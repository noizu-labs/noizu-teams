defmodule NoizuTeamsService.Channel do
  require NoizuTeamsWeb.LiveMessage
  import NoizuLabs.EntityReference.Helpers

  def messages(channel) do
    NoizuTeams.Project.Channel.messages(channel)
  end

  def message_audience(channel, audience, message) do
    recipients = case Regex.run(~r/@([a-z\-]*)/, message) do
      [_,"everyone"] ->
        NoizuTeams.Project.Channel.members(channel)
      [] ->
        audience || NoizuTeams.Project.Channel.members(channel)
      [_|t] when is_list(t) ->
        t
      _ ->
        audience || NoizuTeams.Project.Channel.members(channel)
    end
  end

  def message_agent(channel, agent, sender, message) do
    NoizuTeamsService.Agent.message(agent, channel, sender, message)
  end

  def send(channel, sender, audience, message) do
    IO.inspect sender, label: "Sender"
    {:ok, msg} = %NoizuTeams.Project.Channel.Message{
                   channel_id: channel.identifier,
                   project_member_id: sender.identifier,
                   message: message,
                   sender: "PENDING",
                   created_on: DateTime.utc_now(),
                   modified_on: DateTime.utc_now()
                 }  |> NoizuTeams.Repo.insert()
    NoizuTeamsWeb.LiveMessage.publish(
      NoizuTeamsWeb.LiveMessage.live_pub(subject: :channel, instance: channel.identifier, event: :message, payload: %{message: msg})
    )

    audience = message_audience(channel, audience, message)
    project = NoizuTeams.Project.entity(channel.project_id) |> ok?()
    Enum.map(audience, fn(agent) ->
      with {:ok, agent} <- NoizuTeams.Project.Agent.by_slug(project, agent) do
        message_agent(channel, agent, sender, message)
      end
    end)

    {:ok, audience}
  end

end
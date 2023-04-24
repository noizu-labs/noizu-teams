defmodule NoizuTeamsService.Channel do
  require NoizuTeamsWeb.LiveMessage
  require Logger
  import NoizuLabs.EntityReference.Helpers

  def messages(channel) do
    NoizuTeams.Project.Channel.messages(channel)
  end

  def message_audience(project, channel, audience, message) do
    recipients = case Regex.run(~r/@([a-z\-]*)/, message) do
      [_,"everyone"] ->
        NoizuTeams.Project.Channel.members(channel)
      [] ->
        audience || NoizuTeams.Project.Channel.members(channel)
      [_|t] when is_list(t) ->
        Enum.map(t, fn(slug) ->
          with {:ok, agent} <- NoizuTeams.Project.Agent.by_slug(project, slug) do
            agent
            {:ok, member} = NoizuTeams.Project.member(project, agent)
            %{member| member: agent}
            else
            _ -> nil
          end
        end) |> Enum.filter(&(&1))
      _ ->
        audience || NoizuTeams.Project.Channel.members(channel)
    end
  end

  def message_agent(channel, agent, sender, message) do
    NoizuTeamsService.Agent.message(agent, channel, sender, message)
  end

  def send(channel, sender, audience, message) do
    #IO.inspect sender, label: "Sender"
    {:ok, msg} = %NoizuTeams.Project.Channel.Message{
                   channel_id: channel.identifier,
                   project_member_id: sender.identifier,
                   message: message,
                   sender: sender.member.name,
                   created_on: DateTime.utc_now(),
                   modified_on: DateTime.utc_now()
                 }  |> NoizuTeams.Repo.insert()
    NoizuTeamsWeb.LiveMessage.publish(
      NoizuTeamsWeb.LiveMessage.live_pub(subject: :channel, instance: channel.identifier, event: :message, payload: %{message: msg})
    )

    project = NoizuTeams.Project.entity(channel.project_id) |> ok?()
    audience = cond do
      channel.channel_type == :direct ->
        if (sender.member_type == :agent) do
          []
        else
          members = NoizuTeams.Project.Channel.members(channel)
          Logger.error("FILTER HERE")
          Enum.filter(members, &(&1.identifier != sender.member.identifier))
        end

      :else -> message_audience(project, channel, audience, message)
    end |> IO.inspect(label: "Audience")



    Enum.map(audience, fn(recipient) ->
      IO.inspect(recipient, label: "RECIPIENT")
      if (recipient.member.__struct__ in [NoizuTeams.Project.Agent]) do
        message_agent(channel, recipient, sender, message)
      end
    end)

    {:ok, audience}
  end

end
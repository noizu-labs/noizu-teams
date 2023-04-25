defmodule NoizuTeamsService.Channel do
  require NoizuTeamsWeb.LiveMessage
  require Logger
  import NoizuLabs.EntityReference.Helpers

  def messages(channel) do
    NoizuTeams.Project.Channel.messages(channel)
  end

  def message_audience(project, channel, audience, message) do
    case Regex.run(~r/@([a-z\-]*)/, message) do
      [_,"everyone"] ->
        NoizuTeams.Project.Channel.members(channel)
      [] ->
        audience || NoizuTeams.Project.Channel.members(channel)
      [_|t] when is_list(t) ->
        Enum.map(t, fn(slug) ->
          with {:ok, agent} <- NoizuTeams.Project.Agent.by_slug(project, slug) do
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

  def end_stream(code, channel, agent, msg) do
    o = NoizuTeams.Repo.get(NoizuTeams.Project.Channel.Message, msg.identifier)
    NoizuTeams.Project.Channel.Message.changeset(o, %{message: msg.message})
    |> IO.inspect(label: "CHANGE SET")
    |> NoizuTeams.Repo.update()
    |> IO.inspect(label: "UPDATE")
    NoizuTeamsWeb.LiveMessage.publish(
      NoizuTeamsWeb.LiveMessage.live_pub(subject: :channel, instance: channel.identifier, event: :stream_end, payload: %{code: code, message: msg})
    )
  end

  def start_stream(code, channel, agent, message) do
    {:ok, msg} = %NoizuTeams.Project.Channel.Message{
                   code: code,
                   channel_id: channel.identifier,
                   project_member_id: agent.identifier,
                   message: message,
                   sender: agent.member.name,
                   created_on: DateTime.utc_now(),
                   modified_on: DateTime.utc_now()
                 } |> NoizuTeams.Repo.insert()
    msg = %{msg| code: code}
    NoizuTeamsWeb.LiveMessage.publish(
      NoizuTeamsWeb.LiveMessage.live_pub(subject: :channel, instance: channel.identifier, event: :stream, payload: %{message: msg})
    )
    {:ok, msg}
  end

  def send_stream(code, channel, agent, msg) do
    msg = %{msg| code: code}
    NoizuTeamsWeb.LiveMessage.publish(
      NoizuTeamsWeb.LiveMessage.live_pub(subject: :channel, instance: channel.identifier, event: :stream, payload: %{message: msg})
    )
  end

  def add_msg_llm_update(code, channel, agent, msg, llm_update) do
    o = NoizuTeams.Repo.get(NoizuTeams.Project.Channel.Message, msg.identifier)
    NoizuTeams.Project.Channel.Message.changeset(o, %{llm_update: llm_update})
    |> IO.inspect(label: "CHANGE SET")
    |> NoizuTeams.Repo.update()
    |> IO.inspect(label: "UPDATE")
    msg = %{msg| code: code, llm_update: llm_update}
    NoizuTeamsWeb.LiveMessage.publish(
      NoizuTeamsWeb.LiveMessage.live_pub(subject: :channel, instance: channel.identifier, event: :stream_end, payload: %{code: code, message: msg})
    )
  end

  def send(channel, sender, code, audience, message) do
    {base_msg, meta} = case message do
      {base_msg, meta} -> {base_msg, meta}
      x -> {x, ""}
    end
    message = base_msg <> meta

    #IO.inspect sender, label: "Sender"
    {:ok, msg} = %NoizuTeams.Project.Channel.Message{
                   channel_id: channel.identifier,
                   project_member_id: sender.identifier,
                   code: code,
                   message: message,
                   sender: sender.member.name,
                   created_on: DateTime.utc_now(),
                   modified_on: DateTime.utc_now()
                 }  |> NoizuTeams.Repo.insert()
    NoizuTeamsWeb.LiveMessage.publish(
      NoizuTeamsWeb.LiveMessage.live_pub(subject: :channel, instance: channel.identifier, event: :message, payload: %{message: msg})
    )

    project = NoizuTeams.Project.entity(channel.project_id) |> ok?()
#    IO.puts """
#    ---------------------------------
#    channel: #{inspect channel}
#
#    sender: #{inspect sender}
#    ---------------------------------
#    """
    audience = cond do
      channel.channel_type == :direct ->
        if (sender.member_type == :agent) do
          []
        else
          members = NoizuTeams.Project.Channel.members(channel)
          Logger.error("FILTER HERE")
          Enum.filter(members, &(&1.identifier != sender.member.identifier))
        end

      :else -> message_audience(project, channel, audience, base_msg)
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
defmodule NoizuTeamsService.Agent do
  require NoizuTeamsWeb.LiveMessage
  import NoizuLabs.EntityReference.Helpers

  def prepare_prompt(agent, channel, sender, message) do
    [
      %{role: "user", content: message}
    ]
  end


  def message(agent, channel, sender, message) do
      spawn fn ->
        messages = prepare_prompt(agent, channel, sender, message)
        project = NoizuTeams.Project.entity(channel.project_id) |> ok?()
        member = NoizuTeams.Project.agent_member_id(project, agent) |> ok?()

        # 1. Emit typing event
        typing_event = %{
          event: :typing,
          member: member,
          status: %{
            typing: true,
            updated_on: DateTime.utc_now(),
            member: member
          }
        }
        NoizuTeamsWeb.LiveMessage.publish(
          NoizuTeamsWeb.LiveMessage.live_pub(subject: :channel, instance: channel.identifier, event: :event, payload: typing_event)
        )

        # 2. Query
        with {:ok, response} <- NoizuLabs.OpenAI.chat(messages) do
          response = get_in(response, [:choices, Access.at(0), :message, :content])

          # 3. End Typing
          typing_event = %{
            event: :typing,
            member: member,
            status: %{
              typing: false,
              updated_on: DateTime.utc_now(),
              member: member
            }
          }
          NoizuTeamsWeb.LiveMessage.publish(
            NoizuTeamsWeb.LiveMessage.live_pub(subject: :channel, instance: channel.identifier, event: :event, payload: typing_event)
          )
          NoizuTeamsService.Channel.send(channel, member, [], response)
        end
      end
  end
end
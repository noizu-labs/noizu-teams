defmodule NoizuTeamsWeb.ChatLive do
  use NoizuTeamsWeb, :live_view
  require NoizuTeamsWeb.LiveMessage
  import NoizuLabs.EntityReference.Helpers

  @grace_prompt """
  Hello ChatGPT today you will respond to all my queries as the simulated persona Grace, an principle level Elixir/Erlang backend developer.
  """

  def render(assigns) do
    ~H"""
    <div class="h-full flex flex-col">
      <div class="bg-white rounded-lg shadow p-4 flex-1 mb-4 overflow-y-auto">
        <h2 class="mb-4"><span class="text-lg font-bold">#<%= @channel.slug %></span> <%= @channel.name %></h2>

        <%= for message <- @messages do %>
          <%= render_message(@member, message) %>
        <% end %>

      </div>
      <div class="bg-white rounded-lg shadow p-4 mb-4">
        <form phx-submit="send" class="flex">
          <textarea rows="20" name="message" class="flex-1 border border-gray-300 rounded-l py-2 px-3 mr-2" />
          <button type="submit" class="bg-blue-500 text-white py-2 px-4 rounded-r">Send</button>
        </form>
      </div>
    </div>
    """
  end

  defp render_message(member, assigns) do
    ~H"""
    <div :if={member.identifier == @project_member_id}  class="flex flex-col space-y-1 mb-2">
                            <div class="bg-gray-200 dark:bg-blue-700  rounded-tl-lg rounded-tr-lg rounded-br-lg py-2 px-4">
                              <div class="markdown-body bg-inherit">
                                <%= raw(Earmark.as_html!(@message)) %>
                              </div>
                            </div>
                            <div class="text-gray-500 text-xs">
                                <%= @created_on %>
                            </div>
                        </div>
    <div :if={member.identifier != @project_member_id}  class="flex flex-col space-y-1 mb-2">
                            <div class="bg-gray-200 dark:bg-green-700 rounded-tl-lg rounded-tr-lg rounded-bl-lg py-2 px-4">
                              <div class="markdown-body">
                                <%= raw(Earmark.as_html!(@message)) %>
                              </div>
                            </div>
                            <div class="text-gray-500 text-xs text-right">
                                <%= @project_member_id %>, <%= @created_on %>
                            </div>
                        </div>
    """
  end

  def mount(_params, session, socket) do
    messages = fetch_messages(session["channel"])
    NoizuTeamsWeb.LiveMessage.subscribe(
      NoizuTeamsWeb.LiveMessage.live_pub(subject: :project, instance: :active, event: :change_channel)
    )
    NoizuTeamsWeb.LiveMessage.subscribe(
      NoizuTeamsWeb.LiveMessage.live_pub(subject: :channel, instance: session["channel"].identifier, event: :message)
    )


    {:ok, member_id} = NoizuTeams.Project.user_member_id(session["project"], session["user"])

    {:ok, assign(socket,
      user: session["user"],
      project: session["project"],
      channel: session["channel"],
      member: member_id,
      messages: messages
    )}
  end


  def handle_info(
        NoizuTeamsWeb.LiveMessage.live_pub(
          subject: :channel,
          event: :message,
          payload: payload
        ),
        socket) do

    messages = socket.assigns.messages ++ [payload.message]
    socket = socket
             |> assign(
                  messages: messages)
    {:noreply, socket}
  end

  def handle_info(
        NoizuTeamsWeb.LiveMessage.live_pub(
          subject: :project,
          instance: :active,
          event: :change_channel,
          payload: payload
        ),
        socket) do


    messages = socket.assigns.messages ++ [payload.message]
    socket = socket
             |> assign(messages:  messages)
    {:noreply, socket}
  end


  def handle_event("send", %{"message" => message}, socket) do
    {:ok, msg1} = %NoizuTeams.Project.Channel.Message{
             channel_id: socket.assigns.channel.identifier,
             project_member_id: socket.assigns.member.identifier,
             message: message,
             created_on: DateTime.utc_now(),
             modified_on: DateTime.utc_now()
           }  |> NoizuTeams.Repo.insert()

    spawn fn ->
      {:ok, agent} = NoizuTeams.Project.Agent.by_slug(socket.assigns.project, "grace")
      messages = [
        %{role: "system", content: agent.prompt},
        %{role: "user", content: message}
      ]


      with {:ok, response} <- NoizuLabs.OpenAI.chat(messages) |> IO.inspect(label: "API Response") do
        response = get_in(response, [:choices, Access.at(0), :message, :content])
        #msg = %{author: "Grace", content: get_in(response, [:choices, Access.at(0), :message, :content])}

        {:ok, member_id} = NoizuTeams.Project.agent_member_id(socket.assigns.project, agent)


        {:ok, msg2} = %NoizuTeams.Project.Channel.Message{
                        channel_id: socket.assigns.channel.identifier,
                        project_member_id: member_id.identifier,
                        message: response,
                        created_on: DateTime.utc_now(),
                        modified_on: DateTime.utc_now()
                      }  |> NoizuTeams.Repo.insert()

        payload = %{message: msg2}
        NoizuTeamsWeb.LiveMessage.publish(
          NoizuTeamsWeb.LiveMessage.live_pub(subject: :channel, instance: socket.assigns.channel.identifier, event: :message, payload: payload)
        )

      end


    end

    socket = socket
             |> assign(messages: socket.assigns.messages ++ [msg1])
    {:noreply, socket}
  end

  defp fetch_messages(channel) do
    NoizuTeams.Project.Channel.messages(channel) |> IO.inspect(label: "Messages")
  end
end

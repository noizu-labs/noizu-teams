defmodule NoizuTeamsWeb.ChatLive do
  use NoizuTeamsWeb, :live_view
  require NoizuTeamsWeb.LiveMessage
  import NoizuLabs.EntityReference.Helpers
  require Logger
  def render(assigns) do
    ~H"""
    <div class="h-full flex flex-col">
      <div class="bg-white rounded-lg shadow p-4 flex-1 mb-4 overflow-y-auto">
        <h2 class="mb-4"><span class="text-lg font-bold">#<%= @channel.slug %></span> <%= @channel.name %></h2>

        <%= for message <- @messages do %>
          <%= render_message(@member, message, assigns) %>
        <% end %>

        <%= for {_, typing} <- @typing do %>
          <%= if typing.typing do %>
            <%= typing.member.identifier %> is typing
          <% end %>
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

  defp render_message(member, message, assigns) do
    assigns = assigns
              |> assign(:message, message)
              |> assign(:member, member)

    ~H"""
    <div :if={@member.identifier == @message.project_member_id}  class="flex flex-col space-y-1 mb-2">
                            <div class="bg-gray-200 dark:bg-blue-700  rounded-tl-lg rounded-tr-lg rounded-br-lg py-2 px-4">
                              <div class="markdown-body bg-inherit">
                                <%= raw(Earmark.as_html!(@message.message)) %>
                              </div>
                            </div>
                            <div class="text-gray-500 text-xs">
                                <%= @message.created_on %>
                            </div>
                        </div>
    <div :if={@member.identifier != @message.project_member_id}  class="flex flex-col space-y-1 mb-2">
                            <div class="bg-gray-200 dark:bg-green-700 rounded-tl-lg rounded-tr-lg rounded-bl-lg py-2 px-4">
                              <div class="markdown-body">
                                <%= raw(Earmark.as_html!(@message.message)) %>
                              </div>
                            </div>
                            <div class="text-gray-500 text-xs text-right">
                                <%= @message.sender %>, <%= @message.created_on %>
                            </div>
                        </div>
    """
  end

  def update_subscriptions(previous, channel) do
    if previous != channel do
      if previous do
        NoizuTeamsWeb.LiveMessage.unsubscribe(
          NoizuTeamsWeb.LiveMessage.live_pub(subject: :channel, instance: previous.identifier, event: :message)
        )
        NoizuTeamsWeb.LiveMessage.unsubscribe(
          NoizuTeamsWeb.LiveMessage.live_pub(subject: :channel, instance: previous.identifier, event: :event)
        )
      end

      Logger.error("SUBSCRIBE UPDATE")
      NoizuTeamsWeb.LiveMessage.subscribe(
        NoizuTeamsWeb.LiveMessage.live_pub(subject: :channel, instance: channel.identifier, event: :message)
      )
      NoizuTeamsWeb.LiveMessage.subscribe(
        NoizuTeamsWeb.LiveMessage.live_pub(subject: :channel, instance: channel.identifier, event: :event)
      )
    end
  end

  def mount(_params, session, socket) do
    messages = fetch_messages(session["channel"])
    NoizuTeamsWeb.LiveMessage.subscribe(
      NoizuTeamsWeb.LiveMessage.live_pub(subject: :project, instance: :active, event: :change_channel)
    )
    update_subscriptions(nil, session["channel"])

    {:ok, member_id} = NoizuTeams.Project.user_member_id(session["project"], session["user"])

    {:ok, assign(socket,
      user: session["user"],
      project: session["project"],
      channel: session["channel"],
      typing: %{},
      audience: nil,
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
                  messages: messages
                )
    {:noreply, socket}
  end

  def handle_info(
        NoizuTeamsWeb.LiveMessage.live_pub(
          subject: :channel,
          event: :event,
          payload: payload
        ),
        socket) do

    socket = case payload.event do
      v when v in [:typing] ->
        Logger.error("TYPING UPDATE: #{inspect payload}")
        typing = socket.assigns.typing
                 |> put_in([payload.member.identifier], payload.status)
        socket
        |> assign(typing: typing)
      _ -> socket
    end
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
    previous_channel = socket.assigns.channel
    channel = ERP.entity(payload.channel, nil) |> ok?()
    socket = socket
             |> assign(channel: channel,
                  messages: fetch_messages(channel))
    update_subscriptions(previous_channel, channel)
    {:noreply, socket}
  end


  def handle_event("send", %{"message" => message}, socket) do
    {:ok, audience} = NoizuTeamsService.Channel.send(socket.assigns.channel, socket.assigns.member,  socket.assigns.audience, message)
    socket = socket
             |> assign(audience: audience)
    {:noreply, socket}
  end

  defp fetch_messages(channel) do
    NoizuTeamsService.Channel.messages(channel)
  end
end

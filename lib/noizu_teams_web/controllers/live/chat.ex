defmodule NoizuTeamsWeb.ChatLive do
  use NoizuTeamsWeb, :live_view
  require NoizuTeamsWeb.LiveMessage
  alias Phoenix.LiveView.JS
  import NoizuLabs.EntityReference.Helpers
  require Logger
  def render(assigns) do
    ~H"""
    <div class="h-full flex flex-col">
      <div class="bg-white rounded-lg shadow p-4 flex-1 mb-4 overflow-y-auto">

      <h2 class="mb-4">
          <span :if={@channel.channel_type == :direct}>
            Direct Message: <span  :for={member <- @members}>
      <span class="mr-2" :if={member.identifier != @user.member.identifier }>
    <span :if={member.member_type == :user}>🧬 <%= member.member.name %></span>
    <span :if={member.member_type == :agent}>🔮 <%= member.member.name %></span>
    </span>
              </span>
          </span>
          <span :if={@channel.channel_type == :chat}>
            <span class="text-lg font-bold">#<%= @channel.slug %></span> <%= @channel.name %>
          </span>


      </h2>

        <%= for message <- @messages do %>
          <%= render_message(@user.member, message, assigns) %>
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
    <div id={"msg-" <> @message.identifier}>
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
                              <div class="hide-context" phx-click={%JS{} |> Phoenix.LiveView.JS.toggle(to: "#msg-" <> @message.identifier <> " .msg-llm-context")} :if={@message.llm_update}>
<span class="justify-right">ℹ</span>

                              <div class="msg-llm-context">
                                <pre>
      <%= @message.llm_update %>
                                </pre>
                              </div>

                              </div>

                            </div>
                            <div class="text-gray-500 text-xs text-right">
                                <%= @message.sender %>, <%= @message.created_on %>
                            </div>
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
          NoizuTeamsWeb.LiveMessage.live_pub(subject: :channel, instance: previous.identifier, event: :stream)
        )
        NoizuTeamsWeb.LiveMessage.unsubscribe(
          NoizuTeamsWeb.LiveMessage.live_pub(subject: :channel, instance: previous.identifier, event: :stream_end)
        )
        NoizuTeamsWeb.LiveMessage.unsubscribe(
          NoizuTeamsWeb.LiveMessage.live_pub(subject: :channel, instance: previous.identifier, event: :event)
        )
      end

      NoizuTeamsWeb.LiveMessage.subscribe(
        NoizuTeamsWeb.LiveMessage.live_pub(subject: :channel, instance: channel.identifier, event: :message)
      )
      NoizuTeamsWeb.LiveMessage.subscribe(
        NoizuTeamsWeb.LiveMessage.live_pub(subject: :channel, instance: channel.identifier, event: :stream)
      )
      NoizuTeamsWeb.LiveMessage.subscribe(
        NoizuTeamsWeb.LiveMessage.live_pub(subject: :channel, instance: channel.identifier, event: :stream_end)
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
    members = NoizuTeams.Project.Channel.members(session["channel"])
    user = session["user"]
    {:ok, member} = NoizuTeams.Project.member(session["project"], user)
    user = %{user| member: member}

    {:ok, assign(socket,
      user: user,
      project: session["project"],
      channel: session["channel"],
      typing: %{},
      audience: nil,
      members: members,
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

    messages = socket.assigns.messages
    messages = cond do
      index = payload.message.code && Enum.find_index(messages, &(&1.code == payload.message.code)) ->
        #IO.puts "INSERT AT #{inspect index}"
        put_in(messages, [Access.at(index)], payload.message)
      :else ->
        #IO.puts "APPEND NEW"
        messages ++ [payload.message]
    end

    #IO.puts "REFRESH #{inspect messages}"

    socket = socket
             |> assign(
                  messages: messages
                )
    {:noreply, socket}
  end


  def handle_info(
        NoizuTeamsWeb.LiveMessage.live_pub(
          subject: :channel,
          event: :stream_end,
          payload: payload
        ),
        socket) do

    messages = socket.assigns.messages
    messages = cond do
      index = payload.message.code && Enum.find_index(messages, &(&1.code == payload.message.code)) ->
        put_in(messages, [Access.at(index)], payload.message)
      :else ->
        messages ++ [payload.message]
    end

    #++ [payload.message]
    socket = socket
             |> assign(
                  messages: messages
                )
    {:noreply, socket}
  end

  def handle_info(
        NoizuTeamsWeb.LiveMessage.live_pub(
          subject: :channel,
          event: :stream,
          payload: payload
        ),
        socket) do

    messages = socket.assigns.messages
    messages = cond do
      index = payload.message.code && Enum.find_index(messages, &(&1.code == payload.message.code)) ->
        #IO.puts "INSERT AT #{inspect index}"
        put_in(messages, [Access.at(index)], payload.message)
      :else ->
        #IO.puts "APPEND NEW"
        messages ++ [payload.message]
    end

    #IO.puts "REFRESH #{inspect messages}"

    #++ [payload.message]
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
        #Logger.error("TYPING UPDATE: #{inspect payload.status}")
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
    members = NoizuTeams.Project.Channel.members(channel)
    socket = socket
             |> assign(
                  channel: channel,
                  members: members,
                  messages: fetch_messages(channel)
                )
    update_subscriptions(previous_channel, channel)
    {:noreply, socket}
  end


  def handle_event("send", %{"message" => message}, socket) do
    sender = socket.assigns.user.member
             |> put_in([Access.key(:member)], %{socket.assigns.user| member: nil})
    {:ok, audience} = NoizuTeamsService.Channel.send(socket.assigns.channel, sender, nil, socket.assigns.audience, message)
    socket = socket
             |> assign(audience: audience)
    {:noreply, socket}
  end

  defp fetch_messages(channel) do
    NoizuTeamsService.Channel.messages(channel)
  end
end

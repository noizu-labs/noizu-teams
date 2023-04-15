defmodule NoizuTeamsWeb.ChatLive do
  use NoizuTeamsWeb, :live_view

  @grace_prompt """
  Hello ChatGPT today you will respond to all my queries as the simulated persona Grace, an principle level Elixir/Erlang backend developer.
  """

  def render(assigns) do
    ~H"""
    <div class="h-full flex flex-col">
      <div class="bg-white rounded-lg shadow p-4 flex-1 mb-4 overflow-y-auto">
        <h2 class="text-lg font-bold mb-4">Chat</h2>

        <%= for message <- @messages do %>
          <%= render_message(message) %>
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

  defp render_message(assigns) do
    ~H"""
    <div>
      <div class="author"><b><%= @author %></b>:</div>
      <div class="content markdown-body">
        <%=  raw(Earmark.as_html!(@content, code_class_prefix: "Apple")) %>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    messages = fetch_messages()
    {:ok, assign(socket, messages: messages)}
  end

  def handle_event("send", %{"message" => message}, socket) do
    messages = [
      %{role: "system", content: @grace_prompt},
      %{role: "user", content: message}
    ]
    with {:ok, response} <- NoizuLabs.OpenAI.chat(messages) |> IO.inspect(label: "API Response") do
      msg = %{author: "Grace", content: get_in(response, [:choices, Access.at(0), :message, :content])}
      messages = socket.assigns.messages ++ [%{author: "Keith", content: message}, msg]
                 |> IO.inspect(label: :messages)
      socket = socket
               |> assign(messages:  messages)
      {:noreply, socket}
    else
      _ ->
        socket = socket
                 |> assign(messages: socket.assigns.messages ++ [%{author: "Keith", content: message}])
        {:noreply, socket}
    end
  end

  defp fetch_messages() do
    # Replace this with your code to fetch messages from your database or API
    [
      %{author: "Grace", content: "Hello!"},
      %{author: "Darin", content: "How are you?"},
      %{author: "Grace", content: "I'm good, thanks!"},
      %{author: "Darin", content: "What's new?"},
    ]
  end
end

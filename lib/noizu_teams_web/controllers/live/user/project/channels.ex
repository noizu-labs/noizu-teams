defmodule NoizuTeamsWeb.User.Project.Channels do
  use NoizuTeamsWeb, :live_view

  @grace_prompt """
  Hello ChatGPT today you will respond to all my queries as the simulated persona Grace, an principle level Elixir/Erlang backend developer.
  """

  def render(assigns) do
    ~H"""
    <div class="bg-slate-500 mt-5 rounded-sm flex flex-col">
    <h1 class="mx-auto"> Channels </h1>
    <ul class="pl-4 bg-slate-400">
      <%= for channel <- @channels do %>
        <%= render_channel(channel) %>
      <% end %>
    </ul>
    <div class="mx-auto">Find/Search</div>
    </div>
    """
  end

  defp render_channel(assigns) do
    ~H"""
    <li><span title={@channel.name}>#<%= @channel.slug %></span></li>
    """
  end

  def mount(_params, session, socket) do
    channels = fetch_channels(session["user"], session["project"])
    {:ok, assign(socket, channels: channels)}
  end

  defp fetch_channels(user, project) do
    with {:ok, channels} <- NoizuTeams.User.Project.Channel.user_channels(user, project) do
      channels
    else
      _ -> []
    end |> IO.inspect(label: "CHANNELS")
  end
end

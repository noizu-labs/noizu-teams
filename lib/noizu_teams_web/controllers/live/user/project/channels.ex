defmodule NoizuTeamsWeb.User.Project.Channels do
  use NoizuTeamsWeb, :live_view
  require NoizuTeamsWeb.LiveMessage

  def render(assigns) do
    ~H"""
    <div class="bg-slate-500 mt-5 rounded-sm flex flex-col">
    <h1 class="mx-auto"> Channels (+)</h1>
    <ul class="pl-4 bg-slate-400">
      <%= for channel <- @channels do %>
        <%= render_channel(channel) %>
      <% end %>
    </ul>
    </div>
    """
  end

  defp render_channel(assigns) do
    ~H"""
    <li><a phx-click={"channel:change:" <> @channel.identifier} href="#" title={@channel.name}>#<%= @channel.slug %></a></li>
    """
  end

  def mount(_params, session, socket) do
    channels = fetch_channels(session["user"], session["project"])
    {:ok, assign(socket,
      project: session["project"],
      user: session["user"],
      channels: channels
    )}
  end


  def handle_event("channel:change:" <> channel, form, socket) do
    payload = %{
      project: {:ref,  NoizuTeams.Project, socket.assigns[:project].identifier},
      user: {:ref,  NoizuTeams.Project, socket.assigns[:user].identifier},
      channel: {:ref, NoizuTeams.Project.Channel, channel}
    }
    NoizuTeamsWeb.LiveMessage.publish(
      NoizuTeamsWeb.LiveMessage.live_pub(subject: :project, instance: :active, event: :change_channel, payload: payload)
    )

    {:noreply, socket}
  end

  defp fetch_channels(user, project) do
    with {:ok, channels} <- NoizuTeamsService.Project.channels(project, user, nil) do
      channels
    else
      _ -> []
    end
  end
end

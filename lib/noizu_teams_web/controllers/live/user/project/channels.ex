defmodule NoizuTeamsWeb.User.Project.Channels do
  use NoizuTeamsWeb, :live_view
  require NoizuTeamsWeb.LiveMessage
  import NoizuLabs.EntityReference.Helpers
  require Logger
  def render(assigns) do
    ~H"""
    <div class="bg-slate-500 mt-5 rounded-sm flex flex-col">
    <h1 class="mx-auto"> Channels (<a phx-click="channel:add" href="#">+</a>)</h1>
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
    <li><a phx-click={"channel:change:" <> @identifier} href="#" title={@name}>#<%= @slug %></a></li>
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

  def handle_event("channel:add", _, socket) do
    session = %{
      "project" =>  ERP.entity(socket.assigns.project, nil) |> ok?,
      "user" => socket.assigns.user,
      "identifier" => "add-channel"
    }
    payload = %NoizuTeamsWeb.Nav.Modal.Definition{
      mask: :required,
      enabled: true,
      identifier: "add-channel",
      title: "Create Channel",
      widget: {NoizuTeamsWeb.Project.Channel, "add-channel", session},
      theme: nil,
      size: :md,
      position: %{top: "top-[10%]", left: "left-[20%]" }, # would be nice if we could grab out position
    }
    NoizuTeamsWeb.LiveMessage.publish(
      NoizuTeamsWeb.LiveMessage.live_pub(subject: :modal, instance: "add-channel", event: :launch, payload: payload)
    )
    {:noreply, socket}
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

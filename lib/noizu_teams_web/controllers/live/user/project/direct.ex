defmodule NoizuTeamsWeb.User.Project.Direct do
  use NoizuTeamsWeb, :live_view
  require NoizuTeamsWeb.LiveMessage
  import NoizuLabs.EntityReference.Helpers
  require Logger
  def render(assigns) do
    ~H"""
    <div class="bg-slate-500 mt-5 rounded-sm flex flex-col">
    <h1 class="mx-auto"> Direct (<a phx-click="direct:add" href="#">+</a>)</h1>
    <ul class="pl-4 bg-slate-400">
      <%= for member <- @members do %>
        <%= render_direct(member) %>
      <% end %>
    </ul>
    </div>
    """
  end


  defp render_direct(assigns) do
    ~H"""

    <li>
    <span :if={@member_type == :agent}>🔮<%= @name %><span class="block float-right"><a phx-click={"direct:change:" <> @identifier} href={"#" <> @identifier}>💬</a> </span></span>
    <span :if={@member_type == :user}>🧬<%= @name %><span class="block float-right"><a phx-click={"direct:change:" <> @identifier} href={"#" <> @identifier}>💬</a> </span></span>

    </li>

    """
  end

  def handle_event("direct:change:" <> direct, form, socket) do
    # 1. Get members
    member_b = Enum.find(socket.assigns.members, &(&1.identifier == direct))
    member_a = socket.assigns.user_member

    # 2. Check for a direct channel, or create
    {:ok, channel} = (with {:ok, channel} <- NoizuTeams.Project.Channel.direct_channel(socket.assigns.project, member_a, member_b) do
                        {:ok, channel}
                      else
                        _ ->
                          {:ok, channel} = NoizuTeams.Project.Channel.add_direct_channel(socket.assigns.project, member_a, member_b)
                      end)

    # 3. Change Channel
    payload = %{
      project: {:ref,  NoizuTeams.Project, socket.assigns.project.identifier},
      user: {:ref,  NoizuTeams.Project, socket.assigns.user.identifier},
      channel: {:ref, NoizuTeams.Project.Channel, channel.identifier}
    }
    NoizuTeamsWeb.LiveMessage.publish(
      NoizuTeamsWeb.LiveMessage.live_pub(subject: :project, instance: :active, event: :change_channel, payload: payload)
    )

    {:noreply, socket}
  end

  def mount(_params, session, socket) do
    members = fetch_members(session["user"], session["project"])
    user_member = NoizuTeams.Project.member(session["project"], session["user"]) |> ok?()
    {:ok, assign(socket,
      project: session["project"],
      user: session["user"],
      user_member: user_member,
      members: members
    )}
  end

  def handle_event("direct:add", _, socket) do
    session = %{
      "project" =>  ERP.entity(socket.assigns.project, nil) |> ok?,
      "user" => socket.assigns.user,
      "identifier" => "add-direct"
    }
    payload = %NoizuTeamsWeb.Nav.Modal.Definition{
      mask: :required,
      enabled: true,
      identifier: "add-direct",
      title: "Create Channel",
      widget: {NoizuTeamsWeb.Project.Channel, "add-direct", session},
      theme: nil,
      size: :md,
      position: %{top: "top-[10%]", left: "left-[20%]" }, # would be nice if we could grab out position
    }
    NoizuTeamsWeb.LiveMessage.publish(
      NoizuTeamsWeb.LiveMessage.live_pub(subject: :modal, instance: "add-direct", event: :launch, payload: payload)
    )

    {:noreply, socket}
  end

  defp fetch_members(user, project) do
    with {:ok, members} <- NoizuTeamsService.Project.members(project, user, nil) do
      members
    else
      _ -> []
    end
  end
end

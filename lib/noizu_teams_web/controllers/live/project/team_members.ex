defmodule NoizuTeamsWeb.Project.TeamMembers do
  use NoizuTeamsWeb, :live_view
  import Phoenix.LiveView.JS
  import NoizuTeamsWeb.Nav.Tags
  import NoizuLabs.EntityReference.Helpers
  alias Phoenix.PubSub
  require Logger
  require NoizuTeamsWeb.LiveMessage

  defp error_title(error), do: "Team Member"
  defp error_body(error) do
    "An error has Occurred"
  end

  def render(assigns) do
    ~H"""
    <div>




      <div :for={member <- @team_members}>
      <%= if member.agent do %>
      <span class="bg-red-100 border border-red-400 text-red-700">Agent</span>

      <% end %>
      <span><%= member.name %></span>

      </div>
    </div>
    """
  end

  def handle_event("team1234", form_data, socket) do
    {:noreply, assign(socket, form_data: form_data)}
  end



  def handle_info(
        NoizuTeamsWeb.LiveMessage.live_pub(
          subject: :team,
          instance: :active,
          event: :change,
          payload: payload
        ),
        socket) do

    team = ERP.entity(payload.team, nil) |> ok?()
    members = NoizuTeams.Team.members(team) |> ok?()
    socket = socket
             |> assign(team_name: team.name)
             |> assign(team: ERP.ref(team) |> ok?())
             |> assign(team_members: members)

    socket = socket
             |> assign(team: payload.team)
    {:noreply, socket}
  end


  def mount(_, session, socket) do
    Logger.error("MOUNT#{__MODULE__} , #{inspect socket}, #{inspect session}}")
    NoizuTeamsWeb.LiveMessage.subscribe(
      NoizuTeamsWeb.LiveMessage.live_pub(subject: :team, instance: :active, event: :change)
    )

    team = ERP.entity(session["team"], nil) |> ok?()
    members = NoizuTeams.Team.members(team) |> ok?()
    socket = socket
             |> assign(project: ERP.ref(session["project"]) |> ok?())
             |> assign(team_name: team.name)
             |> assign(team: ERP.ref(team) |> ok?())
             |> assign(team_members: members)
    {:ok, socket}
  end
end
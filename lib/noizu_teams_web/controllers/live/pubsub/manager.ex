defmodule NoizuTeamsWeb.PubSub.Manager do
  use NoizuTeamsWeb, :live_view
  require Logger
#
#  defp error_title(_error), do: "Team Member"
#  defp error_body(_error) do
#    "An error has Occurred"
#  end

  def render(assigns) do
    ~H"""
    <div id="team-members" phx-hook="phx:team1234">

      [ <%= @project %> : <%= @team %> ]
      <div :for={_member <- @team_members}>
      TEAM MEMBER
      </div>
    </div>
    """
  end

  def handle_event("team1234", form_data, socket) do
    {:noreply, assign(socket, form_data: form_data)}
  end


  def mount(_, session, socket) do
    Logger.error("MOUNT#{__MODULE__} , #{inspect socket}, #{inspect session}}")
    socket = socket
             |> assign(project: session["project"].identifier)
             |> assign(team: session["team"].identifier)
             |> assign(team_members: [1,2,3,4])
    {:ok, socket}
  end
end
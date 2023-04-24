defmodule NoizuTeamsWeb.AgentLive do
  use NoizuTeamsWeb, :live_view
  import NoizuLabs.EntityReference.Helpers
  import NoizuTeamsWeb.Project.Tags
  def render(assigns) do
    ~H"""
    <.team_member member={@agent} />
    """
  end

  def mount(_m, session, socket) do
    agent = fetch_agent(session["agent_id"])
    {:ok, assign(socket, agent: agent)}
  end



  def handle_event("spawn:edit:agent:modal:" <> _slug, _, socket) do
    # Recursive and unnecessary but leaving in for testing stacked modals
    NoizuTeamsWeb.Project.TeamMembers.agent_edit_modal("nested-edit-#{socket.assigns[:agent].slug}", socket, socket.assigns[:agent])
    {:noreply, socket}
  end


  defp fetch_agent(agent_id) do
    ERP.entity(agent_id, nil) |> ok?()
  end
end

defmodule NoizuTeamsWeb.AgentsLive do
  use NoizuTeamsWeb, :live_view

  def render(assigns) do

    ~H"""
        <%= for agent <- @agents do %>
          <%= live_render(@socket, NoizuTeamsWeb.AgentLive, id: agent) %>
        <% end %>
    """
  end

  def mount(_params, _session, socket) do
    agents = fetch_agents()
    {:ok, assign(socket, agents: agents)}
  end

  defp fetch_agents() do
    # Replace this with your code to fetch agents from your database or API
    [
      1,2,3
    ]
  end
end

defmodule NoizuTeamsWeb.AgentLive do
  use NoizuTeamsWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="bg-white rounded-lg shadow p-4 mb-4">
      <h2 class="text-lg font-bold mb-4"><%= @agent.name %></h2>
      <div class="flex mb-2">
        <div class="w-16 h-16 bg-gray-400 rounded-full mr-4"></div>
        <div>
          <p class="text-sm"><%= @agent.description %></p>
        </div>
      </div>
    </div>
    """
  end

  def mount(_m, _session, socket) do
    agent = fetch_agent(socket.id)
    {:ok, assign(socket, agent: agent)}
  end

  defp fetch_agent(agent_id) do
    # Replace this with your code to fetch an agent from your database or API
    case agent_id do
      "1" ->
        %{
          id: agent_id,
          name: "Grace",
          description: "Elixir Developer"
        }
      "2" ->
        %{
          id: agent_id,
          name: "Darin",
          description: "UX Designer"
        }
      "3" ->
        %{
          id: agent_id,
          name: "Tyna",
          description: "Project Manager"
        }
    end

  end
end


defmodule NoizuTeamsService.ProjectManager do
  use DynamicSupervisor
  require Logger
  @doc """
  Starts the ProjectManager.
  """
  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_) do
    spawn fn ->
      Process.sleep(1000)
      with {:ok, projects} <- NoizuTeams.Project.projects() do
        Enum.map(projects, fn(project) ->
          start_project_supervisor(project)
        end)
      end
    end
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Creates a new ProjectSupervisor with a list of agent UUIDs.
  """
  def start_project_supervisor(project) do
    spec = {NoizuTeamsService.Project, project}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end

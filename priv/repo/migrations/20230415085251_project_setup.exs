defmodule NoizuTeams.Repo.Migrations.ProjectSetup do
  use Ecto.Migration
  alias NoizuTeams.Repo
  def up do

    now = DateTime.utc_now()

    # Noizu Project
    Repo.insert(%NoizuTeams.Project{
      identifier: "54d49532-1625-4b3a-94f6-65a378575356",
      subdomain: "noizu",
      name: "Noizu Labs, inc.",
      description: "Noizu Labs, inc. account",
      status: :enabled,
      created_on: now,
      modified_on: now
    }) |> IO.inspect(label: "Create Noizu Project")


    # Noizu Project.Team
    now = DateTime.utc_now()
    Repo.insert(%NoizuTeams.Team{
      identifier: "d8b62ad8-54e4-44d6-b27a-1b00819f0443",
      project_id: "54d49532-1625-4b3a-94f6-65a378575356",
      name: "bootstrap",
      slug: "bootstrap",
      description: "Team for Developing the teams.noizu.com product",
      status: :enabled,
      created_on: now,
      modified_on: now
    })  |> IO.inspect(label: "Create Noizu Project.Team")


    now = DateTime.utc_now()
    NoizuTeams.Repo.insert(%NoizuTeams.Team{
      identifier: "ba8afa63-a6df-42e1-956c-7da4176ce20b",
      project_id: "54d49532-1625-4b3a-94f6-65a378575356",
      name: "other",
      slug: "other",
      description: "Second Team",
      status: :enabled,
      created_on: now,
      modified_on: now
    })  |> IO.inspect(label: "Create Noizu Project.Team")
  end

  def down do
    Repo.delete(NoizuTeams.Team, "ba8afa63-a6df-42e1-956c-7da4176ce20b")
    Repo.delete(NoizuTeams.Team, "d8b62ad8-54e4-44d6-b27a-1b00819f0443")
    Repo.delete(NoizuTeams.Project, "54d49532-1625-4b3a-94f6-65a378575356")
  end
end

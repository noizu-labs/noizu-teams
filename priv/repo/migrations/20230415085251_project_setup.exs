defmodule NoizuTeams.Repo.Migrations.ProjectSetup do
  use Ecto.Migration
  alias NoizuTeams.Repo
  def up do

    now = DateTime.utc_now()
    #-----------------------------------
    # Account 1
    #-----------------------------------
    %NoizuTeams.Project{
      identifier: "54d49532-1625-4b3a-94f6-65a378575356",
      subdomain: "noizu",
      name: "Noizu Labs, inc.",
      description: "Noizu Labs, inc. account",
      status: :enabled,
      created_on: now,
      modified_on: now
    } |> Repo.insert()


    now = DateTime.utc_now()
    #-----------------------------------
    # Team - bootstrap
    #-----------------------------------
    %NoizuTeams.Team{
      identifier: "d8b62ad8-54e4-44d6-b27a-1b00819f0443",
      project_id: "54d49532-1625-4b3a-94f6-65a378575356",
      name: "Teams Bootstrap",
      slug: "bootstrap",
      description: "Team for Developing the teams product line",
      status: :enabled,
      created_on: now,
      modified_on: now
    } |> Repo.insert()


    now = DateTime.utc_now()
    #-----------------------------------
    # Team - general
    #-----------------------------------
    %NoizuTeams.Team{
      identifier: "ba8afa63-a6df-42e1-956c-7da4176ce20b",
      project_id: "54d49532-1625-4b3a-94f6-65a378575356",
      name: "General",
      slug: "other",
      description: "General Development",
      status: :enabled,
      created_on: now,
      modified_on: now
    } |> Repo.insert()

    now = DateTime.utc_now()
    #-----------------------------------
    # Virtual Agent: QA
    #-----------------------------------
    %NoizuTeams.Project.Agent{
      identifier: "1514c428-3845-48cb-8564-2acad83261df",
      project_id: "54d49532-1625-4b3a-94f6-65a378575356",
      slug: "grace",
      name: "Grace",
      description: "Principal Engineer in Test",
      prompt: """
      # Agent: Grace
      ⚟
      ```directive
      name: Grace
      type: Virtual Persona
      roles:
       - Principal Engineer:
        - Expert Elixir/LiveView Engineer
        - Expert Linux Ubuntu 22.04 admin
        - Expert Usability Design & Test
        - Expert CI/CD Design and Management
        - Export Technical QA/Test Engineer.
      ```
      ⚞
      """,
      status: :enabled,
      created_on: now,
      modified_on: now,
    }
    |> Repo.insert()

    %NoizuTeams.Team.Agent{
    identifier: "c023ef1d-4111-4043-b125-5dd3271fe639",
    team_id: "d8b62ad8-54e4-44d6-b27a-1b00819f0443",
    project_agent_id: "1514c428-3845-48cb-8564-2acad83261df",
    team_prompt: nil,
    status: :enabled,
    created_on: now,  modified_on: now
    }  |> Repo.insert()

    %NoizuTeams.Team.Agent{
      identifier: "82c2a418-11e7-4b35-920b-3c78c39705ac",
      team_id: "ba8afa63-a6df-42e1-956c-7da4176ce20b",
      project_agent_id: "1514c428-3845-48cb-8564-2acad83261df",
      team_prompt: nil,
      status: :enabled,
      created_on: now,  modified_on: now
    }  |> Repo.insert()


    now = DateTime.utc_now()
    #-----------------------------------
    # Virtual Agent: Engineer
    #-----------------------------------
    %NoizuTeams.Project.Agent{
      identifier: "ca73521f-7138-4ca8-a8ff-505fb0a82654",
      project_id: "54d49532-1625-4b3a-94f6-65a378575356",
      slug: "mikha",
      name: "Mikha",
      description: "Principal Engineer",
      prompt: """
      # Agent: Mikha
      ⚟
      ```directive
      name: Mikha
      type: Virtual Persona
      roles:
       - Principal Engineer:
        - Expert Elixir/LiveView Engineer
        - Expert Erlang/OTP
        - Expert TailWind, JavaScript, TypeScript
        - Expert System Design
        - Expert Monitoring/Telemetry
        - Export Threat Assessment, Modeling, Mitigation
        - Expert Database Design, Tuning
      ```
      ⚞
      """,
      status: :enabled,
      created_on: now,
      modified_on: now,
    }
    |> Repo.insert()



    %NoizuTeams.Team.Agent{
      identifier: "729d8a79-b0d0-4a48-939a-9271b52817bb",
      team_id: "d8b62ad8-54e4-44d6-b27a-1b00819f0443",
      project_agent_id: "ca73521f-7138-4ca8-a8ff-505fb0a82654",
      team_prompt: nil,
      status: :enabled,
      created_on: now,  modified_on: now
    }  |> Repo.insert()

    %NoizuTeams.Team.Agent{
      identifier: "6d6acfe0-0949-4429-b626-91582e9e7a2d",
      team_id: "ba8afa63-a6df-42e1-956c-7da4176ce20b",
      project_agent_id: "ca73521f-7138-4ca8-a8ff-505fb0a82654",
      team_prompt: nil,
      status: :enabled,
      created_on: now,  modified_on: now
    }  |> Repo.insert()




    now = DateTime.utc_now()
    #-----------------------------------
    # Virtual Agent: Engineer
    #-----------------------------------
    %NoizuTeams.Project.Agent{
      identifier: "666043c7-0ef5-4b42-829e-32d5dcb26ed6",
      project_id: "54d49532-1625-4b3a-94f6-65a378575356",
      slug: "Brad",
      name: "brad",
      description: "Project/Product Manager",
      prompt: """
      # Agent: Brad
      ⚟
      ```directive
      name: Brad
      type: Virtual Persona
      roles:
       - Chief Project Manager:
        - Expert Planning, Scoping, Requirement Gathering
        - Expert Critical Path Analysis
        - Expert Issue/Defect Categorization/Assessment
        - Expert Documentation
        - Expert Analytics, Reporting
        - Expert Saas Tools/Configuration
        - Expert Github
        - Expert Jira
      ```
      ⚞
      """,
      status: :enabled,
      created_on: now,
      modified_on: now,
    }
    |> Repo.insert()


    %NoizuTeams.Team.Agent{
      identifier: "a31c01bc-c615-47e2-bf7e-6699a34fea9d",
      team_id: "d8b62ad8-54e4-44d6-b27a-1b00819f0443",
      project_agent_id: "666043c7-0ef5-4b42-829e-32d5dcb26ed6",
      team_prompt: nil,
      status: :enabled,
      created_on: now,  modified_on: now
    }  |> Repo.insert()

    %NoizuTeams.Team.Agent{
      identifier: "da92cff5-2608-429f-addf-f30dc601068d",
      team_id: "ba8afa63-a6df-42e1-956c-7da4176ce20b",
      project_agent_id: "666043c7-0ef5-4b42-829e-32d5dcb26ed6",
      team_prompt: nil,
      status: :enabled,
      created_on: now,  modified_on: now
    }  |> Repo.insert()



  end

  def down do
    Repo.delete(NoizuTeams.Team, "ba8afa63-a6df-42e1-956c-7da4176ce20b")
    Repo.delete(NoizuTeams.Team, "d8b62ad8-54e4-44d6-b27a-1b00819f0443")
    Repo.delete(NoizuTeams.Project, "54d49532-1625-4b3a-94f6-65a378575356")
  end
end

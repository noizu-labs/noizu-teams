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
      name: "Noizu Labs",
      description: "Noizu Labs, inc. account",
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

    %NoizuTeams.Project.Member{
    identifier: "a4183803-bc55-4fcf-a3a7-baa8cacd3f55",
    project_id: "54d49532-1625-4b3a-94f6-65a378575356",
    member_type: :agent,
    member_id: "1514c428-3845-48cb-8564-2acad83261df",
      role: :member,
      position: "Engineer",
      blurb: "Virtual Agent",
    joined_on: now
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

    %NoizuTeams.Project.Member{
      identifier: "3920eb59-2161-4b64-a251-4574fb681fd7",
      project_id: "54d49532-1625-4b3a-94f6-65a378575356",
      member_type: :agent,
      member_id: "ca73521f-7138-4ca8-a8ff-505fb0a82654",
      role: :member,
      position: "Engineer",
      blurb: "Virtual Agent",
      joined_on: now
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


    %NoizuTeams.Project.Member{
      identifier: "93e61443-c293-4bca-a983-194d779e89ee",
      project_id: "54d49532-1625-4b3a-94f6-65a378575356",
      member_type: :agent,
      member_id: "666043c7-0ef5-4b42-829e-32d5dcb26ed6",
      role: :member,
      position: "PM",
      blurb: "Virtual Agent",
      joined_on: now
    }  |> Repo.insert()


    %NoizuTeams.Project.Channel{
      identifier: "5b7bfee3-9400-4a82-b786-ec3aade00f82",
      project_id: "54d49532-1625-4b3a-94f6-65a378575356",
      slug: "general",
      private: false,
      name: "General Chat",
      description: "General Chat",
      created_on: now,
      modified_on: now,

    } |> Repo.insert()

    %NoizuTeams.Project.Channel.Member{
      channel_id: "5b7bfee3-9400-4a82-b786-ec3aade00f82",
      project_member_id: "a4183803-bc55-4fcf-a3a7-baa8cacd3f55",
      joined_on: now,
    } |> Repo.insert()
    %NoizuTeams.Project.Channel.Member{
      channel_id: "5b7bfee3-9400-4a82-b786-ec3aade00f82",
      project_member_id: "3920eb59-2161-4b64-a251-4574fb681fd7",
      joined_on: now,
    } |> Repo.insert()
    %NoizuTeams.Project.Channel.Member{
      channel_id: "5b7bfee3-9400-4a82-b786-ec3aade00f82",
      project_member_id: "93e61443-c293-4bca-a983-194d779e89ee",
      joined_on: now,
    } |> Repo.insert()

  end

  def down do
    Repo.delete(NoizuTeams.Project, "54d49532-1625-4b3a-94f6-65a378575356")
  end
end

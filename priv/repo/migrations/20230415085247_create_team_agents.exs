defmodule NoizuTeams.Repo.Migrations.CreateTeamAgents do
  use Ecto.Migration

  def change do
    create table(:team_agents, primary_key: false) do
      add :identifier, :uuid, primary_key: true
      add :team_id, :uuid, null: false
      add :project_agent_id, :uuid, null: false
      add :team_prompt, :string, null: false

      add :status, :account_status_enum, null: false

      add :created_on, :utc_datetime_usec, null: false
      add :modified_on, :utc_datetime_usec, null: false
      add :deleted_on, :utc_datetime_usec
    end
  end
end

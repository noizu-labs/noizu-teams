defmodule NoizuTeams.Repo.Migrations.CreateTeamMembers do
  use Ecto.Migration

  def change do
    create table(:team_members, primary_key: false) do
      add :identifier, :uuid, primary_key: true
      add :user_id, :uuid, null: false
      add :team_id, :uuid, null: false
      add :role, :team_role_enum, null: false

      add :joined_on, :utc_datetime_usec, null: false
      add :removed_on, :utc_datetime_usec
    end
  end
end

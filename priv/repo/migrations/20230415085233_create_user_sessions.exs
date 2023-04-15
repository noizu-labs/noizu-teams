defmodule NoizuTeams.Repo.Migrations.CreateUserSessions do
  use Ecto.Migration

  def change do
    create table(:user_sessions, primary_key: false) do
      add :identifier, :uuid, primary_key: true
      add :user_id, :uuid, null: false
      add :client_id, :uuid, null: false
      add :active, :boolean, default: false, null: false
      add :created_on, :utc_datetime_usec, null: false
      add :modified_on, :utc_datetime_usec, null: false
      add :deleted_on, :utc_datetime_usec
    end
  end
end

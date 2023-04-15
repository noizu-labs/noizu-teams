defmodule NoizuTeams.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams, primary_key: false) do
      add :identifier, :uuid, primary_key: true
      add :name, :string, null: false
      add :description, :string, null: false
      add :status, :account_status_enum, null: false

      add :created_on, :utc_datetime_usec, null: false
      add :modified_on, :utc_datetime_usec, null: false
      add :deleted_on, :utc_datetime_usec
    end
  end
end

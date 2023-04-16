defmodule NoizuTeams.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :identifier, :uuid, primary_key: true
      add :slug, :string, null: false
      add :name, :string, null: false
      add :email, :citext, null: false
      add :login_name, :citext, null: false
      add :status, :account_status_enum, null: false

      add :created_on, :utc_datetime_usec, null: false
      add :modified_on, :utc_datetime_usec, null: false
      add :deleted_on, :utc_datetime_usec
    end
    create unique_index(:users, [:slug])
    create unique_index(:users, [:email])
    create unique_index(:users, [:login_name])
  end
end

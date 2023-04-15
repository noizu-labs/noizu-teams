defmodule NoizuTeams.Repo.Migrations.CreateUserClients do
  use Ecto.Migration

  def change do
    create table(:user_clients, primary_key: false) do
      add :identifier, :uuid, primary_key: true
      add :user_id, :uuid, null: false

      add :name, :string, null: false
      add :description, :string, null: false

      add :type, :client_type_enum, null: false
      add :client_string, :string, null: false

      add :created_on, :utc_datetime_usec, null: false
      add :modified_on, :utc_datetime_usec, null: false
      add :deleted_on, :utc_datetime_usec
    end
  end
end

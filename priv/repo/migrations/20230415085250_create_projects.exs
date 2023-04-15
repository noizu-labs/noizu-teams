defmodule NoizuTeams.Repo.Migrations.CreateProject do
  use Ecto.Migration

  def up do
    create table(:projects, primary_key: false) do
      add :identifier, :uuid, primary_key: true
      add :subdomain, :string, null: false

      add :name, :string, null: false
      add :description, :string, null: false
      add :status, :account_status_enum, null: false

      add :created_on, :utc_datetime_usec, null: false
      add :modified_on, :utc_datetime_usec, null: false
      add :deleted_on, :utc_datetime_usec
    end

    create table(:project_members, primary_key: false) do
      add :identifier, :uuid, primary_key: true
      add :user_id, :uuid, null: false
      add :project_id, :uuid, null: false
      add :role, :team_role_enum, null: false

      add :position, :string
      add :blurb, :string

      add :joined_on, :utc_datetime_usec, null: false
      add :removed_on, :utc_datetime_usec
    end

    create table(:project_agents, primary_key: false) do
      add :identifier, :uuid, primary_key: true
      add :project_id, :uuid, null: false

      add :slug, :string, null: false
      add :name, :string, null: false
      add :description, :string, null: false
      add :prompt, :string, null: false

      add :status, :account_status_enum, null: false

      add :created_on, :utc_datetime_usec, null: false
      add :modified_on, :utc_datetime_usec, null: false
      add :deleted_on, :utc_datetime_usec
    end
  end

  def down do
    drop table(:project_agents)
    drop table(:project_members)
    drop table(:projects)
  end
end

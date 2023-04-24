defmodule NoizuTeams.Repo.Migrations.ProjectPromptSetup do
  use Ecto.Migration
  alias NoizuTeams.Repo
  def up do

    create table(:project_prompts, primary_key: false) do
      add :identifier, :uuid, primary_key: true
      add :project_id, :uuid, null: false

      add :slug, :string, null: false
      add :name, :string, null: false
      add :description, :string, null: false
      add :prompt, :text, null: false

      add :created_on, :utc_datetime_usec, null: false
      add :modified_on, :utc_datetime_usec, null: false
      add :deleted_on, :utc_datetime_usec
    end

  end

  def down do
    drop table(:project_prompts)
  end
end

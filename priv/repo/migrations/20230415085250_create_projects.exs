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
      add :member_type, :member_type_enum, null: false
      add :member_id, :uuid, null: false
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
      add :name, :string, null: false
      add :slug, :string, null: false
      add :description, :string, null: false

      add :identity, :text, null: false
      add :purpose, :text, null: false
      add :self_image, :text, null: false
      add :mood, :string, null: false


      add :status, :account_status_enum, null: false

      add :created_on, :utc_datetime_usec, null: false
      add :modified_on, :utc_datetime_usec, null: false
      add :deleted_on, :utc_datetime_usec
    end

    create table(:project_agent_memories, primary_key: false) do
      add :identifier, :uuid, primary_key: true
      add :agent_id, :uuid, null: false

      add :subject, :string, null: false
      add :topic, :string, null: false
      add :memory, :string, null: false

      add :created_on, :utc_datetime_usec, null: false
      add :modified_on, :utc_datetime_usec, null: false
      add :deleted_on, :utc_datetime_usec
    end

    create table(:project_agent_mind_readings, primary_key: false) do
      add :identifier, :uuid, primary_key: true
      add :agent_id, :uuid, null: false

      add :subject, :string, null: false
      add :observation, :string, null: false

      add :created_on, :utc_datetime_usec, null: false
      add :modified_on, :utc_datetime_usec, null: false
      add :deleted_on, :utc_datetime_usec
    end


    create table(:project_agent_observations, primary_key: false) do
      add :identifier, :uuid, primary_key: true
      add :agent_id, :uuid, null: false

      add :context, :string, null: false
      add :observation, :string, null: false

      add :created_on, :utc_datetime_usec, null: false
      add :modified_on, :utc_datetime_usec, null: false
      add :deleted_on, :utc_datetime_usec
    end

    create table(:project_agent_opinions, primary_key: false) do
      add :identifier, :uuid, primary_key: true
      add :agent_id, :uuid, null: false

      add :context, :string, null: false
      add :observation, :string, null: false

      add :created_on, :utc_datetime_usec, null: false
      add :modified_on, :utc_datetime_usec, null: false
      add :deleted_on, :utc_datetime_usec
    end



    create table(:project_channels, primary_key: false) do
      add :identifier, :uuid, primary_key: true
      add :project_id, :uuid, null: false
      add :channel_type, :channel_type_enum, null: false
      add :slug, :string, null: true
      add :private, :boolean, null: false, default: false
      add :name, :string, null: false
      add :description, :string, null: true

      add :created_on, :utc_datetime_usec, null: false
      add :modified_on, :utc_datetime_usec, null: false
      add :deleted_on, :utc_datetime_usec
    end


    create table(:project_channel_members, primary_key: false) do
      add :identifier, :uuid, primary_key: true
      add :channel_id, :uuid, null: false
      add :project_member_id, :uuid, null: false
      add :joined_on, :utc_datetime_usec, null: false
    end

    #  field :channel_id, Ecto.UUID
    #    field :project_member_id, Ecto.UUID
    #    field :message, :string
    #    field :created_on, :utc_datetime_usec
    #    field :modified_on, :utc_datetime_usec
    #    field :deleted_on, :utc_datetime_usec
    create table(:project_channel_messages, primary_key: false) do
      add :identifier, :uuid, primary_key: true
      add :channel_id, :uuid, null: false
      add :project_member_id, :uuid, null: false
      add :message, :text, null: false
      add :llm_update, :text, null: true
      add :created_on, :utc_datetime_usec, null: false
      add :modified_on, :utc_datetime_usec, null: false
      add :deleted_on, :utc_datetime_usec
    end

    create table(:user_project_channels, primary_key: false) do
      add :identifier, :uuid, primary_key: true
      add :project_id, :uuid, null: false
      add :channel_id, :uuid, null: false
      add :user_id, :uuid, null: false
      add :starred, :boolean, null: false, default: false
      add :joined_on, :utc_datetime_usec, null: false
      add :left_on, :utc_datetime_usec, null: true
    end



  end

  def down do
    drop table(:user_project_channels)
    drop table(:project_channel_members)
    drop table(:project_channels)
    drop table(:project_agent_opinions)
    drop table(:project_agent_observations)
    drop table(:project_agent_mind_readings)
    drop table(:project_agent_memories)
    drop table(:project_agents)
    drop table(:project_members)
    drop table(:projects)
  end
end

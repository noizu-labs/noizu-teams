defmodule NoizuTeams.Project.Agent do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:identifier, :binary_id, autogenerate: true}
  schema "project_agents" do
    field :project_id, Ecto.UUID

    field :name, :string
    field :slug, :string
    field :description, :string
    field :prompt, :string
    field :team_prompt, :string, virtual: true

    field :status, NoizuTeams.AccountStatusEnum
    field :team_status, NoizuTeams.AccountStatusEnum, virtual: true

    field :created_on, :utc_datetime_usec
    field :deleted_on, :utc_datetime_usec
    field :modified_on, :utc_datetime_usec
  end

  @doc false
  def changeset(team_agent, attrs) do
    team_agent
    |> cast(attrs, [:project_id, :slug, :name, :description, :prompt, :status, :created_on, :modified_on, :deleted_on])
    |> validate_required([:project_id, :slug, :name, :description, :prompt, :status, :created_on, :modified_on, :deleted_on])
  end
end

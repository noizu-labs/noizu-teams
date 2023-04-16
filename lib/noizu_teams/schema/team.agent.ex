defmodule NoizuTeams.Team.Agent do
  use Ecto.Schema
  import Ecto.Changeset

  @derive NoizuLabs.EntityReference.Protocol
  @primary_key {:identifier, :binary_id, autogenerate: true}
  schema "team_agents" do
    field :team_id, Ecto.UUID
    field :project_agent_id, Ecto.UUID
    field :team_prompt, :string
    field :status, NoizuTeams.AccountStatusEnum


    field :created_on, :utc_datetime_usec
    field :deleted_on, :utc_datetime_usec
    field :modified_on, :utc_datetime_usec
  end

  @doc false
  def changeset(team_agent, attrs) do
    team_agent
    |> cast(attrs, [:team_id, :project_agent_id, :team_prompt, :status, :created_on, :modified_on, :deleted_on])
    |> validate_required([:team_id, :project_agent_id, :team_prompt, :status, :created_on, :modified_on, :deleted_on])
  end
end

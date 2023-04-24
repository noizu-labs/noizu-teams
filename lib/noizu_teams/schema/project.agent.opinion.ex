defmodule NoizuTeams.Project.Agent.Opinion do
  use Ecto.Schema
  import Ecto.Changeset

  @derive NoizuLabs.EntityReference.Protocol
  @primary_key {:identifier, :binary_id, autogenerate: true}
  schema "project_agent_opinions" do
    field :agent_id, Ecto.UUID

    field :context, :string
    field :observation, :string

    field :created_on, :utc_datetime_usec
    field :deleted_on, :utc_datetime_usec
    field :modified_on, :utc_datetime_usec
  end

  @doc false
  def changeset(team_agent, attrs) do
    team_agent
    |> cast(attrs, [:agent_id, :context, :observation, :created_on, :modified_on, :deleted_on])
    |> validate_required([:agent_id, :context, :observation, :created_on, :modified_on])
  end

end

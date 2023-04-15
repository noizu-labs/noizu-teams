defmodule NoizuTeams.Team.Agent do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:identifier, :binary_id, autogenerate: true}
  schema "team_agents" do
    field :team_id, Ecto.UUID

    field :name, :string
    field :description, :string
    field :prompt, :string

    field :status, NoizuTeams.AccountStatusEnum

    field :created_on, :utc_datetime_usec
    field :deleted_on, :utc_datetime_usec
    field :modified_on, :utc_datetime_usec
  end

  @doc false
  def changeset(team_agent, attrs) do
    team_agent
    |> cast(attrs, [:team_id, :name, :description, :prompt, :status, :created_on, :modified_on, :deleted_on])
    |> validate_required([:team_id, :name, :description, :prompt, :status, :created_on, :modified_on, :deleted_on])
  end
end

defmodule NoizuTeams.Team do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:identifier, :binary_id, autogenerate: true}
  schema "teams" do
    field :name, :string
    field :description, :string
    field :status, NoizuTeams.AccountStatusEnum

    field :created_on, :utc_datetime_usec
    field :deleted_on, :utc_datetime_usec
    field :modified_on, :utc_datetime_usec
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :description, :status, :created_on, :modified_on, :deleted_on])
    |> validate_required([:name, :description, :status, :created_on, :modified_on, :deleted_on])
  end
end

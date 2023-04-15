defmodule NoizuTeams.Team.Member do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:identifier, :binary_id, autogenerate: true}
  schema "team_members" do
    field :user_id, Ecto.UUID
    field :team_id, Ecto.UUID

    field :role, NoizuTeams.TeamRoleEnum

    field :joined_on, :utc_datetime_usec
    field :removed_on, :utc_datetime_usec

  end

  @doc false
  def changeset(team_member, attrs) do
    team_member
    |> cast(attrs, [:team_id, :user_id, :role, :joined_on, :removed_on])
    |> validate_required([:team_id, :user_id, :role, :joined_on, :removed_on])
  end
end

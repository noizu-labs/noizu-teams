defmodule NoizuTeams.Project.Member do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:identifier, :binary_id, autogenerate: true}
  schema "project_members" do
    field :user_id, Ecto.UUID
    field :project_id, Ecto.UUID

    field :role, NoizuTeams.TeamRoleEnum
    field :position, :string
    field :blurb, :string

    field :joined_on, :utc_datetime_usec
    field :removed_on, :utc_datetime_usec
  end

  @doc false
  def changeset(team_member, attrs) do
    team_member
    |> cast(attrs, [:project_id, :user_id, :role, :position, :blurb, :joined_on, :removed_on])
    |> validate_required([:project_id, :user_id, :role, :joined_on])
  end
end

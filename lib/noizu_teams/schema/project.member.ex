defmodule NoizuTeams.Project.Member do
  use Ecto.Schema
  import Ecto.Changeset

  @derive NoizuLabs.EntityReference.Protocol
  @primary_key {:identifier, :binary_id, autogenerate: true}
  schema "project_members" do
    field :member_type, NoizuTeams.MemberTypeEnum
    field :member_id, Ecto.UUID
    field :project_id, Ecto.UUID

    field :member, :map, virtual: true
    field :name, :string, virtual: true
    field :slug, :string, virtual: true

    field :role, NoizuTeams.TeamRoleEnum

    field :team_role, NoizuTeams.TeamRoleEnum, virtual: true
    field :team_position, :string, virtual: true
    field :team_blurb, :string, virtual: true


    field :position, :string
    field :blurb, :string

    field :joined_on, :utc_datetime_usec
    field :removed_on, :utc_datetime_usec
  end

  @doc false
  def changeset(team_member, attrs) do
    team_member
    |> cast(attrs, [:project_id, :member_type, :member_id, :role, :position, :blurb, :joined_on, :removed_on])
    |> validate_required([:project_id, :member_type, :member_id, :role, :joined_on])
  end
end

defmodule NoizuTeams.Project.Channel.Member do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:identifier, :binary_id, autogenerate: true}
  schema "project_channel_members" do
    field :channel_id, Ecto.UUID
    field :project_member_id, Ecto.UUID
    field :member, :map, virtual: true
    field :joined_on, :utc_datetime_usec
  end

  @doc false
  def changeset(team_agent, attrs) do
    team_agent
    |> cast(attrs, [:channel_id, :project_member_id, :joined_on])
    |> validate_required([:channel_id, :project_member_id, :joined_on])
  end

end

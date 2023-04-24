defmodule NoizuTeams.User.Project.Channel do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @primary_key {:identifier, :binary_id, autogenerate: true}
  schema "user_project_channels" do
    field :project_id, Ecto.UUID
    field :channel_id, Ecto.UUID
    field :channel, :map, virtual: true
    field :user_id, Ecto.UUID
    field :starred, :boolean
    field :joined_on, :utc_datetime_usec
    field :left_on, :utc_datetime_usec
  end

  @doc false
  def changeset(team_agent, attrs) do
    team_agent
    |> cast(attrs, [:project_id, :user_id, :channel_id, :starred, :joined_on, :left_on])
    |> validate_required([:project_id, :user_id, :channel_id, :starred, :joined_on])
  end


end

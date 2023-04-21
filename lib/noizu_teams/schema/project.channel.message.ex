defmodule NoizuTeams.Project.Channel.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:identifier, :binary_id, autogenerate: true}
  schema "project_channel_messages" do
    field :channel_id, Ecto.UUID
    field :project_member_id, Ecto.UUID
    field :sender, :string, virtual: true
    field :message, :string
    field :created_on, :utc_datetime_usec
    field :modified_on, :utc_datetime_usec
    field :deleted_on, :utc_datetime_usec
  end

  @doc false
  def changeset(team_agent, attrs) do
    team_agent
    |> cast(attrs, [:channel_id, :project_member_id, :message, :created_on, :modified_on, :deleted_on])
    |> validate_required([:channel_id, :project_member_id, :message, :created_on, :modified_on])
  end

end

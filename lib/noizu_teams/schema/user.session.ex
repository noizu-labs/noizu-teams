defmodule NoizuTeams.User.Session do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:identifier, :binary_id, autogenerate: true}
  schema "user_sessions" do
    field :active, :boolean, default: false
    field :client_id, Ecto.UUID
    field :user_id, Ecto.UUID

    field :created_on, :utc_datetime_usec
    field :deleted_on, :utc_datetime_usec
    field :modified_on, :utc_datetime_usec
  end

  @doc false
  def changeset(user_session, attrs) do
    user_session
    |> cast(attrs, [:user_id, :client_id, :active, :created_on, :modified_on, :deleted_on])
    |> validate_required([:user_id, :client_id, :active, :created_on, :modified_on, :deleted_on])
  end
end

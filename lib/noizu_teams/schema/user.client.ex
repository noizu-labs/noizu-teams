defmodule NoizuTeams.User.Client do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:identifier, :binary_id, autogenerate: true}
  schema "user_clients" do
    field :user_id, Ecto.UUID

    field :name, :string
    field :description, :string

    field :type, NoizuTeams.ClientTypeEnum
    field :client_string, :string

    field :created_on, :utc_datetime_usec
    field :deleted_on, :utc_datetime_usec
    field :modified_on, :utc_datetime_usec
  end

  @doc false
  def changeset(user_client, attrs) do
    user_client
    |> cast(attrs, [:user_id, :name, :description, :type, :client_string, :created_on, :modified_on, :deleted_on])
    |> validate_required([:user_id, :name, :description, :type, :client_string, :created_on, :modified_on, :deleted_on])
  end
end

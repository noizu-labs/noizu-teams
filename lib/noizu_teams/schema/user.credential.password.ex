defmodule NoizuTeams.User.Credential.Password do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:identifier, :binary_id, autogenerate: true}
  schema "user_credential__password" do
    field :user_id, Ecto.UUID
    field :password, :string
    field :enabled, :boolean, default: false

    field :created_on, :utc_datetime_usec
    field :deleted_on, :utc_datetime_usec
    field :modified_on, :utc_datetime_usec
  end

  @doc false
  def changeset(password, attrs) do
    password
    |> cast(attrs, [:user_id, :password, :enabled, :created_on, :modified_on, :deleted_on])
    |> validate_required([:user_id, :password, :enabled, :created_on, :modified_on, :deleted_on])
  end
end

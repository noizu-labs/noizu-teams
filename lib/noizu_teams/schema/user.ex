defmodule NoizuTeams.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:identifier, :binary_id, autogenerate: true}
  schema "users" do
    field :name, :string
    field :status, NoizuTeams.AccountStatusEnum

    field :email, :string
    field :login_name, :string

    field :created_on, :utc_datetime_usec
    field :deleted_on, :utc_datetime_usec
    field :modified_on, :utc_datetime_usec
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :login_name, :status, :created_on, :modified_on, :deleted_on])
    |> validate_required([:name, :email, :login_name, :status, :created_on, :modified_on, :deleted_on])
    |> unique_constraint(:email)
  end
end

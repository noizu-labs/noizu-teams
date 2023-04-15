defmodule NoizuTeams.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false
  alias NoizuTeams.User
  alias NoizuTeams.Repo

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
    |> validate_required([:name, :email, :login_name, :status, :created_on, :modified_on])
    |> unique_constraint(:email)
    |> unique_constraint(:login_name)
  end


  def generate_jwt(user) do
    {:ok, jwt, _} = NoizuTeamsWeb.Guardian.encode_and_sign(user)
    {:ok, jwt}
  end

  def login(email, password) do
    user = Repo.get_by(User, email: String.downcase(email)) || Repo.get_by(User, login_name: String.downcase(email))
    password_hash = Bcrypt.hash_pwd_salt(password) |> IO.inspect(label: "HASH")
    case user do
      nil ->
        {:error, :user_not_found}
      _ ->
        case Repo.get_by(User.Credential.Password, enabled: true) do
          nil ->
            {:error, :invalid_auth}
          user_credential ->
            if Bcrypt.verify_pass(password, user_credential.password) do
              {:ok, user}
            else
              {:error, :invalid_auth}
            end
        end
    end
  end


  def sign_up(attrs) do
    email = attrs["email"]
    password = attrs["password"]
    name = attrs["name"]

    user = Repo.get_by(User, email: String.downcase(email)) || Repo.get_by(User, login_name: String.downcase(email))

    case user do
      nil ->
        password_hash = Bcrypt.hash_pwd_salt(password)
        changeset = User.changeset(%User{}, %{
          name: name,
          email: email,
          login_name: email,
          status: :enabled,
          created_on: DateTime.utc_now(),
          modified_on: DateTime.utc_now(),
        }) |> IO.inspect(label: "Change Set")
        with {:ok, user} <- Repo.insert(changeset),
             {:ok, _} <- Repo.insert(%User.Credential.Password{
               user_id: user.identifier,
               password: password_hash,
               enabled: true,
               created_on: DateTime.utc_now(),
               modified_on: DateTime.utc_now()
             }) do
          {:ok, user}
        else
          error ->
            {:error, {:user_creation_failed, error}}
        end
      _ ->
        {:error, :user_exists}
    end
  end
end

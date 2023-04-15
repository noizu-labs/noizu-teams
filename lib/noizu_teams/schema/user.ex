defmodule NoizuTeams.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false
  alias NoizuTeams.User
  alias NoizuTeams.Repo

  @derive NoizuLabs.EntityReference.Protocol
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


  def indirect_auth(user) do
    {:ok, jwt, _} = NoizuTeamsWeb.Guardian.encode_and_sign(user, %{"login-only" => true}, ttl: {1, :minute})
    {:ok, jwt}
  end

  def ref(%__MODULE__{identifier: identifier}) do
    {:ok, {:ref, __MODULE__, identifier}}
  end


  def id(%__MODULE__{identifier: identifier}) do
    {:ok, identifier}
  end
  def id({:ref, __MODULE__, identifier}) do
    {:ok, identifier}
  end


  def login(email, password) do
    user = Repo.get_by(User, email: String.downcase(email)) || Repo.get_by(User, login_name: String.downcase(email))
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


  def join_project(user, nil), do: nil
  def join_project(user, {:subdomain, subdomain}) do
    with %NoizuTeams.Project{} = project <- NoizuTeams.Repo.get_by(NoizuTeams.Project, subdomain: subdomain) do
      Repo.insert(%NoizuTeams.Project.Member{
        project_id: project.identifier,
        user_id: user.identifier,
        role: :pending,
        joined_on: DateTime.utc_now(),
      })
    end
  end

  def sign_up(attrs, project \\ nil) do
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

          # Attempt to assign to project
          join_project(user, project)

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

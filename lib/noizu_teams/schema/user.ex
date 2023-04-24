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

    field :slug, :string
    field :member, :map, virtual: true
    field :email, :string
    field :login_name, :string

    field :created_on, :utc_datetime_usec
    field :deleted_on, :utc_datetime_usec
    field :modified_on, :utc_datetime_usec
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :login_name, :status, :slug, :created_on, :modified_on, :deleted_on])
    |> validate_required([:name, :email, :login_name, :status, :slug, :created_on, :modified_on])
    |> unique_constraint(:email)
    |> unique_constraint(:login_name)
    |> unique_constraint(:slug)
  end


  def indirect_auth(user) do
    {:ok, jwt, _} = NoizuTeamsWeb.Guardian.encode_and_sign(user, %{"login-only" => true}, ttl: {1, :minute})
    {:ok, jwt}
  end

  def entity(subject, context \\ nil)
  def entity(%__MODULE__{} = this, _), do: {:ok, this}
  def entity({:ref, __MODULE__, identifier}, _) do
    with %__MODULE__{} = this <- NoizuTeams.Repo.get(__MODULE__, identifier) do
      {:ok, this}
    end
  end
  def entity(_, _) do
    {:error, :not_found}
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



  defp random_suffix() do
    :crypto.strong_rand_bytes(3) |> Base.url_encode64 |> String.slice(0, 3)
  end

  @doc """
  Need to deal with uniqueness.
  """
  def slugify_name(name, attempts \\ nil)
  def slugify_name(_name, 0), do: {:error, :slug_error}
  def slugify_name(name, attempts) do
    suffix = cond do
      attempts == nil -> ""
      :else -> "-#{random_suffix()}"
    end
    attempts = attempts || 20

    slug = name
           |> String.downcase()
           |> String.split()
           |> (fn [first_name, last_name | _] ->
      first_initial = String.slice(first_name, 0, 1)
      last_initial = String.slice(last_name, 0, 3)
      Enum.join([first_initial, last_initial], "-")
               end).()
    slug = slug <> suffix
    case NoizuTeams.Repo.get_by(NoizuTeams.User, slug: slug) do
      nil -> {:ok, slug}
      _ -> slugify_name(name, attempts - 1)
    end
  end

  def join_project(_user, nil), do: nil
  def join_project(user, {:subdomain, subdomain}) do
    with %NoizuTeams.Project{} = project <- NoizuTeams.Repo.get_by(NoizuTeams.Project, subdomain: subdomain) do
      {:ok, member} = Repo.insert(%NoizuTeams.Project.Member{
        project_id: project.identifier,
        member_type: :user,
        member_id: user.identifier,
        role: :pending,
        joined_on: DateTime.utc_now(),
      })

#      # Join public channels
#      now = DateTime.utc_now()
#      with {:ok, channels} <- NoizuTeams.Project.channels(project) do
#        Enum.map(channels, fn(channel) ->
#          %NoizuTeams.Project.Channel.Member{
#            channel_id: channel.identifier,
#            project_member_id: member.identifier,
#            joined_on: now,
#          } |> Repo.insert()
#
#          %NoizuTeams.User.Project.Channel{
#            channel_id: channel.identifier,
#            project_id: project.identifier,
#            user_id: user.identifier,
#            starred: false,
#            joined_on: now,
#          } |> Repo.insert()
#        end)
#
#
#
#      end

      {:ok, member}
    end
  end

  def sign_up(attrs, project \\ nil) do
    email = attrs["email"]
    password = attrs["password"]
    name = attrs["name"]


    user = Repo.get_by(User, email: String.downcase(email)) || Repo.get_by(User, login_name: String.downcase(email))
    case user do
      nil ->


        with {:ok, slug} <- slugify_name(name) do

          password_hash = Bcrypt.hash_pwd_salt(password)
          changeset = User.changeset(%User{}, %{
            name: name,
            slug: slug,
            email: email,
            login_name: email,
            status: :enabled,
            created_on: DateTime.utc_now(),
            modified_on: DateTime.utc_now(),
          })
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

        end

      _ ->
        {:error, :user_exists}
    end

  end
end

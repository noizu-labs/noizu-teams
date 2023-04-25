defmodule NoizuTeams.Project do
  use Ecto.Schema
  use NoizuLabs.EntityReference
  import Ecto.Changeset
  import Ecto.Query

  @derive NoizuLabs.EntityReference.Protocol
  @primary_key {:identifier, :binary_id, autogenerate: true}
  schema "projects" do
    field :subdomain, :string
    field :name, :string
    field :description, :string
    field :status, NoizuTeams.AccountStatusEnum

    field :created_on, :utc_datetime_usec
    field :deleted_on, :utc_datetime_usec
    field :modified_on, :utc_datetime_usec


    # Virtual
    field :membership, :map, virtual: true
  end

  def projects() do
    query = from p in NoizuTeams.Project,
            select: p
    {:ok, NoizuTeams.Repo.all(query)}
  end

  def agents(project) do
    query = from m in NoizuTeams.Project.Member,
                 where: m.project_id == ^project.identifier,
                 where: m.member_type == :agent,
                 join: a in NoizuTeams.Project.Agent,
                 on: a.identifier == m.member_id,
                 select: %{m| member: a}
    {:ok, NoizuTeams.Repo.all(query)}
  end

  def members(project, user) do
    query = from m in NoizuTeams.Project.Member,
                 where: m.project_id == ^project.identifier,
                 select: m
    r = NoizuTeams.Repo.all(query)
    r = Enum.map(r, fn(member) ->
      cond do
        member.member_id == user.identifier -> nil
        member.member_type == :user ->
          user = NoizuTeams.Repo.get(NoizuTeams.User, member.member_id)
          %{member| name: user.name}
        member.member_type == :agent ->
          agent = NoizuTeams.Repo.get(NoizuTeams.Project.Agent, member.member_id)
          %{member| name: agent.name}
      end
    end) |> Enum.filter(&(&1))

    {:ok, r}
  end

  def default_channel(project, _user) do
    query = from c in NoizuTeams.Project.Channel,
                 where: c.project_id == ^project.identifier,
                 limit: 1,
                 select: c
    {:ok, NoizuTeams.Repo.one(query)}
  end

  def channels(project) do
    query = from c in NoizuTeams.Project.Channel,
            where: c.project_id == ^project.identifier,
            select: c
    {:ok, NoizuTeams.Repo.all(query)}
  end
#
#  defp default_team_sort__time(a,b) do
#    case DateTime.compare(a.created_on, b.created_on) do
#      :lt -> -1
#      :eq -> 0
#      :gt -> 1
#    end
#  end
#
#  defp default_team_sort__status(a,b) do
#    ar =  NoizuTeams.AccountStatusEnum.ranking(a.status)
#    br =  NoizuTeams.AccountStatusEnum.ranking(b.status)
#    cond do
#      ar == br -> 0
#      ar < br -> -1
#      :else -> 1
#    end
#  end
#
#  defp default_team_sort__membership(a,b) do
#    cond do
#      a.membership == nil && b.membership == nil -> 0
#      a.membership == nil -> -1
#      b.membership == nil -> 1
#      :else ->
#        ar =  NoizuTeams.TeamRoleEnum.ranking(a.membership.role)
#        br =  NoizuTeams.TeamRoleEnum.ranking(b.membership.role)
#        cond do
#          ar == br -> 0
#          ar < br -> -1
#          :else -> 1
#        end
#    end
#  end
#
#  def default_team_sort(a,b) do
#    with 0 <- default_team_sort__membership(a,b),
#         0 <- default_team_sort__status(a,b) do
#      default_team_sort__time(a,b)
#    end |> case do
#           1 -> true
#           _ -> false
#           end
#  end
#
#  def teams(project, user) do
#    {:ok, project_id} = id(project)
#    {:ok, user_id} = ERP.id(user)
#    q = from t in NoizuTeams.Team,
#             left_join: m in NoizuTeams.Team.Member,
#             on: m.team_id == t.identifier,
#             on: m.user_id == ^user_id,
#             where: t.project_id == ^project_id,
#             order_by: m.role,
#             select: %{t| membership: m}
#    teams = NoizuTeams.Repo.all(q)
#
#
#    case teams do
#      [] -> {:error, :none_available}
#      teams when is_list(teams) ->
#        teams = Enum.sort(teams, &__MODULE__.default_team_sort/2)
#        {:ok, teams}
#      _ -> {:error, :no_teams_defined}
#    end
#  end
#
#  def default_team(project, user) do
#    with {:ok, teams} <- teams(project, user) do
#      {:ok, List.first(teams)}
#    end
#  end
  def member(project, nil), do: {:error, :no_subject}
  def member(project, %NoizuTeams.Project.Member{member: member}), do: member(project, member)
  def member(project, %NoizuTeams.Project.Agent{} = member) do
    with role = %NoizuTeams.Project.Member{} <- NoizuTeams.Repo.get_by(NoizuTeams.Project.Member, member_type: :agent, member_id: member.identifier, project_id: project.identifier) do
      {:ok, %{role| slug: member.slug}}
    else
      _ ->
        {:error, :not_found}
    end
  end
  def member(project, %NoizuTeams.User{} = member) do
    with role = %NoizuTeams.Project.Member{} <- NoizuTeams.Repo.get_by(NoizuTeams.Project.Member, member_type: :user, member_id: member.identifier, project_id: project.identifier) do
      {:ok, %{role| slug: member.slug}}
    else
      _ ->
        {:error, :not_found}
    end
  end

  def user_member_id(project, user) do
    with role = %NoizuTeams.Project.Member{} <- NoizuTeams.Repo.get_by(NoizuTeams.Project.Member, member_type: :user, member_id: user.identifier, project_id: project.identifier) do
      {:ok, %{role| slug: user.slug}}
    else
      _ ->
        {:error, :not_found}
    end
  end

  def agent_member_id(project, agent) do
    with role = %NoizuTeams.Project.Member{} <- NoizuTeams.Repo.get_by(NoizuTeams.Project.Member, member_type: :agent, member_id: agent.identifier, project_id: project.identifier) do
      {:ok, %{role| slug: agent.slug}}
    else
      _ ->
        {:error, :not_found}
    end
  end

  def membership(project, user) do
    with role = %NoizuTeams.Project.Member{} <- NoizuTeams.Repo.get_by(NoizuTeams.Project.Member, member_type: :user, member_id: user.identifier, project_id: project.identifier) do
      {:ok, %{role| slug: user.slug}}
    else
      _ ->
        {:error, :not_found}
    end
  end

  def entity(subject, context \\ nil)
  def entity({:subdomain, slug}, _) do
    with %NoizuTeams.Project{} = project <- NoizuTeams.Repo.get_by(NoizuTeams.Project, subdomain: slug) do
      {:ok, project}
    end
  end
  def entity(%__MODULE__{} = this, _), do: {:ok, this}
  def entity(uuid, _) when is_bitstring(uuid) do
    with %__MODULE__{} = this <- NoizuTeams.Repo.get(__MODULE__, uuid) do
      {:ok, this}
    end
  end
  def entity({:ref, __MODULE__, identifier}, _) do
    with %__MODULE__{} = this <- NoizuTeams.Repo.get(__MODULE__, identifier) do
      {:ok, this}
    end
  end
  def entity(_, _) do
    {:error, :not_found}
  end

  def ref(uuid) when is_bitstring(uuid) do
    {:ok, {:ref, __MODULE__, uuid}}
  end
  def ref(%__MODULE__{identifier: identifier}) do
    {:ok, {:ref, __MODULE__, identifier}}
  end
  def ref({:ref, __MODULE__, _} = ref) do
    {:ok, ref}
  end

  def id(%__MODULE__{identifier: identifier}) do
    {:ok, identifier}
  end
  def id({:ref, __MODULE__, identifier}) do
    {:ok, identifier}
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:slug, :name, :description, :status, :created_on, :modified_on, :deleted_on])
    |> validate_required([:slug, :name, :description, :status, :created_on, :modified_on, :deleted_on])
  end
end

defmodule NoizuTeams.Team do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @derive NoizuLabs.EntityReference.Protocol
  @primary_key {:identifier, :binary_id, autogenerate: true}
  schema "teams" do
    field :project_id, Ecto.UUID
    field :name, :string
    field :slug, :string
    field :description, :string
    field :status, NoizuTeams.AccountStatusEnum

    field :created_on, :utc_datetime_usec
    field :deleted_on, :utc_datetime_usec
    field :modified_on, :utc_datetime_usec

    # Virtual
    field :membership, :map, virtual: true

  end

  def members(team) do

    q = from pm in NoizuTeams.Project.Member,
             join: tm in NoizuTeams.Team.Member,
             on: tm.user_id == pm.user_id,
             join: u in NoizuTeams.User,
             on: u.identifier == tm.user_id,
             where: tm.team_id == ^team.identifier,
             order_by: tm.role,
             select: %{pm| name: u.name, slug: u.slug, team_role: tm.role, team_blurb: tm.blurb, team_position: tm.position  }
    humans = NoizuTeams.Repo.all(q)

    q = from ta in NoizuTeams.Team.Agent,
             join: pa in NoizuTeams.Project.Agent,
             on: pa.identifier == ta.project_agent_id,
             where: ta.team_id == ^team.identifier,
             select: %{pa| team_prompt: ta.team_prompt, team_status: ta.status}
    agents = NoizuTeams.Repo.all(q)

    members = Enum.sort(humans ++ agents,
      fn(a,b) ->
        at = case a do
          %{created_on: v} -> v
          %{joined_on: v} -> v
        end

        bt = case b do
          %{created_on: v} -> v
          %{joined_on: v} -> v
        end

        DateTime.compare(at, bt) == :gt

      end)
    {:ok, members}


  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:project_id, :name, :slug, :description, :status, :created_on, :modified_on, :deleted_on])
    |> validate_required([:project_id, :name, :slug, :description, :status, :created_on, :modified_on])
  end


  def ref(%__MODULE__{identifier: identifier}) do
    {:ok, {:ref, __MODULE__, identifier}}
  end


  def entity(subject, context \\ nil)
  def entity(%__MODULE__{} = this, _) do
    {:ok, this}
  end
  def entity({:ref, __MODULE__, id}, _)  do
    with %NoizuTeams.Team{} = entity <- NoizuTeams.Repo.get(NoizuTeams.Team, id) do
      {:ok, entity}
    end
  end
  def entity(_, _) do
    {:error, :not_found}
  end

  def id(%__MODULE__{identifier: identifier}) do
    {:ok, identifier}
  end
  def id({:ref, __MODULE__, identifier}) do
    {:ok, identifier}
  end
end

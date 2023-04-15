defmodule NoizuTeams.Team do
  use Ecto.Schema
  import Ecto.Changeset

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
    if team.slug == "other" do
      {:ok, [%{agent: true, name: "Grace"},%{agent: false, name: "Kimi"},%{agent: false, name: "Darin"},%{agent: false, name: "Laine"}]}
    else
      {:ok, [%{agent: true, name: "Grace"},%{agent: false, name: "Kimi"},%{agent: false, name: "Darin"}]}
    end

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

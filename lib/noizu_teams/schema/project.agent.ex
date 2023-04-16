defmodule NoizuTeams.Project.Agent do
  use Ecto.Schema
  import Ecto.Changeset

  @derive NoizuLabs.EntityReference.Protocol
  @primary_key {:identifier, :binary_id, autogenerate: true}
  schema "project_agents" do
    field :project_id, Ecto.UUID

    field :name, :string
    field :slug, :string
    field :description, :string
    field :prompt, :string
    field :team_prompt, :string, virtual: true

    field :status, NoizuTeams.AccountStatusEnum
    field :team_status, NoizuTeams.AccountStatusEnum, virtual: true

    field :created_on, :utc_datetime_usec
    field :deleted_on, :utc_datetime_usec
    field :modified_on, :utc_datetime_usec
  end

  @doc false
  def changeset(team_agent, attrs) do
    team_agent
    |> cast(attrs, [:project_id, :slug, :name, :description, :prompt, :status, :created_on, :modified_on, :deleted_on])
    |> validate_required([:project_id, :slug, :name, :description, :prompt, :status, :created_on, :modified_on, :deleted_on])
  end



  def entity(subject, context \\ nil)
  def entity(%__MODULE__{} = this, _) do
    {:ok, this}
  end
  def entity({:ref, __MODULE__, id}, _)  do
    with %NoizuTeams.Project.Agent{} = entity <- NoizuTeams.Repo.get(NoizuTeams.Project.Agent, id) do
      {:ok, entity}
    end
  end
  def entity(_, _) do
    {:error, :not_found}
  end

  def ref(%__MODULE__{identifier: identifier}) do
    {:ok, {:ref, __MODULE__, identifier}}
  end
  def ref({:ref, __MODULE__, identifier}) do
    {:ok, {:ref, __MODULE__, identifier}}
  end


  def id(%__MODULE__{identifier: identifier}) do
    {:ok, identifier}
  end
  def id({:ref, __MODULE__, identifier}) do
    {:ok, identifier}
  end


end

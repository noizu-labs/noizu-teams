defmodule NoizuTeams.Project.Prompt do
  use Ecto.Schema
  import Ecto.Changeset

  @derive NoizuLabs.EntityReference.Protocol
  @primary_key {:identifier, :binary_id, autogenerate: true}
  schema "project_prompts" do
    field :project_id, Ecto.UUID

    field :name, :string
    field :slug, :string
    field :description, :string
    field :prompt, :string

    field :created_on, :utc_datetime_usec
    field :deleted_on, :utc_datetime_usec
    field :modified_on, :utc_datetime_usec
  end

  @doc false
  def changeset(team_agent, attrs) do
    team_agent
    |> cast(attrs, [:project_id, :slug, :name, :description, :prompt, :created_on, :modified_on, :deleted_on])
    |> validate_required([:project_id, :slug, :name, :description, :prompt, :created_on, :modified_on])
  end

  def by_slug(project, slug) do
    key = "#{project.subdomain}:#{slug}"
    case NoizuTeams.Redis.get_binary("#{project.subdomain}.#{slug}") do
      {:ok, nil} ->
        with %NoizuTeams.Project.Prompt{} = s <- NoizuTeams.Repo.get_by(NoizuTeams.Project.Prompt, project_id: project.identifier, slug: slug) do
          NoizuTeams.Redis.set_binary([key, s, "EX", 600])
          {:ok, s}
        end
      {:ok, prompt} -> {:ok, prompt}
      e -> e
    end


  end

  def entity(subject, context \\ nil)
  def entity(%__MODULE__{} = this, _) do
    {:ok, this}
  end
  def entity({:ref, __MODULE__, id}, _)  do
    with %NoizuTeams.Project.Agent{} = entity <- NoizuTeams.Repo.get(NoizuTeams.Project.Prompt, id) do
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

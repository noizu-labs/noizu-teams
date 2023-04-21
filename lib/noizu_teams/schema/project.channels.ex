defmodule NoizuTeams.Project.Channel do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  @derive NoizuLabs.EntityReference.Protocol
  @primary_key {:identifier, :binary_id, autogenerate: true}
  schema "project_channels" do
    field :project_id, Ecto.UUID

    field :slug, :string
    field :private, :boolean

    field :name, :string
    field :description, :string

    field :created_on, :utc_datetime_usec
    field :deleted_on, :utc_datetime_usec
    field :modified_on, :utc_datetime_usec
  end

  @doc false
  def changeset(team_agent, attrs) do
    team_agent
    |> cast(attrs, [:project_id, :slug, :private, :name, :description, :created_on, :modified_on, :deleted_on])
    |> validate_required([:project_id, :slug, :private, :name, :description, :created_on, :modified_on])
  end

  def members(channel) do
    query = from m in NoizuTeams.Project.Channel.Member,
                 where: m.channel_id == ^channel.identifier,
                 join: pm in NoizuTeams.Project.Member,
                  on: pm.identifier == m.project_member_id and pm.member_type == :agent,
                 join: a in NoizuTeams.Project.Agent,
                  on: a.identifier == pm.member_id,
                 select: a.slug
    NoizuTeams.Repo.all(query)
  end

  def messages(channel) do
    query = from m in NoizuTeams.Project.Channel.Message,
            where: m.channel_id == ^channel.identifier,
            where: is_nil(m.deleted_on),
            order_by: m.created_on,
            select: m
    messages = NoizuTeams.Repo.all(query)
    Enum.map(messages, fn(m) ->
      IO.inspect(m, label: "------------------------------------MESSAGE")

      s = NoizuTeams.Repo.get_by(NoizuTeams.Project.Member, project_id: channel.project_id, identifier: m.project_member_id)
      case s.member_type do
        :agent ->
          a = NoizuTeams.Repo.get(NoizuTeams.Project.Agent, s.member_id)
          %{m| sender: "🔮 #{a.name}"}
        :user ->
          a = NoizuTeams.Repo.get(NoizuTeams.User, s.member_id)
          %{m| sender: "🧬 #{a.name}"}
      end
    end)
  end

  def entity(subject, context \\ nil)
  def entity(%__MODULE__{} = this, _) do
    {:ok, this}
  end
  def entity({:ref, __MODULE__ = m, id}, _)  do
    with %{__struct__: ^m} = entity <- NoizuTeams.Repo.get(m, id) do
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

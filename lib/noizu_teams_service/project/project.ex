defmodule NoizuTeamsService.Project do
  alias NoizuLabs.EntityReference.Protocol, as: ERP
  import Ecto.Query

  def channels(project, user, context) do
    with {:ok, project} <- ERP.entity(project, context),
         {:ok, user} <- ERP.entity(user, context),
         {:ok, member} <- NoizuTeams.Project.member(project, user) do
      query = from c in NoizuTeams.Project.Channel,
                   where: c.project_id == ^project.identifier,
                   where: c.channel_type == :chat,
                   left_join: j in NoizuTeams.Project.Channel.Member,
                   on: j.channel_id == c.identifier,
                   on: j.project_member_id == ^member.identifier,
                   left_join: uc in NoizuTeams.User.Project.Channel,
                   on: uc.channel_id == c.identifier,
                   on: uc.user_id == ^user.identifier,
                   on: is_nil(uc.left_on),
                   order_by: [uc.starred, uc.joined_on, j.joined_on],
                   select: %{c| starred: (uc.starred or false)}
        r = NoizuTeams.Repo.all(query)
        {:ok, r}
    end
  end

  def members(project, user, context) do
    with {:ok, project} <- ERP.entity(project, context) do
      NoizuTeams.Project.members(project, user)
    end
  end



end
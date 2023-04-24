defmodule NoizuTeamsService.Project do
  alias NoizuLabs.EntityReference.Protocol, as: ERP

  def channels(project, user, context) do
    with {:ok, project} <- ERP.entity(project, context),
         {:ok, user} <- ERP.entity(user, context) do
      NoizuTeams.User.Project.Channel.user_channels(user, project)
    end
  end

end
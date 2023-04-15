defmodule NoizuTeamsWeb.Project.Tags do
  use NoizuTeamsWeb, :live_component

  attr :active, :string, default: nil
  def team_selector(assigns) do
  ~H"""
    <div class="">
    [TEAM SELECTOR]
    </div>
    """
  end

  attr :team, :string, default: nil
  def team_members(assigns) do
    ~H"""
    <div class="">
    [TEAM MEMBER LIST]
    </div>
    """
  end

end
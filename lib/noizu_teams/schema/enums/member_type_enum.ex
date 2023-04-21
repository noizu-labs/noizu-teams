defmodule NoizuTeams.MemberTypeEnum do
  @ranking %{
    user: 0,
    agent: 1,
    tool: 2,
    extension: 3,
    default: 0
  }

  def ranking(role), do: @ranking[role] || @ranking[:default]


  use NoizuTeams.Enum, [:user, :agent, :tool, :extension]
end

defmodule NoizuTeams.ChannelTypeEnum do
  @ranking %{
    chat: 0,
    direct: 1,
    group: 2,
    default: 0
  }

  def ranking(role), do: @ranking[role] || @ranking[:default]

  use NoizuTeams.Enum, [:chat, :direct, :group]
end
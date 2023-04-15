defmodule NoizuTeams.AccountStatusEnum do
  @ranking %{
    enabled: 0,
    locked: 1,
    pending: 3,
    deactivated: 2,
    deleted: 4,
    default: 1000
  }

  def ranking(role), do: @ranking[role] || @ranking[:default]


  use NoizuTeams.Enum, [:deleted, :locked, :enabled, :pending, :deactivated]
end

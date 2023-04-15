defmodule NoizuTeams.TeamRoleEnum do
  @ranking %{
    owner: 0,
    admin: 1,
    member: 2,
    limited: 3,
    pending: 4,
    deactivated: 5,
    none: 6,
    default: 1000
  }

  def ranking(role), do: @ranking[role] || @ranking[:default]

  use NoizuTeams.Enum, [:owner, :admin, :member, :limited, :deactivated, :pending, :none]
end

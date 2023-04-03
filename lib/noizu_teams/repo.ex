defmodule NoizuTeams.Repo do
  use Ecto.Repo,
    otp_app: :noizu_teams,
    adapter: Ecto.Adapters.Postgres
end

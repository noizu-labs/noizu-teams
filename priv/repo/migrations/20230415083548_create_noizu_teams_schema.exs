defmodule NoizuTeams.Repo.Migrations.CreateNoizuTeamsSchema do
  use Ecto.Migration


  def up do
    execute("CREATE EXTENSION IF NOT EXISTS citext")
    execute("CREATE TYPE account_status_enum AS ENUM ('deleted', 'locked', 'enabled', 'deactivated', 'pending')")
    execute("CREATE TYPE team_role_enum AS ENUM ('owner', 'admin', 'member', 'limited', 'deactivated', 'pending')")
    execute("CREATE TYPE client_type_enum AS ENUM ('ios', 'android', 'web', 'app')")
    execute("CREATE TYPE member_type_enum AS ENUM ('user', 'agent', 'tool', 'extension')")
  end

  def down do
    execute("DROP TYPE account_status_enum")
    execute("DROP TYPE team_role_enum")
    execute("DROP TYPE client_type_enum")
    execute("DROP TYPE member_type_enum")
  end

end

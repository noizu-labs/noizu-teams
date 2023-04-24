IO.puts "TEST HELPER"
NoizuTeams.Repo.start() |> IO.inspect(label: "START REPO")
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(NoizuTeams.Repo, :manual)

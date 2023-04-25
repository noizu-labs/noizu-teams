IO.puts "TEST HELPER"
NoizuTeams.Repo.start_link() |> IO.inspect(label: "START REPO")
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(NoizuTeams.Repo, :manual)

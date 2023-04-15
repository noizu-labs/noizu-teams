defmodule NoizuTeamsWeb.Guardian.AuthPipeline do
    use Guardian.Plug.Pipeline, otp_app: :noizu_teams
    plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
    plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
    plug Guardian.Plug.LoadResource, allow_blank: true
end
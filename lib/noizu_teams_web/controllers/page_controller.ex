defmodule NoizuTeamsWeb.PageController do
  use NoizuTeamsWeb, :controller
  require Logger

  defp project(conn, _params) do
    case String.split(conn.host, ".") do
      ["dev", "teams", "noizu", "com"] -> {:subdomain, "noizu"}
      ["dev", p, "teams", "noizu", "com"] -> {:subdomain, p}
      ["teams", "noizu", "com"] -> {:subdomain, "noizu"}
      [p, "teams", "noizu", "com"] -> {:subdomain, p}
      _ -> nil
    end
  end

  def home(conn, params) do
    with %NoizuTeams.User{} = user <- NoizuTeamsWeb.Guardian.Plug.current_resource(conn) do
      # Verify user has access to current project

      with id = {:subdomain, _slug} <- project(conn, params),
           {:ok, project} <- NoizuTeams.Project.entity(id),
           {:ok, project_membership} <- NoizuTeams.Project.membership(project, user),
           true <- project_membership.role not in [:deactivated, :pending],
           {:ok, channel} <- NoizuTeams.Project.default_channel(project, user)
           #{:ok, team} <- NoizuTeams.Project.default_team(project, user),
           #true <- (project_membership.role in [:owner, :admin]) or (team.membership and team.membership.role not in [:deactivated, :pending])
        do
#
#        team_selector = %{
#          "user" => ERP.ref(user) |> ok?,
#          "project" => ERP.ref(project) |> ok?,
#          "project_role" => project_membership.role,
#          "team" => ERP.ref(team) |> ok?,
#          "team_role" => get_in(team, [Access.key(:membership), Access.key(:role, :none)])
#        }

        conn
        |> render(:home,
             %{
               #team_selector: team_selector,
               active_user: user,
               active_project: %{project | membership: project_membership},
               active_channel: channel
               #active_team: team,
             }
           )
      else
        _ ->
          conn
          |> render(:request_access,
               %{
                 active_user: user,
                 active_project: nil,
                 active_channel: nil
               #  active_team: nil,
               #  active_role: nil,
               }
             )
      end


    else
      _e ->
        # temp hardcode
        project_slug = project(conn, params)
        render(conn, :login, project: project_slug, layout: false)
    end
  end

  def logout(conn, _) do
    conn
    |> NoizuTeamsWeb.Guardian.Plug.sign_out()
    |> redirect(to: "/")
  end

  def login(conn, %{"event" => event}) do
    with {:ok, %{"login-only" => true, "sub" => sub}} <- NoizuTeamsWeb.Guardian.decode_and_verify(event["jwt"]),
         {:ok, resource = %NoizuTeams.User{}} <- NoizuTeamsWeb.Guardian.get_resource_by_id(sub) do
      cond do
        event["remember_me"] ->
          conn
          |> NoizuTeamsWeb.Guardian.Plug.sign_in(resource)
          |> NoizuTeamsWeb.Guardian.Plug.remember_me(resource)
          |> json(%{auth: true})
        :else ->
          conn
          |> NoizuTeamsWeb.Guardian.Plug.sign_in(resource)
          |> json(%{auth: true})
      end
    else
      _ ->
        conn
        |> json(%{auth: false})
    end
  end
  def login(conn, params) do
    project_slug = project(conn, params)
    render(conn, :login, project: project_slug, layout: false)
  end

  def terms(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :terms)
  end
end

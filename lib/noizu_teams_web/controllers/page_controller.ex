defmodule NoizuTeamsWeb.PageController do
  use NoizuTeamsWeb, :controller
  require Logger
  def home(conn, _params) do
    with %NoizuTeams.User{} = user <- NoizuTeamsWeb.Guardian.Plug.current_resource(conn) do
      conn
      |> render(:home,
           %{
             active_user: user,
           }
      )
    else
      e ->
        render(conn, :login, layout: false)
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
  def login(conn, _) do
    render(conn, :login, layout: false)
  end

  def terms(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :terms)
  end
end

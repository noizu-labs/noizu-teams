defmodule NoizuTeamsWeb.PageController do
  use NoizuTeamsWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    if auth = get_session(conn, "auth") do
      # validate, correctly sign-in
      render(conn, :home, layout: false)
    else
      render(conn, :login, layout: false)
    end
  end

  def jwt(conn, %{"jwt" => jwt}) do
    conn
    |> put_session("auth", jwt)
    |> redirect(to: "/")
  end

  def terms(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :terms)
  end
end

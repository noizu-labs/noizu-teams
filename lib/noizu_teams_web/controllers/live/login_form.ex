defmodule NoizuTeamsWeb.LoginForm do
  use NoizuTeamsWeb, :live_view

  def render(assigns) do
    ~H"""
      <%= if @mode == :login do %>
        <.live_component module={NoizuTeamsWeb.LoginForm.Login} id="login-page" />
      <% end %>
      <%= if @mode == :sign_up do %>
        <.live_component module={NoizuTeamsWeb.LoginForm.SignUp} id="sign-up-page" />
      <% end %>
    """
  end

  def handle_event("login", _,  socket) do
    socket = assign(socket, mode: :login)
    {:noreply, socket}
  end

  def handle_event("sign-up", _,  socket) do
    socket = assign(socket, mode: :sign_up)
    {:noreply, socket}
  end

  def mount(_params, _session, socket) do
    socket = socket
             |> assign(mode: :login)
    {:ok, socket}
  end
end

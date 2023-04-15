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


  def handle_event("submit:login", form, socket) do
    case NoizuTeams.User.login(form["email"], form["password"]) do
      {:ok, user} ->
        # Handle successful sign-up
        # Generate JWT token
        with {:ok, jwt_token} <- NoizuTeams.User.generate_jwt(user) do
          # Send auth event with JWT token
          IO.inspect socket
          socket = push_event(socket, "auth", %{jwt: jwt_token})
          {:noreply, socket}
        else
          _ ->
            {:noreply, socket}
        end

      {:error, error_msg} ->
        # Handle sign-up failure
        IO.inspect error_msg, label: "Login Error"
        {:noreply, socket}
    end
  end

  def handle_event("submit:sign-up", form, socket) do
    case NoizuTeams.User.sign_up(form) do
      {:ok, user} ->
        # Handle successful sign-up
        IO.inspect user, label: "New User"
      {:error, error_msg} ->
        # Handle sign-up failure
        IO.inspect error_msg, label: "Sign-Up Error"
    end
    {:noreply, socket}
  end

  def mount(_params, _session, socket) do
    socket = socket
             |> assign(mode: :login)
    {:ok, socket}
  end
end

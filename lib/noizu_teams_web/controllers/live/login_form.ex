defmodule NoizuTeamsWeb.LoginForm do
  use NoizuTeamsWeb, :live_view

  def render(assigns) do
    ~H"""
      <%= if @mode == :login do %>
        <.live_component module={NoizuTeamsWeb.LoginForm.Login} id="login-page" form={@login.form} error={@login.error} />
      <% end %>
      <%= if @mode == :sign_up do %>
        <.live_component module={NoizuTeamsWeb.LoginForm.SignUp} id="sign-up-page" form={@signup.form} error={@signup.error} />
      <% end %>
    """
  end

  def handle_event("login", _,  socket) do
    # copy sign up details if set
    login = socket.assigns[:login]
            |> update_in([:form], &(&1 || %{}))
            |> put_in([:error], nil)
            |> then(
                 fn(t) ->
                   if v = socket.assigns[:signup][:form]["email"] do
                     put_in(t, [Access.key(:form, %{}), Access.key("email")], v)
                   else
                     t
                   end
                 end)
            |> then(
                 fn(t) ->
                   if v = socket.assigns[:signup][:form]["password"] do
                     put_in(t, [Access.key(:form, %{}), Access.key("password")], v)
                   else
                     t
                   end
                 end)

    socket = socket
             |> assign(mode: :login)
             |> assign(login: login)
    {:noreply, socket}
  end

  def handle_event("sign-up", _,  socket) do
    # copy sign up details if set
    signup = socket.assigns[:signup]
             |> update_in([:form], &(&1 || %{}))
             |> put_in([:error], nil)
             |> then(
                  fn(t) ->
                    if v = socket.assigns[:login][:form]["email"] do
                      put_in(t, [Access.key(:form, %{}), Access.key("email")], v)
                    else
                      t
                    end
                  end)
             |> then(
                  fn(t) ->
                    if v = socket.assigns[:login][:form]["password"] do
                      put_in(t, [Access.key(:form, %{}), Access.key("password")], v)
                    else
                      t
                    end
                  end)
    socket = socket
             |> assign(mode: :sign_up)
             |> assign(signup: signup)
    {:noreply, socket}
  end


  def handle_event("submit:login", form, socket) do
    socket = case NoizuTeams.User.login(form["email"], form["password"]) do
      {:ok, user} ->
        # Handle successful sign-up
        # Generate JWT token
        with {:ok, jwt_token} <- NoizuTeams.User.indirect_auth(user) do
          socket
          |> push_event("auth", %{jwt: jwt_token, remember_me: form["remember_me"] == "on"})
          |> assign(login: %{error: nil, form: nil})
          |> assign(signup: %{error: nil, form: nil})
        else
          e = {:error, _} ->
            socket
            |> assign(
                 login: %{
                   error: e,
                   form: form
                 })
          e ->
            socket
            |> assign(
                 login: %{
                   error: {:error, e},
                   form: form
                 })
        end

      e = {:error, _error_msg} ->
        # Handle sign-up failure
        socket
        |> assign(
             login: %{
               error: e,
               form: form
             })
    end
    {:noreply, socket}
  end

  def handle_event("submit:sign-up", form, socket) do
    socket = case NoizuTeams.User.sign_up(form, socket.assigns[:project]) do
      {:ok, user} ->
        # Handle successful sign-up
        with {:ok, jwt_token} <- NoizuTeams.User.indirect_auth(user) do
          # Send auth event with JWT token
          socket
          |> push_event("auth", %{jwt: jwt_token, remember_me: form["remember_me"] == "on"})
          |> assign(login: %{error: nil, form: nil})
          |> assign(signup: %{error: nil, form: nil})
        else
          _ ->
            socket
            |> assign(
                 signup: %{
                   error: {:error, :sign_up_error},
                   form: form
                 })
        end
      e = {:error, _error_msg} ->
        socket
        |> assign(
             signup: %{
               error: e,
               form: form
             })
    end
    {:noreply, socket}
  end

  def mount(_, session, socket) do
    socket = socket
             |> assign(project: session["project"])
             |> assign(mode: :login)
             |> assign(signup: %{error: nil, form: nil})
             |> assign(login: %{error: nil, form: nil})
             |> assign(csrf: session["_csrf_token"])


    {:ok, socket}
  end
end

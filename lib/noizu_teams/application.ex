defmodule NoizuTeams.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      NoizuTeamsWeb.Telemetry,
      # Start the Ecto repository
      NoizuTeams.Repo,
      # Start the PubSub system
      Supervisor.child_spec({Phoenix.PubSub, name: NoizuTeams.PubSub}, id: :pubsub_standard),
      Supervisor.child_spec({Phoenix.PubSub, name: NoizuTeams.LiveView.Interop}, id: :pubsub_interop),
      # Start Finch
      {Finch, name: NoizuTeams.Finch},
      {Finch, name: NoizuLabs.OpenAI.Finch},
      # Start Terminal Service
      {NoizuTeams.TerminalClient, url: "ws://127.0.0.1:6500/ws"},
      # Start the Endpoint (http/https)
      NoizuTeamsWeb.Endpoint
      # Start a worker by calling: NoizuTeams.Worker.start_link(arg)
      # {NoizuTeams.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NoizuTeams.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NoizuTeamsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

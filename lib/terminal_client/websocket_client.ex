defmodule NoizuTeams.TerminalClient.WebsocketClient do
  use WebSockex
  require Logger

  def start_link(url) do
    WebSockex.start_link(url, __MODULE__, nil)
  end

  def send_command(client, command) do
    Logger.info("Sending command: #{command}")
    WebSockex.send_frame(client, {:text, command})
  end

  def handle_connect(_conn, state) do
    Logger.info("Connected!")
    {:ok, state}
  end

  def handle_frame({:text, response}, state) do
    Logger.info("Received response: #{response}")
    {:ok, state}
  end

  def handle_disconnect(%{reason: {:local, reason}}, state) do
    Logger.info("Local close with reason: #{inspect reason}")
    {:ok, state}
  end
  def handle_disconnect(disconnect_map, state) do
    super(disconnect_map, state)
  end
end

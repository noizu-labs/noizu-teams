defmodule NoizuTeams.TerminalClient do
  use WebSockex
  require Logger

  def start_link(config) do
    state = %{response: nil}
    name = config[:name] || __MODULE__
    IO.puts "START Terminal Client: #{config[:url]}"
    WebSockex.start_link(config[:url], __MODULE__, state, name: name)
  end

  def send_command(process \\ __MODULE__, command) do
    Logger.info("Sending command: #{command}")
    WebSockex.send_frame(process, {:text, command})
  end

  def flush(process \\ __MODULE__) do
    GenServer.call(process, :flush)
  end

  def handle_info({:"$gen_call", _, :flush}, state) do
    IO.puts "FLUSH? | #{inspect state}"
    response = state.response
    state = %{state| response: nil}
    {:reply, response, state}
  end

  def handle_connect(_conn, state) do
    Logger.info("Connected!")
    {:ok, state}
  end

  def handle_frame(frame = {:text, response}, state) do
    Logger.info("Received response: #{inspect response, limit: :infinity}")
    state = %{state| response: frame}
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

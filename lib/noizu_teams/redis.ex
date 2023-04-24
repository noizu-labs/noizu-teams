defmodule NoizuTeams.Redis do
  @pool_size 50

  #------------------------
  # Pool Supervisor
  #------------------------
  def child_spec(_args) do
    # Specs for the Redix connections.
    v = Application.get_env(:noizu_teams, :redis)
    uri = v[:uri] || v[:host]
    settings = Redix.URI.opts_from_uri(uri)
    children = Enum.map(
      1..@pool_size,
      fn (index) ->
        opts = Keyword.merge(settings, [name: :"redix_#{index}"])
        Supervisor.child_spec({Redix, opts}, id: {Redix, index})
      end
    )
    rebuild_channels()
    # Spec for the supervisor that will supervise the Redix connections.
    %{
      id: RedixSupervisor,
      type: :supervisor,
      start: {Supervisor, :start_link, [children, [strategy: :one_for_one]]}
    }
  end

  #------------------------
  # Naive Pool
  #------------------------
  def rebuild_channels() do
    pool = Enum.map(1..@pool_size, &({&1, :"redix_#{&1}"}))
           |> Map.new()
    FastGlobal.put(:redix_cluster, pool)
    pool
  end
  def random_channel() do
    FastGlobal.get(:redix_cluster)[random_index()] || rebuild_channels()[random_index()]
  end
  defp random_index(), do: :rand.uniform(@pool_size)

  #------------------------
  # Basic Operations
  #------------------------
  def command(command) do
    Redix.command(random_channel(), command)
  end
  def flush(), do: command(["FLUSHALL"])

  def get(command), do: command_helper("GET", command)
  def set(command), do: command_helper("SET", command)
  def delete(key), do: command_helper("DEL", [key])


  def get_json(command) do
    case get(command) do
      {:ok, json} when is_bitstring(json) -> Poison.decode(json, keys: :atoms)
      e -> e
    end
  end
  def set_json([id,object|t] = _command) do
    case Poison.encode(object, [json_format: :redis]) do
      {:ok, json} -> set([id, json|t])
      e -> e
    end
  end

  def get_binary(command) do
    case get(command) do
      {:ok, nil} -> {:ok, nil}
      {:ok, binary} ->
        with term <- :erlang.binary_to_term(binary) do
          {:ok, term}
        end
      e -> e
    end
  end
  def set_binary([id,object|t] = _command) do
    with binary <- :erlang.term_to_binary(object)do
      set([id, binary|t])
    else
      e -> e
    end
  end

  defp command_helper(action, command) do
    case command do
      v when is_list(v) -> command([action] ++ v)
      v when is_bitstring(v) -> command([action, v])
      _ -> nil
    end
  end
end

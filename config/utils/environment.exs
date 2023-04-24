defmodule NoizuTeams.Config.ConfigUtils do
  @prefix %{
    prod: "NT_PROD",
    stage: "NT_STAGE",
    dev: "NT_DEV",
    test: "NT_TEST"
  }

  def prefix(key, use_prefix) when use_prefix in [true, :auto] do
    @prefix[Mix.env()] <> "_" <> key
  end

  def prefix(key, _) do
    key
  end

  def env_as(key, as, env, default \\ nil, required \\ :required, use_prefix \\ :auto) do
    key = prefix(key, use_prefix)
    case System.get_env(key) do
      nil ->
        cond do
          required in [true, :required] ->
            raise("#{env.file}:#{env.line}  Config Error - User must set #{key}=[...] environment variable")
          required == :silent -> :nop
          :else ->
            IO.puts("#{env.file}:#{env.line} Config Error - User should set #{key}=[...] environment variable")
        end
        default
      v ->
        case as do
          :string -> v
          d when d in [:list, :char_list] -> String.to_charlist(v)
          type when type in [:bool, :flag] ->
            cond do
              v in [true, "true", "TRUE", "on", "ON", 1] -> true
              v in [false, "false", "FALSE", "off", "OFF", 0] -> false
            end
          type when type in [:int, :integer] ->
            String.to_integer(v)
        end
    end
  end

  defmacro env_setting(key, options \\ [default: false, required: true, as: :string, prefix: true]) do
    default = options[:default]
    required = cond do
      options[:silent] -> :silent
      options[:required] == false -> :optional
      :else -> :required
    end
    prefix = case options[:prefix] do
      :auto -> :auto
      false -> false
      true -> true
      _ -> :auto
    end
    as = options[:as] || :string
    quote do
      NoizuTeams.Config.ConfigUtils.env_as(unquote(key), unquote(as), __ENV__, unquote(default), unquote(required), unquote(prefix))
    end
  end
end

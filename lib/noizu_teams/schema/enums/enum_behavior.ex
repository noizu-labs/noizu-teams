defmodule NoizuTeams.Enum do
  defmacro __using__(values) do
    quote do
      @values unquote(values)
      @value_strings Enum.map(@values, &(Atom.to_string(&1)))
      use Ecto.Type

      def from_string(value) when is_binary(value) do
        case value do
          v when v in @value_strings -> {:ok, String.to_existing_atom(value)}
          _ -> {:error, "invalid value"}
        end
      end

      def from_atom(value) when is_atom(value) do
        if Enum.member?(@values, value) do
          {:ok, value}
        else
          {:error, :invalid_value}
        end
      end

      def type, do: Ecto.Enum

      def cast(value) when is_bitstring(value) do
        case from_string(value) do
          {:ok, result} -> {:ok, result}
          {:error, _} -> :error
          error ->
            :error
        end
      end

      def cast(value) when is_atom(value) do
        case from_atom(value) do
          {:ok, result} -> {:ok, result}
          {:error, error} ->
            :error
          error ->
            :error
        end
      end

      def load(value) do
        cast(value)
      end

      def dump(value) when is_bitstring(value) do
        #IO.puts "DUMP: #{inspect value}"
        case from_string(value) do
          {:ok, result} -> {:ok, Atom.to_string(result)}
          error ->
            error
        end
      end

      def dump(value) when is_atom(value) do
        case from_atom(value) do
          {:ok, result} -> {:ok, Atom.to_string(result)}
          error ->
            error
        end
      end
    end
  end
end

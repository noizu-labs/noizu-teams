defmodule NoizuTeams.Enum do
  defmacro __using__(values) do
    quote do
      @values unquote(values)
      use Ecto.Type

      IO.puts "HERE 1"
      def from_string(value) when is_binary(value) do
        case value do
          v when v in @values -> {:ok, String.to_existing_atom(value)}
          _ -> {:error, "invalid value"}
        end
      end

      IO.puts "HERE 2"
      def from_atom(value) when is_atom(value) do
        if Enum.member?(@values, value) do
          value
        else
          {:error, "invalid value"}
        end
      end

      IO.puts "HERE 3"
      def type, do: :enum

      IO.puts "HERE 4"
      def cast(value) do
        case from_string(value) |> IO.inspect(label: "fs") do
          {:ok, result} -> {:ok, result}
          {:error, _} -> :error
          error ->
            IO.inspect(error, label: "Error")
            :error
        end
      end

      IO.puts "HERE 5"
      def dump(value) do
        case from_atom(value) do
          :error -> :error
          value -> {:ok, Atom.to_string(value)}
        end
      end
    end
  end
end

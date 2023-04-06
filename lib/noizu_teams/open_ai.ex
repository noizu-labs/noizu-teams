defmodule NoizuLabs.OpenAI do
  @completions_api "https://api.openai.com/v1/chat/completions"
  def chat(messages, options \\ nil) do
    model = options[:model] || "gpt-3.5-turbo"
    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{Application.get_env(:noizu_teams, :openai_api_key)}"}
    ]
    request = %{
                "model": model,
                "messages": messages
              } |> Jason.encode!()
    with {:ok, %Finch.Response{status: 200, body: body}} <-
           Finch.build(:post, @completions_api, headers, request)
           |> Finch.request(NoizuTeams.Finch)
      do
      Jason.decode(body, keys: :atoms)
    else
      _ ->
        {:error, :unknown}
    end
  end

end
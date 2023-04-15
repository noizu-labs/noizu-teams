defmodule NoizuTeamsWeb.Project.TeamSelector do
  use NoizuTeamsWeb, :live_view
  import Phoenix.LiveView.JS
  import NoizuTeamsWeb.Nav.Tags
  require Logger
  require NoizuTeamsWeb.LiveMessage
  alias  Phoenix.PubSub

  defp error_title(error), do: "Team Selector"
  defp error_body(error) do
    "An error has Occurred"
  end

  def render(assigns) do
    ~H"""
    <form id="team-selector-form" class="p-0 m-2 shadow mb-5 flex flex-col md:flex-row justify-center content-center item-center" phx-change="team:change">
    <%= if @error do %>
      <.noizu_alert error-title={error_title(@error)} error-body={error_body(@error)} />
    <% end %>
    <label for="team-selector" class="bg-blue-50 content-center text-center align-center justify-center">Select Team</label>
    <select name="team-selector" id="team-selector"
       :if={@options}
       class="block appearance-none w-full bg-white border border-gray-400 hover:border-gray-500 px-4 py-2 pr-8 rounded shadow leading-tight focus:outline-none focus:shadow-outline">
      <option :for={entry <- @options} value={entry.value} selected={entry.selected}><%= entry.name %></option>
    </select>
    </form>
    """
  end


  def handle_event("team:change", form, socket) do
    [project, team] = String.split(form["team-selector"], ":")



    payload = %{
      project: {:ref,  NoizuTeams.Project, project},
      team: {:ref, NoizuTeams.Team, team}
    }

    NoizuTeamsWeb.LiveMessage.publish(
      NoizuTeamsWeb.LiveMessage.live_pub(subject: :team, instance: :active, event: :change, payload: payload)
    )

    {:noreply, socket}
  end

  def mount(_, session, socket) do
    Logger.error("MOUNT#{__MODULE__} , #{inspect socket}, #{inspect session}}")
    with {:ok, teams} <- NoizuTeams.Project.teams(session["project"], session["user"]) do
      {:ok, project_id} = ERP.id(session["project"])
      {:ok, team_id} = ERP.id(session["team"])
      options = Enum.map(teams, fn(team) ->
        %{value: "#{project_id}:#{team.identifier}", name: team.name, description: team.description,  selected: team.identifier == team_id}
      end)

      socket = socket
               |> assign(error: nil)
               |> assign(options: options)
      {:ok, socket}
      else
      _ ->
        socket = socket
                 |> assign(error: {:error, :fetching_team_list})
                 |> assign(options: nil)
        {:ok, socket}
    end
  end
end
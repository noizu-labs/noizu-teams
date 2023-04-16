defmodule NoizuTeamsWeb.Project.TeamSelector do
  use NoizuTeamsWeb, :live_view
  import NoizuLabs.EntityReference.Helpers
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
    <form
        id="team-selector-form"
        class="
            p-0 m-2 mb-5
            bg-white
            shadow-lg shadow-slate-400/40
            divide-solid divide-slate-300 divide-y divide-x-0
        "
        phx-change="team:change"
    >
    <%= if @error do %>
      <.noizu_alert error-title={error_title(@error)} error-body={error_body(@error)} />
    <% end %>
    <label for="team-selector" class="text-center">
      <h1 class="bg-slate-300" >Select Team</h1>
    </label>
    <select
       name="team-selector"
       id="team-selector"

       :if={@options}
       class="
          w-full bg-slate-100
          border-none
          focus:border-none focus:outline-none focus:ring-0
        ">
      <option :for={entry <- @options} value={entry.value} selected={entry.selected}><%= entry.name %></option>
    </select>
    <div :if={@active_team} class=" text-sm indent-4 max-h-20 hover:delay-1000 hover:max-h-80 overflow-auto justify-start text-gray-500 font-light font-mono p-2 ">
    <%= @active_team.description %>
    </div>
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

    active_team = ERP.entity(payload.team, nil) |> ok?()
    options = Enum.map(socket.assigns[:options], fn(team) ->
      %{team| selected: team.identifier == active_team.identifier}
    end)

    socket = socket
             |> assign(active_team: active_team)
             |> assign(options: options)

    {:noreply, socket}
  end

  def mount(_, session, socket) do
    with {:ok, teams} <- NoizuTeams.Project.teams(session["project"], session["user"]) do
      {:ok, project_id} = ERP.id(session["project"])
      {:ok, team_id} = ERP.id(session["team"])
      options = Enum.map(teams, fn(team) ->
        %{value: "#{project_id}:#{team.identifier}", identifier: team.identifier, project: team.project_id, name: team.name, description: team.description,  selected: team.identifier == team_id}
      end)
      active_team = ERP.entity(session["team"], nil) |> ok?()


      socket = socket
               |> assign(error: nil)
               |> assign(active_team: active_team)
               |> assign(options: options)
      {:ok, socket}
      else
      _ ->
        socket = socket
                 |> assign(error: {:error, :fetching_team_list})
                 |> assign(active_team: nil)
                 |> assign(options: nil)
        {:ok, socket}
    end
  end
end
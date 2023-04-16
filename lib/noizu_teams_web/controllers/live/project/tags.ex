defmodule NoizuTeamsWeb.Project.Tags do
  use NoizuTeamsWeb, :live_component
  alias Phoenix.LiveView.JS
  attr :active, :string, default: nil
  def team_selector(assigns) do
  ~H"""
    <div class="">
    [TEAM SELECTOR]
    </div>
    """
  end

  def expand_prompt(socket) do
    socket
    |> Phoenix.Component.assigns(expand: !socket.assigns[:expand])
    {:ok, socket}
  end

  def agent(assigns) do
    ~H"""
    <div class="
      flex flex-col
      items-left
      p-2 m-2 mb-5
      min-h-20
      bg-slate-100
      shadow-lg shadow-slate-400/40
    ">
      <div class="w-6/6 mb-1 ">
        <span title="AI Agent">🔮 <%= @member.name %></span>


        <span class="block float-right"><a href={"#" <> @member.slug}>💬</a> </span>
      </div>
      <div class="w-6/6 text-sm">
      <%= @member.description %>
      </div>

    <div class="
           w-6/6 text-sm text-light bg-white
           text-gray-500 font-light font-mono p-2
       ">
        <label
            class="rounded-lg bg-gray-300 p-1 text-slate-600"
            phx-click={JS.toggle(to: "#agent-prompt-" <> @member.slug)}
        >Prompt:</label>
      </div>



      <div id={"agent-prompt-" <> @member.slug}
           class="
           agent-prompt
           hidden
           w-6/6 text-sm text-light bg-white
           max-h-fit
           w-fit
           border-[1px] border-solid border-slate-800
           overflow-auto
           text-gray-500 font-light font-mono p-2
       ">
        <pre>
        <%= @member.prompt %>
        </pre>
      </div>


    <div :if={@member.team_prompt}
          class="
           w-6/6 text-sm text-light bg-white
           text-gray-500 font-light font-mono p-2
       ">
        <label
            class="rounded-lg bg-gray-300 p-1 text-slate-600"
            phx-click={JS.toggle(to: "#agent-team-prompt-" <> @member.slug)}
        >Prompt:</label>
      </div>

      <div :if={@member.team_prompt}
            id={"agent-team-prompt-" <> @member.slug}
           class="
           hidden
           w-6/6 text-sm text-light bg-white
           max-h-fit
           w-fit
           border-[1px] border-solid border-slate-800
           overflow-auto
           text-gray-500 font-light font-mono p-2
       ">



      <pre>
      <%= @member.team_prompt %>
      </pre>
      </div>

    <div >
    <div class="flex flex-col text-right">
    <a href={"#edit-" <> @member.slug}>🔏</a>
    </div>
    </div>


    </div>
    """
  end

  def human(assigns) do
    ~H"""
    <div class="
      flex flex-col
      items-left
      p-2 m-2 mb-5
      min-h-20
      bg-slate-100
      divide-solid divide-slate-500 divide-y divide-x-0
      shadow-lg shadow-slate-400/40
    ">
      <div class="w-6/6 mb-1">
        <span title="Carbon">🧬 <%= @member.name %></span>
      <span class="block float-right"><a href={"#" <> @member.slug}>💬</a> </span>
      </div>
      <div class="w-6/6">
        <label class="p-1 text-green-600">team_role</label><%= @member.team_role %>
      </div>
      <div class="w-6/6">
        <label class="p-1 text-green-600">account_role</label><%= @member.role %>
      </div>

      <div class="w-6/6" :if={@member.team_blurb}>
        <label class="p-1 text-green-600">team_blurb</label><%= @member.team_blurb %>
      </div>
      <div class="w-6/6" :if={@member.blurb}>
        <label class="p-1 text-green-600">blurb</label><%= @member.blurb %>
      </div>
    </div>
    """
  end


  attr :team, :map, default: nil
  attr :member, :map, default: nil
  def team_member(assigns) do
    ~H"""
    <%= if @member.__struct__ == NoizuTeams.Project.Agent do %>
      <.agent member={@member} />
    <% else %>
      <.human member={@member} />
    <% end %>
    """
  end

end
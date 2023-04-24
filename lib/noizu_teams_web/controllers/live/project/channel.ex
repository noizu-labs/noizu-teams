defmodule NoizuTeamsWeb.Project.Channel do
  use NoizuTeamsWeb, :live_view
  alias Phoenix.LiveView.JS
  import NoizuLabs.EntityReference.Helpers

  require NoizuTeamsWeb.LiveMessage
  require Logger
  attr :active, :string, default: nil

  def render(assigns) do
    ~H"""
    <form phx-submit="channel:create"

       class="px-8 pt-6 pb-8 mb-4 w-full">
    <div class="mb-4 flex flex-wrap">
      <div class="w-full md:w-1/3">
        <label class="block text-gray-700 font-bold mb-2 md:mb-0 pr-4" for="channel-slug">
          Channel Slug
        </label>
      </div>
      <div class="w-full md:w-2/3">
        <input
          class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
          id="channel-slug"
          name="slug"
          type="text"
          placeholder="Enter channel slug"
        />
      </div>
    </div>
    <div class="mb-4 flex flex-wrap">
      <div class="w-full md:w-1/3">
        <label class="block text-gray-700 font-bold mb-2 md:mb-0 pr-4" for="channel-name">
          Channel Name
        </label>
      </div>
      <div class="w-full md:w-2/3">
        <input
          class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
          id="channel-name"
          name="name"
          type="text"
          placeholder="Enter channel name"
        />
      </div>
    </div>
    <div class="mb-4 flex flex-wrap">
      <div class="w-full md:w-1/3">
        <label class="block text-gray-700 font-bold mb-2 md:mb-0 pr-4" for="channel-description">
          Channel Description
        </label>
      </div>
      <div class="w-full md:w-2/3">
        <textarea
          class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
          id="channel-description"
          name="description"
          placeholder="Enter channel description"
        ></textarea>
      </div>
    </div>
    <div class="flex items-center justify-end">
    <button
        name="submit[cancel]"
        class="bg-gray-500 hover:bg-gray-700 mr-4 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
        type="submit"
      >
        Cancel
      </button>
      <button
        name="submit[create]"
        class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
        type="submit"
      >
        Create Channel
      </button>
    </div>
    </form>
    """
  end

  def handle_event("channel:create", form, socket) do
    Logger.error("CREATE CHANNEL: #{inspect form}")

    if form["submit"]["cancel"] do
      NoizuTeamsWeb.LiveMessage.publish(
        NoizuTeamsWeb.LiveMessage.live_pub(subject: :modal, instance: socket.assigns.identifier, event: :close, payload: %{})
      )
      {:noreply, socket}
    else

      if form["slug"] && form["name"] && form["description"] do
        now = DateTime.utc_now()
        {:ok, channel} = %NoizuTeams.Project.Channel{
                           project_id: socket.assigns.project.identifier,
                           slug: form["slug"],
                           private: false,
                           name: form["name"],
                           description: form["description"],
                           created_on: now,
                           modified_on: now
                         } |> NoizuTeams.Repo.insert()

        member = NoizuTeams.Project.member(socket.assigns.project, socket.assigns.user) |> ok?()

        %NoizuTeams.Project.Channel.Member{
          channel_id: channel.identifier,
          project_member_id: member.identifier,
          joined_on: now
        } |> NoizuTeams.Repo.insert()

        %NoizuTeams.User.Project.Channel{
          project_id: socket.assigns.project.identifier,
          channel_id: channel.identifier,
          user_id: socket.assigns.user.identifier,
          starred: false,
          joined_on: now
        } |> NoizuTeams.Repo.insert()

        NoizuTeamsWeb.LiveMessage.publish(
          NoizuTeamsWeb.LiveMessage.live_pub(subject: :modal, instance: socket.assigns.identifier, event: :close, payload: %{})
        )

      end

      {:noreply, socket}
    end

  end

  def mount(_m, session, socket) do
    socket = socket
             |> assign(project: session["project"])
             |> assign(user: session["user"])
             |> assign(identifier: session["identifier"])
    {:ok, socket}
  end


end
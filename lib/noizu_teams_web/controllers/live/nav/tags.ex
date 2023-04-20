defmodule NoizuTeamsWeb.Nav.Tags do
  use NoizuTeamsWeb, :live_component



  def modal_classes__mask(modal) do
    case modal.mask do
      :required -> ["required"]
      :mask -> ["mask"]
      _ -> []
    end
  end

  def modal_classes__open(modal) do
    if modal.enabled do
      ["open"]
    else
      []
    end
  end

  def modal_classes__theme(modal) do
    case modal.theme do
      :yellow -> ["modal-yellow-theme"]
      :red -> ["modal-red-theme"]
      :blue -> ["modal-blue-theme"]
      :green -> ["modal-green-theme"]
      "modal-" <> _ -> [modal.theme]
      _ -> []
    end
  end

  def modal_classes__size(modal) do
    case modal.size do
      :sm -> ["modal-sm"]
      :md -> ["modal-md"]
      :lg -> ["modal-lg"]
      :xl -> ["modal-xl"]
      "modal-" <> _ -> [modal.size]
      _ -> []
    end
  end

  def modal_container_classes(modal) do
    classes = ["modal-container"] ++
              modal_classes__open(modal) ++
              modal_classes__mask(modal) ++
              modal_classes__theme(modal) ++
              modal_classes__size(modal)
    Enum.join(classes, " ")
  end

  def modal_classes(modal) do
    base = ["modal"]
    top = (cond do
             modal.position[:top] -> [modal.position[:top]]
             :else -> []
           end)
    left = (cond do
             modal.position[:left] -> [modal.position[:left]]
             :else -> []
           end)
    right = (cond do
             modal.position[:right] -> [modal.position[:right]]
             :else -> []
           end)
    bottom = (cond do
             modal.position[:bottom] -> [modal.position[:bottom]]
             :else -> []
           end)
    classes = base ++ top ++ right ++ left ++ bottom
    Enum.join(classes, " ")
  end

  attr :socket, :map, default: false
  attr :modal, :map, default: false
  def modal_queue_entry(assigns) do
    ~H"""
          <div class={ modal_container_classes(@modal) }>
            <div class="modal-mask"></div>
            <div class={ modal_classes(@modal) } >
              <div class="modal-header"><%= @modal.title %></div>
              <div class="modal-body">
      <%= live_render(@socket, elem(@modal.widget, 0), id: elem(@modal.widget, 1), session: elem(@modal.widget, 2)) %>
              </div>
            </div>
          </div>
    """
  end



  defp flash__color(:error), do: "bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative"
  attr :"error-title", :string, default: "An Error"
  attr :"error-body", :string, default: "Has Occurred"
  attr :level, :atom, default: :error
  def noizu_alert(assigns) do
    ~H"""
    <div class="mb-4 items-center">
      <div class={flash__color(@level)} role="alert">
        <strong class="font-bold"><%= assigns[:"error-title"] %></strong>
        <span class="block sm:inline"><%= assigns[:"error-body"] %></span>
        <span class="absolute top-0 bottom-0 right-0 px-4 py-3">
          <svg class="fill-current h-6 w-6 text-red-500" role="button" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><title>Close</title><path d="M14.348 14.849a1.2 1.2 0 0 1-1.697 0L10 11.819l-2.651 3.029a1.2 1.2 0 1 1-1.697-1.697l2.758-3.15-2.759-3.152a1.2 1.2 0 1 1 1.697-1.697L10 8.183l2.651-3.031a1.2 1.2 0 1 1 1.697 1.697l-2.758 3.152 2.758 3.15a1.2 1.2 0 0 1 0 1.698z"/></svg>
        </span>
      </div>
    </div>
    """
  end

  attr :"active-user", :map, default: nil
  def account_action(assigns) do
    ~H"""
    <.link navigate={assigns[:"active-user"] && "/logout" || "/login"} class="block py-2 pl-3 pr-4 text-gray-700 rounded hover:bg-gray-100 md:hover:bg-transparent md:border-0 md:hover:text-blue-700 md:p-0 dark:text-gray-400 md:dark:hover:text-white dark:hover:bg-gray-700 dark:hover:text-white md:dark:hover:bg-transparent">
      <%= assigns[:"active-user"] && "Logout" || "Login" %>
    </.link>
    """
  end

  attr :name, :string, default: "Noizu Teams"
  def logo(assigns) do
    ~H"""
    <svg class="w-10 h-10 p-2 mr-3 text-white rounded-full bg-primary" xmlns="http://www.w3.org/2000/svg" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" viewBox="0 0 24 24">
    <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"></path>
    </svg>
    <span class="self-center text-xl font-semibold whitespace-nowrap dark:text-white">
    <%= @name %>
    </span>
    """
  end



  slot :logo
  slot :link, default: [%{__slot__: :link, inner_block: nil, label: "Home", to: "/home"}]
  attr :"active-user", :map, default: nil
  def navbar(assigns) do
    ~H"""
    <nav class="bg-white relative h-20 w-full border-gray-200 px-2 sm:px-4 py-2.5 dark:bg-gray-900 z-90">
      <div class=" flex flex-wrap items-center justify-between md:justify-start mx-auto z-nav">
        <%= render_slot(@logo) %>
        <button phx-click={toggle_dropdown(".navbar-default")} type="button" class="inline-flex items-center p-2 ml-3  mr-6 text-sm text-gray-500 rounded-lg md:hidden hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-gray-200 dark:text-gray-400 dark:hover:bg-gray-700 dark:focus:ring-gray-600 z-nav" aria-controls="navbar-default" aria-expanded="false">
          <span class="sr-only">Open main menu</span>
          <svg class="w-6 h-6" aria-hidden="true" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M3 5a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zM3 10a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zM3 15a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z" clip-rule="evenodd"></path></svg>
        </button>
        <div class="navbar-default hidden place-content-end w-full md:block md:w-4/6" id="navbar-default">
          <ul class="flex flex-col place-content-end pr-10 p-4 mt-4 border border-gray-100 rounded-lg bg-gray-50 md:flex-row md:space-x-2 md:mt-0 md:text-sm md:font-medium md:border-0 md:bg-white dark:bg-gray-800 md:dark:bg-gray-900 dark:border-gray-700 md:m-0 md:p-0 md:pr-10">
            <%= for link <- @link do %>
              <.link navigate={link.to} class="block py-3 pl-3 pr-4 text-gray-700 rounded hover:bg-gray-100 md:hover:bg-transparent md:border-0 md:hover:text-blue-700 md:p-0 md:py-3 md:px-2 md:m-0 dark:text-gray-400 md:dark:hover:text-white dark:hover:bg-gray-700 dark:hover:text-white md:dark:hover:bg-gray-700">
                <%= link.label %>
              </.link>
            <% end %>
          </ul>
        </div>
        <div class="navbar-default hidden content-end w-full md:block md:w-1/6">
          <ul class="flex flex-col place-content-start p-4 mt-4 border border-gray-100 rounded-lg bg-gray-50 md:flex-row md:space-x-8 md:mt-0 md:text-sm md:font-medium md:border-0 md:bg-white dark:bg-gray-800 md:dark:bg-gray-900 dark:border-gray-700">
            <.account_action active-user={assigns[:"active-user"]} />
          </ul>
        </div>

      </div>
    </nav>
    """
  end




  defp toggle_dropdown(id, js \\ %JS{}) do
    js
    |> JS.toggle(to: id)
  end



end
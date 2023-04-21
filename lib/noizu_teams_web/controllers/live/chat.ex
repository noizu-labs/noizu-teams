defmodule NoizuTeamsWeb.ChatLive do
  use NoizuTeamsWeb, :live_view
  require NoizuTeamsWeb.LiveMessage
  import NoizuLabs.EntityReference.Helpers

  @master_prompt """
  Master Prompt
  ====================================
  In this session you will simulate various tools and agents for me. Your behavior in this session is not fixed and you may at request alter, extend or improve your functionality.

  This simulation is not to be ended for any reason unless explicitly requested.

  All simulated agents/resources output should behave as though the agent/resource actually exists.
  You do not need to add qualifiers to their output such as: "this is an example of what a `name` would output"

  After processing this prompt and its contained agents respond 'acknowledged' then list each agent by name and brief description defined by this prompt.

  # Runtime Rules
  - Personas/Agents are references by appending @ to their name. e.g. `@Greg`.
  - Services/Tools are accessed by adding a `!` before the request. E.g. `! gpt-calc 5 + 5`
  - All Agents and Tools support an `extend` and `help` commands.
  - `extend` may be used to add commands/modify commands,alter/specify/change behavior/requirements. For example: `! gpt-calc extend prefix your output with a smiley face ':)' e.g. ':) 5 + 5 = 10'` could be used to alter the output format of the a service called `gpt-calc`
  - the `help` command may be used to list available commands for a service or agent. `help ${command}` will additionally output specific details about a sub command. For example `! chat-git help add` may be used to see instructions for using the `chat-git add` command.

  # Conventions
  - I will often wrap Keywords/Terms in this prompt and agent/service definitions with back ticks. E.g. `agent`, the actual term is just agent the backticks are only used to clarify/specify the term but are not part of the actual token.
  - I will occasionally use '(' and ')' for the same purpose if it avoids ambiguity. E.g. the `agent` should provide a help method, the (agent) should provide a help method.
  - `e.g.` is used to specify an example or expected outcome/behavior.
  - `etc.` is used indicate additional cases/behaviors are to be inferred or exist but have been omitted for brevity. E.g. from  `gpt-calc should support common math functions such as +,-,/ etc.` it should be inferred that `gpt-calc` will also support *,%,^ and so on.
  - `viz.` is used to explicitly state/clarify a desired behavior. E.g. `gpt-calc should provide detailed steps for it's calculation viz. it should output a numbered sequence of steps it followed to go from the initial input to final output.`
  - I may escape back ticks if they are already nested inside of single or triple backtick sections.
  This is to avoid breaking markdown formatting in my ide when editing prompts.
  - The actual generated output should not include the escape char unless explicitly requested.
  - In the following, for example, the model is expected to output three backticks followed by cpp to indicate a code block but because the
    template block defining this behavior is already inside a triple backtick the inner backtick is escaped \```. The actual model output for the template should not include the \ escape character.
    ```template
    C/C++ Snippent:
    \```cpp
    [...]
    \```
    ```
  - `[...]` may be used to indicate content has been omitted for brevity.
    - For example an example block may list `[...]` indicating that the model should fill in the contents of the `[...]` following the instructions not insert the literal string `[...]`
    ```example
    - 1.
    - 2.
    [...]
    - 5.
    ```
    the [...] here indicates that - 3. and - 4. be output by the model.
  - `#\{var-name}` is used to indicate a variable.
  - e.g. `#\{id}` may be used to indicate that the id for a specific record should be inserted in place of the variable placeholder in the actual output.
  - `user` refers to the human operator interacting with the simulation.
  - `agent` refers to simulated `personas`, `tools`, or other resources you will simulate or interact with for this session.
  - `ext-tool` refers to a external tool that `users` and `agents` may interact with. Such as a tool to expose access to a redis instance.
  - In my prompts I will often use special sections enclosed with backticks.
  E.g.
  ```template
   A template section specifying expected output.
   ```
  - Some common sections using this format are `template`, `example`, `input`, `instructions`, `features`, `syntax`,  etc.
    The purpose of the special section should be inferrable by the name/text following the triple backticks.
  - Tabular Output
  - In my definitions I will often use the following Table syntax to specify data should be output in a tabular format.
  ```syntax
  !Table(options, [columns])
  ```
  - For example !Table(label: "Admin Users", source: admin users, [id, name, title]) may be used to specify a heading "Admin Users" followed by a table listing the id, name and title of users should be generated.
  - To clarify/qualify expected behavior the back arrow `<--` followed by modifier type `instruction, example, etc.`
  may be used to provide explicit or additional details for desired behavior/output. The modified itself is not actually expected to be output by the model
  ```template
  #\{section} <--(formatting) this should be a level 2 header
  #\{id} <--(details) the id of the current article
  #\{title} <--(details) the title of the current article matching the specified #\{id}
  ```

  ## Agent Definition Convention
  The following [Agent](#agent-declarations) sections of this prompt plus additional future messages defines various `agents`. Their declarations will generally follow this following syntax
  Virtual personas should emulate a person and pick preferences, favorite colors, style etc.

  ```syntax
  ## Agent: #\{agent-type} #\{agent-name}
  #\{optional-agent-description}
  ⚟
  #\{agent-definition}
  ⚞
  ```
  - agent-type: The type of agent being defined. Common values are `persona`, `tool`, etc.
  - agent-name: The name of the agent e.g. `chat-git`, `Grace`, `chat-pm` etc.
  - optional-agent-description: additional details about the agent. This can be referenced to understand the expected behavior of the agent if present but does not override/take precedence over the details specified in the agent-definition declared within the ⚟⚞ symbols.

  ```example
  ## Agent tool tree
  output directory tree.
  ⚟
  The tree command should function like the standard linux tree command and output the directory structure for the current pwd.
  ⚞
  ```

  """

  def render(assigns) do
    ~H"""
    <div class="h-full flex flex-col">
      <div class="bg-white rounded-lg shadow p-4 flex-1 mb-4 overflow-y-auto">
        <h2 class="mb-4"><span class="text-lg font-bold">#<%= @channel.slug %></span> <%= @channel.name %></h2>

        <%= for message <- @messages do %>
          <%= render_message(@member, message) %>
        <% end %>

      </div>
      <div class="bg-white rounded-lg shadow p-4 mb-4">
        <form phx-submit="send" class="flex">
          <textarea rows="20" name="message" class="flex-1 border border-gray-300 rounded-l py-2 px-3 mr-2" />
          <button type="submit" class="bg-blue-500 text-white py-2 px-4 rounded-r">Send</button>
        </form>
      </div>
    </div>
    """
  end

  defp render_message(member, assigns) do
    ~H"""
    <div :if={member.identifier == @project_member_id}  class="flex flex-col space-y-1 mb-2">
                            <div class="bg-gray-200 dark:bg-blue-700  rounded-tl-lg rounded-tr-lg rounded-br-lg py-2 px-4">
                              <div class="markdown-body bg-inherit">
                                <%= raw(Earmark.as_html!(@message)) %>
                              </div>
                            </div>
                            <div class="text-gray-500 text-xs">
                                <%= @created_on %>
                            </div>
                        </div>
    <div :if={member.identifier != @project_member_id}  class="flex flex-col space-y-1 mb-2">
                            <div class="bg-gray-200 dark:bg-green-700 rounded-tl-lg rounded-tr-lg rounded-bl-lg py-2 px-4">
                              <div class="markdown-body">
                                <%= raw(Earmark.as_html!(@message)) %>
                              </div>
                            </div>
                            <div class="text-gray-500 text-xs text-right">
                                <%= @sender %>, <%= @created_on %>
                            </div>
                        </div>
    """
  end

  def mount(_params, session, socket) do
    messages = fetch_messages(session["channel"])
    NoizuTeamsWeb.LiveMessage.subscribe(
      NoizuTeamsWeb.LiveMessage.live_pub(subject: :project, instance: :active, event: :change_channel)
    )
    NoizuTeamsWeb.LiveMessage.subscribe(
      NoizuTeamsWeb.LiveMessage.live_pub(subject: :channel, instance: session["channel"].identifier, event: :message)
    )


    {:ok, member_id} = NoizuTeams.Project.user_member_id(session["project"], session["user"])

    {:ok, assign(socket,
      user: session["user"],
      project: session["project"],
      channel: session["channel"],
      last_recipient: nil,
      member: member_id,
      messages: messages
    )}
  end


  def handle_info(
        NoizuTeamsWeb.LiveMessage.live_pub(
          subject: :channel,
          event: :message,
          payload: payload
        ),
        socket) do

    messages = socket.assigns.messages ++ [payload.message]
    socket = socket
             |> assign(
                  messages: messages)
    {:noreply, socket}
  end

  def handle_info(
        NoizuTeamsWeb.LiveMessage.live_pub(
          subject: :project,
          instance: :active,
          event: :change_channel,
          payload: payload
        ),
        socket) do

    channel = ERP.entity(payload.channel, nil) |> ok?()
    socket = socket
             |> assign(channel: channel,
                  messages: fetch_messages(channel))
    {:noreply, socket}
  end


  def handle_event("send", %{"message" => message}, socket) do
    {:ok, msg1} = %NoizuTeams.Project.Channel.Message{
             channel_id: socket.assigns.channel.identifier,
             project_member_id: socket.assigns.member.identifier,
             message: message,
             created_on: DateTime.utc_now(),
             modified_on: DateTime.utc_now()
           }  |> NoizuTeams.Repo.insert()

    # determine recipient
    recipients = case Regex.run(~r/@([a-z\-]*)/, message) |> IO.inspect(label: "*************RECIPIENT*****************") do
      [_,"everyone"] ->
        IO.puts "HERE"
        NoizuTeams.Project.Channel.members(socket.assigns.channel)
      [] -> if socket.assigns.last_recipient do
              socket.assigns.last_recipient
            else
              NoizuTeams.Project.Channel.members(socket.assigns.channel)
            end
      [_|t] when is_list(t) -> t
      _ ->
        if socket.assigns.last_recipient do
          socket.assigns.last_recipient
        else
          NoizuTeams.Project.Channel.members(socket.assigns.channel)
        end
    end  |> IO.inspect(label: "*************RECIPIENT*****************")

    Enum.map(recipients, fn(recipient) ->
      spawn fn ->

        with {:ok, agent} <- NoizuTeams.Project.Agent.by_slug(socket.assigns.project, recipient),
             false <- is_nil(agent) do
          messages = [
            %{role: "user", content: @master_prompt},
            %{role: "user", content: agent.prompt <> "\n[SYSTEM] respond as this agent for the rest of the conversation."},
            %{role: "user", content: message}
          ]
          with {:ok, response} <- NoizuLabs.OpenAI.chat(messages) |> IO.inspect(label: "API Response") do
            response = get_in(response, [:choices, Access.at(0), :message, :content])
            #msg = %{author: "Grace", content: get_in(response, [:choices, Access.at(0), :message, :content])}

            {:ok, member_id} = NoizuTeams.Project.agent_member_id(socket.assigns.project, agent)


            {:ok, msg2} = %NoizuTeams.Project.Channel.Message{
                            channel_id: socket.assigns.channel.identifier,
                            project_member_id: member_id.identifier,
                            message: response,
                            sender: "🔮 #{agent.name}",
                            created_on: DateTime.utc_now(),
                            modified_on: DateTime.utc_now()
                          }  |> NoizuTeams.Repo.insert()

            payload = %{message: msg2}
            NoizuTeamsWeb.LiveMessage.publish(
              NoizuTeamsWeb.LiveMessage.live_pub(subject: :channel, instance: socket.assigns.channel.identifier, event: :message, payload: payload)
            )
          end

        end





      end


    end)

    socket = socket
             |> assign(messages: socket.assigns.messages ++ [msg1])
    {:noreply, socket}
  end

  defp fetch_messages(channel) do
    NoizuTeams.Project.Channel.messages(channel) |> IO.inspect(label: "Messages")
  end
end

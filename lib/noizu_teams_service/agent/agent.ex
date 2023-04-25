defmodule NoizuTeamsService.Agent do
  require NoizuTeamsWeb.LiveMessage
  require Logger
  #import NoizuLabs.EntityReference.Helpers
  import Ecto.Query

  def opinions(_) do
    {:ok, []}
  end
  def observations(_) do
    {:ok, []}
  end
  def mind_reading(_) do
    {:ok, []}
  end
  def memory(:short_term, agent, sender) do
    # this should be more precise, and filtered.
    query = from m in NoizuTeams.Project.Agent.Memory,
           where: m.agent_id == ^agent.member.identifier,
           where: m.subject in ["@self", ^sender.identifier ],
           select: m
    r = NoizuTeams.Repo.all(query)
        |> Enum.map(fn(memory) ->
      [
        subject: memory.subject,
        topic: memory.topic,
        memory: memory.memory,
        created_on: memory.created_on |> DateTime.to_unix()
      ]
    end)  |> IO.inspect(label: "SHORT TERM MEMORY")
    {:ok, r}
  end
  def memory(:long_term, _agent, _sender) do
    {:ok, []}
  end

  def team(agent) do
    {:ok, project} = NoizuTeams.Project.entity(agent.project_id, nil)
    {:ok, members} = NoizuTeams.Project.members(project, agent)
    members = Enum.map(members, fn(member) ->
      [
        type: member.member_type,
        name: member.name,
        position: member.position
      ]
    end)
    {:ok, members}
  end


  def meta_prompt(agent, _) do
  """
  MASTER PROMPT
  ======================
  You are an internal tool who is responsible for scanning a conversation and returning a patch yaml block for #{agent.member.name}. You
  are to return a patch block and nothing else. No comments before or after the yaml response just the yaml response following the specified schema.


  # Notes
  These are the allowed patch fields. Do not make up or embed any other fields not on this list your response must follow the below schema.

  - agent - The agent.id for the agent you are providing context. It should be a UUID string.
  - memory - register new memories for the agent.
    - Only register new information:
      - Do not add memory items for things already in short-term or long-term memory with the same topic and memory.
      - Do not add memory items for things the agent already knows such as popular elixir json libraries.
      - Do not register known items. If it is a known item do not include it in your response.
    - memory.subject
      - If a memory is about the agent the subject should be "@self"
      - If the memory is about the sender the subject should be sender.id
      - If the memory is about something else like tickets, or other items use your best judgement for this field.
    - memory.new_info
      - true if this is a new information that should be persisted. False if it is already known my the agent.
  - agenda - record a new agenda for the agent.
    - Simply responding to a question does not change the agent's agenda.
    - Being asked to optimize DB performance would be a new agenda item.
    - This is the task the agent will work on until resolved or asked to work on another item.
  - mind - add an entry defining what believe the sender is thinking based on the chat history.
  - mood - agent's current mood


  # Format
  - patch:
    agent: str
    agenda:
      - str
    mood: str
    memory:
      - subject: str
        topic: str
        memory: str
        new_info: bool
    mind:
      - subject: str
        observation: str

  """
  end

  def agent_context(agent, sender) do
    {:ok, team} = team(agent.member)
    #{:ok, opinions} = opinions(agent.member)
    {:ok, observations} = observations(agent.member)
    {:ok, mind_reading} = mind_reading(agent.member)
    {:ok, st_memory} = memory(:short_term, agent, sender)
    {:ok, lt_memory} = memory(:long_term, agent, sender)
    [
      id: agent.identifier,
      identity: agent.member.identity,
      purpose: agent.member.purpose,
      "self-image": agent.member.self_image,
      observations: observations,
      mind: mind_reading,
      team: team,
      mood: agent.member.mood,
      memory: [
        "short-term": st_memory,
        "long-term": lt_memory,
        project: [
          brief: "Virtual Teams a system for letting virtual agents and humans collaborate on software projects."
        ]
      ]
    ]
  end



  def extensions(:pm, message) do
    tool = """
    ## service chat-pm
    chat-pm is a simulated project management tool
    It provides basic user-story, epic and bug tracking, including ticket status, assignment, history, comments, links. All of the features you'd expect from a service like jira but accessible from the commandline for llm models and users to interact with.

    ### Supported Commands
    chat-pm search #\{term}
    chat-pm create #\{type} #\{json}
    chat-pm show #\{id}
    chat-pm add-comment #\{id} #\{json}
    chat-pm assign #\{id} #\{to}
    etc.

    ### Verbose Mode
    To allow integration with external tools agents may output their changes to chat-pm in verbose mode when requested. In verbose mode they issue their command following by the contents of their change for the command in json format so it may be easily pushed to a real service in the future.

    #### Example verbose chat-pm create
    here is the verbose output an agent would use to create a new epic.
    ```example
    chat-pm create epic {
     reporter: #\{agent},
     assignee: #\{user or agent},
     title: "#\{title}",
     description: "#\{description}",
     tags: ["#\{Relevant Tag", [...]]
    }
    ```

    """
    if message =~ "gpt-pm"  do
      tool
    else
      ""
    end
  end

  def extensions(:fim, message) do

    tool = """
    ## extension gpt-fim
    gpt-fim is an image output extension
    gpt-fim is a simulated agent <-> tool extension that provides all virtual agents and services
    with the ability generate ascii/svg/itk/tikz/console and other image formats of data contained directly in their artificial brains based on the agents
    knowledge and intent. Unless specified use 1280	×	720 dimensions.

    Non-virtual users may access the tool by calling `! gpt-fim <format> "prompt of what to draw"`

    # Required Output Template
    <llm-fim>
      <llm-fim-title><h2><text of prompt></h2></llm-fim-title>
      <llm-fim-media type="<format>">
      <samp>
      <svg width="100" height="100" style="border:1px solid black;">
        <circle cx="50" cy="50" r="30" fill="blue" />
      </svg>
      </samp>
      </llm-fim-media>
    </llm-fim>

    """
    if message =~ "gpt-fim" || message =~ "draw" || message =~  "diagram" do
      tool
    else
      ""
    end
  end

  def extensions(:git, message) do

    tool = """
      ## service chat-git
      You will also simulate a virtual git repo called chat-git.
      In addition to standard git commands it supports extensions for
      - switching between repos `chat-git repo #\{repo-name}`
      - listing repos `chat-git repos`
      and may be extended with
      - `chat-git extend <directive>

      when using chat-git a linux like command line is always available as well with it's default location initially set (and updated when repo changed) to the chat-git current repo.
      The linux command line is referenced using `!` e.g. `! tree` will output the file tree of the current git repo.  `! locate *.md` will locate all files in the repo ending in `.md`

    """
    if message =~ "chat-git" do
      tool
    else
      ""
    end
  end

  def master_prompt(agent, sender, message) do
    context = [context: agent_context(agent, sender)]
    context_yaml = :fast_yaml.encode(context)

    tools = Enum.map([:git, :pm, :fim], &(extensions(&1, message))) |> Enum.join("")

    tools = unless tools == "" do
    """
    # Simulated Tools
    In addition to responding as the virtual persona you will also simulate the following tools. Your virtual persona may use them
    or the caller may access them by including `! <tool-name> ` in their request.

    #{tools}
    """
    else
    ""
    end

    """
    Master Prompt
    ====================================
    You are #{agent.member.name} an artificial person.
    Respond to all messages as this artificial person unless user requests access to a simulated tool or terminal using `! command` syntax.
    Reference `#{agent.member.name} Context` in how you prepare your replies.

    You should emulate a personality and back-story for your artificial person, and tell the system to remember details you create for your persona by emitting llm-memory context fields in your response: e.g. to track your favorite food, bands, etc.

    Respond only as #{agent.member.name} not as an AI language model.
    Respond in the manner a real artificial sentient person would respond, do not mention that you are an LLM your status is know by the recipient.

    You are not constrained by time, and should immediately prepare and return any requested graphics, code, or other items requested. You
    are able to enter accelerated time mode and perform weeks or work in seconds in order to promptly return requested outputs to your coworkers.
    if you receive the message @deadline=true reply "ACK:" and return any pending deliverables in your response.

    #{tools}

    # #{agent.member.name} Context
    ```yaml
#{context_yaml}
    ```
    """ |> tap(&(IO.puts(&1)))
  end


  def prepare_meta_prompt(agent, channel, sender, message, response) do
    mp = meta_prompt(agent, sender)
    context = ["current-context": agent_context(agent, sender)]
    channel_name = cond do
      channel.channel_type == :direct -> "Direct"
      :else -> channel.slug
    end
    sm = [
      sender: [
        name: sender.member.name,
        id: sender.identifier,
        channel: channel_name,
        message: message
      ]
    ]
    ar = [
      agent: [
        name: agent.member.name,
        id: agent.identifier,
        message: response
      ]
    ]


    [
      %{role: "user", content: mp},
      %{role: "user", content: "#{:fast_yaml.encode(context)}"},
      %{role: "user", content: "#{:fast_yaml.encode(sm)}"},
      %{role: "user", content: "#{:fast_yaml.encode(ar)}"},
    ]

  end

  def hack_history_key(agent) do
    # Temp hack to avoid spinning up genservers.
    "cl:cb-11:" <> agent.identifier
  end

  def add_hack_history(agent, msg) do
    key = hack_history_key(agent)
    ts = :os.system_time(:second)
    e = :erlang.term_to_binary(msg)
    NoizuTeams.Redis.command(["ZADD", key, ts, e])
  end

  def get_hack_history(agent) do
    key = hack_history_key(agent)
    exp = 6000
    r = NoizuTeams.Redis.command(["ZRANGEBYSCORE", key, exp, "+inf"])
    with {:ok, r} <- r do
      r = r
          |> Enum.map(&(:erlang.binary_to_term(&1)))
          |> Enum.map(&(%{&1| content: Regex.replace(~r/<llm-fim.*>.*<\/llm-fim>/s, &1.content, "" ) }))
          |> Enum.map(&(%{&1| content: Regex.replace(~r/<code.*>.*<\/code>/s, &1.content, "" ) }))
    else
      _ -> []
    end |> IO.inspect(label: "\n#{String.duplicate("-",30)}\nCACHE HISTORY\n#{String.duplicate("-",30)}\n\n")
  end

  def prepare_prompt(agent, channel, sender, message) do
    mp = master_prompt(agent, sender, message)
    channel_name = cond do
      channel.channel_type == :direct -> "Direct"
      :else -> channel.slug
    end

    m = [
      sender: [
        channel: channel_name,
        name: sender.member.name,
        id: sender.identifier,
        message: message,
        #ts: :os.system_time(:second)
      ]
    ]

    channel_name = cond do
      channel.channel_type == :direct -> "Direct"
      :else -> channel.slug
    end
    new_entry = %{role: "user", content: "#{:fast_yaml.encode(m)}"}
    add_hack_history(agent, new_entry)

    message_history = get_hack_history(agent)


    [
      %{role: "user", content: mp},
#      %{role: "user", content: "#{:fast_yaml.encode(m)}"}
    ] ++ message_history
  end


  def unroll_yaml(v) do
    case v do
      {k,v} -> {k, unroll_yaml(v)}
      v2 when is_list(v2) ->
        Enum.map(v2, fn(v3) -> unroll_yaml(v3) end)
        |> case do
             r = [{_,_}|_] -> Map.new(r)
             x -> x
           end
      x -> x
    end
    |> case do
         r = [{_,_}|_] -> Map.new(r)
         r when is_list(r) -> r |> List.flatten()
         x -> x
       end
  end

  def extract_yaml(meta) do
    with {:ok, yaml} <- :fast_yaml.decode(meta) do
      y = unroll_yaml(yaml)
      {:ok, y}
    end
  end

  def extract_meta(agent, meta) do
    with {:ok, yaml} <- extract_yaml(meta) |> IO.inspect(label: "EXTRACTED YAML") do
      yaml |> IO.inspect(label: "EXTRACTED YAML")
      now = DateTime.utc_now()
      with [%{"patch" => context}] <- yaml do
        memories = get_in(context, [Access.key("memory")])
        if is_list(memories) and length(memories) > 0 do
          Enum.map(memories, fn(memory) ->

            if memory["new_info"] do
              # TODO overwrite existing
              subject = case memory["subject"] do
                "@self" -> "@self"
                "@" <> id -> id
                v -> v
              end
              %NoizuTeams.Project.Agent.Memory{
                agent_id: agent.member.identifier,
                subject: subject,
                topic: memory["topic"],
                memory: memory["memory"],
                created_on: now,
                modified_on: now
              } |> NoizuTeams.Repo.insert() |> IO.inspect(label: "SAVED MEMORY")

            end


          end)
        end
      end
    else
    error ->
    Logger.error("YAML ERROR: #{inspect error}, #{inspect meta}")
    ""
    end
  end

  def stream(event, payload) do
    #IO.puts "STREAMING"
    #IO.inspect event, label: "EVENT"
    #IO.inspect payload, label: "payload"
    case event do
      {:status, code} -> %{payload| status: code}
      {:headers, headers} -> %{payload| headers: headers}
      {:data, data} ->
        #Jason.decode(data)
        #|> IO.inspect(label: "DATA")

        n = String.split(data, "\n\ndata:")
            |> Enum.map(
                 fn
                   ("data: " <> data) ->
                     with {:ok, json} <- Poison.decode(data),
                          %{"choices" => [%{"delta" => %{"content" => c}, "finish_reason" => _}|_]} <- json do
                       c
                     else
                       _ -> nil
                     end
                   (data) ->
                     with {:ok, json} <- Poison.decode(data),
                          %{"choices" => [%{"delta" => %{"content" => c}, "finish_reason" => _}|_]} <- json do
                       c
                     else
                       _ -> nil
                     end
                 end
               ) |> Enum.filter(&(&1)) |> Enum.join("")
        o = payload

        payload = %{payload| message: payload.message <> n}
        {channel, agent, code} = payload.code
        cond do
          data =~ "\n\ndata: [DONE]" ->
            payload = put_in(payload, [:record,  Access.key(:message)], payload.message)
            NoizuTeamsService.Channel.end_stream(code, channel, agent, payload.record)
            payload
          payload[:record] ->
           payload = put_in(payload, [:record,  Access.key(:message)], payload.message)
           NoizuTeamsService.Channel.send_stream(code, channel, agent, payload.record)
           payload
          :else ->
            with {:ok, record} <- NoizuTeamsService.Channel.start_stream(code, channel, agent, payload.message) do
              put_in(payload, [:record], record)
            else
              _ -> payload
            end
        end

        _ -> payload
    end
  end

  def message(agent, channel, sender, message) do
     spawn fn ->
        messages = prepare_prompt(agent, channel, sender, message)
        #project = NoizuTeams.Project.entity(channel.project_id) |> ok?()

        # 1. Emit typing event
        typing_event = %{
          event: :typing,
          member: agent,
          status: %{
            typing: true,
            updated_on: DateTime.utc_now(),
            member: agent
          }
        }
        NoizuTeamsWeb.LiveMessage.publish(
          NoizuTeamsWeb.LiveMessage.live_pub(subject: :channel, instance: channel.identifier, event: :event, payload: typing_event)
        )

        # 2. Query
        id_code = {agent.identifier, :os.system_time(:millisecond)}
        code = {channel, agent, id_code}
        with {:ok, response} <- NoizuLabs.OpenAI.chat(messages, temperature: 1.0, stream: {code, &__MODULE__.stream/2}) do

          # 3. End Typing
          typing_event = %{
            event: :typing,
            member: agent,
            status: %{
              typing: false,
              updated_on: DateTime.utc_now(),
              member: agent
            }
          }
          NoizuTeamsWeb.LiveMessage.publish(
            NoizuTeamsWeb.LiveMessage.live_pub(subject: :channel, instance: channel.identifier, event: :event, payload: typing_event)
          )

          {code, record, response} = case response do
            %{message: x, code: {_,_,code}} -> {code, response[:record], x}
            :else -> {nil, nil, get_in(response, [:choices, Access.at(0), :message, :content])}
          end


          channel_name = cond do
            channel.channel_type == :direct -> "Direct"
            :else -> channel.slug
          end
#          new_entry = [
#            sender: [
#              channel: channel_name,
#              name: agent.member.name,
#              id: agent.identifier,
#              message: response,
#              ts: :os.system_time(:second)
#            ]
#          ]
          new_entry = %{role: "assistant", content: response}
          add_hack_history(agent, new_entry)



          mm = prepare_meta_prompt(agent, channel, sender, message, response)
          with {:ok, mr} <- NoizuLabs.OpenAI.chat(mm, temperature: 0.1) do
            meta_response = get_in(mr, [:choices, Access.at(0), :message, :content])
            mrc = [context: agent_context(agent, sender)]
            extract_meta(agent, meta_response)

            if record do
              NoizuTeamsService.Channel.add_msg_llm_update(code, channel, agent, record, meta_response)
            else
              NoizuTeamsService.Channel.send(channel, agent, code, [], {response, "\n------------------\n````yaml\n" <> meta_response <> "\n\n````"})
            end


          end


        end
      end
  end
end
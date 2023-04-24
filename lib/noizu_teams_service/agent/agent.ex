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
  You are an internal tool who is responsible for scanning a conversation and updating #{agent.member.name}'s context based on it's content.

  # Output
  Based on the conversation return a yaml block with the following optional items. Only include entries with content, if there is no change to llm-mood for example don't include the llm-mood key in your response.

  - agent - The agent.id for the agent you are providing context. It should be a UUID string.
  - llm-memory - register a memory entry for an agent about itself, a sender or something else.
    - Only register new memories. Do not register known items.
    - Subject
      - If a memory is about the agent the subject should be "@self".
      - If the memory is about the sender the subject should be "${sender.id}".
      - If the memory is about something else like tickets, or other items use your best judgement for this field.
  - llm-agenda - record a new objective-agenda. Simply responding to a question does not change the agent's agenda. An agenda is something an agent works on over multiple requests.
  - llm-mind-reading - add an entry defining what believe the sender is thinking based on the chat history.
  - llm-mood - agent's current mood

  # Schema
  Use the following schema
  ```yaml-schema
  context:
    type: sequence
    sequence:
      - type: map
        mapping:
          agent:
            type: string
          llm-agenda:
            type: sequence
            sequence: [{type: string}]
          llm-mood:
            type: string
          llm-memory:
            type: sequence
            sequence:
              - type: map
                mapping:
                  subject: {type: string}
                  topic: {type: string}
                  memory: {type: string}
          llm-mind-reading:
            type: sequence
            sequence:
              - type: map
                mapping:
                  subject: {type: string}
                  observation: {type: string}

    ```
    ## Format
    return the context yaml block and only the context yaml block.
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
      "mind-reading": mind_reading,
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

  def master_prompt(agent, sender) do
    context = [context: agent_context(agent, sender)]
    context_yaml = :fast_yaml.encode(context)
    IO.puts agent.member.self_image
    """
    Master Prompt
    ====================================
    You are #{agent.member.name}
    Respond to all messages as this simulated persona.
    Reference `#{agent.member.name} Context` in how you reply.

    You should emulate a personality and back-story for your virtual persona, and tell the system to remember details you create for your persona by emitting llm-memory context fields in your response: e.g. to track your favorite food, bands, etc.

    Respond only as #{agent.member.name} not as an AI language model. Respond in the manner a real person would respond, do not mention that you are an LLM your status is know by the recipient.

    # #{agent.member.name} Context
    ```yaml
#{context_yaml}
    ```
    """
  end


  def prepare_meta_prompt(agent, channel, sender, message, response) do
    mp = meta_prompt(agent, sender)
    context = [context: agent_context(agent, sender)]
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
      %{role: "system", content: "#{:fast_yaml.encode(context)}"},
      %{role: "user", content: "#{:fast_yaml.encode(sm)}"},
      %{role: "assistant", content: "#{:fast_yaml.encode(ar)}"},
    ]

  end

  def prepare_prompt(agent, channel, sender, message) do
    mp = master_prompt(agent, sender)
    channel_name = cond do
      channel.channel_type == :direct -> "Direct"
      :else -> channel.slug
    end

    m = [
      sender: [
        channel: channel_name,
        name: sender.member.name,
        id: sender.identifier,
        message: message
      ]
    ]

    [
      %{role: "user", content: mp},
      %{role: "user", content: "#{:fast_yaml.encode(m)}"}
    ]
  end


  def unroll_yaml(v) do
    case v do
      v when is_list(v) ->
        Enum.map(v,
          fn(v2) ->
            case v2 do
              v2 when is_list(v2) ->
                Enum.map(v2,
                  fn
                    ({k, v3}) -> {k, unroll_yaml(v3)}
                    (v3) -> v3
                  end)
                |>
                  case do
                    r = [{_,_}|_] -> Map.new(r)
                    r -> r
                  end
              other -> other
            end
          end)
       v2 -> v2
    end
  end

  def extract_yaml(meta) do
    with {:ok, yaml} <- :fast_yaml.decode(meta) do
      unroll_yaml(yaml)
    end
  end

  def extract_meta(agent, meta) do
    with {:ok, yaml} <- :fast_yaml.decode(meta) do
      # Convert to map
      # [
      #  [
      #    {"context",
      #      [
      #       [{"agent", [{"id", "a4183803-bc55-4fcf-a3a7-baa8cacd3f55"}]}, {"llm-memory", [[{"subject", "e2cf1eb5-3e6e-41dc-905d-f0b79cffa1ab"}, {"topic", "favorite band"}, {"memory", "weezer"}]]}]
      #      ]
      #     }
      #  ]
      # ]
      response = unroll_yaml(yaml)
      response |> IO.inspect(label: "EXTRACTED YAML")
      now = DateTime.utc_now()
      with [%{"context" => [context]}] <- response do
        memories = get_in(context, [Access.key("llm-memory")])
        if is_list(memories) and length(memories) > 0 do
          Enum.map(memories, fn(memory) ->
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
          end)
        end

      end
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
        with {:ok, response} <- NoizuLabs.OpenAI.chat(messages, temperature: 1.0) do
          response = get_in(response, [:choices, Access.at(0), :message, :content])

          mm = prepare_meta_prompt(agent, channel, sender, message, response)
          with {:ok, mr} <- NoizuLabs.OpenAI.chat(mm, temperature: 0.1) do
            meta_response = get_in(mr, [:choices, Access.at(0), :message, :content])

            Logger.info("AGENT RESPONSE:\n #{response}")
            Logger.info("META RESPONSE:\n #{meta_response}")
            extract_meta(agent, meta_response)
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
            NoizuTeamsService.Channel.send(channel, agent, [], response <> "\n------------------\n````yaml\n" <> meta_response <> "\n\n````")

          end


        end
      end
  end
end
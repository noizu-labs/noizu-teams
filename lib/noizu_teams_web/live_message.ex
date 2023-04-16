defmodule NoizuTeamsWeb.LiveMessage do
  require Record
  require Logger
  alias Phoenix.PubSub

  Record.defrecord(:live_pub, [subject: nil, instance: nil, event: nil, payload: nil])

  def subscribe(live_pub(
    subject: s_subject,
    instance: s_instance,
    event: s_event,
  ) ) do
    key = [s_subject, s_instance, s_event]
          |> Enum.map(&("#{&1 || "*"}"))
          |> Enum.join(":")
    Logger.warn("PUBSUB Subscribe: #{key}")
    PubSub.subscribe(NoizuTeams.LiveView.Interop, key)
  end

  def publish(live_pub(
    subject: s_subject,
    instance: s_instance,
    event: s_event,
    payload: payload
  ) = msg) do

    # This is super inefficient, better routing will be needed in the future.
    keys = [
      "#{s_subject}:*:*",
      "#{s_subject}:#{s_instance}:*",
      "#{s_subject}:#{s_instance}:#{s_event}",
      "#{s_subject}:*:#{s_event}",
    ]
    Logger.info("PUB-SUB-EMIT: #{inspect keys} -> #{inspect msg}")
    Enum.map(keys, fn(key) ->
      PubSub.broadcast(
        NoizuTeams.LiveView.Interop,
        key,
        msg
      )
    end)
  end





end
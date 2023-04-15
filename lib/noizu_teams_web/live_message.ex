defmodule NoizuTeamsWeb.LiveMessage do
  require Record
  alias Phoenix.PubSub

  Record.defrecord(:live_pub, [subject: nil, instance: nil, event: nil, payload: nil])

  def subscribe(live_pub(
    subject: s_subject,
    instance: s_instance,
    event: s_event,
  ) ) do
    key = "#{s_subject}:#{s_instance || "*"}:#{s_event || "*"}"
    PubSub.subscribe(NoizuTeams.LiveView.Interop, key)
  end

  def publish(live_pub(
    subject: s_subject,
    instance: s_instance,
    event: s_event,
    payload: payload
  ) = msg) do
    PubSub.broadcast(
      NoizuTeams.LiveView.Interop,
      "#{s_subject}:#{s_instance}:#{s_event}",
      msg
    )
  end





end
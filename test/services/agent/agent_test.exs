defmodule NoizuTeamsService.AgentTest do
  use ExUnit.Case, async: true
  @moduletag component: :agents
  test "Parse Meta" do
    meta = """
    context:
      - agent: "3920eb59-2161-4b64-a251-4574fb681fd7"
      - llm-memory:
        - subject: "@dc7a6794-2dc4-4fa2-8cb7-4e9ecdb8bc82"
          topic: "favorite band"
          memory: "unknown"
    """
    sut = NoizuTeamsService.Agent.extract_yaml(meta)
    IO.inspect sut
  end

end

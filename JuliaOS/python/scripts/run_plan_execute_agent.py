import juliaos

HOST = "http://127.0.0.1:8052/api/v1"

AGENT_BLUEPRINT = juliaos.AgentBlueprint(
    tools=[
        juliaos.ToolBlueprint(
            name="ping",
            config={}
        ),
        juliaos.ToolBlueprint(
            name="llm_chat",
            config={}
        )
    ],
    strategy=juliaos.StrategyBlueprint(
        name="plan_execute",
        config={}
    ),
    trigger=juliaos.TriggerConfig(
        type="webhook",
        params={}
    )
)

AGENT_ID = "plan-execute-agent"
AGENT_NAME = "Plan and Execute Agent"
AGENT_DESCRIPTION = "Agent with reasoning capabilities"

with juliaos.JuliaOSConnection(HOST) as conn:
    print_agents = lambda: print("Agents:", conn.list_agents())
    
    def print_logs(agent, msg):
        print(msg)
        for log in agent.get_logs()["logs"]:
            print("   ", log)

    try:
        existing_agent = juliaos.Agent.load(conn, AGENT_ID)
        print(f"Agent '{AGENT_ID}' already exists, deleting it.")
        existing_agent.delete()
    except Exception as e:
        print(f"No existing agent '{AGENT_ID}' found. Proceeding to create.")

    print_agents()
    agent = juliaos.Agent.create(conn, AGENT_BLUEPRINT, AGENT_ID, AGENT_NAME, AGENT_DESCRIPTION)
    print_agents()
    agent.set_state(juliaos.AgentState.RUNNING)
    print_agents()

    print_agents()
    print_logs(agent, "Agent logs before execution:")
    task = "First check if the system is responsive, then ask the language model what the capital of France is."
    agent.call_webhook({"text": task})
    print_logs(agent, "Agent logs after successful execution:")
    agent.delete()
    print_agents()
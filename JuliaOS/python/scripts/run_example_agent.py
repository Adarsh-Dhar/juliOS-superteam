import juliaos

HOST = "http://127.0.0.1:8052/api/v1"

AGENT_BLUEPRINT = juliaos.AgentBlueprint(
    tools=[
        juliaos.ToolBlueprint(
            name="adder",
            config={
                "add_value": 2
            }
        )
    ],
    strategy=juliaos.StrategyBlueprint(
        name="adder",
        config={
            "times_to_add": 10
        }
    ),
    trigger=juliaos.TriggerConfig(
        type="webhook",
        params={}
    )
)

AGENT_ID = "test-agent"
AGENT_NAME = "Example Agent"
AGENT_DESCRIPTION = "Adds the number multiple times"

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

    # try to load the same agent again and confirm that both instances correspond to the same agent:
    agent2 = juliaos.Agent.load(conn, AGENT_ID)
    print_agents()
    print_logs(agent2, "Agent logs before execution:")
    agent.call_webhook({})
    print_logs(agent2, "Agent logs after failed execution:")
    agent2.call_webhook({ "value": 3 })
    print_logs(agent2, "Agent logs after successful execution:")
    agent2.delete()
    print_agents()
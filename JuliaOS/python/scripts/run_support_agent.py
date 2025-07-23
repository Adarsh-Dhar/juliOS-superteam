import os

from dotenv import load_dotenv

import juliaos


load_dotenv()
telegram_token = os.getenv("TELEGRAM_BOT_TOKEN")
HOST = "http://127.0.0.1:8052/api/v1"

AGENT_BLUEPRINT = juliaos.AgentBlueprint(
    tools=[
        juliaos.ToolBlueprint(
            name="llm_chat",
            config={}
        ),
        juliaos.ToolBlueprint(
            name="send_message",
            config={
                "api_token": telegram_token
            }
        )
    ],
    strategy=juliaos.StrategyBlueprint(
        name="support",
        config={
            "name": "support-agent",
            "api_token": telegram_token
        }
    ),
    trigger=juliaos.TriggerConfig(
        type="webhook",
        params={}
    )
)

AGENT_ID = "support-agent"
AGENT_NAME = "Telegram Support Agent"
AGENT_DESCRIPTION = "Responds to user messages"

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

    print_logs(agent, "Agent logs before execution:")
    sample_payload_clean = {
        "message": {
            "from": {"id": 340743403},
            "chat": {"id": 340743403},
            "text": "Hello! How are you?"
        }
    }
    agent.call_webhook(sample_payload_clean)
    print_logs(agent, "Agent logs after execution:")
    agent.delete()
    print_agents()
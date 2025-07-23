import json
from a2a.types import AgentCard, AgentSkill, AgentCapabilities
from juliaos import Agent

def make_agent_card(agent: Agent, port: int) -> AgentCard:
    agent_id = agent.id
    name = agent.name
    description = agent.description

    return AgentCard(
        name=name,
        version="1.0",
        description=description,
        url=f"http://127.0.0.1:{port}/{agent_id}/a2a",
        capabilities=AgentCapabilities(streaming=False),
        skills=[
            AgentSkill(
                id=agent_id,
                name=name,
                description=description,
                examples=[json.dumps(agent.input_schema)] if agent.input_schema else [],
                tags=[]
            )
        ],
        defaultInputModes=["application/json"],
        defaultOutputModes=["text/plain"],
    )

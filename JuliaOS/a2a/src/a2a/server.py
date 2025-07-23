import uvicorn
from starlette.applications import Starlette
from starlette.routing import Mount

from a2a.server.apps import A2AStarletteApplication
from a2a.server.request_handlers import DefaultRequestHandler
from a2a.server.tasks import InMemoryTaskStore

from agents.card import make_agent_card
from agents.executors import GenericExecutor

import juliaos

PORT = 9100

conn = juliaos.JuliaOSConnection("http://127.0.0.1:8052/api/v1")
agents = conn.list_agents()

routes = []
for agent in agents:
    if agent.state != juliaos.AgentState.RUNNING:
        continue

    agent_id = agent.id
    handler = DefaultRequestHandler(
        agent_executor=GenericExecutor(agent.id),
        task_store=InMemoryTaskStore()
    )
    a2a_subapp = A2AStarletteApplication(
        agent_card=make_agent_card(agent, port=PORT),
        http_handler=handler
    ).build(rpc_url=f"/a2a")

    routes.append(Mount(f"/{agent_id}", app=a2a_subapp))

multi_agent_app = Starlette(routes=routes)


if __name__ == "__main__":
    uvicorn.run(multi_agent_app, host="127.0.0.1", port=PORT)

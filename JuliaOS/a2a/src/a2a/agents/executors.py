from __future__ import annotations

import json
from typing_extensions import override

from a2a.types import DataPart
from a2a.server.agent_execution import AgentExecutor, RequestContext
from a2a.server.events import EventQueue
from a2a.utils import new_agent_text_message
import juliaos

conn = juliaos.JuliaOSConnection("http://127.0.0.1:8052/api/v1")

class GenericExecutor(AgentExecutor):
    """
    Executes ANY Julia-OS agent that expects a JSON payload.
    """

    def __init__(self, _id: str) -> None:
        self.id = _id

    @override
    async def execute(
        self,
        context: RequestContext,
        event_queue: EventQueue,
    ) -> None:
        raw = context.get_user_input().strip()
        payload = json.loads(raw)

        jl_agent = juliaos.Agent.load(conn, self.id)
        jl_agent.call_webhook(payload)

        result = jl_agent.get_logs()["logs"][-1]
        await event_queue.enqueue_event(new_agent_text_message(result))

    @override
    async def cancel(
        self,
        context: RequestContext,
        event_queue: EventQueue,
    ) -> None:
        raise Exception("cancel not supported")

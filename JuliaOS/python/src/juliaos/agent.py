from typing import Self

from _juliaos_client_api import CreateAgentRequest, AgentBlueprint, DefaultApi, AgentSummary
from _juliaos_client_api.exceptions import BadRequestException
from juliaos.juliaos_connection import JuliaOSConnection
from juliaos.enums import AgentState

class Agent:
    @classmethod
    def create(cls, conn: JuliaOSConnection, blueprint: AgentBlueprint, _id: str, name: str, description: str) -> Self | None:
        api_response = conn.api.create_agent(CreateAgentRequest(
            id=_id,
            name=name,
            description=description,
            blueprint=blueprint
        ))
        if api_response is None:
            return None
        return cls(conn, api_response.id)
        pass

    @classmethod
    def load(cls, conn: JuliaOSConnection, _id: str) -> Self | None:
        if conn.get_agent_summary(_id):
            return cls(conn, _id)
        else:
            return None

    def __init__(self, conn: JuliaOSConnection, _id: str):
        self.conn = conn
        self.id = _id

    def get_summary(self):
        return self.conn.get_agent_summary(self.id)

    def set_state(self, state: AgentState):
        update_request = {"state": state.value}
        api_response = self.conn.api.update_agent(self.id, update_request)
        if api_response is None:
            raise ValueError("Failed to update agent state, no response received.")
        return api_response

    def delete(self):
        self.conn.api.delete_agent(self.id)

    def get_logs(self):
        logs = self.conn.api.get_agent_logs(self.id)
        if logs is None:
            raise ValueError("Failed to retrieve agent logs, no response received.")
        return logs

    def call_webhook(self, params=None):
        try:
            response = self.conn.api.process_agent_webhook(self.id, params)
            return response
        except BadRequestException as e:
            print("Webhook call failed with 400 Bad Request.")
            print("Details:", e.body)
            return None
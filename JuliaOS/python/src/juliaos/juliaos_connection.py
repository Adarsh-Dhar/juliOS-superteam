from _juliaos_client_api import ApiClient, Configuration, DefaultApi, AgentSummary

class JuliaOSConnection:
    def __init__(self, host: str):
        self.client = ApiClient(Configuration(host=host))
        self.api = DefaultApi(self.client)

    def __enter__(self):
        return self

    def __exit__(self, type, value, traceback):
        self.close()

    def close(self):
        if not self.closed:
            self.client.close()
            self.client = None

    @property
    def closed(self) -> bool:
        return self.client is None

    def get_agent_summary(self, agent_id: str) -> AgentSummary | None:
        """
        Get a summary of the agent with the given ID.
        """
        try:
            return self.api.get_agent(agent_id)
        except Exception as e:
            print(f"Error retrieving agent summary: {e}")
            return None

    def list_tools(self):
        """
        List all tools available in the JuliaOS instance.
        """
        return self.api.list_tools()

    def list_agents(self):
        """
        List all agents available in the JuliaOS instance.
        """
        return self.api.list_agents()

    def list_strategies(self):
        """
        List all strategies available in the JuliaOS instance.
        """
        return self.api.list_strategies()
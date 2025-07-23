from enum import StrEnum

class AgentState(StrEnum):
    CREATED = "CREATED",
    RUNNING = "RUNNING",
    PAUSED = "PAUSED",
    STOPPED = "STOPPED",
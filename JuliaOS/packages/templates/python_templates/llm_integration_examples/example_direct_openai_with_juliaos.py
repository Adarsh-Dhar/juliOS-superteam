# packages/templates/python_templates/llm_integration_examples/example_direct_openai_with_juliaos.py

import asyncio
import os
from typing import Dict, Any, List

# Ensure you have the 'openai' package installed: pip install openai
# Also, ensure your OPENAI_API_KEY environment variable is set.
try:
    from openai import AsyncOpenAI
except ImportError:
    print("OpenAI Python package not found. Please install it with 'pip install openai'")
    AsyncOpenAI = None # type: ignore

# Assuming juliaos_wrapper is installed and accessible in the Python path
# For local development, you might need to adjust PYTHONPATH or install the wrapper in editable mode.
try:
    from juliaos_wrapper.client import JuliaOSClient, JuliaOSAPIError, AgentsClient # Assuming direct import for example
except ImportError:
    print("JuliaOSClient not found. Ensure 'juliaos_wrapper' is installed and in your PYTHONPATH.")
    # Define mock classes if JuliaOSClient is not available, to allow the script to be partially runnable for structure review
    class MockJuliaOSAPIError(Exception): pass
    JuliaOSAPIError = MockJuliaOSAPIError # type: ignore

    class MockAgentsClient:
        async def list(self, agent_type: str = None, status: str = None) -> List[Dict[str, Any]]:
            print("[MOCK] MockAgentsClient.list() called")
            return [
                {"agent_id": "agent_001", "name": "Mock Data Collector", "type": "DATA_AGENT", "status": "RUNNING"},
                {"agent_id": "agent_002", "name": "Mock Trading Bot", "type": "TRADING_AGENT", "status": "IDLE"},
            ]
        async def get(self, agent_id: str) -> Dict[str, Any]:
            print(f"[MOCK] MockAgentsClient.get({agent_id}) called")
            if agent_id == "agent_001":
                return {"agent_id": "agent_001", "name": "Mock Data Collector", "type": "DATA_AGENT", "status": "RUNNING", "details": "Fetching market data..."}
            return {"agent_id": agent_id, "name": "Unknown Mock Agent", "status": "UNKNOWN"}

    class MockJuliaOSClient:
        def __init__(self, base_url: str, timeout: float = 30.0):
            print(f"[MOCK] MockJuliaOSClient initialized with base_url: {base_url}")
            self.agents = MockAgentsClient()
        async def get_status(self) -> Dict[str, Any]:
            print("[MOCK] MockJuliaOSClient.get_status() called")
            return {"status": "OK (Mocked)", "version": "0.0.0-mock"}
        async def __aenter__(self): return self
        async def __aexit__(self, exc_type, exc_val, exc_tb): pass
        async def close(self): print("[MOCK] MockJuliaOSClient.close() called")
    
    JuliaOSClient = MockJuliaOSClient # type: ignore


async def get_juliaos_data(julia_client: JuliaOSClient) -> Dict[str, Any]:
    """
    Fetches some example data from JuliaOS.
    In a real scenario, this could be market data, agent statuses, portfolio details, etc.
    """
    print("\nFetching data from JuliaOS...")
    try:
        # Example: Get a list of running agents
        running_agents = await julia_client.agents.list(status="RUNNING")
        if not running_agents:
            # Fallback if no running agents, get any agent for demo
            all_agents = await julia_client.agents.list()
            if all_agents:
                running_agents = [all_agents[0]] # Just take the first one
            else:
                return {"error": "No agents found in JuliaOS."}

        # For simplicity, let's focus on the first running agent's details
        first_agent_summary = {
            "id": running_agents[0].get("agent_id"),
            "name": running_agents[0].get("name"),
            "type": running_agents[0].get("type"),
            "status": running_agents[0].get("status"),
        }
        return {"agent_summary": first_agent_summary}

    except JuliaOSAPIError as e:
        print(f"Error fetching data from JuliaOS: {e}")
        return {"error": str(e)}
    except Exception as e:
        print(f"An unexpected error occurred while fetching JuliaOS data: {e}")
        return {"error": "Unexpected error fetching JuliaOS data."}


async def get_llm_insights(openai_client: "AsyncOpenAI", context_data: Dict[str, Any]) -> str:
    """
    Uses OpenAI to generate insights based on data from JuliaOS.
    """
    if not AsyncOpenAI or not openai_client:
        return "OpenAI client not available. Skipping LLM insights."
    if "error" in context_data:
        return f"Cannot generate insights due to previous error: {context_data['error']}"

    print("\nGenerating insights using OpenAI...")
    
    agent_summary = context_data.get("agent_summary", {})
    prompt_context = (
        f"I have a system called JuliaOS with several autonomous agents. "
        f"Here's a summary of one of the agents:\n"
        f"- ID: {agent_summary.get('id', 'N/A')}\n"
        f"- Name: {agent_summary.get('name', 'N/A')}\n"
        f"- Type: {agent_summary.get('type', 'N/A')}\n"
        f"- Status: {agent_summary.get('status', 'N/A')}\n\n"
        f"Based on this agent's status and type, suggest one potential action "
        f"I might want to take or one piece of information I might want to check next regarding this agent. "
        f"Be concise (1-2 sentences)."
    )

    try:
        completion = await openai_client.chat.completions.create(
            model="gpt-4o-mini", # Or your preferred model
            messages=[
                {"role": "system", "content": "You are a helpful assistant providing suggestions for managing autonomous agents."},
                {"role": "user", "content": prompt_context}
            ],
            temperature=0.7,
            max_tokens=100
        )
        insight = completion.choices[0].message.content
        return insight.strip() if insight else "No insight generated."
    except Exception as e:
        print(f"Error calling OpenAI API: {e}")
        return "Failed to generate insights due to OpenAI API error."


async def main_example():
    """
    Main function to demonstrate fetching data from JuliaOS and using OpenAI for insights.
    """
    # --- Configuration ---
    # JuliaOS Client Configuration
    JULIAOS_BASE_URL = os.getenv("JULIAOS_BASE_URL", "http://localhost:8080/api/v1")
    
    # OpenAI API Key - ensure OPENAI_API_KEY environment variable is set
    # The OpenAI SDK will automatically pick it up.
    if not os.getenv("OPENAI_API_KEY"):
        print("Error: OPENAI_API_KEY environment variable not set. Cannot run OpenAI example.")
        return

    openai_client = None
    if AsyncOpenAI:
        try:
            openai_client = AsyncOpenAI()
        except Exception as e:
            print(f"Failed to initialize OpenAI client: {e}")
            return
    else:
        print("OpenAI SDK not available.")
        return

    # --- Execution ---
    async with JuliaOSClient(base_url=JULIAOS_BASE_URL) as julia_client:
        # 1. Fetch data from JuliaOS
        juliaos_data = await get_juliaos_data(julia_client)
        print(f"Data from JuliaOS: {juliaos_data}")

        # 2. Get insights from LLM based on JuliaOS data
        if openai_client:
            insights = await get_llm_insights(openai_client, juliaos_data)
            print(f"\nLLM Insight: {insights}")
        else:
            print("\nSkipping LLM insights as OpenAI client could not be initialized.")

if __name__ == "__main__":
    print("Running Direct OpenAI with JuliaOSClient Example...")
    print("This example demonstrates fetching data from JuliaOS (mocked if wrapper not found)")
    print("and then using the OpenAI API directly for further processing.")
    print("Ensure JULIAOS_BASE_URL and OPENAI_API_KEY environment variables are set if using real services.\n")
    
    asyncio.run(main_example())

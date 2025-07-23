import os

from dotenv import load_dotenv

import juliaos


load_dotenv()
HOST = "http://127.0.0.1:8052/api/v1"

AGENT_BLUEPRINT = juliaos.AgentBlueprint(
    tools=[
        juliaos.ToolBlueprint(
            name="scrape_article_text",
            config={}
        ),
        juliaos.ToolBlueprint(
            name="summarize_for_post",
            config={}
        ),
        juliaos.ToolBlueprint(
            name="post_to_x",
            config={
                "api_key": os.getenv("X_API_KEY"),
                "api_key_secret": os.getenv("X_API_KEY_SECRET"),
                "access_token": os.getenv("X_ACCESS_TOKEN"),
                "access_token_secret": os.getenv("X_ACCESS_TOKEN_SECRET")
            }
        )
    ],
    strategy=juliaos.StrategyBlueprint(
        name="ai_news_scraping",
        config={
            "news_portal_url": "https://techcrunch.com/category/artificial-intelligence/",
            "css_selector": "a[href]",
            "url_pattern": "/\\d{4}/\\d{2}/\\d{2}/"
        }
    ),
    trigger=juliaos.TriggerConfig(
        type="webhook",
        params={}
    )
)

AGENT_ID = "ai-news-agent"
AGENT_NAME = "AI News Agent"
AGENT_DESCRIPTION = "Scrapes news article and posts a tweet based on it"

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
    agent.call_webhook()
    print_logs(agent, "Agent logs after execution:")
    agent.delete()
    print_agents()
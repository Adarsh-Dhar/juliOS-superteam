# backend-julia/src/api/Routes.jl
module Routes # Filename Routes.jl implies module Routes

using Oxygen
using HTTP
using JSON3
using StructTypes
using Dates  # Add Dates module for timestamp functionality
# These are sibling modules within the 'api' directory
using ..AgentHandlers
# using ..MetricsHandlers
# using ..LlmHandlers # Use LlmHandlers as per screenshot and updated file
# using ..SwarmHandlers # Added SwarmHandlers
# using ..PriceFeedHandlers # Added PriceFeedHandlers
# using ..DexHandlers # Added DexHandlers
# using ..BlockchainHandlers # Added BlockchainHandlers
# using ..TradingHandlers # Added TradingHandlers

# Note: The @route_with_params macro is not standard Oxygen.jl syntax.
# Oxygen typically infers path parameters from the function signature.
# I will use Oxygen's standard way of defining routes with path parameters.

# Define request and response structures
struct TestRequest
    name::String
    age::Int
    email::Union{String, Nothing}
end

struct TestResponse
    message::String
    received_data::TestRequest
    timestamp::String
end

# Add struct type definitions to support JSON serialization
StructTypes.StructType(::Type{TestRequest}) = StructTypes.Struct()
StructTypes.StructType(::Type{TestResponse}) = StructTypes.Struct()

function register_routes()
    BASE_PATH = "/api/v1"

    # Create test router group
    test_router = router(BASE_PATH * "/test", tags=["Test"])
    
    # Test routes
    @get test_router("/hello") function(req)
        return Dict("message" => "Hello, World!")
    end

    @post test_router("/params/{id}/{name}") function(req, id, name)
        return Dict("message" => "Received ID: $id, Name: $name")
    end

    @get test_router("/query") function(req, name::String="Guest", age::Int=18)
        return Dict("message" => "Hello, $name You are $age years old.")
    end

    @post test_router("/post") function(req)
        # Deserialize JSON from request body to TestRequest struct
        request_data = JSON3.read(req.body, TestRequest)
        
        # Create response object
        response = TestResponse(
            "Hello, $(request_data.name)!",
            request_data,
            string(Dates.now())
        )
        
        # Automatically serialize to JSON and return
        return response
    end

    # Create agent router group
    agent_router = router(BASE_PATH * "/agents", tags=["Agent Management"])

    # --- Agent CRUD (Create, Read, Update, Delete) & Clone ---
    @post agent_router("") AgentHandlers.create_agent_handler                           # Create a new agent
    @get agent_router("") AgentHandlers.list_agents_handler                            # List all agents (with optional filters)
    @get agent_router("/{agent_id}") AgentHandlers.get_agent_status_handler     # Get status and details of a specific agent
    @put agent_router("/{agent_id}") AgentHandlers.update_agent_handler         # Update configuration of an existing agent
    @delete agent_router("/{agent_id}") AgentHandlers.delete_agent_handler       # Delete an agent
    @post agent_router("/{agent_id}/clone") AgentHandlers.clone_agent_handler    # Clone an existing agent
    @post agent_router("/bulk-delete") AgentHandlers.bulk_delete_agents_handler      # Delete multiple agents

    # --- Agent Lifecycle Control ---
    @post agent_router("/{agent_id}/start") AgentHandlers.start_agent_handler    # Start an agent's execution loop
    @post agent_router("/{agent_id}/stop") AgentHandlers.stop_agent_handler     # Stop an agent's execution loop
    @post agent_router("/{agent_id}/pause") AgentHandlers.pause_agent_handler    # Pause a running agent
    @post agent_router("/{agent_id}/resume") AgentHandlers.resume_agent_handler   # Resume a paused agent

    # --- Agent Task Management ---
    @post agent_router("/{agent_id}/tasks") AgentHandlers.execute_agent_task_handler # Submit a new task to an agent
    @get agent_router("/{agent_id}/tasks") AgentHandlers.list_agent_tasks_handler    # List tasks for an agent
    @get agent_router("/{agent_id}/tasks/{task_id}") AgentHandlers.get_task_status_handler # Get status of a specific task
    @get agent_router("/{agent_id}/tasks/{task_id}/result") AgentHandlers.get_task_result_handler # Get result of a completed/failed task
    @post agent_router("/{agent_id}/tasks/{task_id}/cancel") AgentHandlers.cancel_task_handler # Attempt to cancel a task
    @post agent_router("/{agent_id}/evaluate_fitness") AgentHandlers.evaluate_agent_fitness_handler # Request agent to evaluate fitness for a given solution

    # --- Agent Memory Access ---
    @get agent_router("/{agent_id}/memory/{key}") AgentHandlers.get_agent_memory_handler # Get a value from agent's memory
    @post agent_router("/{agent_id}/memory/{key}") AgentHandlers.set_agent_memory_handler # Set a value in agent's memory
    @delete agent_router("/{agent_id}/memory") AgentHandlers.clear_agent_memory_handler   # Clear all memory for an agent

    # # ----------------------------------------------------------------------
    # # Metrics Routes
    # # These routes provide access to system and agent-specific metrics.
    # # ----------------------------------------------------------------------
    # @get BASE_PATH * "/metrics" MetricsHandlers.get_all_metrics_handler                # Get all system-wide metrics
    # @delete BASE_PATH * "/metrics" MetricsHandlers.reset_all_metrics_handler            # Reset all system-wide metrics
    # @get BASE_PATH * "/metrics/agent/{agent_id::String}" MetricsHandlers.get_agent_metrics_handler # Get metrics for a specific agent
    # @delete BASE_PATH * "/metrics/agent/{agent_id::String}" MetricsHandlers.reset_agent_metrics_handler # Reset metrics for a specific agent

    # # ----------------------------------------------------------------------
    # # LLM (Large Language Model) Routes
    # # These routes are for interacting with LLM functionalities.
    # # ----------------------------------------------------------------------
    # @get BASE_PATH * "/llm/providers" LlmHandlers.get_configured_llm_providers_handler # List configured LLM providers
    # @get BASE_PATH * "/llm/providers/{provider_name::String}/status" LlmHandlers.get_llm_provider_status_handler # Get status of a specific LLM provider
    # @post BASE_PATH * "/llm/chat" LlmHandlers.direct_llm_chat_handler                   # Perform a direct chat with an LLM

    # # ----------------------------------------------------------------------
    # # Swarm Management Routes
    # # These routes handle the creation, configuration, and management of swarms.
    # # ----------------------------------------------------------------------
    # @post BASE_PATH * "/swarms" SwarmHandlers.create_swarm_handler        # Create a new swarm
    # @get BASE_PATH * "/swarms" SwarmHandlers.list_swarms_handler         # List all swarms
    # @get BASE_PATH * "/swarms/{swarm_id::String}" SwarmHandlers.get_swarm_handler # Get details of a specific swarm
    # @post BASE_PATH * "/swarms/{swarm_id::String}/start" SwarmHandlers.start_swarm_handler # Start a swarm
    # @post BASE_PATH * "/swarms/{swarm_id::String}/stop" SwarmHandlers.stop_swarm_handler   # Stop a swarm
    # @post BASE_PATH * "/swarms/{swarm_id::String}/agents" SwarmHandlers.add_agent_to_swarm_handler # Add an agent to a swarm
    # @delete BASE_PATH * "/swarms/{swarm_id::String}/agents/{agent_id::String}" SwarmHandlers.remove_agent_from_swarm_handler # Remove an agent from a swarm
    
    # # Swarm Shared State
    # @get BASE_PATH * "/swarms/{swarm_id::String}/state/{key::String}" SwarmHandlers.get_swarm_shared_state_handler # Get a value from swarm's shared state
    # @post BASE_PATH * "/swarms/{swarm_id::String}/state/{key::String}" SwarmHandlers.update_swarm_shared_state_handler # Update a value in swarm's shared state
    
    # # Swarm Metrics
    # @get BASE_PATH * "/swarms/{swarm_id::String}/metrics" SwarmHandlers.get_swarm_metrics_handler # Get metrics for a specific swarm
    
    # # Swarm Task Management
    # @post BASE_PATH * "/swarms/{swarm_id::String}/tasks" SwarmHandlers.allocate_task_handler # Allocate a new task to the swarm
    # @post BASE_PATH * "/swarms/{swarm_id::String}/tasks/{task_id::String}/claim" SwarmHandlers.claim_task_handler # Agent claims a task
    # @post BASE_PATH * "/swarms/{swarm_id::String}/tasks/{task_id::String}/complete" SwarmHandlers.complete_task_handler # Agent completes a task
    
    # # Swarm Coordination
    # @post BASE_PATH * "/swarms/{swarm_id::String}/electleader" SwarmHandlers.elect_leader_handler # Trigger leader election
    # # TODO: Add routes for getting task lists, specific task details for swarms.

    # # ----------------------------------------------------------------------
    # # Price Feed Routes
    # # These routes provide access to price data from various feeds.
    # # ----------------------------------------------------------------------
    # @get BASE_PATH * "/pricefeeds/providers" PriceFeedHandlers.list_providers_handler # List available price feed providers
    # @get BASE_PATH * "/pricefeeds/{provider_name::String}/info" PriceFeedHandlers.get_feed_info_handler # Get info about a specific provider
    # @get BASE_PATH * "/pricefeeds/{provider_name::String}/pairs" PriceFeedHandlers.list_supported_pairs_handler # List supported pairs for a provider
    # @get BASE_PATH * "/pricefeeds/{provider_name::String}/price" PriceFeedHandlers.get_latest_price_handler # Get latest price for a pair (base_asset, quote_asset as query params)
    # @get BASE_PATH * "/pricefeeds/{provider_name::String}/historical" PriceFeedHandlers.get_historical_prices_handler # Get historical prices

    # # ----------------------------------------------------------------------
    # # DEX (Decentralized Exchange) Routes
    # # These routes provide access to DEX functionalities.
    # # ----------------------------------------------------------------------
    # @get BASE_PATH * "/dex/protocols" DexHandlers.list_dex_protocols_handler # List available DEX protocols
    # # Get pairs for a specific DEX protocol and version (e.g., uniswap/v3)
    # # Query params can specify chain_id, rpc_url, dex_name for specific instance config
    # @get BASE_PATH * "/dex/{protocol::String}/{version::String}/pairs" DexHandlers.get_dex_pairs_handler 
    # # Get price for a pair on a specific DEX
    # # Query params: token0, token1 (symbols or addresses), chain_id, rpc_url, dex_name
    # @get BASE_PATH * "/dex/{protocol::String}/{version::String}/price" DexHandlers.get_dex_price_handler
    # # Get liquidity for a pair on a specific DEX
    # # Query params: token0, token1 (symbols or addresses)
    # @get BASE_PATH * "/dex/{protocol::String}/{version::String}/liquidity" DexHandlers.get_dex_liquidity_handler
    # # Create an order on a specific DEX
    # # Body: pair_id (or token0/1), order_type, side, amount, price (for limit)
    # @post BASE_PATH * "/dex/{protocol::String}/{version::String}/orders" DexHandlers.create_dex_order_handler
    # # Get status of a specific order
    # @get BASE_PATH * "/dex/{protocol::String}/{version::String}/orders/{order_id::String}" DexHandlers.get_dex_order_status_handler
    # # Associate a transaction hash with a previously created order_id
    # @post BASE_PATH * "/dex/{protocol::String}/{version::String}/orders/{order_id::String}/txhash" DexHandlers.associate_tx_hash_handler
    # # Attempt to cancel an order
    # @delete BASE_PATH * "/dex/{protocol::String}/{version::String}/orders/{order_id::String}" DexHandlers.cancel_dex_order_handler

    # # ----------------------------------------------------------------------
    # # Blockchain Interaction Routes
    # # These routes provide access to general blockchain functionalities.
    # # ----------------------------------------------------------------------
    # # Connect to a network (primarily to check status, returns connection info)
    # # Query params: network (e.g. "ethereum"), endpoint_url (optional override)
    # @get BASE_PATH * "/blockchain/connect" BlockchainHandlers.connect_handler
    # # Get native balance for an address on a specific network
    # @get BASE_PATH * "/blockchain/{network::String}/balance/{address::String}" BlockchainHandlers.get_balance_handler
    # # Get ERC20 (or equivalent) token balance
    # @get BASE_PATH * "/blockchain/{network::String}/tokenbalance/{wallet_address::String}/{token_address::String}" BlockchainHandlers.get_token_balance_handler
    # # Get chain ID for a network
    # @get BASE_PATH * "/blockchain/{network::String}/chainid" BlockchainHandlers.get_chain_id_handler
    # # Get current gas price for a network
    # @get BASE_PATH * "/blockchain/{network::String}/gasprice" BlockchainHandlers.get_gas_price_handler
    # # Get transaction count (nonce) for an address on a network
    # @get BASE_PATH * "/blockchain/{network::String}/nonce/{address::String}" BlockchainHandlers.get_transaction_count_handler
    # # Estimate gas for a transaction (tx_params in POST body)
    # @post BASE_PATH * "/blockchain/{network::String}/estimategas" BlockchainHandlers.estimate_gas_handler
    # # Perform an eth_call (read-only contract call; 'to' and 'data' in POST body)
    # @post BASE_PATH * "/blockchain/{network::String}/ethcall" BlockchainHandlers.eth_call_handler
    # # Send a raw, signed transaction (signed_tx_hex in POST body)
    # @post BASE_PATH * "/blockchain/{network::String}/sendrawtransaction" BlockchainHandlers.send_raw_transaction_handler
    # # Get the receipt of a transaction
    # @get BASE_PATH * "/blockchain/{network::String}/receipt/{tx_hash::String}" BlockchainHandlers.get_transaction_receipt_handler
    # # The /sendtransaction endpoint that used backend signing has been removed.
    # # TODO: Add more specific routes as needed, e.g., for specific contract interactions if generalized eth_call is too broad.

    # # ----------------------------------------------------------------------
    # # Trading Strategy Routes
    # # These routes allow interaction with trading strategies.
    # # ----------------------------------------------------------------------
    # @get BASE_PATH * "/trading/strategies/types" TradingHandlers.list_strategy_types_handler # List available types of strategies
    # # Configure a new strategy instance (type and params in body, name is auto-generated or in body)
    # @post BASE_PATH * "/trading/strategies" TradingHandlers.configure_strategy_handler 
    # # List all configured strategies
    # @get BASE_PATH * "/trading/strategies" TradingHandlers.list_configured_strategies_handler
    # # Get details of a specific configured strategy
    # @get BASE_PATH * "/trading/strategies/{strategy_name::String}" TradingHandlers.get_strategy_details_handler
    # # Delete a configured strategy
    # @delete BASE_PATH * "/trading/strategies/{strategy_name::String}" TradingHandlers.delete_strategy_handler
    # # Execute a configured strategy (name in path, market_data or other execution params in body)
    # @post BASE_PATH * "/trading/strategies/{strategy_name::String}/execute" TradingHandlers.execute_strategy_handler
    # # Update a configured strategy
    # @put BASE_PATH * "/trading/strategies/{strategy_name::String}" TradingHandlers.update_strategy_handler
    # # Trigger a backtest for a configured strategy (name in path, backtest params in body)
    # @post BASE_PATH * "/trading/strategies/{strategy_name::String}/backtest" TradingHandlers.backtest_strategy_handler
    # # TODO: Consider if more granular update routes are needed, e.g., for specific parameters.

    @info "API routes registered with Oxygen under $BASE_PATH."
end

end

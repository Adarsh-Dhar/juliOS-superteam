# julia/src/framework/JuliaOSFramework.jl
module JuliaOSFramework

using Logging

export initialize

# --- Include Core Agent Modules ---
# Paths are relative to this file (julia/src/framework/)
# going up to julia/src/ then down to the specific module directory
try
    include("../agents/Config.jl")
    include("../agents/AgentCore.jl")
    include("../agents/AgentMetrics.jl")
    include("../agents/Persistence.jl")
    include("../agents/LLMIntegration.jl")
    include("../agents/Agents.jl")
    include("../agents/PlanAndExecute.jl")
    # include("../agents/AgentMonitor.jl")
    
    # Make Agent modules available
    using .Config
    using .AgentCore
    using .AgentMetrics
    using .LLMIntegration
    using .Agents
    using .Persistence
    using .PlanAndExecute
    @info "JuliaOSFramework: Agent modules included and using'd successfully."
catch e
    @error "JuliaOSFramework: Critical error including Agent modules." exception=(e, catch_backtrace())
end

# --- Include Core Swarm Modules ---
try
    include("../swarm/SwarmBase.jl")
    include("../swarm/Swarms.jl")

    # Make Swarm modules available
    using .SwarmBase
    using .Swarms
    @info "JuliaOSFramework: Swarm modules included and using'd successfully."
catch e
    @error "JuliaOSFramework: Critical error including Swarm modules." exception=(e, catch_backtrace())
end

# --- Include Core Blockchain Modules ---
# try
#     # EthereumClient.jl is included by Blockchain.jl
#     include("../blockchain/Blockchain.jl")
    
#     # Make Blockchain module and its sub-modules/exports available
#     using .Blockchain # This makes Blockchain.EthereumClient accessible if EthereumClient is a submodule
#     # Or, if EthereumClient is not a submodule but its contents are exported by Blockchain.jl:
#     # using .Blockchain: EthereumClient # if EthereumClient module itself is exported
#     # using .Blockchain: call_contract_evm # if specific functions are re-exported by Blockchain.jl
#     @info "JuliaOSFramework: Blockchain modules included and using'd successfully."
# catch e
#     @error "JuliaOSFramework: Critical error including Blockchain modules." exception=(e, catch_backtrace())
#     module BlockchainStub end
#     const Blockchain = BlockchainStub
# end

# include("../modules/trading/Trading.jl")

# --- Include Core DEX Modules ---
# try
#     include("../dex/DEXBase.jl")
#     include("../dex/UniswapDEX.jl") # Example concrete implementation
#     include("../dex/DEX.jl")        # Main DEX module with factory

#     # Make DEX modules available
#     using .DEXBase
#     using .UniswapDEX # Make specific DEX types available if needed directly
#     using .DEX       # Exports items from DEXBase and specific DEXs
#     @info "JuliaOSFramework: DEX modules included and using'd successfully."
# catch e
#     @error "JuliaOSFramework: Critical error including DEX modules." exception=(e, catch_backtrace())
#     module DEXBaseStub end
#     module UniswapDEXStub end
#     module DEXStub end
#     const DEXBase = DEXBaseStub
#     const UniswapDEX = UniswapDEXStub
#     const DEX = DEXStub
# end

# --- Include Core Price Feed Modules ---
# try
#     include("../price/PriceFeedBase.jl") # Base types
#     include("../price/ChainlinkFeed.jl") # Chainlink implementation
#     include("../price/PriceFeed.jl")     # Main PriceFeed module with factory

#     # Make PriceFeed modules available
#     using .PriceFeedBase
#     using .ChainlinkFeed
#     using .PriceFeed # This exports items from PriceFeedBase and ChainlinkFeed again, which is fine.
#     @info "JuliaOSFramework: Price Feed modules included and using'd successfully."
# catch e
#     @error "JuliaOSFramework: Critical error including Price Feed modules." exception=(e, catch_backtrace())
#     # Define stubs if loading fails
#     module PriceFeedBaseStub end
#     module ChainlinkFeedStub end
#     module PriceFeedStub end
#     const PriceFeedBase = PriceFeedBaseStub
#     const ChainlinkFeed = ChainlinkFeedStub
#     const PriceFeed = PriceFeedStub
# end

# --- Include Core Trading Modules ---
# try
#     # TradingStrategy.jl itself includes RiskManagement, MovingAverageStrategy, MeanReversionImpl
#     include("../trading/TradingStrategy.jl")
#     # If RiskManagement, MovingAverageStrategy, MeanReversionImpl were separate and not sub-included:
#     # include("../trading/RiskManagement.jl")
#     # include("../trading/MovingAverageStrategy.jl")
#     # include("../trading/MeanReversionImpl.jl")

#     # Make Trading modules available
#     using .TradingStrategy
#     # using .RiskManagement # Only if not re-exported by TradingStrategy or used directly
#     # using .MovingAverageStrategy
#     # using .MeanReversionImpl
#     @info "JuliaOSFramework: Trading modules included and using'd successfully."
# catch e
#     @error "JuliaOSFramework: Critical error including Trading modules." exception=(e, catch_backtrace())
#     module TradingStrategyStub end
#     const TradingStrategy = TradingStrategyStub
# end

# --- Include Core Storage Module ---
# try
#     # Storage.jl itself includes storage_interface.jl and specific providers like local_storage.jl
#     include("../storage/Storage.jl")
#     using .Storage # Make Storage module and its exports available
#     @info "JuliaOSFramework: Storage module included and using'd successfully."
#     # Initialize storage system with a default provider (e.g., local) if not done by Storage.__init__
#     # This depends on how Storage.initialize_storage_system should be called (app startup vs. module load)
#     # If Storage.__init__ handles default init, this might not be needed here.
#     # if !Storage.STORAGE_SYSTEM_INITIALIZED[]
#     #     Storage.initialize_storage_system() 
#     # end
# catch e
#     @error "JuliaOSFramework: Critical error including Storage module." exception=(e, catch_backtrace())
#     module StorageStub end
#     const Storage = StorageStub
# end

# --- Include API Layer ---
# try
#     include("../api/API.jl") # Include the main API module
#     using .API # Make its exports (like start_server) available within JuliaOSFramework if needed
#     # To make JuliaOS.API.start_server() work, JuliaOS.jl will need to export API,
#     # and JuliaOSFramework should make API available to JuliaOS.jl.
#     # This is typically done by exporting API from JuliaOSFramework.
#     export API # This makes API accessible as JuliaOSFramework.API
#     @info "JuliaOSFramework: API module included and using'd successfully."
# catch e
#     @error "JuliaOSFramework: Critical error including API module." exception=(e, catch_backtrace())
#     module APIStub end # Define a stub if API loading fails
#     const API = APIStub # Make the stub available under the name API
# end


# etc.

"""
    initialize(; storage_path::String)

Initialize the JuliaOS Framework backend components.
This function will call initialization routines for all included modules.
"""
function initialize(; storage_path::String="default_storage_path_from_framework") # storage_path might be used by multiple modules
    @info "Initializing JuliaOSFramework..."
    
    # Initialization for Agents is largely handled by their __init__ functions
    # (Config loading, Persistence loading, Monitor auto-start)
    # We might pass storage_path to a specific persistence re-init if needed,
    # but Persistence.jl already gets path from Agents.Config.
    
    # Initialization for Swarms (e.g., loading persisted state)
    # Swarms.jl also has an __init__ that calls _load_swarms_state.
    
    # If other modules need explicit initialization with parameters like storage_path,
    # they would be called here.
    # Example:
    # Blockchain.initialize(rpc_config_path="...", main_storage=storage_path)
    # DEX.initialize(dex_specific_config="...", shared_cache_path=storage_path)

    @info "JuliaOSFramework initialized."
    return true # Indicate success
end

end # module JuliaOSFramework

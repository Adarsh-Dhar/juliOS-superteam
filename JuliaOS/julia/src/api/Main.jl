# backend-julia/src/main.jl
# Main entry point for the Julia backend application.

# Ensure 'src' is in the load path if running scripts directly,
# or manage as a package where 'agents' and 'api' are top-level modules.
# For simplicity with include, we assume this file is in 'src' and
# 'agents' and 'api' are subdirectories.

@info "Loading backend modules..."

# 1. Basic Configuration Module - No dependencies
include("../agents/Config.jl")

# 2. Core Modules - Depend on Config
include("../agents/AgentCore.jl")
include("../agents/AgentMetrics.jl")  # Depends on Config, AgentCore

# 3. Feature Modules - Depend on basic modules
include("../agents/LLMIntegration.jl")  # Depends on Config
include("../agents/Persistence.jl")     # Depends on Config, AgentMetrics
include("../agents/Agents.jl")          # Depends on Config, AgentMetrics, LLMIntegration, Persistence
include("../agents/AgentMonitor.jl")    # Depends on Config, AgentMetrics, Agents

# 4. API Layer Modules - Depend on all basic modules
include("Utils.jl")
include("AgentHandlers.jl")    # Depends on api/Utils.jl and agents/Agents.jl
include("Routes.jl")           # Depends on handler modules
include("MainServer.jl")       # Depends on api/Routes.jl and agents/Config.jl

# 5. Export modules for other modules to use
using .Config
using .AgentCore
using .AgentMetrics
using .LLMIntegration
using .Persistence
using .Agents
using .AgentMonitor

using .Routes
using .MainServer

# It's generally better practice to structure your project as a Julia package.
# If structured as a package (e.g., JuliaOS), your imports would be like:
# using .Config, .AgentMetrics, .LLMIntegration, .Agents, .Persistence
# using .Api.Utils, .Api.AgentHandlers, ...
# And then the `include` calls are handled by Julia's package manager.
# The `using ..agents.Agents` style within API modules assumes that `src` is part
# of the module hierarchy recognized by Julia's module system.

function main()
    @info "Starting Julia Agent Backend System..."

    # Modules with __init__ functions (like Config, Persistence, Agents)
    # will have their initialization logic run automatically when they are loaded (included/used).

    # Start the API server
    # The MainServer.start_server() will block if async=false in Oxygen.serve/serveparallel
    try
        # Assuming MainServer.jl defines `module MainServer`
        # and `start_server` is exported or accessed via MainServer.start_server
        MainServer.start_server() # Or just MainServer.start_server() if `using .api.MainServer`
    catch e
        @error "Failed to start the API server or server crashed." exception=(e, catch_backtrace())
        # exit(1) # Optionally exit if server fails to start
    end

    @info "Julia Agent Backend has shut down."
end

# Run the main function if this script is executed directly
if abspath(PROGRAM_FILE) == @__FILE__
    main()
else
    # If included as part of a larger system or package,
    # you might not want to automatically call main().
    # The modules are loaded, and `main()` can be called explicitly.
    @info "Backend modules loaded. Call main() to start the server."
end

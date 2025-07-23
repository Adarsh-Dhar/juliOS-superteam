module JuliaOS

# Export public modules and functions
export initialize, initialize_framework # Removed initialize_cli
export API, Storage, Swarms, SwarmBase, Types, CommandHandler, Agents, Trading # Added Trading

# Constants for feature detection
const PYTHON_WRAPPER_EXISTS = isfile(joinpath(@__DIR__, "python/python_bridge.jl"))
const FRAMEWORK_EXISTS = isdir(joinpath(dirname(dirname(@__DIR__)), "packages/framework"))

# Include the framework module
include("framework/JuliaOSFramework.jl")
# cli/JuliaOSCLI.jl was removed as it does not exist

# Import the framework module
using .JuliaOSFramework
# JuliaOSCLI was removed

"""
    initialize(; storage_path::String=joinpath(homedir(), ".juliaos", "juliaos.sqlite"))

Initialize the JuliaOS system (Framework only).

# Arguments
- `storage_path::String`: Path to the storage database for the framework.

# Returns
- `Bool`: true if initialization was successful
"""
function initialize(; storage_path::String=joinpath(homedir(), ".juliaos", "juliaos.sqlite"))
    @info "Initializing JuliaOS Framework..."

    framework_success = initialize_framework(storage_path=storage_path)

    if framework_success
        @info "JuliaOS Framework initialized successfully."
    else
        @warn "JuliaOS Framework initialization had some issues."
    end

    return framework_success
end

"""
    initialize_framework(; storage_path::String=joinpath(homedir(), ".juliaos", "juliaos.sqlite"))

Initialize the JuliaOS Framework backend.

# Arguments
- `storage_path::String`: Path to the storage database

# Returns
- `Bool`: true if initialization was successful
"""
function initialize_framework(; storage_path::String=joinpath(homedir(), ".juliaos", "juliaos.sqlite"))
    return JuliaOSFramework.initialize(storage_path=storage_path)
end

# initialize_cli function removed as CLI module does not exist

end # module

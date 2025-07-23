# Import JuliaOS module
using JuliaOS

# Import API related modules
include("api/Main.jl")
using .Main

# Initialize framework
initialize()

# Start server
main() 
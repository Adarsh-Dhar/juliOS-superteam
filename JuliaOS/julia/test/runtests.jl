using Test
using JuliaOS

# Get command line arguments
args = ARGS

# If no arguments, run all tests
if isempty(args)
    # Import all test modules
    include("trading/runtests.jl")
    include("risk/runtests.jl")
    include("storage/runtests.jl")
    include("swarm/runtests.jl")
    include("dex/runtests.jl")
    include("framework/runtests.jl")
    include("price/runtests.jl")
    include("api/runtests.jl")
    include("blockchain/runtests.jl")
    include("agents/runtests.jl")
else
    # Run specified test files
    for test_file in args
        if endswith(test_file, ".jl")
            include(test_file)
        else
            # If not a .jl file, try adding .jl extension
            include(test_file * ".jl")
        end
    end
end

# Run all tests
@testset "JuliaOS Tests" begin
    # Global tests can be added here
end 
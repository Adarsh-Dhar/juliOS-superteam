module JuliaOSBackend

include("resources/Resources.jl")
include("agents/Agents.jl")
include("db/JuliaDB.jl")
include("api/JuliaOSV1Server.jl")

using .Resources
using .Agents
using .JuliaDB
using .JuliaOSV1Server

end
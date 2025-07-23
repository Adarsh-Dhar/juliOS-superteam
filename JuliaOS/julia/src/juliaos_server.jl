module JuliaOSV1Server

using HTTP

include("api/server/src/JuliaOSServer.jl")

using .JuliaOSServer

const server = Ref{Any}(nothing)
const agents = Vector{Agent}()

function create_agent(req::HTTP.Request, agent::Agent)
    @info "Triggered endpoint: POST /agents"
    @info "NYI, not actually creating agent $(agent.id)..."
    return nothing
end

function list_agents(req::HTTP.Request)
    @info "Triggered endpoint: GET /agents"
    @info "NYI, not actually listing agents..."
    return agents
end

function ping(::HTTP.Request)
    @info "Triggered endpoint: GET /ping"
    return HTTP.Response(200, "")
end

function update_agent(req::HTTP.Request, agent_id::String, update::AgentUpdate)
    @info "Triggered endpoint: PUT /agents/$(agent_id)"
    @info "NYI, not actually updating agent $(agent_id)..."
    return nothing
end

function delete_agent(req::HTTP.Request, agent_id::String)
    @info "Triggered endpoint: DELETE /agents/$(agent_id)"
    @info "NYI, not actually deleting agent $(agent_id)..."
    return nothing
end

function process_agent_webhook(req::HTTP.Request, agent_id::String, payload::Dict{String, Any})
    @info "Triggered endpoint: POST /agents/$(agent_id)/webhook"
    @info "NYI, not actually processing webhook for agent $(agent_id)..."
    return nothing
end

function get_agent_output(req::HTTP.Request, agent_id::String)
    @info "Triggered endpoint: GET /agents/$(agent_id)/output"
    @info "NYI, not actually getting agent $(agent_id) output..."
    return Dict{String, Any}()
end

function run_server(port=8052)
    try
        router = HTTP.Router()
        router = JuliaOSServer.register(router, @__MODULE__; path_prefix="/api/v1")
        HTTP.register!(router, "GET", "/ping", ping)
        server[] = HTTP.serve!(router, port)
        wait(server[])
    catch ex
        @error("Server error", exception=(ex, catch_backtrace()))
    end
end

end # module JuliaOSV1Server

JuliaOSV1Server.run_server()
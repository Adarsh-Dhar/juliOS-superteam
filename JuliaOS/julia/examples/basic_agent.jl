using Pkg
Pkg.activate(".")

using DotEnv
DotEnv.load!()

using JuliaOS

function main()
    # Configure LLM parameters
    llm_config = Dict{String, Any}(
        "provider" => "openai",
        "api_key" => ENV["OPENAI_API_KEY"],
        "api_base" => ENV["OPENAI_BASE_URL"],
        "model" => ENV["OPENAI_MODEL"],
        "temperature" => 0.7,
        "max_tokens" => 8092,
        "stream" => false  # Enable streaming output
    )
    # Create basic Agent configuration
    cfg = JuliaOS.JuliaOSFramework.AgentCore.AgentConfig(
        "TestAgent",
        JuliaOS.JuliaOSFramework.AgentCore.CUSTOM;
        abilities=["ping"],
        parameters=Dict{String, Any}("demo" => true),
        llm_config=llm_config,
        memory_config=Dict{String, Any}(),
        queue_config=Dict{String, Any}(), 
    )
    
    # Create agent
    agent = JuliaOS.JuliaOSFramework.Agents.createAgent(cfg)
    @info "Agent $(agent.id) created successfully"
    println()

    # Start agent
    is_started = JuliaOS.JuliaOSFramework.Agents.startAgent(agent.id)
    @info "Agent $(agent.id) started successfully"
    println()

    # Pause agent
    is_paused = JuliaOS.JuliaOSFramework.Agents.pauseAgent(agent.id)
    @info "Agent $(agent.id) paused successfully"
    println()

    # Get agent status
    status = JuliaOS.JuliaOSFramework.Agents.getAgentStatus(agent.id)
    @show status
    println()

    # Resume agent
    is_resumed = JuliaOS.JuliaOSFramework.Agents.resumeAgent(agent.id)
    @info "Agent $(agent.id) resumed successfully"
    println()

    # Execute ping task
    result = JuliaOS.JuliaOSFramework.Agents.executeAgentTask(agent.id, Dict{String, Any}("ability" => "ping"))
    @show result
    println()

    # Execute llm chat task
    result = JuliaOS.JuliaOSFramework.Agents.executeAgentTask(agent.id, Dict{String, Any}("ability" => "llm_chat", "prompt" => "how are you?"))
    @show result
    println()

    # Stop agent
    is_stopped = JuliaOS.JuliaOSFramework.Agents.stopAgent(agent.id)
    @info "Agent $(agent.id) stopped successfully"
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end 
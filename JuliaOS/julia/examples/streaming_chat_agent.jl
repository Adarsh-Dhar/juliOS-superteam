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
        "stream" => true  # Enable streaming output
    )

    # Create agent configuration
    chat_agent_cfg = JuliaOS.JuliaOSFramework.AgentCore.AgentConfig(
        "StreamingChatAgent",
        JuliaOS.JuliaOSFramework.AgentCore.CUSTOM;
        abilities=["llm_chat"],
        parameters=Dict{String, Any}("demo" => true),
        llm_config=llm_config,
        memory_config=Dict{String, Any}(),
        queue_config=Dict{String, Any}(),
    )

    # Create agent
    chat_agent = JuliaOS.JuliaOSFramework.Agents.createAgent(chat_agent_cfg)
    @info "Streaming Chat Agent $(chat_agent.id) created successfully"

    # Start agent
    JuliaOS.JuliaOSFramework.Agents.startAgent(chat_agent.id)
    @info "Streaming Chat Agent $(chat_agent.id) started successfully"

    # Execute chat task
    prompt = "Hello! Can you write a 1000-word essay for me? The topic is modernization!"
    @info "Start chat, input: $prompt"
    
    # Use streaming output
    result = JuliaOS.JuliaOSFramework.Agents.executeAgentTask(
        chat_agent.id, 
        Dict{String, Any}(
            "ability" => "llm_chat",
            "prompt" => prompt,
        )
    )
    
    # Handle streaming response
    @info "Start receiving streaming response..."
    if isa(result, Dict) && haskey(result, "answer")
        ch = result["answer"]
        for content in ch
            print(content)
            flush(stdout)
        end
        println()
    else
        @info "Received normal response"
        @show result
    end
    
    @info "Chat completed"

    # Stop agent
    JuliaOS.JuliaOSFramework.Agents.stopAgent(chat_agent.id)
    @info "Streaming Chat Agent $(chat_agent.id) stopped successfully"
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end 
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
        "max_tokens" => 1024
    )

    # Create Plan and Execute Agent configuration
    plan_agent_cfg = JuliaOS.JuliaOSFramework.AgentCore.AgentConfig(
        "PlanExecuteAgent",
        JuliaOS.JuliaOSFramework.AgentCore.CUSTOM;
        abilities=["ping", "llm_chat"],
        parameters=Dict{String, Any}("demo" => true),
        llm_config=llm_config,
        memory_config=Dict{String, Any}(),
        queue_config=Dict{String, Any}(),
    )

    # Create agent
    plan_agent = JuliaOS.JuliaOSFramework.Agents.createAgent(plan_agent_cfg)
    @info "PlanExecute Agent $(plan_agent.id) created successfully"

    # Start agent
    JuliaOS.JuliaOSFramework.Agents.startAgent(plan_agent.id)
    @info "PlanExecute Agent $(plan_agent.id) started successfully"

    # Define tools
    tools = [
        Dict("name" => "Ping",
             "description" => "Simple ping tool to check if the system is responsive",
             "ability" => "ping"),
        Dict("name" => "LLMChat",
             "description" => "Ask the language model a question and get a response",
             "ability" => "llm_chat")
    ]

    # Create Plan and Execute agent
    @info "Creating PlanAndExecute agent"
    plan_execute_agent = JuliaOS.JuliaOSFramework.PlanAndExecute.create_plan_execute_agent(
        plan_agent.id,
        tools,
        llm_config
    )

    # Define task
    task = "First check if the system is responsive, then ask the language model what the capital of France is."

    # Run Plan and Execute agent
    @info "Running PlanAndExecute agent with task: $task"
    result = JuliaOS.JuliaOSFramework.PlanAndExecute.run_plan_execute_agent(plan_execute_agent, task)

    # Display results
    @info "PlanAndExecute Execution Complete"
    @info "Success: $(result["success"])"
    @info "Steps Completed: $(result["steps_completed"]) / $(result["steps_count"])"
    @info "Execution Summary:\n$(result["execution_summary"])"
    @info "Final Answer: $(result["final_answer"])"

    # Stop agent
    JuliaOS.JuliaOSFramework.Agents.stopAgent(plan_agent.id)
    @info "PlanExecute Agent $(plan_agent.id) stopped successfully"
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end 
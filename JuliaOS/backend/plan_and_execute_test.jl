using Pkg
Pkg.activate(".")

using JuliaOSBackend.Agents
using JuliaOSBackend.Agents.CommonTypes: AgentBlueprint, ToolBlueprint, StrategyBlueprint, TriggerConfig, WebhookTriggerParams

function main()
    @info "Supported tools:"
    for (name, spec) in Agents.Tools.TOOL_REGISTRY
        @info " - $name: $spec"
    end
    @info "Supported strategies:"
    for (name, spec) in Agents.Strategies.STRATEGY_REGISTRY
        @info " - $name: $spec"
    end

    tool_blueprints = [
        ToolBlueprint("ping", Dict()),
        ToolBlueprint("llm_chat", Dict())
    ]
    strategy_config = Dict()

    plan_execute_blueprint = AgentBlueprint(
        tool_blueprints,
        StrategyBlueprint("plan_execute", strategy_config),
        TriggerConfig(Agents.CommonTypes.WEBHOOK_TRIGGER, WebhookTriggerParams())
    )
    
    plan_execute_agent = Agents.create_agent("plan_execute_agent", "Plan and Execute Agent", "Agent with reasoning capabilities", plan_execute_blueprint)
    @info "Created reasoning agent: $plan_execute_agent"

    @info "Existing agents:"
    for (name, agent) in Agents.AGENTS
        @info " - $name: $agent"
    end

    Agents.set_agent_state(plan_execute_agent, Agents.CommonTypes.RUNNING_STATE)
    @info "plan_execute_agent is now RUNNING"

    payload = Dict{String, Any}(
        "task" => "First check if the system is responsive, then ask the language model what the capital of France is."
    )

    @info "Running PlanAndExecute agent with task: $payload"
    Agents.run(plan_execute_agent, task)

    @info "Agent logs after sample runs:"
    for log in plan_execute_agent.context.logs
        @info " - $log"
    end

    @info "Existing agents at the end:"
    for (name, agent) in Agents.AGENTS
        @info " - $name: $agent"
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end

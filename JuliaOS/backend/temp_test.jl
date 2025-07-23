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

    example_blueprint = AgentBlueprint(
        [
            ToolBlueprint("adder", Dict("add_value" => 3))
        ],
        StrategyBlueprint(
            "adder",
            Dict("times_to_add" => 5)
        ),
        TriggerConfig(
            Agents.CommonTypes.WEBHOOK_TRIGGER,
            WebhookTriggerParams()
        )
    )

    example_agent = Agents.create_agent("example_agent", "Example Agent", "Adds 2", example_blueprint)
    @info "Created agent: $example_agent"

    @info "Exising agents:"
    for (name, agent) in Agents.AGENTS
        @info " - $name: $agent"
    end

    Agents.set_agent_state(example_agent, Agents.CommonTypes.RUNNING_STATE)

    Agents.run(example_agent, Dict("value" => 7))

    @info "Agent logs:"
    for log in example_agent.context.logs
        @info " - $log"
    end

    @info "Exising agents:"
    for (name, agent) in Agents.AGENTS
        @info " - $name: $agent"
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
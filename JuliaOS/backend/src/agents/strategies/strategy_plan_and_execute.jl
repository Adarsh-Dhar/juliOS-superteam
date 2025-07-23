using ...Resources: Gemini
using ..CommonTypes: StrategyConfig, AgentContext, StrategySpecification, InstantiatedTool, StrategyMetadata, StrategyInput
import Dates: DateTime, now
using Random
using JSON3


GEMINI_API_KEY = ENV["GEMINI_API_KEY"]
GEMINI_MODEL = "models/gemini-1.5-pro"

Base.@kwdef struct StrategyPlanAndExecuteConfig <: StrategyConfig
    api_key::String = GEMINI_API_KEY
    model_name::String = GEMINI_MODEL
    temperature::Float64 = 0.7
    max_output_tokens::Int = 1024
end

Base.@kwdef struct PlanAndExecuteInput <: StrategyInput
    text::String
end

# ----------------------------------------------------------------------
# CONSTANTS
# ----------------------------------------------------------------------
const PLANNING_PROMPT = """
    You are a planning agent designed to identify the steps needed to answer a user's question or fulfill a task.
    Your goal is to break down the problem into a sequence of clear, executable steps.
    You will be given a set of available tools that you can use to execute these steps.

    Available tools:
    {tools}

    For the following task, create a plan with a specific sequence of steps:
    Task: {input}

    Your response must follow this format:
    ```plan
    1. First step description
    2. Second step description
    ...
    n. Final step description
    ```
"""

const EXECUTION_PROMPT = """
    You are an execution agent. Your goal is to execute a specific step in a plan, using the available tools.
    You must determine which tool to use and how to use it to fulfill the current step.

    Available tools:
    {tools}

    Context of your plan (earlier steps and their results):
    {context}

    Current step to execute: {current_step}

    First, think about which tool would be most appropriate...
    Then respond *only* with a JSON object of the form:
    ```json
    {
     "tool":   "<one of the tool names above>",
     "parameters": {
        /* keys must match your ability’s signature exactly */
     }
    }
    ```
    Do *not* include any extra text.
    After executing the tool, provide a brief summary of what you did and what you learned.
"""

# ----------------------------------------------------------------------
# TYPES
# ----------------------------------------------------------------------
"""
    struct PlanStep

Represents a step in an execution plan.

# Fields
- `id::String`: Unique identifier for this step
- `description::String`: Description of what this step should accomplish
- `status::Symbol`: Current status of the step (:pending, :running, :completed, :failed)
- `result::Union{Dict{String,Any}, Nothing}`: Result of executing this step, or nothing if not executed yet
"""
struct PlanStep
    id::String
    description::String
    status::Symbol
    result::Union{Dict{String,Any}, Nothing}

    # Outer constructors
    PlanStep(id::String, description::String) = new(id, description, :pending, nothing)
    PlanStep(id::String, description::String, status::Symbol, result::Union{Dict{String,Any}, Nothing}) = new(id, description, status, result)
end

"""
    struct Plan

Represents a plan with a sequence of steps.

# Fields
- `id::String`: Unique identifier for this plan
- `original_input::String`: The original user query or task
- `steps::Vector{PlanStep}`: Sequence of steps in the plan
- `created_at::DateTime`: When the plan was created
"""
struct Plan
    id::String
    original_input::String
    steps::Vector{PlanStep}
    created_at::DateTime

    # Constructor
    Plan(id::String, input::String, steps::Vector{PlanStep}) = new(id, input, steps, now())
end

# ----------------------------------------------------------------------
# FUNCTIONS
# ----------------------------------------------------------------------
"""
    make_gemini_config(cfg::StrategyPlanAndExecuteConfig)::Gemini.GeminiConfig

Creates a GeminiConfig from the StrategyPlanAndExecuteConfig.

# Arguments
- `cfg::StrategyPlanAndExecuteConfig`: Strategy configuration containing Gemini parameters

# Returns
- A Gemini.GeminiConfig object with the specified parameters
"""
function make_gemini_config(cfg::StrategyPlanAndExecuteConfig)
    return Gemini.GeminiConfig(
        api_key = cfg.api_key,
        model_name = cfg.model_name,
        temperature = cfg.temperature,
        max_output_tokens = cfg.max_output_tokens
    )
end


"""
    format_tools_for_prompt(tools::Vector{InstantiatedTool})::String

Formats the list of tools for inclusion in prompts.

# Arguments
- `tools::Vector{InstantiatedTool}`: List of tools to format

# Returns
- Formatted tools as a string
"""
function format_tools_for_prompt(tools::Vector{InstantiatedTool})::String
    formatted = ""
    for tool in tools
        formatted *= "- $(tool.metadata.name): $(tool.metadata.description)\n"
    end
    return formatted
end

"""
    parse_plan(plan_text::String)::Vector{String}

Parses the plan text returned by the LLM into individual step descriptions.

# Arguments
- `plan_text::String`: The plan text from the LLM, expected to be in a specific format

# Returns
- Vector of step descriptions
"""
function parse_plan(plan_text::String)::Vector{String}
    # Look for text between ```plan and ``` or just parse numbered list if not found
    plan_match = match(r"```plan\s*([\s\S]*?)```", plan_text)
    if plan_match !== nothing
        plan_content = plan_match.captures[1]
    else
        # Just use the whole text if no markers found
        plan_content = plan_text
    end

    # Extract numbered steps
    steps = String[]
    for line in split(plan_content, "\n")
        step_match = match(r"^\s*(\d+)\.(.*)", line)
        if step_match !== nothing
            push!(steps, strip(step_match.captures[2]))
        end
    end

    return steps
end

"""
    create_plan(cfg::StrategyPlanAndExecuteConfig, ctx::AgentContext, input::String)::Plan

Creates a plan by sending a planning prompt to the LLM.

# Arguments
- `cfg::StrategyPlanAndExecuteConfig`: Strategy config.
- `ctx::AgentContext`: Agent context with available tools and logging.
- `input::String`: The user's query or task

# Returns
- A Plan object containing the steps to execute
"""
function create_plan(cfg::StrategyPlanAndExecuteConfig, ctx::AgentContext, input::String)::Plan
    # Format tools for the prompt
    tools_str = format_tools_for_prompt(ctx.tools)

    # Replace placeholders in the planning prompt
    prompt = replace(PLANNING_PROMPT, "{tools}" => tools_str, "{input}" => input)

    gemini_cfg = make_gemini_config(cfg)

    # Send the prompt to the LLM
    response = Gemini.gemini_util(
        gemini_cfg,
        prompt
    ) #raw?

    # Parse the response to extract steps
    step_descriptions = parse_plan(response)

    # Create a PlanStep for each description
    steps = PlanStep[]
    for (i, desc) in enumerate(step_descriptions)
        step_id = "step-$(i)-$(randstring(5))"
        push!(steps, PlanStep(step_id, desc))
    end

    # Create and return the Plan
    plan_id = "plan-$(randstring(8))"
    return Plan(plan_id, input, steps)
end

"""
    execute_step(cfg::StrategyPlanAndExecuteConfig, ctx::AgentContext, step::PlanStep, plan::Plan, context::String)::PlanStep

Executes a single step in the plan.

# Arguments
- `cfg::StrategyPlanAndExecuteConfig`: Strategy config.
- `ctx::AgentContext`: Agent context with available tools and logging.
- `step::PlanStep`: The step to execute
- `plan::Plan`: The overall plan
- `context::String`: Context from previous steps

# Returns
- Updated PlanStep with execution results
"""
function execute_step(cfg::StrategyPlanAndExecuteConfig, ctx::AgentContext, step::PlanStep, plan::Plan, context::String)::PlanStep
    # Format tools for the prompt
    tools_str = format_tools_for_prompt(ctx.tools)

    # Replace placeholders in the execution prompt
    prompt = replace(EXECUTION_PROMPT,
                     "{tools}" => tools_str,
                     "{context}" => context,
                     "{current_step}" => step.description)

    
    gemini_cfg = make_gemini_config(cfg)

    # Send the prompt to the LLM
    raw_response = Gemini.gemini_util(
        gemini_cfg,
        prompt
    )

    # Strip Markdown code fences if present
    json_str = replace(raw_response, r"(?ms)```\s*json\s*(.*?)```" => s"\1")

    # Parse JSON response
    resp = try
        JSON3.read(json_str)
    catch e
        @warn "Failed to parse JSON from execution agent:" raw_response
        # Return failure with error dict of correct type
        return PlanStep(step.id, step.description, :failed, Dict{String,Any}("error" => "Invalid JSON response"))
    end

    # Extract tool name & params
    tool_name = String(resp["tool"])
    params = Dict{String,Any}()
    for (k, v) in resp["parameters"]
        params[String(k)] = v
    end

    # Find the matching Tool object
    idx = findfirst(t -> t.metadata.name == tool_name, ctx.tools)
    if idx === nothing
        @warn "Unknown tool: $tool_name"
        return PlanStep(step.id, step.description, :failed,
                        Dict{String,Any}("error" => "Unknown tool: $tool_name"))
    end
    chosen_tool = ctx.tools[idx]
    if chosen_tool === nothing
        @warn "Unknown tool: $tool_name"
        return PlanStep(step.id, step.description, :failed,
                        Dict{String,Any}("error" => "Unknown tool: $tool_name"))
    end

    # Execute the task
    raw = try
        chosen_tool.execute(chosen_tool.config, params)
    catch e
        @warn "Tool $tool_name execution failed with error" exception=(e, catch_backtrace())
        return PlanStep(step.id, step.description, :failed,
                        Dict("error" => "Tool execution error: $(e)"))
    end

    result = Dict{String,Any}(raw)

    # Promote `msg` to `output` if present
    if haskey(result, "msg") && !haskey(result, "output")
        result["output"] = result["msg"]
    end

    # Determine status
    status = get(result, "success", false) ? :completed : :failed

    # Return updated PlanStep
    return PlanStep(step.id, step.description, status, result)
end

"""
    execute_plan(cfg::StrategyPlanAndExecuteConfig, ctx::AgentContext, plan::Plan)::Plan

Executes each step in the plan sequentially.

# Arguments
- `cfg::StrategyPlanAndExecuteConfig`: Strategy config.
- `ctx::AgentContext`: Agent context with available tools and logging.
- `plan::Plan`: The plan to execute

# Returns
- Updated Plan with execution results
"""
function execute_plan(cfg::StrategyPlanAndExecuteConfig, ctx::AgentContext, plan::Plan)::Plan
    context = "Original task: $(plan.original_input)\n\nExecution progress:\n"

    for (i, step) in enumerate(plan.steps)
        @info "Executing step $(i)/$(length(plan.steps)): $(step.description)"

        # Create a new PlanStep with status :running
        running_step = PlanStep(step.id, step.description, :running, step.result)

        # Execute the step (returns a new PlanStep with updated status/result)
        updated_step = execute_step(cfg, ctx, running_step, plan, context)
        plan.steps[i] = updated_step

        # Update context with this step's result
        context *= "Step $(i): $(step.description)\n"
        if updated_step.status == :completed
            context *= "Result: Success - $(get(updated_step.result, "output", "No specific output"))\n\n"
        else
            context *= "Result: Failed - $(get(updated_step.result, "error", "Unknown error"))\n\n"
            # If a step fails, we might want to stop execution
            # For now, we'll continue to try the next steps
        end
    end

    return plan
end

"""
    strategy_plan_and_execute(cfg::StrategyPlanAndExecuteConfig, ctx::AgentContext, input::String)::AgentContext

Main plan-and-execute function, includes planning, step execution, and final summarization.

# Arguments
- `cfg::StrategyPlanAndExecuteConfig`: Strategy config.
- `ctx::AgentContext`: Agent context with available tools and logging.
- `input::PlanAndExecuteInput`: Struct containing the original user query (`text` field).

# Returns
- Updated AgentContext with logs and final result.
"""
function strategy_plan_and_execute(cfg::StrategyPlanAndExecuteConfig, ctx::AgentContext, input::PlanAndExecuteInput)::AgentContext
    gemini_cfg = make_gemini_config(cfg)
    text = input.text
    
    # Logging: Plan creation
    push!(ctx.logs, "Creating plan for input: $(text)")
    plan = create_plan(cfg, ctx, text)

    steps_count = length(plan.steps)

    # Logging: Plan execution
    push!(ctx.logs, "Executing plan with $(steps_count) steps")
    executed_plan = execute_plan(cfg, ctx, plan)

    # Analyze results and summarize execution
    completed_count = count(step -> step.status == :completed, executed_plan.steps)
    all_completed = completed_count == steps_count
    push!(ctx.logs, "All steps completed: $(all_completed)")
    push!(ctx.logs, "Steps completed: $(completed_count) / $(steps_count)")

    # Create a summary of the execution
    summary = ""
    for (i, step) in enumerate(executed_plan.steps)
        status_str = step.status == :completed ? "✓" : "✗"
        summary *= "$(status_str) Step $(i): $(step.description)\n"
    end
    push!(ctx.logs, "Execution summary:\n$(summary)")

    # Generate a final answer based on all steps
    tools_str = format_tools_for_prompt(ctx.tools)

    # Generate a final answer prompt
    final_answer_prompt = """
    You are a plan-and-execute agent that has completed a series of steps to answer a question or complete a task.
    Based on the results of these steps, provide a concise and complete final answer.

    Original task: $(plan.original_input)

    Plan execution summary:
    $(summary)

    For each step, here are the details:
    """

    for (i, step) in enumerate(executed_plan.steps)
        final_answer_prompt *= "Step $(i): $(step.description)\n"
        if step.status == :completed
            final_answer_prompt *= "Result: $(get(step.result, "output", "No specific output"))\n\n"
        else
            final_answer_prompt *= "Result: Failed - $(get(step.result, "error", "Unknown error"))\n\n"
        end
    end

    final_answer_prompt *= "Based on these steps and results, provide a concise, complete final answer to the original task."

    # Logging: Final answer generation
    push!(ctx.logs, "💡 Generating final answer from plan execution results")
    final_answer = Gemini.gemini_util(
        gemini_cfg,
        final_answer_prompt
    )

    # Logging: Final answer
    push!(ctx.logs, "Final answer generated: $(final_answer)")

    return ctx
end

const STRATEGY_PLAN_AND_EXECUTE_METADATA = StrategyMetadata(
    "plan_execute"
)

const STRATEGY_PLAN_AND_EXECUTE_SPECIFICATION = StrategySpecification(
    strategy_plan_and_execute,
    nothing,
    StrategyPlanAndExecuteConfig,
    STRATEGY_PLAN_AND_EXECUTE_METADATA,
    PlanAndExecuteInput
)

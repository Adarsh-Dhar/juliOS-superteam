# src/agents/PlanAndExecute.jl

"""
PlanAndExecute.jl - Plan-and-Execute Agent Pattern

This module implements the Plan-and-Execute agent pattern similar to LangChain.
It allows agents to first plan the steps required to solve a task and then execute each step
using the provided tools.
"""
module PlanAndExecute

# ----------------------------------------------------------------------
# DEPENDENCIES
# ----------------------------------------------------------------------
using Dates, Random, UUIDs, Logging
using JSON3

# ----------------------------------------------------------------------
# IMPORT OTHER MODULES
# ----------------------------------------------------------------------
using ..Config
using ..AgentCore: Agent, AbstractLLMIntegration, TaskResult, TASK_COMPLETED, TASK_FAILED, TASK_RUNNING
using ..Agents: getAgent, executeAgentTask
using ..LLMIntegration

# ----------------------------------------------------------------------
# EXPORTS
# ----------------------------------------------------------------------
export PlanAndExecuteAgent, create_plan_execute_agent, run_plan_execute_agent

llm = LLMIntegration.OpenAILLMIntegration()  # or whichever integration you want

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
    struct Tool

Represents a tool that can be used by the Plan-and-Execute agent.

# Fields
- `name::String`: The name of the tool
- `description::String`: A description of what the tool does
- `ability::String`: The name of the registered ability that implements this tool
"""
struct Tool
    name::String
    description::String
    ability::String
end

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

"""
    struct PlanAndExecuteAgent

Implements the Plan-and-Execute agent pattern.

# Fields
- `agent_id::String`: ID of the JuliaOS agent to use for LLM interactions
- `tools::Vector{Tool}`: Tools available to the agent
- `llm_config::Dict{String,Any}`: Configuration for the LLM
"""
struct PlanAndExecuteAgent
    agent_id::String
    tools::Vector{Tool}
    llm_config::Dict{String,Any}
end

# ----------------------------------------------------------------------
# FUNCTIONS
# ----------------------------------------------------------------------

"""
    format_tools_for_prompt(tools::Vector{Tool})::String

Formats the list of tools for inclusion in prompts.

# Arguments
- `tools::Vector{Tool}`: List of tools to format

# Returns
- Formatted tools as a string
"""
function format_tools_for_prompt(tools::Vector{Tool})::String
    formatted = ""
    for tool in tools
        formatted *= "- $(tool.name): $(tool.description)\n"
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
    create_plan(agent::PlanAndExecuteAgent, input::String)::Plan

Creates a plan by sending a planning prompt to the LLM.

# Arguments
- `agent::PlanAndExecuteAgent`: The agent to create the plan with
- `input::String`: The user's query or task

# Returns
- A Plan object containing the steps to execute
"""
function create_plan(agent::PlanAndExecuteAgent, input::String)::Plan
    # Format tools for the prompt
    tools_str = format_tools_for_prompt(agent.tools)

    # Replace placeholders in the planning prompt
    prompt = replace(PLANNING_PROMPT, "{tools}" => tools_str, "{input}" => input)

    # Send the prompt to the LLM
    response = LLMIntegration.chat(llm, prompt; cfg=agent.llm_config)

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
    execute_step(agent::PlanAndExecuteAgent, step::PlanStep, plan::Plan, context::String)::PlanStep

Executes a single step in the plan.

# Arguments
- `agent::PlanAndExecuteAgent`: The agent to execute the step with
- `step::PlanStep`: The step to execute
- `plan::Plan`: The overall plan
- `context::String`: Context from previous steps

# Returns
- Updated PlanStep with execution results
"""
function execute_step(agent::PlanAndExecuteAgent, step::PlanStep, plan::Plan, context::String)::PlanStep
    # Format tools for the prompt
    tools_str = format_tools_for_prompt(agent.tools)

    # Replace placeholders in the execution prompt
    prompt = replace(EXECUTION_PROMPT,
                     "{tools}" => tools_str,
                     "{context}" => context,
                     "{current_step}" => step.description)

    # Send the prompt to the LLM
    raw_response = LLMIntegration.chat(llm, prompt; cfg=agent.llm_config)

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
    # Convert parameters to a plain Dict{String,Any}
    params = Dict{String,Any}()
    for (k, v) in resp["parameters"]
        params[String(k)] = v
    end

    # Find the matching Tool object
    idx = findfirst(t -> t.name == tool_name, agent.tools)
    if idx === nothing
        @warn "Unknown tool: $tool_name"
        return PlanStep(step.id, step.description, :failed,
                        Dict{String,Any}("error" => "Unknown tool: $tool_name"))
    end
    chosen_tool = agent.tools[idx]
    if chosen_tool === nothing
        @warn "Unknown tool: $tool_name"
        return PlanStep(step.id, step.description, :failed,
                        Dict{String,Any}("error" => "Unknown tool: $tool_name"))
    end

    # Prepare and execute the task
    task = Dict("ability" => chosen_tool.ability, "parameters" => params)
    raw = executeAgentTask(agent.agent_id, task)
    # Normalize result to Dict{String,Any}
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
    execute_plan(agent::PlanAndExecuteAgent, plan::Plan)::Plan

Executes each step in the plan sequentially.

# Arguments
- `agent::PlanAndExecuteAgent`: The agent to execute the plan with
- `plan::Plan`: The plan to execute

# Returns
- Updated Plan with execution results
"""
function execute_plan(agent::PlanAndExecuteAgent, plan::Plan)::Plan
    context = "Original task: $(plan.original_input)\n\nExecution progress:\n"

    for (i, step) in enumerate(plan.steps)
        @info "Executing step $(i)/$(length(plan.steps)): $(step.description)"

        # Create a new PlanStep with status :running
        running_step = PlanStep(step.id, step.description, :running, step.result)

        # Execute the step (returns a new PlanStep with updated status/result)
        updated_step = execute_step(agent, running_step, plan, context)
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
    create_plan_execute_agent(agent_id::String, tools::Vector{Dict{String,String}},
                              llm_config::Dict{String,Any}=Dict{String,Any}())::PlanAndExecuteAgent

Creates a new Plan-and-Execute agent.

# Arguments
- `agent_id::String`: ID of the JuliaOS agent to use for LLM interactions
- `tools::Vector{Dict{String,String}}`: List of tools available to the agent
  Each tool should have 'name', 'description', and 'ability' keys
- `llm_config::Dict{String,Any}`: Optional configuration for the LLM

# Returns
- A new PlanAndExecuteAgent
"""
function create_plan_execute_agent(agent_id::String, tools::Vector{Dict{String,String}},
                               llm_config::Dict{String,Any}=Dict{String,Any}())::PlanAndExecuteAgent
    # Convert tools dict to Tool objects
    tool_objects = Tool[]
    for tool_dict in tools
        push!(tool_objects, Tool(
            get(tool_dict, "name", "unknown"),
            get(tool_dict, "description", "No description"),
            get(tool_dict, "ability", "unknown")
        ))
    end

    return PlanAndExecuteAgent(agent_id, tool_objects, llm_config)
end

"""
    run_plan_execute_agent(agent::PlanAndExecuteAgent, input::String)::Dict{String,Any}

Runs the Plan-and-Execute agent on a user query or task.

# Arguments
- `agent::PlanAndExecuteAgent`: The agent to run
- `input::String`: The user's query or task

# Returns
- A dictionary containing the execution results
"""
function run_plan_execute_agent(agent::PlanAndExecuteAgent, input::String)::Dict{String,Any}
    # Create the plan
    @info "Creating plan for input: $(input)"
    plan = create_plan(agent, input)

    # Execute the plan
    @info "Executing plan with $(length(plan.steps)) steps"
    executed_plan = execute_plan(agent, plan)

    # Analyze results
    all_completed = all(step.status == :completed for step in executed_plan.steps)

    # Create a summary of the execution
    summary = ""
    for (i, step) in enumerate(executed_plan.steps)
        status_str = step.status == :completed ? "✓" : "✗"
        summary *= "$(status_str) Step $(i): $(step.description)\n"
    end

    # Generate a final answer based on all steps
    tools_str = format_tools_for_prompt(agent.tools)

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

    # Get the final answer from the LLM
    final_answer = LLMIntegration.chat(llm, final_answer_prompt; cfg=agent.llm_config)

    # Return the results
    return Dict(
        "success" => all_completed,
        "plan_id" => plan.id,
        "original_input" => plan.original_input,
        "steps_count" => length(plan.steps),
        "steps_completed" => count(step -> step.status == :completed, plan.steps),
        "execution_summary" => summary,
        "final_answer" => final_answer
    )
end

# Example usage:
#=
# Define some tools
tools = [
    Dict("name" => "Search", "description" => "Search the web for information", "ability" => "search_web"),
    Dict("name" => "Calculator", "description" => "Perform mathematical calculations", "ability" => "calculate"),
    Dict("name" => "DateTime", "description" => "Get the current date and time", "ability" => "get_datetime")
]

# Create a plan-and-execute agent
agent = create_plan_execute_agent("agent-12345", tools)

# Run the agent on a query
result = run_plan_execute_agent(agent, "What is the population of France divided by the square root of 16?")
=#

end # module PlanAndExecute

using DotEnv
DotEnv.load!()

using ...Resources: Gemini
using ..CommonTypes: ToolSpecification, ToolMetadata, ToolConfig


GEMINI_API_KEY = ENV["GEMINI_API_KEY"]
GEMINI_MODEL = "models/gemini-1.5-pro"

Base.@kwdef struct ToolLLMChatConfig <: ToolConfig
    api_key::String = GEMINI_API_KEY
    model_name::String = GEMINI_MODEL
    temperature::Float64 = 0.7
    max_output_tokens::Int = 1024
end

function tool_llm_chat(cfg::ToolLLMChatConfig, task::Dict)
    gemini_cfg = Gemini.GeminiConfig(
        api_key = cfg.api_key,
        model_name = cfg.model_name,
        temperature = cfg.temperature,
        max_output_tokens = cfg.max_output_tokens
    )

    if !haskey(task, "prompt") || !(task["prompt"] isa AbstractString)
        return Dict("success" => false, "error" => "Missing or invalid 'prompt' field")
    end

    try
        answer = Gemini.gemini_util(
            gemini_cfg,
            task["prompt"]
        )
        return Dict("output" => answer, "success" => true)
    catch e
        return Dict("success" => false, "error" => string(e))
    end
end

const TOOL_LLM_CHAT_METADATA = ToolMetadata(
    "llm_chat",
    "Sends a prompt to the configured LLM provider and returns the response."
)

const TOOL_LLM_CHAT_SPECIFICATION = ToolSpecification(
    tool_llm_chat,
    ToolLLMChatConfig,
    TOOL_LLM_CHAT_METADATA
)

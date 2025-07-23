using DotEnv
DotEnv.load!()

using ..CommonTypes: ToolConfig, ToolMetadata, ToolSpecification
using ...Resources: Gemini

GEMINI_API_KEY = ENV["GEMINI_API_KEY"]
GEMINI_MODEL = "models/gemini-1.5-pro"

Base.@kwdef struct ToolSummarizeConfig <: ToolConfig
    api_key::String = GEMINI_API_KEY
    model_name::String = GEMINI_MODEL
end

function tool_summarize_for_post(cfg::ToolSummarizeConfig, task::Dict)::Dict{String,Any}
    if !haskey(task, "text")
        return Dict("success" => false, "error" => "Missing article text")
    end

    prompt = """
    You are AI news bot. Your task is to summarize the following news article into a Twitter post (max 250 characters), focusing on the key idea.

    Article:
    $(task["text"])
    """

    gemini_cfg = Gemini.GeminiConfig(
        api_key = cfg.api_key,
        model_name = cfg.model_name,
        temperature = 0.7,
        max_output_tokens = 100
    )

    try
        post = Gemini.gemini_util(gemini_cfg, prompt)
        return Dict("success" => true, "post_text" => strip(post))
    catch e
        return Dict("success" => false, "error" => string(e))
    end
end

const TOOL_SUMMARIZE_FOR_POST_METADATA = ToolMetadata(
    "summarize_for_post",
    "Summarizes a full news article into a short post for X(Twitter)"
)

const TOOL_SUMMARIZE_FOR_POST_SPECIFICATION = ToolSpecification(
    tool_summarize_for_post,
    ToolSummarizeConfig,
    TOOL_SUMMARIZE_FOR_POST_METADATA
)

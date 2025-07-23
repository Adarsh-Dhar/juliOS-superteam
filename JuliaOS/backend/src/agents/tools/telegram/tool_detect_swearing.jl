using DotEnv
DotEnv.load!()

using ...Resources: Gemini
using ..CommonTypes: ToolSpecification, ToolMetadata, ToolConfig

GEMINI_API_KEY = ENV["GEMINI_API_KEY"]
GEMINI_MODEL = "models/gemini-1.5-pro"

Base.@kwdef struct ToolDetectSwearConfig <: ToolConfig
    api_key::String = GEMINI_API_KEY
    model_name::String = GEMINI_MODEL
    temperature::Float64 = 0.0
    max_output_tokens::Int = 64
end

function tool_detect_swearing(
    cfg::ToolDetectSwearConfig,
    text::String
)::Bool
    prompt = """
    You are a profanity detector. Answer with YES if the following user message contains profanity or hate speech; otherwise respond with NO.

    Message:
    $(text)
    """

    gemini_cfg = Gemini.GeminiConfig(
        api_key = cfg.api_key,
        model_name = cfg.model_name,
        temperature = cfg.temperature,
        max_output_tokens = cfg.max_output_tokens
    )

    raw = Gemini.gemini_util(
        gemini_cfg,
        prompt
    )

    normalized = lowercase(strip(raw))
    return startswith(normalized, "yes")
end

const TOOL_DETECT_SWEAR_METADATA = ToolMetadata(
    "detect_swearing",
    "Uses Gemini to classify whether a message contains profanity."
)

const TOOL_DETECT_SWEAR_SPECIFICATION = ToolSpecification(
    tool_detect_swearing,
    ToolDetectSwearConfig,
    TOOL_DETECT_SWEAR_METADATA
)

using DotEnv
DotEnv.load!()

using ...Resources: Gemini
using ..CommonTypes: ToolSpecification, ToolMetadata, ToolConfig


GEMINI_API_KEY = ENV["GEMINI_API_KEY"]
GEMINI_MODEL = "models/gemini-1.5-pro"

Base.@kwdef struct ToolBlogWriterConfig <: ToolConfig
    api_key::String = GEMINI_API_KEY
    model_name::String = GEMINI_MODEL
    temperature::Float64 = 0.7
    max_output_tokens::Int = 1024
end

const ALLOWED_FORMATS = Set(["plain", "markdown", "html"])
MAX_ATTEMPTS = 3

"""
    tool_write_blog(cfg::ToolBlogWriterConfig, task::Dict) -> Dict{String, Any}

Generates a structured blog post based on a given topic and optional settings.

# Arguments
- `cfg::ToolBlogWriterConfig`: Tool config.
- `task::Dict`: A dictionary with blog generation instructions.
    - Required key:
        - "title": The topic of the blog post.
    - Optional keys:
        - "tone": Tone of the blog post (e.g., "neutral", "formal", "casual", "humorous"). Default: "neutral".
        - "max_characters_amount": Maximum allowed character length for the post. Default: 500.
        - "output_format": Format of the returned content. One of: "plain", "markdown", "html". Default: "plain".

# Returns
A dictionary with the execution result.
"""
function tool_write_blog(cfg::ToolBlogWriterConfig, task::Dict)
    if !haskey(task, "title") || !(task["title"] isa AbstractString)
        return Dict("success" => false, "error" => "Missing or invalid 'topic'")
    elseif haskey(task, "output_format") && lowercase(task["output_format"]) ∉ ALLOWED_FORMATS
        return Dict("success" => false, "error" => "Invalid 'output_format'. Allowed formats: $(join(ALLOWED_FORMATS, ", "))")
    end

    title = task["title"]
    tone = get(task, "tone", "neutral")
    max_characters_amount = get(task, "max_characters_amount", 500)
    output_format = get(task, "output_format", "plain")

    prompt = """
    Write a blog post on the topic "$title" in a $tone tone.
    The post must contain maximun $(max_characters_amount) characters.
    Make it engaging and well-structured.
    Return the output in the following format: $output_format.
    """

    gemini_cfg = Gemini.GeminiConfig(
        api_key = cfg.api_key,
        model_name = cfg.model_name,
        temperature = cfg.temperature,
        max_output_tokens = cfg.max_output_tokens
    )

    for _ in 1:MAX_ATTEMPTS
        try
            answer = Gemini.gemini_util(gemini_cfg, prompt)

            if length(answer) ≤ max_characters_amount
                return Dict("output" => answer, "success" => true)
            end

        catch e
            return Dict("success" => false, "error" => string(e))
        end
    end

    return Dict(
        "success" => false, "error" => "Failed to generate a blog post within $(max_characters_amount) characters after $MAX_ATTEMPTS attempts."
    )
end

const TOOL_BLOG_WRITER_METADATA = ToolMetadata(
    "write_blog",
    "Generates a structured blog post based on a given topic and optional settings."
)

const TOOL_BLOG_WRITER_SPECIFICATION = ToolSpecification(
    tool_write_blog,
    ToolBlogWriterConfig,
    TOOL_BLOG_WRITER_METADATA
)

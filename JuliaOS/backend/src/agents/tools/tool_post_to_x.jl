using ..CommonTypes: ToolSpecification, ToolMetadata, ToolConfig
using PyCall, Conda


const tweepy = Ref{PyObject}()

function __init__()
    try
        tweepy[] = pyimport("tweepy")
    catch e
        @warn "tweepy not found, attempting installation via Conda.pip" exception = e
        Conda.pip_interop(true)
        Conda.pip("install", "tweepy==4.15.0")
        tweepy[] = pyimport("tweepy")
    end
end

Base.@kwdef struct ToolPostToXConfig <: ToolConfig
    api_key::String
    api_key_secret::String
    access_token::String
    access_token_secret::String 
end

"""
    tool_post_to_x(cfg::ToolPostToXConfig, task::Dict{String, String}) -> Dict{String, Any}

Posts a tweet with given text to X(Twitter).

# Arguments
- `cfg::ToolPostToXConfig`: Tool config.
- `task::Dict{String, String}`: A dictionary containing the data to post.

# Returns
A dictionary with the execution result.

# Notes
- The tweet text must not exceed 280 characters (as per Twitter/X limits).
"""
function tool_post_to_x(cfg::ToolPostToXConfig, task::Dict{String,String})::Dict{String,Any}
    if !haskey(task, "blog_text") || !(task["blog_text"] isa AbstractString)
        return Dict("success" => false, "error" => "Missing or invalid 'blog_text'")
    end

    tweet_text = task["blog_text"]

    client = tweepy[].Client(; 
        consumer_key = cfg.api_key,
        consumer_secret = cfg.api_key_secret,
        access_token = cfg.access_token,
        access_token_secret = cfg.access_token_secret
    )

    try
        response = client.create_tweet(text = tweet_text)
        return Dict("success" => true, "result" => response)
    catch e
        return Dict("success" => false, "error" => string(e))
    end
end

const TOOL_POST_TO_X_METADATA = ToolMetadata(
    "post_to_x",
    "Posts a tweet with given text to X(Twitter)."
)

const TOOL_POST_TO_X_SPECIFICATION = ToolSpecification(
    tool_post_to_x,
    ToolPostToXConfig,
    TOOL_POST_TO_X_METADATA
)



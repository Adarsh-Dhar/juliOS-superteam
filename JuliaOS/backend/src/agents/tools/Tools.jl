module Tools

export TOOL_REGISTRY

include("tool_example_adder.jl")
include("tool_ping.jl")
include("tool_llm_chat.jl")
include("tool_write_blog.jl")
include("tool_post_to_x.jl")
include("telegram/tool_ban_user.jl")
include("telegram/tool_detect_swearing.jl")
include("telegram/tool_send_message.jl")
include("tool_scrape_article_text.jl")
include("tool_summarize_for_post.jl")

using ..CommonTypes: ToolSpecification

const TOOL_REGISTRY = Dict{String, ToolSpecification}()

function register_tool(tool_spec::ToolSpecification)
    tool_name = tool_spec.metadata.name
    if haskey(TOOL_REGISTRY, tool_name)
        error("Tool with name '$tool_name' is already registered.")
    end
    TOOL_REGISTRY[tool_name] = tool_spec
end

# All tools to be used by agents must be registered here:

register_tool(TOOL_BLOG_WRITER_SPECIFICATION)
register_tool(TOOL_POST_TO_X_SPECIFICATION)
register_tool(TOOL_EXAMPLE_ADDER_SPECIFICATION)
register_tool(TOOL_LLM_CHAT_SPECIFICATION)
register_tool(TOOL_PING_SPECIFICATION)
register_tool(TOOL_BAN_USER_SPECIFICATION)
register_tool(TOOL_DETECT_SWEAR_SPECIFICATION)
register_tool(TOOL_SEND_MESSAGE_SPECIFICATION)
register_tool(TOOL_SCRAPE_ARTICLE_TEXT_SPECIFICATION)
register_tool(TOOL_SUMMARIZE_FOR_POST_SPECIFICATION)

end
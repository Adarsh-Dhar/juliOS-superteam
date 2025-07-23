using ..CommonTypes: StrategyConfig, AgentContext, StrategySpecification, StrategyMetadata, StrategyInput

Base.@kwdef struct StrategyBlogWriterConfig <: StrategyConfig
end

Base.@kwdef struct BloggerInput <: StrategyInput
    title::String
    tone::String
    max_characters_amount::Int
    output_format::String
end

function strategy_blogger(
        cfg::StrategyBlogWriterConfig,
        ctx::AgentContext,
        input::BloggerInput
    )
    if isnothing(input.title) || isempty(input.title)
        push!(ctx.logs, "ERROR: Input must contain non-empty 'title'.")
        return ctx
    end

    title = input.title
    tone = input.tone
    max_characters_amount = input.max_characters_amount
    output_format = input.output_format

    write_blog_index  = findfirst(tool -> tool.metadata.name == "write_blog", ctx.tools)
    if write_blog_index === nothing
        push!(ctx.logs, "ERROR: write_blog tool not found.")
        return ctx
    end
    blog_writer_tool = ctx.tools[write_blog_index]
    
    push!(ctx.logs, "Writing blog post with:\ntitle: $title \ntone: $tone \nmax characters amount: $max_characters_amount \noutput format: $output_format")
    post_generation_result = nothing
    try
        post_generation_result = blog_writer_tool.execute(
            blog_writer_tool.config, 
            Dict(
                "title" => input.title,
                "tone" => input.tone,
                "output_format" => input.output_format,
                "max_characters_amount" => input.max_characters_amount
            )
        )
        push!(ctx.logs, "Blog post '$title' written successfully.")
        push!(ctx.logs, "Blog content: \n$(post_generation_result["output"])")
    catch e
        push!(ctx.logs, "ERROR: Blog writing failed: $(post_generation_result["error"])")
        return ctx
    end    

    post_to_x_index = findfirst(t -> t.metadata.name == "post_to_x", ctx.tools)
    if post_to_x_index === nothing
        push!(ctx.logs, "post_to_x tool not found — skipping post.")
        return ctx
    end
    post_tool = ctx.tools[post_to_x_index]

    push!(ctx.logs, "Posting to X...")
    try
        result = post_tool.execute(post_tool.config, Dict("blog_text" => post_generation_result["output"]))
        if result["success"]
            push!(ctx.logs, "Posted to X successfully.")
        else
            push!(ctx.logs, "ERROR: Failed to post to X: $(result["error"])")
        end
    catch e
        push!(ctx.logs, "ERROR: Exception during X post: $e")
    end

    return ctx
end

const STRATEGY_BLOG_WRITER_METADATA = StrategyMetadata(
    "blogger"
)

const STRATEGY_BLOG_WRITER_SPECIFICATION = StrategySpecification(
    strategy_blogger,
    nothing,
    StrategyBlogWriterConfig,
    STRATEGY_BLOG_WRITER_METADATA,
    BloggerInput
)

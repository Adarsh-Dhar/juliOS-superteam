using ..CommonTypes: ToolConfig, ToolMetadata, ToolSpecification
using Gumbo, Cascadia, HTTP


Base.@kwdef struct ToolScrapeArticleConfig <: ToolConfig
end

function extract_article_text(html::String)::String
    parsed = parsehtml(html)
    body = parsed.root

    candidates = eachmatch(Selector("article > p, div > p"), body)
    texts = [strip(text(p)) for p in candidates if length(strip(text(p))) > 100]

    return join(texts, "\n\n")
end

function tool_scrape_article_text(cfg::ToolScrapeArticleConfig, task::Dict)::Dict{String,Any}
    if !haskey(task, "url")
        return Dict("success" => false, "error" => "Missing url")
    end

    try
        response = HTTP.get(task["url"]; readtimeout=10)
        html = String(response.body)
        extracted_text = extract_article_text(html)
        if isempty(extracted_text)
            return Dict("success" => false, "error" => "No article text found")
        end
        return Dict("success" => true, "text" => extracted_text)
    catch e
        @error "Error scraping article text: $e"
        return Dict("success" => false, "error" => string(e))
    end
end

const TOOL_SCRAPE_ARTICLE_TEXT_METADATA = ToolMetadata(
    "scrape_article_text",
    "Extracts main content from a news article URL"
)

const TOOL_SCRAPE_ARTICLE_TEXT_SPECIFICATION = ToolSpecification(
    tool_scrape_article_text,
    ToolScrapeArticleConfig,
    TOOL_SCRAPE_ARTICLE_TEXT_METADATA
)

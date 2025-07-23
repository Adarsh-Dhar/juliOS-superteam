module Gemini

using HTTP
using JSON

export GeminiConfig, gemini_util

@kwdef struct GeminiConfig
    api_key::String
    model_name::String
    temperature::Float64 = 0.0
    max_output_tokens::Int = 256
end

"""
    gemini_util(cfg::GeminiConfig, prompt::String) :: String

Sends prompt to Gemini’s API and returns its text completion.
"""
function gemini_util(
    cfg::GeminiConfig,
    prompt::String
)::String
    endpoint_url = "https://generativelanguage.googleapis.com/v1beta/$(cfg.model_name):generateContent?key=$(cfg.api_key)"

    body_dict = Dict(
        "contents" => [
            Dict("parts" => [ Dict("text" => prompt) ])
        ],
        "generationConfig" => Dict(
            "temperature"      => cfg.temperature,
            "maxOutputTokens"  => cfg.max_output_tokens
        )
    )
    request_body = JSON.json(body_dict)

    resp = HTTP.request(
        "POST",
        endpoint_url;
        headers = ["Content-Type" => "application/json"],
        body = request_body
    )

    if resp.status != 200
        error("Gemini generateContent failed with status $(resp.status): $(String(resp.body))")
    end

    resp_json = JSON.parse(String(resp.body))

    if !haskey(resp_json, "candidates") || isempty(resp_json["candidates"])
        error("Gemini response missing 'candidates' or the list is empty.")
    end
    first_candidate = resp_json["candidates"][1]

    if !haskey(first_candidate, "content") ||
       !haskey(first_candidate["content"], "parts") ||
       isempty(first_candidate["content"]["parts"])
        error("Gemini response’s first candidate missing 'content.parts'.")
    end

    generated_text = first_candidate["content"]["parts"][1]["text"]
    return generated_text
end

end

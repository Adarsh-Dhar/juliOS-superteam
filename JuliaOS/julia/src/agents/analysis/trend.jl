# Agents/TrendAnalyzer.jl
# Define TrendAgent directly in server context

# Import the required modules from the server context
using TextAnalysis, SparseArrays, MultivariateStats, Clustering, TSne
using JSON3, Dates, Languages, StatsBase, Random

# Define the agent struct
struct TrendAgent
    id::String
    config::Dict
    stopwords::Vector{String}
    topic_model
    cooldown_until::DateTime
end

function TrendAgent(id::String, config::Dict)
    # Load stopwords (simplified)
    stopwords = String[]
    
    # Initialize topic model (simplified)
    topic_model = Dict("n_topics" => 10, "vocabulary" => Dict{String, Int}())
    
    # Initialize cooldown
    cooldown_until = now()
    
    # Create the struct directly
    return TrendAgent(id, config, stopwords, topic_model, cooldown_until)
end

function run(agent::TrendAgent)
    # Register with reputation system
    ReputationKeeper.stake(agent.id, 0.1)
    
    # Model refresh timer
    last_refresh = now()
    
    while true
        # Check for model refresh
        if now() - last_refresh > Hour(1)
            refresh_model!(agent)
            last_refresh = now()
        end
        
        # Wait for new content messages
        msg = SwarmComms.receive("trend_analyzer", timeout=10)
        
        if msg !== nothing && msg.type == "new_content"
            if now() > agent.cooldown_until
                process_content(agent, msg)
            else
                @warn "Trend analyzer in cooldown until $(agent.cooldown_until)"
            end
        elseif msg !== nothing && msg.type == "shutdown"
            break
        end
    end
end

function process_content(agent::TrendAgent, msg)
    try
        # Fetch content from IPFS
        data = IPFS.cat(msg.cid)
        content = JSON3.read(data)
        
        # Extract texts and metadata
        texts = [item.text for item in content]
        timestamps = [DateTime(item.created_at) for item in content]
        sources = [item.source for item in content]
        
        # Process texts
        processed_texts = preprocess_batch(texts, agent.stopwords)
        
        # Detect trends
        trend_report = detect_trends(agent, processed_texts, timestamps, sources)
        
        # Store results on IPFS
        result_json = JSON3.write(trend_report)
        result_cid = IPFS.add(result_json)
        
        # Send to next stage
        SwarmComms.send("dashboard_renderer", Dict(
            "type" => "trend_report",
            "source" => "trend_analyzer",
            "result_cid" => result_cid,
            "agent_id" => agent.id
        ))
        
        # Report success
        ReputationKeeper.report(agent.id, "trend_analysis_success", 
                               Dict("trend_count" => length(trend_report.trends)))
        
    catch e
        # Enter cooldown on error
        agent.cooldown_until = now() + Minute(5)
        ReputationKeeper.report(agent.id, "trend_analysis_failure", 
                               Dict("error" => string(e), "cooldown_until" => agent.cooldown_until))
    end
end

function preprocess_batch(texts::Vector{String}, stopwords::Vector{String})
    corpus = Corpus(texts)
    prepare!(corpus, strip_punctuation | strip_numbers | strip_non_letters | strip_stopwords(stopwords))
    stem!(corpus)
    return corpus
end

function detect_trends(agent::TrendAgent, corpus, timestamps, sources)
    # Create document-term matrix
    dtm = DocumentTermMatrix(corpus)
    
    # Update topic model
    update_model!(agent.topic_model, dtm)
    
    # Extract topics
    topics = extract_topics(agent.topic_model, dtm)
    
    # Analyze temporal patterns
    time_series = analyze_temporal(topics, timestamps)
    
    # Detect emerging trends
    trends = find_emerging_trends(time_series)
    
    # Cross-source validation
    validated = validate_across_sources(trends, sources)
    
    # Build report
    return Dict(
        "period_start" => minimum(timestamps),
        "period_end" => maximum(timestamps),
        "total_documents" => length(corpus),
        "topics" => topics,
        "trends" => validated
    )
end

function analyze_temporal(topics, timestamps)
    # Create time buckets (e.g., 15-minute intervals)
    time_buckets = create_time_buckets(timestamps, Minute(15))
    
    # Count topic frequency per bucket
    topic_series = Dict{Int, Vector{Int}}()
    for (topic_id, doc_ids) in topics
        counts = zeros(Int, length(time_buckets))
        for doc_id in doc_ids
            bucket = find_bucket(timestamps[doc_id], time_buckets)
            counts[bucket] += 1
        end
        topic_series[topic_id] = counts
    end
    
    return topic_series
end

function create_time_buckets(timestamps::Vector{DateTime}, interval::Period)
    if isempty(timestamps)
        return DateTime[]
    end
    
    start_time = minimum(timestamps)
    end_time = maximum(timestamps)
    
    buckets = DateTime[]
    current = start_time
    while current <= end_time
        push!(buckets, current)
        current += interval
    end
    
    return buckets
end

function find_bucket(timestamp::DateTime, buckets::Vector{DateTime})
    if isempty(buckets)
        return 1
    end
    
    for (i, bucket) in enumerate(buckets)
        if timestamp < bucket
            return max(1, i - 1)
        end
    end
    
    return length(buckets)
end

function find_emerging_trends(topic_series)
    trends = []
    for (topic_id, counts) in topic_series
        # Simple trend detection: exponential growth
        if length(counts) > 3
            growth_rate = (counts[end] - counts[end-1]) / (counts[end-1] + 1)
            if growth_rate > 2.0  # 200% growth
                velocity = growth_rate
                acceleration = (growth_rate - ((counts[end-1] - counts[end-2]) / (counts[end-2] + 1)))
                
                push!(trends, Dict(
                    "topic_id" => topic_id,
                    "current_volume" => counts[end],
                    "growth_rate" => growth_rate,
                    "acceleration" => acceleration,
                    "peak_time" => now()
                ))
            end
        end
    end
    
    # Sort by growth rate
    sort!(trends, by=x->x["growth_rate"], rev=true)
    return trends
end

function validate_across_sources(trends, sources)
    # Simple validation - in production, implement cross-source validation
    validated = []
    for trend in trends
        # Mock validation - just return the trend as-is
        push!(validated, trend)
    end
    return validated
end

# Initialize LDA model
function initialize_model()
    # Use a simple document-term matrix approach for now
    # In a real implementation, you'd use a proper LDA library
    return Dict(
        "n_topics" => 10,
        "vocabulary" => Dict{String, Int}(),
        "topic_assignments" => Dict{Int, Vector{Int}}()
    )
end

# Update model incrementally
function update_model!(model, dtm)
    # Simple vocabulary update
    for term in dtm.terms
        if !haskey(model["vocabulary"], term)
            model["vocabulary"][term] = length(model["vocabulary"]) + 1
        end
    end
end

# Extract topics with threshold
function extract_topics(model, dtm; threshold=0.15)
    topic_assignments = Dict{Int, Vector{Int}}()
    
    # Simple topic assignment based on term frequency
    for i in 1:dtm.ndocs
        # Find the most frequent term in this document
        doc_terms = dtm.dtm[i, :]
        if !isempty(doc_terms.nzval)
            max_term_idx = doc_terms.nzind[argmax(doc_terms.nzval)]
            topic_id = max_term_idx % 10 + 1  # Simple hash-based topic assignment
            
            if !haskey(topic_assignments, topic_id)
                topic_assignments[topic_id] = []
            end
            push!(topic_assignments[topic_id], i)
        end
    end
    
    return topic_assignments
end

# Mock topic distribution function
function topic_distribution(model, doc_idx)
    # Return uniform distribution for now
    return ones(Float32, 10) ./ 10
end

function load_stopwords(languages)
    all_stopwords = String[]
    for lang in languages
        try
            stopwords = Languages.stopwords(Languages.getlanguage(lang))
            append!(all_stopwords, stopwords)
        catch
            @warn "Stopwords not available for $lang"
        end
    end
    
    # Add platform-specific noise words
    push!(all_stopwords, "rt", "http", "https", "com", "www")
    return unique(all_stopwords)
end
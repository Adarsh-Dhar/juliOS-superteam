#!/usr/bin/env julia

# Demo: Consensus Verification with Reddit Data
using JSON3, Dates, Random, Statistics

println("🎯 Demo: Consensus Verification with Reddit Data")
println(repeat("=", 60))

# Personality traits structure
struct PersonalityTraits
    bot_skepticism::Float64
    manipulation_sensitivity::Float64
    authenticity_optimism::Float64
    novelty_preference::Float64
    conformity_bias::Float64
    risk_aversion::Float64
end

# Consensus agent structure
mutable struct ConsensusAgent
    id::String
    personality::PersonalityTraits
    reputation::Float64
    stake::Float64
    total_verifications::Int
    successful_verifications::Int
    error_count::Int
end

# Create personality traits
function create_personality()
    return PersonalityTraits(
        rand(0.7:0.05:1.3),      # bot_skepticism
        rand(0.5:0.05:1.5),      # manipulation_sensitivity
        rand(0.6:0.05:1.4),      # authenticity_optimism
        rand(0.8:0.05:1.2),      # novelty_preference
        rand(0.3:0.05:0.7),      # conformity_bias
        rand(0.4:0.05:1.1)       # risk_aversion
    )
end

# Create consensus agent
function create_consensus_agent(id::String)
    personality = create_personality()
    reputation = rand(60.0:1.0:90.0)
    stake = rand(0.05:0.01:0.2)
    
    return ConsensusAgent(
        id, personality, reputation, stake, 0, 0, 0
    )
end

# Sample Reddit data for verification
function get_reddit_data_for_verification()
    reddit_data = [
        Dict(
            "id" => "1mbsu4d",
            "title" => "Dating a married woman",
            "subreddit" => "nonmonogamy",
            "score" => 15,
            "num_comments" => 8,
            "author" => "Altruistic-Smile-471",
            "account_age" => 45,  # days
            "post_frequency" => 2.3,  # posts per day
            "content_novelty" => 0.7,
            "engagement_rate" => 0.23,
            "temporal_anomaly" => 0.1,
            "language_complexity" => 0.6,
            "sentiment_score" => -0.3,
            "network_connectivity" => 0.4,
            "response_time" => 120,  # seconds
            "content_length" => 150,
            "hashtag_usage" => 0,
            "mention_pattern" => 0,
            "link_ratio" => 0,
            "emoji_usage" => 0,
            "bot_score" => 0.2
        ),
        Dict(
            "id" => "1mbsu4c",
            "title" => "how do i help?",
            "subreddit" => "EatingDisorders",
            "score" => 23,
            "num_comments" => 12,
            "author" => "Waste-Bug-3197",
            "account_age" => 12,
            "post_frequency" => 1.8,
            "content_novelty" => 0.8,
            "engagement_rate" => 0.35,
            "temporal_anomaly" => 0.2,
            "language_complexity" => 0.5,
            "sentiment_score" => 0.1,
            "network_connectivity" => 0.3,
            "response_time" => 300,
            "content_length" => 120,
            "hashtag_usage" => 0,
            "mention_pattern" => 0,
            "link_ratio" => 0,
            "emoji_usage" => 0,
            "bot_score" => 0.3
        ),
        Dict(
            "id" => "1mbsu4b",
            "title" => "Where do these hoses connect to?",
            "subreddit" => "Miata",
            "score" => 45,
            "num_comments" => 18,
            "author" => "easykill2517",
            "account_age" => 180,
            "post_frequency" => 0.5,
            "content_novelty" => 0.9,
            "engagement_rate" => 0.63,
            "temporal_anomaly" => 0.05,
            "language_complexity" => 0.7,
            "sentiment_score" => 0.2,
            "network_connectivity" => 0.6,
            "response_time" => 60,
            "content_length" => 200,
            "hashtag_usage" => 0,
            "mention_pattern" => 0,
            "link_ratio" => 0,
            "emoji_usage" => 0,
            "bot_score" => 0.1
        ),
        Dict(
            "id" => "1mbsu4a",
            "title" => "Would you rather…",
            "subreddit" => "ChuckleSandwich",
            "score" => 67,
            "num_comments" => 34,
            "author" => "supersmallpee",
            "account_age" => 30,
            "post_frequency" => 3.2,
            "content_novelty" => 0.6,
            "engagement_rate" => 1.01,
            "temporal_anomaly" => 0.15,
            "language_complexity" => 0.4,
            "sentiment_score" => 0.0,
            "network_connectivity" => 0.5,
            "response_time" => 45,
            "content_length" => 80,
            "hashtag_usage" => 0,
            "mention_pattern" => 0,
            "link_ratio" => 0,
            "emoji_usage" => 0,
            "bot_score" => 0.4
        ),
        Dict(
            "id" => "1mbsu49",
            "title" => "Warning: Crimson glitch can also permanently reduce your hand size",
            "subreddit" => "balatro",
            "score" => 89,
            "num_comments" => 56,
            "author" => "misterrandom1",
            "account_age" => 90,
            "post_frequency" => 1.2,
            "content_novelty" => 0.95,
            "engagement_rate" => 1.45,
            "temporal_anomaly" => 0.25,
            "language_complexity" => 0.8,
            "sentiment_score" => -0.4,
            "network_connectivity" => 0.7,
            "response_time" => 90,
            "content_length" => 250,
            "hashtag_usage" => 0,
            "mention_pattern" => 0,
            "link_ratio" => 0,
            "emoji_usage" => 0,
            "bot_score" => 0.15
        )
    ]
    
    return reddit_data
end

# Apply personality to features
function apply_personality(agent::ConsensusAgent, features::Dict)
    personalized_features = copy(features)
    
    # Bot-skeptical agents discount account age
    if haskey(personalized_features, "account_age")
        personalized_features["account_age"] *= agent.personality.bot_skepticism
    end
    
    # Novelty-seeking agents amplify new patterns
    if agent.personality.novelty_preference > 1.0 && haskey(personalized_features, "content_novelty")
        personalized_features["content_novelty"] *= 1.5
    end
    
    # Risk-averse agents focus on anomalies
    if agent.personality.risk_aversion > 0.8 && haskey(personalized_features, "temporal_anomaly")
        personalized_features["temporal_anomaly"] *= 2.0
    end
    
    return personalized_features
end

# Convert features to vector
function features_to_vector(features::Dict)
    feature_order = [
        "account_age", "post_frequency", "content_novelty", "engagement_rate",
        "temporal_anomaly", "language_complexity", "sentiment_score",
        "network_connectivity", "response_time", "content_length",
        "hashtag_usage", "mention_pattern", "link_ratio", "emoji_usage", "bot_score"
    ]
    
    vector = zeros(15)
    for (i, feature) in enumerate(feature_order)
        vector[i] = get(features, feature, 0.0)
    end
    
    return vector
end

# Simple neural network simulation
function simulate_model_prediction(input_vector::Vector{Float64})
    # Simple weighted sum simulation
    weights = rand(15)
    bias = rand()
    
    output = sum(input_vector .* weights) + bias
    output = 1 / (1 + exp(-output))  # Sigmoid
    
    # Return 3 scores (bot, manip, auth)
    return [output, 1 - output, 0.5 + 0.1 * randn()]
end

# Convert scores to votes
function scores_to_votes(agent::ConsensusAgent, scores::Vector{Float64})
    thresholds = (
        bot = 0.6 / agent.personality.bot_skepticism,
        manip = 0.55 / agent.personality.manipulation_sensitivity,
        auth = 0.65 * agent.personality.authenticity_optimism
    )
    
    if agent.personality.risk_aversion > 0.8
        thresholds = (
            bot = thresholds.bot + 0.1,
            manip = thresholds.manip + 0.1,
            auth = thresholds.auth - 0.1
        )
    end
    
    return (
        bot = scores[1] > thresholds.bot,
        manip = scores[2] > thresholds.manip,
        auth = scores[3] > thresholds.auth
    )
end

# Verify content
function verify_content(agent::ConsensusAgent, content_data::Dict)
    try
        # Apply personality to features
        personalized_features = apply_personality(agent, content_data)
        
        # Convert to vector
        input_vector = features_to_vector(personalized_features)
        
        # Get model predictions
        scores = simulate_model_prediction(input_vector)
        
        # Convert to votes
        votes = scores_to_votes(agent, scores)
        
        # Update agent state
        agent.total_verifications += 1
        agent.successful_verifications += 1
        
        return votes
        
    catch e
        agent.error_count += 1
        return nothing
    end
end

# Calculate consensus
function calculate_consensus(votes::Vector)
    valid_votes = filter(v -> v !== nothing, votes)
    
    if isempty(valid_votes)
        return (bot=false, manip=false, auth=false, confidence=0.0)
    end
    
    bot_percent = mean([v.bot for v in valid_votes])
    manip_percent = mean([v.manip for v in valid_votes])
    auth_percent = mean([v.auth for v in valid_votes])
    
    thresholds = (bot=0.65, manip=0.6, auth=0.7)
    
    return (
        bot = bot_percent > thresholds.bot,
        manip = manip_percent > thresholds.manip,
        auth = auth_percent > thresholds.auth,
        confidence = min(bot_percent, manip_percent, auth_percent)
    )
end

# Main consensus verification function
function verify_content_swarm(posts::Vector{Dict{String, Any}}, num_agents::Int=5)
    println("📊 Step 1: Creating consensus swarm...")
    agents = [create_consensus_agent("consensus_$i") for i in 1:num_agents]
    println("✅ Created $(length(agents)) consensus agents")
    
    println("\n📊 Step 2: Processing content for verification...")
    all_votes = []
    agent_results = []
    
    for (post_idx, post) in enumerate(posts)
        println("  Processing post $(post_idx): $(post["title"])")
        
        post_votes = []
        for (agent_idx, agent) in enumerate(agents)
            votes = verify_content(agent, post)
            push!(post_votes, votes)
            
            if votes !== nothing
                push!(agent_results, Dict(
                    "agent_id" => agent.id,
                    "post_id" => post["id"],
                    "votes" => votes,
                    "reputation" => agent.reputation,
                    "stake" => agent.stake
                ))
            end
        end
        
        push!(all_votes, post_votes)
    end
    
    println("\n📊 Step 3: Calculating consensus...")
    consensus_results = []
    
    for (post_idx, post_votes) in enumerate(all_votes)
        consensus = calculate_consensus(post_votes)
        push!(consensus_results, Dict(
            "post_id" => posts[post_idx]["id"],
            "title" => posts[post_idx]["title"],
            "consensus" => consensus,
            "total_votes" => length(filter(v -> v !== nothing, post_votes))
        ))
    end
    
    return Dict(
        "agents" => agents,
        "consensus_results" => consensus_results,
        "agent_results" => agent_results
    )
end

# Main demo function
function demo_consensus_verification()
    println("🎯 Demo: Consensus Verification with Reddit Data")
    println(repeat("=", 60))
    
    # Get sample data
    posts = get_reddit_data_for_verification()
    
    # Run consensus verification
    results = verify_content_swarm(posts, 5)
    
    println("\n📈 Consensus Verification Results:")
    println("  Total agents: $(length(results["agents"]))")
    println("  Total posts verified: $(length(results["consensus_results"]))")
    println("  Total agent decisions: $(length(results["agent_results"]))")
    
    println("\n📊 Agent Statistics:")
    for agent in results["agents"]
        success_rate = agent.total_verifications > 0 ? 
            agent.successful_verifications / agent.total_verifications : 0.0
        
        println("  $(agent.id):")
        println("    Reputation: $(round(agent.reputation, digits=1))")
        println("    Stake: $(round(agent.stake, digits=3))")
        println("    Verifications: $(agent.total_verifications)")
        println("    Success rate: $(round(success_rate * 100, digits=1))%")
        println("    Personality: bot_skepticism=$(round(agent.personality.bot_skepticism, digits=2))")
        println()
    end
    
    println("\n📊 Consensus Results:")
    for (i, result) in enumerate(results["consensus_results"])
        consensus = result["consensus"]
        println("  $(i). $(result["title"])")
        println("     Bot detected: $(consensus.bot)")
        println("     Manipulation detected: $(consensus.manip)")
        println("     Authentic: $(consensus.auth)")
        println("     Confidence: $(round(consensus.confidence * 100, digits=1))%")
        println("     Total votes: $(result["total_votes"])")
        println()
    end
    
    println("\n📊 Agent Decision Patterns:")
    for agent in results["agents"]
        agent_decisions = filter(r -> r["agent_id"] == agent.id, results["agent_results"])
        
        if !isempty(agent_decisions)
            bot_votes = sum([d["votes"].bot for d in agent_decisions])
            manip_votes = sum([d["votes"].manip for d in agent_decisions])
            auth_votes = sum([d["votes"].auth for d in agent_decisions])
            
            println("  $(agent.id):")
            println("    Bot votes: $bot_votes/$(length(agent_decisions))")
            println("    Manipulation votes: $manip_votes/$(length(agent_decisions))")
            println("    Authentic votes: $auth_votes/$(length(agent_decisions))")
            println()
        end
    end
    
    return results
end

# Run the demo
if abspath(PROGRAM_FILE) == @__FILE__
    result = demo_consensus_verification()
    println("🎉 Consensus verification demo completed successfully!")
    println("📊 Consensus verification with Reddit data is working!")
end

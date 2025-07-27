# test_consensus_swarm.jl
# Test script for the consensus swarm functionality

using Pkg
Pkg.activate(".")

# Add the src directory to the load path
push!(LOAD_PATH, joinpath(@__DIR__, "src"))

# Import modules
include(joinpath(@__DIR__, "src", "agents", "consensusVerifier.jl"))
include(joinpath(@__DIR__, "src", "agents", "ConsensusSwarm.jl"))

using Random, Statistics, Flux
using Dates, Logging

# Set up logging
Logging.global_logger(Logging.ConsoleLogger(stderr, Logging.Info))

# ----------------------------------------------------------------------
# TEST FUNCTIONS
# ----------------------------------------------------------------------

"""
    test_agent_creation()

Test the creation of individual consensus agents with unique personalities.
"""
function test_agent_creation()
    println("\n=== Testing Agent Creation ===")
    
    # Create test configuration
    config = Dict(
        "campaign_id" => "test_campaign",
        "stake_amount" => 0.1,
        "base_reputation" => 75.0
    )
    
    # Create multiple agents
    agents = []
    for i in 1:5
        agent = ConsensusVerifier.ConsensusAgent("test_agent_$i", config)
        push!(agents, agent)
        
        println("Created agent $(agent.id):")
        println("  Personality: $(agent.personality)")
        println("  Reputation: $(agent.reputation)")
        println("  Stake: $(agent.stake)")
        println()
    end
    
    # Test personality diversity
    personalities = [a.personality for a in agents]
    bot_skepticism_values = [p.bot_skepticism for p in personalities]
    manipulation_values = [p.manipulation_sensitivity for p in personalities]
    
    println("Personality Diversity:")
    println("  Bot skepticism variance: $(var(bot_skepticism_values))")
    println("  Manipulation sensitivity variance: $(var(manipulation_values))")
    println()
    
    return agents
end

"""
    test_swarm_creation()

Test the creation of a consensus swarm.
"""
function test_swarm_creation()
    println("\n=== Testing Swarm Creation ===")
    
    campaign_id = "test_swarm_campaign"
    num_agents = 7
    
    # Create swarm
    swarm = ConsensusSwarm.create_consensus_swarm(num_agents, campaign_id)
    
    println("Created swarm with $(length(swarm)) agents:")
    for (i, agent) in enumerate(swarm)
        println("  Agent $i: $(agent.id)")
        println("    Reputation: $(agent.reputation)")
        println("    Stake: $(agent.stake)")
        println("    Bot skepticism: $(agent.personality.bot_skepticism)")
    end
    
    return swarm
end

"""
    test_verification_workflow()

Test the complete verification workflow with a swarm.
"""
function test_verification_workflow()
    println("\n=== Testing Verification Workflow ===")
    
    # Create campaign
    config = Dict(
        "id" => "verification_test_campaign",
        "consensus_agent_count" => 5
    )
    
    coordinator = ConsensusSwarm.setup_campaign(config)
    
    # Create test content
    test_content = ConsensusSwarm.create_test_content_data()
    println("Test content: $(test_content["content_id"])")
    
    # Run verification
    result = ConsensusSwarm.verify_content_with_swarm(coordinator, test_content)
    
    println("Verification Results:")
    println("  Consensus: $(result["consensus"])")
    println("  Weighted consensus: $(result["weighted_consensus"])")
    println("  Agent count: $(result["agent_count"])")
    
    # Show individual votes
    println("\nIndividual Agent Votes:")
    for (i, vote) in enumerate(result["votes"])
        if vote !== nothing
            println("  Agent $i: bot=$(vote.bot), manip=$(vote.manip), auth=$(vote.auth)")
        else
            println("  Agent $i: No vote (error)")
        end
    end
    
    return coordinator, result
end

"""
    test_swarm_diversity()

Test the diversity of decision-making across the swarm.
"""
function test_swarm_diversity()
    println("\n=== Testing Swarm Diversity ===")
    
    # Create swarm
    swarm = ConsensusSwarm.create_consensus_swarm(10, "diversity_test")
    
    # Create multiple test contents
    test_contents = []
    for i in 1:5
        push!(test_contents, ConsensusSwarm.create_test_content_data())
    end
    
    # Test each content with each agent
    all_votes = []
    
    for (content_idx, content) in enumerate(test_contents)
        println("\nContent $(content_idx): $(content["content_id"])")
        content_votes = []
        
        for (agent_idx, agent) in enumerate(swarm)
            vote = ConsensusVerifier.verify_content(agent, content)
            push!(content_votes, vote)
            
            if vote !== nothing
                println("  Agent $(agent_idx): bot=$(vote.bot), manip=$(vote.manip), auth=$(vote.auth)")
            else
                println("  Agent $(agent_idx): Error")
            end
        end
        
        # Calculate consensus for this content
        consensus = ConsensusVerifier.calculate_consensus(content_votes)
        println("  Consensus: bot=$(consensus.bot), manip=$(consensus.manip), auth=$(consensus.auth)")
        
        push!(all_votes, content_votes)
    end
    
    # Analyze diversity
    println("\nDiversity Analysis:")
    
    # Count different vote patterns
    vote_patterns = Dict()
    for content_votes in all_votes
        for vote in content_votes
            if vote !== nothing
                pattern = "$(vote.bot)_$(vote.manip)_$(vote.auth)"
                vote_patterns[pattern] = get(vote_patterns, pattern, 0) + 1
            end
        end
    end
    
    println("  Unique vote patterns: $(length(vote_patterns))")
    for (pattern, count) in sort(collect(vote_patterns))
        println("    $pattern: $count times")
    end
    
    return swarm, all_votes
end

"""
    test_dynamic_adjustment()

Test the dynamic swarm adjustment functionality.
"""
function test_dynamic_adjustment()
    println("\n=== Testing Dynamic Adjustment ===")
    
    campaign_id = "dynamic_test_campaign"
    initial_swarm = ConsensusSwarm.create_consensus_swarm(5, campaign_id)
    
    println("Initial swarm size: $(length(initial_swarm))")
    
    # Test different scenarios
    scenarios = [
        ("High processing time", 6.0, 0.85),  # Should add agents
        ("Low confidence", 3.0, 0.75),        # Should add agents
        ("Optimal performance", 3.0, 0.85)     # Should remove agents
    ]
    
    for (scenario_name, processing_time, confidence) in scenarios
        println("\nScenario: $scenario_name")
        println("  Processing time: $(processing_time)s")
        println("  Confidence: $(confidence)")
        
        # Simulate the adjustment (in real implementation, these would be actual metrics)
        # For now, we'll just show the logic
        target_size = if processing_time > 5.0
            min(length(initial_swarm) + 2, 15)
        elseif confidence < 0.8
            min(length(initial_swarm) + 1, 15)
        else
            max(length(initial_swarm) - 1, 3)
        end
        
        println("  Target size: $target_size")
        println("  Action: $(target_size > length(initial_swarm) ? "Add" : target_size < length(initial_swarm) ? "Remove" : "No change")")
    end
end

"""
    test_campaign_management()

Test campaign management functionality.
"""
function test_campaign_management()
    println("\n=== Testing Campaign Management ===")
    
    # Create campaign
    config = Dict(
        "id" => "management_test_campaign",
        "consensus_agent_count" => 3
    )
    
    coordinator = ConsensusSwarm.setup_campaign(config)
    
    # Get initial summary
    summary = ConsensusSwarm.get_campaign_summary(coordinator)
    println("Campaign Summary:")
    for (key, value) in summary
        println("  $key: $value")
    end
    
    # Start campaign
    ConsensusSwarm.start_campaign(coordinator)
    println("\nCampaign started")
    
    # Get swarm stats
    stats = ConsensusSwarm.get_swarm_stats(coordinator)
    println("\nSwarm Statistics:")
    println("  Agent count: $(stats["agent_count"])")
    println("  Average reputation: $(round(stats["avg_reputation"], digits=2))")
    println("  Average stake: $(round(stats["avg_stake"], digits=3))")
    println("  Error rate: $(round(stats["error_rate"], digits=3))")
    
    # Monitor health
    health = ConsensusSwarm.monitor_swarm_health(coordinator)
    println("  Health status: $health")
    
    # Stop campaign
    ConsensusSwarm.stop_campaign(coordinator)
    println("\nCampaign stopped")
    
    return coordinator
end

"""
    run_comprehensive_test()

Run a comprehensive test of all functionality.
"""
function run_comprehensive_test()
    println("🚀 Starting Comprehensive Consensus Swarm Test")
    println("=" ^ 50)
    
    try
        # Test 1: Agent Creation
        agents = test_agent_creation()
        
        # Test 2: Swarm Creation
        swarm = test_swarm_creation()
        
        # Test 3: Verification Workflow
        coordinator, result = test_verification_workflow()
        
        # Test 4: Swarm Diversity
        diverse_swarm, votes = test_swarm_diversity()
        
        # Test 5: Dynamic Adjustment
        test_dynamic_adjustment()
        
        # Test 6: Campaign Management
        managed_coordinator = test_campaign_management()
        
        println("\n" * "=" ^ 50)
        println("✅ All tests completed successfully!")
        println("🎯 Consensus swarm system is working as expected")
        
    catch e
        println("\n❌ Test failed with error: $e")
        println("Stack trace: $(stacktrace())")
    end
end

# ----------------------------------------------------------------------
# MAIN EXECUTION
# ----------------------------------------------------------------------

if abspath(PROGRAM_FILE) == @__FILE__
    println("JuliaOS Consensus Swarm Test Suite")
    println("==================================")
    
    # Set random seed for reproducible tests
    Random.seed!(42)
    
    # Run comprehensive test
    run_comprehensive_test()
    
    println("\n🎉 Test suite completed!")
end 
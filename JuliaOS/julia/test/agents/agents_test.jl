using Test
import JuliaOS.JuliaOSFramework.Agents: createAgent, getAgentStatus, startAgent, pauseAgent, resumeAgent, stopAgent, setAgentMemory, getAgentMemory, clearAgentMemory, executeAgentTask, getTaskStatus, getTaskResult, cloneAgent, listAgents, getAgent, register_skill
import JuliaOS.JuliaOSFramework.AgentCore: AgentConfig, TRADING, MONITOR, CREATED, RUNNING, PAUSED, STOPPED, TASK_COMPLETED,register_ability,ABILITY_REGISTRY
using Dates
using DataStructures

@testset "Agents Core Functionality Tests" begin
    # Test Agent creation and basic operations
    @testset "Agent Creation and Basic Operations" begin
        # Create test configuration
        config = AgentConfig(
            "test_agent",
            TRADING;
            abilities=String["test_ability"],
            parameters=Dict{String,Any}("test_param" => "test_value"),
            llm_config=Dict{String,Any}(),
            memory_config=Dict{String,Any}(),
            queue_config=Dict{String,Any}()
        )
        
        # Create Agent
        agent = createAgent(config)
        @test agent.name == "test_agent"
        @test agent.type == TRADING
        @test agent.status == CREATED
        @test !isempty(agent.id)
        
        # Test Agent status management
        @test getAgentStatus(agent.id)["status"] == "CREATED"
        startAgent(agent.id)
        # Wait for Agent to start
        while getAgentStatus(agent.id)["status"] == "INITIALIZING"
            sleep(0.1)
        end
        @test getAgentStatus(agent.id)["status"] == "RUNNING"
        pauseAgent(agent.id)
        @test getAgentStatus(agent.id)["status"] == "PAUSED"
        resumeAgent(agent.id)
        @test getAgentStatus(agent.id)["status"] == "RUNNING"
        stopAgent(agent.id)
        @test getAgentStatus(agent.id)["status"] == "STOPPED"
    end

    # Test Agent memory operations
    @testset "Agent Memory Operations" begin
        config = AgentConfig(
            "memory_test_agent",
            TRADING;
            abilities=String[],
            parameters=Dict{String,Any}(),
            llm_config=Dict{String,Any}(),
            memory_config=Dict{String,Any}(),
            queue_config=Dict{String,Any}()
        )
        agent = createAgent(config)
        
        # Test memory setting and getting
        setAgentMemory(agent.id, "test_key", "test_value")
        @test getAgentMemory(agent.id, "test_key") == "test_value"
        
        # Test memory clearing
        clearAgentMemory(agent.id)
        @test getAgentMemory(agent.id, "test_key") === nothing
    end

    # Test task execution
    @testset "Task Execution" begin
        # Register a test skill
        function test_task(agent, task)
            input = get(task, "input", 0)
            return input * 2
        end
        register_ability("test_task", test_task)
        # Test if registration was successful
        @test haskey(ABILITY_REGISTRY, "test_task")
        config = AgentConfig(
            "task_test_agent",
            TRADING;
            abilities=String["test_task"],  # Add skill to abilities list
            parameters=Dict{String,Any}(),
            llm_config=Dict{String,Any}(),
            memory_config=Dict{String,Any}(),
            queue_config=Dict{String,Any}()
        )
        agent = createAgent(config)
        
        # Test Agent status management
        @test getAgentStatus(agent.id)["status"] == "CREATED"
        startAgent(agent.id)
        # Wait for Agent to start
        while getAgentStatus(agent.id)["status"] == "INITIALIZING"
            sleep(0.1)
        end
        @test getAgentStatus(agent.id)["status"] == "RUNNING"
        
        # Execute task
        task_id = executeAgentTask(agent.id, Dict("ability" => "test_task", "input" => 5))
        @test !isempty(task_id["task_id"])
        
        # Check task status and result
        @test getTaskStatus(agent.id, task_id["task_id"])["status"] == "TASK_COMPLETED"
        result = getTaskResult(agent.id, task_id["task_id"])
        @test result["result"] == 10
        
        # Cleanup
        stopAgent(agent.id)
    end

    # Test Agent cloning
    @testset "Agent Cloning" begin
        config = AgentConfig(
            "clone_test_agent",
            TRADING;
            abilities=String[],
            parameters=Dict{String,Any}(),
            llm_config=Dict{String,Any}(),
            memory_config=Dict{String,Any}(),
            queue_config=Dict{String,Any}()
        )
        original = createAgent(config)
        
        # Set some memory state
        setAgentMemory(original.id, "test_key", "test_value")
        
        # Clone Agent
        clone = cloneAgent(original.id, "clone_test_agent_clone")
        @test clone.name == "clone_test_agent_clone"
        @test clone.type == original.type
        @test clone.status == CREATED
        @test clone.id != original.id
        
        # Verify cloned Agent has independent memory
        @test getAgentMemory(clone.id, "test_key") === nothing
    end

    # Test Agent list operations
    @testset "Agent List Operations" begin
        # Create multiple Agents
        config1 = AgentConfig(
            "list_test_agent1",
            TRADING;
            abilities=String[],
            parameters=Dict{String,Any}(),
            llm_config=Dict{String,Any}(),
            memory_config=Dict{String,Any}(),
            queue_config=Dict{String,Any}()
        )
        config2 = AgentConfig(
            "list_test_agent2",
            MONITOR;
            abilities=String[],
            parameters=Dict{String,Any}(),
            llm_config=Dict{String,Any}(),
            memory_config=Dict{String,Any}(),
            queue_config=Dict{String,Any}()
        )
        agent1 = createAgent(config1)
        agent2 = createAgent(config2)
        
        # Test list operations
        agents = listAgents()
        @test length(agents) >= 2
        @test any(a -> a.id == agent1.id, agents)
        @test any(a -> a.id == agent2.id, agents)
        
        # Test Agent retrieval
        @test getAgent(agent1.id).id == agent1.id
        @test getAgent(agent2.id).id == agent2.id
    end
end
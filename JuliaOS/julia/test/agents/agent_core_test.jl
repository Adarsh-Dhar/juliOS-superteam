using Test
import JuliaOS.JuliaOSFramework.AgentCore: AgentConfig, TRADING, OrderedDictAgentMemory, PriorityAgentQueue, Skill, SkillState, set_value!, get_value
using Dates
using DataStructures

@testset "AgentCore Basic Tests" begin
    # Test AgentConfig creation
    @testset "AgentConfig Creation" begin
        config = AgentConfig(
            "test_agent",
            TRADING;
            abilities=String[],
            parameters=Dict{String,Any}("test_param" => "test_value"),
            llm_config=Dict{String,Any}(),
            memory_config=Dict{String,Any}(),
            queue_config=Dict{String,Any}()
        )
        @test config.name == "test_agent"
        @test config.type == TRADING
        @test config.max_task_history == 100
        @test !isempty(config.llm_config)
        @test !isempty(config.memory_config)
        @test !isempty(config.queue_config)
    end

    # Test OrderedDictAgentMemory
    @testset "OrderedDictAgentMemory" begin
        mem = OrderedDictAgentMemory(OrderedDict{String,Any}(), 3)
        
        # Test basic operations
        set_value!(mem, "key1", "value1")
        @test get_value(mem, "key1") == "value1"
        
        # Test LRU behavior
        set_value!(mem, "key2", "value2")
        set_value!(mem, "key3", "value3")
        set_value!(mem, "key4", "value4")
        @test length(mem) == 3
        @test get_value(mem, "key1") === nothing  # Oldest should be removed
        @test get_value(mem, "key4") == "value4"   # Newest should be kept
    end

    # Test PriorityAgentQueue
    @testset "PriorityAgentQueue" begin
        queue = PriorityAgentQueue(PriorityQueue{Any,Float64}())
        
        # Test enqueue and dequeue
        enqueue!(queue, "task1", 1.0)
        enqueue!(queue, "task2", 2.0)
        enqueue!(queue, "task3", 0.5)
        
        @test length(queue) == 3
        @test dequeue!(queue) == "task3"  # Lowest priority dequeues first
        @test dequeue!(queue) == "task1"
        @test dequeue!(queue) == "task2"
        @test isempty(queue)
    end

    # Test Skill and SkillState
    @testset "Skill and SkillState" begin
        test_fn(x) = x * 2
        skill = Skill("test_skill", test_fn, nothing)
        state = SkillState(skill, 0.0, now())
        
        @test skill.name == "test_skill"
        @test skill.fn(2) == 4
        @test state.xp == 0.0
        @test state.skill === skill
    end
end 
# Example implementation of a tool. The TOOL_EXAMPLE_ADDER_SPECIFICATION struct encapsulates the implementation and is the part added to the registry in Tools.jl.

using ..CommonTypes: ToolSpecification, ToolMetadata, ToolConfig

Base.@kwdef struct ToolExampleAdderConfig <: ToolConfig
    add_value::Integer
end

function tool_example_adder(config::ToolExampleAdderConfig, input::Integer)::Integer
    return input + config.add_value
end

const TOOL_EXAMPLE_ADDER_METADATA::ToolMetadata = ToolMetadata(
    "adder",
    "Adds a specified value to the input integer."
)

const TOOL_EXAMPLE_ADDER_SPECIFICATION::ToolSpecification = ToolSpecification(
    tool_example_adder,
    ToolExampleAdderConfig,
    TOOL_EXAMPLE_ADDER_METADATA
)
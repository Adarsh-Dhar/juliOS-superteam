using OpenAPI
using JSON
import OpenAPI.Servers: to_param_type

"""
    to_param_type(::Type{Dict{String,Any}}, body::AbstractString; stylectx=nothing)

Parse an `application/json` body into a `Dict{String,Any}`.

- Empty body → empty `Dict`.
- Invalid JSON → wrap the original error in an `ArgumentError`
  so the generated 400-handling still works.
"""
function to_param_type(::Type{Dict{String,Any}},
                       body::AbstractString;
                       stylectx = nothing)

    isempty(body) && return Dict{String,Any}()

    try
        return JSON.parse(body)
    catch err
        throw(ArgumentError("invalid JSON body: $(sprint(showerror, err))"))
    end
end

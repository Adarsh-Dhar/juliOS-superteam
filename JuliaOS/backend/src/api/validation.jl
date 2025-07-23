macro validate_model(model)
    return quote
        local _validation_result = validate_model($(esc(model)))
        if _validation_result !== nothing
            @info "Validation failed for $(typeof($(esc(model))))"
            return _validation_result
        end
    end
end

function validate_model(model)::Union{HTTP.Response, Nothing}
    processed_ids = Set{UInt}()
    stack = Vector{Any}()
    push!(stack, model)

    while !isempty(stack)
        obj = pop!(stack)
        obj_id = objectid(obj)

        if obj_id in processed_ids
            continue
        end
        push!(processed_ids, obj_id)

        if obj isa OpenAPI.APIModel
            validation_result = validate_single_model!(stack, obj)
            if validation_result !== nothing
                return validation_result
            end
        elseif obj isa AbstractVector
            for item in obj
                push!(stack, item)
            end
        end
    end

    return nothing
end

function validate_single_model!(children_stack::Vector{Any}, obj)::Union{HTTP.Response, Nothing}
    T = typeof(obj)

    if !JuliaOSServer.check_required(obj)
        return HTTP.Response(400, "Missing required fields in $(T)")
    end

    for field in fieldnames(T)
        val = getfield(obj, field)
        try
            OpenAPI.validate_property(T, field, val)
        catch e
            return HTTP.Response(400, "Invalid value for field $(field) in $(T): $(e.message)")
        end
        if val isa OpenAPI.APIModel || val isa AbstractVector
            push!(children_stack, val)
        end
    end
    return nothing
end


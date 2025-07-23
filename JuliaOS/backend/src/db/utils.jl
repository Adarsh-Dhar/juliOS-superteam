function to_vector_if_sequential(dict::Dict{Int, T})::Vector{T} where T
    n = length(dict)
    expected_keys = 1:n
    actual_keys = sort(collect(keys(dict)))

    if actual_keys != expected_keys
        error("Missing or non-sequential keys in dict: expected 1:$n, got $(actual_keys)")
    end

    return [dict[i] for i in expected_keys]
end

function struct_to_dict(x)
    Dict(string(k) => getfield(x, k) for k in propertynames(x))
end
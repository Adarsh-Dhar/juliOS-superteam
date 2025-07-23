using LibPQ

const _CONN = Ref{Union{Nothing, LibPQ.Connection}}(nothing)

function initialize_connection(conn_string::String)
    if _CONN[] !== nothing
        error("Connection is already initialized.")
    end

    _CONN[] = LibPQ.Connection(conn_string)
end

function get_connection()::LibPQ.Connection
    if _CONN[] === nothing
        error("Connection is not initialized.")
    end

    return _CONN[]
end
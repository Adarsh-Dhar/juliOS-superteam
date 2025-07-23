using DotEnv
DotEnv.load!()

using Pkg
Pkg.activate(".")

using JuliaOSBackend.JuliaOSV1Server
using JuliaOSBackend.JuliaDB

function main()
    @info "Initializing DB connection..."
    db_host = get(ENV, "DB_HOST", "localhost")
    db_port = parse(Int, get(ENV, "DB_PORT", "5435"))
    db_name = get(ENV, "DB_NAME", "postgres")
    db_user = get(ENV, "DB_USER", "postgres")
    db_password = get(ENV, "DB_PASSWORD", "postgres")
    connection_string = "host=$(db_host) port=$(db_port) dbname=$(db_name) user=$(db_user) password=$(db_password)"
    JuliaDB.initialize_connection(connection_string)
    @info "DB connection initialized successfully."
    @info "DB connection string: $(connection_string)"
    @info "Loading state from DB..."
    JuliaDB.load_state()
    @info "State loaded successfully."

    @info "Starting server..."
    host = get(ENV, "HOST", "127.0.0.1")
    port = parse(Int, get(ENV, "PORT", "8052"))
    JuliaOSV1Server.run_server(host, port)
    @info "Server started successfully on http://$(host):$(port)"
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
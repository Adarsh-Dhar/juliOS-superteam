FROM julia:1.11.4-bullseye
WORKDIR /app

COPY Project.toml ./
COPY src/ ./src/
COPY .env ./

RUN julia -e "\
import Pkg; \
Pkg.Registry.add(\"General\"); \
Pkg.activate(\"/app\"); \
Pkg.resolve(); \
Pkg.instantiate(); \
Pkg.precompile();\
"

COPY . .

ENV JULIA_PROJECT=@.
EXPOSE 8052

ENV HOST=0.0.0.0

CMD ["julia", "--project=@.", "run_server.jl", "${PORT:-8052}"]

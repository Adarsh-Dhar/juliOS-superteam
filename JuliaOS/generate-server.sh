# To run this script, you will need:
# - Java 11+
# - openapi-generator-cli.jar, which can be downloaded from https://openapi-generator.tech/docs/installation/#jar

JARNAME="openapi-generator-cli.jar"

API_DIR="./backend/src/api"

if [ ! -f "$JARNAME" ]; then
    echo "Missing $JARNAME. Please download it from https://openapi-generator.tech/docs/installation/#jar"
    exit 1
fi

java -jar $JARNAME generate \
    -i "$API_DIR/spec/api-spec.yaml" \
    -g julia-server \
    -o "$API_DIR/server" \
    --additional-properties=packageName=JuliaOSServer \
    --additional-properties=exportModels=true
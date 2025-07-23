# To run this script, you will need:
# - Java 11+
# - openapi-generator-cli.jar, which can be downloaded from https://openapi-generator.tech/docs/installation/#jar

JARNAME="openapi-generator-cli.jar"
PKGNAME="_juliaos_client_api"

if [ ! -f "$JARNAME" ]; then
    echo "Missing $JARNAME. Please download it from https://openapi-generator.tech/docs/installation/#jar"
    exit 1
fi

if [ -e ./python/src/temp ]; then
    echo "The file ./python/src/temp already exists. Please remove it before running this script."
    exit 1
fi

if [ -e ./temp-generated ]; then
    echo "The file ./temp-generated already exists. Please remove it before running this script."
    exit 1
fi

java -jar $JARNAME generate \
    -i ./backend/src/api/spec/api-spec.yaml \
    -g python-pydantic-v1 \
    -o ./python/src/$PKGNAME/ \
    --additional-properties=packageName=$PKGNAME \
    --additional-properties=exportModels=true

# Only the Python source code is needed directly in python/src/.
# We move the rest to ./temp-generated in case some of the generated files, e.g. documentation, are needed in development.
# Otherwise, ./temp-generated can be safely deleted.

mv ./python/src/$PKGNAME/$PKGNAME ./python/src/temp
mv ./python/src/$PKGNAME ./temp-generated
mv ./python/src/temp ./python/src/$PKGNAME

echo "The directory ./temp-generated can be safely deleted."
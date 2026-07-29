#!/usr/bin/env bash

set -e

source .env
version=$(grep -o '"build":[[:space:]]*[0-9]*' settings.json | grep -o '[0-9]*')
version=$((version + 1))
sed -i "s/\"build\":[[:space:]]*[0-9]*/\"build\": $version/" settings.json



PROJECT_DIR="$(pwd)"
OUTPUT_DIR="$PROJECT_DIR/build/web/$version"


mkdir -p "$OUTPUT_DIR"

"$GODOT_PATH" \
    --headless \
    --path "$PROJECT_DIR" \
    --export-release "Web" \
    "$OUTPUT_DIR/index.html"

echo "Build Done."




########################### ZIP IT



#SOURCE_DIR="$(pwd)/build/web"
OUTPUT_ZIP="$(pwd)/build/web/$version/web.zip"

SEVENZIP="C:\Program Files\7-Zip\7z.exe"
command -v 7z >/dev/null 2>&1 && SEVENZIP="7z"

rm -f "$OUTPUT_ZIP"

pushd "$OUTPUT_DIR" >/dev/null
"$SEVENZIP" a -tzip "$OUTPUT_ZIP" .
popd >/dev/null

echo "Archive created: $OUTPUT_ZIP"




######################## UPLOAD ON ITCH


BUILD_DIR="build/web/$version"
CHANNEL="web"


export BUTLER_API_KEY

echo "Uploading to itch.io..."


$BUTLER_PATH push \
    "$BUILD_DIR" \
    "$ITCH_USER/$ITCH_GAME:$CHANNEL"

echo "Upload complete!"

$BUTLER_PATH status $ITCH_USER/$ITCH_GAME:$CHANNEL

git tag build-$version
git push origin build-$version
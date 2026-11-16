#!/usr/bin/env bash
#
# Reconstruye los recursos JS que van dentro de la app.
#
#   cd ScrambleEngineBuild && npm install && ./build.sh
#
# Salida: TimeCuber/ScrambleEngine/{engine.js,worker.js,viewer.js}
# (`index.html` y `viewer.html` se editan a mano y no los toca este script.)

set -euo pipefail

cd "$(dirname "$0")"

OUT_DIR="../TimeCuber/ScrambleEngine"
mkdir -p "$OUT_DIR"

echo "→ engine.js"
npx esbuild src/entry.js \
    --bundle \
    --format=esm \
    --minify \
    --target=safari16 \
    --outfile="$OUT_DIR/engine.js"

echo "→ worker.js"
npx esbuild src/worker.js \
    --bundle \
    --format=esm \
    --minify \
    --target=safari16 \
    --outfile="$OUT_DIR/worker.js"

echo "→ viewer.js"
npx esbuild src/viewer.js \
    --bundle \
    --format=esm \
    --minify \
    --target=safari16 \
    --outfile="$OUT_DIR/viewer.js"

echo "✓ Listo"
ls -lh "$OUT_DIR"

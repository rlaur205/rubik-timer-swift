#!/usr/bin/env bash
#
# Reconstruye los recursos JS que van dentro de la app.
#
#   cd ScrambleEngineBuild && npm install && ./build.sh
#
# Salidas: TimeCuber/ScrambleEngine/viewer.js y fto.js
# (`viewer.html` se edita a mano y no lo toca este script.)
#
# El visor usa cubing.js para dibujar los diagramas. FTO usa el solver de cubing.js
# en JavaScriptCore. El resto de puzzles usa el framework nativo TNoodleLibNative.

set -euo pipefail

cd "$(dirname "$0")"

OUT_DIR="../TimeCuber/ScrambleEngine"
mkdir -p "$OUT_DIR"

echo "→ viewer.js"
npx esbuild src/viewer.js \
    --bundle \
    --format=esm \
    --minify \
    --target=safari16 \
    --outfile="$OUT_DIR/viewer.js"

echo "→ fto.js"
shopt -s nullglob
solver=(node_modules/cubing/dist/lib/cubing/chunks/search-dynamic-solve-fto-*.js)
if [[ ${#solver[@]} -ne 1 ]]; then
    echo "No se encontró el solver de FTO de cubing.js." >&2
    exit 1
fi
npx esbuild src/fto.js \
    --alias:fto-solver="./${solver[0]}" \
    --bundle \
    --format=iife \
    --minify \
    --target=safari16 \
    --outfile="$OUT_DIR/fto.js"

echo "✓ Listo"
ls -lh "$OUT_DIR"

#!/usr/bin/env bash
#
# Reconstruye los recursos JS que van dentro de la app.
#
#   cd ScrambleEngineBuild && npm install && ./build.sh
#
# Salida: TimeCuber/ScrambleEngine/viewer.js
# (`viewer.html` se edita a mano y no lo toca este script.)
#
# Los scrambles NO se generan aquí: los genera TNoodle dentro del propio dispositivo
# (framework nativo TNoodleLibNative). Este build solo empaqueta el visor del diagrama
# 2D, que usa cubing.js (`TwistyPlayer`) para dibujar el estado del puzzle.

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

echo "✓ Listo"
ls -lh "$OUT_DIR"

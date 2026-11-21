# Avisos de terceros

TimeCuber incluye código y binarios de terceros. Este documento recoge su procedencia,
licencia y obligaciones.

---

## TNoodle (AGPL-3.0)

- **Qué es:** el programa oficial de scrambles de la World Cube Association.
- **Qué se incluye:** `Frameworks/TNoodleLibNative.xcframework`, una compilación de
  TNoodle con GraalVM Native Image que expone una API de C
  (`tnoodle_lib_scramble`, `tnoodle_lib_draw_scramble`).
- **Procedencia:** release `v1.0` del repositorio
  [`CubeLabsNZ/tnoodle-lib-native-v1`](https://github.com/CubeLabsNZ/tnoodle-lib-native-v1),
  que es un fork de [`thewca/tnoodle-lib`](https://github.com/thewca/tnoodle-lib).
  La arquitectura de simulador `arm64` se genera a partir de la de dispositivo con
  [`arm64-to-sim`](https://github.com/bogo/arm64-to-sim).
- **Licencia:** GNU Affero General Public License v3.0
  ([texto](https://www.gnu.org/licenses/agpl-3.0.html)).

### Obligaciones

La AGPL-3.0 es una licencia copyleft fuerte. Al distribuir la app con este framework
dentro, **el conjunto de la aplicación queda sujeto a la AGPL-3.0**, lo que implica:

1. Publicar el código fuente completo de la app bajo AGPL-3.0.
2. Mantener los avisos de copyright y la licencia.
3. Ofrecer el código fuente a cualquiera que reciba el binario.

Si no se desea asumir esta obligación, hay que quitar el framework y usar otro
generador de scrambles (por ejemplo, cubing.js, que es MPL-2.0).

---

## cubing.js (MPL-2.0)

- **Qué es:** la librería que dibuja los diagramas 2D (`TwistyPlayer`) y distribuye el
  generador de FTO de Chen Shuang.
- **Qué se incluye:** `TimeCuber/ScrambleEngine/viewer.js` y `fto.js`, generados desde
  `ScrambleEngineBuild/` con cubing `0.66.1`.
- **Origen:** [`cubing/cubing.js`](https://github.com/cubing/cubing.js).
- **Licencia:** Mozilla Public License 2.0
  ([texto](https://www.mozilla.org/en-US/MPL/2.0/)). El
  [solver de FTO](https://gist.github.com/cs0x7f/1579492aa43c794d529057386c489702)
  tiene licencia MIT. Su aviso se incluye en `fto.js`.

### Obligaciones

La MPL-2.0 es copyleft **por fichero**: los ficheros de cubing.js (y sus
modificaciones) deben seguir bajo MPL-2.0 y con sus avisos de copyright, pero no obliga
a liberar el resto de la app. El código fuente del bundle está en
`ScrambleEngineBuild/`, y la versión exacta queda fijada en `package.json`.

---

## arm64-to-sim (MIT)

- **Qué es:** herramienta usada **solo en el proceso de empaquetado** para convertir la
  arquitectura de simulador del framework de TNoodle.
- **Qué se incluye:** nada; no forma parte del binario de la app.
- **Origen:** [`bogo/arm64-to-sim`](https://github.com/bogo/arm64-to-sim).
- **Licencia:** MIT.

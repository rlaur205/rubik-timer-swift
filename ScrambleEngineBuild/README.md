# ScrambleEngineBuild

Proyecto npm que empaqueta **cubing.js** para los diagramas 2D y para generar scrambles
de FTO. Los demás puzzles usan [TNoodle](https://github.com/thewca/tnoodle) a través
del framework nativo `TNoodleLibNative.xcframework`.

Los ficheros resultantes se guardan en `TimeCuber/ScrambleEngine/` y se copian al
bundle de la app (`TimerV3.app/ScrambleEngine/`).

## Compilar

```bash
cd ScrambleEngineBuild
npm install
./build.sh
```

Salida:

|Fichero|Qué es|
|---|---|
|`../TimeCuber/ScrambleEngine/viewer.js`|Bundle del diagrama 2D; registra y configura el `TwistyPlayer`|
|`../TimeCuber/ScrambleEngine/fto.js`|Solver para generar scrambles de FTO desde JavaScriptCore|

`viewer.html` **no** lo genera este script: se edita a mano en
`TimeCuber/ScrambleEngine/`.

## Cómo encaja

1. `viewer.html` define el puente `window.__setScramble(puzzle, alg)`, que espera a que
   el módulo termine de cargar.
2. `src/viewer.js` registra el custom element `twisty-player` y crea un `TwistyPlayer`
   en modo 2D (`background: "none"`, `controlPanel: "none"`, `hintFacelets: "none"`).
   El scramble se pasa como `experimentalSetupAlg` para dibujar el estado **después**
   de la mezcla.
3. La app sirve `viewer.html` y `viewer.js` desde un servidor en loopback
   (`ScrambleHTTPServer`). Es necesario porque `WKWebView` no puede cargar módulos ES
   desde `file://`, y los `WKURLSchemeHandler` personalizados no son fiables con ellos.
4. Swift llama a `window.__setScramble` con `callAsyncJavaScript` cada vez que cambia
   el scramble o la categoría.

El build ESM de cubing.js **no registra** el custom element `twisty-player` (eso solo
lo hacen los bundles para navegador). Por eso `src/viewer.js` llama a
`customElements.define` antes de crear el elemento.

El build de FTO empaqueta el solver de la versión fijada de cubing.js. Swift lo ejecuta
en un contexto de JavaScriptCore dedicado y reutiliza sus tablas entre scrambles.

## Licencia

- **cubing.js** es **MPL-2.0**. El bundle `viewer.js` contiene código suyo, así que al
  distribuir la app hay que mantener la licencia y los avisos de copyright, y ofrecer
  el código fuente (basta con este directorio, que ya está en el repositorio público,
  más la versión de cubing.js fijada en `package.json`). Al ser copyleft por fichero
  **no** obliga a liberar el resto de la app.
- El solver de FTO es **MIT** y su aviso está incluido en `fto.js`.
- **TNoodle** es **AGPL-3.0** y **sí se distribuye** dentro de la app como framework
  nativo (`Frameworks/TNoodleLibNative.xcframework`). Eso hace que distribuir la app
  obligue a publicar su código fuente bajo AGPL-3.0. Ver `THIRD-PARTY-NOTICES.md` en la
  raíz del repositorio.

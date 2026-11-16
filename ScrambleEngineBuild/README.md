# ScrambleEngineBuild

Proyecto npm que compila el bundle de **cubing.js** que se embebe en la app para el
diagrama 2D del scramble.

Los scrambles **no** se generan aquí: los genera
[TNoodle](https://github.com/thewca/tnoodle) (el programa oficial de la WCA) dentro del
propio dispositivo, a través del framework nativo `TNoodleLibNative.xcframework`. Este
directorio solo empaqueta el visor que dibuja el estado del puzzle con `TwistyPlayer`.

El fichero resultante se guarda en `TimeCuber/ScrambleEngine/` y se copia tal cual al
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

## Licencia

- **cubing.js** es **MPL-2.0**. El bundle `viewer.js` contiene código suyo, así que al
  distribuir la app hay que mantener la licencia y los avisos de copyright, y ofrecer
  el código fuente (basta con este directorio, que ya está en el repositorio público,
  más la versión de cubing.js fijada en `package.json`). Al ser copyleft por fichero
  **no** obliga a liberar el resto de la app.
- **TNoodle** es **AGPL-3.0** y **sí se distribuye** dentro de la app como framework
  nativo (`Frameworks/TNoodleLibNative.xcframework`). Eso hace que distribuir la app
  obligue a publicar su código fuente bajo AGPL-3.0. Ver `THIRD-PARTY-NOTICES.md` en la
  raíz del repositorio.

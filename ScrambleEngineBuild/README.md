# ScrambleEngineBuild

Proyecto npm que compila los bundles de **cubing.js** que se embeben en la app.

La app genera los scrambles con cubing.js dentro de un `WKWebView` oculto. El diagrama
2D del scramble usa el `TwistyPlayer` de la misma librería en otro `WKWebView`
transparente. Los ficheros JS resultantes se guardan en `TimeCuber/ScrambleEngine/` y
se copian tal cual al bundle de la app (`TimerV3.app/ScrambleEngine/`).

## Compilar

```bash
cd ScrambleEngineBuild
npm install
./build.sh
```

Salida:

|Fichero|Qué es|
|---|---|
|`../TimeCuber/ScrambleEngine/engine.js`|Bundle del hilo principal; expone `__generateScramble(eventID)`|
|`../TimeCuber/ScrambleEngine/worker.js`|Bundle del Web Worker; hace la búsqueda random-state|
|`../TimeCuber/ScrambleEngine/viewer.js`|Bundle del diagrama 2D; registra y configura el `TwistyPlayer`|

`index.html` y `viewer.html` **no** los genera este script: se editan a mano en
`TimeCuber/ScrambleEngine/`.

## Por qué hay varios bundles

cubing.js crea su Web Worker con `import.meta.resolve()` o
`new URL("./search-worker-entry.js", import.meta.url)`. Dentro de un bundle ninguno de
los dos apunta a un fichero real, así que:

1. `src/worker.js` compila el entry del worker como bundle autocontenido.
2. `index.html` intercepta `window.Worker` y redirige cualquier URL a `worker.js`.
3. `src/entry.js` importa `cubing/scramble` y publica la función global que Swift llama.

El diagrama va aparte porque necesita un contexto DOM propio y porque el build ESM de
cubing.js **no registra** el custom element `twisty-player` (eso solo lo hacen los
bundles para navegador). Por eso `src/viewer.js` llama a `customElements.define` antes
de crear el elemento, y `viewer.html` le pasa el scramble con `window.__setScramble`.

Los bundles van minificados y sin *splitting*, así que los módulos dinámicos
(4x4, 6x6, 7x7, Megaminx…) quedan inline y no hace falta servir más ficheros.

## Licencia

cubing.js es **MPL-2.0**. Los bundles de `TimeCuber/ScrambleEngine/` contienen código
suyo, así que al distribuir la app hay que:

- mantener la licencia y los avisos de copyright de cubing.js, y
- ofrecer el código fuente de esos ficheros (basta con este directorio, que ya está en
  el repositorio público, más la versión de cubing.js fijada en `package.json`).

Al ser MPL-2.0 (copyleft por fichero) **no** obliga a liberar el resto de la app.

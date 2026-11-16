// Diagrama 2D del scramble.
//
// Se ejecuta en un WKWebView visible y dibuja el estado del puzzle con el
// `TwistyPlayer` de cubing.js. Swift le pasa el puzzle y el algoritmo con
// `window.__setScramble(puzzle, alg)`.

import { TwistyPlayer } from "cubing/twisty";

// El build ESM de cubing.js no registra el custom element `twisty-player` (solo lo
// hacen los bundles para navegador). Sin registrarlo, el elemento nunca recibiría
// `connectedCallback` y no dibujaría nada.
if (!customElements.get("twisty-player")) {
    customElements.define("twisty-player", TwistyPlayer);
}

const jugador = document.createElement("twisty-player");
jugador.puzzle = "3x3x3";
jugador.visualization = "2D";
jugador.background = "none";
jugador.controlPanel = "none";
jugador.hintFacelets = "none";
jugador.experimentalSetupAnchor = "start";

document.body.appendChild(jugador);

window.__aplicarScramble = function (puzzle, alg) {
    jugador.puzzle = puzzle;
    jugador.experimentalSetupAlg = alg;
};

window.__listoResolve();

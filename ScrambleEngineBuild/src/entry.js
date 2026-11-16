// Punto de entrada principal del motor de scrambles.
//
// Se ejecuta en el hilo principal del WKWebView y expone una única función global
// que Swift invoca con `callAsyncJavaScript`. Devuelve siempre un string: o el
// scramble, o un mensaje de error con el prefijo "__ERROR__:" (el puente Swift lo
// interpreta y lo convierte en excepción).

import { randomScrambleForEvent } from "cubing/scramble";

globalThis.__generateScramble = async function (eventID) {
    try {
        const alg = await randomScrambleForEvent(eventID);
        return alg.toString();
    } catch (error) {
        return "__ERROR__:" + (error && error.message ? error.message : String(error));
    }
};

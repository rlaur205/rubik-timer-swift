// Entrada del Web Worker de cubing.js.
//
// Aquí se hace todo el trabajo pesado (búsqueda random-state). Se compila como un
// bundle aparte y autocontenido para poder servirlo como `worker.js`. El módulo se
// autoarranca y habla con el hilo principal mediante comlink.

import "../node_modules/cubing/dist/lib/cubing/chunks/search-worker-entry.js";

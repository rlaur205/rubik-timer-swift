<h1 align="center">TimeCuber</h1>

<p align="center"><strong>Cronómetro de speedcubing para iPhone</strong></p>

<p align="center">
  Mide tus resoluciones, guarda tus scrambles y sigue tu progreso por sesión.
</p>

<p align="center">
  <a href="#funciones">Funciones</a> · <a href="#primeros-pasos">Primeros pasos</a> · <a href="#compilar-en-xcode">Compilar en Xcode</a> · <a href="informe.md">Informe completo</a>
</p>

<p align="center">
  <img src="Capturas/Documentacion/cronometro.png" width="220" alt="Cronómetro con el scramble del 3×3 y los últimos cinco tiempos">
  <img src="Capturas/Documentacion/tiempos.png" width="220" alt="Historial con centésimas, fecha y hora, scramble y penalizaciones">
  <img src="Capturas/Documentacion/estadisticas.png" width="220" alt="Estadísticas de la sesión con resumen y promedios actuales">
</p>

## Funciones

| | |
| --- | --- |
| **Cronómetro** | Inicio por toque o pulsación configurable de 0.3 a 1.5 s. El color de listo indica cuándo soltar para empezar. |
| **Scrambles y diagramas** | Generación local con TNoodle para 14 categorías. Consúltalos en el cronómetro o abre el diagrama 2D del scramble actual y de los tiempos guardados. |
| **Tiempos y penalizaciones** | Aplica o quita **+2** y **DNF** desde el cronómetro o el historial. Cada resolución conserva su tiempo original, scramble y fecha. |
| **Estadísticas** | Mo3, Ao5 a Ao1000, mejores promedios, desviación y gráfica de progreso de la sesión. Abre un promedio para ver los tiempos que lo componen. |
| **Sesiones** | Separa tus prácticas por nombre y puzzle, desde 2×2 hasta 7×7, con Pyraminx, Megaminx, Skewb y Square-1. |
| **Personalización** | Modo del sistema o 16 temas, 15 opciones de tipografía para el cronómetro y otras 15 para el scramble, con tamaños independientes y vistas previas. |

<details>
<summary>Ver capturas de sesiones, detalle de un tiempo y ajustes</summary>

<p align="center">
  <img src="Capturas/Documentacion/nueva-sesion.png" width="200" alt="Creación de una sesión con el selector de puzzle">
  <img src="Capturas/Documentacion/detalle.png" width="200" alt="Detalle de una resolución con +2, diagrama 2D y controles de penalización">
  <img src="Capturas/Documentacion/ajustes.png" width="200" alt="Ajustes de tema, visibilidad, fuente y tamaño del scramble">
</p>

</details>

## Primeros pasos

1. Abre **Sesiones** y elige una existente o crea una con **+**.
2. Lee el scramble en **Cronómetro**. El botón del cubo abre el diagrama.
3. Mantén pulsado hasta que cambie el color, suelta para empezar y toca para detener. Puedes habilitar el inicio por toque en **Ajustes**.
4. Desliza hacia abajo con el cronómetro detenido para penalizar el último tiempo. En **Tiempos**, mantén pulsada una resolución para abrir sus detalles.

## Compilar en Xcode

Necesitas Xcode con Swift 6 y un destino iPhone con **iOS 17.4 o posterior**. El framework incluido requiere un simulador ARM64 en Mac con Apple Silicon o un iPhone físico.

```bash
git clone https://github.com/rlaur205/rubik-timer-swift.git
cd rubik-timer-swift
open TimerV3.xcodeproj
```

Selecciona **TimerV3**, elige un iPhone y ejecuta con **⌘R**. Para un dispositivo físico, configura la firma del target en Xcode.

El [informe de TimeCuber](informe.md) cubre las cinco pantallas, los cálculos, la persistencia y el mantenimiento. Las dependencias del motor y del visor figuran en los [avisos de terceros](THIRD-PARTY-NOTICES.md).

<sub>Capturas de la app con datos de demostración.</sub>

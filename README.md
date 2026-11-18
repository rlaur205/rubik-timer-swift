# TimeCuber — Timer de Rubik para iOS

Aplicación iOS nativa desarrollada en Swift y SwiftUI para speedcubing. Cronometra tus solves, genera scrambles automáticos para 14 tipos de puzzles/eventos WCA y sigue tus estadísticas, todo en una interfaz limpia y nativa.

---

## Capturas de Pantalla

### Cronómetro
| Dark Mode | Light Mode |
|-----------|------------|
| ![Cronómetro Dark](img/img_cronometroB.png) | ![Cronómetro Light](img/img_cronometro.png) |

### Categorías y Sesiones
| Dark | Light | Nueva Sesión (Dark) | Nueva Sesión (Light) |
|------|-------|---------------------|----------------------|
| ![Categorías Dark](img/img_categoriasB.png) | ![Categorías Light](img/img_categorias.png) | ![Nueva Sesión Dark](img/img_agregarCategoriaPopUpB.png) | ![Nueva Sesión Light](img/img_agregarCategoriaPopUp.png) |

### Historial de Tiempos
| Lista (Dark) | Lista (Light) | Eliminar (Dark) | Eliminar (Light) |
|--------------|---------------|-----------------|------------------|
| ![Tiempos Dark](img/img_tiemposB.png) | ![Tiempos Light](img/img_tiempos.png) | ![Eliminar Dark](img/img_eliminarTiemposB.png) | ![Eliminar Light](img/img_eliminarTiempos.png) |

### Estadísticas Avanzadas
| Estadísticas (Dark) | Estadísticas (Light) | Gráfica (Dark) | Gráfica (Light) |
|---------------------|----------------------|----------------|-----------------|
| ![Estadísticas Dark](img/img_estadisticasB.png) | ![Estadísticas Light](img/img_estadisticas.png) | ![Gráfica Dark](img/img_graficaB.png) | ![Gráfica Light](img/img_grafica.png) |

---

## Funcionalidades

- **Cronómetro táctil** — inicia y deten el timer con solo tocar la pantalla
- **Scrambles automáticos** — mezclas oficiales de [TNoodle](https://github.com/thewca/tnoodle) (el programa de la WCA) generadas en el propio dispositivo, sin servidor ni internet
- **Diagrama del scramble** — dibujo 2D del estado del puzzle tras la mezcla, con [cubing.js](https://github.com/cubing/cubing.js)
- **14 eventos WCA** — 3x3, 2x2, 4x4, 5x5, 6x6, 7x7, 3x3 OH, 3x3 BLD, 4x4 BLD, 5x5 BLD, Pyraminx, Megaminx, Skewb, Square-1
- **Múltiples sesiones** — crea y gestiona varias sesiones por categoría
- **Stats en tiempo real** — Mo3, Ao5, Ao12, Ao50 siempre visibles debajo del cronómetro
- **Estadísticas avanzadas** — PBs históricos, desviación estándar y gráficas de progreso
- **Historial completo** — cada solve con fecha, scramble y opción de eliminar individualmente
- **Persistencia automática** — todos los datos se guardan localmente entre sesiones
- **Dark & Light Mode** — soporte nativo completo

---

## Tecnologías

![Swift](https://img.shields.io/badge/Swift-5.x-orange?logo=swift)
![SwiftUI](https://img.shields.io/badge/SwiftUI-declarativo-blue?logo=apple)
![MVVM](https://img.shields.io/badge/Arquitectura-MVVM-green)
![UserDefaults](https://img.shields.io/badge/Persistencia-UserDefaults%20%2B%20JSON-lightgrey)
![iOS](https://img.shields.io/badge/iOS-18%2B-black?logo=apple)

Los scrambles los genera [TNoodle](https://github.com/thewca/tnoodle) (AGPL-3.0), el
programa oficial de la WCA, compilado como librería nativa para iOS e incluido en la
app. Es la misma solución que usa CubeTime: todo ocurre en el dispositivo, sin
servidor ni conexión a internet. El diagrama 2D de la mezcla usa `TwistyPlayer`, la
vista de [cubing.js](https://github.com/cubing/cubing.js) (MPL-2.0), en un `WKWebView`
transparente. Si el motor falla, la app no muestra scramble en lugar de inventarse uno.

> **Licencia:** al incluir TNoodle, el binario de la app queda sujeto a la AGPL-3.0.
> Si distribuyes la app, tienes que publicar el código fuente bajo esa misma licencia.
> Ver [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md).

---

## Instalación

**Requisitos:** macOS con Xcode · iOS 18+ · Cuenta de desarrollador Apple (para dispositivo físico)

```bash
git clone https://github.com/rlaur205/rubik-timer-swift.git
cd rubik-timer-swift
open TimerV3.xcodeproj
```

Selecciona un simulador o dispositivo en Xcode y presiona `Cmd + R`.

El framework de TNoodle (`Frameworks/TNoodleLibNative.xcframework`) ya está incluido
en el repositorio, con las arquitecturas de dispositivo (arm64) y simulador de Apple
Silicon. No hay que arrancar ningún servidor: los scrambles se generan en el propio
iPhone o simulador.

El bundle del diagrama (`viewer.js`, generado con cubing.js) también está incluido.
Solo hace falta Node.js si quieres recompilarlo:

```bash
cd ScrambleEngineBuild
npm install
./build.sh
```


---

## Documentación

Ver [DOCUMENTACION.md](DOCUMENTACION.md) para la documentación completa.

---

## Mejoras Futuras

- Penalizaciones WCA (+2 y DNF)
- Sincronización iCloud
- Exportar tiempos en formato CSV

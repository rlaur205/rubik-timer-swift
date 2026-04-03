# TimeCuber — Timer de Rubik para iOS

Aplicación iOS nativa desarrollada en Swift y SwiftUI para speedcubing. Cronometra tus solves, genera scrambles automáticos para 12 tipos de puzzles WCA y sigue tus estadísticas, todo en una interfaz limpia y nativa.

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
- **Scrambles automáticos** — mezclas aleatorias específicas para cada puzzle al iniciar y después de cada solve
- **12 puzzles WCA** — 3x3, 2x2, 4x4, 5x5, 6x6, 7x7, 3x3 OH, 3x3 BLD, Pyraminx, Megaminx, Skewb, Square-1
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

---

## Instalación

**Requisitos:** macOS con Xcode · iOS 18+ · Cuenta de desarrollador Apple (para dispositivo físico)

```bash
git clone https://github.com/rlaur205/rubik-timer-swift.git
cd rubik-timer-swift
open TimerV3.xcodeproj
```

Selecciona un simulador o dispositivo en Xcode y presiona `Cmd + R`.


---

## Documentación

Ver [DOCUMENTACION.md](DOCUMENTACION.md) para la documentación completa.

---

## Mejoras Futuras

- Penalizaciones WCA (+2 y DNF)
- Sincronización iCloud
- Exportar tiempos en formato CSV

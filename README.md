# 🧩 TimeCuber — Rubik Timer for iOS

A native iOS app built with Swift and SwiftUI for speedcubing. Time your solves, get automatic scrambles for 12 WCA puzzle types, and track your stats — all in one clean interface.

---

## 📱 Screenshots

### Cronómetro
| Dark Mode | Light Mode |
|-----------|------------|
| ![Timer Dark](screenshots/timer_dark.png) | ![Timer Light](screenshots/timer_light.png) |

### Categorías y Sesiones
| Dark | Light | Nueva Sesión (Dark) | Nueva Sesión (Light) |
|------|-------|---------------------|----------------------|
| ![Cat Dark](screenshots/cat_dark.png) | ![Cat Light](screenshots/cat_light.png) | ![New Dark](screenshots/new_dark.png) | ![New Light](screenshots/new_light.png) |

### Historial de Tiempos
| Lista | Borrar (Dark) | Borrar (Light) |
|-------|---------------|----------------|
| ![Lista](screenshots/lista.png) | ![Borrar Dark](screenshots/borrar_dark.png) | ![Borrar Light](screenshots/borrar_light.png) |

### Estadísticas Avanzadas
| Estadísticas | Gráfica (Dark) | Gráfica (Light) |
|--------------|----------------|-----------------|
| ![Stats](screenshots/stats.png) | ![Grafica Dark](screenshots/grafica_dark.png) | ![Grafica Light](screenshots/grafica_light.png) |

---

## ✨ Features

- **Cronómetro táctil** — iniciá y detené el timer con solo tocar la pantalla
- **Scrambles automáticos** — mezclas aleatorias específicas para cada puzzle
- **12 puzzles WCA** — 3x3, 2x2, 4x4, 5x5, 6x6, 7x7, 3x3 OH, 3x3 BLD, Pyraminx, Megaminx, Skewb, Square-1
- **Múltiples sesiones** — creá y gestioná sesiones por categoría
- **Stats en tiempo real** — Mo3, Ao5, Ao12, Ao50 siempre visibles
- **Estadísticas avanzadas** — PBs históricos, desviación estándar y gráficas de progreso
- **Historial completo** — cada solve con fecha, scramble y opción de eliminar
- **Persistencia automática** — datos guardados localmente entre sesiones
- **Dark & Light Mode** — soporte nativo completo

---

## 🛠 Tech Stack

![Swift](https://img.shields.io/badge/Swift-5.x-orange?logo=swift)
![SwiftUI](https://img.shields.io/badge/SwiftUI-declarative-blue?logo=apple)
![MVVM](https://img.shields.io/badge/Architecture-MVVM-green)
![UserDefaults](https://img.shields.io/badge/Persistence-UserDefaults%20%2B%20JSON-lightgrey)
![iOS](https://img.shields.io/badge/iOS-18%2B-black?logo=apple)

---

## 🚀 Instalación

**Requisitos:** macOS con Xcode · iOS 18+ · Cuenta de desarrollador Apple (para dispositivo físico)

```bash
git clone https://github.com/rlaur205/rubik-timer-swift.git
cd rubik-timer-swift
open TimerV3.xcodeproj
```

Seleccioná un simulador o dispositivo en Xcode y presioná `Cmd + R`.

> Sin dependencias externas. No requiere CocoaPods ni SPM.

---

## 📄 Documentación

Ver [DOCUMENTACION.md](DOCUMENTACION.md) para la documentación técnica completa: arquitectura MVVM, modelos de datos, ViewModel, funciones estadísticas y generadores de scrambles.

---

## 🔮 Mejoras Futuras

- Penalizaciones WCA (+2 y DNF)
- Sincronización iCloud
- Exportar tiempos en CSV
- Notificaciones de nuevo PB

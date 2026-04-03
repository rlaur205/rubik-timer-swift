# TimeCuber — Timer de Rubik para iOS

### Documentación Técnica del Proyecto

**Repositorio:** https://github.com/rlaur205/rubik-timer-swift  
**Tecnología principal:** Swift · SwiftUI · MVVM · UserDefaults  
**Plataforma:** iOS (iPhone)  
**Proyecto Xcode:** TimerV3.xcodeproj  
**Fecha de documentación:** Abril 2026

---

## 1. Descripción General

**TimeCuber** es una aplicación iOS nativa desarrollada en Swift con SwiftUI que funciona como cronómetro y gestor de tiempos para speedcubing (resolución rápida del cubo de Rubik). La app permite al usuario cronometrar sus resoluciones, generar mezclas (scrambles) aleatorias para distintos tipos de cubo, organizar sus tiempos en sesiones por categoría y consultar estadísticas detalladas de su desempeño.

El proyecto aplica el patrón de arquitectura **MVVM (Model-View-ViewModel)** y persiste los datos localmente usando **UserDefaults** con codificación JSON.

---

## 2. Estructura del Proyecto

```
rubik-timer-swift/
│
├── TimeCuber/                        # Núcleo de la app
│   ├── TimeCuber.swift               # Punto de entrada (@main)
│   ├── ContentView.swift             # Vista raíz con TabView
│   ├── ModeloTiempos.swift           # Modelos de datos (Sesion, Tiempo, Orden, TimerState)
│   └── RubikAppViewModel.swift       # ViewModel principal (RubikViewModel)
│
├── Cronometro/                       # Módulo del cronómetro
│   ├── CronometroView.swift          # Vista principal del cronómetro
│   ├── TimerAreaView.swift           # Área táctil del timer
│   └── EstadisticasCronometroView.swift # Estadísticas rápidas debajo del timer
│
├── Estadisticas/                     # Módulo de estadísticas avanzadas
│   ├── EstadisticasView.swift        # Vista contenedor de estadísticas
│   ├── TiemposActualesView.swift     # Vista de tiempos actuales
│   ├── TiemposBasicosView.swift      # Vista de estadísticas básicas
│   ├── TiemposPBView.swift           # Vista de récords personales (PB)
│   └── TiemposPBStyle.swift          # Estilos visuales para la vista de PB
│
├── ListaTiempos/                     # Módulo de lista de tiempos
│   ├── ListaTiemposView.swift        # Vista de la lista completa de tiempos
│   └── TiempoRowView.swift           # Celda individual de un tiempo en la lista
│
├── Categorias/                       # Módulo de gestión de sesiones/categorías
│   └── CategoriasView.swift          # Vista para crear, listar y eliminar sesiones
│
├── Funciones/                        # Lógica y utilidades puras
│   ├── funciones.swift               # Funciones de formato, ordenamiento y navegación
│   ├── funcionesEstadisticas.swift   # Funciones de cálculo estadístico
│   └── generadores/                  # Generadores de scrambles por tipo de puzzle
│       ├── gen3.swift                # Scramble para 3x3 y 3x3 OH/BLD
│       ├── gen4.swift                # Scramble para 4x4
│       ├── gen5.swift                # Scramble para 5x5
│       ├── gen6-7.swift              # Scramble para 6x6 y 7x7
│       ├── genMega.swift             # Scramble para Megaminx
│       ├── genPyra.swift             # Scramble para Pyraminx
│       ├── genSkewb.swift            # Scramble para Skewb
│       └── genSq1.swift              # Scramble para Square-1
│
└── TimerV3.xcodeproj/               # Proyecto Xcode
```

---

## 3. Tecnologías y Herramientas

|Tecnología|Uso|
|---|---|
|Swift 5.x|Lenguaje de programación principal|
|SwiftUI|Framework declarativo para la interfaz de usuario|
|UIKit|Uso puntual (importado en `CronometroView`)|
|Foundation|Manejo de fechas, codificación JSON y tipos base|
|UserDefaults|Persistencia local de sesiones y preferencias|
|MVVM|Patrón de arquitectura de la aplicación|
|Xcode|IDE de desarrollo (proyecto `TimerV3.xcodeproj`)|

---

## 4. Modelos de Datos

Definidos en `TimeCuber/ModeloTiempos.swift`.

### 4.1 `Sesion`

Representa una sesión de entrenamiento para un tipo de cubo específico.

```swift
class Sesion: Codable, Identifiable, Equatable {
    var id: UUID
    var tiempos: [Tiempo]   // Lista de tiempos registrados
    var nombre: String       // Nombre de la sesión (ej: "Standard")
    var categoria: String    // Tipo de cubo (ej: "3x3", "4x4")
}
```

### 4.2 `Tiempo`

Representa un solve (resolución) individual guardado en una sesión.

```swift
class Tiempo: Codable, Identifiable, Equatable {
    var id: UUID
    var tiempo: Double       // Duración en segundos
    var scramble: String     // Mezcla utilizada en ese solve
    var fecha: Date          // Fecha y hora del registro
}
```

### 4.3 `Orden` (Enum)

Define los criterios disponibles para ordenar la lista de tiempos.

|Caso|Descripción|
|---|---|
|`.fecha`|Orden cronológico (más reciente primero)|
|`.ascendente`|De menor a mayor tiempo|
|`.descendente`|De mayor a menor tiempo|

### 4.4 `TimerState` (Struct)

Estado interno del cronómetro en un momento dado.

|Propiedad|Tipo|Descripción|
|---|---|---|
|`estaCorriendo`|Bool|Si el timer está activo|
|`estaTocando`|Bool|Si el usuario está tocando la pantalla|
|`tiempoInicio`|Date?|Momento en que inició el timer|
|`tiempoTranscurrido`|TimeInterval|Segundos transcurridos|
|`visibilidadPromedios`|Bool|Si se muestran los promedios|

---

## 5. ViewModel: `RubikViewModel`

Archivo: `TimeCuber/RubikAppViewModel.swift`  
Clase que actúa como cerebro de la aplicación. Implementa `ObservableObject` para que las vistas SwiftUI se actualicen reactivamente ante cualquier cambio.

### 5.1 Propiedades `@Published`

|Propiedad|Tipo|Descripción|
|---|---|---|
|`tiemposPrincipal`|`[Sesion]`|Lista completa de todas las sesiones|
|`sesionActual`|`Sesion`|Sesión actualmente seleccionada|
|`tiemposRecorrer`|`[Tiempo]`|Tiempos de la sesión actual (para mostrar)|
|`scrambleActual`|`String`|Mezcla generada actualmente|
|`idActual`|`UUID?`|ID de la sesión activa|
|`ordenActual`|`Orden`|Criterio de orden activo|
|`timerState`|`TimerState`|Estado completo del cronómetro|
|`categoriaSeleccionada`|`String`|Categoría activa (persistida en UserDefaults)|
|`nombreSeleccionada`|`String`|Nombre de sesión activa (persistida en UserDefaults)|

> `categoriaSeleccionada` y `nombreSeleccionada` usan `didSet` para guardarse automáticamente en `UserDefaults` cada vez que cambian.

### 5.2 Métodos Principales

**`init()`**  
Inicializa el ViewModel: carga las sesiones guardadas y actualiza la vista.

**`guardarSesiones()`**  
Serializa `tiemposPrincipal` a JSON con `JSONEncoder` y lo guarda en `UserDefaults` bajo la clave `"savedSesiones"`.

**`cargarSesiones()`**  
Lee y deserializa las sesiones desde `UserDefaults`. Si no hay datos guardados, carga 5 sesiones predeterminadas (Standard 3x3, Standard2 2x2, Standard4 4x4, etc.).

**`actualizarVista()`**  
Función central que recalcula: la lista de tiempos a mostrar, la sesión actual y genera un nuevo scramble si no hay ninguno.

**`registrarNuevoTiempo()`**  
Calcula el tiempo transcurrido desde `tiempoInicio`, lo agrega a la sesión actual, guarda los datos y genera un nuevo scramble. Ignora tiempos menores a 0.01 segundos.

**`borrarUltimoTiempo()`**  
Elimina el último tiempo registrado en la sesión actual, resetea el cronómetro y genera un nuevo scramble.

**`eliminarTiempoSeleccionado(tiempo: Tiempo)`**  
Elimina un tiempo específico por su `UUID` de la sesión activa y guarda los cambios.

**`eliminarTodosTiempos()`**  
Borra todos los tiempos de la sesión activa.

**`cambiarOrden(_ orden: Orden)`**  
Cambia el criterio de ordenamiento y recalcula `tiemposRecorrer`.

**`borrarCategoria(sesionAEliminar: Sesion)`**  
Elimina una sesión de la lista. Si era la sesión activa, selecciona automáticamente la primera disponible.

**`nuevoScramble()`**  
Genera y asigna un nuevo scramble para la categoría activa.

---

## 6. Vistas (Views)

### 6.1 `ContentView` — Vista Raíz

Contiene un `TabView` con las pestañas principales de la app: Cronómetro, Lista de Tiempos, Estadísticas y Categorías. Instancia y comparte el `RubikViewModel` con todas las vistas hijas.

### 6.2 `CronometroView` — Pantalla del Cronómetro

Vista central de la app. Muestra:

- El nombre de la sesión activa con emoji 🍀 y botón de borrar último tiempo (ícono de basura rojo).
- El **scramble actual** adaptando el tamaño de fuente según la categoría (más grande para 3x3, más pequeño para Megaminx o 7x7).
- El área táctil del cronómetro (`TimerAreaView`).
- Las estadísticas rápidas al pie (`EstadisticasCronometroView`).

Mientras el timer corre, oculta la barra de tabs para una experiencia de pantalla completa.

### 6.3 `TimerAreaView` — Área del Timer

Componente táctil que gestiona el inicio y parada del cronómetro mediante interacción con la pantalla (press and hold). Recibe el estado del timer como `@Binding` y llama a `registrarNuevoTiempo()` al soltar.

### 6.4 `EstadisticasCronometroView` — Stats Rápidas

Panel de 3 columnas visible debajo del cronómetro cuando no está corriendo:

- **Columna izquierda (cyan):** Total de solves, Media, Peor y Mejor tiempo.
- **Columna central (gris):** Últimos 5 tiempos con colores: azul para el mejor y rojo para el peor.
- **Columna derecha (rojo):** Mo3, Ao5, Ao12 y Ao50 actuales.

### 6.5 `CategoriasView` — Gestión de Sesiones

Lista todas las sesiones usando `ForEach` sobre `vm.tiemposPrincipal`. Permite:

- **Agregar** nuevas sesiones con el botón `+` (abre `CrearCategoriaView` en un sheet).
- **Eliminar** sesiones con confirmación mediante `Alert`. Impide eliminar si solo queda una sesión.

### 6.6 `ListaTiemposView` y `TiempoRowView` — Lista de Tiempos

Muestra todos los tiempos de la sesión activa en orden configurable. Cada fila (`TiempoRowView`) muestra el tiempo formateado, la fecha y el scramble utilizado, con opción de eliminar individualmente.

### 6.7 `EstadisticasView` — Estadísticas Avanzadas

Pantalla dedicada a estadísticas profundas dividida en subvistas:

- **`TiemposBasicosView`:** Media global, mejor/peor tiempo, desviación estándar.
- **`TiemposActualesView`:** Promedios actuales (Ao5, Ao12, Ao50, Ao100).
- **`TiemposPBView`:** Mejores promedios históricos (PB Ao5, PB Ao12, etc.) con sus tiempos constitutivos.

---

## 7. Funciones Utilitarias

### 7.1 `funciones.swift` — Funciones Generales

|Función|Descripción|
|---|---|
|`formatoTiempo(_ segundos: Double) -> String`|Convierte segundos a formato `M:SS.mmm` o `SS.mmm`|
|`formatoFecha(_ fecha: Date) -> String`|Formatea una fecha a `dd/MM/yy HH:mm` en locale español|
|`ft(_ segundos: Double) -> String`|Alias de `formatoTiempo`, mismo comportamiento|
|`obtenerMejorPeor(listaTiempos:tipo:) -> Double`|Retorna el mínimo o máximo de una lista de tiempos|
|`scrambleMostrar(categoria:) -> String`|Enrutador que llama al generador de scramble correcto según categoría|
|`convertirAHoras(_ horaTexto: String) -> Double`|Convierte texto `"M:SS"` a segundos Double|
|`ordenarLista(_ lista: [Tiempo]) -> [Tiempo]`|Ordena una lista de `Tiempo` por duración usando **Quicksort recursivo**|
|`obtenerTiemposRecorrer(categoria:nombreCategoria:listaSesiones:)`|Obtiene los tiempos de una sesión específica|
|`obtenerSesionActual(categoria:nombreCategoria:listaSesiones:)`|Obtiene el objeto `Sesion` activa|
|`obtenerTiempos(sesion:) -> [Double]`|Extrae solo los valores `Double` de una sesión|
|`ordentiemposMostrar(orden:catSele:nomSele:tPrincipal:)`|Retorna tiempos ordenados según el criterio `Orden` activo|

> **Nota sobre `ordenarLista`:** Implementa el algoritmo **Quicksort** de forma recursiva con pivote en el centro del array, lo que demuestra dominio de algoritmos de ordenamiento.

### 7.2 `funcionesEstadisticas.swift` — Cálculos Estadísticos

|Función|Descripción|
|---|---|
|`avg(tiempos:cantidad:) -> Double`|Calcula el Average of N (Ao5, Ao12...) descartando el mejor y peor tiempo del grupo|
|`media(tiempos:cantidad:) -> Double`|Calcula la Mean of N (Mo3) sumando los últimos N tiempos|
|`PBavg(tiempos:x:) -> [Double]`|Encuentra el mejor Average histórico de tamaño X (Personal Best)|
|`PBmo3(lista:) -> [Double]`|Encuentra la mejor Mean of 3 histórica|
|`desviacion(valores:) -> String`|Calcula la desviación estándar muestral de una lista de tiempos|
|`grafica(valores:) -> [Item]`|Convierte una lista de tiempos en items para graficar|

> **Cálculo de Average (WCA estándar):** La función `avg` sigue la norma oficial de la WCA: toma los últimos N tiempos, elimina el mejor y el peor, y promedia los restantes. Esto es la forma oficial de calcular Ao5, Ao12, Ao50 y Ao100 en competencias.

---

## 8. Generadores de Scrambles

Cada archivo en `Funciones/generadores/` contiene la lógica para generar una secuencia de movimientos aleatoria válida para su tipo de puzzle. La función `scrambleMostrar(categoria:)` actúa como enrutador central.

|Archivo|Función generadora|Categorías soportadas|
|---|---|---|
|`gen3.swift`|`generador3()`, `generador2()`, `generador3bld()`|3x3, 2x2, 3x3 OH, 3x3 BLD|
|`gen4.swift`|`generar6_7(tamaño: 4)`|4x4|
|`gen5.swift`|`generador5()`|5x5|
|`gen6-7.swift`|`generar6_7(tamaño: 6/7)`|6x6, 7x7|
|`genMega.swift`|`generarMega()`|Megaminx|
|`genPyra.swift`|`generadorPyra()`|Pyraminx|
|`genSkewb.swift`|`generadorSkewb()`|Skewb|
|`genSq1.swift`|`generadorSq1()`|Square-1|

---

## 9. Categorías Soportadas

La app soporta los siguientes tipos de puzzle, cubriendo la mayoría de eventos WCA (World Cube Association):

|Categoría|Tipo de Puzzle|
|---|---|
|3x3|Cubo de Rubik estándar|
|2x2|Pocket Cube|
|4x4|Revenge Cube|
|5x5|Professor's Cube|
|6x6|V-Cube 6|
|7x7|V-Cube 7|
|3x3 OH|3x3 con una sola mano (One-Handed)|
|3x3 BLD|3x3 con los ojos vendados (Blindfolded)|
|Pyraminx|Tetraedro de 4 capas|
|Megaminx|Dodecaedro|
|Skewb|Cubo con movimientos diagonales|
|Square-1|Puzzle con cambio de forma|

---

## 10. Persistencia de Datos

La app utiliza **UserDefaults** como sistema de almacenamiento local, sin base de datos externa. Los datos se guardan bajo las siguientes claves:

|Clave|Contenido|Tipo|
|---|---|---|
|`"savedSesiones"`|Array completo de sesiones (JSON)|`Data`|
|`"categoriaSeleccionada"`|Categoría activa del usuario|`String`|
|`"nombreSeleccionada"`|Nombre de sesión activa|`String`|

La serialización usa `JSONEncoder` con estrategia de fechas `.iso8601` y la deserialización usa `JSONDecoder` con la misma estrategia, garantizando compatibilidad entre sesiones de la app.

---

## 11. Patrón de Arquitectura: MVVM

```
┌─────────────────────────────────────────────────┐
│                    VISTAS (View)                │
│  CronometroView · CategoriasView · Estadisticas │
│  ListaTiemposView · ContentView                 │
└───────────────────┬─────────────────────────────┘
                    │ @ObservedObject / @Published
┌───────────────────▼─────────────────────────────┐
│              VIEWMODEL                          │
│           RubikViewModel                        │
│  (lógica de negocio + estado de la UI)          │
└───────────────────┬─────────────────────────────┘
                    │ lee/escribe
┌───────────────────▼─────────────────────────────┐
│                  MODELO                         │
│    Sesion · Tiempo · Orden · TimerState         │
│         (ModeloTiempos.swift)                   │
└─────────────────────────────────────────────────┘
                    │ persiste
┌───────────────────▼─────────────────────────────┐
│              UserDefaults (JSON)                │
└─────────────────────────────────────────────────┘
```

Las vistas solo leen datos del ViewModel y llaman a sus métodos. Nunca modifican el modelo directamente.

---

## 12. Requisitos e Instalación

### Requisitos

- macOS con Xcode instalado (versión compatible con SwiftUI)
- iPhone con iOS 18 o superior (recomendado)
- Cuenta de desarrollador Apple (para ejecutar en dispositivo físico)

### Pasos de instalación

**1. Clonar el repositorio:**

```bash
git clone https://github.com/rlaur205/rubik-timer-swift.git
```

**2. Abrir el proyecto en Xcode:**

```bash
open TimerV3.xcodeproj
```

**3. Seleccionar target:** En Xcode, seleccionar un simulador de iPhone o un dispositivo físico conectado.

**4. Ejecutar:** Presionar `Cmd + R` o el botón ▶ en Xcode.

> No se requieren dependencias externas ni CocoaPods/SPM. El proyecto es completamente autónomo.

---

## 13. Funcionalidades Principales

- **Cronómetro táctil:** Inicia y detiene el timer con solo tocar la pantalla.
- **Scrambles automáticos:** Genera mezclas aleatorias específicas para cada tipo de puzzle al iniciar y después de cada solve.
- **Múltiples sesiones:** Soporte para crear y gestionar varias sesiones por categoría (ej: dos sesiones distintas de 3x3).
- **Estadísticas en tiempo real:** Muestra Mo3, Ao5, Ao12, Ao50 directamente debajo del cronómetro.
- **Estadísticas avanzadas:** Desviación estándar, mejores promedios históricos (PB) y gráficos de progreso.
- **Historial completo:** Lista de todos los tiempos con fecha y scramble, ordenable por fecha, ascendente o descendente.
- **Eliminación rápida:** Botón para borrar el último tiempo directamente desde la pantalla del cronómetro.
- **Persistencia automática:** Todos los datos se guardan automáticamente en el dispositivo entre sesiones.

==TimeCuber ofrece una experiencia nativa premium con soporte dinámico para **Modo Claro (Light)** y **Modo Oscuro (Dark)**, utilizando componentes de diseño modernos de iOS.==

### Detalles de Diseño (UX/UI)
- **Adaptabilidad:** Uso de `System Colors` y `Blur Effects` (Materiales) para una integración perfecta con iOS.
- **Gestos:** Soporte para menús contextuales y deslizamiento para acciones rápidas.
- **Visualización:** Gráficas dinámicas que muestran la fluctuación de tiempos y consistencia del usuario.
---

## 14. Posibles Mejoras Futuras

- Agregar soporte para penalizaciones (+2 y DNF) según las reglas WCA.
- Implementar sincronización en la nube (iCloud) para acceder a los tiempos desde múltiples dispositivos.
- Soporte para exportar los tiempos en formato CSV o compartirlos.
- Implementar notificaciones de nuevo récord personal (PB) al registrar un tiempo.
# Verificación de temas

Probado en iPhone 15, simulador iOS 27.2, el 18 de noviembre de 2026.

- Compilación Debug del proyecto TimerV3: correcta.
- Prueba de interfaz: selección de los ocho temas y captura de Ajustes y cronómetro de cada uno.
- Navegación por las cinco pestañas con Azul noche y Arena.
- Persistencia: Arena sigue seleccionado y el modo manual sigue activo tras cerrar y abrir la app.
- Modo del sistema: Claro al volver desde Cósmico con el sistema claro; Oscuro con el sistema oscuro.
- Arena fuerza esquema claro incluso con el sistema oscuro.
- Revisión visual: títulos grandes visibles y separadores actualizados al cambiar de tema.
- Las dos pruebas finales de interfaz pasaron, sin fallos. No se crearon ni borraron tiempos o sesiones.

`resumen.png` compara capturas reales del cronómetro en los ocho temas. Las imágenes individuales están en esta carpeta. `Antes/` contiene capturas de la versión instalada antes del cambio (que aún tenía cuatro pestañas).

Los demás controles de Ajustes conservan su estado visual local. Las pruebas se ejecutaron con un proyecto auxiliar en `/tmp/rubik-temas-ui`, sin añadir dependencias de pruebas al proyecto de la app.

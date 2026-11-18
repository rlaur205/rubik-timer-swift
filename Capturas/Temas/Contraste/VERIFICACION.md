# Regresión de contraste

Prueba ejecutada en iPhone 15 / iOS 27.2 con la app abierta:

- Azul noche con dispositivo claro y oscuro: título de Ajustes e iconos inactivos claros en ambos casos.
- Arena con dispositivo oscuro y claro: título e iconos oscuros.
- Tema del sistema activado: cambia entre Claro y Oscuro al alternar el dispositivo en vivo.

La prueba valida los píxeles de las regiones del título y del icono del cronómetro en la barra de pestañas. Resultado: sin fallos. También se revisaron las seis capturas exportadas. Compilación Debug correcta.

Corrección: se fija el colorScheme del entorno y de las barras al esquema del tema efectivo, manteniendo preferredColorScheme en la raíz. La paleta automática se sigue resolviendo a partir del entorno exterior del dispositivo.

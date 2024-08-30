# Ejercicio 4: Interfaz Serial Síncrona

Este ejercicio se enfoca en el desarrollo e implementación de una interfaz SPI (Serial Peripheral Interface) en FPGA, con la capacidad de controlar una pantalla LCD utilizando el protocolo SPI.

## Requisitos

1. **Implementación SPI**:
   - Utilizar un código de terceros con licencia libre para implementar la interfaz SPI en la FPGA.
   - La integración del módulo SPI en el diseño es responsabilidad del estudiante.

2. **Simulación**:
   - Realizar una simulación para verificar el cumplimiento del protocolo SPI con un único dispositivo esclavo.

3. **Configuración de LCD**:
   - Basado en la hoja de datos del controlador ST7789V, crear un procedimiento para configurar la pantalla LCD a través del SPI.
   - Puede utilizar bibliotecas de Arduino o ejemplos de repositorios como el de Sipeed TangNano-9K.
   - Documentar cada instrucción enviada al LCD por SPI.

4. **Diseño de Patrones de Color**:
   - Diseñar un sistema en el que el usuario pueda seleccionar, desde una computadora, dos configuraciones de patrones de color en la pantalla LCD.
   - Las configuraciones alternan entre dos colores; por ejemplo:
     - Configuración 1 (P1: Rojo, P2: Azul)
     - Configuración 2 (P1: Verde, P2: Azul)
   - El patrón de color se actualizará en la pantalla según la entrada del teclado de la laptop.

## Estructura del Proyecto

- `src/` - Contiene los códigos fuente en SystemVerilog.
- `sim/` - Contiene el archivo para la simulación.
- `cst/` - Archivo para la asignación de señales en la FPGA.

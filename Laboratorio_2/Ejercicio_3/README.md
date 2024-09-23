# Ejercicio 3: Interfaz Serial Asíncrona

Este ejercicio se enfoca en el desarrollo e implementación de una interfaz UART (Universal Asynchronous Receiver/Transmitter) en FPGA. 



https://github.com/user-attachments/assets/377935f2-2519-4580-a7be-7a05c8833ef0



## Requisitos

1. **Implementación UART**:
   - Desarrollar la interfaz UART usando un módulo de código libre.
   - La integración y verificación de su funcionamiento en la FPGA es responsabilidad del estudiante.

2. **Set de Pruebas**:
   - Crear un conjunto de pruebas para asegurar el correcto funcionamiento del módulo UART.

3. **Requisitos de Comunicación**:
   - La interfaz debe manejar comunicación serial bidireccional a 9600 baudios.

4. **Bloque de Pruebas**:
   - Desarrollar un bloque de pruebas que permita:
     - Enviar datos desde el teclado (del ejercicio 2) a una computadora personal.
     - Mostrar en los LEDs los datos recibidos desde la computadora.
   - La figura 3 ilustra el diagrama de bloques para la prueba física.

5. **Simulación**:
   - Realizar una simulación de integración total que incluya:
     - Bloques de teclado
     - LEDs
     - UART

## Estructura del Proyecto

- `src/` - Contiene los códigos fuente en SystemVerilog.
- `sim/` - Contiene el archivo para la simulación.
- `cst` - Archivo para la asignación de señales en la FPGA.
- `UART` - Contiene el módulo UART del repositorio y las simulaciones para comprobar su funcionamiento.

# Ejercicio 1: Diseño antirebotes y sincronizador

Este ejercicio implementa un sistema en SystemVerilog para eliminar rebotes y sincronizar entradas de pulsadores e interruptores, con un contador sincronizado y un testbench para verificar su funcionamiento.



https://github.com/user-attachments/assets/ba4c1b83-de5c-42a3-af68-2ad3a98ce1f7



## Requisitos

1. **Bloques Digitales**:
   Implementar módulos en SystemVerilog para:
   - Eliminar rebotes de los pulsadores.
   - Sincronizar entradas de pulsadores e interruptores.

2. **Contador de Pruebas**:
   Incluir un contador sincronizado con el reloj (`clk`), con las siguientes características:
   - Reset activo en bajo (`rst`).
   - Señal habilitadora activa en alto (`EN`) para controlar el incremento del contador.
   - Considerar que las señales con rebotes pueden provocar conteos indeseados.

3. **Pruebas en FPGA**:
   - Utilizar un pulsador de la tarjeta FPGA como entrada (`EN`) para el contador.
   - Asegurarse de que la señal pase por el bloque antirebote y sincronizador.

4. **Salida Visual**:
   - Mostrar la salida del contador en los LEDs de la tarjeta FPGA.

5. **Testbench**:
   - Crear un testbench para simular pulsos contaminados por rebotes.
   - Repetir simulaciones después de la implementación para verificar el funcionamiento correcto.

6. **Verificación en FPGA**:
   - Descargar el diseño a la FPGA.
   - Asignar correctamente las señales.
   - Verificar el funcionamiento del diseño en la FPGA.

## Estructura del Proyecto

- `src/` - Contiene el código fuente en SystemVerilog.
- `sim/` - Contiene el testbench para la simulación.
- `cst` - Contiene la asignación de señales en la FPGA.

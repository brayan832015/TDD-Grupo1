# Ejercicio 2: Interfaz para teclado hexadecimal

Este ejercicio se enfoca en el diseño e implementación de una interfaz de teclado hexadecimal utilizando SystemVerilog. 


https://github.com/user-attachments/assets/9b349777-de13-4c80-aa1f-ef3f8f890bbf




## Requisitos

1. **Análisis de Bloques**:
   - Analizar la función de los bloques
   - Prestar especial atención a la temporización de las señales y cómo fluyen desde la entrada hasta la salida del módulo.

2. **Diagramas**:
   - Basado en el análisis, definir:
     - Tablas de verdad
     - Diagramas de estado
     - Diagramas temporales para cada bloque

3. **Implementación de Bloques**:
   - Desarrollar cada bloque en SystemVerilog con un nivel de abstracción alto.
   - Validar cada sub-bloque individualmente para asegurar su correcto funcionamiento.

4. **Módulo Superior**:
   - Crear un módulo jerárquico que combine los sub-bloques.
   - Conectar las señales del pin header de la FPGA con la protoboard que contiene el teclado.

5. **Prueba de Simulación**:
   - Ejecutar una simulación del sistema completo.
   - Incluir escenarios de rebote en las teclas para verificar la robustez del diseño.

6. **Implementación en FPGA**:
   - Implementar el diseño a la FPGA.
   - Usar hardware adicional, como LEDs y/o un display de 7 segmentos, para demostrar el funcionamiento del sistema.

## Estructura del Proyecto

- `src/` - Contiene el código fuente en SystemVerilog.
- `sim/` - Contiene el archivo para la simulación.
- `cst` - Archivo de asignación de señales en la FPGA.

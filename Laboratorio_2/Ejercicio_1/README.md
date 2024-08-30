Diseño Antirebotes y Sincronizador en SystemVerilog
Este proyecto implementa un sistema en SystemVerilog para eliminar rebotes y sincronizar entradas de pulsadores e interruptores, con un contador sincronizado y un testbench para verificar su funcionamiento.

Requisitos
Bloques Digitales: Implementar módulos en SystemVerilog para:

Eliminar rebotes de los pulsadores.
Sincronizar entradas de pulsadores e interruptores.
Contador de Pruebas: Incluir un contador sincronizado con el reloj (clk), con las siguientes características:

Reset activo en bajo (rst).
Señal habilitadora activa en alto (EN) para controlar el incremento del contador.
Tener en cuenta que las señales con rebotes pueden provocar conteos indeseados.
Pruebas en FPGA:

Utilizar un pulsador de la tarjeta FPGA como entrada (EN) para el contador.
Asegurarse de que la señal pase por el bloque antirebote y sincronizador.
Salida Visual:

Mostrar la salida del contador en los LEDs de la tarjeta FPGA.
Testbench:

Crear un testbench para simular pulsos contaminados por rebotes.
Repetir simulaciones después de la implementación para verificar el funcionamiento correcto.
Verificación en FPGA:

Descargar el diseño a la FPGA.
Asignar correctamente las señales.
Verificar el funcionamiento del diseño en la FPGA.
Estructura del Proyecto
src/ - Contiene los archivos fuente en SystemVerilog.
debounce.sv - Módulo para eliminación de rebotes.
sync.sv - Módulo para sincronización de señales.
counter.sv - Módulo del contador.
tb/ - Contiene el testbench para la simulación.
tb_counter.sv - Testbench para el módulo del contador.
constraints.xdc - Archivo de restricciones para la asignación de señales en la FPGA.
Instrucciones
Desarrollo:

Implementa los módulos en SystemVerilog en la carpeta src/.
Simulación:

Usa el archivo tb_counter.sv en la carpeta tb/ para simular y verificar el diseño.
Implementación en FPGA:

Carga el diseño en la FPGA usando la herramienta de desarrollo correspondiente.
Asigna las señales adecuadamente y realiza pruebas para verificar el funcionamiento.
Verificación:

Comprueba que la salida del contador se visualiza correctamente en los LEDs de la FPGA.
Asegúrate de que el sistema maneje correctamente los rebotes y las señales sincronizadas.
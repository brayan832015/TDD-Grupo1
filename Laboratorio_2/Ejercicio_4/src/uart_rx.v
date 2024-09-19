module uart_rx (
    input wire clk,            // Reloj del sistema
    input wire reset,          // Señal de reset
    input wire uart_rx,        // Línea de recepción UART
    output reg [7:0] data_out, // Datos recibidos
    output reg data_ready      // Señal que indica que los datos están listos
);

    // Parámetros de configuración
    parameter BAUD_RATE = 9600; // Tasa de baudios
    parameter CLOCK_FREQ = 50000000; // Frecuencia del reloj (50MHz)
    parameter CLOCKS_PER_BIT = CLOCK_FREQ / BAUD_RATE; // Ciclos de reloj por bit

    // Estados de la máquina de estados
    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;
    
    reg [1:0] state;          // Estado actual
    reg [3:0] bit_count;      // Contador de bits recibidos
    reg [15:0] clock_counter;  // Contador de ciclos de reloj
    reg sample;               // Señal de muestreo
    reg [7:0] shift_reg;      // Registro de desplazamiento para recibir bits

    // Proceso principal
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            bit_count <= 0;
            clock_counter <= 0;
            data_out <= 0;
            data_ready <= 0;
            sample <= 0;
            shift_reg <= 0;
        end else begin
            case (state)
                IDLE: begin
                    data_ready <= 0;
                    // Esperar el inicio del bit (nivel bajo)
                    if (uart_rx == 0) begin
                        // Detección del inicio
                        state <= START;
                        clock_counter <= 0; // Reiniciar el contador
                    end
                end

                START: begin
                    // Esperar a que se estabilice el inicio
                    if (clock_counter < (CLOCKS_PER_BIT / 2)) begin
                        clock_counter <= clock_counter + 1;
                    end else begin
                        // Muestreo del primer bit de datos
                        state <= DATA;
                        bit_count <= 0;
                        clock_counter <= 0;
                    end
                end

                DATA: begin
                    // Muestreo de los bits de datos
                    if (clock_counter < CLOCKS_PER_BIT) begin
                        clock_counter <= clock_counter + 1;
                    end else begin
                        // Guardar el bit recibido en el registro de desplazamiento
                        shift_reg <= {uart_rx, shift_reg[7:1]};
                        bit_count <= bit_count + 1;
                        clock_counter <= 0;

                        // Comprobar si se han recibido los 8 bits
                        if (bit_count == 7) begin
                            state <= STOP; // Cambiar al estado de detección de parada
                        end
                    end
                end

                STOP: begin
                    // Esperar el bit de parada
                    if (clock_counter < CLOCKS_PER_BIT) begin
                        clock_counter <= clock_counter + 1;
                    end else begin
                        // Verificar el bit de parada (debe ser alto)
                        if (uart_rx == 1) begin
                            // Dato recibido correctamente
                            data_out <= shift_reg; // Almacenar los datos recibidos
                            data_ready <= 1; // Indicar que los datos están listos
                        end
                        state <= IDLE; // Regresar al estado inicial
                    end
                end
            endcase
        end
    end

endmodule

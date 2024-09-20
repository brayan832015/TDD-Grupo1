module spi_master (
    input wire clk,           // Reloj del sistema
    input wire reset,         // Señal de reinicio
    input wire start,         // Señal para comenzar la transmisión
    input wire [7:0] data_in, // Datos a enviar
    output reg spi_clk,       // Reloj SPI
    output reg spi_mosi,      // Señal MOSI
    input wire spi_miso,      // Señal MISO (no usado en este código, pero listo para futuras implementaciones)
    output reg chip_select,   // Chip select para SPI
    output reg done           // Señal para indicar la finalización de la transmisión
);

    // Parámetros de estado
    parameter IDLE = 2'b00, TRANSMIT = 2'b01, DONE = 2'b10;
    reg [1:0] state;         // Estado actual
    reg [3:0] bit_count;     // Contador de bits (máximo 8 bits)

    // Sincronización del reloj SPI
    reg [3:0] clk_divider;   // Divisor de reloj para reducir la velocidad del SPI
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            chip_select <= 1;  // Desactivar el chip al inicio
            spi_clk <= 0;
            bit_count <= 0;
            done <= 0;         // Asegurar que `done` está bajo
            clk_divider <= 0;  // Reiniciar el divisor de reloj
        end else begin
            case (state)
                IDLE: begin
                    chip_select <= 1;  // Mantener chip desactivado
                    spi_clk <= 0;
                    done <= 0;         // Asegurar que la señal `done` está en bajo
                    if (start) begin   // Comenzar cuando `start` es alto
                        chip_select <= 0; // Activar el chip
                        state <= TRANSMIT;
                        bit_count <= 8;   // Enviar 8 bits
                        clk_divider <= 0; // Reiniciar divisor de reloj
                    end
                end

                TRANSMIT: begin
                    clk_divider <= clk_divider + 1;
                    if (clk_divider == 4'b1000) begin // Ajustar la frecuencia del reloj SPI
                        spi_clk <= ~spi_clk; // Cambiar el reloj SPI
                        clk_divider <= 0;

                        if (spi_clk) begin
                            spi_mosi <= data_in[bit_count - 1]; // Enviar el bit actual
                            bit_count <= bit_count - 1;
                            if (bit_count == 0) begin
                                state <= DONE; // Terminar cuando todos los bits se envían
                            end
                        end
                    end
                end

                DONE: begin
                    chip_select <= 1; // Desactivar el chip
                    done <= 1;        // Indicar que la transmisión ha terminado
                    state <= IDLE;    // Volver al estado inicial
                end

            endcase
        end
    end

endmodule

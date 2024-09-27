module spi_master (
    input logic clk,           // Reloj del sistema
    input logic resetn,        // Señal de reset activo en bajo
    input logic start,         // Señal para comenzar la transmisión
    input logic [7:0] data_in, // Datos a enviar
    output logic spi_clk,      // Reloj SPI
    output logic spi_mosi,     // Señal MOSI
    input logic spi_miso,      // Señal MISO (no usado en este código)
    output logic chip_select,  // Chip select para SPI
    output logic done          // Señal para indicar la finalización de la transmisión
);

    typedef enum logic [1:0] {
        IDLE      = 2'b00,
        TRANSMIT  = 2'b01,
        DONE      = 2'b10
    } state_t;

    state_t state;
    logic [3:0] bit_count;
    logic [3:0] clk_divider;

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state <= IDLE;
            chip_select <= 1;  // Desactivar el chip al inicio
            spi_clk <= 0;
            bit_count <= 0;
            done <= 0;
            clk_divider <= 0;
        end else begin
            case (state)
                IDLE: begin
                    chip_select <= 1;  // Mantener chip desactivado
                    spi_clk <= 0;
                    done <= 0;
                    if (start) begin
                        chip_select <= 0; // Activar el chip
                        state <= TRANSMIT;
                        bit_count <= 8;
                        clk_divider <= 0;
                    end
                end

                TRANSMIT: begin
                    clk_divider <= clk_divider + 1;
                    if (clk_divider == 4'b1000) begin
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

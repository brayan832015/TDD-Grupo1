module spi_master (
    input wire clk,
    input wire reset,
    input wire [7:0] data_in,
    output reg spi_clk,
    output reg spi_mosi,
    input wire spi_miso,
    output reg chip_select
);
    // Lógica para el controlador SPI
    parameter IDLE = 2'b00, TRANSMIT = 2'b01, DONE = 2'b10;
    reg [1:0] state;
    reg [3:0] bit_count;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            chip_select <= 1;
            spi_clk <= 0;
            bit_count <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (data_in != 8'h00) begin // Si hay datos para enviar
                        chip_select <= 0; // Activa el chip
                        state <= TRANSMIT;
                        bit_count <= 8; // Número de bits a enviar
                    end
                end
                TRANSMIT: begin
                    spi_clk <= ~spi_clk; // Cambia el reloj SPI
                    spi_mosi <= data_in[bit_count - 1]; // Envía el bit
                    if (spi_clk) begin
                        bit_count <= bit_count - 1;
                        if (bit_count == 0) begin
                            state <= DONE; // Termina la transmisión
                        end
                    end
                end
                DONE: begin
                    chip_select <= 1; // Desactiva el chip
                    state <= IDLE; // Regresa al estado inicial
                end
            endcase
        end
    end
endmodule

module spi_master(
    input wire clk,         // Reloj de la FPGA
    input wire reset_n,     // Reset activo bajo
    input wire start,       // Señal para iniciar la transferencia
    input wire [7:0] data_in, // Datos a enviar
    output reg sclk,        // Señal de reloj SPI
    output reg mosi,        // Línea de datos SPI
    output reg cs_n,        // Selección de chip (activo bajo)
    output reg done         // Señal de fin de transmisión
);

    reg [7:0] shift_reg;    // Registro de desplazamiento para los datos
    reg [2:0] bit_count;    // Contador de bits
    reg active;             // Señal que indica si el SPI está activo
    reg [1:0] sclk_div;     // Divisor de frecuencia para el reloj SPI

    parameter SCLK_DIV = 2; // Ajusta la velocidad del reloj SPI según sea necesario

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            sclk <= 0;
            mosi <= 0;
            cs_n <= 1;
            done <= 0;
            active <= 0;
            sclk_div <= 0;
        end else begin
            if (start && !active) begin
                active <= 1;
                shift_reg <= data_in;
                bit_count <= 7;
                cs_n <= 0;
                done <= 0;
            end

            if (active) begin
                if (sclk_div == SCLK_DIV - 1) begin
                    sclk_div <= 0;
                    sclk <= ~sclk;

                    if (sclk) begin
                        mosi <= shift_reg[7];
                        shift_reg <= {shift_reg[6:0], 1'b0};
                        if (bit_count == 0) begin
                            active <= 0;
                            cs_n <= 1;
                            done <= 1;
                        end else begin
                            bit_count <= bit_count - 1;
                        end
                    end
                end else begin
                    sclk_div <= sclk_div + 1;
                end
            end
        end
    end
endmodule

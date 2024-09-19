module lcd_draw (
    input wire clk,
    input wire reset,
    input wire draw_en,
    input wire [23:0] color_config,
    output reg [7:0] grid_command,
    output reg done,
    output reg spi_start,     // Señal para iniciar la transmisión SPI
    output reg [7:0] spi_data, // Datos a enviar por SPI
    output reg [1:0] spi_cmd,  // Tipo de comando para el SPI (comando/data)
    input wire spi_ready       // Señal que indica que el SPI está listo
);
    // Parámetros para la grilla
    parameter GRID_ROWS = 10;    // Número de filas
    parameter GRID_COLS = 10;    // Número de columnas
    parameter CELL_WIDTH = 10;   // Ancho de cada celda en píxeles
    parameter CELL_HEIGHT = 10;  // Altura de cada celda en píxeles

    // Estado de la máquina de estados
    reg [3:0] row_count;
    reg [3:0] col_count;
    reg [7:0] current_x;         // Posición X actual
    reg [7:0] current_y;         // Posición Y actual
    reg [3:0] state;             // Estado actual de la FSM

    localparam IDLE = 0, DRAW = 1, SEND_COMMAND = 2, WAIT_SPI = 3;

    // Señales internas
    reg [23:0] current_color;
    reg [7:0] next_spi_data;
    reg [1:0] next_spi_cmd;
    reg next_spi_start;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            row_count <= 0;
            col_count <= 0;
            current_x <= 0;
            current_y <= 0;
            grid_command <= 0;
            done <= 0;
            state <= IDLE;
            spi_start <= 0;
            spi_data <= 0;
            spi_cmd <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (draw_en) begin
                        // Iniciar el dibujo
                        current_y <= 0;
                        col_count <= 0;
                        row_count <= 0;
                        done <= 0;
                        state <= DRAW;
                    end
                end

                DRAW: begin
                    if (row_count < GRID_ROWS) begin
                        if (col_count < GRID_COLS) begin
                            // Llamar a la lógica para enviar color (coordinar con SPI)
                            current_color <= color_config;
                            state <= SEND_COMMAND;
                        end else begin
                            // Reiniciar la posición X y pasar a la siguiente fila
                            current_x <= 0;
                            col_count <= 0;
                            current_y <= current_y + CELL_HEIGHT;
                            row_count <= row_count + 1;
                        end
                    end else begin
                        done <= 1;
                        state <= IDLE;
                    end
                end

                SEND_COMMAND: begin
                    // 1. Enviar comando para establecer área de columna (0x2A)
                    next_spi_cmd <= 2'b01;
                    next_spi_data <= 8'h2A;
                    next_spi_start <= 1;
                    state <= WAIT_SPI;
                end

                WAIT_SPI: begin
                    if (spi_ready) begin
                        spi_start <= next_spi_start;
                        spi_data <= next_spi_data;
                        spi_cmd <= next_spi_cmd;
                        next_spi_start <= 0;

                        if (next_spi_start == 1) begin
                            state <= DRAW;
                        end else begin
                            state <= IDLE;
                        end
                    end
                end
            endcase
        end
    end

endmodule

module lcd_draw (
    input wire clk,
    input wire reset,
    input wire draw_en,
    input wire [23:0] color_p1,   // Color 1 de la configuración
    input wire [23:0] color_p2,   // Color 2 de la configuración
    output reg done,
    output reg spi_start,
    output reg [7:0] spi_data,
    output reg [1:0] spi_cmd,
    input wire spi_ready
);

    // Parámetros para la grilla
    parameter GRID_ROWS = 5;     // Número de filas (5 filas de 27px)
    parameter GRID_COLS = 8;     // Número de columnas (8 columnas de 30px)
    parameter CELL_WIDTH = 30;   // Ancho de cada celda
    parameter CELL_HEIGHT = 27;  // Altura de cada celda

    // Estado de la máquina de estados
    reg [2:0] row_count;
    reg [2:0] col_count;
    reg [7:0] current_x;         // Posición X actual
    reg [7:0] current_y;         // Posición Y actual
    reg [3:0] state;             // Estado actual de la FSM
    reg [23:0] current_color;    // Color actual de la celda

    localparam IDLE = 0, DRAW = 1, SEND_COMMAND = 2, WAIT_SPI = 3;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            row_count <= 0;
            col_count <= 0;
            current_x <= 0;
            current_y <= 0;
            done <= 0;
            state <= IDLE;
            spi_start <= 0;
            spi_data <= 0;
            spi_cmd <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (draw_en) begin
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
                            // Alternar colores en columnas
                            if (col_count % 2 == 0) 
                                current_color <= color_p1; // P1 para columnas pares
                            else
                                current_color <= color_p2; // P2 para columnas impares
                            
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
                    // Enviar el comando de inicio SPI con el color de la celda
                    spi_start <= 1;
                    spi_data <= current_color[23:16];  // Color RGB
                    spi_cmd <= 2'b10;  // Asumimos que 2'b10 indica comando de datos
                    state <= WAIT_SPI;
                end

                WAIT_SPI: begin
                    if (spi_ready) begin
                        spi_start <= 0;
                        state <= DRAW;
                        col_count <= col_count + 1;
                    end
                end
            endcase
        end
    end
endmodule

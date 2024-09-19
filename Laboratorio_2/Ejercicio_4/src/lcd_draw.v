module lcd_draw (
    input wire clk,
    input wire reset,
    input wire draw_en,
    input wire [23:0] color_config,
    output reg [7:0] grid_command,
    output reg done,
    output reg spi_start, // Señal para iniciar la transmisión SPI
    output reg [7:0] spi_data, // Datos a enviar por SPI
    output reg [1:0] spi_cmd // Tipo de comando para el SPI (comando/data)
);
    // Parámetros para la grilla
    parameter GRID_ROWS = 10; // Número de filas
    parameter GRID_COLS = 10; // Número de columnas
    parameter CELL_WIDTH = 10; // Ancho de cada celda en píxeles
    parameter CELL_HEIGHT = 10; // Altura de cada celda en píxeles

    // Estado de la máquina de estados
    reg [3:0] row_count;
    reg [3:0] col_count;
    reg [7:0] current_x; // Posición X actual
    reg [7:0] current_y; // Posición Y actual
    reg state; // Estado actual de dibujo

    localparam IDLE = 0, DRAW = 1;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            row_count <= 0;
            col_count <= 0;
            current_x <= 0;
            current_y <= 0;
            grid_command <= 0;
            done <= 0;
            state <= IDLE;
            spi_start <= 0; // Iniciar sin transmisión SPI
            spi_data <= 0; // Datos inicializados
            spi_cmd <= 0; // Tipo de comando inicializado
        end else begin
            case (state)
                IDLE: begin
                    if (draw_en) begin
                        // Iniciar el dibujo
                        current_y <= 0; // Reiniciar Y para la nueva grilla
                        col_count <= 0; // Reiniciar columnas
                        row_count <= 0; // Reiniciar filas
                        state <= DRAW; // Cambiar al estado de dibujo
                    end
                end

                DRAW: begin
                    if (row_count < GRID_ROWS) begin
                        if (col_count < GRID_COLS) begin
                            // Enviar comando para dibujar el cuadro
                            send_color(current_x, current_y, color_config);
                            
                            // Actualizar posición para la siguiente celda
                            current_x <= current_x + CELL_WIDTH;
                            col_count <= col_count + 1;
                        end else begin
                            // Reiniciar la posición X y pasar a la siguiente fila
                            current_x <= 0;
                            col_count <= 0;
                            current_y <= current_y + CELL_HEIGHT;
                            row_count <= row_count + 1;
                        end
                    end else begin
                        done <= 1; // Dibujo completo
                        state <= IDLE; // Regresar al estado inicial
                    end
                end
            endcase
        end
    end

    // Procedimiento para enviar el color y dibujar un cuadro
    task send_color(input [7:0] x, input [7:0] y, input [23:0] color);
        begin
            // 1. Establecer coordenadas
            // Enviar comando para establecer el área de columna
            spi_cmd <= 2'b01; // Indicar que se enviará un comando
            spi_data <= 8'h2A; // Comando para establecer el área de columna
            spi_start <= 1; // Iniciar la transmisión SPI
            wait (spi_ready); // Esperar a que el SPI esté listo
            spi_start <= 0; // Finalizar la transmisión
            
            // Enviar coordenadas X
            spi_cmd <= 2'b10; // Indicar que se enviará un dato
            spi_data <= x; // Coordenada X inicial
            spi_start <= 1;
            wait (spi_ready);
            spi_start <= 0;

            spi_cmd <= 2'b10; // Indicar que se enviará un dato
            spi_data <= x + CELL_WIDTH - 1; // Coordenada X final
            spi_start <= 1;
            wait (spi_ready);
            spi_start <= 0;

            // 2. Establecer coordenadas de fila
            spi_cmd <= 2'b01; // Indicar que se enviará un comando
            spi_data <= 8'h2B; // Comando para establecer el área de fila
            spi_start <= 1;
            wait (spi_ready);
            spi_start <= 0;

            // Enviar coordenadas Y
            spi_cmd <= 2'b10; // Indicar que se enviará un dato
            spi_data <= y; // Coordenada Y inicial
            spi_start <= 1;
            wait (spi_ready);
            spi_start <= 0;

            spi_cmd <= 2'b10; // Indicar que se enviará un dato
            spi_data <= y + CELL_HEIGHT - 1; // Coordenada Y final
            spi_start <= 1;
            wait (spi_ready);
            spi_start <= 0;

            // 3. Enviar color para llenar el área
            spi_cmd <= 2'b01; // Indicar que se enviará un comando
            spi_data <= 8'h2C; // Comando para escribir en el RAM
            spi_start <= 1;
            wait (spi_ready);
            spi_start <= 0;

            // Enviar el color del área
            spi_cmd <= 2'b10; // Indicar que se enviará un dato
            spi_data <= color[23:16]; // Color Rojo
            spi_start <= 1;
            wait (spi_ready);
            spi_start <= 0;

            spi_cmd <= 2'b10; // Indicar que se enviará un dato
            spi_data <= color[15:8]; // Color Verde
            spi_start <= 1;
            wait (spi_ready);
            spi_start <= 0;

            spi_cmd <= 2'b10; // Indicar que se enviará un dato
            spi_data <= color[7:0]; // Color Azul
            spi_start <= 1;
            wait (spi_ready);
            spi_start <= 0;
        end
    endtask

endmodule

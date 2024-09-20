module top (
    input wire clk,            // Reloj principal
    input wire reset,          // Señal de reset global
    input wire rx,             // Línea de recepción UART
    output wire spi_sclk,      // Señal de reloj SPI
    output wire spi_mosi,      // Línea de datos MOSI SPI
    output wire spi_cs,        // Chip select de SPI
    output wire [7:0] leds     // Indicadores LED
);

    // Señales para UART
    wire [7:0] uart_data;
    wire uart_valid;

    // Señales para el controlador SPI
    wire spi_ready;
    wire spi_start;
    wire [7:0] spi_data;
    wire [1:0] spi_cmd;

    // Señales para la lógica de la pantalla
    wire draw_en;
    wire [23:0] color_config;
    wire draw_done;

    // UART RX para recibir configuraciones desde la laptop
    uart_rx(
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .data_out(uart_data),
        .data_valid(uart_valid)
    );

    // Control de configuración de color basado en la entrada UART
    color_control(
        .clk(clk),
        .reset(reset),
        .uart_data(uart_data),
        .uart_valid(uart_valid),
        .color_config(color_config),
        .draw_en(draw_en)
    );

    // Lógica de dibujo de la grilla en la pantalla LCD
    lcd_draw lcd(
        .clk(clk),
        .reset(reset),
        .draw_en(draw_en),
        .color_config(color_config),
        .grid_command(),       // No conectado en esta implementación
        .done(draw_done),
        .spi_start(spi_start),
        .spi_data(spi_data),
        .spi_cmd(spi_cmd),
        .spi_ready(spi_ready)
    );

    // Controlador SPI maestro
    spi_master(
        .clk(clk),
        .reset(reset),
        .spi_start(spi_start),
        .spi_data(spi_data),
        .spi_cmd(spi_cmd),
        .spi_ready(spi_ready),
        .spi_sclk(spi_sclk),
        .spi_mosi(spi_mosi),
        .spi_cs(spi_cs)
    );

    // Indicadores LED para debug o estados
    assign leds[7:0] = {draw_done, uart_valid, 6'b0}; // Indicadores simples de estado

endmodule

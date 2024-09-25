module top (
    input wire clk,                // Reloj del sistema (27M)
    input wire reset,              // Reset activo alto
    input wire toggle_color,       // Señal para alternar el patrón de color
    input wire ser_rx,             // Serial receive
    output wire ser_tx,            // Serial transmit
    output wire lcd_resetn,        // LCD reset (activa baja)
    output wire lcd_clk,           // LCD clock
    output wire lcd_cs,            // LCD chip select
    output wire lcd_rs,            // LCD register select
    output wire lcd_data,          // LCD data
    output reg [23:0] color_p1,    // Color 1
    output reg [23:0] color_p2     // Color 2
);

    // Señales intermedias
    wire [7:0] command;            // Comando de inicialización
    wire start_init;               // Señal de inicio de inicialización
    wire init_done;                // Señal de inicialización completada
    wire start_spi;                // Señal para comenzar la transmisión SPI
    wire [7:0] data_in;            // Datos a enviar a través de SPI
    wire spi_done;                 // Indica que la transmisión SPI está completa
    wire [7:0] data_rx;            // Datos recibidos a través de UART
    wire valid_data;               // Indica datos válidos recibidos
    wire data_ready;               // Indica que se ha recibido un dato completo

    // Instanciación del módulo color_control
    color_control color_ctrl (
        .clk(clk),
        .reset(reset),
        .toggle_color(toggle_color),
        .color_p1(color_p1),
        .color_p2(color_p2)
    );

    // Instanciación del módulo lcd_init
    lcd_init lcd_init_inst (
        .clk(clk),
        .reset(reset),
        .command(command),
        .start_init(start_init),
        .init_done(init_done)
    );

    // Instanciación del módulo lcd_draw
    lcd_draw lcd_draw_inst (
        .clk(clk),
        .resetn(~reset),           // Invertir reset para lcd_draw
        .ser_tx(ser_tx),
        .ser_rx(ser_rx),
        .lcd_resetn(lcd_resetn),
        .lcd_clk(lcd_clk),
        .lcd_cs(lcd_cs),
        .lcd_rs(lcd_rs),
        .lcd_data(lcd_data)
    );

    // Instanciación del módulo spi_master
    spi_master spi_master_inst (
        .clk(clk),
        .reset(reset),
        .start(start_spi),
        .data_in(data_in),
        .spi_clk(lcd_clk),       // Usar el mismo reloj para SPI
        .spi_mosi(lcd_data),     // Utilizando el puerto de datos de LCD como MOSI
        .spi_miso(1'b0),         // No se utiliza, pero se conecta a 0
        .chip_select(lcd_cs),    // Chip select de SPI
        .done(spi_done)          // Indica que la transmisión ha terminado
    );

    // Instanciación del módulo uart_rx
    uart_rx uart_rx_inst (
        .clk(clk),
        .rst(reset),
        .rx(ser_rx),
        .data_rx(data_rx),
        .valid_data(valid_data),
        .data_ready(data_ready)
    );

    // Lógica adicional para gestionar señales entre módulos, si es necesario

endmodule

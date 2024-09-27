module top (
    input logic clk,                // Reloj del sistema (27M)
    input logic resetn,             // Reset activo bajo
    input logic toggle_color,       // Señal para alternar el patrón de color
    input logic ser_rx,             // Serial receive
    output logic ser_tx,            // Serial transmit
    output logic lcd_resetn,        // LCD reset (activa baja)
    output logic lcd_clk,           // LCD clock
    output logic lcd_cs,            // LCD chip select
    output logic lcd_rs,            // LCD register select
    output logic lcd_data,          // LCD data
    output logic [23:0] color_p1,   // Color 1
    output logic [23:0] color_p2    // Color 2
);

    // Señales intermedias
    logic [7:0] command;
    logic start_init;
    logic init_done;
    logic start_spi;
    logic [7:0] data_in;
    logic spi_done;
    logic [7:0] data_rx;
    logic valid_data;
    logic data_ready;

    // Instanciación del módulo color_control
    color_control color_ctrl (
        .clk(clk),
        .resetn(resetn),             
        .toggle_color(toggle_color),
        .color_p1(color_p1),
        .color_p2(color_p2)
    );

    // Instanciación del módulo lcd_init
    lcd_init lcd_init_inst (
        .clk(clk),
        .resetn(resetn),            
        .command(command),
        .start_init(start_init),
        .init_done(init_done)
    );

    // Instanciación del módulo lcd_draw
    lcd_draw lcd_draw_inst (
        .clk(clk),
        .resetn(resetn),            
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
        .resetn(resetn),            
        .start(start_spi),
        .data_in(data_in),
        .spi_clk(lcd_clk),
        .spi_mosi(lcd_data),
        .spi_miso(1'b0),
        .chip_select(lcd_cs),
        .done(spi_done)
    );

    // Instanciación del módulo uart_rx
    uart_rx uart_rx_inst (
        .clk(clk),
        .resetn(resetn),            
        .rx(ser_rx),
        .data_rx(data_rx),
        .valid_data(valid_data),
        .data_ready(data_ready)
    );

endmodule

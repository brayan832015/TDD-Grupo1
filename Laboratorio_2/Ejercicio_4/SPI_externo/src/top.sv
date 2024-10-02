module top(
    input logic clk,          
    input logic rst,
    input logic rx,           
    output logic lcd_resetn,
    output logic spi_sclk,
    output logic spi_cs_l,
    output logic lcd_rs,
    output logic spi_data
);      

logic [7:0] data_rx;
logic WR2c;
logic [15:0] datain;
logic [5:0] counter;
logic spi_force_rst;

clock_divider clock_divider_inst (
    .clk(clk),   
    .rst(rst),    
    .clk_out(clk_out)   
);

uart_rx uart_inst (
    .clk(clk_out),
    .rx(rx),
    .rst(rst),
    .data_rx(data_rx),
    .WR2c(WR2c),
    .WR2d(WR2d),
    .hold_ctrl(hold_ctrl)
);

FSM FSM_inst (
    .clk(clk_out),          
    .rst(rst),
    .data_rx(data_rx),
    .counter(counter),
    .WR2c(WR2c),           
    .lcd_resetn(lcd_resetn),
    .spi_force_rst(spi_force_rst),
    .datain(datain),
    .lcd_rs(lcd_rs)
);

spi spi_inst (
    .clk(clk),
    .rst(spi_force_rst),
    .datain(datain),
    .spi_cs_l(spi_cs_l),
    .spi_sclk(spi_sclk),          
    .spi_data(spi_data),          
    .counter(counter)
);

endmodule

module top_tang_nano (
    input logic clk,
    input logic rst,
    input logic key,
    input logic c,
    input logic d,
    input logic rx,
    input logic resetn,
    output logic tx,
    output logic key_detect,
    output logic lcd_resetn,
    output logic lcd_clk,
    output logic lcd_cs,
    output logic lcd_rs,
    output logic lcd_data,
    output logic [1:0] count,
    output logic [7:0] leds
);

    LCD LCD(
    .clk(clk),          
    .resetn(resetn),       // Reset activo en bajo
    .rx(rx),       
    .tx(tx),      
    .lcd_resetn(lcd_resetn),
    .lcd_clk(lcd_clk),
    .lcd_cs(lcd_cs),
    .lcd_rs(lcd_rs),
    .lcd_data(lcd_data)
    );

    top_final top_final(
    .clk(clk),
    .rst(rst),
    .key(key), 
    .c(c),   
    .d(d),   
    .rx(rx),  
    .tx(tx), 
    .key_detect(key_detect),
    .count(count),
    .leds(leds) 
    );

endmodule
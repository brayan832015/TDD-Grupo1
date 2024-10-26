module top_nexys(
    input logic clk,
    input logic reset,
    output logic tx_A,
    input logic rx_A,
    output logic tx_B,
    input logic rx_B,
    output logic [15:0] leds,
    input logic [15:0] switches,
    input logic [3:0] buttons
    );

clk_wiz_0 PLL_clock (
    .clk(clk),              // input clk 100 MHz
    .clk_10MHz(clk_10MHz)   // output clk 10 MHz 
);

top_uart uart_a (
    .clk(clk_10MHz),
    .reset(reset),
    .wr_i(we_o),            
    .entrada_i(DataOut_o),
    .reg_sel_i(),       
    .addr_i(DataAddress_o),          
    .salida_o(DataIn_i), 
    .rx(rx_A),             
    .tx(tx_A)               
);

top_uart uart_b (
    .clk(clk_10MHz),
    .reset(reset),
    .wr_i(we_o),            
    .entrada_i(DataOut_o),
    .reg_sel_i(),       
    .addr_i(DataAddress_o),          
    .salida_o(DataIn_i), 
    .rx(rx_B),             
    .tx(tx_B)               
);

top_picorv32 cpu (
    .clk_i(clk_10MHz),
    .rst_i(reset),
    .ProgAddress_o(ProgAddress_o),
    .ProgIn_i(ProgIn_i),
    .DataAddress_o(DataAddress_o),
    .DataOut_o(DataOut_o),
    .DataIn_i(DataIn_i),
    .we_o(we_o)
);

switches_buttons switches_buttons (
    .clk(clk_10MHz),
    .rst(reset),
    .address(DataAddress_o),       
    .switches(switches),
    .buttons(buttons),
    .data_out(DataIn_i)
);

leds_register leds_register (
    .clk(clk_10MHz),
    .rst(reset),
    .address(DataAddress_o),
    .we(we_o),
    .data_in(DataOut_o),
    .led_output(leds)
);

// Falta ROM y RAM

endmodule

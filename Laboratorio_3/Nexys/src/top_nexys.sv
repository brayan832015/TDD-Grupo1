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

    logic clk_10MHz;
    logic [31:0] ProgAddress_o, ProgIn_i;
    logic [31:0] DataAddress_o, DataOut_o, DataIn_i;
    logic we_o;
    logic [31:0] data_from_switches_buttons;
    logic [31:0] data_from_uartA;
    logic [31:0] data_from_uartB;
    logic [31:0] data_from_RAM;

clk_wiz_0 PLL_clock (
    .clk(clk),              // input clk 100 MHz
    .clk_10MHz(clk_10MHz)   // output clk 10 MHz 
);

top_uart uart_a (
    .clk(clk_10MHz),
    .reset(reset),
    .wr_i(we_o),            
    .entrada_i(DataOut_o),
    .Address(DataAddress_o),           
    .salida_o(data_from_uartA), 
    .rx(rx_A),             
    .tx(tx_A)               
);

/* UART B no se utiliza momentáneamente
top_uart uart_b (
    .clk(clk_10MHz),
    .reset(reset),
    .wr_i(we_o),            
    .entrada_i(DataOut_o),
    .Address(DataAddress_o),          
    .salida_o(data_from_uartB), 
    .rx(rx_B),             
    .tx(tx_B)               
);
*/

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
    .data_out(data_from_switches_buttons)
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

// Multiplexor para asignar correctamente DataIn_i
    always_comb begin
        if (DataAddress_o == 32'h00002000) begin
            DataIn_i = data_from_switches_buttons;
        end 
        else if (DataAddress_o == 32'h00002010 || DataAddress_o == 32'h00002018 || DataAddress_o == 32'h0000201C) begin
            DataIn_i = data_from_uartA;
        end 
        else if (DataAddress_o == 32'h00002020 || DataAddress_o == 32'h00002028 || DataAddress_o == 32'h0000202C) begin
            DataIn_i = data_from_uartB;
        end 
        else if (DataAddress_o >= 32'h00040000) begin
            DataIn_i = data_from_RAM;
        end
    end

endmodule

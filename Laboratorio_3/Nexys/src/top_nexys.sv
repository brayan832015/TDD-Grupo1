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

    logic clk_10MHz, locked;
    logic [31:0] ProgAddress_o, ProgIn_i;
    logic [31:0] DataAddress_o, DataOut_o, DataIn_i;
    logic we_o, Enable_RAM;
    logic [31:0] data_from_switches_buttons;
    logic [31:0] data_from_uartA;
    logic [31:0] data_from_uartB;
    logic [31:0] data_from_RAM;
    logic [3:0] wstrb;
    logic [16:0] AddressRAM;


clk_wiz_0 PLL_clock (
    .clk(clk),              // input clk 100 MHz
    .locked(locked),
    .clk_10MHz(clk_10MHz)  // output clk 10 MHz
);

top_uartA uart_a (
    .clk(clk_10MHz),
    .reset(reset || ~locked),
    .wr_i(we_o),            
    .entrada_i(DataOut_o),
    .Address(DataAddress_o),           
    .salida_o(data_from_uartA), 
    .rx(rx_A),             
    .tx(tx_A)               
);

top_uartB uart_b (
    .clk(clk_10MHz),
    .reset(reset || ~locked),
    .wr_i(we_o),            
    .entrada_i(DataOut_o),
    .Address(DataAddress_o),          
    .salida_o(data_from_uartB), 
    .rx(rx_B),             
    .tx(tx_B)               
);

top_picorv32 cpu (
    .clk_i(clk_10MHz),
    .rst_i(reset || ~locked),
    .ProgAddress_o(ProgAddress_o),
    .ProgIn_i(ProgIn_i),
    .DataAddress_o(DataAddress_o),
    .DataOut_o(DataOut_o),
    .DataIn_i(DataIn_i),
    .wstrb(wstrb),
    .we_o(we_o)
);


switches_buttons switches_buttons (
    .clk(clk_10MHz),
    .rst(reset || ~locked),
    .address(DataAddress_o),       
    .switches(switches),
    .buttons(buttons),
    .data_out(data_from_switches_buttons)
);

leds_register leds_register (
    .clk(clk_10MHz),
    .rst(reset || ~locked),
    .address(DataAddress_o),
    .we(we_o),
    .data_in(DataOut_o),
    .led_output(leds)
);


ROM ROM (
  .clka(clk_10MHz),
  .addra(ProgAddress_o[10:2]),
  .douta(ProgIn_i)
);


RAM RAM (
  .clka(clk_10MHz),
  .ena(Enable_RAM), 
  .wea(wstrb), 
  .addra(AddressRAM),
  .dina(DataOut_o),
  .douta(data_from_RAM)
);


// Multiplexor para asignar correctamente DataIn_i
    always_comb begin
        AddressRAM = 17'd0;
        Enable_RAM = 1'b0;
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
            AddressRAM = DataAddress_o [22:2] - 17'h10000;
            Enable_RAM = 1'b1;
        end
    end

endmodule

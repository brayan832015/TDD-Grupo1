`timescale 1ns / 1ps

module top_nexys_tb;
    logic clk;
    logic reset;
    logic tx_A, rx_A;
    logic tx_B, rx_B;
    logic [15:0] leds;
    logic [15:0] switches;
    logic [3:0] buttons;

    top_nexys DUT (
        .clk(clk),
        .reset(reset),
        .tx_A(tx_A),
        .rx_A(rx_A),
        .tx_B(tx_B),
        .rx_B(rx_B),
        .leds(leds),
        .switches(switches),
        .buttons(buttons)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100 MHz clock
    end

    initial begin
        reset = 1;
        rx_A = 1;
        rx_B = 1;
        switches = 16'h0000;
        buttons = 4'b0000;

        #120; 
        reset = 0;
        #50;
        
        #50000;

        $stop;
    end

endmodule

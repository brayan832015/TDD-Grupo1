module switch_to_led (
    input [3:0] switches,
    output [3:0] leds
);

    wire [3:0] compl_2;
    // Calcular el complemento a 2
    assign compl_2 = ~switches + 4'b0001;
    assign leds = ~compl_2; //leds encienden con 0

endmodule

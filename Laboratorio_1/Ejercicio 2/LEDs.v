module switch_to_led (
    input [3:0] switches,
    output [3:0] leds
);

    // Calcular el complemento a 2
    assign leds = ~switches + 4'b0001;

endmodule

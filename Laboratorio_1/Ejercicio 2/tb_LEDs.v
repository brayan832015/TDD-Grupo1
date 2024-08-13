module tb_switch_to_led;

    reg [3:0] switches;
    wire [3:0] leds;

    // Instancia del módulo a probar
    switch_to_led uut (
        .switches(switches),
        .leds(leds)
    );

    initial begin
        // Inicializar las entradas
        switches = 4'b0000;
        #10; // Esperar 10 unidades de tiempo
        
        switches = 4'b0001;
        #10;
        
        switches = 4'b0010;
        #10;
        
        switches = 4'b0011;
        #10;
        
        switches = 4'b0100;
        #10;
        
        switches = 4'b0101;
        #10;
        
        switches = 4'b0110;
        #10;
        
        switches = 4'b0111;
        #10;
        
        switches = 4'b1000;
        #10;
        
        switches = 4'b1001;
        #10;
        
        switches = 4'b1010;
        #10;
        
        switches = 4'b1011;
        #10;
        
        switches = 4'b1100;
        #10;
        
        switches = 4'b1101;
        #10;
        
        switches = 4'b1110;
        #10;
        
        switches = 4'b1111;
        #10;
        
        $stop; // Detener la simulación
    end
endmodule

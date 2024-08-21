module tb_switch_to_led;

    reg [3:0] switches;
    wire [3:0] leds;
    integer i;

    // Instancia del módulo a probar
    switch_to_led uut (
        .switches(switches),
        .leds(leds)
    );

    initial begin
        // Inicializar las entradas
        switches = 4'b0000;
        // Ejecutar las pruebas para todos los valores posibles de switches
        for (i = 0; i < 16; i = i + 1) begin
            switches = i;
            #10; // Esperar 10 unidades de tiempo para cada valor
        end
        
        $stop; // Detener la simulación
    end
endmodule
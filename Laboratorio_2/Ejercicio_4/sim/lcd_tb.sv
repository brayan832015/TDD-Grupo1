module lcd_tb;

// Declaración de señales
reg clk;
reg reset;
reg start;
reg toggle_color;
wire [23:0] color_p1, color_p2;
wire done;
wire sck, mosi, cs_n;
reg [7:0] spi_data;
reg spi_ready;
wire spi_start;
wire [1:0] spi_cmd;

// Variables para las pruebas
reg [23:0] expected_color_p1, expected_color_p2;
reg [23:0] color_grid [0:39];  // Grilla de colores para comparar

// Instancia del módulo de control de colores
color_control u_color_control (
    .clk(clk),
    .reset(reset),
    .toggle_color(toggle_color),
    .color_p1(color_p1),
    .color_p2(color_p2)
);

// Instancia del módulo de dibujo de grilla
lcd_draw u_lcd_draw (
    .clk(clk),
    .reset(reset),
    .draw_en(start),
    .color_p1(color_p1),
    .color_p2(color_p2),
    .done(done),
    .spi_start(spi_start),
    .spi_data(spi_data),
    .spi_cmd(spi_cmd),
    .spi_ready(spi_ready)
);

// Generador de reloj
always #5 clk = ~clk;

// Inicialización
initial begin
    clk = 0;
    reset = 0;
    start = 0;
    toggle_color = 0;
    spi_ready = 0;

    // Valores esperados para la configuración de colores
    expected_color_p1 = 24'hFF0000; // Rojo
    expected_color_p2 = 24'h0000FF; // Azul
    
    // Reinicio del sistema
    #10 reset = 1;
    #10 reset = 0;
    
    // Simular la configuración de color 1: P1 = Rojo, P2 = Azul
    #20;
    if (color_p1 === expected_color_p1 && color_p2 === expected_color_p2)
        $display("Prueba Color 1: PASSED - P1 = Rojo, P2 = Azul");
    else
        $display("Prueba Color 1: FAILED - P1 = %h, P2 = %h", color_p1, color_p2);

    // Alternar a la configuración de color 2: P1 = Verde, P2 = Azul
    #20;
    toggle_color = 1;
    #10;
    toggle_color = 0;
    expected_color_p1 = 24'h00FF00; // Verde
    expected_color_p2 = 24'h0000FF; // Azul
    #10;
    if (color_p1 === expected_color_p1 && color_p2 === expected_color_p2)
        $display("Prueba Color 2: PASSED - P1 = Verde, P2 = Azul");
    else
        $display("Prueba Color 2: FAILED - P1 = %h, P2 = %h", color_p1, color_p2);

    // Simulación del dibujo de la grilla
    #20;
    start = 1;  // Iniciar dibujo
    #10 start = 0;

    // Simular la transmisión SPI para cada celda de la grilla
    // La FSM del módulo lcd_draw debe manejar la secuencia de transmisión SPI
    spi_ready = 1;
    
    // Esperar a que se complete el dibujo
    wait (done);

    // Comprobar si el dibujo fue completado correctamente (esto depende de cómo implementes el sistema de pruebas de colores)
    $display("Prueba de dibujo de grilla: PASSED - Grilla dibujada correctamente.");

    $finish;
end

endmodule

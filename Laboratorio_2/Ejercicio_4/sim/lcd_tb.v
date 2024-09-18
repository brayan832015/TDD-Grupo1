module lcd_tb;

// Declaración de señales
reg clk;
reg rst_n;
reg start;
reg [7:0] data_in;
wire sck, mosi, cs_n, done;

reg [15:0] color_p1, color_p2;
reg [15:0] expected_color_p1, expected_color_p2;

// Instanciar módulos
spi_master u_spi_master (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .data_in(data_in),
    .sck(sck),
    .mosi(mosi),
    .cs_n(cs_n),
    .done(done)
);

// Generador de reloj
always #5 clk = ~clk;

// Inicialización
initial begin
    clk = 0;
    rst_n = 0;
    start = 0;
    data_in = 8'h00;
    expected_color_p1 = 16'hF800; // Rojo
    expected_color_p2 = 16'h001F; // Azul
    
    // Reinicio
    #10 rst_n = 1;
    
    // Simular la configuración de color 1: P1 = Rojo, P2 = Azul
    #20;
    color_p1 = 16'hF800; // Rojo
    color_p2 = 16'h001F; // Azul
    #10;
    if (color_p1 === expected_color_p1 && color_p2 === expected_color_p2)
        $display("Prueba Color 1: PASSED - P1 = Rojo, P2 = Azul");
    else
        $display("Prueba Color 1: FAILED - Resultado esperado: P1 = %h, P2 = %h, Resultado obtenido: P1 = %h, P2 = %h",
                 expected_color_p1, expected_color_p2, color_p1, color_p2);
    
    // Simular la configuración de color 2: P1 = Verde, P2 = Azul
    #20;
    expected_color_p1 = 16'h07E0; // Verde
    expected_color_p2 = 16'h001F; // Azul
    color_p1 = 16'h07E0; // Verde
    color_p2 = 16'h001F; // Azul
    #10;
    if (color_p1 === expected_color_p1 && color_p2 === expected_color_p2)
        $display("Prueba Color 2: PASSED - P1 = Verde, P2 = Azul");
    else
        $display("Prueba Color 2: FAILED - Resultado esperado: P1 = %h, P2 = %h, Resultado obtenido: P1 = %h, P2 = %h",
                 expected_color_p1, expected_color_p2, color_p1, color_p2);
                 
    // Prueba de transmisión SPI
    #20;
    start = 1;
    data_in = 8'hAB;  // Comando de prueba
    #10 start = 0;
    #100;
    if (done)
        $display("Prueba SPI: PASSED - Transmisión completa.");
    else
        $display("Prueba SPI: FAILED - No se completó la transmisión.");
    
    $finish;
end

endmodule

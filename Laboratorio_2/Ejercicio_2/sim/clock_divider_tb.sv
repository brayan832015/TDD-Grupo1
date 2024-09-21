module clock_divider_tb();

    // Señales de prueba
    logic clk;
    logic rst;
    logic scan_clk;

    // Instancia del DUT (Device Under Test)
    clock_divider dut(
        .clk(clk),
        .rst(rst),
        .scan_clk(scan_clk)
    );

    always #1 clk = ~clk;

    // Secuencia de prueba
    initial begin
        // Inicializa las señales
        clk = 0;
        rst = 1;
        #100 rst = 0;  // Libera el reset después de 100 ns

        // Corre la simulación por un tiempo para observar los resultados
        #2432432;  // Ajusta el tiempo según sea necesario
        $finish;
    end

endmodule
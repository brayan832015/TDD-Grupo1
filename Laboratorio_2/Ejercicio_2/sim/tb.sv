module tb_clock_divider();

    // Señales de prueba
    logic clk;
    logic rst_n;
    logic scan_clk;

    // Instancia del DUT (Device Under Test)
    clock_divider dut (
        .clk(clk),
        .rst_n(rst_n),
        .scan_clk(scan_clk)
    );

    // Generador de clock de 27 MHz (~37ns periodo)
    initial begin
        clk = 0;
    end

    always #1 clk = ~clk;  // Período de 37 ns

    // Secuencia de prueba
    initial begin
        // Inicializa las señales
        rst_n = 0;
        #100 rst_n = 1;  // Libera el reset después de 100 ns

        // Corre la simulación por un tiempo para observar los resultados
        #999900;  // Ajusta el tiempo según sea necesario
        $finish;
    end

    // Monitoreo para ver los cambios de clock
    //initial begin
        //$monitor("Time: %0t | clk: %b | scan_clk: %b", $time, clk, scan_clk);
    //end
endmodule
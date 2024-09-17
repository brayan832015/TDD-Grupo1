module tb_spi_master;

    reg clk;
    reg reset_n;
    reg start;
    reg [7:0] data_in;
    wire sclk;
    wire mosi;
    wire cs_n;
    wire done;

    // Instancia del módulo SPI maestro
    spi_master uut (
        .clk(clk),
        .reset_n(reset_n),
        .start(start),
        .data_in(data_in),
        .sclk(sclk),
        .mosi(mosi),
        .cs_n(cs_n),
        .done(done)
    );

    // Generador de reloj
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Reloj de 100 MHz
    end

    // Secuencia de prueba
    initial begin
        // Inicializar señales
        reset_n = 0;
        start = 0;
        data_in = 8'hA5;  // Ejemplo de dato para SPI
        #20 reset_n = 1;

        // Iniciar la transmisión
        #30 start = 1;
        #10 start = 0; // Quitar start

        // Esperar a que termine
        wait(done);

        // Nueva transmisión
        #100 data_in = 8'h3C;
        #30 start = 1;
        #10 start = 0;

        wait(done);

        #100 $finish;
    end

    // Monitoreo de señales
    initial begin
        $monitor("Time: %d | Data: %h | sclk: %b | mosi: %b | cs_n: %b | Done: %b", 
                 $time, data_in, sclk, mosi, cs_n, done);
    end
endmodule

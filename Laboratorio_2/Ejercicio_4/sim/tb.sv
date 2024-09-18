module tb_spi_master;

    reg clk;
    reg reset_n;
    reg start;
    reg [7:0] data_in;
    wire sclk;
    wire mosi;
    wire cs_n;
    wire done;

    reg [7:0] expected_data; // Dato esperado para la comprobación
    reg error;               // Indica si ocurrió un error durante la transmisión
    reg success;             // Indica si la transmisión fue exitosa

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
        data_in = 8'hA5;  // Dato a enviar por SPI
        expected_data = 8'hA5; // Dato esperado para la comparación
        error = 0;
        success = 0;
        #20 reset_n = 1;

        // Iniciar la transmisión
        #30 start = 1;
        #10 start = 0; // Quitar start

        // Esperar a que termine
        wait(done);

        // Verificación
        if (uut.shift_reg != expected_data) begin
            $display("ERROR: Dato enviado: %h, Dato esperado: %h", uut.shift_reg, expected_data);
            error = 1;
        end else begin
            $display("SUCCESS: Dato enviado correctamente.");
            success = 1;
        end

        // Nueva transmisión
        #100 data_in = 8'h3C;
        expected_data = 8'h3C; // Actualizar dato esperado
        #30 start = 1;
        #10 start = 0;

        wait(done);

        // Verificación
        if (uut.shift_reg != expected_data) begin
            $display("ERROR: Dato enviado: %h, Dato esperado: %h", uut.shift_reg, expected_data);
            error = 1;
        end else begin

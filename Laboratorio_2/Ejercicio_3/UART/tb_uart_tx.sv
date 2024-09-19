module tb_uart_dual();

    // Clock and reset
    logic clk;
    logic rst;
    
    // UART signals between FPGA and Laptop
    logic fpga_tx, fpga_rx, laptop_tx, laptop_rx;
    
    // Teclado y LEDs para FPGA
    logic [3:0] teclado_fpga;
    logic key_detect_fpga;
    logic [7:0] leds_fpga;
    
    // Variables para pruebas aleatorias
    logic [7:0] random_data_rx;
    logic [3:0] random_key_fpga;
    logic [7:0] received_data_laptop; // Dato recibido por la laptop
    logic [7:0] received_data_fpga;   // Dato recibido por la FPGA

    // UART Timing Parameters
    localparam BAUD_PERIOD = 2813; // Number of clock cycles per bit at 9600 baud with 27 MHz clock
    
    // Loop counters
    int i, j;

    // Assign UART cross-connections with small delay to simulate propagation
    assign fpga_rx = laptop_tx; // FPGA receives data from laptop TX
    assign laptop_rx = fpga_tx; // Laptop receives data from FPGA TX
    
    // Instancia de la UART para la FPGA
    top_uart uart_fpga(
        .clk(clk),
        .rst(rst),
        .rx(fpga_rx),
        .tx(fpga_tx),
        .teclado(teclado_fpga),
        .key_detect(key_detect_fpga),
        .leds(leds_fpga)
    );
    
    // Instancia de la UART para la laptop
    top_uart uart_laptop(
        .clk(clk),
        .rst(rst),
        .rx(laptop_rx), 
        .tx(laptop_tx),  
        .teclado(), 
        .key_detect(),
        .leds()      
    );

    // Generación del clock (27 MHz)
    always #18.515 clk = ~clk; // 37.04ns -> 27 MHz

    // Task to wait for a full UART period
    task wait_for_uart_period();
        repeat (BAUD_PERIOD) @(posedge clk);
    endtask

    // Reset procedure
    initial begin
        clk = 0;
        rst = 1;
        #100;
        rst = 0;
        $display("Iniciando pruebas de transmisión y recepción UART (FPGA-Laptop)...\n");

        // Transmisión desde FPGA al Laptop (teclado 4x4)
        for (i = 0; i < 50; i++) begin
            // Generar un valor aleatorio de 4 bits para simular la tecla presionada en el teclado de FPGA
            random_key_fpga = $urandom_range(15, 0);
            teclado_fpga = random_key_fpga;
            key_detect_fpga = 1;
            wait_for_uart_period(); // Esperar el periodo de UART
            key_detect_fpga = 0;

            // Recibir el dato enviado por la FPGA en la laptop (simulado)
            received_data_laptop = 0; // Inicializar en 0
            wait_for_uart_period(); // Esperar por el bit de inicio (start bit)
            for (j = 0; j < 8; j++) begin
                wait_for_uart_period();
                received_data_laptop[j] = laptop_rx;
            end
            wait_for_uart_period(); // Esperar el bit de parada (stop bit)

            // Mostrar en consola el carácter enviado desde FPGA y recibido en laptop
            case (random_key_fpga)
                4'b0000: $display("FPGA envió: '0', laptop recibió: '%c'", received_data_laptop);
                4'b0001: $display("FPGA envió: '1', laptop recibió: '%c'", received_data_laptop);
                4'b0010: $display("FPGA envió: '2', laptop recibió: '%c'", received_data_laptop);
                4'b0011: $display("FPGA envió: '3', laptop recibió: '%c'", received_data_laptop);
                4'b0100: $display("FPGA envió: '4', laptop recibió: '%c'", received_data_laptop);
                4'b0101: $display("FPGA envió: '5', laptop recibió: '%c'", received_data_laptop);
                4'b0110: $display("FPGA envió: '6', laptop recibió: '%c'", received_data_laptop);
                4'b0111: $display("FPGA envió: '7', laptop recibió: '%c'", received_data_laptop);
                4'b1000: $display("FPGA envió: '8', laptop recibió: '%c'", received_data_laptop);
                4'b1001: $display("FPGA envió: '9', laptop recibió: '%c'", received_data_laptop);
                4'b1010: $display("FPGA envió: 'A', laptop recibió: '%c'", received_data_laptop);
                4'b1011: $display("FPGA envió: 'B', laptop recibió: '%c'", received_data_laptop);
                4'b1100: $display("FPGA envió: 'C', laptop recibió: '%c'", received_data_laptop);
                4'b1101: $display("FPGA envió: 'D', laptop recibió: '%c'", received_data_laptop);
                4'b1110: $display("FPGA envió: '*', laptop recibió: '%c'", received_data_laptop);
                4'b1111: $display("FPGA envió: '#', laptop recibió: '%c'", received_data_laptop);
                default: $display("FPGA envió: Desconocido, laptop recibió: '%c'", received_data_laptop);
            endcase

            #1000; // Wait for the UART transmission to complete
        end
        
        // Transmisión desde la Laptop hacia la FPGA
        for (i = 0; i < 50; i++) begin
            // Generar un valor ASCII aleatorio para simular la entrada desde la laptop
            random_data_rx = $urandom_range(127, 32); // Caracteres imprimibles en ASCII
            laptop_tx = 0; // Simula el start bit
            wait_for_uart_period(); // Esperar un ciclo para el start bit
            
            // Transmitir el dato desde la laptop
            for (j = 0; j < 8; j++) begin
                laptop_tx = random_data_rx[j];
                wait_for_uart_period(); // Esperar un ciclo por bit
            end

            laptop_tx = 1; // Simula el stop bit
            wait_for_uart_period();

            // Recibir el dato enviado por la laptop en la FPGA
            received_data_fpga = leds_fpga; // Los LEDs muestran el valor invertido de lo recibido
            
            // Mostrar el carácter recibido por la FPGA y el estado de los LEDs
            $display("Laptop envió: %c, LEDs FPGA: %b", random_data_rx, received_data_fpga);
            #1000; // Esperar a que la FPGA procese el dato recibido
        end
        
        $display("Pruebas finalizadas.\n");
        $finish;
    end
endmodule

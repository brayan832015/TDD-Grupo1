module tb_uart_dual();
    logic clk;
    logic rst;
    logic fpga_tx, fpga_rx, laptop_tx, laptop_rx;
    
    // Teclado y LEDs para FPGA
    logic [3:0] teclado_fpga;
    logic key_detect_fpga;
    logic [7:0] leds_fpga;
    
    // Pruebas aleatorias
    logic [7:0] random_data_rx;
    logic [3:0] random_key_fpga;
    logic [7:0] received_data_laptop; // Dato recibido por la laptop
    logic [7:0] received_data_fpga;   // Dato recibido por la FPGA

    localparam BAUD_PERIOD = 2813; // Número de ciclos de reloj por bit a 9600 baudios con 27 MHz
    
    int i, j;

    assign fpga_rx = laptop_tx; // FPGA recibe datos del TX de la laptop
    assign laptop_rx = fpga_tx; // Laptop recibe datos del TX de la FPGA
    
    // UART para la FPGA
    top_uart uart_fpga(.clk(clk), .rst(rst), .rx(fpga_rx), .tx(fpga_tx), .teclado(teclado_fpga), .key_detect(key_detect_fpga), .leds(leds_fpga));
    
    // UART para la laptop
    top_uart uart_laptop(.clk(clk), .rst(rst), .rx(laptop_rx), .tx(laptop_tx), .teclado(), .key_detect(), .leds());

    // Generación del clock (27 MHz)
    always #18.515 clk = ~clk; // Periodo de 37.04ns -> 27 MHz
    
    // Reset procedure
    initial begin
        clk = 0;
        rst = 1;
        #100;
        rst = 0;

        // FPGA a laptop
        for (i = 0; i < 50; i++) begin
            // Teclado de FPGA
            random_key_fpga = $urandom_range(15, 0);
            teclado_fpga = random_key_fpga;
            key_detect_fpga = 1;
            #BAUD_PERIOD;
            key_detect_fpga = 0;

            // Recibir el dato en la laptop
            received_data_laptop = 0; 
            #BAUD_PERIOD; // start bit
            for (j = 0; j < 8; j++) begin
                #BAUD_PERIOD;
                received_data_laptop[j] = laptop_rx;
            end
            #BAUD_PERIOD; // stop bit
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
            #1000;
        end
        
        // Laptop a FPGA
        for (i = 0; i < 50; i++) begin
            // ASCII aleatorio
            random_data_rx = $urandom_range(127, 32); // Caracteres imprimibles en ASCII
            laptop_tx = 0; // start bit
            #BAUD_PERIOD; 
            
            // Transmitir el dato desde la laptop
            for (j = 0; j < 8; j++) begin
                laptop_tx = random_data_rx[j];
                #BAUD_PERIOD;
            end

            laptop_tx = 1; // stop bit
            #BAUD_PERIOD;

            // Recibir el dato enviado por la laptop en la FPGA
            received_data_fpga = leds_fpga;
            $display("Laptop envió: %c, LEDs FPGA: %b", random_data_rx, received_data_fpga);
            #1000; 
        end
        $finish;
    end
endmodule

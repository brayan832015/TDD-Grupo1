//////////////// Testbench simulando imágenes con tamaño de 5 bytes y cambios en el ensamblador para esto /////////////////////////////////////////////////

`timescale 1ns / 1ps

module top_nexys_tb;
    logic clk;
    logic reset;
    logic tx_A, rx_A;
    logic tx_B, rx_B;
    logic [15:0] leds;
    logic [15:0] switches;
    logic [3:0] buttons;
    logic [7:0] datos_aleatorios;
    logic [7:0] comando_inicio;
    logic clk_10;

    // Ciclos por bit a 9600 baudios
    parameter Ciclos_por_Bit = 1042; // Basado en 10 MHz de frecuencia de reloj

    top_nexys DUT (
        .clk(clk),
        .reset(reset),
        .tx_A(tx_A),
        .rx_A(rx_A),
        .tx_B(tx_B),
        .rx_B(rx_B),
        .leds(leds),
        .switches(switches),
        .buttons(buttons)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100 MHz clock
    end
    
    initial begin
        #2345;    
        clk_10 = 0;
        forever #50 clk_10 = ~clk_10;
    end

    initial begin
        reset = 1;
        rx_A = 1;
        rx_B = 1;
        switches = 16'h0000;
        buttons = 4'b0000;

        #120; 
        reset = 0;
        #50;
        
        // comando de inicio
        comando_inicio = 8'b11111111;
        send_uart_byte_to_rx(comando_inicio);
        wait_cycles(20);
        
        #50;
        
        // Pruebas de recepción (RX)
        for (int i = 0; i < 5; i++) begin
            datos_aleatorios = $urandom_range(0, 255); // byte aleatorio

            // Enviar byte en la línea RX
            send_uart_byte_to_rx(datos_aleatorios);
            
            wait_cycles(10);

            #50; // Espera entre pruebas
        end
        
        
        send_uart_byte_to_rx(comando_inicio);
        wait_cycles(20);
        
        #50;
        
        
        // Pruebas de recepción (RX)
        for (int i = 0; i < 5; i++) begin
            datos_aleatorios = $urandom_range(0, 255); // byte aleatorio

            // Enviar byte en la línea RX
            send_uart_byte_to_rx(datos_aleatorios);
            
            wait_cycles(10);

            #50; // Espera entre pruebas
        end
        
        
        
        send_uart_byte_to_rx(comando_inicio);
        wait_cycles(20);
        
        #50;
        
        // Pruebas de recepción (RX)
        for (int i = 0; i < 5; i++) begin
            datos_aleatorios = $urandom_range(0, 255); // byte aleatorio

            // Enviar byte en la línea RX
            send_uart_byte_to_rx(datos_aleatorios);
            
            wait_cycles(10);

            #50; // Espera entre pruebas
        end
        
        
        
        send_uart_byte_to_rx(comando_inicio);
        wait_cycles(20);
        
        #50;
        
        // Pruebas de recepción (RX)
        for (int i = 0; i < 5; i++) begin
            datos_aleatorios = $urandom_range(0, 255); // byte aleatorio

            // Enviar byte en la línea RX
            send_uart_byte_to_rx(datos_aleatorios);
            
            wait_cycles(10);

            #50; // Espera entre pruebas
        end
        
        
        
        send_uart_byte_to_rx(comando_inicio);
        wait_cycles(20);
        
        #50;
        
        // Pruebas de recepción (RX)
        for (int i = 0; i < 5; i++) begin
            datos_aleatorios = $urandom_range(0, 255); // byte aleatorio

            // Enviar byte en la línea RX
            send_uart_byte_to_rx(datos_aleatorios);
            
            wait_cycles(10);

            #50; // Espera entre pruebas
        end
        
        
        
        send_uart_byte_to_rx(comando_inicio);
        wait_cycles(20);
        
        #50;
        
        // Pruebas de recepción (RX)
        for (int i = 0; i < 5; i++) begin
            datos_aleatorios = $urandom_range(0, 255); // byte aleatorio

            // Enviar byte en la línea RX
            send_uart_byte_to_rx(datos_aleatorios);
            
            wait_cycles(10);

            #50; // Espera entre pruebas
        end
        
        
        
        send_uart_byte_to_rx(comando_inicio);
        wait_cycles(20);
        
        #50;
        
        // Pruebas de recepción (RX)
        for (int i = 0; i < 5; i++) begin
            datos_aleatorios = $urandom_range(0, 255); // byte aleatorio

            // Enviar byte en la línea RX
            send_uart_byte_to_rx(datos_aleatorios);
            
            wait_cycles(10);

            #50; // Espera entre pruebas
        end
        
        
        send_uart_byte_to_rx(comando_inicio);
        wait_cycles(20);
        
        #50;
        
        // Pruebas de recepción (RX)
        for (int i = 0; i < 5; i++) begin
            datos_aleatorios = $urandom_range(0, 255); // byte aleatorio

            // Enviar byte en la línea RX
            send_uart_byte_to_rx(datos_aleatorios);
            
            wait_cycles(10);

            #50; // Espera entre pruebas
        end
        
        
        
        send_uart_byte_to_rx(comando_inicio);
        wait_cycles(20);
        
        #50;
        
        // Pruebas de recepción (RX)
        for (int i = 0; i < 5; i++) begin
            datos_aleatorios = $urandom_range(0, 255); // byte aleatorio

            // Enviar byte en la línea RX
            send_uart_byte_to_rx(datos_aleatorios);
            
            wait_cycles(10);

            #50; // Espera entre pruebas
        end
        
        
        ////////////////////////////////Envío imágenes a la FPGA Tang Nano 9k/////////////////////////////////////////        
        
        send_uart_byte_to_rx_B(8'b00110001); // Simular llegada de la otra FPGA a RX 0x31 = 1
        wait_cycles(10);
        #50;
        wait_cycles(200);
        
        
        send_uart_byte_to_rx_B(8'b00110010); // Simular llegada de la otra FPGA a RX 0x32 = 2
        wait_cycles(10);
        #50;
        wait_cycles(200);
        
        
        send_uart_byte_to_rx_B(8'b00110011); // Simular llegada de la otra FPGA a RX 0x33 = 3
        wait_cycles(10);
        #50;
        wait_cycles(200);
        
        
        send_uart_byte_to_rx_B(8'b00110100); // Simular llegada de la otra FPGA a RX 0x34 = 4
        wait_cycles(10);
        #50;
        wait_cycles(200);
        
        
        send_uart_byte_to_rx_B(8'b00110101); // Simular llegada de la otra FPGA a RX 0x35 = 5
        wait_cycles(10);
        #50;
        wait_cycles(200);
        
        
        send_uart_byte_to_rx_B(8'b00110110); // Simular llegada de la otra FPGA a RX 0x36 = 6
        wait_cycles(10);
        #50;
        wait_cycles(200);
        
        
        send_uart_byte_to_rx_B(8'b00110111); // Simular llegada de la otra FPGA a RX 0x37 = 7
        wait_cycles(10);
        #50;
        wait_cycles(200);
        
        
        send_uart_byte_to_rx_B(8'b00111000); // Simular llegada de la otra FPGA a RX 0x38 = 8
        wait_cycles(10);
        #50;
        wait_cycles(200);
        
        send_uart_byte_to_rx_B(8'b00110001); // Simular llegada de la otra FPGA a RX 0x31 = 1
        wait_cycles(10);
        #50;
        wait_cycles(200);
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        #500000;

        $stop;
    end

////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // Task para enviar un byte de datos al UART (RX)
    task send_uart_byte_to_rx(input [7:0] data);
        bit [9:0] frame;
        frame = {1'b1, data, 1'b0}; // Bit de parada, datos, bit de inicio

        // Simular la transmisión en `rx` bit por bit
        for (int i = 0; i < 10; i++) begin
            rx_A = frame[i];
            wait_cycles(1); 
        end
    endtask

////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // Task para esperar un número específico de ciclos de reloj
    task wait_cycles(input int num_cycles);
    begin
        repeat (num_cycles * Ciclos_por_Bit) @(posedge clk_10);
    end
    endtask
    
////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // Task para enviar un byte de datos al UART (RX)
    task send_uart_byte_to_rx_B(input [7:0] data);
        bit [9:0] frame;
        frame = {1'b1, data, 1'b0}; // Bit de parada, datos, bit de inicio

        // Simular la transmisión en `rx` bit por bit
        for (int i = 0; i < 10; i++) begin
            rx_B = frame[i];
            wait_cycles(1); 
        end
    endtask

////////////////////////////////////////////////////////////////////////////////////////////////////////////

endmodule


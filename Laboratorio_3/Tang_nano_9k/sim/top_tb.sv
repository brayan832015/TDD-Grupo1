//////////////// Testbench simulando imágenes con tamaño de 5 bytes y cambios en el ensamblador para esto /////////////////////////////////////////////////

`timescale 1ns / 1ps

module tb_tang_nano_9k;
    logic clk;
    logic rst;
    logic tx, rx;
    logic [7:0] leds;
    logic [7:0] datos_aleatorios;

    // Ciclos por bit a 9600 baudios
    parameter Ciclos_por_Bit = 2813; // Basado en 27 MHz de frecuencia de reloj

    top_tang_nano DUT (
        .clk(clk),
        .rst(rst),
        .key(key),
        .c(c),
        .d(d),
        .rx(rx),
        .resetn(1'b1),
        .tx(tx),
        .key_detect(key_detect),
        .lcd_resetn(lcd_resetn),
        .lcd_clk(lcd_clk),
        .lcd_cs(lcd_cs),
        .lcd_rs(lcd_rs),
        .lcd_data(lcd_data),
        .count(count),
        .leds(leds)
    );    

    initial begin
        clk = 0;
        forever #18.515 clk = ~clk;  // 27 MHz clock
    end

    initial begin
        rst = 1;
        rx = 1;

        #120; 
        rst = 0;
        #50;

////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        // Pruebas de recepción (RX)
        for (int i = 0; i < 64800; i++) begin
            datos_aleatorios = $urandom_range(0, 255); // byte aleatorio

            // Enviar byte en la línea RX
            send_uart_byte_to_rx(datos_aleatorios);
            
            wait_cycles(10);

            #50; // Espera entre pruebas
        end

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
            rx = frame[i];
            wait_cycles(1); 
        end
    endtask

////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // Task para esperar un número específico de ciclos de reloj
    task wait_cycles(input int num_cycles);
        begin
            repeat (num_cycles * Ciclos_por_Bit) @(posedge clk);
        end
    endtask
    
////////////////////////////////////////////////////////////////////////////////////////////////////////////

endmodule

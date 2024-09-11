module tb_uart_tx;
    logic clk;
    logic rst;
    logic [7:0] data_tx;
    logic transmit;
    logic tx;
    logic [7:0] datos_aleatorios;
    int pruebas_pasadas = 0;
    int pruebas_fallidas = 0;
    bit frame_correcto;

    // Número de ciclos de reloj para 9600 baudios (clk/baudios)
    parameter Ciclos_por_Bit = 2813; 

    uart_tx dut (.clk(clk), .rst(rst), .data_tx(data_tx), .transmit(transmit), .tx(tx));

    // Generar reloj de 27MHz de la Tang Nano 9k (37.03 ns de periodo)
    always #18.515 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        transmit = 0;
        #100; // reset por los primeros 100 ns

        rst = 0;

        // 50 pruebas aleatorias
        for (int i = 0; i < 50; i++) begin
            datos_aleatorios = $urandom_range(0, 255); // Byte aleatorio

            // Enviar byte por UART
            send_uart_byte(datos_aleatorios);

            // Verificar el byte transmitido
            verify_uart_byte(datos_aleatorios);

            if (frame_correcto) begin
                $display("Prueba %0d exitosa: Los datos transmitidos son correctos (0x%h).", i+1, datos_aleatorios);
                pruebas_pasadas++;
            end
            else begin
                $display("Prueba %0d fallida: Los datos transmitidos son correctos. Esperado 0x%h.", i+1, datos_aleatorios);
                pruebas_fallidas++;
            end

            #50000; // Wait between tests
        end

        // Final results
        $display("Pruebas exitosas: %0d", pruebas_pasadas);
        $display("Pruebas fallidas: %0d", pruebas_fallidas);

        $finish;
    end

    // Task para enviar un byte de datos por UART
    task send_uart_byte(input [7:0] data);
    begin
        data_tx = data;
        
        // Inicio transmisión 
        transmit = 1;
        wait (tx == 0); // tx=0 indica el inicio de los datos a transmitir
        transmit = 0; // Desactiva la señal de transmisión para que el UART funcione   
    end
    endtask

    // Task para verificar la tranmisión del UART
    task verify_uart_byte(input [7:0] expected_data);
        bit [9:0] expected_frame;
        expected_frame = {1'b1, expected_data, 1'b0}; // Bit de parada (tx=1), Datos (8 bits), Bit de inicio (tx=0)}

        // Revisar cada bit del frame
        for (int i = 0; i < 10; i++) begin
            wait_cycles(1);
            if (tx !== expected_frame[i]) begin
                $display("Error en el bit %0d: esperado = %b, recibido = %b", i, expected_frame[i], tx);
                frame_correcto = 0; // error en la transmisión
            end
            else begin
                frame_correcto = 1;
            end
        end
    endtask

    // Task para esperar un número específico de ciclos de reloj
    task wait_cycles(input int num_cycles);
    begin
        repeat (num_cycles * Ciclos_por_Bit) @(posedge clk);
    end
    endtask
endmodule

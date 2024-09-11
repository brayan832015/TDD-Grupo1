module tb_uart_rx;
    logic clk;
    logic rst;
    logic rx;
    logic [7:0] data_rx;
    logic WR2c, WR2d, hold_ctrl;
    logic [7:0] datos_aleatorios;
    int pruebas_pasadas = 0;
    int pruebas_fallidas = 0;

    // Número de ciclos de reloj para 9600 baudios (clk/baudios)
    parameter Ciclos_por_Bit = 2813; // 

    uart_rx dut (.clk(clk), .rst(rst), .rx(rx), .data_rx(data_rx), .WR2c(WR2c), .WR2d(WR2d), .hold_ctrl(hold_ctrl));
    
    // Generar reloj de 27MHz de la Tang Nano 9k (37.03 ns de periodo)
    always #18.515 clk = ~clk;
    
    initial begin
        clk = 0;
        rst = 1;
        rx = 1; 
        #100; // reset por los primeros 100 ns

        rst = 0;

        // 50 pruebas aleatorias
        for (int i = 0; i < 50; i++) begin
            datos_aleatorios = $urandom_range(0, 255); // Byte aleatorio

            // Enviar byte por UART
            send_uart_byte(datos_aleatorios);

            // Esperar a que el módulo procese los datos recibidos
            wait(WR2c == 1);  // WR2c indica que el dato está listo

            // Verificar los datos recibidos
            if (data_rx == datos_aleatorios) begin
                $display("Prueba %0d exitosa: Los datos recibidos son correctos (0x%h).", i+1, datos_aleatorios);
                pruebas_pasadas++;
            end 
            else begin
                $display("Prueba %0d fallida: Los datos recibidos son incorrectos. Esperado 0x%h, recibido 0x%h.", i+1, datos_aleatorios, data_rx);
                pruebas_fallidas++;
            end

            // Esperar a que WR2c se desactive antes de la siguiente prueba
            wait(WR2c == 0);
        end

        // Resultados finales
        $display("Pruebas exitosas: %0d", pruebas_pasadas);
        $display("Pruebas fallidas: %0d", pruebas_fallidas);

        $finish;
    end
    
    // Task para enviar un byte de datos por UART
    task send_uart_byte(input [7:0] data);
    begin
        // Inicio transmisión
        rx = 0;
        wait_cycles(Ciclos_por_Bit); 

        // Enviar 8 bits (LSB primero)
        for (int i = 0; i < 8; i++) begin
            send_bit(data[i]);
        end

        // Fin transmisión
        rx = 1;
        wait_cycles(Ciclos_por_Bit);
    end
    endtask

    // Task para transmitir un solo bit
    task send_bit(input logic bit_val);
    begin
        rx = bit_val;
        wait_cycles(Ciclos_por_Bit);
    end
    endtask

    // Task para esperar un número específico de ciclos de reloj
    task wait_cycles(input int num_cycles);
    begin
        repeat (num_cycles) @(posedge clk);
    end
    endtask

endmodule

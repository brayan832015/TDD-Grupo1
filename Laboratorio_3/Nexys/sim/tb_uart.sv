`timescale 1ns/1ps

module tb_uart;
    logic clk;
    logic reset;
    logic wr_i;
    logic [31:0] entrada_i;
    logic [31:0] Address;
    logic rx;
    logic tx;
    logic [31:0] salida_o;
    logic [7:0] datos_aleatorios;
    int pruebas_pasadas = 0;
    int pruebas_fallidas = 0;
    bit frame_correcto;

    // Ciclos por bit a 9600 baudios
    parameter Ciclos_por_Bit = 1042; // Basado en 10 MHz de frecuencia de reloj

    top_uart uut (
        .clk(clk),
        .reset(reset),
        .wr_i(wr_i),
        .entrada_i(entrada_i),
        .Address(Address),
        .salida_o(salida_o),
        .rx(rx),
        .tx(tx)
    );

    // Generación de reloj a 10 MHz (50 ns por ciclo)
    initial begin
        clk = 0;
        forever #50 clk = ~clk;
    end

    initial begin
        reset = 1;
        wr_i = 0;
        entrada_i = 32'b0;
        Address = 32'b0;
        rx = 1;
        #100;

        // Liberar el reset
        reset = 0;

        // Pruebas de transmisión (TX)
        for (int i = 0; i < 25; i++) begin
            datos_aleatorios = $urandom_range(0, 255); // byte aleatorio

            // Enviar byte por UART A
            send_uart_byte(datos_aleatorios, 32'h00002028, 32'h00002020);

            // Verificar el byte transmitido
            verify_uart_byte(datos_aleatorios);

            wait_cycles(10);

            if (frame_correcto) begin
                $display("Prueba TX %0d exitosa: Los datos transmitidos son correctos (%b).", i+1, datos_aleatorios);
                pruebas_pasadas++;
            end
            else begin
                $display("Prueba TX %0d fallida: Los datos transmitidos son incorrectos. Esperado %b.", i+1, datos_aleatorios);
                pruebas_fallidas++;
            end

            #50; // Espera entre pruebas
        end

        // Pruebas de recepción (RX)
        for (int i = 0; i < 25; i++) begin
            datos_aleatorios = $urandom_range(0, 255); // byte aleatorio

            // Enviar byte en la línea RX
            send_uart_byte_to_rx(datos_aleatorios);

            // Verificar el byte recibido
            verify_uart_receive(datos_aleatorios);
            
            wait_cycles(10);

            if (frame_correcto) begin
                $display("Prueba RX %0d exitosa: Los datos recibidos son correctos (%b).", i+1, datos_aleatorios);
                pruebas_pasadas++;
            end
            else begin
                $display("Prueba RX %0d fallida: Los datos recibidos son incorrectos. Esperado %b.", i+1, datos_aleatorios);
                pruebas_fallidas++;
            end

            #50; // Espera entre pruebas
        end

        // Resultados finales
        $display("Pruebas exitosas: %0d", pruebas_pasadas);
        $display("Pruebas fallidas: %0d", pruebas_fallidas);

        $finish;
    end

////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // Task para enviar un byte de datos por UART (TX)
    task send_uart_byte(input [7:0] data, input [31:0] data_reg, input [31:0] ctrl_reg);
    begin
        // Escribir el byte en el registro de datos del UART
        Address = data_reg;
        entrada_i = {24'b0, data};
        wr_i = 1;
        #100;
        wr_i = 0;
        #50;

        // Activar el bit de `send` en el registro de control
        Address = ctrl_reg;
        entrada_i = 32'h00000001; // Bit 0: `send`
        wr_i = 1;
        #150;
        wr_i = 0;
    end
    endtask

////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // Task para verificar la transmisión del UART (TX)
    task verify_uart_byte(input [7:0] expected_data);
        bit [9:0] expected_frame;
        expected_frame = {1'b1, expected_data, 1'b0}; // Bit de parada, datos, bit de inicio
    
        frame_correcto = 1;
    
        // Esperar hasta detectar el bit de inicio (tx = 0)
        @(negedge tx); 
        $display("Inicio de la transmisión detectado.");
    
        // Revisar cada bit
        for (int i = 0; i < 10; i++) begin
            wait_cycles(1);
    
            // Verificar el bit actual
            if (tx !== expected_frame[i]) begin
                $display("Error en el bit %0d: esperado = %b, enviado = %b", i, expected_frame[i], tx);
                frame_correcto = 0; // Error en la transmisión
            end else begin
                $display("Transmisión correcta en el bit %0d: esperado = %b, enviado = %b", i, expected_frame[i], tx);
            end
        end
    endtask

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

    // Task para verificar el byte recibido en el UART (RX)
    task verify_uart_receive(input [7:0] expected_data);
        frame_correcto = 1;

        Address = 32'h00002020; // Dirección del registro de control
        wr_i = 0;
        #50;
        if (salida_o[1] == 1) begin
            // Leer el dato recibido desde el registro de datos
            Address = 32'h0000202C;
            #50;

            wait_cycles(1);

            if (salida_o[7:0] !== expected_data) begin
                $display("Error: El dato recibido es incorrecto. Esperado = %b, recibido = %b", expected_data, salida_o[7:0]);
                frame_correcto = 0;
            end
            
            // Apagar `new_rx`
            Address = 32'h00002020;
            entrada_i = 32'h0;
            wr_i = 1;
            #150;
            wr_i = 0;
        end else begin
            $display("Error: Flag `new_rx` no se activó para el dato esperado %b", expected_data);
            frame_correcto = 0;
        end
    endtask

    // Task para esperar un número específico de ciclos de reloj
    task wait_cycles(input int num_cycles);
    begin
        repeat (num_cycles * Ciclos_por_Bit) @(posedge clk);
    end
    endtask

endmodule
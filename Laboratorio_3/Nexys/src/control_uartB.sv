module control_uartB (
    input  logic clk,
    input  logic reset,
    input  logic [31:0] OUT_control,
    input  logic [31:0] OUT_data,
    input  logic [31:0] Address,
    output logic [31:0] IN2_control,
    output logic [31:0] IN2_data,
    output logic WR2_data,
    output logic WR2_new_rx,
    output logic WR2_send,
    input  logic rx,             
    output logic tx               
);

    logic send, new_rx, busy, send_to_write, new_rx_to_write;
    logic [7:0] data_rx, data_tx;
    logic WR2c, transmit;
    logic [13:0] transmit_counter;  // 14-bit counter for 8336-cycle delay

    // Instancias
    uart_rx uart_rx_inst (.clk(clk), .rst(reset), .rx(rx), .data_rx(data_rx), .WR2c(WR2c), .WR2d(), .hold_ctrl());
    uart_tx uart_tx_inst (.clk(clk), .rst(reset), .data_tx(data_tx), .transmit(transmit), .tx(tx), .busy(busy));

    // Estados
    typedef enum logic [2:0] {esperar, transmitir, espera_transmitir, post_transmitir, recibir} estados;  
    estados estado, sig_estado;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            estado <= esperar;
            WR2_send <= 0;
            WR2_new_rx <= 0;
            WR2_data <= 0;
            IN2_control <= 32'h0;
            IN2_data <= 32'h0;
            send_to_write <= 0;
            new_rx_to_write <= 0; 
            transmit_counter <= 14'b0;  // Reset counter
        end 
        else begin
            estado <= sig_estado;
            IN2_control[0] <= send_to_write;
            IN2_control[1] <= new_rx_to_write;
            WR2_new_rx <= 0;
            WR2_send <= 0;
            WR2_data <= 0;
            
            if (estado == recibir) begin 
                WR2_new_rx <= 1;
                new_rx_to_write <= 1; // activar new_rx, lo limpia el procesador
                IN2_data <= {24'b0, data_rx}; // cargar el registro con lo recibido por UART
                WR2_data <= 1;
                //transmit_counter <= transmit_counter + 1; // Incrementar el contador en `recibir`
            end
            else if (estado == esperar) begin
                new_rx_to_write <= 0;
            end
            else if (estado == transmitir) begin
                transmit_counter <= transmit_counter + 1; // Incrementar el contador en `transmitir`
            end
            else begin
                transmit_counter <= 14'b0;  // Resetear el contador si no estamos en `recibir` o `transmitir`
            end
            
            if (estado == espera_transmitir) begin 
                WR2_send <= 1;
                send_to_write <= 0; // desactivar send, activado por el procesador en el inicio del envío
            end
        end
    end

    always_comb begin
        if (Address == 32'h00002028) begin
            data_tx <= OUT_data[7:0];
        end
        sig_estado = estado;
        transmit = 0; 
        case (estado)
            esperar: begin
                if (WR2c) begin
                    sig_estado = recibir;   
                end 
                else if (send && !busy) begin 
                    sig_estado = transmitir;  
                end 
            end
            
            recibir: begin
                // Permanecer en `recibir` hasta que el contador alcance 260 ciclos
                if (!WR2c) begin
                    sig_estado = esperar;
                end else begin
                    sig_estado = recibir;  // Mantenerse en `recibir` hasta completar 260 ciclos
                end
            end

            transmitir: begin
                
                transmit = 1;
                if (transmit_counter == 1042) begin // Tiempo de transmisión de un byte completo (ajustar si es necesario)
                    sig_estado = espera_transmitir;
                end 
            end

            espera_transmitir: begin
                transmit = 0; 
                if (!busy) begin
                    sig_estado = post_transmitir;
                end
            end

            post_transmitir: begin
                sig_estado = esperar;
            end            

        endcase
    end

    assign send = OUT_control[0];
    assign new_rx = OUT_control[1];

endmodule

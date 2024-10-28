module control_uart (
    input  logic clk,
    input  logic reset,
    input  logic [31:0] OUT_control,
    input  logic [31:0] OUT_data,
    output logic [31:0] IN2_control,
    output logic [31:0] IN2_data,
    output logic WR2_control,
    output logic WR2_data, 
    input  logic rx,             
    output logic tx               
);

    // Señales internas
    logic send, busy;
    logic [7:0] data_rx, data_tx;
    logic WR2c, transmit;

    // Instancias
    uart_rx uart_rx_inst (.clk(clk), .rst(reset), .rx(rx), .data_rx(data_rx), .WR2c(WR2c), .WR2d(), .hold_ctrl());

    uart_tx uart_tx_inst (.clk(clk), .rst(reset), .data_tx(data_tx), .transmit(transmit), .tx(tx), .busy(busy));


    // Estados
    typedef enum logic [1:0] {esperar, transmitir, post_transmitir, recibir} estados;  
    estados estado, sig_estado;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            estado <= esperar;
            WR2_control <= 0;
            WR2_data <= 0;
            IN2_control <= 32'h0;
            IN2_data <= 32'h0; 
        end 
        else begin
            estado <= sig_estado;

            if (estado == recibir) begin 
                WR2_control <= 1;
                IN2_control <= 32'h00000002; // activar new_rx, lo limpia el procesador
                IN2_data <= {24'b0, data_rx}; // cargar el registro con lo recibido por UART
                WR2_data <= 1;
            end

            if (estado == post_transmitir) begin 
                WR2_control <= 1;
                IN2_control <= 32'h0; // desactivar send, activado por el procesador en el inicio del envío
            end
            
        end
    end

    always_comb begin
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
                sig_estado = esperar;
            end

            transmitir: begin
                data_tx = OUT_data[7:0];
                transmit = 1; 
                sig_estado = post_transmitir;
            end

            post_transmitir: begin
                sig_estado = esperar;
            end            

        endcase
    end

assign send = OUT_control [0];

endmodule

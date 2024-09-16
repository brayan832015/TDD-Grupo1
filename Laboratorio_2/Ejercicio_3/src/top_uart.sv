module top_uart (
    input logic clk,
    input logic rst,
    input logic rx,
    output logic tx,
    input logic [3:0] teclado,
    input logic key_detect,
    output logic [7:0] leds
    );

    logic [7:0] data_rx, data_tx;
    logic WR2c, transmit;

    // Instancias
    uart_rx uart_rx_inst (.clk(clk), .rst(rst), .rx(rx), .data_rx(data_rx), .WR2c(WR2c), .WR2d(WR2d), .hold_ctrl(hold_ctrl));

    uart_tx uart_tx_inst (.clk(clk), .rst(rst), .data_tx(data_tx), .transmit(transmit), .tx(tx));

    // Estados
    typedef enum logic [1:0] {esperar, transmitir, recibir} estados;
    estados estado, sig_estado;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            estado <= esperar;
            leds <= 8'hFF;         //leds apagados (encienden con '0')
        end 
        else begin
            estado <= sig_estado;
            if (estado == recibir) begin
                leds <= ~data_rx;
            end
        end
    end

    always_comb begin
        sig_estado = estado;
        transmit = 0;
        case (estado)
            esperar: begin
                if (WR2c) begin                 // caracter válido (laptop)
                    sig_estado = recibir;   
                end
                else if (key_detect) begin      // teclado presionado (4x4)
                    sig_estado = transmitir;
                end 
            end
            
            transmitir: begin
                transmit = 1;
                sig_estado = esperar;
            end
            
            recibir: begin
                sig_estado = esperar;
            end
        endcase
    end

    // Decodificación del teclado 4x4
    always_comb begin
        case (teclado)
            4'b0000: data_tx = 8'h30; // '0'
            4'b0001: data_tx = 8'h31; // '1'
            4'b0010: data_tx = 8'h32; // '2'
            4'b0011: data_tx = 8'h33; // '3'
            4'b0100: data_tx = 8'h34; // '4'
            4'b0101: data_tx = 8'h35; // '5'
            4'b0110: data_tx = 8'h36; // '6'
            4'b0111: data_tx = 8'h37; // '7'
            4'b1000: data_tx = 8'h38; // '8'
            4'b1001: data_tx = 8'h39; // '9'
            4'b1010: data_tx = 8'h41; // 'A'
            4'b1011: data_tx = 8'h42; // 'B'
            4'b1100: data_tx = 8'h43; // 'C'
            4'b1101: data_tx = 8'h44; // 'D'
            4'b1110: data_tx = 8'h2A; // '*'
            4'b1111: data_tx = 8'h23; // '#'
            default: data_tx = 8'h00; // Default case
        endcase
    end


endmodule

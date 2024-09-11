module top_uart (
    input logic clk,
    input logic rst,
    input logic [3:0] keypad_in, // 4-bit encoded input from the keypad
    output logic rst_led,
    output logic transmit_led,
    input logic transmit_key,    // Pulsar para transmitir la tecla
    output logic tx              // UART transmission line
    );
    
    logic [7:0] data_tx;         // ASCII character to send
    logic transmit;
    
    // Instancia del módulo uart_tx
    uart_tx uart_inst (
        .clk(clk),
        .rst(rst),
        .data_tx(data_tx),
        .transmit(transmit),
        .tx(tx)
    );

    // Decodificación del teclado de 4x4 a código ASCII
    always_comb begin
        case (keypad_in)
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

    // Control del envío de datos
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            rst_led <= 0;
            transmit <= 0;
            transmit_led <= 1;
        end 
        else begin
            if (transmit_key) begin
                rst_led <= 1;
                transmit <= 1;
                transmit_led <= 0;
            end 
            else begin
                rst_led <= 1;
                transmit <= 0;
                transmit_led <= 1;
            end
        end
    end

endmodule
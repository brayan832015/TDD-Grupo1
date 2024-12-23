module control_reg (
    input logic clk,
    input logic rst,
    input logic [31:0] IN1,
    input logic [31:0] IN2,
    input logic [31:0] Address,
    input logic WR1,
    input logic WR2_send,
    input logic WR2_new_rx,
    output logic [31:0] OUT_A
);
    logic send_A, new_rx_A;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            send_A <= 0;
            new_rx_A <= 0;
        end 
        else begin
            if (Address == 32'h00002010) begin // UART A
                if (WR1) begin
                    send_A <= IN1[0];
                    new_rx_A <= IN1[1];
                end
                else if (WR2_send) begin
                    send_A <= IN2[0];
                end
                else if (WR2_new_rx) begin
                    new_rx_A <= IN2[1];
                end
            end
        end
    end

    assign OUT_A = {30'b0, new_rx_A, send_A};
endmodule

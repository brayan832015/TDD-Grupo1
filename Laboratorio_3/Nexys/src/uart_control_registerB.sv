module control_regB (
    input logic clk,
    input logic rst,
    input logic [31:0] IN1,
    input logic [31:0] IN2,
    input logic [31:0] Address,
    input logic WR1,
    input logic WR2_send,
    input logic WR2_new_rx,
    output logic [31:0] OUT_B
);
    logic send_B, new_rx_B;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            send_B <= 0;
            new_rx_B <= 0;
        end 
        else begin
            if (Address == 32'h00002020) begin // UART B
                if (WR1) begin
                    send_B <= IN1[0];
                    new_rx_B <= IN1[1];
                end
                else if (WR2_send) begin
                    send_B <= IN2[0];
                end
                else if (WR2_new_rx) begin
                    new_rx_B <= IN2[1];
                end
            end 
        end
    end
    
    assign OUT_B = {30'b0, new_rx_B, send_B};
endmodule

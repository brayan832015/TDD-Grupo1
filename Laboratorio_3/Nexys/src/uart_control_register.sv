module control_reg (
    input logic clk,
    input logic rst,
    input logic [31:0] IN1,
    input logic [31:0] IN2,
    input logic [31:0] Address,
    input logic WR1,
    input logic WR2,
    output logic [31:0] OUT
);
    logic send, new_rx;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            send <= 0;
            new_rx <= 0;
        end 
        else begin
            if (Address == 32'h00002010 || Address == 32'h00002020) begin
                if (WR1) begin
                    send <= IN1[0];
                    new_rx <= IN1[1];
                end
                if (WR2) begin
                    send <= IN2[0];
                    new_rx <= IN2[1];
                end
            end
        end
    end

    assign OUT = {30'b0, new_rx, send};
endmodule

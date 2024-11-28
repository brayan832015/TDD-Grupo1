module data_regsB (
    input logic clk,
    input logic rst,
    input logic [31:0] IN1,
    input logic [31:0] IN2,
    input logic WR1,
    input logic WR2,
    input logic [31:0] Address,
    output logic [31:0] OUT_B
);
    logic [31:0] regB0, regB1;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            regB0 <= 32'b0;
            regB1 <= 32'b0;
        end 
        else begin
            if (Address == 32'h00002028 || Address == 32'h0000202C) begin  // UART B 0x202X
                if (Address[3:0] == 4'h8 && WR1) begin // 0x2028
                    regB0 <= IN1;
                end
                if (Address[3:0] == 4'hC && WR2) begin // 0x202C
                    regB1 <= IN2;
                end
            end
        end
    end

    always_comb begin
        if (Address == 32'h00002028 || Address == 32'h0000202C) begin  // UART B
            if (Address[3:0] == 4'h8) begin
                OUT_B = regB0;
            end 
            else if (Address[3:0] == 4'hC) begin
                OUT_B = regB1;
            end
        end
    end

endmodule

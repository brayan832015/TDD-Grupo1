module data_regs (
    input logic clk,
    input logic rst,
    input logic [31:0] IN1,
    input logic [31:0] IN2,
    input logic WR1,
    input logic WR2,
    input logic [31:0] Address,
    output logic [31:0] OUT_A
);
    logic [31:0] regA0, regA1;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            regA0 <= 32'b0;
            regA1 <= 32'b0;
        end 
        else begin
            if (Address == 32'h00002018 || Address == 32'h0000201C) begin  // UART A 0x201X
                if (Address[3:0] == 4'h8 && WR1) begin // 0x2018
                    regA0 <= IN1;
                end
                if (Address[3:0] == 4'hC && WR2) begin // 0x201C
                    regA1 <= IN2;
                end
            end 
        end
    end

    always_comb begin
        if (Address == 32'h00002018 || Address == 32'h0000201C) begin  // UART A
            if (Address[3:0] == 4'h8) begin
                OUT_A = regA0;
            end 
            else if (Address[3:0] == 4'hC) begin
                OUT_A = regA1;
            end
        end 
    end

endmodule

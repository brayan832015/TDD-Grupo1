module data_regs (
    input logic clk,
    input logic rst,
    input logic [31:0] IN1,
    input logic [31:0] IN2,
    input logic WR1,
    input logic WR2,
    input logic addr1,
    input logic addr2,
    input logic [31:0] Address,
    output logic [31:0] OUT
);
    logic [31:0] reg0, reg1;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            reg0 <= 32'b0;
            reg1 <= 32'b0;
        end 
        else begin
            if (Address == 32'h00002018 || Address == 32'h00002028) begin
                if (WR1) begin
                    reg0 <= IN1;
                end
            end
            if (Address == 32'h0000201C || Address == 32'h0000202C) begin
                if (WR2) begin
                    reg1 <= IN2;
                end
            end
        end
    end

    always_comb begin
        if (Address == 32'h00002018 || Address == 32'h00002028) begin
            OUT = reg0;
        end 
        if (Address == 32'h0000201C || Address == 32'h0000202C) begin
            OUT = reg1;
        end 
        else begin
            OUT = 32'b0;
        end
    end

endmodule

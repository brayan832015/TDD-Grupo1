module switches_buttons (
    input logic clk,             
    input logic rst,               
    input logic [31:0] address,      
    input logic [15:0] switches,      
    input logic [3:0] buttons,         
    output logic [31:0] data_out        
);

    reg [31:0] switch_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            switch_reg <= 32'b0;
        end 
        else if (address == 32'h00002000) begin
            data_out <= switch_reg;
        end 
        else begin
            data_out <= 32'b0;
        end
    end

endmodule

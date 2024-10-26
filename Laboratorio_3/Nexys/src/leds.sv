module leds_register (
    input logic clk,
    input logic rst,
    input logic [31:0] address,
    input logic we,
    input logic [31:0] data_in,
    output logic [15:0] led_output
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            led_output <= 16'b0;
        end
        else if (address == 32'h00002004 && we) begin
            led_output <= data_in[15:0];
        end 
        else begin
            led_output <= 16'b0;
        end
    end

endmodule

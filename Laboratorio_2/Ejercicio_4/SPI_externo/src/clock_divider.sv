module clock_divider(
    input logic clk,    // Clock de entrada de 27 MHz
    input logic rst,
    output logic clk_out   // Clock de salida de 13.5 MHz
);

logic toggle;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        clk_out <= 0;
        toggle  <= 0;
    end else begin
        toggle  <= ~toggle;
        clk_out <= toggle;
    end
end

endmodule

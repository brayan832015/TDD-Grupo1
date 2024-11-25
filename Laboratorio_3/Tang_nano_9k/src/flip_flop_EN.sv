module flip_flop_EN(
    input logic clk,
    input logic rst,
    input logic ck, //(normalmente 0) data_available de Key_bounce_elimination (EN_s)
    input logic data,
    output logic out
);

    always_ff@(posedge clk, posedge rst) begin
        if(rst) begin
            out <= 0;
        end else begin
            if(ck) begin
                out <= data;
            end
        end
    end

endmodule
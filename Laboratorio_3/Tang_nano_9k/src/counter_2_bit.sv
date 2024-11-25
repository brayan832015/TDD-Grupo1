module counter_2bit(
    input logic scan_clk,
    input logic rst,
    input logic inhibit, //inhibit de Key_bounce_elimination (EN_s)
    output logic [1:0] count
);

    always@(posedge scan_clk, posedge rst) begin
        if(rst) begin
            count <= 0;
        end else begin
            if(~inhibit) begin //Cuenta cuando inhibit es 0
                count <= count+1;
            end
        end
    end

endmodule
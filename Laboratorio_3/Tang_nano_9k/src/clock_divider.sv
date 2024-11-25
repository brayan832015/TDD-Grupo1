module clock_divider(
    input logic clk,
    input logic rst,
    output logic scan_clk
);
    
    logic [18:0] clk_div;

    always_ff@(posedge clk, posedge rst) begin
        if (rst) begin
            clk_div <= 0;
            scan_clk <= 0;
        end else begin
            clk_div <= clk_div + 1;
            if (clk_div == 270000) begin //Esto resulta en un reloj de escaneo de 100Hz
                clk_div <= 0;
                scan_clk <= ~scan_clk; 
            end
        end                           
    end

endmodule
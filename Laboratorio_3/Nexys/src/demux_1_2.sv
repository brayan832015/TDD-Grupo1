module demux_1_2(
    input logic wr_i,
    input logic reg_sel_i,
    output logic y0,
    output logic y1
);

logic [1:0] sd;

always_comb begin
    sd = {reg_sel_i, wr_i};
    case(sd)
        2'b00: begin 
            y1 = 0; 
            y0 = 0; 
        end
        2'b01: begin 
            y1 = 0; 
            y0 = 1; 
        end
        2'b10: begin 
            y1 = 0; 
            y0 = 0; 
        end
        2'b11: begin 
            y1 = 1; 
            y0 = 0; 
        end
        default: begin
            y1 = 0; 
            y0 = 0;
        end
    endcase
end

endmodule

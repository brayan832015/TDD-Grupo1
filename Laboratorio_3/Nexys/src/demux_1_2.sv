module demux_1_2(
    input logic wr_i,
    input logic reg_sel_i,
    output logic y0,
    output logic y1
);

logic sd = {reg_sel_i,wr_i};

always_comb begin
    case(sd)
        00: begin 
            y1 = 0; 
            y0 = 0; 
        end
        01: begin 
            y1 = 0; 
            y0 = 1; 
        end
        10: begin 
            y1 = 0; 
            y0 = 0; 
        end
        11: begin 
            y1 = 1; 
            y0 = 0; 
        end
    endcase
end
    
endmodule
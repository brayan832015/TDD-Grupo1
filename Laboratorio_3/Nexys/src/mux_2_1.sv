module mux_2_1#(parameter n = 32)(
    input logic [n-1:0] d0,
    input logic [n-1:0] d1,
    input logic reg_sel_i,
    output logic [n-1:0] y
);

assign y = reg_sel_i ? (d1):(d0);
    
endmodule
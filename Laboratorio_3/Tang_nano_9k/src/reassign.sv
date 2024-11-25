module reassign(
    input logic [3:0] in,   // 4-bit input
    output logic [3:0] out_4bit  // 4-bit output
);

always_comb begin
    case (in)
        4'b1101: out_4bit = 4'b0000;  // 0 
        4'b0000: out_4bit = 4'b0001;  // 1 
        4'b0001: out_4bit = 4'b0010;  // 2 
        4'b0010: out_4bit = 4'b0011;  // 3 
        4'b0100: out_4bit = 4'b0100;  // 4 
        4'b0101: out_4bit = 4'b0101;  // 5 
        4'b0110: out_4bit = 4'b0110;  // 6 
        4'b1000: out_4bit = 4'b0111;  // 7 
        4'b1001: out_4bit = 4'b1000;  // 8 
        4'b1010: out_4bit = 4'b1001;  // 9 
        4'b0011: out_4bit = 4'b1010;  // A 
        4'b0111: out_4bit = 4'b1011;  // B 
        4'b1011: out_4bit = 4'b1100;  // C 
        4'b1111: out_4bit = 4'b1101;  // D 
        4'b1100: out_4bit = 4'b1110;  // * 
        4'b1110: out_4bit = 4'b1111;  // # 
        default: out_4bit = 4'b0000;  
    endcase
end

endmodule
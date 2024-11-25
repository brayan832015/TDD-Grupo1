module merge_bits(
    input logic bitD,  // Most significant bit (MSB)
    input logic bitC,
    input logic bitB,
    input logic bitA,  // Least significant bit (LSB)
    output logic [3:0] merged_output  // 4-bit output
);

    always_comb begin
        merged_output = {bitD, bitC, bitB, bitA};
    end

endmodule
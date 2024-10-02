module merge_bits_tb();

    // Señales de prueba
    logic bitD;  // MSB
    logic bitC;
    logic bitB;
    logic bitA;  // LSB
    logic [3:0] merged_output;

    // Instancia del DUT
    merge_bits dut(
        .bitD(bitD),
        .bitC(bitC),
        .bitB(bitB),
        .bitA(bitA),
        .merged_output(merged_output[3:0])
    );

    function logic random_bit();
        random_bit = $random % 2;
    endfunction

    initial begin
        int i;
        $display($sformatf("        Iteración  |  bitD |  bitC |  bitB |  bitA | merged_output"));
        for (i = 0; i < 10; i = i + 1) begin
            // Generación de valores para las entradas
            bitD = random_bit();
            bitC = random_bit();
            bitB = random_bit();
            bitA = random_bit();
            #10;

            $display($sformatf("%d        |   %b   |   %b   |   %b   |   %b   |    %b", 
                    i, bitD, bitC, bitB, bitA, merged_output));
            #1000;
        end

        #5000 $finish;
    end

endmodule
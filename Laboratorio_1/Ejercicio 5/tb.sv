module tb();
    parameter n = 4;

    logic [n-1:0] ALUA, ALUB;
    logic ALUFlagIn;
    logic [3:0] ALUControl;
    logic [n-1:0] ALUResult;
    logic [1:0] ALUFlags;

    ALU #(.n(n)) dut (.ALUA(ALUA), .ALUB(ALUB), .ALUFlagIn(ALUFlagIn), .ALUControl(ALUControl), .ALUResult(ALUResult), .ALUFlags(ALUFlags));


    initial begin
        logic [n-1:0] expected_ALUResult;
        logic [1:0] expected_ALUFlags;
        logic [n-1:0] fill_pattern;
        logic carry_bit;

        ALUA = 0;
        ALUB = 0;
        ALUFlagIn = 0;
        ALUControl = 0;
        
        repeat(100) begin // 100 pruebas aleatorias
            ALUA = $urandom % (1 << n);
            ALUB = $urandom % (1 << n);
            ALUFlagIn = $urandom_range(1, 0);
            ALUControl = $urandom_range(9, 0);

            
            case (ALUControl)
                4'h0: 
                    expected_ALUResult = ALUA & ALUB;
                
                4'h1: 
                    expected_ALUResult = ALUA | ALUB;
                
                4'h2: 
                    expected_ALUResult = ALUA + ALUB + ALUFlagIn;
                
                4'h3: 
                    expected_ALUResult = ALUFlagIn ? (ALUB + 1) : (ALUA + 1);
                
                4'h4: 
                    expected_ALUResult = ALUFlagIn ? (ALUB - 1) : (ALUA - 1);
                
                4'h5: 
                    expected_ALUResult = ALUFlagIn ? ~ALUB : ~ALUA;
                
                4'h6: 
                    expected_ALUResult = ALUA - ALUB - ALUFlagIn;
                
                4'h7: 
                    expected_ALUResult = ALUA ^ ALUB;
                
                4'h8: begin
                    fill_pattern = ALUFlagIn ? {n{1'b1}} : {n{1'b0}};
                    if (ALUB >= n) begin
                        expected_ALUResult = fill_pattern;
                        if (ALUB == n)
                            carry_bit = ALUA[0]; 
                        else
                            carry_bit = ALUFlagIn;
                    end
                    else begin
                        expected_ALUResult = (ALUA << ALUB) | (fill_pattern >> (n - ALUB));
                        carry_bit = ALUA[n-ALUB];
                    end
                    expected_ALUFlags[0] = carry_bit;
                end
                
                4'h9: begin
                    fill_pattern = ALUFlagIn ? {n{1'b1}} : {n{1'b0}};
                    if (ALUB >= n) begin
                        expected_ALUResult = fill_pattern;
                        if (ALUB == n)
                            carry_bit = ALUA[n-1]; 
                        else
                            carry_bit = ALUFlagIn;
                    end
                    else begin
                        expected_ALUResult = (ALUA >> ALUB) | (fill_pattern << (n - ALUB));
                        carry_bit = ALUA[ALUB-1];
                    end
                    expected_ALUFlags[0] = carry_bit;
                end
                
                default: expected_ALUResult = 0;
            endcase

            expected_ALUFlags[1] = (expected_ALUResult == 0) ? 1 : 0;

            #10; 

            if (ALUResult !== expected_ALUResult || ALUFlags !== expected_ALUFlags) begin
                $display("ERROR: ALUControl=%h, ALUA=%b, ALUB=%b, ALUFlagIn=%b | ALUResult=%b (esperado %b), ALUFlags=%b (esperado %b)",
                         ALUControl, ALUA, ALUB, ALUFlagIn, ALUResult, expected_ALUResult, ALUFlags, expected_ALUFlags);
            end
            else begin
                $display("SUCCESS: ALUControl=%h, ALUA=%b, ALUB=%b, ALUFlagIn=%b | ALUResult=%b (esperado %b), ALUFlags=%b (esperado %b)",
                         ALUControl, ALUA, ALUB, ALUFlagIn, ALUResult, expected_ALUResult, ALUFlags, expected_ALUFlags);
            end
        end
        $finish;
    end
endmodule

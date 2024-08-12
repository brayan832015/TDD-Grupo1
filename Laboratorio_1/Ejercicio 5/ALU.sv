module ALU #(parameter n = 4) (
    input logic [n-1:0] ALUA,
    input logic [n-1:0] ALUB,
    input logic ALUFlagIn,
    input logic [3:0] ALUControl,
    output logic [n-1:0] ALUResult,
    output logic [1:0] ALUFlags //bit 0 para bandera "C" (bit de salida del corrimiento) y bit 1 para bandera "Z" (resultado cero)
);

typedef enum logic[3:0] {op_and, op_or, suma, incremento_1, decremento_1, op_not, resta, op_xor, corrimiento_izq, corrimiento_der} operations;

logic [n-1:0] fill_pattern;
logic carry_bit;

    always_comb begin
        fill_pattern = ALUFlagIn ? {n{1'b1}} : {n{1'b0}};
        
        case (ALUControl)
            op_and: begin
                ALUResult = ALUA & ALUB;
            end
            
            op_or: begin
                ALUResult = ALUA | ALUB;
            end
            
            suma: begin
                ALUResult = ALUA + ALUB + ALUFlagIn;
            end
           
            incremento_1: begin
                ALUResult = ALUFlagIn ? (ALUB + 1) : (ALUA + 1);
            end

            decremento_1: begin
                ALUResult = ALUFlagIn ? (ALUB - 1) : (ALUA - 1);
            end
            
            op_not: begin
                ALUResult = ALUFlagIn ? ~ALUB : ~ALUA;
            end
            
            resta: begin
                ALUResult = ALUA - ALUB - ALUFlagIn;
            end
            
            op_xor: begin
                ALUResult = ALUA ^ ALUB;
            end
            
            corrimiento_izq: begin
                if (ALUB >= n) begin
                    ALUResult = fill_pattern;
                    if (ALUB == n)
                        carry_bit = ALUA[0]; 
                    else
                        carry_bit = ALUFlagIn;
                end
                else begin
                    ALUResult = (ALUA << ALUB) | (fill_pattern >> (n - ALUB));
                    carry_bit = ALUA[n-ALUB];
                end
                ALUFlags[0] = carry_bit;
            end            
            
            corrimiento_der: begin
                if (ALUB >= n) begin
                    ALUResult = fill_pattern;
                    if (ALUB == n)
                        carry_bit = ALUA[n-1]; 
                    else
                        carry_bit = ALUFlagIn;
                end
                else begin
                    ALUResult = (ALUA >> ALUB) | (fill_pattern << (n - ALUB));
                    carry_bit = ALUA[ALUB-1];
                end
                ALUFlags[0] = carry_bit;
            end 
              
            default: begin
                ALUResult = 0;
                ALUFlags = 2'b10;
            end
        endcase
        ALUFlags[1] = (ALUResult == 0) ? 1 : 0; 
    end
endmodule
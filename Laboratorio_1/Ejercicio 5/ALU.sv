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
logic [n+1:0] shift_out;

    always_comb begin
        
        fill_pattern = ALUFlagIn ? {n{1'b1}} : {n{1'b0}};
        
        case (ALUControl)
            op_and: begin
                ALUResult = ALUA & ALUB;
                ALUFlags[1] = (ALUResult == 0) ? 1 : 0;
            end
            
            op_or: begin
                ALUResult = ALUA | ALUB;
                ALUFlags[1] = (ALUResult == 0) ? 1 : 0;
            end
            
            suma: begin
                ALUResult = ALUA + ALUB + ALUFlagIn;
                ALUFlags[1] = (ALUResult == 0) ? 1 : 0;
            end
           
            incremento_1: begin
                ALUResult = ALUFlagIn ? (ALUB + 1) : (ALUA + 1);
                ALUFlags[1] = (ALUResult == 0) ? 1 : 0;
            end

            decremento_1: begin
                ALUResult = ALUFlagIn ? (ALUB - 1) : (ALUA - 1);
                ALUFlags[1] = (ALUResult == 0) ? 1 : 0;
            end
            
            op_not: begin
                ALUResult = ALUFlagIn ? ~ALUB : ~ALUA;
                ALUFlags[1] = (ALUResult == 0) ? 1 : 0;
            end
            
            resta: begin
                ALUResult = ALUA - ALUB - ALUFlagIn;
                ALUFlags[1] = (ALUResult == 0) ? 1 : 0;
            end
            
            op_xor: begin
                ALUResult = ALUA ^ ALUB;
                ALUFlags[1] = (ALUResult == 0) ? 1 : 0;
            end
            
            corrimiento_izq: begin
                shift_out [n:1] = ALUA << ALUB;
                ALUFlags[0] = shift_out[n+1];
                if (ALUB >= n)
                    ALUResult = fill_pattern;
                else
                    ALUResult = (ALUA << ALUB) | (fill_pattern >> (n - ALUB));
                ALUFlags[1] = (ALUResult == 0) ? 1 : 0;
            end            
            
            corrimiento_der: begin
                shift_out [n:1] = ALUA >> ALUB;
                ALUFlags[0] = shift_out[0];
                if (ALUB >= n)
                    ALUResult = fill_pattern;
                else
                    ALUResult = (ALUA >> ALUB) | (fill_pattern << (n - ALUB));
                ALUFlags[1] = (ALUResult == 0) ? 1 : 0;
            end 
                
           
            default: begin
                ALUResult = 0;
                ALUFlags = 2'b10;
            end
        endcase
    end
endmodule
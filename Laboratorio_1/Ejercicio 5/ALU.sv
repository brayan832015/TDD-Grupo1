module ALU #(parameter n = 4) (
    input logic [n-1:0] ALUA,
    input logic [n-1:0] ALUB,
    input logic ALUFlagIn,
    input logic [3:0] ALUControl,
    output logic [n-1:0] ALUResult,
    output logic [1:0] ALUFlags //bit 0 para bandera "C" y bit 1 para bandera "Z" (Cero)
);

typedef enum logic[3:0] {op_and, op_or, suma, incremento_1, decremento_1, op_not, resta, op_xor, corrimiento_izq, corrimiento_der} operations;


logic [n:0] shift_result;

    always_comb begin
        case (ALUControl)
            op_and: 
                ALUResult = ALUA & ALUB;
           
            op_or: 
                ALUResult = ALUA | ALUB;
            
            suma: begin
                ALUResult = ALUA + ALUB + ALUFlagIn;
            end
           
            incremento_1: 
                if (ALUFlagIn)
                    ALUResult = ALUB + 1;
                else
                    ALUResult = ALUA + 1;

            decremento_1: 
                if (ALUFlagIn)
                    ALUResult = ALUB - 1;
                else
                    ALUResult = ALUA - 1;
            
            op_not: begin
                if (ALUFlagIn)
                    ALUResult = ~ALUB;
                else
                    ALUResult = ~ALUA;
            end
            
            resta: begin
                ALUResult = ALUA - ALUB - ALUFlagIn;
            end
            
            op_xor: 
                ALUResult = ALUA ^ ALUB;
                
            corrimiento_izq: begin
                shift_result = ALUA << ALUB;
                ALUResult = shift_result[n-1:0];
                if (shift_result[n])
                    ALUFlags=2'b01;
                else
                    ALUFlags=2'b00;
            end            
            
            corrimiento_der: begin
                shift_result = ALUA >> ALUB;
                ALUResult = shift_result[n-1:0];
                if (shift_result[n])
                    ALUFlags=2'b01;
                else
                    ALUFlags=2'b00;
            end 
                
           
            default: begin
                ALUResult = 0;
                ALUFlags = 0;
            end
        endcase
    end
endmodule

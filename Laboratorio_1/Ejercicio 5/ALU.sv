module ALU #(parameter n = 4) (
    input logic [n-1:0] ALUA,
    input logic [n-1:0] ALUB,
    input logic ALUFlagIn,
    input logic [3:0] ALUControl,
    output logic [n-1:0] ALUResult,
    output logic [1:0] ALUFlags
);

typedef enum logic[3:0] {op_and, op_or, suma, incremento_1, decremento_1, op_not, resta, op_xor, corrimiento_izq, corrimiento_der} operations;
logic [n-1:0] sum_result;
logic [n-1:0] diff_result;

    always @(*) begin
        case (ALUControl)
            op_and: 
                ALUResult = ALUA & ALUB;
           
            op_or: 
                ALUResult = ALUA | ALUB;
            
            suma: begin
                sum_result = ALUA + ALUB + ALUFlagIn;
                ALUResult = sum_result[n-1:0];
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
                diff_result = ALUA - ALUB - ALUFlagIn;
                ALUResult = diff_result[n-1:0];
            end
            
            op_xor: 
                ALUResult = ALUA ^ ALUB;
                
            //corrimiento_izq: 
                

            //corrimiento_der: 
                
           
            default: begin
                ALUResult = 0;
                ALUFlags = 0;
            end
        endcase
    end
endmodule

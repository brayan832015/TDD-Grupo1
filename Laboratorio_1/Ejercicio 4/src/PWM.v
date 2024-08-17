
module PWM(
    input wire clk,
    input wire rst,
    input wire [3:0] c_trabajo, // Entrada de 4 bits
    
    output reg pwm_out // Salida PWM
);

    reg [14:0] contador; // Contador de 15 bits
    reg [14:0] corte;    // Valor de corte basado en ciclos de trabajo

    //1ms es 27000 ciclos; 27MHz = 27000000 ciclos
    parameter PERIODO = 27000;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            contador <= 0; 
        end else begin
            if (contador < PERIODO) begin
                contador <= contador + 1;
            end else begin
                contador <= 0;
            end
            corte <= (PERIODO / 15) * c_trabajo; // Se calcula el valor de corte 
        end
    end
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pwm_out <= 0;
        end else begin
            pwm_out <= (contador < corte) ? 1 : 0; // La salida PWM se actualiza según el contador y corte
        end
    end
    
endmodule
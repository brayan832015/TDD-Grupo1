
module PWM(
    input wire clk //Clock
    input wire rst //Reset Input

    input wire [3:0] c_trabajo, //Input de 4 bits
    
    output reg pwm_out, // PWM Output
    //output reg [5:0] led // 6 LEDS pin
);

    reg [14:0] contador; // Contador de 15 bits
    reg [14:0] corte; // Valor de corte basado en ciclos de trabajo

    //1ms es 27000 ciclos; 27MHz = 27000000 ciclos
    parameter PERIODO = 27000;

    always @(posedge clk) begin
        if (rst) begin
            counter <= 0;
            pwm_out <= 0; 
        end

        else begin 
            contador <= contador + 1;
            if (contador >= PERIODO - 1) begin // Si el contador llega al periodo (27000) se resetea
                contador <= 0;
            end
            corte <= (c_trabajo * (PERIODO / 15)); // Se actualiza el valor de corte segun el ciclo de trabajo
            pwm_out <= (contador < corte) ? 1 : 0; // Se genera la salida PWM
        end
    end
endmodule
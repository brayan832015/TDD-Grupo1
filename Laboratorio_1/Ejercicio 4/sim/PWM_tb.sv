
module PWM_tb();

    logic clk;
    logic rst;
    logic [3:0] c_trabajo;
    logic pwm_out;

    PWM dut (
        .clk(clk),
        .rst(rst),
        .c_trabajo(c_trabajo),
        .pwm_out(pwm_out)
    );

    // Generación de reloj (clock) con un periodo de 10 unidades de tiempo
    always #5 clk = ~clk;

    // Generación de estímulos
    initial begin
        clk = 0;
        rst = 1;
        c_trabajo = 4'b0000; 

        // Reset del sistema
        #10 rst = 0;

        // Probar diferentes ciclos de trabajo
        #20 c_trabajo = 4'b0001; // Ciclo de trabajo bajo
        #50 c_trabajo = 4'b0111; // Ciclo de trabajo medio
        #50 c_trabajo = 4'b1111; // Ciclo de trabajo máximo
        #100 $finish;
    end

endmodule
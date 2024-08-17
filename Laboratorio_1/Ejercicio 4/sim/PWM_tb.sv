
module PWM_tb();

    logic clk;
    logic rst;
    logic [3:0] c_trabajo;
    logic pwm_out;

    // Contador para 135000 ciclos (5ms a 27MHz)
    reg [17:0] ciclos;

    PWM dut (
        .clk(clk),
        .rst(rst),
        .c_trabajo(c_trabajo),
        .pwm_out(pwm_out)
    );

    always #1 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        c_trabajo = 4'b0000;
        ciclos = 0;
        #100 rst = 0;
        
        // Bucle para aumentar el ciclo de trabajo cada 135000 ciclos (5ms)
        forever begin
            ciclos = 0;
            while (ciclos < 135000) begin
                @(posedge clk);
                ciclos = ciclos + 1;
            end
            
            // Se incrementa el ciclo de trabajo 1 bit
            if (c_trabajo < 4'b1111) begin
                c_trabajo = c_trabajo + 1;
            end else begin
                $finish;
            end
        end
    end

endmodule

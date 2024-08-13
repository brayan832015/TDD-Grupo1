
module MUX41_tb();

    parameter WIDTH = 50; // Se define el número de bits (Probar 4, 8, 16 y 50 bits)
    parameter TESTS = 10; // Número de pruebas
    
    logic [WIDTH-1:0] d0, d1, d2, d3;
    logic [1:0] s;
    logic [WIDTH-1:0] y;
    
    MUX41 #(.WIDTH(WIDTH)) dut (
        .d0(d0),
        .d1(d1),
        .d2(d2),
        .d3(d3),
        .s(s),
        .y(y)
    );
    
    // Se aplican las pruebas individuales
    task automatic test(input [WIDTH-1:0] v_d0, v_d1, v_d2, v_d3, input [1:0] v_s);
        begin
        d0 = v_d0;
        d1 = v_d1;
        d2 = v_d2;
        d3 = v_d3;
        s = v_s;
        #10;
        end
    endtask
    
    initial begin
        // Se generan las n pruebas randomizadas
        for (int n = 0; n < TESTS; n++) begin 
            test($random, $random, $random, $random, $random % 4); // Randomización de entradas y selectores
        end 
        $finish;     
    end

endmodule
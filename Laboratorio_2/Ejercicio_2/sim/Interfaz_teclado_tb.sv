module Interfaz_teclado_tb();
    // Señales de prueba
    //Inputs
    logic clk;
    logic rst;
    logic key;
    logic c;
    logic d;

    //Outputs
    logic [1:0] count;
    logic EN_s;
    logic out_A;
    logic out_B;
    logic out_C;
    logic out_D;

    // Instancia del DUT (Device Under Test)
    top_module dut(
        //Inputs
        .clk(clk),
        .rst(rst),
        .key(key), //<- key_detect
        .c(c), // Input c del codificador
        .d(d), // Input d del codificador

        //Outputs
        .count(count), // Entrada al Decodificador físico
        .EN_s(EN_s), //-> counter_2bit & flip_flop_EN & Output Data_available
        .out_A(out_A), 
        .out_B(out_B),
        .out_C(out_C),
        .out_D(out_D) 
    );

    always #18 clk = ~clk;

    // Se simula el rebote del key_detect y de las salidas del codificador 'c' y 'd'
    task automatic generate_key_bounce(); 
        bit c_random, d_random;
        int steady_time; // Tiempo estable randomizado (entre 15ms y 70ms)
        begin
            // Valores randomizados de 'c' y 'd' con cada iteración del task
            c_random = $urandom_range(0, 1);
            d_random = $urandom_range(0, 1);

            key = 0;
            c = 0;
            d = 0;

            // Estado estable con key low
            steady_time = $urandom_range(15000000, 70000000);
            #steady_time;

            // Rebotes de key low a high
            repeat(7) begin
                #1000000;
                key = ~key;
                if (key == 1) begin
                    c = c_random;
                    d = d_random;
                end else begin
                    c = 1'b0;
                    d = 1'b0;
                end
            end

            // Estado estable con key high
            key = 1;
            c = c_random;
            d = d_random;
            steady_time = $urandom_range(15000000, 70000000);
            #steady_time;

            // Rebotes de key high a low
            repeat(7) begin
                #1000000;
                key = ~key;
                if (key == 1) begin
                    c = c_random;
                    d = d_random;
                end else begin
                    c = 0;
                    d = 0;
                end
            end

            key = 0;
            c = 0;
            d = 0;
        end
    endtask
        
    task automatic monitor_EN_s();
        begin
            forever begin
            // Wait for EN_s to go high
            @(posedge EN_s);
                if (EN_s) begin
                    // Print values of key, c, and d when EN_s is high
                    $display($sformatf("Entrada estable EN_s: %b", EN_s));
                    $display($sformatf("Output LEDs -> D: %0d, C: %0d, B: %0d, A: %0d", out_D, out_C, out_B, out_A));
                    $display($sformatf("[1:0]count %b", count));
                end
            end
        end
    endtask

    initial begin
        clk = 0;
        rst = 1;
        key = 0;
        c = 0;
        d = 0;

        #100 rst = 0;

        // Se deja al contador de 2bits contar al inicio de la simulación
        #50000000

        fork
            monitor_EN_s();
        join_none
        
        // Se simulan los rebotes y estado estable del key_detect
        repeat(10) begin
            generate_key_bounce();
        end
        
        // Se deja al contador de 2bits contar al final de la simulación
        #50000000 $finish; 
    end

endmodule
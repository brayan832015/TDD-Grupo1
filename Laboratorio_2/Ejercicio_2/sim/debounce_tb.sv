module debounce_tb();
    // Señales de prueba
    logic clk;
    logic rst;
    logic key;
    logic EN_s;

    // Instancia del DUT (Device Under Test)
    debounce dut(
        .clk(clk),
        .rst(rst),
        .EN_b(key), //<- debounce
        .EN_s(EN_s) //-> counter_2bit
    );

    always #18 clk = ~clk;

    // Se simula el rebote del key_detect
    task automatic generate_key_bounce(); 
        int steady_time; // Tiempo estable randomizado (entre 15ms y 70ms)
        logic bounce;
        begin
            key = 0;

            // Estado estable con key low
            steady_time = $urandom_range(15000000, 70000000);
            #steady_time;

            // Rebotes de duración randomizada de key low a high
            repeat(7) begin
                bounce = $urandom_range(1000000, 1999999);
                #bounce;
                key = ~key;
            end

            // Estado estable con key high
            key = 1;
            steady_time = $urandom_range(15000000, 70000000);
            #steady_time;

            // Rebotes de duración randomizada de key high a low
            repeat(7) begin
                bounce = $urandom_range(1000000, 1999999);
                #bounce;
                key = ~key;
            end

            key = 0;
        end
    endtask

    task automatic monitor_EN_s();
        begin
            forever begin
            // Esperar a que EN sea 1
            @(posedge EN_s, negedge EN_s);
                if (key !== EN_s) begin
                    $display($sformatf("Error EN_s != key"));
                end else begin
                    $display($sformatf("SUCCESS EN_s: %b = key: %b", EN_s, key));
                end
            end
        end
    endtask
    
    initial begin
        clk = 0;
        rst = 1;
        key = 0;
        
        #100 rst = 0;

        fork
            monitor_EN_s();
        join_none
        
        // Se simulan los rebotes y estado estable del key_detect
        repeat(10) begin
            generate_key_bounce();
        end

        #50000000 $finish; 
    end

endmodule
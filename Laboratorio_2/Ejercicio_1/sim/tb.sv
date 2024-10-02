module debounce_tb();
    // Test signals
    logic clk;
    logic rst;
    logic key;
    logic [5:0] conta; // Contador

    logic [5:0] conta_prev; // Variable para almacenar el valor previo del contador

    // DUT instance
    top_module dut (
        .clk(clk),
        .rst(rst),
        .EN_b(key),  // Entrada con rebotes
        .conta(conta) // Contador de salida
    );

    always #18 clk = ~clk;

    // Se simula el rebote del key_detect
    task automatic generate_key_bounce(); 
        int steady_time; // Tiempo estable randomizado (entre 15ms y 70ms)
        begin
            key = 0;

            // Estado estable con key low
            steady_time = $urandom_range(15000000, 70000000);
            #steady_time;

            // Rebotes de duración randomizada de key low a high
            repeat(7) begin
                #1000000;
                key = ~key;
            end

            // Estado estable con key high
            key = 1;
            steady_time = $urandom_range(15000000, 70000000);
            #steady_time;

            // Rebotes de duración randomizada de key high a low
            repeat(7) begin
                #1000000;
                key = ~key;
            end
            key = 0;
        end
    endtask

    // Monitoreo del contador
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            conta_prev <= 6'b000000;
        end else begin
            if (conta != conta_prev) begin
                $display("Contador: %0d, key: %b", ~conta, key); // Se niega por la lógica del módulo original
                conta_prev <= conta;
            end
        end
    end

    initial begin
        clk = 0;
        rst = 1;
        key = 0;
        conta_prev = 6'b000000;
        
        #100 rst = 0;
        
        repeat(10) begin
            generate_key_bounce();
        end

        #500000 $finish; 
    end

endmodule
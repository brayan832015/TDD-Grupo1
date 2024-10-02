module flip_flop_EN_tb();
    logic rst;
    logic EN_s;
    logic data;
    
    logic out;

    int rand_k_press;

    flip_flop_EN dut(
        .ck(EN_s), //<- debounce
        .rst(rst), 
        .data(data), //data1 = A = lsb
        .out(out)
    );

    always begin 
        rand_k_press = $urandom_range(10000000, 25000000); // Randomización entre 10ms a 25ms
        #rand_k_press EN_s = ~EN_s;
    end

    task automatic monitor_output();
        #1;
        if (EN_s) begin // Cuando se activa el enable EN_s se detecta si la salida es igual a la entrada
            if (out == data) begin
                $display($sformatf("SUCCESS: EN_s = %b, out = %b, data = %b", EN_s, out, data));
            end else begin
                $display($sformatf("ERROR: EN_s = %b, out = %b, data = %b", EN_s, out, data));
            end
        end
    endtask

    always @(posedge EN_s) begin
        monitor_output();  // Se llama a la función de monitoreo en el flanco positivo EN_s
    end

    initial begin
        EN_s = 0;
        rst = 1;
        data = 0;
        #100 rst = 0;

        forever begin
            #($urandom_range(3000000, 5000000));  // Randomización entre 3ms a 5ms
            data = $urandom_range(0, 1);
        end
    end
        
    initial begin
        #250000000 $finish;
    end

endmodule
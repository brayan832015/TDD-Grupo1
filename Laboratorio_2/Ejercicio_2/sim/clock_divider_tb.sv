module clock_divider_tb();
    logic clk;
    logic rst;
    logic scan_clk;

    // Instantiate the clock divider module
    clock_divider dut (
        .clk(clk),
        .rst(rst),
        .scan_clk(scan_clk)
    );

    // Clock generation
    always #18 clk = ~clk;

    int tb_counter;
    int period;

    task automatic automatic_task();
        tb_counter = 0;
        forever begin
            @(posedge clk);
            if (rst) begin
                tb_counter = 0;
            end else begin
                tb_counter++;
            end

            period = tb_counter/13500;

            if (tb_counter >= 270000) begin // Periodo del scan_clk 20ms
                $display("periodo = %0dms, scan_clk = %b", period, scan_clk);
                tb_counter = 0;
            end
        end
    endtask

    initial begin
        clk = 0;
        rst = 1;
        #100 rst = 0;

        fork
            automatic_task();
        join_none

        #270000000; // Run simulation for some time
        $finish;
    end

endmodule

module counter_2bit_tb();
    logic scan_clk;
    logic rst;
    logic inhibit;
    logic [1:0] count;

    counter_2bit dut(
        .scan_clk(scan_clk),
        .rst(rst),
        .inhibit(inhibit),  
        .count(count)
    );

    always #180 scan_clk = ~scan_clk; 

    initial begin
        scan_clk = 0;
        rst = 1;
        inhibit = 0;

        #100 rst = 0;

        forever begin
            @(posedge scan_clk); #2;
            inhibit = $urandom_range(0, 1);
            $display($sformatf("inhibit = %b, count = %b", inhibit, count));
        end
    end

    initial begin
        #7000 $finish;
    end

endmodule
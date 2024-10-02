`timescale 1ps/1ps

module tb();

reg clk;
reg rst;

initial
begin
	clk = 0;
	forever #1 clk = ~clk;
end

initial begin
	rst = 0;
	#10
	rst = 1;
	#10
	rst = 0;
	#500000000
	rst = 1;
	#10
	rst = 0;
	#500000000 $stop;
end

top dut(
	.clk(clk),
	.rst(rst),

	.rx(),
                  
    .lcd_resetn(),
    .spi_sclk(),
    .spi_cs_l(),
    .lcd_rs(),
    .spi_data()
);

endmodule

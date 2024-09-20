module tb_top_module;

  logic clk;
  logic rst_n;
  logic EN_b;
  logic [7:0] conta;

  // Instantiate the top module
  top_module dut (
    .clk(clk),
    .rst_n(rst_n),
    .EN_b(EN_b),
    .conta(conta)
  );

  // Clock generation (50 MHz for example)
  always #10 clk = ~clk; // 20ns period -> 50 MHz

  // Initialize signals
  initial begin
    clk = 0;
    rst_n = 0;
    EN_b = 0;
    #100;                // Wait 100ns to reset the circuit
    rst_n = 1;
    
    // Simulate button press with bounce
    bounce_button();
    
    #1000 $finish;       // End simulation after 1000ns
  end

  // Task to simulate button bouncing and pressing for 2ms
  task bounce_button();
    integer i;
    // Simulate bounces: quickly toggle EN_b between 0 and 1
    for (i = 0; i < 10; i = i + 1) begin
      EN_b = ~EN_b;
      #50;               // 50ns bounce period
    end
    // Stable press for 2ms
    EN_b = 1;
    #2000000;            // 2ms stable press
    EN_b = 0;
  end

  // Monitor the count
  initial begin
    $monitor("Time = %0t, conta = %0d", $time, conta);
  end

endmodule
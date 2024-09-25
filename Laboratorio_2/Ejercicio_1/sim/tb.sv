module top_debounce_tb();

  logic clk;
  logic rst;
  logic EN_b;
  logic [7:0] conta;

  // Instantiate the top module
  top_module dut (
    .clk(clk),
    .rst(rst),
    .EN_b(EN_b),
    .conta(conta)
  );

  always #18 clk = ~clk;

  initial begin
    clk = 0;
    rst = 1;
    EN_b = 0;

    #100 rst = 0;  
    
    #5000000 EN_b = 1; //5 ms

    #5000000 EN_b = 0;
    //10ms inactivo en 0
    #10000000 EN_b = 1;
    //1ms activo
    #1000000 EN_b = 0;
    //10ms inactivo en 0
    #10000000 EN_b = 1;
    //Rebotes al presionar
    #1000000 EN_b = 0;

    #1000000 EN_b = 1;

    #1000000 EN_b = 0;

    #1000000 EN_b = 1;

    #1000000 EN_b = 0;

    #1000000 EN_b = 1;
    //5ms activo en 1
    #5000000 EN_b = 0;
    //Rebotes al dejar de presionar
    #1000000 EN_b = 1;

    #1000000 EN_b = 0;

    #1000000 EN_b = 1;

    #1000000 EN_b = 0;

    #1000000 EN_b = 1;

    #1000000 EN_b = 0;
    //10ms inactivo
    #10000000 EN_b = 1;
    //1ms activo
    #1000000 EN_b = 0;        

    //50ms inactivo
    #25000000 $finish;

  end
  
endmodule
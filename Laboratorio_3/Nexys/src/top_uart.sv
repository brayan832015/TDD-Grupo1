module top_uart (
    input  logic clk,
    input  logic reset,
    input  logic wr_i,            
    input  logic [31:0] entrada_i,
    input  logic reg_sel_i,       // Selección del registro (control o datos)
    input  logic addr_i,          // Selección del registro de datos (0 o 1)
    input  logic [31:0] Address,
    output logic [31:0] salida_o, // Salida al bus de datos
    input  logic rx,
    output logic tx 
);

    logic [31:0] control_out, data_out;
    logic wr_control, wr_data;
    logic [31:0] IN2_control, IN2_data;
    logic WR2_control, WR2_data;

    // MUX para seleccionar entre control y datos
    mux_2_1 #(32) mux(
        .d0(control_out), 
        .d1(data_out), 
        .reg_sel_i(reg_sel_i), 
        .y(salida_o)
    );

    // Demux para escritura entre control y datos
    demux_1_2 demux(
        .wr_i(wr_i), 
        .reg_sel_i(reg_sel_i), 
        .y0(wr_control), 
        .y1(wr_data)
    );

    // Registro de control
    control_reg control_reg (
        .clk(clk),
        .rst(reset),
        .IN1(entrada_i),
        .IN2(IN2_control),
        .Address(Address),
        .WR1(wr_control),
        .WR2(WR2_control),
        .OUT(control_out)
    );

    // Registros de datos
    data_regs data_regs (
        .clk(clk),
        .rst(reset),
        .IN1(entrada_i),
        .IN2(IN2_data),
        .WR1(wr_data),
        .WR2(WR2_data),
        .addr1(),
        .addr2(),
        .Address(Address),
        .OUT(data_out)
    );

    control_uart control_uart (
        .clk(clk),
        .reset(reset),
        .OUT_control(control_out),
        .OUT_data(data_out),
        .IN2_control(IN2_control),
        .IN2_data(IN2_data),
        .WR2_control(WR2_control),
        .WR2_data(WR2_data), 
        .rx(rx),             
        .tx(tx)               
    );

endmodule

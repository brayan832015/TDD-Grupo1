module top_uart (
    input  logic clk,
    input  logic reset,
    input  logic wr_i,            
    input  logic [31:0] entrada_i,
    input  logic [31:0] Address,
    output logic [31:0] salida_o, // Salida al bus de datos
    input  logic rx,
    output logic tx 
);

    logic [31:0] control_out, data_out;
    logic wr_control, wr_data, reg_sel_i;
    logic [31:0] IN2_control, IN2_data;
    logic WR2_control, WR2_data;
    logic [31:0] OUT_A_ctrl, OUT_B_ctrl;
    logic [31:0] OUT_A_data, OUT_B_data;

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
        .OUT_A(OUT_A_ctrl),
        .OUT_B(OUT_B_ctrl)
    );

    // Registros de datos
    data_regs data_regs (
        .clk(clk),
        .rst(reset),
        .IN1(entrada_i),
        .IN2(IN2_data),
        .WR1(wr_data),
        .WR2(WR2_data),
        .Address(Address),
        .OUT_A(OUT_A_data),
        .OUT_B(OUT_B_data)
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

    always_comb begin
        control_out = 32'b0;
        data_out = 32'b0;
        reg_sel_i = 0;
        

        // data_out
        if (Address == 32'h00002018 || Address == 32'h0000201C) begin  // UART A
            data_out = OUT_A_data;
        end
        else if (Address == 32'h00002028 || Address == 32'h0000202C) begin  // UART B
            data_out = OUT_B_data;
        end


        // control_out
        if (Address == 32'h00002010) begin  // UART A
            control_out = OUT_A_ctrl;
        end
        else if (Address == 32'h00002020) begin  // UART B
            control_out = OUT_B_ctrl;
        end


        // reg_sel_i
        if (Address == 32'h00002018 || Address == 32'h0000201C || Address == 32'h00002028 || Address == 32'h0000202C) begin
            reg_sel_i = 1;
        end
        else if (Address == 32'h00002010 || Address == 32'h00002020) begin
            reg_sel_i = 0;
        end
    end
endmodule

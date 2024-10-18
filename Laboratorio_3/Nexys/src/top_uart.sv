module top_uart (
    input  logic clk,
    input  logic reset,
    input  logic wr_i,            // Señal de escritura
    input  logic [31:0] entrada_i,// Dato de entrada desde el bus de datos
    input  logic reg_sel_i,       // Selección del registro (control o datos)
    input  logic addr_i,          // Selección dentro del registro de datos (0 o 1)
    output logic [31:0] salida_o, // Salida de los registros (lectura)
    input  logic rx,              // Señal RX (entrada serial)
    output logic tx               // Señal TX (salida serial)
);

    // Señales internas
    logic [31:0] control_out, data_out;
    logic wr_control, wr_data;
    logic [7:0] data_rx, data_tx;
    logic send, new_rx, wr_clear, busy, busy, hold_ctrl;

    // Instancia del MUX para seleccionar entre control y datos
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

    // Instanciar módulo de registro de control
    uart_control_register control_inst (
        .clk(clk),
        .reset(reset),
        .wr_i(wr_control),
        .entrada_i(entrada_i),
        .salida_o(control_out),
        .send(send),
        .busy(busy),
        .new_rx(new_rx),
        .wr_clear(wr_clear)
    );

    // Instanciar módulo de registro de datos
    uart_data_registers data_inst (
        .clk(clk),
        .reset(reset),
        .wr_i(wr_data),
        .entrada_i(entrada_i),
        .addr_i(addr_i),
        .data_rx(data_rx),
        .salida_o(data_out),
        .data_tx(data_tx),
        .wr_data(wr_clear),
        .hold_ctrl(hold_ctrl)
    );

    // Instanciar el módulo de recepción UART
    uart_rx uart_rx_inst (
        .clk(clk),
        .rst(reset),
        .rx(rx),
        .data_rx(data_rx),
        .WR2c(new_rx),
        .WR2d(wr_clear),
        .hold_ctrl(hold_ctrl)
    );

    // Instanciar el módulo de transmisión UART
    uart_tx uart_tx_inst (
        .clk(clk),
        .rst(reset),
        .data_tx(data_tx),
        .transmit(send),
        .tx(tx),
        .busy(busy)
    );

endmodule

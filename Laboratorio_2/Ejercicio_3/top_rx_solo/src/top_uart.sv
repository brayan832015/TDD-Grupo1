module top_uart (
    input logic clk,          
    input logic rst,  
    input logic rx, // Entrada RX UART desde el USB
    output logic rst_led, // LED enciende con reset activo
    output logic WR2c_led, // LED enciende con caracter válido
    output logic [7:0] leds // Salida LEDs en ASCII (activos en bajo)
);


    logic [7:0] data_rx; // Dato recibido de uart_rx
    logic WR2c, WR2d, hold_ctrl;


    uart_rx uart_rx_inst (.clk(clk), .rst(rst), .rx(rx), .data_rx(data_rx), .WR2c(WR2c), .WR2d(WR2d), .hold_ctrl(hold_ctrl));
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            WR2c_led <= 1;
            rst_led <= 0;
            leds <= 8'b11111111;  // Apagar LEDs en reset 
        end 
        else if (WR2c) begin
            WR2c_led <= 0;
            rst_led <= 1;
            leds <= ~data_rx;  // Actualizar LEDs con el dato recibido cuando hay dato válido
        end
    end

endmodule

module uart_control_register (
    input  logic clk,
    input  logic reset,
    input  logic wr_i,            // Señal de escritura
    input  logic [31:0] entrada_i,// Dato de entrada desde el bus de datos
    output logic [31:0] salida_o, // Salida del registro de control
    output logic send,            // Señal para indicar que se debe enviar un dato
    input  logic busy,            // Indica que la transmisión está en proceso
    input  logic new_rx,          // Indica que hay un nuevo dato recibido
    input  logic wr_clear         // Señal para limpiar el bit de new_rx cuando el dato ha sido leído
);

    logic [31:0] control_reg;  // Registro de control (bit 0: send, bit 1: new_rx)

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            control_reg <= 32'b0;
        end else if (wr_i) begin
            control_reg[0] <= entrada_i[0];  // Escribir el bit de "send" desde el bus de datos
        end

        // Limpiar el bit "send" cuando la transmisión ha finalizado
        if (!busy) begin
            control_reg[0] <= 1'b0;
        end

        // Indicar que hay un nuevo dato recibido
        if (new_rx) begin
            control_reg[1] <= 1'b1;
        end

        // Limpiar el bit "new_rx" cuando se lee el dato
        if (wr_clear) begin
            control_reg[1] <= 1'b0;
        end
    end

    // Salida del registro de control
    assign salida_o = control_reg;
    assign send     = control_reg[0];  // Bit de envío

endmodule

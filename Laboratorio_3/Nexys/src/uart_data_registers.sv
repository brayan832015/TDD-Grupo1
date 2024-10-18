module uart_data_registers (
    input  logic clk,
    input  logic reset,
    input  logic wr_i,             // Señal de escritura
    input  logic [31:0] entrada_i, // Dato de entrada desde el bus de datos
    input  logic addr_i,           // Selección del registro (0: TX, 1: RX)
    input  logic [7:0] data_rx,    // Dato recibido desde el UART
    output logic [31:0] salida_o,  // Salida de los registros (lectura de datos)
    output logic [7:0] data_tx,    // Dato a enviar por UART
    output logic wr_data,          // Señal para escribir en el UART
    input  logic hold_ctrl         // Indica si los datos RX están retenidos
);

    logic [31:0] reg_tx;  // Registro de transmisión
    logic [31:0] reg_rx;  // Registro de recepción

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_tx <= 32'b0;
            reg_rx <= 32'b0;
        end else if (wr_i && addr_i == 1'b0) begin
            reg_tx <= entrada_i;  // Escritura en registro TX (cuando addr_i == 0)
        end

        // Guardar el dato recibido solo si hold_ctrl no está activo
        if (!hold_ctrl && wr_i && addr_i == 1'b1) begin
            reg_rx <= {24'b0, data_rx};  // Escribir dato recibido en el registro RX (cuando addr_i == 1)
        end
    end

    // Salida del registro, según la dirección seleccionada
    assign salida_o = (addr_i == 1'b0) ? reg_tx : reg_rx;
    assign data_tx = reg_tx[7:0];  // Solo los primeros 8 bits se utilizan para la transmisión
    assign wr_data = wr_i && (addr_i == 1'b0);  // Activar la escritura cuando se seleccione TX

endmodule

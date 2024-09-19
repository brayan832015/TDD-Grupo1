module color_control (
    input wire clk,
    input wire reset,
    input wire [7:0] color_data,
    output reg [23:0] color_config
);
    // Lógica para controlar las configuraciones de color

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            color_config <= 24'hFFFFFF; // Color blanco por defecto
        end else begin
            // Actualizar el color basado en el color_data recibido
            color_config <= {color_data, color_data, color_data}; // Ejemplo simple
        end
    end
endmodule

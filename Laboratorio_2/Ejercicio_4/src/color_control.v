module color_control (
    input wire clk,
    input wire reset,
    input wire [7:0] color_data,
    input wire toggle_color,
    output reg [23:0] color_config
);
    // Lógica para controlar las configuraciones de color
    reg select_color;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            color_config <= 24'hFFFFFF; // Color blanco por defecto
            select_color <= 0; // Iniciar con la configuración 1
        end else if (toggle_color) begin
            select_color <= ~select_color; // Alternar configuración
        end

        if (select_color) begin
            // Configuración 1: Rojo y Azul
            color_config <= {8'hFF, 8'h00, 8'h00}; // Rojo
        end else begin
            // Configuración 2: Verde y Azul
            color_config <= {8'h00, 8'hFF, 8'h00}; // Verde
        end
    end
endmodule

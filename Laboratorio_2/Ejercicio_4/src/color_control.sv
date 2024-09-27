module color_control (
    input logic clk,
    input logic resetn,          // Reset activo bajo
    input logic toggle_color,    // Señal para alternar el patrón de color
    output logic [23:0] color_p1, // Color 1
    output logic [23:0] color_p2  // Color 2
);

    logic select_color;

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            select_color <= 0; // Comenzar con la configuración 1 (Rojo y Azul)
        end else if (toggle_color) begin
            select_color <= ~select_color; // Alternar entre las configuraciones
        end
    end

    always_comb begin
        if (select_color) begin
            // Configuración 1: P1 = Rojo, P2 = Azul
            color_p1 = 24'hFF0000; // Rojo
            color_p2 = 24'h0000FF; // Azul
        end else begin
            // Configuración 2: P1 = Verde, P2 = Azul
            color_p1 = 24'h00FF00; // Verde
            color_p2 = 24'h0000FF; // Azul
        end
    end

endmodule

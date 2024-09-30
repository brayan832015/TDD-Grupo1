module color_control (
    input logic clk,
    input logic resetn,
    input logic [7:0] config_select, // Selector de configuración: 2'b00 (Rojo/Azul), 2'b01 (Verde/Azul)
    input logic [7:0] col,           // Columna actual
    input logic init_state,
    output logic [15:0] pixel        // Color del píxel a dibujar
);

    // Toggle para cambiar de color
    logic toggle_color;

    // Estados de inicialización
    localparam INIT_DONE = 1'b1; //................revisar........con SPI...................

    // Colores RGB 5-6-5
    localparam logic [15:0] RED   = 16'hF800; // Rojo
    localparam logic [15:0] GREEN = 16'h07E0; // Verde
    localparam logic [15:0] BLUE  = 16'h001F; // Azul

    // Control de cambio de color basado en la columna
    always_ff @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            toggle_color <= 0;
        end else if (init_state == INIT_DONE) begin
            // Cambia de color en las columnas definidas
            if (col == 29 || col == 59 || col == 89 || col == 119 || col == 149 || col == 179 || col == 209 || col == 239) begin
                toggle_color <= ~toggle_color;
            end
        end 
    end

    // Lógica combinacional para la selección de color
    always_comb begin
        case (config_select)
            8'b00000001: begin // Configuración rojo y azul
                pixel = toggle_color ? RED : BLUE;
            end
            8'b00000010: begin // Configuración verde y azul
                pixel = toggle_color ? GREEN : BLUE;
            end
            default: begin // Valor por defecto si config_select no es válido
                pixel = BLUE;
            end
        endcase
    end

endmodule

module top_final(
    input logic clk,     // Reloj principal
    input logic rst,     // Reset
    input logic key,     // Entrada del botón con rebotes (EN_b)
    input logic c,       // Output C del codificador (del teclado)
    input logic d,       // Output D del codificador (MSB del teclado)
    input logic rx,      // Entrada UART RX
    output logic tx,     // Salida UART TX
    output logic key_detect,
    output logic [1:0] count,
    output logic [7:0] leds // Salidas de los LEDs
);

    // Señales internas
    logic EN_s;              // Salida estabilizada del debounce
    logic out_A, out_B, out_C, out_D; // Salidas de los flip-flops (A = LSB, D = MSB)
    logic [3:0] teclado;     // Entrada de teclado de 4 bits para UART
    logic key_detect_reg; 
    logic [23:0] temporizador_activo;   // Temporizador key_detect activo
    logic [23:0] temporizador_deshabilitado; // Temporizador reactivar key_detect
    logic en_espera;       // Indica si hay espera en la transmisión

    // Parámetros para la duración de los pulsos
    parameter tiempo_activo = 27000;     // Duración key_detect activo
    parameter tiempo_desabilitado = 27000000;  // Duración reactivar key_detect si se solicita de nuevo

    assign teclado = {out_D, out_C, out_B, out_A}; 
    assign key_detect = key_detect_reg;  

    // Instancia del módulo top_module (debounce, flip-flops, etc.)
    top_teclado top_instance (
        .clk(clk),
        .rst(rst),
        .key(key),
        .c(c),
        .d(d),
        .count(count),
        .EN_s(EN_s),
        .out_A(out_A),
        .out_B(out_B),
        .out_C(out_C),
        .out_D(out_D)
    );

    // Instancia del módulo top_uart (manejo de UART y LEDs)
    top_uart uart_instance (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .tx(tx),
        .teclado(teclado),       
        .key_detect(key_detect), 
        .leds(leds)              
    );

    // Control key_detect
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            key_detect_reg <= 0;
            temporizador_activo <= 0;
            temporizador_deshabilitado <= 0;
            en_espera <= 0;
        end else begin
            if (en_espera) begin
                if (temporizador_deshabilitado > 0) begin
                    temporizador_deshabilitado <= temporizador_deshabilitado - 1;
                end else begin
                    en_espera <= 0;
                end
            end

            // Verificar si EN_s se activa y los tiempos de espera y activación
            if (EN_s && !en_espera && temporizador_activo == 0) begin
                key_detect_reg <= 1;         // Activa key_detect
                temporizador_activo <= tiempo_activo;
            end

            // key_detect_reg activo por tiempo_activo
            if (temporizador_activo > 0) begin
                temporizador_activo <= temporizador_activo - 1;
                if (temporizador_activo == 1) begin
                    key_detect_reg <= 0;       // Desactiva key_detect cuando llega a tiempo_activo
                    temporizador_deshabilitado <= tiempo_desabilitado; // Desabilita key_detect por tiempo_desabilitado
                    en_espera <= 1;
                end
            end
        end
    end

endmodule


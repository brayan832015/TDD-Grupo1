module lcd_init (
    input logic clk,
    input logic resetn,          // Reset activo bajo
    output logic [7:0] command,
    output logic start_init,
    input logic init_done
);

    // Lógica para la inicialización de la pantalla LCD
    typedef enum logic [1:0] {INIT_STATE, COMMAND1, COMMAND2} state_t;

    state_t state;

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state <= INIT_STATE;
            command <= 8'b0;
            start_init <= 0;
        end else begin
            case (state)
                INIT_STATE: begin
                    start_init <= 1; // Señal de inicio de inicialización
                    state <= COMMAND1;
                end
                COMMAND1: begin
                    command <= 8'h01; // Ejemplo de comando de inicialización
                    if (init_done) begin
                        state <= COMMAND2;
                    end
                end
                COMMAND2: begin
                    command <= 8'h02; // Otro comando de inicialización
                    if (init_done) begin
                        state <= INIT_STATE; // Completa la inicialización
                    end
                end
            endcase
        end
    end

endmodule

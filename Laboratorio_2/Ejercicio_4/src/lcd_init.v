module lcd_init (
    input wire clk,
    input wire reset,
    output reg [7:0] command,
    output reg start_init,
    input wire init_done
);
    // Lógica para la inicialización de la pantalla LCD
    parameter INIT_STATE = 0, COMMAND1 = 1, COMMAND2 = 2;
    reg [1:0] state;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= INIT_STATE;
            command <= 0;
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

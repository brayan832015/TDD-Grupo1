//Key_bounce_elimination
module debounce(
    input logic clk,
    input logic rst,
    input logic EN_b, //Entrada del botón con rebotes (key) activo en 1
    output logic EN_s //Salida estabilizada (sin rebotes)
    
);
 
    parameter integer DEBOUNCE_TIME = 54000; //Tiempo de debounce = 2ms = 27MHz/500
    
    logic [15:0] counter; //Contador para medir el tiempo de debounce
    logic EN_sync;        //Señal sincronizada al reloj

    always_ff@(posedge clk, posedge rst) begin
        if (rst) begin
            EN_sync <= 0;
            EN_s <= 0;
            counter <= 0;
        end else begin  
            EN_sync <= EN_b; //Se sincroniza la señal de entrada al reloj

            if (EN_sync != EN_s) begin //Se comprueba si el valor de entrada cambió    
                counter <= counter + 1; //Si la entrada cambia, se cuenta el tiempo de estabilidad
                
                if (counter >= DEBOUNCE_TIME) begin
                    EN_s <= EN_sync; //Si se mantiene estable durante DEBOUNCE_TIME, se actualiza la salida
                    counter <= 0; //Se reinicia el contador
                end

            end else begin
                counter <= 0; //Si la entrada no cambia, se reinicia el contador
            end
        end
    end

endmodule
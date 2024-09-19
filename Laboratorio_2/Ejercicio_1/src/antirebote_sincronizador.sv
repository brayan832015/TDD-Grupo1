module Contador(
    input logic clk,
    input logic rst_n,
    input logic EN_s,        //Entrada Enable estabilizada
    output logic [7:0] conta //8-bit counter output
);

    always_ff@(posedge clk, posedge rst_n) begin
        if (!rst_n)
            conta <= 0;  
        else if (EN_s)
            conta <= conta + 1;
    end

endmodule


module debounce (
    input logic clk,
    input logic rst_n,
    input logic EN_b, //Entrada del botón con rebotes
    output logic EN_s //Salida estabilizada (sin rebotes)
);
 
    parameter integer DEBOUNCE_TIME = 54000; //Tiempo de debounce = 2ms = 27MHz/500
    
    logic [15:0] counter; //Contador para medir el tiempo de debounce
    logic EN_sync;        //Señal sincronizada al reloj

    always_ff@(posedge clk, posedge rst_n) begin
        if (!rst_n) begin
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




module top_module (
    input logic clk,
    input logic rst_n,
    input logic EN_b,        //Entrada con rebotes
    output logic [7:0] conta //Contador de salida
);

    logic EN_s; //Señal estabilizada

    //Iniciar modulo de debounce
    debounce debounce_instance (
        .clk(clk),
        .rst_n(rst_n),
        .EN_b(EN_b),
        .EN_s(EN_s)
    );

    //Iniciar modulo contador
    Contador contador_instance (
        .clk(clk),
        .rst_n(rst_n),
        .EN_s(EN_s),  //Se usa la señal estable para contar
        .conta(conta)
    );

endmodule
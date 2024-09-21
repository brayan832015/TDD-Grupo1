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


module clock_divider(
    input logic clk,
    input logic rst,
    output logic scan_clk
);
    
    logic [20:0] clk_div;

    always_ff@(posedge clk, posedge rst) begin
        if (rst) begin
            clk_div <= 0;
            scan_clk <= 0;
        end else begin
            clk_div <= clk_div + 1;
            if (clk_div == 1080000) begin //Esto resulta en un reloj de escaneo de 25Hz
                clk_div <= 0;
                scan_clk <= ~scan_clk; 
            end
        end                           
    end

endmodule


module counter_2bit(
    input logic scan_clk,
    input logic rst,
    input logic inhibit, //inhibit de Key_bounce_elimination (EN_s)
    output logic [1:0] count
);

    always@(posedge scan_clk, posedge rst) begin
        if(rst) begin
            count <= 0;
        end else begin
            if(~inhibit) //Cuenta cuando inhibit es 0
            count <= count+1;
        end
    end

endmodule


module flip_flop_EN(
    input logic clk,
    input logic rst,
    input logic ck, //(normalmente 0) data_available de Key_bounce_elimination (EN_s)
    input logic data,
    output logic out
);

    always_ff@(posedge clk, posedge rst) begin
        if(rst) begin
            out <= 0;
        end else begin
            if(ck)
                out <= data;
        end
    end

endmodule




//key_detect -> debounce /clock_divider -> counter_2bit /-> Flip_Flop_EN

module top_module(
    //Entradas a la FPGA
    input logic clk,
    input logic rst,
    input logic key, //Input key_detect = EN_b
    input logic c, //Output C del codificador
    input logic d, //Output D del codificador msb

    //Salidas controladas por la FPGA
    output logic out_A,
    output logic out_B, 
    output logic out_C,
    output logic out_D
);

    logic [1:0] count;

    debounce debounce_instance(
        .clk(clk),
        .rst(rst),
        .EN_b(key), //<- debounce
        .EN_s(EN_s) //-> counter_2bit
    );


    clock_divider clock_divider_instance(
        .clk(clk),
        .rst(rst),
        .scan_clk(scan_clk) //-> counter_2bit
    );


    counter_2bit counter_2bit_instance(
        .scan_clk(scan_clk), //<- clock_divider
        .rst(rst),
        .inhibit(EN_s), //<- debounce
        .count(count) //-> flip_flop_EN
    );


    flip_flop_EN flip_flop_EN_inst1(
        .clk(clk),
        .rst(rst),
        .ck(EN_s), //<- debounce
        .data(count[0]), //data1 = A = lsb
        .out(out_A)
    );

    flip_flop_EN flip_flop_EN_inst2(
        .clk(clk),
        .rst(rst),
        .ck(EN_s), //<- debounce
        .data(count[1]), //data2 = B
        .out(out_B)
    );

    flip_flop_EN flip_flop_EN_inst3(
        .clk(clk),
        .rst(rst),
        .ck(EN_s), //<- debounce
        .data(c), //data3 = C
        .out(out_C)
    );

    flip_flop_EN flip_flop_EN_inst4(
        .clk(clk),
        .rst(rst),
        .ck(EN_s), //<- debounce
        .data(d), //data4 = D = msb
        .out(out_D)
    ); 

endmodule

// Agregar Data_available

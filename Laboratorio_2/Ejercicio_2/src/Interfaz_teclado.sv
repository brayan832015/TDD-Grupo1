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
    
    logic [18:0] clk_div;

    always_ff@(posedge clk, posedge rst) begin
        if (rst) begin
            clk_div <= 0;
            scan_clk <= 0;
        end else begin
            clk_div <= clk_div + 1;
            if (clk_div == 270000) begin //Esto resulta en un reloj de escaneo de 100Hz
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
            if(~inhibit) begin //Cuenta cuando inhibit es 0
                count <= count+1;
            end
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
            if(ck) begin
                out <= data;
            end else begin
                out <= 0;
            end
        end
    end

endmodule


module merge_bits(
    input logic bitD,  // Most significant bit (MSB)
    input logic bitC,
    input logic bitB,
    input logic bitA,  // Least significant bit (LSB)
    output logic [3:0] merged_output  // 4-bit output
);

    always_comb begin
        merged_output = {bitD, bitC, bitB, bitA};
    end

endmodule


module reassign(
    input logic [3:0] in,   // 4-bit input
    output logic [3:0] out_4bit  // 4-bit output
);

always_comb begin
    case (in)
        4'b1101: out_4bit = 4'b0000;  // 0 
        4'b0000: out_4bit = 4'b0001;  // 1 
        4'b0001: out_4bit = 4'b0010;  // 2 
        4'b0010: out_4bit = 4'b0011;  // 3 
        4'b0100: out_4bit = 4'b0100;  // 4 
        4'b0101: out_4bit = 4'b0101;  // 5 
        4'b0110: out_4bit = 4'b0110;  // 6 
        4'b1000: out_4bit = 4'b0111;  // 7 
        4'b1001: out_4bit = 4'b1000;  // 8 
        4'b1010: out_4bit = 4'b1001;  // 9 
        4'b0011: out_4bit = 4'b1010;  // A 
        4'b0111: out_4bit = 4'b1011;  // B 
        4'b1011: out_4bit = 4'b1100;  // C 
        4'b1111: out_4bit = 4'b1101;  // D 
        4'b1100: out_4bit = 4'b1110;  // * 
        4'b1110: out_4bit = 4'b1111;  // # 
        default: out_4bit = 4'b0000;  
    endcase
end

endmodule




//key_detect -> debounce /clock_divider -> counter_2bit -> merge bits -> reassign -> /-> Flip_Flop_EN -> LEDs & Data Available

module top_module(
    //Entradas a la FPGA
    input logic clk,
    input logic rst,
    input logic key, //Input key_detect = EN_b
    input logic c,   //Output C del codificador
    input logic d,   //Output D del codificador msb

    //Salidas controladas por la FPGA
    output logic [1:0] count,
    output logic ck,    //~Data_available = ck = EN_s
    output logic out_A,
    output logic out_B, 
    output logic out_C,
    output logic out_D
);

    logic [3:0] merged_output;
    logic [3:0] out_4bit;
    logic scan_clk;

    debounce debounce_instance(
        .clk(clk),
        .rst(rst),
        .EN_b(key), //<- key_detect
        .EN_s(EN_s) //-> counter_2bit & flip_flop_EN & Output Data_available 
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
        .count(count) //-> merge_bits
    );


    merge_bits merge_bits_instance(
        .bitD(d),
        .bitC(c),
        .bitB(count[1]),
        .bitA(count[0]),
        .merged_output(merged_output) //-> reassign
    );


    reassign reassign_instance(
        .in(merged_output), //<- merge_bits
        .out_4bit(out_4bit) //-> flip_flop_EN
    );


    flip_flop_EN flip_flop_EN_inst1(
        .clk(clk),
        .rst(rst),
        .ck(EN_s), //<- debounce
        .data(out_4bit[0]), //data1 = A = lsb
        .out(out_A)
    );

    flip_flop_EN flip_flop_EN_inst2(
        .clk(clk),
        .rst(rst),
        .ck(EN_s), //<- debounce
        .data(out_4bit[1]), //data2 = B
        .out(out_B)
    );

    flip_flop_EN flip_flop_EN_inst3(
        .clk(clk),
        .rst(rst),
        .ck(EN_s), //<- debounce
        .data(out_4bit[2]), //data3 = C
        .out(out_C)
    );

    flip_flop_EN flip_flop_EN_inst4(
        .clk(clk),
        .rst(rst),
        .ck(EN_s), //<- debounce
        .data(out_4bit[3]), //data4 = D = msb
        .out(out_D)
    ); 

endmodule

module top_uart (
    input logic clk,
    input logic rst,
    input logic rx,
    output logic tx,
    input logic [3:0] teclado,
    input logic key_detect,
    output logic [7:0] leds
    );

    logic [7:0] data_rx, data_tx;
    logic WR2c, transmit;
    logic busy;  
    logic [1:0] wait_counter;  

    // Instancias
    uart_rx uart_rx_inst (.clk(clk), .rst(rst), .rx(rx), .data_rx(data_rx), .WR2c(WR2c), .WR2d(WR2d), .hold_ctrl(hold_ctrl));

    uart_tx uart_tx_inst (.clk(clk), .rst(rst), .data_tx(data_tx), .transmit(transmit), .tx(tx), .busy(busy));

    // Estados
    typedef enum logic [1:0] {esperar, esperar_delay, transmitir, recibir} estados;  
    estados estado, sig_estado;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            estado <= esperar;
            leds <= 8'hFF;   // LEDs apagados (active low)
            wait_counter <= 0;  
        end else begin
            estado <= sig_estado;

            if (estado == recibir) begin
                leds <= ~data_rx;
            end

            if (estado == esperar_delay && wait_counter != 2'b10) begin
                wait_counter <= wait_counter + 1;  
            end else begin
                wait_counter <= 0;  
            end
        end
    end

    always_comb begin
        sig_estado = estado;
        transmit = 0; 
        case (estado)
            esperar: begin
                if (WR2c) begin  // Tecla laptop
                    sig_estado = recibir;   
                end else if (key_detect && !busy) begin  // Key detect y TX no está usandose
                    sig_estado = esperar_delay;  
                end 
            end
            
            esperar_delay: begin
                if (wait_counter == 2'b10) begin  // Espera dos ciclos para que los flip-flop carguen el valor en la salida
                    sig_estado = transmitir;  
                end else begin
                    sig_estado = esperar_delay; 
                end
            end

            transmitir: begin
                transmit = 1; 
                sig_estado = esperar;
            end
            
            recibir: begin
                sig_estado = esperar;
            end
        endcase
    end

    always_comb begin
        case (teclado)
            4'b0000: data_tx = 8'h30; // '0'
            4'b0001: data_tx = 8'h31; // '1'
            4'b0010: data_tx = 8'h32; // '2'
            4'b0011: data_tx = 8'h33; // '3'
            4'b0100: data_tx = 8'h34; // '4'
            4'b0101: data_tx = 8'h35; // '5'
            4'b0110: data_tx = 8'h36; // '6'
            4'b0111: data_tx = 8'h37; // '7'
            4'b1000: data_tx = 8'h38; // '8'
            4'b1001: data_tx = 8'h39; // '9'
            4'b1010: data_tx = 8'h41; // 'A'
            4'b1011: data_tx = 8'h42; // 'B'
            4'b1100: data_tx = 8'h43; // 'C'
            4'b1101: data_tx = 8'h44; // 'D'
            4'b1110: data_tx = 8'h2A; // '*'
            4'b1111: data_tx = 8'h23; // '#'
            default: data_tx = 8'h00; // Default case
        endcase
    end

endmodule

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


//key_detect -> debounce /clock_divider -> counter_2bit /-> Flip_Flop_EN

module top_module(
    //Entradas a la FPGA
    input logic clk,
    input logic rst,
    input logic key, //Input key_detect = EN_b
    input logic c, //Output C del codificador
    input logic d, //Output D del codificador msb

    //Salidas controladas por la FPGA
    output logic [1:0] count,
    output logic EN_s,
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
        .EN_b(key), //<- debounce
        .EN_s(EN_s) //-> counter_2bit & Output Data_available 
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
    top_module top_instance (
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


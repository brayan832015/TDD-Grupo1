module top_teclado(
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
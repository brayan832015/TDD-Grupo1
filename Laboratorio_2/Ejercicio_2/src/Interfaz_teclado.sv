module key_detect(
    input logic clk,
    input logic rst,
    input logic y4, y3, y2, y1, //Entradas activas en bajo
    output logic key //Salida -> Entrada a Key_bounce_elimination
);

    always@(posedge clk, posedge rst) begin
        if(rst) begin
            key <= 0;
        end else begin
            if(y4 && y3 && y2 && y1) //Solo en este caso no se está presionando ninguna tecla
                key <= 0;
            else
                key <= 1;
        end
    end

endmodule


module counter_2bit(
    input logic clk,
    input logic rst,
    input logic inhibit, //inhibit del Key_bounce_elimination
    output logic [1:0] count
);

    always@(posedge clk, posedge rst) begin
        if(rst) begin
            count <= 0;
        end else begin
            if(~inhibit) //Cuenta cuando inhibit es 0
            count <= count+1;
        end
    end

endmodule


module Flip_Flop_EN(
    input logic clk,
    input logic rst,
    input logic ck, //(normalmente 0) data_available de Key_bounce_elimination 
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
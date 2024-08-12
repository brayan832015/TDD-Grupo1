module keyboard (
    input [15:0] keys,  // 16 teclas de entrada
    output reg [3:0] led // 4 bits de salida para los LEDs
);

    always @(*) begin
        case (keys)
            16'b0000_0000_0000_0001: led = 4'b0000; // Tecla 0
            16'b0000_0000_0000_0010: led = 4'b0001; // Tecla 1
            16'b0000_0000_0000_0100: led = 4'b0010; // Tecla 2
            16'b0000_0000_0000_1000: led = 4'b0011; // Tecla 3
            16'b0000_0000_0001_0000: led = 4'b0100; // Tecla 4
            16'b0000_0000_0010_0000: led = 4'b0101; // Tecla 5
            16'b0000_0000_0100_0000: led = 4'b0110; // Tecla 6
            16'b0000_0000_1000_0000: led = 4'b0111; // Tecla 7
            16'b0000_0001_0000_0000: led = 4'b1000; // Tecla 8
            16'b0000_0010_0000_0000: led = 4'b1001; // Tecla 9
            16'b0000_0100_0000_0000: led = 4'b1010; // Tecla A
            16'b0000_1000_0000_0000: led = 4'b1011; // Tecla B
            16'b0001_0000_0000_0000: led = 4'b1100; // Tecla C
            16'b0010_0000_0000_0000: led = 4'b1101; // Tecla D
            16'b0100_0000_0000_0000: led = 4'b1110; // Tecla E
            16'b1000_0000_0000_0000: led = 4'b1111; // Tecla F
            default: led = 4'b0000; // Caso por defecto, ninguna tecla presionada
        endcase
    end
endmodule

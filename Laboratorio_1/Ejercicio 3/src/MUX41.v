
module MUX41 #(parameter WIDTH = 2)( // Con "WIDTH" se indican el número de bits (por defecto 2)
    input [WIDTH-1:0] d0, d1, d2, d3, // Entradas de "WIDTH" bits
    input [1:0] s, // Selector
    output [WIDTH-1:0] y // Salida de "WIDTH" bits
);
    
    assign y = (s[1] ? (s[0] ? d3 : d2)  // Lógica y salida del mux 4-1
                     : (s[0] ? d1 : d0));

endmodule
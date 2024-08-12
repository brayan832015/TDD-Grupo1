module tb_keyboard;

    reg [15:0] keys;
    wire [3:0] led;

    // Instancia del teclado
    keyboard uut (
        .keys(keys),
        .led(led)
    );

    initial begin
        // Inicializar las entradas y verificar cada tecla
        keys = 16'b0000_0000_0000_0001; // Tecla 0
        #10;
        
        keys = 16'b0000_0000_0000_0010; // Tecla 1
        #10;
        
        keys = 16'b0000_0000_0000_0100; // Tecla 2
        #10;
        
        keys = 16'b0000_0000_0000_1000; // Tecla 3
        #10;
        
        keys = 16'b0000_0000_0001_0000; // Tecla 4
        #10;
        
        keys = 16'b0000_0000_0010_0000; // Tecla 5
        #10;
        
        keys = 16'b0000_0000_0100_0000; // Tecla 6
        #10;
        
        keys = 16'b0000_0000_1000_0000; // Tecla 7
        #10;
        
        keys = 16'b0000_0001_0000_0000; // Tecla 8
        #10;
        
        keys = 16'b0000_0010_0000_0000; // Tecla 9
        #10;
        
        keys = 16'b0000_0100_0000_0000; // Tecla A
        #10;
        
        keys = 16'b0000_1000_0000_0000; // Tecla B
        #10;
        
        keys = 16'b0001_0000_0000_0000; // Tecla C
        #10;
        
        keys = 16'b0010_0000_0000_0000; // Tecla D
        #10;
        
        keys = 16'b0100_0000_0000_0000; // Tecla E
        #10;
        
        keys = 16'b1000_0000_0000_0000; // Tecla F
        #10;

        $stop; // Detener la simulación
    end
endmodule

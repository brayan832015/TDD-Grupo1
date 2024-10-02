module FSM(
    input logic clk,          
    input logic rst,
    input logic [7:0] data_rx,
    input logic [5:0] counter,
    input logic WR2c,           
    output logic lcd_resetn,
    output logic spi_force_rst,
    output logic [15:0] datain,
    output logic lcd_rs
);

// Variables internas
logic [8:0] init_cmd[69:0];
logic [15:0] P1, P2, pixel;                   
logic toggle_color, uart_data_valid, use_red, use_green;
logic [31:0] clk_cnt;
logic [6:0] cmd_index;
logic [7:0] row, col;
logic [3:0] state;

// Codificar estados
localparam INIT_RESET   = 4'b0000;
localparam INIT_WAKEUP  = 4'b0001;
localparam INIT_SNOOZE  = 4'b0010;
localparam INIT_WORKING = 4'b0011;
localparam INIT_DONE    = 4'b0100;

// Proceso para cambiar colores basado en UART
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        use_red <= 0;
        use_green <= 0;
        uart_data_valid <= 0;
    end 
    else begin
        if (WR2c) begin
            if (data_rx == 8'h31) begin       // Si el dato recibido es '1'
                use_red <= 1;                   // Usar Rojo y Azul
                use_green <= 0;                 // No usar verde
                uart_data_valid <= 1;
            end 
            else if (data_rx == 8'h32) begin  // Si el dato recibido es '2'
                use_red <= 0;                   // No usar rojo
                use_green <= 1;                 // Usar Verde y Azul
                uart_data_valid <= 1;
            end
        end
    end
end

// Control de colores
always_comb begin
    if (!uart_data_valid) begin
        // Pantalla en Azul al inicio
        P1 = 16'h001F; // Azul
        P2 = 16'h001F; // Azul
    end 
    else if (use_red) begin
        P1 = 16'hF800; // Rojo
        P2 = 16'h001F; // Azul
    end 
    else if (use_green) begin
        P1 = 16'h07E0; // Verde
        P2 = 16'h001F; // Azul
    end 
    else begin
        P1 = 16'h001F; // Azul
        P2 = 16'h001F; // Azul
    end
end

// Alternar entre P1 y P2 cada 30 columnas
always_ff @(posedge clk) begin
    if (rst) begin
        toggle_color <= 0;
    end
    else if (state == INIT_DONE) begin
        if (col == 29 || col == 59 || col == 89 || col == 119 || col == 149 || col == 179 || col == 209 || col == 239) begin
            toggle_color <= ~toggle_color;
        end
    end
end

// Selección del color según toggle_color
always_comb begin
    pixel = toggle_color ? P1 : P2;
end

// Inicialización de comandos de la pantalla LCD (ST7789V)
assign init_cmd[ 0] = 9'h036;
assign init_cmd[ 1] = 9'h170;
assign init_cmd[ 2] = 9'h03A;
assign init_cmd[ 3] = 9'h105;
assign init_cmd[ 4] = 9'h0B2;
assign init_cmd[ 5] = 9'h10C;
assign init_cmd[ 6] = 9'h10C;
assign init_cmd[ 7] = 9'h100;
assign init_cmd[ 8] = 9'h133;
assign init_cmd[ 9] = 9'h133;
assign init_cmd[10] = 9'h0B7;
assign init_cmd[11] = 9'h135;
assign init_cmd[12] = 9'h0BB;
assign init_cmd[13] = 9'h119;
assign init_cmd[14] = 9'h0C0;
assign init_cmd[15] = 9'h12C;
assign init_cmd[16] = 9'h0C2;
assign init_cmd[17] = 9'h101;
assign init_cmd[18] = 9'h0C3;
assign init_cmd[19] = 9'h112;
assign init_cmd[20] = 9'h0C4;
assign init_cmd[21] = 9'h120;
assign init_cmd[22] = 9'h0C6;
assign init_cmd[23] = 9'h10F;
assign init_cmd[24] = 9'h0D0;
assign init_cmd[25] = 9'h1A4;
assign init_cmd[26] = 9'h1A1;
assign init_cmd[27] = 9'h0E0;
assign init_cmd[28] = 9'h1D0;
assign init_cmd[29] = 9'h104;
assign init_cmd[30] = 9'h10D;
assign init_cmd[31] = 9'h111;
assign init_cmd[32] = 9'h113;
assign init_cmd[33] = 9'h12B;
assign init_cmd[34] = 9'h13F;
assign init_cmd[35] = 9'h154;
assign init_cmd[36] = 9'h14C;
assign init_cmd[37] = 9'h118;
assign init_cmd[38] = 9'h10D;
assign init_cmd[39] = 9'h10B;
assign init_cmd[40] = 9'h11F;
assign init_cmd[41] = 9'h123;
assign init_cmd[42] = 9'h0E1;
assign init_cmd[43] = 9'h1D0;
assign init_cmd[44] = 9'h104;
assign init_cmd[45] = 9'h10C;
assign init_cmd[46] = 9'h111;
assign init_cmd[47] = 9'h113;
assign init_cmd[48] = 9'h12C;
assign init_cmd[49] = 9'h13F;
assign init_cmd[50] = 9'h144;
assign init_cmd[51] = 9'h151;
assign init_cmd[52] = 9'h12F;
assign init_cmd[53] = 9'h11F;
assign init_cmd[54] = 9'h11F;
assign init_cmd[55] = 9'h120;
assign init_cmd[56] = 9'h123;
assign init_cmd[57] = 9'h021;
assign init_cmd[58] = 9'h029;
assign init_cmd[59] = 9'h02A;
assign init_cmd[60] = 9'h100;
assign init_cmd[61] = 9'h128;
assign init_cmd[62] = 9'h101;
assign init_cmd[63] = 9'h117;
assign init_cmd[64] = 9'h02B;
assign init_cmd[65] = 9'h100;
assign init_cmd[66] = 9'h135;
assign init_cmd[67] = 9'h100;
assign init_cmd[68] = 9'h1BB;
assign init_cmd[69] = 9'h02C;

`ifdef MODELTECH


localparam CNT_120MS = 32'd3240000;
localparam CNT_300MS = 32'd8100000;

`else

// speedup for simulation
localparam CNT_120MS = 32'd32;
localparam CNT_300MS = 32'd81;

`endif

// Inicializar y escribir LCD
always_ff @(posedge clk or posedge rst) begin
    lcd_resetn <= 1;
    if (rst) begin
        clk_cnt <= 0;
        cmd_index <= 0;
        state <= INIT_RESET;
        lcd_rs <= 1;
        row <= 0;
        col <= 0;
        spi_force_rst <= 1;
        datain <= 16'hffff;
        lcd_resetn <= 0;
    end 
    else begin
        case (state)
        
            /////////////////////////////////////////////////////0/////////////////////////////////////////////////////
        
            INIT_RESET : begin
                spi_force_rst <= 1; 
                if (clk_cnt == CNT_300MS) begin // 300 ms
                    clk_cnt <= 0;
                    spi_force_rst <= 1;     
                    state <= INIT_WAKEUP;
                end 
                else begin
                    clk_cnt <= clk_cnt + 1;     
                end
            end
            
            /////////////////////////////////////////////////////1/////////////////////////////////////////////////////
            
            INIT_WAKEUP : begin 
                spi_force_rst <= 0;
                if (counter == 15) begin
                    lcd_rs <= 0;
                    datain <= 16'h1100;
                end 
                else if (counter == 7) begin 
                    lcd_rs <= 1;
                    state <= INIT_SNOOZE;
                    spi_force_rst <= 1;
                end 
                else begin
                    datain <= { datain[14:8], 9'b111111111 };
                end
            end
            
            /////////////////////////////////////////////////////2/////////////////////////////////////////////////////
                        
            INIT_SNOOZE : begin
                spi_force_rst <= 1;
                if (clk_cnt == CNT_120MS) begin // 120 ms
                    clk_cnt <= 0;
                    state <= INIT_WORKING;
                end 
                else begin
                    clk_cnt <= clk_cnt + 1;
                end
            end
            
            /////////////////////////////////////////////////////3/////////////////////////////////////////////////////
            
            INIT_WORKING : begin
                spi_force_rst <= 0;
                if (cmd_index == 70) begin
                    state <= INIT_DONE;
                end 
                else begin
                    if (counter == 15) begin
                        lcd_rs <= init_cmd[cmd_index][8];
                        datain [15:8] <= init_cmd[cmd_index][7:0];
                    end 
                    else if (counter == 7) begin
                        lcd_rs <= 1;
                        cmd_index <= cmd_index + 1;
                        spi_force_rst <= 1;
                    end 
                    else begin
                        datain <= { datain[14:8], 9'b111111111 };
                    end
                end
            end
            
            /////////////////////////////////////////////////////4/////////////////////////////////////////////////////
            
            INIT_DONE : begin
                spi_force_rst <= 0;
                if (row == 135 && col == 240) begin
                    // Espera hasta que la pantalla esté lista
                end 
                else begin
                    if (counter == 15) begin
                        lcd_rs <= 1;
                        datain[15:8] <= pixel[15:8]; 
                    end 
                    else if (counter == 7) begin
                        datain[15:8] <= pixel[7:0]; 
                    end 
                    else if (counter == 0) begin
                        lcd_rs <= 1;
                        if (col == 239) begin
                            col <= 0;
                            if (row == 134) begin
                                row <= 0;
                                spi_force_rst <= 1;
                            end 
                            else begin
                                row <= row + 1;
                            end
                        end 
                        else begin
                            col <= col + 1;
                        end
                    end 
                    else begin
                        datain <= { datain[14:8], 9'b111111111 };
                    end
                end
            end
        endcase
    end
end

endmodule

module top(
    input logic clk,          
    input logic resetn,       // Reset activo en bajo
    input logic ser_rx,       
    output logic ser_tx,      
    output logic lcd_resetn,
    output logic lcd_clk,
    output logic lcd_cs,
    output logic lcd_rs,
    output logic lcd_data
);

// Módulo UART para recibir datos
logic [7:0] uart_data;        
logic uart_data_ready;        
logic uart_data_valid;        

uart_rx uart_inst (
    .clk(clk),
    .rst(~resetn),
    .rx(ser_rx),
    .data_rx(uart_data),
    .WR2c(uart_data_ready)
);

// Variables internas
localparam MAX_CMDS = 69;
logic [8:0] init_cmd[MAX_CMDS:0];
logic [15:0] P1;           // Color1 puede ser rojo, verde o blanco
logic [15:0] P2;           // Color2 puede ser azul o blanco
logic toggle_color;
logic [15:0] pixel;
logic use_red, use_green;      // Control para seleccionar rojo, verde o blanco
logic lcd_cs_r, lcd_rs_r, lcd_reset_r;
logic [7:0] spi_data;
logic [31:0] clk_cnt;
logic [6:0] cmd_index;
logic [4:0] bit_loop;
logic [7:0] row, col;
logic [3:0] init_state;

// Asignaciones
assign lcd_resetn = lcd_reset_r;
assign lcd_clk = ~clk;         // Clock de la pantalla LCD
assign lcd_cs = lcd_cs_r;
assign lcd_rs = lcd_rs_r;
assign lcd_data = spi_data[7]; // MSB del dato SPI

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

// Codificar estados
localparam INIT_RESET   = 4'b0000;
localparam INIT_PREPARE = 4'b0001;
localparam INIT_WAKEUP  = 4'b0010;
localparam INIT_SNOOZE  = 4'b0011;
localparam INIT_WORKING = 4'b0100;
localparam INIT_DONE    = 4'b0101;

// Proceso para cambiar colores basado en UART
always_ff @(posedge clk or negedge resetn) begin
    if (~resetn) begin
        use_red <= 0;
        use_green <= 0;
        uart_data_valid <= 0;
    end 
    else begin
        if (uart_data_ready) begin
            if (uart_data == 8'h31) begin       // Si el dato recibido es '1'
                use_red <= 1;                   // Usar Rojo y Azul
                use_green <= 0;                 // No usar verde
                uart_data_valid <= 1;
            end 
            else if (uart_data == 8'h32) begin  // Si el dato recibido es '2'
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
        // Pantalla en blanco al inicio
        P1 = 16'hFFFF; // Blanco
        P2 = 16'hFFFF; // Blanco
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
        P1 = 16'hFFFF; // Blanco
        P2 = 16'hFFFF; // Blanco
    end
end

// Alternar entre P1 y P2 cada 30 columnas
always_ff @(posedge clk or negedge resetn) begin
    if (~resetn) begin
        toggle_color <= 0;
    end 
    else if (init_state == INIT_DONE) begin
        if (col == 29 || col == 59 || col == 89 || col == 119 || col == 149 || col == 179 || col == 209 || col == 239) begin
            toggle_color <= ~toggle_color;
        end
    end
end

// Selección del color según toggle_color
always_comb begin
    pixel = toggle_color ? P1 : P2;
end

// Inicializar y escribir LCD
always_ff @(posedge clk or negedge resetn) begin
    if (~resetn) begin
        clk_cnt <= 0;
        cmd_index <= 0;
        init_state <= INIT_RESET;
        lcd_cs_r <= 1;
        lcd_rs_r <= 1;
        lcd_reset_r <= 0;
        spi_data <= 8'hFF;
        bit_loop <= 0;
        row <= 0;
        col <= 0;
    end 
    else begin
        case (init_state)
            INIT_RESET : begin
                if (clk_cnt == CNT_100MS) begin
                    clk_cnt <= 0;
                    init_state <= INIT_PREPARE;
                    lcd_reset_r <= 1;
                end 
                else begin
                    clk_cnt <= clk_cnt + 1;
                end
            end
            INIT_PREPARE : begin
                if (clk_cnt == CNT_200MS) begin
                    clk_cnt <= 0;
                    init_state <= INIT_WAKEUP;
                end 
                else begin
                    clk_cnt <= clk_cnt + 1;
                end
            end
            INIT_WAKEUP : begin
                if (bit_loop == 0) begin
                    lcd_cs_r <= 0;
                    lcd_rs_r <= 0;
                    spi_data <= 8'h11;
                    bit_loop <= bit_loop + 1;
                end 
                else if (bit_loop == 8) begin
                    lcd_cs_r <= 1;
                    lcd_rs_r <= 1;
                    bit_loop <= 0;
                    init_state <= INIT_SNOOZE;
                end 
                else begin
                    spi_data <= { spi_data[6:0], 1'b1 };
                    bit_loop <= bit_loop + 1;
                end
            end
            INIT_SNOOZE : begin
                if (clk_cnt == CNT_120MS) begin
                    clk_cnt <= 0;
                    init_state <= INIT_WORKING;
                end 
                else begin
                    clk_cnt <= clk_cnt + 1;
                end
            end
            INIT_WORKING : begin
                if (cmd_index == MAX_CMDS + 1) begin
                    init_state <= INIT_DONE;
                end 
                else begin
                    if (bit_loop == 0) begin
                        lcd_cs_r <= 0;
                        lcd_rs_r <= init_cmd[cmd_index][8];
                        spi_data <= init_cmd[cmd_index][7:0];
                        bit_loop <= bit_loop + 1;
                    end 
                    else if (bit_loop == 8) begin
                        lcd_cs_r <= 1;
                        lcd_rs_r <= 1;
                        bit_loop <= 0;
                        cmd_index <= cmd_index + 1;
                    end 
                    else begin
                        spi_data <= { spi_data[6:0], 1'b1 };
                        bit_loop <= bit_loop + 1;
                    end
                end
            end
            INIT_DONE : begin
                if (row == 135 && col == 240) begin
                    // Espera hasta que la pantalla esté lista
                end 
                else begin
                    if (bit_loop == 0) begin
                        lcd_cs_r <= 0;
                        lcd_rs_r <= 1;
                        spi_data <= pixel[15:8]; 
                        bit_loop <= bit_loop + 1;
                    end 
                    else if (bit_loop == 8) begin
                        spi_data <= pixel[7:0]; 
                        bit_loop <= bit_loop + 1;
                    end 
                    else if (bit_loop == 16) begin
                        lcd_cs_r <= 1;
                        lcd_rs_r <= 1;
                        bit_loop <= 0;
                        if (col == 239) begin
                            col <= 0;
                            if (row == 134) begin
                                row <= 0;
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
                        spi_data <= {spi_data[6:0], 1'b1};
                        bit_loop <= bit_loop + 1;
                    end
                end
            end
        endcase
    end
end

endmodule

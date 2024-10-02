// SPI de component byte (youtube)

module spi(
    input logic clk,
    input logic rst,
    input logic [15:0] datain,
    output logic spi_cs_l,
    output logic spi_sclk,          
    output logic spi_data,          
    output logic [5:0] counter
    );

    logic [15:0] MOSI;    
    logic [5:0] count;   
    logic cs_l;           
    logic sclk;
    logic [2:0] state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            MOSI <= 16'hffff;
            count <= 16;
            cs_l <= 1'b1;
            sclk <= 1'b0;
            state <= 0;
        end
        else begin
            case (state)
                0: begin
                    sclk <= 1'b0;
                    cs_l <= 1'b1;                  
                    state <= 1;
                end
                
                1: begin             
                    sclk <= 1'b0;
                    cs_l <= 1'b0;
                    //MOSI <= datain[15];
                    count <= count - 1;
                    state <= 2;              
                end
                
                2: begin
                    sclk <= 1'b1;
                    if (count > 0)
                        state <= 1; 
                    else begin
                        //count <= 16;
                        state <= 3;
                    end
                  end
                3: begin
                    count <= 16;
                    cs_l <= 1'b1;
                    state <= 0;
                end
                                    
                default:
                    state <= 0;
            endcase
        end
    end
    
    assign spi_cs_l = cs_l;
    assign spi_sclk = sclk;
    assign spi_data = datain[15];
    assign counter = count;
    
endmodule

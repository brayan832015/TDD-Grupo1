module uart_rx(
    input logic clk,
    input logic rst,
    input logic rx,
    output logic [7:0] data_rx,
    output logic WR2c,
    output logic WR2d,
    output logic hold_ctrl
    );
    
    //Internal variables
    logic shift;
    logic state, nextstate;
    logic [3:0] bit_counter;
    logic [1:0] sample_counter;
    logic [13:0] baudrate_counter;
    logic [9:0] rxshift_reg;
    logic clear_bitcounter, inc_bitcounter, inc_samplecounter, clear_samplecounter;
    
    //Constants
    parameter clk_freq = 27000000;
    parameter baud_rate = 9600;
    parameter div_sample = 4;
    parameter div_counter = clk_freq/(baud_rate*div_sample);
    parameter mid_sample = div_sample/2;
    parameter div_bit = 10;
    
    assign data_rx = rxshift_reg [8:1];
    
    //UART Receiver logic
    always@ (posedge clk)
    begin
        if(rst)
        begin
            state <= 0;
            bit_counter <= 0;
            baudrate_counter <= 0;
            sample_counter <= 0;
        end
        else
        begin
            baudrate_counter <= baudrate_counter + 1;
            if(baudrate_counter >= div_counter - 1)
            begin
                baudrate_counter <= 0;
                state <= nextstate;
                if(shift)
                    rxshift_reg <= {rx, rxshift_reg[9:1]};
                if (clear_samplecounter)
                    sample_counter <= 0;
                if (inc_samplecounter)
                    sample_counter <= sample_counter + 1;
                if (clear_bitcounter)
                    bit_counter <= 0;
                if (inc_bitcounter)
                    bit_counter <= bit_counter + 1;
            end
        end
    end
    
    //State machine
    always@ (posedge clk)
    begin
        shift <= 0;
        clear_samplecounter <= 0;
        inc_samplecounter <= 0;
        clear_bitcounter <= 0;
        inc_bitcounter <= 0;
        nextstate <= 0;
        case(state)
            0: begin
                if (rx)
                begin
                    nextstate <= 0;
                    WR2c <= 0;
                    hold_ctrl <= 0;
                end
                else
                begin
                    nextstate <= 1;
                    clear_bitcounter <= 1;
                    clear_samplecounter <= 1;
                    WR2d <= 1;
                    hold_ctrl <= 1;
                end
            end
            1: begin
                nextstate <= 1;
                if(sample_counter == mid_sample -1)
                    shift <= 1;
                if (sample_counter == div_sample -1)
                begin
                    if(bit_counter == div_bit -1)
                    begin
                        nextstate <= 0;
                        WR2c <= 1;
                        WR2d <= 0;
                    end
                    inc_bitcounter <= 1;
                    clear_samplecounter <= 1;
                end
                else
                    inc_samplecounter <= 1;
            end
            default:
                nextstate <= 0;
        endcase
    end
endmodule
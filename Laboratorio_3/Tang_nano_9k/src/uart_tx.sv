module uart_tx(
    input logic clk,
    input logic rst,
    input logic [7:0] data_tx,
    input logic transmit,
    output logic tx,
    output logic busy   // <-- New output to indicate TX is busy
    );
    
    logic [3:0] bit_counter;
    logic [13:0] baudrate_counter; 
    logic [9:0] shiftright_register;
    logic state, nextstate;
    logic shift;
    logic load;
    logic clear;
    
    always@ (posedge clk) begin
        if (rst) begin
            state <= 0;
            bit_counter <= 0;
            baudrate_counter <= 0;
            busy <= 0;  // <-- Reset the busy signal
        end else begin
            baudrate_counter <= baudrate_counter + 1;
            if(baudrate_counter == 2813) begin
                state <= nextstate;
                baudrate_counter <= 0;
                if (load)
                    shiftright_register <= {1'b1, data_tx, 1'b0};
                if (clear)
                    bit_counter <= 0;
                if (shift) begin
                    shiftright_register <= shiftright_register >> 1;
                    bit_counter <= bit_counter + 1;
                end
            end
        end
    end
    
    always@ (posedge clk) begin
        load <= 0;
        shift <= 0;
        clear <= 0;
        tx <= 1;
        busy <= (state == 1);  // <-- Busy signal is high when in transmit state
        case(state)
            0: begin
                if(transmit) begin
                    nextstate <= 1;
                    load <= 1;
                    busy <= 1;  // <-- Set busy when starting transmission
                end else begin
                    nextstate <= 0;
                    tx <= 1;
                end
            end
            1: begin
                if (bit_counter == 10) begin
                    nextstate <= 0;
                    clear <= 1;
                    busy <= 0;  // <-- Clear busy after transmission is complete
                end else begin
                    nextstate <= 1;
                    tx <= shiftright_register[0];
                    shift <= 1;
                end
            end
            default: nextstate <= 0;
        endcase
    end
endmodule

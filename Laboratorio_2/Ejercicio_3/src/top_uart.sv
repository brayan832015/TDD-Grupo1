module top_uart (
    input logic clk,
    input logic rst,
    input logic rx,             // RX UART input
    output logic tx,            // TX UART output
    input logic [3:0] keypad_in, // Keypad input for TX
    input logic transmit_key,    // Trigger for TX
    output logic [7:0] leds,     // LEDs displaying received data
    output logic rst_led,        // Reset LED (active low)
    output logic WR2c_led,       // RX valid data LED
    output logic transmit_led    // TX status LED
);

    // Internal signals
    logic [7:0] data_rx, data_tx;
    logic transmit, WR2c, WR2d, hold_ctrl;
    
    // UART RX and TX instances
    uart_rx uart_rx_inst (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .data_rx(data_rx),
        .WR2c(WR2c),
        .WR2d(WR2d),
        .hold_ctrl(hold_ctrl)
    );
    
    uart_tx uart_tx_inst (
        .clk(clk),
        .rst(rst),
        .data_tx(data_tx),
        .transmit(transmit),
        .tx(tx)
    );
    
    // FSM states
    typedef enum logic [1:0] {
        IDLE,
        RECEIVING,
        TRANSMITTING,
        WAIT
    } state_t;
    
    state_t state, next_state;
    
    // State machine logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;             // Reset state to IDLE
            leds <= 8'b11111111;
            rst_led <= 0;              // Activate reset LED (active low)
            transmit_led <= 1;
        end 
        else begin
            state <= next_state;
        end
    end
    
    // FSM and LED control
    always_comb begin
        // Default assignments to avoid latches
        next_state = state;        
        leds = 8'b11111111;        
        rst_led = 1;                // Default to off (since it's active low)
        WR2c_led = 1;
        transmit_led = 1;
        transmit = 0;
    
        case (state)
            IDLE: begin
                rst_led <= 0;
                if (WR2c) begin      // RX has valid data
                    next_state = RECEIVING;
                end else if (transmit_key) begin  // TX trigger pressed
                    next_state = TRANSMITTING;
                end
            end
            RECEIVING: begin
                leds = ~data_rx;     // Update LEDs with received data
                WR2c_led = 0;        // Indicate valid data
                next_state = WAIT;
            end
            TRANSMITTING: begin
                transmit = 1;        // Initiate TX
                transmit_led = 0;    // Indicate transmitting
                next_state = WAIT;
            end
            WAIT: begin
                if (!transmit_key && !WR2c) begin
                    next_state = IDLE; // Go back to IDLE when not receiving or transmitting
                end
            end
            default: begin
                next_state = IDLE;   // Default case, fall back to IDLE
            end
        endcase
    end
    
    // ASCII mapping for keypad
    always_comb begin
        case (keypad_in)
            4'b0000: data_tx = 8'h30; // '0'
            4'b0001: data_tx = 8'h31; // '1'
            4'b0010: data_tx = 8'h32; // '2'
            4'b0011: data_tx = 8'h33; // '3'
            4'b0100: data_tx = 8'h34; // '4'
            4'b0101: data_tx = 8'h35; // '5'
            4'b0110: data_tx = 8'h36; // '6'
            4'b0111: data_tx = 8'h37; // '7'
            4'b1000: data_tx = 8'h38; // '8'
            4'b1001: data_tx = 8'h39; // '9'
            4'b1010: data_tx = 8'h41; // 'A'
            4'b1011: data_tx = 8'h42; // 'B'
            4'b1100: data_tx = 8'h43; // 'C'
            4'b1101: data_tx = 8'h44; // 'D'
            4'b1110: data_tx = 8'h2A; // '*'
            4'b1111: data_tx = 8'h23; // '#'
            default: data_tx = 8'h00;  // Default case
        endcase
    end

endmodule

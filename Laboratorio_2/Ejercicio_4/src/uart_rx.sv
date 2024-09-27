module uart_rx (
    input logic clk,
    input logic resetn,  // Reset activo en bajo
    input logic rx,
    output logic [7:0] data_rx,  // Datos recibidos
    output logic valid_data,     // Indica cuando los datos son válidos
    output logic data_ready      // Indica que se ha recibido un dato completo
);

    // Variables internas
    logic shift;
    logic state, nextstate;
    logic [3:0] bit_counter;
    logic [1:0] sample_counter;
    logic [13:0] baudrate_counter;
    logic [9:0] rxshift_reg;
    logic clear_bitcounter, inc_bitcounter, inc_samplecounter, clear_samplecounter;

    // Constantes
    parameter int clk_freq = 27000000;
    parameter int baud_rate = 9600;
    parameter int div_sample = 4;
    parameter int div_counter = clk_freq / (baud_rate * div_sample);
    parameter int mid_sample = div_sample / 2;
    parameter int div_bit = 10;

    assign data_rx = rxshift_reg[8:1];

    // Lógica de recepción UART
    always_ff @(posedge clk) begin
        if (!resetn) begin
            state <= 0;
            bit_counter <= 0;
            baudrate_counter <= 0;
            sample_counter <= 0;
        end else begin
            baudrate_counter <= baudrate_counter + 1;
            if (baudrate_counter >= div_counter - 1) begin
                baudrate_counter <= 0;
                state <= nextstate;
                if (shift)
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

    // Máquina de estados
    always_ff @(posedge clk) begin
        shift <= 0;
        clear_samplecounter <= 0;
        inc_samplecounter <= 0;
        clear_bitcounter <= 0;
        inc_bitcounter <= 0;
        nextstate <= 0;
        case (state)
            0: begin
                // Estado de espera para inicio de trama
                if (rx) begin
                    nextstate <= 0;
                    valid_data <= 0;
                    data_ready <= 0;
                end else begin
                    nextstate <= 1;
                    clear_bitcounter <= 1;
                    clear_samplecounter <= 1;
                end
            end
            1: begin
                // Estado de recepción de datos
                nextstate <= 1;
                if (sample_counter == mid_sample - 1)
                    shift <= 1;
                if (sample_counter == div_sample - 1) begin
                    if (bit_counter == div_bit - 1) begin
                        nextstate <= 0;
                        data_ready <= 1;  // Indicar que el dato está listo
                        valid_data <= 1;  // Indicar que el dato es válido
                    end
                    inc_bitcounter <= 1;
                    clear_samplecounter <= 1;
                end else
                    inc_samplecounter <= 1;
            end
            default:
                nextstate <= 0;
        endcase
    end
endmodule

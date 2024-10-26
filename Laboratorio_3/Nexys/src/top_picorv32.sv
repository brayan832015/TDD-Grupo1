module top_picorv32 (
    input logic clk_i,
    input logic rst_i,
    output logic [31:0] ProgAddress_o,
    input logic [31:0] ProgIn_i,
    output logic [31:0] DataAddress_o,
    output logic [31:0] DataOut_o,
    input logic [31:0] DataIn_i,
    output logic we_o
);

    logic mem_valid;
    logic mem_instr;
    logic [31:0] mem_addr;
    logic [31:0] mem_wdata;
    logic [3:0]  mem_wstrb;
    logic [31:0] mem_rdata;
    logic mem_ready;

    picorv32 core (
        .clk        (clk_i),
        .resetn     (~rst_i),
        .mem_valid  (mem_valid),
        .mem_instr  (mem_instr),
        .mem_addr   (mem_addr),
        .mem_wdata  (mem_wdata),
        .mem_wstrb  (mem_wstrb),
        .mem_rdata  (mem_rdata),
        .mem_ready  (mem_ready)
    );

    assign ProgAddress_o = mem_instr ? mem_addr : 32'h0;
    assign DataAddress_o = mem_instr ? 32'h0 : mem_addr;
    assign DataOut_o     = mem_wdata;
    assign we_o          = |mem_wstrb; // we_o es alto si cualquier bit de mem_wstrb está activo
    assign mem_rdata     = mem_instr ? ProgIn_i : DataIn_i; // Entrada ROM o RAM

endmodule
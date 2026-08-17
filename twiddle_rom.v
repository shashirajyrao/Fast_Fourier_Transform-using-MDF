`timescale 1ns/1ps

module twiddle_rom #(
    parameter MAX_N = 1024,
    parameter N     = 1024
)(
    input clk,

    input  [$clog2(N)-2:0] rom_addr,

    output reg [15:0] twiddle_real,
    output reg [15:0] twiddle_imag
);

    localparam ROM_DEPTH = MAX_N / 2;
    localparam STRIDE    = MAX_N / N;

    reg [31:0] rom_mem [0:ROM_DEPTH-1];

    reg [$clog2(ROM_DEPTH)-1:0] strided_addr;


    initial begin
        $readmemh("twiddles.mem", rom_mem);
    end

    always @(*) begin
        strided_addr = rom_addr*STRIDE;
    end

    always @(*) begin
        twiddle_real = rom_mem[strided_addr][31:16];
        twiddle_imag = rom_mem[strided_addr][15:0];
    end

endmodule
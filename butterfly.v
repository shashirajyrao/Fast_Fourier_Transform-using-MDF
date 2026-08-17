`timescale 1ns/1ps

module Butterfly
(
    input  [15:0] a_real,
    input  [15:0] a_imag,

    input  [15:0] b_real,
    input  [15:0] b_imag,

    input  [15:0] twiddle_real,
    input  [15:0] twiddle_imag,

    output [15:0] out0_real,
    output [15:0] out0_imag,

    output [15:0] out1_real,
    output [15:0] out1_imag
);

    wire [15:0] diff_real;
    wire [15:0] diff_imag;

    posit_complex_add ADD
    (
        .a_r(a_real),
        .a_i(a_imag),

        .b_r(b_real),
        .b_i(b_imag),

        .r(out0_real),
        .i(out0_imag)
    );

    posit_complex_sub SUB
    (
        .a_r(a_real),
        .a_i(a_imag),

        .b_r(b_real),
        .b_i(b_imag),

        .r(diff_real),
        .i(diff_imag)
    );

    posit_complex_mul MUL
    (
        .a_r(diff_real),
        .a_i(diff_imag),

        .b_r(twiddle_real),
        .b_i(twiddle_imag),

        .r(out1_real),
        .i(out1_imag)
    );

endmodule
module posit_complex_encoder(

    input sign_r,
    input signed [5:0] k_r,
    input exp_r,
    input [31:0] frac_r,

    input sign_i,
    input signed [5:0] k_i,
    input exp_i,
    input [31:0] frac_i,

    output [15:0] posit_r,
    output [15:0] posit_i

);


posit_encode #(
    .N(16),
    .W_FRAC(32)
)
enc_real
(
    .sign(sign_r),
    .k(k_r),
    .exp(exp_r),
    .frac(frac_r),
    .nar(1'b0),
    .zero(1'b0),
    .p(posit_r)
);



posit_encode #(
    .N(16),
    .W_FRAC(32)
)
enc_imag
(
    .sign(sign_i),
    .k(k_i),
    .exp(exp_i),
    .frac(frac_i),
    .nar(1'b0),
    .zero(1'b0),
    .p(posit_i)
);


endmodule
module posit_complex_add(

    input [15:0] a_r,
    input [15:0] b_r,

    input [15:0] a_i,
    input [15:0] b_i,

    output [15:0] r,
    output [15:0] i

);


posit_add #(.N(16)) add_real
(
    .a(a_r),
    .b(b_r),
    .p_out(r)
);



posit_add #(.N(16)) add_imag
(
    .a(a_i),
    .b(b_i),
    .p_out(i)
);


endmodule
module posit_complex_sub(

    input [15:0] a_r,
    input [15:0] b_r,

    input [15:0] a_i,
    input [15:0] b_i,

    output [15:0] r,
    output [15:0] i

);


posit_sub #(.N(16)) sub_real
(
    .a(a_r),
    .b(b_r),
    .p_out(r)
);



posit_sub #(.N(16)) sub_imag
(
    .a(a_i),
    .b(b_i),
    .p_out(i)
);


endmodule
module posit_complex_mul(

    input [15:0] a_r,
    input [15:0] b_r,

    input [15:0] a_i,
    input [15:0] b_i,

    output [15:0] r,
    output [15:0] i

);


wire [15:0] ac;
wire [15:0] bd;

wire [15:0] ad;
wire [15:0] bc;



posit_mul #(.N(16)) mul_ac
(
    .a(a_r),
    .b(b_r),
    .p_out(ac)
);


posit_mul #(.N(16)) mul_bd
(
    .a(a_i),
    .b(b_i),
    .p_out(bd)
);



posit_mul #(.N(16)) mul_ad
(
    .a(a_r),
    .b(b_i),
    .p_out(ad)
);



posit_mul #(.N(16)) mul_bc
(
    .a(a_i),
    .b(b_r),
    .p_out(bc)
);



posit_sub #(.N(16)) real_sub
(
    .a(ac),
    .b(bd),
    .p_out(r)
);



posit_add #(.N(16)) imag_add
(
    .a(ad),
    .b(bc),
    .p_out(i)
);


endmodule
module posit_complex_decoder(

input [15:0] posit_r,
input [15:0] posit_i,

output sign_r,
output signed [5:0] k_r,
output exp_r,
output [12:0] frac_r,

output sign_i,
output signed [5:0] k_i,
output exp_i,
output [12:0] frac_i

);


posit_decode #(.N(16)) dec_r
(
.p(posit_r),
.sign(sign_r),
.k(k_r),
.exp(exp_r),
.frac(frac_r)
);


posit_decode #(.N(16)) dec_i
(
.p(posit_i),
.sign(sign_i),
.k(k_i),
.exp(exp_i),
.frac(frac_i)
);




endmodule
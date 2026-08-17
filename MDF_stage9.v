module MDF_stage9
(
input clk,
input rst_n,

input [31:0] in0,
input [31:0] in1,
input [31:0] in2,
input [31:0] in3,

input valid_in,

output [31:0] out0,
output [31:0] out1,
output [31:0] out2,
output [31:0] out3,

output valid_out
);


wire [15:0] x0r,x0i;
wire [15:0] x8r,x8i;
wire [15:0] x16r,x16i;
wire [15:0] x24r,x24i;



posit_complex_add add0
(
.a_r(in0[31:16]),
.b_r(in2[31:16]),

.a_i(in0[15:0]),
.b_i(in2[15:0]),

.r(x0r),
.i(x0i)
);


posit_complex_sub sub16
(
.a_r(in0[31:16]),
.b_r(in2[31:16]),

.a_i(in0[15:0]),
.b_i(in2[15:0]),

.r(x16r),
.i(x16i)
);



wire [15:0] neg_j_r;
wire [15:0] neg_j_i;

assign neg_j_r = in3[15:0];


posit_sub neg_real
(
.a(16'h0000),
.b(in3[31:16]),
.p_out(neg_j_i)
);



posit_complex_add add8
(
.a_r(in1[31:16]),
.b_r(neg_j_r),

.a_i(in1[15:0]),
.b_i(neg_j_i),

.r(x8r),
.i(x8i)
);



wire [15:0] pos_j_r;
wire [15:0] pos_j_i;




posit_sub neg_imag
(
.a(16'h0000),
.b(in3[15:0]),
.p_out(pos_j_r)
);

assign pos_j_i = in3[31:16];




posit_complex_add add24
(
.a_r(in1[31:16]),
.b_r(pos_j_r),

.a_i(in1[15:0]),
.b_i(pos_j_i),

.r(x24r),
.i(x24i)
);



assign out0={x0r,x0i};
assign out1={x8r,x8i};
assign out2={x16r,x16i};
assign out3={x24r,x24i};


assign valid_out=valid_in;


endmodule
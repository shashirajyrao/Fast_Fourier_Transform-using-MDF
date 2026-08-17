module MDF_stage8
(
input clk,
input rst_n,

input [31:0] in0,
input [31:0] in1,
input [31:0] in2,
input [31:0] in3,

input valid0,
input valid1,
input valid2,
input valid3,

output [31:0] out0,
output [31:0] out1,
output [31:0] out2,
output [31:0] out3,

output valid_out
);

wire [15:0] o0r,o0i;
wire [15:0] o1r,o1i;
wire [15:0] o2r,o2i;
wire [15:0] o3r,o3i;



wire [15:0] tw_real;
wire [15:0] tw_imag;

assign tw_real = 16'h4000;
assign tw_imag = 16'h0000;


Butterfly bf0
(
.a_real(in0[31:16]),
.a_imag(in0[15:0]),

.b_real(in2[31:16]),
.b_imag(in2[15:0]),

.twiddle_real(tw_real),
.twiddle_imag(tw_imag),

.out0_real(o0r), 
.out0_imag(o0i),

.out1_real(o1r),
.out1_imag(o1i)  
);


Butterfly bf1
(
.a_real(in1[31:16]),
.a_imag(in1[15:0]),

.b_real(in3[31:16]),
.b_imag(in3[15:0]),

.twiddle_real(16'h4000),
.twiddle_imag(16'h0000),

.out0_real(o2r),  
.out0_imag(o2i),

.out1_real(o3r),   
.out1_imag(o3i)
);


assign out0 = {o0r,o0i};
assign out1 = {o1r,o1i}; 

assign out2 = {o2r,o2i};
assign out3 = {o3r,o3i}; 


assign valid_out =
       valid0 &
       valid1 &
       valid2 &
       valid3;


endmodule
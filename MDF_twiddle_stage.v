module MDF_twiddle_stage
(
input clk,
input rst_n,

input [31:0] in0,
input [31:0] in1,
input [31:0] in2,
input [31:0] in3,

input valid_in,

output reg [31:0] out0,
output reg [31:0] out1,
output reg [31:0] out2,
output reg [31:0] out3,

output reg valid_out
);


reg [7:0] k;


always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        k <= 8'd0;
    end
    else if(valid_in)
    begin
        if(k==8'd255)
            k <= 8'd0;
        else
            k <= k+1'b1;
    end
end


wire [9:0] addr1;
wire [9:0] addr2;
wire [9:0] addr3;

assign addr1 = k;

assign addr2 = k*10'd2;

assign addr3 = k*10'd3;



wire [15:0] w1r,w1i;
wire [15:0] w2r,w2i;
wire [15:0] w3r,w3i;



MDF_twiddle_rom rom1
(
.addr(addr1),
.twiddle_real(w1r),
.twiddle_imag(w1i)
);



MDF_twiddle_rom rom2
(
.addr(addr2),
.twiddle_real(w2r),
.twiddle_imag(w2i)
);



MDF_twiddle_rom rom3
(
.addr(addr3),
.twiddle_real(w3r),
.twiddle_imag(w3i)
);

wire [31:0] out0_comb;
wire [31:0] out1_comb;
wire [31:0] out2_comb;
wire [31:0] out3_comb;



assign out0_comb = in0;



posit_complex_mul cm1
(
    .a_r(in1[31:16]),
    .a_i(in1[15:0]),

    .b_r(w1r),
    .b_i(w1i),

    .r(out1_comb[31:16]),
    .i(out1_comb[15:0])
);


posit_complex_mul cm2
(
    .a_r(in2[31:16]),
    .a_i(in2[15:0]),

    .b_r(w2r),
    .b_i(w2i),

    .r(out2_comb[31:16]),
    .i(out2_comb[15:0])
);


posit_complex_mul cm3
(
    .a_r(in3[31:16]),
    .a_i(in3[15:0]),

    .b_r(w3r),
    .b_i(w3i),

    .r(out3_comb[31:16]),
    .i(out3_comb[15:0])
);

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        out0 <= 32'd0;
        out1 <= 32'd0;
        out2 <= 32'd0;
        out3 <= 32'd0;
        valid_out <= 1'b0;
    end
    else
    begin
        out0 <= out0_comb;
        out1 <= out1_comb;
        out2 <= out2_comb;
        out3 <= out3_comb;

        valid_out <= valid_in;
    end
end


endmodule
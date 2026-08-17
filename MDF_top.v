module MDF_top
(
    input clk,
    input rst_n,

    input [31:0] din0_in,
input [31:0] din1_in,
input [31:0] din2_in,
input [31:0] din3_in,


input valid_in,

    output [31:0] dout1,
    output [31:0] dout2,
    output [31:0] dout3,
    output [31:0] dout4,
    output valid_out
);


reg        v0;
reg        v1;
reg        v2;
reg        v3;


reg [31:0] din0;
reg [31:0] din1;
reg [31:0] din2;
reg [31:0] din3;



always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        v0 <= 0;
        v1 <= 0;
        v2 <= 0;
        v3 <= 0;

        din0 <= 0;
        din1 <= 0;
        din2 <= 0;
        din3 <= 0;
    end
    else
    begin
        if(valid_in)
        begin
            din0 <= din0_in;
            din1 <= din1_in;
            din2 <= din2_in;
            din3 <= din3_in;

            v0 <= 1;
            v1 <= 1;
            v2 <= 1;
            v3 <= 1;
        end
        else
        begin
            v0 <= 0;
            v1 <= 0;
            v2 <= 0;
            v3 <= 0;
        end
    end
end


wire [31:0] sdf0_out;
wire [31:0] sdf1_out;
wire [31:0] sdf2_out;
wire [31:0] sdf3_out;
wire [31:0] tw_sdf0;
wire [31:0] tw_sdf1;
wire [31:0] tw_sdf2;
wire [31:0] tw_sdf3;

wire [31:0] stage8_out0;
wire [31:0] stage8_out1;
wire [31:0] stage8_out2;
wire [31:0] stage8_out3;


wire fft0_valid;
wire fft1_valid;
wire fft2_valid;
wire fft3_valid;
SDF #(.FFT_ID(0)) fft0
(
    .clk(clk),
    .rst_n(rst_n),

    .valid_in(v0),
    .din(din0),

    .dout(sdf0_out),
    .valid_out(fft0_valid)
);



SDF #(.FFT_ID(1))fft1
(
    .clk(clk),
    .rst_n(rst_n),

    .valid_in(v1),
    .din(din1),

    .dout(sdf1_out),
    .valid_out(fft1_valid)
);



SDF #(.FFT_ID(2))fft2
(
    .clk(clk),
    .rst_n(rst_n),

    .valid_in(v2),
    .din(din2),

    .dout(sdf2_out),
    .valid_out(fft2_valid)
);



SDF #(.FFT_ID(3))fft3
(
    .clk(clk),
    .rst_n(rst_n),

    .valid_in(v3),
    .din(din3),

    .dout(sdf3_out),
    .valid_out(fft3_valid)
);


wire [31:0] sdf0_reordered;
wire [31:0] sdf1_reordered;
wire [31:0] sdf2_reordered;
wire [31:0] sdf3_reordered;

wire sdf0_valid;
wire sdf1_valid;
wire sdf2_valid;
wire sdf3_valid;




SDF_reorder_256 reorder0
(
    .clk(clk),
    .rst_n(rst_n),

    .valid_in(fft0_valid),
    .din(sdf0_out),

    .dout(sdf0_reordered),
    .valid_out(sdf0_valid)
);


SDF_reorder_256 reorder1
(
    .clk(clk),
    .rst_n(rst_n),

    .valid_in(fft1_valid),
    .din(sdf1_out),

    .dout(sdf1_reordered),
    .valid_out(sdf1_valid)
);


SDF_reorder_256 reorder2
(
    .clk(clk),
    .rst_n(rst_n),

    .valid_in(fft2_valid),
    .din(sdf2_out),

    .dout(sdf2_reordered),
    .valid_out(sdf2_valid)
);


SDF_reorder_256 reorder3
(
    .clk(clk),
    .rst_n(rst_n),

    .valid_in(fft3_valid),
    .din(sdf3_out),

    .dout(sdf3_reordered),
    .valid_out(sdf3_valid)
);

MDF_twiddle_stage twiddle_stage
(
    .clk(clk),
    .rst_n(rst_n),

    .in0(sdf0_reordered),
.in1(sdf1_reordered),
.in2(sdf2_reordered),
.in3(sdf3_reordered),

    .valid_in(
    sdf0_valid &
    sdf1_valid &
    sdf2_valid &
    sdf3_valid
),

    .out0(tw_sdf0),
    .out1(tw_sdf1),
    .out2(tw_sdf2),
    .out3(tw_sdf3),

    .valid_out(tw_valid)
);

MDF_stage8 final_fft
(
    .clk(clk),
    .rst_n(rst_n),

    .in0(tw_sdf0),
    .in1(tw_sdf1),
    .in2(tw_sdf2),
    .in3(tw_sdf3),
    
    .valid0(tw_valid),
    .valid1(tw_valid),
    .valid2(tw_valid),
    .valid3(tw_valid),

    .out0(stage8_out0),
    .out1(stage8_out1),
    .out2(stage8_out2),
    .out3(stage8_out3),

    .valid_out(stage8_valid)
);



wire [31:0] stage9_out0;
wire [31:0] stage9_out1;
wire [31:0] stage9_out2;
wire [31:0] stage9_out3;
wire stage9_valid;


MDF_stage9 final_stage
(
    .clk(clk),
    .rst_n(rst_n),

    .in0(stage8_out0),
    .in1(stage8_out1),
    .in2(stage8_out2),
    .in3(stage8_out3),

    .valid_in(stage8_valid),

    .out0(stage9_out0),
    .out1(stage9_out1),
    .out2(stage9_out2),
    .out3(stage9_out3),

    .valid_out(stage9_valid)
);

MDF_Output_Transpose transpose
(
    .clk(clk),
    .rst_n(rst_n),

    .valid_in(stage9_valid),

    .din0(stage9_out0),
    .din1(stage9_out1),
    .din2(stage9_out2),
    .din3(stage9_out3),

    .dout0(dout1),
    .dout1(dout2),
    .dout2(dout3),
    .dout3(dout4),

    .valid_out(valid_out)
);
endmodule
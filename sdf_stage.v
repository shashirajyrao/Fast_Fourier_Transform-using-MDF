module SDF_stage #
(
    parameter DATA_W = 32,
    parameter DELAY  = 128,
    parameter STRIDE = 1,
    parameter STAGE  = 0,
    parameter FFT_N  = 256,
    parameter USESHIFT = 0
)
(
    input clk,
    input rst_n,
    input valid_in,
    input [DATA_W-1:0] din,

    output [DATA_W-1:0] dout,
    output valid_out
);

localparam TW_ADDR_W = $clog2(FFT_N);

wire [TW_ADDR_W-2:0] tw_addr;

wire [DATA_W-1:0] delayed_sample;


wire [DATA_W-1:0] bf_sum;
wire [DATA_W-1:0] bf_diff;

wire [15:0] twiddle_real;
wire [15:0] twiddle_imag;

wire [DATA_W-1:0] twiddle_out;


wire [DATA_W-1:0] delay_buffer_input;
wire fill_phase;
wire compute_phase;
wire stage_valid;
wire drain_phase;
sdf_controller #(
    .DELAY(DELAY),
    .STRIDE(STRIDE),
    .FFT_N(FFT_N)
) ctrl (
    .clk(clk),
    .rst_n(rst_n),
    .valid_in(valid_in),

    .fill_phase(fill_phase),
    .compute_phase(compute_phase),
    .drain_phase(drain_phase),
    .valid_out(stage_valid)

);
wire buffer_en;

assign buffer_en = valid_in | drain_phase;

wire write_en;
wire read_en;

assign write_en =
        fill_phase |
        compute_phase;

assign read_en =
        compute_phase |
        drain_phase;

assign delay_buffer_input =
        fill_phase    ? din :
        compute_phase ? lower_out :
                        {DATA_W{1'b0}};


generate
if(USESHIFT) begin : GEN_SHIFT

    shift_delay #(
        .DATA_W(DATA_W),
        .DEPTH(DELAY)
    )
    shift (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(buffer_en),
        .din(delay_buffer_input),
        .dout(delayed_sample)
    );

end
else begin : GEN_BUFFER

    Delay_Buffer #(
        .DATA_W(DATA_W),
        .DEPTH(DELAY)
    )
    delay_buf (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(buffer_en),
        .din(delay_buffer_input),
        .write_en(write_en),
        .read_en(read_en),
        .dout(delayed_sample)
    );

end
endgenerate  
wire [15:0] a_real = delayed_sample[31:16];
wire [15:0] a_imag = delayed_sample[15:0];

wire [15:0] b_real = din[31:16];
wire [15:0] b_imag = din[15:0];
wire [15:0] out0_real;
wire [15:0] out0_imag;
wire [31:0] upper_out;
wire [31:0] lower_out;
wire [15:0] out1_real;
wire [15:0] out1_imag;

Butterfly BF(

    .a_real(a_real),
    .a_imag(a_imag),

    .b_real(b_real),
    .b_imag(b_imag),

    .twiddle_real(twiddle_real),
    .twiddle_imag(twiddle_imag),

    .out0_real(out0_real),
    .out0_imag(out0_imag),

    .out1_real(out1_real),
    .out1_imag(out1_imag)

);
assign upper_out = {out0_real,out0_imag};
assign lower_out = {out1_real,out1_imag};

assign dout =
        drain_phase  ? delayed_sample :
        compute_phase ? upper_out :
                        32'd0;
reg [$clog2(DELAY)-1:0] bf_count;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        bf_count <= 0;
    else if (compute_phase) begin
        if (bf_count == DELAY-1)
            bf_count <= 0;
        else
            bf_count <= bf_count + 1;
    end
    else
        bf_count <= 0;
end

assign tw_addr = bf_count << STAGE;
assign valid_out = stage_valid;
twiddle_rom #(
    .MAX_N(1024),
    .N(FFT_N)
) twiddle (
    .clk(clk),
    .rom_addr(tw_addr),
    .twiddle_real(twiddle_real),
    .twiddle_imag(twiddle_imag)
);

endmodule
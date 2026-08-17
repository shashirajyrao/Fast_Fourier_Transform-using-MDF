module SDF #(
    parameter FFT_ID = 0,
    parameter FFT_N = 256
)
(
    input clk,
    input rst_n,

    input valid_in,
    input [31:0] din,

    output [31:0] dout,
    output valid_out
);


localparam STAGES = $clog2(FFT_N);


wire [31:0] stage_data [0:STAGES];
wire        stage_valid[0:STAGES];


assign stage_data[0]  = din;
assign stage_valid[0] = valid_in;


genvar i;

generate

for(i=0;i<STAGES;i=i+1)
begin : SDF_STAGE_GEN


    localparam integer DELAY =
                FFT_N >> (i+1);

    localparam integer STRIDE =
                1 << i;


    SDF_stage #(
        .DELAY(DELAY),
        .STRIDE(STRIDE),
        .STAGE(i),
        .USESHIFT((DELAY <= 8) ? 1 : 0)
    )
    stage_inst
    (
        .clk(clk),
        .rst_n(rst_n),

        .valid_in(stage_valid[i]),
        .din(stage_data[i]),

        .dout(stage_data[i+1]),
        .valid_out(stage_valid[i+1])
    );


end

endgenerate


assign dout      = stage_data[STAGES];
assign valid_out = stage_valid[STAGES];


endmodule
module shift_delay
#(
    parameter DATA_W = 32,
    parameter DEPTH  = 8
)
(
    input                   clk,
    input                   rst_n,
    input                   valid_in,
    input  [DATA_W-1:0]     din,

    output [DATA_W-1:0]     dout
);

reg [DATA_W-1:0] shift [0:DEPTH-1];

integer i;

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        for(i=0;i<DEPTH;i=i+1)
            shift[i] <= 0;
    end
    else if(valid_in)
    begin
        shift[0] <= din;

        for(i=1;i<DEPTH;i=i+1)
            shift[i] <= shift[i-1];
    end
end

assign dout = shift[DEPTH-1];

endmodule
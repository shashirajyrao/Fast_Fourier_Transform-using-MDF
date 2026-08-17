`timescale 1ns/1ps

module Delay_Buffer #(
    parameter DATA_W = 32,
    parameter DEPTH  = 128
)(
    input clk,
    input rst_n,
    input valid_in,
    input write_en,
    input read_en,
    input  [DATA_W-1:0] din,
    output [DATA_W-1:0] dout
);

localparam ADDR_W = $clog2(DEPTH);
localparam CNT_W = 32;
reg [CNT_W-1:0] sample_count;

reg [DATA_W-1:0] mem [0:DEPTH-1];

reg [ADDR_W-1:0] ptr;


integer i;


assign dout = mem[ptr];


always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        ptr <= 0;

        for(i=0;i<DEPTH;i=i+1)
            mem[i] <= 0;
    end
    else if(valid_in)
    begin

        if(write_en)
            mem[ptr] <= din;         
        
        if(ptr == DEPTH-1)
            ptr <= 0;
        else
            if(write_en || read_en)
                ptr <= ptr + 1;
    end
end



endmodule
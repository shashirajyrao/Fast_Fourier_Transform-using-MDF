module SDF_reorder_256
(
    input clk,
    input rst_n,

    input valid_in,
    input [31:0] din,

    output reg [31:0] dout,
    output reg valid_out
);


reg [31:0] mem [0:255];

reg [7:0] wr_ptr;
reg [7:0] rd_count;

reg read_phase;


function [7:0] bit_reverse;
    input [7:0] x;
    begin
        bit_reverse = {
            x[0],
            x[1],
            x[2],
            x[3],
            x[4],
            x[5],
            x[6],
            x[7]
        };
    end
endfunction



always @(posedge clk or negedge rst_n)
begin

    if(!rst_n)
    begin
        wr_ptr <= 8'd0;
        rd_count <= 8'd0;
        read_phase <= 1'b0;

        dout <= 32'd0;
        valid_out <= 1'b0;
    end


    else
    begin

        valid_out <= 1'b0;



        if(valid_in && !read_phase)
        begin

            mem[wr_ptr] <= din;


            if(wr_ptr == 8'd255)
            begin
                wr_ptr <= 8'd0;
                read_phase <= 1'b1;
            end

            else
            begin
                wr_ptr <= wr_ptr + 1'b1;
            end

        end




        if(read_phase)
        begin

            dout <= mem[bit_reverse(rd_count)];

            valid_out <= 1'b1;


            if(rd_count == 8'd255)
            begin
                rd_count <= 8'd0;
                read_phase <= 1'b0;
                wr_ptr <= 8'd0;
            end

            else
            begin
                rd_count <= rd_count + 1'b1;
            end

        end

    end

end

endmodule
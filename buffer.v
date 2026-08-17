module MDF_Output_Transpose
#(
    parameter FFT_N = 1024,
    parameter DATA_WIDTH = 32
)
(
    input clk,
    input rst_n,

    input valid_in,

    input [DATA_WIDTH-1:0] din0,
    input [DATA_WIDTH-1:0] din1,
    input [DATA_WIDTH-1:0] din2,
    input [DATA_WIDTH-1:0] din3,

    output reg [DATA_WIDTH-1:0] dout0,
    output reg [DATA_WIDTH-1:0] dout1,
    output reg [DATA_WIDTH-1:0] dout2,
    output reg [DATA_WIDTH-1:0] dout3,

    output reg valid_out
);


reg [DATA_WIDTH-1:0] mem [0:FFT_N-1];

reg [7:0] write_count;
reg [9:0] read_count;

reg read_enable;
reg read_delay;



always @(posedge clk or negedge rst_n)
begin

    if(!rst_n)
    begin
        write_count <= 0;
        read_count <= 0;

        read_delay <= 0;
        read_enable <= 0;

        valid_out <= 0;

        dout0 <= 0;
        dout1 <= 0;
        dout2 <= 0;
        dout3 <= 0;
    end


    else
    begin

        valid_out <= 0;


        if(valid_in && !read_enable)
        begin

        mem[write_count]       <= din0;
        mem[write_count+256]   <= din1;
        mem[write_count+512]   <= din2;
        mem[write_count+768]   <= din3;


        if(write_count==255)
        begin
            write_count <= 0;
            read_count <= 0;
            read_delay <= 1;
        end
        else
        begin
            write_count <= write_count+1'b1;
        end
    end



        if(read_delay)
        begin
            read_delay <= 0;
            read_enable <= 1;
        end




       if(read_enable)
        begin

            dout0 <= mem[read_count];
            dout1 <= mem[read_count+1];
            dout2 <= mem[read_count+2];
            dout3 <= mem[read_count+3];

            valid_out <= 1;


            if(read_count == 1020)
            begin
                read_count <= 0;
                read_enable <= 0;
            end
            else
            begin
                read_count <= read_count + 4;
            end

        end
    end
end

endmodule
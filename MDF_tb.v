`timescale 1ns/1ps

module MDF_top_tb;


reg clk;
reg rst_n;

reg valid_in;
reg [31:0] din0_in,din1_in,din2_in,din3_in;

wire [31:0] dout1,dout2,dout3,dout4;
wire valid_out;


MDF_top DUT
(
    .clk(clk),
    .rst_n(rst_n),

    .valid_in(valid_in),
    .din0_in(din0_in),
    .din1_in(din1_in),
    .din2_in(din2_in),
    .din3_in(din3_in), 

    .dout1(dout1),
    .dout2(dout2),
    .dout3(dout3),
    .dout4(dout4),
    .valid_out(valid_out)
);




reg [15:0] posit_mem [0:1023];


always #5 clk = ~clk;



integer i;
initial begin
    $readmemh("sine.mem", posit_mem);
end
initial
begin

    clk = 0;
    rst_n = 0;
    valid_in = 0;
    din0_in = 0;
    din1_in = 0;
    din2_in = 0;
    din3_in = 0;

    #20;
rst_n = 1;
@(posedge clk);
@(negedge clk);

valid_in = 1;

for(i=0;i<1024;i=i+4)
begin

  
        din0_in = {posit_mem[i],16'h0000};
        din1_in = {posit_mem[i+1],16'h0000};
        din2_in = {posit_mem[i+2],16'h0000};
        din3_in = {posit_mem[i+3],16'h0000};
     

    @(posedge clk);
    @(negedge clk);

end

valid_in = 0;

repeat(1000)
begin
    @(posedge clk);
    @(negedge clk);
end



$fclose(fp);
$finish;

end


integer fp;

initial begin

    fp = $fopen("mdf_output.txt","w");


    forever begin

        @(posedge clk);


        if(valid_out)
        begin
      

            $fdisplay(fp,
            "TIME=%0t OUT1=%h",
            $time,
            dout1);
            $fdisplay(fp,
            "TIME=%0t OUT2=%h",
            $time,
            dout2
            );
            $fdisplay(fp,
            "TIME=%0t OUT3=%h",
            $time,
            dout3
            );
            $fdisplay(fp,
            "TIME=%0t OUT4=%h",
            $time,
            dout4
            );


        end

    end

end



//////////////////////////////////////////////////
// Finish
//////////////////////////////////////////////////

initial begin

    #300000;

    $fclose(fp);

    $finish;

end

// always @(posedge clk)
// begin
//     if(valid_in)
//     begin
//         $display("MDF INPUT: %h %h %h %h",
//                  din0_in,
//                  din1_in,
//                  din2_in,
//                  din3_in);
//     end
// end
endmodule
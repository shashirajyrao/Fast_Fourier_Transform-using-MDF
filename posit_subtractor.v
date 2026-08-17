module posit_sub #(parameter N = 16)(
    input  [N-1:0] a,
    input  [N-1:0] b,
    output [N-1:0] p_out
);


    wire [N-1:0] neg_b = (~b) + 1'b1;

    posit_add #(.N(N)) adder_inst (
        .a(a),
        .b(neg_b),
        .p_out(p_out)
    );

endmodule

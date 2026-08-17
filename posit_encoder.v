module posit_encode #(
    parameter N = 16,
    parameter W_FRAC = N-4
)(
    input        sign,
    input signed [5:0] k,
    input        exp,
    input  [W_FRAC-1:0] frac,
    input        nar,
    input        zero,
    output reg [N-1:0] p
);

reg [N+3:0] temp_wide;
reg [N-1:0] rounded_p;
reg round_up;
integer idx;
integer i;
integer n_minus_2;

always @(*) begin
    n_minus_2 = N - 2;
    p    = 0;
    temp_wide = 0;
    rounded_p = 0;
    round_up  = 0;


    if (zero)
        p = 0;
    else if (nar)
        p = (1 << (N-1));
    else if (k >= (N-2)) begin
        p = sign ? ((1 << (N-1)) | 1) : ((1 << (N-1)) - 1); 
    end
    else if (k <= -(N-2)) begin
        p = sign ? ((1 << N) - 1) : 1; 
    end
    else begin

    
        idx = (N - 2) + 4;


        if (k >= 0) begin

            for (i=0; i<k+1 && idx>=4; i=i+1) begin
                temp_wide[idx] = 1'b1;
                idx = idx - 1;
            end

            if (idx >= 4) begin
                temp_wide[idx] = 1'b0;
                idx = idx - 1;
            end
        end
        else begin
            for (i=0; i<(-k) && idx>=4; i=i+1) begin
                temp_wide[idx] = 1'b0;
                idx = idx - 1;
            end
            if (idx >= 4) begin
                temp_wide[idx] = 1'b1;
                idx = idx - 1;
            end
        end
        if (idx >= 0) begin
            temp_wide[idx] = exp;
            idx = idx - 1;
        end

        for (i = 0; i < W_FRAC; i = i + 1) begin
            if (idx >= 0) begin
                temp_wide[idx] = frac[(W_FRAC-1) - i];
                idx = idx - 1;
            end
        end

        round_up = temp_wide[3] && (temp_wide[4] || |temp_wide[2:0]);

        if (round_up) begin
            rounded_p = temp_wide[N+3:4] + 1'b1;

            if (rounded_p[N-1] && ~temp_wide[N+3]) begin
                rounded_p = (1 << (N-1)) - 1;
            end
        end
        else begin
            rounded_p = temp_wide[N+3:4];
        end
        if (sign)
            p = ((~rounded_p) + 1'b1) & ((1 << N) - 1);
        else
            p = rounded_p;
    end
end

endmodule
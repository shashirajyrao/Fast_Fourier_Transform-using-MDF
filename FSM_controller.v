module sdf_controller
#(
    parameter STRIDE=1,
    parameter FFT_N =256,
    parameter DELAY = 128
)
(
    input clk,
    input rst_n,
    input valid_in,

    output fill_phase,
    output compute_phase,
    output drain_phase,
    output valid_out,
    output done
);

localparam ACTIVE = 2'd0;
localparam DRAIN  = 2'd1;
localparam DONE   = 2'd2;

reg [1:0] state;
reg [$clog2(FFT_N):0] in_count;   
reg [$clog2(DELAY):0] drain_count; 

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state <= ACTIVE;
        in_count <= 0;
        drain_count <= 0;
    end
    else begin
        case(state)
            ACTIVE: begin
                if(valid_in) begin
                    if(in_count == FFT_N - 1) begin
                        state <= DRAIN;
                        in_count <= 0;
                    end
                    else begin
                        in_count <= in_count + 1;
                    end
                end
            end

            DRAIN: begin

                if(drain_count == DELAY - 1) begin
                    state <= DONE;
                    drain_count <= 0;
                end
                else begin
                    drain_count <= drain_count + 1;
                end
            end

            DONE: begin
                state <= DONE;
            end
        endcase
    end
end


wire phase_bit = in_count[$clog2(DELAY)];

wire is_fill_cycle = (phase_bit == 1'b0);
wire is_comp_cycle = (phase_bit == 1'b1);

wire is_initial_fill = (in_count < DELAY);


assign fill_phase    = (state == ACTIVE) && is_fill_cycle;
assign compute_phase = (state == ACTIVE) && is_comp_cycle;


assign drain_phase   = (state == DRAIN) || ((state == ACTIVE) && is_fill_cycle && !is_initial_fill);

assign valid_out = compute_phase | drain_phase;

assign done = (state == DONE);

endmodule
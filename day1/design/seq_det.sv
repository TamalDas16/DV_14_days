module seq_det (
    input  logic clk,
    input  logic rst_n,
    input  logic din,
    output logic detected
);

    typedef enum logic [1:0] {
        S_IDLE,
        S_1,
        S_10,
        S_101
    } state_t;

    state_t state, next_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin
        next_state = state;
        detected   = 1'b0;

        case (state)
            S_IDLE: begin
                next_state = din ? S_1 : S_IDLE;
            end

            S_1: begin
                next_state = din ? S_1 : S_10;
            end

            S_10: begin
                next_state = din ? S_101 : S_IDLE;
            end

            S_101: begin
                detected   = din;
                next_state = din ? S_1 : S_10;
            end

            default: begin
                next_state = S_IDLE;
            end
        endcase
    end

endmodule

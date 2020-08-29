// iverilog -g 2012 -s debounce_testbench debounce.sv debounce_testbench.sv && ./a.out 
module debounce #(
    parameter N = 22
)
(
    input logic clk, reset,
    input logic sw,
    output logic db_level, db_tick
);

    typedef enum {zero, wait1, one, wait0} debounce_state;

    debounce_state state_reg, state_next;
    logic [N-1:0] q_reg, q_next;
    logic db_tick_reg, db_tick_next;
    logic db_level_reg, db_level_next;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) 
            begin
                state_reg <= zero;
                q_reg <= 0;
            end
        else
            begin
                state_reg <= state_next;
                q_reg <= q_next;
            end
    end

    always_comb begin
        state_next = state_reg;
        q_next = q_reg;
        db_tick = 0;
        db_level = 0;

        case (state_reg)
            zero: begin
                if (sw)
                    begin
                        state_next = wait1;
                        q_next = {N{1'b1}};
                    end
            end
            wait1: begin
                if (sw)
                    begin
                        q_next = q_reg - 1;
                        if (q_next == 0) begin
                            state_next = one;
                            db_tick = 1;
                        end
                    end
                else
                    state_next = zero;
            end
            one: begin
                db_level = 1;
                if (~sw) begin
                    state_next = wait0;
                    q_next = {N{1'b1}};
                end
            end
            wait0: begin
                db_level = 1;
                if (~sw)
                    begin
                        q_next = q_reg - 1;
                        if (q_next == 0) begin
                            state_next = zero;
                        end
                    end
                else
                    state_next = one;
            end
        endcase
    end
endmodule

// 4進カウンタ
// iverilog counter.sv && ./a.out

module counter(
    input clk, reset,
    output [1:0] y
);

    typedef enum {s0, s1, s2, s3} counter_state;

    counter_state state_reg, state_next;

    always_ff @(posedge clk)
        if (reset)
            state_reg <= s0;
        else
            state_reg <= state_next;

    always_comb
        case (state_reg)
            s0: state_next = s1;
            s1: state_next = s2;
            s2: state_next = s3;
            s3: state_next = s0;
            default: state_next = s0;
        endcase

    assign y = (state_reg == s0) ? 2'b00 :
               (state_reg == s1) ? 2'b01 :
               (state_reg == s2) ? 2'b10
                                 : 2'b11;
endmodule

module counter_test();
    logic clk = 0;
    logic reset = 0;
    logic [1:0] y;

    counter c(
        .clk(clk),
        .reset(reset),
        .y(y)
    );


    initial begin
        reset = 1; #10
        reset = 0; #10
        
        $display("%d", y); //=> 0

        clk = 1; #10
        clk = 0; #10

        $display("%d", y); //=> 1

        clk = 1; #10
        clk = 0; #10

        $display("%d", y); //=> 2

        clk = 1; #10
        clk = 0; #10

        $display("%d", y); //=> 3

        clk = 1; #10
        clk = 0; #10

        $display("%d", y); //=> 0

        clk = 1; #10
        clk = 0; #10

        $display("%d", y); //=> 1
    end
endmodule

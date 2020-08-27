module baud_gen(
    input clk, reset,
    input [10:0] dvsr,
    output tick
);
    logic [10:0] n_reg;
    logic [10:0] n_next;

    always_ff @(posedge clk, posedge reset)
        if (reset)
            n_reg <= 0;
        else
            n_reg <= n_next;

    assign n_next = (n_reg == dvsr) ? 0 : n_reg + 1;
    assign tick = (n_reg == 1);
endmodule

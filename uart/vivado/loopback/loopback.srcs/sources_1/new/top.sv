module top(
    input logic clk,
    input logic reset,
    input logic rx,
    output logic tx
);

    assign tx = rx;
endmodule

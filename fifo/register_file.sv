module register_file
#(
    parameter DATA_WIDTH = 8,
              ADDR_WIDTH = 2
)
(
    input clk, w_en,
    input [ADDR_WIDTH-1:0] w_addr, r_addr,
    input [DATA_WIDTH-1:0] w_data,
    output [DATA_WIDTH-1:0] r_data
);
    logic [DATA_WIDTH-1:0] registers [(ADDR_WIDTH**2)-1:0];

    assign r_data = registers[r_addr];

    always_ff @(posedge clk) begin
        if (w_en)
            registers[w_addr] <= w_data;
    end
endmodule

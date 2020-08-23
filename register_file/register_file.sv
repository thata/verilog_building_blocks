// register_file
// $ iverilog -g 2012 register_file.sv && ./a.out
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

module register_file_testbench();
    logic clk, w_en;
    logic [1:0] w_addr, r_addr;
    logic [7:0] w_data, r_data;
    
    register_file #(.DATA_WIDTH(8), .ADDR_WIDTH(2)) rf (
        .clk(clk),
        .w_en(w_en),
        .w_addr(w_addr),
        .r_addr(r_addr),
        .w_data(w_data),
        .r_data(r_data)
    );

    initial begin
        $dumpfile("register_file.vcd");
        $dumpvars(0, rf);

        clk = 0;
        w_en = 0;
        w_addr = 2'b0;
        r_addr = 2'b0;
        w_data = 8'b0;

        // R[0] <= 0xFF
        w_addr = 2'd0;
        w_data = 8'hFF;
        w_en = 1;
        clk = 1; #10
        clk = 0; #10

        w_en = 0;
        r_addr = 2'b00; #10
        assert(r_data == 8'hFF) $display("PASSED"); else $display("FAILED %b", r_data);

        // R[1] <= 0xEE
        w_addr = 2'd1;
        w_data = 8'hEE;
        w_en = 1;
        clk = 1; #10
        clk = 0; #10

        w_en = 0;
        r_addr = 2'b01; #10
        assert(r_data == 8'hEE) $display("PASSED"); else $display("FAILED %b", r_data);

        // R[2] <= 0xDD
        w_addr = 2'b10;
        w_data = 8'hDD;
        w_en = 1;
        clk = 1; #10
        clk = 0; #10

        w_en = 0;
        r_addr = 2'b10; #10
        assert(r_data == 8'hDD) $display("PASSED"); else $display("FAILED %b", r_data);

        // R[3] <= 0xCC
        w_addr = 2'b11;
        w_data = 8'hCC;
        w_en = 1;
        clk = 1; #10
        clk = 0; #10

        w_en = 0;
        r_addr = 2'b11; #10
        assert(r_data == 8'hCC) $display("PASSED"); else $display("FAILED %b", r_data);

        r_addr = 2'd0; #10
        assert(r_data == 8'hFF) $display("PASSED"); else $display("FAILED %b", r_data);
    end
endmodule

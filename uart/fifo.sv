// FIFO
// $ iverilog -g 2012 -s fifo_testbench fifo.sv fifo_testbench.sv register_file.sv && ./a.out

module fifo #(
    parameter DATA_WIDTH = 8,
              ADDR_WIDTH = 4
)
(
    input clk, reset,
    input wr, rd,
    input [DATA_WIDTH-1:0] w_data,
    output [DATA_WIDTH-1:0] r_data,
    output full, empty
);

    logic [ADDR_WIDTH-1:0] w_ptr, r_ptr, w_ptr_next, r_ptr_next, w_ptr_succ, r_ptr_succ;
    logic full_reg, empty_reg, full_next, empty_next;

    register_file #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) reg_file (
        .clk(clk),
        .w_en(wr & ~full_reg), // fullの場合は書き込まない
        .w_addr(w_ptr),
        .r_addr(r_ptr),
        .w_data(w_data),
        .r_data(r_data)
    );

    assign full = full_reg;
    assign empty = empty_reg;

    always_ff @(posedge clk, posedge reset) begin
        if (reset)
            begin
                w_ptr <= 0;
                r_ptr <= 0;
                full_reg <= 1'b0;
                empty_reg <= 1'b1;
            end
        else
            begin
                w_ptr <= w_ptr_next;
                r_ptr <= r_ptr_next;
                full_reg <= full_next;
                empty_reg <= empty_next;
            end
    end

    always_comb begin
        w_ptr_succ = w_ptr + 1;
        r_ptr_succ = r_ptr + 1;

        // default values
        w_ptr_next = w_ptr;
        r_ptr_next = r_ptr;
        full_next = full_reg;
        empty_next = empty_reg;

        case ({wr, rd})
            2'b01: // read
                begin
                    if (~empty_reg) begin
                        r_ptr_next = r_ptr_succ;
                        full_next = 1'b0;
                        if (r_ptr_next == w_ptr)
                            empty_next = 1'b1;
                    end
                end
            2'b10: // write
                begin
                    if (~full_reg) begin
                        w_ptr_next = w_ptr_succ;
                        empty_next = 1'b0;
                        if (w_ptr_succ == r_ptr)
                            full_next = 1'b1;
                    end
                end
            2'b11: // write & read
                begin
                    w_ptr_next = w_ptr_succ;
                    r_ptr_next = r_ptr_succ;
                end
            default:
                ;
        endcase
    end
endmodule

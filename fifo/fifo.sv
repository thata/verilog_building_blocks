// FIFO
// $ iverilog -g 2012 -s fifo_testbench fifo.sv register_file.sv && ./a.out

`timescale 1ns/1ps 

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

module fifo_testbench();
    logic clk, reset, wr, rd;
    logic full, empty;
    logic [7:0] w_data;
    logic [7:0] r_data;

    fifo #(.DATA_WIDTH(8), .ADDR_WIDTH(2)) dut (
        .clk(clk),
        .reset(reset),
        .wr(wr),
        .rd(rd),
        .w_data(w_data),
        .r_data(r_data),
        .full(full),
        .empty(empty)
    );

    initial begin
        $dumpfile("fifo.vcd");
        $dumpvars(0, dut);

        clk = 0;
        reset = 0;
        wr = 0;
        rd = 0;

        // reset
        reset = 1;
        clk = 1;
        #10
        reset = 0;
        clk = 0;
        #10

        // full == 0 && empty == 1
        assert(full == 0 & empty == 1) $display("PASSED"); else $display("FAILED full=%b, empty=%b", full, empty);

        // WR 0xAA
        rd = 0;
        wr = 1;
        w_data = 8'hAA;
        clk = 1; #10
        wr = 0;
        w_data = 8'b0;
        clk = 0; #10
        
        assert(r_data == 8'hAA) $display("PASSED"); else $display("FAILED r_data=%h", r_data);
        assert(full == 0 & empty == 0) $display("PASSED"); else $display("FAILED full=%b, empty=%b", full, empty);

        // WR 0xBB
        rd = 0;
        wr = 1;
        w_data = 8'hBB;
        clk = 1; #10
        wr = 0;
        w_data = 8'b0;
        clk = 0; #10
        
        assert(r_data == 8'hAA) $display("PASSED"); else $display("FAILED r_data=%h", r_data);
        assert(full == 0 & empty == 0) $display("PASSED"); else $display("FAILED full=%b, empty=%b", full, empty);

        // WR 0xCC
        rd = 0;
        wr = 1;
        w_data = 8'hCC;
        clk = 1; #10
        wr = 0;
        w_data = 8'b0;
        clk = 0; #10
        
        assert(r_data == 8'hAA) $display("PASSED"); else $display("FAILED r_data=%h", r_data);
        assert(full == 0 & empty == 0) $display("PASSED"); else $display("FAILED full=%b, empty=%b", full, empty);

        // WR 0xDD (fullになる)
        rd = 0;
        wr = 1;
        w_data = 8'hDD;
        clk = 1; #10
        wr = 0;
        w_data = 8'b0;
        clk = 0; #10
        
        assert(r_data == 8'hAA) $display("PASSED"); else $display("FAILED r_data=%h", r_data);
        assert(full == 1 & empty == 0) $display("PASSED"); else $display("FAILED full=%b, empty=%b", full, empty);

        // fullな状態で WR 0xEE する（fullのまま状態は変わらず & 0xEEは書き込まれない）
        rd = 0;
        wr = 1;
        w_data = 8'hEE;
        clk = 1; #10
        wr = 0;
        w_data = 8'b0;
        clk = 0; #10
        
        assert(r_data == 8'hAA) $display("PASSED"); else $display("FAILED r_data=%h", r_data);
        assert(full == 1 & empty == 0) $display("PASSED"); else $display("FAILED full=%b, empty=%b", full, empty);

        // RD (BBがトップに来る)
        rd = 1;
        wr = 0;
        clk = 1; #10
        rd = 0;
        clk = 0; #10
        
        assert(r_data == 8'hBB) $display("PASSED"); else $display("FAILED r_data=%h", r_data);
        assert(full == 0 & empty == 0) $display("PASSED"); else $display("FAILED full=%b, empty=%b", full, empty);

        // RD (CCがトップに来る)
        rd = 1;
        wr = 0;
        clk = 1; #10
        rd = 0;
        clk = 0; #10
        
        assert(r_data == 8'hCC) $display("PASSED"); else $display("FAILED r_data=%h", r_data);
        assert(full == 0 & empty == 0) $display("PASSED"); else $display("FAILED full=%b, empty=%b", full, empty);

        // RD (DDがトップに来る)
        rd = 1;
        wr = 0;
        clk = 1; #10
        rd = 0;
        clk = 0; #10
        
        assert(r_data == 8'hDD) $display("PASSED"); else $display("FAILED r_data=%h", r_data);
        assert(full == 0 & empty == 0) $display("PASSED"); else $display("FAILED full=%b, empty=%b", full, empty);

        // RD (emptyになる & リングバッファを1周回ってAAがトップに来る)
        rd = 1;
        wr = 0;
        clk = 1; #10
        rd = 0;
        clk = 0; #10
        
        assert(full == 0 & empty == 1) $display("PASSED"); else $display("FAILED full=%b, empty=%b", full, empty);
        assert(r_data == 8'hAA) $display("PASSED"); else $display("FAILED r_data=%h", r_data);

        // emptyな状態でRDする (emptyのまま & 読み込みポインタは動かずAAのまま)
        rd = 1;
        wr = 0;
        clk = 1; #10
        rd = 0;
        clk = 0; #10
        
        assert(full == 0 & empty == 1) $display("PASSED"); else $display("FAILED full=%b, empty=%b", full, empty);
        assert(r_data == 8'hAA) $display("PASSED"); else $display("FAILED r_data=%h", r_data);

        // WR 0xEE
        rd = 0;
        wr = 1;
        w_data = 8'hEE;
        clk = 1; #10
        wr = 0;
        w_data = 8'b0;
        clk = 0; #10

        assert(r_data == 8'hEE) $display("PASSED"); else $display("FAILED r_data=%h", r_data);
        assert(full == 0 & empty == 0) $display("PASSED"); else $display("FAILED full=%b, empty=%b", full, empty);

        // TODO: RDとWRを当時に行う
        rd = 1;
        wr = 1;
        w_data = 8'hFF;
        clk = 1; #10
        wr = 0;
        w_data = 8'b0;
        clk = 0; #10

        assert(r_data == 8'hFF) $display("PASSED"); else $display("FAILED r_data=%h", r_data);
        assert(full == 0 & empty == 0) $display("PASSED"); else $display("FAILED full=%b, empty=%b", full, empty);
    end
endmodule

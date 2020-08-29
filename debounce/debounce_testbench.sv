`timescale 1ns/1ps 

module debounce_testbench();
    logic clk, reset, sw;
    logic db_level, db_tick;

    debounce #(.N(4)) dut (
        clk,
        reset,
        sw,
        db_level,
        db_tick
    );

    initial begin
        $dumpfile("debounce.vcd");
        $dumpvars(0, dut);

        clk = 0;
        sw = 0;

        reset = 1; #10
        reset = 0; #10

        #100
        
        sw = 1;

        #500

        sw = 0;

        #500
        
        sw = 1;
        #100
        sw = 0;
        #100
        sw = 1;
        #100
        sw = 0;
        #100
        sw = 1;


        #10000 $finish;
    end

    // 5nsごとにclkを反転することで100MHzのクロックを生成
    always #5
        clk <= ~clk;

endmodule

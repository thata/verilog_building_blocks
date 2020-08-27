`timescale 1ns/1ps 

// iverilog -g 2012 -s baud_gen_testbench baud_gen.sv baud_gen_testbench.sv && ./a.out 
module baud_gen_testbench();
    logic clk, reset, tick;

    baud_gen bg (
        .clk(clk),
        .reset(reset),
        .dvsr(11'd651), // 100MHz / (16サンプリング * 9600Hz)
        .tick(tick)
    );

    initial begin
        $dumpfile("baud_gen.vcd");
        $dumpvars(0, bg);

        clk = 0;

        reset = 1; #10
        reset = 0; #10

        // 50万タイムスケール後に終了
        #500000 $finish;
    end

    // 5nsごとにclkを反転することで100MHzのクロックを生成
    always #5
        clk <= ~clk;
endmodule

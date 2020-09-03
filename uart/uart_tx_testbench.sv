`timescale 1ns/1ps

module uart_tx_testbench();
    logic clk, reset;
    logic tx_start, s_tick;
    logic [7:0] din;
    logic tx_done_tick, tx;

    baud_gen bg (
        .clk(clk),
        .reset(reset),
        .dvsr(11'd651), // 100MHz / (16サンプリング * 9600Hz)
        .tick(s_tick)
    );

    uart_tx dut (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .s_tick(s_tick),
        .din(din),
        .tx_done_tick(tx_done_tick),
        .tx(tx)
    );

    initial begin
        $dumpfile("uart_tx.vcd");
        $dumpvars(0, dut);

        clk = 0;
        tx_start = 0;
        din = 8'd0;

        reset = 1; #10
        reset = 0; #10

        // 9600Hzの1周期が約10400ナノ秒
        #104000

        // データ送信開始（1回目）
        din = 8'h55;
        tx_start = 1;
        #10
        tx_start = 0;

        #2080000

        // データ送信開始（2回目）
        din = 8'hAA;
        tx_start = 1;
        #10
        tx_start = 0;

        #2000000 $finish;
    end

    // 5nsごとにclkを反転することで100MHzのクロックを生成
    always #5
        clk <= ~clk;
endmodule

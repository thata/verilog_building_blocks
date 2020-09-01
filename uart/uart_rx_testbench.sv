`timescale 1ns/1ps 

module uart_rx_testbench();
    logic clk, reset;
    logic s_tick, rx;
    logic [7:0] dout;
    logic rx_done_tick;

    baud_gen bg (
        .clk(clk),
        .reset(reset),
        .dvsr(11'd651), // 100MHz / (16サンプリング * 9600Hz)
        .tick(s_tick)
    );

    uart_rx dut (
        .clk(clk),
        .reset(reset),
        .s_tick(s_tick),
        .rx(rx),
        .dout(dout),
        .rx_done_tick(rx_done_tick)
    );

    initial begin
        $dumpfile("uart_rx.vcd");
        $dumpvars(0, dut);

        clk = 0;
        rx = 1;

        reset = 1; #10
        reset = 0; #10

        // 9600Hzの1周期が約10400ナノ秒
        #104000

        // スタートビットを立てる
        rx = 0;
        #104000

        // rx_state_reg が 0(idle) から 1(start) になること

        // 以下のデータビット(0b01010101 = 0x55)を送信
        // 1, 0, 1, 0, 1, 0, 1, 0
        rx = 1;
        #104000
        rx = 0;
        #104000
        rx = 1;
        #104000
        rx = 0;
        #104000
        rx = 1;
        #104000
        rx = 0;
        #104000
        rx = 1;
        #104000
        rx = 0;
        #104000

        // ストップビットを立てる
        rx = 1;
        #104000

        // dout = 0x55 かつ rx_done_tick に1が立つこと

        // スタートビットを立てる
        rx = 0;
        #104000

        // 以下のデータビット(0x55)を送信
        // 1, 1, 1, 1, 1, 1, 1, 1
        rx = 1;
        #104000
        rx = 1;
        #104000
        rx = 1;
        #104000
        rx = 1;
        #104000
        rx = 1;
        #104000
        rx = 1;
        #104000
        rx = 1;
        #104000
        rx = 1;
        #104000

        // ストップビットを立てる
        rx = 1;
        #104000

        // dout = 0xFF かつ rx_done_tick に1が立つこと

        #200000 $finish;
    end

    // 5nsごとにclkを反転することで100MHzのクロックを生成
    always #5
        clk <= ~clk;
endmodule

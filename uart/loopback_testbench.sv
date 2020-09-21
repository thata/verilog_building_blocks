`timescale 1ns/1ps

module loopback_test();
    logic clk, reset, rx, tx;

    loopback dut (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .tx(tx)
    );

    // 5nsごとにclkを反転することで100MHzのクロックを生成
    always #5
        clk <= ~clk;

    initial begin
        $dumpfile("loopback.vcd");
        $dumpvars(0, dut);

        clk = 0;
        reset = 0;
        rx = 1;

        #10;
        reset = 1;
        #10;
        reset = 0;
        #10;

        /** 受信のテスト **/

        // 以下のデータビット(0b01010101 = 0x55)を受信
        // 1, 0, 1, 0, 1, 0, 1, 0
        rx = 0; // スタートビット
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
        rx = 1;
        #104000
        rx = 0;
        #104000
        rx = 1; // ストップビット
        #104000
        #104000

        // 以下のデータビット(0b00000000 = 0x00)を受信
        // 1, 0, 1, 0, 1, 0, 1, 0
        rx = 0; // スタートビット
        #104000
        rx = 0;
        #104000
        rx = 0;
        #104000
        rx = 0;
        #104000
        rx = 0;
        #104000
        rx = 0;
        #104000
        rx = 0;
        #104000
        rx = 0;
        #104000
        rx = 0;
        #104000
        rx = 1; // ストップビット
        #104000


        #2000000 $finish;
    end
endmodule

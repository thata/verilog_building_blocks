`timescale 1ns/1ps

module uart_testbench();
    logic clk, reset;
    logic [10:0] dvsr;
    logic [7:0] w_data, r_data;
    logic tx, rx;
    logic rd_uart, wr_uart;
    logic tx_full, rx_empty;

    uart dut (
        .clk(clk),
        .reset(reset),
        .rd_uart(rd_uart),
        .wr_uart(wr_uart),
        .rx(rx),
        .w_data(w_data),
        .dvsr(dvsr),
        .tx_full(tx_full),
        .rx_empty(rx_empty),
        .tx(tx),
        .r_data(r_data)
    );

    initial begin
        $dumpfile("uart.vcd");
        $dumpvars(0, dut);

        clk = 0;

        rx = 1;
        rd_uart = 0;
        wr_uart = 0;
        w_data = 8'd0;
        dvsr = 11'd651; // 100MHz / (16サンプリング * 9600Hz)

        reset = 1;
        #10
        reset = 0;
        #10

        #10400
        
        /** 送信のテスト **/

        // 送信データをセット
        w_data = 8'h55;
        wr_uart = 1;
        #10
        wr_uart = 0;

        #1500000 // これくらい待てば送信も終わってるはず

        // 送信データをセット
        w_data = 8'hAA;
        wr_uart = 1;
        #10
        wr_uart = 0;

        #1500000 // これくらい待てば送信も終わってるはず

        // FIFOバッファがいっぱいになるまでデータを書き込む

        // 0xF0を書き込み（これはOK）
        w_data = 8'hF0;
        wr_uart = 1;
        #10
        wr_uart = 0;
        #10

        // 0x0Fを書き込み（これはOK）
        w_data = 8'h0F;
        wr_uart = 1;
        #10
        wr_uart = 0;
        #10

        // 0x00を書き込み（これはOK）
        w_data = 8'h00;
        wr_uart = 1;
        #10
        wr_uart = 0;
        #10

        // 0xFFを書き込み（これはOK）
        w_data = 8'hFF;
        wr_uart = 1;
        #10
        wr_uart = 0;
        #10

        // 0x00を書き込み（FIFOバッファがいっぱいなので、これは出力されない）
        w_data = 8'h00;
        wr_uart = 1;
        #10
        wr_uart = 0;
        #10

        #6000000 // これくらい待てば送信も終わってるはず

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


        // 以下のデータビット(0b01010101 = 0xAA)を受信
        // 0, 1, 0, 1, 0, 1, 0, 1
        rx = 0; // スタートビット
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
        rx = 1;
        #104000
        #104000

        // 以下のデータビット(0b00000000 = 0x00)を受信
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
        #104000

        // 受信FIFOの先頭の値を取り除く（55からAAになる）
        rd_uart = 1;
        #10
        rd_uart = 0;
        #10

        #104000

        // 受信FIFOの先頭の値を取り除く（AAから00になる）
        rd_uart = 1;
        #10
        rd_uart = 0;
        #10

        #104000

        // 受信FIFOの先頭の値を取り除く（00も取り除き、不定値が返る）
        rd_uart = 1;
        #10
        rd_uart = 0;
        #10

        #104000

        #2000000 $finish;
    end

    // 5nsごとにclkを反転することで100MHzのクロックを生成
    always #5
        clk <= ~clk;
endmodule

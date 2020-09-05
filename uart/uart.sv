`timescale 1ns/1ps

module uart(
    input logic clk,
    input logic reset,
    input logic rd_uart,
    input logic wr_uart,
    input logic rx,
    input logic [7:0] w_data,
    input logic [10:0] dvsr,
    output logic tx_full,
    output logic rx_empty,
    output logic tx,
    output logic [7:0] r_data
);

    logic s_tick;
    logic tx_done_tick;
    logic txfifo_empty;
    logic [7:0] txfifo_rdata;

    baud_gen bg (
        .clk(clk),
        .reset(reset),
        .dvsr(dvsr),
        .tick(s_tick)
    );

    fifo #(.ADDR_WIDTH(2)) txfifo (
        .clk(clk),
        .reset(reset),
        .wr(wr_uart),
        .rd(tx_done_tick),
        .w_data(w_data),
        .r_data(txfifo_rdata),
        .full(tx_full),
        .empty(txfifo_empty)
    );

    uart_tx utx (
        .clk(clk),
        .reset(reset),
        .tx_start(~txfifo_empty),
        .s_tick(s_tick),
        .din(txfifo_rdata),
        .tx_done_tick(tx_done_tick),
        .tx(tx)
    );

    logic urx_rx_done_tick;
    logic [7:0] urx_dout;

    fifo #(.ADDR_WIDTH(2)) rxfifo (
        .clk(clk),
        .reset(reset),
        .wr(urx_rx_done_tick),
        .rd(rd_uart),
        .w_data(urx_dout),
        .r_data(r_data),
        .empty(rx_empty)
    );

    uart_rx urx (
        .clk(clk),
        .reset(reset),
        .s_tick(s_tick),
        .rx(rx),
        .dout(urx_dout),
        .rx_done_tick(urx_rx_done_tick) // あとで直す
    );
endmodule

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

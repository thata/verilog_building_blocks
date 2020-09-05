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
        // .tx_start(wr_uart),
        .tx_start(~txfifo_empty),
        .s_tick(s_tick),
        // .din(w_data),
        .din(txfifo_rdata),
        .tx_done_tick(tx_done_tick),
        .tx(tx)
    );

    uart_rx urx (

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
        $dumpvars(1, dut);

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

        // 送信データをセット
        w_data = 8'hF0;
        wr_uart = 1;
        #10
        wr_uart = 0;

        #1500000 // これくらい待てば送信も終わってるはず

        // 送信データをセット
        w_data = 8'h0F;
        wr_uart = 1;
        #10
        wr_uart = 0;

        #1500000 // これくらい待てば送信も終わってるはず

        // TODO
        // - [x] なんとなくtxに何かが出力されるようにする
        // - [x] FIFOを経由してtxに出力されるようにする



        #2000000 $finish;
    end

    // 5nsごとにclkを反転することで100MHzのクロックを生成
    always #5
        clk <= ~clk;
endmodule

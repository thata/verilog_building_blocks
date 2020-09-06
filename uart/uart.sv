// UART
// iverilog -g 2012 -s uart_testbench uart.sv uart_rx.sv uart_tx.sv baud_gen.sv fifo.sv register_file.sv uart_testbench.sv && ./a.out 
module uart #(
    parameter ADDR_WIDTH = 4
)
(
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
    logic urx_rx_done_tick;
    logic [7:0] urx_dout;

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

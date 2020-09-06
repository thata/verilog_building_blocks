//iverilog -g 2012 -s loopback_testbench *.sv && ./a.out
module loopback(
    input logic clk,
    input logic reset,
    input logic rx,
    output logic tx
);
    typedef enum {idle, receive, transmit} loopback_status;
    loopback_status loopback_status_reg, loopback_status_next;
    logic [7:0] b_reg, b_next;
    logic [7:0] received_data;
    logic rd_uart_reg, rd_uart_next;
    logic wr_uart_reg, wr_uart_next;
    logic rx_empty, tx_full;

    uart #(.ADDR_WIDTH(2)) ut (
        .clk(clk),
        .reset(reset),
        .rd_uart(rd_uart_reg),
        .wr_uart(wr_uart_reg),
        .rx(rx),
        .w_data(b_reg),
        .dvsr(11'd651),
        .tx_full(tx_full),
        .rx_empty(rx_empty),
        .tx(tx),
        .r_data(received_data)
    );

    always_ff @(posedge clk, posedge reset) begin
        if (reset)
            begin
                loopback_status_reg <= idle;
                rd_uart_reg <= 0;
                wr_uart_reg <= 0;
                b_reg <= 8'd0;
            end
        else
            begin
                loopback_status_reg <= loopback_status_next;
                rd_uart_reg <= rd_uart_next;
                wr_uart_reg <= wr_uart_next;
                b_reg <= b_next;
            end
    end

    always_comb begin
        loopback_status_next = loopback_status_reg;
        rd_uart_next = 0;
        wr_uart_next = 0;
        b_next = b_reg;

        case (loopback_status_reg)
            idle: begin
                if (~rx_empty)
                    loopback_status_next = receive;
            end
            receive: begin
                // NOTE: tx_fullになることは無さそうな気もするけど念のため
                if (~tx_full) begin
                    loopback_status_next = transmit;
                    rd_uart_next = 1;
                    b_next = received_data;
                end
            end
            transmit: begin
                loopback_status_next = idle;
                wr_uart_next = 1;
            end
        endcase
    end
endmodule

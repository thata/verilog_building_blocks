// iverilog -g 2012 -s loopback_test *.sv && ./a.out
module loopback(
    input logic clk,
    input logic reset,
    input logic rx,
    output logic tx
);
    typedef enum {idle, read_data, read_uart, write_data, write_uart} loopback_status;

    loopback_status loopback_status_reg, loopback_status_next;
    logic rd_uart_reg, rd_uart_next;
    logic wr_uart_reg, wr_uart_next;
    logic [7:0] r_data, r_data_reg, r_data_next;
    logic [7:0] w_data_reg, w_data_next;
    logic rx_empty, rx_empty_reg;

    uart ut (
        .clk(clk),
        .reset(reset),
        .rd_uart(rd_uart_reg),
        .wr_uart(wr_uart_reg),
        .rx(rx),
        .w_data(w_data_reg),
        .dvsr(11'd651),
        .rx_empty(rx_empty),
        .tx(tx),
        .r_data(r_data)
    );

    always_ff @(posedge clk, posedge reset) begin
        if (reset)
            begin
                loopback_status_reg <= idle;
                rd_uart_reg <= 0;
                wr_uart_reg <= 0;
                w_data_reg <= 0;
                r_data_reg <= 0;
                rx_empty_reg <= 1;
            end
        else
            begin
                loopback_status_reg <= loopback_status_next;
                rd_uart_reg <= rd_uart_next;
                wr_uart_reg <= wr_uart_next;
                w_data_reg <= w_data_next;
                r_data_reg <= r_data_next;
                rx_empty_reg <= rx_empty;
            end
    end

    always_comb begin
        loopback_status_next = loopback_status_reg;
        rd_uart_next = 0;
        wr_uart_next = 0;

        case (loopback_status_reg)
            idle: begin
                if (~rx_empty_reg)
                    loopback_status_next = read_data;
            end
            read_data: begin
                loopback_status_next = read_uart;
                r_data_next = r_data;
            end
            read_uart: begin
                loopback_status_next = write_data;
                rd_uart_next = 1;
            end
            write_data: begin
                loopback_status_next = write_uart;
                w_data_next = r_data_reg;
            end
            write_uart: begin
                loopback_status_next = idle;
                wr_uart_next = 1;
            end
        endcase
    end
endmodule

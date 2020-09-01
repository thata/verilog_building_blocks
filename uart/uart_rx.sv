// iverilog -g 2012 -s uart_rx_testbench uart_rx.sv uart_rx_testbench.sv baud_gen.sv && ./a.out
module uart_rx(
    input logic clk,
    input logic reset,
    input logic s_tick,
    input logic rx,
    output logic [N-1:0] dout,
    output logic rx_done_tick
);
    localparam N = 8;
    localparam SB_TICK = 16;

    typedef enum {idle, start, data, stop} rx_state;

    rx_state rx_state_reg, rx_state_next;
    logic [3:0] s_reg, s_next;
    logic [2:0] n_reg, n_next;
    logic [7:0] b_reg, b_next;

    assign dout = b_reg;

    always_ff @(posedge clk, posedge reset) begin
        if (reset)
            begin
                rx_state_reg <= idle;
                s_reg <= 0;
                n_reg <= 0;
                b_reg <= 0;
            end
        else
            begin
                rx_state_reg <= rx_state_next;
                s_reg <= s_next;
                n_reg <= n_next;
                b_reg <= b_next;
            end
    end

    always_comb begin
        rx_state_next = rx_state_reg;
        s_next = s_reg;
        n_next = n_reg;
        b_next = b_reg;
        rx_done_tick = 0;

        case (rx_state_reg)
            idle: begin
                if (rx == 0) begin
                    s_next = 0;
                    rx_state_next = start;
                end
            end
            start: begin
                if (s_tick == 1) begin
                    if (s_reg == 4'd7)
                        begin
                            s_next = 4'd0;
                            n_next = 3'b0;
                            rx_state_next = data;
                        end
                    else
                        s_next = s_reg + 4'd1;
                end
            end
            data: begin
                if (s_tick == 1) begin
                    if (s_reg == 4'd15)
                        begin
                            s_next = 4'd0;

                            // NOTE: 以下のようなエラーが出るのでなんとかしたい...
                            // ```
                            // constant selects in always_* processes are not currently supported
                            // (all bits will be included).
                            // ```
                            b_next = {rx, b_reg[7:1]};

                            if (n_reg == (N - 1))
                                rx_state_next = stop;
                            else
                                n_next = n_reg + 3'd1;
                        end
                    else
                        s_next = s_reg + 4'd1;
                end
            end
            stop: begin
                if (s_tick == 1) begin
                    if (s_reg == (SB_TICK - 1))
                        begin
                            rx_done_tick = 1;
                            rx_state_next = idle;
                        end
                    else
                        s_next = s_reg + 4'd1;
                end
            end
        endcase
    end
endmodule

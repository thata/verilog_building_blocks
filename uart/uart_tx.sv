// iverilog -g 2012 -s uart_tx_testbench uart_tx.sv  baud_gen.sv uart_tx_testbench.sv && ./a.out
module uart_tx(
    input logic clk,
    input logic reset,
    input logic tx_start,
    input logic s_tick,
    input logic [7:0] din,
    output logic tx_done_tick,
    output logic tx
);
    localparam DBIT = 8;
    localparam SB_TICK = 16;

    typedef enum {idle, start, data, stop} tx_state;

    tx_state tx_state_reg, tx_state_next;
    logic [3:0] s_reg, s_next;
    logic [2:0] n_reg, n_next;
    logic [7:0] b_reg, b_next;
    logic tx_reg, tx_next;

    assign tx = tx_reg;

    always_ff @(posedge clk, posedge reset) begin
        if (reset)
            begin
                tx_state_reg <= idle;
                s_reg <= 0;
                n_reg <= 0;
                b_reg <= 0;
                tx_reg <= 1;
            end
        else
            begin
                tx_state_reg <= tx_state_next;
                s_reg <= s_next;
                n_reg <= n_next;
                b_reg <= b_next;
                tx_reg <= tx_next;
            end
    end

    always_comb begin
        tx_done_tick = 0;
        tx_state_next = tx_state_reg;
        s_next = s_reg;
        n_next = n_reg;
        b_next = b_reg;
        tx_next = tx_reg;

        case (tx_state_reg)
            idle: begin
                if (tx_start) begin
                    s_next = 0;
                    b_next = din;
                    tx_state_next = start;
                end
            end
            start: begin
                tx_next = 0;
                if (s_tick) begin
                    if (s_reg == 15)
                        begin
                            s_next = 0;
                            n_next = 0;
                            tx_state_next = data;
                        end
                    else
                        s_next = s_reg + 1;
                end
            end
            data: begin
                tx_next = b_reg & 8'b00000001;
                if (s_tick) begin
                    if (s_reg == 15)
                        begin
                            s_next = 0;
                            b_next = b_reg >> 1;
                            if (n_reg == (DBIT - 1))
                                tx_state_next = stop;
                            else
                                n_next = n_reg + 1;
                        end
                    else
                        s_next = s_reg + 1;
                end
            end
            stop: begin
                tx_next = 1;
                if (s_tick == 1) begin
                    if (s_reg == (SB_TICK - 1))
                        begin
                            tx_state_next = idle;
                            tx_done_tick = 1;
                        end
                    else
                        s_next = s_reg + 1;
                end
            end
        endcase
    end
endmodule

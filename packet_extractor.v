module packet_extractor (
    input clk,
    input rst,
    input [7:0] fifo_data_in,
    input fifo_empty,
    output reg fifo_rd_en,
    output reg [7:0] payload_out,
    output reg byte_enable,
    output reg error_premature_end
);

    typedef enum reg [2:0] {
        IDLE, READ_HEADER_1, READ_HEADER_2, READ_PAYLOAD, DONE
    } state_t;
    state_t state, next_state;

    reg [15:0] payload_length;
    reg [15:0] bytes_remaining;

    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    always @(*) begin
        fifo_rd_en = 0;
        next_state = state;
        case (state)
            IDLE: if (!fifo_empty) next_state = READ_HEADER_1;
            READ_HEADER_1: begin
                if (!fifo_empty) begin
                    fifo_rd_en = 1;
                    next_state = READ_HEADER_2;
                end
            end
            READ_HEADER_2: begin
                if (!fifo_empty) begin
                    fifo_rd_en = 1;
                    next_state = READ_PAYLOAD;
                end
            end
            READ_PAYLOAD: begin
                if (bytes_remaining == 0)
                    next_state = DONE;
                else if (!fifo_empty)
                    fifo_rd_en = 1;
                else
                    next_state = READ_PAYLOAD;
            end
            DONE: next_state = IDLE;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            payload_length <= 0;
            bytes_remaining <= 0;
        end else if (fifo_rd_en && state == READ_HEADER_1)
            payload_length[15:8] <= fifo_data_in;
        else if (fifo_rd_en && state == READ_HEADER_2) begin
            payload_length[7:0] <= fifo_data_in;
            bytes_remaining <= {payload_length[15:8], fifo_data_in};
        end else if (fifo_rd_en && state == READ_PAYLOAD && bytes_remaining > 0)
            bytes_remaining <= bytes_remaining - 1;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            payload_out <= 0;
            byte_enable <= 0;
        end else if (fifo_rd_en && state == READ_PAYLOAD) begin
            payload_out <= fifo_data_in;
            byte_enable <= 1;
        end else begin
            byte_enable <= 0;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst)
            error_premature_end <= 0;
        else if (state == READ_PAYLOAD && fifo_empty && bytes_remaining > 0)
            error_premature_end <= 1;
        else if (state == IDLE)
            error_premature_end <= 0;
    end
endmodule

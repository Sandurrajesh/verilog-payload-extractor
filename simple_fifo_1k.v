module simple_fifo_1k (
    input clk, rst,
    input wr_en,
    input [7:0] wr_data,
    input rd_en,
    output reg [7:0] rd_data,
    output empty, full
);

    reg [7:0] mem [0:1023];
    reg [9:0] wr_ptr = 0, rd_ptr = 0;
    reg [10:0] count = 0;

    assign empty = (count == 0);
    assign full  = (count == 1024);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 0; rd_ptr <= 0; count <= 0;
        end else begin
            if (wr_en && !full) begin
                mem[wr_ptr] <= wr_data;
                wr_ptr <= wr_ptr + 1;
                count <= count + 1;
            end
            if (rd_en && !empty) begin
                rd_data <= mem[rd_ptr];
                rd_ptr <= rd_ptr + 1;
                count <= count - 1;
            end
        end
    end

endmodule

module pc(
    input wire clk,
    input wire rst,
    input wire [9:0] pc_in,
    output reg [9:0] pc_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_out <= 32'b0;
        end else begin
            pc_out <= pc_in;
        end
    end
endmodule
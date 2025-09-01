module register_file(
    input wire clk,
    input wire rst,
    input wire [4:0] read_reg_1,
    input wire [4:0] read_reg_2,
    input wire [4:0] write_reg,
    input wire [31:0] write_data_reg,
    input wire regWrite,
    output wire [31:0] read_data_reg_1,
    output wire [31:0] read_data_reg_2
);
    reg [31:0] registers[31:0];

    assign read_data_reg_1 = registers[read_reg_1];
    assign read_data_reg_2 = registers[read_reg_2];
    
    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end else if (regWrite) begin
            registers[write_reg] <= write_data_reg;
            if(write_reg != 0) begin
                $display("Register %d: %d at time: %t", write_reg, write_data_reg, $time);
            end
            
        end
    end
endmodule
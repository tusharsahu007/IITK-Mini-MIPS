// temporary simulation of vivado automatic memory module
module dist_mem_gen_1(
    input [9:0] a,
    input [31:0] d,
    input [9:0] dpra,
    input clk,
    input we,
    output [31:0] dpo
);
    // Memory array
    reg [31:0] mem [0:1023];
    
    // Write operation
    always @(posedge clk) begin
        if (we) begin
            mem[a] <= d;
            $display("Writing to memory address %d: %d at time: %t", a, d, $time);
        end
    end
    
    // Read operation
    assign dpo = mem[dpra];
endmodule

module memory_wrapper(a,d,dpra,clk,we,dpo);

input [9:0] a,dpra;
input clk,we;
output [31:0] dpo;
input [31:0] d; 
     
    dist_mem_gen_1 your_instance_name (
  .a(a),        // input wire [9 : 0] a
  .d(d),        // input wire [31 : 0] d
  .dpra(dpra),  // input wire [9 : 0] dpra
  .clk(clk),    // input wire clk
  .we(we),      // input wire we
  .dpo(dpo)    // output wire [31 : 0] dpo
);
endmodule

module data_memory(
    input wire clk,
    input wire memWrite,
    input wire memRead,
    input wire [31:0] address,
    input wire [31:0] write_data_memory,
    output wire [31:0] read_data_memory
);
    // Only use the 10 least significant bits of the address for memory addressing
    wire [9:0] addr = address[9:0];
    
    // Connect memWrite to write enable (we), but only when memWrite is active
    wire we = memWrite;
    
    // Connect read_data_memory to dpo, but only when memRead is active
    wire [31:0] dpo;
    assign read_data_memory = memRead ? dpo : 32'h00000000;
    
    // implement the inner representation in vivado
    memory_wrapper mem_wrapper (
        .a(addr),
        .d(write_data_memory),
        .dpra(addr),
        .clk(clk),
        .we(we),
        .dpo(dpo)
    );
    
endmodule
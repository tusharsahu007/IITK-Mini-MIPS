`timescale 1ns / 1ps
`include "control.v"
`include "alu.v"
`include "pc.v"
`include "register_file.v"
`include "alu_control.v"
`include "data_memory.v"


module cpu(
    input wire [32767:0] instruction_stream,
    input wire clk,
    input wire rst
);
    // Convert the instruction stream into a 2D array of instructions
    wire [31:0] instruction_memory[1023:0];
    generate
        for (genvar i = 0; i < 1024; i = i + 1) begin : gen_loop
            assign instruction_memory[i] = instruction_stream[i*32 +: 32];
        end
    endgenerate

    // PC wires
    wire [9:0] cur_addr;
    wire [9:0] next_addr;

    // Control wires
    wire regDst;
    wire regWrite;
    wire Branch;
    wire MemRead;
    wire MemtoReg;
    wire MemWrite;
    wire [4:0] ALUOp;
    wire ALUSrc;
    wire Jump;
    wire JumpReg;
    wire JumpLink;

    // Register file wires
    wire [31:0] write_data_reg;
    wire [31:0] read_data_reg_1;
    wire [31:0] read_data_reg_2;

    // ALU wires
    wire [31:0] alu_result;
    wire [5:0] alu_control;
    wire zero;
    wire [4:0] shamt = instruction_memory[cur_addr][10:6];
    wire [15:0] immediate = instruction_memory[cur_addr][15:0];
    
    // Data memory wires
    wire [31:0] memory_address = alu_result >> 2; // Convert byte address to word address
    wire [31:0] write_data_memory;
    wire [31:0] read_data_memory;

    // Jump wires
    wire [25:0] jump_target = instruction_memory[cur_addr][25:0];
    wire [9:0] jump_address = jump_target[11:2]; // We're using 10-bit addresses in instruction memory

    // Other wires
    wire [31:0] signextended_15_0 = {{16{instruction_memory[cur_addr][15]}}, instruction_memory[cur_addr][15:0]};
    wire [4:0] write_reg = regDst ? instruction_memory[cur_addr][15:11] : 
                           (JumpLink ? 5'd31 : instruction_memory[cur_addr][20:16]);

    // PC calculation logic
    wire branch_taken = Branch & zero;
    wire [9:0] branch_addr = cur_addr + 1 + signextended_15_0[11:2]; // PC+1+offset (doing >>2 effectively to get the word address)
    wire [9:0] jr_addr = read_data_reg_1[11:2]; // Address from register for JR
    wire [9:0] next_pc = Jump ? jump_address :
                         (JumpReg ? jr_addr :
                         (branch_taken ? branch_addr : cur_addr + 10'd1));

    // Write data for registers
    wire [31:0] pc_plus_1 = {20'd0, (cur_addr + 10'd1), 2'b00}; // (PC+1)<<2 for byte addressing in JAL
    wire [31:0] reg_write_data = JumpLink ? pc_plus_1 : 
                                (MemtoReg ? read_data_memory : alu_result);

    // assignments
    assign write_data_memory = read_data_reg_2;
    assign next_addr = next_pc;

    // Instantiate modules
    pc pc_inst(
        .clk(clk),
        .rst(rst),
        .pc_in(next_addr),
        .pc_out(cur_addr)
    );

    control control_inst(
        .opcode(instruction_memory[cur_addr][31:26]),
        .funct(instruction_memory[cur_addr][5:0]),
        .regDst(regDst),
        .regWrite(regWrite),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .MemWrite(MemWrite),
        .ALUOp(ALUOp),
        .ALUSrc(ALUSrc),
        .Jump(Jump),
        .JumpReg(JumpReg),
        .JumpLink(JumpLink)
    );

    register_file register_file_inst(
        .clk(clk),
        .rst(rst),
        .read_reg_1(instruction_memory[cur_addr][25:21]),
        .read_reg_2(instruction_memory[cur_addr][20:16]),
        .write_reg(write_reg),
        .write_data_reg(reg_write_data),
        .regWrite(regWrite | (JumpLink & Jump)), // Enable write for JAL
        .read_data_reg_1(read_data_reg_1),
        .read_data_reg_2(read_data_reg_2)
    );

    alu_control alu_control_inst(
        .ALUOp(ALUOp),
        .funct(instruction_memory[cur_addr][5:0]),
        .alu_control(alu_control)
    );

    
    alu alu_inst(
        .alu_control(alu_control),
        .a(read_data_reg_1),
        .b(ALUSrc == 1 ? signextended_15_0 : read_data_reg_2),
        .result(alu_result),
        .zero(zero),
        .shamt(shamt),
        .immediate(immediate),
        .clk(clk),
        .rst(rst)
    );


    data_memory data_memory_inst(
        .clk(clk),
        .memWrite(MemWrite),
        .memRead(MemRead),
        .address(memory_address),
        .write_data_memory(write_data_memory),
        .read_data_memory(read_data_memory)
    );
    
endmodule
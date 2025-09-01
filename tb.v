`timescale 1ns / 1ps
`include "cpu.v"

module tb();
    reg clk;
    reg rst;
    reg [32767:0] instruction_stream;
    
    cpu cpu_inst(
        .instruction_stream(instruction_stream),
        .clk(clk),
        .rst(rst)
    );

    initial begin
        clk = 0;
        rst = 1;
        instruction_stream = {32768{1'b0}}; // all zeros
        
        // Basic setup
        instruction_stream[31:0]   = 32'b001000_00000_00001_0000000000000101; // addi $1, $0, 5
        instruction_stream[63:32]  = 32'b001000_00000_00010_0000000000000010; // addi $2, $0, 2
        instruction_stream[95:64]  = 32'b001000_00000_00011_0000000000000111; // addi $3, $0, 7
        
        // Test branch equal (beq)
        instruction_stream[127:96] = 32'b000100_00001_00001_0000000000001000; // beq $1, $1, 8 (2*4)
        instruction_stream[159:128] = 32'b001000_00000_00100_0000000000001111; // addi $4, $0, 15 (skipped)
        instruction_stream[191:160] = 32'b001000_00000_00100_0000000000001010; // addi $4, $0, 10 (skipped)
        
        // Test branch not equal (bne)
        instruction_stream[223:192] = 32'b000101_00001_00010_0000000000001000; // bne $1, $2, 8 (2*4)
        instruction_stream[255:224] = 32'b001000_00000_00101_0000000000000001; // addi $5, $0, 1 (skipped)
        instruction_stream[287:256] = 32'b001000_00000_00101_0000000000000010; // addi $5, $0, 2 (skipped)
        
        // Test branch greater than (bgt)
        instruction_stream[319:288] = 32'b000110_00011_00001_0000000000001000; // bgt $3, $1, 8 (2*4)
        instruction_stream[351:320] = 32'b001000_00000_00110_0000000000000001; // addi $6, $0, 1 (skipped)
        instruction_stream[383:352] = 32'b001000_00000_00110_0000000000000011; // addi $6, $0, 3 (skipped)
        
        // Test jump
        instruction_stream[415:384] = 32'b000010_00000000000000000000110100; // j 52 (13*4)
        // skipped instructions...
        
        // Instruction 13 (address 416)
        instruction_stream[447:416] = 32'b001000_00000_00111_0000000000001101; // addi $7, $0, 13 (executed after jump)
        
        // Test jump and link (jal)
        instruction_stream[479:448] = 32'b000011_00000000000000000000111100; // jal 60 (15*4)
        
        // Instruction 15 (address 480)
        instruction_stream[511:480] = 32'b001000_00000_01000_0000000000001111; // addi $8, $0, 15 (executed after jal)
        
        // // Test jr (return from jal) // uncommenting this instruction will create a loop
        // instruction_stream[543:512] = 32'b000000_11111_00000_00000_00000_001000; // jr $ra

        // duplicate instruction added for dummy
        instruction_stream[575:544] = 32'b001000_00000_01001_0000000000000100; // addi $9, $0, 4 (memory address base)
        // Test load and store instructions
        // Set up registers for memory operations
        instruction_stream[575:544] = 32'b001000_00000_01001_0000000000000100; // addi $9, $0, 4 (memory address base)
        instruction_stream[607:576] = 32'b001000_00000_01010_0000000000101010; // addi $10, $0, 42 (test value to store)
        
        // Store word: sw $10, 0($9) - Store value 42 at address $9 + 0
        instruction_stream[639:608] = 32'b101011_01001_01010_0000000000000000;
        
        // Load word: lw $11, 0($9) - Load from address $9 + 0 into $11
        instruction_stream[671:640] = 32'b100011_01001_01011_0000000000000000;
        
        // Store word at different offset: sw $10, 4($9) - Store value 42 at address $9 + 4
        instruction_stream[703:672] = 32'b101011_01001_01010_0000000000000100;
        
        // Load word from different offset: lw $12, 4($9) - Load from address $9 + 4 into $12
        instruction_stream[735:704] = 32'b100011_01001_01100_0000000000000100;
        
        // Store different value
        instruction_stream[767:736] = 32'b001000_00000_01101_0000000000111111; // addi $13, $0, 63 (different test value)
        instruction_stream[799:768] = 32'b101011_01001_01101_0000000000001000; // sw $13, 8($9)
        instruction_stream[831:800] = 32'b100011_01001_01110_0000000000001000; // lw $14, 8($9)

        #10 
        rst = 0;
        #280 $finish; // Extended simulation time to accommodate additional instructions
    end

    always #5 clk = ~clk;
endmodule

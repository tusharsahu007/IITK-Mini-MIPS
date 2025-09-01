module control(
    input wire [5:0] opcode,
    input wire [5:0] funct,

    output reg regDst,
    output reg regWrite,
    output reg Branch,
    output reg MemRead,
    output reg MemtoReg,
    output reg MemWrite,
    output reg [4:0] ALUOp,
    output reg ALUSrc,
    output reg Jump,
    output reg JumpReg,
    output reg JumpLink
); 
// Tentative control signals, need to be adjusted based on the mips instruction set architecture
    always @(*) begin
        // Default values
        regDst = 0;
        regWrite = 0;
        Branch = 0;
        MemRead = 0;
        MemtoReg = 0;
        MemWrite = 0;
        ALUOp = 5'b01111; // No operation
        ALUSrc = 0;
        Jump = 0;
        JumpReg = 0;
        JumpLink = 0;
        
        case (opcode)
            6'b000000: begin // R-type instructions
                regDst = 1;
                regWrite = (funct != 6'b001000); // Don't write for JR. Important Fix.
                Branch = 0;
                MemRead = 0;
                MemtoReg = 0;
                MemWrite = 0;
                ALUOp = 5'b00010; // ALU operation
                ALUSrc = 0; // Register source
                // JR handled in CPU based on funct field
                Jump = 0;
                JumpReg = (funct == 6'b001000); // Set JumpReg for JR
                JumpLink = 0;
            end
            6'b100011: begin // lw instruction
                regDst = 0;
                regWrite = 1;
                Branch = 0;
                MemRead = 1;
                MemtoReg = 1; // Memory to register
                MemWrite = 0;
                ALUOp = 5'b00000; // Load operation
                ALUSrc = 1; // Immediate source
            end
            // Conditional Branch Instructions
            6'b000100: begin // beq instruction
                regDst = 0;
                regWrite = 0;
                Branch = 1;
                MemRead = 0;
                MemtoReg = 0;
                MemWrite = 0;
                ALUOp = 5'b01010; // Equal comparison
                ALUSrc = 0;
            end
            6'b000101: begin // bne instruction
                regDst = 0;
                regWrite = 0;
                Branch = 1;
                MemRead = 0;
                MemtoReg = 0;
                MemWrite = 0;
                ALUOp = 5'b01011; // Not equal comparison
                ALUSrc = 0;
            end
            6'b000110: begin // bgt instruction (custom)
                regDst = 0;
                regWrite = 0;
                Branch = 1;
                MemRead = 0;
                MemtoReg = 0;
                MemWrite = 0;
                ALUOp = 5'b01100; // Greater than
                ALUSrc = 0;
            end
            6'b000111: begin // bgte instruction (custom)
                regDst = 0;
                regWrite = 0;
                Branch = 1;
                MemRead = 0;
                MemtoReg = 0;
                MemWrite = 0;
                ALUOp = 5'b01101; // Greater than or equal
                ALUSrc = 0;
            end
            6'b001001: begin // ble instruction (custom)
                regDst = 0;
                regWrite = 0;
                Branch = 1;
                MemRead = 0;
                MemtoReg = 0;
                MemWrite = 0;
                ALUOp = 5'b01110; // Less than
                ALUSrc = 0;
            end
            6'b001011: begin // bleq instruction (custom)
                regDst = 0;
                regWrite = 0;
                Branch = 1;
                MemRead = 0;
                MemtoReg = 0;
                MemWrite = 0;
                ALUOp = 5'b01111; // Less than or equal
                ALUSrc = 0;
            end
            6'b001111: begin // bleu instruction (custom - unsigned)
                regDst = 0;
                regWrite = 0;
                Branch = 1;
                MemRead = 0;
                MemtoReg = 0;
                MemWrite = 0;
                ALUOp = 5'b10000; // Less than or equal unsigned
                ALUSrc = 0;
            end
            6'b010000: begin // bgtu instruction (custom - unsigned)
                regDst = 0;
                regWrite = 0;
                Branch = 1;
                MemRead = 0;
                MemtoReg = 0;
                MemWrite = 0;
                ALUOp = 5'b10001; // Greater than unsigned
                ALUSrc = 0;
            end
            
            // Unconditional Jump Instructions
            6'b000010: begin // j instruction
                regDst = 0;
                regWrite = 0;
                Branch = 0;
                MemRead = 0;
                MemtoReg = 0;
                MemWrite = 0;
                Jump = 1;
                JumpReg = 0;
                JumpLink = 0;
            end
            6'b000011: begin // jal instruction
                regDst = 0;
                regWrite = 1; // Write to $ra (register 31)
                Branch = 0;
                MemRead = 0;
                MemtoReg = 0;
                MemWrite = 0;
                Jump = 1;
                JumpReg = 0;
                JumpLink = 1;
            end
            
            // Other instructions (already implemented)
            6'b001000: begin // addi instruction
                regDst = 0;
                regWrite = 1;
                Branch = 0;
                MemRead = 0;
                MemtoReg = 0;
                MemWrite = 0;
                ALUOp = 5'b00011; // ALU operation
                ALUSrc = 1; // Immediate source
            end
            //andi
            6'b001100: begin // andi instruction
                regDst = 0;
                regWrite = 1;
                Branch = 0;
                MemRead = 0;
                MemtoReg = 0;
                MemWrite = 0;
                ALUOp = 5'b00100; // ALU operation
                ALUSrc = 1; // Immediate source
            end
            //ori
            6'b001101: begin // ori instruction
                regDst = 0;
                regWrite = 1;
                Branch = 0;
                MemRead = 0;
                MemtoReg = 0;
                MemWrite = 0;
                ALUOp = 5'b00101; // ALU operation
                ALUSrc = 1; // Immediate source
            end
            // xori
            6'b001110: begin // xori instruction
                regDst = 0;
                regWrite = 1;
                Branch = 0;
                MemRead = 0;
                MemtoReg = 0;
                MemWrite = 0;
                ALUOp = 5'b00110; // ALU operation
                ALUSrc = 1; // Immediate source
            end
            //slti
            6'b001010: begin // slti instruction
                regDst = 0;
                regWrite = 1;
                Branch = 0;
                MemRead = 0;
                MemtoReg = 0;
                MemWrite = 0;
                ALUOp = 5'b00111; // ALU operation
                ALUSrc = 1; // Immediate source
            end
            // seq
            6'b011000: begin // seq instruction
                regDst = 0;
                regWrite = 1;
                Branch = 0;
                MemRead = 0;
                MemtoReg = 0;
                MemWrite = 0;
                ALUOp = 5'b01001; // ALU operation
                ALUSrc = 1; // Immediate source
            end
            6'b101011: begin // sw instruction
                regDst = 0;    // Don't care (not writing to register)
                regWrite = 0;  // Not writing to register
                Branch = 0;
                MemRead = 0;
                MemtoReg = 0;  // Don't care (not writing to register)
                MemWrite = 1;  // Write to memory
                ALUOp = 5'b00000; // Same as lw - ADD operation
                ALUSrc = 1;    // Use immediate for address calculation
                Jump = 0;
                JumpReg = 0;
                JumpLink = 0;
            end
        endcase
    end
endmodule
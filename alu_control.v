module alu_control(
    input wire [5:0] funct,
    input wire [4:0] ALUOp,
    output reg [5:0] alu_control
);
    // ALU control signals
    always @(*) begin
        case(ALUOp)
            5'b00000: alu_control = 6'b100000; // ADD for lw/sw address calculation
            // 5'b00001: alu_control = 6'b100010; 
            5'b00010: begin // R type instruction
                case (funct)
                    6'b100000: alu_control = 6'b100000; // ADD
                    6'b100001: alu_control = 6'b100001; // ADDU
                    6'b100010: alu_control = 6'b100010; // SUB
                    6'b100011: alu_control = 6'b100011; // SUBU
                    6'b011000: alu_control = 6'b011000; // MUL / MULT
                    6'b011001: alu_control = 6'b011001; // MULU / MULTU
                    6'b011100: alu_control = 6'b011100; // MADD
                    6'b011101: alu_control = 6'b011101; // MADDU
                    6'b100100: alu_control = 6'b100100; // AND
                    6'b100101: alu_control = 6'b100101; // OR
                    6'b000000: alu_control = 6'b000000; // SLL
                    6'b000010: alu_control = 6'b000010; // SRL
                    6'b000011: alu_control = 6'b000011; // SRA
                    6'b100110: alu_control = 6'b100110; // XOR
                    6'b101000: alu_control = 6'b101000; // NOT (custom)
                    6'b100111: alu_control = 6'b100111; // NOR
                    6'b101010: alu_control = 6'b101010; // SLT
                    6'b101011: alu_control = 6'b101011; // SLTU
                    6'b010000: alu_control = 6'b010000; // MFHI
                    6'b010010: alu_control = 6'b010010; // MFLO
                    6'b001000: alu_control = 6'b001000; // JR
                    default:   alu_control = 6'b111111; // Invalid operation
                endcase
            end
            5'b00011: alu_control = 6'b100000; // ADDI
            5'b00100: alu_control = 6'b100100; // ANDI
            5'b00101: alu_control = 6'b100101; // ORI
            5'b00110: alu_control = 6'b100110; // XORI
            5'b00111: alu_control = 6'b101010; // SLTI
            5'b01000: alu_control = 6'b101011; // SLTIU
            5'b01001: alu_control = 6'b101100; // SEQ (Set if equal)
            5'b01010: alu_control = 6'b101100; // BEQ (reuse SEQ)
            5'b01011: alu_control = 6'b101101; // BNE
            5'b01100: alu_control = 6'b101110; // BGT
            5'b01101: alu_control = 6'b101111; // BGTE
            5'b01110: alu_control = 6'b110000; // BLE
            5'b01111: alu_control = 6'b110001; // BLEQ
            5'b10000: alu_control = 6'b110010; // BLEU (unsigned)
            5'b10001: alu_control = 6'b110011; // BGTU (unsigned)
            default: alu_control = 6'b111111; // Invalid operation
        endcase
    end
endmodule
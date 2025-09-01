module alu(
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [5:0] alu_control,
    input wire [4:0] shamt,
    input wire [15:0] immediate,
    input wire clk,
    input wire rst,

    output reg [31:0] result,
    output reg zero
);
    reg [31:0] Hi, Lo;
    
    wire [31:0] signExtImmediate = {{16{immediate[15]}}, immediate};
    wire [31:0] zeroExtImmediate = {16'b0, immediate};

        always @(posedge clk or posedge rst) begin
        if (rst) begin
            Hi <= 32'b0;
            Lo <= 32'b0;
        end else begin
            case (alu_control)
                6'b011000: begin // MULT
                    {Hi, Lo} <= $signed(a) * $signed(b);
                end
                6'b011001: begin // MULTU
                    {Hi, Lo} <= a * b;
                end
                6'b011100: begin // MADD
                    {Hi, Lo} <= {Hi, Lo} + ($signed(a) * $signed(b));
                end
                6'b011101: begin // MADDU
                    {Hi, Lo} <= {Hi, Lo} + (a * b);
                end
                default:   ; // No change to Hi/Lo
            endcase
        end
    end

    always @(*) begin
        case (alu_control)
            6'b100000: result = $signed(a) + $signed(b); // ADD
            6'b100001: result = a + b;                   // ADDU
            6'b100010: result = $signed(a) - $signed(b); // SUB
            6'b100011: result = a - b;                   // SUBU
            6'b100100: result = a & b;              // AND
            6'b100101: result = a | b;              // OR
            6'b000000: result = b << shamt;         // SLL identical to SLA
            6'b000010: result = b >> shamt;         // SRL
            6'b000011: result = $signed(b) >>> shamt; // SRA
            6'b100110: result = a ^ b;              // XOR
            6'b101000: result = ~b;                 // NOT (custom)
            6'b100111: result = ~(a | b);           // NOR
            6'b101010: result = ($signed(a) < $signed(b)) ? 1 : 0; // SLT
            6'b101011: result = (a < b) ? 1 : 0;     // SLTU
            6'b010000: result = Hi;                 // MFHI
            6'b010010: result = Lo;                 // MFLO
            6'b101100: result = ($signed(a) == $signed(b)) ? 1 : 0; // SEQ (set if equal)
            6'b101101: result = ($signed(a) != $signed(b)) ? 1 : 0; // SNE (set if not equal)
            6'b101110: result = ($signed(a) > $signed(b)) ? 1 : 0;  // SGT (set if greater than)
            6'b101111: result = ($signed(a) >= $signed(b)) ? 1 : 0; // SGTE (set if greater than or equal)
            6'b110000: result = ($signed(a) < $signed(b)) ? 1 : 0;  // SLT (set if less than)
            6'b110001: result = ($signed(a) <= $signed(b)) ? 1 : 0; // SLEQ (set if less than or equal)
            6'b110010: result = (a <= b) ? 1 : 0;                   // SLEU (set if less than or equal unsigned)
            6'b110011: result = (a > b) ? 1 : 0;                    // SGTU (set if greater than unsigned)
            6'b001000: result = a;                                  // JR (pass-through for register jump)
            
            default:   result = 32'b0;
        endcase
        
        // For branch instructions, zero=1 means the branch is taken
        // For comparison operations (101100-110011), result=1 means condition is true
        if (alu_control >= 6'b101100 && alu_control <= 6'b110011)
            zero = (result == 1);
        else
            zero = (result == 0);
    end

endmodule
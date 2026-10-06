module control_unit (
    input  logic [6:0] opcode,

    output logic       RegWrite,
    output logic       ALUSrc,
    output logic       MemWrite,
    output logic       MemRead,
    output logic [1:0] ResultSrc,
    output logic       Branch,
    output logic       Jump,
    output logic [2:0] ImmType,
    output logic [1:0] ALUOp
);

    always_comb begin

        // Default values
        RegWrite  = 1'b0;
        ALUSrc    = 1'b0;
        MemWrite  = 1'b0;
        MemRead   = 1'b0;
        ResultSrc = 2'b00;
        Branch    = 1'b0;
        Jump      = 1'b0;
        ImmType   = 3'b000;
        ALUOp     = 2'b00;

        case (opcode)

            // R-type
            // Examples: ADD, SUB, AND, OR, XOR
            7'b0110011: begin
                RegWrite  = 1'b1;
                ALUSrc    = 1'b0;
                ResultSrc = 2'b00;
                ALUOp     = 2'b10;
            end

            // I-type arithmetic
            // Example: ADDI
            7'b0010011: begin
                RegWrite  = 1'b1;
                ALUSrc    = 1'b1;
                ResultSrc = 2'b00;
                ImmType   = 3'b000;
                ALUOp     = 2'b10;
            end

            // Load
            // Example: LW
            7'b0000011: begin
                RegWrite  = 1'b1;
                ALUSrc    = 1'b1;
                MemRead   = 1'b1;
                ResultSrc = 2'b01;
                ImmType   = 3'b000;
                ALUOp     = 2'b00;
            end

            // Store
            // Example: SW
            7'b0100011: begin
                RegWrite = 1'b0;
                ALUSrc   = 1'b1;
                MemWrite = 1'b1;
                ImmType  = 3'b001;
                ALUOp    = 2'b00;
            end

            // Branch
            // Example: BEQ
            7'b1100011: begin
                RegWrite = 1'b0;
                ALUSrc   = 1'b0;
                Branch   = 1'b1;
                ImmType  = 3'b010;
                ALUOp    = 2'b01;
            end

            // LUI
            7'b0110111: begin
                RegWrite  = 1'b1;
                ResultSrc = 2'b11;
                ImmType   = 3'b011;
            end

            // AUIPC
            7'b0010111: begin
                RegWrite  = 1'b1;
                ALUSrc    = 1'b1;
                ResultSrc = 2'b00;
                ImmType   = 3'b011;
                ALUOp     = 2'b00;
            end

            // JAL
            7'b1101111: begin
                RegWrite  = 1'b1;
                Jump      = 1'b1;
                ResultSrc = 2'b10;
                ImmType   = 3'b100;
            end

            // JALR
            7'b1100111: begin
                RegWrite  = 1'b1;
                ALUSrc    = 1'b1;
                Jump      = 1'b1;
                ResultSrc = 2'b10;
                ImmType   = 3'b000;
                ALUOp     = 2'b00;
            end

            default: begin
                // Keep default control signals
            end

        endcase
    end

endmodule
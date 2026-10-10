
module alu_control (
    input  logic [1:0] ALUOp,
    input  logic [2:0] funct3,
    input  logic       funct7_bit30,
    input  logic       is_r_type,

    output logic [2:0] ALUControl
);

    always_comb begin

        ALUControl = 3'b000; // Default: ADD

        case (ALUOp)

            // Load, store, address calculation
            2'b00: ALUControl = 3'b000;

            // Branch comparison
            2'b01: ALUControl = 3'b001;

            // R-type and I-type arithmetic
            2'b10: begin

                case (funct3)

                    3'b000: begin
                        if (is_r_type && funct7_bit30)
                            ALUControl = 3'b001; // SUB
                        else
                            ALUControl = 3'b000; // ADD / ADDI
                    end

                    3'b111: ALUControl = 3'b010; // AND
                    3'b110: ALUControl = 3'b011; // OR
                    3'b100: ALUControl = 3'b100; // XOR

                    default: ALUControl = 3'b000;

                endcase

            end

            default: ALUControl = 3'b000;

        endcase

    end

endmodule

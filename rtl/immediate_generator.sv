module immediate_generator (
    input  logic [31:0] instruction,
    input  logic [2:0]  ImmType,
    output logic [31:0] immediate
);

    always_comb begin
        case (ImmType)

            // I-type
            // imm[11:0] = instruction[31:20]
            3'b000:
                immediate = {{20{instruction[31]}},
                             instruction[31:20]};

            // S-type
            // imm[11:5] = instruction[31:25]
            // imm[4:0]  = instruction[11:7]
            3'b001:
                immediate = {{20{instruction[31]}},
                             instruction[31:25],
                             instruction[11:7]};

            // B-type
            // imm[12]   = instruction[31]
            // imm[11]   = instruction[7]
            // imm[10:5] = instruction[30:25]
            // imm[4:1]  = instruction[11:8]
            // imm[0]    = 0
            3'b010:
                immediate = {{19{instruction[31]}},
                             instruction[31],
                             instruction[7],
                             instruction[30:25],
                             instruction[11:8],
                             1'b0};

            // U-type
            // imm[31:12] = instruction[31:12]
            // imm[11:0]  = 0
            3'b011:
                immediate = {instruction[31:12],
                             12'b0};

            // J-type
            // imm[20]    = instruction[31]
            // imm[19:12] = instruction[19:12]
            // imm[11]    = instruction[20]
            // imm[10:1]  = instruction[30:21]
            // imm[0]     = 0
            3'b100:
                immediate = {{11{instruction[31]}},
                             instruction[31],
                             instruction[19:12],
                             instruction[20],
                             instruction[30:21],
                             1'b0};

            default:
                immediate = 32'b0;

        endcase
    end

endmodule
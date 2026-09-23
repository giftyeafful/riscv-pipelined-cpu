module immediate_generator (
    input  logic [31:0] instruction,
    input  logic [2:0]  ImmType,

    output logic [31:0] immediate
);

    always_comb begin

        case (ImmType)

            // I-type
            3'b000:
                immediate = {{20{instruction[31]}}, instruction[31:20]};

            default:
                immediate = 32'b0;

        endcase

    end

endmodule
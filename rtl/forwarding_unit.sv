
module forwarding_unit (
    input logic [4:0] Rs1E,
    input logic [4:0] Rs2E,

    input logic [4:0] RdM,
    input logic [4:0] RdW,

    input logic RegWriteM,
    input logic RegWriteW,

    // EX/MEM result selection:
    // 01 means a load, whose data is not
    // available for EX/MEM ALU forwarding.
    input logic [1:0] ResultSrcM,

    output logic [1:0] ForwardA,
    output logic [1:0] ForwardB
);

    always_comb begin
        ForwardA = 2'b00;
        ForwardB = 2'b00;

        // Forward operand A from MEM/WB
        if (RegWriteW && (RdW != 5'd0)
            && (RdW == Rs1E))
            ForwardA = 2'b01;

        // EX/MEM takes priority because it
        // contains the newer instruction.
        if (RegWriteM && (RdM != 5'd0)
            && (RdM == Rs1E)
            && (ResultSrcM != 2'b01))
            ForwardA = 2'b10;

        // Forward operand B from MEM/WB
        if (RegWriteW && (RdW != 5'd0)
            && (RdW == Rs2E))
            ForwardB = 2'b01;

        // EX/MEM takes priority
        if (RegWriteM && (RdM != 5'd0)
            && (RdM == Rs2E)
            && (ResultSrcM != 2'b01))
            ForwardB = 2'b10;
    end

endmodule

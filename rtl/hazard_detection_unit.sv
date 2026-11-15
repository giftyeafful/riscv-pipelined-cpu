
module hazard_detection_unit (
    // Source registers in Decode stage
    input logic [4:0] Rs1D,
    input logic [4:0] Rs2D,

    // Whether Decode instruction uses each source
    input logic UsesRs1D,
    input logic UsesRs2D,

    // Destination register in Execute stage
    input logic [4:0] RdE,

    // Execute-stage instruction is a load
    input logic MemReadE,

    // A taken branch or jump redirects the PC
    input logic PCSrcE,

    // Pipeline controls
    output logic StallF,
    output logic StallD,
    output logic FlushD,
    output logic FlushE
);

    logic LoadUseHazard;

    always_comb begin

        LoadUseHazard =
            MemReadE &&
            (RdE != 5'd0) &&
            (
                (UsesRs1D && (Rs1D == RdE)) ||
                (UsesRs2D && (Rs2D == RdE))
            );

        // Hold PC and IF/ID during a load-use hazard.
        // A redirect takes priority over a stall.
        StallF = LoadUseHazard && !PCSrcE;
        StallD = LoadUseHazard && !PCSrcE;

        // Discard the instruction fetched on
        // the wrong path after a redirect.
        FlushD = PCSrcE;

        // Insert a bubble into Execute for
        // either a load-use hazard or redirect.
        FlushE = LoadUseHazard || PCSrcE;

    end

endmodule

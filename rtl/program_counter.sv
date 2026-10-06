module program_counter (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] NextPC,

    output logic [31:0] PC
);

    always_ff @(posedge clk) begin

        if (reset)
            PC <= 32'b0;
        else
            PC <= NextPC;

    end

endmodule
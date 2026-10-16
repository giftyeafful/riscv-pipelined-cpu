
module if_id_register (
    input  logic        clk,
    input  logic        reset,
    input  logic        stall,
    input  logic        flush,

    input  logic [31:0] PC_in,
    input  logic [31:0] Instruction_in,

    output logic [31:0] PC_out,
    output logic [31:0] Instruction_out
);

    // RISC-V NOP: addi x0, x0, 0
    localparam logic [31:0] NOP = 32'h00000013;

    always_ff @(posedge clk) begin

        if (reset) begin
            PC_out          <= 32'd0;
            Instruction_out <= NOP;
        end

        else if (flush) begin
            PC_out          <= 32'd0;
            Instruction_out <= NOP;
        end

        else if (!stall) begin
            PC_out          <= PC_in;
            Instruction_out <= Instruction_in;
        end

    end

endmodule

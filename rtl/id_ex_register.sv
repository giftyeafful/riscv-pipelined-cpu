
module id_ex_register (
    input logic clk,
    input logic reset,
    input logic flush,

    // Data from Decode stage
    input logic [31:0] PC_in,
    input logic [31:0] RD1_in,
    input logic [31:0] RD2_in,
    input logic [31:0] ImmExt_in,

    // Register addresses
    input logic [4:0] Rs1_in,
    input logic [4:0] Rs2_in,
    input logic [4:0] Rd_in,

    // ALU information
    input logic [2:0] ALUControl_in,
    input logic ALUSrc_in,

    // Control signals
    input logic RegWrite_in,
    input logic MemWrite_in,
    input logic MemRead_in,
    input logic [1:0] ResultSrc_in,
    input logic Branch_in,
    input logic Jump_in,

    // Outputs to Execute stage
    output logic [31:0] PC_out,
    output logic [31:0] RD1_out,
    output logic [31:0] RD2_out,
    output logic [31:0] ImmExt_out,

    output logic [4:0] Rs1_out,
    output logic [4:0] Rs2_out,
    output logic [4:0] Rd_out,

    output logic [2:0] ALUControl_out,
    output logic ALUSrc_out,

    output logic RegWrite_out,
    output logic MemWrite_out,
    output logic MemRead_out,
    output logic [1:0] ResultSrc_out,
    output logic Branch_out,
    output logic Jump_out
);

    always_ff @(posedge clk) begin

        if (reset || flush) begin
            PC_out <= 32'd0;
            RD1_out <= 32'd0;
            RD2_out <= 32'd0;
            ImmExt_out <= 32'd0;

            Rs1_out <= 5'd0;
            Rs2_out <= 5'd0;
            Rd_out <= 5'd0;

            ALUControl_out <= 3'd0;
            ALUSrc_out <= 1'b0;

            RegWrite_out <= 1'b0;
            MemWrite_out <= 1'b0;
            MemRead_out <= 1'b0;
            ResultSrc_out <= 2'b00;
            Branch_out <= 1'b0;
            Jump_out <= 1'b0;
        end

        else begin
            PC_out <= PC_in;
            RD1_out <= RD1_in;
            RD2_out <= RD2_in;
            ImmExt_out <= ImmExt_in;

            Rs1_out <= Rs1_in;
            Rs2_out <= Rs2_in;
            Rd_out <= Rd_in;

            ALUControl_out <= ALUControl_in;
            ALUSrc_out <= ALUSrc_in;

            RegWrite_out <= RegWrite_in;
            MemWrite_out <= MemWrite_in;
            MemRead_out <= MemRead_in;
            ResultSrc_out <= ResultSrc_in;
            Branch_out <= Branch_in;
            Jump_out <= Jump_in;
        end

    end

endmodule

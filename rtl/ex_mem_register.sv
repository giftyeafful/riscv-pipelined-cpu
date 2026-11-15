
module ex_mem_register (
    input logic clk,
    input logic reset,
    input logic flush,

    // Data from Execute stage
    input logic [31:0] ALUResult_in,
    input logic [31:0] WriteData_in,
    input logic [31:0] PCPlus4_in,

    // Destination register
    input logic [4:0] Rd_in,

    // Control signals
    input logic RegWrite_in,
    input logic MemWrite_in,
    input logic MemRead_in,
    input logic [1:0] ResultSrc_in,

    // Outputs to Memory stage
    output logic [31:0] ALUResult_out,
    output logic [31:0] WriteData_out,
    output logic [31:0] PCPlus4_out,

    output logic [4:0] Rd_out,

    output logic RegWrite_out,
    output logic MemWrite_out,
    output logic MemRead_out,
    output logic [1:0] ResultSrc_out
);

    always_ff @(posedge clk) begin

        if (reset || flush) begin
            ALUResult_out <= 32'd0;
            WriteData_out <= 32'd0;
            PCPlus4_out <= 32'd0;

            Rd_out <= 5'd0;

            RegWrite_out <= 1'b0;
            MemWrite_out <= 1'b0;
            MemRead_out <= 1'b0;
            ResultSrc_out <= 2'b00;
        end

        else begin
            ALUResult_out <= ALUResult_in;
            WriteData_out <= WriteData_in;
            PCPlus4_out <= PCPlus4_in;

            Rd_out <= Rd_in;

            RegWrite_out <= RegWrite_in;
            MemWrite_out <= MemWrite_in;
            MemRead_out <= MemRead_in;
            ResultSrc_out <= ResultSrc_in;
        end

    end

endmodule


module mem_wb_register (
    input logic clk,
    input logic reset,
    input logic flush,

    // Data from Memory stage
    input logic [31:0] ALUResult_in,
    input logic [31:0] ReadData_in,
    input logic [31:0] PCPlus4_in,

    // Destination register
    input logic [4:0] Rd_in,

    // Write-back control signals
    input logic RegWrite_in,
    input logic [1:0] ResultSrc_in,

    // Outputs to Write-Back stage
    output logic [31:0] ALUResult_out,
    output logic [31:0] ReadData_out,
    output logic [31:0] PCPlus4_out,

    output logic [4:0] Rd_out,

    output logic RegWrite_out,
    output logic [1:0] ResultSrc_out
);

    always_ff @(posedge clk) begin

        if (reset || flush) begin
            ALUResult_out <= 32'd0;
            ReadData_out <= 32'd0;
            PCPlus4_out <= 32'd0;

            Rd_out <= 5'd0;

            RegWrite_out <= 1'b0;
            ResultSrc_out <= 2'b00;
        end

        else begin
            ALUResult_out <= ALUResult_in;
            ReadData_out <= ReadData_in;
            PCPlus4_out <= PCPlus4_in;

            Rd_out <= Rd_in;

            RegWrite_out <= RegWrite_in;
            ResultSrc_out <= ResultSrc_in;
        end

    end

endmodule

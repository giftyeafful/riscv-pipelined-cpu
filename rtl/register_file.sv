module register_file (
    input logic         clk,

    input logic [4:0]   ReadAddr1,
    input logic [4:0]   ReadAddr2,
    output logic [31:0] ReadData1,
    output logic [31:0] ReadData2,

    input logic [4:0]   WriteAddr,
    input logic [31:0]  WriteData,
    input logic         RegWrite
);

    logic [31:0] registers [0:31];

    assign ReadData1 = (ReadAddr1 == 5'd0) ? 32'd0 : registers[ReadAddr1];

    assign ReadData2 = (ReadAddr2 == 5'd0) ? 32'd0 : registers[ReadAddr2];

    always_ff @(posedge clk) begin
        if (RegWrite && WriteAddr != 5'd0)
            registers[WriteAddr] <= WriteData;
    end

endmodule
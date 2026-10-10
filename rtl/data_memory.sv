
module data_memory (
    input  logic        clk,
    input  logic        MemWrite,
    input  logic        MemRead,
    input  logic [31:0] address,
    input  logic [31:0] WriteData,
    output logic [31:0] ReadData
);

    logic [31:0] memory [0:255];

    // Write data on the rising clock edge
    always_ff @(posedge clk) begin
        if (MemWrite && address < 32'd1024)
            memory[address[9:2]] <= WriteData;
    end

    // Read data combinationally
    always_comb begin
        if (MemRead && address < 32'd1024)
            ReadData = memory[address[9:2]];
        else
            ReadData = 32'b0;
    end

endmodule

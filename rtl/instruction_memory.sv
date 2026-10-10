
module instruction_memory (
    input  logic [31:0] address,
    output logic [31:0] instruction
);

    // 256 words, each 32 bits wide
    logic [31:0] memory [0:255];

    // Load machine-code instructions from a file
    initial begin
        $readmemh("programs/test_program.hex", memory);
    end

    // Read instruction using word-aligned address
    always_comb begin
        if (address < 32'd1024)
            instruction = memory[address[9:2]];
        else
            instruction = 32'h00000013; // NOP
    end

endmodule

module immediate_generator_tb;

    logic [31:0] instruction;
    logic [2:0]  ImmType;
    logic [31:0] immediate;

    immediate_generator dut (
        .instruction(instruction),
        .ImmType(ImmType),
        .immediate(immediate)
    );

    initial begin

        // Test 1: Positive immediate
        // 12-bit immediate = 10
        instruction = 32'b000000001010_00000_000_00000_0010011;
        ImmType = 3'b000;

        #1;

        $display("Positive I-type: immediate = %0d", $signed(immediate));

        if (immediate != 32'd10)
            $display("ERROR: Positive immediate failed!");
        else
            $display("Positive immediate PASSED!");


        // Test 2: Negative immediate
        // 12-bit immediate = -1
        instruction = 32'b111111111111_00000_000_00000_0010011;
        ImmType = 3'b000;

        #1;

        $display("Negative I-type: immediate = %0d", $signed(immediate));

        if (immediate != 32'hFFFFFFFF)
            $display("ERROR: Negative immediate failed!");
        else
            $display("Negative immediate PASSED!");


        $finish;

    end

endmodule
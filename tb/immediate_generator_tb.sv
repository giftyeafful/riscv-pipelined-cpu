module immediate_generator_tb;

    logic [31:0] instruction;
    logic [2:0]  ImmType;
    logic [31:0] immediate;

    // Device Under Test
    immediate_generator dut (
        .instruction(instruction),
        .ImmType(ImmType),
        .immediate(immediate)
    );

    initial begin

        
        // Test 1: Positive I-type immediate = 10
        instruction = 32'b000000001010_00000_000_00000_0010011;
        ImmType = 3'b000;

        #1;

        $display("Positive I-type: immediate = %0d", $signed(immediate));

        if (immediate != 32'd10)
            $display("ERROR: Positive I-type immediate failed!");
        else
            $display("Positive I-type immediate PASSED!");


        // Test 2: Negative I-type immediate = -1
        instruction = 32'b111111111111_00000_000_00000_0010011;
        ImmType = 3'b000;

        #1;

        $display("Negative I-type: immediate = %0d", $signed(immediate));

        if (immediate != 32'hFFFFFFFF)
            $display("ERROR: Negative I-type immediate failed!");
        else
            $display("Negative I-type immediate PASSED!");


        // Test 3: Positive S-type immediate = 20
        // 20 = 000000010100
        // imm[11:5] = 0000000
        // imm[4:0]  = 10100
        instruction = 32'b0000000_00000_00110_010_10100_0100011;
        ImmType = 3'b001;

        #1;

        $display("Positive S-type: immediate = %0d", $signed(immediate));

        if (immediate != 32'd20)
            $display("ERROR: Positive S-type immediate failed!");
        else
            $display("Positive S-type immediate PASSED!");


        // Test 4: Positive B-type branch offset = 8
        instruction = 32'b0000000_00000_00000_000_0100_0_1100011;
        ImmType = 3'b010;

        #1;

        $display("Positive B-type: immediate = %0d", $signed(immediate));

        if (immediate != 32'd8)
            $display("ERROR: Positive B-type immediate failed!");
        else
            $display("Positive B-type immediate PASSED!");


        // Test 5: U-type immediate = 4096
        // Upper immediate = 1
        // 1 << 12 = 4096
        instruction = 32'b00000000000000000001_00000_0110111;
        ImmType = 3'b011;

        #1;

        $display("U-type: immediate = %0d", $signed(immediate));

        if (immediate != 32'd4096)
            $display("ERROR: U-type immediate failed!");
        else
            $display("U-type immediate PASSED!");


        // Test 6: Positive J-type jump offset = 8
        // imm[20]    = 0
        // imm[10:1]  = 0000000100
        // imm[11]    = 0
        // imm[19:12] = 00000000
        // JAL instruction layout:
        // imm[20] | imm[10:1] | imm[11] |
        // imm[19:12] | rd | opcode
        instruction = 32'b0_0000000100_0_00000000_00000_1101111;
        ImmType = 3'b100;

        #1;

        $display("Positive J-type: immediate = %0d", $signed(immediate));

        if (immediate != 32'd8)
            $display("ERROR: Positive J-type immediate failed!");
        else
            $display("Positive J-type immediate PASSED!");


        $finish;

    end

endmodule
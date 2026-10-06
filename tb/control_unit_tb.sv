module control_unit_tb;

    logic [6:0] opcode;

    logic       RegWrite;
    logic       ALUSrc;
    logic       MemWrite;
    logic       MemRead;
    logic [1:0] ResultSrc;
    logic       Branch;
    logic       Jump;
    logic [2:0] ImmType;
    logic [1:0] ALUOp;

    control_unit dut (
        .opcode(opcode),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .ResultSrc(ResultSrc),
        .Branch(Branch),
        .Jump(Jump),
        .ImmType(ImmType),
        .ALUOp(ALUOp)
    );

    initial begin

        // Test 1: R-type
        opcode = 7'b0110011;
        #1;

        $display("R-type: RegWrite=%b ALUSrc=%b ALUOp=%b",
                 RegWrite, ALUSrc, ALUOp);

        if (RegWrite == 1'b1 &&
            ALUSrc   == 1'b0 &&
            MemWrite == 1'b0 &&
            ALUOp    == 2'b10)
            $display("R-type PASSED!");
        else
            $display("ERROR: R-type FAILED!");


        // Test 2: I-type arithmetic
        opcode = 7'b0010011;
        #1;

        $display("I-type: RegWrite=%b ALUSrc=%b ImmType=%b",
                 RegWrite, ALUSrc, ImmType);

        if (RegWrite == 1'b1 &&
            ALUSrc   == 1'b1 &&
            ImmType  == 3'b000)
            $display("I-type PASSED!");
        else
            $display("ERROR: I-type FAILED!");


        // Test 3: Load (LW)
        opcode = 7'b0000011;
        #1;

        $display("LW: RegWrite=%b ALUSrc=%b MemRead=%b ResultSrc=%b",
                 RegWrite, ALUSrc, MemRead, ResultSrc);

        if (RegWrite  == 1'b1 &&
            ALUSrc    == 1'b1 &&
            MemRead   == 1'b1 &&
            ResultSrc == 2'b01)
            $display("LW PASSED!");
        else
            $display("ERROR: LW FAILED!");


        // Test 4: Store (SW)
        opcode = 7'b0100011;
        #1;

        $display("SW: RegWrite=%b ALUSrc=%b MemWrite=%b ImmType=%b",
                 RegWrite, ALUSrc, MemWrite, ImmType);

        if (RegWrite == 1'b0 &&
            ALUSrc   == 1'b1 &&
            MemWrite == 1'b1 &&
            ImmType  == 3'b001)
            $display("SW PASSED!");
        else
            $display("ERROR: SW FAILED!");


        // Test 5: Branch (BEQ)
        opcode = 7'b1100011;
        #1;

        $display("BEQ: RegWrite=%b Branch=%b ImmType=%b ALUOp=%b",
                 RegWrite, Branch, ImmType, ALUOp);

        if (RegWrite == 1'b0 &&
            Branch   == 1'b1 &&
            ImmType  == 3'b010 &&
            ALUOp    == 2'b01)
            $display("BEQ PASSED!");
        else
            $display("ERROR: BEQ FAILED!");


        // Test 6: JAL
        opcode = 7'b1101111;
        #1;

        $display("JAL: RegWrite=%b Jump=%b ImmType=%b ResultSrc=%b",
                 RegWrite, Jump, ImmType, ResultSrc);

        if (RegWrite  == 1'b1 &&
            Jump      == 1'b1 &&
            ImmType   == 3'b100 &&
            ResultSrc == 2'b10)
            $display("JAL PASSED!");
        else
            $display("ERROR: JAL FAILED!");


        $finish;

    end

endmodule
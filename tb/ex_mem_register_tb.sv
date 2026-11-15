
module ex_mem_register_tb;

    logic clk;
    logic reset;
    logic flush;

    logic [31:0] ALUResult_in;
    logic [31:0] WriteData_in;
    logic [31:0] PCPlus4_in;

    logic [4:0] Rd_in;

    logic RegWrite_in;
    logic MemWrite_in;
    logic MemRead_in;
    logic [1:0] ResultSrc_in;

    logic [31:0] ALUResult_out;
    logic [31:0] WriteData_out;
    logic [31:0] PCPlus4_out;

    logic [4:0] Rd_out;

    logic RegWrite_out;
    logic MemWrite_out;
    logic MemRead_out;
    logic [1:0] ResultSrc_out;

    // Instantiate EX/MEM register
    ex_mem_register dut (.*);

    // Clock generator
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        reset = 1;
        flush = 0;

        ALUResult_in = 0;
        WriteData_in = 0;
        PCPlus4_in = 0;
        Rd_in = 0;

        RegWrite_in = 0;
        MemWrite_in = 0;
        MemRead_in = 0;
        ResultSrc_in = 0;

        // ==================================
        // TEST 1: RESET
        // ==================================

        @(posedge clk);
        #1;

        if (ALUResult_out !== 0 ||
            WriteData_out !== 0 ||
            PCPlus4_out !== 0 ||
            Rd_out !== 0 ||
            RegWrite_out !== 0 ||
            MemWrite_out !== 0 ||
            MemRead_out !== 0 ||
            ResultSrc_out !== 0)
            $fatal(1, "RESET FAILED!");

        $display("RESET PASSED!");

        // ==================================
        // TEST 2: ARITHMETIC TRANSFER
        // ==================================

        @(negedge clk);
        reset = 0;

        ALUResult_in = 32'd15;
        WriteData_in = 32'd10;
        PCPlus4_in = 32'd12;
        Rd_in = 5'd3;

        RegWrite_in = 1;
        MemWrite_in = 0;
        MemRead_in = 0;
        ResultSrc_in = 2'b00;

        @(posedge clk);
        #1;

        if (ALUResult_out !== 32'd15 ||
            WriteData_out !== 32'd10 ||
            PCPlus4_out !== 32'd12 ||
            Rd_out !== 5'd3 ||
            RegWrite_out !== 1 ||
            MemWrite_out !== 0 ||
            MemRead_out !== 0 ||
            ResultSrc_out !== 2'b00)
            $fatal(1, "ARITHMETIC TRANSFER FAILED!");

        $display("ARITHMETIC TRANSFER PASSED!");

        // ==================================
        // TEST 3: STORE TRANSFER
        // ==================================

        @(negedge clk);

        ALUResult_in = 32'd100;
        WriteData_in = 32'd15;
        PCPlus4_in = 32'd16;
        Rd_in = 5'd0;

        RegWrite_in = 0;
        MemWrite_in = 1;
        MemRead_in = 0;
        ResultSrc_in = 2'b00;

        @(posedge clk);
        #1;

        if (ALUResult_out !== 32'd100 ||
            WriteData_out !== 32'd15 ||
            MemWrite_out !== 1 ||
            RegWrite_out !== 0)
            $fatal(1, "STORE TRANSFER FAILED!");

        $display("STORE TRANSFER PASSED!");

        // ==================================
        // TEST 4: LOAD TRANSFER
        // ==================================

        @(negedge clk);

        ALUResult_in = 32'd100;
        WriteData_in = 32'd0;
        PCPlus4_in = 32'd20;
        Rd_in = 5'd4;

        RegWrite_in = 1;
        MemWrite_in = 0;
        MemRead_in = 1;
        ResultSrc_in = 2'b01;

        @(posedge clk);
        #1;

        if (ALUResult_out !== 32'd100 ||
            Rd_out !== 5'd4 ||
            RegWrite_out !== 1 ||
            MemWrite_out !== 0 ||
            MemRead_out !== 1 ||
            ResultSrc_out !== 2'b01)
            $fatal(1, "LOAD TRANSFER FAILED!");

        $display("LOAD TRANSFER PASSED!");

        // ==================================
        // TEST 5: JUMP RETURN ADDRESS
        // ==================================

        @(negedge clk);

        PCPlus4_in = 32'd44;
        Rd_in = 5'd7;

        RegWrite_in = 1;
        MemRead_in = 0;
        ResultSrc_in = 2'b10;

        @(posedge clk);
        #1;

        if (PCPlus4_out !== 32'd44 ||
            Rd_out !== 5'd7 ||
            RegWrite_out !== 1 ||
            ResultSrc_out !== 2'b10)
            $fatal(1, "JUMP TRANSFER FAILED!");

        $display("JUMP TRANSFER PASSED!");

        // ==================================
        // TEST 6: FLUSH
        // ==================================

        @(negedge clk);
        flush = 1;

        @(posedge clk);
        #1;

        if (ALUResult_out !== 0 ||
            WriteData_out !== 0 ||
            PCPlus4_out !== 0 ||
            Rd_out !== 0 ||
            RegWrite_out !== 0 ||
            MemWrite_out !== 0 ||
            MemRead_out !== 0 ||
            ResultSrc_out !== 0)
            $fatal(1, "FLUSH FAILED!");

        $display("FLUSH PASSED!");

        // ==================================
        // TEST 7: RECOVERY
        // ==================================

        @(negedge clk);
        flush = 0;

        ALUResult_in = 32'd25;
        WriteData_in = 32'd5;
        PCPlus4_in = 32'd48;
        Rd_in = 5'd9;

        RegWrite_in = 1;
        MemWrite_in = 0;
        MemRead_in = 0;
        ResultSrc_in = 2'b00;

        @(posedge clk);
        #1;

        if (ALUResult_out !== 32'd25 ||
            WriteData_out !== 32'd5 ||
            PCPlus4_out !== 32'd48 ||
            Rd_out !== 5'd9 ||
            RegWrite_out !== 1)
            $fatal(1, "RECOVERY FAILED!");

        $display("RECOVERY PASSED!");

        $display("--------------------------------");
        $display("ALL EX/MEM REGISTER TESTS PASSED!");
        $display("--------------------------------");

        $finish;

    end

endmodule

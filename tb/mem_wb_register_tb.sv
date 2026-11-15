
module mem_wb_register_tb;

    logic clk;
    logic reset;
    logic flush;

    logic [31:0] ALUResult_in;
    logic [31:0] ReadData_in;
    logic [31:0] PCPlus4_in;

    logic [4:0] Rd_in;

    logic RegWrite_in;
    logic [1:0] ResultSrc_in;

    logic [31:0] ALUResult_out;
    logic [31:0] ReadData_out;
    logic [31:0] PCPlus4_out;

    logic [4:0] Rd_out;

    logic RegWrite_out;
    logic [1:0] ResultSrc_out;

    mem_wb_register dut (.*);

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        reset = 1;
        flush = 0;

        ALUResult_in = 0;
        ReadData_in = 0;
        PCPlus4_in = 0;
        Rd_in = 0;

        RegWrite_in = 0;
        ResultSrc_in = 0;

        // TEST 1: RESET
        @(posedge clk);
        #1;

        if (ALUResult_out !== 0 ||
            ReadData_out !== 0 ||
            PCPlus4_out !== 0 ||
            Rd_out !== 0 ||
            RegWrite_out !== 0 ||
            ResultSrc_out !== 0)
            $fatal(1, "RESET FAILED!");

        $display("RESET PASSED!");

        // TEST 2: ALU RESULT
        @(negedge clk);
        reset = 0;

        ALUResult_in = 32'd15;
        ReadData_in = 32'd0;
        PCPlus4_in = 32'd12;
        Rd_in = 5'd3;

        RegWrite_in = 1;
        ResultSrc_in = 2'b00;

        @(posedge clk);
        #1;

        if (ALUResult_out !== 32'd15 ||
            Rd_out !== 5'd3 ||
            RegWrite_out !== 1 ||
            ResultSrc_out !== 2'b00)
            $fatal(1, "ALU WRITE-BACK FAILED!");

        $display("ALU WRITE-BACK PASSED!");

        // TEST 3: LOAD RESULT
        @(negedge clk);

        ALUResult_in = 32'd100;
        ReadData_in = 32'd42;
        PCPlus4_in = 32'd16;
        Rd_in = 5'd4;

        RegWrite_in = 1;
        ResultSrc_in = 2'b01;

        @(posedge clk);
        #1;

        if (ReadData_out !== 32'd42 ||
            Rd_out !== 5'd4 ||
            RegWrite_out !== 1 ||
            ResultSrc_out !== 2'b01)
            $fatal(1, "LOAD WRITE-BACK FAILED!");

        $display("LOAD WRITE-BACK PASSED!");

        // TEST 4: JUMP LINK
        @(negedge clk);

        ALUResult_in = 32'd0;
        ReadData_in = 32'd0;
        PCPlus4_in = 32'd44;
        Rd_in = 5'd7;

        RegWrite_in = 1;
        ResultSrc_in = 2'b10;

        @(posedge clk);
        #1;

        if (PCPlus4_out !== 32'd44 ||
            Rd_out !== 5'd7 ||
            RegWrite_out !== 1 ||
            ResultSrc_out !== 2'b10)
            $fatal(1, "JUMP WRITE-BACK FAILED!");

        $display("JUMP WRITE-BACK PASSED!");

        // TEST 5: FLUSH
        @(negedge clk);
        flush = 1;

        @(posedge clk);
        #1;

        if (ALUResult_out !== 0 ||
            ReadData_out !== 0 ||
            PCPlus4_out !== 0 ||
            Rd_out !== 0 ||
            RegWrite_out !== 0 ||
            ResultSrc_out !== 0)
            $fatal(1, "FLUSH FAILED!");

        $display("FLUSH PASSED!");

        // TEST 6: RECOVERY
        @(negedge clk);
        flush = 0;

        ALUResult_in = 32'd99;
        ReadData_in = 32'd0;
        PCPlus4_in = 32'd52;
        Rd_in = 5'd9;

        RegWrite_in = 1;
        ResultSrc_in = 2'b00;

        @(posedge clk);
        #1;

        if (ALUResult_out !== 32'd99 ||
            Rd_out !== 5'd9 ||
            RegWrite_out !== 1)
            $fatal(1, "RECOVERY FAILED!");

        $display("RECOVERY PASSED!");

        $display("--------------------------------");
        $display("ALL MEM/WB REGISTER TESTS PASSED!");
        $display("--------------------------------");

        $finish;

    end

endmodule


module id_ex_register_tb;

    logic clk, reset, flush;

    logic [31:0] PC_in, RD1_in, RD2_in, ImmExt_in;
    logic [31:0] PC_out, RD1_out, RD2_out, ImmExt_out;

    logic [4:0] Rs1_in, Rs2_in, Rd_in;
    logic [4:0] Rs1_out, Rs2_out, Rd_out;

    logic [2:0] ALUControl_in, ALUControl_out;
    logic ALUSrc_in, ALUSrc_out;

    logic RegWrite_in, MemWrite_in, MemRead_in;
    logic RegWrite_out, MemWrite_out, MemRead_out;

    logic [1:0] ResultSrc_in, ResultSrc_out;
    logic Branch_in, Jump_in;
    logic Branch_out, Jump_out;

    id_ex_register dut (
        .*
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        flush = 0;

        PC_in = 0;
        RD1_in = 0;
        RD2_in = 0;
        ImmExt_in = 0;

        Rs1_in = 0;
        Rs2_in = 0;
        Rd_in = 0;

        ALUControl_in = 0;
        ALUSrc_in = 0;

        RegWrite_in = 0;
        MemWrite_in = 0;
        MemRead_in = 0;
        ResultSrc_in = 0;
        Branch_in = 0;
        Jump_in = 0;

        // TEST 1: RESET
        @(posedge clk);
        #1;

        if (PC_out !== 0 ||
            RegWrite_out !== 0 ||
            MemWrite_out !== 0 ||
            Rd_out !== 0)
            $fatal(1, "RESET FAILED!");

        $display("RESET PASSED!");

        // TEST 2: NORMAL TRANSFER
        @(negedge clk);
        reset = 0;

        PC_in = 32'd8;
        RD1_in = 32'd5;
        RD2_in = 32'd10;
        ImmExt_in = 32'd4;

        Rs1_in = 5'd1;
        Rs2_in = 5'd2;
        Rd_in = 5'd3;

        ALUControl_in = 3'b000;
        ALUSrc_in = 0;

        RegWrite_in = 1;
        MemWrite_in = 0;
        MemRead_in = 0;
        ResultSrc_in = 2'b00;
        Branch_in = 0;
        Jump_in = 0;

        @(posedge clk);
        #1;

        if (PC_out !== 32'd8 ||
            RD1_out !== 32'd5 ||
            RD2_out !== 32'd10 ||
            ImmExt_out !== 32'd4 ||
            Rs1_out !== 5'd1 ||
            Rs2_out !== 5'd2 ||
            Rd_out !== 5'd3 ||
            ALUControl_out !== 3'b000 ||
            ALUSrc_out !== 0 ||
            RegWrite_out !== 1)
            $fatal(1, "NORMAL TRANSFER FAILED!");

        $display("NORMAL TRANSFER PASSED!");

        // TEST 3: FLUSH
        @(negedge clk);
        flush = 1;

        @(posedge clk);
        #1;

        if (PC_out !== 0 ||
            RD1_out !== 0 ||
            RD2_out !== 0 ||
            ImmExt_out !== 0 ||
            Rs1_out !== 0 ||
            Rs2_out !== 0 ||
            Rd_out !== 0 ||
            ALUControl_out !== 0 ||
            ALUSrc_out !== 0 ||
            RegWrite_out !== 0 ||
            MemWrite_out !== 0 ||
            MemRead_out !== 0 ||
            ResultSrc_out !== 0 ||
            Branch_out !== 0 ||
            Jump_out !== 0)
            $fatal(1, "FLUSH FAILED!");

        $display("FLUSH PASSED!");

        // TEST 4: RECOVERY
        @(negedge clk);
        flush = 0;

        PC_in = 32'd12;
        RD1_in = 32'd20;
        RD2_in = 32'd30;
        Rd_in = 5'd4;
        RegWrite_in = 1;

        @(posedge clk);
        #1;

        if (PC_out !== 32'd12 ||
            RD1_out !== 32'd20 ||
            RD2_out !== 32'd30 ||
            Rd_out !== 5'd4 ||
            RegWrite_out !== 1)
            $fatal(1, "RECOVERY FAILED!");

        $display("RECOVERY PASSED!");

        $display("--------------------------------");
        $display("ALL ID/EX REGISTER TESTS PASSED!");
        $display("--------------------------------");

        $finish;
    end

endmodule

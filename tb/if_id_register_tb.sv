
module if_id_register_tb;

    logic clk;
    logic reset;
    logic stall;
    logic flush;

    logic [31:0] PC_in;
    logic [31:0] Instruction_in;

    logic [31:0] PC_out;
    logic [31:0] Instruction_out;

    localparam logic [31:0] NOP = 32'h00000013;

    if_id_register dut (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .flush(flush),
        .PC_in(PC_in),
        .Instruction_in(Instruction_in),
        .PC_out(PC_out),
        .Instruction_out(Instruction_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        reset = 1;
        stall = 0;
        flush = 0;

        PC_in = 32'd0;
        Instruction_in = 32'h00500093;

        // TEST 1: RESET
        @(posedge clk);
        #1;

        if (PC_out !== 32'd0 ||
            Instruction_out !== NOP)
            $fatal(1, "RESET FAILED!");

        $display("RESET PASSED!");

        // TEST 2: NORMAL PIPELINE TRANSFER
        @(negedge clk);
        reset = 0;

        PC_in = 32'd4;
        Instruction_in = 32'h00A00113;

        @(posedge clk);
        #1;

        if (PC_out !== 32'd4 ||
            Instruction_out !== 32'h00A00113)
            $fatal(1, "NORMAL TRANSFER FAILED!");

        $display("NORMAL TRANSFER PASSED!");

        // TEST 3: STALL
        @(negedge clk);
        stall = 1;

        PC_in = 32'd8;
        Instruction_in = 32'h002081B3;

        @(posedge clk);
        #1;

        if (PC_out !== 32'd4 ||
            Instruction_out !== 32'h00A00113)
            $fatal(1, "STALL FAILED!");

        $display("STALL PASSED!");

        // TEST 4: FLUSH
        @(negedge clk);
        stall = 0;
        flush = 1;

        @(posedge clk);
        #1;

        if (PC_out !== 32'd0 ||
            Instruction_out !== NOP)
            $fatal(1, "FLUSH FAILED!");

        $display("FLUSH PASSED!");

        // TEST 5: RECOVERY AFTER FLUSH
        @(negedge clk);
        flush = 0;

        PC_in = 32'd12;
        Instruction_in = 32'h00302023;

        @(posedge clk);
        #1;

        if (PC_out !== 32'd12 ||
            Instruction_out !== 32'h00302023)
            $fatal(1, "RECOVERY FAILED!");

        $display("RECOVERY PASSED!");

        $display("--------------------------------");
        $display("ALL IF/ID REGISTER TESTS PASSED!");
        $display("--------------------------------");

        $finish;

    end

endmodule

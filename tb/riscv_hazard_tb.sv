
module riscv_hazard_tb;

    logic clk;
    logic reset;
    logic [31:0] PC_out;

    integer stall_count;

    riscv_pipelined_cpu dut (
        .clk(clk),
        .reset(reset),
        .PC_out(PC_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Count cycles where fetch is stalled.
    always @(posedge clk) begin
        if (reset)
            stall_count <= 0;
        else if (dut.StallF)
            stall_count <= stall_count + 1;
    end

    initial begin
        reset = 1;

        // Load the hazard program directly
        // into the instruction memory.
        $readmemh(
            "programs/hazard_test.hex",
            dut.imem.memory
        );

        repeat (2) @(posedge clk);
        @(negedge clk);
        reset = 0;

        repeat (15) @(posedge clk);
        #1;

        if (dut.rf.registers[1] !== 32'd100)
            $fatal(1, "ADDI FAILED!");
        $display("ADDI PASSED!");

        if (dut.dmem.memory[0] !== 32'd100)
            $fatal(1, "STORE FAILED!");
        $display("STORE PASSED!");

        if (dut.rf.registers[2] !== 32'd100)
            $fatal(1, "LOAD FAILED!");
        $display("LOAD PASSED!");

        if (dut.rf.registers[3] !== 32'd200)
            $fatal(1, "LOAD-USE ADD FAILED!");
        $display("LOAD-USE ADD PASSED!");

        if (stall_count < 1)
            $fatal(1, "NO STALL DETECTED!");

        $display(
            "LOAD-USE STALL PASSED! Stall cycles = %0d",
            stall_count
        );

        $display("--------------------------------");
        $display("ADVANCED HAZARD TEST PASSED!");
        $display("--------------------------------");

        $finish;
    end

endmodule

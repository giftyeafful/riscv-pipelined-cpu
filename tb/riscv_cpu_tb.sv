
module riscv_cpu_tb;

    logic clk;
    logic reset;
    logic [31:0] PC_out;

    // Instantiate CPU
    riscv_cpu dut (
        .clk(clk),
        .reset(reset),
        .PC_out(PC_out)
    );

    // Clock generator
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // CPU integration tests
    initial begin

        // Reset CPU
        reset = 1;

        @(posedge clk);
        #1;

        if (PC_out !== 32'd0)
            $fatal(1, "CPU reset FAILED!");

        $display("CPU reset PASSED!");

        @(negedge clk);
        reset = 0;

        // Test 1: ADDI x1, x0, 5
        @(posedge clk);
        #1;

        if (dut.rf.registers[1] !== 32'd5)
            $fatal(1, "ADDI x1 FAILED!");

        $display("ADDI x1 PASSED: x1 = 5");

        // Test 2: ADDI x2, x0, 10
        @(posedge clk);
        #1;

        if (dut.rf.registers[2] !== 32'd10)
            $fatal(1, "ADDI x2 FAILED!");

        $display("ADDI x2 PASSED: x2 = 10");

        // Test 3: ADD x3, x1, x2
        @(posedge clk);
        #1;

        if (dut.rf.registers[3] !== 32'd15)
            $fatal(1, "ADD x3 FAILED!");

        $display("ADD x3 PASSED: x3 = 15");

        // Test 4: SW x3, 0(x0)
        @(posedge clk);
        #1;

        if (dut.dmem.memory[0] !== 32'd15)
            $fatal(1, "SW FAILED!");

        $display("SW PASSED: Memory[0] = 15");

        // Test 5: LW x4, 0(x0)
        @(posedge clk);
        #1;

        if (dut.rf.registers[4] !== 32'd15)
            $fatal(1, "LW FAILED!");

        $display("LW PASSED: x4 = 15");

        $display("All CPU Memory Integration tests PASSED!");

        $finish;

    end

endmodule

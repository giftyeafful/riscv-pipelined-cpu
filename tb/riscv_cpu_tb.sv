
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

        // Test 6: BEQ x1, x1, 8
        // Branch from PC 20 to PC 28
        @(posedge clk);
        #1;

        if (PC_out !== 32'd28)
            $fatal(1, "BEQ FAILED! PC = %0d", PC_out);

        $display("BEQ PASSED: PC = %0d", PC_out);

        // Test 7: JAL x6, 8
        // Jump from PC 28 to PC 36
        // Save return address 32 in x6
        @(posedge clk);
        #1;

        if (PC_out !== 32'd36 ||
            dut.rf.registers[6] !== 32'd32)
            $fatal(1, "JAL FAILED!");

        $display("JAL PASSED: x6 = %0d",
                 dut.rf.registers[6]);

        // Test 8: ADDI x8, x0, 40
        @(posedge clk);
        #1;

        if (dut.rf.registers[8] !== 32'd40)
            $fatal(1, "ADDI x8 FAILED!");

        $display("ADDI x8 PASSED: x8 = 40");

        // Test 9: JALR x7, 8(x8)
        // Jump from PC 40 to PC 48
        // Save return address 44 in x7
        @(posedge clk);
        #1;

        if (PC_out !== 32'd48 ||
            dut.rf.registers[7] !== 32'd44)
            $fatal(1, "JALR FAILED!");

        $display("JALR PASSED: x7 = %0d",
                 dut.rf.registers[7]);

        // Test 10: ADDI x5, x0, 66
        @(posedge clk);
        #1;

        if (dut.rf.registers[5] !== 32'd66)
            $fatal(1, "ADDI x5 FAILED!");

        $display("ADDI x5 PASSED: x5 = 66");

        // Test 11: ADDI x9, x0, 42
        @(posedge clk);
        #1;

        if (dut.rf.registers[9] !== 32'd42)
            $fatal(1, "ADDI x9 FAILED!");

        $display("ADDI x9 PASSED: x9 = 42");

        $display("All CPU Integration tests PASSED!");

        $finish;

    end

endmodule

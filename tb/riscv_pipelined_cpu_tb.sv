
module riscv_pipelined_cpu_tb;

    logic clk;
    logic reset;
    logic [31:0] PC_out;

    riscv_pipelined_cpu dut (
        .clk(clk),
        .reset(reset),
        .PC_out(PC_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;

        // Apply reset for two clock cycles.
        repeat (2) @(posedge clk);
        @(negedge clk);
        reset = 0;

        // Allow instructions to move through
        // the five pipeline stages.
        repeat (30) @(posedge clk);
        #1;

        // ADDI x1, x0, 5
        if (dut.rf.registers[1] !== 32'd5)
            $fatal(1, "ADDI x1 FAILED!");
        $display("ADDI x1 PASSED!");

        // ADDI x2, x0, 10
        if (dut.rf.registers[2] !== 32'd10)
            $fatal(1, "ADDI x2 FAILED!");
        $display("ADDI x2 PASSED!");

        // ADD x3, x1, x2
        if (dut.rf.registers[3] !== 32'd15)
            $fatal(1, "ADD x3 FAILED!");
        $display("ADD x3 PASSED!");

        // SW x3, 0(x0)
        if (dut.dmem.memory[0] !== 32'd15)
            $fatal(1, "SW FAILED!");
        $display("SW PASSED!");

        // LW x4, 0(x0)
        if (dut.rf.registers[4] !== 32'd15)
            $fatal(1, "LW FAILED!");
        $display("LW PASSED!");

        // Branch/jump program checks
        if (dut.rf.registers[6] !== 32'd32)
            $fatal(1, "JAL LINK FAILED!");
        $display("JAL LINK PASSED!");

        if (dut.rf.registers[8] !== 32'd40)
            $fatal(1, "ADDI x8 FAILED!");
        $display("ADDI x8 PASSED!");

        if (dut.rf.registers[7] !== 32'd44)
            $fatal(1, "JALR LINK FAILED!");
        $display("JALR LINK PASSED!");

        if (dut.rf.registers[5] !== 32'd66)
            $fatal(1, "BRANCH/JUMP PATH FAILED!");
        $display("BRANCH/JUMP PATH PASSED!");

        if (dut.rf.registers[9] !== 32'd42)
            $fatal(1, "FINAL ADDI FAILED!");
        $display("FINAL ADDI PASSED!");

        $display("--------------------------------");
        $display("PIPELINED CPU INTEGRATION PASSED!");
        $display("--------------------------------");

        $finish;
    end

endmodule

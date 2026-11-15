
module branch_hazard_tb;

    logic clk = 0;
    logic reset;
    logic [31:0] PC_out;

    integer branch_count = 0;
    integer stall_count = 0;

    riscv_pipelined_cpu dut (
        .clk(clk),
        .reset(reset),
        .PC_out(PC_out)
    );

    always #5 clk = ~clk;

    // Count taken branches and stalls.
    always @(posedge clk) begin
        if (reset) begin
            branch_count <= 0;
            stall_count <= 0;
        end else begin
            if (dut.PCSrcE)
                branch_count <= branch_count + 1;

            if (dut.StallF)
                stall_count <= stall_count + 1;
        end
    end

    initial begin
        reset = 1;

        #1;

        // Initialize instruction memory with NOPs.
        for (int i = 0; i < 256; i++) begin
            dut.imem.memory[i] = 32'h00000013;
        end

        // Initialize the test program.
        dut.imem.memory[0] = 32'h00A00093; // addi x1,x0,10
        dut.imem.memory[1] = 32'h00A00113; // addi x2,x0,10

        // beq x1,x2,+12 -> instruction index 5
        dut.imem.memory[2] = 32'h00208663;

        dut.imem.memory[3] = 32'h06300193; // addi x3,x0,99
        dut.imem.memory[4] = 32'h05800213; // addi x4,x0,88

        dut.imem.memory[5] = 32'h01900293; // addi x5,x0,25
        dut.imem.memory[6] = 32'h01E00313; // addi x6,x0,30

        // beq x5,x6,+8 -> instruction index 9
        // This branch must NOT be taken.
        dut.imem.memory[7] = 32'h00628463;

        dut.imem.memory[8] = 32'h02A00393; // addi x7,x0,42
        dut.imem.memory[9] = 32'h03200413; // addi x8,x0,50

        repeat (2) @(posedge clk);
        @(negedge clk);
        reset = 0;

        repeat (25) @(posedge clk);
        #1;

        $display("\nFINAL REGISTER VALUES:");
        for (int i = 1; i <= 8; i++) begin
            $display("x%0d = %0d", i, dut.rf.registers[i]);
        end

        $display("Taken branches = %0d", branch_count);
        $display("Stall cycles   = %0d", stall_count);

        if (dut.rf.registers[1] !== 32'd10)
            $fatal(1, "x1 FAILED");

        if (dut.rf.registers[2] !== 32'd10)
            $fatal(1, "x2 FAILED");

        if (dut.rf.registers[3] !== 32'd0)
            $fatal(1, "BRANCH FLUSH FAILED: x3 changed");

        if (dut.rf.registers[4] !== 32'd0)
            $fatal(1, "BRANCH FLUSH FAILED: x4 changed");

        if (dut.rf.registers[5] !== 32'd25)
            $fatal(1, "TAKEN BRANCH TARGET FAILED");

        if (dut.rf.registers[6] !== 32'd30)
            $fatal(1, "x6 FAILED");

        if (dut.rf.registers[7] !== 32'd42)
            $fatal(1, "NOT-TAKEN BRANCH FAILED");

        if (dut.rf.registers[8] !== 32'd50)
            $fatal(1, "FINAL INSTRUCTION FAILED");

        if (branch_count !== 1)
            $fatal(
                1,
                "EXPECTED 1 TAKEN BRANCH, GOT %0d",
                branch_count
            );

        $display("--------------------------------");
        $display("TAKEN BRANCH PASSED!");
        $display("BRANCH FLUSH PASSED!");
        $display("NOT-TAKEN BRANCH PASSED!");
        $display("BRANCH FORWARDING PASSED!");
        $display("--------------------------------");
        $display("BRANCH HAZARD TEST PASSED!");
        $display("--------------------------------");

        $finish;
    end

endmodule

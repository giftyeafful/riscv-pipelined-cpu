
module alu_forwarding_tb;

    logic clk = 0;
    logic reset;
    logic [31:0] PC_out;

    integer stall_count = 0;

    riscv_pipelined_cpu dut (
        .clk(clk),
        .reset(reset),
        .PC_out(PC_out)
    );

    always #5 clk = ~clk;

    // Count pipeline stalls.
    always @(posedge clk) begin
        if (reset)
            stall_count <= 0;
        else if (dut.StallF)
            stall_count <= stall_count + 1;
    end

    // Display pipeline activity for debugging.
    always @(negedge clk) begin
        if (!reset) begin
            $display(
                "PC=%0d | RdE=%0d | ALUCtrl=%b | A=%0d | B=%0d | Result=%0d | RdW=%0d",
                PC_out,
                dut.RdE,
                dut.ALUControlE,
                dut.SrcAE,
                dut.SrcBE,
                dut.ALUResultE,
                dut.RdW
            );
        end
    end

    initial begin
        reset = 1;

        // Allow the instruction memory to initialize.
        #1;

        // Clear old instructions with NOPs.
        for (int i = 0; i < 256; i++) begin
            dut.imem.memory[i] = 32'h00000013;
        end

        // Explicitly load the test instructions.
        dut.imem.memory[0] = 32'h00500093; // addi x1,x0,5
        dut.imem.memory[1] = 32'h00A08113; // addi x2,x1,10
        dut.imem.memory[2] = 32'h001101B3; // add x3,x2,x1
        dut.imem.memory[3] = 32'h40118233; // sub x4,x3,x1

        repeat (2) @(posedge clk);
        @(negedge clk);
        reset = 0;

        // Allow all instructions to complete.
        repeat (12) @(posedge clk);
        #1;

        $display("\nFINAL REGISTER VALUES:");
        $display("x1 = %0d", dut.rf.registers[1]);
        $display("x2 = %0d", dut.rf.registers[2]);
        $display("x3 = %0d", dut.rf.registers[3]);
        $display("x4 = %0d", dut.rf.registers[4]);
        $display("Stalls = %0d", stall_count);

        if (dut.rf.registers[1] !== 32'd5)
            $fatal(1, "x1 FAILED");
        $display("x1 PASSED!");

        if (dut.rf.registers[2] !== 32'd15)
            $fatal(1, "x2 FAILED");
        $display("x2 PASSED!");

        if (dut.rf.registers[3] !== 32'd20)
            $fatal(1, "x3 FAILED");
        $display("x3 PASSED!");

        if (dut.rf.registers[4] !== 32'd15)
            $fatal(1, "x4 SUB FAILED");
        $display("x4 SUB PASSED!");

        if (stall_count !== 0)
            $fatal(1, "UNEXPECTED PIPELINE STALLS");
        $display("NO UNNECESSARY STALLS PASSED!");

        $display("--------------------------------");
        $display("ALU FORWARDING TEST PASSED!");
        $display("--------------------------------");

        $finish;
    end

endmodule

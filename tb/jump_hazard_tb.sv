
module jump_hazard_tb;


initial begin
    $dumpfile("jump_hazard.vcd");
    $dumpvars(0, jump_hazard_tb);
end


    logic clk = 0;
    logic reset;
    logic [31:0] PC_out;

    integer redirect_count = 0;
    integer stall_count = 0;

    riscv_pipelined_cpu dut (
        .clk(clk),
        .reset(reset),
        .PC_out(PC_out)
    );

    always #5 clk = ~clk;

    always @(posedge clk) begin
        if (reset) begin
            redirect_count <= 0;
            stall_count <= 0;
        end else begin
            if (dut.PCSrcE)
                redirect_count <= redirect_count + 1;
            if (dut.StallF)
                stall_count <= stall_count + 1;
        end
    end

    initial begin
        reset = 1;
        #1;

        // Isolate this test from the original program.
        for (int i = 0; i < 256; i++)
            dut.imem.memory[i] = 32'h00000013;

        dut.imem.memory[0] = 32'h00500093; // addi x1,x0,5
        dut.imem.memory[1] = 32'h0080036F; // jal x6,+8
        dut.imem.memory[2] = 32'h06300113; // addi x2,x0,99
        dut.imem.memory[3] = 32'h01800413; // addi x8,x0,24
        dut.imem.memory[4] = 32'h00C403E7; // jalr x7,12(x8)
        dut.imem.memory[5] = 32'h05800193; // addi x3,x0,88
        dut.imem.memory[6] = 32'h04D00213; // addi x4,x0,77
        dut.imem.memory[9] = 32'h02A00293; // addi x5,x0,42

        repeat (2) @(posedge clk);
        @(negedge clk);
        reset = 0;

        repeat (25) @(posedge clk);
        #1;

        $display("\nFINAL REGISTER VALUES:");
        $display("x1 = %0d", dut.rf.registers[1]);
        $display("x2 = %0d", dut.rf.registers[2]);
        $display("x3 = %0d", dut.rf.registers[3]);
        $display("x4 = %0d", dut.rf.registers[4]);
        $display("x5 = %0d", dut.rf.registers[5]);
        $display("x6 = %0d", dut.rf.registers[6]);
        $display("x7 = %0d", dut.rf.registers[7]);
        $display("x8 = %0d", dut.rf.registers[8]);

        $display("Redirects = %0d", redirect_count);
        $display("Stalls = %0d", stall_count);

        if (dut.rf.registers[1] !== 32'd5)
            $fatal(1, "INITIAL ADDI FAILED");

        if (dut.rf.registers[2] !== 32'd0)
            $fatal(1, "JAL FLUSH FAILED");

        if (dut.rf.registers[3] !== 32'd0 ||
            dut.rf.registers[4] !== 32'd0)
            $fatal(1, "JALR FLUSH FAILED");

        if (dut.rf.registers[5] !== 32'd42)
            $fatal(1, "JALR TARGET FAILED");

        // JAL at PC=4 saves PC+4=8.
        if (dut.rf.registers[6] !== 32'd8)
            $fatal(1, "JAL LINK FAILED");

        // JALR at PC=16 saves PC+4=20.
        if (dut.rf.registers[7] !== 32'd20)
            $fatal(1, "JALR LINK FAILED");

        if (dut.rf.registers[8] !== 32'd24)
            $fatal(1, "JALR BASE REGISTER FAILED");

        if (redirect_count !== 2)
            $fatal(1, "EXPECTED 2 JUMP REDIRECTS");

        if (stall_count !== 0)
            $fatal(1, "UNEXPECTED PIPELINE STALL");

        $display("--------------------------------");
        $display("JAL TARGET AND LINK PASSED!");
        $display("JAL FLUSH PASSED!");
        $display("JALR TARGET AND LINK PASSED!");
        $display("JALR FLUSH PASSED!");
        $display("JALR DEPENDENCY PASSED!");
        $display("NO UNNECESSARY STALLS PASSED!");
        $display("--------------------------------");
        $display("JUMP HAZARD TEST PASSED!");
        $display("--------------------------------");

        $finish;
    end

endmodule

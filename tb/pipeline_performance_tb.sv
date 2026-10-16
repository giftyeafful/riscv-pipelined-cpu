
module pipeline_performance_tb;

    logic clk = 0;
    logic reset;
    logic [31:0] PC_out;

    integer cycle_count = 0;
    integer retired_count = 0;
    integer stall_count = 0;
    integer redirect_count = 0;

    localparam int PROGRAM_LENGTH = 20;

    riscv_pipelined_cpu dut (
        .clk(clk),
        .reset(reset),
        .PC_out(PC_out)
    );

    always #5 clk = ~clk;

    // Measure from reset release until the
    // last program instruction reaches Write-Back.
    always @(posedge clk) begin
        if (reset) begin
            cycle_count <= 0;
            stall_count <= 0;
            redirect_count <= 0;
        end else begin
            cycle_count <= cycle_count + 1;

            if (dut.StallF)
                stall_count <= stall_count + 1;

            if (dut.PCSrcE)
                redirect_count <= redirect_count + 1;
        end
    end

    initial begin
        reset = 1;

        #1;

        // Initialize instruction memory with NOPs.
        for (int i = 0; i < 256; i++)
            dut.imem.memory[i] = 32'h00000013;

        // Twenty ADDI instructions:
        // addi x1,x0,1 through addi x20,x0,20.
        for (int i = 0; i < PROGRAM_LENGTH; i++) begin
            dut.imem.memory[i] =
                ((i + 1) << 20) |
                (0 << 15) |
                (3'b000 << 12) |
                ((i + 1) << 7) |
                7'h13;
        end

        repeat (2) @(posedge clk);
        @(negedge clk);
        reset = 0;

        // Wait for the final instruction to reach
        // the Write-Back stage.
        do begin
            @(negedge clk);
        end while (dut.RdW !== 5'd20);

        // The next rising edge commits x20.
        @(posedge clk);
        #1;

        // Validate all 20 instruction results.
        for (int i = 1; i <= PROGRAM_LENGTH; i++) begin
            if (dut.rf.registers[i] !== i)
                $fatal(
                    1,
                    "REGISTER x%0d FAILED: got %0d",
                    i,
                    dut.rf.registers[i]
                );
        end

        retired_count = PROGRAM_LENGTH;

        $display("\n--------------------------------");
        $display("PIPELINE PERFORMANCE REPORT");
        $display("--------------------------------");

        $display("Instructions retired: %0d",
                 retired_count);
        $display("Clock cycles:         %0d",
                 cycle_count);
        $display("Stall cycles:         %0d",
                 stall_count);
        $display("Redirects:            %0d",
                 redirect_count);

        $display("CPI:                  %0.3f",
                 real'(cycle_count) / real'(retired_count));

        $display("IPC:                  %0.3f",
                 real'(retired_count) / real'(cycle_count));

        if (stall_count !== 0)
            $fatal(1, "UNEXPECTED STALLS");

        if (redirect_count !== 0)
            $fatal(1, "UNEXPECTED REDIRECTS");

        $display("--------------------------------");
        $display("PERFORMANCE TEST PASSED!");
        $display("--------------------------------");

        $finish;
    end

    initial begin
        #5000;
        $fatal(1, "PERFORMANCE TEST TIMEOUT");
    end

endmodule

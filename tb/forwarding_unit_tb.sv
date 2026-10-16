
module forwarding_unit_tb;

    logic [4:0] Rs1E, Rs2E;
    logic [4:0] RdM, RdW;
    logic RegWriteM, RegWriteW;
    logic [1:0] ResultSrcM;
    logic [1:0] ForwardA, ForwardB;

    forwarding_unit dut (.*);

    initial begin

        // Test 1: No forwarding
        Rs1E = 5'd1;
        Rs2E = 5'd2;
        RdM = 5'd3;
        RdW = 5'd4;
        RegWriteM = 1;
        RegWriteW = 1;
        ResultSrcM = 2'b00;

        #1;
        if (ForwardA !== 2'b00 ||
            ForwardB !== 2'b00)
            $fatal(1, "NO FORWARDING FAILED!");

        $display("NO FORWARDING PASSED!");

        // Test 2: Forward A from EX/MEM
        RdM = 5'd1;

        #1;
        if (ForwardA !== 2'b10)
            $fatal(1, "EX/MEM FORWARD A FAILED!");

        $display("EX/MEM FORWARD A PASSED!");

        // Test 3: Forward B from MEM/WB
        RdM = 5'd3;
        RdW = 5'd2;

        #1;
        if (ForwardB !== 2'b01)
            $fatal(1, "MEM/WB FORWARD B FAILED!");

        $display("MEM/WB FORWARD B PASSED!");

        // Test 4: EX/MEM priority
        RdM = 5'd1;
        RdW = 5'd1;
        Rs1E = 5'd1;

        #1;
        if (ForwardA !== 2'b10)
            $fatal(1, "FORWARDING PRIORITY FAILED!");

        $display("FORWARDING PRIORITY PASSED!");

        // Test 5: Never forward x0
        Rs1E = 5'd0;
        RdM = 5'd0;
        RdW = 5'd0;

        #1;
        if (ForwardA !== 2'b00)
            $fatal(1, "X0 PROTECTION FAILED!");

        $display("X0 PROTECTION PASSED!");

        // Test 6: Load cannot forward from EX/MEM
        Rs1E = 5'd5;
        RdM = 5'd5;
        RdW = 5'd0;
        ResultSrcM = 2'b01;

        #1;
        if (ForwardA !== 2'b00)
            $fatal(1, "LOAD FORWARDING FAILED!");

        $display("LOAD FORWARDING PROTECTION PASSED!");

        $display("--------------------------------");
        $display("ALL FORWARDING UNIT TESTS PASSED!");
        $display("--------------------------------");

        $finish;
    end

endmodule

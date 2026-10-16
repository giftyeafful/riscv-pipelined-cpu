
module hazard_detection_unit_tb;

    logic [4:0] Rs1D, Rs2D, RdE;
    logic UsesRs1D, UsesRs2D;
    logic MemReadE, PCSrcE;

    logic StallF, StallD, FlushD, FlushE;

    hazard_detection_unit dut (.*);

    task automatic check_outputs(
        input logic sf,
        input logic sd,
        input logic fd,
        input logic fe,
        input string test_name
    );
        #1;
        if ({StallF, StallD, FlushD, FlushE}
            !== {sf, sd, fd, fe})
            $fatal(1, "%s FAILED!", test_name);

        $display("%s PASSED!", test_name);
    endtask

    initial begin

        // Default: no hazard
        Rs1D = 5'd1;
        Rs2D = 5'd2;
        RdE = 5'd3;

        UsesRs1D = 1;
        UsesRs2D = 1;
        MemReadE = 0;
        PCSrcE = 0;

        check_outputs(0, 0, 0, 0, "NO HAZARD");

        // Load-use dependency on rs1
        MemReadE = 1;
        RdE = 5'd1;

        check_outputs(1, 1, 0, 1, "RS1 LOAD-USE");

        // Load-use dependency on rs2
        RdE = 5'd2;

        check_outputs(1, 1, 0, 1, "RS2 LOAD-USE");

        // No false dependency on unused rs2
        UsesRs2D = 0;

        check_outputs(0, 0, 0, 0, "UNUSED RS2");

        // No hazard for x0
        RdE = 5'd0;
        Rs1D = 5'd0;

        check_outputs(0, 0, 0, 0, "X0 PROTECTION");

        // Taken branch or jump
        MemReadE = 0;
        PCSrcE = 1;

        check_outputs(0, 0, 1, 1, "CONTROL REDIRECT");

        // Redirect has priority over load stall
        MemReadE = 1;
        RdE = 5'd2;
        UsesRs2D = 1;
        Rs2D = 5'd2;

        check_outputs(0, 0, 1, 1, "REDIRECT PRIORITY");

        // Return to normal operation
        PCSrcE = 0;
        MemReadE = 0;

        check_outputs(0, 0, 0, 0, "RECOVERY");

        $display("--------------------------------");
        $display("ALL HAZARD DETECTION TESTS PASSED!");
        $display("--------------------------------");

        $finish;

    end

endmodule

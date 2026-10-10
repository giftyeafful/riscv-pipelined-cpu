
module instruction_memory_tb;

    logic [31:0] address;
    logic [31:0] instruction;

    instruction_memory dut (
        .address(address),
        .instruction(instruction)
    );

    initial begin

        // Test 1: Address 0
        address = 32'd0;
        #1;

        $display("Address 0: instruction = %h", instruction);

        if (instruction !== 32'h00500093)
            $fatal(1, "Address 0 FAILED!");
        else
            $display("Address 0 PASSED!");


        // Test 2: Address 4
        address = 32'd4;
        #1;

        $display("Address 4: instruction = %h", instruction);

        if (instruction !== 32'h00A00113)
            $fatal(1, "Address 4 FAILED!");
        else
            $display("Address 4 PASSED!");


        // Test 3: Address 8
        address = 32'd8;
        #1;

        $display("Address 8: instruction = %h", instruction);

        if (instruction !== 32'h002081B3)
            $fatal(1, "Address 8 FAILED!");
        else
            $display("Address 8 PASSED!");


        // Test 4: Out-of-range address
        address = 32'd1024;
        #1;

        if (instruction !== 32'h00000013)
            $fatal(1, "Out-of-range test FAILED!");
        else
            $display("Out-of-range test PASSED!");

        $display("All Instruction Memory tests PASSED!");

        $finish;

    end

endmodule

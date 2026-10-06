module program_counter_tb;

    logic        clk;
    logic        reset;
    logic [31:0] NextPC;
    logic [31:0] PC;

    program_counter dut (
        .clk(clk),
        .reset(reset),
        .NextPC(NextPC),
        .PC(PC)
    );


    // Generate clock
    initial begin
        clk = 0;

        forever #5 clk = ~clk;
    end


    initial begin

        
        // Test 1: Reset PC
        
        reset  = 1'b1;
        NextPC = 32'd4;

        @(posedge clk);
        #1;

        if (PC != 32'd0)
            $display("ERROR: PC reset FAILED!");
        else
            $display("PC reset PASSED! PC = %0d", PC);


       
        // Test 2: PC = 4
        
        reset  = 1'b0;
        NextPC = 32'd4;

        @(posedge clk);
        #1;

        if (PC != 32'd4)
            $display("ERROR: PC update to 4 FAILED!");
        else
            $display("PC update PASSED! PC = %0d", PC);


        
        // Test 3: PC = 8
        
        NextPC = 32'd8;

        @(posedge clk);
        #1;

        if (PC != 32'd8)
            $display("ERROR: PC update to 8 FAILED!");
        else
            $display("PC update PASSED! PC = %0d", PC);


        
        // Test 4: PC = 12
        
        NextPC = 32'd12;

        @(posedge clk);
        #1;

        if (PC != 32'd12)
            $display("ERROR: PC update to 12 FAILED!");
        else
            $display("PC update PASSED! PC = %0d", PC);


        $finish;

    end

endmodule
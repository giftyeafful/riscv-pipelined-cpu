
module data_memory_tb;

    logic clk;
    logic MemWrite;
    logic MemRead;
    logic [31:0] address;
    logic [31:0] WriteData;
    logic [31:0] ReadData;

    data_memory dut (
        .clk(clk),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .address(address),
        .WriteData(WriteData),
        .ReadData(ReadData)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        MemWrite = 0;
        MemRead  = 0;
        address  = 0;
        WriteData = 0;

        // TEST 1: Write 25 to address 8
        @(negedge clk);
        MemWrite = 1;
        address = 32'd8;
        WriteData = 32'd25;

        @(posedge clk);
        #1;

        MemWrite = 0;
        MemRead = 1;
        #1;

        if (ReadData !== 32'd25)
            $fatal(1, "TEST 1 FAILED!");
        else
            $display("TEST 1 PASSED: Stored and read 25");


        // TEST 2: Write 100 to address 12
        @(negedge clk);
        MemRead = 0;
        MemWrite = 1;
        address = 32'd12;
        WriteData = 32'd100;

        @(posedge clk);
        #1;

        MemWrite = 0;
        MemRead = 1;
        #1;

        if (ReadData !== 32'd100)
            $fatal(1, "TEST 2 FAILED!");
        else
            $display("TEST 2 PASSED: Stored and read 100");


        // TEST 3: Verify previous data remains
        address = 32'd8;
        #1;

        if (ReadData !== 32'd25)
            $fatal(1, "TEST 3 FAILED!");
        else
            $display("TEST 3 PASSED: Previous data preserved");


        // TEST 4: Disable reading
        MemRead = 0;
        #1;

        if (ReadData !== 32'd0)
            $fatal(1, "TEST 4 FAILED!");
        else
            $display("TEST 4 PASSED: Read disabled");


        $display("All Data Memory tests PASSED!");
        $finish;

    end

endmodule

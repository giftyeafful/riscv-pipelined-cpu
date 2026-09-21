module register_file_tb;

    logic clk;

    logic [4:0]  ReadAddr1;
    logic [4:0]  ReadAddr2;
    logic [31:0] ReadData1;
    logic [31:0] ReadData2;

    logic [4:0]  WriteAddr;
    logic [31:0] WriteData;
    logic        RegWrite;

    register_file dut (
        .clk(clk),
        .ReadAddr1(ReadAddr1),
        .ReadAddr2(ReadAddr2),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2),
        .WriteAddr(WriteAddr),
        .WriteData(WriteData),
        .RegWrite(RegWrite)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;

        // Write 123 into x5
        RegWrite = 1;
        WriteAddr = 5'd5;
        WriteData = 32'd123;

        @(posedge clk);
        #1;

        RegWrite = 0;

        // Read x5
        ReadAddr1 = 5'd5;

        #1;

        $display("READ x5 = %0d", ReadData1);

        if (ReadData1 != 32'd123)
            $display("ERROR: x5 read failed!");
        else
            $display("x5 read PASSED!");


         // Attempt to write 999 into x0
        RegWrite = 1;
        WriteAddr = 5'd0;
        WriteData = 32'd999;

        @(posedge clk);
        #1;

        RegWrite = 0;

        // Read x0
        ReadAddr1 = 5'd0;

        #1;

        $display("READ x0 = %0d", ReadData1);

        if (ReadData1 != 32'd0)
            $display("ERROR: x0 was modified!");
        else
            $display("x0 protection PASSED!");

        $finish;
    end

endmodule
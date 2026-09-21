module alu_tb;

    logic [31:0] A;
    logic [31:0] B;
    logic [2:0]  ALUControl;

    logic [31:0] Result;
    logic        Zero;

    alu dut (
        .A(A),
        .B(B),
        .ALUControl(ALUControl),
        .Result(Result),
        .Zero(Zero)
    );

    initial begin

        A = 32'd10;
        B = 32'd5;
        ALUControl = 3'b000;

        #1;

        $display("ADD: A=%0d B=%0d Result=%0d Zero=%b",
                 A, B, Result, Zero);

        if (Result != 32'd15)
            $display("ERROR: ADD test failed!");
        else
            $display("ADD test PASSED!");

        
        //SUB
        A = 32'd10;
        B = 32'd5;
        ALUControl = 3'b001;

        #1;

        $display("SUB: A=%0d B=%0d Result=%0d Zero=%b",
                 A, B, Result, Zero);

        if (Result != 32'd5)
            $display("ERROR: SUB test failed!");
        else
            $display("SUB test PASSED!");

        
        //AND
        A = 32'd10;
        B = 32'd5;
        ALUControl = 3'b010;

        #1

        $display ("AND: A=%0d B=%0d Result=%0d Zero=%b",
                 A, B, Result, Zero);
                
        if (Result != 32'd0)
            $display("ERROR: AND test failed!");
        else
            $display("AND test PASSED!");
        

         //OR
        A = 32'd10;
        B = 32'd5;
        ALUControl = 3'b011;

        #1

        $display ("OR: A=%0d B=%0d Result=%0d Zero=%b",
                 A, B, Result, Zero);

        if (Result != 32'd15)
            $display("ERROR: OR test failed!");
        else
            $display("OR test PASSED!");


        // XOR test
        A = 32'd10;
        B = 32'd5;
        ALUControl = 3'b100;

        #1;

        $display("XOR: A=%0d B=%0d Result=%0d Zero=%b",
                 A, B, Result, Zero);

        if (Result != 32'd15)
            $display("ERROR: XOR test failed!");
        else
            $display("XOR test PASSED!");


        
        // Zero detection test
        A = 32'd10;
        B = 32'd10;
        ALUControl = 3'b001;

        #1;

        $display("ZERO: A=%0d B=%0d Result=%0d Zero=%b",
                 A, B, Result, Zero);

        if (Result != 32'd0 || Zero != 1'b1)
            $display("ERROR: Zero detection test failed!");
        else
            $display("Zero detection test PASSED!");
        

        $finish;

    end

endmodule
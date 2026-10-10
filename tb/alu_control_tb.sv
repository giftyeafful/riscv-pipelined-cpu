
module alu_control_tb;

    logic [1:0] ALUOp;
    logic [2:0] funct3;
    logic funct7_bit30;
    logic is_r_type;
    logic [2:0] ALUControl;

    alu_control dut (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7_bit30(funct7_bit30),
        .is_r_type(is_r_type),
        .ALUControl(ALUControl)
    );

    task automatic check(
        input logic [1:0] op,
        input logic [2:0] f3,
        input logic bit30,
        input logic rtype,
        input logic [2:0] expected,
        input string test_name
    );
        ALUOp = op;
        funct3 = f3;
        funct7_bit30 = bit30;
        is_r_type = rtype;

        #1;

        if (ALUControl !== expected)
            $fatal(1, "%s FAILED: expected %b, got %b",
                   test_name, expected, ALUControl);
        else
            $display("%s PASSED!", test_name);
    endtask

    initial begin

        check(2'b00, 3'b000, 0, 0, 3'b000, "LW/SW ADD");
        check(2'b01, 3'b000, 0, 0, 3'b001, "BEQ SUB");

        check(2'b10, 3'b000, 0, 1, 3'b000, "R-type ADD");
        check(2'b10, 3'b000, 1, 1, 3'b001, "R-type SUB");

        check(2'b10, 3'b111, 0, 1, 3'b010, "R-type AND");
        check(2'b10, 3'b110, 0, 1, 3'b011, "R-type OR");
        check(2'b10, 3'b100, 0, 1, 3'b100, "R-type XOR");

        check(2'b10, 3'b000, 1, 0, 3'b000, "ADDI with bit30=1");

        $display("All ALU Control tests PASSED!");

        $finish;

    end

endmodule

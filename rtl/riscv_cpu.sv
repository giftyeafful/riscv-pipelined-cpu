
module riscv_cpu (
    input logic clk,
    input logic reset,

    output logic [31:0] PC_out
);

    logic [31:0] PC;
    logic [31:0] NextPC;
    logic [31:0] Instruction;

    logic [31:0] RD1;
    logic [31:0] RD2;
    logic [31:0] ImmExt;

    logic [31:0] ALU_B;
    logic [31:0] ALUResult;
    logic [31:0] MemoryReadData;
    logic [31:0] WriteBackData;

    logic Zero;

    logic RegWrite;
    logic ALUSrc;
    logic MemWrite;
    logic MemRead;
    logic [1:0] ResultSrc;
    logic Branch;
    logic Jump;
    logic [2:0] ImmType;
    logic [1:0] ALUOp;
    logic [2:0] ALUControl;

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic funct7_bit30;
    logic is_r_type;

    assign opcode = Instruction[6:0];
    assign funct3 = Instruction[14:12];
    assign funct7_bit30 = Instruction[30];
    assign is_r_type = (opcode == 7'b0110011);

    // Next sequential instruction
    assign NextPC = PC + 32'd4;

    assign PC_out = PC;

    // 1. Program Counter
    program_counter pc_unit (
        .clk(clk),
        .reset(reset),
        .NextPC(NextPC),
        .PC(PC)
    );

    // 2. Instruction Memory
    instruction_memory imem (
        .address(PC),
        .instruction(Instruction)
    );

    // 3. Control Unit
    control_unit cu (
        .opcode(opcode),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .ResultSrc(ResultSrc),
        .Branch(Branch),
        .Jump(Jump),
        .ImmType(ImmType),
        .ALUOp(ALUOp)
    );

    // 4. Register File
    register_file rf (
        .clk(clk),
        .ReadAddr1(Instruction[19:15]),
        .ReadAddr2(Instruction[24:20]),
        .ReadData1(RD1),
        .ReadData2(RD2),
        .WriteAddr(Instruction[11:7]),
        .WriteData(WriteBackData),
        .RegWrite(RegWrite && !reset)
    );  

    //5. Immediate Generator
    immediate_generator imm_gen (
         .instruction(Instruction),
         .ImmType(ImmType),
        .immediate(ImmExt)
     );

    // 6. ALU Control Decoder
    alu_control alu_decoder (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7_bit30(funct7_bit30),
        .is_r_type(is_r_type),
        .ALUControl(ALUControl)
    );


    //7. ALU Operand Multiplexer 
    assign ALU_B = ALUSrc ? ImmExt : RD2;


    //8. Arithmetic Logic Unit
    alu alu_unit (
        .A(RD1),
        .B(ALU_B),
        .ALUControl(ALUControl),
        .Result(ALUResult),
        .Zero(Zero)
    );

    //9. Data Memory
    data_memory dmem (
        .clk(clk),
        .MemWrite(MemWrite && !reset),
        .MemRead(MemRead),
        .address(ALUResult),
        .WriteData(RD2),
        .ReadData(MemoryReadData)
    );

    //10. Write-Back Multiplexer
     assign WriteBackData =
        (ResultSrc == 2'b01)
        ? MemoryReadData
        : ALUResult;

endmodule
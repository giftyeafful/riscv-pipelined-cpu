
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

    // Branch and Jump signals
    logic IsBEQ;
    logic IsJAL;
    logic IsJALR;
    logic BranchTaken;
    logic RegWriteFinal;

    logic [31:0] PCPlus4;
    logic [31:0] BranchImm;
    logic [31:0] JumpImm;
    logic [31:0] JalrImm;
    logic [31:0] BranchTarget;
    logic [31:0] JumpTarget;
    logic [31:0] JalrTarget;

    // Instruction fields
    assign opcode = Instruction[6:0];
    assign funct3 = Instruction[14:12];
    assign funct7_bit30 = Instruction[30];
    assign is_r_type = (opcode == 7'b0110011);

    // Branch and Jump decoding
    assign IsBEQ =
        (opcode == 7'b1100011) &&
        (funct3 == 3'b000);

    assign IsJAL =
        (opcode == 7'b1101111);

    assign IsJALR =
        (opcode == 7'b1100111) &&
        (funct3 == 3'b000);

    // Branch immediate (B-type)
    assign BranchImm = {
        {19{Instruction[31]}},
        Instruction[31],
        Instruction[7],
        Instruction[30:25],
        Instruction[11:8],
        1'b0
    };

    // Jump immediate (J-type)
    assign JumpImm = {
        {11{Instruction[31]}},
        Instruction[31],
        Instruction[19:12],
        Instruction[20],
        Instruction[30:21],
        1'b0
    };

    // JALR immediate (I-type)
    assign JalrImm = {
        {20{Instruction[31]}},
        Instruction[31:20]
    };

    // Next sequential instruction
    assign PCPlus4 = PC + 32'd4;

    // BEQ: branch if registers are equal
    assign BranchTaken = IsBEQ && (RD1 == RD2);

    // Branch and Jump target addresses
    assign BranchTarget = PC + BranchImm;
    assign JumpTarget = PC + JumpImm;

    assign JalrTarget =
        (RD1 + JalrImm) & 32'hFFFFFFFE;

    // Next PC selection
    always_comb begin
        NextPC = PCPlus4;

        if (BranchTaken)
            NextPC = BranchTarget;

        else if (IsJAL)
            NextPC = JumpTarget;

        else if (IsJALR)
            NextPC = JalrTarget;
    end

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

    // Register write enable
    assign RegWriteFinal =
        (RegWrite || IsJAL || IsJALR) && !reset;

    // 4. Register File
    register_file rf (
        .clk(clk),
        .ReadAddr1(Instruction[19:15]),
        .ReadAddr2(Instruction[24:20]),
        .ReadData1(RD1),
        .ReadData2(RD2),
        .WriteAddr(Instruction[11:7]),
        .WriteData(WriteBackData),
        .RegWrite(RegWriteFinal)
    );

    // 5. Immediate Generator
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

    // 7. ALU Operand Multiplexer
    assign ALU_B = ALUSrc ? ImmExt : RD2;

    // 8. Arithmetic Logic Unit
    alu alu_unit (
        .A(RD1),
        .B(ALU_B),
        .ALUControl(ALUControl),
        .Result(ALUResult),
        .Zero(Zero)
    );

    // 9. Data Memory
    data_memory dmem (
        .clk(clk),
        .MemWrite(MemWrite && !reset),
        .MemRead(MemRead),
        .address(ALUResult),
        .WriteData(RD2),
        .ReadData(MemoryReadData)
    );

    // 10. Write-Back Multiplexer
    always_comb begin
        if (IsJAL || IsJALR)
            WriteBackData = PCPlus4;

        else if (ResultSrc == 2'b01)
            WriteBackData = MemoryReadData;

        else
            WriteBackData = ALUResult;
    end

endmodule

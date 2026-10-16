
module riscv_pipelined_cpu (
    input  logic        clk,
    input  logic        reset,
    output logic [31:0] PC_out
);

    // ============================================
    // FETCH STAGE (F)
    // ============================================
    logic [31:0] PCF, PCNextF, PCPlus4F;
    logic [31:0] InstrF;

    logic StallF, StallD, FlushD, FlushE;
    logic PCSrcE;

    assign PCPlus4F = PCF + 32'd4;
    assign PC_out = PCF;

    program_counter pc_unit (
        .clk(clk),
        .reset(reset),
        .NextPC(PCNextF),
        .PC(PCF)
    );

    instruction_memory imem (
        .address(PCF),
        .instruction(InstrF)
    );

    // ============================================
    // IF/ID REGISTER
    // ============================================
    logic [31:0] PCD, InstrD;

    if_id_register if_id (
        .clk(clk),
        .reset(reset),
        .stall(StallD),
        .flush(FlushD),
        .PC_in(PCF),
        .Instruction_in(InstrF),
        .PC_out(PCD),
        .Instruction_out(InstrD)
    );

    // ============================================
    // DECODE STAGE (D)
    // ============================================
    logic [6:0] OpcodeD;
    logic [2:0] Funct3D;
    logic [4:0] Rs1D, Rs2D, RdD;
    logic UsesRs1D, UsesRs2D;

    logic [31:0] RD1D, RD2D;
    logic [31:0] RD1RawD, RD2RawD;
    logic [31:0] ImmExtD, ImmFromGenD;

    logic RegWriteD, ALUSrcD;
    logic MemWriteD, MemReadD;
    logic [1:0] ResultSrcD;
    logic BranchD, JumpD;
    logic [2:0] ImmTypeD;
    logic [1:0] ALUOpD;
    logic [2:0] ALUControlD;

    logic CURegWriteD, CUALUSrcD;
    logic CUMemWriteD, CUMemReadD;
    logic [1:0] CUResultSrcD;
    logic CUBranchD, CUJumpD;

    logic IsBEQD, IsJALD, IsJALRD;
    logic [31:0] BranchImmD, JumpImmD;

    assign OpcodeD = InstrD[6:0];
    assign Funct3D = InstrD[14:12];
    assign Rs1D = InstrD[19:15];
    assign Rs2D = InstrD[24:20];
    assign RdD = InstrD[11:7];

    assign IsBEQD =
        (OpcodeD == 7'b1100011) &&
        (Funct3D == 3'b000);

    assign IsJALD =
        (OpcodeD == 7'b1101111);

    assign IsJALRD =
        (OpcodeD == 7'b1100111) &&
        (Funct3D == 3'b000);

    // Which instructions actually read rs1 / rs2?
    always_comb begin
        UsesRs1D = 1'b0;
        UsesRs2D = 1'b0;

        case (OpcodeD)
            7'b0110011: begin // R-type
                UsesRs1D = 1'b1;
                UsesRs2D = 1'b1;
            end
            7'b0010011: UsesRs1D = 1'b1; // I-type ALU
            7'b0000011: UsesRs1D = 1'b1; // Load
            7'b0100011: begin             // Store
                UsesRs1D = 1'b1;
                UsesRs2D = 1'b1;
            end
            7'b1100011: begin             // Branch
                UsesRs1D = 1'b1;
                UsesRs2D = 1'b1;
            end
            7'b1100111: UsesRs1D = 1'b1; // JALR
            default: begin end
        endcase
    end

    control_unit cu (
        .opcode(OpcodeD),
        .RegWrite(CURegWriteD),
        .ALUSrc(CUALUSrcD),
        .MemWrite(CUMemWriteD),
        .MemRead(CUMemReadD),
        .ResultSrc(CUResultSrcD),
        .Branch(CUBranchD),
        .Jump(CUJumpD),
        .ImmType(ImmTypeD),
        .ALUOp(ALUOpD)
    );

    alu_control alu_decoder (
        .ALUOp(ALUOpD),
        .funct3(Funct3D),
        .funct7_bit30(InstrD[30]),
        .is_r_type(OpcodeD == 7'b0110011),
        .ALUControl(ALUControlD)
    );

    immediate_generator imm_gen (
        .instruction(InstrD),
        .ImmType(ImmTypeD),
        .immediate(ImmFromGenD)
    );

    // B-type and J-type immediates.
    assign BranchImmD = {
        {19{InstrD[31]}},
        InstrD[31],
        InstrD[7],
        InstrD[30:25],
        InstrD[11:8],
        1'b0
    };

    assign JumpImmD = {
        {11{InstrD[31]}},
        InstrD[31],
        InstrD[19:12],
        InstrD[20],
        InstrD[30:21],
        1'b0
    };

    // Explicit jump/branch handling.
    always_comb begin
        RegWriteD  = CURegWriteD;
        ALUSrcD    = CUALUSrcD;
        MemWriteD  = CUMemWriteD;
        MemReadD   = CUMemReadD;
        ResultSrcD = CUResultSrcD;
        BranchD    = CUBranchD;
        JumpD      = CUJumpD;
        ImmExtD    = ImmFromGenD;

        if (IsBEQD) begin
            RegWriteD  = 1'b0;
            MemWriteD  = 1'b0;
            MemReadD   = 1'b0;
            BranchD    = 1'b1;
            JumpD      = 1'b0;
            ImmExtD    = BranchImmD;
        end
        else if (IsJALD || IsJALRD) begin
            RegWriteD  = 1'b1;
            ALUSrcD    = 1'b1;
            MemWriteD  = 1'b0;
            MemReadD   = 1'b0;
            ResultSrcD = 2'b10;
            BranchD    = 1'b0;
            JumpD      = 1'b1;

            if (IsJALD)
                ImmExtD = JumpImmD;
            else
                ImmExtD = {
                    {20{InstrD[31]}},
                    InstrD[31:20]
                };
        end
    end

    // ============================================
    // WRITE-BACK SIGNALS (declared early because
    // the register file is used in Decode)
    // ============================================
    logic [31:0] WriteBackDataW;
    logic [4:0] RdW;
    logic RegWriteW;

    register_file rf (
        .clk(clk),
        .ReadAddr1(Rs1D),
        .ReadAddr2(Rs2D),
        .ReadData1(RD1RawD),
        .ReadData2(RD2RawD),
        .WriteAddr(RdW),
        .WriteData(WriteBackDataW),
        .RegWrite(RegWriteW && !reset)
    );

    // WB-to-ID bypass prevents reading stale data
    // when WB writes on the same clock edge.
    assign RD1D =
        (RegWriteW && RdW != 5'd0 && RdW == Rs1D)
        ? WriteBackDataW : RD1RawD;

    assign RD2D =
        (RegWriteW && RdW != 5'd0 && RdW == Rs2D)
        ? WriteBackDataW : RD2RawD;

    // ============================================
    // ID/EX REGISTER
    // ============================================
    logic [31:0] PCE, RD1E, RD2E, ImmExtE;
    logic [4:0] Rs1E, Rs2E, RdE;
    logic [2:0] ALUControlE;
    logic ALUSrcE, RegWriteE, MemWriteE, MemReadE;
    logic [1:0] ResultSrcE;
    logic BranchE, JumpE;

    id_ex_register id_ex (
        .clk(clk),
        .reset(reset),
        .flush(FlushE),
        .PC_in(PCD),
        .RD1_in(RD1D),
        .RD2_in(RD2D),
        .ImmExt_in(ImmExtD),
        .Rs1_in(Rs1D),
        .Rs2_in(Rs2D),
        .Rd_in(RdD),
        .ALUControl_in(ALUControlD),
        .ALUSrc_in(ALUSrcD),
        .RegWrite_in(RegWriteD),
        .MemWrite_in(MemWriteD),
        .MemRead_in(MemReadD),
        .ResultSrc_in(ResultSrcD),
        .Branch_in(BranchD),
        .Jump_in(JumpD),
        .PC_out(PCE),
        .RD1_out(RD1E),
        .RD2_out(RD2E),
        .ImmExt_out(ImmExtE),
        .Rs1_out(Rs1E),
        .Rs2_out(Rs2E),
        .Rd_out(RdE),
        .ALUControl_out(ALUControlE),
        .ALUSrc_out(ALUSrcE),
        .RegWrite_out(RegWriteE),
        .MemWrite_out(MemWriteE),
        .MemRead_out(MemReadE),
        .ResultSrc_out(ResultSrcE),
        .Branch_out(BranchE),
        .Jump_out(JumpE)
    );

    // Extra metadata needed to distinguish
    // JAL from JALR in the Execute stage.
    logic IsJALRE;

    always_ff @(posedge clk) begin
        if (reset || FlushE)
            IsJALRE <= 1'b0;
        else
            IsJALRE <= IsJALRD;
    end

    // ============================================
    // EXECUTE STAGE (E)
    // ============================================
    logic [1:0] ForwardA, ForwardB;
    logic [31:0] SrcAE, SrcBE, ForwardedBE;
    logic [31:0] ALUResultE, PCPlus4E;
    logic [31:0] PCTargetE;

    // EX/MEM stage signals
    logic [31:0] ALUResultM, WriteDataM, PCPlus4M;
    logic [4:0] RdM;
    logic RegWriteM, MemWriteM, MemReadM;
    logic [1:0] ResultSrcM;

    logic [31:0] ForwardDataM;

    assign ForwardDataM =
        (ResultSrcM == 2'b10)
        ? PCPlus4M : ALUResultM;

    forwarding_unit forward_unit (
        .Rs1E(Rs1E),
        .Rs2E(Rs2E),
        .RdM(RdM),
        .RdW(RdW),
        .RegWriteM(RegWriteM),
        .RegWriteW(RegWriteW),
        .ResultSrcM(ResultSrcM),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB)
    );

    always_comb begin
        case (ForwardA)
            2'b10: SrcAE = ForwardDataM;
            2'b01: SrcAE = WriteBackDataW;
            default: SrcAE = RD1E;
        endcase

        case (ForwardB)
            2'b10: ForwardedBE = ForwardDataM;
            2'b01: ForwardedBE = WriteBackDataW;
            default: ForwardedBE = RD2E;
        endcase
    end

    assign SrcBE = ALUSrcE ? ImmExtE : ForwardedBE;

    alu alu_unit (
        .A(SrcAE),
        .B(SrcBE),
        .ALUControl(ALUControlE),
        .Result(ALUResultE),
        .Zero(ZeroE)
    );

    assign PCPlus4E = PCE + 32'd4;

    // Branches and jumps resolve in Execute.
    assign PCSrcE =
        (BranchE && (SrcAE == ForwardedBE)) ||
        JumpE;

    assign PCTargetE =
        IsJALRE
        ? ((SrcAE + ImmExtE) & 32'hFFFFFFFE)
        : (PCE + ImmExtE);

    assign PCNextF =
        StallF ? PCF :
        PCSrcE ? PCTargetE :
        PCPlus4F;

    // ============================================
    // HAZARD DETECTION
    // ============================================
    hazard_detection_unit hazard_unit (
        .Rs1D(Rs1D),
        .Rs2D(Rs2D),
        .UsesRs1D(UsesRs1D),
        .UsesRs2D(UsesRs2D),
        .RdE(RdE),
        .MemReadE(MemReadE),
        .PCSrcE(PCSrcE),
        .StallF(StallF),
        .StallD(StallD),
        .FlushD(FlushD),
        .FlushE(FlushE)
    );

    // ============================================
    // EX/MEM REGISTER
    // ============================================
    ex_mem_register ex_mem (
        .clk(clk),
        .reset(reset),
        .flush(1'b0),
        .ALUResult_in(ALUResultE),
        .WriteData_in(ForwardedBE),
        .PCPlus4_in(PCPlus4E),
        .Rd_in(RdE),
        .RegWrite_in(RegWriteE),
        .MemWrite_in(MemWriteE),
        .MemRead_in(MemReadE),
        .ResultSrc_in(ResultSrcE),
        .ALUResult_out(ALUResultM),
        .WriteData_out(WriteDataM),
        .PCPlus4_out(PCPlus4M),
        .Rd_out(RdM),
        .RegWrite_out(RegWriteM),
        .MemWrite_out(MemWriteM),
        .MemRead_out(MemReadM),
        .ResultSrc_out(ResultSrcM)
    );

    // ============================================
    // MEMORY STAGE (M)
    // ============================================
    logic [31:0] ReadDataM;

    data_memory dmem (
        .clk(clk),
        .MemWrite(MemWriteM && !reset),
        .MemRead(MemReadM),
        .address(ALUResultM),
        .WriteData(WriteDataM),
        .ReadData(ReadDataM)
    );

    // ============================================
    // MEM/WB REGISTER
    // ============================================
    logic [31:0] ALUResultW;
    logic [31:0] ReadDataW;
    logic [31:0] PCPlus4W;
    logic [1:0] ResultSrcW;

    mem_wb_register mem_wb (
        .clk(clk),
        .reset(reset),
        .flush(1'b0),
        .ALUResult_in(ALUResultM),
        .ReadData_in(ReadDataM),
        .PCPlus4_in(PCPlus4M),
        .Rd_in(RdM),
        .RegWrite_in(RegWriteM),
        .ResultSrc_in(ResultSrcM),
        .ALUResult_out(ALUResultW),
        .ReadData_out(ReadDataW),
        .PCPlus4_out(PCPlus4W),
        .Rd_out(RdW),
        .RegWrite_out(RegWriteW),
        .ResultSrc_out(ResultSrcW)
    );

    // ============================================
    // WRITE-BACK STAGE (W)
    // ============================================
    always_comb begin
        case (ResultSrcW)
            2'b01: WriteBackDataW = ReadDataW;
            2'b10: WriteBackDataW = PCPlus4W;
            default: WriteBackDataW = ALUResultW;
        endcase
    end

endmodule

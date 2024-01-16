`timescale 1us / 1us
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/25 20:27:06
// Design Name: 
// Module Name: TopLevel
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "settings.sv"

module TopLevel(input wire reset, input wire clock);

    Instruction instr;
    ControlSignals signals;
    
    reg [31:0] instructions[1023:0];
    reg [31:0] IP, nextIP, IPplus4;
        
    wire [31:0] readResult;
    reg [31:0] writeInput; 
    reg [4:0] rs, rt, rd;
    reg [31:0] rsval, rtval, imm32; 
    
    reg jumpEnabled = 1;
    reg writeEnabled;
    reg MemoryWriteEnabled;
    reg goBranch, RealBranch;
    reg ZF; //zero flag，零标志位
    
    reg [3:0] ALUop;
    reg [31:0] ALUresult;
    reg [3:0] ALUCalculateop;
    reg [31:0] Mduresult;
     
    reg flush, BranchPrediction, Mdubusy, Mduflush;
    wire [1:0] ForwardA, ForwardB, RsValueInID, RtValueInID;
    reg [31:0] fd;

    initial begin
        $readmemh("./code.txt", instructions);
        if(fd <= 0)
            $stop;
    end;

    PipelineReg IFtoID, IDtoEX, EXtoMEM, MEMtoWB, nextIFtoID, nextIDtoEX, nextEXtoMEM, nextMEMtoWB;

    PipelineRegister IFID(.reset(reset), .clock(clock), .in(nextIFtoID), .out(IFtoID) );
    PipelineRegister IDEX(.reset(reset | flush), .clock(clock), .in(Mduflush ? nextEXtoMEM : nextIDtoEX), .out(IDtoEX) );
    PipelineRegister EXMEM(.reset(reset | Mduflush), .clock(clock), .in(nextEXtoMEM), .out(EXtoMEM) );
    PipelineRegister MEMWB(.reset(reset), .clock(clock), .in(nextMEMtoWB), .out(MEMtoWB));

    ForwardingUnit FU( .IDtoEX(IDtoEX), .EXtoMEM(EXtoMEM), .MEMtoWB(MEMtoWB), .nextIDtoEX(nextIDtoEX), .ForwardA(ForwardA), .ForwardB(ForwardB), .RsValueInID(RsValueInID), .RtValueInID(RtValueInID));
    HazardDetectionUnit HDU(.Mdubusy(Mdubusy), .IFtoID(IFtoID), .IDtoEX(IDtoEX), .EXtoMEM(EXtoMEM), .MEMtoWB(MEMtoWB), .nextIDtoEX(nextIDtoEX), .flush(flush), .Mduflush(Mduflush));

    ProgramCounter PC(.reset(reset), .clock(clock), .jumpEnabled(jumpEnabled), .jumpInput(nextIP), .pcValue(IP));
    ControllerUnit CU(.ins(IFtoID.instr), .sig(signals));
    GeneralPurposeRegisters GPR(.fd(fd), .reset(reset), .clock(clock), .rs(nextIDtoEX.rs), .rt(nextIDtoEX.rt), .rd(MEMtoWB.rd), .writeEnabled(writeEnabled), .writeInput(MEMtoWB.RdValue), .rsvalue(rsval), .rtvalue(rtval), .pcValue(MEMtoWB.pc));
    ALU ALU(.x(nextEXtoMEM.RsValue), .y(nextEXtoMEM.ALUInput), .signals(IDtoEX.ALUCalculateop), .result(ALUresult), .ZF(ZF));
    DataMemory DM(.fd(fd), .signal(EXtoMEM.signals), .reset(reset), .clock(clock), .address(EXtoMEM.RdValue), .writeEnabled(MemoryWriteEnabled), .writeInput(EXtoMEM.RtValue), .result(readResult), .pcValue(EXtoMEM.pc));
    MultiplicationDivisionUnit MDU(.reset(reset), .clock(clock), .operand1(nextEXtoMEM.RsValue), .operand2(nextEXtoMEM.ALUInput), .operation(IDtoEX.signals.Mduop), .start(IDtoEX.signals.MduStart & (IDtoEX.signals.Mduop > MDU_WRITE_LO)), .busy(Mdubusy), .dataRead(Mduresult));

     
    assign instr = instructions[nextIFtoID.pc[11:2]];
    assign IPplus4 = IFtoID.pc + 4;
    assign rs = instr.R.rs;
    assign rt = instr.R.rt;
    assign imm32 = {{16{instr.I.imm[15]}}, instr.I.imm}; // 符号位拓展
    
    always @(*) begin
        if (MEMtoWB.signals.Finish) 
            $finish;
    end

    always @(*) begin     
        nextIFtoID = 0;
        nextIFtoID.instr = instr;
        if (flush | Mduflush)
            nextIFtoID.pc = IFtoID.pc;
        else if(BranchPrediction) 
            nextIFtoID.pc = IFtoID.pc + 4;
        else 
            nextIFtoID.pc = IP;
    end

    always @(*) begin
        writeEnabled = MEMtoWB.signals.RegWrite & (~MEMtoWB.LastJumped);
    end
    

    always @(*) begin
        case(nextIDtoEX.signals.ALUop)
            4'b0001: goBranch = (nextIDtoEX.RsValue == nextIDtoEX.RtValue);
            4'b0010: goBranch = (nextIDtoEX.RsValue != nextIDtoEX.RtValue);
            4'b0011: goBranch = ($signed(nextIDtoEX.RsValue) <= 0);
            4'b0100: goBranch = ($signed(nextIDtoEX.RsValue) > 0);
            4'b0101: goBranch = ($signed(nextIDtoEX.RsValue) >= 0);
            4'b0110: goBranch = ($signed(nextIDtoEX.RsValue) < 0);
        endcase
    end

    
    //ID stage
    always @(*) begin
        nextIDtoEX = IFtoID;
        nextIDtoEX.signals = signals;
        nextIDtoEX.ImmValue = {{16{IFtoID.instr.I.imm[15] & nextIDtoEX.signals.SignExt}}, IFtoID.instr.I.imm};        
        nextIDtoEX.ALUCalculateop = nextIDtoEX.signals.ALUCalculateop;
        nextIDtoEX.Jumped = 0;
        nextIFtoID.LastJumped = 0;
       
        if(nextIDtoEX.signals.WriteToRa) begin
            if(nextIDtoEX.signals.JumpReg) begin
                nextIDtoEX.rs = IFtoID.instr.R.rs;
                nextIDtoEX.rt = 0;
                nextIDtoEX.rd = IFtoID.instr.R.rd;
            end 
            else begin
                nextIDtoEX.rs = 0;
                nextIDtoEX.rt = 0;
                nextIDtoEX.rd = 5'b11111;
            end 
        end
        else if(nextIDtoEX.signals.shift) begin
            nextIDtoEX.rs = IFtoID.instr.R.rt;
            nextIDtoEX.rt = IFtoID.instr.R.rs;
            nextIDtoEX.rd = IFtoID.instr.R.rd;
        end
        else if(nextIDtoEX.signals.WriteToRdRt || nextIDtoEX.signals.MemoryWrite || nextIDtoEX.signals.Branch || nextIDtoEX.signals.MduStart) begin
            nextIDtoEX.rs = IFtoID.instr.R.rs;
            nextIDtoEX.rt = IFtoID.instr.R.rt;
            nextIDtoEX.rd = IFtoID.instr.R.rd;
        end
        else begin
            nextIDtoEX.rs = IFtoID.instr.R.rs;
            nextIDtoEX.rt = 0;
            nextIDtoEX.rd = IFtoID.instr.R.rt;
        end
        
        case (RsValueInID)
            2'b00: nextIDtoEX.RsValue = rsval;
            2'b01: nextIDtoEX.RsValue = MEMtoWB.RdValue;
            2'b10: nextIDtoEX.RsValue = EXtoMEM.RdValue; 
            2'b11: nextIDtoEX.RsValue = IDtoEX.RdValue; 
        endcase
        
        case (RtValueInID)
            2'b00: nextIDtoEX.RtValue = rtval;
            2'b01: nextIDtoEX.RtValue = MEMtoWB.RdValue;
            2'b10: nextIDtoEX.RtValue = EXtoMEM.RdValue; 
            2'b11: nextIDtoEX.RtValue = IDtoEX.RdValue; 
        endcase            
        
        if(flush | Mduflush) 
            nextIP = nextIFtoID.pc + 4;
        else if(BranchPrediction) begin
            nextIP = nextIFtoID.pc + 4;
        end   
        else if(nextIDtoEX.signals.Jump) begin
            if(nextIDtoEX.signals.JumpReg)
                nextIP = nextIDtoEX.RsValue;
            else if(!nextEXtoMEM.Jumped)
                nextIP = {IPplus4[31:28], IFtoID.instr.J.addr[25:0], 2'b00};
        end
        else if (nextIDtoEX.signals.Branch) begin
            if(IDtoEX.signals.RegWrite && (IDtoEX.rd) && (IDtoEX.rd == nextIDtoEX.rs || IDtoEX.rd == nextIDtoEX.rt))
                nextIP = IFtoID.pc + 4 + {nextIDtoEX.ImmValue[29:0],2'b00};
            else if(goBranch)
                nextIP = IFtoID.pc + 4 + {nextIDtoEX.ImmValue[29:0],2'b00}; 
            else
                nextIP = nextIFtoID.pc + 4;
        end
        else 
            nextIP = nextIFtoID.pc + 4;    
            
    end

    //EX stage
    always@ (*) begin
        nextEXtoMEM = IDtoEX;
        nextEXtoMEM.ALU_zero = ZF;
        nextEXtoMEM.RdValue = ALUresult;
        
        case (ForwardA)
            2'b00: nextEXtoMEM.RsValue = IDtoEX.RsValue;
            2'b01: nextEXtoMEM.RsValue = MEMtoWB.RdValue;
            2'b10: nextEXtoMEM.RsValue = EXtoMEM.RdValue; 
        endcase
        
        case (ForwardB)
            2'b00: nextEXtoMEM.RtValue = IDtoEX.RtValue;
            2'b01: nextEXtoMEM.RtValue = MEMtoWB.RdValue;
            2'b10: nextEXtoMEM.RtValue = EXtoMEM.RdValue; 
        endcase
       
        if(IDtoEX.signals.ALUNeedImm) begin
            if(IDtoEX.signals.ImmToReg) 
                nextEXtoMEM.ALUInput = {IDtoEX.instr.I.imm, 16'b0};
            else 
                nextEXtoMEM.ALUInput = IDtoEX.ImmValue;
        end
        else if(IDtoEX.signals.shift) begin
            if(IDtoEX.signals.shift_sa) 
                nextEXtoMEM.ALUInput = IDtoEX.instr.R.padding;
            else 
                nextEXtoMEM.ALUInput = {{27{(1'b0)}}, nextEXtoMEM.RtValue[4:0]};
        end
        else if(IDtoEX.signals.WriteToRa) 
            nextEXtoMEM.ALUInput = IDtoEX.pc + 8 - nextEXtoMEM.RsValue;
        else 
            nextEXtoMEM.ALUInput = nextEXtoMEM.RtValue;
            
        if(IDtoEX.signals.MduStart & (IDtoEX.signals.Mduop < MDU_WRITE_HI)) 
            nextEXtoMEM.RdValue = Mduresult;
        else  
            nextEXtoMEM.RdValue = ALUresult;     
            
        MemoryWriteEnabled = EXtoMEM.signals.MemoryWrite;
        

        // verify whether the branch predition is correct       
        if(nextEXtoMEM.signals.Branch && (ForwardA == 2'b10 || ForwardB == 2'b10)) begin
            case(nextEXtoMEM.signals.ALUop)
                4'b0001: RealBranch = (nextEXtoMEM.RsValue == nextEXtoMEM.RtValue);
                4'b0010: RealBranch = (nextEXtoMEM.RsValue != nextEXtoMEM.RtValue);
                4'b0011: RealBranch = ($signed(nextEXtoMEM.RsValue) <= 0);
                4'b0100: RealBranch = ($signed(nextEXtoMEM.RsValue) > 0);
                4'b0101: RealBranch = ($signed(nextEXtoMEM.RsValue) >= 0);
                4'b0110: RealBranch = ($signed(nextEXtoMEM.RsValue) < 0);
            endcase
            
            if(!RealBranch) begin
                BranchPrediction = 1;
            end
            else
                BranchPrediction = 0;    
        end
        else
            BranchPrediction = 0;
         
    end

    always @(*)
    begin
        ALUop = nextIDtoEX.signals.ALUop;
    end

    wire [7:0] tempB;
    wire [15:0] tempH;
    wire [4:0] bias;
    
    assign bias = EXtoMEM.RdValue[1:0] << 3;
    assign tempB = readResult[(bias + 7)-:8];
    assign tempH = readResult[(bias + 15)-:16]; 

    //MEM stage
    always @(*) begin
        nextMEMtoWB = EXtoMEM;
        if(EXtoMEM.signals.MemoryToReg) begin
            if(EXtoMEM.signals.MemSize == 'b01) begin //LB  or LBU
                if(EXtoMEM.signals.MemExt) begin //LB
                    nextMEMtoWB.RdValue = {{24{tempB[7]}}, tempB};
                end
                else begin //LBU
                    nextMEMtoWB.RdValue = {{24'b0}, tempB};
                end                      
            end
            else if(EXtoMEM.signals.MemSize == 'b10) begin //LH  or LHU
                if(EXtoMEM.signals.MemExt) begin //LH
                    nextMEMtoWB.RdValue = {{16{tempH[15]}}, tempH};
                end
                else begin //LHU
                    nextMEMtoWB.RdValue = {{16'b0}, tempH};
                end                      
            end
            else if(EXtoMEM.signals.MemSize == 'b11) //LW
                nextMEMtoWB.RdValue = readResult;     
        end    
    end

endmodule


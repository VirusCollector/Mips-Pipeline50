`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/25 20:34:26
// Design Name: 
// Module Name: settings
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


`ifndef MyCPU
`define MyCPU
`include "MultiplicationDivisionUnit.sv"


typedef struct packed
{
    logic WriteToRdRt;
    logic ALUNeedImm;
    logic MemoryToReg;
    logic RegWrite;
    logic MemoryRead;
    logic MemoryWrite;
    logic Jump;
    logic JumpReg;
    logic Branch;
    logic [3:0] ALUop;
    logic [3:0] ALUCalculateop;
    logic WriteToRa;
    logic ImmToReg;
    logic SignExt;
    logic Finish;
    mdu_operation_t Mduop;
    logic MduStart;
    logic shift_sa;
    logic shift;
    logic [1:0] MemSize;
    logic MemExt;
    logic [1:0] RegSize;
} ControlSignals;

typedef struct packed
{
    logic [5:0] op;
    logic [4:0] rs;
    logic [4:0] rt;
    logic [4:0] rd;
    logic [4:0] padding;
    logic [5:0] func;
} R_type;

typedef struct packed
{
    logic [5:0] op;
    logic [4:0] rs;
    logic [4:0] rt;
    logic [15:0] imm;
} I_type;

typedef struct packed
{
    logic [5:0] op;
    logic [25:0] addr;
} J_type;

typedef union packed
{
    R_type R;
    I_type I;
    J_type J;
} Instruction;


typedef struct packed 
{
    Instruction instr;
    ControlSignals signals;
    logic [3:0] ALUCalculateop;
    logic ALU_zero;
    logic [31:0] pc;
    logic [31:0] RsValue, RtValue, RdValue;
    logic [31:0] ImmValue;
    logic [31:0] ALUInput;
    logic [4:0] rs, rt, rd;
    logic Jumped;
    logic LastJumped;
    logic [1:0] MemSize;
} PipelineReg;

`endif
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/25 20:57:48
// Design Name: 
// Module Name: ForwardingUnit
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

`timescale 1us / 1us
`include "settings.sv"

module ForwardingUnit
(
input PipelineReg IDtoEX, input PipelineReg EXtoMEM, input PipelineReg MEMtoWB, input PipelineReg nextIDtoEX,
output reg[1:0] ForwardA, output reg[1:0] ForwardB, output reg[1:0] RsValueInID, output reg[1:0] RtValueInID
);

always @(*) begin
    if(EXtoMEM.signals.RegWrite && EXtoMEM.rd && EXtoMEM.rd == IDtoEX.rs)  
        ForwardA = 2'b10;
    else if(MEMtoWB.signals.RegWrite && MEMtoWB.rd && MEMtoWB.rd == IDtoEX.rs) 
        ForwardA = 2'b01;
    else 
        ForwardA = 2'b00;
        
    if(EXtoMEM.signals.RegWrite && EXtoMEM.rd && EXtoMEM.rd == IDtoEX.rt)  
        ForwardB = 2'b10;
    else if(MEMtoWB.signals.RegWrite && MEMtoWB.rd && MEMtoWB.rd == IDtoEX.rt) 
        ForwardB = 2'b01;
    else 
        ForwardB = 2'b00;

    if(IDtoEX.signals.RegWrite && IDtoEX.rd && IDtoEX.rd == nextIDtoEX.rs)  
        RsValueInID = 2'b11;
    else if(EXtoMEM.signals.RegWrite && EXtoMEM.rd && EXtoMEM.rd == nextIDtoEX.rs) 
        RsValueInID = 2'b10;
    else if(MEMtoWB.signals.RegWrite && MEMtoWB.rd && MEMtoWB.rd == nextIDtoEX.rs) 
        RsValueInID = 2'b01;
    else 
        RsValueInID = 2'b00;
        
    if(IDtoEX.signals.RegWrite && IDtoEX.rd && IDtoEX.rd == nextIDtoEX.rt)  
        RtValueInID = 2'b11;
    else if(EXtoMEM.signals.RegWrite && EXtoMEM.rd && EXtoMEM.rd == nextIDtoEX.rt) 
        RtValueInID = 2'b10;
    else if(MEMtoWB.signals.RegWrite && MEMtoWB.rd && MEMtoWB.rd == nextIDtoEX.rt)
        RtValueInID = 2'b01;
    else 
        RtValueInID = 2'b00;
    end
    
endmodule

`timescale 1us / 1us
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/25 20:51:51
// Design Name: 
// Module Name: HazardDetectionUnit
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

module HazardDetectionUnit
(
input Mdubusy, input PipelineReg IFtoID, input PipelineReg IDtoEX, input PipelineReg EXtoMEM, 
input PipelineReg MEMtoWB, input PipelineReg nextIDtoEX, output reg flush, output reg Mduflush
);
    
always @(*)
    begin
        //MemoryRead equals to LW
        if(IDtoEX.signals.MemoryRead && (IDtoEX.rd == nextIDtoEX.rs || IDtoEX.rd == nextIDtoEX.rt)) begin
            flush = 1;
        end
        else if (EXtoMEM.signals.MemoryRead && (EXtoMEM.rd == nextIDtoEX.rs || EXtoMEM.rd == nextIDtoEX.rt) && (nextIDtoEX.signals.Branch || nextIDtoEX.signals.JumpReg)) begin
            flush = 1;
        end
        else if(IDtoEX.signals.RegWrite && (IDtoEX.rd) && (IDtoEX.rd == nextIDtoEX.rs || IDtoEX.rd == nextIDtoEX.rt) && (nextIDtoEX.signals.JumpReg)) begin
            flush = 1;
        end
        else begin
            flush = 0;   
        end  
        
        if ((Mdubusy & IDtoEX.signals.MduStart) == 1 ) 
            Mduflush = 1;
        else 
            Mduflush = 0;
    end

endmodule

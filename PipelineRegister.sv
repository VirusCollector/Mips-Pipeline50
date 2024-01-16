`timescale 1us / 1us
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/25 20:58:38
// Design Name: 
// Module Name: PipelineRegister
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
 
module PipelineRegister(input reset, input clock, input PipelineReg in, output PipelineReg out);
    reg [$bits(PipelineReg)-1:0] result;
    assign out = result;
    
    always @(posedge clock)
    begin
        if (reset) 
            result <= 0;
        else 
            result <= in;
    end
endmodule

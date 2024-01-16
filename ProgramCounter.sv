`timescale 1us / 1us
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/25 20:37:23
// Design Name: 
// Module Name: ProgramCounter
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


module ProgramCounter(input reset, input clock, input jumpEnabled, input [31:0]jumpInput, output reg [31:0]pcValue);
    
always @(posedge clock)begin
    if(reset)
        pcValue <= 'h3000;
    else if(jumpEnabled)
        pcValue = {16'b0, jumpInput[15:0]};
    else 
        pcValue <= pcValue+4;
end
endmodule





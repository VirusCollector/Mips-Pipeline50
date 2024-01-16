`timescale 1us / 1us
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/25 20:54:11
// Design Name: 
// Module Name: ArithmeticLogicUnit
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

module ALU(input reg[31:0] x, input reg[31:0] y, input reg[3:0] signals, output reg [31:0] result, output reg ZF);  
    always@ (*) begin
        case(signals)
            4'b1000 : result = x << y;
            4'b1001 : result = x >> y;
            4'b1011 : result = ($signed(x)) >>> y;
            4'b0010 : result = x + y;
            4'b0110 : result = x - y;
            4'b0000 : result = x & y;
            4'b0001 : result = x | y;
            4'b0011 : result = x ^ y;
            4'b0100 : result = ~(x | y);
            4'b0111 : result = $signed(x) < $signed(y);
            4'b0101 : result = x < y;
        endcase
        
        if (result) 
            ZF = 0;
        else 
            ZF = 1;
    end
    
endmodule



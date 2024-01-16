`timescale 1us / 1us
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/25 20:44:19
// Design Name: 
// Module Name: GeneralPurposeRegisters
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

module GeneralPurposeRegisters
(
input [31:0] fd,
input reset, input clock, input [31:0] pcValue, input [31:0]writeInput,
input writeEnabled, input [4:0] rs, input [4:0]rt, input [4:0] rd, output reg[31:0] rsvalue, output reg[31:0] rtvalue
);
integer k = 0;
reg[31:0] regs[31:0];
assign rsvalue = regs[rs];
assign rtvalue = regs[rt];

always @ (negedge clock) begin
        if (reset) begin
            for ( integer i = 0; i < 32; i = i + 1 )
                regs[i] <= 0;
            regs[28] = 'h1800;
            regs[29] = 'h1000;
        end
        if (writeEnabled) begin
            if(k++ > 0) begin
                if(fd == 0)
                    $stop;
                if (rd && !$isunknown(writeInput)) begin
                    regs[rd] <= writeInput; 
                    $display("@%h: $%d <= %h", pcValue, rd, writeInput);
                    //$fdisplay(fd, "@%h: $%d <= %h", pcValue, rd, writeInput);
                end
                else begin
                    $display("@%h: $%d <= %h", pcValue, rd, writeInput);
                    //$fdisplay(fd, "@%h: $%d <= %h", pcValue, rd, writeInput);
                end
            end
        end
    end

endmodule



`timescale 1us / 1us
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/25 20:38:24
// Design Name: 
// Module Name: DataMemory
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

module DataMemory
(
input [31:0] fd, input ControlSignals signal,
input wire reset, input wire clock, input wire writeEnabled, input wire [31:0] pcValue, input wire [31:0]address, 
input wire [31:0] writeInput, output wire [31:0] result
);

reg [31:0] data[2047:0];
reg [7:0] tempB;
reg [15:0] tempH;
reg [31:0] ans;
wire [7:0] tempAddress;
wire [31:0] writeAddr;

assign result = data[address[31:2]];
assign tempAddress = (address[1:0] << 3);
assign writeAddr = address[31:2] << 2;

always @(posedge clock)
    begin
        if(reset) begin
            for(integer i = 0; i<2048 ; i = i + 1)
                data[i] <= 0;
        end
        else if(writeEnabled) begin //write
            if(signal.RegSize == 'b11) begin//SW
                data[address[31:2]] <= writeInput;           
                $display("@%h: *%h <= %h", pcValue, address, writeInput);
                //$fdisplay(fd, "@%h: *%h <= %h", pcValue, address, writeInput);
            end
            else if(signal.RegSize == 'b01) begin //SB
                data[address[31:2]][(tempAddress + 7)-:8] <= writeInput[7:0];
                if(address[1:0]) begin
                    $display("@%h: *%h <= %h", pcValue, writeAddr, (data[address[31:2]] & ~(8'hFF << tempAddress)) | (writeInput[7:0] << tempAddress));
                    //$fdisplay(fd, "@%h: *%h <= %h", pcValue, writeAddr, (data[address[31:2]] & ~(8'hFF << tempAddress)) | (writeInput[7:0] << tempAddress));
                end
                else begin
                    $display("@%h: *%h <= %h", pcValue, writeAddr, (data[address[31:2]] & ~8'hFF) | (writeInput[7:0]));
                    //$fdisplay(fd, "@%h: *%h <= %h", pcValue, writeAddr, (data[address[31:2]] & ~8'hFF) | (writeInput[7:0]));
                end           
            end
            else if(signal.RegSize == 'b10) begin //SH
                data[address[31:2]][(tempAddress + 15)-:16] <= writeInput[15:0];
                if(address[1:0]) begin
                    $display("@%h: *%h <= %h", pcValue, writeAddr, (data[address[31:2]] & ~(16'hFFFF << tempAddress)) | (writeInput[15:0] << tempAddress));
                    //$fdisplay(fd, "@%h: *%h <= %h", pcValue, writeAddr, (data[address[31:2]] & ~(16'hFFFF << tempAddress)) | (writeInput[15:0] << tempAddress));
                end    
                else begin
                    $display("@%h: *%h <= %h", pcValue, writeAddr, (data[address[31:2]] & ~16'hFFFF) | (writeInput[15:0]));
                    //$fdisplay(fd, "@%h: *%h <= %h", pcValue, writeAddr, (data[address[31:2]] & ~16'hFFFF) | (writeInput[15:0]));     
                end                           
            end
        end
    end

endmodule

`timescale 1us / 1us
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/25 20:50:46
// Design Name: 
// Module Name: ControllerUnit
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

module ControllerUnit(input Instruction ins, output ControlSignals sig);

always @(*) 
begin
	sig = 0;
        if(ins != 0) begin     
            case(ins.R.op)      	
            	6'b100000: begin //LB
                    sig.ALUNeedImm = 1;
                    sig.MemoryToReg = 1;
                    sig.RegWrite = 1;
                    sig.MemoryRead = 1;
                    sig.SignExt = 1;
                    sig.MemSize = 'b01;
                    sig.MemExt = 1;
                    sig.ALUCalculateop = 4'b0010;
                end
                
                6'b100100: begin //LBU
                    sig.ALUNeedImm = 1;
                    sig.MemoryToReg = 1;
                    sig.RegWrite = 1;
                    sig.MemoryRead = 1;
                    sig.SignExt = 1;
                    sig.MemSize = 'b01;
                    sig.ALUCalculateop = 4'b0010;
                end
                
                6'b100001: begin //LH
                    sig.ALUNeedImm = 1;
                    sig.MemoryToReg = 1;
                    sig.RegWrite = 1;
                    sig.MemoryRead = 1;
                    sig.SignExt = 1;
                    sig.MemSize = 'b10;
                    sig.MemExt = 1;
                    sig.ALUCalculateop = 4'b0010;
                end
                
                6'b100101: begin //LHU
                    sig.ALUNeedImm = 1;
                    sig.MemoryToReg = 1;
                    sig.RegWrite = 1;
                    sig.MemoryRead = 1;
                    sig.SignExt = 1;
                    sig.MemSize = 'b10;
                    sig.ALUCalculateop = 4'b0010;
                end
            	
            	6'b100011: begin //LW
            		sig.ALUNeedImm = 1;
                    sig.RegWrite = 1;
                    sig.MemoryToReg = 1;
                    sig.MemoryRead = 1;
                    sig.SignExt = 1;
                    sig.MemSize = 'b11;
                    sig.ALUCalculateop = 4'b0010;
                    
                end
                
                6'b101000: begin //SB
                    sig.ALUNeedImm = 1;
                    sig.MemoryWrite = 1;
                    sig.SignExt = 1;
                    sig.RegSize = 'b01;
                    sig.ALUCalculateop = 4'b0010;
                end
                
                6'b101001: begin //SH
                    sig.ALUNeedImm = 1;
                    sig.MemoryWrite = 1;
                    sig.SignExt = 1;
                    sig.RegSize = 'b10;
                    sig.ALUCalculateop = 4'b0010;
                end
                
                6'b101011: begin //SW
                	sig.ALUNeedImm = 1;
                	sig.MemoryWrite = 1;
                    sig.SignExt = 1;
                    sig.RegSize = 'b11;
                    sig.ALUCalculateop = 4'b0010;
                end
                    
                 6'b000100: begin //BEQ
                 	sig.Branch = 1;
                    sig.ALUop = 4'b0001;
                    //sig.ALUCalculateop = 4'b0110;
                    sig.SignExt = 1;
                end
                
                6'b000101: begin //BNE
                    sig.Branch = 1;
                    sig.ALUop = 4'b0010;
                    //sig.ALUCalculateop = 4'b0110;
                    sig.SignExt = 1;
                end
                
                6'b000110: begin //BLEZ
                    sig.Branch = 1;
                    sig.ALUop = 4'b0011;
                    sig.SignExt = 1;
                end
                
                6'b000111: begin //BGTZ
                    sig.Branch = 1;
                    sig.ALUop = 4'b0100;
                    sig.SignExt = 1;
                end
                
                6'b000001: begin //BGEZ and BLTZ
                    sig.Branch = 1;
                    sig.SignExt = 1;
                    if(ins.R.rt == 5'b00001) 
                        sig.ALUop = 4'b0101;
                    else 
                        sig.ALUop = 4'b0110;
                end	
                
                6'b001111: begin //LUI
                    sig.ALUop = 4'b1010;
                    sig.ALUCalculateop = 4'b0001;
                	sig.ALUNeedImm = 1;
                    sig.RegWrite = 1;
                    sig.ImmToReg = 1;
                end
                
                6'b000011: begin //JAL
                    sig.Jump = 1;
                    sig.RegWrite = 1;
                    sig.WriteToRa = 1;
                    sig.ALUCalculateop = 4'b0010;
                end
                
				6'b000010: begin  //J
					sig.Jump = 1;
					sig.ALUCalculateop = 4'b0010;
				end
				
				6'b001000: begin //ADDI
                    sig.ALUNeedImm = 1;
                    sig.RegWrite = 1;
                    sig.SignExt = 1;
                    sig.ALUCalculateop = 4'b0010;
                end
                
                6'b001001: begin //ADDIU
                    sig.ALUNeedImm = 1;
                    sig.RegWrite = 1;
                    sig.SignExt = 1;
                    sig.ALUCalculateop = 4'b0010;
                end
                
                6'b001100: begin //ANDI
                    sig.ALUNeedImm = 1;
                    sig.RegWrite = 1;
                    sig.ALUop = 4'b1001;
                    sig.ALUCalculateop = 4'b0000;
                end
                
                6'b001101: begin //ORI
                    sig.ALUNeedImm = 1;
                    sig.RegWrite = 1;
                    sig.ALUop = 4'b1010;
                    sig.ALUCalculateop = 4'b0001;
                end
                
                6'b001110: begin //XORI
                    sig.ALUNeedImm = 1;
                    sig.RegWrite = 1;
                    sig.ALUop = 4'b1011;
                    sig.ALUCalculateop = 4'b0011;
                end
                
                6'b001010: begin //SLTI
                    sig.ALUNeedImm = 1;
                    sig.RegWrite = 1;
                    sig.SignExt = 1;
                    sig.ALUop = 4'b1100;
                    sig.ALUCalculateop = 4'b0111;
                end
                
                6'b001011: begin //SLTIU
                    sig.ALUNeedImm = 1;
                    sig.RegWrite = 1;
                    sig.SignExt = 1;
                    sig.ALUop = 4'b1101;
                    sig.ALUCalculateop = 4'b0101;
                end
					
                6'b000000: begin
                	case(ins.R.func) 
                		6'b001100:begin //SYSCALL
                		    sig.Finish = 1;
                		end 
                		6'b001000: begin //JR
                			sig.Jump = 1;
                        	sig.JumpReg = 1;
                        	sig.ALUCalculateop = 4'b0010;
                		end
                		6'b001001: begin// JALR
                			sig.Jump = 1;
                        	sig.JumpReg = 1;
                        	sig.WriteToRa = 1;
                        	sig.RegWrite = 1;
                        	sig.ALUCalculateop = 4'b0010;
                		end
                		6'b010000: begin// MFHI
                            sig.RegWrite = 1;
                            sig.MduStart = 1;
                            sig.Mduop = MDU_READ_HI;
                        end
                        6'b010010: begin// MFLO
                            sig.RegWrite = 1;
                            sig.MduStart = 1;
                            sig.Mduop = MDU_READ_LO;
                        end
                        6'b010001: begin// MTHI
                            sig.MduStart = 1;
                            sig.Mduop = MDU_WRITE_HI;
                        end
                        6'b010011: begin// MTLO
                            sig.MduStart = 1;
                            sig.Mduop = MDU_WRITE_LO;
                        end
                        6'b011000: begin// MULT
                            sig.MduStart = 1;
                            sig.Mduop = MDU_START_SIGNED_MUL;
                        end
                        6'b011001: begin// MULTU
                            sig.MduStart = 1;
                            sig.Mduop = MDU_START_UNSIGNED_MUL;
                        end
                        6'b011010: begin// DIV
                            sig.MduStart = 1;
                            sig.Mduop = MDU_START_SIGNED_DIV;
                        end
                        6'b011011: begin// DIVU
                            sig.MduStart = 1;
                            sig.Mduop = MDU_START_UNSIGNED_DIV;
                        end
                		default: begin
                			sig.RegWrite = 1;
                        	sig.WriteToRdRt = 1;
                        	sig.ALUop = 4'b0010;
                        	if(ins.R.func == 6'b100000 || ins.R.func == 6'b100001)  //ADD ADDU
                        		sig.ALUCalculateop = 4'b0010;
                        	else if(ins.R.func == 6'b100010 || ins.R.func == 6'b100011)  //SUB SUBU
                        		sig.ALUCalculateop = 4'b0110;
                        	else if(ins.R.func == 6'b000000 || ins.R.func == 6'b000100)  //SLL SLLV
                        		sig.ALUCalculateop = 4'b1000;
                        	else if(ins.R.func == 6'b000010 || ins.R.func == 6'b000110)  //SRL SRLV
                        		sig.ALUCalculateop = 4'b1001;
                        	else if(ins.R.func == 6'b000011 || ins.R.func == 6'b000111)  //SRA SRAV
                        		sig.ALUCalculateop = 4'b1011;	
                            else if(ins.R.func == 6'b101010)  //SLT
                        		sig.ALUCalculateop = 4'b0111;	
                        	else if(ins.R.func == 6'b101011)  //SLTU
                        		sig.ALUCalculateop = 4'b0101;	
                        	else if(ins.R.func == 6'b100100)  //AND
                        		sig.ALUCalculateop = 4'b0000;	
                        	else if(ins.R.func == 6'b100101)  //OR
                        		sig.ALUCalculateop = 4'b0001;	
                        	else if(ins.R.func == 6'b100110)  //XOR
                        		sig.ALUCalculateop = 4'b0011;	
                        	else if(ins.R.func == 6'b100111)  //NOR
                        		sig.ALUCalculateop = 4'b0100;	
                        		
                        	if(ins.R.func == 6'b000000 || ins.R.func == 6'b000010 || ins.R.func == 6'b000011) begin // SLL SRL SRA
                                sig.shift = 1;
                                sig.shift_sa = 1;
                            end
                            else if(ins.R.func == 6'b000100 || ins.R.func == 6'b000110 || ins.R.func == 6'b000111) // SLLV SRLV SRAV
                                sig.shift = 1;
                        	                       		
                		end
                	endcase
                end
                default: begin
                	$finish;
                end
            endcase       
		end
        
        else begin //NOP -> SLL $0, $0, 0
            sig.RegWrite = 1;
            sig.WriteToRdRt = 1;
            sig.ALUop = 4'b0010;
            sig.ALUCalculateop = 4'b1000;
            sig.shift = 1;
            sig.shift_sa = 1;
        end

end
        

endmodule

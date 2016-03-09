`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Kun-Hua Huang
// Email: kunhuahuang@hotmail.com

// Create Date:    10:47:49 09/20/2014 
// Design Name:    KH32
// Module Name:    CPU_IF 
// Project Name:   Throughput Processor 
// Description:    This part is the Instruction Fetch of the CPU core
//
// Revision: 1.0v
//
//////////////////////////////////////////////////////////////////////////////////
module CPU_IF(
input wire clk,
input wire rst,
input wire en,
input wire [31:0] PC_temp,
input wire [0:0] PC_jump_flag,

input wire [31:0] IMEM_Dout,
output reg [31:0] PC_IF,
output reg [31:0] IR,
input wire [0:0] LOAD_happened

    );
	
reg [1:0] jump_flag;
	
always @(posedge clk or negedge rst)
if(!rst)
begin
	PC_IF <= 32'b0;	///The init value can be put in from outside.
	IR <= 32'b0;
	jump_flag <= 2'b00;
end
else
begin
	if(LOAD_happened)
	begin
		PC_IF <= PC_IF;
		IR <= IR;
		jump_flag <= 2'b00;
	end
	else
	begin
		if(en)
		begin
			if((IR[31:28] == 4'b0100) || (IR[31:28] == 4'b0101))//Branch or Jump
			begin
				if(jump_flag  == 2'b00)//wait for count PC address
				begin
					PC_IF <=PC_IF;
					IR <= {4'b0100,28'b0};//use branch cond for N
					jump_flag <= 2'b01;
				end
				else if(jump_flag  == 2'b01)//wait for count PC address
				begin
					PC_IF <= PC_IF;
					IR <= {4'b0100,28'b0};//use branch cond for NOP
					jump_flag <= 2'b10;
				end
				else if(jump_flag  == 2'b10)//wait for PUT PC address
				begin
					PC_IF <= PC_jump_flag? PC_temp : PC_IF;
					IR <= 32'b0;//use branch cond for NOP
					jump_flag <= 2'b00;
				end
	/*			else if(jump_flag  == 2'b11)//Wait for the MEM value
				begin
					PC_IF <= PC_IF;
					IR <= 32'b0;
					jump_flag <= 2'b00;
				end*/
			end
			else
			begin
				PC_IF <= PC_IF + 1'b1;//PC counting
				IR <= IMEM_Dout;
				jump_flag <= 2'b00;
			end
		end
		else
		begin
			PC_IF <= PC_IF;//PC counting
			IR <= IR;
			jump_flag <=jump_flag;
		
		end
	end

end



endmodule

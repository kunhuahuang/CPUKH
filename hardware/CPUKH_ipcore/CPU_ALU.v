`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Kun-Hua Huang
// Email: kunhuahuang@hotmail.com

// Create Date:    10:47:49 09/18/2014 
// Design Name:    KH32
// Module Name:    CPU_EX 
// Project Name:   Throughput Processor 
// Description:    This part is the ALU of the CPU core
//
// Revision: 1.0v
//
//////////////////////////////////////////////////////////////////////////////////
module CPU_ALU(
////////INPUT///////////
input wire [3:0] 	ALU_op,//4-bit :{operand}
input wire [31:0]	ALU_Ra,
input wire [31:0]	ALU_Rb,
////////OUTPUT///////////
output reg [3:0]	FLAG_o,
output reg [31:0]	ALU_Rd
    );
/////FLAG  //////////
//////Z C V N////////
parameter MOV = 4'b0000;
parameter ADD = 4'b0001;
parameter SUB = 4'b0010;
parameter AND = 4'b0011;
parameter OR  = 4'b0100;
parameter XOR = 4'b0101;
parameter NOT = 4'b0110;//MVN
parameter SHL = 4'b0111;
parameter SHR = 4'b1000;
parameter ROL = 4'b1001;
parameter ROR = 4'b1010;
parameter ASR = 4'b1011;
parameter MOVi = 4'b1100;
parameter MVHi = 4'b1101;
parameter MVLi = 4'b1110;

wire [31:0] Rb;
wire [31:0] sum;
wire CY_o;
wire overflow;
wire [32:0] RB_w;

assign RB_w = (ALU_op[3:0] == SUB)?({1'b0,(~ALU_Rb)} + 1'b1):{1'b0,ALU_Rb};
assign {CY_o,sum} = {1'b0,ALU_Ra} + RB_w;

xor x1(overflow, sum[30], sum[31]);

always @(ALU_op or ALU_Ra or ALU_Rb or sum)
begin
	case(ALU_op[3:0])
/*		MOV:
			begin
				ALU_Rd = ALU_Ra;
			end*/
		ADD,SUB:
			begin
				ALU_Rd = sum;
			end
		AND:
			begin
				ALU_Rd = ALU_Ra & ALU_Rb;
			end
		OR:
			begin
				ALU_Rd = ALU_Ra | ALU_Rb;
			end
		XOR:
			begin
				ALU_Rd = ALU_Ra ^ ALU_Rb;
			end
		NOT:
			begin
				ALU_Rd = ~ALU_Ra;
			end
		SHL:
			begin
				ALU_Rd = ALU_Ra << ALU_Rb[4:0] ;
			end
		SHR:
			begin
				ALU_Rd = ALU_Ra >> ALU_Rb[4:0] ;
			end
		ROL:
			begin
				ALU_Rd = (ALU_Ra << (6'd32-{1'b0, ALU_Rb[4:0]})) | (ALU_Ra >> ALU_Rb[4:0]);
			end		
		ROR:
			begin
				ALU_Rd = ({32{ALU_Ra[31]}} << (6'd32-{1'b0, ALU_Rb[4:0]})) | ALU_Ra >> ALU_Rb[4:0];
			end		
		ASR:
			begin
				ALU_Rd = ALU_Ra >>> ALU_Rb[4:0];
			end	
		MOVi:
			begin
				ALU_Rd = ALU_Rb;
			end
		MVHi:
			begin
				ALU_Rd = {ALU_Rb[15:0] , ALU_Ra[15:0]};
			end
		MVLi:
			begin
				ALU_Rd = {ALU_Ra[31:16] , ALU_Rb[15:0]};
			end
		default:
			begin
				ALU_Rd = ALU_Ra; // MOV
			end
	endcase
end

always @(CY_o or overflow or overflow or ALU_Rd or ALU_op)
begin
	case(ALU_op[3:0])
		ADD,SUB:
			begin
				FLAG_o = {(ALU_Rd == 0)? 1'b1 : 1'b0/*Zero*/,CY_o/*Carry*/,overflow/*overflow*/,ALU_Rd[31]/*negtive*/};
			end
		default:
			begin
				FLAG_o = {(ALU_Rd == 0)? 1'b1 : 1'b0/*Zero*/,1'b0/*Carry*/,1'b0/*overflow*/,1'b0/*negtive*/};
			end
	endcase
end
endmodule

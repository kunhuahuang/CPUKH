`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Kun-Hua Huang
// Email: kunhuahuang@hotmail.com

// Create Date:    10:47:49 09/19/2014 
// Design Name:    KH32
// Module Name:    CPU_ID 
// Project Name:   Throughput Processor 
// Description:    This part is the Decoder of the CPU core
//
// Revision: 1.0v
//
//////////////////////////////////////////////////////////////////////////////////
module CPU_ID(
input wire clk,
input wire rst,
input wire en,
////////INPUT///////////

//input wire [0:0] ID_state_en, //No need, because of the no hit & FLUSH method.
input wire [31:0] PC_IF,
input wire [31:0] IR,


////////OUTPUT//////////
output reg [1:0] 	ALU_input_sel_Ra,
output reg [0:0] 	ALU_input_sel_Rb,
output reg [31:0] 	PC_ID,
output reg [3:0] 	ALU_op,
output reg [3:0] 	ALU_Ra,
output reg [3:0] 	ALU_Rb,
output reg [31:0] 	ALU_Imm,

output reg [3:0] 	ALU_Rd_WB_sel,
output reg [0:0] 	ALU_Rd_WB_en,
output reg [0:0] 	ALU_FLAG_WB_en,
output reg [3:0] 	JUMP_cond,

output reg [0:0] 	DMEM_Control_sel,
output reg [0:0] 	DMEM_ID_WE,
output reg [0:0] 	DMEM_Data_sel,

////////INPUT for LOAD/////////////
output reg [0:0] 	LOAD_EN, //for Load in second clock
output reg [0:0]  	LOAD_happened,
output reg [0:0]	JUMP_LINK,
////////INPUT AND OUTPUT INSTR///////////
output reg [1:0]	INOUT_F
//2'b00:	NONE
//2'b01:	IN
//2'b10:	OUT
//2'b11:	IN OUT//NOT FOR NOW
    );

reg [1:0] 	ALU_input_sel_Ra_o;
reg [0:0] 	ALU_input_sel_Rb_o;

reg [3:0] 	ALU_op_o;

reg [3:0] 	ALU_Ra_o;
reg [3:0] 	ALU_Rb_o;
reg [31:0] ALU_Imm_o;

reg [3:0] 	ALU_Rd_WB_sel_o;
reg [0:0] 	ALU_Rd_WB_en_o;

reg [0:0] 	ALU_FLAG_WB_en_o;

reg [3:0] 	JUMP_cond_o;

reg [0:0] 	DMEM_Control_sel_o;
reg [0:0] 	DMEM_ID_WE_o;
reg [0:0] 	DMEM_Data_sel_o;

////////INPUT for LOAD/////////////
reg [0:0] 	LOAD_EN_o; //for Load in second clock

////////Make ID know the LOAD happen
reg [0:0]  LOAD_happened_o;
//reg [0:0]  	LOAD_happened;
reg [3:0] 	LOAD_Rd_tmp_o;
reg [3:0] 	LOAD_Rd_tmp;
/////////JMP LINK FLAG
reg [0:0] 	JUMP_LINK_o	;

reg [1:0]	INOUT_F_o;//INOUT_F

/*
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
parameter MVF = 4'b1111;
*/

always @(posedge clk or negedge rst )
if(!rst)
begin
ALU_input_sel_Ra <= 2'b0;
ALU_input_sel_Rb <= 1'b0;

PC_ID <= 32'b0;
ALU_op <= 4'b0;
ALU_Ra <= 5'b0;
ALU_Rb <= 5'b0;
ALU_Imm <= 32'b0;

ALU_Rd_WB_sel <= 4'b0;
ALU_Rd_WB_en <= 1'b0;
ALU_FLAG_WB_en<= 1'b0;
JUMP_cond <= 4'b0;
DMEM_Control_sel <= 1'b0;
DMEM_ID_WE<= 1'b0;
DMEM_Data_sel<= 1'b0;
LOAD_Rd_tmp <= 4'b0000;
////////INPUT for LOAD/////////////
LOAD_EN<= 1'b0; //for Load in second clock
LOAD_happened <= 1'b0;
JUMP_LINK			<=	1'b0;
INOUT_F				<=	2'b00;

end
else
begin
	if(en)
	begin
		if(LOAD_happened)  //write back the LOAD value to Register
			begin	
				PC_ID <= PC_ID;
				ALU_input_sel_Ra	<=	2'b0;	
				ALU_input_sel_Rb	<=	1'b0;
				ALU_op				<=	5'b00000;
				ALU_Ra				<=	5'b00000;
				ALU_Rb				<=	5'b00000;
				ALU_Imm				<=	32'b0;
		
				ALU_Rd_WB_sel		<=	LOAD_Rd_tmp;
				ALU_Rd_WB_en		<=	1'b1;
				ALU_FLAG_WB_en		<=	1'b0;
				
				JUMP_cond 			<=	4'b0;
				DMEM_Control_sel	<=	1'b0;
				DMEM_ID_WE			<=	1'b0;
				DMEM_Data_sel		<=	1'b0;
	
					////////INPUT for LOAD/////////////
				LOAD_EN				<=	1'b1; //for Load in second clock
				LOAD_happened		<=	1'b0;	
				JUMP_LINK			<=	1'b0;
				INOUT_F				<=	2'b00;
			end
		else
			begin
				PC_ID <= PC_IF;
				ALU_input_sel_Ra	<=	ALU_input_sel_Ra_o;
				ALU_input_sel_Rb	<=	ALU_input_sel_Rb_o;

				ALU_op				<=	ALU_op_o;
				ALU_Ra				<=	ALU_Ra_o;
				ALU_Rb				<=	ALU_Rb_o;
				ALU_Imm				<=	ALU_Imm_o;
						
				ALU_Rd_WB_sel		<=	ALU_Rd_WB_sel_o;
				ALU_Rd_WB_en		<=	ALU_Rd_WB_en_o;

				ALU_FLAG_WB_en		<=	ALU_FLAG_WB_en_o;
				
				JUMP_cond 			<=	JUMP_cond_o;
				
				DMEM_Control_sel	<=	DMEM_Control_sel_o;
				DMEM_ID_WE			<=	DMEM_ID_WE_o;
				DMEM_Data_sel		<=	DMEM_Data_sel_o;
					////////INPUT for LOAD/////////////
				LOAD_EN				<=	0; //for Load in second clock
				LOAD_happened		<=	LOAD_happened_o;	
				LOAD_Rd_tmp			<=	LOAD_Rd_tmp_o;
				JUMP_LINK			<=	JUMP_LINK_o;
				INOUT_F				<=	INOUT_F_o;
			end
	end
	else 
	begin
				PC_ID <= PC_ID;
				ALU_input_sel_Ra	<=	ALU_input_sel_Ra;
				ALU_input_sel_Rb	<=	ALU_input_sel_Rb;

				ALU_op				<=	ALU_op;
				ALU_Ra				<=	ALU_Ra;
				ALU_Rb				<=	ALU_Rb;
				ALU_Imm				<=	ALU_Imm;
						
				ALU_Rd_WB_sel		<=	ALU_Rd_WB_sel;
				ALU_Rd_WB_en		<=	ALU_Rd_WB_en;

				ALU_FLAG_WB_en		<=	ALU_FLAG_WB_en;
				
				JUMP_cond 			<=	JUMP_cond;
				
				DMEM_Control_sel	<=	DMEM_Control_sel;
				DMEM_ID_WE			<=	DMEM_ID_WE;
				DMEM_Data_sel		<=	DMEM_Data_sel;
					////////INPUT for LOAD/////////////
				LOAD_EN				<=	LOAD_EN; //for Load in second clock
				LOAD_happened		<=	LOAD_happened;	
				LOAD_Rd_tmp			<=	LOAD_Rd_tmp;
				JUMP_LINK			<=	JUMP_LINK;
				INOUT_F				<=	INOUT_F;
	
	end
end

always @(*)
begin
	//KH32
	case(IR[31:28])
		4'b0000: //MOV
			begin
				ALU_input_sel_Ra_o		=	2'b01;
				ALU_input_sel_Rb_o		= 	1'b1;
//				ALU_op_o				=	;
				ALU_Ra_o				=	IR[19:16];
				ALU_Rb_o				=	4'b0000;	//don't care
				ALU_Imm_o				=	{16'b0,IR[15:0]};
				ALU_Rd_WB_sel_o			=	IR[23:20];
				ALU_Rd_WB_en_o			=	1'b1;
				ALU_FLAG_WB_en_o		=	1'b0;
				JUMP_cond_o				=	4'b0000;	//No jump
				DMEM_Control_sel_o		=	1'b0;
				DMEM_ID_WE_o			= 	1'b0;
				DMEM_Data_sel_o			=	1'b0;
				LOAD_happened_o			=	1'b0;
				LOAD_Rd_tmp_o			=	IR[23:20];	//don't care
				JUMP_LINK_o				=	1'b0;
				INOUT_F_o				=	2'b00;
				casex(IR[27:24]) 
					4'b0??0:
						begin
							ALU_op_o	=	4'b0000;
						end
					4'b0??1:
						begin
							ALU_op_o	=	4'b0110;
						end
					4'b1???:
						begin
							ALU_op_o	=	{2'b11,IR[25:24]};
						end				
				endcase
			end
		4'b0001: //ALU
			begin
				ALU_input_sel_Ra_o		=	2'b01;
				ALU_input_sel_Rb_o		= 	IR[27];
//				ALU_op_o				=	;
				ALU_Ra_o				=	IR[19:16];
				ALU_Rb_o				=	IR[15:12];
				ALU_Imm_o			=	{ {16{IR[15]}} , IR[15:0]};//Signed extend
				ALU_Rd_WB_sel_o			=	IR[23:20];
//				ALU_Rd_WB_en_o			=	1'b1;
//				ALU_FLAG_WB_en_o		=	1'b0;
				JUMP_cond_o				=	4'b0000;	//No jump
				DMEM_Control_sel_o		=	1'b0;
				DMEM_ID_WE_o			= 	1'b0;
				DMEM_Data_sel_o			=	1'b0;
				LOAD_happened_o			=	1'b0;
				LOAD_Rd_tmp_o			=	IR[23:20];	//don't care
				JUMP_LINK_o				=	1'b0;
				INOUT_F_o				=	2'b00;
				case(IR[26:24]) ///////if have time, here can be reduce./////////
					3'b000://ADD
						begin
							ALU_op_o				=	4'b0001;
							ALU_Rd_WB_en_o			=	1'b1;//For CMP
							ALU_FLAG_WB_en_o		=	1'b0;
						end
					3'b001://ADDF
						begin
							ALU_op_o				=	4'b0001;
							ALU_Rd_WB_en_o			=	1'b1;//For CMP
							ALU_FLAG_WB_en_o		=	1'b1;
						end
					3'b010://SUB
						begin
							ALU_op_o				=	4'b0010;
							ALU_Rd_WB_en_o			=	1'b1;//For CMP
							ALU_FLAG_WB_en_o		=	1'b0;
						end
					3'b011://SUBF
						begin
							ALU_op_o				=	4'b0010;
							ALU_Rd_WB_en_o			=	1'b1;//For CMP
							ALU_FLAG_WB_en_o		=	1'b1;
						end
					3'b100://AND
						begin
							ALU_op_o				=	4'b0011;
							ALU_Rd_WB_en_o			=	1'b1;//For CMP
							ALU_FLAG_WB_en_o		=	1'b0;
						end
					3'b101://OR
						begin
							ALU_op_o				=	4'b0100;
							ALU_Rd_WB_en_o			=	1'b1;//For CMP
							ALU_FLAG_WB_en_o		=	1'b0;
						end
					3'b110://XOR
						begin
							ALU_op_o				=	4'b0101;
							ALU_Rd_WB_en_o			=	1'b1;//For CMP
							ALU_FLAG_WB_en_o		=	1'b0;
						end
					3'b111://CMP
						begin
							ALU_op_o				=	4'b0010;
							ALU_Rd_WB_en_o			=	1'b0;//For CMP
							ALU_FLAG_WB_en_o		=	1'b1;
						end
				endcase
			end		
		4'b0010: //SHF
			begin
				ALU_input_sel_Ra_o		=	2'b01;
				ALU_input_sel_Rb_o		= 	1'b1;
				ALU_op_o				=	IR[27:24];
				ALU_Ra_o				=	IR[19:16];
				ALU_Rb_o				=	IR[15:12];
				ALU_Imm_o				=	{27'b0,IR[4:0]};
				ALU_Rd_WB_sel_o			=	IR[23:20];
				ALU_Rd_WB_en_o			=	1'b1;
				ALU_FLAG_WB_en_o		=	1'b0;
				JUMP_cond_o				=	4'b0000;	//No jump
				DMEM_Control_sel_o		=	1'b0;
				DMEM_ID_WE_o			= 	1'b0;
				DMEM_Data_sel_o			=	1'b0;
				LOAD_happened_o			=	1'b0;
				LOAD_Rd_tmp_o			=	IR[23:20];	//don't care
				JUMP_LINK_o				=	1'b0;
				INOUT_F_o				=	2'b00;
			end
		4'b0011: //LDR & STR
			begin
				ALU_input_sel_Ra_o		=	2'b01;
				ALU_input_sel_Rb_o		= 	1'b0;	
				ALU_op_o				=	4'b0000; //don't care
				ALU_Ra_o				=	IR[19:16];
				ALU_Rb_o				=	IR[23:20]; 
				ALU_Imm_o				=	32'b0;//don't care
				ALU_Rd_WB_sel_o			=	IR[23:20];//don't care
				ALU_Rd_WB_en_o			=	1'b0;
				ALU_FLAG_WB_en_o		=	1'b0;
				JUMP_cond_o				=	4'b0000;	//No jump
				DMEM_Control_sel_o		=	1'b1;//Ra
				LOAD_Rd_tmp_o			=	IR[23:20];//don't care
				DMEM_Data_sel_o			=	1'b1;
				DMEM_ID_WE_o			=   IR[27];
				LOAD_happened_o			=   ~IR[27];
				JUMP_LINK_o				=	1'b0;
				INOUT_F_o				=	2'b00;
			end
		4'b0100: //Branch cond
			begin
				ALU_input_sel_Ra_o		=	2'b11;//PC_ID
				ALU_input_sel_Rb_o		= 	1'b1;
				ALU_op_o				=	4'b0001;//ADD
				ALU_Ra_o				=	IR[19:16];//don't care
				ALU_Rb_o				=	IR[15:12];//don't care
				ALU_Imm_o				=	{{8{IR[23]}},IR[23:0]};
				ALU_Rd_WB_sel_o			=	IR[23:20];//don't care
				ALU_Rd_WB_en_o			=	1'b0;
				ALU_FLAG_WB_en_o		=	1'b0;
				JUMP_cond_o				=	IR[27:24];	//jump
				DMEM_Control_sel_o		=	1'b0;
				DMEM_ID_WE_o			= 	1'b0;
				DMEM_Data_sel_o			=	1'b0;
				LOAD_happened_o			=	1'b0;
				LOAD_Rd_tmp_o			=	IR[23:20];	//don't care
				JUMP_LINK_o				=	1'b0;
				INOUT_F_o				=	2'b00;
			end
		4'b0101: //JMP
			begin
				ALU_input_sel_Ra_o		=	2'b01;//Ra
				ALU_input_sel_Rb_o		= 	1'b1;//Imm
				ALU_op_o				=	4'b0000;
				ALU_Rb_o				=	IR[15:12];//don't care
				ALU_Imm_o				=	32'b0;
				ALU_Rd_WB_sel_o			=	IR[23:20];//don't care
				ALU_Rd_WB_en_o			=	1'b0;
				ALU_FLAG_WB_en_o		=	1'b0;
				JUMP_cond_o				=	4'b1111;//jump AL
				DMEM_Control_sel_o		=	1'b0;
				DMEM_ID_WE_o			= 	1'b0;
				DMEM_Data_sel_o			=	1'b0;
				LOAD_happened_o			=	1'b0;
				LOAD_Rd_tmp_o			=	IR[23:20];	//don't care
				INOUT_F_o				=	2'b00;
				casex(IR[27:24])
					4'b0??0:
						begin
							ALU_Ra_o				=	IR[19:16];
							JUMP_LINK_o				=	1'b0;
						end
						
					4'b0??1:
						begin
							ALU_Ra_o				=	IR[19:16];
							JUMP_LINK_o				=	1'b1;
						end
					4'b1???:
						begin
							ALU_Ra_o				=	4'b1111;
							JUMP_LINK_o				=	1'b0;
						end	
				endcase
			end
		4'b0110://IN OUT
			begin
				ALU_input_sel_Ra_o		=	2'b10;
				ALU_input_sel_Rb_o		= 	1'b1;
				ALU_op_o				=	4'b0000;
				ALU_Ra_o				=	IR[19:16];
				ALU_Rb_o				=	IR[15:12];
				ALU_Imm_o				=	{32'b0};
				ALU_Rd_WB_sel_o			=	IR[23:20];
				
				ALU_FLAG_WB_en_o		=	1'b0;
				JUMP_cond_o				=	4'b0000;	//No jump
				DMEM_Control_sel_o		=	1'b0;
				DMEM_ID_WE_o			= 	1'b0;
				DMEM_Data_sel_o			=	1'b0;
				LOAD_happened_o			=	1'b0;
				LOAD_Rd_tmp_o			=	IR[23:20];	//don't care
				JUMP_LINK_o				=	1'b0;				
				case(IR[27])
					1'b0://IN
						begin
							INOUT_F_o				=	2'b01;
							ALU_Rd_WB_en_o			=	1'b1;
						end
					1'b1://OUT
						begin
							INOUT_F_o				=	2'b10;
							ALU_Rd_WB_en_o			=	1'b0;
						end
				endcase
			end			
		default :
			begin //NOP
				ALU_input_sel_Ra_o		=	2'b01;
				ALU_input_sel_Rb_o		= 	1'b1;
				ALU_op_o				=	4'b0000;
				ALU_Ra_o				=	IR[19:16];
				ALU_Rb_o				=	4'b0000;	//don't care
				ALU_Imm_o				=	{16'b0,IR[15:0]};
				ALU_Rd_WB_sel_o			=	IR[23:20];
				ALU_Rd_WB_en_o			=	1'b0;
				ALU_FLAG_WB_en_o		=	1'b0;
				JUMP_cond_o				=	4'b0000;	//No jump
				DMEM_Control_sel_o		=	1'b0;
				DMEM_ID_WE_o			= 	1'b0;
				DMEM_Data_sel_o			=	1'b0;
				LOAD_happened_o			=	1'b0;
				LOAD_Rd_tmp_o			=	IR[23:20];	//don't care
				JUMP_LINK_o				=	1'b0;
				INOUT_F_o				=	2'b00;

			end
			
	endcase
end



endmodule

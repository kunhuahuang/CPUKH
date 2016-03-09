`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Kun-Hua Huang
// Email: kunhuahuang@hotmail.com

// Create Date:    10:47:49 09/18/2014 
// Design Name:    KH32
// Module Name:    CPU_EX 
// Project Name:   Throughput Processor 
// Description:    This part is the Execute of the CPU core
//
// Revision: 1.0v
//
//////////////////////////////////////////////////////////////////////////////////
module CPU_EX(
input wire clk ,
input wire rst,
input wire en,
////////INPUT from ID///////////
input wire [1:0] 	ALU_input_sel_Ra,
input wire [0:0] 	ALU_input_sel_Rb,
input wire [31:0] 	PC_ID,
input wire [3:0] 	ALU_op,
input wire [3:0] 	ALU_Ra,
input wire [3:0] 	ALU_Rb,
input wire [31:0] 	ALU_Imm,

input wire [3:0] 	ALU_Rd_WB_sel,
input wire [0:0] 	ALU_Rd_WB_en,
input wire [0:0] 	ALU_FLAG_WB_en,
input wire [3:0] 	JUMP_cond,

input wire [0:0] 	DMEM_Control_sel ,
input wire [0:0] 	DMEM_ID_WE,
input wire [0:0] 	DMEM_Data_sel,

////////INPUT from DMEM///////////
input wire [31:0] 	DMEM_DATA_WB_w,
////////INPUT for LOAD/////////////
input wire [0:0] 	LOAD_EN,
////////JUMP////////////
input wire [0:0]	JUMP_LINK,
////////INOUT///////////
input wire [1:0]	INOUT_F,
input wire [31:0]	IN_DATA,
output reg [31:0]	OUT_DATA,
output reg [31:0]	INOUT_ADDR,
////////OUTPUT//////////
output reg [0:0] 	DMEM_WE,
output reg [31:0] 	DMEM_Addr,
output reg [31:0] 	DMEM_Data,
////////JUMP////////////
output reg [31:0] 	PC_temp,
output reg [0:0] 	PC_jump_flag //if 1 then jump //if 0 then no jump
////////SPR IO//////////
//special register Output part

    );
/////////////////////////////////////////////
/*FLUSH is use for counting the Flush time.*/
/////////////////////////////////////////////
//output reg [31:0] R17 = 32'b0;//PC
/*
output reg[31:0] R19 = 32'b0;//output device value
output reg [31:0] R20 = 32'b0;//output data value
//special register Input part
input [31:0] R21;//input device value
input [31:0] R22;//input data value
*/

reg [31:0] R00;//R0~R15 for compute
reg [31:0] R01;
reg [31:0] R02;
reg [31:0] R03;
reg [31:0] R04;
reg [31:0] R05;
reg [31:0] R06;
reg [31:0] R07;
reg [31:0] R08;
reg [31:0] R09;
reg [31:0] R10;
reg [31:0] R11;
reg [31:0] R12;
reg [31:0] R13;
reg [31:0] R14;
reg [31:0] R15;
reg [3:0]  FLAG;

wire [31:0] MUX_to_Ra;	 
wire [31:0] MUX_to_Rb;
wire [31:0] MUX_to_ALU_Ra;
wire [31:0] MUX_to_ALU_Rb;

wire [31:0] Reg32_Ra;
wire [31:0] Reg32_Rb;

wire [31:0] ALU_Rd;

wire [3:0] FLAG_Rd;
wire [31:0] DMEM_Addr_o;
wire [31:0] DMEM_Data_o;



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

MUX_16_to_1_32bit ALU_Ra_REG32(
.sel_i_16(ALU_Ra),
.out(Reg32_Ra),
.i0(R00),.i1(R01),.i2(R02),.i3(R03),
.i4(R04),.i5(R05),.i6(R06),.i7(R07),
.i8(R08),.i9(R09),.i10(R10),.i11(R11),
.i12(R12),.i13(R13),.i14(R14),.i15(R15)
	 );

MUX_16_to_1_32bit ALU_Rb_REG32(
.sel_i_16(ALU_Rb),
.out(Reg32_Rb),
.i0(R00),.i1(R01),.i2(R02),.i3(R03),
.i4(R04),.i5(R05),.i6(R06),.i7(R07),
.i8(R08),.i9(R09),.i10(R10),.i11(R11),
.i12(R12),.i13(R13),.i14(R14),.i15(R15)
	 );

//IN DATA PUT IN THIS MUX AND USE MOV TO Rd////*important
MUX_4_to_1_32bit ALU_Ra_Mux(
.sel_i_4(ALU_input_sel_Ra),
.out(MUX_to_ALU_Ra),
.i0(32'b0),
.i1(Reg32_Ra),
.i2(IN_DATA/*if use DMEM_DATA_WB_w*/),//if use DMEM_DATA_WB_w and go though ALU, it will take to long time.
.i3(PC_ID)
    );
	
MUX_2_to_1_32bit ALU_Rb_Mux(
.sel_i_2(ALU_input_sel_Rb),
.out(MUX_to_ALU_Rb),
.i0(Reg32_Rb),
.i1(ALU_Imm)
    );
	


CPU_ALU ALU(
////////INPUT///////////
.ALU_op(ALU_op),//[3:0]  4-bit:operand
.ALU_Ra(MUX_to_ALU_Ra),//[31:0]	
.ALU_Rb(MUX_to_ALU_Rb),//[31:0]	
////////OUTPUT///////////
.FLAG_o(FLAG_Rd),//[3:0]	
.ALU_Rd(ALU_Rd)//[31:0]	
    );
	

MUX_2_to_1_32bit DMEM_Addr_Mux(
.sel_i_2(DMEM_Control_sel),
.out(DMEM_Addr_o),
.i0(DMEM_Addr),
.i1(Reg32_Ra)
    );
	
//Don't do this. Because if the Data or instruction is no hit, it will need to remain the data value.	
//assign DMEM_Data_o = Reg32_Rb;


MUX_2_to_1_32bit DMEM_Data_Mux(
.sel_i_2(DMEM_Data_sel),
.out(DMEM_Data_o),
.i0(DMEM_Data),
.i1(Reg32_Rb)
    );

/////////////////////
//Each of the register are independent
/////////////////////	 
reg JUMP_cond_o;

always @(*)
begin
	case(JUMP_cond)
		4'b0000://NT
			begin
				JUMP_cond_o = 1'b0;
			end
		4'b0001://EQ
			begin
				JUMP_cond_o = FLAG[3];
			end
		4'b0010://NE
			begin
				JUMP_cond_o = ~FLAG[3];
			end
		4'b0011://CS
			begin
				JUMP_cond_o = FLAG[2];
			end
		4'b0100://CC
			begin
				JUMP_cond_o = ~FLAG[2];
			end
		4'b0101://MI
			begin
				JUMP_cond_o =  FLAG[0];
			end	
		4'b0110://PL
			begin
				JUMP_cond_o =  ~FLAG[0];
			end	
		4'b0111://VS
			begin
				JUMP_cond_o =  FLAG[1];
			end	
		4'b1000://VC
			begin
				JUMP_cond_o =  ~FLAG[1];
			end	
		4'b1001://HI
			begin
				JUMP_cond_o = ( FLAG[2] && (~FLAG[3]));
			end	
		4'b1010://LS
			begin
				JUMP_cond_o = ( (FLAG[3]) || (~FLAG[2]));
			end	
		4'b1011://GE
			begin
				JUMP_cond_o = ( FLAG[1] == FLAG[0]);
			end	
		4'b1100://LT
			begin
				JUMP_cond_o = ( FLAG[1] != FLAG[0]);
			end	
		4'b1101://GT
			begin
				JUMP_cond_o = ( ~FLAG[3]  && ( FLAG[1] == FLAG[0]) );
			end	
		4'b1110://LE
			begin
				JUMP_cond_o = ( FLAG[3]  || ( FLAG[1] != FLAG[0]) ) ;
			end	
		4'b1111://AL
			begin
				JUMP_cond_o = 1'b1;
			end	
	 endcase

end


////////////////////////////////////////
//Each of the register are independent//
////////////////////////////////////////
always @(posedge clk or negedge rst )
if(!rst)
begin

	R00 <= 32'b0;//R0~R15 for compute
	R01 <= 32'b0;
	R02 <= 32'b0;
	R03 <= 32'b0;
	R04 <= 32'b0;
	R05 <= 32'b0;
	R06 <= 32'b0;
	R07 <= 32'b0;
	R08 <= 32'b0;
	R09 <= 32'b0;
	R10 <= 32'b0;
	R11 <= 32'b0;
	R12 <= 32'b0;
	R13 <= 32'b0;
	R14 <= 32'b0;
	R15 <= 32'b0;
	
	FLAG <= 4'b0;//FLAG 
	PC_jump_flag <= 1'b0;
	PC_temp <= 32'b0;
	DMEM_WE <= 1'b0;
	DMEM_Addr <= 32'b0;
	DMEM_Data <= 32'b0;
	OUT_DATA <=  32'b0;
	INOUT_ADDR <=  32'b0;
end	
else 
begin
	if(en)
	begin
	R00 <= (ALU_Rd_WB_en && (ALU_Rd_WB_sel == 4'b0000))?  (LOAD_EN? DMEM_DATA_WB_w : ALU_Rd ) : R00;//(LOAD_EN? DMEM_DATA_WB_w : R00));
	R01 <= (ALU_Rd_WB_en && (ALU_Rd_WB_sel == 4'b0001))?  (LOAD_EN? DMEM_DATA_WB_w : ALU_Rd ) : R01;
	R02 <= (ALU_Rd_WB_en && (ALU_Rd_WB_sel == 4'b0010))?  (LOAD_EN? DMEM_DATA_WB_w : ALU_Rd ) : R02;
	R03 <= (ALU_Rd_WB_en && (ALU_Rd_WB_sel == 4'b0011))?  (LOAD_EN? DMEM_DATA_WB_w : ALU_Rd ) : R03;
	R04 <= (ALU_Rd_WB_en && (ALU_Rd_WB_sel == 4'b0100))?  (LOAD_EN? DMEM_DATA_WB_w : ALU_Rd ) : R04;
	R05 <= (ALU_Rd_WB_en && (ALU_Rd_WB_sel == 4'b0101))?  (LOAD_EN? DMEM_DATA_WB_w : ALU_Rd ) : R05;
	R06 <= (ALU_Rd_WB_en && (ALU_Rd_WB_sel == 4'b0110))?  (LOAD_EN? DMEM_DATA_WB_w : ALU_Rd ) : R06;
	R07 <= (ALU_Rd_WB_en && (ALU_Rd_WB_sel == 4'b0111))?  (LOAD_EN? DMEM_DATA_WB_w : ALU_Rd ) : R07;
	R08 <= (ALU_Rd_WB_en && (ALU_Rd_WB_sel == 4'b1000))?  (LOAD_EN? DMEM_DATA_WB_w : ALU_Rd ) : R08;
	R09 <= (ALU_Rd_WB_en && (ALU_Rd_WB_sel == 4'b1001))?  (LOAD_EN? DMEM_DATA_WB_w : ALU_Rd ) : R09;
	R10 <= (ALU_Rd_WB_en && (ALU_Rd_WB_sel == 4'b1010))?  (LOAD_EN? DMEM_DATA_WB_w : ALU_Rd ) : R10;
	R11 <= (ALU_Rd_WB_en && (ALU_Rd_WB_sel == 4'b1011))?  (LOAD_EN? DMEM_DATA_WB_w : ALU_Rd ) : R11;
	R12 <= (ALU_Rd_WB_en && (ALU_Rd_WB_sel == 4'b1100))?  (LOAD_EN? DMEM_DATA_WB_w : ALU_Rd ) : R12;
	R13 <= (ALU_Rd_WB_en && (ALU_Rd_WB_sel == 4'b1101))?  (LOAD_EN? DMEM_DATA_WB_w : ALU_Rd ) : R13;
	R14 <= (ALU_Rd_WB_en && (ALU_Rd_WB_sel == 4'b1110))?  (LOAD_EN? DMEM_DATA_WB_w : ALU_Rd ) : R14;
	R15 <= JUMP_LINK? PC_ID : (ALU_Rd_WB_en && (ALU_Rd_WB_sel == 4'b1111))?  (LOAD_EN? DMEM_DATA_WB_w : ALU_Rd ) : R15;
	INOUT_ADDR 	<=	INOUT_F[1]?	Reg32_Rb:	INOUT_ADDR;
	OUT_DATA	<=	INOUT_F[1]?	Reg32_Ra:	OUT_DATA;
	
	FLAG <= ALU_FLAG_WB_en? FLAG_Rd : FLAG;
		
	PC_temp <= ALU_Rd;
	PC_jump_flag <= JUMP_cond_o;
		
	DMEM_Addr <= DMEM_Addr_o;	
	DMEM_WE <= DMEM_ID_WE;
	DMEM_Data <= DMEM_Data_o;
	end
	else 
	begin
	R00 <=  R00;//(LOAD_EN? DMEM_DATA_WB_w : R00));
	R01 <= 	R01;
	R02 <=  R02;
	R03 <=  R03;
	R04 <= 	R04;
	R05 <= 	R05;
	R06 <= 	R06;
	R07 <= 	R07;
	R08 <=	R08;
	R09 <= 	R09;
	R10 <=	R10;
	R11 <= 	R11;
	R12 <=	R12;
	R13 <= 	R13;
	R14 <=  R14;
	R15 <=  R15;
	INOUT_ADDR 	<=	INOUT_ADDR;
	OUT_DATA	<=	OUT_DATA;
	
	FLAG <=FLAG;
		
	PC_temp <= PC_temp;
	PC_jump_flag <= PC_jump_flag;
		
	DMEM_Addr <= DMEM_Addr;	
	DMEM_WE <= DMEM_WE;
	DMEM_Data <= DMEM_Data;
	
	end
end	
	

/////////////////////////////////////////////

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Kun-Hua Huang
// Email: kunhuahuang@hotmail.com

// Create Date:    10:47:49 09/20/2014 
// Design Name:    KH32
// Module Name:    CPU_TOP
// Project Name:   Throughput Processor 
// Description:    This part is the CPU_TOP of the CPU core
//
// Revision: 1.0v
//
//////////////////////////////////////////////////////////////////////////////////
module CPU_TOP(
input wire  [0:0] 	clk,
input wire  [0:0] 	rst,
input wire 	[0:0] 	en,
////////IMEM/////////
input wire  [31:0]	IMEM_base_addr,
input wire  [31:0]	IMEM_offset,
output wire [31:0]	PC,//IMEM_ADDR
input wire  [31:0]	IMEM_Dout,

////////DMEM/////////
input wire  [31:0]	DMEM_base_addr,
input wire  [31:0]	DMEM_offset,
output wire [31:0]	DMEM_Addr,
output wire [31:0]	DMEM_Data,
output wire [0:0]	DMEM_WE,
input wire  [31:0]	DMEM_DATA_WB_w,
////////INOUT////////
input wire  [31:0]	IN_DATA,
output wire [31:0]	OUT_DATA,
output wire [31:0]	INOUT_ADDR

    );
	
//wire [0:0] 	clk_cpu;
////////IF_stage//////////
wire [31:0] PC_temp;
wire [0:0] 	PC_jump_flag;

wire [31:0] PC_IF;
wire [31:0] IR;
wire [0:0] 	LOAD_happened;
////////ID_stage///////////
wire [1:0] 	ALU_input_sel_Ra;
wire [0:0] 	ALU_input_sel_Rb;
wire [31:0] PC_ID;
wire [3:0] 	ALU_op;
wire [3:0] 	ALU_Ra;
wire [3:0] 	ALU_Rb;
wire [31:0] ALU_Imm;

wire [3:0] 	ALU_Rd_WB_sel;
wire [0:0] 	ALU_Rd_WB_en;
wire [0:0] 	ALU_FLAG_WB_en;
wire [3:0] 	JUMP_cond;

wire [0:0] 	DMEM_Control_sel;
wire [0:0] 	DMEM_ID_WE;
wire [0:0] 	DMEM_Data_sel;
wire [0:0] 	LOAD_EN; //for Load in second clock
wire [0:0]	JUMP_LINK;
wire [1:0]	INOUT_F;
///////EXE_stage///////////
/*
wire [31:0] DMEM_DATA_WB_w;
wire [0:0] 	DMEM_WE;
wire [31:0] DMEM_Addr;
wire [31:0] DMEM_Data;
*/
//////TOP INOUT connect//////
assign PC = PC_IF;
//reset remaining:	The reset value can be reset by outside. 
//But now, the wire is not routed yet. 

CPU_IF IF_stage(
.clk(clk),
.rst(rst),
.en(en),
.PC_temp(PC_temp),
.PC_jump_flag(PC_jump_flag),
.IMEM_Dout(IMEM_Dout),
.PC_IF(PC_IF),
.IR(IR),
.LOAD_happened(LOAD_happened)
    );

	
CPU_ID ID_stage(
.clk(clk),
.rst(rst),
.en(en),
.PC_IF(PC_IF),
.IR(IR),
.ALU_input_sel_Ra(ALU_input_sel_Ra),
.ALU_input_sel_Rb(ALU_input_sel_Rb),
.PC_ID(PC_ID),
.ALU_op(ALU_op),
.ALU_Ra(ALU_Ra),
.ALU_Rb(ALU_Rb),
.ALU_Imm(ALU_Imm),
.ALU_Rd_WB_sel(ALU_Rd_WB_sel),
.ALU_Rd_WB_en(ALU_Rd_WB_en),
.ALU_FLAG_WB_en(ALU_FLAG_WB_en),
.JUMP_cond(JUMP_cond),
.DMEM_Control_sel(DMEM_Control_sel),
.DMEM_ID_WE(DMEM_ID_WE),
.DMEM_Data_sel(DMEM_Data_sel),
.LOAD_EN(LOAD_EN), //for Load in second clock
.LOAD_happened(LOAD_happened),
.JUMP_LINK(JUMP_LINK),
.INOUT_F(INOUT_F)
    );	
	
CPU_EX EXE_stage(
.clk(clk),
.rst(rst),
.en(en),
.ALU_input_sel_Ra(ALU_input_sel_Ra),
.ALU_input_sel_Rb(ALU_input_sel_Rb),
.PC_ID(PC_ID),
.ALU_op(ALU_op),
.ALU_Ra(ALU_Ra),
.ALU_Rb(ALU_Rb),
.ALU_Imm(ALU_Imm),
.ALU_Rd_WB_sel(ALU_Rd_WB_sel),
.ALU_Rd_WB_en(ALU_Rd_WB_en),
.ALU_FLAG_WB_en(ALU_FLAG_WB_en),
.JUMP_cond(JUMP_cond),
.DMEM_Control_sel(DMEM_Control_sel),
.DMEM_ID_WE(DMEM_ID_WE),
.DMEM_Data_sel(DMEM_Data_sel),
.DMEM_DATA_WB_w(DMEM_DATA_WB_w),
.LOAD_EN(LOAD_EN),
.JUMP_LINK(JUMP_LINK),
.INOUT_F(INOUT_F),
.IN_DATA(IN_DATA),
.OUT_DATA(OUT_DATA),
.INOUT_ADDR(INOUT_ADDR),
.DMEM_WE(DMEM_WE),
.DMEM_Addr(DMEM_Addr),
.DMEM_Data(DMEM_Data),
.PC_temp(PC_temp),
.PC_jump_flag(PC_jump_flag) //if 1 then jump //if 0 then no jump
    );
	
//////CPU MCACHE////////


//////CPU ICACHE////////

endmodule

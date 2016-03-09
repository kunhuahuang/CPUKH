#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include "output.h"

 //reg00 :  reset
 //reg01 :	IMEM_base_addr;    //offset now are set by hardware 0X3FF
 //reg02 :	DMEM_base_addr;
 //reg03 :	PC
 //reg04 :	DMEM_Addr
 //reg05 :	IN_DATA
 //reg06 :	OUT_DATA
 //reg07 :	INOUT_ADDR
 //reg08 :	IMEM_ADDR_w
 //reg09 :	IMEM_DIN_w
 //reg10 :	IMEM_DOUT_w
 //reg11 :	IMEM_WE_w
 //reg12 :	DMEM_ADDR_w
 //reg13 :	DMEM_DIN_w
 //reg14 :	DMEM_DOUT_w
 //reg15 :	DMEM_WE_w

#define reset 				0	
#define IMEM_base_addr 	 		 4
#define DMEM_base_addr 	 		 8
#define PC			 	 		12
#define IMEM_ADDR_w 	 		32
#define IMEM_DIN_w 		 	 	36
#define IMEM_DOUT_w		 	 	40
#define IMEM_WE_w 		 	 	44

#define DMEM_ADDR_w 	 	 	48
#define DMEM_DIN_w 		 	 	52
#define DMEM_DOUT_w      	 	56
#define DMEM_WE_w 		 	 	60

#define IN_DATA 		 	 	20
#define OUT_DATA 		 	 	24
#define INOUT_ADDR 		 		28
static int cpukh_dev;

void write_register(off_t offset, uint32_t data){
	lseek(cpukh_dev,offset,SEEK_SET);
	write(cpukh_dev,&data,sizeof(data));
}

uint32_t read_register(off_t offset){
	uint32_t data;
	lseek(cpukh_dev,offset,SEEK_SET);
	read(cpukh_dev,&data,sizeof(data));
	return data;
}

void write_instr_burst(unsigned int instr_addr, unsigned int instr){
	write_register(IMEM_ADDR_w,instr_addr);//set the Memory address
	write_register(IMEM_DIN_w,instr); //set the data which you want to write in
}
void write_data_burst(unsigned int instr_addr, unsigned int instr){
	write_register(DMEM_ADDR_w,instr_addr);//set the Memory address
	write_register(DMEM_DIN_w,instr); //set the data which you want to write in
}

void init(void)
{
	//shut down the cpu
	write_register(IMEM_base_addr, 0x40000000);
	write_register(DMEM_base_addr, 0x40000000);
	//reset the memory value in a block
	write_register(IMEM_WE_w,1);//set write enable
	
	//Clear al data
	int instr_count;
	for(instr_count = 0; instr_count < 1024; instr_count ++)
	{
		write_instr_burst(instr_count, 0x00000000);
		write_data_burst(instr_count, 0x00000000);
	}
	write_register(IMEM_WE_w,0x00000000);//set write disable
}
void write_instr(unsigned int instr_addr, unsigned int instr){
	write_register(IMEM_ADDR_w,instr_addr);//set the Memory address
	write_register(IMEM_WE_w,1);//set write enable
	write_register(IMEM_DIN_w,instr); //set the data which you want to write in
	write_register(IMEM_WE_w,0);//set write disable
}
void write_IMEM(void){
	/* write to fpga */
	unsigned int addr = 0, value = 0;
	unsigned int index;
	for (index = 0; index < khasm_code_size; index++) {
		addr = khasm_code[index][0];
		value = khasm_code[index][1];
		write_instr(addr, value);
	}
//	write_instr(3, 0x);
}

void run_cpu(void){
	//init the cpu
	write_register(IMEM_base_addr, 0x00000000);
	write_register(DMEM_base_addr, 0x00000000);
	//reset the cpu
	write_register(reset, 0x0);
	write_register(reset, 0xffffffff);
	write_register(reset, 0);
	write_register(reset, 0xffffffff);
}
int main()
{
	int led_dev = open("/dev/led", O_RDWR);
    if (led_dev < 0) {
            printf("error: failed to open device /dev/led\n");
            return 0;
    }
    int sw_dev = open("/dev/sw", O_RDWR);
    if (sw_dev < 0) {
            printf("error: failed to open device /dev/sw\n");
            return 0;
    }
    cpukh_dev = open("/dev/cpukh", O_RDWR);
    if (cpukh_dev < 0) {
            printf("error: failed to open device /dev/cpukh_dev\n");
            return 0;
    }
    printf("opened device\n");

	init();
	write_IMEM();
	run_cpu();

	//PUT sw value to cpu input. Than take the output value to led.
	uint32_t switch_value;
	uint32_t cpu_output;
	while(1){
		read(sw_dev,&switch_value,sizeof(switch_value));
		write_register(IN_DATA , switch_value );
		cpu_output = read_register(OUT_DATA);
		printf("\rOUTDATA = %d\t\t\tINDATA = %d", cpu_output, switch_value);
		write(led_dev,&cpu_output,sizeof(cpu_output));
		usleep(1e3);
	}
    close(led_dev);
    close(sw_dev);
	close(cpukh_dev); 
    printf("closed device\n");
    return 0;

}


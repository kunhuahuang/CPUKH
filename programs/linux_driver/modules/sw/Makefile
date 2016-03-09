
obj-m += sw_driver.o
KERNEL_SRC=/lib/module/linux-xlnx/

all:
	make -C $(KERNEL_SRC) M=$(PWD) modules
clean:
	make -C $(KERNEL_SRC) M=$(PWD) clean


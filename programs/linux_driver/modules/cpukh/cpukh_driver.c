/**************************************************
 *
 * Filename: cpukh_driver.c
 * Author: KunHua Huang <kunhuahuang@hotmail.com>
 * Created: 2014-10-2
 * Description: This driver is for CPUKH
 *   
 *
 **************************************************/

#include <linux/init.h>
#include <linux/platform_device.h>
#include <linux/module.h>
#include <linux/cdev.h>
#include <linux/fs.h>
#include <linux/uaccess.h>    /*for copy_to_user, copy_from_user*/
#include <linux/proc_fs.h>
#include <linux/slab.h>
#include <linux/seq_file.h>
#include <asm/io.h>

#define DEVICE_NAME         "cpukh_dev"

#define DEVICE_BASE_ADDR	0x70A00000
#define DEVICE_REG		16
#define DEVICE_WIDTH		32
#define MODULE_NAME 		"Cpukh"



static int cpukh_major = 0;    /*Dynamic*/
//static int cpukh_minor = 0;

MODULE_AUTHOR("Kun Hua");
MODULE_DESCRIPTION("Cpukh driver for Zedboard");
MODULE_LICENSE("GPL");

/*
 * IO ranges
 */
static void __iomem *CPUKH_REG_MAP; //Virtual memory address

/*
 * CDev instance
 */
typedef struct cpukh_cdev_t{
    struct cdev dev;
//    uint32_t offset;
}cpukh_cdev_t;
struct cpukh_cdev_t *cpukh_devs;

/*
 * Real implementations
 */

static int cpukh_open(struct inode * inode , struct file * filp)
{
    struct cpukh_cdev_t *dev;

    /*
     * This is a function used to get the pointer to the container
     * structure when we knows a member of it
     */
    dev = container_of( inode->i_cdev, struct cpukh_cdev_t, dev );

    // Assign it to private_data, that way we can know the offset of it
    filp->private_data = dev;
    return 0;
}

static int cpukh_release(struct inode * inode, struct file *filp)
{
    return 0;
}
static ssize_t cpukh_read(struct file *filp, char __user *buffer, size_t length, loff_t *offset)
{
	loff_t addr_offset = *offset; //byte
    	uint32_t data;
 //   cpukh_cdev_t *dev = filp->private_data;

	if( (length >> 2) > DEVICE_REG)
	{	
		printk( KERN_NOTICE MODULE_NAME "Length in read is out of range!\n");
		return -1;
	}

	if(  ((addr_offset >> 2 ) <<2 ) == addr_offset)//do nothing if byte read
	{		
		data = ioread32(CPUKH_REG_MAP + addr_offset );    	// Read data from the target memory
	}
	
	if(copy_to_user( buffer, &data, 4 ))	// copy a word
	{	
		printk( KERN_NOTICE MODULE_NAME "The data can not copy to user!\n");
		return -1;
	}
	
	return 4;
}

ssize_t cpukh_write( struct file *filp, const char __user *buffer, size_t length, loff_t *offset ){

	loff_t	 addr_offset = *offset; //byte

    uint32_t data;
//    cpukh_cdev_t *dev = filp->private_data;
	if( (length >> 2) > DEVICE_REG)
	{	
		printk( KERN_NOTICE MODULE_NAME "Length in write is out of range!\n");
		return -1;
	}

	if(copy_from_user( &data, buffer, 4))	// copy a word
	{	
		printk( KERN_NOTICE MODULE_NAME "The data can not copy from user!\n");
		return -1;
	}
	if(  ((addr_offset >> 2 ) <<2 ) == addr_offset)//do nothing if byte read
	{		
		iowrite32( data, CPUKH_REG_MAP + addr_offset );  // Write data to the target
	}
    return 4;
}
loff_t cpukh_llseek(struct file *filp, loff_t off, int whence)
{
//	struct cpukh_cdev_t *dev = filp->private_data;
	loff_t newpos;
	switch(whence)
	{
        case 0: /* SEEK_SET */
                newpos = off;
                break;

        case 1: /* SEEK_CUR */
                newpos = filp->f_pos + off;
                break;
//        case 2: /* SEEK_END */
  //              newpos = dev->length + off;
 //               break;
	

	 default: /* can't happen */
                return -EINVAL;
	}
	if (newpos < 0)
                return -EINVAL;
        filp->f_pos = newpos;
        return newpos;
}



static const struct file_operations cpukh_fops =
{
    .owner = THIS_MODULE,
    .llseek = cpukh_llseek,
    .open = cpukh_open,
    .release = cpukh_release,
    .read = cpukh_read,
    .write = cpukh_write,
};

// Register a dev file under /dev
static void setupCDev( struct cpukh_cdev_t *dev, int index ){
    int err , dev_no = MKDEV(cpukh_major, index);
    cdev_init( &dev->dev, &cpukh_fops );
    dev->dev.owner = THIS_MODULE;
    dev->dev.ops = &cpukh_fops;
    err = cdev_add( &dev->dev, dev_no, 1 );
    if( err ){
        printk(KERN_NOTICE MODULE_NAME "Error adding device\n");
    }
}


int __init cpukh_init(void)
{
    int ret;
    dev_t dev = 0;

    // Map device to the virtual address of kernel
    // Set it to the first input register

	CPUKH_REG_MAP = ioremap(DEVICE_BASE_ADDR, DEVICE_REG << 2);
    if(CPUKH_REG_MAP == NULL)
    {
        printk( KERN_NOTICE MODULE_NAME "The access address is NULL!\n");
        return -EIO;
    }    
	
	/*Register device*/
    if( cpukh_major ) {
        dev = MKDEV( cpukh_major, 0 );
        ret = register_chrdev_region(dev, 1, "cpukh_driver");
    } else {    /*dynamic method*/
        ret = alloc_chrdev_region( &dev, 0, 1, "cpukh_driver" );
        cpukh_major = MAJOR( dev );
    }
	if(ret < 0){
		printk( KERN_NOTICE MODULE_NAME "The register_chrdev do not done!\n");
		return ret;
	}
	
    /* Allocate memory for device nodes */
    cpukh_devs = kmalloc(
        DEVICE_REG * sizeof( struct cpukh_cdev_t ), GFP_KERNEL );
    memset( cpukh_devs, 0,
        DEVICE_REG * sizeof( struct cpukh_cdev_t ) );
    /* Initialize the device */
    setupCDev( cpukh_devs, 0 );
	
    printk( KERN_NOTICE MODULE_NAME "module cpukh start\n");

    return 0; /* Success */
}

void __exit cpukh_exit(void)
{
    dev_t dev_no = MKDEV( cpukh_major,  0);
	cdev_del( &cpukh_devs->dev );//////
    kfree( cpukh_devs );
    unregister_chrdev_region( dev_no, 1 );

    // Unmapping the Virtual address
    iounmap(CPUKH_REG_MAP);

    printk( KERN_NOTICE MODULE_NAME "module cpukh exit\n");
}

module_init(cpukh_init);
module_exit(cpukh_exit);




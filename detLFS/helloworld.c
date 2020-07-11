// $Id: helloworld.c 2 2016-07-24 17:50:19Z dettus $ 
#include <stdio.h>
#include <linux/limits.h>
#include <sys/types.h>
#include <string.h>
int main(void)
{
	printf("hello \x1B[0;34mW\x1B[1;34mo\x1B[0;36mr\x1B[1;36ml\x1B[1;37md\x1B[0m\n");
}

/* readfifo.c -- Read a FIFO and print its data */
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <signal.h>
static int end;

struct data{
float t;
float u[1];
};

static void do_end(int dummy) { end = 1; }
int main (void)
{
int fifo;
struct data val;
if ((fifo = open("/dev/rtf0", O_RDONLY)) < 0) {
fprintf(stderr, "Error opening /dev/rtf0\n");
exit(1);
}
signal(SIGINT, do_end);
while (!end) {
read(fifo, &val, sizeof(val));
printf("%f\t%f\n", val.t, val.u[0]);
}
return 0;
}

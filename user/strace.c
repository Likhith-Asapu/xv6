#include "kernel/param.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
    char *command[MAXARG];
    printf("argv - %c\n", argv[0][0]);
    if (argc < 3)
    {
        printf("Too few arguments passed to strace\n");
        exit(1);
    }
    if (argc > MAXARG)
    {
        printf("More than max arguments given\n");
        exit(1);
    }
    if (argv[1][0] < '0' && argv[1][0] > '9')
    {
        printf("Invalid mask number\n");
        exit(1);
    }

    if (trace(atoi(argv[1])) < 0)
    {
        printf("strace failed\n");
        exit(1);
    }

    for (int i = 2; i < argc; i++)
    {
        command[i - 2] = argv[i];
    }
    exec(command[0], command);
    exit(0);
}
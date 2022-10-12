#include "../kernel/types.h"
#include "../kernel/param.h"
#include "../kernel/stat.h"
#include "./user.h"

int check_priority_range(int priority){

    if(priority >= 0 || priority <= 100){
        return 1;
    }
    return 0;
}

int main(int argc, char *argv[]){
    
    if(argc < 3){
        fprintf(2, "Incorrect Input !\n");
        fprintf(2, "Correct usage: setpriority <priority> <pid>\n");
        exit(1);
    }

    int priority = atoi(argv[1]);
    int pid = atoi(argv[2]);

    if(check_priority_range(priority) == 0){
        fprintf(2, "Incorrect Range !\n");
        fprintf(2, "Correct Range: [0,100]\n");
        exit(1);
    }

    setpriority(priority, pid);
    exit(1);
}
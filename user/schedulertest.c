#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"


#define NFORK 10
#define IO 5

int main() {
  int n, pid;
  int wtime, rtime;
  int twtime=0, trtime=0;
  for(n=0; n < NFORK;n++) {
    if(n == 4)
        settickets(400);
      else
        settickets(1);
      pid = fork();
      if (pid < 0)
          break;
      if (pid == 0) {
        
#ifndef MLFQ
          if (n < IO) {
            sleep(200); // IO bound processes
          } else {
#endif
            for (uint64 i = 0; i < 1000000000; i++) {} // CPU bound process 
#ifndef MLFQ
          }
#endif
          printf("Process %d finished\n", n);
          exit(0);
      } else {
#ifdef PBS
        setpriority(80, pid); // Will only matter for PBS, set lower priority for IO bound processes 
#endif
      }
  }
  for(;n > 0; n--) {
      if(waitx(0,&wtime,&rtime) >= 0) {
          trtime += rtime;
          twtime += wtime;
      } 
  }
  printf("Average rtime %d,  wtime %d\n", trtime / NFORK, twtime / NFORK);
  exit(0);
}

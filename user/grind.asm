
user/_grind:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <do_rand>:
#include "kernel/riscv.h"

// from FreeBSD.
int
do_rand(unsigned long *ctx)
{
       0:	1141                	addi	sp,sp,-16
       2:	e422                	sd	s0,8(sp)
       4:	0800                	addi	s0,sp,16
 * October 1988, p. 1195.
 */
    long hi, lo, x;

    /* Transform to [1, 0x7ffffffe] range. */
    x = (*ctx % 0x7ffffffe) + 1;
       6:	611c                	ld	a5,0(a0)
       8:	80000737          	lui	a4,0x80000
       c:	ffe74713          	xori	a4,a4,-2
      10:	02e7f7b3          	remu	a5,a5,a4
      14:	0785                	addi	a5,a5,1
    hi = x / 127773;
    lo = x % 127773;
      16:	66fd                	lui	a3,0x1f
      18:	31d68693          	addi	a3,a3,797 # 1f31d <base+0x1cf15>
      1c:	02d7e733          	rem	a4,a5,a3
    x = 16807 * lo - 2836 * hi;
      20:	6611                	lui	a2,0x4
      22:	1a760613          	addi	a2,a2,423 # 41a7 <base+0x1d9f>
      26:	02c70733          	mul	a4,a4,a2
    hi = x / 127773;
      2a:	02d7c7b3          	div	a5,a5,a3
    x = 16807 * lo - 2836 * hi;
      2e:	76fd                	lui	a3,0xfffff
      30:	4ec68693          	addi	a3,a3,1260 # fffffffffffff4ec <base+0xffffffffffffd0e4>
      34:	02d787b3          	mul	a5,a5,a3
      38:	97ba                	add	a5,a5,a4
    if (x < 0)
      3a:	0007c963          	bltz	a5,4c <do_rand+0x4c>
        x += 0x7fffffff;
    /* Transform to [0, 0x7ffffffd] range. */
    x--;
      3e:	17fd                	addi	a5,a5,-1
    *ctx = x;
      40:	e11c                	sd	a5,0(a0)
    return (x);
}
      42:	0007851b          	sext.w	a0,a5
      46:	6422                	ld	s0,8(sp)
      48:	0141                	addi	sp,sp,16
      4a:	8082                	ret
        x += 0x7fffffff;
      4c:	80000737          	lui	a4,0x80000
      50:	fff74713          	not	a4,a4
      54:	97ba                	add	a5,a5,a4
      56:	b7e5                	j	3e <do_rand+0x3e>

0000000000000058 <rand>:

unsigned long rand_next = 1;

int
rand(void)
{
      58:	1141                	addi	sp,sp,-16
      5a:	e406                	sd	ra,8(sp)
      5c:	e022                	sd	s0,0(sp)
      5e:	0800                	addi	s0,sp,16
    return (do_rand(&rand_next));
      60:	00002517          	auipc	a0,0x2
      64:	fa050513          	addi	a0,a0,-96 # 2000 <rand_next>
      68:	00000097          	auipc	ra,0x0
      6c:	f98080e7          	jalr	-104(ra) # 0 <do_rand>
}
      70:	60a2                	ld	ra,8(sp)
      72:	6402                	ld	s0,0(sp)
      74:	0141                	addi	sp,sp,16
      76:	8082                	ret

0000000000000078 <go>:

void
go(int which_child)
{
      78:	7159                	addi	sp,sp,-112
      7a:	f486                	sd	ra,104(sp)
      7c:	f0a2                	sd	s0,96(sp)
      7e:	eca6                	sd	s1,88(sp)
      80:	e8ca                	sd	s2,80(sp)
      82:	e4ce                	sd	s3,72(sp)
      84:	e0d2                	sd	s4,64(sp)
      86:	fc56                	sd	s5,56(sp)
      88:	f85a                	sd	s6,48(sp)
      8a:	1880                	addi	s0,sp,112
      8c:	84aa                	mv	s1,a0
  int fd = -1;
  static char buf[999];
  char *break0 = sbrk(0);
      8e:	4501                	li	a0,0
      90:	00001097          	auipc	ra,0x1
      94:	e8c080e7          	jalr	-372(ra) # f1c <sbrk>
      98:	8aaa                	mv	s5,a0
  uint64 iters = 0;

  mkdir("grindir");
      9a:	00001517          	auipc	a0,0x1
      9e:	34650513          	addi	a0,a0,838 # 13e0 <malloc+0xe6>
      a2:	00001097          	auipc	ra,0x1
      a6:	e5a080e7          	jalr	-422(ra) # efc <mkdir>
  if(chdir("grindir") != 0){
      aa:	00001517          	auipc	a0,0x1
      ae:	33650513          	addi	a0,a0,822 # 13e0 <malloc+0xe6>
      b2:	00001097          	auipc	ra,0x1
      b6:	e52080e7          	jalr	-430(ra) # f04 <chdir>
      ba:	cd11                	beqz	a0,d6 <go+0x5e>
    printf("grind: chdir grindir failed\n");
      bc:	00001517          	auipc	a0,0x1
      c0:	32c50513          	addi	a0,a0,812 # 13e8 <malloc+0xee>
      c4:	00001097          	auipc	ra,0x1
      c8:	178080e7          	jalr	376(ra) # 123c <printf>
    exit(1);
      cc:	4505                	li	a0,1
      ce:	00001097          	auipc	ra,0x1
      d2:	dc6080e7          	jalr	-570(ra) # e94 <exit>
  }
  chdir("/");
      d6:	00001517          	auipc	a0,0x1
      da:	33250513          	addi	a0,a0,818 # 1408 <malloc+0x10e>
      de:	00001097          	auipc	ra,0x1
      e2:	e26080e7          	jalr	-474(ra) # f04 <chdir>
  
  while(1){
    iters++;
    if((iters % 500) == 0)
      e6:	00001997          	auipc	s3,0x1
      ea:	33298993          	addi	s3,s3,818 # 1418 <malloc+0x11e>
      ee:	c489                	beqz	s1,f8 <go+0x80>
      f0:	00001997          	auipc	s3,0x1
      f4:	32098993          	addi	s3,s3,800 # 1410 <malloc+0x116>
    iters++;
      f8:	4485                	li	s1,1
  int fd = -1;
      fa:	597d                	li	s2,-1
      close(fd);
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
    } else if(what == 7){
      write(fd, buf, sizeof(buf));
    } else if(what == 8){
      read(fd, buf, sizeof(buf));
      fc:	00002a17          	auipc	s4,0x2
     100:	f24a0a13          	addi	s4,s4,-220 # 2020 <buf.0>
     104:	a825                	j	13c <go+0xc4>
      close(open("grindir/../a", O_CREATE|O_RDWR));
     106:	20200593          	li	a1,514
     10a:	00001517          	auipc	a0,0x1
     10e:	31650513          	addi	a0,a0,790 # 1420 <malloc+0x126>
     112:	00001097          	auipc	ra,0x1
     116:	dc2080e7          	jalr	-574(ra) # ed4 <open>
     11a:	00001097          	auipc	ra,0x1
     11e:	da2080e7          	jalr	-606(ra) # ebc <close>
    iters++;
     122:	0485                	addi	s1,s1,1
    if((iters % 500) == 0)
     124:	1f400793          	li	a5,500
     128:	02f4f7b3          	remu	a5,s1,a5
     12c:	eb81                	bnez	a5,13c <go+0xc4>
      write(1, which_child?"B":"A", 1);
     12e:	4605                	li	a2,1
     130:	85ce                	mv	a1,s3
     132:	4505                	li	a0,1
     134:	00001097          	auipc	ra,0x1
     138:	d80080e7          	jalr	-640(ra) # eb4 <write>
    int what = rand() % 23;
     13c:	00000097          	auipc	ra,0x0
     140:	f1c080e7          	jalr	-228(ra) # 58 <rand>
     144:	47dd                	li	a5,23
     146:	02f5653b          	remw	a0,a0,a5
    if(what == 1){
     14a:	4785                	li	a5,1
     14c:	faf50de3          	beq	a0,a5,106 <go+0x8e>
    } else if(what == 2){
     150:	4789                	li	a5,2
     152:	18f50563          	beq	a0,a5,2dc <go+0x264>
    } else if(what == 3){
     156:	478d                	li	a5,3
     158:	1af50163          	beq	a0,a5,2fa <go+0x282>
    } else if(what == 4){
     15c:	4791                	li	a5,4
     15e:	1af50763          	beq	a0,a5,30c <go+0x294>
    } else if(what == 5){
     162:	4795                	li	a5,5
     164:	1ef50b63          	beq	a0,a5,35a <go+0x2e2>
    } else if(what == 6){
     168:	4799                	li	a5,6
     16a:	20f50963          	beq	a0,a5,37c <go+0x304>
    } else if(what == 7){
     16e:	479d                	li	a5,7
     170:	22f50763          	beq	a0,a5,39e <go+0x326>
    } else if(what == 8){
     174:	47a1                	li	a5,8
     176:	22f50d63          	beq	a0,a5,3b0 <go+0x338>
    } else if(what == 9){
     17a:	47a5                	li	a5,9
     17c:	24f50363          	beq	a0,a5,3c2 <go+0x34a>
      mkdir("grindir/../a");
      close(open("a/../a/./a", O_CREATE|O_RDWR));
      unlink("a/a");
    } else if(what == 10){
     180:	47a9                	li	a5,10
     182:	26f50f63          	beq	a0,a5,400 <go+0x388>
      mkdir("/../b");
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
      unlink("b/b");
    } else if(what == 11){
     186:	47ad                	li	a5,11
     188:	2af50b63          	beq	a0,a5,43e <go+0x3c6>
      unlink("b");
      link("../grindir/./../a", "../b");
    } else if(what == 12){
     18c:	47b1                	li	a5,12
     18e:	2cf50d63          	beq	a0,a5,468 <go+0x3f0>
      unlink("../grindir/../a");
      link(".././b", "/grindir/../a");
    } else if(what == 13){
     192:	47b5                	li	a5,13
     194:	2ef50f63          	beq	a0,a5,492 <go+0x41a>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 14){
     198:	47b9                	li	a5,14
     19a:	32f50a63          	beq	a0,a5,4ce <go+0x456>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 15){
     19e:	47bd                	li	a5,15
     1a0:	36f50e63          	beq	a0,a5,51c <go+0x4a4>
      sbrk(6011);
    } else if(what == 16){
     1a4:	47c1                	li	a5,16
     1a6:	38f50363          	beq	a0,a5,52c <go+0x4b4>
      if(sbrk(0) > break0)
        sbrk(-(sbrk(0) - break0));
    } else if(what == 17){
     1aa:	47c5                	li	a5,17
     1ac:	3af50363          	beq	a0,a5,552 <go+0x4da>
        printf("grind: chdir failed\n");
        exit(1);
      }
      kill(pid);
      wait(0);
    } else if(what == 18){
     1b0:	47c9                	li	a5,18
     1b2:	42f50963          	beq	a0,a5,5e4 <go+0x56c>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 19){
     1b6:	47cd                	li	a5,19
     1b8:	46f50d63          	beq	a0,a5,632 <go+0x5ba>
        exit(1);
      }
      close(fds[0]);
      close(fds[1]);
      wait(0);
    } else if(what == 20){
     1bc:	47d1                	li	a5,20
     1be:	54f50e63          	beq	a0,a5,71a <go+0x6a2>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 21){
     1c2:	47d5                	li	a5,21
     1c4:	5ef50c63          	beq	a0,a5,7bc <go+0x744>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
        exit(1);
      }
      close(fd1);
      unlink("c");
    } else if(what == 22){
     1c8:	47d9                	li	a5,22
     1ca:	f4f51ce3          	bne	a0,a5,122 <go+0xaa>
      // echo hi | cat
      int aa[2], bb[2];
      if(pipe(aa) < 0){
     1ce:	f9840513          	addi	a0,s0,-104
     1d2:	00001097          	auipc	ra,0x1
     1d6:	cd2080e7          	jalr	-814(ra) # ea4 <pipe>
     1da:	6e054563          	bltz	a0,8c4 <go+0x84c>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      if(pipe(bb) < 0){
     1de:	fa040513          	addi	a0,s0,-96
     1e2:	00001097          	auipc	ra,0x1
     1e6:	cc2080e7          	jalr	-830(ra) # ea4 <pipe>
     1ea:	6e054b63          	bltz	a0,8e0 <go+0x868>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      int pid1 = fork();
     1ee:	00001097          	auipc	ra,0x1
     1f2:	c9e080e7          	jalr	-866(ra) # e8c <fork>
      if(pid1 == 0){
     1f6:	70050363          	beqz	a0,8fc <go+0x884>
        close(aa[1]);
        char *args[3] = { "echo", "hi", 0 };
        exec("grindir/../echo", args);
        fprintf(2, "grind: echo: not found\n");
        exit(2);
      } else if(pid1 < 0){
     1fa:	7a054b63          	bltz	a0,9b0 <go+0x938>
        fprintf(2, "grind: fork failed\n");
        exit(3);
      }
      int pid2 = fork();
     1fe:	00001097          	auipc	ra,0x1
     202:	c8e080e7          	jalr	-882(ra) # e8c <fork>
      if(pid2 == 0){
     206:	7c050363          	beqz	a0,9cc <go+0x954>
        close(bb[1]);
        char *args[2] = { "cat", 0 };
        exec("/cat", args);
        fprintf(2, "grind: cat: not found\n");
        exit(6);
      } else if(pid2 < 0){
     20a:	08054fe3          	bltz	a0,aa8 <go+0xa30>
        fprintf(2, "grind: fork failed\n");
        exit(7);
      }
      close(aa[0]);
     20e:	f9842503          	lw	a0,-104(s0)
     212:	00001097          	auipc	ra,0x1
     216:	caa080e7          	jalr	-854(ra) # ebc <close>
      close(aa[1]);
     21a:	f9c42503          	lw	a0,-100(s0)
     21e:	00001097          	auipc	ra,0x1
     222:	c9e080e7          	jalr	-866(ra) # ebc <close>
      close(bb[1]);
     226:	fa442503          	lw	a0,-92(s0)
     22a:	00001097          	auipc	ra,0x1
     22e:	c92080e7          	jalr	-878(ra) # ebc <close>
      char buf[4] = { 0, 0, 0, 0 };
     232:	f8042823          	sw	zero,-112(s0)
      read(bb[0], buf+0, 1);
     236:	4605                	li	a2,1
     238:	f9040593          	addi	a1,s0,-112
     23c:	fa042503          	lw	a0,-96(s0)
     240:	00001097          	auipc	ra,0x1
     244:	c6c080e7          	jalr	-916(ra) # eac <read>
      read(bb[0], buf+1, 1);
     248:	4605                	li	a2,1
     24a:	f9140593          	addi	a1,s0,-111
     24e:	fa042503          	lw	a0,-96(s0)
     252:	00001097          	auipc	ra,0x1
     256:	c5a080e7          	jalr	-934(ra) # eac <read>
      read(bb[0], buf+2, 1);
     25a:	4605                	li	a2,1
     25c:	f9240593          	addi	a1,s0,-110
     260:	fa042503          	lw	a0,-96(s0)
     264:	00001097          	auipc	ra,0x1
     268:	c48080e7          	jalr	-952(ra) # eac <read>
      close(bb[0]);
     26c:	fa042503          	lw	a0,-96(s0)
     270:	00001097          	auipc	ra,0x1
     274:	c4c080e7          	jalr	-948(ra) # ebc <close>
      int st1, st2;
      wait(&st1);
     278:	f9440513          	addi	a0,s0,-108
     27c:	00001097          	auipc	ra,0x1
     280:	c20080e7          	jalr	-992(ra) # e9c <wait>
      wait(&st2);
     284:	fa840513          	addi	a0,s0,-88
     288:	00001097          	auipc	ra,0x1
     28c:	c14080e7          	jalr	-1004(ra) # e9c <wait>
      if(st1 != 0 || st2 != 0 || strcmp(buf, "hi\n") != 0){
     290:	f9442783          	lw	a5,-108(s0)
     294:	fa842703          	lw	a4,-88(s0)
     298:	8fd9                	or	a5,a5,a4
     29a:	2781                	sext.w	a5,a5
     29c:	ef89                	bnez	a5,2b6 <go+0x23e>
     29e:	00001597          	auipc	a1,0x1
     2a2:	3fa58593          	addi	a1,a1,1018 # 1698 <malloc+0x39e>
     2a6:	f9040513          	addi	a0,s0,-112
     2aa:	00001097          	auipc	ra,0x1
     2ae:	998080e7          	jalr	-1640(ra) # c42 <strcmp>
     2b2:	e60508e3          	beqz	a0,122 <go+0xaa>
        printf("grind: exec pipeline failed %d %d \"%s\"\n", st1, st2, buf);
     2b6:	f9040693          	addi	a3,s0,-112
     2ba:	fa842603          	lw	a2,-88(s0)
     2be:	f9442583          	lw	a1,-108(s0)
     2c2:	00001517          	auipc	a0,0x1
     2c6:	3de50513          	addi	a0,a0,990 # 16a0 <malloc+0x3a6>
     2ca:	00001097          	auipc	ra,0x1
     2ce:	f72080e7          	jalr	-142(ra) # 123c <printf>
        exit(1);
     2d2:	4505                	li	a0,1
     2d4:	00001097          	auipc	ra,0x1
     2d8:	bc0080e7          	jalr	-1088(ra) # e94 <exit>
      close(open("grindir/../grindir/../b", O_CREATE|O_RDWR));
     2dc:	20200593          	li	a1,514
     2e0:	00001517          	auipc	a0,0x1
     2e4:	15050513          	addi	a0,a0,336 # 1430 <malloc+0x136>
     2e8:	00001097          	auipc	ra,0x1
     2ec:	bec080e7          	jalr	-1044(ra) # ed4 <open>
     2f0:	00001097          	auipc	ra,0x1
     2f4:	bcc080e7          	jalr	-1076(ra) # ebc <close>
     2f8:	b52d                	j	122 <go+0xaa>
      unlink("grindir/../a");
     2fa:	00001517          	auipc	a0,0x1
     2fe:	12650513          	addi	a0,a0,294 # 1420 <malloc+0x126>
     302:	00001097          	auipc	ra,0x1
     306:	be2080e7          	jalr	-1054(ra) # ee4 <unlink>
     30a:	bd21                	j	122 <go+0xaa>
      if(chdir("grindir") != 0){
     30c:	00001517          	auipc	a0,0x1
     310:	0d450513          	addi	a0,a0,212 # 13e0 <malloc+0xe6>
     314:	00001097          	auipc	ra,0x1
     318:	bf0080e7          	jalr	-1040(ra) # f04 <chdir>
     31c:	e115                	bnez	a0,340 <go+0x2c8>
      unlink("../b");
     31e:	00001517          	auipc	a0,0x1
     322:	12a50513          	addi	a0,a0,298 # 1448 <malloc+0x14e>
     326:	00001097          	auipc	ra,0x1
     32a:	bbe080e7          	jalr	-1090(ra) # ee4 <unlink>
      chdir("/");
     32e:	00001517          	auipc	a0,0x1
     332:	0da50513          	addi	a0,a0,218 # 1408 <malloc+0x10e>
     336:	00001097          	auipc	ra,0x1
     33a:	bce080e7          	jalr	-1074(ra) # f04 <chdir>
     33e:	b3d5                	j	122 <go+0xaa>
        printf("grind: chdir grindir failed\n");
     340:	00001517          	auipc	a0,0x1
     344:	0a850513          	addi	a0,a0,168 # 13e8 <malloc+0xee>
     348:	00001097          	auipc	ra,0x1
     34c:	ef4080e7          	jalr	-268(ra) # 123c <printf>
        exit(1);
     350:	4505                	li	a0,1
     352:	00001097          	auipc	ra,0x1
     356:	b42080e7          	jalr	-1214(ra) # e94 <exit>
      close(fd);
     35a:	854a                	mv	a0,s2
     35c:	00001097          	auipc	ra,0x1
     360:	b60080e7          	jalr	-1184(ra) # ebc <close>
      fd = open("/grindir/../a", O_CREATE|O_RDWR);
     364:	20200593          	li	a1,514
     368:	00001517          	auipc	a0,0x1
     36c:	0e850513          	addi	a0,a0,232 # 1450 <malloc+0x156>
     370:	00001097          	auipc	ra,0x1
     374:	b64080e7          	jalr	-1180(ra) # ed4 <open>
     378:	892a                	mv	s2,a0
     37a:	b365                	j	122 <go+0xaa>
      close(fd);
     37c:	854a                	mv	a0,s2
     37e:	00001097          	auipc	ra,0x1
     382:	b3e080e7          	jalr	-1218(ra) # ebc <close>
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
     386:	20200593          	li	a1,514
     38a:	00001517          	auipc	a0,0x1
     38e:	0d650513          	addi	a0,a0,214 # 1460 <malloc+0x166>
     392:	00001097          	auipc	ra,0x1
     396:	b42080e7          	jalr	-1214(ra) # ed4 <open>
     39a:	892a                	mv	s2,a0
     39c:	b359                	j	122 <go+0xaa>
      write(fd, buf, sizeof(buf));
     39e:	3e700613          	li	a2,999
     3a2:	85d2                	mv	a1,s4
     3a4:	854a                	mv	a0,s2
     3a6:	00001097          	auipc	ra,0x1
     3aa:	b0e080e7          	jalr	-1266(ra) # eb4 <write>
     3ae:	bb95                	j	122 <go+0xaa>
      read(fd, buf, sizeof(buf));
     3b0:	3e700613          	li	a2,999
     3b4:	85d2                	mv	a1,s4
     3b6:	854a                	mv	a0,s2
     3b8:	00001097          	auipc	ra,0x1
     3bc:	af4080e7          	jalr	-1292(ra) # eac <read>
     3c0:	b38d                	j	122 <go+0xaa>
      mkdir("grindir/../a");
     3c2:	00001517          	auipc	a0,0x1
     3c6:	05e50513          	addi	a0,a0,94 # 1420 <malloc+0x126>
     3ca:	00001097          	auipc	ra,0x1
     3ce:	b32080e7          	jalr	-1230(ra) # efc <mkdir>
      close(open("a/../a/./a", O_CREATE|O_RDWR));
     3d2:	20200593          	li	a1,514
     3d6:	00001517          	auipc	a0,0x1
     3da:	0a250513          	addi	a0,a0,162 # 1478 <malloc+0x17e>
     3de:	00001097          	auipc	ra,0x1
     3e2:	af6080e7          	jalr	-1290(ra) # ed4 <open>
     3e6:	00001097          	auipc	ra,0x1
     3ea:	ad6080e7          	jalr	-1322(ra) # ebc <close>
      unlink("a/a");
     3ee:	00001517          	auipc	a0,0x1
     3f2:	09a50513          	addi	a0,a0,154 # 1488 <malloc+0x18e>
     3f6:	00001097          	auipc	ra,0x1
     3fa:	aee080e7          	jalr	-1298(ra) # ee4 <unlink>
     3fe:	b315                	j	122 <go+0xaa>
      mkdir("/../b");
     400:	00001517          	auipc	a0,0x1
     404:	09050513          	addi	a0,a0,144 # 1490 <malloc+0x196>
     408:	00001097          	auipc	ra,0x1
     40c:	af4080e7          	jalr	-1292(ra) # efc <mkdir>
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
     410:	20200593          	li	a1,514
     414:	00001517          	auipc	a0,0x1
     418:	08450513          	addi	a0,a0,132 # 1498 <malloc+0x19e>
     41c:	00001097          	auipc	ra,0x1
     420:	ab8080e7          	jalr	-1352(ra) # ed4 <open>
     424:	00001097          	auipc	ra,0x1
     428:	a98080e7          	jalr	-1384(ra) # ebc <close>
      unlink("b/b");
     42c:	00001517          	auipc	a0,0x1
     430:	07c50513          	addi	a0,a0,124 # 14a8 <malloc+0x1ae>
     434:	00001097          	auipc	ra,0x1
     438:	ab0080e7          	jalr	-1360(ra) # ee4 <unlink>
     43c:	b1dd                	j	122 <go+0xaa>
      unlink("b");
     43e:	00001517          	auipc	a0,0x1
     442:	03250513          	addi	a0,a0,50 # 1470 <malloc+0x176>
     446:	00001097          	auipc	ra,0x1
     44a:	a9e080e7          	jalr	-1378(ra) # ee4 <unlink>
      link("../grindir/./../a", "../b");
     44e:	00001597          	auipc	a1,0x1
     452:	ffa58593          	addi	a1,a1,-6 # 1448 <malloc+0x14e>
     456:	00001517          	auipc	a0,0x1
     45a:	05a50513          	addi	a0,a0,90 # 14b0 <malloc+0x1b6>
     45e:	00001097          	auipc	ra,0x1
     462:	a96080e7          	jalr	-1386(ra) # ef4 <link>
     466:	b975                	j	122 <go+0xaa>
      unlink("../grindir/../a");
     468:	00001517          	auipc	a0,0x1
     46c:	06050513          	addi	a0,a0,96 # 14c8 <malloc+0x1ce>
     470:	00001097          	auipc	ra,0x1
     474:	a74080e7          	jalr	-1420(ra) # ee4 <unlink>
      link(".././b", "/grindir/../a");
     478:	00001597          	auipc	a1,0x1
     47c:	fd858593          	addi	a1,a1,-40 # 1450 <malloc+0x156>
     480:	00001517          	auipc	a0,0x1
     484:	05850513          	addi	a0,a0,88 # 14d8 <malloc+0x1de>
     488:	00001097          	auipc	ra,0x1
     48c:	a6c080e7          	jalr	-1428(ra) # ef4 <link>
     490:	b949                	j	122 <go+0xaa>
      int pid = fork();
     492:	00001097          	auipc	ra,0x1
     496:	9fa080e7          	jalr	-1542(ra) # e8c <fork>
      if(pid == 0){
     49a:	c909                	beqz	a0,4ac <go+0x434>
      } else if(pid < 0){
     49c:	00054c63          	bltz	a0,4b4 <go+0x43c>
      wait(0);
     4a0:	4501                	li	a0,0
     4a2:	00001097          	auipc	ra,0x1
     4a6:	9fa080e7          	jalr	-1542(ra) # e9c <wait>
     4aa:	b9a5                	j	122 <go+0xaa>
        exit(0);
     4ac:	00001097          	auipc	ra,0x1
     4b0:	9e8080e7          	jalr	-1560(ra) # e94 <exit>
        printf("grind: fork failed\n");
     4b4:	00001517          	auipc	a0,0x1
     4b8:	02c50513          	addi	a0,a0,44 # 14e0 <malloc+0x1e6>
     4bc:	00001097          	auipc	ra,0x1
     4c0:	d80080e7          	jalr	-640(ra) # 123c <printf>
        exit(1);
     4c4:	4505                	li	a0,1
     4c6:	00001097          	auipc	ra,0x1
     4ca:	9ce080e7          	jalr	-1586(ra) # e94 <exit>
      int pid = fork();
     4ce:	00001097          	auipc	ra,0x1
     4d2:	9be080e7          	jalr	-1602(ra) # e8c <fork>
      if(pid == 0){
     4d6:	c909                	beqz	a0,4e8 <go+0x470>
      } else if(pid < 0){
     4d8:	02054563          	bltz	a0,502 <go+0x48a>
      wait(0);
     4dc:	4501                	li	a0,0
     4de:	00001097          	auipc	ra,0x1
     4e2:	9be080e7          	jalr	-1602(ra) # e9c <wait>
     4e6:	b935                	j	122 <go+0xaa>
        fork();
     4e8:	00001097          	auipc	ra,0x1
     4ec:	9a4080e7          	jalr	-1628(ra) # e8c <fork>
        fork();
     4f0:	00001097          	auipc	ra,0x1
     4f4:	99c080e7          	jalr	-1636(ra) # e8c <fork>
        exit(0);
     4f8:	4501                	li	a0,0
     4fa:	00001097          	auipc	ra,0x1
     4fe:	99a080e7          	jalr	-1638(ra) # e94 <exit>
        printf("grind: fork failed\n");
     502:	00001517          	auipc	a0,0x1
     506:	fde50513          	addi	a0,a0,-34 # 14e0 <malloc+0x1e6>
     50a:	00001097          	auipc	ra,0x1
     50e:	d32080e7          	jalr	-718(ra) # 123c <printf>
        exit(1);
     512:	4505                	li	a0,1
     514:	00001097          	auipc	ra,0x1
     518:	980080e7          	jalr	-1664(ra) # e94 <exit>
      sbrk(6011);
     51c:	6505                	lui	a0,0x1
     51e:	77b50513          	addi	a0,a0,1915 # 177b <digits+0xab>
     522:	00001097          	auipc	ra,0x1
     526:	9fa080e7          	jalr	-1542(ra) # f1c <sbrk>
     52a:	bee5                	j	122 <go+0xaa>
      if(sbrk(0) > break0)
     52c:	4501                	li	a0,0
     52e:	00001097          	auipc	ra,0x1
     532:	9ee080e7          	jalr	-1554(ra) # f1c <sbrk>
     536:	beaaf6e3          	bgeu	s5,a0,122 <go+0xaa>
        sbrk(-(sbrk(0) - break0));
     53a:	4501                	li	a0,0
     53c:	00001097          	auipc	ra,0x1
     540:	9e0080e7          	jalr	-1568(ra) # f1c <sbrk>
     544:	40aa853b          	subw	a0,s5,a0
     548:	00001097          	auipc	ra,0x1
     54c:	9d4080e7          	jalr	-1580(ra) # f1c <sbrk>
     550:	bec9                	j	122 <go+0xaa>
      int pid = fork();
     552:	00001097          	auipc	ra,0x1
     556:	93a080e7          	jalr	-1734(ra) # e8c <fork>
     55a:	8b2a                	mv	s6,a0
      if(pid == 0){
     55c:	c51d                	beqz	a0,58a <go+0x512>
      } else if(pid < 0){
     55e:	04054963          	bltz	a0,5b0 <go+0x538>
      if(chdir("../grindir/..") != 0){
     562:	00001517          	auipc	a0,0x1
     566:	f9650513          	addi	a0,a0,-106 # 14f8 <malloc+0x1fe>
     56a:	00001097          	auipc	ra,0x1
     56e:	99a080e7          	jalr	-1638(ra) # f04 <chdir>
     572:	ed21                	bnez	a0,5ca <go+0x552>
      kill(pid);
     574:	855a                	mv	a0,s6
     576:	00001097          	auipc	ra,0x1
     57a:	94e080e7          	jalr	-1714(ra) # ec4 <kill>
      wait(0);
     57e:	4501                	li	a0,0
     580:	00001097          	auipc	ra,0x1
     584:	91c080e7          	jalr	-1764(ra) # e9c <wait>
     588:	be69                	j	122 <go+0xaa>
        close(open("a", O_CREATE|O_RDWR));
     58a:	20200593          	li	a1,514
     58e:	00001517          	auipc	a0,0x1
     592:	f3250513          	addi	a0,a0,-206 # 14c0 <malloc+0x1c6>
     596:	00001097          	auipc	ra,0x1
     59a:	93e080e7          	jalr	-1730(ra) # ed4 <open>
     59e:	00001097          	auipc	ra,0x1
     5a2:	91e080e7          	jalr	-1762(ra) # ebc <close>
        exit(0);
     5a6:	4501                	li	a0,0
     5a8:	00001097          	auipc	ra,0x1
     5ac:	8ec080e7          	jalr	-1812(ra) # e94 <exit>
        printf("grind: fork failed\n");
     5b0:	00001517          	auipc	a0,0x1
     5b4:	f3050513          	addi	a0,a0,-208 # 14e0 <malloc+0x1e6>
     5b8:	00001097          	auipc	ra,0x1
     5bc:	c84080e7          	jalr	-892(ra) # 123c <printf>
        exit(1);
     5c0:	4505                	li	a0,1
     5c2:	00001097          	auipc	ra,0x1
     5c6:	8d2080e7          	jalr	-1838(ra) # e94 <exit>
        printf("grind: chdir failed\n");
     5ca:	00001517          	auipc	a0,0x1
     5ce:	f3e50513          	addi	a0,a0,-194 # 1508 <malloc+0x20e>
     5d2:	00001097          	auipc	ra,0x1
     5d6:	c6a080e7          	jalr	-918(ra) # 123c <printf>
        exit(1);
     5da:	4505                	li	a0,1
     5dc:	00001097          	auipc	ra,0x1
     5e0:	8b8080e7          	jalr	-1864(ra) # e94 <exit>
      int pid = fork();
     5e4:	00001097          	auipc	ra,0x1
     5e8:	8a8080e7          	jalr	-1880(ra) # e8c <fork>
      if(pid == 0){
     5ec:	c909                	beqz	a0,5fe <go+0x586>
      } else if(pid < 0){
     5ee:	02054563          	bltz	a0,618 <go+0x5a0>
      wait(0);
     5f2:	4501                	li	a0,0
     5f4:	00001097          	auipc	ra,0x1
     5f8:	8a8080e7          	jalr	-1880(ra) # e9c <wait>
     5fc:	b61d                	j	122 <go+0xaa>
        kill(getpid());
     5fe:	00001097          	auipc	ra,0x1
     602:	916080e7          	jalr	-1770(ra) # f14 <getpid>
     606:	00001097          	auipc	ra,0x1
     60a:	8be080e7          	jalr	-1858(ra) # ec4 <kill>
        exit(0);
     60e:	4501                	li	a0,0
     610:	00001097          	auipc	ra,0x1
     614:	884080e7          	jalr	-1916(ra) # e94 <exit>
        printf("grind: fork failed\n");
     618:	00001517          	auipc	a0,0x1
     61c:	ec850513          	addi	a0,a0,-312 # 14e0 <malloc+0x1e6>
     620:	00001097          	auipc	ra,0x1
     624:	c1c080e7          	jalr	-996(ra) # 123c <printf>
        exit(1);
     628:	4505                	li	a0,1
     62a:	00001097          	auipc	ra,0x1
     62e:	86a080e7          	jalr	-1942(ra) # e94 <exit>
      if(pipe(fds) < 0){
     632:	fa840513          	addi	a0,s0,-88
     636:	00001097          	auipc	ra,0x1
     63a:	86e080e7          	jalr	-1938(ra) # ea4 <pipe>
     63e:	02054b63          	bltz	a0,674 <go+0x5fc>
      int pid = fork();
     642:	00001097          	auipc	ra,0x1
     646:	84a080e7          	jalr	-1974(ra) # e8c <fork>
      if(pid == 0){
     64a:	c131                	beqz	a0,68e <go+0x616>
      } else if(pid < 0){
     64c:	0a054a63          	bltz	a0,700 <go+0x688>
      close(fds[0]);
     650:	fa842503          	lw	a0,-88(s0)
     654:	00001097          	auipc	ra,0x1
     658:	868080e7          	jalr	-1944(ra) # ebc <close>
      close(fds[1]);
     65c:	fac42503          	lw	a0,-84(s0)
     660:	00001097          	auipc	ra,0x1
     664:	85c080e7          	jalr	-1956(ra) # ebc <close>
      wait(0);
     668:	4501                	li	a0,0
     66a:	00001097          	auipc	ra,0x1
     66e:	832080e7          	jalr	-1998(ra) # e9c <wait>
     672:	bc45                	j	122 <go+0xaa>
        printf("grind: pipe failed\n");
     674:	00001517          	auipc	a0,0x1
     678:	eac50513          	addi	a0,a0,-340 # 1520 <malloc+0x226>
     67c:	00001097          	auipc	ra,0x1
     680:	bc0080e7          	jalr	-1088(ra) # 123c <printf>
        exit(1);
     684:	4505                	li	a0,1
     686:	00001097          	auipc	ra,0x1
     68a:	80e080e7          	jalr	-2034(ra) # e94 <exit>
        fork();
     68e:	00000097          	auipc	ra,0x0
     692:	7fe080e7          	jalr	2046(ra) # e8c <fork>
        fork();
     696:	00000097          	auipc	ra,0x0
     69a:	7f6080e7          	jalr	2038(ra) # e8c <fork>
        if(write(fds[1], "x", 1) != 1)
     69e:	4605                	li	a2,1
     6a0:	00001597          	auipc	a1,0x1
     6a4:	e9858593          	addi	a1,a1,-360 # 1538 <malloc+0x23e>
     6a8:	fac42503          	lw	a0,-84(s0)
     6ac:	00001097          	auipc	ra,0x1
     6b0:	808080e7          	jalr	-2040(ra) # eb4 <write>
     6b4:	4785                	li	a5,1
     6b6:	02f51363          	bne	a0,a5,6dc <go+0x664>
        if(read(fds[0], &c, 1) != 1)
     6ba:	4605                	li	a2,1
     6bc:	fa040593          	addi	a1,s0,-96
     6c0:	fa842503          	lw	a0,-88(s0)
     6c4:	00000097          	auipc	ra,0x0
     6c8:	7e8080e7          	jalr	2024(ra) # eac <read>
     6cc:	4785                	li	a5,1
     6ce:	02f51063          	bne	a0,a5,6ee <go+0x676>
        exit(0);
     6d2:	4501                	li	a0,0
     6d4:	00000097          	auipc	ra,0x0
     6d8:	7c0080e7          	jalr	1984(ra) # e94 <exit>
          printf("grind: pipe write failed\n");
     6dc:	00001517          	auipc	a0,0x1
     6e0:	e6450513          	addi	a0,a0,-412 # 1540 <malloc+0x246>
     6e4:	00001097          	auipc	ra,0x1
     6e8:	b58080e7          	jalr	-1192(ra) # 123c <printf>
     6ec:	b7f9                	j	6ba <go+0x642>
          printf("grind: pipe read failed\n");
     6ee:	00001517          	auipc	a0,0x1
     6f2:	e7250513          	addi	a0,a0,-398 # 1560 <malloc+0x266>
     6f6:	00001097          	auipc	ra,0x1
     6fa:	b46080e7          	jalr	-1210(ra) # 123c <printf>
     6fe:	bfd1                	j	6d2 <go+0x65a>
        printf("grind: fork failed\n");
     700:	00001517          	auipc	a0,0x1
     704:	de050513          	addi	a0,a0,-544 # 14e0 <malloc+0x1e6>
     708:	00001097          	auipc	ra,0x1
     70c:	b34080e7          	jalr	-1228(ra) # 123c <printf>
        exit(1);
     710:	4505                	li	a0,1
     712:	00000097          	auipc	ra,0x0
     716:	782080e7          	jalr	1922(ra) # e94 <exit>
      int pid = fork();
     71a:	00000097          	auipc	ra,0x0
     71e:	772080e7          	jalr	1906(ra) # e8c <fork>
      if(pid == 0){
     722:	c909                	beqz	a0,734 <go+0x6bc>
      } else if(pid < 0){
     724:	06054f63          	bltz	a0,7a2 <go+0x72a>
      wait(0);
     728:	4501                	li	a0,0
     72a:	00000097          	auipc	ra,0x0
     72e:	772080e7          	jalr	1906(ra) # e9c <wait>
     732:	bac5                	j	122 <go+0xaa>
        unlink("a");
     734:	00001517          	auipc	a0,0x1
     738:	d8c50513          	addi	a0,a0,-628 # 14c0 <malloc+0x1c6>
     73c:	00000097          	auipc	ra,0x0
     740:	7a8080e7          	jalr	1960(ra) # ee4 <unlink>
        mkdir("a");
     744:	00001517          	auipc	a0,0x1
     748:	d7c50513          	addi	a0,a0,-644 # 14c0 <malloc+0x1c6>
     74c:	00000097          	auipc	ra,0x0
     750:	7b0080e7          	jalr	1968(ra) # efc <mkdir>
        chdir("a");
     754:	00001517          	auipc	a0,0x1
     758:	d6c50513          	addi	a0,a0,-660 # 14c0 <malloc+0x1c6>
     75c:	00000097          	auipc	ra,0x0
     760:	7a8080e7          	jalr	1960(ra) # f04 <chdir>
        unlink("../a");
     764:	00001517          	auipc	a0,0x1
     768:	cc450513          	addi	a0,a0,-828 # 1428 <malloc+0x12e>
     76c:	00000097          	auipc	ra,0x0
     770:	778080e7          	jalr	1912(ra) # ee4 <unlink>
        fd = open("x", O_CREATE|O_RDWR);
     774:	20200593          	li	a1,514
     778:	00001517          	auipc	a0,0x1
     77c:	dc050513          	addi	a0,a0,-576 # 1538 <malloc+0x23e>
     780:	00000097          	auipc	ra,0x0
     784:	754080e7          	jalr	1876(ra) # ed4 <open>
        unlink("x");
     788:	00001517          	auipc	a0,0x1
     78c:	db050513          	addi	a0,a0,-592 # 1538 <malloc+0x23e>
     790:	00000097          	auipc	ra,0x0
     794:	754080e7          	jalr	1876(ra) # ee4 <unlink>
        exit(0);
     798:	4501                	li	a0,0
     79a:	00000097          	auipc	ra,0x0
     79e:	6fa080e7          	jalr	1786(ra) # e94 <exit>
        printf("grind: fork failed\n");
     7a2:	00001517          	auipc	a0,0x1
     7a6:	d3e50513          	addi	a0,a0,-706 # 14e0 <malloc+0x1e6>
     7aa:	00001097          	auipc	ra,0x1
     7ae:	a92080e7          	jalr	-1390(ra) # 123c <printf>
        exit(1);
     7b2:	4505                	li	a0,1
     7b4:	00000097          	auipc	ra,0x0
     7b8:	6e0080e7          	jalr	1760(ra) # e94 <exit>
      unlink("c");
     7bc:	00001517          	auipc	a0,0x1
     7c0:	dc450513          	addi	a0,a0,-572 # 1580 <malloc+0x286>
     7c4:	00000097          	auipc	ra,0x0
     7c8:	720080e7          	jalr	1824(ra) # ee4 <unlink>
      int fd1 = open("c", O_CREATE|O_RDWR);
     7cc:	20200593          	li	a1,514
     7d0:	00001517          	auipc	a0,0x1
     7d4:	db050513          	addi	a0,a0,-592 # 1580 <malloc+0x286>
     7d8:	00000097          	auipc	ra,0x0
     7dc:	6fc080e7          	jalr	1788(ra) # ed4 <open>
     7e0:	8b2a                	mv	s6,a0
      if(fd1 < 0){
     7e2:	04054f63          	bltz	a0,840 <go+0x7c8>
      if(write(fd1, "x", 1) != 1){
     7e6:	4605                	li	a2,1
     7e8:	00001597          	auipc	a1,0x1
     7ec:	d5058593          	addi	a1,a1,-688 # 1538 <malloc+0x23e>
     7f0:	00000097          	auipc	ra,0x0
     7f4:	6c4080e7          	jalr	1732(ra) # eb4 <write>
     7f8:	4785                	li	a5,1
     7fa:	06f51063          	bne	a0,a5,85a <go+0x7e2>
      if(fstat(fd1, &st) != 0){
     7fe:	fa840593          	addi	a1,s0,-88
     802:	855a                	mv	a0,s6
     804:	00000097          	auipc	ra,0x0
     808:	6e8080e7          	jalr	1768(ra) # eec <fstat>
     80c:	e525                	bnez	a0,874 <go+0x7fc>
      if(st.size != 1){
     80e:	fb843583          	ld	a1,-72(s0)
     812:	4785                	li	a5,1
     814:	06f59d63          	bne	a1,a5,88e <go+0x816>
      if(st.ino > 200){
     818:	fac42583          	lw	a1,-84(s0)
     81c:	0c800793          	li	a5,200
     820:	08b7e563          	bltu	a5,a1,8aa <go+0x832>
      close(fd1);
     824:	855a                	mv	a0,s6
     826:	00000097          	auipc	ra,0x0
     82a:	696080e7          	jalr	1686(ra) # ebc <close>
      unlink("c");
     82e:	00001517          	auipc	a0,0x1
     832:	d5250513          	addi	a0,a0,-686 # 1580 <malloc+0x286>
     836:	00000097          	auipc	ra,0x0
     83a:	6ae080e7          	jalr	1710(ra) # ee4 <unlink>
     83e:	b0d5                	j	122 <go+0xaa>
        printf("grind: create c failed\n");
     840:	00001517          	auipc	a0,0x1
     844:	d4850513          	addi	a0,a0,-696 # 1588 <malloc+0x28e>
     848:	00001097          	auipc	ra,0x1
     84c:	9f4080e7          	jalr	-1548(ra) # 123c <printf>
        exit(1);
     850:	4505                	li	a0,1
     852:	00000097          	auipc	ra,0x0
     856:	642080e7          	jalr	1602(ra) # e94 <exit>
        printf("grind: write c failed\n");
     85a:	00001517          	auipc	a0,0x1
     85e:	d4650513          	addi	a0,a0,-698 # 15a0 <malloc+0x2a6>
     862:	00001097          	auipc	ra,0x1
     866:	9da080e7          	jalr	-1574(ra) # 123c <printf>
        exit(1);
     86a:	4505                	li	a0,1
     86c:	00000097          	auipc	ra,0x0
     870:	628080e7          	jalr	1576(ra) # e94 <exit>
        printf("grind: fstat failed\n");
     874:	00001517          	auipc	a0,0x1
     878:	d4450513          	addi	a0,a0,-700 # 15b8 <malloc+0x2be>
     87c:	00001097          	auipc	ra,0x1
     880:	9c0080e7          	jalr	-1600(ra) # 123c <printf>
        exit(1);
     884:	4505                	li	a0,1
     886:	00000097          	auipc	ra,0x0
     88a:	60e080e7          	jalr	1550(ra) # e94 <exit>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
     88e:	2581                	sext.w	a1,a1
     890:	00001517          	auipc	a0,0x1
     894:	d4050513          	addi	a0,a0,-704 # 15d0 <malloc+0x2d6>
     898:	00001097          	auipc	ra,0x1
     89c:	9a4080e7          	jalr	-1628(ra) # 123c <printf>
        exit(1);
     8a0:	4505                	li	a0,1
     8a2:	00000097          	auipc	ra,0x0
     8a6:	5f2080e7          	jalr	1522(ra) # e94 <exit>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
     8aa:	00001517          	auipc	a0,0x1
     8ae:	d4e50513          	addi	a0,a0,-690 # 15f8 <malloc+0x2fe>
     8b2:	00001097          	auipc	ra,0x1
     8b6:	98a080e7          	jalr	-1654(ra) # 123c <printf>
        exit(1);
     8ba:	4505                	li	a0,1
     8bc:	00000097          	auipc	ra,0x0
     8c0:	5d8080e7          	jalr	1496(ra) # e94 <exit>
        fprintf(2, "grind: pipe failed\n");
     8c4:	00001597          	auipc	a1,0x1
     8c8:	c5c58593          	addi	a1,a1,-932 # 1520 <malloc+0x226>
     8cc:	4509                	li	a0,2
     8ce:	00001097          	auipc	ra,0x1
     8d2:	940080e7          	jalr	-1728(ra) # 120e <fprintf>
        exit(1);
     8d6:	4505                	li	a0,1
     8d8:	00000097          	auipc	ra,0x0
     8dc:	5bc080e7          	jalr	1468(ra) # e94 <exit>
        fprintf(2, "grind: pipe failed\n");
     8e0:	00001597          	auipc	a1,0x1
     8e4:	c4058593          	addi	a1,a1,-960 # 1520 <malloc+0x226>
     8e8:	4509                	li	a0,2
     8ea:	00001097          	auipc	ra,0x1
     8ee:	924080e7          	jalr	-1756(ra) # 120e <fprintf>
        exit(1);
     8f2:	4505                	li	a0,1
     8f4:	00000097          	auipc	ra,0x0
     8f8:	5a0080e7          	jalr	1440(ra) # e94 <exit>
        close(bb[0]);
     8fc:	fa042503          	lw	a0,-96(s0)
     900:	00000097          	auipc	ra,0x0
     904:	5bc080e7          	jalr	1468(ra) # ebc <close>
        close(bb[1]);
     908:	fa442503          	lw	a0,-92(s0)
     90c:	00000097          	auipc	ra,0x0
     910:	5b0080e7          	jalr	1456(ra) # ebc <close>
        close(aa[0]);
     914:	f9842503          	lw	a0,-104(s0)
     918:	00000097          	auipc	ra,0x0
     91c:	5a4080e7          	jalr	1444(ra) # ebc <close>
        close(1);
     920:	4505                	li	a0,1
     922:	00000097          	auipc	ra,0x0
     926:	59a080e7          	jalr	1434(ra) # ebc <close>
        if(dup(aa[1]) != 1){
     92a:	f9c42503          	lw	a0,-100(s0)
     92e:	00000097          	auipc	ra,0x0
     932:	5de080e7          	jalr	1502(ra) # f0c <dup>
     936:	4785                	li	a5,1
     938:	02f50063          	beq	a0,a5,958 <go+0x8e0>
          fprintf(2, "grind: dup failed\n");
     93c:	00001597          	auipc	a1,0x1
     940:	ce458593          	addi	a1,a1,-796 # 1620 <malloc+0x326>
     944:	4509                	li	a0,2
     946:	00001097          	auipc	ra,0x1
     94a:	8c8080e7          	jalr	-1848(ra) # 120e <fprintf>
          exit(1);
     94e:	4505                	li	a0,1
     950:	00000097          	auipc	ra,0x0
     954:	544080e7          	jalr	1348(ra) # e94 <exit>
        close(aa[1]);
     958:	f9c42503          	lw	a0,-100(s0)
     95c:	00000097          	auipc	ra,0x0
     960:	560080e7          	jalr	1376(ra) # ebc <close>
        char *args[3] = { "echo", "hi", 0 };
     964:	00001797          	auipc	a5,0x1
     968:	cd478793          	addi	a5,a5,-812 # 1638 <malloc+0x33e>
     96c:	faf43423          	sd	a5,-88(s0)
     970:	00001797          	auipc	a5,0x1
     974:	cd078793          	addi	a5,a5,-816 # 1640 <malloc+0x346>
     978:	faf43823          	sd	a5,-80(s0)
     97c:	fa043c23          	sd	zero,-72(s0)
        exec("grindir/../echo", args);
     980:	fa840593          	addi	a1,s0,-88
     984:	00001517          	auipc	a0,0x1
     988:	cc450513          	addi	a0,a0,-828 # 1648 <malloc+0x34e>
     98c:	00000097          	auipc	ra,0x0
     990:	540080e7          	jalr	1344(ra) # ecc <exec>
        fprintf(2, "grind: echo: not found\n");
     994:	00001597          	auipc	a1,0x1
     998:	cc458593          	addi	a1,a1,-828 # 1658 <malloc+0x35e>
     99c:	4509                	li	a0,2
     99e:	00001097          	auipc	ra,0x1
     9a2:	870080e7          	jalr	-1936(ra) # 120e <fprintf>
        exit(2);
     9a6:	4509                	li	a0,2
     9a8:	00000097          	auipc	ra,0x0
     9ac:	4ec080e7          	jalr	1260(ra) # e94 <exit>
        fprintf(2, "grind: fork failed\n");
     9b0:	00001597          	auipc	a1,0x1
     9b4:	b3058593          	addi	a1,a1,-1232 # 14e0 <malloc+0x1e6>
     9b8:	4509                	li	a0,2
     9ba:	00001097          	auipc	ra,0x1
     9be:	854080e7          	jalr	-1964(ra) # 120e <fprintf>
        exit(3);
     9c2:	450d                	li	a0,3
     9c4:	00000097          	auipc	ra,0x0
     9c8:	4d0080e7          	jalr	1232(ra) # e94 <exit>
        close(aa[1]);
     9cc:	f9c42503          	lw	a0,-100(s0)
     9d0:	00000097          	auipc	ra,0x0
     9d4:	4ec080e7          	jalr	1260(ra) # ebc <close>
        close(bb[0]);
     9d8:	fa042503          	lw	a0,-96(s0)
     9dc:	00000097          	auipc	ra,0x0
     9e0:	4e0080e7          	jalr	1248(ra) # ebc <close>
        close(0);
     9e4:	4501                	li	a0,0
     9e6:	00000097          	auipc	ra,0x0
     9ea:	4d6080e7          	jalr	1238(ra) # ebc <close>
        if(dup(aa[0]) != 0){
     9ee:	f9842503          	lw	a0,-104(s0)
     9f2:	00000097          	auipc	ra,0x0
     9f6:	51a080e7          	jalr	1306(ra) # f0c <dup>
     9fa:	cd19                	beqz	a0,a18 <go+0x9a0>
          fprintf(2, "grind: dup failed\n");
     9fc:	00001597          	auipc	a1,0x1
     a00:	c2458593          	addi	a1,a1,-988 # 1620 <malloc+0x326>
     a04:	4509                	li	a0,2
     a06:	00001097          	auipc	ra,0x1
     a0a:	808080e7          	jalr	-2040(ra) # 120e <fprintf>
          exit(4);
     a0e:	4511                	li	a0,4
     a10:	00000097          	auipc	ra,0x0
     a14:	484080e7          	jalr	1156(ra) # e94 <exit>
        close(aa[0]);
     a18:	f9842503          	lw	a0,-104(s0)
     a1c:	00000097          	auipc	ra,0x0
     a20:	4a0080e7          	jalr	1184(ra) # ebc <close>
        close(1);
     a24:	4505                	li	a0,1
     a26:	00000097          	auipc	ra,0x0
     a2a:	496080e7          	jalr	1174(ra) # ebc <close>
        if(dup(bb[1]) != 1){
     a2e:	fa442503          	lw	a0,-92(s0)
     a32:	00000097          	auipc	ra,0x0
     a36:	4da080e7          	jalr	1242(ra) # f0c <dup>
     a3a:	4785                	li	a5,1
     a3c:	02f50063          	beq	a0,a5,a5c <go+0x9e4>
          fprintf(2, "grind: dup failed\n");
     a40:	00001597          	auipc	a1,0x1
     a44:	be058593          	addi	a1,a1,-1056 # 1620 <malloc+0x326>
     a48:	4509                	li	a0,2
     a4a:	00000097          	auipc	ra,0x0
     a4e:	7c4080e7          	jalr	1988(ra) # 120e <fprintf>
          exit(5);
     a52:	4515                	li	a0,5
     a54:	00000097          	auipc	ra,0x0
     a58:	440080e7          	jalr	1088(ra) # e94 <exit>
        close(bb[1]);
     a5c:	fa442503          	lw	a0,-92(s0)
     a60:	00000097          	auipc	ra,0x0
     a64:	45c080e7          	jalr	1116(ra) # ebc <close>
        char *args[2] = { "cat", 0 };
     a68:	00001797          	auipc	a5,0x1
     a6c:	c0878793          	addi	a5,a5,-1016 # 1670 <malloc+0x376>
     a70:	faf43423          	sd	a5,-88(s0)
     a74:	fa043823          	sd	zero,-80(s0)
        exec("/cat", args);
     a78:	fa840593          	addi	a1,s0,-88
     a7c:	00001517          	auipc	a0,0x1
     a80:	bfc50513          	addi	a0,a0,-1028 # 1678 <malloc+0x37e>
     a84:	00000097          	auipc	ra,0x0
     a88:	448080e7          	jalr	1096(ra) # ecc <exec>
        fprintf(2, "grind: cat: not found\n");
     a8c:	00001597          	auipc	a1,0x1
     a90:	bf458593          	addi	a1,a1,-1036 # 1680 <malloc+0x386>
     a94:	4509                	li	a0,2
     a96:	00000097          	auipc	ra,0x0
     a9a:	778080e7          	jalr	1912(ra) # 120e <fprintf>
        exit(6);
     a9e:	4519                	li	a0,6
     aa0:	00000097          	auipc	ra,0x0
     aa4:	3f4080e7          	jalr	1012(ra) # e94 <exit>
        fprintf(2, "grind: fork failed\n");
     aa8:	00001597          	auipc	a1,0x1
     aac:	a3858593          	addi	a1,a1,-1480 # 14e0 <malloc+0x1e6>
     ab0:	4509                	li	a0,2
     ab2:	00000097          	auipc	ra,0x0
     ab6:	75c080e7          	jalr	1884(ra) # 120e <fprintf>
        exit(7);
     aba:	451d                	li	a0,7
     abc:	00000097          	auipc	ra,0x0
     ac0:	3d8080e7          	jalr	984(ra) # e94 <exit>

0000000000000ac4 <iter>:
  }
}

void
iter()
{
     ac4:	7179                	addi	sp,sp,-48
     ac6:	f406                	sd	ra,40(sp)
     ac8:	f022                	sd	s0,32(sp)
     aca:	ec26                	sd	s1,24(sp)
     acc:	e84a                	sd	s2,16(sp)
     ace:	1800                	addi	s0,sp,48
  unlink("a");
     ad0:	00001517          	auipc	a0,0x1
     ad4:	9f050513          	addi	a0,a0,-1552 # 14c0 <malloc+0x1c6>
     ad8:	00000097          	auipc	ra,0x0
     adc:	40c080e7          	jalr	1036(ra) # ee4 <unlink>
  unlink("b");
     ae0:	00001517          	auipc	a0,0x1
     ae4:	99050513          	addi	a0,a0,-1648 # 1470 <malloc+0x176>
     ae8:	00000097          	auipc	ra,0x0
     aec:	3fc080e7          	jalr	1020(ra) # ee4 <unlink>
  
  int pid1 = fork();
     af0:	00000097          	auipc	ra,0x0
     af4:	39c080e7          	jalr	924(ra) # e8c <fork>
  if(pid1 < 0){
     af8:	02054163          	bltz	a0,b1a <iter+0x56>
     afc:	84aa                	mv	s1,a0
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid1 == 0){
     afe:	e91d                	bnez	a0,b34 <iter+0x70>
    rand_next ^= 31;
     b00:	00001717          	auipc	a4,0x1
     b04:	50070713          	addi	a4,a4,1280 # 2000 <rand_next>
     b08:	631c                	ld	a5,0(a4)
     b0a:	01f7c793          	xori	a5,a5,31
     b0e:	e31c                	sd	a5,0(a4)
    go(0);
     b10:	4501                	li	a0,0
     b12:	fffff097          	auipc	ra,0xfffff
     b16:	566080e7          	jalr	1382(ra) # 78 <go>
    printf("grind: fork failed\n");
     b1a:	00001517          	auipc	a0,0x1
     b1e:	9c650513          	addi	a0,a0,-1594 # 14e0 <malloc+0x1e6>
     b22:	00000097          	auipc	ra,0x0
     b26:	71a080e7          	jalr	1818(ra) # 123c <printf>
    exit(1);
     b2a:	4505                	li	a0,1
     b2c:	00000097          	auipc	ra,0x0
     b30:	368080e7          	jalr	872(ra) # e94 <exit>
    exit(0);
  }

  int pid2 = fork();
     b34:	00000097          	auipc	ra,0x0
     b38:	358080e7          	jalr	856(ra) # e8c <fork>
     b3c:	892a                	mv	s2,a0
  if(pid2 < 0){
     b3e:	02054263          	bltz	a0,b62 <iter+0x9e>
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid2 == 0){
     b42:	ed0d                	bnez	a0,b7c <iter+0xb8>
    rand_next ^= 7177;
     b44:	00001697          	auipc	a3,0x1
     b48:	4bc68693          	addi	a3,a3,1212 # 2000 <rand_next>
     b4c:	629c                	ld	a5,0(a3)
     b4e:	6709                	lui	a4,0x2
     b50:	c0970713          	addi	a4,a4,-1015 # 1c09 <digits+0x539>
     b54:	8fb9                	xor	a5,a5,a4
     b56:	e29c                	sd	a5,0(a3)
    go(1);
     b58:	4505                	li	a0,1
     b5a:	fffff097          	auipc	ra,0xfffff
     b5e:	51e080e7          	jalr	1310(ra) # 78 <go>
    printf("grind: fork failed\n");
     b62:	00001517          	auipc	a0,0x1
     b66:	97e50513          	addi	a0,a0,-1666 # 14e0 <malloc+0x1e6>
     b6a:	00000097          	auipc	ra,0x0
     b6e:	6d2080e7          	jalr	1746(ra) # 123c <printf>
    exit(1);
     b72:	4505                	li	a0,1
     b74:	00000097          	auipc	ra,0x0
     b78:	320080e7          	jalr	800(ra) # e94 <exit>
    exit(0);
  }

  int st1 = -1;
     b7c:	57fd                	li	a5,-1
     b7e:	fcf42e23          	sw	a5,-36(s0)
  wait(&st1);
     b82:	fdc40513          	addi	a0,s0,-36
     b86:	00000097          	auipc	ra,0x0
     b8a:	316080e7          	jalr	790(ra) # e9c <wait>
  if(st1 != 0){
     b8e:	fdc42783          	lw	a5,-36(s0)
     b92:	ef99                	bnez	a5,bb0 <iter+0xec>
    kill(pid1);
    kill(pid2);
  }
  int st2 = -1;
     b94:	57fd                	li	a5,-1
     b96:	fcf42c23          	sw	a5,-40(s0)
  wait(&st2);
     b9a:	fd840513          	addi	a0,s0,-40
     b9e:	00000097          	auipc	ra,0x0
     ba2:	2fe080e7          	jalr	766(ra) # e9c <wait>

  exit(0);
     ba6:	4501                	li	a0,0
     ba8:	00000097          	auipc	ra,0x0
     bac:	2ec080e7          	jalr	748(ra) # e94 <exit>
    kill(pid1);
     bb0:	8526                	mv	a0,s1
     bb2:	00000097          	auipc	ra,0x0
     bb6:	312080e7          	jalr	786(ra) # ec4 <kill>
    kill(pid2);
     bba:	854a                	mv	a0,s2
     bbc:	00000097          	auipc	ra,0x0
     bc0:	308080e7          	jalr	776(ra) # ec4 <kill>
     bc4:	bfc1                	j	b94 <iter+0xd0>

0000000000000bc6 <main>:
}

int
main()
{
     bc6:	1101                	addi	sp,sp,-32
     bc8:	ec06                	sd	ra,24(sp)
     bca:	e822                	sd	s0,16(sp)
     bcc:	e426                	sd	s1,8(sp)
     bce:	1000                	addi	s0,sp,32
    }
    if(pid > 0){
      wait(0);
    }
    sleep(20);
    rand_next += 1;
     bd0:	00001497          	auipc	s1,0x1
     bd4:	43048493          	addi	s1,s1,1072 # 2000 <rand_next>
     bd8:	a829                	j	bf2 <main+0x2c>
      iter();
     bda:	00000097          	auipc	ra,0x0
     bde:	eea080e7          	jalr	-278(ra) # ac4 <iter>
    sleep(20);
     be2:	4551                	li	a0,20
     be4:	00000097          	auipc	ra,0x0
     be8:	340080e7          	jalr	832(ra) # f24 <sleep>
    rand_next += 1;
     bec:	609c                	ld	a5,0(s1)
     bee:	0785                	addi	a5,a5,1
     bf0:	e09c                	sd	a5,0(s1)
    int pid = fork();
     bf2:	00000097          	auipc	ra,0x0
     bf6:	29a080e7          	jalr	666(ra) # e8c <fork>
    if(pid == 0){
     bfa:	d165                	beqz	a0,bda <main+0x14>
    if(pid > 0){
     bfc:	fea053e3          	blez	a0,be2 <main+0x1c>
      wait(0);
     c00:	4501                	li	a0,0
     c02:	00000097          	auipc	ra,0x0
     c06:	29a080e7          	jalr	666(ra) # e9c <wait>
     c0a:	bfe1                	j	be2 <main+0x1c>

0000000000000c0c <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
     c0c:	1141                	addi	sp,sp,-16
     c0e:	e406                	sd	ra,8(sp)
     c10:	e022                	sd	s0,0(sp)
     c12:	0800                	addi	s0,sp,16
  extern int main();
  main();
     c14:	00000097          	auipc	ra,0x0
     c18:	fb2080e7          	jalr	-78(ra) # bc6 <main>
  exit(0);
     c1c:	4501                	li	a0,0
     c1e:	00000097          	auipc	ra,0x0
     c22:	276080e7          	jalr	630(ra) # e94 <exit>

0000000000000c26 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     c26:	1141                	addi	sp,sp,-16
     c28:	e422                	sd	s0,8(sp)
     c2a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     c2c:	87aa                	mv	a5,a0
     c2e:	0585                	addi	a1,a1,1
     c30:	0785                	addi	a5,a5,1
     c32:	fff5c703          	lbu	a4,-1(a1)
     c36:	fee78fa3          	sb	a4,-1(a5)
     c3a:	fb75                	bnez	a4,c2e <strcpy+0x8>
    ;
  return os;
}
     c3c:	6422                	ld	s0,8(sp)
     c3e:	0141                	addi	sp,sp,16
     c40:	8082                	ret

0000000000000c42 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     c42:	1141                	addi	sp,sp,-16
     c44:	e422                	sd	s0,8(sp)
     c46:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     c48:	00054783          	lbu	a5,0(a0)
     c4c:	cb91                	beqz	a5,c60 <strcmp+0x1e>
     c4e:	0005c703          	lbu	a4,0(a1)
     c52:	00f71763          	bne	a4,a5,c60 <strcmp+0x1e>
    p++, q++;
     c56:	0505                	addi	a0,a0,1
     c58:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     c5a:	00054783          	lbu	a5,0(a0)
     c5e:	fbe5                	bnez	a5,c4e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     c60:	0005c503          	lbu	a0,0(a1)
}
     c64:	40a7853b          	subw	a0,a5,a0
     c68:	6422                	ld	s0,8(sp)
     c6a:	0141                	addi	sp,sp,16
     c6c:	8082                	ret

0000000000000c6e <strlen>:

uint
strlen(const char *s)
{
     c6e:	1141                	addi	sp,sp,-16
     c70:	e422                	sd	s0,8(sp)
     c72:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     c74:	00054783          	lbu	a5,0(a0)
     c78:	cf91                	beqz	a5,c94 <strlen+0x26>
     c7a:	0505                	addi	a0,a0,1
     c7c:	87aa                	mv	a5,a0
     c7e:	4685                	li	a3,1
     c80:	9e89                	subw	a3,a3,a0
     c82:	00f6853b          	addw	a0,a3,a5
     c86:	0785                	addi	a5,a5,1
     c88:	fff7c703          	lbu	a4,-1(a5)
     c8c:	fb7d                	bnez	a4,c82 <strlen+0x14>
    ;
  return n;
}
     c8e:	6422                	ld	s0,8(sp)
     c90:	0141                	addi	sp,sp,16
     c92:	8082                	ret
  for(n = 0; s[n]; n++)
     c94:	4501                	li	a0,0
     c96:	bfe5                	j	c8e <strlen+0x20>

0000000000000c98 <memset>:

void*
memset(void *dst, int c, uint n)
{
     c98:	1141                	addi	sp,sp,-16
     c9a:	e422                	sd	s0,8(sp)
     c9c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     c9e:	ca19                	beqz	a2,cb4 <memset+0x1c>
     ca0:	87aa                	mv	a5,a0
     ca2:	1602                	slli	a2,a2,0x20
     ca4:	9201                	srli	a2,a2,0x20
     ca6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     caa:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     cae:	0785                	addi	a5,a5,1
     cb0:	fee79de3          	bne	a5,a4,caa <memset+0x12>
  }
  return dst;
}
     cb4:	6422                	ld	s0,8(sp)
     cb6:	0141                	addi	sp,sp,16
     cb8:	8082                	ret

0000000000000cba <strchr>:

char*
strchr(const char *s, char c)
{
     cba:	1141                	addi	sp,sp,-16
     cbc:	e422                	sd	s0,8(sp)
     cbe:	0800                	addi	s0,sp,16
  for(; *s; s++)
     cc0:	00054783          	lbu	a5,0(a0)
     cc4:	cb99                	beqz	a5,cda <strchr+0x20>
    if(*s == c)
     cc6:	00f58763          	beq	a1,a5,cd4 <strchr+0x1a>
  for(; *s; s++)
     cca:	0505                	addi	a0,a0,1
     ccc:	00054783          	lbu	a5,0(a0)
     cd0:	fbfd                	bnez	a5,cc6 <strchr+0xc>
      return (char*)s;
  return 0;
     cd2:	4501                	li	a0,0
}
     cd4:	6422                	ld	s0,8(sp)
     cd6:	0141                	addi	sp,sp,16
     cd8:	8082                	ret
  return 0;
     cda:	4501                	li	a0,0
     cdc:	bfe5                	j	cd4 <strchr+0x1a>

0000000000000cde <gets>:

char*
gets(char *buf, int max)
{
     cde:	711d                	addi	sp,sp,-96
     ce0:	ec86                	sd	ra,88(sp)
     ce2:	e8a2                	sd	s0,80(sp)
     ce4:	e4a6                	sd	s1,72(sp)
     ce6:	e0ca                	sd	s2,64(sp)
     ce8:	fc4e                	sd	s3,56(sp)
     cea:	f852                	sd	s4,48(sp)
     cec:	f456                	sd	s5,40(sp)
     cee:	f05a                	sd	s6,32(sp)
     cf0:	ec5e                	sd	s7,24(sp)
     cf2:	1080                	addi	s0,sp,96
     cf4:	8baa                	mv	s7,a0
     cf6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     cf8:	892a                	mv	s2,a0
     cfa:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     cfc:	4aa9                	li	s5,10
     cfe:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     d00:	89a6                	mv	s3,s1
     d02:	2485                	addiw	s1,s1,1
     d04:	0344d863          	bge	s1,s4,d34 <gets+0x56>
    cc = read(0, &c, 1);
     d08:	4605                	li	a2,1
     d0a:	faf40593          	addi	a1,s0,-81
     d0e:	4501                	li	a0,0
     d10:	00000097          	auipc	ra,0x0
     d14:	19c080e7          	jalr	412(ra) # eac <read>
    if(cc < 1)
     d18:	00a05e63          	blez	a0,d34 <gets+0x56>
    buf[i++] = c;
     d1c:	faf44783          	lbu	a5,-81(s0)
     d20:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     d24:	01578763          	beq	a5,s5,d32 <gets+0x54>
     d28:	0905                	addi	s2,s2,1
     d2a:	fd679be3          	bne	a5,s6,d00 <gets+0x22>
  for(i=0; i+1 < max; ){
     d2e:	89a6                	mv	s3,s1
     d30:	a011                	j	d34 <gets+0x56>
     d32:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     d34:	99de                	add	s3,s3,s7
     d36:	00098023          	sb	zero,0(s3)
  return buf;
}
     d3a:	855e                	mv	a0,s7
     d3c:	60e6                	ld	ra,88(sp)
     d3e:	6446                	ld	s0,80(sp)
     d40:	64a6                	ld	s1,72(sp)
     d42:	6906                	ld	s2,64(sp)
     d44:	79e2                	ld	s3,56(sp)
     d46:	7a42                	ld	s4,48(sp)
     d48:	7aa2                	ld	s5,40(sp)
     d4a:	7b02                	ld	s6,32(sp)
     d4c:	6be2                	ld	s7,24(sp)
     d4e:	6125                	addi	sp,sp,96
     d50:	8082                	ret

0000000000000d52 <stat>:

int
stat(const char *n, struct stat *st)
{
     d52:	1101                	addi	sp,sp,-32
     d54:	ec06                	sd	ra,24(sp)
     d56:	e822                	sd	s0,16(sp)
     d58:	e426                	sd	s1,8(sp)
     d5a:	e04a                	sd	s2,0(sp)
     d5c:	1000                	addi	s0,sp,32
     d5e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     d60:	4581                	li	a1,0
     d62:	00000097          	auipc	ra,0x0
     d66:	172080e7          	jalr	370(ra) # ed4 <open>
  if(fd < 0)
     d6a:	02054563          	bltz	a0,d94 <stat+0x42>
     d6e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     d70:	85ca                	mv	a1,s2
     d72:	00000097          	auipc	ra,0x0
     d76:	17a080e7          	jalr	378(ra) # eec <fstat>
     d7a:	892a                	mv	s2,a0
  close(fd);
     d7c:	8526                	mv	a0,s1
     d7e:	00000097          	auipc	ra,0x0
     d82:	13e080e7          	jalr	318(ra) # ebc <close>
  return r;
}
     d86:	854a                	mv	a0,s2
     d88:	60e2                	ld	ra,24(sp)
     d8a:	6442                	ld	s0,16(sp)
     d8c:	64a2                	ld	s1,8(sp)
     d8e:	6902                	ld	s2,0(sp)
     d90:	6105                	addi	sp,sp,32
     d92:	8082                	ret
    return -1;
     d94:	597d                	li	s2,-1
     d96:	bfc5                	j	d86 <stat+0x34>

0000000000000d98 <atoi>:

int
atoi(const char *s)
{
     d98:	1141                	addi	sp,sp,-16
     d9a:	e422                	sd	s0,8(sp)
     d9c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     d9e:	00054603          	lbu	a2,0(a0)
     da2:	fd06079b          	addiw	a5,a2,-48
     da6:	0ff7f793          	andi	a5,a5,255
     daa:	4725                	li	a4,9
     dac:	02f76963          	bltu	a4,a5,dde <atoi+0x46>
     db0:	86aa                	mv	a3,a0
  n = 0;
     db2:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     db4:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     db6:	0685                	addi	a3,a3,1
     db8:	0025179b          	slliw	a5,a0,0x2
     dbc:	9fa9                	addw	a5,a5,a0
     dbe:	0017979b          	slliw	a5,a5,0x1
     dc2:	9fb1                	addw	a5,a5,a2
     dc4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     dc8:	0006c603          	lbu	a2,0(a3)
     dcc:	fd06071b          	addiw	a4,a2,-48
     dd0:	0ff77713          	andi	a4,a4,255
     dd4:	fee5f1e3          	bgeu	a1,a4,db6 <atoi+0x1e>
  return n;
}
     dd8:	6422                	ld	s0,8(sp)
     dda:	0141                	addi	sp,sp,16
     ddc:	8082                	ret
  n = 0;
     dde:	4501                	li	a0,0
     de0:	bfe5                	j	dd8 <atoi+0x40>

0000000000000de2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     de2:	1141                	addi	sp,sp,-16
     de4:	e422                	sd	s0,8(sp)
     de6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     de8:	02b57463          	bgeu	a0,a1,e10 <memmove+0x2e>
    while(n-- > 0)
     dec:	00c05f63          	blez	a2,e0a <memmove+0x28>
     df0:	1602                	slli	a2,a2,0x20
     df2:	9201                	srli	a2,a2,0x20
     df4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     df8:	872a                	mv	a4,a0
      *dst++ = *src++;
     dfa:	0585                	addi	a1,a1,1
     dfc:	0705                	addi	a4,a4,1
     dfe:	fff5c683          	lbu	a3,-1(a1)
     e02:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     e06:	fee79ae3          	bne	a5,a4,dfa <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     e0a:	6422                	ld	s0,8(sp)
     e0c:	0141                	addi	sp,sp,16
     e0e:	8082                	ret
    dst += n;
     e10:	00c50733          	add	a4,a0,a2
    src += n;
     e14:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     e16:	fec05ae3          	blez	a2,e0a <memmove+0x28>
     e1a:	fff6079b          	addiw	a5,a2,-1
     e1e:	1782                	slli	a5,a5,0x20
     e20:	9381                	srli	a5,a5,0x20
     e22:	fff7c793          	not	a5,a5
     e26:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     e28:	15fd                	addi	a1,a1,-1
     e2a:	177d                	addi	a4,a4,-1
     e2c:	0005c683          	lbu	a3,0(a1)
     e30:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     e34:	fee79ae3          	bne	a5,a4,e28 <memmove+0x46>
     e38:	bfc9                	j	e0a <memmove+0x28>

0000000000000e3a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     e3a:	1141                	addi	sp,sp,-16
     e3c:	e422                	sd	s0,8(sp)
     e3e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     e40:	ca05                	beqz	a2,e70 <memcmp+0x36>
     e42:	fff6069b          	addiw	a3,a2,-1
     e46:	1682                	slli	a3,a3,0x20
     e48:	9281                	srli	a3,a3,0x20
     e4a:	0685                	addi	a3,a3,1
     e4c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     e4e:	00054783          	lbu	a5,0(a0)
     e52:	0005c703          	lbu	a4,0(a1)
     e56:	00e79863          	bne	a5,a4,e66 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     e5a:	0505                	addi	a0,a0,1
    p2++;
     e5c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     e5e:	fed518e3          	bne	a0,a3,e4e <memcmp+0x14>
  }
  return 0;
     e62:	4501                	li	a0,0
     e64:	a019                	j	e6a <memcmp+0x30>
      return *p1 - *p2;
     e66:	40e7853b          	subw	a0,a5,a4
}
     e6a:	6422                	ld	s0,8(sp)
     e6c:	0141                	addi	sp,sp,16
     e6e:	8082                	ret
  return 0;
     e70:	4501                	li	a0,0
     e72:	bfe5                	j	e6a <memcmp+0x30>

0000000000000e74 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     e74:	1141                	addi	sp,sp,-16
     e76:	e406                	sd	ra,8(sp)
     e78:	e022                	sd	s0,0(sp)
     e7a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     e7c:	00000097          	auipc	ra,0x0
     e80:	f66080e7          	jalr	-154(ra) # de2 <memmove>
}
     e84:	60a2                	ld	ra,8(sp)
     e86:	6402                	ld	s0,0(sp)
     e88:	0141                	addi	sp,sp,16
     e8a:	8082                	ret

0000000000000e8c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     e8c:	4885                	li	a7,1
 ecall
     e8e:	00000073          	ecall
 ret
     e92:	8082                	ret

0000000000000e94 <exit>:
.global exit
exit:
 li a7, SYS_exit
     e94:	4889                	li	a7,2
 ecall
     e96:	00000073          	ecall
 ret
     e9a:	8082                	ret

0000000000000e9c <wait>:
.global wait
wait:
 li a7, SYS_wait
     e9c:	488d                	li	a7,3
 ecall
     e9e:	00000073          	ecall
 ret
     ea2:	8082                	ret

0000000000000ea4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     ea4:	4891                	li	a7,4
 ecall
     ea6:	00000073          	ecall
 ret
     eaa:	8082                	ret

0000000000000eac <read>:
.global read
read:
 li a7, SYS_read
     eac:	4895                	li	a7,5
 ecall
     eae:	00000073          	ecall
 ret
     eb2:	8082                	ret

0000000000000eb4 <write>:
.global write
write:
 li a7, SYS_write
     eb4:	48c1                	li	a7,16
 ecall
     eb6:	00000073          	ecall
 ret
     eba:	8082                	ret

0000000000000ebc <close>:
.global close
close:
 li a7, SYS_close
     ebc:	48d5                	li	a7,21
 ecall
     ebe:	00000073          	ecall
 ret
     ec2:	8082                	ret

0000000000000ec4 <kill>:
.global kill
kill:
 li a7, SYS_kill
     ec4:	4899                	li	a7,6
 ecall
     ec6:	00000073          	ecall
 ret
     eca:	8082                	ret

0000000000000ecc <exec>:
.global exec
exec:
 li a7, SYS_exec
     ecc:	489d                	li	a7,7
 ecall
     ece:	00000073          	ecall
 ret
     ed2:	8082                	ret

0000000000000ed4 <open>:
.global open
open:
 li a7, SYS_open
     ed4:	48bd                	li	a7,15
 ecall
     ed6:	00000073          	ecall
 ret
     eda:	8082                	ret

0000000000000edc <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     edc:	48c5                	li	a7,17
 ecall
     ede:	00000073          	ecall
 ret
     ee2:	8082                	ret

0000000000000ee4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     ee4:	48c9                	li	a7,18
 ecall
     ee6:	00000073          	ecall
 ret
     eea:	8082                	ret

0000000000000eec <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     eec:	48a1                	li	a7,8
 ecall
     eee:	00000073          	ecall
 ret
     ef2:	8082                	ret

0000000000000ef4 <link>:
.global link
link:
 li a7, SYS_link
     ef4:	48cd                	li	a7,19
 ecall
     ef6:	00000073          	ecall
 ret
     efa:	8082                	ret

0000000000000efc <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     efc:	48d1                	li	a7,20
 ecall
     efe:	00000073          	ecall
 ret
     f02:	8082                	ret

0000000000000f04 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     f04:	48a5                	li	a7,9
 ecall
     f06:	00000073          	ecall
 ret
     f0a:	8082                	ret

0000000000000f0c <dup>:
.global dup
dup:
 li a7, SYS_dup
     f0c:	48a9                	li	a7,10
 ecall
     f0e:	00000073          	ecall
 ret
     f12:	8082                	ret

0000000000000f14 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     f14:	48ad                	li	a7,11
 ecall
     f16:	00000073          	ecall
 ret
     f1a:	8082                	ret

0000000000000f1c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     f1c:	48b1                	li	a7,12
 ecall
     f1e:	00000073          	ecall
 ret
     f22:	8082                	ret

0000000000000f24 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     f24:	48b5                	li	a7,13
 ecall
     f26:	00000073          	ecall
 ret
     f2a:	8082                	ret

0000000000000f2c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     f2c:	48b9                	li	a7,14
 ecall
     f2e:	00000073          	ecall
 ret
     f32:	8082                	ret

0000000000000f34 <trace>:
.global trace
trace:
 li a7, SYS_trace
     f34:	48d9                	li	a7,22
 ecall
     f36:	00000073          	ecall
 ret
     f3a:	8082                	ret

0000000000000f3c <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
     f3c:	48dd                	li	a7,23
 ecall
     f3e:	00000073          	ecall
 ret
     f42:	8082                	ret

0000000000000f44 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
     f44:	48e5                	li	a7,25
 ecall
     f46:	00000073          	ecall
 ret
     f4a:	8082                	ret

0000000000000f4c <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
     f4c:	48e1                	li	a7,24
 ecall
     f4e:	00000073          	ecall
 ret
     f52:	8082                	ret

0000000000000f54 <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
     f54:	48e9                	li	a7,26
 ecall
     f56:	00000073          	ecall
 ret
     f5a:	8082                	ret

0000000000000f5c <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
     f5c:	48ed                	li	a7,27
 ecall
     f5e:	00000073          	ecall
 ret
     f62:	8082                	ret

0000000000000f64 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     f64:	1101                	addi	sp,sp,-32
     f66:	ec06                	sd	ra,24(sp)
     f68:	e822                	sd	s0,16(sp)
     f6a:	1000                	addi	s0,sp,32
     f6c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     f70:	4605                	li	a2,1
     f72:	fef40593          	addi	a1,s0,-17
     f76:	00000097          	auipc	ra,0x0
     f7a:	f3e080e7          	jalr	-194(ra) # eb4 <write>
}
     f7e:	60e2                	ld	ra,24(sp)
     f80:	6442                	ld	s0,16(sp)
     f82:	6105                	addi	sp,sp,32
     f84:	8082                	ret

0000000000000f86 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     f86:	7139                	addi	sp,sp,-64
     f88:	fc06                	sd	ra,56(sp)
     f8a:	f822                	sd	s0,48(sp)
     f8c:	f426                	sd	s1,40(sp)
     f8e:	f04a                	sd	s2,32(sp)
     f90:	ec4e                	sd	s3,24(sp)
     f92:	0080                	addi	s0,sp,64
     f94:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     f96:	c299                	beqz	a3,f9c <printint+0x16>
     f98:	0805c863          	bltz	a1,1028 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     f9c:	2581                	sext.w	a1,a1
  neg = 0;
     f9e:	4881                	li	a7,0
     fa0:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     fa4:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     fa6:	2601                	sext.w	a2,a2
     fa8:	00000517          	auipc	a0,0x0
     fac:	72850513          	addi	a0,a0,1832 # 16d0 <digits>
     fb0:	883a                	mv	a6,a4
     fb2:	2705                	addiw	a4,a4,1
     fb4:	02c5f7bb          	remuw	a5,a1,a2
     fb8:	1782                	slli	a5,a5,0x20
     fba:	9381                	srli	a5,a5,0x20
     fbc:	97aa                	add	a5,a5,a0
     fbe:	0007c783          	lbu	a5,0(a5)
     fc2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     fc6:	0005879b          	sext.w	a5,a1
     fca:	02c5d5bb          	divuw	a1,a1,a2
     fce:	0685                	addi	a3,a3,1
     fd0:	fec7f0e3          	bgeu	a5,a2,fb0 <printint+0x2a>
  if(neg)
     fd4:	00088b63          	beqz	a7,fea <printint+0x64>
    buf[i++] = '-';
     fd8:	fd040793          	addi	a5,s0,-48
     fdc:	973e                	add	a4,a4,a5
     fde:	02d00793          	li	a5,45
     fe2:	fef70823          	sb	a5,-16(a4)
     fe6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     fea:	02e05863          	blez	a4,101a <printint+0x94>
     fee:	fc040793          	addi	a5,s0,-64
     ff2:	00e78933          	add	s2,a5,a4
     ff6:	fff78993          	addi	s3,a5,-1
     ffa:	99ba                	add	s3,s3,a4
     ffc:	377d                	addiw	a4,a4,-1
     ffe:	1702                	slli	a4,a4,0x20
    1000:	9301                	srli	a4,a4,0x20
    1002:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    1006:	fff94583          	lbu	a1,-1(s2)
    100a:	8526                	mv	a0,s1
    100c:	00000097          	auipc	ra,0x0
    1010:	f58080e7          	jalr	-168(ra) # f64 <putc>
  while(--i >= 0)
    1014:	197d                	addi	s2,s2,-1
    1016:	ff3918e3          	bne	s2,s3,1006 <printint+0x80>
}
    101a:	70e2                	ld	ra,56(sp)
    101c:	7442                	ld	s0,48(sp)
    101e:	74a2                	ld	s1,40(sp)
    1020:	7902                	ld	s2,32(sp)
    1022:	69e2                	ld	s3,24(sp)
    1024:	6121                	addi	sp,sp,64
    1026:	8082                	ret
    x = -xx;
    1028:	40b005bb          	negw	a1,a1
    neg = 1;
    102c:	4885                	li	a7,1
    x = -xx;
    102e:	bf8d                	j	fa0 <printint+0x1a>

0000000000001030 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    1030:	7119                	addi	sp,sp,-128
    1032:	fc86                	sd	ra,120(sp)
    1034:	f8a2                	sd	s0,112(sp)
    1036:	f4a6                	sd	s1,104(sp)
    1038:	f0ca                	sd	s2,96(sp)
    103a:	ecce                	sd	s3,88(sp)
    103c:	e8d2                	sd	s4,80(sp)
    103e:	e4d6                	sd	s5,72(sp)
    1040:	e0da                	sd	s6,64(sp)
    1042:	fc5e                	sd	s7,56(sp)
    1044:	f862                	sd	s8,48(sp)
    1046:	f466                	sd	s9,40(sp)
    1048:	f06a                	sd	s10,32(sp)
    104a:	ec6e                	sd	s11,24(sp)
    104c:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    104e:	0005c903          	lbu	s2,0(a1)
    1052:	18090f63          	beqz	s2,11f0 <vprintf+0x1c0>
    1056:	8aaa                	mv	s5,a0
    1058:	8b32                	mv	s6,a2
    105a:	00158493          	addi	s1,a1,1
  state = 0;
    105e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    1060:	02500a13          	li	s4,37
      if(c == 'd'){
    1064:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    1068:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    106c:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    1070:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1074:	00000b97          	auipc	s7,0x0
    1078:	65cb8b93          	addi	s7,s7,1628 # 16d0 <digits>
    107c:	a839                	j	109a <vprintf+0x6a>
        putc(fd, c);
    107e:	85ca                	mv	a1,s2
    1080:	8556                	mv	a0,s5
    1082:	00000097          	auipc	ra,0x0
    1086:	ee2080e7          	jalr	-286(ra) # f64 <putc>
    108a:	a019                	j	1090 <vprintf+0x60>
    } else if(state == '%'){
    108c:	01498f63          	beq	s3,s4,10aa <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    1090:	0485                	addi	s1,s1,1
    1092:	fff4c903          	lbu	s2,-1(s1)
    1096:	14090d63          	beqz	s2,11f0 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    109a:	0009079b          	sext.w	a5,s2
    if(state == 0){
    109e:	fe0997e3          	bnez	s3,108c <vprintf+0x5c>
      if(c == '%'){
    10a2:	fd479ee3          	bne	a5,s4,107e <vprintf+0x4e>
        state = '%';
    10a6:	89be                	mv	s3,a5
    10a8:	b7e5                	j	1090 <vprintf+0x60>
      if(c == 'd'){
    10aa:	05878063          	beq	a5,s8,10ea <vprintf+0xba>
      } else if(c == 'l') {
    10ae:	05978c63          	beq	a5,s9,1106 <vprintf+0xd6>
      } else if(c == 'x') {
    10b2:	07a78863          	beq	a5,s10,1122 <vprintf+0xf2>
      } else if(c == 'p') {
    10b6:	09b78463          	beq	a5,s11,113e <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    10ba:	07300713          	li	a4,115
    10be:	0ce78663          	beq	a5,a4,118a <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    10c2:	06300713          	li	a4,99
    10c6:	0ee78e63          	beq	a5,a4,11c2 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    10ca:	11478863          	beq	a5,s4,11da <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    10ce:	85d2                	mv	a1,s4
    10d0:	8556                	mv	a0,s5
    10d2:	00000097          	auipc	ra,0x0
    10d6:	e92080e7          	jalr	-366(ra) # f64 <putc>
        putc(fd, c);
    10da:	85ca                	mv	a1,s2
    10dc:	8556                	mv	a0,s5
    10de:	00000097          	auipc	ra,0x0
    10e2:	e86080e7          	jalr	-378(ra) # f64 <putc>
      }
      state = 0;
    10e6:	4981                	li	s3,0
    10e8:	b765                	j	1090 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    10ea:	008b0913          	addi	s2,s6,8
    10ee:	4685                	li	a3,1
    10f0:	4629                	li	a2,10
    10f2:	000b2583          	lw	a1,0(s6)
    10f6:	8556                	mv	a0,s5
    10f8:	00000097          	auipc	ra,0x0
    10fc:	e8e080e7          	jalr	-370(ra) # f86 <printint>
    1100:	8b4a                	mv	s6,s2
      state = 0;
    1102:	4981                	li	s3,0
    1104:	b771                	j	1090 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    1106:	008b0913          	addi	s2,s6,8
    110a:	4681                	li	a3,0
    110c:	4629                	li	a2,10
    110e:	000b2583          	lw	a1,0(s6)
    1112:	8556                	mv	a0,s5
    1114:	00000097          	auipc	ra,0x0
    1118:	e72080e7          	jalr	-398(ra) # f86 <printint>
    111c:	8b4a                	mv	s6,s2
      state = 0;
    111e:	4981                	li	s3,0
    1120:	bf85                	j	1090 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    1122:	008b0913          	addi	s2,s6,8
    1126:	4681                	li	a3,0
    1128:	4641                	li	a2,16
    112a:	000b2583          	lw	a1,0(s6)
    112e:	8556                	mv	a0,s5
    1130:	00000097          	auipc	ra,0x0
    1134:	e56080e7          	jalr	-426(ra) # f86 <printint>
    1138:	8b4a                	mv	s6,s2
      state = 0;
    113a:	4981                	li	s3,0
    113c:	bf91                	j	1090 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    113e:	008b0793          	addi	a5,s6,8
    1142:	f8f43423          	sd	a5,-120(s0)
    1146:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    114a:	03000593          	li	a1,48
    114e:	8556                	mv	a0,s5
    1150:	00000097          	auipc	ra,0x0
    1154:	e14080e7          	jalr	-492(ra) # f64 <putc>
  putc(fd, 'x');
    1158:	85ea                	mv	a1,s10
    115a:	8556                	mv	a0,s5
    115c:	00000097          	auipc	ra,0x0
    1160:	e08080e7          	jalr	-504(ra) # f64 <putc>
    1164:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1166:	03c9d793          	srli	a5,s3,0x3c
    116a:	97de                	add	a5,a5,s7
    116c:	0007c583          	lbu	a1,0(a5)
    1170:	8556                	mv	a0,s5
    1172:	00000097          	auipc	ra,0x0
    1176:	df2080e7          	jalr	-526(ra) # f64 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    117a:	0992                	slli	s3,s3,0x4
    117c:	397d                	addiw	s2,s2,-1
    117e:	fe0914e3          	bnez	s2,1166 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    1182:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    1186:	4981                	li	s3,0
    1188:	b721                	j	1090 <vprintf+0x60>
        s = va_arg(ap, char*);
    118a:	008b0993          	addi	s3,s6,8
    118e:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    1192:	02090163          	beqz	s2,11b4 <vprintf+0x184>
        while(*s != 0){
    1196:	00094583          	lbu	a1,0(s2)
    119a:	c9a1                	beqz	a1,11ea <vprintf+0x1ba>
          putc(fd, *s);
    119c:	8556                	mv	a0,s5
    119e:	00000097          	auipc	ra,0x0
    11a2:	dc6080e7          	jalr	-570(ra) # f64 <putc>
          s++;
    11a6:	0905                	addi	s2,s2,1
        while(*s != 0){
    11a8:	00094583          	lbu	a1,0(s2)
    11ac:	f9e5                	bnez	a1,119c <vprintf+0x16c>
        s = va_arg(ap, char*);
    11ae:	8b4e                	mv	s6,s3
      state = 0;
    11b0:	4981                	li	s3,0
    11b2:	bdf9                	j	1090 <vprintf+0x60>
          s = "(null)";
    11b4:	00000917          	auipc	s2,0x0
    11b8:	51490913          	addi	s2,s2,1300 # 16c8 <malloc+0x3ce>
        while(*s != 0){
    11bc:	02800593          	li	a1,40
    11c0:	bff1                	j	119c <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    11c2:	008b0913          	addi	s2,s6,8
    11c6:	000b4583          	lbu	a1,0(s6)
    11ca:	8556                	mv	a0,s5
    11cc:	00000097          	auipc	ra,0x0
    11d0:	d98080e7          	jalr	-616(ra) # f64 <putc>
    11d4:	8b4a                	mv	s6,s2
      state = 0;
    11d6:	4981                	li	s3,0
    11d8:	bd65                	j	1090 <vprintf+0x60>
        putc(fd, c);
    11da:	85d2                	mv	a1,s4
    11dc:	8556                	mv	a0,s5
    11de:	00000097          	auipc	ra,0x0
    11e2:	d86080e7          	jalr	-634(ra) # f64 <putc>
      state = 0;
    11e6:	4981                	li	s3,0
    11e8:	b565                	j	1090 <vprintf+0x60>
        s = va_arg(ap, char*);
    11ea:	8b4e                	mv	s6,s3
      state = 0;
    11ec:	4981                	li	s3,0
    11ee:	b54d                	j	1090 <vprintf+0x60>
    }
  }
}
    11f0:	70e6                	ld	ra,120(sp)
    11f2:	7446                	ld	s0,112(sp)
    11f4:	74a6                	ld	s1,104(sp)
    11f6:	7906                	ld	s2,96(sp)
    11f8:	69e6                	ld	s3,88(sp)
    11fa:	6a46                	ld	s4,80(sp)
    11fc:	6aa6                	ld	s5,72(sp)
    11fe:	6b06                	ld	s6,64(sp)
    1200:	7be2                	ld	s7,56(sp)
    1202:	7c42                	ld	s8,48(sp)
    1204:	7ca2                	ld	s9,40(sp)
    1206:	7d02                	ld	s10,32(sp)
    1208:	6de2                	ld	s11,24(sp)
    120a:	6109                	addi	sp,sp,128
    120c:	8082                	ret

000000000000120e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    120e:	715d                	addi	sp,sp,-80
    1210:	ec06                	sd	ra,24(sp)
    1212:	e822                	sd	s0,16(sp)
    1214:	1000                	addi	s0,sp,32
    1216:	e010                	sd	a2,0(s0)
    1218:	e414                	sd	a3,8(s0)
    121a:	e818                	sd	a4,16(s0)
    121c:	ec1c                	sd	a5,24(s0)
    121e:	03043023          	sd	a6,32(s0)
    1222:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    1226:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    122a:	8622                	mv	a2,s0
    122c:	00000097          	auipc	ra,0x0
    1230:	e04080e7          	jalr	-508(ra) # 1030 <vprintf>
}
    1234:	60e2                	ld	ra,24(sp)
    1236:	6442                	ld	s0,16(sp)
    1238:	6161                	addi	sp,sp,80
    123a:	8082                	ret

000000000000123c <printf>:

void
printf(const char *fmt, ...)
{
    123c:	711d                	addi	sp,sp,-96
    123e:	ec06                	sd	ra,24(sp)
    1240:	e822                	sd	s0,16(sp)
    1242:	1000                	addi	s0,sp,32
    1244:	e40c                	sd	a1,8(s0)
    1246:	e810                	sd	a2,16(s0)
    1248:	ec14                	sd	a3,24(s0)
    124a:	f018                	sd	a4,32(s0)
    124c:	f41c                	sd	a5,40(s0)
    124e:	03043823          	sd	a6,48(s0)
    1252:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    1256:	00840613          	addi	a2,s0,8
    125a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    125e:	85aa                	mv	a1,a0
    1260:	4505                	li	a0,1
    1262:	00000097          	auipc	ra,0x0
    1266:	dce080e7          	jalr	-562(ra) # 1030 <vprintf>
}
    126a:	60e2                	ld	ra,24(sp)
    126c:	6442                	ld	s0,16(sp)
    126e:	6125                	addi	sp,sp,96
    1270:	8082                	ret

0000000000001272 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1272:	1141                	addi	sp,sp,-16
    1274:	e422                	sd	s0,8(sp)
    1276:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1278:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    127c:	00001797          	auipc	a5,0x1
    1280:	d947b783          	ld	a5,-620(a5) # 2010 <freep>
    1284:	a805                	j	12b4 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    1286:	4618                	lw	a4,8(a2)
    1288:	9db9                	addw	a1,a1,a4
    128a:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    128e:	6398                	ld	a4,0(a5)
    1290:	6318                	ld	a4,0(a4)
    1292:	fee53823          	sd	a4,-16(a0)
    1296:	a091                	j	12da <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    1298:	ff852703          	lw	a4,-8(a0)
    129c:	9e39                	addw	a2,a2,a4
    129e:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    12a0:	ff053703          	ld	a4,-16(a0)
    12a4:	e398                	sd	a4,0(a5)
    12a6:	a099                	j	12ec <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    12a8:	6398                	ld	a4,0(a5)
    12aa:	00e7e463          	bltu	a5,a4,12b2 <free+0x40>
    12ae:	00e6ea63          	bltu	a3,a4,12c2 <free+0x50>
{
    12b2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    12b4:	fed7fae3          	bgeu	a5,a3,12a8 <free+0x36>
    12b8:	6398                	ld	a4,0(a5)
    12ba:	00e6e463          	bltu	a3,a4,12c2 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    12be:	fee7eae3          	bltu	a5,a4,12b2 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    12c2:	ff852583          	lw	a1,-8(a0)
    12c6:	6390                	ld	a2,0(a5)
    12c8:	02059713          	slli	a4,a1,0x20
    12cc:	9301                	srli	a4,a4,0x20
    12ce:	0712                	slli	a4,a4,0x4
    12d0:	9736                	add	a4,a4,a3
    12d2:	fae60ae3          	beq	a2,a4,1286 <free+0x14>
    bp->s.ptr = p->s.ptr;
    12d6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    12da:	4790                	lw	a2,8(a5)
    12dc:	02061713          	slli	a4,a2,0x20
    12e0:	9301                	srli	a4,a4,0x20
    12e2:	0712                	slli	a4,a4,0x4
    12e4:	973e                	add	a4,a4,a5
    12e6:	fae689e3          	beq	a3,a4,1298 <free+0x26>
  } else
    p->s.ptr = bp;
    12ea:	e394                	sd	a3,0(a5)
  freep = p;
    12ec:	00001717          	auipc	a4,0x1
    12f0:	d2f73223          	sd	a5,-732(a4) # 2010 <freep>
}
    12f4:	6422                	ld	s0,8(sp)
    12f6:	0141                	addi	sp,sp,16
    12f8:	8082                	ret

00000000000012fa <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    12fa:	7139                	addi	sp,sp,-64
    12fc:	fc06                	sd	ra,56(sp)
    12fe:	f822                	sd	s0,48(sp)
    1300:	f426                	sd	s1,40(sp)
    1302:	f04a                	sd	s2,32(sp)
    1304:	ec4e                	sd	s3,24(sp)
    1306:	e852                	sd	s4,16(sp)
    1308:	e456                	sd	s5,8(sp)
    130a:	e05a                	sd	s6,0(sp)
    130c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    130e:	02051493          	slli	s1,a0,0x20
    1312:	9081                	srli	s1,s1,0x20
    1314:	04bd                	addi	s1,s1,15
    1316:	8091                	srli	s1,s1,0x4
    1318:	0014899b          	addiw	s3,s1,1
    131c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    131e:	00001517          	auipc	a0,0x1
    1322:	cf253503          	ld	a0,-782(a0) # 2010 <freep>
    1326:	c515                	beqz	a0,1352 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1328:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    132a:	4798                	lw	a4,8(a5)
    132c:	02977f63          	bgeu	a4,s1,136a <malloc+0x70>
    1330:	8a4e                	mv	s4,s3
    1332:	0009871b          	sext.w	a4,s3
    1336:	6685                	lui	a3,0x1
    1338:	00d77363          	bgeu	a4,a3,133e <malloc+0x44>
    133c:	6a05                	lui	s4,0x1
    133e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    1342:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    1346:	00001917          	auipc	s2,0x1
    134a:	cca90913          	addi	s2,s2,-822 # 2010 <freep>
  if(p == (char*)-1)
    134e:	5afd                	li	s5,-1
    1350:	a88d                	j	13c2 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    1352:	00001797          	auipc	a5,0x1
    1356:	0b678793          	addi	a5,a5,182 # 2408 <base>
    135a:	00001717          	auipc	a4,0x1
    135e:	caf73b23          	sd	a5,-842(a4) # 2010 <freep>
    1362:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    1364:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    1368:	b7e1                	j	1330 <malloc+0x36>
      if(p->s.size == nunits)
    136a:	02e48b63          	beq	s1,a4,13a0 <malloc+0xa6>
        p->s.size -= nunits;
    136e:	4137073b          	subw	a4,a4,s3
    1372:	c798                	sw	a4,8(a5)
        p += p->s.size;
    1374:	1702                	slli	a4,a4,0x20
    1376:	9301                	srli	a4,a4,0x20
    1378:	0712                	slli	a4,a4,0x4
    137a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    137c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    1380:	00001717          	auipc	a4,0x1
    1384:	c8a73823          	sd	a0,-880(a4) # 2010 <freep>
      return (void*)(p + 1);
    1388:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    138c:	70e2                	ld	ra,56(sp)
    138e:	7442                	ld	s0,48(sp)
    1390:	74a2                	ld	s1,40(sp)
    1392:	7902                	ld	s2,32(sp)
    1394:	69e2                	ld	s3,24(sp)
    1396:	6a42                	ld	s4,16(sp)
    1398:	6aa2                	ld	s5,8(sp)
    139a:	6b02                	ld	s6,0(sp)
    139c:	6121                	addi	sp,sp,64
    139e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    13a0:	6398                	ld	a4,0(a5)
    13a2:	e118                	sd	a4,0(a0)
    13a4:	bff1                	j	1380 <malloc+0x86>
  hp->s.size = nu;
    13a6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    13aa:	0541                	addi	a0,a0,16
    13ac:	00000097          	auipc	ra,0x0
    13b0:	ec6080e7          	jalr	-314(ra) # 1272 <free>
  return freep;
    13b4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    13b8:	d971                	beqz	a0,138c <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    13ba:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    13bc:	4798                	lw	a4,8(a5)
    13be:	fa9776e3          	bgeu	a4,s1,136a <malloc+0x70>
    if(p == freep)
    13c2:	00093703          	ld	a4,0(s2)
    13c6:	853e                	mv	a0,a5
    13c8:	fef719e3          	bne	a4,a5,13ba <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    13cc:	8552                	mv	a0,s4
    13ce:	00000097          	auipc	ra,0x0
    13d2:	b4e080e7          	jalr	-1202(ra) # f1c <sbrk>
  if(p == (char*)-1)
    13d6:	fd5518e3          	bne	a0,s5,13a6 <malloc+0xac>
        return 0;
    13da:	4501                	li	a0,0
    13dc:	bf45                	j	138c <malloc+0x92>


user/_alarmtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <periodic>:

volatile static int count;

void
periodic()
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  count = count + 1;
   8:	00001797          	auipc	a5,0x1
   c:	ff87a783          	lw	a5,-8(a5) # 1000 <count>
  10:	2785                	addiw	a5,a5,1
  12:	00001717          	auipc	a4,0x1
  16:	fef72723          	sw	a5,-18(a4) # 1000 <count>
  printf("alarm!\n");
  1a:	00001517          	auipc	a0,0x1
  1e:	c2650513          	addi	a0,a0,-986 # c40 <malloc+0xee>
  22:	00001097          	auipc	ra,0x1
  26:	a72080e7          	jalr	-1422(ra) # a94 <printf>
  sigreturn();
  2a:	00000097          	auipc	ra,0x0
  2e:	77a080e7          	jalr	1914(ra) # 7a4 <sigreturn>
}
  32:	60a2                	ld	ra,8(sp)
  34:	6402                	ld	s0,0(sp)
  36:	0141                	addi	sp,sp,16
  38:	8082                	ret

000000000000003a <slow_handler>:
  }
}

void
slow_handler()
{
  3a:	1101                	addi	sp,sp,-32
  3c:	ec06                	sd	ra,24(sp)
  3e:	e822                	sd	s0,16(sp)
  40:	e426                	sd	s1,8(sp)
  42:	1000                	addi	s0,sp,32
  count++;
  44:	00001497          	auipc	s1,0x1
  48:	fbc48493          	addi	s1,s1,-68 # 1000 <count>
  4c:	00001797          	auipc	a5,0x1
  50:	fb47a783          	lw	a5,-76(a5) # 1000 <count>
  54:	2785                	addiw	a5,a5,1
  56:	c09c                	sw	a5,0(s1)
  printf("alarm!\n");
  58:	00001517          	auipc	a0,0x1
  5c:	be850513          	addi	a0,a0,-1048 # c40 <malloc+0xee>
  60:	00001097          	auipc	ra,0x1
  64:	a34080e7          	jalr	-1484(ra) # a94 <printf>
  if (count > 1) {
  68:	4098                	lw	a4,0(s1)
  6a:	2701                	sext.w	a4,a4
  6c:	4685                	li	a3,1
  6e:	1dcd67b7          	lui	a5,0x1dcd6
  72:	50078793          	addi	a5,a5,1280 # 1dcd6500 <base+0x1dcd54f0>
  76:	02e6c463          	blt	a3,a4,9e <slow_handler+0x64>
    printf("test2 failed: alarm handler called more than once\n");
    exit(1);
  }
  for (int i = 0; i < 1000*500000; i++) {
    asm volatile("nop"); // avoid compiler optimizing away loop
  7a:	0001                	nop
  for (int i = 0; i < 1000*500000; i++) {
  7c:	37fd                	addiw	a5,a5,-1
  7e:	fff5                	bnez	a5,7a <slow_handler+0x40>
  }
  sigalarm(0, 0);
  80:	4581                	li	a1,0
  82:	4501                	li	a0,0
  84:	00000097          	auipc	ra,0x0
  88:	728080e7          	jalr	1832(ra) # 7ac <sigalarm>
  sigreturn();
  8c:	00000097          	auipc	ra,0x0
  90:	718080e7          	jalr	1816(ra) # 7a4 <sigreturn>
}
  94:	60e2                	ld	ra,24(sp)
  96:	6442                	ld	s0,16(sp)
  98:	64a2                	ld	s1,8(sp)
  9a:	6105                	addi	sp,sp,32
  9c:	8082                	ret
    printf("test2 failed: alarm handler called more than once\n");
  9e:	00001517          	auipc	a0,0x1
  a2:	baa50513          	addi	a0,a0,-1110 # c48 <malloc+0xf6>
  a6:	00001097          	auipc	ra,0x1
  aa:	9ee080e7          	jalr	-1554(ra) # a94 <printf>
    exit(1);
  ae:	4505                	li	a0,1
  b0:	00000097          	auipc	ra,0x0
  b4:	644080e7          	jalr	1604(ra) # 6f4 <exit>

00000000000000b8 <dummy_handler>:
//
// dummy alarm handler; after running immediately uninstall
// itself and finish signal handling
void
dummy_handler()
{
  b8:	1141                	addi	sp,sp,-16
  ba:	e406                	sd	ra,8(sp)
  bc:	e022                	sd	s0,0(sp)
  be:	0800                	addi	s0,sp,16
  sigalarm(0, 0);
  c0:	4581                	li	a1,0
  c2:	4501                	li	a0,0
  c4:	00000097          	auipc	ra,0x0
  c8:	6e8080e7          	jalr	1768(ra) # 7ac <sigalarm>
  sigreturn();
  cc:	00000097          	auipc	ra,0x0
  d0:	6d8080e7          	jalr	1752(ra) # 7a4 <sigreturn>
}
  d4:	60a2                	ld	ra,8(sp)
  d6:	6402                	ld	s0,0(sp)
  d8:	0141                	addi	sp,sp,16
  da:	8082                	ret

00000000000000dc <test0>:
{
  dc:	7139                	addi	sp,sp,-64
  de:	fc06                	sd	ra,56(sp)
  e0:	f822                	sd	s0,48(sp)
  e2:	f426                	sd	s1,40(sp)
  e4:	f04a                	sd	s2,32(sp)
  e6:	ec4e                	sd	s3,24(sp)
  e8:	e852                	sd	s4,16(sp)
  ea:	e456                	sd	s5,8(sp)
  ec:	0080                	addi	s0,sp,64
  printf("test0 start\n");
  ee:	00001517          	auipc	a0,0x1
  f2:	b9250513          	addi	a0,a0,-1134 # c80 <malloc+0x12e>
  f6:	00001097          	auipc	ra,0x1
  fa:	99e080e7          	jalr	-1634(ra) # a94 <printf>
  count = 0;
  fe:	00001797          	auipc	a5,0x1
 102:	f007a123          	sw	zero,-254(a5) # 1000 <count>
  sigalarm(2, periodic);
 106:	00000597          	auipc	a1,0x0
 10a:	efa58593          	addi	a1,a1,-262 # 0 <periodic>
 10e:	4509                	li	a0,2
 110:	00000097          	auipc	ra,0x0
 114:	69c080e7          	jalr	1692(ra) # 7ac <sigalarm>
  for(i = 0; i < 1000*500000; i++){
 118:	4481                	li	s1,0
    if((i % 1000000) == 0)
 11a:	000f4937          	lui	s2,0xf4
 11e:	2409091b          	addiw	s2,s2,576
      write(2, ".", 1);
 122:	00001a97          	auipc	s5,0x1
 126:	b6ea8a93          	addi	s5,s5,-1170 # c90 <malloc+0x13e>
    if(count > 0)
 12a:	00001a17          	auipc	s4,0x1
 12e:	ed6a0a13          	addi	s4,s4,-298 # 1000 <count>
  for(i = 0; i < 1000*500000; i++){
 132:	1dcd69b7          	lui	s3,0x1dcd6
 136:	50098993          	addi	s3,s3,1280 # 1dcd6500 <base+0x1dcd54f0>
 13a:	a005                	j	15a <test0+0x7e>
      write(2, ".", 1);
 13c:	4605                	li	a2,1
 13e:	85d6                	mv	a1,s5
 140:	4509                	li	a0,2
 142:	00000097          	auipc	ra,0x0
 146:	5d2080e7          	jalr	1490(ra) # 714 <write>
    if(count > 0)
 14a:	000a2783          	lw	a5,0(s4)
 14e:	2781                	sext.w	a5,a5
 150:	00f04963          	bgtz	a5,162 <test0+0x86>
  for(i = 0; i < 1000*500000; i++){
 154:	2485                	addiw	s1,s1,1
 156:	01348663          	beq	s1,s3,162 <test0+0x86>
    if((i % 1000000) == 0)
 15a:	0324e7bb          	remw	a5,s1,s2
 15e:	f7f5                	bnez	a5,14a <test0+0x6e>
 160:	bff1                	j	13c <test0+0x60>
  sigalarm(0, 0);
 162:	4581                	li	a1,0
 164:	4501                	li	a0,0
 166:	00000097          	auipc	ra,0x0
 16a:	646080e7          	jalr	1606(ra) # 7ac <sigalarm>
  if(count > 0){
 16e:	00001797          	auipc	a5,0x1
 172:	e927a783          	lw	a5,-366(a5) # 1000 <count>
 176:	02f05363          	blez	a5,19c <test0+0xc0>
    printf("test0 passed\n");
 17a:	00001517          	auipc	a0,0x1
 17e:	b1e50513          	addi	a0,a0,-1250 # c98 <malloc+0x146>
 182:	00001097          	auipc	ra,0x1
 186:	912080e7          	jalr	-1774(ra) # a94 <printf>
}
 18a:	70e2                	ld	ra,56(sp)
 18c:	7442                	ld	s0,48(sp)
 18e:	74a2                	ld	s1,40(sp)
 190:	7902                	ld	s2,32(sp)
 192:	69e2                	ld	s3,24(sp)
 194:	6a42                	ld	s4,16(sp)
 196:	6aa2                	ld	s5,8(sp)
 198:	6121                	addi	sp,sp,64
 19a:	8082                	ret
    printf("\ntest0 failed: the kernel never called the alarm handler\n");
 19c:	00001517          	auipc	a0,0x1
 1a0:	b0c50513          	addi	a0,a0,-1268 # ca8 <malloc+0x156>
 1a4:	00001097          	auipc	ra,0x1
 1a8:	8f0080e7          	jalr	-1808(ra) # a94 <printf>
}
 1ac:	bff9                	j	18a <test0+0xae>

00000000000001ae <foo>:
void __attribute__ ((noinline)) foo(int i, int *j) {
 1ae:	1101                	addi	sp,sp,-32
 1b0:	ec06                	sd	ra,24(sp)
 1b2:	e822                	sd	s0,16(sp)
 1b4:	e426                	sd	s1,8(sp)
 1b6:	1000                	addi	s0,sp,32
 1b8:	84ae                	mv	s1,a1
  if((i % 2500000) == 0) {
 1ba:	002627b7          	lui	a5,0x262
 1be:	5a07879b          	addiw	a5,a5,1440
 1c2:	02f5653b          	remw	a0,a0,a5
 1c6:	c909                	beqz	a0,1d8 <foo+0x2a>
  *j += 1;
 1c8:	409c                	lw	a5,0(s1)
 1ca:	2785                	addiw	a5,a5,1
 1cc:	c09c                	sw	a5,0(s1)
}
 1ce:	60e2                	ld	ra,24(sp)
 1d0:	6442                	ld	s0,16(sp)
 1d2:	64a2                	ld	s1,8(sp)
 1d4:	6105                	addi	sp,sp,32
 1d6:	8082                	ret
    write(2, ".", 1);
 1d8:	4605                	li	a2,1
 1da:	00001597          	auipc	a1,0x1
 1de:	ab658593          	addi	a1,a1,-1354 # c90 <malloc+0x13e>
 1e2:	4509                	li	a0,2
 1e4:	00000097          	auipc	ra,0x0
 1e8:	530080e7          	jalr	1328(ra) # 714 <write>
 1ec:	bff1                	j	1c8 <foo+0x1a>

00000000000001ee <test1>:
{
 1ee:	7139                	addi	sp,sp,-64
 1f0:	fc06                	sd	ra,56(sp)
 1f2:	f822                	sd	s0,48(sp)
 1f4:	f426                	sd	s1,40(sp)
 1f6:	f04a                	sd	s2,32(sp)
 1f8:	ec4e                	sd	s3,24(sp)
 1fa:	e852                	sd	s4,16(sp)
 1fc:	0080                	addi	s0,sp,64
  printf("test1 start\n");
 1fe:	00001517          	auipc	a0,0x1
 202:	aea50513          	addi	a0,a0,-1302 # ce8 <malloc+0x196>
 206:	00001097          	auipc	ra,0x1
 20a:	88e080e7          	jalr	-1906(ra) # a94 <printf>
  count = 0;
 20e:	00001797          	auipc	a5,0x1
 212:	de07a923          	sw	zero,-526(a5) # 1000 <count>
  j = 0;
 216:	fc042623          	sw	zero,-52(s0)
  sigalarm(2, periodic);
 21a:	00000597          	auipc	a1,0x0
 21e:	de658593          	addi	a1,a1,-538 # 0 <periodic>
 222:	4509                	li	a0,2
 224:	00000097          	auipc	ra,0x0
 228:	588080e7          	jalr	1416(ra) # 7ac <sigalarm>
  for(i = 0; i < 500000000; i++){
 22c:	4481                	li	s1,0
    if(count >= 10)
 22e:	00001a17          	auipc	s4,0x1
 232:	dd2a0a13          	addi	s4,s4,-558 # 1000 <count>
 236:	49a5                	li	s3,9
  for(i = 0; i < 500000000; i++){
 238:	1dcd6937          	lui	s2,0x1dcd6
 23c:	50090913          	addi	s2,s2,1280 # 1dcd6500 <base+0x1dcd54f0>
    if(count >= 10)
 240:	000a2783          	lw	a5,0(s4)
 244:	2781                	sext.w	a5,a5
 246:	00f9cc63          	blt	s3,a5,25e <test1+0x70>
    foo(i, &j);
 24a:	fcc40593          	addi	a1,s0,-52
 24e:	8526                	mv	a0,s1
 250:	00000097          	auipc	ra,0x0
 254:	f5e080e7          	jalr	-162(ra) # 1ae <foo>
  for(i = 0; i < 500000000; i++){
 258:	2485                	addiw	s1,s1,1
 25a:	ff2493e3          	bne	s1,s2,240 <test1+0x52>
  if(count < 10){
 25e:	00001717          	auipc	a4,0x1
 262:	da272703          	lw	a4,-606(a4) # 1000 <count>
 266:	47a5                	li	a5,9
 268:	02e7d663          	bge	a5,a4,294 <test1+0xa6>
  } else if(i != j){
 26c:	fcc42783          	lw	a5,-52(s0)
 270:	02978b63          	beq	a5,s1,2a6 <test1+0xb8>
    printf("\ntest1 failed: foo() executed fewer times than it was called\n");
 274:	00001517          	auipc	a0,0x1
 278:	ab450513          	addi	a0,a0,-1356 # d28 <malloc+0x1d6>
 27c:	00001097          	auipc	ra,0x1
 280:	818080e7          	jalr	-2024(ra) # a94 <printf>
}
 284:	70e2                	ld	ra,56(sp)
 286:	7442                	ld	s0,48(sp)
 288:	74a2                	ld	s1,40(sp)
 28a:	7902                	ld	s2,32(sp)
 28c:	69e2                	ld	s3,24(sp)
 28e:	6a42                	ld	s4,16(sp)
 290:	6121                	addi	sp,sp,64
 292:	8082                	ret
    printf("\ntest1 failed: too few calls to the handler\n");
 294:	00001517          	auipc	a0,0x1
 298:	a6450513          	addi	a0,a0,-1436 # cf8 <malloc+0x1a6>
 29c:	00000097          	auipc	ra,0x0
 2a0:	7f8080e7          	jalr	2040(ra) # a94 <printf>
 2a4:	b7c5                	j	284 <test1+0x96>
    printf("test1 passed\n");
 2a6:	00001517          	auipc	a0,0x1
 2aa:	ac250513          	addi	a0,a0,-1342 # d68 <malloc+0x216>
 2ae:	00000097          	auipc	ra,0x0
 2b2:	7e6080e7          	jalr	2022(ra) # a94 <printf>
}
 2b6:	b7f9                	j	284 <test1+0x96>

00000000000002b8 <test2>:
{
 2b8:	715d                	addi	sp,sp,-80
 2ba:	e486                	sd	ra,72(sp)
 2bc:	e0a2                	sd	s0,64(sp)
 2be:	fc26                	sd	s1,56(sp)
 2c0:	f84a                	sd	s2,48(sp)
 2c2:	f44e                	sd	s3,40(sp)
 2c4:	f052                	sd	s4,32(sp)
 2c6:	ec56                	sd	s5,24(sp)
 2c8:	0880                	addi	s0,sp,80
  printf("test2 start\n");
 2ca:	00001517          	auipc	a0,0x1
 2ce:	aae50513          	addi	a0,a0,-1362 # d78 <malloc+0x226>
 2d2:	00000097          	auipc	ra,0x0
 2d6:	7c2080e7          	jalr	1986(ra) # a94 <printf>
  if ((pid = fork()) < 0) {
 2da:	00000097          	auipc	ra,0x0
 2de:	412080e7          	jalr	1042(ra) # 6ec <fork>
 2e2:	04054263          	bltz	a0,326 <test2+0x6e>
 2e6:	84aa                	mv	s1,a0
  if (pid == 0) {
 2e8:	e539                	bnez	a0,336 <test2+0x7e>
    count = 0;
 2ea:	00001797          	auipc	a5,0x1
 2ee:	d007ab23          	sw	zero,-746(a5) # 1000 <count>
    sigalarm(2, slow_handler);
 2f2:	00000597          	auipc	a1,0x0
 2f6:	d4858593          	addi	a1,a1,-696 # 3a <slow_handler>
 2fa:	4509                	li	a0,2
 2fc:	00000097          	auipc	ra,0x0
 300:	4b0080e7          	jalr	1200(ra) # 7ac <sigalarm>
      if((i % 1000000) == 0)
 304:	000f4937          	lui	s2,0xf4
 308:	2409091b          	addiw	s2,s2,576
        write(2, ".", 1);
 30c:	00001a97          	auipc	s5,0x1
 310:	984a8a93          	addi	s5,s5,-1660 # c90 <malloc+0x13e>
      if(count > 0)
 314:	00001a17          	auipc	s4,0x1
 318:	ceca0a13          	addi	s4,s4,-788 # 1000 <count>
    for(i = 0; i < 1000*500000; i++){
 31c:	1dcd69b7          	lui	s3,0x1dcd6
 320:	50098993          	addi	s3,s3,1280 # 1dcd6500 <base+0x1dcd54f0>
 324:	a891                	j	378 <test2+0xc0>
    printf("test2: fork failed\n");
 326:	00001517          	auipc	a0,0x1
 32a:	a6250513          	addi	a0,a0,-1438 # d88 <malloc+0x236>
 32e:	00000097          	auipc	ra,0x0
 332:	766080e7          	jalr	1894(ra) # a94 <printf>
  wait(&status);
 336:	fbc40513          	addi	a0,s0,-68
 33a:	00000097          	auipc	ra,0x0
 33e:	3c2080e7          	jalr	962(ra) # 6fc <wait>
  if (status == 0) {
 342:	fbc42783          	lw	a5,-68(s0)
 346:	c7a5                	beqz	a5,3ae <test2+0xf6>
}
 348:	60a6                	ld	ra,72(sp)
 34a:	6406                	ld	s0,64(sp)
 34c:	74e2                	ld	s1,56(sp)
 34e:	7942                	ld	s2,48(sp)
 350:	79a2                	ld	s3,40(sp)
 352:	7a02                	ld	s4,32(sp)
 354:	6ae2                	ld	s5,24(sp)
 356:	6161                	addi	sp,sp,80
 358:	8082                	ret
        write(2, ".", 1);
 35a:	4605                	li	a2,1
 35c:	85d6                	mv	a1,s5
 35e:	4509                	li	a0,2
 360:	00000097          	auipc	ra,0x0
 364:	3b4080e7          	jalr	948(ra) # 714 <write>
      if(count > 0)
 368:	000a2783          	lw	a5,0(s4)
 36c:	2781                	sext.w	a5,a5
 36e:	00f04963          	bgtz	a5,380 <test2+0xc8>
    for(i = 0; i < 1000*500000; i++){
 372:	2485                	addiw	s1,s1,1
 374:	01348663          	beq	s1,s3,380 <test2+0xc8>
      if((i % 1000000) == 0)
 378:	0324e7bb          	remw	a5,s1,s2
 37c:	f7f5                	bnez	a5,368 <test2+0xb0>
 37e:	bff1                	j	35a <test2+0xa2>
    if (count == 0) {
 380:	00001797          	auipc	a5,0x1
 384:	c807a783          	lw	a5,-896(a5) # 1000 <count>
 388:	ef91                	bnez	a5,3a4 <test2+0xec>
      printf("\ntest2 failed: alarm not called\n");
 38a:	00001517          	auipc	a0,0x1
 38e:	a1650513          	addi	a0,a0,-1514 # da0 <malloc+0x24e>
 392:	00000097          	auipc	ra,0x0
 396:	702080e7          	jalr	1794(ra) # a94 <printf>
      exit(1);
 39a:	4505                	li	a0,1
 39c:	00000097          	auipc	ra,0x0
 3a0:	358080e7          	jalr	856(ra) # 6f4 <exit>
    exit(0);
 3a4:	4501                	li	a0,0
 3a6:	00000097          	auipc	ra,0x0
 3aa:	34e080e7          	jalr	846(ra) # 6f4 <exit>
    printf("test2 passed\n");
 3ae:	00001517          	auipc	a0,0x1
 3b2:	a1a50513          	addi	a0,a0,-1510 # dc8 <malloc+0x276>
 3b6:	00000097          	auipc	ra,0x0
 3ba:	6de080e7          	jalr	1758(ra) # a94 <printf>
}
 3be:	b769                	j	348 <test2+0x90>

00000000000003c0 <test3>:
//
// tests that the return from sys_sigreturn() does not
// modify the a0 register
void
test3()
{
 3c0:	1141                	addi	sp,sp,-16
 3c2:	e406                	sd	ra,8(sp)
 3c4:	e022                	sd	s0,0(sp)
 3c6:	0800                	addi	s0,sp,16
  uint64 a0;

  sigalarm(1, dummy_handler);
 3c8:	00000597          	auipc	a1,0x0
 3cc:	cf058593          	addi	a1,a1,-784 # b8 <dummy_handler>
 3d0:	4505                	li	a0,1
 3d2:	00000097          	auipc	ra,0x0
 3d6:	3da080e7          	jalr	986(ra) # 7ac <sigalarm>
  printf("test3 start\n");
 3da:	00001517          	auipc	a0,0x1
 3de:	9fe50513          	addi	a0,a0,-1538 # dd8 <malloc+0x286>
 3e2:	00000097          	auipc	ra,0x0
 3e6:	6b2080e7          	jalr	1714(ra) # a94 <printf>

  asm volatile("lui a5, 0");
 3ea:	000007b7          	lui	a5,0x0
  asm volatile("addi a0, a5, 0xac" : : : "a0");
 3ee:	0ac78513          	addi	a0,a5,172 # ac <slow_handler+0x72>
 3f2:	1dcd67b7          	lui	a5,0x1dcd6
 3f6:	50078793          	addi	a5,a5,1280 # 1dcd6500 <base+0x1dcd54f0>
  for(int i = 0; i < 500000000; i++)
 3fa:	37fd                	addiw	a5,a5,-1
 3fc:	fffd                	bnez	a5,3fa <test3+0x3a>
    ;
  asm volatile("mv %0, a0" : "=r" (a0) );
 3fe:	872a                	mv	a4,a0

  if(a0 != 0xac)
 400:	0ac00793          	li	a5,172
 404:	00f70e63          	beq	a4,a5,420 <test3+0x60>
    printf("test3 failed: register a0 changed\n");
 408:	00001517          	auipc	a0,0x1
 40c:	9e050513          	addi	a0,a0,-1568 # de8 <malloc+0x296>
 410:	00000097          	auipc	ra,0x0
 414:	684080e7          	jalr	1668(ra) # a94 <printf>
  else
    printf("test3 passed\n");
 418:	60a2                	ld	ra,8(sp)
 41a:	6402                	ld	s0,0(sp)
 41c:	0141                	addi	sp,sp,16
 41e:	8082                	ret
    printf("test3 passed\n");
 420:	00001517          	auipc	a0,0x1
 424:	9f050513          	addi	a0,a0,-1552 # e10 <malloc+0x2be>
 428:	00000097          	auipc	ra,0x0
 42c:	66c080e7          	jalr	1644(ra) # a94 <printf>
 430:	b7e5                	j	418 <test3+0x58>

0000000000000432 <main>:
{
 432:	1141                	addi	sp,sp,-16
 434:	e406                	sd	ra,8(sp)
 436:	e022                	sd	s0,0(sp)
 438:	0800                	addi	s0,sp,16
  test0();
 43a:	00000097          	auipc	ra,0x0
 43e:	ca2080e7          	jalr	-862(ra) # dc <test0>
  test1();
 442:	00000097          	auipc	ra,0x0
 446:	dac080e7          	jalr	-596(ra) # 1ee <test1>
  test2();
 44a:	00000097          	auipc	ra,0x0
 44e:	e6e080e7          	jalr	-402(ra) # 2b8 <test2>
  test3();
 452:	00000097          	auipc	ra,0x0
 456:	f6e080e7          	jalr	-146(ra) # 3c0 <test3>
  exit(0);
 45a:	4501                	li	a0,0
 45c:	00000097          	auipc	ra,0x0
 460:	298080e7          	jalr	664(ra) # 6f4 <exit>

0000000000000464 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 464:	1141                	addi	sp,sp,-16
 466:	e406                	sd	ra,8(sp)
 468:	e022                	sd	s0,0(sp)
 46a:	0800                	addi	s0,sp,16
  extern int main();
  main();
 46c:	00000097          	auipc	ra,0x0
 470:	fc6080e7          	jalr	-58(ra) # 432 <main>
  exit(0);
 474:	4501                	li	a0,0
 476:	00000097          	auipc	ra,0x0
 47a:	27e080e7          	jalr	638(ra) # 6f4 <exit>

000000000000047e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 47e:	1141                	addi	sp,sp,-16
 480:	e422                	sd	s0,8(sp)
 482:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 484:	87aa                	mv	a5,a0
 486:	0585                	addi	a1,a1,1
 488:	0785                	addi	a5,a5,1
 48a:	fff5c703          	lbu	a4,-1(a1)
 48e:	fee78fa3          	sb	a4,-1(a5)
 492:	fb75                	bnez	a4,486 <strcpy+0x8>
    ;
  return os;
}
 494:	6422                	ld	s0,8(sp)
 496:	0141                	addi	sp,sp,16
 498:	8082                	ret

000000000000049a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 49a:	1141                	addi	sp,sp,-16
 49c:	e422                	sd	s0,8(sp)
 49e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 4a0:	00054783          	lbu	a5,0(a0)
 4a4:	cb91                	beqz	a5,4b8 <strcmp+0x1e>
 4a6:	0005c703          	lbu	a4,0(a1)
 4aa:	00f71763          	bne	a4,a5,4b8 <strcmp+0x1e>
    p++, q++;
 4ae:	0505                	addi	a0,a0,1
 4b0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 4b2:	00054783          	lbu	a5,0(a0)
 4b6:	fbe5                	bnez	a5,4a6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 4b8:	0005c503          	lbu	a0,0(a1)
}
 4bc:	40a7853b          	subw	a0,a5,a0
 4c0:	6422                	ld	s0,8(sp)
 4c2:	0141                	addi	sp,sp,16
 4c4:	8082                	ret

00000000000004c6 <strlen>:

uint
strlen(const char *s)
{
 4c6:	1141                	addi	sp,sp,-16
 4c8:	e422                	sd	s0,8(sp)
 4ca:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 4cc:	00054783          	lbu	a5,0(a0)
 4d0:	cf91                	beqz	a5,4ec <strlen+0x26>
 4d2:	0505                	addi	a0,a0,1
 4d4:	87aa                	mv	a5,a0
 4d6:	4685                	li	a3,1
 4d8:	9e89                	subw	a3,a3,a0
 4da:	00f6853b          	addw	a0,a3,a5
 4de:	0785                	addi	a5,a5,1
 4e0:	fff7c703          	lbu	a4,-1(a5)
 4e4:	fb7d                	bnez	a4,4da <strlen+0x14>
    ;
  return n;
}
 4e6:	6422                	ld	s0,8(sp)
 4e8:	0141                	addi	sp,sp,16
 4ea:	8082                	ret
  for(n = 0; s[n]; n++)
 4ec:	4501                	li	a0,0
 4ee:	bfe5                	j	4e6 <strlen+0x20>

00000000000004f0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 4f0:	1141                	addi	sp,sp,-16
 4f2:	e422                	sd	s0,8(sp)
 4f4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 4f6:	ce09                	beqz	a2,510 <memset+0x20>
 4f8:	87aa                	mv	a5,a0
 4fa:	fff6071b          	addiw	a4,a2,-1
 4fe:	1702                	slli	a4,a4,0x20
 500:	9301                	srli	a4,a4,0x20
 502:	0705                	addi	a4,a4,1
 504:	972a                	add	a4,a4,a0
    cdst[i] = c;
 506:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 50a:	0785                	addi	a5,a5,1
 50c:	fee79de3          	bne	a5,a4,506 <memset+0x16>
  }
  return dst;
}
 510:	6422                	ld	s0,8(sp)
 512:	0141                	addi	sp,sp,16
 514:	8082                	ret

0000000000000516 <strchr>:

char*
strchr(const char *s, char c)
{
 516:	1141                	addi	sp,sp,-16
 518:	e422                	sd	s0,8(sp)
 51a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 51c:	00054783          	lbu	a5,0(a0)
 520:	cb99                	beqz	a5,536 <strchr+0x20>
    if(*s == c)
 522:	00f58763          	beq	a1,a5,530 <strchr+0x1a>
  for(; *s; s++)
 526:	0505                	addi	a0,a0,1
 528:	00054783          	lbu	a5,0(a0)
 52c:	fbfd                	bnez	a5,522 <strchr+0xc>
      return (char*)s;
  return 0;
 52e:	4501                	li	a0,0
}
 530:	6422                	ld	s0,8(sp)
 532:	0141                	addi	sp,sp,16
 534:	8082                	ret
  return 0;
 536:	4501                	li	a0,0
 538:	bfe5                	j	530 <strchr+0x1a>

000000000000053a <gets>:

char*
gets(char *buf, int max)
{
 53a:	711d                	addi	sp,sp,-96
 53c:	ec86                	sd	ra,88(sp)
 53e:	e8a2                	sd	s0,80(sp)
 540:	e4a6                	sd	s1,72(sp)
 542:	e0ca                	sd	s2,64(sp)
 544:	fc4e                	sd	s3,56(sp)
 546:	f852                	sd	s4,48(sp)
 548:	f456                	sd	s5,40(sp)
 54a:	f05a                	sd	s6,32(sp)
 54c:	ec5e                	sd	s7,24(sp)
 54e:	1080                	addi	s0,sp,96
 550:	8baa                	mv	s7,a0
 552:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 554:	892a                	mv	s2,a0
 556:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 558:	4aa9                	li	s5,10
 55a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 55c:	89a6                	mv	s3,s1
 55e:	2485                	addiw	s1,s1,1
 560:	0344d863          	bge	s1,s4,590 <gets+0x56>
    cc = read(0, &c, 1);
 564:	4605                	li	a2,1
 566:	faf40593          	addi	a1,s0,-81
 56a:	4501                	li	a0,0
 56c:	00000097          	auipc	ra,0x0
 570:	1a0080e7          	jalr	416(ra) # 70c <read>
    if(cc < 1)
 574:	00a05e63          	blez	a0,590 <gets+0x56>
    buf[i++] = c;
 578:	faf44783          	lbu	a5,-81(s0)
 57c:	00f90023          	sb	a5,0(s2) # f4000 <base+0xf2ff0>
    if(c == '\n' || c == '\r')
 580:	01578763          	beq	a5,s5,58e <gets+0x54>
 584:	0905                	addi	s2,s2,1
 586:	fd679be3          	bne	a5,s6,55c <gets+0x22>
  for(i=0; i+1 < max; ){
 58a:	89a6                	mv	s3,s1
 58c:	a011                	j	590 <gets+0x56>
 58e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 590:	99de                	add	s3,s3,s7
 592:	00098023          	sb	zero,0(s3)
  return buf;
}
 596:	855e                	mv	a0,s7
 598:	60e6                	ld	ra,88(sp)
 59a:	6446                	ld	s0,80(sp)
 59c:	64a6                	ld	s1,72(sp)
 59e:	6906                	ld	s2,64(sp)
 5a0:	79e2                	ld	s3,56(sp)
 5a2:	7a42                	ld	s4,48(sp)
 5a4:	7aa2                	ld	s5,40(sp)
 5a6:	7b02                	ld	s6,32(sp)
 5a8:	6be2                	ld	s7,24(sp)
 5aa:	6125                	addi	sp,sp,96
 5ac:	8082                	ret

00000000000005ae <stat>:

int
stat(const char *n, struct stat *st)
{
 5ae:	1101                	addi	sp,sp,-32
 5b0:	ec06                	sd	ra,24(sp)
 5b2:	e822                	sd	s0,16(sp)
 5b4:	e426                	sd	s1,8(sp)
 5b6:	e04a                	sd	s2,0(sp)
 5b8:	1000                	addi	s0,sp,32
 5ba:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 5bc:	4581                	li	a1,0
 5be:	00000097          	auipc	ra,0x0
 5c2:	176080e7          	jalr	374(ra) # 734 <open>
  if(fd < 0)
 5c6:	02054563          	bltz	a0,5f0 <stat+0x42>
 5ca:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 5cc:	85ca                	mv	a1,s2
 5ce:	00000097          	auipc	ra,0x0
 5d2:	17e080e7          	jalr	382(ra) # 74c <fstat>
 5d6:	892a                	mv	s2,a0
  close(fd);
 5d8:	8526                	mv	a0,s1
 5da:	00000097          	auipc	ra,0x0
 5de:	142080e7          	jalr	322(ra) # 71c <close>
  return r;
}
 5e2:	854a                	mv	a0,s2
 5e4:	60e2                	ld	ra,24(sp)
 5e6:	6442                	ld	s0,16(sp)
 5e8:	64a2                	ld	s1,8(sp)
 5ea:	6902                	ld	s2,0(sp)
 5ec:	6105                	addi	sp,sp,32
 5ee:	8082                	ret
    return -1;
 5f0:	597d                	li	s2,-1
 5f2:	bfc5                	j	5e2 <stat+0x34>

00000000000005f4 <atoi>:

int
atoi(const char *s)
{
 5f4:	1141                	addi	sp,sp,-16
 5f6:	e422                	sd	s0,8(sp)
 5f8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 5fa:	00054603          	lbu	a2,0(a0)
 5fe:	fd06079b          	addiw	a5,a2,-48
 602:	0ff7f793          	andi	a5,a5,255
 606:	4725                	li	a4,9
 608:	02f76963          	bltu	a4,a5,63a <atoi+0x46>
 60c:	86aa                	mv	a3,a0
  n = 0;
 60e:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 610:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 612:	0685                	addi	a3,a3,1
 614:	0025179b          	slliw	a5,a0,0x2
 618:	9fa9                	addw	a5,a5,a0
 61a:	0017979b          	slliw	a5,a5,0x1
 61e:	9fb1                	addw	a5,a5,a2
 620:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 624:	0006c603          	lbu	a2,0(a3)
 628:	fd06071b          	addiw	a4,a2,-48
 62c:	0ff77713          	andi	a4,a4,255
 630:	fee5f1e3          	bgeu	a1,a4,612 <atoi+0x1e>
  return n;
}
 634:	6422                	ld	s0,8(sp)
 636:	0141                	addi	sp,sp,16
 638:	8082                	ret
  n = 0;
 63a:	4501                	li	a0,0
 63c:	bfe5                	j	634 <atoi+0x40>

000000000000063e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 63e:	1141                	addi	sp,sp,-16
 640:	e422                	sd	s0,8(sp)
 642:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 644:	02b57663          	bgeu	a0,a1,670 <memmove+0x32>
    while(n-- > 0)
 648:	02c05163          	blez	a2,66a <memmove+0x2c>
 64c:	fff6079b          	addiw	a5,a2,-1
 650:	1782                	slli	a5,a5,0x20
 652:	9381                	srli	a5,a5,0x20
 654:	0785                	addi	a5,a5,1
 656:	97aa                	add	a5,a5,a0
  dst = vdst;
 658:	872a                	mv	a4,a0
      *dst++ = *src++;
 65a:	0585                	addi	a1,a1,1
 65c:	0705                	addi	a4,a4,1
 65e:	fff5c683          	lbu	a3,-1(a1)
 662:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 666:	fee79ae3          	bne	a5,a4,65a <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 66a:	6422                	ld	s0,8(sp)
 66c:	0141                	addi	sp,sp,16
 66e:	8082                	ret
    dst += n;
 670:	00c50733          	add	a4,a0,a2
    src += n;
 674:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 676:	fec05ae3          	blez	a2,66a <memmove+0x2c>
 67a:	fff6079b          	addiw	a5,a2,-1
 67e:	1782                	slli	a5,a5,0x20
 680:	9381                	srli	a5,a5,0x20
 682:	fff7c793          	not	a5,a5
 686:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 688:	15fd                	addi	a1,a1,-1
 68a:	177d                	addi	a4,a4,-1
 68c:	0005c683          	lbu	a3,0(a1)
 690:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 694:	fee79ae3          	bne	a5,a4,688 <memmove+0x4a>
 698:	bfc9                	j	66a <memmove+0x2c>

000000000000069a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 69a:	1141                	addi	sp,sp,-16
 69c:	e422                	sd	s0,8(sp)
 69e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 6a0:	ca05                	beqz	a2,6d0 <memcmp+0x36>
 6a2:	fff6069b          	addiw	a3,a2,-1
 6a6:	1682                	slli	a3,a3,0x20
 6a8:	9281                	srli	a3,a3,0x20
 6aa:	0685                	addi	a3,a3,1
 6ac:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 6ae:	00054783          	lbu	a5,0(a0)
 6b2:	0005c703          	lbu	a4,0(a1)
 6b6:	00e79863          	bne	a5,a4,6c6 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 6ba:	0505                	addi	a0,a0,1
    p2++;
 6bc:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 6be:	fed518e3          	bne	a0,a3,6ae <memcmp+0x14>
  }
  return 0;
 6c2:	4501                	li	a0,0
 6c4:	a019                	j	6ca <memcmp+0x30>
      return *p1 - *p2;
 6c6:	40e7853b          	subw	a0,a5,a4
}
 6ca:	6422                	ld	s0,8(sp)
 6cc:	0141                	addi	sp,sp,16
 6ce:	8082                	ret
  return 0;
 6d0:	4501                	li	a0,0
 6d2:	bfe5                	j	6ca <memcmp+0x30>

00000000000006d4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 6d4:	1141                	addi	sp,sp,-16
 6d6:	e406                	sd	ra,8(sp)
 6d8:	e022                	sd	s0,0(sp)
 6da:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 6dc:	00000097          	auipc	ra,0x0
 6e0:	f62080e7          	jalr	-158(ra) # 63e <memmove>
}
 6e4:	60a2                	ld	ra,8(sp)
 6e6:	6402                	ld	s0,0(sp)
 6e8:	0141                	addi	sp,sp,16
 6ea:	8082                	ret

00000000000006ec <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 6ec:	4885                	li	a7,1
 ecall
 6ee:	00000073          	ecall
 ret
 6f2:	8082                	ret

00000000000006f4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 6f4:	4889                	li	a7,2
 ecall
 6f6:	00000073          	ecall
 ret
 6fa:	8082                	ret

00000000000006fc <wait>:
.global wait
wait:
 li a7, SYS_wait
 6fc:	488d                	li	a7,3
 ecall
 6fe:	00000073          	ecall
 ret
 702:	8082                	ret

0000000000000704 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 704:	4891                	li	a7,4
 ecall
 706:	00000073          	ecall
 ret
 70a:	8082                	ret

000000000000070c <read>:
.global read
read:
 li a7, SYS_read
 70c:	4895                	li	a7,5
 ecall
 70e:	00000073          	ecall
 ret
 712:	8082                	ret

0000000000000714 <write>:
.global write
write:
 li a7, SYS_write
 714:	48c1                	li	a7,16
 ecall
 716:	00000073          	ecall
 ret
 71a:	8082                	ret

000000000000071c <close>:
.global close
close:
 li a7, SYS_close
 71c:	48d5                	li	a7,21
 ecall
 71e:	00000073          	ecall
 ret
 722:	8082                	ret

0000000000000724 <kill>:
.global kill
kill:
 li a7, SYS_kill
 724:	4899                	li	a7,6
 ecall
 726:	00000073          	ecall
 ret
 72a:	8082                	ret

000000000000072c <exec>:
.global exec
exec:
 li a7, SYS_exec
 72c:	489d                	li	a7,7
 ecall
 72e:	00000073          	ecall
 ret
 732:	8082                	ret

0000000000000734 <open>:
.global open
open:
 li a7, SYS_open
 734:	48bd                	li	a7,15
 ecall
 736:	00000073          	ecall
 ret
 73a:	8082                	ret

000000000000073c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 73c:	48c5                	li	a7,17
 ecall
 73e:	00000073          	ecall
 ret
 742:	8082                	ret

0000000000000744 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 744:	48c9                	li	a7,18
 ecall
 746:	00000073          	ecall
 ret
 74a:	8082                	ret

000000000000074c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 74c:	48a1                	li	a7,8
 ecall
 74e:	00000073          	ecall
 ret
 752:	8082                	ret

0000000000000754 <link>:
.global link
link:
 li a7, SYS_link
 754:	48cd                	li	a7,19
 ecall
 756:	00000073          	ecall
 ret
 75a:	8082                	ret

000000000000075c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 75c:	48d1                	li	a7,20
 ecall
 75e:	00000073          	ecall
 ret
 762:	8082                	ret

0000000000000764 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 764:	48a5                	li	a7,9
 ecall
 766:	00000073          	ecall
 ret
 76a:	8082                	ret

000000000000076c <dup>:
.global dup
dup:
 li a7, SYS_dup
 76c:	48a9                	li	a7,10
 ecall
 76e:	00000073          	ecall
 ret
 772:	8082                	ret

0000000000000774 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 774:	48ad                	li	a7,11
 ecall
 776:	00000073          	ecall
 ret
 77a:	8082                	ret

000000000000077c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 77c:	48b1                	li	a7,12
 ecall
 77e:	00000073          	ecall
 ret
 782:	8082                	ret

0000000000000784 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 784:	48b5                	li	a7,13
 ecall
 786:	00000073          	ecall
 ret
 78a:	8082                	ret

000000000000078c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 78c:	48b9                	li	a7,14
 ecall
 78e:	00000073          	ecall
 ret
 792:	8082                	ret

0000000000000794 <trace>:
.global trace
trace:
 li a7, SYS_trace
 794:	48d9                	li	a7,22
 ecall
 796:	00000073          	ecall
 ret
 79a:	8082                	ret

000000000000079c <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 79c:	48dd                	li	a7,23
 ecall
 79e:	00000073          	ecall
 ret
 7a2:	8082                	ret

00000000000007a4 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 7a4:	48e5                	li	a7,25
 ecall
 7a6:	00000073          	ecall
 ret
 7aa:	8082                	ret

00000000000007ac <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 7ac:	48e1                	li	a7,24
 ecall
 7ae:	00000073          	ecall
 ret
 7b2:	8082                	ret

00000000000007b4 <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 7b4:	48e9                	li	a7,26
 ecall
 7b6:	00000073          	ecall
 ret
 7ba:	8082                	ret

00000000000007bc <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 7bc:	1101                	addi	sp,sp,-32
 7be:	ec06                	sd	ra,24(sp)
 7c0:	e822                	sd	s0,16(sp)
 7c2:	1000                	addi	s0,sp,32
 7c4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 7c8:	4605                	li	a2,1
 7ca:	fef40593          	addi	a1,s0,-17
 7ce:	00000097          	auipc	ra,0x0
 7d2:	f46080e7          	jalr	-186(ra) # 714 <write>
}
 7d6:	60e2                	ld	ra,24(sp)
 7d8:	6442                	ld	s0,16(sp)
 7da:	6105                	addi	sp,sp,32
 7dc:	8082                	ret

00000000000007de <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 7de:	7139                	addi	sp,sp,-64
 7e0:	fc06                	sd	ra,56(sp)
 7e2:	f822                	sd	s0,48(sp)
 7e4:	f426                	sd	s1,40(sp)
 7e6:	f04a                	sd	s2,32(sp)
 7e8:	ec4e                	sd	s3,24(sp)
 7ea:	0080                	addi	s0,sp,64
 7ec:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 7ee:	c299                	beqz	a3,7f4 <printint+0x16>
 7f0:	0805c863          	bltz	a1,880 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 7f4:	2581                	sext.w	a1,a1
  neg = 0;
 7f6:	4881                	li	a7,0
 7f8:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 7fc:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 7fe:	2601                	sext.w	a2,a2
 800:	00000517          	auipc	a0,0x0
 804:	62850513          	addi	a0,a0,1576 # e28 <digits>
 808:	883a                	mv	a6,a4
 80a:	2705                	addiw	a4,a4,1
 80c:	02c5f7bb          	remuw	a5,a1,a2
 810:	1782                	slli	a5,a5,0x20
 812:	9381                	srli	a5,a5,0x20
 814:	97aa                	add	a5,a5,a0
 816:	0007c783          	lbu	a5,0(a5)
 81a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 81e:	0005879b          	sext.w	a5,a1
 822:	02c5d5bb          	divuw	a1,a1,a2
 826:	0685                	addi	a3,a3,1
 828:	fec7f0e3          	bgeu	a5,a2,808 <printint+0x2a>
  if(neg)
 82c:	00088b63          	beqz	a7,842 <printint+0x64>
    buf[i++] = '-';
 830:	fd040793          	addi	a5,s0,-48
 834:	973e                	add	a4,a4,a5
 836:	02d00793          	li	a5,45
 83a:	fef70823          	sb	a5,-16(a4)
 83e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 842:	02e05863          	blez	a4,872 <printint+0x94>
 846:	fc040793          	addi	a5,s0,-64
 84a:	00e78933          	add	s2,a5,a4
 84e:	fff78993          	addi	s3,a5,-1
 852:	99ba                	add	s3,s3,a4
 854:	377d                	addiw	a4,a4,-1
 856:	1702                	slli	a4,a4,0x20
 858:	9301                	srli	a4,a4,0x20
 85a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 85e:	fff94583          	lbu	a1,-1(s2)
 862:	8526                	mv	a0,s1
 864:	00000097          	auipc	ra,0x0
 868:	f58080e7          	jalr	-168(ra) # 7bc <putc>
  while(--i >= 0)
 86c:	197d                	addi	s2,s2,-1
 86e:	ff3918e3          	bne	s2,s3,85e <printint+0x80>
}
 872:	70e2                	ld	ra,56(sp)
 874:	7442                	ld	s0,48(sp)
 876:	74a2                	ld	s1,40(sp)
 878:	7902                	ld	s2,32(sp)
 87a:	69e2                	ld	s3,24(sp)
 87c:	6121                	addi	sp,sp,64
 87e:	8082                	ret
    x = -xx;
 880:	40b005bb          	negw	a1,a1
    neg = 1;
 884:	4885                	li	a7,1
    x = -xx;
 886:	bf8d                	j	7f8 <printint+0x1a>

0000000000000888 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 888:	7119                	addi	sp,sp,-128
 88a:	fc86                	sd	ra,120(sp)
 88c:	f8a2                	sd	s0,112(sp)
 88e:	f4a6                	sd	s1,104(sp)
 890:	f0ca                	sd	s2,96(sp)
 892:	ecce                	sd	s3,88(sp)
 894:	e8d2                	sd	s4,80(sp)
 896:	e4d6                	sd	s5,72(sp)
 898:	e0da                	sd	s6,64(sp)
 89a:	fc5e                	sd	s7,56(sp)
 89c:	f862                	sd	s8,48(sp)
 89e:	f466                	sd	s9,40(sp)
 8a0:	f06a                	sd	s10,32(sp)
 8a2:	ec6e                	sd	s11,24(sp)
 8a4:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 8a6:	0005c903          	lbu	s2,0(a1)
 8aa:	18090f63          	beqz	s2,a48 <vprintf+0x1c0>
 8ae:	8aaa                	mv	s5,a0
 8b0:	8b32                	mv	s6,a2
 8b2:	00158493          	addi	s1,a1,1
  state = 0;
 8b6:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 8b8:	02500a13          	li	s4,37
      if(c == 'd'){
 8bc:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 8c0:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 8c4:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 8c8:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 8cc:	00000b97          	auipc	s7,0x0
 8d0:	55cb8b93          	addi	s7,s7,1372 # e28 <digits>
 8d4:	a839                	j	8f2 <vprintf+0x6a>
        putc(fd, c);
 8d6:	85ca                	mv	a1,s2
 8d8:	8556                	mv	a0,s5
 8da:	00000097          	auipc	ra,0x0
 8de:	ee2080e7          	jalr	-286(ra) # 7bc <putc>
 8e2:	a019                	j	8e8 <vprintf+0x60>
    } else if(state == '%'){
 8e4:	01498f63          	beq	s3,s4,902 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 8e8:	0485                	addi	s1,s1,1
 8ea:	fff4c903          	lbu	s2,-1(s1)
 8ee:	14090d63          	beqz	s2,a48 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 8f2:	0009079b          	sext.w	a5,s2
    if(state == 0){
 8f6:	fe0997e3          	bnez	s3,8e4 <vprintf+0x5c>
      if(c == '%'){
 8fa:	fd479ee3          	bne	a5,s4,8d6 <vprintf+0x4e>
        state = '%';
 8fe:	89be                	mv	s3,a5
 900:	b7e5                	j	8e8 <vprintf+0x60>
      if(c == 'd'){
 902:	05878063          	beq	a5,s8,942 <vprintf+0xba>
      } else if(c == 'l') {
 906:	05978c63          	beq	a5,s9,95e <vprintf+0xd6>
      } else if(c == 'x') {
 90a:	07a78863          	beq	a5,s10,97a <vprintf+0xf2>
      } else if(c == 'p') {
 90e:	09b78463          	beq	a5,s11,996 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 912:	07300713          	li	a4,115
 916:	0ce78663          	beq	a5,a4,9e2 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 91a:	06300713          	li	a4,99
 91e:	0ee78e63          	beq	a5,a4,a1a <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 922:	11478863          	beq	a5,s4,a32 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 926:	85d2                	mv	a1,s4
 928:	8556                	mv	a0,s5
 92a:	00000097          	auipc	ra,0x0
 92e:	e92080e7          	jalr	-366(ra) # 7bc <putc>
        putc(fd, c);
 932:	85ca                	mv	a1,s2
 934:	8556                	mv	a0,s5
 936:	00000097          	auipc	ra,0x0
 93a:	e86080e7          	jalr	-378(ra) # 7bc <putc>
      }
      state = 0;
 93e:	4981                	li	s3,0
 940:	b765                	j	8e8 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 942:	008b0913          	addi	s2,s6,8
 946:	4685                	li	a3,1
 948:	4629                	li	a2,10
 94a:	000b2583          	lw	a1,0(s6)
 94e:	8556                	mv	a0,s5
 950:	00000097          	auipc	ra,0x0
 954:	e8e080e7          	jalr	-370(ra) # 7de <printint>
 958:	8b4a                	mv	s6,s2
      state = 0;
 95a:	4981                	li	s3,0
 95c:	b771                	j	8e8 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 95e:	008b0913          	addi	s2,s6,8
 962:	4681                	li	a3,0
 964:	4629                	li	a2,10
 966:	000b2583          	lw	a1,0(s6)
 96a:	8556                	mv	a0,s5
 96c:	00000097          	auipc	ra,0x0
 970:	e72080e7          	jalr	-398(ra) # 7de <printint>
 974:	8b4a                	mv	s6,s2
      state = 0;
 976:	4981                	li	s3,0
 978:	bf85                	j	8e8 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 97a:	008b0913          	addi	s2,s6,8
 97e:	4681                	li	a3,0
 980:	4641                	li	a2,16
 982:	000b2583          	lw	a1,0(s6)
 986:	8556                	mv	a0,s5
 988:	00000097          	auipc	ra,0x0
 98c:	e56080e7          	jalr	-426(ra) # 7de <printint>
 990:	8b4a                	mv	s6,s2
      state = 0;
 992:	4981                	li	s3,0
 994:	bf91                	j	8e8 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 996:	008b0793          	addi	a5,s6,8
 99a:	f8f43423          	sd	a5,-120(s0)
 99e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 9a2:	03000593          	li	a1,48
 9a6:	8556                	mv	a0,s5
 9a8:	00000097          	auipc	ra,0x0
 9ac:	e14080e7          	jalr	-492(ra) # 7bc <putc>
  putc(fd, 'x');
 9b0:	85ea                	mv	a1,s10
 9b2:	8556                	mv	a0,s5
 9b4:	00000097          	auipc	ra,0x0
 9b8:	e08080e7          	jalr	-504(ra) # 7bc <putc>
 9bc:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 9be:	03c9d793          	srli	a5,s3,0x3c
 9c2:	97de                	add	a5,a5,s7
 9c4:	0007c583          	lbu	a1,0(a5)
 9c8:	8556                	mv	a0,s5
 9ca:	00000097          	auipc	ra,0x0
 9ce:	df2080e7          	jalr	-526(ra) # 7bc <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 9d2:	0992                	slli	s3,s3,0x4
 9d4:	397d                	addiw	s2,s2,-1
 9d6:	fe0914e3          	bnez	s2,9be <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 9da:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 9de:	4981                	li	s3,0
 9e0:	b721                	j	8e8 <vprintf+0x60>
        s = va_arg(ap, char*);
 9e2:	008b0993          	addi	s3,s6,8
 9e6:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 9ea:	02090163          	beqz	s2,a0c <vprintf+0x184>
        while(*s != 0){
 9ee:	00094583          	lbu	a1,0(s2)
 9f2:	c9a1                	beqz	a1,a42 <vprintf+0x1ba>
          putc(fd, *s);
 9f4:	8556                	mv	a0,s5
 9f6:	00000097          	auipc	ra,0x0
 9fa:	dc6080e7          	jalr	-570(ra) # 7bc <putc>
          s++;
 9fe:	0905                	addi	s2,s2,1
        while(*s != 0){
 a00:	00094583          	lbu	a1,0(s2)
 a04:	f9e5                	bnez	a1,9f4 <vprintf+0x16c>
        s = va_arg(ap, char*);
 a06:	8b4e                	mv	s6,s3
      state = 0;
 a08:	4981                	li	s3,0
 a0a:	bdf9                	j	8e8 <vprintf+0x60>
          s = "(null)";
 a0c:	00000917          	auipc	s2,0x0
 a10:	41490913          	addi	s2,s2,1044 # e20 <malloc+0x2ce>
        while(*s != 0){
 a14:	02800593          	li	a1,40
 a18:	bff1                	j	9f4 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 a1a:	008b0913          	addi	s2,s6,8
 a1e:	000b4583          	lbu	a1,0(s6)
 a22:	8556                	mv	a0,s5
 a24:	00000097          	auipc	ra,0x0
 a28:	d98080e7          	jalr	-616(ra) # 7bc <putc>
 a2c:	8b4a                	mv	s6,s2
      state = 0;
 a2e:	4981                	li	s3,0
 a30:	bd65                	j	8e8 <vprintf+0x60>
        putc(fd, c);
 a32:	85d2                	mv	a1,s4
 a34:	8556                	mv	a0,s5
 a36:	00000097          	auipc	ra,0x0
 a3a:	d86080e7          	jalr	-634(ra) # 7bc <putc>
      state = 0;
 a3e:	4981                	li	s3,0
 a40:	b565                	j	8e8 <vprintf+0x60>
        s = va_arg(ap, char*);
 a42:	8b4e                	mv	s6,s3
      state = 0;
 a44:	4981                	li	s3,0
 a46:	b54d                	j	8e8 <vprintf+0x60>
    }
  }
}
 a48:	70e6                	ld	ra,120(sp)
 a4a:	7446                	ld	s0,112(sp)
 a4c:	74a6                	ld	s1,104(sp)
 a4e:	7906                	ld	s2,96(sp)
 a50:	69e6                	ld	s3,88(sp)
 a52:	6a46                	ld	s4,80(sp)
 a54:	6aa6                	ld	s5,72(sp)
 a56:	6b06                	ld	s6,64(sp)
 a58:	7be2                	ld	s7,56(sp)
 a5a:	7c42                	ld	s8,48(sp)
 a5c:	7ca2                	ld	s9,40(sp)
 a5e:	7d02                	ld	s10,32(sp)
 a60:	6de2                	ld	s11,24(sp)
 a62:	6109                	addi	sp,sp,128
 a64:	8082                	ret

0000000000000a66 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 a66:	715d                	addi	sp,sp,-80
 a68:	ec06                	sd	ra,24(sp)
 a6a:	e822                	sd	s0,16(sp)
 a6c:	1000                	addi	s0,sp,32
 a6e:	e010                	sd	a2,0(s0)
 a70:	e414                	sd	a3,8(s0)
 a72:	e818                	sd	a4,16(s0)
 a74:	ec1c                	sd	a5,24(s0)
 a76:	03043023          	sd	a6,32(s0)
 a7a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 a7e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 a82:	8622                	mv	a2,s0
 a84:	00000097          	auipc	ra,0x0
 a88:	e04080e7          	jalr	-508(ra) # 888 <vprintf>
}
 a8c:	60e2                	ld	ra,24(sp)
 a8e:	6442                	ld	s0,16(sp)
 a90:	6161                	addi	sp,sp,80
 a92:	8082                	ret

0000000000000a94 <printf>:

void
printf(const char *fmt, ...)
{
 a94:	711d                	addi	sp,sp,-96
 a96:	ec06                	sd	ra,24(sp)
 a98:	e822                	sd	s0,16(sp)
 a9a:	1000                	addi	s0,sp,32
 a9c:	e40c                	sd	a1,8(s0)
 a9e:	e810                	sd	a2,16(s0)
 aa0:	ec14                	sd	a3,24(s0)
 aa2:	f018                	sd	a4,32(s0)
 aa4:	f41c                	sd	a5,40(s0)
 aa6:	03043823          	sd	a6,48(s0)
 aaa:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 aae:	00840613          	addi	a2,s0,8
 ab2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 ab6:	85aa                	mv	a1,a0
 ab8:	4505                	li	a0,1
 aba:	00000097          	auipc	ra,0x0
 abe:	dce080e7          	jalr	-562(ra) # 888 <vprintf>
}
 ac2:	60e2                	ld	ra,24(sp)
 ac4:	6442                	ld	s0,16(sp)
 ac6:	6125                	addi	sp,sp,96
 ac8:	8082                	ret

0000000000000aca <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 aca:	1141                	addi	sp,sp,-16
 acc:	e422                	sd	s0,8(sp)
 ace:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 ad0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ad4:	00000797          	auipc	a5,0x0
 ad8:	5347b783          	ld	a5,1332(a5) # 1008 <freep>
 adc:	a805                	j	b0c <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 ade:	4618                	lw	a4,8(a2)
 ae0:	9db9                	addw	a1,a1,a4
 ae2:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 ae6:	6398                	ld	a4,0(a5)
 ae8:	6318                	ld	a4,0(a4)
 aea:	fee53823          	sd	a4,-16(a0)
 aee:	a091                	j	b32 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 af0:	ff852703          	lw	a4,-8(a0)
 af4:	9e39                	addw	a2,a2,a4
 af6:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 af8:	ff053703          	ld	a4,-16(a0)
 afc:	e398                	sd	a4,0(a5)
 afe:	a099                	j	b44 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b00:	6398                	ld	a4,0(a5)
 b02:	00e7e463          	bltu	a5,a4,b0a <free+0x40>
 b06:	00e6ea63          	bltu	a3,a4,b1a <free+0x50>
{
 b0a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b0c:	fed7fae3          	bgeu	a5,a3,b00 <free+0x36>
 b10:	6398                	ld	a4,0(a5)
 b12:	00e6e463          	bltu	a3,a4,b1a <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b16:	fee7eae3          	bltu	a5,a4,b0a <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 b1a:	ff852583          	lw	a1,-8(a0)
 b1e:	6390                	ld	a2,0(a5)
 b20:	02059713          	slli	a4,a1,0x20
 b24:	9301                	srli	a4,a4,0x20
 b26:	0712                	slli	a4,a4,0x4
 b28:	9736                	add	a4,a4,a3
 b2a:	fae60ae3          	beq	a2,a4,ade <free+0x14>
    bp->s.ptr = p->s.ptr;
 b2e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 b32:	4790                	lw	a2,8(a5)
 b34:	02061713          	slli	a4,a2,0x20
 b38:	9301                	srli	a4,a4,0x20
 b3a:	0712                	slli	a4,a4,0x4
 b3c:	973e                	add	a4,a4,a5
 b3e:	fae689e3          	beq	a3,a4,af0 <free+0x26>
  } else
    p->s.ptr = bp;
 b42:	e394                	sd	a3,0(a5)
  freep = p;
 b44:	00000717          	auipc	a4,0x0
 b48:	4cf73223          	sd	a5,1220(a4) # 1008 <freep>
}
 b4c:	6422                	ld	s0,8(sp)
 b4e:	0141                	addi	sp,sp,16
 b50:	8082                	ret

0000000000000b52 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 b52:	7139                	addi	sp,sp,-64
 b54:	fc06                	sd	ra,56(sp)
 b56:	f822                	sd	s0,48(sp)
 b58:	f426                	sd	s1,40(sp)
 b5a:	f04a                	sd	s2,32(sp)
 b5c:	ec4e                	sd	s3,24(sp)
 b5e:	e852                	sd	s4,16(sp)
 b60:	e456                	sd	s5,8(sp)
 b62:	e05a                	sd	s6,0(sp)
 b64:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 b66:	02051493          	slli	s1,a0,0x20
 b6a:	9081                	srli	s1,s1,0x20
 b6c:	04bd                	addi	s1,s1,15
 b6e:	8091                	srli	s1,s1,0x4
 b70:	0014899b          	addiw	s3,s1,1
 b74:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 b76:	00000517          	auipc	a0,0x0
 b7a:	49253503          	ld	a0,1170(a0) # 1008 <freep>
 b7e:	c515                	beqz	a0,baa <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b80:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b82:	4798                	lw	a4,8(a5)
 b84:	02977f63          	bgeu	a4,s1,bc2 <malloc+0x70>
 b88:	8a4e                	mv	s4,s3
 b8a:	0009871b          	sext.w	a4,s3
 b8e:	6685                	lui	a3,0x1
 b90:	00d77363          	bgeu	a4,a3,b96 <malloc+0x44>
 b94:	6a05                	lui	s4,0x1
 b96:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 b9a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 b9e:	00000917          	auipc	s2,0x0
 ba2:	46a90913          	addi	s2,s2,1130 # 1008 <freep>
  if(p == (char*)-1)
 ba6:	5afd                	li	s5,-1
 ba8:	a88d                	j	c1a <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 baa:	00000797          	auipc	a5,0x0
 bae:	46678793          	addi	a5,a5,1126 # 1010 <base>
 bb2:	00000717          	auipc	a4,0x0
 bb6:	44f73b23          	sd	a5,1110(a4) # 1008 <freep>
 bba:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 bbc:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 bc0:	b7e1                	j	b88 <malloc+0x36>
      if(p->s.size == nunits)
 bc2:	02e48b63          	beq	s1,a4,bf8 <malloc+0xa6>
        p->s.size -= nunits;
 bc6:	4137073b          	subw	a4,a4,s3
 bca:	c798                	sw	a4,8(a5)
        p += p->s.size;
 bcc:	1702                	slli	a4,a4,0x20
 bce:	9301                	srli	a4,a4,0x20
 bd0:	0712                	slli	a4,a4,0x4
 bd2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 bd4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 bd8:	00000717          	auipc	a4,0x0
 bdc:	42a73823          	sd	a0,1072(a4) # 1008 <freep>
      return (void*)(p + 1);
 be0:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 be4:	70e2                	ld	ra,56(sp)
 be6:	7442                	ld	s0,48(sp)
 be8:	74a2                	ld	s1,40(sp)
 bea:	7902                	ld	s2,32(sp)
 bec:	69e2                	ld	s3,24(sp)
 bee:	6a42                	ld	s4,16(sp)
 bf0:	6aa2                	ld	s5,8(sp)
 bf2:	6b02                	ld	s6,0(sp)
 bf4:	6121                	addi	sp,sp,64
 bf6:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 bf8:	6398                	ld	a4,0(a5)
 bfa:	e118                	sd	a4,0(a0)
 bfc:	bff1                	j	bd8 <malloc+0x86>
  hp->s.size = nu;
 bfe:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 c02:	0541                	addi	a0,a0,16
 c04:	00000097          	auipc	ra,0x0
 c08:	ec6080e7          	jalr	-314(ra) # aca <free>
  return freep;
 c0c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 c10:	d971                	beqz	a0,be4 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c12:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c14:	4798                	lw	a4,8(a5)
 c16:	fa9776e3          	bgeu	a4,s1,bc2 <malloc+0x70>
    if(p == freep)
 c1a:	00093703          	ld	a4,0(s2)
 c1e:	853e                	mv	a0,a5
 c20:	fef719e3          	bne	a4,a5,c12 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 c24:	8552                	mv	a0,s4
 c26:	00000097          	auipc	ra,0x0
 c2a:	b56080e7          	jalr	-1194(ra) # 77c <sbrk>
  if(p == (char*)-1)
 c2e:	fd5518e3          	bne	a0,s5,bfe <malloc+0xac>
        return 0;
 c32:	4501                	li	a0,0
 c34:	bf45                	j	be4 <malloc+0x92>

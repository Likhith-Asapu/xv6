
user/_time:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user/user.h"
#include "kernel/fcntl.h"

int 
main(int argc, char ** argv) 
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	1800                	addi	s0,sp,48
   c:	892a                	mv	s2,a0
   e:	84ae                	mv	s1,a1
  int pid = fork();
  10:	00000097          	auipc	ra,0x0
  14:	326080e7          	jalr	806(ra) # 336 <fork>
  if(pid < 0) {
  18:	02054a63          	bltz	a0,4c <main+0x4c>
    printf("fork(): failed\n");
    exit(1);
  } else if(pid == 0) {
  1c:	ed39                	bnez	a0,7a <main+0x7a>
    if(argc == 1) {
  1e:	4785                	li	a5,1
  20:	04f90363          	beq	s2,a5,66 <main+0x66>
      sleep(10);
      exit(0);
    } else {
      exec(argv[1], argv + 1);
  24:	00848593          	addi	a1,s1,8
  28:	6488                	ld	a0,8(s1)
  2a:	00000097          	auipc	ra,0x0
  2e:	34c080e7          	jalr	844(ra) # 376 <exec>
      printf("exec(): failed\n");
  32:	00001517          	auipc	a0,0x1
  36:	86e50513          	addi	a0,a0,-1938 # 8a0 <malloc+0xfc>
  3a:	00000097          	auipc	ra,0x0
  3e:	6ac080e7          	jalr	1708(ra) # 6e6 <printf>
      exit(1);
  42:	4505                	li	a0,1
  44:	00000097          	auipc	ra,0x0
  48:	2fa080e7          	jalr	762(ra) # 33e <exit>
    printf("fork(): failed\n");
  4c:	00001517          	auipc	a0,0x1
  50:	84450513          	addi	a0,a0,-1980 # 890 <malloc+0xec>
  54:	00000097          	auipc	ra,0x0
  58:	692080e7          	jalr	1682(ra) # 6e6 <printf>
    exit(1);
  5c:	4505                	li	a0,1
  5e:	00000097          	auipc	ra,0x0
  62:	2e0080e7          	jalr	736(ra) # 33e <exit>
      sleep(10);
  66:	4529                	li	a0,10
  68:	00000097          	auipc	ra,0x0
  6c:	366080e7          	jalr	870(ra) # 3ce <sleep>
      exit(0);
  70:	4501                	li	a0,0
  72:	00000097          	auipc	ra,0x0
  76:	2cc080e7          	jalr	716(ra) # 33e <exit>
    }  
  } else {
    int rtime, wtime;
    waitx(0, &wtime, &rtime);
  7a:	fd840613          	addi	a2,s0,-40
  7e:	fdc40593          	addi	a1,s0,-36
  82:	4501                	li	a0,0
  84:	00000097          	auipc	ra,0x0
  88:	362080e7          	jalr	866(ra) # 3e6 <waitx>
    // similkar to wait
    printf("\nwaiting:%d\nrunning:%d\n", wtime, rtime);
  8c:	fd842603          	lw	a2,-40(s0)
  90:	fdc42583          	lw	a1,-36(s0)
  94:	00001517          	auipc	a0,0x1
  98:	81c50513          	addi	a0,a0,-2020 # 8b0 <malloc+0x10c>
  9c:	00000097          	auipc	ra,0x0
  a0:	64a080e7          	jalr	1610(ra) # 6e6 <printf>
  }
  exit(0);
  a4:	4501                	li	a0,0
  a6:	00000097          	auipc	ra,0x0
  aa:	298080e7          	jalr	664(ra) # 33e <exit>

00000000000000ae <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  ae:	1141                	addi	sp,sp,-16
  b0:	e406                	sd	ra,8(sp)
  b2:	e022                	sd	s0,0(sp)
  b4:	0800                	addi	s0,sp,16
  extern int main();
  main();
  b6:	00000097          	auipc	ra,0x0
  ba:	f4a080e7          	jalr	-182(ra) # 0 <main>
  exit(0);
  be:	4501                	li	a0,0
  c0:	00000097          	auipc	ra,0x0
  c4:	27e080e7          	jalr	638(ra) # 33e <exit>

00000000000000c8 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  c8:	1141                	addi	sp,sp,-16
  ca:	e422                	sd	s0,8(sp)
  cc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  ce:	87aa                	mv	a5,a0
  d0:	0585                	addi	a1,a1,1
  d2:	0785                	addi	a5,a5,1
  d4:	fff5c703          	lbu	a4,-1(a1)
  d8:	fee78fa3          	sb	a4,-1(a5)
  dc:	fb75                	bnez	a4,d0 <strcpy+0x8>
    ;
  return os;
}
  de:	6422                	ld	s0,8(sp)
  e0:	0141                	addi	sp,sp,16
  e2:	8082                	ret

00000000000000e4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  e4:	1141                	addi	sp,sp,-16
  e6:	e422                	sd	s0,8(sp)
  e8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  ea:	00054783          	lbu	a5,0(a0)
  ee:	cb91                	beqz	a5,102 <strcmp+0x1e>
  f0:	0005c703          	lbu	a4,0(a1)
  f4:	00f71763          	bne	a4,a5,102 <strcmp+0x1e>
    p++, q++;
  f8:	0505                	addi	a0,a0,1
  fa:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  fc:	00054783          	lbu	a5,0(a0)
 100:	fbe5                	bnez	a5,f0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 102:	0005c503          	lbu	a0,0(a1)
}
 106:	40a7853b          	subw	a0,a5,a0
 10a:	6422                	ld	s0,8(sp)
 10c:	0141                	addi	sp,sp,16
 10e:	8082                	ret

0000000000000110 <strlen>:

uint
strlen(const char *s)
{
 110:	1141                	addi	sp,sp,-16
 112:	e422                	sd	s0,8(sp)
 114:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 116:	00054783          	lbu	a5,0(a0)
 11a:	cf91                	beqz	a5,136 <strlen+0x26>
 11c:	0505                	addi	a0,a0,1
 11e:	87aa                	mv	a5,a0
 120:	4685                	li	a3,1
 122:	9e89                	subw	a3,a3,a0
 124:	00f6853b          	addw	a0,a3,a5
 128:	0785                	addi	a5,a5,1
 12a:	fff7c703          	lbu	a4,-1(a5)
 12e:	fb7d                	bnez	a4,124 <strlen+0x14>
    ;
  return n;
}
 130:	6422                	ld	s0,8(sp)
 132:	0141                	addi	sp,sp,16
 134:	8082                	ret
  for(n = 0; s[n]; n++)
 136:	4501                	li	a0,0
 138:	bfe5                	j	130 <strlen+0x20>

000000000000013a <memset>:

void*
memset(void *dst, int c, uint n)
{
 13a:	1141                	addi	sp,sp,-16
 13c:	e422                	sd	s0,8(sp)
 13e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 140:	ce09                	beqz	a2,15a <memset+0x20>
 142:	87aa                	mv	a5,a0
 144:	fff6071b          	addiw	a4,a2,-1
 148:	1702                	slli	a4,a4,0x20
 14a:	9301                	srli	a4,a4,0x20
 14c:	0705                	addi	a4,a4,1
 14e:	972a                	add	a4,a4,a0
    cdst[i] = c;
 150:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 154:	0785                	addi	a5,a5,1
 156:	fee79de3          	bne	a5,a4,150 <memset+0x16>
  }
  return dst;
}
 15a:	6422                	ld	s0,8(sp)
 15c:	0141                	addi	sp,sp,16
 15e:	8082                	ret

0000000000000160 <strchr>:

char*
strchr(const char *s, char c)
{
 160:	1141                	addi	sp,sp,-16
 162:	e422                	sd	s0,8(sp)
 164:	0800                	addi	s0,sp,16
  for(; *s; s++)
 166:	00054783          	lbu	a5,0(a0)
 16a:	cb99                	beqz	a5,180 <strchr+0x20>
    if(*s == c)
 16c:	00f58763          	beq	a1,a5,17a <strchr+0x1a>
  for(; *s; s++)
 170:	0505                	addi	a0,a0,1
 172:	00054783          	lbu	a5,0(a0)
 176:	fbfd                	bnez	a5,16c <strchr+0xc>
      return (char*)s;
  return 0;
 178:	4501                	li	a0,0
}
 17a:	6422                	ld	s0,8(sp)
 17c:	0141                	addi	sp,sp,16
 17e:	8082                	ret
  return 0;
 180:	4501                	li	a0,0
 182:	bfe5                	j	17a <strchr+0x1a>

0000000000000184 <gets>:

char*
gets(char *buf, int max)
{
 184:	711d                	addi	sp,sp,-96
 186:	ec86                	sd	ra,88(sp)
 188:	e8a2                	sd	s0,80(sp)
 18a:	e4a6                	sd	s1,72(sp)
 18c:	e0ca                	sd	s2,64(sp)
 18e:	fc4e                	sd	s3,56(sp)
 190:	f852                	sd	s4,48(sp)
 192:	f456                	sd	s5,40(sp)
 194:	f05a                	sd	s6,32(sp)
 196:	ec5e                	sd	s7,24(sp)
 198:	1080                	addi	s0,sp,96
 19a:	8baa                	mv	s7,a0
 19c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 19e:	892a                	mv	s2,a0
 1a0:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1a2:	4aa9                	li	s5,10
 1a4:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1a6:	89a6                	mv	s3,s1
 1a8:	2485                	addiw	s1,s1,1
 1aa:	0344d863          	bge	s1,s4,1da <gets+0x56>
    cc = read(0, &c, 1);
 1ae:	4605                	li	a2,1
 1b0:	faf40593          	addi	a1,s0,-81
 1b4:	4501                	li	a0,0
 1b6:	00000097          	auipc	ra,0x0
 1ba:	1a0080e7          	jalr	416(ra) # 356 <read>
    if(cc < 1)
 1be:	00a05e63          	blez	a0,1da <gets+0x56>
    buf[i++] = c;
 1c2:	faf44783          	lbu	a5,-81(s0)
 1c6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1ca:	01578763          	beq	a5,s5,1d8 <gets+0x54>
 1ce:	0905                	addi	s2,s2,1
 1d0:	fd679be3          	bne	a5,s6,1a6 <gets+0x22>
  for(i=0; i+1 < max; ){
 1d4:	89a6                	mv	s3,s1
 1d6:	a011                	j	1da <gets+0x56>
 1d8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1da:	99de                	add	s3,s3,s7
 1dc:	00098023          	sb	zero,0(s3)
  return buf;
}
 1e0:	855e                	mv	a0,s7
 1e2:	60e6                	ld	ra,88(sp)
 1e4:	6446                	ld	s0,80(sp)
 1e6:	64a6                	ld	s1,72(sp)
 1e8:	6906                	ld	s2,64(sp)
 1ea:	79e2                	ld	s3,56(sp)
 1ec:	7a42                	ld	s4,48(sp)
 1ee:	7aa2                	ld	s5,40(sp)
 1f0:	7b02                	ld	s6,32(sp)
 1f2:	6be2                	ld	s7,24(sp)
 1f4:	6125                	addi	sp,sp,96
 1f6:	8082                	ret

00000000000001f8 <stat>:

int
stat(const char *n, struct stat *st)
{
 1f8:	1101                	addi	sp,sp,-32
 1fa:	ec06                	sd	ra,24(sp)
 1fc:	e822                	sd	s0,16(sp)
 1fe:	e426                	sd	s1,8(sp)
 200:	e04a                	sd	s2,0(sp)
 202:	1000                	addi	s0,sp,32
 204:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 206:	4581                	li	a1,0
 208:	00000097          	auipc	ra,0x0
 20c:	176080e7          	jalr	374(ra) # 37e <open>
  if(fd < 0)
 210:	02054563          	bltz	a0,23a <stat+0x42>
 214:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 216:	85ca                	mv	a1,s2
 218:	00000097          	auipc	ra,0x0
 21c:	17e080e7          	jalr	382(ra) # 396 <fstat>
 220:	892a                	mv	s2,a0
  close(fd);
 222:	8526                	mv	a0,s1
 224:	00000097          	auipc	ra,0x0
 228:	142080e7          	jalr	322(ra) # 366 <close>
  return r;
}
 22c:	854a                	mv	a0,s2
 22e:	60e2                	ld	ra,24(sp)
 230:	6442                	ld	s0,16(sp)
 232:	64a2                	ld	s1,8(sp)
 234:	6902                	ld	s2,0(sp)
 236:	6105                	addi	sp,sp,32
 238:	8082                	ret
    return -1;
 23a:	597d                	li	s2,-1
 23c:	bfc5                	j	22c <stat+0x34>

000000000000023e <atoi>:

int
atoi(const char *s)
{
 23e:	1141                	addi	sp,sp,-16
 240:	e422                	sd	s0,8(sp)
 242:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 244:	00054603          	lbu	a2,0(a0)
 248:	fd06079b          	addiw	a5,a2,-48
 24c:	0ff7f793          	andi	a5,a5,255
 250:	4725                	li	a4,9
 252:	02f76963          	bltu	a4,a5,284 <atoi+0x46>
 256:	86aa                	mv	a3,a0
  n = 0;
 258:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 25a:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 25c:	0685                	addi	a3,a3,1
 25e:	0025179b          	slliw	a5,a0,0x2
 262:	9fa9                	addw	a5,a5,a0
 264:	0017979b          	slliw	a5,a5,0x1
 268:	9fb1                	addw	a5,a5,a2
 26a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 26e:	0006c603          	lbu	a2,0(a3)
 272:	fd06071b          	addiw	a4,a2,-48
 276:	0ff77713          	andi	a4,a4,255
 27a:	fee5f1e3          	bgeu	a1,a4,25c <atoi+0x1e>
  return n;
}
 27e:	6422                	ld	s0,8(sp)
 280:	0141                	addi	sp,sp,16
 282:	8082                	ret
  n = 0;
 284:	4501                	li	a0,0
 286:	bfe5                	j	27e <atoi+0x40>

0000000000000288 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 288:	1141                	addi	sp,sp,-16
 28a:	e422                	sd	s0,8(sp)
 28c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 28e:	02b57663          	bgeu	a0,a1,2ba <memmove+0x32>
    while(n-- > 0)
 292:	02c05163          	blez	a2,2b4 <memmove+0x2c>
 296:	fff6079b          	addiw	a5,a2,-1
 29a:	1782                	slli	a5,a5,0x20
 29c:	9381                	srli	a5,a5,0x20
 29e:	0785                	addi	a5,a5,1
 2a0:	97aa                	add	a5,a5,a0
  dst = vdst;
 2a2:	872a                	mv	a4,a0
      *dst++ = *src++;
 2a4:	0585                	addi	a1,a1,1
 2a6:	0705                	addi	a4,a4,1
 2a8:	fff5c683          	lbu	a3,-1(a1)
 2ac:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2b0:	fee79ae3          	bne	a5,a4,2a4 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2b4:	6422                	ld	s0,8(sp)
 2b6:	0141                	addi	sp,sp,16
 2b8:	8082                	ret
    dst += n;
 2ba:	00c50733          	add	a4,a0,a2
    src += n;
 2be:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2c0:	fec05ae3          	blez	a2,2b4 <memmove+0x2c>
 2c4:	fff6079b          	addiw	a5,a2,-1
 2c8:	1782                	slli	a5,a5,0x20
 2ca:	9381                	srli	a5,a5,0x20
 2cc:	fff7c793          	not	a5,a5
 2d0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2d2:	15fd                	addi	a1,a1,-1
 2d4:	177d                	addi	a4,a4,-1
 2d6:	0005c683          	lbu	a3,0(a1)
 2da:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2de:	fee79ae3          	bne	a5,a4,2d2 <memmove+0x4a>
 2e2:	bfc9                	j	2b4 <memmove+0x2c>

00000000000002e4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2e4:	1141                	addi	sp,sp,-16
 2e6:	e422                	sd	s0,8(sp)
 2e8:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2ea:	ca05                	beqz	a2,31a <memcmp+0x36>
 2ec:	fff6069b          	addiw	a3,a2,-1
 2f0:	1682                	slli	a3,a3,0x20
 2f2:	9281                	srli	a3,a3,0x20
 2f4:	0685                	addi	a3,a3,1
 2f6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2f8:	00054783          	lbu	a5,0(a0)
 2fc:	0005c703          	lbu	a4,0(a1)
 300:	00e79863          	bne	a5,a4,310 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 304:	0505                	addi	a0,a0,1
    p2++;
 306:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 308:	fed518e3          	bne	a0,a3,2f8 <memcmp+0x14>
  }
  return 0;
 30c:	4501                	li	a0,0
 30e:	a019                	j	314 <memcmp+0x30>
      return *p1 - *p2;
 310:	40e7853b          	subw	a0,a5,a4
}
 314:	6422                	ld	s0,8(sp)
 316:	0141                	addi	sp,sp,16
 318:	8082                	ret
  return 0;
 31a:	4501                	li	a0,0
 31c:	bfe5                	j	314 <memcmp+0x30>

000000000000031e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 31e:	1141                	addi	sp,sp,-16
 320:	e406                	sd	ra,8(sp)
 322:	e022                	sd	s0,0(sp)
 324:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 326:	00000097          	auipc	ra,0x0
 32a:	f62080e7          	jalr	-158(ra) # 288 <memmove>
}
 32e:	60a2                	ld	ra,8(sp)
 330:	6402                	ld	s0,0(sp)
 332:	0141                	addi	sp,sp,16
 334:	8082                	ret

0000000000000336 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 336:	4885                	li	a7,1
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <exit>:
.global exit
exit:
 li a7, SYS_exit
 33e:	4889                	li	a7,2
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <wait>:
.global wait
wait:
 li a7, SYS_wait
 346:	488d                	li	a7,3
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 34e:	4891                	li	a7,4
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <read>:
.global read
read:
 li a7, SYS_read
 356:	4895                	li	a7,5
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <write>:
.global write
write:
 li a7, SYS_write
 35e:	48c1                	li	a7,16
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <close>:
.global close
close:
 li a7, SYS_close
 366:	48d5                	li	a7,21
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <kill>:
.global kill
kill:
 li a7, SYS_kill
 36e:	4899                	li	a7,6
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <exec>:
.global exec
exec:
 li a7, SYS_exec
 376:	489d                	li	a7,7
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <open>:
.global open
open:
 li a7, SYS_open
 37e:	48bd                	li	a7,15
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 386:	48c5                	li	a7,17
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 38e:	48c9                	li	a7,18
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 396:	48a1                	li	a7,8
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <link>:
.global link
link:
 li a7, SYS_link
 39e:	48cd                	li	a7,19
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3a6:	48d1                	li	a7,20
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3ae:	48a5                	li	a7,9
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3b6:	48a9                	li	a7,10
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3be:	48ad                	li	a7,11
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3c6:	48b1                	li	a7,12
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3ce:	48b5                	li	a7,13
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3d6:	48b9                	li	a7,14
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <trace>:
.global trace
trace:
 li a7, SYS_trace
 3de:	48d9                	li	a7,22
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 3e6:	48dd                	li	a7,23
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 3ee:	48e5                	li	a7,25
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 3f6:	48e1                	li	a7,24
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 3fe:	48e9                	li	a7,26
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 406:	48ed                	li	a7,27
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 40e:	1101                	addi	sp,sp,-32
 410:	ec06                	sd	ra,24(sp)
 412:	e822                	sd	s0,16(sp)
 414:	1000                	addi	s0,sp,32
 416:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 41a:	4605                	li	a2,1
 41c:	fef40593          	addi	a1,s0,-17
 420:	00000097          	auipc	ra,0x0
 424:	f3e080e7          	jalr	-194(ra) # 35e <write>
}
 428:	60e2                	ld	ra,24(sp)
 42a:	6442                	ld	s0,16(sp)
 42c:	6105                	addi	sp,sp,32
 42e:	8082                	ret

0000000000000430 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 430:	7139                	addi	sp,sp,-64
 432:	fc06                	sd	ra,56(sp)
 434:	f822                	sd	s0,48(sp)
 436:	f426                	sd	s1,40(sp)
 438:	f04a                	sd	s2,32(sp)
 43a:	ec4e                	sd	s3,24(sp)
 43c:	0080                	addi	s0,sp,64
 43e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 440:	c299                	beqz	a3,446 <printint+0x16>
 442:	0805c863          	bltz	a1,4d2 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 446:	2581                	sext.w	a1,a1
  neg = 0;
 448:	4881                	li	a7,0
 44a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 44e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 450:	2601                	sext.w	a2,a2
 452:	00000517          	auipc	a0,0x0
 456:	47e50513          	addi	a0,a0,1150 # 8d0 <digits>
 45a:	883a                	mv	a6,a4
 45c:	2705                	addiw	a4,a4,1
 45e:	02c5f7bb          	remuw	a5,a1,a2
 462:	1782                	slli	a5,a5,0x20
 464:	9381                	srli	a5,a5,0x20
 466:	97aa                	add	a5,a5,a0
 468:	0007c783          	lbu	a5,0(a5)
 46c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 470:	0005879b          	sext.w	a5,a1
 474:	02c5d5bb          	divuw	a1,a1,a2
 478:	0685                	addi	a3,a3,1
 47a:	fec7f0e3          	bgeu	a5,a2,45a <printint+0x2a>
  if(neg)
 47e:	00088b63          	beqz	a7,494 <printint+0x64>
    buf[i++] = '-';
 482:	fd040793          	addi	a5,s0,-48
 486:	973e                	add	a4,a4,a5
 488:	02d00793          	li	a5,45
 48c:	fef70823          	sb	a5,-16(a4)
 490:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 494:	02e05863          	blez	a4,4c4 <printint+0x94>
 498:	fc040793          	addi	a5,s0,-64
 49c:	00e78933          	add	s2,a5,a4
 4a0:	fff78993          	addi	s3,a5,-1
 4a4:	99ba                	add	s3,s3,a4
 4a6:	377d                	addiw	a4,a4,-1
 4a8:	1702                	slli	a4,a4,0x20
 4aa:	9301                	srli	a4,a4,0x20
 4ac:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4b0:	fff94583          	lbu	a1,-1(s2)
 4b4:	8526                	mv	a0,s1
 4b6:	00000097          	auipc	ra,0x0
 4ba:	f58080e7          	jalr	-168(ra) # 40e <putc>
  while(--i >= 0)
 4be:	197d                	addi	s2,s2,-1
 4c0:	ff3918e3          	bne	s2,s3,4b0 <printint+0x80>
}
 4c4:	70e2                	ld	ra,56(sp)
 4c6:	7442                	ld	s0,48(sp)
 4c8:	74a2                	ld	s1,40(sp)
 4ca:	7902                	ld	s2,32(sp)
 4cc:	69e2                	ld	s3,24(sp)
 4ce:	6121                	addi	sp,sp,64
 4d0:	8082                	ret
    x = -xx;
 4d2:	40b005bb          	negw	a1,a1
    neg = 1;
 4d6:	4885                	li	a7,1
    x = -xx;
 4d8:	bf8d                	j	44a <printint+0x1a>

00000000000004da <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4da:	7119                	addi	sp,sp,-128
 4dc:	fc86                	sd	ra,120(sp)
 4de:	f8a2                	sd	s0,112(sp)
 4e0:	f4a6                	sd	s1,104(sp)
 4e2:	f0ca                	sd	s2,96(sp)
 4e4:	ecce                	sd	s3,88(sp)
 4e6:	e8d2                	sd	s4,80(sp)
 4e8:	e4d6                	sd	s5,72(sp)
 4ea:	e0da                	sd	s6,64(sp)
 4ec:	fc5e                	sd	s7,56(sp)
 4ee:	f862                	sd	s8,48(sp)
 4f0:	f466                	sd	s9,40(sp)
 4f2:	f06a                	sd	s10,32(sp)
 4f4:	ec6e                	sd	s11,24(sp)
 4f6:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4f8:	0005c903          	lbu	s2,0(a1)
 4fc:	18090f63          	beqz	s2,69a <vprintf+0x1c0>
 500:	8aaa                	mv	s5,a0
 502:	8b32                	mv	s6,a2
 504:	00158493          	addi	s1,a1,1
  state = 0;
 508:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 50a:	02500a13          	li	s4,37
      if(c == 'd'){
 50e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 512:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 516:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 51a:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 51e:	00000b97          	auipc	s7,0x0
 522:	3b2b8b93          	addi	s7,s7,946 # 8d0 <digits>
 526:	a839                	j	544 <vprintf+0x6a>
        putc(fd, c);
 528:	85ca                	mv	a1,s2
 52a:	8556                	mv	a0,s5
 52c:	00000097          	auipc	ra,0x0
 530:	ee2080e7          	jalr	-286(ra) # 40e <putc>
 534:	a019                	j	53a <vprintf+0x60>
    } else if(state == '%'){
 536:	01498f63          	beq	s3,s4,554 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 53a:	0485                	addi	s1,s1,1
 53c:	fff4c903          	lbu	s2,-1(s1)
 540:	14090d63          	beqz	s2,69a <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 544:	0009079b          	sext.w	a5,s2
    if(state == 0){
 548:	fe0997e3          	bnez	s3,536 <vprintf+0x5c>
      if(c == '%'){
 54c:	fd479ee3          	bne	a5,s4,528 <vprintf+0x4e>
        state = '%';
 550:	89be                	mv	s3,a5
 552:	b7e5                	j	53a <vprintf+0x60>
      if(c == 'd'){
 554:	05878063          	beq	a5,s8,594 <vprintf+0xba>
      } else if(c == 'l') {
 558:	05978c63          	beq	a5,s9,5b0 <vprintf+0xd6>
      } else if(c == 'x') {
 55c:	07a78863          	beq	a5,s10,5cc <vprintf+0xf2>
      } else if(c == 'p') {
 560:	09b78463          	beq	a5,s11,5e8 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 564:	07300713          	li	a4,115
 568:	0ce78663          	beq	a5,a4,634 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 56c:	06300713          	li	a4,99
 570:	0ee78e63          	beq	a5,a4,66c <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 574:	11478863          	beq	a5,s4,684 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 578:	85d2                	mv	a1,s4
 57a:	8556                	mv	a0,s5
 57c:	00000097          	auipc	ra,0x0
 580:	e92080e7          	jalr	-366(ra) # 40e <putc>
        putc(fd, c);
 584:	85ca                	mv	a1,s2
 586:	8556                	mv	a0,s5
 588:	00000097          	auipc	ra,0x0
 58c:	e86080e7          	jalr	-378(ra) # 40e <putc>
      }
      state = 0;
 590:	4981                	li	s3,0
 592:	b765                	j	53a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 594:	008b0913          	addi	s2,s6,8
 598:	4685                	li	a3,1
 59a:	4629                	li	a2,10
 59c:	000b2583          	lw	a1,0(s6)
 5a0:	8556                	mv	a0,s5
 5a2:	00000097          	auipc	ra,0x0
 5a6:	e8e080e7          	jalr	-370(ra) # 430 <printint>
 5aa:	8b4a                	mv	s6,s2
      state = 0;
 5ac:	4981                	li	s3,0
 5ae:	b771                	j	53a <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5b0:	008b0913          	addi	s2,s6,8
 5b4:	4681                	li	a3,0
 5b6:	4629                	li	a2,10
 5b8:	000b2583          	lw	a1,0(s6)
 5bc:	8556                	mv	a0,s5
 5be:	00000097          	auipc	ra,0x0
 5c2:	e72080e7          	jalr	-398(ra) # 430 <printint>
 5c6:	8b4a                	mv	s6,s2
      state = 0;
 5c8:	4981                	li	s3,0
 5ca:	bf85                	j	53a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5cc:	008b0913          	addi	s2,s6,8
 5d0:	4681                	li	a3,0
 5d2:	4641                	li	a2,16
 5d4:	000b2583          	lw	a1,0(s6)
 5d8:	8556                	mv	a0,s5
 5da:	00000097          	auipc	ra,0x0
 5de:	e56080e7          	jalr	-426(ra) # 430 <printint>
 5e2:	8b4a                	mv	s6,s2
      state = 0;
 5e4:	4981                	li	s3,0
 5e6:	bf91                	j	53a <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5e8:	008b0793          	addi	a5,s6,8
 5ec:	f8f43423          	sd	a5,-120(s0)
 5f0:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 5f4:	03000593          	li	a1,48
 5f8:	8556                	mv	a0,s5
 5fa:	00000097          	auipc	ra,0x0
 5fe:	e14080e7          	jalr	-492(ra) # 40e <putc>
  putc(fd, 'x');
 602:	85ea                	mv	a1,s10
 604:	8556                	mv	a0,s5
 606:	00000097          	auipc	ra,0x0
 60a:	e08080e7          	jalr	-504(ra) # 40e <putc>
 60e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 610:	03c9d793          	srli	a5,s3,0x3c
 614:	97de                	add	a5,a5,s7
 616:	0007c583          	lbu	a1,0(a5)
 61a:	8556                	mv	a0,s5
 61c:	00000097          	auipc	ra,0x0
 620:	df2080e7          	jalr	-526(ra) # 40e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 624:	0992                	slli	s3,s3,0x4
 626:	397d                	addiw	s2,s2,-1
 628:	fe0914e3          	bnez	s2,610 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 62c:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 630:	4981                	li	s3,0
 632:	b721                	j	53a <vprintf+0x60>
        s = va_arg(ap, char*);
 634:	008b0993          	addi	s3,s6,8
 638:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 63c:	02090163          	beqz	s2,65e <vprintf+0x184>
        while(*s != 0){
 640:	00094583          	lbu	a1,0(s2)
 644:	c9a1                	beqz	a1,694 <vprintf+0x1ba>
          putc(fd, *s);
 646:	8556                	mv	a0,s5
 648:	00000097          	auipc	ra,0x0
 64c:	dc6080e7          	jalr	-570(ra) # 40e <putc>
          s++;
 650:	0905                	addi	s2,s2,1
        while(*s != 0){
 652:	00094583          	lbu	a1,0(s2)
 656:	f9e5                	bnez	a1,646 <vprintf+0x16c>
        s = va_arg(ap, char*);
 658:	8b4e                	mv	s6,s3
      state = 0;
 65a:	4981                	li	s3,0
 65c:	bdf9                	j	53a <vprintf+0x60>
          s = "(null)";
 65e:	00000917          	auipc	s2,0x0
 662:	26a90913          	addi	s2,s2,618 # 8c8 <malloc+0x124>
        while(*s != 0){
 666:	02800593          	li	a1,40
 66a:	bff1                	j	646 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 66c:	008b0913          	addi	s2,s6,8
 670:	000b4583          	lbu	a1,0(s6)
 674:	8556                	mv	a0,s5
 676:	00000097          	auipc	ra,0x0
 67a:	d98080e7          	jalr	-616(ra) # 40e <putc>
 67e:	8b4a                	mv	s6,s2
      state = 0;
 680:	4981                	li	s3,0
 682:	bd65                	j	53a <vprintf+0x60>
        putc(fd, c);
 684:	85d2                	mv	a1,s4
 686:	8556                	mv	a0,s5
 688:	00000097          	auipc	ra,0x0
 68c:	d86080e7          	jalr	-634(ra) # 40e <putc>
      state = 0;
 690:	4981                	li	s3,0
 692:	b565                	j	53a <vprintf+0x60>
        s = va_arg(ap, char*);
 694:	8b4e                	mv	s6,s3
      state = 0;
 696:	4981                	li	s3,0
 698:	b54d                	j	53a <vprintf+0x60>
    }
  }
}
 69a:	70e6                	ld	ra,120(sp)
 69c:	7446                	ld	s0,112(sp)
 69e:	74a6                	ld	s1,104(sp)
 6a0:	7906                	ld	s2,96(sp)
 6a2:	69e6                	ld	s3,88(sp)
 6a4:	6a46                	ld	s4,80(sp)
 6a6:	6aa6                	ld	s5,72(sp)
 6a8:	6b06                	ld	s6,64(sp)
 6aa:	7be2                	ld	s7,56(sp)
 6ac:	7c42                	ld	s8,48(sp)
 6ae:	7ca2                	ld	s9,40(sp)
 6b0:	7d02                	ld	s10,32(sp)
 6b2:	6de2                	ld	s11,24(sp)
 6b4:	6109                	addi	sp,sp,128
 6b6:	8082                	ret

00000000000006b8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6b8:	715d                	addi	sp,sp,-80
 6ba:	ec06                	sd	ra,24(sp)
 6bc:	e822                	sd	s0,16(sp)
 6be:	1000                	addi	s0,sp,32
 6c0:	e010                	sd	a2,0(s0)
 6c2:	e414                	sd	a3,8(s0)
 6c4:	e818                	sd	a4,16(s0)
 6c6:	ec1c                	sd	a5,24(s0)
 6c8:	03043023          	sd	a6,32(s0)
 6cc:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6d0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6d4:	8622                	mv	a2,s0
 6d6:	00000097          	auipc	ra,0x0
 6da:	e04080e7          	jalr	-508(ra) # 4da <vprintf>
}
 6de:	60e2                	ld	ra,24(sp)
 6e0:	6442                	ld	s0,16(sp)
 6e2:	6161                	addi	sp,sp,80
 6e4:	8082                	ret

00000000000006e6 <printf>:

void
printf(const char *fmt, ...)
{
 6e6:	711d                	addi	sp,sp,-96
 6e8:	ec06                	sd	ra,24(sp)
 6ea:	e822                	sd	s0,16(sp)
 6ec:	1000                	addi	s0,sp,32
 6ee:	e40c                	sd	a1,8(s0)
 6f0:	e810                	sd	a2,16(s0)
 6f2:	ec14                	sd	a3,24(s0)
 6f4:	f018                	sd	a4,32(s0)
 6f6:	f41c                	sd	a5,40(s0)
 6f8:	03043823          	sd	a6,48(s0)
 6fc:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 700:	00840613          	addi	a2,s0,8
 704:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 708:	85aa                	mv	a1,a0
 70a:	4505                	li	a0,1
 70c:	00000097          	auipc	ra,0x0
 710:	dce080e7          	jalr	-562(ra) # 4da <vprintf>
}
 714:	60e2                	ld	ra,24(sp)
 716:	6442                	ld	s0,16(sp)
 718:	6125                	addi	sp,sp,96
 71a:	8082                	ret

000000000000071c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 71c:	1141                	addi	sp,sp,-16
 71e:	e422                	sd	s0,8(sp)
 720:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 722:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 726:	00001797          	auipc	a5,0x1
 72a:	8da7b783          	ld	a5,-1830(a5) # 1000 <freep>
 72e:	a805                	j	75e <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 730:	4618                	lw	a4,8(a2)
 732:	9db9                	addw	a1,a1,a4
 734:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 738:	6398                	ld	a4,0(a5)
 73a:	6318                	ld	a4,0(a4)
 73c:	fee53823          	sd	a4,-16(a0)
 740:	a091                	j	784 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 742:	ff852703          	lw	a4,-8(a0)
 746:	9e39                	addw	a2,a2,a4
 748:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 74a:	ff053703          	ld	a4,-16(a0)
 74e:	e398                	sd	a4,0(a5)
 750:	a099                	j	796 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 752:	6398                	ld	a4,0(a5)
 754:	00e7e463          	bltu	a5,a4,75c <free+0x40>
 758:	00e6ea63          	bltu	a3,a4,76c <free+0x50>
{
 75c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 75e:	fed7fae3          	bgeu	a5,a3,752 <free+0x36>
 762:	6398                	ld	a4,0(a5)
 764:	00e6e463          	bltu	a3,a4,76c <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 768:	fee7eae3          	bltu	a5,a4,75c <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 76c:	ff852583          	lw	a1,-8(a0)
 770:	6390                	ld	a2,0(a5)
 772:	02059713          	slli	a4,a1,0x20
 776:	9301                	srli	a4,a4,0x20
 778:	0712                	slli	a4,a4,0x4
 77a:	9736                	add	a4,a4,a3
 77c:	fae60ae3          	beq	a2,a4,730 <free+0x14>
    bp->s.ptr = p->s.ptr;
 780:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 784:	4790                	lw	a2,8(a5)
 786:	02061713          	slli	a4,a2,0x20
 78a:	9301                	srli	a4,a4,0x20
 78c:	0712                	slli	a4,a4,0x4
 78e:	973e                	add	a4,a4,a5
 790:	fae689e3          	beq	a3,a4,742 <free+0x26>
  } else
    p->s.ptr = bp;
 794:	e394                	sd	a3,0(a5)
  freep = p;
 796:	00001717          	auipc	a4,0x1
 79a:	86f73523          	sd	a5,-1942(a4) # 1000 <freep>
}
 79e:	6422                	ld	s0,8(sp)
 7a0:	0141                	addi	sp,sp,16
 7a2:	8082                	ret

00000000000007a4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7a4:	7139                	addi	sp,sp,-64
 7a6:	fc06                	sd	ra,56(sp)
 7a8:	f822                	sd	s0,48(sp)
 7aa:	f426                	sd	s1,40(sp)
 7ac:	f04a                	sd	s2,32(sp)
 7ae:	ec4e                	sd	s3,24(sp)
 7b0:	e852                	sd	s4,16(sp)
 7b2:	e456                	sd	s5,8(sp)
 7b4:	e05a                	sd	s6,0(sp)
 7b6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7b8:	02051493          	slli	s1,a0,0x20
 7bc:	9081                	srli	s1,s1,0x20
 7be:	04bd                	addi	s1,s1,15
 7c0:	8091                	srli	s1,s1,0x4
 7c2:	0014899b          	addiw	s3,s1,1
 7c6:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7c8:	00001517          	auipc	a0,0x1
 7cc:	83853503          	ld	a0,-1992(a0) # 1000 <freep>
 7d0:	c515                	beqz	a0,7fc <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7d2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7d4:	4798                	lw	a4,8(a5)
 7d6:	02977f63          	bgeu	a4,s1,814 <malloc+0x70>
 7da:	8a4e                	mv	s4,s3
 7dc:	0009871b          	sext.w	a4,s3
 7e0:	6685                	lui	a3,0x1
 7e2:	00d77363          	bgeu	a4,a3,7e8 <malloc+0x44>
 7e6:	6a05                	lui	s4,0x1
 7e8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7ec:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7f0:	00001917          	auipc	s2,0x1
 7f4:	81090913          	addi	s2,s2,-2032 # 1000 <freep>
  if(p == (char*)-1)
 7f8:	5afd                	li	s5,-1
 7fa:	a88d                	j	86c <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 7fc:	00001797          	auipc	a5,0x1
 800:	81478793          	addi	a5,a5,-2028 # 1010 <base>
 804:	00000717          	auipc	a4,0x0
 808:	7ef73e23          	sd	a5,2044(a4) # 1000 <freep>
 80c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 80e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 812:	b7e1                	j	7da <malloc+0x36>
      if(p->s.size == nunits)
 814:	02e48b63          	beq	s1,a4,84a <malloc+0xa6>
        p->s.size -= nunits;
 818:	4137073b          	subw	a4,a4,s3
 81c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 81e:	1702                	slli	a4,a4,0x20
 820:	9301                	srli	a4,a4,0x20
 822:	0712                	slli	a4,a4,0x4
 824:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 826:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 82a:	00000717          	auipc	a4,0x0
 82e:	7ca73b23          	sd	a0,2006(a4) # 1000 <freep>
      return (void*)(p + 1);
 832:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 836:	70e2                	ld	ra,56(sp)
 838:	7442                	ld	s0,48(sp)
 83a:	74a2                	ld	s1,40(sp)
 83c:	7902                	ld	s2,32(sp)
 83e:	69e2                	ld	s3,24(sp)
 840:	6a42                	ld	s4,16(sp)
 842:	6aa2                	ld	s5,8(sp)
 844:	6b02                	ld	s6,0(sp)
 846:	6121                	addi	sp,sp,64
 848:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 84a:	6398                	ld	a4,0(a5)
 84c:	e118                	sd	a4,0(a0)
 84e:	bff1                	j	82a <malloc+0x86>
  hp->s.size = nu;
 850:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 854:	0541                	addi	a0,a0,16
 856:	00000097          	auipc	ra,0x0
 85a:	ec6080e7          	jalr	-314(ra) # 71c <free>
  return freep;
 85e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 862:	d971                	beqz	a0,836 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 864:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 866:	4798                	lw	a4,8(a5)
 868:	fa9776e3          	bgeu	a4,s1,814 <malloc+0x70>
    if(p == freep)
 86c:	00093703          	ld	a4,0(s2)
 870:	853e                	mv	a0,a5
 872:	fef719e3          	bne	a4,a5,864 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 876:	8552                	mv	a0,s4
 878:	00000097          	auipc	ra,0x0
 87c:	b4e080e7          	jalr	-1202(ra) # 3c6 <sbrk>
  if(p == (char*)-1)
 880:	fd5518e3          	bne	a0,s5,850 <malloc+0xac>
        return 0;
 884:	4501                	li	a0,0
 886:	bf45                	j	836 <malloc+0x92>

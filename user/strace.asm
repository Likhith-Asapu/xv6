
user/_strace:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/param.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
 
int main(int argc, char *argv[]) {
   0:	712d                	addi	sp,sp,-288
   2:	ee06                	sd	ra,280(sp)
   4:	ea22                	sd	s0,272(sp)
   6:	e626                	sd	s1,264(sp)
   8:	e24a                	sd	s2,256(sp)
   a:	1200                	addi	s0,sp,288
   c:	892e                	mv	s2,a1
    int i;
    char *nargv[MAXARG];

    if(argc < 3 || (argv[1][0] < '0' || argv[1][0] > '9')){
   e:	4789                	li	a5,2
  10:	00a7dd63          	bge	a5,a0,2a <main+0x2a>
  14:	84aa                	mv	s1,a0
  16:	6588                	ld	a0,8(a1)
  18:	00054783          	lbu	a5,0(a0)
  1c:	fd07879b          	addiw	a5,a5,-48
  20:	0ff7f793          	andi	a5,a5,255
  24:	4725                	li	a4,9
  26:	02f77263          	bgeu	a4,a5,4a <main+0x4a>
        fprintf(2, "Usage: %s mask command\n", argv[0]);
  2a:	00093603          	ld	a2,0(s2)
  2e:	00001597          	auipc	a1,0x1
  32:	84258593          	addi	a1,a1,-1982 # 870 <malloc+0xea>
  36:	4509                	li	a0,2
  38:	00000097          	auipc	ra,0x0
  3c:	662080e7          	jalr	1634(ra) # 69a <fprintf>
        exit(1);
  40:	4505                	li	a0,1
  42:	00000097          	auipc	ra,0x0
  46:	306080e7          	jalr	774(ra) # 348 <exit>
    }

    if (trace(atoi(argv[1])) < 0) {
  4a:	00000097          	auipc	ra,0x0
  4e:	202080e7          	jalr	514(ra) # 24c <atoi>
  52:	00000097          	auipc	ra,0x0
  56:	396080e7          	jalr	918(ra) # 3e8 <trace>
  5a:	04054363          	bltz	a0,a0 <main+0xa0>
  5e:	01090793          	addi	a5,s2,16
  62:	ee040713          	addi	a4,s0,-288
  66:	ffd4869b          	addiw	a3,s1,-3
  6a:	1682                	slli	a3,a3,0x20
  6c:	9281                	srli	a3,a3,0x20
  6e:	068e                	slli	a3,a3,0x3
  70:	96be                	add	a3,a3,a5
  72:	10090913          	addi	s2,s2,256
        fprintf(2, "%s: trace failed\n", argv[0]);
        exit(1);
    }
    
    for(i = 2; i < argc && i < MAXARG; i++){
    	nargv[i-2] = argv[i];
  76:	6390                	ld	a2,0(a5)
  78:	e310                	sd	a2,0(a4)
    for(i = 2; i < argc && i < MAXARG; i++){
  7a:	00d78663          	beq	a5,a3,86 <main+0x86>
  7e:	07a1                	addi	a5,a5,8
  80:	0721                	addi	a4,a4,8
  82:	ff279ae3          	bne	a5,s2,76 <main+0x76>
    }
    exec(nargv[0], nargv);
  86:	ee040593          	addi	a1,s0,-288
  8a:	ee043503          	ld	a0,-288(s0)
  8e:	00000097          	auipc	ra,0x0
  92:	2f2080e7          	jalr	754(ra) # 380 <exec>
    exit(0);
  96:	4501                	li	a0,0
  98:	00000097          	auipc	ra,0x0
  9c:	2b0080e7          	jalr	688(ra) # 348 <exit>
        fprintf(2, "%s: trace failed\n", argv[0]);
  a0:	00093603          	ld	a2,0(s2)
  a4:	00000597          	auipc	a1,0x0
  a8:	7e458593          	addi	a1,a1,2020 # 888 <malloc+0x102>
  ac:	4509                	li	a0,2
  ae:	00000097          	auipc	ra,0x0
  b2:	5ec080e7          	jalr	1516(ra) # 69a <fprintf>
        exit(1);
  b6:	4505                	li	a0,1
  b8:	00000097          	auipc	ra,0x0
  bc:	290080e7          	jalr	656(ra) # 348 <exit>

00000000000000c0 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  c0:	1141                	addi	sp,sp,-16
  c2:	e406                	sd	ra,8(sp)
  c4:	e022                	sd	s0,0(sp)
  c6:	0800                	addi	s0,sp,16
  extern int main();
  main();
  c8:	00000097          	auipc	ra,0x0
  cc:	f38080e7          	jalr	-200(ra) # 0 <main>
  exit(0);
  d0:	4501                	li	a0,0
  d2:	00000097          	auipc	ra,0x0
  d6:	276080e7          	jalr	630(ra) # 348 <exit>

00000000000000da <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  da:	1141                	addi	sp,sp,-16
  dc:	e422                	sd	s0,8(sp)
  de:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  e0:	87aa                	mv	a5,a0
  e2:	0585                	addi	a1,a1,1
  e4:	0785                	addi	a5,a5,1
  e6:	fff5c703          	lbu	a4,-1(a1)
  ea:	fee78fa3          	sb	a4,-1(a5)
  ee:	fb75                	bnez	a4,e2 <strcpy+0x8>
    ;
  return os;
}
  f0:	6422                	ld	s0,8(sp)
  f2:	0141                	addi	sp,sp,16
  f4:	8082                	ret

00000000000000f6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  f6:	1141                	addi	sp,sp,-16
  f8:	e422                	sd	s0,8(sp)
  fa:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  fc:	00054783          	lbu	a5,0(a0)
 100:	cb91                	beqz	a5,114 <strcmp+0x1e>
 102:	0005c703          	lbu	a4,0(a1)
 106:	00f71763          	bne	a4,a5,114 <strcmp+0x1e>
    p++, q++;
 10a:	0505                	addi	a0,a0,1
 10c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 10e:	00054783          	lbu	a5,0(a0)
 112:	fbe5                	bnez	a5,102 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 114:	0005c503          	lbu	a0,0(a1)
}
 118:	40a7853b          	subw	a0,a5,a0
 11c:	6422                	ld	s0,8(sp)
 11e:	0141                	addi	sp,sp,16
 120:	8082                	ret

0000000000000122 <strlen>:

uint
strlen(const char *s)
{
 122:	1141                	addi	sp,sp,-16
 124:	e422                	sd	s0,8(sp)
 126:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 128:	00054783          	lbu	a5,0(a0)
 12c:	cf91                	beqz	a5,148 <strlen+0x26>
 12e:	0505                	addi	a0,a0,1
 130:	87aa                	mv	a5,a0
 132:	4685                	li	a3,1
 134:	9e89                	subw	a3,a3,a0
 136:	00f6853b          	addw	a0,a3,a5
 13a:	0785                	addi	a5,a5,1
 13c:	fff7c703          	lbu	a4,-1(a5)
 140:	fb7d                	bnez	a4,136 <strlen+0x14>
    ;
  return n;
}
 142:	6422                	ld	s0,8(sp)
 144:	0141                	addi	sp,sp,16
 146:	8082                	ret
  for(n = 0; s[n]; n++)
 148:	4501                	li	a0,0
 14a:	bfe5                	j	142 <strlen+0x20>

000000000000014c <memset>:

void*
memset(void *dst, int c, uint n)
{
 14c:	1141                	addi	sp,sp,-16
 14e:	e422                	sd	s0,8(sp)
 150:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 152:	ca19                	beqz	a2,168 <memset+0x1c>
 154:	87aa                	mv	a5,a0
 156:	1602                	slli	a2,a2,0x20
 158:	9201                	srli	a2,a2,0x20
 15a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 15e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 162:	0785                	addi	a5,a5,1
 164:	fee79de3          	bne	a5,a4,15e <memset+0x12>
  }
  return dst;
}
 168:	6422                	ld	s0,8(sp)
 16a:	0141                	addi	sp,sp,16
 16c:	8082                	ret

000000000000016e <strchr>:

char*
strchr(const char *s, char c)
{
 16e:	1141                	addi	sp,sp,-16
 170:	e422                	sd	s0,8(sp)
 172:	0800                	addi	s0,sp,16
  for(; *s; s++)
 174:	00054783          	lbu	a5,0(a0)
 178:	cb99                	beqz	a5,18e <strchr+0x20>
    if(*s == c)
 17a:	00f58763          	beq	a1,a5,188 <strchr+0x1a>
  for(; *s; s++)
 17e:	0505                	addi	a0,a0,1
 180:	00054783          	lbu	a5,0(a0)
 184:	fbfd                	bnez	a5,17a <strchr+0xc>
      return (char*)s;
  return 0;
 186:	4501                	li	a0,0
}
 188:	6422                	ld	s0,8(sp)
 18a:	0141                	addi	sp,sp,16
 18c:	8082                	ret
  return 0;
 18e:	4501                	li	a0,0
 190:	bfe5                	j	188 <strchr+0x1a>

0000000000000192 <gets>:

char*
gets(char *buf, int max)
{
 192:	711d                	addi	sp,sp,-96
 194:	ec86                	sd	ra,88(sp)
 196:	e8a2                	sd	s0,80(sp)
 198:	e4a6                	sd	s1,72(sp)
 19a:	e0ca                	sd	s2,64(sp)
 19c:	fc4e                	sd	s3,56(sp)
 19e:	f852                	sd	s4,48(sp)
 1a0:	f456                	sd	s5,40(sp)
 1a2:	f05a                	sd	s6,32(sp)
 1a4:	ec5e                	sd	s7,24(sp)
 1a6:	1080                	addi	s0,sp,96
 1a8:	8baa                	mv	s7,a0
 1aa:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ac:	892a                	mv	s2,a0
 1ae:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1b0:	4aa9                	li	s5,10
 1b2:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1b4:	89a6                	mv	s3,s1
 1b6:	2485                	addiw	s1,s1,1
 1b8:	0344d863          	bge	s1,s4,1e8 <gets+0x56>
    cc = read(0, &c, 1);
 1bc:	4605                	li	a2,1
 1be:	faf40593          	addi	a1,s0,-81
 1c2:	4501                	li	a0,0
 1c4:	00000097          	auipc	ra,0x0
 1c8:	19c080e7          	jalr	412(ra) # 360 <read>
    if(cc < 1)
 1cc:	00a05e63          	blez	a0,1e8 <gets+0x56>
    buf[i++] = c;
 1d0:	faf44783          	lbu	a5,-81(s0)
 1d4:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1d8:	01578763          	beq	a5,s5,1e6 <gets+0x54>
 1dc:	0905                	addi	s2,s2,1
 1de:	fd679be3          	bne	a5,s6,1b4 <gets+0x22>
  for(i=0; i+1 < max; ){
 1e2:	89a6                	mv	s3,s1
 1e4:	a011                	j	1e8 <gets+0x56>
 1e6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1e8:	99de                	add	s3,s3,s7
 1ea:	00098023          	sb	zero,0(s3)
  return buf;
}
 1ee:	855e                	mv	a0,s7
 1f0:	60e6                	ld	ra,88(sp)
 1f2:	6446                	ld	s0,80(sp)
 1f4:	64a6                	ld	s1,72(sp)
 1f6:	6906                	ld	s2,64(sp)
 1f8:	79e2                	ld	s3,56(sp)
 1fa:	7a42                	ld	s4,48(sp)
 1fc:	7aa2                	ld	s5,40(sp)
 1fe:	7b02                	ld	s6,32(sp)
 200:	6be2                	ld	s7,24(sp)
 202:	6125                	addi	sp,sp,96
 204:	8082                	ret

0000000000000206 <stat>:

int
stat(const char *n, struct stat *st)
{
 206:	1101                	addi	sp,sp,-32
 208:	ec06                	sd	ra,24(sp)
 20a:	e822                	sd	s0,16(sp)
 20c:	e426                	sd	s1,8(sp)
 20e:	e04a                	sd	s2,0(sp)
 210:	1000                	addi	s0,sp,32
 212:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 214:	4581                	li	a1,0
 216:	00000097          	auipc	ra,0x0
 21a:	172080e7          	jalr	370(ra) # 388 <open>
  if(fd < 0)
 21e:	02054563          	bltz	a0,248 <stat+0x42>
 222:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 224:	85ca                	mv	a1,s2
 226:	00000097          	auipc	ra,0x0
 22a:	17a080e7          	jalr	378(ra) # 3a0 <fstat>
 22e:	892a                	mv	s2,a0
  close(fd);
 230:	8526                	mv	a0,s1
 232:	00000097          	auipc	ra,0x0
 236:	13e080e7          	jalr	318(ra) # 370 <close>
  return r;
}
 23a:	854a                	mv	a0,s2
 23c:	60e2                	ld	ra,24(sp)
 23e:	6442                	ld	s0,16(sp)
 240:	64a2                	ld	s1,8(sp)
 242:	6902                	ld	s2,0(sp)
 244:	6105                	addi	sp,sp,32
 246:	8082                	ret
    return -1;
 248:	597d                	li	s2,-1
 24a:	bfc5                	j	23a <stat+0x34>

000000000000024c <atoi>:

int
atoi(const char *s)
{
 24c:	1141                	addi	sp,sp,-16
 24e:	e422                	sd	s0,8(sp)
 250:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 252:	00054603          	lbu	a2,0(a0)
 256:	fd06079b          	addiw	a5,a2,-48
 25a:	0ff7f793          	andi	a5,a5,255
 25e:	4725                	li	a4,9
 260:	02f76963          	bltu	a4,a5,292 <atoi+0x46>
 264:	86aa                	mv	a3,a0
  n = 0;
 266:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 268:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 26a:	0685                	addi	a3,a3,1
 26c:	0025179b          	slliw	a5,a0,0x2
 270:	9fa9                	addw	a5,a5,a0
 272:	0017979b          	slliw	a5,a5,0x1
 276:	9fb1                	addw	a5,a5,a2
 278:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 27c:	0006c603          	lbu	a2,0(a3)
 280:	fd06071b          	addiw	a4,a2,-48
 284:	0ff77713          	andi	a4,a4,255
 288:	fee5f1e3          	bgeu	a1,a4,26a <atoi+0x1e>
  return n;
}
 28c:	6422                	ld	s0,8(sp)
 28e:	0141                	addi	sp,sp,16
 290:	8082                	ret
  n = 0;
 292:	4501                	li	a0,0
 294:	bfe5                	j	28c <atoi+0x40>

0000000000000296 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 296:	1141                	addi	sp,sp,-16
 298:	e422                	sd	s0,8(sp)
 29a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 29c:	02b57463          	bgeu	a0,a1,2c4 <memmove+0x2e>
    while(n-- > 0)
 2a0:	00c05f63          	blez	a2,2be <memmove+0x28>
 2a4:	1602                	slli	a2,a2,0x20
 2a6:	9201                	srli	a2,a2,0x20
 2a8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2ac:	872a                	mv	a4,a0
      *dst++ = *src++;
 2ae:	0585                	addi	a1,a1,1
 2b0:	0705                	addi	a4,a4,1
 2b2:	fff5c683          	lbu	a3,-1(a1)
 2b6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2ba:	fee79ae3          	bne	a5,a4,2ae <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2be:	6422                	ld	s0,8(sp)
 2c0:	0141                	addi	sp,sp,16
 2c2:	8082                	ret
    dst += n;
 2c4:	00c50733          	add	a4,a0,a2
    src += n;
 2c8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2ca:	fec05ae3          	blez	a2,2be <memmove+0x28>
 2ce:	fff6079b          	addiw	a5,a2,-1
 2d2:	1782                	slli	a5,a5,0x20
 2d4:	9381                	srli	a5,a5,0x20
 2d6:	fff7c793          	not	a5,a5
 2da:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2dc:	15fd                	addi	a1,a1,-1
 2de:	177d                	addi	a4,a4,-1
 2e0:	0005c683          	lbu	a3,0(a1)
 2e4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2e8:	fee79ae3          	bne	a5,a4,2dc <memmove+0x46>
 2ec:	bfc9                	j	2be <memmove+0x28>

00000000000002ee <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2ee:	1141                	addi	sp,sp,-16
 2f0:	e422                	sd	s0,8(sp)
 2f2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2f4:	ca05                	beqz	a2,324 <memcmp+0x36>
 2f6:	fff6069b          	addiw	a3,a2,-1
 2fa:	1682                	slli	a3,a3,0x20
 2fc:	9281                	srli	a3,a3,0x20
 2fe:	0685                	addi	a3,a3,1
 300:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 302:	00054783          	lbu	a5,0(a0)
 306:	0005c703          	lbu	a4,0(a1)
 30a:	00e79863          	bne	a5,a4,31a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 30e:	0505                	addi	a0,a0,1
    p2++;
 310:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 312:	fed518e3          	bne	a0,a3,302 <memcmp+0x14>
  }
  return 0;
 316:	4501                	li	a0,0
 318:	a019                	j	31e <memcmp+0x30>
      return *p1 - *p2;
 31a:	40e7853b          	subw	a0,a5,a4
}
 31e:	6422                	ld	s0,8(sp)
 320:	0141                	addi	sp,sp,16
 322:	8082                	ret
  return 0;
 324:	4501                	li	a0,0
 326:	bfe5                	j	31e <memcmp+0x30>

0000000000000328 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 328:	1141                	addi	sp,sp,-16
 32a:	e406                	sd	ra,8(sp)
 32c:	e022                	sd	s0,0(sp)
 32e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 330:	00000097          	auipc	ra,0x0
 334:	f66080e7          	jalr	-154(ra) # 296 <memmove>
}
 338:	60a2                	ld	ra,8(sp)
 33a:	6402                	ld	s0,0(sp)
 33c:	0141                	addi	sp,sp,16
 33e:	8082                	ret

0000000000000340 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 340:	4885                	li	a7,1
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <exit>:
.global exit
exit:
 li a7, SYS_exit
 348:	4889                	li	a7,2
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <wait>:
.global wait
wait:
 li a7, SYS_wait
 350:	488d                	li	a7,3
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 358:	4891                	li	a7,4
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <read>:
.global read
read:
 li a7, SYS_read
 360:	4895                	li	a7,5
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <write>:
.global write
write:
 li a7, SYS_write
 368:	48c1                	li	a7,16
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <close>:
.global close
close:
 li a7, SYS_close
 370:	48d5                	li	a7,21
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <kill>:
.global kill
kill:
 li a7, SYS_kill
 378:	4899                	li	a7,6
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <exec>:
.global exec
exec:
 li a7, SYS_exec
 380:	489d                	li	a7,7
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <open>:
.global open
open:
 li a7, SYS_open
 388:	48bd                	li	a7,15
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 390:	48c5                	li	a7,17
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 398:	48c9                	li	a7,18
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3a0:	48a1                	li	a7,8
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <link>:
.global link
link:
 li a7, SYS_link
 3a8:	48cd                	li	a7,19
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3b0:	48d1                	li	a7,20
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3b8:	48a5                	li	a7,9
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3c0:	48a9                	li	a7,10
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3c8:	48ad                	li	a7,11
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3d0:	48b1                	li	a7,12
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3d8:	48b5                	li	a7,13
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3e0:	48b9                	li	a7,14
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <trace>:
.global trace
trace:
 li a7, SYS_trace
 3e8:	48d9                	li	a7,22
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3f0:	1101                	addi	sp,sp,-32
 3f2:	ec06                	sd	ra,24(sp)
 3f4:	e822                	sd	s0,16(sp)
 3f6:	1000                	addi	s0,sp,32
 3f8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3fc:	4605                	li	a2,1
 3fe:	fef40593          	addi	a1,s0,-17
 402:	00000097          	auipc	ra,0x0
 406:	f66080e7          	jalr	-154(ra) # 368 <write>
}
 40a:	60e2                	ld	ra,24(sp)
 40c:	6442                	ld	s0,16(sp)
 40e:	6105                	addi	sp,sp,32
 410:	8082                	ret

0000000000000412 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 412:	7139                	addi	sp,sp,-64
 414:	fc06                	sd	ra,56(sp)
 416:	f822                	sd	s0,48(sp)
 418:	f426                	sd	s1,40(sp)
 41a:	f04a                	sd	s2,32(sp)
 41c:	ec4e                	sd	s3,24(sp)
 41e:	0080                	addi	s0,sp,64
 420:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 422:	c299                	beqz	a3,428 <printint+0x16>
 424:	0805c863          	bltz	a1,4b4 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 428:	2581                	sext.w	a1,a1
  neg = 0;
 42a:	4881                	li	a7,0
 42c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 430:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 432:	2601                	sext.w	a2,a2
 434:	00000517          	auipc	a0,0x0
 438:	47450513          	addi	a0,a0,1140 # 8a8 <digits>
 43c:	883a                	mv	a6,a4
 43e:	2705                	addiw	a4,a4,1
 440:	02c5f7bb          	remuw	a5,a1,a2
 444:	1782                	slli	a5,a5,0x20
 446:	9381                	srli	a5,a5,0x20
 448:	97aa                	add	a5,a5,a0
 44a:	0007c783          	lbu	a5,0(a5)
 44e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 452:	0005879b          	sext.w	a5,a1
 456:	02c5d5bb          	divuw	a1,a1,a2
 45a:	0685                	addi	a3,a3,1
 45c:	fec7f0e3          	bgeu	a5,a2,43c <printint+0x2a>
  if(neg)
 460:	00088b63          	beqz	a7,476 <printint+0x64>
    buf[i++] = '-';
 464:	fd040793          	addi	a5,s0,-48
 468:	973e                	add	a4,a4,a5
 46a:	02d00793          	li	a5,45
 46e:	fef70823          	sb	a5,-16(a4)
 472:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 476:	02e05863          	blez	a4,4a6 <printint+0x94>
 47a:	fc040793          	addi	a5,s0,-64
 47e:	00e78933          	add	s2,a5,a4
 482:	fff78993          	addi	s3,a5,-1
 486:	99ba                	add	s3,s3,a4
 488:	377d                	addiw	a4,a4,-1
 48a:	1702                	slli	a4,a4,0x20
 48c:	9301                	srli	a4,a4,0x20
 48e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 492:	fff94583          	lbu	a1,-1(s2)
 496:	8526                	mv	a0,s1
 498:	00000097          	auipc	ra,0x0
 49c:	f58080e7          	jalr	-168(ra) # 3f0 <putc>
  while(--i >= 0)
 4a0:	197d                	addi	s2,s2,-1
 4a2:	ff3918e3          	bne	s2,s3,492 <printint+0x80>
}
 4a6:	70e2                	ld	ra,56(sp)
 4a8:	7442                	ld	s0,48(sp)
 4aa:	74a2                	ld	s1,40(sp)
 4ac:	7902                	ld	s2,32(sp)
 4ae:	69e2                	ld	s3,24(sp)
 4b0:	6121                	addi	sp,sp,64
 4b2:	8082                	ret
    x = -xx;
 4b4:	40b005bb          	negw	a1,a1
    neg = 1;
 4b8:	4885                	li	a7,1
    x = -xx;
 4ba:	bf8d                	j	42c <printint+0x1a>

00000000000004bc <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4bc:	7119                	addi	sp,sp,-128
 4be:	fc86                	sd	ra,120(sp)
 4c0:	f8a2                	sd	s0,112(sp)
 4c2:	f4a6                	sd	s1,104(sp)
 4c4:	f0ca                	sd	s2,96(sp)
 4c6:	ecce                	sd	s3,88(sp)
 4c8:	e8d2                	sd	s4,80(sp)
 4ca:	e4d6                	sd	s5,72(sp)
 4cc:	e0da                	sd	s6,64(sp)
 4ce:	fc5e                	sd	s7,56(sp)
 4d0:	f862                	sd	s8,48(sp)
 4d2:	f466                	sd	s9,40(sp)
 4d4:	f06a                	sd	s10,32(sp)
 4d6:	ec6e                	sd	s11,24(sp)
 4d8:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4da:	0005c903          	lbu	s2,0(a1)
 4de:	18090f63          	beqz	s2,67c <vprintf+0x1c0>
 4e2:	8aaa                	mv	s5,a0
 4e4:	8b32                	mv	s6,a2
 4e6:	00158493          	addi	s1,a1,1
  state = 0;
 4ea:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4ec:	02500a13          	li	s4,37
      if(c == 'd'){
 4f0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 4f4:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 4f8:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 4fc:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 500:	00000b97          	auipc	s7,0x0
 504:	3a8b8b93          	addi	s7,s7,936 # 8a8 <digits>
 508:	a839                	j	526 <vprintf+0x6a>
        putc(fd, c);
 50a:	85ca                	mv	a1,s2
 50c:	8556                	mv	a0,s5
 50e:	00000097          	auipc	ra,0x0
 512:	ee2080e7          	jalr	-286(ra) # 3f0 <putc>
 516:	a019                	j	51c <vprintf+0x60>
    } else if(state == '%'){
 518:	01498f63          	beq	s3,s4,536 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 51c:	0485                	addi	s1,s1,1
 51e:	fff4c903          	lbu	s2,-1(s1)
 522:	14090d63          	beqz	s2,67c <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 526:	0009079b          	sext.w	a5,s2
    if(state == 0){
 52a:	fe0997e3          	bnez	s3,518 <vprintf+0x5c>
      if(c == '%'){
 52e:	fd479ee3          	bne	a5,s4,50a <vprintf+0x4e>
        state = '%';
 532:	89be                	mv	s3,a5
 534:	b7e5                	j	51c <vprintf+0x60>
      if(c == 'd'){
 536:	05878063          	beq	a5,s8,576 <vprintf+0xba>
      } else if(c == 'l') {
 53a:	05978c63          	beq	a5,s9,592 <vprintf+0xd6>
      } else if(c == 'x') {
 53e:	07a78863          	beq	a5,s10,5ae <vprintf+0xf2>
      } else if(c == 'p') {
 542:	09b78463          	beq	a5,s11,5ca <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 546:	07300713          	li	a4,115
 54a:	0ce78663          	beq	a5,a4,616 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 54e:	06300713          	li	a4,99
 552:	0ee78e63          	beq	a5,a4,64e <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 556:	11478863          	beq	a5,s4,666 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 55a:	85d2                	mv	a1,s4
 55c:	8556                	mv	a0,s5
 55e:	00000097          	auipc	ra,0x0
 562:	e92080e7          	jalr	-366(ra) # 3f0 <putc>
        putc(fd, c);
 566:	85ca                	mv	a1,s2
 568:	8556                	mv	a0,s5
 56a:	00000097          	auipc	ra,0x0
 56e:	e86080e7          	jalr	-378(ra) # 3f0 <putc>
      }
      state = 0;
 572:	4981                	li	s3,0
 574:	b765                	j	51c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 576:	008b0913          	addi	s2,s6,8
 57a:	4685                	li	a3,1
 57c:	4629                	li	a2,10
 57e:	000b2583          	lw	a1,0(s6)
 582:	8556                	mv	a0,s5
 584:	00000097          	auipc	ra,0x0
 588:	e8e080e7          	jalr	-370(ra) # 412 <printint>
 58c:	8b4a                	mv	s6,s2
      state = 0;
 58e:	4981                	li	s3,0
 590:	b771                	j	51c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 592:	008b0913          	addi	s2,s6,8
 596:	4681                	li	a3,0
 598:	4629                	li	a2,10
 59a:	000b2583          	lw	a1,0(s6)
 59e:	8556                	mv	a0,s5
 5a0:	00000097          	auipc	ra,0x0
 5a4:	e72080e7          	jalr	-398(ra) # 412 <printint>
 5a8:	8b4a                	mv	s6,s2
      state = 0;
 5aa:	4981                	li	s3,0
 5ac:	bf85                	j	51c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5ae:	008b0913          	addi	s2,s6,8
 5b2:	4681                	li	a3,0
 5b4:	4641                	li	a2,16
 5b6:	000b2583          	lw	a1,0(s6)
 5ba:	8556                	mv	a0,s5
 5bc:	00000097          	auipc	ra,0x0
 5c0:	e56080e7          	jalr	-426(ra) # 412 <printint>
 5c4:	8b4a                	mv	s6,s2
      state = 0;
 5c6:	4981                	li	s3,0
 5c8:	bf91                	j	51c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5ca:	008b0793          	addi	a5,s6,8
 5ce:	f8f43423          	sd	a5,-120(s0)
 5d2:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 5d6:	03000593          	li	a1,48
 5da:	8556                	mv	a0,s5
 5dc:	00000097          	auipc	ra,0x0
 5e0:	e14080e7          	jalr	-492(ra) # 3f0 <putc>
  putc(fd, 'x');
 5e4:	85ea                	mv	a1,s10
 5e6:	8556                	mv	a0,s5
 5e8:	00000097          	auipc	ra,0x0
 5ec:	e08080e7          	jalr	-504(ra) # 3f0 <putc>
 5f0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5f2:	03c9d793          	srli	a5,s3,0x3c
 5f6:	97de                	add	a5,a5,s7
 5f8:	0007c583          	lbu	a1,0(a5)
 5fc:	8556                	mv	a0,s5
 5fe:	00000097          	auipc	ra,0x0
 602:	df2080e7          	jalr	-526(ra) # 3f0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 606:	0992                	slli	s3,s3,0x4
 608:	397d                	addiw	s2,s2,-1
 60a:	fe0914e3          	bnez	s2,5f2 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 60e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 612:	4981                	li	s3,0
 614:	b721                	j	51c <vprintf+0x60>
        s = va_arg(ap, char*);
 616:	008b0993          	addi	s3,s6,8
 61a:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 61e:	02090163          	beqz	s2,640 <vprintf+0x184>
        while(*s != 0){
 622:	00094583          	lbu	a1,0(s2)
 626:	c9a1                	beqz	a1,676 <vprintf+0x1ba>
          putc(fd, *s);
 628:	8556                	mv	a0,s5
 62a:	00000097          	auipc	ra,0x0
 62e:	dc6080e7          	jalr	-570(ra) # 3f0 <putc>
          s++;
 632:	0905                	addi	s2,s2,1
        while(*s != 0){
 634:	00094583          	lbu	a1,0(s2)
 638:	f9e5                	bnez	a1,628 <vprintf+0x16c>
        s = va_arg(ap, char*);
 63a:	8b4e                	mv	s6,s3
      state = 0;
 63c:	4981                	li	s3,0
 63e:	bdf9                	j	51c <vprintf+0x60>
          s = "(null)";
 640:	00000917          	auipc	s2,0x0
 644:	26090913          	addi	s2,s2,608 # 8a0 <malloc+0x11a>
        while(*s != 0){
 648:	02800593          	li	a1,40
 64c:	bff1                	j	628 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 64e:	008b0913          	addi	s2,s6,8
 652:	000b4583          	lbu	a1,0(s6)
 656:	8556                	mv	a0,s5
 658:	00000097          	auipc	ra,0x0
 65c:	d98080e7          	jalr	-616(ra) # 3f0 <putc>
 660:	8b4a                	mv	s6,s2
      state = 0;
 662:	4981                	li	s3,0
 664:	bd65                	j	51c <vprintf+0x60>
        putc(fd, c);
 666:	85d2                	mv	a1,s4
 668:	8556                	mv	a0,s5
 66a:	00000097          	auipc	ra,0x0
 66e:	d86080e7          	jalr	-634(ra) # 3f0 <putc>
      state = 0;
 672:	4981                	li	s3,0
 674:	b565                	j	51c <vprintf+0x60>
        s = va_arg(ap, char*);
 676:	8b4e                	mv	s6,s3
      state = 0;
 678:	4981                	li	s3,0
 67a:	b54d                	j	51c <vprintf+0x60>
    }
  }
}
 67c:	70e6                	ld	ra,120(sp)
 67e:	7446                	ld	s0,112(sp)
 680:	74a6                	ld	s1,104(sp)
 682:	7906                	ld	s2,96(sp)
 684:	69e6                	ld	s3,88(sp)
 686:	6a46                	ld	s4,80(sp)
 688:	6aa6                	ld	s5,72(sp)
 68a:	6b06                	ld	s6,64(sp)
 68c:	7be2                	ld	s7,56(sp)
 68e:	7c42                	ld	s8,48(sp)
 690:	7ca2                	ld	s9,40(sp)
 692:	7d02                	ld	s10,32(sp)
 694:	6de2                	ld	s11,24(sp)
 696:	6109                	addi	sp,sp,128
 698:	8082                	ret

000000000000069a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 69a:	715d                	addi	sp,sp,-80
 69c:	ec06                	sd	ra,24(sp)
 69e:	e822                	sd	s0,16(sp)
 6a0:	1000                	addi	s0,sp,32
 6a2:	e010                	sd	a2,0(s0)
 6a4:	e414                	sd	a3,8(s0)
 6a6:	e818                	sd	a4,16(s0)
 6a8:	ec1c                	sd	a5,24(s0)
 6aa:	03043023          	sd	a6,32(s0)
 6ae:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6b2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6b6:	8622                	mv	a2,s0
 6b8:	00000097          	auipc	ra,0x0
 6bc:	e04080e7          	jalr	-508(ra) # 4bc <vprintf>
}
 6c0:	60e2                	ld	ra,24(sp)
 6c2:	6442                	ld	s0,16(sp)
 6c4:	6161                	addi	sp,sp,80
 6c6:	8082                	ret

00000000000006c8 <printf>:

void
printf(const char *fmt, ...)
{
 6c8:	711d                	addi	sp,sp,-96
 6ca:	ec06                	sd	ra,24(sp)
 6cc:	e822                	sd	s0,16(sp)
 6ce:	1000                	addi	s0,sp,32
 6d0:	e40c                	sd	a1,8(s0)
 6d2:	e810                	sd	a2,16(s0)
 6d4:	ec14                	sd	a3,24(s0)
 6d6:	f018                	sd	a4,32(s0)
 6d8:	f41c                	sd	a5,40(s0)
 6da:	03043823          	sd	a6,48(s0)
 6de:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6e2:	00840613          	addi	a2,s0,8
 6e6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6ea:	85aa                	mv	a1,a0
 6ec:	4505                	li	a0,1
 6ee:	00000097          	auipc	ra,0x0
 6f2:	dce080e7          	jalr	-562(ra) # 4bc <vprintf>
}
 6f6:	60e2                	ld	ra,24(sp)
 6f8:	6442                	ld	s0,16(sp)
 6fa:	6125                	addi	sp,sp,96
 6fc:	8082                	ret

00000000000006fe <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6fe:	1141                	addi	sp,sp,-16
 700:	e422                	sd	s0,8(sp)
 702:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 704:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 708:	00001797          	auipc	a5,0x1
 70c:	8f87b783          	ld	a5,-1800(a5) # 1000 <freep>
 710:	a805                	j	740 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 712:	4618                	lw	a4,8(a2)
 714:	9db9                	addw	a1,a1,a4
 716:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 71a:	6398                	ld	a4,0(a5)
 71c:	6318                	ld	a4,0(a4)
 71e:	fee53823          	sd	a4,-16(a0)
 722:	a091                	j	766 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 724:	ff852703          	lw	a4,-8(a0)
 728:	9e39                	addw	a2,a2,a4
 72a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 72c:	ff053703          	ld	a4,-16(a0)
 730:	e398                	sd	a4,0(a5)
 732:	a099                	j	778 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 734:	6398                	ld	a4,0(a5)
 736:	00e7e463          	bltu	a5,a4,73e <free+0x40>
 73a:	00e6ea63          	bltu	a3,a4,74e <free+0x50>
{
 73e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 740:	fed7fae3          	bgeu	a5,a3,734 <free+0x36>
 744:	6398                	ld	a4,0(a5)
 746:	00e6e463          	bltu	a3,a4,74e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 74a:	fee7eae3          	bltu	a5,a4,73e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 74e:	ff852583          	lw	a1,-8(a0)
 752:	6390                	ld	a2,0(a5)
 754:	02059713          	slli	a4,a1,0x20
 758:	9301                	srli	a4,a4,0x20
 75a:	0712                	slli	a4,a4,0x4
 75c:	9736                	add	a4,a4,a3
 75e:	fae60ae3          	beq	a2,a4,712 <free+0x14>
    bp->s.ptr = p->s.ptr;
 762:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 766:	4790                	lw	a2,8(a5)
 768:	02061713          	slli	a4,a2,0x20
 76c:	9301                	srli	a4,a4,0x20
 76e:	0712                	slli	a4,a4,0x4
 770:	973e                	add	a4,a4,a5
 772:	fae689e3          	beq	a3,a4,724 <free+0x26>
  } else
    p->s.ptr = bp;
 776:	e394                	sd	a3,0(a5)
  freep = p;
 778:	00001717          	auipc	a4,0x1
 77c:	88f73423          	sd	a5,-1912(a4) # 1000 <freep>
}
 780:	6422                	ld	s0,8(sp)
 782:	0141                	addi	sp,sp,16
 784:	8082                	ret

0000000000000786 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 786:	7139                	addi	sp,sp,-64
 788:	fc06                	sd	ra,56(sp)
 78a:	f822                	sd	s0,48(sp)
 78c:	f426                	sd	s1,40(sp)
 78e:	f04a                	sd	s2,32(sp)
 790:	ec4e                	sd	s3,24(sp)
 792:	e852                	sd	s4,16(sp)
 794:	e456                	sd	s5,8(sp)
 796:	e05a                	sd	s6,0(sp)
 798:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 79a:	02051493          	slli	s1,a0,0x20
 79e:	9081                	srli	s1,s1,0x20
 7a0:	04bd                	addi	s1,s1,15
 7a2:	8091                	srli	s1,s1,0x4
 7a4:	0014899b          	addiw	s3,s1,1
 7a8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7aa:	00001517          	auipc	a0,0x1
 7ae:	85653503          	ld	a0,-1962(a0) # 1000 <freep>
 7b2:	c515                	beqz	a0,7de <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7b4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7b6:	4798                	lw	a4,8(a5)
 7b8:	02977f63          	bgeu	a4,s1,7f6 <malloc+0x70>
 7bc:	8a4e                	mv	s4,s3
 7be:	0009871b          	sext.w	a4,s3
 7c2:	6685                	lui	a3,0x1
 7c4:	00d77363          	bgeu	a4,a3,7ca <malloc+0x44>
 7c8:	6a05                	lui	s4,0x1
 7ca:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7ce:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7d2:	00001917          	auipc	s2,0x1
 7d6:	82e90913          	addi	s2,s2,-2002 # 1000 <freep>
  if(p == (char*)-1)
 7da:	5afd                	li	s5,-1
 7dc:	a88d                	j	84e <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 7de:	00001797          	auipc	a5,0x1
 7e2:	83278793          	addi	a5,a5,-1998 # 1010 <base>
 7e6:	00001717          	auipc	a4,0x1
 7ea:	80f73d23          	sd	a5,-2022(a4) # 1000 <freep>
 7ee:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7f0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7f4:	b7e1                	j	7bc <malloc+0x36>
      if(p->s.size == nunits)
 7f6:	02e48b63          	beq	s1,a4,82c <malloc+0xa6>
        p->s.size -= nunits;
 7fa:	4137073b          	subw	a4,a4,s3
 7fe:	c798                	sw	a4,8(a5)
        p += p->s.size;
 800:	1702                	slli	a4,a4,0x20
 802:	9301                	srli	a4,a4,0x20
 804:	0712                	slli	a4,a4,0x4
 806:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 808:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 80c:	00000717          	auipc	a4,0x0
 810:	7ea73a23          	sd	a0,2036(a4) # 1000 <freep>
      return (void*)(p + 1);
 814:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 818:	70e2                	ld	ra,56(sp)
 81a:	7442                	ld	s0,48(sp)
 81c:	74a2                	ld	s1,40(sp)
 81e:	7902                	ld	s2,32(sp)
 820:	69e2                	ld	s3,24(sp)
 822:	6a42                	ld	s4,16(sp)
 824:	6aa2                	ld	s5,8(sp)
 826:	6b02                	ld	s6,0(sp)
 828:	6121                	addi	sp,sp,64
 82a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 82c:	6398                	ld	a4,0(a5)
 82e:	e118                	sd	a4,0(a0)
 830:	bff1                	j	80c <malloc+0x86>
  hp->s.size = nu;
 832:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 836:	0541                	addi	a0,a0,16
 838:	00000097          	auipc	ra,0x0
 83c:	ec6080e7          	jalr	-314(ra) # 6fe <free>
  return freep;
 840:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 844:	d971                	beqz	a0,818 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 846:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 848:	4798                	lw	a4,8(a5)
 84a:	fa9776e3          	bgeu	a4,s1,7f6 <malloc+0x70>
    if(p == freep)
 84e:	00093703          	ld	a4,0(s2)
 852:	853e                	mv	a0,a5
 854:	fef719e3          	bne	a4,a5,846 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 858:	8552                	mv	a0,s4
 85a:	00000097          	auipc	ra,0x0
 85e:	b76080e7          	jalr	-1162(ra) # 3d0 <sbrk>
  if(p == (char*)-1)
 862:	fd5518e3          	bne	a0,s5,832 <malloc+0xac>
        return 0;
 866:	4501                	li	a0,0
 868:	bf45                	j	818 <malloc+0x92>

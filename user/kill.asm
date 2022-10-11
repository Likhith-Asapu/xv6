
user/_kill:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
   c:	4785                	li	a5,1
   e:	02a7dd63          	bge	a5,a0,48 <main+0x48>
  12:	00858493          	addi	s1,a1,8
  16:	ffe5091b          	addiw	s2,a0,-2
  1a:	1902                	slli	s2,s2,0x20
  1c:	02095913          	srli	s2,s2,0x20
  20:	090e                	slli	s2,s2,0x3
  22:	05c1                	addi	a1,a1,16
  24:	992e                	add	s2,s2,a1
    fprintf(2, "usage: kill pid...\n");
    exit(1);
  }
  for(i=1; i<argc; i++)
    kill(atoi(argv[i]));
  26:	6088                	ld	a0,0(s1)
  28:	00000097          	auipc	ra,0x0
  2c:	1c8080e7          	jalr	456(ra) # 1f0 <atoi>
  30:	00000097          	auipc	ra,0x0
  34:	2ec080e7          	jalr	748(ra) # 31c <kill>
  for(i=1; i<argc; i++)
  38:	04a1                	addi	s1,s1,8
  3a:	ff2496e3          	bne	s1,s2,26 <main+0x26>
  exit(0);
  3e:	4501                	li	a0,0
  40:	00000097          	auipc	ra,0x0
  44:	2ac080e7          	jalr	684(ra) # 2ec <exit>
    fprintf(2, "usage: kill pid...\n");
  48:	00000597          	auipc	a1,0x0
  4c:	7d858593          	addi	a1,a1,2008 # 820 <malloc+0xee>
  50:	4509                	li	a0,2
  52:	00000097          	auipc	ra,0x0
  56:	5f4080e7          	jalr	1524(ra) # 646 <fprintf>
    exit(1);
  5a:	4505                	li	a0,1
  5c:	00000097          	auipc	ra,0x0
  60:	290080e7          	jalr	656(ra) # 2ec <exit>

0000000000000064 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  64:	1141                	addi	sp,sp,-16
  66:	e406                	sd	ra,8(sp)
  68:	e022                	sd	s0,0(sp)
  6a:	0800                	addi	s0,sp,16
  extern int main();
  main();
  6c:	00000097          	auipc	ra,0x0
  70:	f94080e7          	jalr	-108(ra) # 0 <main>
  exit(0);
  74:	4501                	li	a0,0
  76:	00000097          	auipc	ra,0x0
  7a:	276080e7          	jalr	630(ra) # 2ec <exit>

000000000000007e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  7e:	1141                	addi	sp,sp,-16
  80:	e422                	sd	s0,8(sp)
  82:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  84:	87aa                	mv	a5,a0
  86:	0585                	addi	a1,a1,1
  88:	0785                	addi	a5,a5,1
  8a:	fff5c703          	lbu	a4,-1(a1)
  8e:	fee78fa3          	sb	a4,-1(a5)
  92:	fb75                	bnez	a4,86 <strcpy+0x8>
    ;
  return os;
}
  94:	6422                	ld	s0,8(sp)
  96:	0141                	addi	sp,sp,16
  98:	8082                	ret

000000000000009a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  9a:	1141                	addi	sp,sp,-16
  9c:	e422                	sd	s0,8(sp)
  9e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  a0:	00054783          	lbu	a5,0(a0)
  a4:	cb91                	beqz	a5,b8 <strcmp+0x1e>
  a6:	0005c703          	lbu	a4,0(a1)
  aa:	00f71763          	bne	a4,a5,b8 <strcmp+0x1e>
    p++, q++;
  ae:	0505                	addi	a0,a0,1
  b0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  b2:	00054783          	lbu	a5,0(a0)
  b6:	fbe5                	bnez	a5,a6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  b8:	0005c503          	lbu	a0,0(a1)
}
  bc:	40a7853b          	subw	a0,a5,a0
  c0:	6422                	ld	s0,8(sp)
  c2:	0141                	addi	sp,sp,16
  c4:	8082                	ret

00000000000000c6 <strlen>:

uint
strlen(const char *s)
{
  c6:	1141                	addi	sp,sp,-16
  c8:	e422                	sd	s0,8(sp)
  ca:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  cc:	00054783          	lbu	a5,0(a0)
  d0:	cf91                	beqz	a5,ec <strlen+0x26>
  d2:	0505                	addi	a0,a0,1
  d4:	87aa                	mv	a5,a0
  d6:	4685                	li	a3,1
  d8:	9e89                	subw	a3,a3,a0
  da:	00f6853b          	addw	a0,a3,a5
  de:	0785                	addi	a5,a5,1
  e0:	fff7c703          	lbu	a4,-1(a5)
  e4:	fb7d                	bnez	a4,da <strlen+0x14>
    ;
  return n;
}
  e6:	6422                	ld	s0,8(sp)
  e8:	0141                	addi	sp,sp,16
  ea:	8082                	ret
  for(n = 0; s[n]; n++)
  ec:	4501                	li	a0,0
  ee:	bfe5                	j	e6 <strlen+0x20>

00000000000000f0 <memset>:

void*
memset(void *dst, int c, uint n)
{
  f0:	1141                	addi	sp,sp,-16
  f2:	e422                	sd	s0,8(sp)
  f4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  f6:	ca19                	beqz	a2,10c <memset+0x1c>
  f8:	87aa                	mv	a5,a0
  fa:	1602                	slli	a2,a2,0x20
  fc:	9201                	srli	a2,a2,0x20
  fe:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 102:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 106:	0785                	addi	a5,a5,1
 108:	fee79de3          	bne	a5,a4,102 <memset+0x12>
  }
  return dst;
}
 10c:	6422                	ld	s0,8(sp)
 10e:	0141                	addi	sp,sp,16
 110:	8082                	ret

0000000000000112 <strchr>:

char*
strchr(const char *s, char c)
{
 112:	1141                	addi	sp,sp,-16
 114:	e422                	sd	s0,8(sp)
 116:	0800                	addi	s0,sp,16
  for(; *s; s++)
 118:	00054783          	lbu	a5,0(a0)
 11c:	cb99                	beqz	a5,132 <strchr+0x20>
    if(*s == c)
 11e:	00f58763          	beq	a1,a5,12c <strchr+0x1a>
  for(; *s; s++)
 122:	0505                	addi	a0,a0,1
 124:	00054783          	lbu	a5,0(a0)
 128:	fbfd                	bnez	a5,11e <strchr+0xc>
      return (char*)s;
  return 0;
 12a:	4501                	li	a0,0
}
 12c:	6422                	ld	s0,8(sp)
 12e:	0141                	addi	sp,sp,16
 130:	8082                	ret
  return 0;
 132:	4501                	li	a0,0
 134:	bfe5                	j	12c <strchr+0x1a>

0000000000000136 <gets>:

char*
gets(char *buf, int max)
{
 136:	711d                	addi	sp,sp,-96
 138:	ec86                	sd	ra,88(sp)
 13a:	e8a2                	sd	s0,80(sp)
 13c:	e4a6                	sd	s1,72(sp)
 13e:	e0ca                	sd	s2,64(sp)
 140:	fc4e                	sd	s3,56(sp)
 142:	f852                	sd	s4,48(sp)
 144:	f456                	sd	s5,40(sp)
 146:	f05a                	sd	s6,32(sp)
 148:	ec5e                	sd	s7,24(sp)
 14a:	1080                	addi	s0,sp,96
 14c:	8baa                	mv	s7,a0
 14e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 150:	892a                	mv	s2,a0
 152:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 154:	4aa9                	li	s5,10
 156:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 158:	89a6                	mv	s3,s1
 15a:	2485                	addiw	s1,s1,1
 15c:	0344d863          	bge	s1,s4,18c <gets+0x56>
    cc = read(0, &c, 1);
 160:	4605                	li	a2,1
 162:	faf40593          	addi	a1,s0,-81
 166:	4501                	li	a0,0
 168:	00000097          	auipc	ra,0x0
 16c:	19c080e7          	jalr	412(ra) # 304 <read>
    if(cc < 1)
 170:	00a05e63          	blez	a0,18c <gets+0x56>
    buf[i++] = c;
 174:	faf44783          	lbu	a5,-81(s0)
 178:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 17c:	01578763          	beq	a5,s5,18a <gets+0x54>
 180:	0905                	addi	s2,s2,1
 182:	fd679be3          	bne	a5,s6,158 <gets+0x22>
  for(i=0; i+1 < max; ){
 186:	89a6                	mv	s3,s1
 188:	a011                	j	18c <gets+0x56>
 18a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 18c:	99de                	add	s3,s3,s7
 18e:	00098023          	sb	zero,0(s3)
  return buf;
}
 192:	855e                	mv	a0,s7
 194:	60e6                	ld	ra,88(sp)
 196:	6446                	ld	s0,80(sp)
 198:	64a6                	ld	s1,72(sp)
 19a:	6906                	ld	s2,64(sp)
 19c:	79e2                	ld	s3,56(sp)
 19e:	7a42                	ld	s4,48(sp)
 1a0:	7aa2                	ld	s5,40(sp)
 1a2:	7b02                	ld	s6,32(sp)
 1a4:	6be2                	ld	s7,24(sp)
 1a6:	6125                	addi	sp,sp,96
 1a8:	8082                	ret

00000000000001aa <stat>:

int
stat(const char *n, struct stat *st)
{
 1aa:	1101                	addi	sp,sp,-32
 1ac:	ec06                	sd	ra,24(sp)
 1ae:	e822                	sd	s0,16(sp)
 1b0:	e426                	sd	s1,8(sp)
 1b2:	e04a                	sd	s2,0(sp)
 1b4:	1000                	addi	s0,sp,32
 1b6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1b8:	4581                	li	a1,0
 1ba:	00000097          	auipc	ra,0x0
 1be:	172080e7          	jalr	370(ra) # 32c <open>
  if(fd < 0)
 1c2:	02054563          	bltz	a0,1ec <stat+0x42>
 1c6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1c8:	85ca                	mv	a1,s2
 1ca:	00000097          	auipc	ra,0x0
 1ce:	17a080e7          	jalr	378(ra) # 344 <fstat>
 1d2:	892a                	mv	s2,a0
  close(fd);
 1d4:	8526                	mv	a0,s1
 1d6:	00000097          	auipc	ra,0x0
 1da:	13e080e7          	jalr	318(ra) # 314 <close>
  return r;
}
 1de:	854a                	mv	a0,s2
 1e0:	60e2                	ld	ra,24(sp)
 1e2:	6442                	ld	s0,16(sp)
 1e4:	64a2                	ld	s1,8(sp)
 1e6:	6902                	ld	s2,0(sp)
 1e8:	6105                	addi	sp,sp,32
 1ea:	8082                	ret
    return -1;
 1ec:	597d                	li	s2,-1
 1ee:	bfc5                	j	1de <stat+0x34>

00000000000001f0 <atoi>:

int
atoi(const char *s)
{
 1f0:	1141                	addi	sp,sp,-16
 1f2:	e422                	sd	s0,8(sp)
 1f4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1f6:	00054603          	lbu	a2,0(a0)
 1fa:	fd06079b          	addiw	a5,a2,-48
 1fe:	0ff7f793          	andi	a5,a5,255
 202:	4725                	li	a4,9
 204:	02f76963          	bltu	a4,a5,236 <atoi+0x46>
 208:	86aa                	mv	a3,a0
  n = 0;
 20a:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 20c:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 20e:	0685                	addi	a3,a3,1
 210:	0025179b          	slliw	a5,a0,0x2
 214:	9fa9                	addw	a5,a5,a0
 216:	0017979b          	slliw	a5,a5,0x1
 21a:	9fb1                	addw	a5,a5,a2
 21c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 220:	0006c603          	lbu	a2,0(a3)
 224:	fd06071b          	addiw	a4,a2,-48
 228:	0ff77713          	andi	a4,a4,255
 22c:	fee5f1e3          	bgeu	a1,a4,20e <atoi+0x1e>
  return n;
}
 230:	6422                	ld	s0,8(sp)
 232:	0141                	addi	sp,sp,16
 234:	8082                	ret
  n = 0;
 236:	4501                	li	a0,0
 238:	bfe5                	j	230 <atoi+0x40>

000000000000023a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 23a:	1141                	addi	sp,sp,-16
 23c:	e422                	sd	s0,8(sp)
 23e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 240:	02b57463          	bgeu	a0,a1,268 <memmove+0x2e>
    while(n-- > 0)
 244:	00c05f63          	blez	a2,262 <memmove+0x28>
 248:	1602                	slli	a2,a2,0x20
 24a:	9201                	srli	a2,a2,0x20
 24c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 250:	872a                	mv	a4,a0
      *dst++ = *src++;
 252:	0585                	addi	a1,a1,1
 254:	0705                	addi	a4,a4,1
 256:	fff5c683          	lbu	a3,-1(a1)
 25a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 25e:	fee79ae3          	bne	a5,a4,252 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 262:	6422                	ld	s0,8(sp)
 264:	0141                	addi	sp,sp,16
 266:	8082                	ret
    dst += n;
 268:	00c50733          	add	a4,a0,a2
    src += n;
 26c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 26e:	fec05ae3          	blez	a2,262 <memmove+0x28>
 272:	fff6079b          	addiw	a5,a2,-1
 276:	1782                	slli	a5,a5,0x20
 278:	9381                	srli	a5,a5,0x20
 27a:	fff7c793          	not	a5,a5
 27e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 280:	15fd                	addi	a1,a1,-1
 282:	177d                	addi	a4,a4,-1
 284:	0005c683          	lbu	a3,0(a1)
 288:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 28c:	fee79ae3          	bne	a5,a4,280 <memmove+0x46>
 290:	bfc9                	j	262 <memmove+0x28>

0000000000000292 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 292:	1141                	addi	sp,sp,-16
 294:	e422                	sd	s0,8(sp)
 296:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 298:	ca05                	beqz	a2,2c8 <memcmp+0x36>
 29a:	fff6069b          	addiw	a3,a2,-1
 29e:	1682                	slli	a3,a3,0x20
 2a0:	9281                	srli	a3,a3,0x20
 2a2:	0685                	addi	a3,a3,1
 2a4:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2a6:	00054783          	lbu	a5,0(a0)
 2aa:	0005c703          	lbu	a4,0(a1)
 2ae:	00e79863          	bne	a5,a4,2be <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2b2:	0505                	addi	a0,a0,1
    p2++;
 2b4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2b6:	fed518e3          	bne	a0,a3,2a6 <memcmp+0x14>
  }
  return 0;
 2ba:	4501                	li	a0,0
 2bc:	a019                	j	2c2 <memcmp+0x30>
      return *p1 - *p2;
 2be:	40e7853b          	subw	a0,a5,a4
}
 2c2:	6422                	ld	s0,8(sp)
 2c4:	0141                	addi	sp,sp,16
 2c6:	8082                	ret
  return 0;
 2c8:	4501                	li	a0,0
 2ca:	bfe5                	j	2c2 <memcmp+0x30>

00000000000002cc <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2cc:	1141                	addi	sp,sp,-16
 2ce:	e406                	sd	ra,8(sp)
 2d0:	e022                	sd	s0,0(sp)
 2d2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2d4:	00000097          	auipc	ra,0x0
 2d8:	f66080e7          	jalr	-154(ra) # 23a <memmove>
}
 2dc:	60a2                	ld	ra,8(sp)
 2de:	6402                	ld	s0,0(sp)
 2e0:	0141                	addi	sp,sp,16
 2e2:	8082                	ret

00000000000002e4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2e4:	4885                	li	a7,1
 ecall
 2e6:	00000073          	ecall
 ret
 2ea:	8082                	ret

00000000000002ec <exit>:
.global exit
exit:
 li a7, SYS_exit
 2ec:	4889                	li	a7,2
 ecall
 2ee:	00000073          	ecall
 ret
 2f2:	8082                	ret

00000000000002f4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2f4:	488d                	li	a7,3
 ecall
 2f6:	00000073          	ecall
 ret
 2fa:	8082                	ret

00000000000002fc <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2fc:	4891                	li	a7,4
 ecall
 2fe:	00000073          	ecall
 ret
 302:	8082                	ret

0000000000000304 <read>:
.global read
read:
 li a7, SYS_read
 304:	4895                	li	a7,5
 ecall
 306:	00000073          	ecall
 ret
 30a:	8082                	ret

000000000000030c <write>:
.global write
write:
 li a7, SYS_write
 30c:	48c1                	li	a7,16
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <close>:
.global close
close:
 li a7, SYS_close
 314:	48d5                	li	a7,21
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <kill>:
.global kill
kill:
 li a7, SYS_kill
 31c:	4899                	li	a7,6
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <exec>:
.global exec
exec:
 li a7, SYS_exec
 324:	489d                	li	a7,7
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <open>:
.global open
open:
 li a7, SYS_open
 32c:	48bd                	li	a7,15
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 334:	48c5                	li	a7,17
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 33c:	48c9                	li	a7,18
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 344:	48a1                	li	a7,8
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <link>:
.global link
link:
 li a7, SYS_link
 34c:	48cd                	li	a7,19
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 354:	48d1                	li	a7,20
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 35c:	48a5                	li	a7,9
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <dup>:
.global dup
dup:
 li a7, SYS_dup
 364:	48a9                	li	a7,10
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 36c:	48ad                	li	a7,11
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 374:	48b1                	li	a7,12
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 37c:	48b5                	li	a7,13
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 384:	48b9                	li	a7,14
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <trace>:
.global trace
trace:
 li a7, SYS_trace
 38c:	48d9                	li	a7,22
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 394:	48dd                	li	a7,23
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 39c:	1101                	addi	sp,sp,-32
 39e:	ec06                	sd	ra,24(sp)
 3a0:	e822                	sd	s0,16(sp)
 3a2:	1000                	addi	s0,sp,32
 3a4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3a8:	4605                	li	a2,1
 3aa:	fef40593          	addi	a1,s0,-17
 3ae:	00000097          	auipc	ra,0x0
 3b2:	f5e080e7          	jalr	-162(ra) # 30c <write>
}
 3b6:	60e2                	ld	ra,24(sp)
 3b8:	6442                	ld	s0,16(sp)
 3ba:	6105                	addi	sp,sp,32
 3bc:	8082                	ret

00000000000003be <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3be:	7139                	addi	sp,sp,-64
 3c0:	fc06                	sd	ra,56(sp)
 3c2:	f822                	sd	s0,48(sp)
 3c4:	f426                	sd	s1,40(sp)
 3c6:	f04a                	sd	s2,32(sp)
 3c8:	ec4e                	sd	s3,24(sp)
 3ca:	0080                	addi	s0,sp,64
 3cc:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3ce:	c299                	beqz	a3,3d4 <printint+0x16>
 3d0:	0805c863          	bltz	a1,460 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3d4:	2581                	sext.w	a1,a1
  neg = 0;
 3d6:	4881                	li	a7,0
 3d8:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3dc:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3de:	2601                	sext.w	a2,a2
 3e0:	00000517          	auipc	a0,0x0
 3e4:	46050513          	addi	a0,a0,1120 # 840 <digits>
 3e8:	883a                	mv	a6,a4
 3ea:	2705                	addiw	a4,a4,1
 3ec:	02c5f7bb          	remuw	a5,a1,a2
 3f0:	1782                	slli	a5,a5,0x20
 3f2:	9381                	srli	a5,a5,0x20
 3f4:	97aa                	add	a5,a5,a0
 3f6:	0007c783          	lbu	a5,0(a5)
 3fa:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3fe:	0005879b          	sext.w	a5,a1
 402:	02c5d5bb          	divuw	a1,a1,a2
 406:	0685                	addi	a3,a3,1
 408:	fec7f0e3          	bgeu	a5,a2,3e8 <printint+0x2a>
  if(neg)
 40c:	00088b63          	beqz	a7,422 <printint+0x64>
    buf[i++] = '-';
 410:	fd040793          	addi	a5,s0,-48
 414:	973e                	add	a4,a4,a5
 416:	02d00793          	li	a5,45
 41a:	fef70823          	sb	a5,-16(a4)
 41e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 422:	02e05863          	blez	a4,452 <printint+0x94>
 426:	fc040793          	addi	a5,s0,-64
 42a:	00e78933          	add	s2,a5,a4
 42e:	fff78993          	addi	s3,a5,-1
 432:	99ba                	add	s3,s3,a4
 434:	377d                	addiw	a4,a4,-1
 436:	1702                	slli	a4,a4,0x20
 438:	9301                	srli	a4,a4,0x20
 43a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 43e:	fff94583          	lbu	a1,-1(s2)
 442:	8526                	mv	a0,s1
 444:	00000097          	auipc	ra,0x0
 448:	f58080e7          	jalr	-168(ra) # 39c <putc>
  while(--i >= 0)
 44c:	197d                	addi	s2,s2,-1
 44e:	ff3918e3          	bne	s2,s3,43e <printint+0x80>
}
 452:	70e2                	ld	ra,56(sp)
 454:	7442                	ld	s0,48(sp)
 456:	74a2                	ld	s1,40(sp)
 458:	7902                	ld	s2,32(sp)
 45a:	69e2                	ld	s3,24(sp)
 45c:	6121                	addi	sp,sp,64
 45e:	8082                	ret
    x = -xx;
 460:	40b005bb          	negw	a1,a1
    neg = 1;
 464:	4885                	li	a7,1
    x = -xx;
 466:	bf8d                	j	3d8 <printint+0x1a>

0000000000000468 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 468:	7119                	addi	sp,sp,-128
 46a:	fc86                	sd	ra,120(sp)
 46c:	f8a2                	sd	s0,112(sp)
 46e:	f4a6                	sd	s1,104(sp)
 470:	f0ca                	sd	s2,96(sp)
 472:	ecce                	sd	s3,88(sp)
 474:	e8d2                	sd	s4,80(sp)
 476:	e4d6                	sd	s5,72(sp)
 478:	e0da                	sd	s6,64(sp)
 47a:	fc5e                	sd	s7,56(sp)
 47c:	f862                	sd	s8,48(sp)
 47e:	f466                	sd	s9,40(sp)
 480:	f06a                	sd	s10,32(sp)
 482:	ec6e                	sd	s11,24(sp)
 484:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 486:	0005c903          	lbu	s2,0(a1)
 48a:	18090f63          	beqz	s2,628 <vprintf+0x1c0>
 48e:	8aaa                	mv	s5,a0
 490:	8b32                	mv	s6,a2
 492:	00158493          	addi	s1,a1,1
  state = 0;
 496:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 498:	02500a13          	li	s4,37
      if(c == 'd'){
 49c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 4a0:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 4a4:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 4a8:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4ac:	00000b97          	auipc	s7,0x0
 4b0:	394b8b93          	addi	s7,s7,916 # 840 <digits>
 4b4:	a839                	j	4d2 <vprintf+0x6a>
        putc(fd, c);
 4b6:	85ca                	mv	a1,s2
 4b8:	8556                	mv	a0,s5
 4ba:	00000097          	auipc	ra,0x0
 4be:	ee2080e7          	jalr	-286(ra) # 39c <putc>
 4c2:	a019                	j	4c8 <vprintf+0x60>
    } else if(state == '%'){
 4c4:	01498f63          	beq	s3,s4,4e2 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4c8:	0485                	addi	s1,s1,1
 4ca:	fff4c903          	lbu	s2,-1(s1)
 4ce:	14090d63          	beqz	s2,628 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 4d2:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4d6:	fe0997e3          	bnez	s3,4c4 <vprintf+0x5c>
      if(c == '%'){
 4da:	fd479ee3          	bne	a5,s4,4b6 <vprintf+0x4e>
        state = '%';
 4de:	89be                	mv	s3,a5
 4e0:	b7e5                	j	4c8 <vprintf+0x60>
      if(c == 'd'){
 4e2:	05878063          	beq	a5,s8,522 <vprintf+0xba>
      } else if(c == 'l') {
 4e6:	05978c63          	beq	a5,s9,53e <vprintf+0xd6>
      } else if(c == 'x') {
 4ea:	07a78863          	beq	a5,s10,55a <vprintf+0xf2>
      } else if(c == 'p') {
 4ee:	09b78463          	beq	a5,s11,576 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 4f2:	07300713          	li	a4,115
 4f6:	0ce78663          	beq	a5,a4,5c2 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 4fa:	06300713          	li	a4,99
 4fe:	0ee78e63          	beq	a5,a4,5fa <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 502:	11478863          	beq	a5,s4,612 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 506:	85d2                	mv	a1,s4
 508:	8556                	mv	a0,s5
 50a:	00000097          	auipc	ra,0x0
 50e:	e92080e7          	jalr	-366(ra) # 39c <putc>
        putc(fd, c);
 512:	85ca                	mv	a1,s2
 514:	8556                	mv	a0,s5
 516:	00000097          	auipc	ra,0x0
 51a:	e86080e7          	jalr	-378(ra) # 39c <putc>
      }
      state = 0;
 51e:	4981                	li	s3,0
 520:	b765                	j	4c8 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 522:	008b0913          	addi	s2,s6,8
 526:	4685                	li	a3,1
 528:	4629                	li	a2,10
 52a:	000b2583          	lw	a1,0(s6)
 52e:	8556                	mv	a0,s5
 530:	00000097          	auipc	ra,0x0
 534:	e8e080e7          	jalr	-370(ra) # 3be <printint>
 538:	8b4a                	mv	s6,s2
      state = 0;
 53a:	4981                	li	s3,0
 53c:	b771                	j	4c8 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 53e:	008b0913          	addi	s2,s6,8
 542:	4681                	li	a3,0
 544:	4629                	li	a2,10
 546:	000b2583          	lw	a1,0(s6)
 54a:	8556                	mv	a0,s5
 54c:	00000097          	auipc	ra,0x0
 550:	e72080e7          	jalr	-398(ra) # 3be <printint>
 554:	8b4a                	mv	s6,s2
      state = 0;
 556:	4981                	li	s3,0
 558:	bf85                	j	4c8 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 55a:	008b0913          	addi	s2,s6,8
 55e:	4681                	li	a3,0
 560:	4641                	li	a2,16
 562:	000b2583          	lw	a1,0(s6)
 566:	8556                	mv	a0,s5
 568:	00000097          	auipc	ra,0x0
 56c:	e56080e7          	jalr	-426(ra) # 3be <printint>
 570:	8b4a                	mv	s6,s2
      state = 0;
 572:	4981                	li	s3,0
 574:	bf91                	j	4c8 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 576:	008b0793          	addi	a5,s6,8
 57a:	f8f43423          	sd	a5,-120(s0)
 57e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 582:	03000593          	li	a1,48
 586:	8556                	mv	a0,s5
 588:	00000097          	auipc	ra,0x0
 58c:	e14080e7          	jalr	-492(ra) # 39c <putc>
  putc(fd, 'x');
 590:	85ea                	mv	a1,s10
 592:	8556                	mv	a0,s5
 594:	00000097          	auipc	ra,0x0
 598:	e08080e7          	jalr	-504(ra) # 39c <putc>
 59c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 59e:	03c9d793          	srli	a5,s3,0x3c
 5a2:	97de                	add	a5,a5,s7
 5a4:	0007c583          	lbu	a1,0(a5)
 5a8:	8556                	mv	a0,s5
 5aa:	00000097          	auipc	ra,0x0
 5ae:	df2080e7          	jalr	-526(ra) # 39c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5b2:	0992                	slli	s3,s3,0x4
 5b4:	397d                	addiw	s2,s2,-1
 5b6:	fe0914e3          	bnez	s2,59e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 5ba:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 5be:	4981                	li	s3,0
 5c0:	b721                	j	4c8 <vprintf+0x60>
        s = va_arg(ap, char*);
 5c2:	008b0993          	addi	s3,s6,8
 5c6:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 5ca:	02090163          	beqz	s2,5ec <vprintf+0x184>
        while(*s != 0){
 5ce:	00094583          	lbu	a1,0(s2)
 5d2:	c9a1                	beqz	a1,622 <vprintf+0x1ba>
          putc(fd, *s);
 5d4:	8556                	mv	a0,s5
 5d6:	00000097          	auipc	ra,0x0
 5da:	dc6080e7          	jalr	-570(ra) # 39c <putc>
          s++;
 5de:	0905                	addi	s2,s2,1
        while(*s != 0){
 5e0:	00094583          	lbu	a1,0(s2)
 5e4:	f9e5                	bnez	a1,5d4 <vprintf+0x16c>
        s = va_arg(ap, char*);
 5e6:	8b4e                	mv	s6,s3
      state = 0;
 5e8:	4981                	li	s3,0
 5ea:	bdf9                	j	4c8 <vprintf+0x60>
          s = "(null)";
 5ec:	00000917          	auipc	s2,0x0
 5f0:	24c90913          	addi	s2,s2,588 # 838 <malloc+0x106>
        while(*s != 0){
 5f4:	02800593          	li	a1,40
 5f8:	bff1                	j	5d4 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 5fa:	008b0913          	addi	s2,s6,8
 5fe:	000b4583          	lbu	a1,0(s6)
 602:	8556                	mv	a0,s5
 604:	00000097          	auipc	ra,0x0
 608:	d98080e7          	jalr	-616(ra) # 39c <putc>
 60c:	8b4a                	mv	s6,s2
      state = 0;
 60e:	4981                	li	s3,0
 610:	bd65                	j	4c8 <vprintf+0x60>
        putc(fd, c);
 612:	85d2                	mv	a1,s4
 614:	8556                	mv	a0,s5
 616:	00000097          	auipc	ra,0x0
 61a:	d86080e7          	jalr	-634(ra) # 39c <putc>
      state = 0;
 61e:	4981                	li	s3,0
 620:	b565                	j	4c8 <vprintf+0x60>
        s = va_arg(ap, char*);
 622:	8b4e                	mv	s6,s3
      state = 0;
 624:	4981                	li	s3,0
 626:	b54d                	j	4c8 <vprintf+0x60>
    }
  }
}
 628:	70e6                	ld	ra,120(sp)
 62a:	7446                	ld	s0,112(sp)
 62c:	74a6                	ld	s1,104(sp)
 62e:	7906                	ld	s2,96(sp)
 630:	69e6                	ld	s3,88(sp)
 632:	6a46                	ld	s4,80(sp)
 634:	6aa6                	ld	s5,72(sp)
 636:	6b06                	ld	s6,64(sp)
 638:	7be2                	ld	s7,56(sp)
 63a:	7c42                	ld	s8,48(sp)
 63c:	7ca2                	ld	s9,40(sp)
 63e:	7d02                	ld	s10,32(sp)
 640:	6de2                	ld	s11,24(sp)
 642:	6109                	addi	sp,sp,128
 644:	8082                	ret

0000000000000646 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 646:	715d                	addi	sp,sp,-80
 648:	ec06                	sd	ra,24(sp)
 64a:	e822                	sd	s0,16(sp)
 64c:	1000                	addi	s0,sp,32
 64e:	e010                	sd	a2,0(s0)
 650:	e414                	sd	a3,8(s0)
 652:	e818                	sd	a4,16(s0)
 654:	ec1c                	sd	a5,24(s0)
 656:	03043023          	sd	a6,32(s0)
 65a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 65e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 662:	8622                	mv	a2,s0
 664:	00000097          	auipc	ra,0x0
 668:	e04080e7          	jalr	-508(ra) # 468 <vprintf>
}
 66c:	60e2                	ld	ra,24(sp)
 66e:	6442                	ld	s0,16(sp)
 670:	6161                	addi	sp,sp,80
 672:	8082                	ret

0000000000000674 <printf>:

void
printf(const char *fmt, ...)
{
 674:	711d                	addi	sp,sp,-96
 676:	ec06                	sd	ra,24(sp)
 678:	e822                	sd	s0,16(sp)
 67a:	1000                	addi	s0,sp,32
 67c:	e40c                	sd	a1,8(s0)
 67e:	e810                	sd	a2,16(s0)
 680:	ec14                	sd	a3,24(s0)
 682:	f018                	sd	a4,32(s0)
 684:	f41c                	sd	a5,40(s0)
 686:	03043823          	sd	a6,48(s0)
 68a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 68e:	00840613          	addi	a2,s0,8
 692:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 696:	85aa                	mv	a1,a0
 698:	4505                	li	a0,1
 69a:	00000097          	auipc	ra,0x0
 69e:	dce080e7          	jalr	-562(ra) # 468 <vprintf>
}
 6a2:	60e2                	ld	ra,24(sp)
 6a4:	6442                	ld	s0,16(sp)
 6a6:	6125                	addi	sp,sp,96
 6a8:	8082                	ret

00000000000006aa <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6aa:	1141                	addi	sp,sp,-16
 6ac:	e422                	sd	s0,8(sp)
 6ae:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6b0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6b4:	00001797          	auipc	a5,0x1
 6b8:	94c7b783          	ld	a5,-1716(a5) # 1000 <freep>
 6bc:	a805                	j	6ec <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6be:	4618                	lw	a4,8(a2)
 6c0:	9db9                	addw	a1,a1,a4
 6c2:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6c6:	6398                	ld	a4,0(a5)
 6c8:	6318                	ld	a4,0(a4)
 6ca:	fee53823          	sd	a4,-16(a0)
 6ce:	a091                	j	712 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6d0:	ff852703          	lw	a4,-8(a0)
 6d4:	9e39                	addw	a2,a2,a4
 6d6:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 6d8:	ff053703          	ld	a4,-16(a0)
 6dc:	e398                	sd	a4,0(a5)
 6de:	a099                	j	724 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6e0:	6398                	ld	a4,0(a5)
 6e2:	00e7e463          	bltu	a5,a4,6ea <free+0x40>
 6e6:	00e6ea63          	bltu	a3,a4,6fa <free+0x50>
{
 6ea:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ec:	fed7fae3          	bgeu	a5,a3,6e0 <free+0x36>
 6f0:	6398                	ld	a4,0(a5)
 6f2:	00e6e463          	bltu	a3,a4,6fa <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6f6:	fee7eae3          	bltu	a5,a4,6ea <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 6fa:	ff852583          	lw	a1,-8(a0)
 6fe:	6390                	ld	a2,0(a5)
 700:	02059713          	slli	a4,a1,0x20
 704:	9301                	srli	a4,a4,0x20
 706:	0712                	slli	a4,a4,0x4
 708:	9736                	add	a4,a4,a3
 70a:	fae60ae3          	beq	a2,a4,6be <free+0x14>
    bp->s.ptr = p->s.ptr;
 70e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 712:	4790                	lw	a2,8(a5)
 714:	02061713          	slli	a4,a2,0x20
 718:	9301                	srli	a4,a4,0x20
 71a:	0712                	slli	a4,a4,0x4
 71c:	973e                	add	a4,a4,a5
 71e:	fae689e3          	beq	a3,a4,6d0 <free+0x26>
  } else
    p->s.ptr = bp;
 722:	e394                	sd	a3,0(a5)
  freep = p;
 724:	00001717          	auipc	a4,0x1
 728:	8cf73e23          	sd	a5,-1828(a4) # 1000 <freep>
}
 72c:	6422                	ld	s0,8(sp)
 72e:	0141                	addi	sp,sp,16
 730:	8082                	ret

0000000000000732 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 732:	7139                	addi	sp,sp,-64
 734:	fc06                	sd	ra,56(sp)
 736:	f822                	sd	s0,48(sp)
 738:	f426                	sd	s1,40(sp)
 73a:	f04a                	sd	s2,32(sp)
 73c:	ec4e                	sd	s3,24(sp)
 73e:	e852                	sd	s4,16(sp)
 740:	e456                	sd	s5,8(sp)
 742:	e05a                	sd	s6,0(sp)
 744:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 746:	02051493          	slli	s1,a0,0x20
 74a:	9081                	srli	s1,s1,0x20
 74c:	04bd                	addi	s1,s1,15
 74e:	8091                	srli	s1,s1,0x4
 750:	0014899b          	addiw	s3,s1,1
 754:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 756:	00001517          	auipc	a0,0x1
 75a:	8aa53503          	ld	a0,-1878(a0) # 1000 <freep>
 75e:	c515                	beqz	a0,78a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 760:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 762:	4798                	lw	a4,8(a5)
 764:	02977f63          	bgeu	a4,s1,7a2 <malloc+0x70>
 768:	8a4e                	mv	s4,s3
 76a:	0009871b          	sext.w	a4,s3
 76e:	6685                	lui	a3,0x1
 770:	00d77363          	bgeu	a4,a3,776 <malloc+0x44>
 774:	6a05                	lui	s4,0x1
 776:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 77a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 77e:	00001917          	auipc	s2,0x1
 782:	88290913          	addi	s2,s2,-1918 # 1000 <freep>
  if(p == (char*)-1)
 786:	5afd                	li	s5,-1
 788:	a88d                	j	7fa <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 78a:	00001797          	auipc	a5,0x1
 78e:	88678793          	addi	a5,a5,-1914 # 1010 <base>
 792:	00001717          	auipc	a4,0x1
 796:	86f73723          	sd	a5,-1938(a4) # 1000 <freep>
 79a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 79c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7a0:	b7e1                	j	768 <malloc+0x36>
      if(p->s.size == nunits)
 7a2:	02e48b63          	beq	s1,a4,7d8 <malloc+0xa6>
        p->s.size -= nunits;
 7a6:	4137073b          	subw	a4,a4,s3
 7aa:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7ac:	1702                	slli	a4,a4,0x20
 7ae:	9301                	srli	a4,a4,0x20
 7b0:	0712                	slli	a4,a4,0x4
 7b2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7b4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7b8:	00001717          	auipc	a4,0x1
 7bc:	84a73423          	sd	a0,-1976(a4) # 1000 <freep>
      return (void*)(p + 1);
 7c0:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7c4:	70e2                	ld	ra,56(sp)
 7c6:	7442                	ld	s0,48(sp)
 7c8:	74a2                	ld	s1,40(sp)
 7ca:	7902                	ld	s2,32(sp)
 7cc:	69e2                	ld	s3,24(sp)
 7ce:	6a42                	ld	s4,16(sp)
 7d0:	6aa2                	ld	s5,8(sp)
 7d2:	6b02                	ld	s6,0(sp)
 7d4:	6121                	addi	sp,sp,64
 7d6:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7d8:	6398                	ld	a4,0(a5)
 7da:	e118                	sd	a4,0(a0)
 7dc:	bff1                	j	7b8 <malloc+0x86>
  hp->s.size = nu;
 7de:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7e2:	0541                	addi	a0,a0,16
 7e4:	00000097          	auipc	ra,0x0
 7e8:	ec6080e7          	jalr	-314(ra) # 6aa <free>
  return freep;
 7ec:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7f0:	d971                	beqz	a0,7c4 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7f2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7f4:	4798                	lw	a4,8(a5)
 7f6:	fa9776e3          	bgeu	a4,s1,7a2 <malloc+0x70>
    if(p == freep)
 7fa:	00093703          	ld	a4,0(s2)
 7fe:	853e                	mv	a0,a5
 800:	fef719e3          	bne	a4,a5,7f2 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 804:	8552                	mv	a0,s4
 806:	00000097          	auipc	ra,0x0
 80a:	b6e080e7          	jalr	-1170(ra) # 374 <sbrk>
  if(p == (char*)-1)
 80e:	fd5518e3          	bne	a0,s5,7de <malloc+0xac>
        return 0;
 812:	4501                	li	a0,0
 814:	bf45                	j	7c4 <malloc+0x92>

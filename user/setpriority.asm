
user/_setpriority:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <check_priority_range>:
#include "../kernel/types.h"
#include "../kernel/param.h"
#include "../kernel/stat.h"
#include "./user.h"

int check_priority_range(int priority){
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16

    if(priority >= 0 || priority <= 100){
        return 1;
    }
    return 0;
}
   6:	4505                	li	a0,1
   8:	6422                	ld	s0,8(sp)
   a:	0141                	addi	sp,sp,16
   c:	8082                	ret

000000000000000e <main>:

int main(int argc, char *argv[]){
   e:	1101                	addi	sp,sp,-32
  10:	ec06                	sd	ra,24(sp)
  12:	e822                	sd	s0,16(sp)
  14:	e426                	sd	s1,8(sp)
  16:	e04a                	sd	s2,0(sp)
  18:	1000                	addi	s0,sp,32
    
    if(argc < 3){
  1a:	4789                	li	a5,2
  1c:	02a7c963          	blt	a5,a0,4e <main+0x40>
        fprintf(2, "Incorrect Input !\n");
  20:	00001597          	auipc	a1,0x1
  24:	84058593          	addi	a1,a1,-1984 # 860 <malloc+0xee>
  28:	4509                	li	a0,2
  2a:	00000097          	auipc	ra,0x0
  2e:	65c080e7          	jalr	1628(ra) # 686 <fprintf>
        fprintf(2, "Correct usage: setpriority <priority> <pid>\n");
  32:	00001597          	auipc	a1,0x1
  36:	84658593          	addi	a1,a1,-1978 # 878 <malloc+0x106>
  3a:	4509                	li	a0,2
  3c:	00000097          	auipc	ra,0x0
  40:	64a080e7          	jalr	1610(ra) # 686 <fprintf>
        exit(1);
  44:	4505                	li	a0,1
  46:	00000097          	auipc	ra,0x0
  4a:	2c6080e7          	jalr	710(ra) # 30c <exit>
  4e:	84ae                	mv	s1,a1
    }

    int priority = atoi(argv[1]);
  50:	6588                	ld	a0,8(a1)
  52:	00000097          	auipc	ra,0x0
  56:	1ba080e7          	jalr	442(ra) # 20c <atoi>
  5a:	892a                	mv	s2,a0
    int pid = atoi(argv[2]);
  5c:	6888                	ld	a0,16(s1)
  5e:	00000097          	auipc	ra,0x0
  62:	1ae080e7          	jalr	430(ra) # 20c <atoi>
  66:	85aa                	mv	a1,a0
        fprintf(2, "Incorrect Range !\n");
        fprintf(2, "Correct Range: [0,100]\n");
        exit(1);
    }

    setpriority(priority, pid);
  68:	854a                	mv	a0,s2
  6a:	00000097          	auipc	ra,0x0
  6e:	36a080e7          	jalr	874(ra) # 3d4 <setpriority>
    exit(1);
  72:	4505                	li	a0,1
  74:	00000097          	auipc	ra,0x0
  78:	298080e7          	jalr	664(ra) # 30c <exit>

000000000000007c <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  7c:	1141                	addi	sp,sp,-16
  7e:	e406                	sd	ra,8(sp)
  80:	e022                	sd	s0,0(sp)
  82:	0800                	addi	s0,sp,16
  extern int main();
  main();
  84:	00000097          	auipc	ra,0x0
  88:	f8a080e7          	jalr	-118(ra) # e <main>
  exit(0);
  8c:	4501                	li	a0,0
  8e:	00000097          	auipc	ra,0x0
  92:	27e080e7          	jalr	638(ra) # 30c <exit>

0000000000000096 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  96:	1141                	addi	sp,sp,-16
  98:	e422                	sd	s0,8(sp)
  9a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  9c:	87aa                	mv	a5,a0
  9e:	0585                	addi	a1,a1,1
  a0:	0785                	addi	a5,a5,1
  a2:	fff5c703          	lbu	a4,-1(a1)
  a6:	fee78fa3          	sb	a4,-1(a5)
  aa:	fb75                	bnez	a4,9e <strcpy+0x8>
    ;
  return os;
}
  ac:	6422                	ld	s0,8(sp)
  ae:	0141                	addi	sp,sp,16
  b0:	8082                	ret

00000000000000b2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  b2:	1141                	addi	sp,sp,-16
  b4:	e422                	sd	s0,8(sp)
  b6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  b8:	00054783          	lbu	a5,0(a0)
  bc:	cb91                	beqz	a5,d0 <strcmp+0x1e>
  be:	0005c703          	lbu	a4,0(a1)
  c2:	00f71763          	bne	a4,a5,d0 <strcmp+0x1e>
    p++, q++;
  c6:	0505                	addi	a0,a0,1
  c8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  ca:	00054783          	lbu	a5,0(a0)
  ce:	fbe5                	bnez	a5,be <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  d0:	0005c503          	lbu	a0,0(a1)
}
  d4:	40a7853b          	subw	a0,a5,a0
  d8:	6422                	ld	s0,8(sp)
  da:	0141                	addi	sp,sp,16
  dc:	8082                	ret

00000000000000de <strlen>:

uint
strlen(const char *s)
{
  de:	1141                	addi	sp,sp,-16
  e0:	e422                	sd	s0,8(sp)
  e2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  e4:	00054783          	lbu	a5,0(a0)
  e8:	cf91                	beqz	a5,104 <strlen+0x26>
  ea:	0505                	addi	a0,a0,1
  ec:	87aa                	mv	a5,a0
  ee:	4685                	li	a3,1
  f0:	9e89                	subw	a3,a3,a0
  f2:	00f6853b          	addw	a0,a3,a5
  f6:	0785                	addi	a5,a5,1
  f8:	fff7c703          	lbu	a4,-1(a5)
  fc:	fb7d                	bnez	a4,f2 <strlen+0x14>
    ;
  return n;
}
  fe:	6422                	ld	s0,8(sp)
 100:	0141                	addi	sp,sp,16
 102:	8082                	ret
  for(n = 0; s[n]; n++)
 104:	4501                	li	a0,0
 106:	bfe5                	j	fe <strlen+0x20>

0000000000000108 <memset>:

void*
memset(void *dst, int c, uint n)
{
 108:	1141                	addi	sp,sp,-16
 10a:	e422                	sd	s0,8(sp)
 10c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 10e:	ce09                	beqz	a2,128 <memset+0x20>
 110:	87aa                	mv	a5,a0
 112:	fff6071b          	addiw	a4,a2,-1
 116:	1702                	slli	a4,a4,0x20
 118:	9301                	srli	a4,a4,0x20
 11a:	0705                	addi	a4,a4,1
 11c:	972a                	add	a4,a4,a0
    cdst[i] = c;
 11e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 122:	0785                	addi	a5,a5,1
 124:	fee79de3          	bne	a5,a4,11e <memset+0x16>
  }
  return dst;
}
 128:	6422                	ld	s0,8(sp)
 12a:	0141                	addi	sp,sp,16
 12c:	8082                	ret

000000000000012e <strchr>:

char*
strchr(const char *s, char c)
{
 12e:	1141                	addi	sp,sp,-16
 130:	e422                	sd	s0,8(sp)
 132:	0800                	addi	s0,sp,16
  for(; *s; s++)
 134:	00054783          	lbu	a5,0(a0)
 138:	cb99                	beqz	a5,14e <strchr+0x20>
    if(*s == c)
 13a:	00f58763          	beq	a1,a5,148 <strchr+0x1a>
  for(; *s; s++)
 13e:	0505                	addi	a0,a0,1
 140:	00054783          	lbu	a5,0(a0)
 144:	fbfd                	bnez	a5,13a <strchr+0xc>
      return (char*)s;
  return 0;
 146:	4501                	li	a0,0
}
 148:	6422                	ld	s0,8(sp)
 14a:	0141                	addi	sp,sp,16
 14c:	8082                	ret
  return 0;
 14e:	4501                	li	a0,0
 150:	bfe5                	j	148 <strchr+0x1a>

0000000000000152 <gets>:

char*
gets(char *buf, int max)
{
 152:	711d                	addi	sp,sp,-96
 154:	ec86                	sd	ra,88(sp)
 156:	e8a2                	sd	s0,80(sp)
 158:	e4a6                	sd	s1,72(sp)
 15a:	e0ca                	sd	s2,64(sp)
 15c:	fc4e                	sd	s3,56(sp)
 15e:	f852                	sd	s4,48(sp)
 160:	f456                	sd	s5,40(sp)
 162:	f05a                	sd	s6,32(sp)
 164:	ec5e                	sd	s7,24(sp)
 166:	1080                	addi	s0,sp,96
 168:	8baa                	mv	s7,a0
 16a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 16c:	892a                	mv	s2,a0
 16e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 170:	4aa9                	li	s5,10
 172:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 174:	89a6                	mv	s3,s1
 176:	2485                	addiw	s1,s1,1
 178:	0344d863          	bge	s1,s4,1a8 <gets+0x56>
    cc = read(0, &c, 1);
 17c:	4605                	li	a2,1
 17e:	faf40593          	addi	a1,s0,-81
 182:	4501                	li	a0,0
 184:	00000097          	auipc	ra,0x0
 188:	1a0080e7          	jalr	416(ra) # 324 <read>
    if(cc < 1)
 18c:	00a05e63          	blez	a0,1a8 <gets+0x56>
    buf[i++] = c;
 190:	faf44783          	lbu	a5,-81(s0)
 194:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 198:	01578763          	beq	a5,s5,1a6 <gets+0x54>
 19c:	0905                	addi	s2,s2,1
 19e:	fd679be3          	bne	a5,s6,174 <gets+0x22>
  for(i=0; i+1 < max; ){
 1a2:	89a6                	mv	s3,s1
 1a4:	a011                	j	1a8 <gets+0x56>
 1a6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1a8:	99de                	add	s3,s3,s7
 1aa:	00098023          	sb	zero,0(s3)
  return buf;
}
 1ae:	855e                	mv	a0,s7
 1b0:	60e6                	ld	ra,88(sp)
 1b2:	6446                	ld	s0,80(sp)
 1b4:	64a6                	ld	s1,72(sp)
 1b6:	6906                	ld	s2,64(sp)
 1b8:	79e2                	ld	s3,56(sp)
 1ba:	7a42                	ld	s4,48(sp)
 1bc:	7aa2                	ld	s5,40(sp)
 1be:	7b02                	ld	s6,32(sp)
 1c0:	6be2                	ld	s7,24(sp)
 1c2:	6125                	addi	sp,sp,96
 1c4:	8082                	ret

00000000000001c6 <stat>:

int
stat(const char *n, struct stat *st)
{
 1c6:	1101                	addi	sp,sp,-32
 1c8:	ec06                	sd	ra,24(sp)
 1ca:	e822                	sd	s0,16(sp)
 1cc:	e426                	sd	s1,8(sp)
 1ce:	e04a                	sd	s2,0(sp)
 1d0:	1000                	addi	s0,sp,32
 1d2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1d4:	4581                	li	a1,0
 1d6:	00000097          	auipc	ra,0x0
 1da:	176080e7          	jalr	374(ra) # 34c <open>
  if(fd < 0)
 1de:	02054563          	bltz	a0,208 <stat+0x42>
 1e2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1e4:	85ca                	mv	a1,s2
 1e6:	00000097          	auipc	ra,0x0
 1ea:	17e080e7          	jalr	382(ra) # 364 <fstat>
 1ee:	892a                	mv	s2,a0
  close(fd);
 1f0:	8526                	mv	a0,s1
 1f2:	00000097          	auipc	ra,0x0
 1f6:	142080e7          	jalr	322(ra) # 334 <close>
  return r;
}
 1fa:	854a                	mv	a0,s2
 1fc:	60e2                	ld	ra,24(sp)
 1fe:	6442                	ld	s0,16(sp)
 200:	64a2                	ld	s1,8(sp)
 202:	6902                	ld	s2,0(sp)
 204:	6105                	addi	sp,sp,32
 206:	8082                	ret
    return -1;
 208:	597d                	li	s2,-1
 20a:	bfc5                	j	1fa <stat+0x34>

000000000000020c <atoi>:

int
atoi(const char *s)
{
 20c:	1141                	addi	sp,sp,-16
 20e:	e422                	sd	s0,8(sp)
 210:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 212:	00054603          	lbu	a2,0(a0)
 216:	fd06079b          	addiw	a5,a2,-48
 21a:	0ff7f793          	andi	a5,a5,255
 21e:	4725                	li	a4,9
 220:	02f76963          	bltu	a4,a5,252 <atoi+0x46>
 224:	86aa                	mv	a3,a0
  n = 0;
 226:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 228:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 22a:	0685                	addi	a3,a3,1
 22c:	0025179b          	slliw	a5,a0,0x2
 230:	9fa9                	addw	a5,a5,a0
 232:	0017979b          	slliw	a5,a5,0x1
 236:	9fb1                	addw	a5,a5,a2
 238:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 23c:	0006c603          	lbu	a2,0(a3)
 240:	fd06071b          	addiw	a4,a2,-48
 244:	0ff77713          	andi	a4,a4,255
 248:	fee5f1e3          	bgeu	a1,a4,22a <atoi+0x1e>
  return n;
}
 24c:	6422                	ld	s0,8(sp)
 24e:	0141                	addi	sp,sp,16
 250:	8082                	ret
  n = 0;
 252:	4501                	li	a0,0
 254:	bfe5                	j	24c <atoi+0x40>

0000000000000256 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 256:	1141                	addi	sp,sp,-16
 258:	e422                	sd	s0,8(sp)
 25a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 25c:	02b57663          	bgeu	a0,a1,288 <memmove+0x32>
    while(n-- > 0)
 260:	02c05163          	blez	a2,282 <memmove+0x2c>
 264:	fff6079b          	addiw	a5,a2,-1
 268:	1782                	slli	a5,a5,0x20
 26a:	9381                	srli	a5,a5,0x20
 26c:	0785                	addi	a5,a5,1
 26e:	97aa                	add	a5,a5,a0
  dst = vdst;
 270:	872a                	mv	a4,a0
      *dst++ = *src++;
 272:	0585                	addi	a1,a1,1
 274:	0705                	addi	a4,a4,1
 276:	fff5c683          	lbu	a3,-1(a1)
 27a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 27e:	fee79ae3          	bne	a5,a4,272 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 282:	6422                	ld	s0,8(sp)
 284:	0141                	addi	sp,sp,16
 286:	8082                	ret
    dst += n;
 288:	00c50733          	add	a4,a0,a2
    src += n;
 28c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 28e:	fec05ae3          	blez	a2,282 <memmove+0x2c>
 292:	fff6079b          	addiw	a5,a2,-1
 296:	1782                	slli	a5,a5,0x20
 298:	9381                	srli	a5,a5,0x20
 29a:	fff7c793          	not	a5,a5
 29e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2a0:	15fd                	addi	a1,a1,-1
 2a2:	177d                	addi	a4,a4,-1
 2a4:	0005c683          	lbu	a3,0(a1)
 2a8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2ac:	fee79ae3          	bne	a5,a4,2a0 <memmove+0x4a>
 2b0:	bfc9                	j	282 <memmove+0x2c>

00000000000002b2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2b2:	1141                	addi	sp,sp,-16
 2b4:	e422                	sd	s0,8(sp)
 2b6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2b8:	ca05                	beqz	a2,2e8 <memcmp+0x36>
 2ba:	fff6069b          	addiw	a3,a2,-1
 2be:	1682                	slli	a3,a3,0x20
 2c0:	9281                	srli	a3,a3,0x20
 2c2:	0685                	addi	a3,a3,1
 2c4:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2c6:	00054783          	lbu	a5,0(a0)
 2ca:	0005c703          	lbu	a4,0(a1)
 2ce:	00e79863          	bne	a5,a4,2de <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2d2:	0505                	addi	a0,a0,1
    p2++;
 2d4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2d6:	fed518e3          	bne	a0,a3,2c6 <memcmp+0x14>
  }
  return 0;
 2da:	4501                	li	a0,0
 2dc:	a019                	j	2e2 <memcmp+0x30>
      return *p1 - *p2;
 2de:	40e7853b          	subw	a0,a5,a4
}
 2e2:	6422                	ld	s0,8(sp)
 2e4:	0141                	addi	sp,sp,16
 2e6:	8082                	ret
  return 0;
 2e8:	4501                	li	a0,0
 2ea:	bfe5                	j	2e2 <memcmp+0x30>

00000000000002ec <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2ec:	1141                	addi	sp,sp,-16
 2ee:	e406                	sd	ra,8(sp)
 2f0:	e022                	sd	s0,0(sp)
 2f2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2f4:	00000097          	auipc	ra,0x0
 2f8:	f62080e7          	jalr	-158(ra) # 256 <memmove>
}
 2fc:	60a2                	ld	ra,8(sp)
 2fe:	6402                	ld	s0,0(sp)
 300:	0141                	addi	sp,sp,16
 302:	8082                	ret

0000000000000304 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 304:	4885                	li	a7,1
 ecall
 306:	00000073          	ecall
 ret
 30a:	8082                	ret

000000000000030c <exit>:
.global exit
exit:
 li a7, SYS_exit
 30c:	4889                	li	a7,2
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <wait>:
.global wait
wait:
 li a7, SYS_wait
 314:	488d                	li	a7,3
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 31c:	4891                	li	a7,4
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <read>:
.global read
read:
 li a7, SYS_read
 324:	4895                	li	a7,5
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <write>:
.global write
write:
 li a7, SYS_write
 32c:	48c1                	li	a7,16
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <close>:
.global close
close:
 li a7, SYS_close
 334:	48d5                	li	a7,21
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <kill>:
.global kill
kill:
 li a7, SYS_kill
 33c:	4899                	li	a7,6
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <exec>:
.global exec
exec:
 li a7, SYS_exec
 344:	489d                	li	a7,7
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <open>:
.global open
open:
 li a7, SYS_open
 34c:	48bd                	li	a7,15
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 354:	48c5                	li	a7,17
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 35c:	48c9                	li	a7,18
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 364:	48a1                	li	a7,8
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <link>:
.global link
link:
 li a7, SYS_link
 36c:	48cd                	li	a7,19
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 374:	48d1                	li	a7,20
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 37c:	48a5                	li	a7,9
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <dup>:
.global dup
dup:
 li a7, SYS_dup
 384:	48a9                	li	a7,10
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 38c:	48ad                	li	a7,11
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 394:	48b1                	li	a7,12
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 39c:	48b5                	li	a7,13
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3a4:	48b9                	li	a7,14
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <trace>:
.global trace
trace:
 li a7, SYS_trace
 3ac:	48d9                	li	a7,22
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 3b4:	48dd                	li	a7,23
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 3bc:	48e5                	li	a7,25
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 3c4:	48e1                	li	a7,24
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 3cc:	48e9                	li	a7,26
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 3d4:	48ed                	li	a7,27
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3dc:	1101                	addi	sp,sp,-32
 3de:	ec06                	sd	ra,24(sp)
 3e0:	e822                	sd	s0,16(sp)
 3e2:	1000                	addi	s0,sp,32
 3e4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3e8:	4605                	li	a2,1
 3ea:	fef40593          	addi	a1,s0,-17
 3ee:	00000097          	auipc	ra,0x0
 3f2:	f3e080e7          	jalr	-194(ra) # 32c <write>
}
 3f6:	60e2                	ld	ra,24(sp)
 3f8:	6442                	ld	s0,16(sp)
 3fa:	6105                	addi	sp,sp,32
 3fc:	8082                	ret

00000000000003fe <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3fe:	7139                	addi	sp,sp,-64
 400:	fc06                	sd	ra,56(sp)
 402:	f822                	sd	s0,48(sp)
 404:	f426                	sd	s1,40(sp)
 406:	f04a                	sd	s2,32(sp)
 408:	ec4e                	sd	s3,24(sp)
 40a:	0080                	addi	s0,sp,64
 40c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 40e:	c299                	beqz	a3,414 <printint+0x16>
 410:	0805c863          	bltz	a1,4a0 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 414:	2581                	sext.w	a1,a1
  neg = 0;
 416:	4881                	li	a7,0
 418:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 41c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 41e:	2601                	sext.w	a2,a2
 420:	00000517          	auipc	a0,0x0
 424:	49050513          	addi	a0,a0,1168 # 8b0 <digits>
 428:	883a                	mv	a6,a4
 42a:	2705                	addiw	a4,a4,1
 42c:	02c5f7bb          	remuw	a5,a1,a2
 430:	1782                	slli	a5,a5,0x20
 432:	9381                	srli	a5,a5,0x20
 434:	97aa                	add	a5,a5,a0
 436:	0007c783          	lbu	a5,0(a5)
 43a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 43e:	0005879b          	sext.w	a5,a1
 442:	02c5d5bb          	divuw	a1,a1,a2
 446:	0685                	addi	a3,a3,1
 448:	fec7f0e3          	bgeu	a5,a2,428 <printint+0x2a>
  if(neg)
 44c:	00088b63          	beqz	a7,462 <printint+0x64>
    buf[i++] = '-';
 450:	fd040793          	addi	a5,s0,-48
 454:	973e                	add	a4,a4,a5
 456:	02d00793          	li	a5,45
 45a:	fef70823          	sb	a5,-16(a4)
 45e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 462:	02e05863          	blez	a4,492 <printint+0x94>
 466:	fc040793          	addi	a5,s0,-64
 46a:	00e78933          	add	s2,a5,a4
 46e:	fff78993          	addi	s3,a5,-1
 472:	99ba                	add	s3,s3,a4
 474:	377d                	addiw	a4,a4,-1
 476:	1702                	slli	a4,a4,0x20
 478:	9301                	srli	a4,a4,0x20
 47a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 47e:	fff94583          	lbu	a1,-1(s2)
 482:	8526                	mv	a0,s1
 484:	00000097          	auipc	ra,0x0
 488:	f58080e7          	jalr	-168(ra) # 3dc <putc>
  while(--i >= 0)
 48c:	197d                	addi	s2,s2,-1
 48e:	ff3918e3          	bne	s2,s3,47e <printint+0x80>
}
 492:	70e2                	ld	ra,56(sp)
 494:	7442                	ld	s0,48(sp)
 496:	74a2                	ld	s1,40(sp)
 498:	7902                	ld	s2,32(sp)
 49a:	69e2                	ld	s3,24(sp)
 49c:	6121                	addi	sp,sp,64
 49e:	8082                	ret
    x = -xx;
 4a0:	40b005bb          	negw	a1,a1
    neg = 1;
 4a4:	4885                	li	a7,1
    x = -xx;
 4a6:	bf8d                	j	418 <printint+0x1a>

00000000000004a8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4a8:	7119                	addi	sp,sp,-128
 4aa:	fc86                	sd	ra,120(sp)
 4ac:	f8a2                	sd	s0,112(sp)
 4ae:	f4a6                	sd	s1,104(sp)
 4b0:	f0ca                	sd	s2,96(sp)
 4b2:	ecce                	sd	s3,88(sp)
 4b4:	e8d2                	sd	s4,80(sp)
 4b6:	e4d6                	sd	s5,72(sp)
 4b8:	e0da                	sd	s6,64(sp)
 4ba:	fc5e                	sd	s7,56(sp)
 4bc:	f862                	sd	s8,48(sp)
 4be:	f466                	sd	s9,40(sp)
 4c0:	f06a                	sd	s10,32(sp)
 4c2:	ec6e                	sd	s11,24(sp)
 4c4:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4c6:	0005c903          	lbu	s2,0(a1)
 4ca:	18090f63          	beqz	s2,668 <vprintf+0x1c0>
 4ce:	8aaa                	mv	s5,a0
 4d0:	8b32                	mv	s6,a2
 4d2:	00158493          	addi	s1,a1,1
  state = 0;
 4d6:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4d8:	02500a13          	li	s4,37
      if(c == 'd'){
 4dc:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 4e0:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 4e4:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 4e8:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4ec:	00000b97          	auipc	s7,0x0
 4f0:	3c4b8b93          	addi	s7,s7,964 # 8b0 <digits>
 4f4:	a839                	j	512 <vprintf+0x6a>
        putc(fd, c);
 4f6:	85ca                	mv	a1,s2
 4f8:	8556                	mv	a0,s5
 4fa:	00000097          	auipc	ra,0x0
 4fe:	ee2080e7          	jalr	-286(ra) # 3dc <putc>
 502:	a019                	j	508 <vprintf+0x60>
    } else if(state == '%'){
 504:	01498f63          	beq	s3,s4,522 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 508:	0485                	addi	s1,s1,1
 50a:	fff4c903          	lbu	s2,-1(s1)
 50e:	14090d63          	beqz	s2,668 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 512:	0009079b          	sext.w	a5,s2
    if(state == 0){
 516:	fe0997e3          	bnez	s3,504 <vprintf+0x5c>
      if(c == '%'){
 51a:	fd479ee3          	bne	a5,s4,4f6 <vprintf+0x4e>
        state = '%';
 51e:	89be                	mv	s3,a5
 520:	b7e5                	j	508 <vprintf+0x60>
      if(c == 'd'){
 522:	05878063          	beq	a5,s8,562 <vprintf+0xba>
      } else if(c == 'l') {
 526:	05978c63          	beq	a5,s9,57e <vprintf+0xd6>
      } else if(c == 'x') {
 52a:	07a78863          	beq	a5,s10,59a <vprintf+0xf2>
      } else if(c == 'p') {
 52e:	09b78463          	beq	a5,s11,5b6 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 532:	07300713          	li	a4,115
 536:	0ce78663          	beq	a5,a4,602 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 53a:	06300713          	li	a4,99
 53e:	0ee78e63          	beq	a5,a4,63a <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 542:	11478863          	beq	a5,s4,652 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 546:	85d2                	mv	a1,s4
 548:	8556                	mv	a0,s5
 54a:	00000097          	auipc	ra,0x0
 54e:	e92080e7          	jalr	-366(ra) # 3dc <putc>
        putc(fd, c);
 552:	85ca                	mv	a1,s2
 554:	8556                	mv	a0,s5
 556:	00000097          	auipc	ra,0x0
 55a:	e86080e7          	jalr	-378(ra) # 3dc <putc>
      }
      state = 0;
 55e:	4981                	li	s3,0
 560:	b765                	j	508 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 562:	008b0913          	addi	s2,s6,8
 566:	4685                	li	a3,1
 568:	4629                	li	a2,10
 56a:	000b2583          	lw	a1,0(s6)
 56e:	8556                	mv	a0,s5
 570:	00000097          	auipc	ra,0x0
 574:	e8e080e7          	jalr	-370(ra) # 3fe <printint>
 578:	8b4a                	mv	s6,s2
      state = 0;
 57a:	4981                	li	s3,0
 57c:	b771                	j	508 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 57e:	008b0913          	addi	s2,s6,8
 582:	4681                	li	a3,0
 584:	4629                	li	a2,10
 586:	000b2583          	lw	a1,0(s6)
 58a:	8556                	mv	a0,s5
 58c:	00000097          	auipc	ra,0x0
 590:	e72080e7          	jalr	-398(ra) # 3fe <printint>
 594:	8b4a                	mv	s6,s2
      state = 0;
 596:	4981                	li	s3,0
 598:	bf85                	j	508 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 59a:	008b0913          	addi	s2,s6,8
 59e:	4681                	li	a3,0
 5a0:	4641                	li	a2,16
 5a2:	000b2583          	lw	a1,0(s6)
 5a6:	8556                	mv	a0,s5
 5a8:	00000097          	auipc	ra,0x0
 5ac:	e56080e7          	jalr	-426(ra) # 3fe <printint>
 5b0:	8b4a                	mv	s6,s2
      state = 0;
 5b2:	4981                	li	s3,0
 5b4:	bf91                	j	508 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5b6:	008b0793          	addi	a5,s6,8
 5ba:	f8f43423          	sd	a5,-120(s0)
 5be:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 5c2:	03000593          	li	a1,48
 5c6:	8556                	mv	a0,s5
 5c8:	00000097          	auipc	ra,0x0
 5cc:	e14080e7          	jalr	-492(ra) # 3dc <putc>
  putc(fd, 'x');
 5d0:	85ea                	mv	a1,s10
 5d2:	8556                	mv	a0,s5
 5d4:	00000097          	auipc	ra,0x0
 5d8:	e08080e7          	jalr	-504(ra) # 3dc <putc>
 5dc:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5de:	03c9d793          	srli	a5,s3,0x3c
 5e2:	97de                	add	a5,a5,s7
 5e4:	0007c583          	lbu	a1,0(a5)
 5e8:	8556                	mv	a0,s5
 5ea:	00000097          	auipc	ra,0x0
 5ee:	df2080e7          	jalr	-526(ra) # 3dc <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5f2:	0992                	slli	s3,s3,0x4
 5f4:	397d                	addiw	s2,s2,-1
 5f6:	fe0914e3          	bnez	s2,5de <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 5fa:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 5fe:	4981                	li	s3,0
 600:	b721                	j	508 <vprintf+0x60>
        s = va_arg(ap, char*);
 602:	008b0993          	addi	s3,s6,8
 606:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 60a:	02090163          	beqz	s2,62c <vprintf+0x184>
        while(*s != 0){
 60e:	00094583          	lbu	a1,0(s2)
 612:	c9a1                	beqz	a1,662 <vprintf+0x1ba>
          putc(fd, *s);
 614:	8556                	mv	a0,s5
 616:	00000097          	auipc	ra,0x0
 61a:	dc6080e7          	jalr	-570(ra) # 3dc <putc>
          s++;
 61e:	0905                	addi	s2,s2,1
        while(*s != 0){
 620:	00094583          	lbu	a1,0(s2)
 624:	f9e5                	bnez	a1,614 <vprintf+0x16c>
        s = va_arg(ap, char*);
 626:	8b4e                	mv	s6,s3
      state = 0;
 628:	4981                	li	s3,0
 62a:	bdf9                	j	508 <vprintf+0x60>
          s = "(null)";
 62c:	00000917          	auipc	s2,0x0
 630:	27c90913          	addi	s2,s2,636 # 8a8 <malloc+0x136>
        while(*s != 0){
 634:	02800593          	li	a1,40
 638:	bff1                	j	614 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 63a:	008b0913          	addi	s2,s6,8
 63e:	000b4583          	lbu	a1,0(s6)
 642:	8556                	mv	a0,s5
 644:	00000097          	auipc	ra,0x0
 648:	d98080e7          	jalr	-616(ra) # 3dc <putc>
 64c:	8b4a                	mv	s6,s2
      state = 0;
 64e:	4981                	li	s3,0
 650:	bd65                	j	508 <vprintf+0x60>
        putc(fd, c);
 652:	85d2                	mv	a1,s4
 654:	8556                	mv	a0,s5
 656:	00000097          	auipc	ra,0x0
 65a:	d86080e7          	jalr	-634(ra) # 3dc <putc>
      state = 0;
 65e:	4981                	li	s3,0
 660:	b565                	j	508 <vprintf+0x60>
        s = va_arg(ap, char*);
 662:	8b4e                	mv	s6,s3
      state = 0;
 664:	4981                	li	s3,0
 666:	b54d                	j	508 <vprintf+0x60>
    }
  }
}
 668:	70e6                	ld	ra,120(sp)
 66a:	7446                	ld	s0,112(sp)
 66c:	74a6                	ld	s1,104(sp)
 66e:	7906                	ld	s2,96(sp)
 670:	69e6                	ld	s3,88(sp)
 672:	6a46                	ld	s4,80(sp)
 674:	6aa6                	ld	s5,72(sp)
 676:	6b06                	ld	s6,64(sp)
 678:	7be2                	ld	s7,56(sp)
 67a:	7c42                	ld	s8,48(sp)
 67c:	7ca2                	ld	s9,40(sp)
 67e:	7d02                	ld	s10,32(sp)
 680:	6de2                	ld	s11,24(sp)
 682:	6109                	addi	sp,sp,128
 684:	8082                	ret

0000000000000686 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 686:	715d                	addi	sp,sp,-80
 688:	ec06                	sd	ra,24(sp)
 68a:	e822                	sd	s0,16(sp)
 68c:	1000                	addi	s0,sp,32
 68e:	e010                	sd	a2,0(s0)
 690:	e414                	sd	a3,8(s0)
 692:	e818                	sd	a4,16(s0)
 694:	ec1c                	sd	a5,24(s0)
 696:	03043023          	sd	a6,32(s0)
 69a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 69e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6a2:	8622                	mv	a2,s0
 6a4:	00000097          	auipc	ra,0x0
 6a8:	e04080e7          	jalr	-508(ra) # 4a8 <vprintf>
}
 6ac:	60e2                	ld	ra,24(sp)
 6ae:	6442                	ld	s0,16(sp)
 6b0:	6161                	addi	sp,sp,80
 6b2:	8082                	ret

00000000000006b4 <printf>:

void
printf(const char *fmt, ...)
{
 6b4:	711d                	addi	sp,sp,-96
 6b6:	ec06                	sd	ra,24(sp)
 6b8:	e822                	sd	s0,16(sp)
 6ba:	1000                	addi	s0,sp,32
 6bc:	e40c                	sd	a1,8(s0)
 6be:	e810                	sd	a2,16(s0)
 6c0:	ec14                	sd	a3,24(s0)
 6c2:	f018                	sd	a4,32(s0)
 6c4:	f41c                	sd	a5,40(s0)
 6c6:	03043823          	sd	a6,48(s0)
 6ca:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6ce:	00840613          	addi	a2,s0,8
 6d2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6d6:	85aa                	mv	a1,a0
 6d8:	4505                	li	a0,1
 6da:	00000097          	auipc	ra,0x0
 6de:	dce080e7          	jalr	-562(ra) # 4a8 <vprintf>
}
 6e2:	60e2                	ld	ra,24(sp)
 6e4:	6442                	ld	s0,16(sp)
 6e6:	6125                	addi	sp,sp,96
 6e8:	8082                	ret

00000000000006ea <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6ea:	1141                	addi	sp,sp,-16
 6ec:	e422                	sd	s0,8(sp)
 6ee:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6f0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6f4:	00001797          	auipc	a5,0x1
 6f8:	90c7b783          	ld	a5,-1780(a5) # 1000 <freep>
 6fc:	a805                	j	72c <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6fe:	4618                	lw	a4,8(a2)
 700:	9db9                	addw	a1,a1,a4
 702:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 706:	6398                	ld	a4,0(a5)
 708:	6318                	ld	a4,0(a4)
 70a:	fee53823          	sd	a4,-16(a0)
 70e:	a091                	j	752 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 710:	ff852703          	lw	a4,-8(a0)
 714:	9e39                	addw	a2,a2,a4
 716:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 718:	ff053703          	ld	a4,-16(a0)
 71c:	e398                	sd	a4,0(a5)
 71e:	a099                	j	764 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 720:	6398                	ld	a4,0(a5)
 722:	00e7e463          	bltu	a5,a4,72a <free+0x40>
 726:	00e6ea63          	bltu	a3,a4,73a <free+0x50>
{
 72a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 72c:	fed7fae3          	bgeu	a5,a3,720 <free+0x36>
 730:	6398                	ld	a4,0(a5)
 732:	00e6e463          	bltu	a3,a4,73a <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 736:	fee7eae3          	bltu	a5,a4,72a <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 73a:	ff852583          	lw	a1,-8(a0)
 73e:	6390                	ld	a2,0(a5)
 740:	02059713          	slli	a4,a1,0x20
 744:	9301                	srli	a4,a4,0x20
 746:	0712                	slli	a4,a4,0x4
 748:	9736                	add	a4,a4,a3
 74a:	fae60ae3          	beq	a2,a4,6fe <free+0x14>
    bp->s.ptr = p->s.ptr;
 74e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 752:	4790                	lw	a2,8(a5)
 754:	02061713          	slli	a4,a2,0x20
 758:	9301                	srli	a4,a4,0x20
 75a:	0712                	slli	a4,a4,0x4
 75c:	973e                	add	a4,a4,a5
 75e:	fae689e3          	beq	a3,a4,710 <free+0x26>
  } else
    p->s.ptr = bp;
 762:	e394                	sd	a3,0(a5)
  freep = p;
 764:	00001717          	auipc	a4,0x1
 768:	88f73e23          	sd	a5,-1892(a4) # 1000 <freep>
}
 76c:	6422                	ld	s0,8(sp)
 76e:	0141                	addi	sp,sp,16
 770:	8082                	ret

0000000000000772 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 772:	7139                	addi	sp,sp,-64
 774:	fc06                	sd	ra,56(sp)
 776:	f822                	sd	s0,48(sp)
 778:	f426                	sd	s1,40(sp)
 77a:	f04a                	sd	s2,32(sp)
 77c:	ec4e                	sd	s3,24(sp)
 77e:	e852                	sd	s4,16(sp)
 780:	e456                	sd	s5,8(sp)
 782:	e05a                	sd	s6,0(sp)
 784:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 786:	02051493          	slli	s1,a0,0x20
 78a:	9081                	srli	s1,s1,0x20
 78c:	04bd                	addi	s1,s1,15
 78e:	8091                	srli	s1,s1,0x4
 790:	0014899b          	addiw	s3,s1,1
 794:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 796:	00001517          	auipc	a0,0x1
 79a:	86a53503          	ld	a0,-1942(a0) # 1000 <freep>
 79e:	c515                	beqz	a0,7ca <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7a0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7a2:	4798                	lw	a4,8(a5)
 7a4:	02977f63          	bgeu	a4,s1,7e2 <malloc+0x70>
 7a8:	8a4e                	mv	s4,s3
 7aa:	0009871b          	sext.w	a4,s3
 7ae:	6685                	lui	a3,0x1
 7b0:	00d77363          	bgeu	a4,a3,7b6 <malloc+0x44>
 7b4:	6a05                	lui	s4,0x1
 7b6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7ba:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7be:	00001917          	auipc	s2,0x1
 7c2:	84290913          	addi	s2,s2,-1982 # 1000 <freep>
  if(p == (char*)-1)
 7c6:	5afd                	li	s5,-1
 7c8:	a88d                	j	83a <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 7ca:	00001797          	auipc	a5,0x1
 7ce:	84678793          	addi	a5,a5,-1978 # 1010 <base>
 7d2:	00001717          	auipc	a4,0x1
 7d6:	82f73723          	sd	a5,-2002(a4) # 1000 <freep>
 7da:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7dc:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7e0:	b7e1                	j	7a8 <malloc+0x36>
      if(p->s.size == nunits)
 7e2:	02e48b63          	beq	s1,a4,818 <malloc+0xa6>
        p->s.size -= nunits;
 7e6:	4137073b          	subw	a4,a4,s3
 7ea:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7ec:	1702                	slli	a4,a4,0x20
 7ee:	9301                	srli	a4,a4,0x20
 7f0:	0712                	slli	a4,a4,0x4
 7f2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7f4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7f8:	00001717          	auipc	a4,0x1
 7fc:	80a73423          	sd	a0,-2040(a4) # 1000 <freep>
      return (void*)(p + 1);
 800:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 804:	70e2                	ld	ra,56(sp)
 806:	7442                	ld	s0,48(sp)
 808:	74a2                	ld	s1,40(sp)
 80a:	7902                	ld	s2,32(sp)
 80c:	69e2                	ld	s3,24(sp)
 80e:	6a42                	ld	s4,16(sp)
 810:	6aa2                	ld	s5,8(sp)
 812:	6b02                	ld	s6,0(sp)
 814:	6121                	addi	sp,sp,64
 816:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 818:	6398                	ld	a4,0(a5)
 81a:	e118                	sd	a4,0(a0)
 81c:	bff1                	j	7f8 <malloc+0x86>
  hp->s.size = nu;
 81e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 822:	0541                	addi	a0,a0,16
 824:	00000097          	auipc	ra,0x0
 828:	ec6080e7          	jalr	-314(ra) # 6ea <free>
  return freep;
 82c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 830:	d971                	beqz	a0,804 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 832:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 834:	4798                	lw	a4,8(a5)
 836:	fa9776e3          	bgeu	a4,s1,7e2 <malloc+0x70>
    if(p == freep)
 83a:	00093703          	ld	a4,0(s2)
 83e:	853e                	mv	a0,a5
 840:	fef719e3          	bne	a4,a5,832 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 844:	8552                	mv	a0,s4
 846:	00000097          	auipc	ra,0x0
 84a:	b4e080e7          	jalr	-1202(ra) # 394 <sbrk>
  if(p == (char*)-1)
 84e:	fd5518e3          	bne	a0,s5,81e <malloc+0xac>
        return 0;
 852:	4501                	li	a0,0
 854:	bf45                	j	804 <malloc+0x92>

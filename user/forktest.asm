
user/_forktest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <print>:

#define N  1000

void
print(const char *s)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
   a:	84aa                	mv	s1,a0
  write(1, s, strlen(s));
   c:	00000097          	auipc	ra,0x0
  10:	174080e7          	jalr	372(ra) # 180 <strlen>
  14:	0005061b          	sext.w	a2,a0
  18:	85a6                	mv	a1,s1
  1a:	4505                	li	a0,1
  1c:	00000097          	auipc	ra,0x0
  20:	3aa080e7          	jalr	938(ra) # 3c6 <write>
}
  24:	60e2                	ld	ra,24(sp)
  26:	6442                	ld	s0,16(sp)
  28:	64a2                	ld	s1,8(sp)
  2a:	6105                	addi	sp,sp,32
  2c:	8082                	ret

000000000000002e <forktest>:

void
forktest(void)
{
  2e:	1101                	addi	sp,sp,-32
  30:	ec06                	sd	ra,24(sp)
  32:	e822                	sd	s0,16(sp)
  34:	e426                	sd	s1,8(sp)
  36:	e04a                	sd	s2,0(sp)
  38:	1000                	addi	s0,sp,32
  int n, pid;

  print("fork test\n");
  3a:	00000517          	auipc	a0,0x0
  3e:	41650513          	addi	a0,a0,1046 # 450 <trace+0xa>
  42:	00000097          	auipc	ra,0x0
  46:	fbe080e7          	jalr	-66(ra) # 0 <print>

  for(n=0; n<N; n++){
  4a:	4481                	li	s1,0
  4c:	3e800913          	li	s2,1000
    pid = fork();
  50:	00000097          	auipc	ra,0x0
  54:	34e080e7          	jalr	846(ra) # 39e <fork>
    if(pid < 0)
  58:	02054763          	bltz	a0,86 <forktest+0x58>
      break;
    if(pid == 0)
  5c:	c10d                	beqz	a0,7e <forktest+0x50>
  for(n=0; n<N; n++){
  5e:	2485                	addiw	s1,s1,1
  60:	ff2498e3          	bne	s1,s2,50 <forktest+0x22>
      exit(0);
  }

  if(n == N){
    print("fork claimed to work N times!\n");
  64:	00000517          	auipc	a0,0x0
  68:	3fc50513          	addi	a0,a0,1020 # 460 <trace+0x1a>
  6c:	00000097          	auipc	ra,0x0
  70:	f94080e7          	jalr	-108(ra) # 0 <print>
    exit(1);
  74:	4505                	li	a0,1
  76:	00000097          	auipc	ra,0x0
  7a:	330080e7          	jalr	816(ra) # 3a6 <exit>
      exit(0);
  7e:	00000097          	auipc	ra,0x0
  82:	328080e7          	jalr	808(ra) # 3a6 <exit>
  if(n == N){
  86:	3e800793          	li	a5,1000
  8a:	fcf48de3          	beq	s1,a5,64 <forktest+0x36>
  }

  for(; n > 0; n--){
  8e:	00905b63          	blez	s1,a4 <forktest+0x76>
    if(wait(0) < 0){
  92:	4501                	li	a0,0
  94:	00000097          	auipc	ra,0x0
  98:	31a080e7          	jalr	794(ra) # 3ae <wait>
  9c:	02054a63          	bltz	a0,d0 <forktest+0xa2>
  for(; n > 0; n--){
  a0:	34fd                	addiw	s1,s1,-1
  a2:	f8e5                	bnez	s1,92 <forktest+0x64>
      print("wait stopped early\n");
      exit(1);
    }
  }

  if(wait(0) != -1){
  a4:	4501                	li	a0,0
  a6:	00000097          	auipc	ra,0x0
  aa:	308080e7          	jalr	776(ra) # 3ae <wait>
  ae:	57fd                	li	a5,-1
  b0:	02f51d63          	bne	a0,a5,ea <forktest+0xbc>
    print("wait got too many\n");
    exit(1);
  }

  print("fork test OK\n");
  b4:	00000517          	auipc	a0,0x0
  b8:	3fc50513          	addi	a0,a0,1020 # 4b0 <trace+0x6a>
  bc:	00000097          	auipc	ra,0x0
  c0:	f44080e7          	jalr	-188(ra) # 0 <print>
}
  c4:	60e2                	ld	ra,24(sp)
  c6:	6442                	ld	s0,16(sp)
  c8:	64a2                	ld	s1,8(sp)
  ca:	6902                	ld	s2,0(sp)
  cc:	6105                	addi	sp,sp,32
  ce:	8082                	ret
      print("wait stopped early\n");
  d0:	00000517          	auipc	a0,0x0
  d4:	3b050513          	addi	a0,a0,944 # 480 <trace+0x3a>
  d8:	00000097          	auipc	ra,0x0
  dc:	f28080e7          	jalr	-216(ra) # 0 <print>
      exit(1);
  e0:	4505                	li	a0,1
  e2:	00000097          	auipc	ra,0x0
  e6:	2c4080e7          	jalr	708(ra) # 3a6 <exit>
    print("wait got too many\n");
  ea:	00000517          	auipc	a0,0x0
  ee:	3ae50513          	addi	a0,a0,942 # 498 <trace+0x52>
  f2:	00000097          	auipc	ra,0x0
  f6:	f0e080e7          	jalr	-242(ra) # 0 <print>
    exit(1);
  fa:	4505                	li	a0,1
  fc:	00000097          	auipc	ra,0x0
 100:	2aa080e7          	jalr	682(ra) # 3a6 <exit>

0000000000000104 <main>:

int
main(void)
{
 104:	1141                	addi	sp,sp,-16
 106:	e406                	sd	ra,8(sp)
 108:	e022                	sd	s0,0(sp)
 10a:	0800                	addi	s0,sp,16
  forktest();
 10c:	00000097          	auipc	ra,0x0
 110:	f22080e7          	jalr	-222(ra) # 2e <forktest>
  exit(0);
 114:	4501                	li	a0,0
 116:	00000097          	auipc	ra,0x0
 11a:	290080e7          	jalr	656(ra) # 3a6 <exit>

000000000000011e <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 11e:	1141                	addi	sp,sp,-16
 120:	e406                	sd	ra,8(sp)
 122:	e022                	sd	s0,0(sp)
 124:	0800                	addi	s0,sp,16
  extern int main();
  main();
 126:	00000097          	auipc	ra,0x0
 12a:	fde080e7          	jalr	-34(ra) # 104 <main>
  exit(0);
 12e:	4501                	li	a0,0
 130:	00000097          	auipc	ra,0x0
 134:	276080e7          	jalr	630(ra) # 3a6 <exit>

0000000000000138 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 138:	1141                	addi	sp,sp,-16
 13a:	e422                	sd	s0,8(sp)
 13c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 13e:	87aa                	mv	a5,a0
 140:	0585                	addi	a1,a1,1
 142:	0785                	addi	a5,a5,1
 144:	fff5c703          	lbu	a4,-1(a1)
 148:	fee78fa3          	sb	a4,-1(a5)
 14c:	fb75                	bnez	a4,140 <strcpy+0x8>
    ;
  return os;
}
 14e:	6422                	ld	s0,8(sp)
 150:	0141                	addi	sp,sp,16
 152:	8082                	ret

0000000000000154 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 154:	1141                	addi	sp,sp,-16
 156:	e422                	sd	s0,8(sp)
 158:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 15a:	00054783          	lbu	a5,0(a0)
 15e:	cb91                	beqz	a5,172 <strcmp+0x1e>
 160:	0005c703          	lbu	a4,0(a1)
 164:	00f71763          	bne	a4,a5,172 <strcmp+0x1e>
    p++, q++;
 168:	0505                	addi	a0,a0,1
 16a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 16c:	00054783          	lbu	a5,0(a0)
 170:	fbe5                	bnez	a5,160 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 172:	0005c503          	lbu	a0,0(a1)
}
 176:	40a7853b          	subw	a0,a5,a0
 17a:	6422                	ld	s0,8(sp)
 17c:	0141                	addi	sp,sp,16
 17e:	8082                	ret

0000000000000180 <strlen>:

uint
strlen(const char *s)
{
 180:	1141                	addi	sp,sp,-16
 182:	e422                	sd	s0,8(sp)
 184:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 186:	00054783          	lbu	a5,0(a0)
 18a:	cf91                	beqz	a5,1a6 <strlen+0x26>
 18c:	0505                	addi	a0,a0,1
 18e:	87aa                	mv	a5,a0
 190:	4685                	li	a3,1
 192:	9e89                	subw	a3,a3,a0
 194:	00f6853b          	addw	a0,a3,a5
 198:	0785                	addi	a5,a5,1
 19a:	fff7c703          	lbu	a4,-1(a5)
 19e:	fb7d                	bnez	a4,194 <strlen+0x14>
    ;
  return n;
}
 1a0:	6422                	ld	s0,8(sp)
 1a2:	0141                	addi	sp,sp,16
 1a4:	8082                	ret
  for(n = 0; s[n]; n++)
 1a6:	4501                	li	a0,0
 1a8:	bfe5                	j	1a0 <strlen+0x20>

00000000000001aa <memset>:

void*
memset(void *dst, int c, uint n)
{
 1aa:	1141                	addi	sp,sp,-16
 1ac:	e422                	sd	s0,8(sp)
 1ae:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1b0:	ca19                	beqz	a2,1c6 <memset+0x1c>
 1b2:	87aa                	mv	a5,a0
 1b4:	1602                	slli	a2,a2,0x20
 1b6:	9201                	srli	a2,a2,0x20
 1b8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1bc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1c0:	0785                	addi	a5,a5,1
 1c2:	fee79de3          	bne	a5,a4,1bc <memset+0x12>
  }
  return dst;
}
 1c6:	6422                	ld	s0,8(sp)
 1c8:	0141                	addi	sp,sp,16
 1ca:	8082                	ret

00000000000001cc <strchr>:

char*
strchr(const char *s, char c)
{
 1cc:	1141                	addi	sp,sp,-16
 1ce:	e422                	sd	s0,8(sp)
 1d0:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1d2:	00054783          	lbu	a5,0(a0)
 1d6:	cb99                	beqz	a5,1ec <strchr+0x20>
    if(*s == c)
 1d8:	00f58763          	beq	a1,a5,1e6 <strchr+0x1a>
  for(; *s; s++)
 1dc:	0505                	addi	a0,a0,1
 1de:	00054783          	lbu	a5,0(a0)
 1e2:	fbfd                	bnez	a5,1d8 <strchr+0xc>
      return (char*)s;
  return 0;
 1e4:	4501                	li	a0,0
}
 1e6:	6422                	ld	s0,8(sp)
 1e8:	0141                	addi	sp,sp,16
 1ea:	8082                	ret
  return 0;
 1ec:	4501                	li	a0,0
 1ee:	bfe5                	j	1e6 <strchr+0x1a>

00000000000001f0 <gets>:

char*
gets(char *buf, int max)
{
 1f0:	711d                	addi	sp,sp,-96
 1f2:	ec86                	sd	ra,88(sp)
 1f4:	e8a2                	sd	s0,80(sp)
 1f6:	e4a6                	sd	s1,72(sp)
 1f8:	e0ca                	sd	s2,64(sp)
 1fa:	fc4e                	sd	s3,56(sp)
 1fc:	f852                	sd	s4,48(sp)
 1fe:	f456                	sd	s5,40(sp)
 200:	f05a                	sd	s6,32(sp)
 202:	ec5e                	sd	s7,24(sp)
 204:	1080                	addi	s0,sp,96
 206:	8baa                	mv	s7,a0
 208:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 20a:	892a                	mv	s2,a0
 20c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 20e:	4aa9                	li	s5,10
 210:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 212:	89a6                	mv	s3,s1
 214:	2485                	addiw	s1,s1,1
 216:	0344d863          	bge	s1,s4,246 <gets+0x56>
    cc = read(0, &c, 1);
 21a:	4605                	li	a2,1
 21c:	faf40593          	addi	a1,s0,-81
 220:	4501                	li	a0,0
 222:	00000097          	auipc	ra,0x0
 226:	19c080e7          	jalr	412(ra) # 3be <read>
    if(cc < 1)
 22a:	00a05e63          	blez	a0,246 <gets+0x56>
    buf[i++] = c;
 22e:	faf44783          	lbu	a5,-81(s0)
 232:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 236:	01578763          	beq	a5,s5,244 <gets+0x54>
 23a:	0905                	addi	s2,s2,1
 23c:	fd679be3          	bne	a5,s6,212 <gets+0x22>
  for(i=0; i+1 < max; ){
 240:	89a6                	mv	s3,s1
 242:	a011                	j	246 <gets+0x56>
 244:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 246:	99de                	add	s3,s3,s7
 248:	00098023          	sb	zero,0(s3)
  return buf;
}
 24c:	855e                	mv	a0,s7
 24e:	60e6                	ld	ra,88(sp)
 250:	6446                	ld	s0,80(sp)
 252:	64a6                	ld	s1,72(sp)
 254:	6906                	ld	s2,64(sp)
 256:	79e2                	ld	s3,56(sp)
 258:	7a42                	ld	s4,48(sp)
 25a:	7aa2                	ld	s5,40(sp)
 25c:	7b02                	ld	s6,32(sp)
 25e:	6be2                	ld	s7,24(sp)
 260:	6125                	addi	sp,sp,96
 262:	8082                	ret

0000000000000264 <stat>:

int
stat(const char *n, struct stat *st)
{
 264:	1101                	addi	sp,sp,-32
 266:	ec06                	sd	ra,24(sp)
 268:	e822                	sd	s0,16(sp)
 26a:	e426                	sd	s1,8(sp)
 26c:	e04a                	sd	s2,0(sp)
 26e:	1000                	addi	s0,sp,32
 270:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 272:	4581                	li	a1,0
 274:	00000097          	auipc	ra,0x0
 278:	172080e7          	jalr	370(ra) # 3e6 <open>
  if(fd < 0)
 27c:	02054563          	bltz	a0,2a6 <stat+0x42>
 280:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 282:	85ca                	mv	a1,s2
 284:	00000097          	auipc	ra,0x0
 288:	17a080e7          	jalr	378(ra) # 3fe <fstat>
 28c:	892a                	mv	s2,a0
  close(fd);
 28e:	8526                	mv	a0,s1
 290:	00000097          	auipc	ra,0x0
 294:	13e080e7          	jalr	318(ra) # 3ce <close>
  return r;
}
 298:	854a                	mv	a0,s2
 29a:	60e2                	ld	ra,24(sp)
 29c:	6442                	ld	s0,16(sp)
 29e:	64a2                	ld	s1,8(sp)
 2a0:	6902                	ld	s2,0(sp)
 2a2:	6105                	addi	sp,sp,32
 2a4:	8082                	ret
    return -1;
 2a6:	597d                	li	s2,-1
 2a8:	bfc5                	j	298 <stat+0x34>

00000000000002aa <atoi>:

int
atoi(const char *s)
{
 2aa:	1141                	addi	sp,sp,-16
 2ac:	e422                	sd	s0,8(sp)
 2ae:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2b0:	00054603          	lbu	a2,0(a0)
 2b4:	fd06079b          	addiw	a5,a2,-48
 2b8:	0ff7f793          	andi	a5,a5,255
 2bc:	4725                	li	a4,9
 2be:	02f76963          	bltu	a4,a5,2f0 <atoi+0x46>
 2c2:	86aa                	mv	a3,a0
  n = 0;
 2c4:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2c6:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2c8:	0685                	addi	a3,a3,1
 2ca:	0025179b          	slliw	a5,a0,0x2
 2ce:	9fa9                	addw	a5,a5,a0
 2d0:	0017979b          	slliw	a5,a5,0x1
 2d4:	9fb1                	addw	a5,a5,a2
 2d6:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2da:	0006c603          	lbu	a2,0(a3)
 2de:	fd06071b          	addiw	a4,a2,-48
 2e2:	0ff77713          	andi	a4,a4,255
 2e6:	fee5f1e3          	bgeu	a1,a4,2c8 <atoi+0x1e>
  return n;
}
 2ea:	6422                	ld	s0,8(sp)
 2ec:	0141                	addi	sp,sp,16
 2ee:	8082                	ret
  n = 0;
 2f0:	4501                	li	a0,0
 2f2:	bfe5                	j	2ea <atoi+0x40>

00000000000002f4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2f4:	1141                	addi	sp,sp,-16
 2f6:	e422                	sd	s0,8(sp)
 2f8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2fa:	02b57463          	bgeu	a0,a1,322 <memmove+0x2e>
    while(n-- > 0)
 2fe:	00c05f63          	blez	a2,31c <memmove+0x28>
 302:	1602                	slli	a2,a2,0x20
 304:	9201                	srli	a2,a2,0x20
 306:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 30a:	872a                	mv	a4,a0
      *dst++ = *src++;
 30c:	0585                	addi	a1,a1,1
 30e:	0705                	addi	a4,a4,1
 310:	fff5c683          	lbu	a3,-1(a1)
 314:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 318:	fee79ae3          	bne	a5,a4,30c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 31c:	6422                	ld	s0,8(sp)
 31e:	0141                	addi	sp,sp,16
 320:	8082                	ret
    dst += n;
 322:	00c50733          	add	a4,a0,a2
    src += n;
 326:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 328:	fec05ae3          	blez	a2,31c <memmove+0x28>
 32c:	fff6079b          	addiw	a5,a2,-1
 330:	1782                	slli	a5,a5,0x20
 332:	9381                	srli	a5,a5,0x20
 334:	fff7c793          	not	a5,a5
 338:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 33a:	15fd                	addi	a1,a1,-1
 33c:	177d                	addi	a4,a4,-1
 33e:	0005c683          	lbu	a3,0(a1)
 342:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 346:	fee79ae3          	bne	a5,a4,33a <memmove+0x46>
 34a:	bfc9                	j	31c <memmove+0x28>

000000000000034c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 34c:	1141                	addi	sp,sp,-16
 34e:	e422                	sd	s0,8(sp)
 350:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 352:	ca05                	beqz	a2,382 <memcmp+0x36>
 354:	fff6069b          	addiw	a3,a2,-1
 358:	1682                	slli	a3,a3,0x20
 35a:	9281                	srli	a3,a3,0x20
 35c:	0685                	addi	a3,a3,1
 35e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 360:	00054783          	lbu	a5,0(a0)
 364:	0005c703          	lbu	a4,0(a1)
 368:	00e79863          	bne	a5,a4,378 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 36c:	0505                	addi	a0,a0,1
    p2++;
 36e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 370:	fed518e3          	bne	a0,a3,360 <memcmp+0x14>
  }
  return 0;
 374:	4501                	li	a0,0
 376:	a019                	j	37c <memcmp+0x30>
      return *p1 - *p2;
 378:	40e7853b          	subw	a0,a5,a4
}
 37c:	6422                	ld	s0,8(sp)
 37e:	0141                	addi	sp,sp,16
 380:	8082                	ret
  return 0;
 382:	4501                	li	a0,0
 384:	bfe5                	j	37c <memcmp+0x30>

0000000000000386 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 386:	1141                	addi	sp,sp,-16
 388:	e406                	sd	ra,8(sp)
 38a:	e022                	sd	s0,0(sp)
 38c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 38e:	00000097          	auipc	ra,0x0
 392:	f66080e7          	jalr	-154(ra) # 2f4 <memmove>
}
 396:	60a2                	ld	ra,8(sp)
 398:	6402                	ld	s0,0(sp)
 39a:	0141                	addi	sp,sp,16
 39c:	8082                	ret

000000000000039e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 39e:	4885                	li	a7,1
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3a6:	4889                	li	a7,2
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <wait>:
.global wait
wait:
 li a7, SYS_wait
 3ae:	488d                	li	a7,3
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3b6:	4891                	li	a7,4
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <read>:
.global read
read:
 li a7, SYS_read
 3be:	4895                	li	a7,5
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <write>:
.global write
write:
 li a7, SYS_write
 3c6:	48c1                	li	a7,16
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <close>:
.global close
close:
 li a7, SYS_close
 3ce:	48d5                	li	a7,21
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3d6:	4899                	li	a7,6
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <exec>:
.global exec
exec:
 li a7, SYS_exec
 3de:	489d                	li	a7,7
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <open>:
.global open
open:
 li a7, SYS_open
 3e6:	48bd                	li	a7,15
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3ee:	48c5                	li	a7,17
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3f6:	48c9                	li	a7,18
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3fe:	48a1                	li	a7,8
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <link>:
.global link
link:
 li a7, SYS_link
 406:	48cd                	li	a7,19
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 40e:	48d1                	li	a7,20
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 416:	48a5                	li	a7,9
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <dup>:
.global dup
dup:
 li a7, SYS_dup
 41e:	48a9                	li	a7,10
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 426:	48ad                	li	a7,11
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 42e:	48b1                	li	a7,12
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 436:	48b5                	li	a7,13
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 43e:	48b9                	li	a7,14
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <trace>:
.global trace
trace:
 li a7, SYS_trace
 446:	48d9                	li	a7,22
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

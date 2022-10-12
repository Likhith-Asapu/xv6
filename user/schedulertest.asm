
user/_schedulertest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:


#define NFORK 10
#define IO 5

int main() {
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	0080                	addi	s0,sp,64
  int n, pid;
  int wtime, rtime;
  int twtime=0, trtime=0;
  for(n=0; n < NFORK;n++) {
   e:	4481                	li	s1,0
  10:	49a9                	li	s3,10
  12:	a829                	j	2c <main+0x2c>
      pid = fork();
      
      if(n == 0)
        settickets(400);
      else
        settickets(1);
  14:	4505                	li	a0,1
  16:	00000097          	auipc	ra,0x0
  1a:	432080e7          	jalr	1074(ra) # 448 <settickets>
      if (pid < 0)
  1e:	02094463          	bltz	s2,46 <main+0x46>
          break;
      if (pid == 0) {
  22:	04090b63          	beqz	s2,78 <main+0x78>
  for(n=0; n < NFORK;n++) {
  26:	2485                	addiw	s1,s1,1
  28:	03348163          	beq	s1,s3,4a <main+0x4a>
      pid = fork();
  2c:	00000097          	auipc	ra,0x0
  30:	354080e7          	jalr	852(ra) # 380 <fork>
  34:	892a                	mv	s2,a0
      if(n == 0)
  36:	fcf9                	bnez	s1,14 <main+0x14>
        settickets(400);
  38:	19000513          	li	a0,400
  3c:	00000097          	auipc	ra,0x0
  40:	40c080e7          	jalr	1036(ra) # 448 <settickets>
  44:	bfe9                	j	1e <main+0x1e>
#ifdef PBS
        setpriority(80, pid); // Will only matter for PBS, set lower priority for IO bound processes 
#endif
      }
  }
  for(;n > 0; n--) {
  46:	00905563          	blez	s1,50 <main+0x50>
  for(n=0; n < NFORK;n++) {
  4a:	4901                	li	s2,0
  4c:	4981                	li	s3,0
  4e:	a069                	j	d8 <main+0xd8>
  for(;n > 0; n--) {
  50:	4901                	li	s2,0
  52:	4981                	li	s3,0
      if(waitx(0,&wtime,&rtime) >= 0) {
          trtime += rtime;
          twtime += wtime;
      } 
  }
  printf("Average rtime %d,  wtime %d\n", trtime / NFORK, twtime / NFORK);
  54:	45a9                	li	a1,10
  56:	02b9c63b          	divw	a2,s3,a1
  5a:	02b945bb          	divw	a1,s2,a1
  5e:	00001517          	auipc	a0,0x1
  62:	89a50513          	addi	a0,a0,-1894 # 8f8 <malloc+0x10a>
  66:	00000097          	auipc	ra,0x0
  6a:	6ca080e7          	jalr	1738(ra) # 730 <printf>
  exit(0);
  6e:	4501                	li	a0,0
  70:	00000097          	auipc	ra,0x0
  74:	318080e7          	jalr	792(ra) # 388 <exit>
          if (n < IO) {
  78:	4791                	li	a5,4
  7a:	0497d663          	bge	a5,s1,c6 <main+0xc6>
            for (volatile int i = 0; i < 1000000000; i++) {} // CPU bound process 
  7e:	fc042223          	sw	zero,-60(s0)
  82:	fc442703          	lw	a4,-60(s0)
  86:	2701                	sext.w	a4,a4
  88:	3b9ad7b7          	lui	a5,0x3b9ad
  8c:	9ff78793          	addi	a5,a5,-1537 # 3b9ac9ff <base+0x3b9ab9ef>
  90:	00e7cd63          	blt	a5,a4,aa <main+0xaa>
  94:	873e                	mv	a4,a5
  96:	fc442783          	lw	a5,-60(s0)
  9a:	2785                	addiw	a5,a5,1
  9c:	fcf42223          	sw	a5,-60(s0)
  a0:	fc442783          	lw	a5,-60(s0)
  a4:	2781                	sext.w	a5,a5
  a6:	fef758e3          	bge	a4,a5,96 <main+0x96>
          printf("Process %d finished\n", n);
  aa:	85a6                	mv	a1,s1
  ac:	00001517          	auipc	a0,0x1
  b0:	83450513          	addi	a0,a0,-1996 # 8e0 <malloc+0xf2>
  b4:	00000097          	auipc	ra,0x0
  b8:	67c080e7          	jalr	1660(ra) # 730 <printf>
          exit(0);
  bc:	4501                	li	a0,0
  be:	00000097          	auipc	ra,0x0
  c2:	2ca080e7          	jalr	714(ra) # 388 <exit>
            sleep(200); // IO bound processes
  c6:	0c800513          	li	a0,200
  ca:	00000097          	auipc	ra,0x0
  ce:	34e080e7          	jalr	846(ra) # 418 <sleep>
  d2:	bfe1                	j	aa <main+0xaa>
  for(;n > 0; n--) {
  d4:	34fd                	addiw	s1,s1,-1
  d6:	dcbd                	beqz	s1,54 <main+0x54>
      if(waitx(0,&wtime,&rtime) >= 0) {
  d8:	fc840613          	addi	a2,s0,-56
  dc:	fcc40593          	addi	a1,s0,-52
  e0:	4501                	li	a0,0
  e2:	00000097          	auipc	ra,0x0
  e6:	34e080e7          	jalr	846(ra) # 430 <waitx>
  ea:	fe0545e3          	bltz	a0,d4 <main+0xd4>
          trtime += rtime;
  ee:	fc842783          	lw	a5,-56(s0)
  f2:	0127893b          	addw	s2,a5,s2
          twtime += wtime;
  f6:	fcc42783          	lw	a5,-52(s0)
  fa:	013789bb          	addw	s3,a5,s3
  fe:	bfd9                	j	d4 <main+0xd4>

0000000000000100 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 100:	1141                	addi	sp,sp,-16
 102:	e406                	sd	ra,8(sp)
 104:	e022                	sd	s0,0(sp)
 106:	0800                	addi	s0,sp,16
  extern int main();
  main();
 108:	00000097          	auipc	ra,0x0
 10c:	ef8080e7          	jalr	-264(ra) # 0 <main>
  exit(0);
 110:	4501                	li	a0,0
 112:	00000097          	auipc	ra,0x0
 116:	276080e7          	jalr	630(ra) # 388 <exit>

000000000000011a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 11a:	1141                	addi	sp,sp,-16
 11c:	e422                	sd	s0,8(sp)
 11e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 120:	87aa                	mv	a5,a0
 122:	0585                	addi	a1,a1,1
 124:	0785                	addi	a5,a5,1
 126:	fff5c703          	lbu	a4,-1(a1)
 12a:	fee78fa3          	sb	a4,-1(a5)
 12e:	fb75                	bnez	a4,122 <strcpy+0x8>
    ;
  return os;
}
 130:	6422                	ld	s0,8(sp)
 132:	0141                	addi	sp,sp,16
 134:	8082                	ret

0000000000000136 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 136:	1141                	addi	sp,sp,-16
 138:	e422                	sd	s0,8(sp)
 13a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 13c:	00054783          	lbu	a5,0(a0)
 140:	cb91                	beqz	a5,154 <strcmp+0x1e>
 142:	0005c703          	lbu	a4,0(a1)
 146:	00f71763          	bne	a4,a5,154 <strcmp+0x1e>
    p++, q++;
 14a:	0505                	addi	a0,a0,1
 14c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 14e:	00054783          	lbu	a5,0(a0)
 152:	fbe5                	bnez	a5,142 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 154:	0005c503          	lbu	a0,0(a1)
}
 158:	40a7853b          	subw	a0,a5,a0
 15c:	6422                	ld	s0,8(sp)
 15e:	0141                	addi	sp,sp,16
 160:	8082                	ret

0000000000000162 <strlen>:

uint
strlen(const char *s)
{
 162:	1141                	addi	sp,sp,-16
 164:	e422                	sd	s0,8(sp)
 166:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 168:	00054783          	lbu	a5,0(a0)
 16c:	cf91                	beqz	a5,188 <strlen+0x26>
 16e:	0505                	addi	a0,a0,1
 170:	87aa                	mv	a5,a0
 172:	4685                	li	a3,1
 174:	9e89                	subw	a3,a3,a0
 176:	00f6853b          	addw	a0,a3,a5
 17a:	0785                	addi	a5,a5,1
 17c:	fff7c703          	lbu	a4,-1(a5)
 180:	fb7d                	bnez	a4,176 <strlen+0x14>
    ;
  return n;
}
 182:	6422                	ld	s0,8(sp)
 184:	0141                	addi	sp,sp,16
 186:	8082                	ret
  for(n = 0; s[n]; n++)
 188:	4501                	li	a0,0
 18a:	bfe5                	j	182 <strlen+0x20>

000000000000018c <memset>:

void*
memset(void *dst, int c, uint n)
{
 18c:	1141                	addi	sp,sp,-16
 18e:	e422                	sd	s0,8(sp)
 190:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 192:	ca19                	beqz	a2,1a8 <memset+0x1c>
 194:	87aa                	mv	a5,a0
 196:	1602                	slli	a2,a2,0x20
 198:	9201                	srli	a2,a2,0x20
 19a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 19e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1a2:	0785                	addi	a5,a5,1
 1a4:	fee79de3          	bne	a5,a4,19e <memset+0x12>
  }
  return dst;
}
 1a8:	6422                	ld	s0,8(sp)
 1aa:	0141                	addi	sp,sp,16
 1ac:	8082                	ret

00000000000001ae <strchr>:

char*
strchr(const char *s, char c)
{
 1ae:	1141                	addi	sp,sp,-16
 1b0:	e422                	sd	s0,8(sp)
 1b2:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1b4:	00054783          	lbu	a5,0(a0)
 1b8:	cb99                	beqz	a5,1ce <strchr+0x20>
    if(*s == c)
 1ba:	00f58763          	beq	a1,a5,1c8 <strchr+0x1a>
  for(; *s; s++)
 1be:	0505                	addi	a0,a0,1
 1c0:	00054783          	lbu	a5,0(a0)
 1c4:	fbfd                	bnez	a5,1ba <strchr+0xc>
      return (char*)s;
  return 0;
 1c6:	4501                	li	a0,0
}
 1c8:	6422                	ld	s0,8(sp)
 1ca:	0141                	addi	sp,sp,16
 1cc:	8082                	ret
  return 0;
 1ce:	4501                	li	a0,0
 1d0:	bfe5                	j	1c8 <strchr+0x1a>

00000000000001d2 <gets>:

char*
gets(char *buf, int max)
{
 1d2:	711d                	addi	sp,sp,-96
 1d4:	ec86                	sd	ra,88(sp)
 1d6:	e8a2                	sd	s0,80(sp)
 1d8:	e4a6                	sd	s1,72(sp)
 1da:	e0ca                	sd	s2,64(sp)
 1dc:	fc4e                	sd	s3,56(sp)
 1de:	f852                	sd	s4,48(sp)
 1e0:	f456                	sd	s5,40(sp)
 1e2:	f05a                	sd	s6,32(sp)
 1e4:	ec5e                	sd	s7,24(sp)
 1e6:	1080                	addi	s0,sp,96
 1e8:	8baa                	mv	s7,a0
 1ea:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ec:	892a                	mv	s2,a0
 1ee:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1f0:	4aa9                	li	s5,10
 1f2:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1f4:	89a6                	mv	s3,s1
 1f6:	2485                	addiw	s1,s1,1
 1f8:	0344d863          	bge	s1,s4,228 <gets+0x56>
    cc = read(0, &c, 1);
 1fc:	4605                	li	a2,1
 1fe:	faf40593          	addi	a1,s0,-81
 202:	4501                	li	a0,0
 204:	00000097          	auipc	ra,0x0
 208:	19c080e7          	jalr	412(ra) # 3a0 <read>
    if(cc < 1)
 20c:	00a05e63          	blez	a0,228 <gets+0x56>
    buf[i++] = c;
 210:	faf44783          	lbu	a5,-81(s0)
 214:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 218:	01578763          	beq	a5,s5,226 <gets+0x54>
 21c:	0905                	addi	s2,s2,1
 21e:	fd679be3          	bne	a5,s6,1f4 <gets+0x22>
  for(i=0; i+1 < max; ){
 222:	89a6                	mv	s3,s1
 224:	a011                	j	228 <gets+0x56>
 226:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 228:	99de                	add	s3,s3,s7
 22a:	00098023          	sb	zero,0(s3)
  return buf;
}
 22e:	855e                	mv	a0,s7
 230:	60e6                	ld	ra,88(sp)
 232:	6446                	ld	s0,80(sp)
 234:	64a6                	ld	s1,72(sp)
 236:	6906                	ld	s2,64(sp)
 238:	79e2                	ld	s3,56(sp)
 23a:	7a42                	ld	s4,48(sp)
 23c:	7aa2                	ld	s5,40(sp)
 23e:	7b02                	ld	s6,32(sp)
 240:	6be2                	ld	s7,24(sp)
 242:	6125                	addi	sp,sp,96
 244:	8082                	ret

0000000000000246 <stat>:

int
stat(const char *n, struct stat *st)
{
 246:	1101                	addi	sp,sp,-32
 248:	ec06                	sd	ra,24(sp)
 24a:	e822                	sd	s0,16(sp)
 24c:	e426                	sd	s1,8(sp)
 24e:	e04a                	sd	s2,0(sp)
 250:	1000                	addi	s0,sp,32
 252:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 254:	4581                	li	a1,0
 256:	00000097          	auipc	ra,0x0
 25a:	172080e7          	jalr	370(ra) # 3c8 <open>
  if(fd < 0)
 25e:	02054563          	bltz	a0,288 <stat+0x42>
 262:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 264:	85ca                	mv	a1,s2
 266:	00000097          	auipc	ra,0x0
 26a:	17a080e7          	jalr	378(ra) # 3e0 <fstat>
 26e:	892a                	mv	s2,a0
  close(fd);
 270:	8526                	mv	a0,s1
 272:	00000097          	auipc	ra,0x0
 276:	13e080e7          	jalr	318(ra) # 3b0 <close>
  return r;
}
 27a:	854a                	mv	a0,s2
 27c:	60e2                	ld	ra,24(sp)
 27e:	6442                	ld	s0,16(sp)
 280:	64a2                	ld	s1,8(sp)
 282:	6902                	ld	s2,0(sp)
 284:	6105                	addi	sp,sp,32
 286:	8082                	ret
    return -1;
 288:	597d                	li	s2,-1
 28a:	bfc5                	j	27a <stat+0x34>

000000000000028c <atoi>:

int
atoi(const char *s)
{
 28c:	1141                	addi	sp,sp,-16
 28e:	e422                	sd	s0,8(sp)
 290:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 292:	00054603          	lbu	a2,0(a0)
 296:	fd06079b          	addiw	a5,a2,-48
 29a:	0ff7f793          	andi	a5,a5,255
 29e:	4725                	li	a4,9
 2a0:	02f76963          	bltu	a4,a5,2d2 <atoi+0x46>
 2a4:	86aa                	mv	a3,a0
  n = 0;
 2a6:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2a8:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2aa:	0685                	addi	a3,a3,1
 2ac:	0025179b          	slliw	a5,a0,0x2
 2b0:	9fa9                	addw	a5,a5,a0
 2b2:	0017979b          	slliw	a5,a5,0x1
 2b6:	9fb1                	addw	a5,a5,a2
 2b8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2bc:	0006c603          	lbu	a2,0(a3)
 2c0:	fd06071b          	addiw	a4,a2,-48
 2c4:	0ff77713          	andi	a4,a4,255
 2c8:	fee5f1e3          	bgeu	a1,a4,2aa <atoi+0x1e>
  return n;
}
 2cc:	6422                	ld	s0,8(sp)
 2ce:	0141                	addi	sp,sp,16
 2d0:	8082                	ret
  n = 0;
 2d2:	4501                	li	a0,0
 2d4:	bfe5                	j	2cc <atoi+0x40>

00000000000002d6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2d6:	1141                	addi	sp,sp,-16
 2d8:	e422                	sd	s0,8(sp)
 2da:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2dc:	02b57463          	bgeu	a0,a1,304 <memmove+0x2e>
    while(n-- > 0)
 2e0:	00c05f63          	blez	a2,2fe <memmove+0x28>
 2e4:	1602                	slli	a2,a2,0x20
 2e6:	9201                	srli	a2,a2,0x20
 2e8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2ec:	872a                	mv	a4,a0
      *dst++ = *src++;
 2ee:	0585                	addi	a1,a1,1
 2f0:	0705                	addi	a4,a4,1
 2f2:	fff5c683          	lbu	a3,-1(a1)
 2f6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2fa:	fee79ae3          	bne	a5,a4,2ee <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2fe:	6422                	ld	s0,8(sp)
 300:	0141                	addi	sp,sp,16
 302:	8082                	ret
    dst += n;
 304:	00c50733          	add	a4,a0,a2
    src += n;
 308:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 30a:	fec05ae3          	blez	a2,2fe <memmove+0x28>
 30e:	fff6079b          	addiw	a5,a2,-1
 312:	1782                	slli	a5,a5,0x20
 314:	9381                	srli	a5,a5,0x20
 316:	fff7c793          	not	a5,a5
 31a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 31c:	15fd                	addi	a1,a1,-1
 31e:	177d                	addi	a4,a4,-1
 320:	0005c683          	lbu	a3,0(a1)
 324:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 328:	fee79ae3          	bne	a5,a4,31c <memmove+0x46>
 32c:	bfc9                	j	2fe <memmove+0x28>

000000000000032e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 32e:	1141                	addi	sp,sp,-16
 330:	e422                	sd	s0,8(sp)
 332:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 334:	ca05                	beqz	a2,364 <memcmp+0x36>
 336:	fff6069b          	addiw	a3,a2,-1
 33a:	1682                	slli	a3,a3,0x20
 33c:	9281                	srli	a3,a3,0x20
 33e:	0685                	addi	a3,a3,1
 340:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 342:	00054783          	lbu	a5,0(a0)
 346:	0005c703          	lbu	a4,0(a1)
 34a:	00e79863          	bne	a5,a4,35a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 34e:	0505                	addi	a0,a0,1
    p2++;
 350:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 352:	fed518e3          	bne	a0,a3,342 <memcmp+0x14>
  }
  return 0;
 356:	4501                	li	a0,0
 358:	a019                	j	35e <memcmp+0x30>
      return *p1 - *p2;
 35a:	40e7853b          	subw	a0,a5,a4
}
 35e:	6422                	ld	s0,8(sp)
 360:	0141                	addi	sp,sp,16
 362:	8082                	ret
  return 0;
 364:	4501                	li	a0,0
 366:	bfe5                	j	35e <memcmp+0x30>

0000000000000368 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 368:	1141                	addi	sp,sp,-16
 36a:	e406                	sd	ra,8(sp)
 36c:	e022                	sd	s0,0(sp)
 36e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 370:	00000097          	auipc	ra,0x0
 374:	f66080e7          	jalr	-154(ra) # 2d6 <memmove>
}
 378:	60a2                	ld	ra,8(sp)
 37a:	6402                	ld	s0,0(sp)
 37c:	0141                	addi	sp,sp,16
 37e:	8082                	ret

0000000000000380 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 380:	4885                	li	a7,1
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <exit>:
.global exit
exit:
 li a7, SYS_exit
 388:	4889                	li	a7,2
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <wait>:
.global wait
wait:
 li a7, SYS_wait
 390:	488d                	li	a7,3
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 398:	4891                	li	a7,4
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <read>:
.global read
read:
 li a7, SYS_read
 3a0:	4895                	li	a7,5
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <write>:
.global write
write:
 li a7, SYS_write
 3a8:	48c1                	li	a7,16
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <close>:
.global close
close:
 li a7, SYS_close
 3b0:	48d5                	li	a7,21
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3b8:	4899                	li	a7,6
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3c0:	489d                	li	a7,7
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <open>:
.global open
open:
 li a7, SYS_open
 3c8:	48bd                	li	a7,15
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3d0:	48c5                	li	a7,17
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3d8:	48c9                	li	a7,18
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3e0:	48a1                	li	a7,8
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <link>:
.global link
link:
 li a7, SYS_link
 3e8:	48cd                	li	a7,19
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3f0:	48d1                	li	a7,20
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3f8:	48a5                	li	a7,9
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <dup>:
.global dup
dup:
 li a7, SYS_dup
 400:	48a9                	li	a7,10
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 408:	48ad                	li	a7,11
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 410:	48b1                	li	a7,12
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 418:	48b5                	li	a7,13
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 420:	48b9                	li	a7,14
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <trace>:
.global trace
trace:
 li a7, SYS_trace
 428:	48d9                	li	a7,22
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 430:	48dd                	li	a7,23
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 438:	48e5                	li	a7,25
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 440:	48e1                	li	a7,24
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 448:	48e9                	li	a7,26
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 450:	48ed                	li	a7,27
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 458:	1101                	addi	sp,sp,-32
 45a:	ec06                	sd	ra,24(sp)
 45c:	e822                	sd	s0,16(sp)
 45e:	1000                	addi	s0,sp,32
 460:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 464:	4605                	li	a2,1
 466:	fef40593          	addi	a1,s0,-17
 46a:	00000097          	auipc	ra,0x0
 46e:	f3e080e7          	jalr	-194(ra) # 3a8 <write>
}
 472:	60e2                	ld	ra,24(sp)
 474:	6442                	ld	s0,16(sp)
 476:	6105                	addi	sp,sp,32
 478:	8082                	ret

000000000000047a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 47a:	7139                	addi	sp,sp,-64
 47c:	fc06                	sd	ra,56(sp)
 47e:	f822                	sd	s0,48(sp)
 480:	f426                	sd	s1,40(sp)
 482:	f04a                	sd	s2,32(sp)
 484:	ec4e                	sd	s3,24(sp)
 486:	0080                	addi	s0,sp,64
 488:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 48a:	c299                	beqz	a3,490 <printint+0x16>
 48c:	0805c863          	bltz	a1,51c <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 490:	2581                	sext.w	a1,a1
  neg = 0;
 492:	4881                	li	a7,0
 494:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 498:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 49a:	2601                	sext.w	a2,a2
 49c:	00000517          	auipc	a0,0x0
 4a0:	48450513          	addi	a0,a0,1156 # 920 <digits>
 4a4:	883a                	mv	a6,a4
 4a6:	2705                	addiw	a4,a4,1
 4a8:	02c5f7bb          	remuw	a5,a1,a2
 4ac:	1782                	slli	a5,a5,0x20
 4ae:	9381                	srli	a5,a5,0x20
 4b0:	97aa                	add	a5,a5,a0
 4b2:	0007c783          	lbu	a5,0(a5)
 4b6:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4ba:	0005879b          	sext.w	a5,a1
 4be:	02c5d5bb          	divuw	a1,a1,a2
 4c2:	0685                	addi	a3,a3,1
 4c4:	fec7f0e3          	bgeu	a5,a2,4a4 <printint+0x2a>
  if(neg)
 4c8:	00088b63          	beqz	a7,4de <printint+0x64>
    buf[i++] = '-';
 4cc:	fd040793          	addi	a5,s0,-48
 4d0:	973e                	add	a4,a4,a5
 4d2:	02d00793          	li	a5,45
 4d6:	fef70823          	sb	a5,-16(a4)
 4da:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4de:	02e05863          	blez	a4,50e <printint+0x94>
 4e2:	fc040793          	addi	a5,s0,-64
 4e6:	00e78933          	add	s2,a5,a4
 4ea:	fff78993          	addi	s3,a5,-1
 4ee:	99ba                	add	s3,s3,a4
 4f0:	377d                	addiw	a4,a4,-1
 4f2:	1702                	slli	a4,a4,0x20
 4f4:	9301                	srli	a4,a4,0x20
 4f6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4fa:	fff94583          	lbu	a1,-1(s2)
 4fe:	8526                	mv	a0,s1
 500:	00000097          	auipc	ra,0x0
 504:	f58080e7          	jalr	-168(ra) # 458 <putc>
  while(--i >= 0)
 508:	197d                	addi	s2,s2,-1
 50a:	ff3918e3          	bne	s2,s3,4fa <printint+0x80>
}
 50e:	70e2                	ld	ra,56(sp)
 510:	7442                	ld	s0,48(sp)
 512:	74a2                	ld	s1,40(sp)
 514:	7902                	ld	s2,32(sp)
 516:	69e2                	ld	s3,24(sp)
 518:	6121                	addi	sp,sp,64
 51a:	8082                	ret
    x = -xx;
 51c:	40b005bb          	negw	a1,a1
    neg = 1;
 520:	4885                	li	a7,1
    x = -xx;
 522:	bf8d                	j	494 <printint+0x1a>

0000000000000524 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 524:	7119                	addi	sp,sp,-128
 526:	fc86                	sd	ra,120(sp)
 528:	f8a2                	sd	s0,112(sp)
 52a:	f4a6                	sd	s1,104(sp)
 52c:	f0ca                	sd	s2,96(sp)
 52e:	ecce                	sd	s3,88(sp)
 530:	e8d2                	sd	s4,80(sp)
 532:	e4d6                	sd	s5,72(sp)
 534:	e0da                	sd	s6,64(sp)
 536:	fc5e                	sd	s7,56(sp)
 538:	f862                	sd	s8,48(sp)
 53a:	f466                	sd	s9,40(sp)
 53c:	f06a                	sd	s10,32(sp)
 53e:	ec6e                	sd	s11,24(sp)
 540:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 542:	0005c903          	lbu	s2,0(a1)
 546:	18090f63          	beqz	s2,6e4 <vprintf+0x1c0>
 54a:	8aaa                	mv	s5,a0
 54c:	8b32                	mv	s6,a2
 54e:	00158493          	addi	s1,a1,1
  state = 0;
 552:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 554:	02500a13          	li	s4,37
      if(c == 'd'){
 558:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 55c:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 560:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 564:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 568:	00000b97          	auipc	s7,0x0
 56c:	3b8b8b93          	addi	s7,s7,952 # 920 <digits>
 570:	a839                	j	58e <vprintf+0x6a>
        putc(fd, c);
 572:	85ca                	mv	a1,s2
 574:	8556                	mv	a0,s5
 576:	00000097          	auipc	ra,0x0
 57a:	ee2080e7          	jalr	-286(ra) # 458 <putc>
 57e:	a019                	j	584 <vprintf+0x60>
    } else if(state == '%'){
 580:	01498f63          	beq	s3,s4,59e <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 584:	0485                	addi	s1,s1,1
 586:	fff4c903          	lbu	s2,-1(s1)
 58a:	14090d63          	beqz	s2,6e4 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 58e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 592:	fe0997e3          	bnez	s3,580 <vprintf+0x5c>
      if(c == '%'){
 596:	fd479ee3          	bne	a5,s4,572 <vprintf+0x4e>
        state = '%';
 59a:	89be                	mv	s3,a5
 59c:	b7e5                	j	584 <vprintf+0x60>
      if(c == 'd'){
 59e:	05878063          	beq	a5,s8,5de <vprintf+0xba>
      } else if(c == 'l') {
 5a2:	05978c63          	beq	a5,s9,5fa <vprintf+0xd6>
      } else if(c == 'x') {
 5a6:	07a78863          	beq	a5,s10,616 <vprintf+0xf2>
      } else if(c == 'p') {
 5aa:	09b78463          	beq	a5,s11,632 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5ae:	07300713          	li	a4,115
 5b2:	0ce78663          	beq	a5,a4,67e <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5b6:	06300713          	li	a4,99
 5ba:	0ee78e63          	beq	a5,a4,6b6 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5be:	11478863          	beq	a5,s4,6ce <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5c2:	85d2                	mv	a1,s4
 5c4:	8556                	mv	a0,s5
 5c6:	00000097          	auipc	ra,0x0
 5ca:	e92080e7          	jalr	-366(ra) # 458 <putc>
        putc(fd, c);
 5ce:	85ca                	mv	a1,s2
 5d0:	8556                	mv	a0,s5
 5d2:	00000097          	auipc	ra,0x0
 5d6:	e86080e7          	jalr	-378(ra) # 458 <putc>
      }
      state = 0;
 5da:	4981                	li	s3,0
 5dc:	b765                	j	584 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 5de:	008b0913          	addi	s2,s6,8
 5e2:	4685                	li	a3,1
 5e4:	4629                	li	a2,10
 5e6:	000b2583          	lw	a1,0(s6)
 5ea:	8556                	mv	a0,s5
 5ec:	00000097          	auipc	ra,0x0
 5f0:	e8e080e7          	jalr	-370(ra) # 47a <printint>
 5f4:	8b4a                	mv	s6,s2
      state = 0;
 5f6:	4981                	li	s3,0
 5f8:	b771                	j	584 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5fa:	008b0913          	addi	s2,s6,8
 5fe:	4681                	li	a3,0
 600:	4629                	li	a2,10
 602:	000b2583          	lw	a1,0(s6)
 606:	8556                	mv	a0,s5
 608:	00000097          	auipc	ra,0x0
 60c:	e72080e7          	jalr	-398(ra) # 47a <printint>
 610:	8b4a                	mv	s6,s2
      state = 0;
 612:	4981                	li	s3,0
 614:	bf85                	j	584 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 616:	008b0913          	addi	s2,s6,8
 61a:	4681                	li	a3,0
 61c:	4641                	li	a2,16
 61e:	000b2583          	lw	a1,0(s6)
 622:	8556                	mv	a0,s5
 624:	00000097          	auipc	ra,0x0
 628:	e56080e7          	jalr	-426(ra) # 47a <printint>
 62c:	8b4a                	mv	s6,s2
      state = 0;
 62e:	4981                	li	s3,0
 630:	bf91                	j	584 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 632:	008b0793          	addi	a5,s6,8
 636:	f8f43423          	sd	a5,-120(s0)
 63a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 63e:	03000593          	li	a1,48
 642:	8556                	mv	a0,s5
 644:	00000097          	auipc	ra,0x0
 648:	e14080e7          	jalr	-492(ra) # 458 <putc>
  putc(fd, 'x');
 64c:	85ea                	mv	a1,s10
 64e:	8556                	mv	a0,s5
 650:	00000097          	auipc	ra,0x0
 654:	e08080e7          	jalr	-504(ra) # 458 <putc>
 658:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 65a:	03c9d793          	srli	a5,s3,0x3c
 65e:	97de                	add	a5,a5,s7
 660:	0007c583          	lbu	a1,0(a5)
 664:	8556                	mv	a0,s5
 666:	00000097          	auipc	ra,0x0
 66a:	df2080e7          	jalr	-526(ra) # 458 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 66e:	0992                	slli	s3,s3,0x4
 670:	397d                	addiw	s2,s2,-1
 672:	fe0914e3          	bnez	s2,65a <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 676:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 67a:	4981                	li	s3,0
 67c:	b721                	j	584 <vprintf+0x60>
        s = va_arg(ap, char*);
 67e:	008b0993          	addi	s3,s6,8
 682:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 686:	02090163          	beqz	s2,6a8 <vprintf+0x184>
        while(*s != 0){
 68a:	00094583          	lbu	a1,0(s2)
 68e:	c9a1                	beqz	a1,6de <vprintf+0x1ba>
          putc(fd, *s);
 690:	8556                	mv	a0,s5
 692:	00000097          	auipc	ra,0x0
 696:	dc6080e7          	jalr	-570(ra) # 458 <putc>
          s++;
 69a:	0905                	addi	s2,s2,1
        while(*s != 0){
 69c:	00094583          	lbu	a1,0(s2)
 6a0:	f9e5                	bnez	a1,690 <vprintf+0x16c>
        s = va_arg(ap, char*);
 6a2:	8b4e                	mv	s6,s3
      state = 0;
 6a4:	4981                	li	s3,0
 6a6:	bdf9                	j	584 <vprintf+0x60>
          s = "(null)";
 6a8:	00000917          	auipc	s2,0x0
 6ac:	27090913          	addi	s2,s2,624 # 918 <malloc+0x12a>
        while(*s != 0){
 6b0:	02800593          	li	a1,40
 6b4:	bff1                	j	690 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 6b6:	008b0913          	addi	s2,s6,8
 6ba:	000b4583          	lbu	a1,0(s6)
 6be:	8556                	mv	a0,s5
 6c0:	00000097          	auipc	ra,0x0
 6c4:	d98080e7          	jalr	-616(ra) # 458 <putc>
 6c8:	8b4a                	mv	s6,s2
      state = 0;
 6ca:	4981                	li	s3,0
 6cc:	bd65                	j	584 <vprintf+0x60>
        putc(fd, c);
 6ce:	85d2                	mv	a1,s4
 6d0:	8556                	mv	a0,s5
 6d2:	00000097          	auipc	ra,0x0
 6d6:	d86080e7          	jalr	-634(ra) # 458 <putc>
      state = 0;
 6da:	4981                	li	s3,0
 6dc:	b565                	j	584 <vprintf+0x60>
        s = va_arg(ap, char*);
 6de:	8b4e                	mv	s6,s3
      state = 0;
 6e0:	4981                	li	s3,0
 6e2:	b54d                	j	584 <vprintf+0x60>
    }
  }
}
 6e4:	70e6                	ld	ra,120(sp)
 6e6:	7446                	ld	s0,112(sp)
 6e8:	74a6                	ld	s1,104(sp)
 6ea:	7906                	ld	s2,96(sp)
 6ec:	69e6                	ld	s3,88(sp)
 6ee:	6a46                	ld	s4,80(sp)
 6f0:	6aa6                	ld	s5,72(sp)
 6f2:	6b06                	ld	s6,64(sp)
 6f4:	7be2                	ld	s7,56(sp)
 6f6:	7c42                	ld	s8,48(sp)
 6f8:	7ca2                	ld	s9,40(sp)
 6fa:	7d02                	ld	s10,32(sp)
 6fc:	6de2                	ld	s11,24(sp)
 6fe:	6109                	addi	sp,sp,128
 700:	8082                	ret

0000000000000702 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 702:	715d                	addi	sp,sp,-80
 704:	ec06                	sd	ra,24(sp)
 706:	e822                	sd	s0,16(sp)
 708:	1000                	addi	s0,sp,32
 70a:	e010                	sd	a2,0(s0)
 70c:	e414                	sd	a3,8(s0)
 70e:	e818                	sd	a4,16(s0)
 710:	ec1c                	sd	a5,24(s0)
 712:	03043023          	sd	a6,32(s0)
 716:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 71a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 71e:	8622                	mv	a2,s0
 720:	00000097          	auipc	ra,0x0
 724:	e04080e7          	jalr	-508(ra) # 524 <vprintf>
}
 728:	60e2                	ld	ra,24(sp)
 72a:	6442                	ld	s0,16(sp)
 72c:	6161                	addi	sp,sp,80
 72e:	8082                	ret

0000000000000730 <printf>:

void
printf(const char *fmt, ...)
{
 730:	711d                	addi	sp,sp,-96
 732:	ec06                	sd	ra,24(sp)
 734:	e822                	sd	s0,16(sp)
 736:	1000                	addi	s0,sp,32
 738:	e40c                	sd	a1,8(s0)
 73a:	e810                	sd	a2,16(s0)
 73c:	ec14                	sd	a3,24(s0)
 73e:	f018                	sd	a4,32(s0)
 740:	f41c                	sd	a5,40(s0)
 742:	03043823          	sd	a6,48(s0)
 746:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 74a:	00840613          	addi	a2,s0,8
 74e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 752:	85aa                	mv	a1,a0
 754:	4505                	li	a0,1
 756:	00000097          	auipc	ra,0x0
 75a:	dce080e7          	jalr	-562(ra) # 524 <vprintf>
}
 75e:	60e2                	ld	ra,24(sp)
 760:	6442                	ld	s0,16(sp)
 762:	6125                	addi	sp,sp,96
 764:	8082                	ret

0000000000000766 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 766:	1141                	addi	sp,sp,-16
 768:	e422                	sd	s0,8(sp)
 76a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 76c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 770:	00001797          	auipc	a5,0x1
 774:	8907b783          	ld	a5,-1904(a5) # 1000 <freep>
 778:	a805                	j	7a8 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 77a:	4618                	lw	a4,8(a2)
 77c:	9db9                	addw	a1,a1,a4
 77e:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 782:	6398                	ld	a4,0(a5)
 784:	6318                	ld	a4,0(a4)
 786:	fee53823          	sd	a4,-16(a0)
 78a:	a091                	j	7ce <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 78c:	ff852703          	lw	a4,-8(a0)
 790:	9e39                	addw	a2,a2,a4
 792:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 794:	ff053703          	ld	a4,-16(a0)
 798:	e398                	sd	a4,0(a5)
 79a:	a099                	j	7e0 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 79c:	6398                	ld	a4,0(a5)
 79e:	00e7e463          	bltu	a5,a4,7a6 <free+0x40>
 7a2:	00e6ea63          	bltu	a3,a4,7b6 <free+0x50>
{
 7a6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a8:	fed7fae3          	bgeu	a5,a3,79c <free+0x36>
 7ac:	6398                	ld	a4,0(a5)
 7ae:	00e6e463          	bltu	a3,a4,7b6 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7b2:	fee7eae3          	bltu	a5,a4,7a6 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7b6:	ff852583          	lw	a1,-8(a0)
 7ba:	6390                	ld	a2,0(a5)
 7bc:	02059713          	slli	a4,a1,0x20
 7c0:	9301                	srli	a4,a4,0x20
 7c2:	0712                	slli	a4,a4,0x4
 7c4:	9736                	add	a4,a4,a3
 7c6:	fae60ae3          	beq	a2,a4,77a <free+0x14>
    bp->s.ptr = p->s.ptr;
 7ca:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7ce:	4790                	lw	a2,8(a5)
 7d0:	02061713          	slli	a4,a2,0x20
 7d4:	9301                	srli	a4,a4,0x20
 7d6:	0712                	slli	a4,a4,0x4
 7d8:	973e                	add	a4,a4,a5
 7da:	fae689e3          	beq	a3,a4,78c <free+0x26>
  } else
    p->s.ptr = bp;
 7de:	e394                	sd	a3,0(a5)
  freep = p;
 7e0:	00001717          	auipc	a4,0x1
 7e4:	82f73023          	sd	a5,-2016(a4) # 1000 <freep>
}
 7e8:	6422                	ld	s0,8(sp)
 7ea:	0141                	addi	sp,sp,16
 7ec:	8082                	ret

00000000000007ee <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7ee:	7139                	addi	sp,sp,-64
 7f0:	fc06                	sd	ra,56(sp)
 7f2:	f822                	sd	s0,48(sp)
 7f4:	f426                	sd	s1,40(sp)
 7f6:	f04a                	sd	s2,32(sp)
 7f8:	ec4e                	sd	s3,24(sp)
 7fa:	e852                	sd	s4,16(sp)
 7fc:	e456                	sd	s5,8(sp)
 7fe:	e05a                	sd	s6,0(sp)
 800:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 802:	02051493          	slli	s1,a0,0x20
 806:	9081                	srli	s1,s1,0x20
 808:	04bd                	addi	s1,s1,15
 80a:	8091                	srli	s1,s1,0x4
 80c:	0014899b          	addiw	s3,s1,1
 810:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 812:	00000517          	auipc	a0,0x0
 816:	7ee53503          	ld	a0,2030(a0) # 1000 <freep>
 81a:	c515                	beqz	a0,846 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 81c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 81e:	4798                	lw	a4,8(a5)
 820:	02977f63          	bgeu	a4,s1,85e <malloc+0x70>
 824:	8a4e                	mv	s4,s3
 826:	0009871b          	sext.w	a4,s3
 82a:	6685                	lui	a3,0x1
 82c:	00d77363          	bgeu	a4,a3,832 <malloc+0x44>
 830:	6a05                	lui	s4,0x1
 832:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 836:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 83a:	00000917          	auipc	s2,0x0
 83e:	7c690913          	addi	s2,s2,1990 # 1000 <freep>
  if(p == (char*)-1)
 842:	5afd                	li	s5,-1
 844:	a88d                	j	8b6 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 846:	00000797          	auipc	a5,0x0
 84a:	7ca78793          	addi	a5,a5,1994 # 1010 <base>
 84e:	00000717          	auipc	a4,0x0
 852:	7af73923          	sd	a5,1970(a4) # 1000 <freep>
 856:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 858:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 85c:	b7e1                	j	824 <malloc+0x36>
      if(p->s.size == nunits)
 85e:	02e48b63          	beq	s1,a4,894 <malloc+0xa6>
        p->s.size -= nunits;
 862:	4137073b          	subw	a4,a4,s3
 866:	c798                	sw	a4,8(a5)
        p += p->s.size;
 868:	1702                	slli	a4,a4,0x20
 86a:	9301                	srli	a4,a4,0x20
 86c:	0712                	slli	a4,a4,0x4
 86e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 870:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 874:	00000717          	auipc	a4,0x0
 878:	78a73623          	sd	a0,1932(a4) # 1000 <freep>
      return (void*)(p + 1);
 87c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 880:	70e2                	ld	ra,56(sp)
 882:	7442                	ld	s0,48(sp)
 884:	74a2                	ld	s1,40(sp)
 886:	7902                	ld	s2,32(sp)
 888:	69e2                	ld	s3,24(sp)
 88a:	6a42                	ld	s4,16(sp)
 88c:	6aa2                	ld	s5,8(sp)
 88e:	6b02                	ld	s6,0(sp)
 890:	6121                	addi	sp,sp,64
 892:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 894:	6398                	ld	a4,0(a5)
 896:	e118                	sd	a4,0(a0)
 898:	bff1                	j	874 <malloc+0x86>
  hp->s.size = nu;
 89a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 89e:	0541                	addi	a0,a0,16
 8a0:	00000097          	auipc	ra,0x0
 8a4:	ec6080e7          	jalr	-314(ra) # 766 <free>
  return freep;
 8a8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8ac:	d971                	beqz	a0,880 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ae:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8b0:	4798                	lw	a4,8(a5)
 8b2:	fa9776e3          	bgeu	a4,s1,85e <malloc+0x70>
    if(p == freep)
 8b6:	00093703          	ld	a4,0(s2)
 8ba:	853e                	mv	a0,a5
 8bc:	fef719e3          	bne	a4,a5,8ae <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 8c0:	8552                	mv	a0,s4
 8c2:	00000097          	auipc	ra,0x0
 8c6:	b4e080e7          	jalr	-1202(ra) # 410 <sbrk>
  if(p == (char*)-1)
 8ca:	fd5518e3          	bne	a0,s5,89a <malloc+0xac>
        return 0;
 8ce:	4501                	li	a0,0
 8d0:	bf45                	j	880 <malloc+0x92>

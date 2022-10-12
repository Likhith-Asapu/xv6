
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
    if(n == 4)
  10:	4911                	li	s2,4
  for(n=0; n < NFORK;n++) {
  12:	49a9                	li	s3,10
  14:	a00d                	j	36 <main+0x36>
        settickets(400);
  16:	19000513          	li	a0,400
  1a:	00000097          	auipc	ra,0x0
  1e:	422080e7          	jalr	1058(ra) # 43c <settickets>
      else
        settickets(1);
      pid = fork();
  22:	00000097          	auipc	ra,0x0
  26:	352080e7          	jalr	850(ra) # 374 <fork>
      if (pid < 0)
  2a:	06054263          	bltz	a0,8e <main+0x8e>
          break;
      if (pid == 0) {
  2e:	cd01                	beqz	a0,46 <main+0x46>
  for(n=0; n < NFORK;n++) {
  30:	2485                	addiw	s1,s1,1
  32:	07348063          	beq	s1,s3,92 <main+0x92>
    if(n == 4)
  36:	ff2480e3          	beq	s1,s2,16 <main+0x16>
        settickets(1);
  3a:	4505                	li	a0,1
  3c:	00000097          	auipc	ra,0x0
  40:	400080e7          	jalr	1024(ra) # 43c <settickets>
  44:	bff9                	j	22 <main+0x22>
#ifndef LOTTERY
          if (n < IO) {
            sleep(200); // IO bound processes
          } else {
#endif
            for (volatile int i = 0; i < 1000000000; i++) {} // CPU bound process 
  46:	fc042223          	sw	zero,-60(s0)
  4a:	fc442703          	lw	a4,-60(s0)
  4e:	2701                	sext.w	a4,a4
  50:	3b9ad7b7          	lui	a5,0x3b9ad
  54:	9ff78793          	addi	a5,a5,-1537 # 3b9ac9ff <base+0x3b9ab9ef>
  58:	00e7cd63          	blt	a5,a4,72 <main+0x72>
  5c:	873e                	mv	a4,a5
  5e:	fc442783          	lw	a5,-60(s0)
  62:	2785                	addiw	a5,a5,1
  64:	fcf42223          	sw	a5,-60(s0)
  68:	fc442783          	lw	a5,-60(s0)
  6c:	2781                	sext.w	a5,a5
  6e:	fef758e3          	bge	a4,a5,5e <main+0x5e>
#ifndef LOTTERY
          }
#endif
          printf("Process %d finished\n", n);
  72:	85a6                	mv	a1,s1
  74:	00001517          	auipc	a0,0x1
  78:	85c50513          	addi	a0,a0,-1956 # 8d0 <malloc+0xee>
  7c:	00000097          	auipc	ra,0x0
  80:	6a8080e7          	jalr	1704(ra) # 724 <printf>
          exit(0);
  84:	4501                	li	a0,0
  86:	00000097          	auipc	ra,0x0
  8a:	2f6080e7          	jalr	758(ra) # 37c <exit>
#ifdef PBS
        setpriority(80, pid); // Will only matter for PBS, set lower priority for IO bound processes 
#endif
      }
  }
  for(;n > 0; n--) {
  8e:	02905b63          	blez	s1,c4 <main+0xc4>
  for(n=0; n < NFORK;n++) {
  92:	4901                	li	s2,0
  94:	4981                	li	s3,0
  96:	a019                	j	9c <main+0x9c>
  for(;n > 0; n--) {
  98:	34fd                	addiw	s1,s1,-1
  9a:	c49d                	beqz	s1,c8 <main+0xc8>
      if(waitx(0,&wtime,&rtime) >= 0) {
  9c:	fc840613          	addi	a2,s0,-56
  a0:	fcc40593          	addi	a1,s0,-52
  a4:	4501                	li	a0,0
  a6:	00000097          	auipc	ra,0x0
  aa:	37e080e7          	jalr	894(ra) # 424 <waitx>
  ae:	fe0545e3          	bltz	a0,98 <main+0x98>
          trtime += rtime;
  b2:	fc842783          	lw	a5,-56(s0)
  b6:	0127893b          	addw	s2,a5,s2
          twtime += wtime;
  ba:	fcc42783          	lw	a5,-52(s0)
  be:	013789bb          	addw	s3,a5,s3
  c2:	bfd9                	j	98 <main+0x98>
  for(;n > 0; n--) {
  c4:	4901                	li	s2,0
  c6:	4981                	li	s3,0
      } 
  }
  printf("Average rtime %d,  wtime %d\n", trtime / NFORK, twtime / NFORK);
  c8:	45a9                	li	a1,10
  ca:	02b9c63b          	divw	a2,s3,a1
  ce:	02b945bb          	divw	a1,s2,a1
  d2:	00001517          	auipc	a0,0x1
  d6:	81650513          	addi	a0,a0,-2026 # 8e8 <malloc+0x106>
  da:	00000097          	auipc	ra,0x0
  de:	64a080e7          	jalr	1610(ra) # 724 <printf>
  exit(0);
  e2:	4501                	li	a0,0
  e4:	00000097          	auipc	ra,0x0
  e8:	298080e7          	jalr	664(ra) # 37c <exit>

00000000000000ec <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  ec:	1141                	addi	sp,sp,-16
  ee:	e406                	sd	ra,8(sp)
  f0:	e022                	sd	s0,0(sp)
  f2:	0800                	addi	s0,sp,16
  extern int main();
  main();
  f4:	00000097          	auipc	ra,0x0
  f8:	f0c080e7          	jalr	-244(ra) # 0 <main>
  exit(0);
  fc:	4501                	li	a0,0
  fe:	00000097          	auipc	ra,0x0
 102:	27e080e7          	jalr	638(ra) # 37c <exit>

0000000000000106 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 106:	1141                	addi	sp,sp,-16
 108:	e422                	sd	s0,8(sp)
 10a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 10c:	87aa                	mv	a5,a0
 10e:	0585                	addi	a1,a1,1
 110:	0785                	addi	a5,a5,1
 112:	fff5c703          	lbu	a4,-1(a1)
 116:	fee78fa3          	sb	a4,-1(a5)
 11a:	fb75                	bnez	a4,10e <strcpy+0x8>
    ;
  return os;
}
 11c:	6422                	ld	s0,8(sp)
 11e:	0141                	addi	sp,sp,16
 120:	8082                	ret

0000000000000122 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 122:	1141                	addi	sp,sp,-16
 124:	e422                	sd	s0,8(sp)
 126:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 128:	00054783          	lbu	a5,0(a0)
 12c:	cb91                	beqz	a5,140 <strcmp+0x1e>
 12e:	0005c703          	lbu	a4,0(a1)
 132:	00f71763          	bne	a4,a5,140 <strcmp+0x1e>
    p++, q++;
 136:	0505                	addi	a0,a0,1
 138:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 13a:	00054783          	lbu	a5,0(a0)
 13e:	fbe5                	bnez	a5,12e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 140:	0005c503          	lbu	a0,0(a1)
}
 144:	40a7853b          	subw	a0,a5,a0
 148:	6422                	ld	s0,8(sp)
 14a:	0141                	addi	sp,sp,16
 14c:	8082                	ret

000000000000014e <strlen>:

uint
strlen(const char *s)
{
 14e:	1141                	addi	sp,sp,-16
 150:	e422                	sd	s0,8(sp)
 152:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 154:	00054783          	lbu	a5,0(a0)
 158:	cf91                	beqz	a5,174 <strlen+0x26>
 15a:	0505                	addi	a0,a0,1
 15c:	87aa                	mv	a5,a0
 15e:	4685                	li	a3,1
 160:	9e89                	subw	a3,a3,a0
 162:	00f6853b          	addw	a0,a3,a5
 166:	0785                	addi	a5,a5,1
 168:	fff7c703          	lbu	a4,-1(a5)
 16c:	fb7d                	bnez	a4,162 <strlen+0x14>
    ;
  return n;
}
 16e:	6422                	ld	s0,8(sp)
 170:	0141                	addi	sp,sp,16
 172:	8082                	ret
  for(n = 0; s[n]; n++)
 174:	4501                	li	a0,0
 176:	bfe5                	j	16e <strlen+0x20>

0000000000000178 <memset>:

void*
memset(void *dst, int c, uint n)
{
 178:	1141                	addi	sp,sp,-16
 17a:	e422                	sd	s0,8(sp)
 17c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 17e:	ce09                	beqz	a2,198 <memset+0x20>
 180:	87aa                	mv	a5,a0
 182:	fff6071b          	addiw	a4,a2,-1
 186:	1702                	slli	a4,a4,0x20
 188:	9301                	srli	a4,a4,0x20
 18a:	0705                	addi	a4,a4,1
 18c:	972a                	add	a4,a4,a0
    cdst[i] = c;
 18e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 192:	0785                	addi	a5,a5,1
 194:	fee79de3          	bne	a5,a4,18e <memset+0x16>
  }
  return dst;
}
 198:	6422                	ld	s0,8(sp)
 19a:	0141                	addi	sp,sp,16
 19c:	8082                	ret

000000000000019e <strchr>:

char*
strchr(const char *s, char c)
{
 19e:	1141                	addi	sp,sp,-16
 1a0:	e422                	sd	s0,8(sp)
 1a2:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1a4:	00054783          	lbu	a5,0(a0)
 1a8:	cb99                	beqz	a5,1be <strchr+0x20>
    if(*s == c)
 1aa:	00f58763          	beq	a1,a5,1b8 <strchr+0x1a>
  for(; *s; s++)
 1ae:	0505                	addi	a0,a0,1
 1b0:	00054783          	lbu	a5,0(a0)
 1b4:	fbfd                	bnez	a5,1aa <strchr+0xc>
      return (char*)s;
  return 0;
 1b6:	4501                	li	a0,0
}
 1b8:	6422                	ld	s0,8(sp)
 1ba:	0141                	addi	sp,sp,16
 1bc:	8082                	ret
  return 0;
 1be:	4501                	li	a0,0
 1c0:	bfe5                	j	1b8 <strchr+0x1a>

00000000000001c2 <gets>:

char*
gets(char *buf, int max)
{
 1c2:	711d                	addi	sp,sp,-96
 1c4:	ec86                	sd	ra,88(sp)
 1c6:	e8a2                	sd	s0,80(sp)
 1c8:	e4a6                	sd	s1,72(sp)
 1ca:	e0ca                	sd	s2,64(sp)
 1cc:	fc4e                	sd	s3,56(sp)
 1ce:	f852                	sd	s4,48(sp)
 1d0:	f456                	sd	s5,40(sp)
 1d2:	f05a                	sd	s6,32(sp)
 1d4:	ec5e                	sd	s7,24(sp)
 1d6:	1080                	addi	s0,sp,96
 1d8:	8baa                	mv	s7,a0
 1da:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1dc:	892a                	mv	s2,a0
 1de:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1e0:	4aa9                	li	s5,10
 1e2:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1e4:	89a6                	mv	s3,s1
 1e6:	2485                	addiw	s1,s1,1
 1e8:	0344d863          	bge	s1,s4,218 <gets+0x56>
    cc = read(0, &c, 1);
 1ec:	4605                	li	a2,1
 1ee:	faf40593          	addi	a1,s0,-81
 1f2:	4501                	li	a0,0
 1f4:	00000097          	auipc	ra,0x0
 1f8:	1a0080e7          	jalr	416(ra) # 394 <read>
    if(cc < 1)
 1fc:	00a05e63          	blez	a0,218 <gets+0x56>
    buf[i++] = c;
 200:	faf44783          	lbu	a5,-81(s0)
 204:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 208:	01578763          	beq	a5,s5,216 <gets+0x54>
 20c:	0905                	addi	s2,s2,1
 20e:	fd679be3          	bne	a5,s6,1e4 <gets+0x22>
  for(i=0; i+1 < max; ){
 212:	89a6                	mv	s3,s1
 214:	a011                	j	218 <gets+0x56>
 216:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 218:	99de                	add	s3,s3,s7
 21a:	00098023          	sb	zero,0(s3)
  return buf;
}
 21e:	855e                	mv	a0,s7
 220:	60e6                	ld	ra,88(sp)
 222:	6446                	ld	s0,80(sp)
 224:	64a6                	ld	s1,72(sp)
 226:	6906                	ld	s2,64(sp)
 228:	79e2                	ld	s3,56(sp)
 22a:	7a42                	ld	s4,48(sp)
 22c:	7aa2                	ld	s5,40(sp)
 22e:	7b02                	ld	s6,32(sp)
 230:	6be2                	ld	s7,24(sp)
 232:	6125                	addi	sp,sp,96
 234:	8082                	ret

0000000000000236 <stat>:

int
stat(const char *n, struct stat *st)
{
 236:	1101                	addi	sp,sp,-32
 238:	ec06                	sd	ra,24(sp)
 23a:	e822                	sd	s0,16(sp)
 23c:	e426                	sd	s1,8(sp)
 23e:	e04a                	sd	s2,0(sp)
 240:	1000                	addi	s0,sp,32
 242:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 244:	4581                	li	a1,0
 246:	00000097          	auipc	ra,0x0
 24a:	176080e7          	jalr	374(ra) # 3bc <open>
  if(fd < 0)
 24e:	02054563          	bltz	a0,278 <stat+0x42>
 252:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 254:	85ca                	mv	a1,s2
 256:	00000097          	auipc	ra,0x0
 25a:	17e080e7          	jalr	382(ra) # 3d4 <fstat>
 25e:	892a                	mv	s2,a0
  close(fd);
 260:	8526                	mv	a0,s1
 262:	00000097          	auipc	ra,0x0
 266:	142080e7          	jalr	322(ra) # 3a4 <close>
  return r;
}
 26a:	854a                	mv	a0,s2
 26c:	60e2                	ld	ra,24(sp)
 26e:	6442                	ld	s0,16(sp)
 270:	64a2                	ld	s1,8(sp)
 272:	6902                	ld	s2,0(sp)
 274:	6105                	addi	sp,sp,32
 276:	8082                	ret
    return -1;
 278:	597d                	li	s2,-1
 27a:	bfc5                	j	26a <stat+0x34>

000000000000027c <atoi>:

int
atoi(const char *s)
{
 27c:	1141                	addi	sp,sp,-16
 27e:	e422                	sd	s0,8(sp)
 280:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 282:	00054603          	lbu	a2,0(a0)
 286:	fd06079b          	addiw	a5,a2,-48
 28a:	0ff7f793          	andi	a5,a5,255
 28e:	4725                	li	a4,9
 290:	02f76963          	bltu	a4,a5,2c2 <atoi+0x46>
 294:	86aa                	mv	a3,a0
  n = 0;
 296:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 298:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 29a:	0685                	addi	a3,a3,1
 29c:	0025179b          	slliw	a5,a0,0x2
 2a0:	9fa9                	addw	a5,a5,a0
 2a2:	0017979b          	slliw	a5,a5,0x1
 2a6:	9fb1                	addw	a5,a5,a2
 2a8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2ac:	0006c603          	lbu	a2,0(a3)
 2b0:	fd06071b          	addiw	a4,a2,-48
 2b4:	0ff77713          	andi	a4,a4,255
 2b8:	fee5f1e3          	bgeu	a1,a4,29a <atoi+0x1e>
  return n;
}
 2bc:	6422                	ld	s0,8(sp)
 2be:	0141                	addi	sp,sp,16
 2c0:	8082                	ret
  n = 0;
 2c2:	4501                	li	a0,0
 2c4:	bfe5                	j	2bc <atoi+0x40>

00000000000002c6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2c6:	1141                	addi	sp,sp,-16
 2c8:	e422                	sd	s0,8(sp)
 2ca:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2cc:	02b57663          	bgeu	a0,a1,2f8 <memmove+0x32>
    while(n-- > 0)
 2d0:	02c05163          	blez	a2,2f2 <memmove+0x2c>
 2d4:	fff6079b          	addiw	a5,a2,-1
 2d8:	1782                	slli	a5,a5,0x20
 2da:	9381                	srli	a5,a5,0x20
 2dc:	0785                	addi	a5,a5,1
 2de:	97aa                	add	a5,a5,a0
  dst = vdst;
 2e0:	872a                	mv	a4,a0
      *dst++ = *src++;
 2e2:	0585                	addi	a1,a1,1
 2e4:	0705                	addi	a4,a4,1
 2e6:	fff5c683          	lbu	a3,-1(a1)
 2ea:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2ee:	fee79ae3          	bne	a5,a4,2e2 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2f2:	6422                	ld	s0,8(sp)
 2f4:	0141                	addi	sp,sp,16
 2f6:	8082                	ret
    dst += n;
 2f8:	00c50733          	add	a4,a0,a2
    src += n;
 2fc:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2fe:	fec05ae3          	blez	a2,2f2 <memmove+0x2c>
 302:	fff6079b          	addiw	a5,a2,-1
 306:	1782                	slli	a5,a5,0x20
 308:	9381                	srli	a5,a5,0x20
 30a:	fff7c793          	not	a5,a5
 30e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 310:	15fd                	addi	a1,a1,-1
 312:	177d                	addi	a4,a4,-1
 314:	0005c683          	lbu	a3,0(a1)
 318:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 31c:	fee79ae3          	bne	a5,a4,310 <memmove+0x4a>
 320:	bfc9                	j	2f2 <memmove+0x2c>

0000000000000322 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 322:	1141                	addi	sp,sp,-16
 324:	e422                	sd	s0,8(sp)
 326:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 328:	ca05                	beqz	a2,358 <memcmp+0x36>
 32a:	fff6069b          	addiw	a3,a2,-1
 32e:	1682                	slli	a3,a3,0x20
 330:	9281                	srli	a3,a3,0x20
 332:	0685                	addi	a3,a3,1
 334:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 336:	00054783          	lbu	a5,0(a0)
 33a:	0005c703          	lbu	a4,0(a1)
 33e:	00e79863          	bne	a5,a4,34e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 342:	0505                	addi	a0,a0,1
    p2++;
 344:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 346:	fed518e3          	bne	a0,a3,336 <memcmp+0x14>
  }
  return 0;
 34a:	4501                	li	a0,0
 34c:	a019                	j	352 <memcmp+0x30>
      return *p1 - *p2;
 34e:	40e7853b          	subw	a0,a5,a4
}
 352:	6422                	ld	s0,8(sp)
 354:	0141                	addi	sp,sp,16
 356:	8082                	ret
  return 0;
 358:	4501                	li	a0,0
 35a:	bfe5                	j	352 <memcmp+0x30>

000000000000035c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 35c:	1141                	addi	sp,sp,-16
 35e:	e406                	sd	ra,8(sp)
 360:	e022                	sd	s0,0(sp)
 362:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 364:	00000097          	auipc	ra,0x0
 368:	f62080e7          	jalr	-158(ra) # 2c6 <memmove>
}
 36c:	60a2                	ld	ra,8(sp)
 36e:	6402                	ld	s0,0(sp)
 370:	0141                	addi	sp,sp,16
 372:	8082                	ret

0000000000000374 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 374:	4885                	li	a7,1
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <exit>:
.global exit
exit:
 li a7, SYS_exit
 37c:	4889                	li	a7,2
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <wait>:
.global wait
wait:
 li a7, SYS_wait
 384:	488d                	li	a7,3
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 38c:	4891                	li	a7,4
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <read>:
.global read
read:
 li a7, SYS_read
 394:	4895                	li	a7,5
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <write>:
.global write
write:
 li a7, SYS_write
 39c:	48c1                	li	a7,16
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <close>:
.global close
close:
 li a7, SYS_close
 3a4:	48d5                	li	a7,21
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <kill>:
.global kill
kill:
 li a7, SYS_kill
 3ac:	4899                	li	a7,6
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3b4:	489d                	li	a7,7
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <open>:
.global open
open:
 li a7, SYS_open
 3bc:	48bd                	li	a7,15
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3c4:	48c5                	li	a7,17
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3cc:	48c9                	li	a7,18
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3d4:	48a1                	li	a7,8
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <link>:
.global link
link:
 li a7, SYS_link
 3dc:	48cd                	li	a7,19
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3e4:	48d1                	li	a7,20
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3ec:	48a5                	li	a7,9
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3f4:	48a9                	li	a7,10
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3fc:	48ad                	li	a7,11
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 404:	48b1                	li	a7,12
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 40c:	48b5                	li	a7,13
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 414:	48b9                	li	a7,14
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <trace>:
.global trace
trace:
 li a7, SYS_trace
 41c:	48d9                	li	a7,22
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 424:	48dd                	li	a7,23
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 42c:	48e5                	li	a7,25
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 434:	48e1                	li	a7,24
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 43c:	48e9                	li	a7,26
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 444:	48ed                	li	a7,27
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 44c:	1101                	addi	sp,sp,-32
 44e:	ec06                	sd	ra,24(sp)
 450:	e822                	sd	s0,16(sp)
 452:	1000                	addi	s0,sp,32
 454:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 458:	4605                	li	a2,1
 45a:	fef40593          	addi	a1,s0,-17
 45e:	00000097          	auipc	ra,0x0
 462:	f3e080e7          	jalr	-194(ra) # 39c <write>
}
 466:	60e2                	ld	ra,24(sp)
 468:	6442                	ld	s0,16(sp)
 46a:	6105                	addi	sp,sp,32
 46c:	8082                	ret

000000000000046e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 46e:	7139                	addi	sp,sp,-64
 470:	fc06                	sd	ra,56(sp)
 472:	f822                	sd	s0,48(sp)
 474:	f426                	sd	s1,40(sp)
 476:	f04a                	sd	s2,32(sp)
 478:	ec4e                	sd	s3,24(sp)
 47a:	0080                	addi	s0,sp,64
 47c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 47e:	c299                	beqz	a3,484 <printint+0x16>
 480:	0805c863          	bltz	a1,510 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 484:	2581                	sext.w	a1,a1
  neg = 0;
 486:	4881                	li	a7,0
 488:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 48c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 48e:	2601                	sext.w	a2,a2
 490:	00000517          	auipc	a0,0x0
 494:	48050513          	addi	a0,a0,1152 # 910 <digits>
 498:	883a                	mv	a6,a4
 49a:	2705                	addiw	a4,a4,1
 49c:	02c5f7bb          	remuw	a5,a1,a2
 4a0:	1782                	slli	a5,a5,0x20
 4a2:	9381                	srli	a5,a5,0x20
 4a4:	97aa                	add	a5,a5,a0
 4a6:	0007c783          	lbu	a5,0(a5)
 4aa:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4ae:	0005879b          	sext.w	a5,a1
 4b2:	02c5d5bb          	divuw	a1,a1,a2
 4b6:	0685                	addi	a3,a3,1
 4b8:	fec7f0e3          	bgeu	a5,a2,498 <printint+0x2a>
  if(neg)
 4bc:	00088b63          	beqz	a7,4d2 <printint+0x64>
    buf[i++] = '-';
 4c0:	fd040793          	addi	a5,s0,-48
 4c4:	973e                	add	a4,a4,a5
 4c6:	02d00793          	li	a5,45
 4ca:	fef70823          	sb	a5,-16(a4)
 4ce:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4d2:	02e05863          	blez	a4,502 <printint+0x94>
 4d6:	fc040793          	addi	a5,s0,-64
 4da:	00e78933          	add	s2,a5,a4
 4de:	fff78993          	addi	s3,a5,-1
 4e2:	99ba                	add	s3,s3,a4
 4e4:	377d                	addiw	a4,a4,-1
 4e6:	1702                	slli	a4,a4,0x20
 4e8:	9301                	srli	a4,a4,0x20
 4ea:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4ee:	fff94583          	lbu	a1,-1(s2)
 4f2:	8526                	mv	a0,s1
 4f4:	00000097          	auipc	ra,0x0
 4f8:	f58080e7          	jalr	-168(ra) # 44c <putc>
  while(--i >= 0)
 4fc:	197d                	addi	s2,s2,-1
 4fe:	ff3918e3          	bne	s2,s3,4ee <printint+0x80>
}
 502:	70e2                	ld	ra,56(sp)
 504:	7442                	ld	s0,48(sp)
 506:	74a2                	ld	s1,40(sp)
 508:	7902                	ld	s2,32(sp)
 50a:	69e2                	ld	s3,24(sp)
 50c:	6121                	addi	sp,sp,64
 50e:	8082                	ret
    x = -xx;
 510:	40b005bb          	negw	a1,a1
    neg = 1;
 514:	4885                	li	a7,1
    x = -xx;
 516:	bf8d                	j	488 <printint+0x1a>

0000000000000518 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 518:	7119                	addi	sp,sp,-128
 51a:	fc86                	sd	ra,120(sp)
 51c:	f8a2                	sd	s0,112(sp)
 51e:	f4a6                	sd	s1,104(sp)
 520:	f0ca                	sd	s2,96(sp)
 522:	ecce                	sd	s3,88(sp)
 524:	e8d2                	sd	s4,80(sp)
 526:	e4d6                	sd	s5,72(sp)
 528:	e0da                	sd	s6,64(sp)
 52a:	fc5e                	sd	s7,56(sp)
 52c:	f862                	sd	s8,48(sp)
 52e:	f466                	sd	s9,40(sp)
 530:	f06a                	sd	s10,32(sp)
 532:	ec6e                	sd	s11,24(sp)
 534:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 536:	0005c903          	lbu	s2,0(a1)
 53a:	18090f63          	beqz	s2,6d8 <vprintf+0x1c0>
 53e:	8aaa                	mv	s5,a0
 540:	8b32                	mv	s6,a2
 542:	00158493          	addi	s1,a1,1
  state = 0;
 546:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 548:	02500a13          	li	s4,37
      if(c == 'd'){
 54c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 550:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 554:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 558:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 55c:	00000b97          	auipc	s7,0x0
 560:	3b4b8b93          	addi	s7,s7,948 # 910 <digits>
 564:	a839                	j	582 <vprintf+0x6a>
        putc(fd, c);
 566:	85ca                	mv	a1,s2
 568:	8556                	mv	a0,s5
 56a:	00000097          	auipc	ra,0x0
 56e:	ee2080e7          	jalr	-286(ra) # 44c <putc>
 572:	a019                	j	578 <vprintf+0x60>
    } else if(state == '%'){
 574:	01498f63          	beq	s3,s4,592 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 578:	0485                	addi	s1,s1,1
 57a:	fff4c903          	lbu	s2,-1(s1)
 57e:	14090d63          	beqz	s2,6d8 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 582:	0009079b          	sext.w	a5,s2
    if(state == 0){
 586:	fe0997e3          	bnez	s3,574 <vprintf+0x5c>
      if(c == '%'){
 58a:	fd479ee3          	bne	a5,s4,566 <vprintf+0x4e>
        state = '%';
 58e:	89be                	mv	s3,a5
 590:	b7e5                	j	578 <vprintf+0x60>
      if(c == 'd'){
 592:	05878063          	beq	a5,s8,5d2 <vprintf+0xba>
      } else if(c == 'l') {
 596:	05978c63          	beq	a5,s9,5ee <vprintf+0xd6>
      } else if(c == 'x') {
 59a:	07a78863          	beq	a5,s10,60a <vprintf+0xf2>
      } else if(c == 'p') {
 59e:	09b78463          	beq	a5,s11,626 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5a2:	07300713          	li	a4,115
 5a6:	0ce78663          	beq	a5,a4,672 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5aa:	06300713          	li	a4,99
 5ae:	0ee78e63          	beq	a5,a4,6aa <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5b2:	11478863          	beq	a5,s4,6c2 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5b6:	85d2                	mv	a1,s4
 5b8:	8556                	mv	a0,s5
 5ba:	00000097          	auipc	ra,0x0
 5be:	e92080e7          	jalr	-366(ra) # 44c <putc>
        putc(fd, c);
 5c2:	85ca                	mv	a1,s2
 5c4:	8556                	mv	a0,s5
 5c6:	00000097          	auipc	ra,0x0
 5ca:	e86080e7          	jalr	-378(ra) # 44c <putc>
      }
      state = 0;
 5ce:	4981                	li	s3,0
 5d0:	b765                	j	578 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 5d2:	008b0913          	addi	s2,s6,8
 5d6:	4685                	li	a3,1
 5d8:	4629                	li	a2,10
 5da:	000b2583          	lw	a1,0(s6)
 5de:	8556                	mv	a0,s5
 5e0:	00000097          	auipc	ra,0x0
 5e4:	e8e080e7          	jalr	-370(ra) # 46e <printint>
 5e8:	8b4a                	mv	s6,s2
      state = 0;
 5ea:	4981                	li	s3,0
 5ec:	b771                	j	578 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ee:	008b0913          	addi	s2,s6,8
 5f2:	4681                	li	a3,0
 5f4:	4629                	li	a2,10
 5f6:	000b2583          	lw	a1,0(s6)
 5fa:	8556                	mv	a0,s5
 5fc:	00000097          	auipc	ra,0x0
 600:	e72080e7          	jalr	-398(ra) # 46e <printint>
 604:	8b4a                	mv	s6,s2
      state = 0;
 606:	4981                	li	s3,0
 608:	bf85                	j	578 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 60a:	008b0913          	addi	s2,s6,8
 60e:	4681                	li	a3,0
 610:	4641                	li	a2,16
 612:	000b2583          	lw	a1,0(s6)
 616:	8556                	mv	a0,s5
 618:	00000097          	auipc	ra,0x0
 61c:	e56080e7          	jalr	-426(ra) # 46e <printint>
 620:	8b4a                	mv	s6,s2
      state = 0;
 622:	4981                	li	s3,0
 624:	bf91                	j	578 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 626:	008b0793          	addi	a5,s6,8
 62a:	f8f43423          	sd	a5,-120(s0)
 62e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 632:	03000593          	li	a1,48
 636:	8556                	mv	a0,s5
 638:	00000097          	auipc	ra,0x0
 63c:	e14080e7          	jalr	-492(ra) # 44c <putc>
  putc(fd, 'x');
 640:	85ea                	mv	a1,s10
 642:	8556                	mv	a0,s5
 644:	00000097          	auipc	ra,0x0
 648:	e08080e7          	jalr	-504(ra) # 44c <putc>
 64c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 64e:	03c9d793          	srli	a5,s3,0x3c
 652:	97de                	add	a5,a5,s7
 654:	0007c583          	lbu	a1,0(a5)
 658:	8556                	mv	a0,s5
 65a:	00000097          	auipc	ra,0x0
 65e:	df2080e7          	jalr	-526(ra) # 44c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 662:	0992                	slli	s3,s3,0x4
 664:	397d                	addiw	s2,s2,-1
 666:	fe0914e3          	bnez	s2,64e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 66a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 66e:	4981                	li	s3,0
 670:	b721                	j	578 <vprintf+0x60>
        s = va_arg(ap, char*);
 672:	008b0993          	addi	s3,s6,8
 676:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 67a:	02090163          	beqz	s2,69c <vprintf+0x184>
        while(*s != 0){
 67e:	00094583          	lbu	a1,0(s2)
 682:	c9a1                	beqz	a1,6d2 <vprintf+0x1ba>
          putc(fd, *s);
 684:	8556                	mv	a0,s5
 686:	00000097          	auipc	ra,0x0
 68a:	dc6080e7          	jalr	-570(ra) # 44c <putc>
          s++;
 68e:	0905                	addi	s2,s2,1
        while(*s != 0){
 690:	00094583          	lbu	a1,0(s2)
 694:	f9e5                	bnez	a1,684 <vprintf+0x16c>
        s = va_arg(ap, char*);
 696:	8b4e                	mv	s6,s3
      state = 0;
 698:	4981                	li	s3,0
 69a:	bdf9                	j	578 <vprintf+0x60>
          s = "(null)";
 69c:	00000917          	auipc	s2,0x0
 6a0:	26c90913          	addi	s2,s2,620 # 908 <malloc+0x126>
        while(*s != 0){
 6a4:	02800593          	li	a1,40
 6a8:	bff1                	j	684 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 6aa:	008b0913          	addi	s2,s6,8
 6ae:	000b4583          	lbu	a1,0(s6)
 6b2:	8556                	mv	a0,s5
 6b4:	00000097          	auipc	ra,0x0
 6b8:	d98080e7          	jalr	-616(ra) # 44c <putc>
 6bc:	8b4a                	mv	s6,s2
      state = 0;
 6be:	4981                	li	s3,0
 6c0:	bd65                	j	578 <vprintf+0x60>
        putc(fd, c);
 6c2:	85d2                	mv	a1,s4
 6c4:	8556                	mv	a0,s5
 6c6:	00000097          	auipc	ra,0x0
 6ca:	d86080e7          	jalr	-634(ra) # 44c <putc>
      state = 0;
 6ce:	4981                	li	s3,0
 6d0:	b565                	j	578 <vprintf+0x60>
        s = va_arg(ap, char*);
 6d2:	8b4e                	mv	s6,s3
      state = 0;
 6d4:	4981                	li	s3,0
 6d6:	b54d                	j	578 <vprintf+0x60>
    }
  }
}
 6d8:	70e6                	ld	ra,120(sp)
 6da:	7446                	ld	s0,112(sp)
 6dc:	74a6                	ld	s1,104(sp)
 6de:	7906                	ld	s2,96(sp)
 6e0:	69e6                	ld	s3,88(sp)
 6e2:	6a46                	ld	s4,80(sp)
 6e4:	6aa6                	ld	s5,72(sp)
 6e6:	6b06                	ld	s6,64(sp)
 6e8:	7be2                	ld	s7,56(sp)
 6ea:	7c42                	ld	s8,48(sp)
 6ec:	7ca2                	ld	s9,40(sp)
 6ee:	7d02                	ld	s10,32(sp)
 6f0:	6de2                	ld	s11,24(sp)
 6f2:	6109                	addi	sp,sp,128
 6f4:	8082                	ret

00000000000006f6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6f6:	715d                	addi	sp,sp,-80
 6f8:	ec06                	sd	ra,24(sp)
 6fa:	e822                	sd	s0,16(sp)
 6fc:	1000                	addi	s0,sp,32
 6fe:	e010                	sd	a2,0(s0)
 700:	e414                	sd	a3,8(s0)
 702:	e818                	sd	a4,16(s0)
 704:	ec1c                	sd	a5,24(s0)
 706:	03043023          	sd	a6,32(s0)
 70a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 70e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 712:	8622                	mv	a2,s0
 714:	00000097          	auipc	ra,0x0
 718:	e04080e7          	jalr	-508(ra) # 518 <vprintf>
}
 71c:	60e2                	ld	ra,24(sp)
 71e:	6442                	ld	s0,16(sp)
 720:	6161                	addi	sp,sp,80
 722:	8082                	ret

0000000000000724 <printf>:

void
printf(const char *fmt, ...)
{
 724:	711d                	addi	sp,sp,-96
 726:	ec06                	sd	ra,24(sp)
 728:	e822                	sd	s0,16(sp)
 72a:	1000                	addi	s0,sp,32
 72c:	e40c                	sd	a1,8(s0)
 72e:	e810                	sd	a2,16(s0)
 730:	ec14                	sd	a3,24(s0)
 732:	f018                	sd	a4,32(s0)
 734:	f41c                	sd	a5,40(s0)
 736:	03043823          	sd	a6,48(s0)
 73a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 73e:	00840613          	addi	a2,s0,8
 742:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 746:	85aa                	mv	a1,a0
 748:	4505                	li	a0,1
 74a:	00000097          	auipc	ra,0x0
 74e:	dce080e7          	jalr	-562(ra) # 518 <vprintf>
}
 752:	60e2                	ld	ra,24(sp)
 754:	6442                	ld	s0,16(sp)
 756:	6125                	addi	sp,sp,96
 758:	8082                	ret

000000000000075a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 75a:	1141                	addi	sp,sp,-16
 75c:	e422                	sd	s0,8(sp)
 75e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 760:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 764:	00001797          	auipc	a5,0x1
 768:	89c7b783          	ld	a5,-1892(a5) # 1000 <freep>
 76c:	a805                	j	79c <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 76e:	4618                	lw	a4,8(a2)
 770:	9db9                	addw	a1,a1,a4
 772:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 776:	6398                	ld	a4,0(a5)
 778:	6318                	ld	a4,0(a4)
 77a:	fee53823          	sd	a4,-16(a0)
 77e:	a091                	j	7c2 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 780:	ff852703          	lw	a4,-8(a0)
 784:	9e39                	addw	a2,a2,a4
 786:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 788:	ff053703          	ld	a4,-16(a0)
 78c:	e398                	sd	a4,0(a5)
 78e:	a099                	j	7d4 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 790:	6398                	ld	a4,0(a5)
 792:	00e7e463          	bltu	a5,a4,79a <free+0x40>
 796:	00e6ea63          	bltu	a3,a4,7aa <free+0x50>
{
 79a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 79c:	fed7fae3          	bgeu	a5,a3,790 <free+0x36>
 7a0:	6398                	ld	a4,0(a5)
 7a2:	00e6e463          	bltu	a3,a4,7aa <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7a6:	fee7eae3          	bltu	a5,a4,79a <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7aa:	ff852583          	lw	a1,-8(a0)
 7ae:	6390                	ld	a2,0(a5)
 7b0:	02059713          	slli	a4,a1,0x20
 7b4:	9301                	srli	a4,a4,0x20
 7b6:	0712                	slli	a4,a4,0x4
 7b8:	9736                	add	a4,a4,a3
 7ba:	fae60ae3          	beq	a2,a4,76e <free+0x14>
    bp->s.ptr = p->s.ptr;
 7be:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7c2:	4790                	lw	a2,8(a5)
 7c4:	02061713          	slli	a4,a2,0x20
 7c8:	9301                	srli	a4,a4,0x20
 7ca:	0712                	slli	a4,a4,0x4
 7cc:	973e                	add	a4,a4,a5
 7ce:	fae689e3          	beq	a3,a4,780 <free+0x26>
  } else
    p->s.ptr = bp;
 7d2:	e394                	sd	a3,0(a5)
  freep = p;
 7d4:	00001717          	auipc	a4,0x1
 7d8:	82f73623          	sd	a5,-2004(a4) # 1000 <freep>
}
 7dc:	6422                	ld	s0,8(sp)
 7de:	0141                	addi	sp,sp,16
 7e0:	8082                	ret

00000000000007e2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7e2:	7139                	addi	sp,sp,-64
 7e4:	fc06                	sd	ra,56(sp)
 7e6:	f822                	sd	s0,48(sp)
 7e8:	f426                	sd	s1,40(sp)
 7ea:	f04a                	sd	s2,32(sp)
 7ec:	ec4e                	sd	s3,24(sp)
 7ee:	e852                	sd	s4,16(sp)
 7f0:	e456                	sd	s5,8(sp)
 7f2:	e05a                	sd	s6,0(sp)
 7f4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7f6:	02051493          	slli	s1,a0,0x20
 7fa:	9081                	srli	s1,s1,0x20
 7fc:	04bd                	addi	s1,s1,15
 7fe:	8091                	srli	s1,s1,0x4
 800:	0014899b          	addiw	s3,s1,1
 804:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 806:	00000517          	auipc	a0,0x0
 80a:	7fa53503          	ld	a0,2042(a0) # 1000 <freep>
 80e:	c515                	beqz	a0,83a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 810:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 812:	4798                	lw	a4,8(a5)
 814:	02977f63          	bgeu	a4,s1,852 <malloc+0x70>
 818:	8a4e                	mv	s4,s3
 81a:	0009871b          	sext.w	a4,s3
 81e:	6685                	lui	a3,0x1
 820:	00d77363          	bgeu	a4,a3,826 <malloc+0x44>
 824:	6a05                	lui	s4,0x1
 826:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 82a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 82e:	00000917          	auipc	s2,0x0
 832:	7d290913          	addi	s2,s2,2002 # 1000 <freep>
  if(p == (char*)-1)
 836:	5afd                	li	s5,-1
 838:	a88d                	j	8aa <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 83a:	00000797          	auipc	a5,0x0
 83e:	7d678793          	addi	a5,a5,2006 # 1010 <base>
 842:	00000717          	auipc	a4,0x0
 846:	7af73f23          	sd	a5,1982(a4) # 1000 <freep>
 84a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 84c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 850:	b7e1                	j	818 <malloc+0x36>
      if(p->s.size == nunits)
 852:	02e48b63          	beq	s1,a4,888 <malloc+0xa6>
        p->s.size -= nunits;
 856:	4137073b          	subw	a4,a4,s3
 85a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 85c:	1702                	slli	a4,a4,0x20
 85e:	9301                	srli	a4,a4,0x20
 860:	0712                	slli	a4,a4,0x4
 862:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 864:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 868:	00000717          	auipc	a4,0x0
 86c:	78a73c23          	sd	a0,1944(a4) # 1000 <freep>
      return (void*)(p + 1);
 870:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 874:	70e2                	ld	ra,56(sp)
 876:	7442                	ld	s0,48(sp)
 878:	74a2                	ld	s1,40(sp)
 87a:	7902                	ld	s2,32(sp)
 87c:	69e2                	ld	s3,24(sp)
 87e:	6a42                	ld	s4,16(sp)
 880:	6aa2                	ld	s5,8(sp)
 882:	6b02                	ld	s6,0(sp)
 884:	6121                	addi	sp,sp,64
 886:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 888:	6398                	ld	a4,0(a5)
 88a:	e118                	sd	a4,0(a0)
 88c:	bff1                	j	868 <malloc+0x86>
  hp->s.size = nu;
 88e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 892:	0541                	addi	a0,a0,16
 894:	00000097          	auipc	ra,0x0
 898:	ec6080e7          	jalr	-314(ra) # 75a <free>
  return freep;
 89c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8a0:	d971                	beqz	a0,874 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8a2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8a4:	4798                	lw	a4,8(a5)
 8a6:	fa9776e3          	bgeu	a4,s1,852 <malloc+0x70>
    if(p == freep)
 8aa:	00093703          	ld	a4,0(s2)
 8ae:	853e                	mv	a0,a5
 8b0:	fef719e3          	bne	a4,a5,8a2 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 8b4:	8552                	mv	a0,s4
 8b6:	00000097          	auipc	ra,0x0
 8ba:	b4e080e7          	jalr	-1202(ra) # 404 <sbrk>
  if(p == (char*)-1)
 8be:	fd5518e3          	bne	a0,s5,88e <malloc+0xac>
        return 0;
 8c2:	4501                	li	a0,0
 8c4:	bf45                	j	874 <malloc+0x92>

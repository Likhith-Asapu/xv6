
user/_schedulertest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:


#define NFORK 5
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
  12:	4995                	li	s3,5
    if(n == 4)
  14:	03248463          	beq	s1,s2,3c <main+0x3c>
        settickets(400);
      else
        settickets(1);
  18:	4505                	li	a0,1
  1a:	00000097          	auipc	ra,0x0
  1e:	400080e7          	jalr	1024(ra) # 41a <settickets>
      pid = fork();
  22:	00000097          	auipc	ra,0x0
  26:	330080e7          	jalr	816(ra) # 352 <fork>
      if (pid < 0)
  2a:	04054463          	bltz	a0,72 <main+0x72>
          break;
      if (pid == 0) {
  2e:	cd11                	beqz	a0,4a <main+0x4a>
  for(n=0; n < NFORK;n++) {
  30:	2485                	addiw	s1,s1,1
  32:	ff3491e3          	bne	s1,s3,14 <main+0x14>
  36:	4901                	li	s2,0
  38:	4981                	li	s3,0
  3a:	a0a5                	j	a2 <main+0xa2>
        settickets(400);
  3c:	19000513          	li	a0,400
  40:	00000097          	auipc	ra,0x0
  44:	3da080e7          	jalr	986(ra) # 41a <settickets>
  48:	bfe9                	j	22 <main+0x22>
  4a:	3b9ad7b7          	lui	a5,0x3b9ad
  4e:	a0078793          	addi	a5,a5,-1536 # 3b9aca00 <base+0x3b9ab9f0>
#ifndef MLFQ
          if (n < IO) {
            sleep(200); // IO bound processes
          } else {
#endif
            for (uint64 i = 0; i < 1000000000; i++) {} // CPU bound process 
  52:	17fd                	addi	a5,a5,-1
  54:	fffd                	bnez	a5,52 <main+0x52>
#ifndef MLFQ
          }
#endif
          printf("Process %d finished\n", n);
  56:	85a6                	mv	a1,s1
  58:	00001517          	auipc	a0,0x1
  5c:	85850513          	addi	a0,a0,-1960 # 8b0 <malloc+0xf0>
  60:	00000097          	auipc	ra,0x0
  64:	6a2080e7          	jalr	1698(ra) # 702 <printf>
          exit(0);
  68:	4501                	li	a0,0
  6a:	00000097          	auipc	ra,0x0
  6e:	2f0080e7          	jalr	752(ra) # 35a <exit>
#ifdef PBS
        setpriority(80, pid); // Will only matter for PBS, set lower priority for IO bound processes 
#endif
      }
  }
  for(;n > 0; n--) {
  72:	fc9042e3          	bgtz	s1,36 <main+0x36>
  76:	4901                	li	s2,0
  78:	4981                	li	s3,0
      if(waitx(0,&wtime,&rtime) >= 0) {
          trtime += rtime;
          twtime += wtime;
      } 
  }
  printf("Average rtime %d,  wtime %d\n", trtime / NFORK, twtime / NFORK);
  7a:	4595                	li	a1,5
  7c:	02b9c63b          	divw	a2,s3,a1
  80:	02b945bb          	divw	a1,s2,a1
  84:	00001517          	auipc	a0,0x1
  88:	84450513          	addi	a0,a0,-1980 # 8c8 <malloc+0x108>
  8c:	00000097          	auipc	ra,0x0
  90:	676080e7          	jalr	1654(ra) # 702 <printf>
  exit(0);
  94:	4501                	li	a0,0
  96:	00000097          	auipc	ra,0x0
  9a:	2c4080e7          	jalr	708(ra) # 35a <exit>
  for(;n > 0; n--) {
  9e:	34fd                	addiw	s1,s1,-1
  a0:	dce9                	beqz	s1,7a <main+0x7a>
      if(waitx(0,&wtime,&rtime) >= 0) {
  a2:	fc840613          	addi	a2,s0,-56
  a6:	fcc40593          	addi	a1,s0,-52
  aa:	4501                	li	a0,0
  ac:	00000097          	auipc	ra,0x0
  b0:	356080e7          	jalr	854(ra) # 402 <waitx>
  b4:	fe0545e3          	bltz	a0,9e <main+0x9e>
          trtime += rtime;
  b8:	fc842783          	lw	a5,-56(s0)
  bc:	0127893b          	addw	s2,a5,s2
          twtime += wtime;
  c0:	fcc42783          	lw	a5,-52(s0)
  c4:	013789bb          	addw	s3,a5,s3
  c8:	bfd9                	j	9e <main+0x9e>

00000000000000ca <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  ca:	1141                	addi	sp,sp,-16
  cc:	e406                	sd	ra,8(sp)
  ce:	e022                	sd	s0,0(sp)
  d0:	0800                	addi	s0,sp,16
  extern int main();
  main();
  d2:	00000097          	auipc	ra,0x0
  d6:	f2e080e7          	jalr	-210(ra) # 0 <main>
  exit(0);
  da:	4501                	li	a0,0
  dc:	00000097          	auipc	ra,0x0
  e0:	27e080e7          	jalr	638(ra) # 35a <exit>

00000000000000e4 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  e4:	1141                	addi	sp,sp,-16
  e6:	e422                	sd	s0,8(sp)
  e8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  ea:	87aa                	mv	a5,a0
  ec:	0585                	addi	a1,a1,1
  ee:	0785                	addi	a5,a5,1
  f0:	fff5c703          	lbu	a4,-1(a1)
  f4:	fee78fa3          	sb	a4,-1(a5)
  f8:	fb75                	bnez	a4,ec <strcpy+0x8>
    ;
  return os;
}
  fa:	6422                	ld	s0,8(sp)
  fc:	0141                	addi	sp,sp,16
  fe:	8082                	ret

0000000000000100 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 100:	1141                	addi	sp,sp,-16
 102:	e422                	sd	s0,8(sp)
 104:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 106:	00054783          	lbu	a5,0(a0)
 10a:	cb91                	beqz	a5,11e <strcmp+0x1e>
 10c:	0005c703          	lbu	a4,0(a1)
 110:	00f71763          	bne	a4,a5,11e <strcmp+0x1e>
    p++, q++;
 114:	0505                	addi	a0,a0,1
 116:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 118:	00054783          	lbu	a5,0(a0)
 11c:	fbe5                	bnez	a5,10c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 11e:	0005c503          	lbu	a0,0(a1)
}
 122:	40a7853b          	subw	a0,a5,a0
 126:	6422                	ld	s0,8(sp)
 128:	0141                	addi	sp,sp,16
 12a:	8082                	ret

000000000000012c <strlen>:

uint
strlen(const char *s)
{
 12c:	1141                	addi	sp,sp,-16
 12e:	e422                	sd	s0,8(sp)
 130:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 132:	00054783          	lbu	a5,0(a0)
 136:	cf91                	beqz	a5,152 <strlen+0x26>
 138:	0505                	addi	a0,a0,1
 13a:	87aa                	mv	a5,a0
 13c:	4685                	li	a3,1
 13e:	9e89                	subw	a3,a3,a0
 140:	00f6853b          	addw	a0,a3,a5
 144:	0785                	addi	a5,a5,1
 146:	fff7c703          	lbu	a4,-1(a5)
 14a:	fb7d                	bnez	a4,140 <strlen+0x14>
    ;
  return n;
}
 14c:	6422                	ld	s0,8(sp)
 14e:	0141                	addi	sp,sp,16
 150:	8082                	ret
  for(n = 0; s[n]; n++)
 152:	4501                	li	a0,0
 154:	bfe5                	j	14c <strlen+0x20>

0000000000000156 <memset>:

void*
memset(void *dst, int c, uint n)
{
 156:	1141                	addi	sp,sp,-16
 158:	e422                	sd	s0,8(sp)
 15a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 15c:	ce09                	beqz	a2,176 <memset+0x20>
 15e:	87aa                	mv	a5,a0
 160:	fff6071b          	addiw	a4,a2,-1
 164:	1702                	slli	a4,a4,0x20
 166:	9301                	srli	a4,a4,0x20
 168:	0705                	addi	a4,a4,1
 16a:	972a                	add	a4,a4,a0
    cdst[i] = c;
 16c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 170:	0785                	addi	a5,a5,1
 172:	fee79de3          	bne	a5,a4,16c <memset+0x16>
  }
  return dst;
}
 176:	6422                	ld	s0,8(sp)
 178:	0141                	addi	sp,sp,16
 17a:	8082                	ret

000000000000017c <strchr>:

char*
strchr(const char *s, char c)
{
 17c:	1141                	addi	sp,sp,-16
 17e:	e422                	sd	s0,8(sp)
 180:	0800                	addi	s0,sp,16
  for(; *s; s++)
 182:	00054783          	lbu	a5,0(a0)
 186:	cb99                	beqz	a5,19c <strchr+0x20>
    if(*s == c)
 188:	00f58763          	beq	a1,a5,196 <strchr+0x1a>
  for(; *s; s++)
 18c:	0505                	addi	a0,a0,1
 18e:	00054783          	lbu	a5,0(a0)
 192:	fbfd                	bnez	a5,188 <strchr+0xc>
      return (char*)s;
  return 0;
 194:	4501                	li	a0,0
}
 196:	6422                	ld	s0,8(sp)
 198:	0141                	addi	sp,sp,16
 19a:	8082                	ret
  return 0;
 19c:	4501                	li	a0,0
 19e:	bfe5                	j	196 <strchr+0x1a>

00000000000001a0 <gets>:

char*
gets(char *buf, int max)
{
 1a0:	711d                	addi	sp,sp,-96
 1a2:	ec86                	sd	ra,88(sp)
 1a4:	e8a2                	sd	s0,80(sp)
 1a6:	e4a6                	sd	s1,72(sp)
 1a8:	e0ca                	sd	s2,64(sp)
 1aa:	fc4e                	sd	s3,56(sp)
 1ac:	f852                	sd	s4,48(sp)
 1ae:	f456                	sd	s5,40(sp)
 1b0:	f05a                	sd	s6,32(sp)
 1b2:	ec5e                	sd	s7,24(sp)
 1b4:	1080                	addi	s0,sp,96
 1b6:	8baa                	mv	s7,a0
 1b8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ba:	892a                	mv	s2,a0
 1bc:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1be:	4aa9                	li	s5,10
 1c0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1c2:	89a6                	mv	s3,s1
 1c4:	2485                	addiw	s1,s1,1
 1c6:	0344d863          	bge	s1,s4,1f6 <gets+0x56>
    cc = read(0, &c, 1);
 1ca:	4605                	li	a2,1
 1cc:	faf40593          	addi	a1,s0,-81
 1d0:	4501                	li	a0,0
 1d2:	00000097          	auipc	ra,0x0
 1d6:	1a0080e7          	jalr	416(ra) # 372 <read>
    if(cc < 1)
 1da:	00a05e63          	blez	a0,1f6 <gets+0x56>
    buf[i++] = c;
 1de:	faf44783          	lbu	a5,-81(s0)
 1e2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1e6:	01578763          	beq	a5,s5,1f4 <gets+0x54>
 1ea:	0905                	addi	s2,s2,1
 1ec:	fd679be3          	bne	a5,s6,1c2 <gets+0x22>
  for(i=0; i+1 < max; ){
 1f0:	89a6                	mv	s3,s1
 1f2:	a011                	j	1f6 <gets+0x56>
 1f4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1f6:	99de                	add	s3,s3,s7
 1f8:	00098023          	sb	zero,0(s3)
  return buf;
}
 1fc:	855e                	mv	a0,s7
 1fe:	60e6                	ld	ra,88(sp)
 200:	6446                	ld	s0,80(sp)
 202:	64a6                	ld	s1,72(sp)
 204:	6906                	ld	s2,64(sp)
 206:	79e2                	ld	s3,56(sp)
 208:	7a42                	ld	s4,48(sp)
 20a:	7aa2                	ld	s5,40(sp)
 20c:	7b02                	ld	s6,32(sp)
 20e:	6be2                	ld	s7,24(sp)
 210:	6125                	addi	sp,sp,96
 212:	8082                	ret

0000000000000214 <stat>:

int
stat(const char *n, struct stat *st)
{
 214:	1101                	addi	sp,sp,-32
 216:	ec06                	sd	ra,24(sp)
 218:	e822                	sd	s0,16(sp)
 21a:	e426                	sd	s1,8(sp)
 21c:	e04a                	sd	s2,0(sp)
 21e:	1000                	addi	s0,sp,32
 220:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 222:	4581                	li	a1,0
 224:	00000097          	auipc	ra,0x0
 228:	176080e7          	jalr	374(ra) # 39a <open>
  if(fd < 0)
 22c:	02054563          	bltz	a0,256 <stat+0x42>
 230:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 232:	85ca                	mv	a1,s2
 234:	00000097          	auipc	ra,0x0
 238:	17e080e7          	jalr	382(ra) # 3b2 <fstat>
 23c:	892a                	mv	s2,a0
  close(fd);
 23e:	8526                	mv	a0,s1
 240:	00000097          	auipc	ra,0x0
 244:	142080e7          	jalr	322(ra) # 382 <close>
  return r;
}
 248:	854a                	mv	a0,s2
 24a:	60e2                	ld	ra,24(sp)
 24c:	6442                	ld	s0,16(sp)
 24e:	64a2                	ld	s1,8(sp)
 250:	6902                	ld	s2,0(sp)
 252:	6105                	addi	sp,sp,32
 254:	8082                	ret
    return -1;
 256:	597d                	li	s2,-1
 258:	bfc5                	j	248 <stat+0x34>

000000000000025a <atoi>:

int
atoi(const char *s)
{
 25a:	1141                	addi	sp,sp,-16
 25c:	e422                	sd	s0,8(sp)
 25e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 260:	00054603          	lbu	a2,0(a0)
 264:	fd06079b          	addiw	a5,a2,-48
 268:	0ff7f793          	andi	a5,a5,255
 26c:	4725                	li	a4,9
 26e:	02f76963          	bltu	a4,a5,2a0 <atoi+0x46>
 272:	86aa                	mv	a3,a0
  n = 0;
 274:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 276:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 278:	0685                	addi	a3,a3,1
 27a:	0025179b          	slliw	a5,a0,0x2
 27e:	9fa9                	addw	a5,a5,a0
 280:	0017979b          	slliw	a5,a5,0x1
 284:	9fb1                	addw	a5,a5,a2
 286:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 28a:	0006c603          	lbu	a2,0(a3)
 28e:	fd06071b          	addiw	a4,a2,-48
 292:	0ff77713          	andi	a4,a4,255
 296:	fee5f1e3          	bgeu	a1,a4,278 <atoi+0x1e>
  return n;
}
 29a:	6422                	ld	s0,8(sp)
 29c:	0141                	addi	sp,sp,16
 29e:	8082                	ret
  n = 0;
 2a0:	4501                	li	a0,0
 2a2:	bfe5                	j	29a <atoi+0x40>

00000000000002a4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2a4:	1141                	addi	sp,sp,-16
 2a6:	e422                	sd	s0,8(sp)
 2a8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2aa:	02b57663          	bgeu	a0,a1,2d6 <memmove+0x32>
    while(n-- > 0)
 2ae:	02c05163          	blez	a2,2d0 <memmove+0x2c>
 2b2:	fff6079b          	addiw	a5,a2,-1
 2b6:	1782                	slli	a5,a5,0x20
 2b8:	9381                	srli	a5,a5,0x20
 2ba:	0785                	addi	a5,a5,1
 2bc:	97aa                	add	a5,a5,a0
  dst = vdst;
 2be:	872a                	mv	a4,a0
      *dst++ = *src++;
 2c0:	0585                	addi	a1,a1,1
 2c2:	0705                	addi	a4,a4,1
 2c4:	fff5c683          	lbu	a3,-1(a1)
 2c8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2cc:	fee79ae3          	bne	a5,a4,2c0 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2d0:	6422                	ld	s0,8(sp)
 2d2:	0141                	addi	sp,sp,16
 2d4:	8082                	ret
    dst += n;
 2d6:	00c50733          	add	a4,a0,a2
    src += n;
 2da:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2dc:	fec05ae3          	blez	a2,2d0 <memmove+0x2c>
 2e0:	fff6079b          	addiw	a5,a2,-1
 2e4:	1782                	slli	a5,a5,0x20
 2e6:	9381                	srli	a5,a5,0x20
 2e8:	fff7c793          	not	a5,a5
 2ec:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2ee:	15fd                	addi	a1,a1,-1
 2f0:	177d                	addi	a4,a4,-1
 2f2:	0005c683          	lbu	a3,0(a1)
 2f6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2fa:	fee79ae3          	bne	a5,a4,2ee <memmove+0x4a>
 2fe:	bfc9                	j	2d0 <memmove+0x2c>

0000000000000300 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 300:	1141                	addi	sp,sp,-16
 302:	e422                	sd	s0,8(sp)
 304:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 306:	ca05                	beqz	a2,336 <memcmp+0x36>
 308:	fff6069b          	addiw	a3,a2,-1
 30c:	1682                	slli	a3,a3,0x20
 30e:	9281                	srli	a3,a3,0x20
 310:	0685                	addi	a3,a3,1
 312:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 314:	00054783          	lbu	a5,0(a0)
 318:	0005c703          	lbu	a4,0(a1)
 31c:	00e79863          	bne	a5,a4,32c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 320:	0505                	addi	a0,a0,1
    p2++;
 322:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 324:	fed518e3          	bne	a0,a3,314 <memcmp+0x14>
  }
  return 0;
 328:	4501                	li	a0,0
 32a:	a019                	j	330 <memcmp+0x30>
      return *p1 - *p2;
 32c:	40e7853b          	subw	a0,a5,a4
}
 330:	6422                	ld	s0,8(sp)
 332:	0141                	addi	sp,sp,16
 334:	8082                	ret
  return 0;
 336:	4501                	li	a0,0
 338:	bfe5                	j	330 <memcmp+0x30>

000000000000033a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 33a:	1141                	addi	sp,sp,-16
 33c:	e406                	sd	ra,8(sp)
 33e:	e022                	sd	s0,0(sp)
 340:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 342:	00000097          	auipc	ra,0x0
 346:	f62080e7          	jalr	-158(ra) # 2a4 <memmove>
}
 34a:	60a2                	ld	ra,8(sp)
 34c:	6402                	ld	s0,0(sp)
 34e:	0141                	addi	sp,sp,16
 350:	8082                	ret

0000000000000352 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 352:	4885                	li	a7,1
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <exit>:
.global exit
exit:
 li a7, SYS_exit
 35a:	4889                	li	a7,2
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <wait>:
.global wait
wait:
 li a7, SYS_wait
 362:	488d                	li	a7,3
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 36a:	4891                	li	a7,4
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <read>:
.global read
read:
 li a7, SYS_read
 372:	4895                	li	a7,5
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <write>:
.global write
write:
 li a7, SYS_write
 37a:	48c1                	li	a7,16
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <close>:
.global close
close:
 li a7, SYS_close
 382:	48d5                	li	a7,21
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <kill>:
.global kill
kill:
 li a7, SYS_kill
 38a:	4899                	li	a7,6
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <exec>:
.global exec
exec:
 li a7, SYS_exec
 392:	489d                	li	a7,7
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <open>:
.global open
open:
 li a7, SYS_open
 39a:	48bd                	li	a7,15
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3a2:	48c5                	li	a7,17
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3aa:	48c9                	li	a7,18
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3b2:	48a1                	li	a7,8
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <link>:
.global link
link:
 li a7, SYS_link
 3ba:	48cd                	li	a7,19
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3c2:	48d1                	li	a7,20
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3ca:	48a5                	li	a7,9
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3d2:	48a9                	li	a7,10
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3da:	48ad                	li	a7,11
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3e2:	48b1                	li	a7,12
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3ea:	48b5                	li	a7,13
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3f2:	48b9                	li	a7,14
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <trace>:
.global trace
trace:
 li a7, SYS_trace
 3fa:	48d9                	li	a7,22
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 402:	48dd                	li	a7,23
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 40a:	48e5                	li	a7,25
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 412:	48e1                	li	a7,24
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 41a:	48e9                	li	a7,26
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 422:	48ed                	li	a7,27
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 42a:	1101                	addi	sp,sp,-32
 42c:	ec06                	sd	ra,24(sp)
 42e:	e822                	sd	s0,16(sp)
 430:	1000                	addi	s0,sp,32
 432:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 436:	4605                	li	a2,1
 438:	fef40593          	addi	a1,s0,-17
 43c:	00000097          	auipc	ra,0x0
 440:	f3e080e7          	jalr	-194(ra) # 37a <write>
}
 444:	60e2                	ld	ra,24(sp)
 446:	6442                	ld	s0,16(sp)
 448:	6105                	addi	sp,sp,32
 44a:	8082                	ret

000000000000044c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 44c:	7139                	addi	sp,sp,-64
 44e:	fc06                	sd	ra,56(sp)
 450:	f822                	sd	s0,48(sp)
 452:	f426                	sd	s1,40(sp)
 454:	f04a                	sd	s2,32(sp)
 456:	ec4e                	sd	s3,24(sp)
 458:	0080                	addi	s0,sp,64
 45a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 45c:	c299                	beqz	a3,462 <printint+0x16>
 45e:	0805c863          	bltz	a1,4ee <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 462:	2581                	sext.w	a1,a1
  neg = 0;
 464:	4881                	li	a7,0
 466:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 46a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 46c:	2601                	sext.w	a2,a2
 46e:	00000517          	auipc	a0,0x0
 472:	48250513          	addi	a0,a0,1154 # 8f0 <digits>
 476:	883a                	mv	a6,a4
 478:	2705                	addiw	a4,a4,1
 47a:	02c5f7bb          	remuw	a5,a1,a2
 47e:	1782                	slli	a5,a5,0x20
 480:	9381                	srli	a5,a5,0x20
 482:	97aa                	add	a5,a5,a0
 484:	0007c783          	lbu	a5,0(a5)
 488:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 48c:	0005879b          	sext.w	a5,a1
 490:	02c5d5bb          	divuw	a1,a1,a2
 494:	0685                	addi	a3,a3,1
 496:	fec7f0e3          	bgeu	a5,a2,476 <printint+0x2a>
  if(neg)
 49a:	00088b63          	beqz	a7,4b0 <printint+0x64>
    buf[i++] = '-';
 49e:	fd040793          	addi	a5,s0,-48
 4a2:	973e                	add	a4,a4,a5
 4a4:	02d00793          	li	a5,45
 4a8:	fef70823          	sb	a5,-16(a4)
 4ac:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4b0:	02e05863          	blez	a4,4e0 <printint+0x94>
 4b4:	fc040793          	addi	a5,s0,-64
 4b8:	00e78933          	add	s2,a5,a4
 4bc:	fff78993          	addi	s3,a5,-1
 4c0:	99ba                	add	s3,s3,a4
 4c2:	377d                	addiw	a4,a4,-1
 4c4:	1702                	slli	a4,a4,0x20
 4c6:	9301                	srli	a4,a4,0x20
 4c8:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4cc:	fff94583          	lbu	a1,-1(s2)
 4d0:	8526                	mv	a0,s1
 4d2:	00000097          	auipc	ra,0x0
 4d6:	f58080e7          	jalr	-168(ra) # 42a <putc>
  while(--i >= 0)
 4da:	197d                	addi	s2,s2,-1
 4dc:	ff3918e3          	bne	s2,s3,4cc <printint+0x80>
}
 4e0:	70e2                	ld	ra,56(sp)
 4e2:	7442                	ld	s0,48(sp)
 4e4:	74a2                	ld	s1,40(sp)
 4e6:	7902                	ld	s2,32(sp)
 4e8:	69e2                	ld	s3,24(sp)
 4ea:	6121                	addi	sp,sp,64
 4ec:	8082                	ret
    x = -xx;
 4ee:	40b005bb          	negw	a1,a1
    neg = 1;
 4f2:	4885                	li	a7,1
    x = -xx;
 4f4:	bf8d                	j	466 <printint+0x1a>

00000000000004f6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4f6:	7119                	addi	sp,sp,-128
 4f8:	fc86                	sd	ra,120(sp)
 4fa:	f8a2                	sd	s0,112(sp)
 4fc:	f4a6                	sd	s1,104(sp)
 4fe:	f0ca                	sd	s2,96(sp)
 500:	ecce                	sd	s3,88(sp)
 502:	e8d2                	sd	s4,80(sp)
 504:	e4d6                	sd	s5,72(sp)
 506:	e0da                	sd	s6,64(sp)
 508:	fc5e                	sd	s7,56(sp)
 50a:	f862                	sd	s8,48(sp)
 50c:	f466                	sd	s9,40(sp)
 50e:	f06a                	sd	s10,32(sp)
 510:	ec6e                	sd	s11,24(sp)
 512:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 514:	0005c903          	lbu	s2,0(a1)
 518:	18090f63          	beqz	s2,6b6 <vprintf+0x1c0>
 51c:	8aaa                	mv	s5,a0
 51e:	8b32                	mv	s6,a2
 520:	00158493          	addi	s1,a1,1
  state = 0;
 524:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 526:	02500a13          	li	s4,37
      if(c == 'd'){
 52a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 52e:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 532:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 536:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 53a:	00000b97          	auipc	s7,0x0
 53e:	3b6b8b93          	addi	s7,s7,950 # 8f0 <digits>
 542:	a839                	j	560 <vprintf+0x6a>
        putc(fd, c);
 544:	85ca                	mv	a1,s2
 546:	8556                	mv	a0,s5
 548:	00000097          	auipc	ra,0x0
 54c:	ee2080e7          	jalr	-286(ra) # 42a <putc>
 550:	a019                	j	556 <vprintf+0x60>
    } else if(state == '%'){
 552:	01498f63          	beq	s3,s4,570 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 556:	0485                	addi	s1,s1,1
 558:	fff4c903          	lbu	s2,-1(s1)
 55c:	14090d63          	beqz	s2,6b6 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 560:	0009079b          	sext.w	a5,s2
    if(state == 0){
 564:	fe0997e3          	bnez	s3,552 <vprintf+0x5c>
      if(c == '%'){
 568:	fd479ee3          	bne	a5,s4,544 <vprintf+0x4e>
        state = '%';
 56c:	89be                	mv	s3,a5
 56e:	b7e5                	j	556 <vprintf+0x60>
      if(c == 'd'){
 570:	05878063          	beq	a5,s8,5b0 <vprintf+0xba>
      } else if(c == 'l') {
 574:	05978c63          	beq	a5,s9,5cc <vprintf+0xd6>
      } else if(c == 'x') {
 578:	07a78863          	beq	a5,s10,5e8 <vprintf+0xf2>
      } else if(c == 'p') {
 57c:	09b78463          	beq	a5,s11,604 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 580:	07300713          	li	a4,115
 584:	0ce78663          	beq	a5,a4,650 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 588:	06300713          	li	a4,99
 58c:	0ee78e63          	beq	a5,a4,688 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 590:	11478863          	beq	a5,s4,6a0 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 594:	85d2                	mv	a1,s4
 596:	8556                	mv	a0,s5
 598:	00000097          	auipc	ra,0x0
 59c:	e92080e7          	jalr	-366(ra) # 42a <putc>
        putc(fd, c);
 5a0:	85ca                	mv	a1,s2
 5a2:	8556                	mv	a0,s5
 5a4:	00000097          	auipc	ra,0x0
 5a8:	e86080e7          	jalr	-378(ra) # 42a <putc>
      }
      state = 0;
 5ac:	4981                	li	s3,0
 5ae:	b765                	j	556 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 5b0:	008b0913          	addi	s2,s6,8
 5b4:	4685                	li	a3,1
 5b6:	4629                	li	a2,10
 5b8:	000b2583          	lw	a1,0(s6)
 5bc:	8556                	mv	a0,s5
 5be:	00000097          	auipc	ra,0x0
 5c2:	e8e080e7          	jalr	-370(ra) # 44c <printint>
 5c6:	8b4a                	mv	s6,s2
      state = 0;
 5c8:	4981                	li	s3,0
 5ca:	b771                	j	556 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5cc:	008b0913          	addi	s2,s6,8
 5d0:	4681                	li	a3,0
 5d2:	4629                	li	a2,10
 5d4:	000b2583          	lw	a1,0(s6)
 5d8:	8556                	mv	a0,s5
 5da:	00000097          	auipc	ra,0x0
 5de:	e72080e7          	jalr	-398(ra) # 44c <printint>
 5e2:	8b4a                	mv	s6,s2
      state = 0;
 5e4:	4981                	li	s3,0
 5e6:	bf85                	j	556 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5e8:	008b0913          	addi	s2,s6,8
 5ec:	4681                	li	a3,0
 5ee:	4641                	li	a2,16
 5f0:	000b2583          	lw	a1,0(s6)
 5f4:	8556                	mv	a0,s5
 5f6:	00000097          	auipc	ra,0x0
 5fa:	e56080e7          	jalr	-426(ra) # 44c <printint>
 5fe:	8b4a                	mv	s6,s2
      state = 0;
 600:	4981                	li	s3,0
 602:	bf91                	j	556 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 604:	008b0793          	addi	a5,s6,8
 608:	f8f43423          	sd	a5,-120(s0)
 60c:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 610:	03000593          	li	a1,48
 614:	8556                	mv	a0,s5
 616:	00000097          	auipc	ra,0x0
 61a:	e14080e7          	jalr	-492(ra) # 42a <putc>
  putc(fd, 'x');
 61e:	85ea                	mv	a1,s10
 620:	8556                	mv	a0,s5
 622:	00000097          	auipc	ra,0x0
 626:	e08080e7          	jalr	-504(ra) # 42a <putc>
 62a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 62c:	03c9d793          	srli	a5,s3,0x3c
 630:	97de                	add	a5,a5,s7
 632:	0007c583          	lbu	a1,0(a5)
 636:	8556                	mv	a0,s5
 638:	00000097          	auipc	ra,0x0
 63c:	df2080e7          	jalr	-526(ra) # 42a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 640:	0992                	slli	s3,s3,0x4
 642:	397d                	addiw	s2,s2,-1
 644:	fe0914e3          	bnez	s2,62c <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 648:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 64c:	4981                	li	s3,0
 64e:	b721                	j	556 <vprintf+0x60>
        s = va_arg(ap, char*);
 650:	008b0993          	addi	s3,s6,8
 654:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 658:	02090163          	beqz	s2,67a <vprintf+0x184>
        while(*s != 0){
 65c:	00094583          	lbu	a1,0(s2)
 660:	c9a1                	beqz	a1,6b0 <vprintf+0x1ba>
          putc(fd, *s);
 662:	8556                	mv	a0,s5
 664:	00000097          	auipc	ra,0x0
 668:	dc6080e7          	jalr	-570(ra) # 42a <putc>
          s++;
 66c:	0905                	addi	s2,s2,1
        while(*s != 0){
 66e:	00094583          	lbu	a1,0(s2)
 672:	f9e5                	bnez	a1,662 <vprintf+0x16c>
        s = va_arg(ap, char*);
 674:	8b4e                	mv	s6,s3
      state = 0;
 676:	4981                	li	s3,0
 678:	bdf9                	j	556 <vprintf+0x60>
          s = "(null)";
 67a:	00000917          	auipc	s2,0x0
 67e:	26e90913          	addi	s2,s2,622 # 8e8 <malloc+0x128>
        while(*s != 0){
 682:	02800593          	li	a1,40
 686:	bff1                	j	662 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 688:	008b0913          	addi	s2,s6,8
 68c:	000b4583          	lbu	a1,0(s6)
 690:	8556                	mv	a0,s5
 692:	00000097          	auipc	ra,0x0
 696:	d98080e7          	jalr	-616(ra) # 42a <putc>
 69a:	8b4a                	mv	s6,s2
      state = 0;
 69c:	4981                	li	s3,0
 69e:	bd65                	j	556 <vprintf+0x60>
        putc(fd, c);
 6a0:	85d2                	mv	a1,s4
 6a2:	8556                	mv	a0,s5
 6a4:	00000097          	auipc	ra,0x0
 6a8:	d86080e7          	jalr	-634(ra) # 42a <putc>
      state = 0;
 6ac:	4981                	li	s3,0
 6ae:	b565                	j	556 <vprintf+0x60>
        s = va_arg(ap, char*);
 6b0:	8b4e                	mv	s6,s3
      state = 0;
 6b2:	4981                	li	s3,0
 6b4:	b54d                	j	556 <vprintf+0x60>
    }
  }
}
 6b6:	70e6                	ld	ra,120(sp)
 6b8:	7446                	ld	s0,112(sp)
 6ba:	74a6                	ld	s1,104(sp)
 6bc:	7906                	ld	s2,96(sp)
 6be:	69e6                	ld	s3,88(sp)
 6c0:	6a46                	ld	s4,80(sp)
 6c2:	6aa6                	ld	s5,72(sp)
 6c4:	6b06                	ld	s6,64(sp)
 6c6:	7be2                	ld	s7,56(sp)
 6c8:	7c42                	ld	s8,48(sp)
 6ca:	7ca2                	ld	s9,40(sp)
 6cc:	7d02                	ld	s10,32(sp)
 6ce:	6de2                	ld	s11,24(sp)
 6d0:	6109                	addi	sp,sp,128
 6d2:	8082                	ret

00000000000006d4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6d4:	715d                	addi	sp,sp,-80
 6d6:	ec06                	sd	ra,24(sp)
 6d8:	e822                	sd	s0,16(sp)
 6da:	1000                	addi	s0,sp,32
 6dc:	e010                	sd	a2,0(s0)
 6de:	e414                	sd	a3,8(s0)
 6e0:	e818                	sd	a4,16(s0)
 6e2:	ec1c                	sd	a5,24(s0)
 6e4:	03043023          	sd	a6,32(s0)
 6e8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6ec:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6f0:	8622                	mv	a2,s0
 6f2:	00000097          	auipc	ra,0x0
 6f6:	e04080e7          	jalr	-508(ra) # 4f6 <vprintf>
}
 6fa:	60e2                	ld	ra,24(sp)
 6fc:	6442                	ld	s0,16(sp)
 6fe:	6161                	addi	sp,sp,80
 700:	8082                	ret

0000000000000702 <printf>:

void
printf(const char *fmt, ...)
{
 702:	711d                	addi	sp,sp,-96
 704:	ec06                	sd	ra,24(sp)
 706:	e822                	sd	s0,16(sp)
 708:	1000                	addi	s0,sp,32
 70a:	e40c                	sd	a1,8(s0)
 70c:	e810                	sd	a2,16(s0)
 70e:	ec14                	sd	a3,24(s0)
 710:	f018                	sd	a4,32(s0)
 712:	f41c                	sd	a5,40(s0)
 714:	03043823          	sd	a6,48(s0)
 718:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 71c:	00840613          	addi	a2,s0,8
 720:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 724:	85aa                	mv	a1,a0
 726:	4505                	li	a0,1
 728:	00000097          	auipc	ra,0x0
 72c:	dce080e7          	jalr	-562(ra) # 4f6 <vprintf>
}
 730:	60e2                	ld	ra,24(sp)
 732:	6442                	ld	s0,16(sp)
 734:	6125                	addi	sp,sp,96
 736:	8082                	ret

0000000000000738 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 738:	1141                	addi	sp,sp,-16
 73a:	e422                	sd	s0,8(sp)
 73c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 73e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 742:	00001797          	auipc	a5,0x1
 746:	8be7b783          	ld	a5,-1858(a5) # 1000 <freep>
 74a:	a805                	j	77a <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 74c:	4618                	lw	a4,8(a2)
 74e:	9db9                	addw	a1,a1,a4
 750:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 754:	6398                	ld	a4,0(a5)
 756:	6318                	ld	a4,0(a4)
 758:	fee53823          	sd	a4,-16(a0)
 75c:	a091                	j	7a0 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 75e:	ff852703          	lw	a4,-8(a0)
 762:	9e39                	addw	a2,a2,a4
 764:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 766:	ff053703          	ld	a4,-16(a0)
 76a:	e398                	sd	a4,0(a5)
 76c:	a099                	j	7b2 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 76e:	6398                	ld	a4,0(a5)
 770:	00e7e463          	bltu	a5,a4,778 <free+0x40>
 774:	00e6ea63          	bltu	a3,a4,788 <free+0x50>
{
 778:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 77a:	fed7fae3          	bgeu	a5,a3,76e <free+0x36>
 77e:	6398                	ld	a4,0(a5)
 780:	00e6e463          	bltu	a3,a4,788 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 784:	fee7eae3          	bltu	a5,a4,778 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 788:	ff852583          	lw	a1,-8(a0)
 78c:	6390                	ld	a2,0(a5)
 78e:	02059713          	slli	a4,a1,0x20
 792:	9301                	srli	a4,a4,0x20
 794:	0712                	slli	a4,a4,0x4
 796:	9736                	add	a4,a4,a3
 798:	fae60ae3          	beq	a2,a4,74c <free+0x14>
    bp->s.ptr = p->s.ptr;
 79c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7a0:	4790                	lw	a2,8(a5)
 7a2:	02061713          	slli	a4,a2,0x20
 7a6:	9301                	srli	a4,a4,0x20
 7a8:	0712                	slli	a4,a4,0x4
 7aa:	973e                	add	a4,a4,a5
 7ac:	fae689e3          	beq	a3,a4,75e <free+0x26>
  } else
    p->s.ptr = bp;
 7b0:	e394                	sd	a3,0(a5)
  freep = p;
 7b2:	00001717          	auipc	a4,0x1
 7b6:	84f73723          	sd	a5,-1970(a4) # 1000 <freep>
}
 7ba:	6422                	ld	s0,8(sp)
 7bc:	0141                	addi	sp,sp,16
 7be:	8082                	ret

00000000000007c0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7c0:	7139                	addi	sp,sp,-64
 7c2:	fc06                	sd	ra,56(sp)
 7c4:	f822                	sd	s0,48(sp)
 7c6:	f426                	sd	s1,40(sp)
 7c8:	f04a                	sd	s2,32(sp)
 7ca:	ec4e                	sd	s3,24(sp)
 7cc:	e852                	sd	s4,16(sp)
 7ce:	e456                	sd	s5,8(sp)
 7d0:	e05a                	sd	s6,0(sp)
 7d2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7d4:	02051493          	slli	s1,a0,0x20
 7d8:	9081                	srli	s1,s1,0x20
 7da:	04bd                	addi	s1,s1,15
 7dc:	8091                	srli	s1,s1,0x4
 7de:	0014899b          	addiw	s3,s1,1
 7e2:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7e4:	00001517          	auipc	a0,0x1
 7e8:	81c53503          	ld	a0,-2020(a0) # 1000 <freep>
 7ec:	c515                	beqz	a0,818 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ee:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7f0:	4798                	lw	a4,8(a5)
 7f2:	02977f63          	bgeu	a4,s1,830 <malloc+0x70>
 7f6:	8a4e                	mv	s4,s3
 7f8:	0009871b          	sext.w	a4,s3
 7fc:	6685                	lui	a3,0x1
 7fe:	00d77363          	bgeu	a4,a3,804 <malloc+0x44>
 802:	6a05                	lui	s4,0x1
 804:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 808:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 80c:	00000917          	auipc	s2,0x0
 810:	7f490913          	addi	s2,s2,2036 # 1000 <freep>
  if(p == (char*)-1)
 814:	5afd                	li	s5,-1
 816:	a88d                	j	888 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 818:	00000797          	auipc	a5,0x0
 81c:	7f878793          	addi	a5,a5,2040 # 1010 <base>
 820:	00000717          	auipc	a4,0x0
 824:	7ef73023          	sd	a5,2016(a4) # 1000 <freep>
 828:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 82a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 82e:	b7e1                	j	7f6 <malloc+0x36>
      if(p->s.size == nunits)
 830:	02e48b63          	beq	s1,a4,866 <malloc+0xa6>
        p->s.size -= nunits;
 834:	4137073b          	subw	a4,a4,s3
 838:	c798                	sw	a4,8(a5)
        p += p->s.size;
 83a:	1702                	slli	a4,a4,0x20
 83c:	9301                	srli	a4,a4,0x20
 83e:	0712                	slli	a4,a4,0x4
 840:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 842:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 846:	00000717          	auipc	a4,0x0
 84a:	7aa73d23          	sd	a0,1978(a4) # 1000 <freep>
      return (void*)(p + 1);
 84e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 852:	70e2                	ld	ra,56(sp)
 854:	7442                	ld	s0,48(sp)
 856:	74a2                	ld	s1,40(sp)
 858:	7902                	ld	s2,32(sp)
 85a:	69e2                	ld	s3,24(sp)
 85c:	6a42                	ld	s4,16(sp)
 85e:	6aa2                	ld	s5,8(sp)
 860:	6b02                	ld	s6,0(sp)
 862:	6121                	addi	sp,sp,64
 864:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 866:	6398                	ld	a4,0(a5)
 868:	e118                	sd	a4,0(a0)
 86a:	bff1                	j	846 <malloc+0x86>
  hp->s.size = nu;
 86c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 870:	0541                	addi	a0,a0,16
 872:	00000097          	auipc	ra,0x0
 876:	ec6080e7          	jalr	-314(ra) # 738 <free>
  return freep;
 87a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 87e:	d971                	beqz	a0,852 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 880:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 882:	4798                	lw	a4,8(a5)
 884:	fa9776e3          	bgeu	a4,s1,830 <malloc+0x70>
    if(p == freep)
 888:	00093703          	ld	a4,0(s2)
 88c:	853e                	mv	a0,a5
 88e:	fef719e3          	bne	a4,a5,880 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 892:	8552                	mv	a0,s4
 894:	00000097          	auipc	ra,0x0
 898:	b4e080e7          	jalr	-1202(ra) # 3e2 <sbrk>
  if(p == (char*)-1)
 89c:	fd5518e3          	bne	a0,s5,86c <malloc+0xac>
        return 0;
 8a0:	4501                	li	a0,0
 8a2:	bf45                	j	852 <malloc+0x92>

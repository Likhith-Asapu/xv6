
user/_ls:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <fmtname>:
#include "user/user.h"
#include "kernel/fs.h"

char*
fmtname(char *path)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	84aa                	mv	s1,a0
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
  10:	00000097          	auipc	ra,0x0
  14:	32a080e7          	jalr	810(ra) # 33a <strlen>
  18:	02051793          	slli	a5,a0,0x20
  1c:	9381                	srli	a5,a5,0x20
  1e:	97a6                	add	a5,a5,s1
  20:	02f00693          	li	a3,47
  24:	0097e963          	bltu	a5,s1,36 <fmtname+0x36>
  28:	0007c703          	lbu	a4,0(a5)
  2c:	00d70563          	beq	a4,a3,36 <fmtname+0x36>
  30:	17fd                	addi	a5,a5,-1
  32:	fe97fbe3          	bgeu	a5,s1,28 <fmtname+0x28>
    ;
  p++;
  36:	00178493          	addi	s1,a5,1

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  3a:	8526                	mv	a0,s1
  3c:	00000097          	auipc	ra,0x0
  40:	2fe080e7          	jalr	766(ra) # 33a <strlen>
  44:	2501                	sext.w	a0,a0
  46:	47b5                	li	a5,13
  48:	00a7fa63          	bgeu	a5,a0,5c <fmtname+0x5c>
    return p;
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  return buf;
}
  4c:	8526                	mv	a0,s1
  4e:	70a2                	ld	ra,40(sp)
  50:	7402                	ld	s0,32(sp)
  52:	64e2                	ld	s1,24(sp)
  54:	6942                	ld	s2,16(sp)
  56:	69a2                	ld	s3,8(sp)
  58:	6145                	addi	sp,sp,48
  5a:	8082                	ret
  memmove(buf, p, strlen(p));
  5c:	8526                	mv	a0,s1
  5e:	00000097          	auipc	ra,0x0
  62:	2dc080e7          	jalr	732(ra) # 33a <strlen>
  66:	00001997          	auipc	s3,0x1
  6a:	faa98993          	addi	s3,s3,-86 # 1010 <buf.0>
  6e:	0005061b          	sext.w	a2,a0
  72:	85a6                	mv	a1,s1
  74:	854e                	mv	a0,s3
  76:	00000097          	auipc	ra,0x0
  7a:	438080e7          	jalr	1080(ra) # 4ae <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  7e:	8526                	mv	a0,s1
  80:	00000097          	auipc	ra,0x0
  84:	2ba080e7          	jalr	698(ra) # 33a <strlen>
  88:	0005091b          	sext.w	s2,a0
  8c:	8526                	mv	a0,s1
  8e:	00000097          	auipc	ra,0x0
  92:	2ac080e7          	jalr	684(ra) # 33a <strlen>
  96:	1902                	slli	s2,s2,0x20
  98:	02095913          	srli	s2,s2,0x20
  9c:	4639                	li	a2,14
  9e:	9e09                	subw	a2,a2,a0
  a0:	02000593          	li	a1,32
  a4:	01298533          	add	a0,s3,s2
  a8:	00000097          	auipc	ra,0x0
  ac:	2bc080e7          	jalr	700(ra) # 364 <memset>
  return buf;
  b0:	84ce                	mv	s1,s3
  b2:	bf69                	j	4c <fmtname+0x4c>

00000000000000b4 <ls>:

void
ls(char *path)
{
  b4:	d9010113          	addi	sp,sp,-624
  b8:	26113423          	sd	ra,616(sp)
  bc:	26813023          	sd	s0,608(sp)
  c0:	24913c23          	sd	s1,600(sp)
  c4:	25213823          	sd	s2,592(sp)
  c8:	25313423          	sd	s3,584(sp)
  cc:	25413023          	sd	s4,576(sp)
  d0:	23513c23          	sd	s5,568(sp)
  d4:	1c80                	addi	s0,sp,624
  d6:	892a                	mv	s2,a0
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
  d8:	4581                	li	a1,0
  da:	00000097          	auipc	ra,0x0
  de:	4c6080e7          	jalr	1222(ra) # 5a0 <open>
  e2:	08054163          	bltz	a0,164 <ls+0xb0>
  e6:	84aa                	mv	s1,a0
    fprintf(2, "ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
  e8:	d9840593          	addi	a1,s0,-616
  ec:	00000097          	auipc	ra,0x0
  f0:	4cc080e7          	jalr	1228(ra) # 5b8 <fstat>
  f4:	08054363          	bltz	a0,17a <ls+0xc6>
    fprintf(2, "ls: cannot stat %s\n", path);
    close(fd);
    return;
  }

  switch(st.type){
  f8:	da041783          	lh	a5,-608(s0)
  fc:	0007869b          	sext.w	a3,a5
 100:	4705                	li	a4,1
 102:	08e68c63          	beq	a3,a4,19a <ls+0xe6>
 106:	37f9                	addiw	a5,a5,-2
 108:	17c2                	slli	a5,a5,0x30
 10a:	93c1                	srli	a5,a5,0x30
 10c:	02f76663          	bltu	a4,a5,138 <ls+0x84>
  case T_DEVICE:
  case T_FILE:
    printf("%s %d %d %l\n", fmtname(path), st.type, st.ino, st.size);
 110:	854a                	mv	a0,s2
 112:	00000097          	auipc	ra,0x0
 116:	eee080e7          	jalr	-274(ra) # 0 <fmtname>
 11a:	85aa                	mv	a1,a0
 11c:	da843703          	ld	a4,-600(s0)
 120:	d9c42683          	lw	a3,-612(s0)
 124:	da041603          	lh	a2,-608(s0)
 128:	00001517          	auipc	a0,0x1
 12c:	9b850513          	addi	a0,a0,-1608 # ae0 <malloc+0x11a>
 130:	00000097          	auipc	ra,0x0
 134:	7d8080e7          	jalr	2008(ra) # 908 <printf>
      }
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
    }
    break;
  }
  close(fd);
 138:	8526                	mv	a0,s1
 13a:	00000097          	auipc	ra,0x0
 13e:	44e080e7          	jalr	1102(ra) # 588 <close>
}
 142:	26813083          	ld	ra,616(sp)
 146:	26013403          	ld	s0,608(sp)
 14a:	25813483          	ld	s1,600(sp)
 14e:	25013903          	ld	s2,592(sp)
 152:	24813983          	ld	s3,584(sp)
 156:	24013a03          	ld	s4,576(sp)
 15a:	23813a83          	ld	s5,568(sp)
 15e:	27010113          	addi	sp,sp,624
 162:	8082                	ret
    fprintf(2, "ls: cannot open %s\n", path);
 164:	864a                	mv	a2,s2
 166:	00001597          	auipc	a1,0x1
 16a:	94a58593          	addi	a1,a1,-1718 # ab0 <malloc+0xea>
 16e:	4509                	li	a0,2
 170:	00000097          	auipc	ra,0x0
 174:	76a080e7          	jalr	1898(ra) # 8da <fprintf>
    return;
 178:	b7e9                	j	142 <ls+0x8e>
    fprintf(2, "ls: cannot stat %s\n", path);
 17a:	864a                	mv	a2,s2
 17c:	00001597          	auipc	a1,0x1
 180:	94c58593          	addi	a1,a1,-1716 # ac8 <malloc+0x102>
 184:	4509                	li	a0,2
 186:	00000097          	auipc	ra,0x0
 18a:	754080e7          	jalr	1876(ra) # 8da <fprintf>
    close(fd);
 18e:	8526                	mv	a0,s1
 190:	00000097          	auipc	ra,0x0
 194:	3f8080e7          	jalr	1016(ra) # 588 <close>
    return;
 198:	b76d                	j	142 <ls+0x8e>
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 19a:	854a                	mv	a0,s2
 19c:	00000097          	auipc	ra,0x0
 1a0:	19e080e7          	jalr	414(ra) # 33a <strlen>
 1a4:	2541                	addiw	a0,a0,16
 1a6:	20000793          	li	a5,512
 1aa:	00a7fb63          	bgeu	a5,a0,1c0 <ls+0x10c>
      printf("ls: path too long\n");
 1ae:	00001517          	auipc	a0,0x1
 1b2:	94250513          	addi	a0,a0,-1726 # af0 <malloc+0x12a>
 1b6:	00000097          	auipc	ra,0x0
 1ba:	752080e7          	jalr	1874(ra) # 908 <printf>
      break;
 1be:	bfad                	j	138 <ls+0x84>
    strcpy(buf, path);
 1c0:	85ca                	mv	a1,s2
 1c2:	dc040513          	addi	a0,s0,-576
 1c6:	00000097          	auipc	ra,0x0
 1ca:	12c080e7          	jalr	300(ra) # 2f2 <strcpy>
    p = buf+strlen(buf);
 1ce:	dc040513          	addi	a0,s0,-576
 1d2:	00000097          	auipc	ra,0x0
 1d6:	168080e7          	jalr	360(ra) # 33a <strlen>
 1da:	02051913          	slli	s2,a0,0x20
 1de:	02095913          	srli	s2,s2,0x20
 1e2:	dc040793          	addi	a5,s0,-576
 1e6:	993e                	add	s2,s2,a5
    *p++ = '/';
 1e8:	00190993          	addi	s3,s2,1
 1ec:	02f00793          	li	a5,47
 1f0:	00f90023          	sb	a5,0(s2)
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 1f4:	00001a17          	auipc	s4,0x1
 1f8:	914a0a13          	addi	s4,s4,-1772 # b08 <malloc+0x142>
        printf("ls: cannot stat %s\n", buf);
 1fc:	00001a97          	auipc	s5,0x1
 200:	8cca8a93          	addi	s5,s5,-1844 # ac8 <malloc+0x102>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 204:	a801                	j	214 <ls+0x160>
        printf("ls: cannot stat %s\n", buf);
 206:	dc040593          	addi	a1,s0,-576
 20a:	8556                	mv	a0,s5
 20c:	00000097          	auipc	ra,0x0
 210:	6fc080e7          	jalr	1788(ra) # 908 <printf>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 214:	4641                	li	a2,16
 216:	db040593          	addi	a1,s0,-592
 21a:	8526                	mv	a0,s1
 21c:	00000097          	auipc	ra,0x0
 220:	35c080e7          	jalr	860(ra) # 578 <read>
 224:	47c1                	li	a5,16
 226:	f0f519e3          	bne	a0,a5,138 <ls+0x84>
      if(de.inum == 0)
 22a:	db045783          	lhu	a5,-592(s0)
 22e:	d3fd                	beqz	a5,214 <ls+0x160>
      memmove(p, de.name, DIRSIZ);
 230:	4639                	li	a2,14
 232:	db240593          	addi	a1,s0,-590
 236:	854e                	mv	a0,s3
 238:	00000097          	auipc	ra,0x0
 23c:	276080e7          	jalr	630(ra) # 4ae <memmove>
      p[DIRSIZ] = 0;
 240:	000907a3          	sb	zero,15(s2)
      if(stat(buf, &st) < 0){
 244:	d9840593          	addi	a1,s0,-616
 248:	dc040513          	addi	a0,s0,-576
 24c:	00000097          	auipc	ra,0x0
 250:	1d2080e7          	jalr	466(ra) # 41e <stat>
 254:	fa0549e3          	bltz	a0,206 <ls+0x152>
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 258:	dc040513          	addi	a0,s0,-576
 25c:	00000097          	auipc	ra,0x0
 260:	da4080e7          	jalr	-604(ra) # 0 <fmtname>
 264:	85aa                	mv	a1,a0
 266:	da843703          	ld	a4,-600(s0)
 26a:	d9c42683          	lw	a3,-612(s0)
 26e:	da041603          	lh	a2,-608(s0)
 272:	8552                	mv	a0,s4
 274:	00000097          	auipc	ra,0x0
 278:	694080e7          	jalr	1684(ra) # 908 <printf>
 27c:	bf61                	j	214 <ls+0x160>

000000000000027e <main>:

int
main(int argc, char *argv[])
{
 27e:	1101                	addi	sp,sp,-32
 280:	ec06                	sd	ra,24(sp)
 282:	e822                	sd	s0,16(sp)
 284:	e426                	sd	s1,8(sp)
 286:	e04a                	sd	s2,0(sp)
 288:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
 28a:	4785                	li	a5,1
 28c:	02a7d963          	bge	a5,a0,2be <main+0x40>
 290:	00858493          	addi	s1,a1,8
 294:	ffe5091b          	addiw	s2,a0,-2
 298:	1902                	slli	s2,s2,0x20
 29a:	02095913          	srli	s2,s2,0x20
 29e:	090e                	slli	s2,s2,0x3
 2a0:	05c1                	addi	a1,a1,16
 2a2:	992e                	add	s2,s2,a1
    ls(".");
    exit(0);
  }
  for(i=1; i<argc; i++)
    ls(argv[i]);
 2a4:	6088                	ld	a0,0(s1)
 2a6:	00000097          	auipc	ra,0x0
 2aa:	e0e080e7          	jalr	-498(ra) # b4 <ls>
  for(i=1; i<argc; i++)
 2ae:	04a1                	addi	s1,s1,8
 2b0:	ff249ae3          	bne	s1,s2,2a4 <main+0x26>
  exit(0);
 2b4:	4501                	li	a0,0
 2b6:	00000097          	auipc	ra,0x0
 2ba:	2aa080e7          	jalr	682(ra) # 560 <exit>
    ls(".");
 2be:	00001517          	auipc	a0,0x1
 2c2:	85a50513          	addi	a0,a0,-1958 # b18 <malloc+0x152>
 2c6:	00000097          	auipc	ra,0x0
 2ca:	dee080e7          	jalr	-530(ra) # b4 <ls>
    exit(0);
 2ce:	4501                	li	a0,0
 2d0:	00000097          	auipc	ra,0x0
 2d4:	290080e7          	jalr	656(ra) # 560 <exit>

00000000000002d8 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 2d8:	1141                	addi	sp,sp,-16
 2da:	e406                	sd	ra,8(sp)
 2dc:	e022                	sd	s0,0(sp)
 2de:	0800                	addi	s0,sp,16
  extern int main();
  main();
 2e0:	00000097          	auipc	ra,0x0
 2e4:	f9e080e7          	jalr	-98(ra) # 27e <main>
  exit(0);
 2e8:	4501                	li	a0,0
 2ea:	00000097          	auipc	ra,0x0
 2ee:	276080e7          	jalr	630(ra) # 560 <exit>

00000000000002f2 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 2f2:	1141                	addi	sp,sp,-16
 2f4:	e422                	sd	s0,8(sp)
 2f6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2f8:	87aa                	mv	a5,a0
 2fa:	0585                	addi	a1,a1,1
 2fc:	0785                	addi	a5,a5,1
 2fe:	fff5c703          	lbu	a4,-1(a1)
 302:	fee78fa3          	sb	a4,-1(a5)
 306:	fb75                	bnez	a4,2fa <strcpy+0x8>
    ;
  return os;
}
 308:	6422                	ld	s0,8(sp)
 30a:	0141                	addi	sp,sp,16
 30c:	8082                	ret

000000000000030e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 30e:	1141                	addi	sp,sp,-16
 310:	e422                	sd	s0,8(sp)
 312:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 314:	00054783          	lbu	a5,0(a0)
 318:	cb91                	beqz	a5,32c <strcmp+0x1e>
 31a:	0005c703          	lbu	a4,0(a1)
 31e:	00f71763          	bne	a4,a5,32c <strcmp+0x1e>
    p++, q++;
 322:	0505                	addi	a0,a0,1
 324:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 326:	00054783          	lbu	a5,0(a0)
 32a:	fbe5                	bnez	a5,31a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 32c:	0005c503          	lbu	a0,0(a1)
}
 330:	40a7853b          	subw	a0,a5,a0
 334:	6422                	ld	s0,8(sp)
 336:	0141                	addi	sp,sp,16
 338:	8082                	ret

000000000000033a <strlen>:

uint
strlen(const char *s)
{
 33a:	1141                	addi	sp,sp,-16
 33c:	e422                	sd	s0,8(sp)
 33e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 340:	00054783          	lbu	a5,0(a0)
 344:	cf91                	beqz	a5,360 <strlen+0x26>
 346:	0505                	addi	a0,a0,1
 348:	87aa                	mv	a5,a0
 34a:	4685                	li	a3,1
 34c:	9e89                	subw	a3,a3,a0
 34e:	00f6853b          	addw	a0,a3,a5
 352:	0785                	addi	a5,a5,1
 354:	fff7c703          	lbu	a4,-1(a5)
 358:	fb7d                	bnez	a4,34e <strlen+0x14>
    ;
  return n;
}
 35a:	6422                	ld	s0,8(sp)
 35c:	0141                	addi	sp,sp,16
 35e:	8082                	ret
  for(n = 0; s[n]; n++)
 360:	4501                	li	a0,0
 362:	bfe5                	j	35a <strlen+0x20>

0000000000000364 <memset>:

void*
memset(void *dst, int c, uint n)
{
 364:	1141                	addi	sp,sp,-16
 366:	e422                	sd	s0,8(sp)
 368:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 36a:	ca19                	beqz	a2,380 <memset+0x1c>
 36c:	87aa                	mv	a5,a0
 36e:	1602                	slli	a2,a2,0x20
 370:	9201                	srli	a2,a2,0x20
 372:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 376:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 37a:	0785                	addi	a5,a5,1
 37c:	fee79de3          	bne	a5,a4,376 <memset+0x12>
  }
  return dst;
}
 380:	6422                	ld	s0,8(sp)
 382:	0141                	addi	sp,sp,16
 384:	8082                	ret

0000000000000386 <strchr>:

char*
strchr(const char *s, char c)
{
 386:	1141                	addi	sp,sp,-16
 388:	e422                	sd	s0,8(sp)
 38a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 38c:	00054783          	lbu	a5,0(a0)
 390:	cb99                	beqz	a5,3a6 <strchr+0x20>
    if(*s == c)
 392:	00f58763          	beq	a1,a5,3a0 <strchr+0x1a>
  for(; *s; s++)
 396:	0505                	addi	a0,a0,1
 398:	00054783          	lbu	a5,0(a0)
 39c:	fbfd                	bnez	a5,392 <strchr+0xc>
      return (char*)s;
  return 0;
 39e:	4501                	li	a0,0
}
 3a0:	6422                	ld	s0,8(sp)
 3a2:	0141                	addi	sp,sp,16
 3a4:	8082                	ret
  return 0;
 3a6:	4501                	li	a0,0
 3a8:	bfe5                	j	3a0 <strchr+0x1a>

00000000000003aa <gets>:

char*
gets(char *buf, int max)
{
 3aa:	711d                	addi	sp,sp,-96
 3ac:	ec86                	sd	ra,88(sp)
 3ae:	e8a2                	sd	s0,80(sp)
 3b0:	e4a6                	sd	s1,72(sp)
 3b2:	e0ca                	sd	s2,64(sp)
 3b4:	fc4e                	sd	s3,56(sp)
 3b6:	f852                	sd	s4,48(sp)
 3b8:	f456                	sd	s5,40(sp)
 3ba:	f05a                	sd	s6,32(sp)
 3bc:	ec5e                	sd	s7,24(sp)
 3be:	1080                	addi	s0,sp,96
 3c0:	8baa                	mv	s7,a0
 3c2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3c4:	892a                	mv	s2,a0
 3c6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 3c8:	4aa9                	li	s5,10
 3ca:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 3cc:	89a6                	mv	s3,s1
 3ce:	2485                	addiw	s1,s1,1
 3d0:	0344d863          	bge	s1,s4,400 <gets+0x56>
    cc = read(0, &c, 1);
 3d4:	4605                	li	a2,1
 3d6:	faf40593          	addi	a1,s0,-81
 3da:	4501                	li	a0,0
 3dc:	00000097          	auipc	ra,0x0
 3e0:	19c080e7          	jalr	412(ra) # 578 <read>
    if(cc < 1)
 3e4:	00a05e63          	blez	a0,400 <gets+0x56>
    buf[i++] = c;
 3e8:	faf44783          	lbu	a5,-81(s0)
 3ec:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 3f0:	01578763          	beq	a5,s5,3fe <gets+0x54>
 3f4:	0905                	addi	s2,s2,1
 3f6:	fd679be3          	bne	a5,s6,3cc <gets+0x22>
  for(i=0; i+1 < max; ){
 3fa:	89a6                	mv	s3,s1
 3fc:	a011                	j	400 <gets+0x56>
 3fe:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 400:	99de                	add	s3,s3,s7
 402:	00098023          	sb	zero,0(s3)
  return buf;
}
 406:	855e                	mv	a0,s7
 408:	60e6                	ld	ra,88(sp)
 40a:	6446                	ld	s0,80(sp)
 40c:	64a6                	ld	s1,72(sp)
 40e:	6906                	ld	s2,64(sp)
 410:	79e2                	ld	s3,56(sp)
 412:	7a42                	ld	s4,48(sp)
 414:	7aa2                	ld	s5,40(sp)
 416:	7b02                	ld	s6,32(sp)
 418:	6be2                	ld	s7,24(sp)
 41a:	6125                	addi	sp,sp,96
 41c:	8082                	ret

000000000000041e <stat>:

int
stat(const char *n, struct stat *st)
{
 41e:	1101                	addi	sp,sp,-32
 420:	ec06                	sd	ra,24(sp)
 422:	e822                	sd	s0,16(sp)
 424:	e426                	sd	s1,8(sp)
 426:	e04a                	sd	s2,0(sp)
 428:	1000                	addi	s0,sp,32
 42a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 42c:	4581                	li	a1,0
 42e:	00000097          	auipc	ra,0x0
 432:	172080e7          	jalr	370(ra) # 5a0 <open>
  if(fd < 0)
 436:	02054563          	bltz	a0,460 <stat+0x42>
 43a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 43c:	85ca                	mv	a1,s2
 43e:	00000097          	auipc	ra,0x0
 442:	17a080e7          	jalr	378(ra) # 5b8 <fstat>
 446:	892a                	mv	s2,a0
  close(fd);
 448:	8526                	mv	a0,s1
 44a:	00000097          	auipc	ra,0x0
 44e:	13e080e7          	jalr	318(ra) # 588 <close>
  return r;
}
 452:	854a                	mv	a0,s2
 454:	60e2                	ld	ra,24(sp)
 456:	6442                	ld	s0,16(sp)
 458:	64a2                	ld	s1,8(sp)
 45a:	6902                	ld	s2,0(sp)
 45c:	6105                	addi	sp,sp,32
 45e:	8082                	ret
    return -1;
 460:	597d                	li	s2,-1
 462:	bfc5                	j	452 <stat+0x34>

0000000000000464 <atoi>:

int
atoi(const char *s)
{
 464:	1141                	addi	sp,sp,-16
 466:	e422                	sd	s0,8(sp)
 468:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 46a:	00054603          	lbu	a2,0(a0)
 46e:	fd06079b          	addiw	a5,a2,-48
 472:	0ff7f793          	andi	a5,a5,255
 476:	4725                	li	a4,9
 478:	02f76963          	bltu	a4,a5,4aa <atoi+0x46>
 47c:	86aa                	mv	a3,a0
  n = 0;
 47e:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 480:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 482:	0685                	addi	a3,a3,1
 484:	0025179b          	slliw	a5,a0,0x2
 488:	9fa9                	addw	a5,a5,a0
 48a:	0017979b          	slliw	a5,a5,0x1
 48e:	9fb1                	addw	a5,a5,a2
 490:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 494:	0006c603          	lbu	a2,0(a3)
 498:	fd06071b          	addiw	a4,a2,-48
 49c:	0ff77713          	andi	a4,a4,255
 4a0:	fee5f1e3          	bgeu	a1,a4,482 <atoi+0x1e>
  return n;
}
 4a4:	6422                	ld	s0,8(sp)
 4a6:	0141                	addi	sp,sp,16
 4a8:	8082                	ret
  n = 0;
 4aa:	4501                	li	a0,0
 4ac:	bfe5                	j	4a4 <atoi+0x40>

00000000000004ae <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4ae:	1141                	addi	sp,sp,-16
 4b0:	e422                	sd	s0,8(sp)
 4b2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 4b4:	02b57463          	bgeu	a0,a1,4dc <memmove+0x2e>
    while(n-- > 0)
 4b8:	00c05f63          	blez	a2,4d6 <memmove+0x28>
 4bc:	1602                	slli	a2,a2,0x20
 4be:	9201                	srli	a2,a2,0x20
 4c0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 4c4:	872a                	mv	a4,a0
      *dst++ = *src++;
 4c6:	0585                	addi	a1,a1,1
 4c8:	0705                	addi	a4,a4,1
 4ca:	fff5c683          	lbu	a3,-1(a1)
 4ce:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 4d2:	fee79ae3          	bne	a5,a4,4c6 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4d6:	6422                	ld	s0,8(sp)
 4d8:	0141                	addi	sp,sp,16
 4da:	8082                	ret
    dst += n;
 4dc:	00c50733          	add	a4,a0,a2
    src += n;
 4e0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 4e2:	fec05ae3          	blez	a2,4d6 <memmove+0x28>
 4e6:	fff6079b          	addiw	a5,a2,-1
 4ea:	1782                	slli	a5,a5,0x20
 4ec:	9381                	srli	a5,a5,0x20
 4ee:	fff7c793          	not	a5,a5
 4f2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 4f4:	15fd                	addi	a1,a1,-1
 4f6:	177d                	addi	a4,a4,-1
 4f8:	0005c683          	lbu	a3,0(a1)
 4fc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 500:	fee79ae3          	bne	a5,a4,4f4 <memmove+0x46>
 504:	bfc9                	j	4d6 <memmove+0x28>

0000000000000506 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 506:	1141                	addi	sp,sp,-16
 508:	e422                	sd	s0,8(sp)
 50a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 50c:	ca05                	beqz	a2,53c <memcmp+0x36>
 50e:	fff6069b          	addiw	a3,a2,-1
 512:	1682                	slli	a3,a3,0x20
 514:	9281                	srli	a3,a3,0x20
 516:	0685                	addi	a3,a3,1
 518:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 51a:	00054783          	lbu	a5,0(a0)
 51e:	0005c703          	lbu	a4,0(a1)
 522:	00e79863          	bne	a5,a4,532 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 526:	0505                	addi	a0,a0,1
    p2++;
 528:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 52a:	fed518e3          	bne	a0,a3,51a <memcmp+0x14>
  }
  return 0;
 52e:	4501                	li	a0,0
 530:	a019                	j	536 <memcmp+0x30>
      return *p1 - *p2;
 532:	40e7853b          	subw	a0,a5,a4
}
 536:	6422                	ld	s0,8(sp)
 538:	0141                	addi	sp,sp,16
 53a:	8082                	ret
  return 0;
 53c:	4501                	li	a0,0
 53e:	bfe5                	j	536 <memcmp+0x30>

0000000000000540 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 540:	1141                	addi	sp,sp,-16
 542:	e406                	sd	ra,8(sp)
 544:	e022                	sd	s0,0(sp)
 546:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 548:	00000097          	auipc	ra,0x0
 54c:	f66080e7          	jalr	-154(ra) # 4ae <memmove>
}
 550:	60a2                	ld	ra,8(sp)
 552:	6402                	ld	s0,0(sp)
 554:	0141                	addi	sp,sp,16
 556:	8082                	ret

0000000000000558 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 558:	4885                	li	a7,1
 ecall
 55a:	00000073          	ecall
 ret
 55e:	8082                	ret

0000000000000560 <exit>:
.global exit
exit:
 li a7, SYS_exit
 560:	4889                	li	a7,2
 ecall
 562:	00000073          	ecall
 ret
 566:	8082                	ret

0000000000000568 <wait>:
.global wait
wait:
 li a7, SYS_wait
 568:	488d                	li	a7,3
 ecall
 56a:	00000073          	ecall
 ret
 56e:	8082                	ret

0000000000000570 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 570:	4891                	li	a7,4
 ecall
 572:	00000073          	ecall
 ret
 576:	8082                	ret

0000000000000578 <read>:
.global read
read:
 li a7, SYS_read
 578:	4895                	li	a7,5
 ecall
 57a:	00000073          	ecall
 ret
 57e:	8082                	ret

0000000000000580 <write>:
.global write
write:
 li a7, SYS_write
 580:	48c1                	li	a7,16
 ecall
 582:	00000073          	ecall
 ret
 586:	8082                	ret

0000000000000588 <close>:
.global close
close:
 li a7, SYS_close
 588:	48d5                	li	a7,21
 ecall
 58a:	00000073          	ecall
 ret
 58e:	8082                	ret

0000000000000590 <kill>:
.global kill
kill:
 li a7, SYS_kill
 590:	4899                	li	a7,6
 ecall
 592:	00000073          	ecall
 ret
 596:	8082                	ret

0000000000000598 <exec>:
.global exec
exec:
 li a7, SYS_exec
 598:	489d                	li	a7,7
 ecall
 59a:	00000073          	ecall
 ret
 59e:	8082                	ret

00000000000005a0 <open>:
.global open
open:
 li a7, SYS_open
 5a0:	48bd                	li	a7,15
 ecall
 5a2:	00000073          	ecall
 ret
 5a6:	8082                	ret

00000000000005a8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5a8:	48c5                	li	a7,17
 ecall
 5aa:	00000073          	ecall
 ret
 5ae:	8082                	ret

00000000000005b0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5b0:	48c9                	li	a7,18
 ecall
 5b2:	00000073          	ecall
 ret
 5b6:	8082                	ret

00000000000005b8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5b8:	48a1                	li	a7,8
 ecall
 5ba:	00000073          	ecall
 ret
 5be:	8082                	ret

00000000000005c0 <link>:
.global link
link:
 li a7, SYS_link
 5c0:	48cd                	li	a7,19
 ecall
 5c2:	00000073          	ecall
 ret
 5c6:	8082                	ret

00000000000005c8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5c8:	48d1                	li	a7,20
 ecall
 5ca:	00000073          	ecall
 ret
 5ce:	8082                	ret

00000000000005d0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5d0:	48a5                	li	a7,9
 ecall
 5d2:	00000073          	ecall
 ret
 5d6:	8082                	ret

00000000000005d8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 5d8:	48a9                	li	a7,10
 ecall
 5da:	00000073          	ecall
 ret
 5de:	8082                	ret

00000000000005e0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5e0:	48ad                	li	a7,11
 ecall
 5e2:	00000073          	ecall
 ret
 5e6:	8082                	ret

00000000000005e8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 5e8:	48b1                	li	a7,12
 ecall
 5ea:	00000073          	ecall
 ret
 5ee:	8082                	ret

00000000000005f0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 5f0:	48b5                	li	a7,13
 ecall
 5f2:	00000073          	ecall
 ret
 5f6:	8082                	ret

00000000000005f8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5f8:	48b9                	li	a7,14
 ecall
 5fa:	00000073          	ecall
 ret
 5fe:	8082                	ret

0000000000000600 <trace>:
.global trace
trace:
 li a7, SYS_trace
 600:	48d9                	li	a7,22
 ecall
 602:	00000073          	ecall
 ret
 606:	8082                	ret

0000000000000608 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 608:	48dd                	li	a7,23
 ecall
 60a:	00000073          	ecall
 ret
 60e:	8082                	ret

0000000000000610 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 610:	48e5                	li	a7,25
 ecall
 612:	00000073          	ecall
 ret
 616:	8082                	ret

0000000000000618 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 618:	48e1                	li	a7,24
 ecall
 61a:	00000073          	ecall
 ret
 61e:	8082                	ret

0000000000000620 <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 620:	48e9                	li	a7,26
 ecall
 622:	00000073          	ecall
 ret
 626:	8082                	ret

0000000000000628 <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 628:	48ed                	li	a7,27
 ecall
 62a:	00000073          	ecall
 ret
 62e:	8082                	ret

0000000000000630 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 630:	1101                	addi	sp,sp,-32
 632:	ec06                	sd	ra,24(sp)
 634:	e822                	sd	s0,16(sp)
 636:	1000                	addi	s0,sp,32
 638:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 63c:	4605                	li	a2,1
 63e:	fef40593          	addi	a1,s0,-17
 642:	00000097          	auipc	ra,0x0
 646:	f3e080e7          	jalr	-194(ra) # 580 <write>
}
 64a:	60e2                	ld	ra,24(sp)
 64c:	6442                	ld	s0,16(sp)
 64e:	6105                	addi	sp,sp,32
 650:	8082                	ret

0000000000000652 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 652:	7139                	addi	sp,sp,-64
 654:	fc06                	sd	ra,56(sp)
 656:	f822                	sd	s0,48(sp)
 658:	f426                	sd	s1,40(sp)
 65a:	f04a                	sd	s2,32(sp)
 65c:	ec4e                	sd	s3,24(sp)
 65e:	0080                	addi	s0,sp,64
 660:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 662:	c299                	beqz	a3,668 <printint+0x16>
 664:	0805c863          	bltz	a1,6f4 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 668:	2581                	sext.w	a1,a1
  neg = 0;
 66a:	4881                	li	a7,0
 66c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 670:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 672:	2601                	sext.w	a2,a2
 674:	00000517          	auipc	a0,0x0
 678:	4b450513          	addi	a0,a0,1204 # b28 <digits>
 67c:	883a                	mv	a6,a4
 67e:	2705                	addiw	a4,a4,1
 680:	02c5f7bb          	remuw	a5,a1,a2
 684:	1782                	slli	a5,a5,0x20
 686:	9381                	srli	a5,a5,0x20
 688:	97aa                	add	a5,a5,a0
 68a:	0007c783          	lbu	a5,0(a5)
 68e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 692:	0005879b          	sext.w	a5,a1
 696:	02c5d5bb          	divuw	a1,a1,a2
 69a:	0685                	addi	a3,a3,1
 69c:	fec7f0e3          	bgeu	a5,a2,67c <printint+0x2a>
  if(neg)
 6a0:	00088b63          	beqz	a7,6b6 <printint+0x64>
    buf[i++] = '-';
 6a4:	fd040793          	addi	a5,s0,-48
 6a8:	973e                	add	a4,a4,a5
 6aa:	02d00793          	li	a5,45
 6ae:	fef70823          	sb	a5,-16(a4)
 6b2:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 6b6:	02e05863          	blez	a4,6e6 <printint+0x94>
 6ba:	fc040793          	addi	a5,s0,-64
 6be:	00e78933          	add	s2,a5,a4
 6c2:	fff78993          	addi	s3,a5,-1
 6c6:	99ba                	add	s3,s3,a4
 6c8:	377d                	addiw	a4,a4,-1
 6ca:	1702                	slli	a4,a4,0x20
 6cc:	9301                	srli	a4,a4,0x20
 6ce:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 6d2:	fff94583          	lbu	a1,-1(s2)
 6d6:	8526                	mv	a0,s1
 6d8:	00000097          	auipc	ra,0x0
 6dc:	f58080e7          	jalr	-168(ra) # 630 <putc>
  while(--i >= 0)
 6e0:	197d                	addi	s2,s2,-1
 6e2:	ff3918e3          	bne	s2,s3,6d2 <printint+0x80>
}
 6e6:	70e2                	ld	ra,56(sp)
 6e8:	7442                	ld	s0,48(sp)
 6ea:	74a2                	ld	s1,40(sp)
 6ec:	7902                	ld	s2,32(sp)
 6ee:	69e2                	ld	s3,24(sp)
 6f0:	6121                	addi	sp,sp,64
 6f2:	8082                	ret
    x = -xx;
 6f4:	40b005bb          	negw	a1,a1
    neg = 1;
 6f8:	4885                	li	a7,1
    x = -xx;
 6fa:	bf8d                	j	66c <printint+0x1a>

00000000000006fc <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6fc:	7119                	addi	sp,sp,-128
 6fe:	fc86                	sd	ra,120(sp)
 700:	f8a2                	sd	s0,112(sp)
 702:	f4a6                	sd	s1,104(sp)
 704:	f0ca                	sd	s2,96(sp)
 706:	ecce                	sd	s3,88(sp)
 708:	e8d2                	sd	s4,80(sp)
 70a:	e4d6                	sd	s5,72(sp)
 70c:	e0da                	sd	s6,64(sp)
 70e:	fc5e                	sd	s7,56(sp)
 710:	f862                	sd	s8,48(sp)
 712:	f466                	sd	s9,40(sp)
 714:	f06a                	sd	s10,32(sp)
 716:	ec6e                	sd	s11,24(sp)
 718:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 71a:	0005c903          	lbu	s2,0(a1)
 71e:	18090f63          	beqz	s2,8bc <vprintf+0x1c0>
 722:	8aaa                	mv	s5,a0
 724:	8b32                	mv	s6,a2
 726:	00158493          	addi	s1,a1,1
  state = 0;
 72a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 72c:	02500a13          	li	s4,37
      if(c == 'd'){
 730:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 734:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 738:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 73c:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 740:	00000b97          	auipc	s7,0x0
 744:	3e8b8b93          	addi	s7,s7,1000 # b28 <digits>
 748:	a839                	j	766 <vprintf+0x6a>
        putc(fd, c);
 74a:	85ca                	mv	a1,s2
 74c:	8556                	mv	a0,s5
 74e:	00000097          	auipc	ra,0x0
 752:	ee2080e7          	jalr	-286(ra) # 630 <putc>
 756:	a019                	j	75c <vprintf+0x60>
    } else if(state == '%'){
 758:	01498f63          	beq	s3,s4,776 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 75c:	0485                	addi	s1,s1,1
 75e:	fff4c903          	lbu	s2,-1(s1)
 762:	14090d63          	beqz	s2,8bc <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 766:	0009079b          	sext.w	a5,s2
    if(state == 0){
 76a:	fe0997e3          	bnez	s3,758 <vprintf+0x5c>
      if(c == '%'){
 76e:	fd479ee3          	bne	a5,s4,74a <vprintf+0x4e>
        state = '%';
 772:	89be                	mv	s3,a5
 774:	b7e5                	j	75c <vprintf+0x60>
      if(c == 'd'){
 776:	05878063          	beq	a5,s8,7b6 <vprintf+0xba>
      } else if(c == 'l') {
 77a:	05978c63          	beq	a5,s9,7d2 <vprintf+0xd6>
      } else if(c == 'x') {
 77e:	07a78863          	beq	a5,s10,7ee <vprintf+0xf2>
      } else if(c == 'p') {
 782:	09b78463          	beq	a5,s11,80a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 786:	07300713          	li	a4,115
 78a:	0ce78663          	beq	a5,a4,856 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 78e:	06300713          	li	a4,99
 792:	0ee78e63          	beq	a5,a4,88e <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 796:	11478863          	beq	a5,s4,8a6 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 79a:	85d2                	mv	a1,s4
 79c:	8556                	mv	a0,s5
 79e:	00000097          	auipc	ra,0x0
 7a2:	e92080e7          	jalr	-366(ra) # 630 <putc>
        putc(fd, c);
 7a6:	85ca                	mv	a1,s2
 7a8:	8556                	mv	a0,s5
 7aa:	00000097          	auipc	ra,0x0
 7ae:	e86080e7          	jalr	-378(ra) # 630 <putc>
      }
      state = 0;
 7b2:	4981                	li	s3,0
 7b4:	b765                	j	75c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 7b6:	008b0913          	addi	s2,s6,8
 7ba:	4685                	li	a3,1
 7bc:	4629                	li	a2,10
 7be:	000b2583          	lw	a1,0(s6)
 7c2:	8556                	mv	a0,s5
 7c4:	00000097          	auipc	ra,0x0
 7c8:	e8e080e7          	jalr	-370(ra) # 652 <printint>
 7cc:	8b4a                	mv	s6,s2
      state = 0;
 7ce:	4981                	li	s3,0
 7d0:	b771                	j	75c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7d2:	008b0913          	addi	s2,s6,8
 7d6:	4681                	li	a3,0
 7d8:	4629                	li	a2,10
 7da:	000b2583          	lw	a1,0(s6)
 7de:	8556                	mv	a0,s5
 7e0:	00000097          	auipc	ra,0x0
 7e4:	e72080e7          	jalr	-398(ra) # 652 <printint>
 7e8:	8b4a                	mv	s6,s2
      state = 0;
 7ea:	4981                	li	s3,0
 7ec:	bf85                	j	75c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 7ee:	008b0913          	addi	s2,s6,8
 7f2:	4681                	li	a3,0
 7f4:	4641                	li	a2,16
 7f6:	000b2583          	lw	a1,0(s6)
 7fa:	8556                	mv	a0,s5
 7fc:	00000097          	auipc	ra,0x0
 800:	e56080e7          	jalr	-426(ra) # 652 <printint>
 804:	8b4a                	mv	s6,s2
      state = 0;
 806:	4981                	li	s3,0
 808:	bf91                	j	75c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 80a:	008b0793          	addi	a5,s6,8
 80e:	f8f43423          	sd	a5,-120(s0)
 812:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 816:	03000593          	li	a1,48
 81a:	8556                	mv	a0,s5
 81c:	00000097          	auipc	ra,0x0
 820:	e14080e7          	jalr	-492(ra) # 630 <putc>
  putc(fd, 'x');
 824:	85ea                	mv	a1,s10
 826:	8556                	mv	a0,s5
 828:	00000097          	auipc	ra,0x0
 82c:	e08080e7          	jalr	-504(ra) # 630 <putc>
 830:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 832:	03c9d793          	srli	a5,s3,0x3c
 836:	97de                	add	a5,a5,s7
 838:	0007c583          	lbu	a1,0(a5)
 83c:	8556                	mv	a0,s5
 83e:	00000097          	auipc	ra,0x0
 842:	df2080e7          	jalr	-526(ra) # 630 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 846:	0992                	slli	s3,s3,0x4
 848:	397d                	addiw	s2,s2,-1
 84a:	fe0914e3          	bnez	s2,832 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 84e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 852:	4981                	li	s3,0
 854:	b721                	j	75c <vprintf+0x60>
        s = va_arg(ap, char*);
 856:	008b0993          	addi	s3,s6,8
 85a:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 85e:	02090163          	beqz	s2,880 <vprintf+0x184>
        while(*s != 0){
 862:	00094583          	lbu	a1,0(s2)
 866:	c9a1                	beqz	a1,8b6 <vprintf+0x1ba>
          putc(fd, *s);
 868:	8556                	mv	a0,s5
 86a:	00000097          	auipc	ra,0x0
 86e:	dc6080e7          	jalr	-570(ra) # 630 <putc>
          s++;
 872:	0905                	addi	s2,s2,1
        while(*s != 0){
 874:	00094583          	lbu	a1,0(s2)
 878:	f9e5                	bnez	a1,868 <vprintf+0x16c>
        s = va_arg(ap, char*);
 87a:	8b4e                	mv	s6,s3
      state = 0;
 87c:	4981                	li	s3,0
 87e:	bdf9                	j	75c <vprintf+0x60>
          s = "(null)";
 880:	00000917          	auipc	s2,0x0
 884:	2a090913          	addi	s2,s2,672 # b20 <malloc+0x15a>
        while(*s != 0){
 888:	02800593          	li	a1,40
 88c:	bff1                	j	868 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 88e:	008b0913          	addi	s2,s6,8
 892:	000b4583          	lbu	a1,0(s6)
 896:	8556                	mv	a0,s5
 898:	00000097          	auipc	ra,0x0
 89c:	d98080e7          	jalr	-616(ra) # 630 <putc>
 8a0:	8b4a                	mv	s6,s2
      state = 0;
 8a2:	4981                	li	s3,0
 8a4:	bd65                	j	75c <vprintf+0x60>
        putc(fd, c);
 8a6:	85d2                	mv	a1,s4
 8a8:	8556                	mv	a0,s5
 8aa:	00000097          	auipc	ra,0x0
 8ae:	d86080e7          	jalr	-634(ra) # 630 <putc>
      state = 0;
 8b2:	4981                	li	s3,0
 8b4:	b565                	j	75c <vprintf+0x60>
        s = va_arg(ap, char*);
 8b6:	8b4e                	mv	s6,s3
      state = 0;
 8b8:	4981                	li	s3,0
 8ba:	b54d                	j	75c <vprintf+0x60>
    }
  }
}
 8bc:	70e6                	ld	ra,120(sp)
 8be:	7446                	ld	s0,112(sp)
 8c0:	74a6                	ld	s1,104(sp)
 8c2:	7906                	ld	s2,96(sp)
 8c4:	69e6                	ld	s3,88(sp)
 8c6:	6a46                	ld	s4,80(sp)
 8c8:	6aa6                	ld	s5,72(sp)
 8ca:	6b06                	ld	s6,64(sp)
 8cc:	7be2                	ld	s7,56(sp)
 8ce:	7c42                	ld	s8,48(sp)
 8d0:	7ca2                	ld	s9,40(sp)
 8d2:	7d02                	ld	s10,32(sp)
 8d4:	6de2                	ld	s11,24(sp)
 8d6:	6109                	addi	sp,sp,128
 8d8:	8082                	ret

00000000000008da <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8da:	715d                	addi	sp,sp,-80
 8dc:	ec06                	sd	ra,24(sp)
 8de:	e822                	sd	s0,16(sp)
 8e0:	1000                	addi	s0,sp,32
 8e2:	e010                	sd	a2,0(s0)
 8e4:	e414                	sd	a3,8(s0)
 8e6:	e818                	sd	a4,16(s0)
 8e8:	ec1c                	sd	a5,24(s0)
 8ea:	03043023          	sd	a6,32(s0)
 8ee:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8f2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8f6:	8622                	mv	a2,s0
 8f8:	00000097          	auipc	ra,0x0
 8fc:	e04080e7          	jalr	-508(ra) # 6fc <vprintf>
}
 900:	60e2                	ld	ra,24(sp)
 902:	6442                	ld	s0,16(sp)
 904:	6161                	addi	sp,sp,80
 906:	8082                	ret

0000000000000908 <printf>:

void
printf(const char *fmt, ...)
{
 908:	711d                	addi	sp,sp,-96
 90a:	ec06                	sd	ra,24(sp)
 90c:	e822                	sd	s0,16(sp)
 90e:	1000                	addi	s0,sp,32
 910:	e40c                	sd	a1,8(s0)
 912:	e810                	sd	a2,16(s0)
 914:	ec14                	sd	a3,24(s0)
 916:	f018                	sd	a4,32(s0)
 918:	f41c                	sd	a5,40(s0)
 91a:	03043823          	sd	a6,48(s0)
 91e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 922:	00840613          	addi	a2,s0,8
 926:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 92a:	85aa                	mv	a1,a0
 92c:	4505                	li	a0,1
 92e:	00000097          	auipc	ra,0x0
 932:	dce080e7          	jalr	-562(ra) # 6fc <vprintf>
}
 936:	60e2                	ld	ra,24(sp)
 938:	6442                	ld	s0,16(sp)
 93a:	6125                	addi	sp,sp,96
 93c:	8082                	ret

000000000000093e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 93e:	1141                	addi	sp,sp,-16
 940:	e422                	sd	s0,8(sp)
 942:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 944:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 948:	00000797          	auipc	a5,0x0
 94c:	6b87b783          	ld	a5,1720(a5) # 1000 <freep>
 950:	a805                	j	980 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 952:	4618                	lw	a4,8(a2)
 954:	9db9                	addw	a1,a1,a4
 956:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 95a:	6398                	ld	a4,0(a5)
 95c:	6318                	ld	a4,0(a4)
 95e:	fee53823          	sd	a4,-16(a0)
 962:	a091                	j	9a6 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 964:	ff852703          	lw	a4,-8(a0)
 968:	9e39                	addw	a2,a2,a4
 96a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 96c:	ff053703          	ld	a4,-16(a0)
 970:	e398                	sd	a4,0(a5)
 972:	a099                	j	9b8 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 974:	6398                	ld	a4,0(a5)
 976:	00e7e463          	bltu	a5,a4,97e <free+0x40>
 97a:	00e6ea63          	bltu	a3,a4,98e <free+0x50>
{
 97e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 980:	fed7fae3          	bgeu	a5,a3,974 <free+0x36>
 984:	6398                	ld	a4,0(a5)
 986:	00e6e463          	bltu	a3,a4,98e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 98a:	fee7eae3          	bltu	a5,a4,97e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 98e:	ff852583          	lw	a1,-8(a0)
 992:	6390                	ld	a2,0(a5)
 994:	02059713          	slli	a4,a1,0x20
 998:	9301                	srli	a4,a4,0x20
 99a:	0712                	slli	a4,a4,0x4
 99c:	9736                	add	a4,a4,a3
 99e:	fae60ae3          	beq	a2,a4,952 <free+0x14>
    bp->s.ptr = p->s.ptr;
 9a2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9a6:	4790                	lw	a2,8(a5)
 9a8:	02061713          	slli	a4,a2,0x20
 9ac:	9301                	srli	a4,a4,0x20
 9ae:	0712                	slli	a4,a4,0x4
 9b0:	973e                	add	a4,a4,a5
 9b2:	fae689e3          	beq	a3,a4,964 <free+0x26>
  } else
    p->s.ptr = bp;
 9b6:	e394                	sd	a3,0(a5)
  freep = p;
 9b8:	00000717          	auipc	a4,0x0
 9bc:	64f73423          	sd	a5,1608(a4) # 1000 <freep>
}
 9c0:	6422                	ld	s0,8(sp)
 9c2:	0141                	addi	sp,sp,16
 9c4:	8082                	ret

00000000000009c6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9c6:	7139                	addi	sp,sp,-64
 9c8:	fc06                	sd	ra,56(sp)
 9ca:	f822                	sd	s0,48(sp)
 9cc:	f426                	sd	s1,40(sp)
 9ce:	f04a                	sd	s2,32(sp)
 9d0:	ec4e                	sd	s3,24(sp)
 9d2:	e852                	sd	s4,16(sp)
 9d4:	e456                	sd	s5,8(sp)
 9d6:	e05a                	sd	s6,0(sp)
 9d8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9da:	02051493          	slli	s1,a0,0x20
 9de:	9081                	srli	s1,s1,0x20
 9e0:	04bd                	addi	s1,s1,15
 9e2:	8091                	srli	s1,s1,0x4
 9e4:	0014899b          	addiw	s3,s1,1
 9e8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9ea:	00000517          	auipc	a0,0x0
 9ee:	61653503          	ld	a0,1558(a0) # 1000 <freep>
 9f2:	c515                	beqz	a0,a1e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9f4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9f6:	4798                	lw	a4,8(a5)
 9f8:	02977f63          	bgeu	a4,s1,a36 <malloc+0x70>
 9fc:	8a4e                	mv	s4,s3
 9fe:	0009871b          	sext.w	a4,s3
 a02:	6685                	lui	a3,0x1
 a04:	00d77363          	bgeu	a4,a3,a0a <malloc+0x44>
 a08:	6a05                	lui	s4,0x1
 a0a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a0e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a12:	00000917          	auipc	s2,0x0
 a16:	5ee90913          	addi	s2,s2,1518 # 1000 <freep>
  if(p == (char*)-1)
 a1a:	5afd                	li	s5,-1
 a1c:	a88d                	j	a8e <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 a1e:	00000797          	auipc	a5,0x0
 a22:	60278793          	addi	a5,a5,1538 # 1020 <base>
 a26:	00000717          	auipc	a4,0x0
 a2a:	5cf73d23          	sd	a5,1498(a4) # 1000 <freep>
 a2e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a30:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a34:	b7e1                	j	9fc <malloc+0x36>
      if(p->s.size == nunits)
 a36:	02e48b63          	beq	s1,a4,a6c <malloc+0xa6>
        p->s.size -= nunits;
 a3a:	4137073b          	subw	a4,a4,s3
 a3e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a40:	1702                	slli	a4,a4,0x20
 a42:	9301                	srli	a4,a4,0x20
 a44:	0712                	slli	a4,a4,0x4
 a46:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a48:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a4c:	00000717          	auipc	a4,0x0
 a50:	5aa73a23          	sd	a0,1460(a4) # 1000 <freep>
      return (void*)(p + 1);
 a54:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a58:	70e2                	ld	ra,56(sp)
 a5a:	7442                	ld	s0,48(sp)
 a5c:	74a2                	ld	s1,40(sp)
 a5e:	7902                	ld	s2,32(sp)
 a60:	69e2                	ld	s3,24(sp)
 a62:	6a42                	ld	s4,16(sp)
 a64:	6aa2                	ld	s5,8(sp)
 a66:	6b02                	ld	s6,0(sp)
 a68:	6121                	addi	sp,sp,64
 a6a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a6c:	6398                	ld	a4,0(a5)
 a6e:	e118                	sd	a4,0(a0)
 a70:	bff1                	j	a4c <malloc+0x86>
  hp->s.size = nu;
 a72:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a76:	0541                	addi	a0,a0,16
 a78:	00000097          	auipc	ra,0x0
 a7c:	ec6080e7          	jalr	-314(ra) # 93e <free>
  return freep;
 a80:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a84:	d971                	beqz	a0,a58 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a86:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a88:	4798                	lw	a4,8(a5)
 a8a:	fa9776e3          	bgeu	a4,s1,a36 <malloc+0x70>
    if(p == freep)
 a8e:	00093703          	ld	a4,0(s2)
 a92:	853e                	mv	a0,a5
 a94:	fef719e3          	bne	a4,a5,a86 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 a98:	8552                	mv	a0,s4
 a9a:	00000097          	auipc	ra,0x0
 a9e:	b4e080e7          	jalr	-1202(ra) # 5e8 <sbrk>
  if(p == (char*)-1)
 aa2:	fd5518e3          	bne	a0,s5,a72 <malloc+0xac>
        return 0;
 aa6:	4501                	li	a0,0
 aa8:	bf45                	j	a58 <malloc+0x92>

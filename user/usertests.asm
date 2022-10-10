
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <copyinstr1>:
}

// what if you pass ridiculous string pointers to system calls?
void
copyinstr1(char *s)
{
       0:	1141                	addi	sp,sp,-16
       2:	e406                	sd	ra,8(sp)
       4:	e022                	sd	s0,0(sp)
       6:	0800                	addi	s0,sp,16
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };

  for(int ai = 0; ai < 2; ai++){
    uint64 addr = addrs[ai];

    int fd = open((char *)addr, O_CREATE|O_WRONLY);
       8:	20100593          	li	a1,513
       c:	4505                	li	a0,1
       e:	057e                	slli	a0,a0,0x1f
      10:	00006097          	auipc	ra,0x6
      14:	bf6080e7          	jalr	-1034(ra) # 5c06 <open>
    if(fd >= 0){
      18:	02055063          	bgez	a0,38 <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
      1c:	20100593          	li	a1,513
      20:	557d                	li	a0,-1
      22:	00006097          	auipc	ra,0x6
      26:	be4080e7          	jalr	-1052(ra) # 5c06 <open>
    uint64 addr = addrs[ai];
      2a:	55fd                	li	a1,-1
    if(fd >= 0){
      2c:	00055863          	bgez	a0,3c <copyinstr1+0x3c>
      printf("open(%p) returned %d, not -1\n", addr, fd);
      exit(1);
    }
  }
}
      30:	60a2                	ld	ra,8(sp)
      32:	6402                	ld	s0,0(sp)
      34:	0141                	addi	sp,sp,16
      36:	8082                	ret
    uint64 addr = addrs[ai];
      38:	4585                	li	a1,1
      3a:	05fe                	slli	a1,a1,0x1f
      printf("open(%p) returned %d, not -1\n", addr, fd);
      3c:	862a                	mv	a2,a0
      3e:	00006517          	auipc	a0,0x6
      42:	0d250513          	addi	a0,a0,210 # 6110 <malloc+0x10c>
      46:	00006097          	auipc	ra,0x6
      4a:	f00080e7          	jalr	-256(ra) # 5f46 <printf>
      exit(1);
      4e:	4505                	li	a0,1
      50:	00006097          	auipc	ra,0x6
      54:	b76080e7          	jalr	-1162(ra) # 5bc6 <exit>

0000000000000058 <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
      58:	0000a797          	auipc	a5,0xa
      5c:	51078793          	addi	a5,a5,1296 # a568 <uninit>
      60:	0000d697          	auipc	a3,0xd
      64:	c1868693          	addi	a3,a3,-1000 # cc78 <buf>
    if(uninit[i] != '\0'){
      68:	0007c703          	lbu	a4,0(a5)
      6c:	e709                	bnez	a4,76 <bsstest+0x1e>
  for(i = 0; i < sizeof(uninit); i++){
      6e:	0785                	addi	a5,a5,1
      70:	fed79ce3          	bne	a5,a3,68 <bsstest+0x10>
      74:	8082                	ret
{
      76:	1141                	addi	sp,sp,-16
      78:	e406                	sd	ra,8(sp)
      7a:	e022                	sd	s0,0(sp)
      7c:	0800                	addi	s0,sp,16
      printf("%s: bss test failed\n", s);
      7e:	85aa                	mv	a1,a0
      80:	00006517          	auipc	a0,0x6
      84:	0b050513          	addi	a0,a0,176 # 6130 <malloc+0x12c>
      88:	00006097          	auipc	ra,0x6
      8c:	ebe080e7          	jalr	-322(ra) # 5f46 <printf>
      exit(1);
      90:	4505                	li	a0,1
      92:	00006097          	auipc	ra,0x6
      96:	b34080e7          	jalr	-1228(ra) # 5bc6 <exit>

000000000000009a <opentest>:
{
      9a:	1101                	addi	sp,sp,-32
      9c:	ec06                	sd	ra,24(sp)
      9e:	e822                	sd	s0,16(sp)
      a0:	e426                	sd	s1,8(sp)
      a2:	1000                	addi	s0,sp,32
      a4:	84aa                	mv	s1,a0
  fd = open("echo", 0);
      a6:	4581                	li	a1,0
      a8:	00006517          	auipc	a0,0x6
      ac:	0a050513          	addi	a0,a0,160 # 6148 <malloc+0x144>
      b0:	00006097          	auipc	ra,0x6
      b4:	b56080e7          	jalr	-1194(ra) # 5c06 <open>
  if(fd < 0){
      b8:	02054663          	bltz	a0,e4 <opentest+0x4a>
  close(fd);
      bc:	00006097          	auipc	ra,0x6
      c0:	b32080e7          	jalr	-1230(ra) # 5bee <close>
  fd = open("doesnotexist", 0);
      c4:	4581                	li	a1,0
      c6:	00006517          	auipc	a0,0x6
      ca:	0a250513          	addi	a0,a0,162 # 6168 <malloc+0x164>
      ce:	00006097          	auipc	ra,0x6
      d2:	b38080e7          	jalr	-1224(ra) # 5c06 <open>
  if(fd >= 0){
      d6:	02055563          	bgez	a0,100 <opentest+0x66>
}
      da:	60e2                	ld	ra,24(sp)
      dc:	6442                	ld	s0,16(sp)
      de:	64a2                	ld	s1,8(sp)
      e0:	6105                	addi	sp,sp,32
      e2:	8082                	ret
    printf("%s: open echo failed!\n", s);
      e4:	85a6                	mv	a1,s1
      e6:	00006517          	auipc	a0,0x6
      ea:	06a50513          	addi	a0,a0,106 # 6150 <malloc+0x14c>
      ee:	00006097          	auipc	ra,0x6
      f2:	e58080e7          	jalr	-424(ra) # 5f46 <printf>
    exit(1);
      f6:	4505                	li	a0,1
      f8:	00006097          	auipc	ra,0x6
      fc:	ace080e7          	jalr	-1330(ra) # 5bc6 <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     100:	85a6                	mv	a1,s1
     102:	00006517          	auipc	a0,0x6
     106:	07650513          	addi	a0,a0,118 # 6178 <malloc+0x174>
     10a:	00006097          	auipc	ra,0x6
     10e:	e3c080e7          	jalr	-452(ra) # 5f46 <printf>
    exit(1);
     112:	4505                	li	a0,1
     114:	00006097          	auipc	ra,0x6
     118:	ab2080e7          	jalr	-1358(ra) # 5bc6 <exit>

000000000000011c <truncate2>:
{
     11c:	7179                	addi	sp,sp,-48
     11e:	f406                	sd	ra,40(sp)
     120:	f022                	sd	s0,32(sp)
     122:	ec26                	sd	s1,24(sp)
     124:	e84a                	sd	s2,16(sp)
     126:	e44e                	sd	s3,8(sp)
     128:	1800                	addi	s0,sp,48
     12a:	89aa                	mv	s3,a0
  unlink("truncfile");
     12c:	00006517          	auipc	a0,0x6
     130:	07450513          	addi	a0,a0,116 # 61a0 <malloc+0x19c>
     134:	00006097          	auipc	ra,0x6
     138:	ae2080e7          	jalr	-1310(ra) # 5c16 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     13c:	60100593          	li	a1,1537
     140:	00006517          	auipc	a0,0x6
     144:	06050513          	addi	a0,a0,96 # 61a0 <malloc+0x19c>
     148:	00006097          	auipc	ra,0x6
     14c:	abe080e7          	jalr	-1346(ra) # 5c06 <open>
     150:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     152:	4611                	li	a2,4
     154:	00006597          	auipc	a1,0x6
     158:	05c58593          	addi	a1,a1,92 # 61b0 <malloc+0x1ac>
     15c:	00006097          	auipc	ra,0x6
     160:	a8a080e7          	jalr	-1398(ra) # 5be6 <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     164:	40100593          	li	a1,1025
     168:	00006517          	auipc	a0,0x6
     16c:	03850513          	addi	a0,a0,56 # 61a0 <malloc+0x19c>
     170:	00006097          	auipc	ra,0x6
     174:	a96080e7          	jalr	-1386(ra) # 5c06 <open>
     178:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     17a:	4605                	li	a2,1
     17c:	00006597          	auipc	a1,0x6
     180:	03c58593          	addi	a1,a1,60 # 61b8 <malloc+0x1b4>
     184:	8526                	mv	a0,s1
     186:	00006097          	auipc	ra,0x6
     18a:	a60080e7          	jalr	-1440(ra) # 5be6 <write>
  if(n != -1){
     18e:	57fd                	li	a5,-1
     190:	02f51b63          	bne	a0,a5,1c6 <truncate2+0xaa>
  unlink("truncfile");
     194:	00006517          	auipc	a0,0x6
     198:	00c50513          	addi	a0,a0,12 # 61a0 <malloc+0x19c>
     19c:	00006097          	auipc	ra,0x6
     1a0:	a7a080e7          	jalr	-1414(ra) # 5c16 <unlink>
  close(fd1);
     1a4:	8526                	mv	a0,s1
     1a6:	00006097          	auipc	ra,0x6
     1aa:	a48080e7          	jalr	-1464(ra) # 5bee <close>
  close(fd2);
     1ae:	854a                	mv	a0,s2
     1b0:	00006097          	auipc	ra,0x6
     1b4:	a3e080e7          	jalr	-1474(ra) # 5bee <close>
}
     1b8:	70a2                	ld	ra,40(sp)
     1ba:	7402                	ld	s0,32(sp)
     1bc:	64e2                	ld	s1,24(sp)
     1be:	6942                	ld	s2,16(sp)
     1c0:	69a2                	ld	s3,8(sp)
     1c2:	6145                	addi	sp,sp,48
     1c4:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     1c6:	862a                	mv	a2,a0
     1c8:	85ce                	mv	a1,s3
     1ca:	00006517          	auipc	a0,0x6
     1ce:	ff650513          	addi	a0,a0,-10 # 61c0 <malloc+0x1bc>
     1d2:	00006097          	auipc	ra,0x6
     1d6:	d74080e7          	jalr	-652(ra) # 5f46 <printf>
    exit(1);
     1da:	4505                	li	a0,1
     1dc:	00006097          	auipc	ra,0x6
     1e0:	9ea080e7          	jalr	-1558(ra) # 5bc6 <exit>

00000000000001e4 <createtest>:
{
     1e4:	7179                	addi	sp,sp,-48
     1e6:	f406                	sd	ra,40(sp)
     1e8:	f022                	sd	s0,32(sp)
     1ea:	ec26                	sd	s1,24(sp)
     1ec:	e84a                	sd	s2,16(sp)
     1ee:	1800                	addi	s0,sp,48
  name[0] = 'a';
     1f0:	06100793          	li	a5,97
     1f4:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     1f8:	fc040d23          	sb	zero,-38(s0)
     1fc:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     200:	06400913          	li	s2,100
    name[1] = '0' + i;
     204:	fc940ca3          	sb	s1,-39(s0)
    fd = open(name, O_CREATE|O_RDWR);
     208:	20200593          	li	a1,514
     20c:	fd840513          	addi	a0,s0,-40
     210:	00006097          	auipc	ra,0x6
     214:	9f6080e7          	jalr	-1546(ra) # 5c06 <open>
    close(fd);
     218:	00006097          	auipc	ra,0x6
     21c:	9d6080e7          	jalr	-1578(ra) # 5bee <close>
  for(i = 0; i < N; i++){
     220:	2485                	addiw	s1,s1,1
     222:	0ff4f493          	andi	s1,s1,255
     226:	fd249fe3          	bne	s1,s2,204 <createtest+0x20>
  name[0] = 'a';
     22a:	06100793          	li	a5,97
     22e:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     232:	fc040d23          	sb	zero,-38(s0)
     236:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     23a:	06400913          	li	s2,100
    name[1] = '0' + i;
     23e:	fc940ca3          	sb	s1,-39(s0)
    unlink(name);
     242:	fd840513          	addi	a0,s0,-40
     246:	00006097          	auipc	ra,0x6
     24a:	9d0080e7          	jalr	-1584(ra) # 5c16 <unlink>
  for(i = 0; i < N; i++){
     24e:	2485                	addiw	s1,s1,1
     250:	0ff4f493          	andi	s1,s1,255
     254:	ff2495e3          	bne	s1,s2,23e <createtest+0x5a>
}
     258:	70a2                	ld	ra,40(sp)
     25a:	7402                	ld	s0,32(sp)
     25c:	64e2                	ld	s1,24(sp)
     25e:	6942                	ld	s2,16(sp)
     260:	6145                	addi	sp,sp,48
     262:	8082                	ret

0000000000000264 <bigwrite>:
{
     264:	715d                	addi	sp,sp,-80
     266:	e486                	sd	ra,72(sp)
     268:	e0a2                	sd	s0,64(sp)
     26a:	fc26                	sd	s1,56(sp)
     26c:	f84a                	sd	s2,48(sp)
     26e:	f44e                	sd	s3,40(sp)
     270:	f052                	sd	s4,32(sp)
     272:	ec56                	sd	s5,24(sp)
     274:	e85a                	sd	s6,16(sp)
     276:	e45e                	sd	s7,8(sp)
     278:	0880                	addi	s0,sp,80
     27a:	8baa                	mv	s7,a0
  unlink("bigwrite");
     27c:	00006517          	auipc	a0,0x6
     280:	f6c50513          	addi	a0,a0,-148 # 61e8 <malloc+0x1e4>
     284:	00006097          	auipc	ra,0x6
     288:	992080e7          	jalr	-1646(ra) # 5c16 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     28c:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     290:	00006a97          	auipc	s5,0x6
     294:	f58a8a93          	addi	s5,s5,-168 # 61e8 <malloc+0x1e4>
      int cc = write(fd, buf, sz);
     298:	0000da17          	auipc	s4,0xd
     29c:	9e0a0a13          	addi	s4,s4,-1568 # cc78 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2a0:	6b0d                	lui	s6,0x3
     2a2:	1c9b0b13          	addi	s6,s6,457 # 31c9 <diskfull+0x1>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2a6:	20200593          	li	a1,514
     2aa:	8556                	mv	a0,s5
     2ac:	00006097          	auipc	ra,0x6
     2b0:	95a080e7          	jalr	-1702(ra) # 5c06 <open>
     2b4:	892a                	mv	s2,a0
    if(fd < 0){
     2b6:	04054d63          	bltz	a0,310 <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     2ba:	8626                	mv	a2,s1
     2bc:	85d2                	mv	a1,s4
     2be:	00006097          	auipc	ra,0x6
     2c2:	928080e7          	jalr	-1752(ra) # 5be6 <write>
     2c6:	89aa                	mv	s3,a0
      if(cc != sz){
     2c8:	06a49463          	bne	s1,a0,330 <bigwrite+0xcc>
      int cc = write(fd, buf, sz);
     2cc:	8626                	mv	a2,s1
     2ce:	85d2                	mv	a1,s4
     2d0:	854a                	mv	a0,s2
     2d2:	00006097          	auipc	ra,0x6
     2d6:	914080e7          	jalr	-1772(ra) # 5be6 <write>
      if(cc != sz){
     2da:	04951963          	bne	a0,s1,32c <bigwrite+0xc8>
    close(fd);
     2de:	854a                	mv	a0,s2
     2e0:	00006097          	auipc	ra,0x6
     2e4:	90e080e7          	jalr	-1778(ra) # 5bee <close>
    unlink("bigwrite");
     2e8:	8556                	mv	a0,s5
     2ea:	00006097          	auipc	ra,0x6
     2ee:	92c080e7          	jalr	-1748(ra) # 5c16 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2f2:	1d74849b          	addiw	s1,s1,471
     2f6:	fb6498e3          	bne	s1,s6,2a6 <bigwrite+0x42>
}
     2fa:	60a6                	ld	ra,72(sp)
     2fc:	6406                	ld	s0,64(sp)
     2fe:	74e2                	ld	s1,56(sp)
     300:	7942                	ld	s2,48(sp)
     302:	79a2                	ld	s3,40(sp)
     304:	7a02                	ld	s4,32(sp)
     306:	6ae2                	ld	s5,24(sp)
     308:	6b42                	ld	s6,16(sp)
     30a:	6ba2                	ld	s7,8(sp)
     30c:	6161                	addi	sp,sp,80
     30e:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     310:	85de                	mv	a1,s7
     312:	00006517          	auipc	a0,0x6
     316:	ee650513          	addi	a0,a0,-282 # 61f8 <malloc+0x1f4>
     31a:	00006097          	auipc	ra,0x6
     31e:	c2c080e7          	jalr	-980(ra) # 5f46 <printf>
      exit(1);
     322:	4505                	li	a0,1
     324:	00006097          	auipc	ra,0x6
     328:	8a2080e7          	jalr	-1886(ra) # 5bc6 <exit>
     32c:	84ce                	mv	s1,s3
      int cc = write(fd, buf, sz);
     32e:	89aa                	mv	s3,a0
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     330:	86ce                	mv	a3,s3
     332:	8626                	mv	a2,s1
     334:	85de                	mv	a1,s7
     336:	00006517          	auipc	a0,0x6
     33a:	ee250513          	addi	a0,a0,-286 # 6218 <malloc+0x214>
     33e:	00006097          	auipc	ra,0x6
     342:	c08080e7          	jalr	-1016(ra) # 5f46 <printf>
        exit(1);
     346:	4505                	li	a0,1
     348:	00006097          	auipc	ra,0x6
     34c:	87e080e7          	jalr	-1922(ra) # 5bc6 <exit>

0000000000000350 <badwrite>:
// file is deleted? if the kernel has this bug, it will panic: balloc:
// out of blocks. assumed_free may need to be raised to be more than
// the number of free blocks. this test takes a long time.
void
badwrite(char *s)
{
     350:	7179                	addi	sp,sp,-48
     352:	f406                	sd	ra,40(sp)
     354:	f022                	sd	s0,32(sp)
     356:	ec26                	sd	s1,24(sp)
     358:	e84a                	sd	s2,16(sp)
     35a:	e44e                	sd	s3,8(sp)
     35c:	e052                	sd	s4,0(sp)
     35e:	1800                	addi	s0,sp,48
  int assumed_free = 600;
  
  unlink("junk");
     360:	00006517          	auipc	a0,0x6
     364:	ed050513          	addi	a0,a0,-304 # 6230 <malloc+0x22c>
     368:	00006097          	auipc	ra,0x6
     36c:	8ae080e7          	jalr	-1874(ra) # 5c16 <unlink>
     370:	25800913          	li	s2,600
  for(int i = 0; i < assumed_free; i++){
    int fd = open("junk", O_CREATE|O_WRONLY);
     374:	00006997          	auipc	s3,0x6
     378:	ebc98993          	addi	s3,s3,-324 # 6230 <malloc+0x22c>
    if(fd < 0){
      printf("open junk failed\n");
      exit(1);
    }
    write(fd, (char*)0xffffffffffL, 1);
     37c:	5a7d                	li	s4,-1
     37e:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
     382:	20100593          	li	a1,513
     386:	854e                	mv	a0,s3
     388:	00006097          	auipc	ra,0x6
     38c:	87e080e7          	jalr	-1922(ra) # 5c06 <open>
     390:	84aa                	mv	s1,a0
    if(fd < 0){
     392:	06054b63          	bltz	a0,408 <badwrite+0xb8>
    write(fd, (char*)0xffffffffffL, 1);
     396:	4605                	li	a2,1
     398:	85d2                	mv	a1,s4
     39a:	00006097          	auipc	ra,0x6
     39e:	84c080e7          	jalr	-1972(ra) # 5be6 <write>
    close(fd);
     3a2:	8526                	mv	a0,s1
     3a4:	00006097          	auipc	ra,0x6
     3a8:	84a080e7          	jalr	-1974(ra) # 5bee <close>
    unlink("junk");
     3ac:	854e                	mv	a0,s3
     3ae:	00006097          	auipc	ra,0x6
     3b2:	868080e7          	jalr	-1944(ra) # 5c16 <unlink>
  for(int i = 0; i < assumed_free; i++){
     3b6:	397d                	addiw	s2,s2,-1
     3b8:	fc0915e3          	bnez	s2,382 <badwrite+0x32>
  }

  int fd = open("junk", O_CREATE|O_WRONLY);
     3bc:	20100593          	li	a1,513
     3c0:	00006517          	auipc	a0,0x6
     3c4:	e7050513          	addi	a0,a0,-400 # 6230 <malloc+0x22c>
     3c8:	00006097          	auipc	ra,0x6
     3cc:	83e080e7          	jalr	-1986(ra) # 5c06 <open>
     3d0:	84aa                	mv	s1,a0
  if(fd < 0){
     3d2:	04054863          	bltz	a0,422 <badwrite+0xd2>
    printf("open junk failed\n");
    exit(1);
  }
  if(write(fd, "x", 1) != 1){
     3d6:	4605                	li	a2,1
     3d8:	00006597          	auipc	a1,0x6
     3dc:	de058593          	addi	a1,a1,-544 # 61b8 <malloc+0x1b4>
     3e0:	00006097          	auipc	ra,0x6
     3e4:	806080e7          	jalr	-2042(ra) # 5be6 <write>
     3e8:	4785                	li	a5,1
     3ea:	04f50963          	beq	a0,a5,43c <badwrite+0xec>
    printf("write failed\n");
     3ee:	00006517          	auipc	a0,0x6
     3f2:	e6250513          	addi	a0,a0,-414 # 6250 <malloc+0x24c>
     3f6:	00006097          	auipc	ra,0x6
     3fa:	b50080e7          	jalr	-1200(ra) # 5f46 <printf>
    exit(1);
     3fe:	4505                	li	a0,1
     400:	00005097          	auipc	ra,0x5
     404:	7c6080e7          	jalr	1990(ra) # 5bc6 <exit>
      printf("open junk failed\n");
     408:	00006517          	auipc	a0,0x6
     40c:	e3050513          	addi	a0,a0,-464 # 6238 <malloc+0x234>
     410:	00006097          	auipc	ra,0x6
     414:	b36080e7          	jalr	-1226(ra) # 5f46 <printf>
      exit(1);
     418:	4505                	li	a0,1
     41a:	00005097          	auipc	ra,0x5
     41e:	7ac080e7          	jalr	1964(ra) # 5bc6 <exit>
    printf("open junk failed\n");
     422:	00006517          	auipc	a0,0x6
     426:	e1650513          	addi	a0,a0,-490 # 6238 <malloc+0x234>
     42a:	00006097          	auipc	ra,0x6
     42e:	b1c080e7          	jalr	-1252(ra) # 5f46 <printf>
    exit(1);
     432:	4505                	li	a0,1
     434:	00005097          	auipc	ra,0x5
     438:	792080e7          	jalr	1938(ra) # 5bc6 <exit>
  }
  close(fd);
     43c:	8526                	mv	a0,s1
     43e:	00005097          	auipc	ra,0x5
     442:	7b0080e7          	jalr	1968(ra) # 5bee <close>
  unlink("junk");
     446:	00006517          	auipc	a0,0x6
     44a:	dea50513          	addi	a0,a0,-534 # 6230 <malloc+0x22c>
     44e:	00005097          	auipc	ra,0x5
     452:	7c8080e7          	jalr	1992(ra) # 5c16 <unlink>

  exit(0);
     456:	4501                	li	a0,0
     458:	00005097          	auipc	ra,0x5
     45c:	76e080e7          	jalr	1902(ra) # 5bc6 <exit>

0000000000000460 <outofinodes>:
  }
}

void
outofinodes(char *s)
{
     460:	715d                	addi	sp,sp,-80
     462:	e486                	sd	ra,72(sp)
     464:	e0a2                	sd	s0,64(sp)
     466:	fc26                	sd	s1,56(sp)
     468:	f84a                	sd	s2,48(sp)
     46a:	f44e                	sd	s3,40(sp)
     46c:	0880                	addi	s0,sp,80
  int nzz = 32*32;
  for(int i = 0; i < nzz; i++){
     46e:	4481                	li	s1,0
    char name[32];
    name[0] = 'z';
     470:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
     474:	40000993          	li	s3,1024
    name[0] = 'z';
     478:	fb240823          	sb	s2,-80(s0)
    name[1] = 'z';
     47c:	fb2408a3          	sb	s2,-79(s0)
    name[2] = '0' + (i / 32);
     480:	41f4d79b          	sraiw	a5,s1,0x1f
     484:	01b7d71b          	srliw	a4,a5,0x1b
     488:	009707bb          	addw	a5,a4,s1
     48c:	4057d69b          	sraiw	a3,a5,0x5
     490:	0306869b          	addiw	a3,a3,48
     494:	fad40923          	sb	a3,-78(s0)
    name[3] = '0' + (i % 32);
     498:	8bfd                	andi	a5,a5,31
     49a:	9f99                	subw	a5,a5,a4
     49c:	0307879b          	addiw	a5,a5,48
     4a0:	faf409a3          	sb	a5,-77(s0)
    name[4] = '\0';
     4a4:	fa040a23          	sb	zero,-76(s0)
    unlink(name);
     4a8:	fb040513          	addi	a0,s0,-80
     4ac:	00005097          	auipc	ra,0x5
     4b0:	76a080e7          	jalr	1898(ra) # 5c16 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
     4b4:	60200593          	li	a1,1538
     4b8:	fb040513          	addi	a0,s0,-80
     4bc:	00005097          	auipc	ra,0x5
     4c0:	74a080e7          	jalr	1866(ra) # 5c06 <open>
    if(fd < 0){
     4c4:	00054963          	bltz	a0,4d6 <outofinodes+0x76>
      // failure is eventually expected.
      break;
    }
    close(fd);
     4c8:	00005097          	auipc	ra,0x5
     4cc:	726080e7          	jalr	1830(ra) # 5bee <close>
  for(int i = 0; i < nzz; i++){
     4d0:	2485                	addiw	s1,s1,1
     4d2:	fb3493e3          	bne	s1,s3,478 <outofinodes+0x18>
     4d6:	4481                	li	s1,0
  }

  for(int i = 0; i < nzz; i++){
    char name[32];
    name[0] = 'z';
     4d8:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
     4dc:	40000993          	li	s3,1024
    name[0] = 'z';
     4e0:	fb240823          	sb	s2,-80(s0)
    name[1] = 'z';
     4e4:	fb2408a3          	sb	s2,-79(s0)
    name[2] = '0' + (i / 32);
     4e8:	41f4d79b          	sraiw	a5,s1,0x1f
     4ec:	01b7d71b          	srliw	a4,a5,0x1b
     4f0:	009707bb          	addw	a5,a4,s1
     4f4:	4057d69b          	sraiw	a3,a5,0x5
     4f8:	0306869b          	addiw	a3,a3,48
     4fc:	fad40923          	sb	a3,-78(s0)
    name[3] = '0' + (i % 32);
     500:	8bfd                	andi	a5,a5,31
     502:	9f99                	subw	a5,a5,a4
     504:	0307879b          	addiw	a5,a5,48
     508:	faf409a3          	sb	a5,-77(s0)
    name[4] = '\0';
     50c:	fa040a23          	sb	zero,-76(s0)
    unlink(name);
     510:	fb040513          	addi	a0,s0,-80
     514:	00005097          	auipc	ra,0x5
     518:	702080e7          	jalr	1794(ra) # 5c16 <unlink>
  for(int i = 0; i < nzz; i++){
     51c:	2485                	addiw	s1,s1,1
     51e:	fd3491e3          	bne	s1,s3,4e0 <outofinodes+0x80>
  }
}
     522:	60a6                	ld	ra,72(sp)
     524:	6406                	ld	s0,64(sp)
     526:	74e2                	ld	s1,56(sp)
     528:	7942                	ld	s2,48(sp)
     52a:	79a2                	ld	s3,40(sp)
     52c:	6161                	addi	sp,sp,80
     52e:	8082                	ret

0000000000000530 <copyin>:
{
     530:	715d                	addi	sp,sp,-80
     532:	e486                	sd	ra,72(sp)
     534:	e0a2                	sd	s0,64(sp)
     536:	fc26                	sd	s1,56(sp)
     538:	f84a                	sd	s2,48(sp)
     53a:	f44e                	sd	s3,40(sp)
     53c:	f052                	sd	s4,32(sp)
     53e:	0880                	addi	s0,sp,80
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     540:	4785                	li	a5,1
     542:	07fe                	slli	a5,a5,0x1f
     544:	fcf43023          	sd	a5,-64(s0)
     548:	57fd                	li	a5,-1
     54a:	fcf43423          	sd	a5,-56(s0)
  for(int ai = 0; ai < 2; ai++){
     54e:	fc040913          	addi	s2,s0,-64
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     552:	00006a17          	auipc	s4,0x6
     556:	d0ea0a13          	addi	s4,s4,-754 # 6260 <malloc+0x25c>
    uint64 addr = addrs[ai];
     55a:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     55e:	20100593          	li	a1,513
     562:	8552                	mv	a0,s4
     564:	00005097          	auipc	ra,0x5
     568:	6a2080e7          	jalr	1698(ra) # 5c06 <open>
     56c:	84aa                	mv	s1,a0
    if(fd < 0){
     56e:	08054863          	bltz	a0,5fe <copyin+0xce>
    int n = write(fd, (void*)addr, 8192);
     572:	6609                	lui	a2,0x2
     574:	85ce                	mv	a1,s3
     576:	00005097          	auipc	ra,0x5
     57a:	670080e7          	jalr	1648(ra) # 5be6 <write>
    if(n >= 0){
     57e:	08055d63          	bgez	a0,618 <copyin+0xe8>
    close(fd);
     582:	8526                	mv	a0,s1
     584:	00005097          	auipc	ra,0x5
     588:	66a080e7          	jalr	1642(ra) # 5bee <close>
    unlink("copyin1");
     58c:	8552                	mv	a0,s4
     58e:	00005097          	auipc	ra,0x5
     592:	688080e7          	jalr	1672(ra) # 5c16 <unlink>
    n = write(1, (char*)addr, 8192);
     596:	6609                	lui	a2,0x2
     598:	85ce                	mv	a1,s3
     59a:	4505                	li	a0,1
     59c:	00005097          	auipc	ra,0x5
     5a0:	64a080e7          	jalr	1610(ra) # 5be6 <write>
    if(n > 0){
     5a4:	08a04963          	bgtz	a0,636 <copyin+0x106>
    if(pipe(fds) < 0){
     5a8:	fb840513          	addi	a0,s0,-72
     5ac:	00005097          	auipc	ra,0x5
     5b0:	62a080e7          	jalr	1578(ra) # 5bd6 <pipe>
     5b4:	0a054063          	bltz	a0,654 <copyin+0x124>
    n = write(fds[1], (char*)addr, 8192);
     5b8:	6609                	lui	a2,0x2
     5ba:	85ce                	mv	a1,s3
     5bc:	fbc42503          	lw	a0,-68(s0)
     5c0:	00005097          	auipc	ra,0x5
     5c4:	626080e7          	jalr	1574(ra) # 5be6 <write>
    if(n > 0){
     5c8:	0aa04363          	bgtz	a0,66e <copyin+0x13e>
    close(fds[0]);
     5cc:	fb842503          	lw	a0,-72(s0)
     5d0:	00005097          	auipc	ra,0x5
     5d4:	61e080e7          	jalr	1566(ra) # 5bee <close>
    close(fds[1]);
     5d8:	fbc42503          	lw	a0,-68(s0)
     5dc:	00005097          	auipc	ra,0x5
     5e0:	612080e7          	jalr	1554(ra) # 5bee <close>
  for(int ai = 0; ai < 2; ai++){
     5e4:	0921                	addi	s2,s2,8
     5e6:	fd040793          	addi	a5,s0,-48
     5ea:	f6f918e3          	bne	s2,a5,55a <copyin+0x2a>
}
     5ee:	60a6                	ld	ra,72(sp)
     5f0:	6406                	ld	s0,64(sp)
     5f2:	74e2                	ld	s1,56(sp)
     5f4:	7942                	ld	s2,48(sp)
     5f6:	79a2                	ld	s3,40(sp)
     5f8:	7a02                	ld	s4,32(sp)
     5fa:	6161                	addi	sp,sp,80
     5fc:	8082                	ret
      printf("open(copyin1) failed\n");
     5fe:	00006517          	auipc	a0,0x6
     602:	c6a50513          	addi	a0,a0,-918 # 6268 <malloc+0x264>
     606:	00006097          	auipc	ra,0x6
     60a:	940080e7          	jalr	-1728(ra) # 5f46 <printf>
      exit(1);
     60e:	4505                	li	a0,1
     610:	00005097          	auipc	ra,0x5
     614:	5b6080e7          	jalr	1462(ra) # 5bc6 <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
     618:	862a                	mv	a2,a0
     61a:	85ce                	mv	a1,s3
     61c:	00006517          	auipc	a0,0x6
     620:	c6450513          	addi	a0,a0,-924 # 6280 <malloc+0x27c>
     624:	00006097          	auipc	ra,0x6
     628:	922080e7          	jalr	-1758(ra) # 5f46 <printf>
      exit(1);
     62c:	4505                	li	a0,1
     62e:	00005097          	auipc	ra,0x5
     632:	598080e7          	jalr	1432(ra) # 5bc6 <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     636:	862a                	mv	a2,a0
     638:	85ce                	mv	a1,s3
     63a:	00006517          	auipc	a0,0x6
     63e:	c7650513          	addi	a0,a0,-906 # 62b0 <malloc+0x2ac>
     642:	00006097          	auipc	ra,0x6
     646:	904080e7          	jalr	-1788(ra) # 5f46 <printf>
      exit(1);
     64a:	4505                	li	a0,1
     64c:	00005097          	auipc	ra,0x5
     650:	57a080e7          	jalr	1402(ra) # 5bc6 <exit>
      printf("pipe() failed\n");
     654:	00006517          	auipc	a0,0x6
     658:	c8c50513          	addi	a0,a0,-884 # 62e0 <malloc+0x2dc>
     65c:	00006097          	auipc	ra,0x6
     660:	8ea080e7          	jalr	-1814(ra) # 5f46 <printf>
      exit(1);
     664:	4505                	li	a0,1
     666:	00005097          	auipc	ra,0x5
     66a:	560080e7          	jalr	1376(ra) # 5bc6 <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     66e:	862a                	mv	a2,a0
     670:	85ce                	mv	a1,s3
     672:	00006517          	auipc	a0,0x6
     676:	c7e50513          	addi	a0,a0,-898 # 62f0 <malloc+0x2ec>
     67a:	00006097          	auipc	ra,0x6
     67e:	8cc080e7          	jalr	-1844(ra) # 5f46 <printf>
      exit(1);
     682:	4505                	li	a0,1
     684:	00005097          	auipc	ra,0x5
     688:	542080e7          	jalr	1346(ra) # 5bc6 <exit>

000000000000068c <copyout>:
{
     68c:	711d                	addi	sp,sp,-96
     68e:	ec86                	sd	ra,88(sp)
     690:	e8a2                	sd	s0,80(sp)
     692:	e4a6                	sd	s1,72(sp)
     694:	e0ca                	sd	s2,64(sp)
     696:	fc4e                	sd	s3,56(sp)
     698:	f852                	sd	s4,48(sp)
     69a:	f456                	sd	s5,40(sp)
     69c:	1080                	addi	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     69e:	4785                	li	a5,1
     6a0:	07fe                	slli	a5,a5,0x1f
     6a2:	faf43823          	sd	a5,-80(s0)
     6a6:	57fd                	li	a5,-1
     6a8:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < 2; ai++){
     6ac:	fb040913          	addi	s2,s0,-80
    int fd = open("README", 0);
     6b0:	00006a17          	auipc	s4,0x6
     6b4:	c70a0a13          	addi	s4,s4,-912 # 6320 <malloc+0x31c>
    n = write(fds[1], "x", 1);
     6b8:	00006a97          	auipc	s5,0x6
     6bc:	b00a8a93          	addi	s5,s5,-1280 # 61b8 <malloc+0x1b4>
    uint64 addr = addrs[ai];
     6c0:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     6c4:	4581                	li	a1,0
     6c6:	8552                	mv	a0,s4
     6c8:	00005097          	auipc	ra,0x5
     6cc:	53e080e7          	jalr	1342(ra) # 5c06 <open>
     6d0:	84aa                	mv	s1,a0
    if(fd < 0){
     6d2:	08054663          	bltz	a0,75e <copyout+0xd2>
    int n = read(fd, (void*)addr, 8192);
     6d6:	6609                	lui	a2,0x2
     6d8:	85ce                	mv	a1,s3
     6da:	00005097          	auipc	ra,0x5
     6de:	504080e7          	jalr	1284(ra) # 5bde <read>
    if(n > 0){
     6e2:	08a04b63          	bgtz	a0,778 <copyout+0xec>
    close(fd);
     6e6:	8526                	mv	a0,s1
     6e8:	00005097          	auipc	ra,0x5
     6ec:	506080e7          	jalr	1286(ra) # 5bee <close>
    if(pipe(fds) < 0){
     6f0:	fa840513          	addi	a0,s0,-88
     6f4:	00005097          	auipc	ra,0x5
     6f8:	4e2080e7          	jalr	1250(ra) # 5bd6 <pipe>
     6fc:	08054d63          	bltz	a0,796 <copyout+0x10a>
    n = write(fds[1], "x", 1);
     700:	4605                	li	a2,1
     702:	85d6                	mv	a1,s5
     704:	fac42503          	lw	a0,-84(s0)
     708:	00005097          	auipc	ra,0x5
     70c:	4de080e7          	jalr	1246(ra) # 5be6 <write>
    if(n != 1){
     710:	4785                	li	a5,1
     712:	08f51f63          	bne	a0,a5,7b0 <copyout+0x124>
    n = read(fds[0], (void*)addr, 8192);
     716:	6609                	lui	a2,0x2
     718:	85ce                	mv	a1,s3
     71a:	fa842503          	lw	a0,-88(s0)
     71e:	00005097          	auipc	ra,0x5
     722:	4c0080e7          	jalr	1216(ra) # 5bde <read>
    if(n > 0){
     726:	0aa04263          	bgtz	a0,7ca <copyout+0x13e>
    close(fds[0]);
     72a:	fa842503          	lw	a0,-88(s0)
     72e:	00005097          	auipc	ra,0x5
     732:	4c0080e7          	jalr	1216(ra) # 5bee <close>
    close(fds[1]);
     736:	fac42503          	lw	a0,-84(s0)
     73a:	00005097          	auipc	ra,0x5
     73e:	4b4080e7          	jalr	1204(ra) # 5bee <close>
  for(int ai = 0; ai < 2; ai++){
     742:	0921                	addi	s2,s2,8
     744:	fc040793          	addi	a5,s0,-64
     748:	f6f91ce3          	bne	s2,a5,6c0 <copyout+0x34>
}
     74c:	60e6                	ld	ra,88(sp)
     74e:	6446                	ld	s0,80(sp)
     750:	64a6                	ld	s1,72(sp)
     752:	6906                	ld	s2,64(sp)
     754:	79e2                	ld	s3,56(sp)
     756:	7a42                	ld	s4,48(sp)
     758:	7aa2                	ld	s5,40(sp)
     75a:	6125                	addi	sp,sp,96
     75c:	8082                	ret
      printf("open(README) failed\n");
     75e:	00006517          	auipc	a0,0x6
     762:	bca50513          	addi	a0,a0,-1078 # 6328 <malloc+0x324>
     766:	00005097          	auipc	ra,0x5
     76a:	7e0080e7          	jalr	2016(ra) # 5f46 <printf>
      exit(1);
     76e:	4505                	li	a0,1
     770:	00005097          	auipc	ra,0x5
     774:	456080e7          	jalr	1110(ra) # 5bc6 <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     778:	862a                	mv	a2,a0
     77a:	85ce                	mv	a1,s3
     77c:	00006517          	auipc	a0,0x6
     780:	bc450513          	addi	a0,a0,-1084 # 6340 <malloc+0x33c>
     784:	00005097          	auipc	ra,0x5
     788:	7c2080e7          	jalr	1986(ra) # 5f46 <printf>
      exit(1);
     78c:	4505                	li	a0,1
     78e:	00005097          	auipc	ra,0x5
     792:	438080e7          	jalr	1080(ra) # 5bc6 <exit>
      printf("pipe() failed\n");
     796:	00006517          	auipc	a0,0x6
     79a:	b4a50513          	addi	a0,a0,-1206 # 62e0 <malloc+0x2dc>
     79e:	00005097          	auipc	ra,0x5
     7a2:	7a8080e7          	jalr	1960(ra) # 5f46 <printf>
      exit(1);
     7a6:	4505                	li	a0,1
     7a8:	00005097          	auipc	ra,0x5
     7ac:	41e080e7          	jalr	1054(ra) # 5bc6 <exit>
      printf("pipe write failed\n");
     7b0:	00006517          	auipc	a0,0x6
     7b4:	bc050513          	addi	a0,a0,-1088 # 6370 <malloc+0x36c>
     7b8:	00005097          	auipc	ra,0x5
     7bc:	78e080e7          	jalr	1934(ra) # 5f46 <printf>
      exit(1);
     7c0:	4505                	li	a0,1
     7c2:	00005097          	auipc	ra,0x5
     7c6:	404080e7          	jalr	1028(ra) # 5bc6 <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     7ca:	862a                	mv	a2,a0
     7cc:	85ce                	mv	a1,s3
     7ce:	00006517          	auipc	a0,0x6
     7d2:	bba50513          	addi	a0,a0,-1094 # 6388 <malloc+0x384>
     7d6:	00005097          	auipc	ra,0x5
     7da:	770080e7          	jalr	1904(ra) # 5f46 <printf>
      exit(1);
     7de:	4505                	li	a0,1
     7e0:	00005097          	auipc	ra,0x5
     7e4:	3e6080e7          	jalr	998(ra) # 5bc6 <exit>

00000000000007e8 <truncate1>:
{
     7e8:	711d                	addi	sp,sp,-96
     7ea:	ec86                	sd	ra,88(sp)
     7ec:	e8a2                	sd	s0,80(sp)
     7ee:	e4a6                	sd	s1,72(sp)
     7f0:	e0ca                	sd	s2,64(sp)
     7f2:	fc4e                	sd	s3,56(sp)
     7f4:	f852                	sd	s4,48(sp)
     7f6:	f456                	sd	s5,40(sp)
     7f8:	1080                	addi	s0,sp,96
     7fa:	8aaa                	mv	s5,a0
  unlink("truncfile");
     7fc:	00006517          	auipc	a0,0x6
     800:	9a450513          	addi	a0,a0,-1628 # 61a0 <malloc+0x19c>
     804:	00005097          	auipc	ra,0x5
     808:	412080e7          	jalr	1042(ra) # 5c16 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     80c:	60100593          	li	a1,1537
     810:	00006517          	auipc	a0,0x6
     814:	99050513          	addi	a0,a0,-1648 # 61a0 <malloc+0x19c>
     818:	00005097          	auipc	ra,0x5
     81c:	3ee080e7          	jalr	1006(ra) # 5c06 <open>
     820:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     822:	4611                	li	a2,4
     824:	00006597          	auipc	a1,0x6
     828:	98c58593          	addi	a1,a1,-1652 # 61b0 <malloc+0x1ac>
     82c:	00005097          	auipc	ra,0x5
     830:	3ba080e7          	jalr	954(ra) # 5be6 <write>
  close(fd1);
     834:	8526                	mv	a0,s1
     836:	00005097          	auipc	ra,0x5
     83a:	3b8080e7          	jalr	952(ra) # 5bee <close>
  int fd2 = open("truncfile", O_RDONLY);
     83e:	4581                	li	a1,0
     840:	00006517          	auipc	a0,0x6
     844:	96050513          	addi	a0,a0,-1696 # 61a0 <malloc+0x19c>
     848:	00005097          	auipc	ra,0x5
     84c:	3be080e7          	jalr	958(ra) # 5c06 <open>
     850:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     852:	02000613          	li	a2,32
     856:	fa040593          	addi	a1,s0,-96
     85a:	00005097          	auipc	ra,0x5
     85e:	384080e7          	jalr	900(ra) # 5bde <read>
  if(n != 4){
     862:	4791                	li	a5,4
     864:	0cf51e63          	bne	a0,a5,940 <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     868:	40100593          	li	a1,1025
     86c:	00006517          	auipc	a0,0x6
     870:	93450513          	addi	a0,a0,-1740 # 61a0 <malloc+0x19c>
     874:	00005097          	auipc	ra,0x5
     878:	392080e7          	jalr	914(ra) # 5c06 <open>
     87c:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     87e:	4581                	li	a1,0
     880:	00006517          	auipc	a0,0x6
     884:	92050513          	addi	a0,a0,-1760 # 61a0 <malloc+0x19c>
     888:	00005097          	auipc	ra,0x5
     88c:	37e080e7          	jalr	894(ra) # 5c06 <open>
     890:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     892:	02000613          	li	a2,32
     896:	fa040593          	addi	a1,s0,-96
     89a:	00005097          	auipc	ra,0x5
     89e:	344080e7          	jalr	836(ra) # 5bde <read>
     8a2:	8a2a                	mv	s4,a0
  if(n != 0){
     8a4:	ed4d                	bnez	a0,95e <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
     8a6:	02000613          	li	a2,32
     8aa:	fa040593          	addi	a1,s0,-96
     8ae:	8526                	mv	a0,s1
     8b0:	00005097          	auipc	ra,0x5
     8b4:	32e080e7          	jalr	814(ra) # 5bde <read>
     8b8:	8a2a                	mv	s4,a0
  if(n != 0){
     8ba:	e971                	bnez	a0,98e <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
     8bc:	4619                	li	a2,6
     8be:	00006597          	auipc	a1,0x6
     8c2:	b5a58593          	addi	a1,a1,-1190 # 6418 <malloc+0x414>
     8c6:	854e                	mv	a0,s3
     8c8:	00005097          	auipc	ra,0x5
     8cc:	31e080e7          	jalr	798(ra) # 5be6 <write>
  n = read(fd3, buf, sizeof(buf));
     8d0:	02000613          	li	a2,32
     8d4:	fa040593          	addi	a1,s0,-96
     8d8:	854a                	mv	a0,s2
     8da:	00005097          	auipc	ra,0x5
     8de:	304080e7          	jalr	772(ra) # 5bde <read>
  if(n != 6){
     8e2:	4799                	li	a5,6
     8e4:	0cf51d63          	bne	a0,a5,9be <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
     8e8:	02000613          	li	a2,32
     8ec:	fa040593          	addi	a1,s0,-96
     8f0:	8526                	mv	a0,s1
     8f2:	00005097          	auipc	ra,0x5
     8f6:	2ec080e7          	jalr	748(ra) # 5bde <read>
  if(n != 2){
     8fa:	4789                	li	a5,2
     8fc:	0ef51063          	bne	a0,a5,9dc <truncate1+0x1f4>
  unlink("truncfile");
     900:	00006517          	auipc	a0,0x6
     904:	8a050513          	addi	a0,a0,-1888 # 61a0 <malloc+0x19c>
     908:	00005097          	auipc	ra,0x5
     90c:	30e080e7          	jalr	782(ra) # 5c16 <unlink>
  close(fd1);
     910:	854e                	mv	a0,s3
     912:	00005097          	auipc	ra,0x5
     916:	2dc080e7          	jalr	732(ra) # 5bee <close>
  close(fd2);
     91a:	8526                	mv	a0,s1
     91c:	00005097          	auipc	ra,0x5
     920:	2d2080e7          	jalr	722(ra) # 5bee <close>
  close(fd3);
     924:	854a                	mv	a0,s2
     926:	00005097          	auipc	ra,0x5
     92a:	2c8080e7          	jalr	712(ra) # 5bee <close>
}
     92e:	60e6                	ld	ra,88(sp)
     930:	6446                	ld	s0,80(sp)
     932:	64a6                	ld	s1,72(sp)
     934:	6906                	ld	s2,64(sp)
     936:	79e2                	ld	s3,56(sp)
     938:	7a42                	ld	s4,48(sp)
     93a:	7aa2                	ld	s5,40(sp)
     93c:	6125                	addi	sp,sp,96
     93e:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     940:	862a                	mv	a2,a0
     942:	85d6                	mv	a1,s5
     944:	00006517          	auipc	a0,0x6
     948:	a7450513          	addi	a0,a0,-1420 # 63b8 <malloc+0x3b4>
     94c:	00005097          	auipc	ra,0x5
     950:	5fa080e7          	jalr	1530(ra) # 5f46 <printf>
    exit(1);
     954:	4505                	li	a0,1
     956:	00005097          	auipc	ra,0x5
     95a:	270080e7          	jalr	624(ra) # 5bc6 <exit>
    printf("aaa fd3=%d\n", fd3);
     95e:	85ca                	mv	a1,s2
     960:	00006517          	auipc	a0,0x6
     964:	a7850513          	addi	a0,a0,-1416 # 63d8 <malloc+0x3d4>
     968:	00005097          	auipc	ra,0x5
     96c:	5de080e7          	jalr	1502(ra) # 5f46 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     970:	8652                	mv	a2,s4
     972:	85d6                	mv	a1,s5
     974:	00006517          	auipc	a0,0x6
     978:	a7450513          	addi	a0,a0,-1420 # 63e8 <malloc+0x3e4>
     97c:	00005097          	auipc	ra,0x5
     980:	5ca080e7          	jalr	1482(ra) # 5f46 <printf>
    exit(1);
     984:	4505                	li	a0,1
     986:	00005097          	auipc	ra,0x5
     98a:	240080e7          	jalr	576(ra) # 5bc6 <exit>
    printf("bbb fd2=%d\n", fd2);
     98e:	85a6                	mv	a1,s1
     990:	00006517          	auipc	a0,0x6
     994:	a7850513          	addi	a0,a0,-1416 # 6408 <malloc+0x404>
     998:	00005097          	auipc	ra,0x5
     99c:	5ae080e7          	jalr	1454(ra) # 5f46 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     9a0:	8652                	mv	a2,s4
     9a2:	85d6                	mv	a1,s5
     9a4:	00006517          	auipc	a0,0x6
     9a8:	a4450513          	addi	a0,a0,-1468 # 63e8 <malloc+0x3e4>
     9ac:	00005097          	auipc	ra,0x5
     9b0:	59a080e7          	jalr	1434(ra) # 5f46 <printf>
    exit(1);
     9b4:	4505                	li	a0,1
     9b6:	00005097          	auipc	ra,0x5
     9ba:	210080e7          	jalr	528(ra) # 5bc6 <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     9be:	862a                	mv	a2,a0
     9c0:	85d6                	mv	a1,s5
     9c2:	00006517          	auipc	a0,0x6
     9c6:	a5e50513          	addi	a0,a0,-1442 # 6420 <malloc+0x41c>
     9ca:	00005097          	auipc	ra,0x5
     9ce:	57c080e7          	jalr	1404(ra) # 5f46 <printf>
    exit(1);
     9d2:	4505                	li	a0,1
     9d4:	00005097          	auipc	ra,0x5
     9d8:	1f2080e7          	jalr	498(ra) # 5bc6 <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     9dc:	862a                	mv	a2,a0
     9de:	85d6                	mv	a1,s5
     9e0:	00006517          	auipc	a0,0x6
     9e4:	a6050513          	addi	a0,a0,-1440 # 6440 <malloc+0x43c>
     9e8:	00005097          	auipc	ra,0x5
     9ec:	55e080e7          	jalr	1374(ra) # 5f46 <printf>
    exit(1);
     9f0:	4505                	li	a0,1
     9f2:	00005097          	auipc	ra,0x5
     9f6:	1d4080e7          	jalr	468(ra) # 5bc6 <exit>

00000000000009fa <writetest>:
{
     9fa:	7139                	addi	sp,sp,-64
     9fc:	fc06                	sd	ra,56(sp)
     9fe:	f822                	sd	s0,48(sp)
     a00:	f426                	sd	s1,40(sp)
     a02:	f04a                	sd	s2,32(sp)
     a04:	ec4e                	sd	s3,24(sp)
     a06:	e852                	sd	s4,16(sp)
     a08:	e456                	sd	s5,8(sp)
     a0a:	e05a                	sd	s6,0(sp)
     a0c:	0080                	addi	s0,sp,64
     a0e:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE|O_RDWR);
     a10:	20200593          	li	a1,514
     a14:	00006517          	auipc	a0,0x6
     a18:	a4c50513          	addi	a0,a0,-1460 # 6460 <malloc+0x45c>
     a1c:	00005097          	auipc	ra,0x5
     a20:	1ea080e7          	jalr	490(ra) # 5c06 <open>
  if(fd < 0){
     a24:	0a054d63          	bltz	a0,ade <writetest+0xe4>
     a28:	892a                	mv	s2,a0
     a2a:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     a2c:	00006997          	auipc	s3,0x6
     a30:	a5c98993          	addi	s3,s3,-1444 # 6488 <malloc+0x484>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     a34:	00006a97          	auipc	s5,0x6
     a38:	a8ca8a93          	addi	s5,s5,-1396 # 64c0 <malloc+0x4bc>
  for(i = 0; i < N; i++){
     a3c:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     a40:	4629                	li	a2,10
     a42:	85ce                	mv	a1,s3
     a44:	854a                	mv	a0,s2
     a46:	00005097          	auipc	ra,0x5
     a4a:	1a0080e7          	jalr	416(ra) # 5be6 <write>
     a4e:	47a9                	li	a5,10
     a50:	0af51563          	bne	a0,a5,afa <writetest+0x100>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     a54:	4629                	li	a2,10
     a56:	85d6                	mv	a1,s5
     a58:	854a                	mv	a0,s2
     a5a:	00005097          	auipc	ra,0x5
     a5e:	18c080e7          	jalr	396(ra) # 5be6 <write>
     a62:	47a9                	li	a5,10
     a64:	0af51a63          	bne	a0,a5,b18 <writetest+0x11e>
  for(i = 0; i < N; i++){
     a68:	2485                	addiw	s1,s1,1
     a6a:	fd449be3          	bne	s1,s4,a40 <writetest+0x46>
  close(fd);
     a6e:	854a                	mv	a0,s2
     a70:	00005097          	auipc	ra,0x5
     a74:	17e080e7          	jalr	382(ra) # 5bee <close>
  fd = open("small", O_RDONLY);
     a78:	4581                	li	a1,0
     a7a:	00006517          	auipc	a0,0x6
     a7e:	9e650513          	addi	a0,a0,-1562 # 6460 <malloc+0x45c>
     a82:	00005097          	auipc	ra,0x5
     a86:	184080e7          	jalr	388(ra) # 5c06 <open>
     a8a:	84aa                	mv	s1,a0
  if(fd < 0){
     a8c:	0a054563          	bltz	a0,b36 <writetest+0x13c>
  i = read(fd, buf, N*SZ*2);
     a90:	7d000613          	li	a2,2000
     a94:	0000c597          	auipc	a1,0xc
     a98:	1e458593          	addi	a1,a1,484 # cc78 <buf>
     a9c:	00005097          	auipc	ra,0x5
     aa0:	142080e7          	jalr	322(ra) # 5bde <read>
  if(i != N*SZ*2){
     aa4:	7d000793          	li	a5,2000
     aa8:	0af51563          	bne	a0,a5,b52 <writetest+0x158>
  close(fd);
     aac:	8526                	mv	a0,s1
     aae:	00005097          	auipc	ra,0x5
     ab2:	140080e7          	jalr	320(ra) # 5bee <close>
  if(unlink("small") < 0){
     ab6:	00006517          	auipc	a0,0x6
     aba:	9aa50513          	addi	a0,a0,-1622 # 6460 <malloc+0x45c>
     abe:	00005097          	auipc	ra,0x5
     ac2:	158080e7          	jalr	344(ra) # 5c16 <unlink>
     ac6:	0a054463          	bltz	a0,b6e <writetest+0x174>
}
     aca:	70e2                	ld	ra,56(sp)
     acc:	7442                	ld	s0,48(sp)
     ace:	74a2                	ld	s1,40(sp)
     ad0:	7902                	ld	s2,32(sp)
     ad2:	69e2                	ld	s3,24(sp)
     ad4:	6a42                	ld	s4,16(sp)
     ad6:	6aa2                	ld	s5,8(sp)
     ad8:	6b02                	ld	s6,0(sp)
     ada:	6121                	addi	sp,sp,64
     adc:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     ade:	85da                	mv	a1,s6
     ae0:	00006517          	auipc	a0,0x6
     ae4:	98850513          	addi	a0,a0,-1656 # 6468 <malloc+0x464>
     ae8:	00005097          	auipc	ra,0x5
     aec:	45e080e7          	jalr	1118(ra) # 5f46 <printf>
    exit(1);
     af0:	4505                	li	a0,1
     af2:	00005097          	auipc	ra,0x5
     af6:	0d4080e7          	jalr	212(ra) # 5bc6 <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
     afa:	8626                	mv	a2,s1
     afc:	85da                	mv	a1,s6
     afe:	00006517          	auipc	a0,0x6
     b02:	99a50513          	addi	a0,a0,-1638 # 6498 <malloc+0x494>
     b06:	00005097          	auipc	ra,0x5
     b0a:	440080e7          	jalr	1088(ra) # 5f46 <printf>
      exit(1);
     b0e:	4505                	li	a0,1
     b10:	00005097          	auipc	ra,0x5
     b14:	0b6080e7          	jalr	182(ra) # 5bc6 <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
     b18:	8626                	mv	a2,s1
     b1a:	85da                	mv	a1,s6
     b1c:	00006517          	auipc	a0,0x6
     b20:	9b450513          	addi	a0,a0,-1612 # 64d0 <malloc+0x4cc>
     b24:	00005097          	auipc	ra,0x5
     b28:	422080e7          	jalr	1058(ra) # 5f46 <printf>
      exit(1);
     b2c:	4505                	li	a0,1
     b2e:	00005097          	auipc	ra,0x5
     b32:	098080e7          	jalr	152(ra) # 5bc6 <exit>
    printf("%s: error: open small failed!\n", s);
     b36:	85da                	mv	a1,s6
     b38:	00006517          	auipc	a0,0x6
     b3c:	9c050513          	addi	a0,a0,-1600 # 64f8 <malloc+0x4f4>
     b40:	00005097          	auipc	ra,0x5
     b44:	406080e7          	jalr	1030(ra) # 5f46 <printf>
    exit(1);
     b48:	4505                	li	a0,1
     b4a:	00005097          	auipc	ra,0x5
     b4e:	07c080e7          	jalr	124(ra) # 5bc6 <exit>
    printf("%s: read failed\n", s);
     b52:	85da                	mv	a1,s6
     b54:	00006517          	auipc	a0,0x6
     b58:	9c450513          	addi	a0,a0,-1596 # 6518 <malloc+0x514>
     b5c:	00005097          	auipc	ra,0x5
     b60:	3ea080e7          	jalr	1002(ra) # 5f46 <printf>
    exit(1);
     b64:	4505                	li	a0,1
     b66:	00005097          	auipc	ra,0x5
     b6a:	060080e7          	jalr	96(ra) # 5bc6 <exit>
    printf("%s: unlink small failed\n", s);
     b6e:	85da                	mv	a1,s6
     b70:	00006517          	auipc	a0,0x6
     b74:	9c050513          	addi	a0,a0,-1600 # 6530 <malloc+0x52c>
     b78:	00005097          	auipc	ra,0x5
     b7c:	3ce080e7          	jalr	974(ra) # 5f46 <printf>
    exit(1);
     b80:	4505                	li	a0,1
     b82:	00005097          	auipc	ra,0x5
     b86:	044080e7          	jalr	68(ra) # 5bc6 <exit>

0000000000000b8a <writebig>:
{
     b8a:	7139                	addi	sp,sp,-64
     b8c:	fc06                	sd	ra,56(sp)
     b8e:	f822                	sd	s0,48(sp)
     b90:	f426                	sd	s1,40(sp)
     b92:	f04a                	sd	s2,32(sp)
     b94:	ec4e                	sd	s3,24(sp)
     b96:	e852                	sd	s4,16(sp)
     b98:	e456                	sd	s5,8(sp)
     b9a:	0080                	addi	s0,sp,64
     b9c:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE|O_RDWR);
     b9e:	20200593          	li	a1,514
     ba2:	00006517          	auipc	a0,0x6
     ba6:	9ae50513          	addi	a0,a0,-1618 # 6550 <malloc+0x54c>
     baa:	00005097          	auipc	ra,0x5
     bae:	05c080e7          	jalr	92(ra) # 5c06 <open>
     bb2:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
     bb4:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     bb6:	0000c917          	auipc	s2,0xc
     bba:	0c290913          	addi	s2,s2,194 # cc78 <buf>
  for(i = 0; i < MAXFILE; i++){
     bbe:	10c00a13          	li	s4,268
  if(fd < 0){
     bc2:	06054c63          	bltz	a0,c3a <writebig+0xb0>
    ((int*)buf)[0] = i;
     bc6:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
     bca:	40000613          	li	a2,1024
     bce:	85ca                	mv	a1,s2
     bd0:	854e                	mv	a0,s3
     bd2:	00005097          	auipc	ra,0x5
     bd6:	014080e7          	jalr	20(ra) # 5be6 <write>
     bda:	40000793          	li	a5,1024
     bde:	06f51c63          	bne	a0,a5,c56 <writebig+0xcc>
  for(i = 0; i < MAXFILE; i++){
     be2:	2485                	addiw	s1,s1,1
     be4:	ff4491e3          	bne	s1,s4,bc6 <writebig+0x3c>
  close(fd);
     be8:	854e                	mv	a0,s3
     bea:	00005097          	auipc	ra,0x5
     bee:	004080e7          	jalr	4(ra) # 5bee <close>
  fd = open("big", O_RDONLY);
     bf2:	4581                	li	a1,0
     bf4:	00006517          	auipc	a0,0x6
     bf8:	95c50513          	addi	a0,a0,-1700 # 6550 <malloc+0x54c>
     bfc:	00005097          	auipc	ra,0x5
     c00:	00a080e7          	jalr	10(ra) # 5c06 <open>
     c04:	89aa                	mv	s3,a0
  n = 0;
     c06:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     c08:	0000c917          	auipc	s2,0xc
     c0c:	07090913          	addi	s2,s2,112 # cc78 <buf>
  if(fd < 0){
     c10:	06054263          	bltz	a0,c74 <writebig+0xea>
    i = read(fd, buf, BSIZE);
     c14:	40000613          	li	a2,1024
     c18:	85ca                	mv	a1,s2
     c1a:	854e                	mv	a0,s3
     c1c:	00005097          	auipc	ra,0x5
     c20:	fc2080e7          	jalr	-62(ra) # 5bde <read>
    if(i == 0){
     c24:	c535                	beqz	a0,c90 <writebig+0x106>
    } else if(i != BSIZE){
     c26:	40000793          	li	a5,1024
     c2a:	0af51f63          	bne	a0,a5,ce8 <writebig+0x15e>
    if(((int*)buf)[0] != n){
     c2e:	00092683          	lw	a3,0(s2)
     c32:	0c969a63          	bne	a3,s1,d06 <writebig+0x17c>
    n++;
     c36:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     c38:	bff1                	j	c14 <writebig+0x8a>
    printf("%s: error: creat big failed!\n", s);
     c3a:	85d6                	mv	a1,s5
     c3c:	00006517          	auipc	a0,0x6
     c40:	91c50513          	addi	a0,a0,-1764 # 6558 <malloc+0x554>
     c44:	00005097          	auipc	ra,0x5
     c48:	302080e7          	jalr	770(ra) # 5f46 <printf>
    exit(1);
     c4c:	4505                	li	a0,1
     c4e:	00005097          	auipc	ra,0x5
     c52:	f78080e7          	jalr	-136(ra) # 5bc6 <exit>
      printf("%s: error: write big file failed\n", s, i);
     c56:	8626                	mv	a2,s1
     c58:	85d6                	mv	a1,s5
     c5a:	00006517          	auipc	a0,0x6
     c5e:	91e50513          	addi	a0,a0,-1762 # 6578 <malloc+0x574>
     c62:	00005097          	auipc	ra,0x5
     c66:	2e4080e7          	jalr	740(ra) # 5f46 <printf>
      exit(1);
     c6a:	4505                	li	a0,1
     c6c:	00005097          	auipc	ra,0x5
     c70:	f5a080e7          	jalr	-166(ra) # 5bc6 <exit>
    printf("%s: error: open big failed!\n", s);
     c74:	85d6                	mv	a1,s5
     c76:	00006517          	auipc	a0,0x6
     c7a:	92a50513          	addi	a0,a0,-1750 # 65a0 <malloc+0x59c>
     c7e:	00005097          	auipc	ra,0x5
     c82:	2c8080e7          	jalr	712(ra) # 5f46 <printf>
    exit(1);
     c86:	4505                	li	a0,1
     c88:	00005097          	auipc	ra,0x5
     c8c:	f3e080e7          	jalr	-194(ra) # 5bc6 <exit>
      if(n == MAXFILE - 1){
     c90:	10b00793          	li	a5,267
     c94:	02f48a63          	beq	s1,a5,cc8 <writebig+0x13e>
  close(fd);
     c98:	854e                	mv	a0,s3
     c9a:	00005097          	auipc	ra,0x5
     c9e:	f54080e7          	jalr	-172(ra) # 5bee <close>
  if(unlink("big") < 0){
     ca2:	00006517          	auipc	a0,0x6
     ca6:	8ae50513          	addi	a0,a0,-1874 # 6550 <malloc+0x54c>
     caa:	00005097          	auipc	ra,0x5
     cae:	f6c080e7          	jalr	-148(ra) # 5c16 <unlink>
     cb2:	06054963          	bltz	a0,d24 <writebig+0x19a>
}
     cb6:	70e2                	ld	ra,56(sp)
     cb8:	7442                	ld	s0,48(sp)
     cba:	74a2                	ld	s1,40(sp)
     cbc:	7902                	ld	s2,32(sp)
     cbe:	69e2                	ld	s3,24(sp)
     cc0:	6a42                	ld	s4,16(sp)
     cc2:	6aa2                	ld	s5,8(sp)
     cc4:	6121                	addi	sp,sp,64
     cc6:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
     cc8:	10b00613          	li	a2,267
     ccc:	85d6                	mv	a1,s5
     cce:	00006517          	auipc	a0,0x6
     cd2:	8f250513          	addi	a0,a0,-1806 # 65c0 <malloc+0x5bc>
     cd6:	00005097          	auipc	ra,0x5
     cda:	270080e7          	jalr	624(ra) # 5f46 <printf>
        exit(1);
     cde:	4505                	li	a0,1
     ce0:	00005097          	auipc	ra,0x5
     ce4:	ee6080e7          	jalr	-282(ra) # 5bc6 <exit>
      printf("%s: read failed %d\n", s, i);
     ce8:	862a                	mv	a2,a0
     cea:	85d6                	mv	a1,s5
     cec:	00006517          	auipc	a0,0x6
     cf0:	8fc50513          	addi	a0,a0,-1796 # 65e8 <malloc+0x5e4>
     cf4:	00005097          	auipc	ra,0x5
     cf8:	252080e7          	jalr	594(ra) # 5f46 <printf>
      exit(1);
     cfc:	4505                	li	a0,1
     cfe:	00005097          	auipc	ra,0x5
     d02:	ec8080e7          	jalr	-312(ra) # 5bc6 <exit>
      printf("%s: read content of block %d is %d\n", s,
     d06:	8626                	mv	a2,s1
     d08:	85d6                	mv	a1,s5
     d0a:	00006517          	auipc	a0,0x6
     d0e:	8f650513          	addi	a0,a0,-1802 # 6600 <malloc+0x5fc>
     d12:	00005097          	auipc	ra,0x5
     d16:	234080e7          	jalr	564(ra) # 5f46 <printf>
      exit(1);
     d1a:	4505                	li	a0,1
     d1c:	00005097          	auipc	ra,0x5
     d20:	eaa080e7          	jalr	-342(ra) # 5bc6 <exit>
    printf("%s: unlink big failed\n", s);
     d24:	85d6                	mv	a1,s5
     d26:	00006517          	auipc	a0,0x6
     d2a:	90250513          	addi	a0,a0,-1790 # 6628 <malloc+0x624>
     d2e:	00005097          	auipc	ra,0x5
     d32:	218080e7          	jalr	536(ra) # 5f46 <printf>
    exit(1);
     d36:	4505                	li	a0,1
     d38:	00005097          	auipc	ra,0x5
     d3c:	e8e080e7          	jalr	-370(ra) # 5bc6 <exit>

0000000000000d40 <unlinkread>:
{
     d40:	7179                	addi	sp,sp,-48
     d42:	f406                	sd	ra,40(sp)
     d44:	f022                	sd	s0,32(sp)
     d46:	ec26                	sd	s1,24(sp)
     d48:	e84a                	sd	s2,16(sp)
     d4a:	e44e                	sd	s3,8(sp)
     d4c:	1800                	addi	s0,sp,48
     d4e:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     d50:	20200593          	li	a1,514
     d54:	00006517          	auipc	a0,0x6
     d58:	8ec50513          	addi	a0,a0,-1812 # 6640 <malloc+0x63c>
     d5c:	00005097          	auipc	ra,0x5
     d60:	eaa080e7          	jalr	-342(ra) # 5c06 <open>
  if(fd < 0){
     d64:	0e054563          	bltz	a0,e4e <unlinkread+0x10e>
     d68:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     d6a:	4615                	li	a2,5
     d6c:	00006597          	auipc	a1,0x6
     d70:	90458593          	addi	a1,a1,-1788 # 6670 <malloc+0x66c>
     d74:	00005097          	auipc	ra,0x5
     d78:	e72080e7          	jalr	-398(ra) # 5be6 <write>
  close(fd);
     d7c:	8526                	mv	a0,s1
     d7e:	00005097          	auipc	ra,0x5
     d82:	e70080e7          	jalr	-400(ra) # 5bee <close>
  fd = open("unlinkread", O_RDWR);
     d86:	4589                	li	a1,2
     d88:	00006517          	auipc	a0,0x6
     d8c:	8b850513          	addi	a0,a0,-1864 # 6640 <malloc+0x63c>
     d90:	00005097          	auipc	ra,0x5
     d94:	e76080e7          	jalr	-394(ra) # 5c06 <open>
     d98:	84aa                	mv	s1,a0
  if(fd < 0){
     d9a:	0c054863          	bltz	a0,e6a <unlinkread+0x12a>
  if(unlink("unlinkread") != 0){
     d9e:	00006517          	auipc	a0,0x6
     da2:	8a250513          	addi	a0,a0,-1886 # 6640 <malloc+0x63c>
     da6:	00005097          	auipc	ra,0x5
     daa:	e70080e7          	jalr	-400(ra) # 5c16 <unlink>
     dae:	ed61                	bnez	a0,e86 <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     db0:	20200593          	li	a1,514
     db4:	00006517          	auipc	a0,0x6
     db8:	88c50513          	addi	a0,a0,-1908 # 6640 <malloc+0x63c>
     dbc:	00005097          	auipc	ra,0x5
     dc0:	e4a080e7          	jalr	-438(ra) # 5c06 <open>
     dc4:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     dc6:	460d                	li	a2,3
     dc8:	00006597          	auipc	a1,0x6
     dcc:	8f058593          	addi	a1,a1,-1808 # 66b8 <malloc+0x6b4>
     dd0:	00005097          	auipc	ra,0x5
     dd4:	e16080e7          	jalr	-490(ra) # 5be6 <write>
  close(fd1);
     dd8:	854a                	mv	a0,s2
     dda:	00005097          	auipc	ra,0x5
     dde:	e14080e7          	jalr	-492(ra) # 5bee <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
     de2:	660d                	lui	a2,0x3
     de4:	0000c597          	auipc	a1,0xc
     de8:	e9458593          	addi	a1,a1,-364 # cc78 <buf>
     dec:	8526                	mv	a0,s1
     dee:	00005097          	auipc	ra,0x5
     df2:	df0080e7          	jalr	-528(ra) # 5bde <read>
     df6:	4795                	li	a5,5
     df8:	0af51563          	bne	a0,a5,ea2 <unlinkread+0x162>
  if(buf[0] != 'h'){
     dfc:	0000c717          	auipc	a4,0xc
     e00:	e7c74703          	lbu	a4,-388(a4) # cc78 <buf>
     e04:	06800793          	li	a5,104
     e08:	0af71b63          	bne	a4,a5,ebe <unlinkread+0x17e>
  if(write(fd, buf, 10) != 10){
     e0c:	4629                	li	a2,10
     e0e:	0000c597          	auipc	a1,0xc
     e12:	e6a58593          	addi	a1,a1,-406 # cc78 <buf>
     e16:	8526                	mv	a0,s1
     e18:	00005097          	auipc	ra,0x5
     e1c:	dce080e7          	jalr	-562(ra) # 5be6 <write>
     e20:	47a9                	li	a5,10
     e22:	0af51c63          	bne	a0,a5,eda <unlinkread+0x19a>
  close(fd);
     e26:	8526                	mv	a0,s1
     e28:	00005097          	auipc	ra,0x5
     e2c:	dc6080e7          	jalr	-570(ra) # 5bee <close>
  unlink("unlinkread");
     e30:	00006517          	auipc	a0,0x6
     e34:	81050513          	addi	a0,a0,-2032 # 6640 <malloc+0x63c>
     e38:	00005097          	auipc	ra,0x5
     e3c:	dde080e7          	jalr	-546(ra) # 5c16 <unlink>
}
     e40:	70a2                	ld	ra,40(sp)
     e42:	7402                	ld	s0,32(sp)
     e44:	64e2                	ld	s1,24(sp)
     e46:	6942                	ld	s2,16(sp)
     e48:	69a2                	ld	s3,8(sp)
     e4a:	6145                	addi	sp,sp,48
     e4c:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     e4e:	85ce                	mv	a1,s3
     e50:	00006517          	auipc	a0,0x6
     e54:	80050513          	addi	a0,a0,-2048 # 6650 <malloc+0x64c>
     e58:	00005097          	auipc	ra,0x5
     e5c:	0ee080e7          	jalr	238(ra) # 5f46 <printf>
    exit(1);
     e60:	4505                	li	a0,1
     e62:	00005097          	auipc	ra,0x5
     e66:	d64080e7          	jalr	-668(ra) # 5bc6 <exit>
    printf("%s: open unlinkread failed\n", s);
     e6a:	85ce                	mv	a1,s3
     e6c:	00006517          	auipc	a0,0x6
     e70:	80c50513          	addi	a0,a0,-2036 # 6678 <malloc+0x674>
     e74:	00005097          	auipc	ra,0x5
     e78:	0d2080e7          	jalr	210(ra) # 5f46 <printf>
    exit(1);
     e7c:	4505                	li	a0,1
     e7e:	00005097          	auipc	ra,0x5
     e82:	d48080e7          	jalr	-696(ra) # 5bc6 <exit>
    printf("%s: unlink unlinkread failed\n", s);
     e86:	85ce                	mv	a1,s3
     e88:	00006517          	auipc	a0,0x6
     e8c:	81050513          	addi	a0,a0,-2032 # 6698 <malloc+0x694>
     e90:	00005097          	auipc	ra,0x5
     e94:	0b6080e7          	jalr	182(ra) # 5f46 <printf>
    exit(1);
     e98:	4505                	li	a0,1
     e9a:	00005097          	auipc	ra,0x5
     e9e:	d2c080e7          	jalr	-724(ra) # 5bc6 <exit>
    printf("%s: unlinkread read failed", s);
     ea2:	85ce                	mv	a1,s3
     ea4:	00006517          	auipc	a0,0x6
     ea8:	81c50513          	addi	a0,a0,-2020 # 66c0 <malloc+0x6bc>
     eac:	00005097          	auipc	ra,0x5
     eb0:	09a080e7          	jalr	154(ra) # 5f46 <printf>
    exit(1);
     eb4:	4505                	li	a0,1
     eb6:	00005097          	auipc	ra,0x5
     eba:	d10080e7          	jalr	-752(ra) # 5bc6 <exit>
    printf("%s: unlinkread wrong data\n", s);
     ebe:	85ce                	mv	a1,s3
     ec0:	00006517          	auipc	a0,0x6
     ec4:	82050513          	addi	a0,a0,-2016 # 66e0 <malloc+0x6dc>
     ec8:	00005097          	auipc	ra,0x5
     ecc:	07e080e7          	jalr	126(ra) # 5f46 <printf>
    exit(1);
     ed0:	4505                	li	a0,1
     ed2:	00005097          	auipc	ra,0x5
     ed6:	cf4080e7          	jalr	-780(ra) # 5bc6 <exit>
    printf("%s: unlinkread write failed\n", s);
     eda:	85ce                	mv	a1,s3
     edc:	00006517          	auipc	a0,0x6
     ee0:	82450513          	addi	a0,a0,-2012 # 6700 <malloc+0x6fc>
     ee4:	00005097          	auipc	ra,0x5
     ee8:	062080e7          	jalr	98(ra) # 5f46 <printf>
    exit(1);
     eec:	4505                	li	a0,1
     eee:	00005097          	auipc	ra,0x5
     ef2:	cd8080e7          	jalr	-808(ra) # 5bc6 <exit>

0000000000000ef6 <linktest>:
{
     ef6:	1101                	addi	sp,sp,-32
     ef8:	ec06                	sd	ra,24(sp)
     efa:	e822                	sd	s0,16(sp)
     efc:	e426                	sd	s1,8(sp)
     efe:	e04a                	sd	s2,0(sp)
     f00:	1000                	addi	s0,sp,32
     f02:	892a                	mv	s2,a0
  unlink("lf1");
     f04:	00006517          	auipc	a0,0x6
     f08:	81c50513          	addi	a0,a0,-2020 # 6720 <malloc+0x71c>
     f0c:	00005097          	auipc	ra,0x5
     f10:	d0a080e7          	jalr	-758(ra) # 5c16 <unlink>
  unlink("lf2");
     f14:	00006517          	auipc	a0,0x6
     f18:	81450513          	addi	a0,a0,-2028 # 6728 <malloc+0x724>
     f1c:	00005097          	auipc	ra,0x5
     f20:	cfa080e7          	jalr	-774(ra) # 5c16 <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
     f24:	20200593          	li	a1,514
     f28:	00005517          	auipc	a0,0x5
     f2c:	7f850513          	addi	a0,a0,2040 # 6720 <malloc+0x71c>
     f30:	00005097          	auipc	ra,0x5
     f34:	cd6080e7          	jalr	-810(ra) # 5c06 <open>
  if(fd < 0){
     f38:	10054763          	bltz	a0,1046 <linktest+0x150>
     f3c:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
     f3e:	4615                	li	a2,5
     f40:	00005597          	auipc	a1,0x5
     f44:	73058593          	addi	a1,a1,1840 # 6670 <malloc+0x66c>
     f48:	00005097          	auipc	ra,0x5
     f4c:	c9e080e7          	jalr	-866(ra) # 5be6 <write>
     f50:	4795                	li	a5,5
     f52:	10f51863          	bne	a0,a5,1062 <linktest+0x16c>
  close(fd);
     f56:	8526                	mv	a0,s1
     f58:	00005097          	auipc	ra,0x5
     f5c:	c96080e7          	jalr	-874(ra) # 5bee <close>
  if(link("lf1", "lf2") < 0){
     f60:	00005597          	auipc	a1,0x5
     f64:	7c858593          	addi	a1,a1,1992 # 6728 <malloc+0x724>
     f68:	00005517          	auipc	a0,0x5
     f6c:	7b850513          	addi	a0,a0,1976 # 6720 <malloc+0x71c>
     f70:	00005097          	auipc	ra,0x5
     f74:	cb6080e7          	jalr	-842(ra) # 5c26 <link>
     f78:	10054363          	bltz	a0,107e <linktest+0x188>
  unlink("lf1");
     f7c:	00005517          	auipc	a0,0x5
     f80:	7a450513          	addi	a0,a0,1956 # 6720 <malloc+0x71c>
     f84:	00005097          	auipc	ra,0x5
     f88:	c92080e7          	jalr	-878(ra) # 5c16 <unlink>
  if(open("lf1", 0) >= 0){
     f8c:	4581                	li	a1,0
     f8e:	00005517          	auipc	a0,0x5
     f92:	79250513          	addi	a0,a0,1938 # 6720 <malloc+0x71c>
     f96:	00005097          	auipc	ra,0x5
     f9a:	c70080e7          	jalr	-912(ra) # 5c06 <open>
     f9e:	0e055e63          	bgez	a0,109a <linktest+0x1a4>
  fd = open("lf2", 0);
     fa2:	4581                	li	a1,0
     fa4:	00005517          	auipc	a0,0x5
     fa8:	78450513          	addi	a0,a0,1924 # 6728 <malloc+0x724>
     fac:	00005097          	auipc	ra,0x5
     fb0:	c5a080e7          	jalr	-934(ra) # 5c06 <open>
     fb4:	84aa                	mv	s1,a0
  if(fd < 0){
     fb6:	10054063          	bltz	a0,10b6 <linktest+0x1c0>
  if(read(fd, buf, sizeof(buf)) != SZ){
     fba:	660d                	lui	a2,0x3
     fbc:	0000c597          	auipc	a1,0xc
     fc0:	cbc58593          	addi	a1,a1,-836 # cc78 <buf>
     fc4:	00005097          	auipc	ra,0x5
     fc8:	c1a080e7          	jalr	-998(ra) # 5bde <read>
     fcc:	4795                	li	a5,5
     fce:	10f51263          	bne	a0,a5,10d2 <linktest+0x1dc>
  close(fd);
     fd2:	8526                	mv	a0,s1
     fd4:	00005097          	auipc	ra,0x5
     fd8:	c1a080e7          	jalr	-998(ra) # 5bee <close>
  if(link("lf2", "lf2") >= 0){
     fdc:	00005597          	auipc	a1,0x5
     fe0:	74c58593          	addi	a1,a1,1868 # 6728 <malloc+0x724>
     fe4:	852e                	mv	a0,a1
     fe6:	00005097          	auipc	ra,0x5
     fea:	c40080e7          	jalr	-960(ra) # 5c26 <link>
     fee:	10055063          	bgez	a0,10ee <linktest+0x1f8>
  unlink("lf2");
     ff2:	00005517          	auipc	a0,0x5
     ff6:	73650513          	addi	a0,a0,1846 # 6728 <malloc+0x724>
     ffa:	00005097          	auipc	ra,0x5
     ffe:	c1c080e7          	jalr	-996(ra) # 5c16 <unlink>
  if(link("lf2", "lf1") >= 0){
    1002:	00005597          	auipc	a1,0x5
    1006:	71e58593          	addi	a1,a1,1822 # 6720 <malloc+0x71c>
    100a:	00005517          	auipc	a0,0x5
    100e:	71e50513          	addi	a0,a0,1822 # 6728 <malloc+0x724>
    1012:	00005097          	auipc	ra,0x5
    1016:	c14080e7          	jalr	-1004(ra) # 5c26 <link>
    101a:	0e055863          	bgez	a0,110a <linktest+0x214>
  if(link(".", "lf1") >= 0){
    101e:	00005597          	auipc	a1,0x5
    1022:	70258593          	addi	a1,a1,1794 # 6720 <malloc+0x71c>
    1026:	00006517          	auipc	a0,0x6
    102a:	80a50513          	addi	a0,a0,-2038 # 6830 <malloc+0x82c>
    102e:	00005097          	auipc	ra,0x5
    1032:	bf8080e7          	jalr	-1032(ra) # 5c26 <link>
    1036:	0e055863          	bgez	a0,1126 <linktest+0x230>
}
    103a:	60e2                	ld	ra,24(sp)
    103c:	6442                	ld	s0,16(sp)
    103e:	64a2                	ld	s1,8(sp)
    1040:	6902                	ld	s2,0(sp)
    1042:	6105                	addi	sp,sp,32
    1044:	8082                	ret
    printf("%s: create lf1 failed\n", s);
    1046:	85ca                	mv	a1,s2
    1048:	00005517          	auipc	a0,0x5
    104c:	6e850513          	addi	a0,a0,1768 # 6730 <malloc+0x72c>
    1050:	00005097          	auipc	ra,0x5
    1054:	ef6080e7          	jalr	-266(ra) # 5f46 <printf>
    exit(1);
    1058:	4505                	li	a0,1
    105a:	00005097          	auipc	ra,0x5
    105e:	b6c080e7          	jalr	-1172(ra) # 5bc6 <exit>
    printf("%s: write lf1 failed\n", s);
    1062:	85ca                	mv	a1,s2
    1064:	00005517          	auipc	a0,0x5
    1068:	6e450513          	addi	a0,a0,1764 # 6748 <malloc+0x744>
    106c:	00005097          	auipc	ra,0x5
    1070:	eda080e7          	jalr	-294(ra) # 5f46 <printf>
    exit(1);
    1074:	4505                	li	a0,1
    1076:	00005097          	auipc	ra,0x5
    107a:	b50080e7          	jalr	-1200(ra) # 5bc6 <exit>
    printf("%s: link lf1 lf2 failed\n", s);
    107e:	85ca                	mv	a1,s2
    1080:	00005517          	auipc	a0,0x5
    1084:	6e050513          	addi	a0,a0,1760 # 6760 <malloc+0x75c>
    1088:	00005097          	auipc	ra,0x5
    108c:	ebe080e7          	jalr	-322(ra) # 5f46 <printf>
    exit(1);
    1090:	4505                	li	a0,1
    1092:	00005097          	auipc	ra,0x5
    1096:	b34080e7          	jalr	-1228(ra) # 5bc6 <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
    109a:	85ca                	mv	a1,s2
    109c:	00005517          	auipc	a0,0x5
    10a0:	6e450513          	addi	a0,a0,1764 # 6780 <malloc+0x77c>
    10a4:	00005097          	auipc	ra,0x5
    10a8:	ea2080e7          	jalr	-350(ra) # 5f46 <printf>
    exit(1);
    10ac:	4505                	li	a0,1
    10ae:	00005097          	auipc	ra,0x5
    10b2:	b18080e7          	jalr	-1256(ra) # 5bc6 <exit>
    printf("%s: open lf2 failed\n", s);
    10b6:	85ca                	mv	a1,s2
    10b8:	00005517          	auipc	a0,0x5
    10bc:	6f850513          	addi	a0,a0,1784 # 67b0 <malloc+0x7ac>
    10c0:	00005097          	auipc	ra,0x5
    10c4:	e86080e7          	jalr	-378(ra) # 5f46 <printf>
    exit(1);
    10c8:	4505                	li	a0,1
    10ca:	00005097          	auipc	ra,0x5
    10ce:	afc080e7          	jalr	-1284(ra) # 5bc6 <exit>
    printf("%s: read lf2 failed\n", s);
    10d2:	85ca                	mv	a1,s2
    10d4:	00005517          	auipc	a0,0x5
    10d8:	6f450513          	addi	a0,a0,1780 # 67c8 <malloc+0x7c4>
    10dc:	00005097          	auipc	ra,0x5
    10e0:	e6a080e7          	jalr	-406(ra) # 5f46 <printf>
    exit(1);
    10e4:	4505                	li	a0,1
    10e6:	00005097          	auipc	ra,0x5
    10ea:	ae0080e7          	jalr	-1312(ra) # 5bc6 <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
    10ee:	85ca                	mv	a1,s2
    10f0:	00005517          	auipc	a0,0x5
    10f4:	6f050513          	addi	a0,a0,1776 # 67e0 <malloc+0x7dc>
    10f8:	00005097          	auipc	ra,0x5
    10fc:	e4e080e7          	jalr	-434(ra) # 5f46 <printf>
    exit(1);
    1100:	4505                	li	a0,1
    1102:	00005097          	auipc	ra,0x5
    1106:	ac4080e7          	jalr	-1340(ra) # 5bc6 <exit>
    printf("%s: link non-existent succeeded! oops\n", s);
    110a:	85ca                	mv	a1,s2
    110c:	00005517          	auipc	a0,0x5
    1110:	6fc50513          	addi	a0,a0,1788 # 6808 <malloc+0x804>
    1114:	00005097          	auipc	ra,0x5
    1118:	e32080e7          	jalr	-462(ra) # 5f46 <printf>
    exit(1);
    111c:	4505                	li	a0,1
    111e:	00005097          	auipc	ra,0x5
    1122:	aa8080e7          	jalr	-1368(ra) # 5bc6 <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
    1126:	85ca                	mv	a1,s2
    1128:	00005517          	auipc	a0,0x5
    112c:	71050513          	addi	a0,a0,1808 # 6838 <malloc+0x834>
    1130:	00005097          	auipc	ra,0x5
    1134:	e16080e7          	jalr	-490(ra) # 5f46 <printf>
    exit(1);
    1138:	4505                	li	a0,1
    113a:	00005097          	auipc	ra,0x5
    113e:	a8c080e7          	jalr	-1396(ra) # 5bc6 <exit>

0000000000001142 <validatetest>:
{
    1142:	7139                	addi	sp,sp,-64
    1144:	fc06                	sd	ra,56(sp)
    1146:	f822                	sd	s0,48(sp)
    1148:	f426                	sd	s1,40(sp)
    114a:	f04a                	sd	s2,32(sp)
    114c:	ec4e                	sd	s3,24(sp)
    114e:	e852                	sd	s4,16(sp)
    1150:	e456                	sd	s5,8(sp)
    1152:	e05a                	sd	s6,0(sp)
    1154:	0080                	addi	s0,sp,64
    1156:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    1158:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
    115a:	00005997          	auipc	s3,0x5
    115e:	6fe98993          	addi	s3,s3,1790 # 6858 <malloc+0x854>
    1162:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    1164:	6a85                	lui	s5,0x1
    1166:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
    116a:	85a6                	mv	a1,s1
    116c:	854e                	mv	a0,s3
    116e:	00005097          	auipc	ra,0x5
    1172:	ab8080e7          	jalr	-1352(ra) # 5c26 <link>
    1176:	01251f63          	bne	a0,s2,1194 <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    117a:	94d6                	add	s1,s1,s5
    117c:	ff4497e3          	bne	s1,s4,116a <validatetest+0x28>
}
    1180:	70e2                	ld	ra,56(sp)
    1182:	7442                	ld	s0,48(sp)
    1184:	74a2                	ld	s1,40(sp)
    1186:	7902                	ld	s2,32(sp)
    1188:	69e2                	ld	s3,24(sp)
    118a:	6a42                	ld	s4,16(sp)
    118c:	6aa2                	ld	s5,8(sp)
    118e:	6b02                	ld	s6,0(sp)
    1190:	6121                	addi	sp,sp,64
    1192:	8082                	ret
      printf("%s: link should not succeed\n", s);
    1194:	85da                	mv	a1,s6
    1196:	00005517          	auipc	a0,0x5
    119a:	6d250513          	addi	a0,a0,1746 # 6868 <malloc+0x864>
    119e:	00005097          	auipc	ra,0x5
    11a2:	da8080e7          	jalr	-600(ra) # 5f46 <printf>
      exit(1);
    11a6:	4505                	li	a0,1
    11a8:	00005097          	auipc	ra,0x5
    11ac:	a1e080e7          	jalr	-1506(ra) # 5bc6 <exit>

00000000000011b0 <bigdir>:
{
    11b0:	715d                	addi	sp,sp,-80
    11b2:	e486                	sd	ra,72(sp)
    11b4:	e0a2                	sd	s0,64(sp)
    11b6:	fc26                	sd	s1,56(sp)
    11b8:	f84a                	sd	s2,48(sp)
    11ba:	f44e                	sd	s3,40(sp)
    11bc:	f052                	sd	s4,32(sp)
    11be:	ec56                	sd	s5,24(sp)
    11c0:	e85a                	sd	s6,16(sp)
    11c2:	0880                	addi	s0,sp,80
    11c4:	89aa                	mv	s3,a0
  unlink("bd");
    11c6:	00005517          	auipc	a0,0x5
    11ca:	6c250513          	addi	a0,a0,1730 # 6888 <malloc+0x884>
    11ce:	00005097          	auipc	ra,0x5
    11d2:	a48080e7          	jalr	-1464(ra) # 5c16 <unlink>
  fd = open("bd", O_CREATE);
    11d6:	20000593          	li	a1,512
    11da:	00005517          	auipc	a0,0x5
    11de:	6ae50513          	addi	a0,a0,1710 # 6888 <malloc+0x884>
    11e2:	00005097          	auipc	ra,0x5
    11e6:	a24080e7          	jalr	-1500(ra) # 5c06 <open>
  if(fd < 0){
    11ea:	0c054963          	bltz	a0,12bc <bigdir+0x10c>
  close(fd);
    11ee:	00005097          	auipc	ra,0x5
    11f2:	a00080e7          	jalr	-1536(ra) # 5bee <close>
  for(i = 0; i < N; i++){
    11f6:	4901                	li	s2,0
    name[0] = 'x';
    11f8:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
    11fc:	00005a17          	auipc	s4,0x5
    1200:	68ca0a13          	addi	s4,s4,1676 # 6888 <malloc+0x884>
  for(i = 0; i < N; i++){
    1204:	1f400b13          	li	s6,500
    name[0] = 'x';
    1208:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
    120c:	41f9579b          	sraiw	a5,s2,0x1f
    1210:	01a7d71b          	srliw	a4,a5,0x1a
    1214:	012707bb          	addw	a5,a4,s2
    1218:	4067d69b          	sraiw	a3,a5,0x6
    121c:	0306869b          	addiw	a3,a3,48
    1220:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    1224:	03f7f793          	andi	a5,a5,63
    1228:	9f99                	subw	a5,a5,a4
    122a:	0307879b          	addiw	a5,a5,48
    122e:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    1232:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
    1236:	fb040593          	addi	a1,s0,-80
    123a:	8552                	mv	a0,s4
    123c:	00005097          	auipc	ra,0x5
    1240:	9ea080e7          	jalr	-1558(ra) # 5c26 <link>
    1244:	84aa                	mv	s1,a0
    1246:	e949                	bnez	a0,12d8 <bigdir+0x128>
  for(i = 0; i < N; i++){
    1248:	2905                	addiw	s2,s2,1
    124a:	fb691fe3          	bne	s2,s6,1208 <bigdir+0x58>
  unlink("bd");
    124e:	00005517          	auipc	a0,0x5
    1252:	63a50513          	addi	a0,a0,1594 # 6888 <malloc+0x884>
    1256:	00005097          	auipc	ra,0x5
    125a:	9c0080e7          	jalr	-1600(ra) # 5c16 <unlink>
    name[0] = 'x';
    125e:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
    1262:	1f400a13          	li	s4,500
    name[0] = 'x';
    1266:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    126a:	41f4d79b          	sraiw	a5,s1,0x1f
    126e:	01a7d71b          	srliw	a4,a5,0x1a
    1272:	009707bb          	addw	a5,a4,s1
    1276:	4067d69b          	sraiw	a3,a5,0x6
    127a:	0306869b          	addiw	a3,a3,48
    127e:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    1282:	03f7f793          	andi	a5,a5,63
    1286:	9f99                	subw	a5,a5,a4
    1288:	0307879b          	addiw	a5,a5,48
    128c:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    1290:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
    1294:	fb040513          	addi	a0,s0,-80
    1298:	00005097          	auipc	ra,0x5
    129c:	97e080e7          	jalr	-1666(ra) # 5c16 <unlink>
    12a0:	ed21                	bnez	a0,12f8 <bigdir+0x148>
  for(i = 0; i < N; i++){
    12a2:	2485                	addiw	s1,s1,1
    12a4:	fd4491e3          	bne	s1,s4,1266 <bigdir+0xb6>
}
    12a8:	60a6                	ld	ra,72(sp)
    12aa:	6406                	ld	s0,64(sp)
    12ac:	74e2                	ld	s1,56(sp)
    12ae:	7942                	ld	s2,48(sp)
    12b0:	79a2                	ld	s3,40(sp)
    12b2:	7a02                	ld	s4,32(sp)
    12b4:	6ae2                	ld	s5,24(sp)
    12b6:	6b42                	ld	s6,16(sp)
    12b8:	6161                	addi	sp,sp,80
    12ba:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    12bc:	85ce                	mv	a1,s3
    12be:	00005517          	auipc	a0,0x5
    12c2:	5d250513          	addi	a0,a0,1490 # 6890 <malloc+0x88c>
    12c6:	00005097          	auipc	ra,0x5
    12ca:	c80080e7          	jalr	-896(ra) # 5f46 <printf>
    exit(1);
    12ce:	4505                	li	a0,1
    12d0:	00005097          	auipc	ra,0x5
    12d4:	8f6080e7          	jalr	-1802(ra) # 5bc6 <exit>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
    12d8:	fb040613          	addi	a2,s0,-80
    12dc:	85ce                	mv	a1,s3
    12de:	00005517          	auipc	a0,0x5
    12e2:	5d250513          	addi	a0,a0,1490 # 68b0 <malloc+0x8ac>
    12e6:	00005097          	auipc	ra,0x5
    12ea:	c60080e7          	jalr	-928(ra) # 5f46 <printf>
      exit(1);
    12ee:	4505                	li	a0,1
    12f0:	00005097          	auipc	ra,0x5
    12f4:	8d6080e7          	jalr	-1834(ra) # 5bc6 <exit>
      printf("%s: bigdir unlink failed", s);
    12f8:	85ce                	mv	a1,s3
    12fa:	00005517          	auipc	a0,0x5
    12fe:	5d650513          	addi	a0,a0,1494 # 68d0 <malloc+0x8cc>
    1302:	00005097          	auipc	ra,0x5
    1306:	c44080e7          	jalr	-956(ra) # 5f46 <printf>
      exit(1);
    130a:	4505                	li	a0,1
    130c:	00005097          	auipc	ra,0x5
    1310:	8ba080e7          	jalr	-1862(ra) # 5bc6 <exit>

0000000000001314 <pgbug>:
{
    1314:	7179                	addi	sp,sp,-48
    1316:	f406                	sd	ra,40(sp)
    1318:	f022                	sd	s0,32(sp)
    131a:	ec26                	sd	s1,24(sp)
    131c:	1800                	addi	s0,sp,48
  argv[0] = 0;
    131e:	fc043c23          	sd	zero,-40(s0)
  exec(big, argv);
    1322:	00008497          	auipc	s1,0x8
    1326:	cde48493          	addi	s1,s1,-802 # 9000 <big>
    132a:	fd840593          	addi	a1,s0,-40
    132e:	6088                	ld	a0,0(s1)
    1330:	00005097          	auipc	ra,0x5
    1334:	8ce080e7          	jalr	-1842(ra) # 5bfe <exec>
  pipe(big);
    1338:	6088                	ld	a0,0(s1)
    133a:	00005097          	auipc	ra,0x5
    133e:	89c080e7          	jalr	-1892(ra) # 5bd6 <pipe>
  exit(0);
    1342:	4501                	li	a0,0
    1344:	00005097          	auipc	ra,0x5
    1348:	882080e7          	jalr	-1918(ra) # 5bc6 <exit>

000000000000134c <badarg>:
{
    134c:	7139                	addi	sp,sp,-64
    134e:	fc06                	sd	ra,56(sp)
    1350:	f822                	sd	s0,48(sp)
    1352:	f426                	sd	s1,40(sp)
    1354:	f04a                	sd	s2,32(sp)
    1356:	ec4e                	sd	s3,24(sp)
    1358:	0080                	addi	s0,sp,64
    135a:	64b1                	lui	s1,0xc
    135c:	35048493          	addi	s1,s1,848 # c350 <uninit+0x1de8>
    argv[0] = (char*)0xffffffff;
    1360:	597d                	li	s2,-1
    1362:	02095913          	srli	s2,s2,0x20
    exec("echo", argv);
    1366:	00005997          	auipc	s3,0x5
    136a:	de298993          	addi	s3,s3,-542 # 6148 <malloc+0x144>
    argv[0] = (char*)0xffffffff;
    136e:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    1372:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    1376:	fc040593          	addi	a1,s0,-64
    137a:	854e                	mv	a0,s3
    137c:	00005097          	auipc	ra,0x5
    1380:	882080e7          	jalr	-1918(ra) # 5bfe <exec>
  for(int i = 0; i < 50000; i++){
    1384:	34fd                	addiw	s1,s1,-1
    1386:	f4e5                	bnez	s1,136e <badarg+0x22>
  exit(0);
    1388:	4501                	li	a0,0
    138a:	00005097          	auipc	ra,0x5
    138e:	83c080e7          	jalr	-1988(ra) # 5bc6 <exit>

0000000000001392 <copyinstr2>:
{
    1392:	7155                	addi	sp,sp,-208
    1394:	e586                	sd	ra,200(sp)
    1396:	e1a2                	sd	s0,192(sp)
    1398:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    139a:	f6840793          	addi	a5,s0,-152
    139e:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    13a2:	07800713          	li	a4,120
    13a6:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    13aa:	0785                	addi	a5,a5,1
    13ac:	fed79de3          	bne	a5,a3,13a6 <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    13b0:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    13b4:	f6840513          	addi	a0,s0,-152
    13b8:	00005097          	auipc	ra,0x5
    13bc:	85e080e7          	jalr	-1954(ra) # 5c16 <unlink>
  if(ret != -1){
    13c0:	57fd                	li	a5,-1
    13c2:	0ef51063          	bne	a0,a5,14a2 <copyinstr2+0x110>
  int fd = open(b, O_CREATE | O_WRONLY);
    13c6:	20100593          	li	a1,513
    13ca:	f6840513          	addi	a0,s0,-152
    13ce:	00005097          	auipc	ra,0x5
    13d2:	838080e7          	jalr	-1992(ra) # 5c06 <open>
  if(fd != -1){
    13d6:	57fd                	li	a5,-1
    13d8:	0ef51563          	bne	a0,a5,14c2 <copyinstr2+0x130>
  ret = link(b, b);
    13dc:	f6840593          	addi	a1,s0,-152
    13e0:	852e                	mv	a0,a1
    13e2:	00005097          	auipc	ra,0x5
    13e6:	844080e7          	jalr	-1980(ra) # 5c26 <link>
  if(ret != -1){
    13ea:	57fd                	li	a5,-1
    13ec:	0ef51b63          	bne	a0,a5,14e2 <copyinstr2+0x150>
  char *args[] = { "xx", 0 };
    13f0:	00006797          	auipc	a5,0x6
    13f4:	73878793          	addi	a5,a5,1848 # 7b28 <malloc+0x1b24>
    13f8:	f4f43c23          	sd	a5,-168(s0)
    13fc:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    1400:	f5840593          	addi	a1,s0,-168
    1404:	f6840513          	addi	a0,s0,-152
    1408:	00004097          	auipc	ra,0x4
    140c:	7f6080e7          	jalr	2038(ra) # 5bfe <exec>
  if(ret != -1){
    1410:	57fd                	li	a5,-1
    1412:	0ef51963          	bne	a0,a5,1504 <copyinstr2+0x172>
  int pid = fork();
    1416:	00004097          	auipc	ra,0x4
    141a:	7a8080e7          	jalr	1960(ra) # 5bbe <fork>
  if(pid < 0){
    141e:	10054363          	bltz	a0,1524 <copyinstr2+0x192>
  if(pid == 0){
    1422:	12051463          	bnez	a0,154a <copyinstr2+0x1b8>
    1426:	00008797          	auipc	a5,0x8
    142a:	13a78793          	addi	a5,a5,314 # 9560 <big.0>
    142e:	00009697          	auipc	a3,0x9
    1432:	13268693          	addi	a3,a3,306 # a560 <big.0+0x1000>
      big[i] = 'x';
    1436:	07800713          	li	a4,120
    143a:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    143e:	0785                	addi	a5,a5,1
    1440:	fed79de3          	bne	a5,a3,143a <copyinstr2+0xa8>
    big[PGSIZE] = '\0';
    1444:	00009797          	auipc	a5,0x9
    1448:	10078e23          	sb	zero,284(a5) # a560 <big.0+0x1000>
    char *args2[] = { big, big, big, 0 };
    144c:	00007797          	auipc	a5,0x7
    1450:	0fc78793          	addi	a5,a5,252 # 8548 <malloc+0x2544>
    1454:	6390                	ld	a2,0(a5)
    1456:	6794                	ld	a3,8(a5)
    1458:	6b98                	ld	a4,16(a5)
    145a:	6f9c                	ld	a5,24(a5)
    145c:	f2c43823          	sd	a2,-208(s0)
    1460:	f2d43c23          	sd	a3,-200(s0)
    1464:	f4e43023          	sd	a4,-192(s0)
    1468:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    146c:	f3040593          	addi	a1,s0,-208
    1470:	00005517          	auipc	a0,0x5
    1474:	cd850513          	addi	a0,a0,-808 # 6148 <malloc+0x144>
    1478:	00004097          	auipc	ra,0x4
    147c:	786080e7          	jalr	1926(ra) # 5bfe <exec>
    if(ret != -1){
    1480:	57fd                	li	a5,-1
    1482:	0af50e63          	beq	a0,a5,153e <copyinstr2+0x1ac>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    1486:	55fd                	li	a1,-1
    1488:	00005517          	auipc	a0,0x5
    148c:	4f050513          	addi	a0,a0,1264 # 6978 <malloc+0x974>
    1490:	00005097          	auipc	ra,0x5
    1494:	ab6080e7          	jalr	-1354(ra) # 5f46 <printf>
      exit(1);
    1498:	4505                	li	a0,1
    149a:	00004097          	auipc	ra,0x4
    149e:	72c080e7          	jalr	1836(ra) # 5bc6 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    14a2:	862a                	mv	a2,a0
    14a4:	f6840593          	addi	a1,s0,-152
    14a8:	00005517          	auipc	a0,0x5
    14ac:	44850513          	addi	a0,a0,1096 # 68f0 <malloc+0x8ec>
    14b0:	00005097          	auipc	ra,0x5
    14b4:	a96080e7          	jalr	-1386(ra) # 5f46 <printf>
    exit(1);
    14b8:	4505                	li	a0,1
    14ba:	00004097          	auipc	ra,0x4
    14be:	70c080e7          	jalr	1804(ra) # 5bc6 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    14c2:	862a                	mv	a2,a0
    14c4:	f6840593          	addi	a1,s0,-152
    14c8:	00005517          	auipc	a0,0x5
    14cc:	44850513          	addi	a0,a0,1096 # 6910 <malloc+0x90c>
    14d0:	00005097          	auipc	ra,0x5
    14d4:	a76080e7          	jalr	-1418(ra) # 5f46 <printf>
    exit(1);
    14d8:	4505                	li	a0,1
    14da:	00004097          	auipc	ra,0x4
    14de:	6ec080e7          	jalr	1772(ra) # 5bc6 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    14e2:	86aa                	mv	a3,a0
    14e4:	f6840613          	addi	a2,s0,-152
    14e8:	85b2                	mv	a1,a2
    14ea:	00005517          	auipc	a0,0x5
    14ee:	44650513          	addi	a0,a0,1094 # 6930 <malloc+0x92c>
    14f2:	00005097          	auipc	ra,0x5
    14f6:	a54080e7          	jalr	-1452(ra) # 5f46 <printf>
    exit(1);
    14fa:	4505                	li	a0,1
    14fc:	00004097          	auipc	ra,0x4
    1500:	6ca080e7          	jalr	1738(ra) # 5bc6 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1504:	567d                	li	a2,-1
    1506:	f6840593          	addi	a1,s0,-152
    150a:	00005517          	auipc	a0,0x5
    150e:	44e50513          	addi	a0,a0,1102 # 6958 <malloc+0x954>
    1512:	00005097          	auipc	ra,0x5
    1516:	a34080e7          	jalr	-1484(ra) # 5f46 <printf>
    exit(1);
    151a:	4505                	li	a0,1
    151c:	00004097          	auipc	ra,0x4
    1520:	6aa080e7          	jalr	1706(ra) # 5bc6 <exit>
    printf("fork failed\n");
    1524:	00006517          	auipc	a0,0x6
    1528:	8b450513          	addi	a0,a0,-1868 # 6dd8 <malloc+0xdd4>
    152c:	00005097          	auipc	ra,0x5
    1530:	a1a080e7          	jalr	-1510(ra) # 5f46 <printf>
    exit(1);
    1534:	4505                	li	a0,1
    1536:	00004097          	auipc	ra,0x4
    153a:	690080e7          	jalr	1680(ra) # 5bc6 <exit>
    exit(747); // OK
    153e:	2eb00513          	li	a0,747
    1542:	00004097          	auipc	ra,0x4
    1546:	684080e7          	jalr	1668(ra) # 5bc6 <exit>
  int st = 0;
    154a:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    154e:	f5440513          	addi	a0,s0,-172
    1552:	00004097          	auipc	ra,0x4
    1556:	67c080e7          	jalr	1660(ra) # 5bce <wait>
  if(st != 747){
    155a:	f5442703          	lw	a4,-172(s0)
    155e:	2eb00793          	li	a5,747
    1562:	00f71663          	bne	a4,a5,156e <copyinstr2+0x1dc>
}
    1566:	60ae                	ld	ra,200(sp)
    1568:	640e                	ld	s0,192(sp)
    156a:	6169                	addi	sp,sp,208
    156c:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    156e:	00005517          	auipc	a0,0x5
    1572:	43250513          	addi	a0,a0,1074 # 69a0 <malloc+0x99c>
    1576:	00005097          	auipc	ra,0x5
    157a:	9d0080e7          	jalr	-1584(ra) # 5f46 <printf>
    exit(1);
    157e:	4505                	li	a0,1
    1580:	00004097          	auipc	ra,0x4
    1584:	646080e7          	jalr	1606(ra) # 5bc6 <exit>

0000000000001588 <truncate3>:
{
    1588:	7159                	addi	sp,sp,-112
    158a:	f486                	sd	ra,104(sp)
    158c:	f0a2                	sd	s0,96(sp)
    158e:	eca6                	sd	s1,88(sp)
    1590:	e8ca                	sd	s2,80(sp)
    1592:	e4ce                	sd	s3,72(sp)
    1594:	e0d2                	sd	s4,64(sp)
    1596:	fc56                	sd	s5,56(sp)
    1598:	1880                	addi	s0,sp,112
    159a:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
    159c:	60100593          	li	a1,1537
    15a0:	00005517          	auipc	a0,0x5
    15a4:	c0050513          	addi	a0,a0,-1024 # 61a0 <malloc+0x19c>
    15a8:	00004097          	auipc	ra,0x4
    15ac:	65e080e7          	jalr	1630(ra) # 5c06 <open>
    15b0:	00004097          	auipc	ra,0x4
    15b4:	63e080e7          	jalr	1598(ra) # 5bee <close>
  pid = fork();
    15b8:	00004097          	auipc	ra,0x4
    15bc:	606080e7          	jalr	1542(ra) # 5bbe <fork>
  if(pid < 0){
    15c0:	08054063          	bltz	a0,1640 <truncate3+0xb8>
  if(pid == 0){
    15c4:	e969                	bnez	a0,1696 <truncate3+0x10e>
    15c6:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
    15ca:	00005a17          	auipc	s4,0x5
    15ce:	bd6a0a13          	addi	s4,s4,-1066 # 61a0 <malloc+0x19c>
      int n = write(fd, "1234567890", 10);
    15d2:	00005a97          	auipc	s5,0x5
    15d6:	42ea8a93          	addi	s5,s5,1070 # 6a00 <malloc+0x9fc>
      int fd = open("truncfile", O_WRONLY);
    15da:	4585                	li	a1,1
    15dc:	8552                	mv	a0,s4
    15de:	00004097          	auipc	ra,0x4
    15e2:	628080e7          	jalr	1576(ra) # 5c06 <open>
    15e6:	84aa                	mv	s1,a0
      if(fd < 0){
    15e8:	06054a63          	bltz	a0,165c <truncate3+0xd4>
      int n = write(fd, "1234567890", 10);
    15ec:	4629                	li	a2,10
    15ee:	85d6                	mv	a1,s5
    15f0:	00004097          	auipc	ra,0x4
    15f4:	5f6080e7          	jalr	1526(ra) # 5be6 <write>
      if(n != 10){
    15f8:	47a9                	li	a5,10
    15fa:	06f51f63          	bne	a0,a5,1678 <truncate3+0xf0>
      close(fd);
    15fe:	8526                	mv	a0,s1
    1600:	00004097          	auipc	ra,0x4
    1604:	5ee080e7          	jalr	1518(ra) # 5bee <close>
      fd = open("truncfile", O_RDONLY);
    1608:	4581                	li	a1,0
    160a:	8552                	mv	a0,s4
    160c:	00004097          	auipc	ra,0x4
    1610:	5fa080e7          	jalr	1530(ra) # 5c06 <open>
    1614:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    1616:	02000613          	li	a2,32
    161a:	f9840593          	addi	a1,s0,-104
    161e:	00004097          	auipc	ra,0x4
    1622:	5c0080e7          	jalr	1472(ra) # 5bde <read>
      close(fd);
    1626:	8526                	mv	a0,s1
    1628:	00004097          	auipc	ra,0x4
    162c:	5c6080e7          	jalr	1478(ra) # 5bee <close>
    for(int i = 0; i < 100; i++){
    1630:	39fd                	addiw	s3,s3,-1
    1632:	fa0994e3          	bnez	s3,15da <truncate3+0x52>
    exit(0);
    1636:	4501                	li	a0,0
    1638:	00004097          	auipc	ra,0x4
    163c:	58e080e7          	jalr	1422(ra) # 5bc6 <exit>
    printf("%s: fork failed\n", s);
    1640:	85ca                	mv	a1,s2
    1642:	00005517          	auipc	a0,0x5
    1646:	38e50513          	addi	a0,a0,910 # 69d0 <malloc+0x9cc>
    164a:	00005097          	auipc	ra,0x5
    164e:	8fc080e7          	jalr	-1796(ra) # 5f46 <printf>
    exit(1);
    1652:	4505                	li	a0,1
    1654:	00004097          	auipc	ra,0x4
    1658:	572080e7          	jalr	1394(ra) # 5bc6 <exit>
        printf("%s: open failed\n", s);
    165c:	85ca                	mv	a1,s2
    165e:	00005517          	auipc	a0,0x5
    1662:	38a50513          	addi	a0,a0,906 # 69e8 <malloc+0x9e4>
    1666:	00005097          	auipc	ra,0x5
    166a:	8e0080e7          	jalr	-1824(ra) # 5f46 <printf>
        exit(1);
    166e:	4505                	li	a0,1
    1670:	00004097          	auipc	ra,0x4
    1674:	556080e7          	jalr	1366(ra) # 5bc6 <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    1678:	862a                	mv	a2,a0
    167a:	85ca                	mv	a1,s2
    167c:	00005517          	auipc	a0,0x5
    1680:	39450513          	addi	a0,a0,916 # 6a10 <malloc+0xa0c>
    1684:	00005097          	auipc	ra,0x5
    1688:	8c2080e7          	jalr	-1854(ra) # 5f46 <printf>
        exit(1);
    168c:	4505                	li	a0,1
    168e:	00004097          	auipc	ra,0x4
    1692:	538080e7          	jalr	1336(ra) # 5bc6 <exit>
    1696:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    169a:	00005a17          	auipc	s4,0x5
    169e:	b06a0a13          	addi	s4,s4,-1274 # 61a0 <malloc+0x19c>
    int n = write(fd, "xxx", 3);
    16a2:	00005a97          	auipc	s5,0x5
    16a6:	38ea8a93          	addi	s5,s5,910 # 6a30 <malloc+0xa2c>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    16aa:	60100593          	li	a1,1537
    16ae:	8552                	mv	a0,s4
    16b0:	00004097          	auipc	ra,0x4
    16b4:	556080e7          	jalr	1366(ra) # 5c06 <open>
    16b8:	84aa                	mv	s1,a0
    if(fd < 0){
    16ba:	04054763          	bltz	a0,1708 <truncate3+0x180>
    int n = write(fd, "xxx", 3);
    16be:	460d                	li	a2,3
    16c0:	85d6                	mv	a1,s5
    16c2:	00004097          	auipc	ra,0x4
    16c6:	524080e7          	jalr	1316(ra) # 5be6 <write>
    if(n != 3){
    16ca:	478d                	li	a5,3
    16cc:	04f51c63          	bne	a0,a5,1724 <truncate3+0x19c>
    close(fd);
    16d0:	8526                	mv	a0,s1
    16d2:	00004097          	auipc	ra,0x4
    16d6:	51c080e7          	jalr	1308(ra) # 5bee <close>
  for(int i = 0; i < 150; i++){
    16da:	39fd                	addiw	s3,s3,-1
    16dc:	fc0997e3          	bnez	s3,16aa <truncate3+0x122>
  wait(&xstatus);
    16e0:	fbc40513          	addi	a0,s0,-68
    16e4:	00004097          	auipc	ra,0x4
    16e8:	4ea080e7          	jalr	1258(ra) # 5bce <wait>
  unlink("truncfile");
    16ec:	00005517          	auipc	a0,0x5
    16f0:	ab450513          	addi	a0,a0,-1356 # 61a0 <malloc+0x19c>
    16f4:	00004097          	auipc	ra,0x4
    16f8:	522080e7          	jalr	1314(ra) # 5c16 <unlink>
  exit(xstatus);
    16fc:	fbc42503          	lw	a0,-68(s0)
    1700:	00004097          	auipc	ra,0x4
    1704:	4c6080e7          	jalr	1222(ra) # 5bc6 <exit>
      printf("%s: open failed\n", s);
    1708:	85ca                	mv	a1,s2
    170a:	00005517          	auipc	a0,0x5
    170e:	2de50513          	addi	a0,a0,734 # 69e8 <malloc+0x9e4>
    1712:	00005097          	auipc	ra,0x5
    1716:	834080e7          	jalr	-1996(ra) # 5f46 <printf>
      exit(1);
    171a:	4505                	li	a0,1
    171c:	00004097          	auipc	ra,0x4
    1720:	4aa080e7          	jalr	1194(ra) # 5bc6 <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    1724:	862a                	mv	a2,a0
    1726:	85ca                	mv	a1,s2
    1728:	00005517          	auipc	a0,0x5
    172c:	31050513          	addi	a0,a0,784 # 6a38 <malloc+0xa34>
    1730:	00005097          	auipc	ra,0x5
    1734:	816080e7          	jalr	-2026(ra) # 5f46 <printf>
      exit(1);
    1738:	4505                	li	a0,1
    173a:	00004097          	auipc	ra,0x4
    173e:	48c080e7          	jalr	1164(ra) # 5bc6 <exit>

0000000000001742 <exectest>:
{
    1742:	715d                	addi	sp,sp,-80
    1744:	e486                	sd	ra,72(sp)
    1746:	e0a2                	sd	s0,64(sp)
    1748:	fc26                	sd	s1,56(sp)
    174a:	f84a                	sd	s2,48(sp)
    174c:	0880                	addi	s0,sp,80
    174e:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    1750:	00005797          	auipc	a5,0x5
    1754:	9f878793          	addi	a5,a5,-1544 # 6148 <malloc+0x144>
    1758:	fcf43023          	sd	a5,-64(s0)
    175c:	00005797          	auipc	a5,0x5
    1760:	2fc78793          	addi	a5,a5,764 # 6a58 <malloc+0xa54>
    1764:	fcf43423          	sd	a5,-56(s0)
    1768:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    176c:	00005517          	auipc	a0,0x5
    1770:	2f450513          	addi	a0,a0,756 # 6a60 <malloc+0xa5c>
    1774:	00004097          	auipc	ra,0x4
    1778:	4a2080e7          	jalr	1186(ra) # 5c16 <unlink>
  pid = fork();
    177c:	00004097          	auipc	ra,0x4
    1780:	442080e7          	jalr	1090(ra) # 5bbe <fork>
  if(pid < 0) {
    1784:	04054663          	bltz	a0,17d0 <exectest+0x8e>
    1788:	84aa                	mv	s1,a0
  if(pid == 0) {
    178a:	e959                	bnez	a0,1820 <exectest+0xde>
    close(1);
    178c:	4505                	li	a0,1
    178e:	00004097          	auipc	ra,0x4
    1792:	460080e7          	jalr	1120(ra) # 5bee <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    1796:	20100593          	li	a1,513
    179a:	00005517          	auipc	a0,0x5
    179e:	2c650513          	addi	a0,a0,710 # 6a60 <malloc+0xa5c>
    17a2:	00004097          	auipc	ra,0x4
    17a6:	464080e7          	jalr	1124(ra) # 5c06 <open>
    if(fd < 0) {
    17aa:	04054163          	bltz	a0,17ec <exectest+0xaa>
    if(fd != 1) {
    17ae:	4785                	li	a5,1
    17b0:	04f50c63          	beq	a0,a5,1808 <exectest+0xc6>
      printf("%s: wrong fd\n", s);
    17b4:	85ca                	mv	a1,s2
    17b6:	00005517          	auipc	a0,0x5
    17ba:	2ca50513          	addi	a0,a0,714 # 6a80 <malloc+0xa7c>
    17be:	00004097          	auipc	ra,0x4
    17c2:	788080e7          	jalr	1928(ra) # 5f46 <printf>
      exit(1);
    17c6:	4505                	li	a0,1
    17c8:	00004097          	auipc	ra,0x4
    17cc:	3fe080e7          	jalr	1022(ra) # 5bc6 <exit>
     printf("%s: fork failed\n", s);
    17d0:	85ca                	mv	a1,s2
    17d2:	00005517          	auipc	a0,0x5
    17d6:	1fe50513          	addi	a0,a0,510 # 69d0 <malloc+0x9cc>
    17da:	00004097          	auipc	ra,0x4
    17de:	76c080e7          	jalr	1900(ra) # 5f46 <printf>
     exit(1);
    17e2:	4505                	li	a0,1
    17e4:	00004097          	auipc	ra,0x4
    17e8:	3e2080e7          	jalr	994(ra) # 5bc6 <exit>
      printf("%s: create failed\n", s);
    17ec:	85ca                	mv	a1,s2
    17ee:	00005517          	auipc	a0,0x5
    17f2:	27a50513          	addi	a0,a0,634 # 6a68 <malloc+0xa64>
    17f6:	00004097          	auipc	ra,0x4
    17fa:	750080e7          	jalr	1872(ra) # 5f46 <printf>
      exit(1);
    17fe:	4505                	li	a0,1
    1800:	00004097          	auipc	ra,0x4
    1804:	3c6080e7          	jalr	966(ra) # 5bc6 <exit>
    if(exec("echo", echoargv) < 0){
    1808:	fc040593          	addi	a1,s0,-64
    180c:	00005517          	auipc	a0,0x5
    1810:	93c50513          	addi	a0,a0,-1732 # 6148 <malloc+0x144>
    1814:	00004097          	auipc	ra,0x4
    1818:	3ea080e7          	jalr	1002(ra) # 5bfe <exec>
    181c:	02054163          	bltz	a0,183e <exectest+0xfc>
  if (wait(&xstatus) != pid) {
    1820:	fdc40513          	addi	a0,s0,-36
    1824:	00004097          	auipc	ra,0x4
    1828:	3aa080e7          	jalr	938(ra) # 5bce <wait>
    182c:	02951763          	bne	a0,s1,185a <exectest+0x118>
  if(xstatus != 0)
    1830:	fdc42503          	lw	a0,-36(s0)
    1834:	cd0d                	beqz	a0,186e <exectest+0x12c>
    exit(xstatus);
    1836:	00004097          	auipc	ra,0x4
    183a:	390080e7          	jalr	912(ra) # 5bc6 <exit>
      printf("%s: exec echo failed\n", s);
    183e:	85ca                	mv	a1,s2
    1840:	00005517          	auipc	a0,0x5
    1844:	25050513          	addi	a0,a0,592 # 6a90 <malloc+0xa8c>
    1848:	00004097          	auipc	ra,0x4
    184c:	6fe080e7          	jalr	1790(ra) # 5f46 <printf>
      exit(1);
    1850:	4505                	li	a0,1
    1852:	00004097          	auipc	ra,0x4
    1856:	374080e7          	jalr	884(ra) # 5bc6 <exit>
    printf("%s: wait failed!\n", s);
    185a:	85ca                	mv	a1,s2
    185c:	00005517          	auipc	a0,0x5
    1860:	24c50513          	addi	a0,a0,588 # 6aa8 <malloc+0xaa4>
    1864:	00004097          	auipc	ra,0x4
    1868:	6e2080e7          	jalr	1762(ra) # 5f46 <printf>
    186c:	b7d1                	j	1830 <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    186e:	4581                	li	a1,0
    1870:	00005517          	auipc	a0,0x5
    1874:	1f050513          	addi	a0,a0,496 # 6a60 <malloc+0xa5c>
    1878:	00004097          	auipc	ra,0x4
    187c:	38e080e7          	jalr	910(ra) # 5c06 <open>
  if(fd < 0) {
    1880:	02054a63          	bltz	a0,18b4 <exectest+0x172>
  if (read(fd, buf, 2) != 2) {
    1884:	4609                	li	a2,2
    1886:	fb840593          	addi	a1,s0,-72
    188a:	00004097          	auipc	ra,0x4
    188e:	354080e7          	jalr	852(ra) # 5bde <read>
    1892:	4789                	li	a5,2
    1894:	02f50e63          	beq	a0,a5,18d0 <exectest+0x18e>
    printf("%s: read failed\n", s);
    1898:	85ca                	mv	a1,s2
    189a:	00005517          	auipc	a0,0x5
    189e:	c7e50513          	addi	a0,a0,-898 # 6518 <malloc+0x514>
    18a2:	00004097          	auipc	ra,0x4
    18a6:	6a4080e7          	jalr	1700(ra) # 5f46 <printf>
    exit(1);
    18aa:	4505                	li	a0,1
    18ac:	00004097          	auipc	ra,0x4
    18b0:	31a080e7          	jalr	794(ra) # 5bc6 <exit>
    printf("%s: open failed\n", s);
    18b4:	85ca                	mv	a1,s2
    18b6:	00005517          	auipc	a0,0x5
    18ba:	13250513          	addi	a0,a0,306 # 69e8 <malloc+0x9e4>
    18be:	00004097          	auipc	ra,0x4
    18c2:	688080e7          	jalr	1672(ra) # 5f46 <printf>
    exit(1);
    18c6:	4505                	li	a0,1
    18c8:	00004097          	auipc	ra,0x4
    18cc:	2fe080e7          	jalr	766(ra) # 5bc6 <exit>
  unlink("echo-ok");
    18d0:	00005517          	auipc	a0,0x5
    18d4:	19050513          	addi	a0,a0,400 # 6a60 <malloc+0xa5c>
    18d8:	00004097          	auipc	ra,0x4
    18dc:	33e080e7          	jalr	830(ra) # 5c16 <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    18e0:	fb844703          	lbu	a4,-72(s0)
    18e4:	04f00793          	li	a5,79
    18e8:	00f71863          	bne	a4,a5,18f8 <exectest+0x1b6>
    18ec:	fb944703          	lbu	a4,-71(s0)
    18f0:	04b00793          	li	a5,75
    18f4:	02f70063          	beq	a4,a5,1914 <exectest+0x1d2>
    printf("%s: wrong output\n", s);
    18f8:	85ca                	mv	a1,s2
    18fa:	00005517          	auipc	a0,0x5
    18fe:	1c650513          	addi	a0,a0,454 # 6ac0 <malloc+0xabc>
    1902:	00004097          	auipc	ra,0x4
    1906:	644080e7          	jalr	1604(ra) # 5f46 <printf>
    exit(1);
    190a:	4505                	li	a0,1
    190c:	00004097          	auipc	ra,0x4
    1910:	2ba080e7          	jalr	698(ra) # 5bc6 <exit>
    exit(0);
    1914:	4501                	li	a0,0
    1916:	00004097          	auipc	ra,0x4
    191a:	2b0080e7          	jalr	688(ra) # 5bc6 <exit>

000000000000191e <pipe1>:
{
    191e:	711d                	addi	sp,sp,-96
    1920:	ec86                	sd	ra,88(sp)
    1922:	e8a2                	sd	s0,80(sp)
    1924:	e4a6                	sd	s1,72(sp)
    1926:	e0ca                	sd	s2,64(sp)
    1928:	fc4e                	sd	s3,56(sp)
    192a:	f852                	sd	s4,48(sp)
    192c:	f456                	sd	s5,40(sp)
    192e:	f05a                	sd	s6,32(sp)
    1930:	ec5e                	sd	s7,24(sp)
    1932:	1080                	addi	s0,sp,96
    1934:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    1936:	fa840513          	addi	a0,s0,-88
    193a:	00004097          	auipc	ra,0x4
    193e:	29c080e7          	jalr	668(ra) # 5bd6 <pipe>
    1942:	ed25                	bnez	a0,19ba <pipe1+0x9c>
    1944:	84aa                	mv	s1,a0
  pid = fork();
    1946:	00004097          	auipc	ra,0x4
    194a:	278080e7          	jalr	632(ra) # 5bbe <fork>
    194e:	8a2a                	mv	s4,a0
  if(pid == 0){
    1950:	c159                	beqz	a0,19d6 <pipe1+0xb8>
  } else if(pid > 0){
    1952:	16a05e63          	blez	a0,1ace <pipe1+0x1b0>
    close(fds[1]);
    1956:	fac42503          	lw	a0,-84(s0)
    195a:	00004097          	auipc	ra,0x4
    195e:	294080e7          	jalr	660(ra) # 5bee <close>
    total = 0;
    1962:	8a26                	mv	s4,s1
    cc = 1;
    1964:	4985                	li	s3,1
    while((n = read(fds[0], buf, cc)) > 0){
    1966:	0000ba97          	auipc	s5,0xb
    196a:	312a8a93          	addi	s5,s5,786 # cc78 <buf>
      if(cc > sizeof(buf))
    196e:	6b0d                	lui	s6,0x3
    while((n = read(fds[0], buf, cc)) > 0){
    1970:	864e                	mv	a2,s3
    1972:	85d6                	mv	a1,s5
    1974:	fa842503          	lw	a0,-88(s0)
    1978:	00004097          	auipc	ra,0x4
    197c:	266080e7          	jalr	614(ra) # 5bde <read>
    1980:	10a05263          	blez	a0,1a84 <pipe1+0x166>
      for(i = 0; i < n; i++){
    1984:	0000b717          	auipc	a4,0xb
    1988:	2f470713          	addi	a4,a4,756 # cc78 <buf>
    198c:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    1990:	00074683          	lbu	a3,0(a4)
    1994:	0ff4f793          	andi	a5,s1,255
    1998:	2485                	addiw	s1,s1,1
    199a:	0cf69163          	bne	a3,a5,1a5c <pipe1+0x13e>
      for(i = 0; i < n; i++){
    199e:	0705                	addi	a4,a4,1
    19a0:	fec498e3          	bne	s1,a2,1990 <pipe1+0x72>
      total += n;
    19a4:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    19a8:	0019979b          	slliw	a5,s3,0x1
    19ac:	0007899b          	sext.w	s3,a5
      if(cc > sizeof(buf))
    19b0:	013b7363          	bgeu	s6,s3,19b6 <pipe1+0x98>
        cc = sizeof(buf);
    19b4:	89da                	mv	s3,s6
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    19b6:	84b2                	mv	s1,a2
    19b8:	bf65                	j	1970 <pipe1+0x52>
    printf("%s: pipe() failed\n", s);
    19ba:	85ca                	mv	a1,s2
    19bc:	00005517          	auipc	a0,0x5
    19c0:	11c50513          	addi	a0,a0,284 # 6ad8 <malloc+0xad4>
    19c4:	00004097          	auipc	ra,0x4
    19c8:	582080e7          	jalr	1410(ra) # 5f46 <printf>
    exit(1);
    19cc:	4505                	li	a0,1
    19ce:	00004097          	auipc	ra,0x4
    19d2:	1f8080e7          	jalr	504(ra) # 5bc6 <exit>
    close(fds[0]);
    19d6:	fa842503          	lw	a0,-88(s0)
    19da:	00004097          	auipc	ra,0x4
    19de:	214080e7          	jalr	532(ra) # 5bee <close>
    for(n = 0; n < N; n++){
    19e2:	0000bb17          	auipc	s6,0xb
    19e6:	296b0b13          	addi	s6,s6,662 # cc78 <buf>
    19ea:	416004bb          	negw	s1,s6
    19ee:	0ff4f493          	andi	s1,s1,255
    19f2:	409b0993          	addi	s3,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
    19f6:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
    19f8:	6a85                	lui	s5,0x1
    19fa:	42da8a93          	addi	s5,s5,1069 # 142d <copyinstr2+0x9b>
{
    19fe:	87da                	mv	a5,s6
        buf[i] = seq++;
    1a00:	0097873b          	addw	a4,a5,s1
    1a04:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    1a08:	0785                	addi	a5,a5,1
    1a0a:	fef99be3          	bne	s3,a5,1a00 <pipe1+0xe2>
        buf[i] = seq++;
    1a0e:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
    1a12:	40900613          	li	a2,1033
    1a16:	85de                	mv	a1,s7
    1a18:	fac42503          	lw	a0,-84(s0)
    1a1c:	00004097          	auipc	ra,0x4
    1a20:	1ca080e7          	jalr	458(ra) # 5be6 <write>
    1a24:	40900793          	li	a5,1033
    1a28:	00f51c63          	bne	a0,a5,1a40 <pipe1+0x122>
    for(n = 0; n < N; n++){
    1a2c:	24a5                	addiw	s1,s1,9
    1a2e:	0ff4f493          	andi	s1,s1,255
    1a32:	fd5a16e3          	bne	s4,s5,19fe <pipe1+0xe0>
    exit(0);
    1a36:	4501                	li	a0,0
    1a38:	00004097          	auipc	ra,0x4
    1a3c:	18e080e7          	jalr	398(ra) # 5bc6 <exit>
        printf("%s: pipe1 oops 1\n", s);
    1a40:	85ca                	mv	a1,s2
    1a42:	00005517          	auipc	a0,0x5
    1a46:	0ae50513          	addi	a0,a0,174 # 6af0 <malloc+0xaec>
    1a4a:	00004097          	auipc	ra,0x4
    1a4e:	4fc080e7          	jalr	1276(ra) # 5f46 <printf>
        exit(1);
    1a52:	4505                	li	a0,1
    1a54:	00004097          	auipc	ra,0x4
    1a58:	172080e7          	jalr	370(ra) # 5bc6 <exit>
          printf("%s: pipe1 oops 2\n", s);
    1a5c:	85ca                	mv	a1,s2
    1a5e:	00005517          	auipc	a0,0x5
    1a62:	0aa50513          	addi	a0,a0,170 # 6b08 <malloc+0xb04>
    1a66:	00004097          	auipc	ra,0x4
    1a6a:	4e0080e7          	jalr	1248(ra) # 5f46 <printf>
}
    1a6e:	60e6                	ld	ra,88(sp)
    1a70:	6446                	ld	s0,80(sp)
    1a72:	64a6                	ld	s1,72(sp)
    1a74:	6906                	ld	s2,64(sp)
    1a76:	79e2                	ld	s3,56(sp)
    1a78:	7a42                	ld	s4,48(sp)
    1a7a:	7aa2                	ld	s5,40(sp)
    1a7c:	7b02                	ld	s6,32(sp)
    1a7e:	6be2                	ld	s7,24(sp)
    1a80:	6125                	addi	sp,sp,96
    1a82:	8082                	ret
    if(total != N * SZ){
    1a84:	6785                	lui	a5,0x1
    1a86:	42d78793          	addi	a5,a5,1069 # 142d <copyinstr2+0x9b>
    1a8a:	02fa0063          	beq	s4,a5,1aaa <pipe1+0x18c>
      printf("%s: pipe1 oops 3 total %d\n", total);
    1a8e:	85d2                	mv	a1,s4
    1a90:	00005517          	auipc	a0,0x5
    1a94:	09050513          	addi	a0,a0,144 # 6b20 <malloc+0xb1c>
    1a98:	00004097          	auipc	ra,0x4
    1a9c:	4ae080e7          	jalr	1198(ra) # 5f46 <printf>
      exit(1);
    1aa0:	4505                	li	a0,1
    1aa2:	00004097          	auipc	ra,0x4
    1aa6:	124080e7          	jalr	292(ra) # 5bc6 <exit>
    close(fds[0]);
    1aaa:	fa842503          	lw	a0,-88(s0)
    1aae:	00004097          	auipc	ra,0x4
    1ab2:	140080e7          	jalr	320(ra) # 5bee <close>
    wait(&xstatus);
    1ab6:	fa440513          	addi	a0,s0,-92
    1aba:	00004097          	auipc	ra,0x4
    1abe:	114080e7          	jalr	276(ra) # 5bce <wait>
    exit(xstatus);
    1ac2:	fa442503          	lw	a0,-92(s0)
    1ac6:	00004097          	auipc	ra,0x4
    1aca:	100080e7          	jalr	256(ra) # 5bc6 <exit>
    printf("%s: fork() failed\n", s);
    1ace:	85ca                	mv	a1,s2
    1ad0:	00005517          	auipc	a0,0x5
    1ad4:	07050513          	addi	a0,a0,112 # 6b40 <malloc+0xb3c>
    1ad8:	00004097          	auipc	ra,0x4
    1adc:	46e080e7          	jalr	1134(ra) # 5f46 <printf>
    exit(1);
    1ae0:	4505                	li	a0,1
    1ae2:	00004097          	auipc	ra,0x4
    1ae6:	0e4080e7          	jalr	228(ra) # 5bc6 <exit>

0000000000001aea <exitwait>:
{
    1aea:	7139                	addi	sp,sp,-64
    1aec:	fc06                	sd	ra,56(sp)
    1aee:	f822                	sd	s0,48(sp)
    1af0:	f426                	sd	s1,40(sp)
    1af2:	f04a                	sd	s2,32(sp)
    1af4:	ec4e                	sd	s3,24(sp)
    1af6:	e852                	sd	s4,16(sp)
    1af8:	0080                	addi	s0,sp,64
    1afa:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
    1afc:	4901                	li	s2,0
    1afe:	06400993          	li	s3,100
    pid = fork();
    1b02:	00004097          	auipc	ra,0x4
    1b06:	0bc080e7          	jalr	188(ra) # 5bbe <fork>
    1b0a:	84aa                	mv	s1,a0
    if(pid < 0){
    1b0c:	02054a63          	bltz	a0,1b40 <exitwait+0x56>
    if(pid){
    1b10:	c151                	beqz	a0,1b94 <exitwait+0xaa>
      if(wait(&xstate) != pid){
    1b12:	fcc40513          	addi	a0,s0,-52
    1b16:	00004097          	auipc	ra,0x4
    1b1a:	0b8080e7          	jalr	184(ra) # 5bce <wait>
    1b1e:	02951f63          	bne	a0,s1,1b5c <exitwait+0x72>
      if(i != xstate) {
    1b22:	fcc42783          	lw	a5,-52(s0)
    1b26:	05279963          	bne	a5,s2,1b78 <exitwait+0x8e>
  for(i = 0; i < 100; i++){
    1b2a:	2905                	addiw	s2,s2,1
    1b2c:	fd391be3          	bne	s2,s3,1b02 <exitwait+0x18>
}
    1b30:	70e2                	ld	ra,56(sp)
    1b32:	7442                	ld	s0,48(sp)
    1b34:	74a2                	ld	s1,40(sp)
    1b36:	7902                	ld	s2,32(sp)
    1b38:	69e2                	ld	s3,24(sp)
    1b3a:	6a42                	ld	s4,16(sp)
    1b3c:	6121                	addi	sp,sp,64
    1b3e:	8082                	ret
      printf("%s: fork failed\n", s);
    1b40:	85d2                	mv	a1,s4
    1b42:	00005517          	auipc	a0,0x5
    1b46:	e8e50513          	addi	a0,a0,-370 # 69d0 <malloc+0x9cc>
    1b4a:	00004097          	auipc	ra,0x4
    1b4e:	3fc080e7          	jalr	1020(ra) # 5f46 <printf>
      exit(1);
    1b52:	4505                	li	a0,1
    1b54:	00004097          	auipc	ra,0x4
    1b58:	072080e7          	jalr	114(ra) # 5bc6 <exit>
        printf("%s: wait wrong pid\n", s);
    1b5c:	85d2                	mv	a1,s4
    1b5e:	00005517          	auipc	a0,0x5
    1b62:	ffa50513          	addi	a0,a0,-6 # 6b58 <malloc+0xb54>
    1b66:	00004097          	auipc	ra,0x4
    1b6a:	3e0080e7          	jalr	992(ra) # 5f46 <printf>
        exit(1);
    1b6e:	4505                	li	a0,1
    1b70:	00004097          	auipc	ra,0x4
    1b74:	056080e7          	jalr	86(ra) # 5bc6 <exit>
        printf("%s: wait wrong exit status\n", s);
    1b78:	85d2                	mv	a1,s4
    1b7a:	00005517          	auipc	a0,0x5
    1b7e:	ff650513          	addi	a0,a0,-10 # 6b70 <malloc+0xb6c>
    1b82:	00004097          	auipc	ra,0x4
    1b86:	3c4080e7          	jalr	964(ra) # 5f46 <printf>
        exit(1);
    1b8a:	4505                	li	a0,1
    1b8c:	00004097          	auipc	ra,0x4
    1b90:	03a080e7          	jalr	58(ra) # 5bc6 <exit>
      exit(i);
    1b94:	854a                	mv	a0,s2
    1b96:	00004097          	auipc	ra,0x4
    1b9a:	030080e7          	jalr	48(ra) # 5bc6 <exit>

0000000000001b9e <twochildren>:
{
    1b9e:	1101                	addi	sp,sp,-32
    1ba0:	ec06                	sd	ra,24(sp)
    1ba2:	e822                	sd	s0,16(sp)
    1ba4:	e426                	sd	s1,8(sp)
    1ba6:	e04a                	sd	s2,0(sp)
    1ba8:	1000                	addi	s0,sp,32
    1baa:	892a                	mv	s2,a0
    1bac:	3e800493          	li	s1,1000
    int pid1 = fork();
    1bb0:	00004097          	auipc	ra,0x4
    1bb4:	00e080e7          	jalr	14(ra) # 5bbe <fork>
    if(pid1 < 0){
    1bb8:	02054c63          	bltz	a0,1bf0 <twochildren+0x52>
    if(pid1 == 0){
    1bbc:	c921                	beqz	a0,1c0c <twochildren+0x6e>
      int pid2 = fork();
    1bbe:	00004097          	auipc	ra,0x4
    1bc2:	000080e7          	jalr	ra # 5bbe <fork>
      if(pid2 < 0){
    1bc6:	04054763          	bltz	a0,1c14 <twochildren+0x76>
      if(pid2 == 0){
    1bca:	c13d                	beqz	a0,1c30 <twochildren+0x92>
        wait(0);
    1bcc:	4501                	li	a0,0
    1bce:	00004097          	auipc	ra,0x4
    1bd2:	000080e7          	jalr	ra # 5bce <wait>
        wait(0);
    1bd6:	4501                	li	a0,0
    1bd8:	00004097          	auipc	ra,0x4
    1bdc:	ff6080e7          	jalr	-10(ra) # 5bce <wait>
  for(int i = 0; i < 1000; i++){
    1be0:	34fd                	addiw	s1,s1,-1
    1be2:	f4f9                	bnez	s1,1bb0 <twochildren+0x12>
}
    1be4:	60e2                	ld	ra,24(sp)
    1be6:	6442                	ld	s0,16(sp)
    1be8:	64a2                	ld	s1,8(sp)
    1bea:	6902                	ld	s2,0(sp)
    1bec:	6105                	addi	sp,sp,32
    1bee:	8082                	ret
      printf("%s: fork failed\n", s);
    1bf0:	85ca                	mv	a1,s2
    1bf2:	00005517          	auipc	a0,0x5
    1bf6:	dde50513          	addi	a0,a0,-546 # 69d0 <malloc+0x9cc>
    1bfa:	00004097          	auipc	ra,0x4
    1bfe:	34c080e7          	jalr	844(ra) # 5f46 <printf>
      exit(1);
    1c02:	4505                	li	a0,1
    1c04:	00004097          	auipc	ra,0x4
    1c08:	fc2080e7          	jalr	-62(ra) # 5bc6 <exit>
      exit(0);
    1c0c:	00004097          	auipc	ra,0x4
    1c10:	fba080e7          	jalr	-70(ra) # 5bc6 <exit>
        printf("%s: fork failed\n", s);
    1c14:	85ca                	mv	a1,s2
    1c16:	00005517          	auipc	a0,0x5
    1c1a:	dba50513          	addi	a0,a0,-582 # 69d0 <malloc+0x9cc>
    1c1e:	00004097          	auipc	ra,0x4
    1c22:	328080e7          	jalr	808(ra) # 5f46 <printf>
        exit(1);
    1c26:	4505                	li	a0,1
    1c28:	00004097          	auipc	ra,0x4
    1c2c:	f9e080e7          	jalr	-98(ra) # 5bc6 <exit>
        exit(0);
    1c30:	00004097          	auipc	ra,0x4
    1c34:	f96080e7          	jalr	-106(ra) # 5bc6 <exit>

0000000000001c38 <forkfork>:
{
    1c38:	7179                	addi	sp,sp,-48
    1c3a:	f406                	sd	ra,40(sp)
    1c3c:	f022                	sd	s0,32(sp)
    1c3e:	ec26                	sd	s1,24(sp)
    1c40:	1800                	addi	s0,sp,48
    1c42:	84aa                	mv	s1,a0
    int pid = fork();
    1c44:	00004097          	auipc	ra,0x4
    1c48:	f7a080e7          	jalr	-134(ra) # 5bbe <fork>
    if(pid < 0){
    1c4c:	04054163          	bltz	a0,1c8e <forkfork+0x56>
    if(pid == 0){
    1c50:	cd29                	beqz	a0,1caa <forkfork+0x72>
    int pid = fork();
    1c52:	00004097          	auipc	ra,0x4
    1c56:	f6c080e7          	jalr	-148(ra) # 5bbe <fork>
    if(pid < 0){
    1c5a:	02054a63          	bltz	a0,1c8e <forkfork+0x56>
    if(pid == 0){
    1c5e:	c531                	beqz	a0,1caa <forkfork+0x72>
    wait(&xstatus);
    1c60:	fdc40513          	addi	a0,s0,-36
    1c64:	00004097          	auipc	ra,0x4
    1c68:	f6a080e7          	jalr	-150(ra) # 5bce <wait>
    if(xstatus != 0) {
    1c6c:	fdc42783          	lw	a5,-36(s0)
    1c70:	ebbd                	bnez	a5,1ce6 <forkfork+0xae>
    wait(&xstatus);
    1c72:	fdc40513          	addi	a0,s0,-36
    1c76:	00004097          	auipc	ra,0x4
    1c7a:	f58080e7          	jalr	-168(ra) # 5bce <wait>
    if(xstatus != 0) {
    1c7e:	fdc42783          	lw	a5,-36(s0)
    1c82:	e3b5                	bnez	a5,1ce6 <forkfork+0xae>
}
    1c84:	70a2                	ld	ra,40(sp)
    1c86:	7402                	ld	s0,32(sp)
    1c88:	64e2                	ld	s1,24(sp)
    1c8a:	6145                	addi	sp,sp,48
    1c8c:	8082                	ret
      printf("%s: fork failed", s);
    1c8e:	85a6                	mv	a1,s1
    1c90:	00005517          	auipc	a0,0x5
    1c94:	f0050513          	addi	a0,a0,-256 # 6b90 <malloc+0xb8c>
    1c98:	00004097          	auipc	ra,0x4
    1c9c:	2ae080e7          	jalr	686(ra) # 5f46 <printf>
      exit(1);
    1ca0:	4505                	li	a0,1
    1ca2:	00004097          	auipc	ra,0x4
    1ca6:	f24080e7          	jalr	-220(ra) # 5bc6 <exit>
{
    1caa:	0c800493          	li	s1,200
        int pid1 = fork();
    1cae:	00004097          	auipc	ra,0x4
    1cb2:	f10080e7          	jalr	-240(ra) # 5bbe <fork>
        if(pid1 < 0){
    1cb6:	00054f63          	bltz	a0,1cd4 <forkfork+0x9c>
        if(pid1 == 0){
    1cba:	c115                	beqz	a0,1cde <forkfork+0xa6>
        wait(0);
    1cbc:	4501                	li	a0,0
    1cbe:	00004097          	auipc	ra,0x4
    1cc2:	f10080e7          	jalr	-240(ra) # 5bce <wait>
      for(int j = 0; j < 200; j++){
    1cc6:	34fd                	addiw	s1,s1,-1
    1cc8:	f0fd                	bnez	s1,1cae <forkfork+0x76>
      exit(0);
    1cca:	4501                	li	a0,0
    1ccc:	00004097          	auipc	ra,0x4
    1cd0:	efa080e7          	jalr	-262(ra) # 5bc6 <exit>
          exit(1);
    1cd4:	4505                	li	a0,1
    1cd6:	00004097          	auipc	ra,0x4
    1cda:	ef0080e7          	jalr	-272(ra) # 5bc6 <exit>
          exit(0);
    1cde:	00004097          	auipc	ra,0x4
    1ce2:	ee8080e7          	jalr	-280(ra) # 5bc6 <exit>
      printf("%s: fork in child failed", s);
    1ce6:	85a6                	mv	a1,s1
    1ce8:	00005517          	auipc	a0,0x5
    1cec:	eb850513          	addi	a0,a0,-328 # 6ba0 <malloc+0xb9c>
    1cf0:	00004097          	auipc	ra,0x4
    1cf4:	256080e7          	jalr	598(ra) # 5f46 <printf>
      exit(1);
    1cf8:	4505                	li	a0,1
    1cfa:	00004097          	auipc	ra,0x4
    1cfe:	ecc080e7          	jalr	-308(ra) # 5bc6 <exit>

0000000000001d02 <reparent2>:
{
    1d02:	1101                	addi	sp,sp,-32
    1d04:	ec06                	sd	ra,24(sp)
    1d06:	e822                	sd	s0,16(sp)
    1d08:	e426                	sd	s1,8(sp)
    1d0a:	1000                	addi	s0,sp,32
    1d0c:	32000493          	li	s1,800
    int pid1 = fork();
    1d10:	00004097          	auipc	ra,0x4
    1d14:	eae080e7          	jalr	-338(ra) # 5bbe <fork>
    if(pid1 < 0){
    1d18:	00054f63          	bltz	a0,1d36 <reparent2+0x34>
    if(pid1 == 0){
    1d1c:	c915                	beqz	a0,1d50 <reparent2+0x4e>
    wait(0);
    1d1e:	4501                	li	a0,0
    1d20:	00004097          	auipc	ra,0x4
    1d24:	eae080e7          	jalr	-338(ra) # 5bce <wait>
  for(int i = 0; i < 800; i++){
    1d28:	34fd                	addiw	s1,s1,-1
    1d2a:	f0fd                	bnez	s1,1d10 <reparent2+0xe>
  exit(0);
    1d2c:	4501                	li	a0,0
    1d2e:	00004097          	auipc	ra,0x4
    1d32:	e98080e7          	jalr	-360(ra) # 5bc6 <exit>
      printf("fork failed\n");
    1d36:	00005517          	auipc	a0,0x5
    1d3a:	0a250513          	addi	a0,a0,162 # 6dd8 <malloc+0xdd4>
    1d3e:	00004097          	auipc	ra,0x4
    1d42:	208080e7          	jalr	520(ra) # 5f46 <printf>
      exit(1);
    1d46:	4505                	li	a0,1
    1d48:	00004097          	auipc	ra,0x4
    1d4c:	e7e080e7          	jalr	-386(ra) # 5bc6 <exit>
      fork();
    1d50:	00004097          	auipc	ra,0x4
    1d54:	e6e080e7          	jalr	-402(ra) # 5bbe <fork>
      fork();
    1d58:	00004097          	auipc	ra,0x4
    1d5c:	e66080e7          	jalr	-410(ra) # 5bbe <fork>
      exit(0);
    1d60:	4501                	li	a0,0
    1d62:	00004097          	auipc	ra,0x4
    1d66:	e64080e7          	jalr	-412(ra) # 5bc6 <exit>

0000000000001d6a <createdelete>:
{
    1d6a:	7175                	addi	sp,sp,-144
    1d6c:	e506                	sd	ra,136(sp)
    1d6e:	e122                	sd	s0,128(sp)
    1d70:	fca6                	sd	s1,120(sp)
    1d72:	f8ca                	sd	s2,112(sp)
    1d74:	f4ce                	sd	s3,104(sp)
    1d76:	f0d2                	sd	s4,96(sp)
    1d78:	ecd6                	sd	s5,88(sp)
    1d7a:	e8da                	sd	s6,80(sp)
    1d7c:	e4de                	sd	s7,72(sp)
    1d7e:	e0e2                	sd	s8,64(sp)
    1d80:	fc66                	sd	s9,56(sp)
    1d82:	0900                	addi	s0,sp,144
    1d84:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
    1d86:	4901                	li	s2,0
    1d88:	4991                	li	s3,4
    pid = fork();
    1d8a:	00004097          	auipc	ra,0x4
    1d8e:	e34080e7          	jalr	-460(ra) # 5bbe <fork>
    1d92:	84aa                	mv	s1,a0
    if(pid < 0){
    1d94:	02054f63          	bltz	a0,1dd2 <createdelete+0x68>
    if(pid == 0){
    1d98:	c939                	beqz	a0,1dee <createdelete+0x84>
  for(pi = 0; pi < NCHILD; pi++){
    1d9a:	2905                	addiw	s2,s2,1
    1d9c:	ff3917e3          	bne	s2,s3,1d8a <createdelete+0x20>
    1da0:	4491                	li	s1,4
    wait(&xstatus);
    1da2:	f7c40513          	addi	a0,s0,-132
    1da6:	00004097          	auipc	ra,0x4
    1daa:	e28080e7          	jalr	-472(ra) # 5bce <wait>
    if(xstatus != 0)
    1dae:	f7c42903          	lw	s2,-132(s0)
    1db2:	0e091263          	bnez	s2,1e96 <createdelete+0x12c>
  for(pi = 0; pi < NCHILD; pi++){
    1db6:	34fd                	addiw	s1,s1,-1
    1db8:	f4ed                	bnez	s1,1da2 <createdelete+0x38>
  name[0] = name[1] = name[2] = 0;
    1dba:	f8040123          	sb	zero,-126(s0)
    1dbe:	03000993          	li	s3,48
    1dc2:	5a7d                	li	s4,-1
    1dc4:	07000c13          	li	s8,112
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1dc8:	4b21                	li	s6,8
      if((i == 0 || i >= N/2) && fd < 0){
    1dca:	4ba5                	li	s7,9
    for(pi = 0; pi < NCHILD; pi++){
    1dcc:	07400a93          	li	s5,116
    1dd0:	a29d                	j	1f36 <createdelete+0x1cc>
      printf("fork failed\n", s);
    1dd2:	85e6                	mv	a1,s9
    1dd4:	00005517          	auipc	a0,0x5
    1dd8:	00450513          	addi	a0,a0,4 # 6dd8 <malloc+0xdd4>
    1ddc:	00004097          	auipc	ra,0x4
    1de0:	16a080e7          	jalr	362(ra) # 5f46 <printf>
      exit(1);
    1de4:	4505                	li	a0,1
    1de6:	00004097          	auipc	ra,0x4
    1dea:	de0080e7          	jalr	-544(ra) # 5bc6 <exit>
      name[0] = 'p' + pi;
    1dee:	0709091b          	addiw	s2,s2,112
    1df2:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    1df6:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
    1dfa:	4951                	li	s2,20
    1dfc:	a015                	j	1e20 <createdelete+0xb6>
          printf("%s: create failed\n", s);
    1dfe:	85e6                	mv	a1,s9
    1e00:	00005517          	auipc	a0,0x5
    1e04:	c6850513          	addi	a0,a0,-920 # 6a68 <malloc+0xa64>
    1e08:	00004097          	auipc	ra,0x4
    1e0c:	13e080e7          	jalr	318(ra) # 5f46 <printf>
          exit(1);
    1e10:	4505                	li	a0,1
    1e12:	00004097          	auipc	ra,0x4
    1e16:	db4080e7          	jalr	-588(ra) # 5bc6 <exit>
      for(i = 0; i < N; i++){
    1e1a:	2485                	addiw	s1,s1,1
    1e1c:	07248863          	beq	s1,s2,1e8c <createdelete+0x122>
        name[1] = '0' + i;
    1e20:	0304879b          	addiw	a5,s1,48
    1e24:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    1e28:	20200593          	li	a1,514
    1e2c:	f8040513          	addi	a0,s0,-128
    1e30:	00004097          	auipc	ra,0x4
    1e34:	dd6080e7          	jalr	-554(ra) # 5c06 <open>
        if(fd < 0){
    1e38:	fc0543e3          	bltz	a0,1dfe <createdelete+0x94>
        close(fd);
    1e3c:	00004097          	auipc	ra,0x4
    1e40:	db2080e7          	jalr	-590(ra) # 5bee <close>
        if(i > 0 && (i % 2 ) == 0){
    1e44:	fc905be3          	blez	s1,1e1a <createdelete+0xb0>
    1e48:	0014f793          	andi	a5,s1,1
    1e4c:	f7f9                	bnez	a5,1e1a <createdelete+0xb0>
          name[1] = '0' + (i / 2);
    1e4e:	01f4d79b          	srliw	a5,s1,0x1f
    1e52:	9fa5                	addw	a5,a5,s1
    1e54:	4017d79b          	sraiw	a5,a5,0x1
    1e58:	0307879b          	addiw	a5,a5,48
    1e5c:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    1e60:	f8040513          	addi	a0,s0,-128
    1e64:	00004097          	auipc	ra,0x4
    1e68:	db2080e7          	jalr	-590(ra) # 5c16 <unlink>
    1e6c:	fa0557e3          	bgez	a0,1e1a <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
    1e70:	85e6                	mv	a1,s9
    1e72:	00005517          	auipc	a0,0x5
    1e76:	d4e50513          	addi	a0,a0,-690 # 6bc0 <malloc+0xbbc>
    1e7a:	00004097          	auipc	ra,0x4
    1e7e:	0cc080e7          	jalr	204(ra) # 5f46 <printf>
            exit(1);
    1e82:	4505                	li	a0,1
    1e84:	00004097          	auipc	ra,0x4
    1e88:	d42080e7          	jalr	-702(ra) # 5bc6 <exit>
      exit(0);
    1e8c:	4501                	li	a0,0
    1e8e:	00004097          	auipc	ra,0x4
    1e92:	d38080e7          	jalr	-712(ra) # 5bc6 <exit>
      exit(1);
    1e96:	4505                	li	a0,1
    1e98:	00004097          	auipc	ra,0x4
    1e9c:	d2e080e7          	jalr	-722(ra) # 5bc6 <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    1ea0:	f8040613          	addi	a2,s0,-128
    1ea4:	85e6                	mv	a1,s9
    1ea6:	00005517          	auipc	a0,0x5
    1eaa:	d3250513          	addi	a0,a0,-718 # 6bd8 <malloc+0xbd4>
    1eae:	00004097          	auipc	ra,0x4
    1eb2:	098080e7          	jalr	152(ra) # 5f46 <printf>
        exit(1);
    1eb6:	4505                	li	a0,1
    1eb8:	00004097          	auipc	ra,0x4
    1ebc:	d0e080e7          	jalr	-754(ra) # 5bc6 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1ec0:	054b7163          	bgeu	s6,s4,1f02 <createdelete+0x198>
      if(fd >= 0)
    1ec4:	02055a63          	bgez	a0,1ef8 <createdelete+0x18e>
    for(pi = 0; pi < NCHILD; pi++){
    1ec8:	2485                	addiw	s1,s1,1
    1eca:	0ff4f493          	andi	s1,s1,255
    1ece:	05548c63          	beq	s1,s5,1f26 <createdelete+0x1bc>
      name[0] = 'p' + pi;
    1ed2:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    1ed6:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    1eda:	4581                	li	a1,0
    1edc:	f8040513          	addi	a0,s0,-128
    1ee0:	00004097          	auipc	ra,0x4
    1ee4:	d26080e7          	jalr	-730(ra) # 5c06 <open>
      if((i == 0 || i >= N/2) && fd < 0){
    1ee8:	00090463          	beqz	s2,1ef0 <createdelete+0x186>
    1eec:	fd2bdae3          	bge	s7,s2,1ec0 <createdelete+0x156>
    1ef0:	fa0548e3          	bltz	a0,1ea0 <createdelete+0x136>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1ef4:	014b7963          	bgeu	s6,s4,1f06 <createdelete+0x19c>
        close(fd);
    1ef8:	00004097          	auipc	ra,0x4
    1efc:	cf6080e7          	jalr	-778(ra) # 5bee <close>
    1f00:	b7e1                	j	1ec8 <createdelete+0x15e>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1f02:	fc0543e3          	bltz	a0,1ec8 <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
    1f06:	f8040613          	addi	a2,s0,-128
    1f0a:	85e6                	mv	a1,s9
    1f0c:	00005517          	auipc	a0,0x5
    1f10:	cf450513          	addi	a0,a0,-780 # 6c00 <malloc+0xbfc>
    1f14:	00004097          	auipc	ra,0x4
    1f18:	032080e7          	jalr	50(ra) # 5f46 <printf>
        exit(1);
    1f1c:	4505                	li	a0,1
    1f1e:	00004097          	auipc	ra,0x4
    1f22:	ca8080e7          	jalr	-856(ra) # 5bc6 <exit>
  for(i = 0; i < N; i++){
    1f26:	2905                	addiw	s2,s2,1
    1f28:	2a05                	addiw	s4,s4,1
    1f2a:	2985                	addiw	s3,s3,1
    1f2c:	0ff9f993          	andi	s3,s3,255
    1f30:	47d1                	li	a5,20
    1f32:	02f90a63          	beq	s2,a5,1f66 <createdelete+0x1fc>
    for(pi = 0; pi < NCHILD; pi++){
    1f36:	84e2                	mv	s1,s8
    1f38:	bf69                	j	1ed2 <createdelete+0x168>
  for(i = 0; i < N; i++){
    1f3a:	2905                	addiw	s2,s2,1
    1f3c:	0ff97913          	andi	s2,s2,255
    1f40:	2985                	addiw	s3,s3,1
    1f42:	0ff9f993          	andi	s3,s3,255
    1f46:	03490863          	beq	s2,s4,1f76 <createdelete+0x20c>
  name[0] = name[1] = name[2] = 0;
    1f4a:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
    1f4c:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    1f50:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    1f54:	f8040513          	addi	a0,s0,-128
    1f58:	00004097          	auipc	ra,0x4
    1f5c:	cbe080e7          	jalr	-834(ra) # 5c16 <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    1f60:	34fd                	addiw	s1,s1,-1
    1f62:	f4ed                	bnez	s1,1f4c <createdelete+0x1e2>
    1f64:	bfd9                	j	1f3a <createdelete+0x1d0>
    1f66:	03000993          	li	s3,48
    1f6a:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    1f6e:	4a91                	li	s5,4
  for(i = 0; i < N; i++){
    1f70:	08400a13          	li	s4,132
    1f74:	bfd9                	j	1f4a <createdelete+0x1e0>
}
    1f76:	60aa                	ld	ra,136(sp)
    1f78:	640a                	ld	s0,128(sp)
    1f7a:	74e6                	ld	s1,120(sp)
    1f7c:	7946                	ld	s2,112(sp)
    1f7e:	79a6                	ld	s3,104(sp)
    1f80:	7a06                	ld	s4,96(sp)
    1f82:	6ae6                	ld	s5,88(sp)
    1f84:	6b46                	ld	s6,80(sp)
    1f86:	6ba6                	ld	s7,72(sp)
    1f88:	6c06                	ld	s8,64(sp)
    1f8a:	7ce2                	ld	s9,56(sp)
    1f8c:	6149                	addi	sp,sp,144
    1f8e:	8082                	ret

0000000000001f90 <linkunlink>:
{
    1f90:	711d                	addi	sp,sp,-96
    1f92:	ec86                	sd	ra,88(sp)
    1f94:	e8a2                	sd	s0,80(sp)
    1f96:	e4a6                	sd	s1,72(sp)
    1f98:	e0ca                	sd	s2,64(sp)
    1f9a:	fc4e                	sd	s3,56(sp)
    1f9c:	f852                	sd	s4,48(sp)
    1f9e:	f456                	sd	s5,40(sp)
    1fa0:	f05a                	sd	s6,32(sp)
    1fa2:	ec5e                	sd	s7,24(sp)
    1fa4:	e862                	sd	s8,16(sp)
    1fa6:	e466                	sd	s9,8(sp)
    1fa8:	1080                	addi	s0,sp,96
    1faa:	84aa                	mv	s1,a0
  unlink("x");
    1fac:	00004517          	auipc	a0,0x4
    1fb0:	20c50513          	addi	a0,a0,524 # 61b8 <malloc+0x1b4>
    1fb4:	00004097          	auipc	ra,0x4
    1fb8:	c62080e7          	jalr	-926(ra) # 5c16 <unlink>
  pid = fork();
    1fbc:	00004097          	auipc	ra,0x4
    1fc0:	c02080e7          	jalr	-1022(ra) # 5bbe <fork>
  if(pid < 0){
    1fc4:	02054b63          	bltz	a0,1ffa <linkunlink+0x6a>
    1fc8:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    1fca:	4c85                	li	s9,1
    1fcc:	e119                	bnez	a0,1fd2 <linkunlink+0x42>
    1fce:	06100c93          	li	s9,97
    1fd2:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    1fd6:	41c659b7          	lui	s3,0x41c65
    1fda:	e6d9899b          	addiw	s3,s3,-403
    1fde:	690d                	lui	s2,0x3
    1fe0:	0399091b          	addiw	s2,s2,57
    if((x % 3) == 0){
    1fe4:	4a0d                	li	s4,3
    } else if((x % 3) == 1){
    1fe6:	4b05                	li	s6,1
      unlink("x");
    1fe8:	00004a97          	auipc	s5,0x4
    1fec:	1d0a8a93          	addi	s5,s5,464 # 61b8 <malloc+0x1b4>
      link("cat", "x");
    1ff0:	00005b97          	auipc	s7,0x5
    1ff4:	c38b8b93          	addi	s7,s7,-968 # 6c28 <malloc+0xc24>
    1ff8:	a825                	j	2030 <linkunlink+0xa0>
    printf("%s: fork failed\n", s);
    1ffa:	85a6                	mv	a1,s1
    1ffc:	00005517          	auipc	a0,0x5
    2000:	9d450513          	addi	a0,a0,-1580 # 69d0 <malloc+0x9cc>
    2004:	00004097          	auipc	ra,0x4
    2008:	f42080e7          	jalr	-190(ra) # 5f46 <printf>
    exit(1);
    200c:	4505                	li	a0,1
    200e:	00004097          	auipc	ra,0x4
    2012:	bb8080e7          	jalr	-1096(ra) # 5bc6 <exit>
      close(open("x", O_RDWR | O_CREATE));
    2016:	20200593          	li	a1,514
    201a:	8556                	mv	a0,s5
    201c:	00004097          	auipc	ra,0x4
    2020:	bea080e7          	jalr	-1046(ra) # 5c06 <open>
    2024:	00004097          	auipc	ra,0x4
    2028:	bca080e7          	jalr	-1078(ra) # 5bee <close>
  for(i = 0; i < 100; i++){
    202c:	34fd                	addiw	s1,s1,-1
    202e:	c88d                	beqz	s1,2060 <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    2030:	033c87bb          	mulw	a5,s9,s3
    2034:	012787bb          	addw	a5,a5,s2
    2038:	00078c9b          	sext.w	s9,a5
    if((x % 3) == 0){
    203c:	0347f7bb          	remuw	a5,a5,s4
    2040:	dbf9                	beqz	a5,2016 <linkunlink+0x86>
    } else if((x % 3) == 1){
    2042:	01678863          	beq	a5,s6,2052 <linkunlink+0xc2>
      unlink("x");
    2046:	8556                	mv	a0,s5
    2048:	00004097          	auipc	ra,0x4
    204c:	bce080e7          	jalr	-1074(ra) # 5c16 <unlink>
    2050:	bff1                	j	202c <linkunlink+0x9c>
      link("cat", "x");
    2052:	85d6                	mv	a1,s5
    2054:	855e                	mv	a0,s7
    2056:	00004097          	auipc	ra,0x4
    205a:	bd0080e7          	jalr	-1072(ra) # 5c26 <link>
    205e:	b7f9                	j	202c <linkunlink+0x9c>
  if(pid)
    2060:	020c0463          	beqz	s8,2088 <linkunlink+0xf8>
    wait(0);
    2064:	4501                	li	a0,0
    2066:	00004097          	auipc	ra,0x4
    206a:	b68080e7          	jalr	-1176(ra) # 5bce <wait>
}
    206e:	60e6                	ld	ra,88(sp)
    2070:	6446                	ld	s0,80(sp)
    2072:	64a6                	ld	s1,72(sp)
    2074:	6906                	ld	s2,64(sp)
    2076:	79e2                	ld	s3,56(sp)
    2078:	7a42                	ld	s4,48(sp)
    207a:	7aa2                	ld	s5,40(sp)
    207c:	7b02                	ld	s6,32(sp)
    207e:	6be2                	ld	s7,24(sp)
    2080:	6c42                	ld	s8,16(sp)
    2082:	6ca2                	ld	s9,8(sp)
    2084:	6125                	addi	sp,sp,96
    2086:	8082                	ret
    exit(0);
    2088:	4501                	li	a0,0
    208a:	00004097          	auipc	ra,0x4
    208e:	b3c080e7          	jalr	-1220(ra) # 5bc6 <exit>

0000000000002092 <forktest>:
{
    2092:	7179                	addi	sp,sp,-48
    2094:	f406                	sd	ra,40(sp)
    2096:	f022                	sd	s0,32(sp)
    2098:	ec26                	sd	s1,24(sp)
    209a:	e84a                	sd	s2,16(sp)
    209c:	e44e                	sd	s3,8(sp)
    209e:	1800                	addi	s0,sp,48
    20a0:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    20a2:	4481                	li	s1,0
    20a4:	3e800913          	li	s2,1000
    pid = fork();
    20a8:	00004097          	auipc	ra,0x4
    20ac:	b16080e7          	jalr	-1258(ra) # 5bbe <fork>
    if(pid < 0)
    20b0:	02054863          	bltz	a0,20e0 <forktest+0x4e>
    if(pid == 0)
    20b4:	c115                	beqz	a0,20d8 <forktest+0x46>
  for(n=0; n<N; n++){
    20b6:	2485                	addiw	s1,s1,1
    20b8:	ff2498e3          	bne	s1,s2,20a8 <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    20bc:	85ce                	mv	a1,s3
    20be:	00005517          	auipc	a0,0x5
    20c2:	b8a50513          	addi	a0,a0,-1142 # 6c48 <malloc+0xc44>
    20c6:	00004097          	auipc	ra,0x4
    20ca:	e80080e7          	jalr	-384(ra) # 5f46 <printf>
    exit(1);
    20ce:	4505                	li	a0,1
    20d0:	00004097          	auipc	ra,0x4
    20d4:	af6080e7          	jalr	-1290(ra) # 5bc6 <exit>
      exit(0);
    20d8:	00004097          	auipc	ra,0x4
    20dc:	aee080e7          	jalr	-1298(ra) # 5bc6 <exit>
  if (n == 0) {
    20e0:	cc9d                	beqz	s1,211e <forktest+0x8c>
  if(n == N){
    20e2:	3e800793          	li	a5,1000
    20e6:	fcf48be3          	beq	s1,a5,20bc <forktest+0x2a>
  for(; n > 0; n--){
    20ea:	00905b63          	blez	s1,2100 <forktest+0x6e>
    if(wait(0) < 0){
    20ee:	4501                	li	a0,0
    20f0:	00004097          	auipc	ra,0x4
    20f4:	ade080e7          	jalr	-1314(ra) # 5bce <wait>
    20f8:	04054163          	bltz	a0,213a <forktest+0xa8>
  for(; n > 0; n--){
    20fc:	34fd                	addiw	s1,s1,-1
    20fe:	f8e5                	bnez	s1,20ee <forktest+0x5c>
  if(wait(0) != -1){
    2100:	4501                	li	a0,0
    2102:	00004097          	auipc	ra,0x4
    2106:	acc080e7          	jalr	-1332(ra) # 5bce <wait>
    210a:	57fd                	li	a5,-1
    210c:	04f51563          	bne	a0,a5,2156 <forktest+0xc4>
}
    2110:	70a2                	ld	ra,40(sp)
    2112:	7402                	ld	s0,32(sp)
    2114:	64e2                	ld	s1,24(sp)
    2116:	6942                	ld	s2,16(sp)
    2118:	69a2                	ld	s3,8(sp)
    211a:	6145                	addi	sp,sp,48
    211c:	8082                	ret
    printf("%s: no fork at all!\n", s);
    211e:	85ce                	mv	a1,s3
    2120:	00005517          	auipc	a0,0x5
    2124:	b1050513          	addi	a0,a0,-1264 # 6c30 <malloc+0xc2c>
    2128:	00004097          	auipc	ra,0x4
    212c:	e1e080e7          	jalr	-482(ra) # 5f46 <printf>
    exit(1);
    2130:	4505                	li	a0,1
    2132:	00004097          	auipc	ra,0x4
    2136:	a94080e7          	jalr	-1388(ra) # 5bc6 <exit>
      printf("%s: wait stopped early\n", s);
    213a:	85ce                	mv	a1,s3
    213c:	00005517          	auipc	a0,0x5
    2140:	b3450513          	addi	a0,a0,-1228 # 6c70 <malloc+0xc6c>
    2144:	00004097          	auipc	ra,0x4
    2148:	e02080e7          	jalr	-510(ra) # 5f46 <printf>
      exit(1);
    214c:	4505                	li	a0,1
    214e:	00004097          	auipc	ra,0x4
    2152:	a78080e7          	jalr	-1416(ra) # 5bc6 <exit>
    printf("%s: wait got too many\n", s);
    2156:	85ce                	mv	a1,s3
    2158:	00005517          	auipc	a0,0x5
    215c:	b3050513          	addi	a0,a0,-1232 # 6c88 <malloc+0xc84>
    2160:	00004097          	auipc	ra,0x4
    2164:	de6080e7          	jalr	-538(ra) # 5f46 <printf>
    exit(1);
    2168:	4505                	li	a0,1
    216a:	00004097          	auipc	ra,0x4
    216e:	a5c080e7          	jalr	-1444(ra) # 5bc6 <exit>

0000000000002172 <kernmem>:
{
    2172:	715d                	addi	sp,sp,-80
    2174:	e486                	sd	ra,72(sp)
    2176:	e0a2                	sd	s0,64(sp)
    2178:	fc26                	sd	s1,56(sp)
    217a:	f84a                	sd	s2,48(sp)
    217c:	f44e                	sd	s3,40(sp)
    217e:	f052                	sd	s4,32(sp)
    2180:	ec56                	sd	s5,24(sp)
    2182:	0880                	addi	s0,sp,80
    2184:	8a2a                	mv	s4,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    2186:	4485                	li	s1,1
    2188:	04fe                	slli	s1,s1,0x1f
    if(xstatus != -1)  // did kernel kill child?
    218a:	5afd                	li	s5,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    218c:	69b1                	lui	s3,0xc
    218e:	35098993          	addi	s3,s3,848 # c350 <uninit+0x1de8>
    2192:	1003d937          	lui	s2,0x1003d
    2196:	090e                	slli	s2,s2,0x3
    2198:	48090913          	addi	s2,s2,1152 # 1003d480 <base+0x1002d808>
    pid = fork();
    219c:	00004097          	auipc	ra,0x4
    21a0:	a22080e7          	jalr	-1502(ra) # 5bbe <fork>
    if(pid < 0){
    21a4:	02054963          	bltz	a0,21d6 <kernmem+0x64>
    if(pid == 0){
    21a8:	c529                	beqz	a0,21f2 <kernmem+0x80>
    wait(&xstatus);
    21aa:	fbc40513          	addi	a0,s0,-68
    21ae:	00004097          	auipc	ra,0x4
    21b2:	a20080e7          	jalr	-1504(ra) # 5bce <wait>
    if(xstatus != -1)  // did kernel kill child?
    21b6:	fbc42783          	lw	a5,-68(s0)
    21ba:	05579d63          	bne	a5,s5,2214 <kernmem+0xa2>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    21be:	94ce                	add	s1,s1,s3
    21c0:	fd249ee3          	bne	s1,s2,219c <kernmem+0x2a>
}
    21c4:	60a6                	ld	ra,72(sp)
    21c6:	6406                	ld	s0,64(sp)
    21c8:	74e2                	ld	s1,56(sp)
    21ca:	7942                	ld	s2,48(sp)
    21cc:	79a2                	ld	s3,40(sp)
    21ce:	7a02                	ld	s4,32(sp)
    21d0:	6ae2                	ld	s5,24(sp)
    21d2:	6161                	addi	sp,sp,80
    21d4:	8082                	ret
      printf("%s: fork failed\n", s);
    21d6:	85d2                	mv	a1,s4
    21d8:	00004517          	auipc	a0,0x4
    21dc:	7f850513          	addi	a0,a0,2040 # 69d0 <malloc+0x9cc>
    21e0:	00004097          	auipc	ra,0x4
    21e4:	d66080e7          	jalr	-666(ra) # 5f46 <printf>
      exit(1);
    21e8:	4505                	li	a0,1
    21ea:	00004097          	auipc	ra,0x4
    21ee:	9dc080e7          	jalr	-1572(ra) # 5bc6 <exit>
      printf("%s: oops could read %x = %x\n", s, a, *a);
    21f2:	0004c683          	lbu	a3,0(s1)
    21f6:	8626                	mv	a2,s1
    21f8:	85d2                	mv	a1,s4
    21fa:	00005517          	auipc	a0,0x5
    21fe:	aa650513          	addi	a0,a0,-1370 # 6ca0 <malloc+0xc9c>
    2202:	00004097          	auipc	ra,0x4
    2206:	d44080e7          	jalr	-700(ra) # 5f46 <printf>
      exit(1);
    220a:	4505                	li	a0,1
    220c:	00004097          	auipc	ra,0x4
    2210:	9ba080e7          	jalr	-1606(ra) # 5bc6 <exit>
      exit(1);
    2214:	4505                	li	a0,1
    2216:	00004097          	auipc	ra,0x4
    221a:	9b0080e7          	jalr	-1616(ra) # 5bc6 <exit>

000000000000221e <MAXVAplus>:
{
    221e:	7179                	addi	sp,sp,-48
    2220:	f406                	sd	ra,40(sp)
    2222:	f022                	sd	s0,32(sp)
    2224:	ec26                	sd	s1,24(sp)
    2226:	e84a                	sd	s2,16(sp)
    2228:	1800                	addi	s0,sp,48
  volatile uint64 a = MAXVA;
    222a:	4785                	li	a5,1
    222c:	179a                	slli	a5,a5,0x26
    222e:	fcf43c23          	sd	a5,-40(s0)
  for( ; a != 0; a <<= 1){
    2232:	fd843783          	ld	a5,-40(s0)
    2236:	cf85                	beqz	a5,226e <MAXVAplus+0x50>
    2238:	892a                	mv	s2,a0
    if(xstatus != -1)  // did kernel kill child?
    223a:	54fd                	li	s1,-1
    pid = fork();
    223c:	00004097          	auipc	ra,0x4
    2240:	982080e7          	jalr	-1662(ra) # 5bbe <fork>
    if(pid < 0){
    2244:	02054b63          	bltz	a0,227a <MAXVAplus+0x5c>
    if(pid == 0){
    2248:	c539                	beqz	a0,2296 <MAXVAplus+0x78>
    wait(&xstatus);
    224a:	fd440513          	addi	a0,s0,-44
    224e:	00004097          	auipc	ra,0x4
    2252:	980080e7          	jalr	-1664(ra) # 5bce <wait>
    if(xstatus != -1)  // did kernel kill child?
    2256:	fd442783          	lw	a5,-44(s0)
    225a:	06979463          	bne	a5,s1,22c2 <MAXVAplus+0xa4>
  for( ; a != 0; a <<= 1){
    225e:	fd843783          	ld	a5,-40(s0)
    2262:	0786                	slli	a5,a5,0x1
    2264:	fcf43c23          	sd	a5,-40(s0)
    2268:	fd843783          	ld	a5,-40(s0)
    226c:	fbe1                	bnez	a5,223c <MAXVAplus+0x1e>
}
    226e:	70a2                	ld	ra,40(sp)
    2270:	7402                	ld	s0,32(sp)
    2272:	64e2                	ld	s1,24(sp)
    2274:	6942                	ld	s2,16(sp)
    2276:	6145                	addi	sp,sp,48
    2278:	8082                	ret
      printf("%s: fork failed\n", s);
    227a:	85ca                	mv	a1,s2
    227c:	00004517          	auipc	a0,0x4
    2280:	75450513          	addi	a0,a0,1876 # 69d0 <malloc+0x9cc>
    2284:	00004097          	auipc	ra,0x4
    2288:	cc2080e7          	jalr	-830(ra) # 5f46 <printf>
      exit(1);
    228c:	4505                	li	a0,1
    228e:	00004097          	auipc	ra,0x4
    2292:	938080e7          	jalr	-1736(ra) # 5bc6 <exit>
      *(char*)a = 99;
    2296:	fd843783          	ld	a5,-40(s0)
    229a:	06300713          	li	a4,99
    229e:	00e78023          	sb	a4,0(a5)
      printf("%s: oops wrote %x\n", s, a);
    22a2:	fd843603          	ld	a2,-40(s0)
    22a6:	85ca                	mv	a1,s2
    22a8:	00005517          	auipc	a0,0x5
    22ac:	a1850513          	addi	a0,a0,-1512 # 6cc0 <malloc+0xcbc>
    22b0:	00004097          	auipc	ra,0x4
    22b4:	c96080e7          	jalr	-874(ra) # 5f46 <printf>
      exit(1);
    22b8:	4505                	li	a0,1
    22ba:	00004097          	auipc	ra,0x4
    22be:	90c080e7          	jalr	-1780(ra) # 5bc6 <exit>
      exit(1);
    22c2:	4505                	li	a0,1
    22c4:	00004097          	auipc	ra,0x4
    22c8:	902080e7          	jalr	-1790(ra) # 5bc6 <exit>

00000000000022cc <bigargtest>:
{
    22cc:	7179                	addi	sp,sp,-48
    22ce:	f406                	sd	ra,40(sp)
    22d0:	f022                	sd	s0,32(sp)
    22d2:	ec26                	sd	s1,24(sp)
    22d4:	1800                	addi	s0,sp,48
    22d6:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    22d8:	00005517          	auipc	a0,0x5
    22dc:	a0050513          	addi	a0,a0,-1536 # 6cd8 <malloc+0xcd4>
    22e0:	00004097          	auipc	ra,0x4
    22e4:	936080e7          	jalr	-1738(ra) # 5c16 <unlink>
  pid = fork();
    22e8:	00004097          	auipc	ra,0x4
    22ec:	8d6080e7          	jalr	-1834(ra) # 5bbe <fork>
  if(pid == 0){
    22f0:	c121                	beqz	a0,2330 <bigargtest+0x64>
  } else if(pid < 0){
    22f2:	0a054063          	bltz	a0,2392 <bigargtest+0xc6>
  wait(&xstatus);
    22f6:	fdc40513          	addi	a0,s0,-36
    22fa:	00004097          	auipc	ra,0x4
    22fe:	8d4080e7          	jalr	-1836(ra) # 5bce <wait>
  if(xstatus != 0)
    2302:	fdc42503          	lw	a0,-36(s0)
    2306:	e545                	bnez	a0,23ae <bigargtest+0xe2>
  fd = open("bigarg-ok", 0);
    2308:	4581                	li	a1,0
    230a:	00005517          	auipc	a0,0x5
    230e:	9ce50513          	addi	a0,a0,-1586 # 6cd8 <malloc+0xcd4>
    2312:	00004097          	auipc	ra,0x4
    2316:	8f4080e7          	jalr	-1804(ra) # 5c06 <open>
  if(fd < 0){
    231a:	08054e63          	bltz	a0,23b6 <bigargtest+0xea>
  close(fd);
    231e:	00004097          	auipc	ra,0x4
    2322:	8d0080e7          	jalr	-1840(ra) # 5bee <close>
}
    2326:	70a2                	ld	ra,40(sp)
    2328:	7402                	ld	s0,32(sp)
    232a:	64e2                	ld	s1,24(sp)
    232c:	6145                	addi	sp,sp,48
    232e:	8082                	ret
    2330:	00007797          	auipc	a5,0x7
    2334:	13078793          	addi	a5,a5,304 # 9460 <args.1>
    2338:	00007697          	auipc	a3,0x7
    233c:	22068693          	addi	a3,a3,544 # 9558 <args.1+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    2340:	00005717          	auipc	a4,0x5
    2344:	9a870713          	addi	a4,a4,-1624 # 6ce8 <malloc+0xce4>
    2348:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    234a:	07a1                	addi	a5,a5,8
    234c:	fed79ee3          	bne	a5,a3,2348 <bigargtest+0x7c>
    args[MAXARG-1] = 0;
    2350:	00007597          	auipc	a1,0x7
    2354:	11058593          	addi	a1,a1,272 # 9460 <args.1>
    2358:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    235c:	00004517          	auipc	a0,0x4
    2360:	dec50513          	addi	a0,a0,-532 # 6148 <malloc+0x144>
    2364:	00004097          	auipc	ra,0x4
    2368:	89a080e7          	jalr	-1894(ra) # 5bfe <exec>
    fd = open("bigarg-ok", O_CREATE);
    236c:	20000593          	li	a1,512
    2370:	00005517          	auipc	a0,0x5
    2374:	96850513          	addi	a0,a0,-1688 # 6cd8 <malloc+0xcd4>
    2378:	00004097          	auipc	ra,0x4
    237c:	88e080e7          	jalr	-1906(ra) # 5c06 <open>
    close(fd);
    2380:	00004097          	auipc	ra,0x4
    2384:	86e080e7          	jalr	-1938(ra) # 5bee <close>
    exit(0);
    2388:	4501                	li	a0,0
    238a:	00004097          	auipc	ra,0x4
    238e:	83c080e7          	jalr	-1988(ra) # 5bc6 <exit>
    printf("%s: bigargtest: fork failed\n", s);
    2392:	85a6                	mv	a1,s1
    2394:	00005517          	auipc	a0,0x5
    2398:	a3450513          	addi	a0,a0,-1484 # 6dc8 <malloc+0xdc4>
    239c:	00004097          	auipc	ra,0x4
    23a0:	baa080e7          	jalr	-1110(ra) # 5f46 <printf>
    exit(1);
    23a4:	4505                	li	a0,1
    23a6:	00004097          	auipc	ra,0x4
    23aa:	820080e7          	jalr	-2016(ra) # 5bc6 <exit>
    exit(xstatus);
    23ae:	00004097          	auipc	ra,0x4
    23b2:	818080e7          	jalr	-2024(ra) # 5bc6 <exit>
    printf("%s: bigarg test failed!\n", s);
    23b6:	85a6                	mv	a1,s1
    23b8:	00005517          	auipc	a0,0x5
    23bc:	a3050513          	addi	a0,a0,-1488 # 6de8 <malloc+0xde4>
    23c0:	00004097          	auipc	ra,0x4
    23c4:	b86080e7          	jalr	-1146(ra) # 5f46 <printf>
    exit(1);
    23c8:	4505                	li	a0,1
    23ca:	00003097          	auipc	ra,0x3
    23ce:	7fc080e7          	jalr	2044(ra) # 5bc6 <exit>

00000000000023d2 <stacktest>:
{
    23d2:	7179                	addi	sp,sp,-48
    23d4:	f406                	sd	ra,40(sp)
    23d6:	f022                	sd	s0,32(sp)
    23d8:	ec26                	sd	s1,24(sp)
    23da:	1800                	addi	s0,sp,48
    23dc:	84aa                	mv	s1,a0
  pid = fork();
    23de:	00003097          	auipc	ra,0x3
    23e2:	7e0080e7          	jalr	2016(ra) # 5bbe <fork>
  if(pid == 0) {
    23e6:	c115                	beqz	a0,240a <stacktest+0x38>
  } else if(pid < 0){
    23e8:	04054463          	bltz	a0,2430 <stacktest+0x5e>
  wait(&xstatus);
    23ec:	fdc40513          	addi	a0,s0,-36
    23f0:	00003097          	auipc	ra,0x3
    23f4:	7de080e7          	jalr	2014(ra) # 5bce <wait>
  if(xstatus == -1)  // kernel killed child?
    23f8:	fdc42503          	lw	a0,-36(s0)
    23fc:	57fd                	li	a5,-1
    23fe:	04f50763          	beq	a0,a5,244c <stacktest+0x7a>
    exit(xstatus);
    2402:	00003097          	auipc	ra,0x3
    2406:	7c4080e7          	jalr	1988(ra) # 5bc6 <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    240a:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", s, *sp);
    240c:	77fd                	lui	a5,0xfffff
    240e:	97ba                	add	a5,a5,a4
    2410:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <base+0xfffffffffffef388>
    2414:	85a6                	mv	a1,s1
    2416:	00005517          	auipc	a0,0x5
    241a:	9f250513          	addi	a0,a0,-1550 # 6e08 <malloc+0xe04>
    241e:	00004097          	auipc	ra,0x4
    2422:	b28080e7          	jalr	-1240(ra) # 5f46 <printf>
    exit(1);
    2426:	4505                	li	a0,1
    2428:	00003097          	auipc	ra,0x3
    242c:	79e080e7          	jalr	1950(ra) # 5bc6 <exit>
    printf("%s: fork failed\n", s);
    2430:	85a6                	mv	a1,s1
    2432:	00004517          	auipc	a0,0x4
    2436:	59e50513          	addi	a0,a0,1438 # 69d0 <malloc+0x9cc>
    243a:	00004097          	auipc	ra,0x4
    243e:	b0c080e7          	jalr	-1268(ra) # 5f46 <printf>
    exit(1);
    2442:	4505                	li	a0,1
    2444:	00003097          	auipc	ra,0x3
    2448:	782080e7          	jalr	1922(ra) # 5bc6 <exit>
    exit(0);
    244c:	4501                	li	a0,0
    244e:	00003097          	auipc	ra,0x3
    2452:	778080e7          	jalr	1912(ra) # 5bc6 <exit>

0000000000002456 <textwrite>:
{
    2456:	7179                	addi	sp,sp,-48
    2458:	f406                	sd	ra,40(sp)
    245a:	f022                	sd	s0,32(sp)
    245c:	ec26                	sd	s1,24(sp)
    245e:	1800                	addi	s0,sp,48
    2460:	84aa                	mv	s1,a0
  pid = fork();
    2462:	00003097          	auipc	ra,0x3
    2466:	75c080e7          	jalr	1884(ra) # 5bbe <fork>
  if(pid == 0) {
    246a:	c115                	beqz	a0,248e <textwrite+0x38>
  } else if(pid < 0){
    246c:	02054963          	bltz	a0,249e <textwrite+0x48>
  wait(&xstatus);
    2470:	fdc40513          	addi	a0,s0,-36
    2474:	00003097          	auipc	ra,0x3
    2478:	75a080e7          	jalr	1882(ra) # 5bce <wait>
  if(xstatus == -1)  // kernel killed child?
    247c:	fdc42503          	lw	a0,-36(s0)
    2480:	57fd                	li	a5,-1
    2482:	02f50c63          	beq	a0,a5,24ba <textwrite+0x64>
    exit(xstatus);
    2486:	00003097          	auipc	ra,0x3
    248a:	740080e7          	jalr	1856(ra) # 5bc6 <exit>
    *addr = 10;
    248e:	47a9                	li	a5,10
    2490:	00f02023          	sw	a5,0(zero) # 0 <copyinstr1>
    exit(1);
    2494:	4505                	li	a0,1
    2496:	00003097          	auipc	ra,0x3
    249a:	730080e7          	jalr	1840(ra) # 5bc6 <exit>
    printf("%s: fork failed\n", s);
    249e:	85a6                	mv	a1,s1
    24a0:	00004517          	auipc	a0,0x4
    24a4:	53050513          	addi	a0,a0,1328 # 69d0 <malloc+0x9cc>
    24a8:	00004097          	auipc	ra,0x4
    24ac:	a9e080e7          	jalr	-1378(ra) # 5f46 <printf>
    exit(1);
    24b0:	4505                	li	a0,1
    24b2:	00003097          	auipc	ra,0x3
    24b6:	714080e7          	jalr	1812(ra) # 5bc6 <exit>
    exit(0);
    24ba:	4501                	li	a0,0
    24bc:	00003097          	auipc	ra,0x3
    24c0:	70a080e7          	jalr	1802(ra) # 5bc6 <exit>

00000000000024c4 <manywrites>:
{
    24c4:	711d                	addi	sp,sp,-96
    24c6:	ec86                	sd	ra,88(sp)
    24c8:	e8a2                	sd	s0,80(sp)
    24ca:	e4a6                	sd	s1,72(sp)
    24cc:	e0ca                	sd	s2,64(sp)
    24ce:	fc4e                	sd	s3,56(sp)
    24d0:	f852                	sd	s4,48(sp)
    24d2:	f456                	sd	s5,40(sp)
    24d4:	f05a                	sd	s6,32(sp)
    24d6:	ec5e                	sd	s7,24(sp)
    24d8:	1080                	addi	s0,sp,96
    24da:	8aaa                	mv	s5,a0
  for(int ci = 0; ci < nchildren; ci++){
    24dc:	4981                	li	s3,0
    24de:	4911                	li	s2,4
    int pid = fork();
    24e0:	00003097          	auipc	ra,0x3
    24e4:	6de080e7          	jalr	1758(ra) # 5bbe <fork>
    24e8:	84aa                	mv	s1,a0
    if(pid < 0){
    24ea:	02054963          	bltz	a0,251c <manywrites+0x58>
    if(pid == 0){
    24ee:	c521                	beqz	a0,2536 <manywrites+0x72>
  for(int ci = 0; ci < nchildren; ci++){
    24f0:	2985                	addiw	s3,s3,1
    24f2:	ff2997e3          	bne	s3,s2,24e0 <manywrites+0x1c>
    24f6:	4491                	li	s1,4
    int st = 0;
    24f8:	fa042423          	sw	zero,-88(s0)
    wait(&st);
    24fc:	fa840513          	addi	a0,s0,-88
    2500:	00003097          	auipc	ra,0x3
    2504:	6ce080e7          	jalr	1742(ra) # 5bce <wait>
    if(st != 0)
    2508:	fa842503          	lw	a0,-88(s0)
    250c:	ed6d                	bnez	a0,2606 <manywrites+0x142>
  for(int ci = 0; ci < nchildren; ci++){
    250e:	34fd                	addiw	s1,s1,-1
    2510:	f4e5                	bnez	s1,24f8 <manywrites+0x34>
  exit(0);
    2512:	4501                	li	a0,0
    2514:	00003097          	auipc	ra,0x3
    2518:	6b2080e7          	jalr	1714(ra) # 5bc6 <exit>
      printf("fork failed\n");
    251c:	00005517          	auipc	a0,0x5
    2520:	8bc50513          	addi	a0,a0,-1860 # 6dd8 <malloc+0xdd4>
    2524:	00004097          	auipc	ra,0x4
    2528:	a22080e7          	jalr	-1502(ra) # 5f46 <printf>
      exit(1);
    252c:	4505                	li	a0,1
    252e:	00003097          	auipc	ra,0x3
    2532:	698080e7          	jalr	1688(ra) # 5bc6 <exit>
      name[0] = 'b';
    2536:	06200793          	li	a5,98
    253a:	faf40423          	sb	a5,-88(s0)
      name[1] = 'a' + ci;
    253e:	0619879b          	addiw	a5,s3,97
    2542:	faf404a3          	sb	a5,-87(s0)
      name[2] = '\0';
    2546:	fa040523          	sb	zero,-86(s0)
      unlink(name);
    254a:	fa840513          	addi	a0,s0,-88
    254e:	00003097          	auipc	ra,0x3
    2552:	6c8080e7          	jalr	1736(ra) # 5c16 <unlink>
    2556:	4bf9                	li	s7,30
          int cc = write(fd, buf, sz);
    2558:	0000ab17          	auipc	s6,0xa
    255c:	720b0b13          	addi	s6,s6,1824 # cc78 <buf>
        for(int i = 0; i < ci+1; i++){
    2560:	8a26                	mv	s4,s1
    2562:	0209ce63          	bltz	s3,259e <manywrites+0xda>
          int fd = open(name, O_CREATE | O_RDWR);
    2566:	20200593          	li	a1,514
    256a:	fa840513          	addi	a0,s0,-88
    256e:	00003097          	auipc	ra,0x3
    2572:	698080e7          	jalr	1688(ra) # 5c06 <open>
    2576:	892a                	mv	s2,a0
          if(fd < 0){
    2578:	04054763          	bltz	a0,25c6 <manywrites+0x102>
          int cc = write(fd, buf, sz);
    257c:	660d                	lui	a2,0x3
    257e:	85da                	mv	a1,s6
    2580:	00003097          	auipc	ra,0x3
    2584:	666080e7          	jalr	1638(ra) # 5be6 <write>
          if(cc != sz){
    2588:	678d                	lui	a5,0x3
    258a:	04f51e63          	bne	a0,a5,25e6 <manywrites+0x122>
          close(fd);
    258e:	854a                	mv	a0,s2
    2590:	00003097          	auipc	ra,0x3
    2594:	65e080e7          	jalr	1630(ra) # 5bee <close>
        for(int i = 0; i < ci+1; i++){
    2598:	2a05                	addiw	s4,s4,1
    259a:	fd49d6e3          	bge	s3,s4,2566 <manywrites+0xa2>
        unlink(name);
    259e:	fa840513          	addi	a0,s0,-88
    25a2:	00003097          	auipc	ra,0x3
    25a6:	674080e7          	jalr	1652(ra) # 5c16 <unlink>
      for(int iters = 0; iters < howmany; iters++){
    25aa:	3bfd                	addiw	s7,s7,-1
    25ac:	fa0b9ae3          	bnez	s7,2560 <manywrites+0x9c>
      unlink(name);
    25b0:	fa840513          	addi	a0,s0,-88
    25b4:	00003097          	auipc	ra,0x3
    25b8:	662080e7          	jalr	1634(ra) # 5c16 <unlink>
      exit(0);
    25bc:	4501                	li	a0,0
    25be:	00003097          	auipc	ra,0x3
    25c2:	608080e7          	jalr	1544(ra) # 5bc6 <exit>
            printf("%s: cannot create %s\n", s, name);
    25c6:	fa840613          	addi	a2,s0,-88
    25ca:	85d6                	mv	a1,s5
    25cc:	00005517          	auipc	a0,0x5
    25d0:	86450513          	addi	a0,a0,-1948 # 6e30 <malloc+0xe2c>
    25d4:	00004097          	auipc	ra,0x4
    25d8:	972080e7          	jalr	-1678(ra) # 5f46 <printf>
            exit(1);
    25dc:	4505                	li	a0,1
    25de:	00003097          	auipc	ra,0x3
    25e2:	5e8080e7          	jalr	1512(ra) # 5bc6 <exit>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
    25e6:	86aa                	mv	a3,a0
    25e8:	660d                	lui	a2,0x3
    25ea:	85d6                	mv	a1,s5
    25ec:	00004517          	auipc	a0,0x4
    25f0:	c2c50513          	addi	a0,a0,-980 # 6218 <malloc+0x214>
    25f4:	00004097          	auipc	ra,0x4
    25f8:	952080e7          	jalr	-1710(ra) # 5f46 <printf>
            exit(1);
    25fc:	4505                	li	a0,1
    25fe:	00003097          	auipc	ra,0x3
    2602:	5c8080e7          	jalr	1480(ra) # 5bc6 <exit>
      exit(st);
    2606:	00003097          	auipc	ra,0x3
    260a:	5c0080e7          	jalr	1472(ra) # 5bc6 <exit>

000000000000260e <copyinstr3>:
{
    260e:	7179                	addi	sp,sp,-48
    2610:	f406                	sd	ra,40(sp)
    2612:	f022                	sd	s0,32(sp)
    2614:	ec26                	sd	s1,24(sp)
    2616:	1800                	addi	s0,sp,48
  sbrk(8192);
    2618:	6509                	lui	a0,0x2
    261a:	00003097          	auipc	ra,0x3
    261e:	634080e7          	jalr	1588(ra) # 5c4e <sbrk>
  uint64 top = (uint64) sbrk(0);
    2622:	4501                	li	a0,0
    2624:	00003097          	auipc	ra,0x3
    2628:	62a080e7          	jalr	1578(ra) # 5c4e <sbrk>
  if((top % PGSIZE) != 0){
    262c:	03451793          	slli	a5,a0,0x34
    2630:	e3c9                	bnez	a5,26b2 <copyinstr3+0xa4>
  top = (uint64) sbrk(0);
    2632:	4501                	li	a0,0
    2634:	00003097          	auipc	ra,0x3
    2638:	61a080e7          	jalr	1562(ra) # 5c4e <sbrk>
  if(top % PGSIZE){
    263c:	03451793          	slli	a5,a0,0x34
    2640:	e3d9                	bnez	a5,26c6 <copyinstr3+0xb8>
  char *b = (char *) (top - 1);
    2642:	fff50493          	addi	s1,a0,-1 # 1fff <linkunlink+0x6f>
  *b = 'x';
    2646:	07800793          	li	a5,120
    264a:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    264e:	8526                	mv	a0,s1
    2650:	00003097          	auipc	ra,0x3
    2654:	5c6080e7          	jalr	1478(ra) # 5c16 <unlink>
  if(ret != -1){
    2658:	57fd                	li	a5,-1
    265a:	08f51363          	bne	a0,a5,26e0 <copyinstr3+0xd2>
  int fd = open(b, O_CREATE | O_WRONLY);
    265e:	20100593          	li	a1,513
    2662:	8526                	mv	a0,s1
    2664:	00003097          	auipc	ra,0x3
    2668:	5a2080e7          	jalr	1442(ra) # 5c06 <open>
  if(fd != -1){
    266c:	57fd                	li	a5,-1
    266e:	08f51863          	bne	a0,a5,26fe <copyinstr3+0xf0>
  ret = link(b, b);
    2672:	85a6                	mv	a1,s1
    2674:	8526                	mv	a0,s1
    2676:	00003097          	auipc	ra,0x3
    267a:	5b0080e7          	jalr	1456(ra) # 5c26 <link>
  if(ret != -1){
    267e:	57fd                	li	a5,-1
    2680:	08f51e63          	bne	a0,a5,271c <copyinstr3+0x10e>
  char *args[] = { "xx", 0 };
    2684:	00005797          	auipc	a5,0x5
    2688:	4a478793          	addi	a5,a5,1188 # 7b28 <malloc+0x1b24>
    268c:	fcf43823          	sd	a5,-48(s0)
    2690:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    2694:	fd040593          	addi	a1,s0,-48
    2698:	8526                	mv	a0,s1
    269a:	00003097          	auipc	ra,0x3
    269e:	564080e7          	jalr	1380(ra) # 5bfe <exec>
  if(ret != -1){
    26a2:	57fd                	li	a5,-1
    26a4:	08f51c63          	bne	a0,a5,273c <copyinstr3+0x12e>
}
    26a8:	70a2                	ld	ra,40(sp)
    26aa:	7402                	ld	s0,32(sp)
    26ac:	64e2                	ld	s1,24(sp)
    26ae:	6145                	addi	sp,sp,48
    26b0:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    26b2:	0347d513          	srli	a0,a5,0x34
    26b6:	6785                	lui	a5,0x1
    26b8:	40a7853b          	subw	a0,a5,a0
    26bc:	00003097          	auipc	ra,0x3
    26c0:	592080e7          	jalr	1426(ra) # 5c4e <sbrk>
    26c4:	b7bd                	j	2632 <copyinstr3+0x24>
    printf("oops\n");
    26c6:	00004517          	auipc	a0,0x4
    26ca:	78250513          	addi	a0,a0,1922 # 6e48 <malloc+0xe44>
    26ce:	00004097          	auipc	ra,0x4
    26d2:	878080e7          	jalr	-1928(ra) # 5f46 <printf>
    exit(1);
    26d6:	4505                	li	a0,1
    26d8:	00003097          	auipc	ra,0x3
    26dc:	4ee080e7          	jalr	1262(ra) # 5bc6 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    26e0:	862a                	mv	a2,a0
    26e2:	85a6                	mv	a1,s1
    26e4:	00004517          	auipc	a0,0x4
    26e8:	20c50513          	addi	a0,a0,524 # 68f0 <malloc+0x8ec>
    26ec:	00004097          	auipc	ra,0x4
    26f0:	85a080e7          	jalr	-1958(ra) # 5f46 <printf>
    exit(1);
    26f4:	4505                	li	a0,1
    26f6:	00003097          	auipc	ra,0x3
    26fa:	4d0080e7          	jalr	1232(ra) # 5bc6 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    26fe:	862a                	mv	a2,a0
    2700:	85a6                	mv	a1,s1
    2702:	00004517          	auipc	a0,0x4
    2706:	20e50513          	addi	a0,a0,526 # 6910 <malloc+0x90c>
    270a:	00004097          	auipc	ra,0x4
    270e:	83c080e7          	jalr	-1988(ra) # 5f46 <printf>
    exit(1);
    2712:	4505                	li	a0,1
    2714:	00003097          	auipc	ra,0x3
    2718:	4b2080e7          	jalr	1202(ra) # 5bc6 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    271c:	86aa                	mv	a3,a0
    271e:	8626                	mv	a2,s1
    2720:	85a6                	mv	a1,s1
    2722:	00004517          	auipc	a0,0x4
    2726:	20e50513          	addi	a0,a0,526 # 6930 <malloc+0x92c>
    272a:	00004097          	auipc	ra,0x4
    272e:	81c080e7          	jalr	-2020(ra) # 5f46 <printf>
    exit(1);
    2732:	4505                	li	a0,1
    2734:	00003097          	auipc	ra,0x3
    2738:	492080e7          	jalr	1170(ra) # 5bc6 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    273c:	567d                	li	a2,-1
    273e:	85a6                	mv	a1,s1
    2740:	00004517          	auipc	a0,0x4
    2744:	21850513          	addi	a0,a0,536 # 6958 <malloc+0x954>
    2748:	00003097          	auipc	ra,0x3
    274c:	7fe080e7          	jalr	2046(ra) # 5f46 <printf>
    exit(1);
    2750:	4505                	li	a0,1
    2752:	00003097          	auipc	ra,0x3
    2756:	474080e7          	jalr	1140(ra) # 5bc6 <exit>

000000000000275a <rwsbrk>:
{
    275a:	1101                	addi	sp,sp,-32
    275c:	ec06                	sd	ra,24(sp)
    275e:	e822                	sd	s0,16(sp)
    2760:	e426                	sd	s1,8(sp)
    2762:	e04a                	sd	s2,0(sp)
    2764:	1000                	addi	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
    2766:	6509                	lui	a0,0x2
    2768:	00003097          	auipc	ra,0x3
    276c:	4e6080e7          	jalr	1254(ra) # 5c4e <sbrk>
  if(a == 0xffffffffffffffffLL) {
    2770:	57fd                	li	a5,-1
    2772:	06f50363          	beq	a0,a5,27d8 <rwsbrk+0x7e>
    2776:	84aa                	mv	s1,a0
  if ((uint64) sbrk(-8192) ==  0xffffffffffffffffLL) {
    2778:	7579                	lui	a0,0xffffe
    277a:	00003097          	auipc	ra,0x3
    277e:	4d4080e7          	jalr	1236(ra) # 5c4e <sbrk>
    2782:	57fd                	li	a5,-1
    2784:	06f50763          	beq	a0,a5,27f2 <rwsbrk+0x98>
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
    2788:	20100593          	li	a1,513
    278c:	00004517          	auipc	a0,0x4
    2790:	6fc50513          	addi	a0,a0,1788 # 6e88 <malloc+0xe84>
    2794:	00003097          	auipc	ra,0x3
    2798:	472080e7          	jalr	1138(ra) # 5c06 <open>
    279c:	892a                	mv	s2,a0
  if(fd < 0){
    279e:	06054763          	bltz	a0,280c <rwsbrk+0xb2>
  n = write(fd, (void*)(a+4096), 1024);
    27a2:	6505                	lui	a0,0x1
    27a4:	94aa                	add	s1,s1,a0
    27a6:	40000613          	li	a2,1024
    27aa:	85a6                	mv	a1,s1
    27ac:	854a                	mv	a0,s2
    27ae:	00003097          	auipc	ra,0x3
    27b2:	438080e7          	jalr	1080(ra) # 5be6 <write>
    27b6:	862a                	mv	a2,a0
  if(n >= 0){
    27b8:	06054763          	bltz	a0,2826 <rwsbrk+0xcc>
    printf("write(fd, %p, 1024) returned %d, not -1\n", a+4096, n);
    27bc:	85a6                	mv	a1,s1
    27be:	00004517          	auipc	a0,0x4
    27c2:	6ea50513          	addi	a0,a0,1770 # 6ea8 <malloc+0xea4>
    27c6:	00003097          	auipc	ra,0x3
    27ca:	780080e7          	jalr	1920(ra) # 5f46 <printf>
    exit(1);
    27ce:	4505                	li	a0,1
    27d0:	00003097          	auipc	ra,0x3
    27d4:	3f6080e7          	jalr	1014(ra) # 5bc6 <exit>
    printf("sbrk(rwsbrk) failed\n");
    27d8:	00004517          	auipc	a0,0x4
    27dc:	67850513          	addi	a0,a0,1656 # 6e50 <malloc+0xe4c>
    27e0:	00003097          	auipc	ra,0x3
    27e4:	766080e7          	jalr	1894(ra) # 5f46 <printf>
    exit(1);
    27e8:	4505                	li	a0,1
    27ea:	00003097          	auipc	ra,0x3
    27ee:	3dc080e7          	jalr	988(ra) # 5bc6 <exit>
    printf("sbrk(rwsbrk) shrink failed\n");
    27f2:	00004517          	auipc	a0,0x4
    27f6:	67650513          	addi	a0,a0,1654 # 6e68 <malloc+0xe64>
    27fa:	00003097          	auipc	ra,0x3
    27fe:	74c080e7          	jalr	1868(ra) # 5f46 <printf>
    exit(1);
    2802:	4505                	li	a0,1
    2804:	00003097          	auipc	ra,0x3
    2808:	3c2080e7          	jalr	962(ra) # 5bc6 <exit>
    printf("open(rwsbrk) failed\n");
    280c:	00004517          	auipc	a0,0x4
    2810:	68450513          	addi	a0,a0,1668 # 6e90 <malloc+0xe8c>
    2814:	00003097          	auipc	ra,0x3
    2818:	732080e7          	jalr	1842(ra) # 5f46 <printf>
    exit(1);
    281c:	4505                	li	a0,1
    281e:	00003097          	auipc	ra,0x3
    2822:	3a8080e7          	jalr	936(ra) # 5bc6 <exit>
  close(fd);
    2826:	854a                	mv	a0,s2
    2828:	00003097          	auipc	ra,0x3
    282c:	3c6080e7          	jalr	966(ra) # 5bee <close>
  unlink("rwsbrk");
    2830:	00004517          	auipc	a0,0x4
    2834:	65850513          	addi	a0,a0,1624 # 6e88 <malloc+0xe84>
    2838:	00003097          	auipc	ra,0x3
    283c:	3de080e7          	jalr	990(ra) # 5c16 <unlink>
  fd = open("README", O_RDONLY);
    2840:	4581                	li	a1,0
    2842:	00004517          	auipc	a0,0x4
    2846:	ade50513          	addi	a0,a0,-1314 # 6320 <malloc+0x31c>
    284a:	00003097          	auipc	ra,0x3
    284e:	3bc080e7          	jalr	956(ra) # 5c06 <open>
    2852:	892a                	mv	s2,a0
  if(fd < 0){
    2854:	02054963          	bltz	a0,2886 <rwsbrk+0x12c>
  n = read(fd, (void*)(a+4096), 10);
    2858:	4629                	li	a2,10
    285a:	85a6                	mv	a1,s1
    285c:	00003097          	auipc	ra,0x3
    2860:	382080e7          	jalr	898(ra) # 5bde <read>
    2864:	862a                	mv	a2,a0
  if(n >= 0){
    2866:	02054d63          	bltz	a0,28a0 <rwsbrk+0x146>
    printf("read(fd, %p, 10) returned %d, not -1\n", a+4096, n);
    286a:	85a6                	mv	a1,s1
    286c:	00004517          	auipc	a0,0x4
    2870:	66c50513          	addi	a0,a0,1644 # 6ed8 <malloc+0xed4>
    2874:	00003097          	auipc	ra,0x3
    2878:	6d2080e7          	jalr	1746(ra) # 5f46 <printf>
    exit(1);
    287c:	4505                	li	a0,1
    287e:	00003097          	auipc	ra,0x3
    2882:	348080e7          	jalr	840(ra) # 5bc6 <exit>
    printf("open(rwsbrk) failed\n");
    2886:	00004517          	auipc	a0,0x4
    288a:	60a50513          	addi	a0,a0,1546 # 6e90 <malloc+0xe8c>
    288e:	00003097          	auipc	ra,0x3
    2892:	6b8080e7          	jalr	1720(ra) # 5f46 <printf>
    exit(1);
    2896:	4505                	li	a0,1
    2898:	00003097          	auipc	ra,0x3
    289c:	32e080e7          	jalr	814(ra) # 5bc6 <exit>
  close(fd);
    28a0:	854a                	mv	a0,s2
    28a2:	00003097          	auipc	ra,0x3
    28a6:	34c080e7          	jalr	844(ra) # 5bee <close>
  exit(0);
    28aa:	4501                	li	a0,0
    28ac:	00003097          	auipc	ra,0x3
    28b0:	31a080e7          	jalr	794(ra) # 5bc6 <exit>

00000000000028b4 <sbrkbasic>:
{
    28b4:	7139                	addi	sp,sp,-64
    28b6:	fc06                	sd	ra,56(sp)
    28b8:	f822                	sd	s0,48(sp)
    28ba:	f426                	sd	s1,40(sp)
    28bc:	f04a                	sd	s2,32(sp)
    28be:	ec4e                	sd	s3,24(sp)
    28c0:	e852                	sd	s4,16(sp)
    28c2:	0080                	addi	s0,sp,64
    28c4:	8a2a                	mv	s4,a0
  pid = fork();
    28c6:	00003097          	auipc	ra,0x3
    28ca:	2f8080e7          	jalr	760(ra) # 5bbe <fork>
  if(pid < 0){
    28ce:	02054c63          	bltz	a0,2906 <sbrkbasic+0x52>
  if(pid == 0){
    28d2:	ed21                	bnez	a0,292a <sbrkbasic+0x76>
    a = sbrk(TOOMUCH);
    28d4:	40000537          	lui	a0,0x40000
    28d8:	00003097          	auipc	ra,0x3
    28dc:	376080e7          	jalr	886(ra) # 5c4e <sbrk>
    if(a == (char*)0xffffffffffffffffL){
    28e0:	57fd                	li	a5,-1
    28e2:	02f50f63          	beq	a0,a5,2920 <sbrkbasic+0x6c>
    for(b = a; b < a+TOOMUCH; b += 4096){
    28e6:	400007b7          	lui	a5,0x40000
    28ea:	97aa                	add	a5,a5,a0
      *b = 99;
    28ec:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += 4096){
    28f0:	6705                	lui	a4,0x1
      *b = 99;
    28f2:	00d50023          	sb	a3,0(a0) # 40000000 <base+0x3fff0388>
    for(b = a; b < a+TOOMUCH; b += 4096){
    28f6:	953a                	add	a0,a0,a4
    28f8:	fef51de3          	bne	a0,a5,28f2 <sbrkbasic+0x3e>
    exit(1);
    28fc:	4505                	li	a0,1
    28fe:	00003097          	auipc	ra,0x3
    2902:	2c8080e7          	jalr	712(ra) # 5bc6 <exit>
    printf("fork failed in sbrkbasic\n");
    2906:	00004517          	auipc	a0,0x4
    290a:	5fa50513          	addi	a0,a0,1530 # 6f00 <malloc+0xefc>
    290e:	00003097          	auipc	ra,0x3
    2912:	638080e7          	jalr	1592(ra) # 5f46 <printf>
    exit(1);
    2916:	4505                	li	a0,1
    2918:	00003097          	auipc	ra,0x3
    291c:	2ae080e7          	jalr	686(ra) # 5bc6 <exit>
      exit(0);
    2920:	4501                	li	a0,0
    2922:	00003097          	auipc	ra,0x3
    2926:	2a4080e7          	jalr	676(ra) # 5bc6 <exit>
  wait(&xstatus);
    292a:	fcc40513          	addi	a0,s0,-52
    292e:	00003097          	auipc	ra,0x3
    2932:	2a0080e7          	jalr	672(ra) # 5bce <wait>
  if(xstatus == 1){
    2936:	fcc42703          	lw	a4,-52(s0)
    293a:	4785                	li	a5,1
    293c:	00f70d63          	beq	a4,a5,2956 <sbrkbasic+0xa2>
  a = sbrk(0);
    2940:	4501                	li	a0,0
    2942:	00003097          	auipc	ra,0x3
    2946:	30c080e7          	jalr	780(ra) # 5c4e <sbrk>
    294a:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    294c:	4901                	li	s2,0
    294e:	6985                	lui	s3,0x1
    2950:	38898993          	addi	s3,s3,904 # 1388 <badarg+0x3c>
    2954:	a005                	j	2974 <sbrkbasic+0xc0>
    printf("%s: too much memory allocated!\n", s);
    2956:	85d2                	mv	a1,s4
    2958:	00004517          	auipc	a0,0x4
    295c:	5c850513          	addi	a0,a0,1480 # 6f20 <malloc+0xf1c>
    2960:	00003097          	auipc	ra,0x3
    2964:	5e6080e7          	jalr	1510(ra) # 5f46 <printf>
    exit(1);
    2968:	4505                	li	a0,1
    296a:	00003097          	auipc	ra,0x3
    296e:	25c080e7          	jalr	604(ra) # 5bc6 <exit>
    a = b + 1;
    2972:	84be                	mv	s1,a5
    b = sbrk(1);
    2974:	4505                	li	a0,1
    2976:	00003097          	auipc	ra,0x3
    297a:	2d8080e7          	jalr	728(ra) # 5c4e <sbrk>
    if(b != a){
    297e:	04951c63          	bne	a0,s1,29d6 <sbrkbasic+0x122>
    *b = 1;
    2982:	4785                	li	a5,1
    2984:	00f48023          	sb	a5,0(s1)
    a = b + 1;
    2988:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    298c:	2905                	addiw	s2,s2,1
    298e:	ff3912e3          	bne	s2,s3,2972 <sbrkbasic+0xbe>
  pid = fork();
    2992:	00003097          	auipc	ra,0x3
    2996:	22c080e7          	jalr	556(ra) # 5bbe <fork>
    299a:	892a                	mv	s2,a0
  if(pid < 0){
    299c:	04054e63          	bltz	a0,29f8 <sbrkbasic+0x144>
  c = sbrk(1);
    29a0:	4505                	li	a0,1
    29a2:	00003097          	auipc	ra,0x3
    29a6:	2ac080e7          	jalr	684(ra) # 5c4e <sbrk>
  c = sbrk(1);
    29aa:	4505                	li	a0,1
    29ac:	00003097          	auipc	ra,0x3
    29b0:	2a2080e7          	jalr	674(ra) # 5c4e <sbrk>
  if(c != a + 1){
    29b4:	0489                	addi	s1,s1,2
    29b6:	04a48f63          	beq	s1,a0,2a14 <sbrkbasic+0x160>
    printf("%s: sbrk test failed post-fork\n", s);
    29ba:	85d2                	mv	a1,s4
    29bc:	00004517          	auipc	a0,0x4
    29c0:	5c450513          	addi	a0,a0,1476 # 6f80 <malloc+0xf7c>
    29c4:	00003097          	auipc	ra,0x3
    29c8:	582080e7          	jalr	1410(ra) # 5f46 <printf>
    exit(1);
    29cc:	4505                	li	a0,1
    29ce:	00003097          	auipc	ra,0x3
    29d2:	1f8080e7          	jalr	504(ra) # 5bc6 <exit>
      printf("%s: sbrk test failed %d %x %x\n", s, i, a, b);
    29d6:	872a                	mv	a4,a0
    29d8:	86a6                	mv	a3,s1
    29da:	864a                	mv	a2,s2
    29dc:	85d2                	mv	a1,s4
    29de:	00004517          	auipc	a0,0x4
    29e2:	56250513          	addi	a0,a0,1378 # 6f40 <malloc+0xf3c>
    29e6:	00003097          	auipc	ra,0x3
    29ea:	560080e7          	jalr	1376(ra) # 5f46 <printf>
      exit(1);
    29ee:	4505                	li	a0,1
    29f0:	00003097          	auipc	ra,0x3
    29f4:	1d6080e7          	jalr	470(ra) # 5bc6 <exit>
    printf("%s: sbrk test fork failed\n", s);
    29f8:	85d2                	mv	a1,s4
    29fa:	00004517          	auipc	a0,0x4
    29fe:	56650513          	addi	a0,a0,1382 # 6f60 <malloc+0xf5c>
    2a02:	00003097          	auipc	ra,0x3
    2a06:	544080e7          	jalr	1348(ra) # 5f46 <printf>
    exit(1);
    2a0a:	4505                	li	a0,1
    2a0c:	00003097          	auipc	ra,0x3
    2a10:	1ba080e7          	jalr	442(ra) # 5bc6 <exit>
  if(pid == 0)
    2a14:	00091763          	bnez	s2,2a22 <sbrkbasic+0x16e>
    exit(0);
    2a18:	4501                	li	a0,0
    2a1a:	00003097          	auipc	ra,0x3
    2a1e:	1ac080e7          	jalr	428(ra) # 5bc6 <exit>
  wait(&xstatus);
    2a22:	fcc40513          	addi	a0,s0,-52
    2a26:	00003097          	auipc	ra,0x3
    2a2a:	1a8080e7          	jalr	424(ra) # 5bce <wait>
  exit(xstatus);
    2a2e:	fcc42503          	lw	a0,-52(s0)
    2a32:	00003097          	auipc	ra,0x3
    2a36:	194080e7          	jalr	404(ra) # 5bc6 <exit>

0000000000002a3a <sbrkmuch>:
{
    2a3a:	7179                	addi	sp,sp,-48
    2a3c:	f406                	sd	ra,40(sp)
    2a3e:	f022                	sd	s0,32(sp)
    2a40:	ec26                	sd	s1,24(sp)
    2a42:	e84a                	sd	s2,16(sp)
    2a44:	e44e                	sd	s3,8(sp)
    2a46:	e052                	sd	s4,0(sp)
    2a48:	1800                	addi	s0,sp,48
    2a4a:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    2a4c:	4501                	li	a0,0
    2a4e:	00003097          	auipc	ra,0x3
    2a52:	200080e7          	jalr	512(ra) # 5c4e <sbrk>
    2a56:	892a                	mv	s2,a0
  a = sbrk(0);
    2a58:	4501                	li	a0,0
    2a5a:	00003097          	auipc	ra,0x3
    2a5e:	1f4080e7          	jalr	500(ra) # 5c4e <sbrk>
    2a62:	84aa                	mv	s1,a0
  p = sbrk(amt);
    2a64:	06400537          	lui	a0,0x6400
    2a68:	9d05                	subw	a0,a0,s1
    2a6a:	00003097          	auipc	ra,0x3
    2a6e:	1e4080e7          	jalr	484(ra) # 5c4e <sbrk>
  if (p != a) {
    2a72:	0ca49863          	bne	s1,a0,2b42 <sbrkmuch+0x108>
  char *eee = sbrk(0);
    2a76:	4501                	li	a0,0
    2a78:	00003097          	auipc	ra,0x3
    2a7c:	1d6080e7          	jalr	470(ra) # 5c4e <sbrk>
    2a80:	87aa                	mv	a5,a0
  for(char *pp = a; pp < eee; pp += 4096)
    2a82:	00a4f963          	bgeu	s1,a0,2a94 <sbrkmuch+0x5a>
    *pp = 1;
    2a86:	4685                	li	a3,1
  for(char *pp = a; pp < eee; pp += 4096)
    2a88:	6705                	lui	a4,0x1
    *pp = 1;
    2a8a:	00d48023          	sb	a3,0(s1)
  for(char *pp = a; pp < eee; pp += 4096)
    2a8e:	94ba                	add	s1,s1,a4
    2a90:	fef4ede3          	bltu	s1,a5,2a8a <sbrkmuch+0x50>
  *lastaddr = 99;
    2a94:	064007b7          	lui	a5,0x6400
    2a98:	06300713          	li	a4,99
    2a9c:	fee78fa3          	sb	a4,-1(a5) # 63fffff <base+0x63f0387>
  a = sbrk(0);
    2aa0:	4501                	li	a0,0
    2aa2:	00003097          	auipc	ra,0x3
    2aa6:	1ac080e7          	jalr	428(ra) # 5c4e <sbrk>
    2aaa:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    2aac:	757d                	lui	a0,0xfffff
    2aae:	00003097          	auipc	ra,0x3
    2ab2:	1a0080e7          	jalr	416(ra) # 5c4e <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    2ab6:	57fd                	li	a5,-1
    2ab8:	0af50363          	beq	a0,a5,2b5e <sbrkmuch+0x124>
  c = sbrk(0);
    2abc:	4501                	li	a0,0
    2abe:	00003097          	auipc	ra,0x3
    2ac2:	190080e7          	jalr	400(ra) # 5c4e <sbrk>
  if(c != a - PGSIZE){
    2ac6:	77fd                	lui	a5,0xfffff
    2ac8:	97a6                	add	a5,a5,s1
    2aca:	0af51863          	bne	a0,a5,2b7a <sbrkmuch+0x140>
  a = sbrk(0);
    2ace:	4501                	li	a0,0
    2ad0:	00003097          	auipc	ra,0x3
    2ad4:	17e080e7          	jalr	382(ra) # 5c4e <sbrk>
    2ad8:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    2ada:	6505                	lui	a0,0x1
    2adc:	00003097          	auipc	ra,0x3
    2ae0:	172080e7          	jalr	370(ra) # 5c4e <sbrk>
    2ae4:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    2ae6:	0aa49a63          	bne	s1,a0,2b9a <sbrkmuch+0x160>
    2aea:	4501                	li	a0,0
    2aec:	00003097          	auipc	ra,0x3
    2af0:	162080e7          	jalr	354(ra) # 5c4e <sbrk>
    2af4:	6785                	lui	a5,0x1
    2af6:	97a6                	add	a5,a5,s1
    2af8:	0af51163          	bne	a0,a5,2b9a <sbrkmuch+0x160>
  if(*lastaddr == 99){
    2afc:	064007b7          	lui	a5,0x6400
    2b00:	fff7c703          	lbu	a4,-1(a5) # 63fffff <base+0x63f0387>
    2b04:	06300793          	li	a5,99
    2b08:	0af70963          	beq	a4,a5,2bba <sbrkmuch+0x180>
  a = sbrk(0);
    2b0c:	4501                	li	a0,0
    2b0e:	00003097          	auipc	ra,0x3
    2b12:	140080e7          	jalr	320(ra) # 5c4e <sbrk>
    2b16:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    2b18:	4501                	li	a0,0
    2b1a:	00003097          	auipc	ra,0x3
    2b1e:	134080e7          	jalr	308(ra) # 5c4e <sbrk>
    2b22:	40a9053b          	subw	a0,s2,a0
    2b26:	00003097          	auipc	ra,0x3
    2b2a:	128080e7          	jalr	296(ra) # 5c4e <sbrk>
  if(c != a){
    2b2e:	0aa49463          	bne	s1,a0,2bd6 <sbrkmuch+0x19c>
}
    2b32:	70a2                	ld	ra,40(sp)
    2b34:	7402                	ld	s0,32(sp)
    2b36:	64e2                	ld	s1,24(sp)
    2b38:	6942                	ld	s2,16(sp)
    2b3a:	69a2                	ld	s3,8(sp)
    2b3c:	6a02                	ld	s4,0(sp)
    2b3e:	6145                	addi	sp,sp,48
    2b40:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    2b42:	85ce                	mv	a1,s3
    2b44:	00004517          	auipc	a0,0x4
    2b48:	45c50513          	addi	a0,a0,1116 # 6fa0 <malloc+0xf9c>
    2b4c:	00003097          	auipc	ra,0x3
    2b50:	3fa080e7          	jalr	1018(ra) # 5f46 <printf>
    exit(1);
    2b54:	4505                	li	a0,1
    2b56:	00003097          	auipc	ra,0x3
    2b5a:	070080e7          	jalr	112(ra) # 5bc6 <exit>
    printf("%s: sbrk could not deallocate\n", s);
    2b5e:	85ce                	mv	a1,s3
    2b60:	00004517          	auipc	a0,0x4
    2b64:	48850513          	addi	a0,a0,1160 # 6fe8 <malloc+0xfe4>
    2b68:	00003097          	auipc	ra,0x3
    2b6c:	3de080e7          	jalr	990(ra) # 5f46 <printf>
    exit(1);
    2b70:	4505                	li	a0,1
    2b72:	00003097          	auipc	ra,0x3
    2b76:	054080e7          	jalr	84(ra) # 5bc6 <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", s, a, c);
    2b7a:	86aa                	mv	a3,a0
    2b7c:	8626                	mv	a2,s1
    2b7e:	85ce                	mv	a1,s3
    2b80:	00004517          	auipc	a0,0x4
    2b84:	48850513          	addi	a0,a0,1160 # 7008 <malloc+0x1004>
    2b88:	00003097          	auipc	ra,0x3
    2b8c:	3be080e7          	jalr	958(ra) # 5f46 <printf>
    exit(1);
    2b90:	4505                	li	a0,1
    2b92:	00003097          	auipc	ra,0x3
    2b96:	034080e7          	jalr	52(ra) # 5bc6 <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", s, a, c);
    2b9a:	86d2                	mv	a3,s4
    2b9c:	8626                	mv	a2,s1
    2b9e:	85ce                	mv	a1,s3
    2ba0:	00004517          	auipc	a0,0x4
    2ba4:	4a850513          	addi	a0,a0,1192 # 7048 <malloc+0x1044>
    2ba8:	00003097          	auipc	ra,0x3
    2bac:	39e080e7          	jalr	926(ra) # 5f46 <printf>
    exit(1);
    2bb0:	4505                	li	a0,1
    2bb2:	00003097          	auipc	ra,0x3
    2bb6:	014080e7          	jalr	20(ra) # 5bc6 <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    2bba:	85ce                	mv	a1,s3
    2bbc:	00004517          	auipc	a0,0x4
    2bc0:	4bc50513          	addi	a0,a0,1212 # 7078 <malloc+0x1074>
    2bc4:	00003097          	auipc	ra,0x3
    2bc8:	382080e7          	jalr	898(ra) # 5f46 <printf>
    exit(1);
    2bcc:	4505                	li	a0,1
    2bce:	00003097          	auipc	ra,0x3
    2bd2:	ff8080e7          	jalr	-8(ra) # 5bc6 <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", s, a, c);
    2bd6:	86aa                	mv	a3,a0
    2bd8:	8626                	mv	a2,s1
    2bda:	85ce                	mv	a1,s3
    2bdc:	00004517          	auipc	a0,0x4
    2be0:	4d450513          	addi	a0,a0,1236 # 70b0 <malloc+0x10ac>
    2be4:	00003097          	auipc	ra,0x3
    2be8:	362080e7          	jalr	866(ra) # 5f46 <printf>
    exit(1);
    2bec:	4505                	li	a0,1
    2bee:	00003097          	auipc	ra,0x3
    2bf2:	fd8080e7          	jalr	-40(ra) # 5bc6 <exit>

0000000000002bf6 <sbrkarg>:
{
    2bf6:	7179                	addi	sp,sp,-48
    2bf8:	f406                	sd	ra,40(sp)
    2bfa:	f022                	sd	s0,32(sp)
    2bfc:	ec26                	sd	s1,24(sp)
    2bfe:	e84a                	sd	s2,16(sp)
    2c00:	e44e                	sd	s3,8(sp)
    2c02:	1800                	addi	s0,sp,48
    2c04:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    2c06:	6505                	lui	a0,0x1
    2c08:	00003097          	auipc	ra,0x3
    2c0c:	046080e7          	jalr	70(ra) # 5c4e <sbrk>
    2c10:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    2c12:	20100593          	li	a1,513
    2c16:	00004517          	auipc	a0,0x4
    2c1a:	4c250513          	addi	a0,a0,1218 # 70d8 <malloc+0x10d4>
    2c1e:	00003097          	auipc	ra,0x3
    2c22:	fe8080e7          	jalr	-24(ra) # 5c06 <open>
    2c26:	84aa                	mv	s1,a0
  unlink("sbrk");
    2c28:	00004517          	auipc	a0,0x4
    2c2c:	4b050513          	addi	a0,a0,1200 # 70d8 <malloc+0x10d4>
    2c30:	00003097          	auipc	ra,0x3
    2c34:	fe6080e7          	jalr	-26(ra) # 5c16 <unlink>
  if(fd < 0)  {
    2c38:	0404c163          	bltz	s1,2c7a <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    2c3c:	6605                	lui	a2,0x1
    2c3e:	85ca                	mv	a1,s2
    2c40:	8526                	mv	a0,s1
    2c42:	00003097          	auipc	ra,0x3
    2c46:	fa4080e7          	jalr	-92(ra) # 5be6 <write>
    2c4a:	04054663          	bltz	a0,2c96 <sbrkarg+0xa0>
  close(fd);
    2c4e:	8526                	mv	a0,s1
    2c50:	00003097          	auipc	ra,0x3
    2c54:	f9e080e7          	jalr	-98(ra) # 5bee <close>
  a = sbrk(PGSIZE);
    2c58:	6505                	lui	a0,0x1
    2c5a:	00003097          	auipc	ra,0x3
    2c5e:	ff4080e7          	jalr	-12(ra) # 5c4e <sbrk>
  if(pipe((int *) a) != 0){
    2c62:	00003097          	auipc	ra,0x3
    2c66:	f74080e7          	jalr	-140(ra) # 5bd6 <pipe>
    2c6a:	e521                	bnez	a0,2cb2 <sbrkarg+0xbc>
}
    2c6c:	70a2                	ld	ra,40(sp)
    2c6e:	7402                	ld	s0,32(sp)
    2c70:	64e2                	ld	s1,24(sp)
    2c72:	6942                	ld	s2,16(sp)
    2c74:	69a2                	ld	s3,8(sp)
    2c76:	6145                	addi	sp,sp,48
    2c78:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    2c7a:	85ce                	mv	a1,s3
    2c7c:	00004517          	auipc	a0,0x4
    2c80:	46450513          	addi	a0,a0,1124 # 70e0 <malloc+0x10dc>
    2c84:	00003097          	auipc	ra,0x3
    2c88:	2c2080e7          	jalr	706(ra) # 5f46 <printf>
    exit(1);
    2c8c:	4505                	li	a0,1
    2c8e:	00003097          	auipc	ra,0x3
    2c92:	f38080e7          	jalr	-200(ra) # 5bc6 <exit>
    printf("%s: write sbrk failed\n", s);
    2c96:	85ce                	mv	a1,s3
    2c98:	00004517          	auipc	a0,0x4
    2c9c:	46050513          	addi	a0,a0,1120 # 70f8 <malloc+0x10f4>
    2ca0:	00003097          	auipc	ra,0x3
    2ca4:	2a6080e7          	jalr	678(ra) # 5f46 <printf>
    exit(1);
    2ca8:	4505                	li	a0,1
    2caa:	00003097          	auipc	ra,0x3
    2cae:	f1c080e7          	jalr	-228(ra) # 5bc6 <exit>
    printf("%s: pipe() failed\n", s);
    2cb2:	85ce                	mv	a1,s3
    2cb4:	00004517          	auipc	a0,0x4
    2cb8:	e2450513          	addi	a0,a0,-476 # 6ad8 <malloc+0xad4>
    2cbc:	00003097          	auipc	ra,0x3
    2cc0:	28a080e7          	jalr	650(ra) # 5f46 <printf>
    exit(1);
    2cc4:	4505                	li	a0,1
    2cc6:	00003097          	auipc	ra,0x3
    2cca:	f00080e7          	jalr	-256(ra) # 5bc6 <exit>

0000000000002cce <argptest>:
{
    2cce:	1101                	addi	sp,sp,-32
    2cd0:	ec06                	sd	ra,24(sp)
    2cd2:	e822                	sd	s0,16(sp)
    2cd4:	e426                	sd	s1,8(sp)
    2cd6:	e04a                	sd	s2,0(sp)
    2cd8:	1000                	addi	s0,sp,32
    2cda:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    2cdc:	4581                	li	a1,0
    2cde:	00004517          	auipc	a0,0x4
    2ce2:	43250513          	addi	a0,a0,1074 # 7110 <malloc+0x110c>
    2ce6:	00003097          	auipc	ra,0x3
    2cea:	f20080e7          	jalr	-224(ra) # 5c06 <open>
  if (fd < 0) {
    2cee:	02054b63          	bltz	a0,2d24 <argptest+0x56>
    2cf2:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    2cf4:	4501                	li	a0,0
    2cf6:	00003097          	auipc	ra,0x3
    2cfa:	f58080e7          	jalr	-168(ra) # 5c4e <sbrk>
    2cfe:	567d                	li	a2,-1
    2d00:	fff50593          	addi	a1,a0,-1
    2d04:	8526                	mv	a0,s1
    2d06:	00003097          	auipc	ra,0x3
    2d0a:	ed8080e7          	jalr	-296(ra) # 5bde <read>
  close(fd);
    2d0e:	8526                	mv	a0,s1
    2d10:	00003097          	auipc	ra,0x3
    2d14:	ede080e7          	jalr	-290(ra) # 5bee <close>
}
    2d18:	60e2                	ld	ra,24(sp)
    2d1a:	6442                	ld	s0,16(sp)
    2d1c:	64a2                	ld	s1,8(sp)
    2d1e:	6902                	ld	s2,0(sp)
    2d20:	6105                	addi	sp,sp,32
    2d22:	8082                	ret
    printf("%s: open failed\n", s);
    2d24:	85ca                	mv	a1,s2
    2d26:	00004517          	auipc	a0,0x4
    2d2a:	cc250513          	addi	a0,a0,-830 # 69e8 <malloc+0x9e4>
    2d2e:	00003097          	auipc	ra,0x3
    2d32:	218080e7          	jalr	536(ra) # 5f46 <printf>
    exit(1);
    2d36:	4505                	li	a0,1
    2d38:	00003097          	auipc	ra,0x3
    2d3c:	e8e080e7          	jalr	-370(ra) # 5bc6 <exit>

0000000000002d40 <sbrkbugs>:
{
    2d40:	1141                	addi	sp,sp,-16
    2d42:	e406                	sd	ra,8(sp)
    2d44:	e022                	sd	s0,0(sp)
    2d46:	0800                	addi	s0,sp,16
  int pid = fork();
    2d48:	00003097          	auipc	ra,0x3
    2d4c:	e76080e7          	jalr	-394(ra) # 5bbe <fork>
  if(pid < 0){
    2d50:	02054263          	bltz	a0,2d74 <sbrkbugs+0x34>
  if(pid == 0){
    2d54:	ed0d                	bnez	a0,2d8e <sbrkbugs+0x4e>
    int sz = (uint64) sbrk(0);
    2d56:	00003097          	auipc	ra,0x3
    2d5a:	ef8080e7          	jalr	-264(ra) # 5c4e <sbrk>
    sbrk(-sz);
    2d5e:	40a0053b          	negw	a0,a0
    2d62:	00003097          	auipc	ra,0x3
    2d66:	eec080e7          	jalr	-276(ra) # 5c4e <sbrk>
    exit(0);
    2d6a:	4501                	li	a0,0
    2d6c:	00003097          	auipc	ra,0x3
    2d70:	e5a080e7          	jalr	-422(ra) # 5bc6 <exit>
    printf("fork failed\n");
    2d74:	00004517          	auipc	a0,0x4
    2d78:	06450513          	addi	a0,a0,100 # 6dd8 <malloc+0xdd4>
    2d7c:	00003097          	auipc	ra,0x3
    2d80:	1ca080e7          	jalr	458(ra) # 5f46 <printf>
    exit(1);
    2d84:	4505                	li	a0,1
    2d86:	00003097          	auipc	ra,0x3
    2d8a:	e40080e7          	jalr	-448(ra) # 5bc6 <exit>
  wait(0);
    2d8e:	4501                	li	a0,0
    2d90:	00003097          	auipc	ra,0x3
    2d94:	e3e080e7          	jalr	-450(ra) # 5bce <wait>
  pid = fork();
    2d98:	00003097          	auipc	ra,0x3
    2d9c:	e26080e7          	jalr	-474(ra) # 5bbe <fork>
  if(pid < 0){
    2da0:	02054563          	bltz	a0,2dca <sbrkbugs+0x8a>
  if(pid == 0){
    2da4:	e121                	bnez	a0,2de4 <sbrkbugs+0xa4>
    int sz = (uint64) sbrk(0);
    2da6:	00003097          	auipc	ra,0x3
    2daa:	ea8080e7          	jalr	-344(ra) # 5c4e <sbrk>
    sbrk(-(sz - 3500));
    2dae:	6785                	lui	a5,0x1
    2db0:	dac7879b          	addiw	a5,a5,-596
    2db4:	40a7853b          	subw	a0,a5,a0
    2db8:	00003097          	auipc	ra,0x3
    2dbc:	e96080e7          	jalr	-362(ra) # 5c4e <sbrk>
    exit(0);
    2dc0:	4501                	li	a0,0
    2dc2:	00003097          	auipc	ra,0x3
    2dc6:	e04080e7          	jalr	-508(ra) # 5bc6 <exit>
    printf("fork failed\n");
    2dca:	00004517          	auipc	a0,0x4
    2dce:	00e50513          	addi	a0,a0,14 # 6dd8 <malloc+0xdd4>
    2dd2:	00003097          	auipc	ra,0x3
    2dd6:	174080e7          	jalr	372(ra) # 5f46 <printf>
    exit(1);
    2dda:	4505                	li	a0,1
    2ddc:	00003097          	auipc	ra,0x3
    2de0:	dea080e7          	jalr	-534(ra) # 5bc6 <exit>
  wait(0);
    2de4:	4501                	li	a0,0
    2de6:	00003097          	auipc	ra,0x3
    2dea:	de8080e7          	jalr	-536(ra) # 5bce <wait>
  pid = fork();
    2dee:	00003097          	auipc	ra,0x3
    2df2:	dd0080e7          	jalr	-560(ra) # 5bbe <fork>
  if(pid < 0){
    2df6:	02054a63          	bltz	a0,2e2a <sbrkbugs+0xea>
  if(pid == 0){
    2dfa:	e529                	bnez	a0,2e44 <sbrkbugs+0x104>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    2dfc:	00003097          	auipc	ra,0x3
    2e00:	e52080e7          	jalr	-430(ra) # 5c4e <sbrk>
    2e04:	67ad                	lui	a5,0xb
    2e06:	8007879b          	addiw	a5,a5,-2048
    2e0a:	40a7853b          	subw	a0,a5,a0
    2e0e:	00003097          	auipc	ra,0x3
    2e12:	e40080e7          	jalr	-448(ra) # 5c4e <sbrk>
    sbrk(-10);
    2e16:	5559                	li	a0,-10
    2e18:	00003097          	auipc	ra,0x3
    2e1c:	e36080e7          	jalr	-458(ra) # 5c4e <sbrk>
    exit(0);
    2e20:	4501                	li	a0,0
    2e22:	00003097          	auipc	ra,0x3
    2e26:	da4080e7          	jalr	-604(ra) # 5bc6 <exit>
    printf("fork failed\n");
    2e2a:	00004517          	auipc	a0,0x4
    2e2e:	fae50513          	addi	a0,a0,-82 # 6dd8 <malloc+0xdd4>
    2e32:	00003097          	auipc	ra,0x3
    2e36:	114080e7          	jalr	276(ra) # 5f46 <printf>
    exit(1);
    2e3a:	4505                	li	a0,1
    2e3c:	00003097          	auipc	ra,0x3
    2e40:	d8a080e7          	jalr	-630(ra) # 5bc6 <exit>
  wait(0);
    2e44:	4501                	li	a0,0
    2e46:	00003097          	auipc	ra,0x3
    2e4a:	d88080e7          	jalr	-632(ra) # 5bce <wait>
  exit(0);
    2e4e:	4501                	li	a0,0
    2e50:	00003097          	auipc	ra,0x3
    2e54:	d76080e7          	jalr	-650(ra) # 5bc6 <exit>

0000000000002e58 <sbrklast>:
{
    2e58:	7179                	addi	sp,sp,-48
    2e5a:	f406                	sd	ra,40(sp)
    2e5c:	f022                	sd	s0,32(sp)
    2e5e:	ec26                	sd	s1,24(sp)
    2e60:	e84a                	sd	s2,16(sp)
    2e62:	e44e                	sd	s3,8(sp)
    2e64:	e052                	sd	s4,0(sp)
    2e66:	1800                	addi	s0,sp,48
  uint64 top = (uint64) sbrk(0);
    2e68:	4501                	li	a0,0
    2e6a:	00003097          	auipc	ra,0x3
    2e6e:	de4080e7          	jalr	-540(ra) # 5c4e <sbrk>
  if((top % 4096) != 0)
    2e72:	03451793          	slli	a5,a0,0x34
    2e76:	ebd9                	bnez	a5,2f0c <sbrklast+0xb4>
  sbrk(4096);
    2e78:	6505                	lui	a0,0x1
    2e7a:	00003097          	auipc	ra,0x3
    2e7e:	dd4080e7          	jalr	-556(ra) # 5c4e <sbrk>
  sbrk(10);
    2e82:	4529                	li	a0,10
    2e84:	00003097          	auipc	ra,0x3
    2e88:	dca080e7          	jalr	-566(ra) # 5c4e <sbrk>
  sbrk(-20);
    2e8c:	5531                	li	a0,-20
    2e8e:	00003097          	auipc	ra,0x3
    2e92:	dc0080e7          	jalr	-576(ra) # 5c4e <sbrk>
  top = (uint64) sbrk(0);
    2e96:	4501                	li	a0,0
    2e98:	00003097          	auipc	ra,0x3
    2e9c:	db6080e7          	jalr	-586(ra) # 5c4e <sbrk>
    2ea0:	84aa                	mv	s1,a0
  char *p = (char *) (top - 64);
    2ea2:	fc050913          	addi	s2,a0,-64 # fc0 <linktest+0xca>
  p[0] = 'x';
    2ea6:	07800a13          	li	s4,120
    2eaa:	fd450023          	sb	s4,-64(a0)
  p[1] = '\0';
    2eae:	fc0500a3          	sb	zero,-63(a0)
  int fd = open(p, O_RDWR|O_CREATE);
    2eb2:	20200593          	li	a1,514
    2eb6:	854a                	mv	a0,s2
    2eb8:	00003097          	auipc	ra,0x3
    2ebc:	d4e080e7          	jalr	-690(ra) # 5c06 <open>
    2ec0:	89aa                	mv	s3,a0
  write(fd, p, 1);
    2ec2:	4605                	li	a2,1
    2ec4:	85ca                	mv	a1,s2
    2ec6:	00003097          	auipc	ra,0x3
    2eca:	d20080e7          	jalr	-736(ra) # 5be6 <write>
  close(fd);
    2ece:	854e                	mv	a0,s3
    2ed0:	00003097          	auipc	ra,0x3
    2ed4:	d1e080e7          	jalr	-738(ra) # 5bee <close>
  fd = open(p, O_RDWR);
    2ed8:	4589                	li	a1,2
    2eda:	854a                	mv	a0,s2
    2edc:	00003097          	auipc	ra,0x3
    2ee0:	d2a080e7          	jalr	-726(ra) # 5c06 <open>
  p[0] = '\0';
    2ee4:	fc048023          	sb	zero,-64(s1)
  read(fd, p, 1);
    2ee8:	4605                	li	a2,1
    2eea:	85ca                	mv	a1,s2
    2eec:	00003097          	auipc	ra,0x3
    2ef0:	cf2080e7          	jalr	-782(ra) # 5bde <read>
  if(p[0] != 'x')
    2ef4:	fc04c783          	lbu	a5,-64(s1)
    2ef8:	03479463          	bne	a5,s4,2f20 <sbrklast+0xc8>
}
    2efc:	70a2                	ld	ra,40(sp)
    2efe:	7402                	ld	s0,32(sp)
    2f00:	64e2                	ld	s1,24(sp)
    2f02:	6942                	ld	s2,16(sp)
    2f04:	69a2                	ld	s3,8(sp)
    2f06:	6a02                	ld	s4,0(sp)
    2f08:	6145                	addi	sp,sp,48
    2f0a:	8082                	ret
    sbrk(4096 - (top % 4096));
    2f0c:	0347d513          	srli	a0,a5,0x34
    2f10:	6785                	lui	a5,0x1
    2f12:	40a7853b          	subw	a0,a5,a0
    2f16:	00003097          	auipc	ra,0x3
    2f1a:	d38080e7          	jalr	-712(ra) # 5c4e <sbrk>
    2f1e:	bfa9                	j	2e78 <sbrklast+0x20>
    exit(1);
    2f20:	4505                	li	a0,1
    2f22:	00003097          	auipc	ra,0x3
    2f26:	ca4080e7          	jalr	-860(ra) # 5bc6 <exit>

0000000000002f2a <sbrk8000>:
{
    2f2a:	1141                	addi	sp,sp,-16
    2f2c:	e406                	sd	ra,8(sp)
    2f2e:	e022                	sd	s0,0(sp)
    2f30:	0800                	addi	s0,sp,16
  sbrk(0x80000004);
    2f32:	80000537          	lui	a0,0x80000
    2f36:	0511                	addi	a0,a0,4
    2f38:	00003097          	auipc	ra,0x3
    2f3c:	d16080e7          	jalr	-746(ra) # 5c4e <sbrk>
  volatile char *top = sbrk(0);
    2f40:	4501                	li	a0,0
    2f42:	00003097          	auipc	ra,0x3
    2f46:	d0c080e7          	jalr	-756(ra) # 5c4e <sbrk>
  *(top-1) = *(top-1) + 1;
    2f4a:	fff54783          	lbu	a5,-1(a0) # ffffffff7fffffff <base+0xffffffff7fff0387>
    2f4e:	0785                	addi	a5,a5,1
    2f50:	0ff7f793          	andi	a5,a5,255
    2f54:	fef50fa3          	sb	a5,-1(a0)
}
    2f58:	60a2                	ld	ra,8(sp)
    2f5a:	6402                	ld	s0,0(sp)
    2f5c:	0141                	addi	sp,sp,16
    2f5e:	8082                	ret

0000000000002f60 <execout>:
{
    2f60:	715d                	addi	sp,sp,-80
    2f62:	e486                	sd	ra,72(sp)
    2f64:	e0a2                	sd	s0,64(sp)
    2f66:	fc26                	sd	s1,56(sp)
    2f68:	f84a                	sd	s2,48(sp)
    2f6a:	f44e                	sd	s3,40(sp)
    2f6c:	f052                	sd	s4,32(sp)
    2f6e:	0880                	addi	s0,sp,80
  for(int avail = 0; avail < 15; avail++){
    2f70:	4901                	li	s2,0
    2f72:	49bd                	li	s3,15
    int pid = fork();
    2f74:	00003097          	auipc	ra,0x3
    2f78:	c4a080e7          	jalr	-950(ra) # 5bbe <fork>
    2f7c:	84aa                	mv	s1,a0
    if(pid < 0){
    2f7e:	02054063          	bltz	a0,2f9e <execout+0x3e>
    } else if(pid == 0){
    2f82:	c91d                	beqz	a0,2fb8 <execout+0x58>
      wait((int*)0);
    2f84:	4501                	li	a0,0
    2f86:	00003097          	auipc	ra,0x3
    2f8a:	c48080e7          	jalr	-952(ra) # 5bce <wait>
  for(int avail = 0; avail < 15; avail++){
    2f8e:	2905                	addiw	s2,s2,1
    2f90:	ff3912e3          	bne	s2,s3,2f74 <execout+0x14>
  exit(0);
    2f94:	4501                	li	a0,0
    2f96:	00003097          	auipc	ra,0x3
    2f9a:	c30080e7          	jalr	-976(ra) # 5bc6 <exit>
      printf("fork failed\n");
    2f9e:	00004517          	auipc	a0,0x4
    2fa2:	e3a50513          	addi	a0,a0,-454 # 6dd8 <malloc+0xdd4>
    2fa6:	00003097          	auipc	ra,0x3
    2faa:	fa0080e7          	jalr	-96(ra) # 5f46 <printf>
      exit(1);
    2fae:	4505                	li	a0,1
    2fb0:	00003097          	auipc	ra,0x3
    2fb4:	c16080e7          	jalr	-1002(ra) # 5bc6 <exit>
        if(a == 0xffffffffffffffffLL)
    2fb8:	59fd                	li	s3,-1
        *(char*)(a + 4096 - 1) = 1;
    2fba:	4a05                	li	s4,1
        uint64 a = (uint64) sbrk(4096);
    2fbc:	6505                	lui	a0,0x1
    2fbe:	00003097          	auipc	ra,0x3
    2fc2:	c90080e7          	jalr	-880(ra) # 5c4e <sbrk>
        if(a == 0xffffffffffffffffLL)
    2fc6:	01350763          	beq	a0,s3,2fd4 <execout+0x74>
        *(char*)(a + 4096 - 1) = 1;
    2fca:	6785                	lui	a5,0x1
    2fcc:	953e                	add	a0,a0,a5
    2fce:	ff450fa3          	sb	s4,-1(a0) # fff <linktest+0x109>
      while(1){
    2fd2:	b7ed                	j	2fbc <execout+0x5c>
      for(int i = 0; i < avail; i++)
    2fd4:	01205a63          	blez	s2,2fe8 <execout+0x88>
        sbrk(-4096);
    2fd8:	757d                	lui	a0,0xfffff
    2fda:	00003097          	auipc	ra,0x3
    2fde:	c74080e7          	jalr	-908(ra) # 5c4e <sbrk>
      for(int i = 0; i < avail; i++)
    2fe2:	2485                	addiw	s1,s1,1
    2fe4:	ff249ae3          	bne	s1,s2,2fd8 <execout+0x78>
      close(1);
    2fe8:	4505                	li	a0,1
    2fea:	00003097          	auipc	ra,0x3
    2fee:	c04080e7          	jalr	-1020(ra) # 5bee <close>
      char *args[] = { "echo", "x", 0 };
    2ff2:	00003517          	auipc	a0,0x3
    2ff6:	15650513          	addi	a0,a0,342 # 6148 <malloc+0x144>
    2ffa:	faa43c23          	sd	a0,-72(s0)
    2ffe:	00003797          	auipc	a5,0x3
    3002:	1ba78793          	addi	a5,a5,442 # 61b8 <malloc+0x1b4>
    3006:	fcf43023          	sd	a5,-64(s0)
    300a:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    300e:	fb840593          	addi	a1,s0,-72
    3012:	00003097          	auipc	ra,0x3
    3016:	bec080e7          	jalr	-1044(ra) # 5bfe <exec>
      exit(0);
    301a:	4501                	li	a0,0
    301c:	00003097          	auipc	ra,0x3
    3020:	baa080e7          	jalr	-1110(ra) # 5bc6 <exit>

0000000000003024 <fourteen>:
{
    3024:	1101                	addi	sp,sp,-32
    3026:	ec06                	sd	ra,24(sp)
    3028:	e822                	sd	s0,16(sp)
    302a:	e426                	sd	s1,8(sp)
    302c:	1000                	addi	s0,sp,32
    302e:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    3030:	00004517          	auipc	a0,0x4
    3034:	2b850513          	addi	a0,a0,696 # 72e8 <malloc+0x12e4>
    3038:	00003097          	auipc	ra,0x3
    303c:	bf6080e7          	jalr	-1034(ra) # 5c2e <mkdir>
    3040:	e165                	bnez	a0,3120 <fourteen+0xfc>
  if(mkdir("12345678901234/123456789012345") != 0){
    3042:	00004517          	auipc	a0,0x4
    3046:	0fe50513          	addi	a0,a0,254 # 7140 <malloc+0x113c>
    304a:	00003097          	auipc	ra,0x3
    304e:	be4080e7          	jalr	-1052(ra) # 5c2e <mkdir>
    3052:	e56d                	bnez	a0,313c <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    3054:	20000593          	li	a1,512
    3058:	00004517          	auipc	a0,0x4
    305c:	14050513          	addi	a0,a0,320 # 7198 <malloc+0x1194>
    3060:	00003097          	auipc	ra,0x3
    3064:	ba6080e7          	jalr	-1114(ra) # 5c06 <open>
  if(fd < 0){
    3068:	0e054863          	bltz	a0,3158 <fourteen+0x134>
  close(fd);
    306c:	00003097          	auipc	ra,0x3
    3070:	b82080e7          	jalr	-1150(ra) # 5bee <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    3074:	4581                	li	a1,0
    3076:	00004517          	auipc	a0,0x4
    307a:	19a50513          	addi	a0,a0,410 # 7210 <malloc+0x120c>
    307e:	00003097          	auipc	ra,0x3
    3082:	b88080e7          	jalr	-1144(ra) # 5c06 <open>
  if(fd < 0){
    3086:	0e054763          	bltz	a0,3174 <fourteen+0x150>
  close(fd);
    308a:	00003097          	auipc	ra,0x3
    308e:	b64080e7          	jalr	-1180(ra) # 5bee <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    3092:	00004517          	auipc	a0,0x4
    3096:	1ee50513          	addi	a0,a0,494 # 7280 <malloc+0x127c>
    309a:	00003097          	auipc	ra,0x3
    309e:	b94080e7          	jalr	-1132(ra) # 5c2e <mkdir>
    30a2:	c57d                	beqz	a0,3190 <fourteen+0x16c>
  if(mkdir("123456789012345/12345678901234") == 0){
    30a4:	00004517          	auipc	a0,0x4
    30a8:	23450513          	addi	a0,a0,564 # 72d8 <malloc+0x12d4>
    30ac:	00003097          	auipc	ra,0x3
    30b0:	b82080e7          	jalr	-1150(ra) # 5c2e <mkdir>
    30b4:	cd65                	beqz	a0,31ac <fourteen+0x188>
  unlink("123456789012345/12345678901234");
    30b6:	00004517          	auipc	a0,0x4
    30ba:	22250513          	addi	a0,a0,546 # 72d8 <malloc+0x12d4>
    30be:	00003097          	auipc	ra,0x3
    30c2:	b58080e7          	jalr	-1192(ra) # 5c16 <unlink>
  unlink("12345678901234/12345678901234");
    30c6:	00004517          	auipc	a0,0x4
    30ca:	1ba50513          	addi	a0,a0,442 # 7280 <malloc+0x127c>
    30ce:	00003097          	auipc	ra,0x3
    30d2:	b48080e7          	jalr	-1208(ra) # 5c16 <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    30d6:	00004517          	auipc	a0,0x4
    30da:	13a50513          	addi	a0,a0,314 # 7210 <malloc+0x120c>
    30de:	00003097          	auipc	ra,0x3
    30e2:	b38080e7          	jalr	-1224(ra) # 5c16 <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    30e6:	00004517          	auipc	a0,0x4
    30ea:	0b250513          	addi	a0,a0,178 # 7198 <malloc+0x1194>
    30ee:	00003097          	auipc	ra,0x3
    30f2:	b28080e7          	jalr	-1240(ra) # 5c16 <unlink>
  unlink("12345678901234/123456789012345");
    30f6:	00004517          	auipc	a0,0x4
    30fa:	04a50513          	addi	a0,a0,74 # 7140 <malloc+0x113c>
    30fe:	00003097          	auipc	ra,0x3
    3102:	b18080e7          	jalr	-1256(ra) # 5c16 <unlink>
  unlink("12345678901234");
    3106:	00004517          	auipc	a0,0x4
    310a:	1e250513          	addi	a0,a0,482 # 72e8 <malloc+0x12e4>
    310e:	00003097          	auipc	ra,0x3
    3112:	b08080e7          	jalr	-1272(ra) # 5c16 <unlink>
}
    3116:	60e2                	ld	ra,24(sp)
    3118:	6442                	ld	s0,16(sp)
    311a:	64a2                	ld	s1,8(sp)
    311c:	6105                	addi	sp,sp,32
    311e:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    3120:	85a6                	mv	a1,s1
    3122:	00004517          	auipc	a0,0x4
    3126:	ff650513          	addi	a0,a0,-10 # 7118 <malloc+0x1114>
    312a:	00003097          	auipc	ra,0x3
    312e:	e1c080e7          	jalr	-484(ra) # 5f46 <printf>
    exit(1);
    3132:	4505                	li	a0,1
    3134:	00003097          	auipc	ra,0x3
    3138:	a92080e7          	jalr	-1390(ra) # 5bc6 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    313c:	85a6                	mv	a1,s1
    313e:	00004517          	auipc	a0,0x4
    3142:	02250513          	addi	a0,a0,34 # 7160 <malloc+0x115c>
    3146:	00003097          	auipc	ra,0x3
    314a:	e00080e7          	jalr	-512(ra) # 5f46 <printf>
    exit(1);
    314e:	4505                	li	a0,1
    3150:	00003097          	auipc	ra,0x3
    3154:	a76080e7          	jalr	-1418(ra) # 5bc6 <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    3158:	85a6                	mv	a1,s1
    315a:	00004517          	auipc	a0,0x4
    315e:	06e50513          	addi	a0,a0,110 # 71c8 <malloc+0x11c4>
    3162:	00003097          	auipc	ra,0x3
    3166:	de4080e7          	jalr	-540(ra) # 5f46 <printf>
    exit(1);
    316a:	4505                	li	a0,1
    316c:	00003097          	auipc	ra,0x3
    3170:	a5a080e7          	jalr	-1446(ra) # 5bc6 <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    3174:	85a6                	mv	a1,s1
    3176:	00004517          	auipc	a0,0x4
    317a:	0ca50513          	addi	a0,a0,202 # 7240 <malloc+0x123c>
    317e:	00003097          	auipc	ra,0x3
    3182:	dc8080e7          	jalr	-568(ra) # 5f46 <printf>
    exit(1);
    3186:	4505                	li	a0,1
    3188:	00003097          	auipc	ra,0x3
    318c:	a3e080e7          	jalr	-1474(ra) # 5bc6 <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    3190:	85a6                	mv	a1,s1
    3192:	00004517          	auipc	a0,0x4
    3196:	10e50513          	addi	a0,a0,270 # 72a0 <malloc+0x129c>
    319a:	00003097          	auipc	ra,0x3
    319e:	dac080e7          	jalr	-596(ra) # 5f46 <printf>
    exit(1);
    31a2:	4505                	li	a0,1
    31a4:	00003097          	auipc	ra,0x3
    31a8:	a22080e7          	jalr	-1502(ra) # 5bc6 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    31ac:	85a6                	mv	a1,s1
    31ae:	00004517          	auipc	a0,0x4
    31b2:	14a50513          	addi	a0,a0,330 # 72f8 <malloc+0x12f4>
    31b6:	00003097          	auipc	ra,0x3
    31ba:	d90080e7          	jalr	-624(ra) # 5f46 <printf>
    exit(1);
    31be:	4505                	li	a0,1
    31c0:	00003097          	auipc	ra,0x3
    31c4:	a06080e7          	jalr	-1530(ra) # 5bc6 <exit>

00000000000031c8 <diskfull>:
{
    31c8:	b9010113          	addi	sp,sp,-1136
    31cc:	46113423          	sd	ra,1128(sp)
    31d0:	46813023          	sd	s0,1120(sp)
    31d4:	44913c23          	sd	s1,1112(sp)
    31d8:	45213823          	sd	s2,1104(sp)
    31dc:	45313423          	sd	s3,1096(sp)
    31e0:	45413023          	sd	s4,1088(sp)
    31e4:	43513c23          	sd	s5,1080(sp)
    31e8:	43613823          	sd	s6,1072(sp)
    31ec:	43713423          	sd	s7,1064(sp)
    31f0:	43813023          	sd	s8,1056(sp)
    31f4:	47010413          	addi	s0,sp,1136
    31f8:	8c2a                	mv	s8,a0
  unlink("diskfulldir");
    31fa:	00004517          	auipc	a0,0x4
    31fe:	13650513          	addi	a0,a0,310 # 7330 <malloc+0x132c>
    3202:	00003097          	auipc	ra,0x3
    3206:	a14080e7          	jalr	-1516(ra) # 5c16 <unlink>
  for(fi = 0; done == 0; fi++){
    320a:	4a01                	li	s4,0
    name[0] = 'b';
    320c:	06200b13          	li	s6,98
    name[1] = 'i';
    3210:	06900a93          	li	s5,105
    name[2] = 'g';
    3214:	06700993          	li	s3,103
    3218:	10c00b93          	li	s7,268
    321c:	aabd                	j	339a <diskfull+0x1d2>
      printf("%s: could not create file %s\n", s, name);
    321e:	b9040613          	addi	a2,s0,-1136
    3222:	85e2                	mv	a1,s8
    3224:	00004517          	auipc	a0,0x4
    3228:	11c50513          	addi	a0,a0,284 # 7340 <malloc+0x133c>
    322c:	00003097          	auipc	ra,0x3
    3230:	d1a080e7          	jalr	-742(ra) # 5f46 <printf>
      break;
    3234:	a821                	j	324c <diskfull+0x84>
        close(fd);
    3236:	854a                	mv	a0,s2
    3238:	00003097          	auipc	ra,0x3
    323c:	9b6080e7          	jalr	-1610(ra) # 5bee <close>
    close(fd);
    3240:	854a                	mv	a0,s2
    3242:	00003097          	auipc	ra,0x3
    3246:	9ac080e7          	jalr	-1620(ra) # 5bee <close>
  for(fi = 0; done == 0; fi++){
    324a:	2a05                	addiw	s4,s4,1
  for(int i = 0; i < nzz; i++){
    324c:	4481                	li	s1,0
    name[0] = 'z';
    324e:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
    3252:	08000993          	li	s3,128
    name[0] = 'z';
    3256:	bb240823          	sb	s2,-1104(s0)
    name[1] = 'z';
    325a:	bb2408a3          	sb	s2,-1103(s0)
    name[2] = '0' + (i / 32);
    325e:	41f4d79b          	sraiw	a5,s1,0x1f
    3262:	01b7d71b          	srliw	a4,a5,0x1b
    3266:	009707bb          	addw	a5,a4,s1
    326a:	4057d69b          	sraiw	a3,a5,0x5
    326e:	0306869b          	addiw	a3,a3,48
    3272:	bad40923          	sb	a3,-1102(s0)
    name[3] = '0' + (i % 32);
    3276:	8bfd                	andi	a5,a5,31
    3278:	9f99                	subw	a5,a5,a4
    327a:	0307879b          	addiw	a5,a5,48
    327e:	baf409a3          	sb	a5,-1101(s0)
    name[4] = '\0';
    3282:	ba040a23          	sb	zero,-1100(s0)
    unlink(name);
    3286:	bb040513          	addi	a0,s0,-1104
    328a:	00003097          	auipc	ra,0x3
    328e:	98c080e7          	jalr	-1652(ra) # 5c16 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    3292:	60200593          	li	a1,1538
    3296:	bb040513          	addi	a0,s0,-1104
    329a:	00003097          	auipc	ra,0x3
    329e:	96c080e7          	jalr	-1684(ra) # 5c06 <open>
    if(fd < 0)
    32a2:	00054963          	bltz	a0,32b4 <diskfull+0xec>
    close(fd);
    32a6:	00003097          	auipc	ra,0x3
    32aa:	948080e7          	jalr	-1720(ra) # 5bee <close>
  for(int i = 0; i < nzz; i++){
    32ae:	2485                	addiw	s1,s1,1
    32b0:	fb3493e3          	bne	s1,s3,3256 <diskfull+0x8e>
  if(mkdir("diskfulldir") == 0)
    32b4:	00004517          	auipc	a0,0x4
    32b8:	07c50513          	addi	a0,a0,124 # 7330 <malloc+0x132c>
    32bc:	00003097          	auipc	ra,0x3
    32c0:	972080e7          	jalr	-1678(ra) # 5c2e <mkdir>
    32c4:	12050963          	beqz	a0,33f6 <diskfull+0x22e>
  unlink("diskfulldir");
    32c8:	00004517          	auipc	a0,0x4
    32cc:	06850513          	addi	a0,a0,104 # 7330 <malloc+0x132c>
    32d0:	00003097          	auipc	ra,0x3
    32d4:	946080e7          	jalr	-1722(ra) # 5c16 <unlink>
  for(int i = 0; i < nzz; i++){
    32d8:	4481                	li	s1,0
    name[0] = 'z';
    32da:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
    32de:	08000993          	li	s3,128
    name[0] = 'z';
    32e2:	bb240823          	sb	s2,-1104(s0)
    name[1] = 'z';
    32e6:	bb2408a3          	sb	s2,-1103(s0)
    name[2] = '0' + (i / 32);
    32ea:	41f4d79b          	sraiw	a5,s1,0x1f
    32ee:	01b7d71b          	srliw	a4,a5,0x1b
    32f2:	009707bb          	addw	a5,a4,s1
    32f6:	4057d69b          	sraiw	a3,a5,0x5
    32fa:	0306869b          	addiw	a3,a3,48
    32fe:	bad40923          	sb	a3,-1102(s0)
    name[3] = '0' + (i % 32);
    3302:	8bfd                	andi	a5,a5,31
    3304:	9f99                	subw	a5,a5,a4
    3306:	0307879b          	addiw	a5,a5,48
    330a:	baf409a3          	sb	a5,-1101(s0)
    name[4] = '\0';
    330e:	ba040a23          	sb	zero,-1100(s0)
    unlink(name);
    3312:	bb040513          	addi	a0,s0,-1104
    3316:	00003097          	auipc	ra,0x3
    331a:	900080e7          	jalr	-1792(ra) # 5c16 <unlink>
  for(int i = 0; i < nzz; i++){
    331e:	2485                	addiw	s1,s1,1
    3320:	fd3491e3          	bne	s1,s3,32e2 <diskfull+0x11a>
  for(int i = 0; i < fi; i++){
    3324:	03405e63          	blez	s4,3360 <diskfull+0x198>
    3328:	4481                	li	s1,0
    name[0] = 'b';
    332a:	06200a93          	li	s5,98
    name[1] = 'i';
    332e:	06900993          	li	s3,105
    name[2] = 'g';
    3332:	06700913          	li	s2,103
    name[0] = 'b';
    3336:	bb540823          	sb	s5,-1104(s0)
    name[1] = 'i';
    333a:	bb3408a3          	sb	s3,-1103(s0)
    name[2] = 'g';
    333e:	bb240923          	sb	s2,-1102(s0)
    name[3] = '0' + i;
    3342:	0304879b          	addiw	a5,s1,48
    3346:	baf409a3          	sb	a5,-1101(s0)
    name[4] = '\0';
    334a:	ba040a23          	sb	zero,-1100(s0)
    unlink(name);
    334e:	bb040513          	addi	a0,s0,-1104
    3352:	00003097          	auipc	ra,0x3
    3356:	8c4080e7          	jalr	-1852(ra) # 5c16 <unlink>
  for(int i = 0; i < fi; i++){
    335a:	2485                	addiw	s1,s1,1
    335c:	fd449de3          	bne	s1,s4,3336 <diskfull+0x16e>
}
    3360:	46813083          	ld	ra,1128(sp)
    3364:	46013403          	ld	s0,1120(sp)
    3368:	45813483          	ld	s1,1112(sp)
    336c:	45013903          	ld	s2,1104(sp)
    3370:	44813983          	ld	s3,1096(sp)
    3374:	44013a03          	ld	s4,1088(sp)
    3378:	43813a83          	ld	s5,1080(sp)
    337c:	43013b03          	ld	s6,1072(sp)
    3380:	42813b83          	ld	s7,1064(sp)
    3384:	42013c03          	ld	s8,1056(sp)
    3388:	47010113          	addi	sp,sp,1136
    338c:	8082                	ret
    close(fd);
    338e:	854a                	mv	a0,s2
    3390:	00003097          	auipc	ra,0x3
    3394:	85e080e7          	jalr	-1954(ra) # 5bee <close>
  for(fi = 0; done == 0; fi++){
    3398:	2a05                	addiw	s4,s4,1
    name[0] = 'b';
    339a:	b9640823          	sb	s6,-1136(s0)
    name[1] = 'i';
    339e:	b95408a3          	sb	s5,-1135(s0)
    name[2] = 'g';
    33a2:	b9340923          	sb	s3,-1134(s0)
    name[3] = '0' + fi;
    33a6:	030a079b          	addiw	a5,s4,48
    33aa:	b8f409a3          	sb	a5,-1133(s0)
    name[4] = '\0';
    33ae:	b8040a23          	sb	zero,-1132(s0)
    unlink(name);
    33b2:	b9040513          	addi	a0,s0,-1136
    33b6:	00003097          	auipc	ra,0x3
    33ba:	860080e7          	jalr	-1952(ra) # 5c16 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    33be:	60200593          	li	a1,1538
    33c2:	b9040513          	addi	a0,s0,-1136
    33c6:	00003097          	auipc	ra,0x3
    33ca:	840080e7          	jalr	-1984(ra) # 5c06 <open>
    33ce:	892a                	mv	s2,a0
    if(fd < 0){
    33d0:	e40547e3          	bltz	a0,321e <diskfull+0x56>
    33d4:	84de                	mv	s1,s7
      if(write(fd, buf, BSIZE) != BSIZE){
    33d6:	40000613          	li	a2,1024
    33da:	bb040593          	addi	a1,s0,-1104
    33de:	854a                	mv	a0,s2
    33e0:	00003097          	auipc	ra,0x3
    33e4:	806080e7          	jalr	-2042(ra) # 5be6 <write>
    33e8:	40000793          	li	a5,1024
    33ec:	e4f515e3          	bne	a0,a5,3236 <diskfull+0x6e>
    for(int i = 0; i < MAXFILE; i++){
    33f0:	34fd                	addiw	s1,s1,-1
    33f2:	f0f5                	bnez	s1,33d6 <diskfull+0x20e>
    33f4:	bf69                	j	338e <diskfull+0x1c6>
    printf("%s: mkdir(diskfulldir) unexpectedly succeeded!\n");
    33f6:	00004517          	auipc	a0,0x4
    33fa:	f6a50513          	addi	a0,a0,-150 # 7360 <malloc+0x135c>
    33fe:	00003097          	auipc	ra,0x3
    3402:	b48080e7          	jalr	-1208(ra) # 5f46 <printf>
    3406:	b5c9                	j	32c8 <diskfull+0x100>

0000000000003408 <iputtest>:
{
    3408:	1101                	addi	sp,sp,-32
    340a:	ec06                	sd	ra,24(sp)
    340c:	e822                	sd	s0,16(sp)
    340e:	e426                	sd	s1,8(sp)
    3410:	1000                	addi	s0,sp,32
    3412:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    3414:	00004517          	auipc	a0,0x4
    3418:	f7c50513          	addi	a0,a0,-132 # 7390 <malloc+0x138c>
    341c:	00003097          	auipc	ra,0x3
    3420:	812080e7          	jalr	-2030(ra) # 5c2e <mkdir>
    3424:	04054563          	bltz	a0,346e <iputtest+0x66>
  if(chdir("iputdir") < 0){
    3428:	00004517          	auipc	a0,0x4
    342c:	f6850513          	addi	a0,a0,-152 # 7390 <malloc+0x138c>
    3430:	00003097          	auipc	ra,0x3
    3434:	806080e7          	jalr	-2042(ra) # 5c36 <chdir>
    3438:	04054963          	bltz	a0,348a <iputtest+0x82>
  if(unlink("../iputdir") < 0){
    343c:	00004517          	auipc	a0,0x4
    3440:	f9450513          	addi	a0,a0,-108 # 73d0 <malloc+0x13cc>
    3444:	00002097          	auipc	ra,0x2
    3448:	7d2080e7          	jalr	2002(ra) # 5c16 <unlink>
    344c:	04054d63          	bltz	a0,34a6 <iputtest+0x9e>
  if(chdir("/") < 0){
    3450:	00004517          	auipc	a0,0x4
    3454:	fb050513          	addi	a0,a0,-80 # 7400 <malloc+0x13fc>
    3458:	00002097          	auipc	ra,0x2
    345c:	7de080e7          	jalr	2014(ra) # 5c36 <chdir>
    3460:	06054163          	bltz	a0,34c2 <iputtest+0xba>
}
    3464:	60e2                	ld	ra,24(sp)
    3466:	6442                	ld	s0,16(sp)
    3468:	64a2                	ld	s1,8(sp)
    346a:	6105                	addi	sp,sp,32
    346c:	8082                	ret
    printf("%s: mkdir failed\n", s);
    346e:	85a6                	mv	a1,s1
    3470:	00004517          	auipc	a0,0x4
    3474:	f2850513          	addi	a0,a0,-216 # 7398 <malloc+0x1394>
    3478:	00003097          	auipc	ra,0x3
    347c:	ace080e7          	jalr	-1330(ra) # 5f46 <printf>
    exit(1);
    3480:	4505                	li	a0,1
    3482:	00002097          	auipc	ra,0x2
    3486:	744080e7          	jalr	1860(ra) # 5bc6 <exit>
    printf("%s: chdir iputdir failed\n", s);
    348a:	85a6                	mv	a1,s1
    348c:	00004517          	auipc	a0,0x4
    3490:	f2450513          	addi	a0,a0,-220 # 73b0 <malloc+0x13ac>
    3494:	00003097          	auipc	ra,0x3
    3498:	ab2080e7          	jalr	-1358(ra) # 5f46 <printf>
    exit(1);
    349c:	4505                	li	a0,1
    349e:	00002097          	auipc	ra,0x2
    34a2:	728080e7          	jalr	1832(ra) # 5bc6 <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    34a6:	85a6                	mv	a1,s1
    34a8:	00004517          	auipc	a0,0x4
    34ac:	f3850513          	addi	a0,a0,-200 # 73e0 <malloc+0x13dc>
    34b0:	00003097          	auipc	ra,0x3
    34b4:	a96080e7          	jalr	-1386(ra) # 5f46 <printf>
    exit(1);
    34b8:	4505                	li	a0,1
    34ba:	00002097          	auipc	ra,0x2
    34be:	70c080e7          	jalr	1804(ra) # 5bc6 <exit>
    printf("%s: chdir / failed\n", s);
    34c2:	85a6                	mv	a1,s1
    34c4:	00004517          	auipc	a0,0x4
    34c8:	f4450513          	addi	a0,a0,-188 # 7408 <malloc+0x1404>
    34cc:	00003097          	auipc	ra,0x3
    34d0:	a7a080e7          	jalr	-1414(ra) # 5f46 <printf>
    exit(1);
    34d4:	4505                	li	a0,1
    34d6:	00002097          	auipc	ra,0x2
    34da:	6f0080e7          	jalr	1776(ra) # 5bc6 <exit>

00000000000034de <exitiputtest>:
{
    34de:	7179                	addi	sp,sp,-48
    34e0:	f406                	sd	ra,40(sp)
    34e2:	f022                	sd	s0,32(sp)
    34e4:	ec26                	sd	s1,24(sp)
    34e6:	1800                	addi	s0,sp,48
    34e8:	84aa                	mv	s1,a0
  pid = fork();
    34ea:	00002097          	auipc	ra,0x2
    34ee:	6d4080e7          	jalr	1748(ra) # 5bbe <fork>
  if(pid < 0){
    34f2:	04054663          	bltz	a0,353e <exitiputtest+0x60>
  if(pid == 0){
    34f6:	ed45                	bnez	a0,35ae <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
    34f8:	00004517          	auipc	a0,0x4
    34fc:	e9850513          	addi	a0,a0,-360 # 7390 <malloc+0x138c>
    3500:	00002097          	auipc	ra,0x2
    3504:	72e080e7          	jalr	1838(ra) # 5c2e <mkdir>
    3508:	04054963          	bltz	a0,355a <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
    350c:	00004517          	auipc	a0,0x4
    3510:	e8450513          	addi	a0,a0,-380 # 7390 <malloc+0x138c>
    3514:	00002097          	auipc	ra,0x2
    3518:	722080e7          	jalr	1826(ra) # 5c36 <chdir>
    351c:	04054d63          	bltz	a0,3576 <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
    3520:	00004517          	auipc	a0,0x4
    3524:	eb050513          	addi	a0,a0,-336 # 73d0 <malloc+0x13cc>
    3528:	00002097          	auipc	ra,0x2
    352c:	6ee080e7          	jalr	1774(ra) # 5c16 <unlink>
    3530:	06054163          	bltz	a0,3592 <exitiputtest+0xb4>
    exit(0);
    3534:	4501                	li	a0,0
    3536:	00002097          	auipc	ra,0x2
    353a:	690080e7          	jalr	1680(ra) # 5bc6 <exit>
    printf("%s: fork failed\n", s);
    353e:	85a6                	mv	a1,s1
    3540:	00003517          	auipc	a0,0x3
    3544:	49050513          	addi	a0,a0,1168 # 69d0 <malloc+0x9cc>
    3548:	00003097          	auipc	ra,0x3
    354c:	9fe080e7          	jalr	-1538(ra) # 5f46 <printf>
    exit(1);
    3550:	4505                	li	a0,1
    3552:	00002097          	auipc	ra,0x2
    3556:	674080e7          	jalr	1652(ra) # 5bc6 <exit>
      printf("%s: mkdir failed\n", s);
    355a:	85a6                	mv	a1,s1
    355c:	00004517          	auipc	a0,0x4
    3560:	e3c50513          	addi	a0,a0,-452 # 7398 <malloc+0x1394>
    3564:	00003097          	auipc	ra,0x3
    3568:	9e2080e7          	jalr	-1566(ra) # 5f46 <printf>
      exit(1);
    356c:	4505                	li	a0,1
    356e:	00002097          	auipc	ra,0x2
    3572:	658080e7          	jalr	1624(ra) # 5bc6 <exit>
      printf("%s: child chdir failed\n", s);
    3576:	85a6                	mv	a1,s1
    3578:	00004517          	auipc	a0,0x4
    357c:	ea850513          	addi	a0,a0,-344 # 7420 <malloc+0x141c>
    3580:	00003097          	auipc	ra,0x3
    3584:	9c6080e7          	jalr	-1594(ra) # 5f46 <printf>
      exit(1);
    3588:	4505                	li	a0,1
    358a:	00002097          	auipc	ra,0x2
    358e:	63c080e7          	jalr	1596(ra) # 5bc6 <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    3592:	85a6                	mv	a1,s1
    3594:	00004517          	auipc	a0,0x4
    3598:	e4c50513          	addi	a0,a0,-436 # 73e0 <malloc+0x13dc>
    359c:	00003097          	auipc	ra,0x3
    35a0:	9aa080e7          	jalr	-1622(ra) # 5f46 <printf>
      exit(1);
    35a4:	4505                	li	a0,1
    35a6:	00002097          	auipc	ra,0x2
    35aa:	620080e7          	jalr	1568(ra) # 5bc6 <exit>
  wait(&xstatus);
    35ae:	fdc40513          	addi	a0,s0,-36
    35b2:	00002097          	auipc	ra,0x2
    35b6:	61c080e7          	jalr	1564(ra) # 5bce <wait>
  exit(xstatus);
    35ba:	fdc42503          	lw	a0,-36(s0)
    35be:	00002097          	auipc	ra,0x2
    35c2:	608080e7          	jalr	1544(ra) # 5bc6 <exit>

00000000000035c6 <dirtest>:
{
    35c6:	1101                	addi	sp,sp,-32
    35c8:	ec06                	sd	ra,24(sp)
    35ca:	e822                	sd	s0,16(sp)
    35cc:	e426                	sd	s1,8(sp)
    35ce:	1000                	addi	s0,sp,32
    35d0:	84aa                	mv	s1,a0
  if(mkdir("dir0") < 0){
    35d2:	00004517          	auipc	a0,0x4
    35d6:	e6650513          	addi	a0,a0,-410 # 7438 <malloc+0x1434>
    35da:	00002097          	auipc	ra,0x2
    35de:	654080e7          	jalr	1620(ra) # 5c2e <mkdir>
    35e2:	04054563          	bltz	a0,362c <dirtest+0x66>
  if(chdir("dir0") < 0){
    35e6:	00004517          	auipc	a0,0x4
    35ea:	e5250513          	addi	a0,a0,-430 # 7438 <malloc+0x1434>
    35ee:	00002097          	auipc	ra,0x2
    35f2:	648080e7          	jalr	1608(ra) # 5c36 <chdir>
    35f6:	04054963          	bltz	a0,3648 <dirtest+0x82>
  if(chdir("..") < 0){
    35fa:	00004517          	auipc	a0,0x4
    35fe:	e5e50513          	addi	a0,a0,-418 # 7458 <malloc+0x1454>
    3602:	00002097          	auipc	ra,0x2
    3606:	634080e7          	jalr	1588(ra) # 5c36 <chdir>
    360a:	04054d63          	bltz	a0,3664 <dirtest+0x9e>
  if(unlink("dir0") < 0){
    360e:	00004517          	auipc	a0,0x4
    3612:	e2a50513          	addi	a0,a0,-470 # 7438 <malloc+0x1434>
    3616:	00002097          	auipc	ra,0x2
    361a:	600080e7          	jalr	1536(ra) # 5c16 <unlink>
    361e:	06054163          	bltz	a0,3680 <dirtest+0xba>
}
    3622:	60e2                	ld	ra,24(sp)
    3624:	6442                	ld	s0,16(sp)
    3626:	64a2                	ld	s1,8(sp)
    3628:	6105                	addi	sp,sp,32
    362a:	8082                	ret
    printf("%s: mkdir failed\n", s);
    362c:	85a6                	mv	a1,s1
    362e:	00004517          	auipc	a0,0x4
    3632:	d6a50513          	addi	a0,a0,-662 # 7398 <malloc+0x1394>
    3636:	00003097          	auipc	ra,0x3
    363a:	910080e7          	jalr	-1776(ra) # 5f46 <printf>
    exit(1);
    363e:	4505                	li	a0,1
    3640:	00002097          	auipc	ra,0x2
    3644:	586080e7          	jalr	1414(ra) # 5bc6 <exit>
    printf("%s: chdir dir0 failed\n", s);
    3648:	85a6                	mv	a1,s1
    364a:	00004517          	auipc	a0,0x4
    364e:	df650513          	addi	a0,a0,-522 # 7440 <malloc+0x143c>
    3652:	00003097          	auipc	ra,0x3
    3656:	8f4080e7          	jalr	-1804(ra) # 5f46 <printf>
    exit(1);
    365a:	4505                	li	a0,1
    365c:	00002097          	auipc	ra,0x2
    3660:	56a080e7          	jalr	1386(ra) # 5bc6 <exit>
    printf("%s: chdir .. failed\n", s);
    3664:	85a6                	mv	a1,s1
    3666:	00004517          	auipc	a0,0x4
    366a:	dfa50513          	addi	a0,a0,-518 # 7460 <malloc+0x145c>
    366e:	00003097          	auipc	ra,0x3
    3672:	8d8080e7          	jalr	-1832(ra) # 5f46 <printf>
    exit(1);
    3676:	4505                	li	a0,1
    3678:	00002097          	auipc	ra,0x2
    367c:	54e080e7          	jalr	1358(ra) # 5bc6 <exit>
    printf("%s: unlink dir0 failed\n", s);
    3680:	85a6                	mv	a1,s1
    3682:	00004517          	auipc	a0,0x4
    3686:	df650513          	addi	a0,a0,-522 # 7478 <malloc+0x1474>
    368a:	00003097          	auipc	ra,0x3
    368e:	8bc080e7          	jalr	-1860(ra) # 5f46 <printf>
    exit(1);
    3692:	4505                	li	a0,1
    3694:	00002097          	auipc	ra,0x2
    3698:	532080e7          	jalr	1330(ra) # 5bc6 <exit>

000000000000369c <subdir>:
{
    369c:	1101                	addi	sp,sp,-32
    369e:	ec06                	sd	ra,24(sp)
    36a0:	e822                	sd	s0,16(sp)
    36a2:	e426                	sd	s1,8(sp)
    36a4:	e04a                	sd	s2,0(sp)
    36a6:	1000                	addi	s0,sp,32
    36a8:	892a                	mv	s2,a0
  unlink("ff");
    36aa:	00004517          	auipc	a0,0x4
    36ae:	f1650513          	addi	a0,a0,-234 # 75c0 <malloc+0x15bc>
    36b2:	00002097          	auipc	ra,0x2
    36b6:	564080e7          	jalr	1380(ra) # 5c16 <unlink>
  if(mkdir("dd") != 0){
    36ba:	00004517          	auipc	a0,0x4
    36be:	dd650513          	addi	a0,a0,-554 # 7490 <malloc+0x148c>
    36c2:	00002097          	auipc	ra,0x2
    36c6:	56c080e7          	jalr	1388(ra) # 5c2e <mkdir>
    36ca:	38051663          	bnez	a0,3a56 <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    36ce:	20200593          	li	a1,514
    36d2:	00004517          	auipc	a0,0x4
    36d6:	dde50513          	addi	a0,a0,-546 # 74b0 <malloc+0x14ac>
    36da:	00002097          	auipc	ra,0x2
    36de:	52c080e7          	jalr	1324(ra) # 5c06 <open>
    36e2:	84aa                	mv	s1,a0
  if(fd < 0){
    36e4:	38054763          	bltz	a0,3a72 <subdir+0x3d6>
  write(fd, "ff", 2);
    36e8:	4609                	li	a2,2
    36ea:	00004597          	auipc	a1,0x4
    36ee:	ed658593          	addi	a1,a1,-298 # 75c0 <malloc+0x15bc>
    36f2:	00002097          	auipc	ra,0x2
    36f6:	4f4080e7          	jalr	1268(ra) # 5be6 <write>
  close(fd);
    36fa:	8526                	mv	a0,s1
    36fc:	00002097          	auipc	ra,0x2
    3700:	4f2080e7          	jalr	1266(ra) # 5bee <close>
  if(unlink("dd") >= 0){
    3704:	00004517          	auipc	a0,0x4
    3708:	d8c50513          	addi	a0,a0,-628 # 7490 <malloc+0x148c>
    370c:	00002097          	auipc	ra,0x2
    3710:	50a080e7          	jalr	1290(ra) # 5c16 <unlink>
    3714:	36055d63          	bgez	a0,3a8e <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    3718:	00004517          	auipc	a0,0x4
    371c:	df050513          	addi	a0,a0,-528 # 7508 <malloc+0x1504>
    3720:	00002097          	auipc	ra,0x2
    3724:	50e080e7          	jalr	1294(ra) # 5c2e <mkdir>
    3728:	38051163          	bnez	a0,3aaa <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    372c:	20200593          	li	a1,514
    3730:	00004517          	auipc	a0,0x4
    3734:	e0050513          	addi	a0,a0,-512 # 7530 <malloc+0x152c>
    3738:	00002097          	auipc	ra,0x2
    373c:	4ce080e7          	jalr	1230(ra) # 5c06 <open>
    3740:	84aa                	mv	s1,a0
  if(fd < 0){
    3742:	38054263          	bltz	a0,3ac6 <subdir+0x42a>
  write(fd, "FF", 2);
    3746:	4609                	li	a2,2
    3748:	00004597          	auipc	a1,0x4
    374c:	e1858593          	addi	a1,a1,-488 # 7560 <malloc+0x155c>
    3750:	00002097          	auipc	ra,0x2
    3754:	496080e7          	jalr	1174(ra) # 5be6 <write>
  close(fd);
    3758:	8526                	mv	a0,s1
    375a:	00002097          	auipc	ra,0x2
    375e:	494080e7          	jalr	1172(ra) # 5bee <close>
  fd = open("dd/dd/../ff", 0);
    3762:	4581                	li	a1,0
    3764:	00004517          	auipc	a0,0x4
    3768:	e0450513          	addi	a0,a0,-508 # 7568 <malloc+0x1564>
    376c:	00002097          	auipc	ra,0x2
    3770:	49a080e7          	jalr	1178(ra) # 5c06 <open>
    3774:	84aa                	mv	s1,a0
  if(fd < 0){
    3776:	36054663          	bltz	a0,3ae2 <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    377a:	660d                	lui	a2,0x3
    377c:	00009597          	auipc	a1,0x9
    3780:	4fc58593          	addi	a1,a1,1276 # cc78 <buf>
    3784:	00002097          	auipc	ra,0x2
    3788:	45a080e7          	jalr	1114(ra) # 5bde <read>
  if(cc != 2 || buf[0] != 'f'){
    378c:	4789                	li	a5,2
    378e:	36f51863          	bne	a0,a5,3afe <subdir+0x462>
    3792:	00009717          	auipc	a4,0x9
    3796:	4e674703          	lbu	a4,1254(a4) # cc78 <buf>
    379a:	06600793          	li	a5,102
    379e:	36f71063          	bne	a4,a5,3afe <subdir+0x462>
  close(fd);
    37a2:	8526                	mv	a0,s1
    37a4:	00002097          	auipc	ra,0x2
    37a8:	44a080e7          	jalr	1098(ra) # 5bee <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    37ac:	00004597          	auipc	a1,0x4
    37b0:	e0c58593          	addi	a1,a1,-500 # 75b8 <malloc+0x15b4>
    37b4:	00004517          	auipc	a0,0x4
    37b8:	d7c50513          	addi	a0,a0,-644 # 7530 <malloc+0x152c>
    37bc:	00002097          	auipc	ra,0x2
    37c0:	46a080e7          	jalr	1130(ra) # 5c26 <link>
    37c4:	34051b63          	bnez	a0,3b1a <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    37c8:	00004517          	auipc	a0,0x4
    37cc:	d6850513          	addi	a0,a0,-664 # 7530 <malloc+0x152c>
    37d0:	00002097          	auipc	ra,0x2
    37d4:	446080e7          	jalr	1094(ra) # 5c16 <unlink>
    37d8:	34051f63          	bnez	a0,3b36 <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    37dc:	4581                	li	a1,0
    37de:	00004517          	auipc	a0,0x4
    37e2:	d5250513          	addi	a0,a0,-686 # 7530 <malloc+0x152c>
    37e6:	00002097          	auipc	ra,0x2
    37ea:	420080e7          	jalr	1056(ra) # 5c06 <open>
    37ee:	36055263          	bgez	a0,3b52 <subdir+0x4b6>
  if(chdir("dd") != 0){
    37f2:	00004517          	auipc	a0,0x4
    37f6:	c9e50513          	addi	a0,a0,-866 # 7490 <malloc+0x148c>
    37fa:	00002097          	auipc	ra,0x2
    37fe:	43c080e7          	jalr	1084(ra) # 5c36 <chdir>
    3802:	36051663          	bnez	a0,3b6e <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    3806:	00004517          	auipc	a0,0x4
    380a:	e4a50513          	addi	a0,a0,-438 # 7650 <malloc+0x164c>
    380e:	00002097          	auipc	ra,0x2
    3812:	428080e7          	jalr	1064(ra) # 5c36 <chdir>
    3816:	36051a63          	bnez	a0,3b8a <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    381a:	00004517          	auipc	a0,0x4
    381e:	e6650513          	addi	a0,a0,-410 # 7680 <malloc+0x167c>
    3822:	00002097          	auipc	ra,0x2
    3826:	414080e7          	jalr	1044(ra) # 5c36 <chdir>
    382a:	36051e63          	bnez	a0,3ba6 <subdir+0x50a>
  if(chdir("./..") != 0){
    382e:	00004517          	auipc	a0,0x4
    3832:	e8250513          	addi	a0,a0,-382 # 76b0 <malloc+0x16ac>
    3836:	00002097          	auipc	ra,0x2
    383a:	400080e7          	jalr	1024(ra) # 5c36 <chdir>
    383e:	38051263          	bnez	a0,3bc2 <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    3842:	4581                	li	a1,0
    3844:	00004517          	auipc	a0,0x4
    3848:	d7450513          	addi	a0,a0,-652 # 75b8 <malloc+0x15b4>
    384c:	00002097          	auipc	ra,0x2
    3850:	3ba080e7          	jalr	954(ra) # 5c06 <open>
    3854:	84aa                	mv	s1,a0
  if(fd < 0){
    3856:	38054463          	bltz	a0,3bde <subdir+0x542>
  if(read(fd, buf, sizeof(buf)) != 2){
    385a:	660d                	lui	a2,0x3
    385c:	00009597          	auipc	a1,0x9
    3860:	41c58593          	addi	a1,a1,1052 # cc78 <buf>
    3864:	00002097          	auipc	ra,0x2
    3868:	37a080e7          	jalr	890(ra) # 5bde <read>
    386c:	4789                	li	a5,2
    386e:	38f51663          	bne	a0,a5,3bfa <subdir+0x55e>
  close(fd);
    3872:	8526                	mv	a0,s1
    3874:	00002097          	auipc	ra,0x2
    3878:	37a080e7          	jalr	890(ra) # 5bee <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    387c:	4581                	li	a1,0
    387e:	00004517          	auipc	a0,0x4
    3882:	cb250513          	addi	a0,a0,-846 # 7530 <malloc+0x152c>
    3886:	00002097          	auipc	ra,0x2
    388a:	380080e7          	jalr	896(ra) # 5c06 <open>
    388e:	38055463          	bgez	a0,3c16 <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    3892:	20200593          	li	a1,514
    3896:	00004517          	auipc	a0,0x4
    389a:	eaa50513          	addi	a0,a0,-342 # 7740 <malloc+0x173c>
    389e:	00002097          	auipc	ra,0x2
    38a2:	368080e7          	jalr	872(ra) # 5c06 <open>
    38a6:	38055663          	bgez	a0,3c32 <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    38aa:	20200593          	li	a1,514
    38ae:	00004517          	auipc	a0,0x4
    38b2:	ec250513          	addi	a0,a0,-318 # 7770 <malloc+0x176c>
    38b6:	00002097          	auipc	ra,0x2
    38ba:	350080e7          	jalr	848(ra) # 5c06 <open>
    38be:	38055863          	bgez	a0,3c4e <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    38c2:	20000593          	li	a1,512
    38c6:	00004517          	auipc	a0,0x4
    38ca:	bca50513          	addi	a0,a0,-1078 # 7490 <malloc+0x148c>
    38ce:	00002097          	auipc	ra,0x2
    38d2:	338080e7          	jalr	824(ra) # 5c06 <open>
    38d6:	38055a63          	bgez	a0,3c6a <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    38da:	4589                	li	a1,2
    38dc:	00004517          	auipc	a0,0x4
    38e0:	bb450513          	addi	a0,a0,-1100 # 7490 <malloc+0x148c>
    38e4:	00002097          	auipc	ra,0x2
    38e8:	322080e7          	jalr	802(ra) # 5c06 <open>
    38ec:	38055d63          	bgez	a0,3c86 <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    38f0:	4585                	li	a1,1
    38f2:	00004517          	auipc	a0,0x4
    38f6:	b9e50513          	addi	a0,a0,-1122 # 7490 <malloc+0x148c>
    38fa:	00002097          	auipc	ra,0x2
    38fe:	30c080e7          	jalr	780(ra) # 5c06 <open>
    3902:	3a055063          	bgez	a0,3ca2 <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    3906:	00004597          	auipc	a1,0x4
    390a:	efa58593          	addi	a1,a1,-262 # 7800 <malloc+0x17fc>
    390e:	00004517          	auipc	a0,0x4
    3912:	e3250513          	addi	a0,a0,-462 # 7740 <malloc+0x173c>
    3916:	00002097          	auipc	ra,0x2
    391a:	310080e7          	jalr	784(ra) # 5c26 <link>
    391e:	3a050063          	beqz	a0,3cbe <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    3922:	00004597          	auipc	a1,0x4
    3926:	ede58593          	addi	a1,a1,-290 # 7800 <malloc+0x17fc>
    392a:	00004517          	auipc	a0,0x4
    392e:	e4650513          	addi	a0,a0,-442 # 7770 <malloc+0x176c>
    3932:	00002097          	auipc	ra,0x2
    3936:	2f4080e7          	jalr	756(ra) # 5c26 <link>
    393a:	3a050063          	beqz	a0,3cda <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    393e:	00004597          	auipc	a1,0x4
    3942:	c7a58593          	addi	a1,a1,-902 # 75b8 <malloc+0x15b4>
    3946:	00004517          	auipc	a0,0x4
    394a:	b6a50513          	addi	a0,a0,-1174 # 74b0 <malloc+0x14ac>
    394e:	00002097          	auipc	ra,0x2
    3952:	2d8080e7          	jalr	728(ra) # 5c26 <link>
    3956:	3a050063          	beqz	a0,3cf6 <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    395a:	00004517          	auipc	a0,0x4
    395e:	de650513          	addi	a0,a0,-538 # 7740 <malloc+0x173c>
    3962:	00002097          	auipc	ra,0x2
    3966:	2cc080e7          	jalr	716(ra) # 5c2e <mkdir>
    396a:	3a050463          	beqz	a0,3d12 <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    396e:	00004517          	auipc	a0,0x4
    3972:	e0250513          	addi	a0,a0,-510 # 7770 <malloc+0x176c>
    3976:	00002097          	auipc	ra,0x2
    397a:	2b8080e7          	jalr	696(ra) # 5c2e <mkdir>
    397e:	3a050863          	beqz	a0,3d2e <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    3982:	00004517          	auipc	a0,0x4
    3986:	c3650513          	addi	a0,a0,-970 # 75b8 <malloc+0x15b4>
    398a:	00002097          	auipc	ra,0x2
    398e:	2a4080e7          	jalr	676(ra) # 5c2e <mkdir>
    3992:	3a050c63          	beqz	a0,3d4a <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    3996:	00004517          	auipc	a0,0x4
    399a:	dda50513          	addi	a0,a0,-550 # 7770 <malloc+0x176c>
    399e:	00002097          	auipc	ra,0x2
    39a2:	278080e7          	jalr	632(ra) # 5c16 <unlink>
    39a6:	3c050063          	beqz	a0,3d66 <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    39aa:	00004517          	auipc	a0,0x4
    39ae:	d9650513          	addi	a0,a0,-618 # 7740 <malloc+0x173c>
    39b2:	00002097          	auipc	ra,0x2
    39b6:	264080e7          	jalr	612(ra) # 5c16 <unlink>
    39ba:	3c050463          	beqz	a0,3d82 <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    39be:	00004517          	auipc	a0,0x4
    39c2:	af250513          	addi	a0,a0,-1294 # 74b0 <malloc+0x14ac>
    39c6:	00002097          	auipc	ra,0x2
    39ca:	270080e7          	jalr	624(ra) # 5c36 <chdir>
    39ce:	3c050863          	beqz	a0,3d9e <subdir+0x702>
  if(chdir("dd/xx") == 0){
    39d2:	00004517          	auipc	a0,0x4
    39d6:	f7e50513          	addi	a0,a0,-130 # 7950 <malloc+0x194c>
    39da:	00002097          	auipc	ra,0x2
    39de:	25c080e7          	jalr	604(ra) # 5c36 <chdir>
    39e2:	3c050c63          	beqz	a0,3dba <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    39e6:	00004517          	auipc	a0,0x4
    39ea:	bd250513          	addi	a0,a0,-1070 # 75b8 <malloc+0x15b4>
    39ee:	00002097          	auipc	ra,0x2
    39f2:	228080e7          	jalr	552(ra) # 5c16 <unlink>
    39f6:	3e051063          	bnez	a0,3dd6 <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    39fa:	00004517          	auipc	a0,0x4
    39fe:	ab650513          	addi	a0,a0,-1354 # 74b0 <malloc+0x14ac>
    3a02:	00002097          	auipc	ra,0x2
    3a06:	214080e7          	jalr	532(ra) # 5c16 <unlink>
    3a0a:	3e051463          	bnez	a0,3df2 <subdir+0x756>
  if(unlink("dd") == 0){
    3a0e:	00004517          	auipc	a0,0x4
    3a12:	a8250513          	addi	a0,a0,-1406 # 7490 <malloc+0x148c>
    3a16:	00002097          	auipc	ra,0x2
    3a1a:	200080e7          	jalr	512(ra) # 5c16 <unlink>
    3a1e:	3e050863          	beqz	a0,3e0e <subdir+0x772>
  if(unlink("dd/dd") < 0){
    3a22:	00004517          	auipc	a0,0x4
    3a26:	f9e50513          	addi	a0,a0,-98 # 79c0 <malloc+0x19bc>
    3a2a:	00002097          	auipc	ra,0x2
    3a2e:	1ec080e7          	jalr	492(ra) # 5c16 <unlink>
    3a32:	3e054c63          	bltz	a0,3e2a <subdir+0x78e>
  if(unlink("dd") < 0){
    3a36:	00004517          	auipc	a0,0x4
    3a3a:	a5a50513          	addi	a0,a0,-1446 # 7490 <malloc+0x148c>
    3a3e:	00002097          	auipc	ra,0x2
    3a42:	1d8080e7          	jalr	472(ra) # 5c16 <unlink>
    3a46:	40054063          	bltz	a0,3e46 <subdir+0x7aa>
}
    3a4a:	60e2                	ld	ra,24(sp)
    3a4c:	6442                	ld	s0,16(sp)
    3a4e:	64a2                	ld	s1,8(sp)
    3a50:	6902                	ld	s2,0(sp)
    3a52:	6105                	addi	sp,sp,32
    3a54:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    3a56:	85ca                	mv	a1,s2
    3a58:	00004517          	auipc	a0,0x4
    3a5c:	a4050513          	addi	a0,a0,-1472 # 7498 <malloc+0x1494>
    3a60:	00002097          	auipc	ra,0x2
    3a64:	4e6080e7          	jalr	1254(ra) # 5f46 <printf>
    exit(1);
    3a68:	4505                	li	a0,1
    3a6a:	00002097          	auipc	ra,0x2
    3a6e:	15c080e7          	jalr	348(ra) # 5bc6 <exit>
    printf("%s: create dd/ff failed\n", s);
    3a72:	85ca                	mv	a1,s2
    3a74:	00004517          	auipc	a0,0x4
    3a78:	a4450513          	addi	a0,a0,-1468 # 74b8 <malloc+0x14b4>
    3a7c:	00002097          	auipc	ra,0x2
    3a80:	4ca080e7          	jalr	1226(ra) # 5f46 <printf>
    exit(1);
    3a84:	4505                	li	a0,1
    3a86:	00002097          	auipc	ra,0x2
    3a8a:	140080e7          	jalr	320(ra) # 5bc6 <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    3a8e:	85ca                	mv	a1,s2
    3a90:	00004517          	auipc	a0,0x4
    3a94:	a4850513          	addi	a0,a0,-1464 # 74d8 <malloc+0x14d4>
    3a98:	00002097          	auipc	ra,0x2
    3a9c:	4ae080e7          	jalr	1198(ra) # 5f46 <printf>
    exit(1);
    3aa0:	4505                	li	a0,1
    3aa2:	00002097          	auipc	ra,0x2
    3aa6:	124080e7          	jalr	292(ra) # 5bc6 <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    3aaa:	85ca                	mv	a1,s2
    3aac:	00004517          	auipc	a0,0x4
    3ab0:	a6450513          	addi	a0,a0,-1436 # 7510 <malloc+0x150c>
    3ab4:	00002097          	auipc	ra,0x2
    3ab8:	492080e7          	jalr	1170(ra) # 5f46 <printf>
    exit(1);
    3abc:	4505                	li	a0,1
    3abe:	00002097          	auipc	ra,0x2
    3ac2:	108080e7          	jalr	264(ra) # 5bc6 <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    3ac6:	85ca                	mv	a1,s2
    3ac8:	00004517          	auipc	a0,0x4
    3acc:	a7850513          	addi	a0,a0,-1416 # 7540 <malloc+0x153c>
    3ad0:	00002097          	auipc	ra,0x2
    3ad4:	476080e7          	jalr	1142(ra) # 5f46 <printf>
    exit(1);
    3ad8:	4505                	li	a0,1
    3ada:	00002097          	auipc	ra,0x2
    3ade:	0ec080e7          	jalr	236(ra) # 5bc6 <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    3ae2:	85ca                	mv	a1,s2
    3ae4:	00004517          	auipc	a0,0x4
    3ae8:	a9450513          	addi	a0,a0,-1388 # 7578 <malloc+0x1574>
    3aec:	00002097          	auipc	ra,0x2
    3af0:	45a080e7          	jalr	1114(ra) # 5f46 <printf>
    exit(1);
    3af4:	4505                	li	a0,1
    3af6:	00002097          	auipc	ra,0x2
    3afa:	0d0080e7          	jalr	208(ra) # 5bc6 <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    3afe:	85ca                	mv	a1,s2
    3b00:	00004517          	auipc	a0,0x4
    3b04:	a9850513          	addi	a0,a0,-1384 # 7598 <malloc+0x1594>
    3b08:	00002097          	auipc	ra,0x2
    3b0c:	43e080e7          	jalr	1086(ra) # 5f46 <printf>
    exit(1);
    3b10:	4505                	li	a0,1
    3b12:	00002097          	auipc	ra,0x2
    3b16:	0b4080e7          	jalr	180(ra) # 5bc6 <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    3b1a:	85ca                	mv	a1,s2
    3b1c:	00004517          	auipc	a0,0x4
    3b20:	aac50513          	addi	a0,a0,-1364 # 75c8 <malloc+0x15c4>
    3b24:	00002097          	auipc	ra,0x2
    3b28:	422080e7          	jalr	1058(ra) # 5f46 <printf>
    exit(1);
    3b2c:	4505                	li	a0,1
    3b2e:	00002097          	auipc	ra,0x2
    3b32:	098080e7          	jalr	152(ra) # 5bc6 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3b36:	85ca                	mv	a1,s2
    3b38:	00004517          	auipc	a0,0x4
    3b3c:	ab850513          	addi	a0,a0,-1352 # 75f0 <malloc+0x15ec>
    3b40:	00002097          	auipc	ra,0x2
    3b44:	406080e7          	jalr	1030(ra) # 5f46 <printf>
    exit(1);
    3b48:	4505                	li	a0,1
    3b4a:	00002097          	auipc	ra,0x2
    3b4e:	07c080e7          	jalr	124(ra) # 5bc6 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    3b52:	85ca                	mv	a1,s2
    3b54:	00004517          	auipc	a0,0x4
    3b58:	abc50513          	addi	a0,a0,-1348 # 7610 <malloc+0x160c>
    3b5c:	00002097          	auipc	ra,0x2
    3b60:	3ea080e7          	jalr	1002(ra) # 5f46 <printf>
    exit(1);
    3b64:	4505                	li	a0,1
    3b66:	00002097          	auipc	ra,0x2
    3b6a:	060080e7          	jalr	96(ra) # 5bc6 <exit>
    printf("%s: chdir dd failed\n", s);
    3b6e:	85ca                	mv	a1,s2
    3b70:	00004517          	auipc	a0,0x4
    3b74:	ac850513          	addi	a0,a0,-1336 # 7638 <malloc+0x1634>
    3b78:	00002097          	auipc	ra,0x2
    3b7c:	3ce080e7          	jalr	974(ra) # 5f46 <printf>
    exit(1);
    3b80:	4505                	li	a0,1
    3b82:	00002097          	auipc	ra,0x2
    3b86:	044080e7          	jalr	68(ra) # 5bc6 <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    3b8a:	85ca                	mv	a1,s2
    3b8c:	00004517          	auipc	a0,0x4
    3b90:	ad450513          	addi	a0,a0,-1324 # 7660 <malloc+0x165c>
    3b94:	00002097          	auipc	ra,0x2
    3b98:	3b2080e7          	jalr	946(ra) # 5f46 <printf>
    exit(1);
    3b9c:	4505                	li	a0,1
    3b9e:	00002097          	auipc	ra,0x2
    3ba2:	028080e7          	jalr	40(ra) # 5bc6 <exit>
    printf("chdir dd/../../dd failed\n", s);
    3ba6:	85ca                	mv	a1,s2
    3ba8:	00004517          	auipc	a0,0x4
    3bac:	ae850513          	addi	a0,a0,-1304 # 7690 <malloc+0x168c>
    3bb0:	00002097          	auipc	ra,0x2
    3bb4:	396080e7          	jalr	918(ra) # 5f46 <printf>
    exit(1);
    3bb8:	4505                	li	a0,1
    3bba:	00002097          	auipc	ra,0x2
    3bbe:	00c080e7          	jalr	12(ra) # 5bc6 <exit>
    printf("%s: chdir ./.. failed\n", s);
    3bc2:	85ca                	mv	a1,s2
    3bc4:	00004517          	auipc	a0,0x4
    3bc8:	af450513          	addi	a0,a0,-1292 # 76b8 <malloc+0x16b4>
    3bcc:	00002097          	auipc	ra,0x2
    3bd0:	37a080e7          	jalr	890(ra) # 5f46 <printf>
    exit(1);
    3bd4:	4505                	li	a0,1
    3bd6:	00002097          	auipc	ra,0x2
    3bda:	ff0080e7          	jalr	-16(ra) # 5bc6 <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    3bde:	85ca                	mv	a1,s2
    3be0:	00004517          	auipc	a0,0x4
    3be4:	af050513          	addi	a0,a0,-1296 # 76d0 <malloc+0x16cc>
    3be8:	00002097          	auipc	ra,0x2
    3bec:	35e080e7          	jalr	862(ra) # 5f46 <printf>
    exit(1);
    3bf0:	4505                	li	a0,1
    3bf2:	00002097          	auipc	ra,0x2
    3bf6:	fd4080e7          	jalr	-44(ra) # 5bc6 <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    3bfa:	85ca                	mv	a1,s2
    3bfc:	00004517          	auipc	a0,0x4
    3c00:	af450513          	addi	a0,a0,-1292 # 76f0 <malloc+0x16ec>
    3c04:	00002097          	auipc	ra,0x2
    3c08:	342080e7          	jalr	834(ra) # 5f46 <printf>
    exit(1);
    3c0c:	4505                	li	a0,1
    3c0e:	00002097          	auipc	ra,0x2
    3c12:	fb8080e7          	jalr	-72(ra) # 5bc6 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    3c16:	85ca                	mv	a1,s2
    3c18:	00004517          	auipc	a0,0x4
    3c1c:	af850513          	addi	a0,a0,-1288 # 7710 <malloc+0x170c>
    3c20:	00002097          	auipc	ra,0x2
    3c24:	326080e7          	jalr	806(ra) # 5f46 <printf>
    exit(1);
    3c28:	4505                	li	a0,1
    3c2a:	00002097          	auipc	ra,0x2
    3c2e:	f9c080e7          	jalr	-100(ra) # 5bc6 <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    3c32:	85ca                	mv	a1,s2
    3c34:	00004517          	auipc	a0,0x4
    3c38:	b1c50513          	addi	a0,a0,-1252 # 7750 <malloc+0x174c>
    3c3c:	00002097          	auipc	ra,0x2
    3c40:	30a080e7          	jalr	778(ra) # 5f46 <printf>
    exit(1);
    3c44:	4505                	li	a0,1
    3c46:	00002097          	auipc	ra,0x2
    3c4a:	f80080e7          	jalr	-128(ra) # 5bc6 <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    3c4e:	85ca                	mv	a1,s2
    3c50:	00004517          	auipc	a0,0x4
    3c54:	b3050513          	addi	a0,a0,-1232 # 7780 <malloc+0x177c>
    3c58:	00002097          	auipc	ra,0x2
    3c5c:	2ee080e7          	jalr	750(ra) # 5f46 <printf>
    exit(1);
    3c60:	4505                	li	a0,1
    3c62:	00002097          	auipc	ra,0x2
    3c66:	f64080e7          	jalr	-156(ra) # 5bc6 <exit>
    printf("%s: create dd succeeded!\n", s);
    3c6a:	85ca                	mv	a1,s2
    3c6c:	00004517          	auipc	a0,0x4
    3c70:	b3450513          	addi	a0,a0,-1228 # 77a0 <malloc+0x179c>
    3c74:	00002097          	auipc	ra,0x2
    3c78:	2d2080e7          	jalr	722(ra) # 5f46 <printf>
    exit(1);
    3c7c:	4505                	li	a0,1
    3c7e:	00002097          	auipc	ra,0x2
    3c82:	f48080e7          	jalr	-184(ra) # 5bc6 <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    3c86:	85ca                	mv	a1,s2
    3c88:	00004517          	auipc	a0,0x4
    3c8c:	b3850513          	addi	a0,a0,-1224 # 77c0 <malloc+0x17bc>
    3c90:	00002097          	auipc	ra,0x2
    3c94:	2b6080e7          	jalr	694(ra) # 5f46 <printf>
    exit(1);
    3c98:	4505                	li	a0,1
    3c9a:	00002097          	auipc	ra,0x2
    3c9e:	f2c080e7          	jalr	-212(ra) # 5bc6 <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    3ca2:	85ca                	mv	a1,s2
    3ca4:	00004517          	auipc	a0,0x4
    3ca8:	b3c50513          	addi	a0,a0,-1220 # 77e0 <malloc+0x17dc>
    3cac:	00002097          	auipc	ra,0x2
    3cb0:	29a080e7          	jalr	666(ra) # 5f46 <printf>
    exit(1);
    3cb4:	4505                	li	a0,1
    3cb6:	00002097          	auipc	ra,0x2
    3cba:	f10080e7          	jalr	-240(ra) # 5bc6 <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    3cbe:	85ca                	mv	a1,s2
    3cc0:	00004517          	auipc	a0,0x4
    3cc4:	b5050513          	addi	a0,a0,-1200 # 7810 <malloc+0x180c>
    3cc8:	00002097          	auipc	ra,0x2
    3ccc:	27e080e7          	jalr	638(ra) # 5f46 <printf>
    exit(1);
    3cd0:	4505                	li	a0,1
    3cd2:	00002097          	auipc	ra,0x2
    3cd6:	ef4080e7          	jalr	-268(ra) # 5bc6 <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    3cda:	85ca                	mv	a1,s2
    3cdc:	00004517          	auipc	a0,0x4
    3ce0:	b5c50513          	addi	a0,a0,-1188 # 7838 <malloc+0x1834>
    3ce4:	00002097          	auipc	ra,0x2
    3ce8:	262080e7          	jalr	610(ra) # 5f46 <printf>
    exit(1);
    3cec:	4505                	li	a0,1
    3cee:	00002097          	auipc	ra,0x2
    3cf2:	ed8080e7          	jalr	-296(ra) # 5bc6 <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    3cf6:	85ca                	mv	a1,s2
    3cf8:	00004517          	auipc	a0,0x4
    3cfc:	b6850513          	addi	a0,a0,-1176 # 7860 <malloc+0x185c>
    3d00:	00002097          	auipc	ra,0x2
    3d04:	246080e7          	jalr	582(ra) # 5f46 <printf>
    exit(1);
    3d08:	4505                	li	a0,1
    3d0a:	00002097          	auipc	ra,0x2
    3d0e:	ebc080e7          	jalr	-324(ra) # 5bc6 <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    3d12:	85ca                	mv	a1,s2
    3d14:	00004517          	auipc	a0,0x4
    3d18:	b7450513          	addi	a0,a0,-1164 # 7888 <malloc+0x1884>
    3d1c:	00002097          	auipc	ra,0x2
    3d20:	22a080e7          	jalr	554(ra) # 5f46 <printf>
    exit(1);
    3d24:	4505                	li	a0,1
    3d26:	00002097          	auipc	ra,0x2
    3d2a:	ea0080e7          	jalr	-352(ra) # 5bc6 <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    3d2e:	85ca                	mv	a1,s2
    3d30:	00004517          	auipc	a0,0x4
    3d34:	b7850513          	addi	a0,a0,-1160 # 78a8 <malloc+0x18a4>
    3d38:	00002097          	auipc	ra,0x2
    3d3c:	20e080e7          	jalr	526(ra) # 5f46 <printf>
    exit(1);
    3d40:	4505                	li	a0,1
    3d42:	00002097          	auipc	ra,0x2
    3d46:	e84080e7          	jalr	-380(ra) # 5bc6 <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    3d4a:	85ca                	mv	a1,s2
    3d4c:	00004517          	auipc	a0,0x4
    3d50:	b7c50513          	addi	a0,a0,-1156 # 78c8 <malloc+0x18c4>
    3d54:	00002097          	auipc	ra,0x2
    3d58:	1f2080e7          	jalr	498(ra) # 5f46 <printf>
    exit(1);
    3d5c:	4505                	li	a0,1
    3d5e:	00002097          	auipc	ra,0x2
    3d62:	e68080e7          	jalr	-408(ra) # 5bc6 <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    3d66:	85ca                	mv	a1,s2
    3d68:	00004517          	auipc	a0,0x4
    3d6c:	b8850513          	addi	a0,a0,-1144 # 78f0 <malloc+0x18ec>
    3d70:	00002097          	auipc	ra,0x2
    3d74:	1d6080e7          	jalr	470(ra) # 5f46 <printf>
    exit(1);
    3d78:	4505                	li	a0,1
    3d7a:	00002097          	auipc	ra,0x2
    3d7e:	e4c080e7          	jalr	-436(ra) # 5bc6 <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    3d82:	85ca                	mv	a1,s2
    3d84:	00004517          	auipc	a0,0x4
    3d88:	b8c50513          	addi	a0,a0,-1140 # 7910 <malloc+0x190c>
    3d8c:	00002097          	auipc	ra,0x2
    3d90:	1ba080e7          	jalr	442(ra) # 5f46 <printf>
    exit(1);
    3d94:	4505                	li	a0,1
    3d96:	00002097          	auipc	ra,0x2
    3d9a:	e30080e7          	jalr	-464(ra) # 5bc6 <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    3d9e:	85ca                	mv	a1,s2
    3da0:	00004517          	auipc	a0,0x4
    3da4:	b9050513          	addi	a0,a0,-1136 # 7930 <malloc+0x192c>
    3da8:	00002097          	auipc	ra,0x2
    3dac:	19e080e7          	jalr	414(ra) # 5f46 <printf>
    exit(1);
    3db0:	4505                	li	a0,1
    3db2:	00002097          	auipc	ra,0x2
    3db6:	e14080e7          	jalr	-492(ra) # 5bc6 <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    3dba:	85ca                	mv	a1,s2
    3dbc:	00004517          	auipc	a0,0x4
    3dc0:	b9c50513          	addi	a0,a0,-1124 # 7958 <malloc+0x1954>
    3dc4:	00002097          	auipc	ra,0x2
    3dc8:	182080e7          	jalr	386(ra) # 5f46 <printf>
    exit(1);
    3dcc:	4505                	li	a0,1
    3dce:	00002097          	auipc	ra,0x2
    3dd2:	df8080e7          	jalr	-520(ra) # 5bc6 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3dd6:	85ca                	mv	a1,s2
    3dd8:	00004517          	auipc	a0,0x4
    3ddc:	81850513          	addi	a0,a0,-2024 # 75f0 <malloc+0x15ec>
    3de0:	00002097          	auipc	ra,0x2
    3de4:	166080e7          	jalr	358(ra) # 5f46 <printf>
    exit(1);
    3de8:	4505                	li	a0,1
    3dea:	00002097          	auipc	ra,0x2
    3dee:	ddc080e7          	jalr	-548(ra) # 5bc6 <exit>
    printf("%s: unlink dd/ff failed\n", s);
    3df2:	85ca                	mv	a1,s2
    3df4:	00004517          	auipc	a0,0x4
    3df8:	b8450513          	addi	a0,a0,-1148 # 7978 <malloc+0x1974>
    3dfc:	00002097          	auipc	ra,0x2
    3e00:	14a080e7          	jalr	330(ra) # 5f46 <printf>
    exit(1);
    3e04:	4505                	li	a0,1
    3e06:	00002097          	auipc	ra,0x2
    3e0a:	dc0080e7          	jalr	-576(ra) # 5bc6 <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    3e0e:	85ca                	mv	a1,s2
    3e10:	00004517          	auipc	a0,0x4
    3e14:	b8850513          	addi	a0,a0,-1144 # 7998 <malloc+0x1994>
    3e18:	00002097          	auipc	ra,0x2
    3e1c:	12e080e7          	jalr	302(ra) # 5f46 <printf>
    exit(1);
    3e20:	4505                	li	a0,1
    3e22:	00002097          	auipc	ra,0x2
    3e26:	da4080e7          	jalr	-604(ra) # 5bc6 <exit>
    printf("%s: unlink dd/dd failed\n", s);
    3e2a:	85ca                	mv	a1,s2
    3e2c:	00004517          	auipc	a0,0x4
    3e30:	b9c50513          	addi	a0,a0,-1124 # 79c8 <malloc+0x19c4>
    3e34:	00002097          	auipc	ra,0x2
    3e38:	112080e7          	jalr	274(ra) # 5f46 <printf>
    exit(1);
    3e3c:	4505                	li	a0,1
    3e3e:	00002097          	auipc	ra,0x2
    3e42:	d88080e7          	jalr	-632(ra) # 5bc6 <exit>
    printf("%s: unlink dd failed\n", s);
    3e46:	85ca                	mv	a1,s2
    3e48:	00004517          	auipc	a0,0x4
    3e4c:	ba050513          	addi	a0,a0,-1120 # 79e8 <malloc+0x19e4>
    3e50:	00002097          	auipc	ra,0x2
    3e54:	0f6080e7          	jalr	246(ra) # 5f46 <printf>
    exit(1);
    3e58:	4505                	li	a0,1
    3e5a:	00002097          	auipc	ra,0x2
    3e5e:	d6c080e7          	jalr	-660(ra) # 5bc6 <exit>

0000000000003e62 <rmdot>:
{
    3e62:	1101                	addi	sp,sp,-32
    3e64:	ec06                	sd	ra,24(sp)
    3e66:	e822                	sd	s0,16(sp)
    3e68:	e426                	sd	s1,8(sp)
    3e6a:	1000                	addi	s0,sp,32
    3e6c:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    3e6e:	00004517          	auipc	a0,0x4
    3e72:	b9250513          	addi	a0,a0,-1134 # 7a00 <malloc+0x19fc>
    3e76:	00002097          	auipc	ra,0x2
    3e7a:	db8080e7          	jalr	-584(ra) # 5c2e <mkdir>
    3e7e:	e549                	bnez	a0,3f08 <rmdot+0xa6>
  if(chdir("dots") != 0){
    3e80:	00004517          	auipc	a0,0x4
    3e84:	b8050513          	addi	a0,a0,-1152 # 7a00 <malloc+0x19fc>
    3e88:	00002097          	auipc	ra,0x2
    3e8c:	dae080e7          	jalr	-594(ra) # 5c36 <chdir>
    3e90:	e951                	bnez	a0,3f24 <rmdot+0xc2>
  if(unlink(".") == 0){
    3e92:	00003517          	auipc	a0,0x3
    3e96:	99e50513          	addi	a0,a0,-1634 # 6830 <malloc+0x82c>
    3e9a:	00002097          	auipc	ra,0x2
    3e9e:	d7c080e7          	jalr	-644(ra) # 5c16 <unlink>
    3ea2:	cd59                	beqz	a0,3f40 <rmdot+0xde>
  if(unlink("..") == 0){
    3ea4:	00003517          	auipc	a0,0x3
    3ea8:	5b450513          	addi	a0,a0,1460 # 7458 <malloc+0x1454>
    3eac:	00002097          	auipc	ra,0x2
    3eb0:	d6a080e7          	jalr	-662(ra) # 5c16 <unlink>
    3eb4:	c545                	beqz	a0,3f5c <rmdot+0xfa>
  if(chdir("/") != 0){
    3eb6:	00003517          	auipc	a0,0x3
    3eba:	54a50513          	addi	a0,a0,1354 # 7400 <malloc+0x13fc>
    3ebe:	00002097          	auipc	ra,0x2
    3ec2:	d78080e7          	jalr	-648(ra) # 5c36 <chdir>
    3ec6:	e94d                	bnez	a0,3f78 <rmdot+0x116>
  if(unlink("dots/.") == 0){
    3ec8:	00004517          	auipc	a0,0x4
    3ecc:	ba050513          	addi	a0,a0,-1120 # 7a68 <malloc+0x1a64>
    3ed0:	00002097          	auipc	ra,0x2
    3ed4:	d46080e7          	jalr	-698(ra) # 5c16 <unlink>
    3ed8:	cd55                	beqz	a0,3f94 <rmdot+0x132>
  if(unlink("dots/..") == 0){
    3eda:	00004517          	auipc	a0,0x4
    3ede:	bb650513          	addi	a0,a0,-1098 # 7a90 <malloc+0x1a8c>
    3ee2:	00002097          	auipc	ra,0x2
    3ee6:	d34080e7          	jalr	-716(ra) # 5c16 <unlink>
    3eea:	c179                	beqz	a0,3fb0 <rmdot+0x14e>
  if(unlink("dots") != 0){
    3eec:	00004517          	auipc	a0,0x4
    3ef0:	b1450513          	addi	a0,a0,-1260 # 7a00 <malloc+0x19fc>
    3ef4:	00002097          	auipc	ra,0x2
    3ef8:	d22080e7          	jalr	-734(ra) # 5c16 <unlink>
    3efc:	e961                	bnez	a0,3fcc <rmdot+0x16a>
}
    3efe:	60e2                	ld	ra,24(sp)
    3f00:	6442                	ld	s0,16(sp)
    3f02:	64a2                	ld	s1,8(sp)
    3f04:	6105                	addi	sp,sp,32
    3f06:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    3f08:	85a6                	mv	a1,s1
    3f0a:	00004517          	auipc	a0,0x4
    3f0e:	afe50513          	addi	a0,a0,-1282 # 7a08 <malloc+0x1a04>
    3f12:	00002097          	auipc	ra,0x2
    3f16:	034080e7          	jalr	52(ra) # 5f46 <printf>
    exit(1);
    3f1a:	4505                	li	a0,1
    3f1c:	00002097          	auipc	ra,0x2
    3f20:	caa080e7          	jalr	-854(ra) # 5bc6 <exit>
    printf("%s: chdir dots failed\n", s);
    3f24:	85a6                	mv	a1,s1
    3f26:	00004517          	auipc	a0,0x4
    3f2a:	afa50513          	addi	a0,a0,-1286 # 7a20 <malloc+0x1a1c>
    3f2e:	00002097          	auipc	ra,0x2
    3f32:	018080e7          	jalr	24(ra) # 5f46 <printf>
    exit(1);
    3f36:	4505                	li	a0,1
    3f38:	00002097          	auipc	ra,0x2
    3f3c:	c8e080e7          	jalr	-882(ra) # 5bc6 <exit>
    printf("%s: rm . worked!\n", s);
    3f40:	85a6                	mv	a1,s1
    3f42:	00004517          	auipc	a0,0x4
    3f46:	af650513          	addi	a0,a0,-1290 # 7a38 <malloc+0x1a34>
    3f4a:	00002097          	auipc	ra,0x2
    3f4e:	ffc080e7          	jalr	-4(ra) # 5f46 <printf>
    exit(1);
    3f52:	4505                	li	a0,1
    3f54:	00002097          	auipc	ra,0x2
    3f58:	c72080e7          	jalr	-910(ra) # 5bc6 <exit>
    printf("%s: rm .. worked!\n", s);
    3f5c:	85a6                	mv	a1,s1
    3f5e:	00004517          	auipc	a0,0x4
    3f62:	af250513          	addi	a0,a0,-1294 # 7a50 <malloc+0x1a4c>
    3f66:	00002097          	auipc	ra,0x2
    3f6a:	fe0080e7          	jalr	-32(ra) # 5f46 <printf>
    exit(1);
    3f6e:	4505                	li	a0,1
    3f70:	00002097          	auipc	ra,0x2
    3f74:	c56080e7          	jalr	-938(ra) # 5bc6 <exit>
    printf("%s: chdir / failed\n", s);
    3f78:	85a6                	mv	a1,s1
    3f7a:	00003517          	auipc	a0,0x3
    3f7e:	48e50513          	addi	a0,a0,1166 # 7408 <malloc+0x1404>
    3f82:	00002097          	auipc	ra,0x2
    3f86:	fc4080e7          	jalr	-60(ra) # 5f46 <printf>
    exit(1);
    3f8a:	4505                	li	a0,1
    3f8c:	00002097          	auipc	ra,0x2
    3f90:	c3a080e7          	jalr	-966(ra) # 5bc6 <exit>
    printf("%s: unlink dots/. worked!\n", s);
    3f94:	85a6                	mv	a1,s1
    3f96:	00004517          	auipc	a0,0x4
    3f9a:	ada50513          	addi	a0,a0,-1318 # 7a70 <malloc+0x1a6c>
    3f9e:	00002097          	auipc	ra,0x2
    3fa2:	fa8080e7          	jalr	-88(ra) # 5f46 <printf>
    exit(1);
    3fa6:	4505                	li	a0,1
    3fa8:	00002097          	auipc	ra,0x2
    3fac:	c1e080e7          	jalr	-994(ra) # 5bc6 <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    3fb0:	85a6                	mv	a1,s1
    3fb2:	00004517          	auipc	a0,0x4
    3fb6:	ae650513          	addi	a0,a0,-1306 # 7a98 <malloc+0x1a94>
    3fba:	00002097          	auipc	ra,0x2
    3fbe:	f8c080e7          	jalr	-116(ra) # 5f46 <printf>
    exit(1);
    3fc2:	4505                	li	a0,1
    3fc4:	00002097          	auipc	ra,0x2
    3fc8:	c02080e7          	jalr	-1022(ra) # 5bc6 <exit>
    printf("%s: unlink dots failed!\n", s);
    3fcc:	85a6                	mv	a1,s1
    3fce:	00004517          	auipc	a0,0x4
    3fd2:	aea50513          	addi	a0,a0,-1302 # 7ab8 <malloc+0x1ab4>
    3fd6:	00002097          	auipc	ra,0x2
    3fda:	f70080e7          	jalr	-144(ra) # 5f46 <printf>
    exit(1);
    3fde:	4505                	li	a0,1
    3fe0:	00002097          	auipc	ra,0x2
    3fe4:	be6080e7          	jalr	-1050(ra) # 5bc6 <exit>

0000000000003fe8 <dirfile>:
{
    3fe8:	1101                	addi	sp,sp,-32
    3fea:	ec06                	sd	ra,24(sp)
    3fec:	e822                	sd	s0,16(sp)
    3fee:	e426                	sd	s1,8(sp)
    3ff0:	e04a                	sd	s2,0(sp)
    3ff2:	1000                	addi	s0,sp,32
    3ff4:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    3ff6:	20000593          	li	a1,512
    3ffa:	00004517          	auipc	a0,0x4
    3ffe:	ade50513          	addi	a0,a0,-1314 # 7ad8 <malloc+0x1ad4>
    4002:	00002097          	auipc	ra,0x2
    4006:	c04080e7          	jalr	-1020(ra) # 5c06 <open>
  if(fd < 0){
    400a:	0e054d63          	bltz	a0,4104 <dirfile+0x11c>
  close(fd);
    400e:	00002097          	auipc	ra,0x2
    4012:	be0080e7          	jalr	-1056(ra) # 5bee <close>
  if(chdir("dirfile") == 0){
    4016:	00004517          	auipc	a0,0x4
    401a:	ac250513          	addi	a0,a0,-1342 # 7ad8 <malloc+0x1ad4>
    401e:	00002097          	auipc	ra,0x2
    4022:	c18080e7          	jalr	-1000(ra) # 5c36 <chdir>
    4026:	cd6d                	beqz	a0,4120 <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    4028:	4581                	li	a1,0
    402a:	00004517          	auipc	a0,0x4
    402e:	af650513          	addi	a0,a0,-1290 # 7b20 <malloc+0x1b1c>
    4032:	00002097          	auipc	ra,0x2
    4036:	bd4080e7          	jalr	-1068(ra) # 5c06 <open>
  if(fd >= 0){
    403a:	10055163          	bgez	a0,413c <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    403e:	20000593          	li	a1,512
    4042:	00004517          	auipc	a0,0x4
    4046:	ade50513          	addi	a0,a0,-1314 # 7b20 <malloc+0x1b1c>
    404a:	00002097          	auipc	ra,0x2
    404e:	bbc080e7          	jalr	-1092(ra) # 5c06 <open>
  if(fd >= 0){
    4052:	10055363          	bgez	a0,4158 <dirfile+0x170>
  if(mkdir("dirfile/xx") == 0){
    4056:	00004517          	auipc	a0,0x4
    405a:	aca50513          	addi	a0,a0,-1334 # 7b20 <malloc+0x1b1c>
    405e:	00002097          	auipc	ra,0x2
    4062:	bd0080e7          	jalr	-1072(ra) # 5c2e <mkdir>
    4066:	10050763          	beqz	a0,4174 <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
    406a:	00004517          	auipc	a0,0x4
    406e:	ab650513          	addi	a0,a0,-1354 # 7b20 <malloc+0x1b1c>
    4072:	00002097          	auipc	ra,0x2
    4076:	ba4080e7          	jalr	-1116(ra) # 5c16 <unlink>
    407a:	10050b63          	beqz	a0,4190 <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
    407e:	00004597          	auipc	a1,0x4
    4082:	aa258593          	addi	a1,a1,-1374 # 7b20 <malloc+0x1b1c>
    4086:	00002517          	auipc	a0,0x2
    408a:	29a50513          	addi	a0,a0,666 # 6320 <malloc+0x31c>
    408e:	00002097          	auipc	ra,0x2
    4092:	b98080e7          	jalr	-1128(ra) # 5c26 <link>
    4096:	10050b63          	beqz	a0,41ac <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
    409a:	00004517          	auipc	a0,0x4
    409e:	a3e50513          	addi	a0,a0,-1474 # 7ad8 <malloc+0x1ad4>
    40a2:	00002097          	auipc	ra,0x2
    40a6:	b74080e7          	jalr	-1164(ra) # 5c16 <unlink>
    40aa:	10051f63          	bnez	a0,41c8 <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    40ae:	4589                	li	a1,2
    40b0:	00002517          	auipc	a0,0x2
    40b4:	78050513          	addi	a0,a0,1920 # 6830 <malloc+0x82c>
    40b8:	00002097          	auipc	ra,0x2
    40bc:	b4e080e7          	jalr	-1202(ra) # 5c06 <open>
  if(fd >= 0){
    40c0:	12055263          	bgez	a0,41e4 <dirfile+0x1fc>
  fd = open(".", 0);
    40c4:	4581                	li	a1,0
    40c6:	00002517          	auipc	a0,0x2
    40ca:	76a50513          	addi	a0,a0,1898 # 6830 <malloc+0x82c>
    40ce:	00002097          	auipc	ra,0x2
    40d2:	b38080e7          	jalr	-1224(ra) # 5c06 <open>
    40d6:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    40d8:	4605                	li	a2,1
    40da:	00002597          	auipc	a1,0x2
    40de:	0de58593          	addi	a1,a1,222 # 61b8 <malloc+0x1b4>
    40e2:	00002097          	auipc	ra,0x2
    40e6:	b04080e7          	jalr	-1276(ra) # 5be6 <write>
    40ea:	10a04b63          	bgtz	a0,4200 <dirfile+0x218>
  close(fd);
    40ee:	8526                	mv	a0,s1
    40f0:	00002097          	auipc	ra,0x2
    40f4:	afe080e7          	jalr	-1282(ra) # 5bee <close>
}
    40f8:	60e2                	ld	ra,24(sp)
    40fa:	6442                	ld	s0,16(sp)
    40fc:	64a2                	ld	s1,8(sp)
    40fe:	6902                	ld	s2,0(sp)
    4100:	6105                	addi	sp,sp,32
    4102:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    4104:	85ca                	mv	a1,s2
    4106:	00004517          	auipc	a0,0x4
    410a:	9da50513          	addi	a0,a0,-1574 # 7ae0 <malloc+0x1adc>
    410e:	00002097          	auipc	ra,0x2
    4112:	e38080e7          	jalr	-456(ra) # 5f46 <printf>
    exit(1);
    4116:	4505                	li	a0,1
    4118:	00002097          	auipc	ra,0x2
    411c:	aae080e7          	jalr	-1362(ra) # 5bc6 <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    4120:	85ca                	mv	a1,s2
    4122:	00004517          	auipc	a0,0x4
    4126:	9de50513          	addi	a0,a0,-1570 # 7b00 <malloc+0x1afc>
    412a:	00002097          	auipc	ra,0x2
    412e:	e1c080e7          	jalr	-484(ra) # 5f46 <printf>
    exit(1);
    4132:	4505                	li	a0,1
    4134:	00002097          	auipc	ra,0x2
    4138:	a92080e7          	jalr	-1390(ra) # 5bc6 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    413c:	85ca                	mv	a1,s2
    413e:	00004517          	auipc	a0,0x4
    4142:	9f250513          	addi	a0,a0,-1550 # 7b30 <malloc+0x1b2c>
    4146:	00002097          	auipc	ra,0x2
    414a:	e00080e7          	jalr	-512(ra) # 5f46 <printf>
    exit(1);
    414e:	4505                	li	a0,1
    4150:	00002097          	auipc	ra,0x2
    4154:	a76080e7          	jalr	-1418(ra) # 5bc6 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    4158:	85ca                	mv	a1,s2
    415a:	00004517          	auipc	a0,0x4
    415e:	9d650513          	addi	a0,a0,-1578 # 7b30 <malloc+0x1b2c>
    4162:	00002097          	auipc	ra,0x2
    4166:	de4080e7          	jalr	-540(ra) # 5f46 <printf>
    exit(1);
    416a:	4505                	li	a0,1
    416c:	00002097          	auipc	ra,0x2
    4170:	a5a080e7          	jalr	-1446(ra) # 5bc6 <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    4174:	85ca                	mv	a1,s2
    4176:	00004517          	auipc	a0,0x4
    417a:	9e250513          	addi	a0,a0,-1566 # 7b58 <malloc+0x1b54>
    417e:	00002097          	auipc	ra,0x2
    4182:	dc8080e7          	jalr	-568(ra) # 5f46 <printf>
    exit(1);
    4186:	4505                	li	a0,1
    4188:	00002097          	auipc	ra,0x2
    418c:	a3e080e7          	jalr	-1474(ra) # 5bc6 <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    4190:	85ca                	mv	a1,s2
    4192:	00004517          	auipc	a0,0x4
    4196:	9ee50513          	addi	a0,a0,-1554 # 7b80 <malloc+0x1b7c>
    419a:	00002097          	auipc	ra,0x2
    419e:	dac080e7          	jalr	-596(ra) # 5f46 <printf>
    exit(1);
    41a2:	4505                	li	a0,1
    41a4:	00002097          	auipc	ra,0x2
    41a8:	a22080e7          	jalr	-1502(ra) # 5bc6 <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    41ac:	85ca                	mv	a1,s2
    41ae:	00004517          	auipc	a0,0x4
    41b2:	9fa50513          	addi	a0,a0,-1542 # 7ba8 <malloc+0x1ba4>
    41b6:	00002097          	auipc	ra,0x2
    41ba:	d90080e7          	jalr	-624(ra) # 5f46 <printf>
    exit(1);
    41be:	4505                	li	a0,1
    41c0:	00002097          	auipc	ra,0x2
    41c4:	a06080e7          	jalr	-1530(ra) # 5bc6 <exit>
    printf("%s: unlink dirfile failed!\n", s);
    41c8:	85ca                	mv	a1,s2
    41ca:	00004517          	auipc	a0,0x4
    41ce:	a0650513          	addi	a0,a0,-1530 # 7bd0 <malloc+0x1bcc>
    41d2:	00002097          	auipc	ra,0x2
    41d6:	d74080e7          	jalr	-652(ra) # 5f46 <printf>
    exit(1);
    41da:	4505                	li	a0,1
    41dc:	00002097          	auipc	ra,0x2
    41e0:	9ea080e7          	jalr	-1558(ra) # 5bc6 <exit>
    printf("%s: open . for writing succeeded!\n", s);
    41e4:	85ca                	mv	a1,s2
    41e6:	00004517          	auipc	a0,0x4
    41ea:	a0a50513          	addi	a0,a0,-1526 # 7bf0 <malloc+0x1bec>
    41ee:	00002097          	auipc	ra,0x2
    41f2:	d58080e7          	jalr	-680(ra) # 5f46 <printf>
    exit(1);
    41f6:	4505                	li	a0,1
    41f8:	00002097          	auipc	ra,0x2
    41fc:	9ce080e7          	jalr	-1586(ra) # 5bc6 <exit>
    printf("%s: write . succeeded!\n", s);
    4200:	85ca                	mv	a1,s2
    4202:	00004517          	auipc	a0,0x4
    4206:	a1650513          	addi	a0,a0,-1514 # 7c18 <malloc+0x1c14>
    420a:	00002097          	auipc	ra,0x2
    420e:	d3c080e7          	jalr	-708(ra) # 5f46 <printf>
    exit(1);
    4212:	4505                	li	a0,1
    4214:	00002097          	auipc	ra,0x2
    4218:	9b2080e7          	jalr	-1614(ra) # 5bc6 <exit>

000000000000421c <iref>:
{
    421c:	7139                	addi	sp,sp,-64
    421e:	fc06                	sd	ra,56(sp)
    4220:	f822                	sd	s0,48(sp)
    4222:	f426                	sd	s1,40(sp)
    4224:	f04a                	sd	s2,32(sp)
    4226:	ec4e                	sd	s3,24(sp)
    4228:	e852                	sd	s4,16(sp)
    422a:	e456                	sd	s5,8(sp)
    422c:	e05a                	sd	s6,0(sp)
    422e:	0080                	addi	s0,sp,64
    4230:	8b2a                	mv	s6,a0
    4232:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    4236:	00004a17          	auipc	s4,0x4
    423a:	9faa0a13          	addi	s4,s4,-1542 # 7c30 <malloc+0x1c2c>
    mkdir("");
    423e:	00003497          	auipc	s1,0x3
    4242:	4fa48493          	addi	s1,s1,1274 # 7738 <malloc+0x1734>
    link("README", "");
    4246:	00002a97          	auipc	s5,0x2
    424a:	0daa8a93          	addi	s5,s5,218 # 6320 <malloc+0x31c>
    fd = open("xx", O_CREATE);
    424e:	00004997          	auipc	s3,0x4
    4252:	8da98993          	addi	s3,s3,-1830 # 7b28 <malloc+0x1b24>
    4256:	a891                	j	42aa <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    4258:	85da                	mv	a1,s6
    425a:	00004517          	auipc	a0,0x4
    425e:	9de50513          	addi	a0,a0,-1570 # 7c38 <malloc+0x1c34>
    4262:	00002097          	auipc	ra,0x2
    4266:	ce4080e7          	jalr	-796(ra) # 5f46 <printf>
      exit(1);
    426a:	4505                	li	a0,1
    426c:	00002097          	auipc	ra,0x2
    4270:	95a080e7          	jalr	-1702(ra) # 5bc6 <exit>
      printf("%s: chdir irefd failed\n", s);
    4274:	85da                	mv	a1,s6
    4276:	00004517          	auipc	a0,0x4
    427a:	9da50513          	addi	a0,a0,-1574 # 7c50 <malloc+0x1c4c>
    427e:	00002097          	auipc	ra,0x2
    4282:	cc8080e7          	jalr	-824(ra) # 5f46 <printf>
      exit(1);
    4286:	4505                	li	a0,1
    4288:	00002097          	auipc	ra,0x2
    428c:	93e080e7          	jalr	-1730(ra) # 5bc6 <exit>
      close(fd);
    4290:	00002097          	auipc	ra,0x2
    4294:	95e080e7          	jalr	-1698(ra) # 5bee <close>
    4298:	a889                	j	42ea <iref+0xce>
    unlink("xx");
    429a:	854e                	mv	a0,s3
    429c:	00002097          	auipc	ra,0x2
    42a0:	97a080e7          	jalr	-1670(ra) # 5c16 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    42a4:	397d                	addiw	s2,s2,-1
    42a6:	06090063          	beqz	s2,4306 <iref+0xea>
    if(mkdir("irefd") != 0){
    42aa:	8552                	mv	a0,s4
    42ac:	00002097          	auipc	ra,0x2
    42b0:	982080e7          	jalr	-1662(ra) # 5c2e <mkdir>
    42b4:	f155                	bnez	a0,4258 <iref+0x3c>
    if(chdir("irefd") != 0){
    42b6:	8552                	mv	a0,s4
    42b8:	00002097          	auipc	ra,0x2
    42bc:	97e080e7          	jalr	-1666(ra) # 5c36 <chdir>
    42c0:	f955                	bnez	a0,4274 <iref+0x58>
    mkdir("");
    42c2:	8526                	mv	a0,s1
    42c4:	00002097          	auipc	ra,0x2
    42c8:	96a080e7          	jalr	-1686(ra) # 5c2e <mkdir>
    link("README", "");
    42cc:	85a6                	mv	a1,s1
    42ce:	8556                	mv	a0,s5
    42d0:	00002097          	auipc	ra,0x2
    42d4:	956080e7          	jalr	-1706(ra) # 5c26 <link>
    fd = open("", O_CREATE);
    42d8:	20000593          	li	a1,512
    42dc:	8526                	mv	a0,s1
    42de:	00002097          	auipc	ra,0x2
    42e2:	928080e7          	jalr	-1752(ra) # 5c06 <open>
    if(fd >= 0)
    42e6:	fa0555e3          	bgez	a0,4290 <iref+0x74>
    fd = open("xx", O_CREATE);
    42ea:	20000593          	li	a1,512
    42ee:	854e                	mv	a0,s3
    42f0:	00002097          	auipc	ra,0x2
    42f4:	916080e7          	jalr	-1770(ra) # 5c06 <open>
    if(fd >= 0)
    42f8:	fa0541e3          	bltz	a0,429a <iref+0x7e>
      close(fd);
    42fc:	00002097          	auipc	ra,0x2
    4300:	8f2080e7          	jalr	-1806(ra) # 5bee <close>
    4304:	bf59                	j	429a <iref+0x7e>
    4306:	03300493          	li	s1,51
    chdir("..");
    430a:	00003997          	auipc	s3,0x3
    430e:	14e98993          	addi	s3,s3,334 # 7458 <malloc+0x1454>
    unlink("irefd");
    4312:	00004917          	auipc	s2,0x4
    4316:	91e90913          	addi	s2,s2,-1762 # 7c30 <malloc+0x1c2c>
    chdir("..");
    431a:	854e                	mv	a0,s3
    431c:	00002097          	auipc	ra,0x2
    4320:	91a080e7          	jalr	-1766(ra) # 5c36 <chdir>
    unlink("irefd");
    4324:	854a                	mv	a0,s2
    4326:	00002097          	auipc	ra,0x2
    432a:	8f0080e7          	jalr	-1808(ra) # 5c16 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    432e:	34fd                	addiw	s1,s1,-1
    4330:	f4ed                	bnez	s1,431a <iref+0xfe>
  chdir("/");
    4332:	00003517          	auipc	a0,0x3
    4336:	0ce50513          	addi	a0,a0,206 # 7400 <malloc+0x13fc>
    433a:	00002097          	auipc	ra,0x2
    433e:	8fc080e7          	jalr	-1796(ra) # 5c36 <chdir>
}
    4342:	70e2                	ld	ra,56(sp)
    4344:	7442                	ld	s0,48(sp)
    4346:	74a2                	ld	s1,40(sp)
    4348:	7902                	ld	s2,32(sp)
    434a:	69e2                	ld	s3,24(sp)
    434c:	6a42                	ld	s4,16(sp)
    434e:	6aa2                	ld	s5,8(sp)
    4350:	6b02                	ld	s6,0(sp)
    4352:	6121                	addi	sp,sp,64
    4354:	8082                	ret

0000000000004356 <openiputtest>:
{
    4356:	7179                	addi	sp,sp,-48
    4358:	f406                	sd	ra,40(sp)
    435a:	f022                	sd	s0,32(sp)
    435c:	ec26                	sd	s1,24(sp)
    435e:	1800                	addi	s0,sp,48
    4360:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    4362:	00004517          	auipc	a0,0x4
    4366:	90650513          	addi	a0,a0,-1786 # 7c68 <malloc+0x1c64>
    436a:	00002097          	auipc	ra,0x2
    436e:	8c4080e7          	jalr	-1852(ra) # 5c2e <mkdir>
    4372:	04054263          	bltz	a0,43b6 <openiputtest+0x60>
  pid = fork();
    4376:	00002097          	auipc	ra,0x2
    437a:	848080e7          	jalr	-1976(ra) # 5bbe <fork>
  if(pid < 0){
    437e:	04054a63          	bltz	a0,43d2 <openiputtest+0x7c>
  if(pid == 0){
    4382:	e93d                	bnez	a0,43f8 <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
    4384:	4589                	li	a1,2
    4386:	00004517          	auipc	a0,0x4
    438a:	8e250513          	addi	a0,a0,-1822 # 7c68 <malloc+0x1c64>
    438e:	00002097          	auipc	ra,0x2
    4392:	878080e7          	jalr	-1928(ra) # 5c06 <open>
    if(fd >= 0){
    4396:	04054c63          	bltz	a0,43ee <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
    439a:	85a6                	mv	a1,s1
    439c:	00004517          	auipc	a0,0x4
    43a0:	8ec50513          	addi	a0,a0,-1812 # 7c88 <malloc+0x1c84>
    43a4:	00002097          	auipc	ra,0x2
    43a8:	ba2080e7          	jalr	-1118(ra) # 5f46 <printf>
      exit(1);
    43ac:	4505                	li	a0,1
    43ae:	00002097          	auipc	ra,0x2
    43b2:	818080e7          	jalr	-2024(ra) # 5bc6 <exit>
    printf("%s: mkdir oidir failed\n", s);
    43b6:	85a6                	mv	a1,s1
    43b8:	00004517          	auipc	a0,0x4
    43bc:	8b850513          	addi	a0,a0,-1864 # 7c70 <malloc+0x1c6c>
    43c0:	00002097          	auipc	ra,0x2
    43c4:	b86080e7          	jalr	-1146(ra) # 5f46 <printf>
    exit(1);
    43c8:	4505                	li	a0,1
    43ca:	00001097          	auipc	ra,0x1
    43ce:	7fc080e7          	jalr	2044(ra) # 5bc6 <exit>
    printf("%s: fork failed\n", s);
    43d2:	85a6                	mv	a1,s1
    43d4:	00002517          	auipc	a0,0x2
    43d8:	5fc50513          	addi	a0,a0,1532 # 69d0 <malloc+0x9cc>
    43dc:	00002097          	auipc	ra,0x2
    43e0:	b6a080e7          	jalr	-1174(ra) # 5f46 <printf>
    exit(1);
    43e4:	4505                	li	a0,1
    43e6:	00001097          	auipc	ra,0x1
    43ea:	7e0080e7          	jalr	2016(ra) # 5bc6 <exit>
    exit(0);
    43ee:	4501                	li	a0,0
    43f0:	00001097          	auipc	ra,0x1
    43f4:	7d6080e7          	jalr	2006(ra) # 5bc6 <exit>
  sleep(1);
    43f8:	4505                	li	a0,1
    43fa:	00002097          	auipc	ra,0x2
    43fe:	85c080e7          	jalr	-1956(ra) # 5c56 <sleep>
  if(unlink("oidir") != 0){
    4402:	00004517          	auipc	a0,0x4
    4406:	86650513          	addi	a0,a0,-1946 # 7c68 <malloc+0x1c64>
    440a:	00002097          	auipc	ra,0x2
    440e:	80c080e7          	jalr	-2036(ra) # 5c16 <unlink>
    4412:	cd19                	beqz	a0,4430 <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
    4414:	85a6                	mv	a1,s1
    4416:	00002517          	auipc	a0,0x2
    441a:	7aa50513          	addi	a0,a0,1962 # 6bc0 <malloc+0xbbc>
    441e:	00002097          	auipc	ra,0x2
    4422:	b28080e7          	jalr	-1240(ra) # 5f46 <printf>
    exit(1);
    4426:	4505                	li	a0,1
    4428:	00001097          	auipc	ra,0x1
    442c:	79e080e7          	jalr	1950(ra) # 5bc6 <exit>
  wait(&xstatus);
    4430:	fdc40513          	addi	a0,s0,-36
    4434:	00001097          	auipc	ra,0x1
    4438:	79a080e7          	jalr	1946(ra) # 5bce <wait>
  exit(xstatus);
    443c:	fdc42503          	lw	a0,-36(s0)
    4440:	00001097          	auipc	ra,0x1
    4444:	786080e7          	jalr	1926(ra) # 5bc6 <exit>

0000000000004448 <forkforkfork>:
{
    4448:	1101                	addi	sp,sp,-32
    444a:	ec06                	sd	ra,24(sp)
    444c:	e822                	sd	s0,16(sp)
    444e:	e426                	sd	s1,8(sp)
    4450:	1000                	addi	s0,sp,32
    4452:	84aa                	mv	s1,a0
  unlink("stopforking");
    4454:	00004517          	auipc	a0,0x4
    4458:	85c50513          	addi	a0,a0,-1956 # 7cb0 <malloc+0x1cac>
    445c:	00001097          	auipc	ra,0x1
    4460:	7ba080e7          	jalr	1978(ra) # 5c16 <unlink>
  int pid = fork();
    4464:	00001097          	auipc	ra,0x1
    4468:	75a080e7          	jalr	1882(ra) # 5bbe <fork>
  if(pid < 0){
    446c:	04054563          	bltz	a0,44b6 <forkforkfork+0x6e>
  if(pid == 0){
    4470:	c12d                	beqz	a0,44d2 <forkforkfork+0x8a>
  sleep(20); // two seconds
    4472:	4551                	li	a0,20
    4474:	00001097          	auipc	ra,0x1
    4478:	7e2080e7          	jalr	2018(ra) # 5c56 <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
    447c:	20200593          	li	a1,514
    4480:	00004517          	auipc	a0,0x4
    4484:	83050513          	addi	a0,a0,-2000 # 7cb0 <malloc+0x1cac>
    4488:	00001097          	auipc	ra,0x1
    448c:	77e080e7          	jalr	1918(ra) # 5c06 <open>
    4490:	00001097          	auipc	ra,0x1
    4494:	75e080e7          	jalr	1886(ra) # 5bee <close>
  wait(0);
    4498:	4501                	li	a0,0
    449a:	00001097          	auipc	ra,0x1
    449e:	734080e7          	jalr	1844(ra) # 5bce <wait>
  sleep(10); // one second
    44a2:	4529                	li	a0,10
    44a4:	00001097          	auipc	ra,0x1
    44a8:	7b2080e7          	jalr	1970(ra) # 5c56 <sleep>
}
    44ac:	60e2                	ld	ra,24(sp)
    44ae:	6442                	ld	s0,16(sp)
    44b0:	64a2                	ld	s1,8(sp)
    44b2:	6105                	addi	sp,sp,32
    44b4:	8082                	ret
    printf("%s: fork failed", s);
    44b6:	85a6                	mv	a1,s1
    44b8:	00002517          	auipc	a0,0x2
    44bc:	6d850513          	addi	a0,a0,1752 # 6b90 <malloc+0xb8c>
    44c0:	00002097          	auipc	ra,0x2
    44c4:	a86080e7          	jalr	-1402(ra) # 5f46 <printf>
    exit(1);
    44c8:	4505                	li	a0,1
    44ca:	00001097          	auipc	ra,0x1
    44ce:	6fc080e7          	jalr	1788(ra) # 5bc6 <exit>
      int fd = open("stopforking", 0);
    44d2:	00003497          	auipc	s1,0x3
    44d6:	7de48493          	addi	s1,s1,2014 # 7cb0 <malloc+0x1cac>
    44da:	4581                	li	a1,0
    44dc:	8526                	mv	a0,s1
    44de:	00001097          	auipc	ra,0x1
    44e2:	728080e7          	jalr	1832(ra) # 5c06 <open>
      if(fd >= 0){
    44e6:	02055463          	bgez	a0,450e <forkforkfork+0xc6>
      if(fork() < 0){
    44ea:	00001097          	auipc	ra,0x1
    44ee:	6d4080e7          	jalr	1748(ra) # 5bbe <fork>
    44f2:	fe0554e3          	bgez	a0,44da <forkforkfork+0x92>
        close(open("stopforking", O_CREATE|O_RDWR));
    44f6:	20200593          	li	a1,514
    44fa:	8526                	mv	a0,s1
    44fc:	00001097          	auipc	ra,0x1
    4500:	70a080e7          	jalr	1802(ra) # 5c06 <open>
    4504:	00001097          	auipc	ra,0x1
    4508:	6ea080e7          	jalr	1770(ra) # 5bee <close>
    450c:	b7f9                	j	44da <forkforkfork+0x92>
        exit(0);
    450e:	4501                	li	a0,0
    4510:	00001097          	auipc	ra,0x1
    4514:	6b6080e7          	jalr	1718(ra) # 5bc6 <exit>

0000000000004518 <killstatus>:
{
    4518:	7139                	addi	sp,sp,-64
    451a:	fc06                	sd	ra,56(sp)
    451c:	f822                	sd	s0,48(sp)
    451e:	f426                	sd	s1,40(sp)
    4520:	f04a                	sd	s2,32(sp)
    4522:	ec4e                	sd	s3,24(sp)
    4524:	e852                	sd	s4,16(sp)
    4526:	0080                	addi	s0,sp,64
    4528:	8a2a                	mv	s4,a0
    452a:	06400913          	li	s2,100
    if(xst != -1) {
    452e:	59fd                	li	s3,-1
    int pid1 = fork();
    4530:	00001097          	auipc	ra,0x1
    4534:	68e080e7          	jalr	1678(ra) # 5bbe <fork>
    4538:	84aa                	mv	s1,a0
    if(pid1 < 0){
    453a:	02054f63          	bltz	a0,4578 <killstatus+0x60>
    if(pid1 == 0){
    453e:	c939                	beqz	a0,4594 <killstatus+0x7c>
    sleep(1);
    4540:	4505                	li	a0,1
    4542:	00001097          	auipc	ra,0x1
    4546:	714080e7          	jalr	1812(ra) # 5c56 <sleep>
    kill(pid1);
    454a:	8526                	mv	a0,s1
    454c:	00001097          	auipc	ra,0x1
    4550:	6aa080e7          	jalr	1706(ra) # 5bf6 <kill>
    wait(&xst);
    4554:	fcc40513          	addi	a0,s0,-52
    4558:	00001097          	auipc	ra,0x1
    455c:	676080e7          	jalr	1654(ra) # 5bce <wait>
    if(xst != -1) {
    4560:	fcc42783          	lw	a5,-52(s0)
    4564:	03379d63          	bne	a5,s3,459e <killstatus+0x86>
  for(int i = 0; i < 100; i++){
    4568:	397d                	addiw	s2,s2,-1
    456a:	fc0913e3          	bnez	s2,4530 <killstatus+0x18>
  exit(0);
    456e:	4501                	li	a0,0
    4570:	00001097          	auipc	ra,0x1
    4574:	656080e7          	jalr	1622(ra) # 5bc6 <exit>
      printf("%s: fork failed\n", s);
    4578:	85d2                	mv	a1,s4
    457a:	00002517          	auipc	a0,0x2
    457e:	45650513          	addi	a0,a0,1110 # 69d0 <malloc+0x9cc>
    4582:	00002097          	auipc	ra,0x2
    4586:	9c4080e7          	jalr	-1596(ra) # 5f46 <printf>
      exit(1);
    458a:	4505                	li	a0,1
    458c:	00001097          	auipc	ra,0x1
    4590:	63a080e7          	jalr	1594(ra) # 5bc6 <exit>
        getpid();
    4594:	00001097          	auipc	ra,0x1
    4598:	6b2080e7          	jalr	1714(ra) # 5c46 <getpid>
      while(1) {
    459c:	bfe5                	j	4594 <killstatus+0x7c>
       printf("%s: status should be -1\n", s);
    459e:	85d2                	mv	a1,s4
    45a0:	00003517          	auipc	a0,0x3
    45a4:	72050513          	addi	a0,a0,1824 # 7cc0 <malloc+0x1cbc>
    45a8:	00002097          	auipc	ra,0x2
    45ac:	99e080e7          	jalr	-1634(ra) # 5f46 <printf>
       exit(1);
    45b0:	4505                	li	a0,1
    45b2:	00001097          	auipc	ra,0x1
    45b6:	614080e7          	jalr	1556(ra) # 5bc6 <exit>

00000000000045ba <preempt>:
{
    45ba:	7139                	addi	sp,sp,-64
    45bc:	fc06                	sd	ra,56(sp)
    45be:	f822                	sd	s0,48(sp)
    45c0:	f426                	sd	s1,40(sp)
    45c2:	f04a                	sd	s2,32(sp)
    45c4:	ec4e                	sd	s3,24(sp)
    45c6:	e852                	sd	s4,16(sp)
    45c8:	0080                	addi	s0,sp,64
    45ca:	892a                	mv	s2,a0
  pid1 = fork();
    45cc:	00001097          	auipc	ra,0x1
    45d0:	5f2080e7          	jalr	1522(ra) # 5bbe <fork>
  if(pid1 < 0) {
    45d4:	00054563          	bltz	a0,45de <preempt+0x24>
    45d8:	84aa                	mv	s1,a0
  if(pid1 == 0)
    45da:	e105                	bnez	a0,45fa <preempt+0x40>
    for(;;)
    45dc:	a001                	j	45dc <preempt+0x22>
    printf("%s: fork failed", s);
    45de:	85ca                	mv	a1,s2
    45e0:	00002517          	auipc	a0,0x2
    45e4:	5b050513          	addi	a0,a0,1456 # 6b90 <malloc+0xb8c>
    45e8:	00002097          	auipc	ra,0x2
    45ec:	95e080e7          	jalr	-1698(ra) # 5f46 <printf>
    exit(1);
    45f0:	4505                	li	a0,1
    45f2:	00001097          	auipc	ra,0x1
    45f6:	5d4080e7          	jalr	1492(ra) # 5bc6 <exit>
  pid2 = fork();
    45fa:	00001097          	auipc	ra,0x1
    45fe:	5c4080e7          	jalr	1476(ra) # 5bbe <fork>
    4602:	89aa                	mv	s3,a0
  if(pid2 < 0) {
    4604:	00054463          	bltz	a0,460c <preempt+0x52>
  if(pid2 == 0)
    4608:	e105                	bnez	a0,4628 <preempt+0x6e>
    for(;;)
    460a:	a001                	j	460a <preempt+0x50>
    printf("%s: fork failed\n", s);
    460c:	85ca                	mv	a1,s2
    460e:	00002517          	auipc	a0,0x2
    4612:	3c250513          	addi	a0,a0,962 # 69d0 <malloc+0x9cc>
    4616:	00002097          	auipc	ra,0x2
    461a:	930080e7          	jalr	-1744(ra) # 5f46 <printf>
    exit(1);
    461e:	4505                	li	a0,1
    4620:	00001097          	auipc	ra,0x1
    4624:	5a6080e7          	jalr	1446(ra) # 5bc6 <exit>
  pipe(pfds);
    4628:	fc840513          	addi	a0,s0,-56
    462c:	00001097          	auipc	ra,0x1
    4630:	5aa080e7          	jalr	1450(ra) # 5bd6 <pipe>
  pid3 = fork();
    4634:	00001097          	auipc	ra,0x1
    4638:	58a080e7          	jalr	1418(ra) # 5bbe <fork>
    463c:	8a2a                	mv	s4,a0
  if(pid3 < 0) {
    463e:	02054e63          	bltz	a0,467a <preempt+0xc0>
  if(pid3 == 0){
    4642:	e525                	bnez	a0,46aa <preempt+0xf0>
    close(pfds[0]);
    4644:	fc842503          	lw	a0,-56(s0)
    4648:	00001097          	auipc	ra,0x1
    464c:	5a6080e7          	jalr	1446(ra) # 5bee <close>
    if(write(pfds[1], "x", 1) != 1)
    4650:	4605                	li	a2,1
    4652:	00002597          	auipc	a1,0x2
    4656:	b6658593          	addi	a1,a1,-1178 # 61b8 <malloc+0x1b4>
    465a:	fcc42503          	lw	a0,-52(s0)
    465e:	00001097          	auipc	ra,0x1
    4662:	588080e7          	jalr	1416(ra) # 5be6 <write>
    4666:	4785                	li	a5,1
    4668:	02f51763          	bne	a0,a5,4696 <preempt+0xdc>
    close(pfds[1]);
    466c:	fcc42503          	lw	a0,-52(s0)
    4670:	00001097          	auipc	ra,0x1
    4674:	57e080e7          	jalr	1406(ra) # 5bee <close>
    for(;;)
    4678:	a001                	j	4678 <preempt+0xbe>
     printf("%s: fork failed\n", s);
    467a:	85ca                	mv	a1,s2
    467c:	00002517          	auipc	a0,0x2
    4680:	35450513          	addi	a0,a0,852 # 69d0 <malloc+0x9cc>
    4684:	00002097          	auipc	ra,0x2
    4688:	8c2080e7          	jalr	-1854(ra) # 5f46 <printf>
     exit(1);
    468c:	4505                	li	a0,1
    468e:	00001097          	auipc	ra,0x1
    4692:	538080e7          	jalr	1336(ra) # 5bc6 <exit>
      printf("%s: preempt write error", s);
    4696:	85ca                	mv	a1,s2
    4698:	00003517          	auipc	a0,0x3
    469c:	64850513          	addi	a0,a0,1608 # 7ce0 <malloc+0x1cdc>
    46a0:	00002097          	auipc	ra,0x2
    46a4:	8a6080e7          	jalr	-1882(ra) # 5f46 <printf>
    46a8:	b7d1                	j	466c <preempt+0xb2>
  close(pfds[1]);
    46aa:	fcc42503          	lw	a0,-52(s0)
    46ae:	00001097          	auipc	ra,0x1
    46b2:	540080e7          	jalr	1344(ra) # 5bee <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    46b6:	660d                	lui	a2,0x3
    46b8:	00008597          	auipc	a1,0x8
    46bc:	5c058593          	addi	a1,a1,1472 # cc78 <buf>
    46c0:	fc842503          	lw	a0,-56(s0)
    46c4:	00001097          	auipc	ra,0x1
    46c8:	51a080e7          	jalr	1306(ra) # 5bde <read>
    46cc:	4785                	li	a5,1
    46ce:	02f50363          	beq	a0,a5,46f4 <preempt+0x13a>
    printf("%s: preempt read error", s);
    46d2:	85ca                	mv	a1,s2
    46d4:	00003517          	auipc	a0,0x3
    46d8:	62450513          	addi	a0,a0,1572 # 7cf8 <malloc+0x1cf4>
    46dc:	00002097          	auipc	ra,0x2
    46e0:	86a080e7          	jalr	-1942(ra) # 5f46 <printf>
}
    46e4:	70e2                	ld	ra,56(sp)
    46e6:	7442                	ld	s0,48(sp)
    46e8:	74a2                	ld	s1,40(sp)
    46ea:	7902                	ld	s2,32(sp)
    46ec:	69e2                	ld	s3,24(sp)
    46ee:	6a42                	ld	s4,16(sp)
    46f0:	6121                	addi	sp,sp,64
    46f2:	8082                	ret
  close(pfds[0]);
    46f4:	fc842503          	lw	a0,-56(s0)
    46f8:	00001097          	auipc	ra,0x1
    46fc:	4f6080e7          	jalr	1270(ra) # 5bee <close>
  printf("kill... ");
    4700:	00003517          	auipc	a0,0x3
    4704:	61050513          	addi	a0,a0,1552 # 7d10 <malloc+0x1d0c>
    4708:	00002097          	auipc	ra,0x2
    470c:	83e080e7          	jalr	-1986(ra) # 5f46 <printf>
  kill(pid1);
    4710:	8526                	mv	a0,s1
    4712:	00001097          	auipc	ra,0x1
    4716:	4e4080e7          	jalr	1252(ra) # 5bf6 <kill>
  kill(pid2);
    471a:	854e                	mv	a0,s3
    471c:	00001097          	auipc	ra,0x1
    4720:	4da080e7          	jalr	1242(ra) # 5bf6 <kill>
  kill(pid3);
    4724:	8552                	mv	a0,s4
    4726:	00001097          	auipc	ra,0x1
    472a:	4d0080e7          	jalr	1232(ra) # 5bf6 <kill>
  printf("wait... ");
    472e:	00003517          	auipc	a0,0x3
    4732:	5f250513          	addi	a0,a0,1522 # 7d20 <malloc+0x1d1c>
    4736:	00002097          	auipc	ra,0x2
    473a:	810080e7          	jalr	-2032(ra) # 5f46 <printf>
  wait(0);
    473e:	4501                	li	a0,0
    4740:	00001097          	auipc	ra,0x1
    4744:	48e080e7          	jalr	1166(ra) # 5bce <wait>
  wait(0);
    4748:	4501                	li	a0,0
    474a:	00001097          	auipc	ra,0x1
    474e:	484080e7          	jalr	1156(ra) # 5bce <wait>
  wait(0);
    4752:	4501                	li	a0,0
    4754:	00001097          	auipc	ra,0x1
    4758:	47a080e7          	jalr	1146(ra) # 5bce <wait>
    475c:	b761                	j	46e4 <preempt+0x12a>

000000000000475e <reparent>:
{
    475e:	7179                	addi	sp,sp,-48
    4760:	f406                	sd	ra,40(sp)
    4762:	f022                	sd	s0,32(sp)
    4764:	ec26                	sd	s1,24(sp)
    4766:	e84a                	sd	s2,16(sp)
    4768:	e44e                	sd	s3,8(sp)
    476a:	e052                	sd	s4,0(sp)
    476c:	1800                	addi	s0,sp,48
    476e:	89aa                	mv	s3,a0
  int master_pid = getpid();
    4770:	00001097          	auipc	ra,0x1
    4774:	4d6080e7          	jalr	1238(ra) # 5c46 <getpid>
    4778:	8a2a                	mv	s4,a0
    477a:	0c800913          	li	s2,200
    int pid = fork();
    477e:	00001097          	auipc	ra,0x1
    4782:	440080e7          	jalr	1088(ra) # 5bbe <fork>
    4786:	84aa                	mv	s1,a0
    if(pid < 0){
    4788:	02054263          	bltz	a0,47ac <reparent+0x4e>
    if(pid){
    478c:	cd21                	beqz	a0,47e4 <reparent+0x86>
      if(wait(0) != pid){
    478e:	4501                	li	a0,0
    4790:	00001097          	auipc	ra,0x1
    4794:	43e080e7          	jalr	1086(ra) # 5bce <wait>
    4798:	02951863          	bne	a0,s1,47c8 <reparent+0x6a>
  for(int i = 0; i < 200; i++){
    479c:	397d                	addiw	s2,s2,-1
    479e:	fe0910e3          	bnez	s2,477e <reparent+0x20>
  exit(0);
    47a2:	4501                	li	a0,0
    47a4:	00001097          	auipc	ra,0x1
    47a8:	422080e7          	jalr	1058(ra) # 5bc6 <exit>
      printf("%s: fork failed\n", s);
    47ac:	85ce                	mv	a1,s3
    47ae:	00002517          	auipc	a0,0x2
    47b2:	22250513          	addi	a0,a0,546 # 69d0 <malloc+0x9cc>
    47b6:	00001097          	auipc	ra,0x1
    47ba:	790080e7          	jalr	1936(ra) # 5f46 <printf>
      exit(1);
    47be:	4505                	li	a0,1
    47c0:	00001097          	auipc	ra,0x1
    47c4:	406080e7          	jalr	1030(ra) # 5bc6 <exit>
        printf("%s: wait wrong pid\n", s);
    47c8:	85ce                	mv	a1,s3
    47ca:	00002517          	auipc	a0,0x2
    47ce:	38e50513          	addi	a0,a0,910 # 6b58 <malloc+0xb54>
    47d2:	00001097          	auipc	ra,0x1
    47d6:	774080e7          	jalr	1908(ra) # 5f46 <printf>
        exit(1);
    47da:	4505                	li	a0,1
    47dc:	00001097          	auipc	ra,0x1
    47e0:	3ea080e7          	jalr	1002(ra) # 5bc6 <exit>
      int pid2 = fork();
    47e4:	00001097          	auipc	ra,0x1
    47e8:	3da080e7          	jalr	986(ra) # 5bbe <fork>
      if(pid2 < 0){
    47ec:	00054763          	bltz	a0,47fa <reparent+0x9c>
      exit(0);
    47f0:	4501                	li	a0,0
    47f2:	00001097          	auipc	ra,0x1
    47f6:	3d4080e7          	jalr	980(ra) # 5bc6 <exit>
        kill(master_pid);
    47fa:	8552                	mv	a0,s4
    47fc:	00001097          	auipc	ra,0x1
    4800:	3fa080e7          	jalr	1018(ra) # 5bf6 <kill>
        exit(1);
    4804:	4505                	li	a0,1
    4806:	00001097          	auipc	ra,0x1
    480a:	3c0080e7          	jalr	960(ra) # 5bc6 <exit>

000000000000480e <sbrkfail>:
{
    480e:	7119                	addi	sp,sp,-128
    4810:	fc86                	sd	ra,120(sp)
    4812:	f8a2                	sd	s0,112(sp)
    4814:	f4a6                	sd	s1,104(sp)
    4816:	f0ca                	sd	s2,96(sp)
    4818:	ecce                	sd	s3,88(sp)
    481a:	e8d2                	sd	s4,80(sp)
    481c:	e4d6                	sd	s5,72(sp)
    481e:	0100                	addi	s0,sp,128
    4820:	8aaa                	mv	s5,a0
  if(pipe(fds) != 0){
    4822:	fb040513          	addi	a0,s0,-80
    4826:	00001097          	auipc	ra,0x1
    482a:	3b0080e7          	jalr	944(ra) # 5bd6 <pipe>
    482e:	e901                	bnez	a0,483e <sbrkfail+0x30>
    4830:	f8040493          	addi	s1,s0,-128
    4834:	fa840993          	addi	s3,s0,-88
    4838:	8926                	mv	s2,s1
    if(pids[i] != -1)
    483a:	5a7d                	li	s4,-1
    483c:	a085                	j	489c <sbrkfail+0x8e>
    printf("%s: pipe() failed\n", s);
    483e:	85d6                	mv	a1,s5
    4840:	00002517          	auipc	a0,0x2
    4844:	29850513          	addi	a0,a0,664 # 6ad8 <malloc+0xad4>
    4848:	00001097          	auipc	ra,0x1
    484c:	6fe080e7          	jalr	1790(ra) # 5f46 <printf>
    exit(1);
    4850:	4505                	li	a0,1
    4852:	00001097          	auipc	ra,0x1
    4856:	374080e7          	jalr	884(ra) # 5bc6 <exit>
      sbrk(BIG - (uint64)sbrk(0));
    485a:	00001097          	auipc	ra,0x1
    485e:	3f4080e7          	jalr	1012(ra) # 5c4e <sbrk>
    4862:	064007b7          	lui	a5,0x6400
    4866:	40a7853b          	subw	a0,a5,a0
    486a:	00001097          	auipc	ra,0x1
    486e:	3e4080e7          	jalr	996(ra) # 5c4e <sbrk>
      write(fds[1], "x", 1);
    4872:	4605                	li	a2,1
    4874:	00002597          	auipc	a1,0x2
    4878:	94458593          	addi	a1,a1,-1724 # 61b8 <malloc+0x1b4>
    487c:	fb442503          	lw	a0,-76(s0)
    4880:	00001097          	auipc	ra,0x1
    4884:	366080e7          	jalr	870(ra) # 5be6 <write>
      for(;;) sleep(1000);
    4888:	3e800513          	li	a0,1000
    488c:	00001097          	auipc	ra,0x1
    4890:	3ca080e7          	jalr	970(ra) # 5c56 <sleep>
    4894:	bfd5                	j	4888 <sbrkfail+0x7a>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4896:	0911                	addi	s2,s2,4
    4898:	03390563          	beq	s2,s3,48c2 <sbrkfail+0xb4>
    if((pids[i] = fork()) == 0){
    489c:	00001097          	auipc	ra,0x1
    48a0:	322080e7          	jalr	802(ra) # 5bbe <fork>
    48a4:	00a92023          	sw	a0,0(s2)
    48a8:	d94d                	beqz	a0,485a <sbrkfail+0x4c>
    if(pids[i] != -1)
    48aa:	ff4506e3          	beq	a0,s4,4896 <sbrkfail+0x88>
      read(fds[0], &scratch, 1);
    48ae:	4605                	li	a2,1
    48b0:	faf40593          	addi	a1,s0,-81
    48b4:	fb042503          	lw	a0,-80(s0)
    48b8:	00001097          	auipc	ra,0x1
    48bc:	326080e7          	jalr	806(ra) # 5bde <read>
    48c0:	bfd9                	j	4896 <sbrkfail+0x88>
  c = sbrk(PGSIZE);
    48c2:	6505                	lui	a0,0x1
    48c4:	00001097          	auipc	ra,0x1
    48c8:	38a080e7          	jalr	906(ra) # 5c4e <sbrk>
    48cc:	8a2a                	mv	s4,a0
    if(pids[i] == -1)
    48ce:	597d                	li	s2,-1
    48d0:	a021                	j	48d8 <sbrkfail+0xca>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    48d2:	0491                	addi	s1,s1,4
    48d4:	01348f63          	beq	s1,s3,48f2 <sbrkfail+0xe4>
    if(pids[i] == -1)
    48d8:	4088                	lw	a0,0(s1)
    48da:	ff250ce3          	beq	a0,s2,48d2 <sbrkfail+0xc4>
    kill(pids[i]);
    48de:	00001097          	auipc	ra,0x1
    48e2:	318080e7          	jalr	792(ra) # 5bf6 <kill>
    wait(0);
    48e6:	4501                	li	a0,0
    48e8:	00001097          	auipc	ra,0x1
    48ec:	2e6080e7          	jalr	742(ra) # 5bce <wait>
    48f0:	b7cd                	j	48d2 <sbrkfail+0xc4>
  if(c == (char*)0xffffffffffffffffL){
    48f2:	57fd                	li	a5,-1
    48f4:	04fa0163          	beq	s4,a5,4936 <sbrkfail+0x128>
  pid = fork();
    48f8:	00001097          	auipc	ra,0x1
    48fc:	2c6080e7          	jalr	710(ra) # 5bbe <fork>
    4900:	84aa                	mv	s1,a0
  if(pid < 0){
    4902:	04054863          	bltz	a0,4952 <sbrkfail+0x144>
  if(pid == 0){
    4906:	c525                	beqz	a0,496e <sbrkfail+0x160>
  wait(&xstatus);
    4908:	fbc40513          	addi	a0,s0,-68
    490c:	00001097          	auipc	ra,0x1
    4910:	2c2080e7          	jalr	706(ra) # 5bce <wait>
  if(xstatus != -1 && xstatus != 2)
    4914:	fbc42783          	lw	a5,-68(s0)
    4918:	577d                	li	a4,-1
    491a:	00e78563          	beq	a5,a4,4924 <sbrkfail+0x116>
    491e:	4709                	li	a4,2
    4920:	08e79d63          	bne	a5,a4,49ba <sbrkfail+0x1ac>
}
    4924:	70e6                	ld	ra,120(sp)
    4926:	7446                	ld	s0,112(sp)
    4928:	74a6                	ld	s1,104(sp)
    492a:	7906                	ld	s2,96(sp)
    492c:	69e6                	ld	s3,88(sp)
    492e:	6a46                	ld	s4,80(sp)
    4930:	6aa6                	ld	s5,72(sp)
    4932:	6109                	addi	sp,sp,128
    4934:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    4936:	85d6                	mv	a1,s5
    4938:	00003517          	auipc	a0,0x3
    493c:	3f850513          	addi	a0,a0,1016 # 7d30 <malloc+0x1d2c>
    4940:	00001097          	auipc	ra,0x1
    4944:	606080e7          	jalr	1542(ra) # 5f46 <printf>
    exit(1);
    4948:	4505                	li	a0,1
    494a:	00001097          	auipc	ra,0x1
    494e:	27c080e7          	jalr	636(ra) # 5bc6 <exit>
    printf("%s: fork failed\n", s);
    4952:	85d6                	mv	a1,s5
    4954:	00002517          	auipc	a0,0x2
    4958:	07c50513          	addi	a0,a0,124 # 69d0 <malloc+0x9cc>
    495c:	00001097          	auipc	ra,0x1
    4960:	5ea080e7          	jalr	1514(ra) # 5f46 <printf>
    exit(1);
    4964:	4505                	li	a0,1
    4966:	00001097          	auipc	ra,0x1
    496a:	260080e7          	jalr	608(ra) # 5bc6 <exit>
    a = sbrk(0);
    496e:	4501                	li	a0,0
    4970:	00001097          	auipc	ra,0x1
    4974:	2de080e7          	jalr	734(ra) # 5c4e <sbrk>
    4978:	892a                	mv	s2,a0
    sbrk(10*BIG);
    497a:	3e800537          	lui	a0,0x3e800
    497e:	00001097          	auipc	ra,0x1
    4982:	2d0080e7          	jalr	720(ra) # 5c4e <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    4986:	87ca                	mv	a5,s2
    4988:	3e800737          	lui	a4,0x3e800
    498c:	993a                	add	s2,s2,a4
    498e:	6705                	lui	a4,0x1
      n += *(a+i);
    4990:	0007c683          	lbu	a3,0(a5) # 6400000 <base+0x63f0388>
    4994:	9cb5                	addw	s1,s1,a3
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    4996:	97ba                	add	a5,a5,a4
    4998:	ff279ce3          	bne	a5,s2,4990 <sbrkfail+0x182>
    printf("%s: allocate a lot of memory succeeded %d\n", s, n);
    499c:	8626                	mv	a2,s1
    499e:	85d6                	mv	a1,s5
    49a0:	00003517          	auipc	a0,0x3
    49a4:	3b050513          	addi	a0,a0,944 # 7d50 <malloc+0x1d4c>
    49a8:	00001097          	auipc	ra,0x1
    49ac:	59e080e7          	jalr	1438(ra) # 5f46 <printf>
    exit(1);
    49b0:	4505                	li	a0,1
    49b2:	00001097          	auipc	ra,0x1
    49b6:	214080e7          	jalr	532(ra) # 5bc6 <exit>
    exit(1);
    49ba:	4505                	li	a0,1
    49bc:	00001097          	auipc	ra,0x1
    49c0:	20a080e7          	jalr	522(ra) # 5bc6 <exit>

00000000000049c4 <mem>:
{
    49c4:	7139                	addi	sp,sp,-64
    49c6:	fc06                	sd	ra,56(sp)
    49c8:	f822                	sd	s0,48(sp)
    49ca:	f426                	sd	s1,40(sp)
    49cc:	f04a                	sd	s2,32(sp)
    49ce:	ec4e                	sd	s3,24(sp)
    49d0:	0080                	addi	s0,sp,64
    49d2:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    49d4:	00001097          	auipc	ra,0x1
    49d8:	1ea080e7          	jalr	490(ra) # 5bbe <fork>
    m1 = 0;
    49dc:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    49de:	6909                	lui	s2,0x2
    49e0:	71190913          	addi	s2,s2,1809 # 2711 <copyinstr3+0x103>
  if((pid = fork()) == 0){
    49e4:	c115                	beqz	a0,4a08 <mem+0x44>
    wait(&xstatus);
    49e6:	fcc40513          	addi	a0,s0,-52
    49ea:	00001097          	auipc	ra,0x1
    49ee:	1e4080e7          	jalr	484(ra) # 5bce <wait>
    if(xstatus == -1){
    49f2:	fcc42503          	lw	a0,-52(s0)
    49f6:	57fd                	li	a5,-1
    49f8:	06f50363          	beq	a0,a5,4a5e <mem+0x9a>
    exit(xstatus);
    49fc:	00001097          	auipc	ra,0x1
    4a00:	1ca080e7          	jalr	458(ra) # 5bc6 <exit>
      *(char**)m2 = m1;
    4a04:	e104                	sd	s1,0(a0)
      m1 = m2;
    4a06:	84aa                	mv	s1,a0
    while((m2 = malloc(10001)) != 0){
    4a08:	854a                	mv	a0,s2
    4a0a:	00001097          	auipc	ra,0x1
    4a0e:	5fa080e7          	jalr	1530(ra) # 6004 <malloc>
    4a12:	f96d                	bnez	a0,4a04 <mem+0x40>
    while(m1){
    4a14:	c881                	beqz	s1,4a24 <mem+0x60>
      m2 = *(char**)m1;
    4a16:	8526                	mv	a0,s1
    4a18:	6084                	ld	s1,0(s1)
      free(m1);
    4a1a:	00001097          	auipc	ra,0x1
    4a1e:	562080e7          	jalr	1378(ra) # 5f7c <free>
    while(m1){
    4a22:	f8f5                	bnez	s1,4a16 <mem+0x52>
    m1 = malloc(1024*20);
    4a24:	6515                	lui	a0,0x5
    4a26:	00001097          	auipc	ra,0x1
    4a2a:	5de080e7          	jalr	1502(ra) # 6004 <malloc>
    if(m1 == 0){
    4a2e:	c911                	beqz	a0,4a42 <mem+0x7e>
    free(m1);
    4a30:	00001097          	auipc	ra,0x1
    4a34:	54c080e7          	jalr	1356(ra) # 5f7c <free>
    exit(0);
    4a38:	4501                	li	a0,0
    4a3a:	00001097          	auipc	ra,0x1
    4a3e:	18c080e7          	jalr	396(ra) # 5bc6 <exit>
      printf("couldn't allocate mem?!!\n", s);
    4a42:	85ce                	mv	a1,s3
    4a44:	00003517          	auipc	a0,0x3
    4a48:	33c50513          	addi	a0,a0,828 # 7d80 <malloc+0x1d7c>
    4a4c:	00001097          	auipc	ra,0x1
    4a50:	4fa080e7          	jalr	1274(ra) # 5f46 <printf>
      exit(1);
    4a54:	4505                	li	a0,1
    4a56:	00001097          	auipc	ra,0x1
    4a5a:	170080e7          	jalr	368(ra) # 5bc6 <exit>
      exit(0);
    4a5e:	4501                	li	a0,0
    4a60:	00001097          	auipc	ra,0x1
    4a64:	166080e7          	jalr	358(ra) # 5bc6 <exit>

0000000000004a68 <sharedfd>:
{
    4a68:	7159                	addi	sp,sp,-112
    4a6a:	f486                	sd	ra,104(sp)
    4a6c:	f0a2                	sd	s0,96(sp)
    4a6e:	eca6                	sd	s1,88(sp)
    4a70:	e8ca                	sd	s2,80(sp)
    4a72:	e4ce                	sd	s3,72(sp)
    4a74:	e0d2                	sd	s4,64(sp)
    4a76:	fc56                	sd	s5,56(sp)
    4a78:	f85a                	sd	s6,48(sp)
    4a7a:	f45e                	sd	s7,40(sp)
    4a7c:	1880                	addi	s0,sp,112
    4a7e:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    4a80:	00003517          	auipc	a0,0x3
    4a84:	32050513          	addi	a0,a0,800 # 7da0 <malloc+0x1d9c>
    4a88:	00001097          	auipc	ra,0x1
    4a8c:	18e080e7          	jalr	398(ra) # 5c16 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    4a90:	20200593          	li	a1,514
    4a94:	00003517          	auipc	a0,0x3
    4a98:	30c50513          	addi	a0,a0,780 # 7da0 <malloc+0x1d9c>
    4a9c:	00001097          	auipc	ra,0x1
    4aa0:	16a080e7          	jalr	362(ra) # 5c06 <open>
  if(fd < 0){
    4aa4:	04054a63          	bltz	a0,4af8 <sharedfd+0x90>
    4aa8:	892a                	mv	s2,a0
  pid = fork();
    4aaa:	00001097          	auipc	ra,0x1
    4aae:	114080e7          	jalr	276(ra) # 5bbe <fork>
    4ab2:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    4ab4:	06300593          	li	a1,99
    4ab8:	c119                	beqz	a0,4abe <sharedfd+0x56>
    4aba:	07000593          	li	a1,112
    4abe:	4629                	li	a2,10
    4ac0:	fa040513          	addi	a0,s0,-96
    4ac4:	00001097          	auipc	ra,0x1
    4ac8:	f06080e7          	jalr	-250(ra) # 59ca <memset>
    4acc:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    4ad0:	4629                	li	a2,10
    4ad2:	fa040593          	addi	a1,s0,-96
    4ad6:	854a                	mv	a0,s2
    4ad8:	00001097          	auipc	ra,0x1
    4adc:	10e080e7          	jalr	270(ra) # 5be6 <write>
    4ae0:	47a9                	li	a5,10
    4ae2:	02f51963          	bne	a0,a5,4b14 <sharedfd+0xac>
  for(i = 0; i < N; i++){
    4ae6:	34fd                	addiw	s1,s1,-1
    4ae8:	f4e5                	bnez	s1,4ad0 <sharedfd+0x68>
  if(pid == 0) {
    4aea:	04099363          	bnez	s3,4b30 <sharedfd+0xc8>
    exit(0);
    4aee:	4501                	li	a0,0
    4af0:	00001097          	auipc	ra,0x1
    4af4:	0d6080e7          	jalr	214(ra) # 5bc6 <exit>
    printf("%s: cannot open sharedfd for writing", s);
    4af8:	85d2                	mv	a1,s4
    4afa:	00003517          	auipc	a0,0x3
    4afe:	2b650513          	addi	a0,a0,694 # 7db0 <malloc+0x1dac>
    4b02:	00001097          	auipc	ra,0x1
    4b06:	444080e7          	jalr	1092(ra) # 5f46 <printf>
    exit(1);
    4b0a:	4505                	li	a0,1
    4b0c:	00001097          	auipc	ra,0x1
    4b10:	0ba080e7          	jalr	186(ra) # 5bc6 <exit>
      printf("%s: write sharedfd failed\n", s);
    4b14:	85d2                	mv	a1,s4
    4b16:	00003517          	auipc	a0,0x3
    4b1a:	2c250513          	addi	a0,a0,706 # 7dd8 <malloc+0x1dd4>
    4b1e:	00001097          	auipc	ra,0x1
    4b22:	428080e7          	jalr	1064(ra) # 5f46 <printf>
      exit(1);
    4b26:	4505                	li	a0,1
    4b28:	00001097          	auipc	ra,0x1
    4b2c:	09e080e7          	jalr	158(ra) # 5bc6 <exit>
    wait(&xstatus);
    4b30:	f9c40513          	addi	a0,s0,-100
    4b34:	00001097          	auipc	ra,0x1
    4b38:	09a080e7          	jalr	154(ra) # 5bce <wait>
    if(xstatus != 0)
    4b3c:	f9c42983          	lw	s3,-100(s0)
    4b40:	00098763          	beqz	s3,4b4e <sharedfd+0xe6>
      exit(xstatus);
    4b44:	854e                	mv	a0,s3
    4b46:	00001097          	auipc	ra,0x1
    4b4a:	080080e7          	jalr	128(ra) # 5bc6 <exit>
  close(fd);
    4b4e:	854a                	mv	a0,s2
    4b50:	00001097          	auipc	ra,0x1
    4b54:	09e080e7          	jalr	158(ra) # 5bee <close>
  fd = open("sharedfd", 0);
    4b58:	4581                	li	a1,0
    4b5a:	00003517          	auipc	a0,0x3
    4b5e:	24650513          	addi	a0,a0,582 # 7da0 <malloc+0x1d9c>
    4b62:	00001097          	auipc	ra,0x1
    4b66:	0a4080e7          	jalr	164(ra) # 5c06 <open>
    4b6a:	8baa                	mv	s7,a0
  nc = np = 0;
    4b6c:	8ace                	mv	s5,s3
  if(fd < 0){
    4b6e:	02054563          	bltz	a0,4b98 <sharedfd+0x130>
    4b72:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    4b76:	06300493          	li	s1,99
      if(buf[i] == 'p')
    4b7a:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    4b7e:	4629                	li	a2,10
    4b80:	fa040593          	addi	a1,s0,-96
    4b84:	855e                	mv	a0,s7
    4b86:	00001097          	auipc	ra,0x1
    4b8a:	058080e7          	jalr	88(ra) # 5bde <read>
    4b8e:	02a05f63          	blez	a0,4bcc <sharedfd+0x164>
    4b92:	fa040793          	addi	a5,s0,-96
    4b96:	a01d                	j	4bbc <sharedfd+0x154>
    printf("%s: cannot open sharedfd for reading\n", s);
    4b98:	85d2                	mv	a1,s4
    4b9a:	00003517          	auipc	a0,0x3
    4b9e:	25e50513          	addi	a0,a0,606 # 7df8 <malloc+0x1df4>
    4ba2:	00001097          	auipc	ra,0x1
    4ba6:	3a4080e7          	jalr	932(ra) # 5f46 <printf>
    exit(1);
    4baa:	4505                	li	a0,1
    4bac:	00001097          	auipc	ra,0x1
    4bb0:	01a080e7          	jalr	26(ra) # 5bc6 <exit>
        nc++;
    4bb4:	2985                	addiw	s3,s3,1
    for(i = 0; i < sizeof(buf); i++){
    4bb6:	0785                	addi	a5,a5,1
    4bb8:	fd2783e3          	beq	a5,s2,4b7e <sharedfd+0x116>
      if(buf[i] == 'c')
    4bbc:	0007c703          	lbu	a4,0(a5)
    4bc0:	fe970ae3          	beq	a4,s1,4bb4 <sharedfd+0x14c>
      if(buf[i] == 'p')
    4bc4:	ff6719e3          	bne	a4,s6,4bb6 <sharedfd+0x14e>
        np++;
    4bc8:	2a85                	addiw	s5,s5,1
    4bca:	b7f5                	j	4bb6 <sharedfd+0x14e>
  close(fd);
    4bcc:	855e                	mv	a0,s7
    4bce:	00001097          	auipc	ra,0x1
    4bd2:	020080e7          	jalr	32(ra) # 5bee <close>
  unlink("sharedfd");
    4bd6:	00003517          	auipc	a0,0x3
    4bda:	1ca50513          	addi	a0,a0,458 # 7da0 <malloc+0x1d9c>
    4bde:	00001097          	auipc	ra,0x1
    4be2:	038080e7          	jalr	56(ra) # 5c16 <unlink>
  if(nc == N*SZ && np == N*SZ){
    4be6:	6789                	lui	a5,0x2
    4be8:	71078793          	addi	a5,a5,1808 # 2710 <copyinstr3+0x102>
    4bec:	00f99763          	bne	s3,a5,4bfa <sharedfd+0x192>
    4bf0:	6789                	lui	a5,0x2
    4bf2:	71078793          	addi	a5,a5,1808 # 2710 <copyinstr3+0x102>
    4bf6:	02fa8063          	beq	s5,a5,4c16 <sharedfd+0x1ae>
    printf("%s: nc/np test fails\n", s);
    4bfa:	85d2                	mv	a1,s4
    4bfc:	00003517          	auipc	a0,0x3
    4c00:	22450513          	addi	a0,a0,548 # 7e20 <malloc+0x1e1c>
    4c04:	00001097          	auipc	ra,0x1
    4c08:	342080e7          	jalr	834(ra) # 5f46 <printf>
    exit(1);
    4c0c:	4505                	li	a0,1
    4c0e:	00001097          	auipc	ra,0x1
    4c12:	fb8080e7          	jalr	-72(ra) # 5bc6 <exit>
    exit(0);
    4c16:	4501                	li	a0,0
    4c18:	00001097          	auipc	ra,0x1
    4c1c:	fae080e7          	jalr	-82(ra) # 5bc6 <exit>

0000000000004c20 <fourfiles>:
{
    4c20:	7171                	addi	sp,sp,-176
    4c22:	f506                	sd	ra,168(sp)
    4c24:	f122                	sd	s0,160(sp)
    4c26:	ed26                	sd	s1,152(sp)
    4c28:	e94a                	sd	s2,144(sp)
    4c2a:	e54e                	sd	s3,136(sp)
    4c2c:	e152                	sd	s4,128(sp)
    4c2e:	fcd6                	sd	s5,120(sp)
    4c30:	f8da                	sd	s6,112(sp)
    4c32:	f4de                	sd	s7,104(sp)
    4c34:	f0e2                	sd	s8,96(sp)
    4c36:	ece6                	sd	s9,88(sp)
    4c38:	e8ea                	sd	s10,80(sp)
    4c3a:	e4ee                	sd	s11,72(sp)
    4c3c:	1900                	addi	s0,sp,176
    4c3e:	f4a43c23          	sd	a0,-168(s0)
  char *names[] = { "f0", "f1", "f2", "f3" };
    4c42:	00001797          	auipc	a5,0x1
    4c46:	4ae78793          	addi	a5,a5,1198 # 60f0 <malloc+0xec>
    4c4a:	f6f43823          	sd	a5,-144(s0)
    4c4e:	00001797          	auipc	a5,0x1
    4c52:	4aa78793          	addi	a5,a5,1194 # 60f8 <malloc+0xf4>
    4c56:	f6f43c23          	sd	a5,-136(s0)
    4c5a:	00001797          	auipc	a5,0x1
    4c5e:	4a678793          	addi	a5,a5,1190 # 6100 <malloc+0xfc>
    4c62:	f8f43023          	sd	a5,-128(s0)
    4c66:	00001797          	auipc	a5,0x1
    4c6a:	4a278793          	addi	a5,a5,1186 # 6108 <malloc+0x104>
    4c6e:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    4c72:	f7040c13          	addi	s8,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    4c76:	8962                	mv	s2,s8
  for(pi = 0; pi < NCHILD; pi++){
    4c78:	4481                	li	s1,0
    4c7a:	4a11                	li	s4,4
    fname = names[pi];
    4c7c:	00093983          	ld	s3,0(s2)
    unlink(fname);
    4c80:	854e                	mv	a0,s3
    4c82:	00001097          	auipc	ra,0x1
    4c86:	f94080e7          	jalr	-108(ra) # 5c16 <unlink>
    pid = fork();
    4c8a:	00001097          	auipc	ra,0x1
    4c8e:	f34080e7          	jalr	-204(ra) # 5bbe <fork>
    if(pid < 0){
    4c92:	04054463          	bltz	a0,4cda <fourfiles+0xba>
    if(pid == 0){
    4c96:	c12d                	beqz	a0,4cf8 <fourfiles+0xd8>
  for(pi = 0; pi < NCHILD; pi++){
    4c98:	2485                	addiw	s1,s1,1
    4c9a:	0921                	addi	s2,s2,8
    4c9c:	ff4490e3          	bne	s1,s4,4c7c <fourfiles+0x5c>
    4ca0:	4491                	li	s1,4
    wait(&xstatus);
    4ca2:	f6c40513          	addi	a0,s0,-148
    4ca6:	00001097          	auipc	ra,0x1
    4caa:	f28080e7          	jalr	-216(ra) # 5bce <wait>
    if(xstatus != 0)
    4cae:	f6c42b03          	lw	s6,-148(s0)
    4cb2:	0c0b1e63          	bnez	s6,4d8e <fourfiles+0x16e>
  for(pi = 0; pi < NCHILD; pi++){
    4cb6:	34fd                	addiw	s1,s1,-1
    4cb8:	f4ed                	bnez	s1,4ca2 <fourfiles+0x82>
    4cba:	03000b93          	li	s7,48
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4cbe:	00008a17          	auipc	s4,0x8
    4cc2:	fbaa0a13          	addi	s4,s4,-70 # cc78 <buf>
    4cc6:	00008a97          	auipc	s5,0x8
    4cca:	fb3a8a93          	addi	s5,s5,-77 # cc79 <buf+0x1>
    if(total != N*SZ){
    4cce:	6d85                	lui	s11,0x1
    4cd0:	770d8d93          	addi	s11,s11,1904 # 1770 <exectest+0x2e>
  for(i = 0; i < NCHILD; i++){
    4cd4:	03400d13          	li	s10,52
    4cd8:	aa1d                	j	4e0e <fourfiles+0x1ee>
      printf("fork failed\n", s);
    4cda:	f5843583          	ld	a1,-168(s0)
    4cde:	00002517          	auipc	a0,0x2
    4ce2:	0fa50513          	addi	a0,a0,250 # 6dd8 <malloc+0xdd4>
    4ce6:	00001097          	auipc	ra,0x1
    4cea:	260080e7          	jalr	608(ra) # 5f46 <printf>
      exit(1);
    4cee:	4505                	li	a0,1
    4cf0:	00001097          	auipc	ra,0x1
    4cf4:	ed6080e7          	jalr	-298(ra) # 5bc6 <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    4cf8:	20200593          	li	a1,514
    4cfc:	854e                	mv	a0,s3
    4cfe:	00001097          	auipc	ra,0x1
    4d02:	f08080e7          	jalr	-248(ra) # 5c06 <open>
    4d06:	892a                	mv	s2,a0
      if(fd < 0){
    4d08:	04054763          	bltz	a0,4d56 <fourfiles+0x136>
      memset(buf, '0'+pi, SZ);
    4d0c:	1f400613          	li	a2,500
    4d10:	0304859b          	addiw	a1,s1,48
    4d14:	00008517          	auipc	a0,0x8
    4d18:	f6450513          	addi	a0,a0,-156 # cc78 <buf>
    4d1c:	00001097          	auipc	ra,0x1
    4d20:	cae080e7          	jalr	-850(ra) # 59ca <memset>
    4d24:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    4d26:	00008997          	auipc	s3,0x8
    4d2a:	f5298993          	addi	s3,s3,-174 # cc78 <buf>
    4d2e:	1f400613          	li	a2,500
    4d32:	85ce                	mv	a1,s3
    4d34:	854a                	mv	a0,s2
    4d36:	00001097          	auipc	ra,0x1
    4d3a:	eb0080e7          	jalr	-336(ra) # 5be6 <write>
    4d3e:	85aa                	mv	a1,a0
    4d40:	1f400793          	li	a5,500
    4d44:	02f51863          	bne	a0,a5,4d74 <fourfiles+0x154>
      for(i = 0; i < N; i++){
    4d48:	34fd                	addiw	s1,s1,-1
    4d4a:	f0f5                	bnez	s1,4d2e <fourfiles+0x10e>
      exit(0);
    4d4c:	4501                	li	a0,0
    4d4e:	00001097          	auipc	ra,0x1
    4d52:	e78080e7          	jalr	-392(ra) # 5bc6 <exit>
        printf("create failed\n", s);
    4d56:	f5843583          	ld	a1,-168(s0)
    4d5a:	00003517          	auipc	a0,0x3
    4d5e:	0de50513          	addi	a0,a0,222 # 7e38 <malloc+0x1e34>
    4d62:	00001097          	auipc	ra,0x1
    4d66:	1e4080e7          	jalr	484(ra) # 5f46 <printf>
        exit(1);
    4d6a:	4505                	li	a0,1
    4d6c:	00001097          	auipc	ra,0x1
    4d70:	e5a080e7          	jalr	-422(ra) # 5bc6 <exit>
          printf("write failed %d\n", n);
    4d74:	00003517          	auipc	a0,0x3
    4d78:	0d450513          	addi	a0,a0,212 # 7e48 <malloc+0x1e44>
    4d7c:	00001097          	auipc	ra,0x1
    4d80:	1ca080e7          	jalr	458(ra) # 5f46 <printf>
          exit(1);
    4d84:	4505                	li	a0,1
    4d86:	00001097          	auipc	ra,0x1
    4d8a:	e40080e7          	jalr	-448(ra) # 5bc6 <exit>
      exit(xstatus);
    4d8e:	855a                	mv	a0,s6
    4d90:	00001097          	auipc	ra,0x1
    4d94:	e36080e7          	jalr	-458(ra) # 5bc6 <exit>
          printf("wrong char\n", s);
    4d98:	f5843583          	ld	a1,-168(s0)
    4d9c:	00003517          	auipc	a0,0x3
    4da0:	0c450513          	addi	a0,a0,196 # 7e60 <malloc+0x1e5c>
    4da4:	00001097          	auipc	ra,0x1
    4da8:	1a2080e7          	jalr	418(ra) # 5f46 <printf>
          exit(1);
    4dac:	4505                	li	a0,1
    4dae:	00001097          	auipc	ra,0x1
    4db2:	e18080e7          	jalr	-488(ra) # 5bc6 <exit>
      total += n;
    4db6:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4dba:	660d                	lui	a2,0x3
    4dbc:	85d2                	mv	a1,s4
    4dbe:	854e                	mv	a0,s3
    4dc0:	00001097          	auipc	ra,0x1
    4dc4:	e1e080e7          	jalr	-482(ra) # 5bde <read>
    4dc8:	02a05363          	blez	a0,4dee <fourfiles+0x1ce>
    4dcc:	00008797          	auipc	a5,0x8
    4dd0:	eac78793          	addi	a5,a5,-340 # cc78 <buf>
    4dd4:	fff5069b          	addiw	a3,a0,-1
    4dd8:	1682                	slli	a3,a3,0x20
    4dda:	9281                	srli	a3,a3,0x20
    4ddc:	96d6                	add	a3,a3,s5
        if(buf[j] != '0'+i){
    4dde:	0007c703          	lbu	a4,0(a5)
    4de2:	fa971be3          	bne	a4,s1,4d98 <fourfiles+0x178>
      for(j = 0; j < n; j++){
    4de6:	0785                	addi	a5,a5,1
    4de8:	fed79be3          	bne	a5,a3,4dde <fourfiles+0x1be>
    4dec:	b7e9                	j	4db6 <fourfiles+0x196>
    close(fd);
    4dee:	854e                	mv	a0,s3
    4df0:	00001097          	auipc	ra,0x1
    4df4:	dfe080e7          	jalr	-514(ra) # 5bee <close>
    if(total != N*SZ){
    4df8:	03b91863          	bne	s2,s11,4e28 <fourfiles+0x208>
    unlink(fname);
    4dfc:	8566                	mv	a0,s9
    4dfe:	00001097          	auipc	ra,0x1
    4e02:	e18080e7          	jalr	-488(ra) # 5c16 <unlink>
  for(i = 0; i < NCHILD; i++){
    4e06:	0c21                	addi	s8,s8,8
    4e08:	2b85                	addiw	s7,s7,1
    4e0a:	03ab8d63          	beq	s7,s10,4e44 <fourfiles+0x224>
    fname = names[i];
    4e0e:	000c3c83          	ld	s9,0(s8)
    fd = open(fname, 0);
    4e12:	4581                	li	a1,0
    4e14:	8566                	mv	a0,s9
    4e16:	00001097          	auipc	ra,0x1
    4e1a:	df0080e7          	jalr	-528(ra) # 5c06 <open>
    4e1e:	89aa                	mv	s3,a0
    total = 0;
    4e20:	895a                	mv	s2,s6
        if(buf[j] != '0'+i){
    4e22:	000b849b          	sext.w	s1,s7
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4e26:	bf51                	j	4dba <fourfiles+0x19a>
      printf("wrong length %d\n", total);
    4e28:	85ca                	mv	a1,s2
    4e2a:	00003517          	auipc	a0,0x3
    4e2e:	04650513          	addi	a0,a0,70 # 7e70 <malloc+0x1e6c>
    4e32:	00001097          	auipc	ra,0x1
    4e36:	114080e7          	jalr	276(ra) # 5f46 <printf>
      exit(1);
    4e3a:	4505                	li	a0,1
    4e3c:	00001097          	auipc	ra,0x1
    4e40:	d8a080e7          	jalr	-630(ra) # 5bc6 <exit>
}
    4e44:	70aa                	ld	ra,168(sp)
    4e46:	740a                	ld	s0,160(sp)
    4e48:	64ea                	ld	s1,152(sp)
    4e4a:	694a                	ld	s2,144(sp)
    4e4c:	69aa                	ld	s3,136(sp)
    4e4e:	6a0a                	ld	s4,128(sp)
    4e50:	7ae6                	ld	s5,120(sp)
    4e52:	7b46                	ld	s6,112(sp)
    4e54:	7ba6                	ld	s7,104(sp)
    4e56:	7c06                	ld	s8,96(sp)
    4e58:	6ce6                	ld	s9,88(sp)
    4e5a:	6d46                	ld	s10,80(sp)
    4e5c:	6da6                	ld	s11,72(sp)
    4e5e:	614d                	addi	sp,sp,176
    4e60:	8082                	ret

0000000000004e62 <concreate>:
{
    4e62:	7135                	addi	sp,sp,-160
    4e64:	ed06                	sd	ra,152(sp)
    4e66:	e922                	sd	s0,144(sp)
    4e68:	e526                	sd	s1,136(sp)
    4e6a:	e14a                	sd	s2,128(sp)
    4e6c:	fcce                	sd	s3,120(sp)
    4e6e:	f8d2                	sd	s4,112(sp)
    4e70:	f4d6                	sd	s5,104(sp)
    4e72:	f0da                	sd	s6,96(sp)
    4e74:	ecde                	sd	s7,88(sp)
    4e76:	1100                	addi	s0,sp,160
    4e78:	89aa                	mv	s3,a0
  file[0] = 'C';
    4e7a:	04300793          	li	a5,67
    4e7e:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    4e82:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    4e86:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    4e88:	4b0d                	li	s6,3
    4e8a:	4a85                	li	s5,1
      link("C0", file);
    4e8c:	00003b97          	auipc	s7,0x3
    4e90:	ffcb8b93          	addi	s7,s7,-4 # 7e88 <malloc+0x1e84>
  for(i = 0; i < N; i++){
    4e94:	02800a13          	li	s4,40
    4e98:	acc1                	j	5168 <concreate+0x306>
      link("C0", file);
    4e9a:	fa840593          	addi	a1,s0,-88
    4e9e:	855e                	mv	a0,s7
    4ea0:	00001097          	auipc	ra,0x1
    4ea4:	d86080e7          	jalr	-634(ra) # 5c26 <link>
    if(pid == 0) {
    4ea8:	a45d                	j	514e <concreate+0x2ec>
    } else if(pid == 0 && (i % 5) == 1){
    4eaa:	4795                	li	a5,5
    4eac:	02f9693b          	remw	s2,s2,a5
    4eb0:	4785                	li	a5,1
    4eb2:	02f90b63          	beq	s2,a5,4ee8 <concreate+0x86>
      fd = open(file, O_CREATE | O_RDWR);
    4eb6:	20200593          	li	a1,514
    4eba:	fa840513          	addi	a0,s0,-88
    4ebe:	00001097          	auipc	ra,0x1
    4ec2:	d48080e7          	jalr	-696(ra) # 5c06 <open>
      if(fd < 0){
    4ec6:	26055b63          	bgez	a0,513c <concreate+0x2da>
        printf("concreate create %s failed\n", file);
    4eca:	fa840593          	addi	a1,s0,-88
    4ece:	00003517          	auipc	a0,0x3
    4ed2:	fc250513          	addi	a0,a0,-62 # 7e90 <malloc+0x1e8c>
    4ed6:	00001097          	auipc	ra,0x1
    4eda:	070080e7          	jalr	112(ra) # 5f46 <printf>
        exit(1);
    4ede:	4505                	li	a0,1
    4ee0:	00001097          	auipc	ra,0x1
    4ee4:	ce6080e7          	jalr	-794(ra) # 5bc6 <exit>
      link("C0", file);
    4ee8:	fa840593          	addi	a1,s0,-88
    4eec:	00003517          	auipc	a0,0x3
    4ef0:	f9c50513          	addi	a0,a0,-100 # 7e88 <malloc+0x1e84>
    4ef4:	00001097          	auipc	ra,0x1
    4ef8:	d32080e7          	jalr	-718(ra) # 5c26 <link>
      exit(0);
    4efc:	4501                	li	a0,0
    4efe:	00001097          	auipc	ra,0x1
    4f02:	cc8080e7          	jalr	-824(ra) # 5bc6 <exit>
        exit(1);
    4f06:	4505                	li	a0,1
    4f08:	00001097          	auipc	ra,0x1
    4f0c:	cbe080e7          	jalr	-834(ra) # 5bc6 <exit>
  memset(fa, 0, sizeof(fa));
    4f10:	02800613          	li	a2,40
    4f14:	4581                	li	a1,0
    4f16:	f8040513          	addi	a0,s0,-128
    4f1a:	00001097          	auipc	ra,0x1
    4f1e:	ab0080e7          	jalr	-1360(ra) # 59ca <memset>
  fd = open(".", 0);
    4f22:	4581                	li	a1,0
    4f24:	00002517          	auipc	a0,0x2
    4f28:	90c50513          	addi	a0,a0,-1780 # 6830 <malloc+0x82c>
    4f2c:	00001097          	auipc	ra,0x1
    4f30:	cda080e7          	jalr	-806(ra) # 5c06 <open>
    4f34:	892a                	mv	s2,a0
  n = 0;
    4f36:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    4f38:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    4f3c:	02700b13          	li	s6,39
      fa[i] = 1;
    4f40:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    4f42:	4641                	li	a2,16
    4f44:	f7040593          	addi	a1,s0,-144
    4f48:	854a                	mv	a0,s2
    4f4a:	00001097          	auipc	ra,0x1
    4f4e:	c94080e7          	jalr	-876(ra) # 5bde <read>
    4f52:	08a05163          	blez	a0,4fd4 <concreate+0x172>
    if(de.inum == 0)
    4f56:	f7045783          	lhu	a5,-144(s0)
    4f5a:	d7e5                	beqz	a5,4f42 <concreate+0xe0>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    4f5c:	f7244783          	lbu	a5,-142(s0)
    4f60:	ff4791e3          	bne	a5,s4,4f42 <concreate+0xe0>
    4f64:	f7444783          	lbu	a5,-140(s0)
    4f68:	ffe9                	bnez	a5,4f42 <concreate+0xe0>
      i = de.name[1] - '0';
    4f6a:	f7344783          	lbu	a5,-141(s0)
    4f6e:	fd07879b          	addiw	a5,a5,-48
    4f72:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    4f76:	00eb6f63          	bltu	s6,a4,4f94 <concreate+0x132>
      if(fa[i]){
    4f7a:	fb040793          	addi	a5,s0,-80
    4f7e:	97ba                	add	a5,a5,a4
    4f80:	fd07c783          	lbu	a5,-48(a5)
    4f84:	eb85                	bnez	a5,4fb4 <concreate+0x152>
      fa[i] = 1;
    4f86:	fb040793          	addi	a5,s0,-80
    4f8a:	973e                	add	a4,a4,a5
    4f8c:	fd770823          	sb	s7,-48(a4) # fd0 <linktest+0xda>
      n++;
    4f90:	2a85                	addiw	s5,s5,1
    4f92:	bf45                	j	4f42 <concreate+0xe0>
        printf("%s: concreate weird file %s\n", s, de.name);
    4f94:	f7240613          	addi	a2,s0,-142
    4f98:	85ce                	mv	a1,s3
    4f9a:	00003517          	auipc	a0,0x3
    4f9e:	f1650513          	addi	a0,a0,-234 # 7eb0 <malloc+0x1eac>
    4fa2:	00001097          	auipc	ra,0x1
    4fa6:	fa4080e7          	jalr	-92(ra) # 5f46 <printf>
        exit(1);
    4faa:	4505                	li	a0,1
    4fac:	00001097          	auipc	ra,0x1
    4fb0:	c1a080e7          	jalr	-998(ra) # 5bc6 <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    4fb4:	f7240613          	addi	a2,s0,-142
    4fb8:	85ce                	mv	a1,s3
    4fba:	00003517          	auipc	a0,0x3
    4fbe:	f1650513          	addi	a0,a0,-234 # 7ed0 <malloc+0x1ecc>
    4fc2:	00001097          	auipc	ra,0x1
    4fc6:	f84080e7          	jalr	-124(ra) # 5f46 <printf>
        exit(1);
    4fca:	4505                	li	a0,1
    4fcc:	00001097          	auipc	ra,0x1
    4fd0:	bfa080e7          	jalr	-1030(ra) # 5bc6 <exit>
  close(fd);
    4fd4:	854a                	mv	a0,s2
    4fd6:	00001097          	auipc	ra,0x1
    4fda:	c18080e7          	jalr	-1000(ra) # 5bee <close>
  if(n != N){
    4fde:	02800793          	li	a5,40
    4fe2:	00fa9763          	bne	s5,a5,4ff0 <concreate+0x18e>
    if(((i % 3) == 0 && pid == 0) ||
    4fe6:	4a8d                	li	s5,3
    4fe8:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    4fea:	02800a13          	li	s4,40
    4fee:	a8c9                	j	50c0 <concreate+0x25e>
    printf("%s: concreate not enough files in directory listing\n", s);
    4ff0:	85ce                	mv	a1,s3
    4ff2:	00003517          	auipc	a0,0x3
    4ff6:	f0650513          	addi	a0,a0,-250 # 7ef8 <malloc+0x1ef4>
    4ffa:	00001097          	auipc	ra,0x1
    4ffe:	f4c080e7          	jalr	-180(ra) # 5f46 <printf>
    exit(1);
    5002:	4505                	li	a0,1
    5004:	00001097          	auipc	ra,0x1
    5008:	bc2080e7          	jalr	-1086(ra) # 5bc6 <exit>
      printf("%s: fork failed\n", s);
    500c:	85ce                	mv	a1,s3
    500e:	00002517          	auipc	a0,0x2
    5012:	9c250513          	addi	a0,a0,-1598 # 69d0 <malloc+0x9cc>
    5016:	00001097          	auipc	ra,0x1
    501a:	f30080e7          	jalr	-208(ra) # 5f46 <printf>
      exit(1);
    501e:	4505                	li	a0,1
    5020:	00001097          	auipc	ra,0x1
    5024:	ba6080e7          	jalr	-1114(ra) # 5bc6 <exit>
      close(open(file, 0));
    5028:	4581                	li	a1,0
    502a:	fa840513          	addi	a0,s0,-88
    502e:	00001097          	auipc	ra,0x1
    5032:	bd8080e7          	jalr	-1064(ra) # 5c06 <open>
    5036:	00001097          	auipc	ra,0x1
    503a:	bb8080e7          	jalr	-1096(ra) # 5bee <close>
      close(open(file, 0));
    503e:	4581                	li	a1,0
    5040:	fa840513          	addi	a0,s0,-88
    5044:	00001097          	auipc	ra,0x1
    5048:	bc2080e7          	jalr	-1086(ra) # 5c06 <open>
    504c:	00001097          	auipc	ra,0x1
    5050:	ba2080e7          	jalr	-1118(ra) # 5bee <close>
      close(open(file, 0));
    5054:	4581                	li	a1,0
    5056:	fa840513          	addi	a0,s0,-88
    505a:	00001097          	auipc	ra,0x1
    505e:	bac080e7          	jalr	-1108(ra) # 5c06 <open>
    5062:	00001097          	auipc	ra,0x1
    5066:	b8c080e7          	jalr	-1140(ra) # 5bee <close>
      close(open(file, 0));
    506a:	4581                	li	a1,0
    506c:	fa840513          	addi	a0,s0,-88
    5070:	00001097          	auipc	ra,0x1
    5074:	b96080e7          	jalr	-1130(ra) # 5c06 <open>
    5078:	00001097          	auipc	ra,0x1
    507c:	b76080e7          	jalr	-1162(ra) # 5bee <close>
      close(open(file, 0));
    5080:	4581                	li	a1,0
    5082:	fa840513          	addi	a0,s0,-88
    5086:	00001097          	auipc	ra,0x1
    508a:	b80080e7          	jalr	-1152(ra) # 5c06 <open>
    508e:	00001097          	auipc	ra,0x1
    5092:	b60080e7          	jalr	-1184(ra) # 5bee <close>
      close(open(file, 0));
    5096:	4581                	li	a1,0
    5098:	fa840513          	addi	a0,s0,-88
    509c:	00001097          	auipc	ra,0x1
    50a0:	b6a080e7          	jalr	-1174(ra) # 5c06 <open>
    50a4:	00001097          	auipc	ra,0x1
    50a8:	b4a080e7          	jalr	-1206(ra) # 5bee <close>
    if(pid == 0)
    50ac:	08090363          	beqz	s2,5132 <concreate+0x2d0>
      wait(0);
    50b0:	4501                	li	a0,0
    50b2:	00001097          	auipc	ra,0x1
    50b6:	b1c080e7          	jalr	-1252(ra) # 5bce <wait>
  for(i = 0; i < N; i++){
    50ba:	2485                	addiw	s1,s1,1
    50bc:	0f448563          	beq	s1,s4,51a6 <concreate+0x344>
    file[1] = '0' + i;
    50c0:	0304879b          	addiw	a5,s1,48
    50c4:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    50c8:	00001097          	auipc	ra,0x1
    50cc:	af6080e7          	jalr	-1290(ra) # 5bbe <fork>
    50d0:	892a                	mv	s2,a0
    if(pid < 0){
    50d2:	f2054de3          	bltz	a0,500c <concreate+0x1aa>
    if(((i % 3) == 0 && pid == 0) ||
    50d6:	0354e73b          	remw	a4,s1,s5
    50da:	00a767b3          	or	a5,a4,a0
    50de:	2781                	sext.w	a5,a5
    50e0:	d7a1                	beqz	a5,5028 <concreate+0x1c6>
    50e2:	01671363          	bne	a4,s6,50e8 <concreate+0x286>
       ((i % 3) == 1 && pid != 0)){
    50e6:	f129                	bnez	a0,5028 <concreate+0x1c6>
      unlink(file);
    50e8:	fa840513          	addi	a0,s0,-88
    50ec:	00001097          	auipc	ra,0x1
    50f0:	b2a080e7          	jalr	-1238(ra) # 5c16 <unlink>
      unlink(file);
    50f4:	fa840513          	addi	a0,s0,-88
    50f8:	00001097          	auipc	ra,0x1
    50fc:	b1e080e7          	jalr	-1250(ra) # 5c16 <unlink>
      unlink(file);
    5100:	fa840513          	addi	a0,s0,-88
    5104:	00001097          	auipc	ra,0x1
    5108:	b12080e7          	jalr	-1262(ra) # 5c16 <unlink>
      unlink(file);
    510c:	fa840513          	addi	a0,s0,-88
    5110:	00001097          	auipc	ra,0x1
    5114:	b06080e7          	jalr	-1274(ra) # 5c16 <unlink>
      unlink(file);
    5118:	fa840513          	addi	a0,s0,-88
    511c:	00001097          	auipc	ra,0x1
    5120:	afa080e7          	jalr	-1286(ra) # 5c16 <unlink>
      unlink(file);
    5124:	fa840513          	addi	a0,s0,-88
    5128:	00001097          	auipc	ra,0x1
    512c:	aee080e7          	jalr	-1298(ra) # 5c16 <unlink>
    5130:	bfb5                	j	50ac <concreate+0x24a>
      exit(0);
    5132:	4501                	li	a0,0
    5134:	00001097          	auipc	ra,0x1
    5138:	a92080e7          	jalr	-1390(ra) # 5bc6 <exit>
      close(fd);
    513c:	00001097          	auipc	ra,0x1
    5140:	ab2080e7          	jalr	-1358(ra) # 5bee <close>
    if(pid == 0) {
    5144:	bb65                	j	4efc <concreate+0x9a>
      close(fd);
    5146:	00001097          	auipc	ra,0x1
    514a:	aa8080e7          	jalr	-1368(ra) # 5bee <close>
      wait(&xstatus);
    514e:	f6c40513          	addi	a0,s0,-148
    5152:	00001097          	auipc	ra,0x1
    5156:	a7c080e7          	jalr	-1412(ra) # 5bce <wait>
      if(xstatus != 0)
    515a:	f6c42483          	lw	s1,-148(s0)
    515e:	da0494e3          	bnez	s1,4f06 <concreate+0xa4>
  for(i = 0; i < N; i++){
    5162:	2905                	addiw	s2,s2,1
    5164:	db4906e3          	beq	s2,s4,4f10 <concreate+0xae>
    file[1] = '0' + i;
    5168:	0309079b          	addiw	a5,s2,48
    516c:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    5170:	fa840513          	addi	a0,s0,-88
    5174:	00001097          	auipc	ra,0x1
    5178:	aa2080e7          	jalr	-1374(ra) # 5c16 <unlink>
    pid = fork();
    517c:	00001097          	auipc	ra,0x1
    5180:	a42080e7          	jalr	-1470(ra) # 5bbe <fork>
    if(pid && (i % 3) == 1){
    5184:	d20503e3          	beqz	a0,4eaa <concreate+0x48>
    5188:	036967bb          	remw	a5,s2,s6
    518c:	d15787e3          	beq	a5,s5,4e9a <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    5190:	20200593          	li	a1,514
    5194:	fa840513          	addi	a0,s0,-88
    5198:	00001097          	auipc	ra,0x1
    519c:	a6e080e7          	jalr	-1426(ra) # 5c06 <open>
      if(fd < 0){
    51a0:	fa0553e3          	bgez	a0,5146 <concreate+0x2e4>
    51a4:	b31d                	j	4eca <concreate+0x68>
}
    51a6:	60ea                	ld	ra,152(sp)
    51a8:	644a                	ld	s0,144(sp)
    51aa:	64aa                	ld	s1,136(sp)
    51ac:	690a                	ld	s2,128(sp)
    51ae:	79e6                	ld	s3,120(sp)
    51b0:	7a46                	ld	s4,112(sp)
    51b2:	7aa6                	ld	s5,104(sp)
    51b4:	7b06                	ld	s6,96(sp)
    51b6:	6be6                	ld	s7,88(sp)
    51b8:	610d                	addi	sp,sp,160
    51ba:	8082                	ret

00000000000051bc <bigfile>:
{
    51bc:	7139                	addi	sp,sp,-64
    51be:	fc06                	sd	ra,56(sp)
    51c0:	f822                	sd	s0,48(sp)
    51c2:	f426                	sd	s1,40(sp)
    51c4:	f04a                	sd	s2,32(sp)
    51c6:	ec4e                	sd	s3,24(sp)
    51c8:	e852                	sd	s4,16(sp)
    51ca:	e456                	sd	s5,8(sp)
    51cc:	0080                	addi	s0,sp,64
    51ce:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    51d0:	00003517          	auipc	a0,0x3
    51d4:	d6050513          	addi	a0,a0,-672 # 7f30 <malloc+0x1f2c>
    51d8:	00001097          	auipc	ra,0x1
    51dc:	a3e080e7          	jalr	-1474(ra) # 5c16 <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    51e0:	20200593          	li	a1,514
    51e4:	00003517          	auipc	a0,0x3
    51e8:	d4c50513          	addi	a0,a0,-692 # 7f30 <malloc+0x1f2c>
    51ec:	00001097          	auipc	ra,0x1
    51f0:	a1a080e7          	jalr	-1510(ra) # 5c06 <open>
    51f4:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    51f6:	4481                	li	s1,0
    memset(buf, i, SZ);
    51f8:	00008917          	auipc	s2,0x8
    51fc:	a8090913          	addi	s2,s2,-1408 # cc78 <buf>
  for(i = 0; i < N; i++){
    5200:	4a51                	li	s4,20
  if(fd < 0){
    5202:	0a054063          	bltz	a0,52a2 <bigfile+0xe6>
    memset(buf, i, SZ);
    5206:	25800613          	li	a2,600
    520a:	85a6                	mv	a1,s1
    520c:	854a                	mv	a0,s2
    520e:	00000097          	auipc	ra,0x0
    5212:	7bc080e7          	jalr	1980(ra) # 59ca <memset>
    if(write(fd, buf, SZ) != SZ){
    5216:	25800613          	li	a2,600
    521a:	85ca                	mv	a1,s2
    521c:	854e                	mv	a0,s3
    521e:	00001097          	auipc	ra,0x1
    5222:	9c8080e7          	jalr	-1592(ra) # 5be6 <write>
    5226:	25800793          	li	a5,600
    522a:	08f51a63          	bne	a0,a5,52be <bigfile+0x102>
  for(i = 0; i < N; i++){
    522e:	2485                	addiw	s1,s1,1
    5230:	fd449be3          	bne	s1,s4,5206 <bigfile+0x4a>
  close(fd);
    5234:	854e                	mv	a0,s3
    5236:	00001097          	auipc	ra,0x1
    523a:	9b8080e7          	jalr	-1608(ra) # 5bee <close>
  fd = open("bigfile.dat", 0);
    523e:	4581                	li	a1,0
    5240:	00003517          	auipc	a0,0x3
    5244:	cf050513          	addi	a0,a0,-784 # 7f30 <malloc+0x1f2c>
    5248:	00001097          	auipc	ra,0x1
    524c:	9be080e7          	jalr	-1602(ra) # 5c06 <open>
    5250:	8a2a                	mv	s4,a0
  total = 0;
    5252:	4981                	li	s3,0
  for(i = 0; ; i++){
    5254:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    5256:	00008917          	auipc	s2,0x8
    525a:	a2290913          	addi	s2,s2,-1502 # cc78 <buf>
  if(fd < 0){
    525e:	06054e63          	bltz	a0,52da <bigfile+0x11e>
    cc = read(fd, buf, SZ/2);
    5262:	12c00613          	li	a2,300
    5266:	85ca                	mv	a1,s2
    5268:	8552                	mv	a0,s4
    526a:	00001097          	auipc	ra,0x1
    526e:	974080e7          	jalr	-1676(ra) # 5bde <read>
    if(cc < 0){
    5272:	08054263          	bltz	a0,52f6 <bigfile+0x13a>
    if(cc == 0)
    5276:	c971                	beqz	a0,534a <bigfile+0x18e>
    if(cc != SZ/2){
    5278:	12c00793          	li	a5,300
    527c:	08f51b63          	bne	a0,a5,5312 <bigfile+0x156>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    5280:	01f4d79b          	srliw	a5,s1,0x1f
    5284:	9fa5                	addw	a5,a5,s1
    5286:	4017d79b          	sraiw	a5,a5,0x1
    528a:	00094703          	lbu	a4,0(s2)
    528e:	0af71063          	bne	a4,a5,532e <bigfile+0x172>
    5292:	12b94703          	lbu	a4,299(s2)
    5296:	08f71c63          	bne	a4,a5,532e <bigfile+0x172>
    total += cc;
    529a:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    529e:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    52a0:	b7c9                	j	5262 <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    52a2:	85d6                	mv	a1,s5
    52a4:	00003517          	auipc	a0,0x3
    52a8:	c9c50513          	addi	a0,a0,-868 # 7f40 <malloc+0x1f3c>
    52ac:	00001097          	auipc	ra,0x1
    52b0:	c9a080e7          	jalr	-870(ra) # 5f46 <printf>
    exit(1);
    52b4:	4505                	li	a0,1
    52b6:	00001097          	auipc	ra,0x1
    52ba:	910080e7          	jalr	-1776(ra) # 5bc6 <exit>
      printf("%s: write bigfile failed\n", s);
    52be:	85d6                	mv	a1,s5
    52c0:	00003517          	auipc	a0,0x3
    52c4:	ca050513          	addi	a0,a0,-864 # 7f60 <malloc+0x1f5c>
    52c8:	00001097          	auipc	ra,0x1
    52cc:	c7e080e7          	jalr	-898(ra) # 5f46 <printf>
      exit(1);
    52d0:	4505                	li	a0,1
    52d2:	00001097          	auipc	ra,0x1
    52d6:	8f4080e7          	jalr	-1804(ra) # 5bc6 <exit>
    printf("%s: cannot open bigfile\n", s);
    52da:	85d6                	mv	a1,s5
    52dc:	00003517          	auipc	a0,0x3
    52e0:	ca450513          	addi	a0,a0,-860 # 7f80 <malloc+0x1f7c>
    52e4:	00001097          	auipc	ra,0x1
    52e8:	c62080e7          	jalr	-926(ra) # 5f46 <printf>
    exit(1);
    52ec:	4505                	li	a0,1
    52ee:	00001097          	auipc	ra,0x1
    52f2:	8d8080e7          	jalr	-1832(ra) # 5bc6 <exit>
      printf("%s: read bigfile failed\n", s);
    52f6:	85d6                	mv	a1,s5
    52f8:	00003517          	auipc	a0,0x3
    52fc:	ca850513          	addi	a0,a0,-856 # 7fa0 <malloc+0x1f9c>
    5300:	00001097          	auipc	ra,0x1
    5304:	c46080e7          	jalr	-954(ra) # 5f46 <printf>
      exit(1);
    5308:	4505                	li	a0,1
    530a:	00001097          	auipc	ra,0x1
    530e:	8bc080e7          	jalr	-1860(ra) # 5bc6 <exit>
      printf("%s: short read bigfile\n", s);
    5312:	85d6                	mv	a1,s5
    5314:	00003517          	auipc	a0,0x3
    5318:	cac50513          	addi	a0,a0,-852 # 7fc0 <malloc+0x1fbc>
    531c:	00001097          	auipc	ra,0x1
    5320:	c2a080e7          	jalr	-982(ra) # 5f46 <printf>
      exit(1);
    5324:	4505                	li	a0,1
    5326:	00001097          	auipc	ra,0x1
    532a:	8a0080e7          	jalr	-1888(ra) # 5bc6 <exit>
      printf("%s: read bigfile wrong data\n", s);
    532e:	85d6                	mv	a1,s5
    5330:	00003517          	auipc	a0,0x3
    5334:	ca850513          	addi	a0,a0,-856 # 7fd8 <malloc+0x1fd4>
    5338:	00001097          	auipc	ra,0x1
    533c:	c0e080e7          	jalr	-1010(ra) # 5f46 <printf>
      exit(1);
    5340:	4505                	li	a0,1
    5342:	00001097          	auipc	ra,0x1
    5346:	884080e7          	jalr	-1916(ra) # 5bc6 <exit>
  close(fd);
    534a:	8552                	mv	a0,s4
    534c:	00001097          	auipc	ra,0x1
    5350:	8a2080e7          	jalr	-1886(ra) # 5bee <close>
  if(total != N*SZ){
    5354:	678d                	lui	a5,0x3
    5356:	ee078793          	addi	a5,a5,-288 # 2ee0 <sbrklast+0x88>
    535a:	02f99363          	bne	s3,a5,5380 <bigfile+0x1c4>
  unlink("bigfile.dat");
    535e:	00003517          	auipc	a0,0x3
    5362:	bd250513          	addi	a0,a0,-1070 # 7f30 <malloc+0x1f2c>
    5366:	00001097          	auipc	ra,0x1
    536a:	8b0080e7          	jalr	-1872(ra) # 5c16 <unlink>
}
    536e:	70e2                	ld	ra,56(sp)
    5370:	7442                	ld	s0,48(sp)
    5372:	74a2                	ld	s1,40(sp)
    5374:	7902                	ld	s2,32(sp)
    5376:	69e2                	ld	s3,24(sp)
    5378:	6a42                	ld	s4,16(sp)
    537a:	6aa2                	ld	s5,8(sp)
    537c:	6121                	addi	sp,sp,64
    537e:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    5380:	85d6                	mv	a1,s5
    5382:	00003517          	auipc	a0,0x3
    5386:	c7650513          	addi	a0,a0,-906 # 7ff8 <malloc+0x1ff4>
    538a:	00001097          	auipc	ra,0x1
    538e:	bbc080e7          	jalr	-1092(ra) # 5f46 <printf>
    exit(1);
    5392:	4505                	li	a0,1
    5394:	00001097          	auipc	ra,0x1
    5398:	832080e7          	jalr	-1998(ra) # 5bc6 <exit>

000000000000539c <fsfull>:
{
    539c:	7171                	addi	sp,sp,-176
    539e:	f506                	sd	ra,168(sp)
    53a0:	f122                	sd	s0,160(sp)
    53a2:	ed26                	sd	s1,152(sp)
    53a4:	e94a                	sd	s2,144(sp)
    53a6:	e54e                	sd	s3,136(sp)
    53a8:	e152                	sd	s4,128(sp)
    53aa:	fcd6                	sd	s5,120(sp)
    53ac:	f8da                	sd	s6,112(sp)
    53ae:	f4de                	sd	s7,104(sp)
    53b0:	f0e2                	sd	s8,96(sp)
    53b2:	ece6                	sd	s9,88(sp)
    53b4:	e8ea                	sd	s10,80(sp)
    53b6:	e4ee                	sd	s11,72(sp)
    53b8:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    53ba:	00003517          	auipc	a0,0x3
    53be:	c5e50513          	addi	a0,a0,-930 # 8018 <malloc+0x2014>
    53c2:	00001097          	auipc	ra,0x1
    53c6:	b84080e7          	jalr	-1148(ra) # 5f46 <printf>
  for(nfiles = 0; ; nfiles++){
    53ca:	4481                	li	s1,0
    name[0] = 'f';
    53cc:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    53d0:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    53d4:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    53d8:	4b29                	li	s6,10
    printf("writing %s\n", name);
    53da:	00003c97          	auipc	s9,0x3
    53de:	c4ec8c93          	addi	s9,s9,-946 # 8028 <malloc+0x2024>
    int total = 0;
    53e2:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    53e4:	00008a17          	auipc	s4,0x8
    53e8:	894a0a13          	addi	s4,s4,-1900 # cc78 <buf>
    name[0] = 'f';
    53ec:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    53f0:	0384c7bb          	divw	a5,s1,s8
    53f4:	0307879b          	addiw	a5,a5,48
    53f8:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    53fc:	0384e7bb          	remw	a5,s1,s8
    5400:	0377c7bb          	divw	a5,a5,s7
    5404:	0307879b          	addiw	a5,a5,48
    5408:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    540c:	0374e7bb          	remw	a5,s1,s7
    5410:	0367c7bb          	divw	a5,a5,s6
    5414:	0307879b          	addiw	a5,a5,48
    5418:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    541c:	0364e7bb          	remw	a5,s1,s6
    5420:	0307879b          	addiw	a5,a5,48
    5424:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    5428:	f4040aa3          	sb	zero,-171(s0)
    printf("writing %s\n", name);
    542c:	f5040593          	addi	a1,s0,-176
    5430:	8566                	mv	a0,s9
    5432:	00001097          	auipc	ra,0x1
    5436:	b14080e7          	jalr	-1260(ra) # 5f46 <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    543a:	20200593          	li	a1,514
    543e:	f5040513          	addi	a0,s0,-176
    5442:	00000097          	auipc	ra,0x0
    5446:	7c4080e7          	jalr	1988(ra) # 5c06 <open>
    544a:	892a                	mv	s2,a0
    if(fd < 0){
    544c:	0a055663          	bgez	a0,54f8 <fsfull+0x15c>
      printf("open %s failed\n", name);
    5450:	f5040593          	addi	a1,s0,-176
    5454:	00003517          	auipc	a0,0x3
    5458:	be450513          	addi	a0,a0,-1052 # 8038 <malloc+0x2034>
    545c:	00001097          	auipc	ra,0x1
    5460:	aea080e7          	jalr	-1302(ra) # 5f46 <printf>
  while(nfiles >= 0){
    5464:	0604c363          	bltz	s1,54ca <fsfull+0x12e>
    name[0] = 'f';
    5468:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    546c:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    5470:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    5474:	4929                	li	s2,10
  while(nfiles >= 0){
    5476:	5afd                	li	s5,-1
    name[0] = 'f';
    5478:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    547c:	0344c7bb          	divw	a5,s1,s4
    5480:	0307879b          	addiw	a5,a5,48
    5484:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    5488:	0344e7bb          	remw	a5,s1,s4
    548c:	0337c7bb          	divw	a5,a5,s3
    5490:	0307879b          	addiw	a5,a5,48
    5494:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    5498:	0334e7bb          	remw	a5,s1,s3
    549c:	0327c7bb          	divw	a5,a5,s2
    54a0:	0307879b          	addiw	a5,a5,48
    54a4:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    54a8:	0324e7bb          	remw	a5,s1,s2
    54ac:	0307879b          	addiw	a5,a5,48
    54b0:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    54b4:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    54b8:	f5040513          	addi	a0,s0,-176
    54bc:	00000097          	auipc	ra,0x0
    54c0:	75a080e7          	jalr	1882(ra) # 5c16 <unlink>
    nfiles--;
    54c4:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    54c6:	fb5499e3          	bne	s1,s5,5478 <fsfull+0xdc>
  printf("fsfull test finished\n");
    54ca:	00003517          	auipc	a0,0x3
    54ce:	b8e50513          	addi	a0,a0,-1138 # 8058 <malloc+0x2054>
    54d2:	00001097          	auipc	ra,0x1
    54d6:	a74080e7          	jalr	-1420(ra) # 5f46 <printf>
}
    54da:	70aa                	ld	ra,168(sp)
    54dc:	740a                	ld	s0,160(sp)
    54de:	64ea                	ld	s1,152(sp)
    54e0:	694a                	ld	s2,144(sp)
    54e2:	69aa                	ld	s3,136(sp)
    54e4:	6a0a                	ld	s4,128(sp)
    54e6:	7ae6                	ld	s5,120(sp)
    54e8:	7b46                	ld	s6,112(sp)
    54ea:	7ba6                	ld	s7,104(sp)
    54ec:	7c06                	ld	s8,96(sp)
    54ee:	6ce6                	ld	s9,88(sp)
    54f0:	6d46                	ld	s10,80(sp)
    54f2:	6da6                	ld	s11,72(sp)
    54f4:	614d                	addi	sp,sp,176
    54f6:	8082                	ret
    int total = 0;
    54f8:	89ee                	mv	s3,s11
      if(cc < BSIZE)
    54fa:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    54fe:	40000613          	li	a2,1024
    5502:	85d2                	mv	a1,s4
    5504:	854a                	mv	a0,s2
    5506:	00000097          	auipc	ra,0x0
    550a:	6e0080e7          	jalr	1760(ra) # 5be6 <write>
      if(cc < BSIZE)
    550e:	00aad563          	bge	s5,a0,5518 <fsfull+0x17c>
      total += cc;
    5512:	00a989bb          	addw	s3,s3,a0
    while(1){
    5516:	b7e5                	j	54fe <fsfull+0x162>
    printf("wrote %d bytes\n", total);
    5518:	85ce                	mv	a1,s3
    551a:	00003517          	auipc	a0,0x3
    551e:	b2e50513          	addi	a0,a0,-1234 # 8048 <malloc+0x2044>
    5522:	00001097          	auipc	ra,0x1
    5526:	a24080e7          	jalr	-1500(ra) # 5f46 <printf>
    close(fd);
    552a:	854a                	mv	a0,s2
    552c:	00000097          	auipc	ra,0x0
    5530:	6c2080e7          	jalr	1730(ra) # 5bee <close>
    if(total == 0)
    5534:	f20988e3          	beqz	s3,5464 <fsfull+0xc8>
  for(nfiles = 0; ; nfiles++){
    5538:	2485                	addiw	s1,s1,1
    553a:	bd4d                	j	53ec <fsfull+0x50>

000000000000553c <run>:
//

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    553c:	7179                	addi	sp,sp,-48
    553e:	f406                	sd	ra,40(sp)
    5540:	f022                	sd	s0,32(sp)
    5542:	ec26                	sd	s1,24(sp)
    5544:	e84a                	sd	s2,16(sp)
    5546:	1800                	addi	s0,sp,48
    5548:	84aa                	mv	s1,a0
    554a:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    554c:	00003517          	auipc	a0,0x3
    5550:	b2450513          	addi	a0,a0,-1244 # 8070 <malloc+0x206c>
    5554:	00001097          	auipc	ra,0x1
    5558:	9f2080e7          	jalr	-1550(ra) # 5f46 <printf>
  if((pid = fork()) < 0) {
    555c:	00000097          	auipc	ra,0x0
    5560:	662080e7          	jalr	1634(ra) # 5bbe <fork>
    5564:	02054e63          	bltz	a0,55a0 <run+0x64>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    5568:	c929                	beqz	a0,55ba <run+0x7e>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    556a:	fdc40513          	addi	a0,s0,-36
    556e:	00000097          	auipc	ra,0x0
    5572:	660080e7          	jalr	1632(ra) # 5bce <wait>
    if(xstatus != 0) 
    5576:	fdc42783          	lw	a5,-36(s0)
    557a:	c7b9                	beqz	a5,55c8 <run+0x8c>
      printf("FAILED\n");
    557c:	00003517          	auipc	a0,0x3
    5580:	b1c50513          	addi	a0,a0,-1252 # 8098 <malloc+0x2094>
    5584:	00001097          	auipc	ra,0x1
    5588:	9c2080e7          	jalr	-1598(ra) # 5f46 <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    558c:	fdc42503          	lw	a0,-36(s0)
  }
}
    5590:	00153513          	seqz	a0,a0
    5594:	70a2                	ld	ra,40(sp)
    5596:	7402                	ld	s0,32(sp)
    5598:	64e2                	ld	s1,24(sp)
    559a:	6942                	ld	s2,16(sp)
    559c:	6145                	addi	sp,sp,48
    559e:	8082                	ret
    printf("runtest: fork error\n");
    55a0:	00003517          	auipc	a0,0x3
    55a4:	ae050513          	addi	a0,a0,-1312 # 8080 <malloc+0x207c>
    55a8:	00001097          	auipc	ra,0x1
    55ac:	99e080e7          	jalr	-1634(ra) # 5f46 <printf>
    exit(1);
    55b0:	4505                	li	a0,1
    55b2:	00000097          	auipc	ra,0x0
    55b6:	614080e7          	jalr	1556(ra) # 5bc6 <exit>
    f(s);
    55ba:	854a                	mv	a0,s2
    55bc:	9482                	jalr	s1
    exit(0);
    55be:	4501                	li	a0,0
    55c0:	00000097          	auipc	ra,0x0
    55c4:	606080e7          	jalr	1542(ra) # 5bc6 <exit>
      printf("OK\n");
    55c8:	00003517          	auipc	a0,0x3
    55cc:	ad850513          	addi	a0,a0,-1320 # 80a0 <malloc+0x209c>
    55d0:	00001097          	auipc	ra,0x1
    55d4:	976080e7          	jalr	-1674(ra) # 5f46 <printf>
    55d8:	bf55                	j	558c <run+0x50>

00000000000055da <runtests>:

int
runtests(struct test *tests, char *justone) {
    55da:	1101                	addi	sp,sp,-32
    55dc:	ec06                	sd	ra,24(sp)
    55de:	e822                	sd	s0,16(sp)
    55e0:	e426                	sd	s1,8(sp)
    55e2:	e04a                	sd	s2,0(sp)
    55e4:	1000                	addi	s0,sp,32
    55e6:	84aa                	mv	s1,a0
    55e8:	892e                	mv	s2,a1
  for (struct test *t = tests; t->s != 0; t++) {
    55ea:	6508                	ld	a0,8(a0)
    55ec:	ed09                	bnez	a0,5606 <runtests+0x2c>
        printf("SOME TESTS FAILED\n");
        return 1;
      }
    }
  }
  return 0;
    55ee:	4501                	li	a0,0
    55f0:	a82d                	j	562a <runtests+0x50>
      if(!run(t->f, t->s)){
    55f2:	648c                	ld	a1,8(s1)
    55f4:	6088                	ld	a0,0(s1)
    55f6:	00000097          	auipc	ra,0x0
    55fa:	f46080e7          	jalr	-186(ra) # 553c <run>
    55fe:	cd09                	beqz	a0,5618 <runtests+0x3e>
  for (struct test *t = tests; t->s != 0; t++) {
    5600:	04c1                	addi	s1,s1,16
    5602:	6488                	ld	a0,8(s1)
    5604:	c11d                	beqz	a0,562a <runtests+0x50>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    5606:	fe0906e3          	beqz	s2,55f2 <runtests+0x18>
    560a:	85ca                	mv	a1,s2
    560c:	00000097          	auipc	ra,0x0
    5610:	368080e7          	jalr	872(ra) # 5974 <strcmp>
    5614:	f575                	bnez	a0,5600 <runtests+0x26>
    5616:	bff1                	j	55f2 <runtests+0x18>
        printf("SOME TESTS FAILED\n");
    5618:	00003517          	auipc	a0,0x3
    561c:	a9050513          	addi	a0,a0,-1392 # 80a8 <malloc+0x20a4>
    5620:	00001097          	auipc	ra,0x1
    5624:	926080e7          	jalr	-1754(ra) # 5f46 <printf>
        return 1;
    5628:	4505                	li	a0,1
}
    562a:	60e2                	ld	ra,24(sp)
    562c:	6442                	ld	s0,16(sp)
    562e:	64a2                	ld	s1,8(sp)
    5630:	6902                	ld	s2,0(sp)
    5632:	6105                	addi	sp,sp,32
    5634:	8082                	ret

0000000000005636 <countfree>:
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int
countfree()
{
    5636:	7139                	addi	sp,sp,-64
    5638:	fc06                	sd	ra,56(sp)
    563a:	f822                	sd	s0,48(sp)
    563c:	f426                	sd	s1,40(sp)
    563e:	f04a                	sd	s2,32(sp)
    5640:	ec4e                	sd	s3,24(sp)
    5642:	0080                	addi	s0,sp,64
  int fds[2];

  if(pipe(fds) < 0){
    5644:	fc840513          	addi	a0,s0,-56
    5648:	00000097          	auipc	ra,0x0
    564c:	58e080e7          	jalr	1422(ra) # 5bd6 <pipe>
    5650:	06054763          	bltz	a0,56be <countfree+0x88>
    printf("pipe() failed in countfree()\n");
    exit(1);
  }
  
  int pid = fork();
    5654:	00000097          	auipc	ra,0x0
    5658:	56a080e7          	jalr	1386(ra) # 5bbe <fork>

  if(pid < 0){
    565c:	06054e63          	bltz	a0,56d8 <countfree+0xa2>
    printf("fork failed in countfree()\n");
    exit(1);
  }

  if(pid == 0){
    5660:	ed51                	bnez	a0,56fc <countfree+0xc6>
    close(fds[0]);
    5662:	fc842503          	lw	a0,-56(s0)
    5666:	00000097          	auipc	ra,0x0
    566a:	588080e7          	jalr	1416(ra) # 5bee <close>
    
    while(1){
      uint64 a = (uint64) sbrk(4096);
      if(a == 0xffffffffffffffff){
    566e:	597d                	li	s2,-1
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    5670:	4485                	li	s1,1

      // report back one more page.
      if(write(fds[1], "x", 1) != 1){
    5672:	00001997          	auipc	s3,0x1
    5676:	b4698993          	addi	s3,s3,-1210 # 61b8 <malloc+0x1b4>
      uint64 a = (uint64) sbrk(4096);
    567a:	6505                	lui	a0,0x1
    567c:	00000097          	auipc	ra,0x0
    5680:	5d2080e7          	jalr	1490(ra) # 5c4e <sbrk>
      if(a == 0xffffffffffffffff){
    5684:	07250763          	beq	a0,s2,56f2 <countfree+0xbc>
      *(char *)(a + 4096 - 1) = 1;
    5688:	6785                	lui	a5,0x1
    568a:	953e                	add	a0,a0,a5
    568c:	fe950fa3          	sb	s1,-1(a0) # fff <linktest+0x109>
      if(write(fds[1], "x", 1) != 1){
    5690:	8626                	mv	a2,s1
    5692:	85ce                	mv	a1,s3
    5694:	fcc42503          	lw	a0,-52(s0)
    5698:	00000097          	auipc	ra,0x0
    569c:	54e080e7          	jalr	1358(ra) # 5be6 <write>
    56a0:	fc950de3          	beq	a0,s1,567a <countfree+0x44>
        printf("write() failed in countfree()\n");
    56a4:	00003517          	auipc	a0,0x3
    56a8:	a5c50513          	addi	a0,a0,-1444 # 8100 <malloc+0x20fc>
    56ac:	00001097          	auipc	ra,0x1
    56b0:	89a080e7          	jalr	-1894(ra) # 5f46 <printf>
        exit(1);
    56b4:	4505                	li	a0,1
    56b6:	00000097          	auipc	ra,0x0
    56ba:	510080e7          	jalr	1296(ra) # 5bc6 <exit>
    printf("pipe() failed in countfree()\n");
    56be:	00003517          	auipc	a0,0x3
    56c2:	a0250513          	addi	a0,a0,-1534 # 80c0 <malloc+0x20bc>
    56c6:	00001097          	auipc	ra,0x1
    56ca:	880080e7          	jalr	-1920(ra) # 5f46 <printf>
    exit(1);
    56ce:	4505                	li	a0,1
    56d0:	00000097          	auipc	ra,0x0
    56d4:	4f6080e7          	jalr	1270(ra) # 5bc6 <exit>
    printf("fork failed in countfree()\n");
    56d8:	00003517          	auipc	a0,0x3
    56dc:	a0850513          	addi	a0,a0,-1528 # 80e0 <malloc+0x20dc>
    56e0:	00001097          	auipc	ra,0x1
    56e4:	866080e7          	jalr	-1946(ra) # 5f46 <printf>
    exit(1);
    56e8:	4505                	li	a0,1
    56ea:	00000097          	auipc	ra,0x0
    56ee:	4dc080e7          	jalr	1244(ra) # 5bc6 <exit>
      }
    }

    exit(0);
    56f2:	4501                	li	a0,0
    56f4:	00000097          	auipc	ra,0x0
    56f8:	4d2080e7          	jalr	1234(ra) # 5bc6 <exit>
  }

  close(fds[1]);
    56fc:	fcc42503          	lw	a0,-52(s0)
    5700:	00000097          	auipc	ra,0x0
    5704:	4ee080e7          	jalr	1262(ra) # 5bee <close>

  int n = 0;
    5708:	4481                	li	s1,0
  while(1){
    char c;
    int cc = read(fds[0], &c, 1);
    570a:	4605                	li	a2,1
    570c:	fc740593          	addi	a1,s0,-57
    5710:	fc842503          	lw	a0,-56(s0)
    5714:	00000097          	auipc	ra,0x0
    5718:	4ca080e7          	jalr	1226(ra) # 5bde <read>
    if(cc < 0){
    571c:	00054563          	bltz	a0,5726 <countfree+0xf0>
      printf("read() failed in countfree()\n");
      exit(1);
    }
    if(cc == 0)
    5720:	c105                	beqz	a0,5740 <countfree+0x10a>
      break;
    n += 1;
    5722:	2485                	addiw	s1,s1,1
  while(1){
    5724:	b7dd                	j	570a <countfree+0xd4>
      printf("read() failed in countfree()\n");
    5726:	00003517          	auipc	a0,0x3
    572a:	9fa50513          	addi	a0,a0,-1542 # 8120 <malloc+0x211c>
    572e:	00001097          	auipc	ra,0x1
    5732:	818080e7          	jalr	-2024(ra) # 5f46 <printf>
      exit(1);
    5736:	4505                	li	a0,1
    5738:	00000097          	auipc	ra,0x0
    573c:	48e080e7          	jalr	1166(ra) # 5bc6 <exit>
  }

  close(fds[0]);
    5740:	fc842503          	lw	a0,-56(s0)
    5744:	00000097          	auipc	ra,0x0
    5748:	4aa080e7          	jalr	1194(ra) # 5bee <close>
  wait((int*)0);
    574c:	4501                	li	a0,0
    574e:	00000097          	auipc	ra,0x0
    5752:	480080e7          	jalr	1152(ra) # 5bce <wait>
  
  return n;
}
    5756:	8526                	mv	a0,s1
    5758:	70e2                	ld	ra,56(sp)
    575a:	7442                	ld	s0,48(sp)
    575c:	74a2                	ld	s1,40(sp)
    575e:	7902                	ld	s2,32(sp)
    5760:	69e2                	ld	s3,24(sp)
    5762:	6121                	addi	sp,sp,64
    5764:	8082                	ret

0000000000005766 <drivetests>:

int
drivetests(int quick, int continuous, char *justone) {
    5766:	711d                	addi	sp,sp,-96
    5768:	ec86                	sd	ra,88(sp)
    576a:	e8a2                	sd	s0,80(sp)
    576c:	e4a6                	sd	s1,72(sp)
    576e:	e0ca                	sd	s2,64(sp)
    5770:	fc4e                	sd	s3,56(sp)
    5772:	f852                	sd	s4,48(sp)
    5774:	f456                	sd	s5,40(sp)
    5776:	f05a                	sd	s6,32(sp)
    5778:	ec5e                	sd	s7,24(sp)
    577a:	e862                	sd	s8,16(sp)
    577c:	e466                	sd	s9,8(sp)
    577e:	e06a                	sd	s10,0(sp)
    5780:	1080                	addi	s0,sp,96
    5782:	8a2a                	mv	s4,a0
    5784:	89ae                	mv	s3,a1
    5786:	8932                	mv	s2,a2
  do {
    printf("usertests starting\n");
    5788:	00003b97          	auipc	s7,0x3
    578c:	9b8b8b93          	addi	s7,s7,-1608 # 8140 <malloc+0x213c>
    int free0 = countfree();
    int free1 = 0;
    if (runtests(quicktests, justone)) {
    5790:	00004b17          	auipc	s6,0x4
    5794:	880b0b13          	addi	s6,s6,-1920 # 9010 <quicktests>
      if(continuous != 2) {
    5798:	4a89                	li	s5,2
          return 1;
        }
      }
    }
    if((free1 = countfree()) < free0) {
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    579a:	00003c97          	auipc	s9,0x3
    579e:	9dec8c93          	addi	s9,s9,-1570 # 8178 <malloc+0x2174>
      if (runtests(slowtests, justone)) {
    57a2:	00004c17          	auipc	s8,0x4
    57a6:	c3ec0c13          	addi	s8,s8,-962 # 93e0 <slowtests>
        printf("usertests slow tests starting\n");
    57aa:	00003d17          	auipc	s10,0x3
    57ae:	9aed0d13          	addi	s10,s10,-1618 # 8158 <malloc+0x2154>
    57b2:	a839                	j	57d0 <drivetests+0x6a>
    57b4:	856a                	mv	a0,s10
    57b6:	00000097          	auipc	ra,0x0
    57ba:	790080e7          	jalr	1936(ra) # 5f46 <printf>
    57be:	a081                	j	57fe <drivetests+0x98>
    if((free1 = countfree()) < free0) {
    57c0:	00000097          	auipc	ra,0x0
    57c4:	e76080e7          	jalr	-394(ra) # 5636 <countfree>
    57c8:	06954263          	blt	a0,s1,582c <drivetests+0xc6>
      if(continuous != 2) {
        return 1;
      }
    }
  } while(continuous);
    57cc:	06098f63          	beqz	s3,584a <drivetests+0xe4>
    printf("usertests starting\n");
    57d0:	855e                	mv	a0,s7
    57d2:	00000097          	auipc	ra,0x0
    57d6:	774080e7          	jalr	1908(ra) # 5f46 <printf>
    int free0 = countfree();
    57da:	00000097          	auipc	ra,0x0
    57de:	e5c080e7          	jalr	-420(ra) # 5636 <countfree>
    57e2:	84aa                	mv	s1,a0
    if (runtests(quicktests, justone)) {
    57e4:	85ca                	mv	a1,s2
    57e6:	855a                	mv	a0,s6
    57e8:	00000097          	auipc	ra,0x0
    57ec:	df2080e7          	jalr	-526(ra) # 55da <runtests>
    57f0:	c119                	beqz	a0,57f6 <drivetests+0x90>
      if(continuous != 2) {
    57f2:	05599863          	bne	s3,s5,5842 <drivetests+0xdc>
    if(!quick) {
    57f6:	fc0a15e3          	bnez	s4,57c0 <drivetests+0x5a>
      if (justone == 0)
    57fa:	fa090de3          	beqz	s2,57b4 <drivetests+0x4e>
      if (runtests(slowtests, justone)) {
    57fe:	85ca                	mv	a1,s2
    5800:	8562                	mv	a0,s8
    5802:	00000097          	auipc	ra,0x0
    5806:	dd8080e7          	jalr	-552(ra) # 55da <runtests>
    580a:	d95d                	beqz	a0,57c0 <drivetests+0x5a>
        if(continuous != 2) {
    580c:	03599d63          	bne	s3,s5,5846 <drivetests+0xe0>
    if((free1 = countfree()) < free0) {
    5810:	00000097          	auipc	ra,0x0
    5814:	e26080e7          	jalr	-474(ra) # 5636 <countfree>
    5818:	fa955ae3          	bge	a0,s1,57cc <drivetests+0x66>
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    581c:	8626                	mv	a2,s1
    581e:	85aa                	mv	a1,a0
    5820:	8566                	mv	a0,s9
    5822:	00000097          	auipc	ra,0x0
    5826:	724080e7          	jalr	1828(ra) # 5f46 <printf>
      if(continuous != 2) {
    582a:	b75d                	j	57d0 <drivetests+0x6a>
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    582c:	8626                	mv	a2,s1
    582e:	85aa                	mv	a1,a0
    5830:	8566                	mv	a0,s9
    5832:	00000097          	auipc	ra,0x0
    5836:	714080e7          	jalr	1812(ra) # 5f46 <printf>
      if(continuous != 2) {
    583a:	f9598be3          	beq	s3,s5,57d0 <drivetests+0x6a>
        return 1;
    583e:	4505                	li	a0,1
    5840:	a031                	j	584c <drivetests+0xe6>
        return 1;
    5842:	4505                	li	a0,1
    5844:	a021                	j	584c <drivetests+0xe6>
          return 1;
    5846:	4505                	li	a0,1
    5848:	a011                	j	584c <drivetests+0xe6>
  return 0;
    584a:	854e                	mv	a0,s3
}
    584c:	60e6                	ld	ra,88(sp)
    584e:	6446                	ld	s0,80(sp)
    5850:	64a6                	ld	s1,72(sp)
    5852:	6906                	ld	s2,64(sp)
    5854:	79e2                	ld	s3,56(sp)
    5856:	7a42                	ld	s4,48(sp)
    5858:	7aa2                	ld	s5,40(sp)
    585a:	7b02                	ld	s6,32(sp)
    585c:	6be2                	ld	s7,24(sp)
    585e:	6c42                	ld	s8,16(sp)
    5860:	6ca2                	ld	s9,8(sp)
    5862:	6d02                	ld	s10,0(sp)
    5864:	6125                	addi	sp,sp,96
    5866:	8082                	ret

0000000000005868 <main>:

int
main(int argc, char *argv[])
{
    5868:	1101                	addi	sp,sp,-32
    586a:	ec06                	sd	ra,24(sp)
    586c:	e822                	sd	s0,16(sp)
    586e:	e426                	sd	s1,8(sp)
    5870:	e04a                	sd	s2,0(sp)
    5872:	1000                	addi	s0,sp,32
    5874:	84aa                	mv	s1,a0
  int continuous = 0;
  int quick = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-q") == 0){
    5876:	4789                	li	a5,2
    5878:	02f50363          	beq	a0,a5,589e <main+0x36>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    587c:	4785                	li	a5,1
    587e:	06a7cd63          	blt	a5,a0,58f8 <main+0x90>
  char *justone = 0;
    5882:	4601                	li	a2,0
  int quick = 0;
    5884:	4501                	li	a0,0
  int continuous = 0;
    5886:	4481                	li	s1,0
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    exit(1);
  }
  if (drivetests(quick, continuous, justone)) {
    5888:	85a6                	mv	a1,s1
    588a:	00000097          	auipc	ra,0x0
    588e:	edc080e7          	jalr	-292(ra) # 5766 <drivetests>
    5892:	c949                	beqz	a0,5924 <main+0xbc>
    exit(1);
    5894:	4505                	li	a0,1
    5896:	00000097          	auipc	ra,0x0
    589a:	330080e7          	jalr	816(ra) # 5bc6 <exit>
    589e:	892e                	mv	s2,a1
  if(argc == 2 && strcmp(argv[1], "-q") == 0){
    58a0:	00003597          	auipc	a1,0x3
    58a4:	90858593          	addi	a1,a1,-1784 # 81a8 <malloc+0x21a4>
    58a8:	00893503          	ld	a0,8(s2)
    58ac:	00000097          	auipc	ra,0x0
    58b0:	0c8080e7          	jalr	200(ra) # 5974 <strcmp>
    58b4:	cd39                	beqz	a0,5912 <main+0xaa>
  } else if(argc == 2 && strcmp(argv[1], "-c") == 0){
    58b6:	00003597          	auipc	a1,0x3
    58ba:	94a58593          	addi	a1,a1,-1718 # 8200 <malloc+0x21fc>
    58be:	00893503          	ld	a0,8(s2)
    58c2:	00000097          	auipc	ra,0x0
    58c6:	0b2080e7          	jalr	178(ra) # 5974 <strcmp>
    58ca:	c931                	beqz	a0,591e <main+0xb6>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    58cc:	00003597          	auipc	a1,0x3
    58d0:	92c58593          	addi	a1,a1,-1748 # 81f8 <malloc+0x21f4>
    58d4:	00893503          	ld	a0,8(s2)
    58d8:	00000097          	auipc	ra,0x0
    58dc:	09c080e7          	jalr	156(ra) # 5974 <strcmp>
    58e0:	cd0d                	beqz	a0,591a <main+0xb2>
  } else if(argc == 2 && argv[1][0] != '-'){
    58e2:	00893603          	ld	a2,8(s2)
    58e6:	00064703          	lbu	a4,0(a2) # 3000 <execout+0xa0>
    58ea:	02d00793          	li	a5,45
    58ee:	00f70563          	beq	a4,a5,58f8 <main+0x90>
  int quick = 0;
    58f2:	4501                	li	a0,0
  int continuous = 0;
    58f4:	4481                	li	s1,0
    58f6:	bf49                	j	5888 <main+0x20>
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    58f8:	00003517          	auipc	a0,0x3
    58fc:	8b850513          	addi	a0,a0,-1864 # 81b0 <malloc+0x21ac>
    5900:	00000097          	auipc	ra,0x0
    5904:	646080e7          	jalr	1606(ra) # 5f46 <printf>
    exit(1);
    5908:	4505                	li	a0,1
    590a:	00000097          	auipc	ra,0x0
    590e:	2bc080e7          	jalr	700(ra) # 5bc6 <exit>
  int continuous = 0;
    5912:	84aa                	mv	s1,a0
  char *justone = 0;
    5914:	4601                	li	a2,0
    quick = 1;
    5916:	4505                	li	a0,1
    5918:	bf85                	j	5888 <main+0x20>
  char *justone = 0;
    591a:	4601                	li	a2,0
    591c:	b7b5                	j	5888 <main+0x20>
    591e:	4601                	li	a2,0
    continuous = 1;
    5920:	4485                	li	s1,1
    5922:	b79d                	j	5888 <main+0x20>
  }
  printf("ALL TESTS PASSED\n");
    5924:	00003517          	auipc	a0,0x3
    5928:	8bc50513          	addi	a0,a0,-1860 # 81e0 <malloc+0x21dc>
    592c:	00000097          	auipc	ra,0x0
    5930:	61a080e7          	jalr	1562(ra) # 5f46 <printf>
  exit(0);
    5934:	4501                	li	a0,0
    5936:	00000097          	auipc	ra,0x0
    593a:	290080e7          	jalr	656(ra) # 5bc6 <exit>

000000000000593e <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
    593e:	1141                	addi	sp,sp,-16
    5940:	e406                	sd	ra,8(sp)
    5942:	e022                	sd	s0,0(sp)
    5944:	0800                	addi	s0,sp,16
  extern int main();
  main();
    5946:	00000097          	auipc	ra,0x0
    594a:	f22080e7          	jalr	-222(ra) # 5868 <main>
  exit(0);
    594e:	4501                	li	a0,0
    5950:	00000097          	auipc	ra,0x0
    5954:	276080e7          	jalr	630(ra) # 5bc6 <exit>

0000000000005958 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
    5958:	1141                	addi	sp,sp,-16
    595a:	e422                	sd	s0,8(sp)
    595c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    595e:	87aa                	mv	a5,a0
    5960:	0585                	addi	a1,a1,1
    5962:	0785                	addi	a5,a5,1
    5964:	fff5c703          	lbu	a4,-1(a1)
    5968:	fee78fa3          	sb	a4,-1(a5) # fff <linktest+0x109>
    596c:	fb75                	bnez	a4,5960 <strcpy+0x8>
    ;
  return os;
}
    596e:	6422                	ld	s0,8(sp)
    5970:	0141                	addi	sp,sp,16
    5972:	8082                	ret

0000000000005974 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    5974:	1141                	addi	sp,sp,-16
    5976:	e422                	sd	s0,8(sp)
    5978:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    597a:	00054783          	lbu	a5,0(a0)
    597e:	cb91                	beqz	a5,5992 <strcmp+0x1e>
    5980:	0005c703          	lbu	a4,0(a1)
    5984:	00f71763          	bne	a4,a5,5992 <strcmp+0x1e>
    p++, q++;
    5988:	0505                	addi	a0,a0,1
    598a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    598c:	00054783          	lbu	a5,0(a0)
    5990:	fbe5                	bnez	a5,5980 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    5992:	0005c503          	lbu	a0,0(a1)
}
    5996:	40a7853b          	subw	a0,a5,a0
    599a:	6422                	ld	s0,8(sp)
    599c:	0141                	addi	sp,sp,16
    599e:	8082                	ret

00000000000059a0 <strlen>:

uint
strlen(const char *s)
{
    59a0:	1141                	addi	sp,sp,-16
    59a2:	e422                	sd	s0,8(sp)
    59a4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    59a6:	00054783          	lbu	a5,0(a0)
    59aa:	cf91                	beqz	a5,59c6 <strlen+0x26>
    59ac:	0505                	addi	a0,a0,1
    59ae:	87aa                	mv	a5,a0
    59b0:	4685                	li	a3,1
    59b2:	9e89                	subw	a3,a3,a0
    59b4:	00f6853b          	addw	a0,a3,a5
    59b8:	0785                	addi	a5,a5,1
    59ba:	fff7c703          	lbu	a4,-1(a5)
    59be:	fb7d                	bnez	a4,59b4 <strlen+0x14>
    ;
  return n;
}
    59c0:	6422                	ld	s0,8(sp)
    59c2:	0141                	addi	sp,sp,16
    59c4:	8082                	ret
  for(n = 0; s[n]; n++)
    59c6:	4501                	li	a0,0
    59c8:	bfe5                	j	59c0 <strlen+0x20>

00000000000059ca <memset>:

void*
memset(void *dst, int c, uint n)
{
    59ca:	1141                	addi	sp,sp,-16
    59cc:	e422                	sd	s0,8(sp)
    59ce:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    59d0:	ca19                	beqz	a2,59e6 <memset+0x1c>
    59d2:	87aa                	mv	a5,a0
    59d4:	1602                	slli	a2,a2,0x20
    59d6:	9201                	srli	a2,a2,0x20
    59d8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    59dc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    59e0:	0785                	addi	a5,a5,1
    59e2:	fee79de3          	bne	a5,a4,59dc <memset+0x12>
  }
  return dst;
}
    59e6:	6422                	ld	s0,8(sp)
    59e8:	0141                	addi	sp,sp,16
    59ea:	8082                	ret

00000000000059ec <strchr>:

char*
strchr(const char *s, char c)
{
    59ec:	1141                	addi	sp,sp,-16
    59ee:	e422                	sd	s0,8(sp)
    59f0:	0800                	addi	s0,sp,16
  for(; *s; s++)
    59f2:	00054783          	lbu	a5,0(a0)
    59f6:	cb99                	beqz	a5,5a0c <strchr+0x20>
    if(*s == c)
    59f8:	00f58763          	beq	a1,a5,5a06 <strchr+0x1a>
  for(; *s; s++)
    59fc:	0505                	addi	a0,a0,1
    59fe:	00054783          	lbu	a5,0(a0)
    5a02:	fbfd                	bnez	a5,59f8 <strchr+0xc>
      return (char*)s;
  return 0;
    5a04:	4501                	li	a0,0
}
    5a06:	6422                	ld	s0,8(sp)
    5a08:	0141                	addi	sp,sp,16
    5a0a:	8082                	ret
  return 0;
    5a0c:	4501                	li	a0,0
    5a0e:	bfe5                	j	5a06 <strchr+0x1a>

0000000000005a10 <gets>:

char*
gets(char *buf, int max)
{
    5a10:	711d                	addi	sp,sp,-96
    5a12:	ec86                	sd	ra,88(sp)
    5a14:	e8a2                	sd	s0,80(sp)
    5a16:	e4a6                	sd	s1,72(sp)
    5a18:	e0ca                	sd	s2,64(sp)
    5a1a:	fc4e                	sd	s3,56(sp)
    5a1c:	f852                	sd	s4,48(sp)
    5a1e:	f456                	sd	s5,40(sp)
    5a20:	f05a                	sd	s6,32(sp)
    5a22:	ec5e                	sd	s7,24(sp)
    5a24:	1080                	addi	s0,sp,96
    5a26:	8baa                	mv	s7,a0
    5a28:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    5a2a:	892a                	mv	s2,a0
    5a2c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    5a2e:	4aa9                	li	s5,10
    5a30:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    5a32:	89a6                	mv	s3,s1
    5a34:	2485                	addiw	s1,s1,1
    5a36:	0344d863          	bge	s1,s4,5a66 <gets+0x56>
    cc = read(0, &c, 1);
    5a3a:	4605                	li	a2,1
    5a3c:	faf40593          	addi	a1,s0,-81
    5a40:	4501                	li	a0,0
    5a42:	00000097          	auipc	ra,0x0
    5a46:	19c080e7          	jalr	412(ra) # 5bde <read>
    if(cc < 1)
    5a4a:	00a05e63          	blez	a0,5a66 <gets+0x56>
    buf[i++] = c;
    5a4e:	faf44783          	lbu	a5,-81(s0)
    5a52:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    5a56:	01578763          	beq	a5,s5,5a64 <gets+0x54>
    5a5a:	0905                	addi	s2,s2,1
    5a5c:	fd679be3          	bne	a5,s6,5a32 <gets+0x22>
  for(i=0; i+1 < max; ){
    5a60:	89a6                	mv	s3,s1
    5a62:	a011                	j	5a66 <gets+0x56>
    5a64:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    5a66:	99de                	add	s3,s3,s7
    5a68:	00098023          	sb	zero,0(s3)
  return buf;
}
    5a6c:	855e                	mv	a0,s7
    5a6e:	60e6                	ld	ra,88(sp)
    5a70:	6446                	ld	s0,80(sp)
    5a72:	64a6                	ld	s1,72(sp)
    5a74:	6906                	ld	s2,64(sp)
    5a76:	79e2                	ld	s3,56(sp)
    5a78:	7a42                	ld	s4,48(sp)
    5a7a:	7aa2                	ld	s5,40(sp)
    5a7c:	7b02                	ld	s6,32(sp)
    5a7e:	6be2                	ld	s7,24(sp)
    5a80:	6125                	addi	sp,sp,96
    5a82:	8082                	ret

0000000000005a84 <stat>:

int
stat(const char *n, struct stat *st)
{
    5a84:	1101                	addi	sp,sp,-32
    5a86:	ec06                	sd	ra,24(sp)
    5a88:	e822                	sd	s0,16(sp)
    5a8a:	e426                	sd	s1,8(sp)
    5a8c:	e04a                	sd	s2,0(sp)
    5a8e:	1000                	addi	s0,sp,32
    5a90:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    5a92:	4581                	li	a1,0
    5a94:	00000097          	auipc	ra,0x0
    5a98:	172080e7          	jalr	370(ra) # 5c06 <open>
  if(fd < 0)
    5a9c:	02054563          	bltz	a0,5ac6 <stat+0x42>
    5aa0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    5aa2:	85ca                	mv	a1,s2
    5aa4:	00000097          	auipc	ra,0x0
    5aa8:	17a080e7          	jalr	378(ra) # 5c1e <fstat>
    5aac:	892a                	mv	s2,a0
  close(fd);
    5aae:	8526                	mv	a0,s1
    5ab0:	00000097          	auipc	ra,0x0
    5ab4:	13e080e7          	jalr	318(ra) # 5bee <close>
  return r;
}
    5ab8:	854a                	mv	a0,s2
    5aba:	60e2                	ld	ra,24(sp)
    5abc:	6442                	ld	s0,16(sp)
    5abe:	64a2                	ld	s1,8(sp)
    5ac0:	6902                	ld	s2,0(sp)
    5ac2:	6105                	addi	sp,sp,32
    5ac4:	8082                	ret
    return -1;
    5ac6:	597d                	li	s2,-1
    5ac8:	bfc5                	j	5ab8 <stat+0x34>

0000000000005aca <atoi>:

int
atoi(const char *s)
{
    5aca:	1141                	addi	sp,sp,-16
    5acc:	e422                	sd	s0,8(sp)
    5ace:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    5ad0:	00054603          	lbu	a2,0(a0)
    5ad4:	fd06079b          	addiw	a5,a2,-48
    5ad8:	0ff7f793          	andi	a5,a5,255
    5adc:	4725                	li	a4,9
    5ade:	02f76963          	bltu	a4,a5,5b10 <atoi+0x46>
    5ae2:	86aa                	mv	a3,a0
  n = 0;
    5ae4:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    5ae6:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    5ae8:	0685                	addi	a3,a3,1
    5aea:	0025179b          	slliw	a5,a0,0x2
    5aee:	9fa9                	addw	a5,a5,a0
    5af0:	0017979b          	slliw	a5,a5,0x1
    5af4:	9fb1                	addw	a5,a5,a2
    5af6:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    5afa:	0006c603          	lbu	a2,0(a3)
    5afe:	fd06071b          	addiw	a4,a2,-48
    5b02:	0ff77713          	andi	a4,a4,255
    5b06:	fee5f1e3          	bgeu	a1,a4,5ae8 <atoi+0x1e>
  return n;
}
    5b0a:	6422                	ld	s0,8(sp)
    5b0c:	0141                	addi	sp,sp,16
    5b0e:	8082                	ret
  n = 0;
    5b10:	4501                	li	a0,0
    5b12:	bfe5                	j	5b0a <atoi+0x40>

0000000000005b14 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    5b14:	1141                	addi	sp,sp,-16
    5b16:	e422                	sd	s0,8(sp)
    5b18:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    5b1a:	02b57463          	bgeu	a0,a1,5b42 <memmove+0x2e>
    while(n-- > 0)
    5b1e:	00c05f63          	blez	a2,5b3c <memmove+0x28>
    5b22:	1602                	slli	a2,a2,0x20
    5b24:	9201                	srli	a2,a2,0x20
    5b26:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    5b2a:	872a                	mv	a4,a0
      *dst++ = *src++;
    5b2c:	0585                	addi	a1,a1,1
    5b2e:	0705                	addi	a4,a4,1
    5b30:	fff5c683          	lbu	a3,-1(a1)
    5b34:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    5b38:	fee79ae3          	bne	a5,a4,5b2c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    5b3c:	6422                	ld	s0,8(sp)
    5b3e:	0141                	addi	sp,sp,16
    5b40:	8082                	ret
    dst += n;
    5b42:	00c50733          	add	a4,a0,a2
    src += n;
    5b46:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    5b48:	fec05ae3          	blez	a2,5b3c <memmove+0x28>
    5b4c:	fff6079b          	addiw	a5,a2,-1
    5b50:	1782                	slli	a5,a5,0x20
    5b52:	9381                	srli	a5,a5,0x20
    5b54:	fff7c793          	not	a5,a5
    5b58:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    5b5a:	15fd                	addi	a1,a1,-1
    5b5c:	177d                	addi	a4,a4,-1
    5b5e:	0005c683          	lbu	a3,0(a1)
    5b62:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    5b66:	fee79ae3          	bne	a5,a4,5b5a <memmove+0x46>
    5b6a:	bfc9                	j	5b3c <memmove+0x28>

0000000000005b6c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    5b6c:	1141                	addi	sp,sp,-16
    5b6e:	e422                	sd	s0,8(sp)
    5b70:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    5b72:	ca05                	beqz	a2,5ba2 <memcmp+0x36>
    5b74:	fff6069b          	addiw	a3,a2,-1
    5b78:	1682                	slli	a3,a3,0x20
    5b7a:	9281                	srli	a3,a3,0x20
    5b7c:	0685                	addi	a3,a3,1
    5b7e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    5b80:	00054783          	lbu	a5,0(a0)
    5b84:	0005c703          	lbu	a4,0(a1)
    5b88:	00e79863          	bne	a5,a4,5b98 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    5b8c:	0505                	addi	a0,a0,1
    p2++;
    5b8e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    5b90:	fed518e3          	bne	a0,a3,5b80 <memcmp+0x14>
  }
  return 0;
    5b94:	4501                	li	a0,0
    5b96:	a019                	j	5b9c <memcmp+0x30>
      return *p1 - *p2;
    5b98:	40e7853b          	subw	a0,a5,a4
}
    5b9c:	6422                	ld	s0,8(sp)
    5b9e:	0141                	addi	sp,sp,16
    5ba0:	8082                	ret
  return 0;
    5ba2:	4501                	li	a0,0
    5ba4:	bfe5                	j	5b9c <memcmp+0x30>

0000000000005ba6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    5ba6:	1141                	addi	sp,sp,-16
    5ba8:	e406                	sd	ra,8(sp)
    5baa:	e022                	sd	s0,0(sp)
    5bac:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    5bae:	00000097          	auipc	ra,0x0
    5bb2:	f66080e7          	jalr	-154(ra) # 5b14 <memmove>
}
    5bb6:	60a2                	ld	ra,8(sp)
    5bb8:	6402                	ld	s0,0(sp)
    5bba:	0141                	addi	sp,sp,16
    5bbc:	8082                	ret

0000000000005bbe <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    5bbe:	4885                	li	a7,1
 ecall
    5bc0:	00000073          	ecall
 ret
    5bc4:	8082                	ret

0000000000005bc6 <exit>:
.global exit
exit:
 li a7, SYS_exit
    5bc6:	4889                	li	a7,2
 ecall
    5bc8:	00000073          	ecall
 ret
    5bcc:	8082                	ret

0000000000005bce <wait>:
.global wait
wait:
 li a7, SYS_wait
    5bce:	488d                	li	a7,3
 ecall
    5bd0:	00000073          	ecall
 ret
    5bd4:	8082                	ret

0000000000005bd6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    5bd6:	4891                	li	a7,4
 ecall
    5bd8:	00000073          	ecall
 ret
    5bdc:	8082                	ret

0000000000005bde <read>:
.global read
read:
 li a7, SYS_read
    5bde:	4895                	li	a7,5
 ecall
    5be0:	00000073          	ecall
 ret
    5be4:	8082                	ret

0000000000005be6 <write>:
.global write
write:
 li a7, SYS_write
    5be6:	48c1                	li	a7,16
 ecall
    5be8:	00000073          	ecall
 ret
    5bec:	8082                	ret

0000000000005bee <close>:
.global close
close:
 li a7, SYS_close
    5bee:	48d5                	li	a7,21
 ecall
    5bf0:	00000073          	ecall
 ret
    5bf4:	8082                	ret

0000000000005bf6 <kill>:
.global kill
kill:
 li a7, SYS_kill
    5bf6:	4899                	li	a7,6
 ecall
    5bf8:	00000073          	ecall
 ret
    5bfc:	8082                	ret

0000000000005bfe <exec>:
.global exec
exec:
 li a7, SYS_exec
    5bfe:	489d                	li	a7,7
 ecall
    5c00:	00000073          	ecall
 ret
    5c04:	8082                	ret

0000000000005c06 <open>:
.global open
open:
 li a7, SYS_open
    5c06:	48bd                	li	a7,15
 ecall
    5c08:	00000073          	ecall
 ret
    5c0c:	8082                	ret

0000000000005c0e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    5c0e:	48c5                	li	a7,17
 ecall
    5c10:	00000073          	ecall
 ret
    5c14:	8082                	ret

0000000000005c16 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    5c16:	48c9                	li	a7,18
 ecall
    5c18:	00000073          	ecall
 ret
    5c1c:	8082                	ret

0000000000005c1e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    5c1e:	48a1                	li	a7,8
 ecall
    5c20:	00000073          	ecall
 ret
    5c24:	8082                	ret

0000000000005c26 <link>:
.global link
link:
 li a7, SYS_link
    5c26:	48cd                	li	a7,19
 ecall
    5c28:	00000073          	ecall
 ret
    5c2c:	8082                	ret

0000000000005c2e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    5c2e:	48d1                	li	a7,20
 ecall
    5c30:	00000073          	ecall
 ret
    5c34:	8082                	ret

0000000000005c36 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    5c36:	48a5                	li	a7,9
 ecall
    5c38:	00000073          	ecall
 ret
    5c3c:	8082                	ret

0000000000005c3e <dup>:
.global dup
dup:
 li a7, SYS_dup
    5c3e:	48a9                	li	a7,10
 ecall
    5c40:	00000073          	ecall
 ret
    5c44:	8082                	ret

0000000000005c46 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    5c46:	48ad                	li	a7,11
 ecall
    5c48:	00000073          	ecall
 ret
    5c4c:	8082                	ret

0000000000005c4e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    5c4e:	48b1                	li	a7,12
 ecall
    5c50:	00000073          	ecall
 ret
    5c54:	8082                	ret

0000000000005c56 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    5c56:	48b5                	li	a7,13
 ecall
    5c58:	00000073          	ecall
 ret
    5c5c:	8082                	ret

0000000000005c5e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    5c5e:	48b9                	li	a7,14
 ecall
    5c60:	00000073          	ecall
 ret
    5c64:	8082                	ret

0000000000005c66 <trace>:
.global trace
trace:
 li a7, SYS_trace
    5c66:	48d9                	li	a7,22
 ecall
    5c68:	00000073          	ecall
 ret
    5c6c:	8082                	ret

0000000000005c6e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    5c6e:	1101                	addi	sp,sp,-32
    5c70:	ec06                	sd	ra,24(sp)
    5c72:	e822                	sd	s0,16(sp)
    5c74:	1000                	addi	s0,sp,32
    5c76:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    5c7a:	4605                	li	a2,1
    5c7c:	fef40593          	addi	a1,s0,-17
    5c80:	00000097          	auipc	ra,0x0
    5c84:	f66080e7          	jalr	-154(ra) # 5be6 <write>
}
    5c88:	60e2                	ld	ra,24(sp)
    5c8a:	6442                	ld	s0,16(sp)
    5c8c:	6105                	addi	sp,sp,32
    5c8e:	8082                	ret

0000000000005c90 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    5c90:	7139                	addi	sp,sp,-64
    5c92:	fc06                	sd	ra,56(sp)
    5c94:	f822                	sd	s0,48(sp)
    5c96:	f426                	sd	s1,40(sp)
    5c98:	f04a                	sd	s2,32(sp)
    5c9a:	ec4e                	sd	s3,24(sp)
    5c9c:	0080                	addi	s0,sp,64
    5c9e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    5ca0:	c299                	beqz	a3,5ca6 <printint+0x16>
    5ca2:	0805c863          	bltz	a1,5d32 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    5ca6:	2581                	sext.w	a1,a1
  neg = 0;
    5ca8:	4881                	li	a7,0
    5caa:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    5cae:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    5cb0:	2601                	sext.w	a2,a2
    5cb2:	00003517          	auipc	a0,0x3
    5cb6:	8be50513          	addi	a0,a0,-1858 # 8570 <digits>
    5cba:	883a                	mv	a6,a4
    5cbc:	2705                	addiw	a4,a4,1
    5cbe:	02c5f7bb          	remuw	a5,a1,a2
    5cc2:	1782                	slli	a5,a5,0x20
    5cc4:	9381                	srli	a5,a5,0x20
    5cc6:	97aa                	add	a5,a5,a0
    5cc8:	0007c783          	lbu	a5,0(a5)
    5ccc:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    5cd0:	0005879b          	sext.w	a5,a1
    5cd4:	02c5d5bb          	divuw	a1,a1,a2
    5cd8:	0685                	addi	a3,a3,1
    5cda:	fec7f0e3          	bgeu	a5,a2,5cba <printint+0x2a>
  if(neg)
    5cde:	00088b63          	beqz	a7,5cf4 <printint+0x64>
    buf[i++] = '-';
    5ce2:	fd040793          	addi	a5,s0,-48
    5ce6:	973e                	add	a4,a4,a5
    5ce8:	02d00793          	li	a5,45
    5cec:	fef70823          	sb	a5,-16(a4)
    5cf0:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    5cf4:	02e05863          	blez	a4,5d24 <printint+0x94>
    5cf8:	fc040793          	addi	a5,s0,-64
    5cfc:	00e78933          	add	s2,a5,a4
    5d00:	fff78993          	addi	s3,a5,-1
    5d04:	99ba                	add	s3,s3,a4
    5d06:	377d                	addiw	a4,a4,-1
    5d08:	1702                	slli	a4,a4,0x20
    5d0a:	9301                	srli	a4,a4,0x20
    5d0c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    5d10:	fff94583          	lbu	a1,-1(s2)
    5d14:	8526                	mv	a0,s1
    5d16:	00000097          	auipc	ra,0x0
    5d1a:	f58080e7          	jalr	-168(ra) # 5c6e <putc>
  while(--i >= 0)
    5d1e:	197d                	addi	s2,s2,-1
    5d20:	ff3918e3          	bne	s2,s3,5d10 <printint+0x80>
}
    5d24:	70e2                	ld	ra,56(sp)
    5d26:	7442                	ld	s0,48(sp)
    5d28:	74a2                	ld	s1,40(sp)
    5d2a:	7902                	ld	s2,32(sp)
    5d2c:	69e2                	ld	s3,24(sp)
    5d2e:	6121                	addi	sp,sp,64
    5d30:	8082                	ret
    x = -xx;
    5d32:	40b005bb          	negw	a1,a1
    neg = 1;
    5d36:	4885                	li	a7,1
    x = -xx;
    5d38:	bf8d                	j	5caa <printint+0x1a>

0000000000005d3a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    5d3a:	7119                	addi	sp,sp,-128
    5d3c:	fc86                	sd	ra,120(sp)
    5d3e:	f8a2                	sd	s0,112(sp)
    5d40:	f4a6                	sd	s1,104(sp)
    5d42:	f0ca                	sd	s2,96(sp)
    5d44:	ecce                	sd	s3,88(sp)
    5d46:	e8d2                	sd	s4,80(sp)
    5d48:	e4d6                	sd	s5,72(sp)
    5d4a:	e0da                	sd	s6,64(sp)
    5d4c:	fc5e                	sd	s7,56(sp)
    5d4e:	f862                	sd	s8,48(sp)
    5d50:	f466                	sd	s9,40(sp)
    5d52:	f06a                	sd	s10,32(sp)
    5d54:	ec6e                	sd	s11,24(sp)
    5d56:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    5d58:	0005c903          	lbu	s2,0(a1)
    5d5c:	18090f63          	beqz	s2,5efa <vprintf+0x1c0>
    5d60:	8aaa                	mv	s5,a0
    5d62:	8b32                	mv	s6,a2
    5d64:	00158493          	addi	s1,a1,1
  state = 0;
    5d68:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    5d6a:	02500a13          	li	s4,37
      if(c == 'd'){
    5d6e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    5d72:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    5d76:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    5d7a:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5d7e:	00002b97          	auipc	s7,0x2
    5d82:	7f2b8b93          	addi	s7,s7,2034 # 8570 <digits>
    5d86:	a839                	j	5da4 <vprintf+0x6a>
        putc(fd, c);
    5d88:	85ca                	mv	a1,s2
    5d8a:	8556                	mv	a0,s5
    5d8c:	00000097          	auipc	ra,0x0
    5d90:	ee2080e7          	jalr	-286(ra) # 5c6e <putc>
    5d94:	a019                	j	5d9a <vprintf+0x60>
    } else if(state == '%'){
    5d96:	01498f63          	beq	s3,s4,5db4 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    5d9a:	0485                	addi	s1,s1,1
    5d9c:	fff4c903          	lbu	s2,-1(s1)
    5da0:	14090d63          	beqz	s2,5efa <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    5da4:	0009079b          	sext.w	a5,s2
    if(state == 0){
    5da8:	fe0997e3          	bnez	s3,5d96 <vprintf+0x5c>
      if(c == '%'){
    5dac:	fd479ee3          	bne	a5,s4,5d88 <vprintf+0x4e>
        state = '%';
    5db0:	89be                	mv	s3,a5
    5db2:	b7e5                	j	5d9a <vprintf+0x60>
      if(c == 'd'){
    5db4:	05878063          	beq	a5,s8,5df4 <vprintf+0xba>
      } else if(c == 'l') {
    5db8:	05978c63          	beq	a5,s9,5e10 <vprintf+0xd6>
      } else if(c == 'x') {
    5dbc:	07a78863          	beq	a5,s10,5e2c <vprintf+0xf2>
      } else if(c == 'p') {
    5dc0:	09b78463          	beq	a5,s11,5e48 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    5dc4:	07300713          	li	a4,115
    5dc8:	0ce78663          	beq	a5,a4,5e94 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    5dcc:	06300713          	li	a4,99
    5dd0:	0ee78e63          	beq	a5,a4,5ecc <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    5dd4:	11478863          	beq	a5,s4,5ee4 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    5dd8:	85d2                	mv	a1,s4
    5dda:	8556                	mv	a0,s5
    5ddc:	00000097          	auipc	ra,0x0
    5de0:	e92080e7          	jalr	-366(ra) # 5c6e <putc>
        putc(fd, c);
    5de4:	85ca                	mv	a1,s2
    5de6:	8556                	mv	a0,s5
    5de8:	00000097          	auipc	ra,0x0
    5dec:	e86080e7          	jalr	-378(ra) # 5c6e <putc>
      }
      state = 0;
    5df0:	4981                	li	s3,0
    5df2:	b765                	j	5d9a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    5df4:	008b0913          	addi	s2,s6,8
    5df8:	4685                	li	a3,1
    5dfa:	4629                	li	a2,10
    5dfc:	000b2583          	lw	a1,0(s6)
    5e00:	8556                	mv	a0,s5
    5e02:	00000097          	auipc	ra,0x0
    5e06:	e8e080e7          	jalr	-370(ra) # 5c90 <printint>
    5e0a:	8b4a                	mv	s6,s2
      state = 0;
    5e0c:	4981                	li	s3,0
    5e0e:	b771                	j	5d9a <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    5e10:	008b0913          	addi	s2,s6,8
    5e14:	4681                	li	a3,0
    5e16:	4629                	li	a2,10
    5e18:	000b2583          	lw	a1,0(s6)
    5e1c:	8556                	mv	a0,s5
    5e1e:	00000097          	auipc	ra,0x0
    5e22:	e72080e7          	jalr	-398(ra) # 5c90 <printint>
    5e26:	8b4a                	mv	s6,s2
      state = 0;
    5e28:	4981                	li	s3,0
    5e2a:	bf85                	j	5d9a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    5e2c:	008b0913          	addi	s2,s6,8
    5e30:	4681                	li	a3,0
    5e32:	4641                	li	a2,16
    5e34:	000b2583          	lw	a1,0(s6)
    5e38:	8556                	mv	a0,s5
    5e3a:	00000097          	auipc	ra,0x0
    5e3e:	e56080e7          	jalr	-426(ra) # 5c90 <printint>
    5e42:	8b4a                	mv	s6,s2
      state = 0;
    5e44:	4981                	li	s3,0
    5e46:	bf91                	j	5d9a <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    5e48:	008b0793          	addi	a5,s6,8
    5e4c:	f8f43423          	sd	a5,-120(s0)
    5e50:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    5e54:	03000593          	li	a1,48
    5e58:	8556                	mv	a0,s5
    5e5a:	00000097          	auipc	ra,0x0
    5e5e:	e14080e7          	jalr	-492(ra) # 5c6e <putc>
  putc(fd, 'x');
    5e62:	85ea                	mv	a1,s10
    5e64:	8556                	mv	a0,s5
    5e66:	00000097          	auipc	ra,0x0
    5e6a:	e08080e7          	jalr	-504(ra) # 5c6e <putc>
    5e6e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5e70:	03c9d793          	srli	a5,s3,0x3c
    5e74:	97de                	add	a5,a5,s7
    5e76:	0007c583          	lbu	a1,0(a5)
    5e7a:	8556                	mv	a0,s5
    5e7c:	00000097          	auipc	ra,0x0
    5e80:	df2080e7          	jalr	-526(ra) # 5c6e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    5e84:	0992                	slli	s3,s3,0x4
    5e86:	397d                	addiw	s2,s2,-1
    5e88:	fe0914e3          	bnez	s2,5e70 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    5e8c:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    5e90:	4981                	li	s3,0
    5e92:	b721                	j	5d9a <vprintf+0x60>
        s = va_arg(ap, char*);
    5e94:	008b0993          	addi	s3,s6,8
    5e98:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    5e9c:	02090163          	beqz	s2,5ebe <vprintf+0x184>
        while(*s != 0){
    5ea0:	00094583          	lbu	a1,0(s2)
    5ea4:	c9a1                	beqz	a1,5ef4 <vprintf+0x1ba>
          putc(fd, *s);
    5ea6:	8556                	mv	a0,s5
    5ea8:	00000097          	auipc	ra,0x0
    5eac:	dc6080e7          	jalr	-570(ra) # 5c6e <putc>
          s++;
    5eb0:	0905                	addi	s2,s2,1
        while(*s != 0){
    5eb2:	00094583          	lbu	a1,0(s2)
    5eb6:	f9e5                	bnez	a1,5ea6 <vprintf+0x16c>
        s = va_arg(ap, char*);
    5eb8:	8b4e                	mv	s6,s3
      state = 0;
    5eba:	4981                	li	s3,0
    5ebc:	bdf9                	j	5d9a <vprintf+0x60>
          s = "(null)";
    5ebe:	00002917          	auipc	s2,0x2
    5ec2:	6aa90913          	addi	s2,s2,1706 # 8568 <malloc+0x2564>
        while(*s != 0){
    5ec6:	02800593          	li	a1,40
    5eca:	bff1                	j	5ea6 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    5ecc:	008b0913          	addi	s2,s6,8
    5ed0:	000b4583          	lbu	a1,0(s6)
    5ed4:	8556                	mv	a0,s5
    5ed6:	00000097          	auipc	ra,0x0
    5eda:	d98080e7          	jalr	-616(ra) # 5c6e <putc>
    5ede:	8b4a                	mv	s6,s2
      state = 0;
    5ee0:	4981                	li	s3,0
    5ee2:	bd65                	j	5d9a <vprintf+0x60>
        putc(fd, c);
    5ee4:	85d2                	mv	a1,s4
    5ee6:	8556                	mv	a0,s5
    5ee8:	00000097          	auipc	ra,0x0
    5eec:	d86080e7          	jalr	-634(ra) # 5c6e <putc>
      state = 0;
    5ef0:	4981                	li	s3,0
    5ef2:	b565                	j	5d9a <vprintf+0x60>
        s = va_arg(ap, char*);
    5ef4:	8b4e                	mv	s6,s3
      state = 0;
    5ef6:	4981                	li	s3,0
    5ef8:	b54d                	j	5d9a <vprintf+0x60>
    }
  }
}
    5efa:	70e6                	ld	ra,120(sp)
    5efc:	7446                	ld	s0,112(sp)
    5efe:	74a6                	ld	s1,104(sp)
    5f00:	7906                	ld	s2,96(sp)
    5f02:	69e6                	ld	s3,88(sp)
    5f04:	6a46                	ld	s4,80(sp)
    5f06:	6aa6                	ld	s5,72(sp)
    5f08:	6b06                	ld	s6,64(sp)
    5f0a:	7be2                	ld	s7,56(sp)
    5f0c:	7c42                	ld	s8,48(sp)
    5f0e:	7ca2                	ld	s9,40(sp)
    5f10:	7d02                	ld	s10,32(sp)
    5f12:	6de2                	ld	s11,24(sp)
    5f14:	6109                	addi	sp,sp,128
    5f16:	8082                	ret

0000000000005f18 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    5f18:	715d                	addi	sp,sp,-80
    5f1a:	ec06                	sd	ra,24(sp)
    5f1c:	e822                	sd	s0,16(sp)
    5f1e:	1000                	addi	s0,sp,32
    5f20:	e010                	sd	a2,0(s0)
    5f22:	e414                	sd	a3,8(s0)
    5f24:	e818                	sd	a4,16(s0)
    5f26:	ec1c                	sd	a5,24(s0)
    5f28:	03043023          	sd	a6,32(s0)
    5f2c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    5f30:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    5f34:	8622                	mv	a2,s0
    5f36:	00000097          	auipc	ra,0x0
    5f3a:	e04080e7          	jalr	-508(ra) # 5d3a <vprintf>
}
    5f3e:	60e2                	ld	ra,24(sp)
    5f40:	6442                	ld	s0,16(sp)
    5f42:	6161                	addi	sp,sp,80
    5f44:	8082                	ret

0000000000005f46 <printf>:

void
printf(const char *fmt, ...)
{
    5f46:	711d                	addi	sp,sp,-96
    5f48:	ec06                	sd	ra,24(sp)
    5f4a:	e822                	sd	s0,16(sp)
    5f4c:	1000                	addi	s0,sp,32
    5f4e:	e40c                	sd	a1,8(s0)
    5f50:	e810                	sd	a2,16(s0)
    5f52:	ec14                	sd	a3,24(s0)
    5f54:	f018                	sd	a4,32(s0)
    5f56:	f41c                	sd	a5,40(s0)
    5f58:	03043823          	sd	a6,48(s0)
    5f5c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    5f60:	00840613          	addi	a2,s0,8
    5f64:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    5f68:	85aa                	mv	a1,a0
    5f6a:	4505                	li	a0,1
    5f6c:	00000097          	auipc	ra,0x0
    5f70:	dce080e7          	jalr	-562(ra) # 5d3a <vprintf>
}
    5f74:	60e2                	ld	ra,24(sp)
    5f76:	6442                	ld	s0,16(sp)
    5f78:	6125                	addi	sp,sp,96
    5f7a:	8082                	ret

0000000000005f7c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    5f7c:	1141                	addi	sp,sp,-16
    5f7e:	e422                	sd	s0,8(sp)
    5f80:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    5f82:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5f86:	00003797          	auipc	a5,0x3
    5f8a:	4ca7b783          	ld	a5,1226(a5) # 9450 <freep>
    5f8e:	a805                	j	5fbe <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    5f90:	4618                	lw	a4,8(a2)
    5f92:	9db9                	addw	a1,a1,a4
    5f94:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    5f98:	6398                	ld	a4,0(a5)
    5f9a:	6318                	ld	a4,0(a4)
    5f9c:	fee53823          	sd	a4,-16(a0)
    5fa0:	a091                	j	5fe4 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    5fa2:	ff852703          	lw	a4,-8(a0)
    5fa6:	9e39                	addw	a2,a2,a4
    5fa8:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    5faa:	ff053703          	ld	a4,-16(a0)
    5fae:	e398                	sd	a4,0(a5)
    5fb0:	a099                	j	5ff6 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5fb2:	6398                	ld	a4,0(a5)
    5fb4:	00e7e463          	bltu	a5,a4,5fbc <free+0x40>
    5fb8:	00e6ea63          	bltu	a3,a4,5fcc <free+0x50>
{
    5fbc:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5fbe:	fed7fae3          	bgeu	a5,a3,5fb2 <free+0x36>
    5fc2:	6398                	ld	a4,0(a5)
    5fc4:	00e6e463          	bltu	a3,a4,5fcc <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5fc8:	fee7eae3          	bltu	a5,a4,5fbc <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    5fcc:	ff852583          	lw	a1,-8(a0)
    5fd0:	6390                	ld	a2,0(a5)
    5fd2:	02059713          	slli	a4,a1,0x20
    5fd6:	9301                	srli	a4,a4,0x20
    5fd8:	0712                	slli	a4,a4,0x4
    5fda:	9736                	add	a4,a4,a3
    5fdc:	fae60ae3          	beq	a2,a4,5f90 <free+0x14>
    bp->s.ptr = p->s.ptr;
    5fe0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    5fe4:	4790                	lw	a2,8(a5)
    5fe6:	02061713          	slli	a4,a2,0x20
    5fea:	9301                	srli	a4,a4,0x20
    5fec:	0712                	slli	a4,a4,0x4
    5fee:	973e                	add	a4,a4,a5
    5ff0:	fae689e3          	beq	a3,a4,5fa2 <free+0x26>
  } else
    p->s.ptr = bp;
    5ff4:	e394                	sd	a3,0(a5)
  freep = p;
    5ff6:	00003717          	auipc	a4,0x3
    5ffa:	44f73d23          	sd	a5,1114(a4) # 9450 <freep>
}
    5ffe:	6422                	ld	s0,8(sp)
    6000:	0141                	addi	sp,sp,16
    6002:	8082                	ret

0000000000006004 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    6004:	7139                	addi	sp,sp,-64
    6006:	fc06                	sd	ra,56(sp)
    6008:	f822                	sd	s0,48(sp)
    600a:	f426                	sd	s1,40(sp)
    600c:	f04a                	sd	s2,32(sp)
    600e:	ec4e                	sd	s3,24(sp)
    6010:	e852                	sd	s4,16(sp)
    6012:	e456                	sd	s5,8(sp)
    6014:	e05a                	sd	s6,0(sp)
    6016:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    6018:	02051493          	slli	s1,a0,0x20
    601c:	9081                	srli	s1,s1,0x20
    601e:	04bd                	addi	s1,s1,15
    6020:	8091                	srli	s1,s1,0x4
    6022:	0014899b          	addiw	s3,s1,1
    6026:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    6028:	00003517          	auipc	a0,0x3
    602c:	42853503          	ld	a0,1064(a0) # 9450 <freep>
    6030:	c515                	beqz	a0,605c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    6032:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    6034:	4798                	lw	a4,8(a5)
    6036:	02977f63          	bgeu	a4,s1,6074 <malloc+0x70>
    603a:	8a4e                	mv	s4,s3
    603c:	0009871b          	sext.w	a4,s3
    6040:	6685                	lui	a3,0x1
    6042:	00d77363          	bgeu	a4,a3,6048 <malloc+0x44>
    6046:	6a05                	lui	s4,0x1
    6048:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    604c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    6050:	00003917          	auipc	s2,0x3
    6054:	40090913          	addi	s2,s2,1024 # 9450 <freep>
  if(p == (char*)-1)
    6058:	5afd                	li	s5,-1
    605a:	a88d                	j	60cc <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    605c:	0000a797          	auipc	a5,0xa
    6060:	c1c78793          	addi	a5,a5,-996 # fc78 <base>
    6064:	00003717          	auipc	a4,0x3
    6068:	3ef73623          	sd	a5,1004(a4) # 9450 <freep>
    606c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    606e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    6072:	b7e1                	j	603a <malloc+0x36>
      if(p->s.size == nunits)
    6074:	02e48b63          	beq	s1,a4,60aa <malloc+0xa6>
        p->s.size -= nunits;
    6078:	4137073b          	subw	a4,a4,s3
    607c:	c798                	sw	a4,8(a5)
        p += p->s.size;
    607e:	1702                	slli	a4,a4,0x20
    6080:	9301                	srli	a4,a4,0x20
    6082:	0712                	slli	a4,a4,0x4
    6084:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    6086:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    608a:	00003717          	auipc	a4,0x3
    608e:	3ca73323          	sd	a0,966(a4) # 9450 <freep>
      return (void*)(p + 1);
    6092:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    6096:	70e2                	ld	ra,56(sp)
    6098:	7442                	ld	s0,48(sp)
    609a:	74a2                	ld	s1,40(sp)
    609c:	7902                	ld	s2,32(sp)
    609e:	69e2                	ld	s3,24(sp)
    60a0:	6a42                	ld	s4,16(sp)
    60a2:	6aa2                	ld	s5,8(sp)
    60a4:	6b02                	ld	s6,0(sp)
    60a6:	6121                	addi	sp,sp,64
    60a8:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    60aa:	6398                	ld	a4,0(a5)
    60ac:	e118                	sd	a4,0(a0)
    60ae:	bff1                	j	608a <malloc+0x86>
  hp->s.size = nu;
    60b0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    60b4:	0541                	addi	a0,a0,16
    60b6:	00000097          	auipc	ra,0x0
    60ba:	ec6080e7          	jalr	-314(ra) # 5f7c <free>
  return freep;
    60be:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    60c2:	d971                	beqz	a0,6096 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    60c4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    60c6:	4798                	lw	a4,8(a5)
    60c8:	fa9776e3          	bgeu	a4,s1,6074 <malloc+0x70>
    if(p == freep)
    60cc:	00093703          	ld	a4,0(s2)
    60d0:	853e                	mv	a0,a5
    60d2:	fef719e3          	bne	a4,a5,60c4 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    60d6:	8552                	mv	a0,s4
    60d8:	00000097          	auipc	ra,0x0
    60dc:	b76080e7          	jalr	-1162(ra) # 5c4e <sbrk>
  if(p == (char*)-1)
    60e0:	fd5518e3          	bne	a0,s5,60b0 <malloc+0xac>
        return 0;
    60e4:	4501                	li	a0,0
    60e6:	bf45                	j	6096 <malloc+0x92>

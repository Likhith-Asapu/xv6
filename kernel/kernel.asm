
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	c2010113          	addi	sp,sp,-992 # 80008c20 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	a8e70713          	addi	a4,a4,-1394 # 80008ae0 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	e9c78793          	addi	a5,a5,-356 # 80005f00 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc2af>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	dca78793          	addi	a5,a5,-566 # 80000e78 <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	715d                	addi	sp,sp,-80
    80000104:	e486                	sd	ra,72(sp)
    80000106:	e0a2                	sd	s0,64(sp)
    80000108:	fc26                	sd	s1,56(sp)
    8000010a:	f84a                	sd	s2,48(sp)
    8000010c:	f44e                	sd	s3,40(sp)
    8000010e:	f052                	sd	s4,32(sp)
    80000110:	ec56                	sd	s5,24(sp)
    80000112:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000114:	04c05663          	blez	a2,80000160 <consolewrite+0x5e>
    80000118:	8a2a                	mv	s4,a0
    8000011a:	84ae                	mv	s1,a1
    8000011c:	89b2                	mv	s3,a2
    8000011e:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000120:	5afd                	li	s5,-1
    80000122:	4685                	li	a3,1
    80000124:	8626                	mv	a2,s1
    80000126:	85d2                	mv	a1,s4
    80000128:	fbf40513          	addi	a0,s0,-65
    8000012c:	00002097          	auipc	ra,0x2
    80000130:	5c6080e7          	jalr	1478(ra) # 800026f2 <either_copyin>
    80000134:	01550c63          	beq	a0,s5,8000014c <consolewrite+0x4a>
      break;
    uartputc(c);
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00000097          	auipc	ra,0x0
    80000140:	780080e7          	jalr	1920(ra) # 800008bc <uartputc>
  for(i = 0; i < n; i++){
    80000144:	2905                	addiw	s2,s2,1
    80000146:	0485                	addi	s1,s1,1
    80000148:	fd299de3          	bne	s3,s2,80000122 <consolewrite+0x20>
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4a>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	a9650513          	addi	a0,a0,-1386 # 80010c20 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	a8648493          	addi	s1,s1,-1402 # 80010c20 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	b1690913          	addi	s2,s2,-1258 # 80010cb8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ae:	4ca9                	li	s9,10
  while(n > 0){
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
    while(cons.r == cons.w){
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
      if(killed(myproc())){
    800001c0:	00001097          	auipc	ra,0x1
    800001c4:	7ec080e7          	jalr	2028(ra) # 800019ac <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	374080e7          	jalr	884(ra) # 8000253c <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	f66080e7          	jalr	-154(ra) # 8000213c <sleep>
    while(cons.r == cons.w){
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
    cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	48a080e7          	jalr	1162(ra) # 8000269c <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	9fa50513          	addi	a0,a0,-1542 # 80010c20 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	9e450513          	addi	a0,a0,-1564 # 80010c20 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	a46080e7          	jalr	-1466(ra) # 80000c8a <release>
        return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
      if(n < target){
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	a4f72323          	sw	a5,-1466(a4) # 80010cb8 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	55e080e7          	jalr	1374(ra) # 800007ea <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	54c080e7          	jalr	1356(ra) # 800007ea <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	540080e7          	jalr	1344(ra) # 800007ea <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	536080e7          	jalr	1334(ra) # 800007ea <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00011517          	auipc	a0,0x11
    800002d0:	95450513          	addi	a0,a0,-1708 # 80010c20 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	902080e7          	jalr	-1790(ra) # 80000bd6 <acquire>

  switch(c){
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	456080e7          	jalr	1110(ra) # 80002748 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00011517          	auipc	a0,0x11
    800002fe:	92650513          	addi	a0,a0,-1754 # 80010c20 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	988080e7          	jalr	-1656(ra) # 80000c8a <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch(c){
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031e:	00011717          	auipc	a4,0x11
    80000322:	90270713          	addi	a4,a4,-1790 # 80010c20 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00011797          	auipc	a5,0x11
    8000034c:	8d878793          	addi	a5,a5,-1832 # 80010c20 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00011797          	auipc	a5,0x11
    8000037a:	9427a783          	lw	a5,-1726(a5) # 80010cb8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00011717          	auipc	a4,0x11
    8000038e:	89670713          	addi	a4,a4,-1898 # 80010c20 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00011497          	auipc	s1,0x11
    8000039e:	88648493          	addi	s1,s1,-1914 # 80010c20 <cons>
    while(cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while(cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d6:	00011717          	auipc	a4,0x11
    800003da:	84a70713          	addi	a4,a4,-1974 # 80010c20 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00011717          	auipc	a4,0x11
    800003f0:	8cf72a23          	sw	a5,-1836(a4) # 80010cc0 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00011797          	auipc	a5,0x11
    80000416:	80e78793          	addi	a5,a5,-2034 # 80010c20 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00011797          	auipc	a5,0x11
    8000043a:	88c7a323          	sw	a2,-1914(a5) # 80010cbc <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00011517          	auipc	a0,0x11
    80000442:	87a50513          	addi	a0,a0,-1926 # 80010cb8 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	ea6080e7          	jalr	-346(ra) # 800022ec <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void
consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00010517          	auipc	a0,0x10
    80000464:	7c050513          	addi	a0,a0,1984 # 80010c20 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32a080e7          	jalr	810(ra) # 8000079a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00021797          	auipc	a5,0x21
    8000047c:	f4078793          	addi	a5,a5,-192 # 800213b8 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7870713          	addi	a4,a4,-904 # 80000102 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054663          	bltz	a0,80000536 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088b63          	beqz	a7,800004fc <printint+0x60>
    buf[i++] = '-';
    800004ea:	fe040793          	addi	a5,s0,-32
    800004ee:	973e                	add	a4,a4,a5
    800004f0:	02d00793          	li	a5,45
    800004f4:	fef70823          	sb	a5,-16(a4)
    800004f8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fc:	02e05763          	blez	a4,8000052a <printint+0x8e>
    80000500:	fd040793          	addi	a5,s0,-48
    80000504:	00e784b3          	add	s1,a5,a4
    80000508:	fff78913          	addi	s2,a5,-1
    8000050c:	993a                	add	s2,s2,a4
    8000050e:	377d                	addiw	a4,a4,-1
    80000510:	1702                	slli	a4,a4,0x20
    80000512:	9301                	srli	a4,a4,0x20
    80000514:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000518:	fff4c503          	lbu	a0,-1(s1)
    8000051c:	00000097          	auipc	ra,0x0
    80000520:	d60080e7          	jalr	-672(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000524:	14fd                	addi	s1,s1,-1
    80000526:	ff2499e3          	bne	s1,s2,80000518 <printint+0x7c>
}
    8000052a:	70a2                	ld	ra,40(sp)
    8000052c:	7402                	ld	s0,32(sp)
    8000052e:	64e2                	ld	s1,24(sp)
    80000530:	6942                	ld	s2,16(sp)
    80000532:	6145                	addi	sp,sp,48
    80000534:	8082                	ret
    x = -xx;
    80000536:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053a:	4885                	li	a7,1
    x = -xx;
    8000053c:	bf9d                	j	800004b2 <printint+0x16>

000000008000053e <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053e:	1101                	addi	sp,sp,-32
    80000540:	ec06                	sd	ra,24(sp)
    80000542:	e822                	sd	s0,16(sp)
    80000544:	e426                	sd	s1,8(sp)
    80000546:	1000                	addi	s0,sp,32
    80000548:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054a:	00010797          	auipc	a5,0x10
    8000054e:	7807ab23          	sw	zero,1942(a5) # 80010ce0 <pr+0x18>
  printf("panic: ");
    80000552:	00008517          	auipc	a0,0x8
    80000556:	ac650513          	addi	a0,a0,-1338 # 80008018 <etext+0x18>
    8000055a:	00000097          	auipc	ra,0x0
    8000055e:	02e080e7          	jalr	46(ra) # 80000588 <printf>
  printf(s);
    80000562:	8526                	mv	a0,s1
    80000564:	00000097          	auipc	ra,0x0
    80000568:	024080e7          	jalr	36(ra) # 80000588 <printf>
  printf("\n");
    8000056c:	00008517          	auipc	a0,0x8
    80000570:	b5c50513          	addi	a0,a0,-1188 # 800080c8 <digits+0x88>
    80000574:	00000097          	auipc	ra,0x0
    80000578:	014080e7          	jalr	20(ra) # 80000588 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057c:	4785                	li	a5,1
    8000057e:	00008717          	auipc	a4,0x8
    80000582:	52f72123          	sw	a5,1314(a4) # 80008aa0 <panicked>
  for(;;)
    80000586:	a001                	j	80000586 <panic+0x48>

0000000080000588 <printf>:
{
    80000588:	7131                	addi	sp,sp,-192
    8000058a:	fc86                	sd	ra,120(sp)
    8000058c:	f8a2                	sd	s0,112(sp)
    8000058e:	f4a6                	sd	s1,104(sp)
    80000590:	f0ca                	sd	s2,96(sp)
    80000592:	ecce                	sd	s3,88(sp)
    80000594:	e8d2                	sd	s4,80(sp)
    80000596:	e4d6                	sd	s5,72(sp)
    80000598:	e0da                	sd	s6,64(sp)
    8000059a:	fc5e                	sd	s7,56(sp)
    8000059c:	f862                	sd	s8,48(sp)
    8000059e:	f466                	sd	s9,40(sp)
    800005a0:	f06a                	sd	s10,32(sp)
    800005a2:	ec6e                	sd	s11,24(sp)
    800005a4:	0100                	addi	s0,sp,128
    800005a6:	8a2a                	mv	s4,a0
    800005a8:	e40c                	sd	a1,8(s0)
    800005aa:	e810                	sd	a2,16(s0)
    800005ac:	ec14                	sd	a3,24(s0)
    800005ae:	f018                	sd	a4,32(s0)
    800005b0:	f41c                	sd	a5,40(s0)
    800005b2:	03043823          	sd	a6,48(s0)
    800005b6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ba:	00010d97          	auipc	s11,0x10
    800005be:	726dad83          	lw	s11,1830(s11) # 80010ce0 <pr+0x18>
  if(locking)
    800005c2:	020d9b63          	bnez	s11,800005f8 <printf+0x70>
  if (fmt == 0)
    800005c6:	040a0263          	beqz	s4,8000060a <printf+0x82>
  va_start(ap, fmt);
    800005ca:	00840793          	addi	a5,s0,8
    800005ce:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d2:	000a4503          	lbu	a0,0(s4)
    800005d6:	14050f63          	beqz	a0,80000734 <printf+0x1ac>
    800005da:	4981                	li	s3,0
    if(c != '%'){
    800005dc:	02500a93          	li	s5,37
    switch(c){
    800005e0:	07000b93          	li	s7,112
  consputc('x');
    800005e4:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e6:	00008b17          	auipc	s6,0x8
    800005ea:	a5ab0b13          	addi	s6,s6,-1446 # 80008040 <digits>
    switch(c){
    800005ee:	07300c93          	li	s9,115
    800005f2:	06400c13          	li	s8,100
    800005f6:	a82d                	j	80000630 <printf+0xa8>
    acquire(&pr.lock);
    800005f8:	00010517          	auipc	a0,0x10
    800005fc:	6d050513          	addi	a0,a0,1744 # 80010cc8 <pr>
    80000600:	00000097          	auipc	ra,0x0
    80000604:	5d6080e7          	jalr	1494(ra) # 80000bd6 <acquire>
    80000608:	bf7d                	j	800005c6 <printf+0x3e>
    panic("null fmt");
    8000060a:	00008517          	auipc	a0,0x8
    8000060e:	a1e50513          	addi	a0,a0,-1506 # 80008028 <etext+0x28>
    80000612:	00000097          	auipc	ra,0x0
    80000616:	f2c080e7          	jalr	-212(ra) # 8000053e <panic>
      consputc(c);
    8000061a:	00000097          	auipc	ra,0x0
    8000061e:	c62080e7          	jalr	-926(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000622:	2985                	addiw	s3,s3,1
    80000624:	013a07b3          	add	a5,s4,s3
    80000628:	0007c503          	lbu	a0,0(a5)
    8000062c:	10050463          	beqz	a0,80000734 <printf+0x1ac>
    if(c != '%'){
    80000630:	ff5515e3          	bne	a0,s5,8000061a <printf+0x92>
    c = fmt[++i] & 0xff;
    80000634:	2985                	addiw	s3,s3,1
    80000636:	013a07b3          	add	a5,s4,s3
    8000063a:	0007c783          	lbu	a5,0(a5)
    8000063e:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000642:	cbed                	beqz	a5,80000734 <printf+0x1ac>
    switch(c){
    80000644:	05778a63          	beq	a5,s7,80000698 <printf+0x110>
    80000648:	02fbf663          	bgeu	s7,a5,80000674 <printf+0xec>
    8000064c:	09978863          	beq	a5,s9,800006dc <printf+0x154>
    80000650:	07800713          	li	a4,120
    80000654:	0ce79563          	bne	a5,a4,8000071e <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000658:	f8843783          	ld	a5,-120(s0)
    8000065c:	00878713          	addi	a4,a5,8
    80000660:	f8e43423          	sd	a4,-120(s0)
    80000664:	4605                	li	a2,1
    80000666:	85ea                	mv	a1,s10
    80000668:	4388                	lw	a0,0(a5)
    8000066a:	00000097          	auipc	ra,0x0
    8000066e:	e32080e7          	jalr	-462(ra) # 8000049c <printint>
      break;
    80000672:	bf45                	j	80000622 <printf+0x9a>
    switch(c){
    80000674:	09578f63          	beq	a5,s5,80000712 <printf+0x18a>
    80000678:	0b879363          	bne	a5,s8,8000071e <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4605                	li	a2,1
    8000068a:	45a9                	li	a1,10
    8000068c:	4388                	lw	a0,0(a5)
    8000068e:	00000097          	auipc	ra,0x0
    80000692:	e0e080e7          	jalr	-498(ra) # 8000049c <printint>
      break;
    80000696:	b771                	j	80000622 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000698:	f8843783          	ld	a5,-120(s0)
    8000069c:	00878713          	addi	a4,a5,8
    800006a0:	f8e43423          	sd	a4,-120(s0)
    800006a4:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a8:	03000513          	li	a0,48
    800006ac:	00000097          	auipc	ra,0x0
    800006b0:	bd0080e7          	jalr	-1072(ra) # 8000027c <consputc>
  consputc('x');
    800006b4:	07800513          	li	a0,120
    800006b8:	00000097          	auipc	ra,0x0
    800006bc:	bc4080e7          	jalr	-1084(ra) # 8000027c <consputc>
    800006c0:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c2:	03c95793          	srli	a5,s2,0x3c
    800006c6:	97da                	add	a5,a5,s6
    800006c8:	0007c503          	lbu	a0,0(a5)
    800006cc:	00000097          	auipc	ra,0x0
    800006d0:	bb0080e7          	jalr	-1104(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d4:	0912                	slli	s2,s2,0x4
    800006d6:	34fd                	addiw	s1,s1,-1
    800006d8:	f4ed                	bnez	s1,800006c2 <printf+0x13a>
    800006da:	b7a1                	j	80000622 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006dc:	f8843783          	ld	a5,-120(s0)
    800006e0:	00878713          	addi	a4,a5,8
    800006e4:	f8e43423          	sd	a4,-120(s0)
    800006e8:	6384                	ld	s1,0(a5)
    800006ea:	cc89                	beqz	s1,80000704 <printf+0x17c>
      for(; *s; s++)
    800006ec:	0004c503          	lbu	a0,0(s1)
    800006f0:	d90d                	beqz	a0,80000622 <printf+0x9a>
        consputc(*s);
    800006f2:	00000097          	auipc	ra,0x0
    800006f6:	b8a080e7          	jalr	-1142(ra) # 8000027c <consputc>
      for(; *s; s++)
    800006fa:	0485                	addi	s1,s1,1
    800006fc:	0004c503          	lbu	a0,0(s1)
    80000700:	f96d                	bnez	a0,800006f2 <printf+0x16a>
    80000702:	b705                	j	80000622 <printf+0x9a>
        s = "(null)";
    80000704:	00008497          	auipc	s1,0x8
    80000708:	91c48493          	addi	s1,s1,-1764 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070c:	02800513          	li	a0,40
    80000710:	b7cd                	j	800006f2 <printf+0x16a>
      consputc('%');
    80000712:	8556                	mv	a0,s5
    80000714:	00000097          	auipc	ra,0x0
    80000718:	b68080e7          	jalr	-1176(ra) # 8000027c <consputc>
      break;
    8000071c:	b719                	j	80000622 <printf+0x9a>
      consputc('%');
    8000071e:	8556                	mv	a0,s5
    80000720:	00000097          	auipc	ra,0x0
    80000724:	b5c080e7          	jalr	-1188(ra) # 8000027c <consputc>
      consputc(c);
    80000728:	8526                	mv	a0,s1
    8000072a:	00000097          	auipc	ra,0x0
    8000072e:	b52080e7          	jalr	-1198(ra) # 8000027c <consputc>
      break;
    80000732:	bdc5                	j	80000622 <printf+0x9a>
  if(locking)
    80000734:	020d9163          	bnez	s11,80000756 <printf+0x1ce>
}
    80000738:	70e6                	ld	ra,120(sp)
    8000073a:	7446                	ld	s0,112(sp)
    8000073c:	74a6                	ld	s1,104(sp)
    8000073e:	7906                	ld	s2,96(sp)
    80000740:	69e6                	ld	s3,88(sp)
    80000742:	6a46                	ld	s4,80(sp)
    80000744:	6aa6                	ld	s5,72(sp)
    80000746:	6b06                	ld	s6,64(sp)
    80000748:	7be2                	ld	s7,56(sp)
    8000074a:	7c42                	ld	s8,48(sp)
    8000074c:	7ca2                	ld	s9,40(sp)
    8000074e:	7d02                	ld	s10,32(sp)
    80000750:	6de2                	ld	s11,24(sp)
    80000752:	6129                	addi	sp,sp,192
    80000754:	8082                	ret
    release(&pr.lock);
    80000756:	00010517          	auipc	a0,0x10
    8000075a:	57250513          	addi	a0,a0,1394 # 80010cc8 <pr>
    8000075e:	00000097          	auipc	ra,0x0
    80000762:	52c080e7          	jalr	1324(ra) # 80000c8a <release>
}
    80000766:	bfc9                	j	80000738 <printf+0x1b0>

0000000080000768 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000768:	1101                	addi	sp,sp,-32
    8000076a:	ec06                	sd	ra,24(sp)
    8000076c:	e822                	sd	s0,16(sp)
    8000076e:	e426                	sd	s1,8(sp)
    80000770:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000772:	00010497          	auipc	s1,0x10
    80000776:	55648493          	addi	s1,s1,1366 # 80010cc8 <pr>
    8000077a:	00008597          	auipc	a1,0x8
    8000077e:	8be58593          	addi	a1,a1,-1858 # 80008038 <etext+0x38>
    80000782:	8526                	mv	a0,s1
    80000784:	00000097          	auipc	ra,0x0
    80000788:	3c2080e7          	jalr	962(ra) # 80000b46 <initlock>
  pr.locking = 1;
    8000078c:	4785                	li	a5,1
    8000078e:	cc9c                	sw	a5,24(s1)
}
    80000790:	60e2                	ld	ra,24(sp)
    80000792:	6442                	ld	s0,16(sp)
    80000794:	64a2                	ld	s1,8(sp)
    80000796:	6105                	addi	sp,sp,32
    80000798:	8082                	ret

000000008000079a <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079a:	1141                	addi	sp,sp,-16
    8000079c:	e406                	sd	ra,8(sp)
    8000079e:	e022                	sd	s0,0(sp)
    800007a0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a2:	100007b7          	lui	a5,0x10000
    800007a6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007aa:	f8000713          	li	a4,-128
    800007ae:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b2:	470d                	li	a4,3
    800007b4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007bc:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c0:	469d                	li	a3,7
    800007c2:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c6:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007ca:	00008597          	auipc	a1,0x8
    800007ce:	88e58593          	addi	a1,a1,-1906 # 80008058 <digits+0x18>
    800007d2:	00010517          	auipc	a0,0x10
    800007d6:	51650513          	addi	a0,a0,1302 # 80010ce8 <uart_tx_lock>
    800007da:	00000097          	auipc	ra,0x0
    800007de:	36c080e7          	jalr	876(ra) # 80000b46 <initlock>
}
    800007e2:	60a2                	ld	ra,8(sp)
    800007e4:	6402                	ld	s0,0(sp)
    800007e6:	0141                	addi	sp,sp,16
    800007e8:	8082                	ret

00000000800007ea <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ea:	1101                	addi	sp,sp,-32
    800007ec:	ec06                	sd	ra,24(sp)
    800007ee:	e822                	sd	s0,16(sp)
    800007f0:	e426                	sd	s1,8(sp)
    800007f2:	1000                	addi	s0,sp,32
    800007f4:	84aa                	mv	s1,a0
  push_off();
    800007f6:	00000097          	auipc	ra,0x0
    800007fa:	394080e7          	jalr	916(ra) # 80000b8a <push_off>

  if(panicked){
    800007fe:	00008797          	auipc	a5,0x8
    80000802:	2a27a783          	lw	a5,674(a5) # 80008aa0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000806:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080a:	c391                	beqz	a5,8000080e <uartputc_sync+0x24>
    for(;;)
    8000080c:	a001                	j	8000080c <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080e:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000812:	0207f793          	andi	a5,a5,32
    80000816:	dfe5                	beqz	a5,8000080e <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000818:	0ff4f513          	andi	a0,s1,255
    8000081c:	100007b7          	lui	a5,0x10000
    80000820:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000824:	00000097          	auipc	ra,0x0
    80000828:	406080e7          	jalr	1030(ra) # 80000c2a <pop_off>
}
    8000082c:	60e2                	ld	ra,24(sp)
    8000082e:	6442                	ld	s0,16(sp)
    80000830:	64a2                	ld	s1,8(sp)
    80000832:	6105                	addi	sp,sp,32
    80000834:	8082                	ret

0000000080000836 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000836:	00008797          	auipc	a5,0x8
    8000083a:	2727b783          	ld	a5,626(a5) # 80008aa8 <uart_tx_r>
    8000083e:	00008717          	auipc	a4,0x8
    80000842:	27273703          	ld	a4,626(a4) # 80008ab0 <uart_tx_w>
    80000846:	06f70a63          	beq	a4,a5,800008ba <uartstart+0x84>
{
    8000084a:	7139                	addi	sp,sp,-64
    8000084c:	fc06                	sd	ra,56(sp)
    8000084e:	f822                	sd	s0,48(sp)
    80000850:	f426                	sd	s1,40(sp)
    80000852:	f04a                	sd	s2,32(sp)
    80000854:	ec4e                	sd	s3,24(sp)
    80000856:	e852                	sd	s4,16(sp)
    80000858:	e456                	sd	s5,8(sp)
    8000085a:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085c:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000860:	00010a17          	auipc	s4,0x10
    80000864:	488a0a13          	addi	s4,s4,1160 # 80010ce8 <uart_tx_lock>
    uart_tx_r += 1;
    80000868:	00008497          	auipc	s1,0x8
    8000086c:	24048493          	addi	s1,s1,576 # 80008aa8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000870:	00008997          	auipc	s3,0x8
    80000874:	24098993          	addi	s3,s3,576 # 80008ab0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000878:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087c:	02077713          	andi	a4,a4,32
    80000880:	c705                	beqz	a4,800008a8 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000882:	01f7f713          	andi	a4,a5,31
    80000886:	9752                	add	a4,a4,s4
    80000888:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088c:	0785                	addi	a5,a5,1
    8000088e:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000890:	8526                	mv	a0,s1
    80000892:	00002097          	auipc	ra,0x2
    80000896:	a5a080e7          	jalr	-1446(ra) # 800022ec <wakeup>
    
    WriteReg(THR, c);
    8000089a:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089e:	609c                	ld	a5,0(s1)
    800008a0:	0009b703          	ld	a4,0(s3)
    800008a4:	fcf71ae3          	bne	a4,a5,80000878 <uartstart+0x42>
  }
}
    800008a8:	70e2                	ld	ra,56(sp)
    800008aa:	7442                	ld	s0,48(sp)
    800008ac:	74a2                	ld	s1,40(sp)
    800008ae:	7902                	ld	s2,32(sp)
    800008b0:	69e2                	ld	s3,24(sp)
    800008b2:	6a42                	ld	s4,16(sp)
    800008b4:	6aa2                	ld	s5,8(sp)
    800008b6:	6121                	addi	sp,sp,64
    800008b8:	8082                	ret
    800008ba:	8082                	ret

00000000800008bc <uartputc>:
{
    800008bc:	7179                	addi	sp,sp,-48
    800008be:	f406                	sd	ra,40(sp)
    800008c0:	f022                	sd	s0,32(sp)
    800008c2:	ec26                	sd	s1,24(sp)
    800008c4:	e84a                	sd	s2,16(sp)
    800008c6:	e44e                	sd	s3,8(sp)
    800008c8:	e052                	sd	s4,0(sp)
    800008ca:	1800                	addi	s0,sp,48
    800008cc:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008ce:	00010517          	auipc	a0,0x10
    800008d2:	41a50513          	addi	a0,a0,1050 # 80010ce8 <uart_tx_lock>
    800008d6:	00000097          	auipc	ra,0x0
    800008da:	300080e7          	jalr	768(ra) # 80000bd6 <acquire>
  if(panicked){
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	1c27a783          	lw	a5,450(a5) # 80008aa0 <panicked>
    800008e6:	e7c9                	bnez	a5,80000970 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e8:	00008717          	auipc	a4,0x8
    800008ec:	1c873703          	ld	a4,456(a4) # 80008ab0 <uart_tx_w>
    800008f0:	00008797          	auipc	a5,0x8
    800008f4:	1b87b783          	ld	a5,440(a5) # 80008aa8 <uart_tx_r>
    800008f8:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fc:	00010997          	auipc	s3,0x10
    80000900:	3ec98993          	addi	s3,s3,1004 # 80010ce8 <uart_tx_lock>
    80000904:	00008497          	auipc	s1,0x8
    80000908:	1a448493          	addi	s1,s1,420 # 80008aa8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090c:	00008917          	auipc	s2,0x8
    80000910:	1a490913          	addi	s2,s2,420 # 80008ab0 <uart_tx_w>
    80000914:	00e79f63          	bne	a5,a4,80000932 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000918:	85ce                	mv	a1,s3
    8000091a:	8526                	mv	a0,s1
    8000091c:	00002097          	auipc	ra,0x2
    80000920:	820080e7          	jalr	-2016(ra) # 8000213c <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000924:	00093703          	ld	a4,0(s2)
    80000928:	609c                	ld	a5,0(s1)
    8000092a:	02078793          	addi	a5,a5,32
    8000092e:	fee785e3          	beq	a5,a4,80000918 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000932:	00010497          	auipc	s1,0x10
    80000936:	3b648493          	addi	s1,s1,950 # 80010ce8 <uart_tx_lock>
    8000093a:	01f77793          	andi	a5,a4,31
    8000093e:	97a6                	add	a5,a5,s1
    80000940:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000944:	0705                	addi	a4,a4,1
    80000946:	00008797          	auipc	a5,0x8
    8000094a:	16e7b523          	sd	a4,362(a5) # 80008ab0 <uart_tx_w>
  uartstart();
    8000094e:	00000097          	auipc	ra,0x0
    80000952:	ee8080e7          	jalr	-280(ra) # 80000836 <uartstart>
  release(&uart_tx_lock);
    80000956:	8526                	mv	a0,s1
    80000958:	00000097          	auipc	ra,0x0
    8000095c:	332080e7          	jalr	818(ra) # 80000c8a <release>
}
    80000960:	70a2                	ld	ra,40(sp)
    80000962:	7402                	ld	s0,32(sp)
    80000964:	64e2                	ld	s1,24(sp)
    80000966:	6942                	ld	s2,16(sp)
    80000968:	69a2                	ld	s3,8(sp)
    8000096a:	6a02                	ld	s4,0(sp)
    8000096c:	6145                	addi	sp,sp,48
    8000096e:	8082                	ret
    for(;;)
    80000970:	a001                	j	80000970 <uartputc+0xb4>

0000000080000972 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000972:	1141                	addi	sp,sp,-16
    80000974:	e422                	sd	s0,8(sp)
    80000976:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000978:	100007b7          	lui	a5,0x10000
    8000097c:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000980:	8b85                	andi	a5,a5,1
    80000982:	cb91                	beqz	a5,80000996 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000984:	100007b7          	lui	a5,0x10000
    80000988:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000098c:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80000990:	6422                	ld	s0,8(sp)
    80000992:	0141                	addi	sp,sp,16
    80000994:	8082                	ret
    return -1;
    80000996:	557d                	li	a0,-1
    80000998:	bfe5                	j	80000990 <uartgetc+0x1e>

000000008000099a <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    8000099a:	1101                	addi	sp,sp,-32
    8000099c:	ec06                	sd	ra,24(sp)
    8000099e:	e822                	sd	s0,16(sp)
    800009a0:	e426                	sd	s1,8(sp)
    800009a2:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009a4:	54fd                	li	s1,-1
    800009a6:	a029                	j	800009b0 <uartintr+0x16>
      break;
    consoleintr(c);
    800009a8:	00000097          	auipc	ra,0x0
    800009ac:	916080e7          	jalr	-1770(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009b0:	00000097          	auipc	ra,0x0
    800009b4:	fc2080e7          	jalr	-62(ra) # 80000972 <uartgetc>
    if(c == -1)
    800009b8:	fe9518e3          	bne	a0,s1,800009a8 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009bc:	00010497          	auipc	s1,0x10
    800009c0:	32c48493          	addi	s1,s1,812 # 80010ce8 <uart_tx_lock>
    800009c4:	8526                	mv	a0,s1
    800009c6:	00000097          	auipc	ra,0x0
    800009ca:	210080e7          	jalr	528(ra) # 80000bd6 <acquire>
  uartstart();
    800009ce:	00000097          	auipc	ra,0x0
    800009d2:	e68080e7          	jalr	-408(ra) # 80000836 <uartstart>
  release(&uart_tx_lock);
    800009d6:	8526                	mv	a0,s1
    800009d8:	00000097          	auipc	ra,0x0
    800009dc:	2b2080e7          	jalr	690(ra) # 80000c8a <release>
}
    800009e0:	60e2                	ld	ra,24(sp)
    800009e2:	6442                	ld	s0,16(sp)
    800009e4:	64a2                	ld	s1,8(sp)
    800009e6:	6105                	addi	sp,sp,32
    800009e8:	8082                	ret

00000000800009ea <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009ea:	1101                	addi	sp,sp,-32
    800009ec:	ec06                	sd	ra,24(sp)
    800009ee:	e822                	sd	s0,16(sp)
    800009f0:	e426                	sd	s1,8(sp)
    800009f2:	e04a                	sd	s2,0(sp)
    800009f4:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f6:	03451793          	slli	a5,a0,0x34
    800009fa:	ebb9                	bnez	a5,80000a50 <kfree+0x66>
    800009fc:	84aa                	mv	s1,a0
    800009fe:	00022797          	auipc	a5,0x22
    80000a02:	b5278793          	addi	a5,a5,-1198 # 80022550 <end>
    80000a06:	04f56563          	bltu	a0,a5,80000a50 <kfree+0x66>
    80000a0a:	47c5                	li	a5,17
    80000a0c:	07ee                	slli	a5,a5,0x1b
    80000a0e:	04f57163          	bgeu	a0,a5,80000a50 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a12:	6605                	lui	a2,0x1
    80000a14:	4585                	li	a1,1
    80000a16:	00000097          	auipc	ra,0x0
    80000a1a:	2bc080e7          	jalr	700(ra) # 80000cd2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a1e:	00010917          	auipc	s2,0x10
    80000a22:	30290913          	addi	s2,s2,770 # 80010d20 <kmem>
    80000a26:	854a                	mv	a0,s2
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	1ae080e7          	jalr	430(ra) # 80000bd6 <acquire>
  r->next = kmem.freelist;
    80000a30:	01893783          	ld	a5,24(s2)
    80000a34:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a36:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a3a:	854a                	mv	a0,s2
    80000a3c:	00000097          	auipc	ra,0x0
    80000a40:	24e080e7          	jalr	590(ra) # 80000c8a <release>
}
    80000a44:	60e2                	ld	ra,24(sp)
    80000a46:	6442                	ld	s0,16(sp)
    80000a48:	64a2                	ld	s1,8(sp)
    80000a4a:	6902                	ld	s2,0(sp)
    80000a4c:	6105                	addi	sp,sp,32
    80000a4e:	8082                	ret
    panic("kfree");
    80000a50:	00007517          	auipc	a0,0x7
    80000a54:	61050513          	addi	a0,a0,1552 # 80008060 <digits+0x20>
    80000a58:	00000097          	auipc	ra,0x0
    80000a5c:	ae6080e7          	jalr	-1306(ra) # 8000053e <panic>

0000000080000a60 <freerange>:
{
    80000a60:	7179                	addi	sp,sp,-48
    80000a62:	f406                	sd	ra,40(sp)
    80000a64:	f022                	sd	s0,32(sp)
    80000a66:	ec26                	sd	s1,24(sp)
    80000a68:	e84a                	sd	s2,16(sp)
    80000a6a:	e44e                	sd	s3,8(sp)
    80000a6c:	e052                	sd	s4,0(sp)
    80000a6e:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a70:	6785                	lui	a5,0x1
    80000a72:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a76:	94aa                	add	s1,s1,a0
    80000a78:	757d                	lui	a0,0xfffff
    80000a7a:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a7c:	94be                	add	s1,s1,a5
    80000a7e:	0095ee63          	bltu	a1,s1,80000a9a <freerange+0x3a>
    80000a82:	892e                	mv	s2,a1
    kfree(p);
    80000a84:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a86:	6985                	lui	s3,0x1
    kfree(p);
    80000a88:	01448533          	add	a0,s1,s4
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	f5e080e7          	jalr	-162(ra) # 800009ea <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	94ce                	add	s1,s1,s3
    80000a96:	fe9979e3          	bgeu	s2,s1,80000a88 <freerange+0x28>
}
    80000a9a:	70a2                	ld	ra,40(sp)
    80000a9c:	7402                	ld	s0,32(sp)
    80000a9e:	64e2                	ld	s1,24(sp)
    80000aa0:	6942                	ld	s2,16(sp)
    80000aa2:	69a2                	ld	s3,8(sp)
    80000aa4:	6a02                	ld	s4,0(sp)
    80000aa6:	6145                	addi	sp,sp,48
    80000aa8:	8082                	ret

0000000080000aaa <kinit>:
{
    80000aaa:	1141                	addi	sp,sp,-16
    80000aac:	e406                	sd	ra,8(sp)
    80000aae:	e022                	sd	s0,0(sp)
    80000ab0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ab2:	00007597          	auipc	a1,0x7
    80000ab6:	5b658593          	addi	a1,a1,1462 # 80008068 <digits+0x28>
    80000aba:	00010517          	auipc	a0,0x10
    80000abe:	26650513          	addi	a0,a0,614 # 80010d20 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00022517          	auipc	a0,0x22
    80000ad2:	a8250513          	addi	a0,a0,-1406 # 80022550 <end>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	f8a080e7          	jalr	-118(ra) # 80000a60 <freerange>
}
    80000ade:	60a2                	ld	ra,8(sp)
    80000ae0:	6402                	ld	s0,0(sp)
    80000ae2:	0141                	addi	sp,sp,16
    80000ae4:	8082                	ret

0000000080000ae6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae6:	1101                	addi	sp,sp,-32
    80000ae8:	ec06                	sd	ra,24(sp)
    80000aea:	e822                	sd	s0,16(sp)
    80000aec:	e426                	sd	s1,8(sp)
    80000aee:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000af0:	00010497          	auipc	s1,0x10
    80000af4:	23048493          	addi	s1,s1,560 # 80010d20 <kmem>
    80000af8:	8526                	mv	a0,s1
    80000afa:	00000097          	auipc	ra,0x0
    80000afe:	0dc080e7          	jalr	220(ra) # 80000bd6 <acquire>
  r = kmem.freelist;
    80000b02:	6c84                	ld	s1,24(s1)
  if(r)
    80000b04:	c885                	beqz	s1,80000b34 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b06:	609c                	ld	a5,0(s1)
    80000b08:	00010517          	auipc	a0,0x10
    80000b0c:	21850513          	addi	a0,a0,536 # 80010d20 <kmem>
    80000b10:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b12:	00000097          	auipc	ra,0x0
    80000b16:	178080e7          	jalr	376(ra) # 80000c8a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b1a:	6605                	lui	a2,0x1
    80000b1c:	4595                	li	a1,5
    80000b1e:	8526                	mv	a0,s1
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	1b2080e7          	jalr	434(ra) # 80000cd2 <memset>
  return (void*)r;
}
    80000b28:	8526                	mv	a0,s1
    80000b2a:	60e2                	ld	ra,24(sp)
    80000b2c:	6442                	ld	s0,16(sp)
    80000b2e:	64a2                	ld	s1,8(sp)
    80000b30:	6105                	addi	sp,sp,32
    80000b32:	8082                	ret
  release(&kmem.lock);
    80000b34:	00010517          	auipc	a0,0x10
    80000b38:	1ec50513          	addi	a0,a0,492 # 80010d20 <kmem>
    80000b3c:	00000097          	auipc	ra,0x0
    80000b40:	14e080e7          	jalr	334(ra) # 80000c8a <release>
  if(r)
    80000b44:	b7d5                	j	80000b28 <kalloc+0x42>

0000000080000b46 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b46:	1141                	addi	sp,sp,-16
    80000b48:	e422                	sd	s0,8(sp)
    80000b4a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b4c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b52:	00053823          	sd	zero,16(a0)
}
    80000b56:	6422                	ld	s0,8(sp)
    80000b58:	0141                	addi	sp,sp,16
    80000b5a:	8082                	ret

0000000080000b5c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b5c:	411c                	lw	a5,0(a0)
    80000b5e:	e399                	bnez	a5,80000b64 <holding+0x8>
    80000b60:	4501                	li	a0,0
  return r;
}
    80000b62:	8082                	ret
{
    80000b64:	1101                	addi	sp,sp,-32
    80000b66:	ec06                	sd	ra,24(sp)
    80000b68:	e822                	sd	s0,16(sp)
    80000b6a:	e426                	sd	s1,8(sp)
    80000b6c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6e:	6904                	ld	s1,16(a0)
    80000b70:	00001097          	auipc	ra,0x1
    80000b74:	e20080e7          	jalr	-480(ra) # 80001990 <mycpu>
    80000b78:	40a48533          	sub	a0,s1,a0
    80000b7c:	00153513          	seqz	a0,a0
}
    80000b80:	60e2                	ld	ra,24(sp)
    80000b82:	6442                	ld	s0,16(sp)
    80000b84:	64a2                	ld	s1,8(sp)
    80000b86:	6105                	addi	sp,sp,32
    80000b88:	8082                	ret

0000000080000b8a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8a:	1101                	addi	sp,sp,-32
    80000b8c:	ec06                	sd	ra,24(sp)
    80000b8e:	e822                	sd	s0,16(sp)
    80000b90:	e426                	sd	s1,8(sp)
    80000b92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b94:	100024f3          	csrr	s1,sstatus
    80000b98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b9c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000ba2:	00001097          	auipc	ra,0x1
    80000ba6:	dee080e7          	jalr	-530(ra) # 80001990 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	de2080e7          	jalr	-542(ra) # 80001990 <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	2785                	addiw	a5,a5,1
    80000bba:	dd3c                	sw	a5,120(a0)
}
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
    mycpu()->intena = old;
    80000bc6:	00001097          	auipc	ra,0x1
    80000bca:	dca080e7          	jalr	-566(ra) # 80001990 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bce:	8085                	srli	s1,s1,0x1
    80000bd0:	8885                	andi	s1,s1,1
    80000bd2:	dd64                	sw	s1,124(a0)
    80000bd4:	bfe9                	j	80000bae <push_off+0x24>

0000000080000bd6 <acquire>:
{
    80000bd6:	1101                	addi	sp,sp,-32
    80000bd8:	ec06                	sd	ra,24(sp)
    80000bda:	e822                	sd	s0,16(sp)
    80000bdc:	e426                	sd	s1,8(sp)
    80000bde:	1000                	addi	s0,sp,32
    80000be0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000be2:	00000097          	auipc	ra,0x0
    80000be6:	fa8080e7          	jalr	-88(ra) # 80000b8a <push_off>
  if(holding(lk))
    80000bea:	8526                	mv	a0,s1
    80000bec:	00000097          	auipc	ra,0x0
    80000bf0:	f70080e7          	jalr	-144(ra) # 80000b5c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	4705                	li	a4,1
  if(holding(lk))
    80000bf6:	e115                	bnez	a0,80000c1a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf8:	87ba                	mv	a5,a4
    80000bfa:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfe:	2781                	sext.w	a5,a5
    80000c00:	ffe5                	bnez	a5,80000bf8 <acquire+0x22>
  __sync_synchronize();
    80000c02:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c06:	00001097          	auipc	ra,0x1
    80000c0a:	d8a080e7          	jalr	-630(ra) # 80001990 <mycpu>
    80000c0e:	e888                	sd	a0,16(s1)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    panic("acquire");
    80000c1a:	00007517          	auipc	a0,0x7
    80000c1e:	45650513          	addi	a0,a0,1110 # 80008070 <digits+0x30>
    80000c22:	00000097          	auipc	ra,0x0
    80000c26:	91c080e7          	jalr	-1764(ra) # 8000053e <panic>

0000000080000c2a <pop_off>:

void
pop_off(void)
{
    80000c2a:	1141                	addi	sp,sp,-16
    80000c2c:	e406                	sd	ra,8(sp)
    80000c2e:	e022                	sd	s0,0(sp)
    80000c30:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	d5e080e7          	jalr	-674(ra) # 80001990 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c40:	e78d                	bnez	a5,80000c6a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c42:	5d3c                	lw	a5,120(a0)
    80000c44:	02f05b63          	blez	a5,80000c7a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c48:	37fd                	addiw	a5,a5,-1
    80000c4a:	0007871b          	sext.w	a4,a5
    80000c4e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c50:	eb09                	bnez	a4,80000c62 <pop_off+0x38>
    80000c52:	5d7c                	lw	a5,124(a0)
    80000c54:	c799                	beqz	a5,80000c62 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c5a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c62:	60a2                	ld	ra,8(sp)
    80000c64:	6402                	ld	s0,0(sp)
    80000c66:	0141                	addi	sp,sp,16
    80000c68:	8082                	ret
    panic("pop_off - interruptible");
    80000c6a:	00007517          	auipc	a0,0x7
    80000c6e:	40e50513          	addi	a0,a0,1038 # 80008078 <digits+0x38>
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	8cc080e7          	jalr	-1844(ra) # 8000053e <panic>
    panic("pop_off");
    80000c7a:	00007517          	auipc	a0,0x7
    80000c7e:	41650513          	addi	a0,a0,1046 # 80008090 <digits+0x50>
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	8bc080e7          	jalr	-1860(ra) # 8000053e <panic>

0000000080000c8a <release>:
{
    80000c8a:	1101                	addi	sp,sp,-32
    80000c8c:	ec06                	sd	ra,24(sp)
    80000c8e:	e822                	sd	s0,16(sp)
    80000c90:	e426                	sd	s1,8(sp)
    80000c92:	1000                	addi	s0,sp,32
    80000c94:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	ec6080e7          	jalr	-314(ra) # 80000b5c <holding>
    80000c9e:	c115                	beqz	a0,80000cc2 <release+0x38>
  lk->cpu = 0;
    80000ca0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca8:	0f50000f          	fence	iorw,ow
    80000cac:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	f7a080e7          	jalr	-134(ra) # 80000c2a <pop_off>
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret
    panic("release");
    80000cc2:	00007517          	auipc	a0,0x7
    80000cc6:	3d650513          	addi	a0,a0,982 # 80008098 <digits+0x58>
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	874080e7          	jalr	-1932(ra) # 8000053e <panic>

0000000080000cd2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cd2:	1141                	addi	sp,sp,-16
    80000cd4:	e422                	sd	s0,8(sp)
    80000cd6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd8:	ca19                	beqz	a2,80000cee <memset+0x1c>
    80000cda:	87aa                	mv	a5,a0
    80000cdc:	1602                	slli	a2,a2,0x20
    80000cde:	9201                	srli	a2,a2,0x20
    80000ce0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce8:	0785                	addi	a5,a5,1
    80000cea:	fee79de3          	bne	a5,a4,80000ce4 <memset+0x12>
  }
  return dst;
}
    80000cee:	6422                	ld	s0,8(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e422                	sd	s0,8(sp)
    80000cf8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfa:	ca05                	beqz	a2,80000d2a <memcmp+0x36>
    80000cfc:	fff6069b          	addiw	a3,a2,-1
    80000d00:	1682                	slli	a3,a3,0x20
    80000d02:	9281                	srli	a3,a3,0x20
    80000d04:	0685                	addi	a3,a3,1
    80000d06:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d08:	00054783          	lbu	a5,0(a0)
    80000d0c:	0005c703          	lbu	a4,0(a1)
    80000d10:	00e79863          	bne	a5,a4,80000d20 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d14:	0505                	addi	a0,a0,1
    80000d16:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d18:	fed518e3          	bne	a0,a3,80000d08 <memcmp+0x14>
  }

  return 0;
    80000d1c:	4501                	li	a0,0
    80000d1e:	a019                	j	80000d24 <memcmp+0x30>
      return *s1 - *s2;
    80000d20:	40e7853b          	subw	a0,a5,a4
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  return 0;
    80000d2a:	4501                	li	a0,0
    80000d2c:	bfe5                	j	80000d24 <memcmp+0x30>

0000000080000d2e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2e:	1141                	addi	sp,sp,-16
    80000d30:	e422                	sd	s0,8(sp)
    80000d32:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d34:	c205                	beqz	a2,80000d54 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d36:	02a5e263          	bltu	a1,a0,80000d5a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d3a:	1602                	slli	a2,a2,0x20
    80000d3c:	9201                	srli	a2,a2,0x20
    80000d3e:	00c587b3          	add	a5,a1,a2
{
    80000d42:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d44:	0585                	addi	a1,a1,1
    80000d46:	0705                	addi	a4,a4,1
    80000d48:	fff5c683          	lbu	a3,-1(a1)
    80000d4c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d50:	fef59ae3          	bne	a1,a5,80000d44 <memmove+0x16>

  return dst;
}
    80000d54:	6422                	ld	s0,8(sp)
    80000d56:	0141                	addi	sp,sp,16
    80000d58:	8082                	ret
  if(s < d && s + n > d){
    80000d5a:	02061693          	slli	a3,a2,0x20
    80000d5e:	9281                	srli	a3,a3,0x20
    80000d60:	00d58733          	add	a4,a1,a3
    80000d64:	fce57be3          	bgeu	a0,a4,80000d3a <memmove+0xc>
    d += n;
    80000d68:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d6a:	fff6079b          	addiw	a5,a2,-1
    80000d6e:	1782                	slli	a5,a5,0x20
    80000d70:	9381                	srli	a5,a5,0x20
    80000d72:	fff7c793          	not	a5,a5
    80000d76:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d78:	177d                	addi	a4,a4,-1
    80000d7a:	16fd                	addi	a3,a3,-1
    80000d7c:	00074603          	lbu	a2,0(a4)
    80000d80:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d84:	fee79ae3          	bne	a5,a4,80000d78 <memmove+0x4a>
    80000d88:	b7f1                	j	80000d54 <memmove+0x26>

0000000080000d8a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d8a:	1141                	addi	sp,sp,-16
    80000d8c:	e406                	sd	ra,8(sp)
    80000d8e:	e022                	sd	s0,0(sp)
    80000d90:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d92:	00000097          	auipc	ra,0x0
    80000d96:	f9c080e7          	jalr	-100(ra) # 80000d2e <memmove>
}
    80000d9a:	60a2                	ld	ra,8(sp)
    80000d9c:	6402                	ld	s0,0(sp)
    80000d9e:	0141                	addi	sp,sp,16
    80000da0:	8082                	ret

0000000080000da2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da2:	1141                	addi	sp,sp,-16
    80000da4:	e422                	sd	s0,8(sp)
    80000da6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da8:	ce11                	beqz	a2,80000dc4 <strncmp+0x22>
    80000daa:	00054783          	lbu	a5,0(a0)
    80000dae:	cf89                	beqz	a5,80000dc8 <strncmp+0x26>
    80000db0:	0005c703          	lbu	a4,0(a1)
    80000db4:	00f71a63          	bne	a4,a5,80000dc8 <strncmp+0x26>
    n--, p++, q++;
    80000db8:	367d                	addiw	a2,a2,-1
    80000dba:	0505                	addi	a0,a0,1
    80000dbc:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dbe:	f675                	bnez	a2,80000daa <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dc0:	4501                	li	a0,0
    80000dc2:	a809                	j	80000dd4 <strncmp+0x32>
    80000dc4:	4501                	li	a0,0
    80000dc6:	a039                	j	80000dd4 <strncmp+0x32>
  if(n == 0)
    80000dc8:	ca09                	beqz	a2,80000dda <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dca:	00054503          	lbu	a0,0(a0)
    80000dce:	0005c783          	lbu	a5,0(a1)
    80000dd2:	9d1d                	subw	a0,a0,a5
}
    80000dd4:	6422                	ld	s0,8(sp)
    80000dd6:	0141                	addi	sp,sp,16
    80000dd8:	8082                	ret
    return 0;
    80000dda:	4501                	li	a0,0
    80000ddc:	bfe5                	j	80000dd4 <strncmp+0x32>

0000000080000dde <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dde:	1141                	addi	sp,sp,-16
    80000de0:	e422                	sd	s0,8(sp)
    80000de2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de4:	872a                	mv	a4,a0
    80000de6:	8832                	mv	a6,a2
    80000de8:	367d                	addiw	a2,a2,-1
    80000dea:	01005963          	blez	a6,80000dfc <strncpy+0x1e>
    80000dee:	0705                	addi	a4,a4,1
    80000df0:	0005c783          	lbu	a5,0(a1)
    80000df4:	fef70fa3          	sb	a5,-1(a4)
    80000df8:	0585                	addi	a1,a1,1
    80000dfa:	f7f5                	bnez	a5,80000de6 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dfc:	86ba                	mv	a3,a4
    80000dfe:	00c05c63          	blez	a2,80000e16 <strncpy+0x38>
    *s++ = 0;
    80000e02:	0685                	addi	a3,a3,1
    80000e04:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e08:	fff6c793          	not	a5,a3
    80000e0c:	9fb9                	addw	a5,a5,a4
    80000e0e:	010787bb          	addw	a5,a5,a6
    80000e12:	fef048e3          	bgtz	a5,80000e02 <strncpy+0x24>
  return os;
}
    80000e16:	6422                	ld	s0,8(sp)
    80000e18:	0141                	addi	sp,sp,16
    80000e1a:	8082                	ret

0000000080000e1c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e1c:	1141                	addi	sp,sp,-16
    80000e1e:	e422                	sd	s0,8(sp)
    80000e20:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e22:	02c05363          	blez	a2,80000e48 <safestrcpy+0x2c>
    80000e26:	fff6069b          	addiw	a3,a2,-1
    80000e2a:	1682                	slli	a3,a3,0x20
    80000e2c:	9281                	srli	a3,a3,0x20
    80000e2e:	96ae                	add	a3,a3,a1
    80000e30:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e32:	00d58963          	beq	a1,a3,80000e44 <safestrcpy+0x28>
    80000e36:	0585                	addi	a1,a1,1
    80000e38:	0785                	addi	a5,a5,1
    80000e3a:	fff5c703          	lbu	a4,-1(a1)
    80000e3e:	fee78fa3          	sb	a4,-1(a5)
    80000e42:	fb65                	bnez	a4,80000e32 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e44:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e48:	6422                	ld	s0,8(sp)
    80000e4a:	0141                	addi	sp,sp,16
    80000e4c:	8082                	ret

0000000080000e4e <strlen>:

int
strlen(const char *s)
{
    80000e4e:	1141                	addi	sp,sp,-16
    80000e50:	e422                	sd	s0,8(sp)
    80000e52:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e54:	00054783          	lbu	a5,0(a0)
    80000e58:	cf91                	beqz	a5,80000e74 <strlen+0x26>
    80000e5a:	0505                	addi	a0,a0,1
    80000e5c:	87aa                	mv	a5,a0
    80000e5e:	4685                	li	a3,1
    80000e60:	9e89                	subw	a3,a3,a0
    80000e62:	00f6853b          	addw	a0,a3,a5
    80000e66:	0785                	addi	a5,a5,1
    80000e68:	fff7c703          	lbu	a4,-1(a5)
    80000e6c:	fb7d                	bnez	a4,80000e62 <strlen+0x14>
    ;
  return n;
}
    80000e6e:	6422                	ld	s0,8(sp)
    80000e70:	0141                	addi	sp,sp,16
    80000e72:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e74:	4501                	li	a0,0
    80000e76:	bfe5                	j	80000e6e <strlen+0x20>

0000000080000e78 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e78:	1141                	addi	sp,sp,-16
    80000e7a:	e406                	sd	ra,8(sp)
    80000e7c:	e022                	sd	s0,0(sp)
    80000e7e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e80:	00001097          	auipc	ra,0x1
    80000e84:	b00080e7          	jalr	-1280(ra) # 80001980 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e88:	00008717          	auipc	a4,0x8
    80000e8c:	c3070713          	addi	a4,a4,-976 # 80008ab8 <started>
  if(cpuid() == 0){
    80000e90:	c139                	beqz	a0,80000ed6 <main+0x5e>
    while(started == 0)
    80000e92:	431c                	lw	a5,0(a4)
    80000e94:	2781                	sext.w	a5,a5
    80000e96:	dff5                	beqz	a5,80000e92 <main+0x1a>
      ;
    __sync_synchronize();
    80000e98:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e9c:	00001097          	auipc	ra,0x1
    80000ea0:	ae4080e7          	jalr	-1308(ra) # 80001980 <cpuid>
    80000ea4:	85aa                	mv	a1,a0
    80000ea6:	00007517          	auipc	a0,0x7
    80000eaa:	21250513          	addi	a0,a0,530 # 800080b8 <digits+0x78>
    80000eae:	fffff097          	auipc	ra,0xfffff
    80000eb2:	6da080e7          	jalr	1754(ra) # 80000588 <printf>
    kvminithart();    // turn on paging
    80000eb6:	00000097          	auipc	ra,0x0
    80000eba:	0d8080e7          	jalr	216(ra) # 80000f8e <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ebe:	00002097          	auipc	ra,0x2
    80000ec2:	9ca080e7          	jalr	-1590(ra) # 80002888 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	07a080e7          	jalr	122(ra) # 80005f40 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	05a080e7          	jalr	90(ra) # 80001f28 <scheduler>
    consoleinit();
    80000ed6:	fffff097          	auipc	ra,0xfffff
    80000eda:	57a080e7          	jalr	1402(ra) # 80000450 <consoleinit>
    printfinit();
    80000ede:	00000097          	auipc	ra,0x0
    80000ee2:	88a080e7          	jalr	-1910(ra) # 80000768 <printfinit>
    printf("\n");
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	1e250513          	addi	a0,a0,482 # 800080c8 <digits+0x88>
    80000eee:	fffff097          	auipc	ra,0xfffff
    80000ef2:	69a080e7          	jalr	1690(ra) # 80000588 <printf>
    printf("xv6 kernel is booting\n");
    80000ef6:	00007517          	auipc	a0,0x7
    80000efa:	1aa50513          	addi	a0,a0,426 # 800080a0 <digits+0x60>
    80000efe:	fffff097          	auipc	ra,0xfffff
    80000f02:	68a080e7          	jalr	1674(ra) # 80000588 <printf>
    printf("\n");
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	1c250513          	addi	a0,a0,450 # 800080c8 <digits+0x88>
    80000f0e:	fffff097          	auipc	ra,0xfffff
    80000f12:	67a080e7          	jalr	1658(ra) # 80000588 <printf>
    kinit();         // physical page allocator
    80000f16:	00000097          	auipc	ra,0x0
    80000f1a:	b94080e7          	jalr	-1132(ra) # 80000aaa <kinit>
    kvminit();       // create kernel page table
    80000f1e:	00000097          	auipc	ra,0x0
    80000f22:	326080e7          	jalr	806(ra) # 80001244 <kvminit>
    kvminithart();   // turn on paging
    80000f26:	00000097          	auipc	ra,0x0
    80000f2a:	068080e7          	jalr	104(ra) # 80000f8e <kvminithart>
    procinit();      // process table
    80000f2e:	00001097          	auipc	ra,0x1
    80000f32:	99e080e7          	jalr	-1634(ra) # 800018cc <procinit>
    trapinit();      // trap vectors
    80000f36:	00002097          	auipc	ra,0x2
    80000f3a:	92a080e7          	jalr	-1750(ra) # 80002860 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	94a080e7          	jalr	-1718(ra) # 80002888 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	fe4080e7          	jalr	-28(ra) # 80005f2a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	ff2080e7          	jalr	-14(ra) # 80005f40 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	19c080e7          	jalr	412(ra) # 800030f2 <binit>
    iinit();         // inode table
    80000f5e:	00003097          	auipc	ra,0x3
    80000f62:	840080e7          	jalr	-1984(ra) # 8000379e <iinit>
    fileinit();      // file table
    80000f66:	00003097          	auipc	ra,0x3
    80000f6a:	7de080e7          	jalr	2014(ra) # 80004744 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	0da080e7          	jalr	218(ra) # 80006048 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	d2e080e7          	jalr	-722(ra) # 80001ca4 <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	b2f72a23          	sw	a5,-1228(a4) # 80008ab8 <started>
    80000f8c:	b789                	j	80000ece <main+0x56>

0000000080000f8e <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f8e:	1141                	addi	sp,sp,-16
    80000f90:	e422                	sd	s0,8(sp)
    80000f92:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f94:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f98:	00008797          	auipc	a5,0x8
    80000f9c:	b287b783          	ld	a5,-1240(a5) # 80008ac0 <kernel_pagetable>
    80000fa0:	83b1                	srli	a5,a5,0xc
    80000fa2:	577d                	li	a4,-1
    80000fa4:	177e                	slli	a4,a4,0x3f
    80000fa6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fac:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fb0:	6422                	ld	s0,8(sp)
    80000fb2:	0141                	addi	sp,sp,16
    80000fb4:	8082                	ret

0000000080000fb6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb6:	7139                	addi	sp,sp,-64
    80000fb8:	fc06                	sd	ra,56(sp)
    80000fba:	f822                	sd	s0,48(sp)
    80000fbc:	f426                	sd	s1,40(sp)
    80000fbe:	f04a                	sd	s2,32(sp)
    80000fc0:	ec4e                	sd	s3,24(sp)
    80000fc2:	e852                	sd	s4,16(sp)
    80000fc4:	e456                	sd	s5,8(sp)
    80000fc6:	e05a                	sd	s6,0(sp)
    80000fc8:	0080                	addi	s0,sp,64
    80000fca:	84aa                	mv	s1,a0
    80000fcc:	89ae                	mv	s3,a1
    80000fce:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fd0:	57fd                	li	a5,-1
    80000fd2:	83e9                	srli	a5,a5,0x1a
    80000fd4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd8:	04b7f263          	bgeu	a5,a1,8000101c <walk+0x66>
    panic("walk");
    80000fdc:	00007517          	auipc	a0,0x7
    80000fe0:	0f450513          	addi	a0,a0,244 # 800080d0 <digits+0x90>
    80000fe4:	fffff097          	auipc	ra,0xfffff
    80000fe8:	55a080e7          	jalr	1370(ra) # 8000053e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fec:	060a8663          	beqz	s5,80001058 <walk+0xa2>
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	af6080e7          	jalr	-1290(ra) # 80000ae6 <kalloc>
    80000ff8:	84aa                	mv	s1,a0
    80000ffa:	c529                	beqz	a0,80001044 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ffc:	6605                	lui	a2,0x1
    80000ffe:	4581                	li	a1,0
    80001000:	00000097          	auipc	ra,0x0
    80001004:	cd2080e7          	jalr	-814(ra) # 80000cd2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001008:	00c4d793          	srli	a5,s1,0xc
    8000100c:	07aa                	slli	a5,a5,0xa
    8000100e:	0017e793          	ori	a5,a5,1
    80001012:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001016:	3a5d                	addiw	s4,s4,-9
    80001018:	036a0063          	beq	s4,s6,80001038 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000101c:	0149d933          	srl	s2,s3,s4
    80001020:	1ff97913          	andi	s2,s2,511
    80001024:	090e                	slli	s2,s2,0x3
    80001026:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001028:	00093483          	ld	s1,0(s2)
    8000102c:	0014f793          	andi	a5,s1,1
    80001030:	dfd5                	beqz	a5,80000fec <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001032:	80a9                	srli	s1,s1,0xa
    80001034:	04b2                	slli	s1,s1,0xc
    80001036:	b7c5                	j	80001016 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001038:	00c9d513          	srli	a0,s3,0xc
    8000103c:	1ff57513          	andi	a0,a0,511
    80001040:	050e                	slli	a0,a0,0x3
    80001042:	9526                	add	a0,a0,s1
}
    80001044:	70e2                	ld	ra,56(sp)
    80001046:	7442                	ld	s0,48(sp)
    80001048:	74a2                	ld	s1,40(sp)
    8000104a:	7902                	ld	s2,32(sp)
    8000104c:	69e2                	ld	s3,24(sp)
    8000104e:	6a42                	ld	s4,16(sp)
    80001050:	6aa2                	ld	s5,8(sp)
    80001052:	6b02                	ld	s6,0(sp)
    80001054:	6121                	addi	sp,sp,64
    80001056:	8082                	ret
        return 0;
    80001058:	4501                	li	a0,0
    8000105a:	b7ed                	j	80001044 <walk+0x8e>

000000008000105c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000105c:	57fd                	li	a5,-1
    8000105e:	83e9                	srli	a5,a5,0x1a
    80001060:	00b7f463          	bgeu	a5,a1,80001068 <walkaddr+0xc>
    return 0;
    80001064:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001066:	8082                	ret
{
    80001068:	1141                	addi	sp,sp,-16
    8000106a:	e406                	sd	ra,8(sp)
    8000106c:	e022                	sd	s0,0(sp)
    8000106e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001070:	4601                	li	a2,0
    80001072:	00000097          	auipc	ra,0x0
    80001076:	f44080e7          	jalr	-188(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000107a:	c105                	beqz	a0,8000109a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000107c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000107e:	0117f693          	andi	a3,a5,17
    80001082:	4745                	li	a4,17
    return 0;
    80001084:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001086:	00e68663          	beq	a3,a4,80001092 <walkaddr+0x36>
}
    8000108a:	60a2                	ld	ra,8(sp)
    8000108c:	6402                	ld	s0,0(sp)
    8000108e:	0141                	addi	sp,sp,16
    80001090:	8082                	ret
  pa = PTE2PA(*pte);
    80001092:	00a7d513          	srli	a0,a5,0xa
    80001096:	0532                	slli	a0,a0,0xc
  return pa;
    80001098:	bfcd                	j	8000108a <walkaddr+0x2e>
    return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7fd                	j	8000108a <walkaddr+0x2e>

000000008000109e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000109e:	715d                	addi	sp,sp,-80
    800010a0:	e486                	sd	ra,72(sp)
    800010a2:	e0a2                	sd	s0,64(sp)
    800010a4:	fc26                	sd	s1,56(sp)
    800010a6:	f84a                	sd	s2,48(sp)
    800010a8:	f44e                	sd	s3,40(sp)
    800010aa:	f052                	sd	s4,32(sp)
    800010ac:	ec56                	sd	s5,24(sp)
    800010ae:	e85a                	sd	s6,16(sp)
    800010b0:	e45e                	sd	s7,8(sp)
    800010b2:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010b4:	c639                	beqz	a2,80001102 <mappages+0x64>
    800010b6:	8aaa                	mv	s5,a0
    800010b8:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010ba:	77fd                	lui	a5,0xfffff
    800010bc:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800010c0:	15fd                	addi	a1,a1,-1
    800010c2:	00c589b3          	add	s3,a1,a2
    800010c6:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800010ca:	8952                	mv	s2,s4
    800010cc:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d0:	6b85                	lui	s7,0x1
    800010d2:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d6:	4605                	li	a2,1
    800010d8:	85ca                	mv	a1,s2
    800010da:	8556                	mv	a0,s5
    800010dc:	00000097          	auipc	ra,0x0
    800010e0:	eda080e7          	jalr	-294(ra) # 80000fb6 <walk>
    800010e4:	cd1d                	beqz	a0,80001122 <mappages+0x84>
    if(*pte & PTE_V)
    800010e6:	611c                	ld	a5,0(a0)
    800010e8:	8b85                	andi	a5,a5,1
    800010ea:	e785                	bnez	a5,80001112 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010ec:	80b1                	srli	s1,s1,0xc
    800010ee:	04aa                	slli	s1,s1,0xa
    800010f0:	0164e4b3          	or	s1,s1,s6
    800010f4:	0014e493          	ori	s1,s1,1
    800010f8:	e104                	sd	s1,0(a0)
    if(a == last)
    800010fa:	05390063          	beq	s2,s3,8000113a <mappages+0x9c>
    a += PGSIZE;
    800010fe:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001100:	bfc9                	j	800010d2 <mappages+0x34>
    panic("mappages: size");
    80001102:	00007517          	auipc	a0,0x7
    80001106:	fd650513          	addi	a0,a0,-42 # 800080d8 <digits+0x98>
    8000110a:	fffff097          	auipc	ra,0xfffff
    8000110e:	434080e7          	jalr	1076(ra) # 8000053e <panic>
      panic("mappages: remap");
    80001112:	00007517          	auipc	a0,0x7
    80001116:	fd650513          	addi	a0,a0,-42 # 800080e8 <digits+0xa8>
    8000111a:	fffff097          	auipc	ra,0xfffff
    8000111e:	424080e7          	jalr	1060(ra) # 8000053e <panic>
      return -1;
    80001122:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001124:	60a6                	ld	ra,72(sp)
    80001126:	6406                	ld	s0,64(sp)
    80001128:	74e2                	ld	s1,56(sp)
    8000112a:	7942                	ld	s2,48(sp)
    8000112c:	79a2                	ld	s3,40(sp)
    8000112e:	7a02                	ld	s4,32(sp)
    80001130:	6ae2                	ld	s5,24(sp)
    80001132:	6b42                	ld	s6,16(sp)
    80001134:	6ba2                	ld	s7,8(sp)
    80001136:	6161                	addi	sp,sp,80
    80001138:	8082                	ret
  return 0;
    8000113a:	4501                	li	a0,0
    8000113c:	b7e5                	j	80001124 <mappages+0x86>

000000008000113e <kvmmap>:
{
    8000113e:	1141                	addi	sp,sp,-16
    80001140:	e406                	sd	ra,8(sp)
    80001142:	e022                	sd	s0,0(sp)
    80001144:	0800                	addi	s0,sp,16
    80001146:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001148:	86b2                	mv	a3,a2
    8000114a:	863e                	mv	a2,a5
    8000114c:	00000097          	auipc	ra,0x0
    80001150:	f52080e7          	jalr	-174(ra) # 8000109e <mappages>
    80001154:	e509                	bnez	a0,8000115e <kvmmap+0x20>
}
    80001156:	60a2                	ld	ra,8(sp)
    80001158:	6402                	ld	s0,0(sp)
    8000115a:	0141                	addi	sp,sp,16
    8000115c:	8082                	ret
    panic("kvmmap");
    8000115e:	00007517          	auipc	a0,0x7
    80001162:	f9a50513          	addi	a0,a0,-102 # 800080f8 <digits+0xb8>
    80001166:	fffff097          	auipc	ra,0xfffff
    8000116a:	3d8080e7          	jalr	984(ra) # 8000053e <panic>

000000008000116e <kvmmake>:
{
    8000116e:	1101                	addi	sp,sp,-32
    80001170:	ec06                	sd	ra,24(sp)
    80001172:	e822                	sd	s0,16(sp)
    80001174:	e426                	sd	s1,8(sp)
    80001176:	e04a                	sd	s2,0(sp)
    80001178:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000117a:	00000097          	auipc	ra,0x0
    8000117e:	96c080e7          	jalr	-1684(ra) # 80000ae6 <kalloc>
    80001182:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001184:	6605                	lui	a2,0x1
    80001186:	4581                	li	a1,0
    80001188:	00000097          	auipc	ra,0x0
    8000118c:	b4a080e7          	jalr	-1206(ra) # 80000cd2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001190:	4719                	li	a4,6
    80001192:	6685                	lui	a3,0x1
    80001194:	10000637          	lui	a2,0x10000
    80001198:	100005b7          	lui	a1,0x10000
    8000119c:	8526                	mv	a0,s1
    8000119e:	00000097          	auipc	ra,0x0
    800011a2:	fa0080e7          	jalr	-96(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a6:	4719                	li	a4,6
    800011a8:	6685                	lui	a3,0x1
    800011aa:	10001637          	lui	a2,0x10001
    800011ae:	100015b7          	lui	a1,0x10001
    800011b2:	8526                	mv	a0,s1
    800011b4:	00000097          	auipc	ra,0x0
    800011b8:	f8a080e7          	jalr	-118(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011bc:	4719                	li	a4,6
    800011be:	004006b7          	lui	a3,0x400
    800011c2:	0c000637          	lui	a2,0xc000
    800011c6:	0c0005b7          	lui	a1,0xc000
    800011ca:	8526                	mv	a0,s1
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f72080e7          	jalr	-142(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011d4:	00007917          	auipc	s2,0x7
    800011d8:	e2c90913          	addi	s2,s2,-468 # 80008000 <etext>
    800011dc:	4729                	li	a4,10
    800011de:	80007697          	auipc	a3,0x80007
    800011e2:	e2268693          	addi	a3,a3,-478 # 8000 <_entry-0x7fff8000>
    800011e6:	4605                	li	a2,1
    800011e8:	067e                	slli	a2,a2,0x1f
    800011ea:	85b2                	mv	a1,a2
    800011ec:	8526                	mv	a0,s1
    800011ee:	00000097          	auipc	ra,0x0
    800011f2:	f50080e7          	jalr	-176(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f6:	4719                	li	a4,6
    800011f8:	46c5                	li	a3,17
    800011fa:	06ee                	slli	a3,a3,0x1b
    800011fc:	412686b3          	sub	a3,a3,s2
    80001200:	864a                	mv	a2,s2
    80001202:	85ca                	mv	a1,s2
    80001204:	8526                	mv	a0,s1
    80001206:	00000097          	auipc	ra,0x0
    8000120a:	f38080e7          	jalr	-200(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000120e:	4729                	li	a4,10
    80001210:	6685                	lui	a3,0x1
    80001212:	00006617          	auipc	a2,0x6
    80001216:	dee60613          	addi	a2,a2,-530 # 80007000 <_trampoline>
    8000121a:	040005b7          	lui	a1,0x4000
    8000121e:	15fd                	addi	a1,a1,-1
    80001220:	05b2                	slli	a1,a1,0xc
    80001222:	8526                	mv	a0,s1
    80001224:	00000097          	auipc	ra,0x0
    80001228:	f1a080e7          	jalr	-230(ra) # 8000113e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000122c:	8526                	mv	a0,s1
    8000122e:	00000097          	auipc	ra,0x0
    80001232:	608080e7          	jalr	1544(ra) # 80001836 <proc_mapstacks>
}
    80001236:	8526                	mv	a0,s1
    80001238:	60e2                	ld	ra,24(sp)
    8000123a:	6442                	ld	s0,16(sp)
    8000123c:	64a2                	ld	s1,8(sp)
    8000123e:	6902                	ld	s2,0(sp)
    80001240:	6105                	addi	sp,sp,32
    80001242:	8082                	ret

0000000080001244 <kvminit>:
{
    80001244:	1141                	addi	sp,sp,-16
    80001246:	e406                	sd	ra,8(sp)
    80001248:	e022                	sd	s0,0(sp)
    8000124a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	f22080e7          	jalr	-222(ra) # 8000116e <kvmmake>
    80001254:	00008797          	auipc	a5,0x8
    80001258:	86a7b623          	sd	a0,-1940(a5) # 80008ac0 <kernel_pagetable>
}
    8000125c:	60a2                	ld	ra,8(sp)
    8000125e:	6402                	ld	s0,0(sp)
    80001260:	0141                	addi	sp,sp,16
    80001262:	8082                	ret

0000000080001264 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001264:	715d                	addi	sp,sp,-80
    80001266:	e486                	sd	ra,72(sp)
    80001268:	e0a2                	sd	s0,64(sp)
    8000126a:	fc26                	sd	s1,56(sp)
    8000126c:	f84a                	sd	s2,48(sp)
    8000126e:	f44e                	sd	s3,40(sp)
    80001270:	f052                	sd	s4,32(sp)
    80001272:	ec56                	sd	s5,24(sp)
    80001274:	e85a                	sd	s6,16(sp)
    80001276:	e45e                	sd	s7,8(sp)
    80001278:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000127a:	03459793          	slli	a5,a1,0x34
    8000127e:	e795                	bnez	a5,800012aa <uvmunmap+0x46>
    80001280:	8a2a                	mv	s4,a0
    80001282:	892e                	mv	s2,a1
    80001284:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001286:	0632                	slli	a2,a2,0xc
    80001288:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000128c:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000128e:	6b05                	lui	s6,0x1
    80001290:	0735e263          	bltu	a1,s3,800012f4 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001294:	60a6                	ld	ra,72(sp)
    80001296:	6406                	ld	s0,64(sp)
    80001298:	74e2                	ld	s1,56(sp)
    8000129a:	7942                	ld	s2,48(sp)
    8000129c:	79a2                	ld	s3,40(sp)
    8000129e:	7a02                	ld	s4,32(sp)
    800012a0:	6ae2                	ld	s5,24(sp)
    800012a2:	6b42                	ld	s6,16(sp)
    800012a4:	6ba2                	ld	s7,8(sp)
    800012a6:	6161                	addi	sp,sp,80
    800012a8:	8082                	ret
    panic("uvmunmap: not aligned");
    800012aa:	00007517          	auipc	a0,0x7
    800012ae:	e5650513          	addi	a0,a0,-426 # 80008100 <digits+0xc0>
    800012b2:	fffff097          	auipc	ra,0xfffff
    800012b6:	28c080e7          	jalr	652(ra) # 8000053e <panic>
      panic("uvmunmap: walk");
    800012ba:	00007517          	auipc	a0,0x7
    800012be:	e5e50513          	addi	a0,a0,-418 # 80008118 <digits+0xd8>
    800012c2:	fffff097          	auipc	ra,0xfffff
    800012c6:	27c080e7          	jalr	636(ra) # 8000053e <panic>
      panic("uvmunmap: not mapped");
    800012ca:	00007517          	auipc	a0,0x7
    800012ce:	e5e50513          	addi	a0,a0,-418 # 80008128 <digits+0xe8>
    800012d2:	fffff097          	auipc	ra,0xfffff
    800012d6:	26c080e7          	jalr	620(ra) # 8000053e <panic>
      panic("uvmunmap: not a leaf");
    800012da:	00007517          	auipc	a0,0x7
    800012de:	e6650513          	addi	a0,a0,-410 # 80008140 <digits+0x100>
    800012e2:	fffff097          	auipc	ra,0xfffff
    800012e6:	25c080e7          	jalr	604(ra) # 8000053e <panic>
    *pte = 0;
    800012ea:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ee:	995a                	add	s2,s2,s6
    800012f0:	fb3972e3          	bgeu	s2,s3,80001294 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012f4:	4601                	li	a2,0
    800012f6:	85ca                	mv	a1,s2
    800012f8:	8552                	mv	a0,s4
    800012fa:	00000097          	auipc	ra,0x0
    800012fe:	cbc080e7          	jalr	-836(ra) # 80000fb6 <walk>
    80001302:	84aa                	mv	s1,a0
    80001304:	d95d                	beqz	a0,800012ba <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001306:	6108                	ld	a0,0(a0)
    80001308:	00157793          	andi	a5,a0,1
    8000130c:	dfdd                	beqz	a5,800012ca <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000130e:	3ff57793          	andi	a5,a0,1023
    80001312:	fd7784e3          	beq	a5,s7,800012da <uvmunmap+0x76>
    if(do_free){
    80001316:	fc0a8ae3          	beqz	s5,800012ea <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000131a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000131c:	0532                	slli	a0,a0,0xc
    8000131e:	fffff097          	auipc	ra,0xfffff
    80001322:	6cc080e7          	jalr	1740(ra) # 800009ea <kfree>
    80001326:	b7d1                	j	800012ea <uvmunmap+0x86>

0000000080001328 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001328:	1101                	addi	sp,sp,-32
    8000132a:	ec06                	sd	ra,24(sp)
    8000132c:	e822                	sd	s0,16(sp)
    8000132e:	e426                	sd	s1,8(sp)
    80001330:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001332:	fffff097          	auipc	ra,0xfffff
    80001336:	7b4080e7          	jalr	1972(ra) # 80000ae6 <kalloc>
    8000133a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000133c:	c519                	beqz	a0,8000134a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000133e:	6605                	lui	a2,0x1
    80001340:	4581                	li	a1,0
    80001342:	00000097          	auipc	ra,0x0
    80001346:	990080e7          	jalr	-1648(ra) # 80000cd2 <memset>
  return pagetable;
}
    8000134a:	8526                	mv	a0,s1
    8000134c:	60e2                	ld	ra,24(sp)
    8000134e:	6442                	ld	s0,16(sp)
    80001350:	64a2                	ld	s1,8(sp)
    80001352:	6105                	addi	sp,sp,32
    80001354:	8082                	ret

0000000080001356 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001356:	7179                	addi	sp,sp,-48
    80001358:	f406                	sd	ra,40(sp)
    8000135a:	f022                	sd	s0,32(sp)
    8000135c:	ec26                	sd	s1,24(sp)
    8000135e:	e84a                	sd	s2,16(sp)
    80001360:	e44e                	sd	s3,8(sp)
    80001362:	e052                	sd	s4,0(sp)
    80001364:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001366:	6785                	lui	a5,0x1
    80001368:	04f67863          	bgeu	a2,a5,800013b8 <uvmfirst+0x62>
    8000136c:	8a2a                	mv	s4,a0
    8000136e:	89ae                	mv	s3,a1
    80001370:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	774080e7          	jalr	1908(ra) # 80000ae6 <kalloc>
    8000137a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000137c:	6605                	lui	a2,0x1
    8000137e:	4581                	li	a1,0
    80001380:	00000097          	auipc	ra,0x0
    80001384:	952080e7          	jalr	-1710(ra) # 80000cd2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001388:	4779                	li	a4,30
    8000138a:	86ca                	mv	a3,s2
    8000138c:	6605                	lui	a2,0x1
    8000138e:	4581                	li	a1,0
    80001390:	8552                	mv	a0,s4
    80001392:	00000097          	auipc	ra,0x0
    80001396:	d0c080e7          	jalr	-756(ra) # 8000109e <mappages>
  memmove(mem, src, sz);
    8000139a:	8626                	mv	a2,s1
    8000139c:	85ce                	mv	a1,s3
    8000139e:	854a                	mv	a0,s2
    800013a0:	00000097          	auipc	ra,0x0
    800013a4:	98e080e7          	jalr	-1650(ra) # 80000d2e <memmove>
}
    800013a8:	70a2                	ld	ra,40(sp)
    800013aa:	7402                	ld	s0,32(sp)
    800013ac:	64e2                	ld	s1,24(sp)
    800013ae:	6942                	ld	s2,16(sp)
    800013b0:	69a2                	ld	s3,8(sp)
    800013b2:	6a02                	ld	s4,0(sp)
    800013b4:	6145                	addi	sp,sp,48
    800013b6:	8082                	ret
    panic("uvmfirst: more than a page");
    800013b8:	00007517          	auipc	a0,0x7
    800013bc:	da050513          	addi	a0,a0,-608 # 80008158 <digits+0x118>
    800013c0:	fffff097          	auipc	ra,0xfffff
    800013c4:	17e080e7          	jalr	382(ra) # 8000053e <panic>

00000000800013c8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c8:	1101                	addi	sp,sp,-32
    800013ca:	ec06                	sd	ra,24(sp)
    800013cc:	e822                	sd	s0,16(sp)
    800013ce:	e426                	sd	s1,8(sp)
    800013d0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013d2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013d4:	00b67d63          	bgeu	a2,a1,800013ee <uvmdealloc+0x26>
    800013d8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013da:	6785                	lui	a5,0x1
    800013dc:	17fd                	addi	a5,a5,-1
    800013de:	00f60733          	add	a4,a2,a5
    800013e2:	767d                	lui	a2,0xfffff
    800013e4:	8f71                	and	a4,a4,a2
    800013e6:	97ae                	add	a5,a5,a1
    800013e8:	8ff1                	and	a5,a5,a2
    800013ea:	00f76863          	bltu	a4,a5,800013fa <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013ee:	8526                	mv	a0,s1
    800013f0:	60e2                	ld	ra,24(sp)
    800013f2:	6442                	ld	s0,16(sp)
    800013f4:	64a2                	ld	s1,8(sp)
    800013f6:	6105                	addi	sp,sp,32
    800013f8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013fa:	8f99                	sub	a5,a5,a4
    800013fc:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013fe:	4685                	li	a3,1
    80001400:	0007861b          	sext.w	a2,a5
    80001404:	85ba                	mv	a1,a4
    80001406:	00000097          	auipc	ra,0x0
    8000140a:	e5e080e7          	jalr	-418(ra) # 80001264 <uvmunmap>
    8000140e:	b7c5                	j	800013ee <uvmdealloc+0x26>

0000000080001410 <uvmalloc>:
  if(newsz < oldsz)
    80001410:	0ab66563          	bltu	a2,a1,800014ba <uvmalloc+0xaa>
{
    80001414:	7139                	addi	sp,sp,-64
    80001416:	fc06                	sd	ra,56(sp)
    80001418:	f822                	sd	s0,48(sp)
    8000141a:	f426                	sd	s1,40(sp)
    8000141c:	f04a                	sd	s2,32(sp)
    8000141e:	ec4e                	sd	s3,24(sp)
    80001420:	e852                	sd	s4,16(sp)
    80001422:	e456                	sd	s5,8(sp)
    80001424:	e05a                	sd	s6,0(sp)
    80001426:	0080                	addi	s0,sp,64
    80001428:	8aaa                	mv	s5,a0
    8000142a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000142c:	6985                	lui	s3,0x1
    8000142e:	19fd                	addi	s3,s3,-1
    80001430:	95ce                	add	a1,a1,s3
    80001432:	79fd                	lui	s3,0xfffff
    80001434:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001438:	08c9f363          	bgeu	s3,a2,800014be <uvmalloc+0xae>
    8000143c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000143e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001442:	fffff097          	auipc	ra,0xfffff
    80001446:	6a4080e7          	jalr	1700(ra) # 80000ae6 <kalloc>
    8000144a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000144c:	c51d                	beqz	a0,8000147a <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000144e:	6605                	lui	a2,0x1
    80001450:	4581                	li	a1,0
    80001452:	00000097          	auipc	ra,0x0
    80001456:	880080e7          	jalr	-1920(ra) # 80000cd2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000145a:	875a                	mv	a4,s6
    8000145c:	86a6                	mv	a3,s1
    8000145e:	6605                	lui	a2,0x1
    80001460:	85ca                	mv	a1,s2
    80001462:	8556                	mv	a0,s5
    80001464:	00000097          	auipc	ra,0x0
    80001468:	c3a080e7          	jalr	-966(ra) # 8000109e <mappages>
    8000146c:	e90d                	bnez	a0,8000149e <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000146e:	6785                	lui	a5,0x1
    80001470:	993e                	add	s2,s2,a5
    80001472:	fd4968e3          	bltu	s2,s4,80001442 <uvmalloc+0x32>
  return newsz;
    80001476:	8552                	mv	a0,s4
    80001478:	a809                	j	8000148a <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000147a:	864e                	mv	a2,s3
    8000147c:	85ca                	mv	a1,s2
    8000147e:	8556                	mv	a0,s5
    80001480:	00000097          	auipc	ra,0x0
    80001484:	f48080e7          	jalr	-184(ra) # 800013c8 <uvmdealloc>
      return 0;
    80001488:	4501                	li	a0,0
}
    8000148a:	70e2                	ld	ra,56(sp)
    8000148c:	7442                	ld	s0,48(sp)
    8000148e:	74a2                	ld	s1,40(sp)
    80001490:	7902                	ld	s2,32(sp)
    80001492:	69e2                	ld	s3,24(sp)
    80001494:	6a42                	ld	s4,16(sp)
    80001496:	6aa2                	ld	s5,8(sp)
    80001498:	6b02                	ld	s6,0(sp)
    8000149a:	6121                	addi	sp,sp,64
    8000149c:	8082                	ret
      kfree(mem);
    8000149e:	8526                	mv	a0,s1
    800014a0:	fffff097          	auipc	ra,0xfffff
    800014a4:	54a080e7          	jalr	1354(ra) # 800009ea <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a8:	864e                	mv	a2,s3
    800014aa:	85ca                	mv	a1,s2
    800014ac:	8556                	mv	a0,s5
    800014ae:	00000097          	auipc	ra,0x0
    800014b2:	f1a080e7          	jalr	-230(ra) # 800013c8 <uvmdealloc>
      return 0;
    800014b6:	4501                	li	a0,0
    800014b8:	bfc9                	j	8000148a <uvmalloc+0x7a>
    return oldsz;
    800014ba:	852e                	mv	a0,a1
}
    800014bc:	8082                	ret
  return newsz;
    800014be:	8532                	mv	a0,a2
    800014c0:	b7e9                	j	8000148a <uvmalloc+0x7a>

00000000800014c2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014c2:	7179                	addi	sp,sp,-48
    800014c4:	f406                	sd	ra,40(sp)
    800014c6:	f022                	sd	s0,32(sp)
    800014c8:	ec26                	sd	s1,24(sp)
    800014ca:	e84a                	sd	s2,16(sp)
    800014cc:	e44e                	sd	s3,8(sp)
    800014ce:	e052                	sd	s4,0(sp)
    800014d0:	1800                	addi	s0,sp,48
    800014d2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014d4:	84aa                	mv	s1,a0
    800014d6:	6905                	lui	s2,0x1
    800014d8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014da:	4985                	li	s3,1
    800014dc:	a821                	j	800014f4 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014de:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014e0:	0532                	slli	a0,a0,0xc
    800014e2:	00000097          	auipc	ra,0x0
    800014e6:	fe0080e7          	jalr	-32(ra) # 800014c2 <freewalk>
      pagetable[i] = 0;
    800014ea:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014ee:	04a1                	addi	s1,s1,8
    800014f0:	03248163          	beq	s1,s2,80001512 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014f4:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f6:	00f57793          	andi	a5,a0,15
    800014fa:	ff3782e3          	beq	a5,s3,800014de <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014fe:	8905                	andi	a0,a0,1
    80001500:	d57d                	beqz	a0,800014ee <freewalk+0x2c>
      panic("freewalk: leaf");
    80001502:	00007517          	auipc	a0,0x7
    80001506:	c7650513          	addi	a0,a0,-906 # 80008178 <digits+0x138>
    8000150a:	fffff097          	auipc	ra,0xfffff
    8000150e:	034080e7          	jalr	52(ra) # 8000053e <panic>
    }
  }
  kfree((void*)pagetable);
    80001512:	8552                	mv	a0,s4
    80001514:	fffff097          	auipc	ra,0xfffff
    80001518:	4d6080e7          	jalr	1238(ra) # 800009ea <kfree>
}
    8000151c:	70a2                	ld	ra,40(sp)
    8000151e:	7402                	ld	s0,32(sp)
    80001520:	64e2                	ld	s1,24(sp)
    80001522:	6942                	ld	s2,16(sp)
    80001524:	69a2                	ld	s3,8(sp)
    80001526:	6a02                	ld	s4,0(sp)
    80001528:	6145                	addi	sp,sp,48
    8000152a:	8082                	ret

000000008000152c <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000152c:	1101                	addi	sp,sp,-32
    8000152e:	ec06                	sd	ra,24(sp)
    80001530:	e822                	sd	s0,16(sp)
    80001532:	e426                	sd	s1,8(sp)
    80001534:	1000                	addi	s0,sp,32
    80001536:	84aa                	mv	s1,a0
  if(sz > 0)
    80001538:	e999                	bnez	a1,8000154e <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000153a:	8526                	mv	a0,s1
    8000153c:	00000097          	auipc	ra,0x0
    80001540:	f86080e7          	jalr	-122(ra) # 800014c2 <freewalk>
}
    80001544:	60e2                	ld	ra,24(sp)
    80001546:	6442                	ld	s0,16(sp)
    80001548:	64a2                	ld	s1,8(sp)
    8000154a:	6105                	addi	sp,sp,32
    8000154c:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000154e:	6605                	lui	a2,0x1
    80001550:	167d                	addi	a2,a2,-1
    80001552:	962e                	add	a2,a2,a1
    80001554:	4685                	li	a3,1
    80001556:	8231                	srli	a2,a2,0xc
    80001558:	4581                	li	a1,0
    8000155a:	00000097          	auipc	ra,0x0
    8000155e:	d0a080e7          	jalr	-758(ra) # 80001264 <uvmunmap>
    80001562:	bfe1                	j	8000153a <uvmfree+0xe>

0000000080001564 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001564:	c679                	beqz	a2,80001632 <uvmcopy+0xce>
{
    80001566:	715d                	addi	sp,sp,-80
    80001568:	e486                	sd	ra,72(sp)
    8000156a:	e0a2                	sd	s0,64(sp)
    8000156c:	fc26                	sd	s1,56(sp)
    8000156e:	f84a                	sd	s2,48(sp)
    80001570:	f44e                	sd	s3,40(sp)
    80001572:	f052                	sd	s4,32(sp)
    80001574:	ec56                	sd	s5,24(sp)
    80001576:	e85a                	sd	s6,16(sp)
    80001578:	e45e                	sd	s7,8(sp)
    8000157a:	0880                	addi	s0,sp,80
    8000157c:	8b2a                	mv	s6,a0
    8000157e:	8aae                	mv	s5,a1
    80001580:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001582:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001584:	4601                	li	a2,0
    80001586:	85ce                	mv	a1,s3
    80001588:	855a                	mv	a0,s6
    8000158a:	00000097          	auipc	ra,0x0
    8000158e:	a2c080e7          	jalr	-1492(ra) # 80000fb6 <walk>
    80001592:	c531                	beqz	a0,800015de <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001594:	6118                	ld	a4,0(a0)
    80001596:	00177793          	andi	a5,a4,1
    8000159a:	cbb1                	beqz	a5,800015ee <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000159c:	00a75593          	srli	a1,a4,0xa
    800015a0:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a4:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015a8:	fffff097          	auipc	ra,0xfffff
    800015ac:	53e080e7          	jalr	1342(ra) # 80000ae6 <kalloc>
    800015b0:	892a                	mv	s2,a0
    800015b2:	c939                	beqz	a0,80001608 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b4:	6605                	lui	a2,0x1
    800015b6:	85de                	mv	a1,s7
    800015b8:	fffff097          	auipc	ra,0xfffff
    800015bc:	776080e7          	jalr	1910(ra) # 80000d2e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015c0:	8726                	mv	a4,s1
    800015c2:	86ca                	mv	a3,s2
    800015c4:	6605                	lui	a2,0x1
    800015c6:	85ce                	mv	a1,s3
    800015c8:	8556                	mv	a0,s5
    800015ca:	00000097          	auipc	ra,0x0
    800015ce:	ad4080e7          	jalr	-1324(ra) # 8000109e <mappages>
    800015d2:	e515                	bnez	a0,800015fe <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d4:	6785                	lui	a5,0x1
    800015d6:	99be                	add	s3,s3,a5
    800015d8:	fb49e6e3          	bltu	s3,s4,80001584 <uvmcopy+0x20>
    800015dc:	a081                	j	8000161c <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015de:	00007517          	auipc	a0,0x7
    800015e2:	baa50513          	addi	a0,a0,-1110 # 80008188 <digits+0x148>
    800015e6:	fffff097          	auipc	ra,0xfffff
    800015ea:	f58080e7          	jalr	-168(ra) # 8000053e <panic>
      panic("uvmcopy: page not present");
    800015ee:	00007517          	auipc	a0,0x7
    800015f2:	bba50513          	addi	a0,a0,-1094 # 800081a8 <digits+0x168>
    800015f6:	fffff097          	auipc	ra,0xfffff
    800015fa:	f48080e7          	jalr	-184(ra) # 8000053e <panic>
      kfree(mem);
    800015fe:	854a                	mv	a0,s2
    80001600:	fffff097          	auipc	ra,0xfffff
    80001604:	3ea080e7          	jalr	1002(ra) # 800009ea <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001608:	4685                	li	a3,1
    8000160a:	00c9d613          	srli	a2,s3,0xc
    8000160e:	4581                	li	a1,0
    80001610:	8556                	mv	a0,s5
    80001612:	00000097          	auipc	ra,0x0
    80001616:	c52080e7          	jalr	-942(ra) # 80001264 <uvmunmap>
  return -1;
    8000161a:	557d                	li	a0,-1
}
    8000161c:	60a6                	ld	ra,72(sp)
    8000161e:	6406                	ld	s0,64(sp)
    80001620:	74e2                	ld	s1,56(sp)
    80001622:	7942                	ld	s2,48(sp)
    80001624:	79a2                	ld	s3,40(sp)
    80001626:	7a02                	ld	s4,32(sp)
    80001628:	6ae2                	ld	s5,24(sp)
    8000162a:	6b42                	ld	s6,16(sp)
    8000162c:	6ba2                	ld	s7,8(sp)
    8000162e:	6161                	addi	sp,sp,80
    80001630:	8082                	ret
  return 0;
    80001632:	4501                	li	a0,0
}
    80001634:	8082                	ret

0000000080001636 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001636:	1141                	addi	sp,sp,-16
    80001638:	e406                	sd	ra,8(sp)
    8000163a:	e022                	sd	s0,0(sp)
    8000163c:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000163e:	4601                	li	a2,0
    80001640:	00000097          	auipc	ra,0x0
    80001644:	976080e7          	jalr	-1674(ra) # 80000fb6 <walk>
  if(pte == 0)
    80001648:	c901                	beqz	a0,80001658 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000164a:	611c                	ld	a5,0(a0)
    8000164c:	9bbd                	andi	a5,a5,-17
    8000164e:	e11c                	sd	a5,0(a0)
}
    80001650:	60a2                	ld	ra,8(sp)
    80001652:	6402                	ld	s0,0(sp)
    80001654:	0141                	addi	sp,sp,16
    80001656:	8082                	ret
    panic("uvmclear");
    80001658:	00007517          	auipc	a0,0x7
    8000165c:	b7050513          	addi	a0,a0,-1168 # 800081c8 <digits+0x188>
    80001660:	fffff097          	auipc	ra,0xfffff
    80001664:	ede080e7          	jalr	-290(ra) # 8000053e <panic>

0000000080001668 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001668:	c6bd                	beqz	a3,800016d6 <copyout+0x6e>
{
    8000166a:	715d                	addi	sp,sp,-80
    8000166c:	e486                	sd	ra,72(sp)
    8000166e:	e0a2                	sd	s0,64(sp)
    80001670:	fc26                	sd	s1,56(sp)
    80001672:	f84a                	sd	s2,48(sp)
    80001674:	f44e                	sd	s3,40(sp)
    80001676:	f052                	sd	s4,32(sp)
    80001678:	ec56                	sd	s5,24(sp)
    8000167a:	e85a                	sd	s6,16(sp)
    8000167c:	e45e                	sd	s7,8(sp)
    8000167e:	e062                	sd	s8,0(sp)
    80001680:	0880                	addi	s0,sp,80
    80001682:	8b2a                	mv	s6,a0
    80001684:	8c2e                	mv	s8,a1
    80001686:	8a32                	mv	s4,a2
    80001688:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000168a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000168c:	6a85                	lui	s5,0x1
    8000168e:	a015                	j	800016b2 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001690:	9562                	add	a0,a0,s8
    80001692:	0004861b          	sext.w	a2,s1
    80001696:	85d2                	mv	a1,s4
    80001698:	41250533          	sub	a0,a0,s2
    8000169c:	fffff097          	auipc	ra,0xfffff
    800016a0:	692080e7          	jalr	1682(ra) # 80000d2e <memmove>

    len -= n;
    800016a4:	409989b3          	sub	s3,s3,s1
    src += n;
    800016a8:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016aa:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016ae:	02098263          	beqz	s3,800016d2 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b2:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016b6:	85ca                	mv	a1,s2
    800016b8:	855a                	mv	a0,s6
    800016ba:	00000097          	auipc	ra,0x0
    800016be:	9a2080e7          	jalr	-1630(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800016c2:	cd01                	beqz	a0,800016da <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c4:	418904b3          	sub	s1,s2,s8
    800016c8:	94d6                	add	s1,s1,s5
    if(n > len)
    800016ca:	fc99f3e3          	bgeu	s3,s1,80001690 <copyout+0x28>
    800016ce:	84ce                	mv	s1,s3
    800016d0:	b7c1                	j	80001690 <copyout+0x28>
  }
  return 0;
    800016d2:	4501                	li	a0,0
    800016d4:	a021                	j	800016dc <copyout+0x74>
    800016d6:	4501                	li	a0,0
}
    800016d8:	8082                	ret
      return -1;
    800016da:	557d                	li	a0,-1
}
    800016dc:	60a6                	ld	ra,72(sp)
    800016de:	6406                	ld	s0,64(sp)
    800016e0:	74e2                	ld	s1,56(sp)
    800016e2:	7942                	ld	s2,48(sp)
    800016e4:	79a2                	ld	s3,40(sp)
    800016e6:	7a02                	ld	s4,32(sp)
    800016e8:	6ae2                	ld	s5,24(sp)
    800016ea:	6b42                	ld	s6,16(sp)
    800016ec:	6ba2                	ld	s7,8(sp)
    800016ee:	6c02                	ld	s8,0(sp)
    800016f0:	6161                	addi	sp,sp,80
    800016f2:	8082                	ret

00000000800016f4 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f4:	caa5                	beqz	a3,80001764 <copyin+0x70>
{
    800016f6:	715d                	addi	sp,sp,-80
    800016f8:	e486                	sd	ra,72(sp)
    800016fa:	e0a2                	sd	s0,64(sp)
    800016fc:	fc26                	sd	s1,56(sp)
    800016fe:	f84a                	sd	s2,48(sp)
    80001700:	f44e                	sd	s3,40(sp)
    80001702:	f052                	sd	s4,32(sp)
    80001704:	ec56                	sd	s5,24(sp)
    80001706:	e85a                	sd	s6,16(sp)
    80001708:	e45e                	sd	s7,8(sp)
    8000170a:	e062                	sd	s8,0(sp)
    8000170c:	0880                	addi	s0,sp,80
    8000170e:	8b2a                	mv	s6,a0
    80001710:	8a2e                	mv	s4,a1
    80001712:	8c32                	mv	s8,a2
    80001714:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001716:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001718:	6a85                	lui	s5,0x1
    8000171a:	a01d                	j	80001740 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000171c:	018505b3          	add	a1,a0,s8
    80001720:	0004861b          	sext.w	a2,s1
    80001724:	412585b3          	sub	a1,a1,s2
    80001728:	8552                	mv	a0,s4
    8000172a:	fffff097          	auipc	ra,0xfffff
    8000172e:	604080e7          	jalr	1540(ra) # 80000d2e <memmove>

    len -= n;
    80001732:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001736:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001738:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000173c:	02098263          	beqz	s3,80001760 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001740:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001744:	85ca                	mv	a1,s2
    80001746:	855a                	mv	a0,s6
    80001748:	00000097          	auipc	ra,0x0
    8000174c:	914080e7          	jalr	-1772(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    80001750:	cd01                	beqz	a0,80001768 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001752:	418904b3          	sub	s1,s2,s8
    80001756:	94d6                	add	s1,s1,s5
    if(n > len)
    80001758:	fc99f2e3          	bgeu	s3,s1,8000171c <copyin+0x28>
    8000175c:	84ce                	mv	s1,s3
    8000175e:	bf7d                	j	8000171c <copyin+0x28>
  }
  return 0;
    80001760:	4501                	li	a0,0
    80001762:	a021                	j	8000176a <copyin+0x76>
    80001764:	4501                	li	a0,0
}
    80001766:	8082                	ret
      return -1;
    80001768:	557d                	li	a0,-1
}
    8000176a:	60a6                	ld	ra,72(sp)
    8000176c:	6406                	ld	s0,64(sp)
    8000176e:	74e2                	ld	s1,56(sp)
    80001770:	7942                	ld	s2,48(sp)
    80001772:	79a2                	ld	s3,40(sp)
    80001774:	7a02                	ld	s4,32(sp)
    80001776:	6ae2                	ld	s5,24(sp)
    80001778:	6b42                	ld	s6,16(sp)
    8000177a:	6ba2                	ld	s7,8(sp)
    8000177c:	6c02                	ld	s8,0(sp)
    8000177e:	6161                	addi	sp,sp,80
    80001780:	8082                	ret

0000000080001782 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001782:	c6c5                	beqz	a3,8000182a <copyinstr+0xa8>
{
    80001784:	715d                	addi	sp,sp,-80
    80001786:	e486                	sd	ra,72(sp)
    80001788:	e0a2                	sd	s0,64(sp)
    8000178a:	fc26                	sd	s1,56(sp)
    8000178c:	f84a                	sd	s2,48(sp)
    8000178e:	f44e                	sd	s3,40(sp)
    80001790:	f052                	sd	s4,32(sp)
    80001792:	ec56                	sd	s5,24(sp)
    80001794:	e85a                	sd	s6,16(sp)
    80001796:	e45e                	sd	s7,8(sp)
    80001798:	0880                	addi	s0,sp,80
    8000179a:	8a2a                	mv	s4,a0
    8000179c:	8b2e                	mv	s6,a1
    8000179e:	8bb2                	mv	s7,a2
    800017a0:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a2:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a4:	6985                	lui	s3,0x1
    800017a6:	a035                	j	800017d2 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017a8:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017ac:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017ae:	0017b793          	seqz	a5,a5
    800017b2:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b6:	60a6                	ld	ra,72(sp)
    800017b8:	6406                	ld	s0,64(sp)
    800017ba:	74e2                	ld	s1,56(sp)
    800017bc:	7942                	ld	s2,48(sp)
    800017be:	79a2                	ld	s3,40(sp)
    800017c0:	7a02                	ld	s4,32(sp)
    800017c2:	6ae2                	ld	s5,24(sp)
    800017c4:	6b42                	ld	s6,16(sp)
    800017c6:	6ba2                	ld	s7,8(sp)
    800017c8:	6161                	addi	sp,sp,80
    800017ca:	8082                	ret
    srcva = va0 + PGSIZE;
    800017cc:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d0:	c8a9                	beqz	s1,80001822 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017d2:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d6:	85ca                	mv	a1,s2
    800017d8:	8552                	mv	a0,s4
    800017da:	00000097          	auipc	ra,0x0
    800017de:	882080e7          	jalr	-1918(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800017e2:	c131                	beqz	a0,80001826 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017e4:	41790833          	sub	a6,s2,s7
    800017e8:	984e                	add	a6,a6,s3
    if(n > max)
    800017ea:	0104f363          	bgeu	s1,a6,800017f0 <copyinstr+0x6e>
    800017ee:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f0:	955e                	add	a0,a0,s7
    800017f2:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f6:	fc080be3          	beqz	a6,800017cc <copyinstr+0x4a>
    800017fa:	985a                	add	a6,a6,s6
    800017fc:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017fe:	41650633          	sub	a2,a0,s6
    80001802:	14fd                	addi	s1,s1,-1
    80001804:	9b26                	add	s6,s6,s1
    80001806:	00f60733          	add	a4,a2,a5
    8000180a:	00074703          	lbu	a4,0(a4)
    8000180e:	df49                	beqz	a4,800017a8 <copyinstr+0x26>
        *dst = *p;
    80001810:	00e78023          	sb	a4,0(a5)
      --max;
    80001814:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001818:	0785                	addi	a5,a5,1
    while(n > 0){
    8000181a:	ff0796e3          	bne	a5,a6,80001806 <copyinstr+0x84>
      dst++;
    8000181e:	8b42                	mv	s6,a6
    80001820:	b775                	j	800017cc <copyinstr+0x4a>
    80001822:	4781                	li	a5,0
    80001824:	b769                	j	800017ae <copyinstr+0x2c>
      return -1;
    80001826:	557d                	li	a0,-1
    80001828:	b779                	j	800017b6 <copyinstr+0x34>
  int got_null = 0;
    8000182a:	4781                	li	a5,0
  if(got_null){
    8000182c:	0017b793          	seqz	a5,a5
    80001830:	40f00533          	neg	a0,a5
}
    80001834:	8082                	ret

0000000080001836 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001836:	7139                	addi	sp,sp,-64
    80001838:	fc06                	sd	ra,56(sp)
    8000183a:	f822                	sd	s0,48(sp)
    8000183c:	f426                	sd	s1,40(sp)
    8000183e:	f04a                	sd	s2,32(sp)
    80001840:	ec4e                	sd	s3,24(sp)
    80001842:	e852                	sd	s4,16(sp)
    80001844:	e456                	sd	s5,8(sp)
    80001846:	e05a                	sd	s6,0(sp)
    80001848:	0080                	addi	s0,sp,64
    8000184a:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000184c:	00010497          	auipc	s1,0x10
    80001850:	92448493          	addi	s1,s1,-1756 # 80011170 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001854:	8b26                	mv	s6,s1
    80001856:	00006a97          	auipc	s5,0x6
    8000185a:	7aaa8a93          	addi	s5,s5,1962 # 80008000 <etext>
    8000185e:	04000937          	lui	s2,0x4000
    80001862:	197d                	addi	s2,s2,-1
    80001864:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001866:	00016a17          	auipc	s4,0x16
    8000186a:	90aa0a13          	addi	s4,s4,-1782 # 80017170 <tickslock>
    char *pa = kalloc();
    8000186e:	fffff097          	auipc	ra,0xfffff
    80001872:	278080e7          	jalr	632(ra) # 80000ae6 <kalloc>
    80001876:	862a                	mv	a2,a0
    if(pa == 0)
    80001878:	c131                	beqz	a0,800018bc <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    8000187a:	416485b3          	sub	a1,s1,s6
    8000187e:	859d                	srai	a1,a1,0x7
    80001880:	000ab783          	ld	a5,0(s5)
    80001884:	02f585b3          	mul	a1,a1,a5
    80001888:	2585                	addiw	a1,a1,1
    8000188a:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000188e:	4719                	li	a4,6
    80001890:	6685                	lui	a3,0x1
    80001892:	40b905b3          	sub	a1,s2,a1
    80001896:	854e                	mv	a0,s3
    80001898:	00000097          	auipc	ra,0x0
    8000189c:	8a6080e7          	jalr	-1882(ra) # 8000113e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018a0:	18048493          	addi	s1,s1,384
    800018a4:	fd4495e3          	bne	s1,s4,8000186e <proc_mapstacks+0x38>
  }
}
    800018a8:	70e2                	ld	ra,56(sp)
    800018aa:	7442                	ld	s0,48(sp)
    800018ac:	74a2                	ld	s1,40(sp)
    800018ae:	7902                	ld	s2,32(sp)
    800018b0:	69e2                	ld	s3,24(sp)
    800018b2:	6a42                	ld	s4,16(sp)
    800018b4:	6aa2                	ld	s5,8(sp)
    800018b6:	6b02                	ld	s6,0(sp)
    800018b8:	6121                	addi	sp,sp,64
    800018ba:	8082                	ret
      panic("kalloc");
    800018bc:	00007517          	auipc	a0,0x7
    800018c0:	91c50513          	addi	a0,a0,-1764 # 800081d8 <digits+0x198>
    800018c4:	fffff097          	auipc	ra,0xfffff
    800018c8:	c7a080e7          	jalr	-902(ra) # 8000053e <panic>

00000000800018cc <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018cc:	7139                	addi	sp,sp,-64
    800018ce:	fc06                	sd	ra,56(sp)
    800018d0:	f822                	sd	s0,48(sp)
    800018d2:	f426                	sd	s1,40(sp)
    800018d4:	f04a                	sd	s2,32(sp)
    800018d6:	ec4e                	sd	s3,24(sp)
    800018d8:	e852                	sd	s4,16(sp)
    800018da:	e456                	sd	s5,8(sp)
    800018dc:	e05a                	sd	s6,0(sp)
    800018de:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018e0:	00007597          	auipc	a1,0x7
    800018e4:	90058593          	addi	a1,a1,-1792 # 800081e0 <digits+0x1a0>
    800018e8:	0000f517          	auipc	a0,0xf
    800018ec:	45850513          	addi	a0,a0,1112 # 80010d40 <pid_lock>
    800018f0:	fffff097          	auipc	ra,0xfffff
    800018f4:	256080e7          	jalr	598(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f8:	00007597          	auipc	a1,0x7
    800018fc:	8f058593          	addi	a1,a1,-1808 # 800081e8 <digits+0x1a8>
    80001900:	0000f517          	auipc	a0,0xf
    80001904:	45850513          	addi	a0,a0,1112 # 80010d58 <wait_lock>
    80001908:	fffff097          	auipc	ra,0xfffff
    8000190c:	23e080e7          	jalr	574(ra) # 80000b46 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001910:	00010497          	auipc	s1,0x10
    80001914:	86048493          	addi	s1,s1,-1952 # 80011170 <proc>
      initlock(&p->lock, "proc");
    80001918:	00007b17          	auipc	s6,0x7
    8000191c:	8e0b0b13          	addi	s6,s6,-1824 # 800081f8 <digits+0x1b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001920:	8aa6                	mv	s5,s1
    80001922:	00006a17          	auipc	s4,0x6
    80001926:	6dea0a13          	addi	s4,s4,1758 # 80008000 <etext>
    8000192a:	04000937          	lui	s2,0x4000
    8000192e:	197d                	addi	s2,s2,-1
    80001930:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001932:	00016997          	auipc	s3,0x16
    80001936:	83e98993          	addi	s3,s3,-1986 # 80017170 <tickslock>
      initlock(&p->lock, "proc");
    8000193a:	85da                	mv	a1,s6
    8000193c:	8526                	mv	a0,s1
    8000193e:	fffff097          	auipc	ra,0xfffff
    80001942:	208080e7          	jalr	520(ra) # 80000b46 <initlock>
      p->state = UNUSED;
    80001946:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    8000194a:	415487b3          	sub	a5,s1,s5
    8000194e:	879d                	srai	a5,a5,0x7
    80001950:	000a3703          	ld	a4,0(s4)
    80001954:	02e787b3          	mul	a5,a5,a4
    80001958:	2785                	addiw	a5,a5,1
    8000195a:	00d7979b          	slliw	a5,a5,0xd
    8000195e:	40f907b3          	sub	a5,s2,a5
    80001962:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001964:	18048493          	addi	s1,s1,384
    80001968:	fd3499e3          	bne	s1,s3,8000193a <procinit+0x6e>
  }
}
    8000196c:	70e2                	ld	ra,56(sp)
    8000196e:	7442                	ld	s0,48(sp)
    80001970:	74a2                	ld	s1,40(sp)
    80001972:	7902                	ld	s2,32(sp)
    80001974:	69e2                	ld	s3,24(sp)
    80001976:	6a42                	ld	s4,16(sp)
    80001978:	6aa2                	ld	s5,8(sp)
    8000197a:	6b02                	ld	s6,0(sp)
    8000197c:	6121                	addi	sp,sp,64
    8000197e:	8082                	ret

0000000080001980 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001980:	1141                	addi	sp,sp,-16
    80001982:	e422                	sd	s0,8(sp)
    80001984:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001986:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001988:	2501                	sext.w	a0,a0
    8000198a:	6422                	ld	s0,8(sp)
    8000198c:	0141                	addi	sp,sp,16
    8000198e:	8082                	ret

0000000080001990 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001990:	1141                	addi	sp,sp,-16
    80001992:	e422                	sd	s0,8(sp)
    80001994:	0800                	addi	s0,sp,16
    80001996:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001998:	2781                	sext.w	a5,a5
    8000199a:	079e                	slli	a5,a5,0x7
  return c;
}
    8000199c:	0000f517          	auipc	a0,0xf
    800019a0:	3d450513          	addi	a0,a0,980 # 80010d70 <cpus>
    800019a4:	953e                	add	a0,a0,a5
    800019a6:	6422                	ld	s0,8(sp)
    800019a8:	0141                	addi	sp,sp,16
    800019aa:	8082                	ret

00000000800019ac <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019ac:	1101                	addi	sp,sp,-32
    800019ae:	ec06                	sd	ra,24(sp)
    800019b0:	e822                	sd	s0,16(sp)
    800019b2:	e426                	sd	s1,8(sp)
    800019b4:	1000                	addi	s0,sp,32
  push_off();
    800019b6:	fffff097          	auipc	ra,0xfffff
    800019ba:	1d4080e7          	jalr	468(ra) # 80000b8a <push_off>
    800019be:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019c0:	2781                	sext.w	a5,a5
    800019c2:	079e                	slli	a5,a5,0x7
    800019c4:	0000f717          	auipc	a4,0xf
    800019c8:	37c70713          	addi	a4,a4,892 # 80010d40 <pid_lock>
    800019cc:	97ba                	add	a5,a5,a4
    800019ce:	7b84                	ld	s1,48(a5)
  pop_off();
    800019d0:	fffff097          	auipc	ra,0xfffff
    800019d4:	25a080e7          	jalr	602(ra) # 80000c2a <pop_off>
  return p;
}
    800019d8:	8526                	mv	a0,s1
    800019da:	60e2                	ld	ra,24(sp)
    800019dc:	6442                	ld	s0,16(sp)
    800019de:	64a2                	ld	s1,8(sp)
    800019e0:	6105                	addi	sp,sp,32
    800019e2:	8082                	ret

00000000800019e4 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019e4:	1141                	addi	sp,sp,-16
    800019e6:	e406                	sd	ra,8(sp)
    800019e8:	e022                	sd	s0,0(sp)
    800019ea:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019ec:	00000097          	auipc	ra,0x0
    800019f0:	fc0080e7          	jalr	-64(ra) # 800019ac <myproc>
    800019f4:	fffff097          	auipc	ra,0xfffff
    800019f8:	296080e7          	jalr	662(ra) # 80000c8a <release>

  if (first) {
    800019fc:	00007797          	auipc	a5,0x7
    80001a00:	f947a783          	lw	a5,-108(a5) # 80008990 <first.1>
    80001a04:	eb89                	bnez	a5,80001a16 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a06:	00001097          	auipc	ra,0x1
    80001a0a:	e9a080e7          	jalr	-358(ra) # 800028a0 <usertrapret>
}
    80001a0e:	60a2                	ld	ra,8(sp)
    80001a10:	6402                	ld	s0,0(sp)
    80001a12:	0141                	addi	sp,sp,16
    80001a14:	8082                	ret
    first = 0;
    80001a16:	00007797          	auipc	a5,0x7
    80001a1a:	f607ad23          	sw	zero,-134(a5) # 80008990 <first.1>
    fsinit(ROOTDEV);
    80001a1e:	4505                	li	a0,1
    80001a20:	00002097          	auipc	ra,0x2
    80001a24:	cfe080e7          	jalr	-770(ra) # 8000371e <fsinit>
    80001a28:	bff9                	j	80001a06 <forkret+0x22>

0000000080001a2a <allocpid>:
{
    80001a2a:	1101                	addi	sp,sp,-32
    80001a2c:	ec06                	sd	ra,24(sp)
    80001a2e:	e822                	sd	s0,16(sp)
    80001a30:	e426                	sd	s1,8(sp)
    80001a32:	e04a                	sd	s2,0(sp)
    80001a34:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a36:	0000f917          	auipc	s2,0xf
    80001a3a:	30a90913          	addi	s2,s2,778 # 80010d40 <pid_lock>
    80001a3e:	854a                	mv	a0,s2
    80001a40:	fffff097          	auipc	ra,0xfffff
    80001a44:	196080e7          	jalr	406(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001a48:	00007797          	auipc	a5,0x7
    80001a4c:	f4c78793          	addi	a5,a5,-180 # 80008994 <nextpid>
    80001a50:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a52:	0014871b          	addiw	a4,s1,1
    80001a56:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a58:	854a                	mv	a0,s2
    80001a5a:	fffff097          	auipc	ra,0xfffff
    80001a5e:	230080e7          	jalr	560(ra) # 80000c8a <release>
}
    80001a62:	8526                	mv	a0,s1
    80001a64:	60e2                	ld	ra,24(sp)
    80001a66:	6442                	ld	s0,16(sp)
    80001a68:	64a2                	ld	s1,8(sp)
    80001a6a:	6902                	ld	s2,0(sp)
    80001a6c:	6105                	addi	sp,sp,32
    80001a6e:	8082                	ret

0000000080001a70 <proc_pagetable>:
{
    80001a70:	1101                	addi	sp,sp,-32
    80001a72:	ec06                	sd	ra,24(sp)
    80001a74:	e822                	sd	s0,16(sp)
    80001a76:	e426                	sd	s1,8(sp)
    80001a78:	e04a                	sd	s2,0(sp)
    80001a7a:	1000                	addi	s0,sp,32
    80001a7c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a7e:	00000097          	auipc	ra,0x0
    80001a82:	8aa080e7          	jalr	-1878(ra) # 80001328 <uvmcreate>
    80001a86:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a88:	c121                	beqz	a0,80001ac8 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a8a:	4729                	li	a4,10
    80001a8c:	00005697          	auipc	a3,0x5
    80001a90:	57468693          	addi	a3,a3,1396 # 80007000 <_trampoline>
    80001a94:	6605                	lui	a2,0x1
    80001a96:	040005b7          	lui	a1,0x4000
    80001a9a:	15fd                	addi	a1,a1,-1
    80001a9c:	05b2                	slli	a1,a1,0xc
    80001a9e:	fffff097          	auipc	ra,0xfffff
    80001aa2:	600080e7          	jalr	1536(ra) # 8000109e <mappages>
    80001aa6:	02054863          	bltz	a0,80001ad6 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001aaa:	4719                	li	a4,6
    80001aac:	05893683          	ld	a3,88(s2)
    80001ab0:	6605                	lui	a2,0x1
    80001ab2:	020005b7          	lui	a1,0x2000
    80001ab6:	15fd                	addi	a1,a1,-1
    80001ab8:	05b6                	slli	a1,a1,0xd
    80001aba:	8526                	mv	a0,s1
    80001abc:	fffff097          	auipc	ra,0xfffff
    80001ac0:	5e2080e7          	jalr	1506(ra) # 8000109e <mappages>
    80001ac4:	02054163          	bltz	a0,80001ae6 <proc_pagetable+0x76>
}
    80001ac8:	8526                	mv	a0,s1
    80001aca:	60e2                	ld	ra,24(sp)
    80001acc:	6442                	ld	s0,16(sp)
    80001ace:	64a2                	ld	s1,8(sp)
    80001ad0:	6902                	ld	s2,0(sp)
    80001ad2:	6105                	addi	sp,sp,32
    80001ad4:	8082                	ret
    uvmfree(pagetable, 0);
    80001ad6:	4581                	li	a1,0
    80001ad8:	8526                	mv	a0,s1
    80001ada:	00000097          	auipc	ra,0x0
    80001ade:	a52080e7          	jalr	-1454(ra) # 8000152c <uvmfree>
    return 0;
    80001ae2:	4481                	li	s1,0
    80001ae4:	b7d5                	j	80001ac8 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ae6:	4681                	li	a3,0
    80001ae8:	4605                	li	a2,1
    80001aea:	040005b7          	lui	a1,0x4000
    80001aee:	15fd                	addi	a1,a1,-1
    80001af0:	05b2                	slli	a1,a1,0xc
    80001af2:	8526                	mv	a0,s1
    80001af4:	fffff097          	auipc	ra,0xfffff
    80001af8:	770080e7          	jalr	1904(ra) # 80001264 <uvmunmap>
    uvmfree(pagetable, 0);
    80001afc:	4581                	li	a1,0
    80001afe:	8526                	mv	a0,s1
    80001b00:	00000097          	auipc	ra,0x0
    80001b04:	a2c080e7          	jalr	-1492(ra) # 8000152c <uvmfree>
    return 0;
    80001b08:	4481                	li	s1,0
    80001b0a:	bf7d                	j	80001ac8 <proc_pagetable+0x58>

0000000080001b0c <proc_freepagetable>:
{
    80001b0c:	1101                	addi	sp,sp,-32
    80001b0e:	ec06                	sd	ra,24(sp)
    80001b10:	e822                	sd	s0,16(sp)
    80001b12:	e426                	sd	s1,8(sp)
    80001b14:	e04a                	sd	s2,0(sp)
    80001b16:	1000                	addi	s0,sp,32
    80001b18:	84aa                	mv	s1,a0
    80001b1a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b1c:	4681                	li	a3,0
    80001b1e:	4605                	li	a2,1
    80001b20:	040005b7          	lui	a1,0x4000
    80001b24:	15fd                	addi	a1,a1,-1
    80001b26:	05b2                	slli	a1,a1,0xc
    80001b28:	fffff097          	auipc	ra,0xfffff
    80001b2c:	73c080e7          	jalr	1852(ra) # 80001264 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b30:	4681                	li	a3,0
    80001b32:	4605                	li	a2,1
    80001b34:	020005b7          	lui	a1,0x2000
    80001b38:	15fd                	addi	a1,a1,-1
    80001b3a:	05b6                	slli	a1,a1,0xd
    80001b3c:	8526                	mv	a0,s1
    80001b3e:	fffff097          	auipc	ra,0xfffff
    80001b42:	726080e7          	jalr	1830(ra) # 80001264 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b46:	85ca                	mv	a1,s2
    80001b48:	8526                	mv	a0,s1
    80001b4a:	00000097          	auipc	ra,0x0
    80001b4e:	9e2080e7          	jalr	-1566(ra) # 8000152c <uvmfree>
}
    80001b52:	60e2                	ld	ra,24(sp)
    80001b54:	6442                	ld	s0,16(sp)
    80001b56:	64a2                	ld	s1,8(sp)
    80001b58:	6902                	ld	s2,0(sp)
    80001b5a:	6105                	addi	sp,sp,32
    80001b5c:	8082                	ret

0000000080001b5e <freeproc>:
{
    80001b5e:	1101                	addi	sp,sp,-32
    80001b60:	ec06                	sd	ra,24(sp)
    80001b62:	e822                	sd	s0,16(sp)
    80001b64:	e426                	sd	s1,8(sp)
    80001b66:	1000                	addi	s0,sp,32
    80001b68:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b6a:	6d28                	ld	a0,88(a0)
    80001b6c:	c509                	beqz	a0,80001b76 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b6e:	fffff097          	auipc	ra,0xfffff
    80001b72:	e7c080e7          	jalr	-388(ra) # 800009ea <kfree>
  p->trapframe = 0;
    80001b76:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b7a:	68a8                	ld	a0,80(s1)
    80001b7c:	c511                	beqz	a0,80001b88 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b7e:	64ac                	ld	a1,72(s1)
    80001b80:	00000097          	auipc	ra,0x0
    80001b84:	f8c080e7          	jalr	-116(ra) # 80001b0c <proc_freepagetable>
  p->pagetable = 0;
    80001b88:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b8c:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b90:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b94:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b98:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b9c:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ba0:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001ba4:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001ba8:	0004ac23          	sw	zero,24(s1)
}
    80001bac:	60e2                	ld	ra,24(sp)
    80001bae:	6442                	ld	s0,16(sp)
    80001bb0:	64a2                	ld	s1,8(sp)
    80001bb2:	6105                	addi	sp,sp,32
    80001bb4:	8082                	ret

0000000080001bb6 <allocproc>:
{
    80001bb6:	1101                	addi	sp,sp,-32
    80001bb8:	ec06                	sd	ra,24(sp)
    80001bba:	e822                	sd	s0,16(sp)
    80001bbc:	e426                	sd	s1,8(sp)
    80001bbe:	e04a                	sd	s2,0(sp)
    80001bc0:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bc2:	0000f497          	auipc	s1,0xf
    80001bc6:	5ae48493          	addi	s1,s1,1454 # 80011170 <proc>
    80001bca:	00015917          	auipc	s2,0x15
    80001bce:	5a690913          	addi	s2,s2,1446 # 80017170 <tickslock>
    acquire(&p->lock);
    80001bd2:	8526                	mv	a0,s1
    80001bd4:	fffff097          	auipc	ra,0xfffff
    80001bd8:	002080e7          	jalr	2(ra) # 80000bd6 <acquire>
    if(p->state == UNUSED) {
    80001bdc:	4c9c                	lw	a5,24(s1)
    80001bde:	cf81                	beqz	a5,80001bf6 <allocproc+0x40>
      release(&p->lock);
    80001be0:	8526                	mv	a0,s1
    80001be2:	fffff097          	auipc	ra,0xfffff
    80001be6:	0a8080e7          	jalr	168(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bea:	18048493          	addi	s1,s1,384
    80001bee:	ff2492e3          	bne	s1,s2,80001bd2 <allocproc+0x1c>
  return 0;
    80001bf2:	4481                	li	s1,0
    80001bf4:	a88d                	j	80001c66 <allocproc+0xb0>
  p->pid = allocpid();
    80001bf6:	00000097          	auipc	ra,0x0
    80001bfa:	e34080e7          	jalr	-460(ra) # 80001a2a <allocpid>
    80001bfe:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c00:	4785                	li	a5,1
    80001c02:	cc9c                	sw	a5,24(s1)
  p->time_created = ticks;
    80001c04:	00007797          	auipc	a5,0x7
    80001c08:	ecc7e783          	lwu	a5,-308(a5) # 80008ad0 <ticks>
    80001c0c:	16f4bc23          	sd	a5,376(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c10:	fffff097          	auipc	ra,0xfffff
    80001c14:	ed6080e7          	jalr	-298(ra) # 80000ae6 <kalloc>
    80001c18:	892a                	mv	s2,a0
    80001c1a:	eca8                	sd	a0,88(s1)
    80001c1c:	cd21                	beqz	a0,80001c74 <allocproc+0xbe>
  p->pagetable = proc_pagetable(p);
    80001c1e:	8526                	mv	a0,s1
    80001c20:	00000097          	auipc	ra,0x0
    80001c24:	e50080e7          	jalr	-432(ra) # 80001a70 <proc_pagetable>
    80001c28:	892a                	mv	s2,a0
    80001c2a:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c2c:	c125                	beqz	a0,80001c8c <allocproc+0xd6>
  memset(&p->context, 0, sizeof(p->context));
    80001c2e:	07000613          	li	a2,112
    80001c32:	4581                	li	a1,0
    80001c34:	06048513          	addi	a0,s1,96
    80001c38:	fffff097          	auipc	ra,0xfffff
    80001c3c:	09a080e7          	jalr	154(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001c40:	00000797          	auipc	a5,0x0
    80001c44:	da478793          	addi	a5,a5,-604 # 800019e4 <forkret>
    80001c48:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c4a:	60bc                	ld	a5,64(s1)
    80001c4c:	6705                	lui	a4,0x1
    80001c4e:	97ba                	add	a5,a5,a4
    80001c50:	f4bc                	sd	a5,104(s1)
  p->rtime = 0;
    80001c52:	1604a623          	sw	zero,364(s1)
  p->etime = 0;
    80001c56:	1604aa23          	sw	zero,372(s1)
  p->ctime = ticks;
    80001c5a:	00007797          	auipc	a5,0x7
    80001c5e:	e767a783          	lw	a5,-394(a5) # 80008ad0 <ticks>
    80001c62:	16f4a823          	sw	a5,368(s1)
}
    80001c66:	8526                	mv	a0,s1
    80001c68:	60e2                	ld	ra,24(sp)
    80001c6a:	6442                	ld	s0,16(sp)
    80001c6c:	64a2                	ld	s1,8(sp)
    80001c6e:	6902                	ld	s2,0(sp)
    80001c70:	6105                	addi	sp,sp,32
    80001c72:	8082                	ret
    freeproc(p);
    80001c74:	8526                	mv	a0,s1
    80001c76:	00000097          	auipc	ra,0x0
    80001c7a:	ee8080e7          	jalr	-280(ra) # 80001b5e <freeproc>
    release(&p->lock);
    80001c7e:	8526                	mv	a0,s1
    80001c80:	fffff097          	auipc	ra,0xfffff
    80001c84:	00a080e7          	jalr	10(ra) # 80000c8a <release>
    return 0;
    80001c88:	84ca                	mv	s1,s2
    80001c8a:	bff1                	j	80001c66 <allocproc+0xb0>
    freeproc(p);
    80001c8c:	8526                	mv	a0,s1
    80001c8e:	00000097          	auipc	ra,0x0
    80001c92:	ed0080e7          	jalr	-304(ra) # 80001b5e <freeproc>
    release(&p->lock);
    80001c96:	8526                	mv	a0,s1
    80001c98:	fffff097          	auipc	ra,0xfffff
    80001c9c:	ff2080e7          	jalr	-14(ra) # 80000c8a <release>
    return 0;
    80001ca0:	84ca                	mv	s1,s2
    80001ca2:	b7d1                	j	80001c66 <allocproc+0xb0>

0000000080001ca4 <userinit>:
{
    80001ca4:	1101                	addi	sp,sp,-32
    80001ca6:	ec06                	sd	ra,24(sp)
    80001ca8:	e822                	sd	s0,16(sp)
    80001caa:	e426                	sd	s1,8(sp)
    80001cac:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cae:	00000097          	auipc	ra,0x0
    80001cb2:	f08080e7          	jalr	-248(ra) # 80001bb6 <allocproc>
    80001cb6:	84aa                	mv	s1,a0
  initproc = p;
    80001cb8:	00007797          	auipc	a5,0x7
    80001cbc:	e0a7b823          	sd	a0,-496(a5) # 80008ac8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cc0:	03400613          	li	a2,52
    80001cc4:	00007597          	auipc	a1,0x7
    80001cc8:	cdc58593          	addi	a1,a1,-804 # 800089a0 <initcode>
    80001ccc:	6928                	ld	a0,80(a0)
    80001cce:	fffff097          	auipc	ra,0xfffff
    80001cd2:	688080e7          	jalr	1672(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80001cd6:	6785                	lui	a5,0x1
    80001cd8:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cda:	6cb8                	ld	a4,88(s1)
    80001cdc:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001ce0:	6cb8                	ld	a4,88(s1)
    80001ce2:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001ce4:	4641                	li	a2,16
    80001ce6:	00006597          	auipc	a1,0x6
    80001cea:	51a58593          	addi	a1,a1,1306 # 80008200 <digits+0x1c0>
    80001cee:	15848513          	addi	a0,s1,344
    80001cf2:	fffff097          	auipc	ra,0xfffff
    80001cf6:	12a080e7          	jalr	298(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001cfa:	00006517          	auipc	a0,0x6
    80001cfe:	51650513          	addi	a0,a0,1302 # 80008210 <digits+0x1d0>
    80001d02:	00002097          	auipc	ra,0x2
    80001d06:	43e080e7          	jalr	1086(ra) # 80004140 <namei>
    80001d0a:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d0e:	478d                	li	a5,3
    80001d10:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d12:	8526                	mv	a0,s1
    80001d14:	fffff097          	auipc	ra,0xfffff
    80001d18:	f76080e7          	jalr	-138(ra) # 80000c8a <release>
}
    80001d1c:	60e2                	ld	ra,24(sp)
    80001d1e:	6442                	ld	s0,16(sp)
    80001d20:	64a2                	ld	s1,8(sp)
    80001d22:	6105                	addi	sp,sp,32
    80001d24:	8082                	ret

0000000080001d26 <growproc>:
{
    80001d26:	1101                	addi	sp,sp,-32
    80001d28:	ec06                	sd	ra,24(sp)
    80001d2a:	e822                	sd	s0,16(sp)
    80001d2c:	e426                	sd	s1,8(sp)
    80001d2e:	e04a                	sd	s2,0(sp)
    80001d30:	1000                	addi	s0,sp,32
    80001d32:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d34:	00000097          	auipc	ra,0x0
    80001d38:	c78080e7          	jalr	-904(ra) # 800019ac <myproc>
    80001d3c:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d3e:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d40:	01204c63          	bgtz	s2,80001d58 <growproc+0x32>
  } else if(n < 0){
    80001d44:	02094663          	bltz	s2,80001d70 <growproc+0x4a>
  p->sz = sz;
    80001d48:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d4a:	4501                	li	a0,0
}
    80001d4c:	60e2                	ld	ra,24(sp)
    80001d4e:	6442                	ld	s0,16(sp)
    80001d50:	64a2                	ld	s1,8(sp)
    80001d52:	6902                	ld	s2,0(sp)
    80001d54:	6105                	addi	sp,sp,32
    80001d56:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d58:	4691                	li	a3,4
    80001d5a:	00b90633          	add	a2,s2,a1
    80001d5e:	6928                	ld	a0,80(a0)
    80001d60:	fffff097          	auipc	ra,0xfffff
    80001d64:	6b0080e7          	jalr	1712(ra) # 80001410 <uvmalloc>
    80001d68:	85aa                	mv	a1,a0
    80001d6a:	fd79                	bnez	a0,80001d48 <growproc+0x22>
      return -1;
    80001d6c:	557d                	li	a0,-1
    80001d6e:	bff9                	j	80001d4c <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d70:	00b90633          	add	a2,s2,a1
    80001d74:	6928                	ld	a0,80(a0)
    80001d76:	fffff097          	auipc	ra,0xfffff
    80001d7a:	652080e7          	jalr	1618(ra) # 800013c8 <uvmdealloc>
    80001d7e:	85aa                	mv	a1,a0
    80001d80:	b7e1                	j	80001d48 <growproc+0x22>

0000000080001d82 <fork>:
{
    80001d82:	7139                	addi	sp,sp,-64
    80001d84:	fc06                	sd	ra,56(sp)
    80001d86:	f822                	sd	s0,48(sp)
    80001d88:	f426                	sd	s1,40(sp)
    80001d8a:	f04a                	sd	s2,32(sp)
    80001d8c:	ec4e                	sd	s3,24(sp)
    80001d8e:	e852                	sd	s4,16(sp)
    80001d90:	e456                	sd	s5,8(sp)
    80001d92:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d94:	00000097          	auipc	ra,0x0
    80001d98:	c18080e7          	jalr	-1000(ra) # 800019ac <myproc>
    80001d9c:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001d9e:	00000097          	auipc	ra,0x0
    80001da2:	e18080e7          	jalr	-488(ra) # 80001bb6 <allocproc>
    80001da6:	12050063          	beqz	a0,80001ec6 <fork+0x144>
    80001daa:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001dac:	048ab603          	ld	a2,72(s5)
    80001db0:	692c                	ld	a1,80(a0)
    80001db2:	050ab503          	ld	a0,80(s5)
    80001db6:	fffff097          	auipc	ra,0xfffff
    80001dba:	7ae080e7          	jalr	1966(ra) # 80001564 <uvmcopy>
    80001dbe:	04054c63          	bltz	a0,80001e16 <fork+0x94>
  np->sz = p->sz;
    80001dc2:	048ab783          	ld	a5,72(s5)
    80001dc6:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001dca:	058ab683          	ld	a3,88(s5)
    80001dce:	87b6                	mv	a5,a3
    80001dd0:	0589b703          	ld	a4,88(s3)
    80001dd4:	12068693          	addi	a3,a3,288
    80001dd8:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001ddc:	6788                	ld	a0,8(a5)
    80001dde:	6b8c                	ld	a1,16(a5)
    80001de0:	6f90                	ld	a2,24(a5)
    80001de2:	01073023          	sd	a6,0(a4)
    80001de6:	e708                	sd	a0,8(a4)
    80001de8:	eb0c                	sd	a1,16(a4)
    80001dea:	ef10                	sd	a2,24(a4)
    80001dec:	02078793          	addi	a5,a5,32
    80001df0:	02070713          	addi	a4,a4,32
    80001df4:	fed792e3          	bne	a5,a3,80001dd8 <fork+0x56>
  np->mask = p->mask;
    80001df8:	168aa783          	lw	a5,360(s5)
    80001dfc:	16f9a423          	sw	a5,360(s3)
  np->trapframe->a0 = 0;
    80001e00:	0589b783          	ld	a5,88(s3)
    80001e04:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e08:	0d0a8493          	addi	s1,s5,208
    80001e0c:	0d098913          	addi	s2,s3,208
    80001e10:	150a8a13          	addi	s4,s5,336
    80001e14:	a00d                	j	80001e36 <fork+0xb4>
    freeproc(np);
    80001e16:	854e                	mv	a0,s3
    80001e18:	00000097          	auipc	ra,0x0
    80001e1c:	d46080e7          	jalr	-698(ra) # 80001b5e <freeproc>
    release(&np->lock);
    80001e20:	854e                	mv	a0,s3
    80001e22:	fffff097          	auipc	ra,0xfffff
    80001e26:	e68080e7          	jalr	-408(ra) # 80000c8a <release>
    return -1;
    80001e2a:	597d                	li	s2,-1
    80001e2c:	a059                	j	80001eb2 <fork+0x130>
  for(i = 0; i < NOFILE; i++)
    80001e2e:	04a1                	addi	s1,s1,8
    80001e30:	0921                	addi	s2,s2,8
    80001e32:	01448b63          	beq	s1,s4,80001e48 <fork+0xc6>
    if(p->ofile[i])
    80001e36:	6088                	ld	a0,0(s1)
    80001e38:	d97d                	beqz	a0,80001e2e <fork+0xac>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e3a:	00003097          	auipc	ra,0x3
    80001e3e:	99c080e7          	jalr	-1636(ra) # 800047d6 <filedup>
    80001e42:	00a93023          	sd	a0,0(s2)
    80001e46:	b7e5                	j	80001e2e <fork+0xac>
  np->cwd = idup(p->cwd);
    80001e48:	150ab503          	ld	a0,336(s5)
    80001e4c:	00002097          	auipc	ra,0x2
    80001e50:	b10080e7          	jalr	-1264(ra) # 8000395c <idup>
    80001e54:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e58:	4641                	li	a2,16
    80001e5a:	158a8593          	addi	a1,s5,344
    80001e5e:	15898513          	addi	a0,s3,344
    80001e62:	fffff097          	auipc	ra,0xfffff
    80001e66:	fba080e7          	jalr	-70(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    80001e6a:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001e6e:	854e                	mv	a0,s3
    80001e70:	fffff097          	auipc	ra,0xfffff
    80001e74:	e1a080e7          	jalr	-486(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80001e78:	0000f497          	auipc	s1,0xf
    80001e7c:	ee048493          	addi	s1,s1,-288 # 80010d58 <wait_lock>
    80001e80:	8526                	mv	a0,s1
    80001e82:	fffff097          	auipc	ra,0xfffff
    80001e86:	d54080e7          	jalr	-684(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001e8a:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001e8e:	8526                	mv	a0,s1
    80001e90:	fffff097          	auipc	ra,0xfffff
    80001e94:	dfa080e7          	jalr	-518(ra) # 80000c8a <release>
  acquire(&np->lock);
    80001e98:	854e                	mv	a0,s3
    80001e9a:	fffff097          	auipc	ra,0xfffff
    80001e9e:	d3c080e7          	jalr	-708(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80001ea2:	478d                	li	a5,3
    80001ea4:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001ea8:	854e                	mv	a0,s3
    80001eaa:	fffff097          	auipc	ra,0xfffff
    80001eae:	de0080e7          	jalr	-544(ra) # 80000c8a <release>
}
    80001eb2:	854a                	mv	a0,s2
    80001eb4:	70e2                	ld	ra,56(sp)
    80001eb6:	7442                	ld	s0,48(sp)
    80001eb8:	74a2                	ld	s1,40(sp)
    80001eba:	7902                	ld	s2,32(sp)
    80001ebc:	69e2                	ld	s3,24(sp)
    80001ebe:	6a42                	ld	s4,16(sp)
    80001ec0:	6aa2                	ld	s5,8(sp)
    80001ec2:	6121                	addi	sp,sp,64
    80001ec4:	8082                	ret
    return -1;
    80001ec6:	597d                	li	s2,-1
    80001ec8:	b7ed                	j	80001eb2 <fork+0x130>

0000000080001eca <update_time>:
{
    80001eca:	7179                	addi	sp,sp,-48
    80001ecc:	f406                	sd	ra,40(sp)
    80001ece:	f022                	sd	s0,32(sp)
    80001ed0:	ec26                	sd	s1,24(sp)
    80001ed2:	e84a                	sd	s2,16(sp)
    80001ed4:	e44e                	sd	s3,8(sp)
    80001ed6:	1800                	addi	s0,sp,48
  for (p = proc; p < &proc[NPROC]; p++) {
    80001ed8:	0000f497          	auipc	s1,0xf
    80001edc:	29848493          	addi	s1,s1,664 # 80011170 <proc>
    if (p->state == RUNNING) {
    80001ee0:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++) {
    80001ee2:	00015917          	auipc	s2,0x15
    80001ee6:	28e90913          	addi	s2,s2,654 # 80017170 <tickslock>
    80001eea:	a811                	j	80001efe <update_time+0x34>
    release(&p->lock); 
    80001eec:	8526                	mv	a0,s1
    80001eee:	fffff097          	auipc	ra,0xfffff
    80001ef2:	d9c080e7          	jalr	-612(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001ef6:	18048493          	addi	s1,s1,384
    80001efa:	03248063          	beq	s1,s2,80001f1a <update_time+0x50>
    acquire(&p->lock);
    80001efe:	8526                	mv	a0,s1
    80001f00:	fffff097          	auipc	ra,0xfffff
    80001f04:	cd6080e7          	jalr	-810(ra) # 80000bd6 <acquire>
    if (p->state == RUNNING) {
    80001f08:	4c9c                	lw	a5,24(s1)
    80001f0a:	ff3791e3          	bne	a5,s3,80001eec <update_time+0x22>
      p->rtime++;
    80001f0e:	16c4a783          	lw	a5,364(s1)
    80001f12:	2785                	addiw	a5,a5,1
    80001f14:	16f4a623          	sw	a5,364(s1)
    80001f18:	bfd1                	j	80001eec <update_time+0x22>
}
    80001f1a:	70a2                	ld	ra,40(sp)
    80001f1c:	7402                	ld	s0,32(sp)
    80001f1e:	64e2                	ld	s1,24(sp)
    80001f20:	6942                	ld	s2,16(sp)
    80001f22:	69a2                	ld	s3,8(sp)
    80001f24:	6145                	addi	sp,sp,48
    80001f26:	8082                	ret

0000000080001f28 <scheduler>:
{
    80001f28:	7159                	addi	sp,sp,-112
    80001f2a:	f486                	sd	ra,104(sp)
    80001f2c:	f0a2                	sd	s0,96(sp)
    80001f2e:	eca6                	sd	s1,88(sp)
    80001f30:	e8ca                	sd	s2,80(sp)
    80001f32:	e4ce                	sd	s3,72(sp)
    80001f34:	e0d2                	sd	s4,64(sp)
    80001f36:	fc56                	sd	s5,56(sp)
    80001f38:	f85a                	sd	s6,48(sp)
    80001f3a:	f45e                	sd	s7,40(sp)
    80001f3c:	f062                	sd	s8,32(sp)
    80001f3e:	ec66                	sd	s9,24(sp)
    80001f40:	e86a                	sd	s10,16(sp)
    80001f42:	e46e                	sd	s11,8(sp)
    80001f44:	1880                	addi	s0,sp,112
    80001f46:	8792                	mv	a5,tp
  int id = r_tp();
    80001f48:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f4a:	00779d13          	slli	s10,a5,0x7
    80001f4e:	0000f717          	auipc	a4,0xf
    80001f52:	df270713          	addi	a4,a4,-526 # 80010d40 <pid_lock>
    80001f56:	976a                	add	a4,a4,s10
    80001f58:	02073823          	sd	zero,48(a4)
      swtch(&c->context, &first_proc->context);
    80001f5c:	0000f717          	auipc	a4,0xf
    80001f60:	e1c70713          	addi	a4,a4,-484 # 80010d78 <cpus+0x8>
    80001f64:	9d3a                	add	s10,s10,a4
    first_proc = 0;
    80001f66:	4c81                	li	s9,0
      if(p->state == RUNNABLE) {
    80001f68:	4b0d                	li	s6,3
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f6a:	00015b97          	auipc	s7,0x15
    80001f6e:	206b8b93          	addi	s7,s7,518 # 80017170 <tickslock>
      first_proc->state = RUNNING;
    80001f72:	4d91                	li	s11,4
      c->proc = first_proc;
    80001f74:	079e                	slli	a5,a5,0x7
    80001f76:	0000fc17          	auipc	s8,0xf
    80001f7a:	dcac0c13          	addi	s8,s8,-566 # 80010d40 <pid_lock>
    80001f7e:	9c3e                	add	s8,s8,a5
    80001f80:	a051                	j	80002004 <scheduler+0xdc>
            release(&first_proc->lock);
    80001f82:	8556                	mv	a0,s5
    80001f84:	fffff097          	auipc	ra,0xfffff
    80001f88:	d06080e7          	jalr	-762(ra) # 80000c8a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f8c:	0579fa63          	bgeu	s3,s7,80001fe0 <scheduler+0xb8>
    80001f90:	8ad2                	mv	s5,s4
    80001f92:	a801                	j	80001fa2 <scheduler+0x7a>
      release(&p->lock);
    80001f94:	8526                	mv	a0,s1
    80001f96:	fffff097          	auipc	ra,0xfffff
    80001f9a:	cf4080e7          	jalr	-780(ra) # 80000c8a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f9e:	09797363          	bgeu	s2,s7,80002024 <scheduler+0xfc>
    80001fa2:	18048493          	addi	s1,s1,384
    80001fa6:	18090913          	addi	s2,s2,384
    80001faa:	8a26                	mv	s4,s1
      acquire(&p->lock);
    80001fac:	8526                	mv	a0,s1
    80001fae:	fffff097          	auipc	ra,0xfffff
    80001fb2:	c28080e7          	jalr	-984(ra) # 80000bd6 <acquire>
      if(p->state == RUNNABLE) {
    80001fb6:	89ca                	mv	s3,s2
    80001fb8:	e9892783          	lw	a5,-360(s2)
    80001fbc:	fd679ce3          	bne	a5,s6,80001f94 <scheduler+0x6c>
        if(!first_proc || p->time_created < first_proc->time_created){
    80001fc0:	fc0a86e3          	beqz	s5,80001f8c <scheduler+0x64>
    80001fc4:	ff893703          	ld	a4,-8(s2)
    80001fc8:	178ab783          	ld	a5,376(s5)
    80001fcc:	faf76be3          	bltu	a4,a5,80001f82 <scheduler+0x5a>
      release(&p->lock);
    80001fd0:	8526                	mv	a0,s1
    80001fd2:	fffff097          	auipc	ra,0xfffff
    80001fd6:	cb8080e7          	jalr	-840(ra) # 80000c8a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fda:	fd7964e3          	bltu	s2,s7,80001fa2 <scheduler+0x7a>
    80001fde:	8a56                	mv	s4,s5
      first_proc->state = RUNNING;
    80001fe0:	01ba2c23          	sw	s11,24(s4)
      c->proc = first_proc;
    80001fe4:	034c3823          	sd	s4,48(s8)
      swtch(&c->context, &first_proc->context);
    80001fe8:	060a0593          	addi	a1,s4,96
    80001fec:	856a                	mv	a0,s10
    80001fee:	00001097          	auipc	ra,0x1
    80001ff2:	808080e7          	jalr	-2040(ra) # 800027f6 <swtch>
      c->proc = 0;
    80001ff6:	020c3823          	sd	zero,48(s8)
      release(&first_proc->lock);
    80001ffa:	8552                	mv	a0,s4
    80001ffc:	fffff097          	auipc	ra,0xfffff
    80002000:	c8e080e7          	jalr	-882(ra) # 80000c8a <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002004:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002008:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000200c:	10079073          	csrw	sstatus,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80002010:	0000f497          	auipc	s1,0xf
    80002014:	16048493          	addi	s1,s1,352 # 80011170 <proc>
    80002018:	0000f917          	auipc	s2,0xf
    8000201c:	2d890913          	addi	s2,s2,728 # 800112f0 <proc+0x180>
    first_proc = 0;
    80002020:	8ae6                	mv	s5,s9
    80002022:	b761                	j	80001faa <scheduler+0x82>
    if(first_proc != 0){
    80002024:	fe0a80e3          	beqz	s5,80002004 <scheduler+0xdc>
    80002028:	bf5d                	j	80001fde <scheduler+0xb6>

000000008000202a <sched>:
{
    8000202a:	7179                	addi	sp,sp,-48
    8000202c:	f406                	sd	ra,40(sp)
    8000202e:	f022                	sd	s0,32(sp)
    80002030:	ec26                	sd	s1,24(sp)
    80002032:	e84a                	sd	s2,16(sp)
    80002034:	e44e                	sd	s3,8(sp)
    80002036:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002038:	00000097          	auipc	ra,0x0
    8000203c:	974080e7          	jalr	-1676(ra) # 800019ac <myproc>
    80002040:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002042:	fffff097          	auipc	ra,0xfffff
    80002046:	b1a080e7          	jalr	-1254(ra) # 80000b5c <holding>
    8000204a:	c93d                	beqz	a0,800020c0 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000204c:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000204e:	2781                	sext.w	a5,a5
    80002050:	079e                	slli	a5,a5,0x7
    80002052:	0000f717          	auipc	a4,0xf
    80002056:	cee70713          	addi	a4,a4,-786 # 80010d40 <pid_lock>
    8000205a:	97ba                	add	a5,a5,a4
    8000205c:	0a87a703          	lw	a4,168(a5)
    80002060:	4785                	li	a5,1
    80002062:	06f71763          	bne	a4,a5,800020d0 <sched+0xa6>
  if(p->state == RUNNING)
    80002066:	4c98                	lw	a4,24(s1)
    80002068:	4791                	li	a5,4
    8000206a:	06f70b63          	beq	a4,a5,800020e0 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000206e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002072:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002074:	efb5                	bnez	a5,800020f0 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002076:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002078:	0000f917          	auipc	s2,0xf
    8000207c:	cc890913          	addi	s2,s2,-824 # 80010d40 <pid_lock>
    80002080:	2781                	sext.w	a5,a5
    80002082:	079e                	slli	a5,a5,0x7
    80002084:	97ca                	add	a5,a5,s2
    80002086:	0ac7a983          	lw	s3,172(a5)
    8000208a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000208c:	2781                	sext.w	a5,a5
    8000208e:	079e                	slli	a5,a5,0x7
    80002090:	0000f597          	auipc	a1,0xf
    80002094:	ce858593          	addi	a1,a1,-792 # 80010d78 <cpus+0x8>
    80002098:	95be                	add	a1,a1,a5
    8000209a:	06048513          	addi	a0,s1,96
    8000209e:	00000097          	auipc	ra,0x0
    800020a2:	758080e7          	jalr	1880(ra) # 800027f6 <swtch>
    800020a6:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020a8:	2781                	sext.w	a5,a5
    800020aa:	079e                	slli	a5,a5,0x7
    800020ac:	97ca                	add	a5,a5,s2
    800020ae:	0b37a623          	sw	s3,172(a5)
}
    800020b2:	70a2                	ld	ra,40(sp)
    800020b4:	7402                	ld	s0,32(sp)
    800020b6:	64e2                	ld	s1,24(sp)
    800020b8:	6942                	ld	s2,16(sp)
    800020ba:	69a2                	ld	s3,8(sp)
    800020bc:	6145                	addi	sp,sp,48
    800020be:	8082                	ret
    panic("sched p->lock");
    800020c0:	00006517          	auipc	a0,0x6
    800020c4:	15850513          	addi	a0,a0,344 # 80008218 <digits+0x1d8>
    800020c8:	ffffe097          	auipc	ra,0xffffe
    800020cc:	476080e7          	jalr	1142(ra) # 8000053e <panic>
    panic("sched locks");
    800020d0:	00006517          	auipc	a0,0x6
    800020d4:	15850513          	addi	a0,a0,344 # 80008228 <digits+0x1e8>
    800020d8:	ffffe097          	auipc	ra,0xffffe
    800020dc:	466080e7          	jalr	1126(ra) # 8000053e <panic>
    panic("sched running");
    800020e0:	00006517          	auipc	a0,0x6
    800020e4:	15850513          	addi	a0,a0,344 # 80008238 <digits+0x1f8>
    800020e8:	ffffe097          	auipc	ra,0xffffe
    800020ec:	456080e7          	jalr	1110(ra) # 8000053e <panic>
    panic("sched interruptible");
    800020f0:	00006517          	auipc	a0,0x6
    800020f4:	15850513          	addi	a0,a0,344 # 80008248 <digits+0x208>
    800020f8:	ffffe097          	auipc	ra,0xffffe
    800020fc:	446080e7          	jalr	1094(ra) # 8000053e <panic>

0000000080002100 <yield>:
{
    80002100:	1101                	addi	sp,sp,-32
    80002102:	ec06                	sd	ra,24(sp)
    80002104:	e822                	sd	s0,16(sp)
    80002106:	e426                	sd	s1,8(sp)
    80002108:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000210a:	00000097          	auipc	ra,0x0
    8000210e:	8a2080e7          	jalr	-1886(ra) # 800019ac <myproc>
    80002112:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002114:	fffff097          	auipc	ra,0xfffff
    80002118:	ac2080e7          	jalr	-1342(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    8000211c:	478d                	li	a5,3
    8000211e:	cc9c                	sw	a5,24(s1)
  sched();
    80002120:	00000097          	auipc	ra,0x0
    80002124:	f0a080e7          	jalr	-246(ra) # 8000202a <sched>
  release(&p->lock);
    80002128:	8526                	mv	a0,s1
    8000212a:	fffff097          	auipc	ra,0xfffff
    8000212e:	b60080e7          	jalr	-1184(ra) # 80000c8a <release>
}
    80002132:	60e2                	ld	ra,24(sp)
    80002134:	6442                	ld	s0,16(sp)
    80002136:	64a2                	ld	s1,8(sp)
    80002138:	6105                	addi	sp,sp,32
    8000213a:	8082                	ret

000000008000213c <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000213c:	7179                	addi	sp,sp,-48
    8000213e:	f406                	sd	ra,40(sp)
    80002140:	f022                	sd	s0,32(sp)
    80002142:	ec26                	sd	s1,24(sp)
    80002144:	e84a                	sd	s2,16(sp)
    80002146:	e44e                	sd	s3,8(sp)
    80002148:	1800                	addi	s0,sp,48
    8000214a:	89aa                	mv	s3,a0
    8000214c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000214e:	00000097          	auipc	ra,0x0
    80002152:	85e080e7          	jalr	-1954(ra) # 800019ac <myproc>
    80002156:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002158:	fffff097          	auipc	ra,0xfffff
    8000215c:	a7e080e7          	jalr	-1410(ra) # 80000bd6 <acquire>
  release(lk);
    80002160:	854a                	mv	a0,s2
    80002162:	fffff097          	auipc	ra,0xfffff
    80002166:	b28080e7          	jalr	-1240(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    8000216a:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000216e:	4789                	li	a5,2
    80002170:	cc9c                	sw	a5,24(s1)

  sched();
    80002172:	00000097          	auipc	ra,0x0
    80002176:	eb8080e7          	jalr	-328(ra) # 8000202a <sched>

  // Tidy up.
  p->chan = 0;
    8000217a:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000217e:	8526                	mv	a0,s1
    80002180:	fffff097          	auipc	ra,0xfffff
    80002184:	b0a080e7          	jalr	-1270(ra) # 80000c8a <release>
  acquire(lk);
    80002188:	854a                	mv	a0,s2
    8000218a:	fffff097          	auipc	ra,0xfffff
    8000218e:	a4c080e7          	jalr	-1460(ra) # 80000bd6 <acquire>
}
    80002192:	70a2                	ld	ra,40(sp)
    80002194:	7402                	ld	s0,32(sp)
    80002196:	64e2                	ld	s1,24(sp)
    80002198:	6942                	ld	s2,16(sp)
    8000219a:	69a2                	ld	s3,8(sp)
    8000219c:	6145                	addi	sp,sp,48
    8000219e:	8082                	ret

00000000800021a0 <waitx>:
{
    800021a0:	711d                	addi	sp,sp,-96
    800021a2:	ec86                	sd	ra,88(sp)
    800021a4:	e8a2                	sd	s0,80(sp)
    800021a6:	e4a6                	sd	s1,72(sp)
    800021a8:	e0ca                	sd	s2,64(sp)
    800021aa:	fc4e                	sd	s3,56(sp)
    800021ac:	f852                	sd	s4,48(sp)
    800021ae:	f456                	sd	s5,40(sp)
    800021b0:	f05a                	sd	s6,32(sp)
    800021b2:	ec5e                	sd	s7,24(sp)
    800021b4:	e862                	sd	s8,16(sp)
    800021b6:	e466                	sd	s9,8(sp)
    800021b8:	e06a                	sd	s10,0(sp)
    800021ba:	1080                	addi	s0,sp,96
    800021bc:	8b2a                	mv	s6,a0
    800021be:	8bae                	mv	s7,a1
    800021c0:	8c32                	mv	s8,a2
  struct proc *p = myproc();
    800021c2:	fffff097          	auipc	ra,0xfffff
    800021c6:	7ea080e7          	jalr	2026(ra) # 800019ac <myproc>
    800021ca:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800021cc:	0000f517          	auipc	a0,0xf
    800021d0:	b8c50513          	addi	a0,a0,-1140 # 80010d58 <wait_lock>
    800021d4:	fffff097          	auipc	ra,0xfffff
    800021d8:	a02080e7          	jalr	-1534(ra) # 80000bd6 <acquire>
    havekids = 0;
    800021dc:	4c81                	li	s9,0
        if(np->state == ZOMBIE){
    800021de:	4a15                	li	s4,5
        havekids = 1;
    800021e0:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    800021e2:	00015997          	auipc	s3,0x15
    800021e6:	f8e98993          	addi	s3,s3,-114 # 80017170 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021ea:	0000fd17          	auipc	s10,0xf
    800021ee:	b6ed0d13          	addi	s10,s10,-1170 # 80010d58 <wait_lock>
    havekids = 0;
    800021f2:	8766                	mv	a4,s9
    for(np = proc; np < &proc[NPROC]; np++){
    800021f4:	0000f497          	auipc	s1,0xf
    800021f8:	f7c48493          	addi	s1,s1,-132 # 80011170 <proc>
    800021fc:	a059                	j	80002282 <waitx+0xe2>
          pid = np->pid;
    800021fe:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    80002202:	16c4a703          	lw	a4,364(s1)
    80002206:	00ec2023          	sw	a4,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    8000220a:	1704a783          	lw	a5,368(s1)
    8000220e:	9f3d                	addw	a4,a4,a5
    80002210:	1744a783          	lw	a5,372(s1)
    80002214:	9f99                	subw	a5,a5,a4
    80002216:	00fba023          	sw	a5,0(s7)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000221a:	000b0e63          	beqz	s6,80002236 <waitx+0x96>
    8000221e:	4691                	li	a3,4
    80002220:	02c48613          	addi	a2,s1,44
    80002224:	85da                	mv	a1,s6
    80002226:	05093503          	ld	a0,80(s2)
    8000222a:	fffff097          	auipc	ra,0xfffff
    8000222e:	43e080e7          	jalr	1086(ra) # 80001668 <copyout>
    80002232:	02054563          	bltz	a0,8000225c <waitx+0xbc>
          freeproc(np);
    80002236:	8526                	mv	a0,s1
    80002238:	00000097          	auipc	ra,0x0
    8000223c:	926080e7          	jalr	-1754(ra) # 80001b5e <freeproc>
          release(&np->lock);
    80002240:	8526                	mv	a0,s1
    80002242:	fffff097          	auipc	ra,0xfffff
    80002246:	a48080e7          	jalr	-1464(ra) # 80000c8a <release>
          release(&wait_lock);
    8000224a:	0000f517          	auipc	a0,0xf
    8000224e:	b0e50513          	addi	a0,a0,-1266 # 80010d58 <wait_lock>
    80002252:	fffff097          	auipc	ra,0xfffff
    80002256:	a38080e7          	jalr	-1480(ra) # 80000c8a <release>
          return pid;
    8000225a:	a09d                	j	800022c0 <waitx+0x120>
            release(&np->lock);
    8000225c:	8526                	mv	a0,s1
    8000225e:	fffff097          	auipc	ra,0xfffff
    80002262:	a2c080e7          	jalr	-1492(ra) # 80000c8a <release>
            release(&wait_lock);
    80002266:	0000f517          	auipc	a0,0xf
    8000226a:	af250513          	addi	a0,a0,-1294 # 80010d58 <wait_lock>
    8000226e:	fffff097          	auipc	ra,0xfffff
    80002272:	a1c080e7          	jalr	-1508(ra) # 80000c8a <release>
            return -1;
    80002276:	59fd                	li	s3,-1
    80002278:	a0a1                	j	800022c0 <waitx+0x120>
    for(np = proc; np < &proc[NPROC]; np++){
    8000227a:	18048493          	addi	s1,s1,384
    8000227e:	03348463          	beq	s1,s3,800022a6 <waitx+0x106>
      if(np->parent == p){
    80002282:	7c9c                	ld	a5,56(s1)
    80002284:	ff279be3          	bne	a5,s2,8000227a <waitx+0xda>
        acquire(&np->lock);
    80002288:	8526                	mv	a0,s1
    8000228a:	fffff097          	auipc	ra,0xfffff
    8000228e:	94c080e7          	jalr	-1716(ra) # 80000bd6 <acquire>
        if(np->state == ZOMBIE){
    80002292:	4c9c                	lw	a5,24(s1)
    80002294:	f74785e3          	beq	a5,s4,800021fe <waitx+0x5e>
        release(&np->lock);
    80002298:	8526                	mv	a0,s1
    8000229a:	fffff097          	auipc	ra,0xfffff
    8000229e:	9f0080e7          	jalr	-1552(ra) # 80000c8a <release>
        havekids = 1;
    800022a2:	8756                	mv	a4,s5
    800022a4:	bfd9                	j	8000227a <waitx+0xda>
    if(!havekids || p->killed){
    800022a6:	c701                	beqz	a4,800022ae <waitx+0x10e>
    800022a8:	02892783          	lw	a5,40(s2)
    800022ac:	cb8d                	beqz	a5,800022de <waitx+0x13e>
      release(&wait_lock);
    800022ae:	0000f517          	auipc	a0,0xf
    800022b2:	aaa50513          	addi	a0,a0,-1366 # 80010d58 <wait_lock>
    800022b6:	fffff097          	auipc	ra,0xfffff
    800022ba:	9d4080e7          	jalr	-1580(ra) # 80000c8a <release>
      return -1;
    800022be:	59fd                	li	s3,-1
}
    800022c0:	854e                	mv	a0,s3
    800022c2:	60e6                	ld	ra,88(sp)
    800022c4:	6446                	ld	s0,80(sp)
    800022c6:	64a6                	ld	s1,72(sp)
    800022c8:	6906                	ld	s2,64(sp)
    800022ca:	79e2                	ld	s3,56(sp)
    800022cc:	7a42                	ld	s4,48(sp)
    800022ce:	7aa2                	ld	s5,40(sp)
    800022d0:	7b02                	ld	s6,32(sp)
    800022d2:	6be2                	ld	s7,24(sp)
    800022d4:	6c42                	ld	s8,16(sp)
    800022d6:	6ca2                	ld	s9,8(sp)
    800022d8:	6d02                	ld	s10,0(sp)
    800022da:	6125                	addi	sp,sp,96
    800022dc:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800022de:	85ea                	mv	a1,s10
    800022e0:	854a                	mv	a0,s2
    800022e2:	00000097          	auipc	ra,0x0
    800022e6:	e5a080e7          	jalr	-422(ra) # 8000213c <sleep>
    havekids = 0;
    800022ea:	b721                	j	800021f2 <waitx+0x52>

00000000800022ec <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800022ec:	7139                	addi	sp,sp,-64
    800022ee:	fc06                	sd	ra,56(sp)
    800022f0:	f822                	sd	s0,48(sp)
    800022f2:	f426                	sd	s1,40(sp)
    800022f4:	f04a                	sd	s2,32(sp)
    800022f6:	ec4e                	sd	s3,24(sp)
    800022f8:	e852                	sd	s4,16(sp)
    800022fa:	e456                	sd	s5,8(sp)
    800022fc:	0080                	addi	s0,sp,64
    800022fe:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002300:	0000f497          	auipc	s1,0xf
    80002304:	e7048493          	addi	s1,s1,-400 # 80011170 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002308:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000230a:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000230c:	00015917          	auipc	s2,0x15
    80002310:	e6490913          	addi	s2,s2,-412 # 80017170 <tickslock>
    80002314:	a811                	j	80002328 <wakeup+0x3c>
      }
      release(&p->lock);
    80002316:	8526                	mv	a0,s1
    80002318:	fffff097          	auipc	ra,0xfffff
    8000231c:	972080e7          	jalr	-1678(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002320:	18048493          	addi	s1,s1,384
    80002324:	03248663          	beq	s1,s2,80002350 <wakeup+0x64>
    if(p != myproc()){
    80002328:	fffff097          	auipc	ra,0xfffff
    8000232c:	684080e7          	jalr	1668(ra) # 800019ac <myproc>
    80002330:	fea488e3          	beq	s1,a0,80002320 <wakeup+0x34>
      acquire(&p->lock);
    80002334:	8526                	mv	a0,s1
    80002336:	fffff097          	auipc	ra,0xfffff
    8000233a:	8a0080e7          	jalr	-1888(ra) # 80000bd6 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000233e:	4c9c                	lw	a5,24(s1)
    80002340:	fd379be3          	bne	a5,s3,80002316 <wakeup+0x2a>
    80002344:	709c                	ld	a5,32(s1)
    80002346:	fd4798e3          	bne	a5,s4,80002316 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000234a:	0154ac23          	sw	s5,24(s1)
    8000234e:	b7e1                	j	80002316 <wakeup+0x2a>
    }
  }
}
    80002350:	70e2                	ld	ra,56(sp)
    80002352:	7442                	ld	s0,48(sp)
    80002354:	74a2                	ld	s1,40(sp)
    80002356:	7902                	ld	s2,32(sp)
    80002358:	69e2                	ld	s3,24(sp)
    8000235a:	6a42                	ld	s4,16(sp)
    8000235c:	6aa2                	ld	s5,8(sp)
    8000235e:	6121                	addi	sp,sp,64
    80002360:	8082                	ret

0000000080002362 <reparent>:
{
    80002362:	7179                	addi	sp,sp,-48
    80002364:	f406                	sd	ra,40(sp)
    80002366:	f022                	sd	s0,32(sp)
    80002368:	ec26                	sd	s1,24(sp)
    8000236a:	e84a                	sd	s2,16(sp)
    8000236c:	e44e                	sd	s3,8(sp)
    8000236e:	e052                	sd	s4,0(sp)
    80002370:	1800                	addi	s0,sp,48
    80002372:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002374:	0000f497          	auipc	s1,0xf
    80002378:	dfc48493          	addi	s1,s1,-516 # 80011170 <proc>
      pp->parent = initproc;
    8000237c:	00006a17          	auipc	s4,0x6
    80002380:	74ca0a13          	addi	s4,s4,1868 # 80008ac8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002384:	00015997          	auipc	s3,0x15
    80002388:	dec98993          	addi	s3,s3,-532 # 80017170 <tickslock>
    8000238c:	a029                	j	80002396 <reparent+0x34>
    8000238e:	18048493          	addi	s1,s1,384
    80002392:	01348d63          	beq	s1,s3,800023ac <reparent+0x4a>
    if(pp->parent == p){
    80002396:	7c9c                	ld	a5,56(s1)
    80002398:	ff279be3          	bne	a5,s2,8000238e <reparent+0x2c>
      pp->parent = initproc;
    8000239c:	000a3503          	ld	a0,0(s4)
    800023a0:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800023a2:	00000097          	auipc	ra,0x0
    800023a6:	f4a080e7          	jalr	-182(ra) # 800022ec <wakeup>
    800023aa:	b7d5                	j	8000238e <reparent+0x2c>
}
    800023ac:	70a2                	ld	ra,40(sp)
    800023ae:	7402                	ld	s0,32(sp)
    800023b0:	64e2                	ld	s1,24(sp)
    800023b2:	6942                	ld	s2,16(sp)
    800023b4:	69a2                	ld	s3,8(sp)
    800023b6:	6a02                	ld	s4,0(sp)
    800023b8:	6145                	addi	sp,sp,48
    800023ba:	8082                	ret

00000000800023bc <exit>:
{
    800023bc:	7179                	addi	sp,sp,-48
    800023be:	f406                	sd	ra,40(sp)
    800023c0:	f022                	sd	s0,32(sp)
    800023c2:	ec26                	sd	s1,24(sp)
    800023c4:	e84a                	sd	s2,16(sp)
    800023c6:	e44e                	sd	s3,8(sp)
    800023c8:	e052                	sd	s4,0(sp)
    800023ca:	1800                	addi	s0,sp,48
    800023cc:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800023ce:	fffff097          	auipc	ra,0xfffff
    800023d2:	5de080e7          	jalr	1502(ra) # 800019ac <myproc>
    800023d6:	89aa                	mv	s3,a0
  if(p == initproc)
    800023d8:	00006797          	auipc	a5,0x6
    800023dc:	6f07b783          	ld	a5,1776(a5) # 80008ac8 <initproc>
    800023e0:	0d050493          	addi	s1,a0,208
    800023e4:	15050913          	addi	s2,a0,336
    800023e8:	02a79363          	bne	a5,a0,8000240e <exit+0x52>
    panic("init exiting");
    800023ec:	00006517          	auipc	a0,0x6
    800023f0:	e7450513          	addi	a0,a0,-396 # 80008260 <digits+0x220>
    800023f4:	ffffe097          	auipc	ra,0xffffe
    800023f8:	14a080e7          	jalr	330(ra) # 8000053e <panic>
      fileclose(f);
    800023fc:	00002097          	auipc	ra,0x2
    80002400:	42c080e7          	jalr	1068(ra) # 80004828 <fileclose>
      p->ofile[fd] = 0;
    80002404:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002408:	04a1                	addi	s1,s1,8
    8000240a:	01248563          	beq	s1,s2,80002414 <exit+0x58>
    if(p->ofile[fd]){
    8000240e:	6088                	ld	a0,0(s1)
    80002410:	f575                	bnez	a0,800023fc <exit+0x40>
    80002412:	bfdd                	j	80002408 <exit+0x4c>
  begin_op();
    80002414:	00002097          	auipc	ra,0x2
    80002418:	f48080e7          	jalr	-184(ra) # 8000435c <begin_op>
  iput(p->cwd);
    8000241c:	1509b503          	ld	a0,336(s3)
    80002420:	00001097          	auipc	ra,0x1
    80002424:	734080e7          	jalr	1844(ra) # 80003b54 <iput>
  end_op();
    80002428:	00002097          	auipc	ra,0x2
    8000242c:	fb4080e7          	jalr	-76(ra) # 800043dc <end_op>
  p->cwd = 0;
    80002430:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002434:	0000f497          	auipc	s1,0xf
    80002438:	92448493          	addi	s1,s1,-1756 # 80010d58 <wait_lock>
    8000243c:	8526                	mv	a0,s1
    8000243e:	ffffe097          	auipc	ra,0xffffe
    80002442:	798080e7          	jalr	1944(ra) # 80000bd6 <acquire>
  reparent(p);
    80002446:	854e                	mv	a0,s3
    80002448:	00000097          	auipc	ra,0x0
    8000244c:	f1a080e7          	jalr	-230(ra) # 80002362 <reparent>
  wakeup(p->parent);
    80002450:	0389b503          	ld	a0,56(s3)
    80002454:	00000097          	auipc	ra,0x0
    80002458:	e98080e7          	jalr	-360(ra) # 800022ec <wakeup>
  acquire(&p->lock);
    8000245c:	854e                	mv	a0,s3
    8000245e:	ffffe097          	auipc	ra,0xffffe
    80002462:	778080e7          	jalr	1912(ra) # 80000bd6 <acquire>
  p->xstate = status;
    80002466:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000246a:	4795                	li	a5,5
    8000246c:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    80002470:	00006797          	auipc	a5,0x6
    80002474:	6607a783          	lw	a5,1632(a5) # 80008ad0 <ticks>
    80002478:	16f9aa23          	sw	a5,372(s3)
  release(&wait_lock);
    8000247c:	8526                	mv	a0,s1
    8000247e:	fffff097          	auipc	ra,0xfffff
    80002482:	80c080e7          	jalr	-2036(ra) # 80000c8a <release>
  sched();
    80002486:	00000097          	auipc	ra,0x0
    8000248a:	ba4080e7          	jalr	-1116(ra) # 8000202a <sched>
  panic("zombie exit");
    8000248e:	00006517          	auipc	a0,0x6
    80002492:	de250513          	addi	a0,a0,-542 # 80008270 <digits+0x230>
    80002496:	ffffe097          	auipc	ra,0xffffe
    8000249a:	0a8080e7          	jalr	168(ra) # 8000053e <panic>

000000008000249e <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000249e:	7179                	addi	sp,sp,-48
    800024a0:	f406                	sd	ra,40(sp)
    800024a2:	f022                	sd	s0,32(sp)
    800024a4:	ec26                	sd	s1,24(sp)
    800024a6:	e84a                	sd	s2,16(sp)
    800024a8:	e44e                	sd	s3,8(sp)
    800024aa:	1800                	addi	s0,sp,48
    800024ac:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800024ae:	0000f497          	auipc	s1,0xf
    800024b2:	cc248493          	addi	s1,s1,-830 # 80011170 <proc>
    800024b6:	00015997          	auipc	s3,0x15
    800024ba:	cba98993          	addi	s3,s3,-838 # 80017170 <tickslock>
    acquire(&p->lock);
    800024be:	8526                	mv	a0,s1
    800024c0:	ffffe097          	auipc	ra,0xffffe
    800024c4:	716080e7          	jalr	1814(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    800024c8:	589c                	lw	a5,48(s1)
    800024ca:	01278d63          	beq	a5,s2,800024e4 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800024ce:	8526                	mv	a0,s1
    800024d0:	ffffe097          	auipc	ra,0xffffe
    800024d4:	7ba080e7          	jalr	1978(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800024d8:	18048493          	addi	s1,s1,384
    800024dc:	ff3491e3          	bne	s1,s3,800024be <kill+0x20>
  }
  return -1;
    800024e0:	557d                	li	a0,-1
    800024e2:	a829                	j	800024fc <kill+0x5e>
      p->killed = 1;
    800024e4:	4785                	li	a5,1
    800024e6:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800024e8:	4c98                	lw	a4,24(s1)
    800024ea:	4789                	li	a5,2
    800024ec:	00f70f63          	beq	a4,a5,8000250a <kill+0x6c>
      release(&p->lock);
    800024f0:	8526                	mv	a0,s1
    800024f2:	ffffe097          	auipc	ra,0xffffe
    800024f6:	798080e7          	jalr	1944(ra) # 80000c8a <release>
      return 0;
    800024fa:	4501                	li	a0,0
}
    800024fc:	70a2                	ld	ra,40(sp)
    800024fe:	7402                	ld	s0,32(sp)
    80002500:	64e2                	ld	s1,24(sp)
    80002502:	6942                	ld	s2,16(sp)
    80002504:	69a2                	ld	s3,8(sp)
    80002506:	6145                	addi	sp,sp,48
    80002508:	8082                	ret
        p->state = RUNNABLE;
    8000250a:	478d                	li	a5,3
    8000250c:	cc9c                	sw	a5,24(s1)
    8000250e:	b7cd                	j	800024f0 <kill+0x52>

0000000080002510 <setkilled>:

void
setkilled(struct proc *p)
{
    80002510:	1101                	addi	sp,sp,-32
    80002512:	ec06                	sd	ra,24(sp)
    80002514:	e822                	sd	s0,16(sp)
    80002516:	e426                	sd	s1,8(sp)
    80002518:	1000                	addi	s0,sp,32
    8000251a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000251c:	ffffe097          	auipc	ra,0xffffe
    80002520:	6ba080e7          	jalr	1722(ra) # 80000bd6 <acquire>
  p->killed = 1;
    80002524:	4785                	li	a5,1
    80002526:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002528:	8526                	mv	a0,s1
    8000252a:	ffffe097          	auipc	ra,0xffffe
    8000252e:	760080e7          	jalr	1888(ra) # 80000c8a <release>
}
    80002532:	60e2                	ld	ra,24(sp)
    80002534:	6442                	ld	s0,16(sp)
    80002536:	64a2                	ld	s1,8(sp)
    80002538:	6105                	addi	sp,sp,32
    8000253a:	8082                	ret

000000008000253c <killed>:

int
killed(struct proc *p)
{
    8000253c:	1101                	addi	sp,sp,-32
    8000253e:	ec06                	sd	ra,24(sp)
    80002540:	e822                	sd	s0,16(sp)
    80002542:	e426                	sd	s1,8(sp)
    80002544:	e04a                	sd	s2,0(sp)
    80002546:	1000                	addi	s0,sp,32
    80002548:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000254a:	ffffe097          	auipc	ra,0xffffe
    8000254e:	68c080e7          	jalr	1676(ra) # 80000bd6 <acquire>
  k = p->killed;
    80002552:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002556:	8526                	mv	a0,s1
    80002558:	ffffe097          	auipc	ra,0xffffe
    8000255c:	732080e7          	jalr	1842(ra) # 80000c8a <release>
  return k;
}
    80002560:	854a                	mv	a0,s2
    80002562:	60e2                	ld	ra,24(sp)
    80002564:	6442                	ld	s0,16(sp)
    80002566:	64a2                	ld	s1,8(sp)
    80002568:	6902                	ld	s2,0(sp)
    8000256a:	6105                	addi	sp,sp,32
    8000256c:	8082                	ret

000000008000256e <wait>:
{
    8000256e:	715d                	addi	sp,sp,-80
    80002570:	e486                	sd	ra,72(sp)
    80002572:	e0a2                	sd	s0,64(sp)
    80002574:	fc26                	sd	s1,56(sp)
    80002576:	f84a                	sd	s2,48(sp)
    80002578:	f44e                	sd	s3,40(sp)
    8000257a:	f052                	sd	s4,32(sp)
    8000257c:	ec56                	sd	s5,24(sp)
    8000257e:	e85a                	sd	s6,16(sp)
    80002580:	e45e                	sd	s7,8(sp)
    80002582:	e062                	sd	s8,0(sp)
    80002584:	0880                	addi	s0,sp,80
    80002586:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002588:	fffff097          	auipc	ra,0xfffff
    8000258c:	424080e7          	jalr	1060(ra) # 800019ac <myproc>
    80002590:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002592:	0000e517          	auipc	a0,0xe
    80002596:	7c650513          	addi	a0,a0,1990 # 80010d58 <wait_lock>
    8000259a:	ffffe097          	auipc	ra,0xffffe
    8000259e:	63c080e7          	jalr	1596(ra) # 80000bd6 <acquire>
    havekids = 0;
    800025a2:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800025a4:	4a15                	li	s4,5
        havekids = 1;
    800025a6:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800025a8:	00015997          	auipc	s3,0x15
    800025ac:	bc898993          	addi	s3,s3,-1080 # 80017170 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800025b0:	0000ec17          	auipc	s8,0xe
    800025b4:	7a8c0c13          	addi	s8,s8,1960 # 80010d58 <wait_lock>
    havekids = 0;
    800025b8:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800025ba:	0000f497          	auipc	s1,0xf
    800025be:	bb648493          	addi	s1,s1,-1098 # 80011170 <proc>
    800025c2:	a0bd                	j	80002630 <wait+0xc2>
          pid = pp->pid;
    800025c4:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800025c8:	000b0e63          	beqz	s6,800025e4 <wait+0x76>
    800025cc:	4691                	li	a3,4
    800025ce:	02c48613          	addi	a2,s1,44
    800025d2:	85da                	mv	a1,s6
    800025d4:	05093503          	ld	a0,80(s2)
    800025d8:	fffff097          	auipc	ra,0xfffff
    800025dc:	090080e7          	jalr	144(ra) # 80001668 <copyout>
    800025e0:	02054563          	bltz	a0,8000260a <wait+0x9c>
          freeproc(pp);
    800025e4:	8526                	mv	a0,s1
    800025e6:	fffff097          	auipc	ra,0xfffff
    800025ea:	578080e7          	jalr	1400(ra) # 80001b5e <freeproc>
          release(&pp->lock);
    800025ee:	8526                	mv	a0,s1
    800025f0:	ffffe097          	auipc	ra,0xffffe
    800025f4:	69a080e7          	jalr	1690(ra) # 80000c8a <release>
          release(&wait_lock);
    800025f8:	0000e517          	auipc	a0,0xe
    800025fc:	76050513          	addi	a0,a0,1888 # 80010d58 <wait_lock>
    80002600:	ffffe097          	auipc	ra,0xffffe
    80002604:	68a080e7          	jalr	1674(ra) # 80000c8a <release>
          return pid;
    80002608:	a0b5                	j	80002674 <wait+0x106>
            release(&pp->lock);
    8000260a:	8526                	mv	a0,s1
    8000260c:	ffffe097          	auipc	ra,0xffffe
    80002610:	67e080e7          	jalr	1662(ra) # 80000c8a <release>
            release(&wait_lock);
    80002614:	0000e517          	auipc	a0,0xe
    80002618:	74450513          	addi	a0,a0,1860 # 80010d58 <wait_lock>
    8000261c:	ffffe097          	auipc	ra,0xffffe
    80002620:	66e080e7          	jalr	1646(ra) # 80000c8a <release>
            return -1;
    80002624:	59fd                	li	s3,-1
    80002626:	a0b9                	j	80002674 <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002628:	18048493          	addi	s1,s1,384
    8000262c:	03348463          	beq	s1,s3,80002654 <wait+0xe6>
      if(pp->parent == p){
    80002630:	7c9c                	ld	a5,56(s1)
    80002632:	ff279be3          	bne	a5,s2,80002628 <wait+0xba>
        acquire(&pp->lock);
    80002636:	8526                	mv	a0,s1
    80002638:	ffffe097          	auipc	ra,0xffffe
    8000263c:	59e080e7          	jalr	1438(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    80002640:	4c9c                	lw	a5,24(s1)
    80002642:	f94781e3          	beq	a5,s4,800025c4 <wait+0x56>
        release(&pp->lock);
    80002646:	8526                	mv	a0,s1
    80002648:	ffffe097          	auipc	ra,0xffffe
    8000264c:	642080e7          	jalr	1602(ra) # 80000c8a <release>
        havekids = 1;
    80002650:	8756                	mv	a4,s5
    80002652:	bfd9                	j	80002628 <wait+0xba>
    if(!havekids || killed(p)){
    80002654:	c719                	beqz	a4,80002662 <wait+0xf4>
    80002656:	854a                	mv	a0,s2
    80002658:	00000097          	auipc	ra,0x0
    8000265c:	ee4080e7          	jalr	-284(ra) # 8000253c <killed>
    80002660:	c51d                	beqz	a0,8000268e <wait+0x120>
      release(&wait_lock);
    80002662:	0000e517          	auipc	a0,0xe
    80002666:	6f650513          	addi	a0,a0,1782 # 80010d58 <wait_lock>
    8000266a:	ffffe097          	auipc	ra,0xffffe
    8000266e:	620080e7          	jalr	1568(ra) # 80000c8a <release>
      return -1;
    80002672:	59fd                	li	s3,-1
}
    80002674:	854e                	mv	a0,s3
    80002676:	60a6                	ld	ra,72(sp)
    80002678:	6406                	ld	s0,64(sp)
    8000267a:	74e2                	ld	s1,56(sp)
    8000267c:	7942                	ld	s2,48(sp)
    8000267e:	79a2                	ld	s3,40(sp)
    80002680:	7a02                	ld	s4,32(sp)
    80002682:	6ae2                	ld	s5,24(sp)
    80002684:	6b42                	ld	s6,16(sp)
    80002686:	6ba2                	ld	s7,8(sp)
    80002688:	6c02                	ld	s8,0(sp)
    8000268a:	6161                	addi	sp,sp,80
    8000268c:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000268e:	85e2                	mv	a1,s8
    80002690:	854a                	mv	a0,s2
    80002692:	00000097          	auipc	ra,0x0
    80002696:	aaa080e7          	jalr	-1366(ra) # 8000213c <sleep>
    havekids = 0;
    8000269a:	bf39                	j	800025b8 <wait+0x4a>

000000008000269c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000269c:	7179                	addi	sp,sp,-48
    8000269e:	f406                	sd	ra,40(sp)
    800026a0:	f022                	sd	s0,32(sp)
    800026a2:	ec26                	sd	s1,24(sp)
    800026a4:	e84a                	sd	s2,16(sp)
    800026a6:	e44e                	sd	s3,8(sp)
    800026a8:	e052                	sd	s4,0(sp)
    800026aa:	1800                	addi	s0,sp,48
    800026ac:	84aa                	mv	s1,a0
    800026ae:	892e                	mv	s2,a1
    800026b0:	89b2                	mv	s3,a2
    800026b2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800026b4:	fffff097          	auipc	ra,0xfffff
    800026b8:	2f8080e7          	jalr	760(ra) # 800019ac <myproc>
  if(user_dst){
    800026bc:	c08d                	beqz	s1,800026de <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800026be:	86d2                	mv	a3,s4
    800026c0:	864e                	mv	a2,s3
    800026c2:	85ca                	mv	a1,s2
    800026c4:	6928                	ld	a0,80(a0)
    800026c6:	fffff097          	auipc	ra,0xfffff
    800026ca:	fa2080e7          	jalr	-94(ra) # 80001668 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800026ce:	70a2                	ld	ra,40(sp)
    800026d0:	7402                	ld	s0,32(sp)
    800026d2:	64e2                	ld	s1,24(sp)
    800026d4:	6942                	ld	s2,16(sp)
    800026d6:	69a2                	ld	s3,8(sp)
    800026d8:	6a02                	ld	s4,0(sp)
    800026da:	6145                	addi	sp,sp,48
    800026dc:	8082                	ret
    memmove((char *)dst, src, len);
    800026de:	000a061b          	sext.w	a2,s4
    800026e2:	85ce                	mv	a1,s3
    800026e4:	854a                	mv	a0,s2
    800026e6:	ffffe097          	auipc	ra,0xffffe
    800026ea:	648080e7          	jalr	1608(ra) # 80000d2e <memmove>
    return 0;
    800026ee:	8526                	mv	a0,s1
    800026f0:	bff9                	j	800026ce <either_copyout+0x32>

00000000800026f2 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800026f2:	7179                	addi	sp,sp,-48
    800026f4:	f406                	sd	ra,40(sp)
    800026f6:	f022                	sd	s0,32(sp)
    800026f8:	ec26                	sd	s1,24(sp)
    800026fa:	e84a                	sd	s2,16(sp)
    800026fc:	e44e                	sd	s3,8(sp)
    800026fe:	e052                	sd	s4,0(sp)
    80002700:	1800                	addi	s0,sp,48
    80002702:	892a                	mv	s2,a0
    80002704:	84ae                	mv	s1,a1
    80002706:	89b2                	mv	s3,a2
    80002708:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000270a:	fffff097          	auipc	ra,0xfffff
    8000270e:	2a2080e7          	jalr	674(ra) # 800019ac <myproc>
  if(user_src){
    80002712:	c08d                	beqz	s1,80002734 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002714:	86d2                	mv	a3,s4
    80002716:	864e                	mv	a2,s3
    80002718:	85ca                	mv	a1,s2
    8000271a:	6928                	ld	a0,80(a0)
    8000271c:	fffff097          	auipc	ra,0xfffff
    80002720:	fd8080e7          	jalr	-40(ra) # 800016f4 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002724:	70a2                	ld	ra,40(sp)
    80002726:	7402                	ld	s0,32(sp)
    80002728:	64e2                	ld	s1,24(sp)
    8000272a:	6942                	ld	s2,16(sp)
    8000272c:	69a2                	ld	s3,8(sp)
    8000272e:	6a02                	ld	s4,0(sp)
    80002730:	6145                	addi	sp,sp,48
    80002732:	8082                	ret
    memmove(dst, (char*)src, len);
    80002734:	000a061b          	sext.w	a2,s4
    80002738:	85ce                	mv	a1,s3
    8000273a:	854a                	mv	a0,s2
    8000273c:	ffffe097          	auipc	ra,0xffffe
    80002740:	5f2080e7          	jalr	1522(ra) # 80000d2e <memmove>
    return 0;
    80002744:	8526                	mv	a0,s1
    80002746:	bff9                	j	80002724 <either_copyin+0x32>

0000000080002748 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002748:	715d                	addi	sp,sp,-80
    8000274a:	e486                	sd	ra,72(sp)
    8000274c:	e0a2                	sd	s0,64(sp)
    8000274e:	fc26                	sd	s1,56(sp)
    80002750:	f84a                	sd	s2,48(sp)
    80002752:	f44e                	sd	s3,40(sp)
    80002754:	f052                	sd	s4,32(sp)
    80002756:	ec56                	sd	s5,24(sp)
    80002758:	e85a                	sd	s6,16(sp)
    8000275a:	e45e                	sd	s7,8(sp)
    8000275c:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000275e:	00006517          	auipc	a0,0x6
    80002762:	96a50513          	addi	a0,a0,-1686 # 800080c8 <digits+0x88>
    80002766:	ffffe097          	auipc	ra,0xffffe
    8000276a:	e22080e7          	jalr	-478(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000276e:	0000f497          	auipc	s1,0xf
    80002772:	b5a48493          	addi	s1,s1,-1190 # 800112c8 <proc+0x158>
    80002776:	00015917          	auipc	s2,0x15
    8000277a:	b5290913          	addi	s2,s2,-1198 # 800172c8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000277e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002780:	00006997          	auipc	s3,0x6
    80002784:	b0098993          	addi	s3,s3,-1280 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    80002788:	00006a97          	auipc	s5,0x6
    8000278c:	b00a8a93          	addi	s5,s5,-1280 # 80008288 <digits+0x248>
    printf("\n");
    80002790:	00006a17          	auipc	s4,0x6
    80002794:	938a0a13          	addi	s4,s4,-1736 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002798:	00006b97          	auipc	s7,0x6
    8000279c:	b30b8b93          	addi	s7,s7,-1232 # 800082c8 <states.0>
    800027a0:	a00d                	j	800027c2 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800027a2:	ed86a583          	lw	a1,-296(a3)
    800027a6:	8556                	mv	a0,s5
    800027a8:	ffffe097          	auipc	ra,0xffffe
    800027ac:	de0080e7          	jalr	-544(ra) # 80000588 <printf>
    printf("\n");
    800027b0:	8552                	mv	a0,s4
    800027b2:	ffffe097          	auipc	ra,0xffffe
    800027b6:	dd6080e7          	jalr	-554(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800027ba:	18048493          	addi	s1,s1,384
    800027be:	03248163          	beq	s1,s2,800027e0 <procdump+0x98>
    if(p->state == UNUSED)
    800027c2:	86a6                	mv	a3,s1
    800027c4:	ec04a783          	lw	a5,-320(s1)
    800027c8:	dbed                	beqz	a5,800027ba <procdump+0x72>
      state = "???";
    800027ca:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027cc:	fcfb6be3          	bltu	s6,a5,800027a2 <procdump+0x5a>
    800027d0:	1782                	slli	a5,a5,0x20
    800027d2:	9381                	srli	a5,a5,0x20
    800027d4:	078e                	slli	a5,a5,0x3
    800027d6:	97de                	add	a5,a5,s7
    800027d8:	6390                	ld	a2,0(a5)
    800027da:	f661                	bnez	a2,800027a2 <procdump+0x5a>
      state = "???";
    800027dc:	864e                	mv	a2,s3
    800027de:	b7d1                	j	800027a2 <procdump+0x5a>
  }
}
    800027e0:	60a6                	ld	ra,72(sp)
    800027e2:	6406                	ld	s0,64(sp)
    800027e4:	74e2                	ld	s1,56(sp)
    800027e6:	7942                	ld	s2,48(sp)
    800027e8:	79a2                	ld	s3,40(sp)
    800027ea:	7a02                	ld	s4,32(sp)
    800027ec:	6ae2                	ld	s5,24(sp)
    800027ee:	6b42                	ld	s6,16(sp)
    800027f0:	6ba2                	ld	s7,8(sp)
    800027f2:	6161                	addi	sp,sp,80
    800027f4:	8082                	ret

00000000800027f6 <swtch>:
    800027f6:	00153023          	sd	ra,0(a0)
    800027fa:	00253423          	sd	sp,8(a0)
    800027fe:	e900                	sd	s0,16(a0)
    80002800:	ed04                	sd	s1,24(a0)
    80002802:	03253023          	sd	s2,32(a0)
    80002806:	03353423          	sd	s3,40(a0)
    8000280a:	03453823          	sd	s4,48(a0)
    8000280e:	03553c23          	sd	s5,56(a0)
    80002812:	05653023          	sd	s6,64(a0)
    80002816:	05753423          	sd	s7,72(a0)
    8000281a:	05853823          	sd	s8,80(a0)
    8000281e:	05953c23          	sd	s9,88(a0)
    80002822:	07a53023          	sd	s10,96(a0)
    80002826:	07b53423          	sd	s11,104(a0)
    8000282a:	0005b083          	ld	ra,0(a1)
    8000282e:	0085b103          	ld	sp,8(a1)
    80002832:	6980                	ld	s0,16(a1)
    80002834:	6d84                	ld	s1,24(a1)
    80002836:	0205b903          	ld	s2,32(a1)
    8000283a:	0285b983          	ld	s3,40(a1)
    8000283e:	0305ba03          	ld	s4,48(a1)
    80002842:	0385ba83          	ld	s5,56(a1)
    80002846:	0405bb03          	ld	s6,64(a1)
    8000284a:	0485bb83          	ld	s7,72(a1)
    8000284e:	0505bc03          	ld	s8,80(a1)
    80002852:	0585bc83          	ld	s9,88(a1)
    80002856:	0605bd03          	ld	s10,96(a1)
    8000285a:	0685bd83          	ld	s11,104(a1)
    8000285e:	8082                	ret

0000000080002860 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002860:	1141                	addi	sp,sp,-16
    80002862:	e406                	sd	ra,8(sp)
    80002864:	e022                	sd	s0,0(sp)
    80002866:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002868:	00006597          	auipc	a1,0x6
    8000286c:	a9058593          	addi	a1,a1,-1392 # 800082f8 <states.0+0x30>
    80002870:	00015517          	auipc	a0,0x15
    80002874:	90050513          	addi	a0,a0,-1792 # 80017170 <tickslock>
    80002878:	ffffe097          	auipc	ra,0xffffe
    8000287c:	2ce080e7          	jalr	718(ra) # 80000b46 <initlock>
}
    80002880:	60a2                	ld	ra,8(sp)
    80002882:	6402                	ld	s0,0(sp)
    80002884:	0141                	addi	sp,sp,16
    80002886:	8082                	ret

0000000080002888 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002888:	1141                	addi	sp,sp,-16
    8000288a:	e422                	sd	s0,8(sp)
    8000288c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000288e:	00003797          	auipc	a5,0x3
    80002892:	5e278793          	addi	a5,a5,1506 # 80005e70 <kernelvec>
    80002896:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000289a:	6422                	ld	s0,8(sp)
    8000289c:	0141                	addi	sp,sp,16
    8000289e:	8082                	ret

00000000800028a0 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800028a0:	1141                	addi	sp,sp,-16
    800028a2:	e406                	sd	ra,8(sp)
    800028a4:	e022                	sd	s0,0(sp)
    800028a6:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800028a8:	fffff097          	auipc	ra,0xfffff
    800028ac:	104080e7          	jalr	260(ra) # 800019ac <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028b0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800028b4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028b6:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800028ba:	00004617          	auipc	a2,0x4
    800028be:	74660613          	addi	a2,a2,1862 # 80007000 <_trampoline>
    800028c2:	00004697          	auipc	a3,0x4
    800028c6:	73e68693          	addi	a3,a3,1854 # 80007000 <_trampoline>
    800028ca:	8e91                	sub	a3,a3,a2
    800028cc:	040007b7          	lui	a5,0x4000
    800028d0:	17fd                	addi	a5,a5,-1
    800028d2:	07b2                	slli	a5,a5,0xc
    800028d4:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028d6:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800028da:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800028dc:	180026f3          	csrr	a3,satp
    800028e0:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800028e2:	6d38                	ld	a4,88(a0)
    800028e4:	6134                	ld	a3,64(a0)
    800028e6:	6585                	lui	a1,0x1
    800028e8:	96ae                	add	a3,a3,a1
    800028ea:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800028ec:	6d38                	ld	a4,88(a0)
    800028ee:	00000697          	auipc	a3,0x0
    800028f2:	13e68693          	addi	a3,a3,318 # 80002a2c <usertrap>
    800028f6:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800028f8:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800028fa:	8692                	mv	a3,tp
    800028fc:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028fe:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002902:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002906:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000290a:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000290e:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002910:	6f18                	ld	a4,24(a4)
    80002912:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002916:	6928                	ld	a0,80(a0)
    80002918:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000291a:	00004717          	auipc	a4,0x4
    8000291e:	78270713          	addi	a4,a4,1922 # 8000709c <userret>
    80002922:	8f11                	sub	a4,a4,a2
    80002924:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002926:	577d                	li	a4,-1
    80002928:	177e                	slli	a4,a4,0x3f
    8000292a:	8d59                	or	a0,a0,a4
    8000292c:	9782                	jalr	a5
}
    8000292e:	60a2                	ld	ra,8(sp)
    80002930:	6402                	ld	s0,0(sp)
    80002932:	0141                	addi	sp,sp,16
    80002934:	8082                	ret

0000000080002936 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002936:	1101                	addi	sp,sp,-32
    80002938:	ec06                	sd	ra,24(sp)
    8000293a:	e822                	sd	s0,16(sp)
    8000293c:	e426                	sd	s1,8(sp)
    8000293e:	e04a                	sd	s2,0(sp)
    80002940:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002942:	00015917          	auipc	s2,0x15
    80002946:	82e90913          	addi	s2,s2,-2002 # 80017170 <tickslock>
    8000294a:	854a                	mv	a0,s2
    8000294c:	ffffe097          	auipc	ra,0xffffe
    80002950:	28a080e7          	jalr	650(ra) # 80000bd6 <acquire>
  ticks++;
    80002954:	00006497          	auipc	s1,0x6
    80002958:	17c48493          	addi	s1,s1,380 # 80008ad0 <ticks>
    8000295c:	409c                	lw	a5,0(s1)
    8000295e:	2785                	addiw	a5,a5,1
    80002960:	c09c                	sw	a5,0(s1)
  update_time();
    80002962:	fffff097          	auipc	ra,0xfffff
    80002966:	568080e7          	jalr	1384(ra) # 80001eca <update_time>
  wakeup(&ticks);
    8000296a:	8526                	mv	a0,s1
    8000296c:	00000097          	auipc	ra,0x0
    80002970:	980080e7          	jalr	-1664(ra) # 800022ec <wakeup>
  release(&tickslock);
    80002974:	854a                	mv	a0,s2
    80002976:	ffffe097          	auipc	ra,0xffffe
    8000297a:	314080e7          	jalr	788(ra) # 80000c8a <release>
}
    8000297e:	60e2                	ld	ra,24(sp)
    80002980:	6442                	ld	s0,16(sp)
    80002982:	64a2                	ld	s1,8(sp)
    80002984:	6902                	ld	s2,0(sp)
    80002986:	6105                	addi	sp,sp,32
    80002988:	8082                	ret

000000008000298a <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000298a:	1101                	addi	sp,sp,-32
    8000298c:	ec06                	sd	ra,24(sp)
    8000298e:	e822                	sd	s0,16(sp)
    80002990:	e426                	sd	s1,8(sp)
    80002992:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002994:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002998:	00074d63          	bltz	a4,800029b2 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    8000299c:	57fd                	li	a5,-1
    8000299e:	17fe                	slli	a5,a5,0x3f
    800029a0:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800029a2:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800029a4:	06f70363          	beq	a4,a5,80002a0a <devintr+0x80>
  }
}
    800029a8:	60e2                	ld	ra,24(sp)
    800029aa:	6442                	ld	s0,16(sp)
    800029ac:	64a2                	ld	s1,8(sp)
    800029ae:	6105                	addi	sp,sp,32
    800029b0:	8082                	ret
     (scause & 0xff) == 9){
    800029b2:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    800029b6:	46a5                	li	a3,9
    800029b8:	fed792e3          	bne	a5,a3,8000299c <devintr+0x12>
    int irq = plic_claim();
    800029bc:	00003097          	auipc	ra,0x3
    800029c0:	5bc080e7          	jalr	1468(ra) # 80005f78 <plic_claim>
    800029c4:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800029c6:	47a9                	li	a5,10
    800029c8:	02f50763          	beq	a0,a5,800029f6 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800029cc:	4785                	li	a5,1
    800029ce:	02f50963          	beq	a0,a5,80002a00 <devintr+0x76>
    return 1;
    800029d2:	4505                	li	a0,1
    } else if(irq){
    800029d4:	d8f1                	beqz	s1,800029a8 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800029d6:	85a6                	mv	a1,s1
    800029d8:	00006517          	auipc	a0,0x6
    800029dc:	92850513          	addi	a0,a0,-1752 # 80008300 <states.0+0x38>
    800029e0:	ffffe097          	auipc	ra,0xffffe
    800029e4:	ba8080e7          	jalr	-1112(ra) # 80000588 <printf>
      plic_complete(irq);
    800029e8:	8526                	mv	a0,s1
    800029ea:	00003097          	auipc	ra,0x3
    800029ee:	5b2080e7          	jalr	1458(ra) # 80005f9c <plic_complete>
    return 1;
    800029f2:	4505                	li	a0,1
    800029f4:	bf55                	j	800029a8 <devintr+0x1e>
      uartintr();
    800029f6:	ffffe097          	auipc	ra,0xffffe
    800029fa:	fa4080e7          	jalr	-92(ra) # 8000099a <uartintr>
    800029fe:	b7ed                	j	800029e8 <devintr+0x5e>
      virtio_disk_intr();
    80002a00:	00004097          	auipc	ra,0x4
    80002a04:	a68080e7          	jalr	-1432(ra) # 80006468 <virtio_disk_intr>
    80002a08:	b7c5                	j	800029e8 <devintr+0x5e>
    if(cpuid() == 0){
    80002a0a:	fffff097          	auipc	ra,0xfffff
    80002a0e:	f76080e7          	jalr	-138(ra) # 80001980 <cpuid>
    80002a12:	c901                	beqz	a0,80002a22 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002a14:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002a18:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002a1a:	14479073          	csrw	sip,a5
    return 2;
    80002a1e:	4509                	li	a0,2
    80002a20:	b761                	j	800029a8 <devintr+0x1e>
      clockintr();
    80002a22:	00000097          	auipc	ra,0x0
    80002a26:	f14080e7          	jalr	-236(ra) # 80002936 <clockintr>
    80002a2a:	b7ed                	j	80002a14 <devintr+0x8a>

0000000080002a2c <usertrap>:
{
    80002a2c:	1101                	addi	sp,sp,-32
    80002a2e:	ec06                	sd	ra,24(sp)
    80002a30:	e822                	sd	s0,16(sp)
    80002a32:	e426                	sd	s1,8(sp)
    80002a34:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a36:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002a3a:	1007f793          	andi	a5,a5,256
    80002a3e:	eba9                	bnez	a5,80002a90 <usertrap+0x64>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a40:	00003797          	auipc	a5,0x3
    80002a44:	43078793          	addi	a5,a5,1072 # 80005e70 <kernelvec>
    80002a48:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002a4c:	fffff097          	auipc	ra,0xfffff
    80002a50:	f60080e7          	jalr	-160(ra) # 800019ac <myproc>
    80002a54:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002a56:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a58:	14102773          	csrr	a4,sepc
    80002a5c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a5e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002a62:	47a1                	li	a5,8
    80002a64:	02f70e63          	beq	a4,a5,80002aa0 <usertrap+0x74>
  } else if((which_dev = devintr()) != 0){
    80002a68:	00000097          	auipc	ra,0x0
    80002a6c:	f22080e7          	jalr	-222(ra) # 8000298a <devintr>
    80002a70:	c135                	beqz	a0,80002ad4 <usertrap+0xa8>
  if(killed(p))
    80002a72:	8526                	mv	a0,s1
    80002a74:	00000097          	auipc	ra,0x0
    80002a78:	ac8080e7          	jalr	-1336(ra) # 8000253c <killed>
    80002a7c:	e949                	bnez	a0,80002b0e <usertrap+0xe2>
  usertrapret();
    80002a7e:	00000097          	auipc	ra,0x0
    80002a82:	e22080e7          	jalr	-478(ra) # 800028a0 <usertrapret>
}
    80002a86:	60e2                	ld	ra,24(sp)
    80002a88:	6442                	ld	s0,16(sp)
    80002a8a:	64a2                	ld	s1,8(sp)
    80002a8c:	6105                	addi	sp,sp,32
    80002a8e:	8082                	ret
    panic("usertrap: not from user mode");
    80002a90:	00006517          	auipc	a0,0x6
    80002a94:	89050513          	addi	a0,a0,-1904 # 80008320 <states.0+0x58>
    80002a98:	ffffe097          	auipc	ra,0xffffe
    80002a9c:	aa6080e7          	jalr	-1370(ra) # 8000053e <panic>
    if(killed(p))
    80002aa0:	00000097          	auipc	ra,0x0
    80002aa4:	a9c080e7          	jalr	-1380(ra) # 8000253c <killed>
    80002aa8:	e105                	bnez	a0,80002ac8 <usertrap+0x9c>
    p->trapframe->epc += 4;
    80002aaa:	6cb8                	ld	a4,88(s1)
    80002aac:	6f1c                	ld	a5,24(a4)
    80002aae:	0791                	addi	a5,a5,4
    80002ab0:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ab2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002ab6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002aba:	10079073          	csrw	sstatus,a5
    syscall();
    80002abe:	00000097          	auipc	ra,0x0
    80002ac2:	27e080e7          	jalr	638(ra) # 80002d3c <syscall>
    80002ac6:	b775                	j	80002a72 <usertrap+0x46>
      exit(-1);
    80002ac8:	557d                	li	a0,-1
    80002aca:	00000097          	auipc	ra,0x0
    80002ace:	8f2080e7          	jalr	-1806(ra) # 800023bc <exit>
    80002ad2:	bfe1                	j	80002aaa <usertrap+0x7e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ad4:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002ad8:	5890                	lw	a2,48(s1)
    80002ada:	00006517          	auipc	a0,0x6
    80002ade:	86650513          	addi	a0,a0,-1946 # 80008340 <states.0+0x78>
    80002ae2:	ffffe097          	auipc	ra,0xffffe
    80002ae6:	aa6080e7          	jalr	-1370(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002aea:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002aee:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002af2:	00006517          	auipc	a0,0x6
    80002af6:	87e50513          	addi	a0,a0,-1922 # 80008370 <states.0+0xa8>
    80002afa:	ffffe097          	auipc	ra,0xffffe
    80002afe:	a8e080e7          	jalr	-1394(ra) # 80000588 <printf>
    setkilled(p);
    80002b02:	8526                	mv	a0,s1
    80002b04:	00000097          	auipc	ra,0x0
    80002b08:	a0c080e7          	jalr	-1524(ra) # 80002510 <setkilled>
    80002b0c:	b79d                	j	80002a72 <usertrap+0x46>
    exit(-1);
    80002b0e:	557d                	li	a0,-1
    80002b10:	00000097          	auipc	ra,0x0
    80002b14:	8ac080e7          	jalr	-1876(ra) # 800023bc <exit>
    80002b18:	b79d                	j	80002a7e <usertrap+0x52>

0000000080002b1a <kerneltrap>:
{
    80002b1a:	7179                	addi	sp,sp,-48
    80002b1c:	f406                	sd	ra,40(sp)
    80002b1e:	f022                	sd	s0,32(sp)
    80002b20:	ec26                	sd	s1,24(sp)
    80002b22:	e84a                	sd	s2,16(sp)
    80002b24:	e44e                	sd	s3,8(sp)
    80002b26:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b28:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b2c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b30:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002b34:	1004f793          	andi	a5,s1,256
    80002b38:	c78d                	beqz	a5,80002b62 <kerneltrap+0x48>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002b3e:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002b40:	eb8d                	bnez	a5,80002b72 <kerneltrap+0x58>
  if((which_dev = devintr()) == 0){
    80002b42:	00000097          	auipc	ra,0x0
    80002b46:	e48080e7          	jalr	-440(ra) # 8000298a <devintr>
    80002b4a:	cd05                	beqz	a0,80002b82 <kerneltrap+0x68>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b4c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b50:	10049073          	csrw	sstatus,s1
}
    80002b54:	70a2                	ld	ra,40(sp)
    80002b56:	7402                	ld	s0,32(sp)
    80002b58:	64e2                	ld	s1,24(sp)
    80002b5a:	6942                	ld	s2,16(sp)
    80002b5c:	69a2                	ld	s3,8(sp)
    80002b5e:	6145                	addi	sp,sp,48
    80002b60:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002b62:	00006517          	auipc	a0,0x6
    80002b66:	82e50513          	addi	a0,a0,-2002 # 80008390 <states.0+0xc8>
    80002b6a:	ffffe097          	auipc	ra,0xffffe
    80002b6e:	9d4080e7          	jalr	-1580(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002b72:	00006517          	auipc	a0,0x6
    80002b76:	84650513          	addi	a0,a0,-1978 # 800083b8 <states.0+0xf0>
    80002b7a:	ffffe097          	auipc	ra,0xffffe
    80002b7e:	9c4080e7          	jalr	-1596(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002b82:	85ce                	mv	a1,s3
    80002b84:	00006517          	auipc	a0,0x6
    80002b88:	85450513          	addi	a0,a0,-1964 # 800083d8 <states.0+0x110>
    80002b8c:	ffffe097          	auipc	ra,0xffffe
    80002b90:	9fc080e7          	jalr	-1540(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b94:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b98:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b9c:	00006517          	auipc	a0,0x6
    80002ba0:	84c50513          	addi	a0,a0,-1972 # 800083e8 <states.0+0x120>
    80002ba4:	ffffe097          	auipc	ra,0xffffe
    80002ba8:	9e4080e7          	jalr	-1564(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002bac:	00006517          	auipc	a0,0x6
    80002bb0:	85450513          	addi	a0,a0,-1964 # 80008400 <states.0+0x138>
    80002bb4:	ffffe097          	auipc	ra,0xffffe
    80002bb8:	98a080e7          	jalr	-1654(ra) # 8000053e <panic>

0000000080002bbc <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002bbc:	1101                	addi	sp,sp,-32
    80002bbe:	ec06                	sd	ra,24(sp)
    80002bc0:	e822                	sd	s0,16(sp)
    80002bc2:	e426                	sd	s1,8(sp)
    80002bc4:	1000                	addi	s0,sp,32
    80002bc6:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002bc8:	fffff097          	auipc	ra,0xfffff
    80002bcc:	de4080e7          	jalr	-540(ra) # 800019ac <myproc>
  switch (n) {
    80002bd0:	4795                	li	a5,5
    80002bd2:	0497e163          	bltu	a5,s1,80002c14 <argraw+0x58>
    80002bd6:	048a                	slli	s1,s1,0x2
    80002bd8:	00006717          	auipc	a4,0x6
    80002bdc:	94070713          	addi	a4,a4,-1728 # 80008518 <states.0+0x250>
    80002be0:	94ba                	add	s1,s1,a4
    80002be2:	409c                	lw	a5,0(s1)
    80002be4:	97ba                	add	a5,a5,a4
    80002be6:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002be8:	6d3c                	ld	a5,88(a0)
    80002bea:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002bec:	60e2                	ld	ra,24(sp)
    80002bee:	6442                	ld	s0,16(sp)
    80002bf0:	64a2                	ld	s1,8(sp)
    80002bf2:	6105                	addi	sp,sp,32
    80002bf4:	8082                	ret
    return p->trapframe->a1;
    80002bf6:	6d3c                	ld	a5,88(a0)
    80002bf8:	7fa8                	ld	a0,120(a5)
    80002bfa:	bfcd                	j	80002bec <argraw+0x30>
    return p->trapframe->a2;
    80002bfc:	6d3c                	ld	a5,88(a0)
    80002bfe:	63c8                	ld	a0,128(a5)
    80002c00:	b7f5                	j	80002bec <argraw+0x30>
    return p->trapframe->a3;
    80002c02:	6d3c                	ld	a5,88(a0)
    80002c04:	67c8                	ld	a0,136(a5)
    80002c06:	b7dd                	j	80002bec <argraw+0x30>
    return p->trapframe->a4;
    80002c08:	6d3c                	ld	a5,88(a0)
    80002c0a:	6bc8                	ld	a0,144(a5)
    80002c0c:	b7c5                	j	80002bec <argraw+0x30>
    return p->trapframe->a5;
    80002c0e:	6d3c                	ld	a5,88(a0)
    80002c10:	6fc8                	ld	a0,152(a5)
    80002c12:	bfe9                	j	80002bec <argraw+0x30>
  panic("argraw");
    80002c14:	00005517          	auipc	a0,0x5
    80002c18:	7fc50513          	addi	a0,a0,2044 # 80008410 <states.0+0x148>
    80002c1c:	ffffe097          	auipc	ra,0xffffe
    80002c20:	922080e7          	jalr	-1758(ra) # 8000053e <panic>

0000000080002c24 <fetchaddr>:
{
    80002c24:	1101                	addi	sp,sp,-32
    80002c26:	ec06                	sd	ra,24(sp)
    80002c28:	e822                	sd	s0,16(sp)
    80002c2a:	e426                	sd	s1,8(sp)
    80002c2c:	e04a                	sd	s2,0(sp)
    80002c2e:	1000                	addi	s0,sp,32
    80002c30:	84aa                	mv	s1,a0
    80002c32:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002c34:	fffff097          	auipc	ra,0xfffff
    80002c38:	d78080e7          	jalr	-648(ra) # 800019ac <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002c3c:	653c                	ld	a5,72(a0)
    80002c3e:	02f4f863          	bgeu	s1,a5,80002c6e <fetchaddr+0x4a>
    80002c42:	00848713          	addi	a4,s1,8
    80002c46:	02e7e663          	bltu	a5,a4,80002c72 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002c4a:	46a1                	li	a3,8
    80002c4c:	8626                	mv	a2,s1
    80002c4e:	85ca                	mv	a1,s2
    80002c50:	6928                	ld	a0,80(a0)
    80002c52:	fffff097          	auipc	ra,0xfffff
    80002c56:	aa2080e7          	jalr	-1374(ra) # 800016f4 <copyin>
    80002c5a:	00a03533          	snez	a0,a0
    80002c5e:	40a00533          	neg	a0,a0
}
    80002c62:	60e2                	ld	ra,24(sp)
    80002c64:	6442                	ld	s0,16(sp)
    80002c66:	64a2                	ld	s1,8(sp)
    80002c68:	6902                	ld	s2,0(sp)
    80002c6a:	6105                	addi	sp,sp,32
    80002c6c:	8082                	ret
    return -1;
    80002c6e:	557d                	li	a0,-1
    80002c70:	bfcd                	j	80002c62 <fetchaddr+0x3e>
    80002c72:	557d                	li	a0,-1
    80002c74:	b7fd                	j	80002c62 <fetchaddr+0x3e>

0000000080002c76 <fetchstr>:
{
    80002c76:	7179                	addi	sp,sp,-48
    80002c78:	f406                	sd	ra,40(sp)
    80002c7a:	f022                	sd	s0,32(sp)
    80002c7c:	ec26                	sd	s1,24(sp)
    80002c7e:	e84a                	sd	s2,16(sp)
    80002c80:	e44e                	sd	s3,8(sp)
    80002c82:	1800                	addi	s0,sp,48
    80002c84:	892a                	mv	s2,a0
    80002c86:	84ae                	mv	s1,a1
    80002c88:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002c8a:	fffff097          	auipc	ra,0xfffff
    80002c8e:	d22080e7          	jalr	-734(ra) # 800019ac <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002c92:	86ce                	mv	a3,s3
    80002c94:	864a                	mv	a2,s2
    80002c96:	85a6                	mv	a1,s1
    80002c98:	6928                	ld	a0,80(a0)
    80002c9a:	fffff097          	auipc	ra,0xfffff
    80002c9e:	ae8080e7          	jalr	-1304(ra) # 80001782 <copyinstr>
    80002ca2:	00054e63          	bltz	a0,80002cbe <fetchstr+0x48>
  return strlen(buf);
    80002ca6:	8526                	mv	a0,s1
    80002ca8:	ffffe097          	auipc	ra,0xffffe
    80002cac:	1a6080e7          	jalr	422(ra) # 80000e4e <strlen>
}
    80002cb0:	70a2                	ld	ra,40(sp)
    80002cb2:	7402                	ld	s0,32(sp)
    80002cb4:	64e2                	ld	s1,24(sp)
    80002cb6:	6942                	ld	s2,16(sp)
    80002cb8:	69a2                	ld	s3,8(sp)
    80002cba:	6145                	addi	sp,sp,48
    80002cbc:	8082                	ret
    return -1;
    80002cbe:	557d                	li	a0,-1
    80002cc0:	bfc5                	j	80002cb0 <fetchstr+0x3a>

0000000080002cc2 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002cc2:	1101                	addi	sp,sp,-32
    80002cc4:	ec06                	sd	ra,24(sp)
    80002cc6:	e822                	sd	s0,16(sp)
    80002cc8:	e426                	sd	s1,8(sp)
    80002cca:	1000                	addi	s0,sp,32
    80002ccc:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002cce:	00000097          	auipc	ra,0x0
    80002cd2:	eee080e7          	jalr	-274(ra) # 80002bbc <argraw>
    80002cd6:	c088                	sw	a0,0(s1)
  return 0;
}
    80002cd8:	4501                	li	a0,0
    80002cda:	60e2                	ld	ra,24(sp)
    80002cdc:	6442                	ld	s0,16(sp)
    80002cde:	64a2                	ld	s1,8(sp)
    80002ce0:	6105                	addi	sp,sp,32
    80002ce2:	8082                	ret

0000000080002ce4 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002ce4:	1101                	addi	sp,sp,-32
    80002ce6:	ec06                	sd	ra,24(sp)
    80002ce8:	e822                	sd	s0,16(sp)
    80002cea:	e426                	sd	s1,8(sp)
    80002cec:	1000                	addi	s0,sp,32
    80002cee:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002cf0:	00000097          	auipc	ra,0x0
    80002cf4:	ecc080e7          	jalr	-308(ra) # 80002bbc <argraw>
    80002cf8:	e088                	sd	a0,0(s1)
}
    80002cfa:	60e2                	ld	ra,24(sp)
    80002cfc:	6442                	ld	s0,16(sp)
    80002cfe:	64a2                	ld	s1,8(sp)
    80002d00:	6105                	addi	sp,sp,32
    80002d02:	8082                	ret

0000000080002d04 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002d04:	7179                	addi	sp,sp,-48
    80002d06:	f406                	sd	ra,40(sp)
    80002d08:	f022                	sd	s0,32(sp)
    80002d0a:	ec26                	sd	s1,24(sp)
    80002d0c:	e84a                	sd	s2,16(sp)
    80002d0e:	1800                	addi	s0,sp,48
    80002d10:	84ae                	mv	s1,a1
    80002d12:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002d14:	fd840593          	addi	a1,s0,-40
    80002d18:	00000097          	auipc	ra,0x0
    80002d1c:	fcc080e7          	jalr	-52(ra) # 80002ce4 <argaddr>
  return fetchstr(addr, buf, max);
    80002d20:	864a                	mv	a2,s2
    80002d22:	85a6                	mv	a1,s1
    80002d24:	fd843503          	ld	a0,-40(s0)
    80002d28:	00000097          	auipc	ra,0x0
    80002d2c:	f4e080e7          	jalr	-178(ra) # 80002c76 <fetchstr>
}
    80002d30:	70a2                	ld	ra,40(sp)
    80002d32:	7402                	ld	s0,32(sp)
    80002d34:	64e2                	ld	s1,24(sp)
    80002d36:	6942                	ld	s2,16(sp)
    80002d38:	6145                	addi	sp,sp,48
    80002d3a:	8082                	ret

0000000080002d3c <syscall>:
    [SYS_trace] 1,
};

void
syscall(void)
{
    80002d3c:	7179                	addi	sp,sp,-48
    80002d3e:	f406                	sd	ra,40(sp)
    80002d40:	f022                	sd	s0,32(sp)
    80002d42:	ec26                	sd	s1,24(sp)
    80002d44:	e84a                	sd	s2,16(sp)
    80002d46:	e44e                	sd	s3,8(sp)
    80002d48:	e052                	sd	s4,0(sp)
    80002d4a:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002d4c:	fffff097          	auipc	ra,0xfffff
    80002d50:	c60080e7          	jalr	-928(ra) # 800019ac <myproc>
    80002d54:	892a                	mv	s2,a0

  num = p->trapframe->a7;
    80002d56:	6d24                	ld	s1,88(a0)
    80002d58:	74dc                	ld	a5,168(s1)
    80002d5a:	0007899b          	sext.w	s3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) 
    80002d5e:	37fd                	addiw	a5,a5,-1
    80002d60:	4759                	li	a4,22
    80002d62:	0af76163          	bltu	a4,a5,80002e04 <syscall+0xc8>
    80002d66:	00399713          	slli	a4,s3,0x3
    80002d6a:	00005797          	auipc	a5,0x5
    80002d6e:	7c678793          	addi	a5,a5,1990 # 80008530 <syscalls>
    80002d72:	97ba                	add	a5,a5,a4
    80002d74:	639c                	ld	a5,0(a5)
    80002d76:	c7d9                	beqz	a5,80002e04 <syscall+0xc8>
  {
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002d78:	9782                	jalr	a5
    80002d7a:	f8a8                	sd	a0,112(s1)
    if ((p->mask >> num) & 1)
    80002d7c:	16892483          	lw	s1,360(s2)
    80002d80:	4134d4bb          	sraw	s1,s1,s3
    80002d84:	8885                	andi	s1,s1,1
    80002d86:	c0c5                	beqz	s1,80002e26 <syscall+0xea>
    {
      /* Modified for A4: Added entire section for trace, prints output for each syscall traced */
  	  printf("%d: syscall %s ( %d ",p->pid, syscallnames[num], p->trapframe->a0);
    80002d88:	05893703          	ld	a4,88(s2)
    80002d8c:	00399693          	slli	a3,s3,0x3
    80002d90:	00006797          	auipc	a5,0x6
    80002d94:	c4878793          	addi	a5,a5,-952 # 800089d8 <syscallnames>
    80002d98:	97b6                	add	a5,a5,a3
    80002d9a:	7b34                	ld	a3,112(a4)
    80002d9c:	6390                	ld	a2,0(a5)
    80002d9e:	03092583          	lw	a1,48(s2)
    80002da2:	00005517          	auipc	a0,0x5
    80002da6:	67650513          	addi	a0,a0,1654 # 80008418 <states.0+0x150>
    80002daa:	ffffd097          	auipc	ra,0xffffd
    80002dae:	7de080e7          	jalr	2014(ra) # 80000588 <printf>
      for (int i = 1; i < syscallnum[num]; i++) /* Modified for A4: 'num' tracks number of registers used by syscall and prints its register values  */
    80002db2:	098a                	slli	s3,s3,0x2
    80002db4:	00005797          	auipc	a5,0x5
    80002db8:	77c78793          	addi	a5,a5,1916 # 80008530 <syscalls>
    80002dbc:	99be                	add	s3,s3,a5
    80002dbe:	0c09a983          	lw	s3,192(s3)
    80002dc2:	4785                	li	a5,1
    80002dc4:	0337d463          	bge	a5,s3,80002dec <syscall+0xb0>
        printf("%d ", argraw(i));
    80002dc8:	00005a17          	auipc	s4,0x5
    80002dcc:	668a0a13          	addi	s4,s4,1640 # 80008430 <states.0+0x168>
    80002dd0:	8526                	mv	a0,s1
    80002dd2:	00000097          	auipc	ra,0x0
    80002dd6:	dea080e7          	jalr	-534(ra) # 80002bbc <argraw>
    80002dda:	85aa                	mv	a1,a0
    80002ddc:	8552                	mv	a0,s4
    80002dde:	ffffd097          	auipc	ra,0xffffd
    80002de2:	7aa080e7          	jalr	1962(ra) # 80000588 <printf>
      for (int i = 1; i < syscallnum[num]; i++) /* Modified for A4: 'num' tracks number of registers used by syscall and prints its register values  */
    80002de6:	2485                	addiw	s1,s1,1
    80002de8:	ff3494e3          	bne	s1,s3,80002dd0 <syscall+0x94>
      printf(") -> %d\n", p->trapframe->a0);
    80002dec:	05893783          	ld	a5,88(s2)
    80002df0:	7bac                	ld	a1,112(a5)
    80002df2:	00005517          	auipc	a0,0x5
    80002df6:	64650513          	addi	a0,a0,1606 # 80008438 <states.0+0x170>
    80002dfa:	ffffd097          	auipc	ra,0xffffd
    80002dfe:	78e080e7          	jalr	1934(ra) # 80000588 <printf>
    80002e02:	a015                	j	80002e26 <syscall+0xea>
    }	
  } 
  else 
  {
    printf("%d %s: unknown sys call %d\n",
    80002e04:	86ce                	mv	a3,s3
    80002e06:	15890613          	addi	a2,s2,344
    80002e0a:	03092583          	lw	a1,48(s2)
    80002e0e:	00005517          	auipc	a0,0x5
    80002e12:	63a50513          	addi	a0,a0,1594 # 80008448 <states.0+0x180>
    80002e16:	ffffd097          	auipc	ra,0xffffd
    80002e1a:	772080e7          	jalr	1906(ra) # 80000588 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002e1e:	05893783          	ld	a5,88(s2)
    80002e22:	577d                	li	a4,-1
    80002e24:	fbb8                	sd	a4,112(a5)
  
  // if (p->mask >> num)
  // {
  // 	printf("%d: syscall %s -> %d\n",p->pid, syscallnames[num], p->trapframe->a0);
  // }	
}
    80002e26:	70a2                	ld	ra,40(sp)
    80002e28:	7402                	ld	s0,32(sp)
    80002e2a:	64e2                	ld	s1,24(sp)
    80002e2c:	6942                	ld	s2,16(sp)
    80002e2e:	69a2                	ld	s3,8(sp)
    80002e30:	6a02                	ld	s4,0(sp)
    80002e32:	6145                	addi	sp,sp,48
    80002e34:	8082                	ret

0000000080002e36 <sys_trace>:

int mask;

uint64
sys_trace(void)
{
    80002e36:	1141                	addi	sp,sp,-16
    80002e38:	e406                	sd	ra,8(sp)
    80002e3a:	e022                	sd	s0,0(sp)
    80002e3c:	0800                	addi	s0,sp,16
	if(argint(0, &mask) < 0)
    80002e3e:	00006597          	auipc	a1,0x6
    80002e42:	c9658593          	addi	a1,a1,-874 # 80008ad4 <mask>
    80002e46:	4501                	li	a0,0
    80002e48:	00000097          	auipc	ra,0x0
    80002e4c:	e7a080e7          	jalr	-390(ra) # 80002cc2 <argint>
	{
		return -1;
    80002e50:	57fd                	li	a5,-1
	if(argint(0, &mask) < 0)
    80002e52:	00054d63          	bltz	a0,80002e6c <sys_trace+0x36>
	}
	
  myproc()->mask = mask;
    80002e56:	fffff097          	auipc	ra,0xfffff
    80002e5a:	b56080e7          	jalr	-1194(ra) # 800019ac <myproc>
    80002e5e:	00006797          	auipc	a5,0x6
    80002e62:	c767a783          	lw	a5,-906(a5) # 80008ad4 <mask>
    80002e66:	16f52423          	sw	a5,360(a0)
	return 0;
    80002e6a:	4781                	li	a5,0
}	/* Modified for A4: Added trace */
    80002e6c:	853e                	mv	a0,a5
    80002e6e:	60a2                	ld	ra,8(sp)
    80002e70:	6402                	ld	s0,0(sp)
    80002e72:	0141                	addi	sp,sp,16
    80002e74:	8082                	ret

0000000080002e76 <sys_exit>:

uint64
sys_exit(void)
{
    80002e76:	1101                	addi	sp,sp,-32
    80002e78:	ec06                	sd	ra,24(sp)
    80002e7a:	e822                	sd	s0,16(sp)
    80002e7c:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002e7e:	fec40593          	addi	a1,s0,-20
    80002e82:	4501                	li	a0,0
    80002e84:	00000097          	auipc	ra,0x0
    80002e88:	e3e080e7          	jalr	-450(ra) # 80002cc2 <argint>
  exit(n);
    80002e8c:	fec42503          	lw	a0,-20(s0)
    80002e90:	fffff097          	auipc	ra,0xfffff
    80002e94:	52c080e7          	jalr	1324(ra) # 800023bc <exit>
  return 0;  // not reached
}
    80002e98:	4501                	li	a0,0
    80002e9a:	60e2                	ld	ra,24(sp)
    80002e9c:	6442                	ld	s0,16(sp)
    80002e9e:	6105                	addi	sp,sp,32
    80002ea0:	8082                	ret

0000000080002ea2 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002ea2:	1141                	addi	sp,sp,-16
    80002ea4:	e406                	sd	ra,8(sp)
    80002ea6:	e022                	sd	s0,0(sp)
    80002ea8:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002eaa:	fffff097          	auipc	ra,0xfffff
    80002eae:	b02080e7          	jalr	-1278(ra) # 800019ac <myproc>
}
    80002eb2:	5908                	lw	a0,48(a0)
    80002eb4:	60a2                	ld	ra,8(sp)
    80002eb6:	6402                	ld	s0,0(sp)
    80002eb8:	0141                	addi	sp,sp,16
    80002eba:	8082                	ret

0000000080002ebc <sys_fork>:

uint64
sys_fork(void)
{
    80002ebc:	1141                	addi	sp,sp,-16
    80002ebe:	e406                	sd	ra,8(sp)
    80002ec0:	e022                	sd	s0,0(sp)
    80002ec2:	0800                	addi	s0,sp,16
  return fork();
    80002ec4:	fffff097          	auipc	ra,0xfffff
    80002ec8:	ebe080e7          	jalr	-322(ra) # 80001d82 <fork>
}
    80002ecc:	60a2                	ld	ra,8(sp)
    80002ece:	6402                	ld	s0,0(sp)
    80002ed0:	0141                	addi	sp,sp,16
    80002ed2:	8082                	ret

0000000080002ed4 <sys_wait>:

uint64
sys_wait(void)
{
    80002ed4:	1101                	addi	sp,sp,-32
    80002ed6:	ec06                	sd	ra,24(sp)
    80002ed8:	e822                	sd	s0,16(sp)
    80002eda:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002edc:	fe840593          	addi	a1,s0,-24
    80002ee0:	4501                	li	a0,0
    80002ee2:	00000097          	auipc	ra,0x0
    80002ee6:	e02080e7          	jalr	-510(ra) # 80002ce4 <argaddr>
  return wait(p);
    80002eea:	fe843503          	ld	a0,-24(s0)
    80002eee:	fffff097          	auipc	ra,0xfffff
    80002ef2:	680080e7          	jalr	1664(ra) # 8000256e <wait>
}
    80002ef6:	60e2                	ld	ra,24(sp)
    80002ef8:	6442                	ld	s0,16(sp)
    80002efa:	6105                	addi	sp,sp,32
    80002efc:	8082                	ret

0000000080002efe <sys_waitx>:

uint64
sys_waitx(void)
{
    80002efe:	7139                	addi	sp,sp,-64
    80002f00:	fc06                	sd	ra,56(sp)
    80002f02:	f822                	sd	s0,48(sp)
    80002f04:	f426                	sd	s1,40(sp)
    80002f06:	f04a                	sd	s2,32(sp)
    80002f08:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    80002f0a:	fd840593          	addi	a1,s0,-40
    80002f0e:	4501                	li	a0,0
    80002f10:	00000097          	auipc	ra,0x0
    80002f14:	dd4080e7          	jalr	-556(ra) # 80002ce4 <argaddr>
  argaddr(1, &addr1); // user virtual memory
    80002f18:	fd040593          	addi	a1,s0,-48
    80002f1c:	4505                	li	a0,1
    80002f1e:	00000097          	auipc	ra,0x0
    80002f22:	dc6080e7          	jalr	-570(ra) # 80002ce4 <argaddr>
  argaddr(2, &addr2);
    80002f26:	fc840593          	addi	a1,s0,-56
    80002f2a:	4509                	li	a0,2
    80002f2c:	00000097          	auipc	ra,0x0
    80002f30:	db8080e7          	jalr	-584(ra) # 80002ce4 <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    80002f34:	fc040613          	addi	a2,s0,-64
    80002f38:	fc440593          	addi	a1,s0,-60
    80002f3c:	fd843503          	ld	a0,-40(s0)
    80002f40:	fffff097          	auipc	ra,0xfffff
    80002f44:	260080e7          	jalr	608(ra) # 800021a0 <waitx>
    80002f48:	892a                	mv	s2,a0
  struct proc* p = myproc();
    80002f4a:	fffff097          	auipc	ra,0xfffff
    80002f4e:	a62080e7          	jalr	-1438(ra) # 800019ac <myproc>
    80002f52:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    80002f54:	4691                	li	a3,4
    80002f56:	fc440613          	addi	a2,s0,-60
    80002f5a:	fd043583          	ld	a1,-48(s0)
    80002f5e:	6928                	ld	a0,80(a0)
    80002f60:	ffffe097          	auipc	ra,0xffffe
    80002f64:	708080e7          	jalr	1800(ra) # 80001668 <copyout>
    return -1;
    80002f68:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    80002f6a:	00054f63          	bltz	a0,80002f88 <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2,(char*)&rtime, sizeof(int)) < 0)
    80002f6e:	4691                	li	a3,4
    80002f70:	fc040613          	addi	a2,s0,-64
    80002f74:	fc843583          	ld	a1,-56(s0)
    80002f78:	68a8                	ld	a0,80(s1)
    80002f7a:	ffffe097          	auipc	ra,0xffffe
    80002f7e:	6ee080e7          	jalr	1774(ra) # 80001668 <copyout>
    80002f82:	00054a63          	bltz	a0,80002f96 <sys_waitx+0x98>
    return -1;
  return ret;
    80002f86:	87ca                	mv	a5,s2
}
    80002f88:	853e                	mv	a0,a5
    80002f8a:	70e2                	ld	ra,56(sp)
    80002f8c:	7442                	ld	s0,48(sp)
    80002f8e:	74a2                	ld	s1,40(sp)
    80002f90:	7902                	ld	s2,32(sp)
    80002f92:	6121                	addi	sp,sp,64
    80002f94:	8082                	ret
    return -1;
    80002f96:	57fd                	li	a5,-1
    80002f98:	bfc5                	j	80002f88 <sys_waitx+0x8a>

0000000080002f9a <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002f9a:	7179                	addi	sp,sp,-48
    80002f9c:	f406                	sd	ra,40(sp)
    80002f9e:	f022                	sd	s0,32(sp)
    80002fa0:	ec26                	sd	s1,24(sp)
    80002fa2:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002fa4:	fdc40593          	addi	a1,s0,-36
    80002fa8:	4501                	li	a0,0
    80002faa:	00000097          	auipc	ra,0x0
    80002fae:	d18080e7          	jalr	-744(ra) # 80002cc2 <argint>
  addr = myproc()->sz;
    80002fb2:	fffff097          	auipc	ra,0xfffff
    80002fb6:	9fa080e7          	jalr	-1542(ra) # 800019ac <myproc>
    80002fba:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002fbc:	fdc42503          	lw	a0,-36(s0)
    80002fc0:	fffff097          	auipc	ra,0xfffff
    80002fc4:	d66080e7          	jalr	-666(ra) # 80001d26 <growproc>
    80002fc8:	00054863          	bltz	a0,80002fd8 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002fcc:	8526                	mv	a0,s1
    80002fce:	70a2                	ld	ra,40(sp)
    80002fd0:	7402                	ld	s0,32(sp)
    80002fd2:	64e2                	ld	s1,24(sp)
    80002fd4:	6145                	addi	sp,sp,48
    80002fd6:	8082                	ret
    return -1;
    80002fd8:	54fd                	li	s1,-1
    80002fda:	bfcd                	j	80002fcc <sys_sbrk+0x32>

0000000080002fdc <sys_sleep>:

uint64
sys_sleep(void)
{
    80002fdc:	7139                	addi	sp,sp,-64
    80002fde:	fc06                	sd	ra,56(sp)
    80002fe0:	f822                	sd	s0,48(sp)
    80002fe2:	f426                	sd	s1,40(sp)
    80002fe4:	f04a                	sd	s2,32(sp)
    80002fe6:	ec4e                	sd	s3,24(sp)
    80002fe8:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002fea:	fcc40593          	addi	a1,s0,-52
    80002fee:	4501                	li	a0,0
    80002ff0:	00000097          	auipc	ra,0x0
    80002ff4:	cd2080e7          	jalr	-814(ra) # 80002cc2 <argint>
  acquire(&tickslock);
    80002ff8:	00014517          	auipc	a0,0x14
    80002ffc:	17850513          	addi	a0,a0,376 # 80017170 <tickslock>
    80003000:	ffffe097          	auipc	ra,0xffffe
    80003004:	bd6080e7          	jalr	-1066(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80003008:	00006917          	auipc	s2,0x6
    8000300c:	ac892903          	lw	s2,-1336(s2) # 80008ad0 <ticks>
  while(ticks - ticks0 < n){
    80003010:	fcc42783          	lw	a5,-52(s0)
    80003014:	cf9d                	beqz	a5,80003052 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003016:	00014997          	auipc	s3,0x14
    8000301a:	15a98993          	addi	s3,s3,346 # 80017170 <tickslock>
    8000301e:	00006497          	auipc	s1,0x6
    80003022:	ab248493          	addi	s1,s1,-1358 # 80008ad0 <ticks>
    if(killed(myproc())){
    80003026:	fffff097          	auipc	ra,0xfffff
    8000302a:	986080e7          	jalr	-1658(ra) # 800019ac <myproc>
    8000302e:	fffff097          	auipc	ra,0xfffff
    80003032:	50e080e7          	jalr	1294(ra) # 8000253c <killed>
    80003036:	ed15                	bnez	a0,80003072 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80003038:	85ce                	mv	a1,s3
    8000303a:	8526                	mv	a0,s1
    8000303c:	fffff097          	auipc	ra,0xfffff
    80003040:	100080e7          	jalr	256(ra) # 8000213c <sleep>
  while(ticks - ticks0 < n){
    80003044:	409c                	lw	a5,0(s1)
    80003046:	412787bb          	subw	a5,a5,s2
    8000304a:	fcc42703          	lw	a4,-52(s0)
    8000304e:	fce7ece3          	bltu	a5,a4,80003026 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80003052:	00014517          	auipc	a0,0x14
    80003056:	11e50513          	addi	a0,a0,286 # 80017170 <tickslock>
    8000305a:	ffffe097          	auipc	ra,0xffffe
    8000305e:	c30080e7          	jalr	-976(ra) # 80000c8a <release>
  return 0;
    80003062:	4501                	li	a0,0
}
    80003064:	70e2                	ld	ra,56(sp)
    80003066:	7442                	ld	s0,48(sp)
    80003068:	74a2                	ld	s1,40(sp)
    8000306a:	7902                	ld	s2,32(sp)
    8000306c:	69e2                	ld	s3,24(sp)
    8000306e:	6121                	addi	sp,sp,64
    80003070:	8082                	ret
      release(&tickslock);
    80003072:	00014517          	auipc	a0,0x14
    80003076:	0fe50513          	addi	a0,a0,254 # 80017170 <tickslock>
    8000307a:	ffffe097          	auipc	ra,0xffffe
    8000307e:	c10080e7          	jalr	-1008(ra) # 80000c8a <release>
      return -1;
    80003082:	557d                	li	a0,-1
    80003084:	b7c5                	j	80003064 <sys_sleep+0x88>

0000000080003086 <sys_kill>:

uint64
sys_kill(void)
{
    80003086:	1101                	addi	sp,sp,-32
    80003088:	ec06                	sd	ra,24(sp)
    8000308a:	e822                	sd	s0,16(sp)
    8000308c:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    8000308e:	fec40593          	addi	a1,s0,-20
    80003092:	4501                	li	a0,0
    80003094:	00000097          	auipc	ra,0x0
    80003098:	c2e080e7          	jalr	-978(ra) # 80002cc2 <argint>
  return kill(pid);
    8000309c:	fec42503          	lw	a0,-20(s0)
    800030a0:	fffff097          	auipc	ra,0xfffff
    800030a4:	3fe080e7          	jalr	1022(ra) # 8000249e <kill>
}
    800030a8:	60e2                	ld	ra,24(sp)
    800030aa:	6442                	ld	s0,16(sp)
    800030ac:	6105                	addi	sp,sp,32
    800030ae:	8082                	ret

00000000800030b0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800030b0:	1101                	addi	sp,sp,-32
    800030b2:	ec06                	sd	ra,24(sp)
    800030b4:	e822                	sd	s0,16(sp)
    800030b6:	e426                	sd	s1,8(sp)
    800030b8:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800030ba:	00014517          	auipc	a0,0x14
    800030be:	0b650513          	addi	a0,a0,182 # 80017170 <tickslock>
    800030c2:	ffffe097          	auipc	ra,0xffffe
    800030c6:	b14080e7          	jalr	-1260(ra) # 80000bd6 <acquire>
  xticks = ticks;
    800030ca:	00006497          	auipc	s1,0x6
    800030ce:	a064a483          	lw	s1,-1530(s1) # 80008ad0 <ticks>
  release(&tickslock);
    800030d2:	00014517          	auipc	a0,0x14
    800030d6:	09e50513          	addi	a0,a0,158 # 80017170 <tickslock>
    800030da:	ffffe097          	auipc	ra,0xffffe
    800030de:	bb0080e7          	jalr	-1104(ra) # 80000c8a <release>
  return xticks;
}
    800030e2:	02049513          	slli	a0,s1,0x20
    800030e6:	9101                	srli	a0,a0,0x20
    800030e8:	60e2                	ld	ra,24(sp)
    800030ea:	6442                	ld	s0,16(sp)
    800030ec:	64a2                	ld	s1,8(sp)
    800030ee:	6105                	addi	sp,sp,32
    800030f0:	8082                	ret

00000000800030f2 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800030f2:	7179                	addi	sp,sp,-48
    800030f4:	f406                	sd	ra,40(sp)
    800030f6:	f022                	sd	s0,32(sp)
    800030f8:	ec26                	sd	s1,24(sp)
    800030fa:	e84a                	sd	s2,16(sp)
    800030fc:	e44e                	sd	s3,8(sp)
    800030fe:	e052                	sd	s4,0(sp)
    80003100:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003102:	00005597          	auipc	a1,0x5
    80003106:	54e58593          	addi	a1,a1,1358 # 80008650 <syscallnum+0x60>
    8000310a:	00014517          	auipc	a0,0x14
    8000310e:	07e50513          	addi	a0,a0,126 # 80017188 <bcache>
    80003112:	ffffe097          	auipc	ra,0xffffe
    80003116:	a34080e7          	jalr	-1484(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000311a:	0001c797          	auipc	a5,0x1c
    8000311e:	06e78793          	addi	a5,a5,110 # 8001f188 <bcache+0x8000>
    80003122:	0001c717          	auipc	a4,0x1c
    80003126:	2ce70713          	addi	a4,a4,718 # 8001f3f0 <bcache+0x8268>
    8000312a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000312e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003132:	00014497          	auipc	s1,0x14
    80003136:	06e48493          	addi	s1,s1,110 # 800171a0 <bcache+0x18>
    b->next = bcache.head.next;
    8000313a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000313c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000313e:	00005a17          	auipc	s4,0x5
    80003142:	51aa0a13          	addi	s4,s4,1306 # 80008658 <syscallnum+0x68>
    b->next = bcache.head.next;
    80003146:	2b893783          	ld	a5,696(s2)
    8000314a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000314c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003150:	85d2                	mv	a1,s4
    80003152:	01048513          	addi	a0,s1,16
    80003156:	00001097          	auipc	ra,0x1
    8000315a:	4c4080e7          	jalr	1220(ra) # 8000461a <initsleeplock>
    bcache.head.next->prev = b;
    8000315e:	2b893783          	ld	a5,696(s2)
    80003162:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003164:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003168:	45848493          	addi	s1,s1,1112
    8000316c:	fd349de3          	bne	s1,s3,80003146 <binit+0x54>
  }
}
    80003170:	70a2                	ld	ra,40(sp)
    80003172:	7402                	ld	s0,32(sp)
    80003174:	64e2                	ld	s1,24(sp)
    80003176:	6942                	ld	s2,16(sp)
    80003178:	69a2                	ld	s3,8(sp)
    8000317a:	6a02                	ld	s4,0(sp)
    8000317c:	6145                	addi	sp,sp,48
    8000317e:	8082                	ret

0000000080003180 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003180:	7179                	addi	sp,sp,-48
    80003182:	f406                	sd	ra,40(sp)
    80003184:	f022                	sd	s0,32(sp)
    80003186:	ec26                	sd	s1,24(sp)
    80003188:	e84a                	sd	s2,16(sp)
    8000318a:	e44e                	sd	s3,8(sp)
    8000318c:	1800                	addi	s0,sp,48
    8000318e:	892a                	mv	s2,a0
    80003190:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003192:	00014517          	auipc	a0,0x14
    80003196:	ff650513          	addi	a0,a0,-10 # 80017188 <bcache>
    8000319a:	ffffe097          	auipc	ra,0xffffe
    8000319e:	a3c080e7          	jalr	-1476(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800031a2:	0001c497          	auipc	s1,0x1c
    800031a6:	29e4b483          	ld	s1,670(s1) # 8001f440 <bcache+0x82b8>
    800031aa:	0001c797          	auipc	a5,0x1c
    800031ae:	24678793          	addi	a5,a5,582 # 8001f3f0 <bcache+0x8268>
    800031b2:	02f48f63          	beq	s1,a5,800031f0 <bread+0x70>
    800031b6:	873e                	mv	a4,a5
    800031b8:	a021                	j	800031c0 <bread+0x40>
    800031ba:	68a4                	ld	s1,80(s1)
    800031bc:	02e48a63          	beq	s1,a4,800031f0 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800031c0:	449c                	lw	a5,8(s1)
    800031c2:	ff279ce3          	bne	a5,s2,800031ba <bread+0x3a>
    800031c6:	44dc                	lw	a5,12(s1)
    800031c8:	ff3799e3          	bne	a5,s3,800031ba <bread+0x3a>
      b->refcnt++;
    800031cc:	40bc                	lw	a5,64(s1)
    800031ce:	2785                	addiw	a5,a5,1
    800031d0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800031d2:	00014517          	auipc	a0,0x14
    800031d6:	fb650513          	addi	a0,a0,-74 # 80017188 <bcache>
    800031da:	ffffe097          	auipc	ra,0xffffe
    800031de:	ab0080e7          	jalr	-1360(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    800031e2:	01048513          	addi	a0,s1,16
    800031e6:	00001097          	auipc	ra,0x1
    800031ea:	46e080e7          	jalr	1134(ra) # 80004654 <acquiresleep>
      return b;
    800031ee:	a8b9                	j	8000324c <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800031f0:	0001c497          	auipc	s1,0x1c
    800031f4:	2484b483          	ld	s1,584(s1) # 8001f438 <bcache+0x82b0>
    800031f8:	0001c797          	auipc	a5,0x1c
    800031fc:	1f878793          	addi	a5,a5,504 # 8001f3f0 <bcache+0x8268>
    80003200:	00f48863          	beq	s1,a5,80003210 <bread+0x90>
    80003204:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003206:	40bc                	lw	a5,64(s1)
    80003208:	cf81                	beqz	a5,80003220 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000320a:	64a4                	ld	s1,72(s1)
    8000320c:	fee49de3          	bne	s1,a4,80003206 <bread+0x86>
  panic("bget: no buffers");
    80003210:	00005517          	auipc	a0,0x5
    80003214:	45050513          	addi	a0,a0,1104 # 80008660 <syscallnum+0x70>
    80003218:	ffffd097          	auipc	ra,0xffffd
    8000321c:	326080e7          	jalr	806(ra) # 8000053e <panic>
      b->dev = dev;
    80003220:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003224:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003228:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000322c:	4785                	li	a5,1
    8000322e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003230:	00014517          	auipc	a0,0x14
    80003234:	f5850513          	addi	a0,a0,-168 # 80017188 <bcache>
    80003238:	ffffe097          	auipc	ra,0xffffe
    8000323c:	a52080e7          	jalr	-1454(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003240:	01048513          	addi	a0,s1,16
    80003244:	00001097          	auipc	ra,0x1
    80003248:	410080e7          	jalr	1040(ra) # 80004654 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000324c:	409c                	lw	a5,0(s1)
    8000324e:	cb89                	beqz	a5,80003260 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003250:	8526                	mv	a0,s1
    80003252:	70a2                	ld	ra,40(sp)
    80003254:	7402                	ld	s0,32(sp)
    80003256:	64e2                	ld	s1,24(sp)
    80003258:	6942                	ld	s2,16(sp)
    8000325a:	69a2                	ld	s3,8(sp)
    8000325c:	6145                	addi	sp,sp,48
    8000325e:	8082                	ret
    virtio_disk_rw(b, 0);
    80003260:	4581                	li	a1,0
    80003262:	8526                	mv	a0,s1
    80003264:	00003097          	auipc	ra,0x3
    80003268:	fd0080e7          	jalr	-48(ra) # 80006234 <virtio_disk_rw>
    b->valid = 1;
    8000326c:	4785                	li	a5,1
    8000326e:	c09c                	sw	a5,0(s1)
  return b;
    80003270:	b7c5                	j	80003250 <bread+0xd0>

0000000080003272 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003272:	1101                	addi	sp,sp,-32
    80003274:	ec06                	sd	ra,24(sp)
    80003276:	e822                	sd	s0,16(sp)
    80003278:	e426                	sd	s1,8(sp)
    8000327a:	1000                	addi	s0,sp,32
    8000327c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000327e:	0541                	addi	a0,a0,16
    80003280:	00001097          	auipc	ra,0x1
    80003284:	46e080e7          	jalr	1134(ra) # 800046ee <holdingsleep>
    80003288:	cd01                	beqz	a0,800032a0 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000328a:	4585                	li	a1,1
    8000328c:	8526                	mv	a0,s1
    8000328e:	00003097          	auipc	ra,0x3
    80003292:	fa6080e7          	jalr	-90(ra) # 80006234 <virtio_disk_rw>
}
    80003296:	60e2                	ld	ra,24(sp)
    80003298:	6442                	ld	s0,16(sp)
    8000329a:	64a2                	ld	s1,8(sp)
    8000329c:	6105                	addi	sp,sp,32
    8000329e:	8082                	ret
    panic("bwrite");
    800032a0:	00005517          	auipc	a0,0x5
    800032a4:	3d850513          	addi	a0,a0,984 # 80008678 <syscallnum+0x88>
    800032a8:	ffffd097          	auipc	ra,0xffffd
    800032ac:	296080e7          	jalr	662(ra) # 8000053e <panic>

00000000800032b0 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800032b0:	1101                	addi	sp,sp,-32
    800032b2:	ec06                	sd	ra,24(sp)
    800032b4:	e822                	sd	s0,16(sp)
    800032b6:	e426                	sd	s1,8(sp)
    800032b8:	e04a                	sd	s2,0(sp)
    800032ba:	1000                	addi	s0,sp,32
    800032bc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800032be:	01050913          	addi	s2,a0,16
    800032c2:	854a                	mv	a0,s2
    800032c4:	00001097          	auipc	ra,0x1
    800032c8:	42a080e7          	jalr	1066(ra) # 800046ee <holdingsleep>
    800032cc:	c92d                	beqz	a0,8000333e <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800032ce:	854a                	mv	a0,s2
    800032d0:	00001097          	auipc	ra,0x1
    800032d4:	3da080e7          	jalr	986(ra) # 800046aa <releasesleep>

  acquire(&bcache.lock);
    800032d8:	00014517          	auipc	a0,0x14
    800032dc:	eb050513          	addi	a0,a0,-336 # 80017188 <bcache>
    800032e0:	ffffe097          	auipc	ra,0xffffe
    800032e4:	8f6080e7          	jalr	-1802(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800032e8:	40bc                	lw	a5,64(s1)
    800032ea:	37fd                	addiw	a5,a5,-1
    800032ec:	0007871b          	sext.w	a4,a5
    800032f0:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800032f2:	eb05                	bnez	a4,80003322 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800032f4:	68bc                	ld	a5,80(s1)
    800032f6:	64b8                	ld	a4,72(s1)
    800032f8:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800032fa:	64bc                	ld	a5,72(s1)
    800032fc:	68b8                	ld	a4,80(s1)
    800032fe:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003300:	0001c797          	auipc	a5,0x1c
    80003304:	e8878793          	addi	a5,a5,-376 # 8001f188 <bcache+0x8000>
    80003308:	2b87b703          	ld	a4,696(a5)
    8000330c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000330e:	0001c717          	auipc	a4,0x1c
    80003312:	0e270713          	addi	a4,a4,226 # 8001f3f0 <bcache+0x8268>
    80003316:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003318:	2b87b703          	ld	a4,696(a5)
    8000331c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000331e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003322:	00014517          	auipc	a0,0x14
    80003326:	e6650513          	addi	a0,a0,-410 # 80017188 <bcache>
    8000332a:	ffffe097          	auipc	ra,0xffffe
    8000332e:	960080e7          	jalr	-1696(ra) # 80000c8a <release>
}
    80003332:	60e2                	ld	ra,24(sp)
    80003334:	6442                	ld	s0,16(sp)
    80003336:	64a2                	ld	s1,8(sp)
    80003338:	6902                	ld	s2,0(sp)
    8000333a:	6105                	addi	sp,sp,32
    8000333c:	8082                	ret
    panic("brelse");
    8000333e:	00005517          	auipc	a0,0x5
    80003342:	34250513          	addi	a0,a0,834 # 80008680 <syscallnum+0x90>
    80003346:	ffffd097          	auipc	ra,0xffffd
    8000334a:	1f8080e7          	jalr	504(ra) # 8000053e <panic>

000000008000334e <bpin>:

void
bpin(struct buf *b) {
    8000334e:	1101                	addi	sp,sp,-32
    80003350:	ec06                	sd	ra,24(sp)
    80003352:	e822                	sd	s0,16(sp)
    80003354:	e426                	sd	s1,8(sp)
    80003356:	1000                	addi	s0,sp,32
    80003358:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000335a:	00014517          	auipc	a0,0x14
    8000335e:	e2e50513          	addi	a0,a0,-466 # 80017188 <bcache>
    80003362:	ffffe097          	auipc	ra,0xffffe
    80003366:	874080e7          	jalr	-1932(ra) # 80000bd6 <acquire>
  b->refcnt++;
    8000336a:	40bc                	lw	a5,64(s1)
    8000336c:	2785                	addiw	a5,a5,1
    8000336e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003370:	00014517          	auipc	a0,0x14
    80003374:	e1850513          	addi	a0,a0,-488 # 80017188 <bcache>
    80003378:	ffffe097          	auipc	ra,0xffffe
    8000337c:	912080e7          	jalr	-1774(ra) # 80000c8a <release>
}
    80003380:	60e2                	ld	ra,24(sp)
    80003382:	6442                	ld	s0,16(sp)
    80003384:	64a2                	ld	s1,8(sp)
    80003386:	6105                	addi	sp,sp,32
    80003388:	8082                	ret

000000008000338a <bunpin>:

void
bunpin(struct buf *b) {
    8000338a:	1101                	addi	sp,sp,-32
    8000338c:	ec06                	sd	ra,24(sp)
    8000338e:	e822                	sd	s0,16(sp)
    80003390:	e426                	sd	s1,8(sp)
    80003392:	1000                	addi	s0,sp,32
    80003394:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003396:	00014517          	auipc	a0,0x14
    8000339a:	df250513          	addi	a0,a0,-526 # 80017188 <bcache>
    8000339e:	ffffe097          	auipc	ra,0xffffe
    800033a2:	838080e7          	jalr	-1992(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800033a6:	40bc                	lw	a5,64(s1)
    800033a8:	37fd                	addiw	a5,a5,-1
    800033aa:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800033ac:	00014517          	auipc	a0,0x14
    800033b0:	ddc50513          	addi	a0,a0,-548 # 80017188 <bcache>
    800033b4:	ffffe097          	auipc	ra,0xffffe
    800033b8:	8d6080e7          	jalr	-1834(ra) # 80000c8a <release>
}
    800033bc:	60e2                	ld	ra,24(sp)
    800033be:	6442                	ld	s0,16(sp)
    800033c0:	64a2                	ld	s1,8(sp)
    800033c2:	6105                	addi	sp,sp,32
    800033c4:	8082                	ret

00000000800033c6 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800033c6:	1101                	addi	sp,sp,-32
    800033c8:	ec06                	sd	ra,24(sp)
    800033ca:	e822                	sd	s0,16(sp)
    800033cc:	e426                	sd	s1,8(sp)
    800033ce:	e04a                	sd	s2,0(sp)
    800033d0:	1000                	addi	s0,sp,32
    800033d2:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800033d4:	00d5d59b          	srliw	a1,a1,0xd
    800033d8:	0001c797          	auipc	a5,0x1c
    800033dc:	48c7a783          	lw	a5,1164(a5) # 8001f864 <sb+0x1c>
    800033e0:	9dbd                	addw	a1,a1,a5
    800033e2:	00000097          	auipc	ra,0x0
    800033e6:	d9e080e7          	jalr	-610(ra) # 80003180 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800033ea:	0074f713          	andi	a4,s1,7
    800033ee:	4785                	li	a5,1
    800033f0:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800033f4:	14ce                	slli	s1,s1,0x33
    800033f6:	90d9                	srli	s1,s1,0x36
    800033f8:	00950733          	add	a4,a0,s1
    800033fc:	05874703          	lbu	a4,88(a4)
    80003400:	00e7f6b3          	and	a3,a5,a4
    80003404:	c69d                	beqz	a3,80003432 <bfree+0x6c>
    80003406:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003408:	94aa                	add	s1,s1,a0
    8000340a:	fff7c793          	not	a5,a5
    8000340e:	8ff9                	and	a5,a5,a4
    80003410:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003414:	00001097          	auipc	ra,0x1
    80003418:	120080e7          	jalr	288(ra) # 80004534 <log_write>
  brelse(bp);
    8000341c:	854a                	mv	a0,s2
    8000341e:	00000097          	auipc	ra,0x0
    80003422:	e92080e7          	jalr	-366(ra) # 800032b0 <brelse>
}
    80003426:	60e2                	ld	ra,24(sp)
    80003428:	6442                	ld	s0,16(sp)
    8000342a:	64a2                	ld	s1,8(sp)
    8000342c:	6902                	ld	s2,0(sp)
    8000342e:	6105                	addi	sp,sp,32
    80003430:	8082                	ret
    panic("freeing free block");
    80003432:	00005517          	auipc	a0,0x5
    80003436:	25650513          	addi	a0,a0,598 # 80008688 <syscallnum+0x98>
    8000343a:	ffffd097          	auipc	ra,0xffffd
    8000343e:	104080e7          	jalr	260(ra) # 8000053e <panic>

0000000080003442 <balloc>:
{
    80003442:	711d                	addi	sp,sp,-96
    80003444:	ec86                	sd	ra,88(sp)
    80003446:	e8a2                	sd	s0,80(sp)
    80003448:	e4a6                	sd	s1,72(sp)
    8000344a:	e0ca                	sd	s2,64(sp)
    8000344c:	fc4e                	sd	s3,56(sp)
    8000344e:	f852                	sd	s4,48(sp)
    80003450:	f456                	sd	s5,40(sp)
    80003452:	f05a                	sd	s6,32(sp)
    80003454:	ec5e                	sd	s7,24(sp)
    80003456:	e862                	sd	s8,16(sp)
    80003458:	e466                	sd	s9,8(sp)
    8000345a:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000345c:	0001c797          	auipc	a5,0x1c
    80003460:	3f07a783          	lw	a5,1008(a5) # 8001f84c <sb+0x4>
    80003464:	10078163          	beqz	a5,80003566 <balloc+0x124>
    80003468:	8baa                	mv	s7,a0
    8000346a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000346c:	0001cb17          	auipc	s6,0x1c
    80003470:	3dcb0b13          	addi	s6,s6,988 # 8001f848 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003474:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003476:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003478:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000347a:	6c89                	lui	s9,0x2
    8000347c:	a061                	j	80003504 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000347e:	974a                	add	a4,a4,s2
    80003480:	8fd5                	or	a5,a5,a3
    80003482:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003486:	854a                	mv	a0,s2
    80003488:	00001097          	auipc	ra,0x1
    8000348c:	0ac080e7          	jalr	172(ra) # 80004534 <log_write>
        brelse(bp);
    80003490:	854a                	mv	a0,s2
    80003492:	00000097          	auipc	ra,0x0
    80003496:	e1e080e7          	jalr	-482(ra) # 800032b0 <brelse>
  bp = bread(dev, bno);
    8000349a:	85a6                	mv	a1,s1
    8000349c:	855e                	mv	a0,s7
    8000349e:	00000097          	auipc	ra,0x0
    800034a2:	ce2080e7          	jalr	-798(ra) # 80003180 <bread>
    800034a6:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800034a8:	40000613          	li	a2,1024
    800034ac:	4581                	li	a1,0
    800034ae:	05850513          	addi	a0,a0,88
    800034b2:	ffffe097          	auipc	ra,0xffffe
    800034b6:	820080e7          	jalr	-2016(ra) # 80000cd2 <memset>
  log_write(bp);
    800034ba:	854a                	mv	a0,s2
    800034bc:	00001097          	auipc	ra,0x1
    800034c0:	078080e7          	jalr	120(ra) # 80004534 <log_write>
  brelse(bp);
    800034c4:	854a                	mv	a0,s2
    800034c6:	00000097          	auipc	ra,0x0
    800034ca:	dea080e7          	jalr	-534(ra) # 800032b0 <brelse>
}
    800034ce:	8526                	mv	a0,s1
    800034d0:	60e6                	ld	ra,88(sp)
    800034d2:	6446                	ld	s0,80(sp)
    800034d4:	64a6                	ld	s1,72(sp)
    800034d6:	6906                	ld	s2,64(sp)
    800034d8:	79e2                	ld	s3,56(sp)
    800034da:	7a42                	ld	s4,48(sp)
    800034dc:	7aa2                	ld	s5,40(sp)
    800034de:	7b02                	ld	s6,32(sp)
    800034e0:	6be2                	ld	s7,24(sp)
    800034e2:	6c42                	ld	s8,16(sp)
    800034e4:	6ca2                	ld	s9,8(sp)
    800034e6:	6125                	addi	sp,sp,96
    800034e8:	8082                	ret
    brelse(bp);
    800034ea:	854a                	mv	a0,s2
    800034ec:	00000097          	auipc	ra,0x0
    800034f0:	dc4080e7          	jalr	-572(ra) # 800032b0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800034f4:	015c87bb          	addw	a5,s9,s5
    800034f8:	00078a9b          	sext.w	s5,a5
    800034fc:	004b2703          	lw	a4,4(s6)
    80003500:	06eaf363          	bgeu	s5,a4,80003566 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003504:	41fad79b          	sraiw	a5,s5,0x1f
    80003508:	0137d79b          	srliw	a5,a5,0x13
    8000350c:	015787bb          	addw	a5,a5,s5
    80003510:	40d7d79b          	sraiw	a5,a5,0xd
    80003514:	01cb2583          	lw	a1,28(s6)
    80003518:	9dbd                	addw	a1,a1,a5
    8000351a:	855e                	mv	a0,s7
    8000351c:	00000097          	auipc	ra,0x0
    80003520:	c64080e7          	jalr	-924(ra) # 80003180 <bread>
    80003524:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003526:	004b2503          	lw	a0,4(s6)
    8000352a:	000a849b          	sext.w	s1,s5
    8000352e:	8662                	mv	a2,s8
    80003530:	faa4fde3          	bgeu	s1,a0,800034ea <balloc+0xa8>
      m = 1 << (bi % 8);
    80003534:	41f6579b          	sraiw	a5,a2,0x1f
    80003538:	01d7d69b          	srliw	a3,a5,0x1d
    8000353c:	00c6873b          	addw	a4,a3,a2
    80003540:	00777793          	andi	a5,a4,7
    80003544:	9f95                	subw	a5,a5,a3
    80003546:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000354a:	4037571b          	sraiw	a4,a4,0x3
    8000354e:	00e906b3          	add	a3,s2,a4
    80003552:	0586c683          	lbu	a3,88(a3)
    80003556:	00d7f5b3          	and	a1,a5,a3
    8000355a:	d195                	beqz	a1,8000347e <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000355c:	2605                	addiw	a2,a2,1
    8000355e:	2485                	addiw	s1,s1,1
    80003560:	fd4618e3          	bne	a2,s4,80003530 <balloc+0xee>
    80003564:	b759                	j	800034ea <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003566:	00005517          	auipc	a0,0x5
    8000356a:	13a50513          	addi	a0,a0,314 # 800086a0 <syscallnum+0xb0>
    8000356e:	ffffd097          	auipc	ra,0xffffd
    80003572:	01a080e7          	jalr	26(ra) # 80000588 <printf>
  return 0;
    80003576:	4481                	li	s1,0
    80003578:	bf99                	j	800034ce <balloc+0x8c>

000000008000357a <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000357a:	7179                	addi	sp,sp,-48
    8000357c:	f406                	sd	ra,40(sp)
    8000357e:	f022                	sd	s0,32(sp)
    80003580:	ec26                	sd	s1,24(sp)
    80003582:	e84a                	sd	s2,16(sp)
    80003584:	e44e                	sd	s3,8(sp)
    80003586:	e052                	sd	s4,0(sp)
    80003588:	1800                	addi	s0,sp,48
    8000358a:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000358c:	47ad                	li	a5,11
    8000358e:	02b7e763          	bltu	a5,a1,800035bc <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003592:	02059493          	slli	s1,a1,0x20
    80003596:	9081                	srli	s1,s1,0x20
    80003598:	048a                	slli	s1,s1,0x2
    8000359a:	94aa                	add	s1,s1,a0
    8000359c:	0504a903          	lw	s2,80(s1)
    800035a0:	06091e63          	bnez	s2,8000361c <bmap+0xa2>
      addr = balloc(ip->dev);
    800035a4:	4108                	lw	a0,0(a0)
    800035a6:	00000097          	auipc	ra,0x0
    800035aa:	e9c080e7          	jalr	-356(ra) # 80003442 <balloc>
    800035ae:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800035b2:	06090563          	beqz	s2,8000361c <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    800035b6:	0524a823          	sw	s2,80(s1)
    800035ba:	a08d                	j	8000361c <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    800035bc:	ff45849b          	addiw	s1,a1,-12
    800035c0:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800035c4:	0ff00793          	li	a5,255
    800035c8:	08e7e563          	bltu	a5,a4,80003652 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800035cc:	08052903          	lw	s2,128(a0)
    800035d0:	00091d63          	bnez	s2,800035ea <bmap+0x70>
      addr = balloc(ip->dev);
    800035d4:	4108                	lw	a0,0(a0)
    800035d6:	00000097          	auipc	ra,0x0
    800035da:	e6c080e7          	jalr	-404(ra) # 80003442 <balloc>
    800035de:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800035e2:	02090d63          	beqz	s2,8000361c <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800035e6:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800035ea:	85ca                	mv	a1,s2
    800035ec:	0009a503          	lw	a0,0(s3)
    800035f0:	00000097          	auipc	ra,0x0
    800035f4:	b90080e7          	jalr	-1136(ra) # 80003180 <bread>
    800035f8:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800035fa:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800035fe:	02049593          	slli	a1,s1,0x20
    80003602:	9181                	srli	a1,a1,0x20
    80003604:	058a                	slli	a1,a1,0x2
    80003606:	00b784b3          	add	s1,a5,a1
    8000360a:	0004a903          	lw	s2,0(s1)
    8000360e:	02090063          	beqz	s2,8000362e <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003612:	8552                	mv	a0,s4
    80003614:	00000097          	auipc	ra,0x0
    80003618:	c9c080e7          	jalr	-868(ra) # 800032b0 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000361c:	854a                	mv	a0,s2
    8000361e:	70a2                	ld	ra,40(sp)
    80003620:	7402                	ld	s0,32(sp)
    80003622:	64e2                	ld	s1,24(sp)
    80003624:	6942                	ld	s2,16(sp)
    80003626:	69a2                	ld	s3,8(sp)
    80003628:	6a02                	ld	s4,0(sp)
    8000362a:	6145                	addi	sp,sp,48
    8000362c:	8082                	ret
      addr = balloc(ip->dev);
    8000362e:	0009a503          	lw	a0,0(s3)
    80003632:	00000097          	auipc	ra,0x0
    80003636:	e10080e7          	jalr	-496(ra) # 80003442 <balloc>
    8000363a:	0005091b          	sext.w	s2,a0
      if(addr){
    8000363e:	fc090ae3          	beqz	s2,80003612 <bmap+0x98>
        a[bn] = addr;
    80003642:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003646:	8552                	mv	a0,s4
    80003648:	00001097          	auipc	ra,0x1
    8000364c:	eec080e7          	jalr	-276(ra) # 80004534 <log_write>
    80003650:	b7c9                	j	80003612 <bmap+0x98>
  panic("bmap: out of range");
    80003652:	00005517          	auipc	a0,0x5
    80003656:	06650513          	addi	a0,a0,102 # 800086b8 <syscallnum+0xc8>
    8000365a:	ffffd097          	auipc	ra,0xffffd
    8000365e:	ee4080e7          	jalr	-284(ra) # 8000053e <panic>

0000000080003662 <iget>:
{
    80003662:	7179                	addi	sp,sp,-48
    80003664:	f406                	sd	ra,40(sp)
    80003666:	f022                	sd	s0,32(sp)
    80003668:	ec26                	sd	s1,24(sp)
    8000366a:	e84a                	sd	s2,16(sp)
    8000366c:	e44e                	sd	s3,8(sp)
    8000366e:	e052                	sd	s4,0(sp)
    80003670:	1800                	addi	s0,sp,48
    80003672:	89aa                	mv	s3,a0
    80003674:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003676:	0001c517          	auipc	a0,0x1c
    8000367a:	1f250513          	addi	a0,a0,498 # 8001f868 <itable>
    8000367e:	ffffd097          	auipc	ra,0xffffd
    80003682:	558080e7          	jalr	1368(ra) # 80000bd6 <acquire>
  empty = 0;
    80003686:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003688:	0001c497          	auipc	s1,0x1c
    8000368c:	1f848493          	addi	s1,s1,504 # 8001f880 <itable+0x18>
    80003690:	0001e697          	auipc	a3,0x1e
    80003694:	c8068693          	addi	a3,a3,-896 # 80021310 <log>
    80003698:	a039                	j	800036a6 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000369a:	02090b63          	beqz	s2,800036d0 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000369e:	08848493          	addi	s1,s1,136
    800036a2:	02d48a63          	beq	s1,a3,800036d6 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800036a6:	449c                	lw	a5,8(s1)
    800036a8:	fef059e3          	blez	a5,8000369a <iget+0x38>
    800036ac:	4098                	lw	a4,0(s1)
    800036ae:	ff3716e3          	bne	a4,s3,8000369a <iget+0x38>
    800036b2:	40d8                	lw	a4,4(s1)
    800036b4:	ff4713e3          	bne	a4,s4,8000369a <iget+0x38>
      ip->ref++;
    800036b8:	2785                	addiw	a5,a5,1
    800036ba:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800036bc:	0001c517          	auipc	a0,0x1c
    800036c0:	1ac50513          	addi	a0,a0,428 # 8001f868 <itable>
    800036c4:	ffffd097          	auipc	ra,0xffffd
    800036c8:	5c6080e7          	jalr	1478(ra) # 80000c8a <release>
      return ip;
    800036cc:	8926                	mv	s2,s1
    800036ce:	a03d                	j	800036fc <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800036d0:	f7f9                	bnez	a5,8000369e <iget+0x3c>
    800036d2:	8926                	mv	s2,s1
    800036d4:	b7e9                	j	8000369e <iget+0x3c>
  if(empty == 0)
    800036d6:	02090c63          	beqz	s2,8000370e <iget+0xac>
  ip->dev = dev;
    800036da:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800036de:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800036e2:	4785                	li	a5,1
    800036e4:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800036e8:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800036ec:	0001c517          	auipc	a0,0x1c
    800036f0:	17c50513          	addi	a0,a0,380 # 8001f868 <itable>
    800036f4:	ffffd097          	auipc	ra,0xffffd
    800036f8:	596080e7          	jalr	1430(ra) # 80000c8a <release>
}
    800036fc:	854a                	mv	a0,s2
    800036fe:	70a2                	ld	ra,40(sp)
    80003700:	7402                	ld	s0,32(sp)
    80003702:	64e2                	ld	s1,24(sp)
    80003704:	6942                	ld	s2,16(sp)
    80003706:	69a2                	ld	s3,8(sp)
    80003708:	6a02                	ld	s4,0(sp)
    8000370a:	6145                	addi	sp,sp,48
    8000370c:	8082                	ret
    panic("iget: no inodes");
    8000370e:	00005517          	auipc	a0,0x5
    80003712:	fc250513          	addi	a0,a0,-62 # 800086d0 <syscallnum+0xe0>
    80003716:	ffffd097          	auipc	ra,0xffffd
    8000371a:	e28080e7          	jalr	-472(ra) # 8000053e <panic>

000000008000371e <fsinit>:
fsinit(int dev) {
    8000371e:	7179                	addi	sp,sp,-48
    80003720:	f406                	sd	ra,40(sp)
    80003722:	f022                	sd	s0,32(sp)
    80003724:	ec26                	sd	s1,24(sp)
    80003726:	e84a                	sd	s2,16(sp)
    80003728:	e44e                	sd	s3,8(sp)
    8000372a:	1800                	addi	s0,sp,48
    8000372c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000372e:	4585                	li	a1,1
    80003730:	00000097          	auipc	ra,0x0
    80003734:	a50080e7          	jalr	-1456(ra) # 80003180 <bread>
    80003738:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000373a:	0001c997          	auipc	s3,0x1c
    8000373e:	10e98993          	addi	s3,s3,270 # 8001f848 <sb>
    80003742:	02000613          	li	a2,32
    80003746:	05850593          	addi	a1,a0,88
    8000374a:	854e                	mv	a0,s3
    8000374c:	ffffd097          	auipc	ra,0xffffd
    80003750:	5e2080e7          	jalr	1506(ra) # 80000d2e <memmove>
  brelse(bp);
    80003754:	8526                	mv	a0,s1
    80003756:	00000097          	auipc	ra,0x0
    8000375a:	b5a080e7          	jalr	-1190(ra) # 800032b0 <brelse>
  if(sb.magic != FSMAGIC)
    8000375e:	0009a703          	lw	a4,0(s3)
    80003762:	102037b7          	lui	a5,0x10203
    80003766:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000376a:	02f71263          	bne	a4,a5,8000378e <fsinit+0x70>
  initlog(dev, &sb);
    8000376e:	0001c597          	auipc	a1,0x1c
    80003772:	0da58593          	addi	a1,a1,218 # 8001f848 <sb>
    80003776:	854a                	mv	a0,s2
    80003778:	00001097          	auipc	ra,0x1
    8000377c:	b40080e7          	jalr	-1216(ra) # 800042b8 <initlog>
}
    80003780:	70a2                	ld	ra,40(sp)
    80003782:	7402                	ld	s0,32(sp)
    80003784:	64e2                	ld	s1,24(sp)
    80003786:	6942                	ld	s2,16(sp)
    80003788:	69a2                	ld	s3,8(sp)
    8000378a:	6145                	addi	sp,sp,48
    8000378c:	8082                	ret
    panic("invalid file system");
    8000378e:	00005517          	auipc	a0,0x5
    80003792:	f5250513          	addi	a0,a0,-174 # 800086e0 <syscallnum+0xf0>
    80003796:	ffffd097          	auipc	ra,0xffffd
    8000379a:	da8080e7          	jalr	-600(ra) # 8000053e <panic>

000000008000379e <iinit>:
{
    8000379e:	7179                	addi	sp,sp,-48
    800037a0:	f406                	sd	ra,40(sp)
    800037a2:	f022                	sd	s0,32(sp)
    800037a4:	ec26                	sd	s1,24(sp)
    800037a6:	e84a                	sd	s2,16(sp)
    800037a8:	e44e                	sd	s3,8(sp)
    800037aa:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800037ac:	00005597          	auipc	a1,0x5
    800037b0:	f4c58593          	addi	a1,a1,-180 # 800086f8 <syscallnum+0x108>
    800037b4:	0001c517          	auipc	a0,0x1c
    800037b8:	0b450513          	addi	a0,a0,180 # 8001f868 <itable>
    800037bc:	ffffd097          	auipc	ra,0xffffd
    800037c0:	38a080e7          	jalr	906(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    800037c4:	0001c497          	auipc	s1,0x1c
    800037c8:	0cc48493          	addi	s1,s1,204 # 8001f890 <itable+0x28>
    800037cc:	0001e997          	auipc	s3,0x1e
    800037d0:	b5498993          	addi	s3,s3,-1196 # 80021320 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800037d4:	00005917          	auipc	s2,0x5
    800037d8:	f2c90913          	addi	s2,s2,-212 # 80008700 <syscallnum+0x110>
    800037dc:	85ca                	mv	a1,s2
    800037de:	8526                	mv	a0,s1
    800037e0:	00001097          	auipc	ra,0x1
    800037e4:	e3a080e7          	jalr	-454(ra) # 8000461a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800037e8:	08848493          	addi	s1,s1,136
    800037ec:	ff3498e3          	bne	s1,s3,800037dc <iinit+0x3e>
}
    800037f0:	70a2                	ld	ra,40(sp)
    800037f2:	7402                	ld	s0,32(sp)
    800037f4:	64e2                	ld	s1,24(sp)
    800037f6:	6942                	ld	s2,16(sp)
    800037f8:	69a2                	ld	s3,8(sp)
    800037fa:	6145                	addi	sp,sp,48
    800037fc:	8082                	ret

00000000800037fe <ialloc>:
{
    800037fe:	715d                	addi	sp,sp,-80
    80003800:	e486                	sd	ra,72(sp)
    80003802:	e0a2                	sd	s0,64(sp)
    80003804:	fc26                	sd	s1,56(sp)
    80003806:	f84a                	sd	s2,48(sp)
    80003808:	f44e                	sd	s3,40(sp)
    8000380a:	f052                	sd	s4,32(sp)
    8000380c:	ec56                	sd	s5,24(sp)
    8000380e:	e85a                	sd	s6,16(sp)
    80003810:	e45e                	sd	s7,8(sp)
    80003812:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003814:	0001c717          	auipc	a4,0x1c
    80003818:	04072703          	lw	a4,64(a4) # 8001f854 <sb+0xc>
    8000381c:	4785                	li	a5,1
    8000381e:	04e7fa63          	bgeu	a5,a4,80003872 <ialloc+0x74>
    80003822:	8aaa                	mv	s5,a0
    80003824:	8bae                	mv	s7,a1
    80003826:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003828:	0001ca17          	auipc	s4,0x1c
    8000382c:	020a0a13          	addi	s4,s4,32 # 8001f848 <sb>
    80003830:	00048b1b          	sext.w	s6,s1
    80003834:	0044d793          	srli	a5,s1,0x4
    80003838:	018a2583          	lw	a1,24(s4)
    8000383c:	9dbd                	addw	a1,a1,a5
    8000383e:	8556                	mv	a0,s5
    80003840:	00000097          	auipc	ra,0x0
    80003844:	940080e7          	jalr	-1728(ra) # 80003180 <bread>
    80003848:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000384a:	05850993          	addi	s3,a0,88
    8000384e:	00f4f793          	andi	a5,s1,15
    80003852:	079a                	slli	a5,a5,0x6
    80003854:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003856:	00099783          	lh	a5,0(s3)
    8000385a:	c3a1                	beqz	a5,8000389a <ialloc+0x9c>
    brelse(bp);
    8000385c:	00000097          	auipc	ra,0x0
    80003860:	a54080e7          	jalr	-1452(ra) # 800032b0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003864:	0485                	addi	s1,s1,1
    80003866:	00ca2703          	lw	a4,12(s4)
    8000386a:	0004879b          	sext.w	a5,s1
    8000386e:	fce7e1e3          	bltu	a5,a4,80003830 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003872:	00005517          	auipc	a0,0x5
    80003876:	e9650513          	addi	a0,a0,-362 # 80008708 <syscallnum+0x118>
    8000387a:	ffffd097          	auipc	ra,0xffffd
    8000387e:	d0e080e7          	jalr	-754(ra) # 80000588 <printf>
  return 0;
    80003882:	4501                	li	a0,0
}
    80003884:	60a6                	ld	ra,72(sp)
    80003886:	6406                	ld	s0,64(sp)
    80003888:	74e2                	ld	s1,56(sp)
    8000388a:	7942                	ld	s2,48(sp)
    8000388c:	79a2                	ld	s3,40(sp)
    8000388e:	7a02                	ld	s4,32(sp)
    80003890:	6ae2                	ld	s5,24(sp)
    80003892:	6b42                	ld	s6,16(sp)
    80003894:	6ba2                	ld	s7,8(sp)
    80003896:	6161                	addi	sp,sp,80
    80003898:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000389a:	04000613          	li	a2,64
    8000389e:	4581                	li	a1,0
    800038a0:	854e                	mv	a0,s3
    800038a2:	ffffd097          	auipc	ra,0xffffd
    800038a6:	430080e7          	jalr	1072(ra) # 80000cd2 <memset>
      dip->type = type;
    800038aa:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800038ae:	854a                	mv	a0,s2
    800038b0:	00001097          	auipc	ra,0x1
    800038b4:	c84080e7          	jalr	-892(ra) # 80004534 <log_write>
      brelse(bp);
    800038b8:	854a                	mv	a0,s2
    800038ba:	00000097          	auipc	ra,0x0
    800038be:	9f6080e7          	jalr	-1546(ra) # 800032b0 <brelse>
      return iget(dev, inum);
    800038c2:	85da                	mv	a1,s6
    800038c4:	8556                	mv	a0,s5
    800038c6:	00000097          	auipc	ra,0x0
    800038ca:	d9c080e7          	jalr	-612(ra) # 80003662 <iget>
    800038ce:	bf5d                	j	80003884 <ialloc+0x86>

00000000800038d0 <iupdate>:
{
    800038d0:	1101                	addi	sp,sp,-32
    800038d2:	ec06                	sd	ra,24(sp)
    800038d4:	e822                	sd	s0,16(sp)
    800038d6:	e426                	sd	s1,8(sp)
    800038d8:	e04a                	sd	s2,0(sp)
    800038da:	1000                	addi	s0,sp,32
    800038dc:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800038de:	415c                	lw	a5,4(a0)
    800038e0:	0047d79b          	srliw	a5,a5,0x4
    800038e4:	0001c597          	auipc	a1,0x1c
    800038e8:	f7c5a583          	lw	a1,-132(a1) # 8001f860 <sb+0x18>
    800038ec:	9dbd                	addw	a1,a1,a5
    800038ee:	4108                	lw	a0,0(a0)
    800038f0:	00000097          	auipc	ra,0x0
    800038f4:	890080e7          	jalr	-1904(ra) # 80003180 <bread>
    800038f8:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038fa:	05850793          	addi	a5,a0,88
    800038fe:	40c8                	lw	a0,4(s1)
    80003900:	893d                	andi	a0,a0,15
    80003902:	051a                	slli	a0,a0,0x6
    80003904:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003906:	04449703          	lh	a4,68(s1)
    8000390a:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    8000390e:	04649703          	lh	a4,70(s1)
    80003912:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003916:	04849703          	lh	a4,72(s1)
    8000391a:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    8000391e:	04a49703          	lh	a4,74(s1)
    80003922:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003926:	44f8                	lw	a4,76(s1)
    80003928:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000392a:	03400613          	li	a2,52
    8000392e:	05048593          	addi	a1,s1,80
    80003932:	0531                	addi	a0,a0,12
    80003934:	ffffd097          	auipc	ra,0xffffd
    80003938:	3fa080e7          	jalr	1018(ra) # 80000d2e <memmove>
  log_write(bp);
    8000393c:	854a                	mv	a0,s2
    8000393e:	00001097          	auipc	ra,0x1
    80003942:	bf6080e7          	jalr	-1034(ra) # 80004534 <log_write>
  brelse(bp);
    80003946:	854a                	mv	a0,s2
    80003948:	00000097          	auipc	ra,0x0
    8000394c:	968080e7          	jalr	-1688(ra) # 800032b0 <brelse>
}
    80003950:	60e2                	ld	ra,24(sp)
    80003952:	6442                	ld	s0,16(sp)
    80003954:	64a2                	ld	s1,8(sp)
    80003956:	6902                	ld	s2,0(sp)
    80003958:	6105                	addi	sp,sp,32
    8000395a:	8082                	ret

000000008000395c <idup>:
{
    8000395c:	1101                	addi	sp,sp,-32
    8000395e:	ec06                	sd	ra,24(sp)
    80003960:	e822                	sd	s0,16(sp)
    80003962:	e426                	sd	s1,8(sp)
    80003964:	1000                	addi	s0,sp,32
    80003966:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003968:	0001c517          	auipc	a0,0x1c
    8000396c:	f0050513          	addi	a0,a0,-256 # 8001f868 <itable>
    80003970:	ffffd097          	auipc	ra,0xffffd
    80003974:	266080e7          	jalr	614(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003978:	449c                	lw	a5,8(s1)
    8000397a:	2785                	addiw	a5,a5,1
    8000397c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000397e:	0001c517          	auipc	a0,0x1c
    80003982:	eea50513          	addi	a0,a0,-278 # 8001f868 <itable>
    80003986:	ffffd097          	auipc	ra,0xffffd
    8000398a:	304080e7          	jalr	772(ra) # 80000c8a <release>
}
    8000398e:	8526                	mv	a0,s1
    80003990:	60e2                	ld	ra,24(sp)
    80003992:	6442                	ld	s0,16(sp)
    80003994:	64a2                	ld	s1,8(sp)
    80003996:	6105                	addi	sp,sp,32
    80003998:	8082                	ret

000000008000399a <ilock>:
{
    8000399a:	1101                	addi	sp,sp,-32
    8000399c:	ec06                	sd	ra,24(sp)
    8000399e:	e822                	sd	s0,16(sp)
    800039a0:	e426                	sd	s1,8(sp)
    800039a2:	e04a                	sd	s2,0(sp)
    800039a4:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800039a6:	c115                	beqz	a0,800039ca <ilock+0x30>
    800039a8:	84aa                	mv	s1,a0
    800039aa:	451c                	lw	a5,8(a0)
    800039ac:	00f05f63          	blez	a5,800039ca <ilock+0x30>
  acquiresleep(&ip->lock);
    800039b0:	0541                	addi	a0,a0,16
    800039b2:	00001097          	auipc	ra,0x1
    800039b6:	ca2080e7          	jalr	-862(ra) # 80004654 <acquiresleep>
  if(ip->valid == 0){
    800039ba:	40bc                	lw	a5,64(s1)
    800039bc:	cf99                	beqz	a5,800039da <ilock+0x40>
}
    800039be:	60e2                	ld	ra,24(sp)
    800039c0:	6442                	ld	s0,16(sp)
    800039c2:	64a2                	ld	s1,8(sp)
    800039c4:	6902                	ld	s2,0(sp)
    800039c6:	6105                	addi	sp,sp,32
    800039c8:	8082                	ret
    panic("ilock");
    800039ca:	00005517          	auipc	a0,0x5
    800039ce:	d5650513          	addi	a0,a0,-682 # 80008720 <syscallnum+0x130>
    800039d2:	ffffd097          	auipc	ra,0xffffd
    800039d6:	b6c080e7          	jalr	-1172(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800039da:	40dc                	lw	a5,4(s1)
    800039dc:	0047d79b          	srliw	a5,a5,0x4
    800039e0:	0001c597          	auipc	a1,0x1c
    800039e4:	e805a583          	lw	a1,-384(a1) # 8001f860 <sb+0x18>
    800039e8:	9dbd                	addw	a1,a1,a5
    800039ea:	4088                	lw	a0,0(s1)
    800039ec:	fffff097          	auipc	ra,0xfffff
    800039f0:	794080e7          	jalr	1940(ra) # 80003180 <bread>
    800039f4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800039f6:	05850593          	addi	a1,a0,88
    800039fa:	40dc                	lw	a5,4(s1)
    800039fc:	8bbd                	andi	a5,a5,15
    800039fe:	079a                	slli	a5,a5,0x6
    80003a00:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003a02:	00059783          	lh	a5,0(a1)
    80003a06:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003a0a:	00259783          	lh	a5,2(a1)
    80003a0e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003a12:	00459783          	lh	a5,4(a1)
    80003a16:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003a1a:	00659783          	lh	a5,6(a1)
    80003a1e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003a22:	459c                	lw	a5,8(a1)
    80003a24:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003a26:	03400613          	li	a2,52
    80003a2a:	05b1                	addi	a1,a1,12
    80003a2c:	05048513          	addi	a0,s1,80
    80003a30:	ffffd097          	auipc	ra,0xffffd
    80003a34:	2fe080e7          	jalr	766(ra) # 80000d2e <memmove>
    brelse(bp);
    80003a38:	854a                	mv	a0,s2
    80003a3a:	00000097          	auipc	ra,0x0
    80003a3e:	876080e7          	jalr	-1930(ra) # 800032b0 <brelse>
    ip->valid = 1;
    80003a42:	4785                	li	a5,1
    80003a44:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003a46:	04449783          	lh	a5,68(s1)
    80003a4a:	fbb5                	bnez	a5,800039be <ilock+0x24>
      panic("ilock: no type");
    80003a4c:	00005517          	auipc	a0,0x5
    80003a50:	cdc50513          	addi	a0,a0,-804 # 80008728 <syscallnum+0x138>
    80003a54:	ffffd097          	auipc	ra,0xffffd
    80003a58:	aea080e7          	jalr	-1302(ra) # 8000053e <panic>

0000000080003a5c <iunlock>:
{
    80003a5c:	1101                	addi	sp,sp,-32
    80003a5e:	ec06                	sd	ra,24(sp)
    80003a60:	e822                	sd	s0,16(sp)
    80003a62:	e426                	sd	s1,8(sp)
    80003a64:	e04a                	sd	s2,0(sp)
    80003a66:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003a68:	c905                	beqz	a0,80003a98 <iunlock+0x3c>
    80003a6a:	84aa                	mv	s1,a0
    80003a6c:	01050913          	addi	s2,a0,16
    80003a70:	854a                	mv	a0,s2
    80003a72:	00001097          	auipc	ra,0x1
    80003a76:	c7c080e7          	jalr	-900(ra) # 800046ee <holdingsleep>
    80003a7a:	cd19                	beqz	a0,80003a98 <iunlock+0x3c>
    80003a7c:	449c                	lw	a5,8(s1)
    80003a7e:	00f05d63          	blez	a5,80003a98 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003a82:	854a                	mv	a0,s2
    80003a84:	00001097          	auipc	ra,0x1
    80003a88:	c26080e7          	jalr	-986(ra) # 800046aa <releasesleep>
}
    80003a8c:	60e2                	ld	ra,24(sp)
    80003a8e:	6442                	ld	s0,16(sp)
    80003a90:	64a2                	ld	s1,8(sp)
    80003a92:	6902                	ld	s2,0(sp)
    80003a94:	6105                	addi	sp,sp,32
    80003a96:	8082                	ret
    panic("iunlock");
    80003a98:	00005517          	auipc	a0,0x5
    80003a9c:	ca050513          	addi	a0,a0,-864 # 80008738 <syscallnum+0x148>
    80003aa0:	ffffd097          	auipc	ra,0xffffd
    80003aa4:	a9e080e7          	jalr	-1378(ra) # 8000053e <panic>

0000000080003aa8 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003aa8:	7179                	addi	sp,sp,-48
    80003aaa:	f406                	sd	ra,40(sp)
    80003aac:	f022                	sd	s0,32(sp)
    80003aae:	ec26                	sd	s1,24(sp)
    80003ab0:	e84a                	sd	s2,16(sp)
    80003ab2:	e44e                	sd	s3,8(sp)
    80003ab4:	e052                	sd	s4,0(sp)
    80003ab6:	1800                	addi	s0,sp,48
    80003ab8:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003aba:	05050493          	addi	s1,a0,80
    80003abe:	08050913          	addi	s2,a0,128
    80003ac2:	a021                	j	80003aca <itrunc+0x22>
    80003ac4:	0491                	addi	s1,s1,4
    80003ac6:	01248d63          	beq	s1,s2,80003ae0 <itrunc+0x38>
    if(ip->addrs[i]){
    80003aca:	408c                	lw	a1,0(s1)
    80003acc:	dde5                	beqz	a1,80003ac4 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003ace:	0009a503          	lw	a0,0(s3)
    80003ad2:	00000097          	auipc	ra,0x0
    80003ad6:	8f4080e7          	jalr	-1804(ra) # 800033c6 <bfree>
      ip->addrs[i] = 0;
    80003ada:	0004a023          	sw	zero,0(s1)
    80003ade:	b7dd                	j	80003ac4 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003ae0:	0809a583          	lw	a1,128(s3)
    80003ae4:	e185                	bnez	a1,80003b04 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003ae6:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003aea:	854e                	mv	a0,s3
    80003aec:	00000097          	auipc	ra,0x0
    80003af0:	de4080e7          	jalr	-540(ra) # 800038d0 <iupdate>
}
    80003af4:	70a2                	ld	ra,40(sp)
    80003af6:	7402                	ld	s0,32(sp)
    80003af8:	64e2                	ld	s1,24(sp)
    80003afa:	6942                	ld	s2,16(sp)
    80003afc:	69a2                	ld	s3,8(sp)
    80003afe:	6a02                	ld	s4,0(sp)
    80003b00:	6145                	addi	sp,sp,48
    80003b02:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003b04:	0009a503          	lw	a0,0(s3)
    80003b08:	fffff097          	auipc	ra,0xfffff
    80003b0c:	678080e7          	jalr	1656(ra) # 80003180 <bread>
    80003b10:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003b12:	05850493          	addi	s1,a0,88
    80003b16:	45850913          	addi	s2,a0,1112
    80003b1a:	a021                	j	80003b22 <itrunc+0x7a>
    80003b1c:	0491                	addi	s1,s1,4
    80003b1e:	01248b63          	beq	s1,s2,80003b34 <itrunc+0x8c>
      if(a[j])
    80003b22:	408c                	lw	a1,0(s1)
    80003b24:	dde5                	beqz	a1,80003b1c <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003b26:	0009a503          	lw	a0,0(s3)
    80003b2a:	00000097          	auipc	ra,0x0
    80003b2e:	89c080e7          	jalr	-1892(ra) # 800033c6 <bfree>
    80003b32:	b7ed                	j	80003b1c <itrunc+0x74>
    brelse(bp);
    80003b34:	8552                	mv	a0,s4
    80003b36:	fffff097          	auipc	ra,0xfffff
    80003b3a:	77a080e7          	jalr	1914(ra) # 800032b0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003b3e:	0809a583          	lw	a1,128(s3)
    80003b42:	0009a503          	lw	a0,0(s3)
    80003b46:	00000097          	auipc	ra,0x0
    80003b4a:	880080e7          	jalr	-1920(ra) # 800033c6 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003b4e:	0809a023          	sw	zero,128(s3)
    80003b52:	bf51                	j	80003ae6 <itrunc+0x3e>

0000000080003b54 <iput>:
{
    80003b54:	1101                	addi	sp,sp,-32
    80003b56:	ec06                	sd	ra,24(sp)
    80003b58:	e822                	sd	s0,16(sp)
    80003b5a:	e426                	sd	s1,8(sp)
    80003b5c:	e04a                	sd	s2,0(sp)
    80003b5e:	1000                	addi	s0,sp,32
    80003b60:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b62:	0001c517          	auipc	a0,0x1c
    80003b66:	d0650513          	addi	a0,a0,-762 # 8001f868 <itable>
    80003b6a:	ffffd097          	auipc	ra,0xffffd
    80003b6e:	06c080e7          	jalr	108(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b72:	4498                	lw	a4,8(s1)
    80003b74:	4785                	li	a5,1
    80003b76:	02f70363          	beq	a4,a5,80003b9c <iput+0x48>
  ip->ref--;
    80003b7a:	449c                	lw	a5,8(s1)
    80003b7c:	37fd                	addiw	a5,a5,-1
    80003b7e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003b80:	0001c517          	auipc	a0,0x1c
    80003b84:	ce850513          	addi	a0,a0,-792 # 8001f868 <itable>
    80003b88:	ffffd097          	auipc	ra,0xffffd
    80003b8c:	102080e7          	jalr	258(ra) # 80000c8a <release>
}
    80003b90:	60e2                	ld	ra,24(sp)
    80003b92:	6442                	ld	s0,16(sp)
    80003b94:	64a2                	ld	s1,8(sp)
    80003b96:	6902                	ld	s2,0(sp)
    80003b98:	6105                	addi	sp,sp,32
    80003b9a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b9c:	40bc                	lw	a5,64(s1)
    80003b9e:	dff1                	beqz	a5,80003b7a <iput+0x26>
    80003ba0:	04a49783          	lh	a5,74(s1)
    80003ba4:	fbf9                	bnez	a5,80003b7a <iput+0x26>
    acquiresleep(&ip->lock);
    80003ba6:	01048913          	addi	s2,s1,16
    80003baa:	854a                	mv	a0,s2
    80003bac:	00001097          	auipc	ra,0x1
    80003bb0:	aa8080e7          	jalr	-1368(ra) # 80004654 <acquiresleep>
    release(&itable.lock);
    80003bb4:	0001c517          	auipc	a0,0x1c
    80003bb8:	cb450513          	addi	a0,a0,-844 # 8001f868 <itable>
    80003bbc:	ffffd097          	auipc	ra,0xffffd
    80003bc0:	0ce080e7          	jalr	206(ra) # 80000c8a <release>
    itrunc(ip);
    80003bc4:	8526                	mv	a0,s1
    80003bc6:	00000097          	auipc	ra,0x0
    80003bca:	ee2080e7          	jalr	-286(ra) # 80003aa8 <itrunc>
    ip->type = 0;
    80003bce:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003bd2:	8526                	mv	a0,s1
    80003bd4:	00000097          	auipc	ra,0x0
    80003bd8:	cfc080e7          	jalr	-772(ra) # 800038d0 <iupdate>
    ip->valid = 0;
    80003bdc:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003be0:	854a                	mv	a0,s2
    80003be2:	00001097          	auipc	ra,0x1
    80003be6:	ac8080e7          	jalr	-1336(ra) # 800046aa <releasesleep>
    acquire(&itable.lock);
    80003bea:	0001c517          	auipc	a0,0x1c
    80003bee:	c7e50513          	addi	a0,a0,-898 # 8001f868 <itable>
    80003bf2:	ffffd097          	auipc	ra,0xffffd
    80003bf6:	fe4080e7          	jalr	-28(ra) # 80000bd6 <acquire>
    80003bfa:	b741                	j	80003b7a <iput+0x26>

0000000080003bfc <iunlockput>:
{
    80003bfc:	1101                	addi	sp,sp,-32
    80003bfe:	ec06                	sd	ra,24(sp)
    80003c00:	e822                	sd	s0,16(sp)
    80003c02:	e426                	sd	s1,8(sp)
    80003c04:	1000                	addi	s0,sp,32
    80003c06:	84aa                	mv	s1,a0
  iunlock(ip);
    80003c08:	00000097          	auipc	ra,0x0
    80003c0c:	e54080e7          	jalr	-428(ra) # 80003a5c <iunlock>
  iput(ip);
    80003c10:	8526                	mv	a0,s1
    80003c12:	00000097          	auipc	ra,0x0
    80003c16:	f42080e7          	jalr	-190(ra) # 80003b54 <iput>
}
    80003c1a:	60e2                	ld	ra,24(sp)
    80003c1c:	6442                	ld	s0,16(sp)
    80003c1e:	64a2                	ld	s1,8(sp)
    80003c20:	6105                	addi	sp,sp,32
    80003c22:	8082                	ret

0000000080003c24 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003c24:	1141                	addi	sp,sp,-16
    80003c26:	e422                	sd	s0,8(sp)
    80003c28:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003c2a:	411c                	lw	a5,0(a0)
    80003c2c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003c2e:	415c                	lw	a5,4(a0)
    80003c30:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003c32:	04451783          	lh	a5,68(a0)
    80003c36:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003c3a:	04a51783          	lh	a5,74(a0)
    80003c3e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003c42:	04c56783          	lwu	a5,76(a0)
    80003c46:	e99c                	sd	a5,16(a1)
}
    80003c48:	6422                	ld	s0,8(sp)
    80003c4a:	0141                	addi	sp,sp,16
    80003c4c:	8082                	ret

0000000080003c4e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c4e:	457c                	lw	a5,76(a0)
    80003c50:	0ed7e963          	bltu	a5,a3,80003d42 <readi+0xf4>
{
    80003c54:	7159                	addi	sp,sp,-112
    80003c56:	f486                	sd	ra,104(sp)
    80003c58:	f0a2                	sd	s0,96(sp)
    80003c5a:	eca6                	sd	s1,88(sp)
    80003c5c:	e8ca                	sd	s2,80(sp)
    80003c5e:	e4ce                	sd	s3,72(sp)
    80003c60:	e0d2                	sd	s4,64(sp)
    80003c62:	fc56                	sd	s5,56(sp)
    80003c64:	f85a                	sd	s6,48(sp)
    80003c66:	f45e                	sd	s7,40(sp)
    80003c68:	f062                	sd	s8,32(sp)
    80003c6a:	ec66                	sd	s9,24(sp)
    80003c6c:	e86a                	sd	s10,16(sp)
    80003c6e:	e46e                	sd	s11,8(sp)
    80003c70:	1880                	addi	s0,sp,112
    80003c72:	8b2a                	mv	s6,a0
    80003c74:	8bae                	mv	s7,a1
    80003c76:	8a32                	mv	s4,a2
    80003c78:	84b6                	mv	s1,a3
    80003c7a:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003c7c:	9f35                	addw	a4,a4,a3
    return 0;
    80003c7e:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003c80:	0ad76063          	bltu	a4,a3,80003d20 <readi+0xd2>
  if(off + n > ip->size)
    80003c84:	00e7f463          	bgeu	a5,a4,80003c8c <readi+0x3e>
    n = ip->size - off;
    80003c88:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c8c:	0a0a8963          	beqz	s5,80003d3e <readi+0xf0>
    80003c90:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c92:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003c96:	5c7d                	li	s8,-1
    80003c98:	a82d                	j	80003cd2 <readi+0x84>
    80003c9a:	020d1d93          	slli	s11,s10,0x20
    80003c9e:	020ddd93          	srli	s11,s11,0x20
    80003ca2:	05890793          	addi	a5,s2,88
    80003ca6:	86ee                	mv	a3,s11
    80003ca8:	963e                	add	a2,a2,a5
    80003caa:	85d2                	mv	a1,s4
    80003cac:	855e                	mv	a0,s7
    80003cae:	fffff097          	auipc	ra,0xfffff
    80003cb2:	9ee080e7          	jalr	-1554(ra) # 8000269c <either_copyout>
    80003cb6:	05850d63          	beq	a0,s8,80003d10 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003cba:	854a                	mv	a0,s2
    80003cbc:	fffff097          	auipc	ra,0xfffff
    80003cc0:	5f4080e7          	jalr	1524(ra) # 800032b0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cc4:	013d09bb          	addw	s3,s10,s3
    80003cc8:	009d04bb          	addw	s1,s10,s1
    80003ccc:	9a6e                	add	s4,s4,s11
    80003cce:	0559f763          	bgeu	s3,s5,80003d1c <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003cd2:	00a4d59b          	srliw	a1,s1,0xa
    80003cd6:	855a                	mv	a0,s6
    80003cd8:	00000097          	auipc	ra,0x0
    80003cdc:	8a2080e7          	jalr	-1886(ra) # 8000357a <bmap>
    80003ce0:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003ce4:	cd85                	beqz	a1,80003d1c <readi+0xce>
    bp = bread(ip->dev, addr);
    80003ce6:	000b2503          	lw	a0,0(s6)
    80003cea:	fffff097          	auipc	ra,0xfffff
    80003cee:	496080e7          	jalr	1174(ra) # 80003180 <bread>
    80003cf2:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cf4:	3ff4f613          	andi	a2,s1,1023
    80003cf8:	40cc87bb          	subw	a5,s9,a2
    80003cfc:	413a873b          	subw	a4,s5,s3
    80003d00:	8d3e                	mv	s10,a5
    80003d02:	2781                	sext.w	a5,a5
    80003d04:	0007069b          	sext.w	a3,a4
    80003d08:	f8f6f9e3          	bgeu	a3,a5,80003c9a <readi+0x4c>
    80003d0c:	8d3a                	mv	s10,a4
    80003d0e:	b771                	j	80003c9a <readi+0x4c>
      brelse(bp);
    80003d10:	854a                	mv	a0,s2
    80003d12:	fffff097          	auipc	ra,0xfffff
    80003d16:	59e080e7          	jalr	1438(ra) # 800032b0 <brelse>
      tot = -1;
    80003d1a:	59fd                	li	s3,-1
  }
  return tot;
    80003d1c:	0009851b          	sext.w	a0,s3
}
    80003d20:	70a6                	ld	ra,104(sp)
    80003d22:	7406                	ld	s0,96(sp)
    80003d24:	64e6                	ld	s1,88(sp)
    80003d26:	6946                	ld	s2,80(sp)
    80003d28:	69a6                	ld	s3,72(sp)
    80003d2a:	6a06                	ld	s4,64(sp)
    80003d2c:	7ae2                	ld	s5,56(sp)
    80003d2e:	7b42                	ld	s6,48(sp)
    80003d30:	7ba2                	ld	s7,40(sp)
    80003d32:	7c02                	ld	s8,32(sp)
    80003d34:	6ce2                	ld	s9,24(sp)
    80003d36:	6d42                	ld	s10,16(sp)
    80003d38:	6da2                	ld	s11,8(sp)
    80003d3a:	6165                	addi	sp,sp,112
    80003d3c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d3e:	89d6                	mv	s3,s5
    80003d40:	bff1                	j	80003d1c <readi+0xce>
    return 0;
    80003d42:	4501                	li	a0,0
}
    80003d44:	8082                	ret

0000000080003d46 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d46:	457c                	lw	a5,76(a0)
    80003d48:	10d7e863          	bltu	a5,a3,80003e58 <writei+0x112>
{
    80003d4c:	7159                	addi	sp,sp,-112
    80003d4e:	f486                	sd	ra,104(sp)
    80003d50:	f0a2                	sd	s0,96(sp)
    80003d52:	eca6                	sd	s1,88(sp)
    80003d54:	e8ca                	sd	s2,80(sp)
    80003d56:	e4ce                	sd	s3,72(sp)
    80003d58:	e0d2                	sd	s4,64(sp)
    80003d5a:	fc56                	sd	s5,56(sp)
    80003d5c:	f85a                	sd	s6,48(sp)
    80003d5e:	f45e                	sd	s7,40(sp)
    80003d60:	f062                	sd	s8,32(sp)
    80003d62:	ec66                	sd	s9,24(sp)
    80003d64:	e86a                	sd	s10,16(sp)
    80003d66:	e46e                	sd	s11,8(sp)
    80003d68:	1880                	addi	s0,sp,112
    80003d6a:	8aaa                	mv	s5,a0
    80003d6c:	8bae                	mv	s7,a1
    80003d6e:	8a32                	mv	s4,a2
    80003d70:	8936                	mv	s2,a3
    80003d72:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003d74:	00e687bb          	addw	a5,a3,a4
    80003d78:	0ed7e263          	bltu	a5,a3,80003e5c <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003d7c:	00043737          	lui	a4,0x43
    80003d80:	0ef76063          	bltu	a4,a5,80003e60 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d84:	0c0b0863          	beqz	s6,80003e54 <writei+0x10e>
    80003d88:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d8a:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003d8e:	5c7d                	li	s8,-1
    80003d90:	a091                	j	80003dd4 <writei+0x8e>
    80003d92:	020d1d93          	slli	s11,s10,0x20
    80003d96:	020ddd93          	srli	s11,s11,0x20
    80003d9a:	05848793          	addi	a5,s1,88
    80003d9e:	86ee                	mv	a3,s11
    80003da0:	8652                	mv	a2,s4
    80003da2:	85de                	mv	a1,s7
    80003da4:	953e                	add	a0,a0,a5
    80003da6:	fffff097          	auipc	ra,0xfffff
    80003daa:	94c080e7          	jalr	-1716(ra) # 800026f2 <either_copyin>
    80003dae:	07850263          	beq	a0,s8,80003e12 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003db2:	8526                	mv	a0,s1
    80003db4:	00000097          	auipc	ra,0x0
    80003db8:	780080e7          	jalr	1920(ra) # 80004534 <log_write>
    brelse(bp);
    80003dbc:	8526                	mv	a0,s1
    80003dbe:	fffff097          	auipc	ra,0xfffff
    80003dc2:	4f2080e7          	jalr	1266(ra) # 800032b0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003dc6:	013d09bb          	addw	s3,s10,s3
    80003dca:	012d093b          	addw	s2,s10,s2
    80003dce:	9a6e                	add	s4,s4,s11
    80003dd0:	0569f663          	bgeu	s3,s6,80003e1c <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003dd4:	00a9559b          	srliw	a1,s2,0xa
    80003dd8:	8556                	mv	a0,s5
    80003dda:	fffff097          	auipc	ra,0xfffff
    80003dde:	7a0080e7          	jalr	1952(ra) # 8000357a <bmap>
    80003de2:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003de6:	c99d                	beqz	a1,80003e1c <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003de8:	000aa503          	lw	a0,0(s5)
    80003dec:	fffff097          	auipc	ra,0xfffff
    80003df0:	394080e7          	jalr	916(ra) # 80003180 <bread>
    80003df4:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003df6:	3ff97513          	andi	a0,s2,1023
    80003dfa:	40ac87bb          	subw	a5,s9,a0
    80003dfe:	413b073b          	subw	a4,s6,s3
    80003e02:	8d3e                	mv	s10,a5
    80003e04:	2781                	sext.w	a5,a5
    80003e06:	0007069b          	sext.w	a3,a4
    80003e0a:	f8f6f4e3          	bgeu	a3,a5,80003d92 <writei+0x4c>
    80003e0e:	8d3a                	mv	s10,a4
    80003e10:	b749                	j	80003d92 <writei+0x4c>
      brelse(bp);
    80003e12:	8526                	mv	a0,s1
    80003e14:	fffff097          	auipc	ra,0xfffff
    80003e18:	49c080e7          	jalr	1180(ra) # 800032b0 <brelse>
  }

  if(off > ip->size)
    80003e1c:	04caa783          	lw	a5,76(s5)
    80003e20:	0127f463          	bgeu	a5,s2,80003e28 <writei+0xe2>
    ip->size = off;
    80003e24:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003e28:	8556                	mv	a0,s5
    80003e2a:	00000097          	auipc	ra,0x0
    80003e2e:	aa6080e7          	jalr	-1370(ra) # 800038d0 <iupdate>

  return tot;
    80003e32:	0009851b          	sext.w	a0,s3
}
    80003e36:	70a6                	ld	ra,104(sp)
    80003e38:	7406                	ld	s0,96(sp)
    80003e3a:	64e6                	ld	s1,88(sp)
    80003e3c:	6946                	ld	s2,80(sp)
    80003e3e:	69a6                	ld	s3,72(sp)
    80003e40:	6a06                	ld	s4,64(sp)
    80003e42:	7ae2                	ld	s5,56(sp)
    80003e44:	7b42                	ld	s6,48(sp)
    80003e46:	7ba2                	ld	s7,40(sp)
    80003e48:	7c02                	ld	s8,32(sp)
    80003e4a:	6ce2                	ld	s9,24(sp)
    80003e4c:	6d42                	ld	s10,16(sp)
    80003e4e:	6da2                	ld	s11,8(sp)
    80003e50:	6165                	addi	sp,sp,112
    80003e52:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e54:	89da                	mv	s3,s6
    80003e56:	bfc9                	j	80003e28 <writei+0xe2>
    return -1;
    80003e58:	557d                	li	a0,-1
}
    80003e5a:	8082                	ret
    return -1;
    80003e5c:	557d                	li	a0,-1
    80003e5e:	bfe1                	j	80003e36 <writei+0xf0>
    return -1;
    80003e60:	557d                	li	a0,-1
    80003e62:	bfd1                	j	80003e36 <writei+0xf0>

0000000080003e64 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003e64:	1141                	addi	sp,sp,-16
    80003e66:	e406                	sd	ra,8(sp)
    80003e68:	e022                	sd	s0,0(sp)
    80003e6a:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003e6c:	4639                	li	a2,14
    80003e6e:	ffffd097          	auipc	ra,0xffffd
    80003e72:	f34080e7          	jalr	-204(ra) # 80000da2 <strncmp>
}
    80003e76:	60a2                	ld	ra,8(sp)
    80003e78:	6402                	ld	s0,0(sp)
    80003e7a:	0141                	addi	sp,sp,16
    80003e7c:	8082                	ret

0000000080003e7e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003e7e:	7139                	addi	sp,sp,-64
    80003e80:	fc06                	sd	ra,56(sp)
    80003e82:	f822                	sd	s0,48(sp)
    80003e84:	f426                	sd	s1,40(sp)
    80003e86:	f04a                	sd	s2,32(sp)
    80003e88:	ec4e                	sd	s3,24(sp)
    80003e8a:	e852                	sd	s4,16(sp)
    80003e8c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003e8e:	04451703          	lh	a4,68(a0)
    80003e92:	4785                	li	a5,1
    80003e94:	00f71a63          	bne	a4,a5,80003ea8 <dirlookup+0x2a>
    80003e98:	892a                	mv	s2,a0
    80003e9a:	89ae                	mv	s3,a1
    80003e9c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e9e:	457c                	lw	a5,76(a0)
    80003ea0:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003ea2:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ea4:	e79d                	bnez	a5,80003ed2 <dirlookup+0x54>
    80003ea6:	a8a5                	j	80003f1e <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003ea8:	00005517          	auipc	a0,0x5
    80003eac:	89850513          	addi	a0,a0,-1896 # 80008740 <syscallnum+0x150>
    80003eb0:	ffffc097          	auipc	ra,0xffffc
    80003eb4:	68e080e7          	jalr	1678(ra) # 8000053e <panic>
      panic("dirlookup read");
    80003eb8:	00005517          	auipc	a0,0x5
    80003ebc:	8a050513          	addi	a0,a0,-1888 # 80008758 <syscallnum+0x168>
    80003ec0:	ffffc097          	auipc	ra,0xffffc
    80003ec4:	67e080e7          	jalr	1662(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ec8:	24c1                	addiw	s1,s1,16
    80003eca:	04c92783          	lw	a5,76(s2)
    80003ece:	04f4f763          	bgeu	s1,a5,80003f1c <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ed2:	4741                	li	a4,16
    80003ed4:	86a6                	mv	a3,s1
    80003ed6:	fc040613          	addi	a2,s0,-64
    80003eda:	4581                	li	a1,0
    80003edc:	854a                	mv	a0,s2
    80003ede:	00000097          	auipc	ra,0x0
    80003ee2:	d70080e7          	jalr	-656(ra) # 80003c4e <readi>
    80003ee6:	47c1                	li	a5,16
    80003ee8:	fcf518e3          	bne	a0,a5,80003eb8 <dirlookup+0x3a>
    if(de.inum == 0)
    80003eec:	fc045783          	lhu	a5,-64(s0)
    80003ef0:	dfe1                	beqz	a5,80003ec8 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003ef2:	fc240593          	addi	a1,s0,-62
    80003ef6:	854e                	mv	a0,s3
    80003ef8:	00000097          	auipc	ra,0x0
    80003efc:	f6c080e7          	jalr	-148(ra) # 80003e64 <namecmp>
    80003f00:	f561                	bnez	a0,80003ec8 <dirlookup+0x4a>
      if(poff)
    80003f02:	000a0463          	beqz	s4,80003f0a <dirlookup+0x8c>
        *poff = off;
    80003f06:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003f0a:	fc045583          	lhu	a1,-64(s0)
    80003f0e:	00092503          	lw	a0,0(s2)
    80003f12:	fffff097          	auipc	ra,0xfffff
    80003f16:	750080e7          	jalr	1872(ra) # 80003662 <iget>
    80003f1a:	a011                	j	80003f1e <dirlookup+0xa0>
  return 0;
    80003f1c:	4501                	li	a0,0
}
    80003f1e:	70e2                	ld	ra,56(sp)
    80003f20:	7442                	ld	s0,48(sp)
    80003f22:	74a2                	ld	s1,40(sp)
    80003f24:	7902                	ld	s2,32(sp)
    80003f26:	69e2                	ld	s3,24(sp)
    80003f28:	6a42                	ld	s4,16(sp)
    80003f2a:	6121                	addi	sp,sp,64
    80003f2c:	8082                	ret

0000000080003f2e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003f2e:	711d                	addi	sp,sp,-96
    80003f30:	ec86                	sd	ra,88(sp)
    80003f32:	e8a2                	sd	s0,80(sp)
    80003f34:	e4a6                	sd	s1,72(sp)
    80003f36:	e0ca                	sd	s2,64(sp)
    80003f38:	fc4e                	sd	s3,56(sp)
    80003f3a:	f852                	sd	s4,48(sp)
    80003f3c:	f456                	sd	s5,40(sp)
    80003f3e:	f05a                	sd	s6,32(sp)
    80003f40:	ec5e                	sd	s7,24(sp)
    80003f42:	e862                	sd	s8,16(sp)
    80003f44:	e466                	sd	s9,8(sp)
    80003f46:	1080                	addi	s0,sp,96
    80003f48:	84aa                	mv	s1,a0
    80003f4a:	8aae                	mv	s5,a1
    80003f4c:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003f4e:	00054703          	lbu	a4,0(a0)
    80003f52:	02f00793          	li	a5,47
    80003f56:	02f70363          	beq	a4,a5,80003f7c <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003f5a:	ffffe097          	auipc	ra,0xffffe
    80003f5e:	a52080e7          	jalr	-1454(ra) # 800019ac <myproc>
    80003f62:	15053503          	ld	a0,336(a0)
    80003f66:	00000097          	auipc	ra,0x0
    80003f6a:	9f6080e7          	jalr	-1546(ra) # 8000395c <idup>
    80003f6e:	89aa                	mv	s3,a0
  while(*path == '/')
    80003f70:	02f00913          	li	s2,47
  len = path - s;
    80003f74:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003f76:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003f78:	4b85                	li	s7,1
    80003f7a:	a865                	j	80004032 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003f7c:	4585                	li	a1,1
    80003f7e:	4505                	li	a0,1
    80003f80:	fffff097          	auipc	ra,0xfffff
    80003f84:	6e2080e7          	jalr	1762(ra) # 80003662 <iget>
    80003f88:	89aa                	mv	s3,a0
    80003f8a:	b7dd                	j	80003f70 <namex+0x42>
      iunlockput(ip);
    80003f8c:	854e                	mv	a0,s3
    80003f8e:	00000097          	auipc	ra,0x0
    80003f92:	c6e080e7          	jalr	-914(ra) # 80003bfc <iunlockput>
      return 0;
    80003f96:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003f98:	854e                	mv	a0,s3
    80003f9a:	60e6                	ld	ra,88(sp)
    80003f9c:	6446                	ld	s0,80(sp)
    80003f9e:	64a6                	ld	s1,72(sp)
    80003fa0:	6906                	ld	s2,64(sp)
    80003fa2:	79e2                	ld	s3,56(sp)
    80003fa4:	7a42                	ld	s4,48(sp)
    80003fa6:	7aa2                	ld	s5,40(sp)
    80003fa8:	7b02                	ld	s6,32(sp)
    80003faa:	6be2                	ld	s7,24(sp)
    80003fac:	6c42                	ld	s8,16(sp)
    80003fae:	6ca2                	ld	s9,8(sp)
    80003fb0:	6125                	addi	sp,sp,96
    80003fb2:	8082                	ret
      iunlock(ip);
    80003fb4:	854e                	mv	a0,s3
    80003fb6:	00000097          	auipc	ra,0x0
    80003fba:	aa6080e7          	jalr	-1370(ra) # 80003a5c <iunlock>
      return ip;
    80003fbe:	bfe9                	j	80003f98 <namex+0x6a>
      iunlockput(ip);
    80003fc0:	854e                	mv	a0,s3
    80003fc2:	00000097          	auipc	ra,0x0
    80003fc6:	c3a080e7          	jalr	-966(ra) # 80003bfc <iunlockput>
      return 0;
    80003fca:	89e6                	mv	s3,s9
    80003fcc:	b7f1                	j	80003f98 <namex+0x6a>
  len = path - s;
    80003fce:	40b48633          	sub	a2,s1,a1
    80003fd2:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003fd6:	099c5463          	bge	s8,s9,8000405e <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003fda:	4639                	li	a2,14
    80003fdc:	8552                	mv	a0,s4
    80003fde:	ffffd097          	auipc	ra,0xffffd
    80003fe2:	d50080e7          	jalr	-688(ra) # 80000d2e <memmove>
  while(*path == '/')
    80003fe6:	0004c783          	lbu	a5,0(s1)
    80003fea:	01279763          	bne	a5,s2,80003ff8 <namex+0xca>
    path++;
    80003fee:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003ff0:	0004c783          	lbu	a5,0(s1)
    80003ff4:	ff278de3          	beq	a5,s2,80003fee <namex+0xc0>
    ilock(ip);
    80003ff8:	854e                	mv	a0,s3
    80003ffa:	00000097          	auipc	ra,0x0
    80003ffe:	9a0080e7          	jalr	-1632(ra) # 8000399a <ilock>
    if(ip->type != T_DIR){
    80004002:	04499783          	lh	a5,68(s3)
    80004006:	f97793e3          	bne	a5,s7,80003f8c <namex+0x5e>
    if(nameiparent && *path == '\0'){
    8000400a:	000a8563          	beqz	s5,80004014 <namex+0xe6>
    8000400e:	0004c783          	lbu	a5,0(s1)
    80004012:	d3cd                	beqz	a5,80003fb4 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004014:	865a                	mv	a2,s6
    80004016:	85d2                	mv	a1,s4
    80004018:	854e                	mv	a0,s3
    8000401a:	00000097          	auipc	ra,0x0
    8000401e:	e64080e7          	jalr	-412(ra) # 80003e7e <dirlookup>
    80004022:	8caa                	mv	s9,a0
    80004024:	dd51                	beqz	a0,80003fc0 <namex+0x92>
    iunlockput(ip);
    80004026:	854e                	mv	a0,s3
    80004028:	00000097          	auipc	ra,0x0
    8000402c:	bd4080e7          	jalr	-1068(ra) # 80003bfc <iunlockput>
    ip = next;
    80004030:	89e6                	mv	s3,s9
  while(*path == '/')
    80004032:	0004c783          	lbu	a5,0(s1)
    80004036:	05279763          	bne	a5,s2,80004084 <namex+0x156>
    path++;
    8000403a:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000403c:	0004c783          	lbu	a5,0(s1)
    80004040:	ff278de3          	beq	a5,s2,8000403a <namex+0x10c>
  if(*path == 0)
    80004044:	c79d                	beqz	a5,80004072 <namex+0x144>
    path++;
    80004046:	85a6                	mv	a1,s1
  len = path - s;
    80004048:	8cda                	mv	s9,s6
    8000404a:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    8000404c:	01278963          	beq	a5,s2,8000405e <namex+0x130>
    80004050:	dfbd                	beqz	a5,80003fce <namex+0xa0>
    path++;
    80004052:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004054:	0004c783          	lbu	a5,0(s1)
    80004058:	ff279ce3          	bne	a5,s2,80004050 <namex+0x122>
    8000405c:	bf8d                	j	80003fce <namex+0xa0>
    memmove(name, s, len);
    8000405e:	2601                	sext.w	a2,a2
    80004060:	8552                	mv	a0,s4
    80004062:	ffffd097          	auipc	ra,0xffffd
    80004066:	ccc080e7          	jalr	-820(ra) # 80000d2e <memmove>
    name[len] = 0;
    8000406a:	9cd2                	add	s9,s9,s4
    8000406c:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004070:	bf9d                	j	80003fe6 <namex+0xb8>
  if(nameiparent){
    80004072:	f20a83e3          	beqz	s5,80003f98 <namex+0x6a>
    iput(ip);
    80004076:	854e                	mv	a0,s3
    80004078:	00000097          	auipc	ra,0x0
    8000407c:	adc080e7          	jalr	-1316(ra) # 80003b54 <iput>
    return 0;
    80004080:	4981                	li	s3,0
    80004082:	bf19                	j	80003f98 <namex+0x6a>
  if(*path == 0)
    80004084:	d7fd                	beqz	a5,80004072 <namex+0x144>
  while(*path != '/' && *path != 0)
    80004086:	0004c783          	lbu	a5,0(s1)
    8000408a:	85a6                	mv	a1,s1
    8000408c:	b7d1                	j	80004050 <namex+0x122>

000000008000408e <dirlink>:
{
    8000408e:	7139                	addi	sp,sp,-64
    80004090:	fc06                	sd	ra,56(sp)
    80004092:	f822                	sd	s0,48(sp)
    80004094:	f426                	sd	s1,40(sp)
    80004096:	f04a                	sd	s2,32(sp)
    80004098:	ec4e                	sd	s3,24(sp)
    8000409a:	e852                	sd	s4,16(sp)
    8000409c:	0080                	addi	s0,sp,64
    8000409e:	892a                	mv	s2,a0
    800040a0:	8a2e                	mv	s4,a1
    800040a2:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800040a4:	4601                	li	a2,0
    800040a6:	00000097          	auipc	ra,0x0
    800040aa:	dd8080e7          	jalr	-552(ra) # 80003e7e <dirlookup>
    800040ae:	e93d                	bnez	a0,80004124 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040b0:	04c92483          	lw	s1,76(s2)
    800040b4:	c49d                	beqz	s1,800040e2 <dirlink+0x54>
    800040b6:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040b8:	4741                	li	a4,16
    800040ba:	86a6                	mv	a3,s1
    800040bc:	fc040613          	addi	a2,s0,-64
    800040c0:	4581                	li	a1,0
    800040c2:	854a                	mv	a0,s2
    800040c4:	00000097          	auipc	ra,0x0
    800040c8:	b8a080e7          	jalr	-1142(ra) # 80003c4e <readi>
    800040cc:	47c1                	li	a5,16
    800040ce:	06f51163          	bne	a0,a5,80004130 <dirlink+0xa2>
    if(de.inum == 0)
    800040d2:	fc045783          	lhu	a5,-64(s0)
    800040d6:	c791                	beqz	a5,800040e2 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040d8:	24c1                	addiw	s1,s1,16
    800040da:	04c92783          	lw	a5,76(s2)
    800040de:	fcf4ede3          	bltu	s1,a5,800040b8 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800040e2:	4639                	li	a2,14
    800040e4:	85d2                	mv	a1,s4
    800040e6:	fc240513          	addi	a0,s0,-62
    800040ea:	ffffd097          	auipc	ra,0xffffd
    800040ee:	cf4080e7          	jalr	-780(ra) # 80000dde <strncpy>
  de.inum = inum;
    800040f2:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040f6:	4741                	li	a4,16
    800040f8:	86a6                	mv	a3,s1
    800040fa:	fc040613          	addi	a2,s0,-64
    800040fe:	4581                	li	a1,0
    80004100:	854a                	mv	a0,s2
    80004102:	00000097          	auipc	ra,0x0
    80004106:	c44080e7          	jalr	-956(ra) # 80003d46 <writei>
    8000410a:	1541                	addi	a0,a0,-16
    8000410c:	00a03533          	snez	a0,a0
    80004110:	40a00533          	neg	a0,a0
}
    80004114:	70e2                	ld	ra,56(sp)
    80004116:	7442                	ld	s0,48(sp)
    80004118:	74a2                	ld	s1,40(sp)
    8000411a:	7902                	ld	s2,32(sp)
    8000411c:	69e2                	ld	s3,24(sp)
    8000411e:	6a42                	ld	s4,16(sp)
    80004120:	6121                	addi	sp,sp,64
    80004122:	8082                	ret
    iput(ip);
    80004124:	00000097          	auipc	ra,0x0
    80004128:	a30080e7          	jalr	-1488(ra) # 80003b54 <iput>
    return -1;
    8000412c:	557d                	li	a0,-1
    8000412e:	b7dd                	j	80004114 <dirlink+0x86>
      panic("dirlink read");
    80004130:	00004517          	auipc	a0,0x4
    80004134:	63850513          	addi	a0,a0,1592 # 80008768 <syscallnum+0x178>
    80004138:	ffffc097          	auipc	ra,0xffffc
    8000413c:	406080e7          	jalr	1030(ra) # 8000053e <panic>

0000000080004140 <namei>:

struct inode*
namei(char *path)
{
    80004140:	1101                	addi	sp,sp,-32
    80004142:	ec06                	sd	ra,24(sp)
    80004144:	e822                	sd	s0,16(sp)
    80004146:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004148:	fe040613          	addi	a2,s0,-32
    8000414c:	4581                	li	a1,0
    8000414e:	00000097          	auipc	ra,0x0
    80004152:	de0080e7          	jalr	-544(ra) # 80003f2e <namex>
}
    80004156:	60e2                	ld	ra,24(sp)
    80004158:	6442                	ld	s0,16(sp)
    8000415a:	6105                	addi	sp,sp,32
    8000415c:	8082                	ret

000000008000415e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000415e:	1141                	addi	sp,sp,-16
    80004160:	e406                	sd	ra,8(sp)
    80004162:	e022                	sd	s0,0(sp)
    80004164:	0800                	addi	s0,sp,16
    80004166:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004168:	4585                	li	a1,1
    8000416a:	00000097          	auipc	ra,0x0
    8000416e:	dc4080e7          	jalr	-572(ra) # 80003f2e <namex>
}
    80004172:	60a2                	ld	ra,8(sp)
    80004174:	6402                	ld	s0,0(sp)
    80004176:	0141                	addi	sp,sp,16
    80004178:	8082                	ret

000000008000417a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000417a:	1101                	addi	sp,sp,-32
    8000417c:	ec06                	sd	ra,24(sp)
    8000417e:	e822                	sd	s0,16(sp)
    80004180:	e426                	sd	s1,8(sp)
    80004182:	e04a                	sd	s2,0(sp)
    80004184:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004186:	0001d917          	auipc	s2,0x1d
    8000418a:	18a90913          	addi	s2,s2,394 # 80021310 <log>
    8000418e:	01892583          	lw	a1,24(s2)
    80004192:	02892503          	lw	a0,40(s2)
    80004196:	fffff097          	auipc	ra,0xfffff
    8000419a:	fea080e7          	jalr	-22(ra) # 80003180 <bread>
    8000419e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800041a0:	02c92683          	lw	a3,44(s2)
    800041a4:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800041a6:	02d05763          	blez	a3,800041d4 <write_head+0x5a>
    800041aa:	0001d797          	auipc	a5,0x1d
    800041ae:	19678793          	addi	a5,a5,406 # 80021340 <log+0x30>
    800041b2:	05c50713          	addi	a4,a0,92
    800041b6:	36fd                	addiw	a3,a3,-1
    800041b8:	1682                	slli	a3,a3,0x20
    800041ba:	9281                	srli	a3,a3,0x20
    800041bc:	068a                	slli	a3,a3,0x2
    800041be:	0001d617          	auipc	a2,0x1d
    800041c2:	18660613          	addi	a2,a2,390 # 80021344 <log+0x34>
    800041c6:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800041c8:	4390                	lw	a2,0(a5)
    800041ca:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800041cc:	0791                	addi	a5,a5,4
    800041ce:	0711                	addi	a4,a4,4
    800041d0:	fed79ce3          	bne	a5,a3,800041c8 <write_head+0x4e>
  }
  bwrite(buf);
    800041d4:	8526                	mv	a0,s1
    800041d6:	fffff097          	auipc	ra,0xfffff
    800041da:	09c080e7          	jalr	156(ra) # 80003272 <bwrite>
  brelse(buf);
    800041de:	8526                	mv	a0,s1
    800041e0:	fffff097          	auipc	ra,0xfffff
    800041e4:	0d0080e7          	jalr	208(ra) # 800032b0 <brelse>
}
    800041e8:	60e2                	ld	ra,24(sp)
    800041ea:	6442                	ld	s0,16(sp)
    800041ec:	64a2                	ld	s1,8(sp)
    800041ee:	6902                	ld	s2,0(sp)
    800041f0:	6105                	addi	sp,sp,32
    800041f2:	8082                	ret

00000000800041f4 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800041f4:	0001d797          	auipc	a5,0x1d
    800041f8:	1487a783          	lw	a5,328(a5) # 8002133c <log+0x2c>
    800041fc:	0af05d63          	blez	a5,800042b6 <install_trans+0xc2>
{
    80004200:	7139                	addi	sp,sp,-64
    80004202:	fc06                	sd	ra,56(sp)
    80004204:	f822                	sd	s0,48(sp)
    80004206:	f426                	sd	s1,40(sp)
    80004208:	f04a                	sd	s2,32(sp)
    8000420a:	ec4e                	sd	s3,24(sp)
    8000420c:	e852                	sd	s4,16(sp)
    8000420e:	e456                	sd	s5,8(sp)
    80004210:	e05a                	sd	s6,0(sp)
    80004212:	0080                	addi	s0,sp,64
    80004214:	8b2a                	mv	s6,a0
    80004216:	0001da97          	auipc	s5,0x1d
    8000421a:	12aa8a93          	addi	s5,s5,298 # 80021340 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000421e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004220:	0001d997          	auipc	s3,0x1d
    80004224:	0f098993          	addi	s3,s3,240 # 80021310 <log>
    80004228:	a00d                	j	8000424a <install_trans+0x56>
    brelse(lbuf);
    8000422a:	854a                	mv	a0,s2
    8000422c:	fffff097          	auipc	ra,0xfffff
    80004230:	084080e7          	jalr	132(ra) # 800032b0 <brelse>
    brelse(dbuf);
    80004234:	8526                	mv	a0,s1
    80004236:	fffff097          	auipc	ra,0xfffff
    8000423a:	07a080e7          	jalr	122(ra) # 800032b0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000423e:	2a05                	addiw	s4,s4,1
    80004240:	0a91                	addi	s5,s5,4
    80004242:	02c9a783          	lw	a5,44(s3)
    80004246:	04fa5e63          	bge	s4,a5,800042a2 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000424a:	0189a583          	lw	a1,24(s3)
    8000424e:	014585bb          	addw	a1,a1,s4
    80004252:	2585                	addiw	a1,a1,1
    80004254:	0289a503          	lw	a0,40(s3)
    80004258:	fffff097          	auipc	ra,0xfffff
    8000425c:	f28080e7          	jalr	-216(ra) # 80003180 <bread>
    80004260:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004262:	000aa583          	lw	a1,0(s5)
    80004266:	0289a503          	lw	a0,40(s3)
    8000426a:	fffff097          	auipc	ra,0xfffff
    8000426e:	f16080e7          	jalr	-234(ra) # 80003180 <bread>
    80004272:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004274:	40000613          	li	a2,1024
    80004278:	05890593          	addi	a1,s2,88
    8000427c:	05850513          	addi	a0,a0,88
    80004280:	ffffd097          	auipc	ra,0xffffd
    80004284:	aae080e7          	jalr	-1362(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    80004288:	8526                	mv	a0,s1
    8000428a:	fffff097          	auipc	ra,0xfffff
    8000428e:	fe8080e7          	jalr	-24(ra) # 80003272 <bwrite>
    if(recovering == 0)
    80004292:	f80b1ce3          	bnez	s6,8000422a <install_trans+0x36>
      bunpin(dbuf);
    80004296:	8526                	mv	a0,s1
    80004298:	fffff097          	auipc	ra,0xfffff
    8000429c:	0f2080e7          	jalr	242(ra) # 8000338a <bunpin>
    800042a0:	b769                	j	8000422a <install_trans+0x36>
}
    800042a2:	70e2                	ld	ra,56(sp)
    800042a4:	7442                	ld	s0,48(sp)
    800042a6:	74a2                	ld	s1,40(sp)
    800042a8:	7902                	ld	s2,32(sp)
    800042aa:	69e2                	ld	s3,24(sp)
    800042ac:	6a42                	ld	s4,16(sp)
    800042ae:	6aa2                	ld	s5,8(sp)
    800042b0:	6b02                	ld	s6,0(sp)
    800042b2:	6121                	addi	sp,sp,64
    800042b4:	8082                	ret
    800042b6:	8082                	ret

00000000800042b8 <initlog>:
{
    800042b8:	7179                	addi	sp,sp,-48
    800042ba:	f406                	sd	ra,40(sp)
    800042bc:	f022                	sd	s0,32(sp)
    800042be:	ec26                	sd	s1,24(sp)
    800042c0:	e84a                	sd	s2,16(sp)
    800042c2:	e44e                	sd	s3,8(sp)
    800042c4:	1800                	addi	s0,sp,48
    800042c6:	892a                	mv	s2,a0
    800042c8:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800042ca:	0001d497          	auipc	s1,0x1d
    800042ce:	04648493          	addi	s1,s1,70 # 80021310 <log>
    800042d2:	00004597          	auipc	a1,0x4
    800042d6:	4a658593          	addi	a1,a1,1190 # 80008778 <syscallnum+0x188>
    800042da:	8526                	mv	a0,s1
    800042dc:	ffffd097          	auipc	ra,0xffffd
    800042e0:	86a080e7          	jalr	-1942(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    800042e4:	0149a583          	lw	a1,20(s3)
    800042e8:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800042ea:	0109a783          	lw	a5,16(s3)
    800042ee:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800042f0:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800042f4:	854a                	mv	a0,s2
    800042f6:	fffff097          	auipc	ra,0xfffff
    800042fa:	e8a080e7          	jalr	-374(ra) # 80003180 <bread>
  log.lh.n = lh->n;
    800042fe:	4d34                	lw	a3,88(a0)
    80004300:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004302:	02d05563          	blez	a3,8000432c <initlog+0x74>
    80004306:	05c50793          	addi	a5,a0,92
    8000430a:	0001d717          	auipc	a4,0x1d
    8000430e:	03670713          	addi	a4,a4,54 # 80021340 <log+0x30>
    80004312:	36fd                	addiw	a3,a3,-1
    80004314:	1682                	slli	a3,a3,0x20
    80004316:	9281                	srli	a3,a3,0x20
    80004318:	068a                	slli	a3,a3,0x2
    8000431a:	06050613          	addi	a2,a0,96
    8000431e:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004320:	4390                	lw	a2,0(a5)
    80004322:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004324:	0791                	addi	a5,a5,4
    80004326:	0711                	addi	a4,a4,4
    80004328:	fed79ce3          	bne	a5,a3,80004320 <initlog+0x68>
  brelse(buf);
    8000432c:	fffff097          	auipc	ra,0xfffff
    80004330:	f84080e7          	jalr	-124(ra) # 800032b0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004334:	4505                	li	a0,1
    80004336:	00000097          	auipc	ra,0x0
    8000433a:	ebe080e7          	jalr	-322(ra) # 800041f4 <install_trans>
  log.lh.n = 0;
    8000433e:	0001d797          	auipc	a5,0x1d
    80004342:	fe07af23          	sw	zero,-2(a5) # 8002133c <log+0x2c>
  write_head(); // clear the log
    80004346:	00000097          	auipc	ra,0x0
    8000434a:	e34080e7          	jalr	-460(ra) # 8000417a <write_head>
}
    8000434e:	70a2                	ld	ra,40(sp)
    80004350:	7402                	ld	s0,32(sp)
    80004352:	64e2                	ld	s1,24(sp)
    80004354:	6942                	ld	s2,16(sp)
    80004356:	69a2                	ld	s3,8(sp)
    80004358:	6145                	addi	sp,sp,48
    8000435a:	8082                	ret

000000008000435c <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000435c:	1101                	addi	sp,sp,-32
    8000435e:	ec06                	sd	ra,24(sp)
    80004360:	e822                	sd	s0,16(sp)
    80004362:	e426                	sd	s1,8(sp)
    80004364:	e04a                	sd	s2,0(sp)
    80004366:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004368:	0001d517          	auipc	a0,0x1d
    8000436c:	fa850513          	addi	a0,a0,-88 # 80021310 <log>
    80004370:	ffffd097          	auipc	ra,0xffffd
    80004374:	866080e7          	jalr	-1946(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    80004378:	0001d497          	auipc	s1,0x1d
    8000437c:	f9848493          	addi	s1,s1,-104 # 80021310 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004380:	4979                	li	s2,30
    80004382:	a039                	j	80004390 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004384:	85a6                	mv	a1,s1
    80004386:	8526                	mv	a0,s1
    80004388:	ffffe097          	auipc	ra,0xffffe
    8000438c:	db4080e7          	jalr	-588(ra) # 8000213c <sleep>
    if(log.committing){
    80004390:	50dc                	lw	a5,36(s1)
    80004392:	fbed                	bnez	a5,80004384 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004394:	509c                	lw	a5,32(s1)
    80004396:	0017871b          	addiw	a4,a5,1
    8000439a:	0007069b          	sext.w	a3,a4
    8000439e:	0027179b          	slliw	a5,a4,0x2
    800043a2:	9fb9                	addw	a5,a5,a4
    800043a4:	0017979b          	slliw	a5,a5,0x1
    800043a8:	54d8                	lw	a4,44(s1)
    800043aa:	9fb9                	addw	a5,a5,a4
    800043ac:	00f95963          	bge	s2,a5,800043be <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800043b0:	85a6                	mv	a1,s1
    800043b2:	8526                	mv	a0,s1
    800043b4:	ffffe097          	auipc	ra,0xffffe
    800043b8:	d88080e7          	jalr	-632(ra) # 8000213c <sleep>
    800043bc:	bfd1                	j	80004390 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800043be:	0001d517          	auipc	a0,0x1d
    800043c2:	f5250513          	addi	a0,a0,-174 # 80021310 <log>
    800043c6:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800043c8:	ffffd097          	auipc	ra,0xffffd
    800043cc:	8c2080e7          	jalr	-1854(ra) # 80000c8a <release>
      break;
    }
  }
}
    800043d0:	60e2                	ld	ra,24(sp)
    800043d2:	6442                	ld	s0,16(sp)
    800043d4:	64a2                	ld	s1,8(sp)
    800043d6:	6902                	ld	s2,0(sp)
    800043d8:	6105                	addi	sp,sp,32
    800043da:	8082                	ret

00000000800043dc <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800043dc:	7139                	addi	sp,sp,-64
    800043de:	fc06                	sd	ra,56(sp)
    800043e0:	f822                	sd	s0,48(sp)
    800043e2:	f426                	sd	s1,40(sp)
    800043e4:	f04a                	sd	s2,32(sp)
    800043e6:	ec4e                	sd	s3,24(sp)
    800043e8:	e852                	sd	s4,16(sp)
    800043ea:	e456                	sd	s5,8(sp)
    800043ec:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800043ee:	0001d497          	auipc	s1,0x1d
    800043f2:	f2248493          	addi	s1,s1,-222 # 80021310 <log>
    800043f6:	8526                	mv	a0,s1
    800043f8:	ffffc097          	auipc	ra,0xffffc
    800043fc:	7de080e7          	jalr	2014(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    80004400:	509c                	lw	a5,32(s1)
    80004402:	37fd                	addiw	a5,a5,-1
    80004404:	0007891b          	sext.w	s2,a5
    80004408:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000440a:	50dc                	lw	a5,36(s1)
    8000440c:	e7b9                	bnez	a5,8000445a <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000440e:	04091e63          	bnez	s2,8000446a <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004412:	0001d497          	auipc	s1,0x1d
    80004416:	efe48493          	addi	s1,s1,-258 # 80021310 <log>
    8000441a:	4785                	li	a5,1
    8000441c:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000441e:	8526                	mv	a0,s1
    80004420:	ffffd097          	auipc	ra,0xffffd
    80004424:	86a080e7          	jalr	-1942(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004428:	54dc                	lw	a5,44(s1)
    8000442a:	06f04763          	bgtz	a5,80004498 <end_op+0xbc>
    acquire(&log.lock);
    8000442e:	0001d497          	auipc	s1,0x1d
    80004432:	ee248493          	addi	s1,s1,-286 # 80021310 <log>
    80004436:	8526                	mv	a0,s1
    80004438:	ffffc097          	auipc	ra,0xffffc
    8000443c:	79e080e7          	jalr	1950(ra) # 80000bd6 <acquire>
    log.committing = 0;
    80004440:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004444:	8526                	mv	a0,s1
    80004446:	ffffe097          	auipc	ra,0xffffe
    8000444a:	ea6080e7          	jalr	-346(ra) # 800022ec <wakeup>
    release(&log.lock);
    8000444e:	8526                	mv	a0,s1
    80004450:	ffffd097          	auipc	ra,0xffffd
    80004454:	83a080e7          	jalr	-1990(ra) # 80000c8a <release>
}
    80004458:	a03d                	j	80004486 <end_op+0xaa>
    panic("log.committing");
    8000445a:	00004517          	auipc	a0,0x4
    8000445e:	32650513          	addi	a0,a0,806 # 80008780 <syscallnum+0x190>
    80004462:	ffffc097          	auipc	ra,0xffffc
    80004466:	0dc080e7          	jalr	220(ra) # 8000053e <panic>
    wakeup(&log);
    8000446a:	0001d497          	auipc	s1,0x1d
    8000446e:	ea648493          	addi	s1,s1,-346 # 80021310 <log>
    80004472:	8526                	mv	a0,s1
    80004474:	ffffe097          	auipc	ra,0xffffe
    80004478:	e78080e7          	jalr	-392(ra) # 800022ec <wakeup>
  release(&log.lock);
    8000447c:	8526                	mv	a0,s1
    8000447e:	ffffd097          	auipc	ra,0xffffd
    80004482:	80c080e7          	jalr	-2036(ra) # 80000c8a <release>
}
    80004486:	70e2                	ld	ra,56(sp)
    80004488:	7442                	ld	s0,48(sp)
    8000448a:	74a2                	ld	s1,40(sp)
    8000448c:	7902                	ld	s2,32(sp)
    8000448e:	69e2                	ld	s3,24(sp)
    80004490:	6a42                	ld	s4,16(sp)
    80004492:	6aa2                	ld	s5,8(sp)
    80004494:	6121                	addi	sp,sp,64
    80004496:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004498:	0001da97          	auipc	s5,0x1d
    8000449c:	ea8a8a93          	addi	s5,s5,-344 # 80021340 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800044a0:	0001da17          	auipc	s4,0x1d
    800044a4:	e70a0a13          	addi	s4,s4,-400 # 80021310 <log>
    800044a8:	018a2583          	lw	a1,24(s4)
    800044ac:	012585bb          	addw	a1,a1,s2
    800044b0:	2585                	addiw	a1,a1,1
    800044b2:	028a2503          	lw	a0,40(s4)
    800044b6:	fffff097          	auipc	ra,0xfffff
    800044ba:	cca080e7          	jalr	-822(ra) # 80003180 <bread>
    800044be:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800044c0:	000aa583          	lw	a1,0(s5)
    800044c4:	028a2503          	lw	a0,40(s4)
    800044c8:	fffff097          	auipc	ra,0xfffff
    800044cc:	cb8080e7          	jalr	-840(ra) # 80003180 <bread>
    800044d0:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800044d2:	40000613          	li	a2,1024
    800044d6:	05850593          	addi	a1,a0,88
    800044da:	05848513          	addi	a0,s1,88
    800044de:	ffffd097          	auipc	ra,0xffffd
    800044e2:	850080e7          	jalr	-1968(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    800044e6:	8526                	mv	a0,s1
    800044e8:	fffff097          	auipc	ra,0xfffff
    800044ec:	d8a080e7          	jalr	-630(ra) # 80003272 <bwrite>
    brelse(from);
    800044f0:	854e                	mv	a0,s3
    800044f2:	fffff097          	auipc	ra,0xfffff
    800044f6:	dbe080e7          	jalr	-578(ra) # 800032b0 <brelse>
    brelse(to);
    800044fa:	8526                	mv	a0,s1
    800044fc:	fffff097          	auipc	ra,0xfffff
    80004500:	db4080e7          	jalr	-588(ra) # 800032b0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004504:	2905                	addiw	s2,s2,1
    80004506:	0a91                	addi	s5,s5,4
    80004508:	02ca2783          	lw	a5,44(s4)
    8000450c:	f8f94ee3          	blt	s2,a5,800044a8 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004510:	00000097          	auipc	ra,0x0
    80004514:	c6a080e7          	jalr	-918(ra) # 8000417a <write_head>
    install_trans(0); // Now install writes to home locations
    80004518:	4501                	li	a0,0
    8000451a:	00000097          	auipc	ra,0x0
    8000451e:	cda080e7          	jalr	-806(ra) # 800041f4 <install_trans>
    log.lh.n = 0;
    80004522:	0001d797          	auipc	a5,0x1d
    80004526:	e007ad23          	sw	zero,-486(a5) # 8002133c <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000452a:	00000097          	auipc	ra,0x0
    8000452e:	c50080e7          	jalr	-944(ra) # 8000417a <write_head>
    80004532:	bdf5                	j	8000442e <end_op+0x52>

0000000080004534 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004534:	1101                	addi	sp,sp,-32
    80004536:	ec06                	sd	ra,24(sp)
    80004538:	e822                	sd	s0,16(sp)
    8000453a:	e426                	sd	s1,8(sp)
    8000453c:	e04a                	sd	s2,0(sp)
    8000453e:	1000                	addi	s0,sp,32
    80004540:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004542:	0001d917          	auipc	s2,0x1d
    80004546:	dce90913          	addi	s2,s2,-562 # 80021310 <log>
    8000454a:	854a                	mv	a0,s2
    8000454c:	ffffc097          	auipc	ra,0xffffc
    80004550:	68a080e7          	jalr	1674(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004554:	02c92603          	lw	a2,44(s2)
    80004558:	47f5                	li	a5,29
    8000455a:	06c7c563          	blt	a5,a2,800045c4 <log_write+0x90>
    8000455e:	0001d797          	auipc	a5,0x1d
    80004562:	dce7a783          	lw	a5,-562(a5) # 8002132c <log+0x1c>
    80004566:	37fd                	addiw	a5,a5,-1
    80004568:	04f65e63          	bge	a2,a5,800045c4 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000456c:	0001d797          	auipc	a5,0x1d
    80004570:	dc47a783          	lw	a5,-572(a5) # 80021330 <log+0x20>
    80004574:	06f05063          	blez	a5,800045d4 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004578:	4781                	li	a5,0
    8000457a:	06c05563          	blez	a2,800045e4 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000457e:	44cc                	lw	a1,12(s1)
    80004580:	0001d717          	auipc	a4,0x1d
    80004584:	dc070713          	addi	a4,a4,-576 # 80021340 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004588:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000458a:	4314                	lw	a3,0(a4)
    8000458c:	04b68c63          	beq	a3,a1,800045e4 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004590:	2785                	addiw	a5,a5,1
    80004592:	0711                	addi	a4,a4,4
    80004594:	fef61be3          	bne	a2,a5,8000458a <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004598:	0621                	addi	a2,a2,8
    8000459a:	060a                	slli	a2,a2,0x2
    8000459c:	0001d797          	auipc	a5,0x1d
    800045a0:	d7478793          	addi	a5,a5,-652 # 80021310 <log>
    800045a4:	963e                	add	a2,a2,a5
    800045a6:	44dc                	lw	a5,12(s1)
    800045a8:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800045aa:	8526                	mv	a0,s1
    800045ac:	fffff097          	auipc	ra,0xfffff
    800045b0:	da2080e7          	jalr	-606(ra) # 8000334e <bpin>
    log.lh.n++;
    800045b4:	0001d717          	auipc	a4,0x1d
    800045b8:	d5c70713          	addi	a4,a4,-676 # 80021310 <log>
    800045bc:	575c                	lw	a5,44(a4)
    800045be:	2785                	addiw	a5,a5,1
    800045c0:	d75c                	sw	a5,44(a4)
    800045c2:	a835                	j	800045fe <log_write+0xca>
    panic("too big a transaction");
    800045c4:	00004517          	auipc	a0,0x4
    800045c8:	1cc50513          	addi	a0,a0,460 # 80008790 <syscallnum+0x1a0>
    800045cc:	ffffc097          	auipc	ra,0xffffc
    800045d0:	f72080e7          	jalr	-142(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    800045d4:	00004517          	auipc	a0,0x4
    800045d8:	1d450513          	addi	a0,a0,468 # 800087a8 <syscallnum+0x1b8>
    800045dc:	ffffc097          	auipc	ra,0xffffc
    800045e0:	f62080e7          	jalr	-158(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    800045e4:	00878713          	addi	a4,a5,8
    800045e8:	00271693          	slli	a3,a4,0x2
    800045ec:	0001d717          	auipc	a4,0x1d
    800045f0:	d2470713          	addi	a4,a4,-732 # 80021310 <log>
    800045f4:	9736                	add	a4,a4,a3
    800045f6:	44d4                	lw	a3,12(s1)
    800045f8:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800045fa:	faf608e3          	beq	a2,a5,800045aa <log_write+0x76>
  }
  release(&log.lock);
    800045fe:	0001d517          	auipc	a0,0x1d
    80004602:	d1250513          	addi	a0,a0,-750 # 80021310 <log>
    80004606:	ffffc097          	auipc	ra,0xffffc
    8000460a:	684080e7          	jalr	1668(ra) # 80000c8a <release>
}
    8000460e:	60e2                	ld	ra,24(sp)
    80004610:	6442                	ld	s0,16(sp)
    80004612:	64a2                	ld	s1,8(sp)
    80004614:	6902                	ld	s2,0(sp)
    80004616:	6105                	addi	sp,sp,32
    80004618:	8082                	ret

000000008000461a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000461a:	1101                	addi	sp,sp,-32
    8000461c:	ec06                	sd	ra,24(sp)
    8000461e:	e822                	sd	s0,16(sp)
    80004620:	e426                	sd	s1,8(sp)
    80004622:	e04a                	sd	s2,0(sp)
    80004624:	1000                	addi	s0,sp,32
    80004626:	84aa                	mv	s1,a0
    80004628:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000462a:	00004597          	auipc	a1,0x4
    8000462e:	19e58593          	addi	a1,a1,414 # 800087c8 <syscallnum+0x1d8>
    80004632:	0521                	addi	a0,a0,8
    80004634:	ffffc097          	auipc	ra,0xffffc
    80004638:	512080e7          	jalr	1298(ra) # 80000b46 <initlock>
  lk->name = name;
    8000463c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004640:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004644:	0204a423          	sw	zero,40(s1)
}
    80004648:	60e2                	ld	ra,24(sp)
    8000464a:	6442                	ld	s0,16(sp)
    8000464c:	64a2                	ld	s1,8(sp)
    8000464e:	6902                	ld	s2,0(sp)
    80004650:	6105                	addi	sp,sp,32
    80004652:	8082                	ret

0000000080004654 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004654:	1101                	addi	sp,sp,-32
    80004656:	ec06                	sd	ra,24(sp)
    80004658:	e822                	sd	s0,16(sp)
    8000465a:	e426                	sd	s1,8(sp)
    8000465c:	e04a                	sd	s2,0(sp)
    8000465e:	1000                	addi	s0,sp,32
    80004660:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004662:	00850913          	addi	s2,a0,8
    80004666:	854a                	mv	a0,s2
    80004668:	ffffc097          	auipc	ra,0xffffc
    8000466c:	56e080e7          	jalr	1390(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    80004670:	409c                	lw	a5,0(s1)
    80004672:	cb89                	beqz	a5,80004684 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004674:	85ca                	mv	a1,s2
    80004676:	8526                	mv	a0,s1
    80004678:	ffffe097          	auipc	ra,0xffffe
    8000467c:	ac4080e7          	jalr	-1340(ra) # 8000213c <sleep>
  while (lk->locked) {
    80004680:	409c                	lw	a5,0(s1)
    80004682:	fbed                	bnez	a5,80004674 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004684:	4785                	li	a5,1
    80004686:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004688:	ffffd097          	auipc	ra,0xffffd
    8000468c:	324080e7          	jalr	804(ra) # 800019ac <myproc>
    80004690:	591c                	lw	a5,48(a0)
    80004692:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004694:	854a                	mv	a0,s2
    80004696:	ffffc097          	auipc	ra,0xffffc
    8000469a:	5f4080e7          	jalr	1524(ra) # 80000c8a <release>
}
    8000469e:	60e2                	ld	ra,24(sp)
    800046a0:	6442                	ld	s0,16(sp)
    800046a2:	64a2                	ld	s1,8(sp)
    800046a4:	6902                	ld	s2,0(sp)
    800046a6:	6105                	addi	sp,sp,32
    800046a8:	8082                	ret

00000000800046aa <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800046aa:	1101                	addi	sp,sp,-32
    800046ac:	ec06                	sd	ra,24(sp)
    800046ae:	e822                	sd	s0,16(sp)
    800046b0:	e426                	sd	s1,8(sp)
    800046b2:	e04a                	sd	s2,0(sp)
    800046b4:	1000                	addi	s0,sp,32
    800046b6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800046b8:	00850913          	addi	s2,a0,8
    800046bc:	854a                	mv	a0,s2
    800046be:	ffffc097          	auipc	ra,0xffffc
    800046c2:	518080e7          	jalr	1304(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    800046c6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800046ca:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800046ce:	8526                	mv	a0,s1
    800046d0:	ffffe097          	auipc	ra,0xffffe
    800046d4:	c1c080e7          	jalr	-996(ra) # 800022ec <wakeup>
  release(&lk->lk);
    800046d8:	854a                	mv	a0,s2
    800046da:	ffffc097          	auipc	ra,0xffffc
    800046de:	5b0080e7          	jalr	1456(ra) # 80000c8a <release>
}
    800046e2:	60e2                	ld	ra,24(sp)
    800046e4:	6442                	ld	s0,16(sp)
    800046e6:	64a2                	ld	s1,8(sp)
    800046e8:	6902                	ld	s2,0(sp)
    800046ea:	6105                	addi	sp,sp,32
    800046ec:	8082                	ret

00000000800046ee <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800046ee:	7179                	addi	sp,sp,-48
    800046f0:	f406                	sd	ra,40(sp)
    800046f2:	f022                	sd	s0,32(sp)
    800046f4:	ec26                	sd	s1,24(sp)
    800046f6:	e84a                	sd	s2,16(sp)
    800046f8:	e44e                	sd	s3,8(sp)
    800046fa:	1800                	addi	s0,sp,48
    800046fc:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800046fe:	00850913          	addi	s2,a0,8
    80004702:	854a                	mv	a0,s2
    80004704:	ffffc097          	auipc	ra,0xffffc
    80004708:	4d2080e7          	jalr	1234(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000470c:	409c                	lw	a5,0(s1)
    8000470e:	ef99                	bnez	a5,8000472c <holdingsleep+0x3e>
    80004710:	4481                	li	s1,0
  release(&lk->lk);
    80004712:	854a                	mv	a0,s2
    80004714:	ffffc097          	auipc	ra,0xffffc
    80004718:	576080e7          	jalr	1398(ra) # 80000c8a <release>
  return r;
}
    8000471c:	8526                	mv	a0,s1
    8000471e:	70a2                	ld	ra,40(sp)
    80004720:	7402                	ld	s0,32(sp)
    80004722:	64e2                	ld	s1,24(sp)
    80004724:	6942                	ld	s2,16(sp)
    80004726:	69a2                	ld	s3,8(sp)
    80004728:	6145                	addi	sp,sp,48
    8000472a:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000472c:	0284a983          	lw	s3,40(s1)
    80004730:	ffffd097          	auipc	ra,0xffffd
    80004734:	27c080e7          	jalr	636(ra) # 800019ac <myproc>
    80004738:	5904                	lw	s1,48(a0)
    8000473a:	413484b3          	sub	s1,s1,s3
    8000473e:	0014b493          	seqz	s1,s1
    80004742:	bfc1                	j	80004712 <holdingsleep+0x24>

0000000080004744 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004744:	1141                	addi	sp,sp,-16
    80004746:	e406                	sd	ra,8(sp)
    80004748:	e022                	sd	s0,0(sp)
    8000474a:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000474c:	00004597          	auipc	a1,0x4
    80004750:	08c58593          	addi	a1,a1,140 # 800087d8 <syscallnum+0x1e8>
    80004754:	0001d517          	auipc	a0,0x1d
    80004758:	d0450513          	addi	a0,a0,-764 # 80021458 <ftable>
    8000475c:	ffffc097          	auipc	ra,0xffffc
    80004760:	3ea080e7          	jalr	1002(ra) # 80000b46 <initlock>
}
    80004764:	60a2                	ld	ra,8(sp)
    80004766:	6402                	ld	s0,0(sp)
    80004768:	0141                	addi	sp,sp,16
    8000476a:	8082                	ret

000000008000476c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000476c:	1101                	addi	sp,sp,-32
    8000476e:	ec06                	sd	ra,24(sp)
    80004770:	e822                	sd	s0,16(sp)
    80004772:	e426                	sd	s1,8(sp)
    80004774:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004776:	0001d517          	auipc	a0,0x1d
    8000477a:	ce250513          	addi	a0,a0,-798 # 80021458 <ftable>
    8000477e:	ffffc097          	auipc	ra,0xffffc
    80004782:	458080e7          	jalr	1112(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004786:	0001d497          	auipc	s1,0x1d
    8000478a:	cea48493          	addi	s1,s1,-790 # 80021470 <ftable+0x18>
    8000478e:	0001e717          	auipc	a4,0x1e
    80004792:	c8270713          	addi	a4,a4,-894 # 80022410 <disk>
    if(f->ref == 0){
    80004796:	40dc                	lw	a5,4(s1)
    80004798:	cf99                	beqz	a5,800047b6 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000479a:	02848493          	addi	s1,s1,40
    8000479e:	fee49ce3          	bne	s1,a4,80004796 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800047a2:	0001d517          	auipc	a0,0x1d
    800047a6:	cb650513          	addi	a0,a0,-842 # 80021458 <ftable>
    800047aa:	ffffc097          	auipc	ra,0xffffc
    800047ae:	4e0080e7          	jalr	1248(ra) # 80000c8a <release>
  return 0;
    800047b2:	4481                	li	s1,0
    800047b4:	a819                	j	800047ca <filealloc+0x5e>
      f->ref = 1;
    800047b6:	4785                	li	a5,1
    800047b8:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800047ba:	0001d517          	auipc	a0,0x1d
    800047be:	c9e50513          	addi	a0,a0,-866 # 80021458 <ftable>
    800047c2:	ffffc097          	auipc	ra,0xffffc
    800047c6:	4c8080e7          	jalr	1224(ra) # 80000c8a <release>
}
    800047ca:	8526                	mv	a0,s1
    800047cc:	60e2                	ld	ra,24(sp)
    800047ce:	6442                	ld	s0,16(sp)
    800047d0:	64a2                	ld	s1,8(sp)
    800047d2:	6105                	addi	sp,sp,32
    800047d4:	8082                	ret

00000000800047d6 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800047d6:	1101                	addi	sp,sp,-32
    800047d8:	ec06                	sd	ra,24(sp)
    800047da:	e822                	sd	s0,16(sp)
    800047dc:	e426                	sd	s1,8(sp)
    800047de:	1000                	addi	s0,sp,32
    800047e0:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800047e2:	0001d517          	auipc	a0,0x1d
    800047e6:	c7650513          	addi	a0,a0,-906 # 80021458 <ftable>
    800047ea:	ffffc097          	auipc	ra,0xffffc
    800047ee:	3ec080e7          	jalr	1004(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    800047f2:	40dc                	lw	a5,4(s1)
    800047f4:	02f05263          	blez	a5,80004818 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800047f8:	2785                	addiw	a5,a5,1
    800047fa:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800047fc:	0001d517          	auipc	a0,0x1d
    80004800:	c5c50513          	addi	a0,a0,-932 # 80021458 <ftable>
    80004804:	ffffc097          	auipc	ra,0xffffc
    80004808:	486080e7          	jalr	1158(ra) # 80000c8a <release>
  return f;
}
    8000480c:	8526                	mv	a0,s1
    8000480e:	60e2                	ld	ra,24(sp)
    80004810:	6442                	ld	s0,16(sp)
    80004812:	64a2                	ld	s1,8(sp)
    80004814:	6105                	addi	sp,sp,32
    80004816:	8082                	ret
    panic("filedup");
    80004818:	00004517          	auipc	a0,0x4
    8000481c:	fc850513          	addi	a0,a0,-56 # 800087e0 <syscallnum+0x1f0>
    80004820:	ffffc097          	auipc	ra,0xffffc
    80004824:	d1e080e7          	jalr	-738(ra) # 8000053e <panic>

0000000080004828 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004828:	7139                	addi	sp,sp,-64
    8000482a:	fc06                	sd	ra,56(sp)
    8000482c:	f822                	sd	s0,48(sp)
    8000482e:	f426                	sd	s1,40(sp)
    80004830:	f04a                	sd	s2,32(sp)
    80004832:	ec4e                	sd	s3,24(sp)
    80004834:	e852                	sd	s4,16(sp)
    80004836:	e456                	sd	s5,8(sp)
    80004838:	0080                	addi	s0,sp,64
    8000483a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000483c:	0001d517          	auipc	a0,0x1d
    80004840:	c1c50513          	addi	a0,a0,-996 # 80021458 <ftable>
    80004844:	ffffc097          	auipc	ra,0xffffc
    80004848:	392080e7          	jalr	914(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    8000484c:	40dc                	lw	a5,4(s1)
    8000484e:	06f05163          	blez	a5,800048b0 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004852:	37fd                	addiw	a5,a5,-1
    80004854:	0007871b          	sext.w	a4,a5
    80004858:	c0dc                	sw	a5,4(s1)
    8000485a:	06e04363          	bgtz	a4,800048c0 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000485e:	0004a903          	lw	s2,0(s1)
    80004862:	0094ca83          	lbu	s5,9(s1)
    80004866:	0104ba03          	ld	s4,16(s1)
    8000486a:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000486e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004872:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004876:	0001d517          	auipc	a0,0x1d
    8000487a:	be250513          	addi	a0,a0,-1054 # 80021458 <ftable>
    8000487e:	ffffc097          	auipc	ra,0xffffc
    80004882:	40c080e7          	jalr	1036(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    80004886:	4785                	li	a5,1
    80004888:	04f90d63          	beq	s2,a5,800048e2 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000488c:	3979                	addiw	s2,s2,-2
    8000488e:	4785                	li	a5,1
    80004890:	0527e063          	bltu	a5,s2,800048d0 <fileclose+0xa8>
    begin_op();
    80004894:	00000097          	auipc	ra,0x0
    80004898:	ac8080e7          	jalr	-1336(ra) # 8000435c <begin_op>
    iput(ff.ip);
    8000489c:	854e                	mv	a0,s3
    8000489e:	fffff097          	auipc	ra,0xfffff
    800048a2:	2b6080e7          	jalr	694(ra) # 80003b54 <iput>
    end_op();
    800048a6:	00000097          	auipc	ra,0x0
    800048aa:	b36080e7          	jalr	-1226(ra) # 800043dc <end_op>
    800048ae:	a00d                	j	800048d0 <fileclose+0xa8>
    panic("fileclose");
    800048b0:	00004517          	auipc	a0,0x4
    800048b4:	f3850513          	addi	a0,a0,-200 # 800087e8 <syscallnum+0x1f8>
    800048b8:	ffffc097          	auipc	ra,0xffffc
    800048bc:	c86080e7          	jalr	-890(ra) # 8000053e <panic>
    release(&ftable.lock);
    800048c0:	0001d517          	auipc	a0,0x1d
    800048c4:	b9850513          	addi	a0,a0,-1128 # 80021458 <ftable>
    800048c8:	ffffc097          	auipc	ra,0xffffc
    800048cc:	3c2080e7          	jalr	962(ra) # 80000c8a <release>
  }
}
    800048d0:	70e2                	ld	ra,56(sp)
    800048d2:	7442                	ld	s0,48(sp)
    800048d4:	74a2                	ld	s1,40(sp)
    800048d6:	7902                	ld	s2,32(sp)
    800048d8:	69e2                	ld	s3,24(sp)
    800048da:	6a42                	ld	s4,16(sp)
    800048dc:	6aa2                	ld	s5,8(sp)
    800048de:	6121                	addi	sp,sp,64
    800048e0:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800048e2:	85d6                	mv	a1,s5
    800048e4:	8552                	mv	a0,s4
    800048e6:	00000097          	auipc	ra,0x0
    800048ea:	34c080e7          	jalr	844(ra) # 80004c32 <pipeclose>
    800048ee:	b7cd                	j	800048d0 <fileclose+0xa8>

00000000800048f0 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800048f0:	715d                	addi	sp,sp,-80
    800048f2:	e486                	sd	ra,72(sp)
    800048f4:	e0a2                	sd	s0,64(sp)
    800048f6:	fc26                	sd	s1,56(sp)
    800048f8:	f84a                	sd	s2,48(sp)
    800048fa:	f44e                	sd	s3,40(sp)
    800048fc:	0880                	addi	s0,sp,80
    800048fe:	84aa                	mv	s1,a0
    80004900:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004902:	ffffd097          	auipc	ra,0xffffd
    80004906:	0aa080e7          	jalr	170(ra) # 800019ac <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000490a:	409c                	lw	a5,0(s1)
    8000490c:	37f9                	addiw	a5,a5,-2
    8000490e:	4705                	li	a4,1
    80004910:	04f76763          	bltu	a4,a5,8000495e <filestat+0x6e>
    80004914:	892a                	mv	s2,a0
    ilock(f->ip);
    80004916:	6c88                	ld	a0,24(s1)
    80004918:	fffff097          	auipc	ra,0xfffff
    8000491c:	082080e7          	jalr	130(ra) # 8000399a <ilock>
    stati(f->ip, &st);
    80004920:	fb840593          	addi	a1,s0,-72
    80004924:	6c88                	ld	a0,24(s1)
    80004926:	fffff097          	auipc	ra,0xfffff
    8000492a:	2fe080e7          	jalr	766(ra) # 80003c24 <stati>
    iunlock(f->ip);
    8000492e:	6c88                	ld	a0,24(s1)
    80004930:	fffff097          	auipc	ra,0xfffff
    80004934:	12c080e7          	jalr	300(ra) # 80003a5c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004938:	46e1                	li	a3,24
    8000493a:	fb840613          	addi	a2,s0,-72
    8000493e:	85ce                	mv	a1,s3
    80004940:	05093503          	ld	a0,80(s2)
    80004944:	ffffd097          	auipc	ra,0xffffd
    80004948:	d24080e7          	jalr	-732(ra) # 80001668 <copyout>
    8000494c:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004950:	60a6                	ld	ra,72(sp)
    80004952:	6406                	ld	s0,64(sp)
    80004954:	74e2                	ld	s1,56(sp)
    80004956:	7942                	ld	s2,48(sp)
    80004958:	79a2                	ld	s3,40(sp)
    8000495a:	6161                	addi	sp,sp,80
    8000495c:	8082                	ret
  return -1;
    8000495e:	557d                	li	a0,-1
    80004960:	bfc5                	j	80004950 <filestat+0x60>

0000000080004962 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004962:	7179                	addi	sp,sp,-48
    80004964:	f406                	sd	ra,40(sp)
    80004966:	f022                	sd	s0,32(sp)
    80004968:	ec26                	sd	s1,24(sp)
    8000496a:	e84a                	sd	s2,16(sp)
    8000496c:	e44e                	sd	s3,8(sp)
    8000496e:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004970:	00854783          	lbu	a5,8(a0)
    80004974:	c3d5                	beqz	a5,80004a18 <fileread+0xb6>
    80004976:	84aa                	mv	s1,a0
    80004978:	89ae                	mv	s3,a1
    8000497a:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000497c:	411c                	lw	a5,0(a0)
    8000497e:	4705                	li	a4,1
    80004980:	04e78963          	beq	a5,a4,800049d2 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004984:	470d                	li	a4,3
    80004986:	04e78d63          	beq	a5,a4,800049e0 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000498a:	4709                	li	a4,2
    8000498c:	06e79e63          	bne	a5,a4,80004a08 <fileread+0xa6>
    ilock(f->ip);
    80004990:	6d08                	ld	a0,24(a0)
    80004992:	fffff097          	auipc	ra,0xfffff
    80004996:	008080e7          	jalr	8(ra) # 8000399a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000499a:	874a                	mv	a4,s2
    8000499c:	5094                	lw	a3,32(s1)
    8000499e:	864e                	mv	a2,s3
    800049a0:	4585                	li	a1,1
    800049a2:	6c88                	ld	a0,24(s1)
    800049a4:	fffff097          	auipc	ra,0xfffff
    800049a8:	2aa080e7          	jalr	682(ra) # 80003c4e <readi>
    800049ac:	892a                	mv	s2,a0
    800049ae:	00a05563          	blez	a0,800049b8 <fileread+0x56>
      f->off += r;
    800049b2:	509c                	lw	a5,32(s1)
    800049b4:	9fa9                	addw	a5,a5,a0
    800049b6:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800049b8:	6c88                	ld	a0,24(s1)
    800049ba:	fffff097          	auipc	ra,0xfffff
    800049be:	0a2080e7          	jalr	162(ra) # 80003a5c <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800049c2:	854a                	mv	a0,s2
    800049c4:	70a2                	ld	ra,40(sp)
    800049c6:	7402                	ld	s0,32(sp)
    800049c8:	64e2                	ld	s1,24(sp)
    800049ca:	6942                	ld	s2,16(sp)
    800049cc:	69a2                	ld	s3,8(sp)
    800049ce:	6145                	addi	sp,sp,48
    800049d0:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800049d2:	6908                	ld	a0,16(a0)
    800049d4:	00000097          	auipc	ra,0x0
    800049d8:	3c6080e7          	jalr	966(ra) # 80004d9a <piperead>
    800049dc:	892a                	mv	s2,a0
    800049de:	b7d5                	j	800049c2 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800049e0:	02451783          	lh	a5,36(a0)
    800049e4:	03079693          	slli	a3,a5,0x30
    800049e8:	92c1                	srli	a3,a3,0x30
    800049ea:	4725                	li	a4,9
    800049ec:	02d76863          	bltu	a4,a3,80004a1c <fileread+0xba>
    800049f0:	0792                	slli	a5,a5,0x4
    800049f2:	0001d717          	auipc	a4,0x1d
    800049f6:	9c670713          	addi	a4,a4,-1594 # 800213b8 <devsw>
    800049fa:	97ba                	add	a5,a5,a4
    800049fc:	639c                	ld	a5,0(a5)
    800049fe:	c38d                	beqz	a5,80004a20 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004a00:	4505                	li	a0,1
    80004a02:	9782                	jalr	a5
    80004a04:	892a                	mv	s2,a0
    80004a06:	bf75                	j	800049c2 <fileread+0x60>
    panic("fileread");
    80004a08:	00004517          	auipc	a0,0x4
    80004a0c:	df050513          	addi	a0,a0,-528 # 800087f8 <syscallnum+0x208>
    80004a10:	ffffc097          	auipc	ra,0xffffc
    80004a14:	b2e080e7          	jalr	-1234(ra) # 8000053e <panic>
    return -1;
    80004a18:	597d                	li	s2,-1
    80004a1a:	b765                	j	800049c2 <fileread+0x60>
      return -1;
    80004a1c:	597d                	li	s2,-1
    80004a1e:	b755                	j	800049c2 <fileread+0x60>
    80004a20:	597d                	li	s2,-1
    80004a22:	b745                	j	800049c2 <fileread+0x60>

0000000080004a24 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004a24:	715d                	addi	sp,sp,-80
    80004a26:	e486                	sd	ra,72(sp)
    80004a28:	e0a2                	sd	s0,64(sp)
    80004a2a:	fc26                	sd	s1,56(sp)
    80004a2c:	f84a                	sd	s2,48(sp)
    80004a2e:	f44e                	sd	s3,40(sp)
    80004a30:	f052                	sd	s4,32(sp)
    80004a32:	ec56                	sd	s5,24(sp)
    80004a34:	e85a                	sd	s6,16(sp)
    80004a36:	e45e                	sd	s7,8(sp)
    80004a38:	e062                	sd	s8,0(sp)
    80004a3a:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004a3c:	00954783          	lbu	a5,9(a0)
    80004a40:	10078663          	beqz	a5,80004b4c <filewrite+0x128>
    80004a44:	892a                	mv	s2,a0
    80004a46:	8aae                	mv	s5,a1
    80004a48:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004a4a:	411c                	lw	a5,0(a0)
    80004a4c:	4705                	li	a4,1
    80004a4e:	02e78263          	beq	a5,a4,80004a72 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a52:	470d                	li	a4,3
    80004a54:	02e78663          	beq	a5,a4,80004a80 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a58:	4709                	li	a4,2
    80004a5a:	0ee79163          	bne	a5,a4,80004b3c <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004a5e:	0ac05d63          	blez	a2,80004b18 <filewrite+0xf4>
    int i = 0;
    80004a62:	4981                	li	s3,0
    80004a64:	6b05                	lui	s6,0x1
    80004a66:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004a6a:	6b85                	lui	s7,0x1
    80004a6c:	c00b8b9b          	addiw	s7,s7,-1024
    80004a70:	a861                	j	80004b08 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004a72:	6908                	ld	a0,16(a0)
    80004a74:	00000097          	auipc	ra,0x0
    80004a78:	22e080e7          	jalr	558(ra) # 80004ca2 <pipewrite>
    80004a7c:	8a2a                	mv	s4,a0
    80004a7e:	a045                	j	80004b1e <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004a80:	02451783          	lh	a5,36(a0)
    80004a84:	03079693          	slli	a3,a5,0x30
    80004a88:	92c1                	srli	a3,a3,0x30
    80004a8a:	4725                	li	a4,9
    80004a8c:	0cd76263          	bltu	a4,a3,80004b50 <filewrite+0x12c>
    80004a90:	0792                	slli	a5,a5,0x4
    80004a92:	0001d717          	auipc	a4,0x1d
    80004a96:	92670713          	addi	a4,a4,-1754 # 800213b8 <devsw>
    80004a9a:	97ba                	add	a5,a5,a4
    80004a9c:	679c                	ld	a5,8(a5)
    80004a9e:	cbdd                	beqz	a5,80004b54 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004aa0:	4505                	li	a0,1
    80004aa2:	9782                	jalr	a5
    80004aa4:	8a2a                	mv	s4,a0
    80004aa6:	a8a5                	j	80004b1e <filewrite+0xfa>
    80004aa8:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004aac:	00000097          	auipc	ra,0x0
    80004ab0:	8b0080e7          	jalr	-1872(ra) # 8000435c <begin_op>
      ilock(f->ip);
    80004ab4:	01893503          	ld	a0,24(s2)
    80004ab8:	fffff097          	auipc	ra,0xfffff
    80004abc:	ee2080e7          	jalr	-286(ra) # 8000399a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004ac0:	8762                	mv	a4,s8
    80004ac2:	02092683          	lw	a3,32(s2)
    80004ac6:	01598633          	add	a2,s3,s5
    80004aca:	4585                	li	a1,1
    80004acc:	01893503          	ld	a0,24(s2)
    80004ad0:	fffff097          	auipc	ra,0xfffff
    80004ad4:	276080e7          	jalr	630(ra) # 80003d46 <writei>
    80004ad8:	84aa                	mv	s1,a0
    80004ada:	00a05763          	blez	a0,80004ae8 <filewrite+0xc4>
        f->off += r;
    80004ade:	02092783          	lw	a5,32(s2)
    80004ae2:	9fa9                	addw	a5,a5,a0
    80004ae4:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004ae8:	01893503          	ld	a0,24(s2)
    80004aec:	fffff097          	auipc	ra,0xfffff
    80004af0:	f70080e7          	jalr	-144(ra) # 80003a5c <iunlock>
      end_op();
    80004af4:	00000097          	auipc	ra,0x0
    80004af8:	8e8080e7          	jalr	-1816(ra) # 800043dc <end_op>

      if(r != n1){
    80004afc:	009c1f63          	bne	s8,s1,80004b1a <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004b00:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004b04:	0149db63          	bge	s3,s4,80004b1a <filewrite+0xf6>
      int n1 = n - i;
    80004b08:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004b0c:	84be                	mv	s1,a5
    80004b0e:	2781                	sext.w	a5,a5
    80004b10:	f8fb5ce3          	bge	s6,a5,80004aa8 <filewrite+0x84>
    80004b14:	84de                	mv	s1,s7
    80004b16:	bf49                	j	80004aa8 <filewrite+0x84>
    int i = 0;
    80004b18:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004b1a:	013a1f63          	bne	s4,s3,80004b38 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004b1e:	8552                	mv	a0,s4
    80004b20:	60a6                	ld	ra,72(sp)
    80004b22:	6406                	ld	s0,64(sp)
    80004b24:	74e2                	ld	s1,56(sp)
    80004b26:	7942                	ld	s2,48(sp)
    80004b28:	79a2                	ld	s3,40(sp)
    80004b2a:	7a02                	ld	s4,32(sp)
    80004b2c:	6ae2                	ld	s5,24(sp)
    80004b2e:	6b42                	ld	s6,16(sp)
    80004b30:	6ba2                	ld	s7,8(sp)
    80004b32:	6c02                	ld	s8,0(sp)
    80004b34:	6161                	addi	sp,sp,80
    80004b36:	8082                	ret
    ret = (i == n ? n : -1);
    80004b38:	5a7d                	li	s4,-1
    80004b3a:	b7d5                	j	80004b1e <filewrite+0xfa>
    panic("filewrite");
    80004b3c:	00004517          	auipc	a0,0x4
    80004b40:	ccc50513          	addi	a0,a0,-820 # 80008808 <syscallnum+0x218>
    80004b44:	ffffc097          	auipc	ra,0xffffc
    80004b48:	9fa080e7          	jalr	-1542(ra) # 8000053e <panic>
    return -1;
    80004b4c:	5a7d                	li	s4,-1
    80004b4e:	bfc1                	j	80004b1e <filewrite+0xfa>
      return -1;
    80004b50:	5a7d                	li	s4,-1
    80004b52:	b7f1                	j	80004b1e <filewrite+0xfa>
    80004b54:	5a7d                	li	s4,-1
    80004b56:	b7e1                	j	80004b1e <filewrite+0xfa>

0000000080004b58 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004b58:	7179                	addi	sp,sp,-48
    80004b5a:	f406                	sd	ra,40(sp)
    80004b5c:	f022                	sd	s0,32(sp)
    80004b5e:	ec26                	sd	s1,24(sp)
    80004b60:	e84a                	sd	s2,16(sp)
    80004b62:	e44e                	sd	s3,8(sp)
    80004b64:	e052                	sd	s4,0(sp)
    80004b66:	1800                	addi	s0,sp,48
    80004b68:	84aa                	mv	s1,a0
    80004b6a:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004b6c:	0005b023          	sd	zero,0(a1)
    80004b70:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004b74:	00000097          	auipc	ra,0x0
    80004b78:	bf8080e7          	jalr	-1032(ra) # 8000476c <filealloc>
    80004b7c:	e088                	sd	a0,0(s1)
    80004b7e:	c551                	beqz	a0,80004c0a <pipealloc+0xb2>
    80004b80:	00000097          	auipc	ra,0x0
    80004b84:	bec080e7          	jalr	-1044(ra) # 8000476c <filealloc>
    80004b88:	00aa3023          	sd	a0,0(s4)
    80004b8c:	c92d                	beqz	a0,80004bfe <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004b8e:	ffffc097          	auipc	ra,0xffffc
    80004b92:	f58080e7          	jalr	-168(ra) # 80000ae6 <kalloc>
    80004b96:	892a                	mv	s2,a0
    80004b98:	c125                	beqz	a0,80004bf8 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004b9a:	4985                	li	s3,1
    80004b9c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004ba0:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004ba4:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004ba8:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004bac:	00004597          	auipc	a1,0x4
    80004bb0:	8d458593          	addi	a1,a1,-1836 # 80008480 <states.0+0x1b8>
    80004bb4:	ffffc097          	auipc	ra,0xffffc
    80004bb8:	f92080e7          	jalr	-110(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004bbc:	609c                	ld	a5,0(s1)
    80004bbe:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004bc2:	609c                	ld	a5,0(s1)
    80004bc4:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004bc8:	609c                	ld	a5,0(s1)
    80004bca:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004bce:	609c                	ld	a5,0(s1)
    80004bd0:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004bd4:	000a3783          	ld	a5,0(s4)
    80004bd8:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004bdc:	000a3783          	ld	a5,0(s4)
    80004be0:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004be4:	000a3783          	ld	a5,0(s4)
    80004be8:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004bec:	000a3783          	ld	a5,0(s4)
    80004bf0:	0127b823          	sd	s2,16(a5)
  return 0;
    80004bf4:	4501                	li	a0,0
    80004bf6:	a025                	j	80004c1e <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004bf8:	6088                	ld	a0,0(s1)
    80004bfa:	e501                	bnez	a0,80004c02 <pipealloc+0xaa>
    80004bfc:	a039                	j	80004c0a <pipealloc+0xb2>
    80004bfe:	6088                	ld	a0,0(s1)
    80004c00:	c51d                	beqz	a0,80004c2e <pipealloc+0xd6>
    fileclose(*f0);
    80004c02:	00000097          	auipc	ra,0x0
    80004c06:	c26080e7          	jalr	-986(ra) # 80004828 <fileclose>
  if(*f1)
    80004c0a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004c0e:	557d                	li	a0,-1
  if(*f1)
    80004c10:	c799                	beqz	a5,80004c1e <pipealloc+0xc6>
    fileclose(*f1);
    80004c12:	853e                	mv	a0,a5
    80004c14:	00000097          	auipc	ra,0x0
    80004c18:	c14080e7          	jalr	-1004(ra) # 80004828 <fileclose>
  return -1;
    80004c1c:	557d                	li	a0,-1
}
    80004c1e:	70a2                	ld	ra,40(sp)
    80004c20:	7402                	ld	s0,32(sp)
    80004c22:	64e2                	ld	s1,24(sp)
    80004c24:	6942                	ld	s2,16(sp)
    80004c26:	69a2                	ld	s3,8(sp)
    80004c28:	6a02                	ld	s4,0(sp)
    80004c2a:	6145                	addi	sp,sp,48
    80004c2c:	8082                	ret
  return -1;
    80004c2e:	557d                	li	a0,-1
    80004c30:	b7fd                	j	80004c1e <pipealloc+0xc6>

0000000080004c32 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004c32:	1101                	addi	sp,sp,-32
    80004c34:	ec06                	sd	ra,24(sp)
    80004c36:	e822                	sd	s0,16(sp)
    80004c38:	e426                	sd	s1,8(sp)
    80004c3a:	e04a                	sd	s2,0(sp)
    80004c3c:	1000                	addi	s0,sp,32
    80004c3e:	84aa                	mv	s1,a0
    80004c40:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004c42:	ffffc097          	auipc	ra,0xffffc
    80004c46:	f94080e7          	jalr	-108(ra) # 80000bd6 <acquire>
  if(writable){
    80004c4a:	02090d63          	beqz	s2,80004c84 <pipeclose+0x52>
    pi->writeopen = 0;
    80004c4e:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004c52:	21848513          	addi	a0,s1,536
    80004c56:	ffffd097          	auipc	ra,0xffffd
    80004c5a:	696080e7          	jalr	1686(ra) # 800022ec <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004c5e:	2204b783          	ld	a5,544(s1)
    80004c62:	eb95                	bnez	a5,80004c96 <pipeclose+0x64>
    release(&pi->lock);
    80004c64:	8526                	mv	a0,s1
    80004c66:	ffffc097          	auipc	ra,0xffffc
    80004c6a:	024080e7          	jalr	36(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004c6e:	8526                	mv	a0,s1
    80004c70:	ffffc097          	auipc	ra,0xffffc
    80004c74:	d7a080e7          	jalr	-646(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    80004c78:	60e2                	ld	ra,24(sp)
    80004c7a:	6442                	ld	s0,16(sp)
    80004c7c:	64a2                	ld	s1,8(sp)
    80004c7e:	6902                	ld	s2,0(sp)
    80004c80:	6105                	addi	sp,sp,32
    80004c82:	8082                	ret
    pi->readopen = 0;
    80004c84:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004c88:	21c48513          	addi	a0,s1,540
    80004c8c:	ffffd097          	auipc	ra,0xffffd
    80004c90:	660080e7          	jalr	1632(ra) # 800022ec <wakeup>
    80004c94:	b7e9                	j	80004c5e <pipeclose+0x2c>
    release(&pi->lock);
    80004c96:	8526                	mv	a0,s1
    80004c98:	ffffc097          	auipc	ra,0xffffc
    80004c9c:	ff2080e7          	jalr	-14(ra) # 80000c8a <release>
}
    80004ca0:	bfe1                	j	80004c78 <pipeclose+0x46>

0000000080004ca2 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004ca2:	711d                	addi	sp,sp,-96
    80004ca4:	ec86                	sd	ra,88(sp)
    80004ca6:	e8a2                	sd	s0,80(sp)
    80004ca8:	e4a6                	sd	s1,72(sp)
    80004caa:	e0ca                	sd	s2,64(sp)
    80004cac:	fc4e                	sd	s3,56(sp)
    80004cae:	f852                	sd	s4,48(sp)
    80004cb0:	f456                	sd	s5,40(sp)
    80004cb2:	f05a                	sd	s6,32(sp)
    80004cb4:	ec5e                	sd	s7,24(sp)
    80004cb6:	e862                	sd	s8,16(sp)
    80004cb8:	1080                	addi	s0,sp,96
    80004cba:	84aa                	mv	s1,a0
    80004cbc:	8aae                	mv	s5,a1
    80004cbe:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004cc0:	ffffd097          	auipc	ra,0xffffd
    80004cc4:	cec080e7          	jalr	-788(ra) # 800019ac <myproc>
    80004cc8:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004cca:	8526                	mv	a0,s1
    80004ccc:	ffffc097          	auipc	ra,0xffffc
    80004cd0:	f0a080e7          	jalr	-246(ra) # 80000bd6 <acquire>
  while(i < n){
    80004cd4:	0b405663          	blez	s4,80004d80 <pipewrite+0xde>
  int i = 0;
    80004cd8:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004cda:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004cdc:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004ce0:	21c48b93          	addi	s7,s1,540
    80004ce4:	a089                	j	80004d26 <pipewrite+0x84>
      release(&pi->lock);
    80004ce6:	8526                	mv	a0,s1
    80004ce8:	ffffc097          	auipc	ra,0xffffc
    80004cec:	fa2080e7          	jalr	-94(ra) # 80000c8a <release>
      return -1;
    80004cf0:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004cf2:	854a                	mv	a0,s2
    80004cf4:	60e6                	ld	ra,88(sp)
    80004cf6:	6446                	ld	s0,80(sp)
    80004cf8:	64a6                	ld	s1,72(sp)
    80004cfa:	6906                	ld	s2,64(sp)
    80004cfc:	79e2                	ld	s3,56(sp)
    80004cfe:	7a42                	ld	s4,48(sp)
    80004d00:	7aa2                	ld	s5,40(sp)
    80004d02:	7b02                	ld	s6,32(sp)
    80004d04:	6be2                	ld	s7,24(sp)
    80004d06:	6c42                	ld	s8,16(sp)
    80004d08:	6125                	addi	sp,sp,96
    80004d0a:	8082                	ret
      wakeup(&pi->nread);
    80004d0c:	8562                	mv	a0,s8
    80004d0e:	ffffd097          	auipc	ra,0xffffd
    80004d12:	5de080e7          	jalr	1502(ra) # 800022ec <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004d16:	85a6                	mv	a1,s1
    80004d18:	855e                	mv	a0,s7
    80004d1a:	ffffd097          	auipc	ra,0xffffd
    80004d1e:	422080e7          	jalr	1058(ra) # 8000213c <sleep>
  while(i < n){
    80004d22:	07495063          	bge	s2,s4,80004d82 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004d26:	2204a783          	lw	a5,544(s1)
    80004d2a:	dfd5                	beqz	a5,80004ce6 <pipewrite+0x44>
    80004d2c:	854e                	mv	a0,s3
    80004d2e:	ffffe097          	auipc	ra,0xffffe
    80004d32:	80e080e7          	jalr	-2034(ra) # 8000253c <killed>
    80004d36:	f945                	bnez	a0,80004ce6 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004d38:	2184a783          	lw	a5,536(s1)
    80004d3c:	21c4a703          	lw	a4,540(s1)
    80004d40:	2007879b          	addiw	a5,a5,512
    80004d44:	fcf704e3          	beq	a4,a5,80004d0c <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d48:	4685                	li	a3,1
    80004d4a:	01590633          	add	a2,s2,s5
    80004d4e:	faf40593          	addi	a1,s0,-81
    80004d52:	0509b503          	ld	a0,80(s3)
    80004d56:	ffffd097          	auipc	ra,0xffffd
    80004d5a:	99e080e7          	jalr	-1634(ra) # 800016f4 <copyin>
    80004d5e:	03650263          	beq	a0,s6,80004d82 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004d62:	21c4a783          	lw	a5,540(s1)
    80004d66:	0017871b          	addiw	a4,a5,1
    80004d6a:	20e4ae23          	sw	a4,540(s1)
    80004d6e:	1ff7f793          	andi	a5,a5,511
    80004d72:	97a6                	add	a5,a5,s1
    80004d74:	faf44703          	lbu	a4,-81(s0)
    80004d78:	00e78c23          	sb	a4,24(a5)
      i++;
    80004d7c:	2905                	addiw	s2,s2,1
    80004d7e:	b755                	j	80004d22 <pipewrite+0x80>
  int i = 0;
    80004d80:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004d82:	21848513          	addi	a0,s1,536
    80004d86:	ffffd097          	auipc	ra,0xffffd
    80004d8a:	566080e7          	jalr	1382(ra) # 800022ec <wakeup>
  release(&pi->lock);
    80004d8e:	8526                	mv	a0,s1
    80004d90:	ffffc097          	auipc	ra,0xffffc
    80004d94:	efa080e7          	jalr	-262(ra) # 80000c8a <release>
  return i;
    80004d98:	bfa9                	j	80004cf2 <pipewrite+0x50>

0000000080004d9a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d9a:	715d                	addi	sp,sp,-80
    80004d9c:	e486                	sd	ra,72(sp)
    80004d9e:	e0a2                	sd	s0,64(sp)
    80004da0:	fc26                	sd	s1,56(sp)
    80004da2:	f84a                	sd	s2,48(sp)
    80004da4:	f44e                	sd	s3,40(sp)
    80004da6:	f052                	sd	s4,32(sp)
    80004da8:	ec56                	sd	s5,24(sp)
    80004daa:	e85a                	sd	s6,16(sp)
    80004dac:	0880                	addi	s0,sp,80
    80004dae:	84aa                	mv	s1,a0
    80004db0:	892e                	mv	s2,a1
    80004db2:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004db4:	ffffd097          	auipc	ra,0xffffd
    80004db8:	bf8080e7          	jalr	-1032(ra) # 800019ac <myproc>
    80004dbc:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004dbe:	8526                	mv	a0,s1
    80004dc0:	ffffc097          	auipc	ra,0xffffc
    80004dc4:	e16080e7          	jalr	-490(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004dc8:	2184a703          	lw	a4,536(s1)
    80004dcc:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004dd0:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004dd4:	02f71763          	bne	a4,a5,80004e02 <piperead+0x68>
    80004dd8:	2244a783          	lw	a5,548(s1)
    80004ddc:	c39d                	beqz	a5,80004e02 <piperead+0x68>
    if(killed(pr)){
    80004dde:	8552                	mv	a0,s4
    80004de0:	ffffd097          	auipc	ra,0xffffd
    80004de4:	75c080e7          	jalr	1884(ra) # 8000253c <killed>
    80004de8:	e941                	bnez	a0,80004e78 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004dea:	85a6                	mv	a1,s1
    80004dec:	854e                	mv	a0,s3
    80004dee:	ffffd097          	auipc	ra,0xffffd
    80004df2:	34e080e7          	jalr	846(ra) # 8000213c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004df6:	2184a703          	lw	a4,536(s1)
    80004dfa:	21c4a783          	lw	a5,540(s1)
    80004dfe:	fcf70de3          	beq	a4,a5,80004dd8 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e02:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e04:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e06:	05505363          	blez	s5,80004e4c <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004e0a:	2184a783          	lw	a5,536(s1)
    80004e0e:	21c4a703          	lw	a4,540(s1)
    80004e12:	02f70d63          	beq	a4,a5,80004e4c <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004e16:	0017871b          	addiw	a4,a5,1
    80004e1a:	20e4ac23          	sw	a4,536(s1)
    80004e1e:	1ff7f793          	andi	a5,a5,511
    80004e22:	97a6                	add	a5,a5,s1
    80004e24:	0187c783          	lbu	a5,24(a5)
    80004e28:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e2c:	4685                	li	a3,1
    80004e2e:	fbf40613          	addi	a2,s0,-65
    80004e32:	85ca                	mv	a1,s2
    80004e34:	050a3503          	ld	a0,80(s4)
    80004e38:	ffffd097          	auipc	ra,0xffffd
    80004e3c:	830080e7          	jalr	-2000(ra) # 80001668 <copyout>
    80004e40:	01650663          	beq	a0,s6,80004e4c <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e44:	2985                	addiw	s3,s3,1
    80004e46:	0905                	addi	s2,s2,1
    80004e48:	fd3a91e3          	bne	s5,s3,80004e0a <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004e4c:	21c48513          	addi	a0,s1,540
    80004e50:	ffffd097          	auipc	ra,0xffffd
    80004e54:	49c080e7          	jalr	1180(ra) # 800022ec <wakeup>
  release(&pi->lock);
    80004e58:	8526                	mv	a0,s1
    80004e5a:	ffffc097          	auipc	ra,0xffffc
    80004e5e:	e30080e7          	jalr	-464(ra) # 80000c8a <release>
  return i;
}
    80004e62:	854e                	mv	a0,s3
    80004e64:	60a6                	ld	ra,72(sp)
    80004e66:	6406                	ld	s0,64(sp)
    80004e68:	74e2                	ld	s1,56(sp)
    80004e6a:	7942                	ld	s2,48(sp)
    80004e6c:	79a2                	ld	s3,40(sp)
    80004e6e:	7a02                	ld	s4,32(sp)
    80004e70:	6ae2                	ld	s5,24(sp)
    80004e72:	6b42                	ld	s6,16(sp)
    80004e74:	6161                	addi	sp,sp,80
    80004e76:	8082                	ret
      release(&pi->lock);
    80004e78:	8526                	mv	a0,s1
    80004e7a:	ffffc097          	auipc	ra,0xffffc
    80004e7e:	e10080e7          	jalr	-496(ra) # 80000c8a <release>
      return -1;
    80004e82:	59fd                	li	s3,-1
    80004e84:	bff9                	j	80004e62 <piperead+0xc8>

0000000080004e86 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004e86:	1141                	addi	sp,sp,-16
    80004e88:	e422                	sd	s0,8(sp)
    80004e8a:	0800                	addi	s0,sp,16
    80004e8c:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004e8e:	8905                	andi	a0,a0,1
    80004e90:	c111                	beqz	a0,80004e94 <flags2perm+0xe>
      perm = PTE_X;
    80004e92:	4521                	li	a0,8
    if(flags & 0x2)
    80004e94:	8b89                	andi	a5,a5,2
    80004e96:	c399                	beqz	a5,80004e9c <flags2perm+0x16>
      perm |= PTE_W;
    80004e98:	00456513          	ori	a0,a0,4
    return perm;
}
    80004e9c:	6422                	ld	s0,8(sp)
    80004e9e:	0141                	addi	sp,sp,16
    80004ea0:	8082                	ret

0000000080004ea2 <exec>:

int
exec(char *path, char **argv)
{
    80004ea2:	de010113          	addi	sp,sp,-544
    80004ea6:	20113c23          	sd	ra,536(sp)
    80004eaa:	20813823          	sd	s0,528(sp)
    80004eae:	20913423          	sd	s1,520(sp)
    80004eb2:	21213023          	sd	s2,512(sp)
    80004eb6:	ffce                	sd	s3,504(sp)
    80004eb8:	fbd2                	sd	s4,496(sp)
    80004eba:	f7d6                	sd	s5,488(sp)
    80004ebc:	f3da                	sd	s6,480(sp)
    80004ebe:	efde                	sd	s7,472(sp)
    80004ec0:	ebe2                	sd	s8,464(sp)
    80004ec2:	e7e6                	sd	s9,456(sp)
    80004ec4:	e3ea                	sd	s10,448(sp)
    80004ec6:	ff6e                	sd	s11,440(sp)
    80004ec8:	1400                	addi	s0,sp,544
    80004eca:	892a                	mv	s2,a0
    80004ecc:	dea43423          	sd	a0,-536(s0)
    80004ed0:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004ed4:	ffffd097          	auipc	ra,0xffffd
    80004ed8:	ad8080e7          	jalr	-1320(ra) # 800019ac <myproc>
    80004edc:	84aa                	mv	s1,a0

  begin_op();
    80004ede:	fffff097          	auipc	ra,0xfffff
    80004ee2:	47e080e7          	jalr	1150(ra) # 8000435c <begin_op>

  if((ip = namei(path)) == 0){
    80004ee6:	854a                	mv	a0,s2
    80004ee8:	fffff097          	auipc	ra,0xfffff
    80004eec:	258080e7          	jalr	600(ra) # 80004140 <namei>
    80004ef0:	c93d                	beqz	a0,80004f66 <exec+0xc4>
    80004ef2:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004ef4:	fffff097          	auipc	ra,0xfffff
    80004ef8:	aa6080e7          	jalr	-1370(ra) # 8000399a <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004efc:	04000713          	li	a4,64
    80004f00:	4681                	li	a3,0
    80004f02:	e5040613          	addi	a2,s0,-432
    80004f06:	4581                	li	a1,0
    80004f08:	8556                	mv	a0,s5
    80004f0a:	fffff097          	auipc	ra,0xfffff
    80004f0e:	d44080e7          	jalr	-700(ra) # 80003c4e <readi>
    80004f12:	04000793          	li	a5,64
    80004f16:	00f51a63          	bne	a0,a5,80004f2a <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004f1a:	e5042703          	lw	a4,-432(s0)
    80004f1e:	464c47b7          	lui	a5,0x464c4
    80004f22:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004f26:	04f70663          	beq	a4,a5,80004f72 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004f2a:	8556                	mv	a0,s5
    80004f2c:	fffff097          	auipc	ra,0xfffff
    80004f30:	cd0080e7          	jalr	-816(ra) # 80003bfc <iunlockput>
    end_op();
    80004f34:	fffff097          	auipc	ra,0xfffff
    80004f38:	4a8080e7          	jalr	1192(ra) # 800043dc <end_op>
  }
  return -1;
    80004f3c:	557d                	li	a0,-1
}
    80004f3e:	21813083          	ld	ra,536(sp)
    80004f42:	21013403          	ld	s0,528(sp)
    80004f46:	20813483          	ld	s1,520(sp)
    80004f4a:	20013903          	ld	s2,512(sp)
    80004f4e:	79fe                	ld	s3,504(sp)
    80004f50:	7a5e                	ld	s4,496(sp)
    80004f52:	7abe                	ld	s5,488(sp)
    80004f54:	7b1e                	ld	s6,480(sp)
    80004f56:	6bfe                	ld	s7,472(sp)
    80004f58:	6c5e                	ld	s8,464(sp)
    80004f5a:	6cbe                	ld	s9,456(sp)
    80004f5c:	6d1e                	ld	s10,448(sp)
    80004f5e:	7dfa                	ld	s11,440(sp)
    80004f60:	22010113          	addi	sp,sp,544
    80004f64:	8082                	ret
    end_op();
    80004f66:	fffff097          	auipc	ra,0xfffff
    80004f6a:	476080e7          	jalr	1142(ra) # 800043dc <end_op>
    return -1;
    80004f6e:	557d                	li	a0,-1
    80004f70:	b7f9                	j	80004f3e <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004f72:	8526                	mv	a0,s1
    80004f74:	ffffd097          	auipc	ra,0xffffd
    80004f78:	afc080e7          	jalr	-1284(ra) # 80001a70 <proc_pagetable>
    80004f7c:	8b2a                	mv	s6,a0
    80004f7e:	d555                	beqz	a0,80004f2a <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f80:	e7042783          	lw	a5,-400(s0)
    80004f84:	e8845703          	lhu	a4,-376(s0)
    80004f88:	c735                	beqz	a4,80004ff4 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f8a:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f8c:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004f90:	6a05                	lui	s4,0x1
    80004f92:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004f96:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004f9a:	6d85                	lui	s11,0x1
    80004f9c:	7d7d                	lui	s10,0xfffff
    80004f9e:	a481                	j	800051de <exec+0x33c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004fa0:	00004517          	auipc	a0,0x4
    80004fa4:	87850513          	addi	a0,a0,-1928 # 80008818 <syscallnum+0x228>
    80004fa8:	ffffb097          	auipc	ra,0xffffb
    80004fac:	596080e7          	jalr	1430(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004fb0:	874a                	mv	a4,s2
    80004fb2:	009c86bb          	addw	a3,s9,s1
    80004fb6:	4581                	li	a1,0
    80004fb8:	8556                	mv	a0,s5
    80004fba:	fffff097          	auipc	ra,0xfffff
    80004fbe:	c94080e7          	jalr	-876(ra) # 80003c4e <readi>
    80004fc2:	2501                	sext.w	a0,a0
    80004fc4:	1aa91a63          	bne	s2,a0,80005178 <exec+0x2d6>
  for(i = 0; i < sz; i += PGSIZE){
    80004fc8:	009d84bb          	addw	s1,s11,s1
    80004fcc:	013d09bb          	addw	s3,s10,s3
    80004fd0:	1f74f763          	bgeu	s1,s7,800051be <exec+0x31c>
    pa = walkaddr(pagetable, va + i);
    80004fd4:	02049593          	slli	a1,s1,0x20
    80004fd8:	9181                	srli	a1,a1,0x20
    80004fda:	95e2                	add	a1,a1,s8
    80004fdc:	855a                	mv	a0,s6
    80004fde:	ffffc097          	auipc	ra,0xffffc
    80004fe2:	07e080e7          	jalr	126(ra) # 8000105c <walkaddr>
    80004fe6:	862a                	mv	a2,a0
    if(pa == 0)
    80004fe8:	dd45                	beqz	a0,80004fa0 <exec+0xfe>
      n = PGSIZE;
    80004fea:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004fec:	fd49f2e3          	bgeu	s3,s4,80004fb0 <exec+0x10e>
      n = sz - i;
    80004ff0:	894e                	mv	s2,s3
    80004ff2:	bf7d                	j	80004fb0 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004ff4:	4901                	li	s2,0
  iunlockput(ip);
    80004ff6:	8556                	mv	a0,s5
    80004ff8:	fffff097          	auipc	ra,0xfffff
    80004ffc:	c04080e7          	jalr	-1020(ra) # 80003bfc <iunlockput>
  end_op();
    80005000:	fffff097          	auipc	ra,0xfffff
    80005004:	3dc080e7          	jalr	988(ra) # 800043dc <end_op>
  p = myproc();
    80005008:	ffffd097          	auipc	ra,0xffffd
    8000500c:	9a4080e7          	jalr	-1628(ra) # 800019ac <myproc>
    80005010:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005012:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005016:	6785                	lui	a5,0x1
    80005018:	17fd                	addi	a5,a5,-1
    8000501a:	993e                	add	s2,s2,a5
    8000501c:	77fd                	lui	a5,0xfffff
    8000501e:	00f977b3          	and	a5,s2,a5
    80005022:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005026:	4691                	li	a3,4
    80005028:	6609                	lui	a2,0x2
    8000502a:	963e                	add	a2,a2,a5
    8000502c:	85be                	mv	a1,a5
    8000502e:	855a                	mv	a0,s6
    80005030:	ffffc097          	auipc	ra,0xffffc
    80005034:	3e0080e7          	jalr	992(ra) # 80001410 <uvmalloc>
    80005038:	8c2a                	mv	s8,a0
  ip = 0;
    8000503a:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    8000503c:	12050e63          	beqz	a0,80005178 <exec+0x2d6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005040:	75f9                	lui	a1,0xffffe
    80005042:	95aa                	add	a1,a1,a0
    80005044:	855a                	mv	a0,s6
    80005046:	ffffc097          	auipc	ra,0xffffc
    8000504a:	5f0080e7          	jalr	1520(ra) # 80001636 <uvmclear>
  stackbase = sp - PGSIZE;
    8000504e:	7afd                	lui	s5,0xfffff
    80005050:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005052:	df043783          	ld	a5,-528(s0)
    80005056:	6388                	ld	a0,0(a5)
    80005058:	c925                	beqz	a0,800050c8 <exec+0x226>
    8000505a:	e9040993          	addi	s3,s0,-368
    8000505e:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80005062:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005064:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005066:	ffffc097          	auipc	ra,0xffffc
    8000506a:	de8080e7          	jalr	-536(ra) # 80000e4e <strlen>
    8000506e:	0015079b          	addiw	a5,a0,1
    80005072:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005076:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    8000507a:	13596663          	bltu	s2,s5,800051a6 <exec+0x304>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000507e:	df043d83          	ld	s11,-528(s0)
    80005082:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005086:	8552                	mv	a0,s4
    80005088:	ffffc097          	auipc	ra,0xffffc
    8000508c:	dc6080e7          	jalr	-570(ra) # 80000e4e <strlen>
    80005090:	0015069b          	addiw	a3,a0,1
    80005094:	8652                	mv	a2,s4
    80005096:	85ca                	mv	a1,s2
    80005098:	855a                	mv	a0,s6
    8000509a:	ffffc097          	auipc	ra,0xffffc
    8000509e:	5ce080e7          	jalr	1486(ra) # 80001668 <copyout>
    800050a2:	10054663          	bltz	a0,800051ae <exec+0x30c>
    ustack[argc] = sp;
    800050a6:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800050aa:	0485                	addi	s1,s1,1
    800050ac:	008d8793          	addi	a5,s11,8
    800050b0:	def43823          	sd	a5,-528(s0)
    800050b4:	008db503          	ld	a0,8(s11)
    800050b8:	c911                	beqz	a0,800050cc <exec+0x22a>
    if(argc >= MAXARG)
    800050ba:	09a1                	addi	s3,s3,8
    800050bc:	fb3c95e3          	bne	s9,s3,80005066 <exec+0x1c4>
  sz = sz1;
    800050c0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800050c4:	4a81                	li	s5,0
    800050c6:	a84d                	j	80005178 <exec+0x2d6>
  sp = sz;
    800050c8:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800050ca:	4481                	li	s1,0
  ustack[argc] = 0;
    800050cc:	00349793          	slli	a5,s1,0x3
    800050d0:	f9040713          	addi	a4,s0,-112
    800050d4:	97ba                	add	a5,a5,a4
    800050d6:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffdc9b0>
  sp -= (argc+1) * sizeof(uint64);
    800050da:	00148693          	addi	a3,s1,1
    800050de:	068e                	slli	a3,a3,0x3
    800050e0:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800050e4:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800050e8:	01597663          	bgeu	s2,s5,800050f4 <exec+0x252>
  sz = sz1;
    800050ec:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800050f0:	4a81                	li	s5,0
    800050f2:	a059                	j	80005178 <exec+0x2d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800050f4:	e9040613          	addi	a2,s0,-368
    800050f8:	85ca                	mv	a1,s2
    800050fa:	855a                	mv	a0,s6
    800050fc:	ffffc097          	auipc	ra,0xffffc
    80005100:	56c080e7          	jalr	1388(ra) # 80001668 <copyout>
    80005104:	0a054963          	bltz	a0,800051b6 <exec+0x314>
  p->trapframe->a1 = sp;
    80005108:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    8000510c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005110:	de843783          	ld	a5,-536(s0)
    80005114:	0007c703          	lbu	a4,0(a5)
    80005118:	cf11                	beqz	a4,80005134 <exec+0x292>
    8000511a:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000511c:	02f00693          	li	a3,47
    80005120:	a039                	j	8000512e <exec+0x28c>
      last = s+1;
    80005122:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005126:	0785                	addi	a5,a5,1
    80005128:	fff7c703          	lbu	a4,-1(a5)
    8000512c:	c701                	beqz	a4,80005134 <exec+0x292>
    if(*s == '/')
    8000512e:	fed71ce3          	bne	a4,a3,80005126 <exec+0x284>
    80005132:	bfc5                	j	80005122 <exec+0x280>
  safestrcpy(p->name, last, sizeof(p->name));
    80005134:	4641                	li	a2,16
    80005136:	de843583          	ld	a1,-536(s0)
    8000513a:	158b8513          	addi	a0,s7,344
    8000513e:	ffffc097          	auipc	ra,0xffffc
    80005142:	cde080e7          	jalr	-802(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    80005146:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    8000514a:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    8000514e:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005152:	058bb783          	ld	a5,88(s7)
    80005156:	e6843703          	ld	a4,-408(s0)
    8000515a:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000515c:	058bb783          	ld	a5,88(s7)
    80005160:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005164:	85ea                	mv	a1,s10
    80005166:	ffffd097          	auipc	ra,0xffffd
    8000516a:	9a6080e7          	jalr	-1626(ra) # 80001b0c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000516e:	0004851b          	sext.w	a0,s1
    80005172:	b3f1                	j	80004f3e <exec+0x9c>
    80005174:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005178:	df843583          	ld	a1,-520(s0)
    8000517c:	855a                	mv	a0,s6
    8000517e:	ffffd097          	auipc	ra,0xffffd
    80005182:	98e080e7          	jalr	-1650(ra) # 80001b0c <proc_freepagetable>
  if(ip){
    80005186:	da0a92e3          	bnez	s5,80004f2a <exec+0x88>
  return -1;
    8000518a:	557d                	li	a0,-1
    8000518c:	bb4d                	j	80004f3e <exec+0x9c>
    8000518e:	df243c23          	sd	s2,-520(s0)
    80005192:	b7dd                	j	80005178 <exec+0x2d6>
    80005194:	df243c23          	sd	s2,-520(s0)
    80005198:	b7c5                	j	80005178 <exec+0x2d6>
    8000519a:	df243c23          	sd	s2,-520(s0)
    8000519e:	bfe9                	j	80005178 <exec+0x2d6>
    800051a0:	df243c23          	sd	s2,-520(s0)
    800051a4:	bfd1                	j	80005178 <exec+0x2d6>
  sz = sz1;
    800051a6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800051aa:	4a81                	li	s5,0
    800051ac:	b7f1                	j	80005178 <exec+0x2d6>
  sz = sz1;
    800051ae:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800051b2:	4a81                	li	s5,0
    800051b4:	b7d1                	j	80005178 <exec+0x2d6>
  sz = sz1;
    800051b6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800051ba:	4a81                	li	s5,0
    800051bc:	bf75                	j	80005178 <exec+0x2d6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800051be:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051c2:	e0843783          	ld	a5,-504(s0)
    800051c6:	0017869b          	addiw	a3,a5,1
    800051ca:	e0d43423          	sd	a3,-504(s0)
    800051ce:	e0043783          	ld	a5,-512(s0)
    800051d2:	0387879b          	addiw	a5,a5,56
    800051d6:	e8845703          	lhu	a4,-376(s0)
    800051da:	e0e6dee3          	bge	a3,a4,80004ff6 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800051de:	2781                	sext.w	a5,a5
    800051e0:	e0f43023          	sd	a5,-512(s0)
    800051e4:	03800713          	li	a4,56
    800051e8:	86be                	mv	a3,a5
    800051ea:	e1840613          	addi	a2,s0,-488
    800051ee:	4581                	li	a1,0
    800051f0:	8556                	mv	a0,s5
    800051f2:	fffff097          	auipc	ra,0xfffff
    800051f6:	a5c080e7          	jalr	-1444(ra) # 80003c4e <readi>
    800051fa:	03800793          	li	a5,56
    800051fe:	f6f51be3          	bne	a0,a5,80005174 <exec+0x2d2>
    if(ph.type != ELF_PROG_LOAD)
    80005202:	e1842783          	lw	a5,-488(s0)
    80005206:	4705                	li	a4,1
    80005208:	fae79de3          	bne	a5,a4,800051c2 <exec+0x320>
    if(ph.memsz < ph.filesz)
    8000520c:	e4043483          	ld	s1,-448(s0)
    80005210:	e3843783          	ld	a5,-456(s0)
    80005214:	f6f4ede3          	bltu	s1,a5,8000518e <exec+0x2ec>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005218:	e2843783          	ld	a5,-472(s0)
    8000521c:	94be                	add	s1,s1,a5
    8000521e:	f6f4ebe3          	bltu	s1,a5,80005194 <exec+0x2f2>
    if(ph.vaddr % PGSIZE != 0)
    80005222:	de043703          	ld	a4,-544(s0)
    80005226:	8ff9                	and	a5,a5,a4
    80005228:	fbad                	bnez	a5,8000519a <exec+0x2f8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000522a:	e1c42503          	lw	a0,-484(s0)
    8000522e:	00000097          	auipc	ra,0x0
    80005232:	c58080e7          	jalr	-936(ra) # 80004e86 <flags2perm>
    80005236:	86aa                	mv	a3,a0
    80005238:	8626                	mv	a2,s1
    8000523a:	85ca                	mv	a1,s2
    8000523c:	855a                	mv	a0,s6
    8000523e:	ffffc097          	auipc	ra,0xffffc
    80005242:	1d2080e7          	jalr	466(ra) # 80001410 <uvmalloc>
    80005246:	dea43c23          	sd	a0,-520(s0)
    8000524a:	d939                	beqz	a0,800051a0 <exec+0x2fe>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000524c:	e2843c03          	ld	s8,-472(s0)
    80005250:	e2042c83          	lw	s9,-480(s0)
    80005254:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005258:	f60b83e3          	beqz	s7,800051be <exec+0x31c>
    8000525c:	89de                	mv	s3,s7
    8000525e:	4481                	li	s1,0
    80005260:	bb95                	j	80004fd4 <exec+0x132>

0000000080005262 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005262:	7179                	addi	sp,sp,-48
    80005264:	f406                	sd	ra,40(sp)
    80005266:	f022                	sd	s0,32(sp)
    80005268:	ec26                	sd	s1,24(sp)
    8000526a:	e84a                	sd	s2,16(sp)
    8000526c:	1800                	addi	s0,sp,48
    8000526e:	892e                	mv	s2,a1
    80005270:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005272:	fdc40593          	addi	a1,s0,-36
    80005276:	ffffe097          	auipc	ra,0xffffe
    8000527a:	a4c080e7          	jalr	-1460(ra) # 80002cc2 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000527e:	fdc42703          	lw	a4,-36(s0)
    80005282:	47bd                	li	a5,15
    80005284:	02e7eb63          	bltu	a5,a4,800052ba <argfd+0x58>
    80005288:	ffffc097          	auipc	ra,0xffffc
    8000528c:	724080e7          	jalr	1828(ra) # 800019ac <myproc>
    80005290:	fdc42703          	lw	a4,-36(s0)
    80005294:	01a70793          	addi	a5,a4,26
    80005298:	078e                	slli	a5,a5,0x3
    8000529a:	953e                	add	a0,a0,a5
    8000529c:	611c                	ld	a5,0(a0)
    8000529e:	c385                	beqz	a5,800052be <argfd+0x5c>
    return -1;
  if(pfd)
    800052a0:	00090463          	beqz	s2,800052a8 <argfd+0x46>
    *pfd = fd;
    800052a4:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800052a8:	4501                	li	a0,0
  if(pf)
    800052aa:	c091                	beqz	s1,800052ae <argfd+0x4c>
    *pf = f;
    800052ac:	e09c                	sd	a5,0(s1)
}
    800052ae:	70a2                	ld	ra,40(sp)
    800052b0:	7402                	ld	s0,32(sp)
    800052b2:	64e2                	ld	s1,24(sp)
    800052b4:	6942                	ld	s2,16(sp)
    800052b6:	6145                	addi	sp,sp,48
    800052b8:	8082                	ret
    return -1;
    800052ba:	557d                	li	a0,-1
    800052bc:	bfcd                	j	800052ae <argfd+0x4c>
    800052be:	557d                	li	a0,-1
    800052c0:	b7fd                	j	800052ae <argfd+0x4c>

00000000800052c2 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800052c2:	1101                	addi	sp,sp,-32
    800052c4:	ec06                	sd	ra,24(sp)
    800052c6:	e822                	sd	s0,16(sp)
    800052c8:	e426                	sd	s1,8(sp)
    800052ca:	1000                	addi	s0,sp,32
    800052cc:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800052ce:	ffffc097          	auipc	ra,0xffffc
    800052d2:	6de080e7          	jalr	1758(ra) # 800019ac <myproc>
    800052d6:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800052d8:	0d050793          	addi	a5,a0,208
    800052dc:	4501                	li	a0,0
    800052de:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800052e0:	6398                	ld	a4,0(a5)
    800052e2:	cb19                	beqz	a4,800052f8 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800052e4:	2505                	addiw	a0,a0,1
    800052e6:	07a1                	addi	a5,a5,8
    800052e8:	fed51ce3          	bne	a0,a3,800052e0 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800052ec:	557d                	li	a0,-1
}
    800052ee:	60e2                	ld	ra,24(sp)
    800052f0:	6442                	ld	s0,16(sp)
    800052f2:	64a2                	ld	s1,8(sp)
    800052f4:	6105                	addi	sp,sp,32
    800052f6:	8082                	ret
      p->ofile[fd] = f;
    800052f8:	01a50793          	addi	a5,a0,26
    800052fc:	078e                	slli	a5,a5,0x3
    800052fe:	963e                	add	a2,a2,a5
    80005300:	e204                	sd	s1,0(a2)
      return fd;
    80005302:	b7f5                	j	800052ee <fdalloc+0x2c>

0000000080005304 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005304:	715d                	addi	sp,sp,-80
    80005306:	e486                	sd	ra,72(sp)
    80005308:	e0a2                	sd	s0,64(sp)
    8000530a:	fc26                	sd	s1,56(sp)
    8000530c:	f84a                	sd	s2,48(sp)
    8000530e:	f44e                	sd	s3,40(sp)
    80005310:	f052                	sd	s4,32(sp)
    80005312:	ec56                	sd	s5,24(sp)
    80005314:	e85a                	sd	s6,16(sp)
    80005316:	0880                	addi	s0,sp,80
    80005318:	8b2e                	mv	s6,a1
    8000531a:	89b2                	mv	s3,a2
    8000531c:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000531e:	fb040593          	addi	a1,s0,-80
    80005322:	fffff097          	auipc	ra,0xfffff
    80005326:	e3c080e7          	jalr	-452(ra) # 8000415e <nameiparent>
    8000532a:	84aa                	mv	s1,a0
    8000532c:	14050f63          	beqz	a0,8000548a <create+0x186>
    return 0;

  ilock(dp);
    80005330:	ffffe097          	auipc	ra,0xffffe
    80005334:	66a080e7          	jalr	1642(ra) # 8000399a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005338:	4601                	li	a2,0
    8000533a:	fb040593          	addi	a1,s0,-80
    8000533e:	8526                	mv	a0,s1
    80005340:	fffff097          	auipc	ra,0xfffff
    80005344:	b3e080e7          	jalr	-1218(ra) # 80003e7e <dirlookup>
    80005348:	8aaa                	mv	s5,a0
    8000534a:	c931                	beqz	a0,8000539e <create+0x9a>
    iunlockput(dp);
    8000534c:	8526                	mv	a0,s1
    8000534e:	fffff097          	auipc	ra,0xfffff
    80005352:	8ae080e7          	jalr	-1874(ra) # 80003bfc <iunlockput>
    ilock(ip);
    80005356:	8556                	mv	a0,s5
    80005358:	ffffe097          	auipc	ra,0xffffe
    8000535c:	642080e7          	jalr	1602(ra) # 8000399a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005360:	000b059b          	sext.w	a1,s6
    80005364:	4789                	li	a5,2
    80005366:	02f59563          	bne	a1,a5,80005390 <create+0x8c>
    8000536a:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdcaf4>
    8000536e:	37f9                	addiw	a5,a5,-2
    80005370:	17c2                	slli	a5,a5,0x30
    80005372:	93c1                	srli	a5,a5,0x30
    80005374:	4705                	li	a4,1
    80005376:	00f76d63          	bltu	a4,a5,80005390 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000537a:	8556                	mv	a0,s5
    8000537c:	60a6                	ld	ra,72(sp)
    8000537e:	6406                	ld	s0,64(sp)
    80005380:	74e2                	ld	s1,56(sp)
    80005382:	7942                	ld	s2,48(sp)
    80005384:	79a2                	ld	s3,40(sp)
    80005386:	7a02                	ld	s4,32(sp)
    80005388:	6ae2                	ld	s5,24(sp)
    8000538a:	6b42                	ld	s6,16(sp)
    8000538c:	6161                	addi	sp,sp,80
    8000538e:	8082                	ret
    iunlockput(ip);
    80005390:	8556                	mv	a0,s5
    80005392:	fffff097          	auipc	ra,0xfffff
    80005396:	86a080e7          	jalr	-1942(ra) # 80003bfc <iunlockput>
    return 0;
    8000539a:	4a81                	li	s5,0
    8000539c:	bff9                	j	8000537a <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000539e:	85da                	mv	a1,s6
    800053a0:	4088                	lw	a0,0(s1)
    800053a2:	ffffe097          	auipc	ra,0xffffe
    800053a6:	45c080e7          	jalr	1116(ra) # 800037fe <ialloc>
    800053aa:	8a2a                	mv	s4,a0
    800053ac:	c539                	beqz	a0,800053fa <create+0xf6>
  ilock(ip);
    800053ae:	ffffe097          	auipc	ra,0xffffe
    800053b2:	5ec080e7          	jalr	1516(ra) # 8000399a <ilock>
  ip->major = major;
    800053b6:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800053ba:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800053be:	4905                	li	s2,1
    800053c0:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800053c4:	8552                	mv	a0,s4
    800053c6:	ffffe097          	auipc	ra,0xffffe
    800053ca:	50a080e7          	jalr	1290(ra) # 800038d0 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800053ce:	000b059b          	sext.w	a1,s6
    800053d2:	03258b63          	beq	a1,s2,80005408 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    800053d6:	004a2603          	lw	a2,4(s4)
    800053da:	fb040593          	addi	a1,s0,-80
    800053de:	8526                	mv	a0,s1
    800053e0:	fffff097          	auipc	ra,0xfffff
    800053e4:	cae080e7          	jalr	-850(ra) # 8000408e <dirlink>
    800053e8:	06054f63          	bltz	a0,80005466 <create+0x162>
  iunlockput(dp);
    800053ec:	8526                	mv	a0,s1
    800053ee:	fffff097          	auipc	ra,0xfffff
    800053f2:	80e080e7          	jalr	-2034(ra) # 80003bfc <iunlockput>
  return ip;
    800053f6:	8ad2                	mv	s5,s4
    800053f8:	b749                	j	8000537a <create+0x76>
    iunlockput(dp);
    800053fa:	8526                	mv	a0,s1
    800053fc:	fffff097          	auipc	ra,0xfffff
    80005400:	800080e7          	jalr	-2048(ra) # 80003bfc <iunlockput>
    return 0;
    80005404:	8ad2                	mv	s5,s4
    80005406:	bf95                	j	8000537a <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005408:	004a2603          	lw	a2,4(s4)
    8000540c:	00003597          	auipc	a1,0x3
    80005410:	42c58593          	addi	a1,a1,1068 # 80008838 <syscallnum+0x248>
    80005414:	8552                	mv	a0,s4
    80005416:	fffff097          	auipc	ra,0xfffff
    8000541a:	c78080e7          	jalr	-904(ra) # 8000408e <dirlink>
    8000541e:	04054463          	bltz	a0,80005466 <create+0x162>
    80005422:	40d0                	lw	a2,4(s1)
    80005424:	00003597          	auipc	a1,0x3
    80005428:	41c58593          	addi	a1,a1,1052 # 80008840 <syscallnum+0x250>
    8000542c:	8552                	mv	a0,s4
    8000542e:	fffff097          	auipc	ra,0xfffff
    80005432:	c60080e7          	jalr	-928(ra) # 8000408e <dirlink>
    80005436:	02054863          	bltz	a0,80005466 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    8000543a:	004a2603          	lw	a2,4(s4)
    8000543e:	fb040593          	addi	a1,s0,-80
    80005442:	8526                	mv	a0,s1
    80005444:	fffff097          	auipc	ra,0xfffff
    80005448:	c4a080e7          	jalr	-950(ra) # 8000408e <dirlink>
    8000544c:	00054d63          	bltz	a0,80005466 <create+0x162>
    dp->nlink++;  // for ".."
    80005450:	04a4d783          	lhu	a5,74(s1)
    80005454:	2785                	addiw	a5,a5,1
    80005456:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000545a:	8526                	mv	a0,s1
    8000545c:	ffffe097          	auipc	ra,0xffffe
    80005460:	474080e7          	jalr	1140(ra) # 800038d0 <iupdate>
    80005464:	b761                	j	800053ec <create+0xe8>
  ip->nlink = 0;
    80005466:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000546a:	8552                	mv	a0,s4
    8000546c:	ffffe097          	auipc	ra,0xffffe
    80005470:	464080e7          	jalr	1124(ra) # 800038d0 <iupdate>
  iunlockput(ip);
    80005474:	8552                	mv	a0,s4
    80005476:	ffffe097          	auipc	ra,0xffffe
    8000547a:	786080e7          	jalr	1926(ra) # 80003bfc <iunlockput>
  iunlockput(dp);
    8000547e:	8526                	mv	a0,s1
    80005480:	ffffe097          	auipc	ra,0xffffe
    80005484:	77c080e7          	jalr	1916(ra) # 80003bfc <iunlockput>
  return 0;
    80005488:	bdcd                	j	8000537a <create+0x76>
    return 0;
    8000548a:	8aaa                	mv	s5,a0
    8000548c:	b5fd                	j	8000537a <create+0x76>

000000008000548e <sys_dup>:
{
    8000548e:	7179                	addi	sp,sp,-48
    80005490:	f406                	sd	ra,40(sp)
    80005492:	f022                	sd	s0,32(sp)
    80005494:	ec26                	sd	s1,24(sp)
    80005496:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005498:	fd840613          	addi	a2,s0,-40
    8000549c:	4581                	li	a1,0
    8000549e:	4501                	li	a0,0
    800054a0:	00000097          	auipc	ra,0x0
    800054a4:	dc2080e7          	jalr	-574(ra) # 80005262 <argfd>
    return -1;
    800054a8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800054aa:	02054363          	bltz	a0,800054d0 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800054ae:	fd843503          	ld	a0,-40(s0)
    800054b2:	00000097          	auipc	ra,0x0
    800054b6:	e10080e7          	jalr	-496(ra) # 800052c2 <fdalloc>
    800054ba:	84aa                	mv	s1,a0
    return -1;
    800054bc:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800054be:	00054963          	bltz	a0,800054d0 <sys_dup+0x42>
  filedup(f);
    800054c2:	fd843503          	ld	a0,-40(s0)
    800054c6:	fffff097          	auipc	ra,0xfffff
    800054ca:	310080e7          	jalr	784(ra) # 800047d6 <filedup>
  return fd;
    800054ce:	87a6                	mv	a5,s1
}
    800054d0:	853e                	mv	a0,a5
    800054d2:	70a2                	ld	ra,40(sp)
    800054d4:	7402                	ld	s0,32(sp)
    800054d6:	64e2                	ld	s1,24(sp)
    800054d8:	6145                	addi	sp,sp,48
    800054da:	8082                	ret

00000000800054dc <sys_read>:
{
    800054dc:	7179                	addi	sp,sp,-48
    800054de:	f406                	sd	ra,40(sp)
    800054e0:	f022                	sd	s0,32(sp)
    800054e2:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800054e4:	fd840593          	addi	a1,s0,-40
    800054e8:	4505                	li	a0,1
    800054ea:	ffffd097          	auipc	ra,0xffffd
    800054ee:	7fa080e7          	jalr	2042(ra) # 80002ce4 <argaddr>
  argint(2, &n);
    800054f2:	fe440593          	addi	a1,s0,-28
    800054f6:	4509                	li	a0,2
    800054f8:	ffffd097          	auipc	ra,0xffffd
    800054fc:	7ca080e7          	jalr	1994(ra) # 80002cc2 <argint>
  if(argfd(0, 0, &f) < 0)
    80005500:	fe840613          	addi	a2,s0,-24
    80005504:	4581                	li	a1,0
    80005506:	4501                	li	a0,0
    80005508:	00000097          	auipc	ra,0x0
    8000550c:	d5a080e7          	jalr	-678(ra) # 80005262 <argfd>
    80005510:	87aa                	mv	a5,a0
    return -1;
    80005512:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005514:	0007cc63          	bltz	a5,8000552c <sys_read+0x50>
  return fileread(f, p, n);
    80005518:	fe442603          	lw	a2,-28(s0)
    8000551c:	fd843583          	ld	a1,-40(s0)
    80005520:	fe843503          	ld	a0,-24(s0)
    80005524:	fffff097          	auipc	ra,0xfffff
    80005528:	43e080e7          	jalr	1086(ra) # 80004962 <fileread>
}
    8000552c:	70a2                	ld	ra,40(sp)
    8000552e:	7402                	ld	s0,32(sp)
    80005530:	6145                	addi	sp,sp,48
    80005532:	8082                	ret

0000000080005534 <sys_write>:
{
    80005534:	7179                	addi	sp,sp,-48
    80005536:	f406                	sd	ra,40(sp)
    80005538:	f022                	sd	s0,32(sp)
    8000553a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000553c:	fd840593          	addi	a1,s0,-40
    80005540:	4505                	li	a0,1
    80005542:	ffffd097          	auipc	ra,0xffffd
    80005546:	7a2080e7          	jalr	1954(ra) # 80002ce4 <argaddr>
  argint(2, &n);
    8000554a:	fe440593          	addi	a1,s0,-28
    8000554e:	4509                	li	a0,2
    80005550:	ffffd097          	auipc	ra,0xffffd
    80005554:	772080e7          	jalr	1906(ra) # 80002cc2 <argint>
  if(argfd(0, 0, &f) < 0)
    80005558:	fe840613          	addi	a2,s0,-24
    8000555c:	4581                	li	a1,0
    8000555e:	4501                	li	a0,0
    80005560:	00000097          	auipc	ra,0x0
    80005564:	d02080e7          	jalr	-766(ra) # 80005262 <argfd>
    80005568:	87aa                	mv	a5,a0
    return -1;
    8000556a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000556c:	0007cc63          	bltz	a5,80005584 <sys_write+0x50>
  return filewrite(f, p, n);
    80005570:	fe442603          	lw	a2,-28(s0)
    80005574:	fd843583          	ld	a1,-40(s0)
    80005578:	fe843503          	ld	a0,-24(s0)
    8000557c:	fffff097          	auipc	ra,0xfffff
    80005580:	4a8080e7          	jalr	1192(ra) # 80004a24 <filewrite>
}
    80005584:	70a2                	ld	ra,40(sp)
    80005586:	7402                	ld	s0,32(sp)
    80005588:	6145                	addi	sp,sp,48
    8000558a:	8082                	ret

000000008000558c <sys_close>:
{
    8000558c:	1101                	addi	sp,sp,-32
    8000558e:	ec06                	sd	ra,24(sp)
    80005590:	e822                	sd	s0,16(sp)
    80005592:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005594:	fe040613          	addi	a2,s0,-32
    80005598:	fec40593          	addi	a1,s0,-20
    8000559c:	4501                	li	a0,0
    8000559e:	00000097          	auipc	ra,0x0
    800055a2:	cc4080e7          	jalr	-828(ra) # 80005262 <argfd>
    return -1;
    800055a6:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800055a8:	02054463          	bltz	a0,800055d0 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800055ac:	ffffc097          	auipc	ra,0xffffc
    800055b0:	400080e7          	jalr	1024(ra) # 800019ac <myproc>
    800055b4:	fec42783          	lw	a5,-20(s0)
    800055b8:	07e9                	addi	a5,a5,26
    800055ba:	078e                	slli	a5,a5,0x3
    800055bc:	97aa                	add	a5,a5,a0
    800055be:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800055c2:	fe043503          	ld	a0,-32(s0)
    800055c6:	fffff097          	auipc	ra,0xfffff
    800055ca:	262080e7          	jalr	610(ra) # 80004828 <fileclose>
  return 0;
    800055ce:	4781                	li	a5,0
}
    800055d0:	853e                	mv	a0,a5
    800055d2:	60e2                	ld	ra,24(sp)
    800055d4:	6442                	ld	s0,16(sp)
    800055d6:	6105                	addi	sp,sp,32
    800055d8:	8082                	ret

00000000800055da <sys_fstat>:
{
    800055da:	1101                	addi	sp,sp,-32
    800055dc:	ec06                	sd	ra,24(sp)
    800055de:	e822                	sd	s0,16(sp)
    800055e0:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800055e2:	fe040593          	addi	a1,s0,-32
    800055e6:	4505                	li	a0,1
    800055e8:	ffffd097          	auipc	ra,0xffffd
    800055ec:	6fc080e7          	jalr	1788(ra) # 80002ce4 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800055f0:	fe840613          	addi	a2,s0,-24
    800055f4:	4581                	li	a1,0
    800055f6:	4501                	li	a0,0
    800055f8:	00000097          	auipc	ra,0x0
    800055fc:	c6a080e7          	jalr	-918(ra) # 80005262 <argfd>
    80005600:	87aa                	mv	a5,a0
    return -1;
    80005602:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005604:	0007ca63          	bltz	a5,80005618 <sys_fstat+0x3e>
  return filestat(f, st);
    80005608:	fe043583          	ld	a1,-32(s0)
    8000560c:	fe843503          	ld	a0,-24(s0)
    80005610:	fffff097          	auipc	ra,0xfffff
    80005614:	2e0080e7          	jalr	736(ra) # 800048f0 <filestat>
}
    80005618:	60e2                	ld	ra,24(sp)
    8000561a:	6442                	ld	s0,16(sp)
    8000561c:	6105                	addi	sp,sp,32
    8000561e:	8082                	ret

0000000080005620 <sys_link>:
{
    80005620:	7169                	addi	sp,sp,-304
    80005622:	f606                	sd	ra,296(sp)
    80005624:	f222                	sd	s0,288(sp)
    80005626:	ee26                	sd	s1,280(sp)
    80005628:	ea4a                	sd	s2,272(sp)
    8000562a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000562c:	08000613          	li	a2,128
    80005630:	ed040593          	addi	a1,s0,-304
    80005634:	4501                	li	a0,0
    80005636:	ffffd097          	auipc	ra,0xffffd
    8000563a:	6ce080e7          	jalr	1742(ra) # 80002d04 <argstr>
    return -1;
    8000563e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005640:	10054e63          	bltz	a0,8000575c <sys_link+0x13c>
    80005644:	08000613          	li	a2,128
    80005648:	f5040593          	addi	a1,s0,-176
    8000564c:	4505                	li	a0,1
    8000564e:	ffffd097          	auipc	ra,0xffffd
    80005652:	6b6080e7          	jalr	1718(ra) # 80002d04 <argstr>
    return -1;
    80005656:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005658:	10054263          	bltz	a0,8000575c <sys_link+0x13c>
  begin_op();
    8000565c:	fffff097          	auipc	ra,0xfffff
    80005660:	d00080e7          	jalr	-768(ra) # 8000435c <begin_op>
  if((ip = namei(old)) == 0){
    80005664:	ed040513          	addi	a0,s0,-304
    80005668:	fffff097          	auipc	ra,0xfffff
    8000566c:	ad8080e7          	jalr	-1320(ra) # 80004140 <namei>
    80005670:	84aa                	mv	s1,a0
    80005672:	c551                	beqz	a0,800056fe <sys_link+0xde>
  ilock(ip);
    80005674:	ffffe097          	auipc	ra,0xffffe
    80005678:	326080e7          	jalr	806(ra) # 8000399a <ilock>
  if(ip->type == T_DIR){
    8000567c:	04449703          	lh	a4,68(s1)
    80005680:	4785                	li	a5,1
    80005682:	08f70463          	beq	a4,a5,8000570a <sys_link+0xea>
  ip->nlink++;
    80005686:	04a4d783          	lhu	a5,74(s1)
    8000568a:	2785                	addiw	a5,a5,1
    8000568c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005690:	8526                	mv	a0,s1
    80005692:	ffffe097          	auipc	ra,0xffffe
    80005696:	23e080e7          	jalr	574(ra) # 800038d0 <iupdate>
  iunlock(ip);
    8000569a:	8526                	mv	a0,s1
    8000569c:	ffffe097          	auipc	ra,0xffffe
    800056a0:	3c0080e7          	jalr	960(ra) # 80003a5c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800056a4:	fd040593          	addi	a1,s0,-48
    800056a8:	f5040513          	addi	a0,s0,-176
    800056ac:	fffff097          	auipc	ra,0xfffff
    800056b0:	ab2080e7          	jalr	-1358(ra) # 8000415e <nameiparent>
    800056b4:	892a                	mv	s2,a0
    800056b6:	c935                	beqz	a0,8000572a <sys_link+0x10a>
  ilock(dp);
    800056b8:	ffffe097          	auipc	ra,0xffffe
    800056bc:	2e2080e7          	jalr	738(ra) # 8000399a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800056c0:	00092703          	lw	a4,0(s2)
    800056c4:	409c                	lw	a5,0(s1)
    800056c6:	04f71d63          	bne	a4,a5,80005720 <sys_link+0x100>
    800056ca:	40d0                	lw	a2,4(s1)
    800056cc:	fd040593          	addi	a1,s0,-48
    800056d0:	854a                	mv	a0,s2
    800056d2:	fffff097          	auipc	ra,0xfffff
    800056d6:	9bc080e7          	jalr	-1604(ra) # 8000408e <dirlink>
    800056da:	04054363          	bltz	a0,80005720 <sys_link+0x100>
  iunlockput(dp);
    800056de:	854a                	mv	a0,s2
    800056e0:	ffffe097          	auipc	ra,0xffffe
    800056e4:	51c080e7          	jalr	1308(ra) # 80003bfc <iunlockput>
  iput(ip);
    800056e8:	8526                	mv	a0,s1
    800056ea:	ffffe097          	auipc	ra,0xffffe
    800056ee:	46a080e7          	jalr	1130(ra) # 80003b54 <iput>
  end_op();
    800056f2:	fffff097          	auipc	ra,0xfffff
    800056f6:	cea080e7          	jalr	-790(ra) # 800043dc <end_op>
  return 0;
    800056fa:	4781                	li	a5,0
    800056fc:	a085                	j	8000575c <sys_link+0x13c>
    end_op();
    800056fe:	fffff097          	auipc	ra,0xfffff
    80005702:	cde080e7          	jalr	-802(ra) # 800043dc <end_op>
    return -1;
    80005706:	57fd                	li	a5,-1
    80005708:	a891                	j	8000575c <sys_link+0x13c>
    iunlockput(ip);
    8000570a:	8526                	mv	a0,s1
    8000570c:	ffffe097          	auipc	ra,0xffffe
    80005710:	4f0080e7          	jalr	1264(ra) # 80003bfc <iunlockput>
    end_op();
    80005714:	fffff097          	auipc	ra,0xfffff
    80005718:	cc8080e7          	jalr	-824(ra) # 800043dc <end_op>
    return -1;
    8000571c:	57fd                	li	a5,-1
    8000571e:	a83d                	j	8000575c <sys_link+0x13c>
    iunlockput(dp);
    80005720:	854a                	mv	a0,s2
    80005722:	ffffe097          	auipc	ra,0xffffe
    80005726:	4da080e7          	jalr	1242(ra) # 80003bfc <iunlockput>
  ilock(ip);
    8000572a:	8526                	mv	a0,s1
    8000572c:	ffffe097          	auipc	ra,0xffffe
    80005730:	26e080e7          	jalr	622(ra) # 8000399a <ilock>
  ip->nlink--;
    80005734:	04a4d783          	lhu	a5,74(s1)
    80005738:	37fd                	addiw	a5,a5,-1
    8000573a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000573e:	8526                	mv	a0,s1
    80005740:	ffffe097          	auipc	ra,0xffffe
    80005744:	190080e7          	jalr	400(ra) # 800038d0 <iupdate>
  iunlockput(ip);
    80005748:	8526                	mv	a0,s1
    8000574a:	ffffe097          	auipc	ra,0xffffe
    8000574e:	4b2080e7          	jalr	1202(ra) # 80003bfc <iunlockput>
  end_op();
    80005752:	fffff097          	auipc	ra,0xfffff
    80005756:	c8a080e7          	jalr	-886(ra) # 800043dc <end_op>
  return -1;
    8000575a:	57fd                	li	a5,-1
}
    8000575c:	853e                	mv	a0,a5
    8000575e:	70b2                	ld	ra,296(sp)
    80005760:	7412                	ld	s0,288(sp)
    80005762:	64f2                	ld	s1,280(sp)
    80005764:	6952                	ld	s2,272(sp)
    80005766:	6155                	addi	sp,sp,304
    80005768:	8082                	ret

000000008000576a <sys_unlink>:
{
    8000576a:	7151                	addi	sp,sp,-240
    8000576c:	f586                	sd	ra,232(sp)
    8000576e:	f1a2                	sd	s0,224(sp)
    80005770:	eda6                	sd	s1,216(sp)
    80005772:	e9ca                	sd	s2,208(sp)
    80005774:	e5ce                	sd	s3,200(sp)
    80005776:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005778:	08000613          	li	a2,128
    8000577c:	f3040593          	addi	a1,s0,-208
    80005780:	4501                	li	a0,0
    80005782:	ffffd097          	auipc	ra,0xffffd
    80005786:	582080e7          	jalr	1410(ra) # 80002d04 <argstr>
    8000578a:	18054163          	bltz	a0,8000590c <sys_unlink+0x1a2>
  begin_op();
    8000578e:	fffff097          	auipc	ra,0xfffff
    80005792:	bce080e7          	jalr	-1074(ra) # 8000435c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005796:	fb040593          	addi	a1,s0,-80
    8000579a:	f3040513          	addi	a0,s0,-208
    8000579e:	fffff097          	auipc	ra,0xfffff
    800057a2:	9c0080e7          	jalr	-1600(ra) # 8000415e <nameiparent>
    800057a6:	84aa                	mv	s1,a0
    800057a8:	c979                	beqz	a0,8000587e <sys_unlink+0x114>
  ilock(dp);
    800057aa:	ffffe097          	auipc	ra,0xffffe
    800057ae:	1f0080e7          	jalr	496(ra) # 8000399a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800057b2:	00003597          	auipc	a1,0x3
    800057b6:	08658593          	addi	a1,a1,134 # 80008838 <syscallnum+0x248>
    800057ba:	fb040513          	addi	a0,s0,-80
    800057be:	ffffe097          	auipc	ra,0xffffe
    800057c2:	6a6080e7          	jalr	1702(ra) # 80003e64 <namecmp>
    800057c6:	14050a63          	beqz	a0,8000591a <sys_unlink+0x1b0>
    800057ca:	00003597          	auipc	a1,0x3
    800057ce:	07658593          	addi	a1,a1,118 # 80008840 <syscallnum+0x250>
    800057d2:	fb040513          	addi	a0,s0,-80
    800057d6:	ffffe097          	auipc	ra,0xffffe
    800057da:	68e080e7          	jalr	1678(ra) # 80003e64 <namecmp>
    800057de:	12050e63          	beqz	a0,8000591a <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800057e2:	f2c40613          	addi	a2,s0,-212
    800057e6:	fb040593          	addi	a1,s0,-80
    800057ea:	8526                	mv	a0,s1
    800057ec:	ffffe097          	auipc	ra,0xffffe
    800057f0:	692080e7          	jalr	1682(ra) # 80003e7e <dirlookup>
    800057f4:	892a                	mv	s2,a0
    800057f6:	12050263          	beqz	a0,8000591a <sys_unlink+0x1b0>
  ilock(ip);
    800057fa:	ffffe097          	auipc	ra,0xffffe
    800057fe:	1a0080e7          	jalr	416(ra) # 8000399a <ilock>
  if(ip->nlink < 1)
    80005802:	04a91783          	lh	a5,74(s2)
    80005806:	08f05263          	blez	a5,8000588a <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000580a:	04491703          	lh	a4,68(s2)
    8000580e:	4785                	li	a5,1
    80005810:	08f70563          	beq	a4,a5,8000589a <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005814:	4641                	li	a2,16
    80005816:	4581                	li	a1,0
    80005818:	fc040513          	addi	a0,s0,-64
    8000581c:	ffffb097          	auipc	ra,0xffffb
    80005820:	4b6080e7          	jalr	1206(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005824:	4741                	li	a4,16
    80005826:	f2c42683          	lw	a3,-212(s0)
    8000582a:	fc040613          	addi	a2,s0,-64
    8000582e:	4581                	li	a1,0
    80005830:	8526                	mv	a0,s1
    80005832:	ffffe097          	auipc	ra,0xffffe
    80005836:	514080e7          	jalr	1300(ra) # 80003d46 <writei>
    8000583a:	47c1                	li	a5,16
    8000583c:	0af51563          	bne	a0,a5,800058e6 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005840:	04491703          	lh	a4,68(s2)
    80005844:	4785                	li	a5,1
    80005846:	0af70863          	beq	a4,a5,800058f6 <sys_unlink+0x18c>
  iunlockput(dp);
    8000584a:	8526                	mv	a0,s1
    8000584c:	ffffe097          	auipc	ra,0xffffe
    80005850:	3b0080e7          	jalr	944(ra) # 80003bfc <iunlockput>
  ip->nlink--;
    80005854:	04a95783          	lhu	a5,74(s2)
    80005858:	37fd                	addiw	a5,a5,-1
    8000585a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000585e:	854a                	mv	a0,s2
    80005860:	ffffe097          	auipc	ra,0xffffe
    80005864:	070080e7          	jalr	112(ra) # 800038d0 <iupdate>
  iunlockput(ip);
    80005868:	854a                	mv	a0,s2
    8000586a:	ffffe097          	auipc	ra,0xffffe
    8000586e:	392080e7          	jalr	914(ra) # 80003bfc <iunlockput>
  end_op();
    80005872:	fffff097          	auipc	ra,0xfffff
    80005876:	b6a080e7          	jalr	-1174(ra) # 800043dc <end_op>
  return 0;
    8000587a:	4501                	li	a0,0
    8000587c:	a84d                	j	8000592e <sys_unlink+0x1c4>
    end_op();
    8000587e:	fffff097          	auipc	ra,0xfffff
    80005882:	b5e080e7          	jalr	-1186(ra) # 800043dc <end_op>
    return -1;
    80005886:	557d                	li	a0,-1
    80005888:	a05d                	j	8000592e <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000588a:	00003517          	auipc	a0,0x3
    8000588e:	fbe50513          	addi	a0,a0,-66 # 80008848 <syscallnum+0x258>
    80005892:	ffffb097          	auipc	ra,0xffffb
    80005896:	cac080e7          	jalr	-852(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000589a:	04c92703          	lw	a4,76(s2)
    8000589e:	02000793          	li	a5,32
    800058a2:	f6e7f9e3          	bgeu	a5,a4,80005814 <sys_unlink+0xaa>
    800058a6:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800058aa:	4741                	li	a4,16
    800058ac:	86ce                	mv	a3,s3
    800058ae:	f1840613          	addi	a2,s0,-232
    800058b2:	4581                	li	a1,0
    800058b4:	854a                	mv	a0,s2
    800058b6:	ffffe097          	auipc	ra,0xffffe
    800058ba:	398080e7          	jalr	920(ra) # 80003c4e <readi>
    800058be:	47c1                	li	a5,16
    800058c0:	00f51b63          	bne	a0,a5,800058d6 <sys_unlink+0x16c>
    if(de.inum != 0)
    800058c4:	f1845783          	lhu	a5,-232(s0)
    800058c8:	e7a1                	bnez	a5,80005910 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800058ca:	29c1                	addiw	s3,s3,16
    800058cc:	04c92783          	lw	a5,76(s2)
    800058d0:	fcf9ede3          	bltu	s3,a5,800058aa <sys_unlink+0x140>
    800058d4:	b781                	j	80005814 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800058d6:	00003517          	auipc	a0,0x3
    800058da:	f8a50513          	addi	a0,a0,-118 # 80008860 <syscallnum+0x270>
    800058de:	ffffb097          	auipc	ra,0xffffb
    800058e2:	c60080e7          	jalr	-928(ra) # 8000053e <panic>
    panic("unlink: writei");
    800058e6:	00003517          	auipc	a0,0x3
    800058ea:	f9250513          	addi	a0,a0,-110 # 80008878 <syscallnum+0x288>
    800058ee:	ffffb097          	auipc	ra,0xffffb
    800058f2:	c50080e7          	jalr	-944(ra) # 8000053e <panic>
    dp->nlink--;
    800058f6:	04a4d783          	lhu	a5,74(s1)
    800058fa:	37fd                	addiw	a5,a5,-1
    800058fc:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005900:	8526                	mv	a0,s1
    80005902:	ffffe097          	auipc	ra,0xffffe
    80005906:	fce080e7          	jalr	-50(ra) # 800038d0 <iupdate>
    8000590a:	b781                	j	8000584a <sys_unlink+0xe0>
    return -1;
    8000590c:	557d                	li	a0,-1
    8000590e:	a005                	j	8000592e <sys_unlink+0x1c4>
    iunlockput(ip);
    80005910:	854a                	mv	a0,s2
    80005912:	ffffe097          	auipc	ra,0xffffe
    80005916:	2ea080e7          	jalr	746(ra) # 80003bfc <iunlockput>
  iunlockput(dp);
    8000591a:	8526                	mv	a0,s1
    8000591c:	ffffe097          	auipc	ra,0xffffe
    80005920:	2e0080e7          	jalr	736(ra) # 80003bfc <iunlockput>
  end_op();
    80005924:	fffff097          	auipc	ra,0xfffff
    80005928:	ab8080e7          	jalr	-1352(ra) # 800043dc <end_op>
  return -1;
    8000592c:	557d                	li	a0,-1
}
    8000592e:	70ae                	ld	ra,232(sp)
    80005930:	740e                	ld	s0,224(sp)
    80005932:	64ee                	ld	s1,216(sp)
    80005934:	694e                	ld	s2,208(sp)
    80005936:	69ae                	ld	s3,200(sp)
    80005938:	616d                	addi	sp,sp,240
    8000593a:	8082                	ret

000000008000593c <sys_open>:

uint64
sys_open(void)
{
    8000593c:	7131                	addi	sp,sp,-192
    8000593e:	fd06                	sd	ra,184(sp)
    80005940:	f922                	sd	s0,176(sp)
    80005942:	f526                	sd	s1,168(sp)
    80005944:	f14a                	sd	s2,160(sp)
    80005946:	ed4e                	sd	s3,152(sp)
    80005948:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000594a:	f4c40593          	addi	a1,s0,-180
    8000594e:	4505                	li	a0,1
    80005950:	ffffd097          	auipc	ra,0xffffd
    80005954:	372080e7          	jalr	882(ra) # 80002cc2 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005958:	08000613          	li	a2,128
    8000595c:	f5040593          	addi	a1,s0,-176
    80005960:	4501                	li	a0,0
    80005962:	ffffd097          	auipc	ra,0xffffd
    80005966:	3a2080e7          	jalr	930(ra) # 80002d04 <argstr>
    8000596a:	87aa                	mv	a5,a0
    return -1;
    8000596c:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000596e:	0a07c963          	bltz	a5,80005a20 <sys_open+0xe4>

  begin_op();
    80005972:	fffff097          	auipc	ra,0xfffff
    80005976:	9ea080e7          	jalr	-1558(ra) # 8000435c <begin_op>

  if(omode & O_CREATE){
    8000597a:	f4c42783          	lw	a5,-180(s0)
    8000597e:	2007f793          	andi	a5,a5,512
    80005982:	cfc5                	beqz	a5,80005a3a <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005984:	4681                	li	a3,0
    80005986:	4601                	li	a2,0
    80005988:	4589                	li	a1,2
    8000598a:	f5040513          	addi	a0,s0,-176
    8000598e:	00000097          	auipc	ra,0x0
    80005992:	976080e7          	jalr	-1674(ra) # 80005304 <create>
    80005996:	84aa                	mv	s1,a0
    if(ip == 0){
    80005998:	c959                	beqz	a0,80005a2e <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000599a:	04449703          	lh	a4,68(s1)
    8000599e:	478d                	li	a5,3
    800059a0:	00f71763          	bne	a4,a5,800059ae <sys_open+0x72>
    800059a4:	0464d703          	lhu	a4,70(s1)
    800059a8:	47a5                	li	a5,9
    800059aa:	0ce7ed63          	bltu	a5,a4,80005a84 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800059ae:	fffff097          	auipc	ra,0xfffff
    800059b2:	dbe080e7          	jalr	-578(ra) # 8000476c <filealloc>
    800059b6:	89aa                	mv	s3,a0
    800059b8:	10050363          	beqz	a0,80005abe <sys_open+0x182>
    800059bc:	00000097          	auipc	ra,0x0
    800059c0:	906080e7          	jalr	-1786(ra) # 800052c2 <fdalloc>
    800059c4:	892a                	mv	s2,a0
    800059c6:	0e054763          	bltz	a0,80005ab4 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800059ca:	04449703          	lh	a4,68(s1)
    800059ce:	478d                	li	a5,3
    800059d0:	0cf70563          	beq	a4,a5,80005a9a <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800059d4:	4789                	li	a5,2
    800059d6:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800059da:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800059de:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    800059e2:	f4c42783          	lw	a5,-180(s0)
    800059e6:	0017c713          	xori	a4,a5,1
    800059ea:	8b05                	andi	a4,a4,1
    800059ec:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800059f0:	0037f713          	andi	a4,a5,3
    800059f4:	00e03733          	snez	a4,a4
    800059f8:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800059fc:	4007f793          	andi	a5,a5,1024
    80005a00:	c791                	beqz	a5,80005a0c <sys_open+0xd0>
    80005a02:	04449703          	lh	a4,68(s1)
    80005a06:	4789                	li	a5,2
    80005a08:	0af70063          	beq	a4,a5,80005aa8 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005a0c:	8526                	mv	a0,s1
    80005a0e:	ffffe097          	auipc	ra,0xffffe
    80005a12:	04e080e7          	jalr	78(ra) # 80003a5c <iunlock>
  end_op();
    80005a16:	fffff097          	auipc	ra,0xfffff
    80005a1a:	9c6080e7          	jalr	-1594(ra) # 800043dc <end_op>

  return fd;
    80005a1e:	854a                	mv	a0,s2
}
    80005a20:	70ea                	ld	ra,184(sp)
    80005a22:	744a                	ld	s0,176(sp)
    80005a24:	74aa                	ld	s1,168(sp)
    80005a26:	790a                	ld	s2,160(sp)
    80005a28:	69ea                	ld	s3,152(sp)
    80005a2a:	6129                	addi	sp,sp,192
    80005a2c:	8082                	ret
      end_op();
    80005a2e:	fffff097          	auipc	ra,0xfffff
    80005a32:	9ae080e7          	jalr	-1618(ra) # 800043dc <end_op>
      return -1;
    80005a36:	557d                	li	a0,-1
    80005a38:	b7e5                	j	80005a20 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005a3a:	f5040513          	addi	a0,s0,-176
    80005a3e:	ffffe097          	auipc	ra,0xffffe
    80005a42:	702080e7          	jalr	1794(ra) # 80004140 <namei>
    80005a46:	84aa                	mv	s1,a0
    80005a48:	c905                	beqz	a0,80005a78 <sys_open+0x13c>
    ilock(ip);
    80005a4a:	ffffe097          	auipc	ra,0xffffe
    80005a4e:	f50080e7          	jalr	-176(ra) # 8000399a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005a52:	04449703          	lh	a4,68(s1)
    80005a56:	4785                	li	a5,1
    80005a58:	f4f711e3          	bne	a4,a5,8000599a <sys_open+0x5e>
    80005a5c:	f4c42783          	lw	a5,-180(s0)
    80005a60:	d7b9                	beqz	a5,800059ae <sys_open+0x72>
      iunlockput(ip);
    80005a62:	8526                	mv	a0,s1
    80005a64:	ffffe097          	auipc	ra,0xffffe
    80005a68:	198080e7          	jalr	408(ra) # 80003bfc <iunlockput>
      end_op();
    80005a6c:	fffff097          	auipc	ra,0xfffff
    80005a70:	970080e7          	jalr	-1680(ra) # 800043dc <end_op>
      return -1;
    80005a74:	557d                	li	a0,-1
    80005a76:	b76d                	j	80005a20 <sys_open+0xe4>
      end_op();
    80005a78:	fffff097          	auipc	ra,0xfffff
    80005a7c:	964080e7          	jalr	-1692(ra) # 800043dc <end_op>
      return -1;
    80005a80:	557d                	li	a0,-1
    80005a82:	bf79                	j	80005a20 <sys_open+0xe4>
    iunlockput(ip);
    80005a84:	8526                	mv	a0,s1
    80005a86:	ffffe097          	auipc	ra,0xffffe
    80005a8a:	176080e7          	jalr	374(ra) # 80003bfc <iunlockput>
    end_op();
    80005a8e:	fffff097          	auipc	ra,0xfffff
    80005a92:	94e080e7          	jalr	-1714(ra) # 800043dc <end_op>
    return -1;
    80005a96:	557d                	li	a0,-1
    80005a98:	b761                	j	80005a20 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005a9a:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005a9e:	04649783          	lh	a5,70(s1)
    80005aa2:	02f99223          	sh	a5,36(s3)
    80005aa6:	bf25                	j	800059de <sys_open+0xa2>
    itrunc(ip);
    80005aa8:	8526                	mv	a0,s1
    80005aaa:	ffffe097          	auipc	ra,0xffffe
    80005aae:	ffe080e7          	jalr	-2(ra) # 80003aa8 <itrunc>
    80005ab2:	bfa9                	j	80005a0c <sys_open+0xd0>
      fileclose(f);
    80005ab4:	854e                	mv	a0,s3
    80005ab6:	fffff097          	auipc	ra,0xfffff
    80005aba:	d72080e7          	jalr	-654(ra) # 80004828 <fileclose>
    iunlockput(ip);
    80005abe:	8526                	mv	a0,s1
    80005ac0:	ffffe097          	auipc	ra,0xffffe
    80005ac4:	13c080e7          	jalr	316(ra) # 80003bfc <iunlockput>
    end_op();
    80005ac8:	fffff097          	auipc	ra,0xfffff
    80005acc:	914080e7          	jalr	-1772(ra) # 800043dc <end_op>
    return -1;
    80005ad0:	557d                	li	a0,-1
    80005ad2:	b7b9                	j	80005a20 <sys_open+0xe4>

0000000080005ad4 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005ad4:	7175                	addi	sp,sp,-144
    80005ad6:	e506                	sd	ra,136(sp)
    80005ad8:	e122                	sd	s0,128(sp)
    80005ada:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005adc:	fffff097          	auipc	ra,0xfffff
    80005ae0:	880080e7          	jalr	-1920(ra) # 8000435c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005ae4:	08000613          	li	a2,128
    80005ae8:	f7040593          	addi	a1,s0,-144
    80005aec:	4501                	li	a0,0
    80005aee:	ffffd097          	auipc	ra,0xffffd
    80005af2:	216080e7          	jalr	534(ra) # 80002d04 <argstr>
    80005af6:	02054963          	bltz	a0,80005b28 <sys_mkdir+0x54>
    80005afa:	4681                	li	a3,0
    80005afc:	4601                	li	a2,0
    80005afe:	4585                	li	a1,1
    80005b00:	f7040513          	addi	a0,s0,-144
    80005b04:	00000097          	auipc	ra,0x0
    80005b08:	800080e7          	jalr	-2048(ra) # 80005304 <create>
    80005b0c:	cd11                	beqz	a0,80005b28 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b0e:	ffffe097          	auipc	ra,0xffffe
    80005b12:	0ee080e7          	jalr	238(ra) # 80003bfc <iunlockput>
  end_op();
    80005b16:	fffff097          	auipc	ra,0xfffff
    80005b1a:	8c6080e7          	jalr	-1850(ra) # 800043dc <end_op>
  return 0;
    80005b1e:	4501                	li	a0,0
}
    80005b20:	60aa                	ld	ra,136(sp)
    80005b22:	640a                	ld	s0,128(sp)
    80005b24:	6149                	addi	sp,sp,144
    80005b26:	8082                	ret
    end_op();
    80005b28:	fffff097          	auipc	ra,0xfffff
    80005b2c:	8b4080e7          	jalr	-1868(ra) # 800043dc <end_op>
    return -1;
    80005b30:	557d                	li	a0,-1
    80005b32:	b7fd                	j	80005b20 <sys_mkdir+0x4c>

0000000080005b34 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005b34:	7135                	addi	sp,sp,-160
    80005b36:	ed06                	sd	ra,152(sp)
    80005b38:	e922                	sd	s0,144(sp)
    80005b3a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005b3c:	fffff097          	auipc	ra,0xfffff
    80005b40:	820080e7          	jalr	-2016(ra) # 8000435c <begin_op>
  argint(1, &major);
    80005b44:	f6c40593          	addi	a1,s0,-148
    80005b48:	4505                	li	a0,1
    80005b4a:	ffffd097          	auipc	ra,0xffffd
    80005b4e:	178080e7          	jalr	376(ra) # 80002cc2 <argint>
  argint(2, &minor);
    80005b52:	f6840593          	addi	a1,s0,-152
    80005b56:	4509                	li	a0,2
    80005b58:	ffffd097          	auipc	ra,0xffffd
    80005b5c:	16a080e7          	jalr	362(ra) # 80002cc2 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b60:	08000613          	li	a2,128
    80005b64:	f7040593          	addi	a1,s0,-144
    80005b68:	4501                	li	a0,0
    80005b6a:	ffffd097          	auipc	ra,0xffffd
    80005b6e:	19a080e7          	jalr	410(ra) # 80002d04 <argstr>
    80005b72:	02054b63          	bltz	a0,80005ba8 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005b76:	f6841683          	lh	a3,-152(s0)
    80005b7a:	f6c41603          	lh	a2,-148(s0)
    80005b7e:	458d                	li	a1,3
    80005b80:	f7040513          	addi	a0,s0,-144
    80005b84:	fffff097          	auipc	ra,0xfffff
    80005b88:	780080e7          	jalr	1920(ra) # 80005304 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b8c:	cd11                	beqz	a0,80005ba8 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b8e:	ffffe097          	auipc	ra,0xffffe
    80005b92:	06e080e7          	jalr	110(ra) # 80003bfc <iunlockput>
  end_op();
    80005b96:	fffff097          	auipc	ra,0xfffff
    80005b9a:	846080e7          	jalr	-1978(ra) # 800043dc <end_op>
  return 0;
    80005b9e:	4501                	li	a0,0
}
    80005ba0:	60ea                	ld	ra,152(sp)
    80005ba2:	644a                	ld	s0,144(sp)
    80005ba4:	610d                	addi	sp,sp,160
    80005ba6:	8082                	ret
    end_op();
    80005ba8:	fffff097          	auipc	ra,0xfffff
    80005bac:	834080e7          	jalr	-1996(ra) # 800043dc <end_op>
    return -1;
    80005bb0:	557d                	li	a0,-1
    80005bb2:	b7fd                	j	80005ba0 <sys_mknod+0x6c>

0000000080005bb4 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005bb4:	7135                	addi	sp,sp,-160
    80005bb6:	ed06                	sd	ra,152(sp)
    80005bb8:	e922                	sd	s0,144(sp)
    80005bba:	e526                	sd	s1,136(sp)
    80005bbc:	e14a                	sd	s2,128(sp)
    80005bbe:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005bc0:	ffffc097          	auipc	ra,0xffffc
    80005bc4:	dec080e7          	jalr	-532(ra) # 800019ac <myproc>
    80005bc8:	892a                	mv	s2,a0
  
  begin_op();
    80005bca:	ffffe097          	auipc	ra,0xffffe
    80005bce:	792080e7          	jalr	1938(ra) # 8000435c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005bd2:	08000613          	li	a2,128
    80005bd6:	f6040593          	addi	a1,s0,-160
    80005bda:	4501                	li	a0,0
    80005bdc:	ffffd097          	auipc	ra,0xffffd
    80005be0:	128080e7          	jalr	296(ra) # 80002d04 <argstr>
    80005be4:	04054b63          	bltz	a0,80005c3a <sys_chdir+0x86>
    80005be8:	f6040513          	addi	a0,s0,-160
    80005bec:	ffffe097          	auipc	ra,0xffffe
    80005bf0:	554080e7          	jalr	1364(ra) # 80004140 <namei>
    80005bf4:	84aa                	mv	s1,a0
    80005bf6:	c131                	beqz	a0,80005c3a <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005bf8:	ffffe097          	auipc	ra,0xffffe
    80005bfc:	da2080e7          	jalr	-606(ra) # 8000399a <ilock>
  if(ip->type != T_DIR){
    80005c00:	04449703          	lh	a4,68(s1)
    80005c04:	4785                	li	a5,1
    80005c06:	04f71063          	bne	a4,a5,80005c46 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005c0a:	8526                	mv	a0,s1
    80005c0c:	ffffe097          	auipc	ra,0xffffe
    80005c10:	e50080e7          	jalr	-432(ra) # 80003a5c <iunlock>
  iput(p->cwd);
    80005c14:	15093503          	ld	a0,336(s2)
    80005c18:	ffffe097          	auipc	ra,0xffffe
    80005c1c:	f3c080e7          	jalr	-196(ra) # 80003b54 <iput>
  end_op();
    80005c20:	ffffe097          	auipc	ra,0xffffe
    80005c24:	7bc080e7          	jalr	1980(ra) # 800043dc <end_op>
  p->cwd = ip;
    80005c28:	14993823          	sd	s1,336(s2)
  return 0;
    80005c2c:	4501                	li	a0,0
}
    80005c2e:	60ea                	ld	ra,152(sp)
    80005c30:	644a                	ld	s0,144(sp)
    80005c32:	64aa                	ld	s1,136(sp)
    80005c34:	690a                	ld	s2,128(sp)
    80005c36:	610d                	addi	sp,sp,160
    80005c38:	8082                	ret
    end_op();
    80005c3a:	ffffe097          	auipc	ra,0xffffe
    80005c3e:	7a2080e7          	jalr	1954(ra) # 800043dc <end_op>
    return -1;
    80005c42:	557d                	li	a0,-1
    80005c44:	b7ed                	j	80005c2e <sys_chdir+0x7a>
    iunlockput(ip);
    80005c46:	8526                	mv	a0,s1
    80005c48:	ffffe097          	auipc	ra,0xffffe
    80005c4c:	fb4080e7          	jalr	-76(ra) # 80003bfc <iunlockput>
    end_op();
    80005c50:	ffffe097          	auipc	ra,0xffffe
    80005c54:	78c080e7          	jalr	1932(ra) # 800043dc <end_op>
    return -1;
    80005c58:	557d                	li	a0,-1
    80005c5a:	bfd1                	j	80005c2e <sys_chdir+0x7a>

0000000080005c5c <sys_exec>:

uint64
sys_exec(void)
{
    80005c5c:	7145                	addi	sp,sp,-464
    80005c5e:	e786                	sd	ra,456(sp)
    80005c60:	e3a2                	sd	s0,448(sp)
    80005c62:	ff26                	sd	s1,440(sp)
    80005c64:	fb4a                	sd	s2,432(sp)
    80005c66:	f74e                	sd	s3,424(sp)
    80005c68:	f352                	sd	s4,416(sp)
    80005c6a:	ef56                	sd	s5,408(sp)
    80005c6c:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005c6e:	e3840593          	addi	a1,s0,-456
    80005c72:	4505                	li	a0,1
    80005c74:	ffffd097          	auipc	ra,0xffffd
    80005c78:	070080e7          	jalr	112(ra) # 80002ce4 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005c7c:	08000613          	li	a2,128
    80005c80:	f4040593          	addi	a1,s0,-192
    80005c84:	4501                	li	a0,0
    80005c86:	ffffd097          	auipc	ra,0xffffd
    80005c8a:	07e080e7          	jalr	126(ra) # 80002d04 <argstr>
    80005c8e:	87aa                	mv	a5,a0
    return -1;
    80005c90:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005c92:	0c07c263          	bltz	a5,80005d56 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005c96:	10000613          	li	a2,256
    80005c9a:	4581                	li	a1,0
    80005c9c:	e4040513          	addi	a0,s0,-448
    80005ca0:	ffffb097          	auipc	ra,0xffffb
    80005ca4:	032080e7          	jalr	50(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005ca8:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005cac:	89a6                	mv	s3,s1
    80005cae:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005cb0:	02000a13          	li	s4,32
    80005cb4:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005cb8:	00391793          	slli	a5,s2,0x3
    80005cbc:	e3040593          	addi	a1,s0,-464
    80005cc0:	e3843503          	ld	a0,-456(s0)
    80005cc4:	953e                	add	a0,a0,a5
    80005cc6:	ffffd097          	auipc	ra,0xffffd
    80005cca:	f5e080e7          	jalr	-162(ra) # 80002c24 <fetchaddr>
    80005cce:	02054a63          	bltz	a0,80005d02 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005cd2:	e3043783          	ld	a5,-464(s0)
    80005cd6:	c3b9                	beqz	a5,80005d1c <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005cd8:	ffffb097          	auipc	ra,0xffffb
    80005cdc:	e0e080e7          	jalr	-498(ra) # 80000ae6 <kalloc>
    80005ce0:	85aa                	mv	a1,a0
    80005ce2:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005ce6:	cd11                	beqz	a0,80005d02 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005ce8:	6605                	lui	a2,0x1
    80005cea:	e3043503          	ld	a0,-464(s0)
    80005cee:	ffffd097          	auipc	ra,0xffffd
    80005cf2:	f88080e7          	jalr	-120(ra) # 80002c76 <fetchstr>
    80005cf6:	00054663          	bltz	a0,80005d02 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005cfa:	0905                	addi	s2,s2,1
    80005cfc:	09a1                	addi	s3,s3,8
    80005cfe:	fb491be3          	bne	s2,s4,80005cb4 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d02:	10048913          	addi	s2,s1,256
    80005d06:	6088                	ld	a0,0(s1)
    80005d08:	c531                	beqz	a0,80005d54 <sys_exec+0xf8>
    kfree(argv[i]);
    80005d0a:	ffffb097          	auipc	ra,0xffffb
    80005d0e:	ce0080e7          	jalr	-800(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d12:	04a1                	addi	s1,s1,8
    80005d14:	ff2499e3          	bne	s1,s2,80005d06 <sys_exec+0xaa>
  return -1;
    80005d18:	557d                	li	a0,-1
    80005d1a:	a835                	j	80005d56 <sys_exec+0xfa>
      argv[i] = 0;
    80005d1c:	0a8e                	slli	s5,s5,0x3
    80005d1e:	fc040793          	addi	a5,s0,-64
    80005d22:	9abe                	add	s5,s5,a5
    80005d24:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005d28:	e4040593          	addi	a1,s0,-448
    80005d2c:	f4040513          	addi	a0,s0,-192
    80005d30:	fffff097          	auipc	ra,0xfffff
    80005d34:	172080e7          	jalr	370(ra) # 80004ea2 <exec>
    80005d38:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d3a:	10048993          	addi	s3,s1,256
    80005d3e:	6088                	ld	a0,0(s1)
    80005d40:	c901                	beqz	a0,80005d50 <sys_exec+0xf4>
    kfree(argv[i]);
    80005d42:	ffffb097          	auipc	ra,0xffffb
    80005d46:	ca8080e7          	jalr	-856(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d4a:	04a1                	addi	s1,s1,8
    80005d4c:	ff3499e3          	bne	s1,s3,80005d3e <sys_exec+0xe2>
  return ret;
    80005d50:	854a                	mv	a0,s2
    80005d52:	a011                	j	80005d56 <sys_exec+0xfa>
  return -1;
    80005d54:	557d                	li	a0,-1
}
    80005d56:	60be                	ld	ra,456(sp)
    80005d58:	641e                	ld	s0,448(sp)
    80005d5a:	74fa                	ld	s1,440(sp)
    80005d5c:	795a                	ld	s2,432(sp)
    80005d5e:	79ba                	ld	s3,424(sp)
    80005d60:	7a1a                	ld	s4,416(sp)
    80005d62:	6afa                	ld	s5,408(sp)
    80005d64:	6179                	addi	sp,sp,464
    80005d66:	8082                	ret

0000000080005d68 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005d68:	7139                	addi	sp,sp,-64
    80005d6a:	fc06                	sd	ra,56(sp)
    80005d6c:	f822                	sd	s0,48(sp)
    80005d6e:	f426                	sd	s1,40(sp)
    80005d70:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005d72:	ffffc097          	auipc	ra,0xffffc
    80005d76:	c3a080e7          	jalr	-966(ra) # 800019ac <myproc>
    80005d7a:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005d7c:	fd840593          	addi	a1,s0,-40
    80005d80:	4501                	li	a0,0
    80005d82:	ffffd097          	auipc	ra,0xffffd
    80005d86:	f62080e7          	jalr	-158(ra) # 80002ce4 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005d8a:	fc840593          	addi	a1,s0,-56
    80005d8e:	fd040513          	addi	a0,s0,-48
    80005d92:	fffff097          	auipc	ra,0xfffff
    80005d96:	dc6080e7          	jalr	-570(ra) # 80004b58 <pipealloc>
    return -1;
    80005d9a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d9c:	0c054463          	bltz	a0,80005e64 <sys_pipe+0xfc>
  fd0 = -1;
    80005da0:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005da4:	fd043503          	ld	a0,-48(s0)
    80005da8:	fffff097          	auipc	ra,0xfffff
    80005dac:	51a080e7          	jalr	1306(ra) # 800052c2 <fdalloc>
    80005db0:	fca42223          	sw	a0,-60(s0)
    80005db4:	08054b63          	bltz	a0,80005e4a <sys_pipe+0xe2>
    80005db8:	fc843503          	ld	a0,-56(s0)
    80005dbc:	fffff097          	auipc	ra,0xfffff
    80005dc0:	506080e7          	jalr	1286(ra) # 800052c2 <fdalloc>
    80005dc4:	fca42023          	sw	a0,-64(s0)
    80005dc8:	06054863          	bltz	a0,80005e38 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005dcc:	4691                	li	a3,4
    80005dce:	fc440613          	addi	a2,s0,-60
    80005dd2:	fd843583          	ld	a1,-40(s0)
    80005dd6:	68a8                	ld	a0,80(s1)
    80005dd8:	ffffc097          	auipc	ra,0xffffc
    80005ddc:	890080e7          	jalr	-1904(ra) # 80001668 <copyout>
    80005de0:	02054063          	bltz	a0,80005e00 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005de4:	4691                	li	a3,4
    80005de6:	fc040613          	addi	a2,s0,-64
    80005dea:	fd843583          	ld	a1,-40(s0)
    80005dee:	0591                	addi	a1,a1,4
    80005df0:	68a8                	ld	a0,80(s1)
    80005df2:	ffffc097          	auipc	ra,0xffffc
    80005df6:	876080e7          	jalr	-1930(ra) # 80001668 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005dfa:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005dfc:	06055463          	bgez	a0,80005e64 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005e00:	fc442783          	lw	a5,-60(s0)
    80005e04:	07e9                	addi	a5,a5,26
    80005e06:	078e                	slli	a5,a5,0x3
    80005e08:	97a6                	add	a5,a5,s1
    80005e0a:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005e0e:	fc042503          	lw	a0,-64(s0)
    80005e12:	0569                	addi	a0,a0,26
    80005e14:	050e                	slli	a0,a0,0x3
    80005e16:	94aa                	add	s1,s1,a0
    80005e18:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005e1c:	fd043503          	ld	a0,-48(s0)
    80005e20:	fffff097          	auipc	ra,0xfffff
    80005e24:	a08080e7          	jalr	-1528(ra) # 80004828 <fileclose>
    fileclose(wf);
    80005e28:	fc843503          	ld	a0,-56(s0)
    80005e2c:	fffff097          	auipc	ra,0xfffff
    80005e30:	9fc080e7          	jalr	-1540(ra) # 80004828 <fileclose>
    return -1;
    80005e34:	57fd                	li	a5,-1
    80005e36:	a03d                	j	80005e64 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005e38:	fc442783          	lw	a5,-60(s0)
    80005e3c:	0007c763          	bltz	a5,80005e4a <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005e40:	07e9                	addi	a5,a5,26
    80005e42:	078e                	slli	a5,a5,0x3
    80005e44:	94be                	add	s1,s1,a5
    80005e46:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005e4a:	fd043503          	ld	a0,-48(s0)
    80005e4e:	fffff097          	auipc	ra,0xfffff
    80005e52:	9da080e7          	jalr	-1574(ra) # 80004828 <fileclose>
    fileclose(wf);
    80005e56:	fc843503          	ld	a0,-56(s0)
    80005e5a:	fffff097          	auipc	ra,0xfffff
    80005e5e:	9ce080e7          	jalr	-1586(ra) # 80004828 <fileclose>
    return -1;
    80005e62:	57fd                	li	a5,-1
}
    80005e64:	853e                	mv	a0,a5
    80005e66:	70e2                	ld	ra,56(sp)
    80005e68:	7442                	ld	s0,48(sp)
    80005e6a:	74a2                	ld	s1,40(sp)
    80005e6c:	6121                	addi	sp,sp,64
    80005e6e:	8082                	ret

0000000080005e70 <kernelvec>:
    80005e70:	7111                	addi	sp,sp,-256
    80005e72:	e006                	sd	ra,0(sp)
    80005e74:	e40a                	sd	sp,8(sp)
    80005e76:	e80e                	sd	gp,16(sp)
    80005e78:	ec12                	sd	tp,24(sp)
    80005e7a:	f016                	sd	t0,32(sp)
    80005e7c:	f41a                	sd	t1,40(sp)
    80005e7e:	f81e                	sd	t2,48(sp)
    80005e80:	fc22                	sd	s0,56(sp)
    80005e82:	e0a6                	sd	s1,64(sp)
    80005e84:	e4aa                	sd	a0,72(sp)
    80005e86:	e8ae                	sd	a1,80(sp)
    80005e88:	ecb2                	sd	a2,88(sp)
    80005e8a:	f0b6                	sd	a3,96(sp)
    80005e8c:	f4ba                	sd	a4,104(sp)
    80005e8e:	f8be                	sd	a5,112(sp)
    80005e90:	fcc2                	sd	a6,120(sp)
    80005e92:	e146                	sd	a7,128(sp)
    80005e94:	e54a                	sd	s2,136(sp)
    80005e96:	e94e                	sd	s3,144(sp)
    80005e98:	ed52                	sd	s4,152(sp)
    80005e9a:	f156                	sd	s5,160(sp)
    80005e9c:	f55a                	sd	s6,168(sp)
    80005e9e:	f95e                	sd	s7,176(sp)
    80005ea0:	fd62                	sd	s8,184(sp)
    80005ea2:	e1e6                	sd	s9,192(sp)
    80005ea4:	e5ea                	sd	s10,200(sp)
    80005ea6:	e9ee                	sd	s11,208(sp)
    80005ea8:	edf2                	sd	t3,216(sp)
    80005eaa:	f1f6                	sd	t4,224(sp)
    80005eac:	f5fa                	sd	t5,232(sp)
    80005eae:	f9fe                	sd	t6,240(sp)
    80005eb0:	c6bfc0ef          	jal	ra,80002b1a <kerneltrap>
    80005eb4:	6082                	ld	ra,0(sp)
    80005eb6:	6122                	ld	sp,8(sp)
    80005eb8:	61c2                	ld	gp,16(sp)
    80005eba:	7282                	ld	t0,32(sp)
    80005ebc:	7322                	ld	t1,40(sp)
    80005ebe:	73c2                	ld	t2,48(sp)
    80005ec0:	7462                	ld	s0,56(sp)
    80005ec2:	6486                	ld	s1,64(sp)
    80005ec4:	6526                	ld	a0,72(sp)
    80005ec6:	65c6                	ld	a1,80(sp)
    80005ec8:	6666                	ld	a2,88(sp)
    80005eca:	7686                	ld	a3,96(sp)
    80005ecc:	7726                	ld	a4,104(sp)
    80005ece:	77c6                	ld	a5,112(sp)
    80005ed0:	7866                	ld	a6,120(sp)
    80005ed2:	688a                	ld	a7,128(sp)
    80005ed4:	692a                	ld	s2,136(sp)
    80005ed6:	69ca                	ld	s3,144(sp)
    80005ed8:	6a6a                	ld	s4,152(sp)
    80005eda:	7a8a                	ld	s5,160(sp)
    80005edc:	7b2a                	ld	s6,168(sp)
    80005ede:	7bca                	ld	s7,176(sp)
    80005ee0:	7c6a                	ld	s8,184(sp)
    80005ee2:	6c8e                	ld	s9,192(sp)
    80005ee4:	6d2e                	ld	s10,200(sp)
    80005ee6:	6dce                	ld	s11,208(sp)
    80005ee8:	6e6e                	ld	t3,216(sp)
    80005eea:	7e8e                	ld	t4,224(sp)
    80005eec:	7f2e                	ld	t5,232(sp)
    80005eee:	7fce                	ld	t6,240(sp)
    80005ef0:	6111                	addi	sp,sp,256
    80005ef2:	10200073          	sret
    80005ef6:	00000013          	nop
    80005efa:	00000013          	nop
    80005efe:	0001                	nop

0000000080005f00 <timervec>:
    80005f00:	34051573          	csrrw	a0,mscratch,a0
    80005f04:	e10c                	sd	a1,0(a0)
    80005f06:	e510                	sd	a2,8(a0)
    80005f08:	e914                	sd	a3,16(a0)
    80005f0a:	6d0c                	ld	a1,24(a0)
    80005f0c:	7110                	ld	a2,32(a0)
    80005f0e:	6194                	ld	a3,0(a1)
    80005f10:	96b2                	add	a3,a3,a2
    80005f12:	e194                	sd	a3,0(a1)
    80005f14:	4589                	li	a1,2
    80005f16:	14459073          	csrw	sip,a1
    80005f1a:	6914                	ld	a3,16(a0)
    80005f1c:	6510                	ld	a2,8(a0)
    80005f1e:	610c                	ld	a1,0(a0)
    80005f20:	34051573          	csrrw	a0,mscratch,a0
    80005f24:	30200073          	mret
	...

0000000080005f2a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005f2a:	1141                	addi	sp,sp,-16
    80005f2c:	e422                	sd	s0,8(sp)
    80005f2e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005f30:	0c0007b7          	lui	a5,0xc000
    80005f34:	4705                	li	a4,1
    80005f36:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005f38:	c3d8                	sw	a4,4(a5)
}
    80005f3a:	6422                	ld	s0,8(sp)
    80005f3c:	0141                	addi	sp,sp,16
    80005f3e:	8082                	ret

0000000080005f40 <plicinithart>:

void
plicinithart(void)
{
    80005f40:	1141                	addi	sp,sp,-16
    80005f42:	e406                	sd	ra,8(sp)
    80005f44:	e022                	sd	s0,0(sp)
    80005f46:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f48:	ffffc097          	auipc	ra,0xffffc
    80005f4c:	a38080e7          	jalr	-1480(ra) # 80001980 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005f50:	0085171b          	slliw	a4,a0,0x8
    80005f54:	0c0027b7          	lui	a5,0xc002
    80005f58:	97ba                	add	a5,a5,a4
    80005f5a:	40200713          	li	a4,1026
    80005f5e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005f62:	00d5151b          	slliw	a0,a0,0xd
    80005f66:	0c2017b7          	lui	a5,0xc201
    80005f6a:	953e                	add	a0,a0,a5
    80005f6c:	00052023          	sw	zero,0(a0)
}
    80005f70:	60a2                	ld	ra,8(sp)
    80005f72:	6402                	ld	s0,0(sp)
    80005f74:	0141                	addi	sp,sp,16
    80005f76:	8082                	ret

0000000080005f78 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005f78:	1141                	addi	sp,sp,-16
    80005f7a:	e406                	sd	ra,8(sp)
    80005f7c:	e022                	sd	s0,0(sp)
    80005f7e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f80:	ffffc097          	auipc	ra,0xffffc
    80005f84:	a00080e7          	jalr	-1536(ra) # 80001980 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005f88:	00d5179b          	slliw	a5,a0,0xd
    80005f8c:	0c201537          	lui	a0,0xc201
    80005f90:	953e                	add	a0,a0,a5
  return irq;
}
    80005f92:	4148                	lw	a0,4(a0)
    80005f94:	60a2                	ld	ra,8(sp)
    80005f96:	6402                	ld	s0,0(sp)
    80005f98:	0141                	addi	sp,sp,16
    80005f9a:	8082                	ret

0000000080005f9c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005f9c:	1101                	addi	sp,sp,-32
    80005f9e:	ec06                	sd	ra,24(sp)
    80005fa0:	e822                	sd	s0,16(sp)
    80005fa2:	e426                	sd	s1,8(sp)
    80005fa4:	1000                	addi	s0,sp,32
    80005fa6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005fa8:	ffffc097          	auipc	ra,0xffffc
    80005fac:	9d8080e7          	jalr	-1576(ra) # 80001980 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005fb0:	00d5151b          	slliw	a0,a0,0xd
    80005fb4:	0c2017b7          	lui	a5,0xc201
    80005fb8:	97aa                	add	a5,a5,a0
    80005fba:	c3c4                	sw	s1,4(a5)
}
    80005fbc:	60e2                	ld	ra,24(sp)
    80005fbe:	6442                	ld	s0,16(sp)
    80005fc0:	64a2                	ld	s1,8(sp)
    80005fc2:	6105                	addi	sp,sp,32
    80005fc4:	8082                	ret

0000000080005fc6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005fc6:	1141                	addi	sp,sp,-16
    80005fc8:	e406                	sd	ra,8(sp)
    80005fca:	e022                	sd	s0,0(sp)
    80005fcc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005fce:	479d                	li	a5,7
    80005fd0:	04a7cc63          	blt	a5,a0,80006028 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005fd4:	0001c797          	auipc	a5,0x1c
    80005fd8:	43c78793          	addi	a5,a5,1084 # 80022410 <disk>
    80005fdc:	97aa                	add	a5,a5,a0
    80005fde:	0187c783          	lbu	a5,24(a5)
    80005fe2:	ebb9                	bnez	a5,80006038 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005fe4:	00451613          	slli	a2,a0,0x4
    80005fe8:	0001c797          	auipc	a5,0x1c
    80005fec:	42878793          	addi	a5,a5,1064 # 80022410 <disk>
    80005ff0:	6394                	ld	a3,0(a5)
    80005ff2:	96b2                	add	a3,a3,a2
    80005ff4:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005ff8:	6398                	ld	a4,0(a5)
    80005ffa:	9732                	add	a4,a4,a2
    80005ffc:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006000:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006004:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006008:	953e                	add	a0,a0,a5
    8000600a:	4785                	li	a5,1
    8000600c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006010:	0001c517          	auipc	a0,0x1c
    80006014:	41850513          	addi	a0,a0,1048 # 80022428 <disk+0x18>
    80006018:	ffffc097          	auipc	ra,0xffffc
    8000601c:	2d4080e7          	jalr	724(ra) # 800022ec <wakeup>
}
    80006020:	60a2                	ld	ra,8(sp)
    80006022:	6402                	ld	s0,0(sp)
    80006024:	0141                	addi	sp,sp,16
    80006026:	8082                	ret
    panic("free_desc 1");
    80006028:	00003517          	auipc	a0,0x3
    8000602c:	86050513          	addi	a0,a0,-1952 # 80008888 <syscallnum+0x298>
    80006030:	ffffa097          	auipc	ra,0xffffa
    80006034:	50e080e7          	jalr	1294(ra) # 8000053e <panic>
    panic("free_desc 2");
    80006038:	00003517          	auipc	a0,0x3
    8000603c:	86050513          	addi	a0,a0,-1952 # 80008898 <syscallnum+0x2a8>
    80006040:	ffffa097          	auipc	ra,0xffffa
    80006044:	4fe080e7          	jalr	1278(ra) # 8000053e <panic>

0000000080006048 <virtio_disk_init>:
{
    80006048:	1101                	addi	sp,sp,-32
    8000604a:	ec06                	sd	ra,24(sp)
    8000604c:	e822                	sd	s0,16(sp)
    8000604e:	e426                	sd	s1,8(sp)
    80006050:	e04a                	sd	s2,0(sp)
    80006052:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006054:	00003597          	auipc	a1,0x3
    80006058:	85458593          	addi	a1,a1,-1964 # 800088a8 <syscallnum+0x2b8>
    8000605c:	0001c517          	auipc	a0,0x1c
    80006060:	4dc50513          	addi	a0,a0,1244 # 80022538 <disk+0x128>
    80006064:	ffffb097          	auipc	ra,0xffffb
    80006068:	ae2080e7          	jalr	-1310(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000606c:	100017b7          	lui	a5,0x10001
    80006070:	4398                	lw	a4,0(a5)
    80006072:	2701                	sext.w	a4,a4
    80006074:	747277b7          	lui	a5,0x74727
    80006078:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000607c:	14f71c63          	bne	a4,a5,800061d4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006080:	100017b7          	lui	a5,0x10001
    80006084:	43dc                	lw	a5,4(a5)
    80006086:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006088:	4709                	li	a4,2
    8000608a:	14e79563          	bne	a5,a4,800061d4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000608e:	100017b7          	lui	a5,0x10001
    80006092:	479c                	lw	a5,8(a5)
    80006094:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006096:	12e79f63          	bne	a5,a4,800061d4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000609a:	100017b7          	lui	a5,0x10001
    8000609e:	47d8                	lw	a4,12(a5)
    800060a0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800060a2:	554d47b7          	lui	a5,0x554d4
    800060a6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800060aa:	12f71563          	bne	a4,a5,800061d4 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    800060ae:	100017b7          	lui	a5,0x10001
    800060b2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800060b6:	4705                	li	a4,1
    800060b8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060ba:	470d                	li	a4,3
    800060bc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800060be:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800060c0:	c7ffe737          	lui	a4,0xc7ffe
    800060c4:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc20f>
    800060c8:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800060ca:	2701                	sext.w	a4,a4
    800060cc:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060ce:	472d                	li	a4,11
    800060d0:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800060d2:	5bbc                	lw	a5,112(a5)
    800060d4:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800060d8:	8ba1                	andi	a5,a5,8
    800060da:	10078563          	beqz	a5,800061e4 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800060de:	100017b7          	lui	a5,0x10001
    800060e2:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800060e6:	43fc                	lw	a5,68(a5)
    800060e8:	2781                	sext.w	a5,a5
    800060ea:	10079563          	bnez	a5,800061f4 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800060ee:	100017b7          	lui	a5,0x10001
    800060f2:	5bdc                	lw	a5,52(a5)
    800060f4:	2781                	sext.w	a5,a5
  if(max == 0)
    800060f6:	10078763          	beqz	a5,80006204 <virtio_disk_init+0x1bc>
  if(max < NUM)
    800060fa:	471d                	li	a4,7
    800060fc:	10f77c63          	bgeu	a4,a5,80006214 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    80006100:	ffffb097          	auipc	ra,0xffffb
    80006104:	9e6080e7          	jalr	-1562(ra) # 80000ae6 <kalloc>
    80006108:	0001c497          	auipc	s1,0x1c
    8000610c:	30848493          	addi	s1,s1,776 # 80022410 <disk>
    80006110:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006112:	ffffb097          	auipc	ra,0xffffb
    80006116:	9d4080e7          	jalr	-1580(ra) # 80000ae6 <kalloc>
    8000611a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000611c:	ffffb097          	auipc	ra,0xffffb
    80006120:	9ca080e7          	jalr	-1590(ra) # 80000ae6 <kalloc>
    80006124:	87aa                	mv	a5,a0
    80006126:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006128:	6088                	ld	a0,0(s1)
    8000612a:	cd6d                	beqz	a0,80006224 <virtio_disk_init+0x1dc>
    8000612c:	0001c717          	auipc	a4,0x1c
    80006130:	2ec73703          	ld	a4,748(a4) # 80022418 <disk+0x8>
    80006134:	cb65                	beqz	a4,80006224 <virtio_disk_init+0x1dc>
    80006136:	c7fd                	beqz	a5,80006224 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    80006138:	6605                	lui	a2,0x1
    8000613a:	4581                	li	a1,0
    8000613c:	ffffb097          	auipc	ra,0xffffb
    80006140:	b96080e7          	jalr	-1130(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006144:	0001c497          	auipc	s1,0x1c
    80006148:	2cc48493          	addi	s1,s1,716 # 80022410 <disk>
    8000614c:	6605                	lui	a2,0x1
    8000614e:	4581                	li	a1,0
    80006150:	6488                	ld	a0,8(s1)
    80006152:	ffffb097          	auipc	ra,0xffffb
    80006156:	b80080e7          	jalr	-1152(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    8000615a:	6605                	lui	a2,0x1
    8000615c:	4581                	li	a1,0
    8000615e:	6888                	ld	a0,16(s1)
    80006160:	ffffb097          	auipc	ra,0xffffb
    80006164:	b72080e7          	jalr	-1166(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006168:	100017b7          	lui	a5,0x10001
    8000616c:	4721                	li	a4,8
    8000616e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006170:	4098                	lw	a4,0(s1)
    80006172:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006176:	40d8                	lw	a4,4(s1)
    80006178:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000617c:	6498                	ld	a4,8(s1)
    8000617e:	0007069b          	sext.w	a3,a4
    80006182:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006186:	9701                	srai	a4,a4,0x20
    80006188:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000618c:	6898                	ld	a4,16(s1)
    8000618e:	0007069b          	sext.w	a3,a4
    80006192:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006196:	9701                	srai	a4,a4,0x20
    80006198:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000619c:	4705                	li	a4,1
    8000619e:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800061a0:	00e48c23          	sb	a4,24(s1)
    800061a4:	00e48ca3          	sb	a4,25(s1)
    800061a8:	00e48d23          	sb	a4,26(s1)
    800061ac:	00e48da3          	sb	a4,27(s1)
    800061b0:	00e48e23          	sb	a4,28(s1)
    800061b4:	00e48ea3          	sb	a4,29(s1)
    800061b8:	00e48f23          	sb	a4,30(s1)
    800061bc:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800061c0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800061c4:	0727a823          	sw	s2,112(a5)
}
    800061c8:	60e2                	ld	ra,24(sp)
    800061ca:	6442                	ld	s0,16(sp)
    800061cc:	64a2                	ld	s1,8(sp)
    800061ce:	6902                	ld	s2,0(sp)
    800061d0:	6105                	addi	sp,sp,32
    800061d2:	8082                	ret
    panic("could not find virtio disk");
    800061d4:	00002517          	auipc	a0,0x2
    800061d8:	6e450513          	addi	a0,a0,1764 # 800088b8 <syscallnum+0x2c8>
    800061dc:	ffffa097          	auipc	ra,0xffffa
    800061e0:	362080e7          	jalr	866(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    800061e4:	00002517          	auipc	a0,0x2
    800061e8:	6f450513          	addi	a0,a0,1780 # 800088d8 <syscallnum+0x2e8>
    800061ec:	ffffa097          	auipc	ra,0xffffa
    800061f0:	352080e7          	jalr	850(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    800061f4:	00002517          	auipc	a0,0x2
    800061f8:	70450513          	addi	a0,a0,1796 # 800088f8 <syscallnum+0x308>
    800061fc:	ffffa097          	auipc	ra,0xffffa
    80006200:	342080e7          	jalr	834(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    80006204:	00002517          	auipc	a0,0x2
    80006208:	71450513          	addi	a0,a0,1812 # 80008918 <syscallnum+0x328>
    8000620c:	ffffa097          	auipc	ra,0xffffa
    80006210:	332080e7          	jalr	818(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    80006214:	00002517          	auipc	a0,0x2
    80006218:	72450513          	addi	a0,a0,1828 # 80008938 <syscallnum+0x348>
    8000621c:	ffffa097          	auipc	ra,0xffffa
    80006220:	322080e7          	jalr	802(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    80006224:	00002517          	auipc	a0,0x2
    80006228:	73450513          	addi	a0,a0,1844 # 80008958 <syscallnum+0x368>
    8000622c:	ffffa097          	auipc	ra,0xffffa
    80006230:	312080e7          	jalr	786(ra) # 8000053e <panic>

0000000080006234 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006234:	7119                	addi	sp,sp,-128
    80006236:	fc86                	sd	ra,120(sp)
    80006238:	f8a2                	sd	s0,112(sp)
    8000623a:	f4a6                	sd	s1,104(sp)
    8000623c:	f0ca                	sd	s2,96(sp)
    8000623e:	ecce                	sd	s3,88(sp)
    80006240:	e8d2                	sd	s4,80(sp)
    80006242:	e4d6                	sd	s5,72(sp)
    80006244:	e0da                	sd	s6,64(sp)
    80006246:	fc5e                	sd	s7,56(sp)
    80006248:	f862                	sd	s8,48(sp)
    8000624a:	f466                	sd	s9,40(sp)
    8000624c:	f06a                	sd	s10,32(sp)
    8000624e:	ec6e                	sd	s11,24(sp)
    80006250:	0100                	addi	s0,sp,128
    80006252:	8aaa                	mv	s5,a0
    80006254:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006256:	00c52d03          	lw	s10,12(a0)
    8000625a:	001d1d1b          	slliw	s10,s10,0x1
    8000625e:	1d02                	slli	s10,s10,0x20
    80006260:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006264:	0001c517          	auipc	a0,0x1c
    80006268:	2d450513          	addi	a0,a0,724 # 80022538 <disk+0x128>
    8000626c:	ffffb097          	auipc	ra,0xffffb
    80006270:	96a080e7          	jalr	-1686(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80006274:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006276:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006278:	0001cb97          	auipc	s7,0x1c
    8000627c:	198b8b93          	addi	s7,s7,408 # 80022410 <disk>
  for(int i = 0; i < 3; i++){
    80006280:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006282:	0001cc97          	auipc	s9,0x1c
    80006286:	2b6c8c93          	addi	s9,s9,694 # 80022538 <disk+0x128>
    8000628a:	a08d                	j	800062ec <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000628c:	00fb8733          	add	a4,s7,a5
    80006290:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006294:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006296:	0207c563          	bltz	a5,800062c0 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000629a:	2905                	addiw	s2,s2,1
    8000629c:	0611                	addi	a2,a2,4
    8000629e:	05690c63          	beq	s2,s6,800062f6 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    800062a2:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800062a4:	0001c717          	auipc	a4,0x1c
    800062a8:	16c70713          	addi	a4,a4,364 # 80022410 <disk>
    800062ac:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800062ae:	01874683          	lbu	a3,24(a4)
    800062b2:	fee9                	bnez	a3,8000628c <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800062b4:	2785                	addiw	a5,a5,1
    800062b6:	0705                	addi	a4,a4,1
    800062b8:	fe979be3          	bne	a5,s1,800062ae <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800062bc:	57fd                	li	a5,-1
    800062be:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800062c0:	01205d63          	blez	s2,800062da <virtio_disk_rw+0xa6>
    800062c4:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800062c6:	000a2503          	lw	a0,0(s4)
    800062ca:	00000097          	auipc	ra,0x0
    800062ce:	cfc080e7          	jalr	-772(ra) # 80005fc6 <free_desc>
      for(int j = 0; j < i; j++)
    800062d2:	2d85                	addiw	s11,s11,1
    800062d4:	0a11                	addi	s4,s4,4
    800062d6:	ffb918e3          	bne	s2,s11,800062c6 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800062da:	85e6                	mv	a1,s9
    800062dc:	0001c517          	auipc	a0,0x1c
    800062e0:	14c50513          	addi	a0,a0,332 # 80022428 <disk+0x18>
    800062e4:	ffffc097          	auipc	ra,0xffffc
    800062e8:	e58080e7          	jalr	-424(ra) # 8000213c <sleep>
  for(int i = 0; i < 3; i++){
    800062ec:	f8040a13          	addi	s4,s0,-128
{
    800062f0:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800062f2:	894e                	mv	s2,s3
    800062f4:	b77d                	j	800062a2 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800062f6:	f8042583          	lw	a1,-128(s0)
    800062fa:	00a58793          	addi	a5,a1,10
    800062fe:	0792                	slli	a5,a5,0x4

  if(write)
    80006300:	0001c617          	auipc	a2,0x1c
    80006304:	11060613          	addi	a2,a2,272 # 80022410 <disk>
    80006308:	00f60733          	add	a4,a2,a5
    8000630c:	018036b3          	snez	a3,s8
    80006310:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006312:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006316:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000631a:	f6078693          	addi	a3,a5,-160
    8000631e:	6218                	ld	a4,0(a2)
    80006320:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006322:	00878513          	addi	a0,a5,8
    80006326:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006328:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000632a:	6208                	ld	a0,0(a2)
    8000632c:	96aa                	add	a3,a3,a0
    8000632e:	4741                	li	a4,16
    80006330:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006332:	4705                	li	a4,1
    80006334:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006338:	f8442703          	lw	a4,-124(s0)
    8000633c:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006340:	0712                	slli	a4,a4,0x4
    80006342:	953a                	add	a0,a0,a4
    80006344:	058a8693          	addi	a3,s5,88
    80006348:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000634a:	6208                	ld	a0,0(a2)
    8000634c:	972a                	add	a4,a4,a0
    8000634e:	40000693          	li	a3,1024
    80006352:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006354:	001c3c13          	seqz	s8,s8
    80006358:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000635a:	001c6c13          	ori	s8,s8,1
    8000635e:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006362:	f8842603          	lw	a2,-120(s0)
    80006366:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000636a:	0001c697          	auipc	a3,0x1c
    8000636e:	0a668693          	addi	a3,a3,166 # 80022410 <disk>
    80006372:	00258713          	addi	a4,a1,2
    80006376:	0712                	slli	a4,a4,0x4
    80006378:	9736                	add	a4,a4,a3
    8000637a:	587d                	li	a6,-1
    8000637c:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006380:	0612                	slli	a2,a2,0x4
    80006382:	9532                	add	a0,a0,a2
    80006384:	f9078793          	addi	a5,a5,-112
    80006388:	97b6                	add	a5,a5,a3
    8000638a:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    8000638c:	629c                	ld	a5,0(a3)
    8000638e:	97b2                	add	a5,a5,a2
    80006390:	4605                	li	a2,1
    80006392:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006394:	4509                	li	a0,2
    80006396:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    8000639a:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000639e:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800063a2:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800063a6:	6698                	ld	a4,8(a3)
    800063a8:	00275783          	lhu	a5,2(a4)
    800063ac:	8b9d                	andi	a5,a5,7
    800063ae:	0786                	slli	a5,a5,0x1
    800063b0:	97ba                	add	a5,a5,a4
    800063b2:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    800063b6:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800063ba:	6698                	ld	a4,8(a3)
    800063bc:	00275783          	lhu	a5,2(a4)
    800063c0:	2785                	addiw	a5,a5,1
    800063c2:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800063c6:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800063ca:	100017b7          	lui	a5,0x10001
    800063ce:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800063d2:	004aa783          	lw	a5,4(s5)
    800063d6:	02c79163          	bne	a5,a2,800063f8 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    800063da:	0001c917          	auipc	s2,0x1c
    800063de:	15e90913          	addi	s2,s2,350 # 80022538 <disk+0x128>
  while(b->disk == 1) {
    800063e2:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800063e4:	85ca                	mv	a1,s2
    800063e6:	8556                	mv	a0,s5
    800063e8:	ffffc097          	auipc	ra,0xffffc
    800063ec:	d54080e7          	jalr	-684(ra) # 8000213c <sleep>
  while(b->disk == 1) {
    800063f0:	004aa783          	lw	a5,4(s5)
    800063f4:	fe9788e3          	beq	a5,s1,800063e4 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800063f8:	f8042903          	lw	s2,-128(s0)
    800063fc:	00290793          	addi	a5,s2,2
    80006400:	00479713          	slli	a4,a5,0x4
    80006404:	0001c797          	auipc	a5,0x1c
    80006408:	00c78793          	addi	a5,a5,12 # 80022410 <disk>
    8000640c:	97ba                	add	a5,a5,a4
    8000640e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006412:	0001c997          	auipc	s3,0x1c
    80006416:	ffe98993          	addi	s3,s3,-2 # 80022410 <disk>
    8000641a:	00491713          	slli	a4,s2,0x4
    8000641e:	0009b783          	ld	a5,0(s3)
    80006422:	97ba                	add	a5,a5,a4
    80006424:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006428:	854a                	mv	a0,s2
    8000642a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000642e:	00000097          	auipc	ra,0x0
    80006432:	b98080e7          	jalr	-1128(ra) # 80005fc6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006436:	8885                	andi	s1,s1,1
    80006438:	f0ed                	bnez	s1,8000641a <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000643a:	0001c517          	auipc	a0,0x1c
    8000643e:	0fe50513          	addi	a0,a0,254 # 80022538 <disk+0x128>
    80006442:	ffffb097          	auipc	ra,0xffffb
    80006446:	848080e7          	jalr	-1976(ra) # 80000c8a <release>
}
    8000644a:	70e6                	ld	ra,120(sp)
    8000644c:	7446                	ld	s0,112(sp)
    8000644e:	74a6                	ld	s1,104(sp)
    80006450:	7906                	ld	s2,96(sp)
    80006452:	69e6                	ld	s3,88(sp)
    80006454:	6a46                	ld	s4,80(sp)
    80006456:	6aa6                	ld	s5,72(sp)
    80006458:	6b06                	ld	s6,64(sp)
    8000645a:	7be2                	ld	s7,56(sp)
    8000645c:	7c42                	ld	s8,48(sp)
    8000645e:	7ca2                	ld	s9,40(sp)
    80006460:	7d02                	ld	s10,32(sp)
    80006462:	6de2                	ld	s11,24(sp)
    80006464:	6109                	addi	sp,sp,128
    80006466:	8082                	ret

0000000080006468 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006468:	1101                	addi	sp,sp,-32
    8000646a:	ec06                	sd	ra,24(sp)
    8000646c:	e822                	sd	s0,16(sp)
    8000646e:	e426                	sd	s1,8(sp)
    80006470:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006472:	0001c497          	auipc	s1,0x1c
    80006476:	f9e48493          	addi	s1,s1,-98 # 80022410 <disk>
    8000647a:	0001c517          	auipc	a0,0x1c
    8000647e:	0be50513          	addi	a0,a0,190 # 80022538 <disk+0x128>
    80006482:	ffffa097          	auipc	ra,0xffffa
    80006486:	754080e7          	jalr	1876(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000648a:	10001737          	lui	a4,0x10001
    8000648e:	533c                	lw	a5,96(a4)
    80006490:	8b8d                	andi	a5,a5,3
    80006492:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006494:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006498:	689c                	ld	a5,16(s1)
    8000649a:	0204d703          	lhu	a4,32(s1)
    8000649e:	0027d783          	lhu	a5,2(a5)
    800064a2:	04f70863          	beq	a4,a5,800064f2 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800064a6:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800064aa:	6898                	ld	a4,16(s1)
    800064ac:	0204d783          	lhu	a5,32(s1)
    800064b0:	8b9d                	andi	a5,a5,7
    800064b2:	078e                	slli	a5,a5,0x3
    800064b4:	97ba                	add	a5,a5,a4
    800064b6:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800064b8:	00278713          	addi	a4,a5,2
    800064bc:	0712                	slli	a4,a4,0x4
    800064be:	9726                	add	a4,a4,s1
    800064c0:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800064c4:	e721                	bnez	a4,8000650c <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800064c6:	0789                	addi	a5,a5,2
    800064c8:	0792                	slli	a5,a5,0x4
    800064ca:	97a6                	add	a5,a5,s1
    800064cc:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800064ce:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800064d2:	ffffc097          	auipc	ra,0xffffc
    800064d6:	e1a080e7          	jalr	-486(ra) # 800022ec <wakeup>

    disk.used_idx += 1;
    800064da:	0204d783          	lhu	a5,32(s1)
    800064de:	2785                	addiw	a5,a5,1
    800064e0:	17c2                	slli	a5,a5,0x30
    800064e2:	93c1                	srli	a5,a5,0x30
    800064e4:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800064e8:	6898                	ld	a4,16(s1)
    800064ea:	00275703          	lhu	a4,2(a4)
    800064ee:	faf71ce3          	bne	a4,a5,800064a6 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800064f2:	0001c517          	auipc	a0,0x1c
    800064f6:	04650513          	addi	a0,a0,70 # 80022538 <disk+0x128>
    800064fa:	ffffa097          	auipc	ra,0xffffa
    800064fe:	790080e7          	jalr	1936(ra) # 80000c8a <release>
}
    80006502:	60e2                	ld	ra,24(sp)
    80006504:	6442                	ld	s0,16(sp)
    80006506:	64a2                	ld	s1,8(sp)
    80006508:	6105                	addi	sp,sp,32
    8000650a:	8082                	ret
      panic("virtio_disk_intr status");
    8000650c:	00002517          	auipc	a0,0x2
    80006510:	46450513          	addi	a0,a0,1124 # 80008970 <syscallnum+0x380>
    80006514:	ffffa097          	auipc	ra,0xffffa
    80006518:	02a080e7          	jalr	42(ra) # 8000053e <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...

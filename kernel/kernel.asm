
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	c4010113          	addi	sp,sp,-960 # 80008c40 <stack0>
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
    80000056:	aae70713          	addi	a4,a4,-1362 # 80008b00 <timer_scratch>
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
    80000068:	3bc78793          	addi	a5,a5,956 # 80006420 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdaa5f>
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
    8000012c:	00003097          	auipc	ra,0x3
    80000130:	8a2080e7          	jalr	-1886(ra) # 800029ce <either_copyin>
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
    8000018e:	ab650513          	addi	a0,a0,-1354 # 80010c40 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	aa648493          	addi	s1,s1,-1370 # 80010c40 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	b3690913          	addi	s2,s2,-1226 # 80010cd8 <cons+0x98>
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
    800001cc:	650080e7          	jalr	1616(ra) # 80002818 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	21c080e7          	jalr	540(ra) # 800023f2 <sleep>
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
    80000216:	766080e7          	jalr	1894(ra) # 80002978 <either_copyout>
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
    8000022a:	a1a50513          	addi	a0,a0,-1510 # 80010c40 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	a0450513          	addi	a0,a0,-1532 # 80010c40 <cons>
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
    80000276:	a6f72323          	sw	a5,-1434(a4) # 80010cd8 <cons+0x98>
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
    800002d0:	97450513          	addi	a0,a0,-1676 # 80010c40 <cons>
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
    800002f6:	732080e7          	jalr	1842(ra) # 80002a24 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00011517          	auipc	a0,0x11
    800002fe:	94650513          	addi	a0,a0,-1722 # 80010c40 <cons>
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
    80000322:	92270713          	addi	a4,a4,-1758 # 80010c40 <cons>
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
    8000034c:	8f878793          	addi	a5,a5,-1800 # 80010c40 <cons>
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
    8000037a:	9627a783          	lw	a5,-1694(a5) # 80010cd8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00011717          	auipc	a4,0x11
    8000038e:	8b670713          	addi	a4,a4,-1866 # 80010c40 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00011497          	auipc	s1,0x11
    8000039e:	8a648493          	addi	s1,s1,-1882 # 80010c40 <cons>
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
    800003da:	86a70713          	addi	a4,a4,-1942 # 80010c40 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00011717          	auipc	a4,0x11
    800003f0:	8ef72a23          	sw	a5,-1804(a4) # 80010ce0 <cons+0xa0>
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
    80000416:	82e78793          	addi	a5,a5,-2002 # 80010c40 <cons>
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
    8000043a:	8ac7a323          	sw	a2,-1882(a5) # 80010cdc <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00011517          	auipc	a0,0x11
    80000442:	89a50513          	addi	a0,a0,-1894 # 80010cd8 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	168080e7          	jalr	360(ra) # 800025ae <wakeup>
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
    80000464:	7e050513          	addi	a0,a0,2016 # 80010c40 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32a080e7          	jalr	810(ra) # 8000079a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00022797          	auipc	a5,0x22
    8000047c:	79078793          	addi	a5,a5,1936 # 80022c08 <devsw>
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
    8000054e:	7a07ab23          	sw	zero,1974(a5) # 80010d00 <pr+0x18>
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
    80000582:	54f72123          	sw	a5,1346(a4) # 80008ac0 <panicked>
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
    800005be:	746dad83          	lw	s11,1862(s11) # 80010d00 <pr+0x18>
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
    800005fc:	6f050513          	addi	a0,a0,1776 # 80010ce8 <pr>
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
    8000075a:	59250513          	addi	a0,a0,1426 # 80010ce8 <pr>
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
    80000776:	57648493          	addi	s1,s1,1398 # 80010ce8 <pr>
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
    800007d6:	53650513          	addi	a0,a0,1334 # 80010d08 <uart_tx_lock>
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
    80000802:	2c27a783          	lw	a5,706(a5) # 80008ac0 <panicked>
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
    8000083a:	2927b783          	ld	a5,658(a5) # 80008ac8 <uart_tx_r>
    8000083e:	00008717          	auipc	a4,0x8
    80000842:	29273703          	ld	a4,658(a4) # 80008ad0 <uart_tx_w>
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
    80000864:	4a8a0a13          	addi	s4,s4,1192 # 80010d08 <uart_tx_lock>
    uart_tx_r += 1;
    80000868:	00008497          	auipc	s1,0x8
    8000086c:	26048493          	addi	s1,s1,608 # 80008ac8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000870:	00008997          	auipc	s3,0x8
    80000874:	26098993          	addi	s3,s3,608 # 80008ad0 <uart_tx_w>
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
    80000896:	d1c080e7          	jalr	-740(ra) # 800025ae <wakeup>
    
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
    800008d2:	43a50513          	addi	a0,a0,1082 # 80010d08 <uart_tx_lock>
    800008d6:	00000097          	auipc	ra,0x0
    800008da:	300080e7          	jalr	768(ra) # 80000bd6 <acquire>
  if(panicked){
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	1e27a783          	lw	a5,482(a5) # 80008ac0 <panicked>
    800008e6:	e7c9                	bnez	a5,80000970 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e8:	00008717          	auipc	a4,0x8
    800008ec:	1e873703          	ld	a4,488(a4) # 80008ad0 <uart_tx_w>
    800008f0:	00008797          	auipc	a5,0x8
    800008f4:	1d87b783          	ld	a5,472(a5) # 80008ac8 <uart_tx_r>
    800008f8:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fc:	00010997          	auipc	s3,0x10
    80000900:	40c98993          	addi	s3,s3,1036 # 80010d08 <uart_tx_lock>
    80000904:	00008497          	auipc	s1,0x8
    80000908:	1c448493          	addi	s1,s1,452 # 80008ac8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090c:	00008917          	auipc	s2,0x8
    80000910:	1c490913          	addi	s2,s2,452 # 80008ad0 <uart_tx_w>
    80000914:	00e79f63          	bne	a5,a4,80000932 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000918:	85ce                	mv	a1,s3
    8000091a:	8526                	mv	a0,s1
    8000091c:	00002097          	auipc	ra,0x2
    80000920:	ad6080e7          	jalr	-1322(ra) # 800023f2 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000924:	00093703          	ld	a4,0(s2)
    80000928:	609c                	ld	a5,0(s1)
    8000092a:	02078793          	addi	a5,a5,32
    8000092e:	fee785e3          	beq	a5,a4,80000918 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000932:	00010497          	auipc	s1,0x10
    80000936:	3d648493          	addi	s1,s1,982 # 80010d08 <uart_tx_lock>
    8000093a:	01f77793          	andi	a5,a4,31
    8000093e:	97a6                	add	a5,a5,s1
    80000940:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000944:	0705                	addi	a4,a4,1
    80000946:	00008797          	auipc	a5,0x8
    8000094a:	18e7b523          	sd	a4,394(a5) # 80008ad0 <uart_tx_w>
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
    800009c0:	34c48493          	addi	s1,s1,844 # 80010d08 <uart_tx_lock>
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
    800009fe:	00023797          	auipc	a5,0x23
    80000a02:	3a278793          	addi	a5,a5,930 # 80023da0 <end>
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
    80000a22:	32290913          	addi	s2,s2,802 # 80010d40 <kmem>
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
    80000abe:	28650513          	addi	a0,a0,646 # 80010d40 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00023517          	auipc	a0,0x23
    80000ad2:	2d250513          	addi	a0,a0,722 # 80023da0 <end>
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
    80000af4:	25048493          	addi	s1,s1,592 # 80010d40 <kmem>
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
    80000b0c:	23850513          	addi	a0,a0,568 # 80010d40 <kmem>
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
    80000b38:	20c50513          	addi	a0,a0,524 # 80010d40 <kmem>
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
    80000e8c:	c5070713          	addi	a4,a4,-944 # 80008ad8 <started>
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
    80000ec2:	d00080e7          	jalr	-768(ra) # 80002bbe <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	59a080e7          	jalr	1434(ra) # 80006460 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	116080e7          	jalr	278(ra) # 80001fe4 <scheduler>
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
    80000f3a:	c60080e7          	jalr	-928(ra) # 80002b96 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	c80080e7          	jalr	-896(ra) # 80002bbe <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	504080e7          	jalr	1284(ra) # 8000644a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	512080e7          	jalr	1298(ra) # 80006460 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	6b6080e7          	jalr	1718(ra) # 8000360c <binit>
    iinit();         // inode table
    80000f5e:	00003097          	auipc	ra,0x3
    80000f62:	d5a080e7          	jalr	-678(ra) # 80003cb8 <iinit>
    fileinit();      // file table
    80000f66:	00004097          	auipc	ra,0x4
    80000f6a:	cf8080e7          	jalr	-776(ra) # 80004c5e <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	5fa080e7          	jalr	1530(ra) # 80006568 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	d84080e7          	jalr	-636(ra) # 80001cfa <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	b4f72a23          	sw	a5,-1196(a4) # 80008ad8 <started>
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
    80000f9c:	b487b783          	ld	a5,-1208(a5) # 80008ae0 <kernel_pagetable>
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
    80001258:	88a7b623          	sd	a0,-1908(a5) # 80008ae0 <kernel_pagetable>
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
void proc_mapstacks(pagetable_t kpgtbl)
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

  for (p = proc; p < &proc[NPROC]; p++)
    8000184c:	00010497          	auipc	s1,0x10
    80001850:	97448493          	addi	s1,s1,-1676 # 800111c0 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001854:	8b26                	mv	s6,s1
    80001856:	00006a97          	auipc	s5,0x6
    8000185a:	7aaa8a93          	addi	s5,s5,1962 # 80008000 <etext>
    8000185e:	04000937          	lui	s2,0x4000
    80001862:	197d                	addi	s2,s2,-1
    80001864:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001866:	00017a17          	auipc	s4,0x17
    8000186a:	15aa0a13          	addi	s4,s4,346 # 800189c0 <tickslock>
    char *pa = kalloc();
    8000186e:	fffff097          	auipc	ra,0xfffff
    80001872:	278080e7          	jalr	632(ra) # 80000ae6 <kalloc>
    80001876:	862a                	mv	a2,a0
    if (pa == 0)
    80001878:	c131                	beqz	a0,800018bc <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    8000187a:	416485b3          	sub	a1,s1,s6
    8000187e:	8595                	srai	a1,a1,0x5
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
  for (p = proc; p < &proc[NPROC]; p++)
    800018a0:	1e048493          	addi	s1,s1,480
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
void procinit(void)
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
    800018ec:	47850513          	addi	a0,a0,1144 # 80010d60 <pid_lock>
    800018f0:	fffff097          	auipc	ra,0xfffff
    800018f4:	256080e7          	jalr	598(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f8:	00007597          	auipc	a1,0x7
    800018fc:	8f058593          	addi	a1,a1,-1808 # 800081e8 <digits+0x1a8>
    80001900:	0000f517          	auipc	a0,0xf
    80001904:	47850513          	addi	a0,a0,1144 # 80010d78 <wait_lock>
    80001908:	fffff097          	auipc	ra,0xfffff
    8000190c:	23e080e7          	jalr	574(ra) # 80000b46 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001910:	00010497          	auipc	s1,0x10
    80001914:	8b048493          	addi	s1,s1,-1872 # 800111c0 <proc>
  {
    initlock(&p->lock, "proc");
    80001918:	00007b17          	auipc	s6,0x7
    8000191c:	8e0b0b13          	addi	s6,s6,-1824 # 800081f8 <digits+0x1b8>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001920:	8aa6                	mv	s5,s1
    80001922:	00006a17          	auipc	s4,0x6
    80001926:	6dea0a13          	addi	s4,s4,1758 # 80008000 <etext>
    8000192a:	04000937          	lui	s2,0x4000
    8000192e:	197d                	addi	s2,s2,-1
    80001930:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001932:	00017997          	auipc	s3,0x17
    80001936:	08e98993          	addi	s3,s3,142 # 800189c0 <tickslock>
    initlock(&p->lock, "proc");
    8000193a:	85da                	mv	a1,s6
    8000193c:	8526                	mv	a0,s1
    8000193e:	fffff097          	auipc	ra,0xfffff
    80001942:	208080e7          	jalr	520(ra) # 80000b46 <initlock>
    p->state = UNUSED;
    80001946:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    8000194a:	415487b3          	sub	a5,s1,s5
    8000194e:	8795                	srai	a5,a5,0x5
    80001950:	000a3703          	ld	a4,0(s4)
    80001954:	02e787b3          	mul	a5,a5,a4
    80001958:	2785                	addiw	a5,a5,1
    8000195a:	00d7979b          	slliw	a5,a5,0xd
    8000195e:	40f907b3          	sub	a5,s2,a5
    80001962:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001964:	1e048493          	addi	s1,s1,480
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
int cpuid()
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
struct cpu *
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
    800019a0:	3f450513          	addi	a0,a0,1012 # 80010d90 <cpus>
    800019a4:	953e                	add	a0,a0,a5
    800019a6:	6422                	ld	s0,8(sp)
    800019a8:	0141                	addi	sp,sp,16
    800019aa:	8082                	ret

00000000800019ac <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
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
    800019c8:	39c70713          	addi	a4,a4,924 # 80010d60 <pid_lock>
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
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
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

  if (first)
    800019fc:	00007797          	auipc	a5,0x7
    80001a00:	f947a783          	lw	a5,-108(a5) # 80008990 <first.0>
    80001a04:	eb89                	bnez	a5,80001a16 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a06:	00001097          	auipc	ra,0x1
    80001a0a:	1d0080e7          	jalr	464(ra) # 80002bd6 <usertrapret>
}
    80001a0e:	60a2                	ld	ra,8(sp)
    80001a10:	6402                	ld	s0,0(sp)
    80001a12:	0141                	addi	sp,sp,16
    80001a14:	8082                	ret
    first = 0;
    80001a16:	00007797          	auipc	a5,0x7
    80001a1a:	f607ad23          	sw	zero,-134(a5) # 80008990 <first.0>
    fsinit(ROOTDEV);
    80001a1e:	4505                	li	a0,1
    80001a20:	00002097          	auipc	ra,0x2
    80001a24:	218080e7          	jalr	536(ra) # 80003c38 <fsinit>
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
    80001a3a:	32a90913          	addi	s2,s2,810 # 80010d60 <pid_lock>
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
  if (pagetable == 0)
    80001a88:	c121                	beqz	a0,80001ac8 <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
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
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
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
  if (p->trapframe)
    80001b6a:	6d28                	ld	a0,88(a0)
    80001b6c:	c509                	beqz	a0,80001b76 <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001b6e:	fffff097          	auipc	ra,0xfffff
    80001b72:	e7c080e7          	jalr	-388(ra) # 800009ea <kfree>
  p->trapframe = 0;
    80001b76:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
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
  for (p = proc; p < &proc[NPROC]; p++)
    80001bc2:	0000f497          	auipc	s1,0xf
    80001bc6:	5fe48493          	addi	s1,s1,1534 # 800111c0 <proc>
    80001bca:	00017917          	auipc	s2,0x17
    80001bce:	df690913          	addi	s2,s2,-522 # 800189c0 <tickslock>
    acquire(&p->lock);
    80001bd2:	8526                	mv	a0,s1
    80001bd4:	fffff097          	auipc	ra,0xfffff
    80001bd8:	002080e7          	jalr	2(ra) # 80000bd6 <acquire>
    if (p->state == UNUSED)
    80001bdc:	4c9c                	lw	a5,24(s1)
    80001bde:	cf81                	beqz	a5,80001bf6 <allocproc+0x40>
      release(&p->lock);
    80001be0:	8526                	mv	a0,s1
    80001be2:	fffff097          	auipc	ra,0xfffff
    80001be6:	0a8080e7          	jalr	168(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001bea:	1e048493          	addi	s1,s1,480
    80001bee:	ff2492e3          	bne	s1,s2,80001bd2 <allocproc+0x1c>
  return 0;
    80001bf2:	4481                	li	s1,0
    80001bf4:	a0e1                	j	80001cbc <allocproc+0x106>
  p->pid = allocpid();
    80001bf6:	00000097          	auipc	ra,0x0
    80001bfa:	e34080e7          	jalr	-460(ra) # 80001a2a <allocpid>
    80001bfe:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c00:	4785                	li	a5,1
    80001c02:	cc9c                	sw	a5,24(s1)
  p->time_created = ticks;
    80001c04:	00007797          	auipc	a5,0x7
    80001c08:	eec7e783          	lwu	a5,-276(a5) # 80008af0 <ticks>
    80001c0c:	16f4bc23          	sd	a5,376(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001c10:	fffff097          	auipc	ra,0xfffff
    80001c14:	ed6080e7          	jalr	-298(ra) # 80000ae6 <kalloc>
    80001c18:	892a                	mv	s2,a0
    80001c1a:	eca8                	sd	a0,88(s1)
    80001c1c:	c55d                	beqz	a0,80001cca <allocproc+0x114>
  p->pagetable = proc_pagetable(p);
    80001c1e:	8526                	mv	a0,s1
    80001c20:	00000097          	auipc	ra,0x0
    80001c24:	e50080e7          	jalr	-432(ra) # 80001a70 <proc_pagetable>
    80001c28:	892a                	mv	s2,a0
    80001c2a:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001c2c:	c95d                	beqz	a0,80001ce2 <allocproc+0x12c>
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
    80001c5e:	e967a783          	lw	a5,-362(a5) # 80008af0 <ticks>
    80001c62:	16f4a823          	sw	a5,368(s1)
  p->alarm_on = 0;
    80001c66:	1804ac23          	sw	zero,408(s1)
  p->cur_ticks = 0;
    80001c6a:	1804a623          	sw	zero,396(s1)
  p->runtime = 0;
    80001c6e:	1a04b423          	sd	zero,424(s1)
  p->starttime = 0;
    80001c72:	1a04b823          	sd	zero,432(s1)
  p->sleeptime = 0;
    80001c76:	1a04bc23          	sd	zero,440(s1)
  p->runcount = 0;
    80001c7a:	1c04b023          	sd	zero,448(s1)
  p->priority = 60;
    80001c7e:	03c00793          	li	a5,60
    80001c82:	1cf4b423          	sd	a5,456(s1)
  p->handlerpermission = 1;
    80001c86:	4785                	li	a5,1
    80001c88:	18f4ae23          	sw	a5,412(s1)
  p->tickets = 1;
    80001c8c:	1af4a023          	sw	a5,416(s1)
  p->tickcount = 0;
    80001c90:	1c04a823          	sw	zero,464(s1)
  p->queue = 0;
    80001c94:	1c04aa23          	sw	zero,468(s1)
  p->waittickcount = 0;
    80001c98:	1c04ac23          	sw	zero,472(s1)
  p->queueposition = queueprocesscount[0];
    80001c9c:	0000f797          	auipc	a5,0xf
    80001ca0:	0c478793          	addi	a5,a5,196 # 80010d60 <pid_lock>
    80001ca4:	4307a703          	lw	a4,1072(a5)
    80001ca8:	1ce4ae23          	sw	a4,476(s1)
  queueprocesscount[0]++;
    80001cac:	2705                	addiw	a4,a4,1
    80001cae:	42e7a823          	sw	a4,1072(a5)
  queuemaxindex[0]++;
    80001cb2:	4487a703          	lw	a4,1096(a5)
    80001cb6:	2705                	addiw	a4,a4,1
    80001cb8:	44e7a423          	sw	a4,1096(a5)
}
    80001cbc:	8526                	mv	a0,s1
    80001cbe:	60e2                	ld	ra,24(sp)
    80001cc0:	6442                	ld	s0,16(sp)
    80001cc2:	64a2                	ld	s1,8(sp)
    80001cc4:	6902                	ld	s2,0(sp)
    80001cc6:	6105                	addi	sp,sp,32
    80001cc8:	8082                	ret
    freeproc(p);
    80001cca:	8526                	mv	a0,s1
    80001ccc:	00000097          	auipc	ra,0x0
    80001cd0:	e92080e7          	jalr	-366(ra) # 80001b5e <freeproc>
    release(&p->lock);
    80001cd4:	8526                	mv	a0,s1
    80001cd6:	fffff097          	auipc	ra,0xfffff
    80001cda:	fb4080e7          	jalr	-76(ra) # 80000c8a <release>
    return 0;
    80001cde:	84ca                	mv	s1,s2
    80001ce0:	bff1                	j	80001cbc <allocproc+0x106>
    freeproc(p);
    80001ce2:	8526                	mv	a0,s1
    80001ce4:	00000097          	auipc	ra,0x0
    80001ce8:	e7a080e7          	jalr	-390(ra) # 80001b5e <freeproc>
    release(&p->lock);
    80001cec:	8526                	mv	a0,s1
    80001cee:	fffff097          	auipc	ra,0xfffff
    80001cf2:	f9c080e7          	jalr	-100(ra) # 80000c8a <release>
    return 0;
    80001cf6:	84ca                	mv	s1,s2
    80001cf8:	b7d1                	j	80001cbc <allocproc+0x106>

0000000080001cfa <userinit>:
{
    80001cfa:	1101                	addi	sp,sp,-32
    80001cfc:	ec06                	sd	ra,24(sp)
    80001cfe:	e822                	sd	s0,16(sp)
    80001d00:	e426                	sd	s1,8(sp)
    80001d02:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d04:	00000097          	auipc	ra,0x0
    80001d08:	eb2080e7          	jalr	-334(ra) # 80001bb6 <allocproc>
    80001d0c:	84aa                	mv	s1,a0
  initproc = p;
    80001d0e:	00007797          	auipc	a5,0x7
    80001d12:	dca7bd23          	sd	a0,-550(a5) # 80008ae8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001d16:	03400613          	li	a2,52
    80001d1a:	00007597          	auipc	a1,0x7
    80001d1e:	c8658593          	addi	a1,a1,-890 # 800089a0 <initcode>
    80001d22:	6928                	ld	a0,80(a0)
    80001d24:	fffff097          	auipc	ra,0xfffff
    80001d28:	632080e7          	jalr	1586(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80001d2c:	6785                	lui	a5,0x1
    80001d2e:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001d30:	6cb8                	ld	a4,88(s1)
    80001d32:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001d36:	6cb8                	ld	a4,88(s1)
    80001d38:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d3a:	4641                	li	a2,16
    80001d3c:	00006597          	auipc	a1,0x6
    80001d40:	4c458593          	addi	a1,a1,1220 # 80008200 <digits+0x1c0>
    80001d44:	15848513          	addi	a0,s1,344
    80001d48:	fffff097          	auipc	ra,0xfffff
    80001d4c:	0d4080e7          	jalr	212(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001d50:	00006517          	auipc	a0,0x6
    80001d54:	4c050513          	addi	a0,a0,1216 # 80008210 <digits+0x1d0>
    80001d58:	00003097          	auipc	ra,0x3
    80001d5c:	902080e7          	jalr	-1790(ra) # 8000465a <namei>
    80001d60:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d64:	478d                	li	a5,3
    80001d66:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d68:	8526                	mv	a0,s1
    80001d6a:	fffff097          	auipc	ra,0xfffff
    80001d6e:	f20080e7          	jalr	-224(ra) # 80000c8a <release>
}
    80001d72:	60e2                	ld	ra,24(sp)
    80001d74:	6442                	ld	s0,16(sp)
    80001d76:	64a2                	ld	s1,8(sp)
    80001d78:	6105                	addi	sp,sp,32
    80001d7a:	8082                	ret

0000000080001d7c <growproc>:
{
    80001d7c:	1101                	addi	sp,sp,-32
    80001d7e:	ec06                	sd	ra,24(sp)
    80001d80:	e822                	sd	s0,16(sp)
    80001d82:	e426                	sd	s1,8(sp)
    80001d84:	e04a                	sd	s2,0(sp)
    80001d86:	1000                	addi	s0,sp,32
    80001d88:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d8a:	00000097          	auipc	ra,0x0
    80001d8e:	c22080e7          	jalr	-990(ra) # 800019ac <myproc>
    80001d92:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d94:	652c                	ld	a1,72(a0)
  if (n > 0)
    80001d96:	01204c63          	bgtz	s2,80001dae <growproc+0x32>
  else if (n < 0)
    80001d9a:	02094663          	bltz	s2,80001dc6 <growproc+0x4a>
  p->sz = sz;
    80001d9e:	e4ac                	sd	a1,72(s1)
  return 0;
    80001da0:	4501                	li	a0,0
}
    80001da2:	60e2                	ld	ra,24(sp)
    80001da4:	6442                	ld	s0,16(sp)
    80001da6:	64a2                	ld	s1,8(sp)
    80001da8:	6902                	ld	s2,0(sp)
    80001daa:	6105                	addi	sp,sp,32
    80001dac:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001dae:	4691                	li	a3,4
    80001db0:	00b90633          	add	a2,s2,a1
    80001db4:	6928                	ld	a0,80(a0)
    80001db6:	fffff097          	auipc	ra,0xfffff
    80001dba:	65a080e7          	jalr	1626(ra) # 80001410 <uvmalloc>
    80001dbe:	85aa                	mv	a1,a0
    80001dc0:	fd79                	bnez	a0,80001d9e <growproc+0x22>
      return -1;
    80001dc2:	557d                	li	a0,-1
    80001dc4:	bff9                	j	80001da2 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001dc6:	00b90633          	add	a2,s2,a1
    80001dca:	6928                	ld	a0,80(a0)
    80001dcc:	fffff097          	auipc	ra,0xfffff
    80001dd0:	5fc080e7          	jalr	1532(ra) # 800013c8 <uvmdealloc>
    80001dd4:	85aa                	mv	a1,a0
    80001dd6:	b7e1                	j	80001d9e <growproc+0x22>

0000000080001dd8 <fork>:
{
    80001dd8:	7139                	addi	sp,sp,-64
    80001dda:	fc06                	sd	ra,56(sp)
    80001ddc:	f822                	sd	s0,48(sp)
    80001dde:	f426                	sd	s1,40(sp)
    80001de0:	f04a                	sd	s2,32(sp)
    80001de2:	ec4e                	sd	s3,24(sp)
    80001de4:	e852                	sd	s4,16(sp)
    80001de6:	e456                	sd	s5,8(sp)
    80001de8:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001dea:	00000097          	auipc	ra,0x0
    80001dee:	bc2080e7          	jalr	-1086(ra) # 800019ac <myproc>
    80001df2:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80001df4:	00000097          	auipc	ra,0x0
    80001df8:	dc2080e7          	jalr	-574(ra) # 80001bb6 <allocproc>
    80001dfc:	12050463          	beqz	a0,80001f24 <fork+0x14c>
    80001e00:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001e02:	048ab603          	ld	a2,72(s5)
    80001e06:	692c                	ld	a1,80(a0)
    80001e08:	050ab503          	ld	a0,80(s5)
    80001e0c:	fffff097          	auipc	ra,0xfffff
    80001e10:	758080e7          	jalr	1880(ra) # 80001564 <uvmcopy>
    80001e14:	04054c63          	bltz	a0,80001e6c <fork+0x94>
  np->sz = p->sz;
    80001e18:	048ab783          	ld	a5,72(s5)
    80001e1c:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001e20:	058ab683          	ld	a3,88(s5)
    80001e24:	87b6                	mv	a5,a3
    80001e26:	0589b703          	ld	a4,88(s3)
    80001e2a:	12068693          	addi	a3,a3,288
    80001e2e:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e32:	6788                	ld	a0,8(a5)
    80001e34:	6b8c                	ld	a1,16(a5)
    80001e36:	6f90                	ld	a2,24(a5)
    80001e38:	01073023          	sd	a6,0(a4)
    80001e3c:	e708                	sd	a0,8(a4)
    80001e3e:	eb0c                	sd	a1,16(a4)
    80001e40:	ef10                	sd	a2,24(a4)
    80001e42:	02078793          	addi	a5,a5,32
    80001e46:	02070713          	addi	a4,a4,32
    80001e4a:	fed792e3          	bne	a5,a3,80001e2e <fork+0x56>
  np->mask = p->mask;
    80001e4e:	168aa783          	lw	a5,360(s5)
    80001e52:	16f9a423          	sw	a5,360(s3)
  np->trapframe->a0 = 0;
    80001e56:	0589b783          	ld	a5,88(s3)
    80001e5a:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001e5e:	0d0a8493          	addi	s1,s5,208
    80001e62:	0d098913          	addi	s2,s3,208
    80001e66:	150a8a13          	addi	s4,s5,336
    80001e6a:	a00d                	j	80001e8c <fork+0xb4>
    freeproc(np);
    80001e6c:	854e                	mv	a0,s3
    80001e6e:	00000097          	auipc	ra,0x0
    80001e72:	cf0080e7          	jalr	-784(ra) # 80001b5e <freeproc>
    release(&np->lock);
    80001e76:	854e                	mv	a0,s3
    80001e78:	fffff097          	auipc	ra,0xfffff
    80001e7c:	e12080e7          	jalr	-494(ra) # 80000c8a <release>
    return -1;
    80001e80:	597d                	li	s2,-1
    80001e82:	a079                	j	80001f10 <fork+0x138>
  for (i = 0; i < NOFILE; i++)
    80001e84:	04a1                	addi	s1,s1,8
    80001e86:	0921                	addi	s2,s2,8
    80001e88:	01448b63          	beq	s1,s4,80001e9e <fork+0xc6>
    if (p->ofile[i])
    80001e8c:	6088                	ld	a0,0(s1)
    80001e8e:	d97d                	beqz	a0,80001e84 <fork+0xac>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e90:	00003097          	auipc	ra,0x3
    80001e94:	e60080e7          	jalr	-416(ra) # 80004cf0 <filedup>
    80001e98:	00a93023          	sd	a0,0(s2)
    80001e9c:	b7e5                	j	80001e84 <fork+0xac>
  np->cwd = idup(p->cwd);
    80001e9e:	150ab503          	ld	a0,336(s5)
    80001ea2:	00002097          	auipc	ra,0x2
    80001ea6:	fd4080e7          	jalr	-44(ra) # 80003e76 <idup>
    80001eaa:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001eae:	4641                	li	a2,16
    80001eb0:	158a8593          	addi	a1,s5,344
    80001eb4:	15898513          	addi	a0,s3,344
    80001eb8:	fffff097          	auipc	ra,0xfffff
    80001ebc:	f64080e7          	jalr	-156(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    80001ec0:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001ec4:	854e                	mv	a0,s3
    80001ec6:	fffff097          	auipc	ra,0xfffff
    80001eca:	dc4080e7          	jalr	-572(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80001ece:	0000f497          	auipc	s1,0xf
    80001ed2:	eaa48493          	addi	s1,s1,-342 # 80010d78 <wait_lock>
    80001ed6:	8526                	mv	a0,s1
    80001ed8:	fffff097          	auipc	ra,0xfffff
    80001edc:	cfe080e7          	jalr	-770(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001ee0:	0359bc23          	sd	s5,56(s3)
  np->tickets = np->parent->tickets;
    80001ee4:	1a0aa783          	lw	a5,416(s5)
    80001ee8:	1af9a023          	sw	a5,416(s3)
  release(&wait_lock);
    80001eec:	8526                	mv	a0,s1
    80001eee:	fffff097          	auipc	ra,0xfffff
    80001ef2:	d9c080e7          	jalr	-612(ra) # 80000c8a <release>
  acquire(&np->lock);
    80001ef6:	854e                	mv	a0,s3
    80001ef8:	fffff097          	auipc	ra,0xfffff
    80001efc:	cde080e7          	jalr	-802(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80001f00:	478d                	li	a5,3
    80001f02:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001f06:	854e                	mv	a0,s3
    80001f08:	fffff097          	auipc	ra,0xfffff
    80001f0c:	d82080e7          	jalr	-638(ra) # 80000c8a <release>
}
    80001f10:	854a                	mv	a0,s2
    80001f12:	70e2                	ld	ra,56(sp)
    80001f14:	7442                	ld	s0,48(sp)
    80001f16:	74a2                	ld	s1,40(sp)
    80001f18:	7902                	ld	s2,32(sp)
    80001f1a:	69e2                	ld	s3,24(sp)
    80001f1c:	6a42                	ld	s4,16(sp)
    80001f1e:	6aa2                	ld	s5,8(sp)
    80001f20:	6121                	addi	sp,sp,64
    80001f22:	8082                	ret
    return -1;
    80001f24:	597d                	li	s2,-1
    80001f26:	b7ed                	j	80001f10 <fork+0x138>

0000000080001f28 <max>:
{
    80001f28:	1141                	addi	sp,sp,-16
    80001f2a:	e422                	sd	s0,8(sp)
    80001f2c:	0800                	addi	s0,sp,16
}
    80001f2e:	87aa                	mv	a5,a0
    80001f30:	00b55363          	bge	a0,a1,80001f36 <max+0xe>
    80001f34:	87ae                	mv	a5,a1
    80001f36:	0007851b          	sext.w	a0,a5
    80001f3a:	6422                	ld	s0,8(sp)
    80001f3c:	0141                	addi	sp,sp,16
    80001f3e:	8082                	ret

0000000080001f40 <min>:
{
    80001f40:	1141                	addi	sp,sp,-16
    80001f42:	e422                	sd	s0,8(sp)
    80001f44:	0800                	addi	s0,sp,16
}
    80001f46:	87aa                	mv	a5,a0
    80001f48:	00a5d363          	bge	a1,a0,80001f4e <min+0xe>
    80001f4c:	87ae                	mv	a5,a1
    80001f4e:	0007851b          	sext.w	a0,a5
    80001f52:	6422                	ld	s0,8(sp)
    80001f54:	0141                	addi	sp,sp,16
    80001f56:	8082                	ret

0000000080001f58 <update_time>:
{
    80001f58:	7179                	addi	sp,sp,-48
    80001f5a:	f406                	sd	ra,40(sp)
    80001f5c:	f022                	sd	s0,32(sp)
    80001f5e:	ec26                	sd	s1,24(sp)
    80001f60:	e84a                	sd	s2,16(sp)
    80001f62:	e44e                	sd	s3,8(sp)
    80001f64:	1800                	addi	s0,sp,48
  for (p = proc; p < &proc[NPROC]; p++)
    80001f66:	0000f497          	auipc	s1,0xf
    80001f6a:	25a48493          	addi	s1,s1,602 # 800111c0 <proc>
    if (p->state == RUNNING)
    80001f6e:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++)
    80001f70:	00017917          	auipc	s2,0x17
    80001f74:	a5090913          	addi	s2,s2,-1456 # 800189c0 <tickslock>
    80001f78:	a811                	j	80001f8c <update_time+0x34>
    release(&p->lock);
    80001f7a:	8526                	mv	a0,s1
    80001f7c:	fffff097          	auipc	ra,0xfffff
    80001f80:	d0e080e7          	jalr	-754(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001f84:	1e048493          	addi	s1,s1,480
    80001f88:	03248063          	beq	s1,s2,80001fa8 <update_time+0x50>
    acquire(&p->lock);
    80001f8c:	8526                	mv	a0,s1
    80001f8e:	fffff097          	auipc	ra,0xfffff
    80001f92:	c48080e7          	jalr	-952(ra) # 80000bd6 <acquire>
    if (p->state == RUNNING)
    80001f96:	4c9c                	lw	a5,24(s1)
    80001f98:	ff3791e3          	bne	a5,s3,80001f7a <update_time+0x22>
      p->rtime++;
    80001f9c:	16c4a783          	lw	a5,364(s1)
    80001fa0:	2785                	addiw	a5,a5,1
    80001fa2:	16f4a623          	sw	a5,364(s1)
    80001fa6:	bfd1                	j	80001f7a <update_time+0x22>
}
    80001fa8:	70a2                	ld	ra,40(sp)
    80001faa:	7402                	ld	s0,32(sp)
    80001fac:	64e2                	ld	s1,24(sp)
    80001fae:	6942                	ld	s2,16(sp)
    80001fb0:	69a2                	ld	s3,8(sp)
    80001fb2:	6145                	addi	sp,sp,48
    80001fb4:	8082                	ret

0000000080001fb6 <randomnum>:
{
    80001fb6:	1141                	addi	sp,sp,-16
    80001fb8:	e422                	sd	s0,8(sp)
    80001fba:	0800                	addi	s0,sp,16
  uint64 num = (uint64)ticks;
    80001fbc:	00007797          	auipc	a5,0x7
    80001fc0:	b347e783          	lwu	a5,-1228(a5) # 80008af0 <ticks>
  num = num ^ (num << 13);
    80001fc4:	00d79713          	slli	a4,a5,0xd
    80001fc8:	8fb9                	xor	a5,a5,a4
  num = num ^ (num >> 17);
    80001fca:	0117d713          	srli	a4,a5,0x11
    80001fce:	8f3d                	xor	a4,a4,a5
  num = num ^ (num << 5);
    80001fd0:	00571793          	slli	a5,a4,0x5
    80001fd4:	8fb9                	xor	a5,a5,a4
  num = num % (max - min);
    80001fd6:	9d89                	subw	a1,a1,a0
    80001fd8:	02b7f7b3          	remu	a5,a5,a1
}
    80001fdc:	9d3d                	addw	a0,a0,a5
    80001fde:	6422                	ld	s0,8(sp)
    80001fe0:	0141                	addi	sp,sp,16
    80001fe2:	8082                	ret

0000000080001fe4 <scheduler>:
{
    80001fe4:	7175                	addi	sp,sp,-144
    80001fe6:	e506                	sd	ra,136(sp)
    80001fe8:	e122                	sd	s0,128(sp)
    80001fea:	fca6                	sd	s1,120(sp)
    80001fec:	f8ca                	sd	s2,112(sp)
    80001fee:	f4ce                	sd	s3,104(sp)
    80001ff0:	f0d2                	sd	s4,96(sp)
    80001ff2:	ecd6                	sd	s5,88(sp)
    80001ff4:	e8da                	sd	s6,80(sp)
    80001ff6:	e4de                	sd	s7,72(sp)
    80001ff8:	e0e2                	sd	s8,64(sp)
    80001ffa:	fc66                	sd	s9,56(sp)
    80001ffc:	f86a                	sd	s10,48(sp)
    80001ffe:	f46e                	sd	s11,40(sp)
    80002000:	0900                	addi	s0,sp,144
    80002002:	8792                	mv	a5,tp
  int id = r_tp();
    80002004:	2781                	sext.w	a5,a5
  int maxticks[5] = {1, 2, 4, 8, 16};
    80002006:	4705                	li	a4,1
    80002008:	f6e42c23          	sw	a4,-136(s0)
    8000200c:	4709                	li	a4,2
    8000200e:	f6e42e23          	sw	a4,-132(s0)
    80002012:	4711                	li	a4,4
    80002014:	f8e42023          	sw	a4,-128(s0)
    80002018:	4721                	li	a4,8
    8000201a:	f8e42223          	sw	a4,-124(s0)
    8000201e:	4741                	li	a4,16
    80002020:	f8e42423          	sw	a4,-120(s0)
  c->proc = 0;
    80002024:	00779b93          	slli	s7,a5,0x7
    80002028:	0000f717          	auipc	a4,0xf
    8000202c:	d3870713          	addi	a4,a4,-712 # 80010d60 <pid_lock>
    80002030:	975e                	add	a4,a4,s7
    80002032:	02073823          	sd	zero,48(a4)
          swtch(&c->context, &p->context);
    80002036:	0000f717          	auipc	a4,0xf
    8000203a:	d6270713          	addi	a4,a4,-670 # 80010d98 <cpus+0x8>
    8000203e:	9bba                	add	s7,s7,a4
    for (p = proc; p < &proc[NPROC]; p++)
    80002040:	00017997          	auipc	s3,0x17
    80002044:	98098993          	addi	s3,s3,-1664 # 800189c0 <tickslock>
      int minqueueval = 1000000;
    80002048:	000f4737          	lui	a4,0xf4
    8000204c:	24070d93          	addi	s11,a4,576 # f4240 <_entry-0x7ff0bdc0>
              queueprocesscount[p->queue]--;
    80002050:	0000fa97          	auipc	s5,0xf
    80002054:	d10a8a93          	addi	s5,s5,-752 # 80010d60 <pid_lock>
          c->proc = p;
    80002058:	079e                	slli	a5,a5,0x7
    8000205a:	00fa8b33          	add	s6,s5,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000205e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002062:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002066:	10079073          	csrw	sstatus,a5
    int minqueue = 5;
    8000206a:	4a15                	li	s4,5
    for (p = proc; p < &proc[NPROC]; p++)
    8000206c:	0000f497          	auipc	s1,0xf
    80002070:	15448493          	addi	s1,s1,340 # 800111c0 <proc>
      if (p->state == RUNNABLE && p->queue < minqueue)
    80002074:	490d                	li	s2,3
    80002076:	a821                	j	8000208e <scheduler+0xaa>
    80002078:	00078a1b          	sext.w	s4,a5
      release(&p->lock);
    8000207c:	8526                	mv	a0,s1
    8000207e:	fffff097          	auipc	ra,0xfffff
    80002082:	c0c080e7          	jalr	-1012(ra) # 80000c8a <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002086:	1e048493          	addi	s1,s1,480
    8000208a:	03348263          	beq	s1,s3,800020ae <scheduler+0xca>
      acquire(&p->lock);
    8000208e:	8526                	mv	a0,s1
    80002090:	fffff097          	auipc	ra,0xfffff
    80002094:	b46080e7          	jalr	-1210(ra) # 80000bd6 <acquire>
      if (p->state == RUNNABLE && p->queue < minqueue)
    80002098:	4c9c                	lw	a5,24(s1)
    8000209a:	ff2791e3          	bne	a5,s2,8000207c <scheduler+0x98>
    8000209e:	1d44a783          	lw	a5,468(s1)
    800020a2:	0007871b          	sext.w	a4,a5
    800020a6:	fcea59e3          	bge	s4,a4,80002078 <scheduler+0x94>
    800020aa:	87d2                	mv	a5,s4
    800020ac:	b7f1                	j	80002078 <scheduler+0x94>
    if (minqueue == 4)
    800020ae:	4791                	li	a5,4
    800020b0:	0cfa1c63          	bne	s4,a5,80002188 <scheduler+0x1a4>
      for (p = proc; p < &proc[NPROC]; p++)
    800020b4:	0000f917          	auipc	s2,0xf
    800020b8:	10c90913          	addi	s2,s2,268 # 800111c0 <proc>
        if (p->state == RUNNABLE)
    800020bc:	4a0d                	li	s4,3
              if (q->waittickcount >= 30)
    800020be:	4c75                	li	s8,29
    800020c0:	a841                	j	80002150 <scheduler+0x16c>
              release(&q->lock);
    800020c2:	8526                	mv	a0,s1
    800020c4:	fffff097          	auipc	ra,0xfffff
    800020c8:	bc6080e7          	jalr	-1082(ra) # 80000c8a <release>
          for (q = proc; q < &proc[NPROC]; q++)
    800020cc:	1e048493          	addi	s1,s1,480
    800020d0:	07348763          	beq	s1,s3,8000213e <scheduler+0x15a>
            if (p != q && q->state == RUNNABLE)
    800020d4:	fe990ce3          	beq	s2,s1,800020cc <scheduler+0xe8>
    800020d8:	4c9c                	lw	a5,24(s1)
    800020da:	ff4799e3          	bne	a5,s4,800020cc <scheduler+0xe8>
              acquire(&q->lock);
    800020de:	8526                	mv	a0,s1
    800020e0:	fffff097          	auipc	ra,0xfffff
    800020e4:	af6080e7          	jalr	-1290(ra) # 80000bd6 <acquire>
              q->waittickcount++;
    800020e8:	1d84a783          	lw	a5,472(s1)
    800020ec:	2785                	addiw	a5,a5,1
    800020ee:	0007871b          	sext.w	a4,a5
    800020f2:	1cf4ac23          	sw	a5,472(s1)
              if (q->waittickcount >= 30)
    800020f6:	fcec56e3          	bge	s8,a4,800020c2 <scheduler+0xde>
                queueprocesscount[q->queue]--;
    800020fa:	1d44a703          	lw	a4,468(s1)
    800020fe:	00271793          	slli	a5,a4,0x2
    80002102:	97d6                	add	a5,a5,s5
    80002104:	4307a683          	lw	a3,1072(a5)
    80002108:	36fd                	addiw	a3,a3,-1
    8000210a:	42d7a823          	sw	a3,1072(a5)
                q->queue--;
    8000210e:	377d                	addiw	a4,a4,-1
    80002110:	0007079b          	sext.w	a5,a4
    80002114:	1ce4aa23          	sw	a4,468(s1)
                queueprocesscount[q->queue]++;
    80002118:	078a                	slli	a5,a5,0x2
    8000211a:	97d6                	add	a5,a5,s5
    8000211c:	4307a703          	lw	a4,1072(a5)
    80002120:	2705                	addiw	a4,a4,1
    80002122:	42e7a823          	sw	a4,1072(a5)
                q->tickcount = 0;
    80002126:	1c04a823          	sw	zero,464(s1)
                q->waittickcount = 0;
    8000212a:	1c04ac23          	sw	zero,472(s1)
                q->queueposition = queuemaxindex[q->queue];
    8000212e:	4487a703          	lw	a4,1096(a5)
    80002132:	1ce4ae23          	sw	a4,476(s1)
                queuemaxindex[q->queue]++;
    80002136:	2705                	addiw	a4,a4,1
    80002138:	44e7a423          	sw	a4,1096(a5)
    8000213c:	b759                	j	800020c2 <scheduler+0xde>
        release(&p->lock);
    8000213e:	854a                	mv	a0,s2
    80002140:	fffff097          	auipc	ra,0xfffff
    80002144:	b4a080e7          	jalr	-1206(ra) # 80000c8a <release>
      for (p = proc; p < &proc[NPROC]; p++)
    80002148:	1e090913          	addi	s2,s2,480
    8000214c:	f13909e3          	beq	s2,s3,8000205e <scheduler+0x7a>
        acquire(&p->lock);
    80002150:	854a                	mv	a0,s2
    80002152:	fffff097          	auipc	ra,0xfffff
    80002156:	a84080e7          	jalr	-1404(ra) # 80000bd6 <acquire>
        if (p->state == RUNNABLE)
    8000215a:	01892783          	lw	a5,24(s2)
    8000215e:	ff4790e3          	bne	a5,s4,8000213e <scheduler+0x15a>
          p->state = RUNNING;
    80002162:	4791                	li	a5,4
    80002164:	00f92c23          	sw	a5,24(s2)
          c->proc = p;
    80002168:	032b3823          	sd	s2,48(s6)
          swtch(&c->context, &p->context);
    8000216c:	06090593          	addi	a1,s2,96
    80002170:	855e                	mv	a0,s7
    80002172:	00001097          	auipc	ra,0x1
    80002176:	9ba080e7          	jalr	-1606(ra) # 80002b2c <swtch>
          c->proc = 0;
    8000217a:	020b3823          	sd	zero,48(s6)
          for (q = proc; q < &proc[NPROC]; q++)
    8000217e:	0000f497          	auipc	s1,0xf
    80002182:	04248493          	addi	s1,s1,66 # 800111c0 <proc>
    80002186:	b7b9                	j	800020d4 <scheduler+0xf0>
      struct proc *run_process = 0;
    80002188:	4c01                	li	s8,0
      int minqueueval = 1000000;
    8000218a:	8cee                	mv	s9,s11
      for (p = proc; p < &proc[NPROC]; p++)
    8000218c:	0000f497          	auipc	s1,0xf
    80002190:	03448493          	addi	s1,s1,52 # 800111c0 <proc>
        if (p->state == RUNNABLE && p->queue == minqueue)
    80002194:	490d                	li	s2,3
    80002196:	a811                	j	800021aa <scheduler+0x1c6>
        release(&p->lock);
    80002198:	8526                	mv	a0,s1
    8000219a:	fffff097          	auipc	ra,0xfffff
    8000219e:	af0080e7          	jalr	-1296(ra) # 80000c8a <release>
      for (p = proc; p < &proc[NPROC]; p++)
    800021a2:	1e048493          	addi	s1,s1,480
    800021a6:	03348563          	beq	s1,s3,800021d0 <scheduler+0x1ec>
        acquire(&p->lock);
    800021aa:	8526                	mv	a0,s1
    800021ac:	fffff097          	auipc	ra,0xfffff
    800021b0:	a2a080e7          	jalr	-1494(ra) # 80000bd6 <acquire>
        if (p->state == RUNNABLE && p->queue == minqueue)
    800021b4:	4c9c                	lw	a5,24(s1)
    800021b6:	ff2791e3          	bne	a5,s2,80002198 <scheduler+0x1b4>
    800021ba:	1d44a783          	lw	a5,468(s1)
    800021be:	fd479de3          	bne	a5,s4,80002198 <scheduler+0x1b4>
          if (p->queueposition < minqueueval)
    800021c2:	1dc4a783          	lw	a5,476(s1)
    800021c6:	fd97d9e3          	bge	a5,s9,80002198 <scheduler+0x1b4>
    800021ca:	8c26                	mv	s8,s1
            minqueueval = p->queueposition;
    800021cc:	8cbe                	mv	s9,a5
    800021ce:	b7e9                	j	80002198 <scheduler+0x1b4>
      for (p = proc; p < &proc[NPROC]; p++)
    800021d0:	0000f497          	auipc	s1,0xf
    800021d4:	ff048493          	addi	s1,s1,-16 # 800111c0 <proc>
        if (p->state == RUNNABLE && p == run_process)
    800021d8:	4a0d                	li	s4,3
            if (p->waittickcount >= 30)
    800021da:	4cf5                	li	s9,29
          p->state = RUNNING;
    800021dc:	4d11                	li	s10,4
    800021de:	a851                	j	80002272 <scheduler+0x28e>
    800021e0:	01a4ac23          	sw	s10,24(s1)
          c->proc = p;
    800021e4:	029b3823          	sd	s1,48(s6)
          swtch(&c->context, &p->context);
    800021e8:	06048593          	addi	a1,s1,96
    800021ec:	855e                	mv	a0,s7
    800021ee:	00001097          	auipc	ra,0x1
    800021f2:	93e080e7          	jalr	-1730(ra) # 80002b2c <swtch>
          c->proc = 0;
    800021f6:	020b3823          	sd	zero,48(s6)
          p->tickcount++;
    800021fa:	1d04a783          	lw	a5,464(s1)
    800021fe:	2785                	addiw	a5,a5,1
    80002200:	0007869b          	sext.w	a3,a5
    80002204:	1cf4a823          	sw	a5,464(s1)
          if (p->tickcount >= maxticks[p->queue] && p->queue != 4)
    80002208:	1d44a703          	lw	a4,468(s1)
    8000220c:	00271793          	slli	a5,a4,0x2
    80002210:	f9040613          	addi	a2,s0,-112
    80002214:	97b2                	add	a5,a5,a2
    80002216:	fe87a783          	lw	a5,-24(a5)
    8000221a:	04f6c163          	blt	a3,a5,8000225c <scheduler+0x278>
    8000221e:	03a70f63          	beq	a4,s10,8000225c <scheduler+0x278>
            queueprocesscount[p->queue]--;
    80002222:	00271793          	slli	a5,a4,0x2
    80002226:	97d6                	add	a5,a5,s5
    80002228:	4307a683          	lw	a3,1072(a5)
    8000222c:	36fd                	addiw	a3,a3,-1
    8000222e:	42d7a823          	sw	a3,1072(a5)
            p->queue++;
    80002232:	2705                	addiw	a4,a4,1
    80002234:	0007079b          	sext.w	a5,a4
    80002238:	1ce4aa23          	sw	a4,468(s1)
            queueprocesscount[p->queue]++;
    8000223c:	078a                	slli	a5,a5,0x2
    8000223e:	97d6                	add	a5,a5,s5
    80002240:	4307a703          	lw	a4,1072(a5)
    80002244:	2705                	addiw	a4,a4,1
    80002246:	42e7a823          	sw	a4,1072(a5)
            p->tickcount = 0;
    8000224a:	1c04a823          	sw	zero,464(s1)
            p->queueposition = queuemaxindex[p->queue];
    8000224e:	4487a703          	lw	a4,1096(a5)
    80002252:	1ce4ae23          	sw	a4,476(s1)
            queuemaxindex[p->queue]++;
    80002256:	2705                	addiw	a4,a4,1
    80002258:	44e7a423          	sw	a4,1096(a5)
          p->waittickcount = 0;
    8000225c:	1c04ac23          	sw	zero,472(s1)
        release(&p->lock);
    80002260:	8526                	mv	a0,s1
    80002262:	fffff097          	auipc	ra,0xfffff
    80002266:	a28080e7          	jalr	-1496(ra) # 80000c8a <release>
      for (p = proc; p < &proc[NPROC]; p++)
    8000226a:	1e048493          	addi	s1,s1,480
    8000226e:	df3488e3          	beq	s1,s3,8000205e <scheduler+0x7a>
        acquire(&p->lock);
    80002272:	8526                	mv	a0,s1
    80002274:	fffff097          	auipc	ra,0xfffff
    80002278:	962080e7          	jalr	-1694(ra) # 80000bd6 <acquire>
        if (p->state == RUNNABLE && p == run_process)
    8000227c:	4c9c                	lw	a5,24(s1)
    8000227e:	ff4791e3          	bne	a5,s4,80002260 <scheduler+0x27c>
    80002282:	f49c0fe3          	beq	s8,s1,800021e0 <scheduler+0x1fc>
          p->waittickcount++;
    80002286:	1d84a783          	lw	a5,472(s1)
    8000228a:	2785                	addiw	a5,a5,1
    8000228c:	0007871b          	sext.w	a4,a5
    80002290:	1cf4ac23          	sw	a5,472(s1)
          if (p->queue != 0)
    80002294:	1d44a783          	lw	a5,468(s1)
    80002298:	d7e1                	beqz	a5,80002260 <scheduler+0x27c>
            if (p->waittickcount >= 30)
    8000229a:	fcecd3e3          	bge	s9,a4,80002260 <scheduler+0x27c>
              queueprocesscount[p->queue]--;
    8000229e:	00279713          	slli	a4,a5,0x2
    800022a2:	9756                	add	a4,a4,s5
    800022a4:	43072683          	lw	a3,1072(a4)
    800022a8:	36fd                	addiw	a3,a3,-1
    800022aa:	42d72823          	sw	a3,1072(a4)
              p->queue--;
    800022ae:	37fd                	addiw	a5,a5,-1
    800022b0:	0007871b          	sext.w	a4,a5
    800022b4:	1cf4aa23          	sw	a5,468(s1)
              queueprocesscount[p->queue]++;
    800022b8:	00271793          	slli	a5,a4,0x2
    800022bc:	97d6                	add	a5,a5,s5
    800022be:	4307a703          	lw	a4,1072(a5)
    800022c2:	2705                	addiw	a4,a4,1
    800022c4:	42e7a823          	sw	a4,1072(a5)
              p->tickcount = 0;
    800022c8:	1c04a823          	sw	zero,464(s1)
              p->waittickcount = 0;
    800022cc:	1c04ac23          	sw	zero,472(s1)
              p->queueposition = queuemaxindex[p->queue];
    800022d0:	4487a703          	lw	a4,1096(a5)
    800022d4:	1ce4ae23          	sw	a4,476(s1)
              queuemaxindex[p->queue]++;
    800022d8:	2705                	addiw	a4,a4,1
    800022da:	44e7a423          	sw	a4,1096(a5)
    800022de:	b749                	j	80002260 <scheduler+0x27c>

00000000800022e0 <sched>:
{
    800022e0:	7179                	addi	sp,sp,-48
    800022e2:	f406                	sd	ra,40(sp)
    800022e4:	f022                	sd	s0,32(sp)
    800022e6:	ec26                	sd	s1,24(sp)
    800022e8:	e84a                	sd	s2,16(sp)
    800022ea:	e44e                	sd	s3,8(sp)
    800022ec:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800022ee:	fffff097          	auipc	ra,0xfffff
    800022f2:	6be080e7          	jalr	1726(ra) # 800019ac <myproc>
    800022f6:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    800022f8:	fffff097          	auipc	ra,0xfffff
    800022fc:	864080e7          	jalr	-1948(ra) # 80000b5c <holding>
    80002300:	c93d                	beqz	a0,80002376 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002302:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80002304:	2781                	sext.w	a5,a5
    80002306:	079e                	slli	a5,a5,0x7
    80002308:	0000f717          	auipc	a4,0xf
    8000230c:	a5870713          	addi	a4,a4,-1448 # 80010d60 <pid_lock>
    80002310:	97ba                	add	a5,a5,a4
    80002312:	0a87a703          	lw	a4,168(a5)
    80002316:	4785                	li	a5,1
    80002318:	06f71763          	bne	a4,a5,80002386 <sched+0xa6>
  if (p->state == RUNNING)
    8000231c:	4c98                	lw	a4,24(s1)
    8000231e:	4791                	li	a5,4
    80002320:	06f70b63          	beq	a4,a5,80002396 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002324:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002328:	8b89                	andi	a5,a5,2
  if (intr_get())
    8000232a:	efb5                	bnez	a5,800023a6 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000232c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000232e:	0000f917          	auipc	s2,0xf
    80002332:	a3290913          	addi	s2,s2,-1486 # 80010d60 <pid_lock>
    80002336:	2781                	sext.w	a5,a5
    80002338:	079e                	slli	a5,a5,0x7
    8000233a:	97ca                	add	a5,a5,s2
    8000233c:	0ac7a983          	lw	s3,172(a5)
    80002340:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002342:	2781                	sext.w	a5,a5
    80002344:	079e                	slli	a5,a5,0x7
    80002346:	0000f597          	auipc	a1,0xf
    8000234a:	a5258593          	addi	a1,a1,-1454 # 80010d98 <cpus+0x8>
    8000234e:	95be                	add	a1,a1,a5
    80002350:	06048513          	addi	a0,s1,96
    80002354:	00000097          	auipc	ra,0x0
    80002358:	7d8080e7          	jalr	2008(ra) # 80002b2c <swtch>
    8000235c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000235e:	2781                	sext.w	a5,a5
    80002360:	079e                	slli	a5,a5,0x7
    80002362:	97ca                	add	a5,a5,s2
    80002364:	0b37a623          	sw	s3,172(a5)
}
    80002368:	70a2                	ld	ra,40(sp)
    8000236a:	7402                	ld	s0,32(sp)
    8000236c:	64e2                	ld	s1,24(sp)
    8000236e:	6942                	ld	s2,16(sp)
    80002370:	69a2                	ld	s3,8(sp)
    80002372:	6145                	addi	sp,sp,48
    80002374:	8082                	ret
    panic("sched p->lock");
    80002376:	00006517          	auipc	a0,0x6
    8000237a:	ea250513          	addi	a0,a0,-350 # 80008218 <digits+0x1d8>
    8000237e:	ffffe097          	auipc	ra,0xffffe
    80002382:	1c0080e7          	jalr	448(ra) # 8000053e <panic>
    panic("sched locks");
    80002386:	00006517          	auipc	a0,0x6
    8000238a:	ea250513          	addi	a0,a0,-350 # 80008228 <digits+0x1e8>
    8000238e:	ffffe097          	auipc	ra,0xffffe
    80002392:	1b0080e7          	jalr	432(ra) # 8000053e <panic>
    panic("sched running");
    80002396:	00006517          	auipc	a0,0x6
    8000239a:	ea250513          	addi	a0,a0,-350 # 80008238 <digits+0x1f8>
    8000239e:	ffffe097          	auipc	ra,0xffffe
    800023a2:	1a0080e7          	jalr	416(ra) # 8000053e <panic>
    panic("sched interruptible");
    800023a6:	00006517          	auipc	a0,0x6
    800023aa:	ea250513          	addi	a0,a0,-350 # 80008248 <digits+0x208>
    800023ae:	ffffe097          	auipc	ra,0xffffe
    800023b2:	190080e7          	jalr	400(ra) # 8000053e <panic>

00000000800023b6 <yield>:
{
    800023b6:	1101                	addi	sp,sp,-32
    800023b8:	ec06                	sd	ra,24(sp)
    800023ba:	e822                	sd	s0,16(sp)
    800023bc:	e426                	sd	s1,8(sp)
    800023be:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800023c0:	fffff097          	auipc	ra,0xfffff
    800023c4:	5ec080e7          	jalr	1516(ra) # 800019ac <myproc>
    800023c8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800023ca:	fffff097          	auipc	ra,0xfffff
    800023ce:	80c080e7          	jalr	-2036(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    800023d2:	478d                	li	a5,3
    800023d4:	cc9c                	sw	a5,24(s1)
  sched();
    800023d6:	00000097          	auipc	ra,0x0
    800023da:	f0a080e7          	jalr	-246(ra) # 800022e0 <sched>
  release(&p->lock);
    800023de:	8526                	mv	a0,s1
    800023e0:	fffff097          	auipc	ra,0xfffff
    800023e4:	8aa080e7          	jalr	-1878(ra) # 80000c8a <release>
}
    800023e8:	60e2                	ld	ra,24(sp)
    800023ea:	6442                	ld	s0,16(sp)
    800023ec:	64a2                	ld	s1,8(sp)
    800023ee:	6105                	addi	sp,sp,32
    800023f0:	8082                	ret

00000000800023f2 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    800023f2:	7179                	addi	sp,sp,-48
    800023f4:	f406                	sd	ra,40(sp)
    800023f6:	f022                	sd	s0,32(sp)
    800023f8:	ec26                	sd	s1,24(sp)
    800023fa:	e84a                	sd	s2,16(sp)
    800023fc:	e44e                	sd	s3,8(sp)
    800023fe:	1800                	addi	s0,sp,48
    80002400:	89aa                	mv	s3,a0
    80002402:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002404:	fffff097          	auipc	ra,0xfffff
    80002408:	5a8080e7          	jalr	1448(ra) # 800019ac <myproc>
    8000240c:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    8000240e:	ffffe097          	auipc	ra,0xffffe
    80002412:	7c8080e7          	jalr	1992(ra) # 80000bd6 <acquire>
  release(lk);
    80002416:	854a                	mv	a0,s2
    80002418:	fffff097          	auipc	ra,0xfffff
    8000241c:	872080e7          	jalr	-1934(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    80002420:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002424:	4789                	li	a5,2
    80002426:	cc9c                	sw	a5,24(s1)
  p->sleeptime = ticks;
    80002428:	00006797          	auipc	a5,0x6
    8000242c:	6c87e783          	lwu	a5,1736(a5) # 80008af0 <ticks>
    80002430:	1af4bc23          	sd	a5,440(s1)

  sched();
    80002434:	00000097          	auipc	ra,0x0
    80002438:	eac080e7          	jalr	-340(ra) # 800022e0 <sched>

  // Tidy up.
  p->chan = 0;
    8000243c:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002440:	8526                	mv	a0,s1
    80002442:	fffff097          	auipc	ra,0xfffff
    80002446:	848080e7          	jalr	-1976(ra) # 80000c8a <release>
  acquire(lk);
    8000244a:	854a                	mv	a0,s2
    8000244c:	ffffe097          	auipc	ra,0xffffe
    80002450:	78a080e7          	jalr	1930(ra) # 80000bd6 <acquire>
}
    80002454:	70a2                	ld	ra,40(sp)
    80002456:	7402                	ld	s0,32(sp)
    80002458:	64e2                	ld	s1,24(sp)
    8000245a:	6942                	ld	s2,16(sp)
    8000245c:	69a2                	ld	s3,8(sp)
    8000245e:	6145                	addi	sp,sp,48
    80002460:	8082                	ret

0000000080002462 <waitx>:
{
    80002462:	711d                	addi	sp,sp,-96
    80002464:	ec86                	sd	ra,88(sp)
    80002466:	e8a2                	sd	s0,80(sp)
    80002468:	e4a6                	sd	s1,72(sp)
    8000246a:	e0ca                	sd	s2,64(sp)
    8000246c:	fc4e                	sd	s3,56(sp)
    8000246e:	f852                	sd	s4,48(sp)
    80002470:	f456                	sd	s5,40(sp)
    80002472:	f05a                	sd	s6,32(sp)
    80002474:	ec5e                	sd	s7,24(sp)
    80002476:	e862                	sd	s8,16(sp)
    80002478:	e466                	sd	s9,8(sp)
    8000247a:	e06a                	sd	s10,0(sp)
    8000247c:	1080                	addi	s0,sp,96
    8000247e:	8b2a                	mv	s6,a0
    80002480:	8bae                	mv	s7,a1
    80002482:	8c32                	mv	s8,a2
  struct proc *p = myproc();
    80002484:	fffff097          	auipc	ra,0xfffff
    80002488:	528080e7          	jalr	1320(ra) # 800019ac <myproc>
    8000248c:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000248e:	0000f517          	auipc	a0,0xf
    80002492:	8ea50513          	addi	a0,a0,-1814 # 80010d78 <wait_lock>
    80002496:	ffffe097          	auipc	ra,0xffffe
    8000249a:	740080e7          	jalr	1856(ra) # 80000bd6 <acquire>
    havekids = 0;
    8000249e:	4c81                	li	s9,0
        if (np->state == ZOMBIE)
    800024a0:	4a15                	li	s4,5
        havekids = 1;
    800024a2:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    800024a4:	00016997          	auipc	s3,0x16
    800024a8:	51c98993          	addi	s3,s3,1308 # 800189c0 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800024ac:	0000fd17          	auipc	s10,0xf
    800024b0:	8ccd0d13          	addi	s10,s10,-1844 # 80010d78 <wait_lock>
    havekids = 0;
    800024b4:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    800024b6:	0000f497          	auipc	s1,0xf
    800024ba:	d0a48493          	addi	s1,s1,-758 # 800111c0 <proc>
    800024be:	a059                	j	80002544 <waitx+0xe2>
          pid = np->pid;
    800024c0:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    800024c4:	16c4a703          	lw	a4,364(s1)
    800024c8:	00ec2023          	sw	a4,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    800024cc:	1704a783          	lw	a5,368(s1)
    800024d0:	9f3d                	addw	a4,a4,a5
    800024d2:	1744a783          	lw	a5,372(s1)
    800024d6:	9f99                	subw	a5,a5,a4
    800024d8:	00fba023          	sw	a5,0(s7) # fffffffffffff000 <end+0xffffffff7ffdb260>
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800024dc:	000b0e63          	beqz	s6,800024f8 <waitx+0x96>
    800024e0:	4691                	li	a3,4
    800024e2:	02c48613          	addi	a2,s1,44
    800024e6:	85da                	mv	a1,s6
    800024e8:	05093503          	ld	a0,80(s2)
    800024ec:	fffff097          	auipc	ra,0xfffff
    800024f0:	17c080e7          	jalr	380(ra) # 80001668 <copyout>
    800024f4:	02054563          	bltz	a0,8000251e <waitx+0xbc>
          freeproc(np);
    800024f8:	8526                	mv	a0,s1
    800024fa:	fffff097          	auipc	ra,0xfffff
    800024fe:	664080e7          	jalr	1636(ra) # 80001b5e <freeproc>
          release(&np->lock);
    80002502:	8526                	mv	a0,s1
    80002504:	ffffe097          	auipc	ra,0xffffe
    80002508:	786080e7          	jalr	1926(ra) # 80000c8a <release>
          release(&wait_lock);
    8000250c:	0000f517          	auipc	a0,0xf
    80002510:	86c50513          	addi	a0,a0,-1940 # 80010d78 <wait_lock>
    80002514:	ffffe097          	auipc	ra,0xffffe
    80002518:	776080e7          	jalr	1910(ra) # 80000c8a <release>
          return pid;
    8000251c:	a09d                	j	80002582 <waitx+0x120>
            release(&np->lock);
    8000251e:	8526                	mv	a0,s1
    80002520:	ffffe097          	auipc	ra,0xffffe
    80002524:	76a080e7          	jalr	1898(ra) # 80000c8a <release>
            release(&wait_lock);
    80002528:	0000f517          	auipc	a0,0xf
    8000252c:	85050513          	addi	a0,a0,-1968 # 80010d78 <wait_lock>
    80002530:	ffffe097          	auipc	ra,0xffffe
    80002534:	75a080e7          	jalr	1882(ra) # 80000c8a <release>
            return -1;
    80002538:	59fd                	li	s3,-1
    8000253a:	a0a1                	j	80002582 <waitx+0x120>
    for (np = proc; np < &proc[NPROC]; np++)
    8000253c:	1e048493          	addi	s1,s1,480
    80002540:	03348463          	beq	s1,s3,80002568 <waitx+0x106>
      if (np->parent == p)
    80002544:	7c9c                	ld	a5,56(s1)
    80002546:	ff279be3          	bne	a5,s2,8000253c <waitx+0xda>
        acquire(&np->lock);
    8000254a:	8526                	mv	a0,s1
    8000254c:	ffffe097          	auipc	ra,0xffffe
    80002550:	68a080e7          	jalr	1674(ra) # 80000bd6 <acquire>
        if (np->state == ZOMBIE)
    80002554:	4c9c                	lw	a5,24(s1)
    80002556:	f74785e3          	beq	a5,s4,800024c0 <waitx+0x5e>
        release(&np->lock);
    8000255a:	8526                	mv	a0,s1
    8000255c:	ffffe097          	auipc	ra,0xffffe
    80002560:	72e080e7          	jalr	1838(ra) # 80000c8a <release>
        havekids = 1;
    80002564:	8756                	mv	a4,s5
    80002566:	bfd9                	j	8000253c <waitx+0xda>
    if (!havekids || p->killed)
    80002568:	c701                	beqz	a4,80002570 <waitx+0x10e>
    8000256a:	02892783          	lw	a5,40(s2)
    8000256e:	cb8d                	beqz	a5,800025a0 <waitx+0x13e>
      release(&wait_lock);
    80002570:	0000f517          	auipc	a0,0xf
    80002574:	80850513          	addi	a0,a0,-2040 # 80010d78 <wait_lock>
    80002578:	ffffe097          	auipc	ra,0xffffe
    8000257c:	712080e7          	jalr	1810(ra) # 80000c8a <release>
      return -1;
    80002580:	59fd                	li	s3,-1
}
    80002582:	854e                	mv	a0,s3
    80002584:	60e6                	ld	ra,88(sp)
    80002586:	6446                	ld	s0,80(sp)
    80002588:	64a6                	ld	s1,72(sp)
    8000258a:	6906                	ld	s2,64(sp)
    8000258c:	79e2                	ld	s3,56(sp)
    8000258e:	7a42                	ld	s4,48(sp)
    80002590:	7aa2                	ld	s5,40(sp)
    80002592:	7b02                	ld	s6,32(sp)
    80002594:	6be2                	ld	s7,24(sp)
    80002596:	6c42                	ld	s8,16(sp)
    80002598:	6ca2                	ld	s9,8(sp)
    8000259a:	6d02                	ld	s10,0(sp)
    8000259c:	6125                	addi	sp,sp,96
    8000259e:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    800025a0:	85ea                	mv	a1,s10
    800025a2:	854a                	mv	a0,s2
    800025a4:	00000097          	auipc	ra,0x0
    800025a8:	e4e080e7          	jalr	-434(ra) # 800023f2 <sleep>
    havekids = 0;
    800025ac:	b721                	j	800024b4 <waitx+0x52>

00000000800025ae <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    800025ae:	7139                	addi	sp,sp,-64
    800025b0:	fc06                	sd	ra,56(sp)
    800025b2:	f822                	sd	s0,48(sp)
    800025b4:	f426                	sd	s1,40(sp)
    800025b6:	f04a                	sd	s2,32(sp)
    800025b8:	ec4e                	sd	s3,24(sp)
    800025ba:	e852                	sd	s4,16(sp)
    800025bc:	e456                	sd	s5,8(sp)
    800025be:	e05a                	sd	s6,0(sp)
    800025c0:	0080                	addi	s0,sp,64
    800025c2:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800025c4:	0000f497          	auipc	s1,0xf
    800025c8:	bfc48493          	addi	s1,s1,-1028 # 800111c0 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    800025cc:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    800025ce:	4b0d                	li	s6,3
        p->sleeptime=ticks-p->sleeptime;
    800025d0:	00006a97          	auipc	s5,0x6
    800025d4:	520a8a93          	addi	s5,s5,1312 # 80008af0 <ticks>
  for (p = proc; p < &proc[NPROC]; p++)
    800025d8:	00016917          	auipc	s2,0x16
    800025dc:	3e890913          	addi	s2,s2,1000 # 800189c0 <tickslock>
    800025e0:	a811                	j	800025f4 <wakeup+0x46>
      }
      release(&p->lock);
    800025e2:	8526                	mv	a0,s1
    800025e4:	ffffe097          	auipc	ra,0xffffe
    800025e8:	6a6080e7          	jalr	1702(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800025ec:	1e048493          	addi	s1,s1,480
    800025f0:	03248d63          	beq	s1,s2,8000262a <wakeup+0x7c>
    if (p != myproc())
    800025f4:	fffff097          	auipc	ra,0xfffff
    800025f8:	3b8080e7          	jalr	952(ra) # 800019ac <myproc>
    800025fc:	fea488e3          	beq	s1,a0,800025ec <wakeup+0x3e>
      acquire(&p->lock);
    80002600:	8526                	mv	a0,s1
    80002602:	ffffe097          	auipc	ra,0xffffe
    80002606:	5d4080e7          	jalr	1492(ra) # 80000bd6 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    8000260a:	4c9c                	lw	a5,24(s1)
    8000260c:	fd379be3          	bne	a5,s3,800025e2 <wakeup+0x34>
    80002610:	709c                	ld	a5,32(s1)
    80002612:	fd4798e3          	bne	a5,s4,800025e2 <wakeup+0x34>
        p->state = RUNNABLE;
    80002616:	0164ac23          	sw	s6,24(s1)
        p->sleeptime=ticks-p->sleeptime;
    8000261a:	000ae783          	lwu	a5,0(s5)
    8000261e:	1b84b703          	ld	a4,440(s1)
    80002622:	8f99                	sub	a5,a5,a4
    80002624:	1af4bc23          	sd	a5,440(s1)
    80002628:	bf6d                	j	800025e2 <wakeup+0x34>
    }
  }
}
    8000262a:	70e2                	ld	ra,56(sp)
    8000262c:	7442                	ld	s0,48(sp)
    8000262e:	74a2                	ld	s1,40(sp)
    80002630:	7902                	ld	s2,32(sp)
    80002632:	69e2                	ld	s3,24(sp)
    80002634:	6a42                	ld	s4,16(sp)
    80002636:	6aa2                	ld	s5,8(sp)
    80002638:	6b02                	ld	s6,0(sp)
    8000263a:	6121                	addi	sp,sp,64
    8000263c:	8082                	ret

000000008000263e <reparent>:
{
    8000263e:	7179                	addi	sp,sp,-48
    80002640:	f406                	sd	ra,40(sp)
    80002642:	f022                	sd	s0,32(sp)
    80002644:	ec26                	sd	s1,24(sp)
    80002646:	e84a                	sd	s2,16(sp)
    80002648:	e44e                	sd	s3,8(sp)
    8000264a:	e052                	sd	s4,0(sp)
    8000264c:	1800                	addi	s0,sp,48
    8000264e:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002650:	0000f497          	auipc	s1,0xf
    80002654:	b7048493          	addi	s1,s1,-1168 # 800111c0 <proc>
      pp->parent = initproc;
    80002658:	00006a17          	auipc	s4,0x6
    8000265c:	490a0a13          	addi	s4,s4,1168 # 80008ae8 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002660:	00016997          	auipc	s3,0x16
    80002664:	36098993          	addi	s3,s3,864 # 800189c0 <tickslock>
    80002668:	a029                	j	80002672 <reparent+0x34>
    8000266a:	1e048493          	addi	s1,s1,480
    8000266e:	01348d63          	beq	s1,s3,80002688 <reparent+0x4a>
    if (pp->parent == p)
    80002672:	7c9c                	ld	a5,56(s1)
    80002674:	ff279be3          	bne	a5,s2,8000266a <reparent+0x2c>
      pp->parent = initproc;
    80002678:	000a3503          	ld	a0,0(s4)
    8000267c:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000267e:	00000097          	auipc	ra,0x0
    80002682:	f30080e7          	jalr	-208(ra) # 800025ae <wakeup>
    80002686:	b7d5                	j	8000266a <reparent+0x2c>
}
    80002688:	70a2                	ld	ra,40(sp)
    8000268a:	7402                	ld	s0,32(sp)
    8000268c:	64e2                	ld	s1,24(sp)
    8000268e:	6942                	ld	s2,16(sp)
    80002690:	69a2                	ld	s3,8(sp)
    80002692:	6a02                	ld	s4,0(sp)
    80002694:	6145                	addi	sp,sp,48
    80002696:	8082                	ret

0000000080002698 <exit>:
{
    80002698:	7179                	addi	sp,sp,-48
    8000269a:	f406                	sd	ra,40(sp)
    8000269c:	f022                	sd	s0,32(sp)
    8000269e:	ec26                	sd	s1,24(sp)
    800026a0:	e84a                	sd	s2,16(sp)
    800026a2:	e44e                	sd	s3,8(sp)
    800026a4:	e052                	sd	s4,0(sp)
    800026a6:	1800                	addi	s0,sp,48
    800026a8:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800026aa:	fffff097          	auipc	ra,0xfffff
    800026ae:	302080e7          	jalr	770(ra) # 800019ac <myproc>
    800026b2:	89aa                	mv	s3,a0
  if (p == initproc)
    800026b4:	00006797          	auipc	a5,0x6
    800026b8:	4347b783          	ld	a5,1076(a5) # 80008ae8 <initproc>
    800026bc:	0d050493          	addi	s1,a0,208
    800026c0:	15050913          	addi	s2,a0,336
    800026c4:	02a79363          	bne	a5,a0,800026ea <exit+0x52>
    panic("init exiting");
    800026c8:	00006517          	auipc	a0,0x6
    800026cc:	b9850513          	addi	a0,a0,-1128 # 80008260 <digits+0x220>
    800026d0:	ffffe097          	auipc	ra,0xffffe
    800026d4:	e6e080e7          	jalr	-402(ra) # 8000053e <panic>
      fileclose(f);
    800026d8:	00002097          	auipc	ra,0x2
    800026dc:	66a080e7          	jalr	1642(ra) # 80004d42 <fileclose>
      p->ofile[fd] = 0;
    800026e0:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    800026e4:	04a1                	addi	s1,s1,8
    800026e6:	01248563          	beq	s1,s2,800026f0 <exit+0x58>
    if (p->ofile[fd])
    800026ea:	6088                	ld	a0,0(s1)
    800026ec:	f575                	bnez	a0,800026d8 <exit+0x40>
    800026ee:	bfdd                	j	800026e4 <exit+0x4c>
  begin_op();
    800026f0:	00002097          	auipc	ra,0x2
    800026f4:	186080e7          	jalr	390(ra) # 80004876 <begin_op>
  iput(p->cwd);
    800026f8:	1509b503          	ld	a0,336(s3)
    800026fc:	00002097          	auipc	ra,0x2
    80002700:	972080e7          	jalr	-1678(ra) # 8000406e <iput>
  end_op();
    80002704:	00002097          	auipc	ra,0x2
    80002708:	1f2080e7          	jalr	498(ra) # 800048f6 <end_op>
  p->cwd = 0;
    8000270c:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002710:	0000e497          	auipc	s1,0xe
    80002714:	66848493          	addi	s1,s1,1640 # 80010d78 <wait_lock>
    80002718:	8526                	mv	a0,s1
    8000271a:	ffffe097          	auipc	ra,0xffffe
    8000271e:	4bc080e7          	jalr	1212(ra) # 80000bd6 <acquire>
  reparent(p);
    80002722:	854e                	mv	a0,s3
    80002724:	00000097          	auipc	ra,0x0
    80002728:	f1a080e7          	jalr	-230(ra) # 8000263e <reparent>
  wakeup(p->parent);
    8000272c:	0389b503          	ld	a0,56(s3)
    80002730:	00000097          	auipc	ra,0x0
    80002734:	e7e080e7          	jalr	-386(ra) # 800025ae <wakeup>
  acquire(&p->lock);
    80002738:	854e                	mv	a0,s3
    8000273a:	ffffe097          	auipc	ra,0xffffe
    8000273e:	49c080e7          	jalr	1180(ra) # 80000bd6 <acquire>
  p->xstate = status;
    80002742:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002746:	4795                	li	a5,5
    80002748:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    8000274c:	00006797          	auipc	a5,0x6
    80002750:	3a47a783          	lw	a5,932(a5) # 80008af0 <ticks>
    80002754:	16f9aa23          	sw	a5,372(s3)
  release(&wait_lock);
    80002758:	8526                	mv	a0,s1
    8000275a:	ffffe097          	auipc	ra,0xffffe
    8000275e:	530080e7          	jalr	1328(ra) # 80000c8a <release>
  sched();
    80002762:	00000097          	auipc	ra,0x0
    80002766:	b7e080e7          	jalr	-1154(ra) # 800022e0 <sched>
  panic("zombie exit");
    8000276a:	00006517          	auipc	a0,0x6
    8000276e:	b0650513          	addi	a0,a0,-1274 # 80008270 <digits+0x230>
    80002772:	ffffe097          	auipc	ra,0xffffe
    80002776:	dcc080e7          	jalr	-564(ra) # 8000053e <panic>

000000008000277a <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    8000277a:	7179                	addi	sp,sp,-48
    8000277c:	f406                	sd	ra,40(sp)
    8000277e:	f022                	sd	s0,32(sp)
    80002780:	ec26                	sd	s1,24(sp)
    80002782:	e84a                	sd	s2,16(sp)
    80002784:	e44e                	sd	s3,8(sp)
    80002786:	1800                	addi	s0,sp,48
    80002788:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000278a:	0000f497          	auipc	s1,0xf
    8000278e:	a3648493          	addi	s1,s1,-1482 # 800111c0 <proc>
    80002792:	00016997          	auipc	s3,0x16
    80002796:	22e98993          	addi	s3,s3,558 # 800189c0 <tickslock>
  {
    acquire(&p->lock);
    8000279a:	8526                	mv	a0,s1
    8000279c:	ffffe097          	auipc	ra,0xffffe
    800027a0:	43a080e7          	jalr	1082(ra) # 80000bd6 <acquire>
    if (p->pid == pid)
    800027a4:	589c                	lw	a5,48(s1)
    800027a6:	01278d63          	beq	a5,s2,800027c0 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800027aa:	8526                	mv	a0,s1
    800027ac:	ffffe097          	auipc	ra,0xffffe
    800027b0:	4de080e7          	jalr	1246(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800027b4:	1e048493          	addi	s1,s1,480
    800027b8:	ff3491e3          	bne	s1,s3,8000279a <kill+0x20>
  }
  return -1;
    800027bc:	557d                	li	a0,-1
    800027be:	a829                	j	800027d8 <kill+0x5e>
      p->killed = 1;
    800027c0:	4785                	li	a5,1
    800027c2:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    800027c4:	4c98                	lw	a4,24(s1)
    800027c6:	4789                	li	a5,2
    800027c8:	00f70f63          	beq	a4,a5,800027e6 <kill+0x6c>
      release(&p->lock);
    800027cc:	8526                	mv	a0,s1
    800027ce:	ffffe097          	auipc	ra,0xffffe
    800027d2:	4bc080e7          	jalr	1212(ra) # 80000c8a <release>
      return 0;
    800027d6:	4501                	li	a0,0
}
    800027d8:	70a2                	ld	ra,40(sp)
    800027da:	7402                	ld	s0,32(sp)
    800027dc:	64e2                	ld	s1,24(sp)
    800027de:	6942                	ld	s2,16(sp)
    800027e0:	69a2                	ld	s3,8(sp)
    800027e2:	6145                	addi	sp,sp,48
    800027e4:	8082                	ret
        p->state = RUNNABLE;
    800027e6:	478d                	li	a5,3
    800027e8:	cc9c                	sw	a5,24(s1)
    800027ea:	b7cd                	j	800027cc <kill+0x52>

00000000800027ec <setkilled>:

void setkilled(struct proc *p)
{
    800027ec:	1101                	addi	sp,sp,-32
    800027ee:	ec06                	sd	ra,24(sp)
    800027f0:	e822                	sd	s0,16(sp)
    800027f2:	e426                	sd	s1,8(sp)
    800027f4:	1000                	addi	s0,sp,32
    800027f6:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800027f8:	ffffe097          	auipc	ra,0xffffe
    800027fc:	3de080e7          	jalr	990(ra) # 80000bd6 <acquire>
  p->killed = 1;
    80002800:	4785                	li	a5,1
    80002802:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002804:	8526                	mv	a0,s1
    80002806:	ffffe097          	auipc	ra,0xffffe
    8000280a:	484080e7          	jalr	1156(ra) # 80000c8a <release>
}
    8000280e:	60e2                	ld	ra,24(sp)
    80002810:	6442                	ld	s0,16(sp)
    80002812:	64a2                	ld	s1,8(sp)
    80002814:	6105                	addi	sp,sp,32
    80002816:	8082                	ret

0000000080002818 <killed>:

int killed(struct proc *p)
{
    80002818:	1101                	addi	sp,sp,-32
    8000281a:	ec06                	sd	ra,24(sp)
    8000281c:	e822                	sd	s0,16(sp)
    8000281e:	e426                	sd	s1,8(sp)
    80002820:	e04a                	sd	s2,0(sp)
    80002822:	1000                	addi	s0,sp,32
    80002824:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002826:	ffffe097          	auipc	ra,0xffffe
    8000282a:	3b0080e7          	jalr	944(ra) # 80000bd6 <acquire>
  k = p->killed;
    8000282e:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002832:	8526                	mv	a0,s1
    80002834:	ffffe097          	auipc	ra,0xffffe
    80002838:	456080e7          	jalr	1110(ra) # 80000c8a <release>
  return k;
}
    8000283c:	854a                	mv	a0,s2
    8000283e:	60e2                	ld	ra,24(sp)
    80002840:	6442                	ld	s0,16(sp)
    80002842:	64a2                	ld	s1,8(sp)
    80002844:	6902                	ld	s2,0(sp)
    80002846:	6105                	addi	sp,sp,32
    80002848:	8082                	ret

000000008000284a <wait>:
{
    8000284a:	715d                	addi	sp,sp,-80
    8000284c:	e486                	sd	ra,72(sp)
    8000284e:	e0a2                	sd	s0,64(sp)
    80002850:	fc26                	sd	s1,56(sp)
    80002852:	f84a                	sd	s2,48(sp)
    80002854:	f44e                	sd	s3,40(sp)
    80002856:	f052                	sd	s4,32(sp)
    80002858:	ec56                	sd	s5,24(sp)
    8000285a:	e85a                	sd	s6,16(sp)
    8000285c:	e45e                	sd	s7,8(sp)
    8000285e:	e062                	sd	s8,0(sp)
    80002860:	0880                	addi	s0,sp,80
    80002862:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002864:	fffff097          	auipc	ra,0xfffff
    80002868:	148080e7          	jalr	328(ra) # 800019ac <myproc>
    8000286c:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000286e:	0000e517          	auipc	a0,0xe
    80002872:	50a50513          	addi	a0,a0,1290 # 80010d78 <wait_lock>
    80002876:	ffffe097          	auipc	ra,0xffffe
    8000287a:	360080e7          	jalr	864(ra) # 80000bd6 <acquire>
    havekids = 0;
    8000287e:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    80002880:	4a15                	li	s4,5
        havekids = 1;
    80002882:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002884:	00016997          	auipc	s3,0x16
    80002888:	13c98993          	addi	s3,s3,316 # 800189c0 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000288c:	0000ec17          	auipc	s8,0xe
    80002890:	4ecc0c13          	addi	s8,s8,1260 # 80010d78 <wait_lock>
    havekids = 0;
    80002894:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002896:	0000f497          	auipc	s1,0xf
    8000289a:	92a48493          	addi	s1,s1,-1750 # 800111c0 <proc>
    8000289e:	a0bd                	j	8000290c <wait+0xc2>
          pid = pp->pid;
    800028a0:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800028a4:	000b0e63          	beqz	s6,800028c0 <wait+0x76>
    800028a8:	4691                	li	a3,4
    800028aa:	02c48613          	addi	a2,s1,44
    800028ae:	85da                	mv	a1,s6
    800028b0:	05093503          	ld	a0,80(s2)
    800028b4:	fffff097          	auipc	ra,0xfffff
    800028b8:	db4080e7          	jalr	-588(ra) # 80001668 <copyout>
    800028bc:	02054563          	bltz	a0,800028e6 <wait+0x9c>
          freeproc(pp);
    800028c0:	8526                	mv	a0,s1
    800028c2:	fffff097          	auipc	ra,0xfffff
    800028c6:	29c080e7          	jalr	668(ra) # 80001b5e <freeproc>
          release(&pp->lock);
    800028ca:	8526                	mv	a0,s1
    800028cc:	ffffe097          	auipc	ra,0xffffe
    800028d0:	3be080e7          	jalr	958(ra) # 80000c8a <release>
          release(&wait_lock);
    800028d4:	0000e517          	auipc	a0,0xe
    800028d8:	4a450513          	addi	a0,a0,1188 # 80010d78 <wait_lock>
    800028dc:	ffffe097          	auipc	ra,0xffffe
    800028e0:	3ae080e7          	jalr	942(ra) # 80000c8a <release>
          return pid;
    800028e4:	a0b5                	j	80002950 <wait+0x106>
            release(&pp->lock);
    800028e6:	8526                	mv	a0,s1
    800028e8:	ffffe097          	auipc	ra,0xffffe
    800028ec:	3a2080e7          	jalr	930(ra) # 80000c8a <release>
            release(&wait_lock);
    800028f0:	0000e517          	auipc	a0,0xe
    800028f4:	48850513          	addi	a0,a0,1160 # 80010d78 <wait_lock>
    800028f8:	ffffe097          	auipc	ra,0xffffe
    800028fc:	392080e7          	jalr	914(ra) # 80000c8a <release>
            return -1;
    80002900:	59fd                	li	s3,-1
    80002902:	a0b9                	j	80002950 <wait+0x106>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002904:	1e048493          	addi	s1,s1,480
    80002908:	03348463          	beq	s1,s3,80002930 <wait+0xe6>
      if (pp->parent == p)
    8000290c:	7c9c                	ld	a5,56(s1)
    8000290e:	ff279be3          	bne	a5,s2,80002904 <wait+0xba>
        acquire(&pp->lock);
    80002912:	8526                	mv	a0,s1
    80002914:	ffffe097          	auipc	ra,0xffffe
    80002918:	2c2080e7          	jalr	706(ra) # 80000bd6 <acquire>
        if (pp->state == ZOMBIE)
    8000291c:	4c9c                	lw	a5,24(s1)
    8000291e:	f94781e3          	beq	a5,s4,800028a0 <wait+0x56>
        release(&pp->lock);
    80002922:	8526                	mv	a0,s1
    80002924:	ffffe097          	auipc	ra,0xffffe
    80002928:	366080e7          	jalr	870(ra) # 80000c8a <release>
        havekids = 1;
    8000292c:	8756                	mv	a4,s5
    8000292e:	bfd9                	j	80002904 <wait+0xba>
    if (!havekids || killed(p))
    80002930:	c719                	beqz	a4,8000293e <wait+0xf4>
    80002932:	854a                	mv	a0,s2
    80002934:	00000097          	auipc	ra,0x0
    80002938:	ee4080e7          	jalr	-284(ra) # 80002818 <killed>
    8000293c:	c51d                	beqz	a0,8000296a <wait+0x120>
      release(&wait_lock);
    8000293e:	0000e517          	auipc	a0,0xe
    80002942:	43a50513          	addi	a0,a0,1082 # 80010d78 <wait_lock>
    80002946:	ffffe097          	auipc	ra,0xffffe
    8000294a:	344080e7          	jalr	836(ra) # 80000c8a <release>
      return -1;
    8000294e:	59fd                	li	s3,-1
}
    80002950:	854e                	mv	a0,s3
    80002952:	60a6                	ld	ra,72(sp)
    80002954:	6406                	ld	s0,64(sp)
    80002956:	74e2                	ld	s1,56(sp)
    80002958:	7942                	ld	s2,48(sp)
    8000295a:	79a2                	ld	s3,40(sp)
    8000295c:	7a02                	ld	s4,32(sp)
    8000295e:	6ae2                	ld	s5,24(sp)
    80002960:	6b42                	ld	s6,16(sp)
    80002962:	6ba2                	ld	s7,8(sp)
    80002964:	6c02                	ld	s8,0(sp)
    80002966:	6161                	addi	sp,sp,80
    80002968:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000296a:	85e2                	mv	a1,s8
    8000296c:	854a                	mv	a0,s2
    8000296e:	00000097          	auipc	ra,0x0
    80002972:	a84080e7          	jalr	-1404(ra) # 800023f2 <sleep>
    havekids = 0;
    80002976:	bf39                	j	80002894 <wait+0x4a>

0000000080002978 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002978:	7179                	addi	sp,sp,-48
    8000297a:	f406                	sd	ra,40(sp)
    8000297c:	f022                	sd	s0,32(sp)
    8000297e:	ec26                	sd	s1,24(sp)
    80002980:	e84a                	sd	s2,16(sp)
    80002982:	e44e                	sd	s3,8(sp)
    80002984:	e052                	sd	s4,0(sp)
    80002986:	1800                	addi	s0,sp,48
    80002988:	84aa                	mv	s1,a0
    8000298a:	892e                	mv	s2,a1
    8000298c:	89b2                	mv	s3,a2
    8000298e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002990:	fffff097          	auipc	ra,0xfffff
    80002994:	01c080e7          	jalr	28(ra) # 800019ac <myproc>
  if (user_dst)
    80002998:	c08d                	beqz	s1,800029ba <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    8000299a:	86d2                	mv	a3,s4
    8000299c:	864e                	mv	a2,s3
    8000299e:	85ca                	mv	a1,s2
    800029a0:	6928                	ld	a0,80(a0)
    800029a2:	fffff097          	auipc	ra,0xfffff
    800029a6:	cc6080e7          	jalr	-826(ra) # 80001668 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800029aa:	70a2                	ld	ra,40(sp)
    800029ac:	7402                	ld	s0,32(sp)
    800029ae:	64e2                	ld	s1,24(sp)
    800029b0:	6942                	ld	s2,16(sp)
    800029b2:	69a2                	ld	s3,8(sp)
    800029b4:	6a02                	ld	s4,0(sp)
    800029b6:	6145                	addi	sp,sp,48
    800029b8:	8082                	ret
    memmove((char *)dst, src, len);
    800029ba:	000a061b          	sext.w	a2,s4
    800029be:	85ce                	mv	a1,s3
    800029c0:	854a                	mv	a0,s2
    800029c2:	ffffe097          	auipc	ra,0xffffe
    800029c6:	36c080e7          	jalr	876(ra) # 80000d2e <memmove>
    return 0;
    800029ca:	8526                	mv	a0,s1
    800029cc:	bff9                	j	800029aa <either_copyout+0x32>

00000000800029ce <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800029ce:	7179                	addi	sp,sp,-48
    800029d0:	f406                	sd	ra,40(sp)
    800029d2:	f022                	sd	s0,32(sp)
    800029d4:	ec26                	sd	s1,24(sp)
    800029d6:	e84a                	sd	s2,16(sp)
    800029d8:	e44e                	sd	s3,8(sp)
    800029da:	e052                	sd	s4,0(sp)
    800029dc:	1800                	addi	s0,sp,48
    800029de:	892a                	mv	s2,a0
    800029e0:	84ae                	mv	s1,a1
    800029e2:	89b2                	mv	s3,a2
    800029e4:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800029e6:	fffff097          	auipc	ra,0xfffff
    800029ea:	fc6080e7          	jalr	-58(ra) # 800019ac <myproc>
  if (user_src)
    800029ee:	c08d                	beqz	s1,80002a10 <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    800029f0:	86d2                	mv	a3,s4
    800029f2:	864e                	mv	a2,s3
    800029f4:	85ca                	mv	a1,s2
    800029f6:	6928                	ld	a0,80(a0)
    800029f8:	fffff097          	auipc	ra,0xfffff
    800029fc:	cfc080e7          	jalr	-772(ra) # 800016f4 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002a00:	70a2                	ld	ra,40(sp)
    80002a02:	7402                	ld	s0,32(sp)
    80002a04:	64e2                	ld	s1,24(sp)
    80002a06:	6942                	ld	s2,16(sp)
    80002a08:	69a2                	ld	s3,8(sp)
    80002a0a:	6a02                	ld	s4,0(sp)
    80002a0c:	6145                	addi	sp,sp,48
    80002a0e:	8082                	ret
    memmove(dst, (char *)src, len);
    80002a10:	000a061b          	sext.w	a2,s4
    80002a14:	85ce                	mv	a1,s3
    80002a16:	854a                	mv	a0,s2
    80002a18:	ffffe097          	auipc	ra,0xffffe
    80002a1c:	316080e7          	jalr	790(ra) # 80000d2e <memmove>
    return 0;
    80002a20:	8526                	mv	a0,s1
    80002a22:	bff9                	j	80002a00 <either_copyin+0x32>

0000000080002a24 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002a24:	7139                	addi	sp,sp,-64
    80002a26:	fc06                	sd	ra,56(sp)
    80002a28:	f822                	sd	s0,48(sp)
    80002a2a:	f426                	sd	s1,40(sp)
    80002a2c:	f04a                	sd	s2,32(sp)
    80002a2e:	ec4e                	sd	s3,24(sp)
    80002a30:	e852                	sd	s4,16(sp)
    80002a32:	e456                	sd	s5,8(sp)
    80002a34:	0080                	addi	s0,sp,64
  struct proc *p;

  printf("\n");
    80002a36:	00005517          	auipc	a0,0x5
    80002a3a:	69250513          	addi	a0,a0,1682 # 800080c8 <digits+0x88>
    80002a3e:	ffffe097          	auipc	ra,0xffffe
    80002a42:	b4a080e7          	jalr	-1206(ra) # 80000588 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002a46:	0000e497          	auipc	s1,0xe
    80002a4a:	77a48493          	addi	s1,s1,1914 # 800111c0 <proc>
  {
    if (p->state == UNUSED)
      continue;
    if(p->pid > 3){
    80002a4e:	498d                	li	s3,3
    printf("%d-%d", p->pid, p->queue);
    80002a50:	00006a97          	auipc	s5,0x6
    80002a54:	830a8a93          	addi	s5,s5,-2000 # 80008280 <digits+0x240>
    //printf("#NN - %d %s %s %d %d %d %d", p->pid, state, p->name, p->queue, p->tickcount, p->waittickcount, p->queueposition);
    printf("\n");
    80002a58:	00005a17          	auipc	s4,0x5
    80002a5c:	670a0a13          	addi	s4,s4,1648 # 800080c8 <digits+0x88>
  for (p = proc; p < &proc[NPROC]; p++)
    80002a60:	00016917          	auipc	s2,0x16
    80002a64:	f6090913          	addi	s2,s2,-160 # 800189c0 <tickslock>
    80002a68:	a029                	j	80002a72 <procdump+0x4e>
    80002a6a:	1e048493          	addi	s1,s1,480
    80002a6e:	03248463          	beq	s1,s2,80002a96 <procdump+0x72>
    if (p->state == UNUSED)
    80002a72:	4c9c                	lw	a5,24(s1)
    80002a74:	dbfd                	beqz	a5,80002a6a <procdump+0x46>
    if(p->pid > 3){
    80002a76:	588c                	lw	a1,48(s1)
    80002a78:	feb9d9e3          	bge	s3,a1,80002a6a <procdump+0x46>
    printf("%d-%d", p->pid, p->queue);
    80002a7c:	1d44a603          	lw	a2,468(s1)
    80002a80:	8556                	mv	a0,s5
    80002a82:	ffffe097          	auipc	ra,0xffffe
    80002a86:	b06080e7          	jalr	-1274(ra) # 80000588 <printf>
    printf("\n");
    80002a8a:	8552                	mv	a0,s4
    80002a8c:	ffffe097          	auipc	ra,0xffffe
    80002a90:	afc080e7          	jalr	-1284(ra) # 80000588 <printf>
    80002a94:	bfd9                	j	80002a6a <procdump+0x46>
    }
  }
  //printf("%d %d %d %d %d\n", queueprocesscount[0], queueprocesscount[1], queueprocesscount[2], queueprocesscount[3], queueprocesscount[4]);
}
    80002a96:	70e2                	ld	ra,56(sp)
    80002a98:	7442                	ld	s0,48(sp)
    80002a9a:	74a2                	ld	s1,40(sp)
    80002a9c:	7902                	ld	s2,32(sp)
    80002a9e:	69e2                	ld	s3,24(sp)
    80002aa0:	6a42                	ld	s4,16(sp)
    80002aa2:	6aa2                	ld	s5,8(sp)
    80002aa4:	6121                	addi	sp,sp,64
    80002aa6:	8082                	ret

0000000080002aa8 <setpriority>:

int setpriority(int new_priority, int pid)
{
    80002aa8:	7179                	addi	sp,sp,-48
    80002aaa:	f406                	sd	ra,40(sp)
    80002aac:	f022                	sd	s0,32(sp)
    80002aae:	ec26                	sd	s1,24(sp)
    80002ab0:	e84a                	sd	s2,16(sp)
    80002ab2:	e44e                	sd	s3,8(sp)
    80002ab4:	e052                	sd	s4,0(sp)
    80002ab6:	1800                	addi	s0,sp,48
    80002ab8:	8a2a                	mv	s4,a0
    80002aba:	892e                	mv	s2,a1
  int prev_priority;
  prev_priority = 0;

  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    80002abc:	0000e497          	auipc	s1,0xe
    80002ac0:	70448493          	addi	s1,s1,1796 # 800111c0 <proc>
    80002ac4:	00016997          	auipc	s3,0x16
    80002ac8:	efc98993          	addi	s3,s3,-260 # 800189c0 <tickslock>
  {
    acquire(&p->lock);
    80002acc:	8526                	mv	a0,s1
    80002ace:	ffffe097          	auipc	ra,0xffffe
    80002ad2:	108080e7          	jalr	264(ra) # 80000bd6 <acquire>

    if (p->pid == pid)
    80002ad6:	589c                	lw	a5,48(s1)
    80002ad8:	01278d63          	beq	a5,s2,80002af2 <setpriority+0x4a>
        yield();
      }

      break;
    }
    release(&p->lock);
    80002adc:	8526                	mv	a0,s1
    80002ade:	ffffe097          	auipc	ra,0xffffe
    80002ae2:	1ac080e7          	jalr	428(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002ae6:	1e048493          	addi	s1,s1,480
    80002aea:	ff3491e3          	bne	s1,s3,80002acc <setpriority+0x24>
  prev_priority = 0;
    80002aee:	4901                	li	s2,0
    80002af0:	a005                	j	80002b10 <setpriority+0x68>
      prev_priority = p->priority;
    80002af2:	1c84a903          	lw	s2,456(s1)
      p->priority = new_priority;
    80002af6:	1d44b423          	sd	s4,456(s1)
      p->sleeptime = 0;
    80002afa:	1a04bc23          	sd	zero,440(s1)
      p->runtime = 0;
    80002afe:	1a04b423          	sd	zero,424(s1)
      release(&p->lock);
    80002b02:	8526                	mv	a0,s1
    80002b04:	ffffe097          	auipc	ra,0xffffe
    80002b08:	186080e7          	jalr	390(ra) # 80000c8a <release>
      if (reschedule)
    80002b0c:	012a4b63          	blt	s4,s2,80002b22 <setpriority+0x7a>
  }
  return prev_priority;
}
    80002b10:	854a                	mv	a0,s2
    80002b12:	70a2                	ld	ra,40(sp)
    80002b14:	7402                	ld	s0,32(sp)
    80002b16:	64e2                	ld	s1,24(sp)
    80002b18:	6942                	ld	s2,16(sp)
    80002b1a:	69a2                	ld	s3,8(sp)
    80002b1c:	6a02                	ld	s4,0(sp)
    80002b1e:	6145                	addi	sp,sp,48
    80002b20:	8082                	ret
        yield();
    80002b22:	00000097          	auipc	ra,0x0
    80002b26:	894080e7          	jalr	-1900(ra) # 800023b6 <yield>
    80002b2a:	b7dd                	j	80002b10 <setpriority+0x68>

0000000080002b2c <swtch>:
    80002b2c:	00153023          	sd	ra,0(a0)
    80002b30:	00253423          	sd	sp,8(a0)
    80002b34:	e900                	sd	s0,16(a0)
    80002b36:	ed04                	sd	s1,24(a0)
    80002b38:	03253023          	sd	s2,32(a0)
    80002b3c:	03353423          	sd	s3,40(a0)
    80002b40:	03453823          	sd	s4,48(a0)
    80002b44:	03553c23          	sd	s5,56(a0)
    80002b48:	05653023          	sd	s6,64(a0)
    80002b4c:	05753423          	sd	s7,72(a0)
    80002b50:	05853823          	sd	s8,80(a0)
    80002b54:	05953c23          	sd	s9,88(a0)
    80002b58:	07a53023          	sd	s10,96(a0)
    80002b5c:	07b53423          	sd	s11,104(a0)
    80002b60:	0005b083          	ld	ra,0(a1)
    80002b64:	0085b103          	ld	sp,8(a1)
    80002b68:	6980                	ld	s0,16(a1)
    80002b6a:	6d84                	ld	s1,24(a1)
    80002b6c:	0205b903          	ld	s2,32(a1)
    80002b70:	0285b983          	ld	s3,40(a1)
    80002b74:	0305ba03          	ld	s4,48(a1)
    80002b78:	0385ba83          	ld	s5,56(a1)
    80002b7c:	0405bb03          	ld	s6,64(a1)
    80002b80:	0485bb83          	ld	s7,72(a1)
    80002b84:	0505bc03          	ld	s8,80(a1)
    80002b88:	0585bc83          	ld	s9,88(a1)
    80002b8c:	0605bd03          	ld	s10,96(a1)
    80002b90:	0685bd83          	ld	s11,104(a1)
    80002b94:	8082                	ret

0000000080002b96 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002b96:	1141                	addi	sp,sp,-16
    80002b98:	e406                	sd	ra,8(sp)
    80002b9a:	e022                	sd	s0,0(sp)
    80002b9c:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002b9e:	00005597          	auipc	a1,0x5
    80002ba2:	6ea58593          	addi	a1,a1,1770 # 80008288 <digits+0x248>
    80002ba6:	00016517          	auipc	a0,0x16
    80002baa:	e1a50513          	addi	a0,a0,-486 # 800189c0 <tickslock>
    80002bae:	ffffe097          	auipc	ra,0xffffe
    80002bb2:	f98080e7          	jalr	-104(ra) # 80000b46 <initlock>
}
    80002bb6:	60a2                	ld	ra,8(sp)
    80002bb8:	6402                	ld	s0,0(sp)
    80002bba:	0141                	addi	sp,sp,16
    80002bbc:	8082                	ret

0000000080002bbe <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002bbe:	1141                	addi	sp,sp,-16
    80002bc0:	e422                	sd	s0,8(sp)
    80002bc2:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002bc4:	00003797          	auipc	a5,0x3
    80002bc8:	7cc78793          	addi	a5,a5,1996 # 80006390 <kernelvec>
    80002bcc:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002bd0:	6422                	ld	s0,8(sp)
    80002bd2:	0141                	addi	sp,sp,16
    80002bd4:	8082                	ret

0000000080002bd6 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002bd6:	1141                	addi	sp,sp,-16
    80002bd8:	e406                	sd	ra,8(sp)
    80002bda:	e022                	sd	s0,0(sp)
    80002bdc:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002bde:	fffff097          	auipc	ra,0xfffff
    80002be2:	dce080e7          	jalr	-562(ra) # 800019ac <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002be6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002bea:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bec:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002bf0:	00004617          	auipc	a2,0x4
    80002bf4:	41060613          	addi	a2,a2,1040 # 80007000 <_trampoline>
    80002bf8:	00004697          	auipc	a3,0x4
    80002bfc:	40868693          	addi	a3,a3,1032 # 80007000 <_trampoline>
    80002c00:	8e91                	sub	a3,a3,a2
    80002c02:	040007b7          	lui	a5,0x4000
    80002c06:	17fd                	addi	a5,a5,-1
    80002c08:	07b2                	slli	a5,a5,0xc
    80002c0a:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c0c:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002c10:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002c12:	180026f3          	csrr	a3,satp
    80002c16:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002c18:	6d38                	ld	a4,88(a0)
    80002c1a:	6134                	ld	a3,64(a0)
    80002c1c:	6585                	lui	a1,0x1
    80002c1e:	96ae                	add	a3,a3,a1
    80002c20:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002c22:	6d38                	ld	a4,88(a0)
    80002c24:	00000697          	auipc	a3,0x0
    80002c28:	13e68693          	addi	a3,a3,318 # 80002d62 <usertrap>
    80002c2c:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002c2e:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002c30:	8692                	mv	a3,tp
    80002c32:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c34:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002c38:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002c3c:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c40:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002c44:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c46:	6f18                	ld	a4,24(a4)
    80002c48:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002c4c:	6928                	ld	a0,80(a0)
    80002c4e:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002c50:	00004717          	auipc	a4,0x4
    80002c54:	44c70713          	addi	a4,a4,1100 # 8000709c <userret>
    80002c58:	8f11                	sub	a4,a4,a2
    80002c5a:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002c5c:	577d                	li	a4,-1
    80002c5e:	177e                	slli	a4,a4,0x3f
    80002c60:	8d59                	or	a0,a0,a4
    80002c62:	9782                	jalr	a5
}
    80002c64:	60a2                	ld	ra,8(sp)
    80002c66:	6402                	ld	s0,0(sp)
    80002c68:	0141                	addi	sp,sp,16
    80002c6a:	8082                	ret

0000000080002c6c <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002c6c:	1101                	addi	sp,sp,-32
    80002c6e:	ec06                	sd	ra,24(sp)
    80002c70:	e822                	sd	s0,16(sp)
    80002c72:	e426                	sd	s1,8(sp)
    80002c74:	e04a                	sd	s2,0(sp)
    80002c76:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002c78:	00016917          	auipc	s2,0x16
    80002c7c:	d4890913          	addi	s2,s2,-696 # 800189c0 <tickslock>
    80002c80:	854a                	mv	a0,s2
    80002c82:	ffffe097          	auipc	ra,0xffffe
    80002c86:	f54080e7          	jalr	-172(ra) # 80000bd6 <acquire>
  ticks++;
    80002c8a:	00006497          	auipc	s1,0x6
    80002c8e:	e6648493          	addi	s1,s1,-410 # 80008af0 <ticks>
    80002c92:	409c                	lw	a5,0(s1)
    80002c94:	2785                	addiw	a5,a5,1
    80002c96:	c09c                	sw	a5,0(s1)
  update_time();
    80002c98:	fffff097          	auipc	ra,0xfffff
    80002c9c:	2c0080e7          	jalr	704(ra) # 80001f58 <update_time>
  wakeup(&ticks);
    80002ca0:	8526                	mv	a0,s1
    80002ca2:	00000097          	auipc	ra,0x0
    80002ca6:	90c080e7          	jalr	-1780(ra) # 800025ae <wakeup>
  release(&tickslock);
    80002caa:	854a                	mv	a0,s2
    80002cac:	ffffe097          	auipc	ra,0xffffe
    80002cb0:	fde080e7          	jalr	-34(ra) # 80000c8a <release>
}
    80002cb4:	60e2                	ld	ra,24(sp)
    80002cb6:	6442                	ld	s0,16(sp)
    80002cb8:	64a2                	ld	s1,8(sp)
    80002cba:	6902                	ld	s2,0(sp)
    80002cbc:	6105                	addi	sp,sp,32
    80002cbe:	8082                	ret

0000000080002cc0 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002cc0:	1101                	addi	sp,sp,-32
    80002cc2:	ec06                	sd	ra,24(sp)
    80002cc4:	e822                	sd	s0,16(sp)
    80002cc6:	e426                	sd	s1,8(sp)
    80002cc8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cca:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002cce:	00074d63          	bltz	a4,80002ce8 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002cd2:	57fd                	li	a5,-1
    80002cd4:	17fe                	slli	a5,a5,0x3f
    80002cd6:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002cd8:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002cda:	06f70363          	beq	a4,a5,80002d40 <devintr+0x80>
  }
}
    80002cde:	60e2                	ld	ra,24(sp)
    80002ce0:	6442                	ld	s0,16(sp)
    80002ce2:	64a2                	ld	s1,8(sp)
    80002ce4:	6105                	addi	sp,sp,32
    80002ce6:	8082                	ret
     (scause & 0xff) == 9){
    80002ce8:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002cec:	46a5                	li	a3,9
    80002cee:	fed792e3          	bne	a5,a3,80002cd2 <devintr+0x12>
    int irq = plic_claim();
    80002cf2:	00003097          	auipc	ra,0x3
    80002cf6:	7a6080e7          	jalr	1958(ra) # 80006498 <plic_claim>
    80002cfa:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002cfc:	47a9                	li	a5,10
    80002cfe:	02f50763          	beq	a0,a5,80002d2c <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002d02:	4785                	li	a5,1
    80002d04:	02f50963          	beq	a0,a5,80002d36 <devintr+0x76>
    return 1;
    80002d08:	4505                	li	a0,1
    } else if(irq){
    80002d0a:	d8f1                	beqz	s1,80002cde <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002d0c:	85a6                	mv	a1,s1
    80002d0e:	00005517          	auipc	a0,0x5
    80002d12:	58250513          	addi	a0,a0,1410 # 80008290 <digits+0x250>
    80002d16:	ffffe097          	auipc	ra,0xffffe
    80002d1a:	872080e7          	jalr	-1934(ra) # 80000588 <printf>
      plic_complete(irq);
    80002d1e:	8526                	mv	a0,s1
    80002d20:	00003097          	auipc	ra,0x3
    80002d24:	79c080e7          	jalr	1948(ra) # 800064bc <plic_complete>
    return 1;
    80002d28:	4505                	li	a0,1
    80002d2a:	bf55                	j	80002cde <devintr+0x1e>
      uartintr();
    80002d2c:	ffffe097          	auipc	ra,0xffffe
    80002d30:	c6e080e7          	jalr	-914(ra) # 8000099a <uartintr>
    80002d34:	b7ed                	j	80002d1e <devintr+0x5e>
      virtio_disk_intr();
    80002d36:	00004097          	auipc	ra,0x4
    80002d3a:	c52080e7          	jalr	-942(ra) # 80006988 <virtio_disk_intr>
    80002d3e:	b7c5                	j	80002d1e <devintr+0x5e>
    if(cpuid() == 0){
    80002d40:	fffff097          	auipc	ra,0xfffff
    80002d44:	c40080e7          	jalr	-960(ra) # 80001980 <cpuid>
    80002d48:	c901                	beqz	a0,80002d58 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002d4a:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002d4e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002d50:	14479073          	csrw	sip,a5
    return 2;
    80002d54:	4509                	li	a0,2
    80002d56:	b761                	j	80002cde <devintr+0x1e>
      clockintr();
    80002d58:	00000097          	auipc	ra,0x0
    80002d5c:	f14080e7          	jalr	-236(ra) # 80002c6c <clockintr>
    80002d60:	b7ed                	j	80002d4a <devintr+0x8a>

0000000080002d62 <usertrap>:
{
    80002d62:	1101                	addi	sp,sp,-32
    80002d64:	ec06                	sd	ra,24(sp)
    80002d66:	e822                	sd	s0,16(sp)
    80002d68:	e426                	sd	s1,8(sp)
    80002d6a:	e04a                	sd	s2,0(sp)
    80002d6c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d6e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002d72:	1007f793          	andi	a5,a5,256
    80002d76:	e3b1                	bnez	a5,80002dba <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002d78:	00003797          	auipc	a5,0x3
    80002d7c:	61878793          	addi	a5,a5,1560 # 80006390 <kernelvec>
    80002d80:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002d84:	fffff097          	auipc	ra,0xfffff
    80002d88:	c28080e7          	jalr	-984(ra) # 800019ac <myproc>
    80002d8c:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002d8e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d90:	14102773          	csrr	a4,sepc
    80002d94:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d96:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002d9a:	47a1                	li	a5,8
    80002d9c:	02f70763          	beq	a4,a5,80002dca <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002da0:	00000097          	auipc	ra,0x0
    80002da4:	f20080e7          	jalr	-224(ra) # 80002cc0 <devintr>
    80002da8:	892a                	mv	s2,a0
    80002daa:	c92d                	beqz	a0,80002e1c <usertrap+0xba>
  if(killed(p))
    80002dac:	8526                	mv	a0,s1
    80002dae:	00000097          	auipc	ra,0x0
    80002db2:	a6a080e7          	jalr	-1430(ra) # 80002818 <killed>
    80002db6:	c555                	beqz	a0,80002e62 <usertrap+0x100>
    80002db8:	a045                	j	80002e58 <usertrap+0xf6>
    panic("usertrap: not from user mode");
    80002dba:	00005517          	auipc	a0,0x5
    80002dbe:	4f650513          	addi	a0,a0,1270 # 800082b0 <digits+0x270>
    80002dc2:	ffffd097          	auipc	ra,0xffffd
    80002dc6:	77c080e7          	jalr	1916(ra) # 8000053e <panic>
    if(killed(p))
    80002dca:	00000097          	auipc	ra,0x0
    80002dce:	a4e080e7          	jalr	-1458(ra) # 80002818 <killed>
    80002dd2:	ed1d                	bnez	a0,80002e10 <usertrap+0xae>
    p->trapframe->epc += 4;
    80002dd4:	6cb8                	ld	a4,88(s1)
    80002dd6:	6f1c                	ld	a5,24(a4)
    80002dd8:	0791                	addi	a5,a5,4
    80002dda:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ddc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002de0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002de4:	10079073          	csrw	sstatus,a5
    syscall();
    80002de8:	00000097          	auipc	ra,0x0
    80002dec:	336080e7          	jalr	822(ra) # 8000311e <syscall>
  if(killed(p))
    80002df0:	8526                	mv	a0,s1
    80002df2:	00000097          	auipc	ra,0x0
    80002df6:	a26080e7          	jalr	-1498(ra) # 80002818 <killed>
    80002dfa:	ed31                	bnez	a0,80002e56 <usertrap+0xf4>
  usertrapret();
    80002dfc:	00000097          	auipc	ra,0x0
    80002e00:	dda080e7          	jalr	-550(ra) # 80002bd6 <usertrapret>
}
    80002e04:	60e2                	ld	ra,24(sp)
    80002e06:	6442                	ld	s0,16(sp)
    80002e08:	64a2                	ld	s1,8(sp)
    80002e0a:	6902                	ld	s2,0(sp)
    80002e0c:	6105                	addi	sp,sp,32
    80002e0e:	8082                	ret
      exit(-1);
    80002e10:	557d                	li	a0,-1
    80002e12:	00000097          	auipc	ra,0x0
    80002e16:	886080e7          	jalr	-1914(ra) # 80002698 <exit>
    80002e1a:	bf6d                	j	80002dd4 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e1c:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002e20:	5890                	lw	a2,48(s1)
    80002e22:	00005517          	auipc	a0,0x5
    80002e26:	4ae50513          	addi	a0,a0,1198 # 800082d0 <digits+0x290>
    80002e2a:	ffffd097          	auipc	ra,0xffffd
    80002e2e:	75e080e7          	jalr	1886(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e32:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002e36:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002e3a:	00005517          	auipc	a0,0x5
    80002e3e:	4c650513          	addi	a0,a0,1222 # 80008300 <digits+0x2c0>
    80002e42:	ffffd097          	auipc	ra,0xffffd
    80002e46:	746080e7          	jalr	1862(ra) # 80000588 <printf>
    setkilled(p);
    80002e4a:	8526                	mv	a0,s1
    80002e4c:	00000097          	auipc	ra,0x0
    80002e50:	9a0080e7          	jalr	-1632(ra) # 800027ec <setkilled>
    80002e54:	bf71                	j	80002df0 <usertrap+0x8e>
  if(killed(p))
    80002e56:	4901                	li	s2,0
    exit(-1);
    80002e58:	557d                	li	a0,-1
    80002e5a:	00000097          	auipc	ra,0x0
    80002e5e:	83e080e7          	jalr	-1986(ra) # 80002698 <exit>
  if (which_dev == 2 && p->alarm_on == 1 && p->handlerpermission == 1) {
    80002e62:	4789                	li	a5,2
    80002e64:	f8f91ce3          	bne	s2,a5,80002dfc <usertrap+0x9a>
    80002e68:	1984b703          	ld	a4,408(s1)
    80002e6c:	4785                	li	a5,1
    80002e6e:	1782                	slli	a5,a5,0x20
    80002e70:	0785                	addi	a5,a5,1
    80002e72:	00f70b63          	beq	a4,a5,80002e88 <usertrap+0x126>
    if(p->state == RUNNING)
    80002e76:	4c98                	lw	a4,24(s1)
    80002e78:	4791                	li	a5,4
    80002e7a:	04f70563          	beq	a4,a5,80002ec4 <usertrap+0x162>
    yield();
    80002e7e:	fffff097          	auipc	ra,0xfffff
    80002e82:	538080e7          	jalr	1336(ra) # 800023b6 <yield>
    80002e86:	bf9d                	j	80002dfc <usertrap+0x9a>
      struct trapframe *tf = kalloc();
    80002e88:	ffffe097          	auipc	ra,0xffffe
    80002e8c:	c5e080e7          	jalr	-930(ra) # 80000ae6 <kalloc>
    80002e90:	892a                	mv	s2,a0
      memmove(tf, p->trapframe, PGSIZE);
    80002e92:	6605                	lui	a2,0x1
    80002e94:	6cac                	ld	a1,88(s1)
    80002e96:	ffffe097          	auipc	ra,0xffffe
    80002e9a:	e98080e7          	jalr	-360(ra) # 80000d2e <memmove>
      p->alarm_tf = tf;
    80002e9e:	1924b823          	sd	s2,400(s1)
      p->cur_ticks++;
    80002ea2:	18c4a783          	lw	a5,396(s1)
    80002ea6:	2785                	addiw	a5,a5,1
    80002ea8:	18f4a623          	sw	a5,396(s1)
      if (p->cur_ticks % p->ticks == 0){
    80002eac:	1884a703          	lw	a4,392(s1)
    80002eb0:	02e7e7bb          	remw	a5,a5,a4
    80002eb4:	f3e9                	bnez	a5,80002e76 <usertrap+0x114>
        p->trapframe->epc = p->handler;
    80002eb6:	6cbc                	ld	a5,88(s1)
    80002eb8:	1804b703          	ld	a4,384(s1)
    80002ebc:	ef98                	sd	a4,24(a5)
        p->handlerpermission = 0;
    80002ebe:	1804ae23          	sw	zero,412(s1)
    80002ec2:	bf55                	j	80002e76 <usertrap+0x114>
      p->runtime++;
    80002ec4:	1a84b783          	ld	a5,424(s1)
    80002ec8:	0785                	addi	a5,a5,1
    80002eca:	1af4b423          	sd	a5,424(s1)
    80002ece:	bf45                	j	80002e7e <usertrap+0x11c>

0000000080002ed0 <kerneltrap>:
{
    80002ed0:	7179                	addi	sp,sp,-48
    80002ed2:	f406                	sd	ra,40(sp)
    80002ed4:	f022                	sd	s0,32(sp)
    80002ed6:	ec26                	sd	s1,24(sp)
    80002ed8:	e84a                	sd	s2,16(sp)
    80002eda:	e44e                	sd	s3,8(sp)
    80002edc:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ede:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ee2:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ee6:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002eea:	1004f793          	andi	a5,s1,256
    80002eee:	cb85                	beqz	a5,80002f1e <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ef0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002ef4:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002ef6:	ef85                	bnez	a5,80002f2e <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002ef8:	00000097          	auipc	ra,0x0
    80002efc:	dc8080e7          	jalr	-568(ra) # 80002cc0 <devintr>
    80002f00:	cd1d                	beqz	a0,80002f3e <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002f02:	4789                	li	a5,2
    80002f04:	06f50a63          	beq	a0,a5,80002f78 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002f08:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002f0c:	10049073          	csrw	sstatus,s1
}
    80002f10:	70a2                	ld	ra,40(sp)
    80002f12:	7402                	ld	s0,32(sp)
    80002f14:	64e2                	ld	s1,24(sp)
    80002f16:	6942                	ld	s2,16(sp)
    80002f18:	69a2                	ld	s3,8(sp)
    80002f1a:	6145                	addi	sp,sp,48
    80002f1c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002f1e:	00005517          	auipc	a0,0x5
    80002f22:	40250513          	addi	a0,a0,1026 # 80008320 <digits+0x2e0>
    80002f26:	ffffd097          	auipc	ra,0xffffd
    80002f2a:	618080e7          	jalr	1560(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002f2e:	00005517          	auipc	a0,0x5
    80002f32:	41a50513          	addi	a0,a0,1050 # 80008348 <digits+0x308>
    80002f36:	ffffd097          	auipc	ra,0xffffd
    80002f3a:	608080e7          	jalr	1544(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002f3e:	85ce                	mv	a1,s3
    80002f40:	00005517          	auipc	a0,0x5
    80002f44:	42850513          	addi	a0,a0,1064 # 80008368 <digits+0x328>
    80002f48:	ffffd097          	auipc	ra,0xffffd
    80002f4c:	640080e7          	jalr	1600(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002f50:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002f54:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002f58:	00005517          	auipc	a0,0x5
    80002f5c:	42050513          	addi	a0,a0,1056 # 80008378 <digits+0x338>
    80002f60:	ffffd097          	auipc	ra,0xffffd
    80002f64:	628080e7          	jalr	1576(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002f68:	00005517          	auipc	a0,0x5
    80002f6c:	42850513          	addi	a0,a0,1064 # 80008390 <digits+0x350>
    80002f70:	ffffd097          	auipc	ra,0xffffd
    80002f74:	5ce080e7          	jalr	1486(ra) # 8000053e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002f78:	fffff097          	auipc	ra,0xfffff
    80002f7c:	a34080e7          	jalr	-1484(ra) # 800019ac <myproc>
    80002f80:	d541                	beqz	a0,80002f08 <kerneltrap+0x38>
    80002f82:	fffff097          	auipc	ra,0xfffff
    80002f86:	a2a080e7          	jalr	-1494(ra) # 800019ac <myproc>
    80002f8a:	4d18                	lw	a4,24(a0)
    80002f8c:	4791                	li	a5,4
    80002f8e:	f6f71de3          	bne	a4,a5,80002f08 <kerneltrap+0x38>
    yield();
    80002f92:	fffff097          	auipc	ra,0xfffff
    80002f96:	424080e7          	jalr	1060(ra) # 800023b6 <yield>
    80002f9a:	b7bd                	j	80002f08 <kerneltrap+0x38>

0000000080002f9c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002f9c:	1101                	addi	sp,sp,-32
    80002f9e:	ec06                	sd	ra,24(sp)
    80002fa0:	e822                	sd	s0,16(sp)
    80002fa2:	e426                	sd	s1,8(sp)
    80002fa4:	1000                	addi	s0,sp,32
    80002fa6:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002fa8:	fffff097          	auipc	ra,0xfffff
    80002fac:	a04080e7          	jalr	-1532(ra) # 800019ac <myproc>
  switch (n) {
    80002fb0:	4795                	li	a5,5
    80002fb2:	0497e163          	bltu	a5,s1,80002ff4 <argraw+0x58>
    80002fb6:	048a                	slli	s1,s1,0x2
    80002fb8:	00005717          	auipc	a4,0x5
    80002fbc:	53070713          	addi	a4,a4,1328 # 800084e8 <digits+0x4a8>
    80002fc0:	94ba                	add	s1,s1,a4
    80002fc2:	409c                	lw	a5,0(s1)
    80002fc4:	97ba                	add	a5,a5,a4
    80002fc6:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002fc8:	6d3c                	ld	a5,88(a0)
    80002fca:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002fcc:	60e2                	ld	ra,24(sp)
    80002fce:	6442                	ld	s0,16(sp)
    80002fd0:	64a2                	ld	s1,8(sp)
    80002fd2:	6105                	addi	sp,sp,32
    80002fd4:	8082                	ret
    return p->trapframe->a1;
    80002fd6:	6d3c                	ld	a5,88(a0)
    80002fd8:	7fa8                	ld	a0,120(a5)
    80002fda:	bfcd                	j	80002fcc <argraw+0x30>
    return p->trapframe->a2;
    80002fdc:	6d3c                	ld	a5,88(a0)
    80002fde:	63c8                	ld	a0,128(a5)
    80002fe0:	b7f5                	j	80002fcc <argraw+0x30>
    return p->trapframe->a3;
    80002fe2:	6d3c                	ld	a5,88(a0)
    80002fe4:	67c8                	ld	a0,136(a5)
    80002fe6:	b7dd                	j	80002fcc <argraw+0x30>
    return p->trapframe->a4;
    80002fe8:	6d3c                	ld	a5,88(a0)
    80002fea:	6bc8                	ld	a0,144(a5)
    80002fec:	b7c5                	j	80002fcc <argraw+0x30>
    return p->trapframe->a5;
    80002fee:	6d3c                	ld	a5,88(a0)
    80002ff0:	6fc8                	ld	a0,152(a5)
    80002ff2:	bfe9                	j	80002fcc <argraw+0x30>
  panic("argraw");
    80002ff4:	00005517          	auipc	a0,0x5
    80002ff8:	3ac50513          	addi	a0,a0,940 # 800083a0 <digits+0x360>
    80002ffc:	ffffd097          	auipc	ra,0xffffd
    80003000:	542080e7          	jalr	1346(ra) # 8000053e <panic>

0000000080003004 <fetchaddr>:
{
    80003004:	1101                	addi	sp,sp,-32
    80003006:	ec06                	sd	ra,24(sp)
    80003008:	e822                	sd	s0,16(sp)
    8000300a:	e426                	sd	s1,8(sp)
    8000300c:	e04a                	sd	s2,0(sp)
    8000300e:	1000                	addi	s0,sp,32
    80003010:	84aa                	mv	s1,a0
    80003012:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003014:	fffff097          	auipc	ra,0xfffff
    80003018:	998080e7          	jalr	-1640(ra) # 800019ac <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    8000301c:	653c                	ld	a5,72(a0)
    8000301e:	02f4f863          	bgeu	s1,a5,8000304e <fetchaddr+0x4a>
    80003022:	00848713          	addi	a4,s1,8
    80003026:	02e7e663          	bltu	a5,a4,80003052 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000302a:	46a1                	li	a3,8
    8000302c:	8626                	mv	a2,s1
    8000302e:	85ca                	mv	a1,s2
    80003030:	6928                	ld	a0,80(a0)
    80003032:	ffffe097          	auipc	ra,0xffffe
    80003036:	6c2080e7          	jalr	1730(ra) # 800016f4 <copyin>
    8000303a:	00a03533          	snez	a0,a0
    8000303e:	40a00533          	neg	a0,a0
}
    80003042:	60e2                	ld	ra,24(sp)
    80003044:	6442                	ld	s0,16(sp)
    80003046:	64a2                	ld	s1,8(sp)
    80003048:	6902                	ld	s2,0(sp)
    8000304a:	6105                	addi	sp,sp,32
    8000304c:	8082                	ret
    return -1;
    8000304e:	557d                	li	a0,-1
    80003050:	bfcd                	j	80003042 <fetchaddr+0x3e>
    80003052:	557d                	li	a0,-1
    80003054:	b7fd                	j	80003042 <fetchaddr+0x3e>

0000000080003056 <fetchstr>:
{
    80003056:	7179                	addi	sp,sp,-48
    80003058:	f406                	sd	ra,40(sp)
    8000305a:	f022                	sd	s0,32(sp)
    8000305c:	ec26                	sd	s1,24(sp)
    8000305e:	e84a                	sd	s2,16(sp)
    80003060:	e44e                	sd	s3,8(sp)
    80003062:	1800                	addi	s0,sp,48
    80003064:	892a                	mv	s2,a0
    80003066:	84ae                	mv	s1,a1
    80003068:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000306a:	fffff097          	auipc	ra,0xfffff
    8000306e:	942080e7          	jalr	-1726(ra) # 800019ac <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80003072:	86ce                	mv	a3,s3
    80003074:	864a                	mv	a2,s2
    80003076:	85a6                	mv	a1,s1
    80003078:	6928                	ld	a0,80(a0)
    8000307a:	ffffe097          	auipc	ra,0xffffe
    8000307e:	708080e7          	jalr	1800(ra) # 80001782 <copyinstr>
    80003082:	00054e63          	bltz	a0,8000309e <fetchstr+0x48>
  return strlen(buf);
    80003086:	8526                	mv	a0,s1
    80003088:	ffffe097          	auipc	ra,0xffffe
    8000308c:	dc6080e7          	jalr	-570(ra) # 80000e4e <strlen>
}
    80003090:	70a2                	ld	ra,40(sp)
    80003092:	7402                	ld	s0,32(sp)
    80003094:	64e2                	ld	s1,24(sp)
    80003096:	6942                	ld	s2,16(sp)
    80003098:	69a2                	ld	s3,8(sp)
    8000309a:	6145                	addi	sp,sp,48
    8000309c:	8082                	ret
    return -1;
    8000309e:	557d                	li	a0,-1
    800030a0:	bfc5                	j	80003090 <fetchstr+0x3a>

00000000800030a2 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    800030a2:	1101                	addi	sp,sp,-32
    800030a4:	ec06                	sd	ra,24(sp)
    800030a6:	e822                	sd	s0,16(sp)
    800030a8:	e426                	sd	s1,8(sp)
    800030aa:	1000                	addi	s0,sp,32
    800030ac:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800030ae:	00000097          	auipc	ra,0x0
    800030b2:	eee080e7          	jalr	-274(ra) # 80002f9c <argraw>
    800030b6:	c088                	sw	a0,0(s1)
  return 0;
}
    800030b8:	4501                	li	a0,0
    800030ba:	60e2                	ld	ra,24(sp)
    800030bc:	6442                	ld	s0,16(sp)
    800030be:	64a2                	ld	s1,8(sp)
    800030c0:	6105                	addi	sp,sp,32
    800030c2:	8082                	ret

00000000800030c4 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    800030c4:	1101                	addi	sp,sp,-32
    800030c6:	ec06                	sd	ra,24(sp)
    800030c8:	e822                	sd	s0,16(sp)
    800030ca:	e426                	sd	s1,8(sp)
    800030cc:	1000                	addi	s0,sp,32
    800030ce:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800030d0:	00000097          	auipc	ra,0x0
    800030d4:	ecc080e7          	jalr	-308(ra) # 80002f9c <argraw>
    800030d8:	e088                	sd	a0,0(s1)
  return 0;
}
    800030da:	4501                	li	a0,0
    800030dc:	60e2                	ld	ra,24(sp)
    800030de:	6442                	ld	s0,16(sp)
    800030e0:	64a2                	ld	s1,8(sp)
    800030e2:	6105                	addi	sp,sp,32
    800030e4:	8082                	ret

00000000800030e6 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800030e6:	7179                	addi	sp,sp,-48
    800030e8:	f406                	sd	ra,40(sp)
    800030ea:	f022                	sd	s0,32(sp)
    800030ec:	ec26                	sd	s1,24(sp)
    800030ee:	e84a                	sd	s2,16(sp)
    800030f0:	1800                	addi	s0,sp,48
    800030f2:	84ae                	mv	s1,a1
    800030f4:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    800030f6:	fd840593          	addi	a1,s0,-40
    800030fa:	00000097          	auipc	ra,0x0
    800030fe:	fca080e7          	jalr	-54(ra) # 800030c4 <argaddr>
  return fetchstr(addr, buf, max);
    80003102:	864a                	mv	a2,s2
    80003104:	85a6                	mv	a1,s1
    80003106:	fd843503          	ld	a0,-40(s0)
    8000310a:	00000097          	auipc	ra,0x0
    8000310e:	f4c080e7          	jalr	-180(ra) # 80003056 <fetchstr>
}
    80003112:	70a2                	ld	ra,40(sp)
    80003114:	7402                	ld	s0,32(sp)
    80003116:	64e2                	ld	s1,24(sp)
    80003118:	6942                	ld	s2,16(sp)
    8000311a:	6145                	addi	sp,sp,48
    8000311c:	8082                	ret

000000008000311e <syscall>:
    [SYS_setpriority] 1,
};

void
syscall(void)
{
    8000311e:	7179                	addi	sp,sp,-48
    80003120:	f406                	sd	ra,40(sp)
    80003122:	f022                	sd	s0,32(sp)
    80003124:	ec26                	sd	s1,24(sp)
    80003126:	e84a                	sd	s2,16(sp)
    80003128:	e44e                	sd	s3,8(sp)
    8000312a:	e052                	sd	s4,0(sp)
    8000312c:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    8000312e:	fffff097          	auipc	ra,0xfffff
    80003132:	87e080e7          	jalr	-1922(ra) # 800019ac <myproc>
    80003136:	892a                	mv	s2,a0

  num = p->trapframe->a7;
    80003138:	6d24                	ld	s1,88(a0)
    8000313a:	74dc                	ld	a5,168(s1)
    8000313c:	0007899b          	sext.w	s3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) 
    80003140:	37fd                	addiw	a5,a5,-1
    80003142:	4769                	li	a4,26
    80003144:	0af76163          	bltu	a4,a5,800031e6 <syscall+0xc8>
    80003148:	00399713          	slli	a4,s3,0x3
    8000314c:	00005797          	auipc	a5,0x5
    80003150:	3b478793          	addi	a5,a5,948 # 80008500 <syscalls>
    80003154:	97ba                	add	a5,a5,a4
    80003156:	639c                	ld	a5,0(a5)
    80003158:	c7d9                	beqz	a5,800031e6 <syscall+0xc8>
  {
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    8000315a:	9782                	jalr	a5
    8000315c:	f8a8                	sd	a0,112(s1)
    if ((p->mask >> num) & 1)
    8000315e:	16892483          	lw	s1,360(s2)
    80003162:	4134d4bb          	sraw	s1,s1,s3
    80003166:	8885                	andi	s1,s1,1
    80003168:	c0c5                	beqz	s1,80003208 <syscall+0xea>
    {
      /* Modified for A4: Added entire section for trace, prints output for each syscall traced */
  	  printf("%d: syscall %s ( %d ",p->pid, syscallnames[num], p->trapframe->a0);
    8000316a:	05893703          	ld	a4,88(s2)
    8000316e:	00399693          	slli	a3,s3,0x3
    80003172:	00006797          	auipc	a5,0x6
    80003176:	86678793          	addi	a5,a5,-1946 # 800089d8 <syscallnames>
    8000317a:	97b6                	add	a5,a5,a3
    8000317c:	7b34                	ld	a3,112(a4)
    8000317e:	6390                	ld	a2,0(a5)
    80003180:	03092583          	lw	a1,48(s2)
    80003184:	00005517          	auipc	a0,0x5
    80003188:	22450513          	addi	a0,a0,548 # 800083a8 <digits+0x368>
    8000318c:	ffffd097          	auipc	ra,0xffffd
    80003190:	3fc080e7          	jalr	1020(ra) # 80000588 <printf>
      for (int i = 1; i < syscallnum[num]; i++) /* Modified for A4: 'num' tracks number of registers used by syscall and prints its register values  */
    80003194:	098a                	slli	s3,s3,0x2
    80003196:	00005797          	auipc	a5,0x5
    8000319a:	36a78793          	addi	a5,a5,874 # 80008500 <syscalls>
    8000319e:	99be                	add	s3,s3,a5
    800031a0:	0e09a983          	lw	s3,224(s3)
    800031a4:	4785                	li	a5,1
    800031a6:	0337d463          	bge	a5,s3,800031ce <syscall+0xb0>
        printf("%d ", argraw(i));
    800031aa:	00005a17          	auipc	s4,0x5
    800031ae:	216a0a13          	addi	s4,s4,534 # 800083c0 <digits+0x380>
    800031b2:	8526                	mv	a0,s1
    800031b4:	00000097          	auipc	ra,0x0
    800031b8:	de8080e7          	jalr	-536(ra) # 80002f9c <argraw>
    800031bc:	85aa                	mv	a1,a0
    800031be:	8552                	mv	a0,s4
    800031c0:	ffffd097          	auipc	ra,0xffffd
    800031c4:	3c8080e7          	jalr	968(ra) # 80000588 <printf>
      for (int i = 1; i < syscallnum[num]; i++) /* Modified for A4: 'num' tracks number of registers used by syscall and prints its register values  */
    800031c8:	2485                	addiw	s1,s1,1
    800031ca:	ff3494e3          	bne	s1,s3,800031b2 <syscall+0x94>
      printf(") -> %d\n", p->trapframe->a0);
    800031ce:	05893783          	ld	a5,88(s2)
    800031d2:	7bac                	ld	a1,112(a5)
    800031d4:	00005517          	auipc	a0,0x5
    800031d8:	1f450513          	addi	a0,a0,500 # 800083c8 <digits+0x388>
    800031dc:	ffffd097          	auipc	ra,0xffffd
    800031e0:	3ac080e7          	jalr	940(ra) # 80000588 <printf>
    800031e4:	a015                	j	80003208 <syscall+0xea>
    }	
  } 
  else 
  {
    printf("%d %s: unknown sys call %d\n",
    800031e6:	86ce                	mv	a3,s3
    800031e8:	15890613          	addi	a2,s2,344
    800031ec:	03092583          	lw	a1,48(s2)
    800031f0:	00005517          	auipc	a0,0x5
    800031f4:	1e850513          	addi	a0,a0,488 # 800083d8 <digits+0x398>
    800031f8:	ffffd097          	auipc	ra,0xffffd
    800031fc:	390080e7          	jalr	912(ra) # 80000588 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003200:	05893783          	ld	a5,88(s2)
    80003204:	577d                	li	a4,-1
    80003206:	fbb8                	sd	a4,112(a5)
  
  // if (p->mask >> num)
  // {
  // 	printf("%d: syscall %s -> %d\n",p->pid, syscallnames[num], p->trapframe->a0);
  // }	
}
    80003208:	70a2                	ld	ra,40(sp)
    8000320a:	7402                	ld	s0,32(sp)
    8000320c:	64e2                	ld	s1,24(sp)
    8000320e:	6942                	ld	s2,16(sp)
    80003210:	69a2                	ld	s3,8(sp)
    80003212:	6a02                	ld	s4,0(sp)
    80003214:	6145                	addi	sp,sp,48
    80003216:	8082                	ret

0000000080003218 <sys_trace>:
#include "proc.h"


uint64
sys_trace(void)
{
    80003218:	1101                	addi	sp,sp,-32
    8000321a:	ec06                	sd	ra,24(sp)
    8000321c:	e822                	sd	s0,16(sp)
    8000321e:	1000                	addi	s0,sp,32
  int mask;
	if(argint(0, &mask) < 0)
    80003220:	fec40593          	addi	a1,s0,-20
    80003224:	4501                	li	a0,0
    80003226:	00000097          	auipc	ra,0x0
    8000322a:	e7c080e7          	jalr	-388(ra) # 800030a2 <argint>
	{
		return -1;
    8000322e:	57fd                	li	a5,-1
	if(argint(0, &mask) < 0)
    80003230:	00054b63          	bltz	a0,80003246 <sys_trace+0x2e>
	}
  myproc()->mask = mask;
    80003234:	ffffe097          	auipc	ra,0xffffe
    80003238:	778080e7          	jalr	1912(ra) # 800019ac <myproc>
    8000323c:	fec42783          	lw	a5,-20(s0)
    80003240:	16f52423          	sw	a5,360(a0)
	return 0;
    80003244:	4781                	li	a5,0
}	/* Modified for A4: Added trace */
    80003246:	853e                	mv	a0,a5
    80003248:	60e2                	ld	ra,24(sp)
    8000324a:	6442                	ld	s0,16(sp)
    8000324c:	6105                	addi	sp,sp,32
    8000324e:	8082                	ret

0000000080003250 <sys_sigalarm>:

/* Modified for A4: Added trace */
uint64 
sys_sigalarm(void)
{
    80003250:	1101                	addi	sp,sp,-32
    80003252:	ec06                	sd	ra,24(sp)
    80003254:	e822                	sd	s0,16(sp)
    80003256:	1000                	addi	s0,sp,32
  uint64 handleraddr;
  int ticks;
  if(argint(0, &ticks) < 0)
    80003258:	fe440593          	addi	a1,s0,-28
    8000325c:	4501                	li	a0,0
    8000325e:	00000097          	auipc	ra,0x0
    80003262:	e44080e7          	jalr	-444(ra) # 800030a2 <argint>
    return -1;
    80003266:	57fd                	li	a5,-1
  if(argint(0, &ticks) < 0)
    80003268:	04054463          	bltz	a0,800032b0 <sys_sigalarm+0x60>
  if(argaddr(1, &handleraddr) < 0)
    8000326c:	fe840593          	addi	a1,s0,-24
    80003270:	4505                	li	a0,1
    80003272:	00000097          	auipc	ra,0x0
    80003276:	e52080e7          	jalr	-430(ra) # 800030c4 <argaddr>
    return -1;
    8000327a:	57fd                	li	a5,-1
  if(argaddr(1, &handleraddr) < 0)
    8000327c:	02054a63          	bltz	a0,800032b0 <sys_sigalarm+0x60>

  myproc()->ticks = ticks;
    80003280:	ffffe097          	auipc	ra,0xffffe
    80003284:	72c080e7          	jalr	1836(ra) # 800019ac <myproc>
    80003288:	fe442783          	lw	a5,-28(s0)
    8000328c:	18f52423          	sw	a5,392(a0)
  myproc()->handler = handleraddr;
    80003290:	ffffe097          	auipc	ra,0xffffe
    80003294:	71c080e7          	jalr	1820(ra) # 800019ac <myproc>
    80003298:	fe843783          	ld	a5,-24(s0)
    8000329c:	18f53023          	sd	a5,384(a0)
  myproc()->alarm_on = 1;
    800032a0:	ffffe097          	auipc	ra,0xffffe
    800032a4:	70c080e7          	jalr	1804(ra) # 800019ac <myproc>
    800032a8:	4785                	li	a5,1
    800032aa:	18f52c23          	sw	a5,408(a0)
  //myproc()->a1 = myproc()->trapframe->a0;
  //myproc()->a2 = myproc()->trapframe->a1;

  return 0;
    800032ae:	4781                	li	a5,0
}
    800032b0:	853e                	mv	a0,a5
    800032b2:	60e2                	ld	ra,24(sp)
    800032b4:	6442                	ld	s0,16(sp)
    800032b6:	6105                	addi	sp,sp,32
    800032b8:	8082                	ret

00000000800032ba <sys_sigreturn>:

/* Modified for A4: Added trace */
uint64 
sys_sigreturn(void)
{
    800032ba:	1101                	addi	sp,sp,-32
    800032bc:	ec06                	sd	ra,24(sp)
    800032be:	e822                	sd	s0,16(sp)
    800032c0:	e426                	sd	s1,8(sp)
    800032c2:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800032c4:	ffffe097          	auipc	ra,0xffffe
    800032c8:	6e8080e7          	jalr	1768(ra) # 800019ac <myproc>
    800032cc:	84aa                	mv	s1,a0
  memmove(p->trapframe, p->alarm_tf, PGSIZE);
    800032ce:	6605                	lui	a2,0x1
    800032d0:	19053583          	ld	a1,400(a0)
    800032d4:	6d28                	ld	a0,88(a0)
    800032d6:	ffffe097          	auipc	ra,0xffffe
    800032da:	a58080e7          	jalr	-1448(ra) # 80000d2e <memmove>
  //myproc()->trapframe->a0 = myproc()->a1;
  //myproc()->trapframe->a1 = myproc()->a2;
  kfree(p->alarm_tf);
    800032de:	1904b503          	ld	a0,400(s1)
    800032e2:	ffffd097          	auipc	ra,0xffffd
    800032e6:	708080e7          	jalr	1800(ra) # 800009ea <kfree>
  p->handlerpermission = 1;
    800032ea:	4785                	li	a5,1
    800032ec:	18f4ae23          	sw	a5,412(s1)
  return myproc()->trapframe->a0;
    800032f0:	ffffe097          	auipc	ra,0xffffe
    800032f4:	6bc080e7          	jalr	1724(ra) # 800019ac <myproc>
    800032f8:	6d3c                	ld	a5,88(a0)
}
    800032fa:	7ba8                	ld	a0,112(a5)
    800032fc:	60e2                	ld	ra,24(sp)
    800032fe:	6442                	ld	s0,16(sp)
    80003300:	64a2                	ld	s1,8(sp)
    80003302:	6105                	addi	sp,sp,32
    80003304:	8082                	ret

0000000080003306 <sys_settickets>:

uint64 
sys_settickets(void)
{
    80003306:	7179                	addi	sp,sp,-48
    80003308:	f406                	sd	ra,40(sp)
    8000330a:	f022                	sd	s0,32(sp)
    8000330c:	ec26                	sd	s1,24(sp)
    8000330e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80003310:	ffffe097          	auipc	ra,0xffffe
    80003314:	69c080e7          	jalr	1692(ra) # 800019ac <myproc>
    80003318:	84aa                	mv	s1,a0
  int tickets;
  if(argint(0, &tickets) < 0)
    8000331a:	fdc40593          	addi	a1,s0,-36
    8000331e:	4501                	li	a0,0
    80003320:	00000097          	auipc	ra,0x0
    80003324:	d82080e7          	jalr	-638(ra) # 800030a2 <argint>
    80003328:	00054c63          	bltz	a0,80003340 <sys_settickets+0x3a>
    return -1;
  p->tickets = tickets;
    8000332c:	fdc42783          	lw	a5,-36(s0)
    80003330:	1af4a023          	sw	a5,416(s1)
  return 0; 
    80003334:	4501                	li	a0,0
}
    80003336:	70a2                	ld	ra,40(sp)
    80003338:	7402                	ld	s0,32(sp)
    8000333a:	64e2                	ld	s1,24(sp)
    8000333c:	6145                	addi	sp,sp,48
    8000333e:	8082                	ret
    return -1;
    80003340:	557d                	li	a0,-1
    80003342:	bfd5                	j	80003336 <sys_settickets+0x30>

0000000080003344 <sys_setpriority>:

uint64
sys_setpriority()
{
    80003344:	1101                	addi	sp,sp,-32
    80003346:	ec06                	sd	ra,24(sp)
    80003348:	e822                	sd	s0,16(sp)
    8000334a:	1000                	addi	s0,sp,32
  int pid, priority;
  int arg_num[2] = {0, 1};

  if(argint(arg_num[0], &priority) < 0)
    8000334c:	fe840593          	addi	a1,s0,-24
    80003350:	4501                	li	a0,0
    80003352:	00000097          	auipc	ra,0x0
    80003356:	d50080e7          	jalr	-688(ra) # 800030a2 <argint>
  {
    return -1;
    8000335a:	57fd                	li	a5,-1
  if(argint(arg_num[0], &priority) < 0)
    8000335c:	02054563          	bltz	a0,80003386 <sys_setpriority+0x42>
  }
  if(argint(arg_num[1], &pid) < 0)
    80003360:	fec40593          	addi	a1,s0,-20
    80003364:	4505                	li	a0,1
    80003366:	00000097          	auipc	ra,0x0
    8000336a:	d3c080e7          	jalr	-708(ra) # 800030a2 <argint>
  {
    return -1;
    8000336e:	57fd                	li	a5,-1
  if(argint(arg_num[1], &pid) < 0)
    80003370:	00054b63          	bltz	a0,80003386 <sys_setpriority+0x42>
  }
   
  return setpriority(priority, pid);
    80003374:	fec42583          	lw	a1,-20(s0)
    80003378:	fe842503          	lw	a0,-24(s0)
    8000337c:	fffff097          	auipc	ra,0xfffff
    80003380:	72c080e7          	jalr	1836(ra) # 80002aa8 <setpriority>
    80003384:	87aa                	mv	a5,a0
}
    80003386:	853e                	mv	a0,a5
    80003388:	60e2                	ld	ra,24(sp)
    8000338a:	6442                	ld	s0,16(sp)
    8000338c:	6105                	addi	sp,sp,32
    8000338e:	8082                	ret

0000000080003390 <sys_exit>:


uint64
sys_exit(void)
{
    80003390:	1101                	addi	sp,sp,-32
    80003392:	ec06                	sd	ra,24(sp)
    80003394:	e822                	sd	s0,16(sp)
    80003396:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80003398:	fec40593          	addi	a1,s0,-20
    8000339c:	4501                	li	a0,0
    8000339e:	00000097          	auipc	ra,0x0
    800033a2:	d04080e7          	jalr	-764(ra) # 800030a2 <argint>
  exit(n);
    800033a6:	fec42503          	lw	a0,-20(s0)
    800033aa:	fffff097          	auipc	ra,0xfffff
    800033ae:	2ee080e7          	jalr	750(ra) # 80002698 <exit>
  return 0;  // not reached
}
    800033b2:	4501                	li	a0,0
    800033b4:	60e2                	ld	ra,24(sp)
    800033b6:	6442                	ld	s0,16(sp)
    800033b8:	6105                	addi	sp,sp,32
    800033ba:	8082                	ret

00000000800033bc <sys_getpid>:

uint64
sys_getpid(void)
{
    800033bc:	1141                	addi	sp,sp,-16
    800033be:	e406                	sd	ra,8(sp)
    800033c0:	e022                	sd	s0,0(sp)
    800033c2:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800033c4:	ffffe097          	auipc	ra,0xffffe
    800033c8:	5e8080e7          	jalr	1512(ra) # 800019ac <myproc>
}
    800033cc:	5908                	lw	a0,48(a0)
    800033ce:	60a2                	ld	ra,8(sp)
    800033d0:	6402                	ld	s0,0(sp)
    800033d2:	0141                	addi	sp,sp,16
    800033d4:	8082                	ret

00000000800033d6 <sys_fork>:

uint64
sys_fork(void)
{
    800033d6:	1141                	addi	sp,sp,-16
    800033d8:	e406                	sd	ra,8(sp)
    800033da:	e022                	sd	s0,0(sp)
    800033dc:	0800                	addi	s0,sp,16
  return fork();
    800033de:	fffff097          	auipc	ra,0xfffff
    800033e2:	9fa080e7          	jalr	-1542(ra) # 80001dd8 <fork>
}
    800033e6:	60a2                	ld	ra,8(sp)
    800033e8:	6402                	ld	s0,0(sp)
    800033ea:	0141                	addi	sp,sp,16
    800033ec:	8082                	ret

00000000800033ee <sys_wait>:

uint64
sys_wait(void)
{
    800033ee:	1101                	addi	sp,sp,-32
    800033f0:	ec06                	sd	ra,24(sp)
    800033f2:	e822                	sd	s0,16(sp)
    800033f4:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800033f6:	fe840593          	addi	a1,s0,-24
    800033fa:	4501                	li	a0,0
    800033fc:	00000097          	auipc	ra,0x0
    80003400:	cc8080e7          	jalr	-824(ra) # 800030c4 <argaddr>
  return wait(p);
    80003404:	fe843503          	ld	a0,-24(s0)
    80003408:	fffff097          	auipc	ra,0xfffff
    8000340c:	442080e7          	jalr	1090(ra) # 8000284a <wait>
}
    80003410:	60e2                	ld	ra,24(sp)
    80003412:	6442                	ld	s0,16(sp)
    80003414:	6105                	addi	sp,sp,32
    80003416:	8082                	ret

0000000080003418 <sys_waitx>:

uint64
sys_waitx(void)
{
    80003418:	7139                	addi	sp,sp,-64
    8000341a:	fc06                	sd	ra,56(sp)
    8000341c:	f822                	sd	s0,48(sp)
    8000341e:	f426                	sd	s1,40(sp)
    80003420:	f04a                	sd	s2,32(sp)
    80003422:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    80003424:	fd840593          	addi	a1,s0,-40
    80003428:	4501                	li	a0,0
    8000342a:	00000097          	auipc	ra,0x0
    8000342e:	c9a080e7          	jalr	-870(ra) # 800030c4 <argaddr>
  argaddr(1, &addr1); // user virtual memory
    80003432:	fd040593          	addi	a1,s0,-48
    80003436:	4505                	li	a0,1
    80003438:	00000097          	auipc	ra,0x0
    8000343c:	c8c080e7          	jalr	-884(ra) # 800030c4 <argaddr>
  argaddr(2, &addr2);
    80003440:	fc840593          	addi	a1,s0,-56
    80003444:	4509                	li	a0,2
    80003446:	00000097          	auipc	ra,0x0
    8000344a:	c7e080e7          	jalr	-898(ra) # 800030c4 <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    8000344e:	fc040613          	addi	a2,s0,-64
    80003452:	fc440593          	addi	a1,s0,-60
    80003456:	fd843503          	ld	a0,-40(s0)
    8000345a:	fffff097          	auipc	ra,0xfffff
    8000345e:	008080e7          	jalr	8(ra) # 80002462 <waitx>
    80003462:	892a                	mv	s2,a0
  struct proc* p = myproc();
    80003464:	ffffe097          	auipc	ra,0xffffe
    80003468:	548080e7          	jalr	1352(ra) # 800019ac <myproc>
    8000346c:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    8000346e:	4691                	li	a3,4
    80003470:	fc440613          	addi	a2,s0,-60
    80003474:	fd043583          	ld	a1,-48(s0)
    80003478:	6928                	ld	a0,80(a0)
    8000347a:	ffffe097          	auipc	ra,0xffffe
    8000347e:	1ee080e7          	jalr	494(ra) # 80001668 <copyout>
    return -1;
    80003482:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    80003484:	00054f63          	bltz	a0,800034a2 <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2,(char*)&rtime, sizeof(int)) < 0)
    80003488:	4691                	li	a3,4
    8000348a:	fc040613          	addi	a2,s0,-64
    8000348e:	fc843583          	ld	a1,-56(s0)
    80003492:	68a8                	ld	a0,80(s1)
    80003494:	ffffe097          	auipc	ra,0xffffe
    80003498:	1d4080e7          	jalr	468(ra) # 80001668 <copyout>
    8000349c:	00054a63          	bltz	a0,800034b0 <sys_waitx+0x98>
    return -1;
  return ret;
    800034a0:	87ca                	mv	a5,s2
}
    800034a2:	853e                	mv	a0,a5
    800034a4:	70e2                	ld	ra,56(sp)
    800034a6:	7442                	ld	s0,48(sp)
    800034a8:	74a2                	ld	s1,40(sp)
    800034aa:	7902                	ld	s2,32(sp)
    800034ac:	6121                	addi	sp,sp,64
    800034ae:	8082                	ret
    return -1;
    800034b0:	57fd                	li	a5,-1
    800034b2:	bfc5                	j	800034a2 <sys_waitx+0x8a>

00000000800034b4 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800034b4:	7179                	addi	sp,sp,-48
    800034b6:	f406                	sd	ra,40(sp)
    800034b8:	f022                	sd	s0,32(sp)
    800034ba:	ec26                	sd	s1,24(sp)
    800034bc:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    800034be:	fdc40593          	addi	a1,s0,-36
    800034c2:	4501                	li	a0,0
    800034c4:	00000097          	auipc	ra,0x0
    800034c8:	bde080e7          	jalr	-1058(ra) # 800030a2 <argint>
  addr = myproc()->sz;
    800034cc:	ffffe097          	auipc	ra,0xffffe
    800034d0:	4e0080e7          	jalr	1248(ra) # 800019ac <myproc>
    800034d4:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    800034d6:	fdc42503          	lw	a0,-36(s0)
    800034da:	fffff097          	auipc	ra,0xfffff
    800034de:	8a2080e7          	jalr	-1886(ra) # 80001d7c <growproc>
    800034e2:	00054863          	bltz	a0,800034f2 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    800034e6:	8526                	mv	a0,s1
    800034e8:	70a2                	ld	ra,40(sp)
    800034ea:	7402                	ld	s0,32(sp)
    800034ec:	64e2                	ld	s1,24(sp)
    800034ee:	6145                	addi	sp,sp,48
    800034f0:	8082                	ret
    return -1;
    800034f2:	54fd                	li	s1,-1
    800034f4:	bfcd                	j	800034e6 <sys_sbrk+0x32>

00000000800034f6 <sys_sleep>:

uint64
sys_sleep(void)
{
    800034f6:	7139                	addi	sp,sp,-64
    800034f8:	fc06                	sd	ra,56(sp)
    800034fa:	f822                	sd	s0,48(sp)
    800034fc:	f426                	sd	s1,40(sp)
    800034fe:	f04a                	sd	s2,32(sp)
    80003500:	ec4e                	sd	s3,24(sp)
    80003502:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80003504:	fcc40593          	addi	a1,s0,-52
    80003508:	4501                	li	a0,0
    8000350a:	00000097          	auipc	ra,0x0
    8000350e:	b98080e7          	jalr	-1128(ra) # 800030a2 <argint>
  acquire(&tickslock);
    80003512:	00015517          	auipc	a0,0x15
    80003516:	4ae50513          	addi	a0,a0,1198 # 800189c0 <tickslock>
    8000351a:	ffffd097          	auipc	ra,0xffffd
    8000351e:	6bc080e7          	jalr	1724(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80003522:	00005917          	auipc	s2,0x5
    80003526:	5ce92903          	lw	s2,1486(s2) # 80008af0 <ticks>
  while(ticks - ticks0 < n){
    8000352a:	fcc42783          	lw	a5,-52(s0)
    8000352e:	cf9d                	beqz	a5,8000356c <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003530:	00015997          	auipc	s3,0x15
    80003534:	49098993          	addi	s3,s3,1168 # 800189c0 <tickslock>
    80003538:	00005497          	auipc	s1,0x5
    8000353c:	5b848493          	addi	s1,s1,1464 # 80008af0 <ticks>
    if(killed(myproc())){
    80003540:	ffffe097          	auipc	ra,0xffffe
    80003544:	46c080e7          	jalr	1132(ra) # 800019ac <myproc>
    80003548:	fffff097          	auipc	ra,0xfffff
    8000354c:	2d0080e7          	jalr	720(ra) # 80002818 <killed>
    80003550:	ed15                	bnez	a0,8000358c <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80003552:	85ce                	mv	a1,s3
    80003554:	8526                	mv	a0,s1
    80003556:	fffff097          	auipc	ra,0xfffff
    8000355a:	e9c080e7          	jalr	-356(ra) # 800023f2 <sleep>
  while(ticks - ticks0 < n){
    8000355e:	409c                	lw	a5,0(s1)
    80003560:	412787bb          	subw	a5,a5,s2
    80003564:	fcc42703          	lw	a4,-52(s0)
    80003568:	fce7ece3          	bltu	a5,a4,80003540 <sys_sleep+0x4a>
  }
  release(&tickslock);
    8000356c:	00015517          	auipc	a0,0x15
    80003570:	45450513          	addi	a0,a0,1108 # 800189c0 <tickslock>
    80003574:	ffffd097          	auipc	ra,0xffffd
    80003578:	716080e7          	jalr	1814(ra) # 80000c8a <release>
  return 0;
    8000357c:	4501                	li	a0,0
}
    8000357e:	70e2                	ld	ra,56(sp)
    80003580:	7442                	ld	s0,48(sp)
    80003582:	74a2                	ld	s1,40(sp)
    80003584:	7902                	ld	s2,32(sp)
    80003586:	69e2                	ld	s3,24(sp)
    80003588:	6121                	addi	sp,sp,64
    8000358a:	8082                	ret
      release(&tickslock);
    8000358c:	00015517          	auipc	a0,0x15
    80003590:	43450513          	addi	a0,a0,1076 # 800189c0 <tickslock>
    80003594:	ffffd097          	auipc	ra,0xffffd
    80003598:	6f6080e7          	jalr	1782(ra) # 80000c8a <release>
      return -1;
    8000359c:	557d                	li	a0,-1
    8000359e:	b7c5                	j	8000357e <sys_sleep+0x88>

00000000800035a0 <sys_kill>:

uint64
sys_kill(void)
{
    800035a0:	1101                	addi	sp,sp,-32
    800035a2:	ec06                	sd	ra,24(sp)
    800035a4:	e822                	sd	s0,16(sp)
    800035a6:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800035a8:	fec40593          	addi	a1,s0,-20
    800035ac:	4501                	li	a0,0
    800035ae:	00000097          	auipc	ra,0x0
    800035b2:	af4080e7          	jalr	-1292(ra) # 800030a2 <argint>
  return kill(pid);
    800035b6:	fec42503          	lw	a0,-20(s0)
    800035ba:	fffff097          	auipc	ra,0xfffff
    800035be:	1c0080e7          	jalr	448(ra) # 8000277a <kill>
}
    800035c2:	60e2                	ld	ra,24(sp)
    800035c4:	6442                	ld	s0,16(sp)
    800035c6:	6105                	addi	sp,sp,32
    800035c8:	8082                	ret

00000000800035ca <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800035ca:	1101                	addi	sp,sp,-32
    800035cc:	ec06                	sd	ra,24(sp)
    800035ce:	e822                	sd	s0,16(sp)
    800035d0:	e426                	sd	s1,8(sp)
    800035d2:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800035d4:	00015517          	auipc	a0,0x15
    800035d8:	3ec50513          	addi	a0,a0,1004 # 800189c0 <tickslock>
    800035dc:	ffffd097          	auipc	ra,0xffffd
    800035e0:	5fa080e7          	jalr	1530(ra) # 80000bd6 <acquire>
  xticks = ticks;
    800035e4:	00005497          	auipc	s1,0x5
    800035e8:	50c4a483          	lw	s1,1292(s1) # 80008af0 <ticks>
  release(&tickslock);
    800035ec:	00015517          	auipc	a0,0x15
    800035f0:	3d450513          	addi	a0,a0,980 # 800189c0 <tickslock>
    800035f4:	ffffd097          	auipc	ra,0xffffd
    800035f8:	696080e7          	jalr	1686(ra) # 80000c8a <release>
  return xticks;
}
    800035fc:	02049513          	slli	a0,s1,0x20
    80003600:	9101                	srli	a0,a0,0x20
    80003602:	60e2                	ld	ra,24(sp)
    80003604:	6442                	ld	s0,16(sp)
    80003606:	64a2                	ld	s1,8(sp)
    80003608:	6105                	addi	sp,sp,32
    8000360a:	8082                	ret

000000008000360c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000360c:	7179                	addi	sp,sp,-48
    8000360e:	f406                	sd	ra,40(sp)
    80003610:	f022                	sd	s0,32(sp)
    80003612:	ec26                	sd	s1,24(sp)
    80003614:	e84a                	sd	s2,16(sp)
    80003616:	e44e                	sd	s3,8(sp)
    80003618:	e052                	sd	s4,0(sp)
    8000361a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000361c:	00005597          	auipc	a1,0x5
    80003620:	03458593          	addi	a1,a1,52 # 80008650 <syscallnum+0x70>
    80003624:	00015517          	auipc	a0,0x15
    80003628:	3b450513          	addi	a0,a0,948 # 800189d8 <bcache>
    8000362c:	ffffd097          	auipc	ra,0xffffd
    80003630:	51a080e7          	jalr	1306(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003634:	0001d797          	auipc	a5,0x1d
    80003638:	3a478793          	addi	a5,a5,932 # 800209d8 <bcache+0x8000>
    8000363c:	0001d717          	auipc	a4,0x1d
    80003640:	60470713          	addi	a4,a4,1540 # 80020c40 <bcache+0x8268>
    80003644:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003648:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000364c:	00015497          	auipc	s1,0x15
    80003650:	3a448493          	addi	s1,s1,932 # 800189f0 <bcache+0x18>
    b->next = bcache.head.next;
    80003654:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003656:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003658:	00005a17          	auipc	s4,0x5
    8000365c:	000a0a13          	mv	s4,s4
    b->next = bcache.head.next;
    80003660:	2b893783          	ld	a5,696(s2)
    80003664:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003666:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000366a:	85d2                	mv	a1,s4
    8000366c:	01048513          	addi	a0,s1,16
    80003670:	00001097          	auipc	ra,0x1
    80003674:	4c4080e7          	jalr	1220(ra) # 80004b34 <initsleeplock>
    bcache.head.next->prev = b;
    80003678:	2b893783          	ld	a5,696(s2)
    8000367c:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000367e:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003682:	45848493          	addi	s1,s1,1112
    80003686:	fd349de3          	bne	s1,s3,80003660 <binit+0x54>
  }
}
    8000368a:	70a2                	ld	ra,40(sp)
    8000368c:	7402                	ld	s0,32(sp)
    8000368e:	64e2                	ld	s1,24(sp)
    80003690:	6942                	ld	s2,16(sp)
    80003692:	69a2                	ld	s3,8(sp)
    80003694:	6a02                	ld	s4,0(sp)
    80003696:	6145                	addi	sp,sp,48
    80003698:	8082                	ret

000000008000369a <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000369a:	7179                	addi	sp,sp,-48
    8000369c:	f406                	sd	ra,40(sp)
    8000369e:	f022                	sd	s0,32(sp)
    800036a0:	ec26                	sd	s1,24(sp)
    800036a2:	e84a                	sd	s2,16(sp)
    800036a4:	e44e                	sd	s3,8(sp)
    800036a6:	1800                	addi	s0,sp,48
    800036a8:	892a                	mv	s2,a0
    800036aa:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800036ac:	00015517          	auipc	a0,0x15
    800036b0:	32c50513          	addi	a0,a0,812 # 800189d8 <bcache>
    800036b4:	ffffd097          	auipc	ra,0xffffd
    800036b8:	522080e7          	jalr	1314(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800036bc:	0001d497          	auipc	s1,0x1d
    800036c0:	5d44b483          	ld	s1,1492(s1) # 80020c90 <bcache+0x82b8>
    800036c4:	0001d797          	auipc	a5,0x1d
    800036c8:	57c78793          	addi	a5,a5,1404 # 80020c40 <bcache+0x8268>
    800036cc:	02f48f63          	beq	s1,a5,8000370a <bread+0x70>
    800036d0:	873e                	mv	a4,a5
    800036d2:	a021                	j	800036da <bread+0x40>
    800036d4:	68a4                	ld	s1,80(s1)
    800036d6:	02e48a63          	beq	s1,a4,8000370a <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800036da:	449c                	lw	a5,8(s1)
    800036dc:	ff279ce3          	bne	a5,s2,800036d4 <bread+0x3a>
    800036e0:	44dc                	lw	a5,12(s1)
    800036e2:	ff3799e3          	bne	a5,s3,800036d4 <bread+0x3a>
      b->refcnt++;
    800036e6:	40bc                	lw	a5,64(s1)
    800036e8:	2785                	addiw	a5,a5,1
    800036ea:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800036ec:	00015517          	auipc	a0,0x15
    800036f0:	2ec50513          	addi	a0,a0,748 # 800189d8 <bcache>
    800036f4:	ffffd097          	auipc	ra,0xffffd
    800036f8:	596080e7          	jalr	1430(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    800036fc:	01048513          	addi	a0,s1,16
    80003700:	00001097          	auipc	ra,0x1
    80003704:	46e080e7          	jalr	1134(ra) # 80004b6e <acquiresleep>
      return b;
    80003708:	a8b9                	j	80003766 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000370a:	0001d497          	auipc	s1,0x1d
    8000370e:	57e4b483          	ld	s1,1406(s1) # 80020c88 <bcache+0x82b0>
    80003712:	0001d797          	auipc	a5,0x1d
    80003716:	52e78793          	addi	a5,a5,1326 # 80020c40 <bcache+0x8268>
    8000371a:	00f48863          	beq	s1,a5,8000372a <bread+0x90>
    8000371e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003720:	40bc                	lw	a5,64(s1)
    80003722:	cf81                	beqz	a5,8000373a <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003724:	64a4                	ld	s1,72(s1)
    80003726:	fee49de3          	bne	s1,a4,80003720 <bread+0x86>
  panic("bget: no buffers");
    8000372a:	00005517          	auipc	a0,0x5
    8000372e:	f3650513          	addi	a0,a0,-202 # 80008660 <syscallnum+0x80>
    80003732:	ffffd097          	auipc	ra,0xffffd
    80003736:	e0c080e7          	jalr	-500(ra) # 8000053e <panic>
      b->dev = dev;
    8000373a:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000373e:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003742:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003746:	4785                	li	a5,1
    80003748:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000374a:	00015517          	auipc	a0,0x15
    8000374e:	28e50513          	addi	a0,a0,654 # 800189d8 <bcache>
    80003752:	ffffd097          	auipc	ra,0xffffd
    80003756:	538080e7          	jalr	1336(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    8000375a:	01048513          	addi	a0,s1,16
    8000375e:	00001097          	auipc	ra,0x1
    80003762:	410080e7          	jalr	1040(ra) # 80004b6e <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003766:	409c                	lw	a5,0(s1)
    80003768:	cb89                	beqz	a5,8000377a <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000376a:	8526                	mv	a0,s1
    8000376c:	70a2                	ld	ra,40(sp)
    8000376e:	7402                	ld	s0,32(sp)
    80003770:	64e2                	ld	s1,24(sp)
    80003772:	6942                	ld	s2,16(sp)
    80003774:	69a2                	ld	s3,8(sp)
    80003776:	6145                	addi	sp,sp,48
    80003778:	8082                	ret
    virtio_disk_rw(b, 0);
    8000377a:	4581                	li	a1,0
    8000377c:	8526                	mv	a0,s1
    8000377e:	00003097          	auipc	ra,0x3
    80003782:	fd6080e7          	jalr	-42(ra) # 80006754 <virtio_disk_rw>
    b->valid = 1;
    80003786:	4785                	li	a5,1
    80003788:	c09c                	sw	a5,0(s1)
  return b;
    8000378a:	b7c5                	j	8000376a <bread+0xd0>

000000008000378c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000378c:	1101                	addi	sp,sp,-32
    8000378e:	ec06                	sd	ra,24(sp)
    80003790:	e822                	sd	s0,16(sp)
    80003792:	e426                	sd	s1,8(sp)
    80003794:	1000                	addi	s0,sp,32
    80003796:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003798:	0541                	addi	a0,a0,16
    8000379a:	00001097          	auipc	ra,0x1
    8000379e:	46e080e7          	jalr	1134(ra) # 80004c08 <holdingsleep>
    800037a2:	cd01                	beqz	a0,800037ba <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800037a4:	4585                	li	a1,1
    800037a6:	8526                	mv	a0,s1
    800037a8:	00003097          	auipc	ra,0x3
    800037ac:	fac080e7          	jalr	-84(ra) # 80006754 <virtio_disk_rw>
}
    800037b0:	60e2                	ld	ra,24(sp)
    800037b2:	6442                	ld	s0,16(sp)
    800037b4:	64a2                	ld	s1,8(sp)
    800037b6:	6105                	addi	sp,sp,32
    800037b8:	8082                	ret
    panic("bwrite");
    800037ba:	00005517          	auipc	a0,0x5
    800037be:	ebe50513          	addi	a0,a0,-322 # 80008678 <syscallnum+0x98>
    800037c2:	ffffd097          	auipc	ra,0xffffd
    800037c6:	d7c080e7          	jalr	-644(ra) # 8000053e <panic>

00000000800037ca <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800037ca:	1101                	addi	sp,sp,-32
    800037cc:	ec06                	sd	ra,24(sp)
    800037ce:	e822                	sd	s0,16(sp)
    800037d0:	e426                	sd	s1,8(sp)
    800037d2:	e04a                	sd	s2,0(sp)
    800037d4:	1000                	addi	s0,sp,32
    800037d6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800037d8:	01050913          	addi	s2,a0,16
    800037dc:	854a                	mv	a0,s2
    800037de:	00001097          	auipc	ra,0x1
    800037e2:	42a080e7          	jalr	1066(ra) # 80004c08 <holdingsleep>
    800037e6:	c92d                	beqz	a0,80003858 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800037e8:	854a                	mv	a0,s2
    800037ea:	00001097          	auipc	ra,0x1
    800037ee:	3da080e7          	jalr	986(ra) # 80004bc4 <releasesleep>

  acquire(&bcache.lock);
    800037f2:	00015517          	auipc	a0,0x15
    800037f6:	1e650513          	addi	a0,a0,486 # 800189d8 <bcache>
    800037fa:	ffffd097          	auipc	ra,0xffffd
    800037fe:	3dc080e7          	jalr	988(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80003802:	40bc                	lw	a5,64(s1)
    80003804:	37fd                	addiw	a5,a5,-1
    80003806:	0007871b          	sext.w	a4,a5
    8000380a:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000380c:	eb05                	bnez	a4,8000383c <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000380e:	68bc                	ld	a5,80(s1)
    80003810:	64b8                	ld	a4,72(s1)
    80003812:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003814:	64bc                	ld	a5,72(s1)
    80003816:	68b8                	ld	a4,80(s1)
    80003818:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000381a:	0001d797          	auipc	a5,0x1d
    8000381e:	1be78793          	addi	a5,a5,446 # 800209d8 <bcache+0x8000>
    80003822:	2b87b703          	ld	a4,696(a5)
    80003826:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003828:	0001d717          	auipc	a4,0x1d
    8000382c:	41870713          	addi	a4,a4,1048 # 80020c40 <bcache+0x8268>
    80003830:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003832:	2b87b703          	ld	a4,696(a5)
    80003836:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003838:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000383c:	00015517          	auipc	a0,0x15
    80003840:	19c50513          	addi	a0,a0,412 # 800189d8 <bcache>
    80003844:	ffffd097          	auipc	ra,0xffffd
    80003848:	446080e7          	jalr	1094(ra) # 80000c8a <release>
}
    8000384c:	60e2                	ld	ra,24(sp)
    8000384e:	6442                	ld	s0,16(sp)
    80003850:	64a2                	ld	s1,8(sp)
    80003852:	6902                	ld	s2,0(sp)
    80003854:	6105                	addi	sp,sp,32
    80003856:	8082                	ret
    panic("brelse");
    80003858:	00005517          	auipc	a0,0x5
    8000385c:	e2850513          	addi	a0,a0,-472 # 80008680 <syscallnum+0xa0>
    80003860:	ffffd097          	auipc	ra,0xffffd
    80003864:	cde080e7          	jalr	-802(ra) # 8000053e <panic>

0000000080003868 <bpin>:

void
bpin(struct buf *b) {
    80003868:	1101                	addi	sp,sp,-32
    8000386a:	ec06                	sd	ra,24(sp)
    8000386c:	e822                	sd	s0,16(sp)
    8000386e:	e426                	sd	s1,8(sp)
    80003870:	1000                	addi	s0,sp,32
    80003872:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003874:	00015517          	auipc	a0,0x15
    80003878:	16450513          	addi	a0,a0,356 # 800189d8 <bcache>
    8000387c:	ffffd097          	auipc	ra,0xffffd
    80003880:	35a080e7          	jalr	858(ra) # 80000bd6 <acquire>
  b->refcnt++;
    80003884:	40bc                	lw	a5,64(s1)
    80003886:	2785                	addiw	a5,a5,1
    80003888:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000388a:	00015517          	auipc	a0,0x15
    8000388e:	14e50513          	addi	a0,a0,334 # 800189d8 <bcache>
    80003892:	ffffd097          	auipc	ra,0xffffd
    80003896:	3f8080e7          	jalr	1016(ra) # 80000c8a <release>
}
    8000389a:	60e2                	ld	ra,24(sp)
    8000389c:	6442                	ld	s0,16(sp)
    8000389e:	64a2                	ld	s1,8(sp)
    800038a0:	6105                	addi	sp,sp,32
    800038a2:	8082                	ret

00000000800038a4 <bunpin>:

void
bunpin(struct buf *b) {
    800038a4:	1101                	addi	sp,sp,-32
    800038a6:	ec06                	sd	ra,24(sp)
    800038a8:	e822                	sd	s0,16(sp)
    800038aa:	e426                	sd	s1,8(sp)
    800038ac:	1000                	addi	s0,sp,32
    800038ae:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800038b0:	00015517          	auipc	a0,0x15
    800038b4:	12850513          	addi	a0,a0,296 # 800189d8 <bcache>
    800038b8:	ffffd097          	auipc	ra,0xffffd
    800038bc:	31e080e7          	jalr	798(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800038c0:	40bc                	lw	a5,64(s1)
    800038c2:	37fd                	addiw	a5,a5,-1
    800038c4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800038c6:	00015517          	auipc	a0,0x15
    800038ca:	11250513          	addi	a0,a0,274 # 800189d8 <bcache>
    800038ce:	ffffd097          	auipc	ra,0xffffd
    800038d2:	3bc080e7          	jalr	956(ra) # 80000c8a <release>
}
    800038d6:	60e2                	ld	ra,24(sp)
    800038d8:	6442                	ld	s0,16(sp)
    800038da:	64a2                	ld	s1,8(sp)
    800038dc:	6105                	addi	sp,sp,32
    800038de:	8082                	ret

00000000800038e0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800038e0:	1101                	addi	sp,sp,-32
    800038e2:	ec06                	sd	ra,24(sp)
    800038e4:	e822                	sd	s0,16(sp)
    800038e6:	e426                	sd	s1,8(sp)
    800038e8:	e04a                	sd	s2,0(sp)
    800038ea:	1000                	addi	s0,sp,32
    800038ec:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800038ee:	00d5d59b          	srliw	a1,a1,0xd
    800038f2:	0001d797          	auipc	a5,0x1d
    800038f6:	7c27a783          	lw	a5,1986(a5) # 800210b4 <sb+0x1c>
    800038fa:	9dbd                	addw	a1,a1,a5
    800038fc:	00000097          	auipc	ra,0x0
    80003900:	d9e080e7          	jalr	-610(ra) # 8000369a <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003904:	0074f713          	andi	a4,s1,7
    80003908:	4785                	li	a5,1
    8000390a:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000390e:	14ce                	slli	s1,s1,0x33
    80003910:	90d9                	srli	s1,s1,0x36
    80003912:	00950733          	add	a4,a0,s1
    80003916:	05874703          	lbu	a4,88(a4)
    8000391a:	00e7f6b3          	and	a3,a5,a4
    8000391e:	c69d                	beqz	a3,8000394c <bfree+0x6c>
    80003920:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003922:	94aa                	add	s1,s1,a0
    80003924:	fff7c793          	not	a5,a5
    80003928:	8ff9                	and	a5,a5,a4
    8000392a:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    8000392e:	00001097          	auipc	ra,0x1
    80003932:	120080e7          	jalr	288(ra) # 80004a4e <log_write>
  brelse(bp);
    80003936:	854a                	mv	a0,s2
    80003938:	00000097          	auipc	ra,0x0
    8000393c:	e92080e7          	jalr	-366(ra) # 800037ca <brelse>
}
    80003940:	60e2                	ld	ra,24(sp)
    80003942:	6442                	ld	s0,16(sp)
    80003944:	64a2                	ld	s1,8(sp)
    80003946:	6902                	ld	s2,0(sp)
    80003948:	6105                	addi	sp,sp,32
    8000394a:	8082                	ret
    panic("freeing free block");
    8000394c:	00005517          	auipc	a0,0x5
    80003950:	d3c50513          	addi	a0,a0,-708 # 80008688 <syscallnum+0xa8>
    80003954:	ffffd097          	auipc	ra,0xffffd
    80003958:	bea080e7          	jalr	-1046(ra) # 8000053e <panic>

000000008000395c <balloc>:
{
    8000395c:	711d                	addi	sp,sp,-96
    8000395e:	ec86                	sd	ra,88(sp)
    80003960:	e8a2                	sd	s0,80(sp)
    80003962:	e4a6                	sd	s1,72(sp)
    80003964:	e0ca                	sd	s2,64(sp)
    80003966:	fc4e                	sd	s3,56(sp)
    80003968:	f852                	sd	s4,48(sp)
    8000396a:	f456                	sd	s5,40(sp)
    8000396c:	f05a                	sd	s6,32(sp)
    8000396e:	ec5e                	sd	s7,24(sp)
    80003970:	e862                	sd	s8,16(sp)
    80003972:	e466                	sd	s9,8(sp)
    80003974:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003976:	0001d797          	auipc	a5,0x1d
    8000397a:	7267a783          	lw	a5,1830(a5) # 8002109c <sb+0x4>
    8000397e:	10078163          	beqz	a5,80003a80 <balloc+0x124>
    80003982:	8baa                	mv	s7,a0
    80003984:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003986:	0001db17          	auipc	s6,0x1d
    8000398a:	712b0b13          	addi	s6,s6,1810 # 80021098 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000398e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003990:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003992:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003994:	6c89                	lui	s9,0x2
    80003996:	a061                	j	80003a1e <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003998:	974a                	add	a4,a4,s2
    8000399a:	8fd5                	or	a5,a5,a3
    8000399c:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800039a0:	854a                	mv	a0,s2
    800039a2:	00001097          	auipc	ra,0x1
    800039a6:	0ac080e7          	jalr	172(ra) # 80004a4e <log_write>
        brelse(bp);
    800039aa:	854a                	mv	a0,s2
    800039ac:	00000097          	auipc	ra,0x0
    800039b0:	e1e080e7          	jalr	-482(ra) # 800037ca <brelse>
  bp = bread(dev, bno);
    800039b4:	85a6                	mv	a1,s1
    800039b6:	855e                	mv	a0,s7
    800039b8:	00000097          	auipc	ra,0x0
    800039bc:	ce2080e7          	jalr	-798(ra) # 8000369a <bread>
    800039c0:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800039c2:	40000613          	li	a2,1024
    800039c6:	4581                	li	a1,0
    800039c8:	05850513          	addi	a0,a0,88
    800039cc:	ffffd097          	auipc	ra,0xffffd
    800039d0:	306080e7          	jalr	774(ra) # 80000cd2 <memset>
  log_write(bp);
    800039d4:	854a                	mv	a0,s2
    800039d6:	00001097          	auipc	ra,0x1
    800039da:	078080e7          	jalr	120(ra) # 80004a4e <log_write>
  brelse(bp);
    800039de:	854a                	mv	a0,s2
    800039e0:	00000097          	auipc	ra,0x0
    800039e4:	dea080e7          	jalr	-534(ra) # 800037ca <brelse>
}
    800039e8:	8526                	mv	a0,s1
    800039ea:	60e6                	ld	ra,88(sp)
    800039ec:	6446                	ld	s0,80(sp)
    800039ee:	64a6                	ld	s1,72(sp)
    800039f0:	6906                	ld	s2,64(sp)
    800039f2:	79e2                	ld	s3,56(sp)
    800039f4:	7a42                	ld	s4,48(sp)
    800039f6:	7aa2                	ld	s5,40(sp)
    800039f8:	7b02                	ld	s6,32(sp)
    800039fa:	6be2                	ld	s7,24(sp)
    800039fc:	6c42                	ld	s8,16(sp)
    800039fe:	6ca2                	ld	s9,8(sp)
    80003a00:	6125                	addi	sp,sp,96
    80003a02:	8082                	ret
    brelse(bp);
    80003a04:	854a                	mv	a0,s2
    80003a06:	00000097          	auipc	ra,0x0
    80003a0a:	dc4080e7          	jalr	-572(ra) # 800037ca <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003a0e:	015c87bb          	addw	a5,s9,s5
    80003a12:	00078a9b          	sext.w	s5,a5
    80003a16:	004b2703          	lw	a4,4(s6)
    80003a1a:	06eaf363          	bgeu	s5,a4,80003a80 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003a1e:	41fad79b          	sraiw	a5,s5,0x1f
    80003a22:	0137d79b          	srliw	a5,a5,0x13
    80003a26:	015787bb          	addw	a5,a5,s5
    80003a2a:	40d7d79b          	sraiw	a5,a5,0xd
    80003a2e:	01cb2583          	lw	a1,28(s6)
    80003a32:	9dbd                	addw	a1,a1,a5
    80003a34:	855e                	mv	a0,s7
    80003a36:	00000097          	auipc	ra,0x0
    80003a3a:	c64080e7          	jalr	-924(ra) # 8000369a <bread>
    80003a3e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a40:	004b2503          	lw	a0,4(s6)
    80003a44:	000a849b          	sext.w	s1,s5
    80003a48:	8662                	mv	a2,s8
    80003a4a:	faa4fde3          	bgeu	s1,a0,80003a04 <balloc+0xa8>
      m = 1 << (bi % 8);
    80003a4e:	41f6579b          	sraiw	a5,a2,0x1f
    80003a52:	01d7d69b          	srliw	a3,a5,0x1d
    80003a56:	00c6873b          	addw	a4,a3,a2
    80003a5a:	00777793          	andi	a5,a4,7
    80003a5e:	9f95                	subw	a5,a5,a3
    80003a60:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003a64:	4037571b          	sraiw	a4,a4,0x3
    80003a68:	00e906b3          	add	a3,s2,a4
    80003a6c:	0586c683          	lbu	a3,88(a3)
    80003a70:	00d7f5b3          	and	a1,a5,a3
    80003a74:	d195                	beqz	a1,80003998 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a76:	2605                	addiw	a2,a2,1
    80003a78:	2485                	addiw	s1,s1,1
    80003a7a:	fd4618e3          	bne	a2,s4,80003a4a <balloc+0xee>
    80003a7e:	b759                	j	80003a04 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003a80:	00005517          	auipc	a0,0x5
    80003a84:	c2050513          	addi	a0,a0,-992 # 800086a0 <syscallnum+0xc0>
    80003a88:	ffffd097          	auipc	ra,0xffffd
    80003a8c:	b00080e7          	jalr	-1280(ra) # 80000588 <printf>
  return 0;
    80003a90:	4481                	li	s1,0
    80003a92:	bf99                	j	800039e8 <balloc+0x8c>

0000000080003a94 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003a94:	7179                	addi	sp,sp,-48
    80003a96:	f406                	sd	ra,40(sp)
    80003a98:	f022                	sd	s0,32(sp)
    80003a9a:	ec26                	sd	s1,24(sp)
    80003a9c:	e84a                	sd	s2,16(sp)
    80003a9e:	e44e                	sd	s3,8(sp)
    80003aa0:	e052                	sd	s4,0(sp)
    80003aa2:	1800                	addi	s0,sp,48
    80003aa4:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003aa6:	47ad                	li	a5,11
    80003aa8:	02b7e763          	bltu	a5,a1,80003ad6 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003aac:	02059493          	slli	s1,a1,0x20
    80003ab0:	9081                	srli	s1,s1,0x20
    80003ab2:	048a                	slli	s1,s1,0x2
    80003ab4:	94aa                	add	s1,s1,a0
    80003ab6:	0504a903          	lw	s2,80(s1)
    80003aba:	06091e63          	bnez	s2,80003b36 <bmap+0xa2>
      addr = balloc(ip->dev);
    80003abe:	4108                	lw	a0,0(a0)
    80003ac0:	00000097          	auipc	ra,0x0
    80003ac4:	e9c080e7          	jalr	-356(ra) # 8000395c <balloc>
    80003ac8:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003acc:	06090563          	beqz	s2,80003b36 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003ad0:	0524a823          	sw	s2,80(s1)
    80003ad4:	a08d                	j	80003b36 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003ad6:	ff45849b          	addiw	s1,a1,-12
    80003ada:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003ade:	0ff00793          	li	a5,255
    80003ae2:	08e7e563          	bltu	a5,a4,80003b6c <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003ae6:	08052903          	lw	s2,128(a0)
    80003aea:	00091d63          	bnez	s2,80003b04 <bmap+0x70>
      addr = balloc(ip->dev);
    80003aee:	4108                	lw	a0,0(a0)
    80003af0:	00000097          	auipc	ra,0x0
    80003af4:	e6c080e7          	jalr	-404(ra) # 8000395c <balloc>
    80003af8:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003afc:	02090d63          	beqz	s2,80003b36 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003b00:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003b04:	85ca                	mv	a1,s2
    80003b06:	0009a503          	lw	a0,0(s3)
    80003b0a:	00000097          	auipc	ra,0x0
    80003b0e:	b90080e7          	jalr	-1136(ra) # 8000369a <bread>
    80003b12:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003b14:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003b18:	02049593          	slli	a1,s1,0x20
    80003b1c:	9181                	srli	a1,a1,0x20
    80003b1e:	058a                	slli	a1,a1,0x2
    80003b20:	00b784b3          	add	s1,a5,a1
    80003b24:	0004a903          	lw	s2,0(s1)
    80003b28:	02090063          	beqz	s2,80003b48 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003b2c:	8552                	mv	a0,s4
    80003b2e:	00000097          	auipc	ra,0x0
    80003b32:	c9c080e7          	jalr	-868(ra) # 800037ca <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003b36:	854a                	mv	a0,s2
    80003b38:	70a2                	ld	ra,40(sp)
    80003b3a:	7402                	ld	s0,32(sp)
    80003b3c:	64e2                	ld	s1,24(sp)
    80003b3e:	6942                	ld	s2,16(sp)
    80003b40:	69a2                	ld	s3,8(sp)
    80003b42:	6a02                	ld	s4,0(sp)
    80003b44:	6145                	addi	sp,sp,48
    80003b46:	8082                	ret
      addr = balloc(ip->dev);
    80003b48:	0009a503          	lw	a0,0(s3)
    80003b4c:	00000097          	auipc	ra,0x0
    80003b50:	e10080e7          	jalr	-496(ra) # 8000395c <balloc>
    80003b54:	0005091b          	sext.w	s2,a0
      if(addr){
    80003b58:	fc090ae3          	beqz	s2,80003b2c <bmap+0x98>
        a[bn] = addr;
    80003b5c:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003b60:	8552                	mv	a0,s4
    80003b62:	00001097          	auipc	ra,0x1
    80003b66:	eec080e7          	jalr	-276(ra) # 80004a4e <log_write>
    80003b6a:	b7c9                	j	80003b2c <bmap+0x98>
  panic("bmap: out of range");
    80003b6c:	00005517          	auipc	a0,0x5
    80003b70:	b4c50513          	addi	a0,a0,-1204 # 800086b8 <syscallnum+0xd8>
    80003b74:	ffffd097          	auipc	ra,0xffffd
    80003b78:	9ca080e7          	jalr	-1590(ra) # 8000053e <panic>

0000000080003b7c <iget>:
{
    80003b7c:	7179                	addi	sp,sp,-48
    80003b7e:	f406                	sd	ra,40(sp)
    80003b80:	f022                	sd	s0,32(sp)
    80003b82:	ec26                	sd	s1,24(sp)
    80003b84:	e84a                	sd	s2,16(sp)
    80003b86:	e44e                	sd	s3,8(sp)
    80003b88:	e052                	sd	s4,0(sp)
    80003b8a:	1800                	addi	s0,sp,48
    80003b8c:	89aa                	mv	s3,a0
    80003b8e:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003b90:	0001d517          	auipc	a0,0x1d
    80003b94:	52850513          	addi	a0,a0,1320 # 800210b8 <itable>
    80003b98:	ffffd097          	auipc	ra,0xffffd
    80003b9c:	03e080e7          	jalr	62(ra) # 80000bd6 <acquire>
  empty = 0;
    80003ba0:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003ba2:	0001d497          	auipc	s1,0x1d
    80003ba6:	52e48493          	addi	s1,s1,1326 # 800210d0 <itable+0x18>
    80003baa:	0001f697          	auipc	a3,0x1f
    80003bae:	fb668693          	addi	a3,a3,-74 # 80022b60 <log>
    80003bb2:	a039                	j	80003bc0 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003bb4:	02090b63          	beqz	s2,80003bea <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003bb8:	08848493          	addi	s1,s1,136
    80003bbc:	02d48a63          	beq	s1,a3,80003bf0 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003bc0:	449c                	lw	a5,8(s1)
    80003bc2:	fef059e3          	blez	a5,80003bb4 <iget+0x38>
    80003bc6:	4098                	lw	a4,0(s1)
    80003bc8:	ff3716e3          	bne	a4,s3,80003bb4 <iget+0x38>
    80003bcc:	40d8                	lw	a4,4(s1)
    80003bce:	ff4713e3          	bne	a4,s4,80003bb4 <iget+0x38>
      ip->ref++;
    80003bd2:	2785                	addiw	a5,a5,1
    80003bd4:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003bd6:	0001d517          	auipc	a0,0x1d
    80003bda:	4e250513          	addi	a0,a0,1250 # 800210b8 <itable>
    80003bde:	ffffd097          	auipc	ra,0xffffd
    80003be2:	0ac080e7          	jalr	172(ra) # 80000c8a <release>
      return ip;
    80003be6:	8926                	mv	s2,s1
    80003be8:	a03d                	j	80003c16 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003bea:	f7f9                	bnez	a5,80003bb8 <iget+0x3c>
    80003bec:	8926                	mv	s2,s1
    80003bee:	b7e9                	j	80003bb8 <iget+0x3c>
  if(empty == 0)
    80003bf0:	02090c63          	beqz	s2,80003c28 <iget+0xac>
  ip->dev = dev;
    80003bf4:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003bf8:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003bfc:	4785                	li	a5,1
    80003bfe:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003c02:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003c06:	0001d517          	auipc	a0,0x1d
    80003c0a:	4b250513          	addi	a0,a0,1202 # 800210b8 <itable>
    80003c0e:	ffffd097          	auipc	ra,0xffffd
    80003c12:	07c080e7          	jalr	124(ra) # 80000c8a <release>
}
    80003c16:	854a                	mv	a0,s2
    80003c18:	70a2                	ld	ra,40(sp)
    80003c1a:	7402                	ld	s0,32(sp)
    80003c1c:	64e2                	ld	s1,24(sp)
    80003c1e:	6942                	ld	s2,16(sp)
    80003c20:	69a2                	ld	s3,8(sp)
    80003c22:	6a02                	ld	s4,0(sp)
    80003c24:	6145                	addi	sp,sp,48
    80003c26:	8082                	ret
    panic("iget: no inodes");
    80003c28:	00005517          	auipc	a0,0x5
    80003c2c:	aa850513          	addi	a0,a0,-1368 # 800086d0 <syscallnum+0xf0>
    80003c30:	ffffd097          	auipc	ra,0xffffd
    80003c34:	90e080e7          	jalr	-1778(ra) # 8000053e <panic>

0000000080003c38 <fsinit>:
fsinit(int dev) {
    80003c38:	7179                	addi	sp,sp,-48
    80003c3a:	f406                	sd	ra,40(sp)
    80003c3c:	f022                	sd	s0,32(sp)
    80003c3e:	ec26                	sd	s1,24(sp)
    80003c40:	e84a                	sd	s2,16(sp)
    80003c42:	e44e                	sd	s3,8(sp)
    80003c44:	1800                	addi	s0,sp,48
    80003c46:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003c48:	4585                	li	a1,1
    80003c4a:	00000097          	auipc	ra,0x0
    80003c4e:	a50080e7          	jalr	-1456(ra) # 8000369a <bread>
    80003c52:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003c54:	0001d997          	auipc	s3,0x1d
    80003c58:	44498993          	addi	s3,s3,1092 # 80021098 <sb>
    80003c5c:	02000613          	li	a2,32
    80003c60:	05850593          	addi	a1,a0,88
    80003c64:	854e                	mv	a0,s3
    80003c66:	ffffd097          	auipc	ra,0xffffd
    80003c6a:	0c8080e7          	jalr	200(ra) # 80000d2e <memmove>
  brelse(bp);
    80003c6e:	8526                	mv	a0,s1
    80003c70:	00000097          	auipc	ra,0x0
    80003c74:	b5a080e7          	jalr	-1190(ra) # 800037ca <brelse>
  if(sb.magic != FSMAGIC)
    80003c78:	0009a703          	lw	a4,0(s3)
    80003c7c:	102037b7          	lui	a5,0x10203
    80003c80:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003c84:	02f71263          	bne	a4,a5,80003ca8 <fsinit+0x70>
  initlog(dev, &sb);
    80003c88:	0001d597          	auipc	a1,0x1d
    80003c8c:	41058593          	addi	a1,a1,1040 # 80021098 <sb>
    80003c90:	854a                	mv	a0,s2
    80003c92:	00001097          	auipc	ra,0x1
    80003c96:	b40080e7          	jalr	-1216(ra) # 800047d2 <initlog>
}
    80003c9a:	70a2                	ld	ra,40(sp)
    80003c9c:	7402                	ld	s0,32(sp)
    80003c9e:	64e2                	ld	s1,24(sp)
    80003ca0:	6942                	ld	s2,16(sp)
    80003ca2:	69a2                	ld	s3,8(sp)
    80003ca4:	6145                	addi	sp,sp,48
    80003ca6:	8082                	ret
    panic("invalid file system");
    80003ca8:	00005517          	auipc	a0,0x5
    80003cac:	a3850513          	addi	a0,a0,-1480 # 800086e0 <syscallnum+0x100>
    80003cb0:	ffffd097          	auipc	ra,0xffffd
    80003cb4:	88e080e7          	jalr	-1906(ra) # 8000053e <panic>

0000000080003cb8 <iinit>:
{
    80003cb8:	7179                	addi	sp,sp,-48
    80003cba:	f406                	sd	ra,40(sp)
    80003cbc:	f022                	sd	s0,32(sp)
    80003cbe:	ec26                	sd	s1,24(sp)
    80003cc0:	e84a                	sd	s2,16(sp)
    80003cc2:	e44e                	sd	s3,8(sp)
    80003cc4:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003cc6:	00005597          	auipc	a1,0x5
    80003cca:	a3258593          	addi	a1,a1,-1486 # 800086f8 <syscallnum+0x118>
    80003cce:	0001d517          	auipc	a0,0x1d
    80003cd2:	3ea50513          	addi	a0,a0,1002 # 800210b8 <itable>
    80003cd6:	ffffd097          	auipc	ra,0xffffd
    80003cda:	e70080e7          	jalr	-400(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003cde:	0001d497          	auipc	s1,0x1d
    80003ce2:	40248493          	addi	s1,s1,1026 # 800210e0 <itable+0x28>
    80003ce6:	0001f997          	auipc	s3,0x1f
    80003cea:	e8a98993          	addi	s3,s3,-374 # 80022b70 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003cee:	00005917          	auipc	s2,0x5
    80003cf2:	a1290913          	addi	s2,s2,-1518 # 80008700 <syscallnum+0x120>
    80003cf6:	85ca                	mv	a1,s2
    80003cf8:	8526                	mv	a0,s1
    80003cfa:	00001097          	auipc	ra,0x1
    80003cfe:	e3a080e7          	jalr	-454(ra) # 80004b34 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003d02:	08848493          	addi	s1,s1,136
    80003d06:	ff3498e3          	bne	s1,s3,80003cf6 <iinit+0x3e>
}
    80003d0a:	70a2                	ld	ra,40(sp)
    80003d0c:	7402                	ld	s0,32(sp)
    80003d0e:	64e2                	ld	s1,24(sp)
    80003d10:	6942                	ld	s2,16(sp)
    80003d12:	69a2                	ld	s3,8(sp)
    80003d14:	6145                	addi	sp,sp,48
    80003d16:	8082                	ret

0000000080003d18 <ialloc>:
{
    80003d18:	715d                	addi	sp,sp,-80
    80003d1a:	e486                	sd	ra,72(sp)
    80003d1c:	e0a2                	sd	s0,64(sp)
    80003d1e:	fc26                	sd	s1,56(sp)
    80003d20:	f84a                	sd	s2,48(sp)
    80003d22:	f44e                	sd	s3,40(sp)
    80003d24:	f052                	sd	s4,32(sp)
    80003d26:	ec56                	sd	s5,24(sp)
    80003d28:	e85a                	sd	s6,16(sp)
    80003d2a:	e45e                	sd	s7,8(sp)
    80003d2c:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003d2e:	0001d717          	auipc	a4,0x1d
    80003d32:	37672703          	lw	a4,886(a4) # 800210a4 <sb+0xc>
    80003d36:	4785                	li	a5,1
    80003d38:	04e7fa63          	bgeu	a5,a4,80003d8c <ialloc+0x74>
    80003d3c:	8aaa                	mv	s5,a0
    80003d3e:	8bae                	mv	s7,a1
    80003d40:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003d42:	0001da17          	auipc	s4,0x1d
    80003d46:	356a0a13          	addi	s4,s4,854 # 80021098 <sb>
    80003d4a:	00048b1b          	sext.w	s6,s1
    80003d4e:	0044d793          	srli	a5,s1,0x4
    80003d52:	018a2583          	lw	a1,24(s4)
    80003d56:	9dbd                	addw	a1,a1,a5
    80003d58:	8556                	mv	a0,s5
    80003d5a:	00000097          	auipc	ra,0x0
    80003d5e:	940080e7          	jalr	-1728(ra) # 8000369a <bread>
    80003d62:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003d64:	05850993          	addi	s3,a0,88
    80003d68:	00f4f793          	andi	a5,s1,15
    80003d6c:	079a                	slli	a5,a5,0x6
    80003d6e:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003d70:	00099783          	lh	a5,0(s3)
    80003d74:	c3a1                	beqz	a5,80003db4 <ialloc+0x9c>
    brelse(bp);
    80003d76:	00000097          	auipc	ra,0x0
    80003d7a:	a54080e7          	jalr	-1452(ra) # 800037ca <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003d7e:	0485                	addi	s1,s1,1
    80003d80:	00ca2703          	lw	a4,12(s4)
    80003d84:	0004879b          	sext.w	a5,s1
    80003d88:	fce7e1e3          	bltu	a5,a4,80003d4a <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003d8c:	00005517          	auipc	a0,0x5
    80003d90:	97c50513          	addi	a0,a0,-1668 # 80008708 <syscallnum+0x128>
    80003d94:	ffffc097          	auipc	ra,0xffffc
    80003d98:	7f4080e7          	jalr	2036(ra) # 80000588 <printf>
  return 0;
    80003d9c:	4501                	li	a0,0
}
    80003d9e:	60a6                	ld	ra,72(sp)
    80003da0:	6406                	ld	s0,64(sp)
    80003da2:	74e2                	ld	s1,56(sp)
    80003da4:	7942                	ld	s2,48(sp)
    80003da6:	79a2                	ld	s3,40(sp)
    80003da8:	7a02                	ld	s4,32(sp)
    80003daa:	6ae2                	ld	s5,24(sp)
    80003dac:	6b42                	ld	s6,16(sp)
    80003dae:	6ba2                	ld	s7,8(sp)
    80003db0:	6161                	addi	sp,sp,80
    80003db2:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003db4:	04000613          	li	a2,64
    80003db8:	4581                	li	a1,0
    80003dba:	854e                	mv	a0,s3
    80003dbc:	ffffd097          	auipc	ra,0xffffd
    80003dc0:	f16080e7          	jalr	-234(ra) # 80000cd2 <memset>
      dip->type = type;
    80003dc4:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003dc8:	854a                	mv	a0,s2
    80003dca:	00001097          	auipc	ra,0x1
    80003dce:	c84080e7          	jalr	-892(ra) # 80004a4e <log_write>
      brelse(bp);
    80003dd2:	854a                	mv	a0,s2
    80003dd4:	00000097          	auipc	ra,0x0
    80003dd8:	9f6080e7          	jalr	-1546(ra) # 800037ca <brelse>
      return iget(dev, inum);
    80003ddc:	85da                	mv	a1,s6
    80003dde:	8556                	mv	a0,s5
    80003de0:	00000097          	auipc	ra,0x0
    80003de4:	d9c080e7          	jalr	-612(ra) # 80003b7c <iget>
    80003de8:	bf5d                	j	80003d9e <ialloc+0x86>

0000000080003dea <iupdate>:
{
    80003dea:	1101                	addi	sp,sp,-32
    80003dec:	ec06                	sd	ra,24(sp)
    80003dee:	e822                	sd	s0,16(sp)
    80003df0:	e426                	sd	s1,8(sp)
    80003df2:	e04a                	sd	s2,0(sp)
    80003df4:	1000                	addi	s0,sp,32
    80003df6:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003df8:	415c                	lw	a5,4(a0)
    80003dfa:	0047d79b          	srliw	a5,a5,0x4
    80003dfe:	0001d597          	auipc	a1,0x1d
    80003e02:	2b25a583          	lw	a1,690(a1) # 800210b0 <sb+0x18>
    80003e06:	9dbd                	addw	a1,a1,a5
    80003e08:	4108                	lw	a0,0(a0)
    80003e0a:	00000097          	auipc	ra,0x0
    80003e0e:	890080e7          	jalr	-1904(ra) # 8000369a <bread>
    80003e12:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003e14:	05850793          	addi	a5,a0,88
    80003e18:	40c8                	lw	a0,4(s1)
    80003e1a:	893d                	andi	a0,a0,15
    80003e1c:	051a                	slli	a0,a0,0x6
    80003e1e:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003e20:	04449703          	lh	a4,68(s1)
    80003e24:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003e28:	04649703          	lh	a4,70(s1)
    80003e2c:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003e30:	04849703          	lh	a4,72(s1)
    80003e34:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003e38:	04a49703          	lh	a4,74(s1)
    80003e3c:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003e40:	44f8                	lw	a4,76(s1)
    80003e42:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003e44:	03400613          	li	a2,52
    80003e48:	05048593          	addi	a1,s1,80
    80003e4c:	0531                	addi	a0,a0,12
    80003e4e:	ffffd097          	auipc	ra,0xffffd
    80003e52:	ee0080e7          	jalr	-288(ra) # 80000d2e <memmove>
  log_write(bp);
    80003e56:	854a                	mv	a0,s2
    80003e58:	00001097          	auipc	ra,0x1
    80003e5c:	bf6080e7          	jalr	-1034(ra) # 80004a4e <log_write>
  brelse(bp);
    80003e60:	854a                	mv	a0,s2
    80003e62:	00000097          	auipc	ra,0x0
    80003e66:	968080e7          	jalr	-1688(ra) # 800037ca <brelse>
}
    80003e6a:	60e2                	ld	ra,24(sp)
    80003e6c:	6442                	ld	s0,16(sp)
    80003e6e:	64a2                	ld	s1,8(sp)
    80003e70:	6902                	ld	s2,0(sp)
    80003e72:	6105                	addi	sp,sp,32
    80003e74:	8082                	ret

0000000080003e76 <idup>:
{
    80003e76:	1101                	addi	sp,sp,-32
    80003e78:	ec06                	sd	ra,24(sp)
    80003e7a:	e822                	sd	s0,16(sp)
    80003e7c:	e426                	sd	s1,8(sp)
    80003e7e:	1000                	addi	s0,sp,32
    80003e80:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003e82:	0001d517          	auipc	a0,0x1d
    80003e86:	23650513          	addi	a0,a0,566 # 800210b8 <itable>
    80003e8a:	ffffd097          	auipc	ra,0xffffd
    80003e8e:	d4c080e7          	jalr	-692(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003e92:	449c                	lw	a5,8(s1)
    80003e94:	2785                	addiw	a5,a5,1
    80003e96:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003e98:	0001d517          	auipc	a0,0x1d
    80003e9c:	22050513          	addi	a0,a0,544 # 800210b8 <itable>
    80003ea0:	ffffd097          	auipc	ra,0xffffd
    80003ea4:	dea080e7          	jalr	-534(ra) # 80000c8a <release>
}
    80003ea8:	8526                	mv	a0,s1
    80003eaa:	60e2                	ld	ra,24(sp)
    80003eac:	6442                	ld	s0,16(sp)
    80003eae:	64a2                	ld	s1,8(sp)
    80003eb0:	6105                	addi	sp,sp,32
    80003eb2:	8082                	ret

0000000080003eb4 <ilock>:
{
    80003eb4:	1101                	addi	sp,sp,-32
    80003eb6:	ec06                	sd	ra,24(sp)
    80003eb8:	e822                	sd	s0,16(sp)
    80003eba:	e426                	sd	s1,8(sp)
    80003ebc:	e04a                	sd	s2,0(sp)
    80003ebe:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003ec0:	c115                	beqz	a0,80003ee4 <ilock+0x30>
    80003ec2:	84aa                	mv	s1,a0
    80003ec4:	451c                	lw	a5,8(a0)
    80003ec6:	00f05f63          	blez	a5,80003ee4 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003eca:	0541                	addi	a0,a0,16
    80003ecc:	00001097          	auipc	ra,0x1
    80003ed0:	ca2080e7          	jalr	-862(ra) # 80004b6e <acquiresleep>
  if(ip->valid == 0){
    80003ed4:	40bc                	lw	a5,64(s1)
    80003ed6:	cf99                	beqz	a5,80003ef4 <ilock+0x40>
}
    80003ed8:	60e2                	ld	ra,24(sp)
    80003eda:	6442                	ld	s0,16(sp)
    80003edc:	64a2                	ld	s1,8(sp)
    80003ede:	6902                	ld	s2,0(sp)
    80003ee0:	6105                	addi	sp,sp,32
    80003ee2:	8082                	ret
    panic("ilock");
    80003ee4:	00005517          	auipc	a0,0x5
    80003ee8:	83c50513          	addi	a0,a0,-1988 # 80008720 <syscallnum+0x140>
    80003eec:	ffffc097          	auipc	ra,0xffffc
    80003ef0:	652080e7          	jalr	1618(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003ef4:	40dc                	lw	a5,4(s1)
    80003ef6:	0047d79b          	srliw	a5,a5,0x4
    80003efa:	0001d597          	auipc	a1,0x1d
    80003efe:	1b65a583          	lw	a1,438(a1) # 800210b0 <sb+0x18>
    80003f02:	9dbd                	addw	a1,a1,a5
    80003f04:	4088                	lw	a0,0(s1)
    80003f06:	fffff097          	auipc	ra,0xfffff
    80003f0a:	794080e7          	jalr	1940(ra) # 8000369a <bread>
    80003f0e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003f10:	05850593          	addi	a1,a0,88
    80003f14:	40dc                	lw	a5,4(s1)
    80003f16:	8bbd                	andi	a5,a5,15
    80003f18:	079a                	slli	a5,a5,0x6
    80003f1a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003f1c:	00059783          	lh	a5,0(a1)
    80003f20:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003f24:	00259783          	lh	a5,2(a1)
    80003f28:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003f2c:	00459783          	lh	a5,4(a1)
    80003f30:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003f34:	00659783          	lh	a5,6(a1)
    80003f38:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003f3c:	459c                	lw	a5,8(a1)
    80003f3e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003f40:	03400613          	li	a2,52
    80003f44:	05b1                	addi	a1,a1,12
    80003f46:	05048513          	addi	a0,s1,80
    80003f4a:	ffffd097          	auipc	ra,0xffffd
    80003f4e:	de4080e7          	jalr	-540(ra) # 80000d2e <memmove>
    brelse(bp);
    80003f52:	854a                	mv	a0,s2
    80003f54:	00000097          	auipc	ra,0x0
    80003f58:	876080e7          	jalr	-1930(ra) # 800037ca <brelse>
    ip->valid = 1;
    80003f5c:	4785                	li	a5,1
    80003f5e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003f60:	04449783          	lh	a5,68(s1)
    80003f64:	fbb5                	bnez	a5,80003ed8 <ilock+0x24>
      panic("ilock: no type");
    80003f66:	00004517          	auipc	a0,0x4
    80003f6a:	7c250513          	addi	a0,a0,1986 # 80008728 <syscallnum+0x148>
    80003f6e:	ffffc097          	auipc	ra,0xffffc
    80003f72:	5d0080e7          	jalr	1488(ra) # 8000053e <panic>

0000000080003f76 <iunlock>:
{
    80003f76:	1101                	addi	sp,sp,-32
    80003f78:	ec06                	sd	ra,24(sp)
    80003f7a:	e822                	sd	s0,16(sp)
    80003f7c:	e426                	sd	s1,8(sp)
    80003f7e:	e04a                	sd	s2,0(sp)
    80003f80:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003f82:	c905                	beqz	a0,80003fb2 <iunlock+0x3c>
    80003f84:	84aa                	mv	s1,a0
    80003f86:	01050913          	addi	s2,a0,16
    80003f8a:	854a                	mv	a0,s2
    80003f8c:	00001097          	auipc	ra,0x1
    80003f90:	c7c080e7          	jalr	-900(ra) # 80004c08 <holdingsleep>
    80003f94:	cd19                	beqz	a0,80003fb2 <iunlock+0x3c>
    80003f96:	449c                	lw	a5,8(s1)
    80003f98:	00f05d63          	blez	a5,80003fb2 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003f9c:	854a                	mv	a0,s2
    80003f9e:	00001097          	auipc	ra,0x1
    80003fa2:	c26080e7          	jalr	-986(ra) # 80004bc4 <releasesleep>
}
    80003fa6:	60e2                	ld	ra,24(sp)
    80003fa8:	6442                	ld	s0,16(sp)
    80003faa:	64a2                	ld	s1,8(sp)
    80003fac:	6902                	ld	s2,0(sp)
    80003fae:	6105                	addi	sp,sp,32
    80003fb0:	8082                	ret
    panic("iunlock");
    80003fb2:	00004517          	auipc	a0,0x4
    80003fb6:	78650513          	addi	a0,a0,1926 # 80008738 <syscallnum+0x158>
    80003fba:	ffffc097          	auipc	ra,0xffffc
    80003fbe:	584080e7          	jalr	1412(ra) # 8000053e <panic>

0000000080003fc2 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003fc2:	7179                	addi	sp,sp,-48
    80003fc4:	f406                	sd	ra,40(sp)
    80003fc6:	f022                	sd	s0,32(sp)
    80003fc8:	ec26                	sd	s1,24(sp)
    80003fca:	e84a                	sd	s2,16(sp)
    80003fcc:	e44e                	sd	s3,8(sp)
    80003fce:	e052                	sd	s4,0(sp)
    80003fd0:	1800                	addi	s0,sp,48
    80003fd2:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003fd4:	05050493          	addi	s1,a0,80
    80003fd8:	08050913          	addi	s2,a0,128
    80003fdc:	a021                	j	80003fe4 <itrunc+0x22>
    80003fde:	0491                	addi	s1,s1,4
    80003fe0:	01248d63          	beq	s1,s2,80003ffa <itrunc+0x38>
    if(ip->addrs[i]){
    80003fe4:	408c                	lw	a1,0(s1)
    80003fe6:	dde5                	beqz	a1,80003fde <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003fe8:	0009a503          	lw	a0,0(s3)
    80003fec:	00000097          	auipc	ra,0x0
    80003ff0:	8f4080e7          	jalr	-1804(ra) # 800038e0 <bfree>
      ip->addrs[i] = 0;
    80003ff4:	0004a023          	sw	zero,0(s1)
    80003ff8:	b7dd                	j	80003fde <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003ffa:	0809a583          	lw	a1,128(s3)
    80003ffe:	e185                	bnez	a1,8000401e <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80004000:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80004004:	854e                	mv	a0,s3
    80004006:	00000097          	auipc	ra,0x0
    8000400a:	de4080e7          	jalr	-540(ra) # 80003dea <iupdate>
}
    8000400e:	70a2                	ld	ra,40(sp)
    80004010:	7402                	ld	s0,32(sp)
    80004012:	64e2                	ld	s1,24(sp)
    80004014:	6942                	ld	s2,16(sp)
    80004016:	69a2                	ld	s3,8(sp)
    80004018:	6a02                	ld	s4,0(sp)
    8000401a:	6145                	addi	sp,sp,48
    8000401c:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000401e:	0009a503          	lw	a0,0(s3)
    80004022:	fffff097          	auipc	ra,0xfffff
    80004026:	678080e7          	jalr	1656(ra) # 8000369a <bread>
    8000402a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000402c:	05850493          	addi	s1,a0,88
    80004030:	45850913          	addi	s2,a0,1112
    80004034:	a021                	j	8000403c <itrunc+0x7a>
    80004036:	0491                	addi	s1,s1,4
    80004038:	01248b63          	beq	s1,s2,8000404e <itrunc+0x8c>
      if(a[j])
    8000403c:	408c                	lw	a1,0(s1)
    8000403e:	dde5                	beqz	a1,80004036 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80004040:	0009a503          	lw	a0,0(s3)
    80004044:	00000097          	auipc	ra,0x0
    80004048:	89c080e7          	jalr	-1892(ra) # 800038e0 <bfree>
    8000404c:	b7ed                	j	80004036 <itrunc+0x74>
    brelse(bp);
    8000404e:	8552                	mv	a0,s4
    80004050:	fffff097          	auipc	ra,0xfffff
    80004054:	77a080e7          	jalr	1914(ra) # 800037ca <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80004058:	0809a583          	lw	a1,128(s3)
    8000405c:	0009a503          	lw	a0,0(s3)
    80004060:	00000097          	auipc	ra,0x0
    80004064:	880080e7          	jalr	-1920(ra) # 800038e0 <bfree>
    ip->addrs[NDIRECT] = 0;
    80004068:	0809a023          	sw	zero,128(s3)
    8000406c:	bf51                	j	80004000 <itrunc+0x3e>

000000008000406e <iput>:
{
    8000406e:	1101                	addi	sp,sp,-32
    80004070:	ec06                	sd	ra,24(sp)
    80004072:	e822                	sd	s0,16(sp)
    80004074:	e426                	sd	s1,8(sp)
    80004076:	e04a                	sd	s2,0(sp)
    80004078:	1000                	addi	s0,sp,32
    8000407a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000407c:	0001d517          	auipc	a0,0x1d
    80004080:	03c50513          	addi	a0,a0,60 # 800210b8 <itable>
    80004084:	ffffd097          	auipc	ra,0xffffd
    80004088:	b52080e7          	jalr	-1198(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000408c:	4498                	lw	a4,8(s1)
    8000408e:	4785                	li	a5,1
    80004090:	02f70363          	beq	a4,a5,800040b6 <iput+0x48>
  ip->ref--;
    80004094:	449c                	lw	a5,8(s1)
    80004096:	37fd                	addiw	a5,a5,-1
    80004098:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000409a:	0001d517          	auipc	a0,0x1d
    8000409e:	01e50513          	addi	a0,a0,30 # 800210b8 <itable>
    800040a2:	ffffd097          	auipc	ra,0xffffd
    800040a6:	be8080e7          	jalr	-1048(ra) # 80000c8a <release>
}
    800040aa:	60e2                	ld	ra,24(sp)
    800040ac:	6442                	ld	s0,16(sp)
    800040ae:	64a2                	ld	s1,8(sp)
    800040b0:	6902                	ld	s2,0(sp)
    800040b2:	6105                	addi	sp,sp,32
    800040b4:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800040b6:	40bc                	lw	a5,64(s1)
    800040b8:	dff1                	beqz	a5,80004094 <iput+0x26>
    800040ba:	04a49783          	lh	a5,74(s1)
    800040be:	fbf9                	bnez	a5,80004094 <iput+0x26>
    acquiresleep(&ip->lock);
    800040c0:	01048913          	addi	s2,s1,16
    800040c4:	854a                	mv	a0,s2
    800040c6:	00001097          	auipc	ra,0x1
    800040ca:	aa8080e7          	jalr	-1368(ra) # 80004b6e <acquiresleep>
    release(&itable.lock);
    800040ce:	0001d517          	auipc	a0,0x1d
    800040d2:	fea50513          	addi	a0,a0,-22 # 800210b8 <itable>
    800040d6:	ffffd097          	auipc	ra,0xffffd
    800040da:	bb4080e7          	jalr	-1100(ra) # 80000c8a <release>
    itrunc(ip);
    800040de:	8526                	mv	a0,s1
    800040e0:	00000097          	auipc	ra,0x0
    800040e4:	ee2080e7          	jalr	-286(ra) # 80003fc2 <itrunc>
    ip->type = 0;
    800040e8:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800040ec:	8526                	mv	a0,s1
    800040ee:	00000097          	auipc	ra,0x0
    800040f2:	cfc080e7          	jalr	-772(ra) # 80003dea <iupdate>
    ip->valid = 0;
    800040f6:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800040fa:	854a                	mv	a0,s2
    800040fc:	00001097          	auipc	ra,0x1
    80004100:	ac8080e7          	jalr	-1336(ra) # 80004bc4 <releasesleep>
    acquire(&itable.lock);
    80004104:	0001d517          	auipc	a0,0x1d
    80004108:	fb450513          	addi	a0,a0,-76 # 800210b8 <itable>
    8000410c:	ffffd097          	auipc	ra,0xffffd
    80004110:	aca080e7          	jalr	-1334(ra) # 80000bd6 <acquire>
    80004114:	b741                	j	80004094 <iput+0x26>

0000000080004116 <iunlockput>:
{
    80004116:	1101                	addi	sp,sp,-32
    80004118:	ec06                	sd	ra,24(sp)
    8000411a:	e822                	sd	s0,16(sp)
    8000411c:	e426                	sd	s1,8(sp)
    8000411e:	1000                	addi	s0,sp,32
    80004120:	84aa                	mv	s1,a0
  iunlock(ip);
    80004122:	00000097          	auipc	ra,0x0
    80004126:	e54080e7          	jalr	-428(ra) # 80003f76 <iunlock>
  iput(ip);
    8000412a:	8526                	mv	a0,s1
    8000412c:	00000097          	auipc	ra,0x0
    80004130:	f42080e7          	jalr	-190(ra) # 8000406e <iput>
}
    80004134:	60e2                	ld	ra,24(sp)
    80004136:	6442                	ld	s0,16(sp)
    80004138:	64a2                	ld	s1,8(sp)
    8000413a:	6105                	addi	sp,sp,32
    8000413c:	8082                	ret

000000008000413e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000413e:	1141                	addi	sp,sp,-16
    80004140:	e422                	sd	s0,8(sp)
    80004142:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004144:	411c                	lw	a5,0(a0)
    80004146:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004148:	415c                	lw	a5,4(a0)
    8000414a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000414c:	04451783          	lh	a5,68(a0)
    80004150:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004154:	04a51783          	lh	a5,74(a0)
    80004158:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000415c:	04c56783          	lwu	a5,76(a0)
    80004160:	e99c                	sd	a5,16(a1)
}
    80004162:	6422                	ld	s0,8(sp)
    80004164:	0141                	addi	sp,sp,16
    80004166:	8082                	ret

0000000080004168 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004168:	457c                	lw	a5,76(a0)
    8000416a:	0ed7e963          	bltu	a5,a3,8000425c <readi+0xf4>
{
    8000416e:	7159                	addi	sp,sp,-112
    80004170:	f486                	sd	ra,104(sp)
    80004172:	f0a2                	sd	s0,96(sp)
    80004174:	eca6                	sd	s1,88(sp)
    80004176:	e8ca                	sd	s2,80(sp)
    80004178:	e4ce                	sd	s3,72(sp)
    8000417a:	e0d2                	sd	s4,64(sp)
    8000417c:	fc56                	sd	s5,56(sp)
    8000417e:	f85a                	sd	s6,48(sp)
    80004180:	f45e                	sd	s7,40(sp)
    80004182:	f062                	sd	s8,32(sp)
    80004184:	ec66                	sd	s9,24(sp)
    80004186:	e86a                	sd	s10,16(sp)
    80004188:	e46e                	sd	s11,8(sp)
    8000418a:	1880                	addi	s0,sp,112
    8000418c:	8b2a                	mv	s6,a0
    8000418e:	8bae                	mv	s7,a1
    80004190:	8a32                	mv	s4,a2
    80004192:	84b6                	mv	s1,a3
    80004194:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80004196:	9f35                	addw	a4,a4,a3
    return 0;
    80004198:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000419a:	0ad76063          	bltu	a4,a3,8000423a <readi+0xd2>
  if(off + n > ip->size)
    8000419e:	00e7f463          	bgeu	a5,a4,800041a6 <readi+0x3e>
    n = ip->size - off;
    800041a2:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800041a6:	0a0a8963          	beqz	s5,80004258 <readi+0xf0>
    800041aa:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800041ac:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800041b0:	5c7d                	li	s8,-1
    800041b2:	a82d                	j	800041ec <readi+0x84>
    800041b4:	020d1d93          	slli	s11,s10,0x20
    800041b8:	020ddd93          	srli	s11,s11,0x20
    800041bc:	05890793          	addi	a5,s2,88
    800041c0:	86ee                	mv	a3,s11
    800041c2:	963e                	add	a2,a2,a5
    800041c4:	85d2                	mv	a1,s4
    800041c6:	855e                	mv	a0,s7
    800041c8:	ffffe097          	auipc	ra,0xffffe
    800041cc:	7b0080e7          	jalr	1968(ra) # 80002978 <either_copyout>
    800041d0:	05850d63          	beq	a0,s8,8000422a <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800041d4:	854a                	mv	a0,s2
    800041d6:	fffff097          	auipc	ra,0xfffff
    800041da:	5f4080e7          	jalr	1524(ra) # 800037ca <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800041de:	013d09bb          	addw	s3,s10,s3
    800041e2:	009d04bb          	addw	s1,s10,s1
    800041e6:	9a6e                	add	s4,s4,s11
    800041e8:	0559f763          	bgeu	s3,s5,80004236 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    800041ec:	00a4d59b          	srliw	a1,s1,0xa
    800041f0:	855a                	mv	a0,s6
    800041f2:	00000097          	auipc	ra,0x0
    800041f6:	8a2080e7          	jalr	-1886(ra) # 80003a94 <bmap>
    800041fa:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800041fe:	cd85                	beqz	a1,80004236 <readi+0xce>
    bp = bread(ip->dev, addr);
    80004200:	000b2503          	lw	a0,0(s6)
    80004204:	fffff097          	auipc	ra,0xfffff
    80004208:	496080e7          	jalr	1174(ra) # 8000369a <bread>
    8000420c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000420e:	3ff4f613          	andi	a2,s1,1023
    80004212:	40cc87bb          	subw	a5,s9,a2
    80004216:	413a873b          	subw	a4,s5,s3
    8000421a:	8d3e                	mv	s10,a5
    8000421c:	2781                	sext.w	a5,a5
    8000421e:	0007069b          	sext.w	a3,a4
    80004222:	f8f6f9e3          	bgeu	a3,a5,800041b4 <readi+0x4c>
    80004226:	8d3a                	mv	s10,a4
    80004228:	b771                	j	800041b4 <readi+0x4c>
      brelse(bp);
    8000422a:	854a                	mv	a0,s2
    8000422c:	fffff097          	auipc	ra,0xfffff
    80004230:	59e080e7          	jalr	1438(ra) # 800037ca <brelse>
      tot = -1;
    80004234:	59fd                	li	s3,-1
  }
  return tot;
    80004236:	0009851b          	sext.w	a0,s3
}
    8000423a:	70a6                	ld	ra,104(sp)
    8000423c:	7406                	ld	s0,96(sp)
    8000423e:	64e6                	ld	s1,88(sp)
    80004240:	6946                	ld	s2,80(sp)
    80004242:	69a6                	ld	s3,72(sp)
    80004244:	6a06                	ld	s4,64(sp)
    80004246:	7ae2                	ld	s5,56(sp)
    80004248:	7b42                	ld	s6,48(sp)
    8000424a:	7ba2                	ld	s7,40(sp)
    8000424c:	7c02                	ld	s8,32(sp)
    8000424e:	6ce2                	ld	s9,24(sp)
    80004250:	6d42                	ld	s10,16(sp)
    80004252:	6da2                	ld	s11,8(sp)
    80004254:	6165                	addi	sp,sp,112
    80004256:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004258:	89d6                	mv	s3,s5
    8000425a:	bff1                	j	80004236 <readi+0xce>
    return 0;
    8000425c:	4501                	li	a0,0
}
    8000425e:	8082                	ret

0000000080004260 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004260:	457c                	lw	a5,76(a0)
    80004262:	10d7e863          	bltu	a5,a3,80004372 <writei+0x112>
{
    80004266:	7159                	addi	sp,sp,-112
    80004268:	f486                	sd	ra,104(sp)
    8000426a:	f0a2                	sd	s0,96(sp)
    8000426c:	eca6                	sd	s1,88(sp)
    8000426e:	e8ca                	sd	s2,80(sp)
    80004270:	e4ce                	sd	s3,72(sp)
    80004272:	e0d2                	sd	s4,64(sp)
    80004274:	fc56                	sd	s5,56(sp)
    80004276:	f85a                	sd	s6,48(sp)
    80004278:	f45e                	sd	s7,40(sp)
    8000427a:	f062                	sd	s8,32(sp)
    8000427c:	ec66                	sd	s9,24(sp)
    8000427e:	e86a                	sd	s10,16(sp)
    80004280:	e46e                	sd	s11,8(sp)
    80004282:	1880                	addi	s0,sp,112
    80004284:	8aaa                	mv	s5,a0
    80004286:	8bae                	mv	s7,a1
    80004288:	8a32                	mv	s4,a2
    8000428a:	8936                	mv	s2,a3
    8000428c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000428e:	00e687bb          	addw	a5,a3,a4
    80004292:	0ed7e263          	bltu	a5,a3,80004376 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004296:	00043737          	lui	a4,0x43
    8000429a:	0ef76063          	bltu	a4,a5,8000437a <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000429e:	0c0b0863          	beqz	s6,8000436e <writei+0x10e>
    800042a2:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800042a4:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800042a8:	5c7d                	li	s8,-1
    800042aa:	a091                	j	800042ee <writei+0x8e>
    800042ac:	020d1d93          	slli	s11,s10,0x20
    800042b0:	020ddd93          	srli	s11,s11,0x20
    800042b4:	05848793          	addi	a5,s1,88
    800042b8:	86ee                	mv	a3,s11
    800042ba:	8652                	mv	a2,s4
    800042bc:	85de                	mv	a1,s7
    800042be:	953e                	add	a0,a0,a5
    800042c0:	ffffe097          	auipc	ra,0xffffe
    800042c4:	70e080e7          	jalr	1806(ra) # 800029ce <either_copyin>
    800042c8:	07850263          	beq	a0,s8,8000432c <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800042cc:	8526                	mv	a0,s1
    800042ce:	00000097          	auipc	ra,0x0
    800042d2:	780080e7          	jalr	1920(ra) # 80004a4e <log_write>
    brelse(bp);
    800042d6:	8526                	mv	a0,s1
    800042d8:	fffff097          	auipc	ra,0xfffff
    800042dc:	4f2080e7          	jalr	1266(ra) # 800037ca <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800042e0:	013d09bb          	addw	s3,s10,s3
    800042e4:	012d093b          	addw	s2,s10,s2
    800042e8:	9a6e                	add	s4,s4,s11
    800042ea:	0569f663          	bgeu	s3,s6,80004336 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    800042ee:	00a9559b          	srliw	a1,s2,0xa
    800042f2:	8556                	mv	a0,s5
    800042f4:	fffff097          	auipc	ra,0xfffff
    800042f8:	7a0080e7          	jalr	1952(ra) # 80003a94 <bmap>
    800042fc:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004300:	c99d                	beqz	a1,80004336 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80004302:	000aa503          	lw	a0,0(s5)
    80004306:	fffff097          	auipc	ra,0xfffff
    8000430a:	394080e7          	jalr	916(ra) # 8000369a <bread>
    8000430e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004310:	3ff97513          	andi	a0,s2,1023
    80004314:	40ac87bb          	subw	a5,s9,a0
    80004318:	413b073b          	subw	a4,s6,s3
    8000431c:	8d3e                	mv	s10,a5
    8000431e:	2781                	sext.w	a5,a5
    80004320:	0007069b          	sext.w	a3,a4
    80004324:	f8f6f4e3          	bgeu	a3,a5,800042ac <writei+0x4c>
    80004328:	8d3a                	mv	s10,a4
    8000432a:	b749                	j	800042ac <writei+0x4c>
      brelse(bp);
    8000432c:	8526                	mv	a0,s1
    8000432e:	fffff097          	auipc	ra,0xfffff
    80004332:	49c080e7          	jalr	1180(ra) # 800037ca <brelse>
  }

  if(off > ip->size)
    80004336:	04caa783          	lw	a5,76(s5)
    8000433a:	0127f463          	bgeu	a5,s2,80004342 <writei+0xe2>
    ip->size = off;
    8000433e:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004342:	8556                	mv	a0,s5
    80004344:	00000097          	auipc	ra,0x0
    80004348:	aa6080e7          	jalr	-1370(ra) # 80003dea <iupdate>

  return tot;
    8000434c:	0009851b          	sext.w	a0,s3
}
    80004350:	70a6                	ld	ra,104(sp)
    80004352:	7406                	ld	s0,96(sp)
    80004354:	64e6                	ld	s1,88(sp)
    80004356:	6946                	ld	s2,80(sp)
    80004358:	69a6                	ld	s3,72(sp)
    8000435a:	6a06                	ld	s4,64(sp)
    8000435c:	7ae2                	ld	s5,56(sp)
    8000435e:	7b42                	ld	s6,48(sp)
    80004360:	7ba2                	ld	s7,40(sp)
    80004362:	7c02                	ld	s8,32(sp)
    80004364:	6ce2                	ld	s9,24(sp)
    80004366:	6d42                	ld	s10,16(sp)
    80004368:	6da2                	ld	s11,8(sp)
    8000436a:	6165                	addi	sp,sp,112
    8000436c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000436e:	89da                	mv	s3,s6
    80004370:	bfc9                	j	80004342 <writei+0xe2>
    return -1;
    80004372:	557d                	li	a0,-1
}
    80004374:	8082                	ret
    return -1;
    80004376:	557d                	li	a0,-1
    80004378:	bfe1                	j	80004350 <writei+0xf0>
    return -1;
    8000437a:	557d                	li	a0,-1
    8000437c:	bfd1                	j	80004350 <writei+0xf0>

000000008000437e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000437e:	1141                	addi	sp,sp,-16
    80004380:	e406                	sd	ra,8(sp)
    80004382:	e022                	sd	s0,0(sp)
    80004384:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004386:	4639                	li	a2,14
    80004388:	ffffd097          	auipc	ra,0xffffd
    8000438c:	a1a080e7          	jalr	-1510(ra) # 80000da2 <strncmp>
}
    80004390:	60a2                	ld	ra,8(sp)
    80004392:	6402                	ld	s0,0(sp)
    80004394:	0141                	addi	sp,sp,16
    80004396:	8082                	ret

0000000080004398 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004398:	7139                	addi	sp,sp,-64
    8000439a:	fc06                	sd	ra,56(sp)
    8000439c:	f822                	sd	s0,48(sp)
    8000439e:	f426                	sd	s1,40(sp)
    800043a0:	f04a                	sd	s2,32(sp)
    800043a2:	ec4e                	sd	s3,24(sp)
    800043a4:	e852                	sd	s4,16(sp)
    800043a6:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800043a8:	04451703          	lh	a4,68(a0)
    800043ac:	4785                	li	a5,1
    800043ae:	00f71a63          	bne	a4,a5,800043c2 <dirlookup+0x2a>
    800043b2:	892a                	mv	s2,a0
    800043b4:	89ae                	mv	s3,a1
    800043b6:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800043b8:	457c                	lw	a5,76(a0)
    800043ba:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800043bc:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043be:	e79d                	bnez	a5,800043ec <dirlookup+0x54>
    800043c0:	a8a5                	j	80004438 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800043c2:	00004517          	auipc	a0,0x4
    800043c6:	37e50513          	addi	a0,a0,894 # 80008740 <syscallnum+0x160>
    800043ca:	ffffc097          	auipc	ra,0xffffc
    800043ce:	174080e7          	jalr	372(ra) # 8000053e <panic>
      panic("dirlookup read");
    800043d2:	00004517          	auipc	a0,0x4
    800043d6:	38650513          	addi	a0,a0,902 # 80008758 <syscallnum+0x178>
    800043da:	ffffc097          	auipc	ra,0xffffc
    800043de:	164080e7          	jalr	356(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043e2:	24c1                	addiw	s1,s1,16
    800043e4:	04c92783          	lw	a5,76(s2)
    800043e8:	04f4f763          	bgeu	s1,a5,80004436 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043ec:	4741                	li	a4,16
    800043ee:	86a6                	mv	a3,s1
    800043f0:	fc040613          	addi	a2,s0,-64
    800043f4:	4581                	li	a1,0
    800043f6:	854a                	mv	a0,s2
    800043f8:	00000097          	auipc	ra,0x0
    800043fc:	d70080e7          	jalr	-656(ra) # 80004168 <readi>
    80004400:	47c1                	li	a5,16
    80004402:	fcf518e3          	bne	a0,a5,800043d2 <dirlookup+0x3a>
    if(de.inum == 0)
    80004406:	fc045783          	lhu	a5,-64(s0)
    8000440a:	dfe1                	beqz	a5,800043e2 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000440c:	fc240593          	addi	a1,s0,-62
    80004410:	854e                	mv	a0,s3
    80004412:	00000097          	auipc	ra,0x0
    80004416:	f6c080e7          	jalr	-148(ra) # 8000437e <namecmp>
    8000441a:	f561                	bnez	a0,800043e2 <dirlookup+0x4a>
      if(poff)
    8000441c:	000a0463          	beqz	s4,80004424 <dirlookup+0x8c>
        *poff = off;
    80004420:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004424:	fc045583          	lhu	a1,-64(s0)
    80004428:	00092503          	lw	a0,0(s2)
    8000442c:	fffff097          	auipc	ra,0xfffff
    80004430:	750080e7          	jalr	1872(ra) # 80003b7c <iget>
    80004434:	a011                	j	80004438 <dirlookup+0xa0>
  return 0;
    80004436:	4501                	li	a0,0
}
    80004438:	70e2                	ld	ra,56(sp)
    8000443a:	7442                	ld	s0,48(sp)
    8000443c:	74a2                	ld	s1,40(sp)
    8000443e:	7902                	ld	s2,32(sp)
    80004440:	69e2                	ld	s3,24(sp)
    80004442:	6a42                	ld	s4,16(sp)
    80004444:	6121                	addi	sp,sp,64
    80004446:	8082                	ret

0000000080004448 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004448:	711d                	addi	sp,sp,-96
    8000444a:	ec86                	sd	ra,88(sp)
    8000444c:	e8a2                	sd	s0,80(sp)
    8000444e:	e4a6                	sd	s1,72(sp)
    80004450:	e0ca                	sd	s2,64(sp)
    80004452:	fc4e                	sd	s3,56(sp)
    80004454:	f852                	sd	s4,48(sp)
    80004456:	f456                	sd	s5,40(sp)
    80004458:	f05a                	sd	s6,32(sp)
    8000445a:	ec5e                	sd	s7,24(sp)
    8000445c:	e862                	sd	s8,16(sp)
    8000445e:	e466                	sd	s9,8(sp)
    80004460:	1080                	addi	s0,sp,96
    80004462:	84aa                	mv	s1,a0
    80004464:	8aae                	mv	s5,a1
    80004466:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004468:	00054703          	lbu	a4,0(a0)
    8000446c:	02f00793          	li	a5,47
    80004470:	02f70363          	beq	a4,a5,80004496 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004474:	ffffd097          	auipc	ra,0xffffd
    80004478:	538080e7          	jalr	1336(ra) # 800019ac <myproc>
    8000447c:	15053503          	ld	a0,336(a0)
    80004480:	00000097          	auipc	ra,0x0
    80004484:	9f6080e7          	jalr	-1546(ra) # 80003e76 <idup>
    80004488:	89aa                	mv	s3,a0
  while(*path == '/')
    8000448a:	02f00913          	li	s2,47
  len = path - s;
    8000448e:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004490:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004492:	4b85                	li	s7,1
    80004494:	a865                	j	8000454c <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004496:	4585                	li	a1,1
    80004498:	4505                	li	a0,1
    8000449a:	fffff097          	auipc	ra,0xfffff
    8000449e:	6e2080e7          	jalr	1762(ra) # 80003b7c <iget>
    800044a2:	89aa                	mv	s3,a0
    800044a4:	b7dd                	j	8000448a <namex+0x42>
      iunlockput(ip);
    800044a6:	854e                	mv	a0,s3
    800044a8:	00000097          	auipc	ra,0x0
    800044ac:	c6e080e7          	jalr	-914(ra) # 80004116 <iunlockput>
      return 0;
    800044b0:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800044b2:	854e                	mv	a0,s3
    800044b4:	60e6                	ld	ra,88(sp)
    800044b6:	6446                	ld	s0,80(sp)
    800044b8:	64a6                	ld	s1,72(sp)
    800044ba:	6906                	ld	s2,64(sp)
    800044bc:	79e2                	ld	s3,56(sp)
    800044be:	7a42                	ld	s4,48(sp)
    800044c0:	7aa2                	ld	s5,40(sp)
    800044c2:	7b02                	ld	s6,32(sp)
    800044c4:	6be2                	ld	s7,24(sp)
    800044c6:	6c42                	ld	s8,16(sp)
    800044c8:	6ca2                	ld	s9,8(sp)
    800044ca:	6125                	addi	sp,sp,96
    800044cc:	8082                	ret
      iunlock(ip);
    800044ce:	854e                	mv	a0,s3
    800044d0:	00000097          	auipc	ra,0x0
    800044d4:	aa6080e7          	jalr	-1370(ra) # 80003f76 <iunlock>
      return ip;
    800044d8:	bfe9                	j	800044b2 <namex+0x6a>
      iunlockput(ip);
    800044da:	854e                	mv	a0,s3
    800044dc:	00000097          	auipc	ra,0x0
    800044e0:	c3a080e7          	jalr	-966(ra) # 80004116 <iunlockput>
      return 0;
    800044e4:	89e6                	mv	s3,s9
    800044e6:	b7f1                	j	800044b2 <namex+0x6a>
  len = path - s;
    800044e8:	40b48633          	sub	a2,s1,a1
    800044ec:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800044f0:	099c5463          	bge	s8,s9,80004578 <namex+0x130>
    memmove(name, s, DIRSIZ);
    800044f4:	4639                	li	a2,14
    800044f6:	8552                	mv	a0,s4
    800044f8:	ffffd097          	auipc	ra,0xffffd
    800044fc:	836080e7          	jalr	-1994(ra) # 80000d2e <memmove>
  while(*path == '/')
    80004500:	0004c783          	lbu	a5,0(s1)
    80004504:	01279763          	bne	a5,s2,80004512 <namex+0xca>
    path++;
    80004508:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000450a:	0004c783          	lbu	a5,0(s1)
    8000450e:	ff278de3          	beq	a5,s2,80004508 <namex+0xc0>
    ilock(ip);
    80004512:	854e                	mv	a0,s3
    80004514:	00000097          	auipc	ra,0x0
    80004518:	9a0080e7          	jalr	-1632(ra) # 80003eb4 <ilock>
    if(ip->type != T_DIR){
    8000451c:	04499783          	lh	a5,68(s3)
    80004520:	f97793e3          	bne	a5,s7,800044a6 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004524:	000a8563          	beqz	s5,8000452e <namex+0xe6>
    80004528:	0004c783          	lbu	a5,0(s1)
    8000452c:	d3cd                	beqz	a5,800044ce <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000452e:	865a                	mv	a2,s6
    80004530:	85d2                	mv	a1,s4
    80004532:	854e                	mv	a0,s3
    80004534:	00000097          	auipc	ra,0x0
    80004538:	e64080e7          	jalr	-412(ra) # 80004398 <dirlookup>
    8000453c:	8caa                	mv	s9,a0
    8000453e:	dd51                	beqz	a0,800044da <namex+0x92>
    iunlockput(ip);
    80004540:	854e                	mv	a0,s3
    80004542:	00000097          	auipc	ra,0x0
    80004546:	bd4080e7          	jalr	-1068(ra) # 80004116 <iunlockput>
    ip = next;
    8000454a:	89e6                	mv	s3,s9
  while(*path == '/')
    8000454c:	0004c783          	lbu	a5,0(s1)
    80004550:	05279763          	bne	a5,s2,8000459e <namex+0x156>
    path++;
    80004554:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004556:	0004c783          	lbu	a5,0(s1)
    8000455a:	ff278de3          	beq	a5,s2,80004554 <namex+0x10c>
  if(*path == 0)
    8000455e:	c79d                	beqz	a5,8000458c <namex+0x144>
    path++;
    80004560:	85a6                	mv	a1,s1
  len = path - s;
    80004562:	8cda                	mv	s9,s6
    80004564:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004566:	01278963          	beq	a5,s2,80004578 <namex+0x130>
    8000456a:	dfbd                	beqz	a5,800044e8 <namex+0xa0>
    path++;
    8000456c:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000456e:	0004c783          	lbu	a5,0(s1)
    80004572:	ff279ce3          	bne	a5,s2,8000456a <namex+0x122>
    80004576:	bf8d                	j	800044e8 <namex+0xa0>
    memmove(name, s, len);
    80004578:	2601                	sext.w	a2,a2
    8000457a:	8552                	mv	a0,s4
    8000457c:	ffffc097          	auipc	ra,0xffffc
    80004580:	7b2080e7          	jalr	1970(ra) # 80000d2e <memmove>
    name[len] = 0;
    80004584:	9cd2                	add	s9,s9,s4
    80004586:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000458a:	bf9d                	j	80004500 <namex+0xb8>
  if(nameiparent){
    8000458c:	f20a83e3          	beqz	s5,800044b2 <namex+0x6a>
    iput(ip);
    80004590:	854e                	mv	a0,s3
    80004592:	00000097          	auipc	ra,0x0
    80004596:	adc080e7          	jalr	-1316(ra) # 8000406e <iput>
    return 0;
    8000459a:	4981                	li	s3,0
    8000459c:	bf19                	j	800044b2 <namex+0x6a>
  if(*path == 0)
    8000459e:	d7fd                	beqz	a5,8000458c <namex+0x144>
  while(*path != '/' && *path != 0)
    800045a0:	0004c783          	lbu	a5,0(s1)
    800045a4:	85a6                	mv	a1,s1
    800045a6:	b7d1                	j	8000456a <namex+0x122>

00000000800045a8 <dirlink>:
{
    800045a8:	7139                	addi	sp,sp,-64
    800045aa:	fc06                	sd	ra,56(sp)
    800045ac:	f822                	sd	s0,48(sp)
    800045ae:	f426                	sd	s1,40(sp)
    800045b0:	f04a                	sd	s2,32(sp)
    800045b2:	ec4e                	sd	s3,24(sp)
    800045b4:	e852                	sd	s4,16(sp)
    800045b6:	0080                	addi	s0,sp,64
    800045b8:	892a                	mv	s2,a0
    800045ba:	8a2e                	mv	s4,a1
    800045bc:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800045be:	4601                	li	a2,0
    800045c0:	00000097          	auipc	ra,0x0
    800045c4:	dd8080e7          	jalr	-552(ra) # 80004398 <dirlookup>
    800045c8:	e93d                	bnez	a0,8000463e <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800045ca:	04c92483          	lw	s1,76(s2)
    800045ce:	c49d                	beqz	s1,800045fc <dirlink+0x54>
    800045d0:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800045d2:	4741                	li	a4,16
    800045d4:	86a6                	mv	a3,s1
    800045d6:	fc040613          	addi	a2,s0,-64
    800045da:	4581                	li	a1,0
    800045dc:	854a                	mv	a0,s2
    800045de:	00000097          	auipc	ra,0x0
    800045e2:	b8a080e7          	jalr	-1142(ra) # 80004168 <readi>
    800045e6:	47c1                	li	a5,16
    800045e8:	06f51163          	bne	a0,a5,8000464a <dirlink+0xa2>
    if(de.inum == 0)
    800045ec:	fc045783          	lhu	a5,-64(s0)
    800045f0:	c791                	beqz	a5,800045fc <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800045f2:	24c1                	addiw	s1,s1,16
    800045f4:	04c92783          	lw	a5,76(s2)
    800045f8:	fcf4ede3          	bltu	s1,a5,800045d2 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800045fc:	4639                	li	a2,14
    800045fe:	85d2                	mv	a1,s4
    80004600:	fc240513          	addi	a0,s0,-62
    80004604:	ffffc097          	auipc	ra,0xffffc
    80004608:	7da080e7          	jalr	2010(ra) # 80000dde <strncpy>
  de.inum = inum;
    8000460c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004610:	4741                	li	a4,16
    80004612:	86a6                	mv	a3,s1
    80004614:	fc040613          	addi	a2,s0,-64
    80004618:	4581                	li	a1,0
    8000461a:	854a                	mv	a0,s2
    8000461c:	00000097          	auipc	ra,0x0
    80004620:	c44080e7          	jalr	-956(ra) # 80004260 <writei>
    80004624:	1541                	addi	a0,a0,-16
    80004626:	00a03533          	snez	a0,a0
    8000462a:	40a00533          	neg	a0,a0
}
    8000462e:	70e2                	ld	ra,56(sp)
    80004630:	7442                	ld	s0,48(sp)
    80004632:	74a2                	ld	s1,40(sp)
    80004634:	7902                	ld	s2,32(sp)
    80004636:	69e2                	ld	s3,24(sp)
    80004638:	6a42                	ld	s4,16(sp)
    8000463a:	6121                	addi	sp,sp,64
    8000463c:	8082                	ret
    iput(ip);
    8000463e:	00000097          	auipc	ra,0x0
    80004642:	a30080e7          	jalr	-1488(ra) # 8000406e <iput>
    return -1;
    80004646:	557d                	li	a0,-1
    80004648:	b7dd                	j	8000462e <dirlink+0x86>
      panic("dirlink read");
    8000464a:	00004517          	auipc	a0,0x4
    8000464e:	11e50513          	addi	a0,a0,286 # 80008768 <syscallnum+0x188>
    80004652:	ffffc097          	auipc	ra,0xffffc
    80004656:	eec080e7          	jalr	-276(ra) # 8000053e <panic>

000000008000465a <namei>:

struct inode*
namei(char *path)
{
    8000465a:	1101                	addi	sp,sp,-32
    8000465c:	ec06                	sd	ra,24(sp)
    8000465e:	e822                	sd	s0,16(sp)
    80004660:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004662:	fe040613          	addi	a2,s0,-32
    80004666:	4581                	li	a1,0
    80004668:	00000097          	auipc	ra,0x0
    8000466c:	de0080e7          	jalr	-544(ra) # 80004448 <namex>
}
    80004670:	60e2                	ld	ra,24(sp)
    80004672:	6442                	ld	s0,16(sp)
    80004674:	6105                	addi	sp,sp,32
    80004676:	8082                	ret

0000000080004678 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004678:	1141                	addi	sp,sp,-16
    8000467a:	e406                	sd	ra,8(sp)
    8000467c:	e022                	sd	s0,0(sp)
    8000467e:	0800                	addi	s0,sp,16
    80004680:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004682:	4585                	li	a1,1
    80004684:	00000097          	auipc	ra,0x0
    80004688:	dc4080e7          	jalr	-572(ra) # 80004448 <namex>
}
    8000468c:	60a2                	ld	ra,8(sp)
    8000468e:	6402                	ld	s0,0(sp)
    80004690:	0141                	addi	sp,sp,16
    80004692:	8082                	ret

0000000080004694 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004694:	1101                	addi	sp,sp,-32
    80004696:	ec06                	sd	ra,24(sp)
    80004698:	e822                	sd	s0,16(sp)
    8000469a:	e426                	sd	s1,8(sp)
    8000469c:	e04a                	sd	s2,0(sp)
    8000469e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800046a0:	0001e917          	auipc	s2,0x1e
    800046a4:	4c090913          	addi	s2,s2,1216 # 80022b60 <log>
    800046a8:	01892583          	lw	a1,24(s2)
    800046ac:	02892503          	lw	a0,40(s2)
    800046b0:	fffff097          	auipc	ra,0xfffff
    800046b4:	fea080e7          	jalr	-22(ra) # 8000369a <bread>
    800046b8:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800046ba:	02c92683          	lw	a3,44(s2)
    800046be:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800046c0:	02d05763          	blez	a3,800046ee <write_head+0x5a>
    800046c4:	0001e797          	auipc	a5,0x1e
    800046c8:	4cc78793          	addi	a5,a5,1228 # 80022b90 <log+0x30>
    800046cc:	05c50713          	addi	a4,a0,92
    800046d0:	36fd                	addiw	a3,a3,-1
    800046d2:	1682                	slli	a3,a3,0x20
    800046d4:	9281                	srli	a3,a3,0x20
    800046d6:	068a                	slli	a3,a3,0x2
    800046d8:	0001e617          	auipc	a2,0x1e
    800046dc:	4bc60613          	addi	a2,a2,1212 # 80022b94 <log+0x34>
    800046e0:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800046e2:	4390                	lw	a2,0(a5)
    800046e4:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800046e6:	0791                	addi	a5,a5,4
    800046e8:	0711                	addi	a4,a4,4
    800046ea:	fed79ce3          	bne	a5,a3,800046e2 <write_head+0x4e>
  }
  bwrite(buf);
    800046ee:	8526                	mv	a0,s1
    800046f0:	fffff097          	auipc	ra,0xfffff
    800046f4:	09c080e7          	jalr	156(ra) # 8000378c <bwrite>
  brelse(buf);
    800046f8:	8526                	mv	a0,s1
    800046fa:	fffff097          	auipc	ra,0xfffff
    800046fe:	0d0080e7          	jalr	208(ra) # 800037ca <brelse>
}
    80004702:	60e2                	ld	ra,24(sp)
    80004704:	6442                	ld	s0,16(sp)
    80004706:	64a2                	ld	s1,8(sp)
    80004708:	6902                	ld	s2,0(sp)
    8000470a:	6105                	addi	sp,sp,32
    8000470c:	8082                	ret

000000008000470e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000470e:	0001e797          	auipc	a5,0x1e
    80004712:	47e7a783          	lw	a5,1150(a5) # 80022b8c <log+0x2c>
    80004716:	0af05d63          	blez	a5,800047d0 <install_trans+0xc2>
{
    8000471a:	7139                	addi	sp,sp,-64
    8000471c:	fc06                	sd	ra,56(sp)
    8000471e:	f822                	sd	s0,48(sp)
    80004720:	f426                	sd	s1,40(sp)
    80004722:	f04a                	sd	s2,32(sp)
    80004724:	ec4e                	sd	s3,24(sp)
    80004726:	e852                	sd	s4,16(sp)
    80004728:	e456                	sd	s5,8(sp)
    8000472a:	e05a                	sd	s6,0(sp)
    8000472c:	0080                	addi	s0,sp,64
    8000472e:	8b2a                	mv	s6,a0
    80004730:	0001ea97          	auipc	s5,0x1e
    80004734:	460a8a93          	addi	s5,s5,1120 # 80022b90 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004738:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000473a:	0001e997          	auipc	s3,0x1e
    8000473e:	42698993          	addi	s3,s3,1062 # 80022b60 <log>
    80004742:	a00d                	j	80004764 <install_trans+0x56>
    brelse(lbuf);
    80004744:	854a                	mv	a0,s2
    80004746:	fffff097          	auipc	ra,0xfffff
    8000474a:	084080e7          	jalr	132(ra) # 800037ca <brelse>
    brelse(dbuf);
    8000474e:	8526                	mv	a0,s1
    80004750:	fffff097          	auipc	ra,0xfffff
    80004754:	07a080e7          	jalr	122(ra) # 800037ca <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004758:	2a05                	addiw	s4,s4,1
    8000475a:	0a91                	addi	s5,s5,4
    8000475c:	02c9a783          	lw	a5,44(s3)
    80004760:	04fa5e63          	bge	s4,a5,800047bc <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004764:	0189a583          	lw	a1,24(s3)
    80004768:	014585bb          	addw	a1,a1,s4
    8000476c:	2585                	addiw	a1,a1,1
    8000476e:	0289a503          	lw	a0,40(s3)
    80004772:	fffff097          	auipc	ra,0xfffff
    80004776:	f28080e7          	jalr	-216(ra) # 8000369a <bread>
    8000477a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000477c:	000aa583          	lw	a1,0(s5)
    80004780:	0289a503          	lw	a0,40(s3)
    80004784:	fffff097          	auipc	ra,0xfffff
    80004788:	f16080e7          	jalr	-234(ra) # 8000369a <bread>
    8000478c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000478e:	40000613          	li	a2,1024
    80004792:	05890593          	addi	a1,s2,88
    80004796:	05850513          	addi	a0,a0,88
    8000479a:	ffffc097          	auipc	ra,0xffffc
    8000479e:	594080e7          	jalr	1428(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    800047a2:	8526                	mv	a0,s1
    800047a4:	fffff097          	auipc	ra,0xfffff
    800047a8:	fe8080e7          	jalr	-24(ra) # 8000378c <bwrite>
    if(recovering == 0)
    800047ac:	f80b1ce3          	bnez	s6,80004744 <install_trans+0x36>
      bunpin(dbuf);
    800047b0:	8526                	mv	a0,s1
    800047b2:	fffff097          	auipc	ra,0xfffff
    800047b6:	0f2080e7          	jalr	242(ra) # 800038a4 <bunpin>
    800047ba:	b769                	j	80004744 <install_trans+0x36>
}
    800047bc:	70e2                	ld	ra,56(sp)
    800047be:	7442                	ld	s0,48(sp)
    800047c0:	74a2                	ld	s1,40(sp)
    800047c2:	7902                	ld	s2,32(sp)
    800047c4:	69e2                	ld	s3,24(sp)
    800047c6:	6a42                	ld	s4,16(sp)
    800047c8:	6aa2                	ld	s5,8(sp)
    800047ca:	6b02                	ld	s6,0(sp)
    800047cc:	6121                	addi	sp,sp,64
    800047ce:	8082                	ret
    800047d0:	8082                	ret

00000000800047d2 <initlog>:
{
    800047d2:	7179                	addi	sp,sp,-48
    800047d4:	f406                	sd	ra,40(sp)
    800047d6:	f022                	sd	s0,32(sp)
    800047d8:	ec26                	sd	s1,24(sp)
    800047da:	e84a                	sd	s2,16(sp)
    800047dc:	e44e                	sd	s3,8(sp)
    800047de:	1800                	addi	s0,sp,48
    800047e0:	892a                	mv	s2,a0
    800047e2:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800047e4:	0001e497          	auipc	s1,0x1e
    800047e8:	37c48493          	addi	s1,s1,892 # 80022b60 <log>
    800047ec:	00004597          	auipc	a1,0x4
    800047f0:	f8c58593          	addi	a1,a1,-116 # 80008778 <syscallnum+0x198>
    800047f4:	8526                	mv	a0,s1
    800047f6:	ffffc097          	auipc	ra,0xffffc
    800047fa:	350080e7          	jalr	848(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    800047fe:	0149a583          	lw	a1,20(s3)
    80004802:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004804:	0109a783          	lw	a5,16(s3)
    80004808:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000480a:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000480e:	854a                	mv	a0,s2
    80004810:	fffff097          	auipc	ra,0xfffff
    80004814:	e8a080e7          	jalr	-374(ra) # 8000369a <bread>
  log.lh.n = lh->n;
    80004818:	4d34                	lw	a3,88(a0)
    8000481a:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000481c:	02d05563          	blez	a3,80004846 <initlog+0x74>
    80004820:	05c50793          	addi	a5,a0,92
    80004824:	0001e717          	auipc	a4,0x1e
    80004828:	36c70713          	addi	a4,a4,876 # 80022b90 <log+0x30>
    8000482c:	36fd                	addiw	a3,a3,-1
    8000482e:	1682                	slli	a3,a3,0x20
    80004830:	9281                	srli	a3,a3,0x20
    80004832:	068a                	slli	a3,a3,0x2
    80004834:	06050613          	addi	a2,a0,96
    80004838:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000483a:	4390                	lw	a2,0(a5)
    8000483c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000483e:	0791                	addi	a5,a5,4
    80004840:	0711                	addi	a4,a4,4
    80004842:	fed79ce3          	bne	a5,a3,8000483a <initlog+0x68>
  brelse(buf);
    80004846:	fffff097          	auipc	ra,0xfffff
    8000484a:	f84080e7          	jalr	-124(ra) # 800037ca <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000484e:	4505                	li	a0,1
    80004850:	00000097          	auipc	ra,0x0
    80004854:	ebe080e7          	jalr	-322(ra) # 8000470e <install_trans>
  log.lh.n = 0;
    80004858:	0001e797          	auipc	a5,0x1e
    8000485c:	3207aa23          	sw	zero,820(a5) # 80022b8c <log+0x2c>
  write_head(); // clear the log
    80004860:	00000097          	auipc	ra,0x0
    80004864:	e34080e7          	jalr	-460(ra) # 80004694 <write_head>
}
    80004868:	70a2                	ld	ra,40(sp)
    8000486a:	7402                	ld	s0,32(sp)
    8000486c:	64e2                	ld	s1,24(sp)
    8000486e:	6942                	ld	s2,16(sp)
    80004870:	69a2                	ld	s3,8(sp)
    80004872:	6145                	addi	sp,sp,48
    80004874:	8082                	ret

0000000080004876 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004876:	1101                	addi	sp,sp,-32
    80004878:	ec06                	sd	ra,24(sp)
    8000487a:	e822                	sd	s0,16(sp)
    8000487c:	e426                	sd	s1,8(sp)
    8000487e:	e04a                	sd	s2,0(sp)
    80004880:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004882:	0001e517          	auipc	a0,0x1e
    80004886:	2de50513          	addi	a0,a0,734 # 80022b60 <log>
    8000488a:	ffffc097          	auipc	ra,0xffffc
    8000488e:	34c080e7          	jalr	844(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    80004892:	0001e497          	auipc	s1,0x1e
    80004896:	2ce48493          	addi	s1,s1,718 # 80022b60 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000489a:	4979                	li	s2,30
    8000489c:	a039                	j	800048aa <begin_op+0x34>
      sleep(&log, &log.lock);
    8000489e:	85a6                	mv	a1,s1
    800048a0:	8526                	mv	a0,s1
    800048a2:	ffffe097          	auipc	ra,0xffffe
    800048a6:	b50080e7          	jalr	-1200(ra) # 800023f2 <sleep>
    if(log.committing){
    800048aa:	50dc                	lw	a5,36(s1)
    800048ac:	fbed                	bnez	a5,8000489e <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800048ae:	509c                	lw	a5,32(s1)
    800048b0:	0017871b          	addiw	a4,a5,1
    800048b4:	0007069b          	sext.w	a3,a4
    800048b8:	0027179b          	slliw	a5,a4,0x2
    800048bc:	9fb9                	addw	a5,a5,a4
    800048be:	0017979b          	slliw	a5,a5,0x1
    800048c2:	54d8                	lw	a4,44(s1)
    800048c4:	9fb9                	addw	a5,a5,a4
    800048c6:	00f95963          	bge	s2,a5,800048d8 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800048ca:	85a6                	mv	a1,s1
    800048cc:	8526                	mv	a0,s1
    800048ce:	ffffe097          	auipc	ra,0xffffe
    800048d2:	b24080e7          	jalr	-1244(ra) # 800023f2 <sleep>
    800048d6:	bfd1                	j	800048aa <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800048d8:	0001e517          	auipc	a0,0x1e
    800048dc:	28850513          	addi	a0,a0,648 # 80022b60 <log>
    800048e0:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800048e2:	ffffc097          	auipc	ra,0xffffc
    800048e6:	3a8080e7          	jalr	936(ra) # 80000c8a <release>
      break;
    }
  }
}
    800048ea:	60e2                	ld	ra,24(sp)
    800048ec:	6442                	ld	s0,16(sp)
    800048ee:	64a2                	ld	s1,8(sp)
    800048f0:	6902                	ld	s2,0(sp)
    800048f2:	6105                	addi	sp,sp,32
    800048f4:	8082                	ret

00000000800048f6 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800048f6:	7139                	addi	sp,sp,-64
    800048f8:	fc06                	sd	ra,56(sp)
    800048fa:	f822                	sd	s0,48(sp)
    800048fc:	f426                	sd	s1,40(sp)
    800048fe:	f04a                	sd	s2,32(sp)
    80004900:	ec4e                	sd	s3,24(sp)
    80004902:	e852                	sd	s4,16(sp)
    80004904:	e456                	sd	s5,8(sp)
    80004906:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004908:	0001e497          	auipc	s1,0x1e
    8000490c:	25848493          	addi	s1,s1,600 # 80022b60 <log>
    80004910:	8526                	mv	a0,s1
    80004912:	ffffc097          	auipc	ra,0xffffc
    80004916:	2c4080e7          	jalr	708(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    8000491a:	509c                	lw	a5,32(s1)
    8000491c:	37fd                	addiw	a5,a5,-1
    8000491e:	0007891b          	sext.w	s2,a5
    80004922:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004924:	50dc                	lw	a5,36(s1)
    80004926:	e7b9                	bnez	a5,80004974 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004928:	04091e63          	bnez	s2,80004984 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000492c:	0001e497          	auipc	s1,0x1e
    80004930:	23448493          	addi	s1,s1,564 # 80022b60 <log>
    80004934:	4785                	li	a5,1
    80004936:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004938:	8526                	mv	a0,s1
    8000493a:	ffffc097          	auipc	ra,0xffffc
    8000493e:	350080e7          	jalr	848(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004942:	54dc                	lw	a5,44(s1)
    80004944:	06f04763          	bgtz	a5,800049b2 <end_op+0xbc>
    acquire(&log.lock);
    80004948:	0001e497          	auipc	s1,0x1e
    8000494c:	21848493          	addi	s1,s1,536 # 80022b60 <log>
    80004950:	8526                	mv	a0,s1
    80004952:	ffffc097          	auipc	ra,0xffffc
    80004956:	284080e7          	jalr	644(ra) # 80000bd6 <acquire>
    log.committing = 0;
    8000495a:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000495e:	8526                	mv	a0,s1
    80004960:	ffffe097          	auipc	ra,0xffffe
    80004964:	c4e080e7          	jalr	-946(ra) # 800025ae <wakeup>
    release(&log.lock);
    80004968:	8526                	mv	a0,s1
    8000496a:	ffffc097          	auipc	ra,0xffffc
    8000496e:	320080e7          	jalr	800(ra) # 80000c8a <release>
}
    80004972:	a03d                	j	800049a0 <end_op+0xaa>
    panic("log.committing");
    80004974:	00004517          	auipc	a0,0x4
    80004978:	e0c50513          	addi	a0,a0,-500 # 80008780 <syscallnum+0x1a0>
    8000497c:	ffffc097          	auipc	ra,0xffffc
    80004980:	bc2080e7          	jalr	-1086(ra) # 8000053e <panic>
    wakeup(&log);
    80004984:	0001e497          	auipc	s1,0x1e
    80004988:	1dc48493          	addi	s1,s1,476 # 80022b60 <log>
    8000498c:	8526                	mv	a0,s1
    8000498e:	ffffe097          	auipc	ra,0xffffe
    80004992:	c20080e7          	jalr	-992(ra) # 800025ae <wakeup>
  release(&log.lock);
    80004996:	8526                	mv	a0,s1
    80004998:	ffffc097          	auipc	ra,0xffffc
    8000499c:	2f2080e7          	jalr	754(ra) # 80000c8a <release>
}
    800049a0:	70e2                	ld	ra,56(sp)
    800049a2:	7442                	ld	s0,48(sp)
    800049a4:	74a2                	ld	s1,40(sp)
    800049a6:	7902                	ld	s2,32(sp)
    800049a8:	69e2                	ld	s3,24(sp)
    800049aa:	6a42                	ld	s4,16(sp)
    800049ac:	6aa2                	ld	s5,8(sp)
    800049ae:	6121                	addi	sp,sp,64
    800049b0:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800049b2:	0001ea97          	auipc	s5,0x1e
    800049b6:	1dea8a93          	addi	s5,s5,478 # 80022b90 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800049ba:	0001ea17          	auipc	s4,0x1e
    800049be:	1a6a0a13          	addi	s4,s4,422 # 80022b60 <log>
    800049c2:	018a2583          	lw	a1,24(s4)
    800049c6:	012585bb          	addw	a1,a1,s2
    800049ca:	2585                	addiw	a1,a1,1
    800049cc:	028a2503          	lw	a0,40(s4)
    800049d0:	fffff097          	auipc	ra,0xfffff
    800049d4:	cca080e7          	jalr	-822(ra) # 8000369a <bread>
    800049d8:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800049da:	000aa583          	lw	a1,0(s5)
    800049de:	028a2503          	lw	a0,40(s4)
    800049e2:	fffff097          	auipc	ra,0xfffff
    800049e6:	cb8080e7          	jalr	-840(ra) # 8000369a <bread>
    800049ea:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800049ec:	40000613          	li	a2,1024
    800049f0:	05850593          	addi	a1,a0,88
    800049f4:	05848513          	addi	a0,s1,88
    800049f8:	ffffc097          	auipc	ra,0xffffc
    800049fc:	336080e7          	jalr	822(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    80004a00:	8526                	mv	a0,s1
    80004a02:	fffff097          	auipc	ra,0xfffff
    80004a06:	d8a080e7          	jalr	-630(ra) # 8000378c <bwrite>
    brelse(from);
    80004a0a:	854e                	mv	a0,s3
    80004a0c:	fffff097          	auipc	ra,0xfffff
    80004a10:	dbe080e7          	jalr	-578(ra) # 800037ca <brelse>
    brelse(to);
    80004a14:	8526                	mv	a0,s1
    80004a16:	fffff097          	auipc	ra,0xfffff
    80004a1a:	db4080e7          	jalr	-588(ra) # 800037ca <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004a1e:	2905                	addiw	s2,s2,1
    80004a20:	0a91                	addi	s5,s5,4
    80004a22:	02ca2783          	lw	a5,44(s4)
    80004a26:	f8f94ee3          	blt	s2,a5,800049c2 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004a2a:	00000097          	auipc	ra,0x0
    80004a2e:	c6a080e7          	jalr	-918(ra) # 80004694 <write_head>
    install_trans(0); // Now install writes to home locations
    80004a32:	4501                	li	a0,0
    80004a34:	00000097          	auipc	ra,0x0
    80004a38:	cda080e7          	jalr	-806(ra) # 8000470e <install_trans>
    log.lh.n = 0;
    80004a3c:	0001e797          	auipc	a5,0x1e
    80004a40:	1407a823          	sw	zero,336(a5) # 80022b8c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004a44:	00000097          	auipc	ra,0x0
    80004a48:	c50080e7          	jalr	-944(ra) # 80004694 <write_head>
    80004a4c:	bdf5                	j	80004948 <end_op+0x52>

0000000080004a4e <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004a4e:	1101                	addi	sp,sp,-32
    80004a50:	ec06                	sd	ra,24(sp)
    80004a52:	e822                	sd	s0,16(sp)
    80004a54:	e426                	sd	s1,8(sp)
    80004a56:	e04a                	sd	s2,0(sp)
    80004a58:	1000                	addi	s0,sp,32
    80004a5a:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004a5c:	0001e917          	auipc	s2,0x1e
    80004a60:	10490913          	addi	s2,s2,260 # 80022b60 <log>
    80004a64:	854a                	mv	a0,s2
    80004a66:	ffffc097          	auipc	ra,0xffffc
    80004a6a:	170080e7          	jalr	368(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004a6e:	02c92603          	lw	a2,44(s2)
    80004a72:	47f5                	li	a5,29
    80004a74:	06c7c563          	blt	a5,a2,80004ade <log_write+0x90>
    80004a78:	0001e797          	auipc	a5,0x1e
    80004a7c:	1047a783          	lw	a5,260(a5) # 80022b7c <log+0x1c>
    80004a80:	37fd                	addiw	a5,a5,-1
    80004a82:	04f65e63          	bge	a2,a5,80004ade <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004a86:	0001e797          	auipc	a5,0x1e
    80004a8a:	0fa7a783          	lw	a5,250(a5) # 80022b80 <log+0x20>
    80004a8e:	06f05063          	blez	a5,80004aee <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004a92:	4781                	li	a5,0
    80004a94:	06c05563          	blez	a2,80004afe <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004a98:	44cc                	lw	a1,12(s1)
    80004a9a:	0001e717          	auipc	a4,0x1e
    80004a9e:	0f670713          	addi	a4,a4,246 # 80022b90 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004aa2:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004aa4:	4314                	lw	a3,0(a4)
    80004aa6:	04b68c63          	beq	a3,a1,80004afe <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004aaa:	2785                	addiw	a5,a5,1
    80004aac:	0711                	addi	a4,a4,4
    80004aae:	fef61be3          	bne	a2,a5,80004aa4 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004ab2:	0621                	addi	a2,a2,8
    80004ab4:	060a                	slli	a2,a2,0x2
    80004ab6:	0001e797          	auipc	a5,0x1e
    80004aba:	0aa78793          	addi	a5,a5,170 # 80022b60 <log>
    80004abe:	963e                	add	a2,a2,a5
    80004ac0:	44dc                	lw	a5,12(s1)
    80004ac2:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004ac4:	8526                	mv	a0,s1
    80004ac6:	fffff097          	auipc	ra,0xfffff
    80004aca:	da2080e7          	jalr	-606(ra) # 80003868 <bpin>
    log.lh.n++;
    80004ace:	0001e717          	auipc	a4,0x1e
    80004ad2:	09270713          	addi	a4,a4,146 # 80022b60 <log>
    80004ad6:	575c                	lw	a5,44(a4)
    80004ad8:	2785                	addiw	a5,a5,1
    80004ada:	d75c                	sw	a5,44(a4)
    80004adc:	a835                	j	80004b18 <log_write+0xca>
    panic("too big a transaction");
    80004ade:	00004517          	auipc	a0,0x4
    80004ae2:	cb250513          	addi	a0,a0,-846 # 80008790 <syscallnum+0x1b0>
    80004ae6:	ffffc097          	auipc	ra,0xffffc
    80004aea:	a58080e7          	jalr	-1448(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    80004aee:	00004517          	auipc	a0,0x4
    80004af2:	cba50513          	addi	a0,a0,-838 # 800087a8 <syscallnum+0x1c8>
    80004af6:	ffffc097          	auipc	ra,0xffffc
    80004afa:	a48080e7          	jalr	-1464(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    80004afe:	00878713          	addi	a4,a5,8
    80004b02:	00271693          	slli	a3,a4,0x2
    80004b06:	0001e717          	auipc	a4,0x1e
    80004b0a:	05a70713          	addi	a4,a4,90 # 80022b60 <log>
    80004b0e:	9736                	add	a4,a4,a3
    80004b10:	44d4                	lw	a3,12(s1)
    80004b12:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004b14:	faf608e3          	beq	a2,a5,80004ac4 <log_write+0x76>
  }
  release(&log.lock);
    80004b18:	0001e517          	auipc	a0,0x1e
    80004b1c:	04850513          	addi	a0,a0,72 # 80022b60 <log>
    80004b20:	ffffc097          	auipc	ra,0xffffc
    80004b24:	16a080e7          	jalr	362(ra) # 80000c8a <release>
}
    80004b28:	60e2                	ld	ra,24(sp)
    80004b2a:	6442                	ld	s0,16(sp)
    80004b2c:	64a2                	ld	s1,8(sp)
    80004b2e:	6902                	ld	s2,0(sp)
    80004b30:	6105                	addi	sp,sp,32
    80004b32:	8082                	ret

0000000080004b34 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004b34:	1101                	addi	sp,sp,-32
    80004b36:	ec06                	sd	ra,24(sp)
    80004b38:	e822                	sd	s0,16(sp)
    80004b3a:	e426                	sd	s1,8(sp)
    80004b3c:	e04a                	sd	s2,0(sp)
    80004b3e:	1000                	addi	s0,sp,32
    80004b40:	84aa                	mv	s1,a0
    80004b42:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004b44:	00004597          	auipc	a1,0x4
    80004b48:	c8458593          	addi	a1,a1,-892 # 800087c8 <syscallnum+0x1e8>
    80004b4c:	0521                	addi	a0,a0,8
    80004b4e:	ffffc097          	auipc	ra,0xffffc
    80004b52:	ff8080e7          	jalr	-8(ra) # 80000b46 <initlock>
  lk->name = name;
    80004b56:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004b5a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004b5e:	0204a423          	sw	zero,40(s1)
}
    80004b62:	60e2                	ld	ra,24(sp)
    80004b64:	6442                	ld	s0,16(sp)
    80004b66:	64a2                	ld	s1,8(sp)
    80004b68:	6902                	ld	s2,0(sp)
    80004b6a:	6105                	addi	sp,sp,32
    80004b6c:	8082                	ret

0000000080004b6e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004b6e:	1101                	addi	sp,sp,-32
    80004b70:	ec06                	sd	ra,24(sp)
    80004b72:	e822                	sd	s0,16(sp)
    80004b74:	e426                	sd	s1,8(sp)
    80004b76:	e04a                	sd	s2,0(sp)
    80004b78:	1000                	addi	s0,sp,32
    80004b7a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004b7c:	00850913          	addi	s2,a0,8
    80004b80:	854a                	mv	a0,s2
    80004b82:	ffffc097          	auipc	ra,0xffffc
    80004b86:	054080e7          	jalr	84(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    80004b8a:	409c                	lw	a5,0(s1)
    80004b8c:	cb89                	beqz	a5,80004b9e <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004b8e:	85ca                	mv	a1,s2
    80004b90:	8526                	mv	a0,s1
    80004b92:	ffffe097          	auipc	ra,0xffffe
    80004b96:	860080e7          	jalr	-1952(ra) # 800023f2 <sleep>
  while (lk->locked) {
    80004b9a:	409c                	lw	a5,0(s1)
    80004b9c:	fbed                	bnez	a5,80004b8e <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004b9e:	4785                	li	a5,1
    80004ba0:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004ba2:	ffffd097          	auipc	ra,0xffffd
    80004ba6:	e0a080e7          	jalr	-502(ra) # 800019ac <myproc>
    80004baa:	591c                	lw	a5,48(a0)
    80004bac:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004bae:	854a                	mv	a0,s2
    80004bb0:	ffffc097          	auipc	ra,0xffffc
    80004bb4:	0da080e7          	jalr	218(ra) # 80000c8a <release>
}
    80004bb8:	60e2                	ld	ra,24(sp)
    80004bba:	6442                	ld	s0,16(sp)
    80004bbc:	64a2                	ld	s1,8(sp)
    80004bbe:	6902                	ld	s2,0(sp)
    80004bc0:	6105                	addi	sp,sp,32
    80004bc2:	8082                	ret

0000000080004bc4 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004bc4:	1101                	addi	sp,sp,-32
    80004bc6:	ec06                	sd	ra,24(sp)
    80004bc8:	e822                	sd	s0,16(sp)
    80004bca:	e426                	sd	s1,8(sp)
    80004bcc:	e04a                	sd	s2,0(sp)
    80004bce:	1000                	addi	s0,sp,32
    80004bd0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004bd2:	00850913          	addi	s2,a0,8
    80004bd6:	854a                	mv	a0,s2
    80004bd8:	ffffc097          	auipc	ra,0xffffc
    80004bdc:	ffe080e7          	jalr	-2(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    80004be0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004be4:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004be8:	8526                	mv	a0,s1
    80004bea:	ffffe097          	auipc	ra,0xffffe
    80004bee:	9c4080e7          	jalr	-1596(ra) # 800025ae <wakeup>
  release(&lk->lk);
    80004bf2:	854a                	mv	a0,s2
    80004bf4:	ffffc097          	auipc	ra,0xffffc
    80004bf8:	096080e7          	jalr	150(ra) # 80000c8a <release>
}
    80004bfc:	60e2                	ld	ra,24(sp)
    80004bfe:	6442                	ld	s0,16(sp)
    80004c00:	64a2                	ld	s1,8(sp)
    80004c02:	6902                	ld	s2,0(sp)
    80004c04:	6105                	addi	sp,sp,32
    80004c06:	8082                	ret

0000000080004c08 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004c08:	7179                	addi	sp,sp,-48
    80004c0a:	f406                	sd	ra,40(sp)
    80004c0c:	f022                	sd	s0,32(sp)
    80004c0e:	ec26                	sd	s1,24(sp)
    80004c10:	e84a                	sd	s2,16(sp)
    80004c12:	e44e                	sd	s3,8(sp)
    80004c14:	1800                	addi	s0,sp,48
    80004c16:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004c18:	00850913          	addi	s2,a0,8
    80004c1c:	854a                	mv	a0,s2
    80004c1e:	ffffc097          	auipc	ra,0xffffc
    80004c22:	fb8080e7          	jalr	-72(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004c26:	409c                	lw	a5,0(s1)
    80004c28:	ef99                	bnez	a5,80004c46 <holdingsleep+0x3e>
    80004c2a:	4481                	li	s1,0
  release(&lk->lk);
    80004c2c:	854a                	mv	a0,s2
    80004c2e:	ffffc097          	auipc	ra,0xffffc
    80004c32:	05c080e7          	jalr	92(ra) # 80000c8a <release>
  return r;
}
    80004c36:	8526                	mv	a0,s1
    80004c38:	70a2                	ld	ra,40(sp)
    80004c3a:	7402                	ld	s0,32(sp)
    80004c3c:	64e2                	ld	s1,24(sp)
    80004c3e:	6942                	ld	s2,16(sp)
    80004c40:	69a2                	ld	s3,8(sp)
    80004c42:	6145                	addi	sp,sp,48
    80004c44:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004c46:	0284a983          	lw	s3,40(s1)
    80004c4a:	ffffd097          	auipc	ra,0xffffd
    80004c4e:	d62080e7          	jalr	-670(ra) # 800019ac <myproc>
    80004c52:	5904                	lw	s1,48(a0)
    80004c54:	413484b3          	sub	s1,s1,s3
    80004c58:	0014b493          	seqz	s1,s1
    80004c5c:	bfc1                	j	80004c2c <holdingsleep+0x24>

0000000080004c5e <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004c5e:	1141                	addi	sp,sp,-16
    80004c60:	e406                	sd	ra,8(sp)
    80004c62:	e022                	sd	s0,0(sp)
    80004c64:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004c66:	00004597          	auipc	a1,0x4
    80004c6a:	b7258593          	addi	a1,a1,-1166 # 800087d8 <syscallnum+0x1f8>
    80004c6e:	0001e517          	auipc	a0,0x1e
    80004c72:	03a50513          	addi	a0,a0,58 # 80022ca8 <ftable>
    80004c76:	ffffc097          	auipc	ra,0xffffc
    80004c7a:	ed0080e7          	jalr	-304(ra) # 80000b46 <initlock>
}
    80004c7e:	60a2                	ld	ra,8(sp)
    80004c80:	6402                	ld	s0,0(sp)
    80004c82:	0141                	addi	sp,sp,16
    80004c84:	8082                	ret

0000000080004c86 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004c86:	1101                	addi	sp,sp,-32
    80004c88:	ec06                	sd	ra,24(sp)
    80004c8a:	e822                	sd	s0,16(sp)
    80004c8c:	e426                	sd	s1,8(sp)
    80004c8e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004c90:	0001e517          	auipc	a0,0x1e
    80004c94:	01850513          	addi	a0,a0,24 # 80022ca8 <ftable>
    80004c98:	ffffc097          	auipc	ra,0xffffc
    80004c9c:	f3e080e7          	jalr	-194(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004ca0:	0001e497          	auipc	s1,0x1e
    80004ca4:	02048493          	addi	s1,s1,32 # 80022cc0 <ftable+0x18>
    80004ca8:	0001f717          	auipc	a4,0x1f
    80004cac:	fb870713          	addi	a4,a4,-72 # 80023c60 <disk>
    if(f->ref == 0){
    80004cb0:	40dc                	lw	a5,4(s1)
    80004cb2:	cf99                	beqz	a5,80004cd0 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004cb4:	02848493          	addi	s1,s1,40
    80004cb8:	fee49ce3          	bne	s1,a4,80004cb0 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004cbc:	0001e517          	auipc	a0,0x1e
    80004cc0:	fec50513          	addi	a0,a0,-20 # 80022ca8 <ftable>
    80004cc4:	ffffc097          	auipc	ra,0xffffc
    80004cc8:	fc6080e7          	jalr	-58(ra) # 80000c8a <release>
  return 0;
    80004ccc:	4481                	li	s1,0
    80004cce:	a819                	j	80004ce4 <filealloc+0x5e>
      f->ref = 1;
    80004cd0:	4785                	li	a5,1
    80004cd2:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004cd4:	0001e517          	auipc	a0,0x1e
    80004cd8:	fd450513          	addi	a0,a0,-44 # 80022ca8 <ftable>
    80004cdc:	ffffc097          	auipc	ra,0xffffc
    80004ce0:	fae080e7          	jalr	-82(ra) # 80000c8a <release>
}
    80004ce4:	8526                	mv	a0,s1
    80004ce6:	60e2                	ld	ra,24(sp)
    80004ce8:	6442                	ld	s0,16(sp)
    80004cea:	64a2                	ld	s1,8(sp)
    80004cec:	6105                	addi	sp,sp,32
    80004cee:	8082                	ret

0000000080004cf0 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004cf0:	1101                	addi	sp,sp,-32
    80004cf2:	ec06                	sd	ra,24(sp)
    80004cf4:	e822                	sd	s0,16(sp)
    80004cf6:	e426                	sd	s1,8(sp)
    80004cf8:	1000                	addi	s0,sp,32
    80004cfa:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004cfc:	0001e517          	auipc	a0,0x1e
    80004d00:	fac50513          	addi	a0,a0,-84 # 80022ca8 <ftable>
    80004d04:	ffffc097          	auipc	ra,0xffffc
    80004d08:	ed2080e7          	jalr	-302(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004d0c:	40dc                	lw	a5,4(s1)
    80004d0e:	02f05263          	blez	a5,80004d32 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004d12:	2785                	addiw	a5,a5,1
    80004d14:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004d16:	0001e517          	auipc	a0,0x1e
    80004d1a:	f9250513          	addi	a0,a0,-110 # 80022ca8 <ftable>
    80004d1e:	ffffc097          	auipc	ra,0xffffc
    80004d22:	f6c080e7          	jalr	-148(ra) # 80000c8a <release>
  return f;
}
    80004d26:	8526                	mv	a0,s1
    80004d28:	60e2                	ld	ra,24(sp)
    80004d2a:	6442                	ld	s0,16(sp)
    80004d2c:	64a2                	ld	s1,8(sp)
    80004d2e:	6105                	addi	sp,sp,32
    80004d30:	8082                	ret
    panic("filedup");
    80004d32:	00004517          	auipc	a0,0x4
    80004d36:	aae50513          	addi	a0,a0,-1362 # 800087e0 <syscallnum+0x200>
    80004d3a:	ffffc097          	auipc	ra,0xffffc
    80004d3e:	804080e7          	jalr	-2044(ra) # 8000053e <panic>

0000000080004d42 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004d42:	7139                	addi	sp,sp,-64
    80004d44:	fc06                	sd	ra,56(sp)
    80004d46:	f822                	sd	s0,48(sp)
    80004d48:	f426                	sd	s1,40(sp)
    80004d4a:	f04a                	sd	s2,32(sp)
    80004d4c:	ec4e                	sd	s3,24(sp)
    80004d4e:	e852                	sd	s4,16(sp)
    80004d50:	e456                	sd	s5,8(sp)
    80004d52:	0080                	addi	s0,sp,64
    80004d54:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004d56:	0001e517          	auipc	a0,0x1e
    80004d5a:	f5250513          	addi	a0,a0,-174 # 80022ca8 <ftable>
    80004d5e:	ffffc097          	auipc	ra,0xffffc
    80004d62:	e78080e7          	jalr	-392(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004d66:	40dc                	lw	a5,4(s1)
    80004d68:	06f05163          	blez	a5,80004dca <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004d6c:	37fd                	addiw	a5,a5,-1
    80004d6e:	0007871b          	sext.w	a4,a5
    80004d72:	c0dc                	sw	a5,4(s1)
    80004d74:	06e04363          	bgtz	a4,80004dda <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004d78:	0004a903          	lw	s2,0(s1)
    80004d7c:	0094ca83          	lbu	s5,9(s1)
    80004d80:	0104ba03          	ld	s4,16(s1)
    80004d84:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004d88:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004d8c:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004d90:	0001e517          	auipc	a0,0x1e
    80004d94:	f1850513          	addi	a0,a0,-232 # 80022ca8 <ftable>
    80004d98:	ffffc097          	auipc	ra,0xffffc
    80004d9c:	ef2080e7          	jalr	-270(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    80004da0:	4785                	li	a5,1
    80004da2:	04f90d63          	beq	s2,a5,80004dfc <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004da6:	3979                	addiw	s2,s2,-2
    80004da8:	4785                	li	a5,1
    80004daa:	0527e063          	bltu	a5,s2,80004dea <fileclose+0xa8>
    begin_op();
    80004dae:	00000097          	auipc	ra,0x0
    80004db2:	ac8080e7          	jalr	-1336(ra) # 80004876 <begin_op>
    iput(ff.ip);
    80004db6:	854e                	mv	a0,s3
    80004db8:	fffff097          	auipc	ra,0xfffff
    80004dbc:	2b6080e7          	jalr	694(ra) # 8000406e <iput>
    end_op();
    80004dc0:	00000097          	auipc	ra,0x0
    80004dc4:	b36080e7          	jalr	-1226(ra) # 800048f6 <end_op>
    80004dc8:	a00d                	j	80004dea <fileclose+0xa8>
    panic("fileclose");
    80004dca:	00004517          	auipc	a0,0x4
    80004dce:	a1e50513          	addi	a0,a0,-1506 # 800087e8 <syscallnum+0x208>
    80004dd2:	ffffb097          	auipc	ra,0xffffb
    80004dd6:	76c080e7          	jalr	1900(ra) # 8000053e <panic>
    release(&ftable.lock);
    80004dda:	0001e517          	auipc	a0,0x1e
    80004dde:	ece50513          	addi	a0,a0,-306 # 80022ca8 <ftable>
    80004de2:	ffffc097          	auipc	ra,0xffffc
    80004de6:	ea8080e7          	jalr	-344(ra) # 80000c8a <release>
  }
}
    80004dea:	70e2                	ld	ra,56(sp)
    80004dec:	7442                	ld	s0,48(sp)
    80004dee:	74a2                	ld	s1,40(sp)
    80004df0:	7902                	ld	s2,32(sp)
    80004df2:	69e2                	ld	s3,24(sp)
    80004df4:	6a42                	ld	s4,16(sp)
    80004df6:	6aa2                	ld	s5,8(sp)
    80004df8:	6121                	addi	sp,sp,64
    80004dfa:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004dfc:	85d6                	mv	a1,s5
    80004dfe:	8552                	mv	a0,s4
    80004e00:	00000097          	auipc	ra,0x0
    80004e04:	34c080e7          	jalr	844(ra) # 8000514c <pipeclose>
    80004e08:	b7cd                	j	80004dea <fileclose+0xa8>

0000000080004e0a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004e0a:	715d                	addi	sp,sp,-80
    80004e0c:	e486                	sd	ra,72(sp)
    80004e0e:	e0a2                	sd	s0,64(sp)
    80004e10:	fc26                	sd	s1,56(sp)
    80004e12:	f84a                	sd	s2,48(sp)
    80004e14:	f44e                	sd	s3,40(sp)
    80004e16:	0880                	addi	s0,sp,80
    80004e18:	84aa                	mv	s1,a0
    80004e1a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004e1c:	ffffd097          	auipc	ra,0xffffd
    80004e20:	b90080e7          	jalr	-1136(ra) # 800019ac <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004e24:	409c                	lw	a5,0(s1)
    80004e26:	37f9                	addiw	a5,a5,-2
    80004e28:	4705                	li	a4,1
    80004e2a:	04f76763          	bltu	a4,a5,80004e78 <filestat+0x6e>
    80004e2e:	892a                	mv	s2,a0
    ilock(f->ip);
    80004e30:	6c88                	ld	a0,24(s1)
    80004e32:	fffff097          	auipc	ra,0xfffff
    80004e36:	082080e7          	jalr	130(ra) # 80003eb4 <ilock>
    stati(f->ip, &st);
    80004e3a:	fb840593          	addi	a1,s0,-72
    80004e3e:	6c88                	ld	a0,24(s1)
    80004e40:	fffff097          	auipc	ra,0xfffff
    80004e44:	2fe080e7          	jalr	766(ra) # 8000413e <stati>
    iunlock(f->ip);
    80004e48:	6c88                	ld	a0,24(s1)
    80004e4a:	fffff097          	auipc	ra,0xfffff
    80004e4e:	12c080e7          	jalr	300(ra) # 80003f76 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004e52:	46e1                	li	a3,24
    80004e54:	fb840613          	addi	a2,s0,-72
    80004e58:	85ce                	mv	a1,s3
    80004e5a:	05093503          	ld	a0,80(s2)
    80004e5e:	ffffd097          	auipc	ra,0xffffd
    80004e62:	80a080e7          	jalr	-2038(ra) # 80001668 <copyout>
    80004e66:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004e6a:	60a6                	ld	ra,72(sp)
    80004e6c:	6406                	ld	s0,64(sp)
    80004e6e:	74e2                	ld	s1,56(sp)
    80004e70:	7942                	ld	s2,48(sp)
    80004e72:	79a2                	ld	s3,40(sp)
    80004e74:	6161                	addi	sp,sp,80
    80004e76:	8082                	ret
  return -1;
    80004e78:	557d                	li	a0,-1
    80004e7a:	bfc5                	j	80004e6a <filestat+0x60>

0000000080004e7c <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004e7c:	7179                	addi	sp,sp,-48
    80004e7e:	f406                	sd	ra,40(sp)
    80004e80:	f022                	sd	s0,32(sp)
    80004e82:	ec26                	sd	s1,24(sp)
    80004e84:	e84a                	sd	s2,16(sp)
    80004e86:	e44e                	sd	s3,8(sp)
    80004e88:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004e8a:	00854783          	lbu	a5,8(a0)
    80004e8e:	c3d5                	beqz	a5,80004f32 <fileread+0xb6>
    80004e90:	84aa                	mv	s1,a0
    80004e92:	89ae                	mv	s3,a1
    80004e94:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004e96:	411c                	lw	a5,0(a0)
    80004e98:	4705                	li	a4,1
    80004e9a:	04e78963          	beq	a5,a4,80004eec <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004e9e:	470d                	li	a4,3
    80004ea0:	04e78d63          	beq	a5,a4,80004efa <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004ea4:	4709                	li	a4,2
    80004ea6:	06e79e63          	bne	a5,a4,80004f22 <fileread+0xa6>
    ilock(f->ip);
    80004eaa:	6d08                	ld	a0,24(a0)
    80004eac:	fffff097          	auipc	ra,0xfffff
    80004eb0:	008080e7          	jalr	8(ra) # 80003eb4 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004eb4:	874a                	mv	a4,s2
    80004eb6:	5094                	lw	a3,32(s1)
    80004eb8:	864e                	mv	a2,s3
    80004eba:	4585                	li	a1,1
    80004ebc:	6c88                	ld	a0,24(s1)
    80004ebe:	fffff097          	auipc	ra,0xfffff
    80004ec2:	2aa080e7          	jalr	682(ra) # 80004168 <readi>
    80004ec6:	892a                	mv	s2,a0
    80004ec8:	00a05563          	blez	a0,80004ed2 <fileread+0x56>
      f->off += r;
    80004ecc:	509c                	lw	a5,32(s1)
    80004ece:	9fa9                	addw	a5,a5,a0
    80004ed0:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004ed2:	6c88                	ld	a0,24(s1)
    80004ed4:	fffff097          	auipc	ra,0xfffff
    80004ed8:	0a2080e7          	jalr	162(ra) # 80003f76 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004edc:	854a                	mv	a0,s2
    80004ede:	70a2                	ld	ra,40(sp)
    80004ee0:	7402                	ld	s0,32(sp)
    80004ee2:	64e2                	ld	s1,24(sp)
    80004ee4:	6942                	ld	s2,16(sp)
    80004ee6:	69a2                	ld	s3,8(sp)
    80004ee8:	6145                	addi	sp,sp,48
    80004eea:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004eec:	6908                	ld	a0,16(a0)
    80004eee:	00000097          	auipc	ra,0x0
    80004ef2:	3c6080e7          	jalr	966(ra) # 800052b4 <piperead>
    80004ef6:	892a                	mv	s2,a0
    80004ef8:	b7d5                	j	80004edc <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004efa:	02451783          	lh	a5,36(a0)
    80004efe:	03079693          	slli	a3,a5,0x30
    80004f02:	92c1                	srli	a3,a3,0x30
    80004f04:	4725                	li	a4,9
    80004f06:	02d76863          	bltu	a4,a3,80004f36 <fileread+0xba>
    80004f0a:	0792                	slli	a5,a5,0x4
    80004f0c:	0001e717          	auipc	a4,0x1e
    80004f10:	cfc70713          	addi	a4,a4,-772 # 80022c08 <devsw>
    80004f14:	97ba                	add	a5,a5,a4
    80004f16:	639c                	ld	a5,0(a5)
    80004f18:	c38d                	beqz	a5,80004f3a <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004f1a:	4505                	li	a0,1
    80004f1c:	9782                	jalr	a5
    80004f1e:	892a                	mv	s2,a0
    80004f20:	bf75                	j	80004edc <fileread+0x60>
    panic("fileread");
    80004f22:	00004517          	auipc	a0,0x4
    80004f26:	8d650513          	addi	a0,a0,-1834 # 800087f8 <syscallnum+0x218>
    80004f2a:	ffffb097          	auipc	ra,0xffffb
    80004f2e:	614080e7          	jalr	1556(ra) # 8000053e <panic>
    return -1;
    80004f32:	597d                	li	s2,-1
    80004f34:	b765                	j	80004edc <fileread+0x60>
      return -1;
    80004f36:	597d                	li	s2,-1
    80004f38:	b755                	j	80004edc <fileread+0x60>
    80004f3a:	597d                	li	s2,-1
    80004f3c:	b745                	j	80004edc <fileread+0x60>

0000000080004f3e <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004f3e:	715d                	addi	sp,sp,-80
    80004f40:	e486                	sd	ra,72(sp)
    80004f42:	e0a2                	sd	s0,64(sp)
    80004f44:	fc26                	sd	s1,56(sp)
    80004f46:	f84a                	sd	s2,48(sp)
    80004f48:	f44e                	sd	s3,40(sp)
    80004f4a:	f052                	sd	s4,32(sp)
    80004f4c:	ec56                	sd	s5,24(sp)
    80004f4e:	e85a                	sd	s6,16(sp)
    80004f50:	e45e                	sd	s7,8(sp)
    80004f52:	e062                	sd	s8,0(sp)
    80004f54:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004f56:	00954783          	lbu	a5,9(a0)
    80004f5a:	10078663          	beqz	a5,80005066 <filewrite+0x128>
    80004f5e:	892a                	mv	s2,a0
    80004f60:	8aae                	mv	s5,a1
    80004f62:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004f64:	411c                	lw	a5,0(a0)
    80004f66:	4705                	li	a4,1
    80004f68:	02e78263          	beq	a5,a4,80004f8c <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004f6c:	470d                	li	a4,3
    80004f6e:	02e78663          	beq	a5,a4,80004f9a <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004f72:	4709                	li	a4,2
    80004f74:	0ee79163          	bne	a5,a4,80005056 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004f78:	0ac05d63          	blez	a2,80005032 <filewrite+0xf4>
    int i = 0;
    80004f7c:	4981                	li	s3,0
    80004f7e:	6b05                	lui	s6,0x1
    80004f80:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004f84:	6b85                	lui	s7,0x1
    80004f86:	c00b8b9b          	addiw	s7,s7,-1024
    80004f8a:	a861                	j	80005022 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004f8c:	6908                	ld	a0,16(a0)
    80004f8e:	00000097          	auipc	ra,0x0
    80004f92:	22e080e7          	jalr	558(ra) # 800051bc <pipewrite>
    80004f96:	8a2a                	mv	s4,a0
    80004f98:	a045                	j	80005038 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004f9a:	02451783          	lh	a5,36(a0)
    80004f9e:	03079693          	slli	a3,a5,0x30
    80004fa2:	92c1                	srli	a3,a3,0x30
    80004fa4:	4725                	li	a4,9
    80004fa6:	0cd76263          	bltu	a4,a3,8000506a <filewrite+0x12c>
    80004faa:	0792                	slli	a5,a5,0x4
    80004fac:	0001e717          	auipc	a4,0x1e
    80004fb0:	c5c70713          	addi	a4,a4,-932 # 80022c08 <devsw>
    80004fb4:	97ba                	add	a5,a5,a4
    80004fb6:	679c                	ld	a5,8(a5)
    80004fb8:	cbdd                	beqz	a5,8000506e <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004fba:	4505                	li	a0,1
    80004fbc:	9782                	jalr	a5
    80004fbe:	8a2a                	mv	s4,a0
    80004fc0:	a8a5                	j	80005038 <filewrite+0xfa>
    80004fc2:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004fc6:	00000097          	auipc	ra,0x0
    80004fca:	8b0080e7          	jalr	-1872(ra) # 80004876 <begin_op>
      ilock(f->ip);
    80004fce:	01893503          	ld	a0,24(s2)
    80004fd2:	fffff097          	auipc	ra,0xfffff
    80004fd6:	ee2080e7          	jalr	-286(ra) # 80003eb4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004fda:	8762                	mv	a4,s8
    80004fdc:	02092683          	lw	a3,32(s2)
    80004fe0:	01598633          	add	a2,s3,s5
    80004fe4:	4585                	li	a1,1
    80004fe6:	01893503          	ld	a0,24(s2)
    80004fea:	fffff097          	auipc	ra,0xfffff
    80004fee:	276080e7          	jalr	630(ra) # 80004260 <writei>
    80004ff2:	84aa                	mv	s1,a0
    80004ff4:	00a05763          	blez	a0,80005002 <filewrite+0xc4>
        f->off += r;
    80004ff8:	02092783          	lw	a5,32(s2)
    80004ffc:	9fa9                	addw	a5,a5,a0
    80004ffe:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80005002:	01893503          	ld	a0,24(s2)
    80005006:	fffff097          	auipc	ra,0xfffff
    8000500a:	f70080e7          	jalr	-144(ra) # 80003f76 <iunlock>
      end_op();
    8000500e:	00000097          	auipc	ra,0x0
    80005012:	8e8080e7          	jalr	-1816(ra) # 800048f6 <end_op>

      if(r != n1){
    80005016:	009c1f63          	bne	s8,s1,80005034 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    8000501a:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000501e:	0149db63          	bge	s3,s4,80005034 <filewrite+0xf6>
      int n1 = n - i;
    80005022:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80005026:	84be                	mv	s1,a5
    80005028:	2781                	sext.w	a5,a5
    8000502a:	f8fb5ce3          	bge	s6,a5,80004fc2 <filewrite+0x84>
    8000502e:	84de                	mv	s1,s7
    80005030:	bf49                	j	80004fc2 <filewrite+0x84>
    int i = 0;
    80005032:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80005034:	013a1f63          	bne	s4,s3,80005052 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80005038:	8552                	mv	a0,s4
    8000503a:	60a6                	ld	ra,72(sp)
    8000503c:	6406                	ld	s0,64(sp)
    8000503e:	74e2                	ld	s1,56(sp)
    80005040:	7942                	ld	s2,48(sp)
    80005042:	79a2                	ld	s3,40(sp)
    80005044:	7a02                	ld	s4,32(sp)
    80005046:	6ae2                	ld	s5,24(sp)
    80005048:	6b42                	ld	s6,16(sp)
    8000504a:	6ba2                	ld	s7,8(sp)
    8000504c:	6c02                	ld	s8,0(sp)
    8000504e:	6161                	addi	sp,sp,80
    80005050:	8082                	ret
    ret = (i == n ? n : -1);
    80005052:	5a7d                	li	s4,-1
    80005054:	b7d5                	j	80005038 <filewrite+0xfa>
    panic("filewrite");
    80005056:	00003517          	auipc	a0,0x3
    8000505a:	7b250513          	addi	a0,a0,1970 # 80008808 <syscallnum+0x228>
    8000505e:	ffffb097          	auipc	ra,0xffffb
    80005062:	4e0080e7          	jalr	1248(ra) # 8000053e <panic>
    return -1;
    80005066:	5a7d                	li	s4,-1
    80005068:	bfc1                	j	80005038 <filewrite+0xfa>
      return -1;
    8000506a:	5a7d                	li	s4,-1
    8000506c:	b7f1                	j	80005038 <filewrite+0xfa>
    8000506e:	5a7d                	li	s4,-1
    80005070:	b7e1                	j	80005038 <filewrite+0xfa>

0000000080005072 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80005072:	7179                	addi	sp,sp,-48
    80005074:	f406                	sd	ra,40(sp)
    80005076:	f022                	sd	s0,32(sp)
    80005078:	ec26                	sd	s1,24(sp)
    8000507a:	e84a                	sd	s2,16(sp)
    8000507c:	e44e                	sd	s3,8(sp)
    8000507e:	e052                	sd	s4,0(sp)
    80005080:	1800                	addi	s0,sp,48
    80005082:	84aa                	mv	s1,a0
    80005084:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005086:	0005b023          	sd	zero,0(a1)
    8000508a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000508e:	00000097          	auipc	ra,0x0
    80005092:	bf8080e7          	jalr	-1032(ra) # 80004c86 <filealloc>
    80005096:	e088                	sd	a0,0(s1)
    80005098:	c551                	beqz	a0,80005124 <pipealloc+0xb2>
    8000509a:	00000097          	auipc	ra,0x0
    8000509e:	bec080e7          	jalr	-1044(ra) # 80004c86 <filealloc>
    800050a2:	00aa3023          	sd	a0,0(s4)
    800050a6:	c92d                	beqz	a0,80005118 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800050a8:	ffffc097          	auipc	ra,0xffffc
    800050ac:	a3e080e7          	jalr	-1474(ra) # 80000ae6 <kalloc>
    800050b0:	892a                	mv	s2,a0
    800050b2:	c125                	beqz	a0,80005112 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800050b4:	4985                	li	s3,1
    800050b6:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800050ba:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800050be:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800050c2:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800050c6:	00003597          	auipc	a1,0x3
    800050ca:	34a58593          	addi	a1,a1,842 # 80008410 <digits+0x3d0>
    800050ce:	ffffc097          	auipc	ra,0xffffc
    800050d2:	a78080e7          	jalr	-1416(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    800050d6:	609c                	ld	a5,0(s1)
    800050d8:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800050dc:	609c                	ld	a5,0(s1)
    800050de:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800050e2:	609c                	ld	a5,0(s1)
    800050e4:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800050e8:	609c                	ld	a5,0(s1)
    800050ea:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800050ee:	000a3783          	ld	a5,0(s4)
    800050f2:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800050f6:	000a3783          	ld	a5,0(s4)
    800050fa:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800050fe:	000a3783          	ld	a5,0(s4)
    80005102:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005106:	000a3783          	ld	a5,0(s4)
    8000510a:	0127b823          	sd	s2,16(a5)
  return 0;
    8000510e:	4501                	li	a0,0
    80005110:	a025                	j	80005138 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005112:	6088                	ld	a0,0(s1)
    80005114:	e501                	bnez	a0,8000511c <pipealloc+0xaa>
    80005116:	a039                	j	80005124 <pipealloc+0xb2>
    80005118:	6088                	ld	a0,0(s1)
    8000511a:	c51d                	beqz	a0,80005148 <pipealloc+0xd6>
    fileclose(*f0);
    8000511c:	00000097          	auipc	ra,0x0
    80005120:	c26080e7          	jalr	-986(ra) # 80004d42 <fileclose>
  if(*f1)
    80005124:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005128:	557d                	li	a0,-1
  if(*f1)
    8000512a:	c799                	beqz	a5,80005138 <pipealloc+0xc6>
    fileclose(*f1);
    8000512c:	853e                	mv	a0,a5
    8000512e:	00000097          	auipc	ra,0x0
    80005132:	c14080e7          	jalr	-1004(ra) # 80004d42 <fileclose>
  return -1;
    80005136:	557d                	li	a0,-1
}
    80005138:	70a2                	ld	ra,40(sp)
    8000513a:	7402                	ld	s0,32(sp)
    8000513c:	64e2                	ld	s1,24(sp)
    8000513e:	6942                	ld	s2,16(sp)
    80005140:	69a2                	ld	s3,8(sp)
    80005142:	6a02                	ld	s4,0(sp)
    80005144:	6145                	addi	sp,sp,48
    80005146:	8082                	ret
  return -1;
    80005148:	557d                	li	a0,-1
    8000514a:	b7fd                	j	80005138 <pipealloc+0xc6>

000000008000514c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000514c:	1101                	addi	sp,sp,-32
    8000514e:	ec06                	sd	ra,24(sp)
    80005150:	e822                	sd	s0,16(sp)
    80005152:	e426                	sd	s1,8(sp)
    80005154:	e04a                	sd	s2,0(sp)
    80005156:	1000                	addi	s0,sp,32
    80005158:	84aa                	mv	s1,a0
    8000515a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000515c:	ffffc097          	auipc	ra,0xffffc
    80005160:	a7a080e7          	jalr	-1414(ra) # 80000bd6 <acquire>
  if(writable){
    80005164:	02090d63          	beqz	s2,8000519e <pipeclose+0x52>
    pi->writeopen = 0;
    80005168:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000516c:	21848513          	addi	a0,s1,536
    80005170:	ffffd097          	auipc	ra,0xffffd
    80005174:	43e080e7          	jalr	1086(ra) # 800025ae <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005178:	2204b783          	ld	a5,544(s1)
    8000517c:	eb95                	bnez	a5,800051b0 <pipeclose+0x64>
    release(&pi->lock);
    8000517e:	8526                	mv	a0,s1
    80005180:	ffffc097          	auipc	ra,0xffffc
    80005184:	b0a080e7          	jalr	-1270(ra) # 80000c8a <release>
    kfree((char*)pi);
    80005188:	8526                	mv	a0,s1
    8000518a:	ffffc097          	auipc	ra,0xffffc
    8000518e:	860080e7          	jalr	-1952(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    80005192:	60e2                	ld	ra,24(sp)
    80005194:	6442                	ld	s0,16(sp)
    80005196:	64a2                	ld	s1,8(sp)
    80005198:	6902                	ld	s2,0(sp)
    8000519a:	6105                	addi	sp,sp,32
    8000519c:	8082                	ret
    pi->readopen = 0;
    8000519e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800051a2:	21c48513          	addi	a0,s1,540
    800051a6:	ffffd097          	auipc	ra,0xffffd
    800051aa:	408080e7          	jalr	1032(ra) # 800025ae <wakeup>
    800051ae:	b7e9                	j	80005178 <pipeclose+0x2c>
    release(&pi->lock);
    800051b0:	8526                	mv	a0,s1
    800051b2:	ffffc097          	auipc	ra,0xffffc
    800051b6:	ad8080e7          	jalr	-1320(ra) # 80000c8a <release>
}
    800051ba:	bfe1                	j	80005192 <pipeclose+0x46>

00000000800051bc <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800051bc:	711d                	addi	sp,sp,-96
    800051be:	ec86                	sd	ra,88(sp)
    800051c0:	e8a2                	sd	s0,80(sp)
    800051c2:	e4a6                	sd	s1,72(sp)
    800051c4:	e0ca                	sd	s2,64(sp)
    800051c6:	fc4e                	sd	s3,56(sp)
    800051c8:	f852                	sd	s4,48(sp)
    800051ca:	f456                	sd	s5,40(sp)
    800051cc:	f05a                	sd	s6,32(sp)
    800051ce:	ec5e                	sd	s7,24(sp)
    800051d0:	e862                	sd	s8,16(sp)
    800051d2:	1080                	addi	s0,sp,96
    800051d4:	84aa                	mv	s1,a0
    800051d6:	8aae                	mv	s5,a1
    800051d8:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800051da:	ffffc097          	auipc	ra,0xffffc
    800051de:	7d2080e7          	jalr	2002(ra) # 800019ac <myproc>
    800051e2:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800051e4:	8526                	mv	a0,s1
    800051e6:	ffffc097          	auipc	ra,0xffffc
    800051ea:	9f0080e7          	jalr	-1552(ra) # 80000bd6 <acquire>
  while(i < n){
    800051ee:	0b405663          	blez	s4,8000529a <pipewrite+0xde>
  int i = 0;
    800051f2:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800051f4:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800051f6:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800051fa:	21c48b93          	addi	s7,s1,540
    800051fe:	a089                	j	80005240 <pipewrite+0x84>
      release(&pi->lock);
    80005200:	8526                	mv	a0,s1
    80005202:	ffffc097          	auipc	ra,0xffffc
    80005206:	a88080e7          	jalr	-1400(ra) # 80000c8a <release>
      return -1;
    8000520a:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000520c:	854a                	mv	a0,s2
    8000520e:	60e6                	ld	ra,88(sp)
    80005210:	6446                	ld	s0,80(sp)
    80005212:	64a6                	ld	s1,72(sp)
    80005214:	6906                	ld	s2,64(sp)
    80005216:	79e2                	ld	s3,56(sp)
    80005218:	7a42                	ld	s4,48(sp)
    8000521a:	7aa2                	ld	s5,40(sp)
    8000521c:	7b02                	ld	s6,32(sp)
    8000521e:	6be2                	ld	s7,24(sp)
    80005220:	6c42                	ld	s8,16(sp)
    80005222:	6125                	addi	sp,sp,96
    80005224:	8082                	ret
      wakeup(&pi->nread);
    80005226:	8562                	mv	a0,s8
    80005228:	ffffd097          	auipc	ra,0xffffd
    8000522c:	386080e7          	jalr	902(ra) # 800025ae <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005230:	85a6                	mv	a1,s1
    80005232:	855e                	mv	a0,s7
    80005234:	ffffd097          	auipc	ra,0xffffd
    80005238:	1be080e7          	jalr	446(ra) # 800023f2 <sleep>
  while(i < n){
    8000523c:	07495063          	bge	s2,s4,8000529c <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80005240:	2204a783          	lw	a5,544(s1)
    80005244:	dfd5                	beqz	a5,80005200 <pipewrite+0x44>
    80005246:	854e                	mv	a0,s3
    80005248:	ffffd097          	auipc	ra,0xffffd
    8000524c:	5d0080e7          	jalr	1488(ra) # 80002818 <killed>
    80005250:	f945                	bnez	a0,80005200 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005252:	2184a783          	lw	a5,536(s1)
    80005256:	21c4a703          	lw	a4,540(s1)
    8000525a:	2007879b          	addiw	a5,a5,512
    8000525e:	fcf704e3          	beq	a4,a5,80005226 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005262:	4685                	li	a3,1
    80005264:	01590633          	add	a2,s2,s5
    80005268:	faf40593          	addi	a1,s0,-81
    8000526c:	0509b503          	ld	a0,80(s3)
    80005270:	ffffc097          	auipc	ra,0xffffc
    80005274:	484080e7          	jalr	1156(ra) # 800016f4 <copyin>
    80005278:	03650263          	beq	a0,s6,8000529c <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000527c:	21c4a783          	lw	a5,540(s1)
    80005280:	0017871b          	addiw	a4,a5,1
    80005284:	20e4ae23          	sw	a4,540(s1)
    80005288:	1ff7f793          	andi	a5,a5,511
    8000528c:	97a6                	add	a5,a5,s1
    8000528e:	faf44703          	lbu	a4,-81(s0)
    80005292:	00e78c23          	sb	a4,24(a5)
      i++;
    80005296:	2905                	addiw	s2,s2,1
    80005298:	b755                	j	8000523c <pipewrite+0x80>
  int i = 0;
    8000529a:	4901                	li	s2,0
  wakeup(&pi->nread);
    8000529c:	21848513          	addi	a0,s1,536
    800052a0:	ffffd097          	auipc	ra,0xffffd
    800052a4:	30e080e7          	jalr	782(ra) # 800025ae <wakeup>
  release(&pi->lock);
    800052a8:	8526                	mv	a0,s1
    800052aa:	ffffc097          	auipc	ra,0xffffc
    800052ae:	9e0080e7          	jalr	-1568(ra) # 80000c8a <release>
  return i;
    800052b2:	bfa9                	j	8000520c <pipewrite+0x50>

00000000800052b4 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800052b4:	715d                	addi	sp,sp,-80
    800052b6:	e486                	sd	ra,72(sp)
    800052b8:	e0a2                	sd	s0,64(sp)
    800052ba:	fc26                	sd	s1,56(sp)
    800052bc:	f84a                	sd	s2,48(sp)
    800052be:	f44e                	sd	s3,40(sp)
    800052c0:	f052                	sd	s4,32(sp)
    800052c2:	ec56                	sd	s5,24(sp)
    800052c4:	e85a                	sd	s6,16(sp)
    800052c6:	0880                	addi	s0,sp,80
    800052c8:	84aa                	mv	s1,a0
    800052ca:	892e                	mv	s2,a1
    800052cc:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800052ce:	ffffc097          	auipc	ra,0xffffc
    800052d2:	6de080e7          	jalr	1758(ra) # 800019ac <myproc>
    800052d6:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800052d8:	8526                	mv	a0,s1
    800052da:	ffffc097          	auipc	ra,0xffffc
    800052de:	8fc080e7          	jalr	-1796(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800052e2:	2184a703          	lw	a4,536(s1)
    800052e6:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800052ea:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800052ee:	02f71763          	bne	a4,a5,8000531c <piperead+0x68>
    800052f2:	2244a783          	lw	a5,548(s1)
    800052f6:	c39d                	beqz	a5,8000531c <piperead+0x68>
    if(killed(pr)){
    800052f8:	8552                	mv	a0,s4
    800052fa:	ffffd097          	auipc	ra,0xffffd
    800052fe:	51e080e7          	jalr	1310(ra) # 80002818 <killed>
    80005302:	e941                	bnez	a0,80005392 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005304:	85a6                	mv	a1,s1
    80005306:	854e                	mv	a0,s3
    80005308:	ffffd097          	auipc	ra,0xffffd
    8000530c:	0ea080e7          	jalr	234(ra) # 800023f2 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005310:	2184a703          	lw	a4,536(s1)
    80005314:	21c4a783          	lw	a5,540(s1)
    80005318:	fcf70de3          	beq	a4,a5,800052f2 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000531c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000531e:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005320:	05505363          	blez	s5,80005366 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80005324:	2184a783          	lw	a5,536(s1)
    80005328:	21c4a703          	lw	a4,540(s1)
    8000532c:	02f70d63          	beq	a4,a5,80005366 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005330:	0017871b          	addiw	a4,a5,1
    80005334:	20e4ac23          	sw	a4,536(s1)
    80005338:	1ff7f793          	andi	a5,a5,511
    8000533c:	97a6                	add	a5,a5,s1
    8000533e:	0187c783          	lbu	a5,24(a5)
    80005342:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005346:	4685                	li	a3,1
    80005348:	fbf40613          	addi	a2,s0,-65
    8000534c:	85ca                	mv	a1,s2
    8000534e:	050a3503          	ld	a0,80(s4)
    80005352:	ffffc097          	auipc	ra,0xffffc
    80005356:	316080e7          	jalr	790(ra) # 80001668 <copyout>
    8000535a:	01650663          	beq	a0,s6,80005366 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000535e:	2985                	addiw	s3,s3,1
    80005360:	0905                	addi	s2,s2,1
    80005362:	fd3a91e3          	bne	s5,s3,80005324 <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005366:	21c48513          	addi	a0,s1,540
    8000536a:	ffffd097          	auipc	ra,0xffffd
    8000536e:	244080e7          	jalr	580(ra) # 800025ae <wakeup>
  release(&pi->lock);
    80005372:	8526                	mv	a0,s1
    80005374:	ffffc097          	auipc	ra,0xffffc
    80005378:	916080e7          	jalr	-1770(ra) # 80000c8a <release>
  return i;
}
    8000537c:	854e                	mv	a0,s3
    8000537e:	60a6                	ld	ra,72(sp)
    80005380:	6406                	ld	s0,64(sp)
    80005382:	74e2                	ld	s1,56(sp)
    80005384:	7942                	ld	s2,48(sp)
    80005386:	79a2                	ld	s3,40(sp)
    80005388:	7a02                	ld	s4,32(sp)
    8000538a:	6ae2                	ld	s5,24(sp)
    8000538c:	6b42                	ld	s6,16(sp)
    8000538e:	6161                	addi	sp,sp,80
    80005390:	8082                	ret
      release(&pi->lock);
    80005392:	8526                	mv	a0,s1
    80005394:	ffffc097          	auipc	ra,0xffffc
    80005398:	8f6080e7          	jalr	-1802(ra) # 80000c8a <release>
      return -1;
    8000539c:	59fd                	li	s3,-1
    8000539e:	bff9                	j	8000537c <piperead+0xc8>

00000000800053a0 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800053a0:	1141                	addi	sp,sp,-16
    800053a2:	e422                	sd	s0,8(sp)
    800053a4:	0800                	addi	s0,sp,16
    800053a6:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800053a8:	8905                	andi	a0,a0,1
    800053aa:	c111                	beqz	a0,800053ae <flags2perm+0xe>
      perm = PTE_X;
    800053ac:	4521                	li	a0,8
    if(flags & 0x2)
    800053ae:	8b89                	andi	a5,a5,2
    800053b0:	c399                	beqz	a5,800053b6 <flags2perm+0x16>
      perm |= PTE_W;
    800053b2:	00456513          	ori	a0,a0,4
    return perm;
}
    800053b6:	6422                	ld	s0,8(sp)
    800053b8:	0141                	addi	sp,sp,16
    800053ba:	8082                	ret

00000000800053bc <exec>:

int
exec(char *path, char **argv)
{
    800053bc:	de010113          	addi	sp,sp,-544
    800053c0:	20113c23          	sd	ra,536(sp)
    800053c4:	20813823          	sd	s0,528(sp)
    800053c8:	20913423          	sd	s1,520(sp)
    800053cc:	21213023          	sd	s2,512(sp)
    800053d0:	ffce                	sd	s3,504(sp)
    800053d2:	fbd2                	sd	s4,496(sp)
    800053d4:	f7d6                	sd	s5,488(sp)
    800053d6:	f3da                	sd	s6,480(sp)
    800053d8:	efde                	sd	s7,472(sp)
    800053da:	ebe2                	sd	s8,464(sp)
    800053dc:	e7e6                	sd	s9,456(sp)
    800053de:	e3ea                	sd	s10,448(sp)
    800053e0:	ff6e                	sd	s11,440(sp)
    800053e2:	1400                	addi	s0,sp,544
    800053e4:	892a                	mv	s2,a0
    800053e6:	dea43423          	sd	a0,-536(s0)
    800053ea:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800053ee:	ffffc097          	auipc	ra,0xffffc
    800053f2:	5be080e7          	jalr	1470(ra) # 800019ac <myproc>
    800053f6:	84aa                	mv	s1,a0

  begin_op();
    800053f8:	fffff097          	auipc	ra,0xfffff
    800053fc:	47e080e7          	jalr	1150(ra) # 80004876 <begin_op>

  if((ip = namei(path)) == 0){
    80005400:	854a                	mv	a0,s2
    80005402:	fffff097          	auipc	ra,0xfffff
    80005406:	258080e7          	jalr	600(ra) # 8000465a <namei>
    8000540a:	c93d                	beqz	a0,80005480 <exec+0xc4>
    8000540c:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000540e:	fffff097          	auipc	ra,0xfffff
    80005412:	aa6080e7          	jalr	-1370(ra) # 80003eb4 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005416:	04000713          	li	a4,64
    8000541a:	4681                	li	a3,0
    8000541c:	e5040613          	addi	a2,s0,-432
    80005420:	4581                	li	a1,0
    80005422:	8556                	mv	a0,s5
    80005424:	fffff097          	auipc	ra,0xfffff
    80005428:	d44080e7          	jalr	-700(ra) # 80004168 <readi>
    8000542c:	04000793          	li	a5,64
    80005430:	00f51a63          	bne	a0,a5,80005444 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80005434:	e5042703          	lw	a4,-432(s0)
    80005438:	464c47b7          	lui	a5,0x464c4
    8000543c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005440:	04f70663          	beq	a4,a5,8000548c <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005444:	8556                	mv	a0,s5
    80005446:	fffff097          	auipc	ra,0xfffff
    8000544a:	cd0080e7          	jalr	-816(ra) # 80004116 <iunlockput>
    end_op();
    8000544e:	fffff097          	auipc	ra,0xfffff
    80005452:	4a8080e7          	jalr	1192(ra) # 800048f6 <end_op>
  }
  return -1;
    80005456:	557d                	li	a0,-1
}
    80005458:	21813083          	ld	ra,536(sp)
    8000545c:	21013403          	ld	s0,528(sp)
    80005460:	20813483          	ld	s1,520(sp)
    80005464:	20013903          	ld	s2,512(sp)
    80005468:	79fe                	ld	s3,504(sp)
    8000546a:	7a5e                	ld	s4,496(sp)
    8000546c:	7abe                	ld	s5,488(sp)
    8000546e:	7b1e                	ld	s6,480(sp)
    80005470:	6bfe                	ld	s7,472(sp)
    80005472:	6c5e                	ld	s8,464(sp)
    80005474:	6cbe                	ld	s9,456(sp)
    80005476:	6d1e                	ld	s10,448(sp)
    80005478:	7dfa                	ld	s11,440(sp)
    8000547a:	22010113          	addi	sp,sp,544
    8000547e:	8082                	ret
    end_op();
    80005480:	fffff097          	auipc	ra,0xfffff
    80005484:	476080e7          	jalr	1142(ra) # 800048f6 <end_op>
    return -1;
    80005488:	557d                	li	a0,-1
    8000548a:	b7f9                	j	80005458 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    8000548c:	8526                	mv	a0,s1
    8000548e:	ffffc097          	auipc	ra,0xffffc
    80005492:	5e2080e7          	jalr	1506(ra) # 80001a70 <proc_pagetable>
    80005496:	8b2a                	mv	s6,a0
    80005498:	d555                	beqz	a0,80005444 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000549a:	e7042783          	lw	a5,-400(s0)
    8000549e:	e8845703          	lhu	a4,-376(s0)
    800054a2:	c735                	beqz	a4,8000550e <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800054a4:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800054a6:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    800054aa:	6a05                	lui	s4,0x1
    800054ac:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800054b0:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    800054b4:	6d85                	lui	s11,0x1
    800054b6:	7d7d                	lui	s10,0xfffff
    800054b8:	a481                	j	800056f8 <exec+0x33c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800054ba:	00003517          	auipc	a0,0x3
    800054be:	35e50513          	addi	a0,a0,862 # 80008818 <syscallnum+0x238>
    800054c2:	ffffb097          	auipc	ra,0xffffb
    800054c6:	07c080e7          	jalr	124(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800054ca:	874a                	mv	a4,s2
    800054cc:	009c86bb          	addw	a3,s9,s1
    800054d0:	4581                	li	a1,0
    800054d2:	8556                	mv	a0,s5
    800054d4:	fffff097          	auipc	ra,0xfffff
    800054d8:	c94080e7          	jalr	-876(ra) # 80004168 <readi>
    800054dc:	2501                	sext.w	a0,a0
    800054de:	1aa91a63          	bne	s2,a0,80005692 <exec+0x2d6>
  for(i = 0; i < sz; i += PGSIZE){
    800054e2:	009d84bb          	addw	s1,s11,s1
    800054e6:	013d09bb          	addw	s3,s10,s3
    800054ea:	1f74f763          	bgeu	s1,s7,800056d8 <exec+0x31c>
    pa = walkaddr(pagetable, va + i);
    800054ee:	02049593          	slli	a1,s1,0x20
    800054f2:	9181                	srli	a1,a1,0x20
    800054f4:	95e2                	add	a1,a1,s8
    800054f6:	855a                	mv	a0,s6
    800054f8:	ffffc097          	auipc	ra,0xffffc
    800054fc:	b64080e7          	jalr	-1180(ra) # 8000105c <walkaddr>
    80005500:	862a                	mv	a2,a0
    if(pa == 0)
    80005502:	dd45                	beqz	a0,800054ba <exec+0xfe>
      n = PGSIZE;
    80005504:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005506:	fd49f2e3          	bgeu	s3,s4,800054ca <exec+0x10e>
      n = sz - i;
    8000550a:	894e                	mv	s2,s3
    8000550c:	bf7d                	j	800054ca <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000550e:	4901                	li	s2,0
  iunlockput(ip);
    80005510:	8556                	mv	a0,s5
    80005512:	fffff097          	auipc	ra,0xfffff
    80005516:	c04080e7          	jalr	-1020(ra) # 80004116 <iunlockput>
  end_op();
    8000551a:	fffff097          	auipc	ra,0xfffff
    8000551e:	3dc080e7          	jalr	988(ra) # 800048f6 <end_op>
  p = myproc();
    80005522:	ffffc097          	auipc	ra,0xffffc
    80005526:	48a080e7          	jalr	1162(ra) # 800019ac <myproc>
    8000552a:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    8000552c:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005530:	6785                	lui	a5,0x1
    80005532:	17fd                	addi	a5,a5,-1
    80005534:	993e                	add	s2,s2,a5
    80005536:	77fd                	lui	a5,0xfffff
    80005538:	00f977b3          	and	a5,s2,a5
    8000553c:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005540:	4691                	li	a3,4
    80005542:	6609                	lui	a2,0x2
    80005544:	963e                	add	a2,a2,a5
    80005546:	85be                	mv	a1,a5
    80005548:	855a                	mv	a0,s6
    8000554a:	ffffc097          	auipc	ra,0xffffc
    8000554e:	ec6080e7          	jalr	-314(ra) # 80001410 <uvmalloc>
    80005552:	8c2a                	mv	s8,a0
  ip = 0;
    80005554:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005556:	12050e63          	beqz	a0,80005692 <exec+0x2d6>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000555a:	75f9                	lui	a1,0xffffe
    8000555c:	95aa                	add	a1,a1,a0
    8000555e:	855a                	mv	a0,s6
    80005560:	ffffc097          	auipc	ra,0xffffc
    80005564:	0d6080e7          	jalr	214(ra) # 80001636 <uvmclear>
  stackbase = sp - PGSIZE;
    80005568:	7afd                	lui	s5,0xfffff
    8000556a:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    8000556c:	df043783          	ld	a5,-528(s0)
    80005570:	6388                	ld	a0,0(a5)
    80005572:	c925                	beqz	a0,800055e2 <exec+0x226>
    80005574:	e9040993          	addi	s3,s0,-368
    80005578:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    8000557c:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000557e:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005580:	ffffc097          	auipc	ra,0xffffc
    80005584:	8ce080e7          	jalr	-1842(ra) # 80000e4e <strlen>
    80005588:	0015079b          	addiw	a5,a0,1
    8000558c:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005590:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005594:	13596663          	bltu	s2,s5,800056c0 <exec+0x304>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005598:	df043d83          	ld	s11,-528(s0)
    8000559c:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800055a0:	8552                	mv	a0,s4
    800055a2:	ffffc097          	auipc	ra,0xffffc
    800055a6:	8ac080e7          	jalr	-1876(ra) # 80000e4e <strlen>
    800055aa:	0015069b          	addiw	a3,a0,1
    800055ae:	8652                	mv	a2,s4
    800055b0:	85ca                	mv	a1,s2
    800055b2:	855a                	mv	a0,s6
    800055b4:	ffffc097          	auipc	ra,0xffffc
    800055b8:	0b4080e7          	jalr	180(ra) # 80001668 <copyout>
    800055bc:	10054663          	bltz	a0,800056c8 <exec+0x30c>
    ustack[argc] = sp;
    800055c0:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800055c4:	0485                	addi	s1,s1,1
    800055c6:	008d8793          	addi	a5,s11,8
    800055ca:	def43823          	sd	a5,-528(s0)
    800055ce:	008db503          	ld	a0,8(s11)
    800055d2:	c911                	beqz	a0,800055e6 <exec+0x22a>
    if(argc >= MAXARG)
    800055d4:	09a1                	addi	s3,s3,8
    800055d6:	fb3c95e3          	bne	s9,s3,80005580 <exec+0x1c4>
  sz = sz1;
    800055da:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800055de:	4a81                	li	s5,0
    800055e0:	a84d                	j	80005692 <exec+0x2d6>
  sp = sz;
    800055e2:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800055e4:	4481                	li	s1,0
  ustack[argc] = 0;
    800055e6:	00349793          	slli	a5,s1,0x3
    800055ea:	f9040713          	addi	a4,s0,-112
    800055ee:	97ba                	add	a5,a5,a4
    800055f0:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffdb160>
  sp -= (argc+1) * sizeof(uint64);
    800055f4:	00148693          	addi	a3,s1,1
    800055f8:	068e                	slli	a3,a3,0x3
    800055fa:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800055fe:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005602:	01597663          	bgeu	s2,s5,8000560e <exec+0x252>
  sz = sz1;
    80005606:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000560a:	4a81                	li	s5,0
    8000560c:	a059                	j	80005692 <exec+0x2d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000560e:	e9040613          	addi	a2,s0,-368
    80005612:	85ca                	mv	a1,s2
    80005614:	855a                	mv	a0,s6
    80005616:	ffffc097          	auipc	ra,0xffffc
    8000561a:	052080e7          	jalr	82(ra) # 80001668 <copyout>
    8000561e:	0a054963          	bltz	a0,800056d0 <exec+0x314>
  p->trapframe->a1 = sp;
    80005622:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80005626:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000562a:	de843783          	ld	a5,-536(s0)
    8000562e:	0007c703          	lbu	a4,0(a5)
    80005632:	cf11                	beqz	a4,8000564e <exec+0x292>
    80005634:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005636:	02f00693          	li	a3,47
    8000563a:	a039                	j	80005648 <exec+0x28c>
      last = s+1;
    8000563c:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005640:	0785                	addi	a5,a5,1
    80005642:	fff7c703          	lbu	a4,-1(a5)
    80005646:	c701                	beqz	a4,8000564e <exec+0x292>
    if(*s == '/')
    80005648:	fed71ce3          	bne	a4,a3,80005640 <exec+0x284>
    8000564c:	bfc5                	j	8000563c <exec+0x280>
  safestrcpy(p->name, last, sizeof(p->name));
    8000564e:	4641                	li	a2,16
    80005650:	de843583          	ld	a1,-536(s0)
    80005654:	158b8513          	addi	a0,s7,344
    80005658:	ffffb097          	auipc	ra,0xffffb
    8000565c:	7c4080e7          	jalr	1988(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    80005660:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80005664:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80005668:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000566c:	058bb783          	ld	a5,88(s7)
    80005670:	e6843703          	ld	a4,-408(s0)
    80005674:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005676:	058bb783          	ld	a5,88(s7)
    8000567a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000567e:	85ea                	mv	a1,s10
    80005680:	ffffc097          	auipc	ra,0xffffc
    80005684:	48c080e7          	jalr	1164(ra) # 80001b0c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005688:	0004851b          	sext.w	a0,s1
    8000568c:	b3f1                	j	80005458 <exec+0x9c>
    8000568e:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005692:	df843583          	ld	a1,-520(s0)
    80005696:	855a                	mv	a0,s6
    80005698:	ffffc097          	auipc	ra,0xffffc
    8000569c:	474080e7          	jalr	1140(ra) # 80001b0c <proc_freepagetable>
  if(ip){
    800056a0:	da0a92e3          	bnez	s5,80005444 <exec+0x88>
  return -1;
    800056a4:	557d                	li	a0,-1
    800056a6:	bb4d                	j	80005458 <exec+0x9c>
    800056a8:	df243c23          	sd	s2,-520(s0)
    800056ac:	b7dd                	j	80005692 <exec+0x2d6>
    800056ae:	df243c23          	sd	s2,-520(s0)
    800056b2:	b7c5                	j	80005692 <exec+0x2d6>
    800056b4:	df243c23          	sd	s2,-520(s0)
    800056b8:	bfe9                	j	80005692 <exec+0x2d6>
    800056ba:	df243c23          	sd	s2,-520(s0)
    800056be:	bfd1                	j	80005692 <exec+0x2d6>
  sz = sz1;
    800056c0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800056c4:	4a81                	li	s5,0
    800056c6:	b7f1                	j	80005692 <exec+0x2d6>
  sz = sz1;
    800056c8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800056cc:	4a81                	li	s5,0
    800056ce:	b7d1                	j	80005692 <exec+0x2d6>
  sz = sz1;
    800056d0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800056d4:	4a81                	li	s5,0
    800056d6:	bf75                	j	80005692 <exec+0x2d6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800056d8:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800056dc:	e0843783          	ld	a5,-504(s0)
    800056e0:	0017869b          	addiw	a3,a5,1
    800056e4:	e0d43423          	sd	a3,-504(s0)
    800056e8:	e0043783          	ld	a5,-512(s0)
    800056ec:	0387879b          	addiw	a5,a5,56
    800056f0:	e8845703          	lhu	a4,-376(s0)
    800056f4:	e0e6dee3          	bge	a3,a4,80005510 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800056f8:	2781                	sext.w	a5,a5
    800056fa:	e0f43023          	sd	a5,-512(s0)
    800056fe:	03800713          	li	a4,56
    80005702:	86be                	mv	a3,a5
    80005704:	e1840613          	addi	a2,s0,-488
    80005708:	4581                	li	a1,0
    8000570a:	8556                	mv	a0,s5
    8000570c:	fffff097          	auipc	ra,0xfffff
    80005710:	a5c080e7          	jalr	-1444(ra) # 80004168 <readi>
    80005714:	03800793          	li	a5,56
    80005718:	f6f51be3          	bne	a0,a5,8000568e <exec+0x2d2>
    if(ph.type != ELF_PROG_LOAD)
    8000571c:	e1842783          	lw	a5,-488(s0)
    80005720:	4705                	li	a4,1
    80005722:	fae79de3          	bne	a5,a4,800056dc <exec+0x320>
    if(ph.memsz < ph.filesz)
    80005726:	e4043483          	ld	s1,-448(s0)
    8000572a:	e3843783          	ld	a5,-456(s0)
    8000572e:	f6f4ede3          	bltu	s1,a5,800056a8 <exec+0x2ec>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005732:	e2843783          	ld	a5,-472(s0)
    80005736:	94be                	add	s1,s1,a5
    80005738:	f6f4ebe3          	bltu	s1,a5,800056ae <exec+0x2f2>
    if(ph.vaddr % PGSIZE != 0)
    8000573c:	de043703          	ld	a4,-544(s0)
    80005740:	8ff9                	and	a5,a5,a4
    80005742:	fbad                	bnez	a5,800056b4 <exec+0x2f8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005744:	e1c42503          	lw	a0,-484(s0)
    80005748:	00000097          	auipc	ra,0x0
    8000574c:	c58080e7          	jalr	-936(ra) # 800053a0 <flags2perm>
    80005750:	86aa                	mv	a3,a0
    80005752:	8626                	mv	a2,s1
    80005754:	85ca                	mv	a1,s2
    80005756:	855a                	mv	a0,s6
    80005758:	ffffc097          	auipc	ra,0xffffc
    8000575c:	cb8080e7          	jalr	-840(ra) # 80001410 <uvmalloc>
    80005760:	dea43c23          	sd	a0,-520(s0)
    80005764:	d939                	beqz	a0,800056ba <exec+0x2fe>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005766:	e2843c03          	ld	s8,-472(s0)
    8000576a:	e2042c83          	lw	s9,-480(s0)
    8000576e:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005772:	f60b83e3          	beqz	s7,800056d8 <exec+0x31c>
    80005776:	89de                	mv	s3,s7
    80005778:	4481                	li	s1,0
    8000577a:	bb95                	j	800054ee <exec+0x132>

000000008000577c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000577c:	7179                	addi	sp,sp,-48
    8000577e:	f406                	sd	ra,40(sp)
    80005780:	f022                	sd	s0,32(sp)
    80005782:	ec26                	sd	s1,24(sp)
    80005784:	e84a                	sd	s2,16(sp)
    80005786:	1800                	addi	s0,sp,48
    80005788:	892e                	mv	s2,a1
    8000578a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000578c:	fdc40593          	addi	a1,s0,-36
    80005790:	ffffe097          	auipc	ra,0xffffe
    80005794:	912080e7          	jalr	-1774(ra) # 800030a2 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005798:	fdc42703          	lw	a4,-36(s0)
    8000579c:	47bd                	li	a5,15
    8000579e:	02e7eb63          	bltu	a5,a4,800057d4 <argfd+0x58>
    800057a2:	ffffc097          	auipc	ra,0xffffc
    800057a6:	20a080e7          	jalr	522(ra) # 800019ac <myproc>
    800057aa:	fdc42703          	lw	a4,-36(s0)
    800057ae:	01a70793          	addi	a5,a4,26
    800057b2:	078e                	slli	a5,a5,0x3
    800057b4:	953e                	add	a0,a0,a5
    800057b6:	611c                	ld	a5,0(a0)
    800057b8:	c385                	beqz	a5,800057d8 <argfd+0x5c>
    return -1;
  if(pfd)
    800057ba:	00090463          	beqz	s2,800057c2 <argfd+0x46>
    *pfd = fd;
    800057be:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800057c2:	4501                	li	a0,0
  if(pf)
    800057c4:	c091                	beqz	s1,800057c8 <argfd+0x4c>
    *pf = f;
    800057c6:	e09c                	sd	a5,0(s1)
}
    800057c8:	70a2                	ld	ra,40(sp)
    800057ca:	7402                	ld	s0,32(sp)
    800057cc:	64e2                	ld	s1,24(sp)
    800057ce:	6942                	ld	s2,16(sp)
    800057d0:	6145                	addi	sp,sp,48
    800057d2:	8082                	ret
    return -1;
    800057d4:	557d                	li	a0,-1
    800057d6:	bfcd                	j	800057c8 <argfd+0x4c>
    800057d8:	557d                	li	a0,-1
    800057da:	b7fd                	j	800057c8 <argfd+0x4c>

00000000800057dc <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800057dc:	1101                	addi	sp,sp,-32
    800057de:	ec06                	sd	ra,24(sp)
    800057e0:	e822                	sd	s0,16(sp)
    800057e2:	e426                	sd	s1,8(sp)
    800057e4:	1000                	addi	s0,sp,32
    800057e6:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800057e8:	ffffc097          	auipc	ra,0xffffc
    800057ec:	1c4080e7          	jalr	452(ra) # 800019ac <myproc>
    800057f0:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800057f2:	0d050793          	addi	a5,a0,208
    800057f6:	4501                	li	a0,0
    800057f8:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800057fa:	6398                	ld	a4,0(a5)
    800057fc:	cb19                	beqz	a4,80005812 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800057fe:	2505                	addiw	a0,a0,1
    80005800:	07a1                	addi	a5,a5,8
    80005802:	fed51ce3          	bne	a0,a3,800057fa <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005806:	557d                	li	a0,-1
}
    80005808:	60e2                	ld	ra,24(sp)
    8000580a:	6442                	ld	s0,16(sp)
    8000580c:	64a2                	ld	s1,8(sp)
    8000580e:	6105                	addi	sp,sp,32
    80005810:	8082                	ret
      p->ofile[fd] = f;
    80005812:	01a50793          	addi	a5,a0,26
    80005816:	078e                	slli	a5,a5,0x3
    80005818:	963e                	add	a2,a2,a5
    8000581a:	e204                	sd	s1,0(a2)
      return fd;
    8000581c:	b7f5                	j	80005808 <fdalloc+0x2c>

000000008000581e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000581e:	715d                	addi	sp,sp,-80
    80005820:	e486                	sd	ra,72(sp)
    80005822:	e0a2                	sd	s0,64(sp)
    80005824:	fc26                	sd	s1,56(sp)
    80005826:	f84a                	sd	s2,48(sp)
    80005828:	f44e                	sd	s3,40(sp)
    8000582a:	f052                	sd	s4,32(sp)
    8000582c:	ec56                	sd	s5,24(sp)
    8000582e:	e85a                	sd	s6,16(sp)
    80005830:	0880                	addi	s0,sp,80
    80005832:	8b2e                	mv	s6,a1
    80005834:	89b2                	mv	s3,a2
    80005836:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005838:	fb040593          	addi	a1,s0,-80
    8000583c:	fffff097          	auipc	ra,0xfffff
    80005840:	e3c080e7          	jalr	-452(ra) # 80004678 <nameiparent>
    80005844:	84aa                	mv	s1,a0
    80005846:	14050f63          	beqz	a0,800059a4 <create+0x186>
    return 0;

  ilock(dp);
    8000584a:	ffffe097          	auipc	ra,0xffffe
    8000584e:	66a080e7          	jalr	1642(ra) # 80003eb4 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005852:	4601                	li	a2,0
    80005854:	fb040593          	addi	a1,s0,-80
    80005858:	8526                	mv	a0,s1
    8000585a:	fffff097          	auipc	ra,0xfffff
    8000585e:	b3e080e7          	jalr	-1218(ra) # 80004398 <dirlookup>
    80005862:	8aaa                	mv	s5,a0
    80005864:	c931                	beqz	a0,800058b8 <create+0x9a>
    iunlockput(dp);
    80005866:	8526                	mv	a0,s1
    80005868:	fffff097          	auipc	ra,0xfffff
    8000586c:	8ae080e7          	jalr	-1874(ra) # 80004116 <iunlockput>
    ilock(ip);
    80005870:	8556                	mv	a0,s5
    80005872:	ffffe097          	auipc	ra,0xffffe
    80005876:	642080e7          	jalr	1602(ra) # 80003eb4 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000587a:	000b059b          	sext.w	a1,s6
    8000587e:	4789                	li	a5,2
    80005880:	02f59563          	bne	a1,a5,800058aa <create+0x8c>
    80005884:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdb2a4>
    80005888:	37f9                	addiw	a5,a5,-2
    8000588a:	17c2                	slli	a5,a5,0x30
    8000588c:	93c1                	srli	a5,a5,0x30
    8000588e:	4705                	li	a4,1
    80005890:	00f76d63          	bltu	a4,a5,800058aa <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005894:	8556                	mv	a0,s5
    80005896:	60a6                	ld	ra,72(sp)
    80005898:	6406                	ld	s0,64(sp)
    8000589a:	74e2                	ld	s1,56(sp)
    8000589c:	7942                	ld	s2,48(sp)
    8000589e:	79a2                	ld	s3,40(sp)
    800058a0:	7a02                	ld	s4,32(sp)
    800058a2:	6ae2                	ld	s5,24(sp)
    800058a4:	6b42                	ld	s6,16(sp)
    800058a6:	6161                	addi	sp,sp,80
    800058a8:	8082                	ret
    iunlockput(ip);
    800058aa:	8556                	mv	a0,s5
    800058ac:	fffff097          	auipc	ra,0xfffff
    800058b0:	86a080e7          	jalr	-1942(ra) # 80004116 <iunlockput>
    return 0;
    800058b4:	4a81                	li	s5,0
    800058b6:	bff9                	j	80005894 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800058b8:	85da                	mv	a1,s6
    800058ba:	4088                	lw	a0,0(s1)
    800058bc:	ffffe097          	auipc	ra,0xffffe
    800058c0:	45c080e7          	jalr	1116(ra) # 80003d18 <ialloc>
    800058c4:	8a2a                	mv	s4,a0
    800058c6:	c539                	beqz	a0,80005914 <create+0xf6>
  ilock(ip);
    800058c8:	ffffe097          	auipc	ra,0xffffe
    800058cc:	5ec080e7          	jalr	1516(ra) # 80003eb4 <ilock>
  ip->major = major;
    800058d0:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800058d4:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800058d8:	4905                	li	s2,1
    800058da:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800058de:	8552                	mv	a0,s4
    800058e0:	ffffe097          	auipc	ra,0xffffe
    800058e4:	50a080e7          	jalr	1290(ra) # 80003dea <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800058e8:	000b059b          	sext.w	a1,s6
    800058ec:	03258b63          	beq	a1,s2,80005922 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    800058f0:	004a2603          	lw	a2,4(s4)
    800058f4:	fb040593          	addi	a1,s0,-80
    800058f8:	8526                	mv	a0,s1
    800058fa:	fffff097          	auipc	ra,0xfffff
    800058fe:	cae080e7          	jalr	-850(ra) # 800045a8 <dirlink>
    80005902:	06054f63          	bltz	a0,80005980 <create+0x162>
  iunlockput(dp);
    80005906:	8526                	mv	a0,s1
    80005908:	fffff097          	auipc	ra,0xfffff
    8000590c:	80e080e7          	jalr	-2034(ra) # 80004116 <iunlockput>
  return ip;
    80005910:	8ad2                	mv	s5,s4
    80005912:	b749                	j	80005894 <create+0x76>
    iunlockput(dp);
    80005914:	8526                	mv	a0,s1
    80005916:	fffff097          	auipc	ra,0xfffff
    8000591a:	800080e7          	jalr	-2048(ra) # 80004116 <iunlockput>
    return 0;
    8000591e:	8ad2                	mv	s5,s4
    80005920:	bf95                	j	80005894 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005922:	004a2603          	lw	a2,4(s4)
    80005926:	00003597          	auipc	a1,0x3
    8000592a:	f1258593          	addi	a1,a1,-238 # 80008838 <syscallnum+0x258>
    8000592e:	8552                	mv	a0,s4
    80005930:	fffff097          	auipc	ra,0xfffff
    80005934:	c78080e7          	jalr	-904(ra) # 800045a8 <dirlink>
    80005938:	04054463          	bltz	a0,80005980 <create+0x162>
    8000593c:	40d0                	lw	a2,4(s1)
    8000593e:	00003597          	auipc	a1,0x3
    80005942:	f0258593          	addi	a1,a1,-254 # 80008840 <syscallnum+0x260>
    80005946:	8552                	mv	a0,s4
    80005948:	fffff097          	auipc	ra,0xfffff
    8000594c:	c60080e7          	jalr	-928(ra) # 800045a8 <dirlink>
    80005950:	02054863          	bltz	a0,80005980 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    80005954:	004a2603          	lw	a2,4(s4)
    80005958:	fb040593          	addi	a1,s0,-80
    8000595c:	8526                	mv	a0,s1
    8000595e:	fffff097          	auipc	ra,0xfffff
    80005962:	c4a080e7          	jalr	-950(ra) # 800045a8 <dirlink>
    80005966:	00054d63          	bltz	a0,80005980 <create+0x162>
    dp->nlink++;  // for ".."
    8000596a:	04a4d783          	lhu	a5,74(s1)
    8000596e:	2785                	addiw	a5,a5,1
    80005970:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005974:	8526                	mv	a0,s1
    80005976:	ffffe097          	auipc	ra,0xffffe
    8000597a:	474080e7          	jalr	1140(ra) # 80003dea <iupdate>
    8000597e:	b761                	j	80005906 <create+0xe8>
  ip->nlink = 0;
    80005980:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005984:	8552                	mv	a0,s4
    80005986:	ffffe097          	auipc	ra,0xffffe
    8000598a:	464080e7          	jalr	1124(ra) # 80003dea <iupdate>
  iunlockput(ip);
    8000598e:	8552                	mv	a0,s4
    80005990:	ffffe097          	auipc	ra,0xffffe
    80005994:	786080e7          	jalr	1926(ra) # 80004116 <iunlockput>
  iunlockput(dp);
    80005998:	8526                	mv	a0,s1
    8000599a:	ffffe097          	auipc	ra,0xffffe
    8000599e:	77c080e7          	jalr	1916(ra) # 80004116 <iunlockput>
  return 0;
    800059a2:	bdcd                	j	80005894 <create+0x76>
    return 0;
    800059a4:	8aaa                	mv	s5,a0
    800059a6:	b5fd                	j	80005894 <create+0x76>

00000000800059a8 <sys_dup>:
{
    800059a8:	7179                	addi	sp,sp,-48
    800059aa:	f406                	sd	ra,40(sp)
    800059ac:	f022                	sd	s0,32(sp)
    800059ae:	ec26                	sd	s1,24(sp)
    800059b0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800059b2:	fd840613          	addi	a2,s0,-40
    800059b6:	4581                	li	a1,0
    800059b8:	4501                	li	a0,0
    800059ba:	00000097          	auipc	ra,0x0
    800059be:	dc2080e7          	jalr	-574(ra) # 8000577c <argfd>
    return -1;
    800059c2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800059c4:	02054363          	bltz	a0,800059ea <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800059c8:	fd843503          	ld	a0,-40(s0)
    800059cc:	00000097          	auipc	ra,0x0
    800059d0:	e10080e7          	jalr	-496(ra) # 800057dc <fdalloc>
    800059d4:	84aa                	mv	s1,a0
    return -1;
    800059d6:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800059d8:	00054963          	bltz	a0,800059ea <sys_dup+0x42>
  filedup(f);
    800059dc:	fd843503          	ld	a0,-40(s0)
    800059e0:	fffff097          	auipc	ra,0xfffff
    800059e4:	310080e7          	jalr	784(ra) # 80004cf0 <filedup>
  return fd;
    800059e8:	87a6                	mv	a5,s1
}
    800059ea:	853e                	mv	a0,a5
    800059ec:	70a2                	ld	ra,40(sp)
    800059ee:	7402                	ld	s0,32(sp)
    800059f0:	64e2                	ld	s1,24(sp)
    800059f2:	6145                	addi	sp,sp,48
    800059f4:	8082                	ret

00000000800059f6 <sys_read>:
{
    800059f6:	7179                	addi	sp,sp,-48
    800059f8:	f406                	sd	ra,40(sp)
    800059fa:	f022                	sd	s0,32(sp)
    800059fc:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800059fe:	fd840593          	addi	a1,s0,-40
    80005a02:	4505                	li	a0,1
    80005a04:	ffffd097          	auipc	ra,0xffffd
    80005a08:	6c0080e7          	jalr	1728(ra) # 800030c4 <argaddr>
  argint(2, &n);
    80005a0c:	fe440593          	addi	a1,s0,-28
    80005a10:	4509                	li	a0,2
    80005a12:	ffffd097          	auipc	ra,0xffffd
    80005a16:	690080e7          	jalr	1680(ra) # 800030a2 <argint>
  if(argfd(0, 0, &f) < 0)
    80005a1a:	fe840613          	addi	a2,s0,-24
    80005a1e:	4581                	li	a1,0
    80005a20:	4501                	li	a0,0
    80005a22:	00000097          	auipc	ra,0x0
    80005a26:	d5a080e7          	jalr	-678(ra) # 8000577c <argfd>
    80005a2a:	87aa                	mv	a5,a0
    return -1;
    80005a2c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005a2e:	0007cc63          	bltz	a5,80005a46 <sys_read+0x50>
  return fileread(f, p, n);
    80005a32:	fe442603          	lw	a2,-28(s0)
    80005a36:	fd843583          	ld	a1,-40(s0)
    80005a3a:	fe843503          	ld	a0,-24(s0)
    80005a3e:	fffff097          	auipc	ra,0xfffff
    80005a42:	43e080e7          	jalr	1086(ra) # 80004e7c <fileread>
}
    80005a46:	70a2                	ld	ra,40(sp)
    80005a48:	7402                	ld	s0,32(sp)
    80005a4a:	6145                	addi	sp,sp,48
    80005a4c:	8082                	ret

0000000080005a4e <sys_write>:
{
    80005a4e:	7179                	addi	sp,sp,-48
    80005a50:	f406                	sd	ra,40(sp)
    80005a52:	f022                	sd	s0,32(sp)
    80005a54:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005a56:	fd840593          	addi	a1,s0,-40
    80005a5a:	4505                	li	a0,1
    80005a5c:	ffffd097          	auipc	ra,0xffffd
    80005a60:	668080e7          	jalr	1640(ra) # 800030c4 <argaddr>
  argint(2, &n);
    80005a64:	fe440593          	addi	a1,s0,-28
    80005a68:	4509                	li	a0,2
    80005a6a:	ffffd097          	auipc	ra,0xffffd
    80005a6e:	638080e7          	jalr	1592(ra) # 800030a2 <argint>
  if(argfd(0, 0, &f) < 0)
    80005a72:	fe840613          	addi	a2,s0,-24
    80005a76:	4581                	li	a1,0
    80005a78:	4501                	li	a0,0
    80005a7a:	00000097          	auipc	ra,0x0
    80005a7e:	d02080e7          	jalr	-766(ra) # 8000577c <argfd>
    80005a82:	87aa                	mv	a5,a0
    return -1;
    80005a84:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005a86:	0007cc63          	bltz	a5,80005a9e <sys_write+0x50>
  return filewrite(f, p, n);
    80005a8a:	fe442603          	lw	a2,-28(s0)
    80005a8e:	fd843583          	ld	a1,-40(s0)
    80005a92:	fe843503          	ld	a0,-24(s0)
    80005a96:	fffff097          	auipc	ra,0xfffff
    80005a9a:	4a8080e7          	jalr	1192(ra) # 80004f3e <filewrite>
}
    80005a9e:	70a2                	ld	ra,40(sp)
    80005aa0:	7402                	ld	s0,32(sp)
    80005aa2:	6145                	addi	sp,sp,48
    80005aa4:	8082                	ret

0000000080005aa6 <sys_close>:
{
    80005aa6:	1101                	addi	sp,sp,-32
    80005aa8:	ec06                	sd	ra,24(sp)
    80005aaa:	e822                	sd	s0,16(sp)
    80005aac:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005aae:	fe040613          	addi	a2,s0,-32
    80005ab2:	fec40593          	addi	a1,s0,-20
    80005ab6:	4501                	li	a0,0
    80005ab8:	00000097          	auipc	ra,0x0
    80005abc:	cc4080e7          	jalr	-828(ra) # 8000577c <argfd>
    return -1;
    80005ac0:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005ac2:	02054463          	bltz	a0,80005aea <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005ac6:	ffffc097          	auipc	ra,0xffffc
    80005aca:	ee6080e7          	jalr	-282(ra) # 800019ac <myproc>
    80005ace:	fec42783          	lw	a5,-20(s0)
    80005ad2:	07e9                	addi	a5,a5,26
    80005ad4:	078e                	slli	a5,a5,0x3
    80005ad6:	97aa                	add	a5,a5,a0
    80005ad8:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005adc:	fe043503          	ld	a0,-32(s0)
    80005ae0:	fffff097          	auipc	ra,0xfffff
    80005ae4:	262080e7          	jalr	610(ra) # 80004d42 <fileclose>
  return 0;
    80005ae8:	4781                	li	a5,0
}
    80005aea:	853e                	mv	a0,a5
    80005aec:	60e2                	ld	ra,24(sp)
    80005aee:	6442                	ld	s0,16(sp)
    80005af0:	6105                	addi	sp,sp,32
    80005af2:	8082                	ret

0000000080005af4 <sys_fstat>:
{
    80005af4:	1101                	addi	sp,sp,-32
    80005af6:	ec06                	sd	ra,24(sp)
    80005af8:	e822                	sd	s0,16(sp)
    80005afa:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005afc:	fe040593          	addi	a1,s0,-32
    80005b00:	4505                	li	a0,1
    80005b02:	ffffd097          	auipc	ra,0xffffd
    80005b06:	5c2080e7          	jalr	1474(ra) # 800030c4 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005b0a:	fe840613          	addi	a2,s0,-24
    80005b0e:	4581                	li	a1,0
    80005b10:	4501                	li	a0,0
    80005b12:	00000097          	auipc	ra,0x0
    80005b16:	c6a080e7          	jalr	-918(ra) # 8000577c <argfd>
    80005b1a:	87aa                	mv	a5,a0
    return -1;
    80005b1c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005b1e:	0007ca63          	bltz	a5,80005b32 <sys_fstat+0x3e>
  return filestat(f, st);
    80005b22:	fe043583          	ld	a1,-32(s0)
    80005b26:	fe843503          	ld	a0,-24(s0)
    80005b2a:	fffff097          	auipc	ra,0xfffff
    80005b2e:	2e0080e7          	jalr	736(ra) # 80004e0a <filestat>
}
    80005b32:	60e2                	ld	ra,24(sp)
    80005b34:	6442                	ld	s0,16(sp)
    80005b36:	6105                	addi	sp,sp,32
    80005b38:	8082                	ret

0000000080005b3a <sys_link>:
{
    80005b3a:	7169                	addi	sp,sp,-304
    80005b3c:	f606                	sd	ra,296(sp)
    80005b3e:	f222                	sd	s0,288(sp)
    80005b40:	ee26                	sd	s1,280(sp)
    80005b42:	ea4a                	sd	s2,272(sp)
    80005b44:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b46:	08000613          	li	a2,128
    80005b4a:	ed040593          	addi	a1,s0,-304
    80005b4e:	4501                	li	a0,0
    80005b50:	ffffd097          	auipc	ra,0xffffd
    80005b54:	596080e7          	jalr	1430(ra) # 800030e6 <argstr>
    return -1;
    80005b58:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b5a:	10054e63          	bltz	a0,80005c76 <sys_link+0x13c>
    80005b5e:	08000613          	li	a2,128
    80005b62:	f5040593          	addi	a1,s0,-176
    80005b66:	4505                	li	a0,1
    80005b68:	ffffd097          	auipc	ra,0xffffd
    80005b6c:	57e080e7          	jalr	1406(ra) # 800030e6 <argstr>
    return -1;
    80005b70:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b72:	10054263          	bltz	a0,80005c76 <sys_link+0x13c>
  begin_op();
    80005b76:	fffff097          	auipc	ra,0xfffff
    80005b7a:	d00080e7          	jalr	-768(ra) # 80004876 <begin_op>
  if((ip = namei(old)) == 0){
    80005b7e:	ed040513          	addi	a0,s0,-304
    80005b82:	fffff097          	auipc	ra,0xfffff
    80005b86:	ad8080e7          	jalr	-1320(ra) # 8000465a <namei>
    80005b8a:	84aa                	mv	s1,a0
    80005b8c:	c551                	beqz	a0,80005c18 <sys_link+0xde>
  ilock(ip);
    80005b8e:	ffffe097          	auipc	ra,0xffffe
    80005b92:	326080e7          	jalr	806(ra) # 80003eb4 <ilock>
  if(ip->type == T_DIR){
    80005b96:	04449703          	lh	a4,68(s1)
    80005b9a:	4785                	li	a5,1
    80005b9c:	08f70463          	beq	a4,a5,80005c24 <sys_link+0xea>
  ip->nlink++;
    80005ba0:	04a4d783          	lhu	a5,74(s1)
    80005ba4:	2785                	addiw	a5,a5,1
    80005ba6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005baa:	8526                	mv	a0,s1
    80005bac:	ffffe097          	auipc	ra,0xffffe
    80005bb0:	23e080e7          	jalr	574(ra) # 80003dea <iupdate>
  iunlock(ip);
    80005bb4:	8526                	mv	a0,s1
    80005bb6:	ffffe097          	auipc	ra,0xffffe
    80005bba:	3c0080e7          	jalr	960(ra) # 80003f76 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005bbe:	fd040593          	addi	a1,s0,-48
    80005bc2:	f5040513          	addi	a0,s0,-176
    80005bc6:	fffff097          	auipc	ra,0xfffff
    80005bca:	ab2080e7          	jalr	-1358(ra) # 80004678 <nameiparent>
    80005bce:	892a                	mv	s2,a0
    80005bd0:	c935                	beqz	a0,80005c44 <sys_link+0x10a>
  ilock(dp);
    80005bd2:	ffffe097          	auipc	ra,0xffffe
    80005bd6:	2e2080e7          	jalr	738(ra) # 80003eb4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005bda:	00092703          	lw	a4,0(s2)
    80005bde:	409c                	lw	a5,0(s1)
    80005be0:	04f71d63          	bne	a4,a5,80005c3a <sys_link+0x100>
    80005be4:	40d0                	lw	a2,4(s1)
    80005be6:	fd040593          	addi	a1,s0,-48
    80005bea:	854a                	mv	a0,s2
    80005bec:	fffff097          	auipc	ra,0xfffff
    80005bf0:	9bc080e7          	jalr	-1604(ra) # 800045a8 <dirlink>
    80005bf4:	04054363          	bltz	a0,80005c3a <sys_link+0x100>
  iunlockput(dp);
    80005bf8:	854a                	mv	a0,s2
    80005bfa:	ffffe097          	auipc	ra,0xffffe
    80005bfe:	51c080e7          	jalr	1308(ra) # 80004116 <iunlockput>
  iput(ip);
    80005c02:	8526                	mv	a0,s1
    80005c04:	ffffe097          	auipc	ra,0xffffe
    80005c08:	46a080e7          	jalr	1130(ra) # 8000406e <iput>
  end_op();
    80005c0c:	fffff097          	auipc	ra,0xfffff
    80005c10:	cea080e7          	jalr	-790(ra) # 800048f6 <end_op>
  return 0;
    80005c14:	4781                	li	a5,0
    80005c16:	a085                	j	80005c76 <sys_link+0x13c>
    end_op();
    80005c18:	fffff097          	auipc	ra,0xfffff
    80005c1c:	cde080e7          	jalr	-802(ra) # 800048f6 <end_op>
    return -1;
    80005c20:	57fd                	li	a5,-1
    80005c22:	a891                	j	80005c76 <sys_link+0x13c>
    iunlockput(ip);
    80005c24:	8526                	mv	a0,s1
    80005c26:	ffffe097          	auipc	ra,0xffffe
    80005c2a:	4f0080e7          	jalr	1264(ra) # 80004116 <iunlockput>
    end_op();
    80005c2e:	fffff097          	auipc	ra,0xfffff
    80005c32:	cc8080e7          	jalr	-824(ra) # 800048f6 <end_op>
    return -1;
    80005c36:	57fd                	li	a5,-1
    80005c38:	a83d                	j	80005c76 <sys_link+0x13c>
    iunlockput(dp);
    80005c3a:	854a                	mv	a0,s2
    80005c3c:	ffffe097          	auipc	ra,0xffffe
    80005c40:	4da080e7          	jalr	1242(ra) # 80004116 <iunlockput>
  ilock(ip);
    80005c44:	8526                	mv	a0,s1
    80005c46:	ffffe097          	auipc	ra,0xffffe
    80005c4a:	26e080e7          	jalr	622(ra) # 80003eb4 <ilock>
  ip->nlink--;
    80005c4e:	04a4d783          	lhu	a5,74(s1)
    80005c52:	37fd                	addiw	a5,a5,-1
    80005c54:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005c58:	8526                	mv	a0,s1
    80005c5a:	ffffe097          	auipc	ra,0xffffe
    80005c5e:	190080e7          	jalr	400(ra) # 80003dea <iupdate>
  iunlockput(ip);
    80005c62:	8526                	mv	a0,s1
    80005c64:	ffffe097          	auipc	ra,0xffffe
    80005c68:	4b2080e7          	jalr	1202(ra) # 80004116 <iunlockput>
  end_op();
    80005c6c:	fffff097          	auipc	ra,0xfffff
    80005c70:	c8a080e7          	jalr	-886(ra) # 800048f6 <end_op>
  return -1;
    80005c74:	57fd                	li	a5,-1
}
    80005c76:	853e                	mv	a0,a5
    80005c78:	70b2                	ld	ra,296(sp)
    80005c7a:	7412                	ld	s0,288(sp)
    80005c7c:	64f2                	ld	s1,280(sp)
    80005c7e:	6952                	ld	s2,272(sp)
    80005c80:	6155                	addi	sp,sp,304
    80005c82:	8082                	ret

0000000080005c84 <sys_unlink>:
{
    80005c84:	7151                	addi	sp,sp,-240
    80005c86:	f586                	sd	ra,232(sp)
    80005c88:	f1a2                	sd	s0,224(sp)
    80005c8a:	eda6                	sd	s1,216(sp)
    80005c8c:	e9ca                	sd	s2,208(sp)
    80005c8e:	e5ce                	sd	s3,200(sp)
    80005c90:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005c92:	08000613          	li	a2,128
    80005c96:	f3040593          	addi	a1,s0,-208
    80005c9a:	4501                	li	a0,0
    80005c9c:	ffffd097          	auipc	ra,0xffffd
    80005ca0:	44a080e7          	jalr	1098(ra) # 800030e6 <argstr>
    80005ca4:	18054163          	bltz	a0,80005e26 <sys_unlink+0x1a2>
  begin_op();
    80005ca8:	fffff097          	auipc	ra,0xfffff
    80005cac:	bce080e7          	jalr	-1074(ra) # 80004876 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005cb0:	fb040593          	addi	a1,s0,-80
    80005cb4:	f3040513          	addi	a0,s0,-208
    80005cb8:	fffff097          	auipc	ra,0xfffff
    80005cbc:	9c0080e7          	jalr	-1600(ra) # 80004678 <nameiparent>
    80005cc0:	84aa                	mv	s1,a0
    80005cc2:	c979                	beqz	a0,80005d98 <sys_unlink+0x114>
  ilock(dp);
    80005cc4:	ffffe097          	auipc	ra,0xffffe
    80005cc8:	1f0080e7          	jalr	496(ra) # 80003eb4 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005ccc:	00003597          	auipc	a1,0x3
    80005cd0:	b6c58593          	addi	a1,a1,-1172 # 80008838 <syscallnum+0x258>
    80005cd4:	fb040513          	addi	a0,s0,-80
    80005cd8:	ffffe097          	auipc	ra,0xffffe
    80005cdc:	6a6080e7          	jalr	1702(ra) # 8000437e <namecmp>
    80005ce0:	14050a63          	beqz	a0,80005e34 <sys_unlink+0x1b0>
    80005ce4:	00003597          	auipc	a1,0x3
    80005ce8:	b5c58593          	addi	a1,a1,-1188 # 80008840 <syscallnum+0x260>
    80005cec:	fb040513          	addi	a0,s0,-80
    80005cf0:	ffffe097          	auipc	ra,0xffffe
    80005cf4:	68e080e7          	jalr	1678(ra) # 8000437e <namecmp>
    80005cf8:	12050e63          	beqz	a0,80005e34 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005cfc:	f2c40613          	addi	a2,s0,-212
    80005d00:	fb040593          	addi	a1,s0,-80
    80005d04:	8526                	mv	a0,s1
    80005d06:	ffffe097          	auipc	ra,0xffffe
    80005d0a:	692080e7          	jalr	1682(ra) # 80004398 <dirlookup>
    80005d0e:	892a                	mv	s2,a0
    80005d10:	12050263          	beqz	a0,80005e34 <sys_unlink+0x1b0>
  ilock(ip);
    80005d14:	ffffe097          	auipc	ra,0xffffe
    80005d18:	1a0080e7          	jalr	416(ra) # 80003eb4 <ilock>
  if(ip->nlink < 1)
    80005d1c:	04a91783          	lh	a5,74(s2)
    80005d20:	08f05263          	blez	a5,80005da4 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005d24:	04491703          	lh	a4,68(s2)
    80005d28:	4785                	li	a5,1
    80005d2a:	08f70563          	beq	a4,a5,80005db4 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005d2e:	4641                	li	a2,16
    80005d30:	4581                	li	a1,0
    80005d32:	fc040513          	addi	a0,s0,-64
    80005d36:	ffffb097          	auipc	ra,0xffffb
    80005d3a:	f9c080e7          	jalr	-100(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005d3e:	4741                	li	a4,16
    80005d40:	f2c42683          	lw	a3,-212(s0)
    80005d44:	fc040613          	addi	a2,s0,-64
    80005d48:	4581                	li	a1,0
    80005d4a:	8526                	mv	a0,s1
    80005d4c:	ffffe097          	auipc	ra,0xffffe
    80005d50:	514080e7          	jalr	1300(ra) # 80004260 <writei>
    80005d54:	47c1                	li	a5,16
    80005d56:	0af51563          	bne	a0,a5,80005e00 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005d5a:	04491703          	lh	a4,68(s2)
    80005d5e:	4785                	li	a5,1
    80005d60:	0af70863          	beq	a4,a5,80005e10 <sys_unlink+0x18c>
  iunlockput(dp);
    80005d64:	8526                	mv	a0,s1
    80005d66:	ffffe097          	auipc	ra,0xffffe
    80005d6a:	3b0080e7          	jalr	944(ra) # 80004116 <iunlockput>
  ip->nlink--;
    80005d6e:	04a95783          	lhu	a5,74(s2)
    80005d72:	37fd                	addiw	a5,a5,-1
    80005d74:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005d78:	854a                	mv	a0,s2
    80005d7a:	ffffe097          	auipc	ra,0xffffe
    80005d7e:	070080e7          	jalr	112(ra) # 80003dea <iupdate>
  iunlockput(ip);
    80005d82:	854a                	mv	a0,s2
    80005d84:	ffffe097          	auipc	ra,0xffffe
    80005d88:	392080e7          	jalr	914(ra) # 80004116 <iunlockput>
  end_op();
    80005d8c:	fffff097          	auipc	ra,0xfffff
    80005d90:	b6a080e7          	jalr	-1174(ra) # 800048f6 <end_op>
  return 0;
    80005d94:	4501                	li	a0,0
    80005d96:	a84d                	j	80005e48 <sys_unlink+0x1c4>
    end_op();
    80005d98:	fffff097          	auipc	ra,0xfffff
    80005d9c:	b5e080e7          	jalr	-1186(ra) # 800048f6 <end_op>
    return -1;
    80005da0:	557d                	li	a0,-1
    80005da2:	a05d                	j	80005e48 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005da4:	00003517          	auipc	a0,0x3
    80005da8:	aa450513          	addi	a0,a0,-1372 # 80008848 <syscallnum+0x268>
    80005dac:	ffffa097          	auipc	ra,0xffffa
    80005db0:	792080e7          	jalr	1938(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005db4:	04c92703          	lw	a4,76(s2)
    80005db8:	02000793          	li	a5,32
    80005dbc:	f6e7f9e3          	bgeu	a5,a4,80005d2e <sys_unlink+0xaa>
    80005dc0:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005dc4:	4741                	li	a4,16
    80005dc6:	86ce                	mv	a3,s3
    80005dc8:	f1840613          	addi	a2,s0,-232
    80005dcc:	4581                	li	a1,0
    80005dce:	854a                	mv	a0,s2
    80005dd0:	ffffe097          	auipc	ra,0xffffe
    80005dd4:	398080e7          	jalr	920(ra) # 80004168 <readi>
    80005dd8:	47c1                	li	a5,16
    80005dda:	00f51b63          	bne	a0,a5,80005df0 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005dde:	f1845783          	lhu	a5,-232(s0)
    80005de2:	e7a1                	bnez	a5,80005e2a <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005de4:	29c1                	addiw	s3,s3,16
    80005de6:	04c92783          	lw	a5,76(s2)
    80005dea:	fcf9ede3          	bltu	s3,a5,80005dc4 <sys_unlink+0x140>
    80005dee:	b781                	j	80005d2e <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005df0:	00003517          	auipc	a0,0x3
    80005df4:	a7050513          	addi	a0,a0,-1424 # 80008860 <syscallnum+0x280>
    80005df8:	ffffa097          	auipc	ra,0xffffa
    80005dfc:	746080e7          	jalr	1862(ra) # 8000053e <panic>
    panic("unlink: writei");
    80005e00:	00003517          	auipc	a0,0x3
    80005e04:	a7850513          	addi	a0,a0,-1416 # 80008878 <syscallnum+0x298>
    80005e08:	ffffa097          	auipc	ra,0xffffa
    80005e0c:	736080e7          	jalr	1846(ra) # 8000053e <panic>
    dp->nlink--;
    80005e10:	04a4d783          	lhu	a5,74(s1)
    80005e14:	37fd                	addiw	a5,a5,-1
    80005e16:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005e1a:	8526                	mv	a0,s1
    80005e1c:	ffffe097          	auipc	ra,0xffffe
    80005e20:	fce080e7          	jalr	-50(ra) # 80003dea <iupdate>
    80005e24:	b781                	j	80005d64 <sys_unlink+0xe0>
    return -1;
    80005e26:	557d                	li	a0,-1
    80005e28:	a005                	j	80005e48 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005e2a:	854a                	mv	a0,s2
    80005e2c:	ffffe097          	auipc	ra,0xffffe
    80005e30:	2ea080e7          	jalr	746(ra) # 80004116 <iunlockput>
  iunlockput(dp);
    80005e34:	8526                	mv	a0,s1
    80005e36:	ffffe097          	auipc	ra,0xffffe
    80005e3a:	2e0080e7          	jalr	736(ra) # 80004116 <iunlockput>
  end_op();
    80005e3e:	fffff097          	auipc	ra,0xfffff
    80005e42:	ab8080e7          	jalr	-1352(ra) # 800048f6 <end_op>
  return -1;
    80005e46:	557d                	li	a0,-1
}
    80005e48:	70ae                	ld	ra,232(sp)
    80005e4a:	740e                	ld	s0,224(sp)
    80005e4c:	64ee                	ld	s1,216(sp)
    80005e4e:	694e                	ld	s2,208(sp)
    80005e50:	69ae                	ld	s3,200(sp)
    80005e52:	616d                	addi	sp,sp,240
    80005e54:	8082                	ret

0000000080005e56 <sys_open>:

uint64
sys_open(void)
{
    80005e56:	7131                	addi	sp,sp,-192
    80005e58:	fd06                	sd	ra,184(sp)
    80005e5a:	f922                	sd	s0,176(sp)
    80005e5c:	f526                	sd	s1,168(sp)
    80005e5e:	f14a                	sd	s2,160(sp)
    80005e60:	ed4e                	sd	s3,152(sp)
    80005e62:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005e64:	f4c40593          	addi	a1,s0,-180
    80005e68:	4505                	li	a0,1
    80005e6a:	ffffd097          	auipc	ra,0xffffd
    80005e6e:	238080e7          	jalr	568(ra) # 800030a2 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005e72:	08000613          	li	a2,128
    80005e76:	f5040593          	addi	a1,s0,-176
    80005e7a:	4501                	li	a0,0
    80005e7c:	ffffd097          	auipc	ra,0xffffd
    80005e80:	26a080e7          	jalr	618(ra) # 800030e6 <argstr>
    80005e84:	87aa                	mv	a5,a0
    return -1;
    80005e86:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005e88:	0a07c963          	bltz	a5,80005f3a <sys_open+0xe4>

  begin_op();
    80005e8c:	fffff097          	auipc	ra,0xfffff
    80005e90:	9ea080e7          	jalr	-1558(ra) # 80004876 <begin_op>

  if(omode & O_CREATE){
    80005e94:	f4c42783          	lw	a5,-180(s0)
    80005e98:	2007f793          	andi	a5,a5,512
    80005e9c:	cfc5                	beqz	a5,80005f54 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005e9e:	4681                	li	a3,0
    80005ea0:	4601                	li	a2,0
    80005ea2:	4589                	li	a1,2
    80005ea4:	f5040513          	addi	a0,s0,-176
    80005ea8:	00000097          	auipc	ra,0x0
    80005eac:	976080e7          	jalr	-1674(ra) # 8000581e <create>
    80005eb0:	84aa                	mv	s1,a0
    if(ip == 0){
    80005eb2:	c959                	beqz	a0,80005f48 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005eb4:	04449703          	lh	a4,68(s1)
    80005eb8:	478d                	li	a5,3
    80005eba:	00f71763          	bne	a4,a5,80005ec8 <sys_open+0x72>
    80005ebe:	0464d703          	lhu	a4,70(s1)
    80005ec2:	47a5                	li	a5,9
    80005ec4:	0ce7ed63          	bltu	a5,a4,80005f9e <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005ec8:	fffff097          	auipc	ra,0xfffff
    80005ecc:	dbe080e7          	jalr	-578(ra) # 80004c86 <filealloc>
    80005ed0:	89aa                	mv	s3,a0
    80005ed2:	10050363          	beqz	a0,80005fd8 <sys_open+0x182>
    80005ed6:	00000097          	auipc	ra,0x0
    80005eda:	906080e7          	jalr	-1786(ra) # 800057dc <fdalloc>
    80005ede:	892a                	mv	s2,a0
    80005ee0:	0e054763          	bltz	a0,80005fce <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005ee4:	04449703          	lh	a4,68(s1)
    80005ee8:	478d                	li	a5,3
    80005eea:	0cf70563          	beq	a4,a5,80005fb4 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005eee:	4789                	li	a5,2
    80005ef0:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005ef4:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005ef8:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005efc:	f4c42783          	lw	a5,-180(s0)
    80005f00:	0017c713          	xori	a4,a5,1
    80005f04:	8b05                	andi	a4,a4,1
    80005f06:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005f0a:	0037f713          	andi	a4,a5,3
    80005f0e:	00e03733          	snez	a4,a4
    80005f12:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005f16:	4007f793          	andi	a5,a5,1024
    80005f1a:	c791                	beqz	a5,80005f26 <sys_open+0xd0>
    80005f1c:	04449703          	lh	a4,68(s1)
    80005f20:	4789                	li	a5,2
    80005f22:	0af70063          	beq	a4,a5,80005fc2 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005f26:	8526                	mv	a0,s1
    80005f28:	ffffe097          	auipc	ra,0xffffe
    80005f2c:	04e080e7          	jalr	78(ra) # 80003f76 <iunlock>
  end_op();
    80005f30:	fffff097          	auipc	ra,0xfffff
    80005f34:	9c6080e7          	jalr	-1594(ra) # 800048f6 <end_op>

  return fd;
    80005f38:	854a                	mv	a0,s2
}
    80005f3a:	70ea                	ld	ra,184(sp)
    80005f3c:	744a                	ld	s0,176(sp)
    80005f3e:	74aa                	ld	s1,168(sp)
    80005f40:	790a                	ld	s2,160(sp)
    80005f42:	69ea                	ld	s3,152(sp)
    80005f44:	6129                	addi	sp,sp,192
    80005f46:	8082                	ret
      end_op();
    80005f48:	fffff097          	auipc	ra,0xfffff
    80005f4c:	9ae080e7          	jalr	-1618(ra) # 800048f6 <end_op>
      return -1;
    80005f50:	557d                	li	a0,-1
    80005f52:	b7e5                	j	80005f3a <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005f54:	f5040513          	addi	a0,s0,-176
    80005f58:	ffffe097          	auipc	ra,0xffffe
    80005f5c:	702080e7          	jalr	1794(ra) # 8000465a <namei>
    80005f60:	84aa                	mv	s1,a0
    80005f62:	c905                	beqz	a0,80005f92 <sys_open+0x13c>
    ilock(ip);
    80005f64:	ffffe097          	auipc	ra,0xffffe
    80005f68:	f50080e7          	jalr	-176(ra) # 80003eb4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005f6c:	04449703          	lh	a4,68(s1)
    80005f70:	4785                	li	a5,1
    80005f72:	f4f711e3          	bne	a4,a5,80005eb4 <sys_open+0x5e>
    80005f76:	f4c42783          	lw	a5,-180(s0)
    80005f7a:	d7b9                	beqz	a5,80005ec8 <sys_open+0x72>
      iunlockput(ip);
    80005f7c:	8526                	mv	a0,s1
    80005f7e:	ffffe097          	auipc	ra,0xffffe
    80005f82:	198080e7          	jalr	408(ra) # 80004116 <iunlockput>
      end_op();
    80005f86:	fffff097          	auipc	ra,0xfffff
    80005f8a:	970080e7          	jalr	-1680(ra) # 800048f6 <end_op>
      return -1;
    80005f8e:	557d                	li	a0,-1
    80005f90:	b76d                	j	80005f3a <sys_open+0xe4>
      end_op();
    80005f92:	fffff097          	auipc	ra,0xfffff
    80005f96:	964080e7          	jalr	-1692(ra) # 800048f6 <end_op>
      return -1;
    80005f9a:	557d                	li	a0,-1
    80005f9c:	bf79                	j	80005f3a <sys_open+0xe4>
    iunlockput(ip);
    80005f9e:	8526                	mv	a0,s1
    80005fa0:	ffffe097          	auipc	ra,0xffffe
    80005fa4:	176080e7          	jalr	374(ra) # 80004116 <iunlockput>
    end_op();
    80005fa8:	fffff097          	auipc	ra,0xfffff
    80005fac:	94e080e7          	jalr	-1714(ra) # 800048f6 <end_op>
    return -1;
    80005fb0:	557d                	li	a0,-1
    80005fb2:	b761                	j	80005f3a <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005fb4:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005fb8:	04649783          	lh	a5,70(s1)
    80005fbc:	02f99223          	sh	a5,36(s3)
    80005fc0:	bf25                	j	80005ef8 <sys_open+0xa2>
    itrunc(ip);
    80005fc2:	8526                	mv	a0,s1
    80005fc4:	ffffe097          	auipc	ra,0xffffe
    80005fc8:	ffe080e7          	jalr	-2(ra) # 80003fc2 <itrunc>
    80005fcc:	bfa9                	j	80005f26 <sys_open+0xd0>
      fileclose(f);
    80005fce:	854e                	mv	a0,s3
    80005fd0:	fffff097          	auipc	ra,0xfffff
    80005fd4:	d72080e7          	jalr	-654(ra) # 80004d42 <fileclose>
    iunlockput(ip);
    80005fd8:	8526                	mv	a0,s1
    80005fda:	ffffe097          	auipc	ra,0xffffe
    80005fde:	13c080e7          	jalr	316(ra) # 80004116 <iunlockput>
    end_op();
    80005fe2:	fffff097          	auipc	ra,0xfffff
    80005fe6:	914080e7          	jalr	-1772(ra) # 800048f6 <end_op>
    return -1;
    80005fea:	557d                	li	a0,-1
    80005fec:	b7b9                	j	80005f3a <sys_open+0xe4>

0000000080005fee <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005fee:	7175                	addi	sp,sp,-144
    80005ff0:	e506                	sd	ra,136(sp)
    80005ff2:	e122                	sd	s0,128(sp)
    80005ff4:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005ff6:	fffff097          	auipc	ra,0xfffff
    80005ffa:	880080e7          	jalr	-1920(ra) # 80004876 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005ffe:	08000613          	li	a2,128
    80006002:	f7040593          	addi	a1,s0,-144
    80006006:	4501                	li	a0,0
    80006008:	ffffd097          	auipc	ra,0xffffd
    8000600c:	0de080e7          	jalr	222(ra) # 800030e6 <argstr>
    80006010:	02054963          	bltz	a0,80006042 <sys_mkdir+0x54>
    80006014:	4681                	li	a3,0
    80006016:	4601                	li	a2,0
    80006018:	4585                	li	a1,1
    8000601a:	f7040513          	addi	a0,s0,-144
    8000601e:	00000097          	auipc	ra,0x0
    80006022:	800080e7          	jalr	-2048(ra) # 8000581e <create>
    80006026:	cd11                	beqz	a0,80006042 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006028:	ffffe097          	auipc	ra,0xffffe
    8000602c:	0ee080e7          	jalr	238(ra) # 80004116 <iunlockput>
  end_op();
    80006030:	fffff097          	auipc	ra,0xfffff
    80006034:	8c6080e7          	jalr	-1850(ra) # 800048f6 <end_op>
  return 0;
    80006038:	4501                	li	a0,0
}
    8000603a:	60aa                	ld	ra,136(sp)
    8000603c:	640a                	ld	s0,128(sp)
    8000603e:	6149                	addi	sp,sp,144
    80006040:	8082                	ret
    end_op();
    80006042:	fffff097          	auipc	ra,0xfffff
    80006046:	8b4080e7          	jalr	-1868(ra) # 800048f6 <end_op>
    return -1;
    8000604a:	557d                	li	a0,-1
    8000604c:	b7fd                	j	8000603a <sys_mkdir+0x4c>

000000008000604e <sys_mknod>:

uint64
sys_mknod(void)
{
    8000604e:	7135                	addi	sp,sp,-160
    80006050:	ed06                	sd	ra,152(sp)
    80006052:	e922                	sd	s0,144(sp)
    80006054:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80006056:	fffff097          	auipc	ra,0xfffff
    8000605a:	820080e7          	jalr	-2016(ra) # 80004876 <begin_op>
  argint(1, &major);
    8000605e:	f6c40593          	addi	a1,s0,-148
    80006062:	4505                	li	a0,1
    80006064:	ffffd097          	auipc	ra,0xffffd
    80006068:	03e080e7          	jalr	62(ra) # 800030a2 <argint>
  argint(2, &minor);
    8000606c:	f6840593          	addi	a1,s0,-152
    80006070:	4509                	li	a0,2
    80006072:	ffffd097          	auipc	ra,0xffffd
    80006076:	030080e7          	jalr	48(ra) # 800030a2 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000607a:	08000613          	li	a2,128
    8000607e:	f7040593          	addi	a1,s0,-144
    80006082:	4501                	li	a0,0
    80006084:	ffffd097          	auipc	ra,0xffffd
    80006088:	062080e7          	jalr	98(ra) # 800030e6 <argstr>
    8000608c:	02054b63          	bltz	a0,800060c2 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80006090:	f6841683          	lh	a3,-152(s0)
    80006094:	f6c41603          	lh	a2,-148(s0)
    80006098:	458d                	li	a1,3
    8000609a:	f7040513          	addi	a0,s0,-144
    8000609e:	fffff097          	auipc	ra,0xfffff
    800060a2:	780080e7          	jalr	1920(ra) # 8000581e <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800060a6:	cd11                	beqz	a0,800060c2 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800060a8:	ffffe097          	auipc	ra,0xffffe
    800060ac:	06e080e7          	jalr	110(ra) # 80004116 <iunlockput>
  end_op();
    800060b0:	fffff097          	auipc	ra,0xfffff
    800060b4:	846080e7          	jalr	-1978(ra) # 800048f6 <end_op>
  return 0;
    800060b8:	4501                	li	a0,0
}
    800060ba:	60ea                	ld	ra,152(sp)
    800060bc:	644a                	ld	s0,144(sp)
    800060be:	610d                	addi	sp,sp,160
    800060c0:	8082                	ret
    end_op();
    800060c2:	fffff097          	auipc	ra,0xfffff
    800060c6:	834080e7          	jalr	-1996(ra) # 800048f6 <end_op>
    return -1;
    800060ca:	557d                	li	a0,-1
    800060cc:	b7fd                	j	800060ba <sys_mknod+0x6c>

00000000800060ce <sys_chdir>:

uint64
sys_chdir(void)
{
    800060ce:	7135                	addi	sp,sp,-160
    800060d0:	ed06                	sd	ra,152(sp)
    800060d2:	e922                	sd	s0,144(sp)
    800060d4:	e526                	sd	s1,136(sp)
    800060d6:	e14a                	sd	s2,128(sp)
    800060d8:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800060da:	ffffc097          	auipc	ra,0xffffc
    800060de:	8d2080e7          	jalr	-1838(ra) # 800019ac <myproc>
    800060e2:	892a                	mv	s2,a0
  
  begin_op();
    800060e4:	ffffe097          	auipc	ra,0xffffe
    800060e8:	792080e7          	jalr	1938(ra) # 80004876 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800060ec:	08000613          	li	a2,128
    800060f0:	f6040593          	addi	a1,s0,-160
    800060f4:	4501                	li	a0,0
    800060f6:	ffffd097          	auipc	ra,0xffffd
    800060fa:	ff0080e7          	jalr	-16(ra) # 800030e6 <argstr>
    800060fe:	04054b63          	bltz	a0,80006154 <sys_chdir+0x86>
    80006102:	f6040513          	addi	a0,s0,-160
    80006106:	ffffe097          	auipc	ra,0xffffe
    8000610a:	554080e7          	jalr	1364(ra) # 8000465a <namei>
    8000610e:	84aa                	mv	s1,a0
    80006110:	c131                	beqz	a0,80006154 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006112:	ffffe097          	auipc	ra,0xffffe
    80006116:	da2080e7          	jalr	-606(ra) # 80003eb4 <ilock>
  if(ip->type != T_DIR){
    8000611a:	04449703          	lh	a4,68(s1)
    8000611e:	4785                	li	a5,1
    80006120:	04f71063          	bne	a4,a5,80006160 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006124:	8526                	mv	a0,s1
    80006126:	ffffe097          	auipc	ra,0xffffe
    8000612a:	e50080e7          	jalr	-432(ra) # 80003f76 <iunlock>
  iput(p->cwd);
    8000612e:	15093503          	ld	a0,336(s2)
    80006132:	ffffe097          	auipc	ra,0xffffe
    80006136:	f3c080e7          	jalr	-196(ra) # 8000406e <iput>
  end_op();
    8000613a:	ffffe097          	auipc	ra,0xffffe
    8000613e:	7bc080e7          	jalr	1980(ra) # 800048f6 <end_op>
  p->cwd = ip;
    80006142:	14993823          	sd	s1,336(s2)
  return 0;
    80006146:	4501                	li	a0,0
}
    80006148:	60ea                	ld	ra,152(sp)
    8000614a:	644a                	ld	s0,144(sp)
    8000614c:	64aa                	ld	s1,136(sp)
    8000614e:	690a                	ld	s2,128(sp)
    80006150:	610d                	addi	sp,sp,160
    80006152:	8082                	ret
    end_op();
    80006154:	ffffe097          	auipc	ra,0xffffe
    80006158:	7a2080e7          	jalr	1954(ra) # 800048f6 <end_op>
    return -1;
    8000615c:	557d                	li	a0,-1
    8000615e:	b7ed                	j	80006148 <sys_chdir+0x7a>
    iunlockput(ip);
    80006160:	8526                	mv	a0,s1
    80006162:	ffffe097          	auipc	ra,0xffffe
    80006166:	fb4080e7          	jalr	-76(ra) # 80004116 <iunlockput>
    end_op();
    8000616a:	ffffe097          	auipc	ra,0xffffe
    8000616e:	78c080e7          	jalr	1932(ra) # 800048f6 <end_op>
    return -1;
    80006172:	557d                	li	a0,-1
    80006174:	bfd1                	j	80006148 <sys_chdir+0x7a>

0000000080006176 <sys_exec>:

uint64
sys_exec(void)
{
    80006176:	7145                	addi	sp,sp,-464
    80006178:	e786                	sd	ra,456(sp)
    8000617a:	e3a2                	sd	s0,448(sp)
    8000617c:	ff26                	sd	s1,440(sp)
    8000617e:	fb4a                	sd	s2,432(sp)
    80006180:	f74e                	sd	s3,424(sp)
    80006182:	f352                	sd	s4,416(sp)
    80006184:	ef56                	sd	s5,408(sp)
    80006186:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80006188:	e3840593          	addi	a1,s0,-456
    8000618c:	4505                	li	a0,1
    8000618e:	ffffd097          	auipc	ra,0xffffd
    80006192:	f36080e7          	jalr	-202(ra) # 800030c4 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80006196:	08000613          	li	a2,128
    8000619a:	f4040593          	addi	a1,s0,-192
    8000619e:	4501                	li	a0,0
    800061a0:	ffffd097          	auipc	ra,0xffffd
    800061a4:	f46080e7          	jalr	-186(ra) # 800030e6 <argstr>
    800061a8:	87aa                	mv	a5,a0
    return -1;
    800061aa:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800061ac:	0c07c263          	bltz	a5,80006270 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    800061b0:	10000613          	li	a2,256
    800061b4:	4581                	li	a1,0
    800061b6:	e4040513          	addi	a0,s0,-448
    800061ba:	ffffb097          	auipc	ra,0xffffb
    800061be:	b18080e7          	jalr	-1256(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800061c2:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800061c6:	89a6                	mv	s3,s1
    800061c8:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800061ca:	02000a13          	li	s4,32
    800061ce:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800061d2:	00391793          	slli	a5,s2,0x3
    800061d6:	e3040593          	addi	a1,s0,-464
    800061da:	e3843503          	ld	a0,-456(s0)
    800061de:	953e                	add	a0,a0,a5
    800061e0:	ffffd097          	auipc	ra,0xffffd
    800061e4:	e24080e7          	jalr	-476(ra) # 80003004 <fetchaddr>
    800061e8:	02054a63          	bltz	a0,8000621c <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    800061ec:	e3043783          	ld	a5,-464(s0)
    800061f0:	c3b9                	beqz	a5,80006236 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800061f2:	ffffb097          	auipc	ra,0xffffb
    800061f6:	8f4080e7          	jalr	-1804(ra) # 80000ae6 <kalloc>
    800061fa:	85aa                	mv	a1,a0
    800061fc:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006200:	cd11                	beqz	a0,8000621c <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006202:	6605                	lui	a2,0x1
    80006204:	e3043503          	ld	a0,-464(s0)
    80006208:	ffffd097          	auipc	ra,0xffffd
    8000620c:	e4e080e7          	jalr	-434(ra) # 80003056 <fetchstr>
    80006210:	00054663          	bltz	a0,8000621c <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80006214:	0905                	addi	s2,s2,1
    80006216:	09a1                	addi	s3,s3,8
    80006218:	fb491be3          	bne	s2,s4,800061ce <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000621c:	10048913          	addi	s2,s1,256
    80006220:	6088                	ld	a0,0(s1)
    80006222:	c531                	beqz	a0,8000626e <sys_exec+0xf8>
    kfree(argv[i]);
    80006224:	ffffa097          	auipc	ra,0xffffa
    80006228:	7c6080e7          	jalr	1990(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000622c:	04a1                	addi	s1,s1,8
    8000622e:	ff2499e3          	bne	s1,s2,80006220 <sys_exec+0xaa>
  return -1;
    80006232:	557d                	li	a0,-1
    80006234:	a835                	j	80006270 <sys_exec+0xfa>
      argv[i] = 0;
    80006236:	0a8e                	slli	s5,s5,0x3
    80006238:	fc040793          	addi	a5,s0,-64
    8000623c:	9abe                	add	s5,s5,a5
    8000623e:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80006242:	e4040593          	addi	a1,s0,-448
    80006246:	f4040513          	addi	a0,s0,-192
    8000624a:	fffff097          	auipc	ra,0xfffff
    8000624e:	172080e7          	jalr	370(ra) # 800053bc <exec>
    80006252:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006254:	10048993          	addi	s3,s1,256
    80006258:	6088                	ld	a0,0(s1)
    8000625a:	c901                	beqz	a0,8000626a <sys_exec+0xf4>
    kfree(argv[i]);
    8000625c:	ffffa097          	auipc	ra,0xffffa
    80006260:	78e080e7          	jalr	1934(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006264:	04a1                	addi	s1,s1,8
    80006266:	ff3499e3          	bne	s1,s3,80006258 <sys_exec+0xe2>
  return ret;
    8000626a:	854a                	mv	a0,s2
    8000626c:	a011                	j	80006270 <sys_exec+0xfa>
  return -1;
    8000626e:	557d                	li	a0,-1
}
    80006270:	60be                	ld	ra,456(sp)
    80006272:	641e                	ld	s0,448(sp)
    80006274:	74fa                	ld	s1,440(sp)
    80006276:	795a                	ld	s2,432(sp)
    80006278:	79ba                	ld	s3,424(sp)
    8000627a:	7a1a                	ld	s4,416(sp)
    8000627c:	6afa                	ld	s5,408(sp)
    8000627e:	6179                	addi	sp,sp,464
    80006280:	8082                	ret

0000000080006282 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006282:	7139                	addi	sp,sp,-64
    80006284:	fc06                	sd	ra,56(sp)
    80006286:	f822                	sd	s0,48(sp)
    80006288:	f426                	sd	s1,40(sp)
    8000628a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000628c:	ffffb097          	auipc	ra,0xffffb
    80006290:	720080e7          	jalr	1824(ra) # 800019ac <myproc>
    80006294:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80006296:	fd840593          	addi	a1,s0,-40
    8000629a:	4501                	li	a0,0
    8000629c:	ffffd097          	auipc	ra,0xffffd
    800062a0:	e28080e7          	jalr	-472(ra) # 800030c4 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800062a4:	fc840593          	addi	a1,s0,-56
    800062a8:	fd040513          	addi	a0,s0,-48
    800062ac:	fffff097          	auipc	ra,0xfffff
    800062b0:	dc6080e7          	jalr	-570(ra) # 80005072 <pipealloc>
    return -1;
    800062b4:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800062b6:	0c054463          	bltz	a0,8000637e <sys_pipe+0xfc>
  fd0 = -1;
    800062ba:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800062be:	fd043503          	ld	a0,-48(s0)
    800062c2:	fffff097          	auipc	ra,0xfffff
    800062c6:	51a080e7          	jalr	1306(ra) # 800057dc <fdalloc>
    800062ca:	fca42223          	sw	a0,-60(s0)
    800062ce:	08054b63          	bltz	a0,80006364 <sys_pipe+0xe2>
    800062d2:	fc843503          	ld	a0,-56(s0)
    800062d6:	fffff097          	auipc	ra,0xfffff
    800062da:	506080e7          	jalr	1286(ra) # 800057dc <fdalloc>
    800062de:	fca42023          	sw	a0,-64(s0)
    800062e2:	06054863          	bltz	a0,80006352 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800062e6:	4691                	li	a3,4
    800062e8:	fc440613          	addi	a2,s0,-60
    800062ec:	fd843583          	ld	a1,-40(s0)
    800062f0:	68a8                	ld	a0,80(s1)
    800062f2:	ffffb097          	auipc	ra,0xffffb
    800062f6:	376080e7          	jalr	886(ra) # 80001668 <copyout>
    800062fa:	02054063          	bltz	a0,8000631a <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800062fe:	4691                	li	a3,4
    80006300:	fc040613          	addi	a2,s0,-64
    80006304:	fd843583          	ld	a1,-40(s0)
    80006308:	0591                	addi	a1,a1,4
    8000630a:	68a8                	ld	a0,80(s1)
    8000630c:	ffffb097          	auipc	ra,0xffffb
    80006310:	35c080e7          	jalr	860(ra) # 80001668 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006314:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006316:	06055463          	bgez	a0,8000637e <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    8000631a:	fc442783          	lw	a5,-60(s0)
    8000631e:	07e9                	addi	a5,a5,26
    80006320:	078e                	slli	a5,a5,0x3
    80006322:	97a6                	add	a5,a5,s1
    80006324:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006328:	fc042503          	lw	a0,-64(s0)
    8000632c:	0569                	addi	a0,a0,26
    8000632e:	050e                	slli	a0,a0,0x3
    80006330:	94aa                	add	s1,s1,a0
    80006332:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80006336:	fd043503          	ld	a0,-48(s0)
    8000633a:	fffff097          	auipc	ra,0xfffff
    8000633e:	a08080e7          	jalr	-1528(ra) # 80004d42 <fileclose>
    fileclose(wf);
    80006342:	fc843503          	ld	a0,-56(s0)
    80006346:	fffff097          	auipc	ra,0xfffff
    8000634a:	9fc080e7          	jalr	-1540(ra) # 80004d42 <fileclose>
    return -1;
    8000634e:	57fd                	li	a5,-1
    80006350:	a03d                	j	8000637e <sys_pipe+0xfc>
    if(fd0 >= 0)
    80006352:	fc442783          	lw	a5,-60(s0)
    80006356:	0007c763          	bltz	a5,80006364 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    8000635a:	07e9                	addi	a5,a5,26
    8000635c:	078e                	slli	a5,a5,0x3
    8000635e:	94be                	add	s1,s1,a5
    80006360:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80006364:	fd043503          	ld	a0,-48(s0)
    80006368:	fffff097          	auipc	ra,0xfffff
    8000636c:	9da080e7          	jalr	-1574(ra) # 80004d42 <fileclose>
    fileclose(wf);
    80006370:	fc843503          	ld	a0,-56(s0)
    80006374:	fffff097          	auipc	ra,0xfffff
    80006378:	9ce080e7          	jalr	-1586(ra) # 80004d42 <fileclose>
    return -1;
    8000637c:	57fd                	li	a5,-1
}
    8000637e:	853e                	mv	a0,a5
    80006380:	70e2                	ld	ra,56(sp)
    80006382:	7442                	ld	s0,48(sp)
    80006384:	74a2                	ld	s1,40(sp)
    80006386:	6121                	addi	sp,sp,64
    80006388:	8082                	ret
    8000638a:	0000                	unimp
    8000638c:	0000                	unimp
	...

0000000080006390 <kernelvec>:
    80006390:	7111                	addi	sp,sp,-256
    80006392:	e006                	sd	ra,0(sp)
    80006394:	e40a                	sd	sp,8(sp)
    80006396:	e80e                	sd	gp,16(sp)
    80006398:	ec12                	sd	tp,24(sp)
    8000639a:	f016                	sd	t0,32(sp)
    8000639c:	f41a                	sd	t1,40(sp)
    8000639e:	f81e                	sd	t2,48(sp)
    800063a0:	fc22                	sd	s0,56(sp)
    800063a2:	e0a6                	sd	s1,64(sp)
    800063a4:	e4aa                	sd	a0,72(sp)
    800063a6:	e8ae                	sd	a1,80(sp)
    800063a8:	ecb2                	sd	a2,88(sp)
    800063aa:	f0b6                	sd	a3,96(sp)
    800063ac:	f4ba                	sd	a4,104(sp)
    800063ae:	f8be                	sd	a5,112(sp)
    800063b0:	fcc2                	sd	a6,120(sp)
    800063b2:	e146                	sd	a7,128(sp)
    800063b4:	e54a                	sd	s2,136(sp)
    800063b6:	e94e                	sd	s3,144(sp)
    800063b8:	ed52                	sd	s4,152(sp)
    800063ba:	f156                	sd	s5,160(sp)
    800063bc:	f55a                	sd	s6,168(sp)
    800063be:	f95e                	sd	s7,176(sp)
    800063c0:	fd62                	sd	s8,184(sp)
    800063c2:	e1e6                	sd	s9,192(sp)
    800063c4:	e5ea                	sd	s10,200(sp)
    800063c6:	e9ee                	sd	s11,208(sp)
    800063c8:	edf2                	sd	t3,216(sp)
    800063ca:	f1f6                	sd	t4,224(sp)
    800063cc:	f5fa                	sd	t5,232(sp)
    800063ce:	f9fe                	sd	t6,240(sp)
    800063d0:	b01fc0ef          	jal	ra,80002ed0 <kerneltrap>
    800063d4:	6082                	ld	ra,0(sp)
    800063d6:	6122                	ld	sp,8(sp)
    800063d8:	61c2                	ld	gp,16(sp)
    800063da:	7282                	ld	t0,32(sp)
    800063dc:	7322                	ld	t1,40(sp)
    800063de:	73c2                	ld	t2,48(sp)
    800063e0:	7462                	ld	s0,56(sp)
    800063e2:	6486                	ld	s1,64(sp)
    800063e4:	6526                	ld	a0,72(sp)
    800063e6:	65c6                	ld	a1,80(sp)
    800063e8:	6666                	ld	a2,88(sp)
    800063ea:	7686                	ld	a3,96(sp)
    800063ec:	7726                	ld	a4,104(sp)
    800063ee:	77c6                	ld	a5,112(sp)
    800063f0:	7866                	ld	a6,120(sp)
    800063f2:	688a                	ld	a7,128(sp)
    800063f4:	692a                	ld	s2,136(sp)
    800063f6:	69ca                	ld	s3,144(sp)
    800063f8:	6a6a                	ld	s4,152(sp)
    800063fa:	7a8a                	ld	s5,160(sp)
    800063fc:	7b2a                	ld	s6,168(sp)
    800063fe:	7bca                	ld	s7,176(sp)
    80006400:	7c6a                	ld	s8,184(sp)
    80006402:	6c8e                	ld	s9,192(sp)
    80006404:	6d2e                	ld	s10,200(sp)
    80006406:	6dce                	ld	s11,208(sp)
    80006408:	6e6e                	ld	t3,216(sp)
    8000640a:	7e8e                	ld	t4,224(sp)
    8000640c:	7f2e                	ld	t5,232(sp)
    8000640e:	7fce                	ld	t6,240(sp)
    80006410:	6111                	addi	sp,sp,256
    80006412:	10200073          	sret
    80006416:	00000013          	nop
    8000641a:	00000013          	nop
    8000641e:	0001                	nop

0000000080006420 <timervec>:
    80006420:	34051573          	csrrw	a0,mscratch,a0
    80006424:	e10c                	sd	a1,0(a0)
    80006426:	e510                	sd	a2,8(a0)
    80006428:	e914                	sd	a3,16(a0)
    8000642a:	6d0c                	ld	a1,24(a0)
    8000642c:	7110                	ld	a2,32(a0)
    8000642e:	6194                	ld	a3,0(a1)
    80006430:	96b2                	add	a3,a3,a2
    80006432:	e194                	sd	a3,0(a1)
    80006434:	4589                	li	a1,2
    80006436:	14459073          	csrw	sip,a1
    8000643a:	6914                	ld	a3,16(a0)
    8000643c:	6510                	ld	a2,8(a0)
    8000643e:	610c                	ld	a1,0(a0)
    80006440:	34051573          	csrrw	a0,mscratch,a0
    80006444:	30200073          	mret
	...

000000008000644a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000644a:	1141                	addi	sp,sp,-16
    8000644c:	e422                	sd	s0,8(sp)
    8000644e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006450:	0c0007b7          	lui	a5,0xc000
    80006454:	4705                	li	a4,1
    80006456:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006458:	c3d8                	sw	a4,4(a5)
}
    8000645a:	6422                	ld	s0,8(sp)
    8000645c:	0141                	addi	sp,sp,16
    8000645e:	8082                	ret

0000000080006460 <plicinithart>:

void
plicinithart(void)
{
    80006460:	1141                	addi	sp,sp,-16
    80006462:	e406                	sd	ra,8(sp)
    80006464:	e022                	sd	s0,0(sp)
    80006466:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006468:	ffffb097          	auipc	ra,0xffffb
    8000646c:	518080e7          	jalr	1304(ra) # 80001980 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006470:	0085171b          	slliw	a4,a0,0x8
    80006474:	0c0027b7          	lui	a5,0xc002
    80006478:	97ba                	add	a5,a5,a4
    8000647a:	40200713          	li	a4,1026
    8000647e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006482:	00d5151b          	slliw	a0,a0,0xd
    80006486:	0c2017b7          	lui	a5,0xc201
    8000648a:	953e                	add	a0,a0,a5
    8000648c:	00052023          	sw	zero,0(a0)
}
    80006490:	60a2                	ld	ra,8(sp)
    80006492:	6402                	ld	s0,0(sp)
    80006494:	0141                	addi	sp,sp,16
    80006496:	8082                	ret

0000000080006498 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006498:	1141                	addi	sp,sp,-16
    8000649a:	e406                	sd	ra,8(sp)
    8000649c:	e022                	sd	s0,0(sp)
    8000649e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800064a0:	ffffb097          	auipc	ra,0xffffb
    800064a4:	4e0080e7          	jalr	1248(ra) # 80001980 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800064a8:	00d5179b          	slliw	a5,a0,0xd
    800064ac:	0c201537          	lui	a0,0xc201
    800064b0:	953e                	add	a0,a0,a5
  return irq;
}
    800064b2:	4148                	lw	a0,4(a0)
    800064b4:	60a2                	ld	ra,8(sp)
    800064b6:	6402                	ld	s0,0(sp)
    800064b8:	0141                	addi	sp,sp,16
    800064ba:	8082                	ret

00000000800064bc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800064bc:	1101                	addi	sp,sp,-32
    800064be:	ec06                	sd	ra,24(sp)
    800064c0:	e822                	sd	s0,16(sp)
    800064c2:	e426                	sd	s1,8(sp)
    800064c4:	1000                	addi	s0,sp,32
    800064c6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800064c8:	ffffb097          	auipc	ra,0xffffb
    800064cc:	4b8080e7          	jalr	1208(ra) # 80001980 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800064d0:	00d5151b          	slliw	a0,a0,0xd
    800064d4:	0c2017b7          	lui	a5,0xc201
    800064d8:	97aa                	add	a5,a5,a0
    800064da:	c3c4                	sw	s1,4(a5)
}
    800064dc:	60e2                	ld	ra,24(sp)
    800064de:	6442                	ld	s0,16(sp)
    800064e0:	64a2                	ld	s1,8(sp)
    800064e2:	6105                	addi	sp,sp,32
    800064e4:	8082                	ret

00000000800064e6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800064e6:	1141                	addi	sp,sp,-16
    800064e8:	e406                	sd	ra,8(sp)
    800064ea:	e022                	sd	s0,0(sp)
    800064ec:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800064ee:	479d                	li	a5,7
    800064f0:	04a7cc63          	blt	a5,a0,80006548 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800064f4:	0001d797          	auipc	a5,0x1d
    800064f8:	76c78793          	addi	a5,a5,1900 # 80023c60 <disk>
    800064fc:	97aa                	add	a5,a5,a0
    800064fe:	0187c783          	lbu	a5,24(a5)
    80006502:	ebb9                	bnez	a5,80006558 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006504:	00451613          	slli	a2,a0,0x4
    80006508:	0001d797          	auipc	a5,0x1d
    8000650c:	75878793          	addi	a5,a5,1880 # 80023c60 <disk>
    80006510:	6394                	ld	a3,0(a5)
    80006512:	96b2                	add	a3,a3,a2
    80006514:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006518:	6398                	ld	a4,0(a5)
    8000651a:	9732                	add	a4,a4,a2
    8000651c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006520:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006524:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006528:	953e                	add	a0,a0,a5
    8000652a:	4785                	li	a5,1
    8000652c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006530:	0001d517          	auipc	a0,0x1d
    80006534:	74850513          	addi	a0,a0,1864 # 80023c78 <disk+0x18>
    80006538:	ffffc097          	auipc	ra,0xffffc
    8000653c:	076080e7          	jalr	118(ra) # 800025ae <wakeup>
}
    80006540:	60a2                	ld	ra,8(sp)
    80006542:	6402                	ld	s0,0(sp)
    80006544:	0141                	addi	sp,sp,16
    80006546:	8082                	ret
    panic("free_desc 1");
    80006548:	00002517          	auipc	a0,0x2
    8000654c:	34050513          	addi	a0,a0,832 # 80008888 <syscallnum+0x2a8>
    80006550:	ffffa097          	auipc	ra,0xffffa
    80006554:	fee080e7          	jalr	-18(ra) # 8000053e <panic>
    panic("free_desc 2");
    80006558:	00002517          	auipc	a0,0x2
    8000655c:	34050513          	addi	a0,a0,832 # 80008898 <syscallnum+0x2b8>
    80006560:	ffffa097          	auipc	ra,0xffffa
    80006564:	fde080e7          	jalr	-34(ra) # 8000053e <panic>

0000000080006568 <virtio_disk_init>:
{
    80006568:	1101                	addi	sp,sp,-32
    8000656a:	ec06                	sd	ra,24(sp)
    8000656c:	e822                	sd	s0,16(sp)
    8000656e:	e426                	sd	s1,8(sp)
    80006570:	e04a                	sd	s2,0(sp)
    80006572:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006574:	00002597          	auipc	a1,0x2
    80006578:	33458593          	addi	a1,a1,820 # 800088a8 <syscallnum+0x2c8>
    8000657c:	0001e517          	auipc	a0,0x1e
    80006580:	80c50513          	addi	a0,a0,-2036 # 80023d88 <disk+0x128>
    80006584:	ffffa097          	auipc	ra,0xffffa
    80006588:	5c2080e7          	jalr	1474(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000658c:	100017b7          	lui	a5,0x10001
    80006590:	4398                	lw	a4,0(a5)
    80006592:	2701                	sext.w	a4,a4
    80006594:	747277b7          	lui	a5,0x74727
    80006598:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000659c:	14f71c63          	bne	a4,a5,800066f4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800065a0:	100017b7          	lui	a5,0x10001
    800065a4:	43dc                	lw	a5,4(a5)
    800065a6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800065a8:	4709                	li	a4,2
    800065aa:	14e79563          	bne	a5,a4,800066f4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800065ae:	100017b7          	lui	a5,0x10001
    800065b2:	479c                	lw	a5,8(a5)
    800065b4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800065b6:	12e79f63          	bne	a5,a4,800066f4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800065ba:	100017b7          	lui	a5,0x10001
    800065be:	47d8                	lw	a4,12(a5)
    800065c0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800065c2:	554d47b7          	lui	a5,0x554d4
    800065c6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800065ca:	12f71563          	bne	a4,a5,800066f4 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    800065ce:	100017b7          	lui	a5,0x10001
    800065d2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800065d6:	4705                	li	a4,1
    800065d8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800065da:	470d                	li	a4,3
    800065dc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800065de:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800065e0:	c7ffe737          	lui	a4,0xc7ffe
    800065e4:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fda9bf>
    800065e8:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800065ea:	2701                	sext.w	a4,a4
    800065ec:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800065ee:	472d                	li	a4,11
    800065f0:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800065f2:	5bbc                	lw	a5,112(a5)
    800065f4:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800065f8:	8ba1                	andi	a5,a5,8
    800065fa:	10078563          	beqz	a5,80006704 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800065fe:	100017b7          	lui	a5,0x10001
    80006602:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006606:	43fc                	lw	a5,68(a5)
    80006608:	2781                	sext.w	a5,a5
    8000660a:	10079563          	bnez	a5,80006714 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000660e:	100017b7          	lui	a5,0x10001
    80006612:	5bdc                	lw	a5,52(a5)
    80006614:	2781                	sext.w	a5,a5
  if(max == 0)
    80006616:	10078763          	beqz	a5,80006724 <virtio_disk_init+0x1bc>
  if(max < NUM)
    8000661a:	471d                	li	a4,7
    8000661c:	10f77c63          	bgeu	a4,a5,80006734 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    80006620:	ffffa097          	auipc	ra,0xffffa
    80006624:	4c6080e7          	jalr	1222(ra) # 80000ae6 <kalloc>
    80006628:	0001d497          	auipc	s1,0x1d
    8000662c:	63848493          	addi	s1,s1,1592 # 80023c60 <disk>
    80006630:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006632:	ffffa097          	auipc	ra,0xffffa
    80006636:	4b4080e7          	jalr	1204(ra) # 80000ae6 <kalloc>
    8000663a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000663c:	ffffa097          	auipc	ra,0xffffa
    80006640:	4aa080e7          	jalr	1194(ra) # 80000ae6 <kalloc>
    80006644:	87aa                	mv	a5,a0
    80006646:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006648:	6088                	ld	a0,0(s1)
    8000664a:	cd6d                	beqz	a0,80006744 <virtio_disk_init+0x1dc>
    8000664c:	0001d717          	auipc	a4,0x1d
    80006650:	61c73703          	ld	a4,1564(a4) # 80023c68 <disk+0x8>
    80006654:	cb65                	beqz	a4,80006744 <virtio_disk_init+0x1dc>
    80006656:	c7fd                	beqz	a5,80006744 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    80006658:	6605                	lui	a2,0x1
    8000665a:	4581                	li	a1,0
    8000665c:	ffffa097          	auipc	ra,0xffffa
    80006660:	676080e7          	jalr	1654(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006664:	0001d497          	auipc	s1,0x1d
    80006668:	5fc48493          	addi	s1,s1,1532 # 80023c60 <disk>
    8000666c:	6605                	lui	a2,0x1
    8000666e:	4581                	li	a1,0
    80006670:	6488                	ld	a0,8(s1)
    80006672:	ffffa097          	auipc	ra,0xffffa
    80006676:	660080e7          	jalr	1632(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    8000667a:	6605                	lui	a2,0x1
    8000667c:	4581                	li	a1,0
    8000667e:	6888                	ld	a0,16(s1)
    80006680:	ffffa097          	auipc	ra,0xffffa
    80006684:	652080e7          	jalr	1618(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006688:	100017b7          	lui	a5,0x10001
    8000668c:	4721                	li	a4,8
    8000668e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006690:	4098                	lw	a4,0(s1)
    80006692:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006696:	40d8                	lw	a4,4(s1)
    80006698:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000669c:	6498                	ld	a4,8(s1)
    8000669e:	0007069b          	sext.w	a3,a4
    800066a2:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800066a6:	9701                	srai	a4,a4,0x20
    800066a8:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800066ac:	6898                	ld	a4,16(s1)
    800066ae:	0007069b          	sext.w	a3,a4
    800066b2:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800066b6:	9701                	srai	a4,a4,0x20
    800066b8:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800066bc:	4705                	li	a4,1
    800066be:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800066c0:	00e48c23          	sb	a4,24(s1)
    800066c4:	00e48ca3          	sb	a4,25(s1)
    800066c8:	00e48d23          	sb	a4,26(s1)
    800066cc:	00e48da3          	sb	a4,27(s1)
    800066d0:	00e48e23          	sb	a4,28(s1)
    800066d4:	00e48ea3          	sb	a4,29(s1)
    800066d8:	00e48f23          	sb	a4,30(s1)
    800066dc:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800066e0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800066e4:	0727a823          	sw	s2,112(a5)
}
    800066e8:	60e2                	ld	ra,24(sp)
    800066ea:	6442                	ld	s0,16(sp)
    800066ec:	64a2                	ld	s1,8(sp)
    800066ee:	6902                	ld	s2,0(sp)
    800066f0:	6105                	addi	sp,sp,32
    800066f2:	8082                	ret
    panic("could not find virtio disk");
    800066f4:	00002517          	auipc	a0,0x2
    800066f8:	1c450513          	addi	a0,a0,452 # 800088b8 <syscallnum+0x2d8>
    800066fc:	ffffa097          	auipc	ra,0xffffa
    80006700:	e42080e7          	jalr	-446(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    80006704:	00002517          	auipc	a0,0x2
    80006708:	1d450513          	addi	a0,a0,468 # 800088d8 <syscallnum+0x2f8>
    8000670c:	ffffa097          	auipc	ra,0xffffa
    80006710:	e32080e7          	jalr	-462(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    80006714:	00002517          	auipc	a0,0x2
    80006718:	1e450513          	addi	a0,a0,484 # 800088f8 <syscallnum+0x318>
    8000671c:	ffffa097          	auipc	ra,0xffffa
    80006720:	e22080e7          	jalr	-478(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    80006724:	00002517          	auipc	a0,0x2
    80006728:	1f450513          	addi	a0,a0,500 # 80008918 <syscallnum+0x338>
    8000672c:	ffffa097          	auipc	ra,0xffffa
    80006730:	e12080e7          	jalr	-494(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    80006734:	00002517          	auipc	a0,0x2
    80006738:	20450513          	addi	a0,a0,516 # 80008938 <syscallnum+0x358>
    8000673c:	ffffa097          	auipc	ra,0xffffa
    80006740:	e02080e7          	jalr	-510(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    80006744:	00002517          	auipc	a0,0x2
    80006748:	21450513          	addi	a0,a0,532 # 80008958 <syscallnum+0x378>
    8000674c:	ffffa097          	auipc	ra,0xffffa
    80006750:	df2080e7          	jalr	-526(ra) # 8000053e <panic>

0000000080006754 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006754:	7119                	addi	sp,sp,-128
    80006756:	fc86                	sd	ra,120(sp)
    80006758:	f8a2                	sd	s0,112(sp)
    8000675a:	f4a6                	sd	s1,104(sp)
    8000675c:	f0ca                	sd	s2,96(sp)
    8000675e:	ecce                	sd	s3,88(sp)
    80006760:	e8d2                	sd	s4,80(sp)
    80006762:	e4d6                	sd	s5,72(sp)
    80006764:	e0da                	sd	s6,64(sp)
    80006766:	fc5e                	sd	s7,56(sp)
    80006768:	f862                	sd	s8,48(sp)
    8000676a:	f466                	sd	s9,40(sp)
    8000676c:	f06a                	sd	s10,32(sp)
    8000676e:	ec6e                	sd	s11,24(sp)
    80006770:	0100                	addi	s0,sp,128
    80006772:	8aaa                	mv	s5,a0
    80006774:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006776:	00c52d03          	lw	s10,12(a0)
    8000677a:	001d1d1b          	slliw	s10,s10,0x1
    8000677e:	1d02                	slli	s10,s10,0x20
    80006780:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006784:	0001d517          	auipc	a0,0x1d
    80006788:	60450513          	addi	a0,a0,1540 # 80023d88 <disk+0x128>
    8000678c:	ffffa097          	auipc	ra,0xffffa
    80006790:	44a080e7          	jalr	1098(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80006794:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006796:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006798:	0001db97          	auipc	s7,0x1d
    8000679c:	4c8b8b93          	addi	s7,s7,1224 # 80023c60 <disk>
  for(int i = 0; i < 3; i++){
    800067a0:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800067a2:	0001dc97          	auipc	s9,0x1d
    800067a6:	5e6c8c93          	addi	s9,s9,1510 # 80023d88 <disk+0x128>
    800067aa:	a08d                	j	8000680c <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    800067ac:	00fb8733          	add	a4,s7,a5
    800067b0:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800067b4:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800067b6:	0207c563          	bltz	a5,800067e0 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800067ba:	2905                	addiw	s2,s2,1
    800067bc:	0611                	addi	a2,a2,4
    800067be:	05690c63          	beq	s2,s6,80006816 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    800067c2:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800067c4:	0001d717          	auipc	a4,0x1d
    800067c8:	49c70713          	addi	a4,a4,1180 # 80023c60 <disk>
    800067cc:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800067ce:	01874683          	lbu	a3,24(a4)
    800067d2:	fee9                	bnez	a3,800067ac <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800067d4:	2785                	addiw	a5,a5,1
    800067d6:	0705                	addi	a4,a4,1
    800067d8:	fe979be3          	bne	a5,s1,800067ce <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800067dc:	57fd                	li	a5,-1
    800067de:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800067e0:	01205d63          	blez	s2,800067fa <virtio_disk_rw+0xa6>
    800067e4:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800067e6:	000a2503          	lw	a0,0(s4)
    800067ea:	00000097          	auipc	ra,0x0
    800067ee:	cfc080e7          	jalr	-772(ra) # 800064e6 <free_desc>
      for(int j = 0; j < i; j++)
    800067f2:	2d85                	addiw	s11,s11,1
    800067f4:	0a11                	addi	s4,s4,4
    800067f6:	ffb918e3          	bne	s2,s11,800067e6 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800067fa:	85e6                	mv	a1,s9
    800067fc:	0001d517          	auipc	a0,0x1d
    80006800:	47c50513          	addi	a0,a0,1148 # 80023c78 <disk+0x18>
    80006804:	ffffc097          	auipc	ra,0xffffc
    80006808:	bee080e7          	jalr	-1042(ra) # 800023f2 <sleep>
  for(int i = 0; i < 3; i++){
    8000680c:	f8040a13          	addi	s4,s0,-128
{
    80006810:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006812:	894e                	mv	s2,s3
    80006814:	b77d                	j	800067c2 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006816:	f8042583          	lw	a1,-128(s0)
    8000681a:	00a58793          	addi	a5,a1,10
    8000681e:	0792                	slli	a5,a5,0x4

  if(write)
    80006820:	0001d617          	auipc	a2,0x1d
    80006824:	44060613          	addi	a2,a2,1088 # 80023c60 <disk>
    80006828:	00f60733          	add	a4,a2,a5
    8000682c:	018036b3          	snez	a3,s8
    80006830:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006832:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006836:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000683a:	f6078693          	addi	a3,a5,-160
    8000683e:	6218                	ld	a4,0(a2)
    80006840:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006842:	00878513          	addi	a0,a5,8
    80006846:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006848:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000684a:	6208                	ld	a0,0(a2)
    8000684c:	96aa                	add	a3,a3,a0
    8000684e:	4741                	li	a4,16
    80006850:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006852:	4705                	li	a4,1
    80006854:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006858:	f8442703          	lw	a4,-124(s0)
    8000685c:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006860:	0712                	slli	a4,a4,0x4
    80006862:	953a                	add	a0,a0,a4
    80006864:	058a8693          	addi	a3,s5,88
    80006868:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000686a:	6208                	ld	a0,0(a2)
    8000686c:	972a                	add	a4,a4,a0
    8000686e:	40000693          	li	a3,1024
    80006872:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006874:	001c3c13          	seqz	s8,s8
    80006878:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000687a:	001c6c13          	ori	s8,s8,1
    8000687e:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006882:	f8842603          	lw	a2,-120(s0)
    80006886:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000688a:	0001d697          	auipc	a3,0x1d
    8000688e:	3d668693          	addi	a3,a3,982 # 80023c60 <disk>
    80006892:	00258713          	addi	a4,a1,2
    80006896:	0712                	slli	a4,a4,0x4
    80006898:	9736                	add	a4,a4,a3
    8000689a:	587d                	li	a6,-1
    8000689c:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800068a0:	0612                	slli	a2,a2,0x4
    800068a2:	9532                	add	a0,a0,a2
    800068a4:	f9078793          	addi	a5,a5,-112
    800068a8:	97b6                	add	a5,a5,a3
    800068aa:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    800068ac:	629c                	ld	a5,0(a3)
    800068ae:	97b2                	add	a5,a5,a2
    800068b0:	4605                	li	a2,1
    800068b2:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800068b4:	4509                	li	a0,2
    800068b6:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    800068ba:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800068be:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800068c2:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800068c6:	6698                	ld	a4,8(a3)
    800068c8:	00275783          	lhu	a5,2(a4)
    800068cc:	8b9d                	andi	a5,a5,7
    800068ce:	0786                	slli	a5,a5,0x1
    800068d0:	97ba                	add	a5,a5,a4
    800068d2:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    800068d6:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800068da:	6698                	ld	a4,8(a3)
    800068dc:	00275783          	lhu	a5,2(a4)
    800068e0:	2785                	addiw	a5,a5,1
    800068e2:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800068e6:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800068ea:	100017b7          	lui	a5,0x10001
    800068ee:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800068f2:	004aa783          	lw	a5,4(s5)
    800068f6:	02c79163          	bne	a5,a2,80006918 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    800068fa:	0001d917          	auipc	s2,0x1d
    800068fe:	48e90913          	addi	s2,s2,1166 # 80023d88 <disk+0x128>
  while(b->disk == 1) {
    80006902:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006904:	85ca                	mv	a1,s2
    80006906:	8556                	mv	a0,s5
    80006908:	ffffc097          	auipc	ra,0xffffc
    8000690c:	aea080e7          	jalr	-1302(ra) # 800023f2 <sleep>
  while(b->disk == 1) {
    80006910:	004aa783          	lw	a5,4(s5)
    80006914:	fe9788e3          	beq	a5,s1,80006904 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006918:	f8042903          	lw	s2,-128(s0)
    8000691c:	00290793          	addi	a5,s2,2
    80006920:	00479713          	slli	a4,a5,0x4
    80006924:	0001d797          	auipc	a5,0x1d
    80006928:	33c78793          	addi	a5,a5,828 # 80023c60 <disk>
    8000692c:	97ba                	add	a5,a5,a4
    8000692e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006932:	0001d997          	auipc	s3,0x1d
    80006936:	32e98993          	addi	s3,s3,814 # 80023c60 <disk>
    8000693a:	00491713          	slli	a4,s2,0x4
    8000693e:	0009b783          	ld	a5,0(s3)
    80006942:	97ba                	add	a5,a5,a4
    80006944:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006948:	854a                	mv	a0,s2
    8000694a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000694e:	00000097          	auipc	ra,0x0
    80006952:	b98080e7          	jalr	-1128(ra) # 800064e6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006956:	8885                	andi	s1,s1,1
    80006958:	f0ed                	bnez	s1,8000693a <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000695a:	0001d517          	auipc	a0,0x1d
    8000695e:	42e50513          	addi	a0,a0,1070 # 80023d88 <disk+0x128>
    80006962:	ffffa097          	auipc	ra,0xffffa
    80006966:	328080e7          	jalr	808(ra) # 80000c8a <release>
}
    8000696a:	70e6                	ld	ra,120(sp)
    8000696c:	7446                	ld	s0,112(sp)
    8000696e:	74a6                	ld	s1,104(sp)
    80006970:	7906                	ld	s2,96(sp)
    80006972:	69e6                	ld	s3,88(sp)
    80006974:	6a46                	ld	s4,80(sp)
    80006976:	6aa6                	ld	s5,72(sp)
    80006978:	6b06                	ld	s6,64(sp)
    8000697a:	7be2                	ld	s7,56(sp)
    8000697c:	7c42                	ld	s8,48(sp)
    8000697e:	7ca2                	ld	s9,40(sp)
    80006980:	7d02                	ld	s10,32(sp)
    80006982:	6de2                	ld	s11,24(sp)
    80006984:	6109                	addi	sp,sp,128
    80006986:	8082                	ret

0000000080006988 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006988:	1101                	addi	sp,sp,-32
    8000698a:	ec06                	sd	ra,24(sp)
    8000698c:	e822                	sd	s0,16(sp)
    8000698e:	e426                	sd	s1,8(sp)
    80006990:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006992:	0001d497          	auipc	s1,0x1d
    80006996:	2ce48493          	addi	s1,s1,718 # 80023c60 <disk>
    8000699a:	0001d517          	auipc	a0,0x1d
    8000699e:	3ee50513          	addi	a0,a0,1006 # 80023d88 <disk+0x128>
    800069a2:	ffffa097          	auipc	ra,0xffffa
    800069a6:	234080e7          	jalr	564(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800069aa:	10001737          	lui	a4,0x10001
    800069ae:	533c                	lw	a5,96(a4)
    800069b0:	8b8d                	andi	a5,a5,3
    800069b2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800069b4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800069b8:	689c                	ld	a5,16(s1)
    800069ba:	0204d703          	lhu	a4,32(s1)
    800069be:	0027d783          	lhu	a5,2(a5)
    800069c2:	04f70863          	beq	a4,a5,80006a12 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800069c6:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800069ca:	6898                	ld	a4,16(s1)
    800069cc:	0204d783          	lhu	a5,32(s1)
    800069d0:	8b9d                	andi	a5,a5,7
    800069d2:	078e                	slli	a5,a5,0x3
    800069d4:	97ba                	add	a5,a5,a4
    800069d6:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800069d8:	00278713          	addi	a4,a5,2
    800069dc:	0712                	slli	a4,a4,0x4
    800069de:	9726                	add	a4,a4,s1
    800069e0:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800069e4:	e721                	bnez	a4,80006a2c <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800069e6:	0789                	addi	a5,a5,2
    800069e8:	0792                	slli	a5,a5,0x4
    800069ea:	97a6                	add	a5,a5,s1
    800069ec:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800069ee:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800069f2:	ffffc097          	auipc	ra,0xffffc
    800069f6:	bbc080e7          	jalr	-1092(ra) # 800025ae <wakeup>

    disk.used_idx += 1;
    800069fa:	0204d783          	lhu	a5,32(s1)
    800069fe:	2785                	addiw	a5,a5,1
    80006a00:	17c2                	slli	a5,a5,0x30
    80006a02:	93c1                	srli	a5,a5,0x30
    80006a04:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006a08:	6898                	ld	a4,16(s1)
    80006a0a:	00275703          	lhu	a4,2(a4)
    80006a0e:	faf71ce3          	bne	a4,a5,800069c6 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006a12:	0001d517          	auipc	a0,0x1d
    80006a16:	37650513          	addi	a0,a0,886 # 80023d88 <disk+0x128>
    80006a1a:	ffffa097          	auipc	ra,0xffffa
    80006a1e:	270080e7          	jalr	624(ra) # 80000c8a <release>
}
    80006a22:	60e2                	ld	ra,24(sp)
    80006a24:	6442                	ld	s0,16(sp)
    80006a26:	64a2                	ld	s1,8(sp)
    80006a28:	6105                	addi	sp,sp,32
    80006a2a:	8082                	ret
      panic("virtio_disk_intr status");
    80006a2c:	00002517          	auipc	a0,0x2
    80006a30:	f4450513          	addi	a0,a0,-188 # 80008970 <syscallnum+0x390>
    80006a34:	ffffa097          	auipc	ra,0xffffa
    80006a38:	b0a080e7          	jalr	-1270(ra) # 8000053e <panic>
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

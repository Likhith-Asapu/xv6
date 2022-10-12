
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	cb010113          	addi	sp,sp,-848 # 80008cb0 <stack0>
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
    80000056:	b1e70713          	addi	a4,a4,-1250 # 80008b70 <timer_scratch>
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
    80000068:	13c78793          	addi	a5,a5,316 # 800061a0 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdaa1f>
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
    80000130:	5fc080e7          	jalr	1532(ra) # 80002728 <either_copyin>
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
    8000018e:	b2650513          	addi	a0,a0,-1242 # 80010cb0 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	b1648493          	addi	s1,s1,-1258 # 80010cb0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	ba690913          	addi	s2,s2,-1114 # 80010d48 <cons+0x98>
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
    800001cc:	3aa080e7          	jalr	938(ra) # 80002572 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	f9c080e7          	jalr	-100(ra) # 80002172 <sleep>
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
    80000216:	4c0080e7          	jalr	1216(ra) # 800026d2 <either_copyout>
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
    8000022a:	a8a50513          	addi	a0,a0,-1398 # 80010cb0 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	a7450513          	addi	a0,a0,-1420 # 80010cb0 <cons>
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
    80000276:	acf72b23          	sw	a5,-1322(a4) # 80010d48 <cons+0x98>
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
    800002d0:	9e450513          	addi	a0,a0,-1564 # 80010cb0 <cons>
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
    800002f6:	48c080e7          	jalr	1164(ra) # 8000277e <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00011517          	auipc	a0,0x11
    800002fe:	9b650513          	addi	a0,a0,-1610 # 80010cb0 <cons>
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
    80000322:	99270713          	addi	a4,a4,-1646 # 80010cb0 <cons>
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
    8000034c:	96878793          	addi	a5,a5,-1688 # 80010cb0 <cons>
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
    8000037a:	9d27a783          	lw	a5,-1582(a5) # 80010d48 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00011717          	auipc	a4,0x11
    8000038e:	92670713          	addi	a4,a4,-1754 # 80010cb0 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00011497          	auipc	s1,0x11
    8000039e:	91648493          	addi	s1,s1,-1770 # 80010cb0 <cons>
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
    800003da:	8da70713          	addi	a4,a4,-1830 # 80010cb0 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00011717          	auipc	a4,0x11
    800003f0:	96f72223          	sw	a5,-1692(a4) # 80010d50 <cons+0xa0>
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
    80000416:	89e78793          	addi	a5,a5,-1890 # 80010cb0 <cons>
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
    8000043a:	90c7ab23          	sw	a2,-1770(a5) # 80010d4c <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00011517          	auipc	a0,0x11
    80000442:	90a50513          	addi	a0,a0,-1782 # 80010d48 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	edc080e7          	jalr	-292(ra) # 80002322 <wakeup>
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
    80000460:	00011517          	auipc	a0,0x11
    80000464:	85050513          	addi	a0,a0,-1968 # 80010cb0 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32a080e7          	jalr	810(ra) # 8000079a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00022797          	auipc	a5,0x22
    8000047c:	7d078793          	addi	a5,a5,2000 # 80022c48 <devsw>
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
    8000054a:	00011797          	auipc	a5,0x11
    8000054e:	8207a323          	sw	zero,-2010(a5) # 80010d70 <pr+0x18>
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
    80000582:	5af72923          	sw	a5,1458(a4) # 80008b30 <panicked>
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
    800005be:	7b6dad83          	lw	s11,1974(s11) # 80010d70 <pr+0x18>
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
    800005fc:	76050513          	addi	a0,a0,1888 # 80010d58 <pr>
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
    8000075a:	60250513          	addi	a0,a0,1538 # 80010d58 <pr>
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
    80000776:	5e648493          	addi	s1,s1,1510 # 80010d58 <pr>
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
    800007d6:	5a650513          	addi	a0,a0,1446 # 80010d78 <uart_tx_lock>
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
    80000802:	3327a783          	lw	a5,818(a5) # 80008b30 <panicked>
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
    8000083a:	3027b783          	ld	a5,770(a5) # 80008b38 <uart_tx_r>
    8000083e:	00008717          	auipc	a4,0x8
    80000842:	30273703          	ld	a4,770(a4) # 80008b40 <uart_tx_w>
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
    80000864:	518a0a13          	addi	s4,s4,1304 # 80010d78 <uart_tx_lock>
    uart_tx_r += 1;
    80000868:	00008497          	auipc	s1,0x8
    8000086c:	2d048493          	addi	s1,s1,720 # 80008b38 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000870:	00008997          	auipc	s3,0x8
    80000874:	2d098993          	addi	s3,s3,720 # 80008b40 <uart_tx_w>
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
    80000896:	a90080e7          	jalr	-1392(ra) # 80002322 <wakeup>
    
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
    800008d2:	4aa50513          	addi	a0,a0,1194 # 80010d78 <uart_tx_lock>
    800008d6:	00000097          	auipc	ra,0x0
    800008da:	300080e7          	jalr	768(ra) # 80000bd6 <acquire>
  if(panicked){
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	2527a783          	lw	a5,594(a5) # 80008b30 <panicked>
    800008e6:	e7c9                	bnez	a5,80000970 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e8:	00008717          	auipc	a4,0x8
    800008ec:	25873703          	ld	a4,600(a4) # 80008b40 <uart_tx_w>
    800008f0:	00008797          	auipc	a5,0x8
    800008f4:	2487b783          	ld	a5,584(a5) # 80008b38 <uart_tx_r>
    800008f8:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fc:	00010997          	auipc	s3,0x10
    80000900:	47c98993          	addi	s3,s3,1148 # 80010d78 <uart_tx_lock>
    80000904:	00008497          	auipc	s1,0x8
    80000908:	23448493          	addi	s1,s1,564 # 80008b38 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090c:	00008917          	auipc	s2,0x8
    80000910:	23490913          	addi	s2,s2,564 # 80008b40 <uart_tx_w>
    80000914:	00e79f63          	bne	a5,a4,80000932 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000918:	85ce                	mv	a1,s3
    8000091a:	8526                	mv	a0,s1
    8000091c:	00002097          	auipc	ra,0x2
    80000920:	856080e7          	jalr	-1962(ra) # 80002172 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000924:	00093703          	ld	a4,0(s2)
    80000928:	609c                	ld	a5,0(s1)
    8000092a:	02078793          	addi	a5,a5,32
    8000092e:	fee785e3          	beq	a5,a4,80000918 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000932:	00010497          	auipc	s1,0x10
    80000936:	44648493          	addi	s1,s1,1094 # 80010d78 <uart_tx_lock>
    8000093a:	01f77793          	andi	a5,a4,31
    8000093e:	97a6                	add	a5,a5,s1
    80000940:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000944:	0705                	addi	a4,a4,1
    80000946:	00008797          	auipc	a5,0x8
    8000094a:	1ee7bd23          	sd	a4,506(a5) # 80008b40 <uart_tx_w>
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
    800009c0:	3bc48493          	addi	s1,s1,956 # 80010d78 <uart_tx_lock>
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
    80000a02:	3e278793          	addi	a5,a5,994 # 80023de0 <end>
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
    80000a22:	39290913          	addi	s2,s2,914 # 80010db0 <kmem>
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
    80000abe:	2f650513          	addi	a0,a0,758 # 80010db0 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00023517          	auipc	a0,0x23
    80000ad2:	31250513          	addi	a0,a0,786 # 80023de0 <end>
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
    80000af4:	2c048493          	addi	s1,s1,704 # 80010db0 <kmem>
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
    80000b0c:	2a850513          	addi	a0,a0,680 # 80010db0 <kmem>
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
    80000b38:	27c50513          	addi	a0,a0,636 # 80010db0 <kmem>
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
    80000e8c:	cc070713          	addi	a4,a4,-832 # 80008b48 <started>
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
    80000ec2:	a84080e7          	jalr	-1404(ra) # 80002942 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	31a080e7          	jalr	794(ra) # 800061e0 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	0f2080e7          	jalr	242(ra) # 80001fc0 <scheduler>
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
    80000f3a:	9e4080e7          	jalr	-1564(ra) # 8000291a <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	a04080e7          	jalr	-1532(ra) # 80002942 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	284080e7          	jalr	644(ra) # 800061ca <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	292080e7          	jalr	658(ra) # 800061e0 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	438080e7          	jalr	1080(ra) # 8000338e <binit>
    iinit();         // inode table
    80000f5e:	00003097          	auipc	ra,0x3
    80000f62:	adc080e7          	jalr	-1316(ra) # 80003a3a <iinit>
    fileinit();      // file table
    80000f66:	00004097          	auipc	ra,0x4
    80000f6a:	a7a080e7          	jalr	-1414(ra) # 800049e0 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	37a080e7          	jalr	890(ra) # 800062e8 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	d68080e7          	jalr	-664(ra) # 80001cde <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	bcf72223          	sw	a5,-1084(a4) # 80008b48 <started>
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
    80000f9c:	bb87b783          	ld	a5,-1096(a5) # 80008b50 <kernel_pagetable>
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
    80001258:	8ea7be23          	sd	a0,-1796(a5) # 80008b50 <kernel_pagetable>
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
    80001850:	9b448493          	addi	s1,s1,-1612 # 80011200 <proc>
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
    80001866:	00017a17          	auipc	s4,0x17
    8000186a:	19aa0a13          	addi	s4,s4,410 # 80018a00 <tickslock>
    char *pa = kalloc();
    8000186e:	fffff097          	auipc	ra,0xfffff
    80001872:	278080e7          	jalr	632(ra) # 80000ae6 <kalloc>
    80001876:	862a                	mv	a2,a0
    if(pa == 0)
    80001878:	c131                	beqz	a0,800018bc <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
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
  for(p = proc; p < &proc[NPROC]; p++) {
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
    800018ec:	4e850513          	addi	a0,a0,1256 # 80010dd0 <pid_lock>
    800018f0:	fffff097          	auipc	ra,0xfffff
    800018f4:	256080e7          	jalr	598(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f8:	00007597          	auipc	a1,0x7
    800018fc:	8f058593          	addi	a1,a1,-1808 # 800081e8 <digits+0x1a8>
    80001900:	0000f517          	auipc	a0,0xf
    80001904:	4e850513          	addi	a0,a0,1256 # 80010de8 <wait_lock>
    80001908:	fffff097          	auipc	ra,0xfffff
    8000190c:	23e080e7          	jalr	574(ra) # 80000b46 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001910:	00010497          	auipc	s1,0x10
    80001914:	8f048493          	addi	s1,s1,-1808 # 80011200 <proc>
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
    80001932:	00017997          	auipc	s3,0x17
    80001936:	0ce98993          	addi	s3,s3,206 # 80018a00 <tickslock>
      initlock(&p->lock, "proc");
    8000193a:	85da                	mv	a1,s6
    8000193c:	8526                	mv	a0,s1
    8000193e:	fffff097          	auipc	ra,0xfffff
    80001942:	208080e7          	jalr	520(ra) # 80000b46 <initlock>
      p->state = UNUSED;
    80001946:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    8000194a:	415487b3          	sub	a5,s1,s5
    8000194e:	8795                	srai	a5,a5,0x5
    80001950:	000a3703          	ld	a4,0(s4)
    80001954:	02e787b3          	mul	a5,a5,a4
    80001958:	2785                	addiw	a5,a5,1
    8000195a:	00d7979b          	slliw	a5,a5,0xd
    8000195e:	40f907b3          	sub	a5,s2,a5
    80001962:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
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
    800019a0:	46450513          	addi	a0,a0,1124 # 80010e00 <cpus>
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
    800019c8:	40c70713          	addi	a4,a4,1036 # 80010dd0 <pid_lock>
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
    80001a00:	0047a783          	lw	a5,4(a5) # 80008a00 <first.1>
    80001a04:	eb89                	bnez	a5,80001a16 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a06:	00001097          	auipc	ra,0x1
    80001a0a:	f54080e7          	jalr	-172(ra) # 8000295a <usertrapret>
}
    80001a0e:	60a2                	ld	ra,8(sp)
    80001a10:	6402                	ld	s0,0(sp)
    80001a12:	0141                	addi	sp,sp,16
    80001a14:	8082                	ret
    first = 0;
    80001a16:	00007797          	auipc	a5,0x7
    80001a1a:	fe07a523          	sw	zero,-22(a5) # 80008a00 <first.1>
    fsinit(ROOTDEV);
    80001a1e:	4505                	li	a0,1
    80001a20:	00002097          	auipc	ra,0x2
    80001a24:	f9a080e7          	jalr	-102(ra) # 800039ba <fsinit>
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
    80001a3a:	39a90913          	addi	s2,s2,922 # 80010dd0 <pid_lock>
    80001a3e:	854a                	mv	a0,s2
    80001a40:	fffff097          	auipc	ra,0xfffff
    80001a44:	196080e7          	jalr	406(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001a48:	00007797          	auipc	a5,0x7
    80001a4c:	fbc78793          	addi	a5,a5,-68 # 80008a04 <nextpid>
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
    80001bc6:	63e48493          	addi	s1,s1,1598 # 80011200 <proc>
    80001bca:	00017917          	auipc	s2,0x17
    80001bce:	e3690913          	addi	s2,s2,-458 # 80018a00 <tickslock>
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
    80001bea:	1e048493          	addi	s1,s1,480
    80001bee:	ff2492e3          	bne	s1,s2,80001bd2 <allocproc+0x1c>
  return 0;
    80001bf2:	4481                	li	s1,0
    80001bf4:	a055                	j	80001c98 <allocproc+0xe2>
  p->pid = allocpid();
    80001bf6:	00000097          	auipc	ra,0x0
    80001bfa:	e34080e7          	jalr	-460(ra) # 80001a2a <allocpid>
    80001bfe:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c00:	4785                	li	a5,1
    80001c02:	cc9c                	sw	a5,24(s1)
  p->time_created = ticks;
    80001c04:	00007797          	auipc	a5,0x7
    80001c08:	f5c7e783          	lwu	a5,-164(a5) # 80008b60 <ticks>
    80001c0c:	16f4bc23          	sd	a5,376(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c10:	fffff097          	auipc	ra,0xfffff
    80001c14:	ed6080e7          	jalr	-298(ra) # 80000ae6 <kalloc>
    80001c18:	892a                	mv	s2,a0
    80001c1a:	eca8                	sd	a0,88(s1)
    80001c1c:	c549                	beqz	a0,80001ca6 <allocproc+0xf0>
  p->pagetable = proc_pagetable(p);
    80001c1e:	8526                	mv	a0,s1
    80001c20:	00000097          	auipc	ra,0x0
    80001c24:	e50080e7          	jalr	-432(ra) # 80001a70 <proc_pagetable>
    80001c28:	892a                	mv	s2,a0
    80001c2a:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c2c:	c949                	beqz	a0,80001cbe <allocproc+0x108>
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
    80001c5e:	f067a783          	lw	a5,-250(a5) # 80008b60 <ticks>
    80001c62:	16f4a823          	sw	a5,368(s1)
  p->alarm_on = 0;
    80001c66:	1804ac23          	sw	zero,408(s1)
  p->cur_ticks = 0;
    80001c6a:	1804a623          	sw	zero,396(s1)
  p->runtime = 0;
    80001c6e:	1a04bc23          	sd	zero,440(s1)
  p->starttime = 0;
    80001c72:	1c04b023          	sd	zero,448(s1)
  p->sleeptime = 0;
    80001c76:	1c04b423          	sd	zero,456(s1)
  p->runcount = 0;
    80001c7a:	1c04b823          	sd	zero,464(s1)
  p->priority = 60;
    80001c7e:	03c00793          	li	a5,60
    80001c82:	1cf4bc23          	sd	a5,472(s1)
  p->handlerpermission = 1;
    80001c86:	4785                	li	a5,1
    80001c88:	1af4a823          	sw	a5,432(s1)
  if(p->parent != 0){
    80001c8c:	7c9c                	ld	a5,56(s1)
    80001c8e:	c7a1                	beqz	a5,80001cd6 <allocproc+0x120>
    p->tickets = p->parent->tickets;
    80001c90:	1b47a783          	lw	a5,436(a5)
    80001c94:	1af4aa23          	sw	a5,436(s1)
}
    80001c98:	8526                	mv	a0,s1
    80001c9a:	60e2                	ld	ra,24(sp)
    80001c9c:	6442                	ld	s0,16(sp)
    80001c9e:	64a2                	ld	s1,8(sp)
    80001ca0:	6902                	ld	s2,0(sp)
    80001ca2:	6105                	addi	sp,sp,32
    80001ca4:	8082                	ret
    freeproc(p);
    80001ca6:	8526                	mv	a0,s1
    80001ca8:	00000097          	auipc	ra,0x0
    80001cac:	eb6080e7          	jalr	-330(ra) # 80001b5e <freeproc>
    release(&p->lock);
    80001cb0:	8526                	mv	a0,s1
    80001cb2:	fffff097          	auipc	ra,0xfffff
    80001cb6:	fd8080e7          	jalr	-40(ra) # 80000c8a <release>
    return 0;
    80001cba:	84ca                	mv	s1,s2
    80001cbc:	bff1                	j	80001c98 <allocproc+0xe2>
    freeproc(p);
    80001cbe:	8526                	mv	a0,s1
    80001cc0:	00000097          	auipc	ra,0x0
    80001cc4:	e9e080e7          	jalr	-354(ra) # 80001b5e <freeproc>
    release(&p->lock);
    80001cc8:	8526                	mv	a0,s1
    80001cca:	fffff097          	auipc	ra,0xfffff
    80001cce:	fc0080e7          	jalr	-64(ra) # 80000c8a <release>
    return 0;
    80001cd2:	84ca                	mv	s1,s2
    80001cd4:	b7d1                	j	80001c98 <allocproc+0xe2>
    p->tickets = 1;
    80001cd6:	4785                	li	a5,1
    80001cd8:	1af4aa23          	sw	a5,436(s1)
    80001cdc:	bf75                	j	80001c98 <allocproc+0xe2>

0000000080001cde <userinit>:
{
    80001cde:	1101                	addi	sp,sp,-32
    80001ce0:	ec06                	sd	ra,24(sp)
    80001ce2:	e822                	sd	s0,16(sp)
    80001ce4:	e426                	sd	s1,8(sp)
    80001ce6:	1000                	addi	s0,sp,32
  p = allocproc();
    80001ce8:	00000097          	auipc	ra,0x0
    80001cec:	ece080e7          	jalr	-306(ra) # 80001bb6 <allocproc>
    80001cf0:	84aa                	mv	s1,a0
  initproc = p;
    80001cf2:	00007797          	auipc	a5,0x7
    80001cf6:	e6a7b323          	sd	a0,-410(a5) # 80008b58 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cfa:	03400613          	li	a2,52
    80001cfe:	00007597          	auipc	a1,0x7
    80001d02:	d1258593          	addi	a1,a1,-750 # 80008a10 <initcode>
    80001d06:	6928                	ld	a0,80(a0)
    80001d08:	fffff097          	auipc	ra,0xfffff
    80001d0c:	64e080e7          	jalr	1614(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80001d10:	6785                	lui	a5,0x1
    80001d12:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d14:	6cb8                	ld	a4,88(s1)
    80001d16:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d1a:	6cb8                	ld	a4,88(s1)
    80001d1c:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d1e:	4641                	li	a2,16
    80001d20:	00006597          	auipc	a1,0x6
    80001d24:	4e058593          	addi	a1,a1,1248 # 80008200 <digits+0x1c0>
    80001d28:	15848513          	addi	a0,s1,344
    80001d2c:	fffff097          	auipc	ra,0xfffff
    80001d30:	0f0080e7          	jalr	240(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001d34:	00006517          	auipc	a0,0x6
    80001d38:	4dc50513          	addi	a0,a0,1244 # 80008210 <digits+0x1d0>
    80001d3c:	00002097          	auipc	ra,0x2
    80001d40:	6a0080e7          	jalr	1696(ra) # 800043dc <namei>
    80001d44:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d48:	478d                	li	a5,3
    80001d4a:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d4c:	8526                	mv	a0,s1
    80001d4e:	fffff097          	auipc	ra,0xfffff
    80001d52:	f3c080e7          	jalr	-196(ra) # 80000c8a <release>
}
    80001d56:	60e2                	ld	ra,24(sp)
    80001d58:	6442                	ld	s0,16(sp)
    80001d5a:	64a2                	ld	s1,8(sp)
    80001d5c:	6105                	addi	sp,sp,32
    80001d5e:	8082                	ret

0000000080001d60 <growproc>:
{
    80001d60:	1101                	addi	sp,sp,-32
    80001d62:	ec06                	sd	ra,24(sp)
    80001d64:	e822                	sd	s0,16(sp)
    80001d66:	e426                	sd	s1,8(sp)
    80001d68:	e04a                	sd	s2,0(sp)
    80001d6a:	1000                	addi	s0,sp,32
    80001d6c:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d6e:	00000097          	auipc	ra,0x0
    80001d72:	c3e080e7          	jalr	-962(ra) # 800019ac <myproc>
    80001d76:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d78:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d7a:	01204c63          	bgtz	s2,80001d92 <growproc+0x32>
  } else if(n < 0){
    80001d7e:	02094663          	bltz	s2,80001daa <growproc+0x4a>
  p->sz = sz;
    80001d82:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d84:	4501                	li	a0,0
}
    80001d86:	60e2                	ld	ra,24(sp)
    80001d88:	6442                	ld	s0,16(sp)
    80001d8a:	64a2                	ld	s1,8(sp)
    80001d8c:	6902                	ld	s2,0(sp)
    80001d8e:	6105                	addi	sp,sp,32
    80001d90:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d92:	4691                	li	a3,4
    80001d94:	00b90633          	add	a2,s2,a1
    80001d98:	6928                	ld	a0,80(a0)
    80001d9a:	fffff097          	auipc	ra,0xfffff
    80001d9e:	676080e7          	jalr	1654(ra) # 80001410 <uvmalloc>
    80001da2:	85aa                	mv	a1,a0
    80001da4:	fd79                	bnez	a0,80001d82 <growproc+0x22>
      return -1;
    80001da6:	557d                	li	a0,-1
    80001da8:	bff9                	j	80001d86 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001daa:	00b90633          	add	a2,s2,a1
    80001dae:	6928                	ld	a0,80(a0)
    80001db0:	fffff097          	auipc	ra,0xfffff
    80001db4:	618080e7          	jalr	1560(ra) # 800013c8 <uvmdealloc>
    80001db8:	85aa                	mv	a1,a0
    80001dba:	b7e1                	j	80001d82 <growproc+0x22>

0000000080001dbc <fork>:
{
    80001dbc:	7139                	addi	sp,sp,-64
    80001dbe:	fc06                	sd	ra,56(sp)
    80001dc0:	f822                	sd	s0,48(sp)
    80001dc2:	f426                	sd	s1,40(sp)
    80001dc4:	f04a                	sd	s2,32(sp)
    80001dc6:	ec4e                	sd	s3,24(sp)
    80001dc8:	e852                	sd	s4,16(sp)
    80001dca:	e456                	sd	s5,8(sp)
    80001dcc:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001dce:	00000097          	auipc	ra,0x0
    80001dd2:	bde080e7          	jalr	-1058(ra) # 800019ac <myproc>
    80001dd6:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001dd8:	00000097          	auipc	ra,0x0
    80001ddc:	dde080e7          	jalr	-546(ra) # 80001bb6 <allocproc>
    80001de0:	12050063          	beqz	a0,80001f00 <fork+0x144>
    80001de4:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001de6:	048ab603          	ld	a2,72(s5)
    80001dea:	692c                	ld	a1,80(a0)
    80001dec:	050ab503          	ld	a0,80(s5)
    80001df0:	fffff097          	auipc	ra,0xfffff
    80001df4:	774080e7          	jalr	1908(ra) # 80001564 <uvmcopy>
    80001df8:	04054c63          	bltz	a0,80001e50 <fork+0x94>
  np->sz = p->sz;
    80001dfc:	048ab783          	ld	a5,72(s5)
    80001e00:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001e04:	058ab683          	ld	a3,88(s5)
    80001e08:	87b6                	mv	a5,a3
    80001e0a:	0589b703          	ld	a4,88(s3)
    80001e0e:	12068693          	addi	a3,a3,288
    80001e12:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e16:	6788                	ld	a0,8(a5)
    80001e18:	6b8c                	ld	a1,16(a5)
    80001e1a:	6f90                	ld	a2,24(a5)
    80001e1c:	01073023          	sd	a6,0(a4)
    80001e20:	e708                	sd	a0,8(a4)
    80001e22:	eb0c                	sd	a1,16(a4)
    80001e24:	ef10                	sd	a2,24(a4)
    80001e26:	02078793          	addi	a5,a5,32
    80001e2a:	02070713          	addi	a4,a4,32
    80001e2e:	fed792e3          	bne	a5,a3,80001e12 <fork+0x56>
  np->mask = p->mask;
    80001e32:	168aa783          	lw	a5,360(s5)
    80001e36:	16f9a423          	sw	a5,360(s3)
  np->trapframe->a0 = 0;
    80001e3a:	0589b783          	ld	a5,88(s3)
    80001e3e:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e42:	0d0a8493          	addi	s1,s5,208
    80001e46:	0d098913          	addi	s2,s3,208
    80001e4a:	150a8a13          	addi	s4,s5,336
    80001e4e:	a00d                	j	80001e70 <fork+0xb4>
    freeproc(np);
    80001e50:	854e                	mv	a0,s3
    80001e52:	00000097          	auipc	ra,0x0
    80001e56:	d0c080e7          	jalr	-756(ra) # 80001b5e <freeproc>
    release(&np->lock);
    80001e5a:	854e                	mv	a0,s3
    80001e5c:	fffff097          	auipc	ra,0xfffff
    80001e60:	e2e080e7          	jalr	-466(ra) # 80000c8a <release>
    return -1;
    80001e64:	597d                	li	s2,-1
    80001e66:	a059                	j	80001eec <fork+0x130>
  for(i = 0; i < NOFILE; i++)
    80001e68:	04a1                	addi	s1,s1,8
    80001e6a:	0921                	addi	s2,s2,8
    80001e6c:	01448b63          	beq	s1,s4,80001e82 <fork+0xc6>
    if(p->ofile[i])
    80001e70:	6088                	ld	a0,0(s1)
    80001e72:	d97d                	beqz	a0,80001e68 <fork+0xac>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e74:	00003097          	auipc	ra,0x3
    80001e78:	bfe080e7          	jalr	-1026(ra) # 80004a72 <filedup>
    80001e7c:	00a93023          	sd	a0,0(s2)
    80001e80:	b7e5                	j	80001e68 <fork+0xac>
  np->cwd = idup(p->cwd);
    80001e82:	150ab503          	ld	a0,336(s5)
    80001e86:	00002097          	auipc	ra,0x2
    80001e8a:	d72080e7          	jalr	-654(ra) # 80003bf8 <idup>
    80001e8e:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e92:	4641                	li	a2,16
    80001e94:	158a8593          	addi	a1,s5,344
    80001e98:	15898513          	addi	a0,s3,344
    80001e9c:	fffff097          	auipc	ra,0xfffff
    80001ea0:	f80080e7          	jalr	-128(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    80001ea4:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001ea8:	854e                	mv	a0,s3
    80001eaa:	fffff097          	auipc	ra,0xfffff
    80001eae:	de0080e7          	jalr	-544(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80001eb2:	0000f497          	auipc	s1,0xf
    80001eb6:	f3648493          	addi	s1,s1,-202 # 80010de8 <wait_lock>
    80001eba:	8526                	mv	a0,s1
    80001ebc:	fffff097          	auipc	ra,0xfffff
    80001ec0:	d1a080e7          	jalr	-742(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001ec4:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001ec8:	8526                	mv	a0,s1
    80001eca:	fffff097          	auipc	ra,0xfffff
    80001ece:	dc0080e7          	jalr	-576(ra) # 80000c8a <release>
  acquire(&np->lock);
    80001ed2:	854e                	mv	a0,s3
    80001ed4:	fffff097          	auipc	ra,0xfffff
    80001ed8:	d02080e7          	jalr	-766(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80001edc:	478d                	li	a5,3
    80001ede:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001ee2:	854e                	mv	a0,s3
    80001ee4:	fffff097          	auipc	ra,0xfffff
    80001ee8:	da6080e7          	jalr	-602(ra) # 80000c8a <release>
}
    80001eec:	854a                	mv	a0,s2
    80001eee:	70e2                	ld	ra,56(sp)
    80001ef0:	7442                	ld	s0,48(sp)
    80001ef2:	74a2                	ld	s1,40(sp)
    80001ef4:	7902                	ld	s2,32(sp)
    80001ef6:	69e2                	ld	s3,24(sp)
    80001ef8:	6a42                	ld	s4,16(sp)
    80001efa:	6aa2                	ld	s5,8(sp)
    80001efc:	6121                	addi	sp,sp,64
    80001efe:	8082                	ret
    return -1;
    80001f00:	597d                	li	s2,-1
    80001f02:	b7ed                	j	80001eec <fork+0x130>

0000000080001f04 <max>:
int max(int a, int b){
    80001f04:	1141                	addi	sp,sp,-16
    80001f06:	e422                	sd	s0,8(sp)
    80001f08:	0800                	addi	s0,sp,16
}
    80001f0a:	87aa                	mv	a5,a0
    80001f0c:	00b55363          	bge	a0,a1,80001f12 <max+0xe>
    80001f10:	87ae                	mv	a5,a1
    80001f12:	0007851b          	sext.w	a0,a5
    80001f16:	6422                	ld	s0,8(sp)
    80001f18:	0141                	addi	sp,sp,16
    80001f1a:	8082                	ret

0000000080001f1c <min>:
int min(int a, int b){
    80001f1c:	1141                	addi	sp,sp,-16
    80001f1e:	e422                	sd	s0,8(sp)
    80001f20:	0800                	addi	s0,sp,16
}
    80001f22:	87aa                	mv	a5,a0
    80001f24:	00a5d363          	bge	a1,a0,80001f2a <min+0xe>
    80001f28:	87ae                	mv	a5,a1
    80001f2a:	0007851b          	sext.w	a0,a5
    80001f2e:	6422                	ld	s0,8(sp)
    80001f30:	0141                	addi	sp,sp,16
    80001f32:	8082                	ret

0000000080001f34 <update_time>:
{
    80001f34:	7179                	addi	sp,sp,-48
    80001f36:	f406                	sd	ra,40(sp)
    80001f38:	f022                	sd	s0,32(sp)
    80001f3a:	ec26                	sd	s1,24(sp)
    80001f3c:	e84a                	sd	s2,16(sp)
    80001f3e:	e44e                	sd	s3,8(sp)
    80001f40:	1800                	addi	s0,sp,48
  for (p = proc; p < &proc[NPROC]; p++) {
    80001f42:	0000f497          	auipc	s1,0xf
    80001f46:	2be48493          	addi	s1,s1,702 # 80011200 <proc>
    if (p->state == RUNNING) {
    80001f4a:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++) {
    80001f4c:	00017917          	auipc	s2,0x17
    80001f50:	ab490913          	addi	s2,s2,-1356 # 80018a00 <tickslock>
    80001f54:	a811                	j	80001f68 <update_time+0x34>
    release(&p->lock); 
    80001f56:	8526                	mv	a0,s1
    80001f58:	fffff097          	auipc	ra,0xfffff
    80001f5c:	d32080e7          	jalr	-718(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001f60:	1e048493          	addi	s1,s1,480
    80001f64:	03248063          	beq	s1,s2,80001f84 <update_time+0x50>
    acquire(&p->lock);
    80001f68:	8526                	mv	a0,s1
    80001f6a:	fffff097          	auipc	ra,0xfffff
    80001f6e:	c6c080e7          	jalr	-916(ra) # 80000bd6 <acquire>
    if (p->state == RUNNING) {
    80001f72:	4c9c                	lw	a5,24(s1)
    80001f74:	ff3791e3          	bne	a5,s3,80001f56 <update_time+0x22>
      p->rtime++;
    80001f78:	16c4a783          	lw	a5,364(s1)
    80001f7c:	2785                	addiw	a5,a5,1
    80001f7e:	16f4a623          	sw	a5,364(s1)
    80001f82:	bfd1                	j	80001f56 <update_time+0x22>
}
    80001f84:	70a2                	ld	ra,40(sp)
    80001f86:	7402                	ld	s0,32(sp)
    80001f88:	64e2                	ld	s1,24(sp)
    80001f8a:	6942                	ld	s2,16(sp)
    80001f8c:	69a2                	ld	s3,8(sp)
    80001f8e:	6145                	addi	sp,sp,48
    80001f90:	8082                	ret

0000000080001f92 <randomnum>:
{
    80001f92:	1141                	addi	sp,sp,-16
    80001f94:	e422                	sd	s0,8(sp)
    80001f96:	0800                	addi	s0,sp,16
  uint64 num = (uint64)ticks;
    80001f98:	00007797          	auipc	a5,0x7
    80001f9c:	bc87e783          	lwu	a5,-1080(a5) # 80008b60 <ticks>
  num = num ^ (num << 13);
    80001fa0:	00d79713          	slli	a4,a5,0xd
    80001fa4:	8fb9                	xor	a5,a5,a4
  num = num ^ (num >> 17);
    80001fa6:	0117d713          	srli	a4,a5,0x11
    80001faa:	8f3d                	xor	a4,a4,a5
  num = num ^ (num << 5);
    80001fac:	00571793          	slli	a5,a4,0x5
    80001fb0:	8fb9                	xor	a5,a5,a4
  num = num % (max - min);
    80001fb2:	9d89                	subw	a1,a1,a0
    80001fb4:	02b7f7b3          	remu	a5,a5,a1
}
    80001fb8:	9d3d                	addw	a0,a0,a5
    80001fba:	6422                	ld	s0,8(sp)
    80001fbc:	0141                	addi	sp,sp,16
    80001fbe:	8082                	ret

0000000080001fc0 <scheduler>:
{
    80001fc0:	7139                	addi	sp,sp,-64
    80001fc2:	fc06                	sd	ra,56(sp)
    80001fc4:	f822                	sd	s0,48(sp)
    80001fc6:	f426                	sd	s1,40(sp)
    80001fc8:	f04a                	sd	s2,32(sp)
    80001fca:	ec4e                	sd	s3,24(sp)
    80001fcc:	e852                	sd	s4,16(sp)
    80001fce:	e456                	sd	s5,8(sp)
    80001fd0:	e05a                	sd	s6,0(sp)
    80001fd2:	0080                	addi	s0,sp,64
    80001fd4:	8792                	mv	a5,tp
  int id = r_tp();
    80001fd6:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001fd8:	00779a93          	slli	s5,a5,0x7
    80001fdc:	0000f717          	auipc	a4,0xf
    80001fe0:	df470713          	addi	a4,a4,-524 # 80010dd0 <pid_lock>
    80001fe4:	9756                	add	a4,a4,s5
    80001fe6:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001fea:	0000f717          	auipc	a4,0xf
    80001fee:	e1e70713          	addi	a4,a4,-482 # 80010e08 <cpus+0x8>
    80001ff2:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001ff4:	498d                	li	s3,3
        p->state = RUNNING;
    80001ff6:	4b11                	li	s6,4
        c->proc = p;
    80001ff8:	079e                	slli	a5,a5,0x7
    80001ffa:	0000fa17          	auipc	s4,0xf
    80001ffe:	dd6a0a13          	addi	s4,s4,-554 # 80010dd0 <pid_lock>
    80002002:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80002004:	00017917          	auipc	s2,0x17
    80002008:	9fc90913          	addi	s2,s2,-1540 # 80018a00 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000200c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002010:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002014:	10079073          	csrw	sstatus,a5
    80002018:	0000f497          	auipc	s1,0xf
    8000201c:	1e848493          	addi	s1,s1,488 # 80011200 <proc>
    80002020:	a811                	j	80002034 <scheduler+0x74>
      release(&p->lock);
    80002022:	8526                	mv	a0,s1
    80002024:	fffff097          	auipc	ra,0xfffff
    80002028:	c66080e7          	jalr	-922(ra) # 80000c8a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    8000202c:	1e048493          	addi	s1,s1,480
    80002030:	fd248ee3          	beq	s1,s2,8000200c <scheduler+0x4c>
      acquire(&p->lock);
    80002034:	8526                	mv	a0,s1
    80002036:	fffff097          	auipc	ra,0xfffff
    8000203a:	ba0080e7          	jalr	-1120(ra) # 80000bd6 <acquire>
      if(p->state == RUNNABLE) {
    8000203e:	4c9c                	lw	a5,24(s1)
    80002040:	ff3791e3          	bne	a5,s3,80002022 <scheduler+0x62>
        p->state = RUNNING;
    80002044:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80002048:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    8000204c:	06048593          	addi	a1,s1,96
    80002050:	8556                	mv	a0,s5
    80002052:	00001097          	auipc	ra,0x1
    80002056:	85e080e7          	jalr	-1954(ra) # 800028b0 <swtch>
        c->proc = 0;
    8000205a:	020a3823          	sd	zero,48(s4)
    8000205e:	b7d1                	j	80002022 <scheduler+0x62>

0000000080002060 <sched>:
{
    80002060:	7179                	addi	sp,sp,-48
    80002062:	f406                	sd	ra,40(sp)
    80002064:	f022                	sd	s0,32(sp)
    80002066:	ec26                	sd	s1,24(sp)
    80002068:	e84a                	sd	s2,16(sp)
    8000206a:	e44e                	sd	s3,8(sp)
    8000206c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000206e:	00000097          	auipc	ra,0x0
    80002072:	93e080e7          	jalr	-1730(ra) # 800019ac <myproc>
    80002076:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002078:	fffff097          	auipc	ra,0xfffff
    8000207c:	ae4080e7          	jalr	-1308(ra) # 80000b5c <holding>
    80002080:	c93d                	beqz	a0,800020f6 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002082:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002084:	2781                	sext.w	a5,a5
    80002086:	079e                	slli	a5,a5,0x7
    80002088:	0000f717          	auipc	a4,0xf
    8000208c:	d4870713          	addi	a4,a4,-696 # 80010dd0 <pid_lock>
    80002090:	97ba                	add	a5,a5,a4
    80002092:	0a87a703          	lw	a4,168(a5)
    80002096:	4785                	li	a5,1
    80002098:	06f71763          	bne	a4,a5,80002106 <sched+0xa6>
  if(p->state == RUNNING)
    8000209c:	4c98                	lw	a4,24(s1)
    8000209e:	4791                	li	a5,4
    800020a0:	06f70b63          	beq	a4,a5,80002116 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020a4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800020a8:	8b89                	andi	a5,a5,2
  if(intr_get())
    800020aa:	efb5                	bnez	a5,80002126 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020ac:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800020ae:	0000f917          	auipc	s2,0xf
    800020b2:	d2290913          	addi	s2,s2,-734 # 80010dd0 <pid_lock>
    800020b6:	2781                	sext.w	a5,a5
    800020b8:	079e                	slli	a5,a5,0x7
    800020ba:	97ca                	add	a5,a5,s2
    800020bc:	0ac7a983          	lw	s3,172(a5)
    800020c0:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800020c2:	2781                	sext.w	a5,a5
    800020c4:	079e                	slli	a5,a5,0x7
    800020c6:	0000f597          	auipc	a1,0xf
    800020ca:	d4258593          	addi	a1,a1,-702 # 80010e08 <cpus+0x8>
    800020ce:	95be                	add	a1,a1,a5
    800020d0:	06048513          	addi	a0,s1,96
    800020d4:	00000097          	auipc	ra,0x0
    800020d8:	7dc080e7          	jalr	2012(ra) # 800028b0 <swtch>
    800020dc:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020de:	2781                	sext.w	a5,a5
    800020e0:	079e                	slli	a5,a5,0x7
    800020e2:	97ca                	add	a5,a5,s2
    800020e4:	0b37a623          	sw	s3,172(a5)
}
    800020e8:	70a2                	ld	ra,40(sp)
    800020ea:	7402                	ld	s0,32(sp)
    800020ec:	64e2                	ld	s1,24(sp)
    800020ee:	6942                	ld	s2,16(sp)
    800020f0:	69a2                	ld	s3,8(sp)
    800020f2:	6145                	addi	sp,sp,48
    800020f4:	8082                	ret
    panic("sched p->lock");
    800020f6:	00006517          	auipc	a0,0x6
    800020fa:	12250513          	addi	a0,a0,290 # 80008218 <digits+0x1d8>
    800020fe:	ffffe097          	auipc	ra,0xffffe
    80002102:	440080e7          	jalr	1088(ra) # 8000053e <panic>
    panic("sched locks");
    80002106:	00006517          	auipc	a0,0x6
    8000210a:	12250513          	addi	a0,a0,290 # 80008228 <digits+0x1e8>
    8000210e:	ffffe097          	auipc	ra,0xffffe
    80002112:	430080e7          	jalr	1072(ra) # 8000053e <panic>
    panic("sched running");
    80002116:	00006517          	auipc	a0,0x6
    8000211a:	12250513          	addi	a0,a0,290 # 80008238 <digits+0x1f8>
    8000211e:	ffffe097          	auipc	ra,0xffffe
    80002122:	420080e7          	jalr	1056(ra) # 8000053e <panic>
    panic("sched interruptible");
    80002126:	00006517          	auipc	a0,0x6
    8000212a:	12250513          	addi	a0,a0,290 # 80008248 <digits+0x208>
    8000212e:	ffffe097          	auipc	ra,0xffffe
    80002132:	410080e7          	jalr	1040(ra) # 8000053e <panic>

0000000080002136 <yield>:
{
    80002136:	1101                	addi	sp,sp,-32
    80002138:	ec06                	sd	ra,24(sp)
    8000213a:	e822                	sd	s0,16(sp)
    8000213c:	e426                	sd	s1,8(sp)
    8000213e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002140:	00000097          	auipc	ra,0x0
    80002144:	86c080e7          	jalr	-1940(ra) # 800019ac <myproc>
    80002148:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000214a:	fffff097          	auipc	ra,0xfffff
    8000214e:	a8c080e7          	jalr	-1396(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    80002152:	478d                	li	a5,3
    80002154:	cc9c                	sw	a5,24(s1)
  sched();
    80002156:	00000097          	auipc	ra,0x0
    8000215a:	f0a080e7          	jalr	-246(ra) # 80002060 <sched>
  release(&p->lock);
    8000215e:	8526                	mv	a0,s1
    80002160:	fffff097          	auipc	ra,0xfffff
    80002164:	b2a080e7          	jalr	-1238(ra) # 80000c8a <release>
}
    80002168:	60e2                	ld	ra,24(sp)
    8000216a:	6442                	ld	s0,16(sp)
    8000216c:	64a2                	ld	s1,8(sp)
    8000216e:	6105                	addi	sp,sp,32
    80002170:	8082                	ret

0000000080002172 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002172:	7179                	addi	sp,sp,-48
    80002174:	f406                	sd	ra,40(sp)
    80002176:	f022                	sd	s0,32(sp)
    80002178:	ec26                	sd	s1,24(sp)
    8000217a:	e84a                	sd	s2,16(sp)
    8000217c:	e44e                	sd	s3,8(sp)
    8000217e:	1800                	addi	s0,sp,48
    80002180:	89aa                	mv	s3,a0
    80002182:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002184:	00000097          	auipc	ra,0x0
    80002188:	828080e7          	jalr	-2008(ra) # 800019ac <myproc>
    8000218c:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000218e:	fffff097          	auipc	ra,0xfffff
    80002192:	a48080e7          	jalr	-1464(ra) # 80000bd6 <acquire>
  release(lk);
    80002196:	854a                	mv	a0,s2
    80002198:	fffff097          	auipc	ra,0xfffff
    8000219c:	af2080e7          	jalr	-1294(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    800021a0:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800021a4:	4789                	li	a5,2
    800021a6:	cc9c                	sw	a5,24(s1)

  sched();
    800021a8:	00000097          	auipc	ra,0x0
    800021ac:	eb8080e7          	jalr	-328(ra) # 80002060 <sched>

  // Tidy up.
  p->chan = 0;
    800021b0:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800021b4:	8526                	mv	a0,s1
    800021b6:	fffff097          	auipc	ra,0xfffff
    800021ba:	ad4080e7          	jalr	-1324(ra) # 80000c8a <release>
  acquire(lk);
    800021be:	854a                	mv	a0,s2
    800021c0:	fffff097          	auipc	ra,0xfffff
    800021c4:	a16080e7          	jalr	-1514(ra) # 80000bd6 <acquire>
}
    800021c8:	70a2                	ld	ra,40(sp)
    800021ca:	7402                	ld	s0,32(sp)
    800021cc:	64e2                	ld	s1,24(sp)
    800021ce:	6942                	ld	s2,16(sp)
    800021d0:	69a2                	ld	s3,8(sp)
    800021d2:	6145                	addi	sp,sp,48
    800021d4:	8082                	ret

00000000800021d6 <waitx>:
{
    800021d6:	711d                	addi	sp,sp,-96
    800021d8:	ec86                	sd	ra,88(sp)
    800021da:	e8a2                	sd	s0,80(sp)
    800021dc:	e4a6                	sd	s1,72(sp)
    800021de:	e0ca                	sd	s2,64(sp)
    800021e0:	fc4e                	sd	s3,56(sp)
    800021e2:	f852                	sd	s4,48(sp)
    800021e4:	f456                	sd	s5,40(sp)
    800021e6:	f05a                	sd	s6,32(sp)
    800021e8:	ec5e                	sd	s7,24(sp)
    800021ea:	e862                	sd	s8,16(sp)
    800021ec:	e466                	sd	s9,8(sp)
    800021ee:	e06a                	sd	s10,0(sp)
    800021f0:	1080                	addi	s0,sp,96
    800021f2:	8b2a                	mv	s6,a0
    800021f4:	8bae                	mv	s7,a1
    800021f6:	8c32                	mv	s8,a2
  struct proc *p = myproc();
    800021f8:	fffff097          	auipc	ra,0xfffff
    800021fc:	7b4080e7          	jalr	1972(ra) # 800019ac <myproc>
    80002200:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002202:	0000f517          	auipc	a0,0xf
    80002206:	be650513          	addi	a0,a0,-1050 # 80010de8 <wait_lock>
    8000220a:	fffff097          	auipc	ra,0xfffff
    8000220e:	9cc080e7          	jalr	-1588(ra) # 80000bd6 <acquire>
    havekids = 0;
    80002212:	4c81                	li	s9,0
        if(np->state == ZOMBIE){
    80002214:	4a15                	li	s4,5
        havekids = 1;
    80002216:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002218:	00016997          	auipc	s3,0x16
    8000221c:	7e898993          	addi	s3,s3,2024 # 80018a00 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002220:	0000fd17          	auipc	s10,0xf
    80002224:	bc8d0d13          	addi	s10,s10,-1080 # 80010de8 <wait_lock>
    havekids = 0;
    80002228:	8766                	mv	a4,s9
    for(np = proc; np < &proc[NPROC]; np++){
    8000222a:	0000f497          	auipc	s1,0xf
    8000222e:	fd648493          	addi	s1,s1,-42 # 80011200 <proc>
    80002232:	a059                	j	800022b8 <waitx+0xe2>
          pid = np->pid;
    80002234:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    80002238:	16c4a703          	lw	a4,364(s1)
    8000223c:	00ec2023          	sw	a4,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    80002240:	1704a783          	lw	a5,368(s1)
    80002244:	9f3d                	addw	a4,a4,a5
    80002246:	1744a783          	lw	a5,372(s1)
    8000224a:	9f99                	subw	a5,a5,a4
    8000224c:	00fba023          	sw	a5,0(s7) # fffffffffffff000 <end+0xffffffff7ffdb220>
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002250:	000b0e63          	beqz	s6,8000226c <waitx+0x96>
    80002254:	4691                	li	a3,4
    80002256:	02c48613          	addi	a2,s1,44
    8000225a:	85da                	mv	a1,s6
    8000225c:	05093503          	ld	a0,80(s2)
    80002260:	fffff097          	auipc	ra,0xfffff
    80002264:	408080e7          	jalr	1032(ra) # 80001668 <copyout>
    80002268:	02054563          	bltz	a0,80002292 <waitx+0xbc>
          freeproc(np);
    8000226c:	8526                	mv	a0,s1
    8000226e:	00000097          	auipc	ra,0x0
    80002272:	8f0080e7          	jalr	-1808(ra) # 80001b5e <freeproc>
          release(&np->lock);
    80002276:	8526                	mv	a0,s1
    80002278:	fffff097          	auipc	ra,0xfffff
    8000227c:	a12080e7          	jalr	-1518(ra) # 80000c8a <release>
          release(&wait_lock);
    80002280:	0000f517          	auipc	a0,0xf
    80002284:	b6850513          	addi	a0,a0,-1176 # 80010de8 <wait_lock>
    80002288:	fffff097          	auipc	ra,0xfffff
    8000228c:	a02080e7          	jalr	-1534(ra) # 80000c8a <release>
          return pid;
    80002290:	a09d                	j	800022f6 <waitx+0x120>
            release(&np->lock);
    80002292:	8526                	mv	a0,s1
    80002294:	fffff097          	auipc	ra,0xfffff
    80002298:	9f6080e7          	jalr	-1546(ra) # 80000c8a <release>
            release(&wait_lock);
    8000229c:	0000f517          	auipc	a0,0xf
    800022a0:	b4c50513          	addi	a0,a0,-1204 # 80010de8 <wait_lock>
    800022a4:	fffff097          	auipc	ra,0xfffff
    800022a8:	9e6080e7          	jalr	-1562(ra) # 80000c8a <release>
            return -1;
    800022ac:	59fd                	li	s3,-1
    800022ae:	a0a1                	j	800022f6 <waitx+0x120>
    for(np = proc; np < &proc[NPROC]; np++){
    800022b0:	1e048493          	addi	s1,s1,480
    800022b4:	03348463          	beq	s1,s3,800022dc <waitx+0x106>
      if(np->parent == p){
    800022b8:	7c9c                	ld	a5,56(s1)
    800022ba:	ff279be3          	bne	a5,s2,800022b0 <waitx+0xda>
        acquire(&np->lock);
    800022be:	8526                	mv	a0,s1
    800022c0:	fffff097          	auipc	ra,0xfffff
    800022c4:	916080e7          	jalr	-1770(ra) # 80000bd6 <acquire>
        if(np->state == ZOMBIE){
    800022c8:	4c9c                	lw	a5,24(s1)
    800022ca:	f74785e3          	beq	a5,s4,80002234 <waitx+0x5e>
        release(&np->lock);
    800022ce:	8526                	mv	a0,s1
    800022d0:	fffff097          	auipc	ra,0xfffff
    800022d4:	9ba080e7          	jalr	-1606(ra) # 80000c8a <release>
        havekids = 1;
    800022d8:	8756                	mv	a4,s5
    800022da:	bfd9                	j	800022b0 <waitx+0xda>
    if(!havekids || p->killed){
    800022dc:	c701                	beqz	a4,800022e4 <waitx+0x10e>
    800022de:	02892783          	lw	a5,40(s2)
    800022e2:	cb8d                	beqz	a5,80002314 <waitx+0x13e>
      release(&wait_lock);
    800022e4:	0000f517          	auipc	a0,0xf
    800022e8:	b0450513          	addi	a0,a0,-1276 # 80010de8 <wait_lock>
    800022ec:	fffff097          	auipc	ra,0xfffff
    800022f0:	99e080e7          	jalr	-1634(ra) # 80000c8a <release>
      return -1;
    800022f4:	59fd                	li	s3,-1
}
    800022f6:	854e                	mv	a0,s3
    800022f8:	60e6                	ld	ra,88(sp)
    800022fa:	6446                	ld	s0,80(sp)
    800022fc:	64a6                	ld	s1,72(sp)
    800022fe:	6906                	ld	s2,64(sp)
    80002300:	79e2                	ld	s3,56(sp)
    80002302:	7a42                	ld	s4,48(sp)
    80002304:	7aa2                	ld	s5,40(sp)
    80002306:	7b02                	ld	s6,32(sp)
    80002308:	6be2                	ld	s7,24(sp)
    8000230a:	6c42                	ld	s8,16(sp)
    8000230c:	6ca2                	ld	s9,8(sp)
    8000230e:	6d02                	ld	s10,0(sp)
    80002310:	6125                	addi	sp,sp,96
    80002312:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002314:	85ea                	mv	a1,s10
    80002316:	854a                	mv	a0,s2
    80002318:	00000097          	auipc	ra,0x0
    8000231c:	e5a080e7          	jalr	-422(ra) # 80002172 <sleep>
    havekids = 0;
    80002320:	b721                	j	80002228 <waitx+0x52>

0000000080002322 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002322:	7139                	addi	sp,sp,-64
    80002324:	fc06                	sd	ra,56(sp)
    80002326:	f822                	sd	s0,48(sp)
    80002328:	f426                	sd	s1,40(sp)
    8000232a:	f04a                	sd	s2,32(sp)
    8000232c:	ec4e                	sd	s3,24(sp)
    8000232e:	e852                	sd	s4,16(sp)
    80002330:	e456                	sd	s5,8(sp)
    80002332:	0080                	addi	s0,sp,64
    80002334:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002336:	0000f497          	auipc	s1,0xf
    8000233a:	eca48493          	addi	s1,s1,-310 # 80011200 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000233e:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002340:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002342:	00016917          	auipc	s2,0x16
    80002346:	6be90913          	addi	s2,s2,1726 # 80018a00 <tickslock>
    8000234a:	a811                	j	8000235e <wakeup+0x3c>
      }
      release(&p->lock);
    8000234c:	8526                	mv	a0,s1
    8000234e:	fffff097          	auipc	ra,0xfffff
    80002352:	93c080e7          	jalr	-1732(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002356:	1e048493          	addi	s1,s1,480
    8000235a:	03248663          	beq	s1,s2,80002386 <wakeup+0x64>
    if(p != myproc()){
    8000235e:	fffff097          	auipc	ra,0xfffff
    80002362:	64e080e7          	jalr	1614(ra) # 800019ac <myproc>
    80002366:	fea488e3          	beq	s1,a0,80002356 <wakeup+0x34>
      acquire(&p->lock);
    8000236a:	8526                	mv	a0,s1
    8000236c:	fffff097          	auipc	ra,0xfffff
    80002370:	86a080e7          	jalr	-1942(ra) # 80000bd6 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002374:	4c9c                	lw	a5,24(s1)
    80002376:	fd379be3          	bne	a5,s3,8000234c <wakeup+0x2a>
    8000237a:	709c                	ld	a5,32(s1)
    8000237c:	fd4798e3          	bne	a5,s4,8000234c <wakeup+0x2a>
        p->state = RUNNABLE;
    80002380:	0154ac23          	sw	s5,24(s1)
    80002384:	b7e1                	j	8000234c <wakeup+0x2a>
    }
  }
}
    80002386:	70e2                	ld	ra,56(sp)
    80002388:	7442                	ld	s0,48(sp)
    8000238a:	74a2                	ld	s1,40(sp)
    8000238c:	7902                	ld	s2,32(sp)
    8000238e:	69e2                	ld	s3,24(sp)
    80002390:	6a42                	ld	s4,16(sp)
    80002392:	6aa2                	ld	s5,8(sp)
    80002394:	6121                	addi	sp,sp,64
    80002396:	8082                	ret

0000000080002398 <reparent>:
{
    80002398:	7179                	addi	sp,sp,-48
    8000239a:	f406                	sd	ra,40(sp)
    8000239c:	f022                	sd	s0,32(sp)
    8000239e:	ec26                	sd	s1,24(sp)
    800023a0:	e84a                	sd	s2,16(sp)
    800023a2:	e44e                	sd	s3,8(sp)
    800023a4:	e052                	sd	s4,0(sp)
    800023a6:	1800                	addi	s0,sp,48
    800023a8:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800023aa:	0000f497          	auipc	s1,0xf
    800023ae:	e5648493          	addi	s1,s1,-426 # 80011200 <proc>
      pp->parent = initproc;
    800023b2:	00006a17          	auipc	s4,0x6
    800023b6:	7a6a0a13          	addi	s4,s4,1958 # 80008b58 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800023ba:	00016997          	auipc	s3,0x16
    800023be:	64698993          	addi	s3,s3,1606 # 80018a00 <tickslock>
    800023c2:	a029                	j	800023cc <reparent+0x34>
    800023c4:	1e048493          	addi	s1,s1,480
    800023c8:	01348d63          	beq	s1,s3,800023e2 <reparent+0x4a>
    if(pp->parent == p){
    800023cc:	7c9c                	ld	a5,56(s1)
    800023ce:	ff279be3          	bne	a5,s2,800023c4 <reparent+0x2c>
      pp->parent = initproc;
    800023d2:	000a3503          	ld	a0,0(s4)
    800023d6:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800023d8:	00000097          	auipc	ra,0x0
    800023dc:	f4a080e7          	jalr	-182(ra) # 80002322 <wakeup>
    800023e0:	b7d5                	j	800023c4 <reparent+0x2c>
}
    800023e2:	70a2                	ld	ra,40(sp)
    800023e4:	7402                	ld	s0,32(sp)
    800023e6:	64e2                	ld	s1,24(sp)
    800023e8:	6942                	ld	s2,16(sp)
    800023ea:	69a2                	ld	s3,8(sp)
    800023ec:	6a02                	ld	s4,0(sp)
    800023ee:	6145                	addi	sp,sp,48
    800023f0:	8082                	ret

00000000800023f2 <exit>:
{
    800023f2:	7179                	addi	sp,sp,-48
    800023f4:	f406                	sd	ra,40(sp)
    800023f6:	f022                	sd	s0,32(sp)
    800023f8:	ec26                	sd	s1,24(sp)
    800023fa:	e84a                	sd	s2,16(sp)
    800023fc:	e44e                	sd	s3,8(sp)
    800023fe:	e052                	sd	s4,0(sp)
    80002400:	1800                	addi	s0,sp,48
    80002402:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002404:	fffff097          	auipc	ra,0xfffff
    80002408:	5a8080e7          	jalr	1448(ra) # 800019ac <myproc>
    8000240c:	89aa                	mv	s3,a0
  if(p == initproc)
    8000240e:	00006797          	auipc	a5,0x6
    80002412:	74a7b783          	ld	a5,1866(a5) # 80008b58 <initproc>
    80002416:	0d050493          	addi	s1,a0,208
    8000241a:	15050913          	addi	s2,a0,336
    8000241e:	02a79363          	bne	a5,a0,80002444 <exit+0x52>
    panic("init exiting");
    80002422:	00006517          	auipc	a0,0x6
    80002426:	e3e50513          	addi	a0,a0,-450 # 80008260 <digits+0x220>
    8000242a:	ffffe097          	auipc	ra,0xffffe
    8000242e:	114080e7          	jalr	276(ra) # 8000053e <panic>
      fileclose(f);
    80002432:	00002097          	auipc	ra,0x2
    80002436:	692080e7          	jalr	1682(ra) # 80004ac4 <fileclose>
      p->ofile[fd] = 0;
    8000243a:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000243e:	04a1                	addi	s1,s1,8
    80002440:	01248563          	beq	s1,s2,8000244a <exit+0x58>
    if(p->ofile[fd]){
    80002444:	6088                	ld	a0,0(s1)
    80002446:	f575                	bnez	a0,80002432 <exit+0x40>
    80002448:	bfdd                	j	8000243e <exit+0x4c>
  begin_op();
    8000244a:	00002097          	auipc	ra,0x2
    8000244e:	1ae080e7          	jalr	430(ra) # 800045f8 <begin_op>
  iput(p->cwd);
    80002452:	1509b503          	ld	a0,336(s3)
    80002456:	00002097          	auipc	ra,0x2
    8000245a:	99a080e7          	jalr	-1638(ra) # 80003df0 <iput>
  end_op();
    8000245e:	00002097          	auipc	ra,0x2
    80002462:	21a080e7          	jalr	538(ra) # 80004678 <end_op>
  p->cwd = 0;
    80002466:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000246a:	0000f497          	auipc	s1,0xf
    8000246e:	97e48493          	addi	s1,s1,-1666 # 80010de8 <wait_lock>
    80002472:	8526                	mv	a0,s1
    80002474:	ffffe097          	auipc	ra,0xffffe
    80002478:	762080e7          	jalr	1890(ra) # 80000bd6 <acquire>
  reparent(p);
    8000247c:	854e                	mv	a0,s3
    8000247e:	00000097          	auipc	ra,0x0
    80002482:	f1a080e7          	jalr	-230(ra) # 80002398 <reparent>
  wakeup(p->parent);
    80002486:	0389b503          	ld	a0,56(s3)
    8000248a:	00000097          	auipc	ra,0x0
    8000248e:	e98080e7          	jalr	-360(ra) # 80002322 <wakeup>
  acquire(&p->lock);
    80002492:	854e                	mv	a0,s3
    80002494:	ffffe097          	auipc	ra,0xffffe
    80002498:	742080e7          	jalr	1858(ra) # 80000bd6 <acquire>
  p->xstate = status;
    8000249c:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800024a0:	4795                	li	a5,5
    800024a2:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    800024a6:	00006797          	auipc	a5,0x6
    800024aa:	6ba7a783          	lw	a5,1722(a5) # 80008b60 <ticks>
    800024ae:	16f9aa23          	sw	a5,372(s3)
  release(&wait_lock);
    800024b2:	8526                	mv	a0,s1
    800024b4:	ffffe097          	auipc	ra,0xffffe
    800024b8:	7d6080e7          	jalr	2006(ra) # 80000c8a <release>
  sched();
    800024bc:	00000097          	auipc	ra,0x0
    800024c0:	ba4080e7          	jalr	-1116(ra) # 80002060 <sched>
  panic("zombie exit");
    800024c4:	00006517          	auipc	a0,0x6
    800024c8:	dac50513          	addi	a0,a0,-596 # 80008270 <digits+0x230>
    800024cc:	ffffe097          	auipc	ra,0xffffe
    800024d0:	072080e7          	jalr	114(ra) # 8000053e <panic>

00000000800024d4 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800024d4:	7179                	addi	sp,sp,-48
    800024d6:	f406                	sd	ra,40(sp)
    800024d8:	f022                	sd	s0,32(sp)
    800024da:	ec26                	sd	s1,24(sp)
    800024dc:	e84a                	sd	s2,16(sp)
    800024de:	e44e                	sd	s3,8(sp)
    800024e0:	1800                	addi	s0,sp,48
    800024e2:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800024e4:	0000f497          	auipc	s1,0xf
    800024e8:	d1c48493          	addi	s1,s1,-740 # 80011200 <proc>
    800024ec:	00016997          	auipc	s3,0x16
    800024f0:	51498993          	addi	s3,s3,1300 # 80018a00 <tickslock>
    acquire(&p->lock);
    800024f4:	8526                	mv	a0,s1
    800024f6:	ffffe097          	auipc	ra,0xffffe
    800024fa:	6e0080e7          	jalr	1760(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    800024fe:	589c                	lw	a5,48(s1)
    80002500:	01278d63          	beq	a5,s2,8000251a <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002504:	8526                	mv	a0,s1
    80002506:	ffffe097          	auipc	ra,0xffffe
    8000250a:	784080e7          	jalr	1924(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000250e:	1e048493          	addi	s1,s1,480
    80002512:	ff3491e3          	bne	s1,s3,800024f4 <kill+0x20>
  }
  return -1;
    80002516:	557d                	li	a0,-1
    80002518:	a829                	j	80002532 <kill+0x5e>
      p->killed = 1;
    8000251a:	4785                	li	a5,1
    8000251c:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000251e:	4c98                	lw	a4,24(s1)
    80002520:	4789                	li	a5,2
    80002522:	00f70f63          	beq	a4,a5,80002540 <kill+0x6c>
      release(&p->lock);
    80002526:	8526                	mv	a0,s1
    80002528:	ffffe097          	auipc	ra,0xffffe
    8000252c:	762080e7          	jalr	1890(ra) # 80000c8a <release>
      return 0;
    80002530:	4501                	li	a0,0
}
    80002532:	70a2                	ld	ra,40(sp)
    80002534:	7402                	ld	s0,32(sp)
    80002536:	64e2                	ld	s1,24(sp)
    80002538:	6942                	ld	s2,16(sp)
    8000253a:	69a2                	ld	s3,8(sp)
    8000253c:	6145                	addi	sp,sp,48
    8000253e:	8082                	ret
        p->state = RUNNABLE;
    80002540:	478d                	li	a5,3
    80002542:	cc9c                	sw	a5,24(s1)
    80002544:	b7cd                	j	80002526 <kill+0x52>

0000000080002546 <setkilled>:

void
setkilled(struct proc *p)
{
    80002546:	1101                	addi	sp,sp,-32
    80002548:	ec06                	sd	ra,24(sp)
    8000254a:	e822                	sd	s0,16(sp)
    8000254c:	e426                	sd	s1,8(sp)
    8000254e:	1000                	addi	s0,sp,32
    80002550:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002552:	ffffe097          	auipc	ra,0xffffe
    80002556:	684080e7          	jalr	1668(ra) # 80000bd6 <acquire>
  p->killed = 1;
    8000255a:	4785                	li	a5,1
    8000255c:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000255e:	8526                	mv	a0,s1
    80002560:	ffffe097          	auipc	ra,0xffffe
    80002564:	72a080e7          	jalr	1834(ra) # 80000c8a <release>
}
    80002568:	60e2                	ld	ra,24(sp)
    8000256a:	6442                	ld	s0,16(sp)
    8000256c:	64a2                	ld	s1,8(sp)
    8000256e:	6105                	addi	sp,sp,32
    80002570:	8082                	ret

0000000080002572 <killed>:

int
killed(struct proc *p)
{
    80002572:	1101                	addi	sp,sp,-32
    80002574:	ec06                	sd	ra,24(sp)
    80002576:	e822                	sd	s0,16(sp)
    80002578:	e426                	sd	s1,8(sp)
    8000257a:	e04a                	sd	s2,0(sp)
    8000257c:	1000                	addi	s0,sp,32
    8000257e:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002580:	ffffe097          	auipc	ra,0xffffe
    80002584:	656080e7          	jalr	1622(ra) # 80000bd6 <acquire>
  k = p->killed;
    80002588:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000258c:	8526                	mv	a0,s1
    8000258e:	ffffe097          	auipc	ra,0xffffe
    80002592:	6fc080e7          	jalr	1788(ra) # 80000c8a <release>
  return k;
}
    80002596:	854a                	mv	a0,s2
    80002598:	60e2                	ld	ra,24(sp)
    8000259a:	6442                	ld	s0,16(sp)
    8000259c:	64a2                	ld	s1,8(sp)
    8000259e:	6902                	ld	s2,0(sp)
    800025a0:	6105                	addi	sp,sp,32
    800025a2:	8082                	ret

00000000800025a4 <wait>:
{
    800025a4:	715d                	addi	sp,sp,-80
    800025a6:	e486                	sd	ra,72(sp)
    800025a8:	e0a2                	sd	s0,64(sp)
    800025aa:	fc26                	sd	s1,56(sp)
    800025ac:	f84a                	sd	s2,48(sp)
    800025ae:	f44e                	sd	s3,40(sp)
    800025b0:	f052                	sd	s4,32(sp)
    800025b2:	ec56                	sd	s5,24(sp)
    800025b4:	e85a                	sd	s6,16(sp)
    800025b6:	e45e                	sd	s7,8(sp)
    800025b8:	e062                	sd	s8,0(sp)
    800025ba:	0880                	addi	s0,sp,80
    800025bc:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800025be:	fffff097          	auipc	ra,0xfffff
    800025c2:	3ee080e7          	jalr	1006(ra) # 800019ac <myproc>
    800025c6:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800025c8:	0000f517          	auipc	a0,0xf
    800025cc:	82050513          	addi	a0,a0,-2016 # 80010de8 <wait_lock>
    800025d0:	ffffe097          	auipc	ra,0xffffe
    800025d4:	606080e7          	jalr	1542(ra) # 80000bd6 <acquire>
    havekids = 0;
    800025d8:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800025da:	4a15                	li	s4,5
        havekids = 1;
    800025dc:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800025de:	00016997          	auipc	s3,0x16
    800025e2:	42298993          	addi	s3,s3,1058 # 80018a00 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800025e6:	0000fc17          	auipc	s8,0xf
    800025ea:	802c0c13          	addi	s8,s8,-2046 # 80010de8 <wait_lock>
    havekids = 0;
    800025ee:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800025f0:	0000f497          	auipc	s1,0xf
    800025f4:	c1048493          	addi	s1,s1,-1008 # 80011200 <proc>
    800025f8:	a0bd                	j	80002666 <wait+0xc2>
          pid = pp->pid;
    800025fa:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800025fe:	000b0e63          	beqz	s6,8000261a <wait+0x76>
    80002602:	4691                	li	a3,4
    80002604:	02c48613          	addi	a2,s1,44
    80002608:	85da                	mv	a1,s6
    8000260a:	05093503          	ld	a0,80(s2)
    8000260e:	fffff097          	auipc	ra,0xfffff
    80002612:	05a080e7          	jalr	90(ra) # 80001668 <copyout>
    80002616:	02054563          	bltz	a0,80002640 <wait+0x9c>
          freeproc(pp);
    8000261a:	8526                	mv	a0,s1
    8000261c:	fffff097          	auipc	ra,0xfffff
    80002620:	542080e7          	jalr	1346(ra) # 80001b5e <freeproc>
          release(&pp->lock);
    80002624:	8526                	mv	a0,s1
    80002626:	ffffe097          	auipc	ra,0xffffe
    8000262a:	664080e7          	jalr	1636(ra) # 80000c8a <release>
          release(&wait_lock);
    8000262e:	0000e517          	auipc	a0,0xe
    80002632:	7ba50513          	addi	a0,a0,1978 # 80010de8 <wait_lock>
    80002636:	ffffe097          	auipc	ra,0xffffe
    8000263a:	654080e7          	jalr	1620(ra) # 80000c8a <release>
          return pid;
    8000263e:	a0b5                	j	800026aa <wait+0x106>
            release(&pp->lock);
    80002640:	8526                	mv	a0,s1
    80002642:	ffffe097          	auipc	ra,0xffffe
    80002646:	648080e7          	jalr	1608(ra) # 80000c8a <release>
            release(&wait_lock);
    8000264a:	0000e517          	auipc	a0,0xe
    8000264e:	79e50513          	addi	a0,a0,1950 # 80010de8 <wait_lock>
    80002652:	ffffe097          	auipc	ra,0xffffe
    80002656:	638080e7          	jalr	1592(ra) # 80000c8a <release>
            return -1;
    8000265a:	59fd                	li	s3,-1
    8000265c:	a0b9                	j	800026aa <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000265e:	1e048493          	addi	s1,s1,480
    80002662:	03348463          	beq	s1,s3,8000268a <wait+0xe6>
      if(pp->parent == p){
    80002666:	7c9c                	ld	a5,56(s1)
    80002668:	ff279be3          	bne	a5,s2,8000265e <wait+0xba>
        acquire(&pp->lock);
    8000266c:	8526                	mv	a0,s1
    8000266e:	ffffe097          	auipc	ra,0xffffe
    80002672:	568080e7          	jalr	1384(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    80002676:	4c9c                	lw	a5,24(s1)
    80002678:	f94781e3          	beq	a5,s4,800025fa <wait+0x56>
        release(&pp->lock);
    8000267c:	8526                	mv	a0,s1
    8000267e:	ffffe097          	auipc	ra,0xffffe
    80002682:	60c080e7          	jalr	1548(ra) # 80000c8a <release>
        havekids = 1;
    80002686:	8756                	mv	a4,s5
    80002688:	bfd9                	j	8000265e <wait+0xba>
    if(!havekids || killed(p)){
    8000268a:	c719                	beqz	a4,80002698 <wait+0xf4>
    8000268c:	854a                	mv	a0,s2
    8000268e:	00000097          	auipc	ra,0x0
    80002692:	ee4080e7          	jalr	-284(ra) # 80002572 <killed>
    80002696:	c51d                	beqz	a0,800026c4 <wait+0x120>
      release(&wait_lock);
    80002698:	0000e517          	auipc	a0,0xe
    8000269c:	75050513          	addi	a0,a0,1872 # 80010de8 <wait_lock>
    800026a0:	ffffe097          	auipc	ra,0xffffe
    800026a4:	5ea080e7          	jalr	1514(ra) # 80000c8a <release>
      return -1;
    800026a8:	59fd                	li	s3,-1
}
    800026aa:	854e                	mv	a0,s3
    800026ac:	60a6                	ld	ra,72(sp)
    800026ae:	6406                	ld	s0,64(sp)
    800026b0:	74e2                	ld	s1,56(sp)
    800026b2:	7942                	ld	s2,48(sp)
    800026b4:	79a2                	ld	s3,40(sp)
    800026b6:	7a02                	ld	s4,32(sp)
    800026b8:	6ae2                	ld	s5,24(sp)
    800026ba:	6b42                	ld	s6,16(sp)
    800026bc:	6ba2                	ld	s7,8(sp)
    800026be:	6c02                	ld	s8,0(sp)
    800026c0:	6161                	addi	sp,sp,80
    800026c2:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800026c4:	85e2                	mv	a1,s8
    800026c6:	854a                	mv	a0,s2
    800026c8:	00000097          	auipc	ra,0x0
    800026cc:	aaa080e7          	jalr	-1366(ra) # 80002172 <sleep>
    havekids = 0;
    800026d0:	bf39                	j	800025ee <wait+0x4a>

00000000800026d2 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800026d2:	7179                	addi	sp,sp,-48
    800026d4:	f406                	sd	ra,40(sp)
    800026d6:	f022                	sd	s0,32(sp)
    800026d8:	ec26                	sd	s1,24(sp)
    800026da:	e84a                	sd	s2,16(sp)
    800026dc:	e44e                	sd	s3,8(sp)
    800026de:	e052                	sd	s4,0(sp)
    800026e0:	1800                	addi	s0,sp,48
    800026e2:	84aa                	mv	s1,a0
    800026e4:	892e                	mv	s2,a1
    800026e6:	89b2                	mv	s3,a2
    800026e8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800026ea:	fffff097          	auipc	ra,0xfffff
    800026ee:	2c2080e7          	jalr	706(ra) # 800019ac <myproc>
  if(user_dst){
    800026f2:	c08d                	beqz	s1,80002714 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800026f4:	86d2                	mv	a3,s4
    800026f6:	864e                	mv	a2,s3
    800026f8:	85ca                	mv	a1,s2
    800026fa:	6928                	ld	a0,80(a0)
    800026fc:	fffff097          	auipc	ra,0xfffff
    80002700:	f6c080e7          	jalr	-148(ra) # 80001668 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002704:	70a2                	ld	ra,40(sp)
    80002706:	7402                	ld	s0,32(sp)
    80002708:	64e2                	ld	s1,24(sp)
    8000270a:	6942                	ld	s2,16(sp)
    8000270c:	69a2                	ld	s3,8(sp)
    8000270e:	6a02                	ld	s4,0(sp)
    80002710:	6145                	addi	sp,sp,48
    80002712:	8082                	ret
    memmove((char *)dst, src, len);
    80002714:	000a061b          	sext.w	a2,s4
    80002718:	85ce                	mv	a1,s3
    8000271a:	854a                	mv	a0,s2
    8000271c:	ffffe097          	auipc	ra,0xffffe
    80002720:	612080e7          	jalr	1554(ra) # 80000d2e <memmove>
    return 0;
    80002724:	8526                	mv	a0,s1
    80002726:	bff9                	j	80002704 <either_copyout+0x32>

0000000080002728 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002728:	7179                	addi	sp,sp,-48
    8000272a:	f406                	sd	ra,40(sp)
    8000272c:	f022                	sd	s0,32(sp)
    8000272e:	ec26                	sd	s1,24(sp)
    80002730:	e84a                	sd	s2,16(sp)
    80002732:	e44e                	sd	s3,8(sp)
    80002734:	e052                	sd	s4,0(sp)
    80002736:	1800                	addi	s0,sp,48
    80002738:	892a                	mv	s2,a0
    8000273a:	84ae                	mv	s1,a1
    8000273c:	89b2                	mv	s3,a2
    8000273e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002740:	fffff097          	auipc	ra,0xfffff
    80002744:	26c080e7          	jalr	620(ra) # 800019ac <myproc>
  if(user_src){
    80002748:	c08d                	beqz	s1,8000276a <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    8000274a:	86d2                	mv	a3,s4
    8000274c:	864e                	mv	a2,s3
    8000274e:	85ca                	mv	a1,s2
    80002750:	6928                	ld	a0,80(a0)
    80002752:	fffff097          	auipc	ra,0xfffff
    80002756:	fa2080e7          	jalr	-94(ra) # 800016f4 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000275a:	70a2                	ld	ra,40(sp)
    8000275c:	7402                	ld	s0,32(sp)
    8000275e:	64e2                	ld	s1,24(sp)
    80002760:	6942                	ld	s2,16(sp)
    80002762:	69a2                	ld	s3,8(sp)
    80002764:	6a02                	ld	s4,0(sp)
    80002766:	6145                	addi	sp,sp,48
    80002768:	8082                	ret
    memmove(dst, (char*)src, len);
    8000276a:	000a061b          	sext.w	a2,s4
    8000276e:	85ce                	mv	a1,s3
    80002770:	854a                	mv	a0,s2
    80002772:	ffffe097          	auipc	ra,0xffffe
    80002776:	5bc080e7          	jalr	1468(ra) # 80000d2e <memmove>
    return 0;
    8000277a:	8526                	mv	a0,s1
    8000277c:	bff9                	j	8000275a <either_copyin+0x32>

000000008000277e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000277e:	715d                	addi	sp,sp,-80
    80002780:	e486                	sd	ra,72(sp)
    80002782:	e0a2                	sd	s0,64(sp)
    80002784:	fc26                	sd	s1,56(sp)
    80002786:	f84a                	sd	s2,48(sp)
    80002788:	f44e                	sd	s3,40(sp)
    8000278a:	f052                	sd	s4,32(sp)
    8000278c:	ec56                	sd	s5,24(sp)
    8000278e:	e85a                	sd	s6,16(sp)
    80002790:	e45e                	sd	s7,8(sp)
    80002792:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002794:	00006517          	auipc	a0,0x6
    80002798:	93450513          	addi	a0,a0,-1740 # 800080c8 <digits+0x88>
    8000279c:	ffffe097          	auipc	ra,0xffffe
    800027a0:	dec080e7          	jalr	-532(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800027a4:	0000f497          	auipc	s1,0xf
    800027a8:	bb448493          	addi	s1,s1,-1100 # 80011358 <proc+0x158>
    800027ac:	00016917          	auipc	s2,0x16
    800027b0:	3ac90913          	addi	s2,s2,940 # 80018b58 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027b4:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800027b6:	00006997          	auipc	s3,0x6
    800027ba:	aca98993          	addi	s3,s3,-1334 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    800027be:	00006a97          	auipc	s5,0x6
    800027c2:	acaa8a93          	addi	s5,s5,-1334 # 80008288 <digits+0x248>
    printf("\n");
    800027c6:	00006a17          	auipc	s4,0x6
    800027ca:	902a0a13          	addi	s4,s4,-1790 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027ce:	00006b97          	auipc	s7,0x6
    800027d2:	afab8b93          	addi	s7,s7,-1286 # 800082c8 <states.0>
    800027d6:	a00d                	j	800027f8 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800027d8:	ed86a583          	lw	a1,-296(a3)
    800027dc:	8556                	mv	a0,s5
    800027de:	ffffe097          	auipc	ra,0xffffe
    800027e2:	daa080e7          	jalr	-598(ra) # 80000588 <printf>
    printf("\n");
    800027e6:	8552                	mv	a0,s4
    800027e8:	ffffe097          	auipc	ra,0xffffe
    800027ec:	da0080e7          	jalr	-608(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800027f0:	1e048493          	addi	s1,s1,480
    800027f4:	03248163          	beq	s1,s2,80002816 <procdump+0x98>
    if(p->state == UNUSED)
    800027f8:	86a6                	mv	a3,s1
    800027fa:	ec04a783          	lw	a5,-320(s1)
    800027fe:	dbed                	beqz	a5,800027f0 <procdump+0x72>
      state = "???";
    80002800:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002802:	fcfb6be3          	bltu	s6,a5,800027d8 <procdump+0x5a>
    80002806:	1782                	slli	a5,a5,0x20
    80002808:	9381                	srli	a5,a5,0x20
    8000280a:	078e                	slli	a5,a5,0x3
    8000280c:	97de                	add	a5,a5,s7
    8000280e:	6390                	ld	a2,0(a5)
    80002810:	f661                	bnez	a2,800027d8 <procdump+0x5a>
      state = "???";
    80002812:	864e                	mv	a2,s3
    80002814:	b7d1                	j	800027d8 <procdump+0x5a>
  }
}
    80002816:	60a6                	ld	ra,72(sp)
    80002818:	6406                	ld	s0,64(sp)
    8000281a:	74e2                	ld	s1,56(sp)
    8000281c:	7942                	ld	s2,48(sp)
    8000281e:	79a2                	ld	s3,40(sp)
    80002820:	7a02                	ld	s4,32(sp)
    80002822:	6ae2                	ld	s5,24(sp)
    80002824:	6b42                	ld	s6,16(sp)
    80002826:	6ba2                	ld	s7,8(sp)
    80002828:	6161                	addi	sp,sp,80
    8000282a:	8082                	ret

000000008000282c <setpriority>:

int
setpriority(int new_priority, int pid)
{
    8000282c:	7179                	addi	sp,sp,-48
    8000282e:	f406                	sd	ra,40(sp)
    80002830:	f022                	sd	s0,32(sp)
    80002832:	ec26                	sd	s1,24(sp)
    80002834:	e84a                	sd	s2,16(sp)
    80002836:	e44e                	sd	s3,8(sp)
    80002838:	e052                	sd	s4,0(sp)
    8000283a:	1800                	addi	s0,sp,48
    8000283c:	8a2a                	mv	s4,a0
    8000283e:	892e                	mv	s2,a1
  int prev_priority;
  prev_priority = 0;

  struct proc* p;
  for(p = proc; p < &proc[NPROC]; p++)
    80002840:	0000f497          	auipc	s1,0xf
    80002844:	9c048493          	addi	s1,s1,-1600 # 80011200 <proc>
    80002848:	00016997          	auipc	s3,0x16
    8000284c:	1b898993          	addi	s3,s3,440 # 80018a00 <tickslock>
  {
    acquire(&p->lock);
    80002850:	8526                	mv	a0,s1
    80002852:	ffffe097          	auipc	ra,0xffffe
    80002856:	384080e7          	jalr	900(ra) # 80000bd6 <acquire>

    if(p->pid == pid)
    8000285a:	589c                	lw	a5,48(s1)
    8000285c:	01278d63          	beq	a5,s2,80002876 <setpriority+0x4a>
        yield();
      }

      break;
    }
    release(&p->lock);
    80002860:	8526                	mv	a0,s1
    80002862:	ffffe097          	auipc	ra,0xffffe
    80002866:	428080e7          	jalr	1064(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++)
    8000286a:	1e048493          	addi	s1,s1,480
    8000286e:	ff3491e3          	bne	s1,s3,80002850 <setpriority+0x24>
  prev_priority = 0;
    80002872:	4901                	li	s2,0
    80002874:	a005                	j	80002894 <setpriority+0x68>
      prev_priority = p->priority;
    80002876:	1d84a903          	lw	s2,472(s1)
      p->priority = new_priority;
    8000287a:	1d44bc23          	sd	s4,472(s1)
      p->sleeptime = 0;
    8000287e:	1c04b423          	sd	zero,456(s1)
      p->runtime = 0;
    80002882:	1a04bc23          	sd	zero,440(s1)
      release(&p->lock);
    80002886:	8526                	mv	a0,s1
    80002888:	ffffe097          	auipc	ra,0xffffe
    8000288c:	402080e7          	jalr	1026(ra) # 80000c8a <release>
      if(reschedule){
    80002890:	012a4b63          	blt	s4,s2,800028a6 <setpriority+0x7a>
  }
  return prev_priority;
}
    80002894:	854a                	mv	a0,s2
    80002896:	70a2                	ld	ra,40(sp)
    80002898:	7402                	ld	s0,32(sp)
    8000289a:	64e2                	ld	s1,24(sp)
    8000289c:	6942                	ld	s2,16(sp)
    8000289e:	69a2                	ld	s3,8(sp)
    800028a0:	6a02                	ld	s4,0(sp)
    800028a2:	6145                	addi	sp,sp,48
    800028a4:	8082                	ret
        yield();
    800028a6:	00000097          	auipc	ra,0x0
    800028aa:	890080e7          	jalr	-1904(ra) # 80002136 <yield>
    800028ae:	b7dd                	j	80002894 <setpriority+0x68>

00000000800028b0 <swtch>:
    800028b0:	00153023          	sd	ra,0(a0)
    800028b4:	00253423          	sd	sp,8(a0)
    800028b8:	e900                	sd	s0,16(a0)
    800028ba:	ed04                	sd	s1,24(a0)
    800028bc:	03253023          	sd	s2,32(a0)
    800028c0:	03353423          	sd	s3,40(a0)
    800028c4:	03453823          	sd	s4,48(a0)
    800028c8:	03553c23          	sd	s5,56(a0)
    800028cc:	05653023          	sd	s6,64(a0)
    800028d0:	05753423          	sd	s7,72(a0)
    800028d4:	05853823          	sd	s8,80(a0)
    800028d8:	05953c23          	sd	s9,88(a0)
    800028dc:	07a53023          	sd	s10,96(a0)
    800028e0:	07b53423          	sd	s11,104(a0)
    800028e4:	0005b083          	ld	ra,0(a1)
    800028e8:	0085b103          	ld	sp,8(a1)
    800028ec:	6980                	ld	s0,16(a1)
    800028ee:	6d84                	ld	s1,24(a1)
    800028f0:	0205b903          	ld	s2,32(a1)
    800028f4:	0285b983          	ld	s3,40(a1)
    800028f8:	0305ba03          	ld	s4,48(a1)
    800028fc:	0385ba83          	ld	s5,56(a1)
    80002900:	0405bb03          	ld	s6,64(a1)
    80002904:	0485bb83          	ld	s7,72(a1)
    80002908:	0505bc03          	ld	s8,80(a1)
    8000290c:	0585bc83          	ld	s9,88(a1)
    80002910:	0605bd03          	ld	s10,96(a1)
    80002914:	0685bd83          	ld	s11,104(a1)
    80002918:	8082                	ret

000000008000291a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000291a:	1141                	addi	sp,sp,-16
    8000291c:	e406                	sd	ra,8(sp)
    8000291e:	e022                	sd	s0,0(sp)
    80002920:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002922:	00006597          	auipc	a1,0x6
    80002926:	9d658593          	addi	a1,a1,-1578 # 800082f8 <states.0+0x30>
    8000292a:	00016517          	auipc	a0,0x16
    8000292e:	0d650513          	addi	a0,a0,214 # 80018a00 <tickslock>
    80002932:	ffffe097          	auipc	ra,0xffffe
    80002936:	214080e7          	jalr	532(ra) # 80000b46 <initlock>
}
    8000293a:	60a2                	ld	ra,8(sp)
    8000293c:	6402                	ld	s0,0(sp)
    8000293e:	0141                	addi	sp,sp,16
    80002940:	8082                	ret

0000000080002942 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002942:	1141                	addi	sp,sp,-16
    80002944:	e422                	sd	s0,8(sp)
    80002946:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002948:	00003797          	auipc	a5,0x3
    8000294c:	7c878793          	addi	a5,a5,1992 # 80006110 <kernelvec>
    80002950:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002954:	6422                	ld	s0,8(sp)
    80002956:	0141                	addi	sp,sp,16
    80002958:	8082                	ret

000000008000295a <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000295a:	1141                	addi	sp,sp,-16
    8000295c:	e406                	sd	ra,8(sp)
    8000295e:	e022                	sd	s0,0(sp)
    80002960:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002962:	fffff097          	auipc	ra,0xfffff
    80002966:	04a080e7          	jalr	74(ra) # 800019ac <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000296a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000296e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002970:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002974:	00004617          	auipc	a2,0x4
    80002978:	68c60613          	addi	a2,a2,1676 # 80007000 <_trampoline>
    8000297c:	00004697          	auipc	a3,0x4
    80002980:	68468693          	addi	a3,a3,1668 # 80007000 <_trampoline>
    80002984:	8e91                	sub	a3,a3,a2
    80002986:	040007b7          	lui	a5,0x4000
    8000298a:	17fd                	addi	a5,a5,-1
    8000298c:	07b2                	slli	a5,a5,0xc
    8000298e:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002990:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002994:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002996:	180026f3          	csrr	a3,satp
    8000299a:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000299c:	6d38                	ld	a4,88(a0)
    8000299e:	6134                	ld	a3,64(a0)
    800029a0:	6585                	lui	a1,0x1
    800029a2:	96ae                	add	a3,a3,a1
    800029a4:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800029a6:	6d38                	ld	a4,88(a0)
    800029a8:	00000697          	auipc	a3,0x0
    800029ac:	13e68693          	addi	a3,a3,318 # 80002ae6 <usertrap>
    800029b0:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800029b2:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800029b4:	8692                	mv	a3,tp
    800029b6:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029b8:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800029bc:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800029c0:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029c4:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800029c8:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029ca:	6f18                	ld	a4,24(a4)
    800029cc:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800029d0:	6928                	ld	a0,80(a0)
    800029d2:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800029d4:	00004717          	auipc	a4,0x4
    800029d8:	6c870713          	addi	a4,a4,1736 # 8000709c <userret>
    800029dc:	8f11                	sub	a4,a4,a2
    800029de:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800029e0:	577d                	li	a4,-1
    800029e2:	177e                	slli	a4,a4,0x3f
    800029e4:	8d59                	or	a0,a0,a4
    800029e6:	9782                	jalr	a5
}
    800029e8:	60a2                	ld	ra,8(sp)
    800029ea:	6402                	ld	s0,0(sp)
    800029ec:	0141                	addi	sp,sp,16
    800029ee:	8082                	ret

00000000800029f0 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800029f0:	1101                	addi	sp,sp,-32
    800029f2:	ec06                	sd	ra,24(sp)
    800029f4:	e822                	sd	s0,16(sp)
    800029f6:	e426                	sd	s1,8(sp)
    800029f8:	e04a                	sd	s2,0(sp)
    800029fa:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800029fc:	00016917          	auipc	s2,0x16
    80002a00:	00490913          	addi	s2,s2,4 # 80018a00 <tickslock>
    80002a04:	854a                	mv	a0,s2
    80002a06:	ffffe097          	auipc	ra,0xffffe
    80002a0a:	1d0080e7          	jalr	464(ra) # 80000bd6 <acquire>
  ticks++;
    80002a0e:	00006497          	auipc	s1,0x6
    80002a12:	15248493          	addi	s1,s1,338 # 80008b60 <ticks>
    80002a16:	409c                	lw	a5,0(s1)
    80002a18:	2785                	addiw	a5,a5,1
    80002a1a:	c09c                	sw	a5,0(s1)
  update_time();
    80002a1c:	fffff097          	auipc	ra,0xfffff
    80002a20:	518080e7          	jalr	1304(ra) # 80001f34 <update_time>
  wakeup(&ticks);
    80002a24:	8526                	mv	a0,s1
    80002a26:	00000097          	auipc	ra,0x0
    80002a2a:	8fc080e7          	jalr	-1796(ra) # 80002322 <wakeup>
  release(&tickslock);
    80002a2e:	854a                	mv	a0,s2
    80002a30:	ffffe097          	auipc	ra,0xffffe
    80002a34:	25a080e7          	jalr	602(ra) # 80000c8a <release>
}
    80002a38:	60e2                	ld	ra,24(sp)
    80002a3a:	6442                	ld	s0,16(sp)
    80002a3c:	64a2                	ld	s1,8(sp)
    80002a3e:	6902                	ld	s2,0(sp)
    80002a40:	6105                	addi	sp,sp,32
    80002a42:	8082                	ret

0000000080002a44 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002a44:	1101                	addi	sp,sp,-32
    80002a46:	ec06                	sd	ra,24(sp)
    80002a48:	e822                	sd	s0,16(sp)
    80002a4a:	e426                	sd	s1,8(sp)
    80002a4c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a4e:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002a52:	00074d63          	bltz	a4,80002a6c <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002a56:	57fd                	li	a5,-1
    80002a58:	17fe                	slli	a5,a5,0x3f
    80002a5a:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002a5c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002a5e:	06f70363          	beq	a4,a5,80002ac4 <devintr+0x80>
  }
}
    80002a62:	60e2                	ld	ra,24(sp)
    80002a64:	6442                	ld	s0,16(sp)
    80002a66:	64a2                	ld	s1,8(sp)
    80002a68:	6105                	addi	sp,sp,32
    80002a6a:	8082                	ret
     (scause & 0xff) == 9){
    80002a6c:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002a70:	46a5                	li	a3,9
    80002a72:	fed792e3          	bne	a5,a3,80002a56 <devintr+0x12>
    int irq = plic_claim();
    80002a76:	00003097          	auipc	ra,0x3
    80002a7a:	7a2080e7          	jalr	1954(ra) # 80006218 <plic_claim>
    80002a7e:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002a80:	47a9                	li	a5,10
    80002a82:	02f50763          	beq	a0,a5,80002ab0 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002a86:	4785                	li	a5,1
    80002a88:	02f50963          	beq	a0,a5,80002aba <devintr+0x76>
    return 1;
    80002a8c:	4505                	li	a0,1
    } else if(irq){
    80002a8e:	d8f1                	beqz	s1,80002a62 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002a90:	85a6                	mv	a1,s1
    80002a92:	00006517          	auipc	a0,0x6
    80002a96:	86e50513          	addi	a0,a0,-1938 # 80008300 <states.0+0x38>
    80002a9a:	ffffe097          	auipc	ra,0xffffe
    80002a9e:	aee080e7          	jalr	-1298(ra) # 80000588 <printf>
      plic_complete(irq);
    80002aa2:	8526                	mv	a0,s1
    80002aa4:	00003097          	auipc	ra,0x3
    80002aa8:	798080e7          	jalr	1944(ra) # 8000623c <plic_complete>
    return 1;
    80002aac:	4505                	li	a0,1
    80002aae:	bf55                	j	80002a62 <devintr+0x1e>
      uartintr();
    80002ab0:	ffffe097          	auipc	ra,0xffffe
    80002ab4:	eea080e7          	jalr	-278(ra) # 8000099a <uartintr>
    80002ab8:	b7ed                	j	80002aa2 <devintr+0x5e>
      virtio_disk_intr();
    80002aba:	00004097          	auipc	ra,0x4
    80002abe:	c4e080e7          	jalr	-946(ra) # 80006708 <virtio_disk_intr>
    80002ac2:	b7c5                	j	80002aa2 <devintr+0x5e>
    if(cpuid() == 0){
    80002ac4:	fffff097          	auipc	ra,0xfffff
    80002ac8:	ebc080e7          	jalr	-324(ra) # 80001980 <cpuid>
    80002acc:	c901                	beqz	a0,80002adc <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002ace:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002ad2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002ad4:	14479073          	csrw	sip,a5
    return 2;
    80002ad8:	4509                	li	a0,2
    80002ada:	b761                	j	80002a62 <devintr+0x1e>
      clockintr();
    80002adc:	00000097          	auipc	ra,0x0
    80002ae0:	f14080e7          	jalr	-236(ra) # 800029f0 <clockintr>
    80002ae4:	b7ed                	j	80002ace <devintr+0x8a>

0000000080002ae6 <usertrap>:
{
    80002ae6:	1101                	addi	sp,sp,-32
    80002ae8:	ec06                	sd	ra,24(sp)
    80002aea:	e822                	sd	s0,16(sp)
    80002aec:	e426                	sd	s1,8(sp)
    80002aee:	e04a                	sd	s2,0(sp)
    80002af0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002af2:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002af6:	1007f793          	andi	a5,a5,256
    80002afa:	e3b1                	bnez	a5,80002b3e <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002afc:	00003797          	auipc	a5,0x3
    80002b00:	61478793          	addi	a5,a5,1556 # 80006110 <kernelvec>
    80002b04:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002b08:	fffff097          	auipc	ra,0xfffff
    80002b0c:	ea4080e7          	jalr	-348(ra) # 800019ac <myproc>
    80002b10:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002b12:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b14:	14102773          	csrr	a4,sepc
    80002b18:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b1a:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002b1e:	47a1                	li	a5,8
    80002b20:	02f70763          	beq	a4,a5,80002b4e <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002b24:	00000097          	auipc	ra,0x0
    80002b28:	f20080e7          	jalr	-224(ra) # 80002a44 <devintr>
    80002b2c:	892a                	mv	s2,a0
    80002b2e:	c92d                	beqz	a0,80002ba0 <usertrap+0xba>
  if(killed(p))
    80002b30:	8526                	mv	a0,s1
    80002b32:	00000097          	auipc	ra,0x0
    80002b36:	a40080e7          	jalr	-1472(ra) # 80002572 <killed>
    80002b3a:	c555                	beqz	a0,80002be6 <usertrap+0x100>
    80002b3c:	a045                	j	80002bdc <usertrap+0xf6>
    panic("usertrap: not from user mode");
    80002b3e:	00005517          	auipc	a0,0x5
    80002b42:	7e250513          	addi	a0,a0,2018 # 80008320 <states.0+0x58>
    80002b46:	ffffe097          	auipc	ra,0xffffe
    80002b4a:	9f8080e7          	jalr	-1544(ra) # 8000053e <panic>
    if(killed(p))
    80002b4e:	00000097          	auipc	ra,0x0
    80002b52:	a24080e7          	jalr	-1500(ra) # 80002572 <killed>
    80002b56:	ed1d                	bnez	a0,80002b94 <usertrap+0xae>
    p->trapframe->epc += 4;
    80002b58:	6cb8                	ld	a4,88(s1)
    80002b5a:	6f1c                	ld	a5,24(a4)
    80002b5c:	0791                	addi	a5,a5,4
    80002b5e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b60:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b64:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b68:	10079073          	csrw	sstatus,a5
    syscall();
    80002b6c:	00000097          	auipc	ra,0x0
    80002b70:	328080e7          	jalr	808(ra) # 80002e94 <syscall>
  if(killed(p))
    80002b74:	8526                	mv	a0,s1
    80002b76:	00000097          	auipc	ra,0x0
    80002b7a:	9fc080e7          	jalr	-1540(ra) # 80002572 <killed>
    80002b7e:	ed31                	bnez	a0,80002bda <usertrap+0xf4>
  usertrapret();
    80002b80:	00000097          	auipc	ra,0x0
    80002b84:	dda080e7          	jalr	-550(ra) # 8000295a <usertrapret>
}
    80002b88:	60e2                	ld	ra,24(sp)
    80002b8a:	6442                	ld	s0,16(sp)
    80002b8c:	64a2                	ld	s1,8(sp)
    80002b8e:	6902                	ld	s2,0(sp)
    80002b90:	6105                	addi	sp,sp,32
    80002b92:	8082                	ret
      exit(-1);
    80002b94:	557d                	li	a0,-1
    80002b96:	00000097          	auipc	ra,0x0
    80002b9a:	85c080e7          	jalr	-1956(ra) # 800023f2 <exit>
    80002b9e:	bf6d                	j	80002b58 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ba0:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002ba4:	5890                	lw	a2,48(s1)
    80002ba6:	00005517          	auipc	a0,0x5
    80002baa:	79a50513          	addi	a0,a0,1946 # 80008340 <states.0+0x78>
    80002bae:	ffffe097          	auipc	ra,0xffffe
    80002bb2:	9da080e7          	jalr	-1574(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bb6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002bba:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002bbe:	00005517          	auipc	a0,0x5
    80002bc2:	7b250513          	addi	a0,a0,1970 # 80008370 <states.0+0xa8>
    80002bc6:	ffffe097          	auipc	ra,0xffffe
    80002bca:	9c2080e7          	jalr	-1598(ra) # 80000588 <printf>
    setkilled(p);
    80002bce:	8526                	mv	a0,s1
    80002bd0:	00000097          	auipc	ra,0x0
    80002bd4:	976080e7          	jalr	-1674(ra) # 80002546 <setkilled>
    80002bd8:	bf71                	j	80002b74 <usertrap+0x8e>
  if(killed(p))
    80002bda:	4901                	li	s2,0
    exit(-1);
    80002bdc:	557d                	li	a0,-1
    80002bde:	00000097          	auipc	ra,0x0
    80002be2:	814080e7          	jalr	-2028(ra) # 800023f2 <exit>
  if (which_dev == 2 && p->alarm_on == 1 && p->handlerpermission == 1) {
    80002be6:	4789                	li	a5,2
    80002be8:	f8f91ce3          	bne	s2,a5,80002b80 <usertrap+0x9a>
    80002bec:	1984a703          	lw	a4,408(s1)
    80002bf0:	4785                	li	a5,1
    80002bf2:	00f70763          	beq	a4,a5,80002c00 <usertrap+0x11a>
    yield();
    80002bf6:	fffff097          	auipc	ra,0xfffff
    80002bfa:	540080e7          	jalr	1344(ra) # 80002136 <yield>
    80002bfe:	b749                	j	80002b80 <usertrap+0x9a>
  if (which_dev == 2 && p->alarm_on == 1 && p->handlerpermission == 1) {
    80002c00:	1b04a703          	lw	a4,432(s1)
    80002c04:	fef719e3          	bne	a4,a5,80002bf6 <usertrap+0x110>
      struct trapframe *tf = kalloc();
    80002c08:	ffffe097          	auipc	ra,0xffffe
    80002c0c:	ede080e7          	jalr	-290(ra) # 80000ae6 <kalloc>
    80002c10:	892a                	mv	s2,a0
      memmove(tf, p->trapframe, PGSIZE);
    80002c12:	6605                	lui	a2,0x1
    80002c14:	6cac                	ld	a1,88(s1)
    80002c16:	ffffe097          	auipc	ra,0xffffe
    80002c1a:	118080e7          	jalr	280(ra) # 80000d2e <memmove>
      p->alarm_tf = tf;
    80002c1e:	1924b823          	sd	s2,400(s1)
      p->cur_ticks++;
    80002c22:	18c4a783          	lw	a5,396(s1)
    80002c26:	2785                	addiw	a5,a5,1
    80002c28:	0007871b          	sext.w	a4,a5
    80002c2c:	18f4a623          	sw	a5,396(s1)
      if (p->cur_ticks >= p->ticks){
    80002c30:	1884a783          	lw	a5,392(s1)
    80002c34:	fcf741e3          	blt	a4,a5,80002bf6 <usertrap+0x110>
        p->trapframe->epc = p->handler;
    80002c38:	6cbc                	ld	a5,88(s1)
    80002c3a:	1804b703          	ld	a4,384(s1)
    80002c3e:	ef98                	sd	a4,24(a5)
        p->handlerpermission = 0;
    80002c40:	1a04a823          	sw	zero,432(s1)
    80002c44:	bf4d                	j	80002bf6 <usertrap+0x110>

0000000080002c46 <kerneltrap>:
{
    80002c46:	7179                	addi	sp,sp,-48
    80002c48:	f406                	sd	ra,40(sp)
    80002c4a:	f022                	sd	s0,32(sp)
    80002c4c:	ec26                	sd	s1,24(sp)
    80002c4e:	e84a                	sd	s2,16(sp)
    80002c50:	e44e                	sd	s3,8(sp)
    80002c52:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c54:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c58:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c5c:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002c60:	1004f793          	andi	a5,s1,256
    80002c64:	cb85                	beqz	a5,80002c94 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c66:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c6a:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002c6c:	ef85                	bnez	a5,80002ca4 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002c6e:	00000097          	auipc	ra,0x0
    80002c72:	dd6080e7          	jalr	-554(ra) # 80002a44 <devintr>
    80002c76:	cd1d                	beqz	a0,80002cb4 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c78:	4789                	li	a5,2
    80002c7a:	06f50a63          	beq	a0,a5,80002cee <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c7e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c82:	10049073          	csrw	sstatus,s1
}
    80002c86:	70a2                	ld	ra,40(sp)
    80002c88:	7402                	ld	s0,32(sp)
    80002c8a:	64e2                	ld	s1,24(sp)
    80002c8c:	6942                	ld	s2,16(sp)
    80002c8e:	69a2                	ld	s3,8(sp)
    80002c90:	6145                	addi	sp,sp,48
    80002c92:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c94:	00005517          	auipc	a0,0x5
    80002c98:	6fc50513          	addi	a0,a0,1788 # 80008390 <states.0+0xc8>
    80002c9c:	ffffe097          	auipc	ra,0xffffe
    80002ca0:	8a2080e7          	jalr	-1886(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002ca4:	00005517          	auipc	a0,0x5
    80002ca8:	71450513          	addi	a0,a0,1812 # 800083b8 <states.0+0xf0>
    80002cac:	ffffe097          	auipc	ra,0xffffe
    80002cb0:	892080e7          	jalr	-1902(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002cb4:	85ce                	mv	a1,s3
    80002cb6:	00005517          	auipc	a0,0x5
    80002cba:	72250513          	addi	a0,a0,1826 # 800083d8 <states.0+0x110>
    80002cbe:	ffffe097          	auipc	ra,0xffffe
    80002cc2:	8ca080e7          	jalr	-1846(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cc6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002cca:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002cce:	00005517          	auipc	a0,0x5
    80002cd2:	71a50513          	addi	a0,a0,1818 # 800083e8 <states.0+0x120>
    80002cd6:	ffffe097          	auipc	ra,0xffffe
    80002cda:	8b2080e7          	jalr	-1870(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002cde:	00005517          	auipc	a0,0x5
    80002ce2:	72250513          	addi	a0,a0,1826 # 80008400 <states.0+0x138>
    80002ce6:	ffffe097          	auipc	ra,0xffffe
    80002cea:	858080e7          	jalr	-1960(ra) # 8000053e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002cee:	fffff097          	auipc	ra,0xfffff
    80002cf2:	cbe080e7          	jalr	-834(ra) # 800019ac <myproc>
    80002cf6:	d541                	beqz	a0,80002c7e <kerneltrap+0x38>
    80002cf8:	fffff097          	auipc	ra,0xfffff
    80002cfc:	cb4080e7          	jalr	-844(ra) # 800019ac <myproc>
    80002d00:	4d18                	lw	a4,24(a0)
    80002d02:	4791                	li	a5,4
    80002d04:	f6f71de3          	bne	a4,a5,80002c7e <kerneltrap+0x38>
    yield();
    80002d08:	fffff097          	auipc	ra,0xfffff
    80002d0c:	42e080e7          	jalr	1070(ra) # 80002136 <yield>
    80002d10:	b7bd                	j	80002c7e <kerneltrap+0x38>

0000000080002d12 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002d12:	1101                	addi	sp,sp,-32
    80002d14:	ec06                	sd	ra,24(sp)
    80002d16:	e822                	sd	s0,16(sp)
    80002d18:	e426                	sd	s1,8(sp)
    80002d1a:	1000                	addi	s0,sp,32
    80002d1c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002d1e:	fffff097          	auipc	ra,0xfffff
    80002d22:	c8e080e7          	jalr	-882(ra) # 800019ac <myproc>
  switch (n) {
    80002d26:	4795                	li	a5,5
    80002d28:	0497e163          	bltu	a5,s1,80002d6a <argraw+0x58>
    80002d2c:	048a                	slli	s1,s1,0x2
    80002d2e:	00006717          	auipc	a4,0x6
    80002d32:	82a70713          	addi	a4,a4,-2006 # 80008558 <states.0+0x290>
    80002d36:	94ba                	add	s1,s1,a4
    80002d38:	409c                	lw	a5,0(s1)
    80002d3a:	97ba                	add	a5,a5,a4
    80002d3c:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002d3e:	6d3c                	ld	a5,88(a0)
    80002d40:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002d42:	60e2                	ld	ra,24(sp)
    80002d44:	6442                	ld	s0,16(sp)
    80002d46:	64a2                	ld	s1,8(sp)
    80002d48:	6105                	addi	sp,sp,32
    80002d4a:	8082                	ret
    return p->trapframe->a1;
    80002d4c:	6d3c                	ld	a5,88(a0)
    80002d4e:	7fa8                	ld	a0,120(a5)
    80002d50:	bfcd                	j	80002d42 <argraw+0x30>
    return p->trapframe->a2;
    80002d52:	6d3c                	ld	a5,88(a0)
    80002d54:	63c8                	ld	a0,128(a5)
    80002d56:	b7f5                	j	80002d42 <argraw+0x30>
    return p->trapframe->a3;
    80002d58:	6d3c                	ld	a5,88(a0)
    80002d5a:	67c8                	ld	a0,136(a5)
    80002d5c:	b7dd                	j	80002d42 <argraw+0x30>
    return p->trapframe->a4;
    80002d5e:	6d3c                	ld	a5,88(a0)
    80002d60:	6bc8                	ld	a0,144(a5)
    80002d62:	b7c5                	j	80002d42 <argraw+0x30>
    return p->trapframe->a5;
    80002d64:	6d3c                	ld	a5,88(a0)
    80002d66:	6fc8                	ld	a0,152(a5)
    80002d68:	bfe9                	j	80002d42 <argraw+0x30>
  panic("argraw");
    80002d6a:	00005517          	auipc	a0,0x5
    80002d6e:	6a650513          	addi	a0,a0,1702 # 80008410 <states.0+0x148>
    80002d72:	ffffd097          	auipc	ra,0xffffd
    80002d76:	7cc080e7          	jalr	1996(ra) # 8000053e <panic>

0000000080002d7a <fetchaddr>:
{
    80002d7a:	1101                	addi	sp,sp,-32
    80002d7c:	ec06                	sd	ra,24(sp)
    80002d7e:	e822                	sd	s0,16(sp)
    80002d80:	e426                	sd	s1,8(sp)
    80002d82:	e04a                	sd	s2,0(sp)
    80002d84:	1000                	addi	s0,sp,32
    80002d86:	84aa                	mv	s1,a0
    80002d88:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d8a:	fffff097          	auipc	ra,0xfffff
    80002d8e:	c22080e7          	jalr	-990(ra) # 800019ac <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002d92:	653c                	ld	a5,72(a0)
    80002d94:	02f4f863          	bgeu	s1,a5,80002dc4 <fetchaddr+0x4a>
    80002d98:	00848713          	addi	a4,s1,8
    80002d9c:	02e7e663          	bltu	a5,a4,80002dc8 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002da0:	46a1                	li	a3,8
    80002da2:	8626                	mv	a2,s1
    80002da4:	85ca                	mv	a1,s2
    80002da6:	6928                	ld	a0,80(a0)
    80002da8:	fffff097          	auipc	ra,0xfffff
    80002dac:	94c080e7          	jalr	-1716(ra) # 800016f4 <copyin>
    80002db0:	00a03533          	snez	a0,a0
    80002db4:	40a00533          	neg	a0,a0
}
    80002db8:	60e2                	ld	ra,24(sp)
    80002dba:	6442                	ld	s0,16(sp)
    80002dbc:	64a2                	ld	s1,8(sp)
    80002dbe:	6902                	ld	s2,0(sp)
    80002dc0:	6105                	addi	sp,sp,32
    80002dc2:	8082                	ret
    return -1;
    80002dc4:	557d                	li	a0,-1
    80002dc6:	bfcd                	j	80002db8 <fetchaddr+0x3e>
    80002dc8:	557d                	li	a0,-1
    80002dca:	b7fd                	j	80002db8 <fetchaddr+0x3e>

0000000080002dcc <fetchstr>:
{
    80002dcc:	7179                	addi	sp,sp,-48
    80002dce:	f406                	sd	ra,40(sp)
    80002dd0:	f022                	sd	s0,32(sp)
    80002dd2:	ec26                	sd	s1,24(sp)
    80002dd4:	e84a                	sd	s2,16(sp)
    80002dd6:	e44e                	sd	s3,8(sp)
    80002dd8:	1800                	addi	s0,sp,48
    80002dda:	892a                	mv	s2,a0
    80002ddc:	84ae                	mv	s1,a1
    80002dde:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002de0:	fffff097          	auipc	ra,0xfffff
    80002de4:	bcc080e7          	jalr	-1076(ra) # 800019ac <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002de8:	86ce                	mv	a3,s3
    80002dea:	864a                	mv	a2,s2
    80002dec:	85a6                	mv	a1,s1
    80002dee:	6928                	ld	a0,80(a0)
    80002df0:	fffff097          	auipc	ra,0xfffff
    80002df4:	992080e7          	jalr	-1646(ra) # 80001782 <copyinstr>
    80002df8:	00054e63          	bltz	a0,80002e14 <fetchstr+0x48>
  return strlen(buf);
    80002dfc:	8526                	mv	a0,s1
    80002dfe:	ffffe097          	auipc	ra,0xffffe
    80002e02:	050080e7          	jalr	80(ra) # 80000e4e <strlen>
}
    80002e06:	70a2                	ld	ra,40(sp)
    80002e08:	7402                	ld	s0,32(sp)
    80002e0a:	64e2                	ld	s1,24(sp)
    80002e0c:	6942                	ld	s2,16(sp)
    80002e0e:	69a2                	ld	s3,8(sp)
    80002e10:	6145                	addi	sp,sp,48
    80002e12:	8082                	ret
    return -1;
    80002e14:	557d                	li	a0,-1
    80002e16:	bfc5                	j	80002e06 <fetchstr+0x3a>

0000000080002e18 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002e18:	1101                	addi	sp,sp,-32
    80002e1a:	ec06                	sd	ra,24(sp)
    80002e1c:	e822                	sd	s0,16(sp)
    80002e1e:	e426                	sd	s1,8(sp)
    80002e20:	1000                	addi	s0,sp,32
    80002e22:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e24:	00000097          	auipc	ra,0x0
    80002e28:	eee080e7          	jalr	-274(ra) # 80002d12 <argraw>
    80002e2c:	c088                	sw	a0,0(s1)
  return 0;
}
    80002e2e:	4501                	li	a0,0
    80002e30:	60e2                	ld	ra,24(sp)
    80002e32:	6442                	ld	s0,16(sp)
    80002e34:	64a2                	ld	s1,8(sp)
    80002e36:	6105                	addi	sp,sp,32
    80002e38:	8082                	ret

0000000080002e3a <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002e3a:	1101                	addi	sp,sp,-32
    80002e3c:	ec06                	sd	ra,24(sp)
    80002e3e:	e822                	sd	s0,16(sp)
    80002e40:	e426                	sd	s1,8(sp)
    80002e42:	1000                	addi	s0,sp,32
    80002e44:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e46:	00000097          	auipc	ra,0x0
    80002e4a:	ecc080e7          	jalr	-308(ra) # 80002d12 <argraw>
    80002e4e:	e088                	sd	a0,0(s1)
  return 0;
}
    80002e50:	4501                	li	a0,0
    80002e52:	60e2                	ld	ra,24(sp)
    80002e54:	6442                	ld	s0,16(sp)
    80002e56:	64a2                	ld	s1,8(sp)
    80002e58:	6105                	addi	sp,sp,32
    80002e5a:	8082                	ret

0000000080002e5c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002e5c:	7179                	addi	sp,sp,-48
    80002e5e:	f406                	sd	ra,40(sp)
    80002e60:	f022                	sd	s0,32(sp)
    80002e62:	ec26                	sd	s1,24(sp)
    80002e64:	e84a                	sd	s2,16(sp)
    80002e66:	1800                	addi	s0,sp,48
    80002e68:	84ae                	mv	s1,a1
    80002e6a:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002e6c:	fd840593          	addi	a1,s0,-40
    80002e70:	00000097          	auipc	ra,0x0
    80002e74:	fca080e7          	jalr	-54(ra) # 80002e3a <argaddr>
  return fetchstr(addr, buf, max);
    80002e78:	864a                	mv	a2,s2
    80002e7a:	85a6                	mv	a1,s1
    80002e7c:	fd843503          	ld	a0,-40(s0)
    80002e80:	00000097          	auipc	ra,0x0
    80002e84:	f4c080e7          	jalr	-180(ra) # 80002dcc <fetchstr>
}
    80002e88:	70a2                	ld	ra,40(sp)
    80002e8a:	7402                	ld	s0,32(sp)
    80002e8c:	64e2                	ld	s1,24(sp)
    80002e8e:	6942                	ld	s2,16(sp)
    80002e90:	6145                	addi	sp,sp,48
    80002e92:	8082                	ret

0000000080002e94 <syscall>:
    [SYS_setpriority] 1,
};

void
syscall(void)
{
    80002e94:	7179                	addi	sp,sp,-48
    80002e96:	f406                	sd	ra,40(sp)
    80002e98:	f022                	sd	s0,32(sp)
    80002e9a:	ec26                	sd	s1,24(sp)
    80002e9c:	e84a                	sd	s2,16(sp)
    80002e9e:	e44e                	sd	s3,8(sp)
    80002ea0:	e052                	sd	s4,0(sp)
    80002ea2:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002ea4:	fffff097          	auipc	ra,0xfffff
    80002ea8:	b08080e7          	jalr	-1272(ra) # 800019ac <myproc>
    80002eac:	892a                	mv	s2,a0

  num = p->trapframe->a7;
    80002eae:	6d24                	ld	s1,88(a0)
    80002eb0:	74dc                	ld	a5,168(s1)
    80002eb2:	0007899b          	sext.w	s3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) 
    80002eb6:	37fd                	addiw	a5,a5,-1
    80002eb8:	4769                	li	a4,26
    80002eba:	0af76163          	bltu	a4,a5,80002f5c <syscall+0xc8>
    80002ebe:	00399713          	slli	a4,s3,0x3
    80002ec2:	00005797          	auipc	a5,0x5
    80002ec6:	6ae78793          	addi	a5,a5,1710 # 80008570 <syscalls>
    80002eca:	97ba                	add	a5,a5,a4
    80002ecc:	639c                	ld	a5,0(a5)
    80002ece:	c7d9                	beqz	a5,80002f5c <syscall+0xc8>
  {
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002ed0:	9782                	jalr	a5
    80002ed2:	f8a8                	sd	a0,112(s1)
    if ((p->mask >> num) & 1)
    80002ed4:	16892483          	lw	s1,360(s2)
    80002ed8:	4134d4bb          	sraw	s1,s1,s3
    80002edc:	8885                	andi	s1,s1,1
    80002ede:	c0c5                	beqz	s1,80002f7e <syscall+0xea>
    {
      /* Modified for A4: Added entire section for trace, prints output for each syscall traced */
  	  printf("%d: syscall %s ( %d ",p->pid, syscallnames[num], p->trapframe->a0);
    80002ee0:	05893703          	ld	a4,88(s2)
    80002ee4:	00399693          	slli	a3,s3,0x3
    80002ee8:	00006797          	auipc	a5,0x6
    80002eec:	b6078793          	addi	a5,a5,-1184 # 80008a48 <syscallnames>
    80002ef0:	97b6                	add	a5,a5,a3
    80002ef2:	7b34                	ld	a3,112(a4)
    80002ef4:	6390                	ld	a2,0(a5)
    80002ef6:	03092583          	lw	a1,48(s2)
    80002efa:	00005517          	auipc	a0,0x5
    80002efe:	51e50513          	addi	a0,a0,1310 # 80008418 <states.0+0x150>
    80002f02:	ffffd097          	auipc	ra,0xffffd
    80002f06:	686080e7          	jalr	1670(ra) # 80000588 <printf>
      for (int i = 1; i < syscallnum[num]; i++) /* Modified for A4: 'num' tracks number of registers used by syscall and prints its register values  */
    80002f0a:	098a                	slli	s3,s3,0x2
    80002f0c:	00005797          	auipc	a5,0x5
    80002f10:	66478793          	addi	a5,a5,1636 # 80008570 <syscalls>
    80002f14:	99be                	add	s3,s3,a5
    80002f16:	0e09a983          	lw	s3,224(s3)
    80002f1a:	4785                	li	a5,1
    80002f1c:	0337d463          	bge	a5,s3,80002f44 <syscall+0xb0>
        printf("%d ", argraw(i));
    80002f20:	00005a17          	auipc	s4,0x5
    80002f24:	510a0a13          	addi	s4,s4,1296 # 80008430 <states.0+0x168>
    80002f28:	8526                	mv	a0,s1
    80002f2a:	00000097          	auipc	ra,0x0
    80002f2e:	de8080e7          	jalr	-536(ra) # 80002d12 <argraw>
    80002f32:	85aa                	mv	a1,a0
    80002f34:	8552                	mv	a0,s4
    80002f36:	ffffd097          	auipc	ra,0xffffd
    80002f3a:	652080e7          	jalr	1618(ra) # 80000588 <printf>
      for (int i = 1; i < syscallnum[num]; i++) /* Modified for A4: 'num' tracks number of registers used by syscall and prints its register values  */
    80002f3e:	2485                	addiw	s1,s1,1
    80002f40:	ff3494e3          	bne	s1,s3,80002f28 <syscall+0x94>
      printf(") -> %d\n", p->trapframe->a0);
    80002f44:	05893783          	ld	a5,88(s2)
    80002f48:	7bac                	ld	a1,112(a5)
    80002f4a:	00005517          	auipc	a0,0x5
    80002f4e:	4ee50513          	addi	a0,a0,1262 # 80008438 <states.0+0x170>
    80002f52:	ffffd097          	auipc	ra,0xffffd
    80002f56:	636080e7          	jalr	1590(ra) # 80000588 <printf>
    80002f5a:	a015                	j	80002f7e <syscall+0xea>
    }	
  } 
  else 
  {
    printf("%d %s: unknown sys call %d\n",
    80002f5c:	86ce                	mv	a3,s3
    80002f5e:	15890613          	addi	a2,s2,344
    80002f62:	03092583          	lw	a1,48(s2)
    80002f66:	00005517          	auipc	a0,0x5
    80002f6a:	4e250513          	addi	a0,a0,1250 # 80008448 <states.0+0x180>
    80002f6e:	ffffd097          	auipc	ra,0xffffd
    80002f72:	61a080e7          	jalr	1562(ra) # 80000588 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002f76:	05893783          	ld	a5,88(s2)
    80002f7a:	577d                	li	a4,-1
    80002f7c:	fbb8                	sd	a4,112(a5)
  
  // if (p->mask >> num)
  // {
  // 	printf("%d: syscall %s -> %d\n",p->pid, syscallnames[num], p->trapframe->a0);
  // }	
}
    80002f7e:	70a2                	ld	ra,40(sp)
    80002f80:	7402                	ld	s0,32(sp)
    80002f82:	64e2                	ld	s1,24(sp)
    80002f84:	6942                	ld	s2,16(sp)
    80002f86:	69a2                	ld	s3,8(sp)
    80002f88:	6a02                	ld	s4,0(sp)
    80002f8a:	6145                	addi	sp,sp,48
    80002f8c:	8082                	ret

0000000080002f8e <sys_trace>:

int mask;

uint64
sys_trace(void)
{
    80002f8e:	1141                	addi	sp,sp,-16
    80002f90:	e406                	sd	ra,8(sp)
    80002f92:	e022                	sd	s0,0(sp)
    80002f94:	0800                	addi	s0,sp,16
	if(argint(0, &mask) < 0)
    80002f96:	00006597          	auipc	a1,0x6
    80002f9a:	bce58593          	addi	a1,a1,-1074 # 80008b64 <mask>
    80002f9e:	4501                	li	a0,0
    80002fa0:	00000097          	auipc	ra,0x0
    80002fa4:	e78080e7          	jalr	-392(ra) # 80002e18 <argint>
	{
		return -1;
    80002fa8:	57fd                	li	a5,-1
	if(argint(0, &mask) < 0)
    80002faa:	00054d63          	bltz	a0,80002fc4 <sys_trace+0x36>
	}
	
  myproc()->mask = mask;
    80002fae:	fffff097          	auipc	ra,0xfffff
    80002fb2:	9fe080e7          	jalr	-1538(ra) # 800019ac <myproc>
    80002fb6:	00006797          	auipc	a5,0x6
    80002fba:	bae7a783          	lw	a5,-1106(a5) # 80008b64 <mask>
    80002fbe:	16f52423          	sw	a5,360(a0)
	return 0;
    80002fc2:	4781                	li	a5,0
}	/* Modified for A4: Added trace */
    80002fc4:	853e                	mv	a0,a5
    80002fc6:	60a2                	ld	ra,8(sp)
    80002fc8:	6402                	ld	s0,0(sp)
    80002fca:	0141                	addi	sp,sp,16
    80002fcc:	8082                	ret

0000000080002fce <sys_sigalarm>:

/* Modified for A4: Added trace */
uint64 
sys_sigalarm(void)
{
    80002fce:	1101                	addi	sp,sp,-32
    80002fd0:	ec06                	sd	ra,24(sp)
    80002fd2:	e822                	sd	s0,16(sp)
    80002fd4:	1000                	addi	s0,sp,32
  uint64 addr;
  int ticks;
  if(argint(0, &ticks) < 0)
    80002fd6:	fe440593          	addi	a1,s0,-28
    80002fda:	4501                	li	a0,0
    80002fdc:	00000097          	auipc	ra,0x0
    80002fe0:	e3c080e7          	jalr	-452(ra) # 80002e18 <argint>
    return -1;
    80002fe4:	57fd                	li	a5,-1
  if(argint(0, &ticks) < 0)
    80002fe6:	04054463          	bltz	a0,8000302e <sys_sigalarm+0x60>
  if(argaddr(1, &addr) < 0)
    80002fea:	fe840593          	addi	a1,s0,-24
    80002fee:	4505                	li	a0,1
    80002ff0:	00000097          	auipc	ra,0x0
    80002ff4:	e4a080e7          	jalr	-438(ra) # 80002e3a <argaddr>
    return -1;
    80002ff8:	57fd                	li	a5,-1
  if(argaddr(1, &addr) < 0)
    80002ffa:	02054a63          	bltz	a0,8000302e <sys_sigalarm+0x60>

  myproc()->ticks = ticks;
    80002ffe:	fffff097          	auipc	ra,0xfffff
    80003002:	9ae080e7          	jalr	-1618(ra) # 800019ac <myproc>
    80003006:	fe442783          	lw	a5,-28(s0)
    8000300a:	18f52423          	sw	a5,392(a0)
  myproc()->handler = addr;
    8000300e:	fffff097          	auipc	ra,0xfffff
    80003012:	99e080e7          	jalr	-1634(ra) # 800019ac <myproc>
    80003016:	fe843783          	ld	a5,-24(s0)
    8000301a:	18f53023          	sd	a5,384(a0)
  myproc()->alarm_on = 1;
    8000301e:	fffff097          	auipc	ra,0xfffff
    80003022:	98e080e7          	jalr	-1650(ra) # 800019ac <myproc>
    80003026:	4785                	li	a5,1
    80003028:	18f52c23          	sw	a5,408(a0)
  //myproc()->a1 = myproc()->trapframe->a0;
  //myproc()->a2 = myproc()->trapframe->a1;

  return 0;
    8000302c:	4781                	li	a5,0
}
    8000302e:	853e                	mv	a0,a5
    80003030:	60e2                	ld	ra,24(sp)
    80003032:	6442                	ld	s0,16(sp)
    80003034:	6105                	addi	sp,sp,32
    80003036:	8082                	ret

0000000080003038 <sys_sigreturn>:

/* Modified for A4: Added trace */
uint64 
sys_sigreturn(void)
{
    80003038:	1101                	addi	sp,sp,-32
    8000303a:	ec06                	sd	ra,24(sp)
    8000303c:	e822                	sd	s0,16(sp)
    8000303e:	e426                	sd	s1,8(sp)
    80003040:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80003042:	fffff097          	auipc	ra,0xfffff
    80003046:	96a080e7          	jalr	-1686(ra) # 800019ac <myproc>
    8000304a:	84aa                	mv	s1,a0
  memmove(p->trapframe, p->alarm_tf, PGSIZE);
    8000304c:	6605                	lui	a2,0x1
    8000304e:	19053583          	ld	a1,400(a0)
    80003052:	6d28                	ld	a0,88(a0)
    80003054:	ffffe097          	auipc	ra,0xffffe
    80003058:	cda080e7          	jalr	-806(ra) # 80000d2e <memmove>
  //myproc()->trapframe->a0 = myproc()->a1;
  //myproc()->trapframe->a1 = myproc()->a2;
  kfree(p->alarm_tf);
    8000305c:	1904b503          	ld	a0,400(s1)
    80003060:	ffffe097          	auipc	ra,0xffffe
    80003064:	98a080e7          	jalr	-1654(ra) # 800009ea <kfree>
  p->cur_ticks = 0;
    80003068:	1804a623          	sw	zero,396(s1)
  p->handlerpermission = 1;
    8000306c:	4785                	li	a5,1
    8000306e:	1af4a823          	sw	a5,432(s1)
  return myproc()->trapframe->a0;
    80003072:	fffff097          	auipc	ra,0xfffff
    80003076:	93a080e7          	jalr	-1734(ra) # 800019ac <myproc>
    8000307a:	6d3c                	ld	a5,88(a0)
}
    8000307c:	7ba8                	ld	a0,112(a5)
    8000307e:	60e2                	ld	ra,24(sp)
    80003080:	6442                	ld	s0,16(sp)
    80003082:	64a2                	ld	s1,8(sp)
    80003084:	6105                	addi	sp,sp,32
    80003086:	8082                	ret

0000000080003088 <sys_settickets>:

uint64 
sys_settickets(void)
{
    80003088:	7179                	addi	sp,sp,-48
    8000308a:	f406                	sd	ra,40(sp)
    8000308c:	f022                	sd	s0,32(sp)
    8000308e:	ec26                	sd	s1,24(sp)
    80003090:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80003092:	fffff097          	auipc	ra,0xfffff
    80003096:	91a080e7          	jalr	-1766(ra) # 800019ac <myproc>
    8000309a:	84aa                	mv	s1,a0
  int tickets;
  if(argint(0, &tickets) < 0)
    8000309c:	fdc40593          	addi	a1,s0,-36
    800030a0:	4501                	li	a0,0
    800030a2:	00000097          	auipc	ra,0x0
    800030a6:	d76080e7          	jalr	-650(ra) # 80002e18 <argint>
    800030aa:	00054c63          	bltz	a0,800030c2 <sys_settickets+0x3a>
    return -1;
  p->tickets = tickets;
    800030ae:	fdc42783          	lw	a5,-36(s0)
    800030b2:	1af4aa23          	sw	a5,436(s1)
  return 0; 
    800030b6:	4501                	li	a0,0
}
    800030b8:	70a2                	ld	ra,40(sp)
    800030ba:	7402                	ld	s0,32(sp)
    800030bc:	64e2                	ld	s1,24(sp)
    800030be:	6145                	addi	sp,sp,48
    800030c0:	8082                	ret
    return -1;
    800030c2:	557d                	li	a0,-1
    800030c4:	bfd5                	j	800030b8 <sys_settickets+0x30>

00000000800030c6 <sys_setpriority>:

uint64
sys_setpriority()
{
    800030c6:	1101                	addi	sp,sp,-32
    800030c8:	ec06                	sd	ra,24(sp)
    800030ca:	e822                	sd	s0,16(sp)
    800030cc:	1000                	addi	s0,sp,32
  int pid, priority;
  int arg_num[2] = {0, 1};

  if(argint(arg_num[0], &priority) < 0)
    800030ce:	fe840593          	addi	a1,s0,-24
    800030d2:	4501                	li	a0,0
    800030d4:	00000097          	auipc	ra,0x0
    800030d8:	d44080e7          	jalr	-700(ra) # 80002e18 <argint>
  {
    return -1;
    800030dc:	57fd                	li	a5,-1
  if(argint(arg_num[0], &priority) < 0)
    800030de:	02054563          	bltz	a0,80003108 <sys_setpriority+0x42>
  }
  if(argint(arg_num[1], &pid) < 0)
    800030e2:	fec40593          	addi	a1,s0,-20
    800030e6:	4505                	li	a0,1
    800030e8:	00000097          	auipc	ra,0x0
    800030ec:	d30080e7          	jalr	-720(ra) # 80002e18 <argint>
  {
    return -1;
    800030f0:	57fd                	li	a5,-1
  if(argint(arg_num[1], &pid) < 0)
    800030f2:	00054b63          	bltz	a0,80003108 <sys_setpriority+0x42>
  }
   
  return setpriority(priority, pid);
    800030f6:	fec42583          	lw	a1,-20(s0)
    800030fa:	fe842503          	lw	a0,-24(s0)
    800030fe:	fffff097          	auipc	ra,0xfffff
    80003102:	72e080e7          	jalr	1838(ra) # 8000282c <setpriority>
    80003106:	87aa                	mv	a5,a0
}
    80003108:	853e                	mv	a0,a5
    8000310a:	60e2                	ld	ra,24(sp)
    8000310c:	6442                	ld	s0,16(sp)
    8000310e:	6105                	addi	sp,sp,32
    80003110:	8082                	ret

0000000080003112 <sys_exit>:


uint64
sys_exit(void)
{
    80003112:	1101                	addi	sp,sp,-32
    80003114:	ec06                	sd	ra,24(sp)
    80003116:	e822                	sd	s0,16(sp)
    80003118:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    8000311a:	fec40593          	addi	a1,s0,-20
    8000311e:	4501                	li	a0,0
    80003120:	00000097          	auipc	ra,0x0
    80003124:	cf8080e7          	jalr	-776(ra) # 80002e18 <argint>
  exit(n);
    80003128:	fec42503          	lw	a0,-20(s0)
    8000312c:	fffff097          	auipc	ra,0xfffff
    80003130:	2c6080e7          	jalr	710(ra) # 800023f2 <exit>
  return 0;  // not reached
}
    80003134:	4501                	li	a0,0
    80003136:	60e2                	ld	ra,24(sp)
    80003138:	6442                	ld	s0,16(sp)
    8000313a:	6105                	addi	sp,sp,32
    8000313c:	8082                	ret

000000008000313e <sys_getpid>:

uint64
sys_getpid(void)
{
    8000313e:	1141                	addi	sp,sp,-16
    80003140:	e406                	sd	ra,8(sp)
    80003142:	e022                	sd	s0,0(sp)
    80003144:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003146:	fffff097          	auipc	ra,0xfffff
    8000314a:	866080e7          	jalr	-1946(ra) # 800019ac <myproc>
}
    8000314e:	5908                	lw	a0,48(a0)
    80003150:	60a2                	ld	ra,8(sp)
    80003152:	6402                	ld	s0,0(sp)
    80003154:	0141                	addi	sp,sp,16
    80003156:	8082                	ret

0000000080003158 <sys_fork>:

uint64
sys_fork(void)
{
    80003158:	1141                	addi	sp,sp,-16
    8000315a:	e406                	sd	ra,8(sp)
    8000315c:	e022                	sd	s0,0(sp)
    8000315e:	0800                	addi	s0,sp,16
  return fork();
    80003160:	fffff097          	auipc	ra,0xfffff
    80003164:	c5c080e7          	jalr	-932(ra) # 80001dbc <fork>
}
    80003168:	60a2                	ld	ra,8(sp)
    8000316a:	6402                	ld	s0,0(sp)
    8000316c:	0141                	addi	sp,sp,16
    8000316e:	8082                	ret

0000000080003170 <sys_wait>:

uint64
sys_wait(void)
{
    80003170:	1101                	addi	sp,sp,-32
    80003172:	ec06                	sd	ra,24(sp)
    80003174:	e822                	sd	s0,16(sp)
    80003176:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80003178:	fe840593          	addi	a1,s0,-24
    8000317c:	4501                	li	a0,0
    8000317e:	00000097          	auipc	ra,0x0
    80003182:	cbc080e7          	jalr	-836(ra) # 80002e3a <argaddr>
  return wait(p);
    80003186:	fe843503          	ld	a0,-24(s0)
    8000318a:	fffff097          	auipc	ra,0xfffff
    8000318e:	41a080e7          	jalr	1050(ra) # 800025a4 <wait>
}
    80003192:	60e2                	ld	ra,24(sp)
    80003194:	6442                	ld	s0,16(sp)
    80003196:	6105                	addi	sp,sp,32
    80003198:	8082                	ret

000000008000319a <sys_waitx>:

uint64
sys_waitx(void)
{
    8000319a:	7139                	addi	sp,sp,-64
    8000319c:	fc06                	sd	ra,56(sp)
    8000319e:	f822                	sd	s0,48(sp)
    800031a0:	f426                	sd	s1,40(sp)
    800031a2:	f04a                	sd	s2,32(sp)
    800031a4:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    800031a6:	fd840593          	addi	a1,s0,-40
    800031aa:	4501                	li	a0,0
    800031ac:	00000097          	auipc	ra,0x0
    800031b0:	c8e080e7          	jalr	-882(ra) # 80002e3a <argaddr>
  argaddr(1, &addr1); // user virtual memory
    800031b4:	fd040593          	addi	a1,s0,-48
    800031b8:	4505                	li	a0,1
    800031ba:	00000097          	auipc	ra,0x0
    800031be:	c80080e7          	jalr	-896(ra) # 80002e3a <argaddr>
  argaddr(2, &addr2);
    800031c2:	fc840593          	addi	a1,s0,-56
    800031c6:	4509                	li	a0,2
    800031c8:	00000097          	auipc	ra,0x0
    800031cc:	c72080e7          	jalr	-910(ra) # 80002e3a <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    800031d0:	fc040613          	addi	a2,s0,-64
    800031d4:	fc440593          	addi	a1,s0,-60
    800031d8:	fd843503          	ld	a0,-40(s0)
    800031dc:	fffff097          	auipc	ra,0xfffff
    800031e0:	ffa080e7          	jalr	-6(ra) # 800021d6 <waitx>
    800031e4:	892a                	mv	s2,a0
  struct proc* p = myproc();
    800031e6:	ffffe097          	auipc	ra,0xffffe
    800031ea:	7c6080e7          	jalr	1990(ra) # 800019ac <myproc>
    800031ee:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    800031f0:	4691                	li	a3,4
    800031f2:	fc440613          	addi	a2,s0,-60
    800031f6:	fd043583          	ld	a1,-48(s0)
    800031fa:	6928                	ld	a0,80(a0)
    800031fc:	ffffe097          	auipc	ra,0xffffe
    80003200:	46c080e7          	jalr	1132(ra) # 80001668 <copyout>
    return -1;
    80003204:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    80003206:	00054f63          	bltz	a0,80003224 <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2,(char*)&rtime, sizeof(int)) < 0)
    8000320a:	4691                	li	a3,4
    8000320c:	fc040613          	addi	a2,s0,-64
    80003210:	fc843583          	ld	a1,-56(s0)
    80003214:	68a8                	ld	a0,80(s1)
    80003216:	ffffe097          	auipc	ra,0xffffe
    8000321a:	452080e7          	jalr	1106(ra) # 80001668 <copyout>
    8000321e:	00054a63          	bltz	a0,80003232 <sys_waitx+0x98>
    return -1;
  return ret;
    80003222:	87ca                	mv	a5,s2
}
    80003224:	853e                	mv	a0,a5
    80003226:	70e2                	ld	ra,56(sp)
    80003228:	7442                	ld	s0,48(sp)
    8000322a:	74a2                	ld	s1,40(sp)
    8000322c:	7902                	ld	s2,32(sp)
    8000322e:	6121                	addi	sp,sp,64
    80003230:	8082                	ret
    return -1;
    80003232:	57fd                	li	a5,-1
    80003234:	bfc5                	j	80003224 <sys_waitx+0x8a>

0000000080003236 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003236:	7179                	addi	sp,sp,-48
    80003238:	f406                	sd	ra,40(sp)
    8000323a:	f022                	sd	s0,32(sp)
    8000323c:	ec26                	sd	s1,24(sp)
    8000323e:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80003240:	fdc40593          	addi	a1,s0,-36
    80003244:	4501                	li	a0,0
    80003246:	00000097          	auipc	ra,0x0
    8000324a:	bd2080e7          	jalr	-1070(ra) # 80002e18 <argint>
  addr = myproc()->sz;
    8000324e:	ffffe097          	auipc	ra,0xffffe
    80003252:	75e080e7          	jalr	1886(ra) # 800019ac <myproc>
    80003256:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80003258:	fdc42503          	lw	a0,-36(s0)
    8000325c:	fffff097          	auipc	ra,0xfffff
    80003260:	b04080e7          	jalr	-1276(ra) # 80001d60 <growproc>
    80003264:	00054863          	bltz	a0,80003274 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80003268:	8526                	mv	a0,s1
    8000326a:	70a2                	ld	ra,40(sp)
    8000326c:	7402                	ld	s0,32(sp)
    8000326e:	64e2                	ld	s1,24(sp)
    80003270:	6145                	addi	sp,sp,48
    80003272:	8082                	ret
    return -1;
    80003274:	54fd                	li	s1,-1
    80003276:	bfcd                	j	80003268 <sys_sbrk+0x32>

0000000080003278 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003278:	7139                	addi	sp,sp,-64
    8000327a:	fc06                	sd	ra,56(sp)
    8000327c:	f822                	sd	s0,48(sp)
    8000327e:	f426                	sd	s1,40(sp)
    80003280:	f04a                	sd	s2,32(sp)
    80003282:	ec4e                	sd	s3,24(sp)
    80003284:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80003286:	fcc40593          	addi	a1,s0,-52
    8000328a:	4501                	li	a0,0
    8000328c:	00000097          	auipc	ra,0x0
    80003290:	b8c080e7          	jalr	-1140(ra) # 80002e18 <argint>
  acquire(&tickslock);
    80003294:	00015517          	auipc	a0,0x15
    80003298:	76c50513          	addi	a0,a0,1900 # 80018a00 <tickslock>
    8000329c:	ffffe097          	auipc	ra,0xffffe
    800032a0:	93a080e7          	jalr	-1734(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    800032a4:	00006917          	auipc	s2,0x6
    800032a8:	8bc92903          	lw	s2,-1860(s2) # 80008b60 <ticks>
  while(ticks - ticks0 < n){
    800032ac:	fcc42783          	lw	a5,-52(s0)
    800032b0:	cf9d                	beqz	a5,800032ee <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800032b2:	00015997          	auipc	s3,0x15
    800032b6:	74e98993          	addi	s3,s3,1870 # 80018a00 <tickslock>
    800032ba:	00006497          	auipc	s1,0x6
    800032be:	8a648493          	addi	s1,s1,-1882 # 80008b60 <ticks>
    if(killed(myproc())){
    800032c2:	ffffe097          	auipc	ra,0xffffe
    800032c6:	6ea080e7          	jalr	1770(ra) # 800019ac <myproc>
    800032ca:	fffff097          	auipc	ra,0xfffff
    800032ce:	2a8080e7          	jalr	680(ra) # 80002572 <killed>
    800032d2:	ed15                	bnez	a0,8000330e <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    800032d4:	85ce                	mv	a1,s3
    800032d6:	8526                	mv	a0,s1
    800032d8:	fffff097          	auipc	ra,0xfffff
    800032dc:	e9a080e7          	jalr	-358(ra) # 80002172 <sleep>
  while(ticks - ticks0 < n){
    800032e0:	409c                	lw	a5,0(s1)
    800032e2:	412787bb          	subw	a5,a5,s2
    800032e6:	fcc42703          	lw	a4,-52(s0)
    800032ea:	fce7ece3          	bltu	a5,a4,800032c2 <sys_sleep+0x4a>
  }
  release(&tickslock);
    800032ee:	00015517          	auipc	a0,0x15
    800032f2:	71250513          	addi	a0,a0,1810 # 80018a00 <tickslock>
    800032f6:	ffffe097          	auipc	ra,0xffffe
    800032fa:	994080e7          	jalr	-1644(ra) # 80000c8a <release>
  return 0;
    800032fe:	4501                	li	a0,0
}
    80003300:	70e2                	ld	ra,56(sp)
    80003302:	7442                	ld	s0,48(sp)
    80003304:	74a2                	ld	s1,40(sp)
    80003306:	7902                	ld	s2,32(sp)
    80003308:	69e2                	ld	s3,24(sp)
    8000330a:	6121                	addi	sp,sp,64
    8000330c:	8082                	ret
      release(&tickslock);
    8000330e:	00015517          	auipc	a0,0x15
    80003312:	6f250513          	addi	a0,a0,1778 # 80018a00 <tickslock>
    80003316:	ffffe097          	auipc	ra,0xffffe
    8000331a:	974080e7          	jalr	-1676(ra) # 80000c8a <release>
      return -1;
    8000331e:	557d                	li	a0,-1
    80003320:	b7c5                	j	80003300 <sys_sleep+0x88>

0000000080003322 <sys_kill>:

uint64
sys_kill(void)
{
    80003322:	1101                	addi	sp,sp,-32
    80003324:	ec06                	sd	ra,24(sp)
    80003326:	e822                	sd	s0,16(sp)
    80003328:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    8000332a:	fec40593          	addi	a1,s0,-20
    8000332e:	4501                	li	a0,0
    80003330:	00000097          	auipc	ra,0x0
    80003334:	ae8080e7          	jalr	-1304(ra) # 80002e18 <argint>
  return kill(pid);
    80003338:	fec42503          	lw	a0,-20(s0)
    8000333c:	fffff097          	auipc	ra,0xfffff
    80003340:	198080e7          	jalr	408(ra) # 800024d4 <kill>
}
    80003344:	60e2                	ld	ra,24(sp)
    80003346:	6442                	ld	s0,16(sp)
    80003348:	6105                	addi	sp,sp,32
    8000334a:	8082                	ret

000000008000334c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000334c:	1101                	addi	sp,sp,-32
    8000334e:	ec06                	sd	ra,24(sp)
    80003350:	e822                	sd	s0,16(sp)
    80003352:	e426                	sd	s1,8(sp)
    80003354:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003356:	00015517          	auipc	a0,0x15
    8000335a:	6aa50513          	addi	a0,a0,1706 # 80018a00 <tickslock>
    8000335e:	ffffe097          	auipc	ra,0xffffe
    80003362:	878080e7          	jalr	-1928(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80003366:	00005497          	auipc	s1,0x5
    8000336a:	7fa4a483          	lw	s1,2042(s1) # 80008b60 <ticks>
  release(&tickslock);
    8000336e:	00015517          	auipc	a0,0x15
    80003372:	69250513          	addi	a0,a0,1682 # 80018a00 <tickslock>
    80003376:	ffffe097          	auipc	ra,0xffffe
    8000337a:	914080e7          	jalr	-1772(ra) # 80000c8a <release>
  return xticks;
}
    8000337e:	02049513          	slli	a0,s1,0x20
    80003382:	9101                	srli	a0,a0,0x20
    80003384:	60e2                	ld	ra,24(sp)
    80003386:	6442                	ld	s0,16(sp)
    80003388:	64a2                	ld	s1,8(sp)
    8000338a:	6105                	addi	sp,sp,32
    8000338c:	8082                	ret

000000008000338e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000338e:	7179                	addi	sp,sp,-48
    80003390:	f406                	sd	ra,40(sp)
    80003392:	f022                	sd	s0,32(sp)
    80003394:	ec26                	sd	s1,24(sp)
    80003396:	e84a                	sd	s2,16(sp)
    80003398:	e44e                	sd	s3,8(sp)
    8000339a:	e052                	sd	s4,0(sp)
    8000339c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000339e:	00005597          	auipc	a1,0x5
    800033a2:	32258593          	addi	a1,a1,802 # 800086c0 <syscallnum+0x70>
    800033a6:	00015517          	auipc	a0,0x15
    800033aa:	67250513          	addi	a0,a0,1650 # 80018a18 <bcache>
    800033ae:	ffffd097          	auipc	ra,0xffffd
    800033b2:	798080e7          	jalr	1944(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800033b6:	0001d797          	auipc	a5,0x1d
    800033ba:	66278793          	addi	a5,a5,1634 # 80020a18 <bcache+0x8000>
    800033be:	0001e717          	auipc	a4,0x1e
    800033c2:	8c270713          	addi	a4,a4,-1854 # 80020c80 <bcache+0x8268>
    800033c6:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800033ca:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800033ce:	00015497          	auipc	s1,0x15
    800033d2:	66248493          	addi	s1,s1,1634 # 80018a30 <bcache+0x18>
    b->next = bcache.head.next;
    800033d6:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800033d8:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800033da:	00005a17          	auipc	s4,0x5
    800033de:	2eea0a13          	addi	s4,s4,750 # 800086c8 <syscallnum+0x78>
    b->next = bcache.head.next;
    800033e2:	2b893783          	ld	a5,696(s2)
    800033e6:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800033e8:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800033ec:	85d2                	mv	a1,s4
    800033ee:	01048513          	addi	a0,s1,16
    800033f2:	00001097          	auipc	ra,0x1
    800033f6:	4c4080e7          	jalr	1220(ra) # 800048b6 <initsleeplock>
    bcache.head.next->prev = b;
    800033fa:	2b893783          	ld	a5,696(s2)
    800033fe:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003400:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003404:	45848493          	addi	s1,s1,1112
    80003408:	fd349de3          	bne	s1,s3,800033e2 <binit+0x54>
  }
}
    8000340c:	70a2                	ld	ra,40(sp)
    8000340e:	7402                	ld	s0,32(sp)
    80003410:	64e2                	ld	s1,24(sp)
    80003412:	6942                	ld	s2,16(sp)
    80003414:	69a2                	ld	s3,8(sp)
    80003416:	6a02                	ld	s4,0(sp)
    80003418:	6145                	addi	sp,sp,48
    8000341a:	8082                	ret

000000008000341c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000341c:	7179                	addi	sp,sp,-48
    8000341e:	f406                	sd	ra,40(sp)
    80003420:	f022                	sd	s0,32(sp)
    80003422:	ec26                	sd	s1,24(sp)
    80003424:	e84a                	sd	s2,16(sp)
    80003426:	e44e                	sd	s3,8(sp)
    80003428:	1800                	addi	s0,sp,48
    8000342a:	892a                	mv	s2,a0
    8000342c:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000342e:	00015517          	auipc	a0,0x15
    80003432:	5ea50513          	addi	a0,a0,1514 # 80018a18 <bcache>
    80003436:	ffffd097          	auipc	ra,0xffffd
    8000343a:	7a0080e7          	jalr	1952(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000343e:	0001e497          	auipc	s1,0x1e
    80003442:	8924b483          	ld	s1,-1902(s1) # 80020cd0 <bcache+0x82b8>
    80003446:	0001e797          	auipc	a5,0x1e
    8000344a:	83a78793          	addi	a5,a5,-1990 # 80020c80 <bcache+0x8268>
    8000344e:	02f48f63          	beq	s1,a5,8000348c <bread+0x70>
    80003452:	873e                	mv	a4,a5
    80003454:	a021                	j	8000345c <bread+0x40>
    80003456:	68a4                	ld	s1,80(s1)
    80003458:	02e48a63          	beq	s1,a4,8000348c <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000345c:	449c                	lw	a5,8(s1)
    8000345e:	ff279ce3          	bne	a5,s2,80003456 <bread+0x3a>
    80003462:	44dc                	lw	a5,12(s1)
    80003464:	ff3799e3          	bne	a5,s3,80003456 <bread+0x3a>
      b->refcnt++;
    80003468:	40bc                	lw	a5,64(s1)
    8000346a:	2785                	addiw	a5,a5,1
    8000346c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000346e:	00015517          	auipc	a0,0x15
    80003472:	5aa50513          	addi	a0,a0,1450 # 80018a18 <bcache>
    80003476:	ffffe097          	auipc	ra,0xffffe
    8000347a:	814080e7          	jalr	-2028(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    8000347e:	01048513          	addi	a0,s1,16
    80003482:	00001097          	auipc	ra,0x1
    80003486:	46e080e7          	jalr	1134(ra) # 800048f0 <acquiresleep>
      return b;
    8000348a:	a8b9                	j	800034e8 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000348c:	0001e497          	auipc	s1,0x1e
    80003490:	83c4b483          	ld	s1,-1988(s1) # 80020cc8 <bcache+0x82b0>
    80003494:	0001d797          	auipc	a5,0x1d
    80003498:	7ec78793          	addi	a5,a5,2028 # 80020c80 <bcache+0x8268>
    8000349c:	00f48863          	beq	s1,a5,800034ac <bread+0x90>
    800034a0:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800034a2:	40bc                	lw	a5,64(s1)
    800034a4:	cf81                	beqz	a5,800034bc <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800034a6:	64a4                	ld	s1,72(s1)
    800034a8:	fee49de3          	bne	s1,a4,800034a2 <bread+0x86>
  panic("bget: no buffers");
    800034ac:	00005517          	auipc	a0,0x5
    800034b0:	22450513          	addi	a0,a0,548 # 800086d0 <syscallnum+0x80>
    800034b4:	ffffd097          	auipc	ra,0xffffd
    800034b8:	08a080e7          	jalr	138(ra) # 8000053e <panic>
      b->dev = dev;
    800034bc:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800034c0:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800034c4:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800034c8:	4785                	li	a5,1
    800034ca:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800034cc:	00015517          	auipc	a0,0x15
    800034d0:	54c50513          	addi	a0,a0,1356 # 80018a18 <bcache>
    800034d4:	ffffd097          	auipc	ra,0xffffd
    800034d8:	7b6080e7          	jalr	1974(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    800034dc:	01048513          	addi	a0,s1,16
    800034e0:	00001097          	auipc	ra,0x1
    800034e4:	410080e7          	jalr	1040(ra) # 800048f0 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800034e8:	409c                	lw	a5,0(s1)
    800034ea:	cb89                	beqz	a5,800034fc <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800034ec:	8526                	mv	a0,s1
    800034ee:	70a2                	ld	ra,40(sp)
    800034f0:	7402                	ld	s0,32(sp)
    800034f2:	64e2                	ld	s1,24(sp)
    800034f4:	6942                	ld	s2,16(sp)
    800034f6:	69a2                	ld	s3,8(sp)
    800034f8:	6145                	addi	sp,sp,48
    800034fa:	8082                	ret
    virtio_disk_rw(b, 0);
    800034fc:	4581                	li	a1,0
    800034fe:	8526                	mv	a0,s1
    80003500:	00003097          	auipc	ra,0x3
    80003504:	fd4080e7          	jalr	-44(ra) # 800064d4 <virtio_disk_rw>
    b->valid = 1;
    80003508:	4785                	li	a5,1
    8000350a:	c09c                	sw	a5,0(s1)
  return b;
    8000350c:	b7c5                	j	800034ec <bread+0xd0>

000000008000350e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000350e:	1101                	addi	sp,sp,-32
    80003510:	ec06                	sd	ra,24(sp)
    80003512:	e822                	sd	s0,16(sp)
    80003514:	e426                	sd	s1,8(sp)
    80003516:	1000                	addi	s0,sp,32
    80003518:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000351a:	0541                	addi	a0,a0,16
    8000351c:	00001097          	auipc	ra,0x1
    80003520:	46e080e7          	jalr	1134(ra) # 8000498a <holdingsleep>
    80003524:	cd01                	beqz	a0,8000353c <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003526:	4585                	li	a1,1
    80003528:	8526                	mv	a0,s1
    8000352a:	00003097          	auipc	ra,0x3
    8000352e:	faa080e7          	jalr	-86(ra) # 800064d4 <virtio_disk_rw>
}
    80003532:	60e2                	ld	ra,24(sp)
    80003534:	6442                	ld	s0,16(sp)
    80003536:	64a2                	ld	s1,8(sp)
    80003538:	6105                	addi	sp,sp,32
    8000353a:	8082                	ret
    panic("bwrite");
    8000353c:	00005517          	auipc	a0,0x5
    80003540:	1ac50513          	addi	a0,a0,428 # 800086e8 <syscallnum+0x98>
    80003544:	ffffd097          	auipc	ra,0xffffd
    80003548:	ffa080e7          	jalr	-6(ra) # 8000053e <panic>

000000008000354c <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000354c:	1101                	addi	sp,sp,-32
    8000354e:	ec06                	sd	ra,24(sp)
    80003550:	e822                	sd	s0,16(sp)
    80003552:	e426                	sd	s1,8(sp)
    80003554:	e04a                	sd	s2,0(sp)
    80003556:	1000                	addi	s0,sp,32
    80003558:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000355a:	01050913          	addi	s2,a0,16
    8000355e:	854a                	mv	a0,s2
    80003560:	00001097          	auipc	ra,0x1
    80003564:	42a080e7          	jalr	1066(ra) # 8000498a <holdingsleep>
    80003568:	c92d                	beqz	a0,800035da <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000356a:	854a                	mv	a0,s2
    8000356c:	00001097          	auipc	ra,0x1
    80003570:	3da080e7          	jalr	986(ra) # 80004946 <releasesleep>

  acquire(&bcache.lock);
    80003574:	00015517          	auipc	a0,0x15
    80003578:	4a450513          	addi	a0,a0,1188 # 80018a18 <bcache>
    8000357c:	ffffd097          	auipc	ra,0xffffd
    80003580:	65a080e7          	jalr	1626(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80003584:	40bc                	lw	a5,64(s1)
    80003586:	37fd                	addiw	a5,a5,-1
    80003588:	0007871b          	sext.w	a4,a5
    8000358c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000358e:	eb05                	bnez	a4,800035be <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003590:	68bc                	ld	a5,80(s1)
    80003592:	64b8                	ld	a4,72(s1)
    80003594:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003596:	64bc                	ld	a5,72(s1)
    80003598:	68b8                	ld	a4,80(s1)
    8000359a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000359c:	0001d797          	auipc	a5,0x1d
    800035a0:	47c78793          	addi	a5,a5,1148 # 80020a18 <bcache+0x8000>
    800035a4:	2b87b703          	ld	a4,696(a5)
    800035a8:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800035aa:	0001d717          	auipc	a4,0x1d
    800035ae:	6d670713          	addi	a4,a4,1750 # 80020c80 <bcache+0x8268>
    800035b2:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800035b4:	2b87b703          	ld	a4,696(a5)
    800035b8:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800035ba:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800035be:	00015517          	auipc	a0,0x15
    800035c2:	45a50513          	addi	a0,a0,1114 # 80018a18 <bcache>
    800035c6:	ffffd097          	auipc	ra,0xffffd
    800035ca:	6c4080e7          	jalr	1732(ra) # 80000c8a <release>
}
    800035ce:	60e2                	ld	ra,24(sp)
    800035d0:	6442                	ld	s0,16(sp)
    800035d2:	64a2                	ld	s1,8(sp)
    800035d4:	6902                	ld	s2,0(sp)
    800035d6:	6105                	addi	sp,sp,32
    800035d8:	8082                	ret
    panic("brelse");
    800035da:	00005517          	auipc	a0,0x5
    800035de:	11650513          	addi	a0,a0,278 # 800086f0 <syscallnum+0xa0>
    800035e2:	ffffd097          	auipc	ra,0xffffd
    800035e6:	f5c080e7          	jalr	-164(ra) # 8000053e <panic>

00000000800035ea <bpin>:

void
bpin(struct buf *b) {
    800035ea:	1101                	addi	sp,sp,-32
    800035ec:	ec06                	sd	ra,24(sp)
    800035ee:	e822                	sd	s0,16(sp)
    800035f0:	e426                	sd	s1,8(sp)
    800035f2:	1000                	addi	s0,sp,32
    800035f4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800035f6:	00015517          	auipc	a0,0x15
    800035fa:	42250513          	addi	a0,a0,1058 # 80018a18 <bcache>
    800035fe:	ffffd097          	auipc	ra,0xffffd
    80003602:	5d8080e7          	jalr	1496(ra) # 80000bd6 <acquire>
  b->refcnt++;
    80003606:	40bc                	lw	a5,64(s1)
    80003608:	2785                	addiw	a5,a5,1
    8000360a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000360c:	00015517          	auipc	a0,0x15
    80003610:	40c50513          	addi	a0,a0,1036 # 80018a18 <bcache>
    80003614:	ffffd097          	auipc	ra,0xffffd
    80003618:	676080e7          	jalr	1654(ra) # 80000c8a <release>
}
    8000361c:	60e2                	ld	ra,24(sp)
    8000361e:	6442                	ld	s0,16(sp)
    80003620:	64a2                	ld	s1,8(sp)
    80003622:	6105                	addi	sp,sp,32
    80003624:	8082                	ret

0000000080003626 <bunpin>:

void
bunpin(struct buf *b) {
    80003626:	1101                	addi	sp,sp,-32
    80003628:	ec06                	sd	ra,24(sp)
    8000362a:	e822                	sd	s0,16(sp)
    8000362c:	e426                	sd	s1,8(sp)
    8000362e:	1000                	addi	s0,sp,32
    80003630:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003632:	00015517          	auipc	a0,0x15
    80003636:	3e650513          	addi	a0,a0,998 # 80018a18 <bcache>
    8000363a:	ffffd097          	auipc	ra,0xffffd
    8000363e:	59c080e7          	jalr	1436(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80003642:	40bc                	lw	a5,64(s1)
    80003644:	37fd                	addiw	a5,a5,-1
    80003646:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003648:	00015517          	auipc	a0,0x15
    8000364c:	3d050513          	addi	a0,a0,976 # 80018a18 <bcache>
    80003650:	ffffd097          	auipc	ra,0xffffd
    80003654:	63a080e7          	jalr	1594(ra) # 80000c8a <release>
}
    80003658:	60e2                	ld	ra,24(sp)
    8000365a:	6442                	ld	s0,16(sp)
    8000365c:	64a2                	ld	s1,8(sp)
    8000365e:	6105                	addi	sp,sp,32
    80003660:	8082                	ret

0000000080003662 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003662:	1101                	addi	sp,sp,-32
    80003664:	ec06                	sd	ra,24(sp)
    80003666:	e822                	sd	s0,16(sp)
    80003668:	e426                	sd	s1,8(sp)
    8000366a:	e04a                	sd	s2,0(sp)
    8000366c:	1000                	addi	s0,sp,32
    8000366e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003670:	00d5d59b          	srliw	a1,a1,0xd
    80003674:	0001e797          	auipc	a5,0x1e
    80003678:	a807a783          	lw	a5,-1408(a5) # 800210f4 <sb+0x1c>
    8000367c:	9dbd                	addw	a1,a1,a5
    8000367e:	00000097          	auipc	ra,0x0
    80003682:	d9e080e7          	jalr	-610(ra) # 8000341c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003686:	0074f713          	andi	a4,s1,7
    8000368a:	4785                	li	a5,1
    8000368c:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003690:	14ce                	slli	s1,s1,0x33
    80003692:	90d9                	srli	s1,s1,0x36
    80003694:	00950733          	add	a4,a0,s1
    80003698:	05874703          	lbu	a4,88(a4)
    8000369c:	00e7f6b3          	and	a3,a5,a4
    800036a0:	c69d                	beqz	a3,800036ce <bfree+0x6c>
    800036a2:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800036a4:	94aa                	add	s1,s1,a0
    800036a6:	fff7c793          	not	a5,a5
    800036aa:	8ff9                	and	a5,a5,a4
    800036ac:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800036b0:	00001097          	auipc	ra,0x1
    800036b4:	120080e7          	jalr	288(ra) # 800047d0 <log_write>
  brelse(bp);
    800036b8:	854a                	mv	a0,s2
    800036ba:	00000097          	auipc	ra,0x0
    800036be:	e92080e7          	jalr	-366(ra) # 8000354c <brelse>
}
    800036c2:	60e2                	ld	ra,24(sp)
    800036c4:	6442                	ld	s0,16(sp)
    800036c6:	64a2                	ld	s1,8(sp)
    800036c8:	6902                	ld	s2,0(sp)
    800036ca:	6105                	addi	sp,sp,32
    800036cc:	8082                	ret
    panic("freeing free block");
    800036ce:	00005517          	auipc	a0,0x5
    800036d2:	02a50513          	addi	a0,a0,42 # 800086f8 <syscallnum+0xa8>
    800036d6:	ffffd097          	auipc	ra,0xffffd
    800036da:	e68080e7          	jalr	-408(ra) # 8000053e <panic>

00000000800036de <balloc>:
{
    800036de:	711d                	addi	sp,sp,-96
    800036e0:	ec86                	sd	ra,88(sp)
    800036e2:	e8a2                	sd	s0,80(sp)
    800036e4:	e4a6                	sd	s1,72(sp)
    800036e6:	e0ca                	sd	s2,64(sp)
    800036e8:	fc4e                	sd	s3,56(sp)
    800036ea:	f852                	sd	s4,48(sp)
    800036ec:	f456                	sd	s5,40(sp)
    800036ee:	f05a                	sd	s6,32(sp)
    800036f0:	ec5e                	sd	s7,24(sp)
    800036f2:	e862                	sd	s8,16(sp)
    800036f4:	e466                	sd	s9,8(sp)
    800036f6:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800036f8:	0001e797          	auipc	a5,0x1e
    800036fc:	9e47a783          	lw	a5,-1564(a5) # 800210dc <sb+0x4>
    80003700:	10078163          	beqz	a5,80003802 <balloc+0x124>
    80003704:	8baa                	mv	s7,a0
    80003706:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003708:	0001eb17          	auipc	s6,0x1e
    8000370c:	9d0b0b13          	addi	s6,s6,-1584 # 800210d8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003710:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003712:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003714:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003716:	6c89                	lui	s9,0x2
    80003718:	a061                	j	800037a0 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000371a:	974a                	add	a4,a4,s2
    8000371c:	8fd5                	or	a5,a5,a3
    8000371e:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003722:	854a                	mv	a0,s2
    80003724:	00001097          	auipc	ra,0x1
    80003728:	0ac080e7          	jalr	172(ra) # 800047d0 <log_write>
        brelse(bp);
    8000372c:	854a                	mv	a0,s2
    8000372e:	00000097          	auipc	ra,0x0
    80003732:	e1e080e7          	jalr	-482(ra) # 8000354c <brelse>
  bp = bread(dev, bno);
    80003736:	85a6                	mv	a1,s1
    80003738:	855e                	mv	a0,s7
    8000373a:	00000097          	auipc	ra,0x0
    8000373e:	ce2080e7          	jalr	-798(ra) # 8000341c <bread>
    80003742:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003744:	40000613          	li	a2,1024
    80003748:	4581                	li	a1,0
    8000374a:	05850513          	addi	a0,a0,88
    8000374e:	ffffd097          	auipc	ra,0xffffd
    80003752:	584080e7          	jalr	1412(ra) # 80000cd2 <memset>
  log_write(bp);
    80003756:	854a                	mv	a0,s2
    80003758:	00001097          	auipc	ra,0x1
    8000375c:	078080e7          	jalr	120(ra) # 800047d0 <log_write>
  brelse(bp);
    80003760:	854a                	mv	a0,s2
    80003762:	00000097          	auipc	ra,0x0
    80003766:	dea080e7          	jalr	-534(ra) # 8000354c <brelse>
}
    8000376a:	8526                	mv	a0,s1
    8000376c:	60e6                	ld	ra,88(sp)
    8000376e:	6446                	ld	s0,80(sp)
    80003770:	64a6                	ld	s1,72(sp)
    80003772:	6906                	ld	s2,64(sp)
    80003774:	79e2                	ld	s3,56(sp)
    80003776:	7a42                	ld	s4,48(sp)
    80003778:	7aa2                	ld	s5,40(sp)
    8000377a:	7b02                	ld	s6,32(sp)
    8000377c:	6be2                	ld	s7,24(sp)
    8000377e:	6c42                	ld	s8,16(sp)
    80003780:	6ca2                	ld	s9,8(sp)
    80003782:	6125                	addi	sp,sp,96
    80003784:	8082                	ret
    brelse(bp);
    80003786:	854a                	mv	a0,s2
    80003788:	00000097          	auipc	ra,0x0
    8000378c:	dc4080e7          	jalr	-572(ra) # 8000354c <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003790:	015c87bb          	addw	a5,s9,s5
    80003794:	00078a9b          	sext.w	s5,a5
    80003798:	004b2703          	lw	a4,4(s6)
    8000379c:	06eaf363          	bgeu	s5,a4,80003802 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    800037a0:	41fad79b          	sraiw	a5,s5,0x1f
    800037a4:	0137d79b          	srliw	a5,a5,0x13
    800037a8:	015787bb          	addw	a5,a5,s5
    800037ac:	40d7d79b          	sraiw	a5,a5,0xd
    800037b0:	01cb2583          	lw	a1,28(s6)
    800037b4:	9dbd                	addw	a1,a1,a5
    800037b6:	855e                	mv	a0,s7
    800037b8:	00000097          	auipc	ra,0x0
    800037bc:	c64080e7          	jalr	-924(ra) # 8000341c <bread>
    800037c0:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037c2:	004b2503          	lw	a0,4(s6)
    800037c6:	000a849b          	sext.w	s1,s5
    800037ca:	8662                	mv	a2,s8
    800037cc:	faa4fde3          	bgeu	s1,a0,80003786 <balloc+0xa8>
      m = 1 << (bi % 8);
    800037d0:	41f6579b          	sraiw	a5,a2,0x1f
    800037d4:	01d7d69b          	srliw	a3,a5,0x1d
    800037d8:	00c6873b          	addw	a4,a3,a2
    800037dc:	00777793          	andi	a5,a4,7
    800037e0:	9f95                	subw	a5,a5,a3
    800037e2:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800037e6:	4037571b          	sraiw	a4,a4,0x3
    800037ea:	00e906b3          	add	a3,s2,a4
    800037ee:	0586c683          	lbu	a3,88(a3)
    800037f2:	00d7f5b3          	and	a1,a5,a3
    800037f6:	d195                	beqz	a1,8000371a <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037f8:	2605                	addiw	a2,a2,1
    800037fa:	2485                	addiw	s1,s1,1
    800037fc:	fd4618e3          	bne	a2,s4,800037cc <balloc+0xee>
    80003800:	b759                	j	80003786 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003802:	00005517          	auipc	a0,0x5
    80003806:	f0e50513          	addi	a0,a0,-242 # 80008710 <syscallnum+0xc0>
    8000380a:	ffffd097          	auipc	ra,0xffffd
    8000380e:	d7e080e7          	jalr	-642(ra) # 80000588 <printf>
  return 0;
    80003812:	4481                	li	s1,0
    80003814:	bf99                	j	8000376a <balloc+0x8c>

0000000080003816 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003816:	7179                	addi	sp,sp,-48
    80003818:	f406                	sd	ra,40(sp)
    8000381a:	f022                	sd	s0,32(sp)
    8000381c:	ec26                	sd	s1,24(sp)
    8000381e:	e84a                	sd	s2,16(sp)
    80003820:	e44e                	sd	s3,8(sp)
    80003822:	e052                	sd	s4,0(sp)
    80003824:	1800                	addi	s0,sp,48
    80003826:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003828:	47ad                	li	a5,11
    8000382a:	02b7e763          	bltu	a5,a1,80003858 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    8000382e:	02059493          	slli	s1,a1,0x20
    80003832:	9081                	srli	s1,s1,0x20
    80003834:	048a                	slli	s1,s1,0x2
    80003836:	94aa                	add	s1,s1,a0
    80003838:	0504a903          	lw	s2,80(s1)
    8000383c:	06091e63          	bnez	s2,800038b8 <bmap+0xa2>
      addr = balloc(ip->dev);
    80003840:	4108                	lw	a0,0(a0)
    80003842:	00000097          	auipc	ra,0x0
    80003846:	e9c080e7          	jalr	-356(ra) # 800036de <balloc>
    8000384a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000384e:	06090563          	beqz	s2,800038b8 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003852:	0524a823          	sw	s2,80(s1)
    80003856:	a08d                	j	800038b8 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003858:	ff45849b          	addiw	s1,a1,-12
    8000385c:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003860:	0ff00793          	li	a5,255
    80003864:	08e7e563          	bltu	a5,a4,800038ee <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003868:	08052903          	lw	s2,128(a0)
    8000386c:	00091d63          	bnez	s2,80003886 <bmap+0x70>
      addr = balloc(ip->dev);
    80003870:	4108                	lw	a0,0(a0)
    80003872:	00000097          	auipc	ra,0x0
    80003876:	e6c080e7          	jalr	-404(ra) # 800036de <balloc>
    8000387a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000387e:	02090d63          	beqz	s2,800038b8 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003882:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003886:	85ca                	mv	a1,s2
    80003888:	0009a503          	lw	a0,0(s3)
    8000388c:	00000097          	auipc	ra,0x0
    80003890:	b90080e7          	jalr	-1136(ra) # 8000341c <bread>
    80003894:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003896:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000389a:	02049593          	slli	a1,s1,0x20
    8000389e:	9181                	srli	a1,a1,0x20
    800038a0:	058a                	slli	a1,a1,0x2
    800038a2:	00b784b3          	add	s1,a5,a1
    800038a6:	0004a903          	lw	s2,0(s1)
    800038aa:	02090063          	beqz	s2,800038ca <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800038ae:	8552                	mv	a0,s4
    800038b0:	00000097          	auipc	ra,0x0
    800038b4:	c9c080e7          	jalr	-868(ra) # 8000354c <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800038b8:	854a                	mv	a0,s2
    800038ba:	70a2                	ld	ra,40(sp)
    800038bc:	7402                	ld	s0,32(sp)
    800038be:	64e2                	ld	s1,24(sp)
    800038c0:	6942                	ld	s2,16(sp)
    800038c2:	69a2                	ld	s3,8(sp)
    800038c4:	6a02                	ld	s4,0(sp)
    800038c6:	6145                	addi	sp,sp,48
    800038c8:	8082                	ret
      addr = balloc(ip->dev);
    800038ca:	0009a503          	lw	a0,0(s3)
    800038ce:	00000097          	auipc	ra,0x0
    800038d2:	e10080e7          	jalr	-496(ra) # 800036de <balloc>
    800038d6:	0005091b          	sext.w	s2,a0
      if(addr){
    800038da:	fc090ae3          	beqz	s2,800038ae <bmap+0x98>
        a[bn] = addr;
    800038de:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800038e2:	8552                	mv	a0,s4
    800038e4:	00001097          	auipc	ra,0x1
    800038e8:	eec080e7          	jalr	-276(ra) # 800047d0 <log_write>
    800038ec:	b7c9                	j	800038ae <bmap+0x98>
  panic("bmap: out of range");
    800038ee:	00005517          	auipc	a0,0x5
    800038f2:	e3a50513          	addi	a0,a0,-454 # 80008728 <syscallnum+0xd8>
    800038f6:	ffffd097          	auipc	ra,0xffffd
    800038fa:	c48080e7          	jalr	-952(ra) # 8000053e <panic>

00000000800038fe <iget>:
{
    800038fe:	7179                	addi	sp,sp,-48
    80003900:	f406                	sd	ra,40(sp)
    80003902:	f022                	sd	s0,32(sp)
    80003904:	ec26                	sd	s1,24(sp)
    80003906:	e84a                	sd	s2,16(sp)
    80003908:	e44e                	sd	s3,8(sp)
    8000390a:	e052                	sd	s4,0(sp)
    8000390c:	1800                	addi	s0,sp,48
    8000390e:	89aa                	mv	s3,a0
    80003910:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003912:	0001d517          	auipc	a0,0x1d
    80003916:	7e650513          	addi	a0,a0,2022 # 800210f8 <itable>
    8000391a:	ffffd097          	auipc	ra,0xffffd
    8000391e:	2bc080e7          	jalr	700(ra) # 80000bd6 <acquire>
  empty = 0;
    80003922:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003924:	0001d497          	auipc	s1,0x1d
    80003928:	7ec48493          	addi	s1,s1,2028 # 80021110 <itable+0x18>
    8000392c:	0001f697          	auipc	a3,0x1f
    80003930:	27468693          	addi	a3,a3,628 # 80022ba0 <log>
    80003934:	a039                	j	80003942 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003936:	02090b63          	beqz	s2,8000396c <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000393a:	08848493          	addi	s1,s1,136
    8000393e:	02d48a63          	beq	s1,a3,80003972 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003942:	449c                	lw	a5,8(s1)
    80003944:	fef059e3          	blez	a5,80003936 <iget+0x38>
    80003948:	4098                	lw	a4,0(s1)
    8000394a:	ff3716e3          	bne	a4,s3,80003936 <iget+0x38>
    8000394e:	40d8                	lw	a4,4(s1)
    80003950:	ff4713e3          	bne	a4,s4,80003936 <iget+0x38>
      ip->ref++;
    80003954:	2785                	addiw	a5,a5,1
    80003956:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003958:	0001d517          	auipc	a0,0x1d
    8000395c:	7a050513          	addi	a0,a0,1952 # 800210f8 <itable>
    80003960:	ffffd097          	auipc	ra,0xffffd
    80003964:	32a080e7          	jalr	810(ra) # 80000c8a <release>
      return ip;
    80003968:	8926                	mv	s2,s1
    8000396a:	a03d                	j	80003998 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000396c:	f7f9                	bnez	a5,8000393a <iget+0x3c>
    8000396e:	8926                	mv	s2,s1
    80003970:	b7e9                	j	8000393a <iget+0x3c>
  if(empty == 0)
    80003972:	02090c63          	beqz	s2,800039aa <iget+0xac>
  ip->dev = dev;
    80003976:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000397a:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000397e:	4785                	li	a5,1
    80003980:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003984:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003988:	0001d517          	auipc	a0,0x1d
    8000398c:	77050513          	addi	a0,a0,1904 # 800210f8 <itable>
    80003990:	ffffd097          	auipc	ra,0xffffd
    80003994:	2fa080e7          	jalr	762(ra) # 80000c8a <release>
}
    80003998:	854a                	mv	a0,s2
    8000399a:	70a2                	ld	ra,40(sp)
    8000399c:	7402                	ld	s0,32(sp)
    8000399e:	64e2                	ld	s1,24(sp)
    800039a0:	6942                	ld	s2,16(sp)
    800039a2:	69a2                	ld	s3,8(sp)
    800039a4:	6a02                	ld	s4,0(sp)
    800039a6:	6145                	addi	sp,sp,48
    800039a8:	8082                	ret
    panic("iget: no inodes");
    800039aa:	00005517          	auipc	a0,0x5
    800039ae:	d9650513          	addi	a0,a0,-618 # 80008740 <syscallnum+0xf0>
    800039b2:	ffffd097          	auipc	ra,0xffffd
    800039b6:	b8c080e7          	jalr	-1140(ra) # 8000053e <panic>

00000000800039ba <fsinit>:
fsinit(int dev) {
    800039ba:	7179                	addi	sp,sp,-48
    800039bc:	f406                	sd	ra,40(sp)
    800039be:	f022                	sd	s0,32(sp)
    800039c0:	ec26                	sd	s1,24(sp)
    800039c2:	e84a                	sd	s2,16(sp)
    800039c4:	e44e                	sd	s3,8(sp)
    800039c6:	1800                	addi	s0,sp,48
    800039c8:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800039ca:	4585                	li	a1,1
    800039cc:	00000097          	auipc	ra,0x0
    800039d0:	a50080e7          	jalr	-1456(ra) # 8000341c <bread>
    800039d4:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800039d6:	0001d997          	auipc	s3,0x1d
    800039da:	70298993          	addi	s3,s3,1794 # 800210d8 <sb>
    800039de:	02000613          	li	a2,32
    800039e2:	05850593          	addi	a1,a0,88
    800039e6:	854e                	mv	a0,s3
    800039e8:	ffffd097          	auipc	ra,0xffffd
    800039ec:	346080e7          	jalr	838(ra) # 80000d2e <memmove>
  brelse(bp);
    800039f0:	8526                	mv	a0,s1
    800039f2:	00000097          	auipc	ra,0x0
    800039f6:	b5a080e7          	jalr	-1190(ra) # 8000354c <brelse>
  if(sb.magic != FSMAGIC)
    800039fa:	0009a703          	lw	a4,0(s3)
    800039fe:	102037b7          	lui	a5,0x10203
    80003a02:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003a06:	02f71263          	bne	a4,a5,80003a2a <fsinit+0x70>
  initlog(dev, &sb);
    80003a0a:	0001d597          	auipc	a1,0x1d
    80003a0e:	6ce58593          	addi	a1,a1,1742 # 800210d8 <sb>
    80003a12:	854a                	mv	a0,s2
    80003a14:	00001097          	auipc	ra,0x1
    80003a18:	b40080e7          	jalr	-1216(ra) # 80004554 <initlog>
}
    80003a1c:	70a2                	ld	ra,40(sp)
    80003a1e:	7402                	ld	s0,32(sp)
    80003a20:	64e2                	ld	s1,24(sp)
    80003a22:	6942                	ld	s2,16(sp)
    80003a24:	69a2                	ld	s3,8(sp)
    80003a26:	6145                	addi	sp,sp,48
    80003a28:	8082                	ret
    panic("invalid file system");
    80003a2a:	00005517          	auipc	a0,0x5
    80003a2e:	d2650513          	addi	a0,a0,-730 # 80008750 <syscallnum+0x100>
    80003a32:	ffffd097          	auipc	ra,0xffffd
    80003a36:	b0c080e7          	jalr	-1268(ra) # 8000053e <panic>

0000000080003a3a <iinit>:
{
    80003a3a:	7179                	addi	sp,sp,-48
    80003a3c:	f406                	sd	ra,40(sp)
    80003a3e:	f022                	sd	s0,32(sp)
    80003a40:	ec26                	sd	s1,24(sp)
    80003a42:	e84a                	sd	s2,16(sp)
    80003a44:	e44e                	sd	s3,8(sp)
    80003a46:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003a48:	00005597          	auipc	a1,0x5
    80003a4c:	d2058593          	addi	a1,a1,-736 # 80008768 <syscallnum+0x118>
    80003a50:	0001d517          	auipc	a0,0x1d
    80003a54:	6a850513          	addi	a0,a0,1704 # 800210f8 <itable>
    80003a58:	ffffd097          	auipc	ra,0xffffd
    80003a5c:	0ee080e7          	jalr	238(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003a60:	0001d497          	auipc	s1,0x1d
    80003a64:	6c048493          	addi	s1,s1,1728 # 80021120 <itable+0x28>
    80003a68:	0001f997          	auipc	s3,0x1f
    80003a6c:	14898993          	addi	s3,s3,328 # 80022bb0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003a70:	00005917          	auipc	s2,0x5
    80003a74:	d0090913          	addi	s2,s2,-768 # 80008770 <syscallnum+0x120>
    80003a78:	85ca                	mv	a1,s2
    80003a7a:	8526                	mv	a0,s1
    80003a7c:	00001097          	auipc	ra,0x1
    80003a80:	e3a080e7          	jalr	-454(ra) # 800048b6 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003a84:	08848493          	addi	s1,s1,136
    80003a88:	ff3498e3          	bne	s1,s3,80003a78 <iinit+0x3e>
}
    80003a8c:	70a2                	ld	ra,40(sp)
    80003a8e:	7402                	ld	s0,32(sp)
    80003a90:	64e2                	ld	s1,24(sp)
    80003a92:	6942                	ld	s2,16(sp)
    80003a94:	69a2                	ld	s3,8(sp)
    80003a96:	6145                	addi	sp,sp,48
    80003a98:	8082                	ret

0000000080003a9a <ialloc>:
{
    80003a9a:	715d                	addi	sp,sp,-80
    80003a9c:	e486                	sd	ra,72(sp)
    80003a9e:	e0a2                	sd	s0,64(sp)
    80003aa0:	fc26                	sd	s1,56(sp)
    80003aa2:	f84a                	sd	s2,48(sp)
    80003aa4:	f44e                	sd	s3,40(sp)
    80003aa6:	f052                	sd	s4,32(sp)
    80003aa8:	ec56                	sd	s5,24(sp)
    80003aaa:	e85a                	sd	s6,16(sp)
    80003aac:	e45e                	sd	s7,8(sp)
    80003aae:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003ab0:	0001d717          	auipc	a4,0x1d
    80003ab4:	63472703          	lw	a4,1588(a4) # 800210e4 <sb+0xc>
    80003ab8:	4785                	li	a5,1
    80003aba:	04e7fa63          	bgeu	a5,a4,80003b0e <ialloc+0x74>
    80003abe:	8aaa                	mv	s5,a0
    80003ac0:	8bae                	mv	s7,a1
    80003ac2:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003ac4:	0001da17          	auipc	s4,0x1d
    80003ac8:	614a0a13          	addi	s4,s4,1556 # 800210d8 <sb>
    80003acc:	00048b1b          	sext.w	s6,s1
    80003ad0:	0044d793          	srli	a5,s1,0x4
    80003ad4:	018a2583          	lw	a1,24(s4)
    80003ad8:	9dbd                	addw	a1,a1,a5
    80003ada:	8556                	mv	a0,s5
    80003adc:	00000097          	auipc	ra,0x0
    80003ae0:	940080e7          	jalr	-1728(ra) # 8000341c <bread>
    80003ae4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003ae6:	05850993          	addi	s3,a0,88
    80003aea:	00f4f793          	andi	a5,s1,15
    80003aee:	079a                	slli	a5,a5,0x6
    80003af0:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003af2:	00099783          	lh	a5,0(s3)
    80003af6:	c3a1                	beqz	a5,80003b36 <ialloc+0x9c>
    brelse(bp);
    80003af8:	00000097          	auipc	ra,0x0
    80003afc:	a54080e7          	jalr	-1452(ra) # 8000354c <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b00:	0485                	addi	s1,s1,1
    80003b02:	00ca2703          	lw	a4,12(s4)
    80003b06:	0004879b          	sext.w	a5,s1
    80003b0a:	fce7e1e3          	bltu	a5,a4,80003acc <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003b0e:	00005517          	auipc	a0,0x5
    80003b12:	c6a50513          	addi	a0,a0,-918 # 80008778 <syscallnum+0x128>
    80003b16:	ffffd097          	auipc	ra,0xffffd
    80003b1a:	a72080e7          	jalr	-1422(ra) # 80000588 <printf>
  return 0;
    80003b1e:	4501                	li	a0,0
}
    80003b20:	60a6                	ld	ra,72(sp)
    80003b22:	6406                	ld	s0,64(sp)
    80003b24:	74e2                	ld	s1,56(sp)
    80003b26:	7942                	ld	s2,48(sp)
    80003b28:	79a2                	ld	s3,40(sp)
    80003b2a:	7a02                	ld	s4,32(sp)
    80003b2c:	6ae2                	ld	s5,24(sp)
    80003b2e:	6b42                	ld	s6,16(sp)
    80003b30:	6ba2                	ld	s7,8(sp)
    80003b32:	6161                	addi	sp,sp,80
    80003b34:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003b36:	04000613          	li	a2,64
    80003b3a:	4581                	li	a1,0
    80003b3c:	854e                	mv	a0,s3
    80003b3e:	ffffd097          	auipc	ra,0xffffd
    80003b42:	194080e7          	jalr	404(ra) # 80000cd2 <memset>
      dip->type = type;
    80003b46:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003b4a:	854a                	mv	a0,s2
    80003b4c:	00001097          	auipc	ra,0x1
    80003b50:	c84080e7          	jalr	-892(ra) # 800047d0 <log_write>
      brelse(bp);
    80003b54:	854a                	mv	a0,s2
    80003b56:	00000097          	auipc	ra,0x0
    80003b5a:	9f6080e7          	jalr	-1546(ra) # 8000354c <brelse>
      return iget(dev, inum);
    80003b5e:	85da                	mv	a1,s6
    80003b60:	8556                	mv	a0,s5
    80003b62:	00000097          	auipc	ra,0x0
    80003b66:	d9c080e7          	jalr	-612(ra) # 800038fe <iget>
    80003b6a:	bf5d                	j	80003b20 <ialloc+0x86>

0000000080003b6c <iupdate>:
{
    80003b6c:	1101                	addi	sp,sp,-32
    80003b6e:	ec06                	sd	ra,24(sp)
    80003b70:	e822                	sd	s0,16(sp)
    80003b72:	e426                	sd	s1,8(sp)
    80003b74:	e04a                	sd	s2,0(sp)
    80003b76:	1000                	addi	s0,sp,32
    80003b78:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b7a:	415c                	lw	a5,4(a0)
    80003b7c:	0047d79b          	srliw	a5,a5,0x4
    80003b80:	0001d597          	auipc	a1,0x1d
    80003b84:	5705a583          	lw	a1,1392(a1) # 800210f0 <sb+0x18>
    80003b88:	9dbd                	addw	a1,a1,a5
    80003b8a:	4108                	lw	a0,0(a0)
    80003b8c:	00000097          	auipc	ra,0x0
    80003b90:	890080e7          	jalr	-1904(ra) # 8000341c <bread>
    80003b94:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b96:	05850793          	addi	a5,a0,88
    80003b9a:	40c8                	lw	a0,4(s1)
    80003b9c:	893d                	andi	a0,a0,15
    80003b9e:	051a                	slli	a0,a0,0x6
    80003ba0:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003ba2:	04449703          	lh	a4,68(s1)
    80003ba6:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003baa:	04649703          	lh	a4,70(s1)
    80003bae:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003bb2:	04849703          	lh	a4,72(s1)
    80003bb6:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003bba:	04a49703          	lh	a4,74(s1)
    80003bbe:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003bc2:	44f8                	lw	a4,76(s1)
    80003bc4:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003bc6:	03400613          	li	a2,52
    80003bca:	05048593          	addi	a1,s1,80
    80003bce:	0531                	addi	a0,a0,12
    80003bd0:	ffffd097          	auipc	ra,0xffffd
    80003bd4:	15e080e7          	jalr	350(ra) # 80000d2e <memmove>
  log_write(bp);
    80003bd8:	854a                	mv	a0,s2
    80003bda:	00001097          	auipc	ra,0x1
    80003bde:	bf6080e7          	jalr	-1034(ra) # 800047d0 <log_write>
  brelse(bp);
    80003be2:	854a                	mv	a0,s2
    80003be4:	00000097          	auipc	ra,0x0
    80003be8:	968080e7          	jalr	-1688(ra) # 8000354c <brelse>
}
    80003bec:	60e2                	ld	ra,24(sp)
    80003bee:	6442                	ld	s0,16(sp)
    80003bf0:	64a2                	ld	s1,8(sp)
    80003bf2:	6902                	ld	s2,0(sp)
    80003bf4:	6105                	addi	sp,sp,32
    80003bf6:	8082                	ret

0000000080003bf8 <idup>:
{
    80003bf8:	1101                	addi	sp,sp,-32
    80003bfa:	ec06                	sd	ra,24(sp)
    80003bfc:	e822                	sd	s0,16(sp)
    80003bfe:	e426                	sd	s1,8(sp)
    80003c00:	1000                	addi	s0,sp,32
    80003c02:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003c04:	0001d517          	auipc	a0,0x1d
    80003c08:	4f450513          	addi	a0,a0,1268 # 800210f8 <itable>
    80003c0c:	ffffd097          	auipc	ra,0xffffd
    80003c10:	fca080e7          	jalr	-54(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003c14:	449c                	lw	a5,8(s1)
    80003c16:	2785                	addiw	a5,a5,1
    80003c18:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003c1a:	0001d517          	auipc	a0,0x1d
    80003c1e:	4de50513          	addi	a0,a0,1246 # 800210f8 <itable>
    80003c22:	ffffd097          	auipc	ra,0xffffd
    80003c26:	068080e7          	jalr	104(ra) # 80000c8a <release>
}
    80003c2a:	8526                	mv	a0,s1
    80003c2c:	60e2                	ld	ra,24(sp)
    80003c2e:	6442                	ld	s0,16(sp)
    80003c30:	64a2                	ld	s1,8(sp)
    80003c32:	6105                	addi	sp,sp,32
    80003c34:	8082                	ret

0000000080003c36 <ilock>:
{
    80003c36:	1101                	addi	sp,sp,-32
    80003c38:	ec06                	sd	ra,24(sp)
    80003c3a:	e822                	sd	s0,16(sp)
    80003c3c:	e426                	sd	s1,8(sp)
    80003c3e:	e04a                	sd	s2,0(sp)
    80003c40:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003c42:	c115                	beqz	a0,80003c66 <ilock+0x30>
    80003c44:	84aa                	mv	s1,a0
    80003c46:	451c                	lw	a5,8(a0)
    80003c48:	00f05f63          	blez	a5,80003c66 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003c4c:	0541                	addi	a0,a0,16
    80003c4e:	00001097          	auipc	ra,0x1
    80003c52:	ca2080e7          	jalr	-862(ra) # 800048f0 <acquiresleep>
  if(ip->valid == 0){
    80003c56:	40bc                	lw	a5,64(s1)
    80003c58:	cf99                	beqz	a5,80003c76 <ilock+0x40>
}
    80003c5a:	60e2                	ld	ra,24(sp)
    80003c5c:	6442                	ld	s0,16(sp)
    80003c5e:	64a2                	ld	s1,8(sp)
    80003c60:	6902                	ld	s2,0(sp)
    80003c62:	6105                	addi	sp,sp,32
    80003c64:	8082                	ret
    panic("ilock");
    80003c66:	00005517          	auipc	a0,0x5
    80003c6a:	b2a50513          	addi	a0,a0,-1238 # 80008790 <syscallnum+0x140>
    80003c6e:	ffffd097          	auipc	ra,0xffffd
    80003c72:	8d0080e7          	jalr	-1840(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003c76:	40dc                	lw	a5,4(s1)
    80003c78:	0047d79b          	srliw	a5,a5,0x4
    80003c7c:	0001d597          	auipc	a1,0x1d
    80003c80:	4745a583          	lw	a1,1140(a1) # 800210f0 <sb+0x18>
    80003c84:	9dbd                	addw	a1,a1,a5
    80003c86:	4088                	lw	a0,0(s1)
    80003c88:	fffff097          	auipc	ra,0xfffff
    80003c8c:	794080e7          	jalr	1940(ra) # 8000341c <bread>
    80003c90:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c92:	05850593          	addi	a1,a0,88
    80003c96:	40dc                	lw	a5,4(s1)
    80003c98:	8bbd                	andi	a5,a5,15
    80003c9a:	079a                	slli	a5,a5,0x6
    80003c9c:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003c9e:	00059783          	lh	a5,0(a1)
    80003ca2:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003ca6:	00259783          	lh	a5,2(a1)
    80003caa:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003cae:	00459783          	lh	a5,4(a1)
    80003cb2:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003cb6:	00659783          	lh	a5,6(a1)
    80003cba:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003cbe:	459c                	lw	a5,8(a1)
    80003cc0:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003cc2:	03400613          	li	a2,52
    80003cc6:	05b1                	addi	a1,a1,12
    80003cc8:	05048513          	addi	a0,s1,80
    80003ccc:	ffffd097          	auipc	ra,0xffffd
    80003cd0:	062080e7          	jalr	98(ra) # 80000d2e <memmove>
    brelse(bp);
    80003cd4:	854a                	mv	a0,s2
    80003cd6:	00000097          	auipc	ra,0x0
    80003cda:	876080e7          	jalr	-1930(ra) # 8000354c <brelse>
    ip->valid = 1;
    80003cde:	4785                	li	a5,1
    80003ce0:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003ce2:	04449783          	lh	a5,68(s1)
    80003ce6:	fbb5                	bnez	a5,80003c5a <ilock+0x24>
      panic("ilock: no type");
    80003ce8:	00005517          	auipc	a0,0x5
    80003cec:	ab050513          	addi	a0,a0,-1360 # 80008798 <syscallnum+0x148>
    80003cf0:	ffffd097          	auipc	ra,0xffffd
    80003cf4:	84e080e7          	jalr	-1970(ra) # 8000053e <panic>

0000000080003cf8 <iunlock>:
{
    80003cf8:	1101                	addi	sp,sp,-32
    80003cfa:	ec06                	sd	ra,24(sp)
    80003cfc:	e822                	sd	s0,16(sp)
    80003cfe:	e426                	sd	s1,8(sp)
    80003d00:	e04a                	sd	s2,0(sp)
    80003d02:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003d04:	c905                	beqz	a0,80003d34 <iunlock+0x3c>
    80003d06:	84aa                	mv	s1,a0
    80003d08:	01050913          	addi	s2,a0,16
    80003d0c:	854a                	mv	a0,s2
    80003d0e:	00001097          	auipc	ra,0x1
    80003d12:	c7c080e7          	jalr	-900(ra) # 8000498a <holdingsleep>
    80003d16:	cd19                	beqz	a0,80003d34 <iunlock+0x3c>
    80003d18:	449c                	lw	a5,8(s1)
    80003d1a:	00f05d63          	blez	a5,80003d34 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003d1e:	854a                	mv	a0,s2
    80003d20:	00001097          	auipc	ra,0x1
    80003d24:	c26080e7          	jalr	-986(ra) # 80004946 <releasesleep>
}
    80003d28:	60e2                	ld	ra,24(sp)
    80003d2a:	6442                	ld	s0,16(sp)
    80003d2c:	64a2                	ld	s1,8(sp)
    80003d2e:	6902                	ld	s2,0(sp)
    80003d30:	6105                	addi	sp,sp,32
    80003d32:	8082                	ret
    panic("iunlock");
    80003d34:	00005517          	auipc	a0,0x5
    80003d38:	a7450513          	addi	a0,a0,-1420 # 800087a8 <syscallnum+0x158>
    80003d3c:	ffffd097          	auipc	ra,0xffffd
    80003d40:	802080e7          	jalr	-2046(ra) # 8000053e <panic>

0000000080003d44 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003d44:	7179                	addi	sp,sp,-48
    80003d46:	f406                	sd	ra,40(sp)
    80003d48:	f022                	sd	s0,32(sp)
    80003d4a:	ec26                	sd	s1,24(sp)
    80003d4c:	e84a                	sd	s2,16(sp)
    80003d4e:	e44e                	sd	s3,8(sp)
    80003d50:	e052                	sd	s4,0(sp)
    80003d52:	1800                	addi	s0,sp,48
    80003d54:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003d56:	05050493          	addi	s1,a0,80
    80003d5a:	08050913          	addi	s2,a0,128
    80003d5e:	a021                	j	80003d66 <itrunc+0x22>
    80003d60:	0491                	addi	s1,s1,4
    80003d62:	01248d63          	beq	s1,s2,80003d7c <itrunc+0x38>
    if(ip->addrs[i]){
    80003d66:	408c                	lw	a1,0(s1)
    80003d68:	dde5                	beqz	a1,80003d60 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003d6a:	0009a503          	lw	a0,0(s3)
    80003d6e:	00000097          	auipc	ra,0x0
    80003d72:	8f4080e7          	jalr	-1804(ra) # 80003662 <bfree>
      ip->addrs[i] = 0;
    80003d76:	0004a023          	sw	zero,0(s1)
    80003d7a:	b7dd                	j	80003d60 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003d7c:	0809a583          	lw	a1,128(s3)
    80003d80:	e185                	bnez	a1,80003da0 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003d82:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003d86:	854e                	mv	a0,s3
    80003d88:	00000097          	auipc	ra,0x0
    80003d8c:	de4080e7          	jalr	-540(ra) # 80003b6c <iupdate>
}
    80003d90:	70a2                	ld	ra,40(sp)
    80003d92:	7402                	ld	s0,32(sp)
    80003d94:	64e2                	ld	s1,24(sp)
    80003d96:	6942                	ld	s2,16(sp)
    80003d98:	69a2                	ld	s3,8(sp)
    80003d9a:	6a02                	ld	s4,0(sp)
    80003d9c:	6145                	addi	sp,sp,48
    80003d9e:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003da0:	0009a503          	lw	a0,0(s3)
    80003da4:	fffff097          	auipc	ra,0xfffff
    80003da8:	678080e7          	jalr	1656(ra) # 8000341c <bread>
    80003dac:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003dae:	05850493          	addi	s1,a0,88
    80003db2:	45850913          	addi	s2,a0,1112
    80003db6:	a021                	j	80003dbe <itrunc+0x7a>
    80003db8:	0491                	addi	s1,s1,4
    80003dba:	01248b63          	beq	s1,s2,80003dd0 <itrunc+0x8c>
      if(a[j])
    80003dbe:	408c                	lw	a1,0(s1)
    80003dc0:	dde5                	beqz	a1,80003db8 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003dc2:	0009a503          	lw	a0,0(s3)
    80003dc6:	00000097          	auipc	ra,0x0
    80003dca:	89c080e7          	jalr	-1892(ra) # 80003662 <bfree>
    80003dce:	b7ed                	j	80003db8 <itrunc+0x74>
    brelse(bp);
    80003dd0:	8552                	mv	a0,s4
    80003dd2:	fffff097          	auipc	ra,0xfffff
    80003dd6:	77a080e7          	jalr	1914(ra) # 8000354c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003dda:	0809a583          	lw	a1,128(s3)
    80003dde:	0009a503          	lw	a0,0(s3)
    80003de2:	00000097          	auipc	ra,0x0
    80003de6:	880080e7          	jalr	-1920(ra) # 80003662 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003dea:	0809a023          	sw	zero,128(s3)
    80003dee:	bf51                	j	80003d82 <itrunc+0x3e>

0000000080003df0 <iput>:
{
    80003df0:	1101                	addi	sp,sp,-32
    80003df2:	ec06                	sd	ra,24(sp)
    80003df4:	e822                	sd	s0,16(sp)
    80003df6:	e426                	sd	s1,8(sp)
    80003df8:	e04a                	sd	s2,0(sp)
    80003dfa:	1000                	addi	s0,sp,32
    80003dfc:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003dfe:	0001d517          	auipc	a0,0x1d
    80003e02:	2fa50513          	addi	a0,a0,762 # 800210f8 <itable>
    80003e06:	ffffd097          	auipc	ra,0xffffd
    80003e0a:	dd0080e7          	jalr	-560(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e0e:	4498                	lw	a4,8(s1)
    80003e10:	4785                	li	a5,1
    80003e12:	02f70363          	beq	a4,a5,80003e38 <iput+0x48>
  ip->ref--;
    80003e16:	449c                	lw	a5,8(s1)
    80003e18:	37fd                	addiw	a5,a5,-1
    80003e1a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003e1c:	0001d517          	auipc	a0,0x1d
    80003e20:	2dc50513          	addi	a0,a0,732 # 800210f8 <itable>
    80003e24:	ffffd097          	auipc	ra,0xffffd
    80003e28:	e66080e7          	jalr	-410(ra) # 80000c8a <release>
}
    80003e2c:	60e2                	ld	ra,24(sp)
    80003e2e:	6442                	ld	s0,16(sp)
    80003e30:	64a2                	ld	s1,8(sp)
    80003e32:	6902                	ld	s2,0(sp)
    80003e34:	6105                	addi	sp,sp,32
    80003e36:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e38:	40bc                	lw	a5,64(s1)
    80003e3a:	dff1                	beqz	a5,80003e16 <iput+0x26>
    80003e3c:	04a49783          	lh	a5,74(s1)
    80003e40:	fbf9                	bnez	a5,80003e16 <iput+0x26>
    acquiresleep(&ip->lock);
    80003e42:	01048913          	addi	s2,s1,16
    80003e46:	854a                	mv	a0,s2
    80003e48:	00001097          	auipc	ra,0x1
    80003e4c:	aa8080e7          	jalr	-1368(ra) # 800048f0 <acquiresleep>
    release(&itable.lock);
    80003e50:	0001d517          	auipc	a0,0x1d
    80003e54:	2a850513          	addi	a0,a0,680 # 800210f8 <itable>
    80003e58:	ffffd097          	auipc	ra,0xffffd
    80003e5c:	e32080e7          	jalr	-462(ra) # 80000c8a <release>
    itrunc(ip);
    80003e60:	8526                	mv	a0,s1
    80003e62:	00000097          	auipc	ra,0x0
    80003e66:	ee2080e7          	jalr	-286(ra) # 80003d44 <itrunc>
    ip->type = 0;
    80003e6a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003e6e:	8526                	mv	a0,s1
    80003e70:	00000097          	auipc	ra,0x0
    80003e74:	cfc080e7          	jalr	-772(ra) # 80003b6c <iupdate>
    ip->valid = 0;
    80003e78:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003e7c:	854a                	mv	a0,s2
    80003e7e:	00001097          	auipc	ra,0x1
    80003e82:	ac8080e7          	jalr	-1336(ra) # 80004946 <releasesleep>
    acquire(&itable.lock);
    80003e86:	0001d517          	auipc	a0,0x1d
    80003e8a:	27250513          	addi	a0,a0,626 # 800210f8 <itable>
    80003e8e:	ffffd097          	auipc	ra,0xffffd
    80003e92:	d48080e7          	jalr	-696(ra) # 80000bd6 <acquire>
    80003e96:	b741                	j	80003e16 <iput+0x26>

0000000080003e98 <iunlockput>:
{
    80003e98:	1101                	addi	sp,sp,-32
    80003e9a:	ec06                	sd	ra,24(sp)
    80003e9c:	e822                	sd	s0,16(sp)
    80003e9e:	e426                	sd	s1,8(sp)
    80003ea0:	1000                	addi	s0,sp,32
    80003ea2:	84aa                	mv	s1,a0
  iunlock(ip);
    80003ea4:	00000097          	auipc	ra,0x0
    80003ea8:	e54080e7          	jalr	-428(ra) # 80003cf8 <iunlock>
  iput(ip);
    80003eac:	8526                	mv	a0,s1
    80003eae:	00000097          	auipc	ra,0x0
    80003eb2:	f42080e7          	jalr	-190(ra) # 80003df0 <iput>
}
    80003eb6:	60e2                	ld	ra,24(sp)
    80003eb8:	6442                	ld	s0,16(sp)
    80003eba:	64a2                	ld	s1,8(sp)
    80003ebc:	6105                	addi	sp,sp,32
    80003ebe:	8082                	ret

0000000080003ec0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003ec0:	1141                	addi	sp,sp,-16
    80003ec2:	e422                	sd	s0,8(sp)
    80003ec4:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003ec6:	411c                	lw	a5,0(a0)
    80003ec8:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003eca:	415c                	lw	a5,4(a0)
    80003ecc:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003ece:	04451783          	lh	a5,68(a0)
    80003ed2:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003ed6:	04a51783          	lh	a5,74(a0)
    80003eda:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003ede:	04c56783          	lwu	a5,76(a0)
    80003ee2:	e99c                	sd	a5,16(a1)
}
    80003ee4:	6422                	ld	s0,8(sp)
    80003ee6:	0141                	addi	sp,sp,16
    80003ee8:	8082                	ret

0000000080003eea <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003eea:	457c                	lw	a5,76(a0)
    80003eec:	0ed7e963          	bltu	a5,a3,80003fde <readi+0xf4>
{
    80003ef0:	7159                	addi	sp,sp,-112
    80003ef2:	f486                	sd	ra,104(sp)
    80003ef4:	f0a2                	sd	s0,96(sp)
    80003ef6:	eca6                	sd	s1,88(sp)
    80003ef8:	e8ca                	sd	s2,80(sp)
    80003efa:	e4ce                	sd	s3,72(sp)
    80003efc:	e0d2                	sd	s4,64(sp)
    80003efe:	fc56                	sd	s5,56(sp)
    80003f00:	f85a                	sd	s6,48(sp)
    80003f02:	f45e                	sd	s7,40(sp)
    80003f04:	f062                	sd	s8,32(sp)
    80003f06:	ec66                	sd	s9,24(sp)
    80003f08:	e86a                	sd	s10,16(sp)
    80003f0a:	e46e                	sd	s11,8(sp)
    80003f0c:	1880                	addi	s0,sp,112
    80003f0e:	8b2a                	mv	s6,a0
    80003f10:	8bae                	mv	s7,a1
    80003f12:	8a32                	mv	s4,a2
    80003f14:	84b6                	mv	s1,a3
    80003f16:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003f18:	9f35                	addw	a4,a4,a3
    return 0;
    80003f1a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003f1c:	0ad76063          	bltu	a4,a3,80003fbc <readi+0xd2>
  if(off + n > ip->size)
    80003f20:	00e7f463          	bgeu	a5,a4,80003f28 <readi+0x3e>
    n = ip->size - off;
    80003f24:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f28:	0a0a8963          	beqz	s5,80003fda <readi+0xf0>
    80003f2c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f2e:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003f32:	5c7d                	li	s8,-1
    80003f34:	a82d                	j	80003f6e <readi+0x84>
    80003f36:	020d1d93          	slli	s11,s10,0x20
    80003f3a:	020ddd93          	srli	s11,s11,0x20
    80003f3e:	05890793          	addi	a5,s2,88
    80003f42:	86ee                	mv	a3,s11
    80003f44:	963e                	add	a2,a2,a5
    80003f46:	85d2                	mv	a1,s4
    80003f48:	855e                	mv	a0,s7
    80003f4a:	ffffe097          	auipc	ra,0xffffe
    80003f4e:	788080e7          	jalr	1928(ra) # 800026d2 <either_copyout>
    80003f52:	05850d63          	beq	a0,s8,80003fac <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003f56:	854a                	mv	a0,s2
    80003f58:	fffff097          	auipc	ra,0xfffff
    80003f5c:	5f4080e7          	jalr	1524(ra) # 8000354c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f60:	013d09bb          	addw	s3,s10,s3
    80003f64:	009d04bb          	addw	s1,s10,s1
    80003f68:	9a6e                	add	s4,s4,s11
    80003f6a:	0559f763          	bgeu	s3,s5,80003fb8 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003f6e:	00a4d59b          	srliw	a1,s1,0xa
    80003f72:	855a                	mv	a0,s6
    80003f74:	00000097          	auipc	ra,0x0
    80003f78:	8a2080e7          	jalr	-1886(ra) # 80003816 <bmap>
    80003f7c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003f80:	cd85                	beqz	a1,80003fb8 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003f82:	000b2503          	lw	a0,0(s6)
    80003f86:	fffff097          	auipc	ra,0xfffff
    80003f8a:	496080e7          	jalr	1174(ra) # 8000341c <bread>
    80003f8e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f90:	3ff4f613          	andi	a2,s1,1023
    80003f94:	40cc87bb          	subw	a5,s9,a2
    80003f98:	413a873b          	subw	a4,s5,s3
    80003f9c:	8d3e                	mv	s10,a5
    80003f9e:	2781                	sext.w	a5,a5
    80003fa0:	0007069b          	sext.w	a3,a4
    80003fa4:	f8f6f9e3          	bgeu	a3,a5,80003f36 <readi+0x4c>
    80003fa8:	8d3a                	mv	s10,a4
    80003faa:	b771                	j	80003f36 <readi+0x4c>
      brelse(bp);
    80003fac:	854a                	mv	a0,s2
    80003fae:	fffff097          	auipc	ra,0xfffff
    80003fb2:	59e080e7          	jalr	1438(ra) # 8000354c <brelse>
      tot = -1;
    80003fb6:	59fd                	li	s3,-1
  }
  return tot;
    80003fb8:	0009851b          	sext.w	a0,s3
}
    80003fbc:	70a6                	ld	ra,104(sp)
    80003fbe:	7406                	ld	s0,96(sp)
    80003fc0:	64e6                	ld	s1,88(sp)
    80003fc2:	6946                	ld	s2,80(sp)
    80003fc4:	69a6                	ld	s3,72(sp)
    80003fc6:	6a06                	ld	s4,64(sp)
    80003fc8:	7ae2                	ld	s5,56(sp)
    80003fca:	7b42                	ld	s6,48(sp)
    80003fcc:	7ba2                	ld	s7,40(sp)
    80003fce:	7c02                	ld	s8,32(sp)
    80003fd0:	6ce2                	ld	s9,24(sp)
    80003fd2:	6d42                	ld	s10,16(sp)
    80003fd4:	6da2                	ld	s11,8(sp)
    80003fd6:	6165                	addi	sp,sp,112
    80003fd8:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003fda:	89d6                	mv	s3,s5
    80003fdc:	bff1                	j	80003fb8 <readi+0xce>
    return 0;
    80003fde:	4501                	li	a0,0
}
    80003fe0:	8082                	ret

0000000080003fe2 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003fe2:	457c                	lw	a5,76(a0)
    80003fe4:	10d7e863          	bltu	a5,a3,800040f4 <writei+0x112>
{
    80003fe8:	7159                	addi	sp,sp,-112
    80003fea:	f486                	sd	ra,104(sp)
    80003fec:	f0a2                	sd	s0,96(sp)
    80003fee:	eca6                	sd	s1,88(sp)
    80003ff0:	e8ca                	sd	s2,80(sp)
    80003ff2:	e4ce                	sd	s3,72(sp)
    80003ff4:	e0d2                	sd	s4,64(sp)
    80003ff6:	fc56                	sd	s5,56(sp)
    80003ff8:	f85a                	sd	s6,48(sp)
    80003ffa:	f45e                	sd	s7,40(sp)
    80003ffc:	f062                	sd	s8,32(sp)
    80003ffe:	ec66                	sd	s9,24(sp)
    80004000:	e86a                	sd	s10,16(sp)
    80004002:	e46e                	sd	s11,8(sp)
    80004004:	1880                	addi	s0,sp,112
    80004006:	8aaa                	mv	s5,a0
    80004008:	8bae                	mv	s7,a1
    8000400a:	8a32                	mv	s4,a2
    8000400c:	8936                	mv	s2,a3
    8000400e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004010:	00e687bb          	addw	a5,a3,a4
    80004014:	0ed7e263          	bltu	a5,a3,800040f8 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004018:	00043737          	lui	a4,0x43
    8000401c:	0ef76063          	bltu	a4,a5,800040fc <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004020:	0c0b0863          	beqz	s6,800040f0 <writei+0x10e>
    80004024:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004026:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000402a:	5c7d                	li	s8,-1
    8000402c:	a091                	j	80004070 <writei+0x8e>
    8000402e:	020d1d93          	slli	s11,s10,0x20
    80004032:	020ddd93          	srli	s11,s11,0x20
    80004036:	05848793          	addi	a5,s1,88
    8000403a:	86ee                	mv	a3,s11
    8000403c:	8652                	mv	a2,s4
    8000403e:	85de                	mv	a1,s7
    80004040:	953e                	add	a0,a0,a5
    80004042:	ffffe097          	auipc	ra,0xffffe
    80004046:	6e6080e7          	jalr	1766(ra) # 80002728 <either_copyin>
    8000404a:	07850263          	beq	a0,s8,800040ae <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000404e:	8526                	mv	a0,s1
    80004050:	00000097          	auipc	ra,0x0
    80004054:	780080e7          	jalr	1920(ra) # 800047d0 <log_write>
    brelse(bp);
    80004058:	8526                	mv	a0,s1
    8000405a:	fffff097          	auipc	ra,0xfffff
    8000405e:	4f2080e7          	jalr	1266(ra) # 8000354c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004062:	013d09bb          	addw	s3,s10,s3
    80004066:	012d093b          	addw	s2,s10,s2
    8000406a:	9a6e                	add	s4,s4,s11
    8000406c:	0569f663          	bgeu	s3,s6,800040b8 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80004070:	00a9559b          	srliw	a1,s2,0xa
    80004074:	8556                	mv	a0,s5
    80004076:	fffff097          	auipc	ra,0xfffff
    8000407a:	7a0080e7          	jalr	1952(ra) # 80003816 <bmap>
    8000407e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004082:	c99d                	beqz	a1,800040b8 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80004084:	000aa503          	lw	a0,0(s5)
    80004088:	fffff097          	auipc	ra,0xfffff
    8000408c:	394080e7          	jalr	916(ra) # 8000341c <bread>
    80004090:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004092:	3ff97513          	andi	a0,s2,1023
    80004096:	40ac87bb          	subw	a5,s9,a0
    8000409a:	413b073b          	subw	a4,s6,s3
    8000409e:	8d3e                	mv	s10,a5
    800040a0:	2781                	sext.w	a5,a5
    800040a2:	0007069b          	sext.w	a3,a4
    800040a6:	f8f6f4e3          	bgeu	a3,a5,8000402e <writei+0x4c>
    800040aa:	8d3a                	mv	s10,a4
    800040ac:	b749                	j	8000402e <writei+0x4c>
      brelse(bp);
    800040ae:	8526                	mv	a0,s1
    800040b0:	fffff097          	auipc	ra,0xfffff
    800040b4:	49c080e7          	jalr	1180(ra) # 8000354c <brelse>
  }

  if(off > ip->size)
    800040b8:	04caa783          	lw	a5,76(s5)
    800040bc:	0127f463          	bgeu	a5,s2,800040c4 <writei+0xe2>
    ip->size = off;
    800040c0:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800040c4:	8556                	mv	a0,s5
    800040c6:	00000097          	auipc	ra,0x0
    800040ca:	aa6080e7          	jalr	-1370(ra) # 80003b6c <iupdate>

  return tot;
    800040ce:	0009851b          	sext.w	a0,s3
}
    800040d2:	70a6                	ld	ra,104(sp)
    800040d4:	7406                	ld	s0,96(sp)
    800040d6:	64e6                	ld	s1,88(sp)
    800040d8:	6946                	ld	s2,80(sp)
    800040da:	69a6                	ld	s3,72(sp)
    800040dc:	6a06                	ld	s4,64(sp)
    800040de:	7ae2                	ld	s5,56(sp)
    800040e0:	7b42                	ld	s6,48(sp)
    800040e2:	7ba2                	ld	s7,40(sp)
    800040e4:	7c02                	ld	s8,32(sp)
    800040e6:	6ce2                	ld	s9,24(sp)
    800040e8:	6d42                	ld	s10,16(sp)
    800040ea:	6da2                	ld	s11,8(sp)
    800040ec:	6165                	addi	sp,sp,112
    800040ee:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800040f0:	89da                	mv	s3,s6
    800040f2:	bfc9                	j	800040c4 <writei+0xe2>
    return -1;
    800040f4:	557d                	li	a0,-1
}
    800040f6:	8082                	ret
    return -1;
    800040f8:	557d                	li	a0,-1
    800040fa:	bfe1                	j	800040d2 <writei+0xf0>
    return -1;
    800040fc:	557d                	li	a0,-1
    800040fe:	bfd1                	j	800040d2 <writei+0xf0>

0000000080004100 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004100:	1141                	addi	sp,sp,-16
    80004102:	e406                	sd	ra,8(sp)
    80004104:	e022                	sd	s0,0(sp)
    80004106:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004108:	4639                	li	a2,14
    8000410a:	ffffd097          	auipc	ra,0xffffd
    8000410e:	c98080e7          	jalr	-872(ra) # 80000da2 <strncmp>
}
    80004112:	60a2                	ld	ra,8(sp)
    80004114:	6402                	ld	s0,0(sp)
    80004116:	0141                	addi	sp,sp,16
    80004118:	8082                	ret

000000008000411a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000411a:	7139                	addi	sp,sp,-64
    8000411c:	fc06                	sd	ra,56(sp)
    8000411e:	f822                	sd	s0,48(sp)
    80004120:	f426                	sd	s1,40(sp)
    80004122:	f04a                	sd	s2,32(sp)
    80004124:	ec4e                	sd	s3,24(sp)
    80004126:	e852                	sd	s4,16(sp)
    80004128:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000412a:	04451703          	lh	a4,68(a0)
    8000412e:	4785                	li	a5,1
    80004130:	00f71a63          	bne	a4,a5,80004144 <dirlookup+0x2a>
    80004134:	892a                	mv	s2,a0
    80004136:	89ae                	mv	s3,a1
    80004138:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000413a:	457c                	lw	a5,76(a0)
    8000413c:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000413e:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004140:	e79d                	bnez	a5,8000416e <dirlookup+0x54>
    80004142:	a8a5                	j	800041ba <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004144:	00004517          	auipc	a0,0x4
    80004148:	66c50513          	addi	a0,a0,1644 # 800087b0 <syscallnum+0x160>
    8000414c:	ffffc097          	auipc	ra,0xffffc
    80004150:	3f2080e7          	jalr	1010(ra) # 8000053e <panic>
      panic("dirlookup read");
    80004154:	00004517          	auipc	a0,0x4
    80004158:	67450513          	addi	a0,a0,1652 # 800087c8 <syscallnum+0x178>
    8000415c:	ffffc097          	auipc	ra,0xffffc
    80004160:	3e2080e7          	jalr	994(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004164:	24c1                	addiw	s1,s1,16
    80004166:	04c92783          	lw	a5,76(s2)
    8000416a:	04f4f763          	bgeu	s1,a5,800041b8 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000416e:	4741                	li	a4,16
    80004170:	86a6                	mv	a3,s1
    80004172:	fc040613          	addi	a2,s0,-64
    80004176:	4581                	li	a1,0
    80004178:	854a                	mv	a0,s2
    8000417a:	00000097          	auipc	ra,0x0
    8000417e:	d70080e7          	jalr	-656(ra) # 80003eea <readi>
    80004182:	47c1                	li	a5,16
    80004184:	fcf518e3          	bne	a0,a5,80004154 <dirlookup+0x3a>
    if(de.inum == 0)
    80004188:	fc045783          	lhu	a5,-64(s0)
    8000418c:	dfe1                	beqz	a5,80004164 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000418e:	fc240593          	addi	a1,s0,-62
    80004192:	854e                	mv	a0,s3
    80004194:	00000097          	auipc	ra,0x0
    80004198:	f6c080e7          	jalr	-148(ra) # 80004100 <namecmp>
    8000419c:	f561                	bnez	a0,80004164 <dirlookup+0x4a>
      if(poff)
    8000419e:	000a0463          	beqz	s4,800041a6 <dirlookup+0x8c>
        *poff = off;
    800041a2:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800041a6:	fc045583          	lhu	a1,-64(s0)
    800041aa:	00092503          	lw	a0,0(s2)
    800041ae:	fffff097          	auipc	ra,0xfffff
    800041b2:	750080e7          	jalr	1872(ra) # 800038fe <iget>
    800041b6:	a011                	j	800041ba <dirlookup+0xa0>
  return 0;
    800041b8:	4501                	li	a0,0
}
    800041ba:	70e2                	ld	ra,56(sp)
    800041bc:	7442                	ld	s0,48(sp)
    800041be:	74a2                	ld	s1,40(sp)
    800041c0:	7902                	ld	s2,32(sp)
    800041c2:	69e2                	ld	s3,24(sp)
    800041c4:	6a42                	ld	s4,16(sp)
    800041c6:	6121                	addi	sp,sp,64
    800041c8:	8082                	ret

00000000800041ca <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800041ca:	711d                	addi	sp,sp,-96
    800041cc:	ec86                	sd	ra,88(sp)
    800041ce:	e8a2                	sd	s0,80(sp)
    800041d0:	e4a6                	sd	s1,72(sp)
    800041d2:	e0ca                	sd	s2,64(sp)
    800041d4:	fc4e                	sd	s3,56(sp)
    800041d6:	f852                	sd	s4,48(sp)
    800041d8:	f456                	sd	s5,40(sp)
    800041da:	f05a                	sd	s6,32(sp)
    800041dc:	ec5e                	sd	s7,24(sp)
    800041de:	e862                	sd	s8,16(sp)
    800041e0:	e466                	sd	s9,8(sp)
    800041e2:	1080                	addi	s0,sp,96
    800041e4:	84aa                	mv	s1,a0
    800041e6:	8aae                	mv	s5,a1
    800041e8:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    800041ea:	00054703          	lbu	a4,0(a0)
    800041ee:	02f00793          	li	a5,47
    800041f2:	02f70363          	beq	a4,a5,80004218 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800041f6:	ffffd097          	auipc	ra,0xffffd
    800041fa:	7b6080e7          	jalr	1974(ra) # 800019ac <myproc>
    800041fe:	15053503          	ld	a0,336(a0)
    80004202:	00000097          	auipc	ra,0x0
    80004206:	9f6080e7          	jalr	-1546(ra) # 80003bf8 <idup>
    8000420a:	89aa                	mv	s3,a0
  while(*path == '/')
    8000420c:	02f00913          	li	s2,47
  len = path - s;
    80004210:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004212:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004214:	4b85                	li	s7,1
    80004216:	a865                	j	800042ce <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004218:	4585                	li	a1,1
    8000421a:	4505                	li	a0,1
    8000421c:	fffff097          	auipc	ra,0xfffff
    80004220:	6e2080e7          	jalr	1762(ra) # 800038fe <iget>
    80004224:	89aa                	mv	s3,a0
    80004226:	b7dd                	j	8000420c <namex+0x42>
      iunlockput(ip);
    80004228:	854e                	mv	a0,s3
    8000422a:	00000097          	auipc	ra,0x0
    8000422e:	c6e080e7          	jalr	-914(ra) # 80003e98 <iunlockput>
      return 0;
    80004232:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004234:	854e                	mv	a0,s3
    80004236:	60e6                	ld	ra,88(sp)
    80004238:	6446                	ld	s0,80(sp)
    8000423a:	64a6                	ld	s1,72(sp)
    8000423c:	6906                	ld	s2,64(sp)
    8000423e:	79e2                	ld	s3,56(sp)
    80004240:	7a42                	ld	s4,48(sp)
    80004242:	7aa2                	ld	s5,40(sp)
    80004244:	7b02                	ld	s6,32(sp)
    80004246:	6be2                	ld	s7,24(sp)
    80004248:	6c42                	ld	s8,16(sp)
    8000424a:	6ca2                	ld	s9,8(sp)
    8000424c:	6125                	addi	sp,sp,96
    8000424e:	8082                	ret
      iunlock(ip);
    80004250:	854e                	mv	a0,s3
    80004252:	00000097          	auipc	ra,0x0
    80004256:	aa6080e7          	jalr	-1370(ra) # 80003cf8 <iunlock>
      return ip;
    8000425a:	bfe9                	j	80004234 <namex+0x6a>
      iunlockput(ip);
    8000425c:	854e                	mv	a0,s3
    8000425e:	00000097          	auipc	ra,0x0
    80004262:	c3a080e7          	jalr	-966(ra) # 80003e98 <iunlockput>
      return 0;
    80004266:	89e6                	mv	s3,s9
    80004268:	b7f1                	j	80004234 <namex+0x6a>
  len = path - s;
    8000426a:	40b48633          	sub	a2,s1,a1
    8000426e:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004272:	099c5463          	bge	s8,s9,800042fa <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004276:	4639                	li	a2,14
    80004278:	8552                	mv	a0,s4
    8000427a:	ffffd097          	auipc	ra,0xffffd
    8000427e:	ab4080e7          	jalr	-1356(ra) # 80000d2e <memmove>
  while(*path == '/')
    80004282:	0004c783          	lbu	a5,0(s1)
    80004286:	01279763          	bne	a5,s2,80004294 <namex+0xca>
    path++;
    8000428a:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000428c:	0004c783          	lbu	a5,0(s1)
    80004290:	ff278de3          	beq	a5,s2,8000428a <namex+0xc0>
    ilock(ip);
    80004294:	854e                	mv	a0,s3
    80004296:	00000097          	auipc	ra,0x0
    8000429a:	9a0080e7          	jalr	-1632(ra) # 80003c36 <ilock>
    if(ip->type != T_DIR){
    8000429e:	04499783          	lh	a5,68(s3)
    800042a2:	f97793e3          	bne	a5,s7,80004228 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800042a6:	000a8563          	beqz	s5,800042b0 <namex+0xe6>
    800042aa:	0004c783          	lbu	a5,0(s1)
    800042ae:	d3cd                	beqz	a5,80004250 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800042b0:	865a                	mv	a2,s6
    800042b2:	85d2                	mv	a1,s4
    800042b4:	854e                	mv	a0,s3
    800042b6:	00000097          	auipc	ra,0x0
    800042ba:	e64080e7          	jalr	-412(ra) # 8000411a <dirlookup>
    800042be:	8caa                	mv	s9,a0
    800042c0:	dd51                	beqz	a0,8000425c <namex+0x92>
    iunlockput(ip);
    800042c2:	854e                	mv	a0,s3
    800042c4:	00000097          	auipc	ra,0x0
    800042c8:	bd4080e7          	jalr	-1068(ra) # 80003e98 <iunlockput>
    ip = next;
    800042cc:	89e6                	mv	s3,s9
  while(*path == '/')
    800042ce:	0004c783          	lbu	a5,0(s1)
    800042d2:	05279763          	bne	a5,s2,80004320 <namex+0x156>
    path++;
    800042d6:	0485                	addi	s1,s1,1
  while(*path == '/')
    800042d8:	0004c783          	lbu	a5,0(s1)
    800042dc:	ff278de3          	beq	a5,s2,800042d6 <namex+0x10c>
  if(*path == 0)
    800042e0:	c79d                	beqz	a5,8000430e <namex+0x144>
    path++;
    800042e2:	85a6                	mv	a1,s1
  len = path - s;
    800042e4:	8cda                	mv	s9,s6
    800042e6:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    800042e8:	01278963          	beq	a5,s2,800042fa <namex+0x130>
    800042ec:	dfbd                	beqz	a5,8000426a <namex+0xa0>
    path++;
    800042ee:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800042f0:	0004c783          	lbu	a5,0(s1)
    800042f4:	ff279ce3          	bne	a5,s2,800042ec <namex+0x122>
    800042f8:	bf8d                	j	8000426a <namex+0xa0>
    memmove(name, s, len);
    800042fa:	2601                	sext.w	a2,a2
    800042fc:	8552                	mv	a0,s4
    800042fe:	ffffd097          	auipc	ra,0xffffd
    80004302:	a30080e7          	jalr	-1488(ra) # 80000d2e <memmove>
    name[len] = 0;
    80004306:	9cd2                	add	s9,s9,s4
    80004308:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000430c:	bf9d                	j	80004282 <namex+0xb8>
  if(nameiparent){
    8000430e:	f20a83e3          	beqz	s5,80004234 <namex+0x6a>
    iput(ip);
    80004312:	854e                	mv	a0,s3
    80004314:	00000097          	auipc	ra,0x0
    80004318:	adc080e7          	jalr	-1316(ra) # 80003df0 <iput>
    return 0;
    8000431c:	4981                	li	s3,0
    8000431e:	bf19                	j	80004234 <namex+0x6a>
  if(*path == 0)
    80004320:	d7fd                	beqz	a5,8000430e <namex+0x144>
  while(*path != '/' && *path != 0)
    80004322:	0004c783          	lbu	a5,0(s1)
    80004326:	85a6                	mv	a1,s1
    80004328:	b7d1                	j	800042ec <namex+0x122>

000000008000432a <dirlink>:
{
    8000432a:	7139                	addi	sp,sp,-64
    8000432c:	fc06                	sd	ra,56(sp)
    8000432e:	f822                	sd	s0,48(sp)
    80004330:	f426                	sd	s1,40(sp)
    80004332:	f04a                	sd	s2,32(sp)
    80004334:	ec4e                	sd	s3,24(sp)
    80004336:	e852                	sd	s4,16(sp)
    80004338:	0080                	addi	s0,sp,64
    8000433a:	892a                	mv	s2,a0
    8000433c:	8a2e                	mv	s4,a1
    8000433e:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004340:	4601                	li	a2,0
    80004342:	00000097          	auipc	ra,0x0
    80004346:	dd8080e7          	jalr	-552(ra) # 8000411a <dirlookup>
    8000434a:	e93d                	bnez	a0,800043c0 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000434c:	04c92483          	lw	s1,76(s2)
    80004350:	c49d                	beqz	s1,8000437e <dirlink+0x54>
    80004352:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004354:	4741                	li	a4,16
    80004356:	86a6                	mv	a3,s1
    80004358:	fc040613          	addi	a2,s0,-64
    8000435c:	4581                	li	a1,0
    8000435e:	854a                	mv	a0,s2
    80004360:	00000097          	auipc	ra,0x0
    80004364:	b8a080e7          	jalr	-1142(ra) # 80003eea <readi>
    80004368:	47c1                	li	a5,16
    8000436a:	06f51163          	bne	a0,a5,800043cc <dirlink+0xa2>
    if(de.inum == 0)
    8000436e:	fc045783          	lhu	a5,-64(s0)
    80004372:	c791                	beqz	a5,8000437e <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004374:	24c1                	addiw	s1,s1,16
    80004376:	04c92783          	lw	a5,76(s2)
    8000437a:	fcf4ede3          	bltu	s1,a5,80004354 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000437e:	4639                	li	a2,14
    80004380:	85d2                	mv	a1,s4
    80004382:	fc240513          	addi	a0,s0,-62
    80004386:	ffffd097          	auipc	ra,0xffffd
    8000438a:	a58080e7          	jalr	-1448(ra) # 80000dde <strncpy>
  de.inum = inum;
    8000438e:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004392:	4741                	li	a4,16
    80004394:	86a6                	mv	a3,s1
    80004396:	fc040613          	addi	a2,s0,-64
    8000439a:	4581                	li	a1,0
    8000439c:	854a                	mv	a0,s2
    8000439e:	00000097          	auipc	ra,0x0
    800043a2:	c44080e7          	jalr	-956(ra) # 80003fe2 <writei>
    800043a6:	1541                	addi	a0,a0,-16
    800043a8:	00a03533          	snez	a0,a0
    800043ac:	40a00533          	neg	a0,a0
}
    800043b0:	70e2                	ld	ra,56(sp)
    800043b2:	7442                	ld	s0,48(sp)
    800043b4:	74a2                	ld	s1,40(sp)
    800043b6:	7902                	ld	s2,32(sp)
    800043b8:	69e2                	ld	s3,24(sp)
    800043ba:	6a42                	ld	s4,16(sp)
    800043bc:	6121                	addi	sp,sp,64
    800043be:	8082                	ret
    iput(ip);
    800043c0:	00000097          	auipc	ra,0x0
    800043c4:	a30080e7          	jalr	-1488(ra) # 80003df0 <iput>
    return -1;
    800043c8:	557d                	li	a0,-1
    800043ca:	b7dd                	j	800043b0 <dirlink+0x86>
      panic("dirlink read");
    800043cc:	00004517          	auipc	a0,0x4
    800043d0:	40c50513          	addi	a0,a0,1036 # 800087d8 <syscallnum+0x188>
    800043d4:	ffffc097          	auipc	ra,0xffffc
    800043d8:	16a080e7          	jalr	362(ra) # 8000053e <panic>

00000000800043dc <namei>:

struct inode*
namei(char *path)
{
    800043dc:	1101                	addi	sp,sp,-32
    800043de:	ec06                	sd	ra,24(sp)
    800043e0:	e822                	sd	s0,16(sp)
    800043e2:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800043e4:	fe040613          	addi	a2,s0,-32
    800043e8:	4581                	li	a1,0
    800043ea:	00000097          	auipc	ra,0x0
    800043ee:	de0080e7          	jalr	-544(ra) # 800041ca <namex>
}
    800043f2:	60e2                	ld	ra,24(sp)
    800043f4:	6442                	ld	s0,16(sp)
    800043f6:	6105                	addi	sp,sp,32
    800043f8:	8082                	ret

00000000800043fa <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800043fa:	1141                	addi	sp,sp,-16
    800043fc:	e406                	sd	ra,8(sp)
    800043fe:	e022                	sd	s0,0(sp)
    80004400:	0800                	addi	s0,sp,16
    80004402:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004404:	4585                	li	a1,1
    80004406:	00000097          	auipc	ra,0x0
    8000440a:	dc4080e7          	jalr	-572(ra) # 800041ca <namex>
}
    8000440e:	60a2                	ld	ra,8(sp)
    80004410:	6402                	ld	s0,0(sp)
    80004412:	0141                	addi	sp,sp,16
    80004414:	8082                	ret

0000000080004416 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004416:	1101                	addi	sp,sp,-32
    80004418:	ec06                	sd	ra,24(sp)
    8000441a:	e822                	sd	s0,16(sp)
    8000441c:	e426                	sd	s1,8(sp)
    8000441e:	e04a                	sd	s2,0(sp)
    80004420:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004422:	0001e917          	auipc	s2,0x1e
    80004426:	77e90913          	addi	s2,s2,1918 # 80022ba0 <log>
    8000442a:	01892583          	lw	a1,24(s2)
    8000442e:	02892503          	lw	a0,40(s2)
    80004432:	fffff097          	auipc	ra,0xfffff
    80004436:	fea080e7          	jalr	-22(ra) # 8000341c <bread>
    8000443a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000443c:	02c92683          	lw	a3,44(s2)
    80004440:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004442:	02d05763          	blez	a3,80004470 <write_head+0x5a>
    80004446:	0001e797          	auipc	a5,0x1e
    8000444a:	78a78793          	addi	a5,a5,1930 # 80022bd0 <log+0x30>
    8000444e:	05c50713          	addi	a4,a0,92
    80004452:	36fd                	addiw	a3,a3,-1
    80004454:	1682                	slli	a3,a3,0x20
    80004456:	9281                	srli	a3,a3,0x20
    80004458:	068a                	slli	a3,a3,0x2
    8000445a:	0001e617          	auipc	a2,0x1e
    8000445e:	77a60613          	addi	a2,a2,1914 # 80022bd4 <log+0x34>
    80004462:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004464:	4390                	lw	a2,0(a5)
    80004466:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004468:	0791                	addi	a5,a5,4
    8000446a:	0711                	addi	a4,a4,4
    8000446c:	fed79ce3          	bne	a5,a3,80004464 <write_head+0x4e>
  }
  bwrite(buf);
    80004470:	8526                	mv	a0,s1
    80004472:	fffff097          	auipc	ra,0xfffff
    80004476:	09c080e7          	jalr	156(ra) # 8000350e <bwrite>
  brelse(buf);
    8000447a:	8526                	mv	a0,s1
    8000447c:	fffff097          	auipc	ra,0xfffff
    80004480:	0d0080e7          	jalr	208(ra) # 8000354c <brelse>
}
    80004484:	60e2                	ld	ra,24(sp)
    80004486:	6442                	ld	s0,16(sp)
    80004488:	64a2                	ld	s1,8(sp)
    8000448a:	6902                	ld	s2,0(sp)
    8000448c:	6105                	addi	sp,sp,32
    8000448e:	8082                	ret

0000000080004490 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004490:	0001e797          	auipc	a5,0x1e
    80004494:	73c7a783          	lw	a5,1852(a5) # 80022bcc <log+0x2c>
    80004498:	0af05d63          	blez	a5,80004552 <install_trans+0xc2>
{
    8000449c:	7139                	addi	sp,sp,-64
    8000449e:	fc06                	sd	ra,56(sp)
    800044a0:	f822                	sd	s0,48(sp)
    800044a2:	f426                	sd	s1,40(sp)
    800044a4:	f04a                	sd	s2,32(sp)
    800044a6:	ec4e                	sd	s3,24(sp)
    800044a8:	e852                	sd	s4,16(sp)
    800044aa:	e456                	sd	s5,8(sp)
    800044ac:	e05a                	sd	s6,0(sp)
    800044ae:	0080                	addi	s0,sp,64
    800044b0:	8b2a                	mv	s6,a0
    800044b2:	0001ea97          	auipc	s5,0x1e
    800044b6:	71ea8a93          	addi	s5,s5,1822 # 80022bd0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044ba:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800044bc:	0001e997          	auipc	s3,0x1e
    800044c0:	6e498993          	addi	s3,s3,1764 # 80022ba0 <log>
    800044c4:	a00d                	j	800044e6 <install_trans+0x56>
    brelse(lbuf);
    800044c6:	854a                	mv	a0,s2
    800044c8:	fffff097          	auipc	ra,0xfffff
    800044cc:	084080e7          	jalr	132(ra) # 8000354c <brelse>
    brelse(dbuf);
    800044d0:	8526                	mv	a0,s1
    800044d2:	fffff097          	auipc	ra,0xfffff
    800044d6:	07a080e7          	jalr	122(ra) # 8000354c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044da:	2a05                	addiw	s4,s4,1
    800044dc:	0a91                	addi	s5,s5,4
    800044de:	02c9a783          	lw	a5,44(s3)
    800044e2:	04fa5e63          	bge	s4,a5,8000453e <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800044e6:	0189a583          	lw	a1,24(s3)
    800044ea:	014585bb          	addw	a1,a1,s4
    800044ee:	2585                	addiw	a1,a1,1
    800044f0:	0289a503          	lw	a0,40(s3)
    800044f4:	fffff097          	auipc	ra,0xfffff
    800044f8:	f28080e7          	jalr	-216(ra) # 8000341c <bread>
    800044fc:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800044fe:	000aa583          	lw	a1,0(s5)
    80004502:	0289a503          	lw	a0,40(s3)
    80004506:	fffff097          	auipc	ra,0xfffff
    8000450a:	f16080e7          	jalr	-234(ra) # 8000341c <bread>
    8000450e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004510:	40000613          	li	a2,1024
    80004514:	05890593          	addi	a1,s2,88
    80004518:	05850513          	addi	a0,a0,88
    8000451c:	ffffd097          	auipc	ra,0xffffd
    80004520:	812080e7          	jalr	-2030(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    80004524:	8526                	mv	a0,s1
    80004526:	fffff097          	auipc	ra,0xfffff
    8000452a:	fe8080e7          	jalr	-24(ra) # 8000350e <bwrite>
    if(recovering == 0)
    8000452e:	f80b1ce3          	bnez	s6,800044c6 <install_trans+0x36>
      bunpin(dbuf);
    80004532:	8526                	mv	a0,s1
    80004534:	fffff097          	auipc	ra,0xfffff
    80004538:	0f2080e7          	jalr	242(ra) # 80003626 <bunpin>
    8000453c:	b769                	j	800044c6 <install_trans+0x36>
}
    8000453e:	70e2                	ld	ra,56(sp)
    80004540:	7442                	ld	s0,48(sp)
    80004542:	74a2                	ld	s1,40(sp)
    80004544:	7902                	ld	s2,32(sp)
    80004546:	69e2                	ld	s3,24(sp)
    80004548:	6a42                	ld	s4,16(sp)
    8000454a:	6aa2                	ld	s5,8(sp)
    8000454c:	6b02                	ld	s6,0(sp)
    8000454e:	6121                	addi	sp,sp,64
    80004550:	8082                	ret
    80004552:	8082                	ret

0000000080004554 <initlog>:
{
    80004554:	7179                	addi	sp,sp,-48
    80004556:	f406                	sd	ra,40(sp)
    80004558:	f022                	sd	s0,32(sp)
    8000455a:	ec26                	sd	s1,24(sp)
    8000455c:	e84a                	sd	s2,16(sp)
    8000455e:	e44e                	sd	s3,8(sp)
    80004560:	1800                	addi	s0,sp,48
    80004562:	892a                	mv	s2,a0
    80004564:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004566:	0001e497          	auipc	s1,0x1e
    8000456a:	63a48493          	addi	s1,s1,1594 # 80022ba0 <log>
    8000456e:	00004597          	auipc	a1,0x4
    80004572:	27a58593          	addi	a1,a1,634 # 800087e8 <syscallnum+0x198>
    80004576:	8526                	mv	a0,s1
    80004578:	ffffc097          	auipc	ra,0xffffc
    8000457c:	5ce080e7          	jalr	1486(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    80004580:	0149a583          	lw	a1,20(s3)
    80004584:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004586:	0109a783          	lw	a5,16(s3)
    8000458a:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000458c:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004590:	854a                	mv	a0,s2
    80004592:	fffff097          	auipc	ra,0xfffff
    80004596:	e8a080e7          	jalr	-374(ra) # 8000341c <bread>
  log.lh.n = lh->n;
    8000459a:	4d34                	lw	a3,88(a0)
    8000459c:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000459e:	02d05563          	blez	a3,800045c8 <initlog+0x74>
    800045a2:	05c50793          	addi	a5,a0,92
    800045a6:	0001e717          	auipc	a4,0x1e
    800045aa:	62a70713          	addi	a4,a4,1578 # 80022bd0 <log+0x30>
    800045ae:	36fd                	addiw	a3,a3,-1
    800045b0:	1682                	slli	a3,a3,0x20
    800045b2:	9281                	srli	a3,a3,0x20
    800045b4:	068a                	slli	a3,a3,0x2
    800045b6:	06050613          	addi	a2,a0,96
    800045ba:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800045bc:	4390                	lw	a2,0(a5)
    800045be:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800045c0:	0791                	addi	a5,a5,4
    800045c2:	0711                	addi	a4,a4,4
    800045c4:	fed79ce3          	bne	a5,a3,800045bc <initlog+0x68>
  brelse(buf);
    800045c8:	fffff097          	auipc	ra,0xfffff
    800045cc:	f84080e7          	jalr	-124(ra) # 8000354c <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800045d0:	4505                	li	a0,1
    800045d2:	00000097          	auipc	ra,0x0
    800045d6:	ebe080e7          	jalr	-322(ra) # 80004490 <install_trans>
  log.lh.n = 0;
    800045da:	0001e797          	auipc	a5,0x1e
    800045de:	5e07a923          	sw	zero,1522(a5) # 80022bcc <log+0x2c>
  write_head(); // clear the log
    800045e2:	00000097          	auipc	ra,0x0
    800045e6:	e34080e7          	jalr	-460(ra) # 80004416 <write_head>
}
    800045ea:	70a2                	ld	ra,40(sp)
    800045ec:	7402                	ld	s0,32(sp)
    800045ee:	64e2                	ld	s1,24(sp)
    800045f0:	6942                	ld	s2,16(sp)
    800045f2:	69a2                	ld	s3,8(sp)
    800045f4:	6145                	addi	sp,sp,48
    800045f6:	8082                	ret

00000000800045f8 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800045f8:	1101                	addi	sp,sp,-32
    800045fa:	ec06                	sd	ra,24(sp)
    800045fc:	e822                	sd	s0,16(sp)
    800045fe:	e426                	sd	s1,8(sp)
    80004600:	e04a                	sd	s2,0(sp)
    80004602:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004604:	0001e517          	auipc	a0,0x1e
    80004608:	59c50513          	addi	a0,a0,1436 # 80022ba0 <log>
    8000460c:	ffffc097          	auipc	ra,0xffffc
    80004610:	5ca080e7          	jalr	1482(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    80004614:	0001e497          	auipc	s1,0x1e
    80004618:	58c48493          	addi	s1,s1,1420 # 80022ba0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000461c:	4979                	li	s2,30
    8000461e:	a039                	j	8000462c <begin_op+0x34>
      sleep(&log, &log.lock);
    80004620:	85a6                	mv	a1,s1
    80004622:	8526                	mv	a0,s1
    80004624:	ffffe097          	auipc	ra,0xffffe
    80004628:	b4e080e7          	jalr	-1202(ra) # 80002172 <sleep>
    if(log.committing){
    8000462c:	50dc                	lw	a5,36(s1)
    8000462e:	fbed                	bnez	a5,80004620 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004630:	509c                	lw	a5,32(s1)
    80004632:	0017871b          	addiw	a4,a5,1
    80004636:	0007069b          	sext.w	a3,a4
    8000463a:	0027179b          	slliw	a5,a4,0x2
    8000463e:	9fb9                	addw	a5,a5,a4
    80004640:	0017979b          	slliw	a5,a5,0x1
    80004644:	54d8                	lw	a4,44(s1)
    80004646:	9fb9                	addw	a5,a5,a4
    80004648:	00f95963          	bge	s2,a5,8000465a <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000464c:	85a6                	mv	a1,s1
    8000464e:	8526                	mv	a0,s1
    80004650:	ffffe097          	auipc	ra,0xffffe
    80004654:	b22080e7          	jalr	-1246(ra) # 80002172 <sleep>
    80004658:	bfd1                	j	8000462c <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000465a:	0001e517          	auipc	a0,0x1e
    8000465e:	54650513          	addi	a0,a0,1350 # 80022ba0 <log>
    80004662:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004664:	ffffc097          	auipc	ra,0xffffc
    80004668:	626080e7          	jalr	1574(ra) # 80000c8a <release>
      break;
    }
  }
}
    8000466c:	60e2                	ld	ra,24(sp)
    8000466e:	6442                	ld	s0,16(sp)
    80004670:	64a2                	ld	s1,8(sp)
    80004672:	6902                	ld	s2,0(sp)
    80004674:	6105                	addi	sp,sp,32
    80004676:	8082                	ret

0000000080004678 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004678:	7139                	addi	sp,sp,-64
    8000467a:	fc06                	sd	ra,56(sp)
    8000467c:	f822                	sd	s0,48(sp)
    8000467e:	f426                	sd	s1,40(sp)
    80004680:	f04a                	sd	s2,32(sp)
    80004682:	ec4e                	sd	s3,24(sp)
    80004684:	e852                	sd	s4,16(sp)
    80004686:	e456                	sd	s5,8(sp)
    80004688:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000468a:	0001e497          	auipc	s1,0x1e
    8000468e:	51648493          	addi	s1,s1,1302 # 80022ba0 <log>
    80004692:	8526                	mv	a0,s1
    80004694:	ffffc097          	auipc	ra,0xffffc
    80004698:	542080e7          	jalr	1346(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    8000469c:	509c                	lw	a5,32(s1)
    8000469e:	37fd                	addiw	a5,a5,-1
    800046a0:	0007891b          	sext.w	s2,a5
    800046a4:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800046a6:	50dc                	lw	a5,36(s1)
    800046a8:	e7b9                	bnez	a5,800046f6 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800046aa:	04091e63          	bnez	s2,80004706 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800046ae:	0001e497          	auipc	s1,0x1e
    800046b2:	4f248493          	addi	s1,s1,1266 # 80022ba0 <log>
    800046b6:	4785                	li	a5,1
    800046b8:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800046ba:	8526                	mv	a0,s1
    800046bc:	ffffc097          	auipc	ra,0xffffc
    800046c0:	5ce080e7          	jalr	1486(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800046c4:	54dc                	lw	a5,44(s1)
    800046c6:	06f04763          	bgtz	a5,80004734 <end_op+0xbc>
    acquire(&log.lock);
    800046ca:	0001e497          	auipc	s1,0x1e
    800046ce:	4d648493          	addi	s1,s1,1238 # 80022ba0 <log>
    800046d2:	8526                	mv	a0,s1
    800046d4:	ffffc097          	auipc	ra,0xffffc
    800046d8:	502080e7          	jalr	1282(ra) # 80000bd6 <acquire>
    log.committing = 0;
    800046dc:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800046e0:	8526                	mv	a0,s1
    800046e2:	ffffe097          	auipc	ra,0xffffe
    800046e6:	c40080e7          	jalr	-960(ra) # 80002322 <wakeup>
    release(&log.lock);
    800046ea:	8526                	mv	a0,s1
    800046ec:	ffffc097          	auipc	ra,0xffffc
    800046f0:	59e080e7          	jalr	1438(ra) # 80000c8a <release>
}
    800046f4:	a03d                	j	80004722 <end_op+0xaa>
    panic("log.committing");
    800046f6:	00004517          	auipc	a0,0x4
    800046fa:	0fa50513          	addi	a0,a0,250 # 800087f0 <syscallnum+0x1a0>
    800046fe:	ffffc097          	auipc	ra,0xffffc
    80004702:	e40080e7          	jalr	-448(ra) # 8000053e <panic>
    wakeup(&log);
    80004706:	0001e497          	auipc	s1,0x1e
    8000470a:	49a48493          	addi	s1,s1,1178 # 80022ba0 <log>
    8000470e:	8526                	mv	a0,s1
    80004710:	ffffe097          	auipc	ra,0xffffe
    80004714:	c12080e7          	jalr	-1006(ra) # 80002322 <wakeup>
  release(&log.lock);
    80004718:	8526                	mv	a0,s1
    8000471a:	ffffc097          	auipc	ra,0xffffc
    8000471e:	570080e7          	jalr	1392(ra) # 80000c8a <release>
}
    80004722:	70e2                	ld	ra,56(sp)
    80004724:	7442                	ld	s0,48(sp)
    80004726:	74a2                	ld	s1,40(sp)
    80004728:	7902                	ld	s2,32(sp)
    8000472a:	69e2                	ld	s3,24(sp)
    8000472c:	6a42                	ld	s4,16(sp)
    8000472e:	6aa2                	ld	s5,8(sp)
    80004730:	6121                	addi	sp,sp,64
    80004732:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004734:	0001ea97          	auipc	s5,0x1e
    80004738:	49ca8a93          	addi	s5,s5,1180 # 80022bd0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000473c:	0001ea17          	auipc	s4,0x1e
    80004740:	464a0a13          	addi	s4,s4,1124 # 80022ba0 <log>
    80004744:	018a2583          	lw	a1,24(s4)
    80004748:	012585bb          	addw	a1,a1,s2
    8000474c:	2585                	addiw	a1,a1,1
    8000474e:	028a2503          	lw	a0,40(s4)
    80004752:	fffff097          	auipc	ra,0xfffff
    80004756:	cca080e7          	jalr	-822(ra) # 8000341c <bread>
    8000475a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000475c:	000aa583          	lw	a1,0(s5)
    80004760:	028a2503          	lw	a0,40(s4)
    80004764:	fffff097          	auipc	ra,0xfffff
    80004768:	cb8080e7          	jalr	-840(ra) # 8000341c <bread>
    8000476c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000476e:	40000613          	li	a2,1024
    80004772:	05850593          	addi	a1,a0,88
    80004776:	05848513          	addi	a0,s1,88
    8000477a:	ffffc097          	auipc	ra,0xffffc
    8000477e:	5b4080e7          	jalr	1460(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    80004782:	8526                	mv	a0,s1
    80004784:	fffff097          	auipc	ra,0xfffff
    80004788:	d8a080e7          	jalr	-630(ra) # 8000350e <bwrite>
    brelse(from);
    8000478c:	854e                	mv	a0,s3
    8000478e:	fffff097          	auipc	ra,0xfffff
    80004792:	dbe080e7          	jalr	-578(ra) # 8000354c <brelse>
    brelse(to);
    80004796:	8526                	mv	a0,s1
    80004798:	fffff097          	auipc	ra,0xfffff
    8000479c:	db4080e7          	jalr	-588(ra) # 8000354c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800047a0:	2905                	addiw	s2,s2,1
    800047a2:	0a91                	addi	s5,s5,4
    800047a4:	02ca2783          	lw	a5,44(s4)
    800047a8:	f8f94ee3          	blt	s2,a5,80004744 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800047ac:	00000097          	auipc	ra,0x0
    800047b0:	c6a080e7          	jalr	-918(ra) # 80004416 <write_head>
    install_trans(0); // Now install writes to home locations
    800047b4:	4501                	li	a0,0
    800047b6:	00000097          	auipc	ra,0x0
    800047ba:	cda080e7          	jalr	-806(ra) # 80004490 <install_trans>
    log.lh.n = 0;
    800047be:	0001e797          	auipc	a5,0x1e
    800047c2:	4007a723          	sw	zero,1038(a5) # 80022bcc <log+0x2c>
    write_head();    // Erase the transaction from the log
    800047c6:	00000097          	auipc	ra,0x0
    800047ca:	c50080e7          	jalr	-944(ra) # 80004416 <write_head>
    800047ce:	bdf5                	j	800046ca <end_op+0x52>

00000000800047d0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800047d0:	1101                	addi	sp,sp,-32
    800047d2:	ec06                	sd	ra,24(sp)
    800047d4:	e822                	sd	s0,16(sp)
    800047d6:	e426                	sd	s1,8(sp)
    800047d8:	e04a                	sd	s2,0(sp)
    800047da:	1000                	addi	s0,sp,32
    800047dc:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800047de:	0001e917          	auipc	s2,0x1e
    800047e2:	3c290913          	addi	s2,s2,962 # 80022ba0 <log>
    800047e6:	854a                	mv	a0,s2
    800047e8:	ffffc097          	auipc	ra,0xffffc
    800047ec:	3ee080e7          	jalr	1006(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800047f0:	02c92603          	lw	a2,44(s2)
    800047f4:	47f5                	li	a5,29
    800047f6:	06c7c563          	blt	a5,a2,80004860 <log_write+0x90>
    800047fa:	0001e797          	auipc	a5,0x1e
    800047fe:	3c27a783          	lw	a5,962(a5) # 80022bbc <log+0x1c>
    80004802:	37fd                	addiw	a5,a5,-1
    80004804:	04f65e63          	bge	a2,a5,80004860 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004808:	0001e797          	auipc	a5,0x1e
    8000480c:	3b87a783          	lw	a5,952(a5) # 80022bc0 <log+0x20>
    80004810:	06f05063          	blez	a5,80004870 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004814:	4781                	li	a5,0
    80004816:	06c05563          	blez	a2,80004880 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000481a:	44cc                	lw	a1,12(s1)
    8000481c:	0001e717          	auipc	a4,0x1e
    80004820:	3b470713          	addi	a4,a4,948 # 80022bd0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004824:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004826:	4314                	lw	a3,0(a4)
    80004828:	04b68c63          	beq	a3,a1,80004880 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000482c:	2785                	addiw	a5,a5,1
    8000482e:	0711                	addi	a4,a4,4
    80004830:	fef61be3          	bne	a2,a5,80004826 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004834:	0621                	addi	a2,a2,8
    80004836:	060a                	slli	a2,a2,0x2
    80004838:	0001e797          	auipc	a5,0x1e
    8000483c:	36878793          	addi	a5,a5,872 # 80022ba0 <log>
    80004840:	963e                	add	a2,a2,a5
    80004842:	44dc                	lw	a5,12(s1)
    80004844:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004846:	8526                	mv	a0,s1
    80004848:	fffff097          	auipc	ra,0xfffff
    8000484c:	da2080e7          	jalr	-606(ra) # 800035ea <bpin>
    log.lh.n++;
    80004850:	0001e717          	auipc	a4,0x1e
    80004854:	35070713          	addi	a4,a4,848 # 80022ba0 <log>
    80004858:	575c                	lw	a5,44(a4)
    8000485a:	2785                	addiw	a5,a5,1
    8000485c:	d75c                	sw	a5,44(a4)
    8000485e:	a835                	j	8000489a <log_write+0xca>
    panic("too big a transaction");
    80004860:	00004517          	auipc	a0,0x4
    80004864:	fa050513          	addi	a0,a0,-96 # 80008800 <syscallnum+0x1b0>
    80004868:	ffffc097          	auipc	ra,0xffffc
    8000486c:	cd6080e7          	jalr	-810(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    80004870:	00004517          	auipc	a0,0x4
    80004874:	fa850513          	addi	a0,a0,-88 # 80008818 <syscallnum+0x1c8>
    80004878:	ffffc097          	auipc	ra,0xffffc
    8000487c:	cc6080e7          	jalr	-826(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    80004880:	00878713          	addi	a4,a5,8
    80004884:	00271693          	slli	a3,a4,0x2
    80004888:	0001e717          	auipc	a4,0x1e
    8000488c:	31870713          	addi	a4,a4,792 # 80022ba0 <log>
    80004890:	9736                	add	a4,a4,a3
    80004892:	44d4                	lw	a3,12(s1)
    80004894:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004896:	faf608e3          	beq	a2,a5,80004846 <log_write+0x76>
  }
  release(&log.lock);
    8000489a:	0001e517          	auipc	a0,0x1e
    8000489e:	30650513          	addi	a0,a0,774 # 80022ba0 <log>
    800048a2:	ffffc097          	auipc	ra,0xffffc
    800048a6:	3e8080e7          	jalr	1000(ra) # 80000c8a <release>
}
    800048aa:	60e2                	ld	ra,24(sp)
    800048ac:	6442                	ld	s0,16(sp)
    800048ae:	64a2                	ld	s1,8(sp)
    800048b0:	6902                	ld	s2,0(sp)
    800048b2:	6105                	addi	sp,sp,32
    800048b4:	8082                	ret

00000000800048b6 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800048b6:	1101                	addi	sp,sp,-32
    800048b8:	ec06                	sd	ra,24(sp)
    800048ba:	e822                	sd	s0,16(sp)
    800048bc:	e426                	sd	s1,8(sp)
    800048be:	e04a                	sd	s2,0(sp)
    800048c0:	1000                	addi	s0,sp,32
    800048c2:	84aa                	mv	s1,a0
    800048c4:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800048c6:	00004597          	auipc	a1,0x4
    800048ca:	f7258593          	addi	a1,a1,-142 # 80008838 <syscallnum+0x1e8>
    800048ce:	0521                	addi	a0,a0,8
    800048d0:	ffffc097          	auipc	ra,0xffffc
    800048d4:	276080e7          	jalr	630(ra) # 80000b46 <initlock>
  lk->name = name;
    800048d8:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800048dc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800048e0:	0204a423          	sw	zero,40(s1)
}
    800048e4:	60e2                	ld	ra,24(sp)
    800048e6:	6442                	ld	s0,16(sp)
    800048e8:	64a2                	ld	s1,8(sp)
    800048ea:	6902                	ld	s2,0(sp)
    800048ec:	6105                	addi	sp,sp,32
    800048ee:	8082                	ret

00000000800048f0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800048f0:	1101                	addi	sp,sp,-32
    800048f2:	ec06                	sd	ra,24(sp)
    800048f4:	e822                	sd	s0,16(sp)
    800048f6:	e426                	sd	s1,8(sp)
    800048f8:	e04a                	sd	s2,0(sp)
    800048fa:	1000                	addi	s0,sp,32
    800048fc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800048fe:	00850913          	addi	s2,a0,8
    80004902:	854a                	mv	a0,s2
    80004904:	ffffc097          	auipc	ra,0xffffc
    80004908:	2d2080e7          	jalr	722(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    8000490c:	409c                	lw	a5,0(s1)
    8000490e:	cb89                	beqz	a5,80004920 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004910:	85ca                	mv	a1,s2
    80004912:	8526                	mv	a0,s1
    80004914:	ffffe097          	auipc	ra,0xffffe
    80004918:	85e080e7          	jalr	-1954(ra) # 80002172 <sleep>
  while (lk->locked) {
    8000491c:	409c                	lw	a5,0(s1)
    8000491e:	fbed                	bnez	a5,80004910 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004920:	4785                	li	a5,1
    80004922:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004924:	ffffd097          	auipc	ra,0xffffd
    80004928:	088080e7          	jalr	136(ra) # 800019ac <myproc>
    8000492c:	591c                	lw	a5,48(a0)
    8000492e:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004930:	854a                	mv	a0,s2
    80004932:	ffffc097          	auipc	ra,0xffffc
    80004936:	358080e7          	jalr	856(ra) # 80000c8a <release>
}
    8000493a:	60e2                	ld	ra,24(sp)
    8000493c:	6442                	ld	s0,16(sp)
    8000493e:	64a2                	ld	s1,8(sp)
    80004940:	6902                	ld	s2,0(sp)
    80004942:	6105                	addi	sp,sp,32
    80004944:	8082                	ret

0000000080004946 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004946:	1101                	addi	sp,sp,-32
    80004948:	ec06                	sd	ra,24(sp)
    8000494a:	e822                	sd	s0,16(sp)
    8000494c:	e426                	sd	s1,8(sp)
    8000494e:	e04a                	sd	s2,0(sp)
    80004950:	1000                	addi	s0,sp,32
    80004952:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004954:	00850913          	addi	s2,a0,8
    80004958:	854a                	mv	a0,s2
    8000495a:	ffffc097          	auipc	ra,0xffffc
    8000495e:	27c080e7          	jalr	636(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    80004962:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004966:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000496a:	8526                	mv	a0,s1
    8000496c:	ffffe097          	auipc	ra,0xffffe
    80004970:	9b6080e7          	jalr	-1610(ra) # 80002322 <wakeup>
  release(&lk->lk);
    80004974:	854a                	mv	a0,s2
    80004976:	ffffc097          	auipc	ra,0xffffc
    8000497a:	314080e7          	jalr	788(ra) # 80000c8a <release>
}
    8000497e:	60e2                	ld	ra,24(sp)
    80004980:	6442                	ld	s0,16(sp)
    80004982:	64a2                	ld	s1,8(sp)
    80004984:	6902                	ld	s2,0(sp)
    80004986:	6105                	addi	sp,sp,32
    80004988:	8082                	ret

000000008000498a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000498a:	7179                	addi	sp,sp,-48
    8000498c:	f406                	sd	ra,40(sp)
    8000498e:	f022                	sd	s0,32(sp)
    80004990:	ec26                	sd	s1,24(sp)
    80004992:	e84a                	sd	s2,16(sp)
    80004994:	e44e                	sd	s3,8(sp)
    80004996:	1800                	addi	s0,sp,48
    80004998:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000499a:	00850913          	addi	s2,a0,8
    8000499e:	854a                	mv	a0,s2
    800049a0:	ffffc097          	auipc	ra,0xffffc
    800049a4:	236080e7          	jalr	566(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800049a8:	409c                	lw	a5,0(s1)
    800049aa:	ef99                	bnez	a5,800049c8 <holdingsleep+0x3e>
    800049ac:	4481                	li	s1,0
  release(&lk->lk);
    800049ae:	854a                	mv	a0,s2
    800049b0:	ffffc097          	auipc	ra,0xffffc
    800049b4:	2da080e7          	jalr	730(ra) # 80000c8a <release>
  return r;
}
    800049b8:	8526                	mv	a0,s1
    800049ba:	70a2                	ld	ra,40(sp)
    800049bc:	7402                	ld	s0,32(sp)
    800049be:	64e2                	ld	s1,24(sp)
    800049c0:	6942                	ld	s2,16(sp)
    800049c2:	69a2                	ld	s3,8(sp)
    800049c4:	6145                	addi	sp,sp,48
    800049c6:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800049c8:	0284a983          	lw	s3,40(s1)
    800049cc:	ffffd097          	auipc	ra,0xffffd
    800049d0:	fe0080e7          	jalr	-32(ra) # 800019ac <myproc>
    800049d4:	5904                	lw	s1,48(a0)
    800049d6:	413484b3          	sub	s1,s1,s3
    800049da:	0014b493          	seqz	s1,s1
    800049de:	bfc1                	j	800049ae <holdingsleep+0x24>

00000000800049e0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800049e0:	1141                	addi	sp,sp,-16
    800049e2:	e406                	sd	ra,8(sp)
    800049e4:	e022                	sd	s0,0(sp)
    800049e6:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800049e8:	00004597          	auipc	a1,0x4
    800049ec:	e6058593          	addi	a1,a1,-416 # 80008848 <syscallnum+0x1f8>
    800049f0:	0001e517          	auipc	a0,0x1e
    800049f4:	2f850513          	addi	a0,a0,760 # 80022ce8 <ftable>
    800049f8:	ffffc097          	auipc	ra,0xffffc
    800049fc:	14e080e7          	jalr	334(ra) # 80000b46 <initlock>
}
    80004a00:	60a2                	ld	ra,8(sp)
    80004a02:	6402                	ld	s0,0(sp)
    80004a04:	0141                	addi	sp,sp,16
    80004a06:	8082                	ret

0000000080004a08 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004a08:	1101                	addi	sp,sp,-32
    80004a0a:	ec06                	sd	ra,24(sp)
    80004a0c:	e822                	sd	s0,16(sp)
    80004a0e:	e426                	sd	s1,8(sp)
    80004a10:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004a12:	0001e517          	auipc	a0,0x1e
    80004a16:	2d650513          	addi	a0,a0,726 # 80022ce8 <ftable>
    80004a1a:	ffffc097          	auipc	ra,0xffffc
    80004a1e:	1bc080e7          	jalr	444(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a22:	0001e497          	auipc	s1,0x1e
    80004a26:	2de48493          	addi	s1,s1,734 # 80022d00 <ftable+0x18>
    80004a2a:	0001f717          	auipc	a4,0x1f
    80004a2e:	27670713          	addi	a4,a4,630 # 80023ca0 <disk>
    if(f->ref == 0){
    80004a32:	40dc                	lw	a5,4(s1)
    80004a34:	cf99                	beqz	a5,80004a52 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a36:	02848493          	addi	s1,s1,40
    80004a3a:	fee49ce3          	bne	s1,a4,80004a32 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004a3e:	0001e517          	auipc	a0,0x1e
    80004a42:	2aa50513          	addi	a0,a0,682 # 80022ce8 <ftable>
    80004a46:	ffffc097          	auipc	ra,0xffffc
    80004a4a:	244080e7          	jalr	580(ra) # 80000c8a <release>
  return 0;
    80004a4e:	4481                	li	s1,0
    80004a50:	a819                	j	80004a66 <filealloc+0x5e>
      f->ref = 1;
    80004a52:	4785                	li	a5,1
    80004a54:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004a56:	0001e517          	auipc	a0,0x1e
    80004a5a:	29250513          	addi	a0,a0,658 # 80022ce8 <ftable>
    80004a5e:	ffffc097          	auipc	ra,0xffffc
    80004a62:	22c080e7          	jalr	556(ra) # 80000c8a <release>
}
    80004a66:	8526                	mv	a0,s1
    80004a68:	60e2                	ld	ra,24(sp)
    80004a6a:	6442                	ld	s0,16(sp)
    80004a6c:	64a2                	ld	s1,8(sp)
    80004a6e:	6105                	addi	sp,sp,32
    80004a70:	8082                	ret

0000000080004a72 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004a72:	1101                	addi	sp,sp,-32
    80004a74:	ec06                	sd	ra,24(sp)
    80004a76:	e822                	sd	s0,16(sp)
    80004a78:	e426                	sd	s1,8(sp)
    80004a7a:	1000                	addi	s0,sp,32
    80004a7c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004a7e:	0001e517          	auipc	a0,0x1e
    80004a82:	26a50513          	addi	a0,a0,618 # 80022ce8 <ftable>
    80004a86:	ffffc097          	auipc	ra,0xffffc
    80004a8a:	150080e7          	jalr	336(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004a8e:	40dc                	lw	a5,4(s1)
    80004a90:	02f05263          	blez	a5,80004ab4 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004a94:	2785                	addiw	a5,a5,1
    80004a96:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004a98:	0001e517          	auipc	a0,0x1e
    80004a9c:	25050513          	addi	a0,a0,592 # 80022ce8 <ftable>
    80004aa0:	ffffc097          	auipc	ra,0xffffc
    80004aa4:	1ea080e7          	jalr	490(ra) # 80000c8a <release>
  return f;
}
    80004aa8:	8526                	mv	a0,s1
    80004aaa:	60e2                	ld	ra,24(sp)
    80004aac:	6442                	ld	s0,16(sp)
    80004aae:	64a2                	ld	s1,8(sp)
    80004ab0:	6105                	addi	sp,sp,32
    80004ab2:	8082                	ret
    panic("filedup");
    80004ab4:	00004517          	auipc	a0,0x4
    80004ab8:	d9c50513          	addi	a0,a0,-612 # 80008850 <syscallnum+0x200>
    80004abc:	ffffc097          	auipc	ra,0xffffc
    80004ac0:	a82080e7          	jalr	-1406(ra) # 8000053e <panic>

0000000080004ac4 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004ac4:	7139                	addi	sp,sp,-64
    80004ac6:	fc06                	sd	ra,56(sp)
    80004ac8:	f822                	sd	s0,48(sp)
    80004aca:	f426                	sd	s1,40(sp)
    80004acc:	f04a                	sd	s2,32(sp)
    80004ace:	ec4e                	sd	s3,24(sp)
    80004ad0:	e852                	sd	s4,16(sp)
    80004ad2:	e456                	sd	s5,8(sp)
    80004ad4:	0080                	addi	s0,sp,64
    80004ad6:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004ad8:	0001e517          	auipc	a0,0x1e
    80004adc:	21050513          	addi	a0,a0,528 # 80022ce8 <ftable>
    80004ae0:	ffffc097          	auipc	ra,0xffffc
    80004ae4:	0f6080e7          	jalr	246(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004ae8:	40dc                	lw	a5,4(s1)
    80004aea:	06f05163          	blez	a5,80004b4c <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004aee:	37fd                	addiw	a5,a5,-1
    80004af0:	0007871b          	sext.w	a4,a5
    80004af4:	c0dc                	sw	a5,4(s1)
    80004af6:	06e04363          	bgtz	a4,80004b5c <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004afa:	0004a903          	lw	s2,0(s1)
    80004afe:	0094ca83          	lbu	s5,9(s1)
    80004b02:	0104ba03          	ld	s4,16(s1)
    80004b06:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004b0a:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004b0e:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004b12:	0001e517          	auipc	a0,0x1e
    80004b16:	1d650513          	addi	a0,a0,470 # 80022ce8 <ftable>
    80004b1a:	ffffc097          	auipc	ra,0xffffc
    80004b1e:	170080e7          	jalr	368(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    80004b22:	4785                	li	a5,1
    80004b24:	04f90d63          	beq	s2,a5,80004b7e <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004b28:	3979                	addiw	s2,s2,-2
    80004b2a:	4785                	li	a5,1
    80004b2c:	0527e063          	bltu	a5,s2,80004b6c <fileclose+0xa8>
    begin_op();
    80004b30:	00000097          	auipc	ra,0x0
    80004b34:	ac8080e7          	jalr	-1336(ra) # 800045f8 <begin_op>
    iput(ff.ip);
    80004b38:	854e                	mv	a0,s3
    80004b3a:	fffff097          	auipc	ra,0xfffff
    80004b3e:	2b6080e7          	jalr	694(ra) # 80003df0 <iput>
    end_op();
    80004b42:	00000097          	auipc	ra,0x0
    80004b46:	b36080e7          	jalr	-1226(ra) # 80004678 <end_op>
    80004b4a:	a00d                	j	80004b6c <fileclose+0xa8>
    panic("fileclose");
    80004b4c:	00004517          	auipc	a0,0x4
    80004b50:	d0c50513          	addi	a0,a0,-756 # 80008858 <syscallnum+0x208>
    80004b54:	ffffc097          	auipc	ra,0xffffc
    80004b58:	9ea080e7          	jalr	-1558(ra) # 8000053e <panic>
    release(&ftable.lock);
    80004b5c:	0001e517          	auipc	a0,0x1e
    80004b60:	18c50513          	addi	a0,a0,396 # 80022ce8 <ftable>
    80004b64:	ffffc097          	auipc	ra,0xffffc
    80004b68:	126080e7          	jalr	294(ra) # 80000c8a <release>
  }
}
    80004b6c:	70e2                	ld	ra,56(sp)
    80004b6e:	7442                	ld	s0,48(sp)
    80004b70:	74a2                	ld	s1,40(sp)
    80004b72:	7902                	ld	s2,32(sp)
    80004b74:	69e2                	ld	s3,24(sp)
    80004b76:	6a42                	ld	s4,16(sp)
    80004b78:	6aa2                	ld	s5,8(sp)
    80004b7a:	6121                	addi	sp,sp,64
    80004b7c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004b7e:	85d6                	mv	a1,s5
    80004b80:	8552                	mv	a0,s4
    80004b82:	00000097          	auipc	ra,0x0
    80004b86:	34c080e7          	jalr	844(ra) # 80004ece <pipeclose>
    80004b8a:	b7cd                	j	80004b6c <fileclose+0xa8>

0000000080004b8c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004b8c:	715d                	addi	sp,sp,-80
    80004b8e:	e486                	sd	ra,72(sp)
    80004b90:	e0a2                	sd	s0,64(sp)
    80004b92:	fc26                	sd	s1,56(sp)
    80004b94:	f84a                	sd	s2,48(sp)
    80004b96:	f44e                	sd	s3,40(sp)
    80004b98:	0880                	addi	s0,sp,80
    80004b9a:	84aa                	mv	s1,a0
    80004b9c:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004b9e:	ffffd097          	auipc	ra,0xffffd
    80004ba2:	e0e080e7          	jalr	-498(ra) # 800019ac <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004ba6:	409c                	lw	a5,0(s1)
    80004ba8:	37f9                	addiw	a5,a5,-2
    80004baa:	4705                	li	a4,1
    80004bac:	04f76763          	bltu	a4,a5,80004bfa <filestat+0x6e>
    80004bb0:	892a                	mv	s2,a0
    ilock(f->ip);
    80004bb2:	6c88                	ld	a0,24(s1)
    80004bb4:	fffff097          	auipc	ra,0xfffff
    80004bb8:	082080e7          	jalr	130(ra) # 80003c36 <ilock>
    stati(f->ip, &st);
    80004bbc:	fb840593          	addi	a1,s0,-72
    80004bc0:	6c88                	ld	a0,24(s1)
    80004bc2:	fffff097          	auipc	ra,0xfffff
    80004bc6:	2fe080e7          	jalr	766(ra) # 80003ec0 <stati>
    iunlock(f->ip);
    80004bca:	6c88                	ld	a0,24(s1)
    80004bcc:	fffff097          	auipc	ra,0xfffff
    80004bd0:	12c080e7          	jalr	300(ra) # 80003cf8 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004bd4:	46e1                	li	a3,24
    80004bd6:	fb840613          	addi	a2,s0,-72
    80004bda:	85ce                	mv	a1,s3
    80004bdc:	05093503          	ld	a0,80(s2)
    80004be0:	ffffd097          	auipc	ra,0xffffd
    80004be4:	a88080e7          	jalr	-1400(ra) # 80001668 <copyout>
    80004be8:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004bec:	60a6                	ld	ra,72(sp)
    80004bee:	6406                	ld	s0,64(sp)
    80004bf0:	74e2                	ld	s1,56(sp)
    80004bf2:	7942                	ld	s2,48(sp)
    80004bf4:	79a2                	ld	s3,40(sp)
    80004bf6:	6161                	addi	sp,sp,80
    80004bf8:	8082                	ret
  return -1;
    80004bfa:	557d                	li	a0,-1
    80004bfc:	bfc5                	j	80004bec <filestat+0x60>

0000000080004bfe <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004bfe:	7179                	addi	sp,sp,-48
    80004c00:	f406                	sd	ra,40(sp)
    80004c02:	f022                	sd	s0,32(sp)
    80004c04:	ec26                	sd	s1,24(sp)
    80004c06:	e84a                	sd	s2,16(sp)
    80004c08:	e44e                	sd	s3,8(sp)
    80004c0a:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004c0c:	00854783          	lbu	a5,8(a0)
    80004c10:	c3d5                	beqz	a5,80004cb4 <fileread+0xb6>
    80004c12:	84aa                	mv	s1,a0
    80004c14:	89ae                	mv	s3,a1
    80004c16:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004c18:	411c                	lw	a5,0(a0)
    80004c1a:	4705                	li	a4,1
    80004c1c:	04e78963          	beq	a5,a4,80004c6e <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004c20:	470d                	li	a4,3
    80004c22:	04e78d63          	beq	a5,a4,80004c7c <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c26:	4709                	li	a4,2
    80004c28:	06e79e63          	bne	a5,a4,80004ca4 <fileread+0xa6>
    ilock(f->ip);
    80004c2c:	6d08                	ld	a0,24(a0)
    80004c2e:	fffff097          	auipc	ra,0xfffff
    80004c32:	008080e7          	jalr	8(ra) # 80003c36 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004c36:	874a                	mv	a4,s2
    80004c38:	5094                	lw	a3,32(s1)
    80004c3a:	864e                	mv	a2,s3
    80004c3c:	4585                	li	a1,1
    80004c3e:	6c88                	ld	a0,24(s1)
    80004c40:	fffff097          	auipc	ra,0xfffff
    80004c44:	2aa080e7          	jalr	682(ra) # 80003eea <readi>
    80004c48:	892a                	mv	s2,a0
    80004c4a:	00a05563          	blez	a0,80004c54 <fileread+0x56>
      f->off += r;
    80004c4e:	509c                	lw	a5,32(s1)
    80004c50:	9fa9                	addw	a5,a5,a0
    80004c52:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004c54:	6c88                	ld	a0,24(s1)
    80004c56:	fffff097          	auipc	ra,0xfffff
    80004c5a:	0a2080e7          	jalr	162(ra) # 80003cf8 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004c5e:	854a                	mv	a0,s2
    80004c60:	70a2                	ld	ra,40(sp)
    80004c62:	7402                	ld	s0,32(sp)
    80004c64:	64e2                	ld	s1,24(sp)
    80004c66:	6942                	ld	s2,16(sp)
    80004c68:	69a2                	ld	s3,8(sp)
    80004c6a:	6145                	addi	sp,sp,48
    80004c6c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004c6e:	6908                	ld	a0,16(a0)
    80004c70:	00000097          	auipc	ra,0x0
    80004c74:	3c6080e7          	jalr	966(ra) # 80005036 <piperead>
    80004c78:	892a                	mv	s2,a0
    80004c7a:	b7d5                	j	80004c5e <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004c7c:	02451783          	lh	a5,36(a0)
    80004c80:	03079693          	slli	a3,a5,0x30
    80004c84:	92c1                	srli	a3,a3,0x30
    80004c86:	4725                	li	a4,9
    80004c88:	02d76863          	bltu	a4,a3,80004cb8 <fileread+0xba>
    80004c8c:	0792                	slli	a5,a5,0x4
    80004c8e:	0001e717          	auipc	a4,0x1e
    80004c92:	fba70713          	addi	a4,a4,-70 # 80022c48 <devsw>
    80004c96:	97ba                	add	a5,a5,a4
    80004c98:	639c                	ld	a5,0(a5)
    80004c9a:	c38d                	beqz	a5,80004cbc <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004c9c:	4505                	li	a0,1
    80004c9e:	9782                	jalr	a5
    80004ca0:	892a                	mv	s2,a0
    80004ca2:	bf75                	j	80004c5e <fileread+0x60>
    panic("fileread");
    80004ca4:	00004517          	auipc	a0,0x4
    80004ca8:	bc450513          	addi	a0,a0,-1084 # 80008868 <syscallnum+0x218>
    80004cac:	ffffc097          	auipc	ra,0xffffc
    80004cb0:	892080e7          	jalr	-1902(ra) # 8000053e <panic>
    return -1;
    80004cb4:	597d                	li	s2,-1
    80004cb6:	b765                	j	80004c5e <fileread+0x60>
      return -1;
    80004cb8:	597d                	li	s2,-1
    80004cba:	b755                	j	80004c5e <fileread+0x60>
    80004cbc:	597d                	li	s2,-1
    80004cbe:	b745                	j	80004c5e <fileread+0x60>

0000000080004cc0 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004cc0:	715d                	addi	sp,sp,-80
    80004cc2:	e486                	sd	ra,72(sp)
    80004cc4:	e0a2                	sd	s0,64(sp)
    80004cc6:	fc26                	sd	s1,56(sp)
    80004cc8:	f84a                	sd	s2,48(sp)
    80004cca:	f44e                	sd	s3,40(sp)
    80004ccc:	f052                	sd	s4,32(sp)
    80004cce:	ec56                	sd	s5,24(sp)
    80004cd0:	e85a                	sd	s6,16(sp)
    80004cd2:	e45e                	sd	s7,8(sp)
    80004cd4:	e062                	sd	s8,0(sp)
    80004cd6:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004cd8:	00954783          	lbu	a5,9(a0)
    80004cdc:	10078663          	beqz	a5,80004de8 <filewrite+0x128>
    80004ce0:	892a                	mv	s2,a0
    80004ce2:	8aae                	mv	s5,a1
    80004ce4:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004ce6:	411c                	lw	a5,0(a0)
    80004ce8:	4705                	li	a4,1
    80004cea:	02e78263          	beq	a5,a4,80004d0e <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004cee:	470d                	li	a4,3
    80004cf0:	02e78663          	beq	a5,a4,80004d1c <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004cf4:	4709                	li	a4,2
    80004cf6:	0ee79163          	bne	a5,a4,80004dd8 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004cfa:	0ac05d63          	blez	a2,80004db4 <filewrite+0xf4>
    int i = 0;
    80004cfe:	4981                	li	s3,0
    80004d00:	6b05                	lui	s6,0x1
    80004d02:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004d06:	6b85                	lui	s7,0x1
    80004d08:	c00b8b9b          	addiw	s7,s7,-1024
    80004d0c:	a861                	j	80004da4 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004d0e:	6908                	ld	a0,16(a0)
    80004d10:	00000097          	auipc	ra,0x0
    80004d14:	22e080e7          	jalr	558(ra) # 80004f3e <pipewrite>
    80004d18:	8a2a                	mv	s4,a0
    80004d1a:	a045                	j	80004dba <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004d1c:	02451783          	lh	a5,36(a0)
    80004d20:	03079693          	slli	a3,a5,0x30
    80004d24:	92c1                	srli	a3,a3,0x30
    80004d26:	4725                	li	a4,9
    80004d28:	0cd76263          	bltu	a4,a3,80004dec <filewrite+0x12c>
    80004d2c:	0792                	slli	a5,a5,0x4
    80004d2e:	0001e717          	auipc	a4,0x1e
    80004d32:	f1a70713          	addi	a4,a4,-230 # 80022c48 <devsw>
    80004d36:	97ba                	add	a5,a5,a4
    80004d38:	679c                	ld	a5,8(a5)
    80004d3a:	cbdd                	beqz	a5,80004df0 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004d3c:	4505                	li	a0,1
    80004d3e:	9782                	jalr	a5
    80004d40:	8a2a                	mv	s4,a0
    80004d42:	a8a5                	j	80004dba <filewrite+0xfa>
    80004d44:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004d48:	00000097          	auipc	ra,0x0
    80004d4c:	8b0080e7          	jalr	-1872(ra) # 800045f8 <begin_op>
      ilock(f->ip);
    80004d50:	01893503          	ld	a0,24(s2)
    80004d54:	fffff097          	auipc	ra,0xfffff
    80004d58:	ee2080e7          	jalr	-286(ra) # 80003c36 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004d5c:	8762                	mv	a4,s8
    80004d5e:	02092683          	lw	a3,32(s2)
    80004d62:	01598633          	add	a2,s3,s5
    80004d66:	4585                	li	a1,1
    80004d68:	01893503          	ld	a0,24(s2)
    80004d6c:	fffff097          	auipc	ra,0xfffff
    80004d70:	276080e7          	jalr	630(ra) # 80003fe2 <writei>
    80004d74:	84aa                	mv	s1,a0
    80004d76:	00a05763          	blez	a0,80004d84 <filewrite+0xc4>
        f->off += r;
    80004d7a:	02092783          	lw	a5,32(s2)
    80004d7e:	9fa9                	addw	a5,a5,a0
    80004d80:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004d84:	01893503          	ld	a0,24(s2)
    80004d88:	fffff097          	auipc	ra,0xfffff
    80004d8c:	f70080e7          	jalr	-144(ra) # 80003cf8 <iunlock>
      end_op();
    80004d90:	00000097          	auipc	ra,0x0
    80004d94:	8e8080e7          	jalr	-1816(ra) # 80004678 <end_op>

      if(r != n1){
    80004d98:	009c1f63          	bne	s8,s1,80004db6 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004d9c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004da0:	0149db63          	bge	s3,s4,80004db6 <filewrite+0xf6>
      int n1 = n - i;
    80004da4:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004da8:	84be                	mv	s1,a5
    80004daa:	2781                	sext.w	a5,a5
    80004dac:	f8fb5ce3          	bge	s6,a5,80004d44 <filewrite+0x84>
    80004db0:	84de                	mv	s1,s7
    80004db2:	bf49                	j	80004d44 <filewrite+0x84>
    int i = 0;
    80004db4:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004db6:	013a1f63          	bne	s4,s3,80004dd4 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004dba:	8552                	mv	a0,s4
    80004dbc:	60a6                	ld	ra,72(sp)
    80004dbe:	6406                	ld	s0,64(sp)
    80004dc0:	74e2                	ld	s1,56(sp)
    80004dc2:	7942                	ld	s2,48(sp)
    80004dc4:	79a2                	ld	s3,40(sp)
    80004dc6:	7a02                	ld	s4,32(sp)
    80004dc8:	6ae2                	ld	s5,24(sp)
    80004dca:	6b42                	ld	s6,16(sp)
    80004dcc:	6ba2                	ld	s7,8(sp)
    80004dce:	6c02                	ld	s8,0(sp)
    80004dd0:	6161                	addi	sp,sp,80
    80004dd2:	8082                	ret
    ret = (i == n ? n : -1);
    80004dd4:	5a7d                	li	s4,-1
    80004dd6:	b7d5                	j	80004dba <filewrite+0xfa>
    panic("filewrite");
    80004dd8:	00004517          	auipc	a0,0x4
    80004ddc:	aa050513          	addi	a0,a0,-1376 # 80008878 <syscallnum+0x228>
    80004de0:	ffffb097          	auipc	ra,0xffffb
    80004de4:	75e080e7          	jalr	1886(ra) # 8000053e <panic>
    return -1;
    80004de8:	5a7d                	li	s4,-1
    80004dea:	bfc1                	j	80004dba <filewrite+0xfa>
      return -1;
    80004dec:	5a7d                	li	s4,-1
    80004dee:	b7f1                	j	80004dba <filewrite+0xfa>
    80004df0:	5a7d                	li	s4,-1
    80004df2:	b7e1                	j	80004dba <filewrite+0xfa>

0000000080004df4 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004df4:	7179                	addi	sp,sp,-48
    80004df6:	f406                	sd	ra,40(sp)
    80004df8:	f022                	sd	s0,32(sp)
    80004dfa:	ec26                	sd	s1,24(sp)
    80004dfc:	e84a                	sd	s2,16(sp)
    80004dfe:	e44e                	sd	s3,8(sp)
    80004e00:	e052                	sd	s4,0(sp)
    80004e02:	1800                	addi	s0,sp,48
    80004e04:	84aa                	mv	s1,a0
    80004e06:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004e08:	0005b023          	sd	zero,0(a1)
    80004e0c:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004e10:	00000097          	auipc	ra,0x0
    80004e14:	bf8080e7          	jalr	-1032(ra) # 80004a08 <filealloc>
    80004e18:	e088                	sd	a0,0(s1)
    80004e1a:	c551                	beqz	a0,80004ea6 <pipealloc+0xb2>
    80004e1c:	00000097          	auipc	ra,0x0
    80004e20:	bec080e7          	jalr	-1044(ra) # 80004a08 <filealloc>
    80004e24:	00aa3023          	sd	a0,0(s4)
    80004e28:	c92d                	beqz	a0,80004e9a <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004e2a:	ffffc097          	auipc	ra,0xffffc
    80004e2e:	cbc080e7          	jalr	-836(ra) # 80000ae6 <kalloc>
    80004e32:	892a                	mv	s2,a0
    80004e34:	c125                	beqz	a0,80004e94 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004e36:	4985                	li	s3,1
    80004e38:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004e3c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004e40:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004e44:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004e48:	00003597          	auipc	a1,0x3
    80004e4c:	63858593          	addi	a1,a1,1592 # 80008480 <states.0+0x1b8>
    80004e50:	ffffc097          	auipc	ra,0xffffc
    80004e54:	cf6080e7          	jalr	-778(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004e58:	609c                	ld	a5,0(s1)
    80004e5a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004e5e:	609c                	ld	a5,0(s1)
    80004e60:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004e64:	609c                	ld	a5,0(s1)
    80004e66:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004e6a:	609c                	ld	a5,0(s1)
    80004e6c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004e70:	000a3783          	ld	a5,0(s4)
    80004e74:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004e78:	000a3783          	ld	a5,0(s4)
    80004e7c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004e80:	000a3783          	ld	a5,0(s4)
    80004e84:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004e88:	000a3783          	ld	a5,0(s4)
    80004e8c:	0127b823          	sd	s2,16(a5)
  return 0;
    80004e90:	4501                	li	a0,0
    80004e92:	a025                	j	80004eba <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004e94:	6088                	ld	a0,0(s1)
    80004e96:	e501                	bnez	a0,80004e9e <pipealloc+0xaa>
    80004e98:	a039                	j	80004ea6 <pipealloc+0xb2>
    80004e9a:	6088                	ld	a0,0(s1)
    80004e9c:	c51d                	beqz	a0,80004eca <pipealloc+0xd6>
    fileclose(*f0);
    80004e9e:	00000097          	auipc	ra,0x0
    80004ea2:	c26080e7          	jalr	-986(ra) # 80004ac4 <fileclose>
  if(*f1)
    80004ea6:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004eaa:	557d                	li	a0,-1
  if(*f1)
    80004eac:	c799                	beqz	a5,80004eba <pipealloc+0xc6>
    fileclose(*f1);
    80004eae:	853e                	mv	a0,a5
    80004eb0:	00000097          	auipc	ra,0x0
    80004eb4:	c14080e7          	jalr	-1004(ra) # 80004ac4 <fileclose>
  return -1;
    80004eb8:	557d                	li	a0,-1
}
    80004eba:	70a2                	ld	ra,40(sp)
    80004ebc:	7402                	ld	s0,32(sp)
    80004ebe:	64e2                	ld	s1,24(sp)
    80004ec0:	6942                	ld	s2,16(sp)
    80004ec2:	69a2                	ld	s3,8(sp)
    80004ec4:	6a02                	ld	s4,0(sp)
    80004ec6:	6145                	addi	sp,sp,48
    80004ec8:	8082                	ret
  return -1;
    80004eca:	557d                	li	a0,-1
    80004ecc:	b7fd                	j	80004eba <pipealloc+0xc6>

0000000080004ece <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004ece:	1101                	addi	sp,sp,-32
    80004ed0:	ec06                	sd	ra,24(sp)
    80004ed2:	e822                	sd	s0,16(sp)
    80004ed4:	e426                	sd	s1,8(sp)
    80004ed6:	e04a                	sd	s2,0(sp)
    80004ed8:	1000                	addi	s0,sp,32
    80004eda:	84aa                	mv	s1,a0
    80004edc:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004ede:	ffffc097          	auipc	ra,0xffffc
    80004ee2:	cf8080e7          	jalr	-776(ra) # 80000bd6 <acquire>
  if(writable){
    80004ee6:	02090d63          	beqz	s2,80004f20 <pipeclose+0x52>
    pi->writeopen = 0;
    80004eea:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004eee:	21848513          	addi	a0,s1,536
    80004ef2:	ffffd097          	auipc	ra,0xffffd
    80004ef6:	430080e7          	jalr	1072(ra) # 80002322 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004efa:	2204b783          	ld	a5,544(s1)
    80004efe:	eb95                	bnez	a5,80004f32 <pipeclose+0x64>
    release(&pi->lock);
    80004f00:	8526                	mv	a0,s1
    80004f02:	ffffc097          	auipc	ra,0xffffc
    80004f06:	d88080e7          	jalr	-632(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004f0a:	8526                	mv	a0,s1
    80004f0c:	ffffc097          	auipc	ra,0xffffc
    80004f10:	ade080e7          	jalr	-1314(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    80004f14:	60e2                	ld	ra,24(sp)
    80004f16:	6442                	ld	s0,16(sp)
    80004f18:	64a2                	ld	s1,8(sp)
    80004f1a:	6902                	ld	s2,0(sp)
    80004f1c:	6105                	addi	sp,sp,32
    80004f1e:	8082                	ret
    pi->readopen = 0;
    80004f20:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004f24:	21c48513          	addi	a0,s1,540
    80004f28:	ffffd097          	auipc	ra,0xffffd
    80004f2c:	3fa080e7          	jalr	1018(ra) # 80002322 <wakeup>
    80004f30:	b7e9                	j	80004efa <pipeclose+0x2c>
    release(&pi->lock);
    80004f32:	8526                	mv	a0,s1
    80004f34:	ffffc097          	auipc	ra,0xffffc
    80004f38:	d56080e7          	jalr	-682(ra) # 80000c8a <release>
}
    80004f3c:	bfe1                	j	80004f14 <pipeclose+0x46>

0000000080004f3e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004f3e:	711d                	addi	sp,sp,-96
    80004f40:	ec86                	sd	ra,88(sp)
    80004f42:	e8a2                	sd	s0,80(sp)
    80004f44:	e4a6                	sd	s1,72(sp)
    80004f46:	e0ca                	sd	s2,64(sp)
    80004f48:	fc4e                	sd	s3,56(sp)
    80004f4a:	f852                	sd	s4,48(sp)
    80004f4c:	f456                	sd	s5,40(sp)
    80004f4e:	f05a                	sd	s6,32(sp)
    80004f50:	ec5e                	sd	s7,24(sp)
    80004f52:	e862                	sd	s8,16(sp)
    80004f54:	1080                	addi	s0,sp,96
    80004f56:	84aa                	mv	s1,a0
    80004f58:	8aae                	mv	s5,a1
    80004f5a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004f5c:	ffffd097          	auipc	ra,0xffffd
    80004f60:	a50080e7          	jalr	-1456(ra) # 800019ac <myproc>
    80004f64:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004f66:	8526                	mv	a0,s1
    80004f68:	ffffc097          	auipc	ra,0xffffc
    80004f6c:	c6e080e7          	jalr	-914(ra) # 80000bd6 <acquire>
  while(i < n){
    80004f70:	0b405663          	blez	s4,8000501c <pipewrite+0xde>
  int i = 0;
    80004f74:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f76:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004f78:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004f7c:	21c48b93          	addi	s7,s1,540
    80004f80:	a089                	j	80004fc2 <pipewrite+0x84>
      release(&pi->lock);
    80004f82:	8526                	mv	a0,s1
    80004f84:	ffffc097          	auipc	ra,0xffffc
    80004f88:	d06080e7          	jalr	-762(ra) # 80000c8a <release>
      return -1;
    80004f8c:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004f8e:	854a                	mv	a0,s2
    80004f90:	60e6                	ld	ra,88(sp)
    80004f92:	6446                	ld	s0,80(sp)
    80004f94:	64a6                	ld	s1,72(sp)
    80004f96:	6906                	ld	s2,64(sp)
    80004f98:	79e2                	ld	s3,56(sp)
    80004f9a:	7a42                	ld	s4,48(sp)
    80004f9c:	7aa2                	ld	s5,40(sp)
    80004f9e:	7b02                	ld	s6,32(sp)
    80004fa0:	6be2                	ld	s7,24(sp)
    80004fa2:	6c42                	ld	s8,16(sp)
    80004fa4:	6125                	addi	sp,sp,96
    80004fa6:	8082                	ret
      wakeup(&pi->nread);
    80004fa8:	8562                	mv	a0,s8
    80004faa:	ffffd097          	auipc	ra,0xffffd
    80004fae:	378080e7          	jalr	888(ra) # 80002322 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004fb2:	85a6                	mv	a1,s1
    80004fb4:	855e                	mv	a0,s7
    80004fb6:	ffffd097          	auipc	ra,0xffffd
    80004fba:	1bc080e7          	jalr	444(ra) # 80002172 <sleep>
  while(i < n){
    80004fbe:	07495063          	bge	s2,s4,8000501e <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004fc2:	2204a783          	lw	a5,544(s1)
    80004fc6:	dfd5                	beqz	a5,80004f82 <pipewrite+0x44>
    80004fc8:	854e                	mv	a0,s3
    80004fca:	ffffd097          	auipc	ra,0xffffd
    80004fce:	5a8080e7          	jalr	1448(ra) # 80002572 <killed>
    80004fd2:	f945                	bnez	a0,80004f82 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004fd4:	2184a783          	lw	a5,536(s1)
    80004fd8:	21c4a703          	lw	a4,540(s1)
    80004fdc:	2007879b          	addiw	a5,a5,512
    80004fe0:	fcf704e3          	beq	a4,a5,80004fa8 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004fe4:	4685                	li	a3,1
    80004fe6:	01590633          	add	a2,s2,s5
    80004fea:	faf40593          	addi	a1,s0,-81
    80004fee:	0509b503          	ld	a0,80(s3)
    80004ff2:	ffffc097          	auipc	ra,0xffffc
    80004ff6:	702080e7          	jalr	1794(ra) # 800016f4 <copyin>
    80004ffa:	03650263          	beq	a0,s6,8000501e <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004ffe:	21c4a783          	lw	a5,540(s1)
    80005002:	0017871b          	addiw	a4,a5,1
    80005006:	20e4ae23          	sw	a4,540(s1)
    8000500a:	1ff7f793          	andi	a5,a5,511
    8000500e:	97a6                	add	a5,a5,s1
    80005010:	faf44703          	lbu	a4,-81(s0)
    80005014:	00e78c23          	sb	a4,24(a5)
      i++;
    80005018:	2905                	addiw	s2,s2,1
    8000501a:	b755                	j	80004fbe <pipewrite+0x80>
  int i = 0;
    8000501c:	4901                	li	s2,0
  wakeup(&pi->nread);
    8000501e:	21848513          	addi	a0,s1,536
    80005022:	ffffd097          	auipc	ra,0xffffd
    80005026:	300080e7          	jalr	768(ra) # 80002322 <wakeup>
  release(&pi->lock);
    8000502a:	8526                	mv	a0,s1
    8000502c:	ffffc097          	auipc	ra,0xffffc
    80005030:	c5e080e7          	jalr	-930(ra) # 80000c8a <release>
  return i;
    80005034:	bfa9                	j	80004f8e <pipewrite+0x50>

0000000080005036 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005036:	715d                	addi	sp,sp,-80
    80005038:	e486                	sd	ra,72(sp)
    8000503a:	e0a2                	sd	s0,64(sp)
    8000503c:	fc26                	sd	s1,56(sp)
    8000503e:	f84a                	sd	s2,48(sp)
    80005040:	f44e                	sd	s3,40(sp)
    80005042:	f052                	sd	s4,32(sp)
    80005044:	ec56                	sd	s5,24(sp)
    80005046:	e85a                	sd	s6,16(sp)
    80005048:	0880                	addi	s0,sp,80
    8000504a:	84aa                	mv	s1,a0
    8000504c:	892e                	mv	s2,a1
    8000504e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005050:	ffffd097          	auipc	ra,0xffffd
    80005054:	95c080e7          	jalr	-1700(ra) # 800019ac <myproc>
    80005058:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000505a:	8526                	mv	a0,s1
    8000505c:	ffffc097          	auipc	ra,0xffffc
    80005060:	b7a080e7          	jalr	-1158(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005064:	2184a703          	lw	a4,536(s1)
    80005068:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000506c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005070:	02f71763          	bne	a4,a5,8000509e <piperead+0x68>
    80005074:	2244a783          	lw	a5,548(s1)
    80005078:	c39d                	beqz	a5,8000509e <piperead+0x68>
    if(killed(pr)){
    8000507a:	8552                	mv	a0,s4
    8000507c:	ffffd097          	auipc	ra,0xffffd
    80005080:	4f6080e7          	jalr	1270(ra) # 80002572 <killed>
    80005084:	e941                	bnez	a0,80005114 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005086:	85a6                	mv	a1,s1
    80005088:	854e                	mv	a0,s3
    8000508a:	ffffd097          	auipc	ra,0xffffd
    8000508e:	0e8080e7          	jalr	232(ra) # 80002172 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005092:	2184a703          	lw	a4,536(s1)
    80005096:	21c4a783          	lw	a5,540(s1)
    8000509a:	fcf70de3          	beq	a4,a5,80005074 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000509e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800050a0:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050a2:	05505363          	blez	s5,800050e8 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    800050a6:	2184a783          	lw	a5,536(s1)
    800050aa:	21c4a703          	lw	a4,540(s1)
    800050ae:	02f70d63          	beq	a4,a5,800050e8 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800050b2:	0017871b          	addiw	a4,a5,1
    800050b6:	20e4ac23          	sw	a4,536(s1)
    800050ba:	1ff7f793          	andi	a5,a5,511
    800050be:	97a6                	add	a5,a5,s1
    800050c0:	0187c783          	lbu	a5,24(a5)
    800050c4:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800050c8:	4685                	li	a3,1
    800050ca:	fbf40613          	addi	a2,s0,-65
    800050ce:	85ca                	mv	a1,s2
    800050d0:	050a3503          	ld	a0,80(s4)
    800050d4:	ffffc097          	auipc	ra,0xffffc
    800050d8:	594080e7          	jalr	1428(ra) # 80001668 <copyout>
    800050dc:	01650663          	beq	a0,s6,800050e8 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050e0:	2985                	addiw	s3,s3,1
    800050e2:	0905                	addi	s2,s2,1
    800050e4:	fd3a91e3          	bne	s5,s3,800050a6 <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800050e8:	21c48513          	addi	a0,s1,540
    800050ec:	ffffd097          	auipc	ra,0xffffd
    800050f0:	236080e7          	jalr	566(ra) # 80002322 <wakeup>
  release(&pi->lock);
    800050f4:	8526                	mv	a0,s1
    800050f6:	ffffc097          	auipc	ra,0xffffc
    800050fa:	b94080e7          	jalr	-1132(ra) # 80000c8a <release>
  return i;
}
    800050fe:	854e                	mv	a0,s3
    80005100:	60a6                	ld	ra,72(sp)
    80005102:	6406                	ld	s0,64(sp)
    80005104:	74e2                	ld	s1,56(sp)
    80005106:	7942                	ld	s2,48(sp)
    80005108:	79a2                	ld	s3,40(sp)
    8000510a:	7a02                	ld	s4,32(sp)
    8000510c:	6ae2                	ld	s5,24(sp)
    8000510e:	6b42                	ld	s6,16(sp)
    80005110:	6161                	addi	sp,sp,80
    80005112:	8082                	ret
      release(&pi->lock);
    80005114:	8526                	mv	a0,s1
    80005116:	ffffc097          	auipc	ra,0xffffc
    8000511a:	b74080e7          	jalr	-1164(ra) # 80000c8a <release>
      return -1;
    8000511e:	59fd                	li	s3,-1
    80005120:	bff9                	j	800050fe <piperead+0xc8>

0000000080005122 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80005122:	1141                	addi	sp,sp,-16
    80005124:	e422                	sd	s0,8(sp)
    80005126:	0800                	addi	s0,sp,16
    80005128:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000512a:	8905                	andi	a0,a0,1
    8000512c:	c111                	beqz	a0,80005130 <flags2perm+0xe>
      perm = PTE_X;
    8000512e:	4521                	li	a0,8
    if(flags & 0x2)
    80005130:	8b89                	andi	a5,a5,2
    80005132:	c399                	beqz	a5,80005138 <flags2perm+0x16>
      perm |= PTE_W;
    80005134:	00456513          	ori	a0,a0,4
    return perm;
}
    80005138:	6422                	ld	s0,8(sp)
    8000513a:	0141                	addi	sp,sp,16
    8000513c:	8082                	ret

000000008000513e <exec>:

int
exec(char *path, char **argv)
{
    8000513e:	de010113          	addi	sp,sp,-544
    80005142:	20113c23          	sd	ra,536(sp)
    80005146:	20813823          	sd	s0,528(sp)
    8000514a:	20913423          	sd	s1,520(sp)
    8000514e:	21213023          	sd	s2,512(sp)
    80005152:	ffce                	sd	s3,504(sp)
    80005154:	fbd2                	sd	s4,496(sp)
    80005156:	f7d6                	sd	s5,488(sp)
    80005158:	f3da                	sd	s6,480(sp)
    8000515a:	efde                	sd	s7,472(sp)
    8000515c:	ebe2                	sd	s8,464(sp)
    8000515e:	e7e6                	sd	s9,456(sp)
    80005160:	e3ea                	sd	s10,448(sp)
    80005162:	ff6e                	sd	s11,440(sp)
    80005164:	1400                	addi	s0,sp,544
    80005166:	892a                	mv	s2,a0
    80005168:	dea43423          	sd	a0,-536(s0)
    8000516c:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005170:	ffffd097          	auipc	ra,0xffffd
    80005174:	83c080e7          	jalr	-1988(ra) # 800019ac <myproc>
    80005178:	84aa                	mv	s1,a0

  begin_op();
    8000517a:	fffff097          	auipc	ra,0xfffff
    8000517e:	47e080e7          	jalr	1150(ra) # 800045f8 <begin_op>

  if((ip = namei(path)) == 0){
    80005182:	854a                	mv	a0,s2
    80005184:	fffff097          	auipc	ra,0xfffff
    80005188:	258080e7          	jalr	600(ra) # 800043dc <namei>
    8000518c:	c93d                	beqz	a0,80005202 <exec+0xc4>
    8000518e:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005190:	fffff097          	auipc	ra,0xfffff
    80005194:	aa6080e7          	jalr	-1370(ra) # 80003c36 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005198:	04000713          	li	a4,64
    8000519c:	4681                	li	a3,0
    8000519e:	e5040613          	addi	a2,s0,-432
    800051a2:	4581                	li	a1,0
    800051a4:	8556                	mv	a0,s5
    800051a6:	fffff097          	auipc	ra,0xfffff
    800051aa:	d44080e7          	jalr	-700(ra) # 80003eea <readi>
    800051ae:	04000793          	li	a5,64
    800051b2:	00f51a63          	bne	a0,a5,800051c6 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800051b6:	e5042703          	lw	a4,-432(s0)
    800051ba:	464c47b7          	lui	a5,0x464c4
    800051be:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800051c2:	04f70663          	beq	a4,a5,8000520e <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800051c6:	8556                	mv	a0,s5
    800051c8:	fffff097          	auipc	ra,0xfffff
    800051cc:	cd0080e7          	jalr	-816(ra) # 80003e98 <iunlockput>
    end_op();
    800051d0:	fffff097          	auipc	ra,0xfffff
    800051d4:	4a8080e7          	jalr	1192(ra) # 80004678 <end_op>
  }
  return -1;
    800051d8:	557d                	li	a0,-1
}
    800051da:	21813083          	ld	ra,536(sp)
    800051de:	21013403          	ld	s0,528(sp)
    800051e2:	20813483          	ld	s1,520(sp)
    800051e6:	20013903          	ld	s2,512(sp)
    800051ea:	79fe                	ld	s3,504(sp)
    800051ec:	7a5e                	ld	s4,496(sp)
    800051ee:	7abe                	ld	s5,488(sp)
    800051f0:	7b1e                	ld	s6,480(sp)
    800051f2:	6bfe                	ld	s7,472(sp)
    800051f4:	6c5e                	ld	s8,464(sp)
    800051f6:	6cbe                	ld	s9,456(sp)
    800051f8:	6d1e                	ld	s10,448(sp)
    800051fa:	7dfa                	ld	s11,440(sp)
    800051fc:	22010113          	addi	sp,sp,544
    80005200:	8082                	ret
    end_op();
    80005202:	fffff097          	auipc	ra,0xfffff
    80005206:	476080e7          	jalr	1142(ra) # 80004678 <end_op>
    return -1;
    8000520a:	557d                	li	a0,-1
    8000520c:	b7f9                	j	800051da <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    8000520e:	8526                	mv	a0,s1
    80005210:	ffffd097          	auipc	ra,0xffffd
    80005214:	860080e7          	jalr	-1952(ra) # 80001a70 <proc_pagetable>
    80005218:	8b2a                	mv	s6,a0
    8000521a:	d555                	beqz	a0,800051c6 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000521c:	e7042783          	lw	a5,-400(s0)
    80005220:	e8845703          	lhu	a4,-376(s0)
    80005224:	c735                	beqz	a4,80005290 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005226:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005228:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    8000522c:	6a05                	lui	s4,0x1
    8000522e:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005232:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80005236:	6d85                	lui	s11,0x1
    80005238:	7d7d                	lui	s10,0xfffff
    8000523a:	a481                	j	8000547a <exec+0x33c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000523c:	00003517          	auipc	a0,0x3
    80005240:	64c50513          	addi	a0,a0,1612 # 80008888 <syscallnum+0x238>
    80005244:	ffffb097          	auipc	ra,0xffffb
    80005248:	2fa080e7          	jalr	762(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000524c:	874a                	mv	a4,s2
    8000524e:	009c86bb          	addw	a3,s9,s1
    80005252:	4581                	li	a1,0
    80005254:	8556                	mv	a0,s5
    80005256:	fffff097          	auipc	ra,0xfffff
    8000525a:	c94080e7          	jalr	-876(ra) # 80003eea <readi>
    8000525e:	2501                	sext.w	a0,a0
    80005260:	1aa91a63          	bne	s2,a0,80005414 <exec+0x2d6>
  for(i = 0; i < sz; i += PGSIZE){
    80005264:	009d84bb          	addw	s1,s11,s1
    80005268:	013d09bb          	addw	s3,s10,s3
    8000526c:	1f74f763          	bgeu	s1,s7,8000545a <exec+0x31c>
    pa = walkaddr(pagetable, va + i);
    80005270:	02049593          	slli	a1,s1,0x20
    80005274:	9181                	srli	a1,a1,0x20
    80005276:	95e2                	add	a1,a1,s8
    80005278:	855a                	mv	a0,s6
    8000527a:	ffffc097          	auipc	ra,0xffffc
    8000527e:	de2080e7          	jalr	-542(ra) # 8000105c <walkaddr>
    80005282:	862a                	mv	a2,a0
    if(pa == 0)
    80005284:	dd45                	beqz	a0,8000523c <exec+0xfe>
      n = PGSIZE;
    80005286:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005288:	fd49f2e3          	bgeu	s3,s4,8000524c <exec+0x10e>
      n = sz - i;
    8000528c:	894e                	mv	s2,s3
    8000528e:	bf7d                	j	8000524c <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005290:	4901                	li	s2,0
  iunlockput(ip);
    80005292:	8556                	mv	a0,s5
    80005294:	fffff097          	auipc	ra,0xfffff
    80005298:	c04080e7          	jalr	-1020(ra) # 80003e98 <iunlockput>
  end_op();
    8000529c:	fffff097          	auipc	ra,0xfffff
    800052a0:	3dc080e7          	jalr	988(ra) # 80004678 <end_op>
  p = myproc();
    800052a4:	ffffc097          	auipc	ra,0xffffc
    800052a8:	708080e7          	jalr	1800(ra) # 800019ac <myproc>
    800052ac:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    800052ae:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800052b2:	6785                	lui	a5,0x1
    800052b4:	17fd                	addi	a5,a5,-1
    800052b6:	993e                	add	s2,s2,a5
    800052b8:	77fd                	lui	a5,0xfffff
    800052ba:	00f977b3          	and	a5,s2,a5
    800052be:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800052c2:	4691                	li	a3,4
    800052c4:	6609                	lui	a2,0x2
    800052c6:	963e                	add	a2,a2,a5
    800052c8:	85be                	mv	a1,a5
    800052ca:	855a                	mv	a0,s6
    800052cc:	ffffc097          	auipc	ra,0xffffc
    800052d0:	144080e7          	jalr	324(ra) # 80001410 <uvmalloc>
    800052d4:	8c2a                	mv	s8,a0
  ip = 0;
    800052d6:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800052d8:	12050e63          	beqz	a0,80005414 <exec+0x2d6>
  uvmclear(pagetable, sz-2*PGSIZE);
    800052dc:	75f9                	lui	a1,0xffffe
    800052de:	95aa                	add	a1,a1,a0
    800052e0:	855a                	mv	a0,s6
    800052e2:	ffffc097          	auipc	ra,0xffffc
    800052e6:	354080e7          	jalr	852(ra) # 80001636 <uvmclear>
  stackbase = sp - PGSIZE;
    800052ea:	7afd                	lui	s5,0xfffff
    800052ec:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    800052ee:	df043783          	ld	a5,-528(s0)
    800052f2:	6388                	ld	a0,0(a5)
    800052f4:	c925                	beqz	a0,80005364 <exec+0x226>
    800052f6:	e9040993          	addi	s3,s0,-368
    800052fa:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800052fe:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005300:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005302:	ffffc097          	auipc	ra,0xffffc
    80005306:	b4c080e7          	jalr	-1204(ra) # 80000e4e <strlen>
    8000530a:	0015079b          	addiw	a5,a0,1
    8000530e:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005312:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005316:	13596663          	bltu	s2,s5,80005442 <exec+0x304>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000531a:	df043d83          	ld	s11,-528(s0)
    8000531e:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005322:	8552                	mv	a0,s4
    80005324:	ffffc097          	auipc	ra,0xffffc
    80005328:	b2a080e7          	jalr	-1238(ra) # 80000e4e <strlen>
    8000532c:	0015069b          	addiw	a3,a0,1
    80005330:	8652                	mv	a2,s4
    80005332:	85ca                	mv	a1,s2
    80005334:	855a                	mv	a0,s6
    80005336:	ffffc097          	auipc	ra,0xffffc
    8000533a:	332080e7          	jalr	818(ra) # 80001668 <copyout>
    8000533e:	10054663          	bltz	a0,8000544a <exec+0x30c>
    ustack[argc] = sp;
    80005342:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005346:	0485                	addi	s1,s1,1
    80005348:	008d8793          	addi	a5,s11,8
    8000534c:	def43823          	sd	a5,-528(s0)
    80005350:	008db503          	ld	a0,8(s11)
    80005354:	c911                	beqz	a0,80005368 <exec+0x22a>
    if(argc >= MAXARG)
    80005356:	09a1                	addi	s3,s3,8
    80005358:	fb3c95e3          	bne	s9,s3,80005302 <exec+0x1c4>
  sz = sz1;
    8000535c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005360:	4a81                	li	s5,0
    80005362:	a84d                	j	80005414 <exec+0x2d6>
  sp = sz;
    80005364:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005366:	4481                	li	s1,0
  ustack[argc] = 0;
    80005368:	00349793          	slli	a5,s1,0x3
    8000536c:	f9040713          	addi	a4,s0,-112
    80005370:	97ba                	add	a5,a5,a4
    80005372:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffdb120>
  sp -= (argc+1) * sizeof(uint64);
    80005376:	00148693          	addi	a3,s1,1
    8000537a:	068e                	slli	a3,a3,0x3
    8000537c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005380:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005384:	01597663          	bgeu	s2,s5,80005390 <exec+0x252>
  sz = sz1;
    80005388:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000538c:	4a81                	li	s5,0
    8000538e:	a059                	j	80005414 <exec+0x2d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005390:	e9040613          	addi	a2,s0,-368
    80005394:	85ca                	mv	a1,s2
    80005396:	855a                	mv	a0,s6
    80005398:	ffffc097          	auipc	ra,0xffffc
    8000539c:	2d0080e7          	jalr	720(ra) # 80001668 <copyout>
    800053a0:	0a054963          	bltz	a0,80005452 <exec+0x314>
  p->trapframe->a1 = sp;
    800053a4:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    800053a8:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800053ac:	de843783          	ld	a5,-536(s0)
    800053b0:	0007c703          	lbu	a4,0(a5)
    800053b4:	cf11                	beqz	a4,800053d0 <exec+0x292>
    800053b6:	0785                	addi	a5,a5,1
    if(*s == '/')
    800053b8:	02f00693          	li	a3,47
    800053bc:	a039                	j	800053ca <exec+0x28c>
      last = s+1;
    800053be:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800053c2:	0785                	addi	a5,a5,1
    800053c4:	fff7c703          	lbu	a4,-1(a5)
    800053c8:	c701                	beqz	a4,800053d0 <exec+0x292>
    if(*s == '/')
    800053ca:	fed71ce3          	bne	a4,a3,800053c2 <exec+0x284>
    800053ce:	bfc5                	j	800053be <exec+0x280>
  safestrcpy(p->name, last, sizeof(p->name));
    800053d0:	4641                	li	a2,16
    800053d2:	de843583          	ld	a1,-536(s0)
    800053d6:	158b8513          	addi	a0,s7,344
    800053da:	ffffc097          	auipc	ra,0xffffc
    800053de:	a42080e7          	jalr	-1470(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    800053e2:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    800053e6:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    800053ea:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800053ee:	058bb783          	ld	a5,88(s7)
    800053f2:	e6843703          	ld	a4,-408(s0)
    800053f6:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800053f8:	058bb783          	ld	a5,88(s7)
    800053fc:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005400:	85ea                	mv	a1,s10
    80005402:	ffffc097          	auipc	ra,0xffffc
    80005406:	70a080e7          	jalr	1802(ra) # 80001b0c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000540a:	0004851b          	sext.w	a0,s1
    8000540e:	b3f1                	j	800051da <exec+0x9c>
    80005410:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005414:	df843583          	ld	a1,-520(s0)
    80005418:	855a                	mv	a0,s6
    8000541a:	ffffc097          	auipc	ra,0xffffc
    8000541e:	6f2080e7          	jalr	1778(ra) # 80001b0c <proc_freepagetable>
  if(ip){
    80005422:	da0a92e3          	bnez	s5,800051c6 <exec+0x88>
  return -1;
    80005426:	557d                	li	a0,-1
    80005428:	bb4d                	j	800051da <exec+0x9c>
    8000542a:	df243c23          	sd	s2,-520(s0)
    8000542e:	b7dd                	j	80005414 <exec+0x2d6>
    80005430:	df243c23          	sd	s2,-520(s0)
    80005434:	b7c5                	j	80005414 <exec+0x2d6>
    80005436:	df243c23          	sd	s2,-520(s0)
    8000543a:	bfe9                	j	80005414 <exec+0x2d6>
    8000543c:	df243c23          	sd	s2,-520(s0)
    80005440:	bfd1                	j	80005414 <exec+0x2d6>
  sz = sz1;
    80005442:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005446:	4a81                	li	s5,0
    80005448:	b7f1                	j	80005414 <exec+0x2d6>
  sz = sz1;
    8000544a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000544e:	4a81                	li	s5,0
    80005450:	b7d1                	j	80005414 <exec+0x2d6>
  sz = sz1;
    80005452:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005456:	4a81                	li	s5,0
    80005458:	bf75                	j	80005414 <exec+0x2d6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000545a:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000545e:	e0843783          	ld	a5,-504(s0)
    80005462:	0017869b          	addiw	a3,a5,1
    80005466:	e0d43423          	sd	a3,-504(s0)
    8000546a:	e0043783          	ld	a5,-512(s0)
    8000546e:	0387879b          	addiw	a5,a5,56
    80005472:	e8845703          	lhu	a4,-376(s0)
    80005476:	e0e6dee3          	bge	a3,a4,80005292 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000547a:	2781                	sext.w	a5,a5
    8000547c:	e0f43023          	sd	a5,-512(s0)
    80005480:	03800713          	li	a4,56
    80005484:	86be                	mv	a3,a5
    80005486:	e1840613          	addi	a2,s0,-488
    8000548a:	4581                	li	a1,0
    8000548c:	8556                	mv	a0,s5
    8000548e:	fffff097          	auipc	ra,0xfffff
    80005492:	a5c080e7          	jalr	-1444(ra) # 80003eea <readi>
    80005496:	03800793          	li	a5,56
    8000549a:	f6f51be3          	bne	a0,a5,80005410 <exec+0x2d2>
    if(ph.type != ELF_PROG_LOAD)
    8000549e:	e1842783          	lw	a5,-488(s0)
    800054a2:	4705                	li	a4,1
    800054a4:	fae79de3          	bne	a5,a4,8000545e <exec+0x320>
    if(ph.memsz < ph.filesz)
    800054a8:	e4043483          	ld	s1,-448(s0)
    800054ac:	e3843783          	ld	a5,-456(s0)
    800054b0:	f6f4ede3          	bltu	s1,a5,8000542a <exec+0x2ec>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800054b4:	e2843783          	ld	a5,-472(s0)
    800054b8:	94be                	add	s1,s1,a5
    800054ba:	f6f4ebe3          	bltu	s1,a5,80005430 <exec+0x2f2>
    if(ph.vaddr % PGSIZE != 0)
    800054be:	de043703          	ld	a4,-544(s0)
    800054c2:	8ff9                	and	a5,a5,a4
    800054c4:	fbad                	bnez	a5,80005436 <exec+0x2f8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800054c6:	e1c42503          	lw	a0,-484(s0)
    800054ca:	00000097          	auipc	ra,0x0
    800054ce:	c58080e7          	jalr	-936(ra) # 80005122 <flags2perm>
    800054d2:	86aa                	mv	a3,a0
    800054d4:	8626                	mv	a2,s1
    800054d6:	85ca                	mv	a1,s2
    800054d8:	855a                	mv	a0,s6
    800054da:	ffffc097          	auipc	ra,0xffffc
    800054de:	f36080e7          	jalr	-202(ra) # 80001410 <uvmalloc>
    800054e2:	dea43c23          	sd	a0,-520(s0)
    800054e6:	d939                	beqz	a0,8000543c <exec+0x2fe>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800054e8:	e2843c03          	ld	s8,-472(s0)
    800054ec:	e2042c83          	lw	s9,-480(s0)
    800054f0:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800054f4:	f60b83e3          	beqz	s7,8000545a <exec+0x31c>
    800054f8:	89de                	mv	s3,s7
    800054fa:	4481                	li	s1,0
    800054fc:	bb95                	j	80005270 <exec+0x132>

00000000800054fe <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800054fe:	7179                	addi	sp,sp,-48
    80005500:	f406                	sd	ra,40(sp)
    80005502:	f022                	sd	s0,32(sp)
    80005504:	ec26                	sd	s1,24(sp)
    80005506:	e84a                	sd	s2,16(sp)
    80005508:	1800                	addi	s0,sp,48
    8000550a:	892e                	mv	s2,a1
    8000550c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000550e:	fdc40593          	addi	a1,s0,-36
    80005512:	ffffe097          	auipc	ra,0xffffe
    80005516:	906080e7          	jalr	-1786(ra) # 80002e18 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000551a:	fdc42703          	lw	a4,-36(s0)
    8000551e:	47bd                	li	a5,15
    80005520:	02e7eb63          	bltu	a5,a4,80005556 <argfd+0x58>
    80005524:	ffffc097          	auipc	ra,0xffffc
    80005528:	488080e7          	jalr	1160(ra) # 800019ac <myproc>
    8000552c:	fdc42703          	lw	a4,-36(s0)
    80005530:	01a70793          	addi	a5,a4,26
    80005534:	078e                	slli	a5,a5,0x3
    80005536:	953e                	add	a0,a0,a5
    80005538:	611c                	ld	a5,0(a0)
    8000553a:	c385                	beqz	a5,8000555a <argfd+0x5c>
    return -1;
  if(pfd)
    8000553c:	00090463          	beqz	s2,80005544 <argfd+0x46>
    *pfd = fd;
    80005540:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005544:	4501                	li	a0,0
  if(pf)
    80005546:	c091                	beqz	s1,8000554a <argfd+0x4c>
    *pf = f;
    80005548:	e09c                	sd	a5,0(s1)
}
    8000554a:	70a2                	ld	ra,40(sp)
    8000554c:	7402                	ld	s0,32(sp)
    8000554e:	64e2                	ld	s1,24(sp)
    80005550:	6942                	ld	s2,16(sp)
    80005552:	6145                	addi	sp,sp,48
    80005554:	8082                	ret
    return -1;
    80005556:	557d                	li	a0,-1
    80005558:	bfcd                	j	8000554a <argfd+0x4c>
    8000555a:	557d                	li	a0,-1
    8000555c:	b7fd                	j	8000554a <argfd+0x4c>

000000008000555e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000555e:	1101                	addi	sp,sp,-32
    80005560:	ec06                	sd	ra,24(sp)
    80005562:	e822                	sd	s0,16(sp)
    80005564:	e426                	sd	s1,8(sp)
    80005566:	1000                	addi	s0,sp,32
    80005568:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000556a:	ffffc097          	auipc	ra,0xffffc
    8000556e:	442080e7          	jalr	1090(ra) # 800019ac <myproc>
    80005572:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005574:	0d050793          	addi	a5,a0,208
    80005578:	4501                	li	a0,0
    8000557a:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000557c:	6398                	ld	a4,0(a5)
    8000557e:	cb19                	beqz	a4,80005594 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005580:	2505                	addiw	a0,a0,1
    80005582:	07a1                	addi	a5,a5,8
    80005584:	fed51ce3          	bne	a0,a3,8000557c <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005588:	557d                	li	a0,-1
}
    8000558a:	60e2                	ld	ra,24(sp)
    8000558c:	6442                	ld	s0,16(sp)
    8000558e:	64a2                	ld	s1,8(sp)
    80005590:	6105                	addi	sp,sp,32
    80005592:	8082                	ret
      p->ofile[fd] = f;
    80005594:	01a50793          	addi	a5,a0,26
    80005598:	078e                	slli	a5,a5,0x3
    8000559a:	963e                	add	a2,a2,a5
    8000559c:	e204                	sd	s1,0(a2)
      return fd;
    8000559e:	b7f5                	j	8000558a <fdalloc+0x2c>

00000000800055a0 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800055a0:	715d                	addi	sp,sp,-80
    800055a2:	e486                	sd	ra,72(sp)
    800055a4:	e0a2                	sd	s0,64(sp)
    800055a6:	fc26                	sd	s1,56(sp)
    800055a8:	f84a                	sd	s2,48(sp)
    800055aa:	f44e                	sd	s3,40(sp)
    800055ac:	f052                	sd	s4,32(sp)
    800055ae:	ec56                	sd	s5,24(sp)
    800055b0:	e85a                	sd	s6,16(sp)
    800055b2:	0880                	addi	s0,sp,80
    800055b4:	8b2e                	mv	s6,a1
    800055b6:	89b2                	mv	s3,a2
    800055b8:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800055ba:	fb040593          	addi	a1,s0,-80
    800055be:	fffff097          	auipc	ra,0xfffff
    800055c2:	e3c080e7          	jalr	-452(ra) # 800043fa <nameiparent>
    800055c6:	84aa                	mv	s1,a0
    800055c8:	14050f63          	beqz	a0,80005726 <create+0x186>
    return 0;

  ilock(dp);
    800055cc:	ffffe097          	auipc	ra,0xffffe
    800055d0:	66a080e7          	jalr	1642(ra) # 80003c36 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800055d4:	4601                	li	a2,0
    800055d6:	fb040593          	addi	a1,s0,-80
    800055da:	8526                	mv	a0,s1
    800055dc:	fffff097          	auipc	ra,0xfffff
    800055e0:	b3e080e7          	jalr	-1218(ra) # 8000411a <dirlookup>
    800055e4:	8aaa                	mv	s5,a0
    800055e6:	c931                	beqz	a0,8000563a <create+0x9a>
    iunlockput(dp);
    800055e8:	8526                	mv	a0,s1
    800055ea:	fffff097          	auipc	ra,0xfffff
    800055ee:	8ae080e7          	jalr	-1874(ra) # 80003e98 <iunlockput>
    ilock(ip);
    800055f2:	8556                	mv	a0,s5
    800055f4:	ffffe097          	auipc	ra,0xffffe
    800055f8:	642080e7          	jalr	1602(ra) # 80003c36 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800055fc:	000b059b          	sext.w	a1,s6
    80005600:	4789                	li	a5,2
    80005602:	02f59563          	bne	a1,a5,8000562c <create+0x8c>
    80005606:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdb264>
    8000560a:	37f9                	addiw	a5,a5,-2
    8000560c:	17c2                	slli	a5,a5,0x30
    8000560e:	93c1                	srli	a5,a5,0x30
    80005610:	4705                	li	a4,1
    80005612:	00f76d63          	bltu	a4,a5,8000562c <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005616:	8556                	mv	a0,s5
    80005618:	60a6                	ld	ra,72(sp)
    8000561a:	6406                	ld	s0,64(sp)
    8000561c:	74e2                	ld	s1,56(sp)
    8000561e:	7942                	ld	s2,48(sp)
    80005620:	79a2                	ld	s3,40(sp)
    80005622:	7a02                	ld	s4,32(sp)
    80005624:	6ae2                	ld	s5,24(sp)
    80005626:	6b42                	ld	s6,16(sp)
    80005628:	6161                	addi	sp,sp,80
    8000562a:	8082                	ret
    iunlockput(ip);
    8000562c:	8556                	mv	a0,s5
    8000562e:	fffff097          	auipc	ra,0xfffff
    80005632:	86a080e7          	jalr	-1942(ra) # 80003e98 <iunlockput>
    return 0;
    80005636:	4a81                	li	s5,0
    80005638:	bff9                	j	80005616 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000563a:	85da                	mv	a1,s6
    8000563c:	4088                	lw	a0,0(s1)
    8000563e:	ffffe097          	auipc	ra,0xffffe
    80005642:	45c080e7          	jalr	1116(ra) # 80003a9a <ialloc>
    80005646:	8a2a                	mv	s4,a0
    80005648:	c539                	beqz	a0,80005696 <create+0xf6>
  ilock(ip);
    8000564a:	ffffe097          	auipc	ra,0xffffe
    8000564e:	5ec080e7          	jalr	1516(ra) # 80003c36 <ilock>
  ip->major = major;
    80005652:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005656:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000565a:	4905                	li	s2,1
    8000565c:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005660:	8552                	mv	a0,s4
    80005662:	ffffe097          	auipc	ra,0xffffe
    80005666:	50a080e7          	jalr	1290(ra) # 80003b6c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000566a:	000b059b          	sext.w	a1,s6
    8000566e:	03258b63          	beq	a1,s2,800056a4 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    80005672:	004a2603          	lw	a2,4(s4)
    80005676:	fb040593          	addi	a1,s0,-80
    8000567a:	8526                	mv	a0,s1
    8000567c:	fffff097          	auipc	ra,0xfffff
    80005680:	cae080e7          	jalr	-850(ra) # 8000432a <dirlink>
    80005684:	06054f63          	bltz	a0,80005702 <create+0x162>
  iunlockput(dp);
    80005688:	8526                	mv	a0,s1
    8000568a:	fffff097          	auipc	ra,0xfffff
    8000568e:	80e080e7          	jalr	-2034(ra) # 80003e98 <iunlockput>
  return ip;
    80005692:	8ad2                	mv	s5,s4
    80005694:	b749                	j	80005616 <create+0x76>
    iunlockput(dp);
    80005696:	8526                	mv	a0,s1
    80005698:	fffff097          	auipc	ra,0xfffff
    8000569c:	800080e7          	jalr	-2048(ra) # 80003e98 <iunlockput>
    return 0;
    800056a0:	8ad2                	mv	s5,s4
    800056a2:	bf95                	j	80005616 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800056a4:	004a2603          	lw	a2,4(s4)
    800056a8:	00003597          	auipc	a1,0x3
    800056ac:	20058593          	addi	a1,a1,512 # 800088a8 <syscallnum+0x258>
    800056b0:	8552                	mv	a0,s4
    800056b2:	fffff097          	auipc	ra,0xfffff
    800056b6:	c78080e7          	jalr	-904(ra) # 8000432a <dirlink>
    800056ba:	04054463          	bltz	a0,80005702 <create+0x162>
    800056be:	40d0                	lw	a2,4(s1)
    800056c0:	00003597          	auipc	a1,0x3
    800056c4:	1f058593          	addi	a1,a1,496 # 800088b0 <syscallnum+0x260>
    800056c8:	8552                	mv	a0,s4
    800056ca:	fffff097          	auipc	ra,0xfffff
    800056ce:	c60080e7          	jalr	-928(ra) # 8000432a <dirlink>
    800056d2:	02054863          	bltz	a0,80005702 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    800056d6:	004a2603          	lw	a2,4(s4)
    800056da:	fb040593          	addi	a1,s0,-80
    800056de:	8526                	mv	a0,s1
    800056e0:	fffff097          	auipc	ra,0xfffff
    800056e4:	c4a080e7          	jalr	-950(ra) # 8000432a <dirlink>
    800056e8:	00054d63          	bltz	a0,80005702 <create+0x162>
    dp->nlink++;  // for ".."
    800056ec:	04a4d783          	lhu	a5,74(s1)
    800056f0:	2785                	addiw	a5,a5,1
    800056f2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800056f6:	8526                	mv	a0,s1
    800056f8:	ffffe097          	auipc	ra,0xffffe
    800056fc:	474080e7          	jalr	1140(ra) # 80003b6c <iupdate>
    80005700:	b761                	j	80005688 <create+0xe8>
  ip->nlink = 0;
    80005702:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005706:	8552                	mv	a0,s4
    80005708:	ffffe097          	auipc	ra,0xffffe
    8000570c:	464080e7          	jalr	1124(ra) # 80003b6c <iupdate>
  iunlockput(ip);
    80005710:	8552                	mv	a0,s4
    80005712:	ffffe097          	auipc	ra,0xffffe
    80005716:	786080e7          	jalr	1926(ra) # 80003e98 <iunlockput>
  iunlockput(dp);
    8000571a:	8526                	mv	a0,s1
    8000571c:	ffffe097          	auipc	ra,0xffffe
    80005720:	77c080e7          	jalr	1916(ra) # 80003e98 <iunlockput>
  return 0;
    80005724:	bdcd                	j	80005616 <create+0x76>
    return 0;
    80005726:	8aaa                	mv	s5,a0
    80005728:	b5fd                	j	80005616 <create+0x76>

000000008000572a <sys_dup>:
{
    8000572a:	7179                	addi	sp,sp,-48
    8000572c:	f406                	sd	ra,40(sp)
    8000572e:	f022                	sd	s0,32(sp)
    80005730:	ec26                	sd	s1,24(sp)
    80005732:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005734:	fd840613          	addi	a2,s0,-40
    80005738:	4581                	li	a1,0
    8000573a:	4501                	li	a0,0
    8000573c:	00000097          	auipc	ra,0x0
    80005740:	dc2080e7          	jalr	-574(ra) # 800054fe <argfd>
    return -1;
    80005744:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005746:	02054363          	bltz	a0,8000576c <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000574a:	fd843503          	ld	a0,-40(s0)
    8000574e:	00000097          	auipc	ra,0x0
    80005752:	e10080e7          	jalr	-496(ra) # 8000555e <fdalloc>
    80005756:	84aa                	mv	s1,a0
    return -1;
    80005758:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000575a:	00054963          	bltz	a0,8000576c <sys_dup+0x42>
  filedup(f);
    8000575e:	fd843503          	ld	a0,-40(s0)
    80005762:	fffff097          	auipc	ra,0xfffff
    80005766:	310080e7          	jalr	784(ra) # 80004a72 <filedup>
  return fd;
    8000576a:	87a6                	mv	a5,s1
}
    8000576c:	853e                	mv	a0,a5
    8000576e:	70a2                	ld	ra,40(sp)
    80005770:	7402                	ld	s0,32(sp)
    80005772:	64e2                	ld	s1,24(sp)
    80005774:	6145                	addi	sp,sp,48
    80005776:	8082                	ret

0000000080005778 <sys_read>:
{
    80005778:	7179                	addi	sp,sp,-48
    8000577a:	f406                	sd	ra,40(sp)
    8000577c:	f022                	sd	s0,32(sp)
    8000577e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005780:	fd840593          	addi	a1,s0,-40
    80005784:	4505                	li	a0,1
    80005786:	ffffd097          	auipc	ra,0xffffd
    8000578a:	6b4080e7          	jalr	1716(ra) # 80002e3a <argaddr>
  argint(2, &n);
    8000578e:	fe440593          	addi	a1,s0,-28
    80005792:	4509                	li	a0,2
    80005794:	ffffd097          	auipc	ra,0xffffd
    80005798:	684080e7          	jalr	1668(ra) # 80002e18 <argint>
  if(argfd(0, 0, &f) < 0)
    8000579c:	fe840613          	addi	a2,s0,-24
    800057a0:	4581                	li	a1,0
    800057a2:	4501                	li	a0,0
    800057a4:	00000097          	auipc	ra,0x0
    800057a8:	d5a080e7          	jalr	-678(ra) # 800054fe <argfd>
    800057ac:	87aa                	mv	a5,a0
    return -1;
    800057ae:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800057b0:	0007cc63          	bltz	a5,800057c8 <sys_read+0x50>
  return fileread(f, p, n);
    800057b4:	fe442603          	lw	a2,-28(s0)
    800057b8:	fd843583          	ld	a1,-40(s0)
    800057bc:	fe843503          	ld	a0,-24(s0)
    800057c0:	fffff097          	auipc	ra,0xfffff
    800057c4:	43e080e7          	jalr	1086(ra) # 80004bfe <fileread>
}
    800057c8:	70a2                	ld	ra,40(sp)
    800057ca:	7402                	ld	s0,32(sp)
    800057cc:	6145                	addi	sp,sp,48
    800057ce:	8082                	ret

00000000800057d0 <sys_write>:
{
    800057d0:	7179                	addi	sp,sp,-48
    800057d2:	f406                	sd	ra,40(sp)
    800057d4:	f022                	sd	s0,32(sp)
    800057d6:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800057d8:	fd840593          	addi	a1,s0,-40
    800057dc:	4505                	li	a0,1
    800057de:	ffffd097          	auipc	ra,0xffffd
    800057e2:	65c080e7          	jalr	1628(ra) # 80002e3a <argaddr>
  argint(2, &n);
    800057e6:	fe440593          	addi	a1,s0,-28
    800057ea:	4509                	li	a0,2
    800057ec:	ffffd097          	auipc	ra,0xffffd
    800057f0:	62c080e7          	jalr	1580(ra) # 80002e18 <argint>
  if(argfd(0, 0, &f) < 0)
    800057f4:	fe840613          	addi	a2,s0,-24
    800057f8:	4581                	li	a1,0
    800057fa:	4501                	li	a0,0
    800057fc:	00000097          	auipc	ra,0x0
    80005800:	d02080e7          	jalr	-766(ra) # 800054fe <argfd>
    80005804:	87aa                	mv	a5,a0
    return -1;
    80005806:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005808:	0007cc63          	bltz	a5,80005820 <sys_write+0x50>
  return filewrite(f, p, n);
    8000580c:	fe442603          	lw	a2,-28(s0)
    80005810:	fd843583          	ld	a1,-40(s0)
    80005814:	fe843503          	ld	a0,-24(s0)
    80005818:	fffff097          	auipc	ra,0xfffff
    8000581c:	4a8080e7          	jalr	1192(ra) # 80004cc0 <filewrite>
}
    80005820:	70a2                	ld	ra,40(sp)
    80005822:	7402                	ld	s0,32(sp)
    80005824:	6145                	addi	sp,sp,48
    80005826:	8082                	ret

0000000080005828 <sys_close>:
{
    80005828:	1101                	addi	sp,sp,-32
    8000582a:	ec06                	sd	ra,24(sp)
    8000582c:	e822                	sd	s0,16(sp)
    8000582e:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005830:	fe040613          	addi	a2,s0,-32
    80005834:	fec40593          	addi	a1,s0,-20
    80005838:	4501                	li	a0,0
    8000583a:	00000097          	auipc	ra,0x0
    8000583e:	cc4080e7          	jalr	-828(ra) # 800054fe <argfd>
    return -1;
    80005842:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005844:	02054463          	bltz	a0,8000586c <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005848:	ffffc097          	auipc	ra,0xffffc
    8000584c:	164080e7          	jalr	356(ra) # 800019ac <myproc>
    80005850:	fec42783          	lw	a5,-20(s0)
    80005854:	07e9                	addi	a5,a5,26
    80005856:	078e                	slli	a5,a5,0x3
    80005858:	97aa                	add	a5,a5,a0
    8000585a:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    8000585e:	fe043503          	ld	a0,-32(s0)
    80005862:	fffff097          	auipc	ra,0xfffff
    80005866:	262080e7          	jalr	610(ra) # 80004ac4 <fileclose>
  return 0;
    8000586a:	4781                	li	a5,0
}
    8000586c:	853e                	mv	a0,a5
    8000586e:	60e2                	ld	ra,24(sp)
    80005870:	6442                	ld	s0,16(sp)
    80005872:	6105                	addi	sp,sp,32
    80005874:	8082                	ret

0000000080005876 <sys_fstat>:
{
    80005876:	1101                	addi	sp,sp,-32
    80005878:	ec06                	sd	ra,24(sp)
    8000587a:	e822                	sd	s0,16(sp)
    8000587c:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000587e:	fe040593          	addi	a1,s0,-32
    80005882:	4505                	li	a0,1
    80005884:	ffffd097          	auipc	ra,0xffffd
    80005888:	5b6080e7          	jalr	1462(ra) # 80002e3a <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000588c:	fe840613          	addi	a2,s0,-24
    80005890:	4581                	li	a1,0
    80005892:	4501                	li	a0,0
    80005894:	00000097          	auipc	ra,0x0
    80005898:	c6a080e7          	jalr	-918(ra) # 800054fe <argfd>
    8000589c:	87aa                	mv	a5,a0
    return -1;
    8000589e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800058a0:	0007ca63          	bltz	a5,800058b4 <sys_fstat+0x3e>
  return filestat(f, st);
    800058a4:	fe043583          	ld	a1,-32(s0)
    800058a8:	fe843503          	ld	a0,-24(s0)
    800058ac:	fffff097          	auipc	ra,0xfffff
    800058b0:	2e0080e7          	jalr	736(ra) # 80004b8c <filestat>
}
    800058b4:	60e2                	ld	ra,24(sp)
    800058b6:	6442                	ld	s0,16(sp)
    800058b8:	6105                	addi	sp,sp,32
    800058ba:	8082                	ret

00000000800058bc <sys_link>:
{
    800058bc:	7169                	addi	sp,sp,-304
    800058be:	f606                	sd	ra,296(sp)
    800058c0:	f222                	sd	s0,288(sp)
    800058c2:	ee26                	sd	s1,280(sp)
    800058c4:	ea4a                	sd	s2,272(sp)
    800058c6:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058c8:	08000613          	li	a2,128
    800058cc:	ed040593          	addi	a1,s0,-304
    800058d0:	4501                	li	a0,0
    800058d2:	ffffd097          	auipc	ra,0xffffd
    800058d6:	58a080e7          	jalr	1418(ra) # 80002e5c <argstr>
    return -1;
    800058da:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058dc:	10054e63          	bltz	a0,800059f8 <sys_link+0x13c>
    800058e0:	08000613          	li	a2,128
    800058e4:	f5040593          	addi	a1,s0,-176
    800058e8:	4505                	li	a0,1
    800058ea:	ffffd097          	auipc	ra,0xffffd
    800058ee:	572080e7          	jalr	1394(ra) # 80002e5c <argstr>
    return -1;
    800058f2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058f4:	10054263          	bltz	a0,800059f8 <sys_link+0x13c>
  begin_op();
    800058f8:	fffff097          	auipc	ra,0xfffff
    800058fc:	d00080e7          	jalr	-768(ra) # 800045f8 <begin_op>
  if((ip = namei(old)) == 0){
    80005900:	ed040513          	addi	a0,s0,-304
    80005904:	fffff097          	auipc	ra,0xfffff
    80005908:	ad8080e7          	jalr	-1320(ra) # 800043dc <namei>
    8000590c:	84aa                	mv	s1,a0
    8000590e:	c551                	beqz	a0,8000599a <sys_link+0xde>
  ilock(ip);
    80005910:	ffffe097          	auipc	ra,0xffffe
    80005914:	326080e7          	jalr	806(ra) # 80003c36 <ilock>
  if(ip->type == T_DIR){
    80005918:	04449703          	lh	a4,68(s1)
    8000591c:	4785                	li	a5,1
    8000591e:	08f70463          	beq	a4,a5,800059a6 <sys_link+0xea>
  ip->nlink++;
    80005922:	04a4d783          	lhu	a5,74(s1)
    80005926:	2785                	addiw	a5,a5,1
    80005928:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000592c:	8526                	mv	a0,s1
    8000592e:	ffffe097          	auipc	ra,0xffffe
    80005932:	23e080e7          	jalr	574(ra) # 80003b6c <iupdate>
  iunlock(ip);
    80005936:	8526                	mv	a0,s1
    80005938:	ffffe097          	auipc	ra,0xffffe
    8000593c:	3c0080e7          	jalr	960(ra) # 80003cf8 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005940:	fd040593          	addi	a1,s0,-48
    80005944:	f5040513          	addi	a0,s0,-176
    80005948:	fffff097          	auipc	ra,0xfffff
    8000594c:	ab2080e7          	jalr	-1358(ra) # 800043fa <nameiparent>
    80005950:	892a                	mv	s2,a0
    80005952:	c935                	beqz	a0,800059c6 <sys_link+0x10a>
  ilock(dp);
    80005954:	ffffe097          	auipc	ra,0xffffe
    80005958:	2e2080e7          	jalr	738(ra) # 80003c36 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000595c:	00092703          	lw	a4,0(s2)
    80005960:	409c                	lw	a5,0(s1)
    80005962:	04f71d63          	bne	a4,a5,800059bc <sys_link+0x100>
    80005966:	40d0                	lw	a2,4(s1)
    80005968:	fd040593          	addi	a1,s0,-48
    8000596c:	854a                	mv	a0,s2
    8000596e:	fffff097          	auipc	ra,0xfffff
    80005972:	9bc080e7          	jalr	-1604(ra) # 8000432a <dirlink>
    80005976:	04054363          	bltz	a0,800059bc <sys_link+0x100>
  iunlockput(dp);
    8000597a:	854a                	mv	a0,s2
    8000597c:	ffffe097          	auipc	ra,0xffffe
    80005980:	51c080e7          	jalr	1308(ra) # 80003e98 <iunlockput>
  iput(ip);
    80005984:	8526                	mv	a0,s1
    80005986:	ffffe097          	auipc	ra,0xffffe
    8000598a:	46a080e7          	jalr	1130(ra) # 80003df0 <iput>
  end_op();
    8000598e:	fffff097          	auipc	ra,0xfffff
    80005992:	cea080e7          	jalr	-790(ra) # 80004678 <end_op>
  return 0;
    80005996:	4781                	li	a5,0
    80005998:	a085                	j	800059f8 <sys_link+0x13c>
    end_op();
    8000599a:	fffff097          	auipc	ra,0xfffff
    8000599e:	cde080e7          	jalr	-802(ra) # 80004678 <end_op>
    return -1;
    800059a2:	57fd                	li	a5,-1
    800059a4:	a891                	j	800059f8 <sys_link+0x13c>
    iunlockput(ip);
    800059a6:	8526                	mv	a0,s1
    800059a8:	ffffe097          	auipc	ra,0xffffe
    800059ac:	4f0080e7          	jalr	1264(ra) # 80003e98 <iunlockput>
    end_op();
    800059b0:	fffff097          	auipc	ra,0xfffff
    800059b4:	cc8080e7          	jalr	-824(ra) # 80004678 <end_op>
    return -1;
    800059b8:	57fd                	li	a5,-1
    800059ba:	a83d                	j	800059f8 <sys_link+0x13c>
    iunlockput(dp);
    800059bc:	854a                	mv	a0,s2
    800059be:	ffffe097          	auipc	ra,0xffffe
    800059c2:	4da080e7          	jalr	1242(ra) # 80003e98 <iunlockput>
  ilock(ip);
    800059c6:	8526                	mv	a0,s1
    800059c8:	ffffe097          	auipc	ra,0xffffe
    800059cc:	26e080e7          	jalr	622(ra) # 80003c36 <ilock>
  ip->nlink--;
    800059d0:	04a4d783          	lhu	a5,74(s1)
    800059d4:	37fd                	addiw	a5,a5,-1
    800059d6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800059da:	8526                	mv	a0,s1
    800059dc:	ffffe097          	auipc	ra,0xffffe
    800059e0:	190080e7          	jalr	400(ra) # 80003b6c <iupdate>
  iunlockput(ip);
    800059e4:	8526                	mv	a0,s1
    800059e6:	ffffe097          	auipc	ra,0xffffe
    800059ea:	4b2080e7          	jalr	1202(ra) # 80003e98 <iunlockput>
  end_op();
    800059ee:	fffff097          	auipc	ra,0xfffff
    800059f2:	c8a080e7          	jalr	-886(ra) # 80004678 <end_op>
  return -1;
    800059f6:	57fd                	li	a5,-1
}
    800059f8:	853e                	mv	a0,a5
    800059fa:	70b2                	ld	ra,296(sp)
    800059fc:	7412                	ld	s0,288(sp)
    800059fe:	64f2                	ld	s1,280(sp)
    80005a00:	6952                	ld	s2,272(sp)
    80005a02:	6155                	addi	sp,sp,304
    80005a04:	8082                	ret

0000000080005a06 <sys_unlink>:
{
    80005a06:	7151                	addi	sp,sp,-240
    80005a08:	f586                	sd	ra,232(sp)
    80005a0a:	f1a2                	sd	s0,224(sp)
    80005a0c:	eda6                	sd	s1,216(sp)
    80005a0e:	e9ca                	sd	s2,208(sp)
    80005a10:	e5ce                	sd	s3,200(sp)
    80005a12:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005a14:	08000613          	li	a2,128
    80005a18:	f3040593          	addi	a1,s0,-208
    80005a1c:	4501                	li	a0,0
    80005a1e:	ffffd097          	auipc	ra,0xffffd
    80005a22:	43e080e7          	jalr	1086(ra) # 80002e5c <argstr>
    80005a26:	18054163          	bltz	a0,80005ba8 <sys_unlink+0x1a2>
  begin_op();
    80005a2a:	fffff097          	auipc	ra,0xfffff
    80005a2e:	bce080e7          	jalr	-1074(ra) # 800045f8 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005a32:	fb040593          	addi	a1,s0,-80
    80005a36:	f3040513          	addi	a0,s0,-208
    80005a3a:	fffff097          	auipc	ra,0xfffff
    80005a3e:	9c0080e7          	jalr	-1600(ra) # 800043fa <nameiparent>
    80005a42:	84aa                	mv	s1,a0
    80005a44:	c979                	beqz	a0,80005b1a <sys_unlink+0x114>
  ilock(dp);
    80005a46:	ffffe097          	auipc	ra,0xffffe
    80005a4a:	1f0080e7          	jalr	496(ra) # 80003c36 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005a4e:	00003597          	auipc	a1,0x3
    80005a52:	e5a58593          	addi	a1,a1,-422 # 800088a8 <syscallnum+0x258>
    80005a56:	fb040513          	addi	a0,s0,-80
    80005a5a:	ffffe097          	auipc	ra,0xffffe
    80005a5e:	6a6080e7          	jalr	1702(ra) # 80004100 <namecmp>
    80005a62:	14050a63          	beqz	a0,80005bb6 <sys_unlink+0x1b0>
    80005a66:	00003597          	auipc	a1,0x3
    80005a6a:	e4a58593          	addi	a1,a1,-438 # 800088b0 <syscallnum+0x260>
    80005a6e:	fb040513          	addi	a0,s0,-80
    80005a72:	ffffe097          	auipc	ra,0xffffe
    80005a76:	68e080e7          	jalr	1678(ra) # 80004100 <namecmp>
    80005a7a:	12050e63          	beqz	a0,80005bb6 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005a7e:	f2c40613          	addi	a2,s0,-212
    80005a82:	fb040593          	addi	a1,s0,-80
    80005a86:	8526                	mv	a0,s1
    80005a88:	ffffe097          	auipc	ra,0xffffe
    80005a8c:	692080e7          	jalr	1682(ra) # 8000411a <dirlookup>
    80005a90:	892a                	mv	s2,a0
    80005a92:	12050263          	beqz	a0,80005bb6 <sys_unlink+0x1b0>
  ilock(ip);
    80005a96:	ffffe097          	auipc	ra,0xffffe
    80005a9a:	1a0080e7          	jalr	416(ra) # 80003c36 <ilock>
  if(ip->nlink < 1)
    80005a9e:	04a91783          	lh	a5,74(s2)
    80005aa2:	08f05263          	blez	a5,80005b26 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005aa6:	04491703          	lh	a4,68(s2)
    80005aaa:	4785                	li	a5,1
    80005aac:	08f70563          	beq	a4,a5,80005b36 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005ab0:	4641                	li	a2,16
    80005ab2:	4581                	li	a1,0
    80005ab4:	fc040513          	addi	a0,s0,-64
    80005ab8:	ffffb097          	auipc	ra,0xffffb
    80005abc:	21a080e7          	jalr	538(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005ac0:	4741                	li	a4,16
    80005ac2:	f2c42683          	lw	a3,-212(s0)
    80005ac6:	fc040613          	addi	a2,s0,-64
    80005aca:	4581                	li	a1,0
    80005acc:	8526                	mv	a0,s1
    80005ace:	ffffe097          	auipc	ra,0xffffe
    80005ad2:	514080e7          	jalr	1300(ra) # 80003fe2 <writei>
    80005ad6:	47c1                	li	a5,16
    80005ad8:	0af51563          	bne	a0,a5,80005b82 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005adc:	04491703          	lh	a4,68(s2)
    80005ae0:	4785                	li	a5,1
    80005ae2:	0af70863          	beq	a4,a5,80005b92 <sys_unlink+0x18c>
  iunlockput(dp);
    80005ae6:	8526                	mv	a0,s1
    80005ae8:	ffffe097          	auipc	ra,0xffffe
    80005aec:	3b0080e7          	jalr	944(ra) # 80003e98 <iunlockput>
  ip->nlink--;
    80005af0:	04a95783          	lhu	a5,74(s2)
    80005af4:	37fd                	addiw	a5,a5,-1
    80005af6:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005afa:	854a                	mv	a0,s2
    80005afc:	ffffe097          	auipc	ra,0xffffe
    80005b00:	070080e7          	jalr	112(ra) # 80003b6c <iupdate>
  iunlockput(ip);
    80005b04:	854a                	mv	a0,s2
    80005b06:	ffffe097          	auipc	ra,0xffffe
    80005b0a:	392080e7          	jalr	914(ra) # 80003e98 <iunlockput>
  end_op();
    80005b0e:	fffff097          	auipc	ra,0xfffff
    80005b12:	b6a080e7          	jalr	-1174(ra) # 80004678 <end_op>
  return 0;
    80005b16:	4501                	li	a0,0
    80005b18:	a84d                	j	80005bca <sys_unlink+0x1c4>
    end_op();
    80005b1a:	fffff097          	auipc	ra,0xfffff
    80005b1e:	b5e080e7          	jalr	-1186(ra) # 80004678 <end_op>
    return -1;
    80005b22:	557d                	li	a0,-1
    80005b24:	a05d                	j	80005bca <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005b26:	00003517          	auipc	a0,0x3
    80005b2a:	d9250513          	addi	a0,a0,-622 # 800088b8 <syscallnum+0x268>
    80005b2e:	ffffb097          	auipc	ra,0xffffb
    80005b32:	a10080e7          	jalr	-1520(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b36:	04c92703          	lw	a4,76(s2)
    80005b3a:	02000793          	li	a5,32
    80005b3e:	f6e7f9e3          	bgeu	a5,a4,80005ab0 <sys_unlink+0xaa>
    80005b42:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b46:	4741                	li	a4,16
    80005b48:	86ce                	mv	a3,s3
    80005b4a:	f1840613          	addi	a2,s0,-232
    80005b4e:	4581                	li	a1,0
    80005b50:	854a                	mv	a0,s2
    80005b52:	ffffe097          	auipc	ra,0xffffe
    80005b56:	398080e7          	jalr	920(ra) # 80003eea <readi>
    80005b5a:	47c1                	li	a5,16
    80005b5c:	00f51b63          	bne	a0,a5,80005b72 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005b60:	f1845783          	lhu	a5,-232(s0)
    80005b64:	e7a1                	bnez	a5,80005bac <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b66:	29c1                	addiw	s3,s3,16
    80005b68:	04c92783          	lw	a5,76(s2)
    80005b6c:	fcf9ede3          	bltu	s3,a5,80005b46 <sys_unlink+0x140>
    80005b70:	b781                	j	80005ab0 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005b72:	00003517          	auipc	a0,0x3
    80005b76:	d5e50513          	addi	a0,a0,-674 # 800088d0 <syscallnum+0x280>
    80005b7a:	ffffb097          	auipc	ra,0xffffb
    80005b7e:	9c4080e7          	jalr	-1596(ra) # 8000053e <panic>
    panic("unlink: writei");
    80005b82:	00003517          	auipc	a0,0x3
    80005b86:	d6650513          	addi	a0,a0,-666 # 800088e8 <syscallnum+0x298>
    80005b8a:	ffffb097          	auipc	ra,0xffffb
    80005b8e:	9b4080e7          	jalr	-1612(ra) # 8000053e <panic>
    dp->nlink--;
    80005b92:	04a4d783          	lhu	a5,74(s1)
    80005b96:	37fd                	addiw	a5,a5,-1
    80005b98:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005b9c:	8526                	mv	a0,s1
    80005b9e:	ffffe097          	auipc	ra,0xffffe
    80005ba2:	fce080e7          	jalr	-50(ra) # 80003b6c <iupdate>
    80005ba6:	b781                	j	80005ae6 <sys_unlink+0xe0>
    return -1;
    80005ba8:	557d                	li	a0,-1
    80005baa:	a005                	j	80005bca <sys_unlink+0x1c4>
    iunlockput(ip);
    80005bac:	854a                	mv	a0,s2
    80005bae:	ffffe097          	auipc	ra,0xffffe
    80005bb2:	2ea080e7          	jalr	746(ra) # 80003e98 <iunlockput>
  iunlockput(dp);
    80005bb6:	8526                	mv	a0,s1
    80005bb8:	ffffe097          	auipc	ra,0xffffe
    80005bbc:	2e0080e7          	jalr	736(ra) # 80003e98 <iunlockput>
  end_op();
    80005bc0:	fffff097          	auipc	ra,0xfffff
    80005bc4:	ab8080e7          	jalr	-1352(ra) # 80004678 <end_op>
  return -1;
    80005bc8:	557d                	li	a0,-1
}
    80005bca:	70ae                	ld	ra,232(sp)
    80005bcc:	740e                	ld	s0,224(sp)
    80005bce:	64ee                	ld	s1,216(sp)
    80005bd0:	694e                	ld	s2,208(sp)
    80005bd2:	69ae                	ld	s3,200(sp)
    80005bd4:	616d                	addi	sp,sp,240
    80005bd6:	8082                	ret

0000000080005bd8 <sys_open>:

uint64
sys_open(void)
{
    80005bd8:	7131                	addi	sp,sp,-192
    80005bda:	fd06                	sd	ra,184(sp)
    80005bdc:	f922                	sd	s0,176(sp)
    80005bde:	f526                	sd	s1,168(sp)
    80005be0:	f14a                	sd	s2,160(sp)
    80005be2:	ed4e                	sd	s3,152(sp)
    80005be4:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005be6:	f4c40593          	addi	a1,s0,-180
    80005bea:	4505                	li	a0,1
    80005bec:	ffffd097          	auipc	ra,0xffffd
    80005bf0:	22c080e7          	jalr	556(ra) # 80002e18 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005bf4:	08000613          	li	a2,128
    80005bf8:	f5040593          	addi	a1,s0,-176
    80005bfc:	4501                	li	a0,0
    80005bfe:	ffffd097          	auipc	ra,0xffffd
    80005c02:	25e080e7          	jalr	606(ra) # 80002e5c <argstr>
    80005c06:	87aa                	mv	a5,a0
    return -1;
    80005c08:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005c0a:	0a07c963          	bltz	a5,80005cbc <sys_open+0xe4>

  begin_op();
    80005c0e:	fffff097          	auipc	ra,0xfffff
    80005c12:	9ea080e7          	jalr	-1558(ra) # 800045f8 <begin_op>

  if(omode & O_CREATE){
    80005c16:	f4c42783          	lw	a5,-180(s0)
    80005c1a:	2007f793          	andi	a5,a5,512
    80005c1e:	cfc5                	beqz	a5,80005cd6 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005c20:	4681                	li	a3,0
    80005c22:	4601                	li	a2,0
    80005c24:	4589                	li	a1,2
    80005c26:	f5040513          	addi	a0,s0,-176
    80005c2a:	00000097          	auipc	ra,0x0
    80005c2e:	976080e7          	jalr	-1674(ra) # 800055a0 <create>
    80005c32:	84aa                	mv	s1,a0
    if(ip == 0){
    80005c34:	c959                	beqz	a0,80005cca <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005c36:	04449703          	lh	a4,68(s1)
    80005c3a:	478d                	li	a5,3
    80005c3c:	00f71763          	bne	a4,a5,80005c4a <sys_open+0x72>
    80005c40:	0464d703          	lhu	a4,70(s1)
    80005c44:	47a5                	li	a5,9
    80005c46:	0ce7ed63          	bltu	a5,a4,80005d20 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005c4a:	fffff097          	auipc	ra,0xfffff
    80005c4e:	dbe080e7          	jalr	-578(ra) # 80004a08 <filealloc>
    80005c52:	89aa                	mv	s3,a0
    80005c54:	10050363          	beqz	a0,80005d5a <sys_open+0x182>
    80005c58:	00000097          	auipc	ra,0x0
    80005c5c:	906080e7          	jalr	-1786(ra) # 8000555e <fdalloc>
    80005c60:	892a                	mv	s2,a0
    80005c62:	0e054763          	bltz	a0,80005d50 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005c66:	04449703          	lh	a4,68(s1)
    80005c6a:	478d                	li	a5,3
    80005c6c:	0cf70563          	beq	a4,a5,80005d36 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005c70:	4789                	li	a5,2
    80005c72:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005c76:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005c7a:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005c7e:	f4c42783          	lw	a5,-180(s0)
    80005c82:	0017c713          	xori	a4,a5,1
    80005c86:	8b05                	andi	a4,a4,1
    80005c88:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005c8c:	0037f713          	andi	a4,a5,3
    80005c90:	00e03733          	snez	a4,a4
    80005c94:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005c98:	4007f793          	andi	a5,a5,1024
    80005c9c:	c791                	beqz	a5,80005ca8 <sys_open+0xd0>
    80005c9e:	04449703          	lh	a4,68(s1)
    80005ca2:	4789                	li	a5,2
    80005ca4:	0af70063          	beq	a4,a5,80005d44 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005ca8:	8526                	mv	a0,s1
    80005caa:	ffffe097          	auipc	ra,0xffffe
    80005cae:	04e080e7          	jalr	78(ra) # 80003cf8 <iunlock>
  end_op();
    80005cb2:	fffff097          	auipc	ra,0xfffff
    80005cb6:	9c6080e7          	jalr	-1594(ra) # 80004678 <end_op>

  return fd;
    80005cba:	854a                	mv	a0,s2
}
    80005cbc:	70ea                	ld	ra,184(sp)
    80005cbe:	744a                	ld	s0,176(sp)
    80005cc0:	74aa                	ld	s1,168(sp)
    80005cc2:	790a                	ld	s2,160(sp)
    80005cc4:	69ea                	ld	s3,152(sp)
    80005cc6:	6129                	addi	sp,sp,192
    80005cc8:	8082                	ret
      end_op();
    80005cca:	fffff097          	auipc	ra,0xfffff
    80005cce:	9ae080e7          	jalr	-1618(ra) # 80004678 <end_op>
      return -1;
    80005cd2:	557d                	li	a0,-1
    80005cd4:	b7e5                	j	80005cbc <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005cd6:	f5040513          	addi	a0,s0,-176
    80005cda:	ffffe097          	auipc	ra,0xffffe
    80005cde:	702080e7          	jalr	1794(ra) # 800043dc <namei>
    80005ce2:	84aa                	mv	s1,a0
    80005ce4:	c905                	beqz	a0,80005d14 <sys_open+0x13c>
    ilock(ip);
    80005ce6:	ffffe097          	auipc	ra,0xffffe
    80005cea:	f50080e7          	jalr	-176(ra) # 80003c36 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005cee:	04449703          	lh	a4,68(s1)
    80005cf2:	4785                	li	a5,1
    80005cf4:	f4f711e3          	bne	a4,a5,80005c36 <sys_open+0x5e>
    80005cf8:	f4c42783          	lw	a5,-180(s0)
    80005cfc:	d7b9                	beqz	a5,80005c4a <sys_open+0x72>
      iunlockput(ip);
    80005cfe:	8526                	mv	a0,s1
    80005d00:	ffffe097          	auipc	ra,0xffffe
    80005d04:	198080e7          	jalr	408(ra) # 80003e98 <iunlockput>
      end_op();
    80005d08:	fffff097          	auipc	ra,0xfffff
    80005d0c:	970080e7          	jalr	-1680(ra) # 80004678 <end_op>
      return -1;
    80005d10:	557d                	li	a0,-1
    80005d12:	b76d                	j	80005cbc <sys_open+0xe4>
      end_op();
    80005d14:	fffff097          	auipc	ra,0xfffff
    80005d18:	964080e7          	jalr	-1692(ra) # 80004678 <end_op>
      return -1;
    80005d1c:	557d                	li	a0,-1
    80005d1e:	bf79                	j	80005cbc <sys_open+0xe4>
    iunlockput(ip);
    80005d20:	8526                	mv	a0,s1
    80005d22:	ffffe097          	auipc	ra,0xffffe
    80005d26:	176080e7          	jalr	374(ra) # 80003e98 <iunlockput>
    end_op();
    80005d2a:	fffff097          	auipc	ra,0xfffff
    80005d2e:	94e080e7          	jalr	-1714(ra) # 80004678 <end_op>
    return -1;
    80005d32:	557d                	li	a0,-1
    80005d34:	b761                	j	80005cbc <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005d36:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005d3a:	04649783          	lh	a5,70(s1)
    80005d3e:	02f99223          	sh	a5,36(s3)
    80005d42:	bf25                	j	80005c7a <sys_open+0xa2>
    itrunc(ip);
    80005d44:	8526                	mv	a0,s1
    80005d46:	ffffe097          	auipc	ra,0xffffe
    80005d4a:	ffe080e7          	jalr	-2(ra) # 80003d44 <itrunc>
    80005d4e:	bfa9                	j	80005ca8 <sys_open+0xd0>
      fileclose(f);
    80005d50:	854e                	mv	a0,s3
    80005d52:	fffff097          	auipc	ra,0xfffff
    80005d56:	d72080e7          	jalr	-654(ra) # 80004ac4 <fileclose>
    iunlockput(ip);
    80005d5a:	8526                	mv	a0,s1
    80005d5c:	ffffe097          	auipc	ra,0xffffe
    80005d60:	13c080e7          	jalr	316(ra) # 80003e98 <iunlockput>
    end_op();
    80005d64:	fffff097          	auipc	ra,0xfffff
    80005d68:	914080e7          	jalr	-1772(ra) # 80004678 <end_op>
    return -1;
    80005d6c:	557d                	li	a0,-1
    80005d6e:	b7b9                	j	80005cbc <sys_open+0xe4>

0000000080005d70 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005d70:	7175                	addi	sp,sp,-144
    80005d72:	e506                	sd	ra,136(sp)
    80005d74:	e122                	sd	s0,128(sp)
    80005d76:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005d78:	fffff097          	auipc	ra,0xfffff
    80005d7c:	880080e7          	jalr	-1920(ra) # 800045f8 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005d80:	08000613          	li	a2,128
    80005d84:	f7040593          	addi	a1,s0,-144
    80005d88:	4501                	li	a0,0
    80005d8a:	ffffd097          	auipc	ra,0xffffd
    80005d8e:	0d2080e7          	jalr	210(ra) # 80002e5c <argstr>
    80005d92:	02054963          	bltz	a0,80005dc4 <sys_mkdir+0x54>
    80005d96:	4681                	li	a3,0
    80005d98:	4601                	li	a2,0
    80005d9a:	4585                	li	a1,1
    80005d9c:	f7040513          	addi	a0,s0,-144
    80005da0:	00000097          	auipc	ra,0x0
    80005da4:	800080e7          	jalr	-2048(ra) # 800055a0 <create>
    80005da8:	cd11                	beqz	a0,80005dc4 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005daa:	ffffe097          	auipc	ra,0xffffe
    80005dae:	0ee080e7          	jalr	238(ra) # 80003e98 <iunlockput>
  end_op();
    80005db2:	fffff097          	auipc	ra,0xfffff
    80005db6:	8c6080e7          	jalr	-1850(ra) # 80004678 <end_op>
  return 0;
    80005dba:	4501                	li	a0,0
}
    80005dbc:	60aa                	ld	ra,136(sp)
    80005dbe:	640a                	ld	s0,128(sp)
    80005dc0:	6149                	addi	sp,sp,144
    80005dc2:	8082                	ret
    end_op();
    80005dc4:	fffff097          	auipc	ra,0xfffff
    80005dc8:	8b4080e7          	jalr	-1868(ra) # 80004678 <end_op>
    return -1;
    80005dcc:	557d                	li	a0,-1
    80005dce:	b7fd                	j	80005dbc <sys_mkdir+0x4c>

0000000080005dd0 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005dd0:	7135                	addi	sp,sp,-160
    80005dd2:	ed06                	sd	ra,152(sp)
    80005dd4:	e922                	sd	s0,144(sp)
    80005dd6:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005dd8:	fffff097          	auipc	ra,0xfffff
    80005ddc:	820080e7          	jalr	-2016(ra) # 800045f8 <begin_op>
  argint(1, &major);
    80005de0:	f6c40593          	addi	a1,s0,-148
    80005de4:	4505                	li	a0,1
    80005de6:	ffffd097          	auipc	ra,0xffffd
    80005dea:	032080e7          	jalr	50(ra) # 80002e18 <argint>
  argint(2, &minor);
    80005dee:	f6840593          	addi	a1,s0,-152
    80005df2:	4509                	li	a0,2
    80005df4:	ffffd097          	auipc	ra,0xffffd
    80005df8:	024080e7          	jalr	36(ra) # 80002e18 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005dfc:	08000613          	li	a2,128
    80005e00:	f7040593          	addi	a1,s0,-144
    80005e04:	4501                	li	a0,0
    80005e06:	ffffd097          	auipc	ra,0xffffd
    80005e0a:	056080e7          	jalr	86(ra) # 80002e5c <argstr>
    80005e0e:	02054b63          	bltz	a0,80005e44 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005e12:	f6841683          	lh	a3,-152(s0)
    80005e16:	f6c41603          	lh	a2,-148(s0)
    80005e1a:	458d                	li	a1,3
    80005e1c:	f7040513          	addi	a0,s0,-144
    80005e20:	fffff097          	auipc	ra,0xfffff
    80005e24:	780080e7          	jalr	1920(ra) # 800055a0 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e28:	cd11                	beqz	a0,80005e44 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005e2a:	ffffe097          	auipc	ra,0xffffe
    80005e2e:	06e080e7          	jalr	110(ra) # 80003e98 <iunlockput>
  end_op();
    80005e32:	fffff097          	auipc	ra,0xfffff
    80005e36:	846080e7          	jalr	-1978(ra) # 80004678 <end_op>
  return 0;
    80005e3a:	4501                	li	a0,0
}
    80005e3c:	60ea                	ld	ra,152(sp)
    80005e3e:	644a                	ld	s0,144(sp)
    80005e40:	610d                	addi	sp,sp,160
    80005e42:	8082                	ret
    end_op();
    80005e44:	fffff097          	auipc	ra,0xfffff
    80005e48:	834080e7          	jalr	-1996(ra) # 80004678 <end_op>
    return -1;
    80005e4c:	557d                	li	a0,-1
    80005e4e:	b7fd                	j	80005e3c <sys_mknod+0x6c>

0000000080005e50 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005e50:	7135                	addi	sp,sp,-160
    80005e52:	ed06                	sd	ra,152(sp)
    80005e54:	e922                	sd	s0,144(sp)
    80005e56:	e526                	sd	s1,136(sp)
    80005e58:	e14a                	sd	s2,128(sp)
    80005e5a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005e5c:	ffffc097          	auipc	ra,0xffffc
    80005e60:	b50080e7          	jalr	-1200(ra) # 800019ac <myproc>
    80005e64:	892a                	mv	s2,a0
  
  begin_op();
    80005e66:	ffffe097          	auipc	ra,0xffffe
    80005e6a:	792080e7          	jalr	1938(ra) # 800045f8 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005e6e:	08000613          	li	a2,128
    80005e72:	f6040593          	addi	a1,s0,-160
    80005e76:	4501                	li	a0,0
    80005e78:	ffffd097          	auipc	ra,0xffffd
    80005e7c:	fe4080e7          	jalr	-28(ra) # 80002e5c <argstr>
    80005e80:	04054b63          	bltz	a0,80005ed6 <sys_chdir+0x86>
    80005e84:	f6040513          	addi	a0,s0,-160
    80005e88:	ffffe097          	auipc	ra,0xffffe
    80005e8c:	554080e7          	jalr	1364(ra) # 800043dc <namei>
    80005e90:	84aa                	mv	s1,a0
    80005e92:	c131                	beqz	a0,80005ed6 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005e94:	ffffe097          	auipc	ra,0xffffe
    80005e98:	da2080e7          	jalr	-606(ra) # 80003c36 <ilock>
  if(ip->type != T_DIR){
    80005e9c:	04449703          	lh	a4,68(s1)
    80005ea0:	4785                	li	a5,1
    80005ea2:	04f71063          	bne	a4,a5,80005ee2 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005ea6:	8526                	mv	a0,s1
    80005ea8:	ffffe097          	auipc	ra,0xffffe
    80005eac:	e50080e7          	jalr	-432(ra) # 80003cf8 <iunlock>
  iput(p->cwd);
    80005eb0:	15093503          	ld	a0,336(s2)
    80005eb4:	ffffe097          	auipc	ra,0xffffe
    80005eb8:	f3c080e7          	jalr	-196(ra) # 80003df0 <iput>
  end_op();
    80005ebc:	ffffe097          	auipc	ra,0xffffe
    80005ec0:	7bc080e7          	jalr	1980(ra) # 80004678 <end_op>
  p->cwd = ip;
    80005ec4:	14993823          	sd	s1,336(s2)
  return 0;
    80005ec8:	4501                	li	a0,0
}
    80005eca:	60ea                	ld	ra,152(sp)
    80005ecc:	644a                	ld	s0,144(sp)
    80005ece:	64aa                	ld	s1,136(sp)
    80005ed0:	690a                	ld	s2,128(sp)
    80005ed2:	610d                	addi	sp,sp,160
    80005ed4:	8082                	ret
    end_op();
    80005ed6:	ffffe097          	auipc	ra,0xffffe
    80005eda:	7a2080e7          	jalr	1954(ra) # 80004678 <end_op>
    return -1;
    80005ede:	557d                	li	a0,-1
    80005ee0:	b7ed                	j	80005eca <sys_chdir+0x7a>
    iunlockput(ip);
    80005ee2:	8526                	mv	a0,s1
    80005ee4:	ffffe097          	auipc	ra,0xffffe
    80005ee8:	fb4080e7          	jalr	-76(ra) # 80003e98 <iunlockput>
    end_op();
    80005eec:	ffffe097          	auipc	ra,0xffffe
    80005ef0:	78c080e7          	jalr	1932(ra) # 80004678 <end_op>
    return -1;
    80005ef4:	557d                	li	a0,-1
    80005ef6:	bfd1                	j	80005eca <sys_chdir+0x7a>

0000000080005ef8 <sys_exec>:

uint64
sys_exec(void)
{
    80005ef8:	7145                	addi	sp,sp,-464
    80005efa:	e786                	sd	ra,456(sp)
    80005efc:	e3a2                	sd	s0,448(sp)
    80005efe:	ff26                	sd	s1,440(sp)
    80005f00:	fb4a                	sd	s2,432(sp)
    80005f02:	f74e                	sd	s3,424(sp)
    80005f04:	f352                	sd	s4,416(sp)
    80005f06:	ef56                	sd	s5,408(sp)
    80005f08:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005f0a:	e3840593          	addi	a1,s0,-456
    80005f0e:	4505                	li	a0,1
    80005f10:	ffffd097          	auipc	ra,0xffffd
    80005f14:	f2a080e7          	jalr	-214(ra) # 80002e3a <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005f18:	08000613          	li	a2,128
    80005f1c:	f4040593          	addi	a1,s0,-192
    80005f20:	4501                	li	a0,0
    80005f22:	ffffd097          	auipc	ra,0xffffd
    80005f26:	f3a080e7          	jalr	-198(ra) # 80002e5c <argstr>
    80005f2a:	87aa                	mv	a5,a0
    return -1;
    80005f2c:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005f2e:	0c07c263          	bltz	a5,80005ff2 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005f32:	10000613          	li	a2,256
    80005f36:	4581                	li	a1,0
    80005f38:	e4040513          	addi	a0,s0,-448
    80005f3c:	ffffb097          	auipc	ra,0xffffb
    80005f40:	d96080e7          	jalr	-618(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005f44:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005f48:	89a6                	mv	s3,s1
    80005f4a:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005f4c:	02000a13          	li	s4,32
    80005f50:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005f54:	00391793          	slli	a5,s2,0x3
    80005f58:	e3040593          	addi	a1,s0,-464
    80005f5c:	e3843503          	ld	a0,-456(s0)
    80005f60:	953e                	add	a0,a0,a5
    80005f62:	ffffd097          	auipc	ra,0xffffd
    80005f66:	e18080e7          	jalr	-488(ra) # 80002d7a <fetchaddr>
    80005f6a:	02054a63          	bltz	a0,80005f9e <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005f6e:	e3043783          	ld	a5,-464(s0)
    80005f72:	c3b9                	beqz	a5,80005fb8 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005f74:	ffffb097          	auipc	ra,0xffffb
    80005f78:	b72080e7          	jalr	-1166(ra) # 80000ae6 <kalloc>
    80005f7c:	85aa                	mv	a1,a0
    80005f7e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005f82:	cd11                	beqz	a0,80005f9e <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005f84:	6605                	lui	a2,0x1
    80005f86:	e3043503          	ld	a0,-464(s0)
    80005f8a:	ffffd097          	auipc	ra,0xffffd
    80005f8e:	e42080e7          	jalr	-446(ra) # 80002dcc <fetchstr>
    80005f92:	00054663          	bltz	a0,80005f9e <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005f96:	0905                	addi	s2,s2,1
    80005f98:	09a1                	addi	s3,s3,8
    80005f9a:	fb491be3          	bne	s2,s4,80005f50 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f9e:	10048913          	addi	s2,s1,256
    80005fa2:	6088                	ld	a0,0(s1)
    80005fa4:	c531                	beqz	a0,80005ff0 <sys_exec+0xf8>
    kfree(argv[i]);
    80005fa6:	ffffb097          	auipc	ra,0xffffb
    80005faa:	a44080e7          	jalr	-1468(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fae:	04a1                	addi	s1,s1,8
    80005fb0:	ff2499e3          	bne	s1,s2,80005fa2 <sys_exec+0xaa>
  return -1;
    80005fb4:	557d                	li	a0,-1
    80005fb6:	a835                	j	80005ff2 <sys_exec+0xfa>
      argv[i] = 0;
    80005fb8:	0a8e                	slli	s5,s5,0x3
    80005fba:	fc040793          	addi	a5,s0,-64
    80005fbe:	9abe                	add	s5,s5,a5
    80005fc0:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005fc4:	e4040593          	addi	a1,s0,-448
    80005fc8:	f4040513          	addi	a0,s0,-192
    80005fcc:	fffff097          	auipc	ra,0xfffff
    80005fd0:	172080e7          	jalr	370(ra) # 8000513e <exec>
    80005fd4:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fd6:	10048993          	addi	s3,s1,256
    80005fda:	6088                	ld	a0,0(s1)
    80005fdc:	c901                	beqz	a0,80005fec <sys_exec+0xf4>
    kfree(argv[i]);
    80005fde:	ffffb097          	auipc	ra,0xffffb
    80005fe2:	a0c080e7          	jalr	-1524(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fe6:	04a1                	addi	s1,s1,8
    80005fe8:	ff3499e3          	bne	s1,s3,80005fda <sys_exec+0xe2>
  return ret;
    80005fec:	854a                	mv	a0,s2
    80005fee:	a011                	j	80005ff2 <sys_exec+0xfa>
  return -1;
    80005ff0:	557d                	li	a0,-1
}
    80005ff2:	60be                	ld	ra,456(sp)
    80005ff4:	641e                	ld	s0,448(sp)
    80005ff6:	74fa                	ld	s1,440(sp)
    80005ff8:	795a                	ld	s2,432(sp)
    80005ffa:	79ba                	ld	s3,424(sp)
    80005ffc:	7a1a                	ld	s4,416(sp)
    80005ffe:	6afa                	ld	s5,408(sp)
    80006000:	6179                	addi	sp,sp,464
    80006002:	8082                	ret

0000000080006004 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006004:	7139                	addi	sp,sp,-64
    80006006:	fc06                	sd	ra,56(sp)
    80006008:	f822                	sd	s0,48(sp)
    8000600a:	f426                	sd	s1,40(sp)
    8000600c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000600e:	ffffc097          	auipc	ra,0xffffc
    80006012:	99e080e7          	jalr	-1634(ra) # 800019ac <myproc>
    80006016:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80006018:	fd840593          	addi	a1,s0,-40
    8000601c:	4501                	li	a0,0
    8000601e:	ffffd097          	auipc	ra,0xffffd
    80006022:	e1c080e7          	jalr	-484(ra) # 80002e3a <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80006026:	fc840593          	addi	a1,s0,-56
    8000602a:	fd040513          	addi	a0,s0,-48
    8000602e:	fffff097          	auipc	ra,0xfffff
    80006032:	dc6080e7          	jalr	-570(ra) # 80004df4 <pipealloc>
    return -1;
    80006036:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006038:	0c054463          	bltz	a0,80006100 <sys_pipe+0xfc>
  fd0 = -1;
    8000603c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006040:	fd043503          	ld	a0,-48(s0)
    80006044:	fffff097          	auipc	ra,0xfffff
    80006048:	51a080e7          	jalr	1306(ra) # 8000555e <fdalloc>
    8000604c:	fca42223          	sw	a0,-60(s0)
    80006050:	08054b63          	bltz	a0,800060e6 <sys_pipe+0xe2>
    80006054:	fc843503          	ld	a0,-56(s0)
    80006058:	fffff097          	auipc	ra,0xfffff
    8000605c:	506080e7          	jalr	1286(ra) # 8000555e <fdalloc>
    80006060:	fca42023          	sw	a0,-64(s0)
    80006064:	06054863          	bltz	a0,800060d4 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006068:	4691                	li	a3,4
    8000606a:	fc440613          	addi	a2,s0,-60
    8000606e:	fd843583          	ld	a1,-40(s0)
    80006072:	68a8                	ld	a0,80(s1)
    80006074:	ffffb097          	auipc	ra,0xffffb
    80006078:	5f4080e7          	jalr	1524(ra) # 80001668 <copyout>
    8000607c:	02054063          	bltz	a0,8000609c <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006080:	4691                	li	a3,4
    80006082:	fc040613          	addi	a2,s0,-64
    80006086:	fd843583          	ld	a1,-40(s0)
    8000608a:	0591                	addi	a1,a1,4
    8000608c:	68a8                	ld	a0,80(s1)
    8000608e:	ffffb097          	auipc	ra,0xffffb
    80006092:	5da080e7          	jalr	1498(ra) # 80001668 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006096:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006098:	06055463          	bgez	a0,80006100 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    8000609c:	fc442783          	lw	a5,-60(s0)
    800060a0:	07e9                	addi	a5,a5,26
    800060a2:	078e                	slli	a5,a5,0x3
    800060a4:	97a6                	add	a5,a5,s1
    800060a6:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800060aa:	fc042503          	lw	a0,-64(s0)
    800060ae:	0569                	addi	a0,a0,26
    800060b0:	050e                	slli	a0,a0,0x3
    800060b2:	94aa                	add	s1,s1,a0
    800060b4:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800060b8:	fd043503          	ld	a0,-48(s0)
    800060bc:	fffff097          	auipc	ra,0xfffff
    800060c0:	a08080e7          	jalr	-1528(ra) # 80004ac4 <fileclose>
    fileclose(wf);
    800060c4:	fc843503          	ld	a0,-56(s0)
    800060c8:	fffff097          	auipc	ra,0xfffff
    800060cc:	9fc080e7          	jalr	-1540(ra) # 80004ac4 <fileclose>
    return -1;
    800060d0:	57fd                	li	a5,-1
    800060d2:	a03d                	j	80006100 <sys_pipe+0xfc>
    if(fd0 >= 0)
    800060d4:	fc442783          	lw	a5,-60(s0)
    800060d8:	0007c763          	bltz	a5,800060e6 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    800060dc:	07e9                	addi	a5,a5,26
    800060de:	078e                	slli	a5,a5,0x3
    800060e0:	94be                	add	s1,s1,a5
    800060e2:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800060e6:	fd043503          	ld	a0,-48(s0)
    800060ea:	fffff097          	auipc	ra,0xfffff
    800060ee:	9da080e7          	jalr	-1574(ra) # 80004ac4 <fileclose>
    fileclose(wf);
    800060f2:	fc843503          	ld	a0,-56(s0)
    800060f6:	fffff097          	auipc	ra,0xfffff
    800060fa:	9ce080e7          	jalr	-1586(ra) # 80004ac4 <fileclose>
    return -1;
    800060fe:	57fd                	li	a5,-1
}
    80006100:	853e                	mv	a0,a5
    80006102:	70e2                	ld	ra,56(sp)
    80006104:	7442                	ld	s0,48(sp)
    80006106:	74a2                	ld	s1,40(sp)
    80006108:	6121                	addi	sp,sp,64
    8000610a:	8082                	ret
    8000610c:	0000                	unimp
	...

0000000080006110 <kernelvec>:
    80006110:	7111                	addi	sp,sp,-256
    80006112:	e006                	sd	ra,0(sp)
    80006114:	e40a                	sd	sp,8(sp)
    80006116:	e80e                	sd	gp,16(sp)
    80006118:	ec12                	sd	tp,24(sp)
    8000611a:	f016                	sd	t0,32(sp)
    8000611c:	f41a                	sd	t1,40(sp)
    8000611e:	f81e                	sd	t2,48(sp)
    80006120:	fc22                	sd	s0,56(sp)
    80006122:	e0a6                	sd	s1,64(sp)
    80006124:	e4aa                	sd	a0,72(sp)
    80006126:	e8ae                	sd	a1,80(sp)
    80006128:	ecb2                	sd	a2,88(sp)
    8000612a:	f0b6                	sd	a3,96(sp)
    8000612c:	f4ba                	sd	a4,104(sp)
    8000612e:	f8be                	sd	a5,112(sp)
    80006130:	fcc2                	sd	a6,120(sp)
    80006132:	e146                	sd	a7,128(sp)
    80006134:	e54a                	sd	s2,136(sp)
    80006136:	e94e                	sd	s3,144(sp)
    80006138:	ed52                	sd	s4,152(sp)
    8000613a:	f156                	sd	s5,160(sp)
    8000613c:	f55a                	sd	s6,168(sp)
    8000613e:	f95e                	sd	s7,176(sp)
    80006140:	fd62                	sd	s8,184(sp)
    80006142:	e1e6                	sd	s9,192(sp)
    80006144:	e5ea                	sd	s10,200(sp)
    80006146:	e9ee                	sd	s11,208(sp)
    80006148:	edf2                	sd	t3,216(sp)
    8000614a:	f1f6                	sd	t4,224(sp)
    8000614c:	f5fa                	sd	t5,232(sp)
    8000614e:	f9fe                	sd	t6,240(sp)
    80006150:	af7fc0ef          	jal	ra,80002c46 <kerneltrap>
    80006154:	6082                	ld	ra,0(sp)
    80006156:	6122                	ld	sp,8(sp)
    80006158:	61c2                	ld	gp,16(sp)
    8000615a:	7282                	ld	t0,32(sp)
    8000615c:	7322                	ld	t1,40(sp)
    8000615e:	73c2                	ld	t2,48(sp)
    80006160:	7462                	ld	s0,56(sp)
    80006162:	6486                	ld	s1,64(sp)
    80006164:	6526                	ld	a0,72(sp)
    80006166:	65c6                	ld	a1,80(sp)
    80006168:	6666                	ld	a2,88(sp)
    8000616a:	7686                	ld	a3,96(sp)
    8000616c:	7726                	ld	a4,104(sp)
    8000616e:	77c6                	ld	a5,112(sp)
    80006170:	7866                	ld	a6,120(sp)
    80006172:	688a                	ld	a7,128(sp)
    80006174:	692a                	ld	s2,136(sp)
    80006176:	69ca                	ld	s3,144(sp)
    80006178:	6a6a                	ld	s4,152(sp)
    8000617a:	7a8a                	ld	s5,160(sp)
    8000617c:	7b2a                	ld	s6,168(sp)
    8000617e:	7bca                	ld	s7,176(sp)
    80006180:	7c6a                	ld	s8,184(sp)
    80006182:	6c8e                	ld	s9,192(sp)
    80006184:	6d2e                	ld	s10,200(sp)
    80006186:	6dce                	ld	s11,208(sp)
    80006188:	6e6e                	ld	t3,216(sp)
    8000618a:	7e8e                	ld	t4,224(sp)
    8000618c:	7f2e                	ld	t5,232(sp)
    8000618e:	7fce                	ld	t6,240(sp)
    80006190:	6111                	addi	sp,sp,256
    80006192:	10200073          	sret
    80006196:	00000013          	nop
    8000619a:	00000013          	nop
    8000619e:	0001                	nop

00000000800061a0 <timervec>:
    800061a0:	34051573          	csrrw	a0,mscratch,a0
    800061a4:	e10c                	sd	a1,0(a0)
    800061a6:	e510                	sd	a2,8(a0)
    800061a8:	e914                	sd	a3,16(a0)
    800061aa:	6d0c                	ld	a1,24(a0)
    800061ac:	7110                	ld	a2,32(a0)
    800061ae:	6194                	ld	a3,0(a1)
    800061b0:	96b2                	add	a3,a3,a2
    800061b2:	e194                	sd	a3,0(a1)
    800061b4:	4589                	li	a1,2
    800061b6:	14459073          	csrw	sip,a1
    800061ba:	6914                	ld	a3,16(a0)
    800061bc:	6510                	ld	a2,8(a0)
    800061be:	610c                	ld	a1,0(a0)
    800061c0:	34051573          	csrrw	a0,mscratch,a0
    800061c4:	30200073          	mret
	...

00000000800061ca <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800061ca:	1141                	addi	sp,sp,-16
    800061cc:	e422                	sd	s0,8(sp)
    800061ce:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800061d0:	0c0007b7          	lui	a5,0xc000
    800061d4:	4705                	li	a4,1
    800061d6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800061d8:	c3d8                	sw	a4,4(a5)
}
    800061da:	6422                	ld	s0,8(sp)
    800061dc:	0141                	addi	sp,sp,16
    800061de:	8082                	ret

00000000800061e0 <plicinithart>:

void
plicinithart(void)
{
    800061e0:	1141                	addi	sp,sp,-16
    800061e2:	e406                	sd	ra,8(sp)
    800061e4:	e022                	sd	s0,0(sp)
    800061e6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800061e8:	ffffb097          	auipc	ra,0xffffb
    800061ec:	798080e7          	jalr	1944(ra) # 80001980 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800061f0:	0085171b          	slliw	a4,a0,0x8
    800061f4:	0c0027b7          	lui	a5,0xc002
    800061f8:	97ba                	add	a5,a5,a4
    800061fa:	40200713          	li	a4,1026
    800061fe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006202:	00d5151b          	slliw	a0,a0,0xd
    80006206:	0c2017b7          	lui	a5,0xc201
    8000620a:	953e                	add	a0,a0,a5
    8000620c:	00052023          	sw	zero,0(a0)
}
    80006210:	60a2                	ld	ra,8(sp)
    80006212:	6402                	ld	s0,0(sp)
    80006214:	0141                	addi	sp,sp,16
    80006216:	8082                	ret

0000000080006218 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006218:	1141                	addi	sp,sp,-16
    8000621a:	e406                	sd	ra,8(sp)
    8000621c:	e022                	sd	s0,0(sp)
    8000621e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006220:	ffffb097          	auipc	ra,0xffffb
    80006224:	760080e7          	jalr	1888(ra) # 80001980 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006228:	00d5179b          	slliw	a5,a0,0xd
    8000622c:	0c201537          	lui	a0,0xc201
    80006230:	953e                	add	a0,a0,a5
  return irq;
}
    80006232:	4148                	lw	a0,4(a0)
    80006234:	60a2                	ld	ra,8(sp)
    80006236:	6402                	ld	s0,0(sp)
    80006238:	0141                	addi	sp,sp,16
    8000623a:	8082                	ret

000000008000623c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000623c:	1101                	addi	sp,sp,-32
    8000623e:	ec06                	sd	ra,24(sp)
    80006240:	e822                	sd	s0,16(sp)
    80006242:	e426                	sd	s1,8(sp)
    80006244:	1000                	addi	s0,sp,32
    80006246:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006248:	ffffb097          	auipc	ra,0xffffb
    8000624c:	738080e7          	jalr	1848(ra) # 80001980 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006250:	00d5151b          	slliw	a0,a0,0xd
    80006254:	0c2017b7          	lui	a5,0xc201
    80006258:	97aa                	add	a5,a5,a0
    8000625a:	c3c4                	sw	s1,4(a5)
}
    8000625c:	60e2                	ld	ra,24(sp)
    8000625e:	6442                	ld	s0,16(sp)
    80006260:	64a2                	ld	s1,8(sp)
    80006262:	6105                	addi	sp,sp,32
    80006264:	8082                	ret

0000000080006266 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006266:	1141                	addi	sp,sp,-16
    80006268:	e406                	sd	ra,8(sp)
    8000626a:	e022                	sd	s0,0(sp)
    8000626c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000626e:	479d                	li	a5,7
    80006270:	04a7cc63          	blt	a5,a0,800062c8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006274:	0001e797          	auipc	a5,0x1e
    80006278:	a2c78793          	addi	a5,a5,-1492 # 80023ca0 <disk>
    8000627c:	97aa                	add	a5,a5,a0
    8000627e:	0187c783          	lbu	a5,24(a5)
    80006282:	ebb9                	bnez	a5,800062d8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006284:	00451613          	slli	a2,a0,0x4
    80006288:	0001e797          	auipc	a5,0x1e
    8000628c:	a1878793          	addi	a5,a5,-1512 # 80023ca0 <disk>
    80006290:	6394                	ld	a3,0(a5)
    80006292:	96b2                	add	a3,a3,a2
    80006294:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006298:	6398                	ld	a4,0(a5)
    8000629a:	9732                	add	a4,a4,a2
    8000629c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800062a0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800062a4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800062a8:	953e                	add	a0,a0,a5
    800062aa:	4785                	li	a5,1
    800062ac:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    800062b0:	0001e517          	auipc	a0,0x1e
    800062b4:	a0850513          	addi	a0,a0,-1528 # 80023cb8 <disk+0x18>
    800062b8:	ffffc097          	auipc	ra,0xffffc
    800062bc:	06a080e7          	jalr	106(ra) # 80002322 <wakeup>
}
    800062c0:	60a2                	ld	ra,8(sp)
    800062c2:	6402                	ld	s0,0(sp)
    800062c4:	0141                	addi	sp,sp,16
    800062c6:	8082                	ret
    panic("free_desc 1");
    800062c8:	00002517          	auipc	a0,0x2
    800062cc:	63050513          	addi	a0,a0,1584 # 800088f8 <syscallnum+0x2a8>
    800062d0:	ffffa097          	auipc	ra,0xffffa
    800062d4:	26e080e7          	jalr	622(ra) # 8000053e <panic>
    panic("free_desc 2");
    800062d8:	00002517          	auipc	a0,0x2
    800062dc:	63050513          	addi	a0,a0,1584 # 80008908 <syscallnum+0x2b8>
    800062e0:	ffffa097          	auipc	ra,0xffffa
    800062e4:	25e080e7          	jalr	606(ra) # 8000053e <panic>

00000000800062e8 <virtio_disk_init>:
{
    800062e8:	1101                	addi	sp,sp,-32
    800062ea:	ec06                	sd	ra,24(sp)
    800062ec:	e822                	sd	s0,16(sp)
    800062ee:	e426                	sd	s1,8(sp)
    800062f0:	e04a                	sd	s2,0(sp)
    800062f2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800062f4:	00002597          	auipc	a1,0x2
    800062f8:	62458593          	addi	a1,a1,1572 # 80008918 <syscallnum+0x2c8>
    800062fc:	0001e517          	auipc	a0,0x1e
    80006300:	acc50513          	addi	a0,a0,-1332 # 80023dc8 <disk+0x128>
    80006304:	ffffb097          	auipc	ra,0xffffb
    80006308:	842080e7          	jalr	-1982(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000630c:	100017b7          	lui	a5,0x10001
    80006310:	4398                	lw	a4,0(a5)
    80006312:	2701                	sext.w	a4,a4
    80006314:	747277b7          	lui	a5,0x74727
    80006318:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000631c:	14f71c63          	bne	a4,a5,80006474 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006320:	100017b7          	lui	a5,0x10001
    80006324:	43dc                	lw	a5,4(a5)
    80006326:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006328:	4709                	li	a4,2
    8000632a:	14e79563          	bne	a5,a4,80006474 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000632e:	100017b7          	lui	a5,0x10001
    80006332:	479c                	lw	a5,8(a5)
    80006334:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006336:	12e79f63          	bne	a5,a4,80006474 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000633a:	100017b7          	lui	a5,0x10001
    8000633e:	47d8                	lw	a4,12(a5)
    80006340:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006342:	554d47b7          	lui	a5,0x554d4
    80006346:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000634a:	12f71563          	bne	a4,a5,80006474 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000634e:	100017b7          	lui	a5,0x10001
    80006352:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006356:	4705                	li	a4,1
    80006358:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000635a:	470d                	li	a4,3
    8000635c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000635e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006360:	c7ffe737          	lui	a4,0xc7ffe
    80006364:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fda97f>
    80006368:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000636a:	2701                	sext.w	a4,a4
    8000636c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000636e:	472d                	li	a4,11
    80006370:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006372:	5bbc                	lw	a5,112(a5)
    80006374:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006378:	8ba1                	andi	a5,a5,8
    8000637a:	10078563          	beqz	a5,80006484 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000637e:	100017b7          	lui	a5,0x10001
    80006382:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006386:	43fc                	lw	a5,68(a5)
    80006388:	2781                	sext.w	a5,a5
    8000638a:	10079563          	bnez	a5,80006494 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000638e:	100017b7          	lui	a5,0x10001
    80006392:	5bdc                	lw	a5,52(a5)
    80006394:	2781                	sext.w	a5,a5
  if(max == 0)
    80006396:	10078763          	beqz	a5,800064a4 <virtio_disk_init+0x1bc>
  if(max < NUM)
    8000639a:	471d                	li	a4,7
    8000639c:	10f77c63          	bgeu	a4,a5,800064b4 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    800063a0:	ffffa097          	auipc	ra,0xffffa
    800063a4:	746080e7          	jalr	1862(ra) # 80000ae6 <kalloc>
    800063a8:	0001e497          	auipc	s1,0x1e
    800063ac:	8f848493          	addi	s1,s1,-1800 # 80023ca0 <disk>
    800063b0:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800063b2:	ffffa097          	auipc	ra,0xffffa
    800063b6:	734080e7          	jalr	1844(ra) # 80000ae6 <kalloc>
    800063ba:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800063bc:	ffffa097          	auipc	ra,0xffffa
    800063c0:	72a080e7          	jalr	1834(ra) # 80000ae6 <kalloc>
    800063c4:	87aa                	mv	a5,a0
    800063c6:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800063c8:	6088                	ld	a0,0(s1)
    800063ca:	cd6d                	beqz	a0,800064c4 <virtio_disk_init+0x1dc>
    800063cc:	0001e717          	auipc	a4,0x1e
    800063d0:	8dc73703          	ld	a4,-1828(a4) # 80023ca8 <disk+0x8>
    800063d4:	cb65                	beqz	a4,800064c4 <virtio_disk_init+0x1dc>
    800063d6:	c7fd                	beqz	a5,800064c4 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    800063d8:	6605                	lui	a2,0x1
    800063da:	4581                	li	a1,0
    800063dc:	ffffb097          	auipc	ra,0xffffb
    800063e0:	8f6080e7          	jalr	-1802(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    800063e4:	0001e497          	auipc	s1,0x1e
    800063e8:	8bc48493          	addi	s1,s1,-1860 # 80023ca0 <disk>
    800063ec:	6605                	lui	a2,0x1
    800063ee:	4581                	li	a1,0
    800063f0:	6488                	ld	a0,8(s1)
    800063f2:	ffffb097          	auipc	ra,0xffffb
    800063f6:	8e0080e7          	jalr	-1824(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    800063fa:	6605                	lui	a2,0x1
    800063fc:	4581                	li	a1,0
    800063fe:	6888                	ld	a0,16(s1)
    80006400:	ffffb097          	auipc	ra,0xffffb
    80006404:	8d2080e7          	jalr	-1838(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006408:	100017b7          	lui	a5,0x10001
    8000640c:	4721                	li	a4,8
    8000640e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006410:	4098                	lw	a4,0(s1)
    80006412:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006416:	40d8                	lw	a4,4(s1)
    80006418:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000641c:	6498                	ld	a4,8(s1)
    8000641e:	0007069b          	sext.w	a3,a4
    80006422:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006426:	9701                	srai	a4,a4,0x20
    80006428:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000642c:	6898                	ld	a4,16(s1)
    8000642e:	0007069b          	sext.w	a3,a4
    80006432:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006436:	9701                	srai	a4,a4,0x20
    80006438:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000643c:	4705                	li	a4,1
    8000643e:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80006440:	00e48c23          	sb	a4,24(s1)
    80006444:	00e48ca3          	sb	a4,25(s1)
    80006448:	00e48d23          	sb	a4,26(s1)
    8000644c:	00e48da3          	sb	a4,27(s1)
    80006450:	00e48e23          	sb	a4,28(s1)
    80006454:	00e48ea3          	sb	a4,29(s1)
    80006458:	00e48f23          	sb	a4,30(s1)
    8000645c:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006460:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006464:	0727a823          	sw	s2,112(a5)
}
    80006468:	60e2                	ld	ra,24(sp)
    8000646a:	6442                	ld	s0,16(sp)
    8000646c:	64a2                	ld	s1,8(sp)
    8000646e:	6902                	ld	s2,0(sp)
    80006470:	6105                	addi	sp,sp,32
    80006472:	8082                	ret
    panic("could not find virtio disk");
    80006474:	00002517          	auipc	a0,0x2
    80006478:	4b450513          	addi	a0,a0,1204 # 80008928 <syscallnum+0x2d8>
    8000647c:	ffffa097          	auipc	ra,0xffffa
    80006480:	0c2080e7          	jalr	194(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    80006484:	00002517          	auipc	a0,0x2
    80006488:	4c450513          	addi	a0,a0,1220 # 80008948 <syscallnum+0x2f8>
    8000648c:	ffffa097          	auipc	ra,0xffffa
    80006490:	0b2080e7          	jalr	178(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    80006494:	00002517          	auipc	a0,0x2
    80006498:	4d450513          	addi	a0,a0,1236 # 80008968 <syscallnum+0x318>
    8000649c:	ffffa097          	auipc	ra,0xffffa
    800064a0:	0a2080e7          	jalr	162(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    800064a4:	00002517          	auipc	a0,0x2
    800064a8:	4e450513          	addi	a0,a0,1252 # 80008988 <syscallnum+0x338>
    800064ac:	ffffa097          	auipc	ra,0xffffa
    800064b0:	092080e7          	jalr	146(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    800064b4:	00002517          	auipc	a0,0x2
    800064b8:	4f450513          	addi	a0,a0,1268 # 800089a8 <syscallnum+0x358>
    800064bc:	ffffa097          	auipc	ra,0xffffa
    800064c0:	082080e7          	jalr	130(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    800064c4:	00002517          	auipc	a0,0x2
    800064c8:	50450513          	addi	a0,a0,1284 # 800089c8 <syscallnum+0x378>
    800064cc:	ffffa097          	auipc	ra,0xffffa
    800064d0:	072080e7          	jalr	114(ra) # 8000053e <panic>

00000000800064d4 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800064d4:	7119                	addi	sp,sp,-128
    800064d6:	fc86                	sd	ra,120(sp)
    800064d8:	f8a2                	sd	s0,112(sp)
    800064da:	f4a6                	sd	s1,104(sp)
    800064dc:	f0ca                	sd	s2,96(sp)
    800064de:	ecce                	sd	s3,88(sp)
    800064e0:	e8d2                	sd	s4,80(sp)
    800064e2:	e4d6                	sd	s5,72(sp)
    800064e4:	e0da                	sd	s6,64(sp)
    800064e6:	fc5e                	sd	s7,56(sp)
    800064e8:	f862                	sd	s8,48(sp)
    800064ea:	f466                	sd	s9,40(sp)
    800064ec:	f06a                	sd	s10,32(sp)
    800064ee:	ec6e                	sd	s11,24(sp)
    800064f0:	0100                	addi	s0,sp,128
    800064f2:	8aaa                	mv	s5,a0
    800064f4:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800064f6:	00c52d03          	lw	s10,12(a0)
    800064fa:	001d1d1b          	slliw	s10,s10,0x1
    800064fe:	1d02                	slli	s10,s10,0x20
    80006500:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006504:	0001e517          	auipc	a0,0x1e
    80006508:	8c450513          	addi	a0,a0,-1852 # 80023dc8 <disk+0x128>
    8000650c:	ffffa097          	auipc	ra,0xffffa
    80006510:	6ca080e7          	jalr	1738(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80006514:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006516:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006518:	0001db97          	auipc	s7,0x1d
    8000651c:	788b8b93          	addi	s7,s7,1928 # 80023ca0 <disk>
  for(int i = 0; i < 3; i++){
    80006520:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006522:	0001ec97          	auipc	s9,0x1e
    80006526:	8a6c8c93          	addi	s9,s9,-1882 # 80023dc8 <disk+0x128>
    8000652a:	a08d                	j	8000658c <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000652c:	00fb8733          	add	a4,s7,a5
    80006530:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006534:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006536:	0207c563          	bltz	a5,80006560 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000653a:	2905                	addiw	s2,s2,1
    8000653c:	0611                	addi	a2,a2,4
    8000653e:	05690c63          	beq	s2,s6,80006596 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006542:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006544:	0001d717          	auipc	a4,0x1d
    80006548:	75c70713          	addi	a4,a4,1884 # 80023ca0 <disk>
    8000654c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000654e:	01874683          	lbu	a3,24(a4)
    80006552:	fee9                	bnez	a3,8000652c <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006554:	2785                	addiw	a5,a5,1
    80006556:	0705                	addi	a4,a4,1
    80006558:	fe979be3          	bne	a5,s1,8000654e <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000655c:	57fd                	li	a5,-1
    8000655e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006560:	01205d63          	blez	s2,8000657a <virtio_disk_rw+0xa6>
    80006564:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006566:	000a2503          	lw	a0,0(s4)
    8000656a:	00000097          	auipc	ra,0x0
    8000656e:	cfc080e7          	jalr	-772(ra) # 80006266 <free_desc>
      for(int j = 0; j < i; j++)
    80006572:	2d85                	addiw	s11,s11,1
    80006574:	0a11                	addi	s4,s4,4
    80006576:	ffb918e3          	bne	s2,s11,80006566 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000657a:	85e6                	mv	a1,s9
    8000657c:	0001d517          	auipc	a0,0x1d
    80006580:	73c50513          	addi	a0,a0,1852 # 80023cb8 <disk+0x18>
    80006584:	ffffc097          	auipc	ra,0xffffc
    80006588:	bee080e7          	jalr	-1042(ra) # 80002172 <sleep>
  for(int i = 0; i < 3; i++){
    8000658c:	f8040a13          	addi	s4,s0,-128
{
    80006590:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006592:	894e                	mv	s2,s3
    80006594:	b77d                	j	80006542 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006596:	f8042583          	lw	a1,-128(s0)
    8000659a:	00a58793          	addi	a5,a1,10
    8000659e:	0792                	slli	a5,a5,0x4

  if(write)
    800065a0:	0001d617          	auipc	a2,0x1d
    800065a4:	70060613          	addi	a2,a2,1792 # 80023ca0 <disk>
    800065a8:	00f60733          	add	a4,a2,a5
    800065ac:	018036b3          	snez	a3,s8
    800065b0:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800065b2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800065b6:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800065ba:	f6078693          	addi	a3,a5,-160
    800065be:	6218                	ld	a4,0(a2)
    800065c0:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800065c2:	00878513          	addi	a0,a5,8
    800065c6:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    800065c8:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800065ca:	6208                	ld	a0,0(a2)
    800065cc:	96aa                	add	a3,a3,a0
    800065ce:	4741                	li	a4,16
    800065d0:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800065d2:	4705                	li	a4,1
    800065d4:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    800065d8:	f8442703          	lw	a4,-124(s0)
    800065dc:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800065e0:	0712                	slli	a4,a4,0x4
    800065e2:	953a                	add	a0,a0,a4
    800065e4:	058a8693          	addi	a3,s5,88
    800065e8:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    800065ea:	6208                	ld	a0,0(a2)
    800065ec:	972a                	add	a4,a4,a0
    800065ee:	40000693          	li	a3,1024
    800065f2:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800065f4:	001c3c13          	seqz	s8,s8
    800065f8:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800065fa:	001c6c13          	ori	s8,s8,1
    800065fe:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006602:	f8842603          	lw	a2,-120(s0)
    80006606:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000660a:	0001d697          	auipc	a3,0x1d
    8000660e:	69668693          	addi	a3,a3,1686 # 80023ca0 <disk>
    80006612:	00258713          	addi	a4,a1,2
    80006616:	0712                	slli	a4,a4,0x4
    80006618:	9736                	add	a4,a4,a3
    8000661a:	587d                	li	a6,-1
    8000661c:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006620:	0612                	slli	a2,a2,0x4
    80006622:	9532                	add	a0,a0,a2
    80006624:	f9078793          	addi	a5,a5,-112
    80006628:	97b6                	add	a5,a5,a3
    8000662a:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    8000662c:	629c                	ld	a5,0(a3)
    8000662e:	97b2                	add	a5,a5,a2
    80006630:	4605                	li	a2,1
    80006632:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006634:	4509                	li	a0,2
    80006636:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    8000663a:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000663e:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006642:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006646:	6698                	ld	a4,8(a3)
    80006648:	00275783          	lhu	a5,2(a4)
    8000664c:	8b9d                	andi	a5,a5,7
    8000664e:	0786                	slli	a5,a5,0x1
    80006650:	97ba                	add	a5,a5,a4
    80006652:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006656:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000665a:	6698                	ld	a4,8(a3)
    8000665c:	00275783          	lhu	a5,2(a4)
    80006660:	2785                	addiw	a5,a5,1
    80006662:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006666:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000666a:	100017b7          	lui	a5,0x10001
    8000666e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006672:	004aa783          	lw	a5,4(s5)
    80006676:	02c79163          	bne	a5,a2,80006698 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    8000667a:	0001d917          	auipc	s2,0x1d
    8000667e:	74e90913          	addi	s2,s2,1870 # 80023dc8 <disk+0x128>
  while(b->disk == 1) {
    80006682:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006684:	85ca                	mv	a1,s2
    80006686:	8556                	mv	a0,s5
    80006688:	ffffc097          	auipc	ra,0xffffc
    8000668c:	aea080e7          	jalr	-1302(ra) # 80002172 <sleep>
  while(b->disk == 1) {
    80006690:	004aa783          	lw	a5,4(s5)
    80006694:	fe9788e3          	beq	a5,s1,80006684 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006698:	f8042903          	lw	s2,-128(s0)
    8000669c:	00290793          	addi	a5,s2,2
    800066a0:	00479713          	slli	a4,a5,0x4
    800066a4:	0001d797          	auipc	a5,0x1d
    800066a8:	5fc78793          	addi	a5,a5,1532 # 80023ca0 <disk>
    800066ac:	97ba                	add	a5,a5,a4
    800066ae:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800066b2:	0001d997          	auipc	s3,0x1d
    800066b6:	5ee98993          	addi	s3,s3,1518 # 80023ca0 <disk>
    800066ba:	00491713          	slli	a4,s2,0x4
    800066be:	0009b783          	ld	a5,0(s3)
    800066c2:	97ba                	add	a5,a5,a4
    800066c4:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800066c8:	854a                	mv	a0,s2
    800066ca:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800066ce:	00000097          	auipc	ra,0x0
    800066d2:	b98080e7          	jalr	-1128(ra) # 80006266 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800066d6:	8885                	andi	s1,s1,1
    800066d8:	f0ed                	bnez	s1,800066ba <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800066da:	0001d517          	auipc	a0,0x1d
    800066de:	6ee50513          	addi	a0,a0,1774 # 80023dc8 <disk+0x128>
    800066e2:	ffffa097          	auipc	ra,0xffffa
    800066e6:	5a8080e7          	jalr	1448(ra) # 80000c8a <release>
}
    800066ea:	70e6                	ld	ra,120(sp)
    800066ec:	7446                	ld	s0,112(sp)
    800066ee:	74a6                	ld	s1,104(sp)
    800066f0:	7906                	ld	s2,96(sp)
    800066f2:	69e6                	ld	s3,88(sp)
    800066f4:	6a46                	ld	s4,80(sp)
    800066f6:	6aa6                	ld	s5,72(sp)
    800066f8:	6b06                	ld	s6,64(sp)
    800066fa:	7be2                	ld	s7,56(sp)
    800066fc:	7c42                	ld	s8,48(sp)
    800066fe:	7ca2                	ld	s9,40(sp)
    80006700:	7d02                	ld	s10,32(sp)
    80006702:	6de2                	ld	s11,24(sp)
    80006704:	6109                	addi	sp,sp,128
    80006706:	8082                	ret

0000000080006708 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006708:	1101                	addi	sp,sp,-32
    8000670a:	ec06                	sd	ra,24(sp)
    8000670c:	e822                	sd	s0,16(sp)
    8000670e:	e426                	sd	s1,8(sp)
    80006710:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006712:	0001d497          	auipc	s1,0x1d
    80006716:	58e48493          	addi	s1,s1,1422 # 80023ca0 <disk>
    8000671a:	0001d517          	auipc	a0,0x1d
    8000671e:	6ae50513          	addi	a0,a0,1710 # 80023dc8 <disk+0x128>
    80006722:	ffffa097          	auipc	ra,0xffffa
    80006726:	4b4080e7          	jalr	1204(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000672a:	10001737          	lui	a4,0x10001
    8000672e:	533c                	lw	a5,96(a4)
    80006730:	8b8d                	andi	a5,a5,3
    80006732:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006734:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006738:	689c                	ld	a5,16(s1)
    8000673a:	0204d703          	lhu	a4,32(s1)
    8000673e:	0027d783          	lhu	a5,2(a5)
    80006742:	04f70863          	beq	a4,a5,80006792 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006746:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000674a:	6898                	ld	a4,16(s1)
    8000674c:	0204d783          	lhu	a5,32(s1)
    80006750:	8b9d                	andi	a5,a5,7
    80006752:	078e                	slli	a5,a5,0x3
    80006754:	97ba                	add	a5,a5,a4
    80006756:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006758:	00278713          	addi	a4,a5,2
    8000675c:	0712                	slli	a4,a4,0x4
    8000675e:	9726                	add	a4,a4,s1
    80006760:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006764:	e721                	bnez	a4,800067ac <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006766:	0789                	addi	a5,a5,2
    80006768:	0792                	slli	a5,a5,0x4
    8000676a:	97a6                	add	a5,a5,s1
    8000676c:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000676e:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006772:	ffffc097          	auipc	ra,0xffffc
    80006776:	bb0080e7          	jalr	-1104(ra) # 80002322 <wakeup>

    disk.used_idx += 1;
    8000677a:	0204d783          	lhu	a5,32(s1)
    8000677e:	2785                	addiw	a5,a5,1
    80006780:	17c2                	slli	a5,a5,0x30
    80006782:	93c1                	srli	a5,a5,0x30
    80006784:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006788:	6898                	ld	a4,16(s1)
    8000678a:	00275703          	lhu	a4,2(a4)
    8000678e:	faf71ce3          	bne	a4,a5,80006746 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006792:	0001d517          	auipc	a0,0x1d
    80006796:	63650513          	addi	a0,a0,1590 # 80023dc8 <disk+0x128>
    8000679a:	ffffa097          	auipc	ra,0xffffa
    8000679e:	4f0080e7          	jalr	1264(ra) # 80000c8a <release>
}
    800067a2:	60e2                	ld	ra,24(sp)
    800067a4:	6442                	ld	s0,16(sp)
    800067a6:	64a2                	ld	s1,8(sp)
    800067a8:	6105                	addi	sp,sp,32
    800067aa:	8082                	ret
      panic("virtio_disk_intr status");
    800067ac:	00002517          	auipc	a0,0x2
    800067b0:	23450513          	addi	a0,a0,564 # 800089e0 <syscallnum+0x390>
    800067b4:	ffffa097          	auipc	ra,0xffffa
    800067b8:	d8a080e7          	jalr	-630(ra) # 8000053e <panic>
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


kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	cc010113          	addi	sp,sp,-832 # 80008cc0 <stack0>
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
    80000056:	b2e70713          	addi	a4,a4,-1234 # 80008b80 <timer_scratch>
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
    80000068:	40c78793          	addi	a5,a5,1036 # 80006470 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffda5df>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	de678793          	addi	a5,a5,-538 # 80000e94 <main>
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
    80000130:	8a4080e7          	jalr	-1884(ra) # 800029d0 <either_copyin>
    80000134:	01550c63          	beq	a0,s5,8000014c <consolewrite+0x4a>
      break;
    uartputc(c);
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00000097          	auipc	ra,0x0
    80000140:	794080e7          	jalr	1940(ra) # 800008d0 <uartputc>
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
    80000164:	7119                	addi	sp,sp,-128
    80000166:	fc86                	sd	ra,120(sp)
    80000168:	f8a2                	sd	s0,112(sp)
    8000016a:	f4a6                	sd	s1,104(sp)
    8000016c:	f0ca                	sd	s2,96(sp)
    8000016e:	ecce                	sd	s3,88(sp)
    80000170:	e8d2                	sd	s4,80(sp)
    80000172:	e4d6                	sd	s5,72(sp)
    80000174:	e0da                	sd	s6,64(sp)
    80000176:	fc5e                	sd	s7,56(sp)
    80000178:	f862                	sd	s8,48(sp)
    8000017a:	f466                	sd	s9,40(sp)
    8000017c:	f06a                	sd	s10,32(sp)
    8000017e:	ec6e                	sd	s11,24(sp)
    80000180:	0100                	addi	s0,sp,128
    80000182:	8b2a                	mv	s6,a0
    80000184:	8aae                	mv	s5,a1
    80000186:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    8000018c:	00011517          	auipc	a0,0x11
    80000190:	b3450513          	addi	a0,a0,-1228 # 80010cc0 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	a56080e7          	jalr	-1450(ra) # 80000bea <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019c:	00011497          	auipc	s1,0x11
    800001a0:	b2448493          	addi	s1,s1,-1244 # 80010cc0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a4:	89a6                	mv	s3,s1
    800001a6:	00011917          	auipc	s2,0x11
    800001aa:	bb290913          	addi	s2,s2,-1102 # 80010d58 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    800001ae:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001b0:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001b2:	4da9                	li	s11,10
  while(n > 0){
    800001b4:	07405b63          	blez	s4,8000022a <consoleread+0xc6>
    while(cons.r == cons.w){
    800001b8:	0984a783          	lw	a5,152(s1)
    800001bc:	09c4a703          	lw	a4,156(s1)
    800001c0:	02f71763          	bne	a4,a5,800001ee <consoleread+0x8a>
      if(killed(myproc())){
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	802080e7          	jalr	-2046(ra) # 800019c6 <myproc>
    800001cc:	00002097          	auipc	ra,0x2
    800001d0:	64e080e7          	jalr	1614(ra) # 8000281a <killed>
    800001d4:	e535                	bnez	a0,80000240 <consoleread+0xdc>
      sleep(&cons.r, &cons.lock);
    800001d6:	85ce                	mv	a1,s3
    800001d8:	854a                	mv	a0,s2
    800001da:	00002097          	auipc	ra,0x2
    800001de:	240080e7          	jalr	576(ra) # 8000241a <sleep>
    while(cons.r == cons.w){
    800001e2:	0984a783          	lw	a5,152(s1)
    800001e6:	09c4a703          	lw	a4,156(s1)
    800001ea:	fcf70de3          	beq	a4,a5,800001c4 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ee:	0017871b          	addiw	a4,a5,1
    800001f2:	08e4ac23          	sw	a4,152(s1)
    800001f6:	07f7f713          	andi	a4,a5,127
    800001fa:	9726                	add	a4,a4,s1
    800001fc:	01874703          	lbu	a4,24(a4)
    80000200:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    80000204:	079c0663          	beq	s8,s9,80000270 <consoleread+0x10c>
    cbuf = c;
    80000208:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000020c:	4685                	li	a3,1
    8000020e:	f8f40613          	addi	a2,s0,-113
    80000212:	85d6                	mv	a1,s5
    80000214:	855a                	mv	a0,s6
    80000216:	00002097          	auipc	ra,0x2
    8000021a:	764080e7          	jalr	1892(ra) # 8000297a <either_copyout>
    8000021e:	01a50663          	beq	a0,s10,8000022a <consoleread+0xc6>
    dst++;
    80000222:	0a85                	addi	s5,s5,1
    --n;
    80000224:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    80000226:	f9bc17e3          	bne	s8,s11,800001b4 <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    8000022a:	00011517          	auipc	a0,0x11
    8000022e:	a9650513          	addi	a0,a0,-1386 # 80010cc0 <cons>
    80000232:	00001097          	auipc	ra,0x1
    80000236:	a6c080e7          	jalr	-1428(ra) # 80000c9e <release>

  return target - n;
    8000023a:	414b853b          	subw	a0,s7,s4
    8000023e:	a811                	j	80000252 <consoleread+0xee>
        release(&cons.lock);
    80000240:	00011517          	auipc	a0,0x11
    80000244:	a8050513          	addi	a0,a0,-1408 # 80010cc0 <cons>
    80000248:	00001097          	auipc	ra,0x1
    8000024c:	a56080e7          	jalr	-1450(ra) # 80000c9e <release>
        return -1;
    80000250:	557d                	li	a0,-1
}
    80000252:	70e6                	ld	ra,120(sp)
    80000254:	7446                	ld	s0,112(sp)
    80000256:	74a6                	ld	s1,104(sp)
    80000258:	7906                	ld	s2,96(sp)
    8000025a:	69e6                	ld	s3,88(sp)
    8000025c:	6a46                	ld	s4,80(sp)
    8000025e:	6aa6                	ld	s5,72(sp)
    80000260:	6b06                	ld	s6,64(sp)
    80000262:	7be2                	ld	s7,56(sp)
    80000264:	7c42                	ld	s8,48(sp)
    80000266:	7ca2                	ld	s9,40(sp)
    80000268:	7d02                	ld	s10,32(sp)
    8000026a:	6de2                	ld	s11,24(sp)
    8000026c:	6109                	addi	sp,sp,128
    8000026e:	8082                	ret
      if(n < target){
    80000270:	000a071b          	sext.w	a4,s4
    80000274:	fb777be3          	bgeu	a4,s7,8000022a <consoleread+0xc6>
        cons.r--;
    80000278:	00011717          	auipc	a4,0x11
    8000027c:	aef72023          	sw	a5,-1312(a4) # 80010d58 <cons+0x98>
    80000280:	b76d                	j	8000022a <consoleread+0xc6>

0000000080000282 <consputc>:
{
    80000282:	1141                	addi	sp,sp,-16
    80000284:	e406                	sd	ra,8(sp)
    80000286:	e022                	sd	s0,0(sp)
    80000288:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000028a:	10000793          	li	a5,256
    8000028e:	00f50a63          	beq	a0,a5,800002a2 <consputc+0x20>
    uartputc_sync(c);
    80000292:	00000097          	auipc	ra,0x0
    80000296:	564080e7          	jalr	1380(ra) # 800007f6 <uartputc_sync>
}
    8000029a:	60a2                	ld	ra,8(sp)
    8000029c:	6402                	ld	s0,0(sp)
    8000029e:	0141                	addi	sp,sp,16
    800002a0:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002a2:	4521                	li	a0,8
    800002a4:	00000097          	auipc	ra,0x0
    800002a8:	552080e7          	jalr	1362(ra) # 800007f6 <uartputc_sync>
    800002ac:	02000513          	li	a0,32
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	546080e7          	jalr	1350(ra) # 800007f6 <uartputc_sync>
    800002b8:	4521                	li	a0,8
    800002ba:	00000097          	auipc	ra,0x0
    800002be:	53c080e7          	jalr	1340(ra) # 800007f6 <uartputc_sync>
    800002c2:	bfe1                	j	8000029a <consputc+0x18>

00000000800002c4 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002c4:	1101                	addi	sp,sp,-32
    800002c6:	ec06                	sd	ra,24(sp)
    800002c8:	e822                	sd	s0,16(sp)
    800002ca:	e426                	sd	s1,8(sp)
    800002cc:	e04a                	sd	s2,0(sp)
    800002ce:	1000                	addi	s0,sp,32
    800002d0:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002d2:	00011517          	auipc	a0,0x11
    800002d6:	9ee50513          	addi	a0,a0,-1554 # 80010cc0 <cons>
    800002da:	00001097          	auipc	ra,0x1
    800002de:	910080e7          	jalr	-1776(ra) # 80000bea <acquire>

  switch(c){
    800002e2:	47d5                	li	a5,21
    800002e4:	0af48663          	beq	s1,a5,80000390 <consoleintr+0xcc>
    800002e8:	0297ca63          	blt	a5,s1,8000031c <consoleintr+0x58>
    800002ec:	47a1                	li	a5,8
    800002ee:	0ef48763          	beq	s1,a5,800003dc <consoleintr+0x118>
    800002f2:	47c1                	li	a5,16
    800002f4:	10f49a63          	bne	s1,a5,80000408 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f8:	00002097          	auipc	ra,0x2
    800002fc:	72e080e7          	jalr	1838(ra) # 80002a26 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000300:	00011517          	auipc	a0,0x11
    80000304:	9c050513          	addi	a0,a0,-1600 # 80010cc0 <cons>
    80000308:	00001097          	auipc	ra,0x1
    8000030c:	996080e7          	jalr	-1642(ra) # 80000c9e <release>
}
    80000310:	60e2                	ld	ra,24(sp)
    80000312:	6442                	ld	s0,16(sp)
    80000314:	64a2                	ld	s1,8(sp)
    80000316:	6902                	ld	s2,0(sp)
    80000318:	6105                	addi	sp,sp,32
    8000031a:	8082                	ret
  switch(c){
    8000031c:	07f00793          	li	a5,127
    80000320:	0af48e63          	beq	s1,a5,800003dc <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000324:	00011717          	auipc	a4,0x11
    80000328:	99c70713          	addi	a4,a4,-1636 # 80010cc0 <cons>
    8000032c:	0a072783          	lw	a5,160(a4)
    80000330:	09872703          	lw	a4,152(a4)
    80000334:	9f99                	subw	a5,a5,a4
    80000336:	07f00713          	li	a4,127
    8000033a:	fcf763e3          	bltu	a4,a5,80000300 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    8000033e:	47b5                	li	a5,13
    80000340:	0cf48763          	beq	s1,a5,8000040e <consoleintr+0x14a>
      consputc(c);
    80000344:	8526                	mv	a0,s1
    80000346:	00000097          	auipc	ra,0x0
    8000034a:	f3c080e7          	jalr	-196(ra) # 80000282 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000034e:	00011797          	auipc	a5,0x11
    80000352:	97278793          	addi	a5,a5,-1678 # 80010cc0 <cons>
    80000356:	0a07a683          	lw	a3,160(a5)
    8000035a:	0016871b          	addiw	a4,a3,1
    8000035e:	0007061b          	sext.w	a2,a4
    80000362:	0ae7a023          	sw	a4,160(a5)
    80000366:	07f6f693          	andi	a3,a3,127
    8000036a:	97b6                	add	a5,a5,a3
    8000036c:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000370:	47a9                	li	a5,10
    80000372:	0cf48563          	beq	s1,a5,8000043c <consoleintr+0x178>
    80000376:	4791                	li	a5,4
    80000378:	0cf48263          	beq	s1,a5,8000043c <consoleintr+0x178>
    8000037c:	00011797          	auipc	a5,0x11
    80000380:	9dc7a783          	lw	a5,-1572(a5) # 80010d58 <cons+0x98>
    80000384:	9f1d                	subw	a4,a4,a5
    80000386:	08000793          	li	a5,128
    8000038a:	f6f71be3          	bne	a4,a5,80000300 <consoleintr+0x3c>
    8000038e:	a07d                	j	8000043c <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000390:	00011717          	auipc	a4,0x11
    80000394:	93070713          	addi	a4,a4,-1744 # 80010cc0 <cons>
    80000398:	0a072783          	lw	a5,160(a4)
    8000039c:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a0:	00011497          	auipc	s1,0x11
    800003a4:	92048493          	addi	s1,s1,-1760 # 80010cc0 <cons>
    while(cons.e != cons.w &&
    800003a8:	4929                	li	s2,10
    800003aa:	f4f70be3          	beq	a4,a5,80000300 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003ae:	37fd                	addiw	a5,a5,-1
    800003b0:	07f7f713          	andi	a4,a5,127
    800003b4:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b6:	01874703          	lbu	a4,24(a4)
    800003ba:	f52703e3          	beq	a4,s2,80000300 <consoleintr+0x3c>
      cons.e--;
    800003be:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003c2:	10000513          	li	a0,256
    800003c6:	00000097          	auipc	ra,0x0
    800003ca:	ebc080e7          	jalr	-324(ra) # 80000282 <consputc>
    while(cons.e != cons.w &&
    800003ce:	0a04a783          	lw	a5,160(s1)
    800003d2:	09c4a703          	lw	a4,156(s1)
    800003d6:	fcf71ce3          	bne	a4,a5,800003ae <consoleintr+0xea>
    800003da:	b71d                	j	80000300 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003dc:	00011717          	auipc	a4,0x11
    800003e0:	8e470713          	addi	a4,a4,-1820 # 80010cc0 <cons>
    800003e4:	0a072783          	lw	a5,160(a4)
    800003e8:	09c72703          	lw	a4,156(a4)
    800003ec:	f0f70ae3          	beq	a4,a5,80000300 <consoleintr+0x3c>
      cons.e--;
    800003f0:	37fd                	addiw	a5,a5,-1
    800003f2:	00011717          	auipc	a4,0x11
    800003f6:	96f72723          	sw	a5,-1682(a4) # 80010d60 <cons+0xa0>
      consputc(BACKSPACE);
    800003fa:	10000513          	li	a0,256
    800003fe:	00000097          	auipc	ra,0x0
    80000402:	e84080e7          	jalr	-380(ra) # 80000282 <consputc>
    80000406:	bded                	j	80000300 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000408:	ee048ce3          	beqz	s1,80000300 <consoleintr+0x3c>
    8000040c:	bf21                	j	80000324 <consoleintr+0x60>
      consputc(c);
    8000040e:	4529                	li	a0,10
    80000410:	00000097          	auipc	ra,0x0
    80000414:	e72080e7          	jalr	-398(ra) # 80000282 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000418:	00011797          	auipc	a5,0x11
    8000041c:	8a878793          	addi	a5,a5,-1880 # 80010cc0 <cons>
    80000420:	0a07a703          	lw	a4,160(a5)
    80000424:	0017069b          	addiw	a3,a4,1
    80000428:	0006861b          	sext.w	a2,a3
    8000042c:	0ad7a023          	sw	a3,160(a5)
    80000430:	07f77713          	andi	a4,a4,127
    80000434:	97ba                	add	a5,a5,a4
    80000436:	4729                	li	a4,10
    80000438:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000043c:	00011797          	auipc	a5,0x11
    80000440:	92c7a023          	sw	a2,-1760(a5) # 80010d5c <cons+0x9c>
        wakeup(&cons.r);
    80000444:	00011517          	auipc	a0,0x11
    80000448:	91450513          	addi	a0,a0,-1772 # 80010d58 <cons+0x98>
    8000044c:	00002097          	auipc	ra,0x2
    80000450:	17e080e7          	jalr	382(ra) # 800025ca <wakeup>
    80000454:	b575                	j	80000300 <consoleintr+0x3c>

0000000080000456 <consoleinit>:

void
consoleinit(void)
{
    80000456:	1141                	addi	sp,sp,-16
    80000458:	e406                	sd	ra,8(sp)
    8000045a:	e022                	sd	s0,0(sp)
    8000045c:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000045e:	00008597          	auipc	a1,0x8
    80000462:	bb258593          	addi	a1,a1,-1102 # 80008010 <etext+0x10>
    80000466:	00011517          	auipc	a0,0x11
    8000046a:	85a50513          	addi	a0,a0,-1958 # 80010cc0 <cons>
    8000046e:	00000097          	auipc	ra,0x0
    80000472:	6ec080e7          	jalr	1772(ra) # 80000b5a <initlock>

  uartinit();
    80000476:	00000097          	auipc	ra,0x0
    8000047a:	330080e7          	jalr	816(ra) # 800007a6 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000047e:	00023797          	auipc	a5,0x23
    80000482:	c0a78793          	addi	a5,a5,-1014 # 80023088 <devsw>
    80000486:	00000717          	auipc	a4,0x0
    8000048a:	cde70713          	addi	a4,a4,-802 # 80000164 <consoleread>
    8000048e:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000490:	00000717          	auipc	a4,0x0
    80000494:	c7270713          	addi	a4,a4,-910 # 80000102 <consolewrite>
    80000498:	ef98                	sd	a4,24(a5)
}
    8000049a:	60a2                	ld	ra,8(sp)
    8000049c:	6402                	ld	s0,0(sp)
    8000049e:	0141                	addi	sp,sp,16
    800004a0:	8082                	ret

00000000800004a2 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004a2:	7179                	addi	sp,sp,-48
    800004a4:	f406                	sd	ra,40(sp)
    800004a6:	f022                	sd	s0,32(sp)
    800004a8:	ec26                	sd	s1,24(sp)
    800004aa:	e84a                	sd	s2,16(sp)
    800004ac:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004ae:	c219                	beqz	a2,800004b4 <printint+0x12>
    800004b0:	08054663          	bltz	a0,8000053c <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004b4:	2501                	sext.w	a0,a0
    800004b6:	4881                	li	a7,0
    800004b8:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004bc:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004be:	2581                	sext.w	a1,a1
    800004c0:	00008617          	auipc	a2,0x8
    800004c4:	b8060613          	addi	a2,a2,-1152 # 80008040 <digits>
    800004c8:	883a                	mv	a6,a4
    800004ca:	2705                	addiw	a4,a4,1
    800004cc:	02b577bb          	remuw	a5,a0,a1
    800004d0:	1782                	slli	a5,a5,0x20
    800004d2:	9381                	srli	a5,a5,0x20
    800004d4:	97b2                	add	a5,a5,a2
    800004d6:	0007c783          	lbu	a5,0(a5)
    800004da:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004de:	0005079b          	sext.w	a5,a0
    800004e2:	02b5553b          	divuw	a0,a0,a1
    800004e6:	0685                	addi	a3,a3,1
    800004e8:	feb7f0e3          	bgeu	a5,a1,800004c8 <printint+0x26>

  if(sign)
    800004ec:	00088b63          	beqz	a7,80000502 <printint+0x60>
    buf[i++] = '-';
    800004f0:	fe040793          	addi	a5,s0,-32
    800004f4:	973e                	add	a4,a4,a5
    800004f6:	02d00793          	li	a5,45
    800004fa:	fef70823          	sb	a5,-16(a4)
    800004fe:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80000502:	02e05763          	blez	a4,80000530 <printint+0x8e>
    80000506:	fd040793          	addi	a5,s0,-48
    8000050a:	00e784b3          	add	s1,a5,a4
    8000050e:	fff78913          	addi	s2,a5,-1
    80000512:	993a                	add	s2,s2,a4
    80000514:	377d                	addiw	a4,a4,-1
    80000516:	1702                	slli	a4,a4,0x20
    80000518:	9301                	srli	a4,a4,0x20
    8000051a:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000051e:	fff4c503          	lbu	a0,-1(s1)
    80000522:	00000097          	auipc	ra,0x0
    80000526:	d60080e7          	jalr	-672(ra) # 80000282 <consputc>
  while(--i >= 0)
    8000052a:	14fd                	addi	s1,s1,-1
    8000052c:	ff2499e3          	bne	s1,s2,8000051e <printint+0x7c>
}
    80000530:	70a2                	ld	ra,40(sp)
    80000532:	7402                	ld	s0,32(sp)
    80000534:	64e2                	ld	s1,24(sp)
    80000536:	6942                	ld	s2,16(sp)
    80000538:	6145                	addi	sp,sp,48
    8000053a:	8082                	ret
    x = -xx;
    8000053c:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000540:	4885                	li	a7,1
    x = -xx;
    80000542:	bf9d                	j	800004b8 <printint+0x16>

0000000080000544 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000544:	1101                	addi	sp,sp,-32
    80000546:	ec06                	sd	ra,24(sp)
    80000548:	e822                	sd	s0,16(sp)
    8000054a:	e426                	sd	s1,8(sp)
    8000054c:	1000                	addi	s0,sp,32
    8000054e:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000550:	00011797          	auipc	a5,0x11
    80000554:	8207a823          	sw	zero,-2000(a5) # 80010d80 <pr+0x18>
  printf("panic: ");
    80000558:	00008517          	auipc	a0,0x8
    8000055c:	ac050513          	addi	a0,a0,-1344 # 80008018 <etext+0x18>
    80000560:	00000097          	auipc	ra,0x0
    80000564:	02e080e7          	jalr	46(ra) # 8000058e <printf>
  printf(s);
    80000568:	8526                	mv	a0,s1
    8000056a:	00000097          	auipc	ra,0x0
    8000056e:	024080e7          	jalr	36(ra) # 8000058e <printf>
  printf("\n");
    80000572:	00008517          	auipc	a0,0x8
    80000576:	b5650513          	addi	a0,a0,-1194 # 800080c8 <digits+0x88>
    8000057a:	00000097          	auipc	ra,0x0
    8000057e:	014080e7          	jalr	20(ra) # 8000058e <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000582:	4785                	li	a5,1
    80000584:	00008717          	auipc	a4,0x8
    80000588:	5af72e23          	sw	a5,1468(a4) # 80008b40 <panicked>
  for(;;)
    8000058c:	a001                	j	8000058c <panic+0x48>

000000008000058e <printf>:
{
    8000058e:	7131                	addi	sp,sp,-192
    80000590:	fc86                	sd	ra,120(sp)
    80000592:	f8a2                	sd	s0,112(sp)
    80000594:	f4a6                	sd	s1,104(sp)
    80000596:	f0ca                	sd	s2,96(sp)
    80000598:	ecce                	sd	s3,88(sp)
    8000059a:	e8d2                	sd	s4,80(sp)
    8000059c:	e4d6                	sd	s5,72(sp)
    8000059e:	e0da                	sd	s6,64(sp)
    800005a0:	fc5e                	sd	s7,56(sp)
    800005a2:	f862                	sd	s8,48(sp)
    800005a4:	f466                	sd	s9,40(sp)
    800005a6:	f06a                	sd	s10,32(sp)
    800005a8:	ec6e                	sd	s11,24(sp)
    800005aa:	0100                	addi	s0,sp,128
    800005ac:	8a2a                	mv	s4,a0
    800005ae:	e40c                	sd	a1,8(s0)
    800005b0:	e810                	sd	a2,16(s0)
    800005b2:	ec14                	sd	a3,24(s0)
    800005b4:	f018                	sd	a4,32(s0)
    800005b6:	f41c                	sd	a5,40(s0)
    800005b8:	03043823          	sd	a6,48(s0)
    800005bc:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005c0:	00010d97          	auipc	s11,0x10
    800005c4:	7c0dad83          	lw	s11,1984(s11) # 80010d80 <pr+0x18>
  if(locking)
    800005c8:	020d9b63          	bnez	s11,800005fe <printf+0x70>
  if (fmt == 0)
    800005cc:	040a0263          	beqz	s4,80000610 <printf+0x82>
  va_start(ap, fmt);
    800005d0:	00840793          	addi	a5,s0,8
    800005d4:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d8:	000a4503          	lbu	a0,0(s4)
    800005dc:	16050263          	beqz	a0,80000740 <printf+0x1b2>
    800005e0:	4481                	li	s1,0
    if(c != '%'){
    800005e2:	02500a93          	li	s5,37
    switch(c){
    800005e6:	07000b13          	li	s6,112
  consputc('x');
    800005ea:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005ec:	00008b97          	auipc	s7,0x8
    800005f0:	a54b8b93          	addi	s7,s7,-1452 # 80008040 <digits>
    switch(c){
    800005f4:	07300c93          	li	s9,115
    800005f8:	06400c13          	li	s8,100
    800005fc:	a82d                	j	80000636 <printf+0xa8>
    acquire(&pr.lock);
    800005fe:	00010517          	auipc	a0,0x10
    80000602:	76a50513          	addi	a0,a0,1898 # 80010d68 <pr>
    80000606:	00000097          	auipc	ra,0x0
    8000060a:	5e4080e7          	jalr	1508(ra) # 80000bea <acquire>
    8000060e:	bf7d                	j	800005cc <printf+0x3e>
    panic("null fmt");
    80000610:	00008517          	auipc	a0,0x8
    80000614:	a1850513          	addi	a0,a0,-1512 # 80008028 <etext+0x28>
    80000618:	00000097          	auipc	ra,0x0
    8000061c:	f2c080e7          	jalr	-212(ra) # 80000544 <panic>
      consputc(c);
    80000620:	00000097          	auipc	ra,0x0
    80000624:	c62080e7          	jalr	-926(ra) # 80000282 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000628:	2485                	addiw	s1,s1,1
    8000062a:	009a07b3          	add	a5,s4,s1
    8000062e:	0007c503          	lbu	a0,0(a5)
    80000632:	10050763          	beqz	a0,80000740 <printf+0x1b2>
    if(c != '%'){
    80000636:	ff5515e3          	bne	a0,s5,80000620 <printf+0x92>
    c = fmt[++i] & 0xff;
    8000063a:	2485                	addiw	s1,s1,1
    8000063c:	009a07b3          	add	a5,s4,s1
    80000640:	0007c783          	lbu	a5,0(a5)
    80000644:	0007891b          	sext.w	s2,a5
    if(c == 0)
    80000648:	cfe5                	beqz	a5,80000740 <printf+0x1b2>
    switch(c){
    8000064a:	05678a63          	beq	a5,s6,8000069e <printf+0x110>
    8000064e:	02fb7663          	bgeu	s6,a5,8000067a <printf+0xec>
    80000652:	09978963          	beq	a5,s9,800006e4 <printf+0x156>
    80000656:	07800713          	li	a4,120
    8000065a:	0ce79863          	bne	a5,a4,8000072a <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    8000065e:	f8843783          	ld	a5,-120(s0)
    80000662:	00878713          	addi	a4,a5,8
    80000666:	f8e43423          	sd	a4,-120(s0)
    8000066a:	4605                	li	a2,1
    8000066c:	85ea                	mv	a1,s10
    8000066e:	4388                	lw	a0,0(a5)
    80000670:	00000097          	auipc	ra,0x0
    80000674:	e32080e7          	jalr	-462(ra) # 800004a2 <printint>
      break;
    80000678:	bf45                	j	80000628 <printf+0x9a>
    switch(c){
    8000067a:	0b578263          	beq	a5,s5,8000071e <printf+0x190>
    8000067e:	0b879663          	bne	a5,s8,8000072a <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    80000682:	f8843783          	ld	a5,-120(s0)
    80000686:	00878713          	addi	a4,a5,8
    8000068a:	f8e43423          	sd	a4,-120(s0)
    8000068e:	4605                	li	a2,1
    80000690:	45a9                	li	a1,10
    80000692:	4388                	lw	a0,0(a5)
    80000694:	00000097          	auipc	ra,0x0
    80000698:	e0e080e7          	jalr	-498(ra) # 800004a2 <printint>
      break;
    8000069c:	b771                	j	80000628 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    8000069e:	f8843783          	ld	a5,-120(s0)
    800006a2:	00878713          	addi	a4,a5,8
    800006a6:	f8e43423          	sd	a4,-120(s0)
    800006aa:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006ae:	03000513          	li	a0,48
    800006b2:	00000097          	auipc	ra,0x0
    800006b6:	bd0080e7          	jalr	-1072(ra) # 80000282 <consputc>
  consputc('x');
    800006ba:	07800513          	li	a0,120
    800006be:	00000097          	auipc	ra,0x0
    800006c2:	bc4080e7          	jalr	-1084(ra) # 80000282 <consputc>
    800006c6:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c8:	03c9d793          	srli	a5,s3,0x3c
    800006cc:	97de                	add	a5,a5,s7
    800006ce:	0007c503          	lbu	a0,0(a5)
    800006d2:	00000097          	auipc	ra,0x0
    800006d6:	bb0080e7          	jalr	-1104(ra) # 80000282 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006da:	0992                	slli	s3,s3,0x4
    800006dc:	397d                	addiw	s2,s2,-1
    800006de:	fe0915e3          	bnez	s2,800006c8 <printf+0x13a>
    800006e2:	b799                	j	80000628 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006e4:	f8843783          	ld	a5,-120(s0)
    800006e8:	00878713          	addi	a4,a5,8
    800006ec:	f8e43423          	sd	a4,-120(s0)
    800006f0:	0007b903          	ld	s2,0(a5)
    800006f4:	00090e63          	beqz	s2,80000710 <printf+0x182>
      for(; *s; s++)
    800006f8:	00094503          	lbu	a0,0(s2)
    800006fc:	d515                	beqz	a0,80000628 <printf+0x9a>
        consputc(*s);
    800006fe:	00000097          	auipc	ra,0x0
    80000702:	b84080e7          	jalr	-1148(ra) # 80000282 <consputc>
      for(; *s; s++)
    80000706:	0905                	addi	s2,s2,1
    80000708:	00094503          	lbu	a0,0(s2)
    8000070c:	f96d                	bnez	a0,800006fe <printf+0x170>
    8000070e:	bf29                	j	80000628 <printf+0x9a>
        s = "(null)";
    80000710:	00008917          	auipc	s2,0x8
    80000714:	91090913          	addi	s2,s2,-1776 # 80008020 <etext+0x20>
      for(; *s; s++)
    80000718:	02800513          	li	a0,40
    8000071c:	b7cd                	j	800006fe <printf+0x170>
      consputc('%');
    8000071e:	8556                	mv	a0,s5
    80000720:	00000097          	auipc	ra,0x0
    80000724:	b62080e7          	jalr	-1182(ra) # 80000282 <consputc>
      break;
    80000728:	b701                	j	80000628 <printf+0x9a>
      consputc('%');
    8000072a:	8556                	mv	a0,s5
    8000072c:	00000097          	auipc	ra,0x0
    80000730:	b56080e7          	jalr	-1194(ra) # 80000282 <consputc>
      consputc(c);
    80000734:	854a                	mv	a0,s2
    80000736:	00000097          	auipc	ra,0x0
    8000073a:	b4c080e7          	jalr	-1204(ra) # 80000282 <consputc>
      break;
    8000073e:	b5ed                	j	80000628 <printf+0x9a>
  if(locking)
    80000740:	020d9163          	bnez	s11,80000762 <printf+0x1d4>
}
    80000744:	70e6                	ld	ra,120(sp)
    80000746:	7446                	ld	s0,112(sp)
    80000748:	74a6                	ld	s1,104(sp)
    8000074a:	7906                	ld	s2,96(sp)
    8000074c:	69e6                	ld	s3,88(sp)
    8000074e:	6a46                	ld	s4,80(sp)
    80000750:	6aa6                	ld	s5,72(sp)
    80000752:	6b06                	ld	s6,64(sp)
    80000754:	7be2                	ld	s7,56(sp)
    80000756:	7c42                	ld	s8,48(sp)
    80000758:	7ca2                	ld	s9,40(sp)
    8000075a:	7d02                	ld	s10,32(sp)
    8000075c:	6de2                	ld	s11,24(sp)
    8000075e:	6129                	addi	sp,sp,192
    80000760:	8082                	ret
    release(&pr.lock);
    80000762:	00010517          	auipc	a0,0x10
    80000766:	60650513          	addi	a0,a0,1542 # 80010d68 <pr>
    8000076a:	00000097          	auipc	ra,0x0
    8000076e:	534080e7          	jalr	1332(ra) # 80000c9e <release>
}
    80000772:	bfc9                	j	80000744 <printf+0x1b6>

0000000080000774 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000774:	1101                	addi	sp,sp,-32
    80000776:	ec06                	sd	ra,24(sp)
    80000778:	e822                	sd	s0,16(sp)
    8000077a:	e426                	sd	s1,8(sp)
    8000077c:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000077e:	00010497          	auipc	s1,0x10
    80000782:	5ea48493          	addi	s1,s1,1514 # 80010d68 <pr>
    80000786:	00008597          	auipc	a1,0x8
    8000078a:	8b258593          	addi	a1,a1,-1870 # 80008038 <etext+0x38>
    8000078e:	8526                	mv	a0,s1
    80000790:	00000097          	auipc	ra,0x0
    80000794:	3ca080e7          	jalr	970(ra) # 80000b5a <initlock>
  pr.locking = 1;
    80000798:	4785                	li	a5,1
    8000079a:	cc9c                	sw	a5,24(s1)
}
    8000079c:	60e2                	ld	ra,24(sp)
    8000079e:	6442                	ld	s0,16(sp)
    800007a0:	64a2                	ld	s1,8(sp)
    800007a2:	6105                	addi	sp,sp,32
    800007a4:	8082                	ret

00000000800007a6 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007a6:	1141                	addi	sp,sp,-16
    800007a8:	e406                	sd	ra,8(sp)
    800007aa:	e022                	sd	s0,0(sp)
    800007ac:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007ae:	100007b7          	lui	a5,0x10000
    800007b2:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007b6:	f8000713          	li	a4,-128
    800007ba:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007be:	470d                	li	a4,3
    800007c0:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007c4:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007c8:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007cc:	469d                	li	a3,7
    800007ce:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007d2:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007d6:	00008597          	auipc	a1,0x8
    800007da:	88258593          	addi	a1,a1,-1918 # 80008058 <digits+0x18>
    800007de:	00010517          	auipc	a0,0x10
    800007e2:	5aa50513          	addi	a0,a0,1450 # 80010d88 <uart_tx_lock>
    800007e6:	00000097          	auipc	ra,0x0
    800007ea:	374080e7          	jalr	884(ra) # 80000b5a <initlock>
}
    800007ee:	60a2                	ld	ra,8(sp)
    800007f0:	6402                	ld	s0,0(sp)
    800007f2:	0141                	addi	sp,sp,16
    800007f4:	8082                	ret

00000000800007f6 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007f6:	1101                	addi	sp,sp,-32
    800007f8:	ec06                	sd	ra,24(sp)
    800007fa:	e822                	sd	s0,16(sp)
    800007fc:	e426                	sd	s1,8(sp)
    800007fe:	1000                	addi	s0,sp,32
    80000800:	84aa                	mv	s1,a0
  push_off();
    80000802:	00000097          	auipc	ra,0x0
    80000806:	39c080e7          	jalr	924(ra) # 80000b9e <push_off>

  if(panicked){
    8000080a:	00008797          	auipc	a5,0x8
    8000080e:	3367a783          	lw	a5,822(a5) # 80008b40 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000812:	10000737          	lui	a4,0x10000
  if(panicked){
    80000816:	c391                	beqz	a5,8000081a <uartputc_sync+0x24>
    for(;;)
    80000818:	a001                	j	80000818 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000081a:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000081e:	0ff7f793          	andi	a5,a5,255
    80000822:	0207f793          	andi	a5,a5,32
    80000826:	dbf5                	beqz	a5,8000081a <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000828:	0ff4f793          	andi	a5,s1,255
    8000082c:	10000737          	lui	a4,0x10000
    80000830:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    80000834:	00000097          	auipc	ra,0x0
    80000838:	40a080e7          	jalr	1034(ra) # 80000c3e <pop_off>
}
    8000083c:	60e2                	ld	ra,24(sp)
    8000083e:	6442                	ld	s0,16(sp)
    80000840:	64a2                	ld	s1,8(sp)
    80000842:	6105                	addi	sp,sp,32
    80000844:	8082                	ret

0000000080000846 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000846:	00008717          	auipc	a4,0x8
    8000084a:	30273703          	ld	a4,770(a4) # 80008b48 <uart_tx_r>
    8000084e:	00008797          	auipc	a5,0x8
    80000852:	3027b783          	ld	a5,770(a5) # 80008b50 <uart_tx_w>
    80000856:	06e78c63          	beq	a5,a4,800008ce <uartstart+0x88>
{
    8000085a:	7139                	addi	sp,sp,-64
    8000085c:	fc06                	sd	ra,56(sp)
    8000085e:	f822                	sd	s0,48(sp)
    80000860:	f426                	sd	s1,40(sp)
    80000862:	f04a                	sd	s2,32(sp)
    80000864:	ec4e                	sd	s3,24(sp)
    80000866:	e852                	sd	s4,16(sp)
    80000868:	e456                	sd	s5,8(sp)
    8000086a:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000086c:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000870:	00010a17          	auipc	s4,0x10
    80000874:	518a0a13          	addi	s4,s4,1304 # 80010d88 <uart_tx_lock>
    uart_tx_r += 1;
    80000878:	00008497          	auipc	s1,0x8
    8000087c:	2d048493          	addi	s1,s1,720 # 80008b48 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000880:	00008997          	auipc	s3,0x8
    80000884:	2d098993          	addi	s3,s3,720 # 80008b50 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000888:	00594783          	lbu	a5,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000088c:	0ff7f793          	andi	a5,a5,255
    80000890:	0207f793          	andi	a5,a5,32
    80000894:	c785                	beqz	a5,800008bc <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000896:	01f77793          	andi	a5,a4,31
    8000089a:	97d2                	add	a5,a5,s4
    8000089c:	0187ca83          	lbu	s5,24(a5)
    uart_tx_r += 1;
    800008a0:	0705                	addi	a4,a4,1
    800008a2:	e098                	sd	a4,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008a4:	8526                	mv	a0,s1
    800008a6:	00002097          	auipc	ra,0x2
    800008aa:	d24080e7          	jalr	-732(ra) # 800025ca <wakeup>
    
    WriteReg(THR, c);
    800008ae:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008b2:	6098                	ld	a4,0(s1)
    800008b4:	0009b783          	ld	a5,0(s3)
    800008b8:	fce798e3          	bne	a5,a4,80000888 <uartstart+0x42>
  }
}
    800008bc:	70e2                	ld	ra,56(sp)
    800008be:	7442                	ld	s0,48(sp)
    800008c0:	74a2                	ld	s1,40(sp)
    800008c2:	7902                	ld	s2,32(sp)
    800008c4:	69e2                	ld	s3,24(sp)
    800008c6:	6a42                	ld	s4,16(sp)
    800008c8:	6aa2                	ld	s5,8(sp)
    800008ca:	6121                	addi	sp,sp,64
    800008cc:	8082                	ret
    800008ce:	8082                	ret

00000000800008d0 <uartputc>:
{
    800008d0:	7179                	addi	sp,sp,-48
    800008d2:	f406                	sd	ra,40(sp)
    800008d4:	f022                	sd	s0,32(sp)
    800008d6:	ec26                	sd	s1,24(sp)
    800008d8:	e84a                	sd	s2,16(sp)
    800008da:	e44e                	sd	s3,8(sp)
    800008dc:	e052                	sd	s4,0(sp)
    800008de:	1800                	addi	s0,sp,48
    800008e0:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    800008e2:	00010517          	auipc	a0,0x10
    800008e6:	4a650513          	addi	a0,a0,1190 # 80010d88 <uart_tx_lock>
    800008ea:	00000097          	auipc	ra,0x0
    800008ee:	300080e7          	jalr	768(ra) # 80000bea <acquire>
  if(panicked){
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	24e7a783          	lw	a5,590(a5) # 80008b40 <panicked>
    800008fa:	e7c9                	bnez	a5,80000984 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fc:	00008797          	auipc	a5,0x8
    80000900:	2547b783          	ld	a5,596(a5) # 80008b50 <uart_tx_w>
    80000904:	00008717          	auipc	a4,0x8
    80000908:	24473703          	ld	a4,580(a4) # 80008b48 <uart_tx_r>
    8000090c:	02070713          	addi	a4,a4,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000910:	00010a17          	auipc	s4,0x10
    80000914:	478a0a13          	addi	s4,s4,1144 # 80010d88 <uart_tx_lock>
    80000918:	00008497          	auipc	s1,0x8
    8000091c:	23048493          	addi	s1,s1,560 # 80008b48 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000920:	00008917          	auipc	s2,0x8
    80000924:	23090913          	addi	s2,s2,560 # 80008b50 <uart_tx_w>
    80000928:	00f71f63          	bne	a4,a5,80000946 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000092c:	85d2                	mv	a1,s4
    8000092e:	8526                	mv	a0,s1
    80000930:	00002097          	auipc	ra,0x2
    80000934:	aea080e7          	jalr	-1302(ra) # 8000241a <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000938:	00093783          	ld	a5,0(s2)
    8000093c:	6098                	ld	a4,0(s1)
    8000093e:	02070713          	addi	a4,a4,32
    80000942:	fef705e3          	beq	a4,a5,8000092c <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000946:	00010497          	auipc	s1,0x10
    8000094a:	44248493          	addi	s1,s1,1090 # 80010d88 <uart_tx_lock>
    8000094e:	01f7f713          	andi	a4,a5,31
    80000952:	9726                	add	a4,a4,s1
    80000954:	01370c23          	sb	s3,24(a4)
  uart_tx_w += 1;
    80000958:	0785                	addi	a5,a5,1
    8000095a:	00008717          	auipc	a4,0x8
    8000095e:	1ef73b23          	sd	a5,502(a4) # 80008b50 <uart_tx_w>
  uartstart();
    80000962:	00000097          	auipc	ra,0x0
    80000966:	ee4080e7          	jalr	-284(ra) # 80000846 <uartstart>
  release(&uart_tx_lock);
    8000096a:	8526                	mv	a0,s1
    8000096c:	00000097          	auipc	ra,0x0
    80000970:	332080e7          	jalr	818(ra) # 80000c9e <release>
}
    80000974:	70a2                	ld	ra,40(sp)
    80000976:	7402                	ld	s0,32(sp)
    80000978:	64e2                	ld	s1,24(sp)
    8000097a:	6942                	ld	s2,16(sp)
    8000097c:	69a2                	ld	s3,8(sp)
    8000097e:	6a02                	ld	s4,0(sp)
    80000980:	6145                	addi	sp,sp,48
    80000982:	8082                	ret
    for(;;)
    80000984:	a001                	j	80000984 <uartputc+0xb4>

0000000080000986 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000986:	1141                	addi	sp,sp,-16
    80000988:	e422                	sd	s0,8(sp)
    8000098a:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    8000098c:	100007b7          	lui	a5,0x10000
    80000990:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000994:	8b85                	andi	a5,a5,1
    80000996:	cb91                	beqz	a5,800009aa <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000998:	100007b7          	lui	a5,0x10000
    8000099c:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800009a0:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    800009a4:	6422                	ld	s0,8(sp)
    800009a6:	0141                	addi	sp,sp,16
    800009a8:	8082                	ret
    return -1;
    800009aa:	557d                	li	a0,-1
    800009ac:	bfe5                	j	800009a4 <uartgetc+0x1e>

00000000800009ae <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009ae:	1101                	addi	sp,sp,-32
    800009b0:	ec06                	sd	ra,24(sp)
    800009b2:	e822                	sd	s0,16(sp)
    800009b4:	e426                	sd	s1,8(sp)
    800009b6:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009b8:	54fd                	li	s1,-1
    int c = uartgetc();
    800009ba:	00000097          	auipc	ra,0x0
    800009be:	fcc080e7          	jalr	-52(ra) # 80000986 <uartgetc>
    if(c == -1)
    800009c2:	00950763          	beq	a0,s1,800009d0 <uartintr+0x22>
      break;
    consoleintr(c);
    800009c6:	00000097          	auipc	ra,0x0
    800009ca:	8fe080e7          	jalr	-1794(ra) # 800002c4 <consoleintr>
  while(1){
    800009ce:	b7f5                	j	800009ba <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009d0:	00010497          	auipc	s1,0x10
    800009d4:	3b848493          	addi	s1,s1,952 # 80010d88 <uart_tx_lock>
    800009d8:	8526                	mv	a0,s1
    800009da:	00000097          	auipc	ra,0x0
    800009de:	210080e7          	jalr	528(ra) # 80000bea <acquire>
  uartstart();
    800009e2:	00000097          	auipc	ra,0x0
    800009e6:	e64080e7          	jalr	-412(ra) # 80000846 <uartstart>
  release(&uart_tx_lock);
    800009ea:	8526                	mv	a0,s1
    800009ec:	00000097          	auipc	ra,0x0
    800009f0:	2b2080e7          	jalr	690(ra) # 80000c9e <release>
}
    800009f4:	60e2                	ld	ra,24(sp)
    800009f6:	6442                	ld	s0,16(sp)
    800009f8:	64a2                	ld	s1,8(sp)
    800009fa:	6105                	addi	sp,sp,32
    800009fc:	8082                	ret

00000000800009fe <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009fe:	1101                	addi	sp,sp,-32
    80000a00:	ec06                	sd	ra,24(sp)
    80000a02:	e822                	sd	s0,16(sp)
    80000a04:	e426                	sd	s1,8(sp)
    80000a06:	e04a                	sd	s2,0(sp)
    80000a08:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a0a:	03451793          	slli	a5,a0,0x34
    80000a0e:	ebb9                	bnez	a5,80000a64 <kfree+0x66>
    80000a10:	84aa                	mv	s1,a0
    80000a12:	00024797          	auipc	a5,0x24
    80000a16:	80e78793          	addi	a5,a5,-2034 # 80024220 <end>
    80000a1a:	04f56563          	bltu	a0,a5,80000a64 <kfree+0x66>
    80000a1e:	47c5                	li	a5,17
    80000a20:	07ee                	slli	a5,a5,0x1b
    80000a22:	04f57163          	bgeu	a0,a5,80000a64 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a26:	6605                	lui	a2,0x1
    80000a28:	4585                	li	a1,1
    80000a2a:	00000097          	auipc	ra,0x0
    80000a2e:	2bc080e7          	jalr	700(ra) # 80000ce6 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a32:	00010917          	auipc	s2,0x10
    80000a36:	38e90913          	addi	s2,s2,910 # 80010dc0 <kmem>
    80000a3a:	854a                	mv	a0,s2
    80000a3c:	00000097          	auipc	ra,0x0
    80000a40:	1ae080e7          	jalr	430(ra) # 80000bea <acquire>
  r->next = kmem.freelist;
    80000a44:	01893783          	ld	a5,24(s2)
    80000a48:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a4a:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a4e:	854a                	mv	a0,s2
    80000a50:	00000097          	auipc	ra,0x0
    80000a54:	24e080e7          	jalr	590(ra) # 80000c9e <release>
}
    80000a58:	60e2                	ld	ra,24(sp)
    80000a5a:	6442                	ld	s0,16(sp)
    80000a5c:	64a2                	ld	s1,8(sp)
    80000a5e:	6902                	ld	s2,0(sp)
    80000a60:	6105                	addi	sp,sp,32
    80000a62:	8082                	ret
    panic("kfree");
    80000a64:	00007517          	auipc	a0,0x7
    80000a68:	5fc50513          	addi	a0,a0,1532 # 80008060 <digits+0x20>
    80000a6c:	00000097          	auipc	ra,0x0
    80000a70:	ad8080e7          	jalr	-1320(ra) # 80000544 <panic>

0000000080000a74 <freerange>:
{
    80000a74:	7179                	addi	sp,sp,-48
    80000a76:	f406                	sd	ra,40(sp)
    80000a78:	f022                	sd	s0,32(sp)
    80000a7a:	ec26                	sd	s1,24(sp)
    80000a7c:	e84a                	sd	s2,16(sp)
    80000a7e:	e44e                	sd	s3,8(sp)
    80000a80:	e052                	sd	s4,0(sp)
    80000a82:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a84:	6785                	lui	a5,0x1
    80000a86:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a8a:	94aa                	add	s1,s1,a0
    80000a8c:	757d                	lui	a0,0xfffff
    80000a8e:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a90:	94be                	add	s1,s1,a5
    80000a92:	0095ee63          	bltu	a1,s1,80000aae <freerange+0x3a>
    80000a96:	892e                	mv	s2,a1
    kfree(p);
    80000a98:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a9a:	6985                	lui	s3,0x1
    kfree(p);
    80000a9c:	01448533          	add	a0,s1,s4
    80000aa0:	00000097          	auipc	ra,0x0
    80000aa4:	f5e080e7          	jalr	-162(ra) # 800009fe <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aa8:	94ce                	add	s1,s1,s3
    80000aaa:	fe9979e3          	bgeu	s2,s1,80000a9c <freerange+0x28>
}
    80000aae:	70a2                	ld	ra,40(sp)
    80000ab0:	7402                	ld	s0,32(sp)
    80000ab2:	64e2                	ld	s1,24(sp)
    80000ab4:	6942                	ld	s2,16(sp)
    80000ab6:	69a2                	ld	s3,8(sp)
    80000ab8:	6a02                	ld	s4,0(sp)
    80000aba:	6145                	addi	sp,sp,48
    80000abc:	8082                	ret

0000000080000abe <kinit>:
{
    80000abe:	1141                	addi	sp,sp,-16
    80000ac0:	e406                	sd	ra,8(sp)
    80000ac2:	e022                	sd	s0,0(sp)
    80000ac4:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ac6:	00007597          	auipc	a1,0x7
    80000aca:	5a258593          	addi	a1,a1,1442 # 80008068 <digits+0x28>
    80000ace:	00010517          	auipc	a0,0x10
    80000ad2:	2f250513          	addi	a0,a0,754 # 80010dc0 <kmem>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	084080e7          	jalr	132(ra) # 80000b5a <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ade:	45c5                	li	a1,17
    80000ae0:	05ee                	slli	a1,a1,0x1b
    80000ae2:	00023517          	auipc	a0,0x23
    80000ae6:	73e50513          	addi	a0,a0,1854 # 80024220 <end>
    80000aea:	00000097          	auipc	ra,0x0
    80000aee:	f8a080e7          	jalr	-118(ra) # 80000a74 <freerange>
}
    80000af2:	60a2                	ld	ra,8(sp)
    80000af4:	6402                	ld	s0,0(sp)
    80000af6:	0141                	addi	sp,sp,16
    80000af8:	8082                	ret

0000000080000afa <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000afa:	1101                	addi	sp,sp,-32
    80000afc:	ec06                	sd	ra,24(sp)
    80000afe:	e822                	sd	s0,16(sp)
    80000b00:	e426                	sd	s1,8(sp)
    80000b02:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b04:	00010497          	auipc	s1,0x10
    80000b08:	2bc48493          	addi	s1,s1,700 # 80010dc0 <kmem>
    80000b0c:	8526                	mv	a0,s1
    80000b0e:	00000097          	auipc	ra,0x0
    80000b12:	0dc080e7          	jalr	220(ra) # 80000bea <acquire>
  r = kmem.freelist;
    80000b16:	6c84                	ld	s1,24(s1)
  if(r)
    80000b18:	c885                	beqz	s1,80000b48 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b1a:	609c                	ld	a5,0(s1)
    80000b1c:	00010517          	auipc	a0,0x10
    80000b20:	2a450513          	addi	a0,a0,676 # 80010dc0 <kmem>
    80000b24:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b26:	00000097          	auipc	ra,0x0
    80000b2a:	178080e7          	jalr	376(ra) # 80000c9e <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b2e:	6605                	lui	a2,0x1
    80000b30:	4595                	li	a1,5
    80000b32:	8526                	mv	a0,s1
    80000b34:	00000097          	auipc	ra,0x0
    80000b38:	1b2080e7          	jalr	434(ra) # 80000ce6 <memset>
  return (void*)r;
}
    80000b3c:	8526                	mv	a0,s1
    80000b3e:	60e2                	ld	ra,24(sp)
    80000b40:	6442                	ld	s0,16(sp)
    80000b42:	64a2                	ld	s1,8(sp)
    80000b44:	6105                	addi	sp,sp,32
    80000b46:	8082                	ret
  release(&kmem.lock);
    80000b48:	00010517          	auipc	a0,0x10
    80000b4c:	27850513          	addi	a0,a0,632 # 80010dc0 <kmem>
    80000b50:	00000097          	auipc	ra,0x0
    80000b54:	14e080e7          	jalr	334(ra) # 80000c9e <release>
  if(r)
    80000b58:	b7d5                	j	80000b3c <kalloc+0x42>

0000000080000b5a <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b5a:	1141                	addi	sp,sp,-16
    80000b5c:	e422                	sd	s0,8(sp)
    80000b5e:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b60:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b62:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b66:	00053823          	sd	zero,16(a0)
}
    80000b6a:	6422                	ld	s0,8(sp)
    80000b6c:	0141                	addi	sp,sp,16
    80000b6e:	8082                	ret

0000000080000b70 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b70:	411c                	lw	a5,0(a0)
    80000b72:	e399                	bnez	a5,80000b78 <holding+0x8>
    80000b74:	4501                	li	a0,0
  return r;
}
    80000b76:	8082                	ret
{
    80000b78:	1101                	addi	sp,sp,-32
    80000b7a:	ec06                	sd	ra,24(sp)
    80000b7c:	e822                	sd	s0,16(sp)
    80000b7e:	e426                	sd	s1,8(sp)
    80000b80:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b82:	6904                	ld	s1,16(a0)
    80000b84:	00001097          	auipc	ra,0x1
    80000b88:	e26080e7          	jalr	-474(ra) # 800019aa <mycpu>
    80000b8c:	40a48533          	sub	a0,s1,a0
    80000b90:	00153513          	seqz	a0,a0
}
    80000b94:	60e2                	ld	ra,24(sp)
    80000b96:	6442                	ld	s0,16(sp)
    80000b98:	64a2                	ld	s1,8(sp)
    80000b9a:	6105                	addi	sp,sp,32
    80000b9c:	8082                	ret

0000000080000b9e <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b9e:	1101                	addi	sp,sp,-32
    80000ba0:	ec06                	sd	ra,24(sp)
    80000ba2:	e822                	sd	s0,16(sp)
    80000ba4:	e426                	sd	s1,8(sp)
    80000ba6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000ba8:	100024f3          	csrr	s1,sstatus
    80000bac:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bb0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bb2:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bb6:	00001097          	auipc	ra,0x1
    80000bba:	df4080e7          	jalr	-524(ra) # 800019aa <mycpu>
    80000bbe:	5d3c                	lw	a5,120(a0)
    80000bc0:	cf89                	beqz	a5,80000bda <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bc2:	00001097          	auipc	ra,0x1
    80000bc6:	de8080e7          	jalr	-536(ra) # 800019aa <mycpu>
    80000bca:	5d3c                	lw	a5,120(a0)
    80000bcc:	2785                	addiw	a5,a5,1
    80000bce:	dd3c                	sw	a5,120(a0)
}
    80000bd0:	60e2                	ld	ra,24(sp)
    80000bd2:	6442                	ld	s0,16(sp)
    80000bd4:	64a2                	ld	s1,8(sp)
    80000bd6:	6105                	addi	sp,sp,32
    80000bd8:	8082                	ret
    mycpu()->intena = old;
    80000bda:	00001097          	auipc	ra,0x1
    80000bde:	dd0080e7          	jalr	-560(ra) # 800019aa <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000be2:	8085                	srli	s1,s1,0x1
    80000be4:	8885                	andi	s1,s1,1
    80000be6:	dd64                	sw	s1,124(a0)
    80000be8:	bfe9                	j	80000bc2 <push_off+0x24>

0000000080000bea <acquire>:
{
    80000bea:	1101                	addi	sp,sp,-32
    80000bec:	ec06                	sd	ra,24(sp)
    80000bee:	e822                	sd	s0,16(sp)
    80000bf0:	e426                	sd	s1,8(sp)
    80000bf2:	1000                	addi	s0,sp,32
    80000bf4:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bf6:	00000097          	auipc	ra,0x0
    80000bfa:	fa8080e7          	jalr	-88(ra) # 80000b9e <push_off>
  if(holding(lk))
    80000bfe:	8526                	mv	a0,s1
    80000c00:	00000097          	auipc	ra,0x0
    80000c04:	f70080e7          	jalr	-144(ra) # 80000b70 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c08:	4705                	li	a4,1
  if(holding(lk))
    80000c0a:	e115                	bnez	a0,80000c2e <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0c:	87ba                	mv	a5,a4
    80000c0e:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c12:	2781                	sext.w	a5,a5
    80000c14:	ffe5                	bnez	a5,80000c0c <acquire+0x22>
  __sync_synchronize();
    80000c16:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c1a:	00001097          	auipc	ra,0x1
    80000c1e:	d90080e7          	jalr	-624(ra) # 800019aa <mycpu>
    80000c22:	e888                	sd	a0,16(s1)
}
    80000c24:	60e2                	ld	ra,24(sp)
    80000c26:	6442                	ld	s0,16(sp)
    80000c28:	64a2                	ld	s1,8(sp)
    80000c2a:	6105                	addi	sp,sp,32
    80000c2c:	8082                	ret
    panic("acquire");
    80000c2e:	00007517          	auipc	a0,0x7
    80000c32:	44250513          	addi	a0,a0,1090 # 80008070 <digits+0x30>
    80000c36:	00000097          	auipc	ra,0x0
    80000c3a:	90e080e7          	jalr	-1778(ra) # 80000544 <panic>

0000000080000c3e <pop_off>:

void
pop_off(void)
{
    80000c3e:	1141                	addi	sp,sp,-16
    80000c40:	e406                	sd	ra,8(sp)
    80000c42:	e022                	sd	s0,0(sp)
    80000c44:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c46:	00001097          	auipc	ra,0x1
    80000c4a:	d64080e7          	jalr	-668(ra) # 800019aa <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c4e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c52:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c54:	e78d                	bnez	a5,80000c7e <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c56:	5d3c                	lw	a5,120(a0)
    80000c58:	02f05b63          	blez	a5,80000c8e <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c5c:	37fd                	addiw	a5,a5,-1
    80000c5e:	0007871b          	sext.w	a4,a5
    80000c62:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c64:	eb09                	bnez	a4,80000c76 <pop_off+0x38>
    80000c66:	5d7c                	lw	a5,124(a0)
    80000c68:	c799                	beqz	a5,80000c76 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c6a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c6e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c72:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c76:	60a2                	ld	ra,8(sp)
    80000c78:	6402                	ld	s0,0(sp)
    80000c7a:	0141                	addi	sp,sp,16
    80000c7c:	8082                	ret
    panic("pop_off - interruptible");
    80000c7e:	00007517          	auipc	a0,0x7
    80000c82:	3fa50513          	addi	a0,a0,1018 # 80008078 <digits+0x38>
    80000c86:	00000097          	auipc	ra,0x0
    80000c8a:	8be080e7          	jalr	-1858(ra) # 80000544 <panic>
    panic("pop_off");
    80000c8e:	00007517          	auipc	a0,0x7
    80000c92:	40250513          	addi	a0,a0,1026 # 80008090 <digits+0x50>
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	8ae080e7          	jalr	-1874(ra) # 80000544 <panic>

0000000080000c9e <release>:
{
    80000c9e:	1101                	addi	sp,sp,-32
    80000ca0:	ec06                	sd	ra,24(sp)
    80000ca2:	e822                	sd	s0,16(sp)
    80000ca4:	e426                	sd	s1,8(sp)
    80000ca6:	1000                	addi	s0,sp,32
    80000ca8:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000caa:	00000097          	auipc	ra,0x0
    80000cae:	ec6080e7          	jalr	-314(ra) # 80000b70 <holding>
    80000cb2:	c115                	beqz	a0,80000cd6 <release+0x38>
  lk->cpu = 0;
    80000cb4:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cb8:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000cbc:	0f50000f          	fence	iorw,ow
    80000cc0:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cc4:	00000097          	auipc	ra,0x0
    80000cc8:	f7a080e7          	jalr	-134(ra) # 80000c3e <pop_off>
}
    80000ccc:	60e2                	ld	ra,24(sp)
    80000cce:	6442                	ld	s0,16(sp)
    80000cd0:	64a2                	ld	s1,8(sp)
    80000cd2:	6105                	addi	sp,sp,32
    80000cd4:	8082                	ret
    panic("release");
    80000cd6:	00007517          	auipc	a0,0x7
    80000cda:	3c250513          	addi	a0,a0,962 # 80008098 <digits+0x58>
    80000cde:	00000097          	auipc	ra,0x0
    80000ce2:	866080e7          	jalr	-1946(ra) # 80000544 <panic>

0000000080000ce6 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ce6:	1141                	addi	sp,sp,-16
    80000ce8:	e422                	sd	s0,8(sp)
    80000cea:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cec:	ce09                	beqz	a2,80000d06 <memset+0x20>
    80000cee:	87aa                	mv	a5,a0
    80000cf0:	fff6071b          	addiw	a4,a2,-1
    80000cf4:	1702                	slli	a4,a4,0x20
    80000cf6:	9301                	srli	a4,a4,0x20
    80000cf8:	0705                	addi	a4,a4,1
    80000cfa:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000cfc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d00:	0785                	addi	a5,a5,1
    80000d02:	fee79de3          	bne	a5,a4,80000cfc <memset+0x16>
  }
  return dst;
}
    80000d06:	6422                	ld	s0,8(sp)
    80000d08:	0141                	addi	sp,sp,16
    80000d0a:	8082                	ret

0000000080000d0c <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d0c:	1141                	addi	sp,sp,-16
    80000d0e:	e422                	sd	s0,8(sp)
    80000d10:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d12:	ca05                	beqz	a2,80000d42 <memcmp+0x36>
    80000d14:	fff6069b          	addiw	a3,a2,-1
    80000d18:	1682                	slli	a3,a3,0x20
    80000d1a:	9281                	srli	a3,a3,0x20
    80000d1c:	0685                	addi	a3,a3,1
    80000d1e:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d20:	00054783          	lbu	a5,0(a0)
    80000d24:	0005c703          	lbu	a4,0(a1)
    80000d28:	00e79863          	bne	a5,a4,80000d38 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d2c:	0505                	addi	a0,a0,1
    80000d2e:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d30:	fed518e3          	bne	a0,a3,80000d20 <memcmp+0x14>
  }

  return 0;
    80000d34:	4501                	li	a0,0
    80000d36:	a019                	j	80000d3c <memcmp+0x30>
      return *s1 - *s2;
    80000d38:	40e7853b          	subw	a0,a5,a4
}
    80000d3c:	6422                	ld	s0,8(sp)
    80000d3e:	0141                	addi	sp,sp,16
    80000d40:	8082                	ret
  return 0;
    80000d42:	4501                	li	a0,0
    80000d44:	bfe5                	j	80000d3c <memcmp+0x30>

0000000080000d46 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d46:	1141                	addi	sp,sp,-16
    80000d48:	e422                	sd	s0,8(sp)
    80000d4a:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d4c:	ca0d                	beqz	a2,80000d7e <memmove+0x38>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d4e:	00a5f963          	bgeu	a1,a0,80000d60 <memmove+0x1a>
    80000d52:	02061693          	slli	a3,a2,0x20
    80000d56:	9281                	srli	a3,a3,0x20
    80000d58:	00d58733          	add	a4,a1,a3
    80000d5c:	02e56463          	bltu	a0,a4,80000d84 <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d60:	fff6079b          	addiw	a5,a2,-1
    80000d64:	1782                	slli	a5,a5,0x20
    80000d66:	9381                	srli	a5,a5,0x20
    80000d68:	0785                	addi	a5,a5,1
    80000d6a:	97ae                	add	a5,a5,a1
    80000d6c:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d6e:	0585                	addi	a1,a1,1
    80000d70:	0705                	addi	a4,a4,1
    80000d72:	fff5c683          	lbu	a3,-1(a1)
    80000d76:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d7a:	fef59ae3          	bne	a1,a5,80000d6e <memmove+0x28>

  return dst;
}
    80000d7e:	6422                	ld	s0,8(sp)
    80000d80:	0141                	addi	sp,sp,16
    80000d82:	8082                	ret
    d += n;
    80000d84:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d86:	fff6079b          	addiw	a5,a2,-1
    80000d8a:	1782                	slli	a5,a5,0x20
    80000d8c:	9381                	srli	a5,a5,0x20
    80000d8e:	fff7c793          	not	a5,a5
    80000d92:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d94:	177d                	addi	a4,a4,-1
    80000d96:	16fd                	addi	a3,a3,-1
    80000d98:	00074603          	lbu	a2,0(a4)
    80000d9c:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000da0:	fef71ae3          	bne	a4,a5,80000d94 <memmove+0x4e>
    80000da4:	bfe9                	j	80000d7e <memmove+0x38>

0000000080000da6 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000da6:	1141                	addi	sp,sp,-16
    80000da8:	e406                	sd	ra,8(sp)
    80000daa:	e022                	sd	s0,0(sp)
    80000dac:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000dae:	00000097          	auipc	ra,0x0
    80000db2:	f98080e7          	jalr	-104(ra) # 80000d46 <memmove>
}
    80000db6:	60a2                	ld	ra,8(sp)
    80000db8:	6402                	ld	s0,0(sp)
    80000dba:	0141                	addi	sp,sp,16
    80000dbc:	8082                	ret

0000000080000dbe <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000dbe:	1141                	addi	sp,sp,-16
    80000dc0:	e422                	sd	s0,8(sp)
    80000dc2:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dc4:	ce11                	beqz	a2,80000de0 <strncmp+0x22>
    80000dc6:	00054783          	lbu	a5,0(a0)
    80000dca:	cf89                	beqz	a5,80000de4 <strncmp+0x26>
    80000dcc:	0005c703          	lbu	a4,0(a1)
    80000dd0:	00f71a63          	bne	a4,a5,80000de4 <strncmp+0x26>
    n--, p++, q++;
    80000dd4:	367d                	addiw	a2,a2,-1
    80000dd6:	0505                	addi	a0,a0,1
    80000dd8:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dda:	f675                	bnez	a2,80000dc6 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000ddc:	4501                	li	a0,0
    80000dde:	a809                	j	80000df0 <strncmp+0x32>
    80000de0:	4501                	li	a0,0
    80000de2:	a039                	j	80000df0 <strncmp+0x32>
  if(n == 0)
    80000de4:	ca09                	beqz	a2,80000df6 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000de6:	00054503          	lbu	a0,0(a0)
    80000dea:	0005c783          	lbu	a5,0(a1)
    80000dee:	9d1d                	subw	a0,a0,a5
}
    80000df0:	6422                	ld	s0,8(sp)
    80000df2:	0141                	addi	sp,sp,16
    80000df4:	8082                	ret
    return 0;
    80000df6:	4501                	li	a0,0
    80000df8:	bfe5                	j	80000df0 <strncmp+0x32>

0000000080000dfa <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dfa:	1141                	addi	sp,sp,-16
    80000dfc:	e422                	sd	s0,8(sp)
    80000dfe:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e00:	872a                	mv	a4,a0
    80000e02:	8832                	mv	a6,a2
    80000e04:	367d                	addiw	a2,a2,-1
    80000e06:	01005963          	blez	a6,80000e18 <strncpy+0x1e>
    80000e0a:	0705                	addi	a4,a4,1
    80000e0c:	0005c783          	lbu	a5,0(a1)
    80000e10:	fef70fa3          	sb	a5,-1(a4)
    80000e14:	0585                	addi	a1,a1,1
    80000e16:	f7f5                	bnez	a5,80000e02 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e18:	00c05d63          	blez	a2,80000e32 <strncpy+0x38>
    80000e1c:	86ba                	mv	a3,a4
    *s++ = 0;
    80000e1e:	0685                	addi	a3,a3,1
    80000e20:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e24:	fff6c793          	not	a5,a3
    80000e28:	9fb9                	addw	a5,a5,a4
    80000e2a:	010787bb          	addw	a5,a5,a6
    80000e2e:	fef048e3          	bgtz	a5,80000e1e <strncpy+0x24>
  return os;
}
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret

0000000080000e38 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e38:	1141                	addi	sp,sp,-16
    80000e3a:	e422                	sd	s0,8(sp)
    80000e3c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e3e:	02c05363          	blez	a2,80000e64 <safestrcpy+0x2c>
    80000e42:	fff6069b          	addiw	a3,a2,-1
    80000e46:	1682                	slli	a3,a3,0x20
    80000e48:	9281                	srli	a3,a3,0x20
    80000e4a:	96ae                	add	a3,a3,a1
    80000e4c:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e4e:	00d58963          	beq	a1,a3,80000e60 <safestrcpy+0x28>
    80000e52:	0585                	addi	a1,a1,1
    80000e54:	0785                	addi	a5,a5,1
    80000e56:	fff5c703          	lbu	a4,-1(a1)
    80000e5a:	fee78fa3          	sb	a4,-1(a5)
    80000e5e:	fb65                	bnez	a4,80000e4e <safestrcpy+0x16>
    ;
  *s = 0;
    80000e60:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e64:	6422                	ld	s0,8(sp)
    80000e66:	0141                	addi	sp,sp,16
    80000e68:	8082                	ret

0000000080000e6a <strlen>:

int
strlen(const char *s)
{
    80000e6a:	1141                	addi	sp,sp,-16
    80000e6c:	e422                	sd	s0,8(sp)
    80000e6e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e70:	00054783          	lbu	a5,0(a0)
    80000e74:	cf91                	beqz	a5,80000e90 <strlen+0x26>
    80000e76:	0505                	addi	a0,a0,1
    80000e78:	87aa                	mv	a5,a0
    80000e7a:	4685                	li	a3,1
    80000e7c:	9e89                	subw	a3,a3,a0
    80000e7e:	00f6853b          	addw	a0,a3,a5
    80000e82:	0785                	addi	a5,a5,1
    80000e84:	fff7c703          	lbu	a4,-1(a5)
    80000e88:	fb7d                	bnez	a4,80000e7e <strlen+0x14>
    ;
  return n;
}
    80000e8a:	6422                	ld	s0,8(sp)
    80000e8c:	0141                	addi	sp,sp,16
    80000e8e:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e90:	4501                	li	a0,0
    80000e92:	bfe5                	j	80000e8a <strlen+0x20>

0000000080000e94 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e94:	1141                	addi	sp,sp,-16
    80000e96:	e406                	sd	ra,8(sp)
    80000e98:	e022                	sd	s0,0(sp)
    80000e9a:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e9c:	00001097          	auipc	ra,0x1
    80000ea0:	afe080e7          	jalr	-1282(ra) # 8000199a <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000ea4:	00008717          	auipc	a4,0x8
    80000ea8:	cb470713          	addi	a4,a4,-844 # 80008b58 <started>
  if(cpuid() == 0){
    80000eac:	c139                	beqz	a0,80000ef2 <main+0x5e>
    while(started == 0)
    80000eae:	431c                	lw	a5,0(a4)
    80000eb0:	2781                	sext.w	a5,a5
    80000eb2:	dff5                	beqz	a5,80000eae <main+0x1a>
      ;
    __sync_synchronize();
    80000eb4:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000eb8:	00001097          	auipc	ra,0x1
    80000ebc:	ae2080e7          	jalr	-1310(ra) # 8000199a <cpuid>
    80000ec0:	85aa                	mv	a1,a0
    80000ec2:	00007517          	auipc	a0,0x7
    80000ec6:	1f650513          	addi	a0,a0,502 # 800080b8 <digits+0x78>
    80000eca:	fffff097          	auipc	ra,0xfffff
    80000ece:	6c4080e7          	jalr	1732(ra) # 8000058e <printf>
    kvminithart();    // turn on paging
    80000ed2:	00000097          	auipc	ra,0x0
    80000ed6:	0d8080e7          	jalr	216(ra) # 80000faa <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eda:	00002097          	auipc	ra,0x2
    80000ede:	d4c080e7          	jalr	-692(ra) # 80002c26 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ee2:	00005097          	auipc	ra,0x5
    80000ee6:	5ce080e7          	jalr	1486(ra) # 800064b0 <plicinithart>
  }

  scheduler();        
    80000eea:	00001097          	auipc	ra,0x1
    80000eee:	110080e7          	jalr	272(ra) # 80001ffa <scheduler>
    consoleinit();
    80000ef2:	fffff097          	auipc	ra,0xfffff
    80000ef6:	564080e7          	jalr	1380(ra) # 80000456 <consoleinit>
    printfinit();
    80000efa:	00000097          	auipc	ra,0x0
    80000efe:	87a080e7          	jalr	-1926(ra) # 80000774 <printfinit>
    printf("\n");
    80000f02:	00007517          	auipc	a0,0x7
    80000f06:	1c650513          	addi	a0,a0,454 # 800080c8 <digits+0x88>
    80000f0a:	fffff097          	auipc	ra,0xfffff
    80000f0e:	684080e7          	jalr	1668(ra) # 8000058e <printf>
    printf("xv6 kernel is booting\n");
    80000f12:	00007517          	auipc	a0,0x7
    80000f16:	18e50513          	addi	a0,a0,398 # 800080a0 <digits+0x60>
    80000f1a:	fffff097          	auipc	ra,0xfffff
    80000f1e:	674080e7          	jalr	1652(ra) # 8000058e <printf>
    printf("\n");
    80000f22:	00007517          	auipc	a0,0x7
    80000f26:	1a650513          	addi	a0,a0,422 # 800080c8 <digits+0x88>
    80000f2a:	fffff097          	auipc	ra,0xfffff
    80000f2e:	664080e7          	jalr	1636(ra) # 8000058e <printf>
    kinit();         // physical page allocator
    80000f32:	00000097          	auipc	ra,0x0
    80000f36:	b8c080e7          	jalr	-1140(ra) # 80000abe <kinit>
    kvminit();       // create kernel page table
    80000f3a:	00000097          	auipc	ra,0x0
    80000f3e:	326080e7          	jalr	806(ra) # 80001260 <kvminit>
    kvminithart();   // turn on paging
    80000f42:	00000097          	auipc	ra,0x0
    80000f46:	068080e7          	jalr	104(ra) # 80000faa <kvminithart>
    procinit();      // process table
    80000f4a:	00001097          	auipc	ra,0x1
    80000f4e:	99c080e7          	jalr	-1636(ra) # 800018e6 <procinit>
    trapinit();      // trap vectors
    80000f52:	00002097          	auipc	ra,0x2
    80000f56:	cac080e7          	jalr	-852(ra) # 80002bfe <trapinit>
    trapinithart();  // install kernel trap vector
    80000f5a:	00002097          	auipc	ra,0x2
    80000f5e:	ccc080e7          	jalr	-820(ra) # 80002c26 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	538080e7          	jalr	1336(ra) # 8000649a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f6a:	00005097          	auipc	ra,0x5
    80000f6e:	546080e7          	jalr	1350(ra) # 800064b0 <plicinithart>
    binit();         // buffer cache
    80000f72:	00002097          	auipc	ra,0x2
    80000f76:	700080e7          	jalr	1792(ra) # 80003672 <binit>
    iinit();         // inode table
    80000f7a:	00003097          	auipc	ra,0x3
    80000f7e:	da4080e7          	jalr	-604(ra) # 80003d1e <iinit>
    fileinit();      // file table
    80000f82:	00004097          	auipc	ra,0x4
    80000f86:	d42080e7          	jalr	-702(ra) # 80004cc4 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f8a:	00005097          	auipc	ra,0x5
    80000f8e:	62e080e7          	jalr	1582(ra) # 800065b8 <virtio_disk_init>
    userinit();      // first user process
    80000f92:	00001097          	auipc	ra,0x1
    80000f96:	d82080e7          	jalr	-638(ra) # 80001d14 <userinit>
    __sync_synchronize();
    80000f9a:	0ff0000f          	fence
    started = 1;
    80000f9e:	4785                	li	a5,1
    80000fa0:	00008717          	auipc	a4,0x8
    80000fa4:	baf72c23          	sw	a5,-1096(a4) # 80008b58 <started>
    80000fa8:	b789                	j	80000eea <main+0x56>

0000000080000faa <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000faa:	1141                	addi	sp,sp,-16
    80000fac:	e422                	sd	s0,8(sp)
    80000fae:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fb0:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000fb4:	00008797          	auipc	a5,0x8
    80000fb8:	bac7b783          	ld	a5,-1108(a5) # 80008b60 <kernel_pagetable>
    80000fbc:	83b1                	srli	a5,a5,0xc
    80000fbe:	577d                	li	a4,-1
    80000fc0:	177e                	slli	a4,a4,0x3f
    80000fc2:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fc4:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fc8:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fcc:	6422                	ld	s0,8(sp)
    80000fce:	0141                	addi	sp,sp,16
    80000fd0:	8082                	ret

0000000080000fd2 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fd2:	7139                	addi	sp,sp,-64
    80000fd4:	fc06                	sd	ra,56(sp)
    80000fd6:	f822                	sd	s0,48(sp)
    80000fd8:	f426                	sd	s1,40(sp)
    80000fda:	f04a                	sd	s2,32(sp)
    80000fdc:	ec4e                	sd	s3,24(sp)
    80000fde:	e852                	sd	s4,16(sp)
    80000fe0:	e456                	sd	s5,8(sp)
    80000fe2:	e05a                	sd	s6,0(sp)
    80000fe4:	0080                	addi	s0,sp,64
    80000fe6:	84aa                	mv	s1,a0
    80000fe8:	89ae                	mv	s3,a1
    80000fea:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fec:	57fd                	li	a5,-1
    80000fee:	83e9                	srli	a5,a5,0x1a
    80000ff0:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000ff2:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000ff4:	04b7f263          	bgeu	a5,a1,80001038 <walk+0x66>
    panic("walk");
    80000ff8:	00007517          	auipc	a0,0x7
    80000ffc:	0d850513          	addi	a0,a0,216 # 800080d0 <digits+0x90>
    80001000:	fffff097          	auipc	ra,0xfffff
    80001004:	544080e7          	jalr	1348(ra) # 80000544 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001008:	060a8663          	beqz	s5,80001074 <walk+0xa2>
    8000100c:	00000097          	auipc	ra,0x0
    80001010:	aee080e7          	jalr	-1298(ra) # 80000afa <kalloc>
    80001014:	84aa                	mv	s1,a0
    80001016:	c529                	beqz	a0,80001060 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001018:	6605                	lui	a2,0x1
    8000101a:	4581                	li	a1,0
    8000101c:	00000097          	auipc	ra,0x0
    80001020:	cca080e7          	jalr	-822(ra) # 80000ce6 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001024:	00c4d793          	srli	a5,s1,0xc
    80001028:	07aa                	slli	a5,a5,0xa
    8000102a:	0017e793          	ori	a5,a5,1
    8000102e:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001032:	3a5d                	addiw	s4,s4,-9
    80001034:	036a0063          	beq	s4,s6,80001054 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001038:	0149d933          	srl	s2,s3,s4
    8000103c:	1ff97913          	andi	s2,s2,511
    80001040:	090e                	slli	s2,s2,0x3
    80001042:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001044:	00093483          	ld	s1,0(s2)
    80001048:	0014f793          	andi	a5,s1,1
    8000104c:	dfd5                	beqz	a5,80001008 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000104e:	80a9                	srli	s1,s1,0xa
    80001050:	04b2                	slli	s1,s1,0xc
    80001052:	b7c5                	j	80001032 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001054:	00c9d513          	srli	a0,s3,0xc
    80001058:	1ff57513          	andi	a0,a0,511
    8000105c:	050e                	slli	a0,a0,0x3
    8000105e:	9526                	add	a0,a0,s1
}
    80001060:	70e2                	ld	ra,56(sp)
    80001062:	7442                	ld	s0,48(sp)
    80001064:	74a2                	ld	s1,40(sp)
    80001066:	7902                	ld	s2,32(sp)
    80001068:	69e2                	ld	s3,24(sp)
    8000106a:	6a42                	ld	s4,16(sp)
    8000106c:	6aa2                	ld	s5,8(sp)
    8000106e:	6b02                	ld	s6,0(sp)
    80001070:	6121                	addi	sp,sp,64
    80001072:	8082                	ret
        return 0;
    80001074:	4501                	li	a0,0
    80001076:	b7ed                	j	80001060 <walk+0x8e>

0000000080001078 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001078:	57fd                	li	a5,-1
    8000107a:	83e9                	srli	a5,a5,0x1a
    8000107c:	00b7f463          	bgeu	a5,a1,80001084 <walkaddr+0xc>
    return 0;
    80001080:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001082:	8082                	ret
{
    80001084:	1141                	addi	sp,sp,-16
    80001086:	e406                	sd	ra,8(sp)
    80001088:	e022                	sd	s0,0(sp)
    8000108a:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000108c:	4601                	li	a2,0
    8000108e:	00000097          	auipc	ra,0x0
    80001092:	f44080e7          	jalr	-188(ra) # 80000fd2 <walk>
  if(pte == 0)
    80001096:	c105                	beqz	a0,800010b6 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001098:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000109a:	0117f693          	andi	a3,a5,17
    8000109e:	4745                	li	a4,17
    return 0;
    800010a0:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010a2:	00e68663          	beq	a3,a4,800010ae <walkaddr+0x36>
}
    800010a6:	60a2                	ld	ra,8(sp)
    800010a8:	6402                	ld	s0,0(sp)
    800010aa:	0141                	addi	sp,sp,16
    800010ac:	8082                	ret
  pa = PTE2PA(*pte);
    800010ae:	00a7d513          	srli	a0,a5,0xa
    800010b2:	0532                	slli	a0,a0,0xc
  return pa;
    800010b4:	bfcd                	j	800010a6 <walkaddr+0x2e>
    return 0;
    800010b6:	4501                	li	a0,0
    800010b8:	b7fd                	j	800010a6 <walkaddr+0x2e>

00000000800010ba <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010ba:	715d                	addi	sp,sp,-80
    800010bc:	e486                	sd	ra,72(sp)
    800010be:	e0a2                	sd	s0,64(sp)
    800010c0:	fc26                	sd	s1,56(sp)
    800010c2:	f84a                	sd	s2,48(sp)
    800010c4:	f44e                	sd	s3,40(sp)
    800010c6:	f052                	sd	s4,32(sp)
    800010c8:	ec56                	sd	s5,24(sp)
    800010ca:	e85a                	sd	s6,16(sp)
    800010cc:	e45e                	sd	s7,8(sp)
    800010ce:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010d0:	c205                	beqz	a2,800010f0 <mappages+0x36>
    800010d2:	8aaa                	mv	s5,a0
    800010d4:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010d6:	77fd                	lui	a5,0xfffff
    800010d8:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800010dc:	15fd                	addi	a1,a1,-1
    800010de:	00c589b3          	add	s3,a1,a2
    800010e2:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800010e6:	8952                	mv	s2,s4
    800010e8:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010ec:	6b85                	lui	s7,0x1
    800010ee:	a015                	j	80001112 <mappages+0x58>
    panic("mappages: size");
    800010f0:	00007517          	auipc	a0,0x7
    800010f4:	fe850513          	addi	a0,a0,-24 # 800080d8 <digits+0x98>
    800010f8:	fffff097          	auipc	ra,0xfffff
    800010fc:	44c080e7          	jalr	1100(ra) # 80000544 <panic>
      panic("mappages: remap");
    80001100:	00007517          	auipc	a0,0x7
    80001104:	fe850513          	addi	a0,a0,-24 # 800080e8 <digits+0xa8>
    80001108:	fffff097          	auipc	ra,0xfffff
    8000110c:	43c080e7          	jalr	1084(ra) # 80000544 <panic>
    a += PGSIZE;
    80001110:	995e                	add	s2,s2,s7
  for(;;){
    80001112:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001116:	4605                	li	a2,1
    80001118:	85ca                	mv	a1,s2
    8000111a:	8556                	mv	a0,s5
    8000111c:	00000097          	auipc	ra,0x0
    80001120:	eb6080e7          	jalr	-330(ra) # 80000fd2 <walk>
    80001124:	cd19                	beqz	a0,80001142 <mappages+0x88>
    if(*pte & PTE_V)
    80001126:	611c                	ld	a5,0(a0)
    80001128:	8b85                	andi	a5,a5,1
    8000112a:	fbf9                	bnez	a5,80001100 <mappages+0x46>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000112c:	80b1                	srli	s1,s1,0xc
    8000112e:	04aa                	slli	s1,s1,0xa
    80001130:	0164e4b3          	or	s1,s1,s6
    80001134:	0014e493          	ori	s1,s1,1
    80001138:	e104                	sd	s1,0(a0)
    if(a == last)
    8000113a:	fd391be3          	bne	s2,s3,80001110 <mappages+0x56>
    pa += PGSIZE;
  }
  return 0;
    8000113e:	4501                	li	a0,0
    80001140:	a011                	j	80001144 <mappages+0x8a>
      return -1;
    80001142:	557d                	li	a0,-1
}
    80001144:	60a6                	ld	ra,72(sp)
    80001146:	6406                	ld	s0,64(sp)
    80001148:	74e2                	ld	s1,56(sp)
    8000114a:	7942                	ld	s2,48(sp)
    8000114c:	79a2                	ld	s3,40(sp)
    8000114e:	7a02                	ld	s4,32(sp)
    80001150:	6ae2                	ld	s5,24(sp)
    80001152:	6b42                	ld	s6,16(sp)
    80001154:	6ba2                	ld	s7,8(sp)
    80001156:	6161                	addi	sp,sp,80
    80001158:	8082                	ret

000000008000115a <kvmmap>:
{
    8000115a:	1141                	addi	sp,sp,-16
    8000115c:	e406                	sd	ra,8(sp)
    8000115e:	e022                	sd	s0,0(sp)
    80001160:	0800                	addi	s0,sp,16
    80001162:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001164:	86b2                	mv	a3,a2
    80001166:	863e                	mv	a2,a5
    80001168:	00000097          	auipc	ra,0x0
    8000116c:	f52080e7          	jalr	-174(ra) # 800010ba <mappages>
    80001170:	e509                	bnez	a0,8000117a <kvmmap+0x20>
}
    80001172:	60a2                	ld	ra,8(sp)
    80001174:	6402                	ld	s0,0(sp)
    80001176:	0141                	addi	sp,sp,16
    80001178:	8082                	ret
    panic("kvmmap");
    8000117a:	00007517          	auipc	a0,0x7
    8000117e:	f7e50513          	addi	a0,a0,-130 # 800080f8 <digits+0xb8>
    80001182:	fffff097          	auipc	ra,0xfffff
    80001186:	3c2080e7          	jalr	962(ra) # 80000544 <panic>

000000008000118a <kvmmake>:
{
    8000118a:	1101                	addi	sp,sp,-32
    8000118c:	ec06                	sd	ra,24(sp)
    8000118e:	e822                	sd	s0,16(sp)
    80001190:	e426                	sd	s1,8(sp)
    80001192:	e04a                	sd	s2,0(sp)
    80001194:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001196:	00000097          	auipc	ra,0x0
    8000119a:	964080e7          	jalr	-1692(ra) # 80000afa <kalloc>
    8000119e:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011a0:	6605                	lui	a2,0x1
    800011a2:	4581                	li	a1,0
    800011a4:	00000097          	auipc	ra,0x0
    800011a8:	b42080e7          	jalr	-1214(ra) # 80000ce6 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011ac:	4719                	li	a4,6
    800011ae:	6685                	lui	a3,0x1
    800011b0:	10000637          	lui	a2,0x10000
    800011b4:	100005b7          	lui	a1,0x10000
    800011b8:	8526                	mv	a0,s1
    800011ba:	00000097          	auipc	ra,0x0
    800011be:	fa0080e7          	jalr	-96(ra) # 8000115a <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011c2:	4719                	li	a4,6
    800011c4:	6685                	lui	a3,0x1
    800011c6:	10001637          	lui	a2,0x10001
    800011ca:	100015b7          	lui	a1,0x10001
    800011ce:	8526                	mv	a0,s1
    800011d0:	00000097          	auipc	ra,0x0
    800011d4:	f8a080e7          	jalr	-118(ra) # 8000115a <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011d8:	4719                	li	a4,6
    800011da:	004006b7          	lui	a3,0x400
    800011de:	0c000637          	lui	a2,0xc000
    800011e2:	0c0005b7          	lui	a1,0xc000
    800011e6:	8526                	mv	a0,s1
    800011e8:	00000097          	auipc	ra,0x0
    800011ec:	f72080e7          	jalr	-142(ra) # 8000115a <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011f0:	00007917          	auipc	s2,0x7
    800011f4:	e1090913          	addi	s2,s2,-496 # 80008000 <etext>
    800011f8:	4729                	li	a4,10
    800011fa:	80007697          	auipc	a3,0x80007
    800011fe:	e0668693          	addi	a3,a3,-506 # 8000 <_entry-0x7fff8000>
    80001202:	4605                	li	a2,1
    80001204:	067e                	slli	a2,a2,0x1f
    80001206:	85b2                	mv	a1,a2
    80001208:	8526                	mv	a0,s1
    8000120a:	00000097          	auipc	ra,0x0
    8000120e:	f50080e7          	jalr	-176(ra) # 8000115a <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001212:	4719                	li	a4,6
    80001214:	46c5                	li	a3,17
    80001216:	06ee                	slli	a3,a3,0x1b
    80001218:	412686b3          	sub	a3,a3,s2
    8000121c:	864a                	mv	a2,s2
    8000121e:	85ca                	mv	a1,s2
    80001220:	8526                	mv	a0,s1
    80001222:	00000097          	auipc	ra,0x0
    80001226:	f38080e7          	jalr	-200(ra) # 8000115a <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000122a:	4729                	li	a4,10
    8000122c:	6685                	lui	a3,0x1
    8000122e:	00006617          	auipc	a2,0x6
    80001232:	dd260613          	addi	a2,a2,-558 # 80007000 <_trampoline>
    80001236:	040005b7          	lui	a1,0x4000
    8000123a:	15fd                	addi	a1,a1,-1
    8000123c:	05b2                	slli	a1,a1,0xc
    8000123e:	8526                	mv	a0,s1
    80001240:	00000097          	auipc	ra,0x0
    80001244:	f1a080e7          	jalr	-230(ra) # 8000115a <kvmmap>
  proc_mapstacks(kpgtbl);
    80001248:	8526                	mv	a0,s1
    8000124a:	00000097          	auipc	ra,0x0
    8000124e:	606080e7          	jalr	1542(ra) # 80001850 <proc_mapstacks>
}
    80001252:	8526                	mv	a0,s1
    80001254:	60e2                	ld	ra,24(sp)
    80001256:	6442                	ld	s0,16(sp)
    80001258:	64a2                	ld	s1,8(sp)
    8000125a:	6902                	ld	s2,0(sp)
    8000125c:	6105                	addi	sp,sp,32
    8000125e:	8082                	ret

0000000080001260 <kvminit>:
{
    80001260:	1141                	addi	sp,sp,-16
    80001262:	e406                	sd	ra,8(sp)
    80001264:	e022                	sd	s0,0(sp)
    80001266:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001268:	00000097          	auipc	ra,0x0
    8000126c:	f22080e7          	jalr	-222(ra) # 8000118a <kvmmake>
    80001270:	00008797          	auipc	a5,0x8
    80001274:	8ea7b823          	sd	a0,-1808(a5) # 80008b60 <kernel_pagetable>
}
    80001278:	60a2                	ld	ra,8(sp)
    8000127a:	6402                	ld	s0,0(sp)
    8000127c:	0141                	addi	sp,sp,16
    8000127e:	8082                	ret

0000000080001280 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001280:	715d                	addi	sp,sp,-80
    80001282:	e486                	sd	ra,72(sp)
    80001284:	e0a2                	sd	s0,64(sp)
    80001286:	fc26                	sd	s1,56(sp)
    80001288:	f84a                	sd	s2,48(sp)
    8000128a:	f44e                	sd	s3,40(sp)
    8000128c:	f052                	sd	s4,32(sp)
    8000128e:	ec56                	sd	s5,24(sp)
    80001290:	e85a                	sd	s6,16(sp)
    80001292:	e45e                	sd	s7,8(sp)
    80001294:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001296:	03459793          	slli	a5,a1,0x34
    8000129a:	e795                	bnez	a5,800012c6 <uvmunmap+0x46>
    8000129c:	8a2a                	mv	s4,a0
    8000129e:	892e                	mv	s2,a1
    800012a0:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012a2:	0632                	slli	a2,a2,0xc
    800012a4:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800012a8:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012aa:	6b05                	lui	s6,0x1
    800012ac:	0735e863          	bltu	a1,s3,8000131c <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012b0:	60a6                	ld	ra,72(sp)
    800012b2:	6406                	ld	s0,64(sp)
    800012b4:	74e2                	ld	s1,56(sp)
    800012b6:	7942                	ld	s2,48(sp)
    800012b8:	79a2                	ld	s3,40(sp)
    800012ba:	7a02                	ld	s4,32(sp)
    800012bc:	6ae2                	ld	s5,24(sp)
    800012be:	6b42                	ld	s6,16(sp)
    800012c0:	6ba2                	ld	s7,8(sp)
    800012c2:	6161                	addi	sp,sp,80
    800012c4:	8082                	ret
    panic("uvmunmap: not aligned");
    800012c6:	00007517          	auipc	a0,0x7
    800012ca:	e3a50513          	addi	a0,a0,-454 # 80008100 <digits+0xc0>
    800012ce:	fffff097          	auipc	ra,0xfffff
    800012d2:	276080e7          	jalr	630(ra) # 80000544 <panic>
      panic("uvmunmap: walk");
    800012d6:	00007517          	auipc	a0,0x7
    800012da:	e4250513          	addi	a0,a0,-446 # 80008118 <digits+0xd8>
    800012de:	fffff097          	auipc	ra,0xfffff
    800012e2:	266080e7          	jalr	614(ra) # 80000544 <panic>
      panic("uvmunmap: not mapped");
    800012e6:	00007517          	auipc	a0,0x7
    800012ea:	e4250513          	addi	a0,a0,-446 # 80008128 <digits+0xe8>
    800012ee:	fffff097          	auipc	ra,0xfffff
    800012f2:	256080e7          	jalr	598(ra) # 80000544 <panic>
      panic("uvmunmap: not a leaf");
    800012f6:	00007517          	auipc	a0,0x7
    800012fa:	e4a50513          	addi	a0,a0,-438 # 80008140 <digits+0x100>
    800012fe:	fffff097          	auipc	ra,0xfffff
    80001302:	246080e7          	jalr	582(ra) # 80000544 <panic>
      uint64 pa = PTE2PA(*pte);
    80001306:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001308:	0532                	slli	a0,a0,0xc
    8000130a:	fffff097          	auipc	ra,0xfffff
    8000130e:	6f4080e7          	jalr	1780(ra) # 800009fe <kfree>
    *pte = 0;
    80001312:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001316:	995a                	add	s2,s2,s6
    80001318:	f9397ce3          	bgeu	s2,s3,800012b0 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    8000131c:	4601                	li	a2,0
    8000131e:	85ca                	mv	a1,s2
    80001320:	8552                	mv	a0,s4
    80001322:	00000097          	auipc	ra,0x0
    80001326:	cb0080e7          	jalr	-848(ra) # 80000fd2 <walk>
    8000132a:	84aa                	mv	s1,a0
    8000132c:	d54d                	beqz	a0,800012d6 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    8000132e:	6108                	ld	a0,0(a0)
    80001330:	00157793          	andi	a5,a0,1
    80001334:	dbcd                	beqz	a5,800012e6 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001336:	3ff57793          	andi	a5,a0,1023
    8000133a:	fb778ee3          	beq	a5,s7,800012f6 <uvmunmap+0x76>
    if(do_free){
    8000133e:	fc0a8ae3          	beqz	s5,80001312 <uvmunmap+0x92>
    80001342:	b7d1                	j	80001306 <uvmunmap+0x86>

0000000080001344 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001344:	1101                	addi	sp,sp,-32
    80001346:	ec06                	sd	ra,24(sp)
    80001348:	e822                	sd	s0,16(sp)
    8000134a:	e426                	sd	s1,8(sp)
    8000134c:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000134e:	fffff097          	auipc	ra,0xfffff
    80001352:	7ac080e7          	jalr	1964(ra) # 80000afa <kalloc>
    80001356:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001358:	c519                	beqz	a0,80001366 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000135a:	6605                	lui	a2,0x1
    8000135c:	4581                	li	a1,0
    8000135e:	00000097          	auipc	ra,0x0
    80001362:	988080e7          	jalr	-1656(ra) # 80000ce6 <memset>
  return pagetable;
}
    80001366:	8526                	mv	a0,s1
    80001368:	60e2                	ld	ra,24(sp)
    8000136a:	6442                	ld	s0,16(sp)
    8000136c:	64a2                	ld	s1,8(sp)
    8000136e:	6105                	addi	sp,sp,32
    80001370:	8082                	ret

0000000080001372 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001372:	7179                	addi	sp,sp,-48
    80001374:	f406                	sd	ra,40(sp)
    80001376:	f022                	sd	s0,32(sp)
    80001378:	ec26                	sd	s1,24(sp)
    8000137a:	e84a                	sd	s2,16(sp)
    8000137c:	e44e                	sd	s3,8(sp)
    8000137e:	e052                	sd	s4,0(sp)
    80001380:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001382:	6785                	lui	a5,0x1
    80001384:	04f67863          	bgeu	a2,a5,800013d4 <uvmfirst+0x62>
    80001388:	8a2a                	mv	s4,a0
    8000138a:	89ae                	mv	s3,a1
    8000138c:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000138e:	fffff097          	auipc	ra,0xfffff
    80001392:	76c080e7          	jalr	1900(ra) # 80000afa <kalloc>
    80001396:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001398:	6605                	lui	a2,0x1
    8000139a:	4581                	li	a1,0
    8000139c:	00000097          	auipc	ra,0x0
    800013a0:	94a080e7          	jalr	-1718(ra) # 80000ce6 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013a4:	4779                	li	a4,30
    800013a6:	86ca                	mv	a3,s2
    800013a8:	6605                	lui	a2,0x1
    800013aa:	4581                	li	a1,0
    800013ac:	8552                	mv	a0,s4
    800013ae:	00000097          	auipc	ra,0x0
    800013b2:	d0c080e7          	jalr	-756(ra) # 800010ba <mappages>
  memmove(mem, src, sz);
    800013b6:	8626                	mv	a2,s1
    800013b8:	85ce                	mv	a1,s3
    800013ba:	854a                	mv	a0,s2
    800013bc:	00000097          	auipc	ra,0x0
    800013c0:	98a080e7          	jalr	-1654(ra) # 80000d46 <memmove>
}
    800013c4:	70a2                	ld	ra,40(sp)
    800013c6:	7402                	ld	s0,32(sp)
    800013c8:	64e2                	ld	s1,24(sp)
    800013ca:	6942                	ld	s2,16(sp)
    800013cc:	69a2                	ld	s3,8(sp)
    800013ce:	6a02                	ld	s4,0(sp)
    800013d0:	6145                	addi	sp,sp,48
    800013d2:	8082                	ret
    panic("uvmfirst: more than a page");
    800013d4:	00007517          	auipc	a0,0x7
    800013d8:	d8450513          	addi	a0,a0,-636 # 80008158 <digits+0x118>
    800013dc:	fffff097          	auipc	ra,0xfffff
    800013e0:	168080e7          	jalr	360(ra) # 80000544 <panic>

00000000800013e4 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013e4:	1101                	addi	sp,sp,-32
    800013e6:	ec06                	sd	ra,24(sp)
    800013e8:	e822                	sd	s0,16(sp)
    800013ea:	e426                	sd	s1,8(sp)
    800013ec:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013ee:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013f0:	00b67d63          	bgeu	a2,a1,8000140a <uvmdealloc+0x26>
    800013f4:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013f6:	6785                	lui	a5,0x1
    800013f8:	17fd                	addi	a5,a5,-1
    800013fa:	00f60733          	add	a4,a2,a5
    800013fe:	767d                	lui	a2,0xfffff
    80001400:	8f71                	and	a4,a4,a2
    80001402:	97ae                	add	a5,a5,a1
    80001404:	8ff1                	and	a5,a5,a2
    80001406:	00f76863          	bltu	a4,a5,80001416 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000140a:	8526                	mv	a0,s1
    8000140c:	60e2                	ld	ra,24(sp)
    8000140e:	6442                	ld	s0,16(sp)
    80001410:	64a2                	ld	s1,8(sp)
    80001412:	6105                	addi	sp,sp,32
    80001414:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001416:	8f99                	sub	a5,a5,a4
    80001418:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000141a:	4685                	li	a3,1
    8000141c:	0007861b          	sext.w	a2,a5
    80001420:	85ba                	mv	a1,a4
    80001422:	00000097          	auipc	ra,0x0
    80001426:	e5e080e7          	jalr	-418(ra) # 80001280 <uvmunmap>
    8000142a:	b7c5                	j	8000140a <uvmdealloc+0x26>

000000008000142c <uvmalloc>:
  if(newsz < oldsz)
    8000142c:	0ab66563          	bltu	a2,a1,800014d6 <uvmalloc+0xaa>
{
    80001430:	7139                	addi	sp,sp,-64
    80001432:	fc06                	sd	ra,56(sp)
    80001434:	f822                	sd	s0,48(sp)
    80001436:	f426                	sd	s1,40(sp)
    80001438:	f04a                	sd	s2,32(sp)
    8000143a:	ec4e                	sd	s3,24(sp)
    8000143c:	e852                	sd	s4,16(sp)
    8000143e:	e456                	sd	s5,8(sp)
    80001440:	e05a                	sd	s6,0(sp)
    80001442:	0080                	addi	s0,sp,64
    80001444:	8aaa                	mv	s5,a0
    80001446:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001448:	6985                	lui	s3,0x1
    8000144a:	19fd                	addi	s3,s3,-1
    8000144c:	95ce                	add	a1,a1,s3
    8000144e:	79fd                	lui	s3,0xfffff
    80001450:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001454:	08c9f363          	bgeu	s3,a2,800014da <uvmalloc+0xae>
    80001458:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000145a:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000145e:	fffff097          	auipc	ra,0xfffff
    80001462:	69c080e7          	jalr	1692(ra) # 80000afa <kalloc>
    80001466:	84aa                	mv	s1,a0
    if(mem == 0){
    80001468:	c51d                	beqz	a0,80001496 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000146a:	6605                	lui	a2,0x1
    8000146c:	4581                	li	a1,0
    8000146e:	00000097          	auipc	ra,0x0
    80001472:	878080e7          	jalr	-1928(ra) # 80000ce6 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001476:	875a                	mv	a4,s6
    80001478:	86a6                	mv	a3,s1
    8000147a:	6605                	lui	a2,0x1
    8000147c:	85ca                	mv	a1,s2
    8000147e:	8556                	mv	a0,s5
    80001480:	00000097          	auipc	ra,0x0
    80001484:	c3a080e7          	jalr	-966(ra) # 800010ba <mappages>
    80001488:	e90d                	bnez	a0,800014ba <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000148a:	6785                	lui	a5,0x1
    8000148c:	993e                	add	s2,s2,a5
    8000148e:	fd4968e3          	bltu	s2,s4,8000145e <uvmalloc+0x32>
  return newsz;
    80001492:	8552                	mv	a0,s4
    80001494:	a809                	j	800014a6 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    80001496:	864e                	mv	a2,s3
    80001498:	85ca                	mv	a1,s2
    8000149a:	8556                	mv	a0,s5
    8000149c:	00000097          	auipc	ra,0x0
    800014a0:	f48080e7          	jalr	-184(ra) # 800013e4 <uvmdealloc>
      return 0;
    800014a4:	4501                	li	a0,0
}
    800014a6:	70e2                	ld	ra,56(sp)
    800014a8:	7442                	ld	s0,48(sp)
    800014aa:	74a2                	ld	s1,40(sp)
    800014ac:	7902                	ld	s2,32(sp)
    800014ae:	69e2                	ld	s3,24(sp)
    800014b0:	6a42                	ld	s4,16(sp)
    800014b2:	6aa2                	ld	s5,8(sp)
    800014b4:	6b02                	ld	s6,0(sp)
    800014b6:	6121                	addi	sp,sp,64
    800014b8:	8082                	ret
      kfree(mem);
    800014ba:	8526                	mv	a0,s1
    800014bc:	fffff097          	auipc	ra,0xfffff
    800014c0:	542080e7          	jalr	1346(ra) # 800009fe <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014c4:	864e                	mv	a2,s3
    800014c6:	85ca                	mv	a1,s2
    800014c8:	8556                	mv	a0,s5
    800014ca:	00000097          	auipc	ra,0x0
    800014ce:	f1a080e7          	jalr	-230(ra) # 800013e4 <uvmdealloc>
      return 0;
    800014d2:	4501                	li	a0,0
    800014d4:	bfc9                	j	800014a6 <uvmalloc+0x7a>
    return oldsz;
    800014d6:	852e                	mv	a0,a1
}
    800014d8:	8082                	ret
  return newsz;
    800014da:	8532                	mv	a0,a2
    800014dc:	b7e9                	j	800014a6 <uvmalloc+0x7a>

00000000800014de <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014de:	7179                	addi	sp,sp,-48
    800014e0:	f406                	sd	ra,40(sp)
    800014e2:	f022                	sd	s0,32(sp)
    800014e4:	ec26                	sd	s1,24(sp)
    800014e6:	e84a                	sd	s2,16(sp)
    800014e8:	e44e                	sd	s3,8(sp)
    800014ea:	e052                	sd	s4,0(sp)
    800014ec:	1800                	addi	s0,sp,48
    800014ee:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014f0:	84aa                	mv	s1,a0
    800014f2:	6905                	lui	s2,0x1
    800014f4:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f6:	4985                	li	s3,1
    800014f8:	a821                	j	80001510 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014fa:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014fc:	0532                	slli	a0,a0,0xc
    800014fe:	00000097          	auipc	ra,0x0
    80001502:	fe0080e7          	jalr	-32(ra) # 800014de <freewalk>
      pagetable[i] = 0;
    80001506:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000150a:	04a1                	addi	s1,s1,8
    8000150c:	03248163          	beq	s1,s2,8000152e <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001510:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001512:	00f57793          	andi	a5,a0,15
    80001516:	ff3782e3          	beq	a5,s3,800014fa <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000151a:	8905                	andi	a0,a0,1
    8000151c:	d57d                	beqz	a0,8000150a <freewalk+0x2c>
      panic("freewalk: leaf");
    8000151e:	00007517          	auipc	a0,0x7
    80001522:	c5a50513          	addi	a0,a0,-934 # 80008178 <digits+0x138>
    80001526:	fffff097          	auipc	ra,0xfffff
    8000152a:	01e080e7          	jalr	30(ra) # 80000544 <panic>
    }
  }
  kfree((void*)pagetable);
    8000152e:	8552                	mv	a0,s4
    80001530:	fffff097          	auipc	ra,0xfffff
    80001534:	4ce080e7          	jalr	1230(ra) # 800009fe <kfree>
}
    80001538:	70a2                	ld	ra,40(sp)
    8000153a:	7402                	ld	s0,32(sp)
    8000153c:	64e2                	ld	s1,24(sp)
    8000153e:	6942                	ld	s2,16(sp)
    80001540:	69a2                	ld	s3,8(sp)
    80001542:	6a02                	ld	s4,0(sp)
    80001544:	6145                	addi	sp,sp,48
    80001546:	8082                	ret

0000000080001548 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001548:	1101                	addi	sp,sp,-32
    8000154a:	ec06                	sd	ra,24(sp)
    8000154c:	e822                	sd	s0,16(sp)
    8000154e:	e426                	sd	s1,8(sp)
    80001550:	1000                	addi	s0,sp,32
    80001552:	84aa                	mv	s1,a0
  if(sz > 0)
    80001554:	e999                	bnez	a1,8000156a <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001556:	8526                	mv	a0,s1
    80001558:	00000097          	auipc	ra,0x0
    8000155c:	f86080e7          	jalr	-122(ra) # 800014de <freewalk>
}
    80001560:	60e2                	ld	ra,24(sp)
    80001562:	6442                	ld	s0,16(sp)
    80001564:	64a2                	ld	s1,8(sp)
    80001566:	6105                	addi	sp,sp,32
    80001568:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000156a:	6605                	lui	a2,0x1
    8000156c:	167d                	addi	a2,a2,-1
    8000156e:	962e                	add	a2,a2,a1
    80001570:	4685                	li	a3,1
    80001572:	8231                	srli	a2,a2,0xc
    80001574:	4581                	li	a1,0
    80001576:	00000097          	auipc	ra,0x0
    8000157a:	d0a080e7          	jalr	-758(ra) # 80001280 <uvmunmap>
    8000157e:	bfe1                	j	80001556 <uvmfree+0xe>

0000000080001580 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001580:	c679                	beqz	a2,8000164e <uvmcopy+0xce>
{
    80001582:	715d                	addi	sp,sp,-80
    80001584:	e486                	sd	ra,72(sp)
    80001586:	e0a2                	sd	s0,64(sp)
    80001588:	fc26                	sd	s1,56(sp)
    8000158a:	f84a                	sd	s2,48(sp)
    8000158c:	f44e                	sd	s3,40(sp)
    8000158e:	f052                	sd	s4,32(sp)
    80001590:	ec56                	sd	s5,24(sp)
    80001592:	e85a                	sd	s6,16(sp)
    80001594:	e45e                	sd	s7,8(sp)
    80001596:	0880                	addi	s0,sp,80
    80001598:	8b2a                	mv	s6,a0
    8000159a:	8aae                	mv	s5,a1
    8000159c:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000159e:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800015a0:	4601                	li	a2,0
    800015a2:	85ce                	mv	a1,s3
    800015a4:	855a                	mv	a0,s6
    800015a6:	00000097          	auipc	ra,0x0
    800015aa:	a2c080e7          	jalr	-1492(ra) # 80000fd2 <walk>
    800015ae:	c531                	beqz	a0,800015fa <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800015b0:	6118                	ld	a4,0(a0)
    800015b2:	00177793          	andi	a5,a4,1
    800015b6:	cbb1                	beqz	a5,8000160a <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015b8:	00a75593          	srli	a1,a4,0xa
    800015bc:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015c0:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015c4:	fffff097          	auipc	ra,0xfffff
    800015c8:	536080e7          	jalr	1334(ra) # 80000afa <kalloc>
    800015cc:	892a                	mv	s2,a0
    800015ce:	c939                	beqz	a0,80001624 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015d0:	6605                	lui	a2,0x1
    800015d2:	85de                	mv	a1,s7
    800015d4:	fffff097          	auipc	ra,0xfffff
    800015d8:	772080e7          	jalr	1906(ra) # 80000d46 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015dc:	8726                	mv	a4,s1
    800015de:	86ca                	mv	a3,s2
    800015e0:	6605                	lui	a2,0x1
    800015e2:	85ce                	mv	a1,s3
    800015e4:	8556                	mv	a0,s5
    800015e6:	00000097          	auipc	ra,0x0
    800015ea:	ad4080e7          	jalr	-1324(ra) # 800010ba <mappages>
    800015ee:	e515                	bnez	a0,8000161a <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015f0:	6785                	lui	a5,0x1
    800015f2:	99be                	add	s3,s3,a5
    800015f4:	fb49e6e3          	bltu	s3,s4,800015a0 <uvmcopy+0x20>
    800015f8:	a081                	j	80001638 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015fa:	00007517          	auipc	a0,0x7
    800015fe:	b8e50513          	addi	a0,a0,-1138 # 80008188 <digits+0x148>
    80001602:	fffff097          	auipc	ra,0xfffff
    80001606:	f42080e7          	jalr	-190(ra) # 80000544 <panic>
      panic("uvmcopy: page not present");
    8000160a:	00007517          	auipc	a0,0x7
    8000160e:	b9e50513          	addi	a0,a0,-1122 # 800081a8 <digits+0x168>
    80001612:	fffff097          	auipc	ra,0xfffff
    80001616:	f32080e7          	jalr	-206(ra) # 80000544 <panic>
      kfree(mem);
    8000161a:	854a                	mv	a0,s2
    8000161c:	fffff097          	auipc	ra,0xfffff
    80001620:	3e2080e7          	jalr	994(ra) # 800009fe <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001624:	4685                	li	a3,1
    80001626:	00c9d613          	srli	a2,s3,0xc
    8000162a:	4581                	li	a1,0
    8000162c:	8556                	mv	a0,s5
    8000162e:	00000097          	auipc	ra,0x0
    80001632:	c52080e7          	jalr	-942(ra) # 80001280 <uvmunmap>
  return -1;
    80001636:	557d                	li	a0,-1
}
    80001638:	60a6                	ld	ra,72(sp)
    8000163a:	6406                	ld	s0,64(sp)
    8000163c:	74e2                	ld	s1,56(sp)
    8000163e:	7942                	ld	s2,48(sp)
    80001640:	79a2                	ld	s3,40(sp)
    80001642:	7a02                	ld	s4,32(sp)
    80001644:	6ae2                	ld	s5,24(sp)
    80001646:	6b42                	ld	s6,16(sp)
    80001648:	6ba2                	ld	s7,8(sp)
    8000164a:	6161                	addi	sp,sp,80
    8000164c:	8082                	ret
  return 0;
    8000164e:	4501                	li	a0,0
}
    80001650:	8082                	ret

0000000080001652 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001652:	1141                	addi	sp,sp,-16
    80001654:	e406                	sd	ra,8(sp)
    80001656:	e022                	sd	s0,0(sp)
    80001658:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000165a:	4601                	li	a2,0
    8000165c:	00000097          	auipc	ra,0x0
    80001660:	976080e7          	jalr	-1674(ra) # 80000fd2 <walk>
  if(pte == 0)
    80001664:	c901                	beqz	a0,80001674 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001666:	611c                	ld	a5,0(a0)
    80001668:	9bbd                	andi	a5,a5,-17
    8000166a:	e11c                	sd	a5,0(a0)
}
    8000166c:	60a2                	ld	ra,8(sp)
    8000166e:	6402                	ld	s0,0(sp)
    80001670:	0141                	addi	sp,sp,16
    80001672:	8082                	ret
    panic("uvmclear");
    80001674:	00007517          	auipc	a0,0x7
    80001678:	b5450513          	addi	a0,a0,-1196 # 800081c8 <digits+0x188>
    8000167c:	fffff097          	auipc	ra,0xfffff
    80001680:	ec8080e7          	jalr	-312(ra) # 80000544 <panic>

0000000080001684 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001684:	c6bd                	beqz	a3,800016f2 <copyout+0x6e>
{
    80001686:	715d                	addi	sp,sp,-80
    80001688:	e486                	sd	ra,72(sp)
    8000168a:	e0a2                	sd	s0,64(sp)
    8000168c:	fc26                	sd	s1,56(sp)
    8000168e:	f84a                	sd	s2,48(sp)
    80001690:	f44e                	sd	s3,40(sp)
    80001692:	f052                	sd	s4,32(sp)
    80001694:	ec56                	sd	s5,24(sp)
    80001696:	e85a                	sd	s6,16(sp)
    80001698:	e45e                	sd	s7,8(sp)
    8000169a:	e062                	sd	s8,0(sp)
    8000169c:	0880                	addi	s0,sp,80
    8000169e:	8b2a                	mv	s6,a0
    800016a0:	8c2e                	mv	s8,a1
    800016a2:	8a32                	mv	s4,a2
    800016a4:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800016a6:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800016a8:	6a85                	lui	s5,0x1
    800016aa:	a015                	j	800016ce <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800016ac:	9562                	add	a0,a0,s8
    800016ae:	0004861b          	sext.w	a2,s1
    800016b2:	85d2                	mv	a1,s4
    800016b4:	41250533          	sub	a0,a0,s2
    800016b8:	fffff097          	auipc	ra,0xfffff
    800016bc:	68e080e7          	jalr	1678(ra) # 80000d46 <memmove>

    len -= n;
    800016c0:	409989b3          	sub	s3,s3,s1
    src += n;
    800016c4:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016c6:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016ca:	02098263          	beqz	s3,800016ee <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016ce:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016d2:	85ca                	mv	a1,s2
    800016d4:	855a                	mv	a0,s6
    800016d6:	00000097          	auipc	ra,0x0
    800016da:	9a2080e7          	jalr	-1630(ra) # 80001078 <walkaddr>
    if(pa0 == 0)
    800016de:	cd01                	beqz	a0,800016f6 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016e0:	418904b3          	sub	s1,s2,s8
    800016e4:	94d6                	add	s1,s1,s5
    if(n > len)
    800016e6:	fc99f3e3          	bgeu	s3,s1,800016ac <copyout+0x28>
    800016ea:	84ce                	mv	s1,s3
    800016ec:	b7c1                	j	800016ac <copyout+0x28>
  }
  return 0;
    800016ee:	4501                	li	a0,0
    800016f0:	a021                	j	800016f8 <copyout+0x74>
    800016f2:	4501                	li	a0,0
}
    800016f4:	8082                	ret
      return -1;
    800016f6:	557d                	li	a0,-1
}
    800016f8:	60a6                	ld	ra,72(sp)
    800016fa:	6406                	ld	s0,64(sp)
    800016fc:	74e2                	ld	s1,56(sp)
    800016fe:	7942                	ld	s2,48(sp)
    80001700:	79a2                	ld	s3,40(sp)
    80001702:	7a02                	ld	s4,32(sp)
    80001704:	6ae2                	ld	s5,24(sp)
    80001706:	6b42                	ld	s6,16(sp)
    80001708:	6ba2                	ld	s7,8(sp)
    8000170a:	6c02                	ld	s8,0(sp)
    8000170c:	6161                	addi	sp,sp,80
    8000170e:	8082                	ret

0000000080001710 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001710:	c6bd                	beqz	a3,8000177e <copyin+0x6e>
{
    80001712:	715d                	addi	sp,sp,-80
    80001714:	e486                	sd	ra,72(sp)
    80001716:	e0a2                	sd	s0,64(sp)
    80001718:	fc26                	sd	s1,56(sp)
    8000171a:	f84a                	sd	s2,48(sp)
    8000171c:	f44e                	sd	s3,40(sp)
    8000171e:	f052                	sd	s4,32(sp)
    80001720:	ec56                	sd	s5,24(sp)
    80001722:	e85a                	sd	s6,16(sp)
    80001724:	e45e                	sd	s7,8(sp)
    80001726:	e062                	sd	s8,0(sp)
    80001728:	0880                	addi	s0,sp,80
    8000172a:	8b2a                	mv	s6,a0
    8000172c:	8a2e                	mv	s4,a1
    8000172e:	8c32                	mv	s8,a2
    80001730:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001732:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001734:	6a85                	lui	s5,0x1
    80001736:	a015                	j	8000175a <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001738:	9562                	add	a0,a0,s8
    8000173a:	0004861b          	sext.w	a2,s1
    8000173e:	412505b3          	sub	a1,a0,s2
    80001742:	8552                	mv	a0,s4
    80001744:	fffff097          	auipc	ra,0xfffff
    80001748:	602080e7          	jalr	1538(ra) # 80000d46 <memmove>

    len -= n;
    8000174c:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001750:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001752:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001756:	02098263          	beqz	s3,8000177a <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    8000175a:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000175e:	85ca                	mv	a1,s2
    80001760:	855a                	mv	a0,s6
    80001762:	00000097          	auipc	ra,0x0
    80001766:	916080e7          	jalr	-1770(ra) # 80001078 <walkaddr>
    if(pa0 == 0)
    8000176a:	cd01                	beqz	a0,80001782 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    8000176c:	418904b3          	sub	s1,s2,s8
    80001770:	94d6                	add	s1,s1,s5
    if(n > len)
    80001772:	fc99f3e3          	bgeu	s3,s1,80001738 <copyin+0x28>
    80001776:	84ce                	mv	s1,s3
    80001778:	b7c1                	j	80001738 <copyin+0x28>
  }
  return 0;
    8000177a:	4501                	li	a0,0
    8000177c:	a021                	j	80001784 <copyin+0x74>
    8000177e:	4501                	li	a0,0
}
    80001780:	8082                	ret
      return -1;
    80001782:	557d                	li	a0,-1
}
    80001784:	60a6                	ld	ra,72(sp)
    80001786:	6406                	ld	s0,64(sp)
    80001788:	74e2                	ld	s1,56(sp)
    8000178a:	7942                	ld	s2,48(sp)
    8000178c:	79a2                	ld	s3,40(sp)
    8000178e:	7a02                	ld	s4,32(sp)
    80001790:	6ae2                	ld	s5,24(sp)
    80001792:	6b42                	ld	s6,16(sp)
    80001794:	6ba2                	ld	s7,8(sp)
    80001796:	6c02                	ld	s8,0(sp)
    80001798:	6161                	addi	sp,sp,80
    8000179a:	8082                	ret

000000008000179c <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000179c:	c6c5                	beqz	a3,80001844 <copyinstr+0xa8>
{
    8000179e:	715d                	addi	sp,sp,-80
    800017a0:	e486                	sd	ra,72(sp)
    800017a2:	e0a2                	sd	s0,64(sp)
    800017a4:	fc26                	sd	s1,56(sp)
    800017a6:	f84a                	sd	s2,48(sp)
    800017a8:	f44e                	sd	s3,40(sp)
    800017aa:	f052                	sd	s4,32(sp)
    800017ac:	ec56                	sd	s5,24(sp)
    800017ae:	e85a                	sd	s6,16(sp)
    800017b0:	e45e                	sd	s7,8(sp)
    800017b2:	0880                	addi	s0,sp,80
    800017b4:	8a2a                	mv	s4,a0
    800017b6:	8b2e                	mv	s6,a1
    800017b8:	8bb2                	mv	s7,a2
    800017ba:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017bc:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017be:	6985                	lui	s3,0x1
    800017c0:	a035                	j	800017ec <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017c2:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017c6:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017c8:	0017b793          	seqz	a5,a5
    800017cc:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017d0:	60a6                	ld	ra,72(sp)
    800017d2:	6406                	ld	s0,64(sp)
    800017d4:	74e2                	ld	s1,56(sp)
    800017d6:	7942                	ld	s2,48(sp)
    800017d8:	79a2                	ld	s3,40(sp)
    800017da:	7a02                	ld	s4,32(sp)
    800017dc:	6ae2                	ld	s5,24(sp)
    800017de:	6b42                	ld	s6,16(sp)
    800017e0:	6ba2                	ld	s7,8(sp)
    800017e2:	6161                	addi	sp,sp,80
    800017e4:	8082                	ret
    srcva = va0 + PGSIZE;
    800017e6:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017ea:	c8a9                	beqz	s1,8000183c <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017ec:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017f0:	85ca                	mv	a1,s2
    800017f2:	8552                	mv	a0,s4
    800017f4:	00000097          	auipc	ra,0x0
    800017f8:	884080e7          	jalr	-1916(ra) # 80001078 <walkaddr>
    if(pa0 == 0)
    800017fc:	c131                	beqz	a0,80001840 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017fe:	41790833          	sub	a6,s2,s7
    80001802:	984e                	add	a6,a6,s3
    if(n > max)
    80001804:	0104f363          	bgeu	s1,a6,8000180a <copyinstr+0x6e>
    80001808:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    8000180a:	955e                	add	a0,a0,s7
    8000180c:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001810:	fc080be3          	beqz	a6,800017e6 <copyinstr+0x4a>
    80001814:	985a                	add	a6,a6,s6
    80001816:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001818:	41650633          	sub	a2,a0,s6
    8000181c:	14fd                	addi	s1,s1,-1
    8000181e:	9b26                	add	s6,s6,s1
    80001820:	00f60733          	add	a4,a2,a5
    80001824:	00074703          	lbu	a4,0(a4)
    80001828:	df49                	beqz	a4,800017c2 <copyinstr+0x26>
        *dst = *p;
    8000182a:	00e78023          	sb	a4,0(a5)
      --max;
    8000182e:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001832:	0785                	addi	a5,a5,1
    while(n > 0){
    80001834:	ff0796e3          	bne	a5,a6,80001820 <copyinstr+0x84>
      dst++;
    80001838:	8b42                	mv	s6,a6
    8000183a:	b775                	j	800017e6 <copyinstr+0x4a>
    8000183c:	4781                	li	a5,0
    8000183e:	b769                	j	800017c8 <copyinstr+0x2c>
      return -1;
    80001840:	557d                	li	a0,-1
    80001842:	b779                	j	800017d0 <copyinstr+0x34>
  int got_null = 0;
    80001844:	4781                	li	a5,0
  if(got_null){
    80001846:	0017b793          	seqz	a5,a5
    8000184a:	40f00533          	neg	a0,a5
}
    8000184e:	8082                	ret

0000000080001850 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    80001850:	7139                	addi	sp,sp,-64
    80001852:	fc06                	sd	ra,56(sp)
    80001854:	f822                	sd	s0,48(sp)
    80001856:	f426                	sd	s1,40(sp)
    80001858:	f04a                	sd	s2,32(sp)
    8000185a:	ec4e                	sd	s3,24(sp)
    8000185c:	e852                	sd	s4,16(sp)
    8000185e:	e456                	sd	s5,8(sp)
    80001860:	e05a                	sd	s6,0(sp)
    80001862:	0080                	addi	s0,sp,64
    80001864:	89aa                	mv	s3,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80001866:	00010497          	auipc	s1,0x10
    8000186a:	9da48493          	addi	s1,s1,-1574 # 80011240 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    8000186e:	8b26                	mv	s6,s1
    80001870:	00006a97          	auipc	s5,0x6
    80001874:	790a8a93          	addi	s5,s5,1936 # 80008000 <etext>
    80001878:	04000937          	lui	s2,0x4000
    8000187c:	197d                	addi	s2,s2,-1
    8000187e:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001880:	00017a17          	auipc	s4,0x17
    80001884:	5c0a0a13          	addi	s4,s4,1472 # 80018e40 <tickslock>
    char *pa = kalloc();
    80001888:	fffff097          	auipc	ra,0xfffff
    8000188c:	272080e7          	jalr	626(ra) # 80000afa <kalloc>
    80001890:	862a                	mv	a2,a0
    if (pa == 0)
    80001892:	c131                	beqz	a0,800018d6 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    80001894:	416485b3          	sub	a1,s1,s6
    80001898:	8591                	srai	a1,a1,0x4
    8000189a:	000ab783          	ld	a5,0(s5)
    8000189e:	02f585b3          	mul	a1,a1,a5
    800018a2:	2585                	addiw	a1,a1,1
    800018a4:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018a8:	4719                	li	a4,6
    800018aa:	6685                	lui	a3,0x1
    800018ac:	40b905b3          	sub	a1,s2,a1
    800018b0:	854e                	mv	a0,s3
    800018b2:	00000097          	auipc	ra,0x0
    800018b6:	8a8080e7          	jalr	-1880(ra) # 8000115a <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    800018ba:	1f048493          	addi	s1,s1,496
    800018be:	fd4495e3          	bne	s1,s4,80001888 <proc_mapstacks+0x38>
  }
}
    800018c2:	70e2                	ld	ra,56(sp)
    800018c4:	7442                	ld	s0,48(sp)
    800018c6:	74a2                	ld	s1,40(sp)
    800018c8:	7902                	ld	s2,32(sp)
    800018ca:	69e2                	ld	s3,24(sp)
    800018cc:	6a42                	ld	s4,16(sp)
    800018ce:	6aa2                	ld	s5,8(sp)
    800018d0:	6b02                	ld	s6,0(sp)
    800018d2:	6121                	addi	sp,sp,64
    800018d4:	8082                	ret
      panic("kalloc");
    800018d6:	00007517          	auipc	a0,0x7
    800018da:	90250513          	addi	a0,a0,-1790 # 800081d8 <digits+0x198>
    800018de:	fffff097          	auipc	ra,0xfffff
    800018e2:	c66080e7          	jalr	-922(ra) # 80000544 <panic>

00000000800018e6 <procinit>:

// initialize the proc table.
void procinit(void)
{
    800018e6:	7139                	addi	sp,sp,-64
    800018e8:	fc06                	sd	ra,56(sp)
    800018ea:	f822                	sd	s0,48(sp)
    800018ec:	f426                	sd	s1,40(sp)
    800018ee:	f04a                	sd	s2,32(sp)
    800018f0:	ec4e                	sd	s3,24(sp)
    800018f2:	e852                	sd	s4,16(sp)
    800018f4:	e456                	sd	s5,8(sp)
    800018f6:	e05a                	sd	s6,0(sp)
    800018f8:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    800018fa:	00007597          	auipc	a1,0x7
    800018fe:	8e658593          	addi	a1,a1,-1818 # 800081e0 <digits+0x1a0>
    80001902:	0000f517          	auipc	a0,0xf
    80001906:	4de50513          	addi	a0,a0,1246 # 80010de0 <pid_lock>
    8000190a:	fffff097          	auipc	ra,0xfffff
    8000190e:	250080e7          	jalr	592(ra) # 80000b5a <initlock>
  initlock(&wait_lock, "wait_lock");
    80001912:	00007597          	auipc	a1,0x7
    80001916:	8d658593          	addi	a1,a1,-1834 # 800081e8 <digits+0x1a8>
    8000191a:	0000f517          	auipc	a0,0xf
    8000191e:	4de50513          	addi	a0,a0,1246 # 80010df8 <wait_lock>
    80001922:	fffff097          	auipc	ra,0xfffff
    80001926:	238080e7          	jalr	568(ra) # 80000b5a <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    8000192a:	00010497          	auipc	s1,0x10
    8000192e:	91648493          	addi	s1,s1,-1770 # 80011240 <proc>
  {
    initlock(&p->lock, "proc");
    80001932:	00007b17          	auipc	s6,0x7
    80001936:	8c6b0b13          	addi	s6,s6,-1850 # 800081f8 <digits+0x1b8>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    8000193a:	8aa6                	mv	s5,s1
    8000193c:	00006a17          	auipc	s4,0x6
    80001940:	6c4a0a13          	addi	s4,s4,1732 # 80008000 <etext>
    80001944:	04000937          	lui	s2,0x4000
    80001948:	197d                	addi	s2,s2,-1
    8000194a:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    8000194c:	00017997          	auipc	s3,0x17
    80001950:	4f498993          	addi	s3,s3,1268 # 80018e40 <tickslock>
    initlock(&p->lock, "proc");
    80001954:	85da                	mv	a1,s6
    80001956:	8526                	mv	a0,s1
    80001958:	fffff097          	auipc	ra,0xfffff
    8000195c:	202080e7          	jalr	514(ra) # 80000b5a <initlock>
    p->state = UNUSED;
    80001960:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001964:	415487b3          	sub	a5,s1,s5
    80001968:	8791                	srai	a5,a5,0x4
    8000196a:	000a3703          	ld	a4,0(s4)
    8000196e:	02e787b3          	mul	a5,a5,a4
    80001972:	2785                	addiw	a5,a5,1
    80001974:	00d7979b          	slliw	a5,a5,0xd
    80001978:	40f907b3          	sub	a5,s2,a5
    8000197c:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    8000197e:	1f048493          	addi	s1,s1,496
    80001982:	fd3499e3          	bne	s1,s3,80001954 <procinit+0x6e>
  }
}
    80001986:	70e2                	ld	ra,56(sp)
    80001988:	7442                	ld	s0,48(sp)
    8000198a:	74a2                	ld	s1,40(sp)
    8000198c:	7902                	ld	s2,32(sp)
    8000198e:	69e2                	ld	s3,24(sp)
    80001990:	6a42                	ld	s4,16(sp)
    80001992:	6aa2                	ld	s5,8(sp)
    80001994:	6b02                	ld	s6,0(sp)
    80001996:	6121                	addi	sp,sp,64
    80001998:	8082                	ret

000000008000199a <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    8000199a:	1141                	addi	sp,sp,-16
    8000199c:	e422                	sd	s0,8(sp)
    8000199e:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019a0:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800019a2:	2501                	sext.w	a0,a0
    800019a4:	6422                	ld	s0,8(sp)
    800019a6:	0141                	addi	sp,sp,16
    800019a8:	8082                	ret

00000000800019aa <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    800019aa:	1141                	addi	sp,sp,-16
    800019ac:	e422                	sd	s0,8(sp)
    800019ae:	0800                	addi	s0,sp,16
    800019b0:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019b2:	2781                	sext.w	a5,a5
    800019b4:	079e                	slli	a5,a5,0x7
  return c;
}
    800019b6:	0000f517          	auipc	a0,0xf
    800019ba:	45a50513          	addi	a0,a0,1114 # 80010e10 <cpus>
    800019be:	953e                	add	a0,a0,a5
    800019c0:	6422                	ld	s0,8(sp)
    800019c2:	0141                	addi	sp,sp,16
    800019c4:	8082                	ret

00000000800019c6 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    800019c6:	1101                	addi	sp,sp,-32
    800019c8:	ec06                	sd	ra,24(sp)
    800019ca:	e822                	sd	s0,16(sp)
    800019cc:	e426                	sd	s1,8(sp)
    800019ce:	1000                	addi	s0,sp,32
  push_off();
    800019d0:	fffff097          	auipc	ra,0xfffff
    800019d4:	1ce080e7          	jalr	462(ra) # 80000b9e <push_off>
    800019d8:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019da:	2781                	sext.w	a5,a5
    800019dc:	079e                	slli	a5,a5,0x7
    800019de:	0000f717          	auipc	a4,0xf
    800019e2:	40270713          	addi	a4,a4,1026 # 80010de0 <pid_lock>
    800019e6:	97ba                	add	a5,a5,a4
    800019e8:	7b84                	ld	s1,48(a5)
  pop_off();
    800019ea:	fffff097          	auipc	ra,0xfffff
    800019ee:	254080e7          	jalr	596(ra) # 80000c3e <pop_off>
  return p;
}
    800019f2:	8526                	mv	a0,s1
    800019f4:	60e2                	ld	ra,24(sp)
    800019f6:	6442                	ld	s0,16(sp)
    800019f8:	64a2                	ld	s1,8(sp)
    800019fa:	6105                	addi	sp,sp,32
    800019fc:	8082                	ret

00000000800019fe <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    800019fe:	1141                	addi	sp,sp,-16
    80001a00:	e406                	sd	ra,8(sp)
    80001a02:	e022                	sd	s0,0(sp)
    80001a04:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a06:	00000097          	auipc	ra,0x0
    80001a0a:	fc0080e7          	jalr	-64(ra) # 800019c6 <myproc>
    80001a0e:	fffff097          	auipc	ra,0xfffff
    80001a12:	290080e7          	jalr	656(ra) # 80000c9e <release>

  if (first)
    80001a16:	00007797          	auipc	a5,0x7
    80001a1a:	ffa7a783          	lw	a5,-6(a5) # 80008a10 <first.1761>
    80001a1e:	eb89                	bnez	a5,80001a30 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a20:	00001097          	auipc	ra,0x1
    80001a24:	21e080e7          	jalr	542(ra) # 80002c3e <usertrapret>
}
    80001a28:	60a2                	ld	ra,8(sp)
    80001a2a:	6402                	ld	s0,0(sp)
    80001a2c:	0141                	addi	sp,sp,16
    80001a2e:	8082                	ret
    first = 0;
    80001a30:	00007797          	auipc	a5,0x7
    80001a34:	fe07a023          	sw	zero,-32(a5) # 80008a10 <first.1761>
    fsinit(ROOTDEV);
    80001a38:	4505                	li	a0,1
    80001a3a:	00002097          	auipc	ra,0x2
    80001a3e:	264080e7          	jalr	612(ra) # 80003c9e <fsinit>
    80001a42:	bff9                	j	80001a20 <forkret+0x22>

0000000080001a44 <allocpid>:
{
    80001a44:	1101                	addi	sp,sp,-32
    80001a46:	ec06                	sd	ra,24(sp)
    80001a48:	e822                	sd	s0,16(sp)
    80001a4a:	e426                	sd	s1,8(sp)
    80001a4c:	e04a                	sd	s2,0(sp)
    80001a4e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a50:	0000f917          	auipc	s2,0xf
    80001a54:	39090913          	addi	s2,s2,912 # 80010de0 <pid_lock>
    80001a58:	854a                	mv	a0,s2
    80001a5a:	fffff097          	auipc	ra,0xfffff
    80001a5e:	190080e7          	jalr	400(ra) # 80000bea <acquire>
  pid = nextpid;
    80001a62:	00007797          	auipc	a5,0x7
    80001a66:	fb278793          	addi	a5,a5,-78 # 80008a14 <nextpid>
    80001a6a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a6c:	0014871b          	addiw	a4,s1,1
    80001a70:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a72:	854a                	mv	a0,s2
    80001a74:	fffff097          	auipc	ra,0xfffff
    80001a78:	22a080e7          	jalr	554(ra) # 80000c9e <release>
}
    80001a7c:	8526                	mv	a0,s1
    80001a7e:	60e2                	ld	ra,24(sp)
    80001a80:	6442                	ld	s0,16(sp)
    80001a82:	64a2                	ld	s1,8(sp)
    80001a84:	6902                	ld	s2,0(sp)
    80001a86:	6105                	addi	sp,sp,32
    80001a88:	8082                	ret

0000000080001a8a <proc_pagetable>:
{
    80001a8a:	1101                	addi	sp,sp,-32
    80001a8c:	ec06                	sd	ra,24(sp)
    80001a8e:	e822                	sd	s0,16(sp)
    80001a90:	e426                	sd	s1,8(sp)
    80001a92:	e04a                	sd	s2,0(sp)
    80001a94:	1000                	addi	s0,sp,32
    80001a96:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a98:	00000097          	auipc	ra,0x0
    80001a9c:	8ac080e7          	jalr	-1876(ra) # 80001344 <uvmcreate>
    80001aa0:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001aa2:	c121                	beqz	a0,80001ae2 <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001aa4:	4729                	li	a4,10
    80001aa6:	00005697          	auipc	a3,0x5
    80001aaa:	55a68693          	addi	a3,a3,1370 # 80007000 <_trampoline>
    80001aae:	6605                	lui	a2,0x1
    80001ab0:	040005b7          	lui	a1,0x4000
    80001ab4:	15fd                	addi	a1,a1,-1
    80001ab6:	05b2                	slli	a1,a1,0xc
    80001ab8:	fffff097          	auipc	ra,0xfffff
    80001abc:	602080e7          	jalr	1538(ra) # 800010ba <mappages>
    80001ac0:	02054863          	bltz	a0,80001af0 <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ac4:	4719                	li	a4,6
    80001ac6:	05893683          	ld	a3,88(s2)
    80001aca:	6605                	lui	a2,0x1
    80001acc:	020005b7          	lui	a1,0x2000
    80001ad0:	15fd                	addi	a1,a1,-1
    80001ad2:	05b6                	slli	a1,a1,0xd
    80001ad4:	8526                	mv	a0,s1
    80001ad6:	fffff097          	auipc	ra,0xfffff
    80001ada:	5e4080e7          	jalr	1508(ra) # 800010ba <mappages>
    80001ade:	02054163          	bltz	a0,80001b00 <proc_pagetable+0x76>
}
    80001ae2:	8526                	mv	a0,s1
    80001ae4:	60e2                	ld	ra,24(sp)
    80001ae6:	6442                	ld	s0,16(sp)
    80001ae8:	64a2                	ld	s1,8(sp)
    80001aea:	6902                	ld	s2,0(sp)
    80001aec:	6105                	addi	sp,sp,32
    80001aee:	8082                	ret
    uvmfree(pagetable, 0);
    80001af0:	4581                	li	a1,0
    80001af2:	8526                	mv	a0,s1
    80001af4:	00000097          	auipc	ra,0x0
    80001af8:	a54080e7          	jalr	-1452(ra) # 80001548 <uvmfree>
    return 0;
    80001afc:	4481                	li	s1,0
    80001afe:	b7d5                	j	80001ae2 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b00:	4681                	li	a3,0
    80001b02:	4605                	li	a2,1
    80001b04:	040005b7          	lui	a1,0x4000
    80001b08:	15fd                	addi	a1,a1,-1
    80001b0a:	05b2                	slli	a1,a1,0xc
    80001b0c:	8526                	mv	a0,s1
    80001b0e:	fffff097          	auipc	ra,0xfffff
    80001b12:	772080e7          	jalr	1906(ra) # 80001280 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b16:	4581                	li	a1,0
    80001b18:	8526                	mv	a0,s1
    80001b1a:	00000097          	auipc	ra,0x0
    80001b1e:	a2e080e7          	jalr	-1490(ra) # 80001548 <uvmfree>
    return 0;
    80001b22:	4481                	li	s1,0
    80001b24:	bf7d                	j	80001ae2 <proc_pagetable+0x58>

0000000080001b26 <proc_freepagetable>:
{
    80001b26:	1101                	addi	sp,sp,-32
    80001b28:	ec06                	sd	ra,24(sp)
    80001b2a:	e822                	sd	s0,16(sp)
    80001b2c:	e426                	sd	s1,8(sp)
    80001b2e:	e04a                	sd	s2,0(sp)
    80001b30:	1000                	addi	s0,sp,32
    80001b32:	84aa                	mv	s1,a0
    80001b34:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b36:	4681                	li	a3,0
    80001b38:	4605                	li	a2,1
    80001b3a:	040005b7          	lui	a1,0x4000
    80001b3e:	15fd                	addi	a1,a1,-1
    80001b40:	05b2                	slli	a1,a1,0xc
    80001b42:	fffff097          	auipc	ra,0xfffff
    80001b46:	73e080e7          	jalr	1854(ra) # 80001280 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b4a:	4681                	li	a3,0
    80001b4c:	4605                	li	a2,1
    80001b4e:	020005b7          	lui	a1,0x2000
    80001b52:	15fd                	addi	a1,a1,-1
    80001b54:	05b6                	slli	a1,a1,0xd
    80001b56:	8526                	mv	a0,s1
    80001b58:	fffff097          	auipc	ra,0xfffff
    80001b5c:	728080e7          	jalr	1832(ra) # 80001280 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b60:	85ca                	mv	a1,s2
    80001b62:	8526                	mv	a0,s1
    80001b64:	00000097          	auipc	ra,0x0
    80001b68:	9e4080e7          	jalr	-1564(ra) # 80001548 <uvmfree>
}
    80001b6c:	60e2                	ld	ra,24(sp)
    80001b6e:	6442                	ld	s0,16(sp)
    80001b70:	64a2                	ld	s1,8(sp)
    80001b72:	6902                	ld	s2,0(sp)
    80001b74:	6105                	addi	sp,sp,32
    80001b76:	8082                	ret

0000000080001b78 <freeproc>:
{
    80001b78:	1101                	addi	sp,sp,-32
    80001b7a:	ec06                	sd	ra,24(sp)
    80001b7c:	e822                	sd	s0,16(sp)
    80001b7e:	e426                	sd	s1,8(sp)
    80001b80:	1000                	addi	s0,sp,32
    80001b82:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001b84:	6d28                	ld	a0,88(a0)
    80001b86:	c509                	beqz	a0,80001b90 <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001b88:	fffff097          	auipc	ra,0xfffff
    80001b8c:	e76080e7          	jalr	-394(ra) # 800009fe <kfree>
  p->trapframe = 0;
    80001b90:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001b94:	68a8                	ld	a0,80(s1)
    80001b96:	c511                	beqz	a0,80001ba2 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b98:	64ac                	ld	a1,72(s1)
    80001b9a:	00000097          	auipc	ra,0x0
    80001b9e:	f8c080e7          	jalr	-116(ra) # 80001b26 <proc_freepagetable>
  p->pagetable = 0;
    80001ba2:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001ba6:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001baa:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001bae:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001bb2:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001bb6:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bba:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bbe:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bc2:	0004ac23          	sw	zero,24(s1)
}
    80001bc6:	60e2                	ld	ra,24(sp)
    80001bc8:	6442                	ld	s0,16(sp)
    80001bca:	64a2                	ld	s1,8(sp)
    80001bcc:	6105                	addi	sp,sp,32
    80001bce:	8082                	ret

0000000080001bd0 <allocproc>:
{
    80001bd0:	1101                	addi	sp,sp,-32
    80001bd2:	ec06                	sd	ra,24(sp)
    80001bd4:	e822                	sd	s0,16(sp)
    80001bd6:	e426                	sd	s1,8(sp)
    80001bd8:	e04a                	sd	s2,0(sp)
    80001bda:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001bdc:	0000f497          	auipc	s1,0xf
    80001be0:	66448493          	addi	s1,s1,1636 # 80011240 <proc>
    80001be4:	00017917          	auipc	s2,0x17
    80001be8:	25c90913          	addi	s2,s2,604 # 80018e40 <tickslock>
    acquire(&p->lock);
    80001bec:	8526                	mv	a0,s1
    80001bee:	fffff097          	auipc	ra,0xfffff
    80001bf2:	ffc080e7          	jalr	-4(ra) # 80000bea <acquire>
    if (p->state == UNUSED)
    80001bf6:	4c9c                	lw	a5,24(s1)
    80001bf8:	cf81                	beqz	a5,80001c10 <allocproc+0x40>
      release(&p->lock);
    80001bfa:	8526                	mv	a0,s1
    80001bfc:	fffff097          	auipc	ra,0xfffff
    80001c00:	0a2080e7          	jalr	162(ra) # 80000c9e <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001c04:	1f048493          	addi	s1,s1,496
    80001c08:	ff2492e3          	bne	s1,s2,80001bec <allocproc+0x1c>
  return 0;
    80001c0c:	4481                	li	s1,0
    80001c0e:	a0e1                	j	80001cd6 <allocproc+0x106>
  p->pid = allocpid();
    80001c10:	00000097          	auipc	ra,0x0
    80001c14:	e34080e7          	jalr	-460(ra) # 80001a44 <allocpid>
    80001c18:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c1a:	4785                	li	a5,1
    80001c1c:	cc9c                	sw	a5,24(s1)
  p->time_created = ticks;
    80001c1e:	00007797          	auipc	a5,0x7
    80001c22:	f527e783          	lwu	a5,-174(a5) # 80008b70 <ticks>
    80001c26:	16f4bc23          	sd	a5,376(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001c2a:	fffff097          	auipc	ra,0xfffff
    80001c2e:	ed0080e7          	jalr	-304(ra) # 80000afa <kalloc>
    80001c32:	892a                	mv	s2,a0
    80001c34:	eca8                	sd	a0,88(s1)
    80001c36:	c55d                	beqz	a0,80001ce4 <allocproc+0x114>
  p->pagetable = proc_pagetable(p);
    80001c38:	8526                	mv	a0,s1
    80001c3a:	00000097          	auipc	ra,0x0
    80001c3e:	e50080e7          	jalr	-432(ra) # 80001a8a <proc_pagetable>
    80001c42:	892a                	mv	s2,a0
    80001c44:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001c46:	c95d                	beqz	a0,80001cfc <allocproc+0x12c>
  memset(&p->context, 0, sizeof(p->context));
    80001c48:	07000613          	li	a2,112
    80001c4c:	4581                	li	a1,0
    80001c4e:	06048513          	addi	a0,s1,96
    80001c52:	fffff097          	auipc	ra,0xfffff
    80001c56:	094080e7          	jalr	148(ra) # 80000ce6 <memset>
  p->context.ra = (uint64)forkret;
    80001c5a:	00000797          	auipc	a5,0x0
    80001c5e:	da478793          	addi	a5,a5,-604 # 800019fe <forkret>
    80001c62:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c64:	60bc                	ld	a5,64(s1)
    80001c66:	6705                	lui	a4,0x1
    80001c68:	97ba                	add	a5,a5,a4
    80001c6a:	f4bc                	sd	a5,104(s1)
  p->rtime = 0;
    80001c6c:	1604a623          	sw	zero,364(s1)
  p->etime = 0;
    80001c70:	1604aa23          	sw	zero,372(s1)
  p->ctime = ticks;
    80001c74:	00007797          	auipc	a5,0x7
    80001c78:	efc7a783          	lw	a5,-260(a5) # 80008b70 <ticks>
    80001c7c:	16f4a823          	sw	a5,368(s1)
  p->alarm_on = 0;
    80001c80:	1804ac23          	sw	zero,408(s1)
  p->cur_ticks = 0;
    80001c84:	1804a623          	sw	zero,396(s1)
  p->runtime = 0;
    80001c88:	1a04bc23          	sd	zero,440(s1)
  p->starttime = 0;
    80001c8c:	1c04b023          	sd	zero,448(s1)
  p->sleeptime = 0;
    80001c90:	1c04b423          	sd	zero,456(s1)
  p->runcount = 0;
    80001c94:	1c04b823          	sd	zero,464(s1)
  p->priority = 60;
    80001c98:	03c00793          	li	a5,60
    80001c9c:	1cf4bc23          	sd	a5,472(s1)
  p->handlerpermission = 1;
    80001ca0:	4785                	li	a5,1
    80001ca2:	1af4a823          	sw	a5,432(s1)
  p->tickets = 1;
    80001ca6:	1af4aa23          	sw	a5,436(s1)
  p->tickcount = 0;
    80001caa:	1e04a023          	sw	zero,480(s1)
  p->queue = 0;
    80001cae:	1e04a223          	sw	zero,484(s1)
  p->waittickcount = 0;
    80001cb2:	1e04a423          	sw	zero,488(s1)
  p->queueposition = queueprocesscount[0];
    80001cb6:	0000f797          	auipc	a5,0xf
    80001cba:	12a78793          	addi	a5,a5,298 # 80010de0 <pid_lock>
    80001cbe:	4307a703          	lw	a4,1072(a5)
    80001cc2:	1ee4a623          	sw	a4,492(s1)
  queueprocesscount[0]++;
    80001cc6:	2705                	addiw	a4,a4,1
    80001cc8:	42e7a823          	sw	a4,1072(a5)
  queuemaxindex[0]++;
    80001ccc:	4487a703          	lw	a4,1096(a5)
    80001cd0:	2705                	addiw	a4,a4,1
    80001cd2:	44e7a423          	sw	a4,1096(a5)
}
    80001cd6:	8526                	mv	a0,s1
    80001cd8:	60e2                	ld	ra,24(sp)
    80001cda:	6442                	ld	s0,16(sp)
    80001cdc:	64a2                	ld	s1,8(sp)
    80001cde:	6902                	ld	s2,0(sp)
    80001ce0:	6105                	addi	sp,sp,32
    80001ce2:	8082                	ret
    freeproc(p);
    80001ce4:	8526                	mv	a0,s1
    80001ce6:	00000097          	auipc	ra,0x0
    80001cea:	e92080e7          	jalr	-366(ra) # 80001b78 <freeproc>
    release(&p->lock);
    80001cee:	8526                	mv	a0,s1
    80001cf0:	fffff097          	auipc	ra,0xfffff
    80001cf4:	fae080e7          	jalr	-82(ra) # 80000c9e <release>
    return 0;
    80001cf8:	84ca                	mv	s1,s2
    80001cfa:	bff1                	j	80001cd6 <allocproc+0x106>
    freeproc(p);
    80001cfc:	8526                	mv	a0,s1
    80001cfe:	00000097          	auipc	ra,0x0
    80001d02:	e7a080e7          	jalr	-390(ra) # 80001b78 <freeproc>
    release(&p->lock);
    80001d06:	8526                	mv	a0,s1
    80001d08:	fffff097          	auipc	ra,0xfffff
    80001d0c:	f96080e7          	jalr	-106(ra) # 80000c9e <release>
    return 0;
    80001d10:	84ca                	mv	s1,s2
    80001d12:	b7d1                	j	80001cd6 <allocproc+0x106>

0000000080001d14 <userinit>:
{
    80001d14:	1101                	addi	sp,sp,-32
    80001d16:	ec06                	sd	ra,24(sp)
    80001d18:	e822                	sd	s0,16(sp)
    80001d1a:	e426                	sd	s1,8(sp)
    80001d1c:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d1e:	00000097          	auipc	ra,0x0
    80001d22:	eb2080e7          	jalr	-334(ra) # 80001bd0 <allocproc>
    80001d26:	84aa                	mv	s1,a0
  initproc = p;
    80001d28:	00007797          	auipc	a5,0x7
    80001d2c:	e4a7b023          	sd	a0,-448(a5) # 80008b68 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001d30:	03400613          	li	a2,52
    80001d34:	00007597          	auipc	a1,0x7
    80001d38:	cec58593          	addi	a1,a1,-788 # 80008a20 <initcode>
    80001d3c:	6928                	ld	a0,80(a0)
    80001d3e:	fffff097          	auipc	ra,0xfffff
    80001d42:	634080e7          	jalr	1588(ra) # 80001372 <uvmfirst>
  p->sz = PGSIZE;
    80001d46:	6785                	lui	a5,0x1
    80001d48:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001d4a:	6cb8                	ld	a4,88(s1)
    80001d4c:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001d50:	6cb8                	ld	a4,88(s1)
    80001d52:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d54:	4641                	li	a2,16
    80001d56:	00006597          	auipc	a1,0x6
    80001d5a:	4aa58593          	addi	a1,a1,1194 # 80008200 <digits+0x1c0>
    80001d5e:	15848513          	addi	a0,s1,344
    80001d62:	fffff097          	auipc	ra,0xfffff
    80001d66:	0d6080e7          	jalr	214(ra) # 80000e38 <safestrcpy>
  p->cwd = namei("/");
    80001d6a:	00006517          	auipc	a0,0x6
    80001d6e:	4a650513          	addi	a0,a0,1190 # 80008210 <digits+0x1d0>
    80001d72:	00003097          	auipc	ra,0x3
    80001d76:	94e080e7          	jalr	-1714(ra) # 800046c0 <namei>
    80001d7a:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d7e:	478d                	li	a5,3
    80001d80:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d82:	8526                	mv	a0,s1
    80001d84:	fffff097          	auipc	ra,0xfffff
    80001d88:	f1a080e7          	jalr	-230(ra) # 80000c9e <release>
}
    80001d8c:	60e2                	ld	ra,24(sp)
    80001d8e:	6442                	ld	s0,16(sp)
    80001d90:	64a2                	ld	s1,8(sp)
    80001d92:	6105                	addi	sp,sp,32
    80001d94:	8082                	ret

0000000080001d96 <growproc>:
{
    80001d96:	1101                	addi	sp,sp,-32
    80001d98:	ec06                	sd	ra,24(sp)
    80001d9a:	e822                	sd	s0,16(sp)
    80001d9c:	e426                	sd	s1,8(sp)
    80001d9e:	e04a                	sd	s2,0(sp)
    80001da0:	1000                	addi	s0,sp,32
    80001da2:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001da4:	00000097          	auipc	ra,0x0
    80001da8:	c22080e7          	jalr	-990(ra) # 800019c6 <myproc>
    80001dac:	84aa                	mv	s1,a0
  sz = p->sz;
    80001dae:	652c                	ld	a1,72(a0)
  if (n > 0)
    80001db0:	01204c63          	bgtz	s2,80001dc8 <growproc+0x32>
  else if (n < 0)
    80001db4:	02094663          	bltz	s2,80001de0 <growproc+0x4a>
  p->sz = sz;
    80001db8:	e4ac                	sd	a1,72(s1)
  return 0;
    80001dba:	4501                	li	a0,0
}
    80001dbc:	60e2                	ld	ra,24(sp)
    80001dbe:	6442                	ld	s0,16(sp)
    80001dc0:	64a2                	ld	s1,8(sp)
    80001dc2:	6902                	ld	s2,0(sp)
    80001dc4:	6105                	addi	sp,sp,32
    80001dc6:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001dc8:	4691                	li	a3,4
    80001dca:	00b90633          	add	a2,s2,a1
    80001dce:	6928                	ld	a0,80(a0)
    80001dd0:	fffff097          	auipc	ra,0xfffff
    80001dd4:	65c080e7          	jalr	1628(ra) # 8000142c <uvmalloc>
    80001dd8:	85aa                	mv	a1,a0
    80001dda:	fd79                	bnez	a0,80001db8 <growproc+0x22>
      return -1;
    80001ddc:	557d                	li	a0,-1
    80001dde:	bff9                	j	80001dbc <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001de0:	00b90633          	add	a2,s2,a1
    80001de4:	6928                	ld	a0,80(a0)
    80001de6:	fffff097          	auipc	ra,0xfffff
    80001dea:	5fe080e7          	jalr	1534(ra) # 800013e4 <uvmdealloc>
    80001dee:	85aa                	mv	a1,a0
    80001df0:	b7e1                	j	80001db8 <growproc+0x22>

0000000080001df2 <fork>:
{
    80001df2:	7179                	addi	sp,sp,-48
    80001df4:	f406                	sd	ra,40(sp)
    80001df6:	f022                	sd	s0,32(sp)
    80001df8:	ec26                	sd	s1,24(sp)
    80001dfa:	e84a                	sd	s2,16(sp)
    80001dfc:	e44e                	sd	s3,8(sp)
    80001dfe:	e052                	sd	s4,0(sp)
    80001e00:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e02:	00000097          	auipc	ra,0x0
    80001e06:	bc4080e7          	jalr	-1084(ra) # 800019c6 <myproc>
    80001e0a:	892a                	mv	s2,a0
  if ((np = allocproc()) == 0)
    80001e0c:	00000097          	auipc	ra,0x0
    80001e10:	dc4080e7          	jalr	-572(ra) # 80001bd0 <allocproc>
    80001e14:	12050363          	beqz	a0,80001f3a <fork+0x148>
    80001e18:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001e1a:	04893603          	ld	a2,72(s2)
    80001e1e:	692c                	ld	a1,80(a0)
    80001e20:	05093503          	ld	a0,80(s2)
    80001e24:	fffff097          	auipc	ra,0xfffff
    80001e28:	75c080e7          	jalr	1884(ra) # 80001580 <uvmcopy>
    80001e2c:	04054a63          	bltz	a0,80001e80 <fork+0x8e>
  np->sz = p->sz;
    80001e30:	04893783          	ld	a5,72(s2)
    80001e34:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001e38:	05893683          	ld	a3,88(s2)
    80001e3c:	87b6                	mv	a5,a3
    80001e3e:	0589b703          	ld	a4,88(s3)
    80001e42:	12068693          	addi	a3,a3,288
    80001e46:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e4a:	6788                	ld	a0,8(a5)
    80001e4c:	6b8c                	ld	a1,16(a5)
    80001e4e:	6f90                	ld	a2,24(a5)
    80001e50:	01073023          	sd	a6,0(a4)
    80001e54:	e708                	sd	a0,8(a4)
    80001e56:	eb0c                	sd	a1,16(a4)
    80001e58:	ef10                	sd	a2,24(a4)
    80001e5a:	02078793          	addi	a5,a5,32
    80001e5e:	02070713          	addi	a4,a4,32
    80001e62:	fed792e3          	bne	a5,a3,80001e46 <fork+0x54>
  np->mask = p->mask;
    80001e66:	16892783          	lw	a5,360(s2)
    80001e6a:	16f9a423          	sw	a5,360(s3)
  np->trapframe->a0 = 0;
    80001e6e:	0589b783          	ld	a5,88(s3)
    80001e72:	0607b823          	sd	zero,112(a5)
    80001e76:	0d000493          	li	s1,208
  for (i = 0; i < NOFILE; i++)
    80001e7a:	15000a13          	li	s4,336
    80001e7e:	a03d                	j	80001eac <fork+0xba>
    freeproc(np);
    80001e80:	854e                	mv	a0,s3
    80001e82:	00000097          	auipc	ra,0x0
    80001e86:	cf6080e7          	jalr	-778(ra) # 80001b78 <freeproc>
    release(&np->lock);
    80001e8a:	854e                	mv	a0,s3
    80001e8c:	fffff097          	auipc	ra,0xfffff
    80001e90:	e12080e7          	jalr	-494(ra) # 80000c9e <release>
    return -1;
    80001e94:	5a7d                	li	s4,-1
    80001e96:	a849                	j	80001f28 <fork+0x136>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e98:	00003097          	auipc	ra,0x3
    80001e9c:	ebe080e7          	jalr	-322(ra) # 80004d56 <filedup>
    80001ea0:	009987b3          	add	a5,s3,s1
    80001ea4:	e388                	sd	a0,0(a5)
  for (i = 0; i < NOFILE; i++)
    80001ea6:	04a1                	addi	s1,s1,8
    80001ea8:	01448763          	beq	s1,s4,80001eb6 <fork+0xc4>
    if (p->ofile[i])
    80001eac:	009907b3          	add	a5,s2,s1
    80001eb0:	6388                	ld	a0,0(a5)
    80001eb2:	f17d                	bnez	a0,80001e98 <fork+0xa6>
    80001eb4:	bfcd                	j	80001ea6 <fork+0xb4>
  np->cwd = idup(p->cwd);
    80001eb6:	15093503          	ld	a0,336(s2)
    80001eba:	00002097          	auipc	ra,0x2
    80001ebe:	022080e7          	jalr	34(ra) # 80003edc <idup>
    80001ec2:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ec6:	4641                	li	a2,16
    80001ec8:	15890593          	addi	a1,s2,344
    80001ecc:	15898513          	addi	a0,s3,344
    80001ed0:	fffff097          	auipc	ra,0xfffff
    80001ed4:	f68080e7          	jalr	-152(ra) # 80000e38 <safestrcpy>
  pid = np->pid;
    80001ed8:	0309aa03          	lw	s4,48(s3)
  release(&np->lock);
    80001edc:	854e                	mv	a0,s3
    80001ede:	fffff097          	auipc	ra,0xfffff
    80001ee2:	dc0080e7          	jalr	-576(ra) # 80000c9e <release>
  acquire(&wait_lock);
    80001ee6:	0000f497          	auipc	s1,0xf
    80001eea:	f1248493          	addi	s1,s1,-238 # 80010df8 <wait_lock>
    80001eee:	8526                	mv	a0,s1
    80001ef0:	fffff097          	auipc	ra,0xfffff
    80001ef4:	cfa080e7          	jalr	-774(ra) # 80000bea <acquire>
  np->parent = p;
    80001ef8:	0329bc23          	sd	s2,56(s3)
  np->tickets = np->parent->tickets;
    80001efc:	1b492783          	lw	a5,436(s2)
    80001f00:	1af9aa23          	sw	a5,436(s3)
  release(&wait_lock);
    80001f04:	8526                	mv	a0,s1
    80001f06:	fffff097          	auipc	ra,0xfffff
    80001f0a:	d98080e7          	jalr	-616(ra) # 80000c9e <release>
  acquire(&np->lock);
    80001f0e:	854e                	mv	a0,s3
    80001f10:	fffff097          	auipc	ra,0xfffff
    80001f14:	cda080e7          	jalr	-806(ra) # 80000bea <acquire>
  np->state = RUNNABLE;
    80001f18:	478d                	li	a5,3
    80001f1a:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001f1e:	854e                	mv	a0,s3
    80001f20:	fffff097          	auipc	ra,0xfffff
    80001f24:	d7e080e7          	jalr	-642(ra) # 80000c9e <release>
}
    80001f28:	8552                	mv	a0,s4
    80001f2a:	70a2                	ld	ra,40(sp)
    80001f2c:	7402                	ld	s0,32(sp)
    80001f2e:	64e2                	ld	s1,24(sp)
    80001f30:	6942                	ld	s2,16(sp)
    80001f32:	69a2                	ld	s3,8(sp)
    80001f34:	6a02                	ld	s4,0(sp)
    80001f36:	6145                	addi	sp,sp,48
    80001f38:	8082                	ret
    return -1;
    80001f3a:	5a7d                	li	s4,-1
    80001f3c:	b7f5                	j	80001f28 <fork+0x136>

0000000080001f3e <max>:
{
    80001f3e:	1141                	addi	sp,sp,-16
    80001f40:	e422                	sd	s0,8(sp)
    80001f42:	0800                	addi	s0,sp,16
  if (a > b)
    80001f44:	87aa                	mv	a5,a0
    80001f46:	00b55363          	bge	a0,a1,80001f4c <max+0xe>
    80001f4a:	87ae                	mv	a5,a1
}
    80001f4c:	0007851b          	sext.w	a0,a5
    80001f50:	6422                	ld	s0,8(sp)
    80001f52:	0141                	addi	sp,sp,16
    80001f54:	8082                	ret

0000000080001f56 <min>:
{
    80001f56:	1141                	addi	sp,sp,-16
    80001f58:	e422                	sd	s0,8(sp)
    80001f5a:	0800                	addi	s0,sp,16
  if (a < b)
    80001f5c:	87aa                	mv	a5,a0
    80001f5e:	00a5d363          	bge	a1,a0,80001f64 <min+0xe>
    80001f62:	87ae                	mv	a5,a1
}
    80001f64:	0007851b          	sext.w	a0,a5
    80001f68:	6422                	ld	s0,8(sp)
    80001f6a:	0141                	addi	sp,sp,16
    80001f6c:	8082                	ret

0000000080001f6e <update_time>:
{
    80001f6e:	7179                	addi	sp,sp,-48
    80001f70:	f406                	sd	ra,40(sp)
    80001f72:	f022                	sd	s0,32(sp)
    80001f74:	ec26                	sd	s1,24(sp)
    80001f76:	e84a                	sd	s2,16(sp)
    80001f78:	e44e                	sd	s3,8(sp)
    80001f7a:	1800                	addi	s0,sp,48
  for (p = proc; p < &proc[NPROC]; p++)
    80001f7c:	0000f497          	auipc	s1,0xf
    80001f80:	2c448493          	addi	s1,s1,708 # 80011240 <proc>
    if (p->state == RUNNING)
    80001f84:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++)
    80001f86:	00017917          	auipc	s2,0x17
    80001f8a:	eba90913          	addi	s2,s2,-326 # 80018e40 <tickslock>
    80001f8e:	a811                	j	80001fa2 <update_time+0x34>
    release(&p->lock);
    80001f90:	8526                	mv	a0,s1
    80001f92:	fffff097          	auipc	ra,0xfffff
    80001f96:	d0c080e7          	jalr	-756(ra) # 80000c9e <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001f9a:	1f048493          	addi	s1,s1,496
    80001f9e:	03248063          	beq	s1,s2,80001fbe <update_time+0x50>
    acquire(&p->lock);
    80001fa2:	8526                	mv	a0,s1
    80001fa4:	fffff097          	auipc	ra,0xfffff
    80001fa8:	c46080e7          	jalr	-954(ra) # 80000bea <acquire>
    if (p->state == RUNNING)
    80001fac:	4c9c                	lw	a5,24(s1)
    80001fae:	ff3791e3          	bne	a5,s3,80001f90 <update_time+0x22>
      p->rtime++;
    80001fb2:	16c4a783          	lw	a5,364(s1)
    80001fb6:	2785                	addiw	a5,a5,1
    80001fb8:	16f4a623          	sw	a5,364(s1)
    80001fbc:	bfd1                	j	80001f90 <update_time+0x22>
}
    80001fbe:	70a2                	ld	ra,40(sp)
    80001fc0:	7402                	ld	s0,32(sp)
    80001fc2:	64e2                	ld	s1,24(sp)
    80001fc4:	6942                	ld	s2,16(sp)
    80001fc6:	69a2                	ld	s3,8(sp)
    80001fc8:	6145                	addi	sp,sp,48
    80001fca:	8082                	ret

0000000080001fcc <randomnum>:
{
    80001fcc:	1141                	addi	sp,sp,-16
    80001fce:	e422                	sd	s0,8(sp)
    80001fd0:	0800                	addi	s0,sp,16
  uint64 num = (uint64)ticks;
    80001fd2:	00007797          	auipc	a5,0x7
    80001fd6:	b9e7e783          	lwu	a5,-1122(a5) # 80008b70 <ticks>
  num = num ^ (num << 13);
    80001fda:	00d79713          	slli	a4,a5,0xd
    80001fde:	8fb9                	xor	a5,a5,a4
  num = num ^ (num >> 17);
    80001fe0:	0117d713          	srli	a4,a5,0x11
    80001fe4:	8f3d                	xor	a4,a4,a5
  num = num ^ (num << 5);
    80001fe6:	00571793          	slli	a5,a4,0x5
    80001fea:	8fb9                	xor	a5,a5,a4
  num = num % (max - min);
    80001fec:	9d89                	subw	a1,a1,a0
    80001fee:	02b7f7b3          	remu	a5,a5,a1
}
    80001ff2:	9d3d                	addw	a0,a0,a5
    80001ff4:	6422                	ld	s0,8(sp)
    80001ff6:	0141                	addi	sp,sp,16
    80001ff8:	8082                	ret

0000000080001ffa <scheduler>:
{
    80001ffa:	7135                	addi	sp,sp,-160
    80001ffc:	ed06                	sd	ra,152(sp)
    80001ffe:	e922                	sd	s0,144(sp)
    80002000:	e526                	sd	s1,136(sp)
    80002002:	e14a                	sd	s2,128(sp)
    80002004:	fcce                	sd	s3,120(sp)
    80002006:	f8d2                	sd	s4,112(sp)
    80002008:	f4d6                	sd	s5,104(sp)
    8000200a:	f0da                	sd	s6,96(sp)
    8000200c:	ecde                	sd	s7,88(sp)
    8000200e:	e8e2                	sd	s8,80(sp)
    80002010:	e4e6                	sd	s9,72(sp)
    80002012:	e0ea                	sd	s10,64(sp)
    80002014:	fc6e                	sd	s11,56(sp)
    80002016:	1100                	addi	s0,sp,160
    80002018:	8792                	mv	a5,tp
  int id = r_tp();
    8000201a:	2781                	sext.w	a5,a5
  int maxticks[5] = {1, 2, 4, 8, 16};
    8000201c:	4705                	li	a4,1
    8000201e:	f6e42c23          	sw	a4,-136(s0)
    80002022:	4709                	li	a4,2
    80002024:	f6e42e23          	sw	a4,-132(s0)
    80002028:	4711                	li	a4,4
    8000202a:	f8e42023          	sw	a4,-128(s0)
    8000202e:	4721                	li	a4,8
    80002030:	f8e42223          	sw	a4,-124(s0)
    80002034:	4741                	li	a4,16
    80002036:	f8e42423          	sw	a4,-120(s0)
  c->proc = 0;
    8000203a:	00779c13          	slli	s8,a5,0x7
    8000203e:	0000f717          	auipc	a4,0xf
    80002042:	da270713          	addi	a4,a4,-606 # 80010de0 <pid_lock>
    80002046:	9762                	add	a4,a4,s8
    80002048:	02073823          	sd	zero,48(a4)
          swtch(&c->context, &p->context);
    8000204c:	0000f717          	auipc	a4,0xf
    80002050:	dcc70713          	addi	a4,a4,-564 # 80010e18 <cpus+0x8>
    80002054:	9c3a                	add	s8,s8,a4
    for (p = proc; p < &proc[NPROC]; p++)
    80002056:	00017497          	auipc	s1,0x17
    8000205a:	dea48493          	addi	s1,s1,-534 # 80018e40 <tickslock>
      int minqueueval = 1000000;
    8000205e:	000f4737          	lui	a4,0xf4
    80002062:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002066:	f6e43423          	sd	a4,-152(s0)
              queueprocesscount[p->queue]--;
    8000206a:	0000f997          	auipc	s3,0xf
    8000206e:	d7698993          	addi	s3,s3,-650 # 80010de0 <pid_lock>
          c->proc = p;
    80002072:	079e                	slli	a5,a5,0x7
    80002074:	00f98b33          	add	s6,s3,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002078:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000207c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002080:	10079073          	csrw	sstatus,a5
    int minqueue = 5;
    80002084:	4a15                	li	s4,5
    for (p = proc; p < &proc[NPROC]; p++)
    80002086:	0000f917          	auipc	s2,0xf
    8000208a:	1ba90913          	addi	s2,s2,442 # 80011240 <proc>
      if (p->state == RUNNABLE && p->queue < minqueue)
    8000208e:	4a8d                	li	s5,3
    80002090:	a821                	j	800020a8 <scheduler+0xae>
    80002092:	00078a1b          	sext.w	s4,a5
      release(&p->lock);
    80002096:	854a                	mv	a0,s2
    80002098:	fffff097          	auipc	ra,0xfffff
    8000209c:	c06080e7          	jalr	-1018(ra) # 80000c9e <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800020a0:	1f090913          	addi	s2,s2,496
    800020a4:	02990363          	beq	s2,s1,800020ca <scheduler+0xd0>
      acquire(&p->lock);
    800020a8:	854a                	mv	a0,s2
    800020aa:	fffff097          	auipc	ra,0xfffff
    800020ae:	b40080e7          	jalr	-1216(ra) # 80000bea <acquire>
      if (p->state == RUNNABLE && p->queue < minqueue)
    800020b2:	01892783          	lw	a5,24(s2)
    800020b6:	ff5790e3          	bne	a5,s5,80002096 <scheduler+0x9c>
    800020ba:	1e492783          	lw	a5,484(s2)
    800020be:	0007871b          	sext.w	a4,a5
    800020c2:	fcea58e3          	bge	s4,a4,80002092 <scheduler+0x98>
    800020c6:	87d2                	mv	a5,s4
    800020c8:	b7e9                	j	80002092 <scheduler+0x98>
    if (minqueue == 4)
    800020ca:	4791                	li	a5,4
    800020cc:	0cfa1d63          	bne	s4,a5,800021a6 <scheduler+0x1ac>
      for (p = proc; p < &proc[NPROC]; p++)
    800020d0:	0000fa17          	auipc	s4,0xf
    800020d4:	170a0a13          	addi	s4,s4,368 # 80011240 <proc>
        if (p->state == RUNNABLE)
    800020d8:	4a8d                	li	s5,3
              if (q->waittickcount >= 30)
    800020da:	4bf5                	li	s7,29
    800020dc:	a849                	j	8000216e <scheduler+0x174>
              release(&q->lock);
    800020de:	854a                	mv	a0,s2
    800020e0:	fffff097          	auipc	ra,0xfffff
    800020e4:	bbe080e7          	jalr	-1090(ra) # 80000c9e <release>
          for (q = proc; q < &proc[NPROC]; q++)
    800020e8:	1f090913          	addi	s2,s2,496
    800020ec:	06990863          	beq	s2,s1,8000215c <scheduler+0x162>
            if (p != q && q->state == RUNNABLE)
    800020f0:	ff2a0ce3          	beq	s4,s2,800020e8 <scheduler+0xee>
    800020f4:	01892783          	lw	a5,24(s2)
    800020f8:	ff5798e3          	bne	a5,s5,800020e8 <scheduler+0xee>
              acquire(&q->lock);
    800020fc:	854a                	mv	a0,s2
    800020fe:	fffff097          	auipc	ra,0xfffff
    80002102:	aec080e7          	jalr	-1300(ra) # 80000bea <acquire>
              q->waittickcount++;
    80002106:	1e892783          	lw	a5,488(s2)
    8000210a:	2785                	addiw	a5,a5,1
    8000210c:	0007871b          	sext.w	a4,a5
    80002110:	1ef92423          	sw	a5,488(s2)
              if (q->waittickcount >= 30)
    80002114:	fcebd5e3          	bge	s7,a4,800020de <scheduler+0xe4>
                queueprocesscount[q->queue]--;
    80002118:	1e492703          	lw	a4,484(s2)
    8000211c:	00271793          	slli	a5,a4,0x2
    80002120:	97ce                	add	a5,a5,s3
    80002122:	4307a683          	lw	a3,1072(a5)
    80002126:	36fd                	addiw	a3,a3,-1
    80002128:	42d7a823          	sw	a3,1072(a5)
                q->queue--;
    8000212c:	377d                	addiw	a4,a4,-1
    8000212e:	0007079b          	sext.w	a5,a4
    80002132:	1ee92223          	sw	a4,484(s2)
                queueprocesscount[q->queue]++;
    80002136:	078a                	slli	a5,a5,0x2
    80002138:	97ce                	add	a5,a5,s3
    8000213a:	4307a703          	lw	a4,1072(a5)
    8000213e:	2705                	addiw	a4,a4,1
    80002140:	42e7a823          	sw	a4,1072(a5)
                q->tickcount = 0;
    80002144:	1e092023          	sw	zero,480(s2)
                q->waittickcount = 0;
    80002148:	1e092423          	sw	zero,488(s2)
                q->queueposition = queuemaxindex[q->queue];
    8000214c:	4487a703          	lw	a4,1096(a5)
    80002150:	1ee92623          	sw	a4,492(s2)
                queuemaxindex[q->queue]++;
    80002154:	2705                	addiw	a4,a4,1
    80002156:	44e7a423          	sw	a4,1096(a5)
    8000215a:	b751                	j	800020de <scheduler+0xe4>
        release(&p->lock);
    8000215c:	8552                	mv	a0,s4
    8000215e:	fffff097          	auipc	ra,0xfffff
    80002162:	b40080e7          	jalr	-1216(ra) # 80000c9e <release>
      for (p = proc; p < &proc[NPROC]; p++)
    80002166:	1f0a0a13          	addi	s4,s4,496
    8000216a:	f09a07e3          	beq	s4,s1,80002078 <scheduler+0x7e>
        acquire(&p->lock);
    8000216e:	8552                	mv	a0,s4
    80002170:	fffff097          	auipc	ra,0xfffff
    80002174:	a7a080e7          	jalr	-1414(ra) # 80000bea <acquire>
        if (p->state == RUNNABLE)
    80002178:	018a2783          	lw	a5,24(s4)
    8000217c:	ff5790e3          	bne	a5,s5,8000215c <scheduler+0x162>
          p->state = RUNNING;
    80002180:	4791                	li	a5,4
    80002182:	00fa2c23          	sw	a5,24(s4)
          c->proc = p;
    80002186:	034b3823          	sd	s4,48(s6)
          swtch(&c->context, &p->context);
    8000218a:	060a0593          	addi	a1,s4,96
    8000218e:	8562                	mv	a0,s8
    80002190:	00001097          	auipc	ra,0x1
    80002194:	a04080e7          	jalr	-1532(ra) # 80002b94 <swtch>
          c->proc = 0;
    80002198:	020b3823          	sd	zero,48(s6)
          for (q = proc; q < &proc[NPROC]; q++)
    8000219c:	0000f917          	auipc	s2,0xf
    800021a0:	0a490913          	addi	s2,s2,164 # 80011240 <proc>
    800021a4:	b7b1                	j	800020f0 <scheduler+0xf6>
      struct proc *run_process = 0;
    800021a6:	4b81                	li	s7,0
      int minqueueval = 1000000;
    800021a8:	f6843c83          	ld	s9,-152(s0)
      for (p = proc; p < &proc[NPROC]; p++)
    800021ac:	0000f917          	auipc	s2,0xf
    800021b0:	09490913          	addi	s2,s2,148 # 80011240 <proc>
        if (p->state == RUNNABLE && p->queue == minqueue)
    800021b4:	4a8d                	li	s5,3
    800021b6:	a811                	j	800021ca <scheduler+0x1d0>
        release(&p->lock);
    800021b8:	854a                	mv	a0,s2
    800021ba:	fffff097          	auipc	ra,0xfffff
    800021be:	ae4080e7          	jalr	-1308(ra) # 80000c9e <release>
      for (p = proc; p < &proc[NPROC]; p++)
    800021c2:	1f090913          	addi	s2,s2,496
    800021c6:	02990663          	beq	s2,s1,800021f2 <scheduler+0x1f8>
        acquire(&p->lock);
    800021ca:	854a                	mv	a0,s2
    800021cc:	fffff097          	auipc	ra,0xfffff
    800021d0:	a1e080e7          	jalr	-1506(ra) # 80000bea <acquire>
        if (p->state == RUNNABLE && p->queue == minqueue)
    800021d4:	01892783          	lw	a5,24(s2)
    800021d8:	ff5790e3          	bne	a5,s5,800021b8 <scheduler+0x1be>
    800021dc:	1e492783          	lw	a5,484(s2)
    800021e0:	fd479ce3          	bne	a5,s4,800021b8 <scheduler+0x1be>
          if (p->queueposition < minqueueval)
    800021e4:	1ec92783          	lw	a5,492(s2)
    800021e8:	fd97d8e3          	bge	a5,s9,800021b8 <scheduler+0x1be>
    800021ec:	8bca                	mv	s7,s2
            minqueueval = p->queueposition;
    800021ee:	8cbe                	mv	s9,a5
    800021f0:	b7e1                	j	800021b8 <scheduler+0x1be>
      for (p = proc; p < &proc[NPROC]; p++)
    800021f2:	0000f917          	auipc	s2,0xf
    800021f6:	04e90913          	addi	s2,s2,78 # 80011240 <proc>
        if (p->state == RUNNABLE && p == run_process)
    800021fa:	4a8d                	li	s5,3
            if (p->waittickcount >= 1000)
    800021fc:	3e700c93          	li	s9,999
          p->state = RUNNING;
    80002200:	4d11                	li	s10,4
          if (p->tickcount >= maxticks[p->queue] && p->queue != 4)
    80002202:	4d91                	li	s11,4
    80002204:	a851                	j	80002298 <scheduler+0x29e>
          p->state = RUNNING;
    80002206:	01a92c23          	sw	s10,24(s2)
          c->proc = p;
    8000220a:	032b3823          	sd	s2,48(s6)
          swtch(&c->context, &p->context);
    8000220e:	06090593          	addi	a1,s2,96
    80002212:	8562                	mv	a0,s8
    80002214:	00001097          	auipc	ra,0x1
    80002218:	980080e7          	jalr	-1664(ra) # 80002b94 <swtch>
          c->proc = 0;
    8000221c:	020b3823          	sd	zero,48(s6)
          p->tickcount++;
    80002220:	1e092783          	lw	a5,480(s2)
    80002224:	2785                	addiw	a5,a5,1
    80002226:	0007869b          	sext.w	a3,a5
    8000222a:	1ef92023          	sw	a5,480(s2)
          if (p->tickcount >= maxticks[p->queue] && p->queue != 4)
    8000222e:	1e492703          	lw	a4,484(s2)
    80002232:	00271793          	slli	a5,a4,0x2
    80002236:	f9040613          	addi	a2,s0,-112
    8000223a:	97b2                	add	a5,a5,a2
    8000223c:	fe87a783          	lw	a5,-24(a5)
    80002240:	04f6c163          	blt	a3,a5,80002282 <scheduler+0x288>
    80002244:	03b70f63          	beq	a4,s11,80002282 <scheduler+0x288>
            queueprocesscount[p->queue]--;
    80002248:	00271793          	slli	a5,a4,0x2
    8000224c:	97ce                	add	a5,a5,s3
    8000224e:	4307a683          	lw	a3,1072(a5)
    80002252:	36fd                	addiw	a3,a3,-1
    80002254:	42d7a823          	sw	a3,1072(a5)
            p->queue++;
    80002258:	2705                	addiw	a4,a4,1
    8000225a:	0007079b          	sext.w	a5,a4
    8000225e:	1ee92223          	sw	a4,484(s2)
            queueprocesscount[p->queue]++;
    80002262:	078a                	slli	a5,a5,0x2
    80002264:	97ce                	add	a5,a5,s3
    80002266:	4307a703          	lw	a4,1072(a5)
    8000226a:	2705                	addiw	a4,a4,1
    8000226c:	42e7a823          	sw	a4,1072(a5)
            p->tickcount = 0;
    80002270:	1e092023          	sw	zero,480(s2)
            p->queueposition = queuemaxindex[p->queue];
    80002274:	4487a703          	lw	a4,1096(a5)
    80002278:	1ee92623          	sw	a4,492(s2)
            queuemaxindex[p->queue]++;
    8000227c:	2705                	addiw	a4,a4,1
    8000227e:	44e7a423          	sw	a4,1096(a5)
          p->waittickcount = 0;
    80002282:	1e092423          	sw	zero,488(s2)
        release(&p->lock);
    80002286:	854a                	mv	a0,s2
    80002288:	fffff097          	auipc	ra,0xfffff
    8000228c:	a16080e7          	jalr	-1514(ra) # 80000c9e <release>
      for (p = proc; p < &proc[NPROC]; p++)
    80002290:	1f090913          	addi	s2,s2,496
    80002294:	de9902e3          	beq	s2,s1,80002078 <scheduler+0x7e>
        acquire(&p->lock);
    80002298:	854a                	mv	a0,s2
    8000229a:	fffff097          	auipc	ra,0xfffff
    8000229e:	950080e7          	jalr	-1712(ra) # 80000bea <acquire>
        if (p->state == RUNNABLE && p == run_process)
    800022a2:	01892783          	lw	a5,24(s2)
    800022a6:	ff5790e3          	bne	a5,s5,80002286 <scheduler+0x28c>
    800022aa:	f52b8ee3          	beq	s7,s2,80002206 <scheduler+0x20c>
          p->waittickcount++;
    800022ae:	1e892783          	lw	a5,488(s2)
    800022b2:	2785                	addiw	a5,a5,1
    800022b4:	0007871b          	sext.w	a4,a5
    800022b8:	1ef92423          	sw	a5,488(s2)
          if (p->queue != 0)
    800022bc:	1e492783          	lw	a5,484(s2)
    800022c0:	d3f9                	beqz	a5,80002286 <scheduler+0x28c>
            if (p->waittickcount >= 1000)
    800022c2:	fcecd2e3          	bge	s9,a4,80002286 <scheduler+0x28c>
              queueprocesscount[p->queue]--;
    800022c6:	00279713          	slli	a4,a5,0x2
    800022ca:	974e                	add	a4,a4,s3
    800022cc:	43072683          	lw	a3,1072(a4)
    800022d0:	36fd                	addiw	a3,a3,-1
    800022d2:	42d72823          	sw	a3,1072(a4)
              p->queue--;
    800022d6:	37fd                	addiw	a5,a5,-1
    800022d8:	0007871b          	sext.w	a4,a5
    800022dc:	1ef92223          	sw	a5,484(s2)
              queueprocesscount[p->queue]++;
    800022e0:	00271793          	slli	a5,a4,0x2
    800022e4:	97ce                	add	a5,a5,s3
    800022e6:	4307a703          	lw	a4,1072(a5)
    800022ea:	2705                	addiw	a4,a4,1
    800022ec:	42e7a823          	sw	a4,1072(a5)
              p->tickcount = 0;
    800022f0:	1e092023          	sw	zero,480(s2)
              p->waittickcount = 0;
    800022f4:	1e092423          	sw	zero,488(s2)
              p->queueposition = queuemaxindex[p->queue];
    800022f8:	4487a703          	lw	a4,1096(a5)
    800022fc:	1ee92623          	sw	a4,492(s2)
              queuemaxindex[p->queue]++;
    80002300:	2705                	addiw	a4,a4,1
    80002302:	44e7a423          	sw	a4,1096(a5)
    80002306:	b741                	j	80002286 <scheduler+0x28c>

0000000080002308 <sched>:
{
    80002308:	7179                	addi	sp,sp,-48
    8000230a:	f406                	sd	ra,40(sp)
    8000230c:	f022                	sd	s0,32(sp)
    8000230e:	ec26                	sd	s1,24(sp)
    80002310:	e84a                	sd	s2,16(sp)
    80002312:	e44e                	sd	s3,8(sp)
    80002314:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002316:	fffff097          	auipc	ra,0xfffff
    8000231a:	6b0080e7          	jalr	1712(ra) # 800019c6 <myproc>
    8000231e:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80002320:	fffff097          	auipc	ra,0xfffff
    80002324:	850080e7          	jalr	-1968(ra) # 80000b70 <holding>
    80002328:	c93d                	beqz	a0,8000239e <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000232a:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    8000232c:	2781                	sext.w	a5,a5
    8000232e:	079e                	slli	a5,a5,0x7
    80002330:	0000f717          	auipc	a4,0xf
    80002334:	ab070713          	addi	a4,a4,-1360 # 80010de0 <pid_lock>
    80002338:	97ba                	add	a5,a5,a4
    8000233a:	0a87a703          	lw	a4,168(a5)
    8000233e:	4785                	li	a5,1
    80002340:	06f71763          	bne	a4,a5,800023ae <sched+0xa6>
  if (p->state == RUNNING)
    80002344:	4c98                	lw	a4,24(s1)
    80002346:	4791                	li	a5,4
    80002348:	06f70b63          	beq	a4,a5,800023be <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000234c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002350:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002352:	efb5                	bnez	a5,800023ce <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002354:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002356:	0000f917          	auipc	s2,0xf
    8000235a:	a8a90913          	addi	s2,s2,-1398 # 80010de0 <pid_lock>
    8000235e:	2781                	sext.w	a5,a5
    80002360:	079e                	slli	a5,a5,0x7
    80002362:	97ca                	add	a5,a5,s2
    80002364:	0ac7a983          	lw	s3,172(a5)
    80002368:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000236a:	2781                	sext.w	a5,a5
    8000236c:	079e                	slli	a5,a5,0x7
    8000236e:	0000f597          	auipc	a1,0xf
    80002372:	aaa58593          	addi	a1,a1,-1366 # 80010e18 <cpus+0x8>
    80002376:	95be                	add	a1,a1,a5
    80002378:	06048513          	addi	a0,s1,96
    8000237c:	00001097          	auipc	ra,0x1
    80002380:	818080e7          	jalr	-2024(ra) # 80002b94 <swtch>
    80002384:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002386:	2781                	sext.w	a5,a5
    80002388:	079e                	slli	a5,a5,0x7
    8000238a:	97ca                	add	a5,a5,s2
    8000238c:	0b37a623          	sw	s3,172(a5)
}
    80002390:	70a2                	ld	ra,40(sp)
    80002392:	7402                	ld	s0,32(sp)
    80002394:	64e2                	ld	s1,24(sp)
    80002396:	6942                	ld	s2,16(sp)
    80002398:	69a2                	ld	s3,8(sp)
    8000239a:	6145                	addi	sp,sp,48
    8000239c:	8082                	ret
    panic("sched p->lock");
    8000239e:	00006517          	auipc	a0,0x6
    800023a2:	e7a50513          	addi	a0,a0,-390 # 80008218 <digits+0x1d8>
    800023a6:	ffffe097          	auipc	ra,0xffffe
    800023aa:	19e080e7          	jalr	414(ra) # 80000544 <panic>
    panic("sched locks");
    800023ae:	00006517          	auipc	a0,0x6
    800023b2:	e7a50513          	addi	a0,a0,-390 # 80008228 <digits+0x1e8>
    800023b6:	ffffe097          	auipc	ra,0xffffe
    800023ba:	18e080e7          	jalr	398(ra) # 80000544 <panic>
    panic("sched running");
    800023be:	00006517          	auipc	a0,0x6
    800023c2:	e7a50513          	addi	a0,a0,-390 # 80008238 <digits+0x1f8>
    800023c6:	ffffe097          	auipc	ra,0xffffe
    800023ca:	17e080e7          	jalr	382(ra) # 80000544 <panic>
    panic("sched interruptible");
    800023ce:	00006517          	auipc	a0,0x6
    800023d2:	e7a50513          	addi	a0,a0,-390 # 80008248 <digits+0x208>
    800023d6:	ffffe097          	auipc	ra,0xffffe
    800023da:	16e080e7          	jalr	366(ra) # 80000544 <panic>

00000000800023de <yield>:
{
    800023de:	1101                	addi	sp,sp,-32
    800023e0:	ec06                	sd	ra,24(sp)
    800023e2:	e822                	sd	s0,16(sp)
    800023e4:	e426                	sd	s1,8(sp)
    800023e6:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800023e8:	fffff097          	auipc	ra,0xfffff
    800023ec:	5de080e7          	jalr	1502(ra) # 800019c6 <myproc>
    800023f0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800023f2:	ffffe097          	auipc	ra,0xffffe
    800023f6:	7f8080e7          	jalr	2040(ra) # 80000bea <acquire>
  p->state = RUNNABLE;
    800023fa:	478d                	li	a5,3
    800023fc:	cc9c                	sw	a5,24(s1)
  sched();
    800023fe:	00000097          	auipc	ra,0x0
    80002402:	f0a080e7          	jalr	-246(ra) # 80002308 <sched>
  release(&p->lock);
    80002406:	8526                	mv	a0,s1
    80002408:	fffff097          	auipc	ra,0xfffff
    8000240c:	896080e7          	jalr	-1898(ra) # 80000c9e <release>
}
    80002410:	60e2                	ld	ra,24(sp)
    80002412:	6442                	ld	s0,16(sp)
    80002414:	64a2                	ld	s1,8(sp)
    80002416:	6105                	addi	sp,sp,32
    80002418:	8082                	ret

000000008000241a <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    8000241a:	7179                	addi	sp,sp,-48
    8000241c:	f406                	sd	ra,40(sp)
    8000241e:	f022                	sd	s0,32(sp)
    80002420:	ec26                	sd	s1,24(sp)
    80002422:	e84a                	sd	s2,16(sp)
    80002424:	e44e                	sd	s3,8(sp)
    80002426:	1800                	addi	s0,sp,48
    80002428:	89aa                	mv	s3,a0
    8000242a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000242c:	fffff097          	auipc	ra,0xfffff
    80002430:	59a080e7          	jalr	1434(ra) # 800019c6 <myproc>
    80002434:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    80002436:	ffffe097          	auipc	ra,0xffffe
    8000243a:	7b4080e7          	jalr	1972(ra) # 80000bea <acquire>
  release(lk);
    8000243e:	854a                	mv	a0,s2
    80002440:	fffff097          	auipc	ra,0xfffff
    80002444:	85e080e7          	jalr	-1954(ra) # 80000c9e <release>

  // Go to sleep.
  p->chan = chan;
    80002448:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000244c:	4789                	li	a5,2
    8000244e:	cc9c                	sw	a5,24(s1)

  sched();
    80002450:	00000097          	auipc	ra,0x0
    80002454:	eb8080e7          	jalr	-328(ra) # 80002308 <sched>

  // Tidy up.
  p->chan = 0;
    80002458:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000245c:	8526                	mv	a0,s1
    8000245e:	fffff097          	auipc	ra,0xfffff
    80002462:	840080e7          	jalr	-1984(ra) # 80000c9e <release>
  acquire(lk);
    80002466:	854a                	mv	a0,s2
    80002468:	ffffe097          	auipc	ra,0xffffe
    8000246c:	782080e7          	jalr	1922(ra) # 80000bea <acquire>
}
    80002470:	70a2                	ld	ra,40(sp)
    80002472:	7402                	ld	s0,32(sp)
    80002474:	64e2                	ld	s1,24(sp)
    80002476:	6942                	ld	s2,16(sp)
    80002478:	69a2                	ld	s3,8(sp)
    8000247a:	6145                	addi	sp,sp,48
    8000247c:	8082                	ret

000000008000247e <waitx>:
{
    8000247e:	711d                	addi	sp,sp,-96
    80002480:	ec86                	sd	ra,88(sp)
    80002482:	e8a2                	sd	s0,80(sp)
    80002484:	e4a6                	sd	s1,72(sp)
    80002486:	e0ca                	sd	s2,64(sp)
    80002488:	fc4e                	sd	s3,56(sp)
    8000248a:	f852                	sd	s4,48(sp)
    8000248c:	f456                	sd	s5,40(sp)
    8000248e:	f05a                	sd	s6,32(sp)
    80002490:	ec5e                	sd	s7,24(sp)
    80002492:	e862                	sd	s8,16(sp)
    80002494:	e466                	sd	s9,8(sp)
    80002496:	e06a                	sd	s10,0(sp)
    80002498:	1080                	addi	s0,sp,96
    8000249a:	8b2a                	mv	s6,a0
    8000249c:	8bae                	mv	s7,a1
    8000249e:	8c32                	mv	s8,a2
  struct proc *p = myproc();
    800024a0:	fffff097          	auipc	ra,0xfffff
    800024a4:	526080e7          	jalr	1318(ra) # 800019c6 <myproc>
    800024a8:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800024aa:	0000f517          	auipc	a0,0xf
    800024ae:	94e50513          	addi	a0,a0,-1714 # 80010df8 <wait_lock>
    800024b2:	ffffe097          	auipc	ra,0xffffe
    800024b6:	738080e7          	jalr	1848(ra) # 80000bea <acquire>
    havekids = 0;
    800024ba:	4c81                	li	s9,0
        if (np->state == ZOMBIE)
    800024bc:	4a15                	li	s4,5
    for (np = proc; np < &proc[NPROC]; np++)
    800024be:	00017997          	auipc	s3,0x17
    800024c2:	98298993          	addi	s3,s3,-1662 # 80018e40 <tickslock>
        havekids = 1;
    800024c6:	4a85                	li	s5,1
    sleep(p, &wait_lock); // DOC: wait-sleep
    800024c8:	0000fd17          	auipc	s10,0xf
    800024cc:	930d0d13          	addi	s10,s10,-1744 # 80010df8 <wait_lock>
    havekids = 0;
    800024d0:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    800024d2:	0000f497          	auipc	s1,0xf
    800024d6:	d6e48493          	addi	s1,s1,-658 # 80011240 <proc>
    800024da:	a059                	j	80002560 <waitx+0xe2>
          pid = np->pid;
    800024dc:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    800024e0:	16c4a703          	lw	a4,364(s1)
    800024e4:	00ec2023          	sw	a4,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    800024e8:	1704a783          	lw	a5,368(s1)
    800024ec:	9f3d                	addw	a4,a4,a5
    800024ee:	1744a783          	lw	a5,372(s1)
    800024f2:	9f99                	subw	a5,a5,a4
    800024f4:	00fba023          	sw	a5,0(s7) # fffffffffffff000 <end+0xffffffff7ffdade0>
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800024f8:	000b0e63          	beqz	s6,80002514 <waitx+0x96>
    800024fc:	4691                	li	a3,4
    800024fe:	02c48613          	addi	a2,s1,44
    80002502:	85da                	mv	a1,s6
    80002504:	05093503          	ld	a0,80(s2)
    80002508:	fffff097          	auipc	ra,0xfffff
    8000250c:	17c080e7          	jalr	380(ra) # 80001684 <copyout>
    80002510:	02054563          	bltz	a0,8000253a <waitx+0xbc>
          freeproc(np);
    80002514:	8526                	mv	a0,s1
    80002516:	fffff097          	auipc	ra,0xfffff
    8000251a:	662080e7          	jalr	1634(ra) # 80001b78 <freeproc>
          release(&np->lock);
    8000251e:	8526                	mv	a0,s1
    80002520:	ffffe097          	auipc	ra,0xffffe
    80002524:	77e080e7          	jalr	1918(ra) # 80000c9e <release>
          release(&wait_lock);
    80002528:	0000f517          	auipc	a0,0xf
    8000252c:	8d050513          	addi	a0,a0,-1840 # 80010df8 <wait_lock>
    80002530:	ffffe097          	auipc	ra,0xffffe
    80002534:	76e080e7          	jalr	1902(ra) # 80000c9e <release>
          return pid;
    80002538:	a09d                	j	8000259e <waitx+0x120>
            release(&np->lock);
    8000253a:	8526                	mv	a0,s1
    8000253c:	ffffe097          	auipc	ra,0xffffe
    80002540:	762080e7          	jalr	1890(ra) # 80000c9e <release>
            release(&wait_lock);
    80002544:	0000f517          	auipc	a0,0xf
    80002548:	8b450513          	addi	a0,a0,-1868 # 80010df8 <wait_lock>
    8000254c:	ffffe097          	auipc	ra,0xffffe
    80002550:	752080e7          	jalr	1874(ra) # 80000c9e <release>
            return -1;
    80002554:	59fd                	li	s3,-1
    80002556:	a0a1                	j	8000259e <waitx+0x120>
    for (np = proc; np < &proc[NPROC]; np++)
    80002558:	1f048493          	addi	s1,s1,496
    8000255c:	03348463          	beq	s1,s3,80002584 <waitx+0x106>
      if (np->parent == p)
    80002560:	7c9c                	ld	a5,56(s1)
    80002562:	ff279be3          	bne	a5,s2,80002558 <waitx+0xda>
        acquire(&np->lock);
    80002566:	8526                	mv	a0,s1
    80002568:	ffffe097          	auipc	ra,0xffffe
    8000256c:	682080e7          	jalr	1666(ra) # 80000bea <acquire>
        if (np->state == ZOMBIE)
    80002570:	4c9c                	lw	a5,24(s1)
    80002572:	f74785e3          	beq	a5,s4,800024dc <waitx+0x5e>
        release(&np->lock);
    80002576:	8526                	mv	a0,s1
    80002578:	ffffe097          	auipc	ra,0xffffe
    8000257c:	726080e7          	jalr	1830(ra) # 80000c9e <release>
        havekids = 1;
    80002580:	8756                	mv	a4,s5
    80002582:	bfd9                	j	80002558 <waitx+0xda>
    if (!havekids || p->killed)
    80002584:	c701                	beqz	a4,8000258c <waitx+0x10e>
    80002586:	02892783          	lw	a5,40(s2)
    8000258a:	cb8d                	beqz	a5,800025bc <waitx+0x13e>
      release(&wait_lock);
    8000258c:	0000f517          	auipc	a0,0xf
    80002590:	86c50513          	addi	a0,a0,-1940 # 80010df8 <wait_lock>
    80002594:	ffffe097          	auipc	ra,0xffffe
    80002598:	70a080e7          	jalr	1802(ra) # 80000c9e <release>
      return -1;
    8000259c:	59fd                	li	s3,-1
}
    8000259e:	854e                	mv	a0,s3
    800025a0:	60e6                	ld	ra,88(sp)
    800025a2:	6446                	ld	s0,80(sp)
    800025a4:	64a6                	ld	s1,72(sp)
    800025a6:	6906                	ld	s2,64(sp)
    800025a8:	79e2                	ld	s3,56(sp)
    800025aa:	7a42                	ld	s4,48(sp)
    800025ac:	7aa2                	ld	s5,40(sp)
    800025ae:	7b02                	ld	s6,32(sp)
    800025b0:	6be2                	ld	s7,24(sp)
    800025b2:	6c42                	ld	s8,16(sp)
    800025b4:	6ca2                	ld	s9,8(sp)
    800025b6:	6d02                	ld	s10,0(sp)
    800025b8:	6125                	addi	sp,sp,96
    800025ba:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    800025bc:	85ea                	mv	a1,s10
    800025be:	854a                	mv	a0,s2
    800025c0:	00000097          	auipc	ra,0x0
    800025c4:	e5a080e7          	jalr	-422(ra) # 8000241a <sleep>
    havekids = 0;
    800025c8:	b721                	j	800024d0 <waitx+0x52>

00000000800025ca <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    800025ca:	7139                	addi	sp,sp,-64
    800025cc:	fc06                	sd	ra,56(sp)
    800025ce:	f822                	sd	s0,48(sp)
    800025d0:	f426                	sd	s1,40(sp)
    800025d2:	f04a                	sd	s2,32(sp)
    800025d4:	ec4e                	sd	s3,24(sp)
    800025d6:	e852                	sd	s4,16(sp)
    800025d8:	e456                	sd	s5,8(sp)
    800025da:	0080                	addi	s0,sp,64
    800025dc:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800025de:	0000f497          	auipc	s1,0xf
    800025e2:	c6248493          	addi	s1,s1,-926 # 80011240 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    800025e6:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    800025e8:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    800025ea:	00017917          	auipc	s2,0x17
    800025ee:	85690913          	addi	s2,s2,-1962 # 80018e40 <tickslock>
    800025f2:	a821                	j	8000260a <wakeup+0x40>
        p->state = RUNNABLE;
    800025f4:	0154ac23          	sw	s5,24(s1)
      }
      release(&p->lock);
    800025f8:	8526                	mv	a0,s1
    800025fa:	ffffe097          	auipc	ra,0xffffe
    800025fe:	6a4080e7          	jalr	1700(ra) # 80000c9e <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002602:	1f048493          	addi	s1,s1,496
    80002606:	03248463          	beq	s1,s2,8000262e <wakeup+0x64>
    if (p != myproc())
    8000260a:	fffff097          	auipc	ra,0xfffff
    8000260e:	3bc080e7          	jalr	956(ra) # 800019c6 <myproc>
    80002612:	fea488e3          	beq	s1,a0,80002602 <wakeup+0x38>
      acquire(&p->lock);
    80002616:	8526                	mv	a0,s1
    80002618:	ffffe097          	auipc	ra,0xffffe
    8000261c:	5d2080e7          	jalr	1490(ra) # 80000bea <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    80002620:	4c9c                	lw	a5,24(s1)
    80002622:	fd379be3          	bne	a5,s3,800025f8 <wakeup+0x2e>
    80002626:	709c                	ld	a5,32(s1)
    80002628:	fd4798e3          	bne	a5,s4,800025f8 <wakeup+0x2e>
    8000262c:	b7e1                	j	800025f4 <wakeup+0x2a>
    }
  }
}
    8000262e:	70e2                	ld	ra,56(sp)
    80002630:	7442                	ld	s0,48(sp)
    80002632:	74a2                	ld	s1,40(sp)
    80002634:	7902                	ld	s2,32(sp)
    80002636:	69e2                	ld	s3,24(sp)
    80002638:	6a42                	ld	s4,16(sp)
    8000263a:	6aa2                	ld	s5,8(sp)
    8000263c:	6121                	addi	sp,sp,64
    8000263e:	8082                	ret

0000000080002640 <reparent>:
{
    80002640:	7179                	addi	sp,sp,-48
    80002642:	f406                	sd	ra,40(sp)
    80002644:	f022                	sd	s0,32(sp)
    80002646:	ec26                	sd	s1,24(sp)
    80002648:	e84a                	sd	s2,16(sp)
    8000264a:	e44e                	sd	s3,8(sp)
    8000264c:	e052                	sd	s4,0(sp)
    8000264e:	1800                	addi	s0,sp,48
    80002650:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002652:	0000f497          	auipc	s1,0xf
    80002656:	bee48493          	addi	s1,s1,-1042 # 80011240 <proc>
      pp->parent = initproc;
    8000265a:	00006a17          	auipc	s4,0x6
    8000265e:	50ea0a13          	addi	s4,s4,1294 # 80008b68 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002662:	00016997          	auipc	s3,0x16
    80002666:	7de98993          	addi	s3,s3,2014 # 80018e40 <tickslock>
    8000266a:	a029                	j	80002674 <reparent+0x34>
    8000266c:	1f048493          	addi	s1,s1,496
    80002670:	01348d63          	beq	s1,s3,8000268a <reparent+0x4a>
    if (pp->parent == p)
    80002674:	7c9c                	ld	a5,56(s1)
    80002676:	ff279be3          	bne	a5,s2,8000266c <reparent+0x2c>
      pp->parent = initproc;
    8000267a:	000a3503          	ld	a0,0(s4)
    8000267e:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002680:	00000097          	auipc	ra,0x0
    80002684:	f4a080e7          	jalr	-182(ra) # 800025ca <wakeup>
    80002688:	b7d5                	j	8000266c <reparent+0x2c>
}
    8000268a:	70a2                	ld	ra,40(sp)
    8000268c:	7402                	ld	s0,32(sp)
    8000268e:	64e2                	ld	s1,24(sp)
    80002690:	6942                	ld	s2,16(sp)
    80002692:	69a2                	ld	s3,8(sp)
    80002694:	6a02                	ld	s4,0(sp)
    80002696:	6145                	addi	sp,sp,48
    80002698:	8082                	ret

000000008000269a <exit>:
{
    8000269a:	7179                	addi	sp,sp,-48
    8000269c:	f406                	sd	ra,40(sp)
    8000269e:	f022                	sd	s0,32(sp)
    800026a0:	ec26                	sd	s1,24(sp)
    800026a2:	e84a                	sd	s2,16(sp)
    800026a4:	e44e                	sd	s3,8(sp)
    800026a6:	e052                	sd	s4,0(sp)
    800026a8:	1800                	addi	s0,sp,48
    800026aa:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800026ac:	fffff097          	auipc	ra,0xfffff
    800026b0:	31a080e7          	jalr	794(ra) # 800019c6 <myproc>
    800026b4:	89aa                	mv	s3,a0
  if (p == initproc)
    800026b6:	00006797          	auipc	a5,0x6
    800026ba:	4b27b783          	ld	a5,1202(a5) # 80008b68 <initproc>
    800026be:	0d050493          	addi	s1,a0,208
    800026c2:	15050913          	addi	s2,a0,336
    800026c6:	02a79363          	bne	a5,a0,800026ec <exit+0x52>
    panic("init exiting");
    800026ca:	00006517          	auipc	a0,0x6
    800026ce:	b9650513          	addi	a0,a0,-1130 # 80008260 <digits+0x220>
    800026d2:	ffffe097          	auipc	ra,0xffffe
    800026d6:	e72080e7          	jalr	-398(ra) # 80000544 <panic>
      fileclose(f);
    800026da:	00002097          	auipc	ra,0x2
    800026de:	6ce080e7          	jalr	1742(ra) # 80004da8 <fileclose>
      p->ofile[fd] = 0;
    800026e2:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    800026e6:	04a1                	addi	s1,s1,8
    800026e8:	01248563          	beq	s1,s2,800026f2 <exit+0x58>
    if (p->ofile[fd])
    800026ec:	6088                	ld	a0,0(s1)
    800026ee:	f575                	bnez	a0,800026da <exit+0x40>
    800026f0:	bfdd                	j	800026e6 <exit+0x4c>
  begin_op();
    800026f2:	00002097          	auipc	ra,0x2
    800026f6:	1ea080e7          	jalr	490(ra) # 800048dc <begin_op>
  iput(p->cwd);
    800026fa:	1509b503          	ld	a0,336(s3)
    800026fe:	00002097          	auipc	ra,0x2
    80002702:	9d6080e7          	jalr	-1578(ra) # 800040d4 <iput>
  end_op();
    80002706:	00002097          	auipc	ra,0x2
    8000270a:	256080e7          	jalr	598(ra) # 8000495c <end_op>
  p->cwd = 0;
    8000270e:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002712:	0000e497          	auipc	s1,0xe
    80002716:	6e648493          	addi	s1,s1,1766 # 80010df8 <wait_lock>
    8000271a:	8526                	mv	a0,s1
    8000271c:	ffffe097          	auipc	ra,0xffffe
    80002720:	4ce080e7          	jalr	1230(ra) # 80000bea <acquire>
  reparent(p);
    80002724:	854e                	mv	a0,s3
    80002726:	00000097          	auipc	ra,0x0
    8000272a:	f1a080e7          	jalr	-230(ra) # 80002640 <reparent>
  wakeup(p->parent);
    8000272e:	0389b503          	ld	a0,56(s3)
    80002732:	00000097          	auipc	ra,0x0
    80002736:	e98080e7          	jalr	-360(ra) # 800025ca <wakeup>
  acquire(&p->lock);
    8000273a:	854e                	mv	a0,s3
    8000273c:	ffffe097          	auipc	ra,0xffffe
    80002740:	4ae080e7          	jalr	1198(ra) # 80000bea <acquire>
  p->xstate = status;
    80002744:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002748:	4795                	li	a5,5
    8000274a:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    8000274e:	00006797          	auipc	a5,0x6
    80002752:	4227a783          	lw	a5,1058(a5) # 80008b70 <ticks>
    80002756:	16f9aa23          	sw	a5,372(s3)
  release(&wait_lock);
    8000275a:	8526                	mv	a0,s1
    8000275c:	ffffe097          	auipc	ra,0xffffe
    80002760:	542080e7          	jalr	1346(ra) # 80000c9e <release>
  sched();
    80002764:	00000097          	auipc	ra,0x0
    80002768:	ba4080e7          	jalr	-1116(ra) # 80002308 <sched>
  panic("zombie exit");
    8000276c:	00006517          	auipc	a0,0x6
    80002770:	b0450513          	addi	a0,a0,-1276 # 80008270 <digits+0x230>
    80002774:	ffffe097          	auipc	ra,0xffffe
    80002778:	dd0080e7          	jalr	-560(ra) # 80000544 <panic>

000000008000277c <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    8000277c:	7179                	addi	sp,sp,-48
    8000277e:	f406                	sd	ra,40(sp)
    80002780:	f022                	sd	s0,32(sp)
    80002782:	ec26                	sd	s1,24(sp)
    80002784:	e84a                	sd	s2,16(sp)
    80002786:	e44e                	sd	s3,8(sp)
    80002788:	1800                	addi	s0,sp,48
    8000278a:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000278c:	0000f497          	auipc	s1,0xf
    80002790:	ab448493          	addi	s1,s1,-1356 # 80011240 <proc>
    80002794:	00016997          	auipc	s3,0x16
    80002798:	6ac98993          	addi	s3,s3,1708 # 80018e40 <tickslock>
  {
    acquire(&p->lock);
    8000279c:	8526                	mv	a0,s1
    8000279e:	ffffe097          	auipc	ra,0xffffe
    800027a2:	44c080e7          	jalr	1100(ra) # 80000bea <acquire>
    if (p->pid == pid)
    800027a6:	589c                	lw	a5,48(s1)
    800027a8:	01278d63          	beq	a5,s2,800027c2 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800027ac:	8526                	mv	a0,s1
    800027ae:	ffffe097          	auipc	ra,0xffffe
    800027b2:	4f0080e7          	jalr	1264(ra) # 80000c9e <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800027b6:	1f048493          	addi	s1,s1,496
    800027ba:	ff3491e3          	bne	s1,s3,8000279c <kill+0x20>
  }
  return -1;
    800027be:	557d                	li	a0,-1
    800027c0:	a829                	j	800027da <kill+0x5e>
      p->killed = 1;
    800027c2:	4785                	li	a5,1
    800027c4:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    800027c6:	4c98                	lw	a4,24(s1)
    800027c8:	4789                	li	a5,2
    800027ca:	00f70f63          	beq	a4,a5,800027e8 <kill+0x6c>
      release(&p->lock);
    800027ce:	8526                	mv	a0,s1
    800027d0:	ffffe097          	auipc	ra,0xffffe
    800027d4:	4ce080e7          	jalr	1230(ra) # 80000c9e <release>
      return 0;
    800027d8:	4501                	li	a0,0
}
    800027da:	70a2                	ld	ra,40(sp)
    800027dc:	7402                	ld	s0,32(sp)
    800027de:	64e2                	ld	s1,24(sp)
    800027e0:	6942                	ld	s2,16(sp)
    800027e2:	69a2                	ld	s3,8(sp)
    800027e4:	6145                	addi	sp,sp,48
    800027e6:	8082                	ret
        p->state = RUNNABLE;
    800027e8:	478d                	li	a5,3
    800027ea:	cc9c                	sw	a5,24(s1)
    800027ec:	b7cd                	j	800027ce <kill+0x52>

00000000800027ee <setkilled>:

void setkilled(struct proc *p)
{
    800027ee:	1101                	addi	sp,sp,-32
    800027f0:	ec06                	sd	ra,24(sp)
    800027f2:	e822                	sd	s0,16(sp)
    800027f4:	e426                	sd	s1,8(sp)
    800027f6:	1000                	addi	s0,sp,32
    800027f8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800027fa:	ffffe097          	auipc	ra,0xffffe
    800027fe:	3f0080e7          	jalr	1008(ra) # 80000bea <acquire>
  p->killed = 1;
    80002802:	4785                	li	a5,1
    80002804:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002806:	8526                	mv	a0,s1
    80002808:	ffffe097          	auipc	ra,0xffffe
    8000280c:	496080e7          	jalr	1174(ra) # 80000c9e <release>
}
    80002810:	60e2                	ld	ra,24(sp)
    80002812:	6442                	ld	s0,16(sp)
    80002814:	64a2                	ld	s1,8(sp)
    80002816:	6105                	addi	sp,sp,32
    80002818:	8082                	ret

000000008000281a <killed>:

int killed(struct proc *p)
{
    8000281a:	1101                	addi	sp,sp,-32
    8000281c:	ec06                	sd	ra,24(sp)
    8000281e:	e822                	sd	s0,16(sp)
    80002820:	e426                	sd	s1,8(sp)
    80002822:	e04a                	sd	s2,0(sp)
    80002824:	1000                	addi	s0,sp,32
    80002826:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002828:	ffffe097          	auipc	ra,0xffffe
    8000282c:	3c2080e7          	jalr	962(ra) # 80000bea <acquire>
  k = p->killed;
    80002830:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002834:	8526                	mv	a0,s1
    80002836:	ffffe097          	auipc	ra,0xffffe
    8000283a:	468080e7          	jalr	1128(ra) # 80000c9e <release>
  return k;
}
    8000283e:	854a                	mv	a0,s2
    80002840:	60e2                	ld	ra,24(sp)
    80002842:	6442                	ld	s0,16(sp)
    80002844:	64a2                	ld	s1,8(sp)
    80002846:	6902                	ld	s2,0(sp)
    80002848:	6105                	addi	sp,sp,32
    8000284a:	8082                	ret

000000008000284c <wait>:
{
    8000284c:	715d                	addi	sp,sp,-80
    8000284e:	e486                	sd	ra,72(sp)
    80002850:	e0a2                	sd	s0,64(sp)
    80002852:	fc26                	sd	s1,56(sp)
    80002854:	f84a                	sd	s2,48(sp)
    80002856:	f44e                	sd	s3,40(sp)
    80002858:	f052                	sd	s4,32(sp)
    8000285a:	ec56                	sd	s5,24(sp)
    8000285c:	e85a                	sd	s6,16(sp)
    8000285e:	e45e                	sd	s7,8(sp)
    80002860:	e062                	sd	s8,0(sp)
    80002862:	0880                	addi	s0,sp,80
    80002864:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002866:	fffff097          	auipc	ra,0xfffff
    8000286a:	160080e7          	jalr	352(ra) # 800019c6 <myproc>
    8000286e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002870:	0000e517          	auipc	a0,0xe
    80002874:	58850513          	addi	a0,a0,1416 # 80010df8 <wait_lock>
    80002878:	ffffe097          	auipc	ra,0xffffe
    8000287c:	372080e7          	jalr	882(ra) # 80000bea <acquire>
    havekids = 0;
    80002880:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    80002882:	4a15                	li	s4,5
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002884:	00016997          	auipc	s3,0x16
    80002888:	5bc98993          	addi	s3,s3,1468 # 80018e40 <tickslock>
        havekids = 1;
    8000288c:	4a85                	li	s5,1
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000288e:	0000ec17          	auipc	s8,0xe
    80002892:	56ac0c13          	addi	s8,s8,1386 # 80010df8 <wait_lock>
    havekids = 0;
    80002896:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002898:	0000f497          	auipc	s1,0xf
    8000289c:	9a848493          	addi	s1,s1,-1624 # 80011240 <proc>
    800028a0:	a0bd                	j	8000290e <wait+0xc2>
          pid = pp->pid;
    800028a2:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800028a6:	000b0e63          	beqz	s6,800028c2 <wait+0x76>
    800028aa:	4691                	li	a3,4
    800028ac:	02c48613          	addi	a2,s1,44
    800028b0:	85da                	mv	a1,s6
    800028b2:	05093503          	ld	a0,80(s2)
    800028b6:	fffff097          	auipc	ra,0xfffff
    800028ba:	dce080e7          	jalr	-562(ra) # 80001684 <copyout>
    800028be:	02054563          	bltz	a0,800028e8 <wait+0x9c>
          freeproc(pp);
    800028c2:	8526                	mv	a0,s1
    800028c4:	fffff097          	auipc	ra,0xfffff
    800028c8:	2b4080e7          	jalr	692(ra) # 80001b78 <freeproc>
          release(&pp->lock);
    800028cc:	8526                	mv	a0,s1
    800028ce:	ffffe097          	auipc	ra,0xffffe
    800028d2:	3d0080e7          	jalr	976(ra) # 80000c9e <release>
          release(&wait_lock);
    800028d6:	0000e517          	auipc	a0,0xe
    800028da:	52250513          	addi	a0,a0,1314 # 80010df8 <wait_lock>
    800028de:	ffffe097          	auipc	ra,0xffffe
    800028e2:	3c0080e7          	jalr	960(ra) # 80000c9e <release>
          return pid;
    800028e6:	a0b5                	j	80002952 <wait+0x106>
            release(&pp->lock);
    800028e8:	8526                	mv	a0,s1
    800028ea:	ffffe097          	auipc	ra,0xffffe
    800028ee:	3b4080e7          	jalr	948(ra) # 80000c9e <release>
            release(&wait_lock);
    800028f2:	0000e517          	auipc	a0,0xe
    800028f6:	50650513          	addi	a0,a0,1286 # 80010df8 <wait_lock>
    800028fa:	ffffe097          	auipc	ra,0xffffe
    800028fe:	3a4080e7          	jalr	932(ra) # 80000c9e <release>
            return -1;
    80002902:	59fd                	li	s3,-1
    80002904:	a0b9                	j	80002952 <wait+0x106>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002906:	1f048493          	addi	s1,s1,496
    8000290a:	03348463          	beq	s1,s3,80002932 <wait+0xe6>
      if (pp->parent == p)
    8000290e:	7c9c                	ld	a5,56(s1)
    80002910:	ff279be3          	bne	a5,s2,80002906 <wait+0xba>
        acquire(&pp->lock);
    80002914:	8526                	mv	a0,s1
    80002916:	ffffe097          	auipc	ra,0xffffe
    8000291a:	2d4080e7          	jalr	724(ra) # 80000bea <acquire>
        if (pp->state == ZOMBIE)
    8000291e:	4c9c                	lw	a5,24(s1)
    80002920:	f94781e3          	beq	a5,s4,800028a2 <wait+0x56>
        release(&pp->lock);
    80002924:	8526                	mv	a0,s1
    80002926:	ffffe097          	auipc	ra,0xffffe
    8000292a:	378080e7          	jalr	888(ra) # 80000c9e <release>
        havekids = 1;
    8000292e:	8756                	mv	a4,s5
    80002930:	bfd9                	j	80002906 <wait+0xba>
    if (!havekids || killed(p))
    80002932:	c719                	beqz	a4,80002940 <wait+0xf4>
    80002934:	854a                	mv	a0,s2
    80002936:	00000097          	auipc	ra,0x0
    8000293a:	ee4080e7          	jalr	-284(ra) # 8000281a <killed>
    8000293e:	c51d                	beqz	a0,8000296c <wait+0x120>
      release(&wait_lock);
    80002940:	0000e517          	auipc	a0,0xe
    80002944:	4b850513          	addi	a0,a0,1208 # 80010df8 <wait_lock>
    80002948:	ffffe097          	auipc	ra,0xffffe
    8000294c:	356080e7          	jalr	854(ra) # 80000c9e <release>
      return -1;
    80002950:	59fd                	li	s3,-1
}
    80002952:	854e                	mv	a0,s3
    80002954:	60a6                	ld	ra,72(sp)
    80002956:	6406                	ld	s0,64(sp)
    80002958:	74e2                	ld	s1,56(sp)
    8000295a:	7942                	ld	s2,48(sp)
    8000295c:	79a2                	ld	s3,40(sp)
    8000295e:	7a02                	ld	s4,32(sp)
    80002960:	6ae2                	ld	s5,24(sp)
    80002962:	6b42                	ld	s6,16(sp)
    80002964:	6ba2                	ld	s7,8(sp)
    80002966:	6c02                	ld	s8,0(sp)
    80002968:	6161                	addi	sp,sp,80
    8000296a:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000296c:	85e2                	mv	a1,s8
    8000296e:	854a                	mv	a0,s2
    80002970:	00000097          	auipc	ra,0x0
    80002974:	aaa080e7          	jalr	-1366(ra) # 8000241a <sleep>
    havekids = 0;
    80002978:	bf39                	j	80002896 <wait+0x4a>

000000008000297a <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000297a:	7179                	addi	sp,sp,-48
    8000297c:	f406                	sd	ra,40(sp)
    8000297e:	f022                	sd	s0,32(sp)
    80002980:	ec26                	sd	s1,24(sp)
    80002982:	e84a                	sd	s2,16(sp)
    80002984:	e44e                	sd	s3,8(sp)
    80002986:	e052                	sd	s4,0(sp)
    80002988:	1800                	addi	s0,sp,48
    8000298a:	84aa                	mv	s1,a0
    8000298c:	892e                	mv	s2,a1
    8000298e:	89b2                	mv	s3,a2
    80002990:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002992:	fffff097          	auipc	ra,0xfffff
    80002996:	034080e7          	jalr	52(ra) # 800019c6 <myproc>
  if (user_dst)
    8000299a:	c08d                	beqz	s1,800029bc <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    8000299c:	86d2                	mv	a3,s4
    8000299e:	864e                	mv	a2,s3
    800029a0:	85ca                	mv	a1,s2
    800029a2:	6928                	ld	a0,80(a0)
    800029a4:	fffff097          	auipc	ra,0xfffff
    800029a8:	ce0080e7          	jalr	-800(ra) # 80001684 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800029ac:	70a2                	ld	ra,40(sp)
    800029ae:	7402                	ld	s0,32(sp)
    800029b0:	64e2                	ld	s1,24(sp)
    800029b2:	6942                	ld	s2,16(sp)
    800029b4:	69a2                	ld	s3,8(sp)
    800029b6:	6a02                	ld	s4,0(sp)
    800029b8:	6145                	addi	sp,sp,48
    800029ba:	8082                	ret
    memmove((char *)dst, src, len);
    800029bc:	000a061b          	sext.w	a2,s4
    800029c0:	85ce                	mv	a1,s3
    800029c2:	854a                	mv	a0,s2
    800029c4:	ffffe097          	auipc	ra,0xffffe
    800029c8:	382080e7          	jalr	898(ra) # 80000d46 <memmove>
    return 0;
    800029cc:	8526                	mv	a0,s1
    800029ce:	bff9                	j	800029ac <either_copyout+0x32>

00000000800029d0 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800029d0:	7179                	addi	sp,sp,-48
    800029d2:	f406                	sd	ra,40(sp)
    800029d4:	f022                	sd	s0,32(sp)
    800029d6:	ec26                	sd	s1,24(sp)
    800029d8:	e84a                	sd	s2,16(sp)
    800029da:	e44e                	sd	s3,8(sp)
    800029dc:	e052                	sd	s4,0(sp)
    800029de:	1800                	addi	s0,sp,48
    800029e0:	892a                	mv	s2,a0
    800029e2:	84ae                	mv	s1,a1
    800029e4:	89b2                	mv	s3,a2
    800029e6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800029e8:	fffff097          	auipc	ra,0xfffff
    800029ec:	fde080e7          	jalr	-34(ra) # 800019c6 <myproc>
  if (user_src)
    800029f0:	c08d                	beqz	s1,80002a12 <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    800029f2:	86d2                	mv	a3,s4
    800029f4:	864e                	mv	a2,s3
    800029f6:	85ca                	mv	a1,s2
    800029f8:	6928                	ld	a0,80(a0)
    800029fa:	fffff097          	auipc	ra,0xfffff
    800029fe:	d16080e7          	jalr	-746(ra) # 80001710 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002a02:	70a2                	ld	ra,40(sp)
    80002a04:	7402                	ld	s0,32(sp)
    80002a06:	64e2                	ld	s1,24(sp)
    80002a08:	6942                	ld	s2,16(sp)
    80002a0a:	69a2                	ld	s3,8(sp)
    80002a0c:	6a02                	ld	s4,0(sp)
    80002a0e:	6145                	addi	sp,sp,48
    80002a10:	8082                	ret
    memmove(dst, (char *)src, len);
    80002a12:	000a061b          	sext.w	a2,s4
    80002a16:	85ce                	mv	a1,s3
    80002a18:	854a                	mv	a0,s2
    80002a1a:	ffffe097          	auipc	ra,0xffffe
    80002a1e:	32c080e7          	jalr	812(ra) # 80000d46 <memmove>
    return 0;
    80002a22:	8526                	mv	a0,s1
    80002a24:	bff9                	j	80002a02 <either_copyin+0x32>

0000000080002a26 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002a26:	715d                	addi	sp,sp,-80
    80002a28:	e486                	sd	ra,72(sp)
    80002a2a:	e0a2                	sd	s0,64(sp)
    80002a2c:	fc26                	sd	s1,56(sp)
    80002a2e:	f84a                	sd	s2,48(sp)
    80002a30:	f44e                	sd	s3,40(sp)
    80002a32:	f052                	sd	s4,32(sp)
    80002a34:	ec56                	sd	s5,24(sp)
    80002a36:	e85a                	sd	s6,16(sp)
    80002a38:	e45e                	sd	s7,8(sp)
    80002a3a:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002a3c:	00005517          	auipc	a0,0x5
    80002a40:	68c50513          	addi	a0,a0,1676 # 800080c8 <digits+0x88>
    80002a44:	ffffe097          	auipc	ra,0xffffe
    80002a48:	b4a080e7          	jalr	-1206(ra) # 8000058e <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002a4c:	0000f497          	auipc	s1,0xf
    80002a50:	94c48493          	addi	s1,s1,-1716 # 80011398 <proc+0x158>
    80002a54:	00016917          	auipc	s2,0x16
    80002a58:	54490913          	addi	s2,s2,1348 # 80018f98 <bcache+0x140>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002a5c:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002a5e:	00006997          	auipc	s3,0x6
    80002a62:	82298993          	addi	s3,s3,-2014 # 80008280 <digits+0x240>
    printf("%d %s %s %d %d %d %d", p->pid, state, p->name, p->queue, p->tickcount, p->waittickcount, p->queueposition);
    80002a66:	00006a97          	auipc	s5,0x6
    80002a6a:	822a8a93          	addi	s5,s5,-2014 # 80008288 <digits+0x248>
    printf("\n");
    80002a6e:	00005a17          	auipc	s4,0x5
    80002a72:	65aa0a13          	addi	s4,s4,1626 # 800080c8 <digits+0x88>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002a76:	00006b97          	auipc	s7,0x6
    80002a7a:	86ab8b93          	addi	s7,s7,-1942 # 800082e0 <states.1805>
    80002a7e:	a80d                	j	80002ab0 <procdump+0x8a>
    printf("%d %s %s %d %d %d %d", p->pid, state, p->name, p->queue, p->tickcount, p->waittickcount, p->queueposition);
    80002a80:	0946a883          	lw	a7,148(a3)
    80002a84:	0906a803          	lw	a6,144(a3)
    80002a88:	0886a783          	lw	a5,136(a3)
    80002a8c:	08c6a703          	lw	a4,140(a3)
    80002a90:	ed86a583          	lw	a1,-296(a3)
    80002a94:	8556                	mv	a0,s5
    80002a96:	ffffe097          	auipc	ra,0xffffe
    80002a9a:	af8080e7          	jalr	-1288(ra) # 8000058e <printf>
    printf("\n");
    80002a9e:	8552                	mv	a0,s4
    80002aa0:	ffffe097          	auipc	ra,0xffffe
    80002aa4:	aee080e7          	jalr	-1298(ra) # 8000058e <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002aa8:	1f048493          	addi	s1,s1,496
    80002aac:	03248163          	beq	s1,s2,80002ace <procdump+0xa8>
    if (p->state == UNUSED)
    80002ab0:	86a6                	mv	a3,s1
    80002ab2:	ec04a783          	lw	a5,-320(s1)
    80002ab6:	dbed                	beqz	a5,80002aa8 <procdump+0x82>
      state = "???";
    80002ab8:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002aba:	fcfb63e3          	bltu	s6,a5,80002a80 <procdump+0x5a>
    80002abe:	1782                	slli	a5,a5,0x20
    80002ac0:	9381                	srli	a5,a5,0x20
    80002ac2:	078e                	slli	a5,a5,0x3
    80002ac4:	97de                	add	a5,a5,s7
    80002ac6:	6390                	ld	a2,0(a5)
    80002ac8:	fe45                	bnez	a2,80002a80 <procdump+0x5a>
      state = "???";
    80002aca:	864e                	mv	a2,s3
    80002acc:	bf55                	j	80002a80 <procdump+0x5a>
  }
  printf("%d %d %d %d %d\n", queueprocesscount[0], queueprocesscount[1], queueprocesscount[2], queueprocesscount[3], queueprocesscount[4]);
    80002ace:	0000e597          	auipc	a1,0xe
    80002ad2:	31258593          	addi	a1,a1,786 # 80010de0 <pid_lock>
    80002ad6:	4405a783          	lw	a5,1088(a1)
    80002ada:	43c5a703          	lw	a4,1084(a1)
    80002ade:	4385a683          	lw	a3,1080(a1)
    80002ae2:	4345a603          	lw	a2,1076(a1)
    80002ae6:	4305a583          	lw	a1,1072(a1)
    80002aea:	00005517          	auipc	a0,0x5
    80002aee:	7b650513          	addi	a0,a0,1974 # 800082a0 <digits+0x260>
    80002af2:	ffffe097          	auipc	ra,0xffffe
    80002af6:	a9c080e7          	jalr	-1380(ra) # 8000058e <printf>
}
    80002afa:	60a6                	ld	ra,72(sp)
    80002afc:	6406                	ld	s0,64(sp)
    80002afe:	74e2                	ld	s1,56(sp)
    80002b00:	7942                	ld	s2,48(sp)
    80002b02:	79a2                	ld	s3,40(sp)
    80002b04:	7a02                	ld	s4,32(sp)
    80002b06:	6ae2                	ld	s5,24(sp)
    80002b08:	6b42                	ld	s6,16(sp)
    80002b0a:	6ba2                	ld	s7,8(sp)
    80002b0c:	6161                	addi	sp,sp,80
    80002b0e:	8082                	ret

0000000080002b10 <setpriority>:

int setpriority(int new_priority, int pid)
{
    80002b10:	7179                	addi	sp,sp,-48
    80002b12:	f406                	sd	ra,40(sp)
    80002b14:	f022                	sd	s0,32(sp)
    80002b16:	ec26                	sd	s1,24(sp)
    80002b18:	e84a                	sd	s2,16(sp)
    80002b1a:	e44e                	sd	s3,8(sp)
    80002b1c:	e052                	sd	s4,0(sp)
    80002b1e:	1800                	addi	s0,sp,48
    80002b20:	8a2a                	mv	s4,a0
    80002b22:	892e                	mv	s2,a1
  int prev_priority;
  prev_priority = 0;

  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    80002b24:	0000e497          	auipc	s1,0xe
    80002b28:	71c48493          	addi	s1,s1,1820 # 80011240 <proc>
    80002b2c:	00016997          	auipc	s3,0x16
    80002b30:	31498993          	addi	s3,s3,788 # 80018e40 <tickslock>
  {
    acquire(&p->lock);
    80002b34:	8526                	mv	a0,s1
    80002b36:	ffffe097          	auipc	ra,0xffffe
    80002b3a:	0b4080e7          	jalr	180(ra) # 80000bea <acquire>

    if (p->pid == pid)
    80002b3e:	589c                	lw	a5,48(s1)
    80002b40:	01278d63          	beq	a5,s2,80002b5a <setpriority+0x4a>
        yield();
      }

      break;
    }
    release(&p->lock);
    80002b44:	8526                	mv	a0,s1
    80002b46:	ffffe097          	auipc	ra,0xffffe
    80002b4a:	158080e7          	jalr	344(ra) # 80000c9e <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002b4e:	1f048493          	addi	s1,s1,496
    80002b52:	ff3491e3          	bne	s1,s3,80002b34 <setpriority+0x24>
  prev_priority = 0;
    80002b56:	4901                	li	s2,0
    80002b58:	a005                	j	80002b78 <setpriority+0x68>
      prev_priority = p->priority;
    80002b5a:	1d84a903          	lw	s2,472(s1)
      p->priority = new_priority;
    80002b5e:	1d44bc23          	sd	s4,472(s1)
      p->sleeptime = 0;
    80002b62:	1c04b423          	sd	zero,456(s1)
      p->runtime = 0;
    80002b66:	1a04bc23          	sd	zero,440(s1)
      release(&p->lock);
    80002b6a:	8526                	mv	a0,s1
    80002b6c:	ffffe097          	auipc	ra,0xffffe
    80002b70:	132080e7          	jalr	306(ra) # 80000c9e <release>
      if (reschedule)
    80002b74:	012a4b63          	blt	s4,s2,80002b8a <setpriority+0x7a>
  }
  return prev_priority;
}
    80002b78:	854a                	mv	a0,s2
    80002b7a:	70a2                	ld	ra,40(sp)
    80002b7c:	7402                	ld	s0,32(sp)
    80002b7e:	64e2                	ld	s1,24(sp)
    80002b80:	6942                	ld	s2,16(sp)
    80002b82:	69a2                	ld	s3,8(sp)
    80002b84:	6a02                	ld	s4,0(sp)
    80002b86:	6145                	addi	sp,sp,48
    80002b88:	8082                	ret
        yield();
    80002b8a:	00000097          	auipc	ra,0x0
    80002b8e:	854080e7          	jalr	-1964(ra) # 800023de <yield>
    80002b92:	b7dd                	j	80002b78 <setpriority+0x68>

0000000080002b94 <swtch>:
    80002b94:	00153023          	sd	ra,0(a0)
    80002b98:	00253423          	sd	sp,8(a0)
    80002b9c:	e900                	sd	s0,16(a0)
    80002b9e:	ed04                	sd	s1,24(a0)
    80002ba0:	03253023          	sd	s2,32(a0)
    80002ba4:	03353423          	sd	s3,40(a0)
    80002ba8:	03453823          	sd	s4,48(a0)
    80002bac:	03553c23          	sd	s5,56(a0)
    80002bb0:	05653023          	sd	s6,64(a0)
    80002bb4:	05753423          	sd	s7,72(a0)
    80002bb8:	05853823          	sd	s8,80(a0)
    80002bbc:	05953c23          	sd	s9,88(a0)
    80002bc0:	07a53023          	sd	s10,96(a0)
    80002bc4:	07b53423          	sd	s11,104(a0)
    80002bc8:	0005b083          	ld	ra,0(a1)
    80002bcc:	0085b103          	ld	sp,8(a1)
    80002bd0:	6980                	ld	s0,16(a1)
    80002bd2:	6d84                	ld	s1,24(a1)
    80002bd4:	0205b903          	ld	s2,32(a1)
    80002bd8:	0285b983          	ld	s3,40(a1)
    80002bdc:	0305ba03          	ld	s4,48(a1)
    80002be0:	0385ba83          	ld	s5,56(a1)
    80002be4:	0405bb03          	ld	s6,64(a1)
    80002be8:	0485bb83          	ld	s7,72(a1)
    80002bec:	0505bc03          	ld	s8,80(a1)
    80002bf0:	0585bc83          	ld	s9,88(a1)
    80002bf4:	0605bd03          	ld	s10,96(a1)
    80002bf8:	0685bd83          	ld	s11,104(a1)
    80002bfc:	8082                	ret

0000000080002bfe <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002bfe:	1141                	addi	sp,sp,-16
    80002c00:	e406                	sd	ra,8(sp)
    80002c02:	e022                	sd	s0,0(sp)
    80002c04:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002c06:	00005597          	auipc	a1,0x5
    80002c0a:	70a58593          	addi	a1,a1,1802 # 80008310 <states.1805+0x30>
    80002c0e:	00016517          	auipc	a0,0x16
    80002c12:	23250513          	addi	a0,a0,562 # 80018e40 <tickslock>
    80002c16:	ffffe097          	auipc	ra,0xffffe
    80002c1a:	f44080e7          	jalr	-188(ra) # 80000b5a <initlock>
}
    80002c1e:	60a2                	ld	ra,8(sp)
    80002c20:	6402                	ld	s0,0(sp)
    80002c22:	0141                	addi	sp,sp,16
    80002c24:	8082                	ret

0000000080002c26 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002c26:	1141                	addi	sp,sp,-16
    80002c28:	e422                	sd	s0,8(sp)
    80002c2a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c2c:	00003797          	auipc	a5,0x3
    80002c30:	7b478793          	addi	a5,a5,1972 # 800063e0 <kernelvec>
    80002c34:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002c38:	6422                	ld	s0,8(sp)
    80002c3a:	0141                	addi	sp,sp,16
    80002c3c:	8082                	ret

0000000080002c3e <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002c3e:	1141                	addi	sp,sp,-16
    80002c40:	e406                	sd	ra,8(sp)
    80002c42:	e022                	sd	s0,0(sp)
    80002c44:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002c46:	fffff097          	auipc	ra,0xfffff
    80002c4a:	d80080e7          	jalr	-640(ra) # 800019c6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c4e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002c52:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c54:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002c58:	00004617          	auipc	a2,0x4
    80002c5c:	3a860613          	addi	a2,a2,936 # 80007000 <_trampoline>
    80002c60:	00004697          	auipc	a3,0x4
    80002c64:	3a068693          	addi	a3,a3,928 # 80007000 <_trampoline>
    80002c68:	8e91                	sub	a3,a3,a2
    80002c6a:	040007b7          	lui	a5,0x4000
    80002c6e:	17fd                	addi	a5,a5,-1
    80002c70:	07b2                	slli	a5,a5,0xc
    80002c72:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c74:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002c78:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002c7a:	180026f3          	csrr	a3,satp
    80002c7e:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002c80:	6d38                	ld	a4,88(a0)
    80002c82:	6134                	ld	a3,64(a0)
    80002c84:	6585                	lui	a1,0x1
    80002c86:	96ae                	add	a3,a3,a1
    80002c88:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002c8a:	6d38                	ld	a4,88(a0)
    80002c8c:	00000697          	auipc	a3,0x0
    80002c90:	13e68693          	addi	a3,a3,318 # 80002dca <usertrap>
    80002c94:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002c96:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002c98:	8692                	mv	a3,tp
    80002c9a:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c9c:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002ca0:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002ca4:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ca8:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002cac:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002cae:	6f18                	ld	a4,24(a4)
    80002cb0:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002cb4:	6928                	ld	a0,80(a0)
    80002cb6:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002cb8:	00004717          	auipc	a4,0x4
    80002cbc:	3e470713          	addi	a4,a4,996 # 8000709c <userret>
    80002cc0:	8f11                	sub	a4,a4,a2
    80002cc2:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002cc4:	577d                	li	a4,-1
    80002cc6:	177e                	slli	a4,a4,0x3f
    80002cc8:	8d59                	or	a0,a0,a4
    80002cca:	9782                	jalr	a5
}
    80002ccc:	60a2                	ld	ra,8(sp)
    80002cce:	6402                	ld	s0,0(sp)
    80002cd0:	0141                	addi	sp,sp,16
    80002cd2:	8082                	ret

0000000080002cd4 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002cd4:	1101                	addi	sp,sp,-32
    80002cd6:	ec06                	sd	ra,24(sp)
    80002cd8:	e822                	sd	s0,16(sp)
    80002cda:	e426                	sd	s1,8(sp)
    80002cdc:	e04a                	sd	s2,0(sp)
    80002cde:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002ce0:	00016917          	auipc	s2,0x16
    80002ce4:	16090913          	addi	s2,s2,352 # 80018e40 <tickslock>
    80002ce8:	854a                	mv	a0,s2
    80002cea:	ffffe097          	auipc	ra,0xffffe
    80002cee:	f00080e7          	jalr	-256(ra) # 80000bea <acquire>
  ticks++;
    80002cf2:	00006497          	auipc	s1,0x6
    80002cf6:	e7e48493          	addi	s1,s1,-386 # 80008b70 <ticks>
    80002cfa:	409c                	lw	a5,0(s1)
    80002cfc:	2785                	addiw	a5,a5,1
    80002cfe:	c09c                	sw	a5,0(s1)
  update_time();
    80002d00:	fffff097          	auipc	ra,0xfffff
    80002d04:	26e080e7          	jalr	622(ra) # 80001f6e <update_time>
  wakeup(&ticks);
    80002d08:	8526                	mv	a0,s1
    80002d0a:	00000097          	auipc	ra,0x0
    80002d0e:	8c0080e7          	jalr	-1856(ra) # 800025ca <wakeup>
  release(&tickslock);
    80002d12:	854a                	mv	a0,s2
    80002d14:	ffffe097          	auipc	ra,0xffffe
    80002d18:	f8a080e7          	jalr	-118(ra) # 80000c9e <release>
}
    80002d1c:	60e2                	ld	ra,24(sp)
    80002d1e:	6442                	ld	s0,16(sp)
    80002d20:	64a2                	ld	s1,8(sp)
    80002d22:	6902                	ld	s2,0(sp)
    80002d24:	6105                	addi	sp,sp,32
    80002d26:	8082                	ret

0000000080002d28 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002d28:	1101                	addi	sp,sp,-32
    80002d2a:	ec06                	sd	ra,24(sp)
    80002d2c:	e822                	sd	s0,16(sp)
    80002d2e:	e426                	sd	s1,8(sp)
    80002d30:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d32:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002d36:	00074d63          	bltz	a4,80002d50 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002d3a:	57fd                	li	a5,-1
    80002d3c:	17fe                	slli	a5,a5,0x3f
    80002d3e:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002d40:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002d42:	06f70363          	beq	a4,a5,80002da8 <devintr+0x80>
  }
}
    80002d46:	60e2                	ld	ra,24(sp)
    80002d48:	6442                	ld	s0,16(sp)
    80002d4a:	64a2                	ld	s1,8(sp)
    80002d4c:	6105                	addi	sp,sp,32
    80002d4e:	8082                	ret
     (scause & 0xff) == 9){
    80002d50:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002d54:	46a5                	li	a3,9
    80002d56:	fed792e3          	bne	a5,a3,80002d3a <devintr+0x12>
    int irq = plic_claim();
    80002d5a:	00003097          	auipc	ra,0x3
    80002d5e:	78e080e7          	jalr	1934(ra) # 800064e8 <plic_claim>
    80002d62:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002d64:	47a9                	li	a5,10
    80002d66:	02f50763          	beq	a0,a5,80002d94 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002d6a:	4785                	li	a5,1
    80002d6c:	02f50963          	beq	a0,a5,80002d9e <devintr+0x76>
    return 1;
    80002d70:	4505                	li	a0,1
    } else if(irq){
    80002d72:	d8f1                	beqz	s1,80002d46 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002d74:	85a6                	mv	a1,s1
    80002d76:	00005517          	auipc	a0,0x5
    80002d7a:	5a250513          	addi	a0,a0,1442 # 80008318 <states.1805+0x38>
    80002d7e:	ffffe097          	auipc	ra,0xffffe
    80002d82:	810080e7          	jalr	-2032(ra) # 8000058e <printf>
      plic_complete(irq);
    80002d86:	8526                	mv	a0,s1
    80002d88:	00003097          	auipc	ra,0x3
    80002d8c:	784080e7          	jalr	1924(ra) # 8000650c <plic_complete>
    return 1;
    80002d90:	4505                	li	a0,1
    80002d92:	bf55                	j	80002d46 <devintr+0x1e>
      uartintr();
    80002d94:	ffffe097          	auipc	ra,0xffffe
    80002d98:	c1a080e7          	jalr	-998(ra) # 800009ae <uartintr>
    80002d9c:	b7ed                	j	80002d86 <devintr+0x5e>
      virtio_disk_intr();
    80002d9e:	00004097          	auipc	ra,0x4
    80002da2:	c98080e7          	jalr	-872(ra) # 80006a36 <virtio_disk_intr>
    80002da6:	b7c5                	j	80002d86 <devintr+0x5e>
    if(cpuid() == 0){
    80002da8:	fffff097          	auipc	ra,0xfffff
    80002dac:	bf2080e7          	jalr	-1038(ra) # 8000199a <cpuid>
    80002db0:	c901                	beqz	a0,80002dc0 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002db2:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002db6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002db8:	14479073          	csrw	sip,a5
    return 2;
    80002dbc:	4509                	li	a0,2
    80002dbe:	b761                	j	80002d46 <devintr+0x1e>
      clockintr();
    80002dc0:	00000097          	auipc	ra,0x0
    80002dc4:	f14080e7          	jalr	-236(ra) # 80002cd4 <clockintr>
    80002dc8:	b7ed                	j	80002db2 <devintr+0x8a>

0000000080002dca <usertrap>:
{
    80002dca:	1101                	addi	sp,sp,-32
    80002dcc:	ec06                	sd	ra,24(sp)
    80002dce:	e822                	sd	s0,16(sp)
    80002dd0:	e426                	sd	s1,8(sp)
    80002dd2:	e04a                	sd	s2,0(sp)
    80002dd4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002dd6:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002dda:	1007f793          	andi	a5,a5,256
    80002dde:	e3b1                	bnez	a5,80002e22 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002de0:	00003797          	auipc	a5,0x3
    80002de4:	60078793          	addi	a5,a5,1536 # 800063e0 <kernelvec>
    80002de8:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002dec:	fffff097          	auipc	ra,0xfffff
    80002df0:	bda080e7          	jalr	-1062(ra) # 800019c6 <myproc>
    80002df4:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002df6:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002df8:	14102773          	csrr	a4,sepc
    80002dfc:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002dfe:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002e02:	47a1                	li	a5,8
    80002e04:	02f70763          	beq	a4,a5,80002e32 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002e08:	00000097          	auipc	ra,0x0
    80002e0c:	f20080e7          	jalr	-224(ra) # 80002d28 <devintr>
    80002e10:	892a                	mv	s2,a0
    80002e12:	c92d                	beqz	a0,80002e84 <usertrap+0xba>
  if(killed(p))
    80002e14:	8526                	mv	a0,s1
    80002e16:	00000097          	auipc	ra,0x0
    80002e1a:	a04080e7          	jalr	-1532(ra) # 8000281a <killed>
    80002e1e:	c555                	beqz	a0,80002eca <usertrap+0x100>
    80002e20:	a045                	j	80002ec0 <usertrap+0xf6>
    panic("usertrap: not from user mode");
    80002e22:	00005517          	auipc	a0,0x5
    80002e26:	51650513          	addi	a0,a0,1302 # 80008338 <states.1805+0x58>
    80002e2a:	ffffd097          	auipc	ra,0xffffd
    80002e2e:	71a080e7          	jalr	1818(ra) # 80000544 <panic>
    if(killed(p))
    80002e32:	00000097          	auipc	ra,0x0
    80002e36:	9e8080e7          	jalr	-1560(ra) # 8000281a <killed>
    80002e3a:	ed1d                	bnez	a0,80002e78 <usertrap+0xae>
    p->trapframe->epc += 4;
    80002e3c:	6cb8                	ld	a4,88(s1)
    80002e3e:	6f1c                	ld	a5,24(a4)
    80002e40:	0791                	addi	a5,a5,4
    80002e42:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e44:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002e48:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002e4c:	10079073          	csrw	sstatus,a5
    syscall();
    80002e50:	00000097          	auipc	ra,0x0
    80002e54:	328080e7          	jalr	808(ra) # 80003178 <syscall>
  if(killed(p))
    80002e58:	8526                	mv	a0,s1
    80002e5a:	00000097          	auipc	ra,0x0
    80002e5e:	9c0080e7          	jalr	-1600(ra) # 8000281a <killed>
    80002e62:	ed31                	bnez	a0,80002ebe <usertrap+0xf4>
  usertrapret();
    80002e64:	00000097          	auipc	ra,0x0
    80002e68:	dda080e7          	jalr	-550(ra) # 80002c3e <usertrapret>
}
    80002e6c:	60e2                	ld	ra,24(sp)
    80002e6e:	6442                	ld	s0,16(sp)
    80002e70:	64a2                	ld	s1,8(sp)
    80002e72:	6902                	ld	s2,0(sp)
    80002e74:	6105                	addi	sp,sp,32
    80002e76:	8082                	ret
      exit(-1);
    80002e78:	557d                	li	a0,-1
    80002e7a:	00000097          	auipc	ra,0x0
    80002e7e:	820080e7          	jalr	-2016(ra) # 8000269a <exit>
    80002e82:	bf6d                	j	80002e3c <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e84:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002e88:	5890                	lw	a2,48(s1)
    80002e8a:	00005517          	auipc	a0,0x5
    80002e8e:	4ce50513          	addi	a0,a0,1230 # 80008358 <states.1805+0x78>
    80002e92:	ffffd097          	auipc	ra,0xffffd
    80002e96:	6fc080e7          	jalr	1788(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e9a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002e9e:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ea2:	00005517          	auipc	a0,0x5
    80002ea6:	4e650513          	addi	a0,a0,1254 # 80008388 <states.1805+0xa8>
    80002eaa:	ffffd097          	auipc	ra,0xffffd
    80002eae:	6e4080e7          	jalr	1764(ra) # 8000058e <printf>
    setkilled(p);
    80002eb2:	8526                	mv	a0,s1
    80002eb4:	00000097          	auipc	ra,0x0
    80002eb8:	93a080e7          	jalr	-1734(ra) # 800027ee <setkilled>
    80002ebc:	bf71                	j	80002e58 <usertrap+0x8e>
  if(killed(p))
    80002ebe:	4901                	li	s2,0
    exit(-1);
    80002ec0:	557d                	li	a0,-1
    80002ec2:	fffff097          	auipc	ra,0xfffff
    80002ec6:	7d8080e7          	jalr	2008(ra) # 8000269a <exit>
  if (which_dev == 2 && p->alarm_on == 1 && p->handlerpermission == 1) {
    80002eca:	4789                	li	a5,2
    80002ecc:	f8f91ce3          	bne	s2,a5,80002e64 <usertrap+0x9a>
    80002ed0:	1984a703          	lw	a4,408(s1)
    80002ed4:	4785                	li	a5,1
    80002ed6:	00f70763          	beq	a4,a5,80002ee4 <usertrap+0x11a>
    yield();
    80002eda:	fffff097          	auipc	ra,0xfffff
    80002ede:	504080e7          	jalr	1284(ra) # 800023de <yield>
    80002ee2:	b749                	j	80002e64 <usertrap+0x9a>
  if (which_dev == 2 && p->alarm_on == 1 && p->handlerpermission == 1) {
    80002ee4:	1b04a703          	lw	a4,432(s1)
    80002ee8:	fef719e3          	bne	a4,a5,80002eda <usertrap+0x110>
      struct trapframe *tf = kalloc();
    80002eec:	ffffe097          	auipc	ra,0xffffe
    80002ef0:	c0e080e7          	jalr	-1010(ra) # 80000afa <kalloc>
    80002ef4:	892a                	mv	s2,a0
      memmove(tf, p->trapframe, PGSIZE);
    80002ef6:	6605                	lui	a2,0x1
    80002ef8:	6cac                	ld	a1,88(s1)
    80002efa:	ffffe097          	auipc	ra,0xffffe
    80002efe:	e4c080e7          	jalr	-436(ra) # 80000d46 <memmove>
      p->alarm_tf = tf;
    80002f02:	1924b823          	sd	s2,400(s1)
      p->cur_ticks++;
    80002f06:	18c4a783          	lw	a5,396(s1)
    80002f0a:	2785                	addiw	a5,a5,1
    80002f0c:	0007871b          	sext.w	a4,a5
    80002f10:	18f4a623          	sw	a5,396(s1)
      if (p->cur_ticks >= p->ticks){
    80002f14:	1884a783          	lw	a5,392(s1)
    80002f18:	fcf741e3          	blt	a4,a5,80002eda <usertrap+0x110>
        p->trapframe->epc = p->handler;
    80002f1c:	6cbc                	ld	a5,88(s1)
    80002f1e:	1804b703          	ld	a4,384(s1)
    80002f22:	ef98                	sd	a4,24(a5)
        p->handlerpermission = 0;
    80002f24:	1a04a823          	sw	zero,432(s1)
    80002f28:	bf4d                	j	80002eda <usertrap+0x110>

0000000080002f2a <kerneltrap>:
{
    80002f2a:	7179                	addi	sp,sp,-48
    80002f2c:	f406                	sd	ra,40(sp)
    80002f2e:	f022                	sd	s0,32(sp)
    80002f30:	ec26                	sd	s1,24(sp)
    80002f32:	e84a                	sd	s2,16(sp)
    80002f34:	e44e                	sd	s3,8(sp)
    80002f36:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002f38:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f3c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f40:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002f44:	1004f793          	andi	a5,s1,256
    80002f48:	cb85                	beqz	a5,80002f78 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f4a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002f4e:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002f50:	ef85                	bnez	a5,80002f88 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002f52:	00000097          	auipc	ra,0x0
    80002f56:	dd6080e7          	jalr	-554(ra) # 80002d28 <devintr>
    80002f5a:	cd1d                	beqz	a0,80002f98 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002f5c:	4789                	li	a5,2
    80002f5e:	06f50a63          	beq	a0,a5,80002fd2 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002f62:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002f66:	10049073          	csrw	sstatus,s1
}
    80002f6a:	70a2                	ld	ra,40(sp)
    80002f6c:	7402                	ld	s0,32(sp)
    80002f6e:	64e2                	ld	s1,24(sp)
    80002f70:	6942                	ld	s2,16(sp)
    80002f72:	69a2                	ld	s3,8(sp)
    80002f74:	6145                	addi	sp,sp,48
    80002f76:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002f78:	00005517          	auipc	a0,0x5
    80002f7c:	43050513          	addi	a0,a0,1072 # 800083a8 <states.1805+0xc8>
    80002f80:	ffffd097          	auipc	ra,0xffffd
    80002f84:	5c4080e7          	jalr	1476(ra) # 80000544 <panic>
    panic("kerneltrap: interrupts enabled");
    80002f88:	00005517          	auipc	a0,0x5
    80002f8c:	44850513          	addi	a0,a0,1096 # 800083d0 <states.1805+0xf0>
    80002f90:	ffffd097          	auipc	ra,0xffffd
    80002f94:	5b4080e7          	jalr	1460(ra) # 80000544 <panic>
    printf("scause %p\n", scause);
    80002f98:	85ce                	mv	a1,s3
    80002f9a:	00005517          	auipc	a0,0x5
    80002f9e:	45650513          	addi	a0,a0,1110 # 800083f0 <states.1805+0x110>
    80002fa2:	ffffd097          	auipc	ra,0xffffd
    80002fa6:	5ec080e7          	jalr	1516(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002faa:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002fae:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002fb2:	00005517          	auipc	a0,0x5
    80002fb6:	44e50513          	addi	a0,a0,1102 # 80008400 <states.1805+0x120>
    80002fba:	ffffd097          	auipc	ra,0xffffd
    80002fbe:	5d4080e7          	jalr	1492(ra) # 8000058e <printf>
    panic("kerneltrap");
    80002fc2:	00005517          	auipc	a0,0x5
    80002fc6:	45650513          	addi	a0,a0,1110 # 80008418 <states.1805+0x138>
    80002fca:	ffffd097          	auipc	ra,0xffffd
    80002fce:	57a080e7          	jalr	1402(ra) # 80000544 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002fd2:	fffff097          	auipc	ra,0xfffff
    80002fd6:	9f4080e7          	jalr	-1548(ra) # 800019c6 <myproc>
    80002fda:	d541                	beqz	a0,80002f62 <kerneltrap+0x38>
    80002fdc:	fffff097          	auipc	ra,0xfffff
    80002fe0:	9ea080e7          	jalr	-1558(ra) # 800019c6 <myproc>
    80002fe4:	4d18                	lw	a4,24(a0)
    80002fe6:	4791                	li	a5,4
    80002fe8:	f6f71de3          	bne	a4,a5,80002f62 <kerneltrap+0x38>
    yield();
    80002fec:	fffff097          	auipc	ra,0xfffff
    80002ff0:	3f2080e7          	jalr	1010(ra) # 800023de <yield>
    80002ff4:	b7bd                	j	80002f62 <kerneltrap+0x38>

0000000080002ff6 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002ff6:	1101                	addi	sp,sp,-32
    80002ff8:	ec06                	sd	ra,24(sp)
    80002ffa:	e822                	sd	s0,16(sp)
    80002ffc:	e426                	sd	s1,8(sp)
    80002ffe:	1000                	addi	s0,sp,32
    80003000:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80003002:	fffff097          	auipc	ra,0xfffff
    80003006:	9c4080e7          	jalr	-1596(ra) # 800019c6 <myproc>
  switch (n) {
    8000300a:	4795                	li	a5,5
    8000300c:	0497e163          	bltu	a5,s1,8000304e <argraw+0x58>
    80003010:	048a                	slli	s1,s1,0x2
    80003012:	00005717          	auipc	a4,0x5
    80003016:	55e70713          	addi	a4,a4,1374 # 80008570 <states.1805+0x290>
    8000301a:	94ba                	add	s1,s1,a4
    8000301c:	409c                	lw	a5,0(s1)
    8000301e:	97ba                	add	a5,a5,a4
    80003020:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80003022:	6d3c                	ld	a5,88(a0)
    80003024:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003026:	60e2                	ld	ra,24(sp)
    80003028:	6442                	ld	s0,16(sp)
    8000302a:	64a2                	ld	s1,8(sp)
    8000302c:	6105                	addi	sp,sp,32
    8000302e:	8082                	ret
    return p->trapframe->a1;
    80003030:	6d3c                	ld	a5,88(a0)
    80003032:	7fa8                	ld	a0,120(a5)
    80003034:	bfcd                	j	80003026 <argraw+0x30>
    return p->trapframe->a2;
    80003036:	6d3c                	ld	a5,88(a0)
    80003038:	63c8                	ld	a0,128(a5)
    8000303a:	b7f5                	j	80003026 <argraw+0x30>
    return p->trapframe->a3;
    8000303c:	6d3c                	ld	a5,88(a0)
    8000303e:	67c8                	ld	a0,136(a5)
    80003040:	b7dd                	j	80003026 <argraw+0x30>
    return p->trapframe->a4;
    80003042:	6d3c                	ld	a5,88(a0)
    80003044:	6bc8                	ld	a0,144(a5)
    80003046:	b7c5                	j	80003026 <argraw+0x30>
    return p->trapframe->a5;
    80003048:	6d3c                	ld	a5,88(a0)
    8000304a:	6fc8                	ld	a0,152(a5)
    8000304c:	bfe9                	j	80003026 <argraw+0x30>
  panic("argraw");
    8000304e:	00005517          	auipc	a0,0x5
    80003052:	3da50513          	addi	a0,a0,986 # 80008428 <states.1805+0x148>
    80003056:	ffffd097          	auipc	ra,0xffffd
    8000305a:	4ee080e7          	jalr	1262(ra) # 80000544 <panic>

000000008000305e <fetchaddr>:
{
    8000305e:	1101                	addi	sp,sp,-32
    80003060:	ec06                	sd	ra,24(sp)
    80003062:	e822                	sd	s0,16(sp)
    80003064:	e426                	sd	s1,8(sp)
    80003066:	e04a                	sd	s2,0(sp)
    80003068:	1000                	addi	s0,sp,32
    8000306a:	84aa                	mv	s1,a0
    8000306c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000306e:	fffff097          	auipc	ra,0xfffff
    80003072:	958080e7          	jalr	-1704(ra) # 800019c6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80003076:	653c                	ld	a5,72(a0)
    80003078:	02f4f863          	bgeu	s1,a5,800030a8 <fetchaddr+0x4a>
    8000307c:	00848713          	addi	a4,s1,8
    80003080:	02e7e663          	bltu	a5,a4,800030ac <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003084:	46a1                	li	a3,8
    80003086:	8626                	mv	a2,s1
    80003088:	85ca                	mv	a1,s2
    8000308a:	6928                	ld	a0,80(a0)
    8000308c:	ffffe097          	auipc	ra,0xffffe
    80003090:	684080e7          	jalr	1668(ra) # 80001710 <copyin>
    80003094:	00a03533          	snez	a0,a0
    80003098:	40a00533          	neg	a0,a0
}
    8000309c:	60e2                	ld	ra,24(sp)
    8000309e:	6442                	ld	s0,16(sp)
    800030a0:	64a2                	ld	s1,8(sp)
    800030a2:	6902                	ld	s2,0(sp)
    800030a4:	6105                	addi	sp,sp,32
    800030a6:	8082                	ret
    return -1;
    800030a8:	557d                	li	a0,-1
    800030aa:	bfcd                	j	8000309c <fetchaddr+0x3e>
    800030ac:	557d                	li	a0,-1
    800030ae:	b7fd                	j	8000309c <fetchaddr+0x3e>

00000000800030b0 <fetchstr>:
{
    800030b0:	7179                	addi	sp,sp,-48
    800030b2:	f406                	sd	ra,40(sp)
    800030b4:	f022                	sd	s0,32(sp)
    800030b6:	ec26                	sd	s1,24(sp)
    800030b8:	e84a                	sd	s2,16(sp)
    800030ba:	e44e                	sd	s3,8(sp)
    800030bc:	1800                	addi	s0,sp,48
    800030be:	892a                	mv	s2,a0
    800030c0:	84ae                	mv	s1,a1
    800030c2:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800030c4:	fffff097          	auipc	ra,0xfffff
    800030c8:	902080e7          	jalr	-1790(ra) # 800019c6 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800030cc:	86ce                	mv	a3,s3
    800030ce:	864a                	mv	a2,s2
    800030d0:	85a6                	mv	a1,s1
    800030d2:	6928                	ld	a0,80(a0)
    800030d4:	ffffe097          	auipc	ra,0xffffe
    800030d8:	6c8080e7          	jalr	1736(ra) # 8000179c <copyinstr>
    800030dc:	00054e63          	bltz	a0,800030f8 <fetchstr+0x48>
  return strlen(buf);
    800030e0:	8526                	mv	a0,s1
    800030e2:	ffffe097          	auipc	ra,0xffffe
    800030e6:	d88080e7          	jalr	-632(ra) # 80000e6a <strlen>
}
    800030ea:	70a2                	ld	ra,40(sp)
    800030ec:	7402                	ld	s0,32(sp)
    800030ee:	64e2                	ld	s1,24(sp)
    800030f0:	6942                	ld	s2,16(sp)
    800030f2:	69a2                	ld	s3,8(sp)
    800030f4:	6145                	addi	sp,sp,48
    800030f6:	8082                	ret
    return -1;
    800030f8:	557d                	li	a0,-1
    800030fa:	bfc5                	j	800030ea <fetchstr+0x3a>

00000000800030fc <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    800030fc:	1101                	addi	sp,sp,-32
    800030fe:	ec06                	sd	ra,24(sp)
    80003100:	e822                	sd	s0,16(sp)
    80003102:	e426                	sd	s1,8(sp)
    80003104:	1000                	addi	s0,sp,32
    80003106:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003108:	00000097          	auipc	ra,0x0
    8000310c:	eee080e7          	jalr	-274(ra) # 80002ff6 <argraw>
    80003110:	c088                	sw	a0,0(s1)
  return 0;
}
    80003112:	4501                	li	a0,0
    80003114:	60e2                	ld	ra,24(sp)
    80003116:	6442                	ld	s0,16(sp)
    80003118:	64a2                	ld	s1,8(sp)
    8000311a:	6105                	addi	sp,sp,32
    8000311c:	8082                	ret

000000008000311e <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    8000311e:	1101                	addi	sp,sp,-32
    80003120:	ec06                	sd	ra,24(sp)
    80003122:	e822                	sd	s0,16(sp)
    80003124:	e426                	sd	s1,8(sp)
    80003126:	1000                	addi	s0,sp,32
    80003128:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000312a:	00000097          	auipc	ra,0x0
    8000312e:	ecc080e7          	jalr	-308(ra) # 80002ff6 <argraw>
    80003132:	e088                	sd	a0,0(s1)
  return 0;
}
    80003134:	4501                	li	a0,0
    80003136:	60e2                	ld	ra,24(sp)
    80003138:	6442                	ld	s0,16(sp)
    8000313a:	64a2                	ld	s1,8(sp)
    8000313c:	6105                	addi	sp,sp,32
    8000313e:	8082                	ret

0000000080003140 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003140:	7179                	addi	sp,sp,-48
    80003142:	f406                	sd	ra,40(sp)
    80003144:	f022                	sd	s0,32(sp)
    80003146:	ec26                	sd	s1,24(sp)
    80003148:	e84a                	sd	s2,16(sp)
    8000314a:	1800                	addi	s0,sp,48
    8000314c:	84ae                	mv	s1,a1
    8000314e:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80003150:	fd840593          	addi	a1,s0,-40
    80003154:	00000097          	auipc	ra,0x0
    80003158:	fca080e7          	jalr	-54(ra) # 8000311e <argaddr>
  return fetchstr(addr, buf, max);
    8000315c:	864a                	mv	a2,s2
    8000315e:	85a6                	mv	a1,s1
    80003160:	fd843503          	ld	a0,-40(s0)
    80003164:	00000097          	auipc	ra,0x0
    80003168:	f4c080e7          	jalr	-180(ra) # 800030b0 <fetchstr>
}
    8000316c:	70a2                	ld	ra,40(sp)
    8000316e:	7402                	ld	s0,32(sp)
    80003170:	64e2                	ld	s1,24(sp)
    80003172:	6942                	ld	s2,16(sp)
    80003174:	6145                	addi	sp,sp,48
    80003176:	8082                	ret

0000000080003178 <syscall>:
    [SYS_setpriority] 1,
};

void
syscall(void)
{
    80003178:	7179                	addi	sp,sp,-48
    8000317a:	f406                	sd	ra,40(sp)
    8000317c:	f022                	sd	s0,32(sp)
    8000317e:	ec26                	sd	s1,24(sp)
    80003180:	e84a                	sd	s2,16(sp)
    80003182:	e44e                	sd	s3,8(sp)
    80003184:	e052                	sd	s4,0(sp)
    80003186:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80003188:	fffff097          	auipc	ra,0xfffff
    8000318c:	83e080e7          	jalr	-1986(ra) # 800019c6 <myproc>
    80003190:	892a                	mv	s2,a0

  num = p->trapframe->a7;
    80003192:	6d24                	ld	s1,88(a0)
    80003194:	74dc                	ld	a5,168(s1)
    80003196:	0007899b          	sext.w	s3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) 
    8000319a:	37fd                	addiw	a5,a5,-1
    8000319c:	4769                	li	a4,26
    8000319e:	0af76163          	bltu	a4,a5,80003240 <syscall+0xc8>
    800031a2:	00399713          	slli	a4,s3,0x3
    800031a6:	00005797          	auipc	a5,0x5
    800031aa:	3e278793          	addi	a5,a5,994 # 80008588 <syscalls>
    800031ae:	97ba                	add	a5,a5,a4
    800031b0:	639c                	ld	a5,0(a5)
    800031b2:	c7d9                	beqz	a5,80003240 <syscall+0xc8>
  {
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800031b4:	9782                	jalr	a5
    800031b6:	f8a8                	sd	a0,112(s1)
    if ((p->mask >> num) & 1)
    800031b8:	16892483          	lw	s1,360(s2)
    800031bc:	4134d4bb          	sraw	s1,s1,s3
    800031c0:	8885                	andi	s1,s1,1
    800031c2:	c0c5                	beqz	s1,80003262 <syscall+0xea>
    {
      /* Modified for A4: Added entire section for trace, prints output for each syscall traced */
  	  printf("%d: syscall %s ( %d ",p->pid, syscallnames[num], p->trapframe->a0);
    800031c4:	05893703          	ld	a4,88(s2)
    800031c8:	00399693          	slli	a3,s3,0x3
    800031cc:	00006797          	auipc	a5,0x6
    800031d0:	88c78793          	addi	a5,a5,-1908 # 80008a58 <syscallnames>
    800031d4:	97b6                	add	a5,a5,a3
    800031d6:	7b34                	ld	a3,112(a4)
    800031d8:	6390                	ld	a2,0(a5)
    800031da:	03092583          	lw	a1,48(s2)
    800031de:	00005517          	auipc	a0,0x5
    800031e2:	25250513          	addi	a0,a0,594 # 80008430 <states.1805+0x150>
    800031e6:	ffffd097          	auipc	ra,0xffffd
    800031ea:	3a8080e7          	jalr	936(ra) # 8000058e <printf>
      for (int i = 1; i < syscallnum[num]; i++) /* Modified for A4: 'num' tracks number of registers used by syscall and prints its register values  */
    800031ee:	098a                	slli	s3,s3,0x2
    800031f0:	00005797          	auipc	a5,0x5
    800031f4:	39878793          	addi	a5,a5,920 # 80008588 <syscalls>
    800031f8:	99be                	add	s3,s3,a5
    800031fa:	0e09a983          	lw	s3,224(s3)
    800031fe:	4785                	li	a5,1
    80003200:	0337d463          	bge	a5,s3,80003228 <syscall+0xb0>
        printf("%d ", argraw(i));
    80003204:	00005a17          	auipc	s4,0x5
    80003208:	244a0a13          	addi	s4,s4,580 # 80008448 <states.1805+0x168>
    8000320c:	8526                	mv	a0,s1
    8000320e:	00000097          	auipc	ra,0x0
    80003212:	de8080e7          	jalr	-536(ra) # 80002ff6 <argraw>
    80003216:	85aa                	mv	a1,a0
    80003218:	8552                	mv	a0,s4
    8000321a:	ffffd097          	auipc	ra,0xffffd
    8000321e:	374080e7          	jalr	884(ra) # 8000058e <printf>
      for (int i = 1; i < syscallnum[num]; i++) /* Modified for A4: 'num' tracks number of registers used by syscall and prints its register values  */
    80003222:	2485                	addiw	s1,s1,1
    80003224:	ff3494e3          	bne	s1,s3,8000320c <syscall+0x94>
      printf(") -> %d\n", p->trapframe->a0);
    80003228:	05893783          	ld	a5,88(s2)
    8000322c:	7bac                	ld	a1,112(a5)
    8000322e:	00005517          	auipc	a0,0x5
    80003232:	22250513          	addi	a0,a0,546 # 80008450 <states.1805+0x170>
    80003236:	ffffd097          	auipc	ra,0xffffd
    8000323a:	358080e7          	jalr	856(ra) # 8000058e <printf>
    8000323e:	a015                	j	80003262 <syscall+0xea>
    }	
  } 
  else 
  {
    printf("%d %s: unknown sys call %d\n",
    80003240:	86ce                	mv	a3,s3
    80003242:	15890613          	addi	a2,s2,344
    80003246:	03092583          	lw	a1,48(s2)
    8000324a:	00005517          	auipc	a0,0x5
    8000324e:	21650513          	addi	a0,a0,534 # 80008460 <states.1805+0x180>
    80003252:	ffffd097          	auipc	ra,0xffffd
    80003256:	33c080e7          	jalr	828(ra) # 8000058e <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000325a:	05893783          	ld	a5,88(s2)
    8000325e:	577d                	li	a4,-1
    80003260:	fbb8                	sd	a4,112(a5)
  
  // if (p->mask >> num)
  // {
  // 	printf("%d: syscall %s -> %d\n",p->pid, syscallnames[num], p->trapframe->a0);
  // }	
}
    80003262:	70a2                	ld	ra,40(sp)
    80003264:	7402                	ld	s0,32(sp)
    80003266:	64e2                	ld	s1,24(sp)
    80003268:	6942                	ld	s2,16(sp)
    8000326a:	69a2                	ld	s3,8(sp)
    8000326c:	6a02                	ld	s4,0(sp)
    8000326e:	6145                	addi	sp,sp,48
    80003270:	8082                	ret

0000000080003272 <sys_trace>:

int mask;

uint64
sys_trace(void)
{
    80003272:	1141                	addi	sp,sp,-16
    80003274:	e406                	sd	ra,8(sp)
    80003276:	e022                	sd	s0,0(sp)
    80003278:	0800                	addi	s0,sp,16
	if(argint(0, &mask) < 0)
    8000327a:	00006597          	auipc	a1,0x6
    8000327e:	8fa58593          	addi	a1,a1,-1798 # 80008b74 <mask>
    80003282:	4501                	li	a0,0
    80003284:	00000097          	auipc	ra,0x0
    80003288:	e78080e7          	jalr	-392(ra) # 800030fc <argint>
	{
		return -1;
    8000328c:	57fd                	li	a5,-1
	if(argint(0, &mask) < 0)
    8000328e:	00054d63          	bltz	a0,800032a8 <sys_trace+0x36>
	}
	
  myproc()->mask = mask;
    80003292:	ffffe097          	auipc	ra,0xffffe
    80003296:	734080e7          	jalr	1844(ra) # 800019c6 <myproc>
    8000329a:	00006797          	auipc	a5,0x6
    8000329e:	8da7a783          	lw	a5,-1830(a5) # 80008b74 <mask>
    800032a2:	16f52423          	sw	a5,360(a0)
	return 0;
    800032a6:	4781                	li	a5,0
}	/* Modified for A4: Added trace */
    800032a8:	853e                	mv	a0,a5
    800032aa:	60a2                	ld	ra,8(sp)
    800032ac:	6402                	ld	s0,0(sp)
    800032ae:	0141                	addi	sp,sp,16
    800032b0:	8082                	ret

00000000800032b2 <sys_sigalarm>:

/* Modified for A4: Added trace */
uint64 
sys_sigalarm(void)
{
    800032b2:	1101                	addi	sp,sp,-32
    800032b4:	ec06                	sd	ra,24(sp)
    800032b6:	e822                	sd	s0,16(sp)
    800032b8:	1000                	addi	s0,sp,32
  uint64 addr;
  int ticks;
  if(argint(0, &ticks) < 0)
    800032ba:	fe440593          	addi	a1,s0,-28
    800032be:	4501                	li	a0,0
    800032c0:	00000097          	auipc	ra,0x0
    800032c4:	e3c080e7          	jalr	-452(ra) # 800030fc <argint>
    return -1;
    800032c8:	57fd                	li	a5,-1
  if(argint(0, &ticks) < 0)
    800032ca:	04054463          	bltz	a0,80003312 <sys_sigalarm+0x60>
  if(argaddr(1, &addr) < 0)
    800032ce:	fe840593          	addi	a1,s0,-24
    800032d2:	4505                	li	a0,1
    800032d4:	00000097          	auipc	ra,0x0
    800032d8:	e4a080e7          	jalr	-438(ra) # 8000311e <argaddr>
    return -1;
    800032dc:	57fd                	li	a5,-1
  if(argaddr(1, &addr) < 0)
    800032de:	02054a63          	bltz	a0,80003312 <sys_sigalarm+0x60>

  myproc()->ticks = ticks;
    800032e2:	ffffe097          	auipc	ra,0xffffe
    800032e6:	6e4080e7          	jalr	1764(ra) # 800019c6 <myproc>
    800032ea:	fe442783          	lw	a5,-28(s0)
    800032ee:	18f52423          	sw	a5,392(a0)
  myproc()->handler = addr;
    800032f2:	ffffe097          	auipc	ra,0xffffe
    800032f6:	6d4080e7          	jalr	1748(ra) # 800019c6 <myproc>
    800032fa:	fe843783          	ld	a5,-24(s0)
    800032fe:	18f53023          	sd	a5,384(a0)
  myproc()->alarm_on = 1;
    80003302:	ffffe097          	auipc	ra,0xffffe
    80003306:	6c4080e7          	jalr	1732(ra) # 800019c6 <myproc>
    8000330a:	4785                	li	a5,1
    8000330c:	18f52c23          	sw	a5,408(a0)
  //myproc()->a1 = myproc()->trapframe->a0;
  //myproc()->a2 = myproc()->trapframe->a1;

  return 0;
    80003310:	4781                	li	a5,0
}
    80003312:	853e                	mv	a0,a5
    80003314:	60e2                	ld	ra,24(sp)
    80003316:	6442                	ld	s0,16(sp)
    80003318:	6105                	addi	sp,sp,32
    8000331a:	8082                	ret

000000008000331c <sys_sigreturn>:

/* Modified for A4: Added trace */
uint64 
sys_sigreturn(void)
{
    8000331c:	1101                	addi	sp,sp,-32
    8000331e:	ec06                	sd	ra,24(sp)
    80003320:	e822                	sd	s0,16(sp)
    80003322:	e426                	sd	s1,8(sp)
    80003324:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80003326:	ffffe097          	auipc	ra,0xffffe
    8000332a:	6a0080e7          	jalr	1696(ra) # 800019c6 <myproc>
    8000332e:	84aa                	mv	s1,a0
  memmove(p->trapframe, p->alarm_tf, PGSIZE);
    80003330:	6605                	lui	a2,0x1
    80003332:	19053583          	ld	a1,400(a0)
    80003336:	6d28                	ld	a0,88(a0)
    80003338:	ffffe097          	auipc	ra,0xffffe
    8000333c:	a0e080e7          	jalr	-1522(ra) # 80000d46 <memmove>
  //myproc()->trapframe->a0 = myproc()->a1;
  //myproc()->trapframe->a1 = myproc()->a2;
  kfree(p->alarm_tf);
    80003340:	1904b503          	ld	a0,400(s1)
    80003344:	ffffd097          	auipc	ra,0xffffd
    80003348:	6ba080e7          	jalr	1722(ra) # 800009fe <kfree>
  p->cur_ticks = 0;
    8000334c:	1804a623          	sw	zero,396(s1)
  p->handlerpermission = 1;
    80003350:	4785                	li	a5,1
    80003352:	1af4a823          	sw	a5,432(s1)
  return myproc()->trapframe->a0;
    80003356:	ffffe097          	auipc	ra,0xffffe
    8000335a:	670080e7          	jalr	1648(ra) # 800019c6 <myproc>
    8000335e:	6d3c                	ld	a5,88(a0)
}
    80003360:	7ba8                	ld	a0,112(a5)
    80003362:	60e2                	ld	ra,24(sp)
    80003364:	6442                	ld	s0,16(sp)
    80003366:	64a2                	ld	s1,8(sp)
    80003368:	6105                	addi	sp,sp,32
    8000336a:	8082                	ret

000000008000336c <sys_settickets>:

uint64 
sys_settickets(void)
{
    8000336c:	7179                	addi	sp,sp,-48
    8000336e:	f406                	sd	ra,40(sp)
    80003370:	f022                	sd	s0,32(sp)
    80003372:	ec26                	sd	s1,24(sp)
    80003374:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80003376:	ffffe097          	auipc	ra,0xffffe
    8000337a:	650080e7          	jalr	1616(ra) # 800019c6 <myproc>
    8000337e:	84aa                	mv	s1,a0
  int tickets;
  if(argint(0, &tickets) < 0)
    80003380:	fdc40593          	addi	a1,s0,-36
    80003384:	4501                	li	a0,0
    80003386:	00000097          	auipc	ra,0x0
    8000338a:	d76080e7          	jalr	-650(ra) # 800030fc <argint>
    8000338e:	00054c63          	bltz	a0,800033a6 <sys_settickets+0x3a>
    return -1;
  p->tickets = tickets;
    80003392:	fdc42783          	lw	a5,-36(s0)
    80003396:	1af4aa23          	sw	a5,436(s1)
  return 0; 
    8000339a:	4501                	li	a0,0
}
    8000339c:	70a2                	ld	ra,40(sp)
    8000339e:	7402                	ld	s0,32(sp)
    800033a0:	64e2                	ld	s1,24(sp)
    800033a2:	6145                	addi	sp,sp,48
    800033a4:	8082                	ret
    return -1;
    800033a6:	557d                	li	a0,-1
    800033a8:	bfd5                	j	8000339c <sys_settickets+0x30>

00000000800033aa <sys_setpriority>:

uint64
sys_setpriority()
{
    800033aa:	1101                	addi	sp,sp,-32
    800033ac:	ec06                	sd	ra,24(sp)
    800033ae:	e822                	sd	s0,16(sp)
    800033b0:	1000                	addi	s0,sp,32
  int pid, priority;
  int arg_num[2] = {0, 1};

  if(argint(arg_num[0], &priority) < 0)
    800033b2:	fe840593          	addi	a1,s0,-24
    800033b6:	4501                	li	a0,0
    800033b8:	00000097          	auipc	ra,0x0
    800033bc:	d44080e7          	jalr	-700(ra) # 800030fc <argint>
  {
    return -1;
    800033c0:	57fd                	li	a5,-1
  if(argint(arg_num[0], &priority) < 0)
    800033c2:	02054563          	bltz	a0,800033ec <sys_setpriority+0x42>
  }
  if(argint(arg_num[1], &pid) < 0)
    800033c6:	fec40593          	addi	a1,s0,-20
    800033ca:	4505                	li	a0,1
    800033cc:	00000097          	auipc	ra,0x0
    800033d0:	d30080e7          	jalr	-720(ra) # 800030fc <argint>
  {
    return -1;
    800033d4:	57fd                	li	a5,-1
  if(argint(arg_num[1], &pid) < 0)
    800033d6:	00054b63          	bltz	a0,800033ec <sys_setpriority+0x42>
  }
   
  return setpriority(priority, pid);
    800033da:	fec42583          	lw	a1,-20(s0)
    800033de:	fe842503          	lw	a0,-24(s0)
    800033e2:	fffff097          	auipc	ra,0xfffff
    800033e6:	72e080e7          	jalr	1838(ra) # 80002b10 <setpriority>
    800033ea:	87aa                	mv	a5,a0
}
    800033ec:	853e                	mv	a0,a5
    800033ee:	60e2                	ld	ra,24(sp)
    800033f0:	6442                	ld	s0,16(sp)
    800033f2:	6105                	addi	sp,sp,32
    800033f4:	8082                	ret

00000000800033f6 <sys_exit>:


uint64
sys_exit(void)
{
    800033f6:	1101                	addi	sp,sp,-32
    800033f8:	ec06                	sd	ra,24(sp)
    800033fa:	e822                	sd	s0,16(sp)
    800033fc:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800033fe:	fec40593          	addi	a1,s0,-20
    80003402:	4501                	li	a0,0
    80003404:	00000097          	auipc	ra,0x0
    80003408:	cf8080e7          	jalr	-776(ra) # 800030fc <argint>
  exit(n);
    8000340c:	fec42503          	lw	a0,-20(s0)
    80003410:	fffff097          	auipc	ra,0xfffff
    80003414:	28a080e7          	jalr	650(ra) # 8000269a <exit>
  return 0;  // not reached
}
    80003418:	4501                	li	a0,0
    8000341a:	60e2                	ld	ra,24(sp)
    8000341c:	6442                	ld	s0,16(sp)
    8000341e:	6105                	addi	sp,sp,32
    80003420:	8082                	ret

0000000080003422 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003422:	1141                	addi	sp,sp,-16
    80003424:	e406                	sd	ra,8(sp)
    80003426:	e022                	sd	s0,0(sp)
    80003428:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000342a:	ffffe097          	auipc	ra,0xffffe
    8000342e:	59c080e7          	jalr	1436(ra) # 800019c6 <myproc>
}
    80003432:	5908                	lw	a0,48(a0)
    80003434:	60a2                	ld	ra,8(sp)
    80003436:	6402                	ld	s0,0(sp)
    80003438:	0141                	addi	sp,sp,16
    8000343a:	8082                	ret

000000008000343c <sys_fork>:

uint64
sys_fork(void)
{
    8000343c:	1141                	addi	sp,sp,-16
    8000343e:	e406                	sd	ra,8(sp)
    80003440:	e022                	sd	s0,0(sp)
    80003442:	0800                	addi	s0,sp,16
  return fork();
    80003444:	fffff097          	auipc	ra,0xfffff
    80003448:	9ae080e7          	jalr	-1618(ra) # 80001df2 <fork>
}
    8000344c:	60a2                	ld	ra,8(sp)
    8000344e:	6402                	ld	s0,0(sp)
    80003450:	0141                	addi	sp,sp,16
    80003452:	8082                	ret

0000000080003454 <sys_wait>:

uint64
sys_wait(void)
{
    80003454:	1101                	addi	sp,sp,-32
    80003456:	ec06                	sd	ra,24(sp)
    80003458:	e822                	sd	s0,16(sp)
    8000345a:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    8000345c:	fe840593          	addi	a1,s0,-24
    80003460:	4501                	li	a0,0
    80003462:	00000097          	auipc	ra,0x0
    80003466:	cbc080e7          	jalr	-836(ra) # 8000311e <argaddr>
  return wait(p);
    8000346a:	fe843503          	ld	a0,-24(s0)
    8000346e:	fffff097          	auipc	ra,0xfffff
    80003472:	3de080e7          	jalr	990(ra) # 8000284c <wait>
}
    80003476:	60e2                	ld	ra,24(sp)
    80003478:	6442                	ld	s0,16(sp)
    8000347a:	6105                	addi	sp,sp,32
    8000347c:	8082                	ret

000000008000347e <sys_waitx>:

uint64
sys_waitx(void)
{
    8000347e:	7139                	addi	sp,sp,-64
    80003480:	fc06                	sd	ra,56(sp)
    80003482:	f822                	sd	s0,48(sp)
    80003484:	f426                	sd	s1,40(sp)
    80003486:	f04a                	sd	s2,32(sp)
    80003488:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    8000348a:	fd840593          	addi	a1,s0,-40
    8000348e:	4501                	li	a0,0
    80003490:	00000097          	auipc	ra,0x0
    80003494:	c8e080e7          	jalr	-882(ra) # 8000311e <argaddr>
  argaddr(1, &addr1); // user virtual memory
    80003498:	fd040593          	addi	a1,s0,-48
    8000349c:	4505                	li	a0,1
    8000349e:	00000097          	auipc	ra,0x0
    800034a2:	c80080e7          	jalr	-896(ra) # 8000311e <argaddr>
  argaddr(2, &addr2);
    800034a6:	fc840593          	addi	a1,s0,-56
    800034aa:	4509                	li	a0,2
    800034ac:	00000097          	auipc	ra,0x0
    800034b0:	c72080e7          	jalr	-910(ra) # 8000311e <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    800034b4:	fc040613          	addi	a2,s0,-64
    800034b8:	fc440593          	addi	a1,s0,-60
    800034bc:	fd843503          	ld	a0,-40(s0)
    800034c0:	fffff097          	auipc	ra,0xfffff
    800034c4:	fbe080e7          	jalr	-66(ra) # 8000247e <waitx>
    800034c8:	892a                	mv	s2,a0
  struct proc* p = myproc();
    800034ca:	ffffe097          	auipc	ra,0xffffe
    800034ce:	4fc080e7          	jalr	1276(ra) # 800019c6 <myproc>
    800034d2:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    800034d4:	4691                	li	a3,4
    800034d6:	fc440613          	addi	a2,s0,-60
    800034da:	fd043583          	ld	a1,-48(s0)
    800034de:	6928                	ld	a0,80(a0)
    800034e0:	ffffe097          	auipc	ra,0xffffe
    800034e4:	1a4080e7          	jalr	420(ra) # 80001684 <copyout>
    return -1;
    800034e8:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    800034ea:	00054f63          	bltz	a0,80003508 <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2,(char*)&rtime, sizeof(int)) < 0)
    800034ee:	4691                	li	a3,4
    800034f0:	fc040613          	addi	a2,s0,-64
    800034f4:	fc843583          	ld	a1,-56(s0)
    800034f8:	68a8                	ld	a0,80(s1)
    800034fa:	ffffe097          	auipc	ra,0xffffe
    800034fe:	18a080e7          	jalr	394(ra) # 80001684 <copyout>
    80003502:	00054a63          	bltz	a0,80003516 <sys_waitx+0x98>
    return -1;
  return ret;
    80003506:	87ca                	mv	a5,s2
}
    80003508:	853e                	mv	a0,a5
    8000350a:	70e2                	ld	ra,56(sp)
    8000350c:	7442                	ld	s0,48(sp)
    8000350e:	74a2                	ld	s1,40(sp)
    80003510:	7902                	ld	s2,32(sp)
    80003512:	6121                	addi	sp,sp,64
    80003514:	8082                	ret
    return -1;
    80003516:	57fd                	li	a5,-1
    80003518:	bfc5                	j	80003508 <sys_waitx+0x8a>

000000008000351a <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000351a:	7179                	addi	sp,sp,-48
    8000351c:	f406                	sd	ra,40(sp)
    8000351e:	f022                	sd	s0,32(sp)
    80003520:	ec26                	sd	s1,24(sp)
    80003522:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80003524:	fdc40593          	addi	a1,s0,-36
    80003528:	4501                	li	a0,0
    8000352a:	00000097          	auipc	ra,0x0
    8000352e:	bd2080e7          	jalr	-1070(ra) # 800030fc <argint>
  addr = myproc()->sz;
    80003532:	ffffe097          	auipc	ra,0xffffe
    80003536:	494080e7          	jalr	1172(ra) # 800019c6 <myproc>
    8000353a:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    8000353c:	fdc42503          	lw	a0,-36(s0)
    80003540:	fffff097          	auipc	ra,0xfffff
    80003544:	856080e7          	jalr	-1962(ra) # 80001d96 <growproc>
    80003548:	00054863          	bltz	a0,80003558 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    8000354c:	8526                	mv	a0,s1
    8000354e:	70a2                	ld	ra,40(sp)
    80003550:	7402                	ld	s0,32(sp)
    80003552:	64e2                	ld	s1,24(sp)
    80003554:	6145                	addi	sp,sp,48
    80003556:	8082                	ret
    return -1;
    80003558:	54fd                	li	s1,-1
    8000355a:	bfcd                	j	8000354c <sys_sbrk+0x32>

000000008000355c <sys_sleep>:

uint64
sys_sleep(void)
{
    8000355c:	7139                	addi	sp,sp,-64
    8000355e:	fc06                	sd	ra,56(sp)
    80003560:	f822                	sd	s0,48(sp)
    80003562:	f426                	sd	s1,40(sp)
    80003564:	f04a                	sd	s2,32(sp)
    80003566:	ec4e                	sd	s3,24(sp)
    80003568:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    8000356a:	fcc40593          	addi	a1,s0,-52
    8000356e:	4501                	li	a0,0
    80003570:	00000097          	auipc	ra,0x0
    80003574:	b8c080e7          	jalr	-1140(ra) # 800030fc <argint>
  acquire(&tickslock);
    80003578:	00016517          	auipc	a0,0x16
    8000357c:	8c850513          	addi	a0,a0,-1848 # 80018e40 <tickslock>
    80003580:	ffffd097          	auipc	ra,0xffffd
    80003584:	66a080e7          	jalr	1642(ra) # 80000bea <acquire>
  ticks0 = ticks;
    80003588:	00005917          	auipc	s2,0x5
    8000358c:	5e892903          	lw	s2,1512(s2) # 80008b70 <ticks>
  while(ticks - ticks0 < n){
    80003590:	fcc42783          	lw	a5,-52(s0)
    80003594:	cf9d                	beqz	a5,800035d2 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003596:	00016997          	auipc	s3,0x16
    8000359a:	8aa98993          	addi	s3,s3,-1878 # 80018e40 <tickslock>
    8000359e:	00005497          	auipc	s1,0x5
    800035a2:	5d248493          	addi	s1,s1,1490 # 80008b70 <ticks>
    if(killed(myproc())){
    800035a6:	ffffe097          	auipc	ra,0xffffe
    800035aa:	420080e7          	jalr	1056(ra) # 800019c6 <myproc>
    800035ae:	fffff097          	auipc	ra,0xfffff
    800035b2:	26c080e7          	jalr	620(ra) # 8000281a <killed>
    800035b6:	ed15                	bnez	a0,800035f2 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    800035b8:	85ce                	mv	a1,s3
    800035ba:	8526                	mv	a0,s1
    800035bc:	fffff097          	auipc	ra,0xfffff
    800035c0:	e5e080e7          	jalr	-418(ra) # 8000241a <sleep>
  while(ticks - ticks0 < n){
    800035c4:	409c                	lw	a5,0(s1)
    800035c6:	412787bb          	subw	a5,a5,s2
    800035ca:	fcc42703          	lw	a4,-52(s0)
    800035ce:	fce7ece3          	bltu	a5,a4,800035a6 <sys_sleep+0x4a>
  }
  release(&tickslock);
    800035d2:	00016517          	auipc	a0,0x16
    800035d6:	86e50513          	addi	a0,a0,-1938 # 80018e40 <tickslock>
    800035da:	ffffd097          	auipc	ra,0xffffd
    800035de:	6c4080e7          	jalr	1732(ra) # 80000c9e <release>
  return 0;
    800035e2:	4501                	li	a0,0
}
    800035e4:	70e2                	ld	ra,56(sp)
    800035e6:	7442                	ld	s0,48(sp)
    800035e8:	74a2                	ld	s1,40(sp)
    800035ea:	7902                	ld	s2,32(sp)
    800035ec:	69e2                	ld	s3,24(sp)
    800035ee:	6121                	addi	sp,sp,64
    800035f0:	8082                	ret
      release(&tickslock);
    800035f2:	00016517          	auipc	a0,0x16
    800035f6:	84e50513          	addi	a0,a0,-1970 # 80018e40 <tickslock>
    800035fa:	ffffd097          	auipc	ra,0xffffd
    800035fe:	6a4080e7          	jalr	1700(ra) # 80000c9e <release>
      return -1;
    80003602:	557d                	li	a0,-1
    80003604:	b7c5                	j	800035e4 <sys_sleep+0x88>

0000000080003606 <sys_kill>:

uint64
sys_kill(void)
{
    80003606:	1101                	addi	sp,sp,-32
    80003608:	ec06                	sd	ra,24(sp)
    8000360a:	e822                	sd	s0,16(sp)
    8000360c:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    8000360e:	fec40593          	addi	a1,s0,-20
    80003612:	4501                	li	a0,0
    80003614:	00000097          	auipc	ra,0x0
    80003618:	ae8080e7          	jalr	-1304(ra) # 800030fc <argint>
  return kill(pid);
    8000361c:	fec42503          	lw	a0,-20(s0)
    80003620:	fffff097          	auipc	ra,0xfffff
    80003624:	15c080e7          	jalr	348(ra) # 8000277c <kill>
}
    80003628:	60e2                	ld	ra,24(sp)
    8000362a:	6442                	ld	s0,16(sp)
    8000362c:	6105                	addi	sp,sp,32
    8000362e:	8082                	ret

0000000080003630 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003630:	1101                	addi	sp,sp,-32
    80003632:	ec06                	sd	ra,24(sp)
    80003634:	e822                	sd	s0,16(sp)
    80003636:	e426                	sd	s1,8(sp)
    80003638:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000363a:	00016517          	auipc	a0,0x16
    8000363e:	80650513          	addi	a0,a0,-2042 # 80018e40 <tickslock>
    80003642:	ffffd097          	auipc	ra,0xffffd
    80003646:	5a8080e7          	jalr	1448(ra) # 80000bea <acquire>
  xticks = ticks;
    8000364a:	00005497          	auipc	s1,0x5
    8000364e:	5264a483          	lw	s1,1318(s1) # 80008b70 <ticks>
  release(&tickslock);
    80003652:	00015517          	auipc	a0,0x15
    80003656:	7ee50513          	addi	a0,a0,2030 # 80018e40 <tickslock>
    8000365a:	ffffd097          	auipc	ra,0xffffd
    8000365e:	644080e7          	jalr	1604(ra) # 80000c9e <release>
  return xticks;
}
    80003662:	02049513          	slli	a0,s1,0x20
    80003666:	9101                	srli	a0,a0,0x20
    80003668:	60e2                	ld	ra,24(sp)
    8000366a:	6442                	ld	s0,16(sp)
    8000366c:	64a2                	ld	s1,8(sp)
    8000366e:	6105                	addi	sp,sp,32
    80003670:	8082                	ret

0000000080003672 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003672:	7179                	addi	sp,sp,-48
    80003674:	f406                	sd	ra,40(sp)
    80003676:	f022                	sd	s0,32(sp)
    80003678:	ec26                	sd	s1,24(sp)
    8000367a:	e84a                	sd	s2,16(sp)
    8000367c:	e44e                	sd	s3,8(sp)
    8000367e:	e052                	sd	s4,0(sp)
    80003680:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003682:	00005597          	auipc	a1,0x5
    80003686:	05658593          	addi	a1,a1,86 # 800086d8 <syscallnum+0x70>
    8000368a:	00015517          	auipc	a0,0x15
    8000368e:	7ce50513          	addi	a0,a0,1998 # 80018e58 <bcache>
    80003692:	ffffd097          	auipc	ra,0xffffd
    80003696:	4c8080e7          	jalr	1224(ra) # 80000b5a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000369a:	0001d797          	auipc	a5,0x1d
    8000369e:	7be78793          	addi	a5,a5,1982 # 80020e58 <bcache+0x8000>
    800036a2:	0001e717          	auipc	a4,0x1e
    800036a6:	a1e70713          	addi	a4,a4,-1506 # 800210c0 <bcache+0x8268>
    800036aa:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800036ae:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800036b2:	00015497          	auipc	s1,0x15
    800036b6:	7be48493          	addi	s1,s1,1982 # 80018e70 <bcache+0x18>
    b->next = bcache.head.next;
    800036ba:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800036bc:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800036be:	00005a17          	auipc	s4,0x5
    800036c2:	022a0a13          	addi	s4,s4,34 # 800086e0 <syscallnum+0x78>
    b->next = bcache.head.next;
    800036c6:	2b893783          	ld	a5,696(s2)
    800036ca:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800036cc:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800036d0:	85d2                	mv	a1,s4
    800036d2:	01048513          	addi	a0,s1,16
    800036d6:	00001097          	auipc	ra,0x1
    800036da:	4c4080e7          	jalr	1220(ra) # 80004b9a <initsleeplock>
    bcache.head.next->prev = b;
    800036de:	2b893783          	ld	a5,696(s2)
    800036e2:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800036e4:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800036e8:	45848493          	addi	s1,s1,1112
    800036ec:	fd349de3          	bne	s1,s3,800036c6 <binit+0x54>
  }
}
    800036f0:	70a2                	ld	ra,40(sp)
    800036f2:	7402                	ld	s0,32(sp)
    800036f4:	64e2                	ld	s1,24(sp)
    800036f6:	6942                	ld	s2,16(sp)
    800036f8:	69a2                	ld	s3,8(sp)
    800036fa:	6a02                	ld	s4,0(sp)
    800036fc:	6145                	addi	sp,sp,48
    800036fe:	8082                	ret

0000000080003700 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003700:	7179                	addi	sp,sp,-48
    80003702:	f406                	sd	ra,40(sp)
    80003704:	f022                	sd	s0,32(sp)
    80003706:	ec26                	sd	s1,24(sp)
    80003708:	e84a                	sd	s2,16(sp)
    8000370a:	e44e                	sd	s3,8(sp)
    8000370c:	1800                	addi	s0,sp,48
    8000370e:	89aa                	mv	s3,a0
    80003710:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80003712:	00015517          	auipc	a0,0x15
    80003716:	74650513          	addi	a0,a0,1862 # 80018e58 <bcache>
    8000371a:	ffffd097          	auipc	ra,0xffffd
    8000371e:	4d0080e7          	jalr	1232(ra) # 80000bea <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003722:	0001e497          	auipc	s1,0x1e
    80003726:	9ee4b483          	ld	s1,-1554(s1) # 80021110 <bcache+0x82b8>
    8000372a:	0001e797          	auipc	a5,0x1e
    8000372e:	99678793          	addi	a5,a5,-1642 # 800210c0 <bcache+0x8268>
    80003732:	02f48f63          	beq	s1,a5,80003770 <bread+0x70>
    80003736:	873e                	mv	a4,a5
    80003738:	a021                	j	80003740 <bread+0x40>
    8000373a:	68a4                	ld	s1,80(s1)
    8000373c:	02e48a63          	beq	s1,a4,80003770 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003740:	449c                	lw	a5,8(s1)
    80003742:	ff379ce3          	bne	a5,s3,8000373a <bread+0x3a>
    80003746:	44dc                	lw	a5,12(s1)
    80003748:	ff2799e3          	bne	a5,s2,8000373a <bread+0x3a>
      b->refcnt++;
    8000374c:	40bc                	lw	a5,64(s1)
    8000374e:	2785                	addiw	a5,a5,1
    80003750:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003752:	00015517          	auipc	a0,0x15
    80003756:	70650513          	addi	a0,a0,1798 # 80018e58 <bcache>
    8000375a:	ffffd097          	auipc	ra,0xffffd
    8000375e:	544080e7          	jalr	1348(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    80003762:	01048513          	addi	a0,s1,16
    80003766:	00001097          	auipc	ra,0x1
    8000376a:	46e080e7          	jalr	1134(ra) # 80004bd4 <acquiresleep>
      return b;
    8000376e:	a8b9                	j	800037cc <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003770:	0001e497          	auipc	s1,0x1e
    80003774:	9984b483          	ld	s1,-1640(s1) # 80021108 <bcache+0x82b0>
    80003778:	0001e797          	auipc	a5,0x1e
    8000377c:	94878793          	addi	a5,a5,-1720 # 800210c0 <bcache+0x8268>
    80003780:	00f48863          	beq	s1,a5,80003790 <bread+0x90>
    80003784:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003786:	40bc                	lw	a5,64(s1)
    80003788:	cf81                	beqz	a5,800037a0 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000378a:	64a4                	ld	s1,72(s1)
    8000378c:	fee49de3          	bne	s1,a4,80003786 <bread+0x86>
  panic("bget: no buffers");
    80003790:	00005517          	auipc	a0,0x5
    80003794:	f5850513          	addi	a0,a0,-168 # 800086e8 <syscallnum+0x80>
    80003798:	ffffd097          	auipc	ra,0xffffd
    8000379c:	dac080e7          	jalr	-596(ra) # 80000544 <panic>
      b->dev = dev;
    800037a0:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    800037a4:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    800037a8:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800037ac:	4785                	li	a5,1
    800037ae:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800037b0:	00015517          	auipc	a0,0x15
    800037b4:	6a850513          	addi	a0,a0,1704 # 80018e58 <bcache>
    800037b8:	ffffd097          	auipc	ra,0xffffd
    800037bc:	4e6080e7          	jalr	1254(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    800037c0:	01048513          	addi	a0,s1,16
    800037c4:	00001097          	auipc	ra,0x1
    800037c8:	410080e7          	jalr	1040(ra) # 80004bd4 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800037cc:	409c                	lw	a5,0(s1)
    800037ce:	cb89                	beqz	a5,800037e0 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800037d0:	8526                	mv	a0,s1
    800037d2:	70a2                	ld	ra,40(sp)
    800037d4:	7402                	ld	s0,32(sp)
    800037d6:	64e2                	ld	s1,24(sp)
    800037d8:	6942                	ld	s2,16(sp)
    800037da:	69a2                	ld	s3,8(sp)
    800037dc:	6145                	addi	sp,sp,48
    800037de:	8082                	ret
    virtio_disk_rw(b, 0);
    800037e0:	4581                	li	a1,0
    800037e2:	8526                	mv	a0,s1
    800037e4:	00003097          	auipc	ra,0x3
    800037e8:	fc4080e7          	jalr	-60(ra) # 800067a8 <virtio_disk_rw>
    b->valid = 1;
    800037ec:	4785                	li	a5,1
    800037ee:	c09c                	sw	a5,0(s1)
  return b;
    800037f0:	b7c5                	j	800037d0 <bread+0xd0>

00000000800037f2 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800037f2:	1101                	addi	sp,sp,-32
    800037f4:	ec06                	sd	ra,24(sp)
    800037f6:	e822                	sd	s0,16(sp)
    800037f8:	e426                	sd	s1,8(sp)
    800037fa:	1000                	addi	s0,sp,32
    800037fc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800037fe:	0541                	addi	a0,a0,16
    80003800:	00001097          	auipc	ra,0x1
    80003804:	46e080e7          	jalr	1134(ra) # 80004c6e <holdingsleep>
    80003808:	cd01                	beqz	a0,80003820 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000380a:	4585                	li	a1,1
    8000380c:	8526                	mv	a0,s1
    8000380e:	00003097          	auipc	ra,0x3
    80003812:	f9a080e7          	jalr	-102(ra) # 800067a8 <virtio_disk_rw>
}
    80003816:	60e2                	ld	ra,24(sp)
    80003818:	6442                	ld	s0,16(sp)
    8000381a:	64a2                	ld	s1,8(sp)
    8000381c:	6105                	addi	sp,sp,32
    8000381e:	8082                	ret
    panic("bwrite");
    80003820:	00005517          	auipc	a0,0x5
    80003824:	ee050513          	addi	a0,a0,-288 # 80008700 <syscallnum+0x98>
    80003828:	ffffd097          	auipc	ra,0xffffd
    8000382c:	d1c080e7          	jalr	-740(ra) # 80000544 <panic>

0000000080003830 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003830:	1101                	addi	sp,sp,-32
    80003832:	ec06                	sd	ra,24(sp)
    80003834:	e822                	sd	s0,16(sp)
    80003836:	e426                	sd	s1,8(sp)
    80003838:	e04a                	sd	s2,0(sp)
    8000383a:	1000                	addi	s0,sp,32
    8000383c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000383e:	01050913          	addi	s2,a0,16
    80003842:	854a                	mv	a0,s2
    80003844:	00001097          	auipc	ra,0x1
    80003848:	42a080e7          	jalr	1066(ra) # 80004c6e <holdingsleep>
    8000384c:	c92d                	beqz	a0,800038be <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000384e:	854a                	mv	a0,s2
    80003850:	00001097          	auipc	ra,0x1
    80003854:	3da080e7          	jalr	986(ra) # 80004c2a <releasesleep>

  acquire(&bcache.lock);
    80003858:	00015517          	auipc	a0,0x15
    8000385c:	60050513          	addi	a0,a0,1536 # 80018e58 <bcache>
    80003860:	ffffd097          	auipc	ra,0xffffd
    80003864:	38a080e7          	jalr	906(ra) # 80000bea <acquire>
  b->refcnt--;
    80003868:	40bc                	lw	a5,64(s1)
    8000386a:	37fd                	addiw	a5,a5,-1
    8000386c:	0007871b          	sext.w	a4,a5
    80003870:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003872:	eb05                	bnez	a4,800038a2 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003874:	68bc                	ld	a5,80(s1)
    80003876:	64b8                	ld	a4,72(s1)
    80003878:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000387a:	64bc                	ld	a5,72(s1)
    8000387c:	68b8                	ld	a4,80(s1)
    8000387e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003880:	0001d797          	auipc	a5,0x1d
    80003884:	5d878793          	addi	a5,a5,1496 # 80020e58 <bcache+0x8000>
    80003888:	2b87b703          	ld	a4,696(a5)
    8000388c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000388e:	0001e717          	auipc	a4,0x1e
    80003892:	83270713          	addi	a4,a4,-1998 # 800210c0 <bcache+0x8268>
    80003896:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003898:	2b87b703          	ld	a4,696(a5)
    8000389c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000389e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800038a2:	00015517          	auipc	a0,0x15
    800038a6:	5b650513          	addi	a0,a0,1462 # 80018e58 <bcache>
    800038aa:	ffffd097          	auipc	ra,0xffffd
    800038ae:	3f4080e7          	jalr	1012(ra) # 80000c9e <release>
}
    800038b2:	60e2                	ld	ra,24(sp)
    800038b4:	6442                	ld	s0,16(sp)
    800038b6:	64a2                	ld	s1,8(sp)
    800038b8:	6902                	ld	s2,0(sp)
    800038ba:	6105                	addi	sp,sp,32
    800038bc:	8082                	ret
    panic("brelse");
    800038be:	00005517          	auipc	a0,0x5
    800038c2:	e4a50513          	addi	a0,a0,-438 # 80008708 <syscallnum+0xa0>
    800038c6:	ffffd097          	auipc	ra,0xffffd
    800038ca:	c7e080e7          	jalr	-898(ra) # 80000544 <panic>

00000000800038ce <bpin>:

void
bpin(struct buf *b) {
    800038ce:	1101                	addi	sp,sp,-32
    800038d0:	ec06                	sd	ra,24(sp)
    800038d2:	e822                	sd	s0,16(sp)
    800038d4:	e426                	sd	s1,8(sp)
    800038d6:	1000                	addi	s0,sp,32
    800038d8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800038da:	00015517          	auipc	a0,0x15
    800038de:	57e50513          	addi	a0,a0,1406 # 80018e58 <bcache>
    800038e2:	ffffd097          	auipc	ra,0xffffd
    800038e6:	308080e7          	jalr	776(ra) # 80000bea <acquire>
  b->refcnt++;
    800038ea:	40bc                	lw	a5,64(s1)
    800038ec:	2785                	addiw	a5,a5,1
    800038ee:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800038f0:	00015517          	auipc	a0,0x15
    800038f4:	56850513          	addi	a0,a0,1384 # 80018e58 <bcache>
    800038f8:	ffffd097          	auipc	ra,0xffffd
    800038fc:	3a6080e7          	jalr	934(ra) # 80000c9e <release>
}
    80003900:	60e2                	ld	ra,24(sp)
    80003902:	6442                	ld	s0,16(sp)
    80003904:	64a2                	ld	s1,8(sp)
    80003906:	6105                	addi	sp,sp,32
    80003908:	8082                	ret

000000008000390a <bunpin>:

void
bunpin(struct buf *b) {
    8000390a:	1101                	addi	sp,sp,-32
    8000390c:	ec06                	sd	ra,24(sp)
    8000390e:	e822                	sd	s0,16(sp)
    80003910:	e426                	sd	s1,8(sp)
    80003912:	1000                	addi	s0,sp,32
    80003914:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003916:	00015517          	auipc	a0,0x15
    8000391a:	54250513          	addi	a0,a0,1346 # 80018e58 <bcache>
    8000391e:	ffffd097          	auipc	ra,0xffffd
    80003922:	2cc080e7          	jalr	716(ra) # 80000bea <acquire>
  b->refcnt--;
    80003926:	40bc                	lw	a5,64(s1)
    80003928:	37fd                	addiw	a5,a5,-1
    8000392a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000392c:	00015517          	auipc	a0,0x15
    80003930:	52c50513          	addi	a0,a0,1324 # 80018e58 <bcache>
    80003934:	ffffd097          	auipc	ra,0xffffd
    80003938:	36a080e7          	jalr	874(ra) # 80000c9e <release>
}
    8000393c:	60e2                	ld	ra,24(sp)
    8000393e:	6442                	ld	s0,16(sp)
    80003940:	64a2                	ld	s1,8(sp)
    80003942:	6105                	addi	sp,sp,32
    80003944:	8082                	ret

0000000080003946 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003946:	1101                	addi	sp,sp,-32
    80003948:	ec06                	sd	ra,24(sp)
    8000394a:	e822                	sd	s0,16(sp)
    8000394c:	e426                	sd	s1,8(sp)
    8000394e:	e04a                	sd	s2,0(sp)
    80003950:	1000                	addi	s0,sp,32
    80003952:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003954:	00d5d59b          	srliw	a1,a1,0xd
    80003958:	0001e797          	auipc	a5,0x1e
    8000395c:	bdc7a783          	lw	a5,-1060(a5) # 80021534 <sb+0x1c>
    80003960:	9dbd                	addw	a1,a1,a5
    80003962:	00000097          	auipc	ra,0x0
    80003966:	d9e080e7          	jalr	-610(ra) # 80003700 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000396a:	0074f713          	andi	a4,s1,7
    8000396e:	4785                	li	a5,1
    80003970:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003974:	14ce                	slli	s1,s1,0x33
    80003976:	90d9                	srli	s1,s1,0x36
    80003978:	00950733          	add	a4,a0,s1
    8000397c:	05874703          	lbu	a4,88(a4)
    80003980:	00e7f6b3          	and	a3,a5,a4
    80003984:	c69d                	beqz	a3,800039b2 <bfree+0x6c>
    80003986:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003988:	94aa                	add	s1,s1,a0
    8000398a:	fff7c793          	not	a5,a5
    8000398e:	8ff9                	and	a5,a5,a4
    80003990:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003994:	00001097          	auipc	ra,0x1
    80003998:	120080e7          	jalr	288(ra) # 80004ab4 <log_write>
  brelse(bp);
    8000399c:	854a                	mv	a0,s2
    8000399e:	00000097          	auipc	ra,0x0
    800039a2:	e92080e7          	jalr	-366(ra) # 80003830 <brelse>
}
    800039a6:	60e2                	ld	ra,24(sp)
    800039a8:	6442                	ld	s0,16(sp)
    800039aa:	64a2                	ld	s1,8(sp)
    800039ac:	6902                	ld	s2,0(sp)
    800039ae:	6105                	addi	sp,sp,32
    800039b0:	8082                	ret
    panic("freeing free block");
    800039b2:	00005517          	auipc	a0,0x5
    800039b6:	d5e50513          	addi	a0,a0,-674 # 80008710 <syscallnum+0xa8>
    800039ba:	ffffd097          	auipc	ra,0xffffd
    800039be:	b8a080e7          	jalr	-1142(ra) # 80000544 <panic>

00000000800039c2 <balloc>:
{
    800039c2:	711d                	addi	sp,sp,-96
    800039c4:	ec86                	sd	ra,88(sp)
    800039c6:	e8a2                	sd	s0,80(sp)
    800039c8:	e4a6                	sd	s1,72(sp)
    800039ca:	e0ca                	sd	s2,64(sp)
    800039cc:	fc4e                	sd	s3,56(sp)
    800039ce:	f852                	sd	s4,48(sp)
    800039d0:	f456                	sd	s5,40(sp)
    800039d2:	f05a                	sd	s6,32(sp)
    800039d4:	ec5e                	sd	s7,24(sp)
    800039d6:	e862                	sd	s8,16(sp)
    800039d8:	e466                	sd	s9,8(sp)
    800039da:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800039dc:	0001e797          	auipc	a5,0x1e
    800039e0:	b407a783          	lw	a5,-1216(a5) # 8002151c <sb+0x4>
    800039e4:	10078163          	beqz	a5,80003ae6 <balloc+0x124>
    800039e8:	8baa                	mv	s7,a0
    800039ea:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800039ec:	0001eb17          	auipc	s6,0x1e
    800039f0:	b2cb0b13          	addi	s6,s6,-1236 # 80021518 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800039f4:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800039f6:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800039f8:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800039fa:	6c89                	lui	s9,0x2
    800039fc:	a061                	j	80003a84 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    800039fe:	974a                	add	a4,a4,s2
    80003a00:	8fd5                	or	a5,a5,a3
    80003a02:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003a06:	854a                	mv	a0,s2
    80003a08:	00001097          	auipc	ra,0x1
    80003a0c:	0ac080e7          	jalr	172(ra) # 80004ab4 <log_write>
        brelse(bp);
    80003a10:	854a                	mv	a0,s2
    80003a12:	00000097          	auipc	ra,0x0
    80003a16:	e1e080e7          	jalr	-482(ra) # 80003830 <brelse>
  bp = bread(dev, bno);
    80003a1a:	85a6                	mv	a1,s1
    80003a1c:	855e                	mv	a0,s7
    80003a1e:	00000097          	auipc	ra,0x0
    80003a22:	ce2080e7          	jalr	-798(ra) # 80003700 <bread>
    80003a26:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003a28:	40000613          	li	a2,1024
    80003a2c:	4581                	li	a1,0
    80003a2e:	05850513          	addi	a0,a0,88
    80003a32:	ffffd097          	auipc	ra,0xffffd
    80003a36:	2b4080e7          	jalr	692(ra) # 80000ce6 <memset>
  log_write(bp);
    80003a3a:	854a                	mv	a0,s2
    80003a3c:	00001097          	auipc	ra,0x1
    80003a40:	078080e7          	jalr	120(ra) # 80004ab4 <log_write>
  brelse(bp);
    80003a44:	854a                	mv	a0,s2
    80003a46:	00000097          	auipc	ra,0x0
    80003a4a:	dea080e7          	jalr	-534(ra) # 80003830 <brelse>
}
    80003a4e:	8526                	mv	a0,s1
    80003a50:	60e6                	ld	ra,88(sp)
    80003a52:	6446                	ld	s0,80(sp)
    80003a54:	64a6                	ld	s1,72(sp)
    80003a56:	6906                	ld	s2,64(sp)
    80003a58:	79e2                	ld	s3,56(sp)
    80003a5a:	7a42                	ld	s4,48(sp)
    80003a5c:	7aa2                	ld	s5,40(sp)
    80003a5e:	7b02                	ld	s6,32(sp)
    80003a60:	6be2                	ld	s7,24(sp)
    80003a62:	6c42                	ld	s8,16(sp)
    80003a64:	6ca2                	ld	s9,8(sp)
    80003a66:	6125                	addi	sp,sp,96
    80003a68:	8082                	ret
    brelse(bp);
    80003a6a:	854a                	mv	a0,s2
    80003a6c:	00000097          	auipc	ra,0x0
    80003a70:	dc4080e7          	jalr	-572(ra) # 80003830 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003a74:	015c87bb          	addw	a5,s9,s5
    80003a78:	00078a9b          	sext.w	s5,a5
    80003a7c:	004b2703          	lw	a4,4(s6)
    80003a80:	06eaf363          	bgeu	s5,a4,80003ae6 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003a84:	41fad79b          	sraiw	a5,s5,0x1f
    80003a88:	0137d79b          	srliw	a5,a5,0x13
    80003a8c:	015787bb          	addw	a5,a5,s5
    80003a90:	40d7d79b          	sraiw	a5,a5,0xd
    80003a94:	01cb2583          	lw	a1,28(s6)
    80003a98:	9dbd                	addw	a1,a1,a5
    80003a9a:	855e                	mv	a0,s7
    80003a9c:	00000097          	auipc	ra,0x0
    80003aa0:	c64080e7          	jalr	-924(ra) # 80003700 <bread>
    80003aa4:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003aa6:	004b2503          	lw	a0,4(s6)
    80003aaa:	000a849b          	sext.w	s1,s5
    80003aae:	8662                	mv	a2,s8
    80003ab0:	faa4fde3          	bgeu	s1,a0,80003a6a <balloc+0xa8>
      m = 1 << (bi % 8);
    80003ab4:	41f6579b          	sraiw	a5,a2,0x1f
    80003ab8:	01d7d69b          	srliw	a3,a5,0x1d
    80003abc:	00c6873b          	addw	a4,a3,a2
    80003ac0:	00777793          	andi	a5,a4,7
    80003ac4:	9f95                	subw	a5,a5,a3
    80003ac6:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003aca:	4037571b          	sraiw	a4,a4,0x3
    80003ace:	00e906b3          	add	a3,s2,a4
    80003ad2:	0586c683          	lbu	a3,88(a3)
    80003ad6:	00d7f5b3          	and	a1,a5,a3
    80003ada:	d195                	beqz	a1,800039fe <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003adc:	2605                	addiw	a2,a2,1
    80003ade:	2485                	addiw	s1,s1,1
    80003ae0:	fd4618e3          	bne	a2,s4,80003ab0 <balloc+0xee>
    80003ae4:	b759                	j	80003a6a <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003ae6:	00005517          	auipc	a0,0x5
    80003aea:	c4250513          	addi	a0,a0,-958 # 80008728 <syscallnum+0xc0>
    80003aee:	ffffd097          	auipc	ra,0xffffd
    80003af2:	aa0080e7          	jalr	-1376(ra) # 8000058e <printf>
  return 0;
    80003af6:	4481                	li	s1,0
    80003af8:	bf99                	j	80003a4e <balloc+0x8c>

0000000080003afa <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003afa:	7179                	addi	sp,sp,-48
    80003afc:	f406                	sd	ra,40(sp)
    80003afe:	f022                	sd	s0,32(sp)
    80003b00:	ec26                	sd	s1,24(sp)
    80003b02:	e84a                	sd	s2,16(sp)
    80003b04:	e44e                	sd	s3,8(sp)
    80003b06:	e052                	sd	s4,0(sp)
    80003b08:	1800                	addi	s0,sp,48
    80003b0a:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003b0c:	47ad                	li	a5,11
    80003b0e:	02b7e763          	bltu	a5,a1,80003b3c <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003b12:	02059493          	slli	s1,a1,0x20
    80003b16:	9081                	srli	s1,s1,0x20
    80003b18:	048a                	slli	s1,s1,0x2
    80003b1a:	94aa                	add	s1,s1,a0
    80003b1c:	0504a903          	lw	s2,80(s1)
    80003b20:	06091e63          	bnez	s2,80003b9c <bmap+0xa2>
      addr = balloc(ip->dev);
    80003b24:	4108                	lw	a0,0(a0)
    80003b26:	00000097          	auipc	ra,0x0
    80003b2a:	e9c080e7          	jalr	-356(ra) # 800039c2 <balloc>
    80003b2e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003b32:	06090563          	beqz	s2,80003b9c <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003b36:	0524a823          	sw	s2,80(s1)
    80003b3a:	a08d                	j	80003b9c <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003b3c:	ff45849b          	addiw	s1,a1,-12
    80003b40:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003b44:	0ff00793          	li	a5,255
    80003b48:	08e7e563          	bltu	a5,a4,80003bd2 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003b4c:	08052903          	lw	s2,128(a0)
    80003b50:	00091d63          	bnez	s2,80003b6a <bmap+0x70>
      addr = balloc(ip->dev);
    80003b54:	4108                	lw	a0,0(a0)
    80003b56:	00000097          	auipc	ra,0x0
    80003b5a:	e6c080e7          	jalr	-404(ra) # 800039c2 <balloc>
    80003b5e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003b62:	02090d63          	beqz	s2,80003b9c <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003b66:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003b6a:	85ca                	mv	a1,s2
    80003b6c:	0009a503          	lw	a0,0(s3)
    80003b70:	00000097          	auipc	ra,0x0
    80003b74:	b90080e7          	jalr	-1136(ra) # 80003700 <bread>
    80003b78:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003b7a:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003b7e:	02049593          	slli	a1,s1,0x20
    80003b82:	9181                	srli	a1,a1,0x20
    80003b84:	058a                	slli	a1,a1,0x2
    80003b86:	00b784b3          	add	s1,a5,a1
    80003b8a:	0004a903          	lw	s2,0(s1)
    80003b8e:	02090063          	beqz	s2,80003bae <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003b92:	8552                	mv	a0,s4
    80003b94:	00000097          	auipc	ra,0x0
    80003b98:	c9c080e7          	jalr	-868(ra) # 80003830 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003b9c:	854a                	mv	a0,s2
    80003b9e:	70a2                	ld	ra,40(sp)
    80003ba0:	7402                	ld	s0,32(sp)
    80003ba2:	64e2                	ld	s1,24(sp)
    80003ba4:	6942                	ld	s2,16(sp)
    80003ba6:	69a2                	ld	s3,8(sp)
    80003ba8:	6a02                	ld	s4,0(sp)
    80003baa:	6145                	addi	sp,sp,48
    80003bac:	8082                	ret
      addr = balloc(ip->dev);
    80003bae:	0009a503          	lw	a0,0(s3)
    80003bb2:	00000097          	auipc	ra,0x0
    80003bb6:	e10080e7          	jalr	-496(ra) # 800039c2 <balloc>
    80003bba:	0005091b          	sext.w	s2,a0
      if(addr){
    80003bbe:	fc090ae3          	beqz	s2,80003b92 <bmap+0x98>
        a[bn] = addr;
    80003bc2:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003bc6:	8552                	mv	a0,s4
    80003bc8:	00001097          	auipc	ra,0x1
    80003bcc:	eec080e7          	jalr	-276(ra) # 80004ab4 <log_write>
    80003bd0:	b7c9                	j	80003b92 <bmap+0x98>
  panic("bmap: out of range");
    80003bd2:	00005517          	auipc	a0,0x5
    80003bd6:	b6e50513          	addi	a0,a0,-1170 # 80008740 <syscallnum+0xd8>
    80003bda:	ffffd097          	auipc	ra,0xffffd
    80003bde:	96a080e7          	jalr	-1686(ra) # 80000544 <panic>

0000000080003be2 <iget>:
{
    80003be2:	7179                	addi	sp,sp,-48
    80003be4:	f406                	sd	ra,40(sp)
    80003be6:	f022                	sd	s0,32(sp)
    80003be8:	ec26                	sd	s1,24(sp)
    80003bea:	e84a                	sd	s2,16(sp)
    80003bec:	e44e                	sd	s3,8(sp)
    80003bee:	e052                	sd	s4,0(sp)
    80003bf0:	1800                	addi	s0,sp,48
    80003bf2:	89aa                	mv	s3,a0
    80003bf4:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003bf6:	0001e517          	auipc	a0,0x1e
    80003bfa:	94250513          	addi	a0,a0,-1726 # 80021538 <itable>
    80003bfe:	ffffd097          	auipc	ra,0xffffd
    80003c02:	fec080e7          	jalr	-20(ra) # 80000bea <acquire>
  empty = 0;
    80003c06:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003c08:	0001e497          	auipc	s1,0x1e
    80003c0c:	94848493          	addi	s1,s1,-1720 # 80021550 <itable+0x18>
    80003c10:	0001f697          	auipc	a3,0x1f
    80003c14:	3d068693          	addi	a3,a3,976 # 80022fe0 <log>
    80003c18:	a039                	j	80003c26 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003c1a:	02090b63          	beqz	s2,80003c50 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003c1e:	08848493          	addi	s1,s1,136
    80003c22:	02d48a63          	beq	s1,a3,80003c56 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003c26:	449c                	lw	a5,8(s1)
    80003c28:	fef059e3          	blez	a5,80003c1a <iget+0x38>
    80003c2c:	4098                	lw	a4,0(s1)
    80003c2e:	ff3716e3          	bne	a4,s3,80003c1a <iget+0x38>
    80003c32:	40d8                	lw	a4,4(s1)
    80003c34:	ff4713e3          	bne	a4,s4,80003c1a <iget+0x38>
      ip->ref++;
    80003c38:	2785                	addiw	a5,a5,1
    80003c3a:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003c3c:	0001e517          	auipc	a0,0x1e
    80003c40:	8fc50513          	addi	a0,a0,-1796 # 80021538 <itable>
    80003c44:	ffffd097          	auipc	ra,0xffffd
    80003c48:	05a080e7          	jalr	90(ra) # 80000c9e <release>
      return ip;
    80003c4c:	8926                	mv	s2,s1
    80003c4e:	a03d                	j	80003c7c <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003c50:	f7f9                	bnez	a5,80003c1e <iget+0x3c>
    80003c52:	8926                	mv	s2,s1
    80003c54:	b7e9                	j	80003c1e <iget+0x3c>
  if(empty == 0)
    80003c56:	02090c63          	beqz	s2,80003c8e <iget+0xac>
  ip->dev = dev;
    80003c5a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003c5e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003c62:	4785                	li	a5,1
    80003c64:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003c68:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003c6c:	0001e517          	auipc	a0,0x1e
    80003c70:	8cc50513          	addi	a0,a0,-1844 # 80021538 <itable>
    80003c74:	ffffd097          	auipc	ra,0xffffd
    80003c78:	02a080e7          	jalr	42(ra) # 80000c9e <release>
}
    80003c7c:	854a                	mv	a0,s2
    80003c7e:	70a2                	ld	ra,40(sp)
    80003c80:	7402                	ld	s0,32(sp)
    80003c82:	64e2                	ld	s1,24(sp)
    80003c84:	6942                	ld	s2,16(sp)
    80003c86:	69a2                	ld	s3,8(sp)
    80003c88:	6a02                	ld	s4,0(sp)
    80003c8a:	6145                	addi	sp,sp,48
    80003c8c:	8082                	ret
    panic("iget: no inodes");
    80003c8e:	00005517          	auipc	a0,0x5
    80003c92:	aca50513          	addi	a0,a0,-1334 # 80008758 <syscallnum+0xf0>
    80003c96:	ffffd097          	auipc	ra,0xffffd
    80003c9a:	8ae080e7          	jalr	-1874(ra) # 80000544 <panic>

0000000080003c9e <fsinit>:
fsinit(int dev) {
    80003c9e:	7179                	addi	sp,sp,-48
    80003ca0:	f406                	sd	ra,40(sp)
    80003ca2:	f022                	sd	s0,32(sp)
    80003ca4:	ec26                	sd	s1,24(sp)
    80003ca6:	e84a                	sd	s2,16(sp)
    80003ca8:	e44e                	sd	s3,8(sp)
    80003caa:	1800                	addi	s0,sp,48
    80003cac:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003cae:	4585                	li	a1,1
    80003cb0:	00000097          	auipc	ra,0x0
    80003cb4:	a50080e7          	jalr	-1456(ra) # 80003700 <bread>
    80003cb8:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003cba:	0001e997          	auipc	s3,0x1e
    80003cbe:	85e98993          	addi	s3,s3,-1954 # 80021518 <sb>
    80003cc2:	02000613          	li	a2,32
    80003cc6:	05850593          	addi	a1,a0,88
    80003cca:	854e                	mv	a0,s3
    80003ccc:	ffffd097          	auipc	ra,0xffffd
    80003cd0:	07a080e7          	jalr	122(ra) # 80000d46 <memmove>
  brelse(bp);
    80003cd4:	8526                	mv	a0,s1
    80003cd6:	00000097          	auipc	ra,0x0
    80003cda:	b5a080e7          	jalr	-1190(ra) # 80003830 <brelse>
  if(sb.magic != FSMAGIC)
    80003cde:	0009a703          	lw	a4,0(s3)
    80003ce2:	102037b7          	lui	a5,0x10203
    80003ce6:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003cea:	02f71263          	bne	a4,a5,80003d0e <fsinit+0x70>
  initlog(dev, &sb);
    80003cee:	0001e597          	auipc	a1,0x1e
    80003cf2:	82a58593          	addi	a1,a1,-2006 # 80021518 <sb>
    80003cf6:	854a                	mv	a0,s2
    80003cf8:	00001097          	auipc	ra,0x1
    80003cfc:	b40080e7          	jalr	-1216(ra) # 80004838 <initlog>
}
    80003d00:	70a2                	ld	ra,40(sp)
    80003d02:	7402                	ld	s0,32(sp)
    80003d04:	64e2                	ld	s1,24(sp)
    80003d06:	6942                	ld	s2,16(sp)
    80003d08:	69a2                	ld	s3,8(sp)
    80003d0a:	6145                	addi	sp,sp,48
    80003d0c:	8082                	ret
    panic("invalid file system");
    80003d0e:	00005517          	auipc	a0,0x5
    80003d12:	a5a50513          	addi	a0,a0,-1446 # 80008768 <syscallnum+0x100>
    80003d16:	ffffd097          	auipc	ra,0xffffd
    80003d1a:	82e080e7          	jalr	-2002(ra) # 80000544 <panic>

0000000080003d1e <iinit>:
{
    80003d1e:	7179                	addi	sp,sp,-48
    80003d20:	f406                	sd	ra,40(sp)
    80003d22:	f022                	sd	s0,32(sp)
    80003d24:	ec26                	sd	s1,24(sp)
    80003d26:	e84a                	sd	s2,16(sp)
    80003d28:	e44e                	sd	s3,8(sp)
    80003d2a:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003d2c:	00005597          	auipc	a1,0x5
    80003d30:	a5458593          	addi	a1,a1,-1452 # 80008780 <syscallnum+0x118>
    80003d34:	0001e517          	auipc	a0,0x1e
    80003d38:	80450513          	addi	a0,a0,-2044 # 80021538 <itable>
    80003d3c:	ffffd097          	auipc	ra,0xffffd
    80003d40:	e1e080e7          	jalr	-482(ra) # 80000b5a <initlock>
  for(i = 0; i < NINODE; i++) {
    80003d44:	0001e497          	auipc	s1,0x1e
    80003d48:	81c48493          	addi	s1,s1,-2020 # 80021560 <itable+0x28>
    80003d4c:	0001f997          	auipc	s3,0x1f
    80003d50:	2a498993          	addi	s3,s3,676 # 80022ff0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003d54:	00005917          	auipc	s2,0x5
    80003d58:	a3490913          	addi	s2,s2,-1484 # 80008788 <syscallnum+0x120>
    80003d5c:	85ca                	mv	a1,s2
    80003d5e:	8526                	mv	a0,s1
    80003d60:	00001097          	auipc	ra,0x1
    80003d64:	e3a080e7          	jalr	-454(ra) # 80004b9a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003d68:	08848493          	addi	s1,s1,136
    80003d6c:	ff3498e3          	bne	s1,s3,80003d5c <iinit+0x3e>
}
    80003d70:	70a2                	ld	ra,40(sp)
    80003d72:	7402                	ld	s0,32(sp)
    80003d74:	64e2                	ld	s1,24(sp)
    80003d76:	6942                	ld	s2,16(sp)
    80003d78:	69a2                	ld	s3,8(sp)
    80003d7a:	6145                	addi	sp,sp,48
    80003d7c:	8082                	ret

0000000080003d7e <ialloc>:
{
    80003d7e:	715d                	addi	sp,sp,-80
    80003d80:	e486                	sd	ra,72(sp)
    80003d82:	e0a2                	sd	s0,64(sp)
    80003d84:	fc26                	sd	s1,56(sp)
    80003d86:	f84a                	sd	s2,48(sp)
    80003d88:	f44e                	sd	s3,40(sp)
    80003d8a:	f052                	sd	s4,32(sp)
    80003d8c:	ec56                	sd	s5,24(sp)
    80003d8e:	e85a                	sd	s6,16(sp)
    80003d90:	e45e                	sd	s7,8(sp)
    80003d92:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003d94:	0001d717          	auipc	a4,0x1d
    80003d98:	79072703          	lw	a4,1936(a4) # 80021524 <sb+0xc>
    80003d9c:	4785                	li	a5,1
    80003d9e:	04e7fa63          	bgeu	a5,a4,80003df2 <ialloc+0x74>
    80003da2:	8aaa                	mv	s5,a0
    80003da4:	8bae                	mv	s7,a1
    80003da6:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003da8:	0001da17          	auipc	s4,0x1d
    80003dac:	770a0a13          	addi	s4,s4,1904 # 80021518 <sb>
    80003db0:	00048b1b          	sext.w	s6,s1
    80003db4:	0044d593          	srli	a1,s1,0x4
    80003db8:	018a2783          	lw	a5,24(s4)
    80003dbc:	9dbd                	addw	a1,a1,a5
    80003dbe:	8556                	mv	a0,s5
    80003dc0:	00000097          	auipc	ra,0x0
    80003dc4:	940080e7          	jalr	-1728(ra) # 80003700 <bread>
    80003dc8:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003dca:	05850993          	addi	s3,a0,88
    80003dce:	00f4f793          	andi	a5,s1,15
    80003dd2:	079a                	slli	a5,a5,0x6
    80003dd4:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003dd6:	00099783          	lh	a5,0(s3)
    80003dda:	c3a1                	beqz	a5,80003e1a <ialloc+0x9c>
    brelse(bp);
    80003ddc:	00000097          	auipc	ra,0x0
    80003de0:	a54080e7          	jalr	-1452(ra) # 80003830 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003de4:	0485                	addi	s1,s1,1
    80003de6:	00ca2703          	lw	a4,12(s4)
    80003dea:	0004879b          	sext.w	a5,s1
    80003dee:	fce7e1e3          	bltu	a5,a4,80003db0 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003df2:	00005517          	auipc	a0,0x5
    80003df6:	99e50513          	addi	a0,a0,-1634 # 80008790 <syscallnum+0x128>
    80003dfa:	ffffc097          	auipc	ra,0xffffc
    80003dfe:	794080e7          	jalr	1940(ra) # 8000058e <printf>
  return 0;
    80003e02:	4501                	li	a0,0
}
    80003e04:	60a6                	ld	ra,72(sp)
    80003e06:	6406                	ld	s0,64(sp)
    80003e08:	74e2                	ld	s1,56(sp)
    80003e0a:	7942                	ld	s2,48(sp)
    80003e0c:	79a2                	ld	s3,40(sp)
    80003e0e:	7a02                	ld	s4,32(sp)
    80003e10:	6ae2                	ld	s5,24(sp)
    80003e12:	6b42                	ld	s6,16(sp)
    80003e14:	6ba2                	ld	s7,8(sp)
    80003e16:	6161                	addi	sp,sp,80
    80003e18:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003e1a:	04000613          	li	a2,64
    80003e1e:	4581                	li	a1,0
    80003e20:	854e                	mv	a0,s3
    80003e22:	ffffd097          	auipc	ra,0xffffd
    80003e26:	ec4080e7          	jalr	-316(ra) # 80000ce6 <memset>
      dip->type = type;
    80003e2a:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003e2e:	854a                	mv	a0,s2
    80003e30:	00001097          	auipc	ra,0x1
    80003e34:	c84080e7          	jalr	-892(ra) # 80004ab4 <log_write>
      brelse(bp);
    80003e38:	854a                	mv	a0,s2
    80003e3a:	00000097          	auipc	ra,0x0
    80003e3e:	9f6080e7          	jalr	-1546(ra) # 80003830 <brelse>
      return iget(dev, inum);
    80003e42:	85da                	mv	a1,s6
    80003e44:	8556                	mv	a0,s5
    80003e46:	00000097          	auipc	ra,0x0
    80003e4a:	d9c080e7          	jalr	-612(ra) # 80003be2 <iget>
    80003e4e:	bf5d                	j	80003e04 <ialloc+0x86>

0000000080003e50 <iupdate>:
{
    80003e50:	1101                	addi	sp,sp,-32
    80003e52:	ec06                	sd	ra,24(sp)
    80003e54:	e822                	sd	s0,16(sp)
    80003e56:	e426                	sd	s1,8(sp)
    80003e58:	e04a                	sd	s2,0(sp)
    80003e5a:	1000                	addi	s0,sp,32
    80003e5c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003e5e:	415c                	lw	a5,4(a0)
    80003e60:	0047d79b          	srliw	a5,a5,0x4
    80003e64:	0001d597          	auipc	a1,0x1d
    80003e68:	6cc5a583          	lw	a1,1740(a1) # 80021530 <sb+0x18>
    80003e6c:	9dbd                	addw	a1,a1,a5
    80003e6e:	4108                	lw	a0,0(a0)
    80003e70:	00000097          	auipc	ra,0x0
    80003e74:	890080e7          	jalr	-1904(ra) # 80003700 <bread>
    80003e78:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003e7a:	05850793          	addi	a5,a0,88
    80003e7e:	40c8                	lw	a0,4(s1)
    80003e80:	893d                	andi	a0,a0,15
    80003e82:	051a                	slli	a0,a0,0x6
    80003e84:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003e86:	04449703          	lh	a4,68(s1)
    80003e8a:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003e8e:	04649703          	lh	a4,70(s1)
    80003e92:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003e96:	04849703          	lh	a4,72(s1)
    80003e9a:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003e9e:	04a49703          	lh	a4,74(s1)
    80003ea2:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003ea6:	44f8                	lw	a4,76(s1)
    80003ea8:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003eaa:	03400613          	li	a2,52
    80003eae:	05048593          	addi	a1,s1,80
    80003eb2:	0531                	addi	a0,a0,12
    80003eb4:	ffffd097          	auipc	ra,0xffffd
    80003eb8:	e92080e7          	jalr	-366(ra) # 80000d46 <memmove>
  log_write(bp);
    80003ebc:	854a                	mv	a0,s2
    80003ebe:	00001097          	auipc	ra,0x1
    80003ec2:	bf6080e7          	jalr	-1034(ra) # 80004ab4 <log_write>
  brelse(bp);
    80003ec6:	854a                	mv	a0,s2
    80003ec8:	00000097          	auipc	ra,0x0
    80003ecc:	968080e7          	jalr	-1688(ra) # 80003830 <brelse>
}
    80003ed0:	60e2                	ld	ra,24(sp)
    80003ed2:	6442                	ld	s0,16(sp)
    80003ed4:	64a2                	ld	s1,8(sp)
    80003ed6:	6902                	ld	s2,0(sp)
    80003ed8:	6105                	addi	sp,sp,32
    80003eda:	8082                	ret

0000000080003edc <idup>:
{
    80003edc:	1101                	addi	sp,sp,-32
    80003ede:	ec06                	sd	ra,24(sp)
    80003ee0:	e822                	sd	s0,16(sp)
    80003ee2:	e426                	sd	s1,8(sp)
    80003ee4:	1000                	addi	s0,sp,32
    80003ee6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003ee8:	0001d517          	auipc	a0,0x1d
    80003eec:	65050513          	addi	a0,a0,1616 # 80021538 <itable>
    80003ef0:	ffffd097          	auipc	ra,0xffffd
    80003ef4:	cfa080e7          	jalr	-774(ra) # 80000bea <acquire>
  ip->ref++;
    80003ef8:	449c                	lw	a5,8(s1)
    80003efa:	2785                	addiw	a5,a5,1
    80003efc:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003efe:	0001d517          	auipc	a0,0x1d
    80003f02:	63a50513          	addi	a0,a0,1594 # 80021538 <itable>
    80003f06:	ffffd097          	auipc	ra,0xffffd
    80003f0a:	d98080e7          	jalr	-616(ra) # 80000c9e <release>
}
    80003f0e:	8526                	mv	a0,s1
    80003f10:	60e2                	ld	ra,24(sp)
    80003f12:	6442                	ld	s0,16(sp)
    80003f14:	64a2                	ld	s1,8(sp)
    80003f16:	6105                	addi	sp,sp,32
    80003f18:	8082                	ret

0000000080003f1a <ilock>:
{
    80003f1a:	1101                	addi	sp,sp,-32
    80003f1c:	ec06                	sd	ra,24(sp)
    80003f1e:	e822                	sd	s0,16(sp)
    80003f20:	e426                	sd	s1,8(sp)
    80003f22:	e04a                	sd	s2,0(sp)
    80003f24:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003f26:	c115                	beqz	a0,80003f4a <ilock+0x30>
    80003f28:	84aa                	mv	s1,a0
    80003f2a:	451c                	lw	a5,8(a0)
    80003f2c:	00f05f63          	blez	a5,80003f4a <ilock+0x30>
  acquiresleep(&ip->lock);
    80003f30:	0541                	addi	a0,a0,16
    80003f32:	00001097          	auipc	ra,0x1
    80003f36:	ca2080e7          	jalr	-862(ra) # 80004bd4 <acquiresleep>
  if(ip->valid == 0){
    80003f3a:	40bc                	lw	a5,64(s1)
    80003f3c:	cf99                	beqz	a5,80003f5a <ilock+0x40>
}
    80003f3e:	60e2                	ld	ra,24(sp)
    80003f40:	6442                	ld	s0,16(sp)
    80003f42:	64a2                	ld	s1,8(sp)
    80003f44:	6902                	ld	s2,0(sp)
    80003f46:	6105                	addi	sp,sp,32
    80003f48:	8082                	ret
    panic("ilock");
    80003f4a:	00005517          	auipc	a0,0x5
    80003f4e:	85e50513          	addi	a0,a0,-1954 # 800087a8 <syscallnum+0x140>
    80003f52:	ffffc097          	auipc	ra,0xffffc
    80003f56:	5f2080e7          	jalr	1522(ra) # 80000544 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003f5a:	40dc                	lw	a5,4(s1)
    80003f5c:	0047d79b          	srliw	a5,a5,0x4
    80003f60:	0001d597          	auipc	a1,0x1d
    80003f64:	5d05a583          	lw	a1,1488(a1) # 80021530 <sb+0x18>
    80003f68:	9dbd                	addw	a1,a1,a5
    80003f6a:	4088                	lw	a0,0(s1)
    80003f6c:	fffff097          	auipc	ra,0xfffff
    80003f70:	794080e7          	jalr	1940(ra) # 80003700 <bread>
    80003f74:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003f76:	05850593          	addi	a1,a0,88
    80003f7a:	40dc                	lw	a5,4(s1)
    80003f7c:	8bbd                	andi	a5,a5,15
    80003f7e:	079a                	slli	a5,a5,0x6
    80003f80:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003f82:	00059783          	lh	a5,0(a1)
    80003f86:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003f8a:	00259783          	lh	a5,2(a1)
    80003f8e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003f92:	00459783          	lh	a5,4(a1)
    80003f96:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003f9a:	00659783          	lh	a5,6(a1)
    80003f9e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003fa2:	459c                	lw	a5,8(a1)
    80003fa4:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003fa6:	03400613          	li	a2,52
    80003faa:	05b1                	addi	a1,a1,12
    80003fac:	05048513          	addi	a0,s1,80
    80003fb0:	ffffd097          	auipc	ra,0xffffd
    80003fb4:	d96080e7          	jalr	-618(ra) # 80000d46 <memmove>
    brelse(bp);
    80003fb8:	854a                	mv	a0,s2
    80003fba:	00000097          	auipc	ra,0x0
    80003fbe:	876080e7          	jalr	-1930(ra) # 80003830 <brelse>
    ip->valid = 1;
    80003fc2:	4785                	li	a5,1
    80003fc4:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003fc6:	04449783          	lh	a5,68(s1)
    80003fca:	fbb5                	bnez	a5,80003f3e <ilock+0x24>
      panic("ilock: no type");
    80003fcc:	00004517          	auipc	a0,0x4
    80003fd0:	7e450513          	addi	a0,a0,2020 # 800087b0 <syscallnum+0x148>
    80003fd4:	ffffc097          	auipc	ra,0xffffc
    80003fd8:	570080e7          	jalr	1392(ra) # 80000544 <panic>

0000000080003fdc <iunlock>:
{
    80003fdc:	1101                	addi	sp,sp,-32
    80003fde:	ec06                	sd	ra,24(sp)
    80003fe0:	e822                	sd	s0,16(sp)
    80003fe2:	e426                	sd	s1,8(sp)
    80003fe4:	e04a                	sd	s2,0(sp)
    80003fe6:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003fe8:	c905                	beqz	a0,80004018 <iunlock+0x3c>
    80003fea:	84aa                	mv	s1,a0
    80003fec:	01050913          	addi	s2,a0,16
    80003ff0:	854a                	mv	a0,s2
    80003ff2:	00001097          	auipc	ra,0x1
    80003ff6:	c7c080e7          	jalr	-900(ra) # 80004c6e <holdingsleep>
    80003ffa:	cd19                	beqz	a0,80004018 <iunlock+0x3c>
    80003ffc:	449c                	lw	a5,8(s1)
    80003ffe:	00f05d63          	blez	a5,80004018 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80004002:	854a                	mv	a0,s2
    80004004:	00001097          	auipc	ra,0x1
    80004008:	c26080e7          	jalr	-986(ra) # 80004c2a <releasesleep>
}
    8000400c:	60e2                	ld	ra,24(sp)
    8000400e:	6442                	ld	s0,16(sp)
    80004010:	64a2                	ld	s1,8(sp)
    80004012:	6902                	ld	s2,0(sp)
    80004014:	6105                	addi	sp,sp,32
    80004016:	8082                	ret
    panic("iunlock");
    80004018:	00004517          	auipc	a0,0x4
    8000401c:	7a850513          	addi	a0,a0,1960 # 800087c0 <syscallnum+0x158>
    80004020:	ffffc097          	auipc	ra,0xffffc
    80004024:	524080e7          	jalr	1316(ra) # 80000544 <panic>

0000000080004028 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80004028:	7179                	addi	sp,sp,-48
    8000402a:	f406                	sd	ra,40(sp)
    8000402c:	f022                	sd	s0,32(sp)
    8000402e:	ec26                	sd	s1,24(sp)
    80004030:	e84a                	sd	s2,16(sp)
    80004032:	e44e                	sd	s3,8(sp)
    80004034:	e052                	sd	s4,0(sp)
    80004036:	1800                	addi	s0,sp,48
    80004038:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000403a:	05050493          	addi	s1,a0,80
    8000403e:	08050913          	addi	s2,a0,128
    80004042:	a021                	j	8000404a <itrunc+0x22>
    80004044:	0491                	addi	s1,s1,4
    80004046:	01248d63          	beq	s1,s2,80004060 <itrunc+0x38>
    if(ip->addrs[i]){
    8000404a:	408c                	lw	a1,0(s1)
    8000404c:	dde5                	beqz	a1,80004044 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    8000404e:	0009a503          	lw	a0,0(s3)
    80004052:	00000097          	auipc	ra,0x0
    80004056:	8f4080e7          	jalr	-1804(ra) # 80003946 <bfree>
      ip->addrs[i] = 0;
    8000405a:	0004a023          	sw	zero,0(s1)
    8000405e:	b7dd                	j	80004044 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80004060:	0809a583          	lw	a1,128(s3)
    80004064:	e185                	bnez	a1,80004084 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80004066:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000406a:	854e                	mv	a0,s3
    8000406c:	00000097          	auipc	ra,0x0
    80004070:	de4080e7          	jalr	-540(ra) # 80003e50 <iupdate>
}
    80004074:	70a2                	ld	ra,40(sp)
    80004076:	7402                	ld	s0,32(sp)
    80004078:	64e2                	ld	s1,24(sp)
    8000407a:	6942                	ld	s2,16(sp)
    8000407c:	69a2                	ld	s3,8(sp)
    8000407e:	6a02                	ld	s4,0(sp)
    80004080:	6145                	addi	sp,sp,48
    80004082:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80004084:	0009a503          	lw	a0,0(s3)
    80004088:	fffff097          	auipc	ra,0xfffff
    8000408c:	678080e7          	jalr	1656(ra) # 80003700 <bread>
    80004090:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80004092:	05850493          	addi	s1,a0,88
    80004096:	45850913          	addi	s2,a0,1112
    8000409a:	a811                	j	800040ae <itrunc+0x86>
        bfree(ip->dev, a[j]);
    8000409c:	0009a503          	lw	a0,0(s3)
    800040a0:	00000097          	auipc	ra,0x0
    800040a4:	8a6080e7          	jalr	-1882(ra) # 80003946 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    800040a8:	0491                	addi	s1,s1,4
    800040aa:	01248563          	beq	s1,s2,800040b4 <itrunc+0x8c>
      if(a[j])
    800040ae:	408c                	lw	a1,0(s1)
    800040b0:	dde5                	beqz	a1,800040a8 <itrunc+0x80>
    800040b2:	b7ed                	j	8000409c <itrunc+0x74>
    brelse(bp);
    800040b4:	8552                	mv	a0,s4
    800040b6:	fffff097          	auipc	ra,0xfffff
    800040ba:	77a080e7          	jalr	1914(ra) # 80003830 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800040be:	0809a583          	lw	a1,128(s3)
    800040c2:	0009a503          	lw	a0,0(s3)
    800040c6:	00000097          	auipc	ra,0x0
    800040ca:	880080e7          	jalr	-1920(ra) # 80003946 <bfree>
    ip->addrs[NDIRECT] = 0;
    800040ce:	0809a023          	sw	zero,128(s3)
    800040d2:	bf51                	j	80004066 <itrunc+0x3e>

00000000800040d4 <iput>:
{
    800040d4:	1101                	addi	sp,sp,-32
    800040d6:	ec06                	sd	ra,24(sp)
    800040d8:	e822                	sd	s0,16(sp)
    800040da:	e426                	sd	s1,8(sp)
    800040dc:	e04a                	sd	s2,0(sp)
    800040de:	1000                	addi	s0,sp,32
    800040e0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800040e2:	0001d517          	auipc	a0,0x1d
    800040e6:	45650513          	addi	a0,a0,1110 # 80021538 <itable>
    800040ea:	ffffd097          	auipc	ra,0xffffd
    800040ee:	b00080e7          	jalr	-1280(ra) # 80000bea <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800040f2:	4498                	lw	a4,8(s1)
    800040f4:	4785                	li	a5,1
    800040f6:	02f70363          	beq	a4,a5,8000411c <iput+0x48>
  ip->ref--;
    800040fa:	449c                	lw	a5,8(s1)
    800040fc:	37fd                	addiw	a5,a5,-1
    800040fe:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004100:	0001d517          	auipc	a0,0x1d
    80004104:	43850513          	addi	a0,a0,1080 # 80021538 <itable>
    80004108:	ffffd097          	auipc	ra,0xffffd
    8000410c:	b96080e7          	jalr	-1130(ra) # 80000c9e <release>
}
    80004110:	60e2                	ld	ra,24(sp)
    80004112:	6442                	ld	s0,16(sp)
    80004114:	64a2                	ld	s1,8(sp)
    80004116:	6902                	ld	s2,0(sp)
    80004118:	6105                	addi	sp,sp,32
    8000411a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000411c:	40bc                	lw	a5,64(s1)
    8000411e:	dff1                	beqz	a5,800040fa <iput+0x26>
    80004120:	04a49783          	lh	a5,74(s1)
    80004124:	fbf9                	bnez	a5,800040fa <iput+0x26>
    acquiresleep(&ip->lock);
    80004126:	01048913          	addi	s2,s1,16
    8000412a:	854a                	mv	a0,s2
    8000412c:	00001097          	auipc	ra,0x1
    80004130:	aa8080e7          	jalr	-1368(ra) # 80004bd4 <acquiresleep>
    release(&itable.lock);
    80004134:	0001d517          	auipc	a0,0x1d
    80004138:	40450513          	addi	a0,a0,1028 # 80021538 <itable>
    8000413c:	ffffd097          	auipc	ra,0xffffd
    80004140:	b62080e7          	jalr	-1182(ra) # 80000c9e <release>
    itrunc(ip);
    80004144:	8526                	mv	a0,s1
    80004146:	00000097          	auipc	ra,0x0
    8000414a:	ee2080e7          	jalr	-286(ra) # 80004028 <itrunc>
    ip->type = 0;
    8000414e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80004152:	8526                	mv	a0,s1
    80004154:	00000097          	auipc	ra,0x0
    80004158:	cfc080e7          	jalr	-772(ra) # 80003e50 <iupdate>
    ip->valid = 0;
    8000415c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80004160:	854a                	mv	a0,s2
    80004162:	00001097          	auipc	ra,0x1
    80004166:	ac8080e7          	jalr	-1336(ra) # 80004c2a <releasesleep>
    acquire(&itable.lock);
    8000416a:	0001d517          	auipc	a0,0x1d
    8000416e:	3ce50513          	addi	a0,a0,974 # 80021538 <itable>
    80004172:	ffffd097          	auipc	ra,0xffffd
    80004176:	a78080e7          	jalr	-1416(ra) # 80000bea <acquire>
    8000417a:	b741                	j	800040fa <iput+0x26>

000000008000417c <iunlockput>:
{
    8000417c:	1101                	addi	sp,sp,-32
    8000417e:	ec06                	sd	ra,24(sp)
    80004180:	e822                	sd	s0,16(sp)
    80004182:	e426                	sd	s1,8(sp)
    80004184:	1000                	addi	s0,sp,32
    80004186:	84aa                	mv	s1,a0
  iunlock(ip);
    80004188:	00000097          	auipc	ra,0x0
    8000418c:	e54080e7          	jalr	-428(ra) # 80003fdc <iunlock>
  iput(ip);
    80004190:	8526                	mv	a0,s1
    80004192:	00000097          	auipc	ra,0x0
    80004196:	f42080e7          	jalr	-190(ra) # 800040d4 <iput>
}
    8000419a:	60e2                	ld	ra,24(sp)
    8000419c:	6442                	ld	s0,16(sp)
    8000419e:	64a2                	ld	s1,8(sp)
    800041a0:	6105                	addi	sp,sp,32
    800041a2:	8082                	ret

00000000800041a4 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800041a4:	1141                	addi	sp,sp,-16
    800041a6:	e422                	sd	s0,8(sp)
    800041a8:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800041aa:	411c                	lw	a5,0(a0)
    800041ac:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800041ae:	415c                	lw	a5,4(a0)
    800041b0:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800041b2:	04451783          	lh	a5,68(a0)
    800041b6:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800041ba:	04a51783          	lh	a5,74(a0)
    800041be:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800041c2:	04c56783          	lwu	a5,76(a0)
    800041c6:	e99c                	sd	a5,16(a1)
}
    800041c8:	6422                	ld	s0,8(sp)
    800041ca:	0141                	addi	sp,sp,16
    800041cc:	8082                	ret

00000000800041ce <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800041ce:	457c                	lw	a5,76(a0)
    800041d0:	0ed7e963          	bltu	a5,a3,800042c2 <readi+0xf4>
{
    800041d4:	7159                	addi	sp,sp,-112
    800041d6:	f486                	sd	ra,104(sp)
    800041d8:	f0a2                	sd	s0,96(sp)
    800041da:	eca6                	sd	s1,88(sp)
    800041dc:	e8ca                	sd	s2,80(sp)
    800041de:	e4ce                	sd	s3,72(sp)
    800041e0:	e0d2                	sd	s4,64(sp)
    800041e2:	fc56                	sd	s5,56(sp)
    800041e4:	f85a                	sd	s6,48(sp)
    800041e6:	f45e                	sd	s7,40(sp)
    800041e8:	f062                	sd	s8,32(sp)
    800041ea:	ec66                	sd	s9,24(sp)
    800041ec:	e86a                	sd	s10,16(sp)
    800041ee:	e46e                	sd	s11,8(sp)
    800041f0:	1880                	addi	s0,sp,112
    800041f2:	8b2a                	mv	s6,a0
    800041f4:	8bae                	mv	s7,a1
    800041f6:	8a32                	mv	s4,a2
    800041f8:	84b6                	mv	s1,a3
    800041fa:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800041fc:	9f35                	addw	a4,a4,a3
    return 0;
    800041fe:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004200:	0ad76063          	bltu	a4,a3,800042a0 <readi+0xd2>
  if(off + n > ip->size)
    80004204:	00e7f463          	bgeu	a5,a4,8000420c <readi+0x3e>
    n = ip->size - off;
    80004208:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000420c:	0a0a8963          	beqz	s5,800042be <readi+0xf0>
    80004210:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004212:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004216:	5c7d                	li	s8,-1
    80004218:	a82d                	j	80004252 <readi+0x84>
    8000421a:	020d1d93          	slli	s11,s10,0x20
    8000421e:	020ddd93          	srli	s11,s11,0x20
    80004222:	05890613          	addi	a2,s2,88
    80004226:	86ee                	mv	a3,s11
    80004228:	963a                	add	a2,a2,a4
    8000422a:	85d2                	mv	a1,s4
    8000422c:	855e                	mv	a0,s7
    8000422e:	ffffe097          	auipc	ra,0xffffe
    80004232:	74c080e7          	jalr	1868(ra) # 8000297a <either_copyout>
    80004236:	05850d63          	beq	a0,s8,80004290 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000423a:	854a                	mv	a0,s2
    8000423c:	fffff097          	auipc	ra,0xfffff
    80004240:	5f4080e7          	jalr	1524(ra) # 80003830 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004244:	013d09bb          	addw	s3,s10,s3
    80004248:	009d04bb          	addw	s1,s10,s1
    8000424c:	9a6e                	add	s4,s4,s11
    8000424e:	0559f763          	bgeu	s3,s5,8000429c <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80004252:	00a4d59b          	srliw	a1,s1,0xa
    80004256:	855a                	mv	a0,s6
    80004258:	00000097          	auipc	ra,0x0
    8000425c:	8a2080e7          	jalr	-1886(ra) # 80003afa <bmap>
    80004260:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004264:	cd85                	beqz	a1,8000429c <readi+0xce>
    bp = bread(ip->dev, addr);
    80004266:	000b2503          	lw	a0,0(s6)
    8000426a:	fffff097          	auipc	ra,0xfffff
    8000426e:	496080e7          	jalr	1174(ra) # 80003700 <bread>
    80004272:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004274:	3ff4f713          	andi	a4,s1,1023
    80004278:	40ec87bb          	subw	a5,s9,a4
    8000427c:	413a86bb          	subw	a3,s5,s3
    80004280:	8d3e                	mv	s10,a5
    80004282:	2781                	sext.w	a5,a5
    80004284:	0006861b          	sext.w	a2,a3
    80004288:	f8f679e3          	bgeu	a2,a5,8000421a <readi+0x4c>
    8000428c:	8d36                	mv	s10,a3
    8000428e:	b771                	j	8000421a <readi+0x4c>
      brelse(bp);
    80004290:	854a                	mv	a0,s2
    80004292:	fffff097          	auipc	ra,0xfffff
    80004296:	59e080e7          	jalr	1438(ra) # 80003830 <brelse>
      tot = -1;
    8000429a:	59fd                	li	s3,-1
  }
  return tot;
    8000429c:	0009851b          	sext.w	a0,s3
}
    800042a0:	70a6                	ld	ra,104(sp)
    800042a2:	7406                	ld	s0,96(sp)
    800042a4:	64e6                	ld	s1,88(sp)
    800042a6:	6946                	ld	s2,80(sp)
    800042a8:	69a6                	ld	s3,72(sp)
    800042aa:	6a06                	ld	s4,64(sp)
    800042ac:	7ae2                	ld	s5,56(sp)
    800042ae:	7b42                	ld	s6,48(sp)
    800042b0:	7ba2                	ld	s7,40(sp)
    800042b2:	7c02                	ld	s8,32(sp)
    800042b4:	6ce2                	ld	s9,24(sp)
    800042b6:	6d42                	ld	s10,16(sp)
    800042b8:	6da2                	ld	s11,8(sp)
    800042ba:	6165                	addi	sp,sp,112
    800042bc:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800042be:	89d6                	mv	s3,s5
    800042c0:	bff1                	j	8000429c <readi+0xce>
    return 0;
    800042c2:	4501                	li	a0,0
}
    800042c4:	8082                	ret

00000000800042c6 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800042c6:	457c                	lw	a5,76(a0)
    800042c8:	10d7e863          	bltu	a5,a3,800043d8 <writei+0x112>
{
    800042cc:	7159                	addi	sp,sp,-112
    800042ce:	f486                	sd	ra,104(sp)
    800042d0:	f0a2                	sd	s0,96(sp)
    800042d2:	eca6                	sd	s1,88(sp)
    800042d4:	e8ca                	sd	s2,80(sp)
    800042d6:	e4ce                	sd	s3,72(sp)
    800042d8:	e0d2                	sd	s4,64(sp)
    800042da:	fc56                	sd	s5,56(sp)
    800042dc:	f85a                	sd	s6,48(sp)
    800042de:	f45e                	sd	s7,40(sp)
    800042e0:	f062                	sd	s8,32(sp)
    800042e2:	ec66                	sd	s9,24(sp)
    800042e4:	e86a                	sd	s10,16(sp)
    800042e6:	e46e                	sd	s11,8(sp)
    800042e8:	1880                	addi	s0,sp,112
    800042ea:	8aaa                	mv	s5,a0
    800042ec:	8bae                	mv	s7,a1
    800042ee:	8a32                	mv	s4,a2
    800042f0:	8936                	mv	s2,a3
    800042f2:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800042f4:	00e687bb          	addw	a5,a3,a4
    800042f8:	0ed7e263          	bltu	a5,a3,800043dc <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800042fc:	00043737          	lui	a4,0x43
    80004300:	0ef76063          	bltu	a4,a5,800043e0 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004304:	0c0b0863          	beqz	s6,800043d4 <writei+0x10e>
    80004308:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000430a:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000430e:	5c7d                	li	s8,-1
    80004310:	a091                	j	80004354 <writei+0x8e>
    80004312:	020d1d93          	slli	s11,s10,0x20
    80004316:	020ddd93          	srli	s11,s11,0x20
    8000431a:	05848513          	addi	a0,s1,88
    8000431e:	86ee                	mv	a3,s11
    80004320:	8652                	mv	a2,s4
    80004322:	85de                	mv	a1,s7
    80004324:	953a                	add	a0,a0,a4
    80004326:	ffffe097          	auipc	ra,0xffffe
    8000432a:	6aa080e7          	jalr	1706(ra) # 800029d0 <either_copyin>
    8000432e:	07850263          	beq	a0,s8,80004392 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004332:	8526                	mv	a0,s1
    80004334:	00000097          	auipc	ra,0x0
    80004338:	780080e7          	jalr	1920(ra) # 80004ab4 <log_write>
    brelse(bp);
    8000433c:	8526                	mv	a0,s1
    8000433e:	fffff097          	auipc	ra,0xfffff
    80004342:	4f2080e7          	jalr	1266(ra) # 80003830 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004346:	013d09bb          	addw	s3,s10,s3
    8000434a:	012d093b          	addw	s2,s10,s2
    8000434e:	9a6e                	add	s4,s4,s11
    80004350:	0569f663          	bgeu	s3,s6,8000439c <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80004354:	00a9559b          	srliw	a1,s2,0xa
    80004358:	8556                	mv	a0,s5
    8000435a:	fffff097          	auipc	ra,0xfffff
    8000435e:	7a0080e7          	jalr	1952(ra) # 80003afa <bmap>
    80004362:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004366:	c99d                	beqz	a1,8000439c <writei+0xd6>
    bp = bread(ip->dev, addr);
    80004368:	000aa503          	lw	a0,0(s5)
    8000436c:	fffff097          	auipc	ra,0xfffff
    80004370:	394080e7          	jalr	916(ra) # 80003700 <bread>
    80004374:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004376:	3ff97713          	andi	a4,s2,1023
    8000437a:	40ec87bb          	subw	a5,s9,a4
    8000437e:	413b06bb          	subw	a3,s6,s3
    80004382:	8d3e                	mv	s10,a5
    80004384:	2781                	sext.w	a5,a5
    80004386:	0006861b          	sext.w	a2,a3
    8000438a:	f8f674e3          	bgeu	a2,a5,80004312 <writei+0x4c>
    8000438e:	8d36                	mv	s10,a3
    80004390:	b749                	j	80004312 <writei+0x4c>
      brelse(bp);
    80004392:	8526                	mv	a0,s1
    80004394:	fffff097          	auipc	ra,0xfffff
    80004398:	49c080e7          	jalr	1180(ra) # 80003830 <brelse>
  }

  if(off > ip->size)
    8000439c:	04caa783          	lw	a5,76(s5)
    800043a0:	0127f463          	bgeu	a5,s2,800043a8 <writei+0xe2>
    ip->size = off;
    800043a4:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800043a8:	8556                	mv	a0,s5
    800043aa:	00000097          	auipc	ra,0x0
    800043ae:	aa6080e7          	jalr	-1370(ra) # 80003e50 <iupdate>

  return tot;
    800043b2:	0009851b          	sext.w	a0,s3
}
    800043b6:	70a6                	ld	ra,104(sp)
    800043b8:	7406                	ld	s0,96(sp)
    800043ba:	64e6                	ld	s1,88(sp)
    800043bc:	6946                	ld	s2,80(sp)
    800043be:	69a6                	ld	s3,72(sp)
    800043c0:	6a06                	ld	s4,64(sp)
    800043c2:	7ae2                	ld	s5,56(sp)
    800043c4:	7b42                	ld	s6,48(sp)
    800043c6:	7ba2                	ld	s7,40(sp)
    800043c8:	7c02                	ld	s8,32(sp)
    800043ca:	6ce2                	ld	s9,24(sp)
    800043cc:	6d42                	ld	s10,16(sp)
    800043ce:	6da2                	ld	s11,8(sp)
    800043d0:	6165                	addi	sp,sp,112
    800043d2:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800043d4:	89da                	mv	s3,s6
    800043d6:	bfc9                	j	800043a8 <writei+0xe2>
    return -1;
    800043d8:	557d                	li	a0,-1
}
    800043da:	8082                	ret
    return -1;
    800043dc:	557d                	li	a0,-1
    800043de:	bfe1                	j	800043b6 <writei+0xf0>
    return -1;
    800043e0:	557d                	li	a0,-1
    800043e2:	bfd1                	j	800043b6 <writei+0xf0>

00000000800043e4 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800043e4:	1141                	addi	sp,sp,-16
    800043e6:	e406                	sd	ra,8(sp)
    800043e8:	e022                	sd	s0,0(sp)
    800043ea:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800043ec:	4639                	li	a2,14
    800043ee:	ffffd097          	auipc	ra,0xffffd
    800043f2:	9d0080e7          	jalr	-1584(ra) # 80000dbe <strncmp>
}
    800043f6:	60a2                	ld	ra,8(sp)
    800043f8:	6402                	ld	s0,0(sp)
    800043fa:	0141                	addi	sp,sp,16
    800043fc:	8082                	ret

00000000800043fe <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800043fe:	7139                	addi	sp,sp,-64
    80004400:	fc06                	sd	ra,56(sp)
    80004402:	f822                	sd	s0,48(sp)
    80004404:	f426                	sd	s1,40(sp)
    80004406:	f04a                	sd	s2,32(sp)
    80004408:	ec4e                	sd	s3,24(sp)
    8000440a:	e852                	sd	s4,16(sp)
    8000440c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000440e:	04451703          	lh	a4,68(a0)
    80004412:	4785                	li	a5,1
    80004414:	00f71a63          	bne	a4,a5,80004428 <dirlookup+0x2a>
    80004418:	892a                	mv	s2,a0
    8000441a:	89ae                	mv	s3,a1
    8000441c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000441e:	457c                	lw	a5,76(a0)
    80004420:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004422:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004424:	e79d                	bnez	a5,80004452 <dirlookup+0x54>
    80004426:	a8a5                	j	8000449e <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004428:	00004517          	auipc	a0,0x4
    8000442c:	3a050513          	addi	a0,a0,928 # 800087c8 <syscallnum+0x160>
    80004430:	ffffc097          	auipc	ra,0xffffc
    80004434:	114080e7          	jalr	276(ra) # 80000544 <panic>
      panic("dirlookup read");
    80004438:	00004517          	auipc	a0,0x4
    8000443c:	3a850513          	addi	a0,a0,936 # 800087e0 <syscallnum+0x178>
    80004440:	ffffc097          	auipc	ra,0xffffc
    80004444:	104080e7          	jalr	260(ra) # 80000544 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004448:	24c1                	addiw	s1,s1,16
    8000444a:	04c92783          	lw	a5,76(s2)
    8000444e:	04f4f763          	bgeu	s1,a5,8000449c <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004452:	4741                	li	a4,16
    80004454:	86a6                	mv	a3,s1
    80004456:	fc040613          	addi	a2,s0,-64
    8000445a:	4581                	li	a1,0
    8000445c:	854a                	mv	a0,s2
    8000445e:	00000097          	auipc	ra,0x0
    80004462:	d70080e7          	jalr	-656(ra) # 800041ce <readi>
    80004466:	47c1                	li	a5,16
    80004468:	fcf518e3          	bne	a0,a5,80004438 <dirlookup+0x3a>
    if(de.inum == 0)
    8000446c:	fc045783          	lhu	a5,-64(s0)
    80004470:	dfe1                	beqz	a5,80004448 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004472:	fc240593          	addi	a1,s0,-62
    80004476:	854e                	mv	a0,s3
    80004478:	00000097          	auipc	ra,0x0
    8000447c:	f6c080e7          	jalr	-148(ra) # 800043e4 <namecmp>
    80004480:	f561                	bnez	a0,80004448 <dirlookup+0x4a>
      if(poff)
    80004482:	000a0463          	beqz	s4,8000448a <dirlookup+0x8c>
        *poff = off;
    80004486:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000448a:	fc045583          	lhu	a1,-64(s0)
    8000448e:	00092503          	lw	a0,0(s2)
    80004492:	fffff097          	auipc	ra,0xfffff
    80004496:	750080e7          	jalr	1872(ra) # 80003be2 <iget>
    8000449a:	a011                	j	8000449e <dirlookup+0xa0>
  return 0;
    8000449c:	4501                	li	a0,0
}
    8000449e:	70e2                	ld	ra,56(sp)
    800044a0:	7442                	ld	s0,48(sp)
    800044a2:	74a2                	ld	s1,40(sp)
    800044a4:	7902                	ld	s2,32(sp)
    800044a6:	69e2                	ld	s3,24(sp)
    800044a8:	6a42                	ld	s4,16(sp)
    800044aa:	6121                	addi	sp,sp,64
    800044ac:	8082                	ret

00000000800044ae <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800044ae:	711d                	addi	sp,sp,-96
    800044b0:	ec86                	sd	ra,88(sp)
    800044b2:	e8a2                	sd	s0,80(sp)
    800044b4:	e4a6                	sd	s1,72(sp)
    800044b6:	e0ca                	sd	s2,64(sp)
    800044b8:	fc4e                	sd	s3,56(sp)
    800044ba:	f852                	sd	s4,48(sp)
    800044bc:	f456                	sd	s5,40(sp)
    800044be:	f05a                	sd	s6,32(sp)
    800044c0:	ec5e                	sd	s7,24(sp)
    800044c2:	e862                	sd	s8,16(sp)
    800044c4:	e466                	sd	s9,8(sp)
    800044c6:	1080                	addi	s0,sp,96
    800044c8:	84aa                	mv	s1,a0
    800044ca:	8b2e                	mv	s6,a1
    800044cc:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800044ce:	00054703          	lbu	a4,0(a0)
    800044d2:	02f00793          	li	a5,47
    800044d6:	02f70363          	beq	a4,a5,800044fc <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800044da:	ffffd097          	auipc	ra,0xffffd
    800044de:	4ec080e7          	jalr	1260(ra) # 800019c6 <myproc>
    800044e2:	15053503          	ld	a0,336(a0)
    800044e6:	00000097          	auipc	ra,0x0
    800044ea:	9f6080e7          	jalr	-1546(ra) # 80003edc <idup>
    800044ee:	89aa                	mv	s3,a0
  while(*path == '/')
    800044f0:	02f00913          	li	s2,47
  len = path - s;
    800044f4:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    800044f6:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800044f8:	4c05                	li	s8,1
    800044fa:	a865                	j	800045b2 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800044fc:	4585                	li	a1,1
    800044fe:	4505                	li	a0,1
    80004500:	fffff097          	auipc	ra,0xfffff
    80004504:	6e2080e7          	jalr	1762(ra) # 80003be2 <iget>
    80004508:	89aa                	mv	s3,a0
    8000450a:	b7dd                	j	800044f0 <namex+0x42>
      iunlockput(ip);
    8000450c:	854e                	mv	a0,s3
    8000450e:	00000097          	auipc	ra,0x0
    80004512:	c6e080e7          	jalr	-914(ra) # 8000417c <iunlockput>
      return 0;
    80004516:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004518:	854e                	mv	a0,s3
    8000451a:	60e6                	ld	ra,88(sp)
    8000451c:	6446                	ld	s0,80(sp)
    8000451e:	64a6                	ld	s1,72(sp)
    80004520:	6906                	ld	s2,64(sp)
    80004522:	79e2                	ld	s3,56(sp)
    80004524:	7a42                	ld	s4,48(sp)
    80004526:	7aa2                	ld	s5,40(sp)
    80004528:	7b02                	ld	s6,32(sp)
    8000452a:	6be2                	ld	s7,24(sp)
    8000452c:	6c42                	ld	s8,16(sp)
    8000452e:	6ca2                	ld	s9,8(sp)
    80004530:	6125                	addi	sp,sp,96
    80004532:	8082                	ret
      iunlock(ip);
    80004534:	854e                	mv	a0,s3
    80004536:	00000097          	auipc	ra,0x0
    8000453a:	aa6080e7          	jalr	-1370(ra) # 80003fdc <iunlock>
      return ip;
    8000453e:	bfe9                	j	80004518 <namex+0x6a>
      iunlockput(ip);
    80004540:	854e                	mv	a0,s3
    80004542:	00000097          	auipc	ra,0x0
    80004546:	c3a080e7          	jalr	-966(ra) # 8000417c <iunlockput>
      return 0;
    8000454a:	89d2                	mv	s3,s4
    8000454c:	b7f1                	j	80004518 <namex+0x6a>
  len = path - s;
    8000454e:	40b48633          	sub	a2,s1,a1
    80004552:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80004556:	094cd463          	bge	s9,s4,800045de <namex+0x130>
    memmove(name, s, DIRSIZ);
    8000455a:	4639                	li	a2,14
    8000455c:	8556                	mv	a0,s5
    8000455e:	ffffc097          	auipc	ra,0xffffc
    80004562:	7e8080e7          	jalr	2024(ra) # 80000d46 <memmove>
  while(*path == '/')
    80004566:	0004c783          	lbu	a5,0(s1)
    8000456a:	01279763          	bne	a5,s2,80004578 <namex+0xca>
    path++;
    8000456e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004570:	0004c783          	lbu	a5,0(s1)
    80004574:	ff278de3          	beq	a5,s2,8000456e <namex+0xc0>
    ilock(ip);
    80004578:	854e                	mv	a0,s3
    8000457a:	00000097          	auipc	ra,0x0
    8000457e:	9a0080e7          	jalr	-1632(ra) # 80003f1a <ilock>
    if(ip->type != T_DIR){
    80004582:	04499783          	lh	a5,68(s3)
    80004586:	f98793e3          	bne	a5,s8,8000450c <namex+0x5e>
    if(nameiparent && *path == '\0'){
    8000458a:	000b0563          	beqz	s6,80004594 <namex+0xe6>
    8000458e:	0004c783          	lbu	a5,0(s1)
    80004592:	d3cd                	beqz	a5,80004534 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004594:	865e                	mv	a2,s7
    80004596:	85d6                	mv	a1,s5
    80004598:	854e                	mv	a0,s3
    8000459a:	00000097          	auipc	ra,0x0
    8000459e:	e64080e7          	jalr	-412(ra) # 800043fe <dirlookup>
    800045a2:	8a2a                	mv	s4,a0
    800045a4:	dd51                	beqz	a0,80004540 <namex+0x92>
    iunlockput(ip);
    800045a6:	854e                	mv	a0,s3
    800045a8:	00000097          	auipc	ra,0x0
    800045ac:	bd4080e7          	jalr	-1068(ra) # 8000417c <iunlockput>
    ip = next;
    800045b0:	89d2                	mv	s3,s4
  while(*path == '/')
    800045b2:	0004c783          	lbu	a5,0(s1)
    800045b6:	05279763          	bne	a5,s2,80004604 <namex+0x156>
    path++;
    800045ba:	0485                	addi	s1,s1,1
  while(*path == '/')
    800045bc:	0004c783          	lbu	a5,0(s1)
    800045c0:	ff278de3          	beq	a5,s2,800045ba <namex+0x10c>
  if(*path == 0)
    800045c4:	c79d                	beqz	a5,800045f2 <namex+0x144>
    path++;
    800045c6:	85a6                	mv	a1,s1
  len = path - s;
    800045c8:	8a5e                	mv	s4,s7
    800045ca:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    800045cc:	01278963          	beq	a5,s2,800045de <namex+0x130>
    800045d0:	dfbd                	beqz	a5,8000454e <namex+0xa0>
    path++;
    800045d2:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800045d4:	0004c783          	lbu	a5,0(s1)
    800045d8:	ff279ce3          	bne	a5,s2,800045d0 <namex+0x122>
    800045dc:	bf8d                	j	8000454e <namex+0xa0>
    memmove(name, s, len);
    800045de:	2601                	sext.w	a2,a2
    800045e0:	8556                	mv	a0,s5
    800045e2:	ffffc097          	auipc	ra,0xffffc
    800045e6:	764080e7          	jalr	1892(ra) # 80000d46 <memmove>
    name[len] = 0;
    800045ea:	9a56                	add	s4,s4,s5
    800045ec:	000a0023          	sb	zero,0(s4)
    800045f0:	bf9d                	j	80004566 <namex+0xb8>
  if(nameiparent){
    800045f2:	f20b03e3          	beqz	s6,80004518 <namex+0x6a>
    iput(ip);
    800045f6:	854e                	mv	a0,s3
    800045f8:	00000097          	auipc	ra,0x0
    800045fc:	adc080e7          	jalr	-1316(ra) # 800040d4 <iput>
    return 0;
    80004600:	4981                	li	s3,0
    80004602:	bf19                	j	80004518 <namex+0x6a>
  if(*path == 0)
    80004604:	d7fd                	beqz	a5,800045f2 <namex+0x144>
  while(*path != '/' && *path != 0)
    80004606:	0004c783          	lbu	a5,0(s1)
    8000460a:	85a6                	mv	a1,s1
    8000460c:	b7d1                	j	800045d0 <namex+0x122>

000000008000460e <dirlink>:
{
    8000460e:	7139                	addi	sp,sp,-64
    80004610:	fc06                	sd	ra,56(sp)
    80004612:	f822                	sd	s0,48(sp)
    80004614:	f426                	sd	s1,40(sp)
    80004616:	f04a                	sd	s2,32(sp)
    80004618:	ec4e                	sd	s3,24(sp)
    8000461a:	e852                	sd	s4,16(sp)
    8000461c:	0080                	addi	s0,sp,64
    8000461e:	892a                	mv	s2,a0
    80004620:	8a2e                	mv	s4,a1
    80004622:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004624:	4601                	li	a2,0
    80004626:	00000097          	auipc	ra,0x0
    8000462a:	dd8080e7          	jalr	-552(ra) # 800043fe <dirlookup>
    8000462e:	e93d                	bnez	a0,800046a4 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004630:	04c92483          	lw	s1,76(s2)
    80004634:	c49d                	beqz	s1,80004662 <dirlink+0x54>
    80004636:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004638:	4741                	li	a4,16
    8000463a:	86a6                	mv	a3,s1
    8000463c:	fc040613          	addi	a2,s0,-64
    80004640:	4581                	li	a1,0
    80004642:	854a                	mv	a0,s2
    80004644:	00000097          	auipc	ra,0x0
    80004648:	b8a080e7          	jalr	-1142(ra) # 800041ce <readi>
    8000464c:	47c1                	li	a5,16
    8000464e:	06f51163          	bne	a0,a5,800046b0 <dirlink+0xa2>
    if(de.inum == 0)
    80004652:	fc045783          	lhu	a5,-64(s0)
    80004656:	c791                	beqz	a5,80004662 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004658:	24c1                	addiw	s1,s1,16
    8000465a:	04c92783          	lw	a5,76(s2)
    8000465e:	fcf4ede3          	bltu	s1,a5,80004638 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004662:	4639                	li	a2,14
    80004664:	85d2                	mv	a1,s4
    80004666:	fc240513          	addi	a0,s0,-62
    8000466a:	ffffc097          	auipc	ra,0xffffc
    8000466e:	790080e7          	jalr	1936(ra) # 80000dfa <strncpy>
  de.inum = inum;
    80004672:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004676:	4741                	li	a4,16
    80004678:	86a6                	mv	a3,s1
    8000467a:	fc040613          	addi	a2,s0,-64
    8000467e:	4581                	li	a1,0
    80004680:	854a                	mv	a0,s2
    80004682:	00000097          	auipc	ra,0x0
    80004686:	c44080e7          	jalr	-956(ra) # 800042c6 <writei>
    8000468a:	1541                	addi	a0,a0,-16
    8000468c:	00a03533          	snez	a0,a0
    80004690:	40a00533          	neg	a0,a0
}
    80004694:	70e2                	ld	ra,56(sp)
    80004696:	7442                	ld	s0,48(sp)
    80004698:	74a2                	ld	s1,40(sp)
    8000469a:	7902                	ld	s2,32(sp)
    8000469c:	69e2                	ld	s3,24(sp)
    8000469e:	6a42                	ld	s4,16(sp)
    800046a0:	6121                	addi	sp,sp,64
    800046a2:	8082                	ret
    iput(ip);
    800046a4:	00000097          	auipc	ra,0x0
    800046a8:	a30080e7          	jalr	-1488(ra) # 800040d4 <iput>
    return -1;
    800046ac:	557d                	li	a0,-1
    800046ae:	b7dd                	j	80004694 <dirlink+0x86>
      panic("dirlink read");
    800046b0:	00004517          	auipc	a0,0x4
    800046b4:	14050513          	addi	a0,a0,320 # 800087f0 <syscallnum+0x188>
    800046b8:	ffffc097          	auipc	ra,0xffffc
    800046bc:	e8c080e7          	jalr	-372(ra) # 80000544 <panic>

00000000800046c0 <namei>:

struct inode*
namei(char *path)
{
    800046c0:	1101                	addi	sp,sp,-32
    800046c2:	ec06                	sd	ra,24(sp)
    800046c4:	e822                	sd	s0,16(sp)
    800046c6:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800046c8:	fe040613          	addi	a2,s0,-32
    800046cc:	4581                	li	a1,0
    800046ce:	00000097          	auipc	ra,0x0
    800046d2:	de0080e7          	jalr	-544(ra) # 800044ae <namex>
}
    800046d6:	60e2                	ld	ra,24(sp)
    800046d8:	6442                	ld	s0,16(sp)
    800046da:	6105                	addi	sp,sp,32
    800046dc:	8082                	ret

00000000800046de <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800046de:	1141                	addi	sp,sp,-16
    800046e0:	e406                	sd	ra,8(sp)
    800046e2:	e022                	sd	s0,0(sp)
    800046e4:	0800                	addi	s0,sp,16
    800046e6:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800046e8:	4585                	li	a1,1
    800046ea:	00000097          	auipc	ra,0x0
    800046ee:	dc4080e7          	jalr	-572(ra) # 800044ae <namex>
}
    800046f2:	60a2                	ld	ra,8(sp)
    800046f4:	6402                	ld	s0,0(sp)
    800046f6:	0141                	addi	sp,sp,16
    800046f8:	8082                	ret

00000000800046fa <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800046fa:	1101                	addi	sp,sp,-32
    800046fc:	ec06                	sd	ra,24(sp)
    800046fe:	e822                	sd	s0,16(sp)
    80004700:	e426                	sd	s1,8(sp)
    80004702:	e04a                	sd	s2,0(sp)
    80004704:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004706:	0001f917          	auipc	s2,0x1f
    8000470a:	8da90913          	addi	s2,s2,-1830 # 80022fe0 <log>
    8000470e:	01892583          	lw	a1,24(s2)
    80004712:	02892503          	lw	a0,40(s2)
    80004716:	fffff097          	auipc	ra,0xfffff
    8000471a:	fea080e7          	jalr	-22(ra) # 80003700 <bread>
    8000471e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004720:	02c92683          	lw	a3,44(s2)
    80004724:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004726:	02d05763          	blez	a3,80004754 <write_head+0x5a>
    8000472a:	0001f797          	auipc	a5,0x1f
    8000472e:	8e678793          	addi	a5,a5,-1818 # 80023010 <log+0x30>
    80004732:	05c50713          	addi	a4,a0,92
    80004736:	36fd                	addiw	a3,a3,-1
    80004738:	1682                	slli	a3,a3,0x20
    8000473a:	9281                	srli	a3,a3,0x20
    8000473c:	068a                	slli	a3,a3,0x2
    8000473e:	0001f617          	auipc	a2,0x1f
    80004742:	8d660613          	addi	a2,a2,-1834 # 80023014 <log+0x34>
    80004746:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004748:	4390                	lw	a2,0(a5)
    8000474a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000474c:	0791                	addi	a5,a5,4
    8000474e:	0711                	addi	a4,a4,4
    80004750:	fed79ce3          	bne	a5,a3,80004748 <write_head+0x4e>
  }
  bwrite(buf);
    80004754:	8526                	mv	a0,s1
    80004756:	fffff097          	auipc	ra,0xfffff
    8000475a:	09c080e7          	jalr	156(ra) # 800037f2 <bwrite>
  brelse(buf);
    8000475e:	8526                	mv	a0,s1
    80004760:	fffff097          	auipc	ra,0xfffff
    80004764:	0d0080e7          	jalr	208(ra) # 80003830 <brelse>
}
    80004768:	60e2                	ld	ra,24(sp)
    8000476a:	6442                	ld	s0,16(sp)
    8000476c:	64a2                	ld	s1,8(sp)
    8000476e:	6902                	ld	s2,0(sp)
    80004770:	6105                	addi	sp,sp,32
    80004772:	8082                	ret

0000000080004774 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004774:	0001f797          	auipc	a5,0x1f
    80004778:	8987a783          	lw	a5,-1896(a5) # 8002300c <log+0x2c>
    8000477c:	0af05d63          	blez	a5,80004836 <install_trans+0xc2>
{
    80004780:	7139                	addi	sp,sp,-64
    80004782:	fc06                	sd	ra,56(sp)
    80004784:	f822                	sd	s0,48(sp)
    80004786:	f426                	sd	s1,40(sp)
    80004788:	f04a                	sd	s2,32(sp)
    8000478a:	ec4e                	sd	s3,24(sp)
    8000478c:	e852                	sd	s4,16(sp)
    8000478e:	e456                	sd	s5,8(sp)
    80004790:	e05a                	sd	s6,0(sp)
    80004792:	0080                	addi	s0,sp,64
    80004794:	8b2a                	mv	s6,a0
    80004796:	0001fa97          	auipc	s5,0x1f
    8000479a:	87aa8a93          	addi	s5,s5,-1926 # 80023010 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000479e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800047a0:	0001f997          	auipc	s3,0x1f
    800047a4:	84098993          	addi	s3,s3,-1984 # 80022fe0 <log>
    800047a8:	a035                	j	800047d4 <install_trans+0x60>
      bunpin(dbuf);
    800047aa:	8526                	mv	a0,s1
    800047ac:	fffff097          	auipc	ra,0xfffff
    800047b0:	15e080e7          	jalr	350(ra) # 8000390a <bunpin>
    brelse(lbuf);
    800047b4:	854a                	mv	a0,s2
    800047b6:	fffff097          	auipc	ra,0xfffff
    800047ba:	07a080e7          	jalr	122(ra) # 80003830 <brelse>
    brelse(dbuf);
    800047be:	8526                	mv	a0,s1
    800047c0:	fffff097          	auipc	ra,0xfffff
    800047c4:	070080e7          	jalr	112(ra) # 80003830 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800047c8:	2a05                	addiw	s4,s4,1
    800047ca:	0a91                	addi	s5,s5,4
    800047cc:	02c9a783          	lw	a5,44(s3)
    800047d0:	04fa5963          	bge	s4,a5,80004822 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800047d4:	0189a583          	lw	a1,24(s3)
    800047d8:	014585bb          	addw	a1,a1,s4
    800047dc:	2585                	addiw	a1,a1,1
    800047de:	0289a503          	lw	a0,40(s3)
    800047e2:	fffff097          	auipc	ra,0xfffff
    800047e6:	f1e080e7          	jalr	-226(ra) # 80003700 <bread>
    800047ea:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800047ec:	000aa583          	lw	a1,0(s5)
    800047f0:	0289a503          	lw	a0,40(s3)
    800047f4:	fffff097          	auipc	ra,0xfffff
    800047f8:	f0c080e7          	jalr	-244(ra) # 80003700 <bread>
    800047fc:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800047fe:	40000613          	li	a2,1024
    80004802:	05890593          	addi	a1,s2,88
    80004806:	05850513          	addi	a0,a0,88
    8000480a:	ffffc097          	auipc	ra,0xffffc
    8000480e:	53c080e7          	jalr	1340(ra) # 80000d46 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004812:	8526                	mv	a0,s1
    80004814:	fffff097          	auipc	ra,0xfffff
    80004818:	fde080e7          	jalr	-34(ra) # 800037f2 <bwrite>
    if(recovering == 0)
    8000481c:	f80b1ce3          	bnez	s6,800047b4 <install_trans+0x40>
    80004820:	b769                	j	800047aa <install_trans+0x36>
}
    80004822:	70e2                	ld	ra,56(sp)
    80004824:	7442                	ld	s0,48(sp)
    80004826:	74a2                	ld	s1,40(sp)
    80004828:	7902                	ld	s2,32(sp)
    8000482a:	69e2                	ld	s3,24(sp)
    8000482c:	6a42                	ld	s4,16(sp)
    8000482e:	6aa2                	ld	s5,8(sp)
    80004830:	6b02                	ld	s6,0(sp)
    80004832:	6121                	addi	sp,sp,64
    80004834:	8082                	ret
    80004836:	8082                	ret

0000000080004838 <initlog>:
{
    80004838:	7179                	addi	sp,sp,-48
    8000483a:	f406                	sd	ra,40(sp)
    8000483c:	f022                	sd	s0,32(sp)
    8000483e:	ec26                	sd	s1,24(sp)
    80004840:	e84a                	sd	s2,16(sp)
    80004842:	e44e                	sd	s3,8(sp)
    80004844:	1800                	addi	s0,sp,48
    80004846:	892a                	mv	s2,a0
    80004848:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000484a:	0001e497          	auipc	s1,0x1e
    8000484e:	79648493          	addi	s1,s1,1942 # 80022fe0 <log>
    80004852:	00004597          	auipc	a1,0x4
    80004856:	fae58593          	addi	a1,a1,-82 # 80008800 <syscallnum+0x198>
    8000485a:	8526                	mv	a0,s1
    8000485c:	ffffc097          	auipc	ra,0xffffc
    80004860:	2fe080e7          	jalr	766(ra) # 80000b5a <initlock>
  log.start = sb->logstart;
    80004864:	0149a583          	lw	a1,20(s3)
    80004868:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000486a:	0109a783          	lw	a5,16(s3)
    8000486e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004870:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004874:	854a                	mv	a0,s2
    80004876:	fffff097          	auipc	ra,0xfffff
    8000487a:	e8a080e7          	jalr	-374(ra) # 80003700 <bread>
  log.lh.n = lh->n;
    8000487e:	4d3c                	lw	a5,88(a0)
    80004880:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004882:	02f05563          	blez	a5,800048ac <initlog+0x74>
    80004886:	05c50713          	addi	a4,a0,92
    8000488a:	0001e697          	auipc	a3,0x1e
    8000488e:	78668693          	addi	a3,a3,1926 # 80023010 <log+0x30>
    80004892:	37fd                	addiw	a5,a5,-1
    80004894:	1782                	slli	a5,a5,0x20
    80004896:	9381                	srli	a5,a5,0x20
    80004898:	078a                	slli	a5,a5,0x2
    8000489a:	06050613          	addi	a2,a0,96
    8000489e:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    800048a0:	4310                	lw	a2,0(a4)
    800048a2:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    800048a4:	0711                	addi	a4,a4,4
    800048a6:	0691                	addi	a3,a3,4
    800048a8:	fef71ce3          	bne	a4,a5,800048a0 <initlog+0x68>
  brelse(buf);
    800048ac:	fffff097          	auipc	ra,0xfffff
    800048b0:	f84080e7          	jalr	-124(ra) # 80003830 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800048b4:	4505                	li	a0,1
    800048b6:	00000097          	auipc	ra,0x0
    800048ba:	ebe080e7          	jalr	-322(ra) # 80004774 <install_trans>
  log.lh.n = 0;
    800048be:	0001e797          	auipc	a5,0x1e
    800048c2:	7407a723          	sw	zero,1870(a5) # 8002300c <log+0x2c>
  write_head(); // clear the log
    800048c6:	00000097          	auipc	ra,0x0
    800048ca:	e34080e7          	jalr	-460(ra) # 800046fa <write_head>
}
    800048ce:	70a2                	ld	ra,40(sp)
    800048d0:	7402                	ld	s0,32(sp)
    800048d2:	64e2                	ld	s1,24(sp)
    800048d4:	6942                	ld	s2,16(sp)
    800048d6:	69a2                	ld	s3,8(sp)
    800048d8:	6145                	addi	sp,sp,48
    800048da:	8082                	ret

00000000800048dc <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800048dc:	1101                	addi	sp,sp,-32
    800048de:	ec06                	sd	ra,24(sp)
    800048e0:	e822                	sd	s0,16(sp)
    800048e2:	e426                	sd	s1,8(sp)
    800048e4:	e04a                	sd	s2,0(sp)
    800048e6:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800048e8:	0001e517          	auipc	a0,0x1e
    800048ec:	6f850513          	addi	a0,a0,1784 # 80022fe0 <log>
    800048f0:	ffffc097          	auipc	ra,0xffffc
    800048f4:	2fa080e7          	jalr	762(ra) # 80000bea <acquire>
  while(1){
    if(log.committing){
    800048f8:	0001e497          	auipc	s1,0x1e
    800048fc:	6e848493          	addi	s1,s1,1768 # 80022fe0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004900:	4979                	li	s2,30
    80004902:	a039                	j	80004910 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004904:	85a6                	mv	a1,s1
    80004906:	8526                	mv	a0,s1
    80004908:	ffffe097          	auipc	ra,0xffffe
    8000490c:	b12080e7          	jalr	-1262(ra) # 8000241a <sleep>
    if(log.committing){
    80004910:	50dc                	lw	a5,36(s1)
    80004912:	fbed                	bnez	a5,80004904 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004914:	509c                	lw	a5,32(s1)
    80004916:	0017871b          	addiw	a4,a5,1
    8000491a:	0007069b          	sext.w	a3,a4
    8000491e:	0027179b          	slliw	a5,a4,0x2
    80004922:	9fb9                	addw	a5,a5,a4
    80004924:	0017979b          	slliw	a5,a5,0x1
    80004928:	54d8                	lw	a4,44(s1)
    8000492a:	9fb9                	addw	a5,a5,a4
    8000492c:	00f95963          	bge	s2,a5,8000493e <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004930:	85a6                	mv	a1,s1
    80004932:	8526                	mv	a0,s1
    80004934:	ffffe097          	auipc	ra,0xffffe
    80004938:	ae6080e7          	jalr	-1306(ra) # 8000241a <sleep>
    8000493c:	bfd1                	j	80004910 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000493e:	0001e517          	auipc	a0,0x1e
    80004942:	6a250513          	addi	a0,a0,1698 # 80022fe0 <log>
    80004946:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004948:	ffffc097          	auipc	ra,0xffffc
    8000494c:	356080e7          	jalr	854(ra) # 80000c9e <release>
      break;
    }
  }
}
    80004950:	60e2                	ld	ra,24(sp)
    80004952:	6442                	ld	s0,16(sp)
    80004954:	64a2                	ld	s1,8(sp)
    80004956:	6902                	ld	s2,0(sp)
    80004958:	6105                	addi	sp,sp,32
    8000495a:	8082                	ret

000000008000495c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000495c:	7139                	addi	sp,sp,-64
    8000495e:	fc06                	sd	ra,56(sp)
    80004960:	f822                	sd	s0,48(sp)
    80004962:	f426                	sd	s1,40(sp)
    80004964:	f04a                	sd	s2,32(sp)
    80004966:	ec4e                	sd	s3,24(sp)
    80004968:	e852                	sd	s4,16(sp)
    8000496a:	e456                	sd	s5,8(sp)
    8000496c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000496e:	0001e497          	auipc	s1,0x1e
    80004972:	67248493          	addi	s1,s1,1650 # 80022fe0 <log>
    80004976:	8526                	mv	a0,s1
    80004978:	ffffc097          	auipc	ra,0xffffc
    8000497c:	272080e7          	jalr	626(ra) # 80000bea <acquire>
  log.outstanding -= 1;
    80004980:	509c                	lw	a5,32(s1)
    80004982:	37fd                	addiw	a5,a5,-1
    80004984:	0007891b          	sext.w	s2,a5
    80004988:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000498a:	50dc                	lw	a5,36(s1)
    8000498c:	efb9                	bnez	a5,800049ea <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000498e:	06091663          	bnez	s2,800049fa <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    80004992:	0001e497          	auipc	s1,0x1e
    80004996:	64e48493          	addi	s1,s1,1614 # 80022fe0 <log>
    8000499a:	4785                	li	a5,1
    8000499c:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000499e:	8526                	mv	a0,s1
    800049a0:	ffffc097          	auipc	ra,0xffffc
    800049a4:	2fe080e7          	jalr	766(ra) # 80000c9e <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800049a8:	54dc                	lw	a5,44(s1)
    800049aa:	06f04763          	bgtz	a5,80004a18 <end_op+0xbc>
    acquire(&log.lock);
    800049ae:	0001e497          	auipc	s1,0x1e
    800049b2:	63248493          	addi	s1,s1,1586 # 80022fe0 <log>
    800049b6:	8526                	mv	a0,s1
    800049b8:	ffffc097          	auipc	ra,0xffffc
    800049bc:	232080e7          	jalr	562(ra) # 80000bea <acquire>
    log.committing = 0;
    800049c0:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800049c4:	8526                	mv	a0,s1
    800049c6:	ffffe097          	auipc	ra,0xffffe
    800049ca:	c04080e7          	jalr	-1020(ra) # 800025ca <wakeup>
    release(&log.lock);
    800049ce:	8526                	mv	a0,s1
    800049d0:	ffffc097          	auipc	ra,0xffffc
    800049d4:	2ce080e7          	jalr	718(ra) # 80000c9e <release>
}
    800049d8:	70e2                	ld	ra,56(sp)
    800049da:	7442                	ld	s0,48(sp)
    800049dc:	74a2                	ld	s1,40(sp)
    800049de:	7902                	ld	s2,32(sp)
    800049e0:	69e2                	ld	s3,24(sp)
    800049e2:	6a42                	ld	s4,16(sp)
    800049e4:	6aa2                	ld	s5,8(sp)
    800049e6:	6121                	addi	sp,sp,64
    800049e8:	8082                	ret
    panic("log.committing");
    800049ea:	00004517          	auipc	a0,0x4
    800049ee:	e1e50513          	addi	a0,a0,-482 # 80008808 <syscallnum+0x1a0>
    800049f2:	ffffc097          	auipc	ra,0xffffc
    800049f6:	b52080e7          	jalr	-1198(ra) # 80000544 <panic>
    wakeup(&log);
    800049fa:	0001e497          	auipc	s1,0x1e
    800049fe:	5e648493          	addi	s1,s1,1510 # 80022fe0 <log>
    80004a02:	8526                	mv	a0,s1
    80004a04:	ffffe097          	auipc	ra,0xffffe
    80004a08:	bc6080e7          	jalr	-1082(ra) # 800025ca <wakeup>
  release(&log.lock);
    80004a0c:	8526                	mv	a0,s1
    80004a0e:	ffffc097          	auipc	ra,0xffffc
    80004a12:	290080e7          	jalr	656(ra) # 80000c9e <release>
  if(do_commit){
    80004a16:	b7c9                	j	800049d8 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004a18:	0001ea97          	auipc	s5,0x1e
    80004a1c:	5f8a8a93          	addi	s5,s5,1528 # 80023010 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004a20:	0001ea17          	auipc	s4,0x1e
    80004a24:	5c0a0a13          	addi	s4,s4,1472 # 80022fe0 <log>
    80004a28:	018a2583          	lw	a1,24(s4)
    80004a2c:	012585bb          	addw	a1,a1,s2
    80004a30:	2585                	addiw	a1,a1,1
    80004a32:	028a2503          	lw	a0,40(s4)
    80004a36:	fffff097          	auipc	ra,0xfffff
    80004a3a:	cca080e7          	jalr	-822(ra) # 80003700 <bread>
    80004a3e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004a40:	000aa583          	lw	a1,0(s5)
    80004a44:	028a2503          	lw	a0,40(s4)
    80004a48:	fffff097          	auipc	ra,0xfffff
    80004a4c:	cb8080e7          	jalr	-840(ra) # 80003700 <bread>
    80004a50:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004a52:	40000613          	li	a2,1024
    80004a56:	05850593          	addi	a1,a0,88
    80004a5a:	05848513          	addi	a0,s1,88
    80004a5e:	ffffc097          	auipc	ra,0xffffc
    80004a62:	2e8080e7          	jalr	744(ra) # 80000d46 <memmove>
    bwrite(to);  // write the log
    80004a66:	8526                	mv	a0,s1
    80004a68:	fffff097          	auipc	ra,0xfffff
    80004a6c:	d8a080e7          	jalr	-630(ra) # 800037f2 <bwrite>
    brelse(from);
    80004a70:	854e                	mv	a0,s3
    80004a72:	fffff097          	auipc	ra,0xfffff
    80004a76:	dbe080e7          	jalr	-578(ra) # 80003830 <brelse>
    brelse(to);
    80004a7a:	8526                	mv	a0,s1
    80004a7c:	fffff097          	auipc	ra,0xfffff
    80004a80:	db4080e7          	jalr	-588(ra) # 80003830 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004a84:	2905                	addiw	s2,s2,1
    80004a86:	0a91                	addi	s5,s5,4
    80004a88:	02ca2783          	lw	a5,44(s4)
    80004a8c:	f8f94ee3          	blt	s2,a5,80004a28 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004a90:	00000097          	auipc	ra,0x0
    80004a94:	c6a080e7          	jalr	-918(ra) # 800046fa <write_head>
    install_trans(0); // Now install writes to home locations
    80004a98:	4501                	li	a0,0
    80004a9a:	00000097          	auipc	ra,0x0
    80004a9e:	cda080e7          	jalr	-806(ra) # 80004774 <install_trans>
    log.lh.n = 0;
    80004aa2:	0001e797          	auipc	a5,0x1e
    80004aa6:	5607a523          	sw	zero,1386(a5) # 8002300c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004aaa:	00000097          	auipc	ra,0x0
    80004aae:	c50080e7          	jalr	-944(ra) # 800046fa <write_head>
    80004ab2:	bdf5                	j	800049ae <end_op+0x52>

0000000080004ab4 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004ab4:	1101                	addi	sp,sp,-32
    80004ab6:	ec06                	sd	ra,24(sp)
    80004ab8:	e822                	sd	s0,16(sp)
    80004aba:	e426                	sd	s1,8(sp)
    80004abc:	e04a                	sd	s2,0(sp)
    80004abe:	1000                	addi	s0,sp,32
    80004ac0:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004ac2:	0001e917          	auipc	s2,0x1e
    80004ac6:	51e90913          	addi	s2,s2,1310 # 80022fe0 <log>
    80004aca:	854a                	mv	a0,s2
    80004acc:	ffffc097          	auipc	ra,0xffffc
    80004ad0:	11e080e7          	jalr	286(ra) # 80000bea <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004ad4:	02c92603          	lw	a2,44(s2)
    80004ad8:	47f5                	li	a5,29
    80004ada:	06c7c563          	blt	a5,a2,80004b44 <log_write+0x90>
    80004ade:	0001e797          	auipc	a5,0x1e
    80004ae2:	51e7a783          	lw	a5,1310(a5) # 80022ffc <log+0x1c>
    80004ae6:	37fd                	addiw	a5,a5,-1
    80004ae8:	04f65e63          	bge	a2,a5,80004b44 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004aec:	0001e797          	auipc	a5,0x1e
    80004af0:	5147a783          	lw	a5,1300(a5) # 80023000 <log+0x20>
    80004af4:	06f05063          	blez	a5,80004b54 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004af8:	4781                	li	a5,0
    80004afa:	06c05563          	blez	a2,80004b64 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004afe:	44cc                	lw	a1,12(s1)
    80004b00:	0001e717          	auipc	a4,0x1e
    80004b04:	51070713          	addi	a4,a4,1296 # 80023010 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004b08:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004b0a:	4314                	lw	a3,0(a4)
    80004b0c:	04b68c63          	beq	a3,a1,80004b64 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004b10:	2785                	addiw	a5,a5,1
    80004b12:	0711                	addi	a4,a4,4
    80004b14:	fef61be3          	bne	a2,a5,80004b0a <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004b18:	0621                	addi	a2,a2,8
    80004b1a:	060a                	slli	a2,a2,0x2
    80004b1c:	0001e797          	auipc	a5,0x1e
    80004b20:	4c478793          	addi	a5,a5,1220 # 80022fe0 <log>
    80004b24:	963e                	add	a2,a2,a5
    80004b26:	44dc                	lw	a5,12(s1)
    80004b28:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004b2a:	8526                	mv	a0,s1
    80004b2c:	fffff097          	auipc	ra,0xfffff
    80004b30:	da2080e7          	jalr	-606(ra) # 800038ce <bpin>
    log.lh.n++;
    80004b34:	0001e717          	auipc	a4,0x1e
    80004b38:	4ac70713          	addi	a4,a4,1196 # 80022fe0 <log>
    80004b3c:	575c                	lw	a5,44(a4)
    80004b3e:	2785                	addiw	a5,a5,1
    80004b40:	d75c                	sw	a5,44(a4)
    80004b42:	a835                	j	80004b7e <log_write+0xca>
    panic("too big a transaction");
    80004b44:	00004517          	auipc	a0,0x4
    80004b48:	cd450513          	addi	a0,a0,-812 # 80008818 <syscallnum+0x1b0>
    80004b4c:	ffffc097          	auipc	ra,0xffffc
    80004b50:	9f8080e7          	jalr	-1544(ra) # 80000544 <panic>
    panic("log_write outside of trans");
    80004b54:	00004517          	auipc	a0,0x4
    80004b58:	cdc50513          	addi	a0,a0,-804 # 80008830 <syscallnum+0x1c8>
    80004b5c:	ffffc097          	auipc	ra,0xffffc
    80004b60:	9e8080e7          	jalr	-1560(ra) # 80000544 <panic>
  log.lh.block[i] = b->blockno;
    80004b64:	00878713          	addi	a4,a5,8
    80004b68:	00271693          	slli	a3,a4,0x2
    80004b6c:	0001e717          	auipc	a4,0x1e
    80004b70:	47470713          	addi	a4,a4,1140 # 80022fe0 <log>
    80004b74:	9736                	add	a4,a4,a3
    80004b76:	44d4                	lw	a3,12(s1)
    80004b78:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004b7a:	faf608e3          	beq	a2,a5,80004b2a <log_write+0x76>
  }
  release(&log.lock);
    80004b7e:	0001e517          	auipc	a0,0x1e
    80004b82:	46250513          	addi	a0,a0,1122 # 80022fe0 <log>
    80004b86:	ffffc097          	auipc	ra,0xffffc
    80004b8a:	118080e7          	jalr	280(ra) # 80000c9e <release>
}
    80004b8e:	60e2                	ld	ra,24(sp)
    80004b90:	6442                	ld	s0,16(sp)
    80004b92:	64a2                	ld	s1,8(sp)
    80004b94:	6902                	ld	s2,0(sp)
    80004b96:	6105                	addi	sp,sp,32
    80004b98:	8082                	ret

0000000080004b9a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004b9a:	1101                	addi	sp,sp,-32
    80004b9c:	ec06                	sd	ra,24(sp)
    80004b9e:	e822                	sd	s0,16(sp)
    80004ba0:	e426                	sd	s1,8(sp)
    80004ba2:	e04a                	sd	s2,0(sp)
    80004ba4:	1000                	addi	s0,sp,32
    80004ba6:	84aa                	mv	s1,a0
    80004ba8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004baa:	00004597          	auipc	a1,0x4
    80004bae:	ca658593          	addi	a1,a1,-858 # 80008850 <syscallnum+0x1e8>
    80004bb2:	0521                	addi	a0,a0,8
    80004bb4:	ffffc097          	auipc	ra,0xffffc
    80004bb8:	fa6080e7          	jalr	-90(ra) # 80000b5a <initlock>
  lk->name = name;
    80004bbc:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004bc0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004bc4:	0204a423          	sw	zero,40(s1)
}
    80004bc8:	60e2                	ld	ra,24(sp)
    80004bca:	6442                	ld	s0,16(sp)
    80004bcc:	64a2                	ld	s1,8(sp)
    80004bce:	6902                	ld	s2,0(sp)
    80004bd0:	6105                	addi	sp,sp,32
    80004bd2:	8082                	ret

0000000080004bd4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004bd4:	1101                	addi	sp,sp,-32
    80004bd6:	ec06                	sd	ra,24(sp)
    80004bd8:	e822                	sd	s0,16(sp)
    80004bda:	e426                	sd	s1,8(sp)
    80004bdc:	e04a                	sd	s2,0(sp)
    80004bde:	1000                	addi	s0,sp,32
    80004be0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004be2:	00850913          	addi	s2,a0,8
    80004be6:	854a                	mv	a0,s2
    80004be8:	ffffc097          	auipc	ra,0xffffc
    80004bec:	002080e7          	jalr	2(ra) # 80000bea <acquire>
  while (lk->locked) {
    80004bf0:	409c                	lw	a5,0(s1)
    80004bf2:	cb89                	beqz	a5,80004c04 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004bf4:	85ca                	mv	a1,s2
    80004bf6:	8526                	mv	a0,s1
    80004bf8:	ffffe097          	auipc	ra,0xffffe
    80004bfc:	822080e7          	jalr	-2014(ra) # 8000241a <sleep>
  while (lk->locked) {
    80004c00:	409c                	lw	a5,0(s1)
    80004c02:	fbed                	bnez	a5,80004bf4 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004c04:	4785                	li	a5,1
    80004c06:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004c08:	ffffd097          	auipc	ra,0xffffd
    80004c0c:	dbe080e7          	jalr	-578(ra) # 800019c6 <myproc>
    80004c10:	591c                	lw	a5,48(a0)
    80004c12:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004c14:	854a                	mv	a0,s2
    80004c16:	ffffc097          	auipc	ra,0xffffc
    80004c1a:	088080e7          	jalr	136(ra) # 80000c9e <release>
}
    80004c1e:	60e2                	ld	ra,24(sp)
    80004c20:	6442                	ld	s0,16(sp)
    80004c22:	64a2                	ld	s1,8(sp)
    80004c24:	6902                	ld	s2,0(sp)
    80004c26:	6105                	addi	sp,sp,32
    80004c28:	8082                	ret

0000000080004c2a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004c2a:	1101                	addi	sp,sp,-32
    80004c2c:	ec06                	sd	ra,24(sp)
    80004c2e:	e822                	sd	s0,16(sp)
    80004c30:	e426                	sd	s1,8(sp)
    80004c32:	e04a                	sd	s2,0(sp)
    80004c34:	1000                	addi	s0,sp,32
    80004c36:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004c38:	00850913          	addi	s2,a0,8
    80004c3c:	854a                	mv	a0,s2
    80004c3e:	ffffc097          	auipc	ra,0xffffc
    80004c42:	fac080e7          	jalr	-84(ra) # 80000bea <acquire>
  lk->locked = 0;
    80004c46:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004c4a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004c4e:	8526                	mv	a0,s1
    80004c50:	ffffe097          	auipc	ra,0xffffe
    80004c54:	97a080e7          	jalr	-1670(ra) # 800025ca <wakeup>
  release(&lk->lk);
    80004c58:	854a                	mv	a0,s2
    80004c5a:	ffffc097          	auipc	ra,0xffffc
    80004c5e:	044080e7          	jalr	68(ra) # 80000c9e <release>
}
    80004c62:	60e2                	ld	ra,24(sp)
    80004c64:	6442                	ld	s0,16(sp)
    80004c66:	64a2                	ld	s1,8(sp)
    80004c68:	6902                	ld	s2,0(sp)
    80004c6a:	6105                	addi	sp,sp,32
    80004c6c:	8082                	ret

0000000080004c6e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004c6e:	7179                	addi	sp,sp,-48
    80004c70:	f406                	sd	ra,40(sp)
    80004c72:	f022                	sd	s0,32(sp)
    80004c74:	ec26                	sd	s1,24(sp)
    80004c76:	e84a                	sd	s2,16(sp)
    80004c78:	e44e                	sd	s3,8(sp)
    80004c7a:	1800                	addi	s0,sp,48
    80004c7c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004c7e:	00850913          	addi	s2,a0,8
    80004c82:	854a                	mv	a0,s2
    80004c84:	ffffc097          	auipc	ra,0xffffc
    80004c88:	f66080e7          	jalr	-154(ra) # 80000bea <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004c8c:	409c                	lw	a5,0(s1)
    80004c8e:	ef99                	bnez	a5,80004cac <holdingsleep+0x3e>
    80004c90:	4481                	li	s1,0
  release(&lk->lk);
    80004c92:	854a                	mv	a0,s2
    80004c94:	ffffc097          	auipc	ra,0xffffc
    80004c98:	00a080e7          	jalr	10(ra) # 80000c9e <release>
  return r;
}
    80004c9c:	8526                	mv	a0,s1
    80004c9e:	70a2                	ld	ra,40(sp)
    80004ca0:	7402                	ld	s0,32(sp)
    80004ca2:	64e2                	ld	s1,24(sp)
    80004ca4:	6942                	ld	s2,16(sp)
    80004ca6:	69a2                	ld	s3,8(sp)
    80004ca8:	6145                	addi	sp,sp,48
    80004caa:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004cac:	0284a983          	lw	s3,40(s1)
    80004cb0:	ffffd097          	auipc	ra,0xffffd
    80004cb4:	d16080e7          	jalr	-746(ra) # 800019c6 <myproc>
    80004cb8:	5904                	lw	s1,48(a0)
    80004cba:	413484b3          	sub	s1,s1,s3
    80004cbe:	0014b493          	seqz	s1,s1
    80004cc2:	bfc1                	j	80004c92 <holdingsleep+0x24>

0000000080004cc4 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004cc4:	1141                	addi	sp,sp,-16
    80004cc6:	e406                	sd	ra,8(sp)
    80004cc8:	e022                	sd	s0,0(sp)
    80004cca:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004ccc:	00004597          	auipc	a1,0x4
    80004cd0:	b9458593          	addi	a1,a1,-1132 # 80008860 <syscallnum+0x1f8>
    80004cd4:	0001e517          	auipc	a0,0x1e
    80004cd8:	45450513          	addi	a0,a0,1108 # 80023128 <ftable>
    80004cdc:	ffffc097          	auipc	ra,0xffffc
    80004ce0:	e7e080e7          	jalr	-386(ra) # 80000b5a <initlock>
}
    80004ce4:	60a2                	ld	ra,8(sp)
    80004ce6:	6402                	ld	s0,0(sp)
    80004ce8:	0141                	addi	sp,sp,16
    80004cea:	8082                	ret

0000000080004cec <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004cec:	1101                	addi	sp,sp,-32
    80004cee:	ec06                	sd	ra,24(sp)
    80004cf0:	e822                	sd	s0,16(sp)
    80004cf2:	e426                	sd	s1,8(sp)
    80004cf4:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004cf6:	0001e517          	auipc	a0,0x1e
    80004cfa:	43250513          	addi	a0,a0,1074 # 80023128 <ftable>
    80004cfe:	ffffc097          	auipc	ra,0xffffc
    80004d02:	eec080e7          	jalr	-276(ra) # 80000bea <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004d06:	0001e497          	auipc	s1,0x1e
    80004d0a:	43a48493          	addi	s1,s1,1082 # 80023140 <ftable+0x18>
    80004d0e:	0001f717          	auipc	a4,0x1f
    80004d12:	3d270713          	addi	a4,a4,978 # 800240e0 <disk>
    if(f->ref == 0){
    80004d16:	40dc                	lw	a5,4(s1)
    80004d18:	cf99                	beqz	a5,80004d36 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004d1a:	02848493          	addi	s1,s1,40
    80004d1e:	fee49ce3          	bne	s1,a4,80004d16 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004d22:	0001e517          	auipc	a0,0x1e
    80004d26:	40650513          	addi	a0,a0,1030 # 80023128 <ftable>
    80004d2a:	ffffc097          	auipc	ra,0xffffc
    80004d2e:	f74080e7          	jalr	-140(ra) # 80000c9e <release>
  return 0;
    80004d32:	4481                	li	s1,0
    80004d34:	a819                	j	80004d4a <filealloc+0x5e>
      f->ref = 1;
    80004d36:	4785                	li	a5,1
    80004d38:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004d3a:	0001e517          	auipc	a0,0x1e
    80004d3e:	3ee50513          	addi	a0,a0,1006 # 80023128 <ftable>
    80004d42:	ffffc097          	auipc	ra,0xffffc
    80004d46:	f5c080e7          	jalr	-164(ra) # 80000c9e <release>
}
    80004d4a:	8526                	mv	a0,s1
    80004d4c:	60e2                	ld	ra,24(sp)
    80004d4e:	6442                	ld	s0,16(sp)
    80004d50:	64a2                	ld	s1,8(sp)
    80004d52:	6105                	addi	sp,sp,32
    80004d54:	8082                	ret

0000000080004d56 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004d56:	1101                	addi	sp,sp,-32
    80004d58:	ec06                	sd	ra,24(sp)
    80004d5a:	e822                	sd	s0,16(sp)
    80004d5c:	e426                	sd	s1,8(sp)
    80004d5e:	1000                	addi	s0,sp,32
    80004d60:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004d62:	0001e517          	auipc	a0,0x1e
    80004d66:	3c650513          	addi	a0,a0,966 # 80023128 <ftable>
    80004d6a:	ffffc097          	auipc	ra,0xffffc
    80004d6e:	e80080e7          	jalr	-384(ra) # 80000bea <acquire>
  if(f->ref < 1)
    80004d72:	40dc                	lw	a5,4(s1)
    80004d74:	02f05263          	blez	a5,80004d98 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004d78:	2785                	addiw	a5,a5,1
    80004d7a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004d7c:	0001e517          	auipc	a0,0x1e
    80004d80:	3ac50513          	addi	a0,a0,940 # 80023128 <ftable>
    80004d84:	ffffc097          	auipc	ra,0xffffc
    80004d88:	f1a080e7          	jalr	-230(ra) # 80000c9e <release>
  return f;
}
    80004d8c:	8526                	mv	a0,s1
    80004d8e:	60e2                	ld	ra,24(sp)
    80004d90:	6442                	ld	s0,16(sp)
    80004d92:	64a2                	ld	s1,8(sp)
    80004d94:	6105                	addi	sp,sp,32
    80004d96:	8082                	ret
    panic("filedup");
    80004d98:	00004517          	auipc	a0,0x4
    80004d9c:	ad050513          	addi	a0,a0,-1328 # 80008868 <syscallnum+0x200>
    80004da0:	ffffb097          	auipc	ra,0xffffb
    80004da4:	7a4080e7          	jalr	1956(ra) # 80000544 <panic>

0000000080004da8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004da8:	7139                	addi	sp,sp,-64
    80004daa:	fc06                	sd	ra,56(sp)
    80004dac:	f822                	sd	s0,48(sp)
    80004dae:	f426                	sd	s1,40(sp)
    80004db0:	f04a                	sd	s2,32(sp)
    80004db2:	ec4e                	sd	s3,24(sp)
    80004db4:	e852                	sd	s4,16(sp)
    80004db6:	e456                	sd	s5,8(sp)
    80004db8:	0080                	addi	s0,sp,64
    80004dba:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004dbc:	0001e517          	auipc	a0,0x1e
    80004dc0:	36c50513          	addi	a0,a0,876 # 80023128 <ftable>
    80004dc4:	ffffc097          	auipc	ra,0xffffc
    80004dc8:	e26080e7          	jalr	-474(ra) # 80000bea <acquire>
  if(f->ref < 1)
    80004dcc:	40dc                	lw	a5,4(s1)
    80004dce:	06f05163          	blez	a5,80004e30 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004dd2:	37fd                	addiw	a5,a5,-1
    80004dd4:	0007871b          	sext.w	a4,a5
    80004dd8:	c0dc                	sw	a5,4(s1)
    80004dda:	06e04363          	bgtz	a4,80004e40 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004dde:	0004a903          	lw	s2,0(s1)
    80004de2:	0094ca83          	lbu	s5,9(s1)
    80004de6:	0104ba03          	ld	s4,16(s1)
    80004dea:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004dee:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004df2:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004df6:	0001e517          	auipc	a0,0x1e
    80004dfa:	33250513          	addi	a0,a0,818 # 80023128 <ftable>
    80004dfe:	ffffc097          	auipc	ra,0xffffc
    80004e02:	ea0080e7          	jalr	-352(ra) # 80000c9e <release>

  if(ff.type == FD_PIPE){
    80004e06:	4785                	li	a5,1
    80004e08:	04f90d63          	beq	s2,a5,80004e62 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004e0c:	3979                	addiw	s2,s2,-2
    80004e0e:	4785                	li	a5,1
    80004e10:	0527e063          	bltu	a5,s2,80004e50 <fileclose+0xa8>
    begin_op();
    80004e14:	00000097          	auipc	ra,0x0
    80004e18:	ac8080e7          	jalr	-1336(ra) # 800048dc <begin_op>
    iput(ff.ip);
    80004e1c:	854e                	mv	a0,s3
    80004e1e:	fffff097          	auipc	ra,0xfffff
    80004e22:	2b6080e7          	jalr	694(ra) # 800040d4 <iput>
    end_op();
    80004e26:	00000097          	auipc	ra,0x0
    80004e2a:	b36080e7          	jalr	-1226(ra) # 8000495c <end_op>
    80004e2e:	a00d                	j	80004e50 <fileclose+0xa8>
    panic("fileclose");
    80004e30:	00004517          	auipc	a0,0x4
    80004e34:	a4050513          	addi	a0,a0,-1472 # 80008870 <syscallnum+0x208>
    80004e38:	ffffb097          	auipc	ra,0xffffb
    80004e3c:	70c080e7          	jalr	1804(ra) # 80000544 <panic>
    release(&ftable.lock);
    80004e40:	0001e517          	auipc	a0,0x1e
    80004e44:	2e850513          	addi	a0,a0,744 # 80023128 <ftable>
    80004e48:	ffffc097          	auipc	ra,0xffffc
    80004e4c:	e56080e7          	jalr	-426(ra) # 80000c9e <release>
  }
}
    80004e50:	70e2                	ld	ra,56(sp)
    80004e52:	7442                	ld	s0,48(sp)
    80004e54:	74a2                	ld	s1,40(sp)
    80004e56:	7902                	ld	s2,32(sp)
    80004e58:	69e2                	ld	s3,24(sp)
    80004e5a:	6a42                	ld	s4,16(sp)
    80004e5c:	6aa2                	ld	s5,8(sp)
    80004e5e:	6121                	addi	sp,sp,64
    80004e60:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004e62:	85d6                	mv	a1,s5
    80004e64:	8552                	mv	a0,s4
    80004e66:	00000097          	auipc	ra,0x0
    80004e6a:	34c080e7          	jalr	844(ra) # 800051b2 <pipeclose>
    80004e6e:	b7cd                	j	80004e50 <fileclose+0xa8>

0000000080004e70 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004e70:	715d                	addi	sp,sp,-80
    80004e72:	e486                	sd	ra,72(sp)
    80004e74:	e0a2                	sd	s0,64(sp)
    80004e76:	fc26                	sd	s1,56(sp)
    80004e78:	f84a                	sd	s2,48(sp)
    80004e7a:	f44e                	sd	s3,40(sp)
    80004e7c:	0880                	addi	s0,sp,80
    80004e7e:	84aa                	mv	s1,a0
    80004e80:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004e82:	ffffd097          	auipc	ra,0xffffd
    80004e86:	b44080e7          	jalr	-1212(ra) # 800019c6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004e8a:	409c                	lw	a5,0(s1)
    80004e8c:	37f9                	addiw	a5,a5,-2
    80004e8e:	4705                	li	a4,1
    80004e90:	04f76763          	bltu	a4,a5,80004ede <filestat+0x6e>
    80004e94:	892a                	mv	s2,a0
    ilock(f->ip);
    80004e96:	6c88                	ld	a0,24(s1)
    80004e98:	fffff097          	auipc	ra,0xfffff
    80004e9c:	082080e7          	jalr	130(ra) # 80003f1a <ilock>
    stati(f->ip, &st);
    80004ea0:	fb840593          	addi	a1,s0,-72
    80004ea4:	6c88                	ld	a0,24(s1)
    80004ea6:	fffff097          	auipc	ra,0xfffff
    80004eaa:	2fe080e7          	jalr	766(ra) # 800041a4 <stati>
    iunlock(f->ip);
    80004eae:	6c88                	ld	a0,24(s1)
    80004eb0:	fffff097          	auipc	ra,0xfffff
    80004eb4:	12c080e7          	jalr	300(ra) # 80003fdc <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004eb8:	46e1                	li	a3,24
    80004eba:	fb840613          	addi	a2,s0,-72
    80004ebe:	85ce                	mv	a1,s3
    80004ec0:	05093503          	ld	a0,80(s2)
    80004ec4:	ffffc097          	auipc	ra,0xffffc
    80004ec8:	7c0080e7          	jalr	1984(ra) # 80001684 <copyout>
    80004ecc:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004ed0:	60a6                	ld	ra,72(sp)
    80004ed2:	6406                	ld	s0,64(sp)
    80004ed4:	74e2                	ld	s1,56(sp)
    80004ed6:	7942                	ld	s2,48(sp)
    80004ed8:	79a2                	ld	s3,40(sp)
    80004eda:	6161                	addi	sp,sp,80
    80004edc:	8082                	ret
  return -1;
    80004ede:	557d                	li	a0,-1
    80004ee0:	bfc5                	j	80004ed0 <filestat+0x60>

0000000080004ee2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004ee2:	7179                	addi	sp,sp,-48
    80004ee4:	f406                	sd	ra,40(sp)
    80004ee6:	f022                	sd	s0,32(sp)
    80004ee8:	ec26                	sd	s1,24(sp)
    80004eea:	e84a                	sd	s2,16(sp)
    80004eec:	e44e                	sd	s3,8(sp)
    80004eee:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004ef0:	00854783          	lbu	a5,8(a0)
    80004ef4:	c3d5                	beqz	a5,80004f98 <fileread+0xb6>
    80004ef6:	84aa                	mv	s1,a0
    80004ef8:	89ae                	mv	s3,a1
    80004efa:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004efc:	411c                	lw	a5,0(a0)
    80004efe:	4705                	li	a4,1
    80004f00:	04e78963          	beq	a5,a4,80004f52 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004f04:	470d                	li	a4,3
    80004f06:	04e78d63          	beq	a5,a4,80004f60 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004f0a:	4709                	li	a4,2
    80004f0c:	06e79e63          	bne	a5,a4,80004f88 <fileread+0xa6>
    ilock(f->ip);
    80004f10:	6d08                	ld	a0,24(a0)
    80004f12:	fffff097          	auipc	ra,0xfffff
    80004f16:	008080e7          	jalr	8(ra) # 80003f1a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004f1a:	874a                	mv	a4,s2
    80004f1c:	5094                	lw	a3,32(s1)
    80004f1e:	864e                	mv	a2,s3
    80004f20:	4585                	li	a1,1
    80004f22:	6c88                	ld	a0,24(s1)
    80004f24:	fffff097          	auipc	ra,0xfffff
    80004f28:	2aa080e7          	jalr	682(ra) # 800041ce <readi>
    80004f2c:	892a                	mv	s2,a0
    80004f2e:	00a05563          	blez	a0,80004f38 <fileread+0x56>
      f->off += r;
    80004f32:	509c                	lw	a5,32(s1)
    80004f34:	9fa9                	addw	a5,a5,a0
    80004f36:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004f38:	6c88                	ld	a0,24(s1)
    80004f3a:	fffff097          	auipc	ra,0xfffff
    80004f3e:	0a2080e7          	jalr	162(ra) # 80003fdc <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004f42:	854a                	mv	a0,s2
    80004f44:	70a2                	ld	ra,40(sp)
    80004f46:	7402                	ld	s0,32(sp)
    80004f48:	64e2                	ld	s1,24(sp)
    80004f4a:	6942                	ld	s2,16(sp)
    80004f4c:	69a2                	ld	s3,8(sp)
    80004f4e:	6145                	addi	sp,sp,48
    80004f50:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004f52:	6908                	ld	a0,16(a0)
    80004f54:	00000097          	auipc	ra,0x0
    80004f58:	3ce080e7          	jalr	974(ra) # 80005322 <piperead>
    80004f5c:	892a                	mv	s2,a0
    80004f5e:	b7d5                	j	80004f42 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004f60:	02451783          	lh	a5,36(a0)
    80004f64:	03079693          	slli	a3,a5,0x30
    80004f68:	92c1                	srli	a3,a3,0x30
    80004f6a:	4725                	li	a4,9
    80004f6c:	02d76863          	bltu	a4,a3,80004f9c <fileread+0xba>
    80004f70:	0792                	slli	a5,a5,0x4
    80004f72:	0001e717          	auipc	a4,0x1e
    80004f76:	11670713          	addi	a4,a4,278 # 80023088 <devsw>
    80004f7a:	97ba                	add	a5,a5,a4
    80004f7c:	639c                	ld	a5,0(a5)
    80004f7e:	c38d                	beqz	a5,80004fa0 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004f80:	4505                	li	a0,1
    80004f82:	9782                	jalr	a5
    80004f84:	892a                	mv	s2,a0
    80004f86:	bf75                	j	80004f42 <fileread+0x60>
    panic("fileread");
    80004f88:	00004517          	auipc	a0,0x4
    80004f8c:	8f850513          	addi	a0,a0,-1800 # 80008880 <syscallnum+0x218>
    80004f90:	ffffb097          	auipc	ra,0xffffb
    80004f94:	5b4080e7          	jalr	1460(ra) # 80000544 <panic>
    return -1;
    80004f98:	597d                	li	s2,-1
    80004f9a:	b765                	j	80004f42 <fileread+0x60>
      return -1;
    80004f9c:	597d                	li	s2,-1
    80004f9e:	b755                	j	80004f42 <fileread+0x60>
    80004fa0:	597d                	li	s2,-1
    80004fa2:	b745                	j	80004f42 <fileread+0x60>

0000000080004fa4 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004fa4:	715d                	addi	sp,sp,-80
    80004fa6:	e486                	sd	ra,72(sp)
    80004fa8:	e0a2                	sd	s0,64(sp)
    80004faa:	fc26                	sd	s1,56(sp)
    80004fac:	f84a                	sd	s2,48(sp)
    80004fae:	f44e                	sd	s3,40(sp)
    80004fb0:	f052                	sd	s4,32(sp)
    80004fb2:	ec56                	sd	s5,24(sp)
    80004fb4:	e85a                	sd	s6,16(sp)
    80004fb6:	e45e                	sd	s7,8(sp)
    80004fb8:	e062                	sd	s8,0(sp)
    80004fba:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004fbc:	00954783          	lbu	a5,9(a0)
    80004fc0:	10078663          	beqz	a5,800050cc <filewrite+0x128>
    80004fc4:	892a                	mv	s2,a0
    80004fc6:	8aae                	mv	s5,a1
    80004fc8:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004fca:	411c                	lw	a5,0(a0)
    80004fcc:	4705                	li	a4,1
    80004fce:	02e78263          	beq	a5,a4,80004ff2 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004fd2:	470d                	li	a4,3
    80004fd4:	02e78663          	beq	a5,a4,80005000 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004fd8:	4709                	li	a4,2
    80004fda:	0ee79163          	bne	a5,a4,800050bc <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004fde:	0ac05d63          	blez	a2,80005098 <filewrite+0xf4>
    int i = 0;
    80004fe2:	4981                	li	s3,0
    80004fe4:	6b05                	lui	s6,0x1
    80004fe6:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004fea:	6b85                	lui	s7,0x1
    80004fec:	c00b8b9b          	addiw	s7,s7,-1024
    80004ff0:	a861                	j	80005088 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004ff2:	6908                	ld	a0,16(a0)
    80004ff4:	00000097          	auipc	ra,0x0
    80004ff8:	22e080e7          	jalr	558(ra) # 80005222 <pipewrite>
    80004ffc:	8a2a                	mv	s4,a0
    80004ffe:	a045                	j	8000509e <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005000:	02451783          	lh	a5,36(a0)
    80005004:	03079693          	slli	a3,a5,0x30
    80005008:	92c1                	srli	a3,a3,0x30
    8000500a:	4725                	li	a4,9
    8000500c:	0cd76263          	bltu	a4,a3,800050d0 <filewrite+0x12c>
    80005010:	0792                	slli	a5,a5,0x4
    80005012:	0001e717          	auipc	a4,0x1e
    80005016:	07670713          	addi	a4,a4,118 # 80023088 <devsw>
    8000501a:	97ba                	add	a5,a5,a4
    8000501c:	679c                	ld	a5,8(a5)
    8000501e:	cbdd                	beqz	a5,800050d4 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80005020:	4505                	li	a0,1
    80005022:	9782                	jalr	a5
    80005024:	8a2a                	mv	s4,a0
    80005026:	a8a5                	j	8000509e <filewrite+0xfa>
    80005028:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    8000502c:	00000097          	auipc	ra,0x0
    80005030:	8b0080e7          	jalr	-1872(ra) # 800048dc <begin_op>
      ilock(f->ip);
    80005034:	01893503          	ld	a0,24(s2)
    80005038:	fffff097          	auipc	ra,0xfffff
    8000503c:	ee2080e7          	jalr	-286(ra) # 80003f1a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80005040:	8762                	mv	a4,s8
    80005042:	02092683          	lw	a3,32(s2)
    80005046:	01598633          	add	a2,s3,s5
    8000504a:	4585                	li	a1,1
    8000504c:	01893503          	ld	a0,24(s2)
    80005050:	fffff097          	auipc	ra,0xfffff
    80005054:	276080e7          	jalr	630(ra) # 800042c6 <writei>
    80005058:	84aa                	mv	s1,a0
    8000505a:	00a05763          	blez	a0,80005068 <filewrite+0xc4>
        f->off += r;
    8000505e:	02092783          	lw	a5,32(s2)
    80005062:	9fa9                	addw	a5,a5,a0
    80005064:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80005068:	01893503          	ld	a0,24(s2)
    8000506c:	fffff097          	auipc	ra,0xfffff
    80005070:	f70080e7          	jalr	-144(ra) # 80003fdc <iunlock>
      end_op();
    80005074:	00000097          	auipc	ra,0x0
    80005078:	8e8080e7          	jalr	-1816(ra) # 8000495c <end_op>

      if(r != n1){
    8000507c:	009c1f63          	bne	s8,s1,8000509a <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80005080:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80005084:	0149db63          	bge	s3,s4,8000509a <filewrite+0xf6>
      int n1 = n - i;
    80005088:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    8000508c:	84be                	mv	s1,a5
    8000508e:	2781                	sext.w	a5,a5
    80005090:	f8fb5ce3          	bge	s6,a5,80005028 <filewrite+0x84>
    80005094:	84de                	mv	s1,s7
    80005096:	bf49                	j	80005028 <filewrite+0x84>
    int i = 0;
    80005098:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    8000509a:	013a1f63          	bne	s4,s3,800050b8 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000509e:	8552                	mv	a0,s4
    800050a0:	60a6                	ld	ra,72(sp)
    800050a2:	6406                	ld	s0,64(sp)
    800050a4:	74e2                	ld	s1,56(sp)
    800050a6:	7942                	ld	s2,48(sp)
    800050a8:	79a2                	ld	s3,40(sp)
    800050aa:	7a02                	ld	s4,32(sp)
    800050ac:	6ae2                	ld	s5,24(sp)
    800050ae:	6b42                	ld	s6,16(sp)
    800050b0:	6ba2                	ld	s7,8(sp)
    800050b2:	6c02                	ld	s8,0(sp)
    800050b4:	6161                	addi	sp,sp,80
    800050b6:	8082                	ret
    ret = (i == n ? n : -1);
    800050b8:	5a7d                	li	s4,-1
    800050ba:	b7d5                	j	8000509e <filewrite+0xfa>
    panic("filewrite");
    800050bc:	00003517          	auipc	a0,0x3
    800050c0:	7d450513          	addi	a0,a0,2004 # 80008890 <syscallnum+0x228>
    800050c4:	ffffb097          	auipc	ra,0xffffb
    800050c8:	480080e7          	jalr	1152(ra) # 80000544 <panic>
    return -1;
    800050cc:	5a7d                	li	s4,-1
    800050ce:	bfc1                	j	8000509e <filewrite+0xfa>
      return -1;
    800050d0:	5a7d                	li	s4,-1
    800050d2:	b7f1                	j	8000509e <filewrite+0xfa>
    800050d4:	5a7d                	li	s4,-1
    800050d6:	b7e1                	j	8000509e <filewrite+0xfa>

00000000800050d8 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800050d8:	7179                	addi	sp,sp,-48
    800050da:	f406                	sd	ra,40(sp)
    800050dc:	f022                	sd	s0,32(sp)
    800050de:	ec26                	sd	s1,24(sp)
    800050e0:	e84a                	sd	s2,16(sp)
    800050e2:	e44e                	sd	s3,8(sp)
    800050e4:	e052                	sd	s4,0(sp)
    800050e6:	1800                	addi	s0,sp,48
    800050e8:	84aa                	mv	s1,a0
    800050ea:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800050ec:	0005b023          	sd	zero,0(a1)
    800050f0:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800050f4:	00000097          	auipc	ra,0x0
    800050f8:	bf8080e7          	jalr	-1032(ra) # 80004cec <filealloc>
    800050fc:	e088                	sd	a0,0(s1)
    800050fe:	c551                	beqz	a0,8000518a <pipealloc+0xb2>
    80005100:	00000097          	auipc	ra,0x0
    80005104:	bec080e7          	jalr	-1044(ra) # 80004cec <filealloc>
    80005108:	00aa3023          	sd	a0,0(s4)
    8000510c:	c92d                	beqz	a0,8000517e <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000510e:	ffffc097          	auipc	ra,0xffffc
    80005112:	9ec080e7          	jalr	-1556(ra) # 80000afa <kalloc>
    80005116:	892a                	mv	s2,a0
    80005118:	c125                	beqz	a0,80005178 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    8000511a:	4985                	li	s3,1
    8000511c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80005120:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80005124:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005128:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000512c:	00003597          	auipc	a1,0x3
    80005130:	36c58593          	addi	a1,a1,876 # 80008498 <states.1805+0x1b8>
    80005134:	ffffc097          	auipc	ra,0xffffc
    80005138:	a26080e7          	jalr	-1498(ra) # 80000b5a <initlock>
  (*f0)->type = FD_PIPE;
    8000513c:	609c                	ld	a5,0(s1)
    8000513e:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80005142:	609c                	ld	a5,0(s1)
    80005144:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005148:	609c                	ld	a5,0(s1)
    8000514a:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000514e:	609c                	ld	a5,0(s1)
    80005150:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80005154:	000a3783          	ld	a5,0(s4)
    80005158:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000515c:	000a3783          	ld	a5,0(s4)
    80005160:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005164:	000a3783          	ld	a5,0(s4)
    80005168:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000516c:	000a3783          	ld	a5,0(s4)
    80005170:	0127b823          	sd	s2,16(a5)
  return 0;
    80005174:	4501                	li	a0,0
    80005176:	a025                	j	8000519e <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005178:	6088                	ld	a0,0(s1)
    8000517a:	e501                	bnez	a0,80005182 <pipealloc+0xaa>
    8000517c:	a039                	j	8000518a <pipealloc+0xb2>
    8000517e:	6088                	ld	a0,0(s1)
    80005180:	c51d                	beqz	a0,800051ae <pipealloc+0xd6>
    fileclose(*f0);
    80005182:	00000097          	auipc	ra,0x0
    80005186:	c26080e7          	jalr	-986(ra) # 80004da8 <fileclose>
  if(*f1)
    8000518a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000518e:	557d                	li	a0,-1
  if(*f1)
    80005190:	c799                	beqz	a5,8000519e <pipealloc+0xc6>
    fileclose(*f1);
    80005192:	853e                	mv	a0,a5
    80005194:	00000097          	auipc	ra,0x0
    80005198:	c14080e7          	jalr	-1004(ra) # 80004da8 <fileclose>
  return -1;
    8000519c:	557d                	li	a0,-1
}
    8000519e:	70a2                	ld	ra,40(sp)
    800051a0:	7402                	ld	s0,32(sp)
    800051a2:	64e2                	ld	s1,24(sp)
    800051a4:	6942                	ld	s2,16(sp)
    800051a6:	69a2                	ld	s3,8(sp)
    800051a8:	6a02                	ld	s4,0(sp)
    800051aa:	6145                	addi	sp,sp,48
    800051ac:	8082                	ret
  return -1;
    800051ae:	557d                	li	a0,-1
    800051b0:	b7fd                	j	8000519e <pipealloc+0xc6>

00000000800051b2 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800051b2:	1101                	addi	sp,sp,-32
    800051b4:	ec06                	sd	ra,24(sp)
    800051b6:	e822                	sd	s0,16(sp)
    800051b8:	e426                	sd	s1,8(sp)
    800051ba:	e04a                	sd	s2,0(sp)
    800051bc:	1000                	addi	s0,sp,32
    800051be:	84aa                	mv	s1,a0
    800051c0:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800051c2:	ffffc097          	auipc	ra,0xffffc
    800051c6:	a28080e7          	jalr	-1496(ra) # 80000bea <acquire>
  if(writable){
    800051ca:	02090d63          	beqz	s2,80005204 <pipeclose+0x52>
    pi->writeopen = 0;
    800051ce:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800051d2:	21848513          	addi	a0,s1,536
    800051d6:	ffffd097          	auipc	ra,0xffffd
    800051da:	3f4080e7          	jalr	1012(ra) # 800025ca <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800051de:	2204b783          	ld	a5,544(s1)
    800051e2:	eb95                	bnez	a5,80005216 <pipeclose+0x64>
    release(&pi->lock);
    800051e4:	8526                	mv	a0,s1
    800051e6:	ffffc097          	auipc	ra,0xffffc
    800051ea:	ab8080e7          	jalr	-1352(ra) # 80000c9e <release>
    kfree((char*)pi);
    800051ee:	8526                	mv	a0,s1
    800051f0:	ffffc097          	auipc	ra,0xffffc
    800051f4:	80e080e7          	jalr	-2034(ra) # 800009fe <kfree>
  } else
    release(&pi->lock);
}
    800051f8:	60e2                	ld	ra,24(sp)
    800051fa:	6442                	ld	s0,16(sp)
    800051fc:	64a2                	ld	s1,8(sp)
    800051fe:	6902                	ld	s2,0(sp)
    80005200:	6105                	addi	sp,sp,32
    80005202:	8082                	ret
    pi->readopen = 0;
    80005204:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005208:	21c48513          	addi	a0,s1,540
    8000520c:	ffffd097          	auipc	ra,0xffffd
    80005210:	3be080e7          	jalr	958(ra) # 800025ca <wakeup>
    80005214:	b7e9                	j	800051de <pipeclose+0x2c>
    release(&pi->lock);
    80005216:	8526                	mv	a0,s1
    80005218:	ffffc097          	auipc	ra,0xffffc
    8000521c:	a86080e7          	jalr	-1402(ra) # 80000c9e <release>
}
    80005220:	bfe1                	j	800051f8 <pipeclose+0x46>

0000000080005222 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005222:	7159                	addi	sp,sp,-112
    80005224:	f486                	sd	ra,104(sp)
    80005226:	f0a2                	sd	s0,96(sp)
    80005228:	eca6                	sd	s1,88(sp)
    8000522a:	e8ca                	sd	s2,80(sp)
    8000522c:	e4ce                	sd	s3,72(sp)
    8000522e:	e0d2                	sd	s4,64(sp)
    80005230:	fc56                	sd	s5,56(sp)
    80005232:	f85a                	sd	s6,48(sp)
    80005234:	f45e                	sd	s7,40(sp)
    80005236:	f062                	sd	s8,32(sp)
    80005238:	ec66                	sd	s9,24(sp)
    8000523a:	1880                	addi	s0,sp,112
    8000523c:	84aa                	mv	s1,a0
    8000523e:	8aae                	mv	s5,a1
    80005240:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80005242:	ffffc097          	auipc	ra,0xffffc
    80005246:	784080e7          	jalr	1924(ra) # 800019c6 <myproc>
    8000524a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000524c:	8526                	mv	a0,s1
    8000524e:	ffffc097          	auipc	ra,0xffffc
    80005252:	99c080e7          	jalr	-1636(ra) # 80000bea <acquire>
  while(i < n){
    80005256:	0d405463          	blez	s4,8000531e <pipewrite+0xfc>
    8000525a:	8ba6                	mv	s7,s1
  int i = 0;
    8000525c:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000525e:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005260:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005264:	21c48c13          	addi	s8,s1,540
    80005268:	a08d                	j	800052ca <pipewrite+0xa8>
      release(&pi->lock);
    8000526a:	8526                	mv	a0,s1
    8000526c:	ffffc097          	auipc	ra,0xffffc
    80005270:	a32080e7          	jalr	-1486(ra) # 80000c9e <release>
      return -1;
    80005274:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005276:	854a                	mv	a0,s2
    80005278:	70a6                	ld	ra,104(sp)
    8000527a:	7406                	ld	s0,96(sp)
    8000527c:	64e6                	ld	s1,88(sp)
    8000527e:	6946                	ld	s2,80(sp)
    80005280:	69a6                	ld	s3,72(sp)
    80005282:	6a06                	ld	s4,64(sp)
    80005284:	7ae2                	ld	s5,56(sp)
    80005286:	7b42                	ld	s6,48(sp)
    80005288:	7ba2                	ld	s7,40(sp)
    8000528a:	7c02                	ld	s8,32(sp)
    8000528c:	6ce2                	ld	s9,24(sp)
    8000528e:	6165                	addi	sp,sp,112
    80005290:	8082                	ret
      wakeup(&pi->nread);
    80005292:	8566                	mv	a0,s9
    80005294:	ffffd097          	auipc	ra,0xffffd
    80005298:	336080e7          	jalr	822(ra) # 800025ca <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000529c:	85de                	mv	a1,s7
    8000529e:	8562                	mv	a0,s8
    800052a0:	ffffd097          	auipc	ra,0xffffd
    800052a4:	17a080e7          	jalr	378(ra) # 8000241a <sleep>
    800052a8:	a839                	j	800052c6 <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800052aa:	21c4a783          	lw	a5,540(s1)
    800052ae:	0017871b          	addiw	a4,a5,1
    800052b2:	20e4ae23          	sw	a4,540(s1)
    800052b6:	1ff7f793          	andi	a5,a5,511
    800052ba:	97a6                	add	a5,a5,s1
    800052bc:	f9f44703          	lbu	a4,-97(s0)
    800052c0:	00e78c23          	sb	a4,24(a5)
      i++;
    800052c4:	2905                	addiw	s2,s2,1
  while(i < n){
    800052c6:	05495063          	bge	s2,s4,80005306 <pipewrite+0xe4>
    if(pi->readopen == 0 || killed(pr)){
    800052ca:	2204a783          	lw	a5,544(s1)
    800052ce:	dfd1                	beqz	a5,8000526a <pipewrite+0x48>
    800052d0:	854e                	mv	a0,s3
    800052d2:	ffffd097          	auipc	ra,0xffffd
    800052d6:	548080e7          	jalr	1352(ra) # 8000281a <killed>
    800052da:	f941                	bnez	a0,8000526a <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800052dc:	2184a783          	lw	a5,536(s1)
    800052e0:	21c4a703          	lw	a4,540(s1)
    800052e4:	2007879b          	addiw	a5,a5,512
    800052e8:	faf705e3          	beq	a4,a5,80005292 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800052ec:	4685                	li	a3,1
    800052ee:	01590633          	add	a2,s2,s5
    800052f2:	f9f40593          	addi	a1,s0,-97
    800052f6:	0509b503          	ld	a0,80(s3)
    800052fa:	ffffc097          	auipc	ra,0xffffc
    800052fe:	416080e7          	jalr	1046(ra) # 80001710 <copyin>
    80005302:	fb6514e3          	bne	a0,s6,800052aa <pipewrite+0x88>
  wakeup(&pi->nread);
    80005306:	21848513          	addi	a0,s1,536
    8000530a:	ffffd097          	auipc	ra,0xffffd
    8000530e:	2c0080e7          	jalr	704(ra) # 800025ca <wakeup>
  release(&pi->lock);
    80005312:	8526                	mv	a0,s1
    80005314:	ffffc097          	auipc	ra,0xffffc
    80005318:	98a080e7          	jalr	-1654(ra) # 80000c9e <release>
  return i;
    8000531c:	bfa9                	j	80005276 <pipewrite+0x54>
  int i = 0;
    8000531e:	4901                	li	s2,0
    80005320:	b7dd                	j	80005306 <pipewrite+0xe4>

0000000080005322 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005322:	715d                	addi	sp,sp,-80
    80005324:	e486                	sd	ra,72(sp)
    80005326:	e0a2                	sd	s0,64(sp)
    80005328:	fc26                	sd	s1,56(sp)
    8000532a:	f84a                	sd	s2,48(sp)
    8000532c:	f44e                	sd	s3,40(sp)
    8000532e:	f052                	sd	s4,32(sp)
    80005330:	ec56                	sd	s5,24(sp)
    80005332:	e85a                	sd	s6,16(sp)
    80005334:	0880                	addi	s0,sp,80
    80005336:	84aa                	mv	s1,a0
    80005338:	892e                	mv	s2,a1
    8000533a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000533c:	ffffc097          	auipc	ra,0xffffc
    80005340:	68a080e7          	jalr	1674(ra) # 800019c6 <myproc>
    80005344:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005346:	8b26                	mv	s6,s1
    80005348:	8526                	mv	a0,s1
    8000534a:	ffffc097          	auipc	ra,0xffffc
    8000534e:	8a0080e7          	jalr	-1888(ra) # 80000bea <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005352:	2184a703          	lw	a4,536(s1)
    80005356:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000535a:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000535e:	02f71763          	bne	a4,a5,8000538c <piperead+0x6a>
    80005362:	2244a783          	lw	a5,548(s1)
    80005366:	c39d                	beqz	a5,8000538c <piperead+0x6a>
    if(killed(pr)){
    80005368:	8552                	mv	a0,s4
    8000536a:	ffffd097          	auipc	ra,0xffffd
    8000536e:	4b0080e7          	jalr	1200(ra) # 8000281a <killed>
    80005372:	e941                	bnez	a0,80005402 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005374:	85da                	mv	a1,s6
    80005376:	854e                	mv	a0,s3
    80005378:	ffffd097          	auipc	ra,0xffffd
    8000537c:	0a2080e7          	jalr	162(ra) # 8000241a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005380:	2184a703          	lw	a4,536(s1)
    80005384:	21c4a783          	lw	a5,540(s1)
    80005388:	fcf70de3          	beq	a4,a5,80005362 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000538c:	09505263          	blez	s5,80005410 <piperead+0xee>
    80005390:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005392:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80005394:	2184a783          	lw	a5,536(s1)
    80005398:	21c4a703          	lw	a4,540(s1)
    8000539c:	02f70d63          	beq	a4,a5,800053d6 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800053a0:	0017871b          	addiw	a4,a5,1
    800053a4:	20e4ac23          	sw	a4,536(s1)
    800053a8:	1ff7f793          	andi	a5,a5,511
    800053ac:	97a6                	add	a5,a5,s1
    800053ae:	0187c783          	lbu	a5,24(a5)
    800053b2:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800053b6:	4685                	li	a3,1
    800053b8:	fbf40613          	addi	a2,s0,-65
    800053bc:	85ca                	mv	a1,s2
    800053be:	050a3503          	ld	a0,80(s4)
    800053c2:	ffffc097          	auipc	ra,0xffffc
    800053c6:	2c2080e7          	jalr	706(ra) # 80001684 <copyout>
    800053ca:	01650663          	beq	a0,s6,800053d6 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800053ce:	2985                	addiw	s3,s3,1
    800053d0:	0905                	addi	s2,s2,1
    800053d2:	fd3a91e3          	bne	s5,s3,80005394 <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800053d6:	21c48513          	addi	a0,s1,540
    800053da:	ffffd097          	auipc	ra,0xffffd
    800053de:	1f0080e7          	jalr	496(ra) # 800025ca <wakeup>
  release(&pi->lock);
    800053e2:	8526                	mv	a0,s1
    800053e4:	ffffc097          	auipc	ra,0xffffc
    800053e8:	8ba080e7          	jalr	-1862(ra) # 80000c9e <release>
  return i;
}
    800053ec:	854e                	mv	a0,s3
    800053ee:	60a6                	ld	ra,72(sp)
    800053f0:	6406                	ld	s0,64(sp)
    800053f2:	74e2                	ld	s1,56(sp)
    800053f4:	7942                	ld	s2,48(sp)
    800053f6:	79a2                	ld	s3,40(sp)
    800053f8:	7a02                	ld	s4,32(sp)
    800053fa:	6ae2                	ld	s5,24(sp)
    800053fc:	6b42                	ld	s6,16(sp)
    800053fe:	6161                	addi	sp,sp,80
    80005400:	8082                	ret
      release(&pi->lock);
    80005402:	8526                	mv	a0,s1
    80005404:	ffffc097          	auipc	ra,0xffffc
    80005408:	89a080e7          	jalr	-1894(ra) # 80000c9e <release>
      return -1;
    8000540c:	59fd                	li	s3,-1
    8000540e:	bff9                	j	800053ec <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005410:	4981                	li	s3,0
    80005412:	b7d1                	j	800053d6 <piperead+0xb4>

0000000080005414 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80005414:	1141                	addi	sp,sp,-16
    80005416:	e422                	sd	s0,8(sp)
    80005418:	0800                	addi	s0,sp,16
    8000541a:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000541c:	8905                	andi	a0,a0,1
    8000541e:	c111                	beqz	a0,80005422 <flags2perm+0xe>
      perm = PTE_X;
    80005420:	4521                	li	a0,8
    if(flags & 0x2)
    80005422:	8b89                	andi	a5,a5,2
    80005424:	c399                	beqz	a5,8000542a <flags2perm+0x16>
      perm |= PTE_W;
    80005426:	00456513          	ori	a0,a0,4
    return perm;
}
    8000542a:	6422                	ld	s0,8(sp)
    8000542c:	0141                	addi	sp,sp,16
    8000542e:	8082                	ret

0000000080005430 <exec>:

int
exec(char *path, char **argv)
{
    80005430:	df010113          	addi	sp,sp,-528
    80005434:	20113423          	sd	ra,520(sp)
    80005438:	20813023          	sd	s0,512(sp)
    8000543c:	ffa6                	sd	s1,504(sp)
    8000543e:	fbca                	sd	s2,496(sp)
    80005440:	f7ce                	sd	s3,488(sp)
    80005442:	f3d2                	sd	s4,480(sp)
    80005444:	efd6                	sd	s5,472(sp)
    80005446:	ebda                	sd	s6,464(sp)
    80005448:	e7de                	sd	s7,456(sp)
    8000544a:	e3e2                	sd	s8,448(sp)
    8000544c:	ff66                	sd	s9,440(sp)
    8000544e:	fb6a                	sd	s10,432(sp)
    80005450:	f76e                	sd	s11,424(sp)
    80005452:	0c00                	addi	s0,sp,528
    80005454:	84aa                	mv	s1,a0
    80005456:	dea43c23          	sd	a0,-520(s0)
    8000545a:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000545e:	ffffc097          	auipc	ra,0xffffc
    80005462:	568080e7          	jalr	1384(ra) # 800019c6 <myproc>
    80005466:	892a                	mv	s2,a0

  begin_op();
    80005468:	fffff097          	auipc	ra,0xfffff
    8000546c:	474080e7          	jalr	1140(ra) # 800048dc <begin_op>

  if((ip = namei(path)) == 0){
    80005470:	8526                	mv	a0,s1
    80005472:	fffff097          	auipc	ra,0xfffff
    80005476:	24e080e7          	jalr	590(ra) # 800046c0 <namei>
    8000547a:	c92d                	beqz	a0,800054ec <exec+0xbc>
    8000547c:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000547e:	fffff097          	auipc	ra,0xfffff
    80005482:	a9c080e7          	jalr	-1380(ra) # 80003f1a <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005486:	04000713          	li	a4,64
    8000548a:	4681                	li	a3,0
    8000548c:	e5040613          	addi	a2,s0,-432
    80005490:	4581                	li	a1,0
    80005492:	8526                	mv	a0,s1
    80005494:	fffff097          	auipc	ra,0xfffff
    80005498:	d3a080e7          	jalr	-710(ra) # 800041ce <readi>
    8000549c:	04000793          	li	a5,64
    800054a0:	00f51a63          	bne	a0,a5,800054b4 <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800054a4:	e5042703          	lw	a4,-432(s0)
    800054a8:	464c47b7          	lui	a5,0x464c4
    800054ac:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800054b0:	04f70463          	beq	a4,a5,800054f8 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800054b4:	8526                	mv	a0,s1
    800054b6:	fffff097          	auipc	ra,0xfffff
    800054ba:	cc6080e7          	jalr	-826(ra) # 8000417c <iunlockput>
    end_op();
    800054be:	fffff097          	auipc	ra,0xfffff
    800054c2:	49e080e7          	jalr	1182(ra) # 8000495c <end_op>
  }
  return -1;
    800054c6:	557d                	li	a0,-1
}
    800054c8:	20813083          	ld	ra,520(sp)
    800054cc:	20013403          	ld	s0,512(sp)
    800054d0:	74fe                	ld	s1,504(sp)
    800054d2:	795e                	ld	s2,496(sp)
    800054d4:	79be                	ld	s3,488(sp)
    800054d6:	7a1e                	ld	s4,480(sp)
    800054d8:	6afe                	ld	s5,472(sp)
    800054da:	6b5e                	ld	s6,464(sp)
    800054dc:	6bbe                	ld	s7,456(sp)
    800054de:	6c1e                	ld	s8,448(sp)
    800054e0:	7cfa                	ld	s9,440(sp)
    800054e2:	7d5a                	ld	s10,432(sp)
    800054e4:	7dba                	ld	s11,424(sp)
    800054e6:	21010113          	addi	sp,sp,528
    800054ea:	8082                	ret
    end_op();
    800054ec:	fffff097          	auipc	ra,0xfffff
    800054f0:	470080e7          	jalr	1136(ra) # 8000495c <end_op>
    return -1;
    800054f4:	557d                	li	a0,-1
    800054f6:	bfc9                	j	800054c8 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    800054f8:	854a                	mv	a0,s2
    800054fa:	ffffc097          	auipc	ra,0xffffc
    800054fe:	590080e7          	jalr	1424(ra) # 80001a8a <proc_pagetable>
    80005502:	8baa                	mv	s7,a0
    80005504:	d945                	beqz	a0,800054b4 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005506:	e7042983          	lw	s3,-400(s0)
    8000550a:	e8845783          	lhu	a5,-376(s0)
    8000550e:	c7ad                	beqz	a5,80005578 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005510:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005512:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80005514:	6c85                	lui	s9,0x1
    80005516:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000551a:	def43823          	sd	a5,-528(s0)
    8000551e:	ac0d                	j	80005750 <exec+0x320>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005520:	00003517          	auipc	a0,0x3
    80005524:	38050513          	addi	a0,a0,896 # 800088a0 <syscallnum+0x238>
    80005528:	ffffb097          	auipc	ra,0xffffb
    8000552c:	01c080e7          	jalr	28(ra) # 80000544 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005530:	8756                	mv	a4,s5
    80005532:	012d86bb          	addw	a3,s11,s2
    80005536:	4581                	li	a1,0
    80005538:	8526                	mv	a0,s1
    8000553a:	fffff097          	auipc	ra,0xfffff
    8000553e:	c94080e7          	jalr	-876(ra) # 800041ce <readi>
    80005542:	2501                	sext.w	a0,a0
    80005544:	1aaa9a63          	bne	s5,a0,800056f8 <exec+0x2c8>
  for(i = 0; i < sz; i += PGSIZE){
    80005548:	6785                	lui	a5,0x1
    8000554a:	0127893b          	addw	s2,a5,s2
    8000554e:	77fd                	lui	a5,0xfffff
    80005550:	01478a3b          	addw	s4,a5,s4
    80005554:	1f897563          	bgeu	s2,s8,8000573e <exec+0x30e>
    pa = walkaddr(pagetable, va + i);
    80005558:	02091593          	slli	a1,s2,0x20
    8000555c:	9181                	srli	a1,a1,0x20
    8000555e:	95ea                	add	a1,a1,s10
    80005560:	855e                	mv	a0,s7
    80005562:	ffffc097          	auipc	ra,0xffffc
    80005566:	b16080e7          	jalr	-1258(ra) # 80001078 <walkaddr>
    8000556a:	862a                	mv	a2,a0
    if(pa == 0)
    8000556c:	d955                	beqz	a0,80005520 <exec+0xf0>
      n = PGSIZE;
    8000556e:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80005570:	fd9a70e3          	bgeu	s4,s9,80005530 <exec+0x100>
      n = sz - i;
    80005574:	8ad2                	mv	s5,s4
    80005576:	bf6d                	j	80005530 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005578:	4a01                	li	s4,0
  iunlockput(ip);
    8000557a:	8526                	mv	a0,s1
    8000557c:	fffff097          	auipc	ra,0xfffff
    80005580:	c00080e7          	jalr	-1024(ra) # 8000417c <iunlockput>
  end_op();
    80005584:	fffff097          	auipc	ra,0xfffff
    80005588:	3d8080e7          	jalr	984(ra) # 8000495c <end_op>
  p = myproc();
    8000558c:	ffffc097          	auipc	ra,0xffffc
    80005590:	43a080e7          	jalr	1082(ra) # 800019c6 <myproc>
    80005594:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005596:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    8000559a:	6785                	lui	a5,0x1
    8000559c:	17fd                	addi	a5,a5,-1
    8000559e:	9a3e                	add	s4,s4,a5
    800055a0:	757d                	lui	a0,0xfffff
    800055a2:	00aa77b3          	and	a5,s4,a0
    800055a6:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800055aa:	4691                	li	a3,4
    800055ac:	6609                	lui	a2,0x2
    800055ae:	963e                	add	a2,a2,a5
    800055b0:	85be                	mv	a1,a5
    800055b2:	855e                	mv	a0,s7
    800055b4:	ffffc097          	auipc	ra,0xffffc
    800055b8:	e78080e7          	jalr	-392(ra) # 8000142c <uvmalloc>
    800055bc:	8b2a                	mv	s6,a0
  ip = 0;
    800055be:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800055c0:	12050c63          	beqz	a0,800056f8 <exec+0x2c8>
  uvmclear(pagetable, sz-2*PGSIZE);
    800055c4:	75f9                	lui	a1,0xffffe
    800055c6:	95aa                	add	a1,a1,a0
    800055c8:	855e                	mv	a0,s7
    800055ca:	ffffc097          	auipc	ra,0xffffc
    800055ce:	088080e7          	jalr	136(ra) # 80001652 <uvmclear>
  stackbase = sp - PGSIZE;
    800055d2:	7c7d                	lui	s8,0xfffff
    800055d4:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    800055d6:	e0043783          	ld	a5,-512(s0)
    800055da:	6388                	ld	a0,0(a5)
    800055dc:	c535                	beqz	a0,80005648 <exec+0x218>
    800055de:	e9040993          	addi	s3,s0,-368
    800055e2:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800055e6:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    800055e8:	ffffc097          	auipc	ra,0xffffc
    800055ec:	882080e7          	jalr	-1918(ra) # 80000e6a <strlen>
    800055f0:	2505                	addiw	a0,a0,1
    800055f2:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800055f6:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800055fa:	13896663          	bltu	s2,s8,80005726 <exec+0x2f6>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800055fe:	e0043d83          	ld	s11,-512(s0)
    80005602:	000dba03          	ld	s4,0(s11)
    80005606:	8552                	mv	a0,s4
    80005608:	ffffc097          	auipc	ra,0xffffc
    8000560c:	862080e7          	jalr	-1950(ra) # 80000e6a <strlen>
    80005610:	0015069b          	addiw	a3,a0,1
    80005614:	8652                	mv	a2,s4
    80005616:	85ca                	mv	a1,s2
    80005618:	855e                	mv	a0,s7
    8000561a:	ffffc097          	auipc	ra,0xffffc
    8000561e:	06a080e7          	jalr	106(ra) # 80001684 <copyout>
    80005622:	10054663          	bltz	a0,8000572e <exec+0x2fe>
    ustack[argc] = sp;
    80005626:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000562a:	0485                	addi	s1,s1,1
    8000562c:	008d8793          	addi	a5,s11,8
    80005630:	e0f43023          	sd	a5,-512(s0)
    80005634:	008db503          	ld	a0,8(s11)
    80005638:	c911                	beqz	a0,8000564c <exec+0x21c>
    if(argc >= MAXARG)
    8000563a:	09a1                	addi	s3,s3,8
    8000563c:	fb3c96e3          	bne	s9,s3,800055e8 <exec+0x1b8>
  sz = sz1;
    80005640:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005644:	4481                	li	s1,0
    80005646:	a84d                	j	800056f8 <exec+0x2c8>
  sp = sz;
    80005648:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    8000564a:	4481                	li	s1,0
  ustack[argc] = 0;
    8000564c:	00349793          	slli	a5,s1,0x3
    80005650:	f9040713          	addi	a4,s0,-112
    80005654:	97ba                	add	a5,a5,a4
    80005656:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    8000565a:	00148693          	addi	a3,s1,1
    8000565e:	068e                	slli	a3,a3,0x3
    80005660:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005664:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005668:	01897663          	bgeu	s2,s8,80005674 <exec+0x244>
  sz = sz1;
    8000566c:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005670:	4481                	li	s1,0
    80005672:	a059                	j	800056f8 <exec+0x2c8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005674:	e9040613          	addi	a2,s0,-368
    80005678:	85ca                	mv	a1,s2
    8000567a:	855e                	mv	a0,s7
    8000567c:	ffffc097          	auipc	ra,0xffffc
    80005680:	008080e7          	jalr	8(ra) # 80001684 <copyout>
    80005684:	0a054963          	bltz	a0,80005736 <exec+0x306>
  p->trapframe->a1 = sp;
    80005688:	058ab783          	ld	a5,88(s5)
    8000568c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005690:	df843783          	ld	a5,-520(s0)
    80005694:	0007c703          	lbu	a4,0(a5)
    80005698:	cf11                	beqz	a4,800056b4 <exec+0x284>
    8000569a:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000569c:	02f00693          	li	a3,47
    800056a0:	a039                	j	800056ae <exec+0x27e>
      last = s+1;
    800056a2:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800056a6:	0785                	addi	a5,a5,1
    800056a8:	fff7c703          	lbu	a4,-1(a5)
    800056ac:	c701                	beqz	a4,800056b4 <exec+0x284>
    if(*s == '/')
    800056ae:	fed71ce3          	bne	a4,a3,800056a6 <exec+0x276>
    800056b2:	bfc5                	j	800056a2 <exec+0x272>
  safestrcpy(p->name, last, sizeof(p->name));
    800056b4:	4641                	li	a2,16
    800056b6:	df843583          	ld	a1,-520(s0)
    800056ba:	158a8513          	addi	a0,s5,344
    800056be:	ffffb097          	auipc	ra,0xffffb
    800056c2:	77a080e7          	jalr	1914(ra) # 80000e38 <safestrcpy>
  oldpagetable = p->pagetable;
    800056c6:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800056ca:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    800056ce:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800056d2:	058ab783          	ld	a5,88(s5)
    800056d6:	e6843703          	ld	a4,-408(s0)
    800056da:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800056dc:	058ab783          	ld	a5,88(s5)
    800056e0:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800056e4:	85ea                	mv	a1,s10
    800056e6:	ffffc097          	auipc	ra,0xffffc
    800056ea:	440080e7          	jalr	1088(ra) # 80001b26 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800056ee:	0004851b          	sext.w	a0,s1
    800056f2:	bbd9                	j	800054c8 <exec+0x98>
    800056f4:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    800056f8:	e0843583          	ld	a1,-504(s0)
    800056fc:	855e                	mv	a0,s7
    800056fe:	ffffc097          	auipc	ra,0xffffc
    80005702:	428080e7          	jalr	1064(ra) # 80001b26 <proc_freepagetable>
  if(ip){
    80005706:	da0497e3          	bnez	s1,800054b4 <exec+0x84>
  return -1;
    8000570a:	557d                	li	a0,-1
    8000570c:	bb75                	j	800054c8 <exec+0x98>
    8000570e:	e1443423          	sd	s4,-504(s0)
    80005712:	b7dd                	j	800056f8 <exec+0x2c8>
    80005714:	e1443423          	sd	s4,-504(s0)
    80005718:	b7c5                	j	800056f8 <exec+0x2c8>
    8000571a:	e1443423          	sd	s4,-504(s0)
    8000571e:	bfe9                	j	800056f8 <exec+0x2c8>
    80005720:	e1443423          	sd	s4,-504(s0)
    80005724:	bfd1                	j	800056f8 <exec+0x2c8>
  sz = sz1;
    80005726:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000572a:	4481                	li	s1,0
    8000572c:	b7f1                	j	800056f8 <exec+0x2c8>
  sz = sz1;
    8000572e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005732:	4481                	li	s1,0
    80005734:	b7d1                	j	800056f8 <exec+0x2c8>
  sz = sz1;
    80005736:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000573a:	4481                	li	s1,0
    8000573c:	bf75                	j	800056f8 <exec+0x2c8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000573e:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005742:	2b05                	addiw	s6,s6,1
    80005744:	0389899b          	addiw	s3,s3,56
    80005748:	e8845783          	lhu	a5,-376(s0)
    8000574c:	e2fb57e3          	bge	s6,a5,8000557a <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005750:	2981                	sext.w	s3,s3
    80005752:	03800713          	li	a4,56
    80005756:	86ce                	mv	a3,s3
    80005758:	e1840613          	addi	a2,s0,-488
    8000575c:	4581                	li	a1,0
    8000575e:	8526                	mv	a0,s1
    80005760:	fffff097          	auipc	ra,0xfffff
    80005764:	a6e080e7          	jalr	-1426(ra) # 800041ce <readi>
    80005768:	03800793          	li	a5,56
    8000576c:	f8f514e3          	bne	a0,a5,800056f4 <exec+0x2c4>
    if(ph.type != ELF_PROG_LOAD)
    80005770:	e1842783          	lw	a5,-488(s0)
    80005774:	4705                	li	a4,1
    80005776:	fce796e3          	bne	a5,a4,80005742 <exec+0x312>
    if(ph.memsz < ph.filesz)
    8000577a:	e4043903          	ld	s2,-448(s0)
    8000577e:	e3843783          	ld	a5,-456(s0)
    80005782:	f8f966e3          	bltu	s2,a5,8000570e <exec+0x2de>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005786:	e2843783          	ld	a5,-472(s0)
    8000578a:	993e                	add	s2,s2,a5
    8000578c:	f8f964e3          	bltu	s2,a5,80005714 <exec+0x2e4>
    if(ph.vaddr % PGSIZE != 0)
    80005790:	df043703          	ld	a4,-528(s0)
    80005794:	8ff9                	and	a5,a5,a4
    80005796:	f3d1                	bnez	a5,8000571a <exec+0x2ea>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005798:	e1c42503          	lw	a0,-484(s0)
    8000579c:	00000097          	auipc	ra,0x0
    800057a0:	c78080e7          	jalr	-904(ra) # 80005414 <flags2perm>
    800057a4:	86aa                	mv	a3,a0
    800057a6:	864a                	mv	a2,s2
    800057a8:	85d2                	mv	a1,s4
    800057aa:	855e                	mv	a0,s7
    800057ac:	ffffc097          	auipc	ra,0xffffc
    800057b0:	c80080e7          	jalr	-896(ra) # 8000142c <uvmalloc>
    800057b4:	e0a43423          	sd	a0,-504(s0)
    800057b8:	d525                	beqz	a0,80005720 <exec+0x2f0>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800057ba:	e2843d03          	ld	s10,-472(s0)
    800057be:	e2042d83          	lw	s11,-480(s0)
    800057c2:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800057c6:	f60c0ce3          	beqz	s8,8000573e <exec+0x30e>
    800057ca:	8a62                	mv	s4,s8
    800057cc:	4901                	li	s2,0
    800057ce:	b369                	j	80005558 <exec+0x128>

00000000800057d0 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800057d0:	7179                	addi	sp,sp,-48
    800057d2:	f406                	sd	ra,40(sp)
    800057d4:	f022                	sd	s0,32(sp)
    800057d6:	ec26                	sd	s1,24(sp)
    800057d8:	e84a                	sd	s2,16(sp)
    800057da:	1800                	addi	s0,sp,48
    800057dc:	892e                	mv	s2,a1
    800057de:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800057e0:	fdc40593          	addi	a1,s0,-36
    800057e4:	ffffe097          	auipc	ra,0xffffe
    800057e8:	918080e7          	jalr	-1768(ra) # 800030fc <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800057ec:	fdc42703          	lw	a4,-36(s0)
    800057f0:	47bd                	li	a5,15
    800057f2:	02e7eb63          	bltu	a5,a4,80005828 <argfd+0x58>
    800057f6:	ffffc097          	auipc	ra,0xffffc
    800057fa:	1d0080e7          	jalr	464(ra) # 800019c6 <myproc>
    800057fe:	fdc42703          	lw	a4,-36(s0)
    80005802:	01a70793          	addi	a5,a4,26
    80005806:	078e                	slli	a5,a5,0x3
    80005808:	953e                	add	a0,a0,a5
    8000580a:	611c                	ld	a5,0(a0)
    8000580c:	c385                	beqz	a5,8000582c <argfd+0x5c>
    return -1;
  if(pfd)
    8000580e:	00090463          	beqz	s2,80005816 <argfd+0x46>
    *pfd = fd;
    80005812:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005816:	4501                	li	a0,0
  if(pf)
    80005818:	c091                	beqz	s1,8000581c <argfd+0x4c>
    *pf = f;
    8000581a:	e09c                	sd	a5,0(s1)
}
    8000581c:	70a2                	ld	ra,40(sp)
    8000581e:	7402                	ld	s0,32(sp)
    80005820:	64e2                	ld	s1,24(sp)
    80005822:	6942                	ld	s2,16(sp)
    80005824:	6145                	addi	sp,sp,48
    80005826:	8082                	ret
    return -1;
    80005828:	557d                	li	a0,-1
    8000582a:	bfcd                	j	8000581c <argfd+0x4c>
    8000582c:	557d                	li	a0,-1
    8000582e:	b7fd                	j	8000581c <argfd+0x4c>

0000000080005830 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005830:	1101                	addi	sp,sp,-32
    80005832:	ec06                	sd	ra,24(sp)
    80005834:	e822                	sd	s0,16(sp)
    80005836:	e426                	sd	s1,8(sp)
    80005838:	1000                	addi	s0,sp,32
    8000583a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000583c:	ffffc097          	auipc	ra,0xffffc
    80005840:	18a080e7          	jalr	394(ra) # 800019c6 <myproc>
    80005844:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005846:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffdaeb0>
    8000584a:	4501                	li	a0,0
    8000584c:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000584e:	6398                	ld	a4,0(a5)
    80005850:	cb19                	beqz	a4,80005866 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005852:	2505                	addiw	a0,a0,1
    80005854:	07a1                	addi	a5,a5,8
    80005856:	fed51ce3          	bne	a0,a3,8000584e <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000585a:	557d                	li	a0,-1
}
    8000585c:	60e2                	ld	ra,24(sp)
    8000585e:	6442                	ld	s0,16(sp)
    80005860:	64a2                	ld	s1,8(sp)
    80005862:	6105                	addi	sp,sp,32
    80005864:	8082                	ret
      p->ofile[fd] = f;
    80005866:	01a50793          	addi	a5,a0,26
    8000586a:	078e                	slli	a5,a5,0x3
    8000586c:	963e                	add	a2,a2,a5
    8000586e:	e204                	sd	s1,0(a2)
      return fd;
    80005870:	b7f5                	j	8000585c <fdalloc+0x2c>

0000000080005872 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005872:	715d                	addi	sp,sp,-80
    80005874:	e486                	sd	ra,72(sp)
    80005876:	e0a2                	sd	s0,64(sp)
    80005878:	fc26                	sd	s1,56(sp)
    8000587a:	f84a                	sd	s2,48(sp)
    8000587c:	f44e                	sd	s3,40(sp)
    8000587e:	f052                	sd	s4,32(sp)
    80005880:	ec56                	sd	s5,24(sp)
    80005882:	e85a                	sd	s6,16(sp)
    80005884:	0880                	addi	s0,sp,80
    80005886:	8b2e                	mv	s6,a1
    80005888:	89b2                	mv	s3,a2
    8000588a:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000588c:	fb040593          	addi	a1,s0,-80
    80005890:	fffff097          	auipc	ra,0xfffff
    80005894:	e4e080e7          	jalr	-434(ra) # 800046de <nameiparent>
    80005898:	84aa                	mv	s1,a0
    8000589a:	16050063          	beqz	a0,800059fa <create+0x188>
    return 0;

  ilock(dp);
    8000589e:	ffffe097          	auipc	ra,0xffffe
    800058a2:	67c080e7          	jalr	1660(ra) # 80003f1a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800058a6:	4601                	li	a2,0
    800058a8:	fb040593          	addi	a1,s0,-80
    800058ac:	8526                	mv	a0,s1
    800058ae:	fffff097          	auipc	ra,0xfffff
    800058b2:	b50080e7          	jalr	-1200(ra) # 800043fe <dirlookup>
    800058b6:	8aaa                	mv	s5,a0
    800058b8:	c931                	beqz	a0,8000590c <create+0x9a>
    iunlockput(dp);
    800058ba:	8526                	mv	a0,s1
    800058bc:	fffff097          	auipc	ra,0xfffff
    800058c0:	8c0080e7          	jalr	-1856(ra) # 8000417c <iunlockput>
    ilock(ip);
    800058c4:	8556                	mv	a0,s5
    800058c6:	ffffe097          	auipc	ra,0xffffe
    800058ca:	654080e7          	jalr	1620(ra) # 80003f1a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800058ce:	000b059b          	sext.w	a1,s6
    800058d2:	4789                	li	a5,2
    800058d4:	02f59563          	bne	a1,a5,800058fe <create+0x8c>
    800058d8:	044ad783          	lhu	a5,68(s5)
    800058dc:	37f9                	addiw	a5,a5,-2
    800058de:	17c2                	slli	a5,a5,0x30
    800058e0:	93c1                	srli	a5,a5,0x30
    800058e2:	4705                	li	a4,1
    800058e4:	00f76d63          	bltu	a4,a5,800058fe <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800058e8:	8556                	mv	a0,s5
    800058ea:	60a6                	ld	ra,72(sp)
    800058ec:	6406                	ld	s0,64(sp)
    800058ee:	74e2                	ld	s1,56(sp)
    800058f0:	7942                	ld	s2,48(sp)
    800058f2:	79a2                	ld	s3,40(sp)
    800058f4:	7a02                	ld	s4,32(sp)
    800058f6:	6ae2                	ld	s5,24(sp)
    800058f8:	6b42                	ld	s6,16(sp)
    800058fa:	6161                	addi	sp,sp,80
    800058fc:	8082                	ret
    iunlockput(ip);
    800058fe:	8556                	mv	a0,s5
    80005900:	fffff097          	auipc	ra,0xfffff
    80005904:	87c080e7          	jalr	-1924(ra) # 8000417c <iunlockput>
    return 0;
    80005908:	4a81                	li	s5,0
    8000590a:	bff9                	j	800058e8 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000590c:	85da                	mv	a1,s6
    8000590e:	4088                	lw	a0,0(s1)
    80005910:	ffffe097          	auipc	ra,0xffffe
    80005914:	46e080e7          	jalr	1134(ra) # 80003d7e <ialloc>
    80005918:	8a2a                	mv	s4,a0
    8000591a:	c921                	beqz	a0,8000596a <create+0xf8>
  ilock(ip);
    8000591c:	ffffe097          	auipc	ra,0xffffe
    80005920:	5fe080e7          	jalr	1534(ra) # 80003f1a <ilock>
  ip->major = major;
    80005924:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005928:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000592c:	4785                	li	a5,1
    8000592e:	04fa1523          	sh	a5,74(s4)
  iupdate(ip);
    80005932:	8552                	mv	a0,s4
    80005934:	ffffe097          	auipc	ra,0xffffe
    80005938:	51c080e7          	jalr	1308(ra) # 80003e50 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000593c:	000b059b          	sext.w	a1,s6
    80005940:	4785                	li	a5,1
    80005942:	02f58b63          	beq	a1,a5,80005978 <create+0x106>
  if(dirlink(dp, name, ip->inum) < 0)
    80005946:	004a2603          	lw	a2,4(s4)
    8000594a:	fb040593          	addi	a1,s0,-80
    8000594e:	8526                	mv	a0,s1
    80005950:	fffff097          	auipc	ra,0xfffff
    80005954:	cbe080e7          	jalr	-834(ra) # 8000460e <dirlink>
    80005958:	06054f63          	bltz	a0,800059d6 <create+0x164>
  iunlockput(dp);
    8000595c:	8526                	mv	a0,s1
    8000595e:	fffff097          	auipc	ra,0xfffff
    80005962:	81e080e7          	jalr	-2018(ra) # 8000417c <iunlockput>
  return ip;
    80005966:	8ad2                	mv	s5,s4
    80005968:	b741                	j	800058e8 <create+0x76>
    iunlockput(dp);
    8000596a:	8526                	mv	a0,s1
    8000596c:	fffff097          	auipc	ra,0xfffff
    80005970:	810080e7          	jalr	-2032(ra) # 8000417c <iunlockput>
    return 0;
    80005974:	8ad2                	mv	s5,s4
    80005976:	bf8d                	j	800058e8 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005978:	004a2603          	lw	a2,4(s4)
    8000597c:	00003597          	auipc	a1,0x3
    80005980:	f4458593          	addi	a1,a1,-188 # 800088c0 <syscallnum+0x258>
    80005984:	8552                	mv	a0,s4
    80005986:	fffff097          	auipc	ra,0xfffff
    8000598a:	c88080e7          	jalr	-888(ra) # 8000460e <dirlink>
    8000598e:	04054463          	bltz	a0,800059d6 <create+0x164>
    80005992:	40d0                	lw	a2,4(s1)
    80005994:	00003597          	auipc	a1,0x3
    80005998:	f3458593          	addi	a1,a1,-204 # 800088c8 <syscallnum+0x260>
    8000599c:	8552                	mv	a0,s4
    8000599e:	fffff097          	auipc	ra,0xfffff
    800059a2:	c70080e7          	jalr	-912(ra) # 8000460e <dirlink>
    800059a6:	02054863          	bltz	a0,800059d6 <create+0x164>
  if(dirlink(dp, name, ip->inum) < 0)
    800059aa:	004a2603          	lw	a2,4(s4)
    800059ae:	fb040593          	addi	a1,s0,-80
    800059b2:	8526                	mv	a0,s1
    800059b4:	fffff097          	auipc	ra,0xfffff
    800059b8:	c5a080e7          	jalr	-934(ra) # 8000460e <dirlink>
    800059bc:	00054d63          	bltz	a0,800059d6 <create+0x164>
    dp->nlink++;  // for ".."
    800059c0:	04a4d783          	lhu	a5,74(s1)
    800059c4:	2785                	addiw	a5,a5,1
    800059c6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800059ca:	8526                	mv	a0,s1
    800059cc:	ffffe097          	auipc	ra,0xffffe
    800059d0:	484080e7          	jalr	1156(ra) # 80003e50 <iupdate>
    800059d4:	b761                	j	8000595c <create+0xea>
  ip->nlink = 0;
    800059d6:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800059da:	8552                	mv	a0,s4
    800059dc:	ffffe097          	auipc	ra,0xffffe
    800059e0:	474080e7          	jalr	1140(ra) # 80003e50 <iupdate>
  iunlockput(ip);
    800059e4:	8552                	mv	a0,s4
    800059e6:	ffffe097          	auipc	ra,0xffffe
    800059ea:	796080e7          	jalr	1942(ra) # 8000417c <iunlockput>
  iunlockput(dp);
    800059ee:	8526                	mv	a0,s1
    800059f0:	ffffe097          	auipc	ra,0xffffe
    800059f4:	78c080e7          	jalr	1932(ra) # 8000417c <iunlockput>
  return 0;
    800059f8:	bdc5                	j	800058e8 <create+0x76>
    return 0;
    800059fa:	8aaa                	mv	s5,a0
    800059fc:	b5f5                	j	800058e8 <create+0x76>

00000000800059fe <sys_dup>:
{
    800059fe:	7179                	addi	sp,sp,-48
    80005a00:	f406                	sd	ra,40(sp)
    80005a02:	f022                	sd	s0,32(sp)
    80005a04:	ec26                	sd	s1,24(sp)
    80005a06:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005a08:	fd840613          	addi	a2,s0,-40
    80005a0c:	4581                	li	a1,0
    80005a0e:	4501                	li	a0,0
    80005a10:	00000097          	auipc	ra,0x0
    80005a14:	dc0080e7          	jalr	-576(ra) # 800057d0 <argfd>
    return -1;
    80005a18:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005a1a:	02054363          	bltz	a0,80005a40 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005a1e:	fd843503          	ld	a0,-40(s0)
    80005a22:	00000097          	auipc	ra,0x0
    80005a26:	e0e080e7          	jalr	-498(ra) # 80005830 <fdalloc>
    80005a2a:	84aa                	mv	s1,a0
    return -1;
    80005a2c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005a2e:	00054963          	bltz	a0,80005a40 <sys_dup+0x42>
  filedup(f);
    80005a32:	fd843503          	ld	a0,-40(s0)
    80005a36:	fffff097          	auipc	ra,0xfffff
    80005a3a:	320080e7          	jalr	800(ra) # 80004d56 <filedup>
  return fd;
    80005a3e:	87a6                	mv	a5,s1
}
    80005a40:	853e                	mv	a0,a5
    80005a42:	70a2                	ld	ra,40(sp)
    80005a44:	7402                	ld	s0,32(sp)
    80005a46:	64e2                	ld	s1,24(sp)
    80005a48:	6145                	addi	sp,sp,48
    80005a4a:	8082                	ret

0000000080005a4c <sys_read>:
{
    80005a4c:	7179                	addi	sp,sp,-48
    80005a4e:	f406                	sd	ra,40(sp)
    80005a50:	f022                	sd	s0,32(sp)
    80005a52:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005a54:	fd840593          	addi	a1,s0,-40
    80005a58:	4505                	li	a0,1
    80005a5a:	ffffd097          	auipc	ra,0xffffd
    80005a5e:	6c4080e7          	jalr	1732(ra) # 8000311e <argaddr>
  argint(2, &n);
    80005a62:	fe440593          	addi	a1,s0,-28
    80005a66:	4509                	li	a0,2
    80005a68:	ffffd097          	auipc	ra,0xffffd
    80005a6c:	694080e7          	jalr	1684(ra) # 800030fc <argint>
  if(argfd(0, 0, &f) < 0)
    80005a70:	fe840613          	addi	a2,s0,-24
    80005a74:	4581                	li	a1,0
    80005a76:	4501                	li	a0,0
    80005a78:	00000097          	auipc	ra,0x0
    80005a7c:	d58080e7          	jalr	-680(ra) # 800057d0 <argfd>
    80005a80:	87aa                	mv	a5,a0
    return -1;
    80005a82:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005a84:	0007cc63          	bltz	a5,80005a9c <sys_read+0x50>
  return fileread(f, p, n);
    80005a88:	fe442603          	lw	a2,-28(s0)
    80005a8c:	fd843583          	ld	a1,-40(s0)
    80005a90:	fe843503          	ld	a0,-24(s0)
    80005a94:	fffff097          	auipc	ra,0xfffff
    80005a98:	44e080e7          	jalr	1102(ra) # 80004ee2 <fileread>
}
    80005a9c:	70a2                	ld	ra,40(sp)
    80005a9e:	7402                	ld	s0,32(sp)
    80005aa0:	6145                	addi	sp,sp,48
    80005aa2:	8082                	ret

0000000080005aa4 <sys_write>:
{
    80005aa4:	7179                	addi	sp,sp,-48
    80005aa6:	f406                	sd	ra,40(sp)
    80005aa8:	f022                	sd	s0,32(sp)
    80005aaa:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005aac:	fd840593          	addi	a1,s0,-40
    80005ab0:	4505                	li	a0,1
    80005ab2:	ffffd097          	auipc	ra,0xffffd
    80005ab6:	66c080e7          	jalr	1644(ra) # 8000311e <argaddr>
  argint(2, &n);
    80005aba:	fe440593          	addi	a1,s0,-28
    80005abe:	4509                	li	a0,2
    80005ac0:	ffffd097          	auipc	ra,0xffffd
    80005ac4:	63c080e7          	jalr	1596(ra) # 800030fc <argint>
  if(argfd(0, 0, &f) < 0)
    80005ac8:	fe840613          	addi	a2,s0,-24
    80005acc:	4581                	li	a1,0
    80005ace:	4501                	li	a0,0
    80005ad0:	00000097          	auipc	ra,0x0
    80005ad4:	d00080e7          	jalr	-768(ra) # 800057d0 <argfd>
    80005ad8:	87aa                	mv	a5,a0
    return -1;
    80005ada:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005adc:	0007cc63          	bltz	a5,80005af4 <sys_write+0x50>
  return filewrite(f, p, n);
    80005ae0:	fe442603          	lw	a2,-28(s0)
    80005ae4:	fd843583          	ld	a1,-40(s0)
    80005ae8:	fe843503          	ld	a0,-24(s0)
    80005aec:	fffff097          	auipc	ra,0xfffff
    80005af0:	4b8080e7          	jalr	1208(ra) # 80004fa4 <filewrite>
}
    80005af4:	70a2                	ld	ra,40(sp)
    80005af6:	7402                	ld	s0,32(sp)
    80005af8:	6145                	addi	sp,sp,48
    80005afa:	8082                	ret

0000000080005afc <sys_close>:
{
    80005afc:	1101                	addi	sp,sp,-32
    80005afe:	ec06                	sd	ra,24(sp)
    80005b00:	e822                	sd	s0,16(sp)
    80005b02:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005b04:	fe040613          	addi	a2,s0,-32
    80005b08:	fec40593          	addi	a1,s0,-20
    80005b0c:	4501                	li	a0,0
    80005b0e:	00000097          	auipc	ra,0x0
    80005b12:	cc2080e7          	jalr	-830(ra) # 800057d0 <argfd>
    return -1;
    80005b16:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005b18:	02054463          	bltz	a0,80005b40 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005b1c:	ffffc097          	auipc	ra,0xffffc
    80005b20:	eaa080e7          	jalr	-342(ra) # 800019c6 <myproc>
    80005b24:	fec42783          	lw	a5,-20(s0)
    80005b28:	07e9                	addi	a5,a5,26
    80005b2a:	078e                	slli	a5,a5,0x3
    80005b2c:	97aa                	add	a5,a5,a0
    80005b2e:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005b32:	fe043503          	ld	a0,-32(s0)
    80005b36:	fffff097          	auipc	ra,0xfffff
    80005b3a:	272080e7          	jalr	626(ra) # 80004da8 <fileclose>
  return 0;
    80005b3e:	4781                	li	a5,0
}
    80005b40:	853e                	mv	a0,a5
    80005b42:	60e2                	ld	ra,24(sp)
    80005b44:	6442                	ld	s0,16(sp)
    80005b46:	6105                	addi	sp,sp,32
    80005b48:	8082                	ret

0000000080005b4a <sys_fstat>:
{
    80005b4a:	1101                	addi	sp,sp,-32
    80005b4c:	ec06                	sd	ra,24(sp)
    80005b4e:	e822                	sd	s0,16(sp)
    80005b50:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005b52:	fe040593          	addi	a1,s0,-32
    80005b56:	4505                	li	a0,1
    80005b58:	ffffd097          	auipc	ra,0xffffd
    80005b5c:	5c6080e7          	jalr	1478(ra) # 8000311e <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005b60:	fe840613          	addi	a2,s0,-24
    80005b64:	4581                	li	a1,0
    80005b66:	4501                	li	a0,0
    80005b68:	00000097          	auipc	ra,0x0
    80005b6c:	c68080e7          	jalr	-920(ra) # 800057d0 <argfd>
    80005b70:	87aa                	mv	a5,a0
    return -1;
    80005b72:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005b74:	0007ca63          	bltz	a5,80005b88 <sys_fstat+0x3e>
  return filestat(f, st);
    80005b78:	fe043583          	ld	a1,-32(s0)
    80005b7c:	fe843503          	ld	a0,-24(s0)
    80005b80:	fffff097          	auipc	ra,0xfffff
    80005b84:	2f0080e7          	jalr	752(ra) # 80004e70 <filestat>
}
    80005b88:	60e2                	ld	ra,24(sp)
    80005b8a:	6442                	ld	s0,16(sp)
    80005b8c:	6105                	addi	sp,sp,32
    80005b8e:	8082                	ret

0000000080005b90 <sys_link>:
{
    80005b90:	7169                	addi	sp,sp,-304
    80005b92:	f606                	sd	ra,296(sp)
    80005b94:	f222                	sd	s0,288(sp)
    80005b96:	ee26                	sd	s1,280(sp)
    80005b98:	ea4a                	sd	s2,272(sp)
    80005b9a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b9c:	08000613          	li	a2,128
    80005ba0:	ed040593          	addi	a1,s0,-304
    80005ba4:	4501                	li	a0,0
    80005ba6:	ffffd097          	auipc	ra,0xffffd
    80005baa:	59a080e7          	jalr	1434(ra) # 80003140 <argstr>
    return -1;
    80005bae:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005bb0:	10054e63          	bltz	a0,80005ccc <sys_link+0x13c>
    80005bb4:	08000613          	li	a2,128
    80005bb8:	f5040593          	addi	a1,s0,-176
    80005bbc:	4505                	li	a0,1
    80005bbe:	ffffd097          	auipc	ra,0xffffd
    80005bc2:	582080e7          	jalr	1410(ra) # 80003140 <argstr>
    return -1;
    80005bc6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005bc8:	10054263          	bltz	a0,80005ccc <sys_link+0x13c>
  begin_op();
    80005bcc:	fffff097          	auipc	ra,0xfffff
    80005bd0:	d10080e7          	jalr	-752(ra) # 800048dc <begin_op>
  if((ip = namei(old)) == 0){
    80005bd4:	ed040513          	addi	a0,s0,-304
    80005bd8:	fffff097          	auipc	ra,0xfffff
    80005bdc:	ae8080e7          	jalr	-1304(ra) # 800046c0 <namei>
    80005be0:	84aa                	mv	s1,a0
    80005be2:	c551                	beqz	a0,80005c6e <sys_link+0xde>
  ilock(ip);
    80005be4:	ffffe097          	auipc	ra,0xffffe
    80005be8:	336080e7          	jalr	822(ra) # 80003f1a <ilock>
  if(ip->type == T_DIR){
    80005bec:	04449703          	lh	a4,68(s1)
    80005bf0:	4785                	li	a5,1
    80005bf2:	08f70463          	beq	a4,a5,80005c7a <sys_link+0xea>
  ip->nlink++;
    80005bf6:	04a4d783          	lhu	a5,74(s1)
    80005bfa:	2785                	addiw	a5,a5,1
    80005bfc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005c00:	8526                	mv	a0,s1
    80005c02:	ffffe097          	auipc	ra,0xffffe
    80005c06:	24e080e7          	jalr	590(ra) # 80003e50 <iupdate>
  iunlock(ip);
    80005c0a:	8526                	mv	a0,s1
    80005c0c:	ffffe097          	auipc	ra,0xffffe
    80005c10:	3d0080e7          	jalr	976(ra) # 80003fdc <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005c14:	fd040593          	addi	a1,s0,-48
    80005c18:	f5040513          	addi	a0,s0,-176
    80005c1c:	fffff097          	auipc	ra,0xfffff
    80005c20:	ac2080e7          	jalr	-1342(ra) # 800046de <nameiparent>
    80005c24:	892a                	mv	s2,a0
    80005c26:	c935                	beqz	a0,80005c9a <sys_link+0x10a>
  ilock(dp);
    80005c28:	ffffe097          	auipc	ra,0xffffe
    80005c2c:	2f2080e7          	jalr	754(ra) # 80003f1a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005c30:	00092703          	lw	a4,0(s2)
    80005c34:	409c                	lw	a5,0(s1)
    80005c36:	04f71d63          	bne	a4,a5,80005c90 <sys_link+0x100>
    80005c3a:	40d0                	lw	a2,4(s1)
    80005c3c:	fd040593          	addi	a1,s0,-48
    80005c40:	854a                	mv	a0,s2
    80005c42:	fffff097          	auipc	ra,0xfffff
    80005c46:	9cc080e7          	jalr	-1588(ra) # 8000460e <dirlink>
    80005c4a:	04054363          	bltz	a0,80005c90 <sys_link+0x100>
  iunlockput(dp);
    80005c4e:	854a                	mv	a0,s2
    80005c50:	ffffe097          	auipc	ra,0xffffe
    80005c54:	52c080e7          	jalr	1324(ra) # 8000417c <iunlockput>
  iput(ip);
    80005c58:	8526                	mv	a0,s1
    80005c5a:	ffffe097          	auipc	ra,0xffffe
    80005c5e:	47a080e7          	jalr	1146(ra) # 800040d4 <iput>
  end_op();
    80005c62:	fffff097          	auipc	ra,0xfffff
    80005c66:	cfa080e7          	jalr	-774(ra) # 8000495c <end_op>
  return 0;
    80005c6a:	4781                	li	a5,0
    80005c6c:	a085                	j	80005ccc <sys_link+0x13c>
    end_op();
    80005c6e:	fffff097          	auipc	ra,0xfffff
    80005c72:	cee080e7          	jalr	-786(ra) # 8000495c <end_op>
    return -1;
    80005c76:	57fd                	li	a5,-1
    80005c78:	a891                	j	80005ccc <sys_link+0x13c>
    iunlockput(ip);
    80005c7a:	8526                	mv	a0,s1
    80005c7c:	ffffe097          	auipc	ra,0xffffe
    80005c80:	500080e7          	jalr	1280(ra) # 8000417c <iunlockput>
    end_op();
    80005c84:	fffff097          	auipc	ra,0xfffff
    80005c88:	cd8080e7          	jalr	-808(ra) # 8000495c <end_op>
    return -1;
    80005c8c:	57fd                	li	a5,-1
    80005c8e:	a83d                	j	80005ccc <sys_link+0x13c>
    iunlockput(dp);
    80005c90:	854a                	mv	a0,s2
    80005c92:	ffffe097          	auipc	ra,0xffffe
    80005c96:	4ea080e7          	jalr	1258(ra) # 8000417c <iunlockput>
  ilock(ip);
    80005c9a:	8526                	mv	a0,s1
    80005c9c:	ffffe097          	auipc	ra,0xffffe
    80005ca0:	27e080e7          	jalr	638(ra) # 80003f1a <ilock>
  ip->nlink--;
    80005ca4:	04a4d783          	lhu	a5,74(s1)
    80005ca8:	37fd                	addiw	a5,a5,-1
    80005caa:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005cae:	8526                	mv	a0,s1
    80005cb0:	ffffe097          	auipc	ra,0xffffe
    80005cb4:	1a0080e7          	jalr	416(ra) # 80003e50 <iupdate>
  iunlockput(ip);
    80005cb8:	8526                	mv	a0,s1
    80005cba:	ffffe097          	auipc	ra,0xffffe
    80005cbe:	4c2080e7          	jalr	1218(ra) # 8000417c <iunlockput>
  end_op();
    80005cc2:	fffff097          	auipc	ra,0xfffff
    80005cc6:	c9a080e7          	jalr	-870(ra) # 8000495c <end_op>
  return -1;
    80005cca:	57fd                	li	a5,-1
}
    80005ccc:	853e                	mv	a0,a5
    80005cce:	70b2                	ld	ra,296(sp)
    80005cd0:	7412                	ld	s0,288(sp)
    80005cd2:	64f2                	ld	s1,280(sp)
    80005cd4:	6952                	ld	s2,272(sp)
    80005cd6:	6155                	addi	sp,sp,304
    80005cd8:	8082                	ret

0000000080005cda <sys_unlink>:
{
    80005cda:	7151                	addi	sp,sp,-240
    80005cdc:	f586                	sd	ra,232(sp)
    80005cde:	f1a2                	sd	s0,224(sp)
    80005ce0:	eda6                	sd	s1,216(sp)
    80005ce2:	e9ca                	sd	s2,208(sp)
    80005ce4:	e5ce                	sd	s3,200(sp)
    80005ce6:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005ce8:	08000613          	li	a2,128
    80005cec:	f3040593          	addi	a1,s0,-208
    80005cf0:	4501                	li	a0,0
    80005cf2:	ffffd097          	auipc	ra,0xffffd
    80005cf6:	44e080e7          	jalr	1102(ra) # 80003140 <argstr>
    80005cfa:	18054163          	bltz	a0,80005e7c <sys_unlink+0x1a2>
  begin_op();
    80005cfe:	fffff097          	auipc	ra,0xfffff
    80005d02:	bde080e7          	jalr	-1058(ra) # 800048dc <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005d06:	fb040593          	addi	a1,s0,-80
    80005d0a:	f3040513          	addi	a0,s0,-208
    80005d0e:	fffff097          	auipc	ra,0xfffff
    80005d12:	9d0080e7          	jalr	-1584(ra) # 800046de <nameiparent>
    80005d16:	84aa                	mv	s1,a0
    80005d18:	c979                	beqz	a0,80005dee <sys_unlink+0x114>
  ilock(dp);
    80005d1a:	ffffe097          	auipc	ra,0xffffe
    80005d1e:	200080e7          	jalr	512(ra) # 80003f1a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005d22:	00003597          	auipc	a1,0x3
    80005d26:	b9e58593          	addi	a1,a1,-1122 # 800088c0 <syscallnum+0x258>
    80005d2a:	fb040513          	addi	a0,s0,-80
    80005d2e:	ffffe097          	auipc	ra,0xffffe
    80005d32:	6b6080e7          	jalr	1718(ra) # 800043e4 <namecmp>
    80005d36:	14050a63          	beqz	a0,80005e8a <sys_unlink+0x1b0>
    80005d3a:	00003597          	auipc	a1,0x3
    80005d3e:	b8e58593          	addi	a1,a1,-1138 # 800088c8 <syscallnum+0x260>
    80005d42:	fb040513          	addi	a0,s0,-80
    80005d46:	ffffe097          	auipc	ra,0xffffe
    80005d4a:	69e080e7          	jalr	1694(ra) # 800043e4 <namecmp>
    80005d4e:	12050e63          	beqz	a0,80005e8a <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005d52:	f2c40613          	addi	a2,s0,-212
    80005d56:	fb040593          	addi	a1,s0,-80
    80005d5a:	8526                	mv	a0,s1
    80005d5c:	ffffe097          	auipc	ra,0xffffe
    80005d60:	6a2080e7          	jalr	1698(ra) # 800043fe <dirlookup>
    80005d64:	892a                	mv	s2,a0
    80005d66:	12050263          	beqz	a0,80005e8a <sys_unlink+0x1b0>
  ilock(ip);
    80005d6a:	ffffe097          	auipc	ra,0xffffe
    80005d6e:	1b0080e7          	jalr	432(ra) # 80003f1a <ilock>
  if(ip->nlink < 1)
    80005d72:	04a91783          	lh	a5,74(s2)
    80005d76:	08f05263          	blez	a5,80005dfa <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005d7a:	04491703          	lh	a4,68(s2)
    80005d7e:	4785                	li	a5,1
    80005d80:	08f70563          	beq	a4,a5,80005e0a <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005d84:	4641                	li	a2,16
    80005d86:	4581                	li	a1,0
    80005d88:	fc040513          	addi	a0,s0,-64
    80005d8c:	ffffb097          	auipc	ra,0xffffb
    80005d90:	f5a080e7          	jalr	-166(ra) # 80000ce6 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005d94:	4741                	li	a4,16
    80005d96:	f2c42683          	lw	a3,-212(s0)
    80005d9a:	fc040613          	addi	a2,s0,-64
    80005d9e:	4581                	li	a1,0
    80005da0:	8526                	mv	a0,s1
    80005da2:	ffffe097          	auipc	ra,0xffffe
    80005da6:	524080e7          	jalr	1316(ra) # 800042c6 <writei>
    80005daa:	47c1                	li	a5,16
    80005dac:	0af51563          	bne	a0,a5,80005e56 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005db0:	04491703          	lh	a4,68(s2)
    80005db4:	4785                	li	a5,1
    80005db6:	0af70863          	beq	a4,a5,80005e66 <sys_unlink+0x18c>
  iunlockput(dp);
    80005dba:	8526                	mv	a0,s1
    80005dbc:	ffffe097          	auipc	ra,0xffffe
    80005dc0:	3c0080e7          	jalr	960(ra) # 8000417c <iunlockput>
  ip->nlink--;
    80005dc4:	04a95783          	lhu	a5,74(s2)
    80005dc8:	37fd                	addiw	a5,a5,-1
    80005dca:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005dce:	854a                	mv	a0,s2
    80005dd0:	ffffe097          	auipc	ra,0xffffe
    80005dd4:	080080e7          	jalr	128(ra) # 80003e50 <iupdate>
  iunlockput(ip);
    80005dd8:	854a                	mv	a0,s2
    80005dda:	ffffe097          	auipc	ra,0xffffe
    80005dde:	3a2080e7          	jalr	930(ra) # 8000417c <iunlockput>
  end_op();
    80005de2:	fffff097          	auipc	ra,0xfffff
    80005de6:	b7a080e7          	jalr	-1158(ra) # 8000495c <end_op>
  return 0;
    80005dea:	4501                	li	a0,0
    80005dec:	a84d                	j	80005e9e <sys_unlink+0x1c4>
    end_op();
    80005dee:	fffff097          	auipc	ra,0xfffff
    80005df2:	b6e080e7          	jalr	-1170(ra) # 8000495c <end_op>
    return -1;
    80005df6:	557d                	li	a0,-1
    80005df8:	a05d                	j	80005e9e <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005dfa:	00003517          	auipc	a0,0x3
    80005dfe:	ad650513          	addi	a0,a0,-1322 # 800088d0 <syscallnum+0x268>
    80005e02:	ffffa097          	auipc	ra,0xffffa
    80005e06:	742080e7          	jalr	1858(ra) # 80000544 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005e0a:	04c92703          	lw	a4,76(s2)
    80005e0e:	02000793          	li	a5,32
    80005e12:	f6e7f9e3          	bgeu	a5,a4,80005d84 <sys_unlink+0xaa>
    80005e16:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005e1a:	4741                	li	a4,16
    80005e1c:	86ce                	mv	a3,s3
    80005e1e:	f1840613          	addi	a2,s0,-232
    80005e22:	4581                	li	a1,0
    80005e24:	854a                	mv	a0,s2
    80005e26:	ffffe097          	auipc	ra,0xffffe
    80005e2a:	3a8080e7          	jalr	936(ra) # 800041ce <readi>
    80005e2e:	47c1                	li	a5,16
    80005e30:	00f51b63          	bne	a0,a5,80005e46 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005e34:	f1845783          	lhu	a5,-232(s0)
    80005e38:	e7a1                	bnez	a5,80005e80 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005e3a:	29c1                	addiw	s3,s3,16
    80005e3c:	04c92783          	lw	a5,76(s2)
    80005e40:	fcf9ede3          	bltu	s3,a5,80005e1a <sys_unlink+0x140>
    80005e44:	b781                	j	80005d84 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005e46:	00003517          	auipc	a0,0x3
    80005e4a:	aa250513          	addi	a0,a0,-1374 # 800088e8 <syscallnum+0x280>
    80005e4e:	ffffa097          	auipc	ra,0xffffa
    80005e52:	6f6080e7          	jalr	1782(ra) # 80000544 <panic>
    panic("unlink: writei");
    80005e56:	00003517          	auipc	a0,0x3
    80005e5a:	aaa50513          	addi	a0,a0,-1366 # 80008900 <syscallnum+0x298>
    80005e5e:	ffffa097          	auipc	ra,0xffffa
    80005e62:	6e6080e7          	jalr	1766(ra) # 80000544 <panic>
    dp->nlink--;
    80005e66:	04a4d783          	lhu	a5,74(s1)
    80005e6a:	37fd                	addiw	a5,a5,-1
    80005e6c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005e70:	8526                	mv	a0,s1
    80005e72:	ffffe097          	auipc	ra,0xffffe
    80005e76:	fde080e7          	jalr	-34(ra) # 80003e50 <iupdate>
    80005e7a:	b781                	j	80005dba <sys_unlink+0xe0>
    return -1;
    80005e7c:	557d                	li	a0,-1
    80005e7e:	a005                	j	80005e9e <sys_unlink+0x1c4>
    iunlockput(ip);
    80005e80:	854a                	mv	a0,s2
    80005e82:	ffffe097          	auipc	ra,0xffffe
    80005e86:	2fa080e7          	jalr	762(ra) # 8000417c <iunlockput>
  iunlockput(dp);
    80005e8a:	8526                	mv	a0,s1
    80005e8c:	ffffe097          	auipc	ra,0xffffe
    80005e90:	2f0080e7          	jalr	752(ra) # 8000417c <iunlockput>
  end_op();
    80005e94:	fffff097          	auipc	ra,0xfffff
    80005e98:	ac8080e7          	jalr	-1336(ra) # 8000495c <end_op>
  return -1;
    80005e9c:	557d                	li	a0,-1
}
    80005e9e:	70ae                	ld	ra,232(sp)
    80005ea0:	740e                	ld	s0,224(sp)
    80005ea2:	64ee                	ld	s1,216(sp)
    80005ea4:	694e                	ld	s2,208(sp)
    80005ea6:	69ae                	ld	s3,200(sp)
    80005ea8:	616d                	addi	sp,sp,240
    80005eaa:	8082                	ret

0000000080005eac <sys_open>:

uint64
sys_open(void)
{
    80005eac:	7131                	addi	sp,sp,-192
    80005eae:	fd06                	sd	ra,184(sp)
    80005eb0:	f922                	sd	s0,176(sp)
    80005eb2:	f526                	sd	s1,168(sp)
    80005eb4:	f14a                	sd	s2,160(sp)
    80005eb6:	ed4e                	sd	s3,152(sp)
    80005eb8:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005eba:	f4c40593          	addi	a1,s0,-180
    80005ebe:	4505                	li	a0,1
    80005ec0:	ffffd097          	auipc	ra,0xffffd
    80005ec4:	23c080e7          	jalr	572(ra) # 800030fc <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005ec8:	08000613          	li	a2,128
    80005ecc:	f5040593          	addi	a1,s0,-176
    80005ed0:	4501                	li	a0,0
    80005ed2:	ffffd097          	auipc	ra,0xffffd
    80005ed6:	26e080e7          	jalr	622(ra) # 80003140 <argstr>
    80005eda:	87aa                	mv	a5,a0
    return -1;
    80005edc:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005ede:	0a07c963          	bltz	a5,80005f90 <sys_open+0xe4>

  begin_op();
    80005ee2:	fffff097          	auipc	ra,0xfffff
    80005ee6:	9fa080e7          	jalr	-1542(ra) # 800048dc <begin_op>

  if(omode & O_CREATE){
    80005eea:	f4c42783          	lw	a5,-180(s0)
    80005eee:	2007f793          	andi	a5,a5,512
    80005ef2:	cfc5                	beqz	a5,80005faa <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005ef4:	4681                	li	a3,0
    80005ef6:	4601                	li	a2,0
    80005ef8:	4589                	li	a1,2
    80005efa:	f5040513          	addi	a0,s0,-176
    80005efe:	00000097          	auipc	ra,0x0
    80005f02:	974080e7          	jalr	-1676(ra) # 80005872 <create>
    80005f06:	84aa                	mv	s1,a0
    if(ip == 0){
    80005f08:	c959                	beqz	a0,80005f9e <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005f0a:	04449703          	lh	a4,68(s1)
    80005f0e:	478d                	li	a5,3
    80005f10:	00f71763          	bne	a4,a5,80005f1e <sys_open+0x72>
    80005f14:	0464d703          	lhu	a4,70(s1)
    80005f18:	47a5                	li	a5,9
    80005f1a:	0ce7ed63          	bltu	a5,a4,80005ff4 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005f1e:	fffff097          	auipc	ra,0xfffff
    80005f22:	dce080e7          	jalr	-562(ra) # 80004cec <filealloc>
    80005f26:	89aa                	mv	s3,a0
    80005f28:	10050363          	beqz	a0,8000602e <sys_open+0x182>
    80005f2c:	00000097          	auipc	ra,0x0
    80005f30:	904080e7          	jalr	-1788(ra) # 80005830 <fdalloc>
    80005f34:	892a                	mv	s2,a0
    80005f36:	0e054763          	bltz	a0,80006024 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005f3a:	04449703          	lh	a4,68(s1)
    80005f3e:	478d                	li	a5,3
    80005f40:	0cf70563          	beq	a4,a5,8000600a <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005f44:	4789                	li	a5,2
    80005f46:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005f4a:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005f4e:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005f52:	f4c42783          	lw	a5,-180(s0)
    80005f56:	0017c713          	xori	a4,a5,1
    80005f5a:	8b05                	andi	a4,a4,1
    80005f5c:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005f60:	0037f713          	andi	a4,a5,3
    80005f64:	00e03733          	snez	a4,a4
    80005f68:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005f6c:	4007f793          	andi	a5,a5,1024
    80005f70:	c791                	beqz	a5,80005f7c <sys_open+0xd0>
    80005f72:	04449703          	lh	a4,68(s1)
    80005f76:	4789                	li	a5,2
    80005f78:	0af70063          	beq	a4,a5,80006018 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005f7c:	8526                	mv	a0,s1
    80005f7e:	ffffe097          	auipc	ra,0xffffe
    80005f82:	05e080e7          	jalr	94(ra) # 80003fdc <iunlock>
  end_op();
    80005f86:	fffff097          	auipc	ra,0xfffff
    80005f8a:	9d6080e7          	jalr	-1578(ra) # 8000495c <end_op>

  return fd;
    80005f8e:	854a                	mv	a0,s2
}
    80005f90:	70ea                	ld	ra,184(sp)
    80005f92:	744a                	ld	s0,176(sp)
    80005f94:	74aa                	ld	s1,168(sp)
    80005f96:	790a                	ld	s2,160(sp)
    80005f98:	69ea                	ld	s3,152(sp)
    80005f9a:	6129                	addi	sp,sp,192
    80005f9c:	8082                	ret
      end_op();
    80005f9e:	fffff097          	auipc	ra,0xfffff
    80005fa2:	9be080e7          	jalr	-1602(ra) # 8000495c <end_op>
      return -1;
    80005fa6:	557d                	li	a0,-1
    80005fa8:	b7e5                	j	80005f90 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005faa:	f5040513          	addi	a0,s0,-176
    80005fae:	ffffe097          	auipc	ra,0xffffe
    80005fb2:	712080e7          	jalr	1810(ra) # 800046c0 <namei>
    80005fb6:	84aa                	mv	s1,a0
    80005fb8:	c905                	beqz	a0,80005fe8 <sys_open+0x13c>
    ilock(ip);
    80005fba:	ffffe097          	auipc	ra,0xffffe
    80005fbe:	f60080e7          	jalr	-160(ra) # 80003f1a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005fc2:	04449703          	lh	a4,68(s1)
    80005fc6:	4785                	li	a5,1
    80005fc8:	f4f711e3          	bne	a4,a5,80005f0a <sys_open+0x5e>
    80005fcc:	f4c42783          	lw	a5,-180(s0)
    80005fd0:	d7b9                	beqz	a5,80005f1e <sys_open+0x72>
      iunlockput(ip);
    80005fd2:	8526                	mv	a0,s1
    80005fd4:	ffffe097          	auipc	ra,0xffffe
    80005fd8:	1a8080e7          	jalr	424(ra) # 8000417c <iunlockput>
      end_op();
    80005fdc:	fffff097          	auipc	ra,0xfffff
    80005fe0:	980080e7          	jalr	-1664(ra) # 8000495c <end_op>
      return -1;
    80005fe4:	557d                	li	a0,-1
    80005fe6:	b76d                	j	80005f90 <sys_open+0xe4>
      end_op();
    80005fe8:	fffff097          	auipc	ra,0xfffff
    80005fec:	974080e7          	jalr	-1676(ra) # 8000495c <end_op>
      return -1;
    80005ff0:	557d                	li	a0,-1
    80005ff2:	bf79                	j	80005f90 <sys_open+0xe4>
    iunlockput(ip);
    80005ff4:	8526                	mv	a0,s1
    80005ff6:	ffffe097          	auipc	ra,0xffffe
    80005ffa:	186080e7          	jalr	390(ra) # 8000417c <iunlockput>
    end_op();
    80005ffe:	fffff097          	auipc	ra,0xfffff
    80006002:	95e080e7          	jalr	-1698(ra) # 8000495c <end_op>
    return -1;
    80006006:	557d                	li	a0,-1
    80006008:	b761                	j	80005f90 <sys_open+0xe4>
    f->type = FD_DEVICE;
    8000600a:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    8000600e:	04649783          	lh	a5,70(s1)
    80006012:	02f99223          	sh	a5,36(s3)
    80006016:	bf25                	j	80005f4e <sys_open+0xa2>
    itrunc(ip);
    80006018:	8526                	mv	a0,s1
    8000601a:	ffffe097          	auipc	ra,0xffffe
    8000601e:	00e080e7          	jalr	14(ra) # 80004028 <itrunc>
    80006022:	bfa9                	j	80005f7c <sys_open+0xd0>
      fileclose(f);
    80006024:	854e                	mv	a0,s3
    80006026:	fffff097          	auipc	ra,0xfffff
    8000602a:	d82080e7          	jalr	-638(ra) # 80004da8 <fileclose>
    iunlockput(ip);
    8000602e:	8526                	mv	a0,s1
    80006030:	ffffe097          	auipc	ra,0xffffe
    80006034:	14c080e7          	jalr	332(ra) # 8000417c <iunlockput>
    end_op();
    80006038:	fffff097          	auipc	ra,0xfffff
    8000603c:	924080e7          	jalr	-1756(ra) # 8000495c <end_op>
    return -1;
    80006040:	557d                	li	a0,-1
    80006042:	b7b9                	j	80005f90 <sys_open+0xe4>

0000000080006044 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80006044:	7175                	addi	sp,sp,-144
    80006046:	e506                	sd	ra,136(sp)
    80006048:	e122                	sd	s0,128(sp)
    8000604a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000604c:	fffff097          	auipc	ra,0xfffff
    80006050:	890080e7          	jalr	-1904(ra) # 800048dc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80006054:	08000613          	li	a2,128
    80006058:	f7040593          	addi	a1,s0,-144
    8000605c:	4501                	li	a0,0
    8000605e:	ffffd097          	auipc	ra,0xffffd
    80006062:	0e2080e7          	jalr	226(ra) # 80003140 <argstr>
    80006066:	02054963          	bltz	a0,80006098 <sys_mkdir+0x54>
    8000606a:	4681                	li	a3,0
    8000606c:	4601                	li	a2,0
    8000606e:	4585                	li	a1,1
    80006070:	f7040513          	addi	a0,s0,-144
    80006074:	fffff097          	auipc	ra,0xfffff
    80006078:	7fe080e7          	jalr	2046(ra) # 80005872 <create>
    8000607c:	cd11                	beqz	a0,80006098 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000607e:	ffffe097          	auipc	ra,0xffffe
    80006082:	0fe080e7          	jalr	254(ra) # 8000417c <iunlockput>
  end_op();
    80006086:	fffff097          	auipc	ra,0xfffff
    8000608a:	8d6080e7          	jalr	-1834(ra) # 8000495c <end_op>
  return 0;
    8000608e:	4501                	li	a0,0
}
    80006090:	60aa                	ld	ra,136(sp)
    80006092:	640a                	ld	s0,128(sp)
    80006094:	6149                	addi	sp,sp,144
    80006096:	8082                	ret
    end_op();
    80006098:	fffff097          	auipc	ra,0xfffff
    8000609c:	8c4080e7          	jalr	-1852(ra) # 8000495c <end_op>
    return -1;
    800060a0:	557d                	li	a0,-1
    800060a2:	b7fd                	j	80006090 <sys_mkdir+0x4c>

00000000800060a4 <sys_mknod>:

uint64
sys_mknod(void)
{
    800060a4:	7135                	addi	sp,sp,-160
    800060a6:	ed06                	sd	ra,152(sp)
    800060a8:	e922                	sd	s0,144(sp)
    800060aa:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800060ac:	fffff097          	auipc	ra,0xfffff
    800060b0:	830080e7          	jalr	-2000(ra) # 800048dc <begin_op>
  argint(1, &major);
    800060b4:	f6c40593          	addi	a1,s0,-148
    800060b8:	4505                	li	a0,1
    800060ba:	ffffd097          	auipc	ra,0xffffd
    800060be:	042080e7          	jalr	66(ra) # 800030fc <argint>
  argint(2, &minor);
    800060c2:	f6840593          	addi	a1,s0,-152
    800060c6:	4509                	li	a0,2
    800060c8:	ffffd097          	auipc	ra,0xffffd
    800060cc:	034080e7          	jalr	52(ra) # 800030fc <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800060d0:	08000613          	li	a2,128
    800060d4:	f7040593          	addi	a1,s0,-144
    800060d8:	4501                	li	a0,0
    800060da:	ffffd097          	auipc	ra,0xffffd
    800060de:	066080e7          	jalr	102(ra) # 80003140 <argstr>
    800060e2:	02054b63          	bltz	a0,80006118 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800060e6:	f6841683          	lh	a3,-152(s0)
    800060ea:	f6c41603          	lh	a2,-148(s0)
    800060ee:	458d                	li	a1,3
    800060f0:	f7040513          	addi	a0,s0,-144
    800060f4:	fffff097          	auipc	ra,0xfffff
    800060f8:	77e080e7          	jalr	1918(ra) # 80005872 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800060fc:	cd11                	beqz	a0,80006118 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800060fe:	ffffe097          	auipc	ra,0xffffe
    80006102:	07e080e7          	jalr	126(ra) # 8000417c <iunlockput>
  end_op();
    80006106:	fffff097          	auipc	ra,0xfffff
    8000610a:	856080e7          	jalr	-1962(ra) # 8000495c <end_op>
  return 0;
    8000610e:	4501                	li	a0,0
}
    80006110:	60ea                	ld	ra,152(sp)
    80006112:	644a                	ld	s0,144(sp)
    80006114:	610d                	addi	sp,sp,160
    80006116:	8082                	ret
    end_op();
    80006118:	fffff097          	auipc	ra,0xfffff
    8000611c:	844080e7          	jalr	-1980(ra) # 8000495c <end_op>
    return -1;
    80006120:	557d                	li	a0,-1
    80006122:	b7fd                	j	80006110 <sys_mknod+0x6c>

0000000080006124 <sys_chdir>:

uint64
sys_chdir(void)
{
    80006124:	7135                	addi	sp,sp,-160
    80006126:	ed06                	sd	ra,152(sp)
    80006128:	e922                	sd	s0,144(sp)
    8000612a:	e526                	sd	s1,136(sp)
    8000612c:	e14a                	sd	s2,128(sp)
    8000612e:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006130:	ffffc097          	auipc	ra,0xffffc
    80006134:	896080e7          	jalr	-1898(ra) # 800019c6 <myproc>
    80006138:	892a                	mv	s2,a0
  
  begin_op();
    8000613a:	ffffe097          	auipc	ra,0xffffe
    8000613e:	7a2080e7          	jalr	1954(ra) # 800048dc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80006142:	08000613          	li	a2,128
    80006146:	f6040593          	addi	a1,s0,-160
    8000614a:	4501                	li	a0,0
    8000614c:	ffffd097          	auipc	ra,0xffffd
    80006150:	ff4080e7          	jalr	-12(ra) # 80003140 <argstr>
    80006154:	04054b63          	bltz	a0,800061aa <sys_chdir+0x86>
    80006158:	f6040513          	addi	a0,s0,-160
    8000615c:	ffffe097          	auipc	ra,0xffffe
    80006160:	564080e7          	jalr	1380(ra) # 800046c0 <namei>
    80006164:	84aa                	mv	s1,a0
    80006166:	c131                	beqz	a0,800061aa <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006168:	ffffe097          	auipc	ra,0xffffe
    8000616c:	db2080e7          	jalr	-590(ra) # 80003f1a <ilock>
  if(ip->type != T_DIR){
    80006170:	04449703          	lh	a4,68(s1)
    80006174:	4785                	li	a5,1
    80006176:	04f71063          	bne	a4,a5,800061b6 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000617a:	8526                	mv	a0,s1
    8000617c:	ffffe097          	auipc	ra,0xffffe
    80006180:	e60080e7          	jalr	-416(ra) # 80003fdc <iunlock>
  iput(p->cwd);
    80006184:	15093503          	ld	a0,336(s2)
    80006188:	ffffe097          	auipc	ra,0xffffe
    8000618c:	f4c080e7          	jalr	-180(ra) # 800040d4 <iput>
  end_op();
    80006190:	ffffe097          	auipc	ra,0xffffe
    80006194:	7cc080e7          	jalr	1996(ra) # 8000495c <end_op>
  p->cwd = ip;
    80006198:	14993823          	sd	s1,336(s2)
  return 0;
    8000619c:	4501                	li	a0,0
}
    8000619e:	60ea                	ld	ra,152(sp)
    800061a0:	644a                	ld	s0,144(sp)
    800061a2:	64aa                	ld	s1,136(sp)
    800061a4:	690a                	ld	s2,128(sp)
    800061a6:	610d                	addi	sp,sp,160
    800061a8:	8082                	ret
    end_op();
    800061aa:	ffffe097          	auipc	ra,0xffffe
    800061ae:	7b2080e7          	jalr	1970(ra) # 8000495c <end_op>
    return -1;
    800061b2:	557d                	li	a0,-1
    800061b4:	b7ed                	j	8000619e <sys_chdir+0x7a>
    iunlockput(ip);
    800061b6:	8526                	mv	a0,s1
    800061b8:	ffffe097          	auipc	ra,0xffffe
    800061bc:	fc4080e7          	jalr	-60(ra) # 8000417c <iunlockput>
    end_op();
    800061c0:	ffffe097          	auipc	ra,0xffffe
    800061c4:	79c080e7          	jalr	1948(ra) # 8000495c <end_op>
    return -1;
    800061c8:	557d                	li	a0,-1
    800061ca:	bfd1                	j	8000619e <sys_chdir+0x7a>

00000000800061cc <sys_exec>:

uint64
sys_exec(void)
{
    800061cc:	7145                	addi	sp,sp,-464
    800061ce:	e786                	sd	ra,456(sp)
    800061d0:	e3a2                	sd	s0,448(sp)
    800061d2:	ff26                	sd	s1,440(sp)
    800061d4:	fb4a                	sd	s2,432(sp)
    800061d6:	f74e                	sd	s3,424(sp)
    800061d8:	f352                	sd	s4,416(sp)
    800061da:	ef56                	sd	s5,408(sp)
    800061dc:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800061de:	e3840593          	addi	a1,s0,-456
    800061e2:	4505                	li	a0,1
    800061e4:	ffffd097          	auipc	ra,0xffffd
    800061e8:	f3a080e7          	jalr	-198(ra) # 8000311e <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800061ec:	08000613          	li	a2,128
    800061f0:	f4040593          	addi	a1,s0,-192
    800061f4:	4501                	li	a0,0
    800061f6:	ffffd097          	auipc	ra,0xffffd
    800061fa:	f4a080e7          	jalr	-182(ra) # 80003140 <argstr>
    800061fe:	87aa                	mv	a5,a0
    return -1;
    80006200:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80006202:	0c07c263          	bltz	a5,800062c6 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80006206:	10000613          	li	a2,256
    8000620a:	4581                	li	a1,0
    8000620c:	e4040513          	addi	a0,s0,-448
    80006210:	ffffb097          	auipc	ra,0xffffb
    80006214:	ad6080e7          	jalr	-1322(ra) # 80000ce6 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006218:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    8000621c:	89a6                	mv	s3,s1
    8000621e:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80006220:	02000a13          	li	s4,32
    80006224:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006228:	00391513          	slli	a0,s2,0x3
    8000622c:	e3040593          	addi	a1,s0,-464
    80006230:	e3843783          	ld	a5,-456(s0)
    80006234:	953e                	add	a0,a0,a5
    80006236:	ffffd097          	auipc	ra,0xffffd
    8000623a:	e28080e7          	jalr	-472(ra) # 8000305e <fetchaddr>
    8000623e:	02054a63          	bltz	a0,80006272 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80006242:	e3043783          	ld	a5,-464(s0)
    80006246:	c3b9                	beqz	a5,8000628c <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006248:	ffffb097          	auipc	ra,0xffffb
    8000624c:	8b2080e7          	jalr	-1870(ra) # 80000afa <kalloc>
    80006250:	85aa                	mv	a1,a0
    80006252:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006256:	cd11                	beqz	a0,80006272 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006258:	6605                	lui	a2,0x1
    8000625a:	e3043503          	ld	a0,-464(s0)
    8000625e:	ffffd097          	auipc	ra,0xffffd
    80006262:	e52080e7          	jalr	-430(ra) # 800030b0 <fetchstr>
    80006266:	00054663          	bltz	a0,80006272 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    8000626a:	0905                	addi	s2,s2,1
    8000626c:	09a1                	addi	s3,s3,8
    8000626e:	fb491be3          	bne	s2,s4,80006224 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006272:	10048913          	addi	s2,s1,256
    80006276:	6088                	ld	a0,0(s1)
    80006278:	c531                	beqz	a0,800062c4 <sys_exec+0xf8>
    kfree(argv[i]);
    8000627a:	ffffa097          	auipc	ra,0xffffa
    8000627e:	784080e7          	jalr	1924(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006282:	04a1                	addi	s1,s1,8
    80006284:	ff2499e3          	bne	s1,s2,80006276 <sys_exec+0xaa>
  return -1;
    80006288:	557d                	li	a0,-1
    8000628a:	a835                	j	800062c6 <sys_exec+0xfa>
      argv[i] = 0;
    8000628c:	0a8e                	slli	s5,s5,0x3
    8000628e:	fc040793          	addi	a5,s0,-64
    80006292:	9abe                	add	s5,s5,a5
    80006294:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80006298:	e4040593          	addi	a1,s0,-448
    8000629c:	f4040513          	addi	a0,s0,-192
    800062a0:	fffff097          	auipc	ra,0xfffff
    800062a4:	190080e7          	jalr	400(ra) # 80005430 <exec>
    800062a8:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800062aa:	10048993          	addi	s3,s1,256
    800062ae:	6088                	ld	a0,0(s1)
    800062b0:	c901                	beqz	a0,800062c0 <sys_exec+0xf4>
    kfree(argv[i]);
    800062b2:	ffffa097          	auipc	ra,0xffffa
    800062b6:	74c080e7          	jalr	1868(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800062ba:	04a1                	addi	s1,s1,8
    800062bc:	ff3499e3          	bne	s1,s3,800062ae <sys_exec+0xe2>
  return ret;
    800062c0:	854a                	mv	a0,s2
    800062c2:	a011                	j	800062c6 <sys_exec+0xfa>
  return -1;
    800062c4:	557d                	li	a0,-1
}
    800062c6:	60be                	ld	ra,456(sp)
    800062c8:	641e                	ld	s0,448(sp)
    800062ca:	74fa                	ld	s1,440(sp)
    800062cc:	795a                	ld	s2,432(sp)
    800062ce:	79ba                	ld	s3,424(sp)
    800062d0:	7a1a                	ld	s4,416(sp)
    800062d2:	6afa                	ld	s5,408(sp)
    800062d4:	6179                	addi	sp,sp,464
    800062d6:	8082                	ret

00000000800062d8 <sys_pipe>:

uint64
sys_pipe(void)
{
    800062d8:	7139                	addi	sp,sp,-64
    800062da:	fc06                	sd	ra,56(sp)
    800062dc:	f822                	sd	s0,48(sp)
    800062de:	f426                	sd	s1,40(sp)
    800062e0:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800062e2:	ffffb097          	auipc	ra,0xffffb
    800062e6:	6e4080e7          	jalr	1764(ra) # 800019c6 <myproc>
    800062ea:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800062ec:	fd840593          	addi	a1,s0,-40
    800062f0:	4501                	li	a0,0
    800062f2:	ffffd097          	auipc	ra,0xffffd
    800062f6:	e2c080e7          	jalr	-468(ra) # 8000311e <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800062fa:	fc840593          	addi	a1,s0,-56
    800062fe:	fd040513          	addi	a0,s0,-48
    80006302:	fffff097          	auipc	ra,0xfffff
    80006306:	dd6080e7          	jalr	-554(ra) # 800050d8 <pipealloc>
    return -1;
    8000630a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000630c:	0c054463          	bltz	a0,800063d4 <sys_pipe+0xfc>
  fd0 = -1;
    80006310:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006314:	fd043503          	ld	a0,-48(s0)
    80006318:	fffff097          	auipc	ra,0xfffff
    8000631c:	518080e7          	jalr	1304(ra) # 80005830 <fdalloc>
    80006320:	fca42223          	sw	a0,-60(s0)
    80006324:	08054b63          	bltz	a0,800063ba <sys_pipe+0xe2>
    80006328:	fc843503          	ld	a0,-56(s0)
    8000632c:	fffff097          	auipc	ra,0xfffff
    80006330:	504080e7          	jalr	1284(ra) # 80005830 <fdalloc>
    80006334:	fca42023          	sw	a0,-64(s0)
    80006338:	06054863          	bltz	a0,800063a8 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000633c:	4691                	li	a3,4
    8000633e:	fc440613          	addi	a2,s0,-60
    80006342:	fd843583          	ld	a1,-40(s0)
    80006346:	68a8                	ld	a0,80(s1)
    80006348:	ffffb097          	auipc	ra,0xffffb
    8000634c:	33c080e7          	jalr	828(ra) # 80001684 <copyout>
    80006350:	02054063          	bltz	a0,80006370 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006354:	4691                	li	a3,4
    80006356:	fc040613          	addi	a2,s0,-64
    8000635a:	fd843583          	ld	a1,-40(s0)
    8000635e:	0591                	addi	a1,a1,4
    80006360:	68a8                	ld	a0,80(s1)
    80006362:	ffffb097          	auipc	ra,0xffffb
    80006366:	322080e7          	jalr	802(ra) # 80001684 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000636a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000636c:	06055463          	bgez	a0,800063d4 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80006370:	fc442783          	lw	a5,-60(s0)
    80006374:	07e9                	addi	a5,a5,26
    80006376:	078e                	slli	a5,a5,0x3
    80006378:	97a6                	add	a5,a5,s1
    8000637a:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000637e:	fc042503          	lw	a0,-64(s0)
    80006382:	0569                	addi	a0,a0,26
    80006384:	050e                	slli	a0,a0,0x3
    80006386:	94aa                	add	s1,s1,a0
    80006388:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000638c:	fd043503          	ld	a0,-48(s0)
    80006390:	fffff097          	auipc	ra,0xfffff
    80006394:	a18080e7          	jalr	-1512(ra) # 80004da8 <fileclose>
    fileclose(wf);
    80006398:	fc843503          	ld	a0,-56(s0)
    8000639c:	fffff097          	auipc	ra,0xfffff
    800063a0:	a0c080e7          	jalr	-1524(ra) # 80004da8 <fileclose>
    return -1;
    800063a4:	57fd                	li	a5,-1
    800063a6:	a03d                	j	800063d4 <sys_pipe+0xfc>
    if(fd0 >= 0)
    800063a8:	fc442783          	lw	a5,-60(s0)
    800063ac:	0007c763          	bltz	a5,800063ba <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    800063b0:	07e9                	addi	a5,a5,26
    800063b2:	078e                	slli	a5,a5,0x3
    800063b4:	94be                	add	s1,s1,a5
    800063b6:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800063ba:	fd043503          	ld	a0,-48(s0)
    800063be:	fffff097          	auipc	ra,0xfffff
    800063c2:	9ea080e7          	jalr	-1558(ra) # 80004da8 <fileclose>
    fileclose(wf);
    800063c6:	fc843503          	ld	a0,-56(s0)
    800063ca:	fffff097          	auipc	ra,0xfffff
    800063ce:	9de080e7          	jalr	-1570(ra) # 80004da8 <fileclose>
    return -1;
    800063d2:	57fd                	li	a5,-1
}
    800063d4:	853e                	mv	a0,a5
    800063d6:	70e2                	ld	ra,56(sp)
    800063d8:	7442                	ld	s0,48(sp)
    800063da:	74a2                	ld	s1,40(sp)
    800063dc:	6121                	addi	sp,sp,64
    800063de:	8082                	ret

00000000800063e0 <kernelvec>:
    800063e0:	7111                	addi	sp,sp,-256
    800063e2:	e006                	sd	ra,0(sp)
    800063e4:	e40a                	sd	sp,8(sp)
    800063e6:	e80e                	sd	gp,16(sp)
    800063e8:	ec12                	sd	tp,24(sp)
    800063ea:	f016                	sd	t0,32(sp)
    800063ec:	f41a                	sd	t1,40(sp)
    800063ee:	f81e                	sd	t2,48(sp)
    800063f0:	fc22                	sd	s0,56(sp)
    800063f2:	e0a6                	sd	s1,64(sp)
    800063f4:	e4aa                	sd	a0,72(sp)
    800063f6:	e8ae                	sd	a1,80(sp)
    800063f8:	ecb2                	sd	a2,88(sp)
    800063fa:	f0b6                	sd	a3,96(sp)
    800063fc:	f4ba                	sd	a4,104(sp)
    800063fe:	f8be                	sd	a5,112(sp)
    80006400:	fcc2                	sd	a6,120(sp)
    80006402:	e146                	sd	a7,128(sp)
    80006404:	e54a                	sd	s2,136(sp)
    80006406:	e94e                	sd	s3,144(sp)
    80006408:	ed52                	sd	s4,152(sp)
    8000640a:	f156                	sd	s5,160(sp)
    8000640c:	f55a                	sd	s6,168(sp)
    8000640e:	f95e                	sd	s7,176(sp)
    80006410:	fd62                	sd	s8,184(sp)
    80006412:	e1e6                	sd	s9,192(sp)
    80006414:	e5ea                	sd	s10,200(sp)
    80006416:	e9ee                	sd	s11,208(sp)
    80006418:	edf2                	sd	t3,216(sp)
    8000641a:	f1f6                	sd	t4,224(sp)
    8000641c:	f5fa                	sd	t5,232(sp)
    8000641e:	f9fe                	sd	t6,240(sp)
    80006420:	b0bfc0ef          	jal	ra,80002f2a <kerneltrap>
    80006424:	6082                	ld	ra,0(sp)
    80006426:	6122                	ld	sp,8(sp)
    80006428:	61c2                	ld	gp,16(sp)
    8000642a:	7282                	ld	t0,32(sp)
    8000642c:	7322                	ld	t1,40(sp)
    8000642e:	73c2                	ld	t2,48(sp)
    80006430:	7462                	ld	s0,56(sp)
    80006432:	6486                	ld	s1,64(sp)
    80006434:	6526                	ld	a0,72(sp)
    80006436:	65c6                	ld	a1,80(sp)
    80006438:	6666                	ld	a2,88(sp)
    8000643a:	7686                	ld	a3,96(sp)
    8000643c:	7726                	ld	a4,104(sp)
    8000643e:	77c6                	ld	a5,112(sp)
    80006440:	7866                	ld	a6,120(sp)
    80006442:	688a                	ld	a7,128(sp)
    80006444:	692a                	ld	s2,136(sp)
    80006446:	69ca                	ld	s3,144(sp)
    80006448:	6a6a                	ld	s4,152(sp)
    8000644a:	7a8a                	ld	s5,160(sp)
    8000644c:	7b2a                	ld	s6,168(sp)
    8000644e:	7bca                	ld	s7,176(sp)
    80006450:	7c6a                	ld	s8,184(sp)
    80006452:	6c8e                	ld	s9,192(sp)
    80006454:	6d2e                	ld	s10,200(sp)
    80006456:	6dce                	ld	s11,208(sp)
    80006458:	6e6e                	ld	t3,216(sp)
    8000645a:	7e8e                	ld	t4,224(sp)
    8000645c:	7f2e                	ld	t5,232(sp)
    8000645e:	7fce                	ld	t6,240(sp)
    80006460:	6111                	addi	sp,sp,256
    80006462:	10200073          	sret
    80006466:	00000013          	nop
    8000646a:	00000013          	nop
    8000646e:	0001                	nop

0000000080006470 <timervec>:
    80006470:	34051573          	csrrw	a0,mscratch,a0
    80006474:	e10c                	sd	a1,0(a0)
    80006476:	e510                	sd	a2,8(a0)
    80006478:	e914                	sd	a3,16(a0)
    8000647a:	6d0c                	ld	a1,24(a0)
    8000647c:	7110                	ld	a2,32(a0)
    8000647e:	6194                	ld	a3,0(a1)
    80006480:	96b2                	add	a3,a3,a2
    80006482:	e194                	sd	a3,0(a1)
    80006484:	4589                	li	a1,2
    80006486:	14459073          	csrw	sip,a1
    8000648a:	6914                	ld	a3,16(a0)
    8000648c:	6510                	ld	a2,8(a0)
    8000648e:	610c                	ld	a1,0(a0)
    80006490:	34051573          	csrrw	a0,mscratch,a0
    80006494:	30200073          	mret
	...

000000008000649a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000649a:	1141                	addi	sp,sp,-16
    8000649c:	e422                	sd	s0,8(sp)
    8000649e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800064a0:	0c0007b7          	lui	a5,0xc000
    800064a4:	4705                	li	a4,1
    800064a6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800064a8:	c3d8                	sw	a4,4(a5)
}
    800064aa:	6422                	ld	s0,8(sp)
    800064ac:	0141                	addi	sp,sp,16
    800064ae:	8082                	ret

00000000800064b0 <plicinithart>:

void
plicinithart(void)
{
    800064b0:	1141                	addi	sp,sp,-16
    800064b2:	e406                	sd	ra,8(sp)
    800064b4:	e022                	sd	s0,0(sp)
    800064b6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800064b8:	ffffb097          	auipc	ra,0xffffb
    800064bc:	4e2080e7          	jalr	1250(ra) # 8000199a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800064c0:	0085171b          	slliw	a4,a0,0x8
    800064c4:	0c0027b7          	lui	a5,0xc002
    800064c8:	97ba                	add	a5,a5,a4
    800064ca:	40200713          	li	a4,1026
    800064ce:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800064d2:	00d5151b          	slliw	a0,a0,0xd
    800064d6:	0c2017b7          	lui	a5,0xc201
    800064da:	953e                	add	a0,a0,a5
    800064dc:	00052023          	sw	zero,0(a0)
}
    800064e0:	60a2                	ld	ra,8(sp)
    800064e2:	6402                	ld	s0,0(sp)
    800064e4:	0141                	addi	sp,sp,16
    800064e6:	8082                	ret

00000000800064e8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800064e8:	1141                	addi	sp,sp,-16
    800064ea:	e406                	sd	ra,8(sp)
    800064ec:	e022                	sd	s0,0(sp)
    800064ee:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800064f0:	ffffb097          	auipc	ra,0xffffb
    800064f4:	4aa080e7          	jalr	1194(ra) # 8000199a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800064f8:	00d5179b          	slliw	a5,a0,0xd
    800064fc:	0c201537          	lui	a0,0xc201
    80006500:	953e                	add	a0,a0,a5
  return irq;
}
    80006502:	4148                	lw	a0,4(a0)
    80006504:	60a2                	ld	ra,8(sp)
    80006506:	6402                	ld	s0,0(sp)
    80006508:	0141                	addi	sp,sp,16
    8000650a:	8082                	ret

000000008000650c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000650c:	1101                	addi	sp,sp,-32
    8000650e:	ec06                	sd	ra,24(sp)
    80006510:	e822                	sd	s0,16(sp)
    80006512:	e426                	sd	s1,8(sp)
    80006514:	1000                	addi	s0,sp,32
    80006516:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006518:	ffffb097          	auipc	ra,0xffffb
    8000651c:	482080e7          	jalr	1154(ra) # 8000199a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006520:	00d5151b          	slliw	a0,a0,0xd
    80006524:	0c2017b7          	lui	a5,0xc201
    80006528:	97aa                	add	a5,a5,a0
    8000652a:	c3c4                	sw	s1,4(a5)
}
    8000652c:	60e2                	ld	ra,24(sp)
    8000652e:	6442                	ld	s0,16(sp)
    80006530:	64a2                	ld	s1,8(sp)
    80006532:	6105                	addi	sp,sp,32
    80006534:	8082                	ret

0000000080006536 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006536:	1141                	addi	sp,sp,-16
    80006538:	e406                	sd	ra,8(sp)
    8000653a:	e022                	sd	s0,0(sp)
    8000653c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000653e:	479d                	li	a5,7
    80006540:	04a7cc63          	blt	a5,a0,80006598 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006544:	0001e797          	auipc	a5,0x1e
    80006548:	b9c78793          	addi	a5,a5,-1124 # 800240e0 <disk>
    8000654c:	97aa                	add	a5,a5,a0
    8000654e:	0187c783          	lbu	a5,24(a5)
    80006552:	ebb9                	bnez	a5,800065a8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006554:	00451613          	slli	a2,a0,0x4
    80006558:	0001e797          	auipc	a5,0x1e
    8000655c:	b8878793          	addi	a5,a5,-1144 # 800240e0 <disk>
    80006560:	6394                	ld	a3,0(a5)
    80006562:	96b2                	add	a3,a3,a2
    80006564:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006568:	6398                	ld	a4,0(a5)
    8000656a:	9732                	add	a4,a4,a2
    8000656c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006570:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006574:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006578:	953e                	add	a0,a0,a5
    8000657a:	4785                	li	a5,1
    8000657c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006580:	0001e517          	auipc	a0,0x1e
    80006584:	b7850513          	addi	a0,a0,-1160 # 800240f8 <disk+0x18>
    80006588:	ffffc097          	auipc	ra,0xffffc
    8000658c:	042080e7          	jalr	66(ra) # 800025ca <wakeup>
}
    80006590:	60a2                	ld	ra,8(sp)
    80006592:	6402                	ld	s0,0(sp)
    80006594:	0141                	addi	sp,sp,16
    80006596:	8082                	ret
    panic("free_desc 1");
    80006598:	00002517          	auipc	a0,0x2
    8000659c:	37850513          	addi	a0,a0,888 # 80008910 <syscallnum+0x2a8>
    800065a0:	ffffa097          	auipc	ra,0xffffa
    800065a4:	fa4080e7          	jalr	-92(ra) # 80000544 <panic>
    panic("free_desc 2");
    800065a8:	00002517          	auipc	a0,0x2
    800065ac:	37850513          	addi	a0,a0,888 # 80008920 <syscallnum+0x2b8>
    800065b0:	ffffa097          	auipc	ra,0xffffa
    800065b4:	f94080e7          	jalr	-108(ra) # 80000544 <panic>

00000000800065b8 <virtio_disk_init>:
{
    800065b8:	1101                	addi	sp,sp,-32
    800065ba:	ec06                	sd	ra,24(sp)
    800065bc:	e822                	sd	s0,16(sp)
    800065be:	e426                	sd	s1,8(sp)
    800065c0:	e04a                	sd	s2,0(sp)
    800065c2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800065c4:	00002597          	auipc	a1,0x2
    800065c8:	36c58593          	addi	a1,a1,876 # 80008930 <syscallnum+0x2c8>
    800065cc:	0001e517          	auipc	a0,0x1e
    800065d0:	c3c50513          	addi	a0,a0,-964 # 80024208 <disk+0x128>
    800065d4:	ffffa097          	auipc	ra,0xffffa
    800065d8:	586080e7          	jalr	1414(ra) # 80000b5a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800065dc:	100017b7          	lui	a5,0x10001
    800065e0:	4398                	lw	a4,0(a5)
    800065e2:	2701                	sext.w	a4,a4
    800065e4:	747277b7          	lui	a5,0x74727
    800065e8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800065ec:	14f71e63          	bne	a4,a5,80006748 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800065f0:	100017b7          	lui	a5,0x10001
    800065f4:	43dc                	lw	a5,4(a5)
    800065f6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800065f8:	4709                	li	a4,2
    800065fa:	14e79763          	bne	a5,a4,80006748 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800065fe:	100017b7          	lui	a5,0x10001
    80006602:	479c                	lw	a5,8(a5)
    80006604:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006606:	14e79163          	bne	a5,a4,80006748 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000660a:	100017b7          	lui	a5,0x10001
    8000660e:	47d8                	lw	a4,12(a5)
    80006610:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006612:	554d47b7          	lui	a5,0x554d4
    80006616:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000661a:	12f71763          	bne	a4,a5,80006748 <virtio_disk_init+0x190>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000661e:	100017b7          	lui	a5,0x10001
    80006622:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006626:	4705                	li	a4,1
    80006628:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000662a:	470d                	li	a4,3
    8000662c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000662e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006630:	c7ffe737          	lui	a4,0xc7ffe
    80006634:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fda53f>
    80006638:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000663a:	2701                	sext.w	a4,a4
    8000663c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000663e:	472d                	li	a4,11
    80006640:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006642:	0707a903          	lw	s2,112(a5)
    80006646:	2901                	sext.w	s2,s2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006648:	00897793          	andi	a5,s2,8
    8000664c:	10078663          	beqz	a5,80006758 <virtio_disk_init+0x1a0>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006650:	100017b7          	lui	a5,0x10001
    80006654:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006658:	43fc                	lw	a5,68(a5)
    8000665a:	2781                	sext.w	a5,a5
    8000665c:	10079663          	bnez	a5,80006768 <virtio_disk_init+0x1b0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006660:	100017b7          	lui	a5,0x10001
    80006664:	5bdc                	lw	a5,52(a5)
    80006666:	2781                	sext.w	a5,a5
  if(max == 0)
    80006668:	10078863          	beqz	a5,80006778 <virtio_disk_init+0x1c0>
  if(max < NUM)
    8000666c:	471d                	li	a4,7
    8000666e:	10f77d63          	bgeu	a4,a5,80006788 <virtio_disk_init+0x1d0>
  disk.desc = kalloc();
    80006672:	ffffa097          	auipc	ra,0xffffa
    80006676:	488080e7          	jalr	1160(ra) # 80000afa <kalloc>
    8000667a:	0001e497          	auipc	s1,0x1e
    8000667e:	a6648493          	addi	s1,s1,-1434 # 800240e0 <disk>
    80006682:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006684:	ffffa097          	auipc	ra,0xffffa
    80006688:	476080e7          	jalr	1142(ra) # 80000afa <kalloc>
    8000668c:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000668e:	ffffa097          	auipc	ra,0xffffa
    80006692:	46c080e7          	jalr	1132(ra) # 80000afa <kalloc>
    80006696:	87aa                	mv	a5,a0
    80006698:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    8000669a:	6088                	ld	a0,0(s1)
    8000669c:	cd75                	beqz	a0,80006798 <virtio_disk_init+0x1e0>
    8000669e:	0001e717          	auipc	a4,0x1e
    800066a2:	a4a73703          	ld	a4,-1462(a4) # 800240e8 <disk+0x8>
    800066a6:	cb6d                	beqz	a4,80006798 <virtio_disk_init+0x1e0>
    800066a8:	cbe5                	beqz	a5,80006798 <virtio_disk_init+0x1e0>
  memset(disk.desc, 0, PGSIZE);
    800066aa:	6605                	lui	a2,0x1
    800066ac:	4581                	li	a1,0
    800066ae:	ffffa097          	auipc	ra,0xffffa
    800066b2:	638080e7          	jalr	1592(ra) # 80000ce6 <memset>
  memset(disk.avail, 0, PGSIZE);
    800066b6:	0001e497          	auipc	s1,0x1e
    800066ba:	a2a48493          	addi	s1,s1,-1494 # 800240e0 <disk>
    800066be:	6605                	lui	a2,0x1
    800066c0:	4581                	li	a1,0
    800066c2:	6488                	ld	a0,8(s1)
    800066c4:	ffffa097          	auipc	ra,0xffffa
    800066c8:	622080e7          	jalr	1570(ra) # 80000ce6 <memset>
  memset(disk.used, 0, PGSIZE);
    800066cc:	6605                	lui	a2,0x1
    800066ce:	4581                	li	a1,0
    800066d0:	6888                	ld	a0,16(s1)
    800066d2:	ffffa097          	auipc	ra,0xffffa
    800066d6:	614080e7          	jalr	1556(ra) # 80000ce6 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800066da:	100017b7          	lui	a5,0x10001
    800066de:	4721                	li	a4,8
    800066e0:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800066e2:	4098                	lw	a4,0(s1)
    800066e4:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800066e8:	40d8                	lw	a4,4(s1)
    800066ea:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800066ee:	6498                	ld	a4,8(s1)
    800066f0:	0007069b          	sext.w	a3,a4
    800066f4:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800066f8:	9701                	srai	a4,a4,0x20
    800066fa:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800066fe:	6898                	ld	a4,16(s1)
    80006700:	0007069b          	sext.w	a3,a4
    80006704:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006708:	9701                	srai	a4,a4,0x20
    8000670a:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000670e:	4685                	li	a3,1
    80006710:	c3f4                	sw	a3,68(a5)
    disk.free[i] = 1;
    80006712:	4705                	li	a4,1
    80006714:	00d48c23          	sb	a3,24(s1)
    80006718:	00e48ca3          	sb	a4,25(s1)
    8000671c:	00e48d23          	sb	a4,26(s1)
    80006720:	00e48da3          	sb	a4,27(s1)
    80006724:	00e48e23          	sb	a4,28(s1)
    80006728:	00e48ea3          	sb	a4,29(s1)
    8000672c:	00e48f23          	sb	a4,30(s1)
    80006730:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006734:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006738:	0727a823          	sw	s2,112(a5)
}
    8000673c:	60e2                	ld	ra,24(sp)
    8000673e:	6442                	ld	s0,16(sp)
    80006740:	64a2                	ld	s1,8(sp)
    80006742:	6902                	ld	s2,0(sp)
    80006744:	6105                	addi	sp,sp,32
    80006746:	8082                	ret
    panic("could not find virtio disk");
    80006748:	00002517          	auipc	a0,0x2
    8000674c:	1f850513          	addi	a0,a0,504 # 80008940 <syscallnum+0x2d8>
    80006750:	ffffa097          	auipc	ra,0xffffa
    80006754:	df4080e7          	jalr	-524(ra) # 80000544 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006758:	00002517          	auipc	a0,0x2
    8000675c:	20850513          	addi	a0,a0,520 # 80008960 <syscallnum+0x2f8>
    80006760:	ffffa097          	auipc	ra,0xffffa
    80006764:	de4080e7          	jalr	-540(ra) # 80000544 <panic>
    panic("virtio disk should not be ready");
    80006768:	00002517          	auipc	a0,0x2
    8000676c:	21850513          	addi	a0,a0,536 # 80008980 <syscallnum+0x318>
    80006770:	ffffa097          	auipc	ra,0xffffa
    80006774:	dd4080e7          	jalr	-556(ra) # 80000544 <panic>
    panic("virtio disk has no queue 0");
    80006778:	00002517          	auipc	a0,0x2
    8000677c:	22850513          	addi	a0,a0,552 # 800089a0 <syscallnum+0x338>
    80006780:	ffffa097          	auipc	ra,0xffffa
    80006784:	dc4080e7          	jalr	-572(ra) # 80000544 <panic>
    panic("virtio disk max queue too short");
    80006788:	00002517          	auipc	a0,0x2
    8000678c:	23850513          	addi	a0,a0,568 # 800089c0 <syscallnum+0x358>
    80006790:	ffffa097          	auipc	ra,0xffffa
    80006794:	db4080e7          	jalr	-588(ra) # 80000544 <panic>
    panic("virtio disk kalloc");
    80006798:	00002517          	auipc	a0,0x2
    8000679c:	24850513          	addi	a0,a0,584 # 800089e0 <syscallnum+0x378>
    800067a0:	ffffa097          	auipc	ra,0xffffa
    800067a4:	da4080e7          	jalr	-604(ra) # 80000544 <panic>

00000000800067a8 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800067a8:	7159                	addi	sp,sp,-112
    800067aa:	f486                	sd	ra,104(sp)
    800067ac:	f0a2                	sd	s0,96(sp)
    800067ae:	eca6                	sd	s1,88(sp)
    800067b0:	e8ca                	sd	s2,80(sp)
    800067b2:	e4ce                	sd	s3,72(sp)
    800067b4:	e0d2                	sd	s4,64(sp)
    800067b6:	fc56                	sd	s5,56(sp)
    800067b8:	f85a                	sd	s6,48(sp)
    800067ba:	f45e                	sd	s7,40(sp)
    800067bc:	f062                	sd	s8,32(sp)
    800067be:	ec66                	sd	s9,24(sp)
    800067c0:	e86a                	sd	s10,16(sp)
    800067c2:	1880                	addi	s0,sp,112
    800067c4:	892a                	mv	s2,a0
    800067c6:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800067c8:	00c52c83          	lw	s9,12(a0)
    800067cc:	001c9c9b          	slliw	s9,s9,0x1
    800067d0:	1c82                	slli	s9,s9,0x20
    800067d2:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800067d6:	0001e517          	auipc	a0,0x1e
    800067da:	a3250513          	addi	a0,a0,-1486 # 80024208 <disk+0x128>
    800067de:	ffffa097          	auipc	ra,0xffffa
    800067e2:	40c080e7          	jalr	1036(ra) # 80000bea <acquire>
  for(int i = 0; i < 3; i++){
    800067e6:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800067e8:	4ba1                	li	s7,8
      disk.free[i] = 0;
    800067ea:	0001eb17          	auipc	s6,0x1e
    800067ee:	8f6b0b13          	addi	s6,s6,-1802 # 800240e0 <disk>
  for(int i = 0; i < 3; i++){
    800067f2:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    800067f4:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800067f6:	0001ec17          	auipc	s8,0x1e
    800067fa:	a12c0c13          	addi	s8,s8,-1518 # 80024208 <disk+0x128>
    800067fe:	a8b5                	j	8000687a <virtio_disk_rw+0xd2>
      disk.free[i] = 0;
    80006800:	00fb06b3          	add	a3,s6,a5
    80006804:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006808:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000680a:	0207c563          	bltz	a5,80006834 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000680e:	2485                	addiw	s1,s1,1
    80006810:	0711                	addi	a4,a4,4
    80006812:	1f548a63          	beq	s1,s5,80006a06 <virtio_disk_rw+0x25e>
    idx[i] = alloc_desc();
    80006816:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006818:	0001e697          	auipc	a3,0x1e
    8000681c:	8c868693          	addi	a3,a3,-1848 # 800240e0 <disk>
    80006820:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80006822:	0186c583          	lbu	a1,24(a3)
    80006826:	fde9                	bnez	a1,80006800 <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006828:	2785                	addiw	a5,a5,1
    8000682a:	0685                	addi	a3,a3,1
    8000682c:	ff779be3          	bne	a5,s7,80006822 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    80006830:	57fd                	li	a5,-1
    80006832:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80006834:	02905a63          	blez	s1,80006868 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    80006838:	f9042503          	lw	a0,-112(s0)
    8000683c:	00000097          	auipc	ra,0x0
    80006840:	cfa080e7          	jalr	-774(ra) # 80006536 <free_desc>
      for(int j = 0; j < i; j++)
    80006844:	4785                	li	a5,1
    80006846:	0297d163          	bge	a5,s1,80006868 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000684a:	f9442503          	lw	a0,-108(s0)
    8000684e:	00000097          	auipc	ra,0x0
    80006852:	ce8080e7          	jalr	-792(ra) # 80006536 <free_desc>
      for(int j = 0; j < i; j++)
    80006856:	4789                	li	a5,2
    80006858:	0097d863          	bge	a5,s1,80006868 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000685c:	f9842503          	lw	a0,-104(s0)
    80006860:	00000097          	auipc	ra,0x0
    80006864:	cd6080e7          	jalr	-810(ra) # 80006536 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006868:	85e2                	mv	a1,s8
    8000686a:	0001e517          	auipc	a0,0x1e
    8000686e:	88e50513          	addi	a0,a0,-1906 # 800240f8 <disk+0x18>
    80006872:	ffffc097          	auipc	ra,0xffffc
    80006876:	ba8080e7          	jalr	-1112(ra) # 8000241a <sleep>
  for(int i = 0; i < 3; i++){
    8000687a:	f9040713          	addi	a4,s0,-112
    8000687e:	84ce                	mv	s1,s3
    80006880:	bf59                	j	80006816 <virtio_disk_rw+0x6e>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80006882:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    80006886:	00479693          	slli	a3,a5,0x4
    8000688a:	0001e797          	auipc	a5,0x1e
    8000688e:	85678793          	addi	a5,a5,-1962 # 800240e0 <disk>
    80006892:	97b6                	add	a5,a5,a3
    80006894:	4685                	li	a3,1
    80006896:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006898:	0001e597          	auipc	a1,0x1e
    8000689c:	84858593          	addi	a1,a1,-1976 # 800240e0 <disk>
    800068a0:	00a60793          	addi	a5,a2,10
    800068a4:	0792                	slli	a5,a5,0x4
    800068a6:	97ae                	add	a5,a5,a1
    800068a8:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    800068ac:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800068b0:	f6070693          	addi	a3,a4,-160
    800068b4:	619c                	ld	a5,0(a1)
    800068b6:	97b6                	add	a5,a5,a3
    800068b8:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800068ba:	6188                	ld	a0,0(a1)
    800068bc:	96aa                	add	a3,a3,a0
    800068be:	47c1                	li	a5,16
    800068c0:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800068c2:	4785                	li	a5,1
    800068c4:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    800068c8:	f9442783          	lw	a5,-108(s0)
    800068cc:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800068d0:	0792                	slli	a5,a5,0x4
    800068d2:	953e                	add	a0,a0,a5
    800068d4:	05890693          	addi	a3,s2,88
    800068d8:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    800068da:	6188                	ld	a0,0(a1)
    800068dc:	97aa                	add	a5,a5,a0
    800068de:	40000693          	li	a3,1024
    800068e2:	c794                	sw	a3,8(a5)
  if(write)
    800068e4:	100d0d63          	beqz	s10,800069fe <virtio_disk_rw+0x256>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800068e8:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800068ec:	00c7d683          	lhu	a3,12(a5)
    800068f0:	0016e693          	ori	a3,a3,1
    800068f4:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    800068f8:	f9842583          	lw	a1,-104(s0)
    800068fc:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006900:	0001d697          	auipc	a3,0x1d
    80006904:	7e068693          	addi	a3,a3,2016 # 800240e0 <disk>
    80006908:	00260793          	addi	a5,a2,2
    8000690c:	0792                	slli	a5,a5,0x4
    8000690e:	97b6                	add	a5,a5,a3
    80006910:	587d                	li	a6,-1
    80006912:	01078823          	sb	a6,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006916:	0592                	slli	a1,a1,0x4
    80006918:	952e                	add	a0,a0,a1
    8000691a:	f9070713          	addi	a4,a4,-112
    8000691e:	9736                	add	a4,a4,a3
    80006920:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    80006922:	6298                	ld	a4,0(a3)
    80006924:	972e                	add	a4,a4,a1
    80006926:	4585                	li	a1,1
    80006928:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000692a:	4509                	li	a0,2
    8000692c:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    80006930:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006934:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    80006938:	0127b423          	sd	s2,8(a5)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000693c:	6698                	ld	a4,8(a3)
    8000693e:	00275783          	lhu	a5,2(a4)
    80006942:	8b9d                	andi	a5,a5,7
    80006944:	0786                	slli	a5,a5,0x1
    80006946:	97ba                	add	a5,a5,a4
    80006948:	00c79223          	sh	a2,4(a5)

  __sync_synchronize();
    8000694c:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006950:	6698                	ld	a4,8(a3)
    80006952:	00275783          	lhu	a5,2(a4)
    80006956:	2785                	addiw	a5,a5,1
    80006958:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000695c:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006960:	100017b7          	lui	a5,0x10001
    80006964:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006968:	00492703          	lw	a4,4(s2)
    8000696c:	4785                	li	a5,1
    8000696e:	02f71163          	bne	a4,a5,80006990 <virtio_disk_rw+0x1e8>
    sleep(b, &disk.vdisk_lock);
    80006972:	0001e997          	auipc	s3,0x1e
    80006976:	89698993          	addi	s3,s3,-1898 # 80024208 <disk+0x128>
  while(b->disk == 1) {
    8000697a:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000697c:	85ce                	mv	a1,s3
    8000697e:	854a                	mv	a0,s2
    80006980:	ffffc097          	auipc	ra,0xffffc
    80006984:	a9a080e7          	jalr	-1382(ra) # 8000241a <sleep>
  while(b->disk == 1) {
    80006988:	00492783          	lw	a5,4(s2)
    8000698c:	fe9788e3          	beq	a5,s1,8000697c <virtio_disk_rw+0x1d4>
  }

  disk.info[idx[0]].b = 0;
    80006990:	f9042903          	lw	s2,-112(s0)
    80006994:	00290793          	addi	a5,s2,2
    80006998:	00479713          	slli	a4,a5,0x4
    8000699c:	0001d797          	auipc	a5,0x1d
    800069a0:	74478793          	addi	a5,a5,1860 # 800240e0 <disk>
    800069a4:	97ba                	add	a5,a5,a4
    800069a6:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800069aa:	0001d997          	auipc	s3,0x1d
    800069ae:	73698993          	addi	s3,s3,1846 # 800240e0 <disk>
    800069b2:	00491713          	slli	a4,s2,0x4
    800069b6:	0009b783          	ld	a5,0(s3)
    800069ba:	97ba                	add	a5,a5,a4
    800069bc:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800069c0:	854a                	mv	a0,s2
    800069c2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800069c6:	00000097          	auipc	ra,0x0
    800069ca:	b70080e7          	jalr	-1168(ra) # 80006536 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800069ce:	8885                	andi	s1,s1,1
    800069d0:	f0ed                	bnez	s1,800069b2 <virtio_disk_rw+0x20a>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800069d2:	0001e517          	auipc	a0,0x1e
    800069d6:	83650513          	addi	a0,a0,-1994 # 80024208 <disk+0x128>
    800069da:	ffffa097          	auipc	ra,0xffffa
    800069de:	2c4080e7          	jalr	708(ra) # 80000c9e <release>
}
    800069e2:	70a6                	ld	ra,104(sp)
    800069e4:	7406                	ld	s0,96(sp)
    800069e6:	64e6                	ld	s1,88(sp)
    800069e8:	6946                	ld	s2,80(sp)
    800069ea:	69a6                	ld	s3,72(sp)
    800069ec:	6a06                	ld	s4,64(sp)
    800069ee:	7ae2                	ld	s5,56(sp)
    800069f0:	7b42                	ld	s6,48(sp)
    800069f2:	7ba2                	ld	s7,40(sp)
    800069f4:	7c02                	ld	s8,32(sp)
    800069f6:	6ce2                	ld	s9,24(sp)
    800069f8:	6d42                	ld	s10,16(sp)
    800069fa:	6165                	addi	sp,sp,112
    800069fc:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800069fe:	4689                	li	a3,2
    80006a00:	00d79623          	sh	a3,12(a5)
    80006a04:	b5e5                	j	800068ec <virtio_disk_rw+0x144>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006a06:	f9042603          	lw	a2,-112(s0)
    80006a0a:	00a60713          	addi	a4,a2,10
    80006a0e:	0712                	slli	a4,a4,0x4
    80006a10:	0001d517          	auipc	a0,0x1d
    80006a14:	6d850513          	addi	a0,a0,1752 # 800240e8 <disk+0x8>
    80006a18:	953a                	add	a0,a0,a4
  if(write)
    80006a1a:	e60d14e3          	bnez	s10,80006882 <virtio_disk_rw+0xda>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    80006a1e:	00a60793          	addi	a5,a2,10
    80006a22:	00479693          	slli	a3,a5,0x4
    80006a26:	0001d797          	auipc	a5,0x1d
    80006a2a:	6ba78793          	addi	a5,a5,1722 # 800240e0 <disk>
    80006a2e:	97b6                	add	a5,a5,a3
    80006a30:	0007a423          	sw	zero,8(a5)
    80006a34:	b595                	j	80006898 <virtio_disk_rw+0xf0>

0000000080006a36 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006a36:	1101                	addi	sp,sp,-32
    80006a38:	ec06                	sd	ra,24(sp)
    80006a3a:	e822                	sd	s0,16(sp)
    80006a3c:	e426                	sd	s1,8(sp)
    80006a3e:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006a40:	0001d497          	auipc	s1,0x1d
    80006a44:	6a048493          	addi	s1,s1,1696 # 800240e0 <disk>
    80006a48:	0001d517          	auipc	a0,0x1d
    80006a4c:	7c050513          	addi	a0,a0,1984 # 80024208 <disk+0x128>
    80006a50:	ffffa097          	auipc	ra,0xffffa
    80006a54:	19a080e7          	jalr	410(ra) # 80000bea <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006a58:	10001737          	lui	a4,0x10001
    80006a5c:	533c                	lw	a5,96(a4)
    80006a5e:	8b8d                	andi	a5,a5,3
    80006a60:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006a62:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006a66:	689c                	ld	a5,16(s1)
    80006a68:	0204d703          	lhu	a4,32(s1)
    80006a6c:	0027d783          	lhu	a5,2(a5)
    80006a70:	04f70863          	beq	a4,a5,80006ac0 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006a74:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006a78:	6898                	ld	a4,16(s1)
    80006a7a:	0204d783          	lhu	a5,32(s1)
    80006a7e:	8b9d                	andi	a5,a5,7
    80006a80:	078e                	slli	a5,a5,0x3
    80006a82:	97ba                	add	a5,a5,a4
    80006a84:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006a86:	00278713          	addi	a4,a5,2
    80006a8a:	0712                	slli	a4,a4,0x4
    80006a8c:	9726                	add	a4,a4,s1
    80006a8e:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006a92:	e721                	bnez	a4,80006ada <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006a94:	0789                	addi	a5,a5,2
    80006a96:	0792                	slli	a5,a5,0x4
    80006a98:	97a6                	add	a5,a5,s1
    80006a9a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006a9c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006aa0:	ffffc097          	auipc	ra,0xffffc
    80006aa4:	b2a080e7          	jalr	-1238(ra) # 800025ca <wakeup>

    disk.used_idx += 1;
    80006aa8:	0204d783          	lhu	a5,32(s1)
    80006aac:	2785                	addiw	a5,a5,1
    80006aae:	17c2                	slli	a5,a5,0x30
    80006ab0:	93c1                	srli	a5,a5,0x30
    80006ab2:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006ab6:	6898                	ld	a4,16(s1)
    80006ab8:	00275703          	lhu	a4,2(a4)
    80006abc:	faf71ce3          	bne	a4,a5,80006a74 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006ac0:	0001d517          	auipc	a0,0x1d
    80006ac4:	74850513          	addi	a0,a0,1864 # 80024208 <disk+0x128>
    80006ac8:	ffffa097          	auipc	ra,0xffffa
    80006acc:	1d6080e7          	jalr	470(ra) # 80000c9e <release>
}
    80006ad0:	60e2                	ld	ra,24(sp)
    80006ad2:	6442                	ld	s0,16(sp)
    80006ad4:	64a2                	ld	s1,8(sp)
    80006ad6:	6105                	addi	sp,sp,32
    80006ad8:	8082                	ret
      panic("virtio_disk_intr status");
    80006ada:	00002517          	auipc	a0,0x2
    80006ade:	f1e50513          	addi	a0,a0,-226 # 800089f8 <syscallnum+0x390>
    80006ae2:	ffffa097          	auipc	ra,0xffffa
    80006ae6:	a62080e7          	jalr	-1438(ra) # 80000544 <panic>
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

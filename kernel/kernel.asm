
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
    80000068:	22c78793          	addi	a5,a5,556 # 80006290 <timervec>
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
    8000012c:	00002097          	auipc	ra,0x2
    80000130:	756080e7          	jalr	1878(ra) # 80002882 <either_copyin>
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
    80000190:	ab450513          	addi	a0,a0,-1356 # 80010c40 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	a56080e7          	jalr	-1450(ra) # 80000bea <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019c:	00011497          	auipc	s1,0x11
    800001a0:	aa448493          	addi	s1,s1,-1372 # 80010c40 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a4:	89a6                	mv	s3,s1
    800001a6:	00011917          	auipc	s2,0x11
    800001aa:	b3290913          	addi	s2,s2,-1230 # 80010cd8 <cons+0x98>
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
    800001d0:	500080e7          	jalr	1280(ra) # 800026cc <killed>
    800001d4:	e535                	bnez	a0,80000240 <consoleread+0xdc>
      sleep(&cons.r, &cons.lock);
    800001d6:	85ce                	mv	a1,s3
    800001d8:	854a                	mv	a0,s2
    800001da:	00002097          	auipc	ra,0x2
    800001de:	0cc080e7          	jalr	204(ra) # 800022a6 <sleep>
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
    8000021a:	616080e7          	jalr	1558(ra) # 8000282c <either_copyout>
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
    8000022e:	a1650513          	addi	a0,a0,-1514 # 80010c40 <cons>
    80000232:	00001097          	auipc	ra,0x1
    80000236:	a6c080e7          	jalr	-1428(ra) # 80000c9e <release>

  return target - n;
    8000023a:	414b853b          	subw	a0,s7,s4
    8000023e:	a811                	j	80000252 <consoleread+0xee>
        release(&cons.lock);
    80000240:	00011517          	auipc	a0,0x11
    80000244:	a0050513          	addi	a0,a0,-1536 # 80010c40 <cons>
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
    8000027c:	a6f72023          	sw	a5,-1440(a4) # 80010cd8 <cons+0x98>
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
    800002d6:	96e50513          	addi	a0,a0,-1682 # 80010c40 <cons>
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
    800002fc:	5e0080e7          	jalr	1504(ra) # 800028d8 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000300:	00011517          	auipc	a0,0x11
    80000304:	94050513          	addi	a0,a0,-1728 # 80010c40 <cons>
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
    80000328:	91c70713          	addi	a4,a4,-1764 # 80010c40 <cons>
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
    80000352:	8f278793          	addi	a5,a5,-1806 # 80010c40 <cons>
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
    80000380:	95c7a783          	lw	a5,-1700(a5) # 80010cd8 <cons+0x98>
    80000384:	9f1d                	subw	a4,a4,a5
    80000386:	08000793          	li	a5,128
    8000038a:	f6f71be3          	bne	a4,a5,80000300 <consoleintr+0x3c>
    8000038e:	a07d                	j	8000043c <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000390:	00011717          	auipc	a4,0x11
    80000394:	8b070713          	addi	a4,a4,-1872 # 80010c40 <cons>
    80000398:	0a072783          	lw	a5,160(a4)
    8000039c:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a0:	00011497          	auipc	s1,0x11
    800003a4:	8a048493          	addi	s1,s1,-1888 # 80010c40 <cons>
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
    800003e0:	86470713          	addi	a4,a4,-1948 # 80010c40 <cons>
    800003e4:	0a072783          	lw	a5,160(a4)
    800003e8:	09c72703          	lw	a4,156(a4)
    800003ec:	f0f70ae3          	beq	a4,a5,80000300 <consoleintr+0x3c>
      cons.e--;
    800003f0:	37fd                	addiw	a5,a5,-1
    800003f2:	00011717          	auipc	a4,0x11
    800003f6:	8ef72723          	sw	a5,-1810(a4) # 80010ce0 <cons+0xa0>
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
    8000041c:	82878793          	addi	a5,a5,-2008 # 80010c40 <cons>
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
    80000440:	8ac7a023          	sw	a2,-1888(a5) # 80010cdc <cons+0x9c>
        wakeup(&cons.r);
    80000444:	00011517          	auipc	a0,0x11
    80000448:	89450513          	addi	a0,a0,-1900 # 80010cd8 <cons+0x98>
    8000044c:	00002097          	auipc	ra,0x2
    80000450:	016080e7          	jalr	22(ra) # 80002462 <wakeup>
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
    80000466:	00010517          	auipc	a0,0x10
    8000046a:	7da50513          	addi	a0,a0,2010 # 80010c40 <cons>
    8000046e:	00000097          	auipc	ra,0x0
    80000472:	6ec080e7          	jalr	1772(ra) # 80000b5a <initlock>

  uartinit();
    80000476:	00000097          	auipc	ra,0x0
    8000047a:	330080e7          	jalr	816(ra) # 800007a6 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000047e:	00022797          	auipc	a5,0x22
    80000482:	78a78793          	addi	a5,a5,1930 # 80022c08 <devsw>
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
    80000550:	00010797          	auipc	a5,0x10
    80000554:	7a07a823          	sw	zero,1968(a5) # 80010d00 <pr+0x18>
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
    80000588:	52f72e23          	sw	a5,1340(a4) # 80008ac0 <panicked>
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
    800005c4:	740dad83          	lw	s11,1856(s11) # 80010d00 <pr+0x18>
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
    80000602:	6ea50513          	addi	a0,a0,1770 # 80010ce8 <pr>
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
    80000766:	58650513          	addi	a0,a0,1414 # 80010ce8 <pr>
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
    80000782:	56a48493          	addi	s1,s1,1386 # 80010ce8 <pr>
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
    800007e2:	52a50513          	addi	a0,a0,1322 # 80010d08 <uart_tx_lock>
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
    8000080e:	2b67a783          	lw	a5,694(a5) # 80008ac0 <panicked>
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
    8000084a:	28273703          	ld	a4,642(a4) # 80008ac8 <uart_tx_r>
    8000084e:	00008797          	auipc	a5,0x8
    80000852:	2827b783          	ld	a5,642(a5) # 80008ad0 <uart_tx_w>
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
    80000874:	498a0a13          	addi	s4,s4,1176 # 80010d08 <uart_tx_lock>
    uart_tx_r += 1;
    80000878:	00008497          	auipc	s1,0x8
    8000087c:	25048493          	addi	s1,s1,592 # 80008ac8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000880:	00008997          	auipc	s3,0x8
    80000884:	25098993          	addi	s3,s3,592 # 80008ad0 <uart_tx_w>
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
    800008aa:	bbc080e7          	jalr	-1092(ra) # 80002462 <wakeup>
    
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
    800008e6:	42650513          	addi	a0,a0,1062 # 80010d08 <uart_tx_lock>
    800008ea:	00000097          	auipc	ra,0x0
    800008ee:	300080e7          	jalr	768(ra) # 80000bea <acquire>
  if(panicked){
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	1ce7a783          	lw	a5,462(a5) # 80008ac0 <panicked>
    800008fa:	e7c9                	bnez	a5,80000984 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fc:	00008797          	auipc	a5,0x8
    80000900:	1d47b783          	ld	a5,468(a5) # 80008ad0 <uart_tx_w>
    80000904:	00008717          	auipc	a4,0x8
    80000908:	1c473703          	ld	a4,452(a4) # 80008ac8 <uart_tx_r>
    8000090c:	02070713          	addi	a4,a4,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000910:	00010a17          	auipc	s4,0x10
    80000914:	3f8a0a13          	addi	s4,s4,1016 # 80010d08 <uart_tx_lock>
    80000918:	00008497          	auipc	s1,0x8
    8000091c:	1b048493          	addi	s1,s1,432 # 80008ac8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000920:	00008917          	auipc	s2,0x8
    80000924:	1b090913          	addi	s2,s2,432 # 80008ad0 <uart_tx_w>
    80000928:	00f71f63          	bne	a4,a5,80000946 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000092c:	85d2                	mv	a1,s4
    8000092e:	8526                	mv	a0,s1
    80000930:	00002097          	auipc	ra,0x2
    80000934:	976080e7          	jalr	-1674(ra) # 800022a6 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000938:	00093783          	ld	a5,0(s2)
    8000093c:	6098                	ld	a4,0(s1)
    8000093e:	02070713          	addi	a4,a4,32
    80000942:	fef705e3          	beq	a4,a5,8000092c <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000946:	00010497          	auipc	s1,0x10
    8000094a:	3c248493          	addi	s1,s1,962 # 80010d08 <uart_tx_lock>
    8000094e:	01f7f713          	andi	a4,a5,31
    80000952:	9726                	add	a4,a4,s1
    80000954:	01370c23          	sb	s3,24(a4)
  uart_tx_w += 1;
    80000958:	0785                	addi	a5,a5,1
    8000095a:	00008717          	auipc	a4,0x8
    8000095e:	16f73b23          	sd	a5,374(a4) # 80008ad0 <uart_tx_w>
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
    800009d4:	33848493          	addi	s1,s1,824 # 80010d08 <uart_tx_lock>
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
    80000a12:	00023797          	auipc	a5,0x23
    80000a16:	38e78793          	addi	a5,a5,910 # 80023da0 <end>
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
    80000a36:	30e90913          	addi	s2,s2,782 # 80010d40 <kmem>
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
    80000ad2:	27250513          	addi	a0,a0,626 # 80010d40 <kmem>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	084080e7          	jalr	132(ra) # 80000b5a <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ade:	45c5                	li	a1,17
    80000ae0:	05ee                	slli	a1,a1,0x1b
    80000ae2:	00023517          	auipc	a0,0x23
    80000ae6:	2be50513          	addi	a0,a0,702 # 80023da0 <end>
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
    80000b08:	23c48493          	addi	s1,s1,572 # 80010d40 <kmem>
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
    80000b20:	22450513          	addi	a0,a0,548 # 80010d40 <kmem>
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
    80000b4c:	1f850513          	addi	a0,a0,504 # 80010d40 <kmem>
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
    80000ea8:	c3470713          	addi	a4,a4,-972 # 80008ad8 <started>
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
    80000ede:	b98080e7          	jalr	-1128(ra) # 80002a72 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ee2:	00005097          	auipc	ra,0x5
    80000ee6:	3ee080e7          	jalr	1006(ra) # 800062d0 <plicinithart>
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
    80000f56:	af8080e7          	jalr	-1288(ra) # 80002a4a <trapinit>
    trapinithart();  // install kernel trap vector
    80000f5a:	00002097          	auipc	ra,0x2
    80000f5e:	b18080e7          	jalr	-1256(ra) # 80002a72 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	358080e7          	jalr	856(ra) # 800062ba <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f6a:	00005097          	auipc	ra,0x5
    80000f6e:	366080e7          	jalr	870(ra) # 800062d0 <plicinithart>
    binit();         // buffer cache
    80000f72:	00002097          	auipc	ra,0x2
    80000f76:	51a080e7          	jalr	1306(ra) # 8000348c <binit>
    iinit();         // inode table
    80000f7a:	00003097          	auipc	ra,0x3
    80000f7e:	bbe080e7          	jalr	-1090(ra) # 80003b38 <iinit>
    fileinit();      // file table
    80000f82:	00004097          	auipc	ra,0x4
    80000f86:	b5c080e7          	jalr	-1188(ra) # 80004ade <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f8a:	00005097          	auipc	ra,0x5
    80000f8e:	44e080e7          	jalr	1102(ra) # 800063d8 <virtio_disk_init>
    userinit();      // first user process
    80000f92:	00001097          	auipc	ra,0x1
    80000f96:	d82080e7          	jalr	-638(ra) # 80001d14 <userinit>
    __sync_synchronize();
    80000f9a:	0ff0000f          	fence
    started = 1;
    80000f9e:	4785                	li	a5,1
    80000fa0:	00008717          	auipc	a4,0x8
    80000fa4:	b2f72c23          	sw	a5,-1224(a4) # 80008ad8 <started>
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
    80000fb8:	b2c7b783          	ld	a5,-1236(a5) # 80008ae0 <kernel_pagetable>
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
    80001274:	86a7b823          	sd	a0,-1936(a5) # 80008ae0 <kernel_pagetable>
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
    8000186a:	95a48493          	addi	s1,s1,-1702 # 800111c0 <proc>
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
    80001884:	140a0a13          	addi	s4,s4,320 # 800189c0 <tickslock>
    char *pa = kalloc();
    80001888:	fffff097          	auipc	ra,0xfffff
    8000188c:	272080e7          	jalr	626(ra) # 80000afa <kalloc>
    80001890:	862a                	mv	a2,a0
    if (pa == 0)
    80001892:	c131                	beqz	a0,800018d6 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    80001894:	416485b3          	sub	a1,s1,s6
    80001898:	8595                	srai	a1,a1,0x5
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
    800018ba:	1e048493          	addi	s1,s1,480
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
    80001906:	45e50513          	addi	a0,a0,1118 # 80010d60 <pid_lock>
    8000190a:	fffff097          	auipc	ra,0xfffff
    8000190e:	250080e7          	jalr	592(ra) # 80000b5a <initlock>
  initlock(&wait_lock, "wait_lock");
    80001912:	00007597          	auipc	a1,0x7
    80001916:	8d658593          	addi	a1,a1,-1834 # 800081e8 <digits+0x1a8>
    8000191a:	0000f517          	auipc	a0,0xf
    8000191e:	45e50513          	addi	a0,a0,1118 # 80010d78 <wait_lock>
    80001922:	fffff097          	auipc	ra,0xfffff
    80001926:	238080e7          	jalr	568(ra) # 80000b5a <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    8000192a:	00010497          	auipc	s1,0x10
    8000192e:	89648493          	addi	s1,s1,-1898 # 800111c0 <proc>
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
    80001950:	07498993          	addi	s3,s3,116 # 800189c0 <tickslock>
    initlock(&p->lock, "proc");
    80001954:	85da                	mv	a1,s6
    80001956:	8526                	mv	a0,s1
    80001958:	fffff097          	auipc	ra,0xfffff
    8000195c:	202080e7          	jalr	514(ra) # 80000b5a <initlock>
    p->state = UNUSED;
    80001960:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001964:	415487b3          	sub	a5,s1,s5
    80001968:	8795                	srai	a5,a5,0x5
    8000196a:	000a3703          	ld	a4,0(s4)
    8000196e:	02e787b3          	mul	a5,a5,a4
    80001972:	2785                	addiw	a5,a5,1
    80001974:	00d7979b          	slliw	a5,a5,0xd
    80001978:	40f907b3          	sub	a5,s2,a5
    8000197c:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    8000197e:	1e048493          	addi	s1,s1,480
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
    800019ba:	3da50513          	addi	a0,a0,986 # 80010d90 <cpus>
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
    800019e2:	38270713          	addi	a4,a4,898 # 80010d60 <pid_lock>
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
    80001a1a:	f7a7a783          	lw	a5,-134(a5) # 80008990 <first.1747>
    80001a1e:	eb89                	bnez	a5,80001a30 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a20:	00001097          	auipc	ra,0x1
    80001a24:	06a080e7          	jalr	106(ra) # 80002a8a <usertrapret>
}
    80001a28:	60a2                	ld	ra,8(sp)
    80001a2a:	6402                	ld	s0,0(sp)
    80001a2c:	0141                	addi	sp,sp,16
    80001a2e:	8082                	ret
    first = 0;
    80001a30:	00007797          	auipc	a5,0x7
    80001a34:	f607a023          	sw	zero,-160(a5) # 80008990 <first.1747>
    fsinit(ROOTDEV);
    80001a38:	4505                	li	a0,1
    80001a3a:	00002097          	auipc	ra,0x2
    80001a3e:	07e080e7          	jalr	126(ra) # 80003ab8 <fsinit>
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
    80001a54:	31090913          	addi	s2,s2,784 # 80010d60 <pid_lock>
    80001a58:	854a                	mv	a0,s2
    80001a5a:	fffff097          	auipc	ra,0xfffff
    80001a5e:	190080e7          	jalr	400(ra) # 80000bea <acquire>
  pid = nextpid;
    80001a62:	00007797          	auipc	a5,0x7
    80001a66:	f3278793          	addi	a5,a5,-206 # 80008994 <nextpid>
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
    80001be0:	5e448493          	addi	s1,s1,1508 # 800111c0 <proc>
    80001be4:	00017917          	auipc	s2,0x17
    80001be8:	ddc90913          	addi	s2,s2,-548 # 800189c0 <tickslock>
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
    80001c04:	1e048493          	addi	s1,s1,480
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
    80001c22:	ed27e783          	lwu	a5,-302(a5) # 80008af0 <ticks>
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
    80001c78:	e7c7a783          	lw	a5,-388(a5) # 80008af0 <ticks>
    80001c7c:	16f4a823          	sw	a5,368(s1)
  p->alarm_on = 0;
    80001c80:	1804ac23          	sw	zero,408(s1)
  p->cur_ticks = 0;
    80001c84:	1804a623          	sw	zero,396(s1)
  p->runtime = 0;
    80001c88:	1a04b423          	sd	zero,424(s1)
  p->starttime = 0;
    80001c8c:	1a04b823          	sd	zero,432(s1)
  p->sleeptime = 0;
    80001c90:	1a04bc23          	sd	zero,440(s1)
  p->runcount = 0;
    80001c94:	1c04b023          	sd	zero,448(s1)
  p->priority = 60;
    80001c98:	03c00793          	li	a5,60
    80001c9c:	1cf4b423          	sd	a5,456(s1)
  p->handlerpermission = 1;
    80001ca0:	4785                	li	a5,1
    80001ca2:	18f4ae23          	sw	a5,412(s1)
  p->tickets = 1;
    80001ca6:	1af4a023          	sw	a5,416(s1)
  p->tickcount = 0;
    80001caa:	1c04a823          	sw	zero,464(s1)
  p->queue = 0;
    80001cae:	1c04aa23          	sw	zero,468(s1)
  p->waittickcount = 0;
    80001cb2:	1c04ac23          	sw	zero,472(s1)
  p->queueposition = queueprocesscount[0];
    80001cb6:	0000f797          	auipc	a5,0xf
    80001cba:	0aa78793          	addi	a5,a5,170 # 80010d60 <pid_lock>
    80001cbe:	4307a703          	lw	a4,1072(a5)
    80001cc2:	1ce4ae23          	sw	a4,476(s1)
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
    80001d2c:	dca7b023          	sd	a0,-576(a5) # 80008ae8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001d30:	03400613          	li	a2,52
    80001d34:	00007597          	auipc	a1,0x7
    80001d38:	c6c58593          	addi	a1,a1,-916 # 800089a0 <initcode>
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
    80001d72:	00002097          	auipc	ra,0x2
    80001d76:	768080e7          	jalr	1896(ra) # 800044da <namei>
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
    80001e9c:	cd8080e7          	jalr	-808(ra) # 80004b70 <filedup>
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
    80001ebe:	e3c080e7          	jalr	-452(ra) # 80003cf6 <idup>
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
    80001eea:	e9248493          	addi	s1,s1,-366 # 80010d78 <wait_lock>
    80001eee:	8526                	mv	a0,s1
    80001ef0:	fffff097          	auipc	ra,0xfffff
    80001ef4:	cfa080e7          	jalr	-774(ra) # 80000bea <acquire>
  np->parent = p;
    80001ef8:	0329bc23          	sd	s2,56(s3)
  np->tickets = np->parent->tickets;
    80001efc:	1a092783          	lw	a5,416(s2)
    80001f00:	1af9a023          	sw	a5,416(s3)
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
    80001f80:	24448493          	addi	s1,s1,580 # 800111c0 <proc>
    if (p->state == RUNNING)
    80001f84:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++)
    80001f86:	00017917          	auipc	s2,0x17
    80001f8a:	a3a90913          	addi	s2,s2,-1478 # 800189c0 <tickslock>
    80001f8e:	a811                	j	80001fa2 <update_time+0x34>
    release(&p->lock);
    80001f90:	8526                	mv	a0,s1
    80001f92:	fffff097          	auipc	ra,0xfffff
    80001f96:	d0c080e7          	jalr	-756(ra) # 80000c9e <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001f9a:	1e048493          	addi	s1,s1,480
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
    80001fd6:	b1e7e783          	lwu	a5,-1250(a5) # 80008af0 <ticks>
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
    80001ffa:	7119                	addi	sp,sp,-128
    80001ffc:	fc86                	sd	ra,120(sp)
    80001ffe:	f8a2                	sd	s0,112(sp)
    80002000:	f4a6                	sd	s1,104(sp)
    80002002:	f0ca                	sd	s2,96(sp)
    80002004:	ecce                	sd	s3,88(sp)
    80002006:	e8d2                	sd	s4,80(sp)
    80002008:	e4d6                	sd	s5,72(sp)
    8000200a:	e0da                	sd	s6,64(sp)
    8000200c:	fc5e                	sd	s7,56(sp)
    8000200e:	f862                	sd	s8,48(sp)
    80002010:	f466                	sd	s9,40(sp)
    80002012:	f06a                	sd	s10,32(sp)
    80002014:	ec6e                	sd	s11,24(sp)
    80002016:	0100                	addi	s0,sp,128
    80002018:	8792                	mv	a5,tp
  int id = r_tp();
    8000201a:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000201c:	00779693          	slli	a3,a5,0x7
    80002020:	0000f717          	auipc	a4,0xf
    80002024:	d4070713          	addi	a4,a4,-704 # 80010d60 <pid_lock>
    80002028:	9736                	add	a4,a4,a3
    8000202a:	02073823          	sd	zero,48(a4)
      swtch(&c->context, &high_priority_proc->context);
    8000202e:	0000f717          	auipc	a4,0xf
    80002032:	d6a70713          	addi	a4,a4,-662 # 80010d98 <cpus+0x8>
    80002036:	9736                	add	a4,a4,a3
    80002038:	f8e43423          	sd	a4,-120(s0)
    for (p = proc; p < &proc[NPROC]; p++)
    8000203c:	00017c17          	auipc	s8,0x17
    80002040:	984c0c13          	addi	s8,s8,-1660 # 800189c0 <tickslock>
        nice = 5; // Default value of nice;
    80002044:	4b95                	li	s7,5
    return b;
    80002046:	06400d13          	li	s10,100
      c->proc = high_priority_proc;
    8000204a:	0000fd97          	auipc	s11,0xf
    8000204e:	d16d8d93          	addi	s11,s11,-746 # 80010d60 <pid_lock>
    80002052:	9db6                	add	s11,s11,a3
    80002054:	aa39                	j	80002172 <scheduler+0x178>
          if (high_priority_proc != 0)
    80002056:	000c8763          	beqz	s9,80002064 <scheduler+0x6a>
            release(&high_priority_proc->lock);
    8000205a:	8566                	mv	a0,s9
    8000205c:	fffff097          	auipc	ra,0xfffff
    80002060:	c42080e7          	jalr	-958(ra) # 80000c9e <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002064:	1e090793          	addi	a5,s2,480
    80002068:	0d87f263          	bgeu	a5,s8,8000212c <scheduler+0x132>
    8000206c:	8a26                	mv	s4,s1
    8000206e:	8cce                	mv	s9,s3
    80002070:	a825                	j	800020a8 <scheduler+0xae>
            release(&high_priority_proc->lock);
    80002072:	8566                	mv	a0,s9
    80002074:	fffff097          	auipc	ra,0xfffff
    80002078:	c2a080e7          	jalr	-982(ra) # 80000c9e <release>
    8000207c:	b7e5                	j	80002064 <scheduler+0x6a>
        if (current_dp ==  dynamic_priority && high_priority_proc->runcount == p->runcount && p->time_created < high_priority_proc->time_created)
    8000207e:	1789b703          	ld	a4,376(s3)
    80002082:	178cb783          	ld	a5,376(s9)
    80002086:	08f77663          	bgeu	a4,a5,80002112 <scheduler+0x118>
            release(&high_priority_proc->lock);
    8000208a:	8566                	mv	a0,s9
    8000208c:	fffff097          	auipc	ra,0xfffff
    80002090:	c12080e7          	jalr	-1006(ra) # 80000c9e <release>
    80002094:	bfc1                	j	80002064 <scheduler+0x6a>
      release(&p->lock);
    80002096:	854e                	mv	a0,s3
    80002098:	fffff097          	auipc	ra,0xfffff
    8000209c:	c06080e7          	jalr	-1018(ra) # 80000c9e <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800020a0:	1e090793          	addi	a5,s2,480
    800020a4:	0987f163          	bgeu	a5,s8,80002126 <scheduler+0x12c>
    800020a8:	1e090913          	addi	s2,s2,480
    800020ac:	89ca                	mv	s3,s2
      acquire(&p->lock);
    800020ae:	854a                	mv	a0,s2
    800020b0:	fffff097          	auipc	ra,0xfffff
    800020b4:	b3a080e7          	jalr	-1222(ra) # 80000bea <acquire>
      if (p->runtime + p->sleeptime > 0)
    800020b8:	1b893683          	ld	a3,440(s2)
    800020bc:	1a893483          	ld	s1,424(s2)
    800020c0:	00968733          	add	a4,a3,s1
        nice = 5; // Default value of nice;
    800020c4:	87de                	mv	a5,s7
      if (p->runtime + p->sleeptime > 0)
    800020c6:	cb11                	beqz	a4,800020da <scheduler+0xe0>
        nice = p->sleeptime * 10;
    800020c8:	0026949b          	slliw	s1,a3,0x2
    800020cc:	9cb5                	addw	s1,s1,a3
        nice = nice / (p->sleeptime + p->runtime);
    800020ce:	0014949b          	slliw	s1,s1,0x1
    800020d2:	02e4d4b3          	divu	s1,s1,a4
    800020d6:	0004879b          	sext.w	a5,s1
      int current_dp = max(0, min(p->priority - nice + 5, 100)); // current dynamic priority
    800020da:	1c89b483          	ld	s1,456(s3)
    800020de:	2495                	addiw	s1,s1,5
    800020e0:	9c9d                	subw	s1,s1,a5
  if (a < b)
    800020e2:	009b5363          	bge	s6,s1,800020e8 <scheduler+0xee>
    return b;
    800020e6:	84ea                	mv	s1,s10
      if (p->state == RUNNABLE)
    800020e8:	0189a783          	lw	a5,24(s3)
    800020ec:	fb5795e3          	bne	a5,s5,80002096 <scheduler+0x9c>
    800020f0:	fff4c793          	not	a5,s1
    800020f4:	97fd                	srai	a5,a5,0x3f
    800020f6:	8cfd                	and	s1,s1,a5
    800020f8:	2481                	sext.w	s1,s1
        if(current_dp < dynamic_priority){
    800020fa:	f544cee3          	blt	s1,s4,80002056 <scheduler+0x5c>
        if (current_dp ==  dynamic_priority && p->runcount < high_priority_proc->runcount)
    800020fe:	f89a1ce3          	bne	s4,s1,80002096 <scheduler+0x9c>
    80002102:	1c09b703          	ld	a4,448(s3)
    80002106:	1c0cb783          	ld	a5,448(s9)
    8000210a:	f6f764e3          	bltu	a4,a5,80002072 <scheduler+0x78>
        if (current_dp ==  dynamic_priority && high_priority_proc->runcount == p->runcount && p->time_created < high_priority_proc->time_created)
    8000210e:	f6f708e3          	beq	a4,a5,8000207e <scheduler+0x84>
      release(&p->lock);
    80002112:	854e                	mv	a0,s3
    80002114:	fffff097          	auipc	ra,0xfffff
    80002118:	b8a080e7          	jalr	-1142(ra) # 80000c9e <release>
    for (p = proc; p < &proc[NPROC]; p++)
    8000211c:	1e090793          	addi	a5,s2,480
    80002120:	f987e4e3          	bltu	a5,s8,800020a8 <scheduler+0xae>
    80002124:	a019                	j	8000212a <scheduler+0x130>
    if (high_priority_proc != 0)
    80002126:	040c8963          	beqz	s9,80002178 <scheduler+0x17e>
    for (p = proc; p < &proc[NPROC]; p++)
    8000212a:	89e6                	mv	s3,s9
      high_priority_proc->state = RUNNING;
    8000212c:	4791                	li	a5,4
    8000212e:	00f9ac23          	sw	a5,24(s3)
      high_priority_proc->starttime = ticks;
    80002132:	00007797          	auipc	a5,0x7
    80002136:	9be7e783          	lwu	a5,-1602(a5) # 80008af0 <ticks>
    8000213a:	1af9b823          	sd	a5,432(s3)
      high_priority_proc->runtime = 0;
    8000213e:	1a09b423          	sd	zero,424(s3)
      high_priority_proc->sleeptime = 0;
    80002142:	1a09bc23          	sd	zero,440(s3)
      high_priority_proc->runcount += 1;
    80002146:	1c09b783          	ld	a5,448(s3)
    8000214a:	0785                	addi	a5,a5,1
    8000214c:	1cf9b023          	sd	a5,448(s3)
      c->proc = high_priority_proc;
    80002150:	033db823          	sd	s3,48(s11)
      swtch(&c->context, &high_priority_proc->context);
    80002154:	06098593          	addi	a1,s3,96
    80002158:	f8843503          	ld	a0,-120(s0)
    8000215c:	00001097          	auipc	ra,0x1
    80002160:	884080e7          	jalr	-1916(ra) # 800029e0 <swtch>
      c->proc = 0;
    80002164:	020db823          	sd	zero,48(s11)
      release(&high_priority_proc->lock);
    80002168:	854e                	mv	a0,s3
    8000216a:	fffff097          	auipc	ra,0xfffff
    8000216e:	b34080e7          	jalr	-1228(ra) # 80000c9e <release>
  if (a < b)
    80002172:	06300b13          	li	s6,99
      if (p->state == RUNNABLE)
    80002176:	4a8d                	li	s5,3
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002178:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000217c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002180:	10079073          	csrw	sstatus,a5
    for (p = proc; p < &proc[NPROC]; p++)
    80002184:	0000f917          	auipc	s2,0xf
    80002188:	03c90913          	addi	s2,s2,60 # 800111c0 <proc>
    int dynamic_priority = 101; // Lower dynamic_priority value => higher preference in scheduling
    8000218c:	06500a13          	li	s4,101
    struct proc *high_priority_proc=0;
    80002190:	4c81                	li	s9,0
    80002192:	bf29                	j	800020ac <scheduler+0xb2>

0000000080002194 <sched>:
{
    80002194:	7179                	addi	sp,sp,-48
    80002196:	f406                	sd	ra,40(sp)
    80002198:	f022                	sd	s0,32(sp)
    8000219a:	ec26                	sd	s1,24(sp)
    8000219c:	e84a                	sd	s2,16(sp)
    8000219e:	e44e                	sd	s3,8(sp)
    800021a0:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800021a2:	00000097          	auipc	ra,0x0
    800021a6:	824080e7          	jalr	-2012(ra) # 800019c6 <myproc>
    800021aa:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    800021ac:	fffff097          	auipc	ra,0xfffff
    800021b0:	9c4080e7          	jalr	-1596(ra) # 80000b70 <holding>
    800021b4:	c93d                	beqz	a0,8000222a <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800021b6:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    800021b8:	2781                	sext.w	a5,a5
    800021ba:	079e                	slli	a5,a5,0x7
    800021bc:	0000f717          	auipc	a4,0xf
    800021c0:	ba470713          	addi	a4,a4,-1116 # 80010d60 <pid_lock>
    800021c4:	97ba                	add	a5,a5,a4
    800021c6:	0a87a703          	lw	a4,168(a5)
    800021ca:	4785                	li	a5,1
    800021cc:	06f71763          	bne	a4,a5,8000223a <sched+0xa6>
  if (p->state == RUNNING)
    800021d0:	4c98                	lw	a4,24(s1)
    800021d2:	4791                	li	a5,4
    800021d4:	06f70b63          	beq	a4,a5,8000224a <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800021d8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800021dc:	8b89                	andi	a5,a5,2
  if (intr_get())
    800021de:	efb5                	bnez	a5,8000225a <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800021e0:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800021e2:	0000f917          	auipc	s2,0xf
    800021e6:	b7e90913          	addi	s2,s2,-1154 # 80010d60 <pid_lock>
    800021ea:	2781                	sext.w	a5,a5
    800021ec:	079e                	slli	a5,a5,0x7
    800021ee:	97ca                	add	a5,a5,s2
    800021f0:	0ac7a983          	lw	s3,172(a5)
    800021f4:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800021f6:	2781                	sext.w	a5,a5
    800021f8:	079e                	slli	a5,a5,0x7
    800021fa:	0000f597          	auipc	a1,0xf
    800021fe:	b9e58593          	addi	a1,a1,-1122 # 80010d98 <cpus+0x8>
    80002202:	95be                	add	a1,a1,a5
    80002204:	06048513          	addi	a0,s1,96
    80002208:	00000097          	auipc	ra,0x0
    8000220c:	7d8080e7          	jalr	2008(ra) # 800029e0 <swtch>
    80002210:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002212:	2781                	sext.w	a5,a5
    80002214:	079e                	slli	a5,a5,0x7
    80002216:	97ca                	add	a5,a5,s2
    80002218:	0b37a623          	sw	s3,172(a5)
}
    8000221c:	70a2                	ld	ra,40(sp)
    8000221e:	7402                	ld	s0,32(sp)
    80002220:	64e2                	ld	s1,24(sp)
    80002222:	6942                	ld	s2,16(sp)
    80002224:	69a2                	ld	s3,8(sp)
    80002226:	6145                	addi	sp,sp,48
    80002228:	8082                	ret
    panic("sched p->lock");
    8000222a:	00006517          	auipc	a0,0x6
    8000222e:	fee50513          	addi	a0,a0,-18 # 80008218 <digits+0x1d8>
    80002232:	ffffe097          	auipc	ra,0xffffe
    80002236:	312080e7          	jalr	786(ra) # 80000544 <panic>
    panic("sched locks");
    8000223a:	00006517          	auipc	a0,0x6
    8000223e:	fee50513          	addi	a0,a0,-18 # 80008228 <digits+0x1e8>
    80002242:	ffffe097          	auipc	ra,0xffffe
    80002246:	302080e7          	jalr	770(ra) # 80000544 <panic>
    panic("sched running");
    8000224a:	00006517          	auipc	a0,0x6
    8000224e:	fee50513          	addi	a0,a0,-18 # 80008238 <digits+0x1f8>
    80002252:	ffffe097          	auipc	ra,0xffffe
    80002256:	2f2080e7          	jalr	754(ra) # 80000544 <panic>
    panic("sched interruptible");
    8000225a:	00006517          	auipc	a0,0x6
    8000225e:	fee50513          	addi	a0,a0,-18 # 80008248 <digits+0x208>
    80002262:	ffffe097          	auipc	ra,0xffffe
    80002266:	2e2080e7          	jalr	738(ra) # 80000544 <panic>

000000008000226a <yield>:
{
    8000226a:	1101                	addi	sp,sp,-32
    8000226c:	ec06                	sd	ra,24(sp)
    8000226e:	e822                	sd	s0,16(sp)
    80002270:	e426                	sd	s1,8(sp)
    80002272:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002274:	fffff097          	auipc	ra,0xfffff
    80002278:	752080e7          	jalr	1874(ra) # 800019c6 <myproc>
    8000227c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000227e:	fffff097          	auipc	ra,0xfffff
    80002282:	96c080e7          	jalr	-1684(ra) # 80000bea <acquire>
  p->state = RUNNABLE;
    80002286:	478d                	li	a5,3
    80002288:	cc9c                	sw	a5,24(s1)
  sched();
    8000228a:	00000097          	auipc	ra,0x0
    8000228e:	f0a080e7          	jalr	-246(ra) # 80002194 <sched>
  release(&p->lock);
    80002292:	8526                	mv	a0,s1
    80002294:	fffff097          	auipc	ra,0xfffff
    80002298:	a0a080e7          	jalr	-1526(ra) # 80000c9e <release>
}
    8000229c:	60e2                	ld	ra,24(sp)
    8000229e:	6442                	ld	s0,16(sp)
    800022a0:	64a2                	ld	s1,8(sp)
    800022a2:	6105                	addi	sp,sp,32
    800022a4:	8082                	ret

00000000800022a6 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    800022a6:	7179                	addi	sp,sp,-48
    800022a8:	f406                	sd	ra,40(sp)
    800022aa:	f022                	sd	s0,32(sp)
    800022ac:	ec26                	sd	s1,24(sp)
    800022ae:	e84a                	sd	s2,16(sp)
    800022b0:	e44e                	sd	s3,8(sp)
    800022b2:	1800                	addi	s0,sp,48
    800022b4:	89aa                	mv	s3,a0
    800022b6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800022b8:	fffff097          	auipc	ra,0xfffff
    800022bc:	70e080e7          	jalr	1806(ra) # 800019c6 <myproc>
    800022c0:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    800022c2:	fffff097          	auipc	ra,0xfffff
    800022c6:	928080e7          	jalr	-1752(ra) # 80000bea <acquire>
  release(lk);
    800022ca:	854a                	mv	a0,s2
    800022cc:	fffff097          	auipc	ra,0xfffff
    800022d0:	9d2080e7          	jalr	-1582(ra) # 80000c9e <release>

  // Go to sleep.
  p->chan = chan;
    800022d4:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800022d8:	4789                	li	a5,2
    800022da:	cc9c                	sw	a5,24(s1)
  p->sleeptime = ticks;
    800022dc:	00007797          	auipc	a5,0x7
    800022e0:	8147e783          	lwu	a5,-2028(a5) # 80008af0 <ticks>
    800022e4:	1af4bc23          	sd	a5,440(s1)

  sched();
    800022e8:	00000097          	auipc	ra,0x0
    800022ec:	eac080e7          	jalr	-340(ra) # 80002194 <sched>

  // Tidy up.
  p->chan = 0;
    800022f0:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800022f4:	8526                	mv	a0,s1
    800022f6:	fffff097          	auipc	ra,0xfffff
    800022fa:	9a8080e7          	jalr	-1624(ra) # 80000c9e <release>
  acquire(lk);
    800022fe:	854a                	mv	a0,s2
    80002300:	fffff097          	auipc	ra,0xfffff
    80002304:	8ea080e7          	jalr	-1814(ra) # 80000bea <acquire>
}
    80002308:	70a2                	ld	ra,40(sp)
    8000230a:	7402                	ld	s0,32(sp)
    8000230c:	64e2                	ld	s1,24(sp)
    8000230e:	6942                	ld	s2,16(sp)
    80002310:	69a2                	ld	s3,8(sp)
    80002312:	6145                	addi	sp,sp,48
    80002314:	8082                	ret

0000000080002316 <waitx>:
{
    80002316:	711d                	addi	sp,sp,-96
    80002318:	ec86                	sd	ra,88(sp)
    8000231a:	e8a2                	sd	s0,80(sp)
    8000231c:	e4a6                	sd	s1,72(sp)
    8000231e:	e0ca                	sd	s2,64(sp)
    80002320:	fc4e                	sd	s3,56(sp)
    80002322:	f852                	sd	s4,48(sp)
    80002324:	f456                	sd	s5,40(sp)
    80002326:	f05a                	sd	s6,32(sp)
    80002328:	ec5e                	sd	s7,24(sp)
    8000232a:	e862                	sd	s8,16(sp)
    8000232c:	e466                	sd	s9,8(sp)
    8000232e:	e06a                	sd	s10,0(sp)
    80002330:	1080                	addi	s0,sp,96
    80002332:	8b2a                	mv	s6,a0
    80002334:	8bae                	mv	s7,a1
    80002336:	8c32                	mv	s8,a2
  struct proc *p = myproc();
    80002338:	fffff097          	auipc	ra,0xfffff
    8000233c:	68e080e7          	jalr	1678(ra) # 800019c6 <myproc>
    80002340:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002342:	0000f517          	auipc	a0,0xf
    80002346:	a3650513          	addi	a0,a0,-1482 # 80010d78 <wait_lock>
    8000234a:	fffff097          	auipc	ra,0xfffff
    8000234e:	8a0080e7          	jalr	-1888(ra) # 80000bea <acquire>
    havekids = 0;
    80002352:	4c81                	li	s9,0
        if (np->state == ZOMBIE)
    80002354:	4a15                	li	s4,5
    for (np = proc; np < &proc[NPROC]; np++)
    80002356:	00016997          	auipc	s3,0x16
    8000235a:	66a98993          	addi	s3,s3,1642 # 800189c0 <tickslock>
        havekids = 1;
    8000235e:	4a85                	li	s5,1
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002360:	0000fd17          	auipc	s10,0xf
    80002364:	a18d0d13          	addi	s10,s10,-1512 # 80010d78 <wait_lock>
    havekids = 0;
    80002368:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    8000236a:	0000f497          	auipc	s1,0xf
    8000236e:	e5648493          	addi	s1,s1,-426 # 800111c0 <proc>
    80002372:	a059                	j	800023f8 <waitx+0xe2>
          pid = np->pid;
    80002374:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    80002378:	16c4a703          	lw	a4,364(s1)
    8000237c:	00ec2023          	sw	a4,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    80002380:	1704a783          	lw	a5,368(s1)
    80002384:	9f3d                	addw	a4,a4,a5
    80002386:	1744a783          	lw	a5,372(s1)
    8000238a:	9f99                	subw	a5,a5,a4
    8000238c:	00fba023          	sw	a5,0(s7) # fffffffffffff000 <end+0xffffffff7ffdb260>
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002390:	000b0e63          	beqz	s6,800023ac <waitx+0x96>
    80002394:	4691                	li	a3,4
    80002396:	02c48613          	addi	a2,s1,44
    8000239a:	85da                	mv	a1,s6
    8000239c:	05093503          	ld	a0,80(s2)
    800023a0:	fffff097          	auipc	ra,0xfffff
    800023a4:	2e4080e7          	jalr	740(ra) # 80001684 <copyout>
    800023a8:	02054563          	bltz	a0,800023d2 <waitx+0xbc>
          freeproc(np);
    800023ac:	8526                	mv	a0,s1
    800023ae:	fffff097          	auipc	ra,0xfffff
    800023b2:	7ca080e7          	jalr	1994(ra) # 80001b78 <freeproc>
          release(&np->lock);
    800023b6:	8526                	mv	a0,s1
    800023b8:	fffff097          	auipc	ra,0xfffff
    800023bc:	8e6080e7          	jalr	-1818(ra) # 80000c9e <release>
          release(&wait_lock);
    800023c0:	0000f517          	auipc	a0,0xf
    800023c4:	9b850513          	addi	a0,a0,-1608 # 80010d78 <wait_lock>
    800023c8:	fffff097          	auipc	ra,0xfffff
    800023cc:	8d6080e7          	jalr	-1834(ra) # 80000c9e <release>
          return pid;
    800023d0:	a09d                	j	80002436 <waitx+0x120>
            release(&np->lock);
    800023d2:	8526                	mv	a0,s1
    800023d4:	fffff097          	auipc	ra,0xfffff
    800023d8:	8ca080e7          	jalr	-1846(ra) # 80000c9e <release>
            release(&wait_lock);
    800023dc:	0000f517          	auipc	a0,0xf
    800023e0:	99c50513          	addi	a0,a0,-1636 # 80010d78 <wait_lock>
    800023e4:	fffff097          	auipc	ra,0xfffff
    800023e8:	8ba080e7          	jalr	-1862(ra) # 80000c9e <release>
            return -1;
    800023ec:	59fd                	li	s3,-1
    800023ee:	a0a1                	j	80002436 <waitx+0x120>
    for (np = proc; np < &proc[NPROC]; np++)
    800023f0:	1e048493          	addi	s1,s1,480
    800023f4:	03348463          	beq	s1,s3,8000241c <waitx+0x106>
      if (np->parent == p)
    800023f8:	7c9c                	ld	a5,56(s1)
    800023fa:	ff279be3          	bne	a5,s2,800023f0 <waitx+0xda>
        acquire(&np->lock);
    800023fe:	8526                	mv	a0,s1
    80002400:	ffffe097          	auipc	ra,0xffffe
    80002404:	7ea080e7          	jalr	2026(ra) # 80000bea <acquire>
        if (np->state == ZOMBIE)
    80002408:	4c9c                	lw	a5,24(s1)
    8000240a:	f74785e3          	beq	a5,s4,80002374 <waitx+0x5e>
        release(&np->lock);
    8000240e:	8526                	mv	a0,s1
    80002410:	fffff097          	auipc	ra,0xfffff
    80002414:	88e080e7          	jalr	-1906(ra) # 80000c9e <release>
        havekids = 1;
    80002418:	8756                	mv	a4,s5
    8000241a:	bfd9                	j	800023f0 <waitx+0xda>
    if (!havekids || p->killed)
    8000241c:	c701                	beqz	a4,80002424 <waitx+0x10e>
    8000241e:	02892783          	lw	a5,40(s2)
    80002422:	cb8d                	beqz	a5,80002454 <waitx+0x13e>
      release(&wait_lock);
    80002424:	0000f517          	auipc	a0,0xf
    80002428:	95450513          	addi	a0,a0,-1708 # 80010d78 <wait_lock>
    8000242c:	fffff097          	auipc	ra,0xfffff
    80002430:	872080e7          	jalr	-1934(ra) # 80000c9e <release>
      return -1;
    80002434:	59fd                	li	s3,-1
}
    80002436:	854e                	mv	a0,s3
    80002438:	60e6                	ld	ra,88(sp)
    8000243a:	6446                	ld	s0,80(sp)
    8000243c:	64a6                	ld	s1,72(sp)
    8000243e:	6906                	ld	s2,64(sp)
    80002440:	79e2                	ld	s3,56(sp)
    80002442:	7a42                	ld	s4,48(sp)
    80002444:	7aa2                	ld	s5,40(sp)
    80002446:	7b02                	ld	s6,32(sp)
    80002448:	6be2                	ld	s7,24(sp)
    8000244a:	6c42                	ld	s8,16(sp)
    8000244c:	6ca2                	ld	s9,8(sp)
    8000244e:	6d02                	ld	s10,0(sp)
    80002450:	6125                	addi	sp,sp,96
    80002452:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002454:	85ea                	mv	a1,s10
    80002456:	854a                	mv	a0,s2
    80002458:	00000097          	auipc	ra,0x0
    8000245c:	e4e080e7          	jalr	-434(ra) # 800022a6 <sleep>
    havekids = 0;
    80002460:	b721                	j	80002368 <waitx+0x52>

0000000080002462 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    80002462:	7139                	addi	sp,sp,-64
    80002464:	fc06                	sd	ra,56(sp)
    80002466:	f822                	sd	s0,48(sp)
    80002468:	f426                	sd	s1,40(sp)
    8000246a:	f04a                	sd	s2,32(sp)
    8000246c:	ec4e                	sd	s3,24(sp)
    8000246e:	e852                	sd	s4,16(sp)
    80002470:	e456                	sd	s5,8(sp)
    80002472:	e05a                	sd	s6,0(sp)
    80002474:	0080                	addi	s0,sp,64
    80002476:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002478:	0000f497          	auipc	s1,0xf
    8000247c:	d4848493          	addi	s1,s1,-696 # 800111c0 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    80002480:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    80002482:	4b0d                	li	s6,3
        p->sleeptime=ticks-p->sleeptime;
    80002484:	00006a97          	auipc	s5,0x6
    80002488:	66ca8a93          	addi	s5,s5,1644 # 80008af0 <ticks>
  for (p = proc; p < &proc[NPROC]; p++)
    8000248c:	00016917          	auipc	s2,0x16
    80002490:	53490913          	addi	s2,s2,1332 # 800189c0 <tickslock>
    80002494:	a01d                	j	800024ba <wakeup+0x58>
        p->state = RUNNABLE;
    80002496:	0164ac23          	sw	s6,24(s1)
        p->sleeptime=ticks-p->sleeptime;
    8000249a:	000ae783          	lwu	a5,0(s5)
    8000249e:	1b84b703          	ld	a4,440(s1)
    800024a2:	8f99                	sub	a5,a5,a4
    800024a4:	1af4bc23          	sd	a5,440(s1)
      }
      release(&p->lock);
    800024a8:	8526                	mv	a0,s1
    800024aa:	ffffe097          	auipc	ra,0xffffe
    800024ae:	7f4080e7          	jalr	2036(ra) # 80000c9e <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800024b2:	1e048493          	addi	s1,s1,480
    800024b6:	03248463          	beq	s1,s2,800024de <wakeup+0x7c>
    if (p != myproc())
    800024ba:	fffff097          	auipc	ra,0xfffff
    800024be:	50c080e7          	jalr	1292(ra) # 800019c6 <myproc>
    800024c2:	fea488e3          	beq	s1,a0,800024b2 <wakeup+0x50>
      acquire(&p->lock);
    800024c6:	8526                	mv	a0,s1
    800024c8:	ffffe097          	auipc	ra,0xffffe
    800024cc:	722080e7          	jalr	1826(ra) # 80000bea <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    800024d0:	4c9c                	lw	a5,24(s1)
    800024d2:	fd379be3          	bne	a5,s3,800024a8 <wakeup+0x46>
    800024d6:	709c                	ld	a5,32(s1)
    800024d8:	fd4798e3          	bne	a5,s4,800024a8 <wakeup+0x46>
    800024dc:	bf6d                	j	80002496 <wakeup+0x34>
    }
  }
}
    800024de:	70e2                	ld	ra,56(sp)
    800024e0:	7442                	ld	s0,48(sp)
    800024e2:	74a2                	ld	s1,40(sp)
    800024e4:	7902                	ld	s2,32(sp)
    800024e6:	69e2                	ld	s3,24(sp)
    800024e8:	6a42                	ld	s4,16(sp)
    800024ea:	6aa2                	ld	s5,8(sp)
    800024ec:	6b02                	ld	s6,0(sp)
    800024ee:	6121                	addi	sp,sp,64
    800024f0:	8082                	ret

00000000800024f2 <reparent>:
{
    800024f2:	7179                	addi	sp,sp,-48
    800024f4:	f406                	sd	ra,40(sp)
    800024f6:	f022                	sd	s0,32(sp)
    800024f8:	ec26                	sd	s1,24(sp)
    800024fa:	e84a                	sd	s2,16(sp)
    800024fc:	e44e                	sd	s3,8(sp)
    800024fe:	e052                	sd	s4,0(sp)
    80002500:	1800                	addi	s0,sp,48
    80002502:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002504:	0000f497          	auipc	s1,0xf
    80002508:	cbc48493          	addi	s1,s1,-836 # 800111c0 <proc>
      pp->parent = initproc;
    8000250c:	00006a17          	auipc	s4,0x6
    80002510:	5dca0a13          	addi	s4,s4,1500 # 80008ae8 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002514:	00016997          	auipc	s3,0x16
    80002518:	4ac98993          	addi	s3,s3,1196 # 800189c0 <tickslock>
    8000251c:	a029                	j	80002526 <reparent+0x34>
    8000251e:	1e048493          	addi	s1,s1,480
    80002522:	01348d63          	beq	s1,s3,8000253c <reparent+0x4a>
    if (pp->parent == p)
    80002526:	7c9c                	ld	a5,56(s1)
    80002528:	ff279be3          	bne	a5,s2,8000251e <reparent+0x2c>
      pp->parent = initproc;
    8000252c:	000a3503          	ld	a0,0(s4)
    80002530:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002532:	00000097          	auipc	ra,0x0
    80002536:	f30080e7          	jalr	-208(ra) # 80002462 <wakeup>
    8000253a:	b7d5                	j	8000251e <reparent+0x2c>
}
    8000253c:	70a2                	ld	ra,40(sp)
    8000253e:	7402                	ld	s0,32(sp)
    80002540:	64e2                	ld	s1,24(sp)
    80002542:	6942                	ld	s2,16(sp)
    80002544:	69a2                	ld	s3,8(sp)
    80002546:	6a02                	ld	s4,0(sp)
    80002548:	6145                	addi	sp,sp,48
    8000254a:	8082                	ret

000000008000254c <exit>:
{
    8000254c:	7179                	addi	sp,sp,-48
    8000254e:	f406                	sd	ra,40(sp)
    80002550:	f022                	sd	s0,32(sp)
    80002552:	ec26                	sd	s1,24(sp)
    80002554:	e84a                	sd	s2,16(sp)
    80002556:	e44e                	sd	s3,8(sp)
    80002558:	e052                	sd	s4,0(sp)
    8000255a:	1800                	addi	s0,sp,48
    8000255c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000255e:	fffff097          	auipc	ra,0xfffff
    80002562:	468080e7          	jalr	1128(ra) # 800019c6 <myproc>
    80002566:	89aa                	mv	s3,a0
  if (p == initproc)
    80002568:	00006797          	auipc	a5,0x6
    8000256c:	5807b783          	ld	a5,1408(a5) # 80008ae8 <initproc>
    80002570:	0d050493          	addi	s1,a0,208
    80002574:	15050913          	addi	s2,a0,336
    80002578:	02a79363          	bne	a5,a0,8000259e <exit+0x52>
    panic("init exiting");
    8000257c:	00006517          	auipc	a0,0x6
    80002580:	ce450513          	addi	a0,a0,-796 # 80008260 <digits+0x220>
    80002584:	ffffe097          	auipc	ra,0xffffe
    80002588:	fc0080e7          	jalr	-64(ra) # 80000544 <panic>
      fileclose(f);
    8000258c:	00002097          	auipc	ra,0x2
    80002590:	636080e7          	jalr	1590(ra) # 80004bc2 <fileclose>
      p->ofile[fd] = 0;
    80002594:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    80002598:	04a1                	addi	s1,s1,8
    8000259a:	01248563          	beq	s1,s2,800025a4 <exit+0x58>
    if (p->ofile[fd])
    8000259e:	6088                	ld	a0,0(s1)
    800025a0:	f575                	bnez	a0,8000258c <exit+0x40>
    800025a2:	bfdd                	j	80002598 <exit+0x4c>
  begin_op();
    800025a4:	00002097          	auipc	ra,0x2
    800025a8:	152080e7          	jalr	338(ra) # 800046f6 <begin_op>
  iput(p->cwd);
    800025ac:	1509b503          	ld	a0,336(s3)
    800025b0:	00002097          	auipc	ra,0x2
    800025b4:	93e080e7          	jalr	-1730(ra) # 80003eee <iput>
  end_op();
    800025b8:	00002097          	auipc	ra,0x2
    800025bc:	1be080e7          	jalr	446(ra) # 80004776 <end_op>
  p->cwd = 0;
    800025c0:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800025c4:	0000e497          	auipc	s1,0xe
    800025c8:	7b448493          	addi	s1,s1,1972 # 80010d78 <wait_lock>
    800025cc:	8526                	mv	a0,s1
    800025ce:	ffffe097          	auipc	ra,0xffffe
    800025d2:	61c080e7          	jalr	1564(ra) # 80000bea <acquire>
  reparent(p);
    800025d6:	854e                	mv	a0,s3
    800025d8:	00000097          	auipc	ra,0x0
    800025dc:	f1a080e7          	jalr	-230(ra) # 800024f2 <reparent>
  wakeup(p->parent);
    800025e0:	0389b503          	ld	a0,56(s3)
    800025e4:	00000097          	auipc	ra,0x0
    800025e8:	e7e080e7          	jalr	-386(ra) # 80002462 <wakeup>
  acquire(&p->lock);
    800025ec:	854e                	mv	a0,s3
    800025ee:	ffffe097          	auipc	ra,0xffffe
    800025f2:	5fc080e7          	jalr	1532(ra) # 80000bea <acquire>
  p->xstate = status;
    800025f6:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800025fa:	4795                	li	a5,5
    800025fc:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    80002600:	00006797          	auipc	a5,0x6
    80002604:	4f07a783          	lw	a5,1264(a5) # 80008af0 <ticks>
    80002608:	16f9aa23          	sw	a5,372(s3)
  release(&wait_lock);
    8000260c:	8526                	mv	a0,s1
    8000260e:	ffffe097          	auipc	ra,0xffffe
    80002612:	690080e7          	jalr	1680(ra) # 80000c9e <release>
  sched();
    80002616:	00000097          	auipc	ra,0x0
    8000261a:	b7e080e7          	jalr	-1154(ra) # 80002194 <sched>
  panic("zombie exit");
    8000261e:	00006517          	auipc	a0,0x6
    80002622:	c5250513          	addi	a0,a0,-942 # 80008270 <digits+0x230>
    80002626:	ffffe097          	auipc	ra,0xffffe
    8000262a:	f1e080e7          	jalr	-226(ra) # 80000544 <panic>

000000008000262e <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    8000262e:	7179                	addi	sp,sp,-48
    80002630:	f406                	sd	ra,40(sp)
    80002632:	f022                	sd	s0,32(sp)
    80002634:	ec26                	sd	s1,24(sp)
    80002636:	e84a                	sd	s2,16(sp)
    80002638:	e44e                	sd	s3,8(sp)
    8000263a:	1800                	addi	s0,sp,48
    8000263c:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000263e:	0000f497          	auipc	s1,0xf
    80002642:	b8248493          	addi	s1,s1,-1150 # 800111c0 <proc>
    80002646:	00016997          	auipc	s3,0x16
    8000264a:	37a98993          	addi	s3,s3,890 # 800189c0 <tickslock>
  {
    acquire(&p->lock);
    8000264e:	8526                	mv	a0,s1
    80002650:	ffffe097          	auipc	ra,0xffffe
    80002654:	59a080e7          	jalr	1434(ra) # 80000bea <acquire>
    if (p->pid == pid)
    80002658:	589c                	lw	a5,48(s1)
    8000265a:	01278d63          	beq	a5,s2,80002674 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000265e:	8526                	mv	a0,s1
    80002660:	ffffe097          	auipc	ra,0xffffe
    80002664:	63e080e7          	jalr	1598(ra) # 80000c9e <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002668:	1e048493          	addi	s1,s1,480
    8000266c:	ff3491e3          	bne	s1,s3,8000264e <kill+0x20>
  }
  return -1;
    80002670:	557d                	li	a0,-1
    80002672:	a829                	j	8000268c <kill+0x5e>
      p->killed = 1;
    80002674:	4785                	li	a5,1
    80002676:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    80002678:	4c98                	lw	a4,24(s1)
    8000267a:	4789                	li	a5,2
    8000267c:	00f70f63          	beq	a4,a5,8000269a <kill+0x6c>
      release(&p->lock);
    80002680:	8526                	mv	a0,s1
    80002682:	ffffe097          	auipc	ra,0xffffe
    80002686:	61c080e7          	jalr	1564(ra) # 80000c9e <release>
      return 0;
    8000268a:	4501                	li	a0,0
}
    8000268c:	70a2                	ld	ra,40(sp)
    8000268e:	7402                	ld	s0,32(sp)
    80002690:	64e2                	ld	s1,24(sp)
    80002692:	6942                	ld	s2,16(sp)
    80002694:	69a2                	ld	s3,8(sp)
    80002696:	6145                	addi	sp,sp,48
    80002698:	8082                	ret
        p->state = RUNNABLE;
    8000269a:	478d                	li	a5,3
    8000269c:	cc9c                	sw	a5,24(s1)
    8000269e:	b7cd                	j	80002680 <kill+0x52>

00000000800026a0 <setkilled>:

void setkilled(struct proc *p)
{
    800026a0:	1101                	addi	sp,sp,-32
    800026a2:	ec06                	sd	ra,24(sp)
    800026a4:	e822                	sd	s0,16(sp)
    800026a6:	e426                	sd	s1,8(sp)
    800026a8:	1000                	addi	s0,sp,32
    800026aa:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800026ac:	ffffe097          	auipc	ra,0xffffe
    800026b0:	53e080e7          	jalr	1342(ra) # 80000bea <acquire>
  p->killed = 1;
    800026b4:	4785                	li	a5,1
    800026b6:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800026b8:	8526                	mv	a0,s1
    800026ba:	ffffe097          	auipc	ra,0xffffe
    800026be:	5e4080e7          	jalr	1508(ra) # 80000c9e <release>
}
    800026c2:	60e2                	ld	ra,24(sp)
    800026c4:	6442                	ld	s0,16(sp)
    800026c6:	64a2                	ld	s1,8(sp)
    800026c8:	6105                	addi	sp,sp,32
    800026ca:	8082                	ret

00000000800026cc <killed>:

int killed(struct proc *p)
{
    800026cc:	1101                	addi	sp,sp,-32
    800026ce:	ec06                	sd	ra,24(sp)
    800026d0:	e822                	sd	s0,16(sp)
    800026d2:	e426                	sd	s1,8(sp)
    800026d4:	e04a                	sd	s2,0(sp)
    800026d6:	1000                	addi	s0,sp,32
    800026d8:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800026da:	ffffe097          	auipc	ra,0xffffe
    800026de:	510080e7          	jalr	1296(ra) # 80000bea <acquire>
  k = p->killed;
    800026e2:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800026e6:	8526                	mv	a0,s1
    800026e8:	ffffe097          	auipc	ra,0xffffe
    800026ec:	5b6080e7          	jalr	1462(ra) # 80000c9e <release>
  return k;
}
    800026f0:	854a                	mv	a0,s2
    800026f2:	60e2                	ld	ra,24(sp)
    800026f4:	6442                	ld	s0,16(sp)
    800026f6:	64a2                	ld	s1,8(sp)
    800026f8:	6902                	ld	s2,0(sp)
    800026fa:	6105                	addi	sp,sp,32
    800026fc:	8082                	ret

00000000800026fe <wait>:
{
    800026fe:	715d                	addi	sp,sp,-80
    80002700:	e486                	sd	ra,72(sp)
    80002702:	e0a2                	sd	s0,64(sp)
    80002704:	fc26                	sd	s1,56(sp)
    80002706:	f84a                	sd	s2,48(sp)
    80002708:	f44e                	sd	s3,40(sp)
    8000270a:	f052                	sd	s4,32(sp)
    8000270c:	ec56                	sd	s5,24(sp)
    8000270e:	e85a                	sd	s6,16(sp)
    80002710:	e45e                	sd	s7,8(sp)
    80002712:	e062                	sd	s8,0(sp)
    80002714:	0880                	addi	s0,sp,80
    80002716:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002718:	fffff097          	auipc	ra,0xfffff
    8000271c:	2ae080e7          	jalr	686(ra) # 800019c6 <myproc>
    80002720:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002722:	0000e517          	auipc	a0,0xe
    80002726:	65650513          	addi	a0,a0,1622 # 80010d78 <wait_lock>
    8000272a:	ffffe097          	auipc	ra,0xffffe
    8000272e:	4c0080e7          	jalr	1216(ra) # 80000bea <acquire>
    havekids = 0;
    80002732:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    80002734:	4a15                	li	s4,5
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002736:	00016997          	auipc	s3,0x16
    8000273a:	28a98993          	addi	s3,s3,650 # 800189c0 <tickslock>
        havekids = 1;
    8000273e:	4a85                	li	s5,1
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002740:	0000ec17          	auipc	s8,0xe
    80002744:	638c0c13          	addi	s8,s8,1592 # 80010d78 <wait_lock>
    havekids = 0;
    80002748:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000274a:	0000f497          	auipc	s1,0xf
    8000274e:	a7648493          	addi	s1,s1,-1418 # 800111c0 <proc>
    80002752:	a0bd                	j	800027c0 <wait+0xc2>
          pid = pp->pid;
    80002754:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002758:	000b0e63          	beqz	s6,80002774 <wait+0x76>
    8000275c:	4691                	li	a3,4
    8000275e:	02c48613          	addi	a2,s1,44
    80002762:	85da                	mv	a1,s6
    80002764:	05093503          	ld	a0,80(s2)
    80002768:	fffff097          	auipc	ra,0xfffff
    8000276c:	f1c080e7          	jalr	-228(ra) # 80001684 <copyout>
    80002770:	02054563          	bltz	a0,8000279a <wait+0x9c>
          freeproc(pp);
    80002774:	8526                	mv	a0,s1
    80002776:	fffff097          	auipc	ra,0xfffff
    8000277a:	402080e7          	jalr	1026(ra) # 80001b78 <freeproc>
          release(&pp->lock);
    8000277e:	8526                	mv	a0,s1
    80002780:	ffffe097          	auipc	ra,0xffffe
    80002784:	51e080e7          	jalr	1310(ra) # 80000c9e <release>
          release(&wait_lock);
    80002788:	0000e517          	auipc	a0,0xe
    8000278c:	5f050513          	addi	a0,a0,1520 # 80010d78 <wait_lock>
    80002790:	ffffe097          	auipc	ra,0xffffe
    80002794:	50e080e7          	jalr	1294(ra) # 80000c9e <release>
          return pid;
    80002798:	a0b5                	j	80002804 <wait+0x106>
            release(&pp->lock);
    8000279a:	8526                	mv	a0,s1
    8000279c:	ffffe097          	auipc	ra,0xffffe
    800027a0:	502080e7          	jalr	1282(ra) # 80000c9e <release>
            release(&wait_lock);
    800027a4:	0000e517          	auipc	a0,0xe
    800027a8:	5d450513          	addi	a0,a0,1492 # 80010d78 <wait_lock>
    800027ac:	ffffe097          	auipc	ra,0xffffe
    800027b0:	4f2080e7          	jalr	1266(ra) # 80000c9e <release>
            return -1;
    800027b4:	59fd                	li	s3,-1
    800027b6:	a0b9                	j	80002804 <wait+0x106>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800027b8:	1e048493          	addi	s1,s1,480
    800027bc:	03348463          	beq	s1,s3,800027e4 <wait+0xe6>
      if (pp->parent == p)
    800027c0:	7c9c                	ld	a5,56(s1)
    800027c2:	ff279be3          	bne	a5,s2,800027b8 <wait+0xba>
        acquire(&pp->lock);
    800027c6:	8526                	mv	a0,s1
    800027c8:	ffffe097          	auipc	ra,0xffffe
    800027cc:	422080e7          	jalr	1058(ra) # 80000bea <acquire>
        if (pp->state == ZOMBIE)
    800027d0:	4c9c                	lw	a5,24(s1)
    800027d2:	f94781e3          	beq	a5,s4,80002754 <wait+0x56>
        release(&pp->lock);
    800027d6:	8526                	mv	a0,s1
    800027d8:	ffffe097          	auipc	ra,0xffffe
    800027dc:	4c6080e7          	jalr	1222(ra) # 80000c9e <release>
        havekids = 1;
    800027e0:	8756                	mv	a4,s5
    800027e2:	bfd9                	j	800027b8 <wait+0xba>
    if (!havekids || killed(p))
    800027e4:	c719                	beqz	a4,800027f2 <wait+0xf4>
    800027e6:	854a                	mv	a0,s2
    800027e8:	00000097          	auipc	ra,0x0
    800027ec:	ee4080e7          	jalr	-284(ra) # 800026cc <killed>
    800027f0:	c51d                	beqz	a0,8000281e <wait+0x120>
      release(&wait_lock);
    800027f2:	0000e517          	auipc	a0,0xe
    800027f6:	58650513          	addi	a0,a0,1414 # 80010d78 <wait_lock>
    800027fa:	ffffe097          	auipc	ra,0xffffe
    800027fe:	4a4080e7          	jalr	1188(ra) # 80000c9e <release>
      return -1;
    80002802:	59fd                	li	s3,-1
}
    80002804:	854e                	mv	a0,s3
    80002806:	60a6                	ld	ra,72(sp)
    80002808:	6406                	ld	s0,64(sp)
    8000280a:	74e2                	ld	s1,56(sp)
    8000280c:	7942                	ld	s2,48(sp)
    8000280e:	79a2                	ld	s3,40(sp)
    80002810:	7a02                	ld	s4,32(sp)
    80002812:	6ae2                	ld	s5,24(sp)
    80002814:	6b42                	ld	s6,16(sp)
    80002816:	6ba2                	ld	s7,8(sp)
    80002818:	6c02                	ld	s8,0(sp)
    8000281a:	6161                	addi	sp,sp,80
    8000281c:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000281e:	85e2                	mv	a1,s8
    80002820:	854a                	mv	a0,s2
    80002822:	00000097          	auipc	ra,0x0
    80002826:	a84080e7          	jalr	-1404(ra) # 800022a6 <sleep>
    havekids = 0;
    8000282a:	bf39                	j	80002748 <wait+0x4a>

000000008000282c <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000282c:	7179                	addi	sp,sp,-48
    8000282e:	f406                	sd	ra,40(sp)
    80002830:	f022                	sd	s0,32(sp)
    80002832:	ec26                	sd	s1,24(sp)
    80002834:	e84a                	sd	s2,16(sp)
    80002836:	e44e                	sd	s3,8(sp)
    80002838:	e052                	sd	s4,0(sp)
    8000283a:	1800                	addi	s0,sp,48
    8000283c:	84aa                	mv	s1,a0
    8000283e:	892e                	mv	s2,a1
    80002840:	89b2                	mv	s3,a2
    80002842:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002844:	fffff097          	auipc	ra,0xfffff
    80002848:	182080e7          	jalr	386(ra) # 800019c6 <myproc>
  if (user_dst)
    8000284c:	c08d                	beqz	s1,8000286e <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    8000284e:	86d2                	mv	a3,s4
    80002850:	864e                	mv	a2,s3
    80002852:	85ca                	mv	a1,s2
    80002854:	6928                	ld	a0,80(a0)
    80002856:	fffff097          	auipc	ra,0xfffff
    8000285a:	e2e080e7          	jalr	-466(ra) # 80001684 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000285e:	70a2                	ld	ra,40(sp)
    80002860:	7402                	ld	s0,32(sp)
    80002862:	64e2                	ld	s1,24(sp)
    80002864:	6942                	ld	s2,16(sp)
    80002866:	69a2                	ld	s3,8(sp)
    80002868:	6a02                	ld	s4,0(sp)
    8000286a:	6145                	addi	sp,sp,48
    8000286c:	8082                	ret
    memmove((char *)dst, src, len);
    8000286e:	000a061b          	sext.w	a2,s4
    80002872:	85ce                	mv	a1,s3
    80002874:	854a                	mv	a0,s2
    80002876:	ffffe097          	auipc	ra,0xffffe
    8000287a:	4d0080e7          	jalr	1232(ra) # 80000d46 <memmove>
    return 0;
    8000287e:	8526                	mv	a0,s1
    80002880:	bff9                	j	8000285e <either_copyout+0x32>

0000000080002882 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002882:	7179                	addi	sp,sp,-48
    80002884:	f406                	sd	ra,40(sp)
    80002886:	f022                	sd	s0,32(sp)
    80002888:	ec26                	sd	s1,24(sp)
    8000288a:	e84a                	sd	s2,16(sp)
    8000288c:	e44e                	sd	s3,8(sp)
    8000288e:	e052                	sd	s4,0(sp)
    80002890:	1800                	addi	s0,sp,48
    80002892:	892a                	mv	s2,a0
    80002894:	84ae                	mv	s1,a1
    80002896:	89b2                	mv	s3,a2
    80002898:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000289a:	fffff097          	auipc	ra,0xfffff
    8000289e:	12c080e7          	jalr	300(ra) # 800019c6 <myproc>
  if (user_src)
    800028a2:	c08d                	beqz	s1,800028c4 <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    800028a4:	86d2                	mv	a3,s4
    800028a6:	864e                	mv	a2,s3
    800028a8:	85ca                	mv	a1,s2
    800028aa:	6928                	ld	a0,80(a0)
    800028ac:	fffff097          	auipc	ra,0xfffff
    800028b0:	e64080e7          	jalr	-412(ra) # 80001710 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800028b4:	70a2                	ld	ra,40(sp)
    800028b6:	7402                	ld	s0,32(sp)
    800028b8:	64e2                	ld	s1,24(sp)
    800028ba:	6942                	ld	s2,16(sp)
    800028bc:	69a2                	ld	s3,8(sp)
    800028be:	6a02                	ld	s4,0(sp)
    800028c0:	6145                	addi	sp,sp,48
    800028c2:	8082                	ret
    memmove(dst, (char *)src, len);
    800028c4:	000a061b          	sext.w	a2,s4
    800028c8:	85ce                	mv	a1,s3
    800028ca:	854a                	mv	a0,s2
    800028cc:	ffffe097          	auipc	ra,0xffffe
    800028d0:	47a080e7          	jalr	1146(ra) # 80000d46 <memmove>
    return 0;
    800028d4:	8526                	mv	a0,s1
    800028d6:	bff9                	j	800028b4 <either_copyin+0x32>

00000000800028d8 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    800028d8:	7139                	addi	sp,sp,-64
    800028da:	fc06                	sd	ra,56(sp)
    800028dc:	f822                	sd	s0,48(sp)
    800028de:	f426                	sd	s1,40(sp)
    800028e0:	f04a                	sd	s2,32(sp)
    800028e2:	ec4e                	sd	s3,24(sp)
    800028e4:	e852                	sd	s4,16(sp)
    800028e6:	e456                	sd	s5,8(sp)
    800028e8:	0080                	addi	s0,sp,64
  struct proc *p;

  printf("\n");
    800028ea:	00005517          	auipc	a0,0x5
    800028ee:	7de50513          	addi	a0,a0,2014 # 800080c8 <digits+0x88>
    800028f2:	ffffe097          	auipc	ra,0xffffe
    800028f6:	c9c080e7          	jalr	-868(ra) # 8000058e <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800028fa:	0000f497          	auipc	s1,0xf
    800028fe:	8c648493          	addi	s1,s1,-1850 # 800111c0 <proc>
  {
    if (p->state == UNUSED)
      continue;
    if(p->pid > 3){
    80002902:	498d                	li	s3,3
    printf("%d-%d", p->pid, p->queue);
    80002904:	00006a97          	auipc	s5,0x6
    80002908:	97ca8a93          	addi	s5,s5,-1668 # 80008280 <digits+0x240>
    //printf("#NN - %d %s %s %d %d %d %d", p->pid, state, p->name, p->queue, p->tickcount, p->waittickcount, p->queueposition);
    printf("\n");
    8000290c:	00005a17          	auipc	s4,0x5
    80002910:	7bca0a13          	addi	s4,s4,1980 # 800080c8 <digits+0x88>
  for (p = proc; p < &proc[NPROC]; p++)
    80002914:	00016917          	auipc	s2,0x16
    80002918:	0ac90913          	addi	s2,s2,172 # 800189c0 <tickslock>
    8000291c:	a00d                	j	8000293e <procdump+0x66>
    printf("%d-%d", p->pid, p->queue);
    8000291e:	1d44a603          	lw	a2,468(s1)
    80002922:	8556                	mv	a0,s5
    80002924:	ffffe097          	auipc	ra,0xffffe
    80002928:	c6a080e7          	jalr	-918(ra) # 8000058e <printf>
    printf("\n");
    8000292c:	8552                	mv	a0,s4
    8000292e:	ffffe097          	auipc	ra,0xffffe
    80002932:	c60080e7          	jalr	-928(ra) # 8000058e <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002936:	1e048493          	addi	s1,s1,480
    8000293a:	01248863          	beq	s1,s2,8000294a <procdump+0x72>
    if (p->state == UNUSED)
    8000293e:	4c9c                	lw	a5,24(s1)
    80002940:	dbfd                	beqz	a5,80002936 <procdump+0x5e>
    if(p->pid > 3){
    80002942:	588c                	lw	a1,48(s1)
    80002944:	feb9d9e3          	bge	s3,a1,80002936 <procdump+0x5e>
    80002948:	bfd9                	j	8000291e <procdump+0x46>
    }
  }
  //printf("%d %d %d %d %d\n", queueprocesscount[0], queueprocesscount[1], queueprocesscount[2], queueprocesscount[3], queueprocesscount[4]);
}
    8000294a:	70e2                	ld	ra,56(sp)
    8000294c:	7442                	ld	s0,48(sp)
    8000294e:	74a2                	ld	s1,40(sp)
    80002950:	7902                	ld	s2,32(sp)
    80002952:	69e2                	ld	s3,24(sp)
    80002954:	6a42                	ld	s4,16(sp)
    80002956:	6aa2                	ld	s5,8(sp)
    80002958:	6121                	addi	sp,sp,64
    8000295a:	8082                	ret

000000008000295c <setpriority>:

int setpriority(int new_priority, int pid)
{
    8000295c:	7179                	addi	sp,sp,-48
    8000295e:	f406                	sd	ra,40(sp)
    80002960:	f022                	sd	s0,32(sp)
    80002962:	ec26                	sd	s1,24(sp)
    80002964:	e84a                	sd	s2,16(sp)
    80002966:	e44e                	sd	s3,8(sp)
    80002968:	e052                	sd	s4,0(sp)
    8000296a:	1800                	addi	s0,sp,48
    8000296c:	8a2a                	mv	s4,a0
    8000296e:	892e                	mv	s2,a1
  int prev_priority;
  prev_priority = 0;

  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    80002970:	0000f497          	auipc	s1,0xf
    80002974:	85048493          	addi	s1,s1,-1968 # 800111c0 <proc>
    80002978:	00016997          	auipc	s3,0x16
    8000297c:	04898993          	addi	s3,s3,72 # 800189c0 <tickslock>
  {
    acquire(&p->lock);
    80002980:	8526                	mv	a0,s1
    80002982:	ffffe097          	auipc	ra,0xffffe
    80002986:	268080e7          	jalr	616(ra) # 80000bea <acquire>

    if (p->pid == pid)
    8000298a:	589c                	lw	a5,48(s1)
    8000298c:	01278d63          	beq	a5,s2,800029a6 <setpriority+0x4a>
        yield();
      }

      break;
    }
    release(&p->lock);
    80002990:	8526                	mv	a0,s1
    80002992:	ffffe097          	auipc	ra,0xffffe
    80002996:	30c080e7          	jalr	780(ra) # 80000c9e <release>
  for (p = proc; p < &proc[NPROC]; p++)
    8000299a:	1e048493          	addi	s1,s1,480
    8000299e:	ff3491e3          	bne	s1,s3,80002980 <setpriority+0x24>
  prev_priority = 0;
    800029a2:	4901                	li	s2,0
    800029a4:	a005                	j	800029c4 <setpriority+0x68>
      prev_priority = p->priority;
    800029a6:	1c84a903          	lw	s2,456(s1)
      p->priority = new_priority;
    800029aa:	1d44b423          	sd	s4,456(s1)
      p->sleeptime = 0;
    800029ae:	1a04bc23          	sd	zero,440(s1)
      p->runtime = 0;
    800029b2:	1a04b423          	sd	zero,424(s1)
      release(&p->lock);
    800029b6:	8526                	mv	a0,s1
    800029b8:	ffffe097          	auipc	ra,0xffffe
    800029bc:	2e6080e7          	jalr	742(ra) # 80000c9e <release>
      if (reschedule)
    800029c0:	012a4b63          	blt	s4,s2,800029d6 <setpriority+0x7a>
  }
  return prev_priority;
}
    800029c4:	854a                	mv	a0,s2
    800029c6:	70a2                	ld	ra,40(sp)
    800029c8:	7402                	ld	s0,32(sp)
    800029ca:	64e2                	ld	s1,24(sp)
    800029cc:	6942                	ld	s2,16(sp)
    800029ce:	69a2                	ld	s3,8(sp)
    800029d0:	6a02                	ld	s4,0(sp)
    800029d2:	6145                	addi	sp,sp,48
    800029d4:	8082                	ret
        yield();
    800029d6:	00000097          	auipc	ra,0x0
    800029da:	894080e7          	jalr	-1900(ra) # 8000226a <yield>
    800029de:	b7dd                	j	800029c4 <setpriority+0x68>

00000000800029e0 <swtch>:
    800029e0:	00153023          	sd	ra,0(a0)
    800029e4:	00253423          	sd	sp,8(a0)
    800029e8:	e900                	sd	s0,16(a0)
    800029ea:	ed04                	sd	s1,24(a0)
    800029ec:	03253023          	sd	s2,32(a0)
    800029f0:	03353423          	sd	s3,40(a0)
    800029f4:	03453823          	sd	s4,48(a0)
    800029f8:	03553c23          	sd	s5,56(a0)
    800029fc:	05653023          	sd	s6,64(a0)
    80002a00:	05753423          	sd	s7,72(a0)
    80002a04:	05853823          	sd	s8,80(a0)
    80002a08:	05953c23          	sd	s9,88(a0)
    80002a0c:	07a53023          	sd	s10,96(a0)
    80002a10:	07b53423          	sd	s11,104(a0)
    80002a14:	0005b083          	ld	ra,0(a1)
    80002a18:	0085b103          	ld	sp,8(a1)
    80002a1c:	6980                	ld	s0,16(a1)
    80002a1e:	6d84                	ld	s1,24(a1)
    80002a20:	0205b903          	ld	s2,32(a1)
    80002a24:	0285b983          	ld	s3,40(a1)
    80002a28:	0305ba03          	ld	s4,48(a1)
    80002a2c:	0385ba83          	ld	s5,56(a1)
    80002a30:	0405bb03          	ld	s6,64(a1)
    80002a34:	0485bb83          	ld	s7,72(a1)
    80002a38:	0505bc03          	ld	s8,80(a1)
    80002a3c:	0585bc83          	ld	s9,88(a1)
    80002a40:	0605bd03          	ld	s10,96(a1)
    80002a44:	0685bd83          	ld	s11,104(a1)
    80002a48:	8082                	ret

0000000080002a4a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002a4a:	1141                	addi	sp,sp,-16
    80002a4c:	e406                	sd	ra,8(sp)
    80002a4e:	e022                	sd	s0,0(sp)
    80002a50:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002a52:	00006597          	auipc	a1,0x6
    80002a56:	83658593          	addi	a1,a1,-1994 # 80008288 <digits+0x248>
    80002a5a:	00016517          	auipc	a0,0x16
    80002a5e:	f6650513          	addi	a0,a0,-154 # 800189c0 <tickslock>
    80002a62:	ffffe097          	auipc	ra,0xffffe
    80002a66:	0f8080e7          	jalr	248(ra) # 80000b5a <initlock>
}
    80002a6a:	60a2                	ld	ra,8(sp)
    80002a6c:	6402                	ld	s0,0(sp)
    80002a6e:	0141                	addi	sp,sp,16
    80002a70:	8082                	ret

0000000080002a72 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002a72:	1141                	addi	sp,sp,-16
    80002a74:	e422                	sd	s0,8(sp)
    80002a76:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a78:	00003797          	auipc	a5,0x3
    80002a7c:	78878793          	addi	a5,a5,1928 # 80006200 <kernelvec>
    80002a80:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002a84:	6422                	ld	s0,8(sp)
    80002a86:	0141                	addi	sp,sp,16
    80002a88:	8082                	ret

0000000080002a8a <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002a8a:	1141                	addi	sp,sp,-16
    80002a8c:	e406                	sd	ra,8(sp)
    80002a8e:	e022                	sd	s0,0(sp)
    80002a90:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002a92:	fffff097          	auipc	ra,0xfffff
    80002a96:	f34080e7          	jalr	-204(ra) # 800019c6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a9a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002a9e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002aa0:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002aa4:	00004617          	auipc	a2,0x4
    80002aa8:	55c60613          	addi	a2,a2,1372 # 80007000 <_trampoline>
    80002aac:	00004697          	auipc	a3,0x4
    80002ab0:	55468693          	addi	a3,a3,1364 # 80007000 <_trampoline>
    80002ab4:	8e91                	sub	a3,a3,a2
    80002ab6:	040007b7          	lui	a5,0x4000
    80002aba:	17fd                	addi	a5,a5,-1
    80002abc:	07b2                	slli	a5,a5,0xc
    80002abe:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ac0:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002ac4:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002ac6:	180026f3          	csrr	a3,satp
    80002aca:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002acc:	6d38                	ld	a4,88(a0)
    80002ace:	6134                	ld	a3,64(a0)
    80002ad0:	6585                	lui	a1,0x1
    80002ad2:	96ae                	add	a3,a3,a1
    80002ad4:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002ad6:	6d38                	ld	a4,88(a0)
    80002ad8:	00000697          	auipc	a3,0x0
    80002adc:	13e68693          	addi	a3,a3,318 # 80002c16 <usertrap>
    80002ae0:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002ae2:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002ae4:	8692                	mv	a3,tp
    80002ae6:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ae8:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002aec:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002af0:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002af4:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002af8:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002afa:	6f18                	ld	a4,24(a4)
    80002afc:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002b00:	6928                	ld	a0,80(a0)
    80002b02:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002b04:	00004717          	auipc	a4,0x4
    80002b08:	59870713          	addi	a4,a4,1432 # 8000709c <userret>
    80002b0c:	8f11                	sub	a4,a4,a2
    80002b0e:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002b10:	577d                	li	a4,-1
    80002b12:	177e                	slli	a4,a4,0x3f
    80002b14:	8d59                	or	a0,a0,a4
    80002b16:	9782                	jalr	a5
}
    80002b18:	60a2                	ld	ra,8(sp)
    80002b1a:	6402                	ld	s0,0(sp)
    80002b1c:	0141                	addi	sp,sp,16
    80002b1e:	8082                	ret

0000000080002b20 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002b20:	1101                	addi	sp,sp,-32
    80002b22:	ec06                	sd	ra,24(sp)
    80002b24:	e822                	sd	s0,16(sp)
    80002b26:	e426                	sd	s1,8(sp)
    80002b28:	e04a                	sd	s2,0(sp)
    80002b2a:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002b2c:	00016917          	auipc	s2,0x16
    80002b30:	e9490913          	addi	s2,s2,-364 # 800189c0 <tickslock>
    80002b34:	854a                	mv	a0,s2
    80002b36:	ffffe097          	auipc	ra,0xffffe
    80002b3a:	0b4080e7          	jalr	180(ra) # 80000bea <acquire>
  ticks++;
    80002b3e:	00006497          	auipc	s1,0x6
    80002b42:	fb248493          	addi	s1,s1,-78 # 80008af0 <ticks>
    80002b46:	409c                	lw	a5,0(s1)
    80002b48:	2785                	addiw	a5,a5,1
    80002b4a:	c09c                	sw	a5,0(s1)
  update_time();
    80002b4c:	fffff097          	auipc	ra,0xfffff
    80002b50:	422080e7          	jalr	1058(ra) # 80001f6e <update_time>
  wakeup(&ticks);
    80002b54:	8526                	mv	a0,s1
    80002b56:	00000097          	auipc	ra,0x0
    80002b5a:	90c080e7          	jalr	-1780(ra) # 80002462 <wakeup>
  release(&tickslock);
    80002b5e:	854a                	mv	a0,s2
    80002b60:	ffffe097          	auipc	ra,0xffffe
    80002b64:	13e080e7          	jalr	318(ra) # 80000c9e <release>
}
    80002b68:	60e2                	ld	ra,24(sp)
    80002b6a:	6442                	ld	s0,16(sp)
    80002b6c:	64a2                	ld	s1,8(sp)
    80002b6e:	6902                	ld	s2,0(sp)
    80002b70:	6105                	addi	sp,sp,32
    80002b72:	8082                	ret

0000000080002b74 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002b74:	1101                	addi	sp,sp,-32
    80002b76:	ec06                	sd	ra,24(sp)
    80002b78:	e822                	sd	s0,16(sp)
    80002b7a:	e426                	sd	s1,8(sp)
    80002b7c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b7e:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002b82:	00074d63          	bltz	a4,80002b9c <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002b86:	57fd                	li	a5,-1
    80002b88:	17fe                	slli	a5,a5,0x3f
    80002b8a:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002b8c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002b8e:	06f70363          	beq	a4,a5,80002bf4 <devintr+0x80>
  }
}
    80002b92:	60e2                	ld	ra,24(sp)
    80002b94:	6442                	ld	s0,16(sp)
    80002b96:	64a2                	ld	s1,8(sp)
    80002b98:	6105                	addi	sp,sp,32
    80002b9a:	8082                	ret
     (scause & 0xff) == 9){
    80002b9c:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002ba0:	46a5                	li	a3,9
    80002ba2:	fed792e3          	bne	a5,a3,80002b86 <devintr+0x12>
    int irq = plic_claim();
    80002ba6:	00003097          	auipc	ra,0x3
    80002baa:	762080e7          	jalr	1890(ra) # 80006308 <plic_claim>
    80002bae:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002bb0:	47a9                	li	a5,10
    80002bb2:	02f50763          	beq	a0,a5,80002be0 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002bb6:	4785                	li	a5,1
    80002bb8:	02f50963          	beq	a0,a5,80002bea <devintr+0x76>
    return 1;
    80002bbc:	4505                	li	a0,1
    } else if(irq){
    80002bbe:	d8f1                	beqz	s1,80002b92 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002bc0:	85a6                	mv	a1,s1
    80002bc2:	00005517          	auipc	a0,0x5
    80002bc6:	6ce50513          	addi	a0,a0,1742 # 80008290 <digits+0x250>
    80002bca:	ffffe097          	auipc	ra,0xffffe
    80002bce:	9c4080e7          	jalr	-1596(ra) # 8000058e <printf>
      plic_complete(irq);
    80002bd2:	8526                	mv	a0,s1
    80002bd4:	00003097          	auipc	ra,0x3
    80002bd8:	758080e7          	jalr	1880(ra) # 8000632c <plic_complete>
    return 1;
    80002bdc:	4505                	li	a0,1
    80002bde:	bf55                	j	80002b92 <devintr+0x1e>
      uartintr();
    80002be0:	ffffe097          	auipc	ra,0xffffe
    80002be4:	dce080e7          	jalr	-562(ra) # 800009ae <uartintr>
    80002be8:	b7ed                	j	80002bd2 <devintr+0x5e>
      virtio_disk_intr();
    80002bea:	00004097          	auipc	ra,0x4
    80002bee:	c6c080e7          	jalr	-916(ra) # 80006856 <virtio_disk_intr>
    80002bf2:	b7c5                	j	80002bd2 <devintr+0x5e>
    if(cpuid() == 0){
    80002bf4:	fffff097          	auipc	ra,0xfffff
    80002bf8:	da6080e7          	jalr	-602(ra) # 8000199a <cpuid>
    80002bfc:	c901                	beqz	a0,80002c0c <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002bfe:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002c02:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002c04:	14479073          	csrw	sip,a5
    return 2;
    80002c08:	4509                	li	a0,2
    80002c0a:	b761                	j	80002b92 <devintr+0x1e>
      clockintr();
    80002c0c:	00000097          	auipc	ra,0x0
    80002c10:	f14080e7          	jalr	-236(ra) # 80002b20 <clockintr>
    80002c14:	b7ed                	j	80002bfe <devintr+0x8a>

0000000080002c16 <usertrap>:
{
    80002c16:	1101                	addi	sp,sp,-32
    80002c18:	ec06                	sd	ra,24(sp)
    80002c1a:	e822                	sd	s0,16(sp)
    80002c1c:	e426                	sd	s1,8(sp)
    80002c1e:	e04a                	sd	s2,0(sp)
    80002c20:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c22:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002c26:	1007f793          	andi	a5,a5,256
    80002c2a:	e3b1                	bnez	a5,80002c6e <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c2c:	00003797          	auipc	a5,0x3
    80002c30:	5d478793          	addi	a5,a5,1492 # 80006200 <kernelvec>
    80002c34:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002c38:	fffff097          	auipc	ra,0xfffff
    80002c3c:	d8e080e7          	jalr	-626(ra) # 800019c6 <myproc>
    80002c40:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002c42:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c44:	14102773          	csrr	a4,sepc
    80002c48:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c4a:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002c4e:	47a1                	li	a5,8
    80002c50:	02f70763          	beq	a4,a5,80002c7e <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002c54:	00000097          	auipc	ra,0x0
    80002c58:	f20080e7          	jalr	-224(ra) # 80002b74 <devintr>
    80002c5c:	892a                	mv	s2,a0
    80002c5e:	c92d                	beqz	a0,80002cd0 <usertrap+0xba>
  if(killed(p))
    80002c60:	8526                	mv	a0,s1
    80002c62:	00000097          	auipc	ra,0x0
    80002c66:	a6a080e7          	jalr	-1430(ra) # 800026cc <killed>
    80002c6a:	c555                	beqz	a0,80002d16 <usertrap+0x100>
    80002c6c:	a045                	j	80002d0c <usertrap+0xf6>
    panic("usertrap: not from user mode");
    80002c6e:	00005517          	auipc	a0,0x5
    80002c72:	64250513          	addi	a0,a0,1602 # 800082b0 <digits+0x270>
    80002c76:	ffffe097          	auipc	ra,0xffffe
    80002c7a:	8ce080e7          	jalr	-1842(ra) # 80000544 <panic>
    if(killed(p))
    80002c7e:	00000097          	auipc	ra,0x0
    80002c82:	a4e080e7          	jalr	-1458(ra) # 800026cc <killed>
    80002c86:	ed1d                	bnez	a0,80002cc4 <usertrap+0xae>
    p->trapframe->epc += 4;
    80002c88:	6cb8                	ld	a4,88(s1)
    80002c8a:	6f1c                	ld	a5,24(a4)
    80002c8c:	0791                	addi	a5,a5,4
    80002c8e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c90:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002c94:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c98:	10079073          	csrw	sstatus,a5
    syscall();
    80002c9c:	00000097          	auipc	ra,0x0
    80002ca0:	302080e7          	jalr	770(ra) # 80002f9e <syscall>
  if(killed(p))
    80002ca4:	8526                	mv	a0,s1
    80002ca6:	00000097          	auipc	ra,0x0
    80002caa:	a26080e7          	jalr	-1498(ra) # 800026cc <killed>
    80002cae:	ed31                	bnez	a0,80002d0a <usertrap+0xf4>
  usertrapret();
    80002cb0:	00000097          	auipc	ra,0x0
    80002cb4:	dda080e7          	jalr	-550(ra) # 80002a8a <usertrapret>
}
    80002cb8:	60e2                	ld	ra,24(sp)
    80002cba:	6442                	ld	s0,16(sp)
    80002cbc:	64a2                	ld	s1,8(sp)
    80002cbe:	6902                	ld	s2,0(sp)
    80002cc0:	6105                	addi	sp,sp,32
    80002cc2:	8082                	ret
      exit(-1);
    80002cc4:	557d                	li	a0,-1
    80002cc6:	00000097          	auipc	ra,0x0
    80002cca:	886080e7          	jalr	-1914(ra) # 8000254c <exit>
    80002cce:	bf6d                	j	80002c88 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cd0:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002cd4:	5890                	lw	a2,48(s1)
    80002cd6:	00005517          	auipc	a0,0x5
    80002cda:	5fa50513          	addi	a0,a0,1530 # 800082d0 <digits+0x290>
    80002cde:	ffffe097          	auipc	ra,0xffffe
    80002ce2:	8b0080e7          	jalr	-1872(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ce6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002cea:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002cee:	00005517          	auipc	a0,0x5
    80002cf2:	61250513          	addi	a0,a0,1554 # 80008300 <digits+0x2c0>
    80002cf6:	ffffe097          	auipc	ra,0xffffe
    80002cfa:	898080e7          	jalr	-1896(ra) # 8000058e <printf>
    setkilled(p);
    80002cfe:	8526                	mv	a0,s1
    80002d00:	00000097          	auipc	ra,0x0
    80002d04:	9a0080e7          	jalr	-1632(ra) # 800026a0 <setkilled>
    80002d08:	bf71                	j	80002ca4 <usertrap+0x8e>
  if(killed(p))
    80002d0a:	4901                	li	s2,0
    exit(-1);
    80002d0c:	557d                	li	a0,-1
    80002d0e:	00000097          	auipc	ra,0x0
    80002d12:	83e080e7          	jalr	-1986(ra) # 8000254c <exit>
  if (which_dev == 2 && p->alarm_on == 1 && p->handlerpermission == 1) {
    80002d16:	4789                	li	a5,2
    80002d18:	f8f91ce3          	bne	s2,a5,80002cb0 <usertrap+0x9a>
    80002d1c:	1984b703          	ld	a4,408(s1)
    80002d20:	4785                	li	a5,1
    80002d22:	1782                	slli	a5,a5,0x20
    80002d24:	0785                	addi	a5,a5,1
    80002d26:	00f70c63          	beq	a4,a5,80002d3e <usertrap+0x128>
    if(p->state == RUNNING)
    80002d2a:	4c98                	lw	a4,24(s1)
    80002d2c:	4791                	li	a5,4
    80002d2e:	f8f711e3          	bne	a4,a5,80002cb0 <usertrap+0x9a>
      p->runtime++;
    80002d32:	1a84b783          	ld	a5,424(s1)
    80002d36:	0785                	addi	a5,a5,1
    80002d38:	1af4b423          	sd	a5,424(s1)
    80002d3c:	bf95                	j	80002cb0 <usertrap+0x9a>
      struct trapframe *tf = kalloc();
    80002d3e:	ffffe097          	auipc	ra,0xffffe
    80002d42:	dbc080e7          	jalr	-580(ra) # 80000afa <kalloc>
    80002d46:	892a                	mv	s2,a0
      memmove(tf, p->trapframe, PGSIZE);
    80002d48:	6605                	lui	a2,0x1
    80002d4a:	6cac                	ld	a1,88(s1)
    80002d4c:	ffffe097          	auipc	ra,0xffffe
    80002d50:	ffa080e7          	jalr	-6(ra) # 80000d46 <memmove>
      p->alarm_tf = tf;
    80002d54:	1924b823          	sd	s2,400(s1)
      p->cur_ticks++;
    80002d58:	18c4a783          	lw	a5,396(s1)
    80002d5c:	2785                	addiw	a5,a5,1
    80002d5e:	18f4a623          	sw	a5,396(s1)
      if (p->cur_ticks % p->ticks == 0){
    80002d62:	1884a703          	lw	a4,392(s1)
    80002d66:	02e7e7bb          	remw	a5,a5,a4
    80002d6a:	f3e1                	bnez	a5,80002d2a <usertrap+0x114>
        p->trapframe->epc = p->handler;
    80002d6c:	6cbc                	ld	a5,88(s1)
    80002d6e:	1804b703          	ld	a4,384(s1)
    80002d72:	ef98                	sd	a4,24(a5)
        p->handlerpermission = 0;
    80002d74:	1804ae23          	sw	zero,412(s1)
    80002d78:	bf4d                	j	80002d2a <usertrap+0x114>

0000000080002d7a <kerneltrap>:
{
    80002d7a:	7179                	addi	sp,sp,-48
    80002d7c:	f406                	sd	ra,40(sp)
    80002d7e:	f022                	sd	s0,32(sp)
    80002d80:	ec26                	sd	s1,24(sp)
    80002d82:	e84a                	sd	s2,16(sp)
    80002d84:	e44e                	sd	s3,8(sp)
    80002d86:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d88:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d8c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d90:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002d94:	1004f793          	andi	a5,s1,256
    80002d98:	c78d                	beqz	a5,80002dc2 <kerneltrap+0x48>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d9a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002d9e:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002da0:	eb8d                	bnez	a5,80002dd2 <kerneltrap+0x58>
  if((which_dev = devintr()) == 0){
    80002da2:	00000097          	auipc	ra,0x0
    80002da6:	dd2080e7          	jalr	-558(ra) # 80002b74 <devintr>
    80002daa:	cd05                	beqz	a0,80002de2 <kerneltrap+0x68>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002dac:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002db0:	10049073          	csrw	sstatus,s1
}
    80002db4:	70a2                	ld	ra,40(sp)
    80002db6:	7402                	ld	s0,32(sp)
    80002db8:	64e2                	ld	s1,24(sp)
    80002dba:	6942                	ld	s2,16(sp)
    80002dbc:	69a2                	ld	s3,8(sp)
    80002dbe:	6145                	addi	sp,sp,48
    80002dc0:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002dc2:	00005517          	auipc	a0,0x5
    80002dc6:	55e50513          	addi	a0,a0,1374 # 80008320 <digits+0x2e0>
    80002dca:	ffffd097          	auipc	ra,0xffffd
    80002dce:	77a080e7          	jalr	1914(ra) # 80000544 <panic>
    panic("kerneltrap: interrupts enabled");
    80002dd2:	00005517          	auipc	a0,0x5
    80002dd6:	57650513          	addi	a0,a0,1398 # 80008348 <digits+0x308>
    80002dda:	ffffd097          	auipc	ra,0xffffd
    80002dde:	76a080e7          	jalr	1898(ra) # 80000544 <panic>
    printf("scause %p\n", scause);
    80002de2:	85ce                	mv	a1,s3
    80002de4:	00005517          	auipc	a0,0x5
    80002de8:	58450513          	addi	a0,a0,1412 # 80008368 <digits+0x328>
    80002dec:	ffffd097          	auipc	ra,0xffffd
    80002df0:	7a2080e7          	jalr	1954(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002df4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002df8:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002dfc:	00005517          	auipc	a0,0x5
    80002e00:	57c50513          	addi	a0,a0,1404 # 80008378 <digits+0x338>
    80002e04:	ffffd097          	auipc	ra,0xffffd
    80002e08:	78a080e7          	jalr	1930(ra) # 8000058e <printf>
    panic("kerneltrap");
    80002e0c:	00005517          	auipc	a0,0x5
    80002e10:	58450513          	addi	a0,a0,1412 # 80008390 <digits+0x350>
    80002e14:	ffffd097          	auipc	ra,0xffffd
    80002e18:	730080e7          	jalr	1840(ra) # 80000544 <panic>

0000000080002e1c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002e1c:	1101                	addi	sp,sp,-32
    80002e1e:	ec06                	sd	ra,24(sp)
    80002e20:	e822                	sd	s0,16(sp)
    80002e22:	e426                	sd	s1,8(sp)
    80002e24:	1000                	addi	s0,sp,32
    80002e26:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002e28:	fffff097          	auipc	ra,0xfffff
    80002e2c:	b9e080e7          	jalr	-1122(ra) # 800019c6 <myproc>
  switch (n) {
    80002e30:	4795                	li	a5,5
    80002e32:	0497e163          	bltu	a5,s1,80002e74 <argraw+0x58>
    80002e36:	048a                	slli	s1,s1,0x2
    80002e38:	00005717          	auipc	a4,0x5
    80002e3c:	6b070713          	addi	a4,a4,1712 # 800084e8 <digits+0x4a8>
    80002e40:	94ba                	add	s1,s1,a4
    80002e42:	409c                	lw	a5,0(s1)
    80002e44:	97ba                	add	a5,a5,a4
    80002e46:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002e48:	6d3c                	ld	a5,88(a0)
    80002e4a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002e4c:	60e2                	ld	ra,24(sp)
    80002e4e:	6442                	ld	s0,16(sp)
    80002e50:	64a2                	ld	s1,8(sp)
    80002e52:	6105                	addi	sp,sp,32
    80002e54:	8082                	ret
    return p->trapframe->a1;
    80002e56:	6d3c                	ld	a5,88(a0)
    80002e58:	7fa8                	ld	a0,120(a5)
    80002e5a:	bfcd                	j	80002e4c <argraw+0x30>
    return p->trapframe->a2;
    80002e5c:	6d3c                	ld	a5,88(a0)
    80002e5e:	63c8                	ld	a0,128(a5)
    80002e60:	b7f5                	j	80002e4c <argraw+0x30>
    return p->trapframe->a3;
    80002e62:	6d3c                	ld	a5,88(a0)
    80002e64:	67c8                	ld	a0,136(a5)
    80002e66:	b7dd                	j	80002e4c <argraw+0x30>
    return p->trapframe->a4;
    80002e68:	6d3c                	ld	a5,88(a0)
    80002e6a:	6bc8                	ld	a0,144(a5)
    80002e6c:	b7c5                	j	80002e4c <argraw+0x30>
    return p->trapframe->a5;
    80002e6e:	6d3c                	ld	a5,88(a0)
    80002e70:	6fc8                	ld	a0,152(a5)
    80002e72:	bfe9                	j	80002e4c <argraw+0x30>
  panic("argraw");
    80002e74:	00005517          	auipc	a0,0x5
    80002e78:	52c50513          	addi	a0,a0,1324 # 800083a0 <digits+0x360>
    80002e7c:	ffffd097          	auipc	ra,0xffffd
    80002e80:	6c8080e7          	jalr	1736(ra) # 80000544 <panic>

0000000080002e84 <fetchaddr>:
{
    80002e84:	1101                	addi	sp,sp,-32
    80002e86:	ec06                	sd	ra,24(sp)
    80002e88:	e822                	sd	s0,16(sp)
    80002e8a:	e426                	sd	s1,8(sp)
    80002e8c:	e04a                	sd	s2,0(sp)
    80002e8e:	1000                	addi	s0,sp,32
    80002e90:	84aa                	mv	s1,a0
    80002e92:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002e94:	fffff097          	auipc	ra,0xfffff
    80002e98:	b32080e7          	jalr	-1230(ra) # 800019c6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002e9c:	653c                	ld	a5,72(a0)
    80002e9e:	02f4f863          	bgeu	s1,a5,80002ece <fetchaddr+0x4a>
    80002ea2:	00848713          	addi	a4,s1,8
    80002ea6:	02e7e663          	bltu	a5,a4,80002ed2 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002eaa:	46a1                	li	a3,8
    80002eac:	8626                	mv	a2,s1
    80002eae:	85ca                	mv	a1,s2
    80002eb0:	6928                	ld	a0,80(a0)
    80002eb2:	fffff097          	auipc	ra,0xfffff
    80002eb6:	85e080e7          	jalr	-1954(ra) # 80001710 <copyin>
    80002eba:	00a03533          	snez	a0,a0
    80002ebe:	40a00533          	neg	a0,a0
}
    80002ec2:	60e2                	ld	ra,24(sp)
    80002ec4:	6442                	ld	s0,16(sp)
    80002ec6:	64a2                	ld	s1,8(sp)
    80002ec8:	6902                	ld	s2,0(sp)
    80002eca:	6105                	addi	sp,sp,32
    80002ecc:	8082                	ret
    return -1;
    80002ece:	557d                	li	a0,-1
    80002ed0:	bfcd                	j	80002ec2 <fetchaddr+0x3e>
    80002ed2:	557d                	li	a0,-1
    80002ed4:	b7fd                	j	80002ec2 <fetchaddr+0x3e>

0000000080002ed6 <fetchstr>:
{
    80002ed6:	7179                	addi	sp,sp,-48
    80002ed8:	f406                	sd	ra,40(sp)
    80002eda:	f022                	sd	s0,32(sp)
    80002edc:	ec26                	sd	s1,24(sp)
    80002ede:	e84a                	sd	s2,16(sp)
    80002ee0:	e44e                	sd	s3,8(sp)
    80002ee2:	1800                	addi	s0,sp,48
    80002ee4:	892a                	mv	s2,a0
    80002ee6:	84ae                	mv	s1,a1
    80002ee8:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002eea:	fffff097          	auipc	ra,0xfffff
    80002eee:	adc080e7          	jalr	-1316(ra) # 800019c6 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002ef2:	86ce                	mv	a3,s3
    80002ef4:	864a                	mv	a2,s2
    80002ef6:	85a6                	mv	a1,s1
    80002ef8:	6928                	ld	a0,80(a0)
    80002efa:	fffff097          	auipc	ra,0xfffff
    80002efe:	8a2080e7          	jalr	-1886(ra) # 8000179c <copyinstr>
    80002f02:	00054e63          	bltz	a0,80002f1e <fetchstr+0x48>
  return strlen(buf);
    80002f06:	8526                	mv	a0,s1
    80002f08:	ffffe097          	auipc	ra,0xffffe
    80002f0c:	f62080e7          	jalr	-158(ra) # 80000e6a <strlen>
}
    80002f10:	70a2                	ld	ra,40(sp)
    80002f12:	7402                	ld	s0,32(sp)
    80002f14:	64e2                	ld	s1,24(sp)
    80002f16:	6942                	ld	s2,16(sp)
    80002f18:	69a2                	ld	s3,8(sp)
    80002f1a:	6145                	addi	sp,sp,48
    80002f1c:	8082                	ret
    return -1;
    80002f1e:	557d                	li	a0,-1
    80002f20:	bfc5                	j	80002f10 <fetchstr+0x3a>

0000000080002f22 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002f22:	1101                	addi	sp,sp,-32
    80002f24:	ec06                	sd	ra,24(sp)
    80002f26:	e822                	sd	s0,16(sp)
    80002f28:	e426                	sd	s1,8(sp)
    80002f2a:	1000                	addi	s0,sp,32
    80002f2c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002f2e:	00000097          	auipc	ra,0x0
    80002f32:	eee080e7          	jalr	-274(ra) # 80002e1c <argraw>
    80002f36:	c088                	sw	a0,0(s1)
  return 0;
}
    80002f38:	4501                	li	a0,0
    80002f3a:	60e2                	ld	ra,24(sp)
    80002f3c:	6442                	ld	s0,16(sp)
    80002f3e:	64a2                	ld	s1,8(sp)
    80002f40:	6105                	addi	sp,sp,32
    80002f42:	8082                	ret

0000000080002f44 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002f44:	1101                	addi	sp,sp,-32
    80002f46:	ec06                	sd	ra,24(sp)
    80002f48:	e822                	sd	s0,16(sp)
    80002f4a:	e426                	sd	s1,8(sp)
    80002f4c:	1000                	addi	s0,sp,32
    80002f4e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002f50:	00000097          	auipc	ra,0x0
    80002f54:	ecc080e7          	jalr	-308(ra) # 80002e1c <argraw>
    80002f58:	e088                	sd	a0,0(s1)
  return 0;
}
    80002f5a:	4501                	li	a0,0
    80002f5c:	60e2                	ld	ra,24(sp)
    80002f5e:	6442                	ld	s0,16(sp)
    80002f60:	64a2                	ld	s1,8(sp)
    80002f62:	6105                	addi	sp,sp,32
    80002f64:	8082                	ret

0000000080002f66 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002f66:	7179                	addi	sp,sp,-48
    80002f68:	f406                	sd	ra,40(sp)
    80002f6a:	f022                	sd	s0,32(sp)
    80002f6c:	ec26                	sd	s1,24(sp)
    80002f6e:	e84a                	sd	s2,16(sp)
    80002f70:	1800                	addi	s0,sp,48
    80002f72:	84ae                	mv	s1,a1
    80002f74:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002f76:	fd840593          	addi	a1,s0,-40
    80002f7a:	00000097          	auipc	ra,0x0
    80002f7e:	fca080e7          	jalr	-54(ra) # 80002f44 <argaddr>
  return fetchstr(addr, buf, max);
    80002f82:	864a                	mv	a2,s2
    80002f84:	85a6                	mv	a1,s1
    80002f86:	fd843503          	ld	a0,-40(s0)
    80002f8a:	00000097          	auipc	ra,0x0
    80002f8e:	f4c080e7          	jalr	-180(ra) # 80002ed6 <fetchstr>
}
    80002f92:	70a2                	ld	ra,40(sp)
    80002f94:	7402                	ld	s0,32(sp)
    80002f96:	64e2                	ld	s1,24(sp)
    80002f98:	6942                	ld	s2,16(sp)
    80002f9a:	6145                	addi	sp,sp,48
    80002f9c:	8082                	ret

0000000080002f9e <syscall>:
    [SYS_setpriority] 1,
};

void
syscall(void)
{
    80002f9e:	7179                	addi	sp,sp,-48
    80002fa0:	f406                	sd	ra,40(sp)
    80002fa2:	f022                	sd	s0,32(sp)
    80002fa4:	ec26                	sd	s1,24(sp)
    80002fa6:	e84a                	sd	s2,16(sp)
    80002fa8:	e44e                	sd	s3,8(sp)
    80002faa:	e052                	sd	s4,0(sp)
    80002fac:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002fae:	fffff097          	auipc	ra,0xfffff
    80002fb2:	a18080e7          	jalr	-1512(ra) # 800019c6 <myproc>
    80002fb6:	892a                	mv	s2,a0

  num = p->trapframe->a7;
    80002fb8:	6d24                	ld	s1,88(a0)
    80002fba:	74dc                	ld	a5,168(s1)
    80002fbc:	0007899b          	sext.w	s3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) 
    80002fc0:	37fd                	addiw	a5,a5,-1
    80002fc2:	4769                	li	a4,26
    80002fc4:	0af76163          	bltu	a4,a5,80003066 <syscall+0xc8>
    80002fc8:	00399713          	slli	a4,s3,0x3
    80002fcc:	00005797          	auipc	a5,0x5
    80002fd0:	53478793          	addi	a5,a5,1332 # 80008500 <syscalls>
    80002fd4:	97ba                	add	a5,a5,a4
    80002fd6:	639c                	ld	a5,0(a5)
    80002fd8:	c7d9                	beqz	a5,80003066 <syscall+0xc8>
  {
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002fda:	9782                	jalr	a5
    80002fdc:	f8a8                	sd	a0,112(s1)
    if ((p->mask >> num) & 1)
    80002fde:	16892483          	lw	s1,360(s2)
    80002fe2:	4134d4bb          	sraw	s1,s1,s3
    80002fe6:	8885                	andi	s1,s1,1
    80002fe8:	c0c5                	beqz	s1,80003088 <syscall+0xea>
    {
      /* Modified for A4: Added entire section for trace, prints output for each syscall traced */
  	  printf("%d: syscall %s ( %d ",p->pid, syscallnames[num], p->trapframe->a0);
    80002fea:	05893703          	ld	a4,88(s2)
    80002fee:	00399693          	slli	a3,s3,0x3
    80002ff2:	00006797          	auipc	a5,0x6
    80002ff6:	9e678793          	addi	a5,a5,-1562 # 800089d8 <syscallnames>
    80002ffa:	97b6                	add	a5,a5,a3
    80002ffc:	7b34                	ld	a3,112(a4)
    80002ffe:	6390                	ld	a2,0(a5)
    80003000:	03092583          	lw	a1,48(s2)
    80003004:	00005517          	auipc	a0,0x5
    80003008:	3a450513          	addi	a0,a0,932 # 800083a8 <digits+0x368>
    8000300c:	ffffd097          	auipc	ra,0xffffd
    80003010:	582080e7          	jalr	1410(ra) # 8000058e <printf>
      for (int i = 1; i < syscallnum[num]; i++) /* Modified for A4: 'num' tracks number of registers used by syscall and prints its register values  */
    80003014:	098a                	slli	s3,s3,0x2
    80003016:	00005797          	auipc	a5,0x5
    8000301a:	4ea78793          	addi	a5,a5,1258 # 80008500 <syscalls>
    8000301e:	99be                	add	s3,s3,a5
    80003020:	0e09a983          	lw	s3,224(s3)
    80003024:	4785                	li	a5,1
    80003026:	0337d463          	bge	a5,s3,8000304e <syscall+0xb0>
        printf("%d ", argraw(i));
    8000302a:	00005a17          	auipc	s4,0x5
    8000302e:	396a0a13          	addi	s4,s4,918 # 800083c0 <digits+0x380>
    80003032:	8526                	mv	a0,s1
    80003034:	00000097          	auipc	ra,0x0
    80003038:	de8080e7          	jalr	-536(ra) # 80002e1c <argraw>
    8000303c:	85aa                	mv	a1,a0
    8000303e:	8552                	mv	a0,s4
    80003040:	ffffd097          	auipc	ra,0xffffd
    80003044:	54e080e7          	jalr	1358(ra) # 8000058e <printf>
      for (int i = 1; i < syscallnum[num]; i++) /* Modified for A4: 'num' tracks number of registers used by syscall and prints its register values  */
    80003048:	2485                	addiw	s1,s1,1
    8000304a:	ff3494e3          	bne	s1,s3,80003032 <syscall+0x94>
      printf(") -> %d\n", p->trapframe->a0);
    8000304e:	05893783          	ld	a5,88(s2)
    80003052:	7bac                	ld	a1,112(a5)
    80003054:	00005517          	auipc	a0,0x5
    80003058:	37450513          	addi	a0,a0,884 # 800083c8 <digits+0x388>
    8000305c:	ffffd097          	auipc	ra,0xffffd
    80003060:	532080e7          	jalr	1330(ra) # 8000058e <printf>
    80003064:	a015                	j	80003088 <syscall+0xea>
    }	
  } 
  else 
  {
    printf("%d %s: unknown sys call %d\n",
    80003066:	86ce                	mv	a3,s3
    80003068:	15890613          	addi	a2,s2,344
    8000306c:	03092583          	lw	a1,48(s2)
    80003070:	00005517          	auipc	a0,0x5
    80003074:	36850513          	addi	a0,a0,872 # 800083d8 <digits+0x398>
    80003078:	ffffd097          	auipc	ra,0xffffd
    8000307c:	516080e7          	jalr	1302(ra) # 8000058e <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003080:	05893783          	ld	a5,88(s2)
    80003084:	577d                	li	a4,-1
    80003086:	fbb8                	sd	a4,112(a5)
  
  // if (p->mask >> num)
  // {
  // 	printf("%d: syscall %s -> %d\n",p->pid, syscallnames[num], p->trapframe->a0);
  // }	
}
    80003088:	70a2                	ld	ra,40(sp)
    8000308a:	7402                	ld	s0,32(sp)
    8000308c:	64e2                	ld	s1,24(sp)
    8000308e:	6942                	ld	s2,16(sp)
    80003090:	69a2                	ld	s3,8(sp)
    80003092:	6a02                	ld	s4,0(sp)
    80003094:	6145                	addi	sp,sp,48
    80003096:	8082                	ret

0000000080003098 <sys_trace>:
#include "proc.h"


uint64
sys_trace(void)
{
    80003098:	1101                	addi	sp,sp,-32
    8000309a:	ec06                	sd	ra,24(sp)
    8000309c:	e822                	sd	s0,16(sp)
    8000309e:	1000                	addi	s0,sp,32
  int mask;
	if(argint(0, &mask) < 0)
    800030a0:	fec40593          	addi	a1,s0,-20
    800030a4:	4501                	li	a0,0
    800030a6:	00000097          	auipc	ra,0x0
    800030aa:	e7c080e7          	jalr	-388(ra) # 80002f22 <argint>
	{
		return -1;
    800030ae:	57fd                	li	a5,-1
	if(argint(0, &mask) < 0)
    800030b0:	00054b63          	bltz	a0,800030c6 <sys_trace+0x2e>
	}
  myproc()->mask = mask;
    800030b4:	fffff097          	auipc	ra,0xfffff
    800030b8:	912080e7          	jalr	-1774(ra) # 800019c6 <myproc>
    800030bc:	fec42783          	lw	a5,-20(s0)
    800030c0:	16f52423          	sw	a5,360(a0)
	return 0;
    800030c4:	4781                	li	a5,0
}	/* Modified for A4: Added trace */
    800030c6:	853e                	mv	a0,a5
    800030c8:	60e2                	ld	ra,24(sp)
    800030ca:	6442                	ld	s0,16(sp)
    800030cc:	6105                	addi	sp,sp,32
    800030ce:	8082                	ret

00000000800030d0 <sys_sigalarm>:

/* Modified for A4: Added trace */
uint64 
sys_sigalarm(void)
{
    800030d0:	1101                	addi	sp,sp,-32
    800030d2:	ec06                	sd	ra,24(sp)
    800030d4:	e822                	sd	s0,16(sp)
    800030d6:	1000                	addi	s0,sp,32
  uint64 handleraddr;
  int ticks;
  if(argint(0, &ticks) < 0)
    800030d8:	fe440593          	addi	a1,s0,-28
    800030dc:	4501                	li	a0,0
    800030de:	00000097          	auipc	ra,0x0
    800030e2:	e44080e7          	jalr	-444(ra) # 80002f22 <argint>
    return -1;
    800030e6:	57fd                	li	a5,-1
  if(argint(0, &ticks) < 0)
    800030e8:	04054463          	bltz	a0,80003130 <sys_sigalarm+0x60>
  if(argaddr(1, &handleraddr) < 0)
    800030ec:	fe840593          	addi	a1,s0,-24
    800030f0:	4505                	li	a0,1
    800030f2:	00000097          	auipc	ra,0x0
    800030f6:	e52080e7          	jalr	-430(ra) # 80002f44 <argaddr>
    return -1;
    800030fa:	57fd                	li	a5,-1
  if(argaddr(1, &handleraddr) < 0)
    800030fc:	02054a63          	bltz	a0,80003130 <sys_sigalarm+0x60>

  myproc()->ticks = ticks;
    80003100:	fffff097          	auipc	ra,0xfffff
    80003104:	8c6080e7          	jalr	-1850(ra) # 800019c6 <myproc>
    80003108:	fe442783          	lw	a5,-28(s0)
    8000310c:	18f52423          	sw	a5,392(a0)
  myproc()->handler = handleraddr;
    80003110:	fffff097          	auipc	ra,0xfffff
    80003114:	8b6080e7          	jalr	-1866(ra) # 800019c6 <myproc>
    80003118:	fe843783          	ld	a5,-24(s0)
    8000311c:	18f53023          	sd	a5,384(a0)
  myproc()->alarm_on = 1;
    80003120:	fffff097          	auipc	ra,0xfffff
    80003124:	8a6080e7          	jalr	-1882(ra) # 800019c6 <myproc>
    80003128:	4785                	li	a5,1
    8000312a:	18f52c23          	sw	a5,408(a0)
  //myproc()->a1 = myproc()->trapframe->a0;
  //myproc()->a2 = myproc()->trapframe->a1;

  return 0;
    8000312e:	4781                	li	a5,0
}
    80003130:	853e                	mv	a0,a5
    80003132:	60e2                	ld	ra,24(sp)
    80003134:	6442                	ld	s0,16(sp)
    80003136:	6105                	addi	sp,sp,32
    80003138:	8082                	ret

000000008000313a <sys_sigreturn>:

/* Modified for A4: Added trace */
uint64 
sys_sigreturn(void)
{
    8000313a:	1101                	addi	sp,sp,-32
    8000313c:	ec06                	sd	ra,24(sp)
    8000313e:	e822                	sd	s0,16(sp)
    80003140:	e426                	sd	s1,8(sp)
    80003142:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80003144:	fffff097          	auipc	ra,0xfffff
    80003148:	882080e7          	jalr	-1918(ra) # 800019c6 <myproc>
    8000314c:	84aa                	mv	s1,a0
  memmove(p->trapframe, p->alarm_tf, PGSIZE);
    8000314e:	6605                	lui	a2,0x1
    80003150:	19053583          	ld	a1,400(a0)
    80003154:	6d28                	ld	a0,88(a0)
    80003156:	ffffe097          	auipc	ra,0xffffe
    8000315a:	bf0080e7          	jalr	-1040(ra) # 80000d46 <memmove>
  //myproc()->trapframe->a0 = myproc()->a1;
  //myproc()->trapframe->a1 = myproc()->a2;
  kfree(p->alarm_tf);
    8000315e:	1904b503          	ld	a0,400(s1)
    80003162:	ffffe097          	auipc	ra,0xffffe
    80003166:	89c080e7          	jalr	-1892(ra) # 800009fe <kfree>
  p->handlerpermission = 1;
    8000316a:	4785                	li	a5,1
    8000316c:	18f4ae23          	sw	a5,412(s1)
  return myproc()->trapframe->a0;
    80003170:	fffff097          	auipc	ra,0xfffff
    80003174:	856080e7          	jalr	-1962(ra) # 800019c6 <myproc>
    80003178:	6d3c                	ld	a5,88(a0)
}
    8000317a:	7ba8                	ld	a0,112(a5)
    8000317c:	60e2                	ld	ra,24(sp)
    8000317e:	6442                	ld	s0,16(sp)
    80003180:	64a2                	ld	s1,8(sp)
    80003182:	6105                	addi	sp,sp,32
    80003184:	8082                	ret

0000000080003186 <sys_settickets>:

uint64 
sys_settickets(void)
{
    80003186:	7179                	addi	sp,sp,-48
    80003188:	f406                	sd	ra,40(sp)
    8000318a:	f022                	sd	s0,32(sp)
    8000318c:	ec26                	sd	s1,24(sp)
    8000318e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80003190:	fffff097          	auipc	ra,0xfffff
    80003194:	836080e7          	jalr	-1994(ra) # 800019c6 <myproc>
    80003198:	84aa                	mv	s1,a0
  int tickets;
  if(argint(0, &tickets) < 0)
    8000319a:	fdc40593          	addi	a1,s0,-36
    8000319e:	4501                	li	a0,0
    800031a0:	00000097          	auipc	ra,0x0
    800031a4:	d82080e7          	jalr	-638(ra) # 80002f22 <argint>
    800031a8:	00054c63          	bltz	a0,800031c0 <sys_settickets+0x3a>
    return -1;
  p->tickets = tickets;
    800031ac:	fdc42783          	lw	a5,-36(s0)
    800031b0:	1af4a023          	sw	a5,416(s1)
  return 0; 
    800031b4:	4501                	li	a0,0
}
    800031b6:	70a2                	ld	ra,40(sp)
    800031b8:	7402                	ld	s0,32(sp)
    800031ba:	64e2                	ld	s1,24(sp)
    800031bc:	6145                	addi	sp,sp,48
    800031be:	8082                	ret
    return -1;
    800031c0:	557d                	li	a0,-1
    800031c2:	bfd5                	j	800031b6 <sys_settickets+0x30>

00000000800031c4 <sys_setpriority>:

uint64
sys_setpriority()
{
    800031c4:	1101                	addi	sp,sp,-32
    800031c6:	ec06                	sd	ra,24(sp)
    800031c8:	e822                	sd	s0,16(sp)
    800031ca:	1000                	addi	s0,sp,32
  int pid, priority;
  int arg_num[2] = {0, 1};

  if(argint(arg_num[0], &priority) < 0)
    800031cc:	fe840593          	addi	a1,s0,-24
    800031d0:	4501                	li	a0,0
    800031d2:	00000097          	auipc	ra,0x0
    800031d6:	d50080e7          	jalr	-688(ra) # 80002f22 <argint>
  {
    return -1;
    800031da:	57fd                	li	a5,-1
  if(argint(arg_num[0], &priority) < 0)
    800031dc:	02054563          	bltz	a0,80003206 <sys_setpriority+0x42>
  }
  if(argint(arg_num[1], &pid) < 0)
    800031e0:	fec40593          	addi	a1,s0,-20
    800031e4:	4505                	li	a0,1
    800031e6:	00000097          	auipc	ra,0x0
    800031ea:	d3c080e7          	jalr	-708(ra) # 80002f22 <argint>
  {
    return -1;
    800031ee:	57fd                	li	a5,-1
  if(argint(arg_num[1], &pid) < 0)
    800031f0:	00054b63          	bltz	a0,80003206 <sys_setpriority+0x42>
  }
   
  return setpriority(priority, pid);
    800031f4:	fec42583          	lw	a1,-20(s0)
    800031f8:	fe842503          	lw	a0,-24(s0)
    800031fc:	fffff097          	auipc	ra,0xfffff
    80003200:	760080e7          	jalr	1888(ra) # 8000295c <setpriority>
    80003204:	87aa                	mv	a5,a0
}
    80003206:	853e                	mv	a0,a5
    80003208:	60e2                	ld	ra,24(sp)
    8000320a:	6442                	ld	s0,16(sp)
    8000320c:	6105                	addi	sp,sp,32
    8000320e:	8082                	ret

0000000080003210 <sys_exit>:


uint64
sys_exit(void)
{
    80003210:	1101                	addi	sp,sp,-32
    80003212:	ec06                	sd	ra,24(sp)
    80003214:	e822                	sd	s0,16(sp)
    80003216:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80003218:	fec40593          	addi	a1,s0,-20
    8000321c:	4501                	li	a0,0
    8000321e:	00000097          	auipc	ra,0x0
    80003222:	d04080e7          	jalr	-764(ra) # 80002f22 <argint>
  exit(n);
    80003226:	fec42503          	lw	a0,-20(s0)
    8000322a:	fffff097          	auipc	ra,0xfffff
    8000322e:	322080e7          	jalr	802(ra) # 8000254c <exit>
  return 0;  // not reached
}
    80003232:	4501                	li	a0,0
    80003234:	60e2                	ld	ra,24(sp)
    80003236:	6442                	ld	s0,16(sp)
    80003238:	6105                	addi	sp,sp,32
    8000323a:	8082                	ret

000000008000323c <sys_getpid>:

uint64
sys_getpid(void)
{
    8000323c:	1141                	addi	sp,sp,-16
    8000323e:	e406                	sd	ra,8(sp)
    80003240:	e022                	sd	s0,0(sp)
    80003242:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003244:	ffffe097          	auipc	ra,0xffffe
    80003248:	782080e7          	jalr	1922(ra) # 800019c6 <myproc>
}
    8000324c:	5908                	lw	a0,48(a0)
    8000324e:	60a2                	ld	ra,8(sp)
    80003250:	6402                	ld	s0,0(sp)
    80003252:	0141                	addi	sp,sp,16
    80003254:	8082                	ret

0000000080003256 <sys_fork>:

uint64
sys_fork(void)
{
    80003256:	1141                	addi	sp,sp,-16
    80003258:	e406                	sd	ra,8(sp)
    8000325a:	e022                	sd	s0,0(sp)
    8000325c:	0800                	addi	s0,sp,16
  return fork();
    8000325e:	fffff097          	auipc	ra,0xfffff
    80003262:	b94080e7          	jalr	-1132(ra) # 80001df2 <fork>
}
    80003266:	60a2                	ld	ra,8(sp)
    80003268:	6402                	ld	s0,0(sp)
    8000326a:	0141                	addi	sp,sp,16
    8000326c:	8082                	ret

000000008000326e <sys_wait>:

uint64
sys_wait(void)
{
    8000326e:	1101                	addi	sp,sp,-32
    80003270:	ec06                	sd	ra,24(sp)
    80003272:	e822                	sd	s0,16(sp)
    80003274:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80003276:	fe840593          	addi	a1,s0,-24
    8000327a:	4501                	li	a0,0
    8000327c:	00000097          	auipc	ra,0x0
    80003280:	cc8080e7          	jalr	-824(ra) # 80002f44 <argaddr>
  return wait(p);
    80003284:	fe843503          	ld	a0,-24(s0)
    80003288:	fffff097          	auipc	ra,0xfffff
    8000328c:	476080e7          	jalr	1142(ra) # 800026fe <wait>
}
    80003290:	60e2                	ld	ra,24(sp)
    80003292:	6442                	ld	s0,16(sp)
    80003294:	6105                	addi	sp,sp,32
    80003296:	8082                	ret

0000000080003298 <sys_waitx>:

uint64
sys_waitx(void)
{
    80003298:	7139                	addi	sp,sp,-64
    8000329a:	fc06                	sd	ra,56(sp)
    8000329c:	f822                	sd	s0,48(sp)
    8000329e:	f426                	sd	s1,40(sp)
    800032a0:	f04a                	sd	s2,32(sp)
    800032a2:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    800032a4:	fd840593          	addi	a1,s0,-40
    800032a8:	4501                	li	a0,0
    800032aa:	00000097          	auipc	ra,0x0
    800032ae:	c9a080e7          	jalr	-870(ra) # 80002f44 <argaddr>
  argaddr(1, &addr1); // user virtual memory
    800032b2:	fd040593          	addi	a1,s0,-48
    800032b6:	4505                	li	a0,1
    800032b8:	00000097          	auipc	ra,0x0
    800032bc:	c8c080e7          	jalr	-884(ra) # 80002f44 <argaddr>
  argaddr(2, &addr2);
    800032c0:	fc840593          	addi	a1,s0,-56
    800032c4:	4509                	li	a0,2
    800032c6:	00000097          	auipc	ra,0x0
    800032ca:	c7e080e7          	jalr	-898(ra) # 80002f44 <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    800032ce:	fc040613          	addi	a2,s0,-64
    800032d2:	fc440593          	addi	a1,s0,-60
    800032d6:	fd843503          	ld	a0,-40(s0)
    800032da:	fffff097          	auipc	ra,0xfffff
    800032de:	03c080e7          	jalr	60(ra) # 80002316 <waitx>
    800032e2:	892a                	mv	s2,a0
  struct proc* p = myproc();
    800032e4:	ffffe097          	auipc	ra,0xffffe
    800032e8:	6e2080e7          	jalr	1762(ra) # 800019c6 <myproc>
    800032ec:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    800032ee:	4691                	li	a3,4
    800032f0:	fc440613          	addi	a2,s0,-60
    800032f4:	fd043583          	ld	a1,-48(s0)
    800032f8:	6928                	ld	a0,80(a0)
    800032fa:	ffffe097          	auipc	ra,0xffffe
    800032fe:	38a080e7          	jalr	906(ra) # 80001684 <copyout>
    return -1;
    80003302:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    80003304:	00054f63          	bltz	a0,80003322 <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2,(char*)&rtime, sizeof(int)) < 0)
    80003308:	4691                	li	a3,4
    8000330a:	fc040613          	addi	a2,s0,-64
    8000330e:	fc843583          	ld	a1,-56(s0)
    80003312:	68a8                	ld	a0,80(s1)
    80003314:	ffffe097          	auipc	ra,0xffffe
    80003318:	370080e7          	jalr	880(ra) # 80001684 <copyout>
    8000331c:	00054a63          	bltz	a0,80003330 <sys_waitx+0x98>
    return -1;
  return ret;
    80003320:	87ca                	mv	a5,s2
}
    80003322:	853e                	mv	a0,a5
    80003324:	70e2                	ld	ra,56(sp)
    80003326:	7442                	ld	s0,48(sp)
    80003328:	74a2                	ld	s1,40(sp)
    8000332a:	7902                	ld	s2,32(sp)
    8000332c:	6121                	addi	sp,sp,64
    8000332e:	8082                	ret
    return -1;
    80003330:	57fd                	li	a5,-1
    80003332:	bfc5                	j	80003322 <sys_waitx+0x8a>

0000000080003334 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003334:	7179                	addi	sp,sp,-48
    80003336:	f406                	sd	ra,40(sp)
    80003338:	f022                	sd	s0,32(sp)
    8000333a:	ec26                	sd	s1,24(sp)
    8000333c:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    8000333e:	fdc40593          	addi	a1,s0,-36
    80003342:	4501                	li	a0,0
    80003344:	00000097          	auipc	ra,0x0
    80003348:	bde080e7          	jalr	-1058(ra) # 80002f22 <argint>
  addr = myproc()->sz;
    8000334c:	ffffe097          	auipc	ra,0xffffe
    80003350:	67a080e7          	jalr	1658(ra) # 800019c6 <myproc>
    80003354:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80003356:	fdc42503          	lw	a0,-36(s0)
    8000335a:	fffff097          	auipc	ra,0xfffff
    8000335e:	a3c080e7          	jalr	-1476(ra) # 80001d96 <growproc>
    80003362:	00054863          	bltz	a0,80003372 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80003366:	8526                	mv	a0,s1
    80003368:	70a2                	ld	ra,40(sp)
    8000336a:	7402                	ld	s0,32(sp)
    8000336c:	64e2                	ld	s1,24(sp)
    8000336e:	6145                	addi	sp,sp,48
    80003370:	8082                	ret
    return -1;
    80003372:	54fd                	li	s1,-1
    80003374:	bfcd                	j	80003366 <sys_sbrk+0x32>

0000000080003376 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003376:	7139                	addi	sp,sp,-64
    80003378:	fc06                	sd	ra,56(sp)
    8000337a:	f822                	sd	s0,48(sp)
    8000337c:	f426                	sd	s1,40(sp)
    8000337e:	f04a                	sd	s2,32(sp)
    80003380:	ec4e                	sd	s3,24(sp)
    80003382:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80003384:	fcc40593          	addi	a1,s0,-52
    80003388:	4501                	li	a0,0
    8000338a:	00000097          	auipc	ra,0x0
    8000338e:	b98080e7          	jalr	-1128(ra) # 80002f22 <argint>
  acquire(&tickslock);
    80003392:	00015517          	auipc	a0,0x15
    80003396:	62e50513          	addi	a0,a0,1582 # 800189c0 <tickslock>
    8000339a:	ffffe097          	auipc	ra,0xffffe
    8000339e:	850080e7          	jalr	-1968(ra) # 80000bea <acquire>
  ticks0 = ticks;
    800033a2:	00005917          	auipc	s2,0x5
    800033a6:	74e92903          	lw	s2,1870(s2) # 80008af0 <ticks>
  while(ticks - ticks0 < n){
    800033aa:	fcc42783          	lw	a5,-52(s0)
    800033ae:	cf9d                	beqz	a5,800033ec <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800033b0:	00015997          	auipc	s3,0x15
    800033b4:	61098993          	addi	s3,s3,1552 # 800189c0 <tickslock>
    800033b8:	00005497          	auipc	s1,0x5
    800033bc:	73848493          	addi	s1,s1,1848 # 80008af0 <ticks>
    if(killed(myproc())){
    800033c0:	ffffe097          	auipc	ra,0xffffe
    800033c4:	606080e7          	jalr	1542(ra) # 800019c6 <myproc>
    800033c8:	fffff097          	auipc	ra,0xfffff
    800033cc:	304080e7          	jalr	772(ra) # 800026cc <killed>
    800033d0:	ed15                	bnez	a0,8000340c <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    800033d2:	85ce                	mv	a1,s3
    800033d4:	8526                	mv	a0,s1
    800033d6:	fffff097          	auipc	ra,0xfffff
    800033da:	ed0080e7          	jalr	-304(ra) # 800022a6 <sleep>
  while(ticks - ticks0 < n){
    800033de:	409c                	lw	a5,0(s1)
    800033e0:	412787bb          	subw	a5,a5,s2
    800033e4:	fcc42703          	lw	a4,-52(s0)
    800033e8:	fce7ece3          	bltu	a5,a4,800033c0 <sys_sleep+0x4a>
  }
  release(&tickslock);
    800033ec:	00015517          	auipc	a0,0x15
    800033f0:	5d450513          	addi	a0,a0,1492 # 800189c0 <tickslock>
    800033f4:	ffffe097          	auipc	ra,0xffffe
    800033f8:	8aa080e7          	jalr	-1878(ra) # 80000c9e <release>
  return 0;
    800033fc:	4501                	li	a0,0
}
    800033fe:	70e2                	ld	ra,56(sp)
    80003400:	7442                	ld	s0,48(sp)
    80003402:	74a2                	ld	s1,40(sp)
    80003404:	7902                	ld	s2,32(sp)
    80003406:	69e2                	ld	s3,24(sp)
    80003408:	6121                	addi	sp,sp,64
    8000340a:	8082                	ret
      release(&tickslock);
    8000340c:	00015517          	auipc	a0,0x15
    80003410:	5b450513          	addi	a0,a0,1460 # 800189c0 <tickslock>
    80003414:	ffffe097          	auipc	ra,0xffffe
    80003418:	88a080e7          	jalr	-1910(ra) # 80000c9e <release>
      return -1;
    8000341c:	557d                	li	a0,-1
    8000341e:	b7c5                	j	800033fe <sys_sleep+0x88>

0000000080003420 <sys_kill>:

uint64
sys_kill(void)
{
    80003420:	1101                	addi	sp,sp,-32
    80003422:	ec06                	sd	ra,24(sp)
    80003424:	e822                	sd	s0,16(sp)
    80003426:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003428:	fec40593          	addi	a1,s0,-20
    8000342c:	4501                	li	a0,0
    8000342e:	00000097          	auipc	ra,0x0
    80003432:	af4080e7          	jalr	-1292(ra) # 80002f22 <argint>
  return kill(pid);
    80003436:	fec42503          	lw	a0,-20(s0)
    8000343a:	fffff097          	auipc	ra,0xfffff
    8000343e:	1f4080e7          	jalr	500(ra) # 8000262e <kill>
}
    80003442:	60e2                	ld	ra,24(sp)
    80003444:	6442                	ld	s0,16(sp)
    80003446:	6105                	addi	sp,sp,32
    80003448:	8082                	ret

000000008000344a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000344a:	1101                	addi	sp,sp,-32
    8000344c:	ec06                	sd	ra,24(sp)
    8000344e:	e822                	sd	s0,16(sp)
    80003450:	e426                	sd	s1,8(sp)
    80003452:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003454:	00015517          	auipc	a0,0x15
    80003458:	56c50513          	addi	a0,a0,1388 # 800189c0 <tickslock>
    8000345c:	ffffd097          	auipc	ra,0xffffd
    80003460:	78e080e7          	jalr	1934(ra) # 80000bea <acquire>
  xticks = ticks;
    80003464:	00005497          	auipc	s1,0x5
    80003468:	68c4a483          	lw	s1,1676(s1) # 80008af0 <ticks>
  release(&tickslock);
    8000346c:	00015517          	auipc	a0,0x15
    80003470:	55450513          	addi	a0,a0,1364 # 800189c0 <tickslock>
    80003474:	ffffe097          	auipc	ra,0xffffe
    80003478:	82a080e7          	jalr	-2006(ra) # 80000c9e <release>
  return xticks;
}
    8000347c:	02049513          	slli	a0,s1,0x20
    80003480:	9101                	srli	a0,a0,0x20
    80003482:	60e2                	ld	ra,24(sp)
    80003484:	6442                	ld	s0,16(sp)
    80003486:	64a2                	ld	s1,8(sp)
    80003488:	6105                	addi	sp,sp,32
    8000348a:	8082                	ret

000000008000348c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000348c:	7179                	addi	sp,sp,-48
    8000348e:	f406                	sd	ra,40(sp)
    80003490:	f022                	sd	s0,32(sp)
    80003492:	ec26                	sd	s1,24(sp)
    80003494:	e84a                	sd	s2,16(sp)
    80003496:	e44e                	sd	s3,8(sp)
    80003498:	e052                	sd	s4,0(sp)
    8000349a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000349c:	00005597          	auipc	a1,0x5
    800034a0:	1b458593          	addi	a1,a1,436 # 80008650 <syscallnum+0x70>
    800034a4:	00015517          	auipc	a0,0x15
    800034a8:	53450513          	addi	a0,a0,1332 # 800189d8 <bcache>
    800034ac:	ffffd097          	auipc	ra,0xffffd
    800034b0:	6ae080e7          	jalr	1710(ra) # 80000b5a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800034b4:	0001d797          	auipc	a5,0x1d
    800034b8:	52478793          	addi	a5,a5,1316 # 800209d8 <bcache+0x8000>
    800034bc:	0001d717          	auipc	a4,0x1d
    800034c0:	78470713          	addi	a4,a4,1924 # 80020c40 <bcache+0x8268>
    800034c4:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800034c8:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800034cc:	00015497          	auipc	s1,0x15
    800034d0:	52448493          	addi	s1,s1,1316 # 800189f0 <bcache+0x18>
    b->next = bcache.head.next;
    800034d4:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800034d6:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800034d8:	00005a17          	auipc	s4,0x5
    800034dc:	180a0a13          	addi	s4,s4,384 # 80008658 <syscallnum+0x78>
    b->next = bcache.head.next;
    800034e0:	2b893783          	ld	a5,696(s2)
    800034e4:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800034e6:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800034ea:	85d2                	mv	a1,s4
    800034ec:	01048513          	addi	a0,s1,16
    800034f0:	00001097          	auipc	ra,0x1
    800034f4:	4c4080e7          	jalr	1220(ra) # 800049b4 <initsleeplock>
    bcache.head.next->prev = b;
    800034f8:	2b893783          	ld	a5,696(s2)
    800034fc:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800034fe:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003502:	45848493          	addi	s1,s1,1112
    80003506:	fd349de3          	bne	s1,s3,800034e0 <binit+0x54>
  }
}
    8000350a:	70a2                	ld	ra,40(sp)
    8000350c:	7402                	ld	s0,32(sp)
    8000350e:	64e2                	ld	s1,24(sp)
    80003510:	6942                	ld	s2,16(sp)
    80003512:	69a2                	ld	s3,8(sp)
    80003514:	6a02                	ld	s4,0(sp)
    80003516:	6145                	addi	sp,sp,48
    80003518:	8082                	ret

000000008000351a <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000351a:	7179                	addi	sp,sp,-48
    8000351c:	f406                	sd	ra,40(sp)
    8000351e:	f022                	sd	s0,32(sp)
    80003520:	ec26                	sd	s1,24(sp)
    80003522:	e84a                	sd	s2,16(sp)
    80003524:	e44e                	sd	s3,8(sp)
    80003526:	1800                	addi	s0,sp,48
    80003528:	89aa                	mv	s3,a0
    8000352a:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    8000352c:	00015517          	auipc	a0,0x15
    80003530:	4ac50513          	addi	a0,a0,1196 # 800189d8 <bcache>
    80003534:	ffffd097          	auipc	ra,0xffffd
    80003538:	6b6080e7          	jalr	1718(ra) # 80000bea <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000353c:	0001d497          	auipc	s1,0x1d
    80003540:	7544b483          	ld	s1,1876(s1) # 80020c90 <bcache+0x82b8>
    80003544:	0001d797          	auipc	a5,0x1d
    80003548:	6fc78793          	addi	a5,a5,1788 # 80020c40 <bcache+0x8268>
    8000354c:	02f48f63          	beq	s1,a5,8000358a <bread+0x70>
    80003550:	873e                	mv	a4,a5
    80003552:	a021                	j	8000355a <bread+0x40>
    80003554:	68a4                	ld	s1,80(s1)
    80003556:	02e48a63          	beq	s1,a4,8000358a <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000355a:	449c                	lw	a5,8(s1)
    8000355c:	ff379ce3          	bne	a5,s3,80003554 <bread+0x3a>
    80003560:	44dc                	lw	a5,12(s1)
    80003562:	ff2799e3          	bne	a5,s2,80003554 <bread+0x3a>
      b->refcnt++;
    80003566:	40bc                	lw	a5,64(s1)
    80003568:	2785                	addiw	a5,a5,1
    8000356a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000356c:	00015517          	auipc	a0,0x15
    80003570:	46c50513          	addi	a0,a0,1132 # 800189d8 <bcache>
    80003574:	ffffd097          	auipc	ra,0xffffd
    80003578:	72a080e7          	jalr	1834(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    8000357c:	01048513          	addi	a0,s1,16
    80003580:	00001097          	auipc	ra,0x1
    80003584:	46e080e7          	jalr	1134(ra) # 800049ee <acquiresleep>
      return b;
    80003588:	a8b9                	j	800035e6 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000358a:	0001d497          	auipc	s1,0x1d
    8000358e:	6fe4b483          	ld	s1,1790(s1) # 80020c88 <bcache+0x82b0>
    80003592:	0001d797          	auipc	a5,0x1d
    80003596:	6ae78793          	addi	a5,a5,1710 # 80020c40 <bcache+0x8268>
    8000359a:	00f48863          	beq	s1,a5,800035aa <bread+0x90>
    8000359e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800035a0:	40bc                	lw	a5,64(s1)
    800035a2:	cf81                	beqz	a5,800035ba <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800035a4:	64a4                	ld	s1,72(s1)
    800035a6:	fee49de3          	bne	s1,a4,800035a0 <bread+0x86>
  panic("bget: no buffers");
    800035aa:	00005517          	auipc	a0,0x5
    800035ae:	0b650513          	addi	a0,a0,182 # 80008660 <syscallnum+0x80>
    800035b2:	ffffd097          	auipc	ra,0xffffd
    800035b6:	f92080e7          	jalr	-110(ra) # 80000544 <panic>
      b->dev = dev;
    800035ba:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    800035be:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    800035c2:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800035c6:	4785                	li	a5,1
    800035c8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800035ca:	00015517          	auipc	a0,0x15
    800035ce:	40e50513          	addi	a0,a0,1038 # 800189d8 <bcache>
    800035d2:	ffffd097          	auipc	ra,0xffffd
    800035d6:	6cc080e7          	jalr	1740(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    800035da:	01048513          	addi	a0,s1,16
    800035de:	00001097          	auipc	ra,0x1
    800035e2:	410080e7          	jalr	1040(ra) # 800049ee <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800035e6:	409c                	lw	a5,0(s1)
    800035e8:	cb89                	beqz	a5,800035fa <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800035ea:	8526                	mv	a0,s1
    800035ec:	70a2                	ld	ra,40(sp)
    800035ee:	7402                	ld	s0,32(sp)
    800035f0:	64e2                	ld	s1,24(sp)
    800035f2:	6942                	ld	s2,16(sp)
    800035f4:	69a2                	ld	s3,8(sp)
    800035f6:	6145                	addi	sp,sp,48
    800035f8:	8082                	ret
    virtio_disk_rw(b, 0);
    800035fa:	4581                	li	a1,0
    800035fc:	8526                	mv	a0,s1
    800035fe:	00003097          	auipc	ra,0x3
    80003602:	fca080e7          	jalr	-54(ra) # 800065c8 <virtio_disk_rw>
    b->valid = 1;
    80003606:	4785                	li	a5,1
    80003608:	c09c                	sw	a5,0(s1)
  return b;
    8000360a:	b7c5                	j	800035ea <bread+0xd0>

000000008000360c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000360c:	1101                	addi	sp,sp,-32
    8000360e:	ec06                	sd	ra,24(sp)
    80003610:	e822                	sd	s0,16(sp)
    80003612:	e426                	sd	s1,8(sp)
    80003614:	1000                	addi	s0,sp,32
    80003616:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003618:	0541                	addi	a0,a0,16
    8000361a:	00001097          	auipc	ra,0x1
    8000361e:	46e080e7          	jalr	1134(ra) # 80004a88 <holdingsleep>
    80003622:	cd01                	beqz	a0,8000363a <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003624:	4585                	li	a1,1
    80003626:	8526                	mv	a0,s1
    80003628:	00003097          	auipc	ra,0x3
    8000362c:	fa0080e7          	jalr	-96(ra) # 800065c8 <virtio_disk_rw>
}
    80003630:	60e2                	ld	ra,24(sp)
    80003632:	6442                	ld	s0,16(sp)
    80003634:	64a2                	ld	s1,8(sp)
    80003636:	6105                	addi	sp,sp,32
    80003638:	8082                	ret
    panic("bwrite");
    8000363a:	00005517          	auipc	a0,0x5
    8000363e:	03e50513          	addi	a0,a0,62 # 80008678 <syscallnum+0x98>
    80003642:	ffffd097          	auipc	ra,0xffffd
    80003646:	f02080e7          	jalr	-254(ra) # 80000544 <panic>

000000008000364a <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000364a:	1101                	addi	sp,sp,-32
    8000364c:	ec06                	sd	ra,24(sp)
    8000364e:	e822                	sd	s0,16(sp)
    80003650:	e426                	sd	s1,8(sp)
    80003652:	e04a                	sd	s2,0(sp)
    80003654:	1000                	addi	s0,sp,32
    80003656:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003658:	01050913          	addi	s2,a0,16
    8000365c:	854a                	mv	a0,s2
    8000365e:	00001097          	auipc	ra,0x1
    80003662:	42a080e7          	jalr	1066(ra) # 80004a88 <holdingsleep>
    80003666:	c92d                	beqz	a0,800036d8 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003668:	854a                	mv	a0,s2
    8000366a:	00001097          	auipc	ra,0x1
    8000366e:	3da080e7          	jalr	986(ra) # 80004a44 <releasesleep>

  acquire(&bcache.lock);
    80003672:	00015517          	auipc	a0,0x15
    80003676:	36650513          	addi	a0,a0,870 # 800189d8 <bcache>
    8000367a:	ffffd097          	auipc	ra,0xffffd
    8000367e:	570080e7          	jalr	1392(ra) # 80000bea <acquire>
  b->refcnt--;
    80003682:	40bc                	lw	a5,64(s1)
    80003684:	37fd                	addiw	a5,a5,-1
    80003686:	0007871b          	sext.w	a4,a5
    8000368a:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000368c:	eb05                	bnez	a4,800036bc <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000368e:	68bc                	ld	a5,80(s1)
    80003690:	64b8                	ld	a4,72(s1)
    80003692:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003694:	64bc                	ld	a5,72(s1)
    80003696:	68b8                	ld	a4,80(s1)
    80003698:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000369a:	0001d797          	auipc	a5,0x1d
    8000369e:	33e78793          	addi	a5,a5,830 # 800209d8 <bcache+0x8000>
    800036a2:	2b87b703          	ld	a4,696(a5)
    800036a6:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800036a8:	0001d717          	auipc	a4,0x1d
    800036ac:	59870713          	addi	a4,a4,1432 # 80020c40 <bcache+0x8268>
    800036b0:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800036b2:	2b87b703          	ld	a4,696(a5)
    800036b6:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800036b8:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800036bc:	00015517          	auipc	a0,0x15
    800036c0:	31c50513          	addi	a0,a0,796 # 800189d8 <bcache>
    800036c4:	ffffd097          	auipc	ra,0xffffd
    800036c8:	5da080e7          	jalr	1498(ra) # 80000c9e <release>
}
    800036cc:	60e2                	ld	ra,24(sp)
    800036ce:	6442                	ld	s0,16(sp)
    800036d0:	64a2                	ld	s1,8(sp)
    800036d2:	6902                	ld	s2,0(sp)
    800036d4:	6105                	addi	sp,sp,32
    800036d6:	8082                	ret
    panic("brelse");
    800036d8:	00005517          	auipc	a0,0x5
    800036dc:	fa850513          	addi	a0,a0,-88 # 80008680 <syscallnum+0xa0>
    800036e0:	ffffd097          	auipc	ra,0xffffd
    800036e4:	e64080e7          	jalr	-412(ra) # 80000544 <panic>

00000000800036e8 <bpin>:

void
bpin(struct buf *b) {
    800036e8:	1101                	addi	sp,sp,-32
    800036ea:	ec06                	sd	ra,24(sp)
    800036ec:	e822                	sd	s0,16(sp)
    800036ee:	e426                	sd	s1,8(sp)
    800036f0:	1000                	addi	s0,sp,32
    800036f2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800036f4:	00015517          	auipc	a0,0x15
    800036f8:	2e450513          	addi	a0,a0,740 # 800189d8 <bcache>
    800036fc:	ffffd097          	auipc	ra,0xffffd
    80003700:	4ee080e7          	jalr	1262(ra) # 80000bea <acquire>
  b->refcnt++;
    80003704:	40bc                	lw	a5,64(s1)
    80003706:	2785                	addiw	a5,a5,1
    80003708:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000370a:	00015517          	auipc	a0,0x15
    8000370e:	2ce50513          	addi	a0,a0,718 # 800189d8 <bcache>
    80003712:	ffffd097          	auipc	ra,0xffffd
    80003716:	58c080e7          	jalr	1420(ra) # 80000c9e <release>
}
    8000371a:	60e2                	ld	ra,24(sp)
    8000371c:	6442                	ld	s0,16(sp)
    8000371e:	64a2                	ld	s1,8(sp)
    80003720:	6105                	addi	sp,sp,32
    80003722:	8082                	ret

0000000080003724 <bunpin>:

void
bunpin(struct buf *b) {
    80003724:	1101                	addi	sp,sp,-32
    80003726:	ec06                	sd	ra,24(sp)
    80003728:	e822                	sd	s0,16(sp)
    8000372a:	e426                	sd	s1,8(sp)
    8000372c:	1000                	addi	s0,sp,32
    8000372e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003730:	00015517          	auipc	a0,0x15
    80003734:	2a850513          	addi	a0,a0,680 # 800189d8 <bcache>
    80003738:	ffffd097          	auipc	ra,0xffffd
    8000373c:	4b2080e7          	jalr	1202(ra) # 80000bea <acquire>
  b->refcnt--;
    80003740:	40bc                	lw	a5,64(s1)
    80003742:	37fd                	addiw	a5,a5,-1
    80003744:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003746:	00015517          	auipc	a0,0x15
    8000374a:	29250513          	addi	a0,a0,658 # 800189d8 <bcache>
    8000374e:	ffffd097          	auipc	ra,0xffffd
    80003752:	550080e7          	jalr	1360(ra) # 80000c9e <release>
}
    80003756:	60e2                	ld	ra,24(sp)
    80003758:	6442                	ld	s0,16(sp)
    8000375a:	64a2                	ld	s1,8(sp)
    8000375c:	6105                	addi	sp,sp,32
    8000375e:	8082                	ret

0000000080003760 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003760:	1101                	addi	sp,sp,-32
    80003762:	ec06                	sd	ra,24(sp)
    80003764:	e822                	sd	s0,16(sp)
    80003766:	e426                	sd	s1,8(sp)
    80003768:	e04a                	sd	s2,0(sp)
    8000376a:	1000                	addi	s0,sp,32
    8000376c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000376e:	00d5d59b          	srliw	a1,a1,0xd
    80003772:	0001e797          	auipc	a5,0x1e
    80003776:	9427a783          	lw	a5,-1726(a5) # 800210b4 <sb+0x1c>
    8000377a:	9dbd                	addw	a1,a1,a5
    8000377c:	00000097          	auipc	ra,0x0
    80003780:	d9e080e7          	jalr	-610(ra) # 8000351a <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003784:	0074f713          	andi	a4,s1,7
    80003788:	4785                	li	a5,1
    8000378a:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000378e:	14ce                	slli	s1,s1,0x33
    80003790:	90d9                	srli	s1,s1,0x36
    80003792:	00950733          	add	a4,a0,s1
    80003796:	05874703          	lbu	a4,88(a4)
    8000379a:	00e7f6b3          	and	a3,a5,a4
    8000379e:	c69d                	beqz	a3,800037cc <bfree+0x6c>
    800037a0:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800037a2:	94aa                	add	s1,s1,a0
    800037a4:	fff7c793          	not	a5,a5
    800037a8:	8ff9                	and	a5,a5,a4
    800037aa:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800037ae:	00001097          	auipc	ra,0x1
    800037b2:	120080e7          	jalr	288(ra) # 800048ce <log_write>
  brelse(bp);
    800037b6:	854a                	mv	a0,s2
    800037b8:	00000097          	auipc	ra,0x0
    800037bc:	e92080e7          	jalr	-366(ra) # 8000364a <brelse>
}
    800037c0:	60e2                	ld	ra,24(sp)
    800037c2:	6442                	ld	s0,16(sp)
    800037c4:	64a2                	ld	s1,8(sp)
    800037c6:	6902                	ld	s2,0(sp)
    800037c8:	6105                	addi	sp,sp,32
    800037ca:	8082                	ret
    panic("freeing free block");
    800037cc:	00005517          	auipc	a0,0x5
    800037d0:	ebc50513          	addi	a0,a0,-324 # 80008688 <syscallnum+0xa8>
    800037d4:	ffffd097          	auipc	ra,0xffffd
    800037d8:	d70080e7          	jalr	-656(ra) # 80000544 <panic>

00000000800037dc <balloc>:
{
    800037dc:	711d                	addi	sp,sp,-96
    800037de:	ec86                	sd	ra,88(sp)
    800037e0:	e8a2                	sd	s0,80(sp)
    800037e2:	e4a6                	sd	s1,72(sp)
    800037e4:	e0ca                	sd	s2,64(sp)
    800037e6:	fc4e                	sd	s3,56(sp)
    800037e8:	f852                	sd	s4,48(sp)
    800037ea:	f456                	sd	s5,40(sp)
    800037ec:	f05a                	sd	s6,32(sp)
    800037ee:	ec5e                	sd	s7,24(sp)
    800037f0:	e862                	sd	s8,16(sp)
    800037f2:	e466                	sd	s9,8(sp)
    800037f4:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800037f6:	0001e797          	auipc	a5,0x1e
    800037fa:	8a67a783          	lw	a5,-1882(a5) # 8002109c <sb+0x4>
    800037fe:	10078163          	beqz	a5,80003900 <balloc+0x124>
    80003802:	8baa                	mv	s7,a0
    80003804:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003806:	0001eb17          	auipc	s6,0x1e
    8000380a:	892b0b13          	addi	s6,s6,-1902 # 80021098 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000380e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003810:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003812:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003814:	6c89                	lui	s9,0x2
    80003816:	a061                	j	8000389e <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003818:	974a                	add	a4,a4,s2
    8000381a:	8fd5                	or	a5,a5,a3
    8000381c:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003820:	854a                	mv	a0,s2
    80003822:	00001097          	auipc	ra,0x1
    80003826:	0ac080e7          	jalr	172(ra) # 800048ce <log_write>
        brelse(bp);
    8000382a:	854a                	mv	a0,s2
    8000382c:	00000097          	auipc	ra,0x0
    80003830:	e1e080e7          	jalr	-482(ra) # 8000364a <brelse>
  bp = bread(dev, bno);
    80003834:	85a6                	mv	a1,s1
    80003836:	855e                	mv	a0,s7
    80003838:	00000097          	auipc	ra,0x0
    8000383c:	ce2080e7          	jalr	-798(ra) # 8000351a <bread>
    80003840:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003842:	40000613          	li	a2,1024
    80003846:	4581                	li	a1,0
    80003848:	05850513          	addi	a0,a0,88
    8000384c:	ffffd097          	auipc	ra,0xffffd
    80003850:	49a080e7          	jalr	1178(ra) # 80000ce6 <memset>
  log_write(bp);
    80003854:	854a                	mv	a0,s2
    80003856:	00001097          	auipc	ra,0x1
    8000385a:	078080e7          	jalr	120(ra) # 800048ce <log_write>
  brelse(bp);
    8000385e:	854a                	mv	a0,s2
    80003860:	00000097          	auipc	ra,0x0
    80003864:	dea080e7          	jalr	-534(ra) # 8000364a <brelse>
}
    80003868:	8526                	mv	a0,s1
    8000386a:	60e6                	ld	ra,88(sp)
    8000386c:	6446                	ld	s0,80(sp)
    8000386e:	64a6                	ld	s1,72(sp)
    80003870:	6906                	ld	s2,64(sp)
    80003872:	79e2                	ld	s3,56(sp)
    80003874:	7a42                	ld	s4,48(sp)
    80003876:	7aa2                	ld	s5,40(sp)
    80003878:	7b02                	ld	s6,32(sp)
    8000387a:	6be2                	ld	s7,24(sp)
    8000387c:	6c42                	ld	s8,16(sp)
    8000387e:	6ca2                	ld	s9,8(sp)
    80003880:	6125                	addi	sp,sp,96
    80003882:	8082                	ret
    brelse(bp);
    80003884:	854a                	mv	a0,s2
    80003886:	00000097          	auipc	ra,0x0
    8000388a:	dc4080e7          	jalr	-572(ra) # 8000364a <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000388e:	015c87bb          	addw	a5,s9,s5
    80003892:	00078a9b          	sext.w	s5,a5
    80003896:	004b2703          	lw	a4,4(s6)
    8000389a:	06eaf363          	bgeu	s5,a4,80003900 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    8000389e:	41fad79b          	sraiw	a5,s5,0x1f
    800038a2:	0137d79b          	srliw	a5,a5,0x13
    800038a6:	015787bb          	addw	a5,a5,s5
    800038aa:	40d7d79b          	sraiw	a5,a5,0xd
    800038ae:	01cb2583          	lw	a1,28(s6)
    800038b2:	9dbd                	addw	a1,a1,a5
    800038b4:	855e                	mv	a0,s7
    800038b6:	00000097          	auipc	ra,0x0
    800038ba:	c64080e7          	jalr	-924(ra) # 8000351a <bread>
    800038be:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800038c0:	004b2503          	lw	a0,4(s6)
    800038c4:	000a849b          	sext.w	s1,s5
    800038c8:	8662                	mv	a2,s8
    800038ca:	faa4fde3          	bgeu	s1,a0,80003884 <balloc+0xa8>
      m = 1 << (bi % 8);
    800038ce:	41f6579b          	sraiw	a5,a2,0x1f
    800038d2:	01d7d69b          	srliw	a3,a5,0x1d
    800038d6:	00c6873b          	addw	a4,a3,a2
    800038da:	00777793          	andi	a5,a4,7
    800038de:	9f95                	subw	a5,a5,a3
    800038e0:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800038e4:	4037571b          	sraiw	a4,a4,0x3
    800038e8:	00e906b3          	add	a3,s2,a4
    800038ec:	0586c683          	lbu	a3,88(a3)
    800038f0:	00d7f5b3          	and	a1,a5,a3
    800038f4:	d195                	beqz	a1,80003818 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800038f6:	2605                	addiw	a2,a2,1
    800038f8:	2485                	addiw	s1,s1,1
    800038fa:	fd4618e3          	bne	a2,s4,800038ca <balloc+0xee>
    800038fe:	b759                	j	80003884 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003900:	00005517          	auipc	a0,0x5
    80003904:	da050513          	addi	a0,a0,-608 # 800086a0 <syscallnum+0xc0>
    80003908:	ffffd097          	auipc	ra,0xffffd
    8000390c:	c86080e7          	jalr	-890(ra) # 8000058e <printf>
  return 0;
    80003910:	4481                	li	s1,0
    80003912:	bf99                	j	80003868 <balloc+0x8c>

0000000080003914 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003914:	7179                	addi	sp,sp,-48
    80003916:	f406                	sd	ra,40(sp)
    80003918:	f022                	sd	s0,32(sp)
    8000391a:	ec26                	sd	s1,24(sp)
    8000391c:	e84a                	sd	s2,16(sp)
    8000391e:	e44e                	sd	s3,8(sp)
    80003920:	e052                	sd	s4,0(sp)
    80003922:	1800                	addi	s0,sp,48
    80003924:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003926:	47ad                	li	a5,11
    80003928:	02b7e763          	bltu	a5,a1,80003956 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    8000392c:	02059493          	slli	s1,a1,0x20
    80003930:	9081                	srli	s1,s1,0x20
    80003932:	048a                	slli	s1,s1,0x2
    80003934:	94aa                	add	s1,s1,a0
    80003936:	0504a903          	lw	s2,80(s1)
    8000393a:	06091e63          	bnez	s2,800039b6 <bmap+0xa2>
      addr = balloc(ip->dev);
    8000393e:	4108                	lw	a0,0(a0)
    80003940:	00000097          	auipc	ra,0x0
    80003944:	e9c080e7          	jalr	-356(ra) # 800037dc <balloc>
    80003948:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000394c:	06090563          	beqz	s2,800039b6 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003950:	0524a823          	sw	s2,80(s1)
    80003954:	a08d                	j	800039b6 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003956:	ff45849b          	addiw	s1,a1,-12
    8000395a:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000395e:	0ff00793          	li	a5,255
    80003962:	08e7e563          	bltu	a5,a4,800039ec <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003966:	08052903          	lw	s2,128(a0)
    8000396a:	00091d63          	bnez	s2,80003984 <bmap+0x70>
      addr = balloc(ip->dev);
    8000396e:	4108                	lw	a0,0(a0)
    80003970:	00000097          	auipc	ra,0x0
    80003974:	e6c080e7          	jalr	-404(ra) # 800037dc <balloc>
    80003978:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000397c:	02090d63          	beqz	s2,800039b6 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003980:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003984:	85ca                	mv	a1,s2
    80003986:	0009a503          	lw	a0,0(s3)
    8000398a:	00000097          	auipc	ra,0x0
    8000398e:	b90080e7          	jalr	-1136(ra) # 8000351a <bread>
    80003992:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003994:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003998:	02049593          	slli	a1,s1,0x20
    8000399c:	9181                	srli	a1,a1,0x20
    8000399e:	058a                	slli	a1,a1,0x2
    800039a0:	00b784b3          	add	s1,a5,a1
    800039a4:	0004a903          	lw	s2,0(s1)
    800039a8:	02090063          	beqz	s2,800039c8 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800039ac:	8552                	mv	a0,s4
    800039ae:	00000097          	auipc	ra,0x0
    800039b2:	c9c080e7          	jalr	-868(ra) # 8000364a <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800039b6:	854a                	mv	a0,s2
    800039b8:	70a2                	ld	ra,40(sp)
    800039ba:	7402                	ld	s0,32(sp)
    800039bc:	64e2                	ld	s1,24(sp)
    800039be:	6942                	ld	s2,16(sp)
    800039c0:	69a2                	ld	s3,8(sp)
    800039c2:	6a02                	ld	s4,0(sp)
    800039c4:	6145                	addi	sp,sp,48
    800039c6:	8082                	ret
      addr = balloc(ip->dev);
    800039c8:	0009a503          	lw	a0,0(s3)
    800039cc:	00000097          	auipc	ra,0x0
    800039d0:	e10080e7          	jalr	-496(ra) # 800037dc <balloc>
    800039d4:	0005091b          	sext.w	s2,a0
      if(addr){
    800039d8:	fc090ae3          	beqz	s2,800039ac <bmap+0x98>
        a[bn] = addr;
    800039dc:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800039e0:	8552                	mv	a0,s4
    800039e2:	00001097          	auipc	ra,0x1
    800039e6:	eec080e7          	jalr	-276(ra) # 800048ce <log_write>
    800039ea:	b7c9                	j	800039ac <bmap+0x98>
  panic("bmap: out of range");
    800039ec:	00005517          	auipc	a0,0x5
    800039f0:	ccc50513          	addi	a0,a0,-820 # 800086b8 <syscallnum+0xd8>
    800039f4:	ffffd097          	auipc	ra,0xffffd
    800039f8:	b50080e7          	jalr	-1200(ra) # 80000544 <panic>

00000000800039fc <iget>:
{
    800039fc:	7179                	addi	sp,sp,-48
    800039fe:	f406                	sd	ra,40(sp)
    80003a00:	f022                	sd	s0,32(sp)
    80003a02:	ec26                	sd	s1,24(sp)
    80003a04:	e84a                	sd	s2,16(sp)
    80003a06:	e44e                	sd	s3,8(sp)
    80003a08:	e052                	sd	s4,0(sp)
    80003a0a:	1800                	addi	s0,sp,48
    80003a0c:	89aa                	mv	s3,a0
    80003a0e:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003a10:	0001d517          	auipc	a0,0x1d
    80003a14:	6a850513          	addi	a0,a0,1704 # 800210b8 <itable>
    80003a18:	ffffd097          	auipc	ra,0xffffd
    80003a1c:	1d2080e7          	jalr	466(ra) # 80000bea <acquire>
  empty = 0;
    80003a20:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003a22:	0001d497          	auipc	s1,0x1d
    80003a26:	6ae48493          	addi	s1,s1,1710 # 800210d0 <itable+0x18>
    80003a2a:	0001f697          	auipc	a3,0x1f
    80003a2e:	13668693          	addi	a3,a3,310 # 80022b60 <log>
    80003a32:	a039                	j	80003a40 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003a34:	02090b63          	beqz	s2,80003a6a <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003a38:	08848493          	addi	s1,s1,136
    80003a3c:	02d48a63          	beq	s1,a3,80003a70 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003a40:	449c                	lw	a5,8(s1)
    80003a42:	fef059e3          	blez	a5,80003a34 <iget+0x38>
    80003a46:	4098                	lw	a4,0(s1)
    80003a48:	ff3716e3          	bne	a4,s3,80003a34 <iget+0x38>
    80003a4c:	40d8                	lw	a4,4(s1)
    80003a4e:	ff4713e3          	bne	a4,s4,80003a34 <iget+0x38>
      ip->ref++;
    80003a52:	2785                	addiw	a5,a5,1
    80003a54:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003a56:	0001d517          	auipc	a0,0x1d
    80003a5a:	66250513          	addi	a0,a0,1634 # 800210b8 <itable>
    80003a5e:	ffffd097          	auipc	ra,0xffffd
    80003a62:	240080e7          	jalr	576(ra) # 80000c9e <release>
      return ip;
    80003a66:	8926                	mv	s2,s1
    80003a68:	a03d                	j	80003a96 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003a6a:	f7f9                	bnez	a5,80003a38 <iget+0x3c>
    80003a6c:	8926                	mv	s2,s1
    80003a6e:	b7e9                	j	80003a38 <iget+0x3c>
  if(empty == 0)
    80003a70:	02090c63          	beqz	s2,80003aa8 <iget+0xac>
  ip->dev = dev;
    80003a74:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003a78:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003a7c:	4785                	li	a5,1
    80003a7e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003a82:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003a86:	0001d517          	auipc	a0,0x1d
    80003a8a:	63250513          	addi	a0,a0,1586 # 800210b8 <itable>
    80003a8e:	ffffd097          	auipc	ra,0xffffd
    80003a92:	210080e7          	jalr	528(ra) # 80000c9e <release>
}
    80003a96:	854a                	mv	a0,s2
    80003a98:	70a2                	ld	ra,40(sp)
    80003a9a:	7402                	ld	s0,32(sp)
    80003a9c:	64e2                	ld	s1,24(sp)
    80003a9e:	6942                	ld	s2,16(sp)
    80003aa0:	69a2                	ld	s3,8(sp)
    80003aa2:	6a02                	ld	s4,0(sp)
    80003aa4:	6145                	addi	sp,sp,48
    80003aa6:	8082                	ret
    panic("iget: no inodes");
    80003aa8:	00005517          	auipc	a0,0x5
    80003aac:	c2850513          	addi	a0,a0,-984 # 800086d0 <syscallnum+0xf0>
    80003ab0:	ffffd097          	auipc	ra,0xffffd
    80003ab4:	a94080e7          	jalr	-1388(ra) # 80000544 <panic>

0000000080003ab8 <fsinit>:
fsinit(int dev) {
    80003ab8:	7179                	addi	sp,sp,-48
    80003aba:	f406                	sd	ra,40(sp)
    80003abc:	f022                	sd	s0,32(sp)
    80003abe:	ec26                	sd	s1,24(sp)
    80003ac0:	e84a                	sd	s2,16(sp)
    80003ac2:	e44e                	sd	s3,8(sp)
    80003ac4:	1800                	addi	s0,sp,48
    80003ac6:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003ac8:	4585                	li	a1,1
    80003aca:	00000097          	auipc	ra,0x0
    80003ace:	a50080e7          	jalr	-1456(ra) # 8000351a <bread>
    80003ad2:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003ad4:	0001d997          	auipc	s3,0x1d
    80003ad8:	5c498993          	addi	s3,s3,1476 # 80021098 <sb>
    80003adc:	02000613          	li	a2,32
    80003ae0:	05850593          	addi	a1,a0,88
    80003ae4:	854e                	mv	a0,s3
    80003ae6:	ffffd097          	auipc	ra,0xffffd
    80003aea:	260080e7          	jalr	608(ra) # 80000d46 <memmove>
  brelse(bp);
    80003aee:	8526                	mv	a0,s1
    80003af0:	00000097          	auipc	ra,0x0
    80003af4:	b5a080e7          	jalr	-1190(ra) # 8000364a <brelse>
  if(sb.magic != FSMAGIC)
    80003af8:	0009a703          	lw	a4,0(s3)
    80003afc:	102037b7          	lui	a5,0x10203
    80003b00:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003b04:	02f71263          	bne	a4,a5,80003b28 <fsinit+0x70>
  initlog(dev, &sb);
    80003b08:	0001d597          	auipc	a1,0x1d
    80003b0c:	59058593          	addi	a1,a1,1424 # 80021098 <sb>
    80003b10:	854a                	mv	a0,s2
    80003b12:	00001097          	auipc	ra,0x1
    80003b16:	b40080e7          	jalr	-1216(ra) # 80004652 <initlog>
}
    80003b1a:	70a2                	ld	ra,40(sp)
    80003b1c:	7402                	ld	s0,32(sp)
    80003b1e:	64e2                	ld	s1,24(sp)
    80003b20:	6942                	ld	s2,16(sp)
    80003b22:	69a2                	ld	s3,8(sp)
    80003b24:	6145                	addi	sp,sp,48
    80003b26:	8082                	ret
    panic("invalid file system");
    80003b28:	00005517          	auipc	a0,0x5
    80003b2c:	bb850513          	addi	a0,a0,-1096 # 800086e0 <syscallnum+0x100>
    80003b30:	ffffd097          	auipc	ra,0xffffd
    80003b34:	a14080e7          	jalr	-1516(ra) # 80000544 <panic>

0000000080003b38 <iinit>:
{
    80003b38:	7179                	addi	sp,sp,-48
    80003b3a:	f406                	sd	ra,40(sp)
    80003b3c:	f022                	sd	s0,32(sp)
    80003b3e:	ec26                	sd	s1,24(sp)
    80003b40:	e84a                	sd	s2,16(sp)
    80003b42:	e44e                	sd	s3,8(sp)
    80003b44:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003b46:	00005597          	auipc	a1,0x5
    80003b4a:	bb258593          	addi	a1,a1,-1102 # 800086f8 <syscallnum+0x118>
    80003b4e:	0001d517          	auipc	a0,0x1d
    80003b52:	56a50513          	addi	a0,a0,1386 # 800210b8 <itable>
    80003b56:	ffffd097          	auipc	ra,0xffffd
    80003b5a:	004080e7          	jalr	4(ra) # 80000b5a <initlock>
  for(i = 0; i < NINODE; i++) {
    80003b5e:	0001d497          	auipc	s1,0x1d
    80003b62:	58248493          	addi	s1,s1,1410 # 800210e0 <itable+0x28>
    80003b66:	0001f997          	auipc	s3,0x1f
    80003b6a:	00a98993          	addi	s3,s3,10 # 80022b70 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003b6e:	00005917          	auipc	s2,0x5
    80003b72:	b9290913          	addi	s2,s2,-1134 # 80008700 <syscallnum+0x120>
    80003b76:	85ca                	mv	a1,s2
    80003b78:	8526                	mv	a0,s1
    80003b7a:	00001097          	auipc	ra,0x1
    80003b7e:	e3a080e7          	jalr	-454(ra) # 800049b4 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003b82:	08848493          	addi	s1,s1,136
    80003b86:	ff3498e3          	bne	s1,s3,80003b76 <iinit+0x3e>
}
    80003b8a:	70a2                	ld	ra,40(sp)
    80003b8c:	7402                	ld	s0,32(sp)
    80003b8e:	64e2                	ld	s1,24(sp)
    80003b90:	6942                	ld	s2,16(sp)
    80003b92:	69a2                	ld	s3,8(sp)
    80003b94:	6145                	addi	sp,sp,48
    80003b96:	8082                	ret

0000000080003b98 <ialloc>:
{
    80003b98:	715d                	addi	sp,sp,-80
    80003b9a:	e486                	sd	ra,72(sp)
    80003b9c:	e0a2                	sd	s0,64(sp)
    80003b9e:	fc26                	sd	s1,56(sp)
    80003ba0:	f84a                	sd	s2,48(sp)
    80003ba2:	f44e                	sd	s3,40(sp)
    80003ba4:	f052                	sd	s4,32(sp)
    80003ba6:	ec56                	sd	s5,24(sp)
    80003ba8:	e85a                	sd	s6,16(sp)
    80003baa:	e45e                	sd	s7,8(sp)
    80003bac:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003bae:	0001d717          	auipc	a4,0x1d
    80003bb2:	4f672703          	lw	a4,1270(a4) # 800210a4 <sb+0xc>
    80003bb6:	4785                	li	a5,1
    80003bb8:	04e7fa63          	bgeu	a5,a4,80003c0c <ialloc+0x74>
    80003bbc:	8aaa                	mv	s5,a0
    80003bbe:	8bae                	mv	s7,a1
    80003bc0:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003bc2:	0001da17          	auipc	s4,0x1d
    80003bc6:	4d6a0a13          	addi	s4,s4,1238 # 80021098 <sb>
    80003bca:	00048b1b          	sext.w	s6,s1
    80003bce:	0044d593          	srli	a1,s1,0x4
    80003bd2:	018a2783          	lw	a5,24(s4)
    80003bd6:	9dbd                	addw	a1,a1,a5
    80003bd8:	8556                	mv	a0,s5
    80003bda:	00000097          	auipc	ra,0x0
    80003bde:	940080e7          	jalr	-1728(ra) # 8000351a <bread>
    80003be2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003be4:	05850993          	addi	s3,a0,88
    80003be8:	00f4f793          	andi	a5,s1,15
    80003bec:	079a                	slli	a5,a5,0x6
    80003bee:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003bf0:	00099783          	lh	a5,0(s3)
    80003bf4:	c3a1                	beqz	a5,80003c34 <ialloc+0x9c>
    brelse(bp);
    80003bf6:	00000097          	auipc	ra,0x0
    80003bfa:	a54080e7          	jalr	-1452(ra) # 8000364a <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003bfe:	0485                	addi	s1,s1,1
    80003c00:	00ca2703          	lw	a4,12(s4)
    80003c04:	0004879b          	sext.w	a5,s1
    80003c08:	fce7e1e3          	bltu	a5,a4,80003bca <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003c0c:	00005517          	auipc	a0,0x5
    80003c10:	afc50513          	addi	a0,a0,-1284 # 80008708 <syscallnum+0x128>
    80003c14:	ffffd097          	auipc	ra,0xffffd
    80003c18:	97a080e7          	jalr	-1670(ra) # 8000058e <printf>
  return 0;
    80003c1c:	4501                	li	a0,0
}
    80003c1e:	60a6                	ld	ra,72(sp)
    80003c20:	6406                	ld	s0,64(sp)
    80003c22:	74e2                	ld	s1,56(sp)
    80003c24:	7942                	ld	s2,48(sp)
    80003c26:	79a2                	ld	s3,40(sp)
    80003c28:	7a02                	ld	s4,32(sp)
    80003c2a:	6ae2                	ld	s5,24(sp)
    80003c2c:	6b42                	ld	s6,16(sp)
    80003c2e:	6ba2                	ld	s7,8(sp)
    80003c30:	6161                	addi	sp,sp,80
    80003c32:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003c34:	04000613          	li	a2,64
    80003c38:	4581                	li	a1,0
    80003c3a:	854e                	mv	a0,s3
    80003c3c:	ffffd097          	auipc	ra,0xffffd
    80003c40:	0aa080e7          	jalr	170(ra) # 80000ce6 <memset>
      dip->type = type;
    80003c44:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003c48:	854a                	mv	a0,s2
    80003c4a:	00001097          	auipc	ra,0x1
    80003c4e:	c84080e7          	jalr	-892(ra) # 800048ce <log_write>
      brelse(bp);
    80003c52:	854a                	mv	a0,s2
    80003c54:	00000097          	auipc	ra,0x0
    80003c58:	9f6080e7          	jalr	-1546(ra) # 8000364a <brelse>
      return iget(dev, inum);
    80003c5c:	85da                	mv	a1,s6
    80003c5e:	8556                	mv	a0,s5
    80003c60:	00000097          	auipc	ra,0x0
    80003c64:	d9c080e7          	jalr	-612(ra) # 800039fc <iget>
    80003c68:	bf5d                	j	80003c1e <ialloc+0x86>

0000000080003c6a <iupdate>:
{
    80003c6a:	1101                	addi	sp,sp,-32
    80003c6c:	ec06                	sd	ra,24(sp)
    80003c6e:	e822                	sd	s0,16(sp)
    80003c70:	e426                	sd	s1,8(sp)
    80003c72:	e04a                	sd	s2,0(sp)
    80003c74:	1000                	addi	s0,sp,32
    80003c76:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003c78:	415c                	lw	a5,4(a0)
    80003c7a:	0047d79b          	srliw	a5,a5,0x4
    80003c7e:	0001d597          	auipc	a1,0x1d
    80003c82:	4325a583          	lw	a1,1074(a1) # 800210b0 <sb+0x18>
    80003c86:	9dbd                	addw	a1,a1,a5
    80003c88:	4108                	lw	a0,0(a0)
    80003c8a:	00000097          	auipc	ra,0x0
    80003c8e:	890080e7          	jalr	-1904(ra) # 8000351a <bread>
    80003c92:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c94:	05850793          	addi	a5,a0,88
    80003c98:	40c8                	lw	a0,4(s1)
    80003c9a:	893d                	andi	a0,a0,15
    80003c9c:	051a                	slli	a0,a0,0x6
    80003c9e:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003ca0:	04449703          	lh	a4,68(s1)
    80003ca4:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003ca8:	04649703          	lh	a4,70(s1)
    80003cac:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003cb0:	04849703          	lh	a4,72(s1)
    80003cb4:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003cb8:	04a49703          	lh	a4,74(s1)
    80003cbc:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003cc0:	44f8                	lw	a4,76(s1)
    80003cc2:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003cc4:	03400613          	li	a2,52
    80003cc8:	05048593          	addi	a1,s1,80
    80003ccc:	0531                	addi	a0,a0,12
    80003cce:	ffffd097          	auipc	ra,0xffffd
    80003cd2:	078080e7          	jalr	120(ra) # 80000d46 <memmove>
  log_write(bp);
    80003cd6:	854a                	mv	a0,s2
    80003cd8:	00001097          	auipc	ra,0x1
    80003cdc:	bf6080e7          	jalr	-1034(ra) # 800048ce <log_write>
  brelse(bp);
    80003ce0:	854a                	mv	a0,s2
    80003ce2:	00000097          	auipc	ra,0x0
    80003ce6:	968080e7          	jalr	-1688(ra) # 8000364a <brelse>
}
    80003cea:	60e2                	ld	ra,24(sp)
    80003cec:	6442                	ld	s0,16(sp)
    80003cee:	64a2                	ld	s1,8(sp)
    80003cf0:	6902                	ld	s2,0(sp)
    80003cf2:	6105                	addi	sp,sp,32
    80003cf4:	8082                	ret

0000000080003cf6 <idup>:
{
    80003cf6:	1101                	addi	sp,sp,-32
    80003cf8:	ec06                	sd	ra,24(sp)
    80003cfa:	e822                	sd	s0,16(sp)
    80003cfc:	e426                	sd	s1,8(sp)
    80003cfe:	1000                	addi	s0,sp,32
    80003d00:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003d02:	0001d517          	auipc	a0,0x1d
    80003d06:	3b650513          	addi	a0,a0,950 # 800210b8 <itable>
    80003d0a:	ffffd097          	auipc	ra,0xffffd
    80003d0e:	ee0080e7          	jalr	-288(ra) # 80000bea <acquire>
  ip->ref++;
    80003d12:	449c                	lw	a5,8(s1)
    80003d14:	2785                	addiw	a5,a5,1
    80003d16:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003d18:	0001d517          	auipc	a0,0x1d
    80003d1c:	3a050513          	addi	a0,a0,928 # 800210b8 <itable>
    80003d20:	ffffd097          	auipc	ra,0xffffd
    80003d24:	f7e080e7          	jalr	-130(ra) # 80000c9e <release>
}
    80003d28:	8526                	mv	a0,s1
    80003d2a:	60e2                	ld	ra,24(sp)
    80003d2c:	6442                	ld	s0,16(sp)
    80003d2e:	64a2                	ld	s1,8(sp)
    80003d30:	6105                	addi	sp,sp,32
    80003d32:	8082                	ret

0000000080003d34 <ilock>:
{
    80003d34:	1101                	addi	sp,sp,-32
    80003d36:	ec06                	sd	ra,24(sp)
    80003d38:	e822                	sd	s0,16(sp)
    80003d3a:	e426                	sd	s1,8(sp)
    80003d3c:	e04a                	sd	s2,0(sp)
    80003d3e:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003d40:	c115                	beqz	a0,80003d64 <ilock+0x30>
    80003d42:	84aa                	mv	s1,a0
    80003d44:	451c                	lw	a5,8(a0)
    80003d46:	00f05f63          	blez	a5,80003d64 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003d4a:	0541                	addi	a0,a0,16
    80003d4c:	00001097          	auipc	ra,0x1
    80003d50:	ca2080e7          	jalr	-862(ra) # 800049ee <acquiresleep>
  if(ip->valid == 0){
    80003d54:	40bc                	lw	a5,64(s1)
    80003d56:	cf99                	beqz	a5,80003d74 <ilock+0x40>
}
    80003d58:	60e2                	ld	ra,24(sp)
    80003d5a:	6442                	ld	s0,16(sp)
    80003d5c:	64a2                	ld	s1,8(sp)
    80003d5e:	6902                	ld	s2,0(sp)
    80003d60:	6105                	addi	sp,sp,32
    80003d62:	8082                	ret
    panic("ilock");
    80003d64:	00005517          	auipc	a0,0x5
    80003d68:	9bc50513          	addi	a0,a0,-1604 # 80008720 <syscallnum+0x140>
    80003d6c:	ffffc097          	auipc	ra,0xffffc
    80003d70:	7d8080e7          	jalr	2008(ra) # 80000544 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003d74:	40dc                	lw	a5,4(s1)
    80003d76:	0047d79b          	srliw	a5,a5,0x4
    80003d7a:	0001d597          	auipc	a1,0x1d
    80003d7e:	3365a583          	lw	a1,822(a1) # 800210b0 <sb+0x18>
    80003d82:	9dbd                	addw	a1,a1,a5
    80003d84:	4088                	lw	a0,0(s1)
    80003d86:	fffff097          	auipc	ra,0xfffff
    80003d8a:	794080e7          	jalr	1940(ra) # 8000351a <bread>
    80003d8e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003d90:	05850593          	addi	a1,a0,88
    80003d94:	40dc                	lw	a5,4(s1)
    80003d96:	8bbd                	andi	a5,a5,15
    80003d98:	079a                	slli	a5,a5,0x6
    80003d9a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003d9c:	00059783          	lh	a5,0(a1)
    80003da0:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003da4:	00259783          	lh	a5,2(a1)
    80003da8:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003dac:	00459783          	lh	a5,4(a1)
    80003db0:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003db4:	00659783          	lh	a5,6(a1)
    80003db8:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003dbc:	459c                	lw	a5,8(a1)
    80003dbe:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003dc0:	03400613          	li	a2,52
    80003dc4:	05b1                	addi	a1,a1,12
    80003dc6:	05048513          	addi	a0,s1,80
    80003dca:	ffffd097          	auipc	ra,0xffffd
    80003dce:	f7c080e7          	jalr	-132(ra) # 80000d46 <memmove>
    brelse(bp);
    80003dd2:	854a                	mv	a0,s2
    80003dd4:	00000097          	auipc	ra,0x0
    80003dd8:	876080e7          	jalr	-1930(ra) # 8000364a <brelse>
    ip->valid = 1;
    80003ddc:	4785                	li	a5,1
    80003dde:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003de0:	04449783          	lh	a5,68(s1)
    80003de4:	fbb5                	bnez	a5,80003d58 <ilock+0x24>
      panic("ilock: no type");
    80003de6:	00005517          	auipc	a0,0x5
    80003dea:	94250513          	addi	a0,a0,-1726 # 80008728 <syscallnum+0x148>
    80003dee:	ffffc097          	auipc	ra,0xffffc
    80003df2:	756080e7          	jalr	1878(ra) # 80000544 <panic>

0000000080003df6 <iunlock>:
{
    80003df6:	1101                	addi	sp,sp,-32
    80003df8:	ec06                	sd	ra,24(sp)
    80003dfa:	e822                	sd	s0,16(sp)
    80003dfc:	e426                	sd	s1,8(sp)
    80003dfe:	e04a                	sd	s2,0(sp)
    80003e00:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003e02:	c905                	beqz	a0,80003e32 <iunlock+0x3c>
    80003e04:	84aa                	mv	s1,a0
    80003e06:	01050913          	addi	s2,a0,16
    80003e0a:	854a                	mv	a0,s2
    80003e0c:	00001097          	auipc	ra,0x1
    80003e10:	c7c080e7          	jalr	-900(ra) # 80004a88 <holdingsleep>
    80003e14:	cd19                	beqz	a0,80003e32 <iunlock+0x3c>
    80003e16:	449c                	lw	a5,8(s1)
    80003e18:	00f05d63          	blez	a5,80003e32 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003e1c:	854a                	mv	a0,s2
    80003e1e:	00001097          	auipc	ra,0x1
    80003e22:	c26080e7          	jalr	-986(ra) # 80004a44 <releasesleep>
}
    80003e26:	60e2                	ld	ra,24(sp)
    80003e28:	6442                	ld	s0,16(sp)
    80003e2a:	64a2                	ld	s1,8(sp)
    80003e2c:	6902                	ld	s2,0(sp)
    80003e2e:	6105                	addi	sp,sp,32
    80003e30:	8082                	ret
    panic("iunlock");
    80003e32:	00005517          	auipc	a0,0x5
    80003e36:	90650513          	addi	a0,a0,-1786 # 80008738 <syscallnum+0x158>
    80003e3a:	ffffc097          	auipc	ra,0xffffc
    80003e3e:	70a080e7          	jalr	1802(ra) # 80000544 <panic>

0000000080003e42 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003e42:	7179                	addi	sp,sp,-48
    80003e44:	f406                	sd	ra,40(sp)
    80003e46:	f022                	sd	s0,32(sp)
    80003e48:	ec26                	sd	s1,24(sp)
    80003e4a:	e84a                	sd	s2,16(sp)
    80003e4c:	e44e                	sd	s3,8(sp)
    80003e4e:	e052                	sd	s4,0(sp)
    80003e50:	1800                	addi	s0,sp,48
    80003e52:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003e54:	05050493          	addi	s1,a0,80
    80003e58:	08050913          	addi	s2,a0,128
    80003e5c:	a021                	j	80003e64 <itrunc+0x22>
    80003e5e:	0491                	addi	s1,s1,4
    80003e60:	01248d63          	beq	s1,s2,80003e7a <itrunc+0x38>
    if(ip->addrs[i]){
    80003e64:	408c                	lw	a1,0(s1)
    80003e66:	dde5                	beqz	a1,80003e5e <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003e68:	0009a503          	lw	a0,0(s3)
    80003e6c:	00000097          	auipc	ra,0x0
    80003e70:	8f4080e7          	jalr	-1804(ra) # 80003760 <bfree>
      ip->addrs[i] = 0;
    80003e74:	0004a023          	sw	zero,0(s1)
    80003e78:	b7dd                	j	80003e5e <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003e7a:	0809a583          	lw	a1,128(s3)
    80003e7e:	e185                	bnez	a1,80003e9e <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003e80:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003e84:	854e                	mv	a0,s3
    80003e86:	00000097          	auipc	ra,0x0
    80003e8a:	de4080e7          	jalr	-540(ra) # 80003c6a <iupdate>
}
    80003e8e:	70a2                	ld	ra,40(sp)
    80003e90:	7402                	ld	s0,32(sp)
    80003e92:	64e2                	ld	s1,24(sp)
    80003e94:	6942                	ld	s2,16(sp)
    80003e96:	69a2                	ld	s3,8(sp)
    80003e98:	6a02                	ld	s4,0(sp)
    80003e9a:	6145                	addi	sp,sp,48
    80003e9c:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003e9e:	0009a503          	lw	a0,0(s3)
    80003ea2:	fffff097          	auipc	ra,0xfffff
    80003ea6:	678080e7          	jalr	1656(ra) # 8000351a <bread>
    80003eaa:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003eac:	05850493          	addi	s1,a0,88
    80003eb0:	45850913          	addi	s2,a0,1112
    80003eb4:	a811                	j	80003ec8 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003eb6:	0009a503          	lw	a0,0(s3)
    80003eba:	00000097          	auipc	ra,0x0
    80003ebe:	8a6080e7          	jalr	-1882(ra) # 80003760 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003ec2:	0491                	addi	s1,s1,4
    80003ec4:	01248563          	beq	s1,s2,80003ece <itrunc+0x8c>
      if(a[j])
    80003ec8:	408c                	lw	a1,0(s1)
    80003eca:	dde5                	beqz	a1,80003ec2 <itrunc+0x80>
    80003ecc:	b7ed                	j	80003eb6 <itrunc+0x74>
    brelse(bp);
    80003ece:	8552                	mv	a0,s4
    80003ed0:	fffff097          	auipc	ra,0xfffff
    80003ed4:	77a080e7          	jalr	1914(ra) # 8000364a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003ed8:	0809a583          	lw	a1,128(s3)
    80003edc:	0009a503          	lw	a0,0(s3)
    80003ee0:	00000097          	auipc	ra,0x0
    80003ee4:	880080e7          	jalr	-1920(ra) # 80003760 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003ee8:	0809a023          	sw	zero,128(s3)
    80003eec:	bf51                	j	80003e80 <itrunc+0x3e>

0000000080003eee <iput>:
{
    80003eee:	1101                	addi	sp,sp,-32
    80003ef0:	ec06                	sd	ra,24(sp)
    80003ef2:	e822                	sd	s0,16(sp)
    80003ef4:	e426                	sd	s1,8(sp)
    80003ef6:	e04a                	sd	s2,0(sp)
    80003ef8:	1000                	addi	s0,sp,32
    80003efa:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003efc:	0001d517          	auipc	a0,0x1d
    80003f00:	1bc50513          	addi	a0,a0,444 # 800210b8 <itable>
    80003f04:	ffffd097          	auipc	ra,0xffffd
    80003f08:	ce6080e7          	jalr	-794(ra) # 80000bea <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003f0c:	4498                	lw	a4,8(s1)
    80003f0e:	4785                	li	a5,1
    80003f10:	02f70363          	beq	a4,a5,80003f36 <iput+0x48>
  ip->ref--;
    80003f14:	449c                	lw	a5,8(s1)
    80003f16:	37fd                	addiw	a5,a5,-1
    80003f18:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003f1a:	0001d517          	auipc	a0,0x1d
    80003f1e:	19e50513          	addi	a0,a0,414 # 800210b8 <itable>
    80003f22:	ffffd097          	auipc	ra,0xffffd
    80003f26:	d7c080e7          	jalr	-644(ra) # 80000c9e <release>
}
    80003f2a:	60e2                	ld	ra,24(sp)
    80003f2c:	6442                	ld	s0,16(sp)
    80003f2e:	64a2                	ld	s1,8(sp)
    80003f30:	6902                	ld	s2,0(sp)
    80003f32:	6105                	addi	sp,sp,32
    80003f34:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003f36:	40bc                	lw	a5,64(s1)
    80003f38:	dff1                	beqz	a5,80003f14 <iput+0x26>
    80003f3a:	04a49783          	lh	a5,74(s1)
    80003f3e:	fbf9                	bnez	a5,80003f14 <iput+0x26>
    acquiresleep(&ip->lock);
    80003f40:	01048913          	addi	s2,s1,16
    80003f44:	854a                	mv	a0,s2
    80003f46:	00001097          	auipc	ra,0x1
    80003f4a:	aa8080e7          	jalr	-1368(ra) # 800049ee <acquiresleep>
    release(&itable.lock);
    80003f4e:	0001d517          	auipc	a0,0x1d
    80003f52:	16a50513          	addi	a0,a0,362 # 800210b8 <itable>
    80003f56:	ffffd097          	auipc	ra,0xffffd
    80003f5a:	d48080e7          	jalr	-696(ra) # 80000c9e <release>
    itrunc(ip);
    80003f5e:	8526                	mv	a0,s1
    80003f60:	00000097          	auipc	ra,0x0
    80003f64:	ee2080e7          	jalr	-286(ra) # 80003e42 <itrunc>
    ip->type = 0;
    80003f68:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003f6c:	8526                	mv	a0,s1
    80003f6e:	00000097          	auipc	ra,0x0
    80003f72:	cfc080e7          	jalr	-772(ra) # 80003c6a <iupdate>
    ip->valid = 0;
    80003f76:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003f7a:	854a                	mv	a0,s2
    80003f7c:	00001097          	auipc	ra,0x1
    80003f80:	ac8080e7          	jalr	-1336(ra) # 80004a44 <releasesleep>
    acquire(&itable.lock);
    80003f84:	0001d517          	auipc	a0,0x1d
    80003f88:	13450513          	addi	a0,a0,308 # 800210b8 <itable>
    80003f8c:	ffffd097          	auipc	ra,0xffffd
    80003f90:	c5e080e7          	jalr	-930(ra) # 80000bea <acquire>
    80003f94:	b741                	j	80003f14 <iput+0x26>

0000000080003f96 <iunlockput>:
{
    80003f96:	1101                	addi	sp,sp,-32
    80003f98:	ec06                	sd	ra,24(sp)
    80003f9a:	e822                	sd	s0,16(sp)
    80003f9c:	e426                	sd	s1,8(sp)
    80003f9e:	1000                	addi	s0,sp,32
    80003fa0:	84aa                	mv	s1,a0
  iunlock(ip);
    80003fa2:	00000097          	auipc	ra,0x0
    80003fa6:	e54080e7          	jalr	-428(ra) # 80003df6 <iunlock>
  iput(ip);
    80003faa:	8526                	mv	a0,s1
    80003fac:	00000097          	auipc	ra,0x0
    80003fb0:	f42080e7          	jalr	-190(ra) # 80003eee <iput>
}
    80003fb4:	60e2                	ld	ra,24(sp)
    80003fb6:	6442                	ld	s0,16(sp)
    80003fb8:	64a2                	ld	s1,8(sp)
    80003fba:	6105                	addi	sp,sp,32
    80003fbc:	8082                	ret

0000000080003fbe <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003fbe:	1141                	addi	sp,sp,-16
    80003fc0:	e422                	sd	s0,8(sp)
    80003fc2:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003fc4:	411c                	lw	a5,0(a0)
    80003fc6:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003fc8:	415c                	lw	a5,4(a0)
    80003fca:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003fcc:	04451783          	lh	a5,68(a0)
    80003fd0:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003fd4:	04a51783          	lh	a5,74(a0)
    80003fd8:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003fdc:	04c56783          	lwu	a5,76(a0)
    80003fe0:	e99c                	sd	a5,16(a1)
}
    80003fe2:	6422                	ld	s0,8(sp)
    80003fe4:	0141                	addi	sp,sp,16
    80003fe6:	8082                	ret

0000000080003fe8 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003fe8:	457c                	lw	a5,76(a0)
    80003fea:	0ed7e963          	bltu	a5,a3,800040dc <readi+0xf4>
{
    80003fee:	7159                	addi	sp,sp,-112
    80003ff0:	f486                	sd	ra,104(sp)
    80003ff2:	f0a2                	sd	s0,96(sp)
    80003ff4:	eca6                	sd	s1,88(sp)
    80003ff6:	e8ca                	sd	s2,80(sp)
    80003ff8:	e4ce                	sd	s3,72(sp)
    80003ffa:	e0d2                	sd	s4,64(sp)
    80003ffc:	fc56                	sd	s5,56(sp)
    80003ffe:	f85a                	sd	s6,48(sp)
    80004000:	f45e                	sd	s7,40(sp)
    80004002:	f062                	sd	s8,32(sp)
    80004004:	ec66                	sd	s9,24(sp)
    80004006:	e86a                	sd	s10,16(sp)
    80004008:	e46e                	sd	s11,8(sp)
    8000400a:	1880                	addi	s0,sp,112
    8000400c:	8b2a                	mv	s6,a0
    8000400e:	8bae                	mv	s7,a1
    80004010:	8a32                	mv	s4,a2
    80004012:	84b6                	mv	s1,a3
    80004014:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80004016:	9f35                	addw	a4,a4,a3
    return 0;
    80004018:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000401a:	0ad76063          	bltu	a4,a3,800040ba <readi+0xd2>
  if(off + n > ip->size)
    8000401e:	00e7f463          	bgeu	a5,a4,80004026 <readi+0x3e>
    n = ip->size - off;
    80004022:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004026:	0a0a8963          	beqz	s5,800040d8 <readi+0xf0>
    8000402a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000402c:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004030:	5c7d                	li	s8,-1
    80004032:	a82d                	j	8000406c <readi+0x84>
    80004034:	020d1d93          	slli	s11,s10,0x20
    80004038:	020ddd93          	srli	s11,s11,0x20
    8000403c:	05890613          	addi	a2,s2,88
    80004040:	86ee                	mv	a3,s11
    80004042:	963a                	add	a2,a2,a4
    80004044:	85d2                	mv	a1,s4
    80004046:	855e                	mv	a0,s7
    80004048:	ffffe097          	auipc	ra,0xffffe
    8000404c:	7e4080e7          	jalr	2020(ra) # 8000282c <either_copyout>
    80004050:	05850d63          	beq	a0,s8,800040aa <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004054:	854a                	mv	a0,s2
    80004056:	fffff097          	auipc	ra,0xfffff
    8000405a:	5f4080e7          	jalr	1524(ra) # 8000364a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000405e:	013d09bb          	addw	s3,s10,s3
    80004062:	009d04bb          	addw	s1,s10,s1
    80004066:	9a6e                	add	s4,s4,s11
    80004068:	0559f763          	bgeu	s3,s5,800040b6 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    8000406c:	00a4d59b          	srliw	a1,s1,0xa
    80004070:	855a                	mv	a0,s6
    80004072:	00000097          	auipc	ra,0x0
    80004076:	8a2080e7          	jalr	-1886(ra) # 80003914 <bmap>
    8000407a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000407e:	cd85                	beqz	a1,800040b6 <readi+0xce>
    bp = bread(ip->dev, addr);
    80004080:	000b2503          	lw	a0,0(s6)
    80004084:	fffff097          	auipc	ra,0xfffff
    80004088:	496080e7          	jalr	1174(ra) # 8000351a <bread>
    8000408c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000408e:	3ff4f713          	andi	a4,s1,1023
    80004092:	40ec87bb          	subw	a5,s9,a4
    80004096:	413a86bb          	subw	a3,s5,s3
    8000409a:	8d3e                	mv	s10,a5
    8000409c:	2781                	sext.w	a5,a5
    8000409e:	0006861b          	sext.w	a2,a3
    800040a2:	f8f679e3          	bgeu	a2,a5,80004034 <readi+0x4c>
    800040a6:	8d36                	mv	s10,a3
    800040a8:	b771                	j	80004034 <readi+0x4c>
      brelse(bp);
    800040aa:	854a                	mv	a0,s2
    800040ac:	fffff097          	auipc	ra,0xfffff
    800040b0:	59e080e7          	jalr	1438(ra) # 8000364a <brelse>
      tot = -1;
    800040b4:	59fd                	li	s3,-1
  }
  return tot;
    800040b6:	0009851b          	sext.w	a0,s3
}
    800040ba:	70a6                	ld	ra,104(sp)
    800040bc:	7406                	ld	s0,96(sp)
    800040be:	64e6                	ld	s1,88(sp)
    800040c0:	6946                	ld	s2,80(sp)
    800040c2:	69a6                	ld	s3,72(sp)
    800040c4:	6a06                	ld	s4,64(sp)
    800040c6:	7ae2                	ld	s5,56(sp)
    800040c8:	7b42                	ld	s6,48(sp)
    800040ca:	7ba2                	ld	s7,40(sp)
    800040cc:	7c02                	ld	s8,32(sp)
    800040ce:	6ce2                	ld	s9,24(sp)
    800040d0:	6d42                	ld	s10,16(sp)
    800040d2:	6da2                	ld	s11,8(sp)
    800040d4:	6165                	addi	sp,sp,112
    800040d6:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800040d8:	89d6                	mv	s3,s5
    800040da:	bff1                	j	800040b6 <readi+0xce>
    return 0;
    800040dc:	4501                	li	a0,0
}
    800040de:	8082                	ret

00000000800040e0 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800040e0:	457c                	lw	a5,76(a0)
    800040e2:	10d7e863          	bltu	a5,a3,800041f2 <writei+0x112>
{
    800040e6:	7159                	addi	sp,sp,-112
    800040e8:	f486                	sd	ra,104(sp)
    800040ea:	f0a2                	sd	s0,96(sp)
    800040ec:	eca6                	sd	s1,88(sp)
    800040ee:	e8ca                	sd	s2,80(sp)
    800040f0:	e4ce                	sd	s3,72(sp)
    800040f2:	e0d2                	sd	s4,64(sp)
    800040f4:	fc56                	sd	s5,56(sp)
    800040f6:	f85a                	sd	s6,48(sp)
    800040f8:	f45e                	sd	s7,40(sp)
    800040fa:	f062                	sd	s8,32(sp)
    800040fc:	ec66                	sd	s9,24(sp)
    800040fe:	e86a                	sd	s10,16(sp)
    80004100:	e46e                	sd	s11,8(sp)
    80004102:	1880                	addi	s0,sp,112
    80004104:	8aaa                	mv	s5,a0
    80004106:	8bae                	mv	s7,a1
    80004108:	8a32                	mv	s4,a2
    8000410a:	8936                	mv	s2,a3
    8000410c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000410e:	00e687bb          	addw	a5,a3,a4
    80004112:	0ed7e263          	bltu	a5,a3,800041f6 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004116:	00043737          	lui	a4,0x43
    8000411a:	0ef76063          	bltu	a4,a5,800041fa <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000411e:	0c0b0863          	beqz	s6,800041ee <writei+0x10e>
    80004122:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004124:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004128:	5c7d                	li	s8,-1
    8000412a:	a091                	j	8000416e <writei+0x8e>
    8000412c:	020d1d93          	slli	s11,s10,0x20
    80004130:	020ddd93          	srli	s11,s11,0x20
    80004134:	05848513          	addi	a0,s1,88
    80004138:	86ee                	mv	a3,s11
    8000413a:	8652                	mv	a2,s4
    8000413c:	85de                	mv	a1,s7
    8000413e:	953a                	add	a0,a0,a4
    80004140:	ffffe097          	auipc	ra,0xffffe
    80004144:	742080e7          	jalr	1858(ra) # 80002882 <either_copyin>
    80004148:	07850263          	beq	a0,s8,800041ac <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000414c:	8526                	mv	a0,s1
    8000414e:	00000097          	auipc	ra,0x0
    80004152:	780080e7          	jalr	1920(ra) # 800048ce <log_write>
    brelse(bp);
    80004156:	8526                	mv	a0,s1
    80004158:	fffff097          	auipc	ra,0xfffff
    8000415c:	4f2080e7          	jalr	1266(ra) # 8000364a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004160:	013d09bb          	addw	s3,s10,s3
    80004164:	012d093b          	addw	s2,s10,s2
    80004168:	9a6e                	add	s4,s4,s11
    8000416a:	0569f663          	bgeu	s3,s6,800041b6 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    8000416e:	00a9559b          	srliw	a1,s2,0xa
    80004172:	8556                	mv	a0,s5
    80004174:	fffff097          	auipc	ra,0xfffff
    80004178:	7a0080e7          	jalr	1952(ra) # 80003914 <bmap>
    8000417c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004180:	c99d                	beqz	a1,800041b6 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80004182:	000aa503          	lw	a0,0(s5)
    80004186:	fffff097          	auipc	ra,0xfffff
    8000418a:	394080e7          	jalr	916(ra) # 8000351a <bread>
    8000418e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004190:	3ff97713          	andi	a4,s2,1023
    80004194:	40ec87bb          	subw	a5,s9,a4
    80004198:	413b06bb          	subw	a3,s6,s3
    8000419c:	8d3e                	mv	s10,a5
    8000419e:	2781                	sext.w	a5,a5
    800041a0:	0006861b          	sext.w	a2,a3
    800041a4:	f8f674e3          	bgeu	a2,a5,8000412c <writei+0x4c>
    800041a8:	8d36                	mv	s10,a3
    800041aa:	b749                	j	8000412c <writei+0x4c>
      brelse(bp);
    800041ac:	8526                	mv	a0,s1
    800041ae:	fffff097          	auipc	ra,0xfffff
    800041b2:	49c080e7          	jalr	1180(ra) # 8000364a <brelse>
  }

  if(off > ip->size)
    800041b6:	04caa783          	lw	a5,76(s5)
    800041ba:	0127f463          	bgeu	a5,s2,800041c2 <writei+0xe2>
    ip->size = off;
    800041be:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800041c2:	8556                	mv	a0,s5
    800041c4:	00000097          	auipc	ra,0x0
    800041c8:	aa6080e7          	jalr	-1370(ra) # 80003c6a <iupdate>

  return tot;
    800041cc:	0009851b          	sext.w	a0,s3
}
    800041d0:	70a6                	ld	ra,104(sp)
    800041d2:	7406                	ld	s0,96(sp)
    800041d4:	64e6                	ld	s1,88(sp)
    800041d6:	6946                	ld	s2,80(sp)
    800041d8:	69a6                	ld	s3,72(sp)
    800041da:	6a06                	ld	s4,64(sp)
    800041dc:	7ae2                	ld	s5,56(sp)
    800041de:	7b42                	ld	s6,48(sp)
    800041e0:	7ba2                	ld	s7,40(sp)
    800041e2:	7c02                	ld	s8,32(sp)
    800041e4:	6ce2                	ld	s9,24(sp)
    800041e6:	6d42                	ld	s10,16(sp)
    800041e8:	6da2                	ld	s11,8(sp)
    800041ea:	6165                	addi	sp,sp,112
    800041ec:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800041ee:	89da                	mv	s3,s6
    800041f0:	bfc9                	j	800041c2 <writei+0xe2>
    return -1;
    800041f2:	557d                	li	a0,-1
}
    800041f4:	8082                	ret
    return -1;
    800041f6:	557d                	li	a0,-1
    800041f8:	bfe1                	j	800041d0 <writei+0xf0>
    return -1;
    800041fa:	557d                	li	a0,-1
    800041fc:	bfd1                	j	800041d0 <writei+0xf0>

00000000800041fe <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800041fe:	1141                	addi	sp,sp,-16
    80004200:	e406                	sd	ra,8(sp)
    80004202:	e022                	sd	s0,0(sp)
    80004204:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004206:	4639                	li	a2,14
    80004208:	ffffd097          	auipc	ra,0xffffd
    8000420c:	bb6080e7          	jalr	-1098(ra) # 80000dbe <strncmp>
}
    80004210:	60a2                	ld	ra,8(sp)
    80004212:	6402                	ld	s0,0(sp)
    80004214:	0141                	addi	sp,sp,16
    80004216:	8082                	ret

0000000080004218 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004218:	7139                	addi	sp,sp,-64
    8000421a:	fc06                	sd	ra,56(sp)
    8000421c:	f822                	sd	s0,48(sp)
    8000421e:	f426                	sd	s1,40(sp)
    80004220:	f04a                	sd	s2,32(sp)
    80004222:	ec4e                	sd	s3,24(sp)
    80004224:	e852                	sd	s4,16(sp)
    80004226:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004228:	04451703          	lh	a4,68(a0)
    8000422c:	4785                	li	a5,1
    8000422e:	00f71a63          	bne	a4,a5,80004242 <dirlookup+0x2a>
    80004232:	892a                	mv	s2,a0
    80004234:	89ae                	mv	s3,a1
    80004236:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004238:	457c                	lw	a5,76(a0)
    8000423a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000423c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000423e:	e79d                	bnez	a5,8000426c <dirlookup+0x54>
    80004240:	a8a5                	j	800042b8 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004242:	00004517          	auipc	a0,0x4
    80004246:	4fe50513          	addi	a0,a0,1278 # 80008740 <syscallnum+0x160>
    8000424a:	ffffc097          	auipc	ra,0xffffc
    8000424e:	2fa080e7          	jalr	762(ra) # 80000544 <panic>
      panic("dirlookup read");
    80004252:	00004517          	auipc	a0,0x4
    80004256:	50650513          	addi	a0,a0,1286 # 80008758 <syscallnum+0x178>
    8000425a:	ffffc097          	auipc	ra,0xffffc
    8000425e:	2ea080e7          	jalr	746(ra) # 80000544 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004262:	24c1                	addiw	s1,s1,16
    80004264:	04c92783          	lw	a5,76(s2)
    80004268:	04f4f763          	bgeu	s1,a5,800042b6 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000426c:	4741                	li	a4,16
    8000426e:	86a6                	mv	a3,s1
    80004270:	fc040613          	addi	a2,s0,-64
    80004274:	4581                	li	a1,0
    80004276:	854a                	mv	a0,s2
    80004278:	00000097          	auipc	ra,0x0
    8000427c:	d70080e7          	jalr	-656(ra) # 80003fe8 <readi>
    80004280:	47c1                	li	a5,16
    80004282:	fcf518e3          	bne	a0,a5,80004252 <dirlookup+0x3a>
    if(de.inum == 0)
    80004286:	fc045783          	lhu	a5,-64(s0)
    8000428a:	dfe1                	beqz	a5,80004262 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000428c:	fc240593          	addi	a1,s0,-62
    80004290:	854e                	mv	a0,s3
    80004292:	00000097          	auipc	ra,0x0
    80004296:	f6c080e7          	jalr	-148(ra) # 800041fe <namecmp>
    8000429a:	f561                	bnez	a0,80004262 <dirlookup+0x4a>
      if(poff)
    8000429c:	000a0463          	beqz	s4,800042a4 <dirlookup+0x8c>
        *poff = off;
    800042a0:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800042a4:	fc045583          	lhu	a1,-64(s0)
    800042a8:	00092503          	lw	a0,0(s2)
    800042ac:	fffff097          	auipc	ra,0xfffff
    800042b0:	750080e7          	jalr	1872(ra) # 800039fc <iget>
    800042b4:	a011                	j	800042b8 <dirlookup+0xa0>
  return 0;
    800042b6:	4501                	li	a0,0
}
    800042b8:	70e2                	ld	ra,56(sp)
    800042ba:	7442                	ld	s0,48(sp)
    800042bc:	74a2                	ld	s1,40(sp)
    800042be:	7902                	ld	s2,32(sp)
    800042c0:	69e2                	ld	s3,24(sp)
    800042c2:	6a42                	ld	s4,16(sp)
    800042c4:	6121                	addi	sp,sp,64
    800042c6:	8082                	ret

00000000800042c8 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800042c8:	711d                	addi	sp,sp,-96
    800042ca:	ec86                	sd	ra,88(sp)
    800042cc:	e8a2                	sd	s0,80(sp)
    800042ce:	e4a6                	sd	s1,72(sp)
    800042d0:	e0ca                	sd	s2,64(sp)
    800042d2:	fc4e                	sd	s3,56(sp)
    800042d4:	f852                	sd	s4,48(sp)
    800042d6:	f456                	sd	s5,40(sp)
    800042d8:	f05a                	sd	s6,32(sp)
    800042da:	ec5e                	sd	s7,24(sp)
    800042dc:	e862                	sd	s8,16(sp)
    800042de:	e466                	sd	s9,8(sp)
    800042e0:	1080                	addi	s0,sp,96
    800042e2:	84aa                	mv	s1,a0
    800042e4:	8b2e                	mv	s6,a1
    800042e6:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800042e8:	00054703          	lbu	a4,0(a0)
    800042ec:	02f00793          	li	a5,47
    800042f0:	02f70363          	beq	a4,a5,80004316 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800042f4:	ffffd097          	auipc	ra,0xffffd
    800042f8:	6d2080e7          	jalr	1746(ra) # 800019c6 <myproc>
    800042fc:	15053503          	ld	a0,336(a0)
    80004300:	00000097          	auipc	ra,0x0
    80004304:	9f6080e7          	jalr	-1546(ra) # 80003cf6 <idup>
    80004308:	89aa                	mv	s3,a0
  while(*path == '/')
    8000430a:	02f00913          	li	s2,47
  len = path - s;
    8000430e:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80004310:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004312:	4c05                	li	s8,1
    80004314:	a865                	j	800043cc <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004316:	4585                	li	a1,1
    80004318:	4505                	li	a0,1
    8000431a:	fffff097          	auipc	ra,0xfffff
    8000431e:	6e2080e7          	jalr	1762(ra) # 800039fc <iget>
    80004322:	89aa                	mv	s3,a0
    80004324:	b7dd                	j	8000430a <namex+0x42>
      iunlockput(ip);
    80004326:	854e                	mv	a0,s3
    80004328:	00000097          	auipc	ra,0x0
    8000432c:	c6e080e7          	jalr	-914(ra) # 80003f96 <iunlockput>
      return 0;
    80004330:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004332:	854e                	mv	a0,s3
    80004334:	60e6                	ld	ra,88(sp)
    80004336:	6446                	ld	s0,80(sp)
    80004338:	64a6                	ld	s1,72(sp)
    8000433a:	6906                	ld	s2,64(sp)
    8000433c:	79e2                	ld	s3,56(sp)
    8000433e:	7a42                	ld	s4,48(sp)
    80004340:	7aa2                	ld	s5,40(sp)
    80004342:	7b02                	ld	s6,32(sp)
    80004344:	6be2                	ld	s7,24(sp)
    80004346:	6c42                	ld	s8,16(sp)
    80004348:	6ca2                	ld	s9,8(sp)
    8000434a:	6125                	addi	sp,sp,96
    8000434c:	8082                	ret
      iunlock(ip);
    8000434e:	854e                	mv	a0,s3
    80004350:	00000097          	auipc	ra,0x0
    80004354:	aa6080e7          	jalr	-1370(ra) # 80003df6 <iunlock>
      return ip;
    80004358:	bfe9                	j	80004332 <namex+0x6a>
      iunlockput(ip);
    8000435a:	854e                	mv	a0,s3
    8000435c:	00000097          	auipc	ra,0x0
    80004360:	c3a080e7          	jalr	-966(ra) # 80003f96 <iunlockput>
      return 0;
    80004364:	89d2                	mv	s3,s4
    80004366:	b7f1                	j	80004332 <namex+0x6a>
  len = path - s;
    80004368:	40b48633          	sub	a2,s1,a1
    8000436c:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80004370:	094cd463          	bge	s9,s4,800043f8 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004374:	4639                	li	a2,14
    80004376:	8556                	mv	a0,s5
    80004378:	ffffd097          	auipc	ra,0xffffd
    8000437c:	9ce080e7          	jalr	-1586(ra) # 80000d46 <memmove>
  while(*path == '/')
    80004380:	0004c783          	lbu	a5,0(s1)
    80004384:	01279763          	bne	a5,s2,80004392 <namex+0xca>
    path++;
    80004388:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000438a:	0004c783          	lbu	a5,0(s1)
    8000438e:	ff278de3          	beq	a5,s2,80004388 <namex+0xc0>
    ilock(ip);
    80004392:	854e                	mv	a0,s3
    80004394:	00000097          	auipc	ra,0x0
    80004398:	9a0080e7          	jalr	-1632(ra) # 80003d34 <ilock>
    if(ip->type != T_DIR){
    8000439c:	04499783          	lh	a5,68(s3)
    800043a0:	f98793e3          	bne	a5,s8,80004326 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800043a4:	000b0563          	beqz	s6,800043ae <namex+0xe6>
    800043a8:	0004c783          	lbu	a5,0(s1)
    800043ac:	d3cd                	beqz	a5,8000434e <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800043ae:	865e                	mv	a2,s7
    800043b0:	85d6                	mv	a1,s5
    800043b2:	854e                	mv	a0,s3
    800043b4:	00000097          	auipc	ra,0x0
    800043b8:	e64080e7          	jalr	-412(ra) # 80004218 <dirlookup>
    800043bc:	8a2a                	mv	s4,a0
    800043be:	dd51                	beqz	a0,8000435a <namex+0x92>
    iunlockput(ip);
    800043c0:	854e                	mv	a0,s3
    800043c2:	00000097          	auipc	ra,0x0
    800043c6:	bd4080e7          	jalr	-1068(ra) # 80003f96 <iunlockput>
    ip = next;
    800043ca:	89d2                	mv	s3,s4
  while(*path == '/')
    800043cc:	0004c783          	lbu	a5,0(s1)
    800043d0:	05279763          	bne	a5,s2,8000441e <namex+0x156>
    path++;
    800043d4:	0485                	addi	s1,s1,1
  while(*path == '/')
    800043d6:	0004c783          	lbu	a5,0(s1)
    800043da:	ff278de3          	beq	a5,s2,800043d4 <namex+0x10c>
  if(*path == 0)
    800043de:	c79d                	beqz	a5,8000440c <namex+0x144>
    path++;
    800043e0:	85a6                	mv	a1,s1
  len = path - s;
    800043e2:	8a5e                	mv	s4,s7
    800043e4:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    800043e6:	01278963          	beq	a5,s2,800043f8 <namex+0x130>
    800043ea:	dfbd                	beqz	a5,80004368 <namex+0xa0>
    path++;
    800043ec:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800043ee:	0004c783          	lbu	a5,0(s1)
    800043f2:	ff279ce3          	bne	a5,s2,800043ea <namex+0x122>
    800043f6:	bf8d                	j	80004368 <namex+0xa0>
    memmove(name, s, len);
    800043f8:	2601                	sext.w	a2,a2
    800043fa:	8556                	mv	a0,s5
    800043fc:	ffffd097          	auipc	ra,0xffffd
    80004400:	94a080e7          	jalr	-1718(ra) # 80000d46 <memmove>
    name[len] = 0;
    80004404:	9a56                	add	s4,s4,s5
    80004406:	000a0023          	sb	zero,0(s4)
    8000440a:	bf9d                	j	80004380 <namex+0xb8>
  if(nameiparent){
    8000440c:	f20b03e3          	beqz	s6,80004332 <namex+0x6a>
    iput(ip);
    80004410:	854e                	mv	a0,s3
    80004412:	00000097          	auipc	ra,0x0
    80004416:	adc080e7          	jalr	-1316(ra) # 80003eee <iput>
    return 0;
    8000441a:	4981                	li	s3,0
    8000441c:	bf19                	j	80004332 <namex+0x6a>
  if(*path == 0)
    8000441e:	d7fd                	beqz	a5,8000440c <namex+0x144>
  while(*path != '/' && *path != 0)
    80004420:	0004c783          	lbu	a5,0(s1)
    80004424:	85a6                	mv	a1,s1
    80004426:	b7d1                	j	800043ea <namex+0x122>

0000000080004428 <dirlink>:
{
    80004428:	7139                	addi	sp,sp,-64
    8000442a:	fc06                	sd	ra,56(sp)
    8000442c:	f822                	sd	s0,48(sp)
    8000442e:	f426                	sd	s1,40(sp)
    80004430:	f04a                	sd	s2,32(sp)
    80004432:	ec4e                	sd	s3,24(sp)
    80004434:	e852                	sd	s4,16(sp)
    80004436:	0080                	addi	s0,sp,64
    80004438:	892a                	mv	s2,a0
    8000443a:	8a2e                	mv	s4,a1
    8000443c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000443e:	4601                	li	a2,0
    80004440:	00000097          	auipc	ra,0x0
    80004444:	dd8080e7          	jalr	-552(ra) # 80004218 <dirlookup>
    80004448:	e93d                	bnez	a0,800044be <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000444a:	04c92483          	lw	s1,76(s2)
    8000444e:	c49d                	beqz	s1,8000447c <dirlink+0x54>
    80004450:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004452:	4741                	li	a4,16
    80004454:	86a6                	mv	a3,s1
    80004456:	fc040613          	addi	a2,s0,-64
    8000445a:	4581                	li	a1,0
    8000445c:	854a                	mv	a0,s2
    8000445e:	00000097          	auipc	ra,0x0
    80004462:	b8a080e7          	jalr	-1142(ra) # 80003fe8 <readi>
    80004466:	47c1                	li	a5,16
    80004468:	06f51163          	bne	a0,a5,800044ca <dirlink+0xa2>
    if(de.inum == 0)
    8000446c:	fc045783          	lhu	a5,-64(s0)
    80004470:	c791                	beqz	a5,8000447c <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004472:	24c1                	addiw	s1,s1,16
    80004474:	04c92783          	lw	a5,76(s2)
    80004478:	fcf4ede3          	bltu	s1,a5,80004452 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000447c:	4639                	li	a2,14
    8000447e:	85d2                	mv	a1,s4
    80004480:	fc240513          	addi	a0,s0,-62
    80004484:	ffffd097          	auipc	ra,0xffffd
    80004488:	976080e7          	jalr	-1674(ra) # 80000dfa <strncpy>
  de.inum = inum;
    8000448c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004490:	4741                	li	a4,16
    80004492:	86a6                	mv	a3,s1
    80004494:	fc040613          	addi	a2,s0,-64
    80004498:	4581                	li	a1,0
    8000449a:	854a                	mv	a0,s2
    8000449c:	00000097          	auipc	ra,0x0
    800044a0:	c44080e7          	jalr	-956(ra) # 800040e0 <writei>
    800044a4:	1541                	addi	a0,a0,-16
    800044a6:	00a03533          	snez	a0,a0
    800044aa:	40a00533          	neg	a0,a0
}
    800044ae:	70e2                	ld	ra,56(sp)
    800044b0:	7442                	ld	s0,48(sp)
    800044b2:	74a2                	ld	s1,40(sp)
    800044b4:	7902                	ld	s2,32(sp)
    800044b6:	69e2                	ld	s3,24(sp)
    800044b8:	6a42                	ld	s4,16(sp)
    800044ba:	6121                	addi	sp,sp,64
    800044bc:	8082                	ret
    iput(ip);
    800044be:	00000097          	auipc	ra,0x0
    800044c2:	a30080e7          	jalr	-1488(ra) # 80003eee <iput>
    return -1;
    800044c6:	557d                	li	a0,-1
    800044c8:	b7dd                	j	800044ae <dirlink+0x86>
      panic("dirlink read");
    800044ca:	00004517          	auipc	a0,0x4
    800044ce:	29e50513          	addi	a0,a0,670 # 80008768 <syscallnum+0x188>
    800044d2:	ffffc097          	auipc	ra,0xffffc
    800044d6:	072080e7          	jalr	114(ra) # 80000544 <panic>

00000000800044da <namei>:

struct inode*
namei(char *path)
{
    800044da:	1101                	addi	sp,sp,-32
    800044dc:	ec06                	sd	ra,24(sp)
    800044de:	e822                	sd	s0,16(sp)
    800044e0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800044e2:	fe040613          	addi	a2,s0,-32
    800044e6:	4581                	li	a1,0
    800044e8:	00000097          	auipc	ra,0x0
    800044ec:	de0080e7          	jalr	-544(ra) # 800042c8 <namex>
}
    800044f0:	60e2                	ld	ra,24(sp)
    800044f2:	6442                	ld	s0,16(sp)
    800044f4:	6105                	addi	sp,sp,32
    800044f6:	8082                	ret

00000000800044f8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800044f8:	1141                	addi	sp,sp,-16
    800044fa:	e406                	sd	ra,8(sp)
    800044fc:	e022                	sd	s0,0(sp)
    800044fe:	0800                	addi	s0,sp,16
    80004500:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004502:	4585                	li	a1,1
    80004504:	00000097          	auipc	ra,0x0
    80004508:	dc4080e7          	jalr	-572(ra) # 800042c8 <namex>
}
    8000450c:	60a2                	ld	ra,8(sp)
    8000450e:	6402                	ld	s0,0(sp)
    80004510:	0141                	addi	sp,sp,16
    80004512:	8082                	ret

0000000080004514 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004514:	1101                	addi	sp,sp,-32
    80004516:	ec06                	sd	ra,24(sp)
    80004518:	e822                	sd	s0,16(sp)
    8000451a:	e426                	sd	s1,8(sp)
    8000451c:	e04a                	sd	s2,0(sp)
    8000451e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004520:	0001e917          	auipc	s2,0x1e
    80004524:	64090913          	addi	s2,s2,1600 # 80022b60 <log>
    80004528:	01892583          	lw	a1,24(s2)
    8000452c:	02892503          	lw	a0,40(s2)
    80004530:	fffff097          	auipc	ra,0xfffff
    80004534:	fea080e7          	jalr	-22(ra) # 8000351a <bread>
    80004538:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000453a:	02c92683          	lw	a3,44(s2)
    8000453e:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004540:	02d05763          	blez	a3,8000456e <write_head+0x5a>
    80004544:	0001e797          	auipc	a5,0x1e
    80004548:	64c78793          	addi	a5,a5,1612 # 80022b90 <log+0x30>
    8000454c:	05c50713          	addi	a4,a0,92
    80004550:	36fd                	addiw	a3,a3,-1
    80004552:	1682                	slli	a3,a3,0x20
    80004554:	9281                	srli	a3,a3,0x20
    80004556:	068a                	slli	a3,a3,0x2
    80004558:	0001e617          	auipc	a2,0x1e
    8000455c:	63c60613          	addi	a2,a2,1596 # 80022b94 <log+0x34>
    80004560:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004562:	4390                	lw	a2,0(a5)
    80004564:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004566:	0791                	addi	a5,a5,4
    80004568:	0711                	addi	a4,a4,4
    8000456a:	fed79ce3          	bne	a5,a3,80004562 <write_head+0x4e>
  }
  bwrite(buf);
    8000456e:	8526                	mv	a0,s1
    80004570:	fffff097          	auipc	ra,0xfffff
    80004574:	09c080e7          	jalr	156(ra) # 8000360c <bwrite>
  brelse(buf);
    80004578:	8526                	mv	a0,s1
    8000457a:	fffff097          	auipc	ra,0xfffff
    8000457e:	0d0080e7          	jalr	208(ra) # 8000364a <brelse>
}
    80004582:	60e2                	ld	ra,24(sp)
    80004584:	6442                	ld	s0,16(sp)
    80004586:	64a2                	ld	s1,8(sp)
    80004588:	6902                	ld	s2,0(sp)
    8000458a:	6105                	addi	sp,sp,32
    8000458c:	8082                	ret

000000008000458e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000458e:	0001e797          	auipc	a5,0x1e
    80004592:	5fe7a783          	lw	a5,1534(a5) # 80022b8c <log+0x2c>
    80004596:	0af05d63          	blez	a5,80004650 <install_trans+0xc2>
{
    8000459a:	7139                	addi	sp,sp,-64
    8000459c:	fc06                	sd	ra,56(sp)
    8000459e:	f822                	sd	s0,48(sp)
    800045a0:	f426                	sd	s1,40(sp)
    800045a2:	f04a                	sd	s2,32(sp)
    800045a4:	ec4e                	sd	s3,24(sp)
    800045a6:	e852                	sd	s4,16(sp)
    800045a8:	e456                	sd	s5,8(sp)
    800045aa:	e05a                	sd	s6,0(sp)
    800045ac:	0080                	addi	s0,sp,64
    800045ae:	8b2a                	mv	s6,a0
    800045b0:	0001ea97          	auipc	s5,0x1e
    800045b4:	5e0a8a93          	addi	s5,s5,1504 # 80022b90 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800045b8:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800045ba:	0001e997          	auipc	s3,0x1e
    800045be:	5a698993          	addi	s3,s3,1446 # 80022b60 <log>
    800045c2:	a035                	j	800045ee <install_trans+0x60>
      bunpin(dbuf);
    800045c4:	8526                	mv	a0,s1
    800045c6:	fffff097          	auipc	ra,0xfffff
    800045ca:	15e080e7          	jalr	350(ra) # 80003724 <bunpin>
    brelse(lbuf);
    800045ce:	854a                	mv	a0,s2
    800045d0:	fffff097          	auipc	ra,0xfffff
    800045d4:	07a080e7          	jalr	122(ra) # 8000364a <brelse>
    brelse(dbuf);
    800045d8:	8526                	mv	a0,s1
    800045da:	fffff097          	auipc	ra,0xfffff
    800045de:	070080e7          	jalr	112(ra) # 8000364a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800045e2:	2a05                	addiw	s4,s4,1
    800045e4:	0a91                	addi	s5,s5,4
    800045e6:	02c9a783          	lw	a5,44(s3)
    800045ea:	04fa5963          	bge	s4,a5,8000463c <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800045ee:	0189a583          	lw	a1,24(s3)
    800045f2:	014585bb          	addw	a1,a1,s4
    800045f6:	2585                	addiw	a1,a1,1
    800045f8:	0289a503          	lw	a0,40(s3)
    800045fc:	fffff097          	auipc	ra,0xfffff
    80004600:	f1e080e7          	jalr	-226(ra) # 8000351a <bread>
    80004604:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004606:	000aa583          	lw	a1,0(s5)
    8000460a:	0289a503          	lw	a0,40(s3)
    8000460e:	fffff097          	auipc	ra,0xfffff
    80004612:	f0c080e7          	jalr	-244(ra) # 8000351a <bread>
    80004616:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004618:	40000613          	li	a2,1024
    8000461c:	05890593          	addi	a1,s2,88
    80004620:	05850513          	addi	a0,a0,88
    80004624:	ffffc097          	auipc	ra,0xffffc
    80004628:	722080e7          	jalr	1826(ra) # 80000d46 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000462c:	8526                	mv	a0,s1
    8000462e:	fffff097          	auipc	ra,0xfffff
    80004632:	fde080e7          	jalr	-34(ra) # 8000360c <bwrite>
    if(recovering == 0)
    80004636:	f80b1ce3          	bnez	s6,800045ce <install_trans+0x40>
    8000463a:	b769                	j	800045c4 <install_trans+0x36>
}
    8000463c:	70e2                	ld	ra,56(sp)
    8000463e:	7442                	ld	s0,48(sp)
    80004640:	74a2                	ld	s1,40(sp)
    80004642:	7902                	ld	s2,32(sp)
    80004644:	69e2                	ld	s3,24(sp)
    80004646:	6a42                	ld	s4,16(sp)
    80004648:	6aa2                	ld	s5,8(sp)
    8000464a:	6b02                	ld	s6,0(sp)
    8000464c:	6121                	addi	sp,sp,64
    8000464e:	8082                	ret
    80004650:	8082                	ret

0000000080004652 <initlog>:
{
    80004652:	7179                	addi	sp,sp,-48
    80004654:	f406                	sd	ra,40(sp)
    80004656:	f022                	sd	s0,32(sp)
    80004658:	ec26                	sd	s1,24(sp)
    8000465a:	e84a                	sd	s2,16(sp)
    8000465c:	e44e                	sd	s3,8(sp)
    8000465e:	1800                	addi	s0,sp,48
    80004660:	892a                	mv	s2,a0
    80004662:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004664:	0001e497          	auipc	s1,0x1e
    80004668:	4fc48493          	addi	s1,s1,1276 # 80022b60 <log>
    8000466c:	00004597          	auipc	a1,0x4
    80004670:	10c58593          	addi	a1,a1,268 # 80008778 <syscallnum+0x198>
    80004674:	8526                	mv	a0,s1
    80004676:	ffffc097          	auipc	ra,0xffffc
    8000467a:	4e4080e7          	jalr	1252(ra) # 80000b5a <initlock>
  log.start = sb->logstart;
    8000467e:	0149a583          	lw	a1,20(s3)
    80004682:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004684:	0109a783          	lw	a5,16(s3)
    80004688:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000468a:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000468e:	854a                	mv	a0,s2
    80004690:	fffff097          	auipc	ra,0xfffff
    80004694:	e8a080e7          	jalr	-374(ra) # 8000351a <bread>
  log.lh.n = lh->n;
    80004698:	4d3c                	lw	a5,88(a0)
    8000469a:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000469c:	02f05563          	blez	a5,800046c6 <initlog+0x74>
    800046a0:	05c50713          	addi	a4,a0,92
    800046a4:	0001e697          	auipc	a3,0x1e
    800046a8:	4ec68693          	addi	a3,a3,1260 # 80022b90 <log+0x30>
    800046ac:	37fd                	addiw	a5,a5,-1
    800046ae:	1782                	slli	a5,a5,0x20
    800046b0:	9381                	srli	a5,a5,0x20
    800046b2:	078a                	slli	a5,a5,0x2
    800046b4:	06050613          	addi	a2,a0,96
    800046b8:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    800046ba:	4310                	lw	a2,0(a4)
    800046bc:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    800046be:	0711                	addi	a4,a4,4
    800046c0:	0691                	addi	a3,a3,4
    800046c2:	fef71ce3          	bne	a4,a5,800046ba <initlog+0x68>
  brelse(buf);
    800046c6:	fffff097          	auipc	ra,0xfffff
    800046ca:	f84080e7          	jalr	-124(ra) # 8000364a <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800046ce:	4505                	li	a0,1
    800046d0:	00000097          	auipc	ra,0x0
    800046d4:	ebe080e7          	jalr	-322(ra) # 8000458e <install_trans>
  log.lh.n = 0;
    800046d8:	0001e797          	auipc	a5,0x1e
    800046dc:	4a07aa23          	sw	zero,1204(a5) # 80022b8c <log+0x2c>
  write_head(); // clear the log
    800046e0:	00000097          	auipc	ra,0x0
    800046e4:	e34080e7          	jalr	-460(ra) # 80004514 <write_head>
}
    800046e8:	70a2                	ld	ra,40(sp)
    800046ea:	7402                	ld	s0,32(sp)
    800046ec:	64e2                	ld	s1,24(sp)
    800046ee:	6942                	ld	s2,16(sp)
    800046f0:	69a2                	ld	s3,8(sp)
    800046f2:	6145                	addi	sp,sp,48
    800046f4:	8082                	ret

00000000800046f6 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800046f6:	1101                	addi	sp,sp,-32
    800046f8:	ec06                	sd	ra,24(sp)
    800046fa:	e822                	sd	s0,16(sp)
    800046fc:	e426                	sd	s1,8(sp)
    800046fe:	e04a                	sd	s2,0(sp)
    80004700:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004702:	0001e517          	auipc	a0,0x1e
    80004706:	45e50513          	addi	a0,a0,1118 # 80022b60 <log>
    8000470a:	ffffc097          	auipc	ra,0xffffc
    8000470e:	4e0080e7          	jalr	1248(ra) # 80000bea <acquire>
  while(1){
    if(log.committing){
    80004712:	0001e497          	auipc	s1,0x1e
    80004716:	44e48493          	addi	s1,s1,1102 # 80022b60 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000471a:	4979                	li	s2,30
    8000471c:	a039                	j	8000472a <begin_op+0x34>
      sleep(&log, &log.lock);
    8000471e:	85a6                	mv	a1,s1
    80004720:	8526                	mv	a0,s1
    80004722:	ffffe097          	auipc	ra,0xffffe
    80004726:	b84080e7          	jalr	-1148(ra) # 800022a6 <sleep>
    if(log.committing){
    8000472a:	50dc                	lw	a5,36(s1)
    8000472c:	fbed                	bnez	a5,8000471e <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000472e:	509c                	lw	a5,32(s1)
    80004730:	0017871b          	addiw	a4,a5,1
    80004734:	0007069b          	sext.w	a3,a4
    80004738:	0027179b          	slliw	a5,a4,0x2
    8000473c:	9fb9                	addw	a5,a5,a4
    8000473e:	0017979b          	slliw	a5,a5,0x1
    80004742:	54d8                	lw	a4,44(s1)
    80004744:	9fb9                	addw	a5,a5,a4
    80004746:	00f95963          	bge	s2,a5,80004758 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000474a:	85a6                	mv	a1,s1
    8000474c:	8526                	mv	a0,s1
    8000474e:	ffffe097          	auipc	ra,0xffffe
    80004752:	b58080e7          	jalr	-1192(ra) # 800022a6 <sleep>
    80004756:	bfd1                	j	8000472a <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004758:	0001e517          	auipc	a0,0x1e
    8000475c:	40850513          	addi	a0,a0,1032 # 80022b60 <log>
    80004760:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004762:	ffffc097          	auipc	ra,0xffffc
    80004766:	53c080e7          	jalr	1340(ra) # 80000c9e <release>
      break;
    }
  }
}
    8000476a:	60e2                	ld	ra,24(sp)
    8000476c:	6442                	ld	s0,16(sp)
    8000476e:	64a2                	ld	s1,8(sp)
    80004770:	6902                	ld	s2,0(sp)
    80004772:	6105                	addi	sp,sp,32
    80004774:	8082                	ret

0000000080004776 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004776:	7139                	addi	sp,sp,-64
    80004778:	fc06                	sd	ra,56(sp)
    8000477a:	f822                	sd	s0,48(sp)
    8000477c:	f426                	sd	s1,40(sp)
    8000477e:	f04a                	sd	s2,32(sp)
    80004780:	ec4e                	sd	s3,24(sp)
    80004782:	e852                	sd	s4,16(sp)
    80004784:	e456                	sd	s5,8(sp)
    80004786:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004788:	0001e497          	auipc	s1,0x1e
    8000478c:	3d848493          	addi	s1,s1,984 # 80022b60 <log>
    80004790:	8526                	mv	a0,s1
    80004792:	ffffc097          	auipc	ra,0xffffc
    80004796:	458080e7          	jalr	1112(ra) # 80000bea <acquire>
  log.outstanding -= 1;
    8000479a:	509c                	lw	a5,32(s1)
    8000479c:	37fd                	addiw	a5,a5,-1
    8000479e:	0007891b          	sext.w	s2,a5
    800047a2:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800047a4:	50dc                	lw	a5,36(s1)
    800047a6:	efb9                	bnez	a5,80004804 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    800047a8:	06091663          	bnez	s2,80004814 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    800047ac:	0001e497          	auipc	s1,0x1e
    800047b0:	3b448493          	addi	s1,s1,948 # 80022b60 <log>
    800047b4:	4785                	li	a5,1
    800047b6:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800047b8:	8526                	mv	a0,s1
    800047ba:	ffffc097          	auipc	ra,0xffffc
    800047be:	4e4080e7          	jalr	1252(ra) # 80000c9e <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800047c2:	54dc                	lw	a5,44(s1)
    800047c4:	06f04763          	bgtz	a5,80004832 <end_op+0xbc>
    acquire(&log.lock);
    800047c8:	0001e497          	auipc	s1,0x1e
    800047cc:	39848493          	addi	s1,s1,920 # 80022b60 <log>
    800047d0:	8526                	mv	a0,s1
    800047d2:	ffffc097          	auipc	ra,0xffffc
    800047d6:	418080e7          	jalr	1048(ra) # 80000bea <acquire>
    log.committing = 0;
    800047da:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800047de:	8526                	mv	a0,s1
    800047e0:	ffffe097          	auipc	ra,0xffffe
    800047e4:	c82080e7          	jalr	-894(ra) # 80002462 <wakeup>
    release(&log.lock);
    800047e8:	8526                	mv	a0,s1
    800047ea:	ffffc097          	auipc	ra,0xffffc
    800047ee:	4b4080e7          	jalr	1204(ra) # 80000c9e <release>
}
    800047f2:	70e2                	ld	ra,56(sp)
    800047f4:	7442                	ld	s0,48(sp)
    800047f6:	74a2                	ld	s1,40(sp)
    800047f8:	7902                	ld	s2,32(sp)
    800047fa:	69e2                	ld	s3,24(sp)
    800047fc:	6a42                	ld	s4,16(sp)
    800047fe:	6aa2                	ld	s5,8(sp)
    80004800:	6121                	addi	sp,sp,64
    80004802:	8082                	ret
    panic("log.committing");
    80004804:	00004517          	auipc	a0,0x4
    80004808:	f7c50513          	addi	a0,a0,-132 # 80008780 <syscallnum+0x1a0>
    8000480c:	ffffc097          	auipc	ra,0xffffc
    80004810:	d38080e7          	jalr	-712(ra) # 80000544 <panic>
    wakeup(&log);
    80004814:	0001e497          	auipc	s1,0x1e
    80004818:	34c48493          	addi	s1,s1,844 # 80022b60 <log>
    8000481c:	8526                	mv	a0,s1
    8000481e:	ffffe097          	auipc	ra,0xffffe
    80004822:	c44080e7          	jalr	-956(ra) # 80002462 <wakeup>
  release(&log.lock);
    80004826:	8526                	mv	a0,s1
    80004828:	ffffc097          	auipc	ra,0xffffc
    8000482c:	476080e7          	jalr	1142(ra) # 80000c9e <release>
  if(do_commit){
    80004830:	b7c9                	j	800047f2 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004832:	0001ea97          	auipc	s5,0x1e
    80004836:	35ea8a93          	addi	s5,s5,862 # 80022b90 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000483a:	0001ea17          	auipc	s4,0x1e
    8000483e:	326a0a13          	addi	s4,s4,806 # 80022b60 <log>
    80004842:	018a2583          	lw	a1,24(s4)
    80004846:	012585bb          	addw	a1,a1,s2
    8000484a:	2585                	addiw	a1,a1,1
    8000484c:	028a2503          	lw	a0,40(s4)
    80004850:	fffff097          	auipc	ra,0xfffff
    80004854:	cca080e7          	jalr	-822(ra) # 8000351a <bread>
    80004858:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000485a:	000aa583          	lw	a1,0(s5)
    8000485e:	028a2503          	lw	a0,40(s4)
    80004862:	fffff097          	auipc	ra,0xfffff
    80004866:	cb8080e7          	jalr	-840(ra) # 8000351a <bread>
    8000486a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000486c:	40000613          	li	a2,1024
    80004870:	05850593          	addi	a1,a0,88
    80004874:	05848513          	addi	a0,s1,88
    80004878:	ffffc097          	auipc	ra,0xffffc
    8000487c:	4ce080e7          	jalr	1230(ra) # 80000d46 <memmove>
    bwrite(to);  // write the log
    80004880:	8526                	mv	a0,s1
    80004882:	fffff097          	auipc	ra,0xfffff
    80004886:	d8a080e7          	jalr	-630(ra) # 8000360c <bwrite>
    brelse(from);
    8000488a:	854e                	mv	a0,s3
    8000488c:	fffff097          	auipc	ra,0xfffff
    80004890:	dbe080e7          	jalr	-578(ra) # 8000364a <brelse>
    brelse(to);
    80004894:	8526                	mv	a0,s1
    80004896:	fffff097          	auipc	ra,0xfffff
    8000489a:	db4080e7          	jalr	-588(ra) # 8000364a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000489e:	2905                	addiw	s2,s2,1
    800048a0:	0a91                	addi	s5,s5,4
    800048a2:	02ca2783          	lw	a5,44(s4)
    800048a6:	f8f94ee3          	blt	s2,a5,80004842 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800048aa:	00000097          	auipc	ra,0x0
    800048ae:	c6a080e7          	jalr	-918(ra) # 80004514 <write_head>
    install_trans(0); // Now install writes to home locations
    800048b2:	4501                	li	a0,0
    800048b4:	00000097          	auipc	ra,0x0
    800048b8:	cda080e7          	jalr	-806(ra) # 8000458e <install_trans>
    log.lh.n = 0;
    800048bc:	0001e797          	auipc	a5,0x1e
    800048c0:	2c07a823          	sw	zero,720(a5) # 80022b8c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800048c4:	00000097          	auipc	ra,0x0
    800048c8:	c50080e7          	jalr	-944(ra) # 80004514 <write_head>
    800048cc:	bdf5                	j	800047c8 <end_op+0x52>

00000000800048ce <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800048ce:	1101                	addi	sp,sp,-32
    800048d0:	ec06                	sd	ra,24(sp)
    800048d2:	e822                	sd	s0,16(sp)
    800048d4:	e426                	sd	s1,8(sp)
    800048d6:	e04a                	sd	s2,0(sp)
    800048d8:	1000                	addi	s0,sp,32
    800048da:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800048dc:	0001e917          	auipc	s2,0x1e
    800048e0:	28490913          	addi	s2,s2,644 # 80022b60 <log>
    800048e4:	854a                	mv	a0,s2
    800048e6:	ffffc097          	auipc	ra,0xffffc
    800048ea:	304080e7          	jalr	772(ra) # 80000bea <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800048ee:	02c92603          	lw	a2,44(s2)
    800048f2:	47f5                	li	a5,29
    800048f4:	06c7c563          	blt	a5,a2,8000495e <log_write+0x90>
    800048f8:	0001e797          	auipc	a5,0x1e
    800048fc:	2847a783          	lw	a5,644(a5) # 80022b7c <log+0x1c>
    80004900:	37fd                	addiw	a5,a5,-1
    80004902:	04f65e63          	bge	a2,a5,8000495e <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004906:	0001e797          	auipc	a5,0x1e
    8000490a:	27a7a783          	lw	a5,634(a5) # 80022b80 <log+0x20>
    8000490e:	06f05063          	blez	a5,8000496e <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004912:	4781                	li	a5,0
    80004914:	06c05563          	blez	a2,8000497e <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004918:	44cc                	lw	a1,12(s1)
    8000491a:	0001e717          	auipc	a4,0x1e
    8000491e:	27670713          	addi	a4,a4,630 # 80022b90 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004922:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004924:	4314                	lw	a3,0(a4)
    80004926:	04b68c63          	beq	a3,a1,8000497e <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000492a:	2785                	addiw	a5,a5,1
    8000492c:	0711                	addi	a4,a4,4
    8000492e:	fef61be3          	bne	a2,a5,80004924 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004932:	0621                	addi	a2,a2,8
    80004934:	060a                	slli	a2,a2,0x2
    80004936:	0001e797          	auipc	a5,0x1e
    8000493a:	22a78793          	addi	a5,a5,554 # 80022b60 <log>
    8000493e:	963e                	add	a2,a2,a5
    80004940:	44dc                	lw	a5,12(s1)
    80004942:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004944:	8526                	mv	a0,s1
    80004946:	fffff097          	auipc	ra,0xfffff
    8000494a:	da2080e7          	jalr	-606(ra) # 800036e8 <bpin>
    log.lh.n++;
    8000494e:	0001e717          	auipc	a4,0x1e
    80004952:	21270713          	addi	a4,a4,530 # 80022b60 <log>
    80004956:	575c                	lw	a5,44(a4)
    80004958:	2785                	addiw	a5,a5,1
    8000495a:	d75c                	sw	a5,44(a4)
    8000495c:	a835                	j	80004998 <log_write+0xca>
    panic("too big a transaction");
    8000495e:	00004517          	auipc	a0,0x4
    80004962:	e3250513          	addi	a0,a0,-462 # 80008790 <syscallnum+0x1b0>
    80004966:	ffffc097          	auipc	ra,0xffffc
    8000496a:	bde080e7          	jalr	-1058(ra) # 80000544 <panic>
    panic("log_write outside of trans");
    8000496e:	00004517          	auipc	a0,0x4
    80004972:	e3a50513          	addi	a0,a0,-454 # 800087a8 <syscallnum+0x1c8>
    80004976:	ffffc097          	auipc	ra,0xffffc
    8000497a:	bce080e7          	jalr	-1074(ra) # 80000544 <panic>
  log.lh.block[i] = b->blockno;
    8000497e:	00878713          	addi	a4,a5,8
    80004982:	00271693          	slli	a3,a4,0x2
    80004986:	0001e717          	auipc	a4,0x1e
    8000498a:	1da70713          	addi	a4,a4,474 # 80022b60 <log>
    8000498e:	9736                	add	a4,a4,a3
    80004990:	44d4                	lw	a3,12(s1)
    80004992:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004994:	faf608e3          	beq	a2,a5,80004944 <log_write+0x76>
  }
  release(&log.lock);
    80004998:	0001e517          	auipc	a0,0x1e
    8000499c:	1c850513          	addi	a0,a0,456 # 80022b60 <log>
    800049a0:	ffffc097          	auipc	ra,0xffffc
    800049a4:	2fe080e7          	jalr	766(ra) # 80000c9e <release>
}
    800049a8:	60e2                	ld	ra,24(sp)
    800049aa:	6442                	ld	s0,16(sp)
    800049ac:	64a2                	ld	s1,8(sp)
    800049ae:	6902                	ld	s2,0(sp)
    800049b0:	6105                	addi	sp,sp,32
    800049b2:	8082                	ret

00000000800049b4 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800049b4:	1101                	addi	sp,sp,-32
    800049b6:	ec06                	sd	ra,24(sp)
    800049b8:	e822                	sd	s0,16(sp)
    800049ba:	e426                	sd	s1,8(sp)
    800049bc:	e04a                	sd	s2,0(sp)
    800049be:	1000                	addi	s0,sp,32
    800049c0:	84aa                	mv	s1,a0
    800049c2:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800049c4:	00004597          	auipc	a1,0x4
    800049c8:	e0458593          	addi	a1,a1,-508 # 800087c8 <syscallnum+0x1e8>
    800049cc:	0521                	addi	a0,a0,8
    800049ce:	ffffc097          	auipc	ra,0xffffc
    800049d2:	18c080e7          	jalr	396(ra) # 80000b5a <initlock>
  lk->name = name;
    800049d6:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800049da:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800049de:	0204a423          	sw	zero,40(s1)
}
    800049e2:	60e2                	ld	ra,24(sp)
    800049e4:	6442                	ld	s0,16(sp)
    800049e6:	64a2                	ld	s1,8(sp)
    800049e8:	6902                	ld	s2,0(sp)
    800049ea:	6105                	addi	sp,sp,32
    800049ec:	8082                	ret

00000000800049ee <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800049ee:	1101                	addi	sp,sp,-32
    800049f0:	ec06                	sd	ra,24(sp)
    800049f2:	e822                	sd	s0,16(sp)
    800049f4:	e426                	sd	s1,8(sp)
    800049f6:	e04a                	sd	s2,0(sp)
    800049f8:	1000                	addi	s0,sp,32
    800049fa:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800049fc:	00850913          	addi	s2,a0,8
    80004a00:	854a                	mv	a0,s2
    80004a02:	ffffc097          	auipc	ra,0xffffc
    80004a06:	1e8080e7          	jalr	488(ra) # 80000bea <acquire>
  while (lk->locked) {
    80004a0a:	409c                	lw	a5,0(s1)
    80004a0c:	cb89                	beqz	a5,80004a1e <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004a0e:	85ca                	mv	a1,s2
    80004a10:	8526                	mv	a0,s1
    80004a12:	ffffe097          	auipc	ra,0xffffe
    80004a16:	894080e7          	jalr	-1900(ra) # 800022a6 <sleep>
  while (lk->locked) {
    80004a1a:	409c                	lw	a5,0(s1)
    80004a1c:	fbed                	bnez	a5,80004a0e <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004a1e:	4785                	li	a5,1
    80004a20:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004a22:	ffffd097          	auipc	ra,0xffffd
    80004a26:	fa4080e7          	jalr	-92(ra) # 800019c6 <myproc>
    80004a2a:	591c                	lw	a5,48(a0)
    80004a2c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004a2e:	854a                	mv	a0,s2
    80004a30:	ffffc097          	auipc	ra,0xffffc
    80004a34:	26e080e7          	jalr	622(ra) # 80000c9e <release>
}
    80004a38:	60e2                	ld	ra,24(sp)
    80004a3a:	6442                	ld	s0,16(sp)
    80004a3c:	64a2                	ld	s1,8(sp)
    80004a3e:	6902                	ld	s2,0(sp)
    80004a40:	6105                	addi	sp,sp,32
    80004a42:	8082                	ret

0000000080004a44 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004a44:	1101                	addi	sp,sp,-32
    80004a46:	ec06                	sd	ra,24(sp)
    80004a48:	e822                	sd	s0,16(sp)
    80004a4a:	e426                	sd	s1,8(sp)
    80004a4c:	e04a                	sd	s2,0(sp)
    80004a4e:	1000                	addi	s0,sp,32
    80004a50:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004a52:	00850913          	addi	s2,a0,8
    80004a56:	854a                	mv	a0,s2
    80004a58:	ffffc097          	auipc	ra,0xffffc
    80004a5c:	192080e7          	jalr	402(ra) # 80000bea <acquire>
  lk->locked = 0;
    80004a60:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004a64:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004a68:	8526                	mv	a0,s1
    80004a6a:	ffffe097          	auipc	ra,0xffffe
    80004a6e:	9f8080e7          	jalr	-1544(ra) # 80002462 <wakeup>
  release(&lk->lk);
    80004a72:	854a                	mv	a0,s2
    80004a74:	ffffc097          	auipc	ra,0xffffc
    80004a78:	22a080e7          	jalr	554(ra) # 80000c9e <release>
}
    80004a7c:	60e2                	ld	ra,24(sp)
    80004a7e:	6442                	ld	s0,16(sp)
    80004a80:	64a2                	ld	s1,8(sp)
    80004a82:	6902                	ld	s2,0(sp)
    80004a84:	6105                	addi	sp,sp,32
    80004a86:	8082                	ret

0000000080004a88 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004a88:	7179                	addi	sp,sp,-48
    80004a8a:	f406                	sd	ra,40(sp)
    80004a8c:	f022                	sd	s0,32(sp)
    80004a8e:	ec26                	sd	s1,24(sp)
    80004a90:	e84a                	sd	s2,16(sp)
    80004a92:	e44e                	sd	s3,8(sp)
    80004a94:	1800                	addi	s0,sp,48
    80004a96:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004a98:	00850913          	addi	s2,a0,8
    80004a9c:	854a                	mv	a0,s2
    80004a9e:	ffffc097          	auipc	ra,0xffffc
    80004aa2:	14c080e7          	jalr	332(ra) # 80000bea <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004aa6:	409c                	lw	a5,0(s1)
    80004aa8:	ef99                	bnez	a5,80004ac6 <holdingsleep+0x3e>
    80004aaa:	4481                	li	s1,0
  release(&lk->lk);
    80004aac:	854a                	mv	a0,s2
    80004aae:	ffffc097          	auipc	ra,0xffffc
    80004ab2:	1f0080e7          	jalr	496(ra) # 80000c9e <release>
  return r;
}
    80004ab6:	8526                	mv	a0,s1
    80004ab8:	70a2                	ld	ra,40(sp)
    80004aba:	7402                	ld	s0,32(sp)
    80004abc:	64e2                	ld	s1,24(sp)
    80004abe:	6942                	ld	s2,16(sp)
    80004ac0:	69a2                	ld	s3,8(sp)
    80004ac2:	6145                	addi	sp,sp,48
    80004ac4:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004ac6:	0284a983          	lw	s3,40(s1)
    80004aca:	ffffd097          	auipc	ra,0xffffd
    80004ace:	efc080e7          	jalr	-260(ra) # 800019c6 <myproc>
    80004ad2:	5904                	lw	s1,48(a0)
    80004ad4:	413484b3          	sub	s1,s1,s3
    80004ad8:	0014b493          	seqz	s1,s1
    80004adc:	bfc1                	j	80004aac <holdingsleep+0x24>

0000000080004ade <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004ade:	1141                	addi	sp,sp,-16
    80004ae0:	e406                	sd	ra,8(sp)
    80004ae2:	e022                	sd	s0,0(sp)
    80004ae4:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004ae6:	00004597          	auipc	a1,0x4
    80004aea:	cf258593          	addi	a1,a1,-782 # 800087d8 <syscallnum+0x1f8>
    80004aee:	0001e517          	auipc	a0,0x1e
    80004af2:	1ba50513          	addi	a0,a0,442 # 80022ca8 <ftable>
    80004af6:	ffffc097          	auipc	ra,0xffffc
    80004afa:	064080e7          	jalr	100(ra) # 80000b5a <initlock>
}
    80004afe:	60a2                	ld	ra,8(sp)
    80004b00:	6402                	ld	s0,0(sp)
    80004b02:	0141                	addi	sp,sp,16
    80004b04:	8082                	ret

0000000080004b06 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004b06:	1101                	addi	sp,sp,-32
    80004b08:	ec06                	sd	ra,24(sp)
    80004b0a:	e822                	sd	s0,16(sp)
    80004b0c:	e426                	sd	s1,8(sp)
    80004b0e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004b10:	0001e517          	auipc	a0,0x1e
    80004b14:	19850513          	addi	a0,a0,408 # 80022ca8 <ftable>
    80004b18:	ffffc097          	auipc	ra,0xffffc
    80004b1c:	0d2080e7          	jalr	210(ra) # 80000bea <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004b20:	0001e497          	auipc	s1,0x1e
    80004b24:	1a048493          	addi	s1,s1,416 # 80022cc0 <ftable+0x18>
    80004b28:	0001f717          	auipc	a4,0x1f
    80004b2c:	13870713          	addi	a4,a4,312 # 80023c60 <disk>
    if(f->ref == 0){
    80004b30:	40dc                	lw	a5,4(s1)
    80004b32:	cf99                	beqz	a5,80004b50 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004b34:	02848493          	addi	s1,s1,40
    80004b38:	fee49ce3          	bne	s1,a4,80004b30 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004b3c:	0001e517          	auipc	a0,0x1e
    80004b40:	16c50513          	addi	a0,a0,364 # 80022ca8 <ftable>
    80004b44:	ffffc097          	auipc	ra,0xffffc
    80004b48:	15a080e7          	jalr	346(ra) # 80000c9e <release>
  return 0;
    80004b4c:	4481                	li	s1,0
    80004b4e:	a819                	j	80004b64 <filealloc+0x5e>
      f->ref = 1;
    80004b50:	4785                	li	a5,1
    80004b52:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004b54:	0001e517          	auipc	a0,0x1e
    80004b58:	15450513          	addi	a0,a0,340 # 80022ca8 <ftable>
    80004b5c:	ffffc097          	auipc	ra,0xffffc
    80004b60:	142080e7          	jalr	322(ra) # 80000c9e <release>
}
    80004b64:	8526                	mv	a0,s1
    80004b66:	60e2                	ld	ra,24(sp)
    80004b68:	6442                	ld	s0,16(sp)
    80004b6a:	64a2                	ld	s1,8(sp)
    80004b6c:	6105                	addi	sp,sp,32
    80004b6e:	8082                	ret

0000000080004b70 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004b70:	1101                	addi	sp,sp,-32
    80004b72:	ec06                	sd	ra,24(sp)
    80004b74:	e822                	sd	s0,16(sp)
    80004b76:	e426                	sd	s1,8(sp)
    80004b78:	1000                	addi	s0,sp,32
    80004b7a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004b7c:	0001e517          	auipc	a0,0x1e
    80004b80:	12c50513          	addi	a0,a0,300 # 80022ca8 <ftable>
    80004b84:	ffffc097          	auipc	ra,0xffffc
    80004b88:	066080e7          	jalr	102(ra) # 80000bea <acquire>
  if(f->ref < 1)
    80004b8c:	40dc                	lw	a5,4(s1)
    80004b8e:	02f05263          	blez	a5,80004bb2 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004b92:	2785                	addiw	a5,a5,1
    80004b94:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004b96:	0001e517          	auipc	a0,0x1e
    80004b9a:	11250513          	addi	a0,a0,274 # 80022ca8 <ftable>
    80004b9e:	ffffc097          	auipc	ra,0xffffc
    80004ba2:	100080e7          	jalr	256(ra) # 80000c9e <release>
  return f;
}
    80004ba6:	8526                	mv	a0,s1
    80004ba8:	60e2                	ld	ra,24(sp)
    80004baa:	6442                	ld	s0,16(sp)
    80004bac:	64a2                	ld	s1,8(sp)
    80004bae:	6105                	addi	sp,sp,32
    80004bb0:	8082                	ret
    panic("filedup");
    80004bb2:	00004517          	auipc	a0,0x4
    80004bb6:	c2e50513          	addi	a0,a0,-978 # 800087e0 <syscallnum+0x200>
    80004bba:	ffffc097          	auipc	ra,0xffffc
    80004bbe:	98a080e7          	jalr	-1654(ra) # 80000544 <panic>

0000000080004bc2 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004bc2:	7139                	addi	sp,sp,-64
    80004bc4:	fc06                	sd	ra,56(sp)
    80004bc6:	f822                	sd	s0,48(sp)
    80004bc8:	f426                	sd	s1,40(sp)
    80004bca:	f04a                	sd	s2,32(sp)
    80004bcc:	ec4e                	sd	s3,24(sp)
    80004bce:	e852                	sd	s4,16(sp)
    80004bd0:	e456                	sd	s5,8(sp)
    80004bd2:	0080                	addi	s0,sp,64
    80004bd4:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004bd6:	0001e517          	auipc	a0,0x1e
    80004bda:	0d250513          	addi	a0,a0,210 # 80022ca8 <ftable>
    80004bde:	ffffc097          	auipc	ra,0xffffc
    80004be2:	00c080e7          	jalr	12(ra) # 80000bea <acquire>
  if(f->ref < 1)
    80004be6:	40dc                	lw	a5,4(s1)
    80004be8:	06f05163          	blez	a5,80004c4a <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004bec:	37fd                	addiw	a5,a5,-1
    80004bee:	0007871b          	sext.w	a4,a5
    80004bf2:	c0dc                	sw	a5,4(s1)
    80004bf4:	06e04363          	bgtz	a4,80004c5a <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004bf8:	0004a903          	lw	s2,0(s1)
    80004bfc:	0094ca83          	lbu	s5,9(s1)
    80004c00:	0104ba03          	ld	s4,16(s1)
    80004c04:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004c08:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004c0c:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004c10:	0001e517          	auipc	a0,0x1e
    80004c14:	09850513          	addi	a0,a0,152 # 80022ca8 <ftable>
    80004c18:	ffffc097          	auipc	ra,0xffffc
    80004c1c:	086080e7          	jalr	134(ra) # 80000c9e <release>

  if(ff.type == FD_PIPE){
    80004c20:	4785                	li	a5,1
    80004c22:	04f90d63          	beq	s2,a5,80004c7c <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004c26:	3979                	addiw	s2,s2,-2
    80004c28:	4785                	li	a5,1
    80004c2a:	0527e063          	bltu	a5,s2,80004c6a <fileclose+0xa8>
    begin_op();
    80004c2e:	00000097          	auipc	ra,0x0
    80004c32:	ac8080e7          	jalr	-1336(ra) # 800046f6 <begin_op>
    iput(ff.ip);
    80004c36:	854e                	mv	a0,s3
    80004c38:	fffff097          	auipc	ra,0xfffff
    80004c3c:	2b6080e7          	jalr	694(ra) # 80003eee <iput>
    end_op();
    80004c40:	00000097          	auipc	ra,0x0
    80004c44:	b36080e7          	jalr	-1226(ra) # 80004776 <end_op>
    80004c48:	a00d                	j	80004c6a <fileclose+0xa8>
    panic("fileclose");
    80004c4a:	00004517          	auipc	a0,0x4
    80004c4e:	b9e50513          	addi	a0,a0,-1122 # 800087e8 <syscallnum+0x208>
    80004c52:	ffffc097          	auipc	ra,0xffffc
    80004c56:	8f2080e7          	jalr	-1806(ra) # 80000544 <panic>
    release(&ftable.lock);
    80004c5a:	0001e517          	auipc	a0,0x1e
    80004c5e:	04e50513          	addi	a0,a0,78 # 80022ca8 <ftable>
    80004c62:	ffffc097          	auipc	ra,0xffffc
    80004c66:	03c080e7          	jalr	60(ra) # 80000c9e <release>
  }
}
    80004c6a:	70e2                	ld	ra,56(sp)
    80004c6c:	7442                	ld	s0,48(sp)
    80004c6e:	74a2                	ld	s1,40(sp)
    80004c70:	7902                	ld	s2,32(sp)
    80004c72:	69e2                	ld	s3,24(sp)
    80004c74:	6a42                	ld	s4,16(sp)
    80004c76:	6aa2                	ld	s5,8(sp)
    80004c78:	6121                	addi	sp,sp,64
    80004c7a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004c7c:	85d6                	mv	a1,s5
    80004c7e:	8552                	mv	a0,s4
    80004c80:	00000097          	auipc	ra,0x0
    80004c84:	34c080e7          	jalr	844(ra) # 80004fcc <pipeclose>
    80004c88:	b7cd                	j	80004c6a <fileclose+0xa8>

0000000080004c8a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004c8a:	715d                	addi	sp,sp,-80
    80004c8c:	e486                	sd	ra,72(sp)
    80004c8e:	e0a2                	sd	s0,64(sp)
    80004c90:	fc26                	sd	s1,56(sp)
    80004c92:	f84a                	sd	s2,48(sp)
    80004c94:	f44e                	sd	s3,40(sp)
    80004c96:	0880                	addi	s0,sp,80
    80004c98:	84aa                	mv	s1,a0
    80004c9a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004c9c:	ffffd097          	auipc	ra,0xffffd
    80004ca0:	d2a080e7          	jalr	-726(ra) # 800019c6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004ca4:	409c                	lw	a5,0(s1)
    80004ca6:	37f9                	addiw	a5,a5,-2
    80004ca8:	4705                	li	a4,1
    80004caa:	04f76763          	bltu	a4,a5,80004cf8 <filestat+0x6e>
    80004cae:	892a                	mv	s2,a0
    ilock(f->ip);
    80004cb0:	6c88                	ld	a0,24(s1)
    80004cb2:	fffff097          	auipc	ra,0xfffff
    80004cb6:	082080e7          	jalr	130(ra) # 80003d34 <ilock>
    stati(f->ip, &st);
    80004cba:	fb840593          	addi	a1,s0,-72
    80004cbe:	6c88                	ld	a0,24(s1)
    80004cc0:	fffff097          	auipc	ra,0xfffff
    80004cc4:	2fe080e7          	jalr	766(ra) # 80003fbe <stati>
    iunlock(f->ip);
    80004cc8:	6c88                	ld	a0,24(s1)
    80004cca:	fffff097          	auipc	ra,0xfffff
    80004cce:	12c080e7          	jalr	300(ra) # 80003df6 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004cd2:	46e1                	li	a3,24
    80004cd4:	fb840613          	addi	a2,s0,-72
    80004cd8:	85ce                	mv	a1,s3
    80004cda:	05093503          	ld	a0,80(s2)
    80004cde:	ffffd097          	auipc	ra,0xffffd
    80004ce2:	9a6080e7          	jalr	-1626(ra) # 80001684 <copyout>
    80004ce6:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004cea:	60a6                	ld	ra,72(sp)
    80004cec:	6406                	ld	s0,64(sp)
    80004cee:	74e2                	ld	s1,56(sp)
    80004cf0:	7942                	ld	s2,48(sp)
    80004cf2:	79a2                	ld	s3,40(sp)
    80004cf4:	6161                	addi	sp,sp,80
    80004cf6:	8082                	ret
  return -1;
    80004cf8:	557d                	li	a0,-1
    80004cfa:	bfc5                	j	80004cea <filestat+0x60>

0000000080004cfc <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004cfc:	7179                	addi	sp,sp,-48
    80004cfe:	f406                	sd	ra,40(sp)
    80004d00:	f022                	sd	s0,32(sp)
    80004d02:	ec26                	sd	s1,24(sp)
    80004d04:	e84a                	sd	s2,16(sp)
    80004d06:	e44e                	sd	s3,8(sp)
    80004d08:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004d0a:	00854783          	lbu	a5,8(a0)
    80004d0e:	c3d5                	beqz	a5,80004db2 <fileread+0xb6>
    80004d10:	84aa                	mv	s1,a0
    80004d12:	89ae                	mv	s3,a1
    80004d14:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004d16:	411c                	lw	a5,0(a0)
    80004d18:	4705                	li	a4,1
    80004d1a:	04e78963          	beq	a5,a4,80004d6c <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004d1e:	470d                	li	a4,3
    80004d20:	04e78d63          	beq	a5,a4,80004d7a <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004d24:	4709                	li	a4,2
    80004d26:	06e79e63          	bne	a5,a4,80004da2 <fileread+0xa6>
    ilock(f->ip);
    80004d2a:	6d08                	ld	a0,24(a0)
    80004d2c:	fffff097          	auipc	ra,0xfffff
    80004d30:	008080e7          	jalr	8(ra) # 80003d34 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004d34:	874a                	mv	a4,s2
    80004d36:	5094                	lw	a3,32(s1)
    80004d38:	864e                	mv	a2,s3
    80004d3a:	4585                	li	a1,1
    80004d3c:	6c88                	ld	a0,24(s1)
    80004d3e:	fffff097          	auipc	ra,0xfffff
    80004d42:	2aa080e7          	jalr	682(ra) # 80003fe8 <readi>
    80004d46:	892a                	mv	s2,a0
    80004d48:	00a05563          	blez	a0,80004d52 <fileread+0x56>
      f->off += r;
    80004d4c:	509c                	lw	a5,32(s1)
    80004d4e:	9fa9                	addw	a5,a5,a0
    80004d50:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004d52:	6c88                	ld	a0,24(s1)
    80004d54:	fffff097          	auipc	ra,0xfffff
    80004d58:	0a2080e7          	jalr	162(ra) # 80003df6 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004d5c:	854a                	mv	a0,s2
    80004d5e:	70a2                	ld	ra,40(sp)
    80004d60:	7402                	ld	s0,32(sp)
    80004d62:	64e2                	ld	s1,24(sp)
    80004d64:	6942                	ld	s2,16(sp)
    80004d66:	69a2                	ld	s3,8(sp)
    80004d68:	6145                	addi	sp,sp,48
    80004d6a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004d6c:	6908                	ld	a0,16(a0)
    80004d6e:	00000097          	auipc	ra,0x0
    80004d72:	3ce080e7          	jalr	974(ra) # 8000513c <piperead>
    80004d76:	892a                	mv	s2,a0
    80004d78:	b7d5                	j	80004d5c <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004d7a:	02451783          	lh	a5,36(a0)
    80004d7e:	03079693          	slli	a3,a5,0x30
    80004d82:	92c1                	srli	a3,a3,0x30
    80004d84:	4725                	li	a4,9
    80004d86:	02d76863          	bltu	a4,a3,80004db6 <fileread+0xba>
    80004d8a:	0792                	slli	a5,a5,0x4
    80004d8c:	0001e717          	auipc	a4,0x1e
    80004d90:	e7c70713          	addi	a4,a4,-388 # 80022c08 <devsw>
    80004d94:	97ba                	add	a5,a5,a4
    80004d96:	639c                	ld	a5,0(a5)
    80004d98:	c38d                	beqz	a5,80004dba <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004d9a:	4505                	li	a0,1
    80004d9c:	9782                	jalr	a5
    80004d9e:	892a                	mv	s2,a0
    80004da0:	bf75                	j	80004d5c <fileread+0x60>
    panic("fileread");
    80004da2:	00004517          	auipc	a0,0x4
    80004da6:	a5650513          	addi	a0,a0,-1450 # 800087f8 <syscallnum+0x218>
    80004daa:	ffffb097          	auipc	ra,0xffffb
    80004dae:	79a080e7          	jalr	1946(ra) # 80000544 <panic>
    return -1;
    80004db2:	597d                	li	s2,-1
    80004db4:	b765                	j	80004d5c <fileread+0x60>
      return -1;
    80004db6:	597d                	li	s2,-1
    80004db8:	b755                	j	80004d5c <fileread+0x60>
    80004dba:	597d                	li	s2,-1
    80004dbc:	b745                	j	80004d5c <fileread+0x60>

0000000080004dbe <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004dbe:	715d                	addi	sp,sp,-80
    80004dc0:	e486                	sd	ra,72(sp)
    80004dc2:	e0a2                	sd	s0,64(sp)
    80004dc4:	fc26                	sd	s1,56(sp)
    80004dc6:	f84a                	sd	s2,48(sp)
    80004dc8:	f44e                	sd	s3,40(sp)
    80004dca:	f052                	sd	s4,32(sp)
    80004dcc:	ec56                	sd	s5,24(sp)
    80004dce:	e85a                	sd	s6,16(sp)
    80004dd0:	e45e                	sd	s7,8(sp)
    80004dd2:	e062                	sd	s8,0(sp)
    80004dd4:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004dd6:	00954783          	lbu	a5,9(a0)
    80004dda:	10078663          	beqz	a5,80004ee6 <filewrite+0x128>
    80004dde:	892a                	mv	s2,a0
    80004de0:	8aae                	mv	s5,a1
    80004de2:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004de4:	411c                	lw	a5,0(a0)
    80004de6:	4705                	li	a4,1
    80004de8:	02e78263          	beq	a5,a4,80004e0c <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004dec:	470d                	li	a4,3
    80004dee:	02e78663          	beq	a5,a4,80004e1a <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004df2:	4709                	li	a4,2
    80004df4:	0ee79163          	bne	a5,a4,80004ed6 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004df8:	0ac05d63          	blez	a2,80004eb2 <filewrite+0xf4>
    int i = 0;
    80004dfc:	4981                	li	s3,0
    80004dfe:	6b05                	lui	s6,0x1
    80004e00:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004e04:	6b85                	lui	s7,0x1
    80004e06:	c00b8b9b          	addiw	s7,s7,-1024
    80004e0a:	a861                	j	80004ea2 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004e0c:	6908                	ld	a0,16(a0)
    80004e0e:	00000097          	auipc	ra,0x0
    80004e12:	22e080e7          	jalr	558(ra) # 8000503c <pipewrite>
    80004e16:	8a2a                	mv	s4,a0
    80004e18:	a045                	j	80004eb8 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004e1a:	02451783          	lh	a5,36(a0)
    80004e1e:	03079693          	slli	a3,a5,0x30
    80004e22:	92c1                	srli	a3,a3,0x30
    80004e24:	4725                	li	a4,9
    80004e26:	0cd76263          	bltu	a4,a3,80004eea <filewrite+0x12c>
    80004e2a:	0792                	slli	a5,a5,0x4
    80004e2c:	0001e717          	auipc	a4,0x1e
    80004e30:	ddc70713          	addi	a4,a4,-548 # 80022c08 <devsw>
    80004e34:	97ba                	add	a5,a5,a4
    80004e36:	679c                	ld	a5,8(a5)
    80004e38:	cbdd                	beqz	a5,80004eee <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004e3a:	4505                	li	a0,1
    80004e3c:	9782                	jalr	a5
    80004e3e:	8a2a                	mv	s4,a0
    80004e40:	a8a5                	j	80004eb8 <filewrite+0xfa>
    80004e42:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004e46:	00000097          	auipc	ra,0x0
    80004e4a:	8b0080e7          	jalr	-1872(ra) # 800046f6 <begin_op>
      ilock(f->ip);
    80004e4e:	01893503          	ld	a0,24(s2)
    80004e52:	fffff097          	auipc	ra,0xfffff
    80004e56:	ee2080e7          	jalr	-286(ra) # 80003d34 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004e5a:	8762                	mv	a4,s8
    80004e5c:	02092683          	lw	a3,32(s2)
    80004e60:	01598633          	add	a2,s3,s5
    80004e64:	4585                	li	a1,1
    80004e66:	01893503          	ld	a0,24(s2)
    80004e6a:	fffff097          	auipc	ra,0xfffff
    80004e6e:	276080e7          	jalr	630(ra) # 800040e0 <writei>
    80004e72:	84aa                	mv	s1,a0
    80004e74:	00a05763          	blez	a0,80004e82 <filewrite+0xc4>
        f->off += r;
    80004e78:	02092783          	lw	a5,32(s2)
    80004e7c:	9fa9                	addw	a5,a5,a0
    80004e7e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004e82:	01893503          	ld	a0,24(s2)
    80004e86:	fffff097          	auipc	ra,0xfffff
    80004e8a:	f70080e7          	jalr	-144(ra) # 80003df6 <iunlock>
      end_op();
    80004e8e:	00000097          	auipc	ra,0x0
    80004e92:	8e8080e7          	jalr	-1816(ra) # 80004776 <end_op>

      if(r != n1){
    80004e96:	009c1f63          	bne	s8,s1,80004eb4 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004e9a:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004e9e:	0149db63          	bge	s3,s4,80004eb4 <filewrite+0xf6>
      int n1 = n - i;
    80004ea2:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004ea6:	84be                	mv	s1,a5
    80004ea8:	2781                	sext.w	a5,a5
    80004eaa:	f8fb5ce3          	bge	s6,a5,80004e42 <filewrite+0x84>
    80004eae:	84de                	mv	s1,s7
    80004eb0:	bf49                	j	80004e42 <filewrite+0x84>
    int i = 0;
    80004eb2:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004eb4:	013a1f63          	bne	s4,s3,80004ed2 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004eb8:	8552                	mv	a0,s4
    80004eba:	60a6                	ld	ra,72(sp)
    80004ebc:	6406                	ld	s0,64(sp)
    80004ebe:	74e2                	ld	s1,56(sp)
    80004ec0:	7942                	ld	s2,48(sp)
    80004ec2:	79a2                	ld	s3,40(sp)
    80004ec4:	7a02                	ld	s4,32(sp)
    80004ec6:	6ae2                	ld	s5,24(sp)
    80004ec8:	6b42                	ld	s6,16(sp)
    80004eca:	6ba2                	ld	s7,8(sp)
    80004ecc:	6c02                	ld	s8,0(sp)
    80004ece:	6161                	addi	sp,sp,80
    80004ed0:	8082                	ret
    ret = (i == n ? n : -1);
    80004ed2:	5a7d                	li	s4,-1
    80004ed4:	b7d5                	j	80004eb8 <filewrite+0xfa>
    panic("filewrite");
    80004ed6:	00004517          	auipc	a0,0x4
    80004eda:	93250513          	addi	a0,a0,-1742 # 80008808 <syscallnum+0x228>
    80004ede:	ffffb097          	auipc	ra,0xffffb
    80004ee2:	666080e7          	jalr	1638(ra) # 80000544 <panic>
    return -1;
    80004ee6:	5a7d                	li	s4,-1
    80004ee8:	bfc1                	j	80004eb8 <filewrite+0xfa>
      return -1;
    80004eea:	5a7d                	li	s4,-1
    80004eec:	b7f1                	j	80004eb8 <filewrite+0xfa>
    80004eee:	5a7d                	li	s4,-1
    80004ef0:	b7e1                	j	80004eb8 <filewrite+0xfa>

0000000080004ef2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004ef2:	7179                	addi	sp,sp,-48
    80004ef4:	f406                	sd	ra,40(sp)
    80004ef6:	f022                	sd	s0,32(sp)
    80004ef8:	ec26                	sd	s1,24(sp)
    80004efa:	e84a                	sd	s2,16(sp)
    80004efc:	e44e                	sd	s3,8(sp)
    80004efe:	e052                	sd	s4,0(sp)
    80004f00:	1800                	addi	s0,sp,48
    80004f02:	84aa                	mv	s1,a0
    80004f04:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004f06:	0005b023          	sd	zero,0(a1)
    80004f0a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004f0e:	00000097          	auipc	ra,0x0
    80004f12:	bf8080e7          	jalr	-1032(ra) # 80004b06 <filealloc>
    80004f16:	e088                	sd	a0,0(s1)
    80004f18:	c551                	beqz	a0,80004fa4 <pipealloc+0xb2>
    80004f1a:	00000097          	auipc	ra,0x0
    80004f1e:	bec080e7          	jalr	-1044(ra) # 80004b06 <filealloc>
    80004f22:	00aa3023          	sd	a0,0(s4)
    80004f26:	c92d                	beqz	a0,80004f98 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004f28:	ffffc097          	auipc	ra,0xffffc
    80004f2c:	bd2080e7          	jalr	-1070(ra) # 80000afa <kalloc>
    80004f30:	892a                	mv	s2,a0
    80004f32:	c125                	beqz	a0,80004f92 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004f34:	4985                	li	s3,1
    80004f36:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004f3a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004f3e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004f42:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004f46:	00003597          	auipc	a1,0x3
    80004f4a:	4ca58593          	addi	a1,a1,1226 # 80008410 <digits+0x3d0>
    80004f4e:	ffffc097          	auipc	ra,0xffffc
    80004f52:	c0c080e7          	jalr	-1012(ra) # 80000b5a <initlock>
  (*f0)->type = FD_PIPE;
    80004f56:	609c                	ld	a5,0(s1)
    80004f58:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004f5c:	609c                	ld	a5,0(s1)
    80004f5e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004f62:	609c                	ld	a5,0(s1)
    80004f64:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004f68:	609c                	ld	a5,0(s1)
    80004f6a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004f6e:	000a3783          	ld	a5,0(s4)
    80004f72:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004f76:	000a3783          	ld	a5,0(s4)
    80004f7a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004f7e:	000a3783          	ld	a5,0(s4)
    80004f82:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004f86:	000a3783          	ld	a5,0(s4)
    80004f8a:	0127b823          	sd	s2,16(a5)
  return 0;
    80004f8e:	4501                	li	a0,0
    80004f90:	a025                	j	80004fb8 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004f92:	6088                	ld	a0,0(s1)
    80004f94:	e501                	bnez	a0,80004f9c <pipealloc+0xaa>
    80004f96:	a039                	j	80004fa4 <pipealloc+0xb2>
    80004f98:	6088                	ld	a0,0(s1)
    80004f9a:	c51d                	beqz	a0,80004fc8 <pipealloc+0xd6>
    fileclose(*f0);
    80004f9c:	00000097          	auipc	ra,0x0
    80004fa0:	c26080e7          	jalr	-986(ra) # 80004bc2 <fileclose>
  if(*f1)
    80004fa4:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004fa8:	557d                	li	a0,-1
  if(*f1)
    80004faa:	c799                	beqz	a5,80004fb8 <pipealloc+0xc6>
    fileclose(*f1);
    80004fac:	853e                	mv	a0,a5
    80004fae:	00000097          	auipc	ra,0x0
    80004fb2:	c14080e7          	jalr	-1004(ra) # 80004bc2 <fileclose>
  return -1;
    80004fb6:	557d                	li	a0,-1
}
    80004fb8:	70a2                	ld	ra,40(sp)
    80004fba:	7402                	ld	s0,32(sp)
    80004fbc:	64e2                	ld	s1,24(sp)
    80004fbe:	6942                	ld	s2,16(sp)
    80004fc0:	69a2                	ld	s3,8(sp)
    80004fc2:	6a02                	ld	s4,0(sp)
    80004fc4:	6145                	addi	sp,sp,48
    80004fc6:	8082                	ret
  return -1;
    80004fc8:	557d                	li	a0,-1
    80004fca:	b7fd                	j	80004fb8 <pipealloc+0xc6>

0000000080004fcc <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004fcc:	1101                	addi	sp,sp,-32
    80004fce:	ec06                	sd	ra,24(sp)
    80004fd0:	e822                	sd	s0,16(sp)
    80004fd2:	e426                	sd	s1,8(sp)
    80004fd4:	e04a                	sd	s2,0(sp)
    80004fd6:	1000                	addi	s0,sp,32
    80004fd8:	84aa                	mv	s1,a0
    80004fda:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004fdc:	ffffc097          	auipc	ra,0xffffc
    80004fe0:	c0e080e7          	jalr	-1010(ra) # 80000bea <acquire>
  if(writable){
    80004fe4:	02090d63          	beqz	s2,8000501e <pipeclose+0x52>
    pi->writeopen = 0;
    80004fe8:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004fec:	21848513          	addi	a0,s1,536
    80004ff0:	ffffd097          	auipc	ra,0xffffd
    80004ff4:	472080e7          	jalr	1138(ra) # 80002462 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004ff8:	2204b783          	ld	a5,544(s1)
    80004ffc:	eb95                	bnez	a5,80005030 <pipeclose+0x64>
    release(&pi->lock);
    80004ffe:	8526                	mv	a0,s1
    80005000:	ffffc097          	auipc	ra,0xffffc
    80005004:	c9e080e7          	jalr	-866(ra) # 80000c9e <release>
    kfree((char*)pi);
    80005008:	8526                	mv	a0,s1
    8000500a:	ffffc097          	auipc	ra,0xffffc
    8000500e:	9f4080e7          	jalr	-1548(ra) # 800009fe <kfree>
  } else
    release(&pi->lock);
}
    80005012:	60e2                	ld	ra,24(sp)
    80005014:	6442                	ld	s0,16(sp)
    80005016:	64a2                	ld	s1,8(sp)
    80005018:	6902                	ld	s2,0(sp)
    8000501a:	6105                	addi	sp,sp,32
    8000501c:	8082                	ret
    pi->readopen = 0;
    8000501e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005022:	21c48513          	addi	a0,s1,540
    80005026:	ffffd097          	auipc	ra,0xffffd
    8000502a:	43c080e7          	jalr	1084(ra) # 80002462 <wakeup>
    8000502e:	b7e9                	j	80004ff8 <pipeclose+0x2c>
    release(&pi->lock);
    80005030:	8526                	mv	a0,s1
    80005032:	ffffc097          	auipc	ra,0xffffc
    80005036:	c6c080e7          	jalr	-916(ra) # 80000c9e <release>
}
    8000503a:	bfe1                	j	80005012 <pipeclose+0x46>

000000008000503c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000503c:	7159                	addi	sp,sp,-112
    8000503e:	f486                	sd	ra,104(sp)
    80005040:	f0a2                	sd	s0,96(sp)
    80005042:	eca6                	sd	s1,88(sp)
    80005044:	e8ca                	sd	s2,80(sp)
    80005046:	e4ce                	sd	s3,72(sp)
    80005048:	e0d2                	sd	s4,64(sp)
    8000504a:	fc56                	sd	s5,56(sp)
    8000504c:	f85a                	sd	s6,48(sp)
    8000504e:	f45e                	sd	s7,40(sp)
    80005050:	f062                	sd	s8,32(sp)
    80005052:	ec66                	sd	s9,24(sp)
    80005054:	1880                	addi	s0,sp,112
    80005056:	84aa                	mv	s1,a0
    80005058:	8aae                	mv	s5,a1
    8000505a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000505c:	ffffd097          	auipc	ra,0xffffd
    80005060:	96a080e7          	jalr	-1686(ra) # 800019c6 <myproc>
    80005064:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005066:	8526                	mv	a0,s1
    80005068:	ffffc097          	auipc	ra,0xffffc
    8000506c:	b82080e7          	jalr	-1150(ra) # 80000bea <acquire>
  while(i < n){
    80005070:	0d405463          	blez	s4,80005138 <pipewrite+0xfc>
    80005074:	8ba6                	mv	s7,s1
  int i = 0;
    80005076:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005078:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000507a:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000507e:	21c48c13          	addi	s8,s1,540
    80005082:	a08d                	j	800050e4 <pipewrite+0xa8>
      release(&pi->lock);
    80005084:	8526                	mv	a0,s1
    80005086:	ffffc097          	auipc	ra,0xffffc
    8000508a:	c18080e7          	jalr	-1000(ra) # 80000c9e <release>
      return -1;
    8000508e:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005090:	854a                	mv	a0,s2
    80005092:	70a6                	ld	ra,104(sp)
    80005094:	7406                	ld	s0,96(sp)
    80005096:	64e6                	ld	s1,88(sp)
    80005098:	6946                	ld	s2,80(sp)
    8000509a:	69a6                	ld	s3,72(sp)
    8000509c:	6a06                	ld	s4,64(sp)
    8000509e:	7ae2                	ld	s5,56(sp)
    800050a0:	7b42                	ld	s6,48(sp)
    800050a2:	7ba2                	ld	s7,40(sp)
    800050a4:	7c02                	ld	s8,32(sp)
    800050a6:	6ce2                	ld	s9,24(sp)
    800050a8:	6165                	addi	sp,sp,112
    800050aa:	8082                	ret
      wakeup(&pi->nread);
    800050ac:	8566                	mv	a0,s9
    800050ae:	ffffd097          	auipc	ra,0xffffd
    800050b2:	3b4080e7          	jalr	948(ra) # 80002462 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800050b6:	85de                	mv	a1,s7
    800050b8:	8562                	mv	a0,s8
    800050ba:	ffffd097          	auipc	ra,0xffffd
    800050be:	1ec080e7          	jalr	492(ra) # 800022a6 <sleep>
    800050c2:	a839                	j	800050e0 <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800050c4:	21c4a783          	lw	a5,540(s1)
    800050c8:	0017871b          	addiw	a4,a5,1
    800050cc:	20e4ae23          	sw	a4,540(s1)
    800050d0:	1ff7f793          	andi	a5,a5,511
    800050d4:	97a6                	add	a5,a5,s1
    800050d6:	f9f44703          	lbu	a4,-97(s0)
    800050da:	00e78c23          	sb	a4,24(a5)
      i++;
    800050de:	2905                	addiw	s2,s2,1
  while(i < n){
    800050e0:	05495063          	bge	s2,s4,80005120 <pipewrite+0xe4>
    if(pi->readopen == 0 || killed(pr)){
    800050e4:	2204a783          	lw	a5,544(s1)
    800050e8:	dfd1                	beqz	a5,80005084 <pipewrite+0x48>
    800050ea:	854e                	mv	a0,s3
    800050ec:	ffffd097          	auipc	ra,0xffffd
    800050f0:	5e0080e7          	jalr	1504(ra) # 800026cc <killed>
    800050f4:	f941                	bnez	a0,80005084 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800050f6:	2184a783          	lw	a5,536(s1)
    800050fa:	21c4a703          	lw	a4,540(s1)
    800050fe:	2007879b          	addiw	a5,a5,512
    80005102:	faf705e3          	beq	a4,a5,800050ac <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005106:	4685                	li	a3,1
    80005108:	01590633          	add	a2,s2,s5
    8000510c:	f9f40593          	addi	a1,s0,-97
    80005110:	0509b503          	ld	a0,80(s3)
    80005114:	ffffc097          	auipc	ra,0xffffc
    80005118:	5fc080e7          	jalr	1532(ra) # 80001710 <copyin>
    8000511c:	fb6514e3          	bne	a0,s6,800050c4 <pipewrite+0x88>
  wakeup(&pi->nread);
    80005120:	21848513          	addi	a0,s1,536
    80005124:	ffffd097          	auipc	ra,0xffffd
    80005128:	33e080e7          	jalr	830(ra) # 80002462 <wakeup>
  release(&pi->lock);
    8000512c:	8526                	mv	a0,s1
    8000512e:	ffffc097          	auipc	ra,0xffffc
    80005132:	b70080e7          	jalr	-1168(ra) # 80000c9e <release>
  return i;
    80005136:	bfa9                	j	80005090 <pipewrite+0x54>
  int i = 0;
    80005138:	4901                	li	s2,0
    8000513a:	b7dd                	j	80005120 <pipewrite+0xe4>

000000008000513c <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000513c:	715d                	addi	sp,sp,-80
    8000513e:	e486                	sd	ra,72(sp)
    80005140:	e0a2                	sd	s0,64(sp)
    80005142:	fc26                	sd	s1,56(sp)
    80005144:	f84a                	sd	s2,48(sp)
    80005146:	f44e                	sd	s3,40(sp)
    80005148:	f052                	sd	s4,32(sp)
    8000514a:	ec56                	sd	s5,24(sp)
    8000514c:	e85a                	sd	s6,16(sp)
    8000514e:	0880                	addi	s0,sp,80
    80005150:	84aa                	mv	s1,a0
    80005152:	892e                	mv	s2,a1
    80005154:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005156:	ffffd097          	auipc	ra,0xffffd
    8000515a:	870080e7          	jalr	-1936(ra) # 800019c6 <myproc>
    8000515e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005160:	8b26                	mv	s6,s1
    80005162:	8526                	mv	a0,s1
    80005164:	ffffc097          	auipc	ra,0xffffc
    80005168:	a86080e7          	jalr	-1402(ra) # 80000bea <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000516c:	2184a703          	lw	a4,536(s1)
    80005170:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005174:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005178:	02f71763          	bne	a4,a5,800051a6 <piperead+0x6a>
    8000517c:	2244a783          	lw	a5,548(s1)
    80005180:	c39d                	beqz	a5,800051a6 <piperead+0x6a>
    if(killed(pr)){
    80005182:	8552                	mv	a0,s4
    80005184:	ffffd097          	auipc	ra,0xffffd
    80005188:	548080e7          	jalr	1352(ra) # 800026cc <killed>
    8000518c:	e941                	bnez	a0,8000521c <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000518e:	85da                	mv	a1,s6
    80005190:	854e                	mv	a0,s3
    80005192:	ffffd097          	auipc	ra,0xffffd
    80005196:	114080e7          	jalr	276(ra) # 800022a6 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000519a:	2184a703          	lw	a4,536(s1)
    8000519e:	21c4a783          	lw	a5,540(s1)
    800051a2:	fcf70de3          	beq	a4,a5,8000517c <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800051a6:	09505263          	blez	s5,8000522a <piperead+0xee>
    800051aa:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800051ac:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    800051ae:	2184a783          	lw	a5,536(s1)
    800051b2:	21c4a703          	lw	a4,540(s1)
    800051b6:	02f70d63          	beq	a4,a5,800051f0 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800051ba:	0017871b          	addiw	a4,a5,1
    800051be:	20e4ac23          	sw	a4,536(s1)
    800051c2:	1ff7f793          	andi	a5,a5,511
    800051c6:	97a6                	add	a5,a5,s1
    800051c8:	0187c783          	lbu	a5,24(a5)
    800051cc:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800051d0:	4685                	li	a3,1
    800051d2:	fbf40613          	addi	a2,s0,-65
    800051d6:	85ca                	mv	a1,s2
    800051d8:	050a3503          	ld	a0,80(s4)
    800051dc:	ffffc097          	auipc	ra,0xffffc
    800051e0:	4a8080e7          	jalr	1192(ra) # 80001684 <copyout>
    800051e4:	01650663          	beq	a0,s6,800051f0 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800051e8:	2985                	addiw	s3,s3,1
    800051ea:	0905                	addi	s2,s2,1
    800051ec:	fd3a91e3          	bne	s5,s3,800051ae <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800051f0:	21c48513          	addi	a0,s1,540
    800051f4:	ffffd097          	auipc	ra,0xffffd
    800051f8:	26e080e7          	jalr	622(ra) # 80002462 <wakeup>
  release(&pi->lock);
    800051fc:	8526                	mv	a0,s1
    800051fe:	ffffc097          	auipc	ra,0xffffc
    80005202:	aa0080e7          	jalr	-1376(ra) # 80000c9e <release>
  return i;
}
    80005206:	854e                	mv	a0,s3
    80005208:	60a6                	ld	ra,72(sp)
    8000520a:	6406                	ld	s0,64(sp)
    8000520c:	74e2                	ld	s1,56(sp)
    8000520e:	7942                	ld	s2,48(sp)
    80005210:	79a2                	ld	s3,40(sp)
    80005212:	7a02                	ld	s4,32(sp)
    80005214:	6ae2                	ld	s5,24(sp)
    80005216:	6b42                	ld	s6,16(sp)
    80005218:	6161                	addi	sp,sp,80
    8000521a:	8082                	ret
      release(&pi->lock);
    8000521c:	8526                	mv	a0,s1
    8000521e:	ffffc097          	auipc	ra,0xffffc
    80005222:	a80080e7          	jalr	-1408(ra) # 80000c9e <release>
      return -1;
    80005226:	59fd                	li	s3,-1
    80005228:	bff9                	j	80005206 <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000522a:	4981                	li	s3,0
    8000522c:	b7d1                	j	800051f0 <piperead+0xb4>

000000008000522e <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    8000522e:	1141                	addi	sp,sp,-16
    80005230:	e422                	sd	s0,8(sp)
    80005232:	0800                	addi	s0,sp,16
    80005234:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80005236:	8905                	andi	a0,a0,1
    80005238:	c111                	beqz	a0,8000523c <flags2perm+0xe>
      perm = PTE_X;
    8000523a:	4521                	li	a0,8
    if(flags & 0x2)
    8000523c:	8b89                	andi	a5,a5,2
    8000523e:	c399                	beqz	a5,80005244 <flags2perm+0x16>
      perm |= PTE_W;
    80005240:	00456513          	ori	a0,a0,4
    return perm;
}
    80005244:	6422                	ld	s0,8(sp)
    80005246:	0141                	addi	sp,sp,16
    80005248:	8082                	ret

000000008000524a <exec>:

int
exec(char *path, char **argv)
{
    8000524a:	df010113          	addi	sp,sp,-528
    8000524e:	20113423          	sd	ra,520(sp)
    80005252:	20813023          	sd	s0,512(sp)
    80005256:	ffa6                	sd	s1,504(sp)
    80005258:	fbca                	sd	s2,496(sp)
    8000525a:	f7ce                	sd	s3,488(sp)
    8000525c:	f3d2                	sd	s4,480(sp)
    8000525e:	efd6                	sd	s5,472(sp)
    80005260:	ebda                	sd	s6,464(sp)
    80005262:	e7de                	sd	s7,456(sp)
    80005264:	e3e2                	sd	s8,448(sp)
    80005266:	ff66                	sd	s9,440(sp)
    80005268:	fb6a                	sd	s10,432(sp)
    8000526a:	f76e                	sd	s11,424(sp)
    8000526c:	0c00                	addi	s0,sp,528
    8000526e:	84aa                	mv	s1,a0
    80005270:	dea43c23          	sd	a0,-520(s0)
    80005274:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005278:	ffffc097          	auipc	ra,0xffffc
    8000527c:	74e080e7          	jalr	1870(ra) # 800019c6 <myproc>
    80005280:	892a                	mv	s2,a0

  begin_op();
    80005282:	fffff097          	auipc	ra,0xfffff
    80005286:	474080e7          	jalr	1140(ra) # 800046f6 <begin_op>

  if((ip = namei(path)) == 0){
    8000528a:	8526                	mv	a0,s1
    8000528c:	fffff097          	auipc	ra,0xfffff
    80005290:	24e080e7          	jalr	590(ra) # 800044da <namei>
    80005294:	c92d                	beqz	a0,80005306 <exec+0xbc>
    80005296:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005298:	fffff097          	auipc	ra,0xfffff
    8000529c:	a9c080e7          	jalr	-1380(ra) # 80003d34 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800052a0:	04000713          	li	a4,64
    800052a4:	4681                	li	a3,0
    800052a6:	e5040613          	addi	a2,s0,-432
    800052aa:	4581                	li	a1,0
    800052ac:	8526                	mv	a0,s1
    800052ae:	fffff097          	auipc	ra,0xfffff
    800052b2:	d3a080e7          	jalr	-710(ra) # 80003fe8 <readi>
    800052b6:	04000793          	li	a5,64
    800052ba:	00f51a63          	bne	a0,a5,800052ce <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800052be:	e5042703          	lw	a4,-432(s0)
    800052c2:	464c47b7          	lui	a5,0x464c4
    800052c6:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800052ca:	04f70463          	beq	a4,a5,80005312 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800052ce:	8526                	mv	a0,s1
    800052d0:	fffff097          	auipc	ra,0xfffff
    800052d4:	cc6080e7          	jalr	-826(ra) # 80003f96 <iunlockput>
    end_op();
    800052d8:	fffff097          	auipc	ra,0xfffff
    800052dc:	49e080e7          	jalr	1182(ra) # 80004776 <end_op>
  }
  return -1;
    800052e0:	557d                	li	a0,-1
}
    800052e2:	20813083          	ld	ra,520(sp)
    800052e6:	20013403          	ld	s0,512(sp)
    800052ea:	74fe                	ld	s1,504(sp)
    800052ec:	795e                	ld	s2,496(sp)
    800052ee:	79be                	ld	s3,488(sp)
    800052f0:	7a1e                	ld	s4,480(sp)
    800052f2:	6afe                	ld	s5,472(sp)
    800052f4:	6b5e                	ld	s6,464(sp)
    800052f6:	6bbe                	ld	s7,456(sp)
    800052f8:	6c1e                	ld	s8,448(sp)
    800052fa:	7cfa                	ld	s9,440(sp)
    800052fc:	7d5a                	ld	s10,432(sp)
    800052fe:	7dba                	ld	s11,424(sp)
    80005300:	21010113          	addi	sp,sp,528
    80005304:	8082                	ret
    end_op();
    80005306:	fffff097          	auipc	ra,0xfffff
    8000530a:	470080e7          	jalr	1136(ra) # 80004776 <end_op>
    return -1;
    8000530e:	557d                	li	a0,-1
    80005310:	bfc9                	j	800052e2 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80005312:	854a                	mv	a0,s2
    80005314:	ffffc097          	auipc	ra,0xffffc
    80005318:	776080e7          	jalr	1910(ra) # 80001a8a <proc_pagetable>
    8000531c:	8baa                	mv	s7,a0
    8000531e:	d945                	beqz	a0,800052ce <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005320:	e7042983          	lw	s3,-400(s0)
    80005324:	e8845783          	lhu	a5,-376(s0)
    80005328:	c7ad                	beqz	a5,80005392 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000532a:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000532c:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    8000532e:	6c85                	lui	s9,0x1
    80005330:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80005334:	def43823          	sd	a5,-528(s0)
    80005338:	ac0d                	j	8000556a <exec+0x320>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000533a:	00003517          	auipc	a0,0x3
    8000533e:	4de50513          	addi	a0,a0,1246 # 80008818 <syscallnum+0x238>
    80005342:	ffffb097          	auipc	ra,0xffffb
    80005346:	202080e7          	jalr	514(ra) # 80000544 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000534a:	8756                	mv	a4,s5
    8000534c:	012d86bb          	addw	a3,s11,s2
    80005350:	4581                	li	a1,0
    80005352:	8526                	mv	a0,s1
    80005354:	fffff097          	auipc	ra,0xfffff
    80005358:	c94080e7          	jalr	-876(ra) # 80003fe8 <readi>
    8000535c:	2501                	sext.w	a0,a0
    8000535e:	1aaa9a63          	bne	s5,a0,80005512 <exec+0x2c8>
  for(i = 0; i < sz; i += PGSIZE){
    80005362:	6785                	lui	a5,0x1
    80005364:	0127893b          	addw	s2,a5,s2
    80005368:	77fd                	lui	a5,0xfffff
    8000536a:	01478a3b          	addw	s4,a5,s4
    8000536e:	1f897563          	bgeu	s2,s8,80005558 <exec+0x30e>
    pa = walkaddr(pagetable, va + i);
    80005372:	02091593          	slli	a1,s2,0x20
    80005376:	9181                	srli	a1,a1,0x20
    80005378:	95ea                	add	a1,a1,s10
    8000537a:	855e                	mv	a0,s7
    8000537c:	ffffc097          	auipc	ra,0xffffc
    80005380:	cfc080e7          	jalr	-772(ra) # 80001078 <walkaddr>
    80005384:	862a                	mv	a2,a0
    if(pa == 0)
    80005386:	d955                	beqz	a0,8000533a <exec+0xf0>
      n = PGSIZE;
    80005388:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    8000538a:	fd9a70e3          	bgeu	s4,s9,8000534a <exec+0x100>
      n = sz - i;
    8000538e:	8ad2                	mv	s5,s4
    80005390:	bf6d                	j	8000534a <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005392:	4a01                	li	s4,0
  iunlockput(ip);
    80005394:	8526                	mv	a0,s1
    80005396:	fffff097          	auipc	ra,0xfffff
    8000539a:	c00080e7          	jalr	-1024(ra) # 80003f96 <iunlockput>
  end_op();
    8000539e:	fffff097          	auipc	ra,0xfffff
    800053a2:	3d8080e7          	jalr	984(ra) # 80004776 <end_op>
  p = myproc();
    800053a6:	ffffc097          	auipc	ra,0xffffc
    800053aa:	620080e7          	jalr	1568(ra) # 800019c6 <myproc>
    800053ae:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800053b0:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800053b4:	6785                	lui	a5,0x1
    800053b6:	17fd                	addi	a5,a5,-1
    800053b8:	9a3e                	add	s4,s4,a5
    800053ba:	757d                	lui	a0,0xfffff
    800053bc:	00aa77b3          	and	a5,s4,a0
    800053c0:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800053c4:	4691                	li	a3,4
    800053c6:	6609                	lui	a2,0x2
    800053c8:	963e                	add	a2,a2,a5
    800053ca:	85be                	mv	a1,a5
    800053cc:	855e                	mv	a0,s7
    800053ce:	ffffc097          	auipc	ra,0xffffc
    800053d2:	05e080e7          	jalr	94(ra) # 8000142c <uvmalloc>
    800053d6:	8b2a                	mv	s6,a0
  ip = 0;
    800053d8:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800053da:	12050c63          	beqz	a0,80005512 <exec+0x2c8>
  uvmclear(pagetable, sz-2*PGSIZE);
    800053de:	75f9                	lui	a1,0xffffe
    800053e0:	95aa                	add	a1,a1,a0
    800053e2:	855e                	mv	a0,s7
    800053e4:	ffffc097          	auipc	ra,0xffffc
    800053e8:	26e080e7          	jalr	622(ra) # 80001652 <uvmclear>
  stackbase = sp - PGSIZE;
    800053ec:	7c7d                	lui	s8,0xfffff
    800053ee:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    800053f0:	e0043783          	ld	a5,-512(s0)
    800053f4:	6388                	ld	a0,0(a5)
    800053f6:	c535                	beqz	a0,80005462 <exec+0x218>
    800053f8:	e9040993          	addi	s3,s0,-368
    800053fc:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80005400:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80005402:	ffffc097          	auipc	ra,0xffffc
    80005406:	a68080e7          	jalr	-1432(ra) # 80000e6a <strlen>
    8000540a:	2505                	addiw	a0,a0,1
    8000540c:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005410:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005414:	13896663          	bltu	s2,s8,80005540 <exec+0x2f6>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005418:	e0043d83          	ld	s11,-512(s0)
    8000541c:	000dba03          	ld	s4,0(s11)
    80005420:	8552                	mv	a0,s4
    80005422:	ffffc097          	auipc	ra,0xffffc
    80005426:	a48080e7          	jalr	-1464(ra) # 80000e6a <strlen>
    8000542a:	0015069b          	addiw	a3,a0,1
    8000542e:	8652                	mv	a2,s4
    80005430:	85ca                	mv	a1,s2
    80005432:	855e                	mv	a0,s7
    80005434:	ffffc097          	auipc	ra,0xffffc
    80005438:	250080e7          	jalr	592(ra) # 80001684 <copyout>
    8000543c:	10054663          	bltz	a0,80005548 <exec+0x2fe>
    ustack[argc] = sp;
    80005440:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005444:	0485                	addi	s1,s1,1
    80005446:	008d8793          	addi	a5,s11,8
    8000544a:	e0f43023          	sd	a5,-512(s0)
    8000544e:	008db503          	ld	a0,8(s11)
    80005452:	c911                	beqz	a0,80005466 <exec+0x21c>
    if(argc >= MAXARG)
    80005454:	09a1                	addi	s3,s3,8
    80005456:	fb3c96e3          	bne	s9,s3,80005402 <exec+0x1b8>
  sz = sz1;
    8000545a:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000545e:	4481                	li	s1,0
    80005460:	a84d                	j	80005512 <exec+0x2c8>
  sp = sz;
    80005462:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005464:	4481                	li	s1,0
  ustack[argc] = 0;
    80005466:	00349793          	slli	a5,s1,0x3
    8000546a:	f9040713          	addi	a4,s0,-112
    8000546e:	97ba                	add	a5,a5,a4
    80005470:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    80005474:	00148693          	addi	a3,s1,1
    80005478:	068e                	slli	a3,a3,0x3
    8000547a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000547e:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005482:	01897663          	bgeu	s2,s8,8000548e <exec+0x244>
  sz = sz1;
    80005486:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000548a:	4481                	li	s1,0
    8000548c:	a059                	j	80005512 <exec+0x2c8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000548e:	e9040613          	addi	a2,s0,-368
    80005492:	85ca                	mv	a1,s2
    80005494:	855e                	mv	a0,s7
    80005496:	ffffc097          	auipc	ra,0xffffc
    8000549a:	1ee080e7          	jalr	494(ra) # 80001684 <copyout>
    8000549e:	0a054963          	bltz	a0,80005550 <exec+0x306>
  p->trapframe->a1 = sp;
    800054a2:	058ab783          	ld	a5,88(s5)
    800054a6:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800054aa:	df843783          	ld	a5,-520(s0)
    800054ae:	0007c703          	lbu	a4,0(a5)
    800054b2:	cf11                	beqz	a4,800054ce <exec+0x284>
    800054b4:	0785                	addi	a5,a5,1
    if(*s == '/')
    800054b6:	02f00693          	li	a3,47
    800054ba:	a039                	j	800054c8 <exec+0x27e>
      last = s+1;
    800054bc:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800054c0:	0785                	addi	a5,a5,1
    800054c2:	fff7c703          	lbu	a4,-1(a5)
    800054c6:	c701                	beqz	a4,800054ce <exec+0x284>
    if(*s == '/')
    800054c8:	fed71ce3          	bne	a4,a3,800054c0 <exec+0x276>
    800054cc:	bfc5                	j	800054bc <exec+0x272>
  safestrcpy(p->name, last, sizeof(p->name));
    800054ce:	4641                	li	a2,16
    800054d0:	df843583          	ld	a1,-520(s0)
    800054d4:	158a8513          	addi	a0,s5,344
    800054d8:	ffffc097          	auipc	ra,0xffffc
    800054dc:	960080e7          	jalr	-1696(ra) # 80000e38 <safestrcpy>
  oldpagetable = p->pagetable;
    800054e0:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800054e4:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    800054e8:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800054ec:	058ab783          	ld	a5,88(s5)
    800054f0:	e6843703          	ld	a4,-408(s0)
    800054f4:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800054f6:	058ab783          	ld	a5,88(s5)
    800054fa:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800054fe:	85ea                	mv	a1,s10
    80005500:	ffffc097          	auipc	ra,0xffffc
    80005504:	626080e7          	jalr	1574(ra) # 80001b26 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005508:	0004851b          	sext.w	a0,s1
    8000550c:	bbd9                	j	800052e2 <exec+0x98>
    8000550e:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    80005512:	e0843583          	ld	a1,-504(s0)
    80005516:	855e                	mv	a0,s7
    80005518:	ffffc097          	auipc	ra,0xffffc
    8000551c:	60e080e7          	jalr	1550(ra) # 80001b26 <proc_freepagetable>
  if(ip){
    80005520:	da0497e3          	bnez	s1,800052ce <exec+0x84>
  return -1;
    80005524:	557d                	li	a0,-1
    80005526:	bb75                	j	800052e2 <exec+0x98>
    80005528:	e1443423          	sd	s4,-504(s0)
    8000552c:	b7dd                	j	80005512 <exec+0x2c8>
    8000552e:	e1443423          	sd	s4,-504(s0)
    80005532:	b7c5                	j	80005512 <exec+0x2c8>
    80005534:	e1443423          	sd	s4,-504(s0)
    80005538:	bfe9                	j	80005512 <exec+0x2c8>
    8000553a:	e1443423          	sd	s4,-504(s0)
    8000553e:	bfd1                	j	80005512 <exec+0x2c8>
  sz = sz1;
    80005540:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005544:	4481                	li	s1,0
    80005546:	b7f1                	j	80005512 <exec+0x2c8>
  sz = sz1;
    80005548:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000554c:	4481                	li	s1,0
    8000554e:	b7d1                	j	80005512 <exec+0x2c8>
  sz = sz1;
    80005550:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005554:	4481                	li	s1,0
    80005556:	bf75                	j	80005512 <exec+0x2c8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005558:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000555c:	2b05                	addiw	s6,s6,1
    8000555e:	0389899b          	addiw	s3,s3,56
    80005562:	e8845783          	lhu	a5,-376(s0)
    80005566:	e2fb57e3          	bge	s6,a5,80005394 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000556a:	2981                	sext.w	s3,s3
    8000556c:	03800713          	li	a4,56
    80005570:	86ce                	mv	a3,s3
    80005572:	e1840613          	addi	a2,s0,-488
    80005576:	4581                	li	a1,0
    80005578:	8526                	mv	a0,s1
    8000557a:	fffff097          	auipc	ra,0xfffff
    8000557e:	a6e080e7          	jalr	-1426(ra) # 80003fe8 <readi>
    80005582:	03800793          	li	a5,56
    80005586:	f8f514e3          	bne	a0,a5,8000550e <exec+0x2c4>
    if(ph.type != ELF_PROG_LOAD)
    8000558a:	e1842783          	lw	a5,-488(s0)
    8000558e:	4705                	li	a4,1
    80005590:	fce796e3          	bne	a5,a4,8000555c <exec+0x312>
    if(ph.memsz < ph.filesz)
    80005594:	e4043903          	ld	s2,-448(s0)
    80005598:	e3843783          	ld	a5,-456(s0)
    8000559c:	f8f966e3          	bltu	s2,a5,80005528 <exec+0x2de>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800055a0:	e2843783          	ld	a5,-472(s0)
    800055a4:	993e                	add	s2,s2,a5
    800055a6:	f8f964e3          	bltu	s2,a5,8000552e <exec+0x2e4>
    if(ph.vaddr % PGSIZE != 0)
    800055aa:	df043703          	ld	a4,-528(s0)
    800055ae:	8ff9                	and	a5,a5,a4
    800055b0:	f3d1                	bnez	a5,80005534 <exec+0x2ea>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800055b2:	e1c42503          	lw	a0,-484(s0)
    800055b6:	00000097          	auipc	ra,0x0
    800055ba:	c78080e7          	jalr	-904(ra) # 8000522e <flags2perm>
    800055be:	86aa                	mv	a3,a0
    800055c0:	864a                	mv	a2,s2
    800055c2:	85d2                	mv	a1,s4
    800055c4:	855e                	mv	a0,s7
    800055c6:	ffffc097          	auipc	ra,0xffffc
    800055ca:	e66080e7          	jalr	-410(ra) # 8000142c <uvmalloc>
    800055ce:	e0a43423          	sd	a0,-504(s0)
    800055d2:	d525                	beqz	a0,8000553a <exec+0x2f0>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800055d4:	e2843d03          	ld	s10,-472(s0)
    800055d8:	e2042d83          	lw	s11,-480(s0)
    800055dc:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800055e0:	f60c0ce3          	beqz	s8,80005558 <exec+0x30e>
    800055e4:	8a62                	mv	s4,s8
    800055e6:	4901                	li	s2,0
    800055e8:	b369                	j	80005372 <exec+0x128>

00000000800055ea <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800055ea:	7179                	addi	sp,sp,-48
    800055ec:	f406                	sd	ra,40(sp)
    800055ee:	f022                	sd	s0,32(sp)
    800055f0:	ec26                	sd	s1,24(sp)
    800055f2:	e84a                	sd	s2,16(sp)
    800055f4:	1800                	addi	s0,sp,48
    800055f6:	892e                	mv	s2,a1
    800055f8:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800055fa:	fdc40593          	addi	a1,s0,-36
    800055fe:	ffffe097          	auipc	ra,0xffffe
    80005602:	924080e7          	jalr	-1756(ra) # 80002f22 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005606:	fdc42703          	lw	a4,-36(s0)
    8000560a:	47bd                	li	a5,15
    8000560c:	02e7eb63          	bltu	a5,a4,80005642 <argfd+0x58>
    80005610:	ffffc097          	auipc	ra,0xffffc
    80005614:	3b6080e7          	jalr	950(ra) # 800019c6 <myproc>
    80005618:	fdc42703          	lw	a4,-36(s0)
    8000561c:	01a70793          	addi	a5,a4,26
    80005620:	078e                	slli	a5,a5,0x3
    80005622:	953e                	add	a0,a0,a5
    80005624:	611c                	ld	a5,0(a0)
    80005626:	c385                	beqz	a5,80005646 <argfd+0x5c>
    return -1;
  if(pfd)
    80005628:	00090463          	beqz	s2,80005630 <argfd+0x46>
    *pfd = fd;
    8000562c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005630:	4501                	li	a0,0
  if(pf)
    80005632:	c091                	beqz	s1,80005636 <argfd+0x4c>
    *pf = f;
    80005634:	e09c                	sd	a5,0(s1)
}
    80005636:	70a2                	ld	ra,40(sp)
    80005638:	7402                	ld	s0,32(sp)
    8000563a:	64e2                	ld	s1,24(sp)
    8000563c:	6942                	ld	s2,16(sp)
    8000563e:	6145                	addi	sp,sp,48
    80005640:	8082                	ret
    return -1;
    80005642:	557d                	li	a0,-1
    80005644:	bfcd                	j	80005636 <argfd+0x4c>
    80005646:	557d                	li	a0,-1
    80005648:	b7fd                	j	80005636 <argfd+0x4c>

000000008000564a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000564a:	1101                	addi	sp,sp,-32
    8000564c:	ec06                	sd	ra,24(sp)
    8000564e:	e822                	sd	s0,16(sp)
    80005650:	e426                	sd	s1,8(sp)
    80005652:	1000                	addi	s0,sp,32
    80005654:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005656:	ffffc097          	auipc	ra,0xffffc
    8000565a:	370080e7          	jalr	880(ra) # 800019c6 <myproc>
    8000565e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005660:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffdb330>
    80005664:	4501                	li	a0,0
    80005666:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005668:	6398                	ld	a4,0(a5)
    8000566a:	cb19                	beqz	a4,80005680 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000566c:	2505                	addiw	a0,a0,1
    8000566e:	07a1                	addi	a5,a5,8
    80005670:	fed51ce3          	bne	a0,a3,80005668 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005674:	557d                	li	a0,-1
}
    80005676:	60e2                	ld	ra,24(sp)
    80005678:	6442                	ld	s0,16(sp)
    8000567a:	64a2                	ld	s1,8(sp)
    8000567c:	6105                	addi	sp,sp,32
    8000567e:	8082                	ret
      p->ofile[fd] = f;
    80005680:	01a50793          	addi	a5,a0,26
    80005684:	078e                	slli	a5,a5,0x3
    80005686:	963e                	add	a2,a2,a5
    80005688:	e204                	sd	s1,0(a2)
      return fd;
    8000568a:	b7f5                	j	80005676 <fdalloc+0x2c>

000000008000568c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000568c:	715d                	addi	sp,sp,-80
    8000568e:	e486                	sd	ra,72(sp)
    80005690:	e0a2                	sd	s0,64(sp)
    80005692:	fc26                	sd	s1,56(sp)
    80005694:	f84a                	sd	s2,48(sp)
    80005696:	f44e                	sd	s3,40(sp)
    80005698:	f052                	sd	s4,32(sp)
    8000569a:	ec56                	sd	s5,24(sp)
    8000569c:	e85a                	sd	s6,16(sp)
    8000569e:	0880                	addi	s0,sp,80
    800056a0:	8b2e                	mv	s6,a1
    800056a2:	89b2                	mv	s3,a2
    800056a4:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800056a6:	fb040593          	addi	a1,s0,-80
    800056aa:	fffff097          	auipc	ra,0xfffff
    800056ae:	e4e080e7          	jalr	-434(ra) # 800044f8 <nameiparent>
    800056b2:	84aa                	mv	s1,a0
    800056b4:	16050063          	beqz	a0,80005814 <create+0x188>
    return 0;

  ilock(dp);
    800056b8:	ffffe097          	auipc	ra,0xffffe
    800056bc:	67c080e7          	jalr	1660(ra) # 80003d34 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800056c0:	4601                	li	a2,0
    800056c2:	fb040593          	addi	a1,s0,-80
    800056c6:	8526                	mv	a0,s1
    800056c8:	fffff097          	auipc	ra,0xfffff
    800056cc:	b50080e7          	jalr	-1200(ra) # 80004218 <dirlookup>
    800056d0:	8aaa                	mv	s5,a0
    800056d2:	c931                	beqz	a0,80005726 <create+0x9a>
    iunlockput(dp);
    800056d4:	8526                	mv	a0,s1
    800056d6:	fffff097          	auipc	ra,0xfffff
    800056da:	8c0080e7          	jalr	-1856(ra) # 80003f96 <iunlockput>
    ilock(ip);
    800056de:	8556                	mv	a0,s5
    800056e0:	ffffe097          	auipc	ra,0xffffe
    800056e4:	654080e7          	jalr	1620(ra) # 80003d34 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800056e8:	000b059b          	sext.w	a1,s6
    800056ec:	4789                	li	a5,2
    800056ee:	02f59563          	bne	a1,a5,80005718 <create+0x8c>
    800056f2:	044ad783          	lhu	a5,68(s5)
    800056f6:	37f9                	addiw	a5,a5,-2
    800056f8:	17c2                	slli	a5,a5,0x30
    800056fa:	93c1                	srli	a5,a5,0x30
    800056fc:	4705                	li	a4,1
    800056fe:	00f76d63          	bltu	a4,a5,80005718 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005702:	8556                	mv	a0,s5
    80005704:	60a6                	ld	ra,72(sp)
    80005706:	6406                	ld	s0,64(sp)
    80005708:	74e2                	ld	s1,56(sp)
    8000570a:	7942                	ld	s2,48(sp)
    8000570c:	79a2                	ld	s3,40(sp)
    8000570e:	7a02                	ld	s4,32(sp)
    80005710:	6ae2                	ld	s5,24(sp)
    80005712:	6b42                	ld	s6,16(sp)
    80005714:	6161                	addi	sp,sp,80
    80005716:	8082                	ret
    iunlockput(ip);
    80005718:	8556                	mv	a0,s5
    8000571a:	fffff097          	auipc	ra,0xfffff
    8000571e:	87c080e7          	jalr	-1924(ra) # 80003f96 <iunlockput>
    return 0;
    80005722:	4a81                	li	s5,0
    80005724:	bff9                	j	80005702 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005726:	85da                	mv	a1,s6
    80005728:	4088                	lw	a0,0(s1)
    8000572a:	ffffe097          	auipc	ra,0xffffe
    8000572e:	46e080e7          	jalr	1134(ra) # 80003b98 <ialloc>
    80005732:	8a2a                	mv	s4,a0
    80005734:	c921                	beqz	a0,80005784 <create+0xf8>
  ilock(ip);
    80005736:	ffffe097          	auipc	ra,0xffffe
    8000573a:	5fe080e7          	jalr	1534(ra) # 80003d34 <ilock>
  ip->major = major;
    8000573e:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005742:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005746:	4785                	li	a5,1
    80005748:	04fa1523          	sh	a5,74(s4)
  iupdate(ip);
    8000574c:	8552                	mv	a0,s4
    8000574e:	ffffe097          	auipc	ra,0xffffe
    80005752:	51c080e7          	jalr	1308(ra) # 80003c6a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005756:	000b059b          	sext.w	a1,s6
    8000575a:	4785                	li	a5,1
    8000575c:	02f58b63          	beq	a1,a5,80005792 <create+0x106>
  if(dirlink(dp, name, ip->inum) < 0)
    80005760:	004a2603          	lw	a2,4(s4)
    80005764:	fb040593          	addi	a1,s0,-80
    80005768:	8526                	mv	a0,s1
    8000576a:	fffff097          	auipc	ra,0xfffff
    8000576e:	cbe080e7          	jalr	-834(ra) # 80004428 <dirlink>
    80005772:	06054f63          	bltz	a0,800057f0 <create+0x164>
  iunlockput(dp);
    80005776:	8526                	mv	a0,s1
    80005778:	fffff097          	auipc	ra,0xfffff
    8000577c:	81e080e7          	jalr	-2018(ra) # 80003f96 <iunlockput>
  return ip;
    80005780:	8ad2                	mv	s5,s4
    80005782:	b741                	j	80005702 <create+0x76>
    iunlockput(dp);
    80005784:	8526                	mv	a0,s1
    80005786:	fffff097          	auipc	ra,0xfffff
    8000578a:	810080e7          	jalr	-2032(ra) # 80003f96 <iunlockput>
    return 0;
    8000578e:	8ad2                	mv	s5,s4
    80005790:	bf8d                	j	80005702 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005792:	004a2603          	lw	a2,4(s4)
    80005796:	00003597          	auipc	a1,0x3
    8000579a:	0a258593          	addi	a1,a1,162 # 80008838 <syscallnum+0x258>
    8000579e:	8552                	mv	a0,s4
    800057a0:	fffff097          	auipc	ra,0xfffff
    800057a4:	c88080e7          	jalr	-888(ra) # 80004428 <dirlink>
    800057a8:	04054463          	bltz	a0,800057f0 <create+0x164>
    800057ac:	40d0                	lw	a2,4(s1)
    800057ae:	00003597          	auipc	a1,0x3
    800057b2:	09258593          	addi	a1,a1,146 # 80008840 <syscallnum+0x260>
    800057b6:	8552                	mv	a0,s4
    800057b8:	fffff097          	auipc	ra,0xfffff
    800057bc:	c70080e7          	jalr	-912(ra) # 80004428 <dirlink>
    800057c0:	02054863          	bltz	a0,800057f0 <create+0x164>
  if(dirlink(dp, name, ip->inum) < 0)
    800057c4:	004a2603          	lw	a2,4(s4)
    800057c8:	fb040593          	addi	a1,s0,-80
    800057cc:	8526                	mv	a0,s1
    800057ce:	fffff097          	auipc	ra,0xfffff
    800057d2:	c5a080e7          	jalr	-934(ra) # 80004428 <dirlink>
    800057d6:	00054d63          	bltz	a0,800057f0 <create+0x164>
    dp->nlink++;  // for ".."
    800057da:	04a4d783          	lhu	a5,74(s1)
    800057de:	2785                	addiw	a5,a5,1
    800057e0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800057e4:	8526                	mv	a0,s1
    800057e6:	ffffe097          	auipc	ra,0xffffe
    800057ea:	484080e7          	jalr	1156(ra) # 80003c6a <iupdate>
    800057ee:	b761                	j	80005776 <create+0xea>
  ip->nlink = 0;
    800057f0:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800057f4:	8552                	mv	a0,s4
    800057f6:	ffffe097          	auipc	ra,0xffffe
    800057fa:	474080e7          	jalr	1140(ra) # 80003c6a <iupdate>
  iunlockput(ip);
    800057fe:	8552                	mv	a0,s4
    80005800:	ffffe097          	auipc	ra,0xffffe
    80005804:	796080e7          	jalr	1942(ra) # 80003f96 <iunlockput>
  iunlockput(dp);
    80005808:	8526                	mv	a0,s1
    8000580a:	ffffe097          	auipc	ra,0xffffe
    8000580e:	78c080e7          	jalr	1932(ra) # 80003f96 <iunlockput>
  return 0;
    80005812:	bdc5                	j	80005702 <create+0x76>
    return 0;
    80005814:	8aaa                	mv	s5,a0
    80005816:	b5f5                	j	80005702 <create+0x76>

0000000080005818 <sys_dup>:
{
    80005818:	7179                	addi	sp,sp,-48
    8000581a:	f406                	sd	ra,40(sp)
    8000581c:	f022                	sd	s0,32(sp)
    8000581e:	ec26                	sd	s1,24(sp)
    80005820:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005822:	fd840613          	addi	a2,s0,-40
    80005826:	4581                	li	a1,0
    80005828:	4501                	li	a0,0
    8000582a:	00000097          	auipc	ra,0x0
    8000582e:	dc0080e7          	jalr	-576(ra) # 800055ea <argfd>
    return -1;
    80005832:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005834:	02054363          	bltz	a0,8000585a <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005838:	fd843503          	ld	a0,-40(s0)
    8000583c:	00000097          	auipc	ra,0x0
    80005840:	e0e080e7          	jalr	-498(ra) # 8000564a <fdalloc>
    80005844:	84aa                	mv	s1,a0
    return -1;
    80005846:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005848:	00054963          	bltz	a0,8000585a <sys_dup+0x42>
  filedup(f);
    8000584c:	fd843503          	ld	a0,-40(s0)
    80005850:	fffff097          	auipc	ra,0xfffff
    80005854:	320080e7          	jalr	800(ra) # 80004b70 <filedup>
  return fd;
    80005858:	87a6                	mv	a5,s1
}
    8000585a:	853e                	mv	a0,a5
    8000585c:	70a2                	ld	ra,40(sp)
    8000585e:	7402                	ld	s0,32(sp)
    80005860:	64e2                	ld	s1,24(sp)
    80005862:	6145                	addi	sp,sp,48
    80005864:	8082                	ret

0000000080005866 <sys_read>:
{
    80005866:	7179                	addi	sp,sp,-48
    80005868:	f406                	sd	ra,40(sp)
    8000586a:	f022                	sd	s0,32(sp)
    8000586c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000586e:	fd840593          	addi	a1,s0,-40
    80005872:	4505                	li	a0,1
    80005874:	ffffd097          	auipc	ra,0xffffd
    80005878:	6d0080e7          	jalr	1744(ra) # 80002f44 <argaddr>
  argint(2, &n);
    8000587c:	fe440593          	addi	a1,s0,-28
    80005880:	4509                	li	a0,2
    80005882:	ffffd097          	auipc	ra,0xffffd
    80005886:	6a0080e7          	jalr	1696(ra) # 80002f22 <argint>
  if(argfd(0, 0, &f) < 0)
    8000588a:	fe840613          	addi	a2,s0,-24
    8000588e:	4581                	li	a1,0
    80005890:	4501                	li	a0,0
    80005892:	00000097          	auipc	ra,0x0
    80005896:	d58080e7          	jalr	-680(ra) # 800055ea <argfd>
    8000589a:	87aa                	mv	a5,a0
    return -1;
    8000589c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000589e:	0007cc63          	bltz	a5,800058b6 <sys_read+0x50>
  return fileread(f, p, n);
    800058a2:	fe442603          	lw	a2,-28(s0)
    800058a6:	fd843583          	ld	a1,-40(s0)
    800058aa:	fe843503          	ld	a0,-24(s0)
    800058ae:	fffff097          	auipc	ra,0xfffff
    800058b2:	44e080e7          	jalr	1102(ra) # 80004cfc <fileread>
}
    800058b6:	70a2                	ld	ra,40(sp)
    800058b8:	7402                	ld	s0,32(sp)
    800058ba:	6145                	addi	sp,sp,48
    800058bc:	8082                	ret

00000000800058be <sys_write>:
{
    800058be:	7179                	addi	sp,sp,-48
    800058c0:	f406                	sd	ra,40(sp)
    800058c2:	f022                	sd	s0,32(sp)
    800058c4:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800058c6:	fd840593          	addi	a1,s0,-40
    800058ca:	4505                	li	a0,1
    800058cc:	ffffd097          	auipc	ra,0xffffd
    800058d0:	678080e7          	jalr	1656(ra) # 80002f44 <argaddr>
  argint(2, &n);
    800058d4:	fe440593          	addi	a1,s0,-28
    800058d8:	4509                	li	a0,2
    800058da:	ffffd097          	auipc	ra,0xffffd
    800058de:	648080e7          	jalr	1608(ra) # 80002f22 <argint>
  if(argfd(0, 0, &f) < 0)
    800058e2:	fe840613          	addi	a2,s0,-24
    800058e6:	4581                	li	a1,0
    800058e8:	4501                	li	a0,0
    800058ea:	00000097          	auipc	ra,0x0
    800058ee:	d00080e7          	jalr	-768(ra) # 800055ea <argfd>
    800058f2:	87aa                	mv	a5,a0
    return -1;
    800058f4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800058f6:	0007cc63          	bltz	a5,8000590e <sys_write+0x50>
  return filewrite(f, p, n);
    800058fa:	fe442603          	lw	a2,-28(s0)
    800058fe:	fd843583          	ld	a1,-40(s0)
    80005902:	fe843503          	ld	a0,-24(s0)
    80005906:	fffff097          	auipc	ra,0xfffff
    8000590a:	4b8080e7          	jalr	1208(ra) # 80004dbe <filewrite>
}
    8000590e:	70a2                	ld	ra,40(sp)
    80005910:	7402                	ld	s0,32(sp)
    80005912:	6145                	addi	sp,sp,48
    80005914:	8082                	ret

0000000080005916 <sys_close>:
{
    80005916:	1101                	addi	sp,sp,-32
    80005918:	ec06                	sd	ra,24(sp)
    8000591a:	e822                	sd	s0,16(sp)
    8000591c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000591e:	fe040613          	addi	a2,s0,-32
    80005922:	fec40593          	addi	a1,s0,-20
    80005926:	4501                	li	a0,0
    80005928:	00000097          	auipc	ra,0x0
    8000592c:	cc2080e7          	jalr	-830(ra) # 800055ea <argfd>
    return -1;
    80005930:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005932:	02054463          	bltz	a0,8000595a <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005936:	ffffc097          	auipc	ra,0xffffc
    8000593a:	090080e7          	jalr	144(ra) # 800019c6 <myproc>
    8000593e:	fec42783          	lw	a5,-20(s0)
    80005942:	07e9                	addi	a5,a5,26
    80005944:	078e                	slli	a5,a5,0x3
    80005946:	97aa                	add	a5,a5,a0
    80005948:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    8000594c:	fe043503          	ld	a0,-32(s0)
    80005950:	fffff097          	auipc	ra,0xfffff
    80005954:	272080e7          	jalr	626(ra) # 80004bc2 <fileclose>
  return 0;
    80005958:	4781                	li	a5,0
}
    8000595a:	853e                	mv	a0,a5
    8000595c:	60e2                	ld	ra,24(sp)
    8000595e:	6442                	ld	s0,16(sp)
    80005960:	6105                	addi	sp,sp,32
    80005962:	8082                	ret

0000000080005964 <sys_fstat>:
{
    80005964:	1101                	addi	sp,sp,-32
    80005966:	ec06                	sd	ra,24(sp)
    80005968:	e822                	sd	s0,16(sp)
    8000596a:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000596c:	fe040593          	addi	a1,s0,-32
    80005970:	4505                	li	a0,1
    80005972:	ffffd097          	auipc	ra,0xffffd
    80005976:	5d2080e7          	jalr	1490(ra) # 80002f44 <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000597a:	fe840613          	addi	a2,s0,-24
    8000597e:	4581                	li	a1,0
    80005980:	4501                	li	a0,0
    80005982:	00000097          	auipc	ra,0x0
    80005986:	c68080e7          	jalr	-920(ra) # 800055ea <argfd>
    8000598a:	87aa                	mv	a5,a0
    return -1;
    8000598c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000598e:	0007ca63          	bltz	a5,800059a2 <sys_fstat+0x3e>
  return filestat(f, st);
    80005992:	fe043583          	ld	a1,-32(s0)
    80005996:	fe843503          	ld	a0,-24(s0)
    8000599a:	fffff097          	auipc	ra,0xfffff
    8000599e:	2f0080e7          	jalr	752(ra) # 80004c8a <filestat>
}
    800059a2:	60e2                	ld	ra,24(sp)
    800059a4:	6442                	ld	s0,16(sp)
    800059a6:	6105                	addi	sp,sp,32
    800059a8:	8082                	ret

00000000800059aa <sys_link>:
{
    800059aa:	7169                	addi	sp,sp,-304
    800059ac:	f606                	sd	ra,296(sp)
    800059ae:	f222                	sd	s0,288(sp)
    800059b0:	ee26                	sd	s1,280(sp)
    800059b2:	ea4a                	sd	s2,272(sp)
    800059b4:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800059b6:	08000613          	li	a2,128
    800059ba:	ed040593          	addi	a1,s0,-304
    800059be:	4501                	li	a0,0
    800059c0:	ffffd097          	auipc	ra,0xffffd
    800059c4:	5a6080e7          	jalr	1446(ra) # 80002f66 <argstr>
    return -1;
    800059c8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800059ca:	10054e63          	bltz	a0,80005ae6 <sys_link+0x13c>
    800059ce:	08000613          	li	a2,128
    800059d2:	f5040593          	addi	a1,s0,-176
    800059d6:	4505                	li	a0,1
    800059d8:	ffffd097          	auipc	ra,0xffffd
    800059dc:	58e080e7          	jalr	1422(ra) # 80002f66 <argstr>
    return -1;
    800059e0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800059e2:	10054263          	bltz	a0,80005ae6 <sys_link+0x13c>
  begin_op();
    800059e6:	fffff097          	auipc	ra,0xfffff
    800059ea:	d10080e7          	jalr	-752(ra) # 800046f6 <begin_op>
  if((ip = namei(old)) == 0){
    800059ee:	ed040513          	addi	a0,s0,-304
    800059f2:	fffff097          	auipc	ra,0xfffff
    800059f6:	ae8080e7          	jalr	-1304(ra) # 800044da <namei>
    800059fa:	84aa                	mv	s1,a0
    800059fc:	c551                	beqz	a0,80005a88 <sys_link+0xde>
  ilock(ip);
    800059fe:	ffffe097          	auipc	ra,0xffffe
    80005a02:	336080e7          	jalr	822(ra) # 80003d34 <ilock>
  if(ip->type == T_DIR){
    80005a06:	04449703          	lh	a4,68(s1)
    80005a0a:	4785                	li	a5,1
    80005a0c:	08f70463          	beq	a4,a5,80005a94 <sys_link+0xea>
  ip->nlink++;
    80005a10:	04a4d783          	lhu	a5,74(s1)
    80005a14:	2785                	addiw	a5,a5,1
    80005a16:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005a1a:	8526                	mv	a0,s1
    80005a1c:	ffffe097          	auipc	ra,0xffffe
    80005a20:	24e080e7          	jalr	590(ra) # 80003c6a <iupdate>
  iunlock(ip);
    80005a24:	8526                	mv	a0,s1
    80005a26:	ffffe097          	auipc	ra,0xffffe
    80005a2a:	3d0080e7          	jalr	976(ra) # 80003df6 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005a2e:	fd040593          	addi	a1,s0,-48
    80005a32:	f5040513          	addi	a0,s0,-176
    80005a36:	fffff097          	auipc	ra,0xfffff
    80005a3a:	ac2080e7          	jalr	-1342(ra) # 800044f8 <nameiparent>
    80005a3e:	892a                	mv	s2,a0
    80005a40:	c935                	beqz	a0,80005ab4 <sys_link+0x10a>
  ilock(dp);
    80005a42:	ffffe097          	auipc	ra,0xffffe
    80005a46:	2f2080e7          	jalr	754(ra) # 80003d34 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005a4a:	00092703          	lw	a4,0(s2)
    80005a4e:	409c                	lw	a5,0(s1)
    80005a50:	04f71d63          	bne	a4,a5,80005aaa <sys_link+0x100>
    80005a54:	40d0                	lw	a2,4(s1)
    80005a56:	fd040593          	addi	a1,s0,-48
    80005a5a:	854a                	mv	a0,s2
    80005a5c:	fffff097          	auipc	ra,0xfffff
    80005a60:	9cc080e7          	jalr	-1588(ra) # 80004428 <dirlink>
    80005a64:	04054363          	bltz	a0,80005aaa <sys_link+0x100>
  iunlockput(dp);
    80005a68:	854a                	mv	a0,s2
    80005a6a:	ffffe097          	auipc	ra,0xffffe
    80005a6e:	52c080e7          	jalr	1324(ra) # 80003f96 <iunlockput>
  iput(ip);
    80005a72:	8526                	mv	a0,s1
    80005a74:	ffffe097          	auipc	ra,0xffffe
    80005a78:	47a080e7          	jalr	1146(ra) # 80003eee <iput>
  end_op();
    80005a7c:	fffff097          	auipc	ra,0xfffff
    80005a80:	cfa080e7          	jalr	-774(ra) # 80004776 <end_op>
  return 0;
    80005a84:	4781                	li	a5,0
    80005a86:	a085                	j	80005ae6 <sys_link+0x13c>
    end_op();
    80005a88:	fffff097          	auipc	ra,0xfffff
    80005a8c:	cee080e7          	jalr	-786(ra) # 80004776 <end_op>
    return -1;
    80005a90:	57fd                	li	a5,-1
    80005a92:	a891                	j	80005ae6 <sys_link+0x13c>
    iunlockput(ip);
    80005a94:	8526                	mv	a0,s1
    80005a96:	ffffe097          	auipc	ra,0xffffe
    80005a9a:	500080e7          	jalr	1280(ra) # 80003f96 <iunlockput>
    end_op();
    80005a9e:	fffff097          	auipc	ra,0xfffff
    80005aa2:	cd8080e7          	jalr	-808(ra) # 80004776 <end_op>
    return -1;
    80005aa6:	57fd                	li	a5,-1
    80005aa8:	a83d                	j	80005ae6 <sys_link+0x13c>
    iunlockput(dp);
    80005aaa:	854a                	mv	a0,s2
    80005aac:	ffffe097          	auipc	ra,0xffffe
    80005ab0:	4ea080e7          	jalr	1258(ra) # 80003f96 <iunlockput>
  ilock(ip);
    80005ab4:	8526                	mv	a0,s1
    80005ab6:	ffffe097          	auipc	ra,0xffffe
    80005aba:	27e080e7          	jalr	638(ra) # 80003d34 <ilock>
  ip->nlink--;
    80005abe:	04a4d783          	lhu	a5,74(s1)
    80005ac2:	37fd                	addiw	a5,a5,-1
    80005ac4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005ac8:	8526                	mv	a0,s1
    80005aca:	ffffe097          	auipc	ra,0xffffe
    80005ace:	1a0080e7          	jalr	416(ra) # 80003c6a <iupdate>
  iunlockput(ip);
    80005ad2:	8526                	mv	a0,s1
    80005ad4:	ffffe097          	auipc	ra,0xffffe
    80005ad8:	4c2080e7          	jalr	1218(ra) # 80003f96 <iunlockput>
  end_op();
    80005adc:	fffff097          	auipc	ra,0xfffff
    80005ae0:	c9a080e7          	jalr	-870(ra) # 80004776 <end_op>
  return -1;
    80005ae4:	57fd                	li	a5,-1
}
    80005ae6:	853e                	mv	a0,a5
    80005ae8:	70b2                	ld	ra,296(sp)
    80005aea:	7412                	ld	s0,288(sp)
    80005aec:	64f2                	ld	s1,280(sp)
    80005aee:	6952                	ld	s2,272(sp)
    80005af0:	6155                	addi	sp,sp,304
    80005af2:	8082                	ret

0000000080005af4 <sys_unlink>:
{
    80005af4:	7151                	addi	sp,sp,-240
    80005af6:	f586                	sd	ra,232(sp)
    80005af8:	f1a2                	sd	s0,224(sp)
    80005afa:	eda6                	sd	s1,216(sp)
    80005afc:	e9ca                	sd	s2,208(sp)
    80005afe:	e5ce                	sd	s3,200(sp)
    80005b00:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005b02:	08000613          	li	a2,128
    80005b06:	f3040593          	addi	a1,s0,-208
    80005b0a:	4501                	li	a0,0
    80005b0c:	ffffd097          	auipc	ra,0xffffd
    80005b10:	45a080e7          	jalr	1114(ra) # 80002f66 <argstr>
    80005b14:	18054163          	bltz	a0,80005c96 <sys_unlink+0x1a2>
  begin_op();
    80005b18:	fffff097          	auipc	ra,0xfffff
    80005b1c:	bde080e7          	jalr	-1058(ra) # 800046f6 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005b20:	fb040593          	addi	a1,s0,-80
    80005b24:	f3040513          	addi	a0,s0,-208
    80005b28:	fffff097          	auipc	ra,0xfffff
    80005b2c:	9d0080e7          	jalr	-1584(ra) # 800044f8 <nameiparent>
    80005b30:	84aa                	mv	s1,a0
    80005b32:	c979                	beqz	a0,80005c08 <sys_unlink+0x114>
  ilock(dp);
    80005b34:	ffffe097          	auipc	ra,0xffffe
    80005b38:	200080e7          	jalr	512(ra) # 80003d34 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005b3c:	00003597          	auipc	a1,0x3
    80005b40:	cfc58593          	addi	a1,a1,-772 # 80008838 <syscallnum+0x258>
    80005b44:	fb040513          	addi	a0,s0,-80
    80005b48:	ffffe097          	auipc	ra,0xffffe
    80005b4c:	6b6080e7          	jalr	1718(ra) # 800041fe <namecmp>
    80005b50:	14050a63          	beqz	a0,80005ca4 <sys_unlink+0x1b0>
    80005b54:	00003597          	auipc	a1,0x3
    80005b58:	cec58593          	addi	a1,a1,-788 # 80008840 <syscallnum+0x260>
    80005b5c:	fb040513          	addi	a0,s0,-80
    80005b60:	ffffe097          	auipc	ra,0xffffe
    80005b64:	69e080e7          	jalr	1694(ra) # 800041fe <namecmp>
    80005b68:	12050e63          	beqz	a0,80005ca4 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005b6c:	f2c40613          	addi	a2,s0,-212
    80005b70:	fb040593          	addi	a1,s0,-80
    80005b74:	8526                	mv	a0,s1
    80005b76:	ffffe097          	auipc	ra,0xffffe
    80005b7a:	6a2080e7          	jalr	1698(ra) # 80004218 <dirlookup>
    80005b7e:	892a                	mv	s2,a0
    80005b80:	12050263          	beqz	a0,80005ca4 <sys_unlink+0x1b0>
  ilock(ip);
    80005b84:	ffffe097          	auipc	ra,0xffffe
    80005b88:	1b0080e7          	jalr	432(ra) # 80003d34 <ilock>
  if(ip->nlink < 1)
    80005b8c:	04a91783          	lh	a5,74(s2)
    80005b90:	08f05263          	blez	a5,80005c14 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005b94:	04491703          	lh	a4,68(s2)
    80005b98:	4785                	li	a5,1
    80005b9a:	08f70563          	beq	a4,a5,80005c24 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005b9e:	4641                	li	a2,16
    80005ba0:	4581                	li	a1,0
    80005ba2:	fc040513          	addi	a0,s0,-64
    80005ba6:	ffffb097          	auipc	ra,0xffffb
    80005baa:	140080e7          	jalr	320(ra) # 80000ce6 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005bae:	4741                	li	a4,16
    80005bb0:	f2c42683          	lw	a3,-212(s0)
    80005bb4:	fc040613          	addi	a2,s0,-64
    80005bb8:	4581                	li	a1,0
    80005bba:	8526                	mv	a0,s1
    80005bbc:	ffffe097          	auipc	ra,0xffffe
    80005bc0:	524080e7          	jalr	1316(ra) # 800040e0 <writei>
    80005bc4:	47c1                	li	a5,16
    80005bc6:	0af51563          	bne	a0,a5,80005c70 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005bca:	04491703          	lh	a4,68(s2)
    80005bce:	4785                	li	a5,1
    80005bd0:	0af70863          	beq	a4,a5,80005c80 <sys_unlink+0x18c>
  iunlockput(dp);
    80005bd4:	8526                	mv	a0,s1
    80005bd6:	ffffe097          	auipc	ra,0xffffe
    80005bda:	3c0080e7          	jalr	960(ra) # 80003f96 <iunlockput>
  ip->nlink--;
    80005bde:	04a95783          	lhu	a5,74(s2)
    80005be2:	37fd                	addiw	a5,a5,-1
    80005be4:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005be8:	854a                	mv	a0,s2
    80005bea:	ffffe097          	auipc	ra,0xffffe
    80005bee:	080080e7          	jalr	128(ra) # 80003c6a <iupdate>
  iunlockput(ip);
    80005bf2:	854a                	mv	a0,s2
    80005bf4:	ffffe097          	auipc	ra,0xffffe
    80005bf8:	3a2080e7          	jalr	930(ra) # 80003f96 <iunlockput>
  end_op();
    80005bfc:	fffff097          	auipc	ra,0xfffff
    80005c00:	b7a080e7          	jalr	-1158(ra) # 80004776 <end_op>
  return 0;
    80005c04:	4501                	li	a0,0
    80005c06:	a84d                	j	80005cb8 <sys_unlink+0x1c4>
    end_op();
    80005c08:	fffff097          	auipc	ra,0xfffff
    80005c0c:	b6e080e7          	jalr	-1170(ra) # 80004776 <end_op>
    return -1;
    80005c10:	557d                	li	a0,-1
    80005c12:	a05d                	j	80005cb8 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005c14:	00003517          	auipc	a0,0x3
    80005c18:	c3450513          	addi	a0,a0,-972 # 80008848 <syscallnum+0x268>
    80005c1c:	ffffb097          	auipc	ra,0xffffb
    80005c20:	928080e7          	jalr	-1752(ra) # 80000544 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005c24:	04c92703          	lw	a4,76(s2)
    80005c28:	02000793          	li	a5,32
    80005c2c:	f6e7f9e3          	bgeu	a5,a4,80005b9e <sys_unlink+0xaa>
    80005c30:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005c34:	4741                	li	a4,16
    80005c36:	86ce                	mv	a3,s3
    80005c38:	f1840613          	addi	a2,s0,-232
    80005c3c:	4581                	li	a1,0
    80005c3e:	854a                	mv	a0,s2
    80005c40:	ffffe097          	auipc	ra,0xffffe
    80005c44:	3a8080e7          	jalr	936(ra) # 80003fe8 <readi>
    80005c48:	47c1                	li	a5,16
    80005c4a:	00f51b63          	bne	a0,a5,80005c60 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005c4e:	f1845783          	lhu	a5,-232(s0)
    80005c52:	e7a1                	bnez	a5,80005c9a <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005c54:	29c1                	addiw	s3,s3,16
    80005c56:	04c92783          	lw	a5,76(s2)
    80005c5a:	fcf9ede3          	bltu	s3,a5,80005c34 <sys_unlink+0x140>
    80005c5e:	b781                	j	80005b9e <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005c60:	00003517          	auipc	a0,0x3
    80005c64:	c0050513          	addi	a0,a0,-1024 # 80008860 <syscallnum+0x280>
    80005c68:	ffffb097          	auipc	ra,0xffffb
    80005c6c:	8dc080e7          	jalr	-1828(ra) # 80000544 <panic>
    panic("unlink: writei");
    80005c70:	00003517          	auipc	a0,0x3
    80005c74:	c0850513          	addi	a0,a0,-1016 # 80008878 <syscallnum+0x298>
    80005c78:	ffffb097          	auipc	ra,0xffffb
    80005c7c:	8cc080e7          	jalr	-1844(ra) # 80000544 <panic>
    dp->nlink--;
    80005c80:	04a4d783          	lhu	a5,74(s1)
    80005c84:	37fd                	addiw	a5,a5,-1
    80005c86:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005c8a:	8526                	mv	a0,s1
    80005c8c:	ffffe097          	auipc	ra,0xffffe
    80005c90:	fde080e7          	jalr	-34(ra) # 80003c6a <iupdate>
    80005c94:	b781                	j	80005bd4 <sys_unlink+0xe0>
    return -1;
    80005c96:	557d                	li	a0,-1
    80005c98:	a005                	j	80005cb8 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005c9a:	854a                	mv	a0,s2
    80005c9c:	ffffe097          	auipc	ra,0xffffe
    80005ca0:	2fa080e7          	jalr	762(ra) # 80003f96 <iunlockput>
  iunlockput(dp);
    80005ca4:	8526                	mv	a0,s1
    80005ca6:	ffffe097          	auipc	ra,0xffffe
    80005caa:	2f0080e7          	jalr	752(ra) # 80003f96 <iunlockput>
  end_op();
    80005cae:	fffff097          	auipc	ra,0xfffff
    80005cb2:	ac8080e7          	jalr	-1336(ra) # 80004776 <end_op>
  return -1;
    80005cb6:	557d                	li	a0,-1
}
    80005cb8:	70ae                	ld	ra,232(sp)
    80005cba:	740e                	ld	s0,224(sp)
    80005cbc:	64ee                	ld	s1,216(sp)
    80005cbe:	694e                	ld	s2,208(sp)
    80005cc0:	69ae                	ld	s3,200(sp)
    80005cc2:	616d                	addi	sp,sp,240
    80005cc4:	8082                	ret

0000000080005cc6 <sys_open>:

uint64
sys_open(void)
{
    80005cc6:	7131                	addi	sp,sp,-192
    80005cc8:	fd06                	sd	ra,184(sp)
    80005cca:	f922                	sd	s0,176(sp)
    80005ccc:	f526                	sd	s1,168(sp)
    80005cce:	f14a                	sd	s2,160(sp)
    80005cd0:	ed4e                	sd	s3,152(sp)
    80005cd2:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005cd4:	f4c40593          	addi	a1,s0,-180
    80005cd8:	4505                	li	a0,1
    80005cda:	ffffd097          	auipc	ra,0xffffd
    80005cde:	248080e7          	jalr	584(ra) # 80002f22 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005ce2:	08000613          	li	a2,128
    80005ce6:	f5040593          	addi	a1,s0,-176
    80005cea:	4501                	li	a0,0
    80005cec:	ffffd097          	auipc	ra,0xffffd
    80005cf0:	27a080e7          	jalr	634(ra) # 80002f66 <argstr>
    80005cf4:	87aa                	mv	a5,a0
    return -1;
    80005cf6:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005cf8:	0a07c963          	bltz	a5,80005daa <sys_open+0xe4>

  begin_op();
    80005cfc:	fffff097          	auipc	ra,0xfffff
    80005d00:	9fa080e7          	jalr	-1542(ra) # 800046f6 <begin_op>

  if(omode & O_CREATE){
    80005d04:	f4c42783          	lw	a5,-180(s0)
    80005d08:	2007f793          	andi	a5,a5,512
    80005d0c:	cfc5                	beqz	a5,80005dc4 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005d0e:	4681                	li	a3,0
    80005d10:	4601                	li	a2,0
    80005d12:	4589                	li	a1,2
    80005d14:	f5040513          	addi	a0,s0,-176
    80005d18:	00000097          	auipc	ra,0x0
    80005d1c:	974080e7          	jalr	-1676(ra) # 8000568c <create>
    80005d20:	84aa                	mv	s1,a0
    if(ip == 0){
    80005d22:	c959                	beqz	a0,80005db8 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005d24:	04449703          	lh	a4,68(s1)
    80005d28:	478d                	li	a5,3
    80005d2a:	00f71763          	bne	a4,a5,80005d38 <sys_open+0x72>
    80005d2e:	0464d703          	lhu	a4,70(s1)
    80005d32:	47a5                	li	a5,9
    80005d34:	0ce7ed63          	bltu	a5,a4,80005e0e <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005d38:	fffff097          	auipc	ra,0xfffff
    80005d3c:	dce080e7          	jalr	-562(ra) # 80004b06 <filealloc>
    80005d40:	89aa                	mv	s3,a0
    80005d42:	10050363          	beqz	a0,80005e48 <sys_open+0x182>
    80005d46:	00000097          	auipc	ra,0x0
    80005d4a:	904080e7          	jalr	-1788(ra) # 8000564a <fdalloc>
    80005d4e:	892a                	mv	s2,a0
    80005d50:	0e054763          	bltz	a0,80005e3e <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005d54:	04449703          	lh	a4,68(s1)
    80005d58:	478d                	li	a5,3
    80005d5a:	0cf70563          	beq	a4,a5,80005e24 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005d5e:	4789                	li	a5,2
    80005d60:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005d64:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005d68:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005d6c:	f4c42783          	lw	a5,-180(s0)
    80005d70:	0017c713          	xori	a4,a5,1
    80005d74:	8b05                	andi	a4,a4,1
    80005d76:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005d7a:	0037f713          	andi	a4,a5,3
    80005d7e:	00e03733          	snez	a4,a4
    80005d82:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005d86:	4007f793          	andi	a5,a5,1024
    80005d8a:	c791                	beqz	a5,80005d96 <sys_open+0xd0>
    80005d8c:	04449703          	lh	a4,68(s1)
    80005d90:	4789                	li	a5,2
    80005d92:	0af70063          	beq	a4,a5,80005e32 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005d96:	8526                	mv	a0,s1
    80005d98:	ffffe097          	auipc	ra,0xffffe
    80005d9c:	05e080e7          	jalr	94(ra) # 80003df6 <iunlock>
  end_op();
    80005da0:	fffff097          	auipc	ra,0xfffff
    80005da4:	9d6080e7          	jalr	-1578(ra) # 80004776 <end_op>

  return fd;
    80005da8:	854a                	mv	a0,s2
}
    80005daa:	70ea                	ld	ra,184(sp)
    80005dac:	744a                	ld	s0,176(sp)
    80005dae:	74aa                	ld	s1,168(sp)
    80005db0:	790a                	ld	s2,160(sp)
    80005db2:	69ea                	ld	s3,152(sp)
    80005db4:	6129                	addi	sp,sp,192
    80005db6:	8082                	ret
      end_op();
    80005db8:	fffff097          	auipc	ra,0xfffff
    80005dbc:	9be080e7          	jalr	-1602(ra) # 80004776 <end_op>
      return -1;
    80005dc0:	557d                	li	a0,-1
    80005dc2:	b7e5                	j	80005daa <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005dc4:	f5040513          	addi	a0,s0,-176
    80005dc8:	ffffe097          	auipc	ra,0xffffe
    80005dcc:	712080e7          	jalr	1810(ra) # 800044da <namei>
    80005dd0:	84aa                	mv	s1,a0
    80005dd2:	c905                	beqz	a0,80005e02 <sys_open+0x13c>
    ilock(ip);
    80005dd4:	ffffe097          	auipc	ra,0xffffe
    80005dd8:	f60080e7          	jalr	-160(ra) # 80003d34 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005ddc:	04449703          	lh	a4,68(s1)
    80005de0:	4785                	li	a5,1
    80005de2:	f4f711e3          	bne	a4,a5,80005d24 <sys_open+0x5e>
    80005de6:	f4c42783          	lw	a5,-180(s0)
    80005dea:	d7b9                	beqz	a5,80005d38 <sys_open+0x72>
      iunlockput(ip);
    80005dec:	8526                	mv	a0,s1
    80005dee:	ffffe097          	auipc	ra,0xffffe
    80005df2:	1a8080e7          	jalr	424(ra) # 80003f96 <iunlockput>
      end_op();
    80005df6:	fffff097          	auipc	ra,0xfffff
    80005dfa:	980080e7          	jalr	-1664(ra) # 80004776 <end_op>
      return -1;
    80005dfe:	557d                	li	a0,-1
    80005e00:	b76d                	j	80005daa <sys_open+0xe4>
      end_op();
    80005e02:	fffff097          	auipc	ra,0xfffff
    80005e06:	974080e7          	jalr	-1676(ra) # 80004776 <end_op>
      return -1;
    80005e0a:	557d                	li	a0,-1
    80005e0c:	bf79                	j	80005daa <sys_open+0xe4>
    iunlockput(ip);
    80005e0e:	8526                	mv	a0,s1
    80005e10:	ffffe097          	auipc	ra,0xffffe
    80005e14:	186080e7          	jalr	390(ra) # 80003f96 <iunlockput>
    end_op();
    80005e18:	fffff097          	auipc	ra,0xfffff
    80005e1c:	95e080e7          	jalr	-1698(ra) # 80004776 <end_op>
    return -1;
    80005e20:	557d                	li	a0,-1
    80005e22:	b761                	j	80005daa <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005e24:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005e28:	04649783          	lh	a5,70(s1)
    80005e2c:	02f99223          	sh	a5,36(s3)
    80005e30:	bf25                	j	80005d68 <sys_open+0xa2>
    itrunc(ip);
    80005e32:	8526                	mv	a0,s1
    80005e34:	ffffe097          	auipc	ra,0xffffe
    80005e38:	00e080e7          	jalr	14(ra) # 80003e42 <itrunc>
    80005e3c:	bfa9                	j	80005d96 <sys_open+0xd0>
      fileclose(f);
    80005e3e:	854e                	mv	a0,s3
    80005e40:	fffff097          	auipc	ra,0xfffff
    80005e44:	d82080e7          	jalr	-638(ra) # 80004bc2 <fileclose>
    iunlockput(ip);
    80005e48:	8526                	mv	a0,s1
    80005e4a:	ffffe097          	auipc	ra,0xffffe
    80005e4e:	14c080e7          	jalr	332(ra) # 80003f96 <iunlockput>
    end_op();
    80005e52:	fffff097          	auipc	ra,0xfffff
    80005e56:	924080e7          	jalr	-1756(ra) # 80004776 <end_op>
    return -1;
    80005e5a:	557d                	li	a0,-1
    80005e5c:	b7b9                	j	80005daa <sys_open+0xe4>

0000000080005e5e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005e5e:	7175                	addi	sp,sp,-144
    80005e60:	e506                	sd	ra,136(sp)
    80005e62:	e122                	sd	s0,128(sp)
    80005e64:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005e66:	fffff097          	auipc	ra,0xfffff
    80005e6a:	890080e7          	jalr	-1904(ra) # 800046f6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005e6e:	08000613          	li	a2,128
    80005e72:	f7040593          	addi	a1,s0,-144
    80005e76:	4501                	li	a0,0
    80005e78:	ffffd097          	auipc	ra,0xffffd
    80005e7c:	0ee080e7          	jalr	238(ra) # 80002f66 <argstr>
    80005e80:	02054963          	bltz	a0,80005eb2 <sys_mkdir+0x54>
    80005e84:	4681                	li	a3,0
    80005e86:	4601                	li	a2,0
    80005e88:	4585                	li	a1,1
    80005e8a:	f7040513          	addi	a0,s0,-144
    80005e8e:	fffff097          	auipc	ra,0xfffff
    80005e92:	7fe080e7          	jalr	2046(ra) # 8000568c <create>
    80005e96:	cd11                	beqz	a0,80005eb2 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005e98:	ffffe097          	auipc	ra,0xffffe
    80005e9c:	0fe080e7          	jalr	254(ra) # 80003f96 <iunlockput>
  end_op();
    80005ea0:	fffff097          	auipc	ra,0xfffff
    80005ea4:	8d6080e7          	jalr	-1834(ra) # 80004776 <end_op>
  return 0;
    80005ea8:	4501                	li	a0,0
}
    80005eaa:	60aa                	ld	ra,136(sp)
    80005eac:	640a                	ld	s0,128(sp)
    80005eae:	6149                	addi	sp,sp,144
    80005eb0:	8082                	ret
    end_op();
    80005eb2:	fffff097          	auipc	ra,0xfffff
    80005eb6:	8c4080e7          	jalr	-1852(ra) # 80004776 <end_op>
    return -1;
    80005eba:	557d                	li	a0,-1
    80005ebc:	b7fd                	j	80005eaa <sys_mkdir+0x4c>

0000000080005ebe <sys_mknod>:

uint64
sys_mknod(void)
{
    80005ebe:	7135                	addi	sp,sp,-160
    80005ec0:	ed06                	sd	ra,152(sp)
    80005ec2:	e922                	sd	s0,144(sp)
    80005ec4:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005ec6:	fffff097          	auipc	ra,0xfffff
    80005eca:	830080e7          	jalr	-2000(ra) # 800046f6 <begin_op>
  argint(1, &major);
    80005ece:	f6c40593          	addi	a1,s0,-148
    80005ed2:	4505                	li	a0,1
    80005ed4:	ffffd097          	auipc	ra,0xffffd
    80005ed8:	04e080e7          	jalr	78(ra) # 80002f22 <argint>
  argint(2, &minor);
    80005edc:	f6840593          	addi	a1,s0,-152
    80005ee0:	4509                	li	a0,2
    80005ee2:	ffffd097          	auipc	ra,0xffffd
    80005ee6:	040080e7          	jalr	64(ra) # 80002f22 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005eea:	08000613          	li	a2,128
    80005eee:	f7040593          	addi	a1,s0,-144
    80005ef2:	4501                	li	a0,0
    80005ef4:	ffffd097          	auipc	ra,0xffffd
    80005ef8:	072080e7          	jalr	114(ra) # 80002f66 <argstr>
    80005efc:	02054b63          	bltz	a0,80005f32 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005f00:	f6841683          	lh	a3,-152(s0)
    80005f04:	f6c41603          	lh	a2,-148(s0)
    80005f08:	458d                	li	a1,3
    80005f0a:	f7040513          	addi	a0,s0,-144
    80005f0e:	fffff097          	auipc	ra,0xfffff
    80005f12:	77e080e7          	jalr	1918(ra) # 8000568c <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005f16:	cd11                	beqz	a0,80005f32 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005f18:	ffffe097          	auipc	ra,0xffffe
    80005f1c:	07e080e7          	jalr	126(ra) # 80003f96 <iunlockput>
  end_op();
    80005f20:	fffff097          	auipc	ra,0xfffff
    80005f24:	856080e7          	jalr	-1962(ra) # 80004776 <end_op>
  return 0;
    80005f28:	4501                	li	a0,0
}
    80005f2a:	60ea                	ld	ra,152(sp)
    80005f2c:	644a                	ld	s0,144(sp)
    80005f2e:	610d                	addi	sp,sp,160
    80005f30:	8082                	ret
    end_op();
    80005f32:	fffff097          	auipc	ra,0xfffff
    80005f36:	844080e7          	jalr	-1980(ra) # 80004776 <end_op>
    return -1;
    80005f3a:	557d                	li	a0,-1
    80005f3c:	b7fd                	j	80005f2a <sys_mknod+0x6c>

0000000080005f3e <sys_chdir>:

uint64
sys_chdir(void)
{
    80005f3e:	7135                	addi	sp,sp,-160
    80005f40:	ed06                	sd	ra,152(sp)
    80005f42:	e922                	sd	s0,144(sp)
    80005f44:	e526                	sd	s1,136(sp)
    80005f46:	e14a                	sd	s2,128(sp)
    80005f48:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005f4a:	ffffc097          	auipc	ra,0xffffc
    80005f4e:	a7c080e7          	jalr	-1412(ra) # 800019c6 <myproc>
    80005f52:	892a                	mv	s2,a0
  
  begin_op();
    80005f54:	ffffe097          	auipc	ra,0xffffe
    80005f58:	7a2080e7          	jalr	1954(ra) # 800046f6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005f5c:	08000613          	li	a2,128
    80005f60:	f6040593          	addi	a1,s0,-160
    80005f64:	4501                	li	a0,0
    80005f66:	ffffd097          	auipc	ra,0xffffd
    80005f6a:	000080e7          	jalr	ra # 80002f66 <argstr>
    80005f6e:	04054b63          	bltz	a0,80005fc4 <sys_chdir+0x86>
    80005f72:	f6040513          	addi	a0,s0,-160
    80005f76:	ffffe097          	auipc	ra,0xffffe
    80005f7a:	564080e7          	jalr	1380(ra) # 800044da <namei>
    80005f7e:	84aa                	mv	s1,a0
    80005f80:	c131                	beqz	a0,80005fc4 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005f82:	ffffe097          	auipc	ra,0xffffe
    80005f86:	db2080e7          	jalr	-590(ra) # 80003d34 <ilock>
  if(ip->type != T_DIR){
    80005f8a:	04449703          	lh	a4,68(s1)
    80005f8e:	4785                	li	a5,1
    80005f90:	04f71063          	bne	a4,a5,80005fd0 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005f94:	8526                	mv	a0,s1
    80005f96:	ffffe097          	auipc	ra,0xffffe
    80005f9a:	e60080e7          	jalr	-416(ra) # 80003df6 <iunlock>
  iput(p->cwd);
    80005f9e:	15093503          	ld	a0,336(s2)
    80005fa2:	ffffe097          	auipc	ra,0xffffe
    80005fa6:	f4c080e7          	jalr	-180(ra) # 80003eee <iput>
  end_op();
    80005faa:	ffffe097          	auipc	ra,0xffffe
    80005fae:	7cc080e7          	jalr	1996(ra) # 80004776 <end_op>
  p->cwd = ip;
    80005fb2:	14993823          	sd	s1,336(s2)
  return 0;
    80005fb6:	4501                	li	a0,0
}
    80005fb8:	60ea                	ld	ra,152(sp)
    80005fba:	644a                	ld	s0,144(sp)
    80005fbc:	64aa                	ld	s1,136(sp)
    80005fbe:	690a                	ld	s2,128(sp)
    80005fc0:	610d                	addi	sp,sp,160
    80005fc2:	8082                	ret
    end_op();
    80005fc4:	ffffe097          	auipc	ra,0xffffe
    80005fc8:	7b2080e7          	jalr	1970(ra) # 80004776 <end_op>
    return -1;
    80005fcc:	557d                	li	a0,-1
    80005fce:	b7ed                	j	80005fb8 <sys_chdir+0x7a>
    iunlockput(ip);
    80005fd0:	8526                	mv	a0,s1
    80005fd2:	ffffe097          	auipc	ra,0xffffe
    80005fd6:	fc4080e7          	jalr	-60(ra) # 80003f96 <iunlockput>
    end_op();
    80005fda:	ffffe097          	auipc	ra,0xffffe
    80005fde:	79c080e7          	jalr	1948(ra) # 80004776 <end_op>
    return -1;
    80005fe2:	557d                	li	a0,-1
    80005fe4:	bfd1                	j	80005fb8 <sys_chdir+0x7a>

0000000080005fe6 <sys_exec>:

uint64
sys_exec(void)
{
    80005fe6:	7145                	addi	sp,sp,-464
    80005fe8:	e786                	sd	ra,456(sp)
    80005fea:	e3a2                	sd	s0,448(sp)
    80005fec:	ff26                	sd	s1,440(sp)
    80005fee:	fb4a                	sd	s2,432(sp)
    80005ff0:	f74e                	sd	s3,424(sp)
    80005ff2:	f352                	sd	s4,416(sp)
    80005ff4:	ef56                	sd	s5,408(sp)
    80005ff6:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005ff8:	e3840593          	addi	a1,s0,-456
    80005ffc:	4505                	li	a0,1
    80005ffe:	ffffd097          	auipc	ra,0xffffd
    80006002:	f46080e7          	jalr	-186(ra) # 80002f44 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80006006:	08000613          	li	a2,128
    8000600a:	f4040593          	addi	a1,s0,-192
    8000600e:	4501                	li	a0,0
    80006010:	ffffd097          	auipc	ra,0xffffd
    80006014:	f56080e7          	jalr	-170(ra) # 80002f66 <argstr>
    80006018:	87aa                	mv	a5,a0
    return -1;
    8000601a:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000601c:	0c07c263          	bltz	a5,800060e0 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80006020:	10000613          	li	a2,256
    80006024:	4581                	li	a1,0
    80006026:	e4040513          	addi	a0,s0,-448
    8000602a:	ffffb097          	auipc	ra,0xffffb
    8000602e:	cbc080e7          	jalr	-836(ra) # 80000ce6 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006032:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80006036:	89a6                	mv	s3,s1
    80006038:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000603a:	02000a13          	li	s4,32
    8000603e:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006042:	00391513          	slli	a0,s2,0x3
    80006046:	e3040593          	addi	a1,s0,-464
    8000604a:	e3843783          	ld	a5,-456(s0)
    8000604e:	953e                	add	a0,a0,a5
    80006050:	ffffd097          	auipc	ra,0xffffd
    80006054:	e34080e7          	jalr	-460(ra) # 80002e84 <fetchaddr>
    80006058:	02054a63          	bltz	a0,8000608c <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    8000605c:	e3043783          	ld	a5,-464(s0)
    80006060:	c3b9                	beqz	a5,800060a6 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006062:	ffffb097          	auipc	ra,0xffffb
    80006066:	a98080e7          	jalr	-1384(ra) # 80000afa <kalloc>
    8000606a:	85aa                	mv	a1,a0
    8000606c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006070:	cd11                	beqz	a0,8000608c <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006072:	6605                	lui	a2,0x1
    80006074:	e3043503          	ld	a0,-464(s0)
    80006078:	ffffd097          	auipc	ra,0xffffd
    8000607c:	e5e080e7          	jalr	-418(ra) # 80002ed6 <fetchstr>
    80006080:	00054663          	bltz	a0,8000608c <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80006084:	0905                	addi	s2,s2,1
    80006086:	09a1                	addi	s3,s3,8
    80006088:	fb491be3          	bne	s2,s4,8000603e <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000608c:	10048913          	addi	s2,s1,256
    80006090:	6088                	ld	a0,0(s1)
    80006092:	c531                	beqz	a0,800060de <sys_exec+0xf8>
    kfree(argv[i]);
    80006094:	ffffb097          	auipc	ra,0xffffb
    80006098:	96a080e7          	jalr	-1686(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000609c:	04a1                	addi	s1,s1,8
    8000609e:	ff2499e3          	bne	s1,s2,80006090 <sys_exec+0xaa>
  return -1;
    800060a2:	557d                	li	a0,-1
    800060a4:	a835                	j	800060e0 <sys_exec+0xfa>
      argv[i] = 0;
    800060a6:	0a8e                	slli	s5,s5,0x3
    800060a8:	fc040793          	addi	a5,s0,-64
    800060ac:	9abe                	add	s5,s5,a5
    800060ae:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    800060b2:	e4040593          	addi	a1,s0,-448
    800060b6:	f4040513          	addi	a0,s0,-192
    800060ba:	fffff097          	auipc	ra,0xfffff
    800060be:	190080e7          	jalr	400(ra) # 8000524a <exec>
    800060c2:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800060c4:	10048993          	addi	s3,s1,256
    800060c8:	6088                	ld	a0,0(s1)
    800060ca:	c901                	beqz	a0,800060da <sys_exec+0xf4>
    kfree(argv[i]);
    800060cc:	ffffb097          	auipc	ra,0xffffb
    800060d0:	932080e7          	jalr	-1742(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800060d4:	04a1                	addi	s1,s1,8
    800060d6:	ff3499e3          	bne	s1,s3,800060c8 <sys_exec+0xe2>
  return ret;
    800060da:	854a                	mv	a0,s2
    800060dc:	a011                	j	800060e0 <sys_exec+0xfa>
  return -1;
    800060de:	557d                	li	a0,-1
}
    800060e0:	60be                	ld	ra,456(sp)
    800060e2:	641e                	ld	s0,448(sp)
    800060e4:	74fa                	ld	s1,440(sp)
    800060e6:	795a                	ld	s2,432(sp)
    800060e8:	79ba                	ld	s3,424(sp)
    800060ea:	7a1a                	ld	s4,416(sp)
    800060ec:	6afa                	ld	s5,408(sp)
    800060ee:	6179                	addi	sp,sp,464
    800060f0:	8082                	ret

00000000800060f2 <sys_pipe>:

uint64
sys_pipe(void)
{
    800060f2:	7139                	addi	sp,sp,-64
    800060f4:	fc06                	sd	ra,56(sp)
    800060f6:	f822                	sd	s0,48(sp)
    800060f8:	f426                	sd	s1,40(sp)
    800060fa:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800060fc:	ffffc097          	auipc	ra,0xffffc
    80006100:	8ca080e7          	jalr	-1846(ra) # 800019c6 <myproc>
    80006104:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80006106:	fd840593          	addi	a1,s0,-40
    8000610a:	4501                	li	a0,0
    8000610c:	ffffd097          	auipc	ra,0xffffd
    80006110:	e38080e7          	jalr	-456(ra) # 80002f44 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80006114:	fc840593          	addi	a1,s0,-56
    80006118:	fd040513          	addi	a0,s0,-48
    8000611c:	fffff097          	auipc	ra,0xfffff
    80006120:	dd6080e7          	jalr	-554(ra) # 80004ef2 <pipealloc>
    return -1;
    80006124:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006126:	0c054463          	bltz	a0,800061ee <sys_pipe+0xfc>
  fd0 = -1;
    8000612a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000612e:	fd043503          	ld	a0,-48(s0)
    80006132:	fffff097          	auipc	ra,0xfffff
    80006136:	518080e7          	jalr	1304(ra) # 8000564a <fdalloc>
    8000613a:	fca42223          	sw	a0,-60(s0)
    8000613e:	08054b63          	bltz	a0,800061d4 <sys_pipe+0xe2>
    80006142:	fc843503          	ld	a0,-56(s0)
    80006146:	fffff097          	auipc	ra,0xfffff
    8000614a:	504080e7          	jalr	1284(ra) # 8000564a <fdalloc>
    8000614e:	fca42023          	sw	a0,-64(s0)
    80006152:	06054863          	bltz	a0,800061c2 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006156:	4691                	li	a3,4
    80006158:	fc440613          	addi	a2,s0,-60
    8000615c:	fd843583          	ld	a1,-40(s0)
    80006160:	68a8                	ld	a0,80(s1)
    80006162:	ffffb097          	auipc	ra,0xffffb
    80006166:	522080e7          	jalr	1314(ra) # 80001684 <copyout>
    8000616a:	02054063          	bltz	a0,8000618a <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000616e:	4691                	li	a3,4
    80006170:	fc040613          	addi	a2,s0,-64
    80006174:	fd843583          	ld	a1,-40(s0)
    80006178:	0591                	addi	a1,a1,4
    8000617a:	68a8                	ld	a0,80(s1)
    8000617c:	ffffb097          	auipc	ra,0xffffb
    80006180:	508080e7          	jalr	1288(ra) # 80001684 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006184:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006186:	06055463          	bgez	a0,800061ee <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    8000618a:	fc442783          	lw	a5,-60(s0)
    8000618e:	07e9                	addi	a5,a5,26
    80006190:	078e                	slli	a5,a5,0x3
    80006192:	97a6                	add	a5,a5,s1
    80006194:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006198:	fc042503          	lw	a0,-64(s0)
    8000619c:	0569                	addi	a0,a0,26
    8000619e:	050e                	slli	a0,a0,0x3
    800061a0:	94aa                	add	s1,s1,a0
    800061a2:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800061a6:	fd043503          	ld	a0,-48(s0)
    800061aa:	fffff097          	auipc	ra,0xfffff
    800061ae:	a18080e7          	jalr	-1512(ra) # 80004bc2 <fileclose>
    fileclose(wf);
    800061b2:	fc843503          	ld	a0,-56(s0)
    800061b6:	fffff097          	auipc	ra,0xfffff
    800061ba:	a0c080e7          	jalr	-1524(ra) # 80004bc2 <fileclose>
    return -1;
    800061be:	57fd                	li	a5,-1
    800061c0:	a03d                	j	800061ee <sys_pipe+0xfc>
    if(fd0 >= 0)
    800061c2:	fc442783          	lw	a5,-60(s0)
    800061c6:	0007c763          	bltz	a5,800061d4 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    800061ca:	07e9                	addi	a5,a5,26
    800061cc:	078e                	slli	a5,a5,0x3
    800061ce:	94be                	add	s1,s1,a5
    800061d0:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800061d4:	fd043503          	ld	a0,-48(s0)
    800061d8:	fffff097          	auipc	ra,0xfffff
    800061dc:	9ea080e7          	jalr	-1558(ra) # 80004bc2 <fileclose>
    fileclose(wf);
    800061e0:	fc843503          	ld	a0,-56(s0)
    800061e4:	fffff097          	auipc	ra,0xfffff
    800061e8:	9de080e7          	jalr	-1570(ra) # 80004bc2 <fileclose>
    return -1;
    800061ec:	57fd                	li	a5,-1
}
    800061ee:	853e                	mv	a0,a5
    800061f0:	70e2                	ld	ra,56(sp)
    800061f2:	7442                	ld	s0,48(sp)
    800061f4:	74a2                	ld	s1,40(sp)
    800061f6:	6121                	addi	sp,sp,64
    800061f8:	8082                	ret
    800061fa:	0000                	unimp
    800061fc:	0000                	unimp
	...

0000000080006200 <kernelvec>:
    80006200:	7111                	addi	sp,sp,-256
    80006202:	e006                	sd	ra,0(sp)
    80006204:	e40a                	sd	sp,8(sp)
    80006206:	e80e                	sd	gp,16(sp)
    80006208:	ec12                	sd	tp,24(sp)
    8000620a:	f016                	sd	t0,32(sp)
    8000620c:	f41a                	sd	t1,40(sp)
    8000620e:	f81e                	sd	t2,48(sp)
    80006210:	fc22                	sd	s0,56(sp)
    80006212:	e0a6                	sd	s1,64(sp)
    80006214:	e4aa                	sd	a0,72(sp)
    80006216:	e8ae                	sd	a1,80(sp)
    80006218:	ecb2                	sd	a2,88(sp)
    8000621a:	f0b6                	sd	a3,96(sp)
    8000621c:	f4ba                	sd	a4,104(sp)
    8000621e:	f8be                	sd	a5,112(sp)
    80006220:	fcc2                	sd	a6,120(sp)
    80006222:	e146                	sd	a7,128(sp)
    80006224:	e54a                	sd	s2,136(sp)
    80006226:	e94e                	sd	s3,144(sp)
    80006228:	ed52                	sd	s4,152(sp)
    8000622a:	f156                	sd	s5,160(sp)
    8000622c:	f55a                	sd	s6,168(sp)
    8000622e:	f95e                	sd	s7,176(sp)
    80006230:	fd62                	sd	s8,184(sp)
    80006232:	e1e6                	sd	s9,192(sp)
    80006234:	e5ea                	sd	s10,200(sp)
    80006236:	e9ee                	sd	s11,208(sp)
    80006238:	edf2                	sd	t3,216(sp)
    8000623a:	f1f6                	sd	t4,224(sp)
    8000623c:	f5fa                	sd	t5,232(sp)
    8000623e:	f9fe                	sd	t6,240(sp)
    80006240:	b3bfc0ef          	jal	ra,80002d7a <kerneltrap>
    80006244:	6082                	ld	ra,0(sp)
    80006246:	6122                	ld	sp,8(sp)
    80006248:	61c2                	ld	gp,16(sp)
    8000624a:	7282                	ld	t0,32(sp)
    8000624c:	7322                	ld	t1,40(sp)
    8000624e:	73c2                	ld	t2,48(sp)
    80006250:	7462                	ld	s0,56(sp)
    80006252:	6486                	ld	s1,64(sp)
    80006254:	6526                	ld	a0,72(sp)
    80006256:	65c6                	ld	a1,80(sp)
    80006258:	6666                	ld	a2,88(sp)
    8000625a:	7686                	ld	a3,96(sp)
    8000625c:	7726                	ld	a4,104(sp)
    8000625e:	77c6                	ld	a5,112(sp)
    80006260:	7866                	ld	a6,120(sp)
    80006262:	688a                	ld	a7,128(sp)
    80006264:	692a                	ld	s2,136(sp)
    80006266:	69ca                	ld	s3,144(sp)
    80006268:	6a6a                	ld	s4,152(sp)
    8000626a:	7a8a                	ld	s5,160(sp)
    8000626c:	7b2a                	ld	s6,168(sp)
    8000626e:	7bca                	ld	s7,176(sp)
    80006270:	7c6a                	ld	s8,184(sp)
    80006272:	6c8e                	ld	s9,192(sp)
    80006274:	6d2e                	ld	s10,200(sp)
    80006276:	6dce                	ld	s11,208(sp)
    80006278:	6e6e                	ld	t3,216(sp)
    8000627a:	7e8e                	ld	t4,224(sp)
    8000627c:	7f2e                	ld	t5,232(sp)
    8000627e:	7fce                	ld	t6,240(sp)
    80006280:	6111                	addi	sp,sp,256
    80006282:	10200073          	sret
    80006286:	00000013          	nop
    8000628a:	00000013          	nop
    8000628e:	0001                	nop

0000000080006290 <timervec>:
    80006290:	34051573          	csrrw	a0,mscratch,a0
    80006294:	e10c                	sd	a1,0(a0)
    80006296:	e510                	sd	a2,8(a0)
    80006298:	e914                	sd	a3,16(a0)
    8000629a:	6d0c                	ld	a1,24(a0)
    8000629c:	7110                	ld	a2,32(a0)
    8000629e:	6194                	ld	a3,0(a1)
    800062a0:	96b2                	add	a3,a3,a2
    800062a2:	e194                	sd	a3,0(a1)
    800062a4:	4589                	li	a1,2
    800062a6:	14459073          	csrw	sip,a1
    800062aa:	6914                	ld	a3,16(a0)
    800062ac:	6510                	ld	a2,8(a0)
    800062ae:	610c                	ld	a1,0(a0)
    800062b0:	34051573          	csrrw	a0,mscratch,a0
    800062b4:	30200073          	mret
	...

00000000800062ba <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800062ba:	1141                	addi	sp,sp,-16
    800062bc:	e422                	sd	s0,8(sp)
    800062be:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800062c0:	0c0007b7          	lui	a5,0xc000
    800062c4:	4705                	li	a4,1
    800062c6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800062c8:	c3d8                	sw	a4,4(a5)
}
    800062ca:	6422                	ld	s0,8(sp)
    800062cc:	0141                	addi	sp,sp,16
    800062ce:	8082                	ret

00000000800062d0 <plicinithart>:

void
plicinithart(void)
{
    800062d0:	1141                	addi	sp,sp,-16
    800062d2:	e406                	sd	ra,8(sp)
    800062d4:	e022                	sd	s0,0(sp)
    800062d6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800062d8:	ffffb097          	auipc	ra,0xffffb
    800062dc:	6c2080e7          	jalr	1730(ra) # 8000199a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800062e0:	0085171b          	slliw	a4,a0,0x8
    800062e4:	0c0027b7          	lui	a5,0xc002
    800062e8:	97ba                	add	a5,a5,a4
    800062ea:	40200713          	li	a4,1026
    800062ee:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800062f2:	00d5151b          	slliw	a0,a0,0xd
    800062f6:	0c2017b7          	lui	a5,0xc201
    800062fa:	953e                	add	a0,a0,a5
    800062fc:	00052023          	sw	zero,0(a0)
}
    80006300:	60a2                	ld	ra,8(sp)
    80006302:	6402                	ld	s0,0(sp)
    80006304:	0141                	addi	sp,sp,16
    80006306:	8082                	ret

0000000080006308 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006308:	1141                	addi	sp,sp,-16
    8000630a:	e406                	sd	ra,8(sp)
    8000630c:	e022                	sd	s0,0(sp)
    8000630e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006310:	ffffb097          	auipc	ra,0xffffb
    80006314:	68a080e7          	jalr	1674(ra) # 8000199a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006318:	00d5179b          	slliw	a5,a0,0xd
    8000631c:	0c201537          	lui	a0,0xc201
    80006320:	953e                	add	a0,a0,a5
  return irq;
}
    80006322:	4148                	lw	a0,4(a0)
    80006324:	60a2                	ld	ra,8(sp)
    80006326:	6402                	ld	s0,0(sp)
    80006328:	0141                	addi	sp,sp,16
    8000632a:	8082                	ret

000000008000632c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000632c:	1101                	addi	sp,sp,-32
    8000632e:	ec06                	sd	ra,24(sp)
    80006330:	e822                	sd	s0,16(sp)
    80006332:	e426                	sd	s1,8(sp)
    80006334:	1000                	addi	s0,sp,32
    80006336:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006338:	ffffb097          	auipc	ra,0xffffb
    8000633c:	662080e7          	jalr	1634(ra) # 8000199a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006340:	00d5151b          	slliw	a0,a0,0xd
    80006344:	0c2017b7          	lui	a5,0xc201
    80006348:	97aa                	add	a5,a5,a0
    8000634a:	c3c4                	sw	s1,4(a5)
}
    8000634c:	60e2                	ld	ra,24(sp)
    8000634e:	6442                	ld	s0,16(sp)
    80006350:	64a2                	ld	s1,8(sp)
    80006352:	6105                	addi	sp,sp,32
    80006354:	8082                	ret

0000000080006356 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006356:	1141                	addi	sp,sp,-16
    80006358:	e406                	sd	ra,8(sp)
    8000635a:	e022                	sd	s0,0(sp)
    8000635c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000635e:	479d                	li	a5,7
    80006360:	04a7cc63          	blt	a5,a0,800063b8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006364:	0001e797          	auipc	a5,0x1e
    80006368:	8fc78793          	addi	a5,a5,-1796 # 80023c60 <disk>
    8000636c:	97aa                	add	a5,a5,a0
    8000636e:	0187c783          	lbu	a5,24(a5)
    80006372:	ebb9                	bnez	a5,800063c8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006374:	00451613          	slli	a2,a0,0x4
    80006378:	0001e797          	auipc	a5,0x1e
    8000637c:	8e878793          	addi	a5,a5,-1816 # 80023c60 <disk>
    80006380:	6394                	ld	a3,0(a5)
    80006382:	96b2                	add	a3,a3,a2
    80006384:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006388:	6398                	ld	a4,0(a5)
    8000638a:	9732                	add	a4,a4,a2
    8000638c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006390:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006394:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006398:	953e                	add	a0,a0,a5
    8000639a:	4785                	li	a5,1
    8000639c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    800063a0:	0001e517          	auipc	a0,0x1e
    800063a4:	8d850513          	addi	a0,a0,-1832 # 80023c78 <disk+0x18>
    800063a8:	ffffc097          	auipc	ra,0xffffc
    800063ac:	0ba080e7          	jalr	186(ra) # 80002462 <wakeup>
}
    800063b0:	60a2                	ld	ra,8(sp)
    800063b2:	6402                	ld	s0,0(sp)
    800063b4:	0141                	addi	sp,sp,16
    800063b6:	8082                	ret
    panic("free_desc 1");
    800063b8:	00002517          	auipc	a0,0x2
    800063bc:	4d050513          	addi	a0,a0,1232 # 80008888 <syscallnum+0x2a8>
    800063c0:	ffffa097          	auipc	ra,0xffffa
    800063c4:	184080e7          	jalr	388(ra) # 80000544 <panic>
    panic("free_desc 2");
    800063c8:	00002517          	auipc	a0,0x2
    800063cc:	4d050513          	addi	a0,a0,1232 # 80008898 <syscallnum+0x2b8>
    800063d0:	ffffa097          	auipc	ra,0xffffa
    800063d4:	174080e7          	jalr	372(ra) # 80000544 <panic>

00000000800063d8 <virtio_disk_init>:
{
    800063d8:	1101                	addi	sp,sp,-32
    800063da:	ec06                	sd	ra,24(sp)
    800063dc:	e822                	sd	s0,16(sp)
    800063de:	e426                	sd	s1,8(sp)
    800063e0:	e04a                	sd	s2,0(sp)
    800063e2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800063e4:	00002597          	auipc	a1,0x2
    800063e8:	4c458593          	addi	a1,a1,1220 # 800088a8 <syscallnum+0x2c8>
    800063ec:	0001e517          	auipc	a0,0x1e
    800063f0:	99c50513          	addi	a0,a0,-1636 # 80023d88 <disk+0x128>
    800063f4:	ffffa097          	auipc	ra,0xffffa
    800063f8:	766080e7          	jalr	1894(ra) # 80000b5a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800063fc:	100017b7          	lui	a5,0x10001
    80006400:	4398                	lw	a4,0(a5)
    80006402:	2701                	sext.w	a4,a4
    80006404:	747277b7          	lui	a5,0x74727
    80006408:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000640c:	14f71e63          	bne	a4,a5,80006568 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006410:	100017b7          	lui	a5,0x10001
    80006414:	43dc                	lw	a5,4(a5)
    80006416:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006418:	4709                	li	a4,2
    8000641a:	14e79763          	bne	a5,a4,80006568 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000641e:	100017b7          	lui	a5,0x10001
    80006422:	479c                	lw	a5,8(a5)
    80006424:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006426:	14e79163          	bne	a5,a4,80006568 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000642a:	100017b7          	lui	a5,0x10001
    8000642e:	47d8                	lw	a4,12(a5)
    80006430:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006432:	554d47b7          	lui	a5,0x554d4
    80006436:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000643a:	12f71763          	bne	a4,a5,80006568 <virtio_disk_init+0x190>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000643e:	100017b7          	lui	a5,0x10001
    80006442:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006446:	4705                	li	a4,1
    80006448:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000644a:	470d                	li	a4,3
    8000644c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000644e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006450:	c7ffe737          	lui	a4,0xc7ffe
    80006454:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fda9bf>
    80006458:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000645a:	2701                	sext.w	a4,a4
    8000645c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000645e:	472d                	li	a4,11
    80006460:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006462:	0707a903          	lw	s2,112(a5)
    80006466:	2901                	sext.w	s2,s2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006468:	00897793          	andi	a5,s2,8
    8000646c:	10078663          	beqz	a5,80006578 <virtio_disk_init+0x1a0>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006470:	100017b7          	lui	a5,0x10001
    80006474:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006478:	43fc                	lw	a5,68(a5)
    8000647a:	2781                	sext.w	a5,a5
    8000647c:	10079663          	bnez	a5,80006588 <virtio_disk_init+0x1b0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006480:	100017b7          	lui	a5,0x10001
    80006484:	5bdc                	lw	a5,52(a5)
    80006486:	2781                	sext.w	a5,a5
  if(max == 0)
    80006488:	10078863          	beqz	a5,80006598 <virtio_disk_init+0x1c0>
  if(max < NUM)
    8000648c:	471d                	li	a4,7
    8000648e:	10f77d63          	bgeu	a4,a5,800065a8 <virtio_disk_init+0x1d0>
  disk.desc = kalloc();
    80006492:	ffffa097          	auipc	ra,0xffffa
    80006496:	668080e7          	jalr	1640(ra) # 80000afa <kalloc>
    8000649a:	0001d497          	auipc	s1,0x1d
    8000649e:	7c648493          	addi	s1,s1,1990 # 80023c60 <disk>
    800064a2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800064a4:	ffffa097          	auipc	ra,0xffffa
    800064a8:	656080e7          	jalr	1622(ra) # 80000afa <kalloc>
    800064ac:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800064ae:	ffffa097          	auipc	ra,0xffffa
    800064b2:	64c080e7          	jalr	1612(ra) # 80000afa <kalloc>
    800064b6:	87aa                	mv	a5,a0
    800064b8:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800064ba:	6088                	ld	a0,0(s1)
    800064bc:	cd75                	beqz	a0,800065b8 <virtio_disk_init+0x1e0>
    800064be:	0001d717          	auipc	a4,0x1d
    800064c2:	7aa73703          	ld	a4,1962(a4) # 80023c68 <disk+0x8>
    800064c6:	cb6d                	beqz	a4,800065b8 <virtio_disk_init+0x1e0>
    800064c8:	cbe5                	beqz	a5,800065b8 <virtio_disk_init+0x1e0>
  memset(disk.desc, 0, PGSIZE);
    800064ca:	6605                	lui	a2,0x1
    800064cc:	4581                	li	a1,0
    800064ce:	ffffb097          	auipc	ra,0xffffb
    800064d2:	818080e7          	jalr	-2024(ra) # 80000ce6 <memset>
  memset(disk.avail, 0, PGSIZE);
    800064d6:	0001d497          	auipc	s1,0x1d
    800064da:	78a48493          	addi	s1,s1,1930 # 80023c60 <disk>
    800064de:	6605                	lui	a2,0x1
    800064e0:	4581                	li	a1,0
    800064e2:	6488                	ld	a0,8(s1)
    800064e4:	ffffb097          	auipc	ra,0xffffb
    800064e8:	802080e7          	jalr	-2046(ra) # 80000ce6 <memset>
  memset(disk.used, 0, PGSIZE);
    800064ec:	6605                	lui	a2,0x1
    800064ee:	4581                	li	a1,0
    800064f0:	6888                	ld	a0,16(s1)
    800064f2:	ffffa097          	auipc	ra,0xffffa
    800064f6:	7f4080e7          	jalr	2036(ra) # 80000ce6 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800064fa:	100017b7          	lui	a5,0x10001
    800064fe:	4721                	li	a4,8
    80006500:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006502:	4098                	lw	a4,0(s1)
    80006504:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006508:	40d8                	lw	a4,4(s1)
    8000650a:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000650e:	6498                	ld	a4,8(s1)
    80006510:	0007069b          	sext.w	a3,a4
    80006514:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006518:	9701                	srai	a4,a4,0x20
    8000651a:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000651e:	6898                	ld	a4,16(s1)
    80006520:	0007069b          	sext.w	a3,a4
    80006524:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006528:	9701                	srai	a4,a4,0x20
    8000652a:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000652e:	4685                	li	a3,1
    80006530:	c3f4                	sw	a3,68(a5)
    disk.free[i] = 1;
    80006532:	4705                	li	a4,1
    80006534:	00d48c23          	sb	a3,24(s1)
    80006538:	00e48ca3          	sb	a4,25(s1)
    8000653c:	00e48d23          	sb	a4,26(s1)
    80006540:	00e48da3          	sb	a4,27(s1)
    80006544:	00e48e23          	sb	a4,28(s1)
    80006548:	00e48ea3          	sb	a4,29(s1)
    8000654c:	00e48f23          	sb	a4,30(s1)
    80006550:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006554:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006558:	0727a823          	sw	s2,112(a5)
}
    8000655c:	60e2                	ld	ra,24(sp)
    8000655e:	6442                	ld	s0,16(sp)
    80006560:	64a2                	ld	s1,8(sp)
    80006562:	6902                	ld	s2,0(sp)
    80006564:	6105                	addi	sp,sp,32
    80006566:	8082                	ret
    panic("could not find virtio disk");
    80006568:	00002517          	auipc	a0,0x2
    8000656c:	35050513          	addi	a0,a0,848 # 800088b8 <syscallnum+0x2d8>
    80006570:	ffffa097          	auipc	ra,0xffffa
    80006574:	fd4080e7          	jalr	-44(ra) # 80000544 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006578:	00002517          	auipc	a0,0x2
    8000657c:	36050513          	addi	a0,a0,864 # 800088d8 <syscallnum+0x2f8>
    80006580:	ffffa097          	auipc	ra,0xffffa
    80006584:	fc4080e7          	jalr	-60(ra) # 80000544 <panic>
    panic("virtio disk should not be ready");
    80006588:	00002517          	auipc	a0,0x2
    8000658c:	37050513          	addi	a0,a0,880 # 800088f8 <syscallnum+0x318>
    80006590:	ffffa097          	auipc	ra,0xffffa
    80006594:	fb4080e7          	jalr	-76(ra) # 80000544 <panic>
    panic("virtio disk has no queue 0");
    80006598:	00002517          	auipc	a0,0x2
    8000659c:	38050513          	addi	a0,a0,896 # 80008918 <syscallnum+0x338>
    800065a0:	ffffa097          	auipc	ra,0xffffa
    800065a4:	fa4080e7          	jalr	-92(ra) # 80000544 <panic>
    panic("virtio disk max queue too short");
    800065a8:	00002517          	auipc	a0,0x2
    800065ac:	39050513          	addi	a0,a0,912 # 80008938 <syscallnum+0x358>
    800065b0:	ffffa097          	auipc	ra,0xffffa
    800065b4:	f94080e7          	jalr	-108(ra) # 80000544 <panic>
    panic("virtio disk kalloc");
    800065b8:	00002517          	auipc	a0,0x2
    800065bc:	3a050513          	addi	a0,a0,928 # 80008958 <syscallnum+0x378>
    800065c0:	ffffa097          	auipc	ra,0xffffa
    800065c4:	f84080e7          	jalr	-124(ra) # 80000544 <panic>

00000000800065c8 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800065c8:	7159                	addi	sp,sp,-112
    800065ca:	f486                	sd	ra,104(sp)
    800065cc:	f0a2                	sd	s0,96(sp)
    800065ce:	eca6                	sd	s1,88(sp)
    800065d0:	e8ca                	sd	s2,80(sp)
    800065d2:	e4ce                	sd	s3,72(sp)
    800065d4:	e0d2                	sd	s4,64(sp)
    800065d6:	fc56                	sd	s5,56(sp)
    800065d8:	f85a                	sd	s6,48(sp)
    800065da:	f45e                	sd	s7,40(sp)
    800065dc:	f062                	sd	s8,32(sp)
    800065de:	ec66                	sd	s9,24(sp)
    800065e0:	e86a                	sd	s10,16(sp)
    800065e2:	1880                	addi	s0,sp,112
    800065e4:	892a                	mv	s2,a0
    800065e6:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800065e8:	00c52c83          	lw	s9,12(a0)
    800065ec:	001c9c9b          	slliw	s9,s9,0x1
    800065f0:	1c82                	slli	s9,s9,0x20
    800065f2:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800065f6:	0001d517          	auipc	a0,0x1d
    800065fa:	79250513          	addi	a0,a0,1938 # 80023d88 <disk+0x128>
    800065fe:	ffffa097          	auipc	ra,0xffffa
    80006602:	5ec080e7          	jalr	1516(ra) # 80000bea <acquire>
  for(int i = 0; i < 3; i++){
    80006606:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006608:	4ba1                	li	s7,8
      disk.free[i] = 0;
    8000660a:	0001db17          	auipc	s6,0x1d
    8000660e:	656b0b13          	addi	s6,s6,1622 # 80023c60 <disk>
  for(int i = 0; i < 3; i++){
    80006612:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80006614:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006616:	0001dc17          	auipc	s8,0x1d
    8000661a:	772c0c13          	addi	s8,s8,1906 # 80023d88 <disk+0x128>
    8000661e:	a8b5                	j	8000669a <virtio_disk_rw+0xd2>
      disk.free[i] = 0;
    80006620:	00fb06b3          	add	a3,s6,a5
    80006624:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006628:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000662a:	0207c563          	bltz	a5,80006654 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000662e:	2485                	addiw	s1,s1,1
    80006630:	0711                	addi	a4,a4,4
    80006632:	1f548a63          	beq	s1,s5,80006826 <virtio_disk_rw+0x25e>
    idx[i] = alloc_desc();
    80006636:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006638:	0001d697          	auipc	a3,0x1d
    8000663c:	62868693          	addi	a3,a3,1576 # 80023c60 <disk>
    80006640:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80006642:	0186c583          	lbu	a1,24(a3)
    80006646:	fde9                	bnez	a1,80006620 <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006648:	2785                	addiw	a5,a5,1
    8000664a:	0685                	addi	a3,a3,1
    8000664c:	ff779be3          	bne	a5,s7,80006642 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    80006650:	57fd                	li	a5,-1
    80006652:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80006654:	02905a63          	blez	s1,80006688 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    80006658:	f9042503          	lw	a0,-112(s0)
    8000665c:	00000097          	auipc	ra,0x0
    80006660:	cfa080e7          	jalr	-774(ra) # 80006356 <free_desc>
      for(int j = 0; j < i; j++)
    80006664:	4785                	li	a5,1
    80006666:	0297d163          	bge	a5,s1,80006688 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000666a:	f9442503          	lw	a0,-108(s0)
    8000666e:	00000097          	auipc	ra,0x0
    80006672:	ce8080e7          	jalr	-792(ra) # 80006356 <free_desc>
      for(int j = 0; j < i; j++)
    80006676:	4789                	li	a5,2
    80006678:	0097d863          	bge	a5,s1,80006688 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000667c:	f9842503          	lw	a0,-104(s0)
    80006680:	00000097          	auipc	ra,0x0
    80006684:	cd6080e7          	jalr	-810(ra) # 80006356 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006688:	85e2                	mv	a1,s8
    8000668a:	0001d517          	auipc	a0,0x1d
    8000668e:	5ee50513          	addi	a0,a0,1518 # 80023c78 <disk+0x18>
    80006692:	ffffc097          	auipc	ra,0xffffc
    80006696:	c14080e7          	jalr	-1004(ra) # 800022a6 <sleep>
  for(int i = 0; i < 3; i++){
    8000669a:	f9040713          	addi	a4,s0,-112
    8000669e:	84ce                	mv	s1,s3
    800066a0:	bf59                	j	80006636 <virtio_disk_rw+0x6e>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    800066a2:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    800066a6:	00479693          	slli	a3,a5,0x4
    800066aa:	0001d797          	auipc	a5,0x1d
    800066ae:	5b678793          	addi	a5,a5,1462 # 80023c60 <disk>
    800066b2:	97b6                	add	a5,a5,a3
    800066b4:	4685                	li	a3,1
    800066b6:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800066b8:	0001d597          	auipc	a1,0x1d
    800066bc:	5a858593          	addi	a1,a1,1448 # 80023c60 <disk>
    800066c0:	00a60793          	addi	a5,a2,10
    800066c4:	0792                	slli	a5,a5,0x4
    800066c6:	97ae                	add	a5,a5,a1
    800066c8:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    800066cc:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800066d0:	f6070693          	addi	a3,a4,-160
    800066d4:	619c                	ld	a5,0(a1)
    800066d6:	97b6                	add	a5,a5,a3
    800066d8:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800066da:	6188                	ld	a0,0(a1)
    800066dc:	96aa                	add	a3,a3,a0
    800066de:	47c1                	li	a5,16
    800066e0:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800066e2:	4785                	li	a5,1
    800066e4:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    800066e8:	f9442783          	lw	a5,-108(s0)
    800066ec:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800066f0:	0792                	slli	a5,a5,0x4
    800066f2:	953e                	add	a0,a0,a5
    800066f4:	05890693          	addi	a3,s2,88
    800066f8:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    800066fa:	6188                	ld	a0,0(a1)
    800066fc:	97aa                	add	a5,a5,a0
    800066fe:	40000693          	li	a3,1024
    80006702:	c794                	sw	a3,8(a5)
  if(write)
    80006704:	100d0d63          	beqz	s10,8000681e <virtio_disk_rw+0x256>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006708:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000670c:	00c7d683          	lhu	a3,12(a5)
    80006710:	0016e693          	ori	a3,a3,1
    80006714:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    80006718:	f9842583          	lw	a1,-104(s0)
    8000671c:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006720:	0001d697          	auipc	a3,0x1d
    80006724:	54068693          	addi	a3,a3,1344 # 80023c60 <disk>
    80006728:	00260793          	addi	a5,a2,2
    8000672c:	0792                	slli	a5,a5,0x4
    8000672e:	97b6                	add	a5,a5,a3
    80006730:	587d                	li	a6,-1
    80006732:	01078823          	sb	a6,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006736:	0592                	slli	a1,a1,0x4
    80006738:	952e                	add	a0,a0,a1
    8000673a:	f9070713          	addi	a4,a4,-112
    8000673e:	9736                	add	a4,a4,a3
    80006740:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    80006742:	6298                	ld	a4,0(a3)
    80006744:	972e                	add	a4,a4,a1
    80006746:	4585                	li	a1,1
    80006748:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000674a:	4509                	li	a0,2
    8000674c:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    80006750:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006754:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    80006758:	0127b423          	sd	s2,8(a5)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000675c:	6698                	ld	a4,8(a3)
    8000675e:	00275783          	lhu	a5,2(a4)
    80006762:	8b9d                	andi	a5,a5,7
    80006764:	0786                	slli	a5,a5,0x1
    80006766:	97ba                	add	a5,a5,a4
    80006768:	00c79223          	sh	a2,4(a5)

  __sync_synchronize();
    8000676c:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006770:	6698                	ld	a4,8(a3)
    80006772:	00275783          	lhu	a5,2(a4)
    80006776:	2785                	addiw	a5,a5,1
    80006778:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000677c:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006780:	100017b7          	lui	a5,0x10001
    80006784:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006788:	00492703          	lw	a4,4(s2)
    8000678c:	4785                	li	a5,1
    8000678e:	02f71163          	bne	a4,a5,800067b0 <virtio_disk_rw+0x1e8>
    sleep(b, &disk.vdisk_lock);
    80006792:	0001d997          	auipc	s3,0x1d
    80006796:	5f698993          	addi	s3,s3,1526 # 80023d88 <disk+0x128>
  while(b->disk == 1) {
    8000679a:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000679c:	85ce                	mv	a1,s3
    8000679e:	854a                	mv	a0,s2
    800067a0:	ffffc097          	auipc	ra,0xffffc
    800067a4:	b06080e7          	jalr	-1274(ra) # 800022a6 <sleep>
  while(b->disk == 1) {
    800067a8:	00492783          	lw	a5,4(s2)
    800067ac:	fe9788e3          	beq	a5,s1,8000679c <virtio_disk_rw+0x1d4>
  }

  disk.info[idx[0]].b = 0;
    800067b0:	f9042903          	lw	s2,-112(s0)
    800067b4:	00290793          	addi	a5,s2,2
    800067b8:	00479713          	slli	a4,a5,0x4
    800067bc:	0001d797          	auipc	a5,0x1d
    800067c0:	4a478793          	addi	a5,a5,1188 # 80023c60 <disk>
    800067c4:	97ba                	add	a5,a5,a4
    800067c6:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800067ca:	0001d997          	auipc	s3,0x1d
    800067ce:	49698993          	addi	s3,s3,1174 # 80023c60 <disk>
    800067d2:	00491713          	slli	a4,s2,0x4
    800067d6:	0009b783          	ld	a5,0(s3)
    800067da:	97ba                	add	a5,a5,a4
    800067dc:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800067e0:	854a                	mv	a0,s2
    800067e2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800067e6:	00000097          	auipc	ra,0x0
    800067ea:	b70080e7          	jalr	-1168(ra) # 80006356 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800067ee:	8885                	andi	s1,s1,1
    800067f0:	f0ed                	bnez	s1,800067d2 <virtio_disk_rw+0x20a>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800067f2:	0001d517          	auipc	a0,0x1d
    800067f6:	59650513          	addi	a0,a0,1430 # 80023d88 <disk+0x128>
    800067fa:	ffffa097          	auipc	ra,0xffffa
    800067fe:	4a4080e7          	jalr	1188(ra) # 80000c9e <release>
}
    80006802:	70a6                	ld	ra,104(sp)
    80006804:	7406                	ld	s0,96(sp)
    80006806:	64e6                	ld	s1,88(sp)
    80006808:	6946                	ld	s2,80(sp)
    8000680a:	69a6                	ld	s3,72(sp)
    8000680c:	6a06                	ld	s4,64(sp)
    8000680e:	7ae2                	ld	s5,56(sp)
    80006810:	7b42                	ld	s6,48(sp)
    80006812:	7ba2                	ld	s7,40(sp)
    80006814:	7c02                	ld	s8,32(sp)
    80006816:	6ce2                	ld	s9,24(sp)
    80006818:	6d42                	ld	s10,16(sp)
    8000681a:	6165                	addi	sp,sp,112
    8000681c:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000681e:	4689                	li	a3,2
    80006820:	00d79623          	sh	a3,12(a5)
    80006824:	b5e5                	j	8000670c <virtio_disk_rw+0x144>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006826:	f9042603          	lw	a2,-112(s0)
    8000682a:	00a60713          	addi	a4,a2,10
    8000682e:	0712                	slli	a4,a4,0x4
    80006830:	0001d517          	auipc	a0,0x1d
    80006834:	43850513          	addi	a0,a0,1080 # 80023c68 <disk+0x8>
    80006838:	953a                	add	a0,a0,a4
  if(write)
    8000683a:	e60d14e3          	bnez	s10,800066a2 <virtio_disk_rw+0xda>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    8000683e:	00a60793          	addi	a5,a2,10
    80006842:	00479693          	slli	a3,a5,0x4
    80006846:	0001d797          	auipc	a5,0x1d
    8000684a:	41a78793          	addi	a5,a5,1050 # 80023c60 <disk>
    8000684e:	97b6                	add	a5,a5,a3
    80006850:	0007a423          	sw	zero,8(a5)
    80006854:	b595                	j	800066b8 <virtio_disk_rw+0xf0>

0000000080006856 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006856:	1101                	addi	sp,sp,-32
    80006858:	ec06                	sd	ra,24(sp)
    8000685a:	e822                	sd	s0,16(sp)
    8000685c:	e426                	sd	s1,8(sp)
    8000685e:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006860:	0001d497          	auipc	s1,0x1d
    80006864:	40048493          	addi	s1,s1,1024 # 80023c60 <disk>
    80006868:	0001d517          	auipc	a0,0x1d
    8000686c:	52050513          	addi	a0,a0,1312 # 80023d88 <disk+0x128>
    80006870:	ffffa097          	auipc	ra,0xffffa
    80006874:	37a080e7          	jalr	890(ra) # 80000bea <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006878:	10001737          	lui	a4,0x10001
    8000687c:	533c                	lw	a5,96(a4)
    8000687e:	8b8d                	andi	a5,a5,3
    80006880:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006882:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006886:	689c                	ld	a5,16(s1)
    80006888:	0204d703          	lhu	a4,32(s1)
    8000688c:	0027d783          	lhu	a5,2(a5)
    80006890:	04f70863          	beq	a4,a5,800068e0 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006894:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006898:	6898                	ld	a4,16(s1)
    8000689a:	0204d783          	lhu	a5,32(s1)
    8000689e:	8b9d                	andi	a5,a5,7
    800068a0:	078e                	slli	a5,a5,0x3
    800068a2:	97ba                	add	a5,a5,a4
    800068a4:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800068a6:	00278713          	addi	a4,a5,2
    800068aa:	0712                	slli	a4,a4,0x4
    800068ac:	9726                	add	a4,a4,s1
    800068ae:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800068b2:	e721                	bnez	a4,800068fa <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800068b4:	0789                	addi	a5,a5,2
    800068b6:	0792                	slli	a5,a5,0x4
    800068b8:	97a6                	add	a5,a5,s1
    800068ba:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800068bc:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800068c0:	ffffc097          	auipc	ra,0xffffc
    800068c4:	ba2080e7          	jalr	-1118(ra) # 80002462 <wakeup>

    disk.used_idx += 1;
    800068c8:	0204d783          	lhu	a5,32(s1)
    800068cc:	2785                	addiw	a5,a5,1
    800068ce:	17c2                	slli	a5,a5,0x30
    800068d0:	93c1                	srli	a5,a5,0x30
    800068d2:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800068d6:	6898                	ld	a4,16(s1)
    800068d8:	00275703          	lhu	a4,2(a4)
    800068dc:	faf71ce3          	bne	a4,a5,80006894 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800068e0:	0001d517          	auipc	a0,0x1d
    800068e4:	4a850513          	addi	a0,a0,1192 # 80023d88 <disk+0x128>
    800068e8:	ffffa097          	auipc	ra,0xffffa
    800068ec:	3b6080e7          	jalr	950(ra) # 80000c9e <release>
}
    800068f0:	60e2                	ld	ra,24(sp)
    800068f2:	6442                	ld	s0,16(sp)
    800068f4:	64a2                	ld	s1,8(sp)
    800068f6:	6105                	addi	sp,sp,32
    800068f8:	8082                	ret
      panic("virtio_disk_intr status");
    800068fa:	00002517          	auipc	a0,0x2
    800068fe:	07650513          	addi	a0,a0,118 # 80008970 <syscallnum+0x390>
    80006902:	ffffa097          	auipc	ra,0xffffa
    80006906:	c42080e7          	jalr	-958(ra) # 80000544 <panic>
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

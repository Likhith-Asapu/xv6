
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
    80000068:	39c78793          	addi	a5,a5,924 # 80006400 <timervec>
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
    8000012c:	00003097          	auipc	ra,0x3
    80000130:	8a2080e7          	jalr	-1886(ra) # 800029ce <either_copyin>
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
    800001d0:	64c080e7          	jalr	1612(ra) # 80002818 <killed>
    800001d4:	e535                	bnez	a0,80000240 <consoleread+0xdc>
      sleep(&cons.r, &cons.lock);
    800001d6:	85ce                	mv	a1,s3
    800001d8:	854a                	mv	a0,s2
    800001da:	00002097          	auipc	ra,0x2
    800001de:	23e080e7          	jalr	574(ra) # 80002418 <sleep>
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
    8000021a:	762080e7          	jalr	1890(ra) # 80002978 <either_copyout>
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
    800002fc:	72c080e7          	jalr	1836(ra) # 80002a24 <procdump>
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
    80000450:	17c080e7          	jalr	380(ra) # 800025c8 <wakeup>
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
    800008aa:	d22080e7          	jalr	-734(ra) # 800025c8 <wakeup>
    
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
    80000934:	ae8080e7          	jalr	-1304(ra) # 80002418 <sleep>
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
    80000ede:	ce4080e7          	jalr	-796(ra) # 80002bbe <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ee2:	00005097          	auipc	ra,0x5
    80000ee6:	55e080e7          	jalr	1374(ra) # 80006440 <plicinithart>
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
    80000f56:	c44080e7          	jalr	-956(ra) # 80002b96 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f5a:	00002097          	auipc	ra,0x2
    80000f5e:	c64080e7          	jalr	-924(ra) # 80002bbe <trapinithart>
    plicinit();      // set up interrupt controller
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	4c8080e7          	jalr	1224(ra) # 8000642a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f6a:	00005097          	auipc	ra,0x5
    80000f6e:	4d6080e7          	jalr	1238(ra) # 80006440 <plicinithart>
    binit();         // buffer cache
    80000f72:	00002097          	auipc	ra,0x2
    80000f76:	686080e7          	jalr	1670(ra) # 800035f8 <binit>
    iinit();         // inode table
    80000f7a:	00003097          	auipc	ra,0x3
    80000f7e:	d2a080e7          	jalr	-726(ra) # 80003ca4 <iinit>
    fileinit();      // file table
    80000f82:	00004097          	auipc	ra,0x4
    80000f86:	cc8080e7          	jalr	-824(ra) # 80004c4a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f8a:	00005097          	auipc	ra,0x5
    80000f8e:	5be080e7          	jalr	1470(ra) # 80006548 <virtio_disk_init>
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
    80001a1a:	f7a7a783          	lw	a5,-134(a5) # 80008990 <first.1759>
    80001a1e:	eb89                	bnez	a5,80001a30 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a20:	00001097          	auipc	ra,0x1
    80001a24:	1b6080e7          	jalr	438(ra) # 80002bd6 <usertrapret>
}
    80001a28:	60a2                	ld	ra,8(sp)
    80001a2a:	6402                	ld	s0,0(sp)
    80001a2c:	0141                	addi	sp,sp,16
    80001a2e:	8082                	ret
    first = 0;
    80001a30:	00007797          	auipc	a5,0x7
    80001a34:	f607a023          	sw	zero,-160(a5) # 80008990 <first.1759>
    fsinit(ROOTDEV);
    80001a38:	4505                	li	a0,1
    80001a3a:	00002097          	auipc	ra,0x2
    80001a3e:	1ea080e7          	jalr	490(ra) # 80003c24 <fsinit>
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
    80001d72:	00003097          	auipc	ra,0x3
    80001d76:	8d4080e7          	jalr	-1836(ra) # 80004646 <namei>
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
    80001e9c:	e44080e7          	jalr	-444(ra) # 80004cdc <filedup>
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
    80001ebe:	fa8080e7          	jalr	-88(ra) # 80003e62 <idup>
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
    80002042:	d2270713          	addi	a4,a4,-734 # 80010d60 <pid_lock>
    80002046:	9762                	add	a4,a4,s8
    80002048:	02073823          	sd	zero,48(a4)
          swtch(&c->context, &p->context);
    8000204c:	0000f717          	auipc	a4,0xf
    80002050:	d4c70713          	addi	a4,a4,-692 # 80010d98 <cpus+0x8>
    80002054:	9c3a                	add	s8,s8,a4
    for (p = proc; p < &proc[NPROC]; p++)
    80002056:	00017497          	auipc	s1,0x17
    8000205a:	96a48493          	addi	s1,s1,-1686 # 800189c0 <tickslock>
      int minqueueval = 1000000;
    8000205e:	000f4737          	lui	a4,0xf4
    80002062:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002066:	f6e43423          	sd	a4,-152(s0)
              queueprocesscount[p->queue]--;
    8000206a:	0000f997          	auipc	s3,0xf
    8000206e:	cf698993          	addi	s3,s3,-778 # 80010d60 <pid_lock>
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
    8000208a:	13a90913          	addi	s2,s2,314 # 800111c0 <proc>
      if (p->state == RUNNABLE && p->queue < minqueue)
    8000208e:	4a8d                	li	s5,3
    80002090:	a821                	j	800020a8 <scheduler+0xae>
    80002092:	00078a1b          	sext.w	s4,a5
      release(&p->lock);
    80002096:	854a                	mv	a0,s2
    80002098:	fffff097          	auipc	ra,0xfffff
    8000209c:	c06080e7          	jalr	-1018(ra) # 80000c9e <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800020a0:	1e090913          	addi	s2,s2,480
    800020a4:	02990363          	beq	s2,s1,800020ca <scheduler+0xd0>
      acquire(&p->lock);
    800020a8:	854a                	mv	a0,s2
    800020aa:	fffff097          	auipc	ra,0xfffff
    800020ae:	b40080e7          	jalr	-1216(ra) # 80000bea <acquire>
      if (p->state == RUNNABLE && p->queue < minqueue)
    800020b2:	01892783          	lw	a5,24(s2)
    800020b6:	ff5790e3          	bne	a5,s5,80002096 <scheduler+0x9c>
    800020ba:	1d492783          	lw	a5,468(s2)
    800020be:	0007871b          	sext.w	a4,a5
    800020c2:	fcea58e3          	bge	s4,a4,80002092 <scheduler+0x98>
    800020c6:	87d2                	mv	a5,s4
    800020c8:	b7e9                	j	80002092 <scheduler+0x98>
    if (minqueue == 4)
    800020ca:	4791                	li	a5,4
    800020cc:	0cfa1d63          	bne	s4,a5,800021a6 <scheduler+0x1ac>
      for (p = proc; p < &proc[NPROC]; p++)
    800020d0:	0000fa17          	auipc	s4,0xf
    800020d4:	0f0a0a13          	addi	s4,s4,240 # 800111c0 <proc>
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
    800020e8:	1e090913          	addi	s2,s2,480
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
    80002106:	1d892783          	lw	a5,472(s2)
    8000210a:	2785                	addiw	a5,a5,1
    8000210c:	0007871b          	sext.w	a4,a5
    80002110:	1cf92c23          	sw	a5,472(s2)
              if (q->waittickcount >= 30)
    80002114:	fcebd5e3          	bge	s7,a4,800020de <scheduler+0xe4>
                queueprocesscount[q->queue]--;
    80002118:	1d492703          	lw	a4,468(s2)
    8000211c:	00271793          	slli	a5,a4,0x2
    80002120:	97ce                	add	a5,a5,s3
    80002122:	4307a683          	lw	a3,1072(a5)
    80002126:	36fd                	addiw	a3,a3,-1
    80002128:	42d7a823          	sw	a3,1072(a5)
                q->queue--;
    8000212c:	377d                	addiw	a4,a4,-1
    8000212e:	0007079b          	sext.w	a5,a4
    80002132:	1ce92a23          	sw	a4,468(s2)
                queueprocesscount[q->queue]++;
    80002136:	078a                	slli	a5,a5,0x2
    80002138:	97ce                	add	a5,a5,s3
    8000213a:	4307a703          	lw	a4,1072(a5)
    8000213e:	2705                	addiw	a4,a4,1
    80002140:	42e7a823          	sw	a4,1072(a5)
                q->tickcount = 0;
    80002144:	1c092823          	sw	zero,464(s2)
                q->waittickcount = 0;
    80002148:	1c092c23          	sw	zero,472(s2)
                q->queueposition = queuemaxindex[q->queue];
    8000214c:	4487a703          	lw	a4,1096(a5)
    80002150:	1ce92e23          	sw	a4,476(s2)
                queuemaxindex[q->queue]++;
    80002154:	2705                	addiw	a4,a4,1
    80002156:	44e7a423          	sw	a4,1096(a5)
    8000215a:	b751                	j	800020de <scheduler+0xe4>
        release(&p->lock);
    8000215c:	8552                	mv	a0,s4
    8000215e:	fffff097          	auipc	ra,0xfffff
    80002162:	b40080e7          	jalr	-1216(ra) # 80000c9e <release>
      for (p = proc; p < &proc[NPROC]; p++)
    80002166:	1e0a0a13          	addi	s4,s4,480
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
    80002194:	99c080e7          	jalr	-1636(ra) # 80002b2c <swtch>
          c->proc = 0;
    80002198:	020b3823          	sd	zero,48(s6)
          for (q = proc; q < &proc[NPROC]; q++)
    8000219c:	0000f917          	auipc	s2,0xf
    800021a0:	02490913          	addi	s2,s2,36 # 800111c0 <proc>
    800021a4:	b7b1                	j	800020f0 <scheduler+0xf6>
      struct proc *run_process = 0;
    800021a6:	4b81                	li	s7,0
      int minqueueval = 1000000;
    800021a8:	f6843c83          	ld	s9,-152(s0)
      for (p = proc; p < &proc[NPROC]; p++)
    800021ac:	0000f917          	auipc	s2,0xf
    800021b0:	01490913          	addi	s2,s2,20 # 800111c0 <proc>
        if (p->state == RUNNABLE && p->queue == minqueue)
    800021b4:	4a8d                	li	s5,3
    800021b6:	a811                	j	800021ca <scheduler+0x1d0>
        release(&p->lock);
    800021b8:	854a                	mv	a0,s2
    800021ba:	fffff097          	auipc	ra,0xfffff
    800021be:	ae4080e7          	jalr	-1308(ra) # 80000c9e <release>
      for (p = proc; p < &proc[NPROC]; p++)
    800021c2:	1e090913          	addi	s2,s2,480
    800021c6:	02990663          	beq	s2,s1,800021f2 <scheduler+0x1f8>
        acquire(&p->lock);
    800021ca:	854a                	mv	a0,s2
    800021cc:	fffff097          	auipc	ra,0xfffff
    800021d0:	a1e080e7          	jalr	-1506(ra) # 80000bea <acquire>
        if (p->state == RUNNABLE && p->queue == minqueue)
    800021d4:	01892783          	lw	a5,24(s2)
    800021d8:	ff5790e3          	bne	a5,s5,800021b8 <scheduler+0x1be>
    800021dc:	1d492783          	lw	a5,468(s2)
    800021e0:	fd479ce3          	bne	a5,s4,800021b8 <scheduler+0x1be>
          if (p->queueposition < minqueueval)
    800021e4:	1dc92783          	lw	a5,476(s2)
    800021e8:	fd97d8e3          	bge	a5,s9,800021b8 <scheduler+0x1be>
    800021ec:	8bca                	mv	s7,s2
            minqueueval = p->queueposition;
    800021ee:	8cbe                	mv	s9,a5
    800021f0:	b7e1                	j	800021b8 <scheduler+0x1be>
      for (p = proc; p < &proc[NPROC]; p++)
    800021f2:	0000f917          	auipc	s2,0xf
    800021f6:	fce90913          	addi	s2,s2,-50 # 800111c0 <proc>
        if (p->state == RUNNABLE && p == run_process)
    800021fa:	4a8d                	li	s5,3
            if (p->waittickcount >= 30)
    800021fc:	4cf5                	li	s9,29
          p->state = RUNNING;
    800021fe:	4d11                	li	s10,4
          if (p->tickcount >= maxticks[p->queue] && p->queue != 4)
    80002200:	4d91                	li	s11,4
    80002202:	a851                	j	80002296 <scheduler+0x29c>
          p->state = RUNNING;
    80002204:	01a92c23          	sw	s10,24(s2)
          c->proc = p;
    80002208:	032b3823          	sd	s2,48(s6)
          swtch(&c->context, &p->context);
    8000220c:	06090593          	addi	a1,s2,96
    80002210:	8562                	mv	a0,s8
    80002212:	00001097          	auipc	ra,0x1
    80002216:	91a080e7          	jalr	-1766(ra) # 80002b2c <swtch>
          c->proc = 0;
    8000221a:	020b3823          	sd	zero,48(s6)
          p->tickcount++;
    8000221e:	1d092783          	lw	a5,464(s2)
    80002222:	2785                	addiw	a5,a5,1
    80002224:	0007869b          	sext.w	a3,a5
    80002228:	1cf92823          	sw	a5,464(s2)
          if (p->tickcount >= maxticks[p->queue] && p->queue != 4)
    8000222c:	1d492703          	lw	a4,468(s2)
    80002230:	00271793          	slli	a5,a4,0x2
    80002234:	f9040613          	addi	a2,s0,-112
    80002238:	97b2                	add	a5,a5,a2
    8000223a:	fe87a783          	lw	a5,-24(a5)
    8000223e:	04f6c163          	blt	a3,a5,80002280 <scheduler+0x286>
    80002242:	03b70f63          	beq	a4,s11,80002280 <scheduler+0x286>
            queueprocesscount[p->queue]--;
    80002246:	00271793          	slli	a5,a4,0x2
    8000224a:	97ce                	add	a5,a5,s3
    8000224c:	4307a683          	lw	a3,1072(a5)
    80002250:	36fd                	addiw	a3,a3,-1
    80002252:	42d7a823          	sw	a3,1072(a5)
            p->queue++;
    80002256:	2705                	addiw	a4,a4,1
    80002258:	0007079b          	sext.w	a5,a4
    8000225c:	1ce92a23          	sw	a4,468(s2)
            queueprocesscount[p->queue]++;
    80002260:	078a                	slli	a5,a5,0x2
    80002262:	97ce                	add	a5,a5,s3
    80002264:	4307a703          	lw	a4,1072(a5)
    80002268:	2705                	addiw	a4,a4,1
    8000226a:	42e7a823          	sw	a4,1072(a5)
            p->tickcount = 0;
    8000226e:	1c092823          	sw	zero,464(s2)
            p->queueposition = queuemaxindex[p->queue];
    80002272:	4487a703          	lw	a4,1096(a5)
    80002276:	1ce92e23          	sw	a4,476(s2)
            queuemaxindex[p->queue]++;
    8000227a:	2705                	addiw	a4,a4,1
    8000227c:	44e7a423          	sw	a4,1096(a5)
          p->waittickcount = 0;
    80002280:	1c092c23          	sw	zero,472(s2)
        release(&p->lock);
    80002284:	854a                	mv	a0,s2
    80002286:	fffff097          	auipc	ra,0xfffff
    8000228a:	a18080e7          	jalr	-1512(ra) # 80000c9e <release>
      for (p = proc; p < &proc[NPROC]; p++)
    8000228e:	1e090913          	addi	s2,s2,480
    80002292:	de9903e3          	beq	s2,s1,80002078 <scheduler+0x7e>
        acquire(&p->lock);
    80002296:	854a                	mv	a0,s2
    80002298:	fffff097          	auipc	ra,0xfffff
    8000229c:	952080e7          	jalr	-1710(ra) # 80000bea <acquire>
        if (p->state == RUNNABLE && p == run_process)
    800022a0:	01892783          	lw	a5,24(s2)
    800022a4:	ff5790e3          	bne	a5,s5,80002284 <scheduler+0x28a>
    800022a8:	f52b8ee3          	beq	s7,s2,80002204 <scheduler+0x20a>
          p->waittickcount++;
    800022ac:	1d892783          	lw	a5,472(s2)
    800022b0:	2785                	addiw	a5,a5,1
    800022b2:	0007871b          	sext.w	a4,a5
    800022b6:	1cf92c23          	sw	a5,472(s2)
          if (p->queue != 0)
    800022ba:	1d492783          	lw	a5,468(s2)
    800022be:	d3f9                	beqz	a5,80002284 <scheduler+0x28a>
            if (p->waittickcount >= 30)
    800022c0:	fcecd2e3          	bge	s9,a4,80002284 <scheduler+0x28a>
              queueprocesscount[p->queue]--;
    800022c4:	00279713          	slli	a4,a5,0x2
    800022c8:	974e                	add	a4,a4,s3
    800022ca:	43072683          	lw	a3,1072(a4)
    800022ce:	36fd                	addiw	a3,a3,-1
    800022d0:	42d72823          	sw	a3,1072(a4)
              p->queue--;
    800022d4:	37fd                	addiw	a5,a5,-1
    800022d6:	0007871b          	sext.w	a4,a5
    800022da:	1cf92a23          	sw	a5,468(s2)
              queueprocesscount[p->queue]++;
    800022de:	00271793          	slli	a5,a4,0x2
    800022e2:	97ce                	add	a5,a5,s3
    800022e4:	4307a703          	lw	a4,1072(a5)
    800022e8:	2705                	addiw	a4,a4,1
    800022ea:	42e7a823          	sw	a4,1072(a5)
              p->tickcount = 0;
    800022ee:	1c092823          	sw	zero,464(s2)
              p->waittickcount = 0;
    800022f2:	1c092c23          	sw	zero,472(s2)
              p->queueposition = queuemaxindex[p->queue];
    800022f6:	4487a703          	lw	a4,1096(a5)
    800022fa:	1ce92e23          	sw	a4,476(s2)
              queuemaxindex[p->queue]++;
    800022fe:	2705                	addiw	a4,a4,1
    80002300:	44e7a423          	sw	a4,1096(a5)
    80002304:	b741                	j	80002284 <scheduler+0x28a>

0000000080002306 <sched>:
{
    80002306:	7179                	addi	sp,sp,-48
    80002308:	f406                	sd	ra,40(sp)
    8000230a:	f022                	sd	s0,32(sp)
    8000230c:	ec26                	sd	s1,24(sp)
    8000230e:	e84a                	sd	s2,16(sp)
    80002310:	e44e                	sd	s3,8(sp)
    80002312:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002314:	fffff097          	auipc	ra,0xfffff
    80002318:	6b2080e7          	jalr	1714(ra) # 800019c6 <myproc>
    8000231c:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    8000231e:	fffff097          	auipc	ra,0xfffff
    80002322:	852080e7          	jalr	-1966(ra) # 80000b70 <holding>
    80002326:	c93d                	beqz	a0,8000239c <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002328:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    8000232a:	2781                	sext.w	a5,a5
    8000232c:	079e                	slli	a5,a5,0x7
    8000232e:	0000f717          	auipc	a4,0xf
    80002332:	a3270713          	addi	a4,a4,-1486 # 80010d60 <pid_lock>
    80002336:	97ba                	add	a5,a5,a4
    80002338:	0a87a703          	lw	a4,168(a5)
    8000233c:	4785                	li	a5,1
    8000233e:	06f71763          	bne	a4,a5,800023ac <sched+0xa6>
  if (p->state == RUNNING)
    80002342:	4c98                	lw	a4,24(s1)
    80002344:	4791                	li	a5,4
    80002346:	06f70b63          	beq	a4,a5,800023bc <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000234a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000234e:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002350:	efb5                	bnez	a5,800023cc <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002352:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002354:	0000f917          	auipc	s2,0xf
    80002358:	a0c90913          	addi	s2,s2,-1524 # 80010d60 <pid_lock>
    8000235c:	2781                	sext.w	a5,a5
    8000235e:	079e                	slli	a5,a5,0x7
    80002360:	97ca                	add	a5,a5,s2
    80002362:	0ac7a983          	lw	s3,172(a5)
    80002366:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002368:	2781                	sext.w	a5,a5
    8000236a:	079e                	slli	a5,a5,0x7
    8000236c:	0000f597          	auipc	a1,0xf
    80002370:	a2c58593          	addi	a1,a1,-1492 # 80010d98 <cpus+0x8>
    80002374:	95be                	add	a1,a1,a5
    80002376:	06048513          	addi	a0,s1,96
    8000237a:	00000097          	auipc	ra,0x0
    8000237e:	7b2080e7          	jalr	1970(ra) # 80002b2c <swtch>
    80002382:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002384:	2781                	sext.w	a5,a5
    80002386:	079e                	slli	a5,a5,0x7
    80002388:	97ca                	add	a5,a5,s2
    8000238a:	0b37a623          	sw	s3,172(a5)
}
    8000238e:	70a2                	ld	ra,40(sp)
    80002390:	7402                	ld	s0,32(sp)
    80002392:	64e2                	ld	s1,24(sp)
    80002394:	6942                	ld	s2,16(sp)
    80002396:	69a2                	ld	s3,8(sp)
    80002398:	6145                	addi	sp,sp,48
    8000239a:	8082                	ret
    panic("sched p->lock");
    8000239c:	00006517          	auipc	a0,0x6
    800023a0:	e7c50513          	addi	a0,a0,-388 # 80008218 <digits+0x1d8>
    800023a4:	ffffe097          	auipc	ra,0xffffe
    800023a8:	1a0080e7          	jalr	416(ra) # 80000544 <panic>
    panic("sched locks");
    800023ac:	00006517          	auipc	a0,0x6
    800023b0:	e7c50513          	addi	a0,a0,-388 # 80008228 <digits+0x1e8>
    800023b4:	ffffe097          	auipc	ra,0xffffe
    800023b8:	190080e7          	jalr	400(ra) # 80000544 <panic>
    panic("sched running");
    800023bc:	00006517          	auipc	a0,0x6
    800023c0:	e7c50513          	addi	a0,a0,-388 # 80008238 <digits+0x1f8>
    800023c4:	ffffe097          	auipc	ra,0xffffe
    800023c8:	180080e7          	jalr	384(ra) # 80000544 <panic>
    panic("sched interruptible");
    800023cc:	00006517          	auipc	a0,0x6
    800023d0:	e7c50513          	addi	a0,a0,-388 # 80008248 <digits+0x208>
    800023d4:	ffffe097          	auipc	ra,0xffffe
    800023d8:	170080e7          	jalr	368(ra) # 80000544 <panic>

00000000800023dc <yield>:
{
    800023dc:	1101                	addi	sp,sp,-32
    800023de:	ec06                	sd	ra,24(sp)
    800023e0:	e822                	sd	s0,16(sp)
    800023e2:	e426                	sd	s1,8(sp)
    800023e4:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800023e6:	fffff097          	auipc	ra,0xfffff
    800023ea:	5e0080e7          	jalr	1504(ra) # 800019c6 <myproc>
    800023ee:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800023f0:	ffffe097          	auipc	ra,0xffffe
    800023f4:	7fa080e7          	jalr	2042(ra) # 80000bea <acquire>
  p->state = RUNNABLE;
    800023f8:	478d                	li	a5,3
    800023fa:	cc9c                	sw	a5,24(s1)
  sched();
    800023fc:	00000097          	auipc	ra,0x0
    80002400:	f0a080e7          	jalr	-246(ra) # 80002306 <sched>
  release(&p->lock);
    80002404:	8526                	mv	a0,s1
    80002406:	fffff097          	auipc	ra,0xfffff
    8000240a:	898080e7          	jalr	-1896(ra) # 80000c9e <release>
}
    8000240e:	60e2                	ld	ra,24(sp)
    80002410:	6442                	ld	s0,16(sp)
    80002412:	64a2                	ld	s1,8(sp)
    80002414:	6105                	addi	sp,sp,32
    80002416:	8082                	ret

0000000080002418 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    80002418:	7179                	addi	sp,sp,-48
    8000241a:	f406                	sd	ra,40(sp)
    8000241c:	f022                	sd	s0,32(sp)
    8000241e:	ec26                	sd	s1,24(sp)
    80002420:	e84a                	sd	s2,16(sp)
    80002422:	e44e                	sd	s3,8(sp)
    80002424:	1800                	addi	s0,sp,48
    80002426:	89aa                	mv	s3,a0
    80002428:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000242a:	fffff097          	auipc	ra,0xfffff
    8000242e:	59c080e7          	jalr	1436(ra) # 800019c6 <myproc>
    80002432:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    80002434:	ffffe097          	auipc	ra,0xffffe
    80002438:	7b6080e7          	jalr	1974(ra) # 80000bea <acquire>
  release(lk);
    8000243c:	854a                	mv	a0,s2
    8000243e:	fffff097          	auipc	ra,0xfffff
    80002442:	860080e7          	jalr	-1952(ra) # 80000c9e <release>

  // Go to sleep.
  p->chan = chan;
    80002446:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000244a:	4789                	li	a5,2
    8000244c:	cc9c                	sw	a5,24(s1)

  sched();
    8000244e:	00000097          	auipc	ra,0x0
    80002452:	eb8080e7          	jalr	-328(ra) # 80002306 <sched>

  // Tidy up.
  p->chan = 0;
    80002456:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000245a:	8526                	mv	a0,s1
    8000245c:	fffff097          	auipc	ra,0xfffff
    80002460:	842080e7          	jalr	-1982(ra) # 80000c9e <release>
  acquire(lk);
    80002464:	854a                	mv	a0,s2
    80002466:	ffffe097          	auipc	ra,0xffffe
    8000246a:	784080e7          	jalr	1924(ra) # 80000bea <acquire>
}
    8000246e:	70a2                	ld	ra,40(sp)
    80002470:	7402                	ld	s0,32(sp)
    80002472:	64e2                	ld	s1,24(sp)
    80002474:	6942                	ld	s2,16(sp)
    80002476:	69a2                	ld	s3,8(sp)
    80002478:	6145                	addi	sp,sp,48
    8000247a:	8082                	ret

000000008000247c <waitx>:
{
    8000247c:	711d                	addi	sp,sp,-96
    8000247e:	ec86                	sd	ra,88(sp)
    80002480:	e8a2                	sd	s0,80(sp)
    80002482:	e4a6                	sd	s1,72(sp)
    80002484:	e0ca                	sd	s2,64(sp)
    80002486:	fc4e                	sd	s3,56(sp)
    80002488:	f852                	sd	s4,48(sp)
    8000248a:	f456                	sd	s5,40(sp)
    8000248c:	f05a                	sd	s6,32(sp)
    8000248e:	ec5e                	sd	s7,24(sp)
    80002490:	e862                	sd	s8,16(sp)
    80002492:	e466                	sd	s9,8(sp)
    80002494:	e06a                	sd	s10,0(sp)
    80002496:	1080                	addi	s0,sp,96
    80002498:	8b2a                	mv	s6,a0
    8000249a:	8bae                	mv	s7,a1
    8000249c:	8c32                	mv	s8,a2
  struct proc *p = myproc();
    8000249e:	fffff097          	auipc	ra,0xfffff
    800024a2:	528080e7          	jalr	1320(ra) # 800019c6 <myproc>
    800024a6:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800024a8:	0000f517          	auipc	a0,0xf
    800024ac:	8d050513          	addi	a0,a0,-1840 # 80010d78 <wait_lock>
    800024b0:	ffffe097          	auipc	ra,0xffffe
    800024b4:	73a080e7          	jalr	1850(ra) # 80000bea <acquire>
    havekids = 0;
    800024b8:	4c81                	li	s9,0
        if (np->state == ZOMBIE)
    800024ba:	4a15                	li	s4,5
    for (np = proc; np < &proc[NPROC]; np++)
    800024bc:	00016997          	auipc	s3,0x16
    800024c0:	50498993          	addi	s3,s3,1284 # 800189c0 <tickslock>
        havekids = 1;
    800024c4:	4a85                	li	s5,1
    sleep(p, &wait_lock); // DOC: wait-sleep
    800024c6:	0000fd17          	auipc	s10,0xf
    800024ca:	8b2d0d13          	addi	s10,s10,-1870 # 80010d78 <wait_lock>
    havekids = 0;
    800024ce:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    800024d0:	0000f497          	auipc	s1,0xf
    800024d4:	cf048493          	addi	s1,s1,-784 # 800111c0 <proc>
    800024d8:	a059                	j	8000255e <waitx+0xe2>
          pid = np->pid;
    800024da:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    800024de:	16c4a703          	lw	a4,364(s1)
    800024e2:	00ec2023          	sw	a4,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    800024e6:	1704a783          	lw	a5,368(s1)
    800024ea:	9f3d                	addw	a4,a4,a5
    800024ec:	1744a783          	lw	a5,372(s1)
    800024f0:	9f99                	subw	a5,a5,a4
    800024f2:	00fba023          	sw	a5,0(s7) # fffffffffffff000 <end+0xffffffff7ffdb260>
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800024f6:	000b0e63          	beqz	s6,80002512 <waitx+0x96>
    800024fa:	4691                	li	a3,4
    800024fc:	02c48613          	addi	a2,s1,44
    80002500:	85da                	mv	a1,s6
    80002502:	05093503          	ld	a0,80(s2)
    80002506:	fffff097          	auipc	ra,0xfffff
    8000250a:	17e080e7          	jalr	382(ra) # 80001684 <copyout>
    8000250e:	02054563          	bltz	a0,80002538 <waitx+0xbc>
          freeproc(np);
    80002512:	8526                	mv	a0,s1
    80002514:	fffff097          	auipc	ra,0xfffff
    80002518:	664080e7          	jalr	1636(ra) # 80001b78 <freeproc>
          release(&np->lock);
    8000251c:	8526                	mv	a0,s1
    8000251e:	ffffe097          	auipc	ra,0xffffe
    80002522:	780080e7          	jalr	1920(ra) # 80000c9e <release>
          release(&wait_lock);
    80002526:	0000f517          	auipc	a0,0xf
    8000252a:	85250513          	addi	a0,a0,-1966 # 80010d78 <wait_lock>
    8000252e:	ffffe097          	auipc	ra,0xffffe
    80002532:	770080e7          	jalr	1904(ra) # 80000c9e <release>
          return pid;
    80002536:	a09d                	j	8000259c <waitx+0x120>
            release(&np->lock);
    80002538:	8526                	mv	a0,s1
    8000253a:	ffffe097          	auipc	ra,0xffffe
    8000253e:	764080e7          	jalr	1892(ra) # 80000c9e <release>
            release(&wait_lock);
    80002542:	0000f517          	auipc	a0,0xf
    80002546:	83650513          	addi	a0,a0,-1994 # 80010d78 <wait_lock>
    8000254a:	ffffe097          	auipc	ra,0xffffe
    8000254e:	754080e7          	jalr	1876(ra) # 80000c9e <release>
            return -1;
    80002552:	59fd                	li	s3,-1
    80002554:	a0a1                	j	8000259c <waitx+0x120>
    for (np = proc; np < &proc[NPROC]; np++)
    80002556:	1e048493          	addi	s1,s1,480
    8000255a:	03348463          	beq	s1,s3,80002582 <waitx+0x106>
      if (np->parent == p)
    8000255e:	7c9c                	ld	a5,56(s1)
    80002560:	ff279be3          	bne	a5,s2,80002556 <waitx+0xda>
        acquire(&np->lock);
    80002564:	8526                	mv	a0,s1
    80002566:	ffffe097          	auipc	ra,0xffffe
    8000256a:	684080e7          	jalr	1668(ra) # 80000bea <acquire>
        if (np->state == ZOMBIE)
    8000256e:	4c9c                	lw	a5,24(s1)
    80002570:	f74785e3          	beq	a5,s4,800024da <waitx+0x5e>
        release(&np->lock);
    80002574:	8526                	mv	a0,s1
    80002576:	ffffe097          	auipc	ra,0xffffe
    8000257a:	728080e7          	jalr	1832(ra) # 80000c9e <release>
        havekids = 1;
    8000257e:	8756                	mv	a4,s5
    80002580:	bfd9                	j	80002556 <waitx+0xda>
    if (!havekids || p->killed)
    80002582:	c701                	beqz	a4,8000258a <waitx+0x10e>
    80002584:	02892783          	lw	a5,40(s2)
    80002588:	cb8d                	beqz	a5,800025ba <waitx+0x13e>
      release(&wait_lock);
    8000258a:	0000e517          	auipc	a0,0xe
    8000258e:	7ee50513          	addi	a0,a0,2030 # 80010d78 <wait_lock>
    80002592:	ffffe097          	auipc	ra,0xffffe
    80002596:	70c080e7          	jalr	1804(ra) # 80000c9e <release>
      return -1;
    8000259a:	59fd                	li	s3,-1
}
    8000259c:	854e                	mv	a0,s3
    8000259e:	60e6                	ld	ra,88(sp)
    800025a0:	6446                	ld	s0,80(sp)
    800025a2:	64a6                	ld	s1,72(sp)
    800025a4:	6906                	ld	s2,64(sp)
    800025a6:	79e2                	ld	s3,56(sp)
    800025a8:	7a42                	ld	s4,48(sp)
    800025aa:	7aa2                	ld	s5,40(sp)
    800025ac:	7b02                	ld	s6,32(sp)
    800025ae:	6be2                	ld	s7,24(sp)
    800025b0:	6c42                	ld	s8,16(sp)
    800025b2:	6ca2                	ld	s9,8(sp)
    800025b4:	6d02                	ld	s10,0(sp)
    800025b6:	6125                	addi	sp,sp,96
    800025b8:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    800025ba:	85ea                	mv	a1,s10
    800025bc:	854a                	mv	a0,s2
    800025be:	00000097          	auipc	ra,0x0
    800025c2:	e5a080e7          	jalr	-422(ra) # 80002418 <sleep>
    havekids = 0;
    800025c6:	b721                	j	800024ce <waitx+0x52>

00000000800025c8 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    800025c8:	7139                	addi	sp,sp,-64
    800025ca:	fc06                	sd	ra,56(sp)
    800025cc:	f822                	sd	s0,48(sp)
    800025ce:	f426                	sd	s1,40(sp)
    800025d0:	f04a                	sd	s2,32(sp)
    800025d2:	ec4e                	sd	s3,24(sp)
    800025d4:	e852                	sd	s4,16(sp)
    800025d6:	e456                	sd	s5,8(sp)
    800025d8:	0080                	addi	s0,sp,64
    800025da:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800025dc:	0000f497          	auipc	s1,0xf
    800025e0:	be448493          	addi	s1,s1,-1052 # 800111c0 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    800025e4:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    800025e6:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    800025e8:	00016917          	auipc	s2,0x16
    800025ec:	3d890913          	addi	s2,s2,984 # 800189c0 <tickslock>
    800025f0:	a821                	j	80002608 <wakeup+0x40>
        p->state = RUNNABLE;
    800025f2:	0154ac23          	sw	s5,24(s1)
      }
      release(&p->lock);
    800025f6:	8526                	mv	a0,s1
    800025f8:	ffffe097          	auipc	ra,0xffffe
    800025fc:	6a6080e7          	jalr	1702(ra) # 80000c9e <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002600:	1e048493          	addi	s1,s1,480
    80002604:	03248463          	beq	s1,s2,8000262c <wakeup+0x64>
    if (p != myproc())
    80002608:	fffff097          	auipc	ra,0xfffff
    8000260c:	3be080e7          	jalr	958(ra) # 800019c6 <myproc>
    80002610:	fea488e3          	beq	s1,a0,80002600 <wakeup+0x38>
      acquire(&p->lock);
    80002614:	8526                	mv	a0,s1
    80002616:	ffffe097          	auipc	ra,0xffffe
    8000261a:	5d4080e7          	jalr	1492(ra) # 80000bea <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    8000261e:	4c9c                	lw	a5,24(s1)
    80002620:	fd379be3          	bne	a5,s3,800025f6 <wakeup+0x2e>
    80002624:	709c                	ld	a5,32(s1)
    80002626:	fd4798e3          	bne	a5,s4,800025f6 <wakeup+0x2e>
    8000262a:	b7e1                	j	800025f2 <wakeup+0x2a>
    }
  }
}
    8000262c:	70e2                	ld	ra,56(sp)
    8000262e:	7442                	ld	s0,48(sp)
    80002630:	74a2                	ld	s1,40(sp)
    80002632:	7902                	ld	s2,32(sp)
    80002634:	69e2                	ld	s3,24(sp)
    80002636:	6a42                	ld	s4,16(sp)
    80002638:	6aa2                	ld	s5,8(sp)
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
    80002682:	f4a080e7          	jalr	-182(ra) # 800025c8 <wakeup>
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
    800026ae:	31c080e7          	jalr	796(ra) # 800019c6 <myproc>
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
    800026d4:	e74080e7          	jalr	-396(ra) # 80000544 <panic>
      fileclose(f);
    800026d8:	00002097          	auipc	ra,0x2
    800026dc:	656080e7          	jalr	1622(ra) # 80004d2e <fileclose>
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
    800026f4:	172080e7          	jalr	370(ra) # 80004862 <begin_op>
  iput(p->cwd);
    800026f8:	1509b503          	ld	a0,336(s3)
    800026fc:	00002097          	auipc	ra,0x2
    80002700:	95e080e7          	jalr	-1698(ra) # 8000405a <iput>
  end_op();
    80002704:	00002097          	auipc	ra,0x2
    80002708:	1de080e7          	jalr	478(ra) # 800048e2 <end_op>
  p->cwd = 0;
    8000270c:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002710:	0000e497          	auipc	s1,0xe
    80002714:	66848493          	addi	s1,s1,1640 # 80010d78 <wait_lock>
    80002718:	8526                	mv	a0,s1
    8000271a:	ffffe097          	auipc	ra,0xffffe
    8000271e:	4d0080e7          	jalr	1232(ra) # 80000bea <acquire>
  reparent(p);
    80002722:	854e                	mv	a0,s3
    80002724:	00000097          	auipc	ra,0x0
    80002728:	f1a080e7          	jalr	-230(ra) # 8000263e <reparent>
  wakeup(p->parent);
    8000272c:	0389b503          	ld	a0,56(s3)
    80002730:	00000097          	auipc	ra,0x0
    80002734:	e98080e7          	jalr	-360(ra) # 800025c8 <wakeup>
  acquire(&p->lock);
    80002738:	854e                	mv	a0,s3
    8000273a:	ffffe097          	auipc	ra,0xffffe
    8000273e:	4b0080e7          	jalr	1200(ra) # 80000bea <acquire>
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
    8000275e:	544080e7          	jalr	1348(ra) # 80000c9e <release>
  sched();
    80002762:	00000097          	auipc	ra,0x0
    80002766:	ba4080e7          	jalr	-1116(ra) # 80002306 <sched>
  panic("zombie exit");
    8000276a:	00006517          	auipc	a0,0x6
    8000276e:	b0650513          	addi	a0,a0,-1274 # 80008270 <digits+0x230>
    80002772:	ffffe097          	auipc	ra,0xffffe
    80002776:	dd2080e7          	jalr	-558(ra) # 80000544 <panic>

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
    800027a0:	44e080e7          	jalr	1102(ra) # 80000bea <acquire>
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
    800027b0:	4f2080e7          	jalr	1266(ra) # 80000c9e <release>
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
    800027d2:	4d0080e7          	jalr	1232(ra) # 80000c9e <release>
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
    800027fc:	3f2080e7          	jalr	1010(ra) # 80000bea <acquire>
  p->killed = 1;
    80002800:	4785                	li	a5,1
    80002802:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002804:	8526                	mv	a0,s1
    80002806:	ffffe097          	auipc	ra,0xffffe
    8000280a:	498080e7          	jalr	1176(ra) # 80000c9e <release>
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
    8000282a:	3c4080e7          	jalr	964(ra) # 80000bea <acquire>
  k = p->killed;
    8000282e:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002832:	8526                	mv	a0,s1
    80002834:	ffffe097          	auipc	ra,0xffffe
    80002838:	46a080e7          	jalr	1130(ra) # 80000c9e <release>
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
    80002868:	162080e7          	jalr	354(ra) # 800019c6 <myproc>
    8000286c:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000286e:	0000e517          	auipc	a0,0xe
    80002872:	50a50513          	addi	a0,a0,1290 # 80010d78 <wait_lock>
    80002876:	ffffe097          	auipc	ra,0xffffe
    8000287a:	374080e7          	jalr	884(ra) # 80000bea <acquire>
    havekids = 0;
    8000287e:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    80002880:	4a15                	li	s4,5
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002882:	00016997          	auipc	s3,0x16
    80002886:	13e98993          	addi	s3,s3,318 # 800189c0 <tickslock>
        havekids = 1;
    8000288a:	4a85                	li	s5,1
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
    800028b8:	dd0080e7          	jalr	-560(ra) # 80001684 <copyout>
    800028bc:	02054563          	bltz	a0,800028e6 <wait+0x9c>
          freeproc(pp);
    800028c0:	8526                	mv	a0,s1
    800028c2:	fffff097          	auipc	ra,0xfffff
    800028c6:	2b6080e7          	jalr	694(ra) # 80001b78 <freeproc>
          release(&pp->lock);
    800028ca:	8526                	mv	a0,s1
    800028cc:	ffffe097          	auipc	ra,0xffffe
    800028d0:	3d2080e7          	jalr	978(ra) # 80000c9e <release>
          release(&wait_lock);
    800028d4:	0000e517          	auipc	a0,0xe
    800028d8:	4a450513          	addi	a0,a0,1188 # 80010d78 <wait_lock>
    800028dc:	ffffe097          	auipc	ra,0xffffe
    800028e0:	3c2080e7          	jalr	962(ra) # 80000c9e <release>
          return pid;
    800028e4:	a0b5                	j	80002950 <wait+0x106>
            release(&pp->lock);
    800028e6:	8526                	mv	a0,s1
    800028e8:	ffffe097          	auipc	ra,0xffffe
    800028ec:	3b6080e7          	jalr	950(ra) # 80000c9e <release>
            release(&wait_lock);
    800028f0:	0000e517          	auipc	a0,0xe
    800028f4:	48850513          	addi	a0,a0,1160 # 80010d78 <wait_lock>
    800028f8:	ffffe097          	auipc	ra,0xffffe
    800028fc:	3a6080e7          	jalr	934(ra) # 80000c9e <release>
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
    80002918:	2d6080e7          	jalr	726(ra) # 80000bea <acquire>
        if (pp->state == ZOMBIE)
    8000291c:	4c9c                	lw	a5,24(s1)
    8000291e:	f94781e3          	beq	a5,s4,800028a0 <wait+0x56>
        release(&pp->lock);
    80002922:	8526                	mv	a0,s1
    80002924:	ffffe097          	auipc	ra,0xffffe
    80002928:	37a080e7          	jalr	890(ra) # 80000c9e <release>
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
    8000294a:	358080e7          	jalr	856(ra) # 80000c9e <release>
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
    80002972:	aaa080e7          	jalr	-1366(ra) # 80002418 <sleep>
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
    80002994:	036080e7          	jalr	54(ra) # 800019c6 <myproc>
  if (user_dst)
    80002998:	c08d                	beqz	s1,800029ba <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    8000299a:	86d2                	mv	a3,s4
    8000299c:	864e                	mv	a2,s3
    8000299e:	85ca                	mv	a1,s2
    800029a0:	6928                	ld	a0,80(a0)
    800029a2:	fffff097          	auipc	ra,0xfffff
    800029a6:	ce2080e7          	jalr	-798(ra) # 80001684 <copyout>
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
    800029c6:	384080e7          	jalr	900(ra) # 80000d46 <memmove>
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
    800029ea:	fe0080e7          	jalr	-32(ra) # 800019c6 <myproc>
  if (user_src)
    800029ee:	c08d                	beqz	s1,80002a10 <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    800029f0:	86d2                	mv	a3,s4
    800029f2:	864e                	mv	a2,s3
    800029f4:	85ca                	mv	a1,s2
    800029f6:	6928                	ld	a0,80(a0)
    800029f8:	fffff097          	auipc	ra,0xfffff
    800029fc:	d18080e7          	jalr	-744(ra) # 80001710 <copyin>
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
    80002a1c:	32e080e7          	jalr	814(ra) # 80000d46 <memmove>
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
    80002a42:	b50080e7          	jalr	-1200(ra) # 8000058e <printf>
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
    80002a68:	a00d                	j	80002a8a <procdump+0x66>
    printf("%d-%d", p->pid, p->queue);
    80002a6a:	1d44a603          	lw	a2,468(s1)
    80002a6e:	8556                	mv	a0,s5
    80002a70:	ffffe097          	auipc	ra,0xffffe
    80002a74:	b1e080e7          	jalr	-1250(ra) # 8000058e <printf>
    printf("\n");
    80002a78:	8552                	mv	a0,s4
    80002a7a:	ffffe097          	auipc	ra,0xffffe
    80002a7e:	b14080e7          	jalr	-1260(ra) # 8000058e <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002a82:	1e048493          	addi	s1,s1,480
    80002a86:	01248863          	beq	s1,s2,80002a96 <procdump+0x72>
    if (p->state == UNUSED)
    80002a8a:	4c9c                	lw	a5,24(s1)
    80002a8c:	dbfd                	beqz	a5,80002a82 <procdump+0x5e>
    if(p->pid > 3){
    80002a8e:	588c                	lw	a1,48(s1)
    80002a90:	feb9d9e3          	bge	s3,a1,80002a82 <procdump+0x5e>
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
    80002ad2:	11c080e7          	jalr	284(ra) # 80000bea <acquire>

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
    80002ae2:	1c0080e7          	jalr	448(ra) # 80000c9e <release>
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
    80002b08:	19a080e7          	jalr	410(ra) # 80000c9e <release>
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
    80002b26:	8ba080e7          	jalr	-1862(ra) # 800023dc <yield>
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
    80002bb2:	fac080e7          	jalr	-84(ra) # 80000b5a <initlock>
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
    80002bc8:	7ac78793          	addi	a5,a5,1964 # 80006370 <kernelvec>
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
    80002be2:	de8080e7          	jalr	-536(ra) # 800019c6 <myproc>
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
    80002c86:	f68080e7          	jalr	-152(ra) # 80000bea <acquire>
  ticks++;
    80002c8a:	00006497          	auipc	s1,0x6
    80002c8e:	e6648493          	addi	s1,s1,-410 # 80008af0 <ticks>
    80002c92:	409c                	lw	a5,0(s1)
    80002c94:	2785                	addiw	a5,a5,1
    80002c96:	c09c                	sw	a5,0(s1)
  update_time();
    80002c98:	fffff097          	auipc	ra,0xfffff
    80002c9c:	2d6080e7          	jalr	726(ra) # 80001f6e <update_time>
  wakeup(&ticks);
    80002ca0:	8526                	mv	a0,s1
    80002ca2:	00000097          	auipc	ra,0x0
    80002ca6:	926080e7          	jalr	-1754(ra) # 800025c8 <wakeup>
  release(&tickslock);
    80002caa:	854a                	mv	a0,s2
    80002cac:	ffffe097          	auipc	ra,0xffffe
    80002cb0:	ff2080e7          	jalr	-14(ra) # 80000c9e <release>
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
    80002cf6:	786080e7          	jalr	1926(ra) # 80006478 <plic_claim>
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
    80002d1a:	878080e7          	jalr	-1928(ra) # 8000058e <printf>
      plic_complete(irq);
    80002d1e:	8526                	mv	a0,s1
    80002d20:	00003097          	auipc	ra,0x3
    80002d24:	77c080e7          	jalr	1916(ra) # 8000649c <plic_complete>
    return 1;
    80002d28:	4505                	li	a0,1
    80002d2a:	bf55                	j	80002cde <devintr+0x1e>
      uartintr();
    80002d2c:	ffffe097          	auipc	ra,0xffffe
    80002d30:	c82080e7          	jalr	-894(ra) # 800009ae <uartintr>
    80002d34:	b7ed                	j	80002d1e <devintr+0x5e>
      virtio_disk_intr();
    80002d36:	00004097          	auipc	ra,0x4
    80002d3a:	c90080e7          	jalr	-880(ra) # 800069c6 <virtio_disk_intr>
    80002d3e:	b7c5                	j	80002d1e <devintr+0x5e>
    if(cpuid() == 0){
    80002d40:	fffff097          	auipc	ra,0xfffff
    80002d44:	c5a080e7          	jalr	-934(ra) # 8000199a <cpuid>
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
    80002d7c:	5f878793          	addi	a5,a5,1528 # 80006370 <kernelvec>
    80002d80:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002d84:	fffff097          	auipc	ra,0xfffff
    80002d88:	c42080e7          	jalr	-958(ra) # 800019c6 <myproc>
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
    80002dc6:	782080e7          	jalr	1922(ra) # 80000544 <panic>
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
    80002dec:	322080e7          	jalr	802(ra) # 8000310a <syscall>
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
    80002e2e:	764080e7          	jalr	1892(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e32:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002e36:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002e3a:	00005517          	auipc	a0,0x5
    80002e3e:	4c650513          	addi	a0,a0,1222 # 80008300 <digits+0x2c0>
    80002e42:	ffffd097          	auipc	ra,0xffffd
    80002e46:	74c080e7          	jalr	1868(ra) # 8000058e <printf>
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
    80002e72:	00f70763          	beq	a4,a5,80002e80 <usertrap+0x11e>
    yield();
    80002e76:	fffff097          	auipc	ra,0xfffff
    80002e7a:	566080e7          	jalr	1382(ra) # 800023dc <yield>
    80002e7e:	bfbd                	j	80002dfc <usertrap+0x9a>
      struct trapframe *tf = kalloc();
    80002e80:	ffffe097          	auipc	ra,0xffffe
    80002e84:	c7a080e7          	jalr	-902(ra) # 80000afa <kalloc>
    80002e88:	892a                	mv	s2,a0
      memmove(tf, p->trapframe, PGSIZE);
    80002e8a:	6605                	lui	a2,0x1
    80002e8c:	6cac                	ld	a1,88(s1)
    80002e8e:	ffffe097          	auipc	ra,0xffffe
    80002e92:	eb8080e7          	jalr	-328(ra) # 80000d46 <memmove>
      p->alarm_tf = tf;
    80002e96:	1924b823          	sd	s2,400(s1)
      p->cur_ticks++;
    80002e9a:	18c4a783          	lw	a5,396(s1)
    80002e9e:	2785                	addiw	a5,a5,1
    80002ea0:	18f4a623          	sw	a5,396(s1)
      if (p->cur_ticks % p->ticks == 0){
    80002ea4:	1884a703          	lw	a4,392(s1)
    80002ea8:	02e7e7bb          	remw	a5,a5,a4
    80002eac:	f7e9                	bnez	a5,80002e76 <usertrap+0x114>
        p->trapframe->epc = p->handler;
    80002eae:	6cbc                	ld	a5,88(s1)
    80002eb0:	1804b703          	ld	a4,384(s1)
    80002eb4:	ef98                	sd	a4,24(a5)
        p->handlerpermission = 0;
    80002eb6:	1804ae23          	sw	zero,412(s1)
    80002eba:	bf75                	j	80002e76 <usertrap+0x114>

0000000080002ebc <kerneltrap>:
{
    80002ebc:	7179                	addi	sp,sp,-48
    80002ebe:	f406                	sd	ra,40(sp)
    80002ec0:	f022                	sd	s0,32(sp)
    80002ec2:	ec26                	sd	s1,24(sp)
    80002ec4:	e84a                	sd	s2,16(sp)
    80002ec6:	e44e                	sd	s3,8(sp)
    80002ec8:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002eca:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ece:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ed2:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002ed6:	1004f793          	andi	a5,s1,256
    80002eda:	cb85                	beqz	a5,80002f0a <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002edc:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002ee0:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002ee2:	ef85                	bnez	a5,80002f1a <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002ee4:	00000097          	auipc	ra,0x0
    80002ee8:	ddc080e7          	jalr	-548(ra) # 80002cc0 <devintr>
    80002eec:	cd1d                	beqz	a0,80002f2a <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002eee:	4789                	li	a5,2
    80002ef0:	06f50a63          	beq	a0,a5,80002f64 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002ef4:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ef8:	10049073          	csrw	sstatus,s1
}
    80002efc:	70a2                	ld	ra,40(sp)
    80002efe:	7402                	ld	s0,32(sp)
    80002f00:	64e2                	ld	s1,24(sp)
    80002f02:	6942                	ld	s2,16(sp)
    80002f04:	69a2                	ld	s3,8(sp)
    80002f06:	6145                	addi	sp,sp,48
    80002f08:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002f0a:	00005517          	auipc	a0,0x5
    80002f0e:	41650513          	addi	a0,a0,1046 # 80008320 <digits+0x2e0>
    80002f12:	ffffd097          	auipc	ra,0xffffd
    80002f16:	632080e7          	jalr	1586(ra) # 80000544 <panic>
    panic("kerneltrap: interrupts enabled");
    80002f1a:	00005517          	auipc	a0,0x5
    80002f1e:	42e50513          	addi	a0,a0,1070 # 80008348 <digits+0x308>
    80002f22:	ffffd097          	auipc	ra,0xffffd
    80002f26:	622080e7          	jalr	1570(ra) # 80000544 <panic>
    printf("scause %p\n", scause);
    80002f2a:	85ce                	mv	a1,s3
    80002f2c:	00005517          	auipc	a0,0x5
    80002f30:	43c50513          	addi	a0,a0,1084 # 80008368 <digits+0x328>
    80002f34:	ffffd097          	auipc	ra,0xffffd
    80002f38:	65a080e7          	jalr	1626(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002f3c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002f40:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002f44:	00005517          	auipc	a0,0x5
    80002f48:	43450513          	addi	a0,a0,1076 # 80008378 <digits+0x338>
    80002f4c:	ffffd097          	auipc	ra,0xffffd
    80002f50:	642080e7          	jalr	1602(ra) # 8000058e <printf>
    panic("kerneltrap");
    80002f54:	00005517          	auipc	a0,0x5
    80002f58:	43c50513          	addi	a0,a0,1084 # 80008390 <digits+0x350>
    80002f5c:	ffffd097          	auipc	ra,0xffffd
    80002f60:	5e8080e7          	jalr	1512(ra) # 80000544 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002f64:	fffff097          	auipc	ra,0xfffff
    80002f68:	a62080e7          	jalr	-1438(ra) # 800019c6 <myproc>
    80002f6c:	d541                	beqz	a0,80002ef4 <kerneltrap+0x38>
    80002f6e:	fffff097          	auipc	ra,0xfffff
    80002f72:	a58080e7          	jalr	-1448(ra) # 800019c6 <myproc>
    80002f76:	4d18                	lw	a4,24(a0)
    80002f78:	4791                	li	a5,4
    80002f7a:	f6f71de3          	bne	a4,a5,80002ef4 <kerneltrap+0x38>
    yield();
    80002f7e:	fffff097          	auipc	ra,0xfffff
    80002f82:	45e080e7          	jalr	1118(ra) # 800023dc <yield>
    80002f86:	b7bd                	j	80002ef4 <kerneltrap+0x38>

0000000080002f88 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002f88:	1101                	addi	sp,sp,-32
    80002f8a:	ec06                	sd	ra,24(sp)
    80002f8c:	e822                	sd	s0,16(sp)
    80002f8e:	e426                	sd	s1,8(sp)
    80002f90:	1000                	addi	s0,sp,32
    80002f92:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002f94:	fffff097          	auipc	ra,0xfffff
    80002f98:	a32080e7          	jalr	-1486(ra) # 800019c6 <myproc>
  switch (n) {
    80002f9c:	4795                	li	a5,5
    80002f9e:	0497e163          	bltu	a5,s1,80002fe0 <argraw+0x58>
    80002fa2:	048a                	slli	s1,s1,0x2
    80002fa4:	00005717          	auipc	a4,0x5
    80002fa8:	54470713          	addi	a4,a4,1348 # 800084e8 <digits+0x4a8>
    80002fac:	94ba                	add	s1,s1,a4
    80002fae:	409c                	lw	a5,0(s1)
    80002fb0:	97ba                	add	a5,a5,a4
    80002fb2:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002fb4:	6d3c                	ld	a5,88(a0)
    80002fb6:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002fb8:	60e2                	ld	ra,24(sp)
    80002fba:	6442                	ld	s0,16(sp)
    80002fbc:	64a2                	ld	s1,8(sp)
    80002fbe:	6105                	addi	sp,sp,32
    80002fc0:	8082                	ret
    return p->trapframe->a1;
    80002fc2:	6d3c                	ld	a5,88(a0)
    80002fc4:	7fa8                	ld	a0,120(a5)
    80002fc6:	bfcd                	j	80002fb8 <argraw+0x30>
    return p->trapframe->a2;
    80002fc8:	6d3c                	ld	a5,88(a0)
    80002fca:	63c8                	ld	a0,128(a5)
    80002fcc:	b7f5                	j	80002fb8 <argraw+0x30>
    return p->trapframe->a3;
    80002fce:	6d3c                	ld	a5,88(a0)
    80002fd0:	67c8                	ld	a0,136(a5)
    80002fd2:	b7dd                	j	80002fb8 <argraw+0x30>
    return p->trapframe->a4;
    80002fd4:	6d3c                	ld	a5,88(a0)
    80002fd6:	6bc8                	ld	a0,144(a5)
    80002fd8:	b7c5                	j	80002fb8 <argraw+0x30>
    return p->trapframe->a5;
    80002fda:	6d3c                	ld	a5,88(a0)
    80002fdc:	6fc8                	ld	a0,152(a5)
    80002fde:	bfe9                	j	80002fb8 <argraw+0x30>
  panic("argraw");
    80002fe0:	00005517          	auipc	a0,0x5
    80002fe4:	3c050513          	addi	a0,a0,960 # 800083a0 <digits+0x360>
    80002fe8:	ffffd097          	auipc	ra,0xffffd
    80002fec:	55c080e7          	jalr	1372(ra) # 80000544 <panic>

0000000080002ff0 <fetchaddr>:
{
    80002ff0:	1101                	addi	sp,sp,-32
    80002ff2:	ec06                	sd	ra,24(sp)
    80002ff4:	e822                	sd	s0,16(sp)
    80002ff6:	e426                	sd	s1,8(sp)
    80002ff8:	e04a                	sd	s2,0(sp)
    80002ffa:	1000                	addi	s0,sp,32
    80002ffc:	84aa                	mv	s1,a0
    80002ffe:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003000:	fffff097          	auipc	ra,0xfffff
    80003004:	9c6080e7          	jalr	-1594(ra) # 800019c6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80003008:	653c                	ld	a5,72(a0)
    8000300a:	02f4f863          	bgeu	s1,a5,8000303a <fetchaddr+0x4a>
    8000300e:	00848713          	addi	a4,s1,8
    80003012:	02e7e663          	bltu	a5,a4,8000303e <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003016:	46a1                	li	a3,8
    80003018:	8626                	mv	a2,s1
    8000301a:	85ca                	mv	a1,s2
    8000301c:	6928                	ld	a0,80(a0)
    8000301e:	ffffe097          	auipc	ra,0xffffe
    80003022:	6f2080e7          	jalr	1778(ra) # 80001710 <copyin>
    80003026:	00a03533          	snez	a0,a0
    8000302a:	40a00533          	neg	a0,a0
}
    8000302e:	60e2                	ld	ra,24(sp)
    80003030:	6442                	ld	s0,16(sp)
    80003032:	64a2                	ld	s1,8(sp)
    80003034:	6902                	ld	s2,0(sp)
    80003036:	6105                	addi	sp,sp,32
    80003038:	8082                	ret
    return -1;
    8000303a:	557d                	li	a0,-1
    8000303c:	bfcd                	j	8000302e <fetchaddr+0x3e>
    8000303e:	557d                	li	a0,-1
    80003040:	b7fd                	j	8000302e <fetchaddr+0x3e>

0000000080003042 <fetchstr>:
{
    80003042:	7179                	addi	sp,sp,-48
    80003044:	f406                	sd	ra,40(sp)
    80003046:	f022                	sd	s0,32(sp)
    80003048:	ec26                	sd	s1,24(sp)
    8000304a:	e84a                	sd	s2,16(sp)
    8000304c:	e44e                	sd	s3,8(sp)
    8000304e:	1800                	addi	s0,sp,48
    80003050:	892a                	mv	s2,a0
    80003052:	84ae                	mv	s1,a1
    80003054:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80003056:	fffff097          	auipc	ra,0xfffff
    8000305a:	970080e7          	jalr	-1680(ra) # 800019c6 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    8000305e:	86ce                	mv	a3,s3
    80003060:	864a                	mv	a2,s2
    80003062:	85a6                	mv	a1,s1
    80003064:	6928                	ld	a0,80(a0)
    80003066:	ffffe097          	auipc	ra,0xffffe
    8000306a:	736080e7          	jalr	1846(ra) # 8000179c <copyinstr>
    8000306e:	00054e63          	bltz	a0,8000308a <fetchstr+0x48>
  return strlen(buf);
    80003072:	8526                	mv	a0,s1
    80003074:	ffffe097          	auipc	ra,0xffffe
    80003078:	df6080e7          	jalr	-522(ra) # 80000e6a <strlen>
}
    8000307c:	70a2                	ld	ra,40(sp)
    8000307e:	7402                	ld	s0,32(sp)
    80003080:	64e2                	ld	s1,24(sp)
    80003082:	6942                	ld	s2,16(sp)
    80003084:	69a2                	ld	s3,8(sp)
    80003086:	6145                	addi	sp,sp,48
    80003088:	8082                	ret
    return -1;
    8000308a:	557d                	li	a0,-1
    8000308c:	bfc5                	j	8000307c <fetchstr+0x3a>

000000008000308e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    8000308e:	1101                	addi	sp,sp,-32
    80003090:	ec06                	sd	ra,24(sp)
    80003092:	e822                	sd	s0,16(sp)
    80003094:	e426                	sd	s1,8(sp)
    80003096:	1000                	addi	s0,sp,32
    80003098:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000309a:	00000097          	auipc	ra,0x0
    8000309e:	eee080e7          	jalr	-274(ra) # 80002f88 <argraw>
    800030a2:	c088                	sw	a0,0(s1)
  return 0;
}
    800030a4:	4501                	li	a0,0
    800030a6:	60e2                	ld	ra,24(sp)
    800030a8:	6442                	ld	s0,16(sp)
    800030aa:	64a2                	ld	s1,8(sp)
    800030ac:	6105                	addi	sp,sp,32
    800030ae:	8082                	ret

00000000800030b0 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    800030b0:	1101                	addi	sp,sp,-32
    800030b2:	ec06                	sd	ra,24(sp)
    800030b4:	e822                	sd	s0,16(sp)
    800030b6:	e426                	sd	s1,8(sp)
    800030b8:	1000                	addi	s0,sp,32
    800030ba:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800030bc:	00000097          	auipc	ra,0x0
    800030c0:	ecc080e7          	jalr	-308(ra) # 80002f88 <argraw>
    800030c4:	e088                	sd	a0,0(s1)
  return 0;
}
    800030c6:	4501                	li	a0,0
    800030c8:	60e2                	ld	ra,24(sp)
    800030ca:	6442                	ld	s0,16(sp)
    800030cc:	64a2                	ld	s1,8(sp)
    800030ce:	6105                	addi	sp,sp,32
    800030d0:	8082                	ret

00000000800030d2 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800030d2:	7179                	addi	sp,sp,-48
    800030d4:	f406                	sd	ra,40(sp)
    800030d6:	f022                	sd	s0,32(sp)
    800030d8:	ec26                	sd	s1,24(sp)
    800030da:	e84a                	sd	s2,16(sp)
    800030dc:	1800                	addi	s0,sp,48
    800030de:	84ae                	mv	s1,a1
    800030e0:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    800030e2:	fd840593          	addi	a1,s0,-40
    800030e6:	00000097          	auipc	ra,0x0
    800030ea:	fca080e7          	jalr	-54(ra) # 800030b0 <argaddr>
  return fetchstr(addr, buf, max);
    800030ee:	864a                	mv	a2,s2
    800030f0:	85a6                	mv	a1,s1
    800030f2:	fd843503          	ld	a0,-40(s0)
    800030f6:	00000097          	auipc	ra,0x0
    800030fa:	f4c080e7          	jalr	-180(ra) # 80003042 <fetchstr>
}
    800030fe:	70a2                	ld	ra,40(sp)
    80003100:	7402                	ld	s0,32(sp)
    80003102:	64e2                	ld	s1,24(sp)
    80003104:	6942                	ld	s2,16(sp)
    80003106:	6145                	addi	sp,sp,48
    80003108:	8082                	ret

000000008000310a <syscall>:
    [SYS_setpriority] 1,
};

void
syscall(void)
{
    8000310a:	7179                	addi	sp,sp,-48
    8000310c:	f406                	sd	ra,40(sp)
    8000310e:	f022                	sd	s0,32(sp)
    80003110:	ec26                	sd	s1,24(sp)
    80003112:	e84a                	sd	s2,16(sp)
    80003114:	e44e                	sd	s3,8(sp)
    80003116:	e052                	sd	s4,0(sp)
    80003118:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    8000311a:	fffff097          	auipc	ra,0xfffff
    8000311e:	8ac080e7          	jalr	-1876(ra) # 800019c6 <myproc>
    80003122:	892a                	mv	s2,a0

  num = p->trapframe->a7;
    80003124:	6d24                	ld	s1,88(a0)
    80003126:	74dc                	ld	a5,168(s1)
    80003128:	0007899b          	sext.w	s3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) 
    8000312c:	37fd                	addiw	a5,a5,-1
    8000312e:	4769                	li	a4,26
    80003130:	0af76163          	bltu	a4,a5,800031d2 <syscall+0xc8>
    80003134:	00399713          	slli	a4,s3,0x3
    80003138:	00005797          	auipc	a5,0x5
    8000313c:	3c878793          	addi	a5,a5,968 # 80008500 <syscalls>
    80003140:	97ba                	add	a5,a5,a4
    80003142:	639c                	ld	a5,0(a5)
    80003144:	c7d9                	beqz	a5,800031d2 <syscall+0xc8>
  {
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80003146:	9782                	jalr	a5
    80003148:	f8a8                	sd	a0,112(s1)
    if ((p->mask >> num) & 1)
    8000314a:	16892483          	lw	s1,360(s2)
    8000314e:	4134d4bb          	sraw	s1,s1,s3
    80003152:	8885                	andi	s1,s1,1
    80003154:	c0c5                	beqz	s1,800031f4 <syscall+0xea>
    {
      /* Modified for A4: Added entire section for trace, prints output for each syscall traced */
  	  printf("%d: syscall %s ( %d ",p->pid, syscallnames[num], p->trapframe->a0);
    80003156:	05893703          	ld	a4,88(s2)
    8000315a:	00399693          	slli	a3,s3,0x3
    8000315e:	00006797          	auipc	a5,0x6
    80003162:	87a78793          	addi	a5,a5,-1926 # 800089d8 <syscallnames>
    80003166:	97b6                	add	a5,a5,a3
    80003168:	7b34                	ld	a3,112(a4)
    8000316a:	6390                	ld	a2,0(a5)
    8000316c:	03092583          	lw	a1,48(s2)
    80003170:	00005517          	auipc	a0,0x5
    80003174:	23850513          	addi	a0,a0,568 # 800083a8 <digits+0x368>
    80003178:	ffffd097          	auipc	ra,0xffffd
    8000317c:	416080e7          	jalr	1046(ra) # 8000058e <printf>
      for (int i = 1; i < syscallnum[num]; i++) /* Modified for A4: 'num' tracks number of registers used by syscall and prints its register values  */
    80003180:	098a                	slli	s3,s3,0x2
    80003182:	00005797          	auipc	a5,0x5
    80003186:	37e78793          	addi	a5,a5,894 # 80008500 <syscalls>
    8000318a:	99be                	add	s3,s3,a5
    8000318c:	0e09a983          	lw	s3,224(s3)
    80003190:	4785                	li	a5,1
    80003192:	0337d463          	bge	a5,s3,800031ba <syscall+0xb0>
        printf("%d ", argraw(i));
    80003196:	00005a17          	auipc	s4,0x5
    8000319a:	22aa0a13          	addi	s4,s4,554 # 800083c0 <digits+0x380>
    8000319e:	8526                	mv	a0,s1
    800031a0:	00000097          	auipc	ra,0x0
    800031a4:	de8080e7          	jalr	-536(ra) # 80002f88 <argraw>
    800031a8:	85aa                	mv	a1,a0
    800031aa:	8552                	mv	a0,s4
    800031ac:	ffffd097          	auipc	ra,0xffffd
    800031b0:	3e2080e7          	jalr	994(ra) # 8000058e <printf>
      for (int i = 1; i < syscallnum[num]; i++) /* Modified for A4: 'num' tracks number of registers used by syscall and prints its register values  */
    800031b4:	2485                	addiw	s1,s1,1
    800031b6:	ff3494e3          	bne	s1,s3,8000319e <syscall+0x94>
      printf(") -> %d\n", p->trapframe->a0);
    800031ba:	05893783          	ld	a5,88(s2)
    800031be:	7bac                	ld	a1,112(a5)
    800031c0:	00005517          	auipc	a0,0x5
    800031c4:	20850513          	addi	a0,a0,520 # 800083c8 <digits+0x388>
    800031c8:	ffffd097          	auipc	ra,0xffffd
    800031cc:	3c6080e7          	jalr	966(ra) # 8000058e <printf>
    800031d0:	a015                	j	800031f4 <syscall+0xea>
    }	
  } 
  else 
  {
    printf("%d %s: unknown sys call %d\n",
    800031d2:	86ce                	mv	a3,s3
    800031d4:	15890613          	addi	a2,s2,344
    800031d8:	03092583          	lw	a1,48(s2)
    800031dc:	00005517          	auipc	a0,0x5
    800031e0:	1fc50513          	addi	a0,a0,508 # 800083d8 <digits+0x398>
    800031e4:	ffffd097          	auipc	ra,0xffffd
    800031e8:	3aa080e7          	jalr	938(ra) # 8000058e <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800031ec:	05893783          	ld	a5,88(s2)
    800031f0:	577d                	li	a4,-1
    800031f2:	fbb8                	sd	a4,112(a5)
  
  // if (p->mask >> num)
  // {
  // 	printf("%d: syscall %s -> %d\n",p->pid, syscallnames[num], p->trapframe->a0);
  // }	
}
    800031f4:	70a2                	ld	ra,40(sp)
    800031f6:	7402                	ld	s0,32(sp)
    800031f8:	64e2                	ld	s1,24(sp)
    800031fa:	6942                	ld	s2,16(sp)
    800031fc:	69a2                	ld	s3,8(sp)
    800031fe:	6a02                	ld	s4,0(sp)
    80003200:	6145                	addi	sp,sp,48
    80003202:	8082                	ret

0000000080003204 <sys_trace>:
#include "proc.h"


uint64
sys_trace(void)
{
    80003204:	1101                	addi	sp,sp,-32
    80003206:	ec06                	sd	ra,24(sp)
    80003208:	e822                	sd	s0,16(sp)
    8000320a:	1000                	addi	s0,sp,32
  int mask;
	if(argint(0, &mask) < 0)
    8000320c:	fec40593          	addi	a1,s0,-20
    80003210:	4501                	li	a0,0
    80003212:	00000097          	auipc	ra,0x0
    80003216:	e7c080e7          	jalr	-388(ra) # 8000308e <argint>
	{
		return -1;
    8000321a:	57fd                	li	a5,-1
	if(argint(0, &mask) < 0)
    8000321c:	00054b63          	bltz	a0,80003232 <sys_trace+0x2e>
	}
  myproc()->mask = mask;
    80003220:	ffffe097          	auipc	ra,0xffffe
    80003224:	7a6080e7          	jalr	1958(ra) # 800019c6 <myproc>
    80003228:	fec42783          	lw	a5,-20(s0)
    8000322c:	16f52423          	sw	a5,360(a0)
	return 0;
    80003230:	4781                	li	a5,0
}	/* Modified for A4: Added trace */
    80003232:	853e                	mv	a0,a5
    80003234:	60e2                	ld	ra,24(sp)
    80003236:	6442                	ld	s0,16(sp)
    80003238:	6105                	addi	sp,sp,32
    8000323a:	8082                	ret

000000008000323c <sys_sigalarm>:

/* Modified for A4: Added trace */
uint64 
sys_sigalarm(void)
{
    8000323c:	1101                	addi	sp,sp,-32
    8000323e:	ec06                	sd	ra,24(sp)
    80003240:	e822                	sd	s0,16(sp)
    80003242:	1000                	addi	s0,sp,32
  uint64 handleraddr;
  int ticks;
  if(argint(0, &ticks) < 0)
    80003244:	fe440593          	addi	a1,s0,-28
    80003248:	4501                	li	a0,0
    8000324a:	00000097          	auipc	ra,0x0
    8000324e:	e44080e7          	jalr	-444(ra) # 8000308e <argint>
    return -1;
    80003252:	57fd                	li	a5,-1
  if(argint(0, &ticks) < 0)
    80003254:	04054463          	bltz	a0,8000329c <sys_sigalarm+0x60>
  if(argaddr(1, &handleraddr) < 0)
    80003258:	fe840593          	addi	a1,s0,-24
    8000325c:	4505                	li	a0,1
    8000325e:	00000097          	auipc	ra,0x0
    80003262:	e52080e7          	jalr	-430(ra) # 800030b0 <argaddr>
    return -1;
    80003266:	57fd                	li	a5,-1
  if(argaddr(1, &handleraddr) < 0)
    80003268:	02054a63          	bltz	a0,8000329c <sys_sigalarm+0x60>

  myproc()->ticks = ticks;
    8000326c:	ffffe097          	auipc	ra,0xffffe
    80003270:	75a080e7          	jalr	1882(ra) # 800019c6 <myproc>
    80003274:	fe442783          	lw	a5,-28(s0)
    80003278:	18f52423          	sw	a5,392(a0)
  myproc()->handler = handleraddr;
    8000327c:	ffffe097          	auipc	ra,0xffffe
    80003280:	74a080e7          	jalr	1866(ra) # 800019c6 <myproc>
    80003284:	fe843783          	ld	a5,-24(s0)
    80003288:	18f53023          	sd	a5,384(a0)
  myproc()->alarm_on = 1;
    8000328c:	ffffe097          	auipc	ra,0xffffe
    80003290:	73a080e7          	jalr	1850(ra) # 800019c6 <myproc>
    80003294:	4785                	li	a5,1
    80003296:	18f52c23          	sw	a5,408(a0)
  //myproc()->a1 = myproc()->trapframe->a0;
  //myproc()->a2 = myproc()->trapframe->a1;

  return 0;
    8000329a:	4781                	li	a5,0
}
    8000329c:	853e                	mv	a0,a5
    8000329e:	60e2                	ld	ra,24(sp)
    800032a0:	6442                	ld	s0,16(sp)
    800032a2:	6105                	addi	sp,sp,32
    800032a4:	8082                	ret

00000000800032a6 <sys_sigreturn>:

/* Modified for A4: Added trace */
uint64 
sys_sigreturn(void)
{
    800032a6:	1101                	addi	sp,sp,-32
    800032a8:	ec06                	sd	ra,24(sp)
    800032aa:	e822                	sd	s0,16(sp)
    800032ac:	e426                	sd	s1,8(sp)
    800032ae:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800032b0:	ffffe097          	auipc	ra,0xffffe
    800032b4:	716080e7          	jalr	1814(ra) # 800019c6 <myproc>
    800032b8:	84aa                	mv	s1,a0
  memmove(p->trapframe, p->alarm_tf, PGSIZE);
    800032ba:	6605                	lui	a2,0x1
    800032bc:	19053583          	ld	a1,400(a0)
    800032c0:	6d28                	ld	a0,88(a0)
    800032c2:	ffffe097          	auipc	ra,0xffffe
    800032c6:	a84080e7          	jalr	-1404(ra) # 80000d46 <memmove>
  //myproc()->trapframe->a0 = myproc()->a1;
  //myproc()->trapframe->a1 = myproc()->a2;
  kfree(p->alarm_tf);
    800032ca:	1904b503          	ld	a0,400(s1)
    800032ce:	ffffd097          	auipc	ra,0xffffd
    800032d2:	730080e7          	jalr	1840(ra) # 800009fe <kfree>
  p->handlerpermission = 1;
    800032d6:	4785                	li	a5,1
    800032d8:	18f4ae23          	sw	a5,412(s1)
  return myproc()->trapframe->a0;
    800032dc:	ffffe097          	auipc	ra,0xffffe
    800032e0:	6ea080e7          	jalr	1770(ra) # 800019c6 <myproc>
    800032e4:	6d3c                	ld	a5,88(a0)
}
    800032e6:	7ba8                	ld	a0,112(a5)
    800032e8:	60e2                	ld	ra,24(sp)
    800032ea:	6442                	ld	s0,16(sp)
    800032ec:	64a2                	ld	s1,8(sp)
    800032ee:	6105                	addi	sp,sp,32
    800032f0:	8082                	ret

00000000800032f2 <sys_settickets>:

uint64 
sys_settickets(void)
{
    800032f2:	7179                	addi	sp,sp,-48
    800032f4:	f406                	sd	ra,40(sp)
    800032f6:	f022                	sd	s0,32(sp)
    800032f8:	ec26                	sd	s1,24(sp)
    800032fa:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800032fc:	ffffe097          	auipc	ra,0xffffe
    80003300:	6ca080e7          	jalr	1738(ra) # 800019c6 <myproc>
    80003304:	84aa                	mv	s1,a0
  int tickets;
  if(argint(0, &tickets) < 0)
    80003306:	fdc40593          	addi	a1,s0,-36
    8000330a:	4501                	li	a0,0
    8000330c:	00000097          	auipc	ra,0x0
    80003310:	d82080e7          	jalr	-638(ra) # 8000308e <argint>
    80003314:	00054c63          	bltz	a0,8000332c <sys_settickets+0x3a>
    return -1;
  p->tickets = tickets;
    80003318:	fdc42783          	lw	a5,-36(s0)
    8000331c:	1af4a023          	sw	a5,416(s1)
  return 0; 
    80003320:	4501                	li	a0,0
}
    80003322:	70a2                	ld	ra,40(sp)
    80003324:	7402                	ld	s0,32(sp)
    80003326:	64e2                	ld	s1,24(sp)
    80003328:	6145                	addi	sp,sp,48
    8000332a:	8082                	ret
    return -1;
    8000332c:	557d                	li	a0,-1
    8000332e:	bfd5                	j	80003322 <sys_settickets+0x30>

0000000080003330 <sys_setpriority>:

uint64
sys_setpriority()
{
    80003330:	1101                	addi	sp,sp,-32
    80003332:	ec06                	sd	ra,24(sp)
    80003334:	e822                	sd	s0,16(sp)
    80003336:	1000                	addi	s0,sp,32
  int pid, priority;
  int arg_num[2] = {0, 1};

  if(argint(arg_num[0], &priority) < 0)
    80003338:	fe840593          	addi	a1,s0,-24
    8000333c:	4501                	li	a0,0
    8000333e:	00000097          	auipc	ra,0x0
    80003342:	d50080e7          	jalr	-688(ra) # 8000308e <argint>
  {
    return -1;
    80003346:	57fd                	li	a5,-1
  if(argint(arg_num[0], &priority) < 0)
    80003348:	02054563          	bltz	a0,80003372 <sys_setpriority+0x42>
  }
  if(argint(arg_num[1], &pid) < 0)
    8000334c:	fec40593          	addi	a1,s0,-20
    80003350:	4505                	li	a0,1
    80003352:	00000097          	auipc	ra,0x0
    80003356:	d3c080e7          	jalr	-708(ra) # 8000308e <argint>
  {
    return -1;
    8000335a:	57fd                	li	a5,-1
  if(argint(arg_num[1], &pid) < 0)
    8000335c:	00054b63          	bltz	a0,80003372 <sys_setpriority+0x42>
  }
   
  return setpriority(priority, pid);
    80003360:	fec42583          	lw	a1,-20(s0)
    80003364:	fe842503          	lw	a0,-24(s0)
    80003368:	fffff097          	auipc	ra,0xfffff
    8000336c:	740080e7          	jalr	1856(ra) # 80002aa8 <setpriority>
    80003370:	87aa                	mv	a5,a0
}
    80003372:	853e                	mv	a0,a5
    80003374:	60e2                	ld	ra,24(sp)
    80003376:	6442                	ld	s0,16(sp)
    80003378:	6105                	addi	sp,sp,32
    8000337a:	8082                	ret

000000008000337c <sys_exit>:


uint64
sys_exit(void)
{
    8000337c:	1101                	addi	sp,sp,-32
    8000337e:	ec06                	sd	ra,24(sp)
    80003380:	e822                	sd	s0,16(sp)
    80003382:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80003384:	fec40593          	addi	a1,s0,-20
    80003388:	4501                	li	a0,0
    8000338a:	00000097          	auipc	ra,0x0
    8000338e:	d04080e7          	jalr	-764(ra) # 8000308e <argint>
  exit(n);
    80003392:	fec42503          	lw	a0,-20(s0)
    80003396:	fffff097          	auipc	ra,0xfffff
    8000339a:	302080e7          	jalr	770(ra) # 80002698 <exit>
  return 0;  // not reached
}
    8000339e:	4501                	li	a0,0
    800033a0:	60e2                	ld	ra,24(sp)
    800033a2:	6442                	ld	s0,16(sp)
    800033a4:	6105                	addi	sp,sp,32
    800033a6:	8082                	ret

00000000800033a8 <sys_getpid>:

uint64
sys_getpid(void)
{
    800033a8:	1141                	addi	sp,sp,-16
    800033aa:	e406                	sd	ra,8(sp)
    800033ac:	e022                	sd	s0,0(sp)
    800033ae:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800033b0:	ffffe097          	auipc	ra,0xffffe
    800033b4:	616080e7          	jalr	1558(ra) # 800019c6 <myproc>
}
    800033b8:	5908                	lw	a0,48(a0)
    800033ba:	60a2                	ld	ra,8(sp)
    800033bc:	6402                	ld	s0,0(sp)
    800033be:	0141                	addi	sp,sp,16
    800033c0:	8082                	ret

00000000800033c2 <sys_fork>:

uint64
sys_fork(void)
{
    800033c2:	1141                	addi	sp,sp,-16
    800033c4:	e406                	sd	ra,8(sp)
    800033c6:	e022                	sd	s0,0(sp)
    800033c8:	0800                	addi	s0,sp,16
  return fork();
    800033ca:	fffff097          	auipc	ra,0xfffff
    800033ce:	a28080e7          	jalr	-1496(ra) # 80001df2 <fork>
}
    800033d2:	60a2                	ld	ra,8(sp)
    800033d4:	6402                	ld	s0,0(sp)
    800033d6:	0141                	addi	sp,sp,16
    800033d8:	8082                	ret

00000000800033da <sys_wait>:

uint64
sys_wait(void)
{
    800033da:	1101                	addi	sp,sp,-32
    800033dc:	ec06                	sd	ra,24(sp)
    800033de:	e822                	sd	s0,16(sp)
    800033e0:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800033e2:	fe840593          	addi	a1,s0,-24
    800033e6:	4501                	li	a0,0
    800033e8:	00000097          	auipc	ra,0x0
    800033ec:	cc8080e7          	jalr	-824(ra) # 800030b0 <argaddr>
  return wait(p);
    800033f0:	fe843503          	ld	a0,-24(s0)
    800033f4:	fffff097          	auipc	ra,0xfffff
    800033f8:	456080e7          	jalr	1110(ra) # 8000284a <wait>
}
    800033fc:	60e2                	ld	ra,24(sp)
    800033fe:	6442                	ld	s0,16(sp)
    80003400:	6105                	addi	sp,sp,32
    80003402:	8082                	ret

0000000080003404 <sys_waitx>:

uint64
sys_waitx(void)
{
    80003404:	7139                	addi	sp,sp,-64
    80003406:	fc06                	sd	ra,56(sp)
    80003408:	f822                	sd	s0,48(sp)
    8000340a:	f426                	sd	s1,40(sp)
    8000340c:	f04a                	sd	s2,32(sp)
    8000340e:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    80003410:	fd840593          	addi	a1,s0,-40
    80003414:	4501                	li	a0,0
    80003416:	00000097          	auipc	ra,0x0
    8000341a:	c9a080e7          	jalr	-870(ra) # 800030b0 <argaddr>
  argaddr(1, &addr1); // user virtual memory
    8000341e:	fd040593          	addi	a1,s0,-48
    80003422:	4505                	li	a0,1
    80003424:	00000097          	auipc	ra,0x0
    80003428:	c8c080e7          	jalr	-884(ra) # 800030b0 <argaddr>
  argaddr(2, &addr2);
    8000342c:	fc840593          	addi	a1,s0,-56
    80003430:	4509                	li	a0,2
    80003432:	00000097          	auipc	ra,0x0
    80003436:	c7e080e7          	jalr	-898(ra) # 800030b0 <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    8000343a:	fc040613          	addi	a2,s0,-64
    8000343e:	fc440593          	addi	a1,s0,-60
    80003442:	fd843503          	ld	a0,-40(s0)
    80003446:	fffff097          	auipc	ra,0xfffff
    8000344a:	036080e7          	jalr	54(ra) # 8000247c <waitx>
    8000344e:	892a                	mv	s2,a0
  struct proc* p = myproc();
    80003450:	ffffe097          	auipc	ra,0xffffe
    80003454:	576080e7          	jalr	1398(ra) # 800019c6 <myproc>
    80003458:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    8000345a:	4691                	li	a3,4
    8000345c:	fc440613          	addi	a2,s0,-60
    80003460:	fd043583          	ld	a1,-48(s0)
    80003464:	6928                	ld	a0,80(a0)
    80003466:	ffffe097          	auipc	ra,0xffffe
    8000346a:	21e080e7          	jalr	542(ra) # 80001684 <copyout>
    return -1;
    8000346e:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    80003470:	00054f63          	bltz	a0,8000348e <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2,(char*)&rtime, sizeof(int)) < 0)
    80003474:	4691                	li	a3,4
    80003476:	fc040613          	addi	a2,s0,-64
    8000347a:	fc843583          	ld	a1,-56(s0)
    8000347e:	68a8                	ld	a0,80(s1)
    80003480:	ffffe097          	auipc	ra,0xffffe
    80003484:	204080e7          	jalr	516(ra) # 80001684 <copyout>
    80003488:	00054a63          	bltz	a0,8000349c <sys_waitx+0x98>
    return -1;
  return ret;
    8000348c:	87ca                	mv	a5,s2
}
    8000348e:	853e                	mv	a0,a5
    80003490:	70e2                	ld	ra,56(sp)
    80003492:	7442                	ld	s0,48(sp)
    80003494:	74a2                	ld	s1,40(sp)
    80003496:	7902                	ld	s2,32(sp)
    80003498:	6121                	addi	sp,sp,64
    8000349a:	8082                	ret
    return -1;
    8000349c:	57fd                	li	a5,-1
    8000349e:	bfc5                	j	8000348e <sys_waitx+0x8a>

00000000800034a0 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800034a0:	7179                	addi	sp,sp,-48
    800034a2:	f406                	sd	ra,40(sp)
    800034a4:	f022                	sd	s0,32(sp)
    800034a6:	ec26                	sd	s1,24(sp)
    800034a8:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    800034aa:	fdc40593          	addi	a1,s0,-36
    800034ae:	4501                	li	a0,0
    800034b0:	00000097          	auipc	ra,0x0
    800034b4:	bde080e7          	jalr	-1058(ra) # 8000308e <argint>
  addr = myproc()->sz;
    800034b8:	ffffe097          	auipc	ra,0xffffe
    800034bc:	50e080e7          	jalr	1294(ra) # 800019c6 <myproc>
    800034c0:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    800034c2:	fdc42503          	lw	a0,-36(s0)
    800034c6:	fffff097          	auipc	ra,0xfffff
    800034ca:	8d0080e7          	jalr	-1840(ra) # 80001d96 <growproc>
    800034ce:	00054863          	bltz	a0,800034de <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    800034d2:	8526                	mv	a0,s1
    800034d4:	70a2                	ld	ra,40(sp)
    800034d6:	7402                	ld	s0,32(sp)
    800034d8:	64e2                	ld	s1,24(sp)
    800034da:	6145                	addi	sp,sp,48
    800034dc:	8082                	ret
    return -1;
    800034de:	54fd                	li	s1,-1
    800034e0:	bfcd                	j	800034d2 <sys_sbrk+0x32>

00000000800034e2 <sys_sleep>:

uint64
sys_sleep(void)
{
    800034e2:	7139                	addi	sp,sp,-64
    800034e4:	fc06                	sd	ra,56(sp)
    800034e6:	f822                	sd	s0,48(sp)
    800034e8:	f426                	sd	s1,40(sp)
    800034ea:	f04a                	sd	s2,32(sp)
    800034ec:	ec4e                	sd	s3,24(sp)
    800034ee:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800034f0:	fcc40593          	addi	a1,s0,-52
    800034f4:	4501                	li	a0,0
    800034f6:	00000097          	auipc	ra,0x0
    800034fa:	b98080e7          	jalr	-1128(ra) # 8000308e <argint>
  acquire(&tickslock);
    800034fe:	00015517          	auipc	a0,0x15
    80003502:	4c250513          	addi	a0,a0,1218 # 800189c0 <tickslock>
    80003506:	ffffd097          	auipc	ra,0xffffd
    8000350a:	6e4080e7          	jalr	1764(ra) # 80000bea <acquire>
  ticks0 = ticks;
    8000350e:	00005917          	auipc	s2,0x5
    80003512:	5e292903          	lw	s2,1506(s2) # 80008af0 <ticks>
  while(ticks - ticks0 < n){
    80003516:	fcc42783          	lw	a5,-52(s0)
    8000351a:	cf9d                	beqz	a5,80003558 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000351c:	00015997          	auipc	s3,0x15
    80003520:	4a498993          	addi	s3,s3,1188 # 800189c0 <tickslock>
    80003524:	00005497          	auipc	s1,0x5
    80003528:	5cc48493          	addi	s1,s1,1484 # 80008af0 <ticks>
    if(killed(myproc())){
    8000352c:	ffffe097          	auipc	ra,0xffffe
    80003530:	49a080e7          	jalr	1178(ra) # 800019c6 <myproc>
    80003534:	fffff097          	auipc	ra,0xfffff
    80003538:	2e4080e7          	jalr	740(ra) # 80002818 <killed>
    8000353c:	ed15                	bnez	a0,80003578 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    8000353e:	85ce                	mv	a1,s3
    80003540:	8526                	mv	a0,s1
    80003542:	fffff097          	auipc	ra,0xfffff
    80003546:	ed6080e7          	jalr	-298(ra) # 80002418 <sleep>
  while(ticks - ticks0 < n){
    8000354a:	409c                	lw	a5,0(s1)
    8000354c:	412787bb          	subw	a5,a5,s2
    80003550:	fcc42703          	lw	a4,-52(s0)
    80003554:	fce7ece3          	bltu	a5,a4,8000352c <sys_sleep+0x4a>
  }
  release(&tickslock);
    80003558:	00015517          	auipc	a0,0x15
    8000355c:	46850513          	addi	a0,a0,1128 # 800189c0 <tickslock>
    80003560:	ffffd097          	auipc	ra,0xffffd
    80003564:	73e080e7          	jalr	1854(ra) # 80000c9e <release>
  return 0;
    80003568:	4501                	li	a0,0
}
    8000356a:	70e2                	ld	ra,56(sp)
    8000356c:	7442                	ld	s0,48(sp)
    8000356e:	74a2                	ld	s1,40(sp)
    80003570:	7902                	ld	s2,32(sp)
    80003572:	69e2                	ld	s3,24(sp)
    80003574:	6121                	addi	sp,sp,64
    80003576:	8082                	ret
      release(&tickslock);
    80003578:	00015517          	auipc	a0,0x15
    8000357c:	44850513          	addi	a0,a0,1096 # 800189c0 <tickslock>
    80003580:	ffffd097          	auipc	ra,0xffffd
    80003584:	71e080e7          	jalr	1822(ra) # 80000c9e <release>
      return -1;
    80003588:	557d                	li	a0,-1
    8000358a:	b7c5                	j	8000356a <sys_sleep+0x88>

000000008000358c <sys_kill>:

uint64
sys_kill(void)
{
    8000358c:	1101                	addi	sp,sp,-32
    8000358e:	ec06                	sd	ra,24(sp)
    80003590:	e822                	sd	s0,16(sp)
    80003592:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003594:	fec40593          	addi	a1,s0,-20
    80003598:	4501                	li	a0,0
    8000359a:	00000097          	auipc	ra,0x0
    8000359e:	af4080e7          	jalr	-1292(ra) # 8000308e <argint>
  return kill(pid);
    800035a2:	fec42503          	lw	a0,-20(s0)
    800035a6:	fffff097          	auipc	ra,0xfffff
    800035aa:	1d4080e7          	jalr	468(ra) # 8000277a <kill>
}
    800035ae:	60e2                	ld	ra,24(sp)
    800035b0:	6442                	ld	s0,16(sp)
    800035b2:	6105                	addi	sp,sp,32
    800035b4:	8082                	ret

00000000800035b6 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800035b6:	1101                	addi	sp,sp,-32
    800035b8:	ec06                	sd	ra,24(sp)
    800035ba:	e822                	sd	s0,16(sp)
    800035bc:	e426                	sd	s1,8(sp)
    800035be:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800035c0:	00015517          	auipc	a0,0x15
    800035c4:	40050513          	addi	a0,a0,1024 # 800189c0 <tickslock>
    800035c8:	ffffd097          	auipc	ra,0xffffd
    800035cc:	622080e7          	jalr	1570(ra) # 80000bea <acquire>
  xticks = ticks;
    800035d0:	00005497          	auipc	s1,0x5
    800035d4:	5204a483          	lw	s1,1312(s1) # 80008af0 <ticks>
  release(&tickslock);
    800035d8:	00015517          	auipc	a0,0x15
    800035dc:	3e850513          	addi	a0,a0,1000 # 800189c0 <tickslock>
    800035e0:	ffffd097          	auipc	ra,0xffffd
    800035e4:	6be080e7          	jalr	1726(ra) # 80000c9e <release>
  return xticks;
}
    800035e8:	02049513          	slli	a0,s1,0x20
    800035ec:	9101                	srli	a0,a0,0x20
    800035ee:	60e2                	ld	ra,24(sp)
    800035f0:	6442                	ld	s0,16(sp)
    800035f2:	64a2                	ld	s1,8(sp)
    800035f4:	6105                	addi	sp,sp,32
    800035f6:	8082                	ret

00000000800035f8 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800035f8:	7179                	addi	sp,sp,-48
    800035fa:	f406                	sd	ra,40(sp)
    800035fc:	f022                	sd	s0,32(sp)
    800035fe:	ec26                	sd	s1,24(sp)
    80003600:	e84a                	sd	s2,16(sp)
    80003602:	e44e                	sd	s3,8(sp)
    80003604:	e052                	sd	s4,0(sp)
    80003606:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003608:	00005597          	auipc	a1,0x5
    8000360c:	04858593          	addi	a1,a1,72 # 80008650 <syscallnum+0x70>
    80003610:	00015517          	auipc	a0,0x15
    80003614:	3c850513          	addi	a0,a0,968 # 800189d8 <bcache>
    80003618:	ffffd097          	auipc	ra,0xffffd
    8000361c:	542080e7          	jalr	1346(ra) # 80000b5a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003620:	0001d797          	auipc	a5,0x1d
    80003624:	3b878793          	addi	a5,a5,952 # 800209d8 <bcache+0x8000>
    80003628:	0001d717          	auipc	a4,0x1d
    8000362c:	61870713          	addi	a4,a4,1560 # 80020c40 <bcache+0x8268>
    80003630:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003634:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003638:	00015497          	auipc	s1,0x15
    8000363c:	3b848493          	addi	s1,s1,952 # 800189f0 <bcache+0x18>
    b->next = bcache.head.next;
    80003640:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003642:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003644:	00005a17          	auipc	s4,0x5
    80003648:	014a0a13          	addi	s4,s4,20 # 80008658 <syscallnum+0x78>
    b->next = bcache.head.next;
    8000364c:	2b893783          	ld	a5,696(s2)
    80003650:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003652:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003656:	85d2                	mv	a1,s4
    80003658:	01048513          	addi	a0,s1,16
    8000365c:	00001097          	auipc	ra,0x1
    80003660:	4c4080e7          	jalr	1220(ra) # 80004b20 <initsleeplock>
    bcache.head.next->prev = b;
    80003664:	2b893783          	ld	a5,696(s2)
    80003668:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000366a:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000366e:	45848493          	addi	s1,s1,1112
    80003672:	fd349de3          	bne	s1,s3,8000364c <binit+0x54>
  }
}
    80003676:	70a2                	ld	ra,40(sp)
    80003678:	7402                	ld	s0,32(sp)
    8000367a:	64e2                	ld	s1,24(sp)
    8000367c:	6942                	ld	s2,16(sp)
    8000367e:	69a2                	ld	s3,8(sp)
    80003680:	6a02                	ld	s4,0(sp)
    80003682:	6145                	addi	sp,sp,48
    80003684:	8082                	ret

0000000080003686 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003686:	7179                	addi	sp,sp,-48
    80003688:	f406                	sd	ra,40(sp)
    8000368a:	f022                	sd	s0,32(sp)
    8000368c:	ec26                	sd	s1,24(sp)
    8000368e:	e84a                	sd	s2,16(sp)
    80003690:	e44e                	sd	s3,8(sp)
    80003692:	1800                	addi	s0,sp,48
    80003694:	89aa                	mv	s3,a0
    80003696:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80003698:	00015517          	auipc	a0,0x15
    8000369c:	34050513          	addi	a0,a0,832 # 800189d8 <bcache>
    800036a0:	ffffd097          	auipc	ra,0xffffd
    800036a4:	54a080e7          	jalr	1354(ra) # 80000bea <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800036a8:	0001d497          	auipc	s1,0x1d
    800036ac:	5e84b483          	ld	s1,1512(s1) # 80020c90 <bcache+0x82b8>
    800036b0:	0001d797          	auipc	a5,0x1d
    800036b4:	59078793          	addi	a5,a5,1424 # 80020c40 <bcache+0x8268>
    800036b8:	02f48f63          	beq	s1,a5,800036f6 <bread+0x70>
    800036bc:	873e                	mv	a4,a5
    800036be:	a021                	j	800036c6 <bread+0x40>
    800036c0:	68a4                	ld	s1,80(s1)
    800036c2:	02e48a63          	beq	s1,a4,800036f6 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800036c6:	449c                	lw	a5,8(s1)
    800036c8:	ff379ce3          	bne	a5,s3,800036c0 <bread+0x3a>
    800036cc:	44dc                	lw	a5,12(s1)
    800036ce:	ff2799e3          	bne	a5,s2,800036c0 <bread+0x3a>
      b->refcnt++;
    800036d2:	40bc                	lw	a5,64(s1)
    800036d4:	2785                	addiw	a5,a5,1
    800036d6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800036d8:	00015517          	auipc	a0,0x15
    800036dc:	30050513          	addi	a0,a0,768 # 800189d8 <bcache>
    800036e0:	ffffd097          	auipc	ra,0xffffd
    800036e4:	5be080e7          	jalr	1470(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    800036e8:	01048513          	addi	a0,s1,16
    800036ec:	00001097          	auipc	ra,0x1
    800036f0:	46e080e7          	jalr	1134(ra) # 80004b5a <acquiresleep>
      return b;
    800036f4:	a8b9                	j	80003752 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800036f6:	0001d497          	auipc	s1,0x1d
    800036fa:	5924b483          	ld	s1,1426(s1) # 80020c88 <bcache+0x82b0>
    800036fe:	0001d797          	auipc	a5,0x1d
    80003702:	54278793          	addi	a5,a5,1346 # 80020c40 <bcache+0x8268>
    80003706:	00f48863          	beq	s1,a5,80003716 <bread+0x90>
    8000370a:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000370c:	40bc                	lw	a5,64(s1)
    8000370e:	cf81                	beqz	a5,80003726 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003710:	64a4                	ld	s1,72(s1)
    80003712:	fee49de3          	bne	s1,a4,8000370c <bread+0x86>
  panic("bget: no buffers");
    80003716:	00005517          	auipc	a0,0x5
    8000371a:	f4a50513          	addi	a0,a0,-182 # 80008660 <syscallnum+0x80>
    8000371e:	ffffd097          	auipc	ra,0xffffd
    80003722:	e26080e7          	jalr	-474(ra) # 80000544 <panic>
      b->dev = dev;
    80003726:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    8000372a:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    8000372e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003732:	4785                	li	a5,1
    80003734:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003736:	00015517          	auipc	a0,0x15
    8000373a:	2a250513          	addi	a0,a0,674 # 800189d8 <bcache>
    8000373e:	ffffd097          	auipc	ra,0xffffd
    80003742:	560080e7          	jalr	1376(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    80003746:	01048513          	addi	a0,s1,16
    8000374a:	00001097          	auipc	ra,0x1
    8000374e:	410080e7          	jalr	1040(ra) # 80004b5a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003752:	409c                	lw	a5,0(s1)
    80003754:	cb89                	beqz	a5,80003766 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003756:	8526                	mv	a0,s1
    80003758:	70a2                	ld	ra,40(sp)
    8000375a:	7402                	ld	s0,32(sp)
    8000375c:	64e2                	ld	s1,24(sp)
    8000375e:	6942                	ld	s2,16(sp)
    80003760:	69a2                	ld	s3,8(sp)
    80003762:	6145                	addi	sp,sp,48
    80003764:	8082                	ret
    virtio_disk_rw(b, 0);
    80003766:	4581                	li	a1,0
    80003768:	8526                	mv	a0,s1
    8000376a:	00003097          	auipc	ra,0x3
    8000376e:	fce080e7          	jalr	-50(ra) # 80006738 <virtio_disk_rw>
    b->valid = 1;
    80003772:	4785                	li	a5,1
    80003774:	c09c                	sw	a5,0(s1)
  return b;
    80003776:	b7c5                	j	80003756 <bread+0xd0>

0000000080003778 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003778:	1101                	addi	sp,sp,-32
    8000377a:	ec06                	sd	ra,24(sp)
    8000377c:	e822                	sd	s0,16(sp)
    8000377e:	e426                	sd	s1,8(sp)
    80003780:	1000                	addi	s0,sp,32
    80003782:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003784:	0541                	addi	a0,a0,16
    80003786:	00001097          	auipc	ra,0x1
    8000378a:	46e080e7          	jalr	1134(ra) # 80004bf4 <holdingsleep>
    8000378e:	cd01                	beqz	a0,800037a6 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003790:	4585                	li	a1,1
    80003792:	8526                	mv	a0,s1
    80003794:	00003097          	auipc	ra,0x3
    80003798:	fa4080e7          	jalr	-92(ra) # 80006738 <virtio_disk_rw>
}
    8000379c:	60e2                	ld	ra,24(sp)
    8000379e:	6442                	ld	s0,16(sp)
    800037a0:	64a2                	ld	s1,8(sp)
    800037a2:	6105                	addi	sp,sp,32
    800037a4:	8082                	ret
    panic("bwrite");
    800037a6:	00005517          	auipc	a0,0x5
    800037aa:	ed250513          	addi	a0,a0,-302 # 80008678 <syscallnum+0x98>
    800037ae:	ffffd097          	auipc	ra,0xffffd
    800037b2:	d96080e7          	jalr	-618(ra) # 80000544 <panic>

00000000800037b6 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800037b6:	1101                	addi	sp,sp,-32
    800037b8:	ec06                	sd	ra,24(sp)
    800037ba:	e822                	sd	s0,16(sp)
    800037bc:	e426                	sd	s1,8(sp)
    800037be:	e04a                	sd	s2,0(sp)
    800037c0:	1000                	addi	s0,sp,32
    800037c2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800037c4:	01050913          	addi	s2,a0,16
    800037c8:	854a                	mv	a0,s2
    800037ca:	00001097          	auipc	ra,0x1
    800037ce:	42a080e7          	jalr	1066(ra) # 80004bf4 <holdingsleep>
    800037d2:	c92d                	beqz	a0,80003844 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800037d4:	854a                	mv	a0,s2
    800037d6:	00001097          	auipc	ra,0x1
    800037da:	3da080e7          	jalr	986(ra) # 80004bb0 <releasesleep>

  acquire(&bcache.lock);
    800037de:	00015517          	auipc	a0,0x15
    800037e2:	1fa50513          	addi	a0,a0,506 # 800189d8 <bcache>
    800037e6:	ffffd097          	auipc	ra,0xffffd
    800037ea:	404080e7          	jalr	1028(ra) # 80000bea <acquire>
  b->refcnt--;
    800037ee:	40bc                	lw	a5,64(s1)
    800037f0:	37fd                	addiw	a5,a5,-1
    800037f2:	0007871b          	sext.w	a4,a5
    800037f6:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800037f8:	eb05                	bnez	a4,80003828 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800037fa:	68bc                	ld	a5,80(s1)
    800037fc:	64b8                	ld	a4,72(s1)
    800037fe:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003800:	64bc                	ld	a5,72(s1)
    80003802:	68b8                	ld	a4,80(s1)
    80003804:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003806:	0001d797          	auipc	a5,0x1d
    8000380a:	1d278793          	addi	a5,a5,466 # 800209d8 <bcache+0x8000>
    8000380e:	2b87b703          	ld	a4,696(a5)
    80003812:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003814:	0001d717          	auipc	a4,0x1d
    80003818:	42c70713          	addi	a4,a4,1068 # 80020c40 <bcache+0x8268>
    8000381c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000381e:	2b87b703          	ld	a4,696(a5)
    80003822:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003824:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003828:	00015517          	auipc	a0,0x15
    8000382c:	1b050513          	addi	a0,a0,432 # 800189d8 <bcache>
    80003830:	ffffd097          	auipc	ra,0xffffd
    80003834:	46e080e7          	jalr	1134(ra) # 80000c9e <release>
}
    80003838:	60e2                	ld	ra,24(sp)
    8000383a:	6442                	ld	s0,16(sp)
    8000383c:	64a2                	ld	s1,8(sp)
    8000383e:	6902                	ld	s2,0(sp)
    80003840:	6105                	addi	sp,sp,32
    80003842:	8082                	ret
    panic("brelse");
    80003844:	00005517          	auipc	a0,0x5
    80003848:	e3c50513          	addi	a0,a0,-452 # 80008680 <syscallnum+0xa0>
    8000384c:	ffffd097          	auipc	ra,0xffffd
    80003850:	cf8080e7          	jalr	-776(ra) # 80000544 <panic>

0000000080003854 <bpin>:

void
bpin(struct buf *b) {
    80003854:	1101                	addi	sp,sp,-32
    80003856:	ec06                	sd	ra,24(sp)
    80003858:	e822                	sd	s0,16(sp)
    8000385a:	e426                	sd	s1,8(sp)
    8000385c:	1000                	addi	s0,sp,32
    8000385e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003860:	00015517          	auipc	a0,0x15
    80003864:	17850513          	addi	a0,a0,376 # 800189d8 <bcache>
    80003868:	ffffd097          	auipc	ra,0xffffd
    8000386c:	382080e7          	jalr	898(ra) # 80000bea <acquire>
  b->refcnt++;
    80003870:	40bc                	lw	a5,64(s1)
    80003872:	2785                	addiw	a5,a5,1
    80003874:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003876:	00015517          	auipc	a0,0x15
    8000387a:	16250513          	addi	a0,a0,354 # 800189d8 <bcache>
    8000387e:	ffffd097          	auipc	ra,0xffffd
    80003882:	420080e7          	jalr	1056(ra) # 80000c9e <release>
}
    80003886:	60e2                	ld	ra,24(sp)
    80003888:	6442                	ld	s0,16(sp)
    8000388a:	64a2                	ld	s1,8(sp)
    8000388c:	6105                	addi	sp,sp,32
    8000388e:	8082                	ret

0000000080003890 <bunpin>:

void
bunpin(struct buf *b) {
    80003890:	1101                	addi	sp,sp,-32
    80003892:	ec06                	sd	ra,24(sp)
    80003894:	e822                	sd	s0,16(sp)
    80003896:	e426                	sd	s1,8(sp)
    80003898:	1000                	addi	s0,sp,32
    8000389a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000389c:	00015517          	auipc	a0,0x15
    800038a0:	13c50513          	addi	a0,a0,316 # 800189d8 <bcache>
    800038a4:	ffffd097          	auipc	ra,0xffffd
    800038a8:	346080e7          	jalr	838(ra) # 80000bea <acquire>
  b->refcnt--;
    800038ac:	40bc                	lw	a5,64(s1)
    800038ae:	37fd                	addiw	a5,a5,-1
    800038b0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800038b2:	00015517          	auipc	a0,0x15
    800038b6:	12650513          	addi	a0,a0,294 # 800189d8 <bcache>
    800038ba:	ffffd097          	auipc	ra,0xffffd
    800038be:	3e4080e7          	jalr	996(ra) # 80000c9e <release>
}
    800038c2:	60e2                	ld	ra,24(sp)
    800038c4:	6442                	ld	s0,16(sp)
    800038c6:	64a2                	ld	s1,8(sp)
    800038c8:	6105                	addi	sp,sp,32
    800038ca:	8082                	ret

00000000800038cc <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800038cc:	1101                	addi	sp,sp,-32
    800038ce:	ec06                	sd	ra,24(sp)
    800038d0:	e822                	sd	s0,16(sp)
    800038d2:	e426                	sd	s1,8(sp)
    800038d4:	e04a                	sd	s2,0(sp)
    800038d6:	1000                	addi	s0,sp,32
    800038d8:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800038da:	00d5d59b          	srliw	a1,a1,0xd
    800038de:	0001d797          	auipc	a5,0x1d
    800038e2:	7d67a783          	lw	a5,2006(a5) # 800210b4 <sb+0x1c>
    800038e6:	9dbd                	addw	a1,a1,a5
    800038e8:	00000097          	auipc	ra,0x0
    800038ec:	d9e080e7          	jalr	-610(ra) # 80003686 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800038f0:	0074f713          	andi	a4,s1,7
    800038f4:	4785                	li	a5,1
    800038f6:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800038fa:	14ce                	slli	s1,s1,0x33
    800038fc:	90d9                	srli	s1,s1,0x36
    800038fe:	00950733          	add	a4,a0,s1
    80003902:	05874703          	lbu	a4,88(a4)
    80003906:	00e7f6b3          	and	a3,a5,a4
    8000390a:	c69d                	beqz	a3,80003938 <bfree+0x6c>
    8000390c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000390e:	94aa                	add	s1,s1,a0
    80003910:	fff7c793          	not	a5,a5
    80003914:	8ff9                	and	a5,a5,a4
    80003916:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    8000391a:	00001097          	auipc	ra,0x1
    8000391e:	120080e7          	jalr	288(ra) # 80004a3a <log_write>
  brelse(bp);
    80003922:	854a                	mv	a0,s2
    80003924:	00000097          	auipc	ra,0x0
    80003928:	e92080e7          	jalr	-366(ra) # 800037b6 <brelse>
}
    8000392c:	60e2                	ld	ra,24(sp)
    8000392e:	6442                	ld	s0,16(sp)
    80003930:	64a2                	ld	s1,8(sp)
    80003932:	6902                	ld	s2,0(sp)
    80003934:	6105                	addi	sp,sp,32
    80003936:	8082                	ret
    panic("freeing free block");
    80003938:	00005517          	auipc	a0,0x5
    8000393c:	d5050513          	addi	a0,a0,-688 # 80008688 <syscallnum+0xa8>
    80003940:	ffffd097          	auipc	ra,0xffffd
    80003944:	c04080e7          	jalr	-1020(ra) # 80000544 <panic>

0000000080003948 <balloc>:
{
    80003948:	711d                	addi	sp,sp,-96
    8000394a:	ec86                	sd	ra,88(sp)
    8000394c:	e8a2                	sd	s0,80(sp)
    8000394e:	e4a6                	sd	s1,72(sp)
    80003950:	e0ca                	sd	s2,64(sp)
    80003952:	fc4e                	sd	s3,56(sp)
    80003954:	f852                	sd	s4,48(sp)
    80003956:	f456                	sd	s5,40(sp)
    80003958:	f05a                	sd	s6,32(sp)
    8000395a:	ec5e                	sd	s7,24(sp)
    8000395c:	e862                	sd	s8,16(sp)
    8000395e:	e466                	sd	s9,8(sp)
    80003960:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003962:	0001d797          	auipc	a5,0x1d
    80003966:	73a7a783          	lw	a5,1850(a5) # 8002109c <sb+0x4>
    8000396a:	10078163          	beqz	a5,80003a6c <balloc+0x124>
    8000396e:	8baa                	mv	s7,a0
    80003970:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003972:	0001db17          	auipc	s6,0x1d
    80003976:	726b0b13          	addi	s6,s6,1830 # 80021098 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000397a:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000397c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000397e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003980:	6c89                	lui	s9,0x2
    80003982:	a061                	j	80003a0a <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003984:	974a                	add	a4,a4,s2
    80003986:	8fd5                	or	a5,a5,a3
    80003988:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    8000398c:	854a                	mv	a0,s2
    8000398e:	00001097          	auipc	ra,0x1
    80003992:	0ac080e7          	jalr	172(ra) # 80004a3a <log_write>
        brelse(bp);
    80003996:	854a                	mv	a0,s2
    80003998:	00000097          	auipc	ra,0x0
    8000399c:	e1e080e7          	jalr	-482(ra) # 800037b6 <brelse>
  bp = bread(dev, bno);
    800039a0:	85a6                	mv	a1,s1
    800039a2:	855e                	mv	a0,s7
    800039a4:	00000097          	auipc	ra,0x0
    800039a8:	ce2080e7          	jalr	-798(ra) # 80003686 <bread>
    800039ac:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800039ae:	40000613          	li	a2,1024
    800039b2:	4581                	li	a1,0
    800039b4:	05850513          	addi	a0,a0,88
    800039b8:	ffffd097          	auipc	ra,0xffffd
    800039bc:	32e080e7          	jalr	814(ra) # 80000ce6 <memset>
  log_write(bp);
    800039c0:	854a                	mv	a0,s2
    800039c2:	00001097          	auipc	ra,0x1
    800039c6:	078080e7          	jalr	120(ra) # 80004a3a <log_write>
  brelse(bp);
    800039ca:	854a                	mv	a0,s2
    800039cc:	00000097          	auipc	ra,0x0
    800039d0:	dea080e7          	jalr	-534(ra) # 800037b6 <brelse>
}
    800039d4:	8526                	mv	a0,s1
    800039d6:	60e6                	ld	ra,88(sp)
    800039d8:	6446                	ld	s0,80(sp)
    800039da:	64a6                	ld	s1,72(sp)
    800039dc:	6906                	ld	s2,64(sp)
    800039de:	79e2                	ld	s3,56(sp)
    800039e0:	7a42                	ld	s4,48(sp)
    800039e2:	7aa2                	ld	s5,40(sp)
    800039e4:	7b02                	ld	s6,32(sp)
    800039e6:	6be2                	ld	s7,24(sp)
    800039e8:	6c42                	ld	s8,16(sp)
    800039ea:	6ca2                	ld	s9,8(sp)
    800039ec:	6125                	addi	sp,sp,96
    800039ee:	8082                	ret
    brelse(bp);
    800039f0:	854a                	mv	a0,s2
    800039f2:	00000097          	auipc	ra,0x0
    800039f6:	dc4080e7          	jalr	-572(ra) # 800037b6 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800039fa:	015c87bb          	addw	a5,s9,s5
    800039fe:	00078a9b          	sext.w	s5,a5
    80003a02:	004b2703          	lw	a4,4(s6)
    80003a06:	06eaf363          	bgeu	s5,a4,80003a6c <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003a0a:	41fad79b          	sraiw	a5,s5,0x1f
    80003a0e:	0137d79b          	srliw	a5,a5,0x13
    80003a12:	015787bb          	addw	a5,a5,s5
    80003a16:	40d7d79b          	sraiw	a5,a5,0xd
    80003a1a:	01cb2583          	lw	a1,28(s6)
    80003a1e:	9dbd                	addw	a1,a1,a5
    80003a20:	855e                	mv	a0,s7
    80003a22:	00000097          	auipc	ra,0x0
    80003a26:	c64080e7          	jalr	-924(ra) # 80003686 <bread>
    80003a2a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a2c:	004b2503          	lw	a0,4(s6)
    80003a30:	000a849b          	sext.w	s1,s5
    80003a34:	8662                	mv	a2,s8
    80003a36:	faa4fde3          	bgeu	s1,a0,800039f0 <balloc+0xa8>
      m = 1 << (bi % 8);
    80003a3a:	41f6579b          	sraiw	a5,a2,0x1f
    80003a3e:	01d7d69b          	srliw	a3,a5,0x1d
    80003a42:	00c6873b          	addw	a4,a3,a2
    80003a46:	00777793          	andi	a5,a4,7
    80003a4a:	9f95                	subw	a5,a5,a3
    80003a4c:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003a50:	4037571b          	sraiw	a4,a4,0x3
    80003a54:	00e906b3          	add	a3,s2,a4
    80003a58:	0586c683          	lbu	a3,88(a3)
    80003a5c:	00d7f5b3          	and	a1,a5,a3
    80003a60:	d195                	beqz	a1,80003984 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a62:	2605                	addiw	a2,a2,1
    80003a64:	2485                	addiw	s1,s1,1
    80003a66:	fd4618e3          	bne	a2,s4,80003a36 <balloc+0xee>
    80003a6a:	b759                	j	800039f0 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003a6c:	00005517          	auipc	a0,0x5
    80003a70:	c3450513          	addi	a0,a0,-972 # 800086a0 <syscallnum+0xc0>
    80003a74:	ffffd097          	auipc	ra,0xffffd
    80003a78:	b1a080e7          	jalr	-1254(ra) # 8000058e <printf>
  return 0;
    80003a7c:	4481                	li	s1,0
    80003a7e:	bf99                	j	800039d4 <balloc+0x8c>

0000000080003a80 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003a80:	7179                	addi	sp,sp,-48
    80003a82:	f406                	sd	ra,40(sp)
    80003a84:	f022                	sd	s0,32(sp)
    80003a86:	ec26                	sd	s1,24(sp)
    80003a88:	e84a                	sd	s2,16(sp)
    80003a8a:	e44e                	sd	s3,8(sp)
    80003a8c:	e052                	sd	s4,0(sp)
    80003a8e:	1800                	addi	s0,sp,48
    80003a90:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003a92:	47ad                	li	a5,11
    80003a94:	02b7e763          	bltu	a5,a1,80003ac2 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003a98:	02059493          	slli	s1,a1,0x20
    80003a9c:	9081                	srli	s1,s1,0x20
    80003a9e:	048a                	slli	s1,s1,0x2
    80003aa0:	94aa                	add	s1,s1,a0
    80003aa2:	0504a903          	lw	s2,80(s1)
    80003aa6:	06091e63          	bnez	s2,80003b22 <bmap+0xa2>
      addr = balloc(ip->dev);
    80003aaa:	4108                	lw	a0,0(a0)
    80003aac:	00000097          	auipc	ra,0x0
    80003ab0:	e9c080e7          	jalr	-356(ra) # 80003948 <balloc>
    80003ab4:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003ab8:	06090563          	beqz	s2,80003b22 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003abc:	0524a823          	sw	s2,80(s1)
    80003ac0:	a08d                	j	80003b22 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003ac2:	ff45849b          	addiw	s1,a1,-12
    80003ac6:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003aca:	0ff00793          	li	a5,255
    80003ace:	08e7e563          	bltu	a5,a4,80003b58 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003ad2:	08052903          	lw	s2,128(a0)
    80003ad6:	00091d63          	bnez	s2,80003af0 <bmap+0x70>
      addr = balloc(ip->dev);
    80003ada:	4108                	lw	a0,0(a0)
    80003adc:	00000097          	auipc	ra,0x0
    80003ae0:	e6c080e7          	jalr	-404(ra) # 80003948 <balloc>
    80003ae4:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003ae8:	02090d63          	beqz	s2,80003b22 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003aec:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003af0:	85ca                	mv	a1,s2
    80003af2:	0009a503          	lw	a0,0(s3)
    80003af6:	00000097          	auipc	ra,0x0
    80003afa:	b90080e7          	jalr	-1136(ra) # 80003686 <bread>
    80003afe:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003b00:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003b04:	02049593          	slli	a1,s1,0x20
    80003b08:	9181                	srli	a1,a1,0x20
    80003b0a:	058a                	slli	a1,a1,0x2
    80003b0c:	00b784b3          	add	s1,a5,a1
    80003b10:	0004a903          	lw	s2,0(s1)
    80003b14:	02090063          	beqz	s2,80003b34 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003b18:	8552                	mv	a0,s4
    80003b1a:	00000097          	auipc	ra,0x0
    80003b1e:	c9c080e7          	jalr	-868(ra) # 800037b6 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003b22:	854a                	mv	a0,s2
    80003b24:	70a2                	ld	ra,40(sp)
    80003b26:	7402                	ld	s0,32(sp)
    80003b28:	64e2                	ld	s1,24(sp)
    80003b2a:	6942                	ld	s2,16(sp)
    80003b2c:	69a2                	ld	s3,8(sp)
    80003b2e:	6a02                	ld	s4,0(sp)
    80003b30:	6145                	addi	sp,sp,48
    80003b32:	8082                	ret
      addr = balloc(ip->dev);
    80003b34:	0009a503          	lw	a0,0(s3)
    80003b38:	00000097          	auipc	ra,0x0
    80003b3c:	e10080e7          	jalr	-496(ra) # 80003948 <balloc>
    80003b40:	0005091b          	sext.w	s2,a0
      if(addr){
    80003b44:	fc090ae3          	beqz	s2,80003b18 <bmap+0x98>
        a[bn] = addr;
    80003b48:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003b4c:	8552                	mv	a0,s4
    80003b4e:	00001097          	auipc	ra,0x1
    80003b52:	eec080e7          	jalr	-276(ra) # 80004a3a <log_write>
    80003b56:	b7c9                	j	80003b18 <bmap+0x98>
  panic("bmap: out of range");
    80003b58:	00005517          	auipc	a0,0x5
    80003b5c:	b6050513          	addi	a0,a0,-1184 # 800086b8 <syscallnum+0xd8>
    80003b60:	ffffd097          	auipc	ra,0xffffd
    80003b64:	9e4080e7          	jalr	-1564(ra) # 80000544 <panic>

0000000080003b68 <iget>:
{
    80003b68:	7179                	addi	sp,sp,-48
    80003b6a:	f406                	sd	ra,40(sp)
    80003b6c:	f022                	sd	s0,32(sp)
    80003b6e:	ec26                	sd	s1,24(sp)
    80003b70:	e84a                	sd	s2,16(sp)
    80003b72:	e44e                	sd	s3,8(sp)
    80003b74:	e052                	sd	s4,0(sp)
    80003b76:	1800                	addi	s0,sp,48
    80003b78:	89aa                	mv	s3,a0
    80003b7a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003b7c:	0001d517          	auipc	a0,0x1d
    80003b80:	53c50513          	addi	a0,a0,1340 # 800210b8 <itable>
    80003b84:	ffffd097          	auipc	ra,0xffffd
    80003b88:	066080e7          	jalr	102(ra) # 80000bea <acquire>
  empty = 0;
    80003b8c:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003b8e:	0001d497          	auipc	s1,0x1d
    80003b92:	54248493          	addi	s1,s1,1346 # 800210d0 <itable+0x18>
    80003b96:	0001f697          	auipc	a3,0x1f
    80003b9a:	fca68693          	addi	a3,a3,-54 # 80022b60 <log>
    80003b9e:	a039                	j	80003bac <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003ba0:	02090b63          	beqz	s2,80003bd6 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003ba4:	08848493          	addi	s1,s1,136
    80003ba8:	02d48a63          	beq	s1,a3,80003bdc <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003bac:	449c                	lw	a5,8(s1)
    80003bae:	fef059e3          	blez	a5,80003ba0 <iget+0x38>
    80003bb2:	4098                	lw	a4,0(s1)
    80003bb4:	ff3716e3          	bne	a4,s3,80003ba0 <iget+0x38>
    80003bb8:	40d8                	lw	a4,4(s1)
    80003bba:	ff4713e3          	bne	a4,s4,80003ba0 <iget+0x38>
      ip->ref++;
    80003bbe:	2785                	addiw	a5,a5,1
    80003bc0:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003bc2:	0001d517          	auipc	a0,0x1d
    80003bc6:	4f650513          	addi	a0,a0,1270 # 800210b8 <itable>
    80003bca:	ffffd097          	auipc	ra,0xffffd
    80003bce:	0d4080e7          	jalr	212(ra) # 80000c9e <release>
      return ip;
    80003bd2:	8926                	mv	s2,s1
    80003bd4:	a03d                	j	80003c02 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003bd6:	f7f9                	bnez	a5,80003ba4 <iget+0x3c>
    80003bd8:	8926                	mv	s2,s1
    80003bda:	b7e9                	j	80003ba4 <iget+0x3c>
  if(empty == 0)
    80003bdc:	02090c63          	beqz	s2,80003c14 <iget+0xac>
  ip->dev = dev;
    80003be0:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003be4:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003be8:	4785                	li	a5,1
    80003bea:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003bee:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003bf2:	0001d517          	auipc	a0,0x1d
    80003bf6:	4c650513          	addi	a0,a0,1222 # 800210b8 <itable>
    80003bfa:	ffffd097          	auipc	ra,0xffffd
    80003bfe:	0a4080e7          	jalr	164(ra) # 80000c9e <release>
}
    80003c02:	854a                	mv	a0,s2
    80003c04:	70a2                	ld	ra,40(sp)
    80003c06:	7402                	ld	s0,32(sp)
    80003c08:	64e2                	ld	s1,24(sp)
    80003c0a:	6942                	ld	s2,16(sp)
    80003c0c:	69a2                	ld	s3,8(sp)
    80003c0e:	6a02                	ld	s4,0(sp)
    80003c10:	6145                	addi	sp,sp,48
    80003c12:	8082                	ret
    panic("iget: no inodes");
    80003c14:	00005517          	auipc	a0,0x5
    80003c18:	abc50513          	addi	a0,a0,-1348 # 800086d0 <syscallnum+0xf0>
    80003c1c:	ffffd097          	auipc	ra,0xffffd
    80003c20:	928080e7          	jalr	-1752(ra) # 80000544 <panic>

0000000080003c24 <fsinit>:
fsinit(int dev) {
    80003c24:	7179                	addi	sp,sp,-48
    80003c26:	f406                	sd	ra,40(sp)
    80003c28:	f022                	sd	s0,32(sp)
    80003c2a:	ec26                	sd	s1,24(sp)
    80003c2c:	e84a                	sd	s2,16(sp)
    80003c2e:	e44e                	sd	s3,8(sp)
    80003c30:	1800                	addi	s0,sp,48
    80003c32:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003c34:	4585                	li	a1,1
    80003c36:	00000097          	auipc	ra,0x0
    80003c3a:	a50080e7          	jalr	-1456(ra) # 80003686 <bread>
    80003c3e:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003c40:	0001d997          	auipc	s3,0x1d
    80003c44:	45898993          	addi	s3,s3,1112 # 80021098 <sb>
    80003c48:	02000613          	li	a2,32
    80003c4c:	05850593          	addi	a1,a0,88
    80003c50:	854e                	mv	a0,s3
    80003c52:	ffffd097          	auipc	ra,0xffffd
    80003c56:	0f4080e7          	jalr	244(ra) # 80000d46 <memmove>
  brelse(bp);
    80003c5a:	8526                	mv	a0,s1
    80003c5c:	00000097          	auipc	ra,0x0
    80003c60:	b5a080e7          	jalr	-1190(ra) # 800037b6 <brelse>
  if(sb.magic != FSMAGIC)
    80003c64:	0009a703          	lw	a4,0(s3)
    80003c68:	102037b7          	lui	a5,0x10203
    80003c6c:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003c70:	02f71263          	bne	a4,a5,80003c94 <fsinit+0x70>
  initlog(dev, &sb);
    80003c74:	0001d597          	auipc	a1,0x1d
    80003c78:	42458593          	addi	a1,a1,1060 # 80021098 <sb>
    80003c7c:	854a                	mv	a0,s2
    80003c7e:	00001097          	auipc	ra,0x1
    80003c82:	b40080e7          	jalr	-1216(ra) # 800047be <initlog>
}
    80003c86:	70a2                	ld	ra,40(sp)
    80003c88:	7402                	ld	s0,32(sp)
    80003c8a:	64e2                	ld	s1,24(sp)
    80003c8c:	6942                	ld	s2,16(sp)
    80003c8e:	69a2                	ld	s3,8(sp)
    80003c90:	6145                	addi	sp,sp,48
    80003c92:	8082                	ret
    panic("invalid file system");
    80003c94:	00005517          	auipc	a0,0x5
    80003c98:	a4c50513          	addi	a0,a0,-1460 # 800086e0 <syscallnum+0x100>
    80003c9c:	ffffd097          	auipc	ra,0xffffd
    80003ca0:	8a8080e7          	jalr	-1880(ra) # 80000544 <panic>

0000000080003ca4 <iinit>:
{
    80003ca4:	7179                	addi	sp,sp,-48
    80003ca6:	f406                	sd	ra,40(sp)
    80003ca8:	f022                	sd	s0,32(sp)
    80003caa:	ec26                	sd	s1,24(sp)
    80003cac:	e84a                	sd	s2,16(sp)
    80003cae:	e44e                	sd	s3,8(sp)
    80003cb0:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003cb2:	00005597          	auipc	a1,0x5
    80003cb6:	a4658593          	addi	a1,a1,-1466 # 800086f8 <syscallnum+0x118>
    80003cba:	0001d517          	auipc	a0,0x1d
    80003cbe:	3fe50513          	addi	a0,a0,1022 # 800210b8 <itable>
    80003cc2:	ffffd097          	auipc	ra,0xffffd
    80003cc6:	e98080e7          	jalr	-360(ra) # 80000b5a <initlock>
  for(i = 0; i < NINODE; i++) {
    80003cca:	0001d497          	auipc	s1,0x1d
    80003cce:	41648493          	addi	s1,s1,1046 # 800210e0 <itable+0x28>
    80003cd2:	0001f997          	auipc	s3,0x1f
    80003cd6:	e9e98993          	addi	s3,s3,-354 # 80022b70 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003cda:	00005917          	auipc	s2,0x5
    80003cde:	a2690913          	addi	s2,s2,-1498 # 80008700 <syscallnum+0x120>
    80003ce2:	85ca                	mv	a1,s2
    80003ce4:	8526                	mv	a0,s1
    80003ce6:	00001097          	auipc	ra,0x1
    80003cea:	e3a080e7          	jalr	-454(ra) # 80004b20 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003cee:	08848493          	addi	s1,s1,136
    80003cf2:	ff3498e3          	bne	s1,s3,80003ce2 <iinit+0x3e>
}
    80003cf6:	70a2                	ld	ra,40(sp)
    80003cf8:	7402                	ld	s0,32(sp)
    80003cfa:	64e2                	ld	s1,24(sp)
    80003cfc:	6942                	ld	s2,16(sp)
    80003cfe:	69a2                	ld	s3,8(sp)
    80003d00:	6145                	addi	sp,sp,48
    80003d02:	8082                	ret

0000000080003d04 <ialloc>:
{
    80003d04:	715d                	addi	sp,sp,-80
    80003d06:	e486                	sd	ra,72(sp)
    80003d08:	e0a2                	sd	s0,64(sp)
    80003d0a:	fc26                	sd	s1,56(sp)
    80003d0c:	f84a                	sd	s2,48(sp)
    80003d0e:	f44e                	sd	s3,40(sp)
    80003d10:	f052                	sd	s4,32(sp)
    80003d12:	ec56                	sd	s5,24(sp)
    80003d14:	e85a                	sd	s6,16(sp)
    80003d16:	e45e                	sd	s7,8(sp)
    80003d18:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003d1a:	0001d717          	auipc	a4,0x1d
    80003d1e:	38a72703          	lw	a4,906(a4) # 800210a4 <sb+0xc>
    80003d22:	4785                	li	a5,1
    80003d24:	04e7fa63          	bgeu	a5,a4,80003d78 <ialloc+0x74>
    80003d28:	8aaa                	mv	s5,a0
    80003d2a:	8bae                	mv	s7,a1
    80003d2c:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003d2e:	0001da17          	auipc	s4,0x1d
    80003d32:	36aa0a13          	addi	s4,s4,874 # 80021098 <sb>
    80003d36:	00048b1b          	sext.w	s6,s1
    80003d3a:	0044d593          	srli	a1,s1,0x4
    80003d3e:	018a2783          	lw	a5,24(s4)
    80003d42:	9dbd                	addw	a1,a1,a5
    80003d44:	8556                	mv	a0,s5
    80003d46:	00000097          	auipc	ra,0x0
    80003d4a:	940080e7          	jalr	-1728(ra) # 80003686 <bread>
    80003d4e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003d50:	05850993          	addi	s3,a0,88
    80003d54:	00f4f793          	andi	a5,s1,15
    80003d58:	079a                	slli	a5,a5,0x6
    80003d5a:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003d5c:	00099783          	lh	a5,0(s3)
    80003d60:	c3a1                	beqz	a5,80003da0 <ialloc+0x9c>
    brelse(bp);
    80003d62:	00000097          	auipc	ra,0x0
    80003d66:	a54080e7          	jalr	-1452(ra) # 800037b6 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003d6a:	0485                	addi	s1,s1,1
    80003d6c:	00ca2703          	lw	a4,12(s4)
    80003d70:	0004879b          	sext.w	a5,s1
    80003d74:	fce7e1e3          	bltu	a5,a4,80003d36 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003d78:	00005517          	auipc	a0,0x5
    80003d7c:	99050513          	addi	a0,a0,-1648 # 80008708 <syscallnum+0x128>
    80003d80:	ffffd097          	auipc	ra,0xffffd
    80003d84:	80e080e7          	jalr	-2034(ra) # 8000058e <printf>
  return 0;
    80003d88:	4501                	li	a0,0
}
    80003d8a:	60a6                	ld	ra,72(sp)
    80003d8c:	6406                	ld	s0,64(sp)
    80003d8e:	74e2                	ld	s1,56(sp)
    80003d90:	7942                	ld	s2,48(sp)
    80003d92:	79a2                	ld	s3,40(sp)
    80003d94:	7a02                	ld	s4,32(sp)
    80003d96:	6ae2                	ld	s5,24(sp)
    80003d98:	6b42                	ld	s6,16(sp)
    80003d9a:	6ba2                	ld	s7,8(sp)
    80003d9c:	6161                	addi	sp,sp,80
    80003d9e:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003da0:	04000613          	li	a2,64
    80003da4:	4581                	li	a1,0
    80003da6:	854e                	mv	a0,s3
    80003da8:	ffffd097          	auipc	ra,0xffffd
    80003dac:	f3e080e7          	jalr	-194(ra) # 80000ce6 <memset>
      dip->type = type;
    80003db0:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003db4:	854a                	mv	a0,s2
    80003db6:	00001097          	auipc	ra,0x1
    80003dba:	c84080e7          	jalr	-892(ra) # 80004a3a <log_write>
      brelse(bp);
    80003dbe:	854a                	mv	a0,s2
    80003dc0:	00000097          	auipc	ra,0x0
    80003dc4:	9f6080e7          	jalr	-1546(ra) # 800037b6 <brelse>
      return iget(dev, inum);
    80003dc8:	85da                	mv	a1,s6
    80003dca:	8556                	mv	a0,s5
    80003dcc:	00000097          	auipc	ra,0x0
    80003dd0:	d9c080e7          	jalr	-612(ra) # 80003b68 <iget>
    80003dd4:	bf5d                	j	80003d8a <ialloc+0x86>

0000000080003dd6 <iupdate>:
{
    80003dd6:	1101                	addi	sp,sp,-32
    80003dd8:	ec06                	sd	ra,24(sp)
    80003dda:	e822                	sd	s0,16(sp)
    80003ddc:	e426                	sd	s1,8(sp)
    80003dde:	e04a                	sd	s2,0(sp)
    80003de0:	1000                	addi	s0,sp,32
    80003de2:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003de4:	415c                	lw	a5,4(a0)
    80003de6:	0047d79b          	srliw	a5,a5,0x4
    80003dea:	0001d597          	auipc	a1,0x1d
    80003dee:	2c65a583          	lw	a1,710(a1) # 800210b0 <sb+0x18>
    80003df2:	9dbd                	addw	a1,a1,a5
    80003df4:	4108                	lw	a0,0(a0)
    80003df6:	00000097          	auipc	ra,0x0
    80003dfa:	890080e7          	jalr	-1904(ra) # 80003686 <bread>
    80003dfe:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003e00:	05850793          	addi	a5,a0,88
    80003e04:	40c8                	lw	a0,4(s1)
    80003e06:	893d                	andi	a0,a0,15
    80003e08:	051a                	slli	a0,a0,0x6
    80003e0a:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003e0c:	04449703          	lh	a4,68(s1)
    80003e10:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003e14:	04649703          	lh	a4,70(s1)
    80003e18:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003e1c:	04849703          	lh	a4,72(s1)
    80003e20:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003e24:	04a49703          	lh	a4,74(s1)
    80003e28:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003e2c:	44f8                	lw	a4,76(s1)
    80003e2e:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003e30:	03400613          	li	a2,52
    80003e34:	05048593          	addi	a1,s1,80
    80003e38:	0531                	addi	a0,a0,12
    80003e3a:	ffffd097          	auipc	ra,0xffffd
    80003e3e:	f0c080e7          	jalr	-244(ra) # 80000d46 <memmove>
  log_write(bp);
    80003e42:	854a                	mv	a0,s2
    80003e44:	00001097          	auipc	ra,0x1
    80003e48:	bf6080e7          	jalr	-1034(ra) # 80004a3a <log_write>
  brelse(bp);
    80003e4c:	854a                	mv	a0,s2
    80003e4e:	00000097          	auipc	ra,0x0
    80003e52:	968080e7          	jalr	-1688(ra) # 800037b6 <brelse>
}
    80003e56:	60e2                	ld	ra,24(sp)
    80003e58:	6442                	ld	s0,16(sp)
    80003e5a:	64a2                	ld	s1,8(sp)
    80003e5c:	6902                	ld	s2,0(sp)
    80003e5e:	6105                	addi	sp,sp,32
    80003e60:	8082                	ret

0000000080003e62 <idup>:
{
    80003e62:	1101                	addi	sp,sp,-32
    80003e64:	ec06                	sd	ra,24(sp)
    80003e66:	e822                	sd	s0,16(sp)
    80003e68:	e426                	sd	s1,8(sp)
    80003e6a:	1000                	addi	s0,sp,32
    80003e6c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003e6e:	0001d517          	auipc	a0,0x1d
    80003e72:	24a50513          	addi	a0,a0,586 # 800210b8 <itable>
    80003e76:	ffffd097          	auipc	ra,0xffffd
    80003e7a:	d74080e7          	jalr	-652(ra) # 80000bea <acquire>
  ip->ref++;
    80003e7e:	449c                	lw	a5,8(s1)
    80003e80:	2785                	addiw	a5,a5,1
    80003e82:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003e84:	0001d517          	auipc	a0,0x1d
    80003e88:	23450513          	addi	a0,a0,564 # 800210b8 <itable>
    80003e8c:	ffffd097          	auipc	ra,0xffffd
    80003e90:	e12080e7          	jalr	-494(ra) # 80000c9e <release>
}
    80003e94:	8526                	mv	a0,s1
    80003e96:	60e2                	ld	ra,24(sp)
    80003e98:	6442                	ld	s0,16(sp)
    80003e9a:	64a2                	ld	s1,8(sp)
    80003e9c:	6105                	addi	sp,sp,32
    80003e9e:	8082                	ret

0000000080003ea0 <ilock>:
{
    80003ea0:	1101                	addi	sp,sp,-32
    80003ea2:	ec06                	sd	ra,24(sp)
    80003ea4:	e822                	sd	s0,16(sp)
    80003ea6:	e426                	sd	s1,8(sp)
    80003ea8:	e04a                	sd	s2,0(sp)
    80003eaa:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003eac:	c115                	beqz	a0,80003ed0 <ilock+0x30>
    80003eae:	84aa                	mv	s1,a0
    80003eb0:	451c                	lw	a5,8(a0)
    80003eb2:	00f05f63          	blez	a5,80003ed0 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003eb6:	0541                	addi	a0,a0,16
    80003eb8:	00001097          	auipc	ra,0x1
    80003ebc:	ca2080e7          	jalr	-862(ra) # 80004b5a <acquiresleep>
  if(ip->valid == 0){
    80003ec0:	40bc                	lw	a5,64(s1)
    80003ec2:	cf99                	beqz	a5,80003ee0 <ilock+0x40>
}
    80003ec4:	60e2                	ld	ra,24(sp)
    80003ec6:	6442                	ld	s0,16(sp)
    80003ec8:	64a2                	ld	s1,8(sp)
    80003eca:	6902                	ld	s2,0(sp)
    80003ecc:	6105                	addi	sp,sp,32
    80003ece:	8082                	ret
    panic("ilock");
    80003ed0:	00005517          	auipc	a0,0x5
    80003ed4:	85050513          	addi	a0,a0,-1968 # 80008720 <syscallnum+0x140>
    80003ed8:	ffffc097          	auipc	ra,0xffffc
    80003edc:	66c080e7          	jalr	1644(ra) # 80000544 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003ee0:	40dc                	lw	a5,4(s1)
    80003ee2:	0047d79b          	srliw	a5,a5,0x4
    80003ee6:	0001d597          	auipc	a1,0x1d
    80003eea:	1ca5a583          	lw	a1,458(a1) # 800210b0 <sb+0x18>
    80003eee:	9dbd                	addw	a1,a1,a5
    80003ef0:	4088                	lw	a0,0(s1)
    80003ef2:	fffff097          	auipc	ra,0xfffff
    80003ef6:	794080e7          	jalr	1940(ra) # 80003686 <bread>
    80003efa:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003efc:	05850593          	addi	a1,a0,88
    80003f00:	40dc                	lw	a5,4(s1)
    80003f02:	8bbd                	andi	a5,a5,15
    80003f04:	079a                	slli	a5,a5,0x6
    80003f06:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003f08:	00059783          	lh	a5,0(a1)
    80003f0c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003f10:	00259783          	lh	a5,2(a1)
    80003f14:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003f18:	00459783          	lh	a5,4(a1)
    80003f1c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003f20:	00659783          	lh	a5,6(a1)
    80003f24:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003f28:	459c                	lw	a5,8(a1)
    80003f2a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003f2c:	03400613          	li	a2,52
    80003f30:	05b1                	addi	a1,a1,12
    80003f32:	05048513          	addi	a0,s1,80
    80003f36:	ffffd097          	auipc	ra,0xffffd
    80003f3a:	e10080e7          	jalr	-496(ra) # 80000d46 <memmove>
    brelse(bp);
    80003f3e:	854a                	mv	a0,s2
    80003f40:	00000097          	auipc	ra,0x0
    80003f44:	876080e7          	jalr	-1930(ra) # 800037b6 <brelse>
    ip->valid = 1;
    80003f48:	4785                	li	a5,1
    80003f4a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003f4c:	04449783          	lh	a5,68(s1)
    80003f50:	fbb5                	bnez	a5,80003ec4 <ilock+0x24>
      panic("ilock: no type");
    80003f52:	00004517          	auipc	a0,0x4
    80003f56:	7d650513          	addi	a0,a0,2006 # 80008728 <syscallnum+0x148>
    80003f5a:	ffffc097          	auipc	ra,0xffffc
    80003f5e:	5ea080e7          	jalr	1514(ra) # 80000544 <panic>

0000000080003f62 <iunlock>:
{
    80003f62:	1101                	addi	sp,sp,-32
    80003f64:	ec06                	sd	ra,24(sp)
    80003f66:	e822                	sd	s0,16(sp)
    80003f68:	e426                	sd	s1,8(sp)
    80003f6a:	e04a                	sd	s2,0(sp)
    80003f6c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003f6e:	c905                	beqz	a0,80003f9e <iunlock+0x3c>
    80003f70:	84aa                	mv	s1,a0
    80003f72:	01050913          	addi	s2,a0,16
    80003f76:	854a                	mv	a0,s2
    80003f78:	00001097          	auipc	ra,0x1
    80003f7c:	c7c080e7          	jalr	-900(ra) # 80004bf4 <holdingsleep>
    80003f80:	cd19                	beqz	a0,80003f9e <iunlock+0x3c>
    80003f82:	449c                	lw	a5,8(s1)
    80003f84:	00f05d63          	blez	a5,80003f9e <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003f88:	854a                	mv	a0,s2
    80003f8a:	00001097          	auipc	ra,0x1
    80003f8e:	c26080e7          	jalr	-986(ra) # 80004bb0 <releasesleep>
}
    80003f92:	60e2                	ld	ra,24(sp)
    80003f94:	6442                	ld	s0,16(sp)
    80003f96:	64a2                	ld	s1,8(sp)
    80003f98:	6902                	ld	s2,0(sp)
    80003f9a:	6105                	addi	sp,sp,32
    80003f9c:	8082                	ret
    panic("iunlock");
    80003f9e:	00004517          	auipc	a0,0x4
    80003fa2:	79a50513          	addi	a0,a0,1946 # 80008738 <syscallnum+0x158>
    80003fa6:	ffffc097          	auipc	ra,0xffffc
    80003faa:	59e080e7          	jalr	1438(ra) # 80000544 <panic>

0000000080003fae <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003fae:	7179                	addi	sp,sp,-48
    80003fb0:	f406                	sd	ra,40(sp)
    80003fb2:	f022                	sd	s0,32(sp)
    80003fb4:	ec26                	sd	s1,24(sp)
    80003fb6:	e84a                	sd	s2,16(sp)
    80003fb8:	e44e                	sd	s3,8(sp)
    80003fba:	e052                	sd	s4,0(sp)
    80003fbc:	1800                	addi	s0,sp,48
    80003fbe:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003fc0:	05050493          	addi	s1,a0,80
    80003fc4:	08050913          	addi	s2,a0,128
    80003fc8:	a021                	j	80003fd0 <itrunc+0x22>
    80003fca:	0491                	addi	s1,s1,4
    80003fcc:	01248d63          	beq	s1,s2,80003fe6 <itrunc+0x38>
    if(ip->addrs[i]){
    80003fd0:	408c                	lw	a1,0(s1)
    80003fd2:	dde5                	beqz	a1,80003fca <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003fd4:	0009a503          	lw	a0,0(s3)
    80003fd8:	00000097          	auipc	ra,0x0
    80003fdc:	8f4080e7          	jalr	-1804(ra) # 800038cc <bfree>
      ip->addrs[i] = 0;
    80003fe0:	0004a023          	sw	zero,0(s1)
    80003fe4:	b7dd                	j	80003fca <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003fe6:	0809a583          	lw	a1,128(s3)
    80003fea:	e185                	bnez	a1,8000400a <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003fec:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003ff0:	854e                	mv	a0,s3
    80003ff2:	00000097          	auipc	ra,0x0
    80003ff6:	de4080e7          	jalr	-540(ra) # 80003dd6 <iupdate>
}
    80003ffa:	70a2                	ld	ra,40(sp)
    80003ffc:	7402                	ld	s0,32(sp)
    80003ffe:	64e2                	ld	s1,24(sp)
    80004000:	6942                	ld	s2,16(sp)
    80004002:	69a2                	ld	s3,8(sp)
    80004004:	6a02                	ld	s4,0(sp)
    80004006:	6145                	addi	sp,sp,48
    80004008:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000400a:	0009a503          	lw	a0,0(s3)
    8000400e:	fffff097          	auipc	ra,0xfffff
    80004012:	678080e7          	jalr	1656(ra) # 80003686 <bread>
    80004016:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80004018:	05850493          	addi	s1,a0,88
    8000401c:	45850913          	addi	s2,a0,1112
    80004020:	a811                	j	80004034 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80004022:	0009a503          	lw	a0,0(s3)
    80004026:	00000097          	auipc	ra,0x0
    8000402a:	8a6080e7          	jalr	-1882(ra) # 800038cc <bfree>
    for(j = 0; j < NINDIRECT; j++){
    8000402e:	0491                	addi	s1,s1,4
    80004030:	01248563          	beq	s1,s2,8000403a <itrunc+0x8c>
      if(a[j])
    80004034:	408c                	lw	a1,0(s1)
    80004036:	dde5                	beqz	a1,8000402e <itrunc+0x80>
    80004038:	b7ed                	j	80004022 <itrunc+0x74>
    brelse(bp);
    8000403a:	8552                	mv	a0,s4
    8000403c:	fffff097          	auipc	ra,0xfffff
    80004040:	77a080e7          	jalr	1914(ra) # 800037b6 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80004044:	0809a583          	lw	a1,128(s3)
    80004048:	0009a503          	lw	a0,0(s3)
    8000404c:	00000097          	auipc	ra,0x0
    80004050:	880080e7          	jalr	-1920(ra) # 800038cc <bfree>
    ip->addrs[NDIRECT] = 0;
    80004054:	0809a023          	sw	zero,128(s3)
    80004058:	bf51                	j	80003fec <itrunc+0x3e>

000000008000405a <iput>:
{
    8000405a:	1101                	addi	sp,sp,-32
    8000405c:	ec06                	sd	ra,24(sp)
    8000405e:	e822                	sd	s0,16(sp)
    80004060:	e426                	sd	s1,8(sp)
    80004062:	e04a                	sd	s2,0(sp)
    80004064:	1000                	addi	s0,sp,32
    80004066:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004068:	0001d517          	auipc	a0,0x1d
    8000406c:	05050513          	addi	a0,a0,80 # 800210b8 <itable>
    80004070:	ffffd097          	auipc	ra,0xffffd
    80004074:	b7a080e7          	jalr	-1158(ra) # 80000bea <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004078:	4498                	lw	a4,8(s1)
    8000407a:	4785                	li	a5,1
    8000407c:	02f70363          	beq	a4,a5,800040a2 <iput+0x48>
  ip->ref--;
    80004080:	449c                	lw	a5,8(s1)
    80004082:	37fd                	addiw	a5,a5,-1
    80004084:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004086:	0001d517          	auipc	a0,0x1d
    8000408a:	03250513          	addi	a0,a0,50 # 800210b8 <itable>
    8000408e:	ffffd097          	auipc	ra,0xffffd
    80004092:	c10080e7          	jalr	-1008(ra) # 80000c9e <release>
}
    80004096:	60e2                	ld	ra,24(sp)
    80004098:	6442                	ld	s0,16(sp)
    8000409a:	64a2                	ld	s1,8(sp)
    8000409c:	6902                	ld	s2,0(sp)
    8000409e:	6105                	addi	sp,sp,32
    800040a0:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800040a2:	40bc                	lw	a5,64(s1)
    800040a4:	dff1                	beqz	a5,80004080 <iput+0x26>
    800040a6:	04a49783          	lh	a5,74(s1)
    800040aa:	fbf9                	bnez	a5,80004080 <iput+0x26>
    acquiresleep(&ip->lock);
    800040ac:	01048913          	addi	s2,s1,16
    800040b0:	854a                	mv	a0,s2
    800040b2:	00001097          	auipc	ra,0x1
    800040b6:	aa8080e7          	jalr	-1368(ra) # 80004b5a <acquiresleep>
    release(&itable.lock);
    800040ba:	0001d517          	auipc	a0,0x1d
    800040be:	ffe50513          	addi	a0,a0,-2 # 800210b8 <itable>
    800040c2:	ffffd097          	auipc	ra,0xffffd
    800040c6:	bdc080e7          	jalr	-1060(ra) # 80000c9e <release>
    itrunc(ip);
    800040ca:	8526                	mv	a0,s1
    800040cc:	00000097          	auipc	ra,0x0
    800040d0:	ee2080e7          	jalr	-286(ra) # 80003fae <itrunc>
    ip->type = 0;
    800040d4:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800040d8:	8526                	mv	a0,s1
    800040da:	00000097          	auipc	ra,0x0
    800040de:	cfc080e7          	jalr	-772(ra) # 80003dd6 <iupdate>
    ip->valid = 0;
    800040e2:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800040e6:	854a                	mv	a0,s2
    800040e8:	00001097          	auipc	ra,0x1
    800040ec:	ac8080e7          	jalr	-1336(ra) # 80004bb0 <releasesleep>
    acquire(&itable.lock);
    800040f0:	0001d517          	auipc	a0,0x1d
    800040f4:	fc850513          	addi	a0,a0,-56 # 800210b8 <itable>
    800040f8:	ffffd097          	auipc	ra,0xffffd
    800040fc:	af2080e7          	jalr	-1294(ra) # 80000bea <acquire>
    80004100:	b741                	j	80004080 <iput+0x26>

0000000080004102 <iunlockput>:
{
    80004102:	1101                	addi	sp,sp,-32
    80004104:	ec06                	sd	ra,24(sp)
    80004106:	e822                	sd	s0,16(sp)
    80004108:	e426                	sd	s1,8(sp)
    8000410a:	1000                	addi	s0,sp,32
    8000410c:	84aa                	mv	s1,a0
  iunlock(ip);
    8000410e:	00000097          	auipc	ra,0x0
    80004112:	e54080e7          	jalr	-428(ra) # 80003f62 <iunlock>
  iput(ip);
    80004116:	8526                	mv	a0,s1
    80004118:	00000097          	auipc	ra,0x0
    8000411c:	f42080e7          	jalr	-190(ra) # 8000405a <iput>
}
    80004120:	60e2                	ld	ra,24(sp)
    80004122:	6442                	ld	s0,16(sp)
    80004124:	64a2                	ld	s1,8(sp)
    80004126:	6105                	addi	sp,sp,32
    80004128:	8082                	ret

000000008000412a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000412a:	1141                	addi	sp,sp,-16
    8000412c:	e422                	sd	s0,8(sp)
    8000412e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004130:	411c                	lw	a5,0(a0)
    80004132:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004134:	415c                	lw	a5,4(a0)
    80004136:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004138:	04451783          	lh	a5,68(a0)
    8000413c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004140:	04a51783          	lh	a5,74(a0)
    80004144:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004148:	04c56783          	lwu	a5,76(a0)
    8000414c:	e99c                	sd	a5,16(a1)
}
    8000414e:	6422                	ld	s0,8(sp)
    80004150:	0141                	addi	sp,sp,16
    80004152:	8082                	ret

0000000080004154 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004154:	457c                	lw	a5,76(a0)
    80004156:	0ed7e963          	bltu	a5,a3,80004248 <readi+0xf4>
{
    8000415a:	7159                	addi	sp,sp,-112
    8000415c:	f486                	sd	ra,104(sp)
    8000415e:	f0a2                	sd	s0,96(sp)
    80004160:	eca6                	sd	s1,88(sp)
    80004162:	e8ca                	sd	s2,80(sp)
    80004164:	e4ce                	sd	s3,72(sp)
    80004166:	e0d2                	sd	s4,64(sp)
    80004168:	fc56                	sd	s5,56(sp)
    8000416a:	f85a                	sd	s6,48(sp)
    8000416c:	f45e                	sd	s7,40(sp)
    8000416e:	f062                	sd	s8,32(sp)
    80004170:	ec66                	sd	s9,24(sp)
    80004172:	e86a                	sd	s10,16(sp)
    80004174:	e46e                	sd	s11,8(sp)
    80004176:	1880                	addi	s0,sp,112
    80004178:	8b2a                	mv	s6,a0
    8000417a:	8bae                	mv	s7,a1
    8000417c:	8a32                	mv	s4,a2
    8000417e:	84b6                	mv	s1,a3
    80004180:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80004182:	9f35                	addw	a4,a4,a3
    return 0;
    80004184:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004186:	0ad76063          	bltu	a4,a3,80004226 <readi+0xd2>
  if(off + n > ip->size)
    8000418a:	00e7f463          	bgeu	a5,a4,80004192 <readi+0x3e>
    n = ip->size - off;
    8000418e:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004192:	0a0a8963          	beqz	s5,80004244 <readi+0xf0>
    80004196:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004198:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000419c:	5c7d                	li	s8,-1
    8000419e:	a82d                	j	800041d8 <readi+0x84>
    800041a0:	020d1d93          	slli	s11,s10,0x20
    800041a4:	020ddd93          	srli	s11,s11,0x20
    800041a8:	05890613          	addi	a2,s2,88
    800041ac:	86ee                	mv	a3,s11
    800041ae:	963a                	add	a2,a2,a4
    800041b0:	85d2                	mv	a1,s4
    800041b2:	855e                	mv	a0,s7
    800041b4:	ffffe097          	auipc	ra,0xffffe
    800041b8:	7c4080e7          	jalr	1988(ra) # 80002978 <either_copyout>
    800041bc:	05850d63          	beq	a0,s8,80004216 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800041c0:	854a                	mv	a0,s2
    800041c2:	fffff097          	auipc	ra,0xfffff
    800041c6:	5f4080e7          	jalr	1524(ra) # 800037b6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800041ca:	013d09bb          	addw	s3,s10,s3
    800041ce:	009d04bb          	addw	s1,s10,s1
    800041d2:	9a6e                	add	s4,s4,s11
    800041d4:	0559f763          	bgeu	s3,s5,80004222 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    800041d8:	00a4d59b          	srliw	a1,s1,0xa
    800041dc:	855a                	mv	a0,s6
    800041de:	00000097          	auipc	ra,0x0
    800041e2:	8a2080e7          	jalr	-1886(ra) # 80003a80 <bmap>
    800041e6:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800041ea:	cd85                	beqz	a1,80004222 <readi+0xce>
    bp = bread(ip->dev, addr);
    800041ec:	000b2503          	lw	a0,0(s6)
    800041f0:	fffff097          	auipc	ra,0xfffff
    800041f4:	496080e7          	jalr	1174(ra) # 80003686 <bread>
    800041f8:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800041fa:	3ff4f713          	andi	a4,s1,1023
    800041fe:	40ec87bb          	subw	a5,s9,a4
    80004202:	413a86bb          	subw	a3,s5,s3
    80004206:	8d3e                	mv	s10,a5
    80004208:	2781                	sext.w	a5,a5
    8000420a:	0006861b          	sext.w	a2,a3
    8000420e:	f8f679e3          	bgeu	a2,a5,800041a0 <readi+0x4c>
    80004212:	8d36                	mv	s10,a3
    80004214:	b771                	j	800041a0 <readi+0x4c>
      brelse(bp);
    80004216:	854a                	mv	a0,s2
    80004218:	fffff097          	auipc	ra,0xfffff
    8000421c:	59e080e7          	jalr	1438(ra) # 800037b6 <brelse>
      tot = -1;
    80004220:	59fd                	li	s3,-1
  }
  return tot;
    80004222:	0009851b          	sext.w	a0,s3
}
    80004226:	70a6                	ld	ra,104(sp)
    80004228:	7406                	ld	s0,96(sp)
    8000422a:	64e6                	ld	s1,88(sp)
    8000422c:	6946                	ld	s2,80(sp)
    8000422e:	69a6                	ld	s3,72(sp)
    80004230:	6a06                	ld	s4,64(sp)
    80004232:	7ae2                	ld	s5,56(sp)
    80004234:	7b42                	ld	s6,48(sp)
    80004236:	7ba2                	ld	s7,40(sp)
    80004238:	7c02                	ld	s8,32(sp)
    8000423a:	6ce2                	ld	s9,24(sp)
    8000423c:	6d42                	ld	s10,16(sp)
    8000423e:	6da2                	ld	s11,8(sp)
    80004240:	6165                	addi	sp,sp,112
    80004242:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004244:	89d6                	mv	s3,s5
    80004246:	bff1                	j	80004222 <readi+0xce>
    return 0;
    80004248:	4501                	li	a0,0
}
    8000424a:	8082                	ret

000000008000424c <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000424c:	457c                	lw	a5,76(a0)
    8000424e:	10d7e863          	bltu	a5,a3,8000435e <writei+0x112>
{
    80004252:	7159                	addi	sp,sp,-112
    80004254:	f486                	sd	ra,104(sp)
    80004256:	f0a2                	sd	s0,96(sp)
    80004258:	eca6                	sd	s1,88(sp)
    8000425a:	e8ca                	sd	s2,80(sp)
    8000425c:	e4ce                	sd	s3,72(sp)
    8000425e:	e0d2                	sd	s4,64(sp)
    80004260:	fc56                	sd	s5,56(sp)
    80004262:	f85a                	sd	s6,48(sp)
    80004264:	f45e                	sd	s7,40(sp)
    80004266:	f062                	sd	s8,32(sp)
    80004268:	ec66                	sd	s9,24(sp)
    8000426a:	e86a                	sd	s10,16(sp)
    8000426c:	e46e                	sd	s11,8(sp)
    8000426e:	1880                	addi	s0,sp,112
    80004270:	8aaa                	mv	s5,a0
    80004272:	8bae                	mv	s7,a1
    80004274:	8a32                	mv	s4,a2
    80004276:	8936                	mv	s2,a3
    80004278:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000427a:	00e687bb          	addw	a5,a3,a4
    8000427e:	0ed7e263          	bltu	a5,a3,80004362 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004282:	00043737          	lui	a4,0x43
    80004286:	0ef76063          	bltu	a4,a5,80004366 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000428a:	0c0b0863          	beqz	s6,8000435a <writei+0x10e>
    8000428e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004290:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004294:	5c7d                	li	s8,-1
    80004296:	a091                	j	800042da <writei+0x8e>
    80004298:	020d1d93          	slli	s11,s10,0x20
    8000429c:	020ddd93          	srli	s11,s11,0x20
    800042a0:	05848513          	addi	a0,s1,88
    800042a4:	86ee                	mv	a3,s11
    800042a6:	8652                	mv	a2,s4
    800042a8:	85de                	mv	a1,s7
    800042aa:	953a                	add	a0,a0,a4
    800042ac:	ffffe097          	auipc	ra,0xffffe
    800042b0:	722080e7          	jalr	1826(ra) # 800029ce <either_copyin>
    800042b4:	07850263          	beq	a0,s8,80004318 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800042b8:	8526                	mv	a0,s1
    800042ba:	00000097          	auipc	ra,0x0
    800042be:	780080e7          	jalr	1920(ra) # 80004a3a <log_write>
    brelse(bp);
    800042c2:	8526                	mv	a0,s1
    800042c4:	fffff097          	auipc	ra,0xfffff
    800042c8:	4f2080e7          	jalr	1266(ra) # 800037b6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800042cc:	013d09bb          	addw	s3,s10,s3
    800042d0:	012d093b          	addw	s2,s10,s2
    800042d4:	9a6e                	add	s4,s4,s11
    800042d6:	0569f663          	bgeu	s3,s6,80004322 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    800042da:	00a9559b          	srliw	a1,s2,0xa
    800042de:	8556                	mv	a0,s5
    800042e0:	fffff097          	auipc	ra,0xfffff
    800042e4:	7a0080e7          	jalr	1952(ra) # 80003a80 <bmap>
    800042e8:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800042ec:	c99d                	beqz	a1,80004322 <writei+0xd6>
    bp = bread(ip->dev, addr);
    800042ee:	000aa503          	lw	a0,0(s5)
    800042f2:	fffff097          	auipc	ra,0xfffff
    800042f6:	394080e7          	jalr	916(ra) # 80003686 <bread>
    800042fa:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800042fc:	3ff97713          	andi	a4,s2,1023
    80004300:	40ec87bb          	subw	a5,s9,a4
    80004304:	413b06bb          	subw	a3,s6,s3
    80004308:	8d3e                	mv	s10,a5
    8000430a:	2781                	sext.w	a5,a5
    8000430c:	0006861b          	sext.w	a2,a3
    80004310:	f8f674e3          	bgeu	a2,a5,80004298 <writei+0x4c>
    80004314:	8d36                	mv	s10,a3
    80004316:	b749                	j	80004298 <writei+0x4c>
      brelse(bp);
    80004318:	8526                	mv	a0,s1
    8000431a:	fffff097          	auipc	ra,0xfffff
    8000431e:	49c080e7          	jalr	1180(ra) # 800037b6 <brelse>
  }

  if(off > ip->size)
    80004322:	04caa783          	lw	a5,76(s5)
    80004326:	0127f463          	bgeu	a5,s2,8000432e <writei+0xe2>
    ip->size = off;
    8000432a:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000432e:	8556                	mv	a0,s5
    80004330:	00000097          	auipc	ra,0x0
    80004334:	aa6080e7          	jalr	-1370(ra) # 80003dd6 <iupdate>

  return tot;
    80004338:	0009851b          	sext.w	a0,s3
}
    8000433c:	70a6                	ld	ra,104(sp)
    8000433e:	7406                	ld	s0,96(sp)
    80004340:	64e6                	ld	s1,88(sp)
    80004342:	6946                	ld	s2,80(sp)
    80004344:	69a6                	ld	s3,72(sp)
    80004346:	6a06                	ld	s4,64(sp)
    80004348:	7ae2                	ld	s5,56(sp)
    8000434a:	7b42                	ld	s6,48(sp)
    8000434c:	7ba2                	ld	s7,40(sp)
    8000434e:	7c02                	ld	s8,32(sp)
    80004350:	6ce2                	ld	s9,24(sp)
    80004352:	6d42                	ld	s10,16(sp)
    80004354:	6da2                	ld	s11,8(sp)
    80004356:	6165                	addi	sp,sp,112
    80004358:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000435a:	89da                	mv	s3,s6
    8000435c:	bfc9                	j	8000432e <writei+0xe2>
    return -1;
    8000435e:	557d                	li	a0,-1
}
    80004360:	8082                	ret
    return -1;
    80004362:	557d                	li	a0,-1
    80004364:	bfe1                	j	8000433c <writei+0xf0>
    return -1;
    80004366:	557d                	li	a0,-1
    80004368:	bfd1                	j	8000433c <writei+0xf0>

000000008000436a <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000436a:	1141                	addi	sp,sp,-16
    8000436c:	e406                	sd	ra,8(sp)
    8000436e:	e022                	sd	s0,0(sp)
    80004370:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004372:	4639                	li	a2,14
    80004374:	ffffd097          	auipc	ra,0xffffd
    80004378:	a4a080e7          	jalr	-1462(ra) # 80000dbe <strncmp>
}
    8000437c:	60a2                	ld	ra,8(sp)
    8000437e:	6402                	ld	s0,0(sp)
    80004380:	0141                	addi	sp,sp,16
    80004382:	8082                	ret

0000000080004384 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004384:	7139                	addi	sp,sp,-64
    80004386:	fc06                	sd	ra,56(sp)
    80004388:	f822                	sd	s0,48(sp)
    8000438a:	f426                	sd	s1,40(sp)
    8000438c:	f04a                	sd	s2,32(sp)
    8000438e:	ec4e                	sd	s3,24(sp)
    80004390:	e852                	sd	s4,16(sp)
    80004392:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004394:	04451703          	lh	a4,68(a0)
    80004398:	4785                	li	a5,1
    8000439a:	00f71a63          	bne	a4,a5,800043ae <dirlookup+0x2a>
    8000439e:	892a                	mv	s2,a0
    800043a0:	89ae                	mv	s3,a1
    800043a2:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800043a4:	457c                	lw	a5,76(a0)
    800043a6:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800043a8:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043aa:	e79d                	bnez	a5,800043d8 <dirlookup+0x54>
    800043ac:	a8a5                	j	80004424 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800043ae:	00004517          	auipc	a0,0x4
    800043b2:	39250513          	addi	a0,a0,914 # 80008740 <syscallnum+0x160>
    800043b6:	ffffc097          	auipc	ra,0xffffc
    800043ba:	18e080e7          	jalr	398(ra) # 80000544 <panic>
      panic("dirlookup read");
    800043be:	00004517          	auipc	a0,0x4
    800043c2:	39a50513          	addi	a0,a0,922 # 80008758 <syscallnum+0x178>
    800043c6:	ffffc097          	auipc	ra,0xffffc
    800043ca:	17e080e7          	jalr	382(ra) # 80000544 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043ce:	24c1                	addiw	s1,s1,16
    800043d0:	04c92783          	lw	a5,76(s2)
    800043d4:	04f4f763          	bgeu	s1,a5,80004422 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043d8:	4741                	li	a4,16
    800043da:	86a6                	mv	a3,s1
    800043dc:	fc040613          	addi	a2,s0,-64
    800043e0:	4581                	li	a1,0
    800043e2:	854a                	mv	a0,s2
    800043e4:	00000097          	auipc	ra,0x0
    800043e8:	d70080e7          	jalr	-656(ra) # 80004154 <readi>
    800043ec:	47c1                	li	a5,16
    800043ee:	fcf518e3          	bne	a0,a5,800043be <dirlookup+0x3a>
    if(de.inum == 0)
    800043f2:	fc045783          	lhu	a5,-64(s0)
    800043f6:	dfe1                	beqz	a5,800043ce <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800043f8:	fc240593          	addi	a1,s0,-62
    800043fc:	854e                	mv	a0,s3
    800043fe:	00000097          	auipc	ra,0x0
    80004402:	f6c080e7          	jalr	-148(ra) # 8000436a <namecmp>
    80004406:	f561                	bnez	a0,800043ce <dirlookup+0x4a>
      if(poff)
    80004408:	000a0463          	beqz	s4,80004410 <dirlookup+0x8c>
        *poff = off;
    8000440c:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004410:	fc045583          	lhu	a1,-64(s0)
    80004414:	00092503          	lw	a0,0(s2)
    80004418:	fffff097          	auipc	ra,0xfffff
    8000441c:	750080e7          	jalr	1872(ra) # 80003b68 <iget>
    80004420:	a011                	j	80004424 <dirlookup+0xa0>
  return 0;
    80004422:	4501                	li	a0,0
}
    80004424:	70e2                	ld	ra,56(sp)
    80004426:	7442                	ld	s0,48(sp)
    80004428:	74a2                	ld	s1,40(sp)
    8000442a:	7902                	ld	s2,32(sp)
    8000442c:	69e2                	ld	s3,24(sp)
    8000442e:	6a42                	ld	s4,16(sp)
    80004430:	6121                	addi	sp,sp,64
    80004432:	8082                	ret

0000000080004434 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004434:	711d                	addi	sp,sp,-96
    80004436:	ec86                	sd	ra,88(sp)
    80004438:	e8a2                	sd	s0,80(sp)
    8000443a:	e4a6                	sd	s1,72(sp)
    8000443c:	e0ca                	sd	s2,64(sp)
    8000443e:	fc4e                	sd	s3,56(sp)
    80004440:	f852                	sd	s4,48(sp)
    80004442:	f456                	sd	s5,40(sp)
    80004444:	f05a                	sd	s6,32(sp)
    80004446:	ec5e                	sd	s7,24(sp)
    80004448:	e862                	sd	s8,16(sp)
    8000444a:	e466                	sd	s9,8(sp)
    8000444c:	1080                	addi	s0,sp,96
    8000444e:	84aa                	mv	s1,a0
    80004450:	8b2e                	mv	s6,a1
    80004452:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004454:	00054703          	lbu	a4,0(a0)
    80004458:	02f00793          	li	a5,47
    8000445c:	02f70363          	beq	a4,a5,80004482 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004460:	ffffd097          	auipc	ra,0xffffd
    80004464:	566080e7          	jalr	1382(ra) # 800019c6 <myproc>
    80004468:	15053503          	ld	a0,336(a0)
    8000446c:	00000097          	auipc	ra,0x0
    80004470:	9f6080e7          	jalr	-1546(ra) # 80003e62 <idup>
    80004474:	89aa                	mv	s3,a0
  while(*path == '/')
    80004476:	02f00913          	li	s2,47
  len = path - s;
    8000447a:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    8000447c:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000447e:	4c05                	li	s8,1
    80004480:	a865                	j	80004538 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004482:	4585                	li	a1,1
    80004484:	4505                	li	a0,1
    80004486:	fffff097          	auipc	ra,0xfffff
    8000448a:	6e2080e7          	jalr	1762(ra) # 80003b68 <iget>
    8000448e:	89aa                	mv	s3,a0
    80004490:	b7dd                	j	80004476 <namex+0x42>
      iunlockput(ip);
    80004492:	854e                	mv	a0,s3
    80004494:	00000097          	auipc	ra,0x0
    80004498:	c6e080e7          	jalr	-914(ra) # 80004102 <iunlockput>
      return 0;
    8000449c:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    8000449e:	854e                	mv	a0,s3
    800044a0:	60e6                	ld	ra,88(sp)
    800044a2:	6446                	ld	s0,80(sp)
    800044a4:	64a6                	ld	s1,72(sp)
    800044a6:	6906                	ld	s2,64(sp)
    800044a8:	79e2                	ld	s3,56(sp)
    800044aa:	7a42                	ld	s4,48(sp)
    800044ac:	7aa2                	ld	s5,40(sp)
    800044ae:	7b02                	ld	s6,32(sp)
    800044b0:	6be2                	ld	s7,24(sp)
    800044b2:	6c42                	ld	s8,16(sp)
    800044b4:	6ca2                	ld	s9,8(sp)
    800044b6:	6125                	addi	sp,sp,96
    800044b8:	8082                	ret
      iunlock(ip);
    800044ba:	854e                	mv	a0,s3
    800044bc:	00000097          	auipc	ra,0x0
    800044c0:	aa6080e7          	jalr	-1370(ra) # 80003f62 <iunlock>
      return ip;
    800044c4:	bfe9                	j	8000449e <namex+0x6a>
      iunlockput(ip);
    800044c6:	854e                	mv	a0,s3
    800044c8:	00000097          	auipc	ra,0x0
    800044cc:	c3a080e7          	jalr	-966(ra) # 80004102 <iunlockput>
      return 0;
    800044d0:	89d2                	mv	s3,s4
    800044d2:	b7f1                	j	8000449e <namex+0x6a>
  len = path - s;
    800044d4:	40b48633          	sub	a2,s1,a1
    800044d8:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    800044dc:	094cd463          	bge	s9,s4,80004564 <namex+0x130>
    memmove(name, s, DIRSIZ);
    800044e0:	4639                	li	a2,14
    800044e2:	8556                	mv	a0,s5
    800044e4:	ffffd097          	auipc	ra,0xffffd
    800044e8:	862080e7          	jalr	-1950(ra) # 80000d46 <memmove>
  while(*path == '/')
    800044ec:	0004c783          	lbu	a5,0(s1)
    800044f0:	01279763          	bne	a5,s2,800044fe <namex+0xca>
    path++;
    800044f4:	0485                	addi	s1,s1,1
  while(*path == '/')
    800044f6:	0004c783          	lbu	a5,0(s1)
    800044fa:	ff278de3          	beq	a5,s2,800044f4 <namex+0xc0>
    ilock(ip);
    800044fe:	854e                	mv	a0,s3
    80004500:	00000097          	auipc	ra,0x0
    80004504:	9a0080e7          	jalr	-1632(ra) # 80003ea0 <ilock>
    if(ip->type != T_DIR){
    80004508:	04499783          	lh	a5,68(s3)
    8000450c:	f98793e3          	bne	a5,s8,80004492 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004510:	000b0563          	beqz	s6,8000451a <namex+0xe6>
    80004514:	0004c783          	lbu	a5,0(s1)
    80004518:	d3cd                	beqz	a5,800044ba <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000451a:	865e                	mv	a2,s7
    8000451c:	85d6                	mv	a1,s5
    8000451e:	854e                	mv	a0,s3
    80004520:	00000097          	auipc	ra,0x0
    80004524:	e64080e7          	jalr	-412(ra) # 80004384 <dirlookup>
    80004528:	8a2a                	mv	s4,a0
    8000452a:	dd51                	beqz	a0,800044c6 <namex+0x92>
    iunlockput(ip);
    8000452c:	854e                	mv	a0,s3
    8000452e:	00000097          	auipc	ra,0x0
    80004532:	bd4080e7          	jalr	-1068(ra) # 80004102 <iunlockput>
    ip = next;
    80004536:	89d2                	mv	s3,s4
  while(*path == '/')
    80004538:	0004c783          	lbu	a5,0(s1)
    8000453c:	05279763          	bne	a5,s2,8000458a <namex+0x156>
    path++;
    80004540:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004542:	0004c783          	lbu	a5,0(s1)
    80004546:	ff278de3          	beq	a5,s2,80004540 <namex+0x10c>
  if(*path == 0)
    8000454a:	c79d                	beqz	a5,80004578 <namex+0x144>
    path++;
    8000454c:	85a6                	mv	a1,s1
  len = path - s;
    8000454e:	8a5e                	mv	s4,s7
    80004550:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80004552:	01278963          	beq	a5,s2,80004564 <namex+0x130>
    80004556:	dfbd                	beqz	a5,800044d4 <namex+0xa0>
    path++;
    80004558:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000455a:	0004c783          	lbu	a5,0(s1)
    8000455e:	ff279ce3          	bne	a5,s2,80004556 <namex+0x122>
    80004562:	bf8d                	j	800044d4 <namex+0xa0>
    memmove(name, s, len);
    80004564:	2601                	sext.w	a2,a2
    80004566:	8556                	mv	a0,s5
    80004568:	ffffc097          	auipc	ra,0xffffc
    8000456c:	7de080e7          	jalr	2014(ra) # 80000d46 <memmove>
    name[len] = 0;
    80004570:	9a56                	add	s4,s4,s5
    80004572:	000a0023          	sb	zero,0(s4)
    80004576:	bf9d                	j	800044ec <namex+0xb8>
  if(nameiparent){
    80004578:	f20b03e3          	beqz	s6,8000449e <namex+0x6a>
    iput(ip);
    8000457c:	854e                	mv	a0,s3
    8000457e:	00000097          	auipc	ra,0x0
    80004582:	adc080e7          	jalr	-1316(ra) # 8000405a <iput>
    return 0;
    80004586:	4981                	li	s3,0
    80004588:	bf19                	j	8000449e <namex+0x6a>
  if(*path == 0)
    8000458a:	d7fd                	beqz	a5,80004578 <namex+0x144>
  while(*path != '/' && *path != 0)
    8000458c:	0004c783          	lbu	a5,0(s1)
    80004590:	85a6                	mv	a1,s1
    80004592:	b7d1                	j	80004556 <namex+0x122>

0000000080004594 <dirlink>:
{
    80004594:	7139                	addi	sp,sp,-64
    80004596:	fc06                	sd	ra,56(sp)
    80004598:	f822                	sd	s0,48(sp)
    8000459a:	f426                	sd	s1,40(sp)
    8000459c:	f04a                	sd	s2,32(sp)
    8000459e:	ec4e                	sd	s3,24(sp)
    800045a0:	e852                	sd	s4,16(sp)
    800045a2:	0080                	addi	s0,sp,64
    800045a4:	892a                	mv	s2,a0
    800045a6:	8a2e                	mv	s4,a1
    800045a8:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800045aa:	4601                	li	a2,0
    800045ac:	00000097          	auipc	ra,0x0
    800045b0:	dd8080e7          	jalr	-552(ra) # 80004384 <dirlookup>
    800045b4:	e93d                	bnez	a0,8000462a <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800045b6:	04c92483          	lw	s1,76(s2)
    800045ba:	c49d                	beqz	s1,800045e8 <dirlink+0x54>
    800045bc:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800045be:	4741                	li	a4,16
    800045c0:	86a6                	mv	a3,s1
    800045c2:	fc040613          	addi	a2,s0,-64
    800045c6:	4581                	li	a1,0
    800045c8:	854a                	mv	a0,s2
    800045ca:	00000097          	auipc	ra,0x0
    800045ce:	b8a080e7          	jalr	-1142(ra) # 80004154 <readi>
    800045d2:	47c1                	li	a5,16
    800045d4:	06f51163          	bne	a0,a5,80004636 <dirlink+0xa2>
    if(de.inum == 0)
    800045d8:	fc045783          	lhu	a5,-64(s0)
    800045dc:	c791                	beqz	a5,800045e8 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800045de:	24c1                	addiw	s1,s1,16
    800045e0:	04c92783          	lw	a5,76(s2)
    800045e4:	fcf4ede3          	bltu	s1,a5,800045be <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800045e8:	4639                	li	a2,14
    800045ea:	85d2                	mv	a1,s4
    800045ec:	fc240513          	addi	a0,s0,-62
    800045f0:	ffffd097          	auipc	ra,0xffffd
    800045f4:	80a080e7          	jalr	-2038(ra) # 80000dfa <strncpy>
  de.inum = inum;
    800045f8:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800045fc:	4741                	li	a4,16
    800045fe:	86a6                	mv	a3,s1
    80004600:	fc040613          	addi	a2,s0,-64
    80004604:	4581                	li	a1,0
    80004606:	854a                	mv	a0,s2
    80004608:	00000097          	auipc	ra,0x0
    8000460c:	c44080e7          	jalr	-956(ra) # 8000424c <writei>
    80004610:	1541                	addi	a0,a0,-16
    80004612:	00a03533          	snez	a0,a0
    80004616:	40a00533          	neg	a0,a0
}
    8000461a:	70e2                	ld	ra,56(sp)
    8000461c:	7442                	ld	s0,48(sp)
    8000461e:	74a2                	ld	s1,40(sp)
    80004620:	7902                	ld	s2,32(sp)
    80004622:	69e2                	ld	s3,24(sp)
    80004624:	6a42                	ld	s4,16(sp)
    80004626:	6121                	addi	sp,sp,64
    80004628:	8082                	ret
    iput(ip);
    8000462a:	00000097          	auipc	ra,0x0
    8000462e:	a30080e7          	jalr	-1488(ra) # 8000405a <iput>
    return -1;
    80004632:	557d                	li	a0,-1
    80004634:	b7dd                	j	8000461a <dirlink+0x86>
      panic("dirlink read");
    80004636:	00004517          	auipc	a0,0x4
    8000463a:	13250513          	addi	a0,a0,306 # 80008768 <syscallnum+0x188>
    8000463e:	ffffc097          	auipc	ra,0xffffc
    80004642:	f06080e7          	jalr	-250(ra) # 80000544 <panic>

0000000080004646 <namei>:

struct inode*
namei(char *path)
{
    80004646:	1101                	addi	sp,sp,-32
    80004648:	ec06                	sd	ra,24(sp)
    8000464a:	e822                	sd	s0,16(sp)
    8000464c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000464e:	fe040613          	addi	a2,s0,-32
    80004652:	4581                	li	a1,0
    80004654:	00000097          	auipc	ra,0x0
    80004658:	de0080e7          	jalr	-544(ra) # 80004434 <namex>
}
    8000465c:	60e2                	ld	ra,24(sp)
    8000465e:	6442                	ld	s0,16(sp)
    80004660:	6105                	addi	sp,sp,32
    80004662:	8082                	ret

0000000080004664 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004664:	1141                	addi	sp,sp,-16
    80004666:	e406                	sd	ra,8(sp)
    80004668:	e022                	sd	s0,0(sp)
    8000466a:	0800                	addi	s0,sp,16
    8000466c:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000466e:	4585                	li	a1,1
    80004670:	00000097          	auipc	ra,0x0
    80004674:	dc4080e7          	jalr	-572(ra) # 80004434 <namex>
}
    80004678:	60a2                	ld	ra,8(sp)
    8000467a:	6402                	ld	s0,0(sp)
    8000467c:	0141                	addi	sp,sp,16
    8000467e:	8082                	ret

0000000080004680 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004680:	1101                	addi	sp,sp,-32
    80004682:	ec06                	sd	ra,24(sp)
    80004684:	e822                	sd	s0,16(sp)
    80004686:	e426                	sd	s1,8(sp)
    80004688:	e04a                	sd	s2,0(sp)
    8000468a:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000468c:	0001e917          	auipc	s2,0x1e
    80004690:	4d490913          	addi	s2,s2,1236 # 80022b60 <log>
    80004694:	01892583          	lw	a1,24(s2)
    80004698:	02892503          	lw	a0,40(s2)
    8000469c:	fffff097          	auipc	ra,0xfffff
    800046a0:	fea080e7          	jalr	-22(ra) # 80003686 <bread>
    800046a4:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800046a6:	02c92683          	lw	a3,44(s2)
    800046aa:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800046ac:	02d05763          	blez	a3,800046da <write_head+0x5a>
    800046b0:	0001e797          	auipc	a5,0x1e
    800046b4:	4e078793          	addi	a5,a5,1248 # 80022b90 <log+0x30>
    800046b8:	05c50713          	addi	a4,a0,92
    800046bc:	36fd                	addiw	a3,a3,-1
    800046be:	1682                	slli	a3,a3,0x20
    800046c0:	9281                	srli	a3,a3,0x20
    800046c2:	068a                	slli	a3,a3,0x2
    800046c4:	0001e617          	auipc	a2,0x1e
    800046c8:	4d060613          	addi	a2,a2,1232 # 80022b94 <log+0x34>
    800046cc:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800046ce:	4390                	lw	a2,0(a5)
    800046d0:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800046d2:	0791                	addi	a5,a5,4
    800046d4:	0711                	addi	a4,a4,4
    800046d6:	fed79ce3          	bne	a5,a3,800046ce <write_head+0x4e>
  }
  bwrite(buf);
    800046da:	8526                	mv	a0,s1
    800046dc:	fffff097          	auipc	ra,0xfffff
    800046e0:	09c080e7          	jalr	156(ra) # 80003778 <bwrite>
  brelse(buf);
    800046e4:	8526                	mv	a0,s1
    800046e6:	fffff097          	auipc	ra,0xfffff
    800046ea:	0d0080e7          	jalr	208(ra) # 800037b6 <brelse>
}
    800046ee:	60e2                	ld	ra,24(sp)
    800046f0:	6442                	ld	s0,16(sp)
    800046f2:	64a2                	ld	s1,8(sp)
    800046f4:	6902                	ld	s2,0(sp)
    800046f6:	6105                	addi	sp,sp,32
    800046f8:	8082                	ret

00000000800046fa <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800046fa:	0001e797          	auipc	a5,0x1e
    800046fe:	4927a783          	lw	a5,1170(a5) # 80022b8c <log+0x2c>
    80004702:	0af05d63          	blez	a5,800047bc <install_trans+0xc2>
{
    80004706:	7139                	addi	sp,sp,-64
    80004708:	fc06                	sd	ra,56(sp)
    8000470a:	f822                	sd	s0,48(sp)
    8000470c:	f426                	sd	s1,40(sp)
    8000470e:	f04a                	sd	s2,32(sp)
    80004710:	ec4e                	sd	s3,24(sp)
    80004712:	e852                	sd	s4,16(sp)
    80004714:	e456                	sd	s5,8(sp)
    80004716:	e05a                	sd	s6,0(sp)
    80004718:	0080                	addi	s0,sp,64
    8000471a:	8b2a                	mv	s6,a0
    8000471c:	0001ea97          	auipc	s5,0x1e
    80004720:	474a8a93          	addi	s5,s5,1140 # 80022b90 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004724:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004726:	0001e997          	auipc	s3,0x1e
    8000472a:	43a98993          	addi	s3,s3,1082 # 80022b60 <log>
    8000472e:	a035                	j	8000475a <install_trans+0x60>
      bunpin(dbuf);
    80004730:	8526                	mv	a0,s1
    80004732:	fffff097          	auipc	ra,0xfffff
    80004736:	15e080e7          	jalr	350(ra) # 80003890 <bunpin>
    brelse(lbuf);
    8000473a:	854a                	mv	a0,s2
    8000473c:	fffff097          	auipc	ra,0xfffff
    80004740:	07a080e7          	jalr	122(ra) # 800037b6 <brelse>
    brelse(dbuf);
    80004744:	8526                	mv	a0,s1
    80004746:	fffff097          	auipc	ra,0xfffff
    8000474a:	070080e7          	jalr	112(ra) # 800037b6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000474e:	2a05                	addiw	s4,s4,1
    80004750:	0a91                	addi	s5,s5,4
    80004752:	02c9a783          	lw	a5,44(s3)
    80004756:	04fa5963          	bge	s4,a5,800047a8 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000475a:	0189a583          	lw	a1,24(s3)
    8000475e:	014585bb          	addw	a1,a1,s4
    80004762:	2585                	addiw	a1,a1,1
    80004764:	0289a503          	lw	a0,40(s3)
    80004768:	fffff097          	auipc	ra,0xfffff
    8000476c:	f1e080e7          	jalr	-226(ra) # 80003686 <bread>
    80004770:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004772:	000aa583          	lw	a1,0(s5)
    80004776:	0289a503          	lw	a0,40(s3)
    8000477a:	fffff097          	auipc	ra,0xfffff
    8000477e:	f0c080e7          	jalr	-244(ra) # 80003686 <bread>
    80004782:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004784:	40000613          	li	a2,1024
    80004788:	05890593          	addi	a1,s2,88
    8000478c:	05850513          	addi	a0,a0,88
    80004790:	ffffc097          	auipc	ra,0xffffc
    80004794:	5b6080e7          	jalr	1462(ra) # 80000d46 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004798:	8526                	mv	a0,s1
    8000479a:	fffff097          	auipc	ra,0xfffff
    8000479e:	fde080e7          	jalr	-34(ra) # 80003778 <bwrite>
    if(recovering == 0)
    800047a2:	f80b1ce3          	bnez	s6,8000473a <install_trans+0x40>
    800047a6:	b769                	j	80004730 <install_trans+0x36>
}
    800047a8:	70e2                	ld	ra,56(sp)
    800047aa:	7442                	ld	s0,48(sp)
    800047ac:	74a2                	ld	s1,40(sp)
    800047ae:	7902                	ld	s2,32(sp)
    800047b0:	69e2                	ld	s3,24(sp)
    800047b2:	6a42                	ld	s4,16(sp)
    800047b4:	6aa2                	ld	s5,8(sp)
    800047b6:	6b02                	ld	s6,0(sp)
    800047b8:	6121                	addi	sp,sp,64
    800047ba:	8082                	ret
    800047bc:	8082                	ret

00000000800047be <initlog>:
{
    800047be:	7179                	addi	sp,sp,-48
    800047c0:	f406                	sd	ra,40(sp)
    800047c2:	f022                	sd	s0,32(sp)
    800047c4:	ec26                	sd	s1,24(sp)
    800047c6:	e84a                	sd	s2,16(sp)
    800047c8:	e44e                	sd	s3,8(sp)
    800047ca:	1800                	addi	s0,sp,48
    800047cc:	892a                	mv	s2,a0
    800047ce:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800047d0:	0001e497          	auipc	s1,0x1e
    800047d4:	39048493          	addi	s1,s1,912 # 80022b60 <log>
    800047d8:	00004597          	auipc	a1,0x4
    800047dc:	fa058593          	addi	a1,a1,-96 # 80008778 <syscallnum+0x198>
    800047e0:	8526                	mv	a0,s1
    800047e2:	ffffc097          	auipc	ra,0xffffc
    800047e6:	378080e7          	jalr	888(ra) # 80000b5a <initlock>
  log.start = sb->logstart;
    800047ea:	0149a583          	lw	a1,20(s3)
    800047ee:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800047f0:	0109a783          	lw	a5,16(s3)
    800047f4:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800047f6:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800047fa:	854a                	mv	a0,s2
    800047fc:	fffff097          	auipc	ra,0xfffff
    80004800:	e8a080e7          	jalr	-374(ra) # 80003686 <bread>
  log.lh.n = lh->n;
    80004804:	4d3c                	lw	a5,88(a0)
    80004806:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004808:	02f05563          	blez	a5,80004832 <initlog+0x74>
    8000480c:	05c50713          	addi	a4,a0,92
    80004810:	0001e697          	auipc	a3,0x1e
    80004814:	38068693          	addi	a3,a3,896 # 80022b90 <log+0x30>
    80004818:	37fd                	addiw	a5,a5,-1
    8000481a:	1782                	slli	a5,a5,0x20
    8000481c:	9381                	srli	a5,a5,0x20
    8000481e:	078a                	slli	a5,a5,0x2
    80004820:	06050613          	addi	a2,a0,96
    80004824:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80004826:	4310                	lw	a2,0(a4)
    80004828:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    8000482a:	0711                	addi	a4,a4,4
    8000482c:	0691                	addi	a3,a3,4
    8000482e:	fef71ce3          	bne	a4,a5,80004826 <initlog+0x68>
  brelse(buf);
    80004832:	fffff097          	auipc	ra,0xfffff
    80004836:	f84080e7          	jalr	-124(ra) # 800037b6 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000483a:	4505                	li	a0,1
    8000483c:	00000097          	auipc	ra,0x0
    80004840:	ebe080e7          	jalr	-322(ra) # 800046fa <install_trans>
  log.lh.n = 0;
    80004844:	0001e797          	auipc	a5,0x1e
    80004848:	3407a423          	sw	zero,840(a5) # 80022b8c <log+0x2c>
  write_head(); // clear the log
    8000484c:	00000097          	auipc	ra,0x0
    80004850:	e34080e7          	jalr	-460(ra) # 80004680 <write_head>
}
    80004854:	70a2                	ld	ra,40(sp)
    80004856:	7402                	ld	s0,32(sp)
    80004858:	64e2                	ld	s1,24(sp)
    8000485a:	6942                	ld	s2,16(sp)
    8000485c:	69a2                	ld	s3,8(sp)
    8000485e:	6145                	addi	sp,sp,48
    80004860:	8082                	ret

0000000080004862 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004862:	1101                	addi	sp,sp,-32
    80004864:	ec06                	sd	ra,24(sp)
    80004866:	e822                	sd	s0,16(sp)
    80004868:	e426                	sd	s1,8(sp)
    8000486a:	e04a                	sd	s2,0(sp)
    8000486c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000486e:	0001e517          	auipc	a0,0x1e
    80004872:	2f250513          	addi	a0,a0,754 # 80022b60 <log>
    80004876:	ffffc097          	auipc	ra,0xffffc
    8000487a:	374080e7          	jalr	884(ra) # 80000bea <acquire>
  while(1){
    if(log.committing){
    8000487e:	0001e497          	auipc	s1,0x1e
    80004882:	2e248493          	addi	s1,s1,738 # 80022b60 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004886:	4979                	li	s2,30
    80004888:	a039                	j	80004896 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000488a:	85a6                	mv	a1,s1
    8000488c:	8526                	mv	a0,s1
    8000488e:	ffffe097          	auipc	ra,0xffffe
    80004892:	b8a080e7          	jalr	-1142(ra) # 80002418 <sleep>
    if(log.committing){
    80004896:	50dc                	lw	a5,36(s1)
    80004898:	fbed                	bnez	a5,8000488a <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000489a:	509c                	lw	a5,32(s1)
    8000489c:	0017871b          	addiw	a4,a5,1
    800048a0:	0007069b          	sext.w	a3,a4
    800048a4:	0027179b          	slliw	a5,a4,0x2
    800048a8:	9fb9                	addw	a5,a5,a4
    800048aa:	0017979b          	slliw	a5,a5,0x1
    800048ae:	54d8                	lw	a4,44(s1)
    800048b0:	9fb9                	addw	a5,a5,a4
    800048b2:	00f95963          	bge	s2,a5,800048c4 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800048b6:	85a6                	mv	a1,s1
    800048b8:	8526                	mv	a0,s1
    800048ba:	ffffe097          	auipc	ra,0xffffe
    800048be:	b5e080e7          	jalr	-1186(ra) # 80002418 <sleep>
    800048c2:	bfd1                	j	80004896 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800048c4:	0001e517          	auipc	a0,0x1e
    800048c8:	29c50513          	addi	a0,a0,668 # 80022b60 <log>
    800048cc:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800048ce:	ffffc097          	auipc	ra,0xffffc
    800048d2:	3d0080e7          	jalr	976(ra) # 80000c9e <release>
      break;
    }
  }
}
    800048d6:	60e2                	ld	ra,24(sp)
    800048d8:	6442                	ld	s0,16(sp)
    800048da:	64a2                	ld	s1,8(sp)
    800048dc:	6902                	ld	s2,0(sp)
    800048de:	6105                	addi	sp,sp,32
    800048e0:	8082                	ret

00000000800048e2 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800048e2:	7139                	addi	sp,sp,-64
    800048e4:	fc06                	sd	ra,56(sp)
    800048e6:	f822                	sd	s0,48(sp)
    800048e8:	f426                	sd	s1,40(sp)
    800048ea:	f04a                	sd	s2,32(sp)
    800048ec:	ec4e                	sd	s3,24(sp)
    800048ee:	e852                	sd	s4,16(sp)
    800048f0:	e456                	sd	s5,8(sp)
    800048f2:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800048f4:	0001e497          	auipc	s1,0x1e
    800048f8:	26c48493          	addi	s1,s1,620 # 80022b60 <log>
    800048fc:	8526                	mv	a0,s1
    800048fe:	ffffc097          	auipc	ra,0xffffc
    80004902:	2ec080e7          	jalr	748(ra) # 80000bea <acquire>
  log.outstanding -= 1;
    80004906:	509c                	lw	a5,32(s1)
    80004908:	37fd                	addiw	a5,a5,-1
    8000490a:	0007891b          	sext.w	s2,a5
    8000490e:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004910:	50dc                	lw	a5,36(s1)
    80004912:	efb9                	bnez	a5,80004970 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004914:	06091663          	bnez	s2,80004980 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    80004918:	0001e497          	auipc	s1,0x1e
    8000491c:	24848493          	addi	s1,s1,584 # 80022b60 <log>
    80004920:	4785                	li	a5,1
    80004922:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004924:	8526                	mv	a0,s1
    80004926:	ffffc097          	auipc	ra,0xffffc
    8000492a:	378080e7          	jalr	888(ra) # 80000c9e <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000492e:	54dc                	lw	a5,44(s1)
    80004930:	06f04763          	bgtz	a5,8000499e <end_op+0xbc>
    acquire(&log.lock);
    80004934:	0001e497          	auipc	s1,0x1e
    80004938:	22c48493          	addi	s1,s1,556 # 80022b60 <log>
    8000493c:	8526                	mv	a0,s1
    8000493e:	ffffc097          	auipc	ra,0xffffc
    80004942:	2ac080e7          	jalr	684(ra) # 80000bea <acquire>
    log.committing = 0;
    80004946:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000494a:	8526                	mv	a0,s1
    8000494c:	ffffe097          	auipc	ra,0xffffe
    80004950:	c7c080e7          	jalr	-900(ra) # 800025c8 <wakeup>
    release(&log.lock);
    80004954:	8526                	mv	a0,s1
    80004956:	ffffc097          	auipc	ra,0xffffc
    8000495a:	348080e7          	jalr	840(ra) # 80000c9e <release>
}
    8000495e:	70e2                	ld	ra,56(sp)
    80004960:	7442                	ld	s0,48(sp)
    80004962:	74a2                	ld	s1,40(sp)
    80004964:	7902                	ld	s2,32(sp)
    80004966:	69e2                	ld	s3,24(sp)
    80004968:	6a42                	ld	s4,16(sp)
    8000496a:	6aa2                	ld	s5,8(sp)
    8000496c:	6121                	addi	sp,sp,64
    8000496e:	8082                	ret
    panic("log.committing");
    80004970:	00004517          	auipc	a0,0x4
    80004974:	e1050513          	addi	a0,a0,-496 # 80008780 <syscallnum+0x1a0>
    80004978:	ffffc097          	auipc	ra,0xffffc
    8000497c:	bcc080e7          	jalr	-1076(ra) # 80000544 <panic>
    wakeup(&log);
    80004980:	0001e497          	auipc	s1,0x1e
    80004984:	1e048493          	addi	s1,s1,480 # 80022b60 <log>
    80004988:	8526                	mv	a0,s1
    8000498a:	ffffe097          	auipc	ra,0xffffe
    8000498e:	c3e080e7          	jalr	-962(ra) # 800025c8 <wakeup>
  release(&log.lock);
    80004992:	8526                	mv	a0,s1
    80004994:	ffffc097          	auipc	ra,0xffffc
    80004998:	30a080e7          	jalr	778(ra) # 80000c9e <release>
  if(do_commit){
    8000499c:	b7c9                	j	8000495e <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000499e:	0001ea97          	auipc	s5,0x1e
    800049a2:	1f2a8a93          	addi	s5,s5,498 # 80022b90 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800049a6:	0001ea17          	auipc	s4,0x1e
    800049aa:	1baa0a13          	addi	s4,s4,442 # 80022b60 <log>
    800049ae:	018a2583          	lw	a1,24(s4)
    800049b2:	012585bb          	addw	a1,a1,s2
    800049b6:	2585                	addiw	a1,a1,1
    800049b8:	028a2503          	lw	a0,40(s4)
    800049bc:	fffff097          	auipc	ra,0xfffff
    800049c0:	cca080e7          	jalr	-822(ra) # 80003686 <bread>
    800049c4:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800049c6:	000aa583          	lw	a1,0(s5)
    800049ca:	028a2503          	lw	a0,40(s4)
    800049ce:	fffff097          	auipc	ra,0xfffff
    800049d2:	cb8080e7          	jalr	-840(ra) # 80003686 <bread>
    800049d6:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800049d8:	40000613          	li	a2,1024
    800049dc:	05850593          	addi	a1,a0,88
    800049e0:	05848513          	addi	a0,s1,88
    800049e4:	ffffc097          	auipc	ra,0xffffc
    800049e8:	362080e7          	jalr	866(ra) # 80000d46 <memmove>
    bwrite(to);  // write the log
    800049ec:	8526                	mv	a0,s1
    800049ee:	fffff097          	auipc	ra,0xfffff
    800049f2:	d8a080e7          	jalr	-630(ra) # 80003778 <bwrite>
    brelse(from);
    800049f6:	854e                	mv	a0,s3
    800049f8:	fffff097          	auipc	ra,0xfffff
    800049fc:	dbe080e7          	jalr	-578(ra) # 800037b6 <brelse>
    brelse(to);
    80004a00:	8526                	mv	a0,s1
    80004a02:	fffff097          	auipc	ra,0xfffff
    80004a06:	db4080e7          	jalr	-588(ra) # 800037b6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004a0a:	2905                	addiw	s2,s2,1
    80004a0c:	0a91                	addi	s5,s5,4
    80004a0e:	02ca2783          	lw	a5,44(s4)
    80004a12:	f8f94ee3          	blt	s2,a5,800049ae <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004a16:	00000097          	auipc	ra,0x0
    80004a1a:	c6a080e7          	jalr	-918(ra) # 80004680 <write_head>
    install_trans(0); // Now install writes to home locations
    80004a1e:	4501                	li	a0,0
    80004a20:	00000097          	auipc	ra,0x0
    80004a24:	cda080e7          	jalr	-806(ra) # 800046fa <install_trans>
    log.lh.n = 0;
    80004a28:	0001e797          	auipc	a5,0x1e
    80004a2c:	1607a223          	sw	zero,356(a5) # 80022b8c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004a30:	00000097          	auipc	ra,0x0
    80004a34:	c50080e7          	jalr	-944(ra) # 80004680 <write_head>
    80004a38:	bdf5                	j	80004934 <end_op+0x52>

0000000080004a3a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004a3a:	1101                	addi	sp,sp,-32
    80004a3c:	ec06                	sd	ra,24(sp)
    80004a3e:	e822                	sd	s0,16(sp)
    80004a40:	e426                	sd	s1,8(sp)
    80004a42:	e04a                	sd	s2,0(sp)
    80004a44:	1000                	addi	s0,sp,32
    80004a46:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004a48:	0001e917          	auipc	s2,0x1e
    80004a4c:	11890913          	addi	s2,s2,280 # 80022b60 <log>
    80004a50:	854a                	mv	a0,s2
    80004a52:	ffffc097          	auipc	ra,0xffffc
    80004a56:	198080e7          	jalr	408(ra) # 80000bea <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004a5a:	02c92603          	lw	a2,44(s2)
    80004a5e:	47f5                	li	a5,29
    80004a60:	06c7c563          	blt	a5,a2,80004aca <log_write+0x90>
    80004a64:	0001e797          	auipc	a5,0x1e
    80004a68:	1187a783          	lw	a5,280(a5) # 80022b7c <log+0x1c>
    80004a6c:	37fd                	addiw	a5,a5,-1
    80004a6e:	04f65e63          	bge	a2,a5,80004aca <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004a72:	0001e797          	auipc	a5,0x1e
    80004a76:	10e7a783          	lw	a5,270(a5) # 80022b80 <log+0x20>
    80004a7a:	06f05063          	blez	a5,80004ada <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004a7e:	4781                	li	a5,0
    80004a80:	06c05563          	blez	a2,80004aea <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004a84:	44cc                	lw	a1,12(s1)
    80004a86:	0001e717          	auipc	a4,0x1e
    80004a8a:	10a70713          	addi	a4,a4,266 # 80022b90 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004a8e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004a90:	4314                	lw	a3,0(a4)
    80004a92:	04b68c63          	beq	a3,a1,80004aea <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004a96:	2785                	addiw	a5,a5,1
    80004a98:	0711                	addi	a4,a4,4
    80004a9a:	fef61be3          	bne	a2,a5,80004a90 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004a9e:	0621                	addi	a2,a2,8
    80004aa0:	060a                	slli	a2,a2,0x2
    80004aa2:	0001e797          	auipc	a5,0x1e
    80004aa6:	0be78793          	addi	a5,a5,190 # 80022b60 <log>
    80004aaa:	963e                	add	a2,a2,a5
    80004aac:	44dc                	lw	a5,12(s1)
    80004aae:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004ab0:	8526                	mv	a0,s1
    80004ab2:	fffff097          	auipc	ra,0xfffff
    80004ab6:	da2080e7          	jalr	-606(ra) # 80003854 <bpin>
    log.lh.n++;
    80004aba:	0001e717          	auipc	a4,0x1e
    80004abe:	0a670713          	addi	a4,a4,166 # 80022b60 <log>
    80004ac2:	575c                	lw	a5,44(a4)
    80004ac4:	2785                	addiw	a5,a5,1
    80004ac6:	d75c                	sw	a5,44(a4)
    80004ac8:	a835                	j	80004b04 <log_write+0xca>
    panic("too big a transaction");
    80004aca:	00004517          	auipc	a0,0x4
    80004ace:	cc650513          	addi	a0,a0,-826 # 80008790 <syscallnum+0x1b0>
    80004ad2:	ffffc097          	auipc	ra,0xffffc
    80004ad6:	a72080e7          	jalr	-1422(ra) # 80000544 <panic>
    panic("log_write outside of trans");
    80004ada:	00004517          	auipc	a0,0x4
    80004ade:	cce50513          	addi	a0,a0,-818 # 800087a8 <syscallnum+0x1c8>
    80004ae2:	ffffc097          	auipc	ra,0xffffc
    80004ae6:	a62080e7          	jalr	-1438(ra) # 80000544 <panic>
  log.lh.block[i] = b->blockno;
    80004aea:	00878713          	addi	a4,a5,8
    80004aee:	00271693          	slli	a3,a4,0x2
    80004af2:	0001e717          	auipc	a4,0x1e
    80004af6:	06e70713          	addi	a4,a4,110 # 80022b60 <log>
    80004afa:	9736                	add	a4,a4,a3
    80004afc:	44d4                	lw	a3,12(s1)
    80004afe:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004b00:	faf608e3          	beq	a2,a5,80004ab0 <log_write+0x76>
  }
  release(&log.lock);
    80004b04:	0001e517          	auipc	a0,0x1e
    80004b08:	05c50513          	addi	a0,a0,92 # 80022b60 <log>
    80004b0c:	ffffc097          	auipc	ra,0xffffc
    80004b10:	192080e7          	jalr	402(ra) # 80000c9e <release>
}
    80004b14:	60e2                	ld	ra,24(sp)
    80004b16:	6442                	ld	s0,16(sp)
    80004b18:	64a2                	ld	s1,8(sp)
    80004b1a:	6902                	ld	s2,0(sp)
    80004b1c:	6105                	addi	sp,sp,32
    80004b1e:	8082                	ret

0000000080004b20 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004b20:	1101                	addi	sp,sp,-32
    80004b22:	ec06                	sd	ra,24(sp)
    80004b24:	e822                	sd	s0,16(sp)
    80004b26:	e426                	sd	s1,8(sp)
    80004b28:	e04a                	sd	s2,0(sp)
    80004b2a:	1000                	addi	s0,sp,32
    80004b2c:	84aa                	mv	s1,a0
    80004b2e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004b30:	00004597          	auipc	a1,0x4
    80004b34:	c9858593          	addi	a1,a1,-872 # 800087c8 <syscallnum+0x1e8>
    80004b38:	0521                	addi	a0,a0,8
    80004b3a:	ffffc097          	auipc	ra,0xffffc
    80004b3e:	020080e7          	jalr	32(ra) # 80000b5a <initlock>
  lk->name = name;
    80004b42:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004b46:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004b4a:	0204a423          	sw	zero,40(s1)
}
    80004b4e:	60e2                	ld	ra,24(sp)
    80004b50:	6442                	ld	s0,16(sp)
    80004b52:	64a2                	ld	s1,8(sp)
    80004b54:	6902                	ld	s2,0(sp)
    80004b56:	6105                	addi	sp,sp,32
    80004b58:	8082                	ret

0000000080004b5a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004b5a:	1101                	addi	sp,sp,-32
    80004b5c:	ec06                	sd	ra,24(sp)
    80004b5e:	e822                	sd	s0,16(sp)
    80004b60:	e426                	sd	s1,8(sp)
    80004b62:	e04a                	sd	s2,0(sp)
    80004b64:	1000                	addi	s0,sp,32
    80004b66:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004b68:	00850913          	addi	s2,a0,8
    80004b6c:	854a                	mv	a0,s2
    80004b6e:	ffffc097          	auipc	ra,0xffffc
    80004b72:	07c080e7          	jalr	124(ra) # 80000bea <acquire>
  while (lk->locked) {
    80004b76:	409c                	lw	a5,0(s1)
    80004b78:	cb89                	beqz	a5,80004b8a <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004b7a:	85ca                	mv	a1,s2
    80004b7c:	8526                	mv	a0,s1
    80004b7e:	ffffe097          	auipc	ra,0xffffe
    80004b82:	89a080e7          	jalr	-1894(ra) # 80002418 <sleep>
  while (lk->locked) {
    80004b86:	409c                	lw	a5,0(s1)
    80004b88:	fbed                	bnez	a5,80004b7a <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004b8a:	4785                	li	a5,1
    80004b8c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004b8e:	ffffd097          	auipc	ra,0xffffd
    80004b92:	e38080e7          	jalr	-456(ra) # 800019c6 <myproc>
    80004b96:	591c                	lw	a5,48(a0)
    80004b98:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004b9a:	854a                	mv	a0,s2
    80004b9c:	ffffc097          	auipc	ra,0xffffc
    80004ba0:	102080e7          	jalr	258(ra) # 80000c9e <release>
}
    80004ba4:	60e2                	ld	ra,24(sp)
    80004ba6:	6442                	ld	s0,16(sp)
    80004ba8:	64a2                	ld	s1,8(sp)
    80004baa:	6902                	ld	s2,0(sp)
    80004bac:	6105                	addi	sp,sp,32
    80004bae:	8082                	ret

0000000080004bb0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004bb0:	1101                	addi	sp,sp,-32
    80004bb2:	ec06                	sd	ra,24(sp)
    80004bb4:	e822                	sd	s0,16(sp)
    80004bb6:	e426                	sd	s1,8(sp)
    80004bb8:	e04a                	sd	s2,0(sp)
    80004bba:	1000                	addi	s0,sp,32
    80004bbc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004bbe:	00850913          	addi	s2,a0,8
    80004bc2:	854a                	mv	a0,s2
    80004bc4:	ffffc097          	auipc	ra,0xffffc
    80004bc8:	026080e7          	jalr	38(ra) # 80000bea <acquire>
  lk->locked = 0;
    80004bcc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004bd0:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004bd4:	8526                	mv	a0,s1
    80004bd6:	ffffe097          	auipc	ra,0xffffe
    80004bda:	9f2080e7          	jalr	-1550(ra) # 800025c8 <wakeup>
  release(&lk->lk);
    80004bde:	854a                	mv	a0,s2
    80004be0:	ffffc097          	auipc	ra,0xffffc
    80004be4:	0be080e7          	jalr	190(ra) # 80000c9e <release>
}
    80004be8:	60e2                	ld	ra,24(sp)
    80004bea:	6442                	ld	s0,16(sp)
    80004bec:	64a2                	ld	s1,8(sp)
    80004bee:	6902                	ld	s2,0(sp)
    80004bf0:	6105                	addi	sp,sp,32
    80004bf2:	8082                	ret

0000000080004bf4 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004bf4:	7179                	addi	sp,sp,-48
    80004bf6:	f406                	sd	ra,40(sp)
    80004bf8:	f022                	sd	s0,32(sp)
    80004bfa:	ec26                	sd	s1,24(sp)
    80004bfc:	e84a                	sd	s2,16(sp)
    80004bfe:	e44e                	sd	s3,8(sp)
    80004c00:	1800                	addi	s0,sp,48
    80004c02:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004c04:	00850913          	addi	s2,a0,8
    80004c08:	854a                	mv	a0,s2
    80004c0a:	ffffc097          	auipc	ra,0xffffc
    80004c0e:	fe0080e7          	jalr	-32(ra) # 80000bea <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004c12:	409c                	lw	a5,0(s1)
    80004c14:	ef99                	bnez	a5,80004c32 <holdingsleep+0x3e>
    80004c16:	4481                	li	s1,0
  release(&lk->lk);
    80004c18:	854a                	mv	a0,s2
    80004c1a:	ffffc097          	auipc	ra,0xffffc
    80004c1e:	084080e7          	jalr	132(ra) # 80000c9e <release>
  return r;
}
    80004c22:	8526                	mv	a0,s1
    80004c24:	70a2                	ld	ra,40(sp)
    80004c26:	7402                	ld	s0,32(sp)
    80004c28:	64e2                	ld	s1,24(sp)
    80004c2a:	6942                	ld	s2,16(sp)
    80004c2c:	69a2                	ld	s3,8(sp)
    80004c2e:	6145                	addi	sp,sp,48
    80004c30:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004c32:	0284a983          	lw	s3,40(s1)
    80004c36:	ffffd097          	auipc	ra,0xffffd
    80004c3a:	d90080e7          	jalr	-624(ra) # 800019c6 <myproc>
    80004c3e:	5904                	lw	s1,48(a0)
    80004c40:	413484b3          	sub	s1,s1,s3
    80004c44:	0014b493          	seqz	s1,s1
    80004c48:	bfc1                	j	80004c18 <holdingsleep+0x24>

0000000080004c4a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004c4a:	1141                	addi	sp,sp,-16
    80004c4c:	e406                	sd	ra,8(sp)
    80004c4e:	e022                	sd	s0,0(sp)
    80004c50:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004c52:	00004597          	auipc	a1,0x4
    80004c56:	b8658593          	addi	a1,a1,-1146 # 800087d8 <syscallnum+0x1f8>
    80004c5a:	0001e517          	auipc	a0,0x1e
    80004c5e:	04e50513          	addi	a0,a0,78 # 80022ca8 <ftable>
    80004c62:	ffffc097          	auipc	ra,0xffffc
    80004c66:	ef8080e7          	jalr	-264(ra) # 80000b5a <initlock>
}
    80004c6a:	60a2                	ld	ra,8(sp)
    80004c6c:	6402                	ld	s0,0(sp)
    80004c6e:	0141                	addi	sp,sp,16
    80004c70:	8082                	ret

0000000080004c72 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004c72:	1101                	addi	sp,sp,-32
    80004c74:	ec06                	sd	ra,24(sp)
    80004c76:	e822                	sd	s0,16(sp)
    80004c78:	e426                	sd	s1,8(sp)
    80004c7a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004c7c:	0001e517          	auipc	a0,0x1e
    80004c80:	02c50513          	addi	a0,a0,44 # 80022ca8 <ftable>
    80004c84:	ffffc097          	auipc	ra,0xffffc
    80004c88:	f66080e7          	jalr	-154(ra) # 80000bea <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004c8c:	0001e497          	auipc	s1,0x1e
    80004c90:	03448493          	addi	s1,s1,52 # 80022cc0 <ftable+0x18>
    80004c94:	0001f717          	auipc	a4,0x1f
    80004c98:	fcc70713          	addi	a4,a4,-52 # 80023c60 <disk>
    if(f->ref == 0){
    80004c9c:	40dc                	lw	a5,4(s1)
    80004c9e:	cf99                	beqz	a5,80004cbc <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004ca0:	02848493          	addi	s1,s1,40
    80004ca4:	fee49ce3          	bne	s1,a4,80004c9c <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004ca8:	0001e517          	auipc	a0,0x1e
    80004cac:	00050513          	mv	a0,a0
    80004cb0:	ffffc097          	auipc	ra,0xffffc
    80004cb4:	fee080e7          	jalr	-18(ra) # 80000c9e <release>
  return 0;
    80004cb8:	4481                	li	s1,0
    80004cba:	a819                	j	80004cd0 <filealloc+0x5e>
      f->ref = 1;
    80004cbc:	4785                	li	a5,1
    80004cbe:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004cc0:	0001e517          	auipc	a0,0x1e
    80004cc4:	fe850513          	addi	a0,a0,-24 # 80022ca8 <ftable>
    80004cc8:	ffffc097          	auipc	ra,0xffffc
    80004ccc:	fd6080e7          	jalr	-42(ra) # 80000c9e <release>
}
    80004cd0:	8526                	mv	a0,s1
    80004cd2:	60e2                	ld	ra,24(sp)
    80004cd4:	6442                	ld	s0,16(sp)
    80004cd6:	64a2                	ld	s1,8(sp)
    80004cd8:	6105                	addi	sp,sp,32
    80004cda:	8082                	ret

0000000080004cdc <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004cdc:	1101                	addi	sp,sp,-32
    80004cde:	ec06                	sd	ra,24(sp)
    80004ce0:	e822                	sd	s0,16(sp)
    80004ce2:	e426                	sd	s1,8(sp)
    80004ce4:	1000                	addi	s0,sp,32
    80004ce6:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004ce8:	0001e517          	auipc	a0,0x1e
    80004cec:	fc050513          	addi	a0,a0,-64 # 80022ca8 <ftable>
    80004cf0:	ffffc097          	auipc	ra,0xffffc
    80004cf4:	efa080e7          	jalr	-262(ra) # 80000bea <acquire>
  if(f->ref < 1)
    80004cf8:	40dc                	lw	a5,4(s1)
    80004cfa:	02f05263          	blez	a5,80004d1e <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004cfe:	2785                	addiw	a5,a5,1
    80004d00:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004d02:	0001e517          	auipc	a0,0x1e
    80004d06:	fa650513          	addi	a0,a0,-90 # 80022ca8 <ftable>
    80004d0a:	ffffc097          	auipc	ra,0xffffc
    80004d0e:	f94080e7          	jalr	-108(ra) # 80000c9e <release>
  return f;
}
    80004d12:	8526                	mv	a0,s1
    80004d14:	60e2                	ld	ra,24(sp)
    80004d16:	6442                	ld	s0,16(sp)
    80004d18:	64a2                	ld	s1,8(sp)
    80004d1a:	6105                	addi	sp,sp,32
    80004d1c:	8082                	ret
    panic("filedup");
    80004d1e:	00004517          	auipc	a0,0x4
    80004d22:	ac250513          	addi	a0,a0,-1342 # 800087e0 <syscallnum+0x200>
    80004d26:	ffffc097          	auipc	ra,0xffffc
    80004d2a:	81e080e7          	jalr	-2018(ra) # 80000544 <panic>

0000000080004d2e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004d2e:	7139                	addi	sp,sp,-64
    80004d30:	fc06                	sd	ra,56(sp)
    80004d32:	f822                	sd	s0,48(sp)
    80004d34:	f426                	sd	s1,40(sp)
    80004d36:	f04a                	sd	s2,32(sp)
    80004d38:	ec4e                	sd	s3,24(sp)
    80004d3a:	e852                	sd	s4,16(sp)
    80004d3c:	e456                	sd	s5,8(sp)
    80004d3e:	0080                	addi	s0,sp,64
    80004d40:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004d42:	0001e517          	auipc	a0,0x1e
    80004d46:	f6650513          	addi	a0,a0,-154 # 80022ca8 <ftable>
    80004d4a:	ffffc097          	auipc	ra,0xffffc
    80004d4e:	ea0080e7          	jalr	-352(ra) # 80000bea <acquire>
  if(f->ref < 1)
    80004d52:	40dc                	lw	a5,4(s1)
    80004d54:	06f05163          	blez	a5,80004db6 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004d58:	37fd                	addiw	a5,a5,-1
    80004d5a:	0007871b          	sext.w	a4,a5
    80004d5e:	c0dc                	sw	a5,4(s1)
    80004d60:	06e04363          	bgtz	a4,80004dc6 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004d64:	0004a903          	lw	s2,0(s1)
    80004d68:	0094ca83          	lbu	s5,9(s1)
    80004d6c:	0104ba03          	ld	s4,16(s1)
    80004d70:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004d74:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004d78:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004d7c:	0001e517          	auipc	a0,0x1e
    80004d80:	f2c50513          	addi	a0,a0,-212 # 80022ca8 <ftable>
    80004d84:	ffffc097          	auipc	ra,0xffffc
    80004d88:	f1a080e7          	jalr	-230(ra) # 80000c9e <release>

  if(ff.type == FD_PIPE){
    80004d8c:	4785                	li	a5,1
    80004d8e:	04f90d63          	beq	s2,a5,80004de8 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004d92:	3979                	addiw	s2,s2,-2
    80004d94:	4785                	li	a5,1
    80004d96:	0527e063          	bltu	a5,s2,80004dd6 <fileclose+0xa8>
    begin_op();
    80004d9a:	00000097          	auipc	ra,0x0
    80004d9e:	ac8080e7          	jalr	-1336(ra) # 80004862 <begin_op>
    iput(ff.ip);
    80004da2:	854e                	mv	a0,s3
    80004da4:	fffff097          	auipc	ra,0xfffff
    80004da8:	2b6080e7          	jalr	694(ra) # 8000405a <iput>
    end_op();
    80004dac:	00000097          	auipc	ra,0x0
    80004db0:	b36080e7          	jalr	-1226(ra) # 800048e2 <end_op>
    80004db4:	a00d                	j	80004dd6 <fileclose+0xa8>
    panic("fileclose");
    80004db6:	00004517          	auipc	a0,0x4
    80004dba:	a3250513          	addi	a0,a0,-1486 # 800087e8 <syscallnum+0x208>
    80004dbe:	ffffb097          	auipc	ra,0xffffb
    80004dc2:	786080e7          	jalr	1926(ra) # 80000544 <panic>
    release(&ftable.lock);
    80004dc6:	0001e517          	auipc	a0,0x1e
    80004dca:	ee250513          	addi	a0,a0,-286 # 80022ca8 <ftable>
    80004dce:	ffffc097          	auipc	ra,0xffffc
    80004dd2:	ed0080e7          	jalr	-304(ra) # 80000c9e <release>
  }
}
    80004dd6:	70e2                	ld	ra,56(sp)
    80004dd8:	7442                	ld	s0,48(sp)
    80004dda:	74a2                	ld	s1,40(sp)
    80004ddc:	7902                	ld	s2,32(sp)
    80004dde:	69e2                	ld	s3,24(sp)
    80004de0:	6a42                	ld	s4,16(sp)
    80004de2:	6aa2                	ld	s5,8(sp)
    80004de4:	6121                	addi	sp,sp,64
    80004de6:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004de8:	85d6                	mv	a1,s5
    80004dea:	8552                	mv	a0,s4
    80004dec:	00000097          	auipc	ra,0x0
    80004df0:	34c080e7          	jalr	844(ra) # 80005138 <pipeclose>
    80004df4:	b7cd                	j	80004dd6 <fileclose+0xa8>

0000000080004df6 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004df6:	715d                	addi	sp,sp,-80
    80004df8:	e486                	sd	ra,72(sp)
    80004dfa:	e0a2                	sd	s0,64(sp)
    80004dfc:	fc26                	sd	s1,56(sp)
    80004dfe:	f84a                	sd	s2,48(sp)
    80004e00:	f44e                	sd	s3,40(sp)
    80004e02:	0880                	addi	s0,sp,80
    80004e04:	84aa                	mv	s1,a0
    80004e06:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004e08:	ffffd097          	auipc	ra,0xffffd
    80004e0c:	bbe080e7          	jalr	-1090(ra) # 800019c6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004e10:	409c                	lw	a5,0(s1)
    80004e12:	37f9                	addiw	a5,a5,-2
    80004e14:	4705                	li	a4,1
    80004e16:	04f76763          	bltu	a4,a5,80004e64 <filestat+0x6e>
    80004e1a:	892a                	mv	s2,a0
    ilock(f->ip);
    80004e1c:	6c88                	ld	a0,24(s1)
    80004e1e:	fffff097          	auipc	ra,0xfffff
    80004e22:	082080e7          	jalr	130(ra) # 80003ea0 <ilock>
    stati(f->ip, &st);
    80004e26:	fb840593          	addi	a1,s0,-72
    80004e2a:	6c88                	ld	a0,24(s1)
    80004e2c:	fffff097          	auipc	ra,0xfffff
    80004e30:	2fe080e7          	jalr	766(ra) # 8000412a <stati>
    iunlock(f->ip);
    80004e34:	6c88                	ld	a0,24(s1)
    80004e36:	fffff097          	auipc	ra,0xfffff
    80004e3a:	12c080e7          	jalr	300(ra) # 80003f62 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004e3e:	46e1                	li	a3,24
    80004e40:	fb840613          	addi	a2,s0,-72
    80004e44:	85ce                	mv	a1,s3
    80004e46:	05093503          	ld	a0,80(s2)
    80004e4a:	ffffd097          	auipc	ra,0xffffd
    80004e4e:	83a080e7          	jalr	-1990(ra) # 80001684 <copyout>
    80004e52:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004e56:	60a6                	ld	ra,72(sp)
    80004e58:	6406                	ld	s0,64(sp)
    80004e5a:	74e2                	ld	s1,56(sp)
    80004e5c:	7942                	ld	s2,48(sp)
    80004e5e:	79a2                	ld	s3,40(sp)
    80004e60:	6161                	addi	sp,sp,80
    80004e62:	8082                	ret
  return -1;
    80004e64:	557d                	li	a0,-1
    80004e66:	bfc5                	j	80004e56 <filestat+0x60>

0000000080004e68 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004e68:	7179                	addi	sp,sp,-48
    80004e6a:	f406                	sd	ra,40(sp)
    80004e6c:	f022                	sd	s0,32(sp)
    80004e6e:	ec26                	sd	s1,24(sp)
    80004e70:	e84a                	sd	s2,16(sp)
    80004e72:	e44e                	sd	s3,8(sp)
    80004e74:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004e76:	00854783          	lbu	a5,8(a0)
    80004e7a:	c3d5                	beqz	a5,80004f1e <fileread+0xb6>
    80004e7c:	84aa                	mv	s1,a0
    80004e7e:	89ae                	mv	s3,a1
    80004e80:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004e82:	411c                	lw	a5,0(a0)
    80004e84:	4705                	li	a4,1
    80004e86:	04e78963          	beq	a5,a4,80004ed8 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004e8a:	470d                	li	a4,3
    80004e8c:	04e78d63          	beq	a5,a4,80004ee6 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004e90:	4709                	li	a4,2
    80004e92:	06e79e63          	bne	a5,a4,80004f0e <fileread+0xa6>
    ilock(f->ip);
    80004e96:	6d08                	ld	a0,24(a0)
    80004e98:	fffff097          	auipc	ra,0xfffff
    80004e9c:	008080e7          	jalr	8(ra) # 80003ea0 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004ea0:	874a                	mv	a4,s2
    80004ea2:	5094                	lw	a3,32(s1)
    80004ea4:	864e                	mv	a2,s3
    80004ea6:	4585                	li	a1,1
    80004ea8:	6c88                	ld	a0,24(s1)
    80004eaa:	fffff097          	auipc	ra,0xfffff
    80004eae:	2aa080e7          	jalr	682(ra) # 80004154 <readi>
    80004eb2:	892a                	mv	s2,a0
    80004eb4:	00a05563          	blez	a0,80004ebe <fileread+0x56>
      f->off += r;
    80004eb8:	509c                	lw	a5,32(s1)
    80004eba:	9fa9                	addw	a5,a5,a0
    80004ebc:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004ebe:	6c88                	ld	a0,24(s1)
    80004ec0:	fffff097          	auipc	ra,0xfffff
    80004ec4:	0a2080e7          	jalr	162(ra) # 80003f62 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004ec8:	854a                	mv	a0,s2
    80004eca:	70a2                	ld	ra,40(sp)
    80004ecc:	7402                	ld	s0,32(sp)
    80004ece:	64e2                	ld	s1,24(sp)
    80004ed0:	6942                	ld	s2,16(sp)
    80004ed2:	69a2                	ld	s3,8(sp)
    80004ed4:	6145                	addi	sp,sp,48
    80004ed6:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004ed8:	6908                	ld	a0,16(a0)
    80004eda:	00000097          	auipc	ra,0x0
    80004ede:	3ce080e7          	jalr	974(ra) # 800052a8 <piperead>
    80004ee2:	892a                	mv	s2,a0
    80004ee4:	b7d5                	j	80004ec8 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004ee6:	02451783          	lh	a5,36(a0)
    80004eea:	03079693          	slli	a3,a5,0x30
    80004eee:	92c1                	srli	a3,a3,0x30
    80004ef0:	4725                	li	a4,9
    80004ef2:	02d76863          	bltu	a4,a3,80004f22 <fileread+0xba>
    80004ef6:	0792                	slli	a5,a5,0x4
    80004ef8:	0001e717          	auipc	a4,0x1e
    80004efc:	d1070713          	addi	a4,a4,-752 # 80022c08 <devsw>
    80004f00:	97ba                	add	a5,a5,a4
    80004f02:	639c                	ld	a5,0(a5)
    80004f04:	c38d                	beqz	a5,80004f26 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004f06:	4505                	li	a0,1
    80004f08:	9782                	jalr	a5
    80004f0a:	892a                	mv	s2,a0
    80004f0c:	bf75                	j	80004ec8 <fileread+0x60>
    panic("fileread");
    80004f0e:	00004517          	auipc	a0,0x4
    80004f12:	8ea50513          	addi	a0,a0,-1814 # 800087f8 <syscallnum+0x218>
    80004f16:	ffffb097          	auipc	ra,0xffffb
    80004f1a:	62e080e7          	jalr	1582(ra) # 80000544 <panic>
    return -1;
    80004f1e:	597d                	li	s2,-1
    80004f20:	b765                	j	80004ec8 <fileread+0x60>
      return -1;
    80004f22:	597d                	li	s2,-1
    80004f24:	b755                	j	80004ec8 <fileread+0x60>
    80004f26:	597d                	li	s2,-1
    80004f28:	b745                	j	80004ec8 <fileread+0x60>

0000000080004f2a <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004f2a:	715d                	addi	sp,sp,-80
    80004f2c:	e486                	sd	ra,72(sp)
    80004f2e:	e0a2                	sd	s0,64(sp)
    80004f30:	fc26                	sd	s1,56(sp)
    80004f32:	f84a                	sd	s2,48(sp)
    80004f34:	f44e                	sd	s3,40(sp)
    80004f36:	f052                	sd	s4,32(sp)
    80004f38:	ec56                	sd	s5,24(sp)
    80004f3a:	e85a                	sd	s6,16(sp)
    80004f3c:	e45e                	sd	s7,8(sp)
    80004f3e:	e062                	sd	s8,0(sp)
    80004f40:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004f42:	00954783          	lbu	a5,9(a0)
    80004f46:	10078663          	beqz	a5,80005052 <filewrite+0x128>
    80004f4a:	892a                	mv	s2,a0
    80004f4c:	8aae                	mv	s5,a1
    80004f4e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004f50:	411c                	lw	a5,0(a0)
    80004f52:	4705                	li	a4,1
    80004f54:	02e78263          	beq	a5,a4,80004f78 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004f58:	470d                	li	a4,3
    80004f5a:	02e78663          	beq	a5,a4,80004f86 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004f5e:	4709                	li	a4,2
    80004f60:	0ee79163          	bne	a5,a4,80005042 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004f64:	0ac05d63          	blez	a2,8000501e <filewrite+0xf4>
    int i = 0;
    80004f68:	4981                	li	s3,0
    80004f6a:	6b05                	lui	s6,0x1
    80004f6c:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004f70:	6b85                	lui	s7,0x1
    80004f72:	c00b8b9b          	addiw	s7,s7,-1024
    80004f76:	a861                	j	8000500e <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004f78:	6908                	ld	a0,16(a0)
    80004f7a:	00000097          	auipc	ra,0x0
    80004f7e:	22e080e7          	jalr	558(ra) # 800051a8 <pipewrite>
    80004f82:	8a2a                	mv	s4,a0
    80004f84:	a045                	j	80005024 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004f86:	02451783          	lh	a5,36(a0)
    80004f8a:	03079693          	slli	a3,a5,0x30
    80004f8e:	92c1                	srli	a3,a3,0x30
    80004f90:	4725                	li	a4,9
    80004f92:	0cd76263          	bltu	a4,a3,80005056 <filewrite+0x12c>
    80004f96:	0792                	slli	a5,a5,0x4
    80004f98:	0001e717          	auipc	a4,0x1e
    80004f9c:	c7070713          	addi	a4,a4,-912 # 80022c08 <devsw>
    80004fa0:	97ba                	add	a5,a5,a4
    80004fa2:	679c                	ld	a5,8(a5)
    80004fa4:	cbdd                	beqz	a5,8000505a <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004fa6:	4505                	li	a0,1
    80004fa8:	9782                	jalr	a5
    80004faa:	8a2a                	mv	s4,a0
    80004fac:	a8a5                	j	80005024 <filewrite+0xfa>
    80004fae:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004fb2:	00000097          	auipc	ra,0x0
    80004fb6:	8b0080e7          	jalr	-1872(ra) # 80004862 <begin_op>
      ilock(f->ip);
    80004fba:	01893503          	ld	a0,24(s2)
    80004fbe:	fffff097          	auipc	ra,0xfffff
    80004fc2:	ee2080e7          	jalr	-286(ra) # 80003ea0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004fc6:	8762                	mv	a4,s8
    80004fc8:	02092683          	lw	a3,32(s2)
    80004fcc:	01598633          	add	a2,s3,s5
    80004fd0:	4585                	li	a1,1
    80004fd2:	01893503          	ld	a0,24(s2)
    80004fd6:	fffff097          	auipc	ra,0xfffff
    80004fda:	276080e7          	jalr	630(ra) # 8000424c <writei>
    80004fde:	84aa                	mv	s1,a0
    80004fe0:	00a05763          	blez	a0,80004fee <filewrite+0xc4>
        f->off += r;
    80004fe4:	02092783          	lw	a5,32(s2)
    80004fe8:	9fa9                	addw	a5,a5,a0
    80004fea:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004fee:	01893503          	ld	a0,24(s2)
    80004ff2:	fffff097          	auipc	ra,0xfffff
    80004ff6:	f70080e7          	jalr	-144(ra) # 80003f62 <iunlock>
      end_op();
    80004ffa:	00000097          	auipc	ra,0x0
    80004ffe:	8e8080e7          	jalr	-1816(ra) # 800048e2 <end_op>

      if(r != n1){
    80005002:	009c1f63          	bne	s8,s1,80005020 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80005006:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000500a:	0149db63          	bge	s3,s4,80005020 <filewrite+0xf6>
      int n1 = n - i;
    8000500e:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80005012:	84be                	mv	s1,a5
    80005014:	2781                	sext.w	a5,a5
    80005016:	f8fb5ce3          	bge	s6,a5,80004fae <filewrite+0x84>
    8000501a:	84de                	mv	s1,s7
    8000501c:	bf49                	j	80004fae <filewrite+0x84>
    int i = 0;
    8000501e:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80005020:	013a1f63          	bne	s4,s3,8000503e <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80005024:	8552                	mv	a0,s4
    80005026:	60a6                	ld	ra,72(sp)
    80005028:	6406                	ld	s0,64(sp)
    8000502a:	74e2                	ld	s1,56(sp)
    8000502c:	7942                	ld	s2,48(sp)
    8000502e:	79a2                	ld	s3,40(sp)
    80005030:	7a02                	ld	s4,32(sp)
    80005032:	6ae2                	ld	s5,24(sp)
    80005034:	6b42                	ld	s6,16(sp)
    80005036:	6ba2                	ld	s7,8(sp)
    80005038:	6c02                	ld	s8,0(sp)
    8000503a:	6161                	addi	sp,sp,80
    8000503c:	8082                	ret
    ret = (i == n ? n : -1);
    8000503e:	5a7d                	li	s4,-1
    80005040:	b7d5                	j	80005024 <filewrite+0xfa>
    panic("filewrite");
    80005042:	00003517          	auipc	a0,0x3
    80005046:	7c650513          	addi	a0,a0,1990 # 80008808 <syscallnum+0x228>
    8000504a:	ffffb097          	auipc	ra,0xffffb
    8000504e:	4fa080e7          	jalr	1274(ra) # 80000544 <panic>
    return -1;
    80005052:	5a7d                	li	s4,-1
    80005054:	bfc1                	j	80005024 <filewrite+0xfa>
      return -1;
    80005056:	5a7d                	li	s4,-1
    80005058:	b7f1                	j	80005024 <filewrite+0xfa>
    8000505a:	5a7d                	li	s4,-1
    8000505c:	b7e1                	j	80005024 <filewrite+0xfa>

000000008000505e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000505e:	7179                	addi	sp,sp,-48
    80005060:	f406                	sd	ra,40(sp)
    80005062:	f022                	sd	s0,32(sp)
    80005064:	ec26                	sd	s1,24(sp)
    80005066:	e84a                	sd	s2,16(sp)
    80005068:	e44e                	sd	s3,8(sp)
    8000506a:	e052                	sd	s4,0(sp)
    8000506c:	1800                	addi	s0,sp,48
    8000506e:	84aa                	mv	s1,a0
    80005070:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005072:	0005b023          	sd	zero,0(a1)
    80005076:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000507a:	00000097          	auipc	ra,0x0
    8000507e:	bf8080e7          	jalr	-1032(ra) # 80004c72 <filealloc>
    80005082:	e088                	sd	a0,0(s1)
    80005084:	c551                	beqz	a0,80005110 <pipealloc+0xb2>
    80005086:	00000097          	auipc	ra,0x0
    8000508a:	bec080e7          	jalr	-1044(ra) # 80004c72 <filealloc>
    8000508e:	00aa3023          	sd	a0,0(s4)
    80005092:	c92d                	beqz	a0,80005104 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80005094:	ffffc097          	auipc	ra,0xffffc
    80005098:	a66080e7          	jalr	-1434(ra) # 80000afa <kalloc>
    8000509c:	892a                	mv	s2,a0
    8000509e:	c125                	beqz	a0,800050fe <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800050a0:	4985                	li	s3,1
    800050a2:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800050a6:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800050aa:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800050ae:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800050b2:	00003597          	auipc	a1,0x3
    800050b6:	35e58593          	addi	a1,a1,862 # 80008410 <digits+0x3d0>
    800050ba:	ffffc097          	auipc	ra,0xffffc
    800050be:	aa0080e7          	jalr	-1376(ra) # 80000b5a <initlock>
  (*f0)->type = FD_PIPE;
    800050c2:	609c                	ld	a5,0(s1)
    800050c4:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800050c8:	609c                	ld	a5,0(s1)
    800050ca:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800050ce:	609c                	ld	a5,0(s1)
    800050d0:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800050d4:	609c                	ld	a5,0(s1)
    800050d6:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800050da:	000a3783          	ld	a5,0(s4)
    800050de:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800050e2:	000a3783          	ld	a5,0(s4)
    800050e6:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800050ea:	000a3783          	ld	a5,0(s4)
    800050ee:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800050f2:	000a3783          	ld	a5,0(s4)
    800050f6:	0127b823          	sd	s2,16(a5)
  return 0;
    800050fa:	4501                	li	a0,0
    800050fc:	a025                	j	80005124 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800050fe:	6088                	ld	a0,0(s1)
    80005100:	e501                	bnez	a0,80005108 <pipealloc+0xaa>
    80005102:	a039                	j	80005110 <pipealloc+0xb2>
    80005104:	6088                	ld	a0,0(s1)
    80005106:	c51d                	beqz	a0,80005134 <pipealloc+0xd6>
    fileclose(*f0);
    80005108:	00000097          	auipc	ra,0x0
    8000510c:	c26080e7          	jalr	-986(ra) # 80004d2e <fileclose>
  if(*f1)
    80005110:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005114:	557d                	li	a0,-1
  if(*f1)
    80005116:	c799                	beqz	a5,80005124 <pipealloc+0xc6>
    fileclose(*f1);
    80005118:	853e                	mv	a0,a5
    8000511a:	00000097          	auipc	ra,0x0
    8000511e:	c14080e7          	jalr	-1004(ra) # 80004d2e <fileclose>
  return -1;
    80005122:	557d                	li	a0,-1
}
    80005124:	70a2                	ld	ra,40(sp)
    80005126:	7402                	ld	s0,32(sp)
    80005128:	64e2                	ld	s1,24(sp)
    8000512a:	6942                	ld	s2,16(sp)
    8000512c:	69a2                	ld	s3,8(sp)
    8000512e:	6a02                	ld	s4,0(sp)
    80005130:	6145                	addi	sp,sp,48
    80005132:	8082                	ret
  return -1;
    80005134:	557d                	li	a0,-1
    80005136:	b7fd                	j	80005124 <pipealloc+0xc6>

0000000080005138 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005138:	1101                	addi	sp,sp,-32
    8000513a:	ec06                	sd	ra,24(sp)
    8000513c:	e822                	sd	s0,16(sp)
    8000513e:	e426                	sd	s1,8(sp)
    80005140:	e04a                	sd	s2,0(sp)
    80005142:	1000                	addi	s0,sp,32
    80005144:	84aa                	mv	s1,a0
    80005146:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005148:	ffffc097          	auipc	ra,0xffffc
    8000514c:	aa2080e7          	jalr	-1374(ra) # 80000bea <acquire>
  if(writable){
    80005150:	02090d63          	beqz	s2,8000518a <pipeclose+0x52>
    pi->writeopen = 0;
    80005154:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005158:	21848513          	addi	a0,s1,536
    8000515c:	ffffd097          	auipc	ra,0xffffd
    80005160:	46c080e7          	jalr	1132(ra) # 800025c8 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005164:	2204b783          	ld	a5,544(s1)
    80005168:	eb95                	bnez	a5,8000519c <pipeclose+0x64>
    release(&pi->lock);
    8000516a:	8526                	mv	a0,s1
    8000516c:	ffffc097          	auipc	ra,0xffffc
    80005170:	b32080e7          	jalr	-1230(ra) # 80000c9e <release>
    kfree((char*)pi);
    80005174:	8526                	mv	a0,s1
    80005176:	ffffc097          	auipc	ra,0xffffc
    8000517a:	888080e7          	jalr	-1912(ra) # 800009fe <kfree>
  } else
    release(&pi->lock);
}
    8000517e:	60e2                	ld	ra,24(sp)
    80005180:	6442                	ld	s0,16(sp)
    80005182:	64a2                	ld	s1,8(sp)
    80005184:	6902                	ld	s2,0(sp)
    80005186:	6105                	addi	sp,sp,32
    80005188:	8082                	ret
    pi->readopen = 0;
    8000518a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000518e:	21c48513          	addi	a0,s1,540
    80005192:	ffffd097          	auipc	ra,0xffffd
    80005196:	436080e7          	jalr	1078(ra) # 800025c8 <wakeup>
    8000519a:	b7e9                	j	80005164 <pipeclose+0x2c>
    release(&pi->lock);
    8000519c:	8526                	mv	a0,s1
    8000519e:	ffffc097          	auipc	ra,0xffffc
    800051a2:	b00080e7          	jalr	-1280(ra) # 80000c9e <release>
}
    800051a6:	bfe1                	j	8000517e <pipeclose+0x46>

00000000800051a8 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800051a8:	7159                	addi	sp,sp,-112
    800051aa:	f486                	sd	ra,104(sp)
    800051ac:	f0a2                	sd	s0,96(sp)
    800051ae:	eca6                	sd	s1,88(sp)
    800051b0:	e8ca                	sd	s2,80(sp)
    800051b2:	e4ce                	sd	s3,72(sp)
    800051b4:	e0d2                	sd	s4,64(sp)
    800051b6:	fc56                	sd	s5,56(sp)
    800051b8:	f85a                	sd	s6,48(sp)
    800051ba:	f45e                	sd	s7,40(sp)
    800051bc:	f062                	sd	s8,32(sp)
    800051be:	ec66                	sd	s9,24(sp)
    800051c0:	1880                	addi	s0,sp,112
    800051c2:	84aa                	mv	s1,a0
    800051c4:	8aae                	mv	s5,a1
    800051c6:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800051c8:	ffffc097          	auipc	ra,0xffffc
    800051cc:	7fe080e7          	jalr	2046(ra) # 800019c6 <myproc>
    800051d0:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800051d2:	8526                	mv	a0,s1
    800051d4:	ffffc097          	auipc	ra,0xffffc
    800051d8:	a16080e7          	jalr	-1514(ra) # 80000bea <acquire>
  while(i < n){
    800051dc:	0d405463          	blez	s4,800052a4 <pipewrite+0xfc>
    800051e0:	8ba6                	mv	s7,s1
  int i = 0;
    800051e2:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800051e4:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800051e6:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800051ea:	21c48c13          	addi	s8,s1,540
    800051ee:	a08d                	j	80005250 <pipewrite+0xa8>
      release(&pi->lock);
    800051f0:	8526                	mv	a0,s1
    800051f2:	ffffc097          	auipc	ra,0xffffc
    800051f6:	aac080e7          	jalr	-1364(ra) # 80000c9e <release>
      return -1;
    800051fa:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800051fc:	854a                	mv	a0,s2
    800051fe:	70a6                	ld	ra,104(sp)
    80005200:	7406                	ld	s0,96(sp)
    80005202:	64e6                	ld	s1,88(sp)
    80005204:	6946                	ld	s2,80(sp)
    80005206:	69a6                	ld	s3,72(sp)
    80005208:	6a06                	ld	s4,64(sp)
    8000520a:	7ae2                	ld	s5,56(sp)
    8000520c:	7b42                	ld	s6,48(sp)
    8000520e:	7ba2                	ld	s7,40(sp)
    80005210:	7c02                	ld	s8,32(sp)
    80005212:	6ce2                	ld	s9,24(sp)
    80005214:	6165                	addi	sp,sp,112
    80005216:	8082                	ret
      wakeup(&pi->nread);
    80005218:	8566                	mv	a0,s9
    8000521a:	ffffd097          	auipc	ra,0xffffd
    8000521e:	3ae080e7          	jalr	942(ra) # 800025c8 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005222:	85de                	mv	a1,s7
    80005224:	8562                	mv	a0,s8
    80005226:	ffffd097          	auipc	ra,0xffffd
    8000522a:	1f2080e7          	jalr	498(ra) # 80002418 <sleep>
    8000522e:	a839                	j	8000524c <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005230:	21c4a783          	lw	a5,540(s1)
    80005234:	0017871b          	addiw	a4,a5,1
    80005238:	20e4ae23          	sw	a4,540(s1)
    8000523c:	1ff7f793          	andi	a5,a5,511
    80005240:	97a6                	add	a5,a5,s1
    80005242:	f9f44703          	lbu	a4,-97(s0)
    80005246:	00e78c23          	sb	a4,24(a5)
      i++;
    8000524a:	2905                	addiw	s2,s2,1
  while(i < n){
    8000524c:	05495063          	bge	s2,s4,8000528c <pipewrite+0xe4>
    if(pi->readopen == 0 || killed(pr)){
    80005250:	2204a783          	lw	a5,544(s1)
    80005254:	dfd1                	beqz	a5,800051f0 <pipewrite+0x48>
    80005256:	854e                	mv	a0,s3
    80005258:	ffffd097          	auipc	ra,0xffffd
    8000525c:	5c0080e7          	jalr	1472(ra) # 80002818 <killed>
    80005260:	f941                	bnez	a0,800051f0 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005262:	2184a783          	lw	a5,536(s1)
    80005266:	21c4a703          	lw	a4,540(s1)
    8000526a:	2007879b          	addiw	a5,a5,512
    8000526e:	faf705e3          	beq	a4,a5,80005218 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005272:	4685                	li	a3,1
    80005274:	01590633          	add	a2,s2,s5
    80005278:	f9f40593          	addi	a1,s0,-97
    8000527c:	0509b503          	ld	a0,80(s3)
    80005280:	ffffc097          	auipc	ra,0xffffc
    80005284:	490080e7          	jalr	1168(ra) # 80001710 <copyin>
    80005288:	fb6514e3          	bne	a0,s6,80005230 <pipewrite+0x88>
  wakeup(&pi->nread);
    8000528c:	21848513          	addi	a0,s1,536
    80005290:	ffffd097          	auipc	ra,0xffffd
    80005294:	338080e7          	jalr	824(ra) # 800025c8 <wakeup>
  release(&pi->lock);
    80005298:	8526                	mv	a0,s1
    8000529a:	ffffc097          	auipc	ra,0xffffc
    8000529e:	a04080e7          	jalr	-1532(ra) # 80000c9e <release>
  return i;
    800052a2:	bfa9                	j	800051fc <pipewrite+0x54>
  int i = 0;
    800052a4:	4901                	li	s2,0
    800052a6:	b7dd                	j	8000528c <pipewrite+0xe4>

00000000800052a8 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800052a8:	715d                	addi	sp,sp,-80
    800052aa:	e486                	sd	ra,72(sp)
    800052ac:	e0a2                	sd	s0,64(sp)
    800052ae:	fc26                	sd	s1,56(sp)
    800052b0:	f84a                	sd	s2,48(sp)
    800052b2:	f44e                	sd	s3,40(sp)
    800052b4:	f052                	sd	s4,32(sp)
    800052b6:	ec56                	sd	s5,24(sp)
    800052b8:	e85a                	sd	s6,16(sp)
    800052ba:	0880                	addi	s0,sp,80
    800052bc:	84aa                	mv	s1,a0
    800052be:	892e                	mv	s2,a1
    800052c0:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800052c2:	ffffc097          	auipc	ra,0xffffc
    800052c6:	704080e7          	jalr	1796(ra) # 800019c6 <myproc>
    800052ca:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800052cc:	8b26                	mv	s6,s1
    800052ce:	8526                	mv	a0,s1
    800052d0:	ffffc097          	auipc	ra,0xffffc
    800052d4:	91a080e7          	jalr	-1766(ra) # 80000bea <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800052d8:	2184a703          	lw	a4,536(s1)
    800052dc:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800052e0:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800052e4:	02f71763          	bne	a4,a5,80005312 <piperead+0x6a>
    800052e8:	2244a783          	lw	a5,548(s1)
    800052ec:	c39d                	beqz	a5,80005312 <piperead+0x6a>
    if(killed(pr)){
    800052ee:	8552                	mv	a0,s4
    800052f0:	ffffd097          	auipc	ra,0xffffd
    800052f4:	528080e7          	jalr	1320(ra) # 80002818 <killed>
    800052f8:	e941                	bnez	a0,80005388 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800052fa:	85da                	mv	a1,s6
    800052fc:	854e                	mv	a0,s3
    800052fe:	ffffd097          	auipc	ra,0xffffd
    80005302:	11a080e7          	jalr	282(ra) # 80002418 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005306:	2184a703          	lw	a4,536(s1)
    8000530a:	21c4a783          	lw	a5,540(s1)
    8000530e:	fcf70de3          	beq	a4,a5,800052e8 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005312:	09505263          	blez	s5,80005396 <piperead+0xee>
    80005316:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005318:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    8000531a:	2184a783          	lw	a5,536(s1)
    8000531e:	21c4a703          	lw	a4,540(s1)
    80005322:	02f70d63          	beq	a4,a5,8000535c <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005326:	0017871b          	addiw	a4,a5,1
    8000532a:	20e4ac23          	sw	a4,536(s1)
    8000532e:	1ff7f793          	andi	a5,a5,511
    80005332:	97a6                	add	a5,a5,s1
    80005334:	0187c783          	lbu	a5,24(a5)
    80005338:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000533c:	4685                	li	a3,1
    8000533e:	fbf40613          	addi	a2,s0,-65
    80005342:	85ca                	mv	a1,s2
    80005344:	050a3503          	ld	a0,80(s4)
    80005348:	ffffc097          	auipc	ra,0xffffc
    8000534c:	33c080e7          	jalr	828(ra) # 80001684 <copyout>
    80005350:	01650663          	beq	a0,s6,8000535c <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005354:	2985                	addiw	s3,s3,1
    80005356:	0905                	addi	s2,s2,1
    80005358:	fd3a91e3          	bne	s5,s3,8000531a <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000535c:	21c48513          	addi	a0,s1,540
    80005360:	ffffd097          	auipc	ra,0xffffd
    80005364:	268080e7          	jalr	616(ra) # 800025c8 <wakeup>
  release(&pi->lock);
    80005368:	8526                	mv	a0,s1
    8000536a:	ffffc097          	auipc	ra,0xffffc
    8000536e:	934080e7          	jalr	-1740(ra) # 80000c9e <release>
  return i;
}
    80005372:	854e                	mv	a0,s3
    80005374:	60a6                	ld	ra,72(sp)
    80005376:	6406                	ld	s0,64(sp)
    80005378:	74e2                	ld	s1,56(sp)
    8000537a:	7942                	ld	s2,48(sp)
    8000537c:	79a2                	ld	s3,40(sp)
    8000537e:	7a02                	ld	s4,32(sp)
    80005380:	6ae2                	ld	s5,24(sp)
    80005382:	6b42                	ld	s6,16(sp)
    80005384:	6161                	addi	sp,sp,80
    80005386:	8082                	ret
      release(&pi->lock);
    80005388:	8526                	mv	a0,s1
    8000538a:	ffffc097          	auipc	ra,0xffffc
    8000538e:	914080e7          	jalr	-1772(ra) # 80000c9e <release>
      return -1;
    80005392:	59fd                	li	s3,-1
    80005394:	bff9                	j	80005372 <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005396:	4981                	li	s3,0
    80005398:	b7d1                	j	8000535c <piperead+0xb4>

000000008000539a <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    8000539a:	1141                	addi	sp,sp,-16
    8000539c:	e422                	sd	s0,8(sp)
    8000539e:	0800                	addi	s0,sp,16
    800053a0:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800053a2:	8905                	andi	a0,a0,1
    800053a4:	c111                	beqz	a0,800053a8 <flags2perm+0xe>
      perm = PTE_X;
    800053a6:	4521                	li	a0,8
    if(flags & 0x2)
    800053a8:	8b89                	andi	a5,a5,2
    800053aa:	c399                	beqz	a5,800053b0 <flags2perm+0x16>
      perm |= PTE_W;
    800053ac:	00456513          	ori	a0,a0,4
    return perm;
}
    800053b0:	6422                	ld	s0,8(sp)
    800053b2:	0141                	addi	sp,sp,16
    800053b4:	8082                	ret

00000000800053b6 <exec>:

int
exec(char *path, char **argv)
{
    800053b6:	df010113          	addi	sp,sp,-528
    800053ba:	20113423          	sd	ra,520(sp)
    800053be:	20813023          	sd	s0,512(sp)
    800053c2:	ffa6                	sd	s1,504(sp)
    800053c4:	fbca                	sd	s2,496(sp)
    800053c6:	f7ce                	sd	s3,488(sp)
    800053c8:	f3d2                	sd	s4,480(sp)
    800053ca:	efd6                	sd	s5,472(sp)
    800053cc:	ebda                	sd	s6,464(sp)
    800053ce:	e7de                	sd	s7,456(sp)
    800053d0:	e3e2                	sd	s8,448(sp)
    800053d2:	ff66                	sd	s9,440(sp)
    800053d4:	fb6a                	sd	s10,432(sp)
    800053d6:	f76e                	sd	s11,424(sp)
    800053d8:	0c00                	addi	s0,sp,528
    800053da:	84aa                	mv	s1,a0
    800053dc:	dea43c23          	sd	a0,-520(s0)
    800053e0:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800053e4:	ffffc097          	auipc	ra,0xffffc
    800053e8:	5e2080e7          	jalr	1506(ra) # 800019c6 <myproc>
    800053ec:	892a                	mv	s2,a0

  begin_op();
    800053ee:	fffff097          	auipc	ra,0xfffff
    800053f2:	474080e7          	jalr	1140(ra) # 80004862 <begin_op>

  if((ip = namei(path)) == 0){
    800053f6:	8526                	mv	a0,s1
    800053f8:	fffff097          	auipc	ra,0xfffff
    800053fc:	24e080e7          	jalr	590(ra) # 80004646 <namei>
    80005400:	c92d                	beqz	a0,80005472 <exec+0xbc>
    80005402:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005404:	fffff097          	auipc	ra,0xfffff
    80005408:	a9c080e7          	jalr	-1380(ra) # 80003ea0 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000540c:	04000713          	li	a4,64
    80005410:	4681                	li	a3,0
    80005412:	e5040613          	addi	a2,s0,-432
    80005416:	4581                	li	a1,0
    80005418:	8526                	mv	a0,s1
    8000541a:	fffff097          	auipc	ra,0xfffff
    8000541e:	d3a080e7          	jalr	-710(ra) # 80004154 <readi>
    80005422:	04000793          	li	a5,64
    80005426:	00f51a63          	bne	a0,a5,8000543a <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    8000542a:	e5042703          	lw	a4,-432(s0)
    8000542e:	464c47b7          	lui	a5,0x464c4
    80005432:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005436:	04f70463          	beq	a4,a5,8000547e <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000543a:	8526                	mv	a0,s1
    8000543c:	fffff097          	auipc	ra,0xfffff
    80005440:	cc6080e7          	jalr	-826(ra) # 80004102 <iunlockput>
    end_op();
    80005444:	fffff097          	auipc	ra,0xfffff
    80005448:	49e080e7          	jalr	1182(ra) # 800048e2 <end_op>
  }
  return -1;
    8000544c:	557d                	li	a0,-1
}
    8000544e:	20813083          	ld	ra,520(sp)
    80005452:	20013403          	ld	s0,512(sp)
    80005456:	74fe                	ld	s1,504(sp)
    80005458:	795e                	ld	s2,496(sp)
    8000545a:	79be                	ld	s3,488(sp)
    8000545c:	7a1e                	ld	s4,480(sp)
    8000545e:	6afe                	ld	s5,472(sp)
    80005460:	6b5e                	ld	s6,464(sp)
    80005462:	6bbe                	ld	s7,456(sp)
    80005464:	6c1e                	ld	s8,448(sp)
    80005466:	7cfa                	ld	s9,440(sp)
    80005468:	7d5a                	ld	s10,432(sp)
    8000546a:	7dba                	ld	s11,424(sp)
    8000546c:	21010113          	addi	sp,sp,528
    80005470:	8082                	ret
    end_op();
    80005472:	fffff097          	auipc	ra,0xfffff
    80005476:	470080e7          	jalr	1136(ra) # 800048e2 <end_op>
    return -1;
    8000547a:	557d                	li	a0,-1
    8000547c:	bfc9                	j	8000544e <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    8000547e:	854a                	mv	a0,s2
    80005480:	ffffc097          	auipc	ra,0xffffc
    80005484:	60a080e7          	jalr	1546(ra) # 80001a8a <proc_pagetable>
    80005488:	8baa                	mv	s7,a0
    8000548a:	d945                	beqz	a0,8000543a <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000548c:	e7042983          	lw	s3,-400(s0)
    80005490:	e8845783          	lhu	a5,-376(s0)
    80005494:	c7ad                	beqz	a5,800054fe <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005496:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005498:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    8000549a:	6c85                	lui	s9,0x1
    8000549c:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800054a0:	def43823          	sd	a5,-528(s0)
    800054a4:	ac0d                	j	800056d6 <exec+0x320>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800054a6:	00003517          	auipc	a0,0x3
    800054aa:	37250513          	addi	a0,a0,882 # 80008818 <syscallnum+0x238>
    800054ae:	ffffb097          	auipc	ra,0xffffb
    800054b2:	096080e7          	jalr	150(ra) # 80000544 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800054b6:	8756                	mv	a4,s5
    800054b8:	012d86bb          	addw	a3,s11,s2
    800054bc:	4581                	li	a1,0
    800054be:	8526                	mv	a0,s1
    800054c0:	fffff097          	auipc	ra,0xfffff
    800054c4:	c94080e7          	jalr	-876(ra) # 80004154 <readi>
    800054c8:	2501                	sext.w	a0,a0
    800054ca:	1aaa9a63          	bne	s5,a0,8000567e <exec+0x2c8>
  for(i = 0; i < sz; i += PGSIZE){
    800054ce:	6785                	lui	a5,0x1
    800054d0:	0127893b          	addw	s2,a5,s2
    800054d4:	77fd                	lui	a5,0xfffff
    800054d6:	01478a3b          	addw	s4,a5,s4
    800054da:	1f897563          	bgeu	s2,s8,800056c4 <exec+0x30e>
    pa = walkaddr(pagetable, va + i);
    800054de:	02091593          	slli	a1,s2,0x20
    800054e2:	9181                	srli	a1,a1,0x20
    800054e4:	95ea                	add	a1,a1,s10
    800054e6:	855e                	mv	a0,s7
    800054e8:	ffffc097          	auipc	ra,0xffffc
    800054ec:	b90080e7          	jalr	-1136(ra) # 80001078 <walkaddr>
    800054f0:	862a                	mv	a2,a0
    if(pa == 0)
    800054f2:	d955                	beqz	a0,800054a6 <exec+0xf0>
      n = PGSIZE;
    800054f4:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    800054f6:	fd9a70e3          	bgeu	s4,s9,800054b6 <exec+0x100>
      n = sz - i;
    800054fa:	8ad2                	mv	s5,s4
    800054fc:	bf6d                	j	800054b6 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800054fe:	4a01                	li	s4,0
  iunlockput(ip);
    80005500:	8526                	mv	a0,s1
    80005502:	fffff097          	auipc	ra,0xfffff
    80005506:	c00080e7          	jalr	-1024(ra) # 80004102 <iunlockput>
  end_op();
    8000550a:	fffff097          	auipc	ra,0xfffff
    8000550e:	3d8080e7          	jalr	984(ra) # 800048e2 <end_op>
  p = myproc();
    80005512:	ffffc097          	auipc	ra,0xffffc
    80005516:	4b4080e7          	jalr	1204(ra) # 800019c6 <myproc>
    8000551a:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    8000551c:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005520:	6785                	lui	a5,0x1
    80005522:	17fd                	addi	a5,a5,-1
    80005524:	9a3e                	add	s4,s4,a5
    80005526:	757d                	lui	a0,0xfffff
    80005528:	00aa77b3          	and	a5,s4,a0
    8000552c:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005530:	4691                	li	a3,4
    80005532:	6609                	lui	a2,0x2
    80005534:	963e                	add	a2,a2,a5
    80005536:	85be                	mv	a1,a5
    80005538:	855e                	mv	a0,s7
    8000553a:	ffffc097          	auipc	ra,0xffffc
    8000553e:	ef2080e7          	jalr	-270(ra) # 8000142c <uvmalloc>
    80005542:	8b2a                	mv	s6,a0
  ip = 0;
    80005544:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005546:	12050c63          	beqz	a0,8000567e <exec+0x2c8>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000554a:	75f9                	lui	a1,0xffffe
    8000554c:	95aa                	add	a1,a1,a0
    8000554e:	855e                	mv	a0,s7
    80005550:	ffffc097          	auipc	ra,0xffffc
    80005554:	102080e7          	jalr	258(ra) # 80001652 <uvmclear>
  stackbase = sp - PGSIZE;
    80005558:	7c7d                	lui	s8,0xfffff
    8000555a:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    8000555c:	e0043783          	ld	a5,-512(s0)
    80005560:	6388                	ld	a0,0(a5)
    80005562:	c535                	beqz	a0,800055ce <exec+0x218>
    80005564:	e9040993          	addi	s3,s0,-368
    80005568:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    8000556c:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    8000556e:	ffffc097          	auipc	ra,0xffffc
    80005572:	8fc080e7          	jalr	-1796(ra) # 80000e6a <strlen>
    80005576:	2505                	addiw	a0,a0,1
    80005578:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000557c:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005580:	13896663          	bltu	s2,s8,800056ac <exec+0x2f6>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005584:	e0043d83          	ld	s11,-512(s0)
    80005588:	000dba03          	ld	s4,0(s11)
    8000558c:	8552                	mv	a0,s4
    8000558e:	ffffc097          	auipc	ra,0xffffc
    80005592:	8dc080e7          	jalr	-1828(ra) # 80000e6a <strlen>
    80005596:	0015069b          	addiw	a3,a0,1
    8000559a:	8652                	mv	a2,s4
    8000559c:	85ca                	mv	a1,s2
    8000559e:	855e                	mv	a0,s7
    800055a0:	ffffc097          	auipc	ra,0xffffc
    800055a4:	0e4080e7          	jalr	228(ra) # 80001684 <copyout>
    800055a8:	10054663          	bltz	a0,800056b4 <exec+0x2fe>
    ustack[argc] = sp;
    800055ac:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800055b0:	0485                	addi	s1,s1,1
    800055b2:	008d8793          	addi	a5,s11,8
    800055b6:	e0f43023          	sd	a5,-512(s0)
    800055ba:	008db503          	ld	a0,8(s11)
    800055be:	c911                	beqz	a0,800055d2 <exec+0x21c>
    if(argc >= MAXARG)
    800055c0:	09a1                	addi	s3,s3,8
    800055c2:	fb3c96e3          	bne	s9,s3,8000556e <exec+0x1b8>
  sz = sz1;
    800055c6:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800055ca:	4481                	li	s1,0
    800055cc:	a84d                	j	8000567e <exec+0x2c8>
  sp = sz;
    800055ce:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    800055d0:	4481                	li	s1,0
  ustack[argc] = 0;
    800055d2:	00349793          	slli	a5,s1,0x3
    800055d6:	f9040713          	addi	a4,s0,-112
    800055da:	97ba                	add	a5,a5,a4
    800055dc:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    800055e0:	00148693          	addi	a3,s1,1
    800055e4:	068e                	slli	a3,a3,0x3
    800055e6:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800055ea:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800055ee:	01897663          	bgeu	s2,s8,800055fa <exec+0x244>
  sz = sz1;
    800055f2:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800055f6:	4481                	li	s1,0
    800055f8:	a059                	j	8000567e <exec+0x2c8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800055fa:	e9040613          	addi	a2,s0,-368
    800055fe:	85ca                	mv	a1,s2
    80005600:	855e                	mv	a0,s7
    80005602:	ffffc097          	auipc	ra,0xffffc
    80005606:	082080e7          	jalr	130(ra) # 80001684 <copyout>
    8000560a:	0a054963          	bltz	a0,800056bc <exec+0x306>
  p->trapframe->a1 = sp;
    8000560e:	058ab783          	ld	a5,88(s5)
    80005612:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005616:	df843783          	ld	a5,-520(s0)
    8000561a:	0007c703          	lbu	a4,0(a5)
    8000561e:	cf11                	beqz	a4,8000563a <exec+0x284>
    80005620:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005622:	02f00693          	li	a3,47
    80005626:	a039                	j	80005634 <exec+0x27e>
      last = s+1;
    80005628:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    8000562c:	0785                	addi	a5,a5,1
    8000562e:	fff7c703          	lbu	a4,-1(a5)
    80005632:	c701                	beqz	a4,8000563a <exec+0x284>
    if(*s == '/')
    80005634:	fed71ce3          	bne	a4,a3,8000562c <exec+0x276>
    80005638:	bfc5                	j	80005628 <exec+0x272>
  safestrcpy(p->name, last, sizeof(p->name));
    8000563a:	4641                	li	a2,16
    8000563c:	df843583          	ld	a1,-520(s0)
    80005640:	158a8513          	addi	a0,s5,344
    80005644:	ffffb097          	auipc	ra,0xffffb
    80005648:	7f4080e7          	jalr	2036(ra) # 80000e38 <safestrcpy>
  oldpagetable = p->pagetable;
    8000564c:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80005650:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    80005654:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005658:	058ab783          	ld	a5,88(s5)
    8000565c:	e6843703          	ld	a4,-408(s0)
    80005660:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005662:	058ab783          	ld	a5,88(s5)
    80005666:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000566a:	85ea                	mv	a1,s10
    8000566c:	ffffc097          	auipc	ra,0xffffc
    80005670:	4ba080e7          	jalr	1210(ra) # 80001b26 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005674:	0004851b          	sext.w	a0,s1
    80005678:	bbd9                	j	8000544e <exec+0x98>
    8000567a:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    8000567e:	e0843583          	ld	a1,-504(s0)
    80005682:	855e                	mv	a0,s7
    80005684:	ffffc097          	auipc	ra,0xffffc
    80005688:	4a2080e7          	jalr	1186(ra) # 80001b26 <proc_freepagetable>
  if(ip){
    8000568c:	da0497e3          	bnez	s1,8000543a <exec+0x84>
  return -1;
    80005690:	557d                	li	a0,-1
    80005692:	bb75                	j	8000544e <exec+0x98>
    80005694:	e1443423          	sd	s4,-504(s0)
    80005698:	b7dd                	j	8000567e <exec+0x2c8>
    8000569a:	e1443423          	sd	s4,-504(s0)
    8000569e:	b7c5                	j	8000567e <exec+0x2c8>
    800056a0:	e1443423          	sd	s4,-504(s0)
    800056a4:	bfe9                	j	8000567e <exec+0x2c8>
    800056a6:	e1443423          	sd	s4,-504(s0)
    800056aa:	bfd1                	j	8000567e <exec+0x2c8>
  sz = sz1;
    800056ac:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800056b0:	4481                	li	s1,0
    800056b2:	b7f1                	j	8000567e <exec+0x2c8>
  sz = sz1;
    800056b4:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800056b8:	4481                	li	s1,0
    800056ba:	b7d1                	j	8000567e <exec+0x2c8>
  sz = sz1;
    800056bc:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800056c0:	4481                	li	s1,0
    800056c2:	bf75                	j	8000567e <exec+0x2c8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800056c4:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800056c8:	2b05                	addiw	s6,s6,1
    800056ca:	0389899b          	addiw	s3,s3,56
    800056ce:	e8845783          	lhu	a5,-376(s0)
    800056d2:	e2fb57e3          	bge	s6,a5,80005500 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800056d6:	2981                	sext.w	s3,s3
    800056d8:	03800713          	li	a4,56
    800056dc:	86ce                	mv	a3,s3
    800056de:	e1840613          	addi	a2,s0,-488
    800056e2:	4581                	li	a1,0
    800056e4:	8526                	mv	a0,s1
    800056e6:	fffff097          	auipc	ra,0xfffff
    800056ea:	a6e080e7          	jalr	-1426(ra) # 80004154 <readi>
    800056ee:	03800793          	li	a5,56
    800056f2:	f8f514e3          	bne	a0,a5,8000567a <exec+0x2c4>
    if(ph.type != ELF_PROG_LOAD)
    800056f6:	e1842783          	lw	a5,-488(s0)
    800056fa:	4705                	li	a4,1
    800056fc:	fce796e3          	bne	a5,a4,800056c8 <exec+0x312>
    if(ph.memsz < ph.filesz)
    80005700:	e4043903          	ld	s2,-448(s0)
    80005704:	e3843783          	ld	a5,-456(s0)
    80005708:	f8f966e3          	bltu	s2,a5,80005694 <exec+0x2de>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000570c:	e2843783          	ld	a5,-472(s0)
    80005710:	993e                	add	s2,s2,a5
    80005712:	f8f964e3          	bltu	s2,a5,8000569a <exec+0x2e4>
    if(ph.vaddr % PGSIZE != 0)
    80005716:	df043703          	ld	a4,-528(s0)
    8000571a:	8ff9                	and	a5,a5,a4
    8000571c:	f3d1                	bnez	a5,800056a0 <exec+0x2ea>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000571e:	e1c42503          	lw	a0,-484(s0)
    80005722:	00000097          	auipc	ra,0x0
    80005726:	c78080e7          	jalr	-904(ra) # 8000539a <flags2perm>
    8000572a:	86aa                	mv	a3,a0
    8000572c:	864a                	mv	a2,s2
    8000572e:	85d2                	mv	a1,s4
    80005730:	855e                	mv	a0,s7
    80005732:	ffffc097          	auipc	ra,0xffffc
    80005736:	cfa080e7          	jalr	-774(ra) # 8000142c <uvmalloc>
    8000573a:	e0a43423          	sd	a0,-504(s0)
    8000573e:	d525                	beqz	a0,800056a6 <exec+0x2f0>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005740:	e2843d03          	ld	s10,-472(s0)
    80005744:	e2042d83          	lw	s11,-480(s0)
    80005748:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000574c:	f60c0ce3          	beqz	s8,800056c4 <exec+0x30e>
    80005750:	8a62                	mv	s4,s8
    80005752:	4901                	li	s2,0
    80005754:	b369                	j	800054de <exec+0x128>

0000000080005756 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005756:	7179                	addi	sp,sp,-48
    80005758:	f406                	sd	ra,40(sp)
    8000575a:	f022                	sd	s0,32(sp)
    8000575c:	ec26                	sd	s1,24(sp)
    8000575e:	e84a                	sd	s2,16(sp)
    80005760:	1800                	addi	s0,sp,48
    80005762:	892e                	mv	s2,a1
    80005764:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005766:	fdc40593          	addi	a1,s0,-36
    8000576a:	ffffe097          	auipc	ra,0xffffe
    8000576e:	924080e7          	jalr	-1756(ra) # 8000308e <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005772:	fdc42703          	lw	a4,-36(s0)
    80005776:	47bd                	li	a5,15
    80005778:	02e7eb63          	bltu	a5,a4,800057ae <argfd+0x58>
    8000577c:	ffffc097          	auipc	ra,0xffffc
    80005780:	24a080e7          	jalr	586(ra) # 800019c6 <myproc>
    80005784:	fdc42703          	lw	a4,-36(s0)
    80005788:	01a70793          	addi	a5,a4,26
    8000578c:	078e                	slli	a5,a5,0x3
    8000578e:	953e                	add	a0,a0,a5
    80005790:	611c                	ld	a5,0(a0)
    80005792:	c385                	beqz	a5,800057b2 <argfd+0x5c>
    return -1;
  if(pfd)
    80005794:	00090463          	beqz	s2,8000579c <argfd+0x46>
    *pfd = fd;
    80005798:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000579c:	4501                	li	a0,0
  if(pf)
    8000579e:	c091                	beqz	s1,800057a2 <argfd+0x4c>
    *pf = f;
    800057a0:	e09c                	sd	a5,0(s1)
}
    800057a2:	70a2                	ld	ra,40(sp)
    800057a4:	7402                	ld	s0,32(sp)
    800057a6:	64e2                	ld	s1,24(sp)
    800057a8:	6942                	ld	s2,16(sp)
    800057aa:	6145                	addi	sp,sp,48
    800057ac:	8082                	ret
    return -1;
    800057ae:	557d                	li	a0,-1
    800057b0:	bfcd                	j	800057a2 <argfd+0x4c>
    800057b2:	557d                	li	a0,-1
    800057b4:	b7fd                	j	800057a2 <argfd+0x4c>

00000000800057b6 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800057b6:	1101                	addi	sp,sp,-32
    800057b8:	ec06                	sd	ra,24(sp)
    800057ba:	e822                	sd	s0,16(sp)
    800057bc:	e426                	sd	s1,8(sp)
    800057be:	1000                	addi	s0,sp,32
    800057c0:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800057c2:	ffffc097          	auipc	ra,0xffffc
    800057c6:	204080e7          	jalr	516(ra) # 800019c6 <myproc>
    800057ca:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800057cc:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffdb330>
    800057d0:	4501                	li	a0,0
    800057d2:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800057d4:	6398                	ld	a4,0(a5)
    800057d6:	cb19                	beqz	a4,800057ec <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800057d8:	2505                	addiw	a0,a0,1
    800057da:	07a1                	addi	a5,a5,8
    800057dc:	fed51ce3          	bne	a0,a3,800057d4 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800057e0:	557d                	li	a0,-1
}
    800057e2:	60e2                	ld	ra,24(sp)
    800057e4:	6442                	ld	s0,16(sp)
    800057e6:	64a2                	ld	s1,8(sp)
    800057e8:	6105                	addi	sp,sp,32
    800057ea:	8082                	ret
      p->ofile[fd] = f;
    800057ec:	01a50793          	addi	a5,a0,26
    800057f0:	078e                	slli	a5,a5,0x3
    800057f2:	963e                	add	a2,a2,a5
    800057f4:	e204                	sd	s1,0(a2)
      return fd;
    800057f6:	b7f5                	j	800057e2 <fdalloc+0x2c>

00000000800057f8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800057f8:	715d                	addi	sp,sp,-80
    800057fa:	e486                	sd	ra,72(sp)
    800057fc:	e0a2                	sd	s0,64(sp)
    800057fe:	fc26                	sd	s1,56(sp)
    80005800:	f84a                	sd	s2,48(sp)
    80005802:	f44e                	sd	s3,40(sp)
    80005804:	f052                	sd	s4,32(sp)
    80005806:	ec56                	sd	s5,24(sp)
    80005808:	e85a                	sd	s6,16(sp)
    8000580a:	0880                	addi	s0,sp,80
    8000580c:	8b2e                	mv	s6,a1
    8000580e:	89b2                	mv	s3,a2
    80005810:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005812:	fb040593          	addi	a1,s0,-80
    80005816:	fffff097          	auipc	ra,0xfffff
    8000581a:	e4e080e7          	jalr	-434(ra) # 80004664 <nameiparent>
    8000581e:	84aa                	mv	s1,a0
    80005820:	16050063          	beqz	a0,80005980 <create+0x188>
    return 0;

  ilock(dp);
    80005824:	ffffe097          	auipc	ra,0xffffe
    80005828:	67c080e7          	jalr	1660(ra) # 80003ea0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000582c:	4601                	li	a2,0
    8000582e:	fb040593          	addi	a1,s0,-80
    80005832:	8526                	mv	a0,s1
    80005834:	fffff097          	auipc	ra,0xfffff
    80005838:	b50080e7          	jalr	-1200(ra) # 80004384 <dirlookup>
    8000583c:	8aaa                	mv	s5,a0
    8000583e:	c931                	beqz	a0,80005892 <create+0x9a>
    iunlockput(dp);
    80005840:	8526                	mv	a0,s1
    80005842:	fffff097          	auipc	ra,0xfffff
    80005846:	8c0080e7          	jalr	-1856(ra) # 80004102 <iunlockput>
    ilock(ip);
    8000584a:	8556                	mv	a0,s5
    8000584c:	ffffe097          	auipc	ra,0xffffe
    80005850:	654080e7          	jalr	1620(ra) # 80003ea0 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005854:	000b059b          	sext.w	a1,s6
    80005858:	4789                	li	a5,2
    8000585a:	02f59563          	bne	a1,a5,80005884 <create+0x8c>
    8000585e:	044ad783          	lhu	a5,68(s5)
    80005862:	37f9                	addiw	a5,a5,-2
    80005864:	17c2                	slli	a5,a5,0x30
    80005866:	93c1                	srli	a5,a5,0x30
    80005868:	4705                	li	a4,1
    8000586a:	00f76d63          	bltu	a4,a5,80005884 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000586e:	8556                	mv	a0,s5
    80005870:	60a6                	ld	ra,72(sp)
    80005872:	6406                	ld	s0,64(sp)
    80005874:	74e2                	ld	s1,56(sp)
    80005876:	7942                	ld	s2,48(sp)
    80005878:	79a2                	ld	s3,40(sp)
    8000587a:	7a02                	ld	s4,32(sp)
    8000587c:	6ae2                	ld	s5,24(sp)
    8000587e:	6b42                	ld	s6,16(sp)
    80005880:	6161                	addi	sp,sp,80
    80005882:	8082                	ret
    iunlockput(ip);
    80005884:	8556                	mv	a0,s5
    80005886:	fffff097          	auipc	ra,0xfffff
    8000588a:	87c080e7          	jalr	-1924(ra) # 80004102 <iunlockput>
    return 0;
    8000588e:	4a81                	li	s5,0
    80005890:	bff9                	j	8000586e <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005892:	85da                	mv	a1,s6
    80005894:	4088                	lw	a0,0(s1)
    80005896:	ffffe097          	auipc	ra,0xffffe
    8000589a:	46e080e7          	jalr	1134(ra) # 80003d04 <ialloc>
    8000589e:	8a2a                	mv	s4,a0
    800058a0:	c921                	beqz	a0,800058f0 <create+0xf8>
  ilock(ip);
    800058a2:	ffffe097          	auipc	ra,0xffffe
    800058a6:	5fe080e7          	jalr	1534(ra) # 80003ea0 <ilock>
  ip->major = major;
    800058aa:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800058ae:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800058b2:	4785                	li	a5,1
    800058b4:	04fa1523          	sh	a5,74(s4)
  iupdate(ip);
    800058b8:	8552                	mv	a0,s4
    800058ba:	ffffe097          	auipc	ra,0xffffe
    800058be:	51c080e7          	jalr	1308(ra) # 80003dd6 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800058c2:	000b059b          	sext.w	a1,s6
    800058c6:	4785                	li	a5,1
    800058c8:	02f58b63          	beq	a1,a5,800058fe <create+0x106>
  if(dirlink(dp, name, ip->inum) < 0)
    800058cc:	004a2603          	lw	a2,4(s4)
    800058d0:	fb040593          	addi	a1,s0,-80
    800058d4:	8526                	mv	a0,s1
    800058d6:	fffff097          	auipc	ra,0xfffff
    800058da:	cbe080e7          	jalr	-834(ra) # 80004594 <dirlink>
    800058de:	06054f63          	bltz	a0,8000595c <create+0x164>
  iunlockput(dp);
    800058e2:	8526                	mv	a0,s1
    800058e4:	fffff097          	auipc	ra,0xfffff
    800058e8:	81e080e7          	jalr	-2018(ra) # 80004102 <iunlockput>
  return ip;
    800058ec:	8ad2                	mv	s5,s4
    800058ee:	b741                	j	8000586e <create+0x76>
    iunlockput(dp);
    800058f0:	8526                	mv	a0,s1
    800058f2:	fffff097          	auipc	ra,0xfffff
    800058f6:	810080e7          	jalr	-2032(ra) # 80004102 <iunlockput>
    return 0;
    800058fa:	8ad2                	mv	s5,s4
    800058fc:	bf8d                	j	8000586e <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800058fe:	004a2603          	lw	a2,4(s4)
    80005902:	00003597          	auipc	a1,0x3
    80005906:	f3658593          	addi	a1,a1,-202 # 80008838 <syscallnum+0x258>
    8000590a:	8552                	mv	a0,s4
    8000590c:	fffff097          	auipc	ra,0xfffff
    80005910:	c88080e7          	jalr	-888(ra) # 80004594 <dirlink>
    80005914:	04054463          	bltz	a0,8000595c <create+0x164>
    80005918:	40d0                	lw	a2,4(s1)
    8000591a:	00003597          	auipc	a1,0x3
    8000591e:	f2658593          	addi	a1,a1,-218 # 80008840 <syscallnum+0x260>
    80005922:	8552                	mv	a0,s4
    80005924:	fffff097          	auipc	ra,0xfffff
    80005928:	c70080e7          	jalr	-912(ra) # 80004594 <dirlink>
    8000592c:	02054863          	bltz	a0,8000595c <create+0x164>
  if(dirlink(dp, name, ip->inum) < 0)
    80005930:	004a2603          	lw	a2,4(s4)
    80005934:	fb040593          	addi	a1,s0,-80
    80005938:	8526                	mv	a0,s1
    8000593a:	fffff097          	auipc	ra,0xfffff
    8000593e:	c5a080e7          	jalr	-934(ra) # 80004594 <dirlink>
    80005942:	00054d63          	bltz	a0,8000595c <create+0x164>
    dp->nlink++;  // for ".."
    80005946:	04a4d783          	lhu	a5,74(s1)
    8000594a:	2785                	addiw	a5,a5,1
    8000594c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005950:	8526                	mv	a0,s1
    80005952:	ffffe097          	auipc	ra,0xffffe
    80005956:	484080e7          	jalr	1156(ra) # 80003dd6 <iupdate>
    8000595a:	b761                	j	800058e2 <create+0xea>
  ip->nlink = 0;
    8000595c:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005960:	8552                	mv	a0,s4
    80005962:	ffffe097          	auipc	ra,0xffffe
    80005966:	474080e7          	jalr	1140(ra) # 80003dd6 <iupdate>
  iunlockput(ip);
    8000596a:	8552                	mv	a0,s4
    8000596c:	ffffe097          	auipc	ra,0xffffe
    80005970:	796080e7          	jalr	1942(ra) # 80004102 <iunlockput>
  iunlockput(dp);
    80005974:	8526                	mv	a0,s1
    80005976:	ffffe097          	auipc	ra,0xffffe
    8000597a:	78c080e7          	jalr	1932(ra) # 80004102 <iunlockput>
  return 0;
    8000597e:	bdc5                	j	8000586e <create+0x76>
    return 0;
    80005980:	8aaa                	mv	s5,a0
    80005982:	b5f5                	j	8000586e <create+0x76>

0000000080005984 <sys_dup>:
{
    80005984:	7179                	addi	sp,sp,-48
    80005986:	f406                	sd	ra,40(sp)
    80005988:	f022                	sd	s0,32(sp)
    8000598a:	ec26                	sd	s1,24(sp)
    8000598c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000598e:	fd840613          	addi	a2,s0,-40
    80005992:	4581                	li	a1,0
    80005994:	4501                	li	a0,0
    80005996:	00000097          	auipc	ra,0x0
    8000599a:	dc0080e7          	jalr	-576(ra) # 80005756 <argfd>
    return -1;
    8000599e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800059a0:	02054363          	bltz	a0,800059c6 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800059a4:	fd843503          	ld	a0,-40(s0)
    800059a8:	00000097          	auipc	ra,0x0
    800059ac:	e0e080e7          	jalr	-498(ra) # 800057b6 <fdalloc>
    800059b0:	84aa                	mv	s1,a0
    return -1;
    800059b2:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800059b4:	00054963          	bltz	a0,800059c6 <sys_dup+0x42>
  filedup(f);
    800059b8:	fd843503          	ld	a0,-40(s0)
    800059bc:	fffff097          	auipc	ra,0xfffff
    800059c0:	320080e7          	jalr	800(ra) # 80004cdc <filedup>
  return fd;
    800059c4:	87a6                	mv	a5,s1
}
    800059c6:	853e                	mv	a0,a5
    800059c8:	70a2                	ld	ra,40(sp)
    800059ca:	7402                	ld	s0,32(sp)
    800059cc:	64e2                	ld	s1,24(sp)
    800059ce:	6145                	addi	sp,sp,48
    800059d0:	8082                	ret

00000000800059d2 <sys_read>:
{
    800059d2:	7179                	addi	sp,sp,-48
    800059d4:	f406                	sd	ra,40(sp)
    800059d6:	f022                	sd	s0,32(sp)
    800059d8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800059da:	fd840593          	addi	a1,s0,-40
    800059de:	4505                	li	a0,1
    800059e0:	ffffd097          	auipc	ra,0xffffd
    800059e4:	6d0080e7          	jalr	1744(ra) # 800030b0 <argaddr>
  argint(2, &n);
    800059e8:	fe440593          	addi	a1,s0,-28
    800059ec:	4509                	li	a0,2
    800059ee:	ffffd097          	auipc	ra,0xffffd
    800059f2:	6a0080e7          	jalr	1696(ra) # 8000308e <argint>
  if(argfd(0, 0, &f) < 0)
    800059f6:	fe840613          	addi	a2,s0,-24
    800059fa:	4581                	li	a1,0
    800059fc:	4501                	li	a0,0
    800059fe:	00000097          	auipc	ra,0x0
    80005a02:	d58080e7          	jalr	-680(ra) # 80005756 <argfd>
    80005a06:	87aa                	mv	a5,a0
    return -1;
    80005a08:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005a0a:	0007cc63          	bltz	a5,80005a22 <sys_read+0x50>
  return fileread(f, p, n);
    80005a0e:	fe442603          	lw	a2,-28(s0)
    80005a12:	fd843583          	ld	a1,-40(s0)
    80005a16:	fe843503          	ld	a0,-24(s0)
    80005a1a:	fffff097          	auipc	ra,0xfffff
    80005a1e:	44e080e7          	jalr	1102(ra) # 80004e68 <fileread>
}
    80005a22:	70a2                	ld	ra,40(sp)
    80005a24:	7402                	ld	s0,32(sp)
    80005a26:	6145                	addi	sp,sp,48
    80005a28:	8082                	ret

0000000080005a2a <sys_write>:
{
    80005a2a:	7179                	addi	sp,sp,-48
    80005a2c:	f406                	sd	ra,40(sp)
    80005a2e:	f022                	sd	s0,32(sp)
    80005a30:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005a32:	fd840593          	addi	a1,s0,-40
    80005a36:	4505                	li	a0,1
    80005a38:	ffffd097          	auipc	ra,0xffffd
    80005a3c:	678080e7          	jalr	1656(ra) # 800030b0 <argaddr>
  argint(2, &n);
    80005a40:	fe440593          	addi	a1,s0,-28
    80005a44:	4509                	li	a0,2
    80005a46:	ffffd097          	auipc	ra,0xffffd
    80005a4a:	648080e7          	jalr	1608(ra) # 8000308e <argint>
  if(argfd(0, 0, &f) < 0)
    80005a4e:	fe840613          	addi	a2,s0,-24
    80005a52:	4581                	li	a1,0
    80005a54:	4501                	li	a0,0
    80005a56:	00000097          	auipc	ra,0x0
    80005a5a:	d00080e7          	jalr	-768(ra) # 80005756 <argfd>
    80005a5e:	87aa                	mv	a5,a0
    return -1;
    80005a60:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005a62:	0007cc63          	bltz	a5,80005a7a <sys_write+0x50>
  return filewrite(f, p, n);
    80005a66:	fe442603          	lw	a2,-28(s0)
    80005a6a:	fd843583          	ld	a1,-40(s0)
    80005a6e:	fe843503          	ld	a0,-24(s0)
    80005a72:	fffff097          	auipc	ra,0xfffff
    80005a76:	4b8080e7          	jalr	1208(ra) # 80004f2a <filewrite>
}
    80005a7a:	70a2                	ld	ra,40(sp)
    80005a7c:	7402                	ld	s0,32(sp)
    80005a7e:	6145                	addi	sp,sp,48
    80005a80:	8082                	ret

0000000080005a82 <sys_close>:
{
    80005a82:	1101                	addi	sp,sp,-32
    80005a84:	ec06                	sd	ra,24(sp)
    80005a86:	e822                	sd	s0,16(sp)
    80005a88:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005a8a:	fe040613          	addi	a2,s0,-32
    80005a8e:	fec40593          	addi	a1,s0,-20
    80005a92:	4501                	li	a0,0
    80005a94:	00000097          	auipc	ra,0x0
    80005a98:	cc2080e7          	jalr	-830(ra) # 80005756 <argfd>
    return -1;
    80005a9c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005a9e:	02054463          	bltz	a0,80005ac6 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005aa2:	ffffc097          	auipc	ra,0xffffc
    80005aa6:	f24080e7          	jalr	-220(ra) # 800019c6 <myproc>
    80005aaa:	fec42783          	lw	a5,-20(s0)
    80005aae:	07e9                	addi	a5,a5,26
    80005ab0:	078e                	slli	a5,a5,0x3
    80005ab2:	97aa                	add	a5,a5,a0
    80005ab4:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005ab8:	fe043503          	ld	a0,-32(s0)
    80005abc:	fffff097          	auipc	ra,0xfffff
    80005ac0:	272080e7          	jalr	626(ra) # 80004d2e <fileclose>
  return 0;
    80005ac4:	4781                	li	a5,0
}
    80005ac6:	853e                	mv	a0,a5
    80005ac8:	60e2                	ld	ra,24(sp)
    80005aca:	6442                	ld	s0,16(sp)
    80005acc:	6105                	addi	sp,sp,32
    80005ace:	8082                	ret

0000000080005ad0 <sys_fstat>:
{
    80005ad0:	1101                	addi	sp,sp,-32
    80005ad2:	ec06                	sd	ra,24(sp)
    80005ad4:	e822                	sd	s0,16(sp)
    80005ad6:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005ad8:	fe040593          	addi	a1,s0,-32
    80005adc:	4505                	li	a0,1
    80005ade:	ffffd097          	auipc	ra,0xffffd
    80005ae2:	5d2080e7          	jalr	1490(ra) # 800030b0 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005ae6:	fe840613          	addi	a2,s0,-24
    80005aea:	4581                	li	a1,0
    80005aec:	4501                	li	a0,0
    80005aee:	00000097          	auipc	ra,0x0
    80005af2:	c68080e7          	jalr	-920(ra) # 80005756 <argfd>
    80005af6:	87aa                	mv	a5,a0
    return -1;
    80005af8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005afa:	0007ca63          	bltz	a5,80005b0e <sys_fstat+0x3e>
  return filestat(f, st);
    80005afe:	fe043583          	ld	a1,-32(s0)
    80005b02:	fe843503          	ld	a0,-24(s0)
    80005b06:	fffff097          	auipc	ra,0xfffff
    80005b0a:	2f0080e7          	jalr	752(ra) # 80004df6 <filestat>
}
    80005b0e:	60e2                	ld	ra,24(sp)
    80005b10:	6442                	ld	s0,16(sp)
    80005b12:	6105                	addi	sp,sp,32
    80005b14:	8082                	ret

0000000080005b16 <sys_link>:
{
    80005b16:	7169                	addi	sp,sp,-304
    80005b18:	f606                	sd	ra,296(sp)
    80005b1a:	f222                	sd	s0,288(sp)
    80005b1c:	ee26                	sd	s1,280(sp)
    80005b1e:	ea4a                	sd	s2,272(sp)
    80005b20:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b22:	08000613          	li	a2,128
    80005b26:	ed040593          	addi	a1,s0,-304
    80005b2a:	4501                	li	a0,0
    80005b2c:	ffffd097          	auipc	ra,0xffffd
    80005b30:	5a6080e7          	jalr	1446(ra) # 800030d2 <argstr>
    return -1;
    80005b34:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b36:	10054e63          	bltz	a0,80005c52 <sys_link+0x13c>
    80005b3a:	08000613          	li	a2,128
    80005b3e:	f5040593          	addi	a1,s0,-176
    80005b42:	4505                	li	a0,1
    80005b44:	ffffd097          	auipc	ra,0xffffd
    80005b48:	58e080e7          	jalr	1422(ra) # 800030d2 <argstr>
    return -1;
    80005b4c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b4e:	10054263          	bltz	a0,80005c52 <sys_link+0x13c>
  begin_op();
    80005b52:	fffff097          	auipc	ra,0xfffff
    80005b56:	d10080e7          	jalr	-752(ra) # 80004862 <begin_op>
  if((ip = namei(old)) == 0){
    80005b5a:	ed040513          	addi	a0,s0,-304
    80005b5e:	fffff097          	auipc	ra,0xfffff
    80005b62:	ae8080e7          	jalr	-1304(ra) # 80004646 <namei>
    80005b66:	84aa                	mv	s1,a0
    80005b68:	c551                	beqz	a0,80005bf4 <sys_link+0xde>
  ilock(ip);
    80005b6a:	ffffe097          	auipc	ra,0xffffe
    80005b6e:	336080e7          	jalr	822(ra) # 80003ea0 <ilock>
  if(ip->type == T_DIR){
    80005b72:	04449703          	lh	a4,68(s1)
    80005b76:	4785                	li	a5,1
    80005b78:	08f70463          	beq	a4,a5,80005c00 <sys_link+0xea>
  ip->nlink++;
    80005b7c:	04a4d783          	lhu	a5,74(s1)
    80005b80:	2785                	addiw	a5,a5,1
    80005b82:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005b86:	8526                	mv	a0,s1
    80005b88:	ffffe097          	auipc	ra,0xffffe
    80005b8c:	24e080e7          	jalr	590(ra) # 80003dd6 <iupdate>
  iunlock(ip);
    80005b90:	8526                	mv	a0,s1
    80005b92:	ffffe097          	auipc	ra,0xffffe
    80005b96:	3d0080e7          	jalr	976(ra) # 80003f62 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005b9a:	fd040593          	addi	a1,s0,-48
    80005b9e:	f5040513          	addi	a0,s0,-176
    80005ba2:	fffff097          	auipc	ra,0xfffff
    80005ba6:	ac2080e7          	jalr	-1342(ra) # 80004664 <nameiparent>
    80005baa:	892a                	mv	s2,a0
    80005bac:	c935                	beqz	a0,80005c20 <sys_link+0x10a>
  ilock(dp);
    80005bae:	ffffe097          	auipc	ra,0xffffe
    80005bb2:	2f2080e7          	jalr	754(ra) # 80003ea0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005bb6:	00092703          	lw	a4,0(s2)
    80005bba:	409c                	lw	a5,0(s1)
    80005bbc:	04f71d63          	bne	a4,a5,80005c16 <sys_link+0x100>
    80005bc0:	40d0                	lw	a2,4(s1)
    80005bc2:	fd040593          	addi	a1,s0,-48
    80005bc6:	854a                	mv	a0,s2
    80005bc8:	fffff097          	auipc	ra,0xfffff
    80005bcc:	9cc080e7          	jalr	-1588(ra) # 80004594 <dirlink>
    80005bd0:	04054363          	bltz	a0,80005c16 <sys_link+0x100>
  iunlockput(dp);
    80005bd4:	854a                	mv	a0,s2
    80005bd6:	ffffe097          	auipc	ra,0xffffe
    80005bda:	52c080e7          	jalr	1324(ra) # 80004102 <iunlockput>
  iput(ip);
    80005bde:	8526                	mv	a0,s1
    80005be0:	ffffe097          	auipc	ra,0xffffe
    80005be4:	47a080e7          	jalr	1146(ra) # 8000405a <iput>
  end_op();
    80005be8:	fffff097          	auipc	ra,0xfffff
    80005bec:	cfa080e7          	jalr	-774(ra) # 800048e2 <end_op>
  return 0;
    80005bf0:	4781                	li	a5,0
    80005bf2:	a085                	j	80005c52 <sys_link+0x13c>
    end_op();
    80005bf4:	fffff097          	auipc	ra,0xfffff
    80005bf8:	cee080e7          	jalr	-786(ra) # 800048e2 <end_op>
    return -1;
    80005bfc:	57fd                	li	a5,-1
    80005bfe:	a891                	j	80005c52 <sys_link+0x13c>
    iunlockput(ip);
    80005c00:	8526                	mv	a0,s1
    80005c02:	ffffe097          	auipc	ra,0xffffe
    80005c06:	500080e7          	jalr	1280(ra) # 80004102 <iunlockput>
    end_op();
    80005c0a:	fffff097          	auipc	ra,0xfffff
    80005c0e:	cd8080e7          	jalr	-808(ra) # 800048e2 <end_op>
    return -1;
    80005c12:	57fd                	li	a5,-1
    80005c14:	a83d                	j	80005c52 <sys_link+0x13c>
    iunlockput(dp);
    80005c16:	854a                	mv	a0,s2
    80005c18:	ffffe097          	auipc	ra,0xffffe
    80005c1c:	4ea080e7          	jalr	1258(ra) # 80004102 <iunlockput>
  ilock(ip);
    80005c20:	8526                	mv	a0,s1
    80005c22:	ffffe097          	auipc	ra,0xffffe
    80005c26:	27e080e7          	jalr	638(ra) # 80003ea0 <ilock>
  ip->nlink--;
    80005c2a:	04a4d783          	lhu	a5,74(s1)
    80005c2e:	37fd                	addiw	a5,a5,-1
    80005c30:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005c34:	8526                	mv	a0,s1
    80005c36:	ffffe097          	auipc	ra,0xffffe
    80005c3a:	1a0080e7          	jalr	416(ra) # 80003dd6 <iupdate>
  iunlockput(ip);
    80005c3e:	8526                	mv	a0,s1
    80005c40:	ffffe097          	auipc	ra,0xffffe
    80005c44:	4c2080e7          	jalr	1218(ra) # 80004102 <iunlockput>
  end_op();
    80005c48:	fffff097          	auipc	ra,0xfffff
    80005c4c:	c9a080e7          	jalr	-870(ra) # 800048e2 <end_op>
  return -1;
    80005c50:	57fd                	li	a5,-1
}
    80005c52:	853e                	mv	a0,a5
    80005c54:	70b2                	ld	ra,296(sp)
    80005c56:	7412                	ld	s0,288(sp)
    80005c58:	64f2                	ld	s1,280(sp)
    80005c5a:	6952                	ld	s2,272(sp)
    80005c5c:	6155                	addi	sp,sp,304
    80005c5e:	8082                	ret

0000000080005c60 <sys_unlink>:
{
    80005c60:	7151                	addi	sp,sp,-240
    80005c62:	f586                	sd	ra,232(sp)
    80005c64:	f1a2                	sd	s0,224(sp)
    80005c66:	eda6                	sd	s1,216(sp)
    80005c68:	e9ca                	sd	s2,208(sp)
    80005c6a:	e5ce                	sd	s3,200(sp)
    80005c6c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005c6e:	08000613          	li	a2,128
    80005c72:	f3040593          	addi	a1,s0,-208
    80005c76:	4501                	li	a0,0
    80005c78:	ffffd097          	auipc	ra,0xffffd
    80005c7c:	45a080e7          	jalr	1114(ra) # 800030d2 <argstr>
    80005c80:	18054163          	bltz	a0,80005e02 <sys_unlink+0x1a2>
  begin_op();
    80005c84:	fffff097          	auipc	ra,0xfffff
    80005c88:	bde080e7          	jalr	-1058(ra) # 80004862 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005c8c:	fb040593          	addi	a1,s0,-80
    80005c90:	f3040513          	addi	a0,s0,-208
    80005c94:	fffff097          	auipc	ra,0xfffff
    80005c98:	9d0080e7          	jalr	-1584(ra) # 80004664 <nameiparent>
    80005c9c:	84aa                	mv	s1,a0
    80005c9e:	c979                	beqz	a0,80005d74 <sys_unlink+0x114>
  ilock(dp);
    80005ca0:	ffffe097          	auipc	ra,0xffffe
    80005ca4:	200080e7          	jalr	512(ra) # 80003ea0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005ca8:	00003597          	auipc	a1,0x3
    80005cac:	b9058593          	addi	a1,a1,-1136 # 80008838 <syscallnum+0x258>
    80005cb0:	fb040513          	addi	a0,s0,-80
    80005cb4:	ffffe097          	auipc	ra,0xffffe
    80005cb8:	6b6080e7          	jalr	1718(ra) # 8000436a <namecmp>
    80005cbc:	14050a63          	beqz	a0,80005e10 <sys_unlink+0x1b0>
    80005cc0:	00003597          	auipc	a1,0x3
    80005cc4:	b8058593          	addi	a1,a1,-1152 # 80008840 <syscallnum+0x260>
    80005cc8:	fb040513          	addi	a0,s0,-80
    80005ccc:	ffffe097          	auipc	ra,0xffffe
    80005cd0:	69e080e7          	jalr	1694(ra) # 8000436a <namecmp>
    80005cd4:	12050e63          	beqz	a0,80005e10 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005cd8:	f2c40613          	addi	a2,s0,-212
    80005cdc:	fb040593          	addi	a1,s0,-80
    80005ce0:	8526                	mv	a0,s1
    80005ce2:	ffffe097          	auipc	ra,0xffffe
    80005ce6:	6a2080e7          	jalr	1698(ra) # 80004384 <dirlookup>
    80005cea:	892a                	mv	s2,a0
    80005cec:	12050263          	beqz	a0,80005e10 <sys_unlink+0x1b0>
  ilock(ip);
    80005cf0:	ffffe097          	auipc	ra,0xffffe
    80005cf4:	1b0080e7          	jalr	432(ra) # 80003ea0 <ilock>
  if(ip->nlink < 1)
    80005cf8:	04a91783          	lh	a5,74(s2)
    80005cfc:	08f05263          	blez	a5,80005d80 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005d00:	04491703          	lh	a4,68(s2)
    80005d04:	4785                	li	a5,1
    80005d06:	08f70563          	beq	a4,a5,80005d90 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005d0a:	4641                	li	a2,16
    80005d0c:	4581                	li	a1,0
    80005d0e:	fc040513          	addi	a0,s0,-64
    80005d12:	ffffb097          	auipc	ra,0xffffb
    80005d16:	fd4080e7          	jalr	-44(ra) # 80000ce6 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005d1a:	4741                	li	a4,16
    80005d1c:	f2c42683          	lw	a3,-212(s0)
    80005d20:	fc040613          	addi	a2,s0,-64
    80005d24:	4581                	li	a1,0
    80005d26:	8526                	mv	a0,s1
    80005d28:	ffffe097          	auipc	ra,0xffffe
    80005d2c:	524080e7          	jalr	1316(ra) # 8000424c <writei>
    80005d30:	47c1                	li	a5,16
    80005d32:	0af51563          	bne	a0,a5,80005ddc <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005d36:	04491703          	lh	a4,68(s2)
    80005d3a:	4785                	li	a5,1
    80005d3c:	0af70863          	beq	a4,a5,80005dec <sys_unlink+0x18c>
  iunlockput(dp);
    80005d40:	8526                	mv	a0,s1
    80005d42:	ffffe097          	auipc	ra,0xffffe
    80005d46:	3c0080e7          	jalr	960(ra) # 80004102 <iunlockput>
  ip->nlink--;
    80005d4a:	04a95783          	lhu	a5,74(s2)
    80005d4e:	37fd                	addiw	a5,a5,-1
    80005d50:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005d54:	854a                	mv	a0,s2
    80005d56:	ffffe097          	auipc	ra,0xffffe
    80005d5a:	080080e7          	jalr	128(ra) # 80003dd6 <iupdate>
  iunlockput(ip);
    80005d5e:	854a                	mv	a0,s2
    80005d60:	ffffe097          	auipc	ra,0xffffe
    80005d64:	3a2080e7          	jalr	930(ra) # 80004102 <iunlockput>
  end_op();
    80005d68:	fffff097          	auipc	ra,0xfffff
    80005d6c:	b7a080e7          	jalr	-1158(ra) # 800048e2 <end_op>
  return 0;
    80005d70:	4501                	li	a0,0
    80005d72:	a84d                	j	80005e24 <sys_unlink+0x1c4>
    end_op();
    80005d74:	fffff097          	auipc	ra,0xfffff
    80005d78:	b6e080e7          	jalr	-1170(ra) # 800048e2 <end_op>
    return -1;
    80005d7c:	557d                	li	a0,-1
    80005d7e:	a05d                	j	80005e24 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005d80:	00003517          	auipc	a0,0x3
    80005d84:	ac850513          	addi	a0,a0,-1336 # 80008848 <syscallnum+0x268>
    80005d88:	ffffa097          	auipc	ra,0xffffa
    80005d8c:	7bc080e7          	jalr	1980(ra) # 80000544 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005d90:	04c92703          	lw	a4,76(s2)
    80005d94:	02000793          	li	a5,32
    80005d98:	f6e7f9e3          	bgeu	a5,a4,80005d0a <sys_unlink+0xaa>
    80005d9c:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005da0:	4741                	li	a4,16
    80005da2:	86ce                	mv	a3,s3
    80005da4:	f1840613          	addi	a2,s0,-232
    80005da8:	4581                	li	a1,0
    80005daa:	854a                	mv	a0,s2
    80005dac:	ffffe097          	auipc	ra,0xffffe
    80005db0:	3a8080e7          	jalr	936(ra) # 80004154 <readi>
    80005db4:	47c1                	li	a5,16
    80005db6:	00f51b63          	bne	a0,a5,80005dcc <sys_unlink+0x16c>
    if(de.inum != 0)
    80005dba:	f1845783          	lhu	a5,-232(s0)
    80005dbe:	e7a1                	bnez	a5,80005e06 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005dc0:	29c1                	addiw	s3,s3,16
    80005dc2:	04c92783          	lw	a5,76(s2)
    80005dc6:	fcf9ede3          	bltu	s3,a5,80005da0 <sys_unlink+0x140>
    80005dca:	b781                	j	80005d0a <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005dcc:	00003517          	auipc	a0,0x3
    80005dd0:	a9450513          	addi	a0,a0,-1388 # 80008860 <syscallnum+0x280>
    80005dd4:	ffffa097          	auipc	ra,0xffffa
    80005dd8:	770080e7          	jalr	1904(ra) # 80000544 <panic>
    panic("unlink: writei");
    80005ddc:	00003517          	auipc	a0,0x3
    80005de0:	a9c50513          	addi	a0,a0,-1380 # 80008878 <syscallnum+0x298>
    80005de4:	ffffa097          	auipc	ra,0xffffa
    80005de8:	760080e7          	jalr	1888(ra) # 80000544 <panic>
    dp->nlink--;
    80005dec:	04a4d783          	lhu	a5,74(s1)
    80005df0:	37fd                	addiw	a5,a5,-1
    80005df2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005df6:	8526                	mv	a0,s1
    80005df8:	ffffe097          	auipc	ra,0xffffe
    80005dfc:	fde080e7          	jalr	-34(ra) # 80003dd6 <iupdate>
    80005e00:	b781                	j	80005d40 <sys_unlink+0xe0>
    return -1;
    80005e02:	557d                	li	a0,-1
    80005e04:	a005                	j	80005e24 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005e06:	854a                	mv	a0,s2
    80005e08:	ffffe097          	auipc	ra,0xffffe
    80005e0c:	2fa080e7          	jalr	762(ra) # 80004102 <iunlockput>
  iunlockput(dp);
    80005e10:	8526                	mv	a0,s1
    80005e12:	ffffe097          	auipc	ra,0xffffe
    80005e16:	2f0080e7          	jalr	752(ra) # 80004102 <iunlockput>
  end_op();
    80005e1a:	fffff097          	auipc	ra,0xfffff
    80005e1e:	ac8080e7          	jalr	-1336(ra) # 800048e2 <end_op>
  return -1;
    80005e22:	557d                	li	a0,-1
}
    80005e24:	70ae                	ld	ra,232(sp)
    80005e26:	740e                	ld	s0,224(sp)
    80005e28:	64ee                	ld	s1,216(sp)
    80005e2a:	694e                	ld	s2,208(sp)
    80005e2c:	69ae                	ld	s3,200(sp)
    80005e2e:	616d                	addi	sp,sp,240
    80005e30:	8082                	ret

0000000080005e32 <sys_open>:

uint64
sys_open(void)
{
    80005e32:	7131                	addi	sp,sp,-192
    80005e34:	fd06                	sd	ra,184(sp)
    80005e36:	f922                	sd	s0,176(sp)
    80005e38:	f526                	sd	s1,168(sp)
    80005e3a:	f14a                	sd	s2,160(sp)
    80005e3c:	ed4e                	sd	s3,152(sp)
    80005e3e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005e40:	f4c40593          	addi	a1,s0,-180
    80005e44:	4505                	li	a0,1
    80005e46:	ffffd097          	auipc	ra,0xffffd
    80005e4a:	248080e7          	jalr	584(ra) # 8000308e <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005e4e:	08000613          	li	a2,128
    80005e52:	f5040593          	addi	a1,s0,-176
    80005e56:	4501                	li	a0,0
    80005e58:	ffffd097          	auipc	ra,0xffffd
    80005e5c:	27a080e7          	jalr	634(ra) # 800030d2 <argstr>
    80005e60:	87aa                	mv	a5,a0
    return -1;
    80005e62:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005e64:	0a07c963          	bltz	a5,80005f16 <sys_open+0xe4>

  begin_op();
    80005e68:	fffff097          	auipc	ra,0xfffff
    80005e6c:	9fa080e7          	jalr	-1542(ra) # 80004862 <begin_op>

  if(omode & O_CREATE){
    80005e70:	f4c42783          	lw	a5,-180(s0)
    80005e74:	2007f793          	andi	a5,a5,512
    80005e78:	cfc5                	beqz	a5,80005f30 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005e7a:	4681                	li	a3,0
    80005e7c:	4601                	li	a2,0
    80005e7e:	4589                	li	a1,2
    80005e80:	f5040513          	addi	a0,s0,-176
    80005e84:	00000097          	auipc	ra,0x0
    80005e88:	974080e7          	jalr	-1676(ra) # 800057f8 <create>
    80005e8c:	84aa                	mv	s1,a0
    if(ip == 0){
    80005e8e:	c959                	beqz	a0,80005f24 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005e90:	04449703          	lh	a4,68(s1)
    80005e94:	478d                	li	a5,3
    80005e96:	00f71763          	bne	a4,a5,80005ea4 <sys_open+0x72>
    80005e9a:	0464d703          	lhu	a4,70(s1)
    80005e9e:	47a5                	li	a5,9
    80005ea0:	0ce7ed63          	bltu	a5,a4,80005f7a <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005ea4:	fffff097          	auipc	ra,0xfffff
    80005ea8:	dce080e7          	jalr	-562(ra) # 80004c72 <filealloc>
    80005eac:	89aa                	mv	s3,a0
    80005eae:	10050363          	beqz	a0,80005fb4 <sys_open+0x182>
    80005eb2:	00000097          	auipc	ra,0x0
    80005eb6:	904080e7          	jalr	-1788(ra) # 800057b6 <fdalloc>
    80005eba:	892a                	mv	s2,a0
    80005ebc:	0e054763          	bltz	a0,80005faa <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005ec0:	04449703          	lh	a4,68(s1)
    80005ec4:	478d                	li	a5,3
    80005ec6:	0cf70563          	beq	a4,a5,80005f90 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005eca:	4789                	li	a5,2
    80005ecc:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005ed0:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005ed4:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005ed8:	f4c42783          	lw	a5,-180(s0)
    80005edc:	0017c713          	xori	a4,a5,1
    80005ee0:	8b05                	andi	a4,a4,1
    80005ee2:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005ee6:	0037f713          	andi	a4,a5,3
    80005eea:	00e03733          	snez	a4,a4
    80005eee:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005ef2:	4007f793          	andi	a5,a5,1024
    80005ef6:	c791                	beqz	a5,80005f02 <sys_open+0xd0>
    80005ef8:	04449703          	lh	a4,68(s1)
    80005efc:	4789                	li	a5,2
    80005efe:	0af70063          	beq	a4,a5,80005f9e <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005f02:	8526                	mv	a0,s1
    80005f04:	ffffe097          	auipc	ra,0xffffe
    80005f08:	05e080e7          	jalr	94(ra) # 80003f62 <iunlock>
  end_op();
    80005f0c:	fffff097          	auipc	ra,0xfffff
    80005f10:	9d6080e7          	jalr	-1578(ra) # 800048e2 <end_op>

  return fd;
    80005f14:	854a                	mv	a0,s2
}
    80005f16:	70ea                	ld	ra,184(sp)
    80005f18:	744a                	ld	s0,176(sp)
    80005f1a:	74aa                	ld	s1,168(sp)
    80005f1c:	790a                	ld	s2,160(sp)
    80005f1e:	69ea                	ld	s3,152(sp)
    80005f20:	6129                	addi	sp,sp,192
    80005f22:	8082                	ret
      end_op();
    80005f24:	fffff097          	auipc	ra,0xfffff
    80005f28:	9be080e7          	jalr	-1602(ra) # 800048e2 <end_op>
      return -1;
    80005f2c:	557d                	li	a0,-1
    80005f2e:	b7e5                	j	80005f16 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005f30:	f5040513          	addi	a0,s0,-176
    80005f34:	ffffe097          	auipc	ra,0xffffe
    80005f38:	712080e7          	jalr	1810(ra) # 80004646 <namei>
    80005f3c:	84aa                	mv	s1,a0
    80005f3e:	c905                	beqz	a0,80005f6e <sys_open+0x13c>
    ilock(ip);
    80005f40:	ffffe097          	auipc	ra,0xffffe
    80005f44:	f60080e7          	jalr	-160(ra) # 80003ea0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005f48:	04449703          	lh	a4,68(s1)
    80005f4c:	4785                	li	a5,1
    80005f4e:	f4f711e3          	bne	a4,a5,80005e90 <sys_open+0x5e>
    80005f52:	f4c42783          	lw	a5,-180(s0)
    80005f56:	d7b9                	beqz	a5,80005ea4 <sys_open+0x72>
      iunlockput(ip);
    80005f58:	8526                	mv	a0,s1
    80005f5a:	ffffe097          	auipc	ra,0xffffe
    80005f5e:	1a8080e7          	jalr	424(ra) # 80004102 <iunlockput>
      end_op();
    80005f62:	fffff097          	auipc	ra,0xfffff
    80005f66:	980080e7          	jalr	-1664(ra) # 800048e2 <end_op>
      return -1;
    80005f6a:	557d                	li	a0,-1
    80005f6c:	b76d                	j	80005f16 <sys_open+0xe4>
      end_op();
    80005f6e:	fffff097          	auipc	ra,0xfffff
    80005f72:	974080e7          	jalr	-1676(ra) # 800048e2 <end_op>
      return -1;
    80005f76:	557d                	li	a0,-1
    80005f78:	bf79                	j	80005f16 <sys_open+0xe4>
    iunlockput(ip);
    80005f7a:	8526                	mv	a0,s1
    80005f7c:	ffffe097          	auipc	ra,0xffffe
    80005f80:	186080e7          	jalr	390(ra) # 80004102 <iunlockput>
    end_op();
    80005f84:	fffff097          	auipc	ra,0xfffff
    80005f88:	95e080e7          	jalr	-1698(ra) # 800048e2 <end_op>
    return -1;
    80005f8c:	557d                	li	a0,-1
    80005f8e:	b761                	j	80005f16 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005f90:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005f94:	04649783          	lh	a5,70(s1)
    80005f98:	02f99223          	sh	a5,36(s3)
    80005f9c:	bf25                	j	80005ed4 <sys_open+0xa2>
    itrunc(ip);
    80005f9e:	8526                	mv	a0,s1
    80005fa0:	ffffe097          	auipc	ra,0xffffe
    80005fa4:	00e080e7          	jalr	14(ra) # 80003fae <itrunc>
    80005fa8:	bfa9                	j	80005f02 <sys_open+0xd0>
      fileclose(f);
    80005faa:	854e                	mv	a0,s3
    80005fac:	fffff097          	auipc	ra,0xfffff
    80005fb0:	d82080e7          	jalr	-638(ra) # 80004d2e <fileclose>
    iunlockput(ip);
    80005fb4:	8526                	mv	a0,s1
    80005fb6:	ffffe097          	auipc	ra,0xffffe
    80005fba:	14c080e7          	jalr	332(ra) # 80004102 <iunlockput>
    end_op();
    80005fbe:	fffff097          	auipc	ra,0xfffff
    80005fc2:	924080e7          	jalr	-1756(ra) # 800048e2 <end_op>
    return -1;
    80005fc6:	557d                	li	a0,-1
    80005fc8:	b7b9                	j	80005f16 <sys_open+0xe4>

0000000080005fca <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005fca:	7175                	addi	sp,sp,-144
    80005fcc:	e506                	sd	ra,136(sp)
    80005fce:	e122                	sd	s0,128(sp)
    80005fd0:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005fd2:	fffff097          	auipc	ra,0xfffff
    80005fd6:	890080e7          	jalr	-1904(ra) # 80004862 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005fda:	08000613          	li	a2,128
    80005fde:	f7040593          	addi	a1,s0,-144
    80005fe2:	4501                	li	a0,0
    80005fe4:	ffffd097          	auipc	ra,0xffffd
    80005fe8:	0ee080e7          	jalr	238(ra) # 800030d2 <argstr>
    80005fec:	02054963          	bltz	a0,8000601e <sys_mkdir+0x54>
    80005ff0:	4681                	li	a3,0
    80005ff2:	4601                	li	a2,0
    80005ff4:	4585                	li	a1,1
    80005ff6:	f7040513          	addi	a0,s0,-144
    80005ffa:	fffff097          	auipc	ra,0xfffff
    80005ffe:	7fe080e7          	jalr	2046(ra) # 800057f8 <create>
    80006002:	cd11                	beqz	a0,8000601e <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006004:	ffffe097          	auipc	ra,0xffffe
    80006008:	0fe080e7          	jalr	254(ra) # 80004102 <iunlockput>
  end_op();
    8000600c:	fffff097          	auipc	ra,0xfffff
    80006010:	8d6080e7          	jalr	-1834(ra) # 800048e2 <end_op>
  return 0;
    80006014:	4501                	li	a0,0
}
    80006016:	60aa                	ld	ra,136(sp)
    80006018:	640a                	ld	s0,128(sp)
    8000601a:	6149                	addi	sp,sp,144
    8000601c:	8082                	ret
    end_op();
    8000601e:	fffff097          	auipc	ra,0xfffff
    80006022:	8c4080e7          	jalr	-1852(ra) # 800048e2 <end_op>
    return -1;
    80006026:	557d                	li	a0,-1
    80006028:	b7fd                	j	80006016 <sys_mkdir+0x4c>

000000008000602a <sys_mknod>:

uint64
sys_mknod(void)
{
    8000602a:	7135                	addi	sp,sp,-160
    8000602c:	ed06                	sd	ra,152(sp)
    8000602e:	e922                	sd	s0,144(sp)
    80006030:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80006032:	fffff097          	auipc	ra,0xfffff
    80006036:	830080e7          	jalr	-2000(ra) # 80004862 <begin_op>
  argint(1, &major);
    8000603a:	f6c40593          	addi	a1,s0,-148
    8000603e:	4505                	li	a0,1
    80006040:	ffffd097          	auipc	ra,0xffffd
    80006044:	04e080e7          	jalr	78(ra) # 8000308e <argint>
  argint(2, &minor);
    80006048:	f6840593          	addi	a1,s0,-152
    8000604c:	4509                	li	a0,2
    8000604e:	ffffd097          	auipc	ra,0xffffd
    80006052:	040080e7          	jalr	64(ra) # 8000308e <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006056:	08000613          	li	a2,128
    8000605a:	f7040593          	addi	a1,s0,-144
    8000605e:	4501                	li	a0,0
    80006060:	ffffd097          	auipc	ra,0xffffd
    80006064:	072080e7          	jalr	114(ra) # 800030d2 <argstr>
    80006068:	02054b63          	bltz	a0,8000609e <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000606c:	f6841683          	lh	a3,-152(s0)
    80006070:	f6c41603          	lh	a2,-148(s0)
    80006074:	458d                	li	a1,3
    80006076:	f7040513          	addi	a0,s0,-144
    8000607a:	fffff097          	auipc	ra,0xfffff
    8000607e:	77e080e7          	jalr	1918(ra) # 800057f8 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006082:	cd11                	beqz	a0,8000609e <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006084:	ffffe097          	auipc	ra,0xffffe
    80006088:	07e080e7          	jalr	126(ra) # 80004102 <iunlockput>
  end_op();
    8000608c:	fffff097          	auipc	ra,0xfffff
    80006090:	856080e7          	jalr	-1962(ra) # 800048e2 <end_op>
  return 0;
    80006094:	4501                	li	a0,0
}
    80006096:	60ea                	ld	ra,152(sp)
    80006098:	644a                	ld	s0,144(sp)
    8000609a:	610d                	addi	sp,sp,160
    8000609c:	8082                	ret
    end_op();
    8000609e:	fffff097          	auipc	ra,0xfffff
    800060a2:	844080e7          	jalr	-1980(ra) # 800048e2 <end_op>
    return -1;
    800060a6:	557d                	li	a0,-1
    800060a8:	b7fd                	j	80006096 <sys_mknod+0x6c>

00000000800060aa <sys_chdir>:

uint64
sys_chdir(void)
{
    800060aa:	7135                	addi	sp,sp,-160
    800060ac:	ed06                	sd	ra,152(sp)
    800060ae:	e922                	sd	s0,144(sp)
    800060b0:	e526                	sd	s1,136(sp)
    800060b2:	e14a                	sd	s2,128(sp)
    800060b4:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800060b6:	ffffc097          	auipc	ra,0xffffc
    800060ba:	910080e7          	jalr	-1776(ra) # 800019c6 <myproc>
    800060be:	892a                	mv	s2,a0
  
  begin_op();
    800060c0:	ffffe097          	auipc	ra,0xffffe
    800060c4:	7a2080e7          	jalr	1954(ra) # 80004862 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800060c8:	08000613          	li	a2,128
    800060cc:	f6040593          	addi	a1,s0,-160
    800060d0:	4501                	li	a0,0
    800060d2:	ffffd097          	auipc	ra,0xffffd
    800060d6:	000080e7          	jalr	ra # 800030d2 <argstr>
    800060da:	04054b63          	bltz	a0,80006130 <sys_chdir+0x86>
    800060de:	f6040513          	addi	a0,s0,-160
    800060e2:	ffffe097          	auipc	ra,0xffffe
    800060e6:	564080e7          	jalr	1380(ra) # 80004646 <namei>
    800060ea:	84aa                	mv	s1,a0
    800060ec:	c131                	beqz	a0,80006130 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800060ee:	ffffe097          	auipc	ra,0xffffe
    800060f2:	db2080e7          	jalr	-590(ra) # 80003ea0 <ilock>
  if(ip->type != T_DIR){
    800060f6:	04449703          	lh	a4,68(s1)
    800060fa:	4785                	li	a5,1
    800060fc:	04f71063          	bne	a4,a5,8000613c <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006100:	8526                	mv	a0,s1
    80006102:	ffffe097          	auipc	ra,0xffffe
    80006106:	e60080e7          	jalr	-416(ra) # 80003f62 <iunlock>
  iput(p->cwd);
    8000610a:	15093503          	ld	a0,336(s2)
    8000610e:	ffffe097          	auipc	ra,0xffffe
    80006112:	f4c080e7          	jalr	-180(ra) # 8000405a <iput>
  end_op();
    80006116:	ffffe097          	auipc	ra,0xffffe
    8000611a:	7cc080e7          	jalr	1996(ra) # 800048e2 <end_op>
  p->cwd = ip;
    8000611e:	14993823          	sd	s1,336(s2)
  return 0;
    80006122:	4501                	li	a0,0
}
    80006124:	60ea                	ld	ra,152(sp)
    80006126:	644a                	ld	s0,144(sp)
    80006128:	64aa                	ld	s1,136(sp)
    8000612a:	690a                	ld	s2,128(sp)
    8000612c:	610d                	addi	sp,sp,160
    8000612e:	8082                	ret
    end_op();
    80006130:	ffffe097          	auipc	ra,0xffffe
    80006134:	7b2080e7          	jalr	1970(ra) # 800048e2 <end_op>
    return -1;
    80006138:	557d                	li	a0,-1
    8000613a:	b7ed                	j	80006124 <sys_chdir+0x7a>
    iunlockput(ip);
    8000613c:	8526                	mv	a0,s1
    8000613e:	ffffe097          	auipc	ra,0xffffe
    80006142:	fc4080e7          	jalr	-60(ra) # 80004102 <iunlockput>
    end_op();
    80006146:	ffffe097          	auipc	ra,0xffffe
    8000614a:	79c080e7          	jalr	1948(ra) # 800048e2 <end_op>
    return -1;
    8000614e:	557d                	li	a0,-1
    80006150:	bfd1                	j	80006124 <sys_chdir+0x7a>

0000000080006152 <sys_exec>:

uint64
sys_exec(void)
{
    80006152:	7145                	addi	sp,sp,-464
    80006154:	e786                	sd	ra,456(sp)
    80006156:	e3a2                	sd	s0,448(sp)
    80006158:	ff26                	sd	s1,440(sp)
    8000615a:	fb4a                	sd	s2,432(sp)
    8000615c:	f74e                	sd	s3,424(sp)
    8000615e:	f352                	sd	s4,416(sp)
    80006160:	ef56                	sd	s5,408(sp)
    80006162:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80006164:	e3840593          	addi	a1,s0,-456
    80006168:	4505                	li	a0,1
    8000616a:	ffffd097          	auipc	ra,0xffffd
    8000616e:	f46080e7          	jalr	-186(ra) # 800030b0 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80006172:	08000613          	li	a2,128
    80006176:	f4040593          	addi	a1,s0,-192
    8000617a:	4501                	li	a0,0
    8000617c:	ffffd097          	auipc	ra,0xffffd
    80006180:	f56080e7          	jalr	-170(ra) # 800030d2 <argstr>
    80006184:	87aa                	mv	a5,a0
    return -1;
    80006186:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80006188:	0c07c263          	bltz	a5,8000624c <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    8000618c:	10000613          	li	a2,256
    80006190:	4581                	li	a1,0
    80006192:	e4040513          	addi	a0,s0,-448
    80006196:	ffffb097          	auipc	ra,0xffffb
    8000619a:	b50080e7          	jalr	-1200(ra) # 80000ce6 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000619e:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800061a2:	89a6                	mv	s3,s1
    800061a4:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800061a6:	02000a13          	li	s4,32
    800061aa:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800061ae:	00391513          	slli	a0,s2,0x3
    800061b2:	e3040593          	addi	a1,s0,-464
    800061b6:	e3843783          	ld	a5,-456(s0)
    800061ba:	953e                	add	a0,a0,a5
    800061bc:	ffffd097          	auipc	ra,0xffffd
    800061c0:	e34080e7          	jalr	-460(ra) # 80002ff0 <fetchaddr>
    800061c4:	02054a63          	bltz	a0,800061f8 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    800061c8:	e3043783          	ld	a5,-464(s0)
    800061cc:	c3b9                	beqz	a5,80006212 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800061ce:	ffffb097          	auipc	ra,0xffffb
    800061d2:	92c080e7          	jalr	-1748(ra) # 80000afa <kalloc>
    800061d6:	85aa                	mv	a1,a0
    800061d8:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800061dc:	cd11                	beqz	a0,800061f8 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800061de:	6605                	lui	a2,0x1
    800061e0:	e3043503          	ld	a0,-464(s0)
    800061e4:	ffffd097          	auipc	ra,0xffffd
    800061e8:	e5e080e7          	jalr	-418(ra) # 80003042 <fetchstr>
    800061ec:	00054663          	bltz	a0,800061f8 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    800061f0:	0905                	addi	s2,s2,1
    800061f2:	09a1                	addi	s3,s3,8
    800061f4:	fb491be3          	bne	s2,s4,800061aa <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800061f8:	10048913          	addi	s2,s1,256
    800061fc:	6088                	ld	a0,0(s1)
    800061fe:	c531                	beqz	a0,8000624a <sys_exec+0xf8>
    kfree(argv[i]);
    80006200:	ffffa097          	auipc	ra,0xffffa
    80006204:	7fe080e7          	jalr	2046(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006208:	04a1                	addi	s1,s1,8
    8000620a:	ff2499e3          	bne	s1,s2,800061fc <sys_exec+0xaa>
  return -1;
    8000620e:	557d                	li	a0,-1
    80006210:	a835                	j	8000624c <sys_exec+0xfa>
      argv[i] = 0;
    80006212:	0a8e                	slli	s5,s5,0x3
    80006214:	fc040793          	addi	a5,s0,-64
    80006218:	9abe                	add	s5,s5,a5
    8000621a:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    8000621e:	e4040593          	addi	a1,s0,-448
    80006222:	f4040513          	addi	a0,s0,-192
    80006226:	fffff097          	auipc	ra,0xfffff
    8000622a:	190080e7          	jalr	400(ra) # 800053b6 <exec>
    8000622e:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006230:	10048993          	addi	s3,s1,256
    80006234:	6088                	ld	a0,0(s1)
    80006236:	c901                	beqz	a0,80006246 <sys_exec+0xf4>
    kfree(argv[i]);
    80006238:	ffffa097          	auipc	ra,0xffffa
    8000623c:	7c6080e7          	jalr	1990(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006240:	04a1                	addi	s1,s1,8
    80006242:	ff3499e3          	bne	s1,s3,80006234 <sys_exec+0xe2>
  return ret;
    80006246:	854a                	mv	a0,s2
    80006248:	a011                	j	8000624c <sys_exec+0xfa>
  return -1;
    8000624a:	557d                	li	a0,-1
}
    8000624c:	60be                	ld	ra,456(sp)
    8000624e:	641e                	ld	s0,448(sp)
    80006250:	74fa                	ld	s1,440(sp)
    80006252:	795a                	ld	s2,432(sp)
    80006254:	79ba                	ld	s3,424(sp)
    80006256:	7a1a                	ld	s4,416(sp)
    80006258:	6afa                	ld	s5,408(sp)
    8000625a:	6179                	addi	sp,sp,464
    8000625c:	8082                	ret

000000008000625e <sys_pipe>:

uint64
sys_pipe(void)
{
    8000625e:	7139                	addi	sp,sp,-64
    80006260:	fc06                	sd	ra,56(sp)
    80006262:	f822                	sd	s0,48(sp)
    80006264:	f426                	sd	s1,40(sp)
    80006266:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006268:	ffffb097          	auipc	ra,0xffffb
    8000626c:	75e080e7          	jalr	1886(ra) # 800019c6 <myproc>
    80006270:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80006272:	fd840593          	addi	a1,s0,-40
    80006276:	4501                	li	a0,0
    80006278:	ffffd097          	auipc	ra,0xffffd
    8000627c:	e38080e7          	jalr	-456(ra) # 800030b0 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80006280:	fc840593          	addi	a1,s0,-56
    80006284:	fd040513          	addi	a0,s0,-48
    80006288:	fffff097          	auipc	ra,0xfffff
    8000628c:	dd6080e7          	jalr	-554(ra) # 8000505e <pipealloc>
    return -1;
    80006290:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006292:	0c054463          	bltz	a0,8000635a <sys_pipe+0xfc>
  fd0 = -1;
    80006296:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000629a:	fd043503          	ld	a0,-48(s0)
    8000629e:	fffff097          	auipc	ra,0xfffff
    800062a2:	518080e7          	jalr	1304(ra) # 800057b6 <fdalloc>
    800062a6:	fca42223          	sw	a0,-60(s0)
    800062aa:	08054b63          	bltz	a0,80006340 <sys_pipe+0xe2>
    800062ae:	fc843503          	ld	a0,-56(s0)
    800062b2:	fffff097          	auipc	ra,0xfffff
    800062b6:	504080e7          	jalr	1284(ra) # 800057b6 <fdalloc>
    800062ba:	fca42023          	sw	a0,-64(s0)
    800062be:	06054863          	bltz	a0,8000632e <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800062c2:	4691                	li	a3,4
    800062c4:	fc440613          	addi	a2,s0,-60
    800062c8:	fd843583          	ld	a1,-40(s0)
    800062cc:	68a8                	ld	a0,80(s1)
    800062ce:	ffffb097          	auipc	ra,0xffffb
    800062d2:	3b6080e7          	jalr	950(ra) # 80001684 <copyout>
    800062d6:	02054063          	bltz	a0,800062f6 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800062da:	4691                	li	a3,4
    800062dc:	fc040613          	addi	a2,s0,-64
    800062e0:	fd843583          	ld	a1,-40(s0)
    800062e4:	0591                	addi	a1,a1,4
    800062e6:	68a8                	ld	a0,80(s1)
    800062e8:	ffffb097          	auipc	ra,0xffffb
    800062ec:	39c080e7          	jalr	924(ra) # 80001684 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800062f0:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800062f2:	06055463          	bgez	a0,8000635a <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    800062f6:	fc442783          	lw	a5,-60(s0)
    800062fa:	07e9                	addi	a5,a5,26
    800062fc:	078e                	slli	a5,a5,0x3
    800062fe:	97a6                	add	a5,a5,s1
    80006300:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006304:	fc042503          	lw	a0,-64(s0)
    80006308:	0569                	addi	a0,a0,26
    8000630a:	050e                	slli	a0,a0,0x3
    8000630c:	94aa                	add	s1,s1,a0
    8000630e:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80006312:	fd043503          	ld	a0,-48(s0)
    80006316:	fffff097          	auipc	ra,0xfffff
    8000631a:	a18080e7          	jalr	-1512(ra) # 80004d2e <fileclose>
    fileclose(wf);
    8000631e:	fc843503          	ld	a0,-56(s0)
    80006322:	fffff097          	auipc	ra,0xfffff
    80006326:	a0c080e7          	jalr	-1524(ra) # 80004d2e <fileclose>
    return -1;
    8000632a:	57fd                	li	a5,-1
    8000632c:	a03d                	j	8000635a <sys_pipe+0xfc>
    if(fd0 >= 0)
    8000632e:	fc442783          	lw	a5,-60(s0)
    80006332:	0007c763          	bltz	a5,80006340 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80006336:	07e9                	addi	a5,a5,26
    80006338:	078e                	slli	a5,a5,0x3
    8000633a:	94be                	add	s1,s1,a5
    8000633c:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80006340:	fd043503          	ld	a0,-48(s0)
    80006344:	fffff097          	auipc	ra,0xfffff
    80006348:	9ea080e7          	jalr	-1558(ra) # 80004d2e <fileclose>
    fileclose(wf);
    8000634c:	fc843503          	ld	a0,-56(s0)
    80006350:	fffff097          	auipc	ra,0xfffff
    80006354:	9de080e7          	jalr	-1570(ra) # 80004d2e <fileclose>
    return -1;
    80006358:	57fd                	li	a5,-1
}
    8000635a:	853e                	mv	a0,a5
    8000635c:	70e2                	ld	ra,56(sp)
    8000635e:	7442                	ld	s0,48(sp)
    80006360:	74a2                	ld	s1,40(sp)
    80006362:	6121                	addi	sp,sp,64
    80006364:	8082                	ret
	...

0000000080006370 <kernelvec>:
    80006370:	7111                	addi	sp,sp,-256
    80006372:	e006                	sd	ra,0(sp)
    80006374:	e40a                	sd	sp,8(sp)
    80006376:	e80e                	sd	gp,16(sp)
    80006378:	ec12                	sd	tp,24(sp)
    8000637a:	f016                	sd	t0,32(sp)
    8000637c:	f41a                	sd	t1,40(sp)
    8000637e:	f81e                	sd	t2,48(sp)
    80006380:	fc22                	sd	s0,56(sp)
    80006382:	e0a6                	sd	s1,64(sp)
    80006384:	e4aa                	sd	a0,72(sp)
    80006386:	e8ae                	sd	a1,80(sp)
    80006388:	ecb2                	sd	a2,88(sp)
    8000638a:	f0b6                	sd	a3,96(sp)
    8000638c:	f4ba                	sd	a4,104(sp)
    8000638e:	f8be                	sd	a5,112(sp)
    80006390:	fcc2                	sd	a6,120(sp)
    80006392:	e146                	sd	a7,128(sp)
    80006394:	e54a                	sd	s2,136(sp)
    80006396:	e94e                	sd	s3,144(sp)
    80006398:	ed52                	sd	s4,152(sp)
    8000639a:	f156                	sd	s5,160(sp)
    8000639c:	f55a                	sd	s6,168(sp)
    8000639e:	f95e                	sd	s7,176(sp)
    800063a0:	fd62                	sd	s8,184(sp)
    800063a2:	e1e6                	sd	s9,192(sp)
    800063a4:	e5ea                	sd	s10,200(sp)
    800063a6:	e9ee                	sd	s11,208(sp)
    800063a8:	edf2                	sd	t3,216(sp)
    800063aa:	f1f6                	sd	t4,224(sp)
    800063ac:	f5fa                	sd	t5,232(sp)
    800063ae:	f9fe                	sd	t6,240(sp)
    800063b0:	b0dfc0ef          	jal	ra,80002ebc <kerneltrap>
    800063b4:	6082                	ld	ra,0(sp)
    800063b6:	6122                	ld	sp,8(sp)
    800063b8:	61c2                	ld	gp,16(sp)
    800063ba:	7282                	ld	t0,32(sp)
    800063bc:	7322                	ld	t1,40(sp)
    800063be:	73c2                	ld	t2,48(sp)
    800063c0:	7462                	ld	s0,56(sp)
    800063c2:	6486                	ld	s1,64(sp)
    800063c4:	6526                	ld	a0,72(sp)
    800063c6:	65c6                	ld	a1,80(sp)
    800063c8:	6666                	ld	a2,88(sp)
    800063ca:	7686                	ld	a3,96(sp)
    800063cc:	7726                	ld	a4,104(sp)
    800063ce:	77c6                	ld	a5,112(sp)
    800063d0:	7866                	ld	a6,120(sp)
    800063d2:	688a                	ld	a7,128(sp)
    800063d4:	692a                	ld	s2,136(sp)
    800063d6:	69ca                	ld	s3,144(sp)
    800063d8:	6a6a                	ld	s4,152(sp)
    800063da:	7a8a                	ld	s5,160(sp)
    800063dc:	7b2a                	ld	s6,168(sp)
    800063de:	7bca                	ld	s7,176(sp)
    800063e0:	7c6a                	ld	s8,184(sp)
    800063e2:	6c8e                	ld	s9,192(sp)
    800063e4:	6d2e                	ld	s10,200(sp)
    800063e6:	6dce                	ld	s11,208(sp)
    800063e8:	6e6e                	ld	t3,216(sp)
    800063ea:	7e8e                	ld	t4,224(sp)
    800063ec:	7f2e                	ld	t5,232(sp)
    800063ee:	7fce                	ld	t6,240(sp)
    800063f0:	6111                	addi	sp,sp,256
    800063f2:	10200073          	sret
    800063f6:	00000013          	nop
    800063fa:	00000013          	nop
    800063fe:	0001                	nop

0000000080006400 <timervec>:
    80006400:	34051573          	csrrw	a0,mscratch,a0
    80006404:	e10c                	sd	a1,0(a0)
    80006406:	e510                	sd	a2,8(a0)
    80006408:	e914                	sd	a3,16(a0)
    8000640a:	6d0c                	ld	a1,24(a0)
    8000640c:	7110                	ld	a2,32(a0)
    8000640e:	6194                	ld	a3,0(a1)
    80006410:	96b2                	add	a3,a3,a2
    80006412:	e194                	sd	a3,0(a1)
    80006414:	4589                	li	a1,2
    80006416:	14459073          	csrw	sip,a1
    8000641a:	6914                	ld	a3,16(a0)
    8000641c:	6510                	ld	a2,8(a0)
    8000641e:	610c                	ld	a1,0(a0)
    80006420:	34051573          	csrrw	a0,mscratch,a0
    80006424:	30200073          	mret
	...

000000008000642a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000642a:	1141                	addi	sp,sp,-16
    8000642c:	e422                	sd	s0,8(sp)
    8000642e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006430:	0c0007b7          	lui	a5,0xc000
    80006434:	4705                	li	a4,1
    80006436:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006438:	c3d8                	sw	a4,4(a5)
}
    8000643a:	6422                	ld	s0,8(sp)
    8000643c:	0141                	addi	sp,sp,16
    8000643e:	8082                	ret

0000000080006440 <plicinithart>:

void
plicinithart(void)
{
    80006440:	1141                	addi	sp,sp,-16
    80006442:	e406                	sd	ra,8(sp)
    80006444:	e022                	sd	s0,0(sp)
    80006446:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006448:	ffffb097          	auipc	ra,0xffffb
    8000644c:	552080e7          	jalr	1362(ra) # 8000199a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006450:	0085171b          	slliw	a4,a0,0x8
    80006454:	0c0027b7          	lui	a5,0xc002
    80006458:	97ba                	add	a5,a5,a4
    8000645a:	40200713          	li	a4,1026
    8000645e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006462:	00d5151b          	slliw	a0,a0,0xd
    80006466:	0c2017b7          	lui	a5,0xc201
    8000646a:	953e                	add	a0,a0,a5
    8000646c:	00052023          	sw	zero,0(a0)
}
    80006470:	60a2                	ld	ra,8(sp)
    80006472:	6402                	ld	s0,0(sp)
    80006474:	0141                	addi	sp,sp,16
    80006476:	8082                	ret

0000000080006478 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006478:	1141                	addi	sp,sp,-16
    8000647a:	e406                	sd	ra,8(sp)
    8000647c:	e022                	sd	s0,0(sp)
    8000647e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006480:	ffffb097          	auipc	ra,0xffffb
    80006484:	51a080e7          	jalr	1306(ra) # 8000199a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006488:	00d5179b          	slliw	a5,a0,0xd
    8000648c:	0c201537          	lui	a0,0xc201
    80006490:	953e                	add	a0,a0,a5
  return irq;
}
    80006492:	4148                	lw	a0,4(a0)
    80006494:	60a2                	ld	ra,8(sp)
    80006496:	6402                	ld	s0,0(sp)
    80006498:	0141                	addi	sp,sp,16
    8000649a:	8082                	ret

000000008000649c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000649c:	1101                	addi	sp,sp,-32
    8000649e:	ec06                	sd	ra,24(sp)
    800064a0:	e822                	sd	s0,16(sp)
    800064a2:	e426                	sd	s1,8(sp)
    800064a4:	1000                	addi	s0,sp,32
    800064a6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800064a8:	ffffb097          	auipc	ra,0xffffb
    800064ac:	4f2080e7          	jalr	1266(ra) # 8000199a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800064b0:	00d5151b          	slliw	a0,a0,0xd
    800064b4:	0c2017b7          	lui	a5,0xc201
    800064b8:	97aa                	add	a5,a5,a0
    800064ba:	c3c4                	sw	s1,4(a5)
}
    800064bc:	60e2                	ld	ra,24(sp)
    800064be:	6442                	ld	s0,16(sp)
    800064c0:	64a2                	ld	s1,8(sp)
    800064c2:	6105                	addi	sp,sp,32
    800064c4:	8082                	ret

00000000800064c6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800064c6:	1141                	addi	sp,sp,-16
    800064c8:	e406                	sd	ra,8(sp)
    800064ca:	e022                	sd	s0,0(sp)
    800064cc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800064ce:	479d                	li	a5,7
    800064d0:	04a7cc63          	blt	a5,a0,80006528 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800064d4:	0001d797          	auipc	a5,0x1d
    800064d8:	78c78793          	addi	a5,a5,1932 # 80023c60 <disk>
    800064dc:	97aa                	add	a5,a5,a0
    800064de:	0187c783          	lbu	a5,24(a5)
    800064e2:	ebb9                	bnez	a5,80006538 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800064e4:	00451613          	slli	a2,a0,0x4
    800064e8:	0001d797          	auipc	a5,0x1d
    800064ec:	77878793          	addi	a5,a5,1912 # 80023c60 <disk>
    800064f0:	6394                	ld	a3,0(a5)
    800064f2:	96b2                	add	a3,a3,a2
    800064f4:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800064f8:	6398                	ld	a4,0(a5)
    800064fa:	9732                	add	a4,a4,a2
    800064fc:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006500:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006504:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006508:	953e                	add	a0,a0,a5
    8000650a:	4785                	li	a5,1
    8000650c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006510:	0001d517          	auipc	a0,0x1d
    80006514:	76850513          	addi	a0,a0,1896 # 80023c78 <disk+0x18>
    80006518:	ffffc097          	auipc	ra,0xffffc
    8000651c:	0b0080e7          	jalr	176(ra) # 800025c8 <wakeup>
}
    80006520:	60a2                	ld	ra,8(sp)
    80006522:	6402                	ld	s0,0(sp)
    80006524:	0141                	addi	sp,sp,16
    80006526:	8082                	ret
    panic("free_desc 1");
    80006528:	00002517          	auipc	a0,0x2
    8000652c:	36050513          	addi	a0,a0,864 # 80008888 <syscallnum+0x2a8>
    80006530:	ffffa097          	auipc	ra,0xffffa
    80006534:	014080e7          	jalr	20(ra) # 80000544 <panic>
    panic("free_desc 2");
    80006538:	00002517          	auipc	a0,0x2
    8000653c:	36050513          	addi	a0,a0,864 # 80008898 <syscallnum+0x2b8>
    80006540:	ffffa097          	auipc	ra,0xffffa
    80006544:	004080e7          	jalr	4(ra) # 80000544 <panic>

0000000080006548 <virtio_disk_init>:
{
    80006548:	1101                	addi	sp,sp,-32
    8000654a:	ec06                	sd	ra,24(sp)
    8000654c:	e822                	sd	s0,16(sp)
    8000654e:	e426                	sd	s1,8(sp)
    80006550:	e04a                	sd	s2,0(sp)
    80006552:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006554:	00002597          	auipc	a1,0x2
    80006558:	35458593          	addi	a1,a1,852 # 800088a8 <syscallnum+0x2c8>
    8000655c:	0001e517          	auipc	a0,0x1e
    80006560:	82c50513          	addi	a0,a0,-2004 # 80023d88 <disk+0x128>
    80006564:	ffffa097          	auipc	ra,0xffffa
    80006568:	5f6080e7          	jalr	1526(ra) # 80000b5a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000656c:	100017b7          	lui	a5,0x10001
    80006570:	4398                	lw	a4,0(a5)
    80006572:	2701                	sext.w	a4,a4
    80006574:	747277b7          	lui	a5,0x74727
    80006578:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000657c:	14f71e63          	bne	a4,a5,800066d8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006580:	100017b7          	lui	a5,0x10001
    80006584:	43dc                	lw	a5,4(a5)
    80006586:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006588:	4709                	li	a4,2
    8000658a:	14e79763          	bne	a5,a4,800066d8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000658e:	100017b7          	lui	a5,0x10001
    80006592:	479c                	lw	a5,8(a5)
    80006594:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006596:	14e79163          	bne	a5,a4,800066d8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000659a:	100017b7          	lui	a5,0x10001
    8000659e:	47d8                	lw	a4,12(a5)
    800065a0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800065a2:	554d47b7          	lui	a5,0x554d4
    800065a6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800065aa:	12f71763          	bne	a4,a5,800066d8 <virtio_disk_init+0x190>
  *R(VIRTIO_MMIO_STATUS) = status;
    800065ae:	100017b7          	lui	a5,0x10001
    800065b2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800065b6:	4705                	li	a4,1
    800065b8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800065ba:	470d                	li	a4,3
    800065bc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800065be:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800065c0:	c7ffe737          	lui	a4,0xc7ffe
    800065c4:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fda9bf>
    800065c8:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800065ca:	2701                	sext.w	a4,a4
    800065cc:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800065ce:	472d                	li	a4,11
    800065d0:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800065d2:	0707a903          	lw	s2,112(a5)
    800065d6:	2901                	sext.w	s2,s2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800065d8:	00897793          	andi	a5,s2,8
    800065dc:	10078663          	beqz	a5,800066e8 <virtio_disk_init+0x1a0>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800065e0:	100017b7          	lui	a5,0x10001
    800065e4:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800065e8:	43fc                	lw	a5,68(a5)
    800065ea:	2781                	sext.w	a5,a5
    800065ec:	10079663          	bnez	a5,800066f8 <virtio_disk_init+0x1b0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800065f0:	100017b7          	lui	a5,0x10001
    800065f4:	5bdc                	lw	a5,52(a5)
    800065f6:	2781                	sext.w	a5,a5
  if(max == 0)
    800065f8:	10078863          	beqz	a5,80006708 <virtio_disk_init+0x1c0>
  if(max < NUM)
    800065fc:	471d                	li	a4,7
    800065fe:	10f77d63          	bgeu	a4,a5,80006718 <virtio_disk_init+0x1d0>
  disk.desc = kalloc();
    80006602:	ffffa097          	auipc	ra,0xffffa
    80006606:	4f8080e7          	jalr	1272(ra) # 80000afa <kalloc>
    8000660a:	0001d497          	auipc	s1,0x1d
    8000660e:	65648493          	addi	s1,s1,1622 # 80023c60 <disk>
    80006612:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006614:	ffffa097          	auipc	ra,0xffffa
    80006618:	4e6080e7          	jalr	1254(ra) # 80000afa <kalloc>
    8000661c:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000661e:	ffffa097          	auipc	ra,0xffffa
    80006622:	4dc080e7          	jalr	1244(ra) # 80000afa <kalloc>
    80006626:	87aa                	mv	a5,a0
    80006628:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    8000662a:	6088                	ld	a0,0(s1)
    8000662c:	cd75                	beqz	a0,80006728 <virtio_disk_init+0x1e0>
    8000662e:	0001d717          	auipc	a4,0x1d
    80006632:	63a73703          	ld	a4,1594(a4) # 80023c68 <disk+0x8>
    80006636:	cb6d                	beqz	a4,80006728 <virtio_disk_init+0x1e0>
    80006638:	cbe5                	beqz	a5,80006728 <virtio_disk_init+0x1e0>
  memset(disk.desc, 0, PGSIZE);
    8000663a:	6605                	lui	a2,0x1
    8000663c:	4581                	li	a1,0
    8000663e:	ffffa097          	auipc	ra,0xffffa
    80006642:	6a8080e7          	jalr	1704(ra) # 80000ce6 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006646:	0001d497          	auipc	s1,0x1d
    8000664a:	61a48493          	addi	s1,s1,1562 # 80023c60 <disk>
    8000664e:	6605                	lui	a2,0x1
    80006650:	4581                	li	a1,0
    80006652:	6488                	ld	a0,8(s1)
    80006654:	ffffa097          	auipc	ra,0xffffa
    80006658:	692080e7          	jalr	1682(ra) # 80000ce6 <memset>
  memset(disk.used, 0, PGSIZE);
    8000665c:	6605                	lui	a2,0x1
    8000665e:	4581                	li	a1,0
    80006660:	6888                	ld	a0,16(s1)
    80006662:	ffffa097          	auipc	ra,0xffffa
    80006666:	684080e7          	jalr	1668(ra) # 80000ce6 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000666a:	100017b7          	lui	a5,0x10001
    8000666e:	4721                	li	a4,8
    80006670:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006672:	4098                	lw	a4,0(s1)
    80006674:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006678:	40d8                	lw	a4,4(s1)
    8000667a:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000667e:	6498                	ld	a4,8(s1)
    80006680:	0007069b          	sext.w	a3,a4
    80006684:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006688:	9701                	srai	a4,a4,0x20
    8000668a:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000668e:	6898                	ld	a4,16(s1)
    80006690:	0007069b          	sext.w	a3,a4
    80006694:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006698:	9701                	srai	a4,a4,0x20
    8000669a:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000669e:	4685                	li	a3,1
    800066a0:	c3f4                	sw	a3,68(a5)
    disk.free[i] = 1;
    800066a2:	4705                	li	a4,1
    800066a4:	00d48c23          	sb	a3,24(s1)
    800066a8:	00e48ca3          	sb	a4,25(s1)
    800066ac:	00e48d23          	sb	a4,26(s1)
    800066b0:	00e48da3          	sb	a4,27(s1)
    800066b4:	00e48e23          	sb	a4,28(s1)
    800066b8:	00e48ea3          	sb	a4,29(s1)
    800066bc:	00e48f23          	sb	a4,30(s1)
    800066c0:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800066c4:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800066c8:	0727a823          	sw	s2,112(a5)
}
    800066cc:	60e2                	ld	ra,24(sp)
    800066ce:	6442                	ld	s0,16(sp)
    800066d0:	64a2                	ld	s1,8(sp)
    800066d2:	6902                	ld	s2,0(sp)
    800066d4:	6105                	addi	sp,sp,32
    800066d6:	8082                	ret
    panic("could not find virtio disk");
    800066d8:	00002517          	auipc	a0,0x2
    800066dc:	1e050513          	addi	a0,a0,480 # 800088b8 <syscallnum+0x2d8>
    800066e0:	ffffa097          	auipc	ra,0xffffa
    800066e4:	e64080e7          	jalr	-412(ra) # 80000544 <panic>
    panic("virtio disk FEATURES_OK unset");
    800066e8:	00002517          	auipc	a0,0x2
    800066ec:	1f050513          	addi	a0,a0,496 # 800088d8 <syscallnum+0x2f8>
    800066f0:	ffffa097          	auipc	ra,0xffffa
    800066f4:	e54080e7          	jalr	-428(ra) # 80000544 <panic>
    panic("virtio disk should not be ready");
    800066f8:	00002517          	auipc	a0,0x2
    800066fc:	20050513          	addi	a0,a0,512 # 800088f8 <syscallnum+0x318>
    80006700:	ffffa097          	auipc	ra,0xffffa
    80006704:	e44080e7          	jalr	-444(ra) # 80000544 <panic>
    panic("virtio disk has no queue 0");
    80006708:	00002517          	auipc	a0,0x2
    8000670c:	21050513          	addi	a0,a0,528 # 80008918 <syscallnum+0x338>
    80006710:	ffffa097          	auipc	ra,0xffffa
    80006714:	e34080e7          	jalr	-460(ra) # 80000544 <panic>
    panic("virtio disk max queue too short");
    80006718:	00002517          	auipc	a0,0x2
    8000671c:	22050513          	addi	a0,a0,544 # 80008938 <syscallnum+0x358>
    80006720:	ffffa097          	auipc	ra,0xffffa
    80006724:	e24080e7          	jalr	-476(ra) # 80000544 <panic>
    panic("virtio disk kalloc");
    80006728:	00002517          	auipc	a0,0x2
    8000672c:	23050513          	addi	a0,a0,560 # 80008958 <syscallnum+0x378>
    80006730:	ffffa097          	auipc	ra,0xffffa
    80006734:	e14080e7          	jalr	-492(ra) # 80000544 <panic>

0000000080006738 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006738:	7159                	addi	sp,sp,-112
    8000673a:	f486                	sd	ra,104(sp)
    8000673c:	f0a2                	sd	s0,96(sp)
    8000673e:	eca6                	sd	s1,88(sp)
    80006740:	e8ca                	sd	s2,80(sp)
    80006742:	e4ce                	sd	s3,72(sp)
    80006744:	e0d2                	sd	s4,64(sp)
    80006746:	fc56                	sd	s5,56(sp)
    80006748:	f85a                	sd	s6,48(sp)
    8000674a:	f45e                	sd	s7,40(sp)
    8000674c:	f062                	sd	s8,32(sp)
    8000674e:	ec66                	sd	s9,24(sp)
    80006750:	e86a                	sd	s10,16(sp)
    80006752:	1880                	addi	s0,sp,112
    80006754:	892a                	mv	s2,a0
    80006756:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006758:	00c52c83          	lw	s9,12(a0)
    8000675c:	001c9c9b          	slliw	s9,s9,0x1
    80006760:	1c82                	slli	s9,s9,0x20
    80006762:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006766:	0001d517          	auipc	a0,0x1d
    8000676a:	62250513          	addi	a0,a0,1570 # 80023d88 <disk+0x128>
    8000676e:	ffffa097          	auipc	ra,0xffffa
    80006772:	47c080e7          	jalr	1148(ra) # 80000bea <acquire>
  for(int i = 0; i < 3; i++){
    80006776:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006778:	4ba1                	li	s7,8
      disk.free[i] = 0;
    8000677a:	0001db17          	auipc	s6,0x1d
    8000677e:	4e6b0b13          	addi	s6,s6,1254 # 80023c60 <disk>
  for(int i = 0; i < 3; i++){
    80006782:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80006784:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006786:	0001dc17          	auipc	s8,0x1d
    8000678a:	602c0c13          	addi	s8,s8,1538 # 80023d88 <disk+0x128>
    8000678e:	a8b5                	j	8000680a <virtio_disk_rw+0xd2>
      disk.free[i] = 0;
    80006790:	00fb06b3          	add	a3,s6,a5
    80006794:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006798:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000679a:	0207c563          	bltz	a5,800067c4 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000679e:	2485                	addiw	s1,s1,1
    800067a0:	0711                	addi	a4,a4,4
    800067a2:	1f548a63          	beq	s1,s5,80006996 <virtio_disk_rw+0x25e>
    idx[i] = alloc_desc();
    800067a6:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    800067a8:	0001d697          	auipc	a3,0x1d
    800067ac:	4b868693          	addi	a3,a3,1208 # 80023c60 <disk>
    800067b0:	87d2                	mv	a5,s4
    if(disk.free[i]){
    800067b2:	0186c583          	lbu	a1,24(a3)
    800067b6:	fde9                	bnez	a1,80006790 <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800067b8:	2785                	addiw	a5,a5,1
    800067ba:	0685                	addi	a3,a3,1
    800067bc:	ff779be3          	bne	a5,s7,800067b2 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800067c0:	57fd                	li	a5,-1
    800067c2:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    800067c4:	02905a63          	blez	s1,800067f8 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800067c8:	f9042503          	lw	a0,-112(s0)
    800067cc:	00000097          	auipc	ra,0x0
    800067d0:	cfa080e7          	jalr	-774(ra) # 800064c6 <free_desc>
      for(int j = 0; j < i; j++)
    800067d4:	4785                	li	a5,1
    800067d6:	0297d163          	bge	a5,s1,800067f8 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800067da:	f9442503          	lw	a0,-108(s0)
    800067de:	00000097          	auipc	ra,0x0
    800067e2:	ce8080e7          	jalr	-792(ra) # 800064c6 <free_desc>
      for(int j = 0; j < i; j++)
    800067e6:	4789                	li	a5,2
    800067e8:	0097d863          	bge	a5,s1,800067f8 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800067ec:	f9842503          	lw	a0,-104(s0)
    800067f0:	00000097          	auipc	ra,0x0
    800067f4:	cd6080e7          	jalr	-810(ra) # 800064c6 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800067f8:	85e2                	mv	a1,s8
    800067fa:	0001d517          	auipc	a0,0x1d
    800067fe:	47e50513          	addi	a0,a0,1150 # 80023c78 <disk+0x18>
    80006802:	ffffc097          	auipc	ra,0xffffc
    80006806:	c16080e7          	jalr	-1002(ra) # 80002418 <sleep>
  for(int i = 0; i < 3; i++){
    8000680a:	f9040713          	addi	a4,s0,-112
    8000680e:	84ce                	mv	s1,s3
    80006810:	bf59                	j	800067a6 <virtio_disk_rw+0x6e>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80006812:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    80006816:	00479693          	slli	a3,a5,0x4
    8000681a:	0001d797          	auipc	a5,0x1d
    8000681e:	44678793          	addi	a5,a5,1094 # 80023c60 <disk>
    80006822:	97b6                	add	a5,a5,a3
    80006824:	4685                	li	a3,1
    80006826:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006828:	0001d597          	auipc	a1,0x1d
    8000682c:	43858593          	addi	a1,a1,1080 # 80023c60 <disk>
    80006830:	00a60793          	addi	a5,a2,10
    80006834:	0792                	slli	a5,a5,0x4
    80006836:	97ae                	add	a5,a5,a1
    80006838:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    8000683c:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006840:	f6070693          	addi	a3,a4,-160
    80006844:	619c                	ld	a5,0(a1)
    80006846:	97b6                	add	a5,a5,a3
    80006848:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000684a:	6188                	ld	a0,0(a1)
    8000684c:	96aa                	add	a3,a3,a0
    8000684e:	47c1                	li	a5,16
    80006850:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006852:	4785                	li	a5,1
    80006854:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006858:	f9442783          	lw	a5,-108(s0)
    8000685c:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006860:	0792                	slli	a5,a5,0x4
    80006862:	953e                	add	a0,a0,a5
    80006864:	05890693          	addi	a3,s2,88
    80006868:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000686a:	6188                	ld	a0,0(a1)
    8000686c:	97aa                	add	a5,a5,a0
    8000686e:	40000693          	li	a3,1024
    80006872:	c794                	sw	a3,8(a5)
  if(write)
    80006874:	100d0d63          	beqz	s10,8000698e <virtio_disk_rw+0x256>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006878:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000687c:	00c7d683          	lhu	a3,12(a5)
    80006880:	0016e693          	ori	a3,a3,1
    80006884:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    80006888:	f9842583          	lw	a1,-104(s0)
    8000688c:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006890:	0001d697          	auipc	a3,0x1d
    80006894:	3d068693          	addi	a3,a3,976 # 80023c60 <disk>
    80006898:	00260793          	addi	a5,a2,2
    8000689c:	0792                	slli	a5,a5,0x4
    8000689e:	97b6                	add	a5,a5,a3
    800068a0:	587d                	li	a6,-1
    800068a2:	01078823          	sb	a6,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800068a6:	0592                	slli	a1,a1,0x4
    800068a8:	952e                	add	a0,a0,a1
    800068aa:	f9070713          	addi	a4,a4,-112
    800068ae:	9736                	add	a4,a4,a3
    800068b0:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    800068b2:	6298                	ld	a4,0(a3)
    800068b4:	972e                	add	a4,a4,a1
    800068b6:	4585                	li	a1,1
    800068b8:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800068ba:	4509                	li	a0,2
    800068bc:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    800068c0:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800068c4:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    800068c8:	0127b423          	sd	s2,8(a5)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800068cc:	6698                	ld	a4,8(a3)
    800068ce:	00275783          	lhu	a5,2(a4)
    800068d2:	8b9d                	andi	a5,a5,7
    800068d4:	0786                	slli	a5,a5,0x1
    800068d6:	97ba                	add	a5,a5,a4
    800068d8:	00c79223          	sh	a2,4(a5)

  __sync_synchronize();
    800068dc:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800068e0:	6698                	ld	a4,8(a3)
    800068e2:	00275783          	lhu	a5,2(a4)
    800068e6:	2785                	addiw	a5,a5,1
    800068e8:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800068ec:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800068f0:	100017b7          	lui	a5,0x10001
    800068f4:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800068f8:	00492703          	lw	a4,4(s2)
    800068fc:	4785                	li	a5,1
    800068fe:	02f71163          	bne	a4,a5,80006920 <virtio_disk_rw+0x1e8>
    sleep(b, &disk.vdisk_lock);
    80006902:	0001d997          	auipc	s3,0x1d
    80006906:	48698993          	addi	s3,s3,1158 # 80023d88 <disk+0x128>
  while(b->disk == 1) {
    8000690a:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000690c:	85ce                	mv	a1,s3
    8000690e:	854a                	mv	a0,s2
    80006910:	ffffc097          	auipc	ra,0xffffc
    80006914:	b08080e7          	jalr	-1272(ra) # 80002418 <sleep>
  while(b->disk == 1) {
    80006918:	00492783          	lw	a5,4(s2)
    8000691c:	fe9788e3          	beq	a5,s1,8000690c <virtio_disk_rw+0x1d4>
  }

  disk.info[idx[0]].b = 0;
    80006920:	f9042903          	lw	s2,-112(s0)
    80006924:	00290793          	addi	a5,s2,2
    80006928:	00479713          	slli	a4,a5,0x4
    8000692c:	0001d797          	auipc	a5,0x1d
    80006930:	33478793          	addi	a5,a5,820 # 80023c60 <disk>
    80006934:	97ba                	add	a5,a5,a4
    80006936:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000693a:	0001d997          	auipc	s3,0x1d
    8000693e:	32698993          	addi	s3,s3,806 # 80023c60 <disk>
    80006942:	00491713          	slli	a4,s2,0x4
    80006946:	0009b783          	ld	a5,0(s3)
    8000694a:	97ba                	add	a5,a5,a4
    8000694c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006950:	854a                	mv	a0,s2
    80006952:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006956:	00000097          	auipc	ra,0x0
    8000695a:	b70080e7          	jalr	-1168(ra) # 800064c6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000695e:	8885                	andi	s1,s1,1
    80006960:	f0ed                	bnez	s1,80006942 <virtio_disk_rw+0x20a>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006962:	0001d517          	auipc	a0,0x1d
    80006966:	42650513          	addi	a0,a0,1062 # 80023d88 <disk+0x128>
    8000696a:	ffffa097          	auipc	ra,0xffffa
    8000696e:	334080e7          	jalr	820(ra) # 80000c9e <release>
}
    80006972:	70a6                	ld	ra,104(sp)
    80006974:	7406                	ld	s0,96(sp)
    80006976:	64e6                	ld	s1,88(sp)
    80006978:	6946                	ld	s2,80(sp)
    8000697a:	69a6                	ld	s3,72(sp)
    8000697c:	6a06                	ld	s4,64(sp)
    8000697e:	7ae2                	ld	s5,56(sp)
    80006980:	7b42                	ld	s6,48(sp)
    80006982:	7ba2                	ld	s7,40(sp)
    80006984:	7c02                	ld	s8,32(sp)
    80006986:	6ce2                	ld	s9,24(sp)
    80006988:	6d42                	ld	s10,16(sp)
    8000698a:	6165                	addi	sp,sp,112
    8000698c:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000698e:	4689                	li	a3,2
    80006990:	00d79623          	sh	a3,12(a5)
    80006994:	b5e5                	j	8000687c <virtio_disk_rw+0x144>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006996:	f9042603          	lw	a2,-112(s0)
    8000699a:	00a60713          	addi	a4,a2,10
    8000699e:	0712                	slli	a4,a4,0x4
    800069a0:	0001d517          	auipc	a0,0x1d
    800069a4:	2c850513          	addi	a0,a0,712 # 80023c68 <disk+0x8>
    800069a8:	953a                	add	a0,a0,a4
  if(write)
    800069aa:	e60d14e3          	bnez	s10,80006812 <virtio_disk_rw+0xda>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    800069ae:	00a60793          	addi	a5,a2,10
    800069b2:	00479693          	slli	a3,a5,0x4
    800069b6:	0001d797          	auipc	a5,0x1d
    800069ba:	2aa78793          	addi	a5,a5,682 # 80023c60 <disk>
    800069be:	97b6                	add	a5,a5,a3
    800069c0:	0007a423          	sw	zero,8(a5)
    800069c4:	b595                	j	80006828 <virtio_disk_rw+0xf0>

00000000800069c6 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800069c6:	1101                	addi	sp,sp,-32
    800069c8:	ec06                	sd	ra,24(sp)
    800069ca:	e822                	sd	s0,16(sp)
    800069cc:	e426                	sd	s1,8(sp)
    800069ce:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800069d0:	0001d497          	auipc	s1,0x1d
    800069d4:	29048493          	addi	s1,s1,656 # 80023c60 <disk>
    800069d8:	0001d517          	auipc	a0,0x1d
    800069dc:	3b050513          	addi	a0,a0,944 # 80023d88 <disk+0x128>
    800069e0:	ffffa097          	auipc	ra,0xffffa
    800069e4:	20a080e7          	jalr	522(ra) # 80000bea <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800069e8:	10001737          	lui	a4,0x10001
    800069ec:	533c                	lw	a5,96(a4)
    800069ee:	8b8d                	andi	a5,a5,3
    800069f0:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800069f2:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800069f6:	689c                	ld	a5,16(s1)
    800069f8:	0204d703          	lhu	a4,32(s1)
    800069fc:	0027d783          	lhu	a5,2(a5)
    80006a00:	04f70863          	beq	a4,a5,80006a50 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006a04:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006a08:	6898                	ld	a4,16(s1)
    80006a0a:	0204d783          	lhu	a5,32(s1)
    80006a0e:	8b9d                	andi	a5,a5,7
    80006a10:	078e                	slli	a5,a5,0x3
    80006a12:	97ba                	add	a5,a5,a4
    80006a14:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006a16:	00278713          	addi	a4,a5,2
    80006a1a:	0712                	slli	a4,a4,0x4
    80006a1c:	9726                	add	a4,a4,s1
    80006a1e:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006a22:	e721                	bnez	a4,80006a6a <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006a24:	0789                	addi	a5,a5,2
    80006a26:	0792                	slli	a5,a5,0x4
    80006a28:	97a6                	add	a5,a5,s1
    80006a2a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006a2c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006a30:	ffffc097          	auipc	ra,0xffffc
    80006a34:	b98080e7          	jalr	-1128(ra) # 800025c8 <wakeup>

    disk.used_idx += 1;
    80006a38:	0204d783          	lhu	a5,32(s1)
    80006a3c:	2785                	addiw	a5,a5,1
    80006a3e:	17c2                	slli	a5,a5,0x30
    80006a40:	93c1                	srli	a5,a5,0x30
    80006a42:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006a46:	6898                	ld	a4,16(s1)
    80006a48:	00275703          	lhu	a4,2(a4)
    80006a4c:	faf71ce3          	bne	a4,a5,80006a04 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006a50:	0001d517          	auipc	a0,0x1d
    80006a54:	33850513          	addi	a0,a0,824 # 80023d88 <disk+0x128>
    80006a58:	ffffa097          	auipc	ra,0xffffa
    80006a5c:	246080e7          	jalr	582(ra) # 80000c9e <release>
}
    80006a60:	60e2                	ld	ra,24(sp)
    80006a62:	6442                	ld	s0,16(sp)
    80006a64:	64a2                	ld	s1,8(sp)
    80006a66:	6105                	addi	sp,sp,32
    80006a68:	8082                	ret
      panic("virtio_disk_intr status");
    80006a6a:	00002517          	auipc	a0,0x2
    80006a6e:	f0650513          	addi	a0,a0,-250 # 80008970 <syscallnum+0x390>
    80006a72:	ffffa097          	auipc	ra,0xffffa
    80006a76:	ad2080e7          	jalr	-1326(ra) # 80000544 <panic>
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

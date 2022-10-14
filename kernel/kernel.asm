
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
    80000068:	1bc78793          	addi	a5,a5,444 # 80006220 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffda9df>
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
    80000130:	692080e7          	jalr	1682(ra) # 800027be <either_copyin>
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
    800001d0:	43c080e7          	jalr	1084(ra) # 80002608 <killed>
    800001d4:	e535                	bnez	a0,80000240 <consoleread+0xdc>
      sleep(&cons.r, &cons.lock);
    800001d6:	85ce                	mv	a1,s3
    800001d8:	854a                	mv	a0,s2
    800001da:	00002097          	auipc	ra,0x2
    800001de:	02e080e7          	jalr	46(ra) # 80002208 <sleep>
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
    8000021a:	552080e7          	jalr	1362(ra) # 80002768 <either_copyout>
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
    800002fc:	51c080e7          	jalr	1308(ra) # 80002814 <procdump>
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
    80000450:	f6c080e7          	jalr	-148(ra) # 800023b8 <wakeup>
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
    80000482:	80a78793          	addi	a5,a5,-2038 # 80022c88 <devsw>
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
    800008aa:	b12080e7          	jalr	-1262(ra) # 800023b8 <wakeup>
    
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
    80000934:	8d8080e7          	jalr	-1832(ra) # 80002208 <sleep>
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
    80000a12:	00023797          	auipc	a5,0x23
    80000a16:	40e78793          	addi	a5,a5,1038 # 80023e20 <end>
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
    80000ae6:	33e50513          	addi	a0,a0,830 # 80023e20 <end>
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
    80000ede:	b36080e7          	jalr	-1226(ra) # 80002a10 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ee2:	00005097          	auipc	ra,0x5
    80000ee6:	37e080e7          	jalr	894(ra) # 80006260 <plicinithart>
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
    80000f56:	a96080e7          	jalr	-1386(ra) # 800029e8 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f5a:	00002097          	auipc	ra,0x2
    80000f5e:	ab6080e7          	jalr	-1354(ra) # 80002a10 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	2e8080e7          	jalr	744(ra) # 8000624a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f6a:	00005097          	auipc	ra,0x5
    80000f6e:	2f6080e7          	jalr	758(ra) # 80006260 <plicinithart>
    binit();         // buffer cache
    80000f72:	00002097          	auipc	ra,0x2
    80000f76:	4a4080e7          	jalr	1188(ra) # 80003416 <binit>
    iinit();         // inode table
    80000f7a:	00003097          	auipc	ra,0x3
    80000f7e:	b48080e7          	jalr	-1208(ra) # 80003ac2 <iinit>
    fileinit();      // file table
    80000f82:	00004097          	auipc	ra,0x4
    80000f86:	ae6080e7          	jalr	-1306(ra) # 80004a68 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f8a:	00005097          	auipc	ra,0x5
    80000f8e:	3de080e7          	jalr	990(ra) # 80006368 <virtio_disk_init>
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
    80001884:	1c0a0a13          	addi	s4,s4,448 # 80018a40 <tickslock>
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
    80001950:	0f498993          	addi	s3,s3,244 # 80018a40 <tickslock>
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
    80001a1a:	ffa7a783          	lw	a5,-6(a5) # 80008a10 <first.1744>
    80001a1e:	eb89                	bnez	a5,80001a30 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a20:	00001097          	auipc	ra,0x1
    80001a24:	008080e7          	jalr	8(ra) # 80002a28 <usertrapret>
}
    80001a28:	60a2                	ld	ra,8(sp)
    80001a2a:	6402                	ld	s0,0(sp)
    80001a2c:	0141                	addi	sp,sp,16
    80001a2e:	8082                	ret
    first = 0;
    80001a30:	00007797          	auipc	a5,0x7
    80001a34:	fe07a023          	sw	zero,-32(a5) # 80008a10 <first.1744>
    fsinit(ROOTDEV);
    80001a38:	4505                	li	a0,1
    80001a3a:	00002097          	auipc	ra,0x2
    80001a3e:	008080e7          	jalr	8(ra) # 80003a42 <fsinit>
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
    80001be8:	e5c90913          	addi	s2,s2,-420 # 80018a40 <tickslock>
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
    80001cba:	12a78793          	addi	a5,a5,298 # 80010de0 <pid_lock>
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
    80001d72:	00002097          	auipc	ra,0x2
    80001d76:	6f2080e7          	jalr	1778(ra) # 80004464 <namei>
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
    80001e9c:	c62080e7          	jalr	-926(ra) # 80004afa <filedup>
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
    80001ebe:	dc6080e7          	jalr	-570(ra) # 80003c80 <idup>
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
    80001f80:	2c448493          	addi	s1,s1,708 # 80011240 <proc>
    if (p->state == RUNNING)
    80001f84:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++)
    80001f86:	00017917          	auipc	s2,0x17
    80001f8a:	aba90913          	addi	s2,s2,-1350 # 80018a40 <tickslock>
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
    80001ffa:	711d                	addi	sp,sp,-96
    80001ffc:	ec86                	sd	ra,88(sp)
    80001ffe:	e8a2                	sd	s0,80(sp)
    80002000:	e4a6                	sd	s1,72(sp)
    80002002:	e0ca                	sd	s2,64(sp)
    80002004:	fc4e                	sd	s3,56(sp)
    80002006:	f852                	sd	s4,48(sp)
    80002008:	f456                	sd	s5,40(sp)
    8000200a:	f05a                	sd	s6,32(sp)
    8000200c:	ec5e                	sd	s7,24(sp)
    8000200e:	e862                	sd	s8,16(sp)
    80002010:	e466                	sd	s9,8(sp)
    80002012:	1080                	addi	s0,sp,96
    80002014:	8792                	mv	a5,tp
  int id = r_tp();
    80002016:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002018:	00779c13          	slli	s8,a5,0x7
    8000201c:	0000f717          	auipc	a4,0xf
    80002020:	dc470713          	addi	a4,a4,-572 # 80010de0 <pid_lock>
    80002024:	9762                	add	a4,a4,s8
    80002026:	02073823          	sd	zero,48(a4)
      swtch(&c->context, &first_proc->context);
    8000202a:	0000f717          	auipc	a4,0xf
    8000202e:	dee70713          	addi	a4,a4,-530 # 80010e18 <cpus+0x8>
    80002032:	9c3a                	add	s8,s8,a4
      if (p->state == RUNNABLE)
    80002034:	4a0d                	li	s4,3
    for (p = proc; p < &proc[NPROC]; p++)
    80002036:	00017a97          	auipc	s5,0x17
    8000203a:	a0aa8a93          	addi	s5,s5,-1526 # 80018a40 <tickslock>
    first_proc = 0;
    8000203e:	4b81                	li	s7,0
      first_proc->state = RUNNING;
    80002040:	4c91                	li	s9,4
      c->proc = first_proc;
    80002042:	079e                	slli	a5,a5,0x7
    80002044:	0000fb17          	auipc	s6,0xf
    80002048:	d9cb0b13          	addi	s6,s6,-612 # 80010de0 <pid_lock>
    8000204c:	9b3e                	add	s6,s6,a5
    8000204e:	a059                	j	800020d4 <scheduler+0xda>
          release(&first_proc->lock);
    80002050:	854e                	mv	a0,s3
    80002052:	fffff097          	auipc	ra,0xfffff
    80002056:	c4c080e7          	jalr	-948(ra) # 80000c9e <release>
    for (p = proc; p < &proc[NPROC]; p++)
    8000205a:	1e048793          	addi	a5,s1,480
    8000205e:	0957fa63          	bgeu	a5,s5,800020f2 <scheduler+0xf8>
    80002062:	89ca                	mv	s3,s2
    80002064:	a811                	j	80002078 <scheduler+0x7e>
      release(&p->lock);
    80002066:	8526                	mv	a0,s1
    80002068:	fffff097          	auipc	ra,0xfffff
    8000206c:	c36080e7          	jalr	-970(ra) # 80000c9e <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002070:	1e048793          	addi	a5,s1,480
    80002074:	0757fc63          	bgeu	a5,s5,800020ec <scheduler+0xf2>
    80002078:	1e048493          	addi	s1,s1,480
    8000207c:	8926                	mv	s2,s1
      acquire(&p->lock);
    8000207e:	8526                	mv	a0,s1
    80002080:	fffff097          	auipc	ra,0xfffff
    80002084:	b6a080e7          	jalr	-1174(ra) # 80000bea <acquire>
      if (p->state == RUNNABLE)
    80002088:	4c9c                	lw	a5,24(s1)
    8000208a:	fd479ee3          	bne	a5,s4,80002066 <scheduler+0x6c>
        if(first_proc == 0){
    8000208e:	fc0986e3          	beqz	s3,8000205a <scheduler+0x60>
        else if (p->time_created < first_proc->time_created)
    80002092:	1784b703          	ld	a4,376(s1)
    80002096:	1789b783          	ld	a5,376(s3)
    8000209a:	faf76be3          	bltu	a4,a5,80002050 <scheduler+0x56>
      release(&p->lock);
    8000209e:	8526                	mv	a0,s1
    800020a0:	fffff097          	auipc	ra,0xfffff
    800020a4:	bfe080e7          	jalr	-1026(ra) # 80000c9e <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800020a8:	1e048793          	addi	a5,s1,480
    800020ac:	fd57e6e3          	bltu	a5,s5,80002078 <scheduler+0x7e>
      first_proc->state = RUNNING;
    800020b0:	0199ac23          	sw	s9,24(s3)
      c->proc = first_proc;
    800020b4:	033b3823          	sd	s3,48(s6)
      swtch(&c->context, &first_proc->context);
    800020b8:	06098593          	addi	a1,s3,96
    800020bc:	8562                	mv	a0,s8
    800020be:	00001097          	auipc	ra,0x1
    800020c2:	8c0080e7          	jalr	-1856(ra) # 8000297e <swtch>
      c->proc = 0;
    800020c6:	020b3823          	sd	zero,48(s6)
      release(&first_proc->lock);
    800020ca:	854e                	mv	a0,s3
    800020cc:	fffff097          	auipc	ra,0xfffff
    800020d0:	bd2080e7          	jalr	-1070(ra) # 80000c9e <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020d4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800020d8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800020dc:	10079073          	csrw	sstatus,a5
    for (p = proc; p < &proc[NPROC]; p++)
    800020e0:	0000f497          	auipc	s1,0xf
    800020e4:	16048493          	addi	s1,s1,352 # 80011240 <proc>
    first_proc = 0;
    800020e8:	89de                	mv	s3,s7
    800020ea:	bf49                	j	8000207c <scheduler+0x82>
    if (first_proc != 0)
    800020ec:	fe0984e3          	beqz	s3,800020d4 <scheduler+0xda>
    800020f0:	b7c1                	j	800020b0 <scheduler+0xb6>
    for (p = proc; p < &proc[NPROC]; p++)
    800020f2:	89ca                	mv	s3,s2
    800020f4:	bf75                	j	800020b0 <scheduler+0xb6>

00000000800020f6 <sched>:
{
    800020f6:	7179                	addi	sp,sp,-48
    800020f8:	f406                	sd	ra,40(sp)
    800020fa:	f022                	sd	s0,32(sp)
    800020fc:	ec26                	sd	s1,24(sp)
    800020fe:	e84a                	sd	s2,16(sp)
    80002100:	e44e                	sd	s3,8(sp)
    80002102:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002104:	00000097          	auipc	ra,0x0
    80002108:	8c2080e7          	jalr	-1854(ra) # 800019c6 <myproc>
    8000210c:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    8000210e:	fffff097          	auipc	ra,0xfffff
    80002112:	a62080e7          	jalr	-1438(ra) # 80000b70 <holding>
    80002116:	c93d                	beqz	a0,8000218c <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002118:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    8000211a:	2781                	sext.w	a5,a5
    8000211c:	079e                	slli	a5,a5,0x7
    8000211e:	0000f717          	auipc	a4,0xf
    80002122:	cc270713          	addi	a4,a4,-830 # 80010de0 <pid_lock>
    80002126:	97ba                	add	a5,a5,a4
    80002128:	0a87a703          	lw	a4,168(a5)
    8000212c:	4785                	li	a5,1
    8000212e:	06f71763          	bne	a4,a5,8000219c <sched+0xa6>
  if (p->state == RUNNING)
    80002132:	4c98                	lw	a4,24(s1)
    80002134:	4791                	li	a5,4
    80002136:	06f70b63          	beq	a4,a5,800021ac <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000213a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000213e:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002140:	efb5                	bnez	a5,800021bc <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002142:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002144:	0000f917          	auipc	s2,0xf
    80002148:	c9c90913          	addi	s2,s2,-868 # 80010de0 <pid_lock>
    8000214c:	2781                	sext.w	a5,a5
    8000214e:	079e                	slli	a5,a5,0x7
    80002150:	97ca                	add	a5,a5,s2
    80002152:	0ac7a983          	lw	s3,172(a5)
    80002156:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002158:	2781                	sext.w	a5,a5
    8000215a:	079e                	slli	a5,a5,0x7
    8000215c:	0000f597          	auipc	a1,0xf
    80002160:	cbc58593          	addi	a1,a1,-836 # 80010e18 <cpus+0x8>
    80002164:	95be                	add	a1,a1,a5
    80002166:	06048513          	addi	a0,s1,96
    8000216a:	00001097          	auipc	ra,0x1
    8000216e:	814080e7          	jalr	-2028(ra) # 8000297e <swtch>
    80002172:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002174:	2781                	sext.w	a5,a5
    80002176:	079e                	slli	a5,a5,0x7
    80002178:	97ca                	add	a5,a5,s2
    8000217a:	0b37a623          	sw	s3,172(a5)
}
    8000217e:	70a2                	ld	ra,40(sp)
    80002180:	7402                	ld	s0,32(sp)
    80002182:	64e2                	ld	s1,24(sp)
    80002184:	6942                	ld	s2,16(sp)
    80002186:	69a2                	ld	s3,8(sp)
    80002188:	6145                	addi	sp,sp,48
    8000218a:	8082                	ret
    panic("sched p->lock");
    8000218c:	00006517          	auipc	a0,0x6
    80002190:	08c50513          	addi	a0,a0,140 # 80008218 <digits+0x1d8>
    80002194:	ffffe097          	auipc	ra,0xffffe
    80002198:	3b0080e7          	jalr	944(ra) # 80000544 <panic>
    panic("sched locks");
    8000219c:	00006517          	auipc	a0,0x6
    800021a0:	08c50513          	addi	a0,a0,140 # 80008228 <digits+0x1e8>
    800021a4:	ffffe097          	auipc	ra,0xffffe
    800021a8:	3a0080e7          	jalr	928(ra) # 80000544 <panic>
    panic("sched running");
    800021ac:	00006517          	auipc	a0,0x6
    800021b0:	08c50513          	addi	a0,a0,140 # 80008238 <digits+0x1f8>
    800021b4:	ffffe097          	auipc	ra,0xffffe
    800021b8:	390080e7          	jalr	912(ra) # 80000544 <panic>
    panic("sched interruptible");
    800021bc:	00006517          	auipc	a0,0x6
    800021c0:	08c50513          	addi	a0,a0,140 # 80008248 <digits+0x208>
    800021c4:	ffffe097          	auipc	ra,0xffffe
    800021c8:	380080e7          	jalr	896(ra) # 80000544 <panic>

00000000800021cc <yield>:
{
    800021cc:	1101                	addi	sp,sp,-32
    800021ce:	ec06                	sd	ra,24(sp)
    800021d0:	e822                	sd	s0,16(sp)
    800021d2:	e426                	sd	s1,8(sp)
    800021d4:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800021d6:	fffff097          	auipc	ra,0xfffff
    800021da:	7f0080e7          	jalr	2032(ra) # 800019c6 <myproc>
    800021de:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021e0:	fffff097          	auipc	ra,0xfffff
    800021e4:	a0a080e7          	jalr	-1526(ra) # 80000bea <acquire>
  p->state = RUNNABLE;
    800021e8:	478d                	li	a5,3
    800021ea:	cc9c                	sw	a5,24(s1)
  sched();
    800021ec:	00000097          	auipc	ra,0x0
    800021f0:	f0a080e7          	jalr	-246(ra) # 800020f6 <sched>
  release(&p->lock);
    800021f4:	8526                	mv	a0,s1
    800021f6:	fffff097          	auipc	ra,0xfffff
    800021fa:	aa8080e7          	jalr	-1368(ra) # 80000c9e <release>
}
    800021fe:	60e2                	ld	ra,24(sp)
    80002200:	6442                	ld	s0,16(sp)
    80002202:	64a2                	ld	s1,8(sp)
    80002204:	6105                	addi	sp,sp,32
    80002206:	8082                	ret

0000000080002208 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    80002208:	7179                	addi	sp,sp,-48
    8000220a:	f406                	sd	ra,40(sp)
    8000220c:	f022                	sd	s0,32(sp)
    8000220e:	ec26                	sd	s1,24(sp)
    80002210:	e84a                	sd	s2,16(sp)
    80002212:	e44e                	sd	s3,8(sp)
    80002214:	1800                	addi	s0,sp,48
    80002216:	89aa                	mv	s3,a0
    80002218:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000221a:	fffff097          	auipc	ra,0xfffff
    8000221e:	7ac080e7          	jalr	1964(ra) # 800019c6 <myproc>
    80002222:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    80002224:	fffff097          	auipc	ra,0xfffff
    80002228:	9c6080e7          	jalr	-1594(ra) # 80000bea <acquire>
  release(lk);
    8000222c:	854a                	mv	a0,s2
    8000222e:	fffff097          	auipc	ra,0xfffff
    80002232:	a70080e7          	jalr	-1424(ra) # 80000c9e <release>

  // Go to sleep.
  p->chan = chan;
    80002236:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000223a:	4789                	li	a5,2
    8000223c:	cc9c                	sw	a5,24(s1)

  sched();
    8000223e:	00000097          	auipc	ra,0x0
    80002242:	eb8080e7          	jalr	-328(ra) # 800020f6 <sched>

  // Tidy up.
  p->chan = 0;
    80002246:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000224a:	8526                	mv	a0,s1
    8000224c:	fffff097          	auipc	ra,0xfffff
    80002250:	a52080e7          	jalr	-1454(ra) # 80000c9e <release>
  acquire(lk);
    80002254:	854a                	mv	a0,s2
    80002256:	fffff097          	auipc	ra,0xfffff
    8000225a:	994080e7          	jalr	-1644(ra) # 80000bea <acquire>
}
    8000225e:	70a2                	ld	ra,40(sp)
    80002260:	7402                	ld	s0,32(sp)
    80002262:	64e2                	ld	s1,24(sp)
    80002264:	6942                	ld	s2,16(sp)
    80002266:	69a2                	ld	s3,8(sp)
    80002268:	6145                	addi	sp,sp,48
    8000226a:	8082                	ret

000000008000226c <waitx>:
{
    8000226c:	711d                	addi	sp,sp,-96
    8000226e:	ec86                	sd	ra,88(sp)
    80002270:	e8a2                	sd	s0,80(sp)
    80002272:	e4a6                	sd	s1,72(sp)
    80002274:	e0ca                	sd	s2,64(sp)
    80002276:	fc4e                	sd	s3,56(sp)
    80002278:	f852                	sd	s4,48(sp)
    8000227a:	f456                	sd	s5,40(sp)
    8000227c:	f05a                	sd	s6,32(sp)
    8000227e:	ec5e                	sd	s7,24(sp)
    80002280:	e862                	sd	s8,16(sp)
    80002282:	e466                	sd	s9,8(sp)
    80002284:	e06a                	sd	s10,0(sp)
    80002286:	1080                	addi	s0,sp,96
    80002288:	8b2a                	mv	s6,a0
    8000228a:	8bae                	mv	s7,a1
    8000228c:	8c32                	mv	s8,a2
  struct proc *p = myproc();
    8000228e:	fffff097          	auipc	ra,0xfffff
    80002292:	738080e7          	jalr	1848(ra) # 800019c6 <myproc>
    80002296:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002298:	0000f517          	auipc	a0,0xf
    8000229c:	b6050513          	addi	a0,a0,-1184 # 80010df8 <wait_lock>
    800022a0:	fffff097          	auipc	ra,0xfffff
    800022a4:	94a080e7          	jalr	-1718(ra) # 80000bea <acquire>
    havekids = 0;
    800022a8:	4c81                	li	s9,0
        if (np->state == ZOMBIE)
    800022aa:	4a15                	li	s4,5
    for (np = proc; np < &proc[NPROC]; np++)
    800022ac:	00016997          	auipc	s3,0x16
    800022b0:	79498993          	addi	s3,s3,1940 # 80018a40 <tickslock>
        havekids = 1;
    800022b4:	4a85                	li	s5,1
    sleep(p, &wait_lock); // DOC: wait-sleep
    800022b6:	0000fd17          	auipc	s10,0xf
    800022ba:	b42d0d13          	addi	s10,s10,-1214 # 80010df8 <wait_lock>
    havekids = 0;
    800022be:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    800022c0:	0000f497          	auipc	s1,0xf
    800022c4:	f8048493          	addi	s1,s1,-128 # 80011240 <proc>
    800022c8:	a059                	j	8000234e <waitx+0xe2>
          pid = np->pid;
    800022ca:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    800022ce:	16c4a703          	lw	a4,364(s1)
    800022d2:	00ec2023          	sw	a4,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    800022d6:	1704a783          	lw	a5,368(s1)
    800022da:	9f3d                	addw	a4,a4,a5
    800022dc:	1744a783          	lw	a5,372(s1)
    800022e0:	9f99                	subw	a5,a5,a4
    800022e2:	00fba023          	sw	a5,0(s7) # fffffffffffff000 <end+0xffffffff7ffdb1e0>
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800022e6:	000b0e63          	beqz	s6,80002302 <waitx+0x96>
    800022ea:	4691                	li	a3,4
    800022ec:	02c48613          	addi	a2,s1,44
    800022f0:	85da                	mv	a1,s6
    800022f2:	05093503          	ld	a0,80(s2)
    800022f6:	fffff097          	auipc	ra,0xfffff
    800022fa:	38e080e7          	jalr	910(ra) # 80001684 <copyout>
    800022fe:	02054563          	bltz	a0,80002328 <waitx+0xbc>
          freeproc(np);
    80002302:	8526                	mv	a0,s1
    80002304:	00000097          	auipc	ra,0x0
    80002308:	874080e7          	jalr	-1932(ra) # 80001b78 <freeproc>
          release(&np->lock);
    8000230c:	8526                	mv	a0,s1
    8000230e:	fffff097          	auipc	ra,0xfffff
    80002312:	990080e7          	jalr	-1648(ra) # 80000c9e <release>
          release(&wait_lock);
    80002316:	0000f517          	auipc	a0,0xf
    8000231a:	ae250513          	addi	a0,a0,-1310 # 80010df8 <wait_lock>
    8000231e:	fffff097          	auipc	ra,0xfffff
    80002322:	980080e7          	jalr	-1664(ra) # 80000c9e <release>
          return pid;
    80002326:	a09d                	j	8000238c <waitx+0x120>
            release(&np->lock);
    80002328:	8526                	mv	a0,s1
    8000232a:	fffff097          	auipc	ra,0xfffff
    8000232e:	974080e7          	jalr	-1676(ra) # 80000c9e <release>
            release(&wait_lock);
    80002332:	0000f517          	auipc	a0,0xf
    80002336:	ac650513          	addi	a0,a0,-1338 # 80010df8 <wait_lock>
    8000233a:	fffff097          	auipc	ra,0xfffff
    8000233e:	964080e7          	jalr	-1692(ra) # 80000c9e <release>
            return -1;
    80002342:	59fd                	li	s3,-1
    80002344:	a0a1                	j	8000238c <waitx+0x120>
    for (np = proc; np < &proc[NPROC]; np++)
    80002346:	1e048493          	addi	s1,s1,480
    8000234a:	03348463          	beq	s1,s3,80002372 <waitx+0x106>
      if (np->parent == p)
    8000234e:	7c9c                	ld	a5,56(s1)
    80002350:	ff279be3          	bne	a5,s2,80002346 <waitx+0xda>
        acquire(&np->lock);
    80002354:	8526                	mv	a0,s1
    80002356:	fffff097          	auipc	ra,0xfffff
    8000235a:	894080e7          	jalr	-1900(ra) # 80000bea <acquire>
        if (np->state == ZOMBIE)
    8000235e:	4c9c                	lw	a5,24(s1)
    80002360:	f74785e3          	beq	a5,s4,800022ca <waitx+0x5e>
        release(&np->lock);
    80002364:	8526                	mv	a0,s1
    80002366:	fffff097          	auipc	ra,0xfffff
    8000236a:	938080e7          	jalr	-1736(ra) # 80000c9e <release>
        havekids = 1;
    8000236e:	8756                	mv	a4,s5
    80002370:	bfd9                	j	80002346 <waitx+0xda>
    if (!havekids || p->killed)
    80002372:	c701                	beqz	a4,8000237a <waitx+0x10e>
    80002374:	02892783          	lw	a5,40(s2)
    80002378:	cb8d                	beqz	a5,800023aa <waitx+0x13e>
      release(&wait_lock);
    8000237a:	0000f517          	auipc	a0,0xf
    8000237e:	a7e50513          	addi	a0,a0,-1410 # 80010df8 <wait_lock>
    80002382:	fffff097          	auipc	ra,0xfffff
    80002386:	91c080e7          	jalr	-1764(ra) # 80000c9e <release>
      return -1;
    8000238a:	59fd                	li	s3,-1
}
    8000238c:	854e                	mv	a0,s3
    8000238e:	60e6                	ld	ra,88(sp)
    80002390:	6446                	ld	s0,80(sp)
    80002392:	64a6                	ld	s1,72(sp)
    80002394:	6906                	ld	s2,64(sp)
    80002396:	79e2                	ld	s3,56(sp)
    80002398:	7a42                	ld	s4,48(sp)
    8000239a:	7aa2                	ld	s5,40(sp)
    8000239c:	7b02                	ld	s6,32(sp)
    8000239e:	6be2                	ld	s7,24(sp)
    800023a0:	6c42                	ld	s8,16(sp)
    800023a2:	6ca2                	ld	s9,8(sp)
    800023a4:	6d02                	ld	s10,0(sp)
    800023a6:	6125                	addi	sp,sp,96
    800023a8:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    800023aa:	85ea                	mv	a1,s10
    800023ac:	854a                	mv	a0,s2
    800023ae:	00000097          	auipc	ra,0x0
    800023b2:	e5a080e7          	jalr	-422(ra) # 80002208 <sleep>
    havekids = 0;
    800023b6:	b721                	j	800022be <waitx+0x52>

00000000800023b8 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    800023b8:	7139                	addi	sp,sp,-64
    800023ba:	fc06                	sd	ra,56(sp)
    800023bc:	f822                	sd	s0,48(sp)
    800023be:	f426                	sd	s1,40(sp)
    800023c0:	f04a                	sd	s2,32(sp)
    800023c2:	ec4e                	sd	s3,24(sp)
    800023c4:	e852                	sd	s4,16(sp)
    800023c6:	e456                	sd	s5,8(sp)
    800023c8:	0080                	addi	s0,sp,64
    800023ca:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800023cc:	0000f497          	auipc	s1,0xf
    800023d0:	e7448493          	addi	s1,s1,-396 # 80011240 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    800023d4:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    800023d6:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    800023d8:	00016917          	auipc	s2,0x16
    800023dc:	66890913          	addi	s2,s2,1640 # 80018a40 <tickslock>
    800023e0:	a821                	j	800023f8 <wakeup+0x40>
        p->state = RUNNABLE;
    800023e2:	0154ac23          	sw	s5,24(s1)
      }
      release(&p->lock);
    800023e6:	8526                	mv	a0,s1
    800023e8:	fffff097          	auipc	ra,0xfffff
    800023ec:	8b6080e7          	jalr	-1866(ra) # 80000c9e <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800023f0:	1e048493          	addi	s1,s1,480
    800023f4:	03248463          	beq	s1,s2,8000241c <wakeup+0x64>
    if (p != myproc())
    800023f8:	fffff097          	auipc	ra,0xfffff
    800023fc:	5ce080e7          	jalr	1486(ra) # 800019c6 <myproc>
    80002400:	fea488e3          	beq	s1,a0,800023f0 <wakeup+0x38>
      acquire(&p->lock);
    80002404:	8526                	mv	a0,s1
    80002406:	ffffe097          	auipc	ra,0xffffe
    8000240a:	7e4080e7          	jalr	2020(ra) # 80000bea <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    8000240e:	4c9c                	lw	a5,24(s1)
    80002410:	fd379be3          	bne	a5,s3,800023e6 <wakeup+0x2e>
    80002414:	709c                	ld	a5,32(s1)
    80002416:	fd4798e3          	bne	a5,s4,800023e6 <wakeup+0x2e>
    8000241a:	b7e1                	j	800023e2 <wakeup+0x2a>
    }
  }
}
    8000241c:	70e2                	ld	ra,56(sp)
    8000241e:	7442                	ld	s0,48(sp)
    80002420:	74a2                	ld	s1,40(sp)
    80002422:	7902                	ld	s2,32(sp)
    80002424:	69e2                	ld	s3,24(sp)
    80002426:	6a42                	ld	s4,16(sp)
    80002428:	6aa2                	ld	s5,8(sp)
    8000242a:	6121                	addi	sp,sp,64
    8000242c:	8082                	ret

000000008000242e <reparent>:
{
    8000242e:	7179                	addi	sp,sp,-48
    80002430:	f406                	sd	ra,40(sp)
    80002432:	f022                	sd	s0,32(sp)
    80002434:	ec26                	sd	s1,24(sp)
    80002436:	e84a                	sd	s2,16(sp)
    80002438:	e44e                	sd	s3,8(sp)
    8000243a:	e052                	sd	s4,0(sp)
    8000243c:	1800                	addi	s0,sp,48
    8000243e:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002440:	0000f497          	auipc	s1,0xf
    80002444:	e0048493          	addi	s1,s1,-512 # 80011240 <proc>
      pp->parent = initproc;
    80002448:	00006a17          	auipc	s4,0x6
    8000244c:	720a0a13          	addi	s4,s4,1824 # 80008b68 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002450:	00016997          	auipc	s3,0x16
    80002454:	5f098993          	addi	s3,s3,1520 # 80018a40 <tickslock>
    80002458:	a029                	j	80002462 <reparent+0x34>
    8000245a:	1e048493          	addi	s1,s1,480
    8000245e:	01348d63          	beq	s1,s3,80002478 <reparent+0x4a>
    if (pp->parent == p)
    80002462:	7c9c                	ld	a5,56(s1)
    80002464:	ff279be3          	bne	a5,s2,8000245a <reparent+0x2c>
      pp->parent = initproc;
    80002468:	000a3503          	ld	a0,0(s4)
    8000246c:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000246e:	00000097          	auipc	ra,0x0
    80002472:	f4a080e7          	jalr	-182(ra) # 800023b8 <wakeup>
    80002476:	b7d5                	j	8000245a <reparent+0x2c>
}
    80002478:	70a2                	ld	ra,40(sp)
    8000247a:	7402                	ld	s0,32(sp)
    8000247c:	64e2                	ld	s1,24(sp)
    8000247e:	6942                	ld	s2,16(sp)
    80002480:	69a2                	ld	s3,8(sp)
    80002482:	6a02                	ld	s4,0(sp)
    80002484:	6145                	addi	sp,sp,48
    80002486:	8082                	ret

0000000080002488 <exit>:
{
    80002488:	7179                	addi	sp,sp,-48
    8000248a:	f406                	sd	ra,40(sp)
    8000248c:	f022                	sd	s0,32(sp)
    8000248e:	ec26                	sd	s1,24(sp)
    80002490:	e84a                	sd	s2,16(sp)
    80002492:	e44e                	sd	s3,8(sp)
    80002494:	e052                	sd	s4,0(sp)
    80002496:	1800                	addi	s0,sp,48
    80002498:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000249a:	fffff097          	auipc	ra,0xfffff
    8000249e:	52c080e7          	jalr	1324(ra) # 800019c6 <myproc>
    800024a2:	89aa                	mv	s3,a0
  if (p == initproc)
    800024a4:	00006797          	auipc	a5,0x6
    800024a8:	6c47b783          	ld	a5,1732(a5) # 80008b68 <initproc>
    800024ac:	0d050493          	addi	s1,a0,208
    800024b0:	15050913          	addi	s2,a0,336
    800024b4:	02a79363          	bne	a5,a0,800024da <exit+0x52>
    panic("init exiting");
    800024b8:	00006517          	auipc	a0,0x6
    800024bc:	da850513          	addi	a0,a0,-600 # 80008260 <digits+0x220>
    800024c0:	ffffe097          	auipc	ra,0xffffe
    800024c4:	084080e7          	jalr	132(ra) # 80000544 <panic>
      fileclose(f);
    800024c8:	00002097          	auipc	ra,0x2
    800024cc:	684080e7          	jalr	1668(ra) # 80004b4c <fileclose>
      p->ofile[fd] = 0;
    800024d0:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    800024d4:	04a1                	addi	s1,s1,8
    800024d6:	01248563          	beq	s1,s2,800024e0 <exit+0x58>
    if (p->ofile[fd])
    800024da:	6088                	ld	a0,0(s1)
    800024dc:	f575                	bnez	a0,800024c8 <exit+0x40>
    800024de:	bfdd                	j	800024d4 <exit+0x4c>
  begin_op();
    800024e0:	00002097          	auipc	ra,0x2
    800024e4:	1a0080e7          	jalr	416(ra) # 80004680 <begin_op>
  iput(p->cwd);
    800024e8:	1509b503          	ld	a0,336(s3)
    800024ec:	00002097          	auipc	ra,0x2
    800024f0:	98c080e7          	jalr	-1652(ra) # 80003e78 <iput>
  end_op();
    800024f4:	00002097          	auipc	ra,0x2
    800024f8:	20c080e7          	jalr	524(ra) # 80004700 <end_op>
  p->cwd = 0;
    800024fc:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002500:	0000f497          	auipc	s1,0xf
    80002504:	8f848493          	addi	s1,s1,-1800 # 80010df8 <wait_lock>
    80002508:	8526                	mv	a0,s1
    8000250a:	ffffe097          	auipc	ra,0xffffe
    8000250e:	6e0080e7          	jalr	1760(ra) # 80000bea <acquire>
  reparent(p);
    80002512:	854e                	mv	a0,s3
    80002514:	00000097          	auipc	ra,0x0
    80002518:	f1a080e7          	jalr	-230(ra) # 8000242e <reparent>
  wakeup(p->parent);
    8000251c:	0389b503          	ld	a0,56(s3)
    80002520:	00000097          	auipc	ra,0x0
    80002524:	e98080e7          	jalr	-360(ra) # 800023b8 <wakeup>
  acquire(&p->lock);
    80002528:	854e                	mv	a0,s3
    8000252a:	ffffe097          	auipc	ra,0xffffe
    8000252e:	6c0080e7          	jalr	1728(ra) # 80000bea <acquire>
  p->xstate = status;
    80002532:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002536:	4795                	li	a5,5
    80002538:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    8000253c:	00006797          	auipc	a5,0x6
    80002540:	6347a783          	lw	a5,1588(a5) # 80008b70 <ticks>
    80002544:	16f9aa23          	sw	a5,372(s3)
  release(&wait_lock);
    80002548:	8526                	mv	a0,s1
    8000254a:	ffffe097          	auipc	ra,0xffffe
    8000254e:	754080e7          	jalr	1876(ra) # 80000c9e <release>
  sched();
    80002552:	00000097          	auipc	ra,0x0
    80002556:	ba4080e7          	jalr	-1116(ra) # 800020f6 <sched>
  panic("zombie exit");
    8000255a:	00006517          	auipc	a0,0x6
    8000255e:	d1650513          	addi	a0,a0,-746 # 80008270 <digits+0x230>
    80002562:	ffffe097          	auipc	ra,0xffffe
    80002566:	fe2080e7          	jalr	-30(ra) # 80000544 <panic>

000000008000256a <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    8000256a:	7179                	addi	sp,sp,-48
    8000256c:	f406                	sd	ra,40(sp)
    8000256e:	f022                	sd	s0,32(sp)
    80002570:	ec26                	sd	s1,24(sp)
    80002572:	e84a                	sd	s2,16(sp)
    80002574:	e44e                	sd	s3,8(sp)
    80002576:	1800                	addi	s0,sp,48
    80002578:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000257a:	0000f497          	auipc	s1,0xf
    8000257e:	cc648493          	addi	s1,s1,-826 # 80011240 <proc>
    80002582:	00016997          	auipc	s3,0x16
    80002586:	4be98993          	addi	s3,s3,1214 # 80018a40 <tickslock>
  {
    acquire(&p->lock);
    8000258a:	8526                	mv	a0,s1
    8000258c:	ffffe097          	auipc	ra,0xffffe
    80002590:	65e080e7          	jalr	1630(ra) # 80000bea <acquire>
    if (p->pid == pid)
    80002594:	589c                	lw	a5,48(s1)
    80002596:	01278d63          	beq	a5,s2,800025b0 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000259a:	8526                	mv	a0,s1
    8000259c:	ffffe097          	auipc	ra,0xffffe
    800025a0:	702080e7          	jalr	1794(ra) # 80000c9e <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800025a4:	1e048493          	addi	s1,s1,480
    800025a8:	ff3491e3          	bne	s1,s3,8000258a <kill+0x20>
  }
  return -1;
    800025ac:	557d                	li	a0,-1
    800025ae:	a829                	j	800025c8 <kill+0x5e>
      p->killed = 1;
    800025b0:	4785                	li	a5,1
    800025b2:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    800025b4:	4c98                	lw	a4,24(s1)
    800025b6:	4789                	li	a5,2
    800025b8:	00f70f63          	beq	a4,a5,800025d6 <kill+0x6c>
      release(&p->lock);
    800025bc:	8526                	mv	a0,s1
    800025be:	ffffe097          	auipc	ra,0xffffe
    800025c2:	6e0080e7          	jalr	1760(ra) # 80000c9e <release>
      return 0;
    800025c6:	4501                	li	a0,0
}
    800025c8:	70a2                	ld	ra,40(sp)
    800025ca:	7402                	ld	s0,32(sp)
    800025cc:	64e2                	ld	s1,24(sp)
    800025ce:	6942                	ld	s2,16(sp)
    800025d0:	69a2                	ld	s3,8(sp)
    800025d2:	6145                	addi	sp,sp,48
    800025d4:	8082                	ret
        p->state = RUNNABLE;
    800025d6:	478d                	li	a5,3
    800025d8:	cc9c                	sw	a5,24(s1)
    800025da:	b7cd                	j	800025bc <kill+0x52>

00000000800025dc <setkilled>:

void setkilled(struct proc *p)
{
    800025dc:	1101                	addi	sp,sp,-32
    800025de:	ec06                	sd	ra,24(sp)
    800025e0:	e822                	sd	s0,16(sp)
    800025e2:	e426                	sd	s1,8(sp)
    800025e4:	1000                	addi	s0,sp,32
    800025e6:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800025e8:	ffffe097          	auipc	ra,0xffffe
    800025ec:	602080e7          	jalr	1538(ra) # 80000bea <acquire>
  p->killed = 1;
    800025f0:	4785                	li	a5,1
    800025f2:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800025f4:	8526                	mv	a0,s1
    800025f6:	ffffe097          	auipc	ra,0xffffe
    800025fa:	6a8080e7          	jalr	1704(ra) # 80000c9e <release>
}
    800025fe:	60e2                	ld	ra,24(sp)
    80002600:	6442                	ld	s0,16(sp)
    80002602:	64a2                	ld	s1,8(sp)
    80002604:	6105                	addi	sp,sp,32
    80002606:	8082                	ret

0000000080002608 <killed>:

int killed(struct proc *p)
{
    80002608:	1101                	addi	sp,sp,-32
    8000260a:	ec06                	sd	ra,24(sp)
    8000260c:	e822                	sd	s0,16(sp)
    8000260e:	e426                	sd	s1,8(sp)
    80002610:	e04a                	sd	s2,0(sp)
    80002612:	1000                	addi	s0,sp,32
    80002614:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002616:	ffffe097          	auipc	ra,0xffffe
    8000261a:	5d4080e7          	jalr	1492(ra) # 80000bea <acquire>
  k = p->killed;
    8000261e:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002622:	8526                	mv	a0,s1
    80002624:	ffffe097          	auipc	ra,0xffffe
    80002628:	67a080e7          	jalr	1658(ra) # 80000c9e <release>
  return k;
}
    8000262c:	854a                	mv	a0,s2
    8000262e:	60e2                	ld	ra,24(sp)
    80002630:	6442                	ld	s0,16(sp)
    80002632:	64a2                	ld	s1,8(sp)
    80002634:	6902                	ld	s2,0(sp)
    80002636:	6105                	addi	sp,sp,32
    80002638:	8082                	ret

000000008000263a <wait>:
{
    8000263a:	715d                	addi	sp,sp,-80
    8000263c:	e486                	sd	ra,72(sp)
    8000263e:	e0a2                	sd	s0,64(sp)
    80002640:	fc26                	sd	s1,56(sp)
    80002642:	f84a                	sd	s2,48(sp)
    80002644:	f44e                	sd	s3,40(sp)
    80002646:	f052                	sd	s4,32(sp)
    80002648:	ec56                	sd	s5,24(sp)
    8000264a:	e85a                	sd	s6,16(sp)
    8000264c:	e45e                	sd	s7,8(sp)
    8000264e:	e062                	sd	s8,0(sp)
    80002650:	0880                	addi	s0,sp,80
    80002652:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002654:	fffff097          	auipc	ra,0xfffff
    80002658:	372080e7          	jalr	882(ra) # 800019c6 <myproc>
    8000265c:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000265e:	0000e517          	auipc	a0,0xe
    80002662:	79a50513          	addi	a0,a0,1946 # 80010df8 <wait_lock>
    80002666:	ffffe097          	auipc	ra,0xffffe
    8000266a:	584080e7          	jalr	1412(ra) # 80000bea <acquire>
    havekids = 0;
    8000266e:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    80002670:	4a15                	li	s4,5
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002672:	00016997          	auipc	s3,0x16
    80002676:	3ce98993          	addi	s3,s3,974 # 80018a40 <tickslock>
        havekids = 1;
    8000267a:	4a85                	li	s5,1
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000267c:	0000ec17          	auipc	s8,0xe
    80002680:	77cc0c13          	addi	s8,s8,1916 # 80010df8 <wait_lock>
    havekids = 0;
    80002684:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002686:	0000f497          	auipc	s1,0xf
    8000268a:	bba48493          	addi	s1,s1,-1094 # 80011240 <proc>
    8000268e:	a0bd                	j	800026fc <wait+0xc2>
          pid = pp->pid;
    80002690:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002694:	000b0e63          	beqz	s6,800026b0 <wait+0x76>
    80002698:	4691                	li	a3,4
    8000269a:	02c48613          	addi	a2,s1,44
    8000269e:	85da                	mv	a1,s6
    800026a0:	05093503          	ld	a0,80(s2)
    800026a4:	fffff097          	auipc	ra,0xfffff
    800026a8:	fe0080e7          	jalr	-32(ra) # 80001684 <copyout>
    800026ac:	02054563          	bltz	a0,800026d6 <wait+0x9c>
          freeproc(pp);
    800026b0:	8526                	mv	a0,s1
    800026b2:	fffff097          	auipc	ra,0xfffff
    800026b6:	4c6080e7          	jalr	1222(ra) # 80001b78 <freeproc>
          release(&pp->lock);
    800026ba:	8526                	mv	a0,s1
    800026bc:	ffffe097          	auipc	ra,0xffffe
    800026c0:	5e2080e7          	jalr	1506(ra) # 80000c9e <release>
          release(&wait_lock);
    800026c4:	0000e517          	auipc	a0,0xe
    800026c8:	73450513          	addi	a0,a0,1844 # 80010df8 <wait_lock>
    800026cc:	ffffe097          	auipc	ra,0xffffe
    800026d0:	5d2080e7          	jalr	1490(ra) # 80000c9e <release>
          return pid;
    800026d4:	a0b5                	j	80002740 <wait+0x106>
            release(&pp->lock);
    800026d6:	8526                	mv	a0,s1
    800026d8:	ffffe097          	auipc	ra,0xffffe
    800026dc:	5c6080e7          	jalr	1478(ra) # 80000c9e <release>
            release(&wait_lock);
    800026e0:	0000e517          	auipc	a0,0xe
    800026e4:	71850513          	addi	a0,a0,1816 # 80010df8 <wait_lock>
    800026e8:	ffffe097          	auipc	ra,0xffffe
    800026ec:	5b6080e7          	jalr	1462(ra) # 80000c9e <release>
            return -1;
    800026f0:	59fd                	li	s3,-1
    800026f2:	a0b9                	j	80002740 <wait+0x106>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800026f4:	1e048493          	addi	s1,s1,480
    800026f8:	03348463          	beq	s1,s3,80002720 <wait+0xe6>
      if (pp->parent == p)
    800026fc:	7c9c                	ld	a5,56(s1)
    800026fe:	ff279be3          	bne	a5,s2,800026f4 <wait+0xba>
        acquire(&pp->lock);
    80002702:	8526                	mv	a0,s1
    80002704:	ffffe097          	auipc	ra,0xffffe
    80002708:	4e6080e7          	jalr	1254(ra) # 80000bea <acquire>
        if (pp->state == ZOMBIE)
    8000270c:	4c9c                	lw	a5,24(s1)
    8000270e:	f94781e3          	beq	a5,s4,80002690 <wait+0x56>
        release(&pp->lock);
    80002712:	8526                	mv	a0,s1
    80002714:	ffffe097          	auipc	ra,0xffffe
    80002718:	58a080e7          	jalr	1418(ra) # 80000c9e <release>
        havekids = 1;
    8000271c:	8756                	mv	a4,s5
    8000271e:	bfd9                	j	800026f4 <wait+0xba>
    if (!havekids || killed(p))
    80002720:	c719                	beqz	a4,8000272e <wait+0xf4>
    80002722:	854a                	mv	a0,s2
    80002724:	00000097          	auipc	ra,0x0
    80002728:	ee4080e7          	jalr	-284(ra) # 80002608 <killed>
    8000272c:	c51d                	beqz	a0,8000275a <wait+0x120>
      release(&wait_lock);
    8000272e:	0000e517          	auipc	a0,0xe
    80002732:	6ca50513          	addi	a0,a0,1738 # 80010df8 <wait_lock>
    80002736:	ffffe097          	auipc	ra,0xffffe
    8000273a:	568080e7          	jalr	1384(ra) # 80000c9e <release>
      return -1;
    8000273e:	59fd                	li	s3,-1
}
    80002740:	854e                	mv	a0,s3
    80002742:	60a6                	ld	ra,72(sp)
    80002744:	6406                	ld	s0,64(sp)
    80002746:	74e2                	ld	s1,56(sp)
    80002748:	7942                	ld	s2,48(sp)
    8000274a:	79a2                	ld	s3,40(sp)
    8000274c:	7a02                	ld	s4,32(sp)
    8000274e:	6ae2                	ld	s5,24(sp)
    80002750:	6b42                	ld	s6,16(sp)
    80002752:	6ba2                	ld	s7,8(sp)
    80002754:	6c02                	ld	s8,0(sp)
    80002756:	6161                	addi	sp,sp,80
    80002758:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000275a:	85e2                	mv	a1,s8
    8000275c:	854a                	mv	a0,s2
    8000275e:	00000097          	auipc	ra,0x0
    80002762:	aaa080e7          	jalr	-1366(ra) # 80002208 <sleep>
    havekids = 0;
    80002766:	bf39                	j	80002684 <wait+0x4a>

0000000080002768 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002768:	7179                	addi	sp,sp,-48
    8000276a:	f406                	sd	ra,40(sp)
    8000276c:	f022                	sd	s0,32(sp)
    8000276e:	ec26                	sd	s1,24(sp)
    80002770:	e84a                	sd	s2,16(sp)
    80002772:	e44e                	sd	s3,8(sp)
    80002774:	e052                	sd	s4,0(sp)
    80002776:	1800                	addi	s0,sp,48
    80002778:	84aa                	mv	s1,a0
    8000277a:	892e                	mv	s2,a1
    8000277c:	89b2                	mv	s3,a2
    8000277e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002780:	fffff097          	auipc	ra,0xfffff
    80002784:	246080e7          	jalr	582(ra) # 800019c6 <myproc>
  if (user_dst)
    80002788:	c08d                	beqz	s1,800027aa <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    8000278a:	86d2                	mv	a3,s4
    8000278c:	864e                	mv	a2,s3
    8000278e:	85ca                	mv	a1,s2
    80002790:	6928                	ld	a0,80(a0)
    80002792:	fffff097          	auipc	ra,0xfffff
    80002796:	ef2080e7          	jalr	-270(ra) # 80001684 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000279a:	70a2                	ld	ra,40(sp)
    8000279c:	7402                	ld	s0,32(sp)
    8000279e:	64e2                	ld	s1,24(sp)
    800027a0:	6942                	ld	s2,16(sp)
    800027a2:	69a2                	ld	s3,8(sp)
    800027a4:	6a02                	ld	s4,0(sp)
    800027a6:	6145                	addi	sp,sp,48
    800027a8:	8082                	ret
    memmove((char *)dst, src, len);
    800027aa:	000a061b          	sext.w	a2,s4
    800027ae:	85ce                	mv	a1,s3
    800027b0:	854a                	mv	a0,s2
    800027b2:	ffffe097          	auipc	ra,0xffffe
    800027b6:	594080e7          	jalr	1428(ra) # 80000d46 <memmove>
    return 0;
    800027ba:	8526                	mv	a0,s1
    800027bc:	bff9                	j	8000279a <either_copyout+0x32>

00000000800027be <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800027be:	7179                	addi	sp,sp,-48
    800027c0:	f406                	sd	ra,40(sp)
    800027c2:	f022                	sd	s0,32(sp)
    800027c4:	ec26                	sd	s1,24(sp)
    800027c6:	e84a                	sd	s2,16(sp)
    800027c8:	e44e                	sd	s3,8(sp)
    800027ca:	e052                	sd	s4,0(sp)
    800027cc:	1800                	addi	s0,sp,48
    800027ce:	892a                	mv	s2,a0
    800027d0:	84ae                	mv	s1,a1
    800027d2:	89b2                	mv	s3,a2
    800027d4:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800027d6:	fffff097          	auipc	ra,0xfffff
    800027da:	1f0080e7          	jalr	496(ra) # 800019c6 <myproc>
  if (user_src)
    800027de:	c08d                	beqz	s1,80002800 <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    800027e0:	86d2                	mv	a3,s4
    800027e2:	864e                	mv	a2,s3
    800027e4:	85ca                	mv	a1,s2
    800027e6:	6928                	ld	a0,80(a0)
    800027e8:	fffff097          	auipc	ra,0xfffff
    800027ec:	f28080e7          	jalr	-216(ra) # 80001710 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800027f0:	70a2                	ld	ra,40(sp)
    800027f2:	7402                	ld	s0,32(sp)
    800027f4:	64e2                	ld	s1,24(sp)
    800027f6:	6942                	ld	s2,16(sp)
    800027f8:	69a2                	ld	s3,8(sp)
    800027fa:	6a02                	ld	s4,0(sp)
    800027fc:	6145                	addi	sp,sp,48
    800027fe:	8082                	ret
    memmove(dst, (char *)src, len);
    80002800:	000a061b          	sext.w	a2,s4
    80002804:	85ce                	mv	a1,s3
    80002806:	854a                	mv	a0,s2
    80002808:	ffffe097          	auipc	ra,0xffffe
    8000280c:	53e080e7          	jalr	1342(ra) # 80000d46 <memmove>
    return 0;
    80002810:	8526                	mv	a0,s1
    80002812:	bff9                	j	800027f0 <either_copyin+0x32>

0000000080002814 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002814:	715d                	addi	sp,sp,-80
    80002816:	e486                	sd	ra,72(sp)
    80002818:	e0a2                	sd	s0,64(sp)
    8000281a:	fc26                	sd	s1,56(sp)
    8000281c:	f84a                	sd	s2,48(sp)
    8000281e:	f44e                	sd	s3,40(sp)
    80002820:	f052                	sd	s4,32(sp)
    80002822:	ec56                	sd	s5,24(sp)
    80002824:	e85a                	sd	s6,16(sp)
    80002826:	e45e                	sd	s7,8(sp)
    80002828:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    8000282a:	00006517          	auipc	a0,0x6
    8000282e:	89e50513          	addi	a0,a0,-1890 # 800080c8 <digits+0x88>
    80002832:	ffffe097          	auipc	ra,0xffffe
    80002836:	d5c080e7          	jalr	-676(ra) # 8000058e <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    8000283a:	0000f497          	auipc	s1,0xf
    8000283e:	b5e48493          	addi	s1,s1,-1186 # 80011398 <proc+0x158>
    80002842:	00016917          	auipc	s2,0x16
    80002846:	35690913          	addi	s2,s2,854 # 80018b98 <bcache+0x140>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000284a:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000284c:	00006997          	auipc	s3,0x6
    80002850:	a3498993          	addi	s3,s3,-1484 # 80008280 <digits+0x240>
    printf("%d %s %s %d %d %d %d", p->pid, state, p->name, p->queue, p->tickcount, p->waittickcount, p->queueposition);
    80002854:	00006a97          	auipc	s5,0x6
    80002858:	a34a8a93          	addi	s5,s5,-1484 # 80008288 <digits+0x248>
    printf("\n");
    8000285c:	00006a17          	auipc	s4,0x6
    80002860:	86ca0a13          	addi	s4,s4,-1940 # 800080c8 <digits+0x88>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002864:	00006b97          	auipc	s7,0x6
    80002868:	a7cb8b93          	addi	s7,s7,-1412 # 800082e0 <states.1788>
    8000286c:	a03d                	j	8000289a <procdump+0x86>
    printf("%d %s %s %d %d %d %d", p->pid, state, p->name, p->queue, p->tickcount, p->waittickcount, p->queueposition);
    8000286e:	0846a883          	lw	a7,132(a3)
    80002872:	0806a803          	lw	a6,128(a3)
    80002876:	5ebc                	lw	a5,120(a3)
    80002878:	5ef8                	lw	a4,124(a3)
    8000287a:	ed86a583          	lw	a1,-296(a3)
    8000287e:	8556                	mv	a0,s5
    80002880:	ffffe097          	auipc	ra,0xffffe
    80002884:	d0e080e7          	jalr	-754(ra) # 8000058e <printf>
    printf("\n");
    80002888:	8552                	mv	a0,s4
    8000288a:	ffffe097          	auipc	ra,0xffffe
    8000288e:	d04080e7          	jalr	-764(ra) # 8000058e <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002892:	1e048493          	addi	s1,s1,480
    80002896:	03248163          	beq	s1,s2,800028b8 <procdump+0xa4>
    if (p->state == UNUSED)
    8000289a:	86a6                	mv	a3,s1
    8000289c:	ec04a783          	lw	a5,-320(s1)
    800028a0:	dbed                	beqz	a5,80002892 <procdump+0x7e>
      state = "???";
    800028a2:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028a4:	fcfb65e3          	bltu	s6,a5,8000286e <procdump+0x5a>
    800028a8:	1782                	slli	a5,a5,0x20
    800028aa:	9381                	srli	a5,a5,0x20
    800028ac:	078e                	slli	a5,a5,0x3
    800028ae:	97de                	add	a5,a5,s7
    800028b0:	6390                	ld	a2,0(a5)
    800028b2:	fe55                	bnez	a2,8000286e <procdump+0x5a>
      state = "???";
    800028b4:	864e                	mv	a2,s3
    800028b6:	bf65                	j	8000286e <procdump+0x5a>
  }
  printf("%d %d %d %d %d\n", queueprocesscount[0], queueprocesscount[1], queueprocesscount[2], queueprocesscount[3], queueprocesscount[4]);
    800028b8:	0000e597          	auipc	a1,0xe
    800028bc:	52858593          	addi	a1,a1,1320 # 80010de0 <pid_lock>
    800028c0:	4405a783          	lw	a5,1088(a1)
    800028c4:	43c5a703          	lw	a4,1084(a1)
    800028c8:	4385a683          	lw	a3,1080(a1)
    800028cc:	4345a603          	lw	a2,1076(a1)
    800028d0:	4305a583          	lw	a1,1072(a1)
    800028d4:	00006517          	auipc	a0,0x6
    800028d8:	9cc50513          	addi	a0,a0,-1588 # 800082a0 <digits+0x260>
    800028dc:	ffffe097          	auipc	ra,0xffffe
    800028e0:	cb2080e7          	jalr	-846(ra) # 8000058e <printf>
}
    800028e4:	60a6                	ld	ra,72(sp)
    800028e6:	6406                	ld	s0,64(sp)
    800028e8:	74e2                	ld	s1,56(sp)
    800028ea:	7942                	ld	s2,48(sp)
    800028ec:	79a2                	ld	s3,40(sp)
    800028ee:	7a02                	ld	s4,32(sp)
    800028f0:	6ae2                	ld	s5,24(sp)
    800028f2:	6b42                	ld	s6,16(sp)
    800028f4:	6ba2                	ld	s7,8(sp)
    800028f6:	6161                	addi	sp,sp,80
    800028f8:	8082                	ret

00000000800028fa <setpriority>:

int setpriority(int new_priority, int pid)
{
    800028fa:	7179                	addi	sp,sp,-48
    800028fc:	f406                	sd	ra,40(sp)
    800028fe:	f022                	sd	s0,32(sp)
    80002900:	ec26                	sd	s1,24(sp)
    80002902:	e84a                	sd	s2,16(sp)
    80002904:	e44e                	sd	s3,8(sp)
    80002906:	e052                	sd	s4,0(sp)
    80002908:	1800                	addi	s0,sp,48
    8000290a:	8a2a                	mv	s4,a0
    8000290c:	892e                	mv	s2,a1
  int prev_priority;
  prev_priority = 0;

  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    8000290e:	0000f497          	auipc	s1,0xf
    80002912:	93248493          	addi	s1,s1,-1742 # 80011240 <proc>
    80002916:	00016997          	auipc	s3,0x16
    8000291a:	12a98993          	addi	s3,s3,298 # 80018a40 <tickslock>
  {
    acquire(&p->lock);
    8000291e:	8526                	mv	a0,s1
    80002920:	ffffe097          	auipc	ra,0xffffe
    80002924:	2ca080e7          	jalr	714(ra) # 80000bea <acquire>

    if (p->pid == pid)
    80002928:	589c                	lw	a5,48(s1)
    8000292a:	01278d63          	beq	a5,s2,80002944 <setpriority+0x4a>
        yield();
      }

      break;
    }
    release(&p->lock);
    8000292e:	8526                	mv	a0,s1
    80002930:	ffffe097          	auipc	ra,0xffffe
    80002934:	36e080e7          	jalr	878(ra) # 80000c9e <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002938:	1e048493          	addi	s1,s1,480
    8000293c:	ff3491e3          	bne	s1,s3,8000291e <setpriority+0x24>
  prev_priority = 0;
    80002940:	4901                	li	s2,0
    80002942:	a005                	j	80002962 <setpriority+0x68>
      prev_priority = p->priority;
    80002944:	1c84a903          	lw	s2,456(s1)
      p->priority = new_priority;
    80002948:	1d44b423          	sd	s4,456(s1)
      p->sleeptime = 0;
    8000294c:	1a04bc23          	sd	zero,440(s1)
      p->runtime = 0;
    80002950:	1a04b423          	sd	zero,424(s1)
      release(&p->lock);
    80002954:	8526                	mv	a0,s1
    80002956:	ffffe097          	auipc	ra,0xffffe
    8000295a:	348080e7          	jalr	840(ra) # 80000c9e <release>
      if (reschedule)
    8000295e:	012a4b63          	blt	s4,s2,80002974 <setpriority+0x7a>
  }
  return prev_priority;
}
    80002962:	854a                	mv	a0,s2
    80002964:	70a2                	ld	ra,40(sp)
    80002966:	7402                	ld	s0,32(sp)
    80002968:	64e2                	ld	s1,24(sp)
    8000296a:	6942                	ld	s2,16(sp)
    8000296c:	69a2                	ld	s3,8(sp)
    8000296e:	6a02                	ld	s4,0(sp)
    80002970:	6145                	addi	sp,sp,48
    80002972:	8082                	ret
        yield();
    80002974:	00000097          	auipc	ra,0x0
    80002978:	858080e7          	jalr	-1960(ra) # 800021cc <yield>
    8000297c:	b7dd                	j	80002962 <setpriority+0x68>

000000008000297e <swtch>:
    8000297e:	00153023          	sd	ra,0(a0)
    80002982:	00253423          	sd	sp,8(a0)
    80002986:	e900                	sd	s0,16(a0)
    80002988:	ed04                	sd	s1,24(a0)
    8000298a:	03253023          	sd	s2,32(a0)
    8000298e:	03353423          	sd	s3,40(a0)
    80002992:	03453823          	sd	s4,48(a0)
    80002996:	03553c23          	sd	s5,56(a0)
    8000299a:	05653023          	sd	s6,64(a0)
    8000299e:	05753423          	sd	s7,72(a0)
    800029a2:	05853823          	sd	s8,80(a0)
    800029a6:	05953c23          	sd	s9,88(a0)
    800029aa:	07a53023          	sd	s10,96(a0)
    800029ae:	07b53423          	sd	s11,104(a0)
    800029b2:	0005b083          	ld	ra,0(a1)
    800029b6:	0085b103          	ld	sp,8(a1)
    800029ba:	6980                	ld	s0,16(a1)
    800029bc:	6d84                	ld	s1,24(a1)
    800029be:	0205b903          	ld	s2,32(a1)
    800029c2:	0285b983          	ld	s3,40(a1)
    800029c6:	0305ba03          	ld	s4,48(a1)
    800029ca:	0385ba83          	ld	s5,56(a1)
    800029ce:	0405bb03          	ld	s6,64(a1)
    800029d2:	0485bb83          	ld	s7,72(a1)
    800029d6:	0505bc03          	ld	s8,80(a1)
    800029da:	0585bc83          	ld	s9,88(a1)
    800029de:	0605bd03          	ld	s10,96(a1)
    800029e2:	0685bd83          	ld	s11,104(a1)
    800029e6:	8082                	ret

00000000800029e8 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800029e8:	1141                	addi	sp,sp,-16
    800029ea:	e406                	sd	ra,8(sp)
    800029ec:	e022                	sd	s0,0(sp)
    800029ee:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800029f0:	00006597          	auipc	a1,0x6
    800029f4:	92058593          	addi	a1,a1,-1760 # 80008310 <states.1788+0x30>
    800029f8:	00016517          	auipc	a0,0x16
    800029fc:	04850513          	addi	a0,a0,72 # 80018a40 <tickslock>
    80002a00:	ffffe097          	auipc	ra,0xffffe
    80002a04:	15a080e7          	jalr	346(ra) # 80000b5a <initlock>
}
    80002a08:	60a2                	ld	ra,8(sp)
    80002a0a:	6402                	ld	s0,0(sp)
    80002a0c:	0141                	addi	sp,sp,16
    80002a0e:	8082                	ret

0000000080002a10 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002a10:	1141                	addi	sp,sp,-16
    80002a12:	e422                	sd	s0,8(sp)
    80002a14:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a16:	00003797          	auipc	a5,0x3
    80002a1a:	77a78793          	addi	a5,a5,1914 # 80006190 <kernelvec>
    80002a1e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002a22:	6422                	ld	s0,8(sp)
    80002a24:	0141                	addi	sp,sp,16
    80002a26:	8082                	ret

0000000080002a28 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002a28:	1141                	addi	sp,sp,-16
    80002a2a:	e406                	sd	ra,8(sp)
    80002a2c:	e022                	sd	s0,0(sp)
    80002a2e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002a30:	fffff097          	auipc	ra,0xfffff
    80002a34:	f96080e7          	jalr	-106(ra) # 800019c6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a38:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002a3c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a3e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002a42:	00004617          	auipc	a2,0x4
    80002a46:	5be60613          	addi	a2,a2,1470 # 80007000 <_trampoline>
    80002a4a:	00004697          	auipc	a3,0x4
    80002a4e:	5b668693          	addi	a3,a3,1462 # 80007000 <_trampoline>
    80002a52:	8e91                	sub	a3,a3,a2
    80002a54:	040007b7          	lui	a5,0x4000
    80002a58:	17fd                	addi	a5,a5,-1
    80002a5a:	07b2                	slli	a5,a5,0xc
    80002a5c:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a5e:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002a62:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002a64:	180026f3          	csrr	a3,satp
    80002a68:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002a6a:	6d38                	ld	a4,88(a0)
    80002a6c:	6134                	ld	a3,64(a0)
    80002a6e:	6585                	lui	a1,0x1
    80002a70:	96ae                	add	a3,a3,a1
    80002a72:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002a74:	6d38                	ld	a4,88(a0)
    80002a76:	00000697          	auipc	a3,0x0
    80002a7a:	13e68693          	addi	a3,a3,318 # 80002bb4 <usertrap>
    80002a7e:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002a80:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002a82:	8692                	mv	a3,tp
    80002a84:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a86:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002a8a:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002a8e:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a92:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002a96:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a98:	6f18                	ld	a4,24(a4)
    80002a9a:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002a9e:	6928                	ld	a0,80(a0)
    80002aa0:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002aa2:	00004717          	auipc	a4,0x4
    80002aa6:	5fa70713          	addi	a4,a4,1530 # 8000709c <userret>
    80002aaa:	8f11                	sub	a4,a4,a2
    80002aac:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002aae:	577d                	li	a4,-1
    80002ab0:	177e                	slli	a4,a4,0x3f
    80002ab2:	8d59                	or	a0,a0,a4
    80002ab4:	9782                	jalr	a5
}
    80002ab6:	60a2                	ld	ra,8(sp)
    80002ab8:	6402                	ld	s0,0(sp)
    80002aba:	0141                	addi	sp,sp,16
    80002abc:	8082                	ret

0000000080002abe <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002abe:	1101                	addi	sp,sp,-32
    80002ac0:	ec06                	sd	ra,24(sp)
    80002ac2:	e822                	sd	s0,16(sp)
    80002ac4:	e426                	sd	s1,8(sp)
    80002ac6:	e04a                	sd	s2,0(sp)
    80002ac8:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002aca:	00016917          	auipc	s2,0x16
    80002ace:	f7690913          	addi	s2,s2,-138 # 80018a40 <tickslock>
    80002ad2:	854a                	mv	a0,s2
    80002ad4:	ffffe097          	auipc	ra,0xffffe
    80002ad8:	116080e7          	jalr	278(ra) # 80000bea <acquire>
  ticks++;
    80002adc:	00006497          	auipc	s1,0x6
    80002ae0:	09448493          	addi	s1,s1,148 # 80008b70 <ticks>
    80002ae4:	409c                	lw	a5,0(s1)
    80002ae6:	2785                	addiw	a5,a5,1
    80002ae8:	c09c                	sw	a5,0(s1)
  update_time();
    80002aea:	fffff097          	auipc	ra,0xfffff
    80002aee:	484080e7          	jalr	1156(ra) # 80001f6e <update_time>
  wakeup(&ticks);
    80002af2:	8526                	mv	a0,s1
    80002af4:	00000097          	auipc	ra,0x0
    80002af8:	8c4080e7          	jalr	-1852(ra) # 800023b8 <wakeup>
  release(&tickslock);
    80002afc:	854a                	mv	a0,s2
    80002afe:	ffffe097          	auipc	ra,0xffffe
    80002b02:	1a0080e7          	jalr	416(ra) # 80000c9e <release>
}
    80002b06:	60e2                	ld	ra,24(sp)
    80002b08:	6442                	ld	s0,16(sp)
    80002b0a:	64a2                	ld	s1,8(sp)
    80002b0c:	6902                	ld	s2,0(sp)
    80002b0e:	6105                	addi	sp,sp,32
    80002b10:	8082                	ret

0000000080002b12 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002b12:	1101                	addi	sp,sp,-32
    80002b14:	ec06                	sd	ra,24(sp)
    80002b16:	e822                	sd	s0,16(sp)
    80002b18:	e426                	sd	s1,8(sp)
    80002b1a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b1c:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002b20:	00074d63          	bltz	a4,80002b3a <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002b24:	57fd                	li	a5,-1
    80002b26:	17fe                	slli	a5,a5,0x3f
    80002b28:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002b2a:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002b2c:	06f70363          	beq	a4,a5,80002b92 <devintr+0x80>
  }
}
    80002b30:	60e2                	ld	ra,24(sp)
    80002b32:	6442                	ld	s0,16(sp)
    80002b34:	64a2                	ld	s1,8(sp)
    80002b36:	6105                	addi	sp,sp,32
    80002b38:	8082                	ret
     (scause & 0xff) == 9){
    80002b3a:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002b3e:	46a5                	li	a3,9
    80002b40:	fed792e3          	bne	a5,a3,80002b24 <devintr+0x12>
    int irq = plic_claim();
    80002b44:	00003097          	auipc	ra,0x3
    80002b48:	754080e7          	jalr	1876(ra) # 80006298 <plic_claim>
    80002b4c:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002b4e:	47a9                	li	a5,10
    80002b50:	02f50763          	beq	a0,a5,80002b7e <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002b54:	4785                	li	a5,1
    80002b56:	02f50963          	beq	a0,a5,80002b88 <devintr+0x76>
    return 1;
    80002b5a:	4505                	li	a0,1
    } else if(irq){
    80002b5c:	d8f1                	beqz	s1,80002b30 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002b5e:	85a6                	mv	a1,s1
    80002b60:	00005517          	auipc	a0,0x5
    80002b64:	7b850513          	addi	a0,a0,1976 # 80008318 <states.1788+0x38>
    80002b68:	ffffe097          	auipc	ra,0xffffe
    80002b6c:	a26080e7          	jalr	-1498(ra) # 8000058e <printf>
      plic_complete(irq);
    80002b70:	8526                	mv	a0,s1
    80002b72:	00003097          	auipc	ra,0x3
    80002b76:	74a080e7          	jalr	1866(ra) # 800062bc <plic_complete>
    return 1;
    80002b7a:	4505                	li	a0,1
    80002b7c:	bf55                	j	80002b30 <devintr+0x1e>
      uartintr();
    80002b7e:	ffffe097          	auipc	ra,0xffffe
    80002b82:	e30080e7          	jalr	-464(ra) # 800009ae <uartintr>
    80002b86:	b7ed                	j	80002b70 <devintr+0x5e>
      virtio_disk_intr();
    80002b88:	00004097          	auipc	ra,0x4
    80002b8c:	c5e080e7          	jalr	-930(ra) # 800067e6 <virtio_disk_intr>
    80002b90:	b7c5                	j	80002b70 <devintr+0x5e>
    if(cpuid() == 0){
    80002b92:	fffff097          	auipc	ra,0xfffff
    80002b96:	e08080e7          	jalr	-504(ra) # 8000199a <cpuid>
    80002b9a:	c901                	beqz	a0,80002baa <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002b9c:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002ba0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002ba2:	14479073          	csrw	sip,a5
    return 2;
    80002ba6:	4509                	li	a0,2
    80002ba8:	b761                	j	80002b30 <devintr+0x1e>
      clockintr();
    80002baa:	00000097          	auipc	ra,0x0
    80002bae:	f14080e7          	jalr	-236(ra) # 80002abe <clockintr>
    80002bb2:	b7ed                	j	80002b9c <devintr+0x8a>

0000000080002bb4 <usertrap>:
{
    80002bb4:	1101                	addi	sp,sp,-32
    80002bb6:	ec06                	sd	ra,24(sp)
    80002bb8:	e822                	sd	s0,16(sp)
    80002bba:	e426                	sd	s1,8(sp)
    80002bbc:	e04a                	sd	s2,0(sp)
    80002bbe:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bc0:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002bc4:	1007f793          	andi	a5,a5,256
    80002bc8:	e3b1                	bnez	a5,80002c0c <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002bca:	00003797          	auipc	a5,0x3
    80002bce:	5c678793          	addi	a5,a5,1478 # 80006190 <kernelvec>
    80002bd2:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002bd6:	fffff097          	auipc	ra,0xfffff
    80002bda:	df0080e7          	jalr	-528(ra) # 800019c6 <myproc>
    80002bde:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002be0:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002be2:	14102773          	csrr	a4,sepc
    80002be6:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002be8:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002bec:	47a1                	li	a5,8
    80002bee:	02f70763          	beq	a4,a5,80002c1c <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002bf2:	00000097          	auipc	ra,0x0
    80002bf6:	f20080e7          	jalr	-224(ra) # 80002b12 <devintr>
    80002bfa:	892a                	mv	s2,a0
    80002bfc:	c92d                	beqz	a0,80002c6e <usertrap+0xba>
  if(killed(p))
    80002bfe:	8526                	mv	a0,s1
    80002c00:	00000097          	auipc	ra,0x0
    80002c04:	a08080e7          	jalr	-1528(ra) # 80002608 <killed>
    80002c08:	c555                	beqz	a0,80002cb4 <usertrap+0x100>
    80002c0a:	a045                	j	80002caa <usertrap+0xf6>
    panic("usertrap: not from user mode");
    80002c0c:	00005517          	auipc	a0,0x5
    80002c10:	72c50513          	addi	a0,a0,1836 # 80008338 <states.1788+0x58>
    80002c14:	ffffe097          	auipc	ra,0xffffe
    80002c18:	930080e7          	jalr	-1744(ra) # 80000544 <panic>
    if(killed(p))
    80002c1c:	00000097          	auipc	ra,0x0
    80002c20:	9ec080e7          	jalr	-1556(ra) # 80002608 <killed>
    80002c24:	ed1d                	bnez	a0,80002c62 <usertrap+0xae>
    p->trapframe->epc += 4;
    80002c26:	6cb8                	ld	a4,88(s1)
    80002c28:	6f1c                	ld	a5,24(a4)
    80002c2a:	0791                	addi	a5,a5,4
    80002c2c:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c2e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002c32:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c36:	10079073          	csrw	sstatus,a5
    syscall();
    80002c3a:	00000097          	auipc	ra,0x0
    80002c3e:	2ee080e7          	jalr	750(ra) # 80002f28 <syscall>
  if(killed(p))
    80002c42:	8526                	mv	a0,s1
    80002c44:	00000097          	auipc	ra,0x0
    80002c48:	9c4080e7          	jalr	-1596(ra) # 80002608 <killed>
    80002c4c:	ed31                	bnez	a0,80002ca8 <usertrap+0xf4>
  usertrapret();
    80002c4e:	00000097          	auipc	ra,0x0
    80002c52:	dda080e7          	jalr	-550(ra) # 80002a28 <usertrapret>
}
    80002c56:	60e2                	ld	ra,24(sp)
    80002c58:	6442                	ld	s0,16(sp)
    80002c5a:	64a2                	ld	s1,8(sp)
    80002c5c:	6902                	ld	s2,0(sp)
    80002c5e:	6105                	addi	sp,sp,32
    80002c60:	8082                	ret
      exit(-1);
    80002c62:	557d                	li	a0,-1
    80002c64:	00000097          	auipc	ra,0x0
    80002c68:	824080e7          	jalr	-2012(ra) # 80002488 <exit>
    80002c6c:	bf6d                	j	80002c26 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c6e:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002c72:	5890                	lw	a2,48(s1)
    80002c74:	00005517          	auipc	a0,0x5
    80002c78:	6e450513          	addi	a0,a0,1764 # 80008358 <states.1788+0x78>
    80002c7c:	ffffe097          	auipc	ra,0xffffe
    80002c80:	912080e7          	jalr	-1774(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c84:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c88:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c8c:	00005517          	auipc	a0,0x5
    80002c90:	6fc50513          	addi	a0,a0,1788 # 80008388 <states.1788+0xa8>
    80002c94:	ffffe097          	auipc	ra,0xffffe
    80002c98:	8fa080e7          	jalr	-1798(ra) # 8000058e <printf>
    setkilled(p);
    80002c9c:	8526                	mv	a0,s1
    80002c9e:	00000097          	auipc	ra,0x0
    80002ca2:	93e080e7          	jalr	-1730(ra) # 800025dc <setkilled>
    80002ca6:	bf71                	j	80002c42 <usertrap+0x8e>
  if(killed(p))
    80002ca8:	4901                	li	s2,0
    exit(-1);
    80002caa:	557d                	li	a0,-1
    80002cac:	fffff097          	auipc	ra,0xfffff
    80002cb0:	7dc080e7          	jalr	2012(ra) # 80002488 <exit>
  if (which_dev == 2 && p->alarm_on == 1 && p->handlerpermission == 1) {
    80002cb4:	4789                	li	a5,2
    80002cb6:	f8f91ce3          	bne	s2,a5,80002c4e <usertrap+0x9a>
    80002cba:	1984b703          	ld	a4,408(s1)
    80002cbe:	4785                	li	a5,1
    80002cc0:	1782                	slli	a5,a5,0x20
    80002cc2:	0785                	addi	a5,a5,1
    80002cc4:	f8f715e3          	bne	a4,a5,80002c4e <usertrap+0x9a>
      struct trapframe *tf = kalloc();
    80002cc8:	ffffe097          	auipc	ra,0xffffe
    80002ccc:	e32080e7          	jalr	-462(ra) # 80000afa <kalloc>
    80002cd0:	892a                	mv	s2,a0
      memmove(tf, p->trapframe, PGSIZE);
    80002cd2:	6605                	lui	a2,0x1
    80002cd4:	6cac                	ld	a1,88(s1)
    80002cd6:	ffffe097          	auipc	ra,0xffffe
    80002cda:	070080e7          	jalr	112(ra) # 80000d46 <memmove>
      p->alarm_tf = tf;
    80002cde:	1924b823          	sd	s2,400(s1)
      p->cur_ticks++;
    80002ce2:	18c4a783          	lw	a5,396(s1)
    80002ce6:	2785                	addiw	a5,a5,1
    80002ce8:	18f4a623          	sw	a5,396(s1)
      if (p->cur_ticks % p->ticks == 0){
    80002cec:	1884a703          	lw	a4,392(s1)
    80002cf0:	02e7e7bb          	remw	a5,a5,a4
    80002cf4:	ffa9                	bnez	a5,80002c4e <usertrap+0x9a>
        p->trapframe->epc = p->handler;
    80002cf6:	6cbc                	ld	a5,88(s1)
    80002cf8:	1804b703          	ld	a4,384(s1)
    80002cfc:	ef98                	sd	a4,24(a5)
        p->handlerpermission = 0;
    80002cfe:	1804ae23          	sw	zero,412(s1)
    80002d02:	b7b1                	j	80002c4e <usertrap+0x9a>

0000000080002d04 <kerneltrap>:
{
    80002d04:	7179                	addi	sp,sp,-48
    80002d06:	f406                	sd	ra,40(sp)
    80002d08:	f022                	sd	s0,32(sp)
    80002d0a:	ec26                	sd	s1,24(sp)
    80002d0c:	e84a                	sd	s2,16(sp)
    80002d0e:	e44e                	sd	s3,8(sp)
    80002d10:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d12:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d16:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d1a:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002d1e:	1004f793          	andi	a5,s1,256
    80002d22:	c78d                	beqz	a5,80002d4c <kerneltrap+0x48>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d24:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002d28:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002d2a:	eb8d                	bnez	a5,80002d5c <kerneltrap+0x58>
  if((which_dev = devintr()) == 0){
    80002d2c:	00000097          	auipc	ra,0x0
    80002d30:	de6080e7          	jalr	-538(ra) # 80002b12 <devintr>
    80002d34:	cd05                	beqz	a0,80002d6c <kerneltrap+0x68>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002d36:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d3a:	10049073          	csrw	sstatus,s1
}
    80002d3e:	70a2                	ld	ra,40(sp)
    80002d40:	7402                	ld	s0,32(sp)
    80002d42:	64e2                	ld	s1,24(sp)
    80002d44:	6942                	ld	s2,16(sp)
    80002d46:	69a2                	ld	s3,8(sp)
    80002d48:	6145                	addi	sp,sp,48
    80002d4a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002d4c:	00005517          	auipc	a0,0x5
    80002d50:	65c50513          	addi	a0,a0,1628 # 800083a8 <states.1788+0xc8>
    80002d54:	ffffd097          	auipc	ra,0xffffd
    80002d58:	7f0080e7          	jalr	2032(ra) # 80000544 <panic>
    panic("kerneltrap: interrupts enabled");
    80002d5c:	00005517          	auipc	a0,0x5
    80002d60:	67450513          	addi	a0,a0,1652 # 800083d0 <states.1788+0xf0>
    80002d64:	ffffd097          	auipc	ra,0xffffd
    80002d68:	7e0080e7          	jalr	2016(ra) # 80000544 <panic>
    printf("scause %p\n", scause);
    80002d6c:	85ce                	mv	a1,s3
    80002d6e:	00005517          	auipc	a0,0x5
    80002d72:	68250513          	addi	a0,a0,1666 # 800083f0 <states.1788+0x110>
    80002d76:	ffffe097          	auipc	ra,0xffffe
    80002d7a:	818080e7          	jalr	-2024(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d7e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d82:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d86:	00005517          	auipc	a0,0x5
    80002d8a:	67a50513          	addi	a0,a0,1658 # 80008400 <states.1788+0x120>
    80002d8e:	ffffe097          	auipc	ra,0xffffe
    80002d92:	800080e7          	jalr	-2048(ra) # 8000058e <printf>
    panic("kerneltrap");
    80002d96:	00005517          	auipc	a0,0x5
    80002d9a:	68250513          	addi	a0,a0,1666 # 80008418 <states.1788+0x138>
    80002d9e:	ffffd097          	auipc	ra,0xffffd
    80002da2:	7a6080e7          	jalr	1958(ra) # 80000544 <panic>

0000000080002da6 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002da6:	1101                	addi	sp,sp,-32
    80002da8:	ec06                	sd	ra,24(sp)
    80002daa:	e822                	sd	s0,16(sp)
    80002dac:	e426                	sd	s1,8(sp)
    80002dae:	1000                	addi	s0,sp,32
    80002db0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002db2:	fffff097          	auipc	ra,0xfffff
    80002db6:	c14080e7          	jalr	-1004(ra) # 800019c6 <myproc>
  switch (n) {
    80002dba:	4795                	li	a5,5
    80002dbc:	0497e163          	bltu	a5,s1,80002dfe <argraw+0x58>
    80002dc0:	048a                	slli	s1,s1,0x2
    80002dc2:	00005717          	auipc	a4,0x5
    80002dc6:	7ae70713          	addi	a4,a4,1966 # 80008570 <states.1788+0x290>
    80002dca:	94ba                	add	s1,s1,a4
    80002dcc:	409c                	lw	a5,0(s1)
    80002dce:	97ba                	add	a5,a5,a4
    80002dd0:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002dd2:	6d3c                	ld	a5,88(a0)
    80002dd4:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002dd6:	60e2                	ld	ra,24(sp)
    80002dd8:	6442                	ld	s0,16(sp)
    80002dda:	64a2                	ld	s1,8(sp)
    80002ddc:	6105                	addi	sp,sp,32
    80002dde:	8082                	ret
    return p->trapframe->a1;
    80002de0:	6d3c                	ld	a5,88(a0)
    80002de2:	7fa8                	ld	a0,120(a5)
    80002de4:	bfcd                	j	80002dd6 <argraw+0x30>
    return p->trapframe->a2;
    80002de6:	6d3c                	ld	a5,88(a0)
    80002de8:	63c8                	ld	a0,128(a5)
    80002dea:	b7f5                	j	80002dd6 <argraw+0x30>
    return p->trapframe->a3;
    80002dec:	6d3c                	ld	a5,88(a0)
    80002dee:	67c8                	ld	a0,136(a5)
    80002df0:	b7dd                	j	80002dd6 <argraw+0x30>
    return p->trapframe->a4;
    80002df2:	6d3c                	ld	a5,88(a0)
    80002df4:	6bc8                	ld	a0,144(a5)
    80002df6:	b7c5                	j	80002dd6 <argraw+0x30>
    return p->trapframe->a5;
    80002df8:	6d3c                	ld	a5,88(a0)
    80002dfa:	6fc8                	ld	a0,152(a5)
    80002dfc:	bfe9                	j	80002dd6 <argraw+0x30>
  panic("argraw");
    80002dfe:	00005517          	auipc	a0,0x5
    80002e02:	62a50513          	addi	a0,a0,1578 # 80008428 <states.1788+0x148>
    80002e06:	ffffd097          	auipc	ra,0xffffd
    80002e0a:	73e080e7          	jalr	1854(ra) # 80000544 <panic>

0000000080002e0e <fetchaddr>:
{
    80002e0e:	1101                	addi	sp,sp,-32
    80002e10:	ec06                	sd	ra,24(sp)
    80002e12:	e822                	sd	s0,16(sp)
    80002e14:	e426                	sd	s1,8(sp)
    80002e16:	e04a                	sd	s2,0(sp)
    80002e18:	1000                	addi	s0,sp,32
    80002e1a:	84aa                	mv	s1,a0
    80002e1c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002e1e:	fffff097          	auipc	ra,0xfffff
    80002e22:	ba8080e7          	jalr	-1112(ra) # 800019c6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002e26:	653c                	ld	a5,72(a0)
    80002e28:	02f4f863          	bgeu	s1,a5,80002e58 <fetchaddr+0x4a>
    80002e2c:	00848713          	addi	a4,s1,8
    80002e30:	02e7e663          	bltu	a5,a4,80002e5c <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002e34:	46a1                	li	a3,8
    80002e36:	8626                	mv	a2,s1
    80002e38:	85ca                	mv	a1,s2
    80002e3a:	6928                	ld	a0,80(a0)
    80002e3c:	fffff097          	auipc	ra,0xfffff
    80002e40:	8d4080e7          	jalr	-1836(ra) # 80001710 <copyin>
    80002e44:	00a03533          	snez	a0,a0
    80002e48:	40a00533          	neg	a0,a0
}
    80002e4c:	60e2                	ld	ra,24(sp)
    80002e4e:	6442                	ld	s0,16(sp)
    80002e50:	64a2                	ld	s1,8(sp)
    80002e52:	6902                	ld	s2,0(sp)
    80002e54:	6105                	addi	sp,sp,32
    80002e56:	8082                	ret
    return -1;
    80002e58:	557d                	li	a0,-1
    80002e5a:	bfcd                	j	80002e4c <fetchaddr+0x3e>
    80002e5c:	557d                	li	a0,-1
    80002e5e:	b7fd                	j	80002e4c <fetchaddr+0x3e>

0000000080002e60 <fetchstr>:
{
    80002e60:	7179                	addi	sp,sp,-48
    80002e62:	f406                	sd	ra,40(sp)
    80002e64:	f022                	sd	s0,32(sp)
    80002e66:	ec26                	sd	s1,24(sp)
    80002e68:	e84a                	sd	s2,16(sp)
    80002e6a:	e44e                	sd	s3,8(sp)
    80002e6c:	1800                	addi	s0,sp,48
    80002e6e:	892a                	mv	s2,a0
    80002e70:	84ae                	mv	s1,a1
    80002e72:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002e74:	fffff097          	auipc	ra,0xfffff
    80002e78:	b52080e7          	jalr	-1198(ra) # 800019c6 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002e7c:	86ce                	mv	a3,s3
    80002e7e:	864a                	mv	a2,s2
    80002e80:	85a6                	mv	a1,s1
    80002e82:	6928                	ld	a0,80(a0)
    80002e84:	fffff097          	auipc	ra,0xfffff
    80002e88:	918080e7          	jalr	-1768(ra) # 8000179c <copyinstr>
    80002e8c:	00054e63          	bltz	a0,80002ea8 <fetchstr+0x48>
  return strlen(buf);
    80002e90:	8526                	mv	a0,s1
    80002e92:	ffffe097          	auipc	ra,0xffffe
    80002e96:	fd8080e7          	jalr	-40(ra) # 80000e6a <strlen>
}
    80002e9a:	70a2                	ld	ra,40(sp)
    80002e9c:	7402                	ld	s0,32(sp)
    80002e9e:	64e2                	ld	s1,24(sp)
    80002ea0:	6942                	ld	s2,16(sp)
    80002ea2:	69a2                	ld	s3,8(sp)
    80002ea4:	6145                	addi	sp,sp,48
    80002ea6:	8082                	ret
    return -1;
    80002ea8:	557d                	li	a0,-1
    80002eaa:	bfc5                	j	80002e9a <fetchstr+0x3a>

0000000080002eac <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002eac:	1101                	addi	sp,sp,-32
    80002eae:	ec06                	sd	ra,24(sp)
    80002eb0:	e822                	sd	s0,16(sp)
    80002eb2:	e426                	sd	s1,8(sp)
    80002eb4:	1000                	addi	s0,sp,32
    80002eb6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002eb8:	00000097          	auipc	ra,0x0
    80002ebc:	eee080e7          	jalr	-274(ra) # 80002da6 <argraw>
    80002ec0:	c088                	sw	a0,0(s1)
  return 0;
}
    80002ec2:	4501                	li	a0,0
    80002ec4:	60e2                	ld	ra,24(sp)
    80002ec6:	6442                	ld	s0,16(sp)
    80002ec8:	64a2                	ld	s1,8(sp)
    80002eca:	6105                	addi	sp,sp,32
    80002ecc:	8082                	ret

0000000080002ece <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002ece:	1101                	addi	sp,sp,-32
    80002ed0:	ec06                	sd	ra,24(sp)
    80002ed2:	e822                	sd	s0,16(sp)
    80002ed4:	e426                	sd	s1,8(sp)
    80002ed6:	1000                	addi	s0,sp,32
    80002ed8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002eda:	00000097          	auipc	ra,0x0
    80002ede:	ecc080e7          	jalr	-308(ra) # 80002da6 <argraw>
    80002ee2:	e088                	sd	a0,0(s1)
  return 0;
}
    80002ee4:	4501                	li	a0,0
    80002ee6:	60e2                	ld	ra,24(sp)
    80002ee8:	6442                	ld	s0,16(sp)
    80002eea:	64a2                	ld	s1,8(sp)
    80002eec:	6105                	addi	sp,sp,32
    80002eee:	8082                	ret

0000000080002ef0 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002ef0:	7179                	addi	sp,sp,-48
    80002ef2:	f406                	sd	ra,40(sp)
    80002ef4:	f022                	sd	s0,32(sp)
    80002ef6:	ec26                	sd	s1,24(sp)
    80002ef8:	e84a                	sd	s2,16(sp)
    80002efa:	1800                	addi	s0,sp,48
    80002efc:	84ae                	mv	s1,a1
    80002efe:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002f00:	fd840593          	addi	a1,s0,-40
    80002f04:	00000097          	auipc	ra,0x0
    80002f08:	fca080e7          	jalr	-54(ra) # 80002ece <argaddr>
  return fetchstr(addr, buf, max);
    80002f0c:	864a                	mv	a2,s2
    80002f0e:	85a6                	mv	a1,s1
    80002f10:	fd843503          	ld	a0,-40(s0)
    80002f14:	00000097          	auipc	ra,0x0
    80002f18:	f4c080e7          	jalr	-180(ra) # 80002e60 <fetchstr>
}
    80002f1c:	70a2                	ld	ra,40(sp)
    80002f1e:	7402                	ld	s0,32(sp)
    80002f20:	64e2                	ld	s1,24(sp)
    80002f22:	6942                	ld	s2,16(sp)
    80002f24:	6145                	addi	sp,sp,48
    80002f26:	8082                	ret

0000000080002f28 <syscall>:
    [SYS_setpriority] 1,
};

void
syscall(void)
{
    80002f28:	7179                	addi	sp,sp,-48
    80002f2a:	f406                	sd	ra,40(sp)
    80002f2c:	f022                	sd	s0,32(sp)
    80002f2e:	ec26                	sd	s1,24(sp)
    80002f30:	e84a                	sd	s2,16(sp)
    80002f32:	e44e                	sd	s3,8(sp)
    80002f34:	e052                	sd	s4,0(sp)
    80002f36:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002f38:	fffff097          	auipc	ra,0xfffff
    80002f3c:	a8e080e7          	jalr	-1394(ra) # 800019c6 <myproc>
    80002f40:	892a                	mv	s2,a0

  num = p->trapframe->a7;
    80002f42:	6d24                	ld	s1,88(a0)
    80002f44:	74dc                	ld	a5,168(s1)
    80002f46:	0007899b          	sext.w	s3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) 
    80002f4a:	37fd                	addiw	a5,a5,-1
    80002f4c:	4769                	li	a4,26
    80002f4e:	0af76163          	bltu	a4,a5,80002ff0 <syscall+0xc8>
    80002f52:	00399713          	slli	a4,s3,0x3
    80002f56:	00005797          	auipc	a5,0x5
    80002f5a:	63278793          	addi	a5,a5,1586 # 80008588 <syscalls>
    80002f5e:	97ba                	add	a5,a5,a4
    80002f60:	639c                	ld	a5,0(a5)
    80002f62:	c7d9                	beqz	a5,80002ff0 <syscall+0xc8>
  {
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002f64:	9782                	jalr	a5
    80002f66:	f8a8                	sd	a0,112(s1)
    if ((p->mask >> num) & 1)
    80002f68:	16892483          	lw	s1,360(s2)
    80002f6c:	4134d4bb          	sraw	s1,s1,s3
    80002f70:	8885                	andi	s1,s1,1
    80002f72:	c0c5                	beqz	s1,80003012 <syscall+0xea>
    {
      /* Modified for A4: Added entire section for trace, prints output for each syscall traced */
  	  printf("%d: syscall %s ( %d ",p->pid, syscallnames[num], p->trapframe->a0);
    80002f74:	05893703          	ld	a4,88(s2)
    80002f78:	00399693          	slli	a3,s3,0x3
    80002f7c:	00006797          	auipc	a5,0x6
    80002f80:	adc78793          	addi	a5,a5,-1316 # 80008a58 <syscallnames>
    80002f84:	97b6                	add	a5,a5,a3
    80002f86:	7b34                	ld	a3,112(a4)
    80002f88:	6390                	ld	a2,0(a5)
    80002f8a:	03092583          	lw	a1,48(s2)
    80002f8e:	00005517          	auipc	a0,0x5
    80002f92:	4a250513          	addi	a0,a0,1186 # 80008430 <states.1788+0x150>
    80002f96:	ffffd097          	auipc	ra,0xffffd
    80002f9a:	5f8080e7          	jalr	1528(ra) # 8000058e <printf>
      for (int i = 1; i < syscallnum[num]; i++) /* Modified for A4: 'num' tracks number of registers used by syscall and prints its register values  */
    80002f9e:	098a                	slli	s3,s3,0x2
    80002fa0:	00005797          	auipc	a5,0x5
    80002fa4:	5e878793          	addi	a5,a5,1512 # 80008588 <syscalls>
    80002fa8:	99be                	add	s3,s3,a5
    80002faa:	0e09a983          	lw	s3,224(s3)
    80002fae:	4785                	li	a5,1
    80002fb0:	0337d463          	bge	a5,s3,80002fd8 <syscall+0xb0>
        printf("%d ", argraw(i));
    80002fb4:	00005a17          	auipc	s4,0x5
    80002fb8:	494a0a13          	addi	s4,s4,1172 # 80008448 <states.1788+0x168>
    80002fbc:	8526                	mv	a0,s1
    80002fbe:	00000097          	auipc	ra,0x0
    80002fc2:	de8080e7          	jalr	-536(ra) # 80002da6 <argraw>
    80002fc6:	85aa                	mv	a1,a0
    80002fc8:	8552                	mv	a0,s4
    80002fca:	ffffd097          	auipc	ra,0xffffd
    80002fce:	5c4080e7          	jalr	1476(ra) # 8000058e <printf>
      for (int i = 1; i < syscallnum[num]; i++) /* Modified for A4: 'num' tracks number of registers used by syscall and prints its register values  */
    80002fd2:	2485                	addiw	s1,s1,1
    80002fd4:	ff3494e3          	bne	s1,s3,80002fbc <syscall+0x94>
      printf(") -> %d\n", p->trapframe->a0);
    80002fd8:	05893783          	ld	a5,88(s2)
    80002fdc:	7bac                	ld	a1,112(a5)
    80002fde:	00005517          	auipc	a0,0x5
    80002fe2:	47250513          	addi	a0,a0,1138 # 80008450 <states.1788+0x170>
    80002fe6:	ffffd097          	auipc	ra,0xffffd
    80002fea:	5a8080e7          	jalr	1448(ra) # 8000058e <printf>
    80002fee:	a015                	j	80003012 <syscall+0xea>
    }	
  } 
  else 
  {
    printf("%d %s: unknown sys call %d\n",
    80002ff0:	86ce                	mv	a3,s3
    80002ff2:	15890613          	addi	a2,s2,344
    80002ff6:	03092583          	lw	a1,48(s2)
    80002ffa:	00005517          	auipc	a0,0x5
    80002ffe:	46650513          	addi	a0,a0,1126 # 80008460 <states.1788+0x180>
    80003002:	ffffd097          	auipc	ra,0xffffd
    80003006:	58c080e7          	jalr	1420(ra) # 8000058e <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000300a:	05893783          	ld	a5,88(s2)
    8000300e:	577d                	li	a4,-1
    80003010:	fbb8                	sd	a4,112(a5)
  
  // if (p->mask >> num)
  // {
  // 	printf("%d: syscall %s -> %d\n",p->pid, syscallnames[num], p->trapframe->a0);
  // }	
}
    80003012:	70a2                	ld	ra,40(sp)
    80003014:	7402                	ld	s0,32(sp)
    80003016:	64e2                	ld	s1,24(sp)
    80003018:	6942                	ld	s2,16(sp)
    8000301a:	69a2                	ld	s3,8(sp)
    8000301c:	6a02                	ld	s4,0(sp)
    8000301e:	6145                	addi	sp,sp,48
    80003020:	8082                	ret

0000000080003022 <sys_trace>:
#include "proc.h"


uint64
sys_trace(void)
{
    80003022:	1101                	addi	sp,sp,-32
    80003024:	ec06                	sd	ra,24(sp)
    80003026:	e822                	sd	s0,16(sp)
    80003028:	1000                	addi	s0,sp,32
  int mask;
	if(argint(0, &mask) < 0)
    8000302a:	fec40593          	addi	a1,s0,-20
    8000302e:	4501                	li	a0,0
    80003030:	00000097          	auipc	ra,0x0
    80003034:	e7c080e7          	jalr	-388(ra) # 80002eac <argint>
	{
		return -1;
    80003038:	57fd                	li	a5,-1
	if(argint(0, &mask) < 0)
    8000303a:	00054b63          	bltz	a0,80003050 <sys_trace+0x2e>
	}
  myproc()->mask = mask;
    8000303e:	fffff097          	auipc	ra,0xfffff
    80003042:	988080e7          	jalr	-1656(ra) # 800019c6 <myproc>
    80003046:	fec42783          	lw	a5,-20(s0)
    8000304a:	16f52423          	sw	a5,360(a0)
	return 0;
    8000304e:	4781                	li	a5,0
}	/* Modified for A4: Added trace */
    80003050:	853e                	mv	a0,a5
    80003052:	60e2                	ld	ra,24(sp)
    80003054:	6442                	ld	s0,16(sp)
    80003056:	6105                	addi	sp,sp,32
    80003058:	8082                	ret

000000008000305a <sys_sigalarm>:

/* Modified for A4: Added trace */
uint64 
sys_sigalarm(void)
{
    8000305a:	1101                	addi	sp,sp,-32
    8000305c:	ec06                	sd	ra,24(sp)
    8000305e:	e822                	sd	s0,16(sp)
    80003060:	1000                	addi	s0,sp,32
  uint64 handleraddr;
  int ticks;
  if(argint(0, &ticks) < 0)
    80003062:	fe440593          	addi	a1,s0,-28
    80003066:	4501                	li	a0,0
    80003068:	00000097          	auipc	ra,0x0
    8000306c:	e44080e7          	jalr	-444(ra) # 80002eac <argint>
    return -1;
    80003070:	57fd                	li	a5,-1
  if(argint(0, &ticks) < 0)
    80003072:	04054463          	bltz	a0,800030ba <sys_sigalarm+0x60>
  if(argaddr(1, &handleraddr) < 0)
    80003076:	fe840593          	addi	a1,s0,-24
    8000307a:	4505                	li	a0,1
    8000307c:	00000097          	auipc	ra,0x0
    80003080:	e52080e7          	jalr	-430(ra) # 80002ece <argaddr>
    return -1;
    80003084:	57fd                	li	a5,-1
  if(argaddr(1, &handleraddr) < 0)
    80003086:	02054a63          	bltz	a0,800030ba <sys_sigalarm+0x60>

  myproc()->ticks = ticks;
    8000308a:	fffff097          	auipc	ra,0xfffff
    8000308e:	93c080e7          	jalr	-1732(ra) # 800019c6 <myproc>
    80003092:	fe442783          	lw	a5,-28(s0)
    80003096:	18f52423          	sw	a5,392(a0)
  myproc()->handler = handleraddr;
    8000309a:	fffff097          	auipc	ra,0xfffff
    8000309e:	92c080e7          	jalr	-1748(ra) # 800019c6 <myproc>
    800030a2:	fe843783          	ld	a5,-24(s0)
    800030a6:	18f53023          	sd	a5,384(a0)
  myproc()->alarm_on = 1;
    800030aa:	fffff097          	auipc	ra,0xfffff
    800030ae:	91c080e7          	jalr	-1764(ra) # 800019c6 <myproc>
    800030b2:	4785                	li	a5,1
    800030b4:	18f52c23          	sw	a5,408(a0)
  //myproc()->a1 = myproc()->trapframe->a0;
  //myproc()->a2 = myproc()->trapframe->a1;

  return 0;
    800030b8:	4781                	li	a5,0
}
    800030ba:	853e                	mv	a0,a5
    800030bc:	60e2                	ld	ra,24(sp)
    800030be:	6442                	ld	s0,16(sp)
    800030c0:	6105                	addi	sp,sp,32
    800030c2:	8082                	ret

00000000800030c4 <sys_sigreturn>:

/* Modified for A4: Added trace */
uint64 
sys_sigreturn(void)
{
    800030c4:	1101                	addi	sp,sp,-32
    800030c6:	ec06                	sd	ra,24(sp)
    800030c8:	e822                	sd	s0,16(sp)
    800030ca:	e426                	sd	s1,8(sp)
    800030cc:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800030ce:	fffff097          	auipc	ra,0xfffff
    800030d2:	8f8080e7          	jalr	-1800(ra) # 800019c6 <myproc>
    800030d6:	84aa                	mv	s1,a0
  memmove(p->trapframe, p->alarm_tf, PGSIZE);
    800030d8:	6605                	lui	a2,0x1
    800030da:	19053583          	ld	a1,400(a0)
    800030de:	6d28                	ld	a0,88(a0)
    800030e0:	ffffe097          	auipc	ra,0xffffe
    800030e4:	c66080e7          	jalr	-922(ra) # 80000d46 <memmove>
  //myproc()->trapframe->a0 = myproc()->a1;
  //myproc()->trapframe->a1 = myproc()->a2;
  kfree(p->alarm_tf);
    800030e8:	1904b503          	ld	a0,400(s1)
    800030ec:	ffffe097          	auipc	ra,0xffffe
    800030f0:	912080e7          	jalr	-1774(ra) # 800009fe <kfree>
  p->handlerpermission = 1;
    800030f4:	4785                	li	a5,1
    800030f6:	18f4ae23          	sw	a5,412(s1)
  return myproc()->trapframe->a0;
    800030fa:	fffff097          	auipc	ra,0xfffff
    800030fe:	8cc080e7          	jalr	-1844(ra) # 800019c6 <myproc>
    80003102:	6d3c                	ld	a5,88(a0)
}
    80003104:	7ba8                	ld	a0,112(a5)
    80003106:	60e2                	ld	ra,24(sp)
    80003108:	6442                	ld	s0,16(sp)
    8000310a:	64a2                	ld	s1,8(sp)
    8000310c:	6105                	addi	sp,sp,32
    8000310e:	8082                	ret

0000000080003110 <sys_settickets>:

uint64 
sys_settickets(void)
{
    80003110:	7179                	addi	sp,sp,-48
    80003112:	f406                	sd	ra,40(sp)
    80003114:	f022                	sd	s0,32(sp)
    80003116:	ec26                	sd	s1,24(sp)
    80003118:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000311a:	fffff097          	auipc	ra,0xfffff
    8000311e:	8ac080e7          	jalr	-1876(ra) # 800019c6 <myproc>
    80003122:	84aa                	mv	s1,a0
  int tickets;
  if(argint(0, &tickets) < 0)
    80003124:	fdc40593          	addi	a1,s0,-36
    80003128:	4501                	li	a0,0
    8000312a:	00000097          	auipc	ra,0x0
    8000312e:	d82080e7          	jalr	-638(ra) # 80002eac <argint>
    80003132:	00054c63          	bltz	a0,8000314a <sys_settickets+0x3a>
    return -1;
  p->tickets = tickets;
    80003136:	fdc42783          	lw	a5,-36(s0)
    8000313a:	1af4a023          	sw	a5,416(s1)
  return 0; 
    8000313e:	4501                	li	a0,0
}
    80003140:	70a2                	ld	ra,40(sp)
    80003142:	7402                	ld	s0,32(sp)
    80003144:	64e2                	ld	s1,24(sp)
    80003146:	6145                	addi	sp,sp,48
    80003148:	8082                	ret
    return -1;
    8000314a:	557d                	li	a0,-1
    8000314c:	bfd5                	j	80003140 <sys_settickets+0x30>

000000008000314e <sys_setpriority>:

uint64
sys_setpriority()
{
    8000314e:	1101                	addi	sp,sp,-32
    80003150:	ec06                	sd	ra,24(sp)
    80003152:	e822                	sd	s0,16(sp)
    80003154:	1000                	addi	s0,sp,32
  int pid, priority;
  int arg_num[2] = {0, 1};

  if(argint(arg_num[0], &priority) < 0)
    80003156:	fe840593          	addi	a1,s0,-24
    8000315a:	4501                	li	a0,0
    8000315c:	00000097          	auipc	ra,0x0
    80003160:	d50080e7          	jalr	-688(ra) # 80002eac <argint>
  {
    return -1;
    80003164:	57fd                	li	a5,-1
  if(argint(arg_num[0], &priority) < 0)
    80003166:	02054563          	bltz	a0,80003190 <sys_setpriority+0x42>
  }
  if(argint(arg_num[1], &pid) < 0)
    8000316a:	fec40593          	addi	a1,s0,-20
    8000316e:	4505                	li	a0,1
    80003170:	00000097          	auipc	ra,0x0
    80003174:	d3c080e7          	jalr	-708(ra) # 80002eac <argint>
  {
    return -1;
    80003178:	57fd                	li	a5,-1
  if(argint(arg_num[1], &pid) < 0)
    8000317a:	00054b63          	bltz	a0,80003190 <sys_setpriority+0x42>
  }
   
  return setpriority(priority, pid);
    8000317e:	fec42583          	lw	a1,-20(s0)
    80003182:	fe842503          	lw	a0,-24(s0)
    80003186:	fffff097          	auipc	ra,0xfffff
    8000318a:	774080e7          	jalr	1908(ra) # 800028fa <setpriority>
    8000318e:	87aa                	mv	a5,a0
}
    80003190:	853e                	mv	a0,a5
    80003192:	60e2                	ld	ra,24(sp)
    80003194:	6442                	ld	s0,16(sp)
    80003196:	6105                	addi	sp,sp,32
    80003198:	8082                	ret

000000008000319a <sys_exit>:


uint64
sys_exit(void)
{
    8000319a:	1101                	addi	sp,sp,-32
    8000319c:	ec06                	sd	ra,24(sp)
    8000319e:	e822                	sd	s0,16(sp)
    800031a0:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800031a2:	fec40593          	addi	a1,s0,-20
    800031a6:	4501                	li	a0,0
    800031a8:	00000097          	auipc	ra,0x0
    800031ac:	d04080e7          	jalr	-764(ra) # 80002eac <argint>
  exit(n);
    800031b0:	fec42503          	lw	a0,-20(s0)
    800031b4:	fffff097          	auipc	ra,0xfffff
    800031b8:	2d4080e7          	jalr	724(ra) # 80002488 <exit>
  return 0;  // not reached
}
    800031bc:	4501                	li	a0,0
    800031be:	60e2                	ld	ra,24(sp)
    800031c0:	6442                	ld	s0,16(sp)
    800031c2:	6105                	addi	sp,sp,32
    800031c4:	8082                	ret

00000000800031c6 <sys_getpid>:

uint64
sys_getpid(void)
{
    800031c6:	1141                	addi	sp,sp,-16
    800031c8:	e406                	sd	ra,8(sp)
    800031ca:	e022                	sd	s0,0(sp)
    800031cc:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800031ce:	ffffe097          	auipc	ra,0xffffe
    800031d2:	7f8080e7          	jalr	2040(ra) # 800019c6 <myproc>
}
    800031d6:	5908                	lw	a0,48(a0)
    800031d8:	60a2                	ld	ra,8(sp)
    800031da:	6402                	ld	s0,0(sp)
    800031dc:	0141                	addi	sp,sp,16
    800031de:	8082                	ret

00000000800031e0 <sys_fork>:

uint64
sys_fork(void)
{
    800031e0:	1141                	addi	sp,sp,-16
    800031e2:	e406                	sd	ra,8(sp)
    800031e4:	e022                	sd	s0,0(sp)
    800031e6:	0800                	addi	s0,sp,16
  return fork();
    800031e8:	fffff097          	auipc	ra,0xfffff
    800031ec:	c0a080e7          	jalr	-1014(ra) # 80001df2 <fork>
}
    800031f0:	60a2                	ld	ra,8(sp)
    800031f2:	6402                	ld	s0,0(sp)
    800031f4:	0141                	addi	sp,sp,16
    800031f6:	8082                	ret

00000000800031f8 <sys_wait>:

uint64
sys_wait(void)
{
    800031f8:	1101                	addi	sp,sp,-32
    800031fa:	ec06                	sd	ra,24(sp)
    800031fc:	e822                	sd	s0,16(sp)
    800031fe:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80003200:	fe840593          	addi	a1,s0,-24
    80003204:	4501                	li	a0,0
    80003206:	00000097          	auipc	ra,0x0
    8000320a:	cc8080e7          	jalr	-824(ra) # 80002ece <argaddr>
  return wait(p);
    8000320e:	fe843503          	ld	a0,-24(s0)
    80003212:	fffff097          	auipc	ra,0xfffff
    80003216:	428080e7          	jalr	1064(ra) # 8000263a <wait>
}
    8000321a:	60e2                	ld	ra,24(sp)
    8000321c:	6442                	ld	s0,16(sp)
    8000321e:	6105                	addi	sp,sp,32
    80003220:	8082                	ret

0000000080003222 <sys_waitx>:

uint64
sys_waitx(void)
{
    80003222:	7139                	addi	sp,sp,-64
    80003224:	fc06                	sd	ra,56(sp)
    80003226:	f822                	sd	s0,48(sp)
    80003228:	f426                	sd	s1,40(sp)
    8000322a:	f04a                	sd	s2,32(sp)
    8000322c:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    8000322e:	fd840593          	addi	a1,s0,-40
    80003232:	4501                	li	a0,0
    80003234:	00000097          	auipc	ra,0x0
    80003238:	c9a080e7          	jalr	-870(ra) # 80002ece <argaddr>
  argaddr(1, &addr1); // user virtual memory
    8000323c:	fd040593          	addi	a1,s0,-48
    80003240:	4505                	li	a0,1
    80003242:	00000097          	auipc	ra,0x0
    80003246:	c8c080e7          	jalr	-884(ra) # 80002ece <argaddr>
  argaddr(2, &addr2);
    8000324a:	fc840593          	addi	a1,s0,-56
    8000324e:	4509                	li	a0,2
    80003250:	00000097          	auipc	ra,0x0
    80003254:	c7e080e7          	jalr	-898(ra) # 80002ece <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    80003258:	fc040613          	addi	a2,s0,-64
    8000325c:	fc440593          	addi	a1,s0,-60
    80003260:	fd843503          	ld	a0,-40(s0)
    80003264:	fffff097          	auipc	ra,0xfffff
    80003268:	008080e7          	jalr	8(ra) # 8000226c <waitx>
    8000326c:	892a                	mv	s2,a0
  struct proc* p = myproc();
    8000326e:	ffffe097          	auipc	ra,0xffffe
    80003272:	758080e7          	jalr	1880(ra) # 800019c6 <myproc>
    80003276:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    80003278:	4691                	li	a3,4
    8000327a:	fc440613          	addi	a2,s0,-60
    8000327e:	fd043583          	ld	a1,-48(s0)
    80003282:	6928                	ld	a0,80(a0)
    80003284:	ffffe097          	auipc	ra,0xffffe
    80003288:	400080e7          	jalr	1024(ra) # 80001684 <copyout>
    return -1;
    8000328c:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    8000328e:	00054f63          	bltz	a0,800032ac <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2,(char*)&rtime, sizeof(int)) < 0)
    80003292:	4691                	li	a3,4
    80003294:	fc040613          	addi	a2,s0,-64
    80003298:	fc843583          	ld	a1,-56(s0)
    8000329c:	68a8                	ld	a0,80(s1)
    8000329e:	ffffe097          	auipc	ra,0xffffe
    800032a2:	3e6080e7          	jalr	998(ra) # 80001684 <copyout>
    800032a6:	00054a63          	bltz	a0,800032ba <sys_waitx+0x98>
    return -1;
  return ret;
    800032aa:	87ca                	mv	a5,s2
}
    800032ac:	853e                	mv	a0,a5
    800032ae:	70e2                	ld	ra,56(sp)
    800032b0:	7442                	ld	s0,48(sp)
    800032b2:	74a2                	ld	s1,40(sp)
    800032b4:	7902                	ld	s2,32(sp)
    800032b6:	6121                	addi	sp,sp,64
    800032b8:	8082                	ret
    return -1;
    800032ba:	57fd                	li	a5,-1
    800032bc:	bfc5                	j	800032ac <sys_waitx+0x8a>

00000000800032be <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800032be:	7179                	addi	sp,sp,-48
    800032c0:	f406                	sd	ra,40(sp)
    800032c2:	f022                	sd	s0,32(sp)
    800032c4:	ec26                	sd	s1,24(sp)
    800032c6:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    800032c8:	fdc40593          	addi	a1,s0,-36
    800032cc:	4501                	li	a0,0
    800032ce:	00000097          	auipc	ra,0x0
    800032d2:	bde080e7          	jalr	-1058(ra) # 80002eac <argint>
  addr = myproc()->sz;
    800032d6:	ffffe097          	auipc	ra,0xffffe
    800032da:	6f0080e7          	jalr	1776(ra) # 800019c6 <myproc>
    800032de:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    800032e0:	fdc42503          	lw	a0,-36(s0)
    800032e4:	fffff097          	auipc	ra,0xfffff
    800032e8:	ab2080e7          	jalr	-1358(ra) # 80001d96 <growproc>
    800032ec:	00054863          	bltz	a0,800032fc <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    800032f0:	8526                	mv	a0,s1
    800032f2:	70a2                	ld	ra,40(sp)
    800032f4:	7402                	ld	s0,32(sp)
    800032f6:	64e2                	ld	s1,24(sp)
    800032f8:	6145                	addi	sp,sp,48
    800032fa:	8082                	ret
    return -1;
    800032fc:	54fd                	li	s1,-1
    800032fe:	bfcd                	j	800032f0 <sys_sbrk+0x32>

0000000080003300 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003300:	7139                	addi	sp,sp,-64
    80003302:	fc06                	sd	ra,56(sp)
    80003304:	f822                	sd	s0,48(sp)
    80003306:	f426                	sd	s1,40(sp)
    80003308:	f04a                	sd	s2,32(sp)
    8000330a:	ec4e                	sd	s3,24(sp)
    8000330c:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    8000330e:	fcc40593          	addi	a1,s0,-52
    80003312:	4501                	li	a0,0
    80003314:	00000097          	auipc	ra,0x0
    80003318:	b98080e7          	jalr	-1128(ra) # 80002eac <argint>
  acquire(&tickslock);
    8000331c:	00015517          	auipc	a0,0x15
    80003320:	72450513          	addi	a0,a0,1828 # 80018a40 <tickslock>
    80003324:	ffffe097          	auipc	ra,0xffffe
    80003328:	8c6080e7          	jalr	-1850(ra) # 80000bea <acquire>
  ticks0 = ticks;
    8000332c:	00006917          	auipc	s2,0x6
    80003330:	84492903          	lw	s2,-1980(s2) # 80008b70 <ticks>
  while(ticks - ticks0 < n){
    80003334:	fcc42783          	lw	a5,-52(s0)
    80003338:	cf9d                	beqz	a5,80003376 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000333a:	00015997          	auipc	s3,0x15
    8000333e:	70698993          	addi	s3,s3,1798 # 80018a40 <tickslock>
    80003342:	00006497          	auipc	s1,0x6
    80003346:	82e48493          	addi	s1,s1,-2002 # 80008b70 <ticks>
    if(killed(myproc())){
    8000334a:	ffffe097          	auipc	ra,0xffffe
    8000334e:	67c080e7          	jalr	1660(ra) # 800019c6 <myproc>
    80003352:	fffff097          	auipc	ra,0xfffff
    80003356:	2b6080e7          	jalr	694(ra) # 80002608 <killed>
    8000335a:	ed15                	bnez	a0,80003396 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    8000335c:	85ce                	mv	a1,s3
    8000335e:	8526                	mv	a0,s1
    80003360:	fffff097          	auipc	ra,0xfffff
    80003364:	ea8080e7          	jalr	-344(ra) # 80002208 <sleep>
  while(ticks - ticks0 < n){
    80003368:	409c                	lw	a5,0(s1)
    8000336a:	412787bb          	subw	a5,a5,s2
    8000336e:	fcc42703          	lw	a4,-52(s0)
    80003372:	fce7ece3          	bltu	a5,a4,8000334a <sys_sleep+0x4a>
  }
  release(&tickslock);
    80003376:	00015517          	auipc	a0,0x15
    8000337a:	6ca50513          	addi	a0,a0,1738 # 80018a40 <tickslock>
    8000337e:	ffffe097          	auipc	ra,0xffffe
    80003382:	920080e7          	jalr	-1760(ra) # 80000c9e <release>
  return 0;
    80003386:	4501                	li	a0,0
}
    80003388:	70e2                	ld	ra,56(sp)
    8000338a:	7442                	ld	s0,48(sp)
    8000338c:	74a2                	ld	s1,40(sp)
    8000338e:	7902                	ld	s2,32(sp)
    80003390:	69e2                	ld	s3,24(sp)
    80003392:	6121                	addi	sp,sp,64
    80003394:	8082                	ret
      release(&tickslock);
    80003396:	00015517          	auipc	a0,0x15
    8000339a:	6aa50513          	addi	a0,a0,1706 # 80018a40 <tickslock>
    8000339e:	ffffe097          	auipc	ra,0xffffe
    800033a2:	900080e7          	jalr	-1792(ra) # 80000c9e <release>
      return -1;
    800033a6:	557d                	li	a0,-1
    800033a8:	b7c5                	j	80003388 <sys_sleep+0x88>

00000000800033aa <sys_kill>:

uint64
sys_kill(void)
{
    800033aa:	1101                	addi	sp,sp,-32
    800033ac:	ec06                	sd	ra,24(sp)
    800033ae:	e822                	sd	s0,16(sp)
    800033b0:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800033b2:	fec40593          	addi	a1,s0,-20
    800033b6:	4501                	li	a0,0
    800033b8:	00000097          	auipc	ra,0x0
    800033bc:	af4080e7          	jalr	-1292(ra) # 80002eac <argint>
  return kill(pid);
    800033c0:	fec42503          	lw	a0,-20(s0)
    800033c4:	fffff097          	auipc	ra,0xfffff
    800033c8:	1a6080e7          	jalr	422(ra) # 8000256a <kill>
}
    800033cc:	60e2                	ld	ra,24(sp)
    800033ce:	6442                	ld	s0,16(sp)
    800033d0:	6105                	addi	sp,sp,32
    800033d2:	8082                	ret

00000000800033d4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800033d4:	1101                	addi	sp,sp,-32
    800033d6:	ec06                	sd	ra,24(sp)
    800033d8:	e822                	sd	s0,16(sp)
    800033da:	e426                	sd	s1,8(sp)
    800033dc:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800033de:	00015517          	auipc	a0,0x15
    800033e2:	66250513          	addi	a0,a0,1634 # 80018a40 <tickslock>
    800033e6:	ffffe097          	auipc	ra,0xffffe
    800033ea:	804080e7          	jalr	-2044(ra) # 80000bea <acquire>
  xticks = ticks;
    800033ee:	00005497          	auipc	s1,0x5
    800033f2:	7824a483          	lw	s1,1922(s1) # 80008b70 <ticks>
  release(&tickslock);
    800033f6:	00015517          	auipc	a0,0x15
    800033fa:	64a50513          	addi	a0,a0,1610 # 80018a40 <tickslock>
    800033fe:	ffffe097          	auipc	ra,0xffffe
    80003402:	8a0080e7          	jalr	-1888(ra) # 80000c9e <release>
  return xticks;
}
    80003406:	02049513          	slli	a0,s1,0x20
    8000340a:	9101                	srli	a0,a0,0x20
    8000340c:	60e2                	ld	ra,24(sp)
    8000340e:	6442                	ld	s0,16(sp)
    80003410:	64a2                	ld	s1,8(sp)
    80003412:	6105                	addi	sp,sp,32
    80003414:	8082                	ret

0000000080003416 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003416:	7179                	addi	sp,sp,-48
    80003418:	f406                	sd	ra,40(sp)
    8000341a:	f022                	sd	s0,32(sp)
    8000341c:	ec26                	sd	s1,24(sp)
    8000341e:	e84a                	sd	s2,16(sp)
    80003420:	e44e                	sd	s3,8(sp)
    80003422:	e052                	sd	s4,0(sp)
    80003424:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003426:	00005597          	auipc	a1,0x5
    8000342a:	2b258593          	addi	a1,a1,690 # 800086d8 <syscallnum+0x70>
    8000342e:	00015517          	auipc	a0,0x15
    80003432:	62a50513          	addi	a0,a0,1578 # 80018a58 <bcache>
    80003436:	ffffd097          	auipc	ra,0xffffd
    8000343a:	724080e7          	jalr	1828(ra) # 80000b5a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000343e:	0001d797          	auipc	a5,0x1d
    80003442:	61a78793          	addi	a5,a5,1562 # 80020a58 <bcache+0x8000>
    80003446:	0001e717          	auipc	a4,0x1e
    8000344a:	87a70713          	addi	a4,a4,-1926 # 80020cc0 <bcache+0x8268>
    8000344e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003452:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003456:	00015497          	auipc	s1,0x15
    8000345a:	61a48493          	addi	s1,s1,1562 # 80018a70 <bcache+0x18>
    b->next = bcache.head.next;
    8000345e:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003460:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003462:	00005a17          	auipc	s4,0x5
    80003466:	27ea0a13          	addi	s4,s4,638 # 800086e0 <syscallnum+0x78>
    b->next = bcache.head.next;
    8000346a:	2b893783          	ld	a5,696(s2)
    8000346e:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003470:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003474:	85d2                	mv	a1,s4
    80003476:	01048513          	addi	a0,s1,16
    8000347a:	00001097          	auipc	ra,0x1
    8000347e:	4c4080e7          	jalr	1220(ra) # 8000493e <initsleeplock>
    bcache.head.next->prev = b;
    80003482:	2b893783          	ld	a5,696(s2)
    80003486:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003488:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000348c:	45848493          	addi	s1,s1,1112
    80003490:	fd349de3          	bne	s1,s3,8000346a <binit+0x54>
  }
}
    80003494:	70a2                	ld	ra,40(sp)
    80003496:	7402                	ld	s0,32(sp)
    80003498:	64e2                	ld	s1,24(sp)
    8000349a:	6942                	ld	s2,16(sp)
    8000349c:	69a2                	ld	s3,8(sp)
    8000349e:	6a02                	ld	s4,0(sp)
    800034a0:	6145                	addi	sp,sp,48
    800034a2:	8082                	ret

00000000800034a4 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800034a4:	7179                	addi	sp,sp,-48
    800034a6:	f406                	sd	ra,40(sp)
    800034a8:	f022                	sd	s0,32(sp)
    800034aa:	ec26                	sd	s1,24(sp)
    800034ac:	e84a                	sd	s2,16(sp)
    800034ae:	e44e                	sd	s3,8(sp)
    800034b0:	1800                	addi	s0,sp,48
    800034b2:	89aa                	mv	s3,a0
    800034b4:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    800034b6:	00015517          	auipc	a0,0x15
    800034ba:	5a250513          	addi	a0,a0,1442 # 80018a58 <bcache>
    800034be:	ffffd097          	auipc	ra,0xffffd
    800034c2:	72c080e7          	jalr	1836(ra) # 80000bea <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800034c6:	0001e497          	auipc	s1,0x1e
    800034ca:	84a4b483          	ld	s1,-1974(s1) # 80020d10 <bcache+0x82b8>
    800034ce:	0001d797          	auipc	a5,0x1d
    800034d2:	7f278793          	addi	a5,a5,2034 # 80020cc0 <bcache+0x8268>
    800034d6:	02f48f63          	beq	s1,a5,80003514 <bread+0x70>
    800034da:	873e                	mv	a4,a5
    800034dc:	a021                	j	800034e4 <bread+0x40>
    800034de:	68a4                	ld	s1,80(s1)
    800034e0:	02e48a63          	beq	s1,a4,80003514 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800034e4:	449c                	lw	a5,8(s1)
    800034e6:	ff379ce3          	bne	a5,s3,800034de <bread+0x3a>
    800034ea:	44dc                	lw	a5,12(s1)
    800034ec:	ff2799e3          	bne	a5,s2,800034de <bread+0x3a>
      b->refcnt++;
    800034f0:	40bc                	lw	a5,64(s1)
    800034f2:	2785                	addiw	a5,a5,1
    800034f4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800034f6:	00015517          	auipc	a0,0x15
    800034fa:	56250513          	addi	a0,a0,1378 # 80018a58 <bcache>
    800034fe:	ffffd097          	auipc	ra,0xffffd
    80003502:	7a0080e7          	jalr	1952(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    80003506:	01048513          	addi	a0,s1,16
    8000350a:	00001097          	auipc	ra,0x1
    8000350e:	46e080e7          	jalr	1134(ra) # 80004978 <acquiresleep>
      return b;
    80003512:	a8b9                	j	80003570 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003514:	0001d497          	auipc	s1,0x1d
    80003518:	7f44b483          	ld	s1,2036(s1) # 80020d08 <bcache+0x82b0>
    8000351c:	0001d797          	auipc	a5,0x1d
    80003520:	7a478793          	addi	a5,a5,1956 # 80020cc0 <bcache+0x8268>
    80003524:	00f48863          	beq	s1,a5,80003534 <bread+0x90>
    80003528:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000352a:	40bc                	lw	a5,64(s1)
    8000352c:	cf81                	beqz	a5,80003544 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000352e:	64a4                	ld	s1,72(s1)
    80003530:	fee49de3          	bne	s1,a4,8000352a <bread+0x86>
  panic("bget: no buffers");
    80003534:	00005517          	auipc	a0,0x5
    80003538:	1b450513          	addi	a0,a0,436 # 800086e8 <syscallnum+0x80>
    8000353c:	ffffd097          	auipc	ra,0xffffd
    80003540:	008080e7          	jalr	8(ra) # 80000544 <panic>
      b->dev = dev;
    80003544:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80003548:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    8000354c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003550:	4785                	li	a5,1
    80003552:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003554:	00015517          	auipc	a0,0x15
    80003558:	50450513          	addi	a0,a0,1284 # 80018a58 <bcache>
    8000355c:	ffffd097          	auipc	ra,0xffffd
    80003560:	742080e7          	jalr	1858(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    80003564:	01048513          	addi	a0,s1,16
    80003568:	00001097          	auipc	ra,0x1
    8000356c:	410080e7          	jalr	1040(ra) # 80004978 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003570:	409c                	lw	a5,0(s1)
    80003572:	cb89                	beqz	a5,80003584 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003574:	8526                	mv	a0,s1
    80003576:	70a2                	ld	ra,40(sp)
    80003578:	7402                	ld	s0,32(sp)
    8000357a:	64e2                	ld	s1,24(sp)
    8000357c:	6942                	ld	s2,16(sp)
    8000357e:	69a2                	ld	s3,8(sp)
    80003580:	6145                	addi	sp,sp,48
    80003582:	8082                	ret
    virtio_disk_rw(b, 0);
    80003584:	4581                	li	a1,0
    80003586:	8526                	mv	a0,s1
    80003588:	00003097          	auipc	ra,0x3
    8000358c:	fd0080e7          	jalr	-48(ra) # 80006558 <virtio_disk_rw>
    b->valid = 1;
    80003590:	4785                	li	a5,1
    80003592:	c09c                	sw	a5,0(s1)
  return b;
    80003594:	b7c5                	j	80003574 <bread+0xd0>

0000000080003596 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003596:	1101                	addi	sp,sp,-32
    80003598:	ec06                	sd	ra,24(sp)
    8000359a:	e822                	sd	s0,16(sp)
    8000359c:	e426                	sd	s1,8(sp)
    8000359e:	1000                	addi	s0,sp,32
    800035a0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800035a2:	0541                	addi	a0,a0,16
    800035a4:	00001097          	auipc	ra,0x1
    800035a8:	46e080e7          	jalr	1134(ra) # 80004a12 <holdingsleep>
    800035ac:	cd01                	beqz	a0,800035c4 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800035ae:	4585                	li	a1,1
    800035b0:	8526                	mv	a0,s1
    800035b2:	00003097          	auipc	ra,0x3
    800035b6:	fa6080e7          	jalr	-90(ra) # 80006558 <virtio_disk_rw>
}
    800035ba:	60e2                	ld	ra,24(sp)
    800035bc:	6442                	ld	s0,16(sp)
    800035be:	64a2                	ld	s1,8(sp)
    800035c0:	6105                	addi	sp,sp,32
    800035c2:	8082                	ret
    panic("bwrite");
    800035c4:	00005517          	auipc	a0,0x5
    800035c8:	13c50513          	addi	a0,a0,316 # 80008700 <syscallnum+0x98>
    800035cc:	ffffd097          	auipc	ra,0xffffd
    800035d0:	f78080e7          	jalr	-136(ra) # 80000544 <panic>

00000000800035d4 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800035d4:	1101                	addi	sp,sp,-32
    800035d6:	ec06                	sd	ra,24(sp)
    800035d8:	e822                	sd	s0,16(sp)
    800035da:	e426                	sd	s1,8(sp)
    800035dc:	e04a                	sd	s2,0(sp)
    800035de:	1000                	addi	s0,sp,32
    800035e0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800035e2:	01050913          	addi	s2,a0,16
    800035e6:	854a                	mv	a0,s2
    800035e8:	00001097          	auipc	ra,0x1
    800035ec:	42a080e7          	jalr	1066(ra) # 80004a12 <holdingsleep>
    800035f0:	c92d                	beqz	a0,80003662 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800035f2:	854a                	mv	a0,s2
    800035f4:	00001097          	auipc	ra,0x1
    800035f8:	3da080e7          	jalr	986(ra) # 800049ce <releasesleep>

  acquire(&bcache.lock);
    800035fc:	00015517          	auipc	a0,0x15
    80003600:	45c50513          	addi	a0,a0,1116 # 80018a58 <bcache>
    80003604:	ffffd097          	auipc	ra,0xffffd
    80003608:	5e6080e7          	jalr	1510(ra) # 80000bea <acquire>
  b->refcnt--;
    8000360c:	40bc                	lw	a5,64(s1)
    8000360e:	37fd                	addiw	a5,a5,-1
    80003610:	0007871b          	sext.w	a4,a5
    80003614:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003616:	eb05                	bnez	a4,80003646 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003618:	68bc                	ld	a5,80(s1)
    8000361a:	64b8                	ld	a4,72(s1)
    8000361c:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000361e:	64bc                	ld	a5,72(s1)
    80003620:	68b8                	ld	a4,80(s1)
    80003622:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003624:	0001d797          	auipc	a5,0x1d
    80003628:	43478793          	addi	a5,a5,1076 # 80020a58 <bcache+0x8000>
    8000362c:	2b87b703          	ld	a4,696(a5)
    80003630:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003632:	0001d717          	auipc	a4,0x1d
    80003636:	68e70713          	addi	a4,a4,1678 # 80020cc0 <bcache+0x8268>
    8000363a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000363c:	2b87b703          	ld	a4,696(a5)
    80003640:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003642:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003646:	00015517          	auipc	a0,0x15
    8000364a:	41250513          	addi	a0,a0,1042 # 80018a58 <bcache>
    8000364e:	ffffd097          	auipc	ra,0xffffd
    80003652:	650080e7          	jalr	1616(ra) # 80000c9e <release>
}
    80003656:	60e2                	ld	ra,24(sp)
    80003658:	6442                	ld	s0,16(sp)
    8000365a:	64a2                	ld	s1,8(sp)
    8000365c:	6902                	ld	s2,0(sp)
    8000365e:	6105                	addi	sp,sp,32
    80003660:	8082                	ret
    panic("brelse");
    80003662:	00005517          	auipc	a0,0x5
    80003666:	0a650513          	addi	a0,a0,166 # 80008708 <syscallnum+0xa0>
    8000366a:	ffffd097          	auipc	ra,0xffffd
    8000366e:	eda080e7          	jalr	-294(ra) # 80000544 <panic>

0000000080003672 <bpin>:

void
bpin(struct buf *b) {
    80003672:	1101                	addi	sp,sp,-32
    80003674:	ec06                	sd	ra,24(sp)
    80003676:	e822                	sd	s0,16(sp)
    80003678:	e426                	sd	s1,8(sp)
    8000367a:	1000                	addi	s0,sp,32
    8000367c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000367e:	00015517          	auipc	a0,0x15
    80003682:	3da50513          	addi	a0,a0,986 # 80018a58 <bcache>
    80003686:	ffffd097          	auipc	ra,0xffffd
    8000368a:	564080e7          	jalr	1380(ra) # 80000bea <acquire>
  b->refcnt++;
    8000368e:	40bc                	lw	a5,64(s1)
    80003690:	2785                	addiw	a5,a5,1
    80003692:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003694:	00015517          	auipc	a0,0x15
    80003698:	3c450513          	addi	a0,a0,964 # 80018a58 <bcache>
    8000369c:	ffffd097          	auipc	ra,0xffffd
    800036a0:	602080e7          	jalr	1538(ra) # 80000c9e <release>
}
    800036a4:	60e2                	ld	ra,24(sp)
    800036a6:	6442                	ld	s0,16(sp)
    800036a8:	64a2                	ld	s1,8(sp)
    800036aa:	6105                	addi	sp,sp,32
    800036ac:	8082                	ret

00000000800036ae <bunpin>:

void
bunpin(struct buf *b) {
    800036ae:	1101                	addi	sp,sp,-32
    800036b0:	ec06                	sd	ra,24(sp)
    800036b2:	e822                	sd	s0,16(sp)
    800036b4:	e426                	sd	s1,8(sp)
    800036b6:	1000                	addi	s0,sp,32
    800036b8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800036ba:	00015517          	auipc	a0,0x15
    800036be:	39e50513          	addi	a0,a0,926 # 80018a58 <bcache>
    800036c2:	ffffd097          	auipc	ra,0xffffd
    800036c6:	528080e7          	jalr	1320(ra) # 80000bea <acquire>
  b->refcnt--;
    800036ca:	40bc                	lw	a5,64(s1)
    800036cc:	37fd                	addiw	a5,a5,-1
    800036ce:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800036d0:	00015517          	auipc	a0,0x15
    800036d4:	38850513          	addi	a0,a0,904 # 80018a58 <bcache>
    800036d8:	ffffd097          	auipc	ra,0xffffd
    800036dc:	5c6080e7          	jalr	1478(ra) # 80000c9e <release>
}
    800036e0:	60e2                	ld	ra,24(sp)
    800036e2:	6442                	ld	s0,16(sp)
    800036e4:	64a2                	ld	s1,8(sp)
    800036e6:	6105                	addi	sp,sp,32
    800036e8:	8082                	ret

00000000800036ea <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800036ea:	1101                	addi	sp,sp,-32
    800036ec:	ec06                	sd	ra,24(sp)
    800036ee:	e822                	sd	s0,16(sp)
    800036f0:	e426                	sd	s1,8(sp)
    800036f2:	e04a                	sd	s2,0(sp)
    800036f4:	1000                	addi	s0,sp,32
    800036f6:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800036f8:	00d5d59b          	srliw	a1,a1,0xd
    800036fc:	0001e797          	auipc	a5,0x1e
    80003700:	a387a783          	lw	a5,-1480(a5) # 80021134 <sb+0x1c>
    80003704:	9dbd                	addw	a1,a1,a5
    80003706:	00000097          	auipc	ra,0x0
    8000370a:	d9e080e7          	jalr	-610(ra) # 800034a4 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000370e:	0074f713          	andi	a4,s1,7
    80003712:	4785                	li	a5,1
    80003714:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003718:	14ce                	slli	s1,s1,0x33
    8000371a:	90d9                	srli	s1,s1,0x36
    8000371c:	00950733          	add	a4,a0,s1
    80003720:	05874703          	lbu	a4,88(a4)
    80003724:	00e7f6b3          	and	a3,a5,a4
    80003728:	c69d                	beqz	a3,80003756 <bfree+0x6c>
    8000372a:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000372c:	94aa                	add	s1,s1,a0
    8000372e:	fff7c793          	not	a5,a5
    80003732:	8ff9                	and	a5,a5,a4
    80003734:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003738:	00001097          	auipc	ra,0x1
    8000373c:	120080e7          	jalr	288(ra) # 80004858 <log_write>
  brelse(bp);
    80003740:	854a                	mv	a0,s2
    80003742:	00000097          	auipc	ra,0x0
    80003746:	e92080e7          	jalr	-366(ra) # 800035d4 <brelse>
}
    8000374a:	60e2                	ld	ra,24(sp)
    8000374c:	6442                	ld	s0,16(sp)
    8000374e:	64a2                	ld	s1,8(sp)
    80003750:	6902                	ld	s2,0(sp)
    80003752:	6105                	addi	sp,sp,32
    80003754:	8082                	ret
    panic("freeing free block");
    80003756:	00005517          	auipc	a0,0x5
    8000375a:	fba50513          	addi	a0,a0,-70 # 80008710 <syscallnum+0xa8>
    8000375e:	ffffd097          	auipc	ra,0xffffd
    80003762:	de6080e7          	jalr	-538(ra) # 80000544 <panic>

0000000080003766 <balloc>:
{
    80003766:	711d                	addi	sp,sp,-96
    80003768:	ec86                	sd	ra,88(sp)
    8000376a:	e8a2                	sd	s0,80(sp)
    8000376c:	e4a6                	sd	s1,72(sp)
    8000376e:	e0ca                	sd	s2,64(sp)
    80003770:	fc4e                	sd	s3,56(sp)
    80003772:	f852                	sd	s4,48(sp)
    80003774:	f456                	sd	s5,40(sp)
    80003776:	f05a                	sd	s6,32(sp)
    80003778:	ec5e                	sd	s7,24(sp)
    8000377a:	e862                	sd	s8,16(sp)
    8000377c:	e466                	sd	s9,8(sp)
    8000377e:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003780:	0001e797          	auipc	a5,0x1e
    80003784:	99c7a783          	lw	a5,-1636(a5) # 8002111c <sb+0x4>
    80003788:	10078163          	beqz	a5,8000388a <balloc+0x124>
    8000378c:	8baa                	mv	s7,a0
    8000378e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003790:	0001eb17          	auipc	s6,0x1e
    80003794:	988b0b13          	addi	s6,s6,-1656 # 80021118 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003798:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000379a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000379c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000379e:	6c89                	lui	s9,0x2
    800037a0:	a061                	j	80003828 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    800037a2:	974a                	add	a4,a4,s2
    800037a4:	8fd5                	or	a5,a5,a3
    800037a6:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800037aa:	854a                	mv	a0,s2
    800037ac:	00001097          	auipc	ra,0x1
    800037b0:	0ac080e7          	jalr	172(ra) # 80004858 <log_write>
        brelse(bp);
    800037b4:	854a                	mv	a0,s2
    800037b6:	00000097          	auipc	ra,0x0
    800037ba:	e1e080e7          	jalr	-482(ra) # 800035d4 <brelse>
  bp = bread(dev, bno);
    800037be:	85a6                	mv	a1,s1
    800037c0:	855e                	mv	a0,s7
    800037c2:	00000097          	auipc	ra,0x0
    800037c6:	ce2080e7          	jalr	-798(ra) # 800034a4 <bread>
    800037ca:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800037cc:	40000613          	li	a2,1024
    800037d0:	4581                	li	a1,0
    800037d2:	05850513          	addi	a0,a0,88
    800037d6:	ffffd097          	auipc	ra,0xffffd
    800037da:	510080e7          	jalr	1296(ra) # 80000ce6 <memset>
  log_write(bp);
    800037de:	854a                	mv	a0,s2
    800037e0:	00001097          	auipc	ra,0x1
    800037e4:	078080e7          	jalr	120(ra) # 80004858 <log_write>
  brelse(bp);
    800037e8:	854a                	mv	a0,s2
    800037ea:	00000097          	auipc	ra,0x0
    800037ee:	dea080e7          	jalr	-534(ra) # 800035d4 <brelse>
}
    800037f2:	8526                	mv	a0,s1
    800037f4:	60e6                	ld	ra,88(sp)
    800037f6:	6446                	ld	s0,80(sp)
    800037f8:	64a6                	ld	s1,72(sp)
    800037fa:	6906                	ld	s2,64(sp)
    800037fc:	79e2                	ld	s3,56(sp)
    800037fe:	7a42                	ld	s4,48(sp)
    80003800:	7aa2                	ld	s5,40(sp)
    80003802:	7b02                	ld	s6,32(sp)
    80003804:	6be2                	ld	s7,24(sp)
    80003806:	6c42                	ld	s8,16(sp)
    80003808:	6ca2                	ld	s9,8(sp)
    8000380a:	6125                	addi	sp,sp,96
    8000380c:	8082                	ret
    brelse(bp);
    8000380e:	854a                	mv	a0,s2
    80003810:	00000097          	auipc	ra,0x0
    80003814:	dc4080e7          	jalr	-572(ra) # 800035d4 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003818:	015c87bb          	addw	a5,s9,s5
    8000381c:	00078a9b          	sext.w	s5,a5
    80003820:	004b2703          	lw	a4,4(s6)
    80003824:	06eaf363          	bgeu	s5,a4,8000388a <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003828:	41fad79b          	sraiw	a5,s5,0x1f
    8000382c:	0137d79b          	srliw	a5,a5,0x13
    80003830:	015787bb          	addw	a5,a5,s5
    80003834:	40d7d79b          	sraiw	a5,a5,0xd
    80003838:	01cb2583          	lw	a1,28(s6)
    8000383c:	9dbd                	addw	a1,a1,a5
    8000383e:	855e                	mv	a0,s7
    80003840:	00000097          	auipc	ra,0x0
    80003844:	c64080e7          	jalr	-924(ra) # 800034a4 <bread>
    80003848:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000384a:	004b2503          	lw	a0,4(s6)
    8000384e:	000a849b          	sext.w	s1,s5
    80003852:	8662                	mv	a2,s8
    80003854:	faa4fde3          	bgeu	s1,a0,8000380e <balloc+0xa8>
      m = 1 << (bi % 8);
    80003858:	41f6579b          	sraiw	a5,a2,0x1f
    8000385c:	01d7d69b          	srliw	a3,a5,0x1d
    80003860:	00c6873b          	addw	a4,a3,a2
    80003864:	00777793          	andi	a5,a4,7
    80003868:	9f95                	subw	a5,a5,a3
    8000386a:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000386e:	4037571b          	sraiw	a4,a4,0x3
    80003872:	00e906b3          	add	a3,s2,a4
    80003876:	0586c683          	lbu	a3,88(a3)
    8000387a:	00d7f5b3          	and	a1,a5,a3
    8000387e:	d195                	beqz	a1,800037a2 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003880:	2605                	addiw	a2,a2,1
    80003882:	2485                	addiw	s1,s1,1
    80003884:	fd4618e3          	bne	a2,s4,80003854 <balloc+0xee>
    80003888:	b759                	j	8000380e <balloc+0xa8>
  printf("balloc: out of blocks\n");
    8000388a:	00005517          	auipc	a0,0x5
    8000388e:	e9e50513          	addi	a0,a0,-354 # 80008728 <syscallnum+0xc0>
    80003892:	ffffd097          	auipc	ra,0xffffd
    80003896:	cfc080e7          	jalr	-772(ra) # 8000058e <printf>
  return 0;
    8000389a:	4481                	li	s1,0
    8000389c:	bf99                	j	800037f2 <balloc+0x8c>

000000008000389e <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000389e:	7179                	addi	sp,sp,-48
    800038a0:	f406                	sd	ra,40(sp)
    800038a2:	f022                	sd	s0,32(sp)
    800038a4:	ec26                	sd	s1,24(sp)
    800038a6:	e84a                	sd	s2,16(sp)
    800038a8:	e44e                	sd	s3,8(sp)
    800038aa:	e052                	sd	s4,0(sp)
    800038ac:	1800                	addi	s0,sp,48
    800038ae:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800038b0:	47ad                	li	a5,11
    800038b2:	02b7e763          	bltu	a5,a1,800038e0 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    800038b6:	02059493          	slli	s1,a1,0x20
    800038ba:	9081                	srli	s1,s1,0x20
    800038bc:	048a                	slli	s1,s1,0x2
    800038be:	94aa                	add	s1,s1,a0
    800038c0:	0504a903          	lw	s2,80(s1)
    800038c4:	06091e63          	bnez	s2,80003940 <bmap+0xa2>
      addr = balloc(ip->dev);
    800038c8:	4108                	lw	a0,0(a0)
    800038ca:	00000097          	auipc	ra,0x0
    800038ce:	e9c080e7          	jalr	-356(ra) # 80003766 <balloc>
    800038d2:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800038d6:	06090563          	beqz	s2,80003940 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    800038da:	0524a823          	sw	s2,80(s1)
    800038de:	a08d                	j	80003940 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    800038e0:	ff45849b          	addiw	s1,a1,-12
    800038e4:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800038e8:	0ff00793          	li	a5,255
    800038ec:	08e7e563          	bltu	a5,a4,80003976 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800038f0:	08052903          	lw	s2,128(a0)
    800038f4:	00091d63          	bnez	s2,8000390e <bmap+0x70>
      addr = balloc(ip->dev);
    800038f8:	4108                	lw	a0,0(a0)
    800038fa:	00000097          	auipc	ra,0x0
    800038fe:	e6c080e7          	jalr	-404(ra) # 80003766 <balloc>
    80003902:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003906:	02090d63          	beqz	s2,80003940 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000390a:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000390e:	85ca                	mv	a1,s2
    80003910:	0009a503          	lw	a0,0(s3)
    80003914:	00000097          	auipc	ra,0x0
    80003918:	b90080e7          	jalr	-1136(ra) # 800034a4 <bread>
    8000391c:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000391e:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003922:	02049593          	slli	a1,s1,0x20
    80003926:	9181                	srli	a1,a1,0x20
    80003928:	058a                	slli	a1,a1,0x2
    8000392a:	00b784b3          	add	s1,a5,a1
    8000392e:	0004a903          	lw	s2,0(s1)
    80003932:	02090063          	beqz	s2,80003952 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003936:	8552                	mv	a0,s4
    80003938:	00000097          	auipc	ra,0x0
    8000393c:	c9c080e7          	jalr	-868(ra) # 800035d4 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003940:	854a                	mv	a0,s2
    80003942:	70a2                	ld	ra,40(sp)
    80003944:	7402                	ld	s0,32(sp)
    80003946:	64e2                	ld	s1,24(sp)
    80003948:	6942                	ld	s2,16(sp)
    8000394a:	69a2                	ld	s3,8(sp)
    8000394c:	6a02                	ld	s4,0(sp)
    8000394e:	6145                	addi	sp,sp,48
    80003950:	8082                	ret
      addr = balloc(ip->dev);
    80003952:	0009a503          	lw	a0,0(s3)
    80003956:	00000097          	auipc	ra,0x0
    8000395a:	e10080e7          	jalr	-496(ra) # 80003766 <balloc>
    8000395e:	0005091b          	sext.w	s2,a0
      if(addr){
    80003962:	fc090ae3          	beqz	s2,80003936 <bmap+0x98>
        a[bn] = addr;
    80003966:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000396a:	8552                	mv	a0,s4
    8000396c:	00001097          	auipc	ra,0x1
    80003970:	eec080e7          	jalr	-276(ra) # 80004858 <log_write>
    80003974:	b7c9                	j	80003936 <bmap+0x98>
  panic("bmap: out of range");
    80003976:	00005517          	auipc	a0,0x5
    8000397a:	dca50513          	addi	a0,a0,-566 # 80008740 <syscallnum+0xd8>
    8000397e:	ffffd097          	auipc	ra,0xffffd
    80003982:	bc6080e7          	jalr	-1082(ra) # 80000544 <panic>

0000000080003986 <iget>:
{
    80003986:	7179                	addi	sp,sp,-48
    80003988:	f406                	sd	ra,40(sp)
    8000398a:	f022                	sd	s0,32(sp)
    8000398c:	ec26                	sd	s1,24(sp)
    8000398e:	e84a                	sd	s2,16(sp)
    80003990:	e44e                	sd	s3,8(sp)
    80003992:	e052                	sd	s4,0(sp)
    80003994:	1800                	addi	s0,sp,48
    80003996:	89aa                	mv	s3,a0
    80003998:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000399a:	0001d517          	auipc	a0,0x1d
    8000399e:	79e50513          	addi	a0,a0,1950 # 80021138 <itable>
    800039a2:	ffffd097          	auipc	ra,0xffffd
    800039a6:	248080e7          	jalr	584(ra) # 80000bea <acquire>
  empty = 0;
    800039aa:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800039ac:	0001d497          	auipc	s1,0x1d
    800039b0:	7a448493          	addi	s1,s1,1956 # 80021150 <itable+0x18>
    800039b4:	0001f697          	auipc	a3,0x1f
    800039b8:	22c68693          	addi	a3,a3,556 # 80022be0 <log>
    800039bc:	a039                	j	800039ca <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800039be:	02090b63          	beqz	s2,800039f4 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800039c2:	08848493          	addi	s1,s1,136
    800039c6:	02d48a63          	beq	s1,a3,800039fa <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800039ca:	449c                	lw	a5,8(s1)
    800039cc:	fef059e3          	blez	a5,800039be <iget+0x38>
    800039d0:	4098                	lw	a4,0(s1)
    800039d2:	ff3716e3          	bne	a4,s3,800039be <iget+0x38>
    800039d6:	40d8                	lw	a4,4(s1)
    800039d8:	ff4713e3          	bne	a4,s4,800039be <iget+0x38>
      ip->ref++;
    800039dc:	2785                	addiw	a5,a5,1
    800039de:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800039e0:	0001d517          	auipc	a0,0x1d
    800039e4:	75850513          	addi	a0,a0,1880 # 80021138 <itable>
    800039e8:	ffffd097          	auipc	ra,0xffffd
    800039ec:	2b6080e7          	jalr	694(ra) # 80000c9e <release>
      return ip;
    800039f0:	8926                	mv	s2,s1
    800039f2:	a03d                	j	80003a20 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800039f4:	f7f9                	bnez	a5,800039c2 <iget+0x3c>
    800039f6:	8926                	mv	s2,s1
    800039f8:	b7e9                	j	800039c2 <iget+0x3c>
  if(empty == 0)
    800039fa:	02090c63          	beqz	s2,80003a32 <iget+0xac>
  ip->dev = dev;
    800039fe:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003a02:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003a06:	4785                	li	a5,1
    80003a08:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003a0c:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003a10:	0001d517          	auipc	a0,0x1d
    80003a14:	72850513          	addi	a0,a0,1832 # 80021138 <itable>
    80003a18:	ffffd097          	auipc	ra,0xffffd
    80003a1c:	286080e7          	jalr	646(ra) # 80000c9e <release>
}
    80003a20:	854a                	mv	a0,s2
    80003a22:	70a2                	ld	ra,40(sp)
    80003a24:	7402                	ld	s0,32(sp)
    80003a26:	64e2                	ld	s1,24(sp)
    80003a28:	6942                	ld	s2,16(sp)
    80003a2a:	69a2                	ld	s3,8(sp)
    80003a2c:	6a02                	ld	s4,0(sp)
    80003a2e:	6145                	addi	sp,sp,48
    80003a30:	8082                	ret
    panic("iget: no inodes");
    80003a32:	00005517          	auipc	a0,0x5
    80003a36:	d2650513          	addi	a0,a0,-730 # 80008758 <syscallnum+0xf0>
    80003a3a:	ffffd097          	auipc	ra,0xffffd
    80003a3e:	b0a080e7          	jalr	-1270(ra) # 80000544 <panic>

0000000080003a42 <fsinit>:
fsinit(int dev) {
    80003a42:	7179                	addi	sp,sp,-48
    80003a44:	f406                	sd	ra,40(sp)
    80003a46:	f022                	sd	s0,32(sp)
    80003a48:	ec26                	sd	s1,24(sp)
    80003a4a:	e84a                	sd	s2,16(sp)
    80003a4c:	e44e                	sd	s3,8(sp)
    80003a4e:	1800                	addi	s0,sp,48
    80003a50:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003a52:	4585                	li	a1,1
    80003a54:	00000097          	auipc	ra,0x0
    80003a58:	a50080e7          	jalr	-1456(ra) # 800034a4 <bread>
    80003a5c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003a5e:	0001d997          	auipc	s3,0x1d
    80003a62:	6ba98993          	addi	s3,s3,1722 # 80021118 <sb>
    80003a66:	02000613          	li	a2,32
    80003a6a:	05850593          	addi	a1,a0,88
    80003a6e:	854e                	mv	a0,s3
    80003a70:	ffffd097          	auipc	ra,0xffffd
    80003a74:	2d6080e7          	jalr	726(ra) # 80000d46 <memmove>
  brelse(bp);
    80003a78:	8526                	mv	a0,s1
    80003a7a:	00000097          	auipc	ra,0x0
    80003a7e:	b5a080e7          	jalr	-1190(ra) # 800035d4 <brelse>
  if(sb.magic != FSMAGIC)
    80003a82:	0009a703          	lw	a4,0(s3)
    80003a86:	102037b7          	lui	a5,0x10203
    80003a8a:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003a8e:	02f71263          	bne	a4,a5,80003ab2 <fsinit+0x70>
  initlog(dev, &sb);
    80003a92:	0001d597          	auipc	a1,0x1d
    80003a96:	68658593          	addi	a1,a1,1670 # 80021118 <sb>
    80003a9a:	854a                	mv	a0,s2
    80003a9c:	00001097          	auipc	ra,0x1
    80003aa0:	b40080e7          	jalr	-1216(ra) # 800045dc <initlog>
}
    80003aa4:	70a2                	ld	ra,40(sp)
    80003aa6:	7402                	ld	s0,32(sp)
    80003aa8:	64e2                	ld	s1,24(sp)
    80003aaa:	6942                	ld	s2,16(sp)
    80003aac:	69a2                	ld	s3,8(sp)
    80003aae:	6145                	addi	sp,sp,48
    80003ab0:	8082                	ret
    panic("invalid file system");
    80003ab2:	00005517          	auipc	a0,0x5
    80003ab6:	cb650513          	addi	a0,a0,-842 # 80008768 <syscallnum+0x100>
    80003aba:	ffffd097          	auipc	ra,0xffffd
    80003abe:	a8a080e7          	jalr	-1398(ra) # 80000544 <panic>

0000000080003ac2 <iinit>:
{
    80003ac2:	7179                	addi	sp,sp,-48
    80003ac4:	f406                	sd	ra,40(sp)
    80003ac6:	f022                	sd	s0,32(sp)
    80003ac8:	ec26                	sd	s1,24(sp)
    80003aca:	e84a                	sd	s2,16(sp)
    80003acc:	e44e                	sd	s3,8(sp)
    80003ace:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003ad0:	00005597          	auipc	a1,0x5
    80003ad4:	cb058593          	addi	a1,a1,-848 # 80008780 <syscallnum+0x118>
    80003ad8:	0001d517          	auipc	a0,0x1d
    80003adc:	66050513          	addi	a0,a0,1632 # 80021138 <itable>
    80003ae0:	ffffd097          	auipc	ra,0xffffd
    80003ae4:	07a080e7          	jalr	122(ra) # 80000b5a <initlock>
  for(i = 0; i < NINODE; i++) {
    80003ae8:	0001d497          	auipc	s1,0x1d
    80003aec:	67848493          	addi	s1,s1,1656 # 80021160 <itable+0x28>
    80003af0:	0001f997          	auipc	s3,0x1f
    80003af4:	10098993          	addi	s3,s3,256 # 80022bf0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003af8:	00005917          	auipc	s2,0x5
    80003afc:	c9090913          	addi	s2,s2,-880 # 80008788 <syscallnum+0x120>
    80003b00:	85ca                	mv	a1,s2
    80003b02:	8526                	mv	a0,s1
    80003b04:	00001097          	auipc	ra,0x1
    80003b08:	e3a080e7          	jalr	-454(ra) # 8000493e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003b0c:	08848493          	addi	s1,s1,136
    80003b10:	ff3498e3          	bne	s1,s3,80003b00 <iinit+0x3e>
}
    80003b14:	70a2                	ld	ra,40(sp)
    80003b16:	7402                	ld	s0,32(sp)
    80003b18:	64e2                	ld	s1,24(sp)
    80003b1a:	6942                	ld	s2,16(sp)
    80003b1c:	69a2                	ld	s3,8(sp)
    80003b1e:	6145                	addi	sp,sp,48
    80003b20:	8082                	ret

0000000080003b22 <ialloc>:
{
    80003b22:	715d                	addi	sp,sp,-80
    80003b24:	e486                	sd	ra,72(sp)
    80003b26:	e0a2                	sd	s0,64(sp)
    80003b28:	fc26                	sd	s1,56(sp)
    80003b2a:	f84a                	sd	s2,48(sp)
    80003b2c:	f44e                	sd	s3,40(sp)
    80003b2e:	f052                	sd	s4,32(sp)
    80003b30:	ec56                	sd	s5,24(sp)
    80003b32:	e85a                	sd	s6,16(sp)
    80003b34:	e45e                	sd	s7,8(sp)
    80003b36:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b38:	0001d717          	auipc	a4,0x1d
    80003b3c:	5ec72703          	lw	a4,1516(a4) # 80021124 <sb+0xc>
    80003b40:	4785                	li	a5,1
    80003b42:	04e7fa63          	bgeu	a5,a4,80003b96 <ialloc+0x74>
    80003b46:	8aaa                	mv	s5,a0
    80003b48:	8bae                	mv	s7,a1
    80003b4a:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003b4c:	0001da17          	auipc	s4,0x1d
    80003b50:	5cca0a13          	addi	s4,s4,1484 # 80021118 <sb>
    80003b54:	00048b1b          	sext.w	s6,s1
    80003b58:	0044d593          	srli	a1,s1,0x4
    80003b5c:	018a2783          	lw	a5,24(s4)
    80003b60:	9dbd                	addw	a1,a1,a5
    80003b62:	8556                	mv	a0,s5
    80003b64:	00000097          	auipc	ra,0x0
    80003b68:	940080e7          	jalr	-1728(ra) # 800034a4 <bread>
    80003b6c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003b6e:	05850993          	addi	s3,a0,88
    80003b72:	00f4f793          	andi	a5,s1,15
    80003b76:	079a                	slli	a5,a5,0x6
    80003b78:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003b7a:	00099783          	lh	a5,0(s3)
    80003b7e:	c3a1                	beqz	a5,80003bbe <ialloc+0x9c>
    brelse(bp);
    80003b80:	00000097          	auipc	ra,0x0
    80003b84:	a54080e7          	jalr	-1452(ra) # 800035d4 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b88:	0485                	addi	s1,s1,1
    80003b8a:	00ca2703          	lw	a4,12(s4)
    80003b8e:	0004879b          	sext.w	a5,s1
    80003b92:	fce7e1e3          	bltu	a5,a4,80003b54 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003b96:	00005517          	auipc	a0,0x5
    80003b9a:	bfa50513          	addi	a0,a0,-1030 # 80008790 <syscallnum+0x128>
    80003b9e:	ffffd097          	auipc	ra,0xffffd
    80003ba2:	9f0080e7          	jalr	-1552(ra) # 8000058e <printf>
  return 0;
    80003ba6:	4501                	li	a0,0
}
    80003ba8:	60a6                	ld	ra,72(sp)
    80003baa:	6406                	ld	s0,64(sp)
    80003bac:	74e2                	ld	s1,56(sp)
    80003bae:	7942                	ld	s2,48(sp)
    80003bb0:	79a2                	ld	s3,40(sp)
    80003bb2:	7a02                	ld	s4,32(sp)
    80003bb4:	6ae2                	ld	s5,24(sp)
    80003bb6:	6b42                	ld	s6,16(sp)
    80003bb8:	6ba2                	ld	s7,8(sp)
    80003bba:	6161                	addi	sp,sp,80
    80003bbc:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003bbe:	04000613          	li	a2,64
    80003bc2:	4581                	li	a1,0
    80003bc4:	854e                	mv	a0,s3
    80003bc6:	ffffd097          	auipc	ra,0xffffd
    80003bca:	120080e7          	jalr	288(ra) # 80000ce6 <memset>
      dip->type = type;
    80003bce:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003bd2:	854a                	mv	a0,s2
    80003bd4:	00001097          	auipc	ra,0x1
    80003bd8:	c84080e7          	jalr	-892(ra) # 80004858 <log_write>
      brelse(bp);
    80003bdc:	854a                	mv	a0,s2
    80003bde:	00000097          	auipc	ra,0x0
    80003be2:	9f6080e7          	jalr	-1546(ra) # 800035d4 <brelse>
      return iget(dev, inum);
    80003be6:	85da                	mv	a1,s6
    80003be8:	8556                	mv	a0,s5
    80003bea:	00000097          	auipc	ra,0x0
    80003bee:	d9c080e7          	jalr	-612(ra) # 80003986 <iget>
    80003bf2:	bf5d                	j	80003ba8 <ialloc+0x86>

0000000080003bf4 <iupdate>:
{
    80003bf4:	1101                	addi	sp,sp,-32
    80003bf6:	ec06                	sd	ra,24(sp)
    80003bf8:	e822                	sd	s0,16(sp)
    80003bfa:	e426                	sd	s1,8(sp)
    80003bfc:	e04a                	sd	s2,0(sp)
    80003bfe:	1000                	addi	s0,sp,32
    80003c00:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003c02:	415c                	lw	a5,4(a0)
    80003c04:	0047d79b          	srliw	a5,a5,0x4
    80003c08:	0001d597          	auipc	a1,0x1d
    80003c0c:	5285a583          	lw	a1,1320(a1) # 80021130 <sb+0x18>
    80003c10:	9dbd                	addw	a1,a1,a5
    80003c12:	4108                	lw	a0,0(a0)
    80003c14:	00000097          	auipc	ra,0x0
    80003c18:	890080e7          	jalr	-1904(ra) # 800034a4 <bread>
    80003c1c:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c1e:	05850793          	addi	a5,a0,88
    80003c22:	40c8                	lw	a0,4(s1)
    80003c24:	893d                	andi	a0,a0,15
    80003c26:	051a                	slli	a0,a0,0x6
    80003c28:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003c2a:	04449703          	lh	a4,68(s1)
    80003c2e:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003c32:	04649703          	lh	a4,70(s1)
    80003c36:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003c3a:	04849703          	lh	a4,72(s1)
    80003c3e:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003c42:	04a49703          	lh	a4,74(s1)
    80003c46:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003c4a:	44f8                	lw	a4,76(s1)
    80003c4c:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003c4e:	03400613          	li	a2,52
    80003c52:	05048593          	addi	a1,s1,80
    80003c56:	0531                	addi	a0,a0,12
    80003c58:	ffffd097          	auipc	ra,0xffffd
    80003c5c:	0ee080e7          	jalr	238(ra) # 80000d46 <memmove>
  log_write(bp);
    80003c60:	854a                	mv	a0,s2
    80003c62:	00001097          	auipc	ra,0x1
    80003c66:	bf6080e7          	jalr	-1034(ra) # 80004858 <log_write>
  brelse(bp);
    80003c6a:	854a                	mv	a0,s2
    80003c6c:	00000097          	auipc	ra,0x0
    80003c70:	968080e7          	jalr	-1688(ra) # 800035d4 <brelse>
}
    80003c74:	60e2                	ld	ra,24(sp)
    80003c76:	6442                	ld	s0,16(sp)
    80003c78:	64a2                	ld	s1,8(sp)
    80003c7a:	6902                	ld	s2,0(sp)
    80003c7c:	6105                	addi	sp,sp,32
    80003c7e:	8082                	ret

0000000080003c80 <idup>:
{
    80003c80:	1101                	addi	sp,sp,-32
    80003c82:	ec06                	sd	ra,24(sp)
    80003c84:	e822                	sd	s0,16(sp)
    80003c86:	e426                	sd	s1,8(sp)
    80003c88:	1000                	addi	s0,sp,32
    80003c8a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003c8c:	0001d517          	auipc	a0,0x1d
    80003c90:	4ac50513          	addi	a0,a0,1196 # 80021138 <itable>
    80003c94:	ffffd097          	auipc	ra,0xffffd
    80003c98:	f56080e7          	jalr	-170(ra) # 80000bea <acquire>
  ip->ref++;
    80003c9c:	449c                	lw	a5,8(s1)
    80003c9e:	2785                	addiw	a5,a5,1
    80003ca0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003ca2:	0001d517          	auipc	a0,0x1d
    80003ca6:	49650513          	addi	a0,a0,1174 # 80021138 <itable>
    80003caa:	ffffd097          	auipc	ra,0xffffd
    80003cae:	ff4080e7          	jalr	-12(ra) # 80000c9e <release>
}
    80003cb2:	8526                	mv	a0,s1
    80003cb4:	60e2                	ld	ra,24(sp)
    80003cb6:	6442                	ld	s0,16(sp)
    80003cb8:	64a2                	ld	s1,8(sp)
    80003cba:	6105                	addi	sp,sp,32
    80003cbc:	8082                	ret

0000000080003cbe <ilock>:
{
    80003cbe:	1101                	addi	sp,sp,-32
    80003cc0:	ec06                	sd	ra,24(sp)
    80003cc2:	e822                	sd	s0,16(sp)
    80003cc4:	e426                	sd	s1,8(sp)
    80003cc6:	e04a                	sd	s2,0(sp)
    80003cc8:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003cca:	c115                	beqz	a0,80003cee <ilock+0x30>
    80003ccc:	84aa                	mv	s1,a0
    80003cce:	451c                	lw	a5,8(a0)
    80003cd0:	00f05f63          	blez	a5,80003cee <ilock+0x30>
  acquiresleep(&ip->lock);
    80003cd4:	0541                	addi	a0,a0,16
    80003cd6:	00001097          	auipc	ra,0x1
    80003cda:	ca2080e7          	jalr	-862(ra) # 80004978 <acquiresleep>
  if(ip->valid == 0){
    80003cde:	40bc                	lw	a5,64(s1)
    80003ce0:	cf99                	beqz	a5,80003cfe <ilock+0x40>
}
    80003ce2:	60e2                	ld	ra,24(sp)
    80003ce4:	6442                	ld	s0,16(sp)
    80003ce6:	64a2                	ld	s1,8(sp)
    80003ce8:	6902                	ld	s2,0(sp)
    80003cea:	6105                	addi	sp,sp,32
    80003cec:	8082                	ret
    panic("ilock");
    80003cee:	00005517          	auipc	a0,0x5
    80003cf2:	aba50513          	addi	a0,a0,-1350 # 800087a8 <syscallnum+0x140>
    80003cf6:	ffffd097          	auipc	ra,0xffffd
    80003cfa:	84e080e7          	jalr	-1970(ra) # 80000544 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003cfe:	40dc                	lw	a5,4(s1)
    80003d00:	0047d79b          	srliw	a5,a5,0x4
    80003d04:	0001d597          	auipc	a1,0x1d
    80003d08:	42c5a583          	lw	a1,1068(a1) # 80021130 <sb+0x18>
    80003d0c:	9dbd                	addw	a1,a1,a5
    80003d0e:	4088                	lw	a0,0(s1)
    80003d10:	fffff097          	auipc	ra,0xfffff
    80003d14:	794080e7          	jalr	1940(ra) # 800034a4 <bread>
    80003d18:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003d1a:	05850593          	addi	a1,a0,88
    80003d1e:	40dc                	lw	a5,4(s1)
    80003d20:	8bbd                	andi	a5,a5,15
    80003d22:	079a                	slli	a5,a5,0x6
    80003d24:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003d26:	00059783          	lh	a5,0(a1)
    80003d2a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003d2e:	00259783          	lh	a5,2(a1)
    80003d32:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003d36:	00459783          	lh	a5,4(a1)
    80003d3a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003d3e:	00659783          	lh	a5,6(a1)
    80003d42:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003d46:	459c                	lw	a5,8(a1)
    80003d48:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003d4a:	03400613          	li	a2,52
    80003d4e:	05b1                	addi	a1,a1,12
    80003d50:	05048513          	addi	a0,s1,80
    80003d54:	ffffd097          	auipc	ra,0xffffd
    80003d58:	ff2080e7          	jalr	-14(ra) # 80000d46 <memmove>
    brelse(bp);
    80003d5c:	854a                	mv	a0,s2
    80003d5e:	00000097          	auipc	ra,0x0
    80003d62:	876080e7          	jalr	-1930(ra) # 800035d4 <brelse>
    ip->valid = 1;
    80003d66:	4785                	li	a5,1
    80003d68:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003d6a:	04449783          	lh	a5,68(s1)
    80003d6e:	fbb5                	bnez	a5,80003ce2 <ilock+0x24>
      panic("ilock: no type");
    80003d70:	00005517          	auipc	a0,0x5
    80003d74:	a4050513          	addi	a0,a0,-1472 # 800087b0 <syscallnum+0x148>
    80003d78:	ffffc097          	auipc	ra,0xffffc
    80003d7c:	7cc080e7          	jalr	1996(ra) # 80000544 <panic>

0000000080003d80 <iunlock>:
{
    80003d80:	1101                	addi	sp,sp,-32
    80003d82:	ec06                	sd	ra,24(sp)
    80003d84:	e822                	sd	s0,16(sp)
    80003d86:	e426                	sd	s1,8(sp)
    80003d88:	e04a                	sd	s2,0(sp)
    80003d8a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003d8c:	c905                	beqz	a0,80003dbc <iunlock+0x3c>
    80003d8e:	84aa                	mv	s1,a0
    80003d90:	01050913          	addi	s2,a0,16
    80003d94:	854a                	mv	a0,s2
    80003d96:	00001097          	auipc	ra,0x1
    80003d9a:	c7c080e7          	jalr	-900(ra) # 80004a12 <holdingsleep>
    80003d9e:	cd19                	beqz	a0,80003dbc <iunlock+0x3c>
    80003da0:	449c                	lw	a5,8(s1)
    80003da2:	00f05d63          	blez	a5,80003dbc <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003da6:	854a                	mv	a0,s2
    80003da8:	00001097          	auipc	ra,0x1
    80003dac:	c26080e7          	jalr	-986(ra) # 800049ce <releasesleep>
}
    80003db0:	60e2                	ld	ra,24(sp)
    80003db2:	6442                	ld	s0,16(sp)
    80003db4:	64a2                	ld	s1,8(sp)
    80003db6:	6902                	ld	s2,0(sp)
    80003db8:	6105                	addi	sp,sp,32
    80003dba:	8082                	ret
    panic("iunlock");
    80003dbc:	00005517          	auipc	a0,0x5
    80003dc0:	a0450513          	addi	a0,a0,-1532 # 800087c0 <syscallnum+0x158>
    80003dc4:	ffffc097          	auipc	ra,0xffffc
    80003dc8:	780080e7          	jalr	1920(ra) # 80000544 <panic>

0000000080003dcc <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003dcc:	7179                	addi	sp,sp,-48
    80003dce:	f406                	sd	ra,40(sp)
    80003dd0:	f022                	sd	s0,32(sp)
    80003dd2:	ec26                	sd	s1,24(sp)
    80003dd4:	e84a                	sd	s2,16(sp)
    80003dd6:	e44e                	sd	s3,8(sp)
    80003dd8:	e052                	sd	s4,0(sp)
    80003dda:	1800                	addi	s0,sp,48
    80003ddc:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003dde:	05050493          	addi	s1,a0,80
    80003de2:	08050913          	addi	s2,a0,128
    80003de6:	a021                	j	80003dee <itrunc+0x22>
    80003de8:	0491                	addi	s1,s1,4
    80003dea:	01248d63          	beq	s1,s2,80003e04 <itrunc+0x38>
    if(ip->addrs[i]){
    80003dee:	408c                	lw	a1,0(s1)
    80003df0:	dde5                	beqz	a1,80003de8 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003df2:	0009a503          	lw	a0,0(s3)
    80003df6:	00000097          	auipc	ra,0x0
    80003dfa:	8f4080e7          	jalr	-1804(ra) # 800036ea <bfree>
      ip->addrs[i] = 0;
    80003dfe:	0004a023          	sw	zero,0(s1)
    80003e02:	b7dd                	j	80003de8 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003e04:	0809a583          	lw	a1,128(s3)
    80003e08:	e185                	bnez	a1,80003e28 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003e0a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003e0e:	854e                	mv	a0,s3
    80003e10:	00000097          	auipc	ra,0x0
    80003e14:	de4080e7          	jalr	-540(ra) # 80003bf4 <iupdate>
}
    80003e18:	70a2                	ld	ra,40(sp)
    80003e1a:	7402                	ld	s0,32(sp)
    80003e1c:	64e2                	ld	s1,24(sp)
    80003e1e:	6942                	ld	s2,16(sp)
    80003e20:	69a2                	ld	s3,8(sp)
    80003e22:	6a02                	ld	s4,0(sp)
    80003e24:	6145                	addi	sp,sp,48
    80003e26:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003e28:	0009a503          	lw	a0,0(s3)
    80003e2c:	fffff097          	auipc	ra,0xfffff
    80003e30:	678080e7          	jalr	1656(ra) # 800034a4 <bread>
    80003e34:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003e36:	05850493          	addi	s1,a0,88
    80003e3a:	45850913          	addi	s2,a0,1112
    80003e3e:	a811                	j	80003e52 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003e40:	0009a503          	lw	a0,0(s3)
    80003e44:	00000097          	auipc	ra,0x0
    80003e48:	8a6080e7          	jalr	-1882(ra) # 800036ea <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003e4c:	0491                	addi	s1,s1,4
    80003e4e:	01248563          	beq	s1,s2,80003e58 <itrunc+0x8c>
      if(a[j])
    80003e52:	408c                	lw	a1,0(s1)
    80003e54:	dde5                	beqz	a1,80003e4c <itrunc+0x80>
    80003e56:	b7ed                	j	80003e40 <itrunc+0x74>
    brelse(bp);
    80003e58:	8552                	mv	a0,s4
    80003e5a:	fffff097          	auipc	ra,0xfffff
    80003e5e:	77a080e7          	jalr	1914(ra) # 800035d4 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003e62:	0809a583          	lw	a1,128(s3)
    80003e66:	0009a503          	lw	a0,0(s3)
    80003e6a:	00000097          	auipc	ra,0x0
    80003e6e:	880080e7          	jalr	-1920(ra) # 800036ea <bfree>
    ip->addrs[NDIRECT] = 0;
    80003e72:	0809a023          	sw	zero,128(s3)
    80003e76:	bf51                	j	80003e0a <itrunc+0x3e>

0000000080003e78 <iput>:
{
    80003e78:	1101                	addi	sp,sp,-32
    80003e7a:	ec06                	sd	ra,24(sp)
    80003e7c:	e822                	sd	s0,16(sp)
    80003e7e:	e426                	sd	s1,8(sp)
    80003e80:	e04a                	sd	s2,0(sp)
    80003e82:	1000                	addi	s0,sp,32
    80003e84:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003e86:	0001d517          	auipc	a0,0x1d
    80003e8a:	2b250513          	addi	a0,a0,690 # 80021138 <itable>
    80003e8e:	ffffd097          	auipc	ra,0xffffd
    80003e92:	d5c080e7          	jalr	-676(ra) # 80000bea <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e96:	4498                	lw	a4,8(s1)
    80003e98:	4785                	li	a5,1
    80003e9a:	02f70363          	beq	a4,a5,80003ec0 <iput+0x48>
  ip->ref--;
    80003e9e:	449c                	lw	a5,8(s1)
    80003ea0:	37fd                	addiw	a5,a5,-1
    80003ea2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003ea4:	0001d517          	auipc	a0,0x1d
    80003ea8:	29450513          	addi	a0,a0,660 # 80021138 <itable>
    80003eac:	ffffd097          	auipc	ra,0xffffd
    80003eb0:	df2080e7          	jalr	-526(ra) # 80000c9e <release>
}
    80003eb4:	60e2                	ld	ra,24(sp)
    80003eb6:	6442                	ld	s0,16(sp)
    80003eb8:	64a2                	ld	s1,8(sp)
    80003eba:	6902                	ld	s2,0(sp)
    80003ebc:	6105                	addi	sp,sp,32
    80003ebe:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003ec0:	40bc                	lw	a5,64(s1)
    80003ec2:	dff1                	beqz	a5,80003e9e <iput+0x26>
    80003ec4:	04a49783          	lh	a5,74(s1)
    80003ec8:	fbf9                	bnez	a5,80003e9e <iput+0x26>
    acquiresleep(&ip->lock);
    80003eca:	01048913          	addi	s2,s1,16
    80003ece:	854a                	mv	a0,s2
    80003ed0:	00001097          	auipc	ra,0x1
    80003ed4:	aa8080e7          	jalr	-1368(ra) # 80004978 <acquiresleep>
    release(&itable.lock);
    80003ed8:	0001d517          	auipc	a0,0x1d
    80003edc:	26050513          	addi	a0,a0,608 # 80021138 <itable>
    80003ee0:	ffffd097          	auipc	ra,0xffffd
    80003ee4:	dbe080e7          	jalr	-578(ra) # 80000c9e <release>
    itrunc(ip);
    80003ee8:	8526                	mv	a0,s1
    80003eea:	00000097          	auipc	ra,0x0
    80003eee:	ee2080e7          	jalr	-286(ra) # 80003dcc <itrunc>
    ip->type = 0;
    80003ef2:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003ef6:	8526                	mv	a0,s1
    80003ef8:	00000097          	auipc	ra,0x0
    80003efc:	cfc080e7          	jalr	-772(ra) # 80003bf4 <iupdate>
    ip->valid = 0;
    80003f00:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003f04:	854a                	mv	a0,s2
    80003f06:	00001097          	auipc	ra,0x1
    80003f0a:	ac8080e7          	jalr	-1336(ra) # 800049ce <releasesleep>
    acquire(&itable.lock);
    80003f0e:	0001d517          	auipc	a0,0x1d
    80003f12:	22a50513          	addi	a0,a0,554 # 80021138 <itable>
    80003f16:	ffffd097          	auipc	ra,0xffffd
    80003f1a:	cd4080e7          	jalr	-812(ra) # 80000bea <acquire>
    80003f1e:	b741                	j	80003e9e <iput+0x26>

0000000080003f20 <iunlockput>:
{
    80003f20:	1101                	addi	sp,sp,-32
    80003f22:	ec06                	sd	ra,24(sp)
    80003f24:	e822                	sd	s0,16(sp)
    80003f26:	e426                	sd	s1,8(sp)
    80003f28:	1000                	addi	s0,sp,32
    80003f2a:	84aa                	mv	s1,a0
  iunlock(ip);
    80003f2c:	00000097          	auipc	ra,0x0
    80003f30:	e54080e7          	jalr	-428(ra) # 80003d80 <iunlock>
  iput(ip);
    80003f34:	8526                	mv	a0,s1
    80003f36:	00000097          	auipc	ra,0x0
    80003f3a:	f42080e7          	jalr	-190(ra) # 80003e78 <iput>
}
    80003f3e:	60e2                	ld	ra,24(sp)
    80003f40:	6442                	ld	s0,16(sp)
    80003f42:	64a2                	ld	s1,8(sp)
    80003f44:	6105                	addi	sp,sp,32
    80003f46:	8082                	ret

0000000080003f48 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003f48:	1141                	addi	sp,sp,-16
    80003f4a:	e422                	sd	s0,8(sp)
    80003f4c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003f4e:	411c                	lw	a5,0(a0)
    80003f50:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003f52:	415c                	lw	a5,4(a0)
    80003f54:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003f56:	04451783          	lh	a5,68(a0)
    80003f5a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003f5e:	04a51783          	lh	a5,74(a0)
    80003f62:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003f66:	04c56783          	lwu	a5,76(a0)
    80003f6a:	e99c                	sd	a5,16(a1)
}
    80003f6c:	6422                	ld	s0,8(sp)
    80003f6e:	0141                	addi	sp,sp,16
    80003f70:	8082                	ret

0000000080003f72 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f72:	457c                	lw	a5,76(a0)
    80003f74:	0ed7e963          	bltu	a5,a3,80004066 <readi+0xf4>
{
    80003f78:	7159                	addi	sp,sp,-112
    80003f7a:	f486                	sd	ra,104(sp)
    80003f7c:	f0a2                	sd	s0,96(sp)
    80003f7e:	eca6                	sd	s1,88(sp)
    80003f80:	e8ca                	sd	s2,80(sp)
    80003f82:	e4ce                	sd	s3,72(sp)
    80003f84:	e0d2                	sd	s4,64(sp)
    80003f86:	fc56                	sd	s5,56(sp)
    80003f88:	f85a                	sd	s6,48(sp)
    80003f8a:	f45e                	sd	s7,40(sp)
    80003f8c:	f062                	sd	s8,32(sp)
    80003f8e:	ec66                	sd	s9,24(sp)
    80003f90:	e86a                	sd	s10,16(sp)
    80003f92:	e46e                	sd	s11,8(sp)
    80003f94:	1880                	addi	s0,sp,112
    80003f96:	8b2a                	mv	s6,a0
    80003f98:	8bae                	mv	s7,a1
    80003f9a:	8a32                	mv	s4,a2
    80003f9c:	84b6                	mv	s1,a3
    80003f9e:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003fa0:	9f35                	addw	a4,a4,a3
    return 0;
    80003fa2:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003fa4:	0ad76063          	bltu	a4,a3,80004044 <readi+0xd2>
  if(off + n > ip->size)
    80003fa8:	00e7f463          	bgeu	a5,a4,80003fb0 <readi+0x3e>
    n = ip->size - off;
    80003fac:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003fb0:	0a0a8963          	beqz	s5,80004062 <readi+0xf0>
    80003fb4:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fb6:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003fba:	5c7d                	li	s8,-1
    80003fbc:	a82d                	j	80003ff6 <readi+0x84>
    80003fbe:	020d1d93          	slli	s11,s10,0x20
    80003fc2:	020ddd93          	srli	s11,s11,0x20
    80003fc6:	05890613          	addi	a2,s2,88
    80003fca:	86ee                	mv	a3,s11
    80003fcc:	963a                	add	a2,a2,a4
    80003fce:	85d2                	mv	a1,s4
    80003fd0:	855e                	mv	a0,s7
    80003fd2:	ffffe097          	auipc	ra,0xffffe
    80003fd6:	796080e7          	jalr	1942(ra) # 80002768 <either_copyout>
    80003fda:	05850d63          	beq	a0,s8,80004034 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003fde:	854a                	mv	a0,s2
    80003fe0:	fffff097          	auipc	ra,0xfffff
    80003fe4:	5f4080e7          	jalr	1524(ra) # 800035d4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003fe8:	013d09bb          	addw	s3,s10,s3
    80003fec:	009d04bb          	addw	s1,s10,s1
    80003ff0:	9a6e                	add	s4,s4,s11
    80003ff2:	0559f763          	bgeu	s3,s5,80004040 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003ff6:	00a4d59b          	srliw	a1,s1,0xa
    80003ffa:	855a                	mv	a0,s6
    80003ffc:	00000097          	auipc	ra,0x0
    80004000:	8a2080e7          	jalr	-1886(ra) # 8000389e <bmap>
    80004004:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004008:	cd85                	beqz	a1,80004040 <readi+0xce>
    bp = bread(ip->dev, addr);
    8000400a:	000b2503          	lw	a0,0(s6)
    8000400e:	fffff097          	auipc	ra,0xfffff
    80004012:	496080e7          	jalr	1174(ra) # 800034a4 <bread>
    80004016:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004018:	3ff4f713          	andi	a4,s1,1023
    8000401c:	40ec87bb          	subw	a5,s9,a4
    80004020:	413a86bb          	subw	a3,s5,s3
    80004024:	8d3e                	mv	s10,a5
    80004026:	2781                	sext.w	a5,a5
    80004028:	0006861b          	sext.w	a2,a3
    8000402c:	f8f679e3          	bgeu	a2,a5,80003fbe <readi+0x4c>
    80004030:	8d36                	mv	s10,a3
    80004032:	b771                	j	80003fbe <readi+0x4c>
      brelse(bp);
    80004034:	854a                	mv	a0,s2
    80004036:	fffff097          	auipc	ra,0xfffff
    8000403a:	59e080e7          	jalr	1438(ra) # 800035d4 <brelse>
      tot = -1;
    8000403e:	59fd                	li	s3,-1
  }
  return tot;
    80004040:	0009851b          	sext.w	a0,s3
}
    80004044:	70a6                	ld	ra,104(sp)
    80004046:	7406                	ld	s0,96(sp)
    80004048:	64e6                	ld	s1,88(sp)
    8000404a:	6946                	ld	s2,80(sp)
    8000404c:	69a6                	ld	s3,72(sp)
    8000404e:	6a06                	ld	s4,64(sp)
    80004050:	7ae2                	ld	s5,56(sp)
    80004052:	7b42                	ld	s6,48(sp)
    80004054:	7ba2                	ld	s7,40(sp)
    80004056:	7c02                	ld	s8,32(sp)
    80004058:	6ce2                	ld	s9,24(sp)
    8000405a:	6d42                	ld	s10,16(sp)
    8000405c:	6da2                	ld	s11,8(sp)
    8000405e:	6165                	addi	sp,sp,112
    80004060:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004062:	89d6                	mv	s3,s5
    80004064:	bff1                	j	80004040 <readi+0xce>
    return 0;
    80004066:	4501                	li	a0,0
}
    80004068:	8082                	ret

000000008000406a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000406a:	457c                	lw	a5,76(a0)
    8000406c:	10d7e863          	bltu	a5,a3,8000417c <writei+0x112>
{
    80004070:	7159                	addi	sp,sp,-112
    80004072:	f486                	sd	ra,104(sp)
    80004074:	f0a2                	sd	s0,96(sp)
    80004076:	eca6                	sd	s1,88(sp)
    80004078:	e8ca                	sd	s2,80(sp)
    8000407a:	e4ce                	sd	s3,72(sp)
    8000407c:	e0d2                	sd	s4,64(sp)
    8000407e:	fc56                	sd	s5,56(sp)
    80004080:	f85a                	sd	s6,48(sp)
    80004082:	f45e                	sd	s7,40(sp)
    80004084:	f062                	sd	s8,32(sp)
    80004086:	ec66                	sd	s9,24(sp)
    80004088:	e86a                	sd	s10,16(sp)
    8000408a:	e46e                	sd	s11,8(sp)
    8000408c:	1880                	addi	s0,sp,112
    8000408e:	8aaa                	mv	s5,a0
    80004090:	8bae                	mv	s7,a1
    80004092:	8a32                	mv	s4,a2
    80004094:	8936                	mv	s2,a3
    80004096:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004098:	00e687bb          	addw	a5,a3,a4
    8000409c:	0ed7e263          	bltu	a5,a3,80004180 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800040a0:	00043737          	lui	a4,0x43
    800040a4:	0ef76063          	bltu	a4,a5,80004184 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800040a8:	0c0b0863          	beqz	s6,80004178 <writei+0x10e>
    800040ac:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800040ae:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800040b2:	5c7d                	li	s8,-1
    800040b4:	a091                	j	800040f8 <writei+0x8e>
    800040b6:	020d1d93          	slli	s11,s10,0x20
    800040ba:	020ddd93          	srli	s11,s11,0x20
    800040be:	05848513          	addi	a0,s1,88
    800040c2:	86ee                	mv	a3,s11
    800040c4:	8652                	mv	a2,s4
    800040c6:	85de                	mv	a1,s7
    800040c8:	953a                	add	a0,a0,a4
    800040ca:	ffffe097          	auipc	ra,0xffffe
    800040ce:	6f4080e7          	jalr	1780(ra) # 800027be <either_copyin>
    800040d2:	07850263          	beq	a0,s8,80004136 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800040d6:	8526                	mv	a0,s1
    800040d8:	00000097          	auipc	ra,0x0
    800040dc:	780080e7          	jalr	1920(ra) # 80004858 <log_write>
    brelse(bp);
    800040e0:	8526                	mv	a0,s1
    800040e2:	fffff097          	auipc	ra,0xfffff
    800040e6:	4f2080e7          	jalr	1266(ra) # 800035d4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800040ea:	013d09bb          	addw	s3,s10,s3
    800040ee:	012d093b          	addw	s2,s10,s2
    800040f2:	9a6e                	add	s4,s4,s11
    800040f4:	0569f663          	bgeu	s3,s6,80004140 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    800040f8:	00a9559b          	srliw	a1,s2,0xa
    800040fc:	8556                	mv	a0,s5
    800040fe:	fffff097          	auipc	ra,0xfffff
    80004102:	7a0080e7          	jalr	1952(ra) # 8000389e <bmap>
    80004106:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000410a:	c99d                	beqz	a1,80004140 <writei+0xd6>
    bp = bread(ip->dev, addr);
    8000410c:	000aa503          	lw	a0,0(s5)
    80004110:	fffff097          	auipc	ra,0xfffff
    80004114:	394080e7          	jalr	916(ra) # 800034a4 <bread>
    80004118:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000411a:	3ff97713          	andi	a4,s2,1023
    8000411e:	40ec87bb          	subw	a5,s9,a4
    80004122:	413b06bb          	subw	a3,s6,s3
    80004126:	8d3e                	mv	s10,a5
    80004128:	2781                	sext.w	a5,a5
    8000412a:	0006861b          	sext.w	a2,a3
    8000412e:	f8f674e3          	bgeu	a2,a5,800040b6 <writei+0x4c>
    80004132:	8d36                	mv	s10,a3
    80004134:	b749                	j	800040b6 <writei+0x4c>
      brelse(bp);
    80004136:	8526                	mv	a0,s1
    80004138:	fffff097          	auipc	ra,0xfffff
    8000413c:	49c080e7          	jalr	1180(ra) # 800035d4 <brelse>
  }

  if(off > ip->size)
    80004140:	04caa783          	lw	a5,76(s5)
    80004144:	0127f463          	bgeu	a5,s2,8000414c <writei+0xe2>
    ip->size = off;
    80004148:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000414c:	8556                	mv	a0,s5
    8000414e:	00000097          	auipc	ra,0x0
    80004152:	aa6080e7          	jalr	-1370(ra) # 80003bf4 <iupdate>

  return tot;
    80004156:	0009851b          	sext.w	a0,s3
}
    8000415a:	70a6                	ld	ra,104(sp)
    8000415c:	7406                	ld	s0,96(sp)
    8000415e:	64e6                	ld	s1,88(sp)
    80004160:	6946                	ld	s2,80(sp)
    80004162:	69a6                	ld	s3,72(sp)
    80004164:	6a06                	ld	s4,64(sp)
    80004166:	7ae2                	ld	s5,56(sp)
    80004168:	7b42                	ld	s6,48(sp)
    8000416a:	7ba2                	ld	s7,40(sp)
    8000416c:	7c02                	ld	s8,32(sp)
    8000416e:	6ce2                	ld	s9,24(sp)
    80004170:	6d42                	ld	s10,16(sp)
    80004172:	6da2                	ld	s11,8(sp)
    80004174:	6165                	addi	sp,sp,112
    80004176:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004178:	89da                	mv	s3,s6
    8000417a:	bfc9                	j	8000414c <writei+0xe2>
    return -1;
    8000417c:	557d                	li	a0,-1
}
    8000417e:	8082                	ret
    return -1;
    80004180:	557d                	li	a0,-1
    80004182:	bfe1                	j	8000415a <writei+0xf0>
    return -1;
    80004184:	557d                	li	a0,-1
    80004186:	bfd1                	j	8000415a <writei+0xf0>

0000000080004188 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004188:	1141                	addi	sp,sp,-16
    8000418a:	e406                	sd	ra,8(sp)
    8000418c:	e022                	sd	s0,0(sp)
    8000418e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004190:	4639                	li	a2,14
    80004192:	ffffd097          	auipc	ra,0xffffd
    80004196:	c2c080e7          	jalr	-980(ra) # 80000dbe <strncmp>
}
    8000419a:	60a2                	ld	ra,8(sp)
    8000419c:	6402                	ld	s0,0(sp)
    8000419e:	0141                	addi	sp,sp,16
    800041a0:	8082                	ret

00000000800041a2 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800041a2:	7139                	addi	sp,sp,-64
    800041a4:	fc06                	sd	ra,56(sp)
    800041a6:	f822                	sd	s0,48(sp)
    800041a8:	f426                	sd	s1,40(sp)
    800041aa:	f04a                	sd	s2,32(sp)
    800041ac:	ec4e                	sd	s3,24(sp)
    800041ae:	e852                	sd	s4,16(sp)
    800041b0:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800041b2:	04451703          	lh	a4,68(a0)
    800041b6:	4785                	li	a5,1
    800041b8:	00f71a63          	bne	a4,a5,800041cc <dirlookup+0x2a>
    800041bc:	892a                	mv	s2,a0
    800041be:	89ae                	mv	s3,a1
    800041c0:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800041c2:	457c                	lw	a5,76(a0)
    800041c4:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800041c6:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041c8:	e79d                	bnez	a5,800041f6 <dirlookup+0x54>
    800041ca:	a8a5                	j	80004242 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800041cc:	00004517          	auipc	a0,0x4
    800041d0:	5fc50513          	addi	a0,a0,1532 # 800087c8 <syscallnum+0x160>
    800041d4:	ffffc097          	auipc	ra,0xffffc
    800041d8:	370080e7          	jalr	880(ra) # 80000544 <panic>
      panic("dirlookup read");
    800041dc:	00004517          	auipc	a0,0x4
    800041e0:	60450513          	addi	a0,a0,1540 # 800087e0 <syscallnum+0x178>
    800041e4:	ffffc097          	auipc	ra,0xffffc
    800041e8:	360080e7          	jalr	864(ra) # 80000544 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041ec:	24c1                	addiw	s1,s1,16
    800041ee:	04c92783          	lw	a5,76(s2)
    800041f2:	04f4f763          	bgeu	s1,a5,80004240 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041f6:	4741                	li	a4,16
    800041f8:	86a6                	mv	a3,s1
    800041fa:	fc040613          	addi	a2,s0,-64
    800041fe:	4581                	li	a1,0
    80004200:	854a                	mv	a0,s2
    80004202:	00000097          	auipc	ra,0x0
    80004206:	d70080e7          	jalr	-656(ra) # 80003f72 <readi>
    8000420a:	47c1                	li	a5,16
    8000420c:	fcf518e3          	bne	a0,a5,800041dc <dirlookup+0x3a>
    if(de.inum == 0)
    80004210:	fc045783          	lhu	a5,-64(s0)
    80004214:	dfe1                	beqz	a5,800041ec <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004216:	fc240593          	addi	a1,s0,-62
    8000421a:	854e                	mv	a0,s3
    8000421c:	00000097          	auipc	ra,0x0
    80004220:	f6c080e7          	jalr	-148(ra) # 80004188 <namecmp>
    80004224:	f561                	bnez	a0,800041ec <dirlookup+0x4a>
      if(poff)
    80004226:	000a0463          	beqz	s4,8000422e <dirlookup+0x8c>
        *poff = off;
    8000422a:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000422e:	fc045583          	lhu	a1,-64(s0)
    80004232:	00092503          	lw	a0,0(s2)
    80004236:	fffff097          	auipc	ra,0xfffff
    8000423a:	750080e7          	jalr	1872(ra) # 80003986 <iget>
    8000423e:	a011                	j	80004242 <dirlookup+0xa0>
  return 0;
    80004240:	4501                	li	a0,0
}
    80004242:	70e2                	ld	ra,56(sp)
    80004244:	7442                	ld	s0,48(sp)
    80004246:	74a2                	ld	s1,40(sp)
    80004248:	7902                	ld	s2,32(sp)
    8000424a:	69e2                	ld	s3,24(sp)
    8000424c:	6a42                	ld	s4,16(sp)
    8000424e:	6121                	addi	sp,sp,64
    80004250:	8082                	ret

0000000080004252 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004252:	711d                	addi	sp,sp,-96
    80004254:	ec86                	sd	ra,88(sp)
    80004256:	e8a2                	sd	s0,80(sp)
    80004258:	e4a6                	sd	s1,72(sp)
    8000425a:	e0ca                	sd	s2,64(sp)
    8000425c:	fc4e                	sd	s3,56(sp)
    8000425e:	f852                	sd	s4,48(sp)
    80004260:	f456                	sd	s5,40(sp)
    80004262:	f05a                	sd	s6,32(sp)
    80004264:	ec5e                	sd	s7,24(sp)
    80004266:	e862                	sd	s8,16(sp)
    80004268:	e466                	sd	s9,8(sp)
    8000426a:	1080                	addi	s0,sp,96
    8000426c:	84aa                	mv	s1,a0
    8000426e:	8b2e                	mv	s6,a1
    80004270:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004272:	00054703          	lbu	a4,0(a0)
    80004276:	02f00793          	li	a5,47
    8000427a:	02f70363          	beq	a4,a5,800042a0 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000427e:	ffffd097          	auipc	ra,0xffffd
    80004282:	748080e7          	jalr	1864(ra) # 800019c6 <myproc>
    80004286:	15053503          	ld	a0,336(a0)
    8000428a:	00000097          	auipc	ra,0x0
    8000428e:	9f6080e7          	jalr	-1546(ra) # 80003c80 <idup>
    80004292:	89aa                	mv	s3,a0
  while(*path == '/')
    80004294:	02f00913          	li	s2,47
  len = path - s;
    80004298:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    8000429a:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000429c:	4c05                	li	s8,1
    8000429e:	a865                	j	80004356 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800042a0:	4585                	li	a1,1
    800042a2:	4505                	li	a0,1
    800042a4:	fffff097          	auipc	ra,0xfffff
    800042a8:	6e2080e7          	jalr	1762(ra) # 80003986 <iget>
    800042ac:	89aa                	mv	s3,a0
    800042ae:	b7dd                	j	80004294 <namex+0x42>
      iunlockput(ip);
    800042b0:	854e                	mv	a0,s3
    800042b2:	00000097          	auipc	ra,0x0
    800042b6:	c6e080e7          	jalr	-914(ra) # 80003f20 <iunlockput>
      return 0;
    800042ba:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800042bc:	854e                	mv	a0,s3
    800042be:	60e6                	ld	ra,88(sp)
    800042c0:	6446                	ld	s0,80(sp)
    800042c2:	64a6                	ld	s1,72(sp)
    800042c4:	6906                	ld	s2,64(sp)
    800042c6:	79e2                	ld	s3,56(sp)
    800042c8:	7a42                	ld	s4,48(sp)
    800042ca:	7aa2                	ld	s5,40(sp)
    800042cc:	7b02                	ld	s6,32(sp)
    800042ce:	6be2                	ld	s7,24(sp)
    800042d0:	6c42                	ld	s8,16(sp)
    800042d2:	6ca2                	ld	s9,8(sp)
    800042d4:	6125                	addi	sp,sp,96
    800042d6:	8082                	ret
      iunlock(ip);
    800042d8:	854e                	mv	a0,s3
    800042da:	00000097          	auipc	ra,0x0
    800042de:	aa6080e7          	jalr	-1370(ra) # 80003d80 <iunlock>
      return ip;
    800042e2:	bfe9                	j	800042bc <namex+0x6a>
      iunlockput(ip);
    800042e4:	854e                	mv	a0,s3
    800042e6:	00000097          	auipc	ra,0x0
    800042ea:	c3a080e7          	jalr	-966(ra) # 80003f20 <iunlockput>
      return 0;
    800042ee:	89d2                	mv	s3,s4
    800042f0:	b7f1                	j	800042bc <namex+0x6a>
  len = path - s;
    800042f2:	40b48633          	sub	a2,s1,a1
    800042f6:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    800042fa:	094cd463          	bge	s9,s4,80004382 <namex+0x130>
    memmove(name, s, DIRSIZ);
    800042fe:	4639                	li	a2,14
    80004300:	8556                	mv	a0,s5
    80004302:	ffffd097          	auipc	ra,0xffffd
    80004306:	a44080e7          	jalr	-1468(ra) # 80000d46 <memmove>
  while(*path == '/')
    8000430a:	0004c783          	lbu	a5,0(s1)
    8000430e:	01279763          	bne	a5,s2,8000431c <namex+0xca>
    path++;
    80004312:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004314:	0004c783          	lbu	a5,0(s1)
    80004318:	ff278de3          	beq	a5,s2,80004312 <namex+0xc0>
    ilock(ip);
    8000431c:	854e                	mv	a0,s3
    8000431e:	00000097          	auipc	ra,0x0
    80004322:	9a0080e7          	jalr	-1632(ra) # 80003cbe <ilock>
    if(ip->type != T_DIR){
    80004326:	04499783          	lh	a5,68(s3)
    8000432a:	f98793e3          	bne	a5,s8,800042b0 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    8000432e:	000b0563          	beqz	s6,80004338 <namex+0xe6>
    80004332:	0004c783          	lbu	a5,0(s1)
    80004336:	d3cd                	beqz	a5,800042d8 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004338:	865e                	mv	a2,s7
    8000433a:	85d6                	mv	a1,s5
    8000433c:	854e                	mv	a0,s3
    8000433e:	00000097          	auipc	ra,0x0
    80004342:	e64080e7          	jalr	-412(ra) # 800041a2 <dirlookup>
    80004346:	8a2a                	mv	s4,a0
    80004348:	dd51                	beqz	a0,800042e4 <namex+0x92>
    iunlockput(ip);
    8000434a:	854e                	mv	a0,s3
    8000434c:	00000097          	auipc	ra,0x0
    80004350:	bd4080e7          	jalr	-1068(ra) # 80003f20 <iunlockput>
    ip = next;
    80004354:	89d2                	mv	s3,s4
  while(*path == '/')
    80004356:	0004c783          	lbu	a5,0(s1)
    8000435a:	05279763          	bne	a5,s2,800043a8 <namex+0x156>
    path++;
    8000435e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004360:	0004c783          	lbu	a5,0(s1)
    80004364:	ff278de3          	beq	a5,s2,8000435e <namex+0x10c>
  if(*path == 0)
    80004368:	c79d                	beqz	a5,80004396 <namex+0x144>
    path++;
    8000436a:	85a6                	mv	a1,s1
  len = path - s;
    8000436c:	8a5e                	mv	s4,s7
    8000436e:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80004370:	01278963          	beq	a5,s2,80004382 <namex+0x130>
    80004374:	dfbd                	beqz	a5,800042f2 <namex+0xa0>
    path++;
    80004376:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004378:	0004c783          	lbu	a5,0(s1)
    8000437c:	ff279ce3          	bne	a5,s2,80004374 <namex+0x122>
    80004380:	bf8d                	j	800042f2 <namex+0xa0>
    memmove(name, s, len);
    80004382:	2601                	sext.w	a2,a2
    80004384:	8556                	mv	a0,s5
    80004386:	ffffd097          	auipc	ra,0xffffd
    8000438a:	9c0080e7          	jalr	-1600(ra) # 80000d46 <memmove>
    name[len] = 0;
    8000438e:	9a56                	add	s4,s4,s5
    80004390:	000a0023          	sb	zero,0(s4)
    80004394:	bf9d                	j	8000430a <namex+0xb8>
  if(nameiparent){
    80004396:	f20b03e3          	beqz	s6,800042bc <namex+0x6a>
    iput(ip);
    8000439a:	854e                	mv	a0,s3
    8000439c:	00000097          	auipc	ra,0x0
    800043a0:	adc080e7          	jalr	-1316(ra) # 80003e78 <iput>
    return 0;
    800043a4:	4981                	li	s3,0
    800043a6:	bf19                	j	800042bc <namex+0x6a>
  if(*path == 0)
    800043a8:	d7fd                	beqz	a5,80004396 <namex+0x144>
  while(*path != '/' && *path != 0)
    800043aa:	0004c783          	lbu	a5,0(s1)
    800043ae:	85a6                	mv	a1,s1
    800043b0:	b7d1                	j	80004374 <namex+0x122>

00000000800043b2 <dirlink>:
{
    800043b2:	7139                	addi	sp,sp,-64
    800043b4:	fc06                	sd	ra,56(sp)
    800043b6:	f822                	sd	s0,48(sp)
    800043b8:	f426                	sd	s1,40(sp)
    800043ba:	f04a                	sd	s2,32(sp)
    800043bc:	ec4e                	sd	s3,24(sp)
    800043be:	e852                	sd	s4,16(sp)
    800043c0:	0080                	addi	s0,sp,64
    800043c2:	892a                	mv	s2,a0
    800043c4:	8a2e                	mv	s4,a1
    800043c6:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800043c8:	4601                	li	a2,0
    800043ca:	00000097          	auipc	ra,0x0
    800043ce:	dd8080e7          	jalr	-552(ra) # 800041a2 <dirlookup>
    800043d2:	e93d                	bnez	a0,80004448 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043d4:	04c92483          	lw	s1,76(s2)
    800043d8:	c49d                	beqz	s1,80004406 <dirlink+0x54>
    800043da:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043dc:	4741                	li	a4,16
    800043de:	86a6                	mv	a3,s1
    800043e0:	fc040613          	addi	a2,s0,-64
    800043e4:	4581                	li	a1,0
    800043e6:	854a                	mv	a0,s2
    800043e8:	00000097          	auipc	ra,0x0
    800043ec:	b8a080e7          	jalr	-1142(ra) # 80003f72 <readi>
    800043f0:	47c1                	li	a5,16
    800043f2:	06f51163          	bne	a0,a5,80004454 <dirlink+0xa2>
    if(de.inum == 0)
    800043f6:	fc045783          	lhu	a5,-64(s0)
    800043fa:	c791                	beqz	a5,80004406 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043fc:	24c1                	addiw	s1,s1,16
    800043fe:	04c92783          	lw	a5,76(s2)
    80004402:	fcf4ede3          	bltu	s1,a5,800043dc <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004406:	4639                	li	a2,14
    80004408:	85d2                	mv	a1,s4
    8000440a:	fc240513          	addi	a0,s0,-62
    8000440e:	ffffd097          	auipc	ra,0xffffd
    80004412:	9ec080e7          	jalr	-1556(ra) # 80000dfa <strncpy>
  de.inum = inum;
    80004416:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000441a:	4741                	li	a4,16
    8000441c:	86a6                	mv	a3,s1
    8000441e:	fc040613          	addi	a2,s0,-64
    80004422:	4581                	li	a1,0
    80004424:	854a                	mv	a0,s2
    80004426:	00000097          	auipc	ra,0x0
    8000442a:	c44080e7          	jalr	-956(ra) # 8000406a <writei>
    8000442e:	1541                	addi	a0,a0,-16
    80004430:	00a03533          	snez	a0,a0
    80004434:	40a00533          	neg	a0,a0
}
    80004438:	70e2                	ld	ra,56(sp)
    8000443a:	7442                	ld	s0,48(sp)
    8000443c:	74a2                	ld	s1,40(sp)
    8000443e:	7902                	ld	s2,32(sp)
    80004440:	69e2                	ld	s3,24(sp)
    80004442:	6a42                	ld	s4,16(sp)
    80004444:	6121                	addi	sp,sp,64
    80004446:	8082                	ret
    iput(ip);
    80004448:	00000097          	auipc	ra,0x0
    8000444c:	a30080e7          	jalr	-1488(ra) # 80003e78 <iput>
    return -1;
    80004450:	557d                	li	a0,-1
    80004452:	b7dd                	j	80004438 <dirlink+0x86>
      panic("dirlink read");
    80004454:	00004517          	auipc	a0,0x4
    80004458:	39c50513          	addi	a0,a0,924 # 800087f0 <syscallnum+0x188>
    8000445c:	ffffc097          	auipc	ra,0xffffc
    80004460:	0e8080e7          	jalr	232(ra) # 80000544 <panic>

0000000080004464 <namei>:

struct inode*
namei(char *path)
{
    80004464:	1101                	addi	sp,sp,-32
    80004466:	ec06                	sd	ra,24(sp)
    80004468:	e822                	sd	s0,16(sp)
    8000446a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000446c:	fe040613          	addi	a2,s0,-32
    80004470:	4581                	li	a1,0
    80004472:	00000097          	auipc	ra,0x0
    80004476:	de0080e7          	jalr	-544(ra) # 80004252 <namex>
}
    8000447a:	60e2                	ld	ra,24(sp)
    8000447c:	6442                	ld	s0,16(sp)
    8000447e:	6105                	addi	sp,sp,32
    80004480:	8082                	ret

0000000080004482 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004482:	1141                	addi	sp,sp,-16
    80004484:	e406                	sd	ra,8(sp)
    80004486:	e022                	sd	s0,0(sp)
    80004488:	0800                	addi	s0,sp,16
    8000448a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000448c:	4585                	li	a1,1
    8000448e:	00000097          	auipc	ra,0x0
    80004492:	dc4080e7          	jalr	-572(ra) # 80004252 <namex>
}
    80004496:	60a2                	ld	ra,8(sp)
    80004498:	6402                	ld	s0,0(sp)
    8000449a:	0141                	addi	sp,sp,16
    8000449c:	8082                	ret

000000008000449e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000449e:	1101                	addi	sp,sp,-32
    800044a0:	ec06                	sd	ra,24(sp)
    800044a2:	e822                	sd	s0,16(sp)
    800044a4:	e426                	sd	s1,8(sp)
    800044a6:	e04a                	sd	s2,0(sp)
    800044a8:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800044aa:	0001e917          	auipc	s2,0x1e
    800044ae:	73690913          	addi	s2,s2,1846 # 80022be0 <log>
    800044b2:	01892583          	lw	a1,24(s2)
    800044b6:	02892503          	lw	a0,40(s2)
    800044ba:	fffff097          	auipc	ra,0xfffff
    800044be:	fea080e7          	jalr	-22(ra) # 800034a4 <bread>
    800044c2:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800044c4:	02c92683          	lw	a3,44(s2)
    800044c8:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800044ca:	02d05763          	blez	a3,800044f8 <write_head+0x5a>
    800044ce:	0001e797          	auipc	a5,0x1e
    800044d2:	74278793          	addi	a5,a5,1858 # 80022c10 <log+0x30>
    800044d6:	05c50713          	addi	a4,a0,92
    800044da:	36fd                	addiw	a3,a3,-1
    800044dc:	1682                	slli	a3,a3,0x20
    800044de:	9281                	srli	a3,a3,0x20
    800044e0:	068a                	slli	a3,a3,0x2
    800044e2:	0001e617          	auipc	a2,0x1e
    800044e6:	73260613          	addi	a2,a2,1842 # 80022c14 <log+0x34>
    800044ea:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800044ec:	4390                	lw	a2,0(a5)
    800044ee:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800044f0:	0791                	addi	a5,a5,4
    800044f2:	0711                	addi	a4,a4,4
    800044f4:	fed79ce3          	bne	a5,a3,800044ec <write_head+0x4e>
  }
  bwrite(buf);
    800044f8:	8526                	mv	a0,s1
    800044fa:	fffff097          	auipc	ra,0xfffff
    800044fe:	09c080e7          	jalr	156(ra) # 80003596 <bwrite>
  brelse(buf);
    80004502:	8526                	mv	a0,s1
    80004504:	fffff097          	auipc	ra,0xfffff
    80004508:	0d0080e7          	jalr	208(ra) # 800035d4 <brelse>
}
    8000450c:	60e2                	ld	ra,24(sp)
    8000450e:	6442                	ld	s0,16(sp)
    80004510:	64a2                	ld	s1,8(sp)
    80004512:	6902                	ld	s2,0(sp)
    80004514:	6105                	addi	sp,sp,32
    80004516:	8082                	ret

0000000080004518 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004518:	0001e797          	auipc	a5,0x1e
    8000451c:	6f47a783          	lw	a5,1780(a5) # 80022c0c <log+0x2c>
    80004520:	0af05d63          	blez	a5,800045da <install_trans+0xc2>
{
    80004524:	7139                	addi	sp,sp,-64
    80004526:	fc06                	sd	ra,56(sp)
    80004528:	f822                	sd	s0,48(sp)
    8000452a:	f426                	sd	s1,40(sp)
    8000452c:	f04a                	sd	s2,32(sp)
    8000452e:	ec4e                	sd	s3,24(sp)
    80004530:	e852                	sd	s4,16(sp)
    80004532:	e456                	sd	s5,8(sp)
    80004534:	e05a                	sd	s6,0(sp)
    80004536:	0080                	addi	s0,sp,64
    80004538:	8b2a                	mv	s6,a0
    8000453a:	0001ea97          	auipc	s5,0x1e
    8000453e:	6d6a8a93          	addi	s5,s5,1750 # 80022c10 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004542:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004544:	0001e997          	auipc	s3,0x1e
    80004548:	69c98993          	addi	s3,s3,1692 # 80022be0 <log>
    8000454c:	a035                	j	80004578 <install_trans+0x60>
      bunpin(dbuf);
    8000454e:	8526                	mv	a0,s1
    80004550:	fffff097          	auipc	ra,0xfffff
    80004554:	15e080e7          	jalr	350(ra) # 800036ae <bunpin>
    brelse(lbuf);
    80004558:	854a                	mv	a0,s2
    8000455a:	fffff097          	auipc	ra,0xfffff
    8000455e:	07a080e7          	jalr	122(ra) # 800035d4 <brelse>
    brelse(dbuf);
    80004562:	8526                	mv	a0,s1
    80004564:	fffff097          	auipc	ra,0xfffff
    80004568:	070080e7          	jalr	112(ra) # 800035d4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000456c:	2a05                	addiw	s4,s4,1
    8000456e:	0a91                	addi	s5,s5,4
    80004570:	02c9a783          	lw	a5,44(s3)
    80004574:	04fa5963          	bge	s4,a5,800045c6 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004578:	0189a583          	lw	a1,24(s3)
    8000457c:	014585bb          	addw	a1,a1,s4
    80004580:	2585                	addiw	a1,a1,1
    80004582:	0289a503          	lw	a0,40(s3)
    80004586:	fffff097          	auipc	ra,0xfffff
    8000458a:	f1e080e7          	jalr	-226(ra) # 800034a4 <bread>
    8000458e:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004590:	000aa583          	lw	a1,0(s5)
    80004594:	0289a503          	lw	a0,40(s3)
    80004598:	fffff097          	auipc	ra,0xfffff
    8000459c:	f0c080e7          	jalr	-244(ra) # 800034a4 <bread>
    800045a0:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800045a2:	40000613          	li	a2,1024
    800045a6:	05890593          	addi	a1,s2,88
    800045aa:	05850513          	addi	a0,a0,88
    800045ae:	ffffc097          	auipc	ra,0xffffc
    800045b2:	798080e7          	jalr	1944(ra) # 80000d46 <memmove>
    bwrite(dbuf);  // write dst to disk
    800045b6:	8526                	mv	a0,s1
    800045b8:	fffff097          	auipc	ra,0xfffff
    800045bc:	fde080e7          	jalr	-34(ra) # 80003596 <bwrite>
    if(recovering == 0)
    800045c0:	f80b1ce3          	bnez	s6,80004558 <install_trans+0x40>
    800045c4:	b769                	j	8000454e <install_trans+0x36>
}
    800045c6:	70e2                	ld	ra,56(sp)
    800045c8:	7442                	ld	s0,48(sp)
    800045ca:	74a2                	ld	s1,40(sp)
    800045cc:	7902                	ld	s2,32(sp)
    800045ce:	69e2                	ld	s3,24(sp)
    800045d0:	6a42                	ld	s4,16(sp)
    800045d2:	6aa2                	ld	s5,8(sp)
    800045d4:	6b02                	ld	s6,0(sp)
    800045d6:	6121                	addi	sp,sp,64
    800045d8:	8082                	ret
    800045da:	8082                	ret

00000000800045dc <initlog>:
{
    800045dc:	7179                	addi	sp,sp,-48
    800045de:	f406                	sd	ra,40(sp)
    800045e0:	f022                	sd	s0,32(sp)
    800045e2:	ec26                	sd	s1,24(sp)
    800045e4:	e84a                	sd	s2,16(sp)
    800045e6:	e44e                	sd	s3,8(sp)
    800045e8:	1800                	addi	s0,sp,48
    800045ea:	892a                	mv	s2,a0
    800045ec:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800045ee:	0001e497          	auipc	s1,0x1e
    800045f2:	5f248493          	addi	s1,s1,1522 # 80022be0 <log>
    800045f6:	00004597          	auipc	a1,0x4
    800045fa:	20a58593          	addi	a1,a1,522 # 80008800 <syscallnum+0x198>
    800045fe:	8526                	mv	a0,s1
    80004600:	ffffc097          	auipc	ra,0xffffc
    80004604:	55a080e7          	jalr	1370(ra) # 80000b5a <initlock>
  log.start = sb->logstart;
    80004608:	0149a583          	lw	a1,20(s3)
    8000460c:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000460e:	0109a783          	lw	a5,16(s3)
    80004612:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004614:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004618:	854a                	mv	a0,s2
    8000461a:	fffff097          	auipc	ra,0xfffff
    8000461e:	e8a080e7          	jalr	-374(ra) # 800034a4 <bread>
  log.lh.n = lh->n;
    80004622:	4d3c                	lw	a5,88(a0)
    80004624:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004626:	02f05563          	blez	a5,80004650 <initlog+0x74>
    8000462a:	05c50713          	addi	a4,a0,92
    8000462e:	0001e697          	auipc	a3,0x1e
    80004632:	5e268693          	addi	a3,a3,1506 # 80022c10 <log+0x30>
    80004636:	37fd                	addiw	a5,a5,-1
    80004638:	1782                	slli	a5,a5,0x20
    8000463a:	9381                	srli	a5,a5,0x20
    8000463c:	078a                	slli	a5,a5,0x2
    8000463e:	06050613          	addi	a2,a0,96
    80004642:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80004644:	4310                	lw	a2,0(a4)
    80004646:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80004648:	0711                	addi	a4,a4,4
    8000464a:	0691                	addi	a3,a3,4
    8000464c:	fef71ce3          	bne	a4,a5,80004644 <initlog+0x68>
  brelse(buf);
    80004650:	fffff097          	auipc	ra,0xfffff
    80004654:	f84080e7          	jalr	-124(ra) # 800035d4 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004658:	4505                	li	a0,1
    8000465a:	00000097          	auipc	ra,0x0
    8000465e:	ebe080e7          	jalr	-322(ra) # 80004518 <install_trans>
  log.lh.n = 0;
    80004662:	0001e797          	auipc	a5,0x1e
    80004666:	5a07a523          	sw	zero,1450(a5) # 80022c0c <log+0x2c>
  write_head(); // clear the log
    8000466a:	00000097          	auipc	ra,0x0
    8000466e:	e34080e7          	jalr	-460(ra) # 8000449e <write_head>
}
    80004672:	70a2                	ld	ra,40(sp)
    80004674:	7402                	ld	s0,32(sp)
    80004676:	64e2                	ld	s1,24(sp)
    80004678:	6942                	ld	s2,16(sp)
    8000467a:	69a2                	ld	s3,8(sp)
    8000467c:	6145                	addi	sp,sp,48
    8000467e:	8082                	ret

0000000080004680 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004680:	1101                	addi	sp,sp,-32
    80004682:	ec06                	sd	ra,24(sp)
    80004684:	e822                	sd	s0,16(sp)
    80004686:	e426                	sd	s1,8(sp)
    80004688:	e04a                	sd	s2,0(sp)
    8000468a:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000468c:	0001e517          	auipc	a0,0x1e
    80004690:	55450513          	addi	a0,a0,1364 # 80022be0 <log>
    80004694:	ffffc097          	auipc	ra,0xffffc
    80004698:	556080e7          	jalr	1366(ra) # 80000bea <acquire>
  while(1){
    if(log.committing){
    8000469c:	0001e497          	auipc	s1,0x1e
    800046a0:	54448493          	addi	s1,s1,1348 # 80022be0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800046a4:	4979                	li	s2,30
    800046a6:	a039                	j	800046b4 <begin_op+0x34>
      sleep(&log, &log.lock);
    800046a8:	85a6                	mv	a1,s1
    800046aa:	8526                	mv	a0,s1
    800046ac:	ffffe097          	auipc	ra,0xffffe
    800046b0:	b5c080e7          	jalr	-1188(ra) # 80002208 <sleep>
    if(log.committing){
    800046b4:	50dc                	lw	a5,36(s1)
    800046b6:	fbed                	bnez	a5,800046a8 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800046b8:	509c                	lw	a5,32(s1)
    800046ba:	0017871b          	addiw	a4,a5,1
    800046be:	0007069b          	sext.w	a3,a4
    800046c2:	0027179b          	slliw	a5,a4,0x2
    800046c6:	9fb9                	addw	a5,a5,a4
    800046c8:	0017979b          	slliw	a5,a5,0x1
    800046cc:	54d8                	lw	a4,44(s1)
    800046ce:	9fb9                	addw	a5,a5,a4
    800046d0:	00f95963          	bge	s2,a5,800046e2 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800046d4:	85a6                	mv	a1,s1
    800046d6:	8526                	mv	a0,s1
    800046d8:	ffffe097          	auipc	ra,0xffffe
    800046dc:	b30080e7          	jalr	-1232(ra) # 80002208 <sleep>
    800046e0:	bfd1                	j	800046b4 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800046e2:	0001e517          	auipc	a0,0x1e
    800046e6:	4fe50513          	addi	a0,a0,1278 # 80022be0 <log>
    800046ea:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800046ec:	ffffc097          	auipc	ra,0xffffc
    800046f0:	5b2080e7          	jalr	1458(ra) # 80000c9e <release>
      break;
    }
  }
}
    800046f4:	60e2                	ld	ra,24(sp)
    800046f6:	6442                	ld	s0,16(sp)
    800046f8:	64a2                	ld	s1,8(sp)
    800046fa:	6902                	ld	s2,0(sp)
    800046fc:	6105                	addi	sp,sp,32
    800046fe:	8082                	ret

0000000080004700 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004700:	7139                	addi	sp,sp,-64
    80004702:	fc06                	sd	ra,56(sp)
    80004704:	f822                	sd	s0,48(sp)
    80004706:	f426                	sd	s1,40(sp)
    80004708:	f04a                	sd	s2,32(sp)
    8000470a:	ec4e                	sd	s3,24(sp)
    8000470c:	e852                	sd	s4,16(sp)
    8000470e:	e456                	sd	s5,8(sp)
    80004710:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004712:	0001e497          	auipc	s1,0x1e
    80004716:	4ce48493          	addi	s1,s1,1230 # 80022be0 <log>
    8000471a:	8526                	mv	a0,s1
    8000471c:	ffffc097          	auipc	ra,0xffffc
    80004720:	4ce080e7          	jalr	1230(ra) # 80000bea <acquire>
  log.outstanding -= 1;
    80004724:	509c                	lw	a5,32(s1)
    80004726:	37fd                	addiw	a5,a5,-1
    80004728:	0007891b          	sext.w	s2,a5
    8000472c:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000472e:	50dc                	lw	a5,36(s1)
    80004730:	efb9                	bnez	a5,8000478e <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004732:	06091663          	bnez	s2,8000479e <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    80004736:	0001e497          	auipc	s1,0x1e
    8000473a:	4aa48493          	addi	s1,s1,1194 # 80022be0 <log>
    8000473e:	4785                	li	a5,1
    80004740:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004742:	8526                	mv	a0,s1
    80004744:	ffffc097          	auipc	ra,0xffffc
    80004748:	55a080e7          	jalr	1370(ra) # 80000c9e <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000474c:	54dc                	lw	a5,44(s1)
    8000474e:	06f04763          	bgtz	a5,800047bc <end_op+0xbc>
    acquire(&log.lock);
    80004752:	0001e497          	auipc	s1,0x1e
    80004756:	48e48493          	addi	s1,s1,1166 # 80022be0 <log>
    8000475a:	8526                	mv	a0,s1
    8000475c:	ffffc097          	auipc	ra,0xffffc
    80004760:	48e080e7          	jalr	1166(ra) # 80000bea <acquire>
    log.committing = 0;
    80004764:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004768:	8526                	mv	a0,s1
    8000476a:	ffffe097          	auipc	ra,0xffffe
    8000476e:	c4e080e7          	jalr	-946(ra) # 800023b8 <wakeup>
    release(&log.lock);
    80004772:	8526                	mv	a0,s1
    80004774:	ffffc097          	auipc	ra,0xffffc
    80004778:	52a080e7          	jalr	1322(ra) # 80000c9e <release>
}
    8000477c:	70e2                	ld	ra,56(sp)
    8000477e:	7442                	ld	s0,48(sp)
    80004780:	74a2                	ld	s1,40(sp)
    80004782:	7902                	ld	s2,32(sp)
    80004784:	69e2                	ld	s3,24(sp)
    80004786:	6a42                	ld	s4,16(sp)
    80004788:	6aa2                	ld	s5,8(sp)
    8000478a:	6121                	addi	sp,sp,64
    8000478c:	8082                	ret
    panic("log.committing");
    8000478e:	00004517          	auipc	a0,0x4
    80004792:	07a50513          	addi	a0,a0,122 # 80008808 <syscallnum+0x1a0>
    80004796:	ffffc097          	auipc	ra,0xffffc
    8000479a:	dae080e7          	jalr	-594(ra) # 80000544 <panic>
    wakeup(&log);
    8000479e:	0001e497          	auipc	s1,0x1e
    800047a2:	44248493          	addi	s1,s1,1090 # 80022be0 <log>
    800047a6:	8526                	mv	a0,s1
    800047a8:	ffffe097          	auipc	ra,0xffffe
    800047ac:	c10080e7          	jalr	-1008(ra) # 800023b8 <wakeup>
  release(&log.lock);
    800047b0:	8526                	mv	a0,s1
    800047b2:	ffffc097          	auipc	ra,0xffffc
    800047b6:	4ec080e7          	jalr	1260(ra) # 80000c9e <release>
  if(do_commit){
    800047ba:	b7c9                	j	8000477c <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800047bc:	0001ea97          	auipc	s5,0x1e
    800047c0:	454a8a93          	addi	s5,s5,1108 # 80022c10 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800047c4:	0001ea17          	auipc	s4,0x1e
    800047c8:	41ca0a13          	addi	s4,s4,1052 # 80022be0 <log>
    800047cc:	018a2583          	lw	a1,24(s4)
    800047d0:	012585bb          	addw	a1,a1,s2
    800047d4:	2585                	addiw	a1,a1,1
    800047d6:	028a2503          	lw	a0,40(s4)
    800047da:	fffff097          	auipc	ra,0xfffff
    800047de:	cca080e7          	jalr	-822(ra) # 800034a4 <bread>
    800047e2:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800047e4:	000aa583          	lw	a1,0(s5)
    800047e8:	028a2503          	lw	a0,40(s4)
    800047ec:	fffff097          	auipc	ra,0xfffff
    800047f0:	cb8080e7          	jalr	-840(ra) # 800034a4 <bread>
    800047f4:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800047f6:	40000613          	li	a2,1024
    800047fa:	05850593          	addi	a1,a0,88
    800047fe:	05848513          	addi	a0,s1,88
    80004802:	ffffc097          	auipc	ra,0xffffc
    80004806:	544080e7          	jalr	1348(ra) # 80000d46 <memmove>
    bwrite(to);  // write the log
    8000480a:	8526                	mv	a0,s1
    8000480c:	fffff097          	auipc	ra,0xfffff
    80004810:	d8a080e7          	jalr	-630(ra) # 80003596 <bwrite>
    brelse(from);
    80004814:	854e                	mv	a0,s3
    80004816:	fffff097          	auipc	ra,0xfffff
    8000481a:	dbe080e7          	jalr	-578(ra) # 800035d4 <brelse>
    brelse(to);
    8000481e:	8526                	mv	a0,s1
    80004820:	fffff097          	auipc	ra,0xfffff
    80004824:	db4080e7          	jalr	-588(ra) # 800035d4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004828:	2905                	addiw	s2,s2,1
    8000482a:	0a91                	addi	s5,s5,4
    8000482c:	02ca2783          	lw	a5,44(s4)
    80004830:	f8f94ee3          	blt	s2,a5,800047cc <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004834:	00000097          	auipc	ra,0x0
    80004838:	c6a080e7          	jalr	-918(ra) # 8000449e <write_head>
    install_trans(0); // Now install writes to home locations
    8000483c:	4501                	li	a0,0
    8000483e:	00000097          	auipc	ra,0x0
    80004842:	cda080e7          	jalr	-806(ra) # 80004518 <install_trans>
    log.lh.n = 0;
    80004846:	0001e797          	auipc	a5,0x1e
    8000484a:	3c07a323          	sw	zero,966(a5) # 80022c0c <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000484e:	00000097          	auipc	ra,0x0
    80004852:	c50080e7          	jalr	-944(ra) # 8000449e <write_head>
    80004856:	bdf5                	j	80004752 <end_op+0x52>

0000000080004858 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004858:	1101                	addi	sp,sp,-32
    8000485a:	ec06                	sd	ra,24(sp)
    8000485c:	e822                	sd	s0,16(sp)
    8000485e:	e426                	sd	s1,8(sp)
    80004860:	e04a                	sd	s2,0(sp)
    80004862:	1000                	addi	s0,sp,32
    80004864:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004866:	0001e917          	auipc	s2,0x1e
    8000486a:	37a90913          	addi	s2,s2,890 # 80022be0 <log>
    8000486e:	854a                	mv	a0,s2
    80004870:	ffffc097          	auipc	ra,0xffffc
    80004874:	37a080e7          	jalr	890(ra) # 80000bea <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004878:	02c92603          	lw	a2,44(s2)
    8000487c:	47f5                	li	a5,29
    8000487e:	06c7c563          	blt	a5,a2,800048e8 <log_write+0x90>
    80004882:	0001e797          	auipc	a5,0x1e
    80004886:	37a7a783          	lw	a5,890(a5) # 80022bfc <log+0x1c>
    8000488a:	37fd                	addiw	a5,a5,-1
    8000488c:	04f65e63          	bge	a2,a5,800048e8 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004890:	0001e797          	auipc	a5,0x1e
    80004894:	3707a783          	lw	a5,880(a5) # 80022c00 <log+0x20>
    80004898:	06f05063          	blez	a5,800048f8 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000489c:	4781                	li	a5,0
    8000489e:	06c05563          	blez	a2,80004908 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800048a2:	44cc                	lw	a1,12(s1)
    800048a4:	0001e717          	auipc	a4,0x1e
    800048a8:	36c70713          	addi	a4,a4,876 # 80022c10 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800048ac:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800048ae:	4314                	lw	a3,0(a4)
    800048b0:	04b68c63          	beq	a3,a1,80004908 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800048b4:	2785                	addiw	a5,a5,1
    800048b6:	0711                	addi	a4,a4,4
    800048b8:	fef61be3          	bne	a2,a5,800048ae <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800048bc:	0621                	addi	a2,a2,8
    800048be:	060a                	slli	a2,a2,0x2
    800048c0:	0001e797          	auipc	a5,0x1e
    800048c4:	32078793          	addi	a5,a5,800 # 80022be0 <log>
    800048c8:	963e                	add	a2,a2,a5
    800048ca:	44dc                	lw	a5,12(s1)
    800048cc:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800048ce:	8526                	mv	a0,s1
    800048d0:	fffff097          	auipc	ra,0xfffff
    800048d4:	da2080e7          	jalr	-606(ra) # 80003672 <bpin>
    log.lh.n++;
    800048d8:	0001e717          	auipc	a4,0x1e
    800048dc:	30870713          	addi	a4,a4,776 # 80022be0 <log>
    800048e0:	575c                	lw	a5,44(a4)
    800048e2:	2785                	addiw	a5,a5,1
    800048e4:	d75c                	sw	a5,44(a4)
    800048e6:	a835                	j	80004922 <log_write+0xca>
    panic("too big a transaction");
    800048e8:	00004517          	auipc	a0,0x4
    800048ec:	f3050513          	addi	a0,a0,-208 # 80008818 <syscallnum+0x1b0>
    800048f0:	ffffc097          	auipc	ra,0xffffc
    800048f4:	c54080e7          	jalr	-940(ra) # 80000544 <panic>
    panic("log_write outside of trans");
    800048f8:	00004517          	auipc	a0,0x4
    800048fc:	f3850513          	addi	a0,a0,-200 # 80008830 <syscallnum+0x1c8>
    80004900:	ffffc097          	auipc	ra,0xffffc
    80004904:	c44080e7          	jalr	-956(ra) # 80000544 <panic>
  log.lh.block[i] = b->blockno;
    80004908:	00878713          	addi	a4,a5,8
    8000490c:	00271693          	slli	a3,a4,0x2
    80004910:	0001e717          	auipc	a4,0x1e
    80004914:	2d070713          	addi	a4,a4,720 # 80022be0 <log>
    80004918:	9736                	add	a4,a4,a3
    8000491a:	44d4                	lw	a3,12(s1)
    8000491c:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000491e:	faf608e3          	beq	a2,a5,800048ce <log_write+0x76>
  }
  release(&log.lock);
    80004922:	0001e517          	auipc	a0,0x1e
    80004926:	2be50513          	addi	a0,a0,702 # 80022be0 <log>
    8000492a:	ffffc097          	auipc	ra,0xffffc
    8000492e:	374080e7          	jalr	884(ra) # 80000c9e <release>
}
    80004932:	60e2                	ld	ra,24(sp)
    80004934:	6442                	ld	s0,16(sp)
    80004936:	64a2                	ld	s1,8(sp)
    80004938:	6902                	ld	s2,0(sp)
    8000493a:	6105                	addi	sp,sp,32
    8000493c:	8082                	ret

000000008000493e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000493e:	1101                	addi	sp,sp,-32
    80004940:	ec06                	sd	ra,24(sp)
    80004942:	e822                	sd	s0,16(sp)
    80004944:	e426                	sd	s1,8(sp)
    80004946:	e04a                	sd	s2,0(sp)
    80004948:	1000                	addi	s0,sp,32
    8000494a:	84aa                	mv	s1,a0
    8000494c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000494e:	00004597          	auipc	a1,0x4
    80004952:	f0258593          	addi	a1,a1,-254 # 80008850 <syscallnum+0x1e8>
    80004956:	0521                	addi	a0,a0,8
    80004958:	ffffc097          	auipc	ra,0xffffc
    8000495c:	202080e7          	jalr	514(ra) # 80000b5a <initlock>
  lk->name = name;
    80004960:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004964:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004968:	0204a423          	sw	zero,40(s1)
}
    8000496c:	60e2                	ld	ra,24(sp)
    8000496e:	6442                	ld	s0,16(sp)
    80004970:	64a2                	ld	s1,8(sp)
    80004972:	6902                	ld	s2,0(sp)
    80004974:	6105                	addi	sp,sp,32
    80004976:	8082                	ret

0000000080004978 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004978:	1101                	addi	sp,sp,-32
    8000497a:	ec06                	sd	ra,24(sp)
    8000497c:	e822                	sd	s0,16(sp)
    8000497e:	e426                	sd	s1,8(sp)
    80004980:	e04a                	sd	s2,0(sp)
    80004982:	1000                	addi	s0,sp,32
    80004984:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004986:	00850913          	addi	s2,a0,8
    8000498a:	854a                	mv	a0,s2
    8000498c:	ffffc097          	auipc	ra,0xffffc
    80004990:	25e080e7          	jalr	606(ra) # 80000bea <acquire>
  while (lk->locked) {
    80004994:	409c                	lw	a5,0(s1)
    80004996:	cb89                	beqz	a5,800049a8 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004998:	85ca                	mv	a1,s2
    8000499a:	8526                	mv	a0,s1
    8000499c:	ffffe097          	auipc	ra,0xffffe
    800049a0:	86c080e7          	jalr	-1940(ra) # 80002208 <sleep>
  while (lk->locked) {
    800049a4:	409c                	lw	a5,0(s1)
    800049a6:	fbed                	bnez	a5,80004998 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800049a8:	4785                	li	a5,1
    800049aa:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800049ac:	ffffd097          	auipc	ra,0xffffd
    800049b0:	01a080e7          	jalr	26(ra) # 800019c6 <myproc>
    800049b4:	591c                	lw	a5,48(a0)
    800049b6:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800049b8:	854a                	mv	a0,s2
    800049ba:	ffffc097          	auipc	ra,0xffffc
    800049be:	2e4080e7          	jalr	740(ra) # 80000c9e <release>
}
    800049c2:	60e2                	ld	ra,24(sp)
    800049c4:	6442                	ld	s0,16(sp)
    800049c6:	64a2                	ld	s1,8(sp)
    800049c8:	6902                	ld	s2,0(sp)
    800049ca:	6105                	addi	sp,sp,32
    800049cc:	8082                	ret

00000000800049ce <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800049ce:	1101                	addi	sp,sp,-32
    800049d0:	ec06                	sd	ra,24(sp)
    800049d2:	e822                	sd	s0,16(sp)
    800049d4:	e426                	sd	s1,8(sp)
    800049d6:	e04a                	sd	s2,0(sp)
    800049d8:	1000                	addi	s0,sp,32
    800049da:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800049dc:	00850913          	addi	s2,a0,8
    800049e0:	854a                	mv	a0,s2
    800049e2:	ffffc097          	auipc	ra,0xffffc
    800049e6:	208080e7          	jalr	520(ra) # 80000bea <acquire>
  lk->locked = 0;
    800049ea:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800049ee:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800049f2:	8526                	mv	a0,s1
    800049f4:	ffffe097          	auipc	ra,0xffffe
    800049f8:	9c4080e7          	jalr	-1596(ra) # 800023b8 <wakeup>
  release(&lk->lk);
    800049fc:	854a                	mv	a0,s2
    800049fe:	ffffc097          	auipc	ra,0xffffc
    80004a02:	2a0080e7          	jalr	672(ra) # 80000c9e <release>
}
    80004a06:	60e2                	ld	ra,24(sp)
    80004a08:	6442                	ld	s0,16(sp)
    80004a0a:	64a2                	ld	s1,8(sp)
    80004a0c:	6902                	ld	s2,0(sp)
    80004a0e:	6105                	addi	sp,sp,32
    80004a10:	8082                	ret

0000000080004a12 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004a12:	7179                	addi	sp,sp,-48
    80004a14:	f406                	sd	ra,40(sp)
    80004a16:	f022                	sd	s0,32(sp)
    80004a18:	ec26                	sd	s1,24(sp)
    80004a1a:	e84a                	sd	s2,16(sp)
    80004a1c:	e44e                	sd	s3,8(sp)
    80004a1e:	1800                	addi	s0,sp,48
    80004a20:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004a22:	00850913          	addi	s2,a0,8
    80004a26:	854a                	mv	a0,s2
    80004a28:	ffffc097          	auipc	ra,0xffffc
    80004a2c:	1c2080e7          	jalr	450(ra) # 80000bea <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004a30:	409c                	lw	a5,0(s1)
    80004a32:	ef99                	bnez	a5,80004a50 <holdingsleep+0x3e>
    80004a34:	4481                	li	s1,0
  release(&lk->lk);
    80004a36:	854a                	mv	a0,s2
    80004a38:	ffffc097          	auipc	ra,0xffffc
    80004a3c:	266080e7          	jalr	614(ra) # 80000c9e <release>
  return r;
}
    80004a40:	8526                	mv	a0,s1
    80004a42:	70a2                	ld	ra,40(sp)
    80004a44:	7402                	ld	s0,32(sp)
    80004a46:	64e2                	ld	s1,24(sp)
    80004a48:	6942                	ld	s2,16(sp)
    80004a4a:	69a2                	ld	s3,8(sp)
    80004a4c:	6145                	addi	sp,sp,48
    80004a4e:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004a50:	0284a983          	lw	s3,40(s1)
    80004a54:	ffffd097          	auipc	ra,0xffffd
    80004a58:	f72080e7          	jalr	-142(ra) # 800019c6 <myproc>
    80004a5c:	5904                	lw	s1,48(a0)
    80004a5e:	413484b3          	sub	s1,s1,s3
    80004a62:	0014b493          	seqz	s1,s1
    80004a66:	bfc1                	j	80004a36 <holdingsleep+0x24>

0000000080004a68 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004a68:	1141                	addi	sp,sp,-16
    80004a6a:	e406                	sd	ra,8(sp)
    80004a6c:	e022                	sd	s0,0(sp)
    80004a6e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004a70:	00004597          	auipc	a1,0x4
    80004a74:	df058593          	addi	a1,a1,-528 # 80008860 <syscallnum+0x1f8>
    80004a78:	0001e517          	auipc	a0,0x1e
    80004a7c:	2b050513          	addi	a0,a0,688 # 80022d28 <ftable>
    80004a80:	ffffc097          	auipc	ra,0xffffc
    80004a84:	0da080e7          	jalr	218(ra) # 80000b5a <initlock>
}
    80004a88:	60a2                	ld	ra,8(sp)
    80004a8a:	6402                	ld	s0,0(sp)
    80004a8c:	0141                	addi	sp,sp,16
    80004a8e:	8082                	ret

0000000080004a90 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004a90:	1101                	addi	sp,sp,-32
    80004a92:	ec06                	sd	ra,24(sp)
    80004a94:	e822                	sd	s0,16(sp)
    80004a96:	e426                	sd	s1,8(sp)
    80004a98:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004a9a:	0001e517          	auipc	a0,0x1e
    80004a9e:	28e50513          	addi	a0,a0,654 # 80022d28 <ftable>
    80004aa2:	ffffc097          	auipc	ra,0xffffc
    80004aa6:	148080e7          	jalr	328(ra) # 80000bea <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004aaa:	0001e497          	auipc	s1,0x1e
    80004aae:	29648493          	addi	s1,s1,662 # 80022d40 <ftable+0x18>
    80004ab2:	0001f717          	auipc	a4,0x1f
    80004ab6:	22e70713          	addi	a4,a4,558 # 80023ce0 <disk>
    if(f->ref == 0){
    80004aba:	40dc                	lw	a5,4(s1)
    80004abc:	cf99                	beqz	a5,80004ada <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004abe:	02848493          	addi	s1,s1,40
    80004ac2:	fee49ce3          	bne	s1,a4,80004aba <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004ac6:	0001e517          	auipc	a0,0x1e
    80004aca:	26250513          	addi	a0,a0,610 # 80022d28 <ftable>
    80004ace:	ffffc097          	auipc	ra,0xffffc
    80004ad2:	1d0080e7          	jalr	464(ra) # 80000c9e <release>
  return 0;
    80004ad6:	4481                	li	s1,0
    80004ad8:	a819                	j	80004aee <filealloc+0x5e>
      f->ref = 1;
    80004ada:	4785                	li	a5,1
    80004adc:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004ade:	0001e517          	auipc	a0,0x1e
    80004ae2:	24a50513          	addi	a0,a0,586 # 80022d28 <ftable>
    80004ae6:	ffffc097          	auipc	ra,0xffffc
    80004aea:	1b8080e7          	jalr	440(ra) # 80000c9e <release>
}
    80004aee:	8526                	mv	a0,s1
    80004af0:	60e2                	ld	ra,24(sp)
    80004af2:	6442                	ld	s0,16(sp)
    80004af4:	64a2                	ld	s1,8(sp)
    80004af6:	6105                	addi	sp,sp,32
    80004af8:	8082                	ret

0000000080004afa <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004afa:	1101                	addi	sp,sp,-32
    80004afc:	ec06                	sd	ra,24(sp)
    80004afe:	e822                	sd	s0,16(sp)
    80004b00:	e426                	sd	s1,8(sp)
    80004b02:	1000                	addi	s0,sp,32
    80004b04:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004b06:	0001e517          	auipc	a0,0x1e
    80004b0a:	22250513          	addi	a0,a0,546 # 80022d28 <ftable>
    80004b0e:	ffffc097          	auipc	ra,0xffffc
    80004b12:	0dc080e7          	jalr	220(ra) # 80000bea <acquire>
  if(f->ref < 1)
    80004b16:	40dc                	lw	a5,4(s1)
    80004b18:	02f05263          	blez	a5,80004b3c <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004b1c:	2785                	addiw	a5,a5,1
    80004b1e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004b20:	0001e517          	auipc	a0,0x1e
    80004b24:	20850513          	addi	a0,a0,520 # 80022d28 <ftable>
    80004b28:	ffffc097          	auipc	ra,0xffffc
    80004b2c:	176080e7          	jalr	374(ra) # 80000c9e <release>
  return f;
}
    80004b30:	8526                	mv	a0,s1
    80004b32:	60e2                	ld	ra,24(sp)
    80004b34:	6442                	ld	s0,16(sp)
    80004b36:	64a2                	ld	s1,8(sp)
    80004b38:	6105                	addi	sp,sp,32
    80004b3a:	8082                	ret
    panic("filedup");
    80004b3c:	00004517          	auipc	a0,0x4
    80004b40:	d2c50513          	addi	a0,a0,-724 # 80008868 <syscallnum+0x200>
    80004b44:	ffffc097          	auipc	ra,0xffffc
    80004b48:	a00080e7          	jalr	-1536(ra) # 80000544 <panic>

0000000080004b4c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004b4c:	7139                	addi	sp,sp,-64
    80004b4e:	fc06                	sd	ra,56(sp)
    80004b50:	f822                	sd	s0,48(sp)
    80004b52:	f426                	sd	s1,40(sp)
    80004b54:	f04a                	sd	s2,32(sp)
    80004b56:	ec4e                	sd	s3,24(sp)
    80004b58:	e852                	sd	s4,16(sp)
    80004b5a:	e456                	sd	s5,8(sp)
    80004b5c:	0080                	addi	s0,sp,64
    80004b5e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004b60:	0001e517          	auipc	a0,0x1e
    80004b64:	1c850513          	addi	a0,a0,456 # 80022d28 <ftable>
    80004b68:	ffffc097          	auipc	ra,0xffffc
    80004b6c:	082080e7          	jalr	130(ra) # 80000bea <acquire>
  if(f->ref < 1)
    80004b70:	40dc                	lw	a5,4(s1)
    80004b72:	06f05163          	blez	a5,80004bd4 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004b76:	37fd                	addiw	a5,a5,-1
    80004b78:	0007871b          	sext.w	a4,a5
    80004b7c:	c0dc                	sw	a5,4(s1)
    80004b7e:	06e04363          	bgtz	a4,80004be4 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004b82:	0004a903          	lw	s2,0(s1)
    80004b86:	0094ca83          	lbu	s5,9(s1)
    80004b8a:	0104ba03          	ld	s4,16(s1)
    80004b8e:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004b92:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004b96:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004b9a:	0001e517          	auipc	a0,0x1e
    80004b9e:	18e50513          	addi	a0,a0,398 # 80022d28 <ftable>
    80004ba2:	ffffc097          	auipc	ra,0xffffc
    80004ba6:	0fc080e7          	jalr	252(ra) # 80000c9e <release>

  if(ff.type == FD_PIPE){
    80004baa:	4785                	li	a5,1
    80004bac:	04f90d63          	beq	s2,a5,80004c06 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004bb0:	3979                	addiw	s2,s2,-2
    80004bb2:	4785                	li	a5,1
    80004bb4:	0527e063          	bltu	a5,s2,80004bf4 <fileclose+0xa8>
    begin_op();
    80004bb8:	00000097          	auipc	ra,0x0
    80004bbc:	ac8080e7          	jalr	-1336(ra) # 80004680 <begin_op>
    iput(ff.ip);
    80004bc0:	854e                	mv	a0,s3
    80004bc2:	fffff097          	auipc	ra,0xfffff
    80004bc6:	2b6080e7          	jalr	694(ra) # 80003e78 <iput>
    end_op();
    80004bca:	00000097          	auipc	ra,0x0
    80004bce:	b36080e7          	jalr	-1226(ra) # 80004700 <end_op>
    80004bd2:	a00d                	j	80004bf4 <fileclose+0xa8>
    panic("fileclose");
    80004bd4:	00004517          	auipc	a0,0x4
    80004bd8:	c9c50513          	addi	a0,a0,-868 # 80008870 <syscallnum+0x208>
    80004bdc:	ffffc097          	auipc	ra,0xffffc
    80004be0:	968080e7          	jalr	-1688(ra) # 80000544 <panic>
    release(&ftable.lock);
    80004be4:	0001e517          	auipc	a0,0x1e
    80004be8:	14450513          	addi	a0,a0,324 # 80022d28 <ftable>
    80004bec:	ffffc097          	auipc	ra,0xffffc
    80004bf0:	0b2080e7          	jalr	178(ra) # 80000c9e <release>
  }
}
    80004bf4:	70e2                	ld	ra,56(sp)
    80004bf6:	7442                	ld	s0,48(sp)
    80004bf8:	74a2                	ld	s1,40(sp)
    80004bfa:	7902                	ld	s2,32(sp)
    80004bfc:	69e2                	ld	s3,24(sp)
    80004bfe:	6a42                	ld	s4,16(sp)
    80004c00:	6aa2                	ld	s5,8(sp)
    80004c02:	6121                	addi	sp,sp,64
    80004c04:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004c06:	85d6                	mv	a1,s5
    80004c08:	8552                	mv	a0,s4
    80004c0a:	00000097          	auipc	ra,0x0
    80004c0e:	34c080e7          	jalr	844(ra) # 80004f56 <pipeclose>
    80004c12:	b7cd                	j	80004bf4 <fileclose+0xa8>

0000000080004c14 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004c14:	715d                	addi	sp,sp,-80
    80004c16:	e486                	sd	ra,72(sp)
    80004c18:	e0a2                	sd	s0,64(sp)
    80004c1a:	fc26                	sd	s1,56(sp)
    80004c1c:	f84a                	sd	s2,48(sp)
    80004c1e:	f44e                	sd	s3,40(sp)
    80004c20:	0880                	addi	s0,sp,80
    80004c22:	84aa                	mv	s1,a0
    80004c24:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004c26:	ffffd097          	auipc	ra,0xffffd
    80004c2a:	da0080e7          	jalr	-608(ra) # 800019c6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004c2e:	409c                	lw	a5,0(s1)
    80004c30:	37f9                	addiw	a5,a5,-2
    80004c32:	4705                	li	a4,1
    80004c34:	04f76763          	bltu	a4,a5,80004c82 <filestat+0x6e>
    80004c38:	892a                	mv	s2,a0
    ilock(f->ip);
    80004c3a:	6c88                	ld	a0,24(s1)
    80004c3c:	fffff097          	auipc	ra,0xfffff
    80004c40:	082080e7          	jalr	130(ra) # 80003cbe <ilock>
    stati(f->ip, &st);
    80004c44:	fb840593          	addi	a1,s0,-72
    80004c48:	6c88                	ld	a0,24(s1)
    80004c4a:	fffff097          	auipc	ra,0xfffff
    80004c4e:	2fe080e7          	jalr	766(ra) # 80003f48 <stati>
    iunlock(f->ip);
    80004c52:	6c88                	ld	a0,24(s1)
    80004c54:	fffff097          	auipc	ra,0xfffff
    80004c58:	12c080e7          	jalr	300(ra) # 80003d80 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004c5c:	46e1                	li	a3,24
    80004c5e:	fb840613          	addi	a2,s0,-72
    80004c62:	85ce                	mv	a1,s3
    80004c64:	05093503          	ld	a0,80(s2)
    80004c68:	ffffd097          	auipc	ra,0xffffd
    80004c6c:	a1c080e7          	jalr	-1508(ra) # 80001684 <copyout>
    80004c70:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004c74:	60a6                	ld	ra,72(sp)
    80004c76:	6406                	ld	s0,64(sp)
    80004c78:	74e2                	ld	s1,56(sp)
    80004c7a:	7942                	ld	s2,48(sp)
    80004c7c:	79a2                	ld	s3,40(sp)
    80004c7e:	6161                	addi	sp,sp,80
    80004c80:	8082                	ret
  return -1;
    80004c82:	557d                	li	a0,-1
    80004c84:	bfc5                	j	80004c74 <filestat+0x60>

0000000080004c86 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004c86:	7179                	addi	sp,sp,-48
    80004c88:	f406                	sd	ra,40(sp)
    80004c8a:	f022                	sd	s0,32(sp)
    80004c8c:	ec26                	sd	s1,24(sp)
    80004c8e:	e84a                	sd	s2,16(sp)
    80004c90:	e44e                	sd	s3,8(sp)
    80004c92:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004c94:	00854783          	lbu	a5,8(a0)
    80004c98:	c3d5                	beqz	a5,80004d3c <fileread+0xb6>
    80004c9a:	84aa                	mv	s1,a0
    80004c9c:	89ae                	mv	s3,a1
    80004c9e:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004ca0:	411c                	lw	a5,0(a0)
    80004ca2:	4705                	li	a4,1
    80004ca4:	04e78963          	beq	a5,a4,80004cf6 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004ca8:	470d                	li	a4,3
    80004caa:	04e78d63          	beq	a5,a4,80004d04 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004cae:	4709                	li	a4,2
    80004cb0:	06e79e63          	bne	a5,a4,80004d2c <fileread+0xa6>
    ilock(f->ip);
    80004cb4:	6d08                	ld	a0,24(a0)
    80004cb6:	fffff097          	auipc	ra,0xfffff
    80004cba:	008080e7          	jalr	8(ra) # 80003cbe <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004cbe:	874a                	mv	a4,s2
    80004cc0:	5094                	lw	a3,32(s1)
    80004cc2:	864e                	mv	a2,s3
    80004cc4:	4585                	li	a1,1
    80004cc6:	6c88                	ld	a0,24(s1)
    80004cc8:	fffff097          	auipc	ra,0xfffff
    80004ccc:	2aa080e7          	jalr	682(ra) # 80003f72 <readi>
    80004cd0:	892a                	mv	s2,a0
    80004cd2:	00a05563          	blez	a0,80004cdc <fileread+0x56>
      f->off += r;
    80004cd6:	509c                	lw	a5,32(s1)
    80004cd8:	9fa9                	addw	a5,a5,a0
    80004cda:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004cdc:	6c88                	ld	a0,24(s1)
    80004cde:	fffff097          	auipc	ra,0xfffff
    80004ce2:	0a2080e7          	jalr	162(ra) # 80003d80 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004ce6:	854a                	mv	a0,s2
    80004ce8:	70a2                	ld	ra,40(sp)
    80004cea:	7402                	ld	s0,32(sp)
    80004cec:	64e2                	ld	s1,24(sp)
    80004cee:	6942                	ld	s2,16(sp)
    80004cf0:	69a2                	ld	s3,8(sp)
    80004cf2:	6145                	addi	sp,sp,48
    80004cf4:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004cf6:	6908                	ld	a0,16(a0)
    80004cf8:	00000097          	auipc	ra,0x0
    80004cfc:	3ce080e7          	jalr	974(ra) # 800050c6 <piperead>
    80004d00:	892a                	mv	s2,a0
    80004d02:	b7d5                	j	80004ce6 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004d04:	02451783          	lh	a5,36(a0)
    80004d08:	03079693          	slli	a3,a5,0x30
    80004d0c:	92c1                	srli	a3,a3,0x30
    80004d0e:	4725                	li	a4,9
    80004d10:	02d76863          	bltu	a4,a3,80004d40 <fileread+0xba>
    80004d14:	0792                	slli	a5,a5,0x4
    80004d16:	0001e717          	auipc	a4,0x1e
    80004d1a:	f7270713          	addi	a4,a4,-142 # 80022c88 <devsw>
    80004d1e:	97ba                	add	a5,a5,a4
    80004d20:	639c                	ld	a5,0(a5)
    80004d22:	c38d                	beqz	a5,80004d44 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004d24:	4505                	li	a0,1
    80004d26:	9782                	jalr	a5
    80004d28:	892a                	mv	s2,a0
    80004d2a:	bf75                	j	80004ce6 <fileread+0x60>
    panic("fileread");
    80004d2c:	00004517          	auipc	a0,0x4
    80004d30:	b5450513          	addi	a0,a0,-1196 # 80008880 <syscallnum+0x218>
    80004d34:	ffffc097          	auipc	ra,0xffffc
    80004d38:	810080e7          	jalr	-2032(ra) # 80000544 <panic>
    return -1;
    80004d3c:	597d                	li	s2,-1
    80004d3e:	b765                	j	80004ce6 <fileread+0x60>
      return -1;
    80004d40:	597d                	li	s2,-1
    80004d42:	b755                	j	80004ce6 <fileread+0x60>
    80004d44:	597d                	li	s2,-1
    80004d46:	b745                	j	80004ce6 <fileread+0x60>

0000000080004d48 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004d48:	715d                	addi	sp,sp,-80
    80004d4a:	e486                	sd	ra,72(sp)
    80004d4c:	e0a2                	sd	s0,64(sp)
    80004d4e:	fc26                	sd	s1,56(sp)
    80004d50:	f84a                	sd	s2,48(sp)
    80004d52:	f44e                	sd	s3,40(sp)
    80004d54:	f052                	sd	s4,32(sp)
    80004d56:	ec56                	sd	s5,24(sp)
    80004d58:	e85a                	sd	s6,16(sp)
    80004d5a:	e45e                	sd	s7,8(sp)
    80004d5c:	e062                	sd	s8,0(sp)
    80004d5e:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004d60:	00954783          	lbu	a5,9(a0)
    80004d64:	10078663          	beqz	a5,80004e70 <filewrite+0x128>
    80004d68:	892a                	mv	s2,a0
    80004d6a:	8aae                	mv	s5,a1
    80004d6c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004d6e:	411c                	lw	a5,0(a0)
    80004d70:	4705                	li	a4,1
    80004d72:	02e78263          	beq	a5,a4,80004d96 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004d76:	470d                	li	a4,3
    80004d78:	02e78663          	beq	a5,a4,80004da4 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004d7c:	4709                	li	a4,2
    80004d7e:	0ee79163          	bne	a5,a4,80004e60 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004d82:	0ac05d63          	blez	a2,80004e3c <filewrite+0xf4>
    int i = 0;
    80004d86:	4981                	li	s3,0
    80004d88:	6b05                	lui	s6,0x1
    80004d8a:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004d8e:	6b85                	lui	s7,0x1
    80004d90:	c00b8b9b          	addiw	s7,s7,-1024
    80004d94:	a861                	j	80004e2c <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004d96:	6908                	ld	a0,16(a0)
    80004d98:	00000097          	auipc	ra,0x0
    80004d9c:	22e080e7          	jalr	558(ra) # 80004fc6 <pipewrite>
    80004da0:	8a2a                	mv	s4,a0
    80004da2:	a045                	j	80004e42 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004da4:	02451783          	lh	a5,36(a0)
    80004da8:	03079693          	slli	a3,a5,0x30
    80004dac:	92c1                	srli	a3,a3,0x30
    80004dae:	4725                	li	a4,9
    80004db0:	0cd76263          	bltu	a4,a3,80004e74 <filewrite+0x12c>
    80004db4:	0792                	slli	a5,a5,0x4
    80004db6:	0001e717          	auipc	a4,0x1e
    80004dba:	ed270713          	addi	a4,a4,-302 # 80022c88 <devsw>
    80004dbe:	97ba                	add	a5,a5,a4
    80004dc0:	679c                	ld	a5,8(a5)
    80004dc2:	cbdd                	beqz	a5,80004e78 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004dc4:	4505                	li	a0,1
    80004dc6:	9782                	jalr	a5
    80004dc8:	8a2a                	mv	s4,a0
    80004dca:	a8a5                	j	80004e42 <filewrite+0xfa>
    80004dcc:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004dd0:	00000097          	auipc	ra,0x0
    80004dd4:	8b0080e7          	jalr	-1872(ra) # 80004680 <begin_op>
      ilock(f->ip);
    80004dd8:	01893503          	ld	a0,24(s2)
    80004ddc:	fffff097          	auipc	ra,0xfffff
    80004de0:	ee2080e7          	jalr	-286(ra) # 80003cbe <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004de4:	8762                	mv	a4,s8
    80004de6:	02092683          	lw	a3,32(s2)
    80004dea:	01598633          	add	a2,s3,s5
    80004dee:	4585                	li	a1,1
    80004df0:	01893503          	ld	a0,24(s2)
    80004df4:	fffff097          	auipc	ra,0xfffff
    80004df8:	276080e7          	jalr	630(ra) # 8000406a <writei>
    80004dfc:	84aa                	mv	s1,a0
    80004dfe:	00a05763          	blez	a0,80004e0c <filewrite+0xc4>
        f->off += r;
    80004e02:	02092783          	lw	a5,32(s2)
    80004e06:	9fa9                	addw	a5,a5,a0
    80004e08:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004e0c:	01893503          	ld	a0,24(s2)
    80004e10:	fffff097          	auipc	ra,0xfffff
    80004e14:	f70080e7          	jalr	-144(ra) # 80003d80 <iunlock>
      end_op();
    80004e18:	00000097          	auipc	ra,0x0
    80004e1c:	8e8080e7          	jalr	-1816(ra) # 80004700 <end_op>

      if(r != n1){
    80004e20:	009c1f63          	bne	s8,s1,80004e3e <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004e24:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004e28:	0149db63          	bge	s3,s4,80004e3e <filewrite+0xf6>
      int n1 = n - i;
    80004e2c:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004e30:	84be                	mv	s1,a5
    80004e32:	2781                	sext.w	a5,a5
    80004e34:	f8fb5ce3          	bge	s6,a5,80004dcc <filewrite+0x84>
    80004e38:	84de                	mv	s1,s7
    80004e3a:	bf49                	j	80004dcc <filewrite+0x84>
    int i = 0;
    80004e3c:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004e3e:	013a1f63          	bne	s4,s3,80004e5c <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004e42:	8552                	mv	a0,s4
    80004e44:	60a6                	ld	ra,72(sp)
    80004e46:	6406                	ld	s0,64(sp)
    80004e48:	74e2                	ld	s1,56(sp)
    80004e4a:	7942                	ld	s2,48(sp)
    80004e4c:	79a2                	ld	s3,40(sp)
    80004e4e:	7a02                	ld	s4,32(sp)
    80004e50:	6ae2                	ld	s5,24(sp)
    80004e52:	6b42                	ld	s6,16(sp)
    80004e54:	6ba2                	ld	s7,8(sp)
    80004e56:	6c02                	ld	s8,0(sp)
    80004e58:	6161                	addi	sp,sp,80
    80004e5a:	8082                	ret
    ret = (i == n ? n : -1);
    80004e5c:	5a7d                	li	s4,-1
    80004e5e:	b7d5                	j	80004e42 <filewrite+0xfa>
    panic("filewrite");
    80004e60:	00004517          	auipc	a0,0x4
    80004e64:	a3050513          	addi	a0,a0,-1488 # 80008890 <syscallnum+0x228>
    80004e68:	ffffb097          	auipc	ra,0xffffb
    80004e6c:	6dc080e7          	jalr	1756(ra) # 80000544 <panic>
    return -1;
    80004e70:	5a7d                	li	s4,-1
    80004e72:	bfc1                	j	80004e42 <filewrite+0xfa>
      return -1;
    80004e74:	5a7d                	li	s4,-1
    80004e76:	b7f1                	j	80004e42 <filewrite+0xfa>
    80004e78:	5a7d                	li	s4,-1
    80004e7a:	b7e1                	j	80004e42 <filewrite+0xfa>

0000000080004e7c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004e7c:	7179                	addi	sp,sp,-48
    80004e7e:	f406                	sd	ra,40(sp)
    80004e80:	f022                	sd	s0,32(sp)
    80004e82:	ec26                	sd	s1,24(sp)
    80004e84:	e84a                	sd	s2,16(sp)
    80004e86:	e44e                	sd	s3,8(sp)
    80004e88:	e052                	sd	s4,0(sp)
    80004e8a:	1800                	addi	s0,sp,48
    80004e8c:	84aa                	mv	s1,a0
    80004e8e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004e90:	0005b023          	sd	zero,0(a1)
    80004e94:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004e98:	00000097          	auipc	ra,0x0
    80004e9c:	bf8080e7          	jalr	-1032(ra) # 80004a90 <filealloc>
    80004ea0:	e088                	sd	a0,0(s1)
    80004ea2:	c551                	beqz	a0,80004f2e <pipealloc+0xb2>
    80004ea4:	00000097          	auipc	ra,0x0
    80004ea8:	bec080e7          	jalr	-1044(ra) # 80004a90 <filealloc>
    80004eac:	00aa3023          	sd	a0,0(s4)
    80004eb0:	c92d                	beqz	a0,80004f22 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004eb2:	ffffc097          	auipc	ra,0xffffc
    80004eb6:	c48080e7          	jalr	-952(ra) # 80000afa <kalloc>
    80004eba:	892a                	mv	s2,a0
    80004ebc:	c125                	beqz	a0,80004f1c <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004ebe:	4985                	li	s3,1
    80004ec0:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004ec4:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004ec8:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004ecc:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004ed0:	00003597          	auipc	a1,0x3
    80004ed4:	5c858593          	addi	a1,a1,1480 # 80008498 <states.1788+0x1b8>
    80004ed8:	ffffc097          	auipc	ra,0xffffc
    80004edc:	c82080e7          	jalr	-894(ra) # 80000b5a <initlock>
  (*f0)->type = FD_PIPE;
    80004ee0:	609c                	ld	a5,0(s1)
    80004ee2:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004ee6:	609c                	ld	a5,0(s1)
    80004ee8:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004eec:	609c                	ld	a5,0(s1)
    80004eee:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004ef2:	609c                	ld	a5,0(s1)
    80004ef4:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004ef8:	000a3783          	ld	a5,0(s4)
    80004efc:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004f00:	000a3783          	ld	a5,0(s4)
    80004f04:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004f08:	000a3783          	ld	a5,0(s4)
    80004f0c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004f10:	000a3783          	ld	a5,0(s4)
    80004f14:	0127b823          	sd	s2,16(a5)
  return 0;
    80004f18:	4501                	li	a0,0
    80004f1a:	a025                	j	80004f42 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004f1c:	6088                	ld	a0,0(s1)
    80004f1e:	e501                	bnez	a0,80004f26 <pipealloc+0xaa>
    80004f20:	a039                	j	80004f2e <pipealloc+0xb2>
    80004f22:	6088                	ld	a0,0(s1)
    80004f24:	c51d                	beqz	a0,80004f52 <pipealloc+0xd6>
    fileclose(*f0);
    80004f26:	00000097          	auipc	ra,0x0
    80004f2a:	c26080e7          	jalr	-986(ra) # 80004b4c <fileclose>
  if(*f1)
    80004f2e:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004f32:	557d                	li	a0,-1
  if(*f1)
    80004f34:	c799                	beqz	a5,80004f42 <pipealloc+0xc6>
    fileclose(*f1);
    80004f36:	853e                	mv	a0,a5
    80004f38:	00000097          	auipc	ra,0x0
    80004f3c:	c14080e7          	jalr	-1004(ra) # 80004b4c <fileclose>
  return -1;
    80004f40:	557d                	li	a0,-1
}
    80004f42:	70a2                	ld	ra,40(sp)
    80004f44:	7402                	ld	s0,32(sp)
    80004f46:	64e2                	ld	s1,24(sp)
    80004f48:	6942                	ld	s2,16(sp)
    80004f4a:	69a2                	ld	s3,8(sp)
    80004f4c:	6a02                	ld	s4,0(sp)
    80004f4e:	6145                	addi	sp,sp,48
    80004f50:	8082                	ret
  return -1;
    80004f52:	557d                	li	a0,-1
    80004f54:	b7fd                	j	80004f42 <pipealloc+0xc6>

0000000080004f56 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004f56:	1101                	addi	sp,sp,-32
    80004f58:	ec06                	sd	ra,24(sp)
    80004f5a:	e822                	sd	s0,16(sp)
    80004f5c:	e426                	sd	s1,8(sp)
    80004f5e:	e04a                	sd	s2,0(sp)
    80004f60:	1000                	addi	s0,sp,32
    80004f62:	84aa                	mv	s1,a0
    80004f64:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004f66:	ffffc097          	auipc	ra,0xffffc
    80004f6a:	c84080e7          	jalr	-892(ra) # 80000bea <acquire>
  if(writable){
    80004f6e:	02090d63          	beqz	s2,80004fa8 <pipeclose+0x52>
    pi->writeopen = 0;
    80004f72:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004f76:	21848513          	addi	a0,s1,536
    80004f7a:	ffffd097          	auipc	ra,0xffffd
    80004f7e:	43e080e7          	jalr	1086(ra) # 800023b8 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004f82:	2204b783          	ld	a5,544(s1)
    80004f86:	eb95                	bnez	a5,80004fba <pipeclose+0x64>
    release(&pi->lock);
    80004f88:	8526                	mv	a0,s1
    80004f8a:	ffffc097          	auipc	ra,0xffffc
    80004f8e:	d14080e7          	jalr	-748(ra) # 80000c9e <release>
    kfree((char*)pi);
    80004f92:	8526                	mv	a0,s1
    80004f94:	ffffc097          	auipc	ra,0xffffc
    80004f98:	a6a080e7          	jalr	-1430(ra) # 800009fe <kfree>
  } else
    release(&pi->lock);
}
    80004f9c:	60e2                	ld	ra,24(sp)
    80004f9e:	6442                	ld	s0,16(sp)
    80004fa0:	64a2                	ld	s1,8(sp)
    80004fa2:	6902                	ld	s2,0(sp)
    80004fa4:	6105                	addi	sp,sp,32
    80004fa6:	8082                	ret
    pi->readopen = 0;
    80004fa8:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004fac:	21c48513          	addi	a0,s1,540
    80004fb0:	ffffd097          	auipc	ra,0xffffd
    80004fb4:	408080e7          	jalr	1032(ra) # 800023b8 <wakeup>
    80004fb8:	b7e9                	j	80004f82 <pipeclose+0x2c>
    release(&pi->lock);
    80004fba:	8526                	mv	a0,s1
    80004fbc:	ffffc097          	auipc	ra,0xffffc
    80004fc0:	ce2080e7          	jalr	-798(ra) # 80000c9e <release>
}
    80004fc4:	bfe1                	j	80004f9c <pipeclose+0x46>

0000000080004fc6 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004fc6:	7159                	addi	sp,sp,-112
    80004fc8:	f486                	sd	ra,104(sp)
    80004fca:	f0a2                	sd	s0,96(sp)
    80004fcc:	eca6                	sd	s1,88(sp)
    80004fce:	e8ca                	sd	s2,80(sp)
    80004fd0:	e4ce                	sd	s3,72(sp)
    80004fd2:	e0d2                	sd	s4,64(sp)
    80004fd4:	fc56                	sd	s5,56(sp)
    80004fd6:	f85a                	sd	s6,48(sp)
    80004fd8:	f45e                	sd	s7,40(sp)
    80004fda:	f062                	sd	s8,32(sp)
    80004fdc:	ec66                	sd	s9,24(sp)
    80004fde:	1880                	addi	s0,sp,112
    80004fe0:	84aa                	mv	s1,a0
    80004fe2:	8aae                	mv	s5,a1
    80004fe4:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004fe6:	ffffd097          	auipc	ra,0xffffd
    80004fea:	9e0080e7          	jalr	-1568(ra) # 800019c6 <myproc>
    80004fee:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004ff0:	8526                	mv	a0,s1
    80004ff2:	ffffc097          	auipc	ra,0xffffc
    80004ff6:	bf8080e7          	jalr	-1032(ra) # 80000bea <acquire>
  while(i < n){
    80004ffa:	0d405463          	blez	s4,800050c2 <pipewrite+0xfc>
    80004ffe:	8ba6                	mv	s7,s1
  int i = 0;
    80005000:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005002:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005004:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005008:	21c48c13          	addi	s8,s1,540
    8000500c:	a08d                	j	8000506e <pipewrite+0xa8>
      release(&pi->lock);
    8000500e:	8526                	mv	a0,s1
    80005010:	ffffc097          	auipc	ra,0xffffc
    80005014:	c8e080e7          	jalr	-882(ra) # 80000c9e <release>
      return -1;
    80005018:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000501a:	854a                	mv	a0,s2
    8000501c:	70a6                	ld	ra,104(sp)
    8000501e:	7406                	ld	s0,96(sp)
    80005020:	64e6                	ld	s1,88(sp)
    80005022:	6946                	ld	s2,80(sp)
    80005024:	69a6                	ld	s3,72(sp)
    80005026:	6a06                	ld	s4,64(sp)
    80005028:	7ae2                	ld	s5,56(sp)
    8000502a:	7b42                	ld	s6,48(sp)
    8000502c:	7ba2                	ld	s7,40(sp)
    8000502e:	7c02                	ld	s8,32(sp)
    80005030:	6ce2                	ld	s9,24(sp)
    80005032:	6165                	addi	sp,sp,112
    80005034:	8082                	ret
      wakeup(&pi->nread);
    80005036:	8566                	mv	a0,s9
    80005038:	ffffd097          	auipc	ra,0xffffd
    8000503c:	380080e7          	jalr	896(ra) # 800023b8 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005040:	85de                	mv	a1,s7
    80005042:	8562                	mv	a0,s8
    80005044:	ffffd097          	auipc	ra,0xffffd
    80005048:	1c4080e7          	jalr	452(ra) # 80002208 <sleep>
    8000504c:	a839                	j	8000506a <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000504e:	21c4a783          	lw	a5,540(s1)
    80005052:	0017871b          	addiw	a4,a5,1
    80005056:	20e4ae23          	sw	a4,540(s1)
    8000505a:	1ff7f793          	andi	a5,a5,511
    8000505e:	97a6                	add	a5,a5,s1
    80005060:	f9f44703          	lbu	a4,-97(s0)
    80005064:	00e78c23          	sb	a4,24(a5)
      i++;
    80005068:	2905                	addiw	s2,s2,1
  while(i < n){
    8000506a:	05495063          	bge	s2,s4,800050aa <pipewrite+0xe4>
    if(pi->readopen == 0 || killed(pr)){
    8000506e:	2204a783          	lw	a5,544(s1)
    80005072:	dfd1                	beqz	a5,8000500e <pipewrite+0x48>
    80005074:	854e                	mv	a0,s3
    80005076:	ffffd097          	auipc	ra,0xffffd
    8000507a:	592080e7          	jalr	1426(ra) # 80002608 <killed>
    8000507e:	f941                	bnez	a0,8000500e <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005080:	2184a783          	lw	a5,536(s1)
    80005084:	21c4a703          	lw	a4,540(s1)
    80005088:	2007879b          	addiw	a5,a5,512
    8000508c:	faf705e3          	beq	a4,a5,80005036 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005090:	4685                	li	a3,1
    80005092:	01590633          	add	a2,s2,s5
    80005096:	f9f40593          	addi	a1,s0,-97
    8000509a:	0509b503          	ld	a0,80(s3)
    8000509e:	ffffc097          	auipc	ra,0xffffc
    800050a2:	672080e7          	jalr	1650(ra) # 80001710 <copyin>
    800050a6:	fb6514e3          	bne	a0,s6,8000504e <pipewrite+0x88>
  wakeup(&pi->nread);
    800050aa:	21848513          	addi	a0,s1,536
    800050ae:	ffffd097          	auipc	ra,0xffffd
    800050b2:	30a080e7          	jalr	778(ra) # 800023b8 <wakeup>
  release(&pi->lock);
    800050b6:	8526                	mv	a0,s1
    800050b8:	ffffc097          	auipc	ra,0xffffc
    800050bc:	be6080e7          	jalr	-1050(ra) # 80000c9e <release>
  return i;
    800050c0:	bfa9                	j	8000501a <pipewrite+0x54>
  int i = 0;
    800050c2:	4901                	li	s2,0
    800050c4:	b7dd                	j	800050aa <pipewrite+0xe4>

00000000800050c6 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800050c6:	715d                	addi	sp,sp,-80
    800050c8:	e486                	sd	ra,72(sp)
    800050ca:	e0a2                	sd	s0,64(sp)
    800050cc:	fc26                	sd	s1,56(sp)
    800050ce:	f84a                	sd	s2,48(sp)
    800050d0:	f44e                	sd	s3,40(sp)
    800050d2:	f052                	sd	s4,32(sp)
    800050d4:	ec56                	sd	s5,24(sp)
    800050d6:	e85a                	sd	s6,16(sp)
    800050d8:	0880                	addi	s0,sp,80
    800050da:	84aa                	mv	s1,a0
    800050dc:	892e                	mv	s2,a1
    800050de:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800050e0:	ffffd097          	auipc	ra,0xffffd
    800050e4:	8e6080e7          	jalr	-1818(ra) # 800019c6 <myproc>
    800050e8:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800050ea:	8b26                	mv	s6,s1
    800050ec:	8526                	mv	a0,s1
    800050ee:	ffffc097          	auipc	ra,0xffffc
    800050f2:	afc080e7          	jalr	-1284(ra) # 80000bea <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800050f6:	2184a703          	lw	a4,536(s1)
    800050fa:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800050fe:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005102:	02f71763          	bne	a4,a5,80005130 <piperead+0x6a>
    80005106:	2244a783          	lw	a5,548(s1)
    8000510a:	c39d                	beqz	a5,80005130 <piperead+0x6a>
    if(killed(pr)){
    8000510c:	8552                	mv	a0,s4
    8000510e:	ffffd097          	auipc	ra,0xffffd
    80005112:	4fa080e7          	jalr	1274(ra) # 80002608 <killed>
    80005116:	e941                	bnez	a0,800051a6 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005118:	85da                	mv	a1,s6
    8000511a:	854e                	mv	a0,s3
    8000511c:	ffffd097          	auipc	ra,0xffffd
    80005120:	0ec080e7          	jalr	236(ra) # 80002208 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005124:	2184a703          	lw	a4,536(s1)
    80005128:	21c4a783          	lw	a5,540(s1)
    8000512c:	fcf70de3          	beq	a4,a5,80005106 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005130:	09505263          	blez	s5,800051b4 <piperead+0xee>
    80005134:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005136:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80005138:	2184a783          	lw	a5,536(s1)
    8000513c:	21c4a703          	lw	a4,540(s1)
    80005140:	02f70d63          	beq	a4,a5,8000517a <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005144:	0017871b          	addiw	a4,a5,1
    80005148:	20e4ac23          	sw	a4,536(s1)
    8000514c:	1ff7f793          	andi	a5,a5,511
    80005150:	97a6                	add	a5,a5,s1
    80005152:	0187c783          	lbu	a5,24(a5)
    80005156:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000515a:	4685                	li	a3,1
    8000515c:	fbf40613          	addi	a2,s0,-65
    80005160:	85ca                	mv	a1,s2
    80005162:	050a3503          	ld	a0,80(s4)
    80005166:	ffffc097          	auipc	ra,0xffffc
    8000516a:	51e080e7          	jalr	1310(ra) # 80001684 <copyout>
    8000516e:	01650663          	beq	a0,s6,8000517a <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005172:	2985                	addiw	s3,s3,1
    80005174:	0905                	addi	s2,s2,1
    80005176:	fd3a91e3          	bne	s5,s3,80005138 <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000517a:	21c48513          	addi	a0,s1,540
    8000517e:	ffffd097          	auipc	ra,0xffffd
    80005182:	23a080e7          	jalr	570(ra) # 800023b8 <wakeup>
  release(&pi->lock);
    80005186:	8526                	mv	a0,s1
    80005188:	ffffc097          	auipc	ra,0xffffc
    8000518c:	b16080e7          	jalr	-1258(ra) # 80000c9e <release>
  return i;
}
    80005190:	854e                	mv	a0,s3
    80005192:	60a6                	ld	ra,72(sp)
    80005194:	6406                	ld	s0,64(sp)
    80005196:	74e2                	ld	s1,56(sp)
    80005198:	7942                	ld	s2,48(sp)
    8000519a:	79a2                	ld	s3,40(sp)
    8000519c:	7a02                	ld	s4,32(sp)
    8000519e:	6ae2                	ld	s5,24(sp)
    800051a0:	6b42                	ld	s6,16(sp)
    800051a2:	6161                	addi	sp,sp,80
    800051a4:	8082                	ret
      release(&pi->lock);
    800051a6:	8526                	mv	a0,s1
    800051a8:	ffffc097          	auipc	ra,0xffffc
    800051ac:	af6080e7          	jalr	-1290(ra) # 80000c9e <release>
      return -1;
    800051b0:	59fd                	li	s3,-1
    800051b2:	bff9                	j	80005190 <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800051b4:	4981                	li	s3,0
    800051b6:	b7d1                	j	8000517a <piperead+0xb4>

00000000800051b8 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800051b8:	1141                	addi	sp,sp,-16
    800051ba:	e422                	sd	s0,8(sp)
    800051bc:	0800                	addi	s0,sp,16
    800051be:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800051c0:	8905                	andi	a0,a0,1
    800051c2:	c111                	beqz	a0,800051c6 <flags2perm+0xe>
      perm = PTE_X;
    800051c4:	4521                	li	a0,8
    if(flags & 0x2)
    800051c6:	8b89                	andi	a5,a5,2
    800051c8:	c399                	beqz	a5,800051ce <flags2perm+0x16>
      perm |= PTE_W;
    800051ca:	00456513          	ori	a0,a0,4
    return perm;
}
    800051ce:	6422                	ld	s0,8(sp)
    800051d0:	0141                	addi	sp,sp,16
    800051d2:	8082                	ret

00000000800051d4 <exec>:

int
exec(char *path, char **argv)
{
    800051d4:	df010113          	addi	sp,sp,-528
    800051d8:	20113423          	sd	ra,520(sp)
    800051dc:	20813023          	sd	s0,512(sp)
    800051e0:	ffa6                	sd	s1,504(sp)
    800051e2:	fbca                	sd	s2,496(sp)
    800051e4:	f7ce                	sd	s3,488(sp)
    800051e6:	f3d2                	sd	s4,480(sp)
    800051e8:	efd6                	sd	s5,472(sp)
    800051ea:	ebda                	sd	s6,464(sp)
    800051ec:	e7de                	sd	s7,456(sp)
    800051ee:	e3e2                	sd	s8,448(sp)
    800051f0:	ff66                	sd	s9,440(sp)
    800051f2:	fb6a                	sd	s10,432(sp)
    800051f4:	f76e                	sd	s11,424(sp)
    800051f6:	0c00                	addi	s0,sp,528
    800051f8:	84aa                	mv	s1,a0
    800051fa:	dea43c23          	sd	a0,-520(s0)
    800051fe:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005202:	ffffc097          	auipc	ra,0xffffc
    80005206:	7c4080e7          	jalr	1988(ra) # 800019c6 <myproc>
    8000520a:	892a                	mv	s2,a0

  begin_op();
    8000520c:	fffff097          	auipc	ra,0xfffff
    80005210:	474080e7          	jalr	1140(ra) # 80004680 <begin_op>

  if((ip = namei(path)) == 0){
    80005214:	8526                	mv	a0,s1
    80005216:	fffff097          	auipc	ra,0xfffff
    8000521a:	24e080e7          	jalr	590(ra) # 80004464 <namei>
    8000521e:	c92d                	beqz	a0,80005290 <exec+0xbc>
    80005220:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005222:	fffff097          	auipc	ra,0xfffff
    80005226:	a9c080e7          	jalr	-1380(ra) # 80003cbe <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000522a:	04000713          	li	a4,64
    8000522e:	4681                	li	a3,0
    80005230:	e5040613          	addi	a2,s0,-432
    80005234:	4581                	li	a1,0
    80005236:	8526                	mv	a0,s1
    80005238:	fffff097          	auipc	ra,0xfffff
    8000523c:	d3a080e7          	jalr	-710(ra) # 80003f72 <readi>
    80005240:	04000793          	li	a5,64
    80005244:	00f51a63          	bne	a0,a5,80005258 <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80005248:	e5042703          	lw	a4,-432(s0)
    8000524c:	464c47b7          	lui	a5,0x464c4
    80005250:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005254:	04f70463          	beq	a4,a5,8000529c <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005258:	8526                	mv	a0,s1
    8000525a:	fffff097          	auipc	ra,0xfffff
    8000525e:	cc6080e7          	jalr	-826(ra) # 80003f20 <iunlockput>
    end_op();
    80005262:	fffff097          	auipc	ra,0xfffff
    80005266:	49e080e7          	jalr	1182(ra) # 80004700 <end_op>
  }
  return -1;
    8000526a:	557d                	li	a0,-1
}
    8000526c:	20813083          	ld	ra,520(sp)
    80005270:	20013403          	ld	s0,512(sp)
    80005274:	74fe                	ld	s1,504(sp)
    80005276:	795e                	ld	s2,496(sp)
    80005278:	79be                	ld	s3,488(sp)
    8000527a:	7a1e                	ld	s4,480(sp)
    8000527c:	6afe                	ld	s5,472(sp)
    8000527e:	6b5e                	ld	s6,464(sp)
    80005280:	6bbe                	ld	s7,456(sp)
    80005282:	6c1e                	ld	s8,448(sp)
    80005284:	7cfa                	ld	s9,440(sp)
    80005286:	7d5a                	ld	s10,432(sp)
    80005288:	7dba                	ld	s11,424(sp)
    8000528a:	21010113          	addi	sp,sp,528
    8000528e:	8082                	ret
    end_op();
    80005290:	fffff097          	auipc	ra,0xfffff
    80005294:	470080e7          	jalr	1136(ra) # 80004700 <end_op>
    return -1;
    80005298:	557d                	li	a0,-1
    8000529a:	bfc9                	j	8000526c <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    8000529c:	854a                	mv	a0,s2
    8000529e:	ffffc097          	auipc	ra,0xffffc
    800052a2:	7ec080e7          	jalr	2028(ra) # 80001a8a <proc_pagetable>
    800052a6:	8baa                	mv	s7,a0
    800052a8:	d945                	beqz	a0,80005258 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800052aa:	e7042983          	lw	s3,-400(s0)
    800052ae:	e8845783          	lhu	a5,-376(s0)
    800052b2:	c7ad                	beqz	a5,8000531c <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800052b4:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800052b6:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    800052b8:	6c85                	lui	s9,0x1
    800052ba:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800052be:	def43823          	sd	a5,-528(s0)
    800052c2:	ac0d                	j	800054f4 <exec+0x320>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800052c4:	00003517          	auipc	a0,0x3
    800052c8:	5dc50513          	addi	a0,a0,1500 # 800088a0 <syscallnum+0x238>
    800052cc:	ffffb097          	auipc	ra,0xffffb
    800052d0:	278080e7          	jalr	632(ra) # 80000544 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800052d4:	8756                	mv	a4,s5
    800052d6:	012d86bb          	addw	a3,s11,s2
    800052da:	4581                	li	a1,0
    800052dc:	8526                	mv	a0,s1
    800052de:	fffff097          	auipc	ra,0xfffff
    800052e2:	c94080e7          	jalr	-876(ra) # 80003f72 <readi>
    800052e6:	2501                	sext.w	a0,a0
    800052e8:	1aaa9a63          	bne	s5,a0,8000549c <exec+0x2c8>
  for(i = 0; i < sz; i += PGSIZE){
    800052ec:	6785                	lui	a5,0x1
    800052ee:	0127893b          	addw	s2,a5,s2
    800052f2:	77fd                	lui	a5,0xfffff
    800052f4:	01478a3b          	addw	s4,a5,s4
    800052f8:	1f897563          	bgeu	s2,s8,800054e2 <exec+0x30e>
    pa = walkaddr(pagetable, va + i);
    800052fc:	02091593          	slli	a1,s2,0x20
    80005300:	9181                	srli	a1,a1,0x20
    80005302:	95ea                	add	a1,a1,s10
    80005304:	855e                	mv	a0,s7
    80005306:	ffffc097          	auipc	ra,0xffffc
    8000530a:	d72080e7          	jalr	-654(ra) # 80001078 <walkaddr>
    8000530e:	862a                	mv	a2,a0
    if(pa == 0)
    80005310:	d955                	beqz	a0,800052c4 <exec+0xf0>
      n = PGSIZE;
    80005312:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80005314:	fd9a70e3          	bgeu	s4,s9,800052d4 <exec+0x100>
      n = sz - i;
    80005318:	8ad2                	mv	s5,s4
    8000531a:	bf6d                	j	800052d4 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000531c:	4a01                	li	s4,0
  iunlockput(ip);
    8000531e:	8526                	mv	a0,s1
    80005320:	fffff097          	auipc	ra,0xfffff
    80005324:	c00080e7          	jalr	-1024(ra) # 80003f20 <iunlockput>
  end_op();
    80005328:	fffff097          	auipc	ra,0xfffff
    8000532c:	3d8080e7          	jalr	984(ra) # 80004700 <end_op>
  p = myproc();
    80005330:	ffffc097          	auipc	ra,0xffffc
    80005334:	696080e7          	jalr	1686(ra) # 800019c6 <myproc>
    80005338:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    8000533a:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    8000533e:	6785                	lui	a5,0x1
    80005340:	17fd                	addi	a5,a5,-1
    80005342:	9a3e                	add	s4,s4,a5
    80005344:	757d                	lui	a0,0xfffff
    80005346:	00aa77b3          	and	a5,s4,a0
    8000534a:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    8000534e:	4691                	li	a3,4
    80005350:	6609                	lui	a2,0x2
    80005352:	963e                	add	a2,a2,a5
    80005354:	85be                	mv	a1,a5
    80005356:	855e                	mv	a0,s7
    80005358:	ffffc097          	auipc	ra,0xffffc
    8000535c:	0d4080e7          	jalr	212(ra) # 8000142c <uvmalloc>
    80005360:	8b2a                	mv	s6,a0
  ip = 0;
    80005362:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005364:	12050c63          	beqz	a0,8000549c <exec+0x2c8>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005368:	75f9                	lui	a1,0xffffe
    8000536a:	95aa                	add	a1,a1,a0
    8000536c:	855e                	mv	a0,s7
    8000536e:	ffffc097          	auipc	ra,0xffffc
    80005372:	2e4080e7          	jalr	740(ra) # 80001652 <uvmclear>
  stackbase = sp - PGSIZE;
    80005376:	7c7d                	lui	s8,0xfffff
    80005378:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    8000537a:	e0043783          	ld	a5,-512(s0)
    8000537e:	6388                	ld	a0,0(a5)
    80005380:	c535                	beqz	a0,800053ec <exec+0x218>
    80005382:	e9040993          	addi	s3,s0,-368
    80005386:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    8000538a:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    8000538c:	ffffc097          	auipc	ra,0xffffc
    80005390:	ade080e7          	jalr	-1314(ra) # 80000e6a <strlen>
    80005394:	2505                	addiw	a0,a0,1
    80005396:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000539a:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    8000539e:	13896663          	bltu	s2,s8,800054ca <exec+0x2f6>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800053a2:	e0043d83          	ld	s11,-512(s0)
    800053a6:	000dba03          	ld	s4,0(s11)
    800053aa:	8552                	mv	a0,s4
    800053ac:	ffffc097          	auipc	ra,0xffffc
    800053b0:	abe080e7          	jalr	-1346(ra) # 80000e6a <strlen>
    800053b4:	0015069b          	addiw	a3,a0,1
    800053b8:	8652                	mv	a2,s4
    800053ba:	85ca                	mv	a1,s2
    800053bc:	855e                	mv	a0,s7
    800053be:	ffffc097          	auipc	ra,0xffffc
    800053c2:	2c6080e7          	jalr	710(ra) # 80001684 <copyout>
    800053c6:	10054663          	bltz	a0,800054d2 <exec+0x2fe>
    ustack[argc] = sp;
    800053ca:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800053ce:	0485                	addi	s1,s1,1
    800053d0:	008d8793          	addi	a5,s11,8
    800053d4:	e0f43023          	sd	a5,-512(s0)
    800053d8:	008db503          	ld	a0,8(s11)
    800053dc:	c911                	beqz	a0,800053f0 <exec+0x21c>
    if(argc >= MAXARG)
    800053de:	09a1                	addi	s3,s3,8
    800053e0:	fb3c96e3          	bne	s9,s3,8000538c <exec+0x1b8>
  sz = sz1;
    800053e4:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800053e8:	4481                	li	s1,0
    800053ea:	a84d                	j	8000549c <exec+0x2c8>
  sp = sz;
    800053ec:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    800053ee:	4481                	li	s1,0
  ustack[argc] = 0;
    800053f0:	00349793          	slli	a5,s1,0x3
    800053f4:	f9040713          	addi	a4,s0,-112
    800053f8:	97ba                	add	a5,a5,a4
    800053fa:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    800053fe:	00148693          	addi	a3,s1,1
    80005402:	068e                	slli	a3,a3,0x3
    80005404:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005408:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    8000540c:	01897663          	bgeu	s2,s8,80005418 <exec+0x244>
  sz = sz1;
    80005410:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005414:	4481                	li	s1,0
    80005416:	a059                	j	8000549c <exec+0x2c8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005418:	e9040613          	addi	a2,s0,-368
    8000541c:	85ca                	mv	a1,s2
    8000541e:	855e                	mv	a0,s7
    80005420:	ffffc097          	auipc	ra,0xffffc
    80005424:	264080e7          	jalr	612(ra) # 80001684 <copyout>
    80005428:	0a054963          	bltz	a0,800054da <exec+0x306>
  p->trapframe->a1 = sp;
    8000542c:	058ab783          	ld	a5,88(s5)
    80005430:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005434:	df843783          	ld	a5,-520(s0)
    80005438:	0007c703          	lbu	a4,0(a5)
    8000543c:	cf11                	beqz	a4,80005458 <exec+0x284>
    8000543e:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005440:	02f00693          	li	a3,47
    80005444:	a039                	j	80005452 <exec+0x27e>
      last = s+1;
    80005446:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    8000544a:	0785                	addi	a5,a5,1
    8000544c:	fff7c703          	lbu	a4,-1(a5)
    80005450:	c701                	beqz	a4,80005458 <exec+0x284>
    if(*s == '/')
    80005452:	fed71ce3          	bne	a4,a3,8000544a <exec+0x276>
    80005456:	bfc5                	j	80005446 <exec+0x272>
  safestrcpy(p->name, last, sizeof(p->name));
    80005458:	4641                	li	a2,16
    8000545a:	df843583          	ld	a1,-520(s0)
    8000545e:	158a8513          	addi	a0,s5,344
    80005462:	ffffc097          	auipc	ra,0xffffc
    80005466:	9d6080e7          	jalr	-1578(ra) # 80000e38 <safestrcpy>
  oldpagetable = p->pagetable;
    8000546a:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    8000546e:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    80005472:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005476:	058ab783          	ld	a5,88(s5)
    8000547a:	e6843703          	ld	a4,-408(s0)
    8000547e:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005480:	058ab783          	ld	a5,88(s5)
    80005484:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005488:	85ea                	mv	a1,s10
    8000548a:	ffffc097          	auipc	ra,0xffffc
    8000548e:	69c080e7          	jalr	1692(ra) # 80001b26 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005492:	0004851b          	sext.w	a0,s1
    80005496:	bbd9                	j	8000526c <exec+0x98>
    80005498:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    8000549c:	e0843583          	ld	a1,-504(s0)
    800054a0:	855e                	mv	a0,s7
    800054a2:	ffffc097          	auipc	ra,0xffffc
    800054a6:	684080e7          	jalr	1668(ra) # 80001b26 <proc_freepagetable>
  if(ip){
    800054aa:	da0497e3          	bnez	s1,80005258 <exec+0x84>
  return -1;
    800054ae:	557d                	li	a0,-1
    800054b0:	bb75                	j	8000526c <exec+0x98>
    800054b2:	e1443423          	sd	s4,-504(s0)
    800054b6:	b7dd                	j	8000549c <exec+0x2c8>
    800054b8:	e1443423          	sd	s4,-504(s0)
    800054bc:	b7c5                	j	8000549c <exec+0x2c8>
    800054be:	e1443423          	sd	s4,-504(s0)
    800054c2:	bfe9                	j	8000549c <exec+0x2c8>
    800054c4:	e1443423          	sd	s4,-504(s0)
    800054c8:	bfd1                	j	8000549c <exec+0x2c8>
  sz = sz1;
    800054ca:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800054ce:	4481                	li	s1,0
    800054d0:	b7f1                	j	8000549c <exec+0x2c8>
  sz = sz1;
    800054d2:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800054d6:	4481                	li	s1,0
    800054d8:	b7d1                	j	8000549c <exec+0x2c8>
  sz = sz1;
    800054da:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800054de:	4481                	li	s1,0
    800054e0:	bf75                	j	8000549c <exec+0x2c8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800054e2:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800054e6:	2b05                	addiw	s6,s6,1
    800054e8:	0389899b          	addiw	s3,s3,56
    800054ec:	e8845783          	lhu	a5,-376(s0)
    800054f0:	e2fb57e3          	bge	s6,a5,8000531e <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800054f4:	2981                	sext.w	s3,s3
    800054f6:	03800713          	li	a4,56
    800054fa:	86ce                	mv	a3,s3
    800054fc:	e1840613          	addi	a2,s0,-488
    80005500:	4581                	li	a1,0
    80005502:	8526                	mv	a0,s1
    80005504:	fffff097          	auipc	ra,0xfffff
    80005508:	a6e080e7          	jalr	-1426(ra) # 80003f72 <readi>
    8000550c:	03800793          	li	a5,56
    80005510:	f8f514e3          	bne	a0,a5,80005498 <exec+0x2c4>
    if(ph.type != ELF_PROG_LOAD)
    80005514:	e1842783          	lw	a5,-488(s0)
    80005518:	4705                	li	a4,1
    8000551a:	fce796e3          	bne	a5,a4,800054e6 <exec+0x312>
    if(ph.memsz < ph.filesz)
    8000551e:	e4043903          	ld	s2,-448(s0)
    80005522:	e3843783          	ld	a5,-456(s0)
    80005526:	f8f966e3          	bltu	s2,a5,800054b2 <exec+0x2de>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000552a:	e2843783          	ld	a5,-472(s0)
    8000552e:	993e                	add	s2,s2,a5
    80005530:	f8f964e3          	bltu	s2,a5,800054b8 <exec+0x2e4>
    if(ph.vaddr % PGSIZE != 0)
    80005534:	df043703          	ld	a4,-528(s0)
    80005538:	8ff9                	and	a5,a5,a4
    8000553a:	f3d1                	bnez	a5,800054be <exec+0x2ea>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000553c:	e1c42503          	lw	a0,-484(s0)
    80005540:	00000097          	auipc	ra,0x0
    80005544:	c78080e7          	jalr	-904(ra) # 800051b8 <flags2perm>
    80005548:	86aa                	mv	a3,a0
    8000554a:	864a                	mv	a2,s2
    8000554c:	85d2                	mv	a1,s4
    8000554e:	855e                	mv	a0,s7
    80005550:	ffffc097          	auipc	ra,0xffffc
    80005554:	edc080e7          	jalr	-292(ra) # 8000142c <uvmalloc>
    80005558:	e0a43423          	sd	a0,-504(s0)
    8000555c:	d525                	beqz	a0,800054c4 <exec+0x2f0>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000555e:	e2843d03          	ld	s10,-472(s0)
    80005562:	e2042d83          	lw	s11,-480(s0)
    80005566:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000556a:	f60c0ce3          	beqz	s8,800054e2 <exec+0x30e>
    8000556e:	8a62                	mv	s4,s8
    80005570:	4901                	li	s2,0
    80005572:	b369                	j	800052fc <exec+0x128>

0000000080005574 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005574:	7179                	addi	sp,sp,-48
    80005576:	f406                	sd	ra,40(sp)
    80005578:	f022                	sd	s0,32(sp)
    8000557a:	ec26                	sd	s1,24(sp)
    8000557c:	e84a                	sd	s2,16(sp)
    8000557e:	1800                	addi	s0,sp,48
    80005580:	892e                	mv	s2,a1
    80005582:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005584:	fdc40593          	addi	a1,s0,-36
    80005588:	ffffe097          	auipc	ra,0xffffe
    8000558c:	924080e7          	jalr	-1756(ra) # 80002eac <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005590:	fdc42703          	lw	a4,-36(s0)
    80005594:	47bd                	li	a5,15
    80005596:	02e7eb63          	bltu	a5,a4,800055cc <argfd+0x58>
    8000559a:	ffffc097          	auipc	ra,0xffffc
    8000559e:	42c080e7          	jalr	1068(ra) # 800019c6 <myproc>
    800055a2:	fdc42703          	lw	a4,-36(s0)
    800055a6:	01a70793          	addi	a5,a4,26
    800055aa:	078e                	slli	a5,a5,0x3
    800055ac:	953e                	add	a0,a0,a5
    800055ae:	611c                	ld	a5,0(a0)
    800055b0:	c385                	beqz	a5,800055d0 <argfd+0x5c>
    return -1;
  if(pfd)
    800055b2:	00090463          	beqz	s2,800055ba <argfd+0x46>
    *pfd = fd;
    800055b6:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800055ba:	4501                	li	a0,0
  if(pf)
    800055bc:	c091                	beqz	s1,800055c0 <argfd+0x4c>
    *pf = f;
    800055be:	e09c                	sd	a5,0(s1)
}
    800055c0:	70a2                	ld	ra,40(sp)
    800055c2:	7402                	ld	s0,32(sp)
    800055c4:	64e2                	ld	s1,24(sp)
    800055c6:	6942                	ld	s2,16(sp)
    800055c8:	6145                	addi	sp,sp,48
    800055ca:	8082                	ret
    return -1;
    800055cc:	557d                	li	a0,-1
    800055ce:	bfcd                	j	800055c0 <argfd+0x4c>
    800055d0:	557d                	li	a0,-1
    800055d2:	b7fd                	j	800055c0 <argfd+0x4c>

00000000800055d4 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800055d4:	1101                	addi	sp,sp,-32
    800055d6:	ec06                	sd	ra,24(sp)
    800055d8:	e822                	sd	s0,16(sp)
    800055da:	e426                	sd	s1,8(sp)
    800055dc:	1000                	addi	s0,sp,32
    800055de:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800055e0:	ffffc097          	auipc	ra,0xffffc
    800055e4:	3e6080e7          	jalr	998(ra) # 800019c6 <myproc>
    800055e8:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800055ea:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffdb2b0>
    800055ee:	4501                	li	a0,0
    800055f0:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800055f2:	6398                	ld	a4,0(a5)
    800055f4:	cb19                	beqz	a4,8000560a <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800055f6:	2505                	addiw	a0,a0,1
    800055f8:	07a1                	addi	a5,a5,8
    800055fa:	fed51ce3          	bne	a0,a3,800055f2 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800055fe:	557d                	li	a0,-1
}
    80005600:	60e2                	ld	ra,24(sp)
    80005602:	6442                	ld	s0,16(sp)
    80005604:	64a2                	ld	s1,8(sp)
    80005606:	6105                	addi	sp,sp,32
    80005608:	8082                	ret
      p->ofile[fd] = f;
    8000560a:	01a50793          	addi	a5,a0,26
    8000560e:	078e                	slli	a5,a5,0x3
    80005610:	963e                	add	a2,a2,a5
    80005612:	e204                	sd	s1,0(a2)
      return fd;
    80005614:	b7f5                	j	80005600 <fdalloc+0x2c>

0000000080005616 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005616:	715d                	addi	sp,sp,-80
    80005618:	e486                	sd	ra,72(sp)
    8000561a:	e0a2                	sd	s0,64(sp)
    8000561c:	fc26                	sd	s1,56(sp)
    8000561e:	f84a                	sd	s2,48(sp)
    80005620:	f44e                	sd	s3,40(sp)
    80005622:	f052                	sd	s4,32(sp)
    80005624:	ec56                	sd	s5,24(sp)
    80005626:	e85a                	sd	s6,16(sp)
    80005628:	0880                	addi	s0,sp,80
    8000562a:	8b2e                	mv	s6,a1
    8000562c:	89b2                	mv	s3,a2
    8000562e:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005630:	fb040593          	addi	a1,s0,-80
    80005634:	fffff097          	auipc	ra,0xfffff
    80005638:	e4e080e7          	jalr	-434(ra) # 80004482 <nameiparent>
    8000563c:	84aa                	mv	s1,a0
    8000563e:	16050063          	beqz	a0,8000579e <create+0x188>
    return 0;

  ilock(dp);
    80005642:	ffffe097          	auipc	ra,0xffffe
    80005646:	67c080e7          	jalr	1660(ra) # 80003cbe <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000564a:	4601                	li	a2,0
    8000564c:	fb040593          	addi	a1,s0,-80
    80005650:	8526                	mv	a0,s1
    80005652:	fffff097          	auipc	ra,0xfffff
    80005656:	b50080e7          	jalr	-1200(ra) # 800041a2 <dirlookup>
    8000565a:	8aaa                	mv	s5,a0
    8000565c:	c931                	beqz	a0,800056b0 <create+0x9a>
    iunlockput(dp);
    8000565e:	8526                	mv	a0,s1
    80005660:	fffff097          	auipc	ra,0xfffff
    80005664:	8c0080e7          	jalr	-1856(ra) # 80003f20 <iunlockput>
    ilock(ip);
    80005668:	8556                	mv	a0,s5
    8000566a:	ffffe097          	auipc	ra,0xffffe
    8000566e:	654080e7          	jalr	1620(ra) # 80003cbe <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005672:	000b059b          	sext.w	a1,s6
    80005676:	4789                	li	a5,2
    80005678:	02f59563          	bne	a1,a5,800056a2 <create+0x8c>
    8000567c:	044ad783          	lhu	a5,68(s5)
    80005680:	37f9                	addiw	a5,a5,-2
    80005682:	17c2                	slli	a5,a5,0x30
    80005684:	93c1                	srli	a5,a5,0x30
    80005686:	4705                	li	a4,1
    80005688:	00f76d63          	bltu	a4,a5,800056a2 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000568c:	8556                	mv	a0,s5
    8000568e:	60a6                	ld	ra,72(sp)
    80005690:	6406                	ld	s0,64(sp)
    80005692:	74e2                	ld	s1,56(sp)
    80005694:	7942                	ld	s2,48(sp)
    80005696:	79a2                	ld	s3,40(sp)
    80005698:	7a02                	ld	s4,32(sp)
    8000569a:	6ae2                	ld	s5,24(sp)
    8000569c:	6b42                	ld	s6,16(sp)
    8000569e:	6161                	addi	sp,sp,80
    800056a0:	8082                	ret
    iunlockput(ip);
    800056a2:	8556                	mv	a0,s5
    800056a4:	fffff097          	auipc	ra,0xfffff
    800056a8:	87c080e7          	jalr	-1924(ra) # 80003f20 <iunlockput>
    return 0;
    800056ac:	4a81                	li	s5,0
    800056ae:	bff9                	j	8000568c <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800056b0:	85da                	mv	a1,s6
    800056b2:	4088                	lw	a0,0(s1)
    800056b4:	ffffe097          	auipc	ra,0xffffe
    800056b8:	46e080e7          	jalr	1134(ra) # 80003b22 <ialloc>
    800056bc:	8a2a                	mv	s4,a0
    800056be:	c921                	beqz	a0,8000570e <create+0xf8>
  ilock(ip);
    800056c0:	ffffe097          	auipc	ra,0xffffe
    800056c4:	5fe080e7          	jalr	1534(ra) # 80003cbe <ilock>
  ip->major = major;
    800056c8:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800056cc:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800056d0:	4785                	li	a5,1
    800056d2:	04fa1523          	sh	a5,74(s4)
  iupdate(ip);
    800056d6:	8552                	mv	a0,s4
    800056d8:	ffffe097          	auipc	ra,0xffffe
    800056dc:	51c080e7          	jalr	1308(ra) # 80003bf4 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800056e0:	000b059b          	sext.w	a1,s6
    800056e4:	4785                	li	a5,1
    800056e6:	02f58b63          	beq	a1,a5,8000571c <create+0x106>
  if(dirlink(dp, name, ip->inum) < 0)
    800056ea:	004a2603          	lw	a2,4(s4)
    800056ee:	fb040593          	addi	a1,s0,-80
    800056f2:	8526                	mv	a0,s1
    800056f4:	fffff097          	auipc	ra,0xfffff
    800056f8:	cbe080e7          	jalr	-834(ra) # 800043b2 <dirlink>
    800056fc:	06054f63          	bltz	a0,8000577a <create+0x164>
  iunlockput(dp);
    80005700:	8526                	mv	a0,s1
    80005702:	fffff097          	auipc	ra,0xfffff
    80005706:	81e080e7          	jalr	-2018(ra) # 80003f20 <iunlockput>
  return ip;
    8000570a:	8ad2                	mv	s5,s4
    8000570c:	b741                	j	8000568c <create+0x76>
    iunlockput(dp);
    8000570e:	8526                	mv	a0,s1
    80005710:	fffff097          	auipc	ra,0xfffff
    80005714:	810080e7          	jalr	-2032(ra) # 80003f20 <iunlockput>
    return 0;
    80005718:	8ad2                	mv	s5,s4
    8000571a:	bf8d                	j	8000568c <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000571c:	004a2603          	lw	a2,4(s4)
    80005720:	00003597          	auipc	a1,0x3
    80005724:	1a058593          	addi	a1,a1,416 # 800088c0 <syscallnum+0x258>
    80005728:	8552                	mv	a0,s4
    8000572a:	fffff097          	auipc	ra,0xfffff
    8000572e:	c88080e7          	jalr	-888(ra) # 800043b2 <dirlink>
    80005732:	04054463          	bltz	a0,8000577a <create+0x164>
    80005736:	40d0                	lw	a2,4(s1)
    80005738:	00003597          	auipc	a1,0x3
    8000573c:	19058593          	addi	a1,a1,400 # 800088c8 <syscallnum+0x260>
    80005740:	8552                	mv	a0,s4
    80005742:	fffff097          	auipc	ra,0xfffff
    80005746:	c70080e7          	jalr	-912(ra) # 800043b2 <dirlink>
    8000574a:	02054863          	bltz	a0,8000577a <create+0x164>
  if(dirlink(dp, name, ip->inum) < 0)
    8000574e:	004a2603          	lw	a2,4(s4)
    80005752:	fb040593          	addi	a1,s0,-80
    80005756:	8526                	mv	a0,s1
    80005758:	fffff097          	auipc	ra,0xfffff
    8000575c:	c5a080e7          	jalr	-934(ra) # 800043b2 <dirlink>
    80005760:	00054d63          	bltz	a0,8000577a <create+0x164>
    dp->nlink++;  // for ".."
    80005764:	04a4d783          	lhu	a5,74(s1)
    80005768:	2785                	addiw	a5,a5,1
    8000576a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000576e:	8526                	mv	a0,s1
    80005770:	ffffe097          	auipc	ra,0xffffe
    80005774:	484080e7          	jalr	1156(ra) # 80003bf4 <iupdate>
    80005778:	b761                	j	80005700 <create+0xea>
  ip->nlink = 0;
    8000577a:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000577e:	8552                	mv	a0,s4
    80005780:	ffffe097          	auipc	ra,0xffffe
    80005784:	474080e7          	jalr	1140(ra) # 80003bf4 <iupdate>
  iunlockput(ip);
    80005788:	8552                	mv	a0,s4
    8000578a:	ffffe097          	auipc	ra,0xffffe
    8000578e:	796080e7          	jalr	1942(ra) # 80003f20 <iunlockput>
  iunlockput(dp);
    80005792:	8526                	mv	a0,s1
    80005794:	ffffe097          	auipc	ra,0xffffe
    80005798:	78c080e7          	jalr	1932(ra) # 80003f20 <iunlockput>
  return 0;
    8000579c:	bdc5                	j	8000568c <create+0x76>
    return 0;
    8000579e:	8aaa                	mv	s5,a0
    800057a0:	b5f5                	j	8000568c <create+0x76>

00000000800057a2 <sys_dup>:
{
    800057a2:	7179                	addi	sp,sp,-48
    800057a4:	f406                	sd	ra,40(sp)
    800057a6:	f022                	sd	s0,32(sp)
    800057a8:	ec26                	sd	s1,24(sp)
    800057aa:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800057ac:	fd840613          	addi	a2,s0,-40
    800057b0:	4581                	li	a1,0
    800057b2:	4501                	li	a0,0
    800057b4:	00000097          	auipc	ra,0x0
    800057b8:	dc0080e7          	jalr	-576(ra) # 80005574 <argfd>
    return -1;
    800057bc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800057be:	02054363          	bltz	a0,800057e4 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800057c2:	fd843503          	ld	a0,-40(s0)
    800057c6:	00000097          	auipc	ra,0x0
    800057ca:	e0e080e7          	jalr	-498(ra) # 800055d4 <fdalloc>
    800057ce:	84aa                	mv	s1,a0
    return -1;
    800057d0:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800057d2:	00054963          	bltz	a0,800057e4 <sys_dup+0x42>
  filedup(f);
    800057d6:	fd843503          	ld	a0,-40(s0)
    800057da:	fffff097          	auipc	ra,0xfffff
    800057de:	320080e7          	jalr	800(ra) # 80004afa <filedup>
  return fd;
    800057e2:	87a6                	mv	a5,s1
}
    800057e4:	853e                	mv	a0,a5
    800057e6:	70a2                	ld	ra,40(sp)
    800057e8:	7402                	ld	s0,32(sp)
    800057ea:	64e2                	ld	s1,24(sp)
    800057ec:	6145                	addi	sp,sp,48
    800057ee:	8082                	ret

00000000800057f0 <sys_read>:
{
    800057f0:	7179                	addi	sp,sp,-48
    800057f2:	f406                	sd	ra,40(sp)
    800057f4:	f022                	sd	s0,32(sp)
    800057f6:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800057f8:	fd840593          	addi	a1,s0,-40
    800057fc:	4505                	li	a0,1
    800057fe:	ffffd097          	auipc	ra,0xffffd
    80005802:	6d0080e7          	jalr	1744(ra) # 80002ece <argaddr>
  argint(2, &n);
    80005806:	fe440593          	addi	a1,s0,-28
    8000580a:	4509                	li	a0,2
    8000580c:	ffffd097          	auipc	ra,0xffffd
    80005810:	6a0080e7          	jalr	1696(ra) # 80002eac <argint>
  if(argfd(0, 0, &f) < 0)
    80005814:	fe840613          	addi	a2,s0,-24
    80005818:	4581                	li	a1,0
    8000581a:	4501                	li	a0,0
    8000581c:	00000097          	auipc	ra,0x0
    80005820:	d58080e7          	jalr	-680(ra) # 80005574 <argfd>
    80005824:	87aa                	mv	a5,a0
    return -1;
    80005826:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005828:	0007cc63          	bltz	a5,80005840 <sys_read+0x50>
  return fileread(f, p, n);
    8000582c:	fe442603          	lw	a2,-28(s0)
    80005830:	fd843583          	ld	a1,-40(s0)
    80005834:	fe843503          	ld	a0,-24(s0)
    80005838:	fffff097          	auipc	ra,0xfffff
    8000583c:	44e080e7          	jalr	1102(ra) # 80004c86 <fileread>
}
    80005840:	70a2                	ld	ra,40(sp)
    80005842:	7402                	ld	s0,32(sp)
    80005844:	6145                	addi	sp,sp,48
    80005846:	8082                	ret

0000000080005848 <sys_write>:
{
    80005848:	7179                	addi	sp,sp,-48
    8000584a:	f406                	sd	ra,40(sp)
    8000584c:	f022                	sd	s0,32(sp)
    8000584e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005850:	fd840593          	addi	a1,s0,-40
    80005854:	4505                	li	a0,1
    80005856:	ffffd097          	auipc	ra,0xffffd
    8000585a:	678080e7          	jalr	1656(ra) # 80002ece <argaddr>
  argint(2, &n);
    8000585e:	fe440593          	addi	a1,s0,-28
    80005862:	4509                	li	a0,2
    80005864:	ffffd097          	auipc	ra,0xffffd
    80005868:	648080e7          	jalr	1608(ra) # 80002eac <argint>
  if(argfd(0, 0, &f) < 0)
    8000586c:	fe840613          	addi	a2,s0,-24
    80005870:	4581                	li	a1,0
    80005872:	4501                	li	a0,0
    80005874:	00000097          	auipc	ra,0x0
    80005878:	d00080e7          	jalr	-768(ra) # 80005574 <argfd>
    8000587c:	87aa                	mv	a5,a0
    return -1;
    8000587e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005880:	0007cc63          	bltz	a5,80005898 <sys_write+0x50>
  return filewrite(f, p, n);
    80005884:	fe442603          	lw	a2,-28(s0)
    80005888:	fd843583          	ld	a1,-40(s0)
    8000588c:	fe843503          	ld	a0,-24(s0)
    80005890:	fffff097          	auipc	ra,0xfffff
    80005894:	4b8080e7          	jalr	1208(ra) # 80004d48 <filewrite>
}
    80005898:	70a2                	ld	ra,40(sp)
    8000589a:	7402                	ld	s0,32(sp)
    8000589c:	6145                	addi	sp,sp,48
    8000589e:	8082                	ret

00000000800058a0 <sys_close>:
{
    800058a0:	1101                	addi	sp,sp,-32
    800058a2:	ec06                	sd	ra,24(sp)
    800058a4:	e822                	sd	s0,16(sp)
    800058a6:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800058a8:	fe040613          	addi	a2,s0,-32
    800058ac:	fec40593          	addi	a1,s0,-20
    800058b0:	4501                	li	a0,0
    800058b2:	00000097          	auipc	ra,0x0
    800058b6:	cc2080e7          	jalr	-830(ra) # 80005574 <argfd>
    return -1;
    800058ba:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800058bc:	02054463          	bltz	a0,800058e4 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800058c0:	ffffc097          	auipc	ra,0xffffc
    800058c4:	106080e7          	jalr	262(ra) # 800019c6 <myproc>
    800058c8:	fec42783          	lw	a5,-20(s0)
    800058cc:	07e9                	addi	a5,a5,26
    800058ce:	078e                	slli	a5,a5,0x3
    800058d0:	97aa                	add	a5,a5,a0
    800058d2:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800058d6:	fe043503          	ld	a0,-32(s0)
    800058da:	fffff097          	auipc	ra,0xfffff
    800058de:	272080e7          	jalr	626(ra) # 80004b4c <fileclose>
  return 0;
    800058e2:	4781                	li	a5,0
}
    800058e4:	853e                	mv	a0,a5
    800058e6:	60e2                	ld	ra,24(sp)
    800058e8:	6442                	ld	s0,16(sp)
    800058ea:	6105                	addi	sp,sp,32
    800058ec:	8082                	ret

00000000800058ee <sys_fstat>:
{
    800058ee:	1101                	addi	sp,sp,-32
    800058f0:	ec06                	sd	ra,24(sp)
    800058f2:	e822                	sd	s0,16(sp)
    800058f4:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800058f6:	fe040593          	addi	a1,s0,-32
    800058fa:	4505                	li	a0,1
    800058fc:	ffffd097          	auipc	ra,0xffffd
    80005900:	5d2080e7          	jalr	1490(ra) # 80002ece <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005904:	fe840613          	addi	a2,s0,-24
    80005908:	4581                	li	a1,0
    8000590a:	4501                	li	a0,0
    8000590c:	00000097          	auipc	ra,0x0
    80005910:	c68080e7          	jalr	-920(ra) # 80005574 <argfd>
    80005914:	87aa                	mv	a5,a0
    return -1;
    80005916:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005918:	0007ca63          	bltz	a5,8000592c <sys_fstat+0x3e>
  return filestat(f, st);
    8000591c:	fe043583          	ld	a1,-32(s0)
    80005920:	fe843503          	ld	a0,-24(s0)
    80005924:	fffff097          	auipc	ra,0xfffff
    80005928:	2f0080e7          	jalr	752(ra) # 80004c14 <filestat>
}
    8000592c:	60e2                	ld	ra,24(sp)
    8000592e:	6442                	ld	s0,16(sp)
    80005930:	6105                	addi	sp,sp,32
    80005932:	8082                	ret

0000000080005934 <sys_link>:
{
    80005934:	7169                	addi	sp,sp,-304
    80005936:	f606                	sd	ra,296(sp)
    80005938:	f222                	sd	s0,288(sp)
    8000593a:	ee26                	sd	s1,280(sp)
    8000593c:	ea4a                	sd	s2,272(sp)
    8000593e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005940:	08000613          	li	a2,128
    80005944:	ed040593          	addi	a1,s0,-304
    80005948:	4501                	li	a0,0
    8000594a:	ffffd097          	auipc	ra,0xffffd
    8000594e:	5a6080e7          	jalr	1446(ra) # 80002ef0 <argstr>
    return -1;
    80005952:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005954:	10054e63          	bltz	a0,80005a70 <sys_link+0x13c>
    80005958:	08000613          	li	a2,128
    8000595c:	f5040593          	addi	a1,s0,-176
    80005960:	4505                	li	a0,1
    80005962:	ffffd097          	auipc	ra,0xffffd
    80005966:	58e080e7          	jalr	1422(ra) # 80002ef0 <argstr>
    return -1;
    8000596a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000596c:	10054263          	bltz	a0,80005a70 <sys_link+0x13c>
  begin_op();
    80005970:	fffff097          	auipc	ra,0xfffff
    80005974:	d10080e7          	jalr	-752(ra) # 80004680 <begin_op>
  if((ip = namei(old)) == 0){
    80005978:	ed040513          	addi	a0,s0,-304
    8000597c:	fffff097          	auipc	ra,0xfffff
    80005980:	ae8080e7          	jalr	-1304(ra) # 80004464 <namei>
    80005984:	84aa                	mv	s1,a0
    80005986:	c551                	beqz	a0,80005a12 <sys_link+0xde>
  ilock(ip);
    80005988:	ffffe097          	auipc	ra,0xffffe
    8000598c:	336080e7          	jalr	822(ra) # 80003cbe <ilock>
  if(ip->type == T_DIR){
    80005990:	04449703          	lh	a4,68(s1)
    80005994:	4785                	li	a5,1
    80005996:	08f70463          	beq	a4,a5,80005a1e <sys_link+0xea>
  ip->nlink++;
    8000599a:	04a4d783          	lhu	a5,74(s1)
    8000599e:	2785                	addiw	a5,a5,1
    800059a0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800059a4:	8526                	mv	a0,s1
    800059a6:	ffffe097          	auipc	ra,0xffffe
    800059aa:	24e080e7          	jalr	590(ra) # 80003bf4 <iupdate>
  iunlock(ip);
    800059ae:	8526                	mv	a0,s1
    800059b0:	ffffe097          	auipc	ra,0xffffe
    800059b4:	3d0080e7          	jalr	976(ra) # 80003d80 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800059b8:	fd040593          	addi	a1,s0,-48
    800059bc:	f5040513          	addi	a0,s0,-176
    800059c0:	fffff097          	auipc	ra,0xfffff
    800059c4:	ac2080e7          	jalr	-1342(ra) # 80004482 <nameiparent>
    800059c8:	892a                	mv	s2,a0
    800059ca:	c935                	beqz	a0,80005a3e <sys_link+0x10a>
  ilock(dp);
    800059cc:	ffffe097          	auipc	ra,0xffffe
    800059d0:	2f2080e7          	jalr	754(ra) # 80003cbe <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800059d4:	00092703          	lw	a4,0(s2)
    800059d8:	409c                	lw	a5,0(s1)
    800059da:	04f71d63          	bne	a4,a5,80005a34 <sys_link+0x100>
    800059de:	40d0                	lw	a2,4(s1)
    800059e0:	fd040593          	addi	a1,s0,-48
    800059e4:	854a                	mv	a0,s2
    800059e6:	fffff097          	auipc	ra,0xfffff
    800059ea:	9cc080e7          	jalr	-1588(ra) # 800043b2 <dirlink>
    800059ee:	04054363          	bltz	a0,80005a34 <sys_link+0x100>
  iunlockput(dp);
    800059f2:	854a                	mv	a0,s2
    800059f4:	ffffe097          	auipc	ra,0xffffe
    800059f8:	52c080e7          	jalr	1324(ra) # 80003f20 <iunlockput>
  iput(ip);
    800059fc:	8526                	mv	a0,s1
    800059fe:	ffffe097          	auipc	ra,0xffffe
    80005a02:	47a080e7          	jalr	1146(ra) # 80003e78 <iput>
  end_op();
    80005a06:	fffff097          	auipc	ra,0xfffff
    80005a0a:	cfa080e7          	jalr	-774(ra) # 80004700 <end_op>
  return 0;
    80005a0e:	4781                	li	a5,0
    80005a10:	a085                	j	80005a70 <sys_link+0x13c>
    end_op();
    80005a12:	fffff097          	auipc	ra,0xfffff
    80005a16:	cee080e7          	jalr	-786(ra) # 80004700 <end_op>
    return -1;
    80005a1a:	57fd                	li	a5,-1
    80005a1c:	a891                	j	80005a70 <sys_link+0x13c>
    iunlockput(ip);
    80005a1e:	8526                	mv	a0,s1
    80005a20:	ffffe097          	auipc	ra,0xffffe
    80005a24:	500080e7          	jalr	1280(ra) # 80003f20 <iunlockput>
    end_op();
    80005a28:	fffff097          	auipc	ra,0xfffff
    80005a2c:	cd8080e7          	jalr	-808(ra) # 80004700 <end_op>
    return -1;
    80005a30:	57fd                	li	a5,-1
    80005a32:	a83d                	j	80005a70 <sys_link+0x13c>
    iunlockput(dp);
    80005a34:	854a                	mv	a0,s2
    80005a36:	ffffe097          	auipc	ra,0xffffe
    80005a3a:	4ea080e7          	jalr	1258(ra) # 80003f20 <iunlockput>
  ilock(ip);
    80005a3e:	8526                	mv	a0,s1
    80005a40:	ffffe097          	auipc	ra,0xffffe
    80005a44:	27e080e7          	jalr	638(ra) # 80003cbe <ilock>
  ip->nlink--;
    80005a48:	04a4d783          	lhu	a5,74(s1)
    80005a4c:	37fd                	addiw	a5,a5,-1
    80005a4e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005a52:	8526                	mv	a0,s1
    80005a54:	ffffe097          	auipc	ra,0xffffe
    80005a58:	1a0080e7          	jalr	416(ra) # 80003bf4 <iupdate>
  iunlockput(ip);
    80005a5c:	8526                	mv	a0,s1
    80005a5e:	ffffe097          	auipc	ra,0xffffe
    80005a62:	4c2080e7          	jalr	1218(ra) # 80003f20 <iunlockput>
  end_op();
    80005a66:	fffff097          	auipc	ra,0xfffff
    80005a6a:	c9a080e7          	jalr	-870(ra) # 80004700 <end_op>
  return -1;
    80005a6e:	57fd                	li	a5,-1
}
    80005a70:	853e                	mv	a0,a5
    80005a72:	70b2                	ld	ra,296(sp)
    80005a74:	7412                	ld	s0,288(sp)
    80005a76:	64f2                	ld	s1,280(sp)
    80005a78:	6952                	ld	s2,272(sp)
    80005a7a:	6155                	addi	sp,sp,304
    80005a7c:	8082                	ret

0000000080005a7e <sys_unlink>:
{
    80005a7e:	7151                	addi	sp,sp,-240
    80005a80:	f586                	sd	ra,232(sp)
    80005a82:	f1a2                	sd	s0,224(sp)
    80005a84:	eda6                	sd	s1,216(sp)
    80005a86:	e9ca                	sd	s2,208(sp)
    80005a88:	e5ce                	sd	s3,200(sp)
    80005a8a:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005a8c:	08000613          	li	a2,128
    80005a90:	f3040593          	addi	a1,s0,-208
    80005a94:	4501                	li	a0,0
    80005a96:	ffffd097          	auipc	ra,0xffffd
    80005a9a:	45a080e7          	jalr	1114(ra) # 80002ef0 <argstr>
    80005a9e:	18054163          	bltz	a0,80005c20 <sys_unlink+0x1a2>
  begin_op();
    80005aa2:	fffff097          	auipc	ra,0xfffff
    80005aa6:	bde080e7          	jalr	-1058(ra) # 80004680 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005aaa:	fb040593          	addi	a1,s0,-80
    80005aae:	f3040513          	addi	a0,s0,-208
    80005ab2:	fffff097          	auipc	ra,0xfffff
    80005ab6:	9d0080e7          	jalr	-1584(ra) # 80004482 <nameiparent>
    80005aba:	84aa                	mv	s1,a0
    80005abc:	c979                	beqz	a0,80005b92 <sys_unlink+0x114>
  ilock(dp);
    80005abe:	ffffe097          	auipc	ra,0xffffe
    80005ac2:	200080e7          	jalr	512(ra) # 80003cbe <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005ac6:	00003597          	auipc	a1,0x3
    80005aca:	dfa58593          	addi	a1,a1,-518 # 800088c0 <syscallnum+0x258>
    80005ace:	fb040513          	addi	a0,s0,-80
    80005ad2:	ffffe097          	auipc	ra,0xffffe
    80005ad6:	6b6080e7          	jalr	1718(ra) # 80004188 <namecmp>
    80005ada:	14050a63          	beqz	a0,80005c2e <sys_unlink+0x1b0>
    80005ade:	00003597          	auipc	a1,0x3
    80005ae2:	dea58593          	addi	a1,a1,-534 # 800088c8 <syscallnum+0x260>
    80005ae6:	fb040513          	addi	a0,s0,-80
    80005aea:	ffffe097          	auipc	ra,0xffffe
    80005aee:	69e080e7          	jalr	1694(ra) # 80004188 <namecmp>
    80005af2:	12050e63          	beqz	a0,80005c2e <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005af6:	f2c40613          	addi	a2,s0,-212
    80005afa:	fb040593          	addi	a1,s0,-80
    80005afe:	8526                	mv	a0,s1
    80005b00:	ffffe097          	auipc	ra,0xffffe
    80005b04:	6a2080e7          	jalr	1698(ra) # 800041a2 <dirlookup>
    80005b08:	892a                	mv	s2,a0
    80005b0a:	12050263          	beqz	a0,80005c2e <sys_unlink+0x1b0>
  ilock(ip);
    80005b0e:	ffffe097          	auipc	ra,0xffffe
    80005b12:	1b0080e7          	jalr	432(ra) # 80003cbe <ilock>
  if(ip->nlink < 1)
    80005b16:	04a91783          	lh	a5,74(s2)
    80005b1a:	08f05263          	blez	a5,80005b9e <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005b1e:	04491703          	lh	a4,68(s2)
    80005b22:	4785                	li	a5,1
    80005b24:	08f70563          	beq	a4,a5,80005bae <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005b28:	4641                	li	a2,16
    80005b2a:	4581                	li	a1,0
    80005b2c:	fc040513          	addi	a0,s0,-64
    80005b30:	ffffb097          	auipc	ra,0xffffb
    80005b34:	1b6080e7          	jalr	438(ra) # 80000ce6 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b38:	4741                	li	a4,16
    80005b3a:	f2c42683          	lw	a3,-212(s0)
    80005b3e:	fc040613          	addi	a2,s0,-64
    80005b42:	4581                	li	a1,0
    80005b44:	8526                	mv	a0,s1
    80005b46:	ffffe097          	auipc	ra,0xffffe
    80005b4a:	524080e7          	jalr	1316(ra) # 8000406a <writei>
    80005b4e:	47c1                	li	a5,16
    80005b50:	0af51563          	bne	a0,a5,80005bfa <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005b54:	04491703          	lh	a4,68(s2)
    80005b58:	4785                	li	a5,1
    80005b5a:	0af70863          	beq	a4,a5,80005c0a <sys_unlink+0x18c>
  iunlockput(dp);
    80005b5e:	8526                	mv	a0,s1
    80005b60:	ffffe097          	auipc	ra,0xffffe
    80005b64:	3c0080e7          	jalr	960(ra) # 80003f20 <iunlockput>
  ip->nlink--;
    80005b68:	04a95783          	lhu	a5,74(s2)
    80005b6c:	37fd                	addiw	a5,a5,-1
    80005b6e:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005b72:	854a                	mv	a0,s2
    80005b74:	ffffe097          	auipc	ra,0xffffe
    80005b78:	080080e7          	jalr	128(ra) # 80003bf4 <iupdate>
  iunlockput(ip);
    80005b7c:	854a                	mv	a0,s2
    80005b7e:	ffffe097          	auipc	ra,0xffffe
    80005b82:	3a2080e7          	jalr	930(ra) # 80003f20 <iunlockput>
  end_op();
    80005b86:	fffff097          	auipc	ra,0xfffff
    80005b8a:	b7a080e7          	jalr	-1158(ra) # 80004700 <end_op>
  return 0;
    80005b8e:	4501                	li	a0,0
    80005b90:	a84d                	j	80005c42 <sys_unlink+0x1c4>
    end_op();
    80005b92:	fffff097          	auipc	ra,0xfffff
    80005b96:	b6e080e7          	jalr	-1170(ra) # 80004700 <end_op>
    return -1;
    80005b9a:	557d                	li	a0,-1
    80005b9c:	a05d                	j	80005c42 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005b9e:	00003517          	auipc	a0,0x3
    80005ba2:	d3250513          	addi	a0,a0,-718 # 800088d0 <syscallnum+0x268>
    80005ba6:	ffffb097          	auipc	ra,0xffffb
    80005baa:	99e080e7          	jalr	-1634(ra) # 80000544 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005bae:	04c92703          	lw	a4,76(s2)
    80005bb2:	02000793          	li	a5,32
    80005bb6:	f6e7f9e3          	bgeu	a5,a4,80005b28 <sys_unlink+0xaa>
    80005bba:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005bbe:	4741                	li	a4,16
    80005bc0:	86ce                	mv	a3,s3
    80005bc2:	f1840613          	addi	a2,s0,-232
    80005bc6:	4581                	li	a1,0
    80005bc8:	854a                	mv	a0,s2
    80005bca:	ffffe097          	auipc	ra,0xffffe
    80005bce:	3a8080e7          	jalr	936(ra) # 80003f72 <readi>
    80005bd2:	47c1                	li	a5,16
    80005bd4:	00f51b63          	bne	a0,a5,80005bea <sys_unlink+0x16c>
    if(de.inum != 0)
    80005bd8:	f1845783          	lhu	a5,-232(s0)
    80005bdc:	e7a1                	bnez	a5,80005c24 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005bde:	29c1                	addiw	s3,s3,16
    80005be0:	04c92783          	lw	a5,76(s2)
    80005be4:	fcf9ede3          	bltu	s3,a5,80005bbe <sys_unlink+0x140>
    80005be8:	b781                	j	80005b28 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005bea:	00003517          	auipc	a0,0x3
    80005bee:	cfe50513          	addi	a0,a0,-770 # 800088e8 <syscallnum+0x280>
    80005bf2:	ffffb097          	auipc	ra,0xffffb
    80005bf6:	952080e7          	jalr	-1710(ra) # 80000544 <panic>
    panic("unlink: writei");
    80005bfa:	00003517          	auipc	a0,0x3
    80005bfe:	d0650513          	addi	a0,a0,-762 # 80008900 <syscallnum+0x298>
    80005c02:	ffffb097          	auipc	ra,0xffffb
    80005c06:	942080e7          	jalr	-1726(ra) # 80000544 <panic>
    dp->nlink--;
    80005c0a:	04a4d783          	lhu	a5,74(s1)
    80005c0e:	37fd                	addiw	a5,a5,-1
    80005c10:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005c14:	8526                	mv	a0,s1
    80005c16:	ffffe097          	auipc	ra,0xffffe
    80005c1a:	fde080e7          	jalr	-34(ra) # 80003bf4 <iupdate>
    80005c1e:	b781                	j	80005b5e <sys_unlink+0xe0>
    return -1;
    80005c20:	557d                	li	a0,-1
    80005c22:	a005                	j	80005c42 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005c24:	854a                	mv	a0,s2
    80005c26:	ffffe097          	auipc	ra,0xffffe
    80005c2a:	2fa080e7          	jalr	762(ra) # 80003f20 <iunlockput>
  iunlockput(dp);
    80005c2e:	8526                	mv	a0,s1
    80005c30:	ffffe097          	auipc	ra,0xffffe
    80005c34:	2f0080e7          	jalr	752(ra) # 80003f20 <iunlockput>
  end_op();
    80005c38:	fffff097          	auipc	ra,0xfffff
    80005c3c:	ac8080e7          	jalr	-1336(ra) # 80004700 <end_op>
  return -1;
    80005c40:	557d                	li	a0,-1
}
    80005c42:	70ae                	ld	ra,232(sp)
    80005c44:	740e                	ld	s0,224(sp)
    80005c46:	64ee                	ld	s1,216(sp)
    80005c48:	694e                	ld	s2,208(sp)
    80005c4a:	69ae                	ld	s3,200(sp)
    80005c4c:	616d                	addi	sp,sp,240
    80005c4e:	8082                	ret

0000000080005c50 <sys_open>:

uint64
sys_open(void)
{
    80005c50:	7131                	addi	sp,sp,-192
    80005c52:	fd06                	sd	ra,184(sp)
    80005c54:	f922                	sd	s0,176(sp)
    80005c56:	f526                	sd	s1,168(sp)
    80005c58:	f14a                	sd	s2,160(sp)
    80005c5a:	ed4e                	sd	s3,152(sp)
    80005c5c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005c5e:	f4c40593          	addi	a1,s0,-180
    80005c62:	4505                	li	a0,1
    80005c64:	ffffd097          	auipc	ra,0xffffd
    80005c68:	248080e7          	jalr	584(ra) # 80002eac <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005c6c:	08000613          	li	a2,128
    80005c70:	f5040593          	addi	a1,s0,-176
    80005c74:	4501                	li	a0,0
    80005c76:	ffffd097          	auipc	ra,0xffffd
    80005c7a:	27a080e7          	jalr	634(ra) # 80002ef0 <argstr>
    80005c7e:	87aa                	mv	a5,a0
    return -1;
    80005c80:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005c82:	0a07c963          	bltz	a5,80005d34 <sys_open+0xe4>

  begin_op();
    80005c86:	fffff097          	auipc	ra,0xfffff
    80005c8a:	9fa080e7          	jalr	-1542(ra) # 80004680 <begin_op>

  if(omode & O_CREATE){
    80005c8e:	f4c42783          	lw	a5,-180(s0)
    80005c92:	2007f793          	andi	a5,a5,512
    80005c96:	cfc5                	beqz	a5,80005d4e <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005c98:	4681                	li	a3,0
    80005c9a:	4601                	li	a2,0
    80005c9c:	4589                	li	a1,2
    80005c9e:	f5040513          	addi	a0,s0,-176
    80005ca2:	00000097          	auipc	ra,0x0
    80005ca6:	974080e7          	jalr	-1676(ra) # 80005616 <create>
    80005caa:	84aa                	mv	s1,a0
    if(ip == 0){
    80005cac:	c959                	beqz	a0,80005d42 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005cae:	04449703          	lh	a4,68(s1)
    80005cb2:	478d                	li	a5,3
    80005cb4:	00f71763          	bne	a4,a5,80005cc2 <sys_open+0x72>
    80005cb8:	0464d703          	lhu	a4,70(s1)
    80005cbc:	47a5                	li	a5,9
    80005cbe:	0ce7ed63          	bltu	a5,a4,80005d98 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005cc2:	fffff097          	auipc	ra,0xfffff
    80005cc6:	dce080e7          	jalr	-562(ra) # 80004a90 <filealloc>
    80005cca:	89aa                	mv	s3,a0
    80005ccc:	10050363          	beqz	a0,80005dd2 <sys_open+0x182>
    80005cd0:	00000097          	auipc	ra,0x0
    80005cd4:	904080e7          	jalr	-1788(ra) # 800055d4 <fdalloc>
    80005cd8:	892a                	mv	s2,a0
    80005cda:	0e054763          	bltz	a0,80005dc8 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005cde:	04449703          	lh	a4,68(s1)
    80005ce2:	478d                	li	a5,3
    80005ce4:	0cf70563          	beq	a4,a5,80005dae <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005ce8:	4789                	li	a5,2
    80005cea:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005cee:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005cf2:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005cf6:	f4c42783          	lw	a5,-180(s0)
    80005cfa:	0017c713          	xori	a4,a5,1
    80005cfe:	8b05                	andi	a4,a4,1
    80005d00:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005d04:	0037f713          	andi	a4,a5,3
    80005d08:	00e03733          	snez	a4,a4
    80005d0c:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005d10:	4007f793          	andi	a5,a5,1024
    80005d14:	c791                	beqz	a5,80005d20 <sys_open+0xd0>
    80005d16:	04449703          	lh	a4,68(s1)
    80005d1a:	4789                	li	a5,2
    80005d1c:	0af70063          	beq	a4,a5,80005dbc <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005d20:	8526                	mv	a0,s1
    80005d22:	ffffe097          	auipc	ra,0xffffe
    80005d26:	05e080e7          	jalr	94(ra) # 80003d80 <iunlock>
  end_op();
    80005d2a:	fffff097          	auipc	ra,0xfffff
    80005d2e:	9d6080e7          	jalr	-1578(ra) # 80004700 <end_op>

  return fd;
    80005d32:	854a                	mv	a0,s2
}
    80005d34:	70ea                	ld	ra,184(sp)
    80005d36:	744a                	ld	s0,176(sp)
    80005d38:	74aa                	ld	s1,168(sp)
    80005d3a:	790a                	ld	s2,160(sp)
    80005d3c:	69ea                	ld	s3,152(sp)
    80005d3e:	6129                	addi	sp,sp,192
    80005d40:	8082                	ret
      end_op();
    80005d42:	fffff097          	auipc	ra,0xfffff
    80005d46:	9be080e7          	jalr	-1602(ra) # 80004700 <end_op>
      return -1;
    80005d4a:	557d                	li	a0,-1
    80005d4c:	b7e5                	j	80005d34 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005d4e:	f5040513          	addi	a0,s0,-176
    80005d52:	ffffe097          	auipc	ra,0xffffe
    80005d56:	712080e7          	jalr	1810(ra) # 80004464 <namei>
    80005d5a:	84aa                	mv	s1,a0
    80005d5c:	c905                	beqz	a0,80005d8c <sys_open+0x13c>
    ilock(ip);
    80005d5e:	ffffe097          	auipc	ra,0xffffe
    80005d62:	f60080e7          	jalr	-160(ra) # 80003cbe <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005d66:	04449703          	lh	a4,68(s1)
    80005d6a:	4785                	li	a5,1
    80005d6c:	f4f711e3          	bne	a4,a5,80005cae <sys_open+0x5e>
    80005d70:	f4c42783          	lw	a5,-180(s0)
    80005d74:	d7b9                	beqz	a5,80005cc2 <sys_open+0x72>
      iunlockput(ip);
    80005d76:	8526                	mv	a0,s1
    80005d78:	ffffe097          	auipc	ra,0xffffe
    80005d7c:	1a8080e7          	jalr	424(ra) # 80003f20 <iunlockput>
      end_op();
    80005d80:	fffff097          	auipc	ra,0xfffff
    80005d84:	980080e7          	jalr	-1664(ra) # 80004700 <end_op>
      return -1;
    80005d88:	557d                	li	a0,-1
    80005d8a:	b76d                	j	80005d34 <sys_open+0xe4>
      end_op();
    80005d8c:	fffff097          	auipc	ra,0xfffff
    80005d90:	974080e7          	jalr	-1676(ra) # 80004700 <end_op>
      return -1;
    80005d94:	557d                	li	a0,-1
    80005d96:	bf79                	j	80005d34 <sys_open+0xe4>
    iunlockput(ip);
    80005d98:	8526                	mv	a0,s1
    80005d9a:	ffffe097          	auipc	ra,0xffffe
    80005d9e:	186080e7          	jalr	390(ra) # 80003f20 <iunlockput>
    end_op();
    80005da2:	fffff097          	auipc	ra,0xfffff
    80005da6:	95e080e7          	jalr	-1698(ra) # 80004700 <end_op>
    return -1;
    80005daa:	557d                	li	a0,-1
    80005dac:	b761                	j	80005d34 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005dae:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005db2:	04649783          	lh	a5,70(s1)
    80005db6:	02f99223          	sh	a5,36(s3)
    80005dba:	bf25                	j	80005cf2 <sys_open+0xa2>
    itrunc(ip);
    80005dbc:	8526                	mv	a0,s1
    80005dbe:	ffffe097          	auipc	ra,0xffffe
    80005dc2:	00e080e7          	jalr	14(ra) # 80003dcc <itrunc>
    80005dc6:	bfa9                	j	80005d20 <sys_open+0xd0>
      fileclose(f);
    80005dc8:	854e                	mv	a0,s3
    80005dca:	fffff097          	auipc	ra,0xfffff
    80005dce:	d82080e7          	jalr	-638(ra) # 80004b4c <fileclose>
    iunlockput(ip);
    80005dd2:	8526                	mv	a0,s1
    80005dd4:	ffffe097          	auipc	ra,0xffffe
    80005dd8:	14c080e7          	jalr	332(ra) # 80003f20 <iunlockput>
    end_op();
    80005ddc:	fffff097          	auipc	ra,0xfffff
    80005de0:	924080e7          	jalr	-1756(ra) # 80004700 <end_op>
    return -1;
    80005de4:	557d                	li	a0,-1
    80005de6:	b7b9                	j	80005d34 <sys_open+0xe4>

0000000080005de8 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005de8:	7175                	addi	sp,sp,-144
    80005dea:	e506                	sd	ra,136(sp)
    80005dec:	e122                	sd	s0,128(sp)
    80005dee:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005df0:	fffff097          	auipc	ra,0xfffff
    80005df4:	890080e7          	jalr	-1904(ra) # 80004680 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005df8:	08000613          	li	a2,128
    80005dfc:	f7040593          	addi	a1,s0,-144
    80005e00:	4501                	li	a0,0
    80005e02:	ffffd097          	auipc	ra,0xffffd
    80005e06:	0ee080e7          	jalr	238(ra) # 80002ef0 <argstr>
    80005e0a:	02054963          	bltz	a0,80005e3c <sys_mkdir+0x54>
    80005e0e:	4681                	li	a3,0
    80005e10:	4601                	li	a2,0
    80005e12:	4585                	li	a1,1
    80005e14:	f7040513          	addi	a0,s0,-144
    80005e18:	fffff097          	auipc	ra,0xfffff
    80005e1c:	7fe080e7          	jalr	2046(ra) # 80005616 <create>
    80005e20:	cd11                	beqz	a0,80005e3c <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005e22:	ffffe097          	auipc	ra,0xffffe
    80005e26:	0fe080e7          	jalr	254(ra) # 80003f20 <iunlockput>
  end_op();
    80005e2a:	fffff097          	auipc	ra,0xfffff
    80005e2e:	8d6080e7          	jalr	-1834(ra) # 80004700 <end_op>
  return 0;
    80005e32:	4501                	li	a0,0
}
    80005e34:	60aa                	ld	ra,136(sp)
    80005e36:	640a                	ld	s0,128(sp)
    80005e38:	6149                	addi	sp,sp,144
    80005e3a:	8082                	ret
    end_op();
    80005e3c:	fffff097          	auipc	ra,0xfffff
    80005e40:	8c4080e7          	jalr	-1852(ra) # 80004700 <end_op>
    return -1;
    80005e44:	557d                	li	a0,-1
    80005e46:	b7fd                	j	80005e34 <sys_mkdir+0x4c>

0000000080005e48 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005e48:	7135                	addi	sp,sp,-160
    80005e4a:	ed06                	sd	ra,152(sp)
    80005e4c:	e922                	sd	s0,144(sp)
    80005e4e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005e50:	fffff097          	auipc	ra,0xfffff
    80005e54:	830080e7          	jalr	-2000(ra) # 80004680 <begin_op>
  argint(1, &major);
    80005e58:	f6c40593          	addi	a1,s0,-148
    80005e5c:	4505                	li	a0,1
    80005e5e:	ffffd097          	auipc	ra,0xffffd
    80005e62:	04e080e7          	jalr	78(ra) # 80002eac <argint>
  argint(2, &minor);
    80005e66:	f6840593          	addi	a1,s0,-152
    80005e6a:	4509                	li	a0,2
    80005e6c:	ffffd097          	auipc	ra,0xffffd
    80005e70:	040080e7          	jalr	64(ra) # 80002eac <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e74:	08000613          	li	a2,128
    80005e78:	f7040593          	addi	a1,s0,-144
    80005e7c:	4501                	li	a0,0
    80005e7e:	ffffd097          	auipc	ra,0xffffd
    80005e82:	072080e7          	jalr	114(ra) # 80002ef0 <argstr>
    80005e86:	02054b63          	bltz	a0,80005ebc <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005e8a:	f6841683          	lh	a3,-152(s0)
    80005e8e:	f6c41603          	lh	a2,-148(s0)
    80005e92:	458d                	li	a1,3
    80005e94:	f7040513          	addi	a0,s0,-144
    80005e98:	fffff097          	auipc	ra,0xfffff
    80005e9c:	77e080e7          	jalr	1918(ra) # 80005616 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005ea0:	cd11                	beqz	a0,80005ebc <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005ea2:	ffffe097          	auipc	ra,0xffffe
    80005ea6:	07e080e7          	jalr	126(ra) # 80003f20 <iunlockput>
  end_op();
    80005eaa:	fffff097          	auipc	ra,0xfffff
    80005eae:	856080e7          	jalr	-1962(ra) # 80004700 <end_op>
  return 0;
    80005eb2:	4501                	li	a0,0
}
    80005eb4:	60ea                	ld	ra,152(sp)
    80005eb6:	644a                	ld	s0,144(sp)
    80005eb8:	610d                	addi	sp,sp,160
    80005eba:	8082                	ret
    end_op();
    80005ebc:	fffff097          	auipc	ra,0xfffff
    80005ec0:	844080e7          	jalr	-1980(ra) # 80004700 <end_op>
    return -1;
    80005ec4:	557d                	li	a0,-1
    80005ec6:	b7fd                	j	80005eb4 <sys_mknod+0x6c>

0000000080005ec8 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005ec8:	7135                	addi	sp,sp,-160
    80005eca:	ed06                	sd	ra,152(sp)
    80005ecc:	e922                	sd	s0,144(sp)
    80005ece:	e526                	sd	s1,136(sp)
    80005ed0:	e14a                	sd	s2,128(sp)
    80005ed2:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005ed4:	ffffc097          	auipc	ra,0xffffc
    80005ed8:	af2080e7          	jalr	-1294(ra) # 800019c6 <myproc>
    80005edc:	892a                	mv	s2,a0
  
  begin_op();
    80005ede:	ffffe097          	auipc	ra,0xffffe
    80005ee2:	7a2080e7          	jalr	1954(ra) # 80004680 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005ee6:	08000613          	li	a2,128
    80005eea:	f6040593          	addi	a1,s0,-160
    80005eee:	4501                	li	a0,0
    80005ef0:	ffffd097          	auipc	ra,0xffffd
    80005ef4:	000080e7          	jalr	ra # 80002ef0 <argstr>
    80005ef8:	04054b63          	bltz	a0,80005f4e <sys_chdir+0x86>
    80005efc:	f6040513          	addi	a0,s0,-160
    80005f00:	ffffe097          	auipc	ra,0xffffe
    80005f04:	564080e7          	jalr	1380(ra) # 80004464 <namei>
    80005f08:	84aa                	mv	s1,a0
    80005f0a:	c131                	beqz	a0,80005f4e <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005f0c:	ffffe097          	auipc	ra,0xffffe
    80005f10:	db2080e7          	jalr	-590(ra) # 80003cbe <ilock>
  if(ip->type != T_DIR){
    80005f14:	04449703          	lh	a4,68(s1)
    80005f18:	4785                	li	a5,1
    80005f1a:	04f71063          	bne	a4,a5,80005f5a <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005f1e:	8526                	mv	a0,s1
    80005f20:	ffffe097          	auipc	ra,0xffffe
    80005f24:	e60080e7          	jalr	-416(ra) # 80003d80 <iunlock>
  iput(p->cwd);
    80005f28:	15093503          	ld	a0,336(s2)
    80005f2c:	ffffe097          	auipc	ra,0xffffe
    80005f30:	f4c080e7          	jalr	-180(ra) # 80003e78 <iput>
  end_op();
    80005f34:	ffffe097          	auipc	ra,0xffffe
    80005f38:	7cc080e7          	jalr	1996(ra) # 80004700 <end_op>
  p->cwd = ip;
    80005f3c:	14993823          	sd	s1,336(s2)
  return 0;
    80005f40:	4501                	li	a0,0
}
    80005f42:	60ea                	ld	ra,152(sp)
    80005f44:	644a                	ld	s0,144(sp)
    80005f46:	64aa                	ld	s1,136(sp)
    80005f48:	690a                	ld	s2,128(sp)
    80005f4a:	610d                	addi	sp,sp,160
    80005f4c:	8082                	ret
    end_op();
    80005f4e:	ffffe097          	auipc	ra,0xffffe
    80005f52:	7b2080e7          	jalr	1970(ra) # 80004700 <end_op>
    return -1;
    80005f56:	557d                	li	a0,-1
    80005f58:	b7ed                	j	80005f42 <sys_chdir+0x7a>
    iunlockput(ip);
    80005f5a:	8526                	mv	a0,s1
    80005f5c:	ffffe097          	auipc	ra,0xffffe
    80005f60:	fc4080e7          	jalr	-60(ra) # 80003f20 <iunlockput>
    end_op();
    80005f64:	ffffe097          	auipc	ra,0xffffe
    80005f68:	79c080e7          	jalr	1948(ra) # 80004700 <end_op>
    return -1;
    80005f6c:	557d                	li	a0,-1
    80005f6e:	bfd1                	j	80005f42 <sys_chdir+0x7a>

0000000080005f70 <sys_exec>:

uint64
sys_exec(void)
{
    80005f70:	7145                	addi	sp,sp,-464
    80005f72:	e786                	sd	ra,456(sp)
    80005f74:	e3a2                	sd	s0,448(sp)
    80005f76:	ff26                	sd	s1,440(sp)
    80005f78:	fb4a                	sd	s2,432(sp)
    80005f7a:	f74e                	sd	s3,424(sp)
    80005f7c:	f352                	sd	s4,416(sp)
    80005f7e:	ef56                	sd	s5,408(sp)
    80005f80:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005f82:	e3840593          	addi	a1,s0,-456
    80005f86:	4505                	li	a0,1
    80005f88:	ffffd097          	auipc	ra,0xffffd
    80005f8c:	f46080e7          	jalr	-186(ra) # 80002ece <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005f90:	08000613          	li	a2,128
    80005f94:	f4040593          	addi	a1,s0,-192
    80005f98:	4501                	li	a0,0
    80005f9a:	ffffd097          	auipc	ra,0xffffd
    80005f9e:	f56080e7          	jalr	-170(ra) # 80002ef0 <argstr>
    80005fa2:	87aa                	mv	a5,a0
    return -1;
    80005fa4:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005fa6:	0c07c263          	bltz	a5,8000606a <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005faa:	10000613          	li	a2,256
    80005fae:	4581                	li	a1,0
    80005fb0:	e4040513          	addi	a0,s0,-448
    80005fb4:	ffffb097          	auipc	ra,0xffffb
    80005fb8:	d32080e7          	jalr	-718(ra) # 80000ce6 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005fbc:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005fc0:	89a6                	mv	s3,s1
    80005fc2:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005fc4:	02000a13          	li	s4,32
    80005fc8:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005fcc:	00391513          	slli	a0,s2,0x3
    80005fd0:	e3040593          	addi	a1,s0,-464
    80005fd4:	e3843783          	ld	a5,-456(s0)
    80005fd8:	953e                	add	a0,a0,a5
    80005fda:	ffffd097          	auipc	ra,0xffffd
    80005fde:	e34080e7          	jalr	-460(ra) # 80002e0e <fetchaddr>
    80005fe2:	02054a63          	bltz	a0,80006016 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005fe6:	e3043783          	ld	a5,-464(s0)
    80005fea:	c3b9                	beqz	a5,80006030 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005fec:	ffffb097          	auipc	ra,0xffffb
    80005ff0:	b0e080e7          	jalr	-1266(ra) # 80000afa <kalloc>
    80005ff4:	85aa                	mv	a1,a0
    80005ff6:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005ffa:	cd11                	beqz	a0,80006016 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005ffc:	6605                	lui	a2,0x1
    80005ffe:	e3043503          	ld	a0,-464(s0)
    80006002:	ffffd097          	auipc	ra,0xffffd
    80006006:	e5e080e7          	jalr	-418(ra) # 80002e60 <fetchstr>
    8000600a:	00054663          	bltz	a0,80006016 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    8000600e:	0905                	addi	s2,s2,1
    80006010:	09a1                	addi	s3,s3,8
    80006012:	fb491be3          	bne	s2,s4,80005fc8 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006016:	10048913          	addi	s2,s1,256
    8000601a:	6088                	ld	a0,0(s1)
    8000601c:	c531                	beqz	a0,80006068 <sys_exec+0xf8>
    kfree(argv[i]);
    8000601e:	ffffb097          	auipc	ra,0xffffb
    80006022:	9e0080e7          	jalr	-1568(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006026:	04a1                	addi	s1,s1,8
    80006028:	ff2499e3          	bne	s1,s2,8000601a <sys_exec+0xaa>
  return -1;
    8000602c:	557d                	li	a0,-1
    8000602e:	a835                	j	8000606a <sys_exec+0xfa>
      argv[i] = 0;
    80006030:	0a8e                	slli	s5,s5,0x3
    80006032:	fc040793          	addi	a5,s0,-64
    80006036:	9abe                	add	s5,s5,a5
    80006038:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    8000603c:	e4040593          	addi	a1,s0,-448
    80006040:	f4040513          	addi	a0,s0,-192
    80006044:	fffff097          	auipc	ra,0xfffff
    80006048:	190080e7          	jalr	400(ra) # 800051d4 <exec>
    8000604c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000604e:	10048993          	addi	s3,s1,256
    80006052:	6088                	ld	a0,0(s1)
    80006054:	c901                	beqz	a0,80006064 <sys_exec+0xf4>
    kfree(argv[i]);
    80006056:	ffffb097          	auipc	ra,0xffffb
    8000605a:	9a8080e7          	jalr	-1624(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000605e:	04a1                	addi	s1,s1,8
    80006060:	ff3499e3          	bne	s1,s3,80006052 <sys_exec+0xe2>
  return ret;
    80006064:	854a                	mv	a0,s2
    80006066:	a011                	j	8000606a <sys_exec+0xfa>
  return -1;
    80006068:	557d                	li	a0,-1
}
    8000606a:	60be                	ld	ra,456(sp)
    8000606c:	641e                	ld	s0,448(sp)
    8000606e:	74fa                	ld	s1,440(sp)
    80006070:	795a                	ld	s2,432(sp)
    80006072:	79ba                	ld	s3,424(sp)
    80006074:	7a1a                	ld	s4,416(sp)
    80006076:	6afa                	ld	s5,408(sp)
    80006078:	6179                	addi	sp,sp,464
    8000607a:	8082                	ret

000000008000607c <sys_pipe>:

uint64
sys_pipe(void)
{
    8000607c:	7139                	addi	sp,sp,-64
    8000607e:	fc06                	sd	ra,56(sp)
    80006080:	f822                	sd	s0,48(sp)
    80006082:	f426                	sd	s1,40(sp)
    80006084:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006086:	ffffc097          	auipc	ra,0xffffc
    8000608a:	940080e7          	jalr	-1728(ra) # 800019c6 <myproc>
    8000608e:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80006090:	fd840593          	addi	a1,s0,-40
    80006094:	4501                	li	a0,0
    80006096:	ffffd097          	auipc	ra,0xffffd
    8000609a:	e38080e7          	jalr	-456(ra) # 80002ece <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000609e:	fc840593          	addi	a1,s0,-56
    800060a2:	fd040513          	addi	a0,s0,-48
    800060a6:	fffff097          	auipc	ra,0xfffff
    800060aa:	dd6080e7          	jalr	-554(ra) # 80004e7c <pipealloc>
    return -1;
    800060ae:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800060b0:	0c054463          	bltz	a0,80006178 <sys_pipe+0xfc>
  fd0 = -1;
    800060b4:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800060b8:	fd043503          	ld	a0,-48(s0)
    800060bc:	fffff097          	auipc	ra,0xfffff
    800060c0:	518080e7          	jalr	1304(ra) # 800055d4 <fdalloc>
    800060c4:	fca42223          	sw	a0,-60(s0)
    800060c8:	08054b63          	bltz	a0,8000615e <sys_pipe+0xe2>
    800060cc:	fc843503          	ld	a0,-56(s0)
    800060d0:	fffff097          	auipc	ra,0xfffff
    800060d4:	504080e7          	jalr	1284(ra) # 800055d4 <fdalloc>
    800060d8:	fca42023          	sw	a0,-64(s0)
    800060dc:	06054863          	bltz	a0,8000614c <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800060e0:	4691                	li	a3,4
    800060e2:	fc440613          	addi	a2,s0,-60
    800060e6:	fd843583          	ld	a1,-40(s0)
    800060ea:	68a8                	ld	a0,80(s1)
    800060ec:	ffffb097          	auipc	ra,0xffffb
    800060f0:	598080e7          	jalr	1432(ra) # 80001684 <copyout>
    800060f4:	02054063          	bltz	a0,80006114 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800060f8:	4691                	li	a3,4
    800060fa:	fc040613          	addi	a2,s0,-64
    800060fe:	fd843583          	ld	a1,-40(s0)
    80006102:	0591                	addi	a1,a1,4
    80006104:	68a8                	ld	a0,80(s1)
    80006106:	ffffb097          	auipc	ra,0xffffb
    8000610a:	57e080e7          	jalr	1406(ra) # 80001684 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000610e:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006110:	06055463          	bgez	a0,80006178 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80006114:	fc442783          	lw	a5,-60(s0)
    80006118:	07e9                	addi	a5,a5,26
    8000611a:	078e                	slli	a5,a5,0x3
    8000611c:	97a6                	add	a5,a5,s1
    8000611e:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006122:	fc042503          	lw	a0,-64(s0)
    80006126:	0569                	addi	a0,a0,26
    80006128:	050e                	slli	a0,a0,0x3
    8000612a:	94aa                	add	s1,s1,a0
    8000612c:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80006130:	fd043503          	ld	a0,-48(s0)
    80006134:	fffff097          	auipc	ra,0xfffff
    80006138:	a18080e7          	jalr	-1512(ra) # 80004b4c <fileclose>
    fileclose(wf);
    8000613c:	fc843503          	ld	a0,-56(s0)
    80006140:	fffff097          	auipc	ra,0xfffff
    80006144:	a0c080e7          	jalr	-1524(ra) # 80004b4c <fileclose>
    return -1;
    80006148:	57fd                	li	a5,-1
    8000614a:	a03d                	j	80006178 <sys_pipe+0xfc>
    if(fd0 >= 0)
    8000614c:	fc442783          	lw	a5,-60(s0)
    80006150:	0007c763          	bltz	a5,8000615e <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80006154:	07e9                	addi	a5,a5,26
    80006156:	078e                	slli	a5,a5,0x3
    80006158:	94be                	add	s1,s1,a5
    8000615a:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000615e:	fd043503          	ld	a0,-48(s0)
    80006162:	fffff097          	auipc	ra,0xfffff
    80006166:	9ea080e7          	jalr	-1558(ra) # 80004b4c <fileclose>
    fileclose(wf);
    8000616a:	fc843503          	ld	a0,-56(s0)
    8000616e:	fffff097          	auipc	ra,0xfffff
    80006172:	9de080e7          	jalr	-1570(ra) # 80004b4c <fileclose>
    return -1;
    80006176:	57fd                	li	a5,-1
}
    80006178:	853e                	mv	a0,a5
    8000617a:	70e2                	ld	ra,56(sp)
    8000617c:	7442                	ld	s0,48(sp)
    8000617e:	74a2                	ld	s1,40(sp)
    80006180:	6121                	addi	sp,sp,64
    80006182:	8082                	ret
	...

0000000080006190 <kernelvec>:
    80006190:	7111                	addi	sp,sp,-256
    80006192:	e006                	sd	ra,0(sp)
    80006194:	e40a                	sd	sp,8(sp)
    80006196:	e80e                	sd	gp,16(sp)
    80006198:	ec12                	sd	tp,24(sp)
    8000619a:	f016                	sd	t0,32(sp)
    8000619c:	f41a                	sd	t1,40(sp)
    8000619e:	f81e                	sd	t2,48(sp)
    800061a0:	fc22                	sd	s0,56(sp)
    800061a2:	e0a6                	sd	s1,64(sp)
    800061a4:	e4aa                	sd	a0,72(sp)
    800061a6:	e8ae                	sd	a1,80(sp)
    800061a8:	ecb2                	sd	a2,88(sp)
    800061aa:	f0b6                	sd	a3,96(sp)
    800061ac:	f4ba                	sd	a4,104(sp)
    800061ae:	f8be                	sd	a5,112(sp)
    800061b0:	fcc2                	sd	a6,120(sp)
    800061b2:	e146                	sd	a7,128(sp)
    800061b4:	e54a                	sd	s2,136(sp)
    800061b6:	e94e                	sd	s3,144(sp)
    800061b8:	ed52                	sd	s4,152(sp)
    800061ba:	f156                	sd	s5,160(sp)
    800061bc:	f55a                	sd	s6,168(sp)
    800061be:	f95e                	sd	s7,176(sp)
    800061c0:	fd62                	sd	s8,184(sp)
    800061c2:	e1e6                	sd	s9,192(sp)
    800061c4:	e5ea                	sd	s10,200(sp)
    800061c6:	e9ee                	sd	s11,208(sp)
    800061c8:	edf2                	sd	t3,216(sp)
    800061ca:	f1f6                	sd	t4,224(sp)
    800061cc:	f5fa                	sd	t5,232(sp)
    800061ce:	f9fe                	sd	t6,240(sp)
    800061d0:	b35fc0ef          	jal	ra,80002d04 <kerneltrap>
    800061d4:	6082                	ld	ra,0(sp)
    800061d6:	6122                	ld	sp,8(sp)
    800061d8:	61c2                	ld	gp,16(sp)
    800061da:	7282                	ld	t0,32(sp)
    800061dc:	7322                	ld	t1,40(sp)
    800061de:	73c2                	ld	t2,48(sp)
    800061e0:	7462                	ld	s0,56(sp)
    800061e2:	6486                	ld	s1,64(sp)
    800061e4:	6526                	ld	a0,72(sp)
    800061e6:	65c6                	ld	a1,80(sp)
    800061e8:	6666                	ld	a2,88(sp)
    800061ea:	7686                	ld	a3,96(sp)
    800061ec:	7726                	ld	a4,104(sp)
    800061ee:	77c6                	ld	a5,112(sp)
    800061f0:	7866                	ld	a6,120(sp)
    800061f2:	688a                	ld	a7,128(sp)
    800061f4:	692a                	ld	s2,136(sp)
    800061f6:	69ca                	ld	s3,144(sp)
    800061f8:	6a6a                	ld	s4,152(sp)
    800061fa:	7a8a                	ld	s5,160(sp)
    800061fc:	7b2a                	ld	s6,168(sp)
    800061fe:	7bca                	ld	s7,176(sp)
    80006200:	7c6a                	ld	s8,184(sp)
    80006202:	6c8e                	ld	s9,192(sp)
    80006204:	6d2e                	ld	s10,200(sp)
    80006206:	6dce                	ld	s11,208(sp)
    80006208:	6e6e                	ld	t3,216(sp)
    8000620a:	7e8e                	ld	t4,224(sp)
    8000620c:	7f2e                	ld	t5,232(sp)
    8000620e:	7fce                	ld	t6,240(sp)
    80006210:	6111                	addi	sp,sp,256
    80006212:	10200073          	sret
    80006216:	00000013          	nop
    8000621a:	00000013          	nop
    8000621e:	0001                	nop

0000000080006220 <timervec>:
    80006220:	34051573          	csrrw	a0,mscratch,a0
    80006224:	e10c                	sd	a1,0(a0)
    80006226:	e510                	sd	a2,8(a0)
    80006228:	e914                	sd	a3,16(a0)
    8000622a:	6d0c                	ld	a1,24(a0)
    8000622c:	7110                	ld	a2,32(a0)
    8000622e:	6194                	ld	a3,0(a1)
    80006230:	96b2                	add	a3,a3,a2
    80006232:	e194                	sd	a3,0(a1)
    80006234:	4589                	li	a1,2
    80006236:	14459073          	csrw	sip,a1
    8000623a:	6914                	ld	a3,16(a0)
    8000623c:	6510                	ld	a2,8(a0)
    8000623e:	610c                	ld	a1,0(a0)
    80006240:	34051573          	csrrw	a0,mscratch,a0
    80006244:	30200073          	mret
	...

000000008000624a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000624a:	1141                	addi	sp,sp,-16
    8000624c:	e422                	sd	s0,8(sp)
    8000624e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006250:	0c0007b7          	lui	a5,0xc000
    80006254:	4705                	li	a4,1
    80006256:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006258:	c3d8                	sw	a4,4(a5)
}
    8000625a:	6422                	ld	s0,8(sp)
    8000625c:	0141                	addi	sp,sp,16
    8000625e:	8082                	ret

0000000080006260 <plicinithart>:

void
plicinithart(void)
{
    80006260:	1141                	addi	sp,sp,-16
    80006262:	e406                	sd	ra,8(sp)
    80006264:	e022                	sd	s0,0(sp)
    80006266:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006268:	ffffb097          	auipc	ra,0xffffb
    8000626c:	732080e7          	jalr	1842(ra) # 8000199a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006270:	0085171b          	slliw	a4,a0,0x8
    80006274:	0c0027b7          	lui	a5,0xc002
    80006278:	97ba                	add	a5,a5,a4
    8000627a:	40200713          	li	a4,1026
    8000627e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006282:	00d5151b          	slliw	a0,a0,0xd
    80006286:	0c2017b7          	lui	a5,0xc201
    8000628a:	953e                	add	a0,a0,a5
    8000628c:	00052023          	sw	zero,0(a0)
}
    80006290:	60a2                	ld	ra,8(sp)
    80006292:	6402                	ld	s0,0(sp)
    80006294:	0141                	addi	sp,sp,16
    80006296:	8082                	ret

0000000080006298 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006298:	1141                	addi	sp,sp,-16
    8000629a:	e406                	sd	ra,8(sp)
    8000629c:	e022                	sd	s0,0(sp)
    8000629e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800062a0:	ffffb097          	auipc	ra,0xffffb
    800062a4:	6fa080e7          	jalr	1786(ra) # 8000199a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800062a8:	00d5179b          	slliw	a5,a0,0xd
    800062ac:	0c201537          	lui	a0,0xc201
    800062b0:	953e                	add	a0,a0,a5
  return irq;
}
    800062b2:	4148                	lw	a0,4(a0)
    800062b4:	60a2                	ld	ra,8(sp)
    800062b6:	6402                	ld	s0,0(sp)
    800062b8:	0141                	addi	sp,sp,16
    800062ba:	8082                	ret

00000000800062bc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800062bc:	1101                	addi	sp,sp,-32
    800062be:	ec06                	sd	ra,24(sp)
    800062c0:	e822                	sd	s0,16(sp)
    800062c2:	e426                	sd	s1,8(sp)
    800062c4:	1000                	addi	s0,sp,32
    800062c6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800062c8:	ffffb097          	auipc	ra,0xffffb
    800062cc:	6d2080e7          	jalr	1746(ra) # 8000199a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800062d0:	00d5151b          	slliw	a0,a0,0xd
    800062d4:	0c2017b7          	lui	a5,0xc201
    800062d8:	97aa                	add	a5,a5,a0
    800062da:	c3c4                	sw	s1,4(a5)
}
    800062dc:	60e2                	ld	ra,24(sp)
    800062de:	6442                	ld	s0,16(sp)
    800062e0:	64a2                	ld	s1,8(sp)
    800062e2:	6105                	addi	sp,sp,32
    800062e4:	8082                	ret

00000000800062e6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800062e6:	1141                	addi	sp,sp,-16
    800062e8:	e406                	sd	ra,8(sp)
    800062ea:	e022                	sd	s0,0(sp)
    800062ec:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800062ee:	479d                	li	a5,7
    800062f0:	04a7cc63          	blt	a5,a0,80006348 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800062f4:	0001e797          	auipc	a5,0x1e
    800062f8:	9ec78793          	addi	a5,a5,-1556 # 80023ce0 <disk>
    800062fc:	97aa                	add	a5,a5,a0
    800062fe:	0187c783          	lbu	a5,24(a5)
    80006302:	ebb9                	bnez	a5,80006358 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006304:	00451613          	slli	a2,a0,0x4
    80006308:	0001e797          	auipc	a5,0x1e
    8000630c:	9d878793          	addi	a5,a5,-1576 # 80023ce0 <disk>
    80006310:	6394                	ld	a3,0(a5)
    80006312:	96b2                	add	a3,a3,a2
    80006314:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006318:	6398                	ld	a4,0(a5)
    8000631a:	9732                	add	a4,a4,a2
    8000631c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006320:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006324:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006328:	953e                	add	a0,a0,a5
    8000632a:	4785                	li	a5,1
    8000632c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006330:	0001e517          	auipc	a0,0x1e
    80006334:	9c850513          	addi	a0,a0,-1592 # 80023cf8 <disk+0x18>
    80006338:	ffffc097          	auipc	ra,0xffffc
    8000633c:	080080e7          	jalr	128(ra) # 800023b8 <wakeup>
}
    80006340:	60a2                	ld	ra,8(sp)
    80006342:	6402                	ld	s0,0(sp)
    80006344:	0141                	addi	sp,sp,16
    80006346:	8082                	ret
    panic("free_desc 1");
    80006348:	00002517          	auipc	a0,0x2
    8000634c:	5c850513          	addi	a0,a0,1480 # 80008910 <syscallnum+0x2a8>
    80006350:	ffffa097          	auipc	ra,0xffffa
    80006354:	1f4080e7          	jalr	500(ra) # 80000544 <panic>
    panic("free_desc 2");
    80006358:	00002517          	auipc	a0,0x2
    8000635c:	5c850513          	addi	a0,a0,1480 # 80008920 <syscallnum+0x2b8>
    80006360:	ffffa097          	auipc	ra,0xffffa
    80006364:	1e4080e7          	jalr	484(ra) # 80000544 <panic>

0000000080006368 <virtio_disk_init>:
{
    80006368:	1101                	addi	sp,sp,-32
    8000636a:	ec06                	sd	ra,24(sp)
    8000636c:	e822                	sd	s0,16(sp)
    8000636e:	e426                	sd	s1,8(sp)
    80006370:	e04a                	sd	s2,0(sp)
    80006372:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006374:	00002597          	auipc	a1,0x2
    80006378:	5bc58593          	addi	a1,a1,1468 # 80008930 <syscallnum+0x2c8>
    8000637c:	0001e517          	auipc	a0,0x1e
    80006380:	a8c50513          	addi	a0,a0,-1396 # 80023e08 <disk+0x128>
    80006384:	ffffa097          	auipc	ra,0xffffa
    80006388:	7d6080e7          	jalr	2006(ra) # 80000b5a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000638c:	100017b7          	lui	a5,0x10001
    80006390:	4398                	lw	a4,0(a5)
    80006392:	2701                	sext.w	a4,a4
    80006394:	747277b7          	lui	a5,0x74727
    80006398:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000639c:	14f71e63          	bne	a4,a5,800064f8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800063a0:	100017b7          	lui	a5,0x10001
    800063a4:	43dc                	lw	a5,4(a5)
    800063a6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800063a8:	4709                	li	a4,2
    800063aa:	14e79763          	bne	a5,a4,800064f8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800063ae:	100017b7          	lui	a5,0x10001
    800063b2:	479c                	lw	a5,8(a5)
    800063b4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800063b6:	14e79163          	bne	a5,a4,800064f8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800063ba:	100017b7          	lui	a5,0x10001
    800063be:	47d8                	lw	a4,12(a5)
    800063c0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800063c2:	554d47b7          	lui	a5,0x554d4
    800063c6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800063ca:	12f71763          	bne	a4,a5,800064f8 <virtio_disk_init+0x190>
  *R(VIRTIO_MMIO_STATUS) = status;
    800063ce:	100017b7          	lui	a5,0x10001
    800063d2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800063d6:	4705                	li	a4,1
    800063d8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800063da:	470d                	li	a4,3
    800063dc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800063de:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800063e0:	c7ffe737          	lui	a4,0xc7ffe
    800063e4:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fda93f>
    800063e8:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800063ea:	2701                	sext.w	a4,a4
    800063ec:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800063ee:	472d                	li	a4,11
    800063f0:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800063f2:	0707a903          	lw	s2,112(a5)
    800063f6:	2901                	sext.w	s2,s2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800063f8:	00897793          	andi	a5,s2,8
    800063fc:	10078663          	beqz	a5,80006508 <virtio_disk_init+0x1a0>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006400:	100017b7          	lui	a5,0x10001
    80006404:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006408:	43fc                	lw	a5,68(a5)
    8000640a:	2781                	sext.w	a5,a5
    8000640c:	10079663          	bnez	a5,80006518 <virtio_disk_init+0x1b0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006410:	100017b7          	lui	a5,0x10001
    80006414:	5bdc                	lw	a5,52(a5)
    80006416:	2781                	sext.w	a5,a5
  if(max == 0)
    80006418:	10078863          	beqz	a5,80006528 <virtio_disk_init+0x1c0>
  if(max < NUM)
    8000641c:	471d                	li	a4,7
    8000641e:	10f77d63          	bgeu	a4,a5,80006538 <virtio_disk_init+0x1d0>
  disk.desc = kalloc();
    80006422:	ffffa097          	auipc	ra,0xffffa
    80006426:	6d8080e7          	jalr	1752(ra) # 80000afa <kalloc>
    8000642a:	0001e497          	auipc	s1,0x1e
    8000642e:	8b648493          	addi	s1,s1,-1866 # 80023ce0 <disk>
    80006432:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006434:	ffffa097          	auipc	ra,0xffffa
    80006438:	6c6080e7          	jalr	1734(ra) # 80000afa <kalloc>
    8000643c:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000643e:	ffffa097          	auipc	ra,0xffffa
    80006442:	6bc080e7          	jalr	1724(ra) # 80000afa <kalloc>
    80006446:	87aa                	mv	a5,a0
    80006448:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    8000644a:	6088                	ld	a0,0(s1)
    8000644c:	cd75                	beqz	a0,80006548 <virtio_disk_init+0x1e0>
    8000644e:	0001e717          	auipc	a4,0x1e
    80006452:	89a73703          	ld	a4,-1894(a4) # 80023ce8 <disk+0x8>
    80006456:	cb6d                	beqz	a4,80006548 <virtio_disk_init+0x1e0>
    80006458:	cbe5                	beqz	a5,80006548 <virtio_disk_init+0x1e0>
  memset(disk.desc, 0, PGSIZE);
    8000645a:	6605                	lui	a2,0x1
    8000645c:	4581                	li	a1,0
    8000645e:	ffffb097          	auipc	ra,0xffffb
    80006462:	888080e7          	jalr	-1912(ra) # 80000ce6 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006466:	0001e497          	auipc	s1,0x1e
    8000646a:	87a48493          	addi	s1,s1,-1926 # 80023ce0 <disk>
    8000646e:	6605                	lui	a2,0x1
    80006470:	4581                	li	a1,0
    80006472:	6488                	ld	a0,8(s1)
    80006474:	ffffb097          	auipc	ra,0xffffb
    80006478:	872080e7          	jalr	-1934(ra) # 80000ce6 <memset>
  memset(disk.used, 0, PGSIZE);
    8000647c:	6605                	lui	a2,0x1
    8000647e:	4581                	li	a1,0
    80006480:	6888                	ld	a0,16(s1)
    80006482:	ffffb097          	auipc	ra,0xffffb
    80006486:	864080e7          	jalr	-1948(ra) # 80000ce6 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000648a:	100017b7          	lui	a5,0x10001
    8000648e:	4721                	li	a4,8
    80006490:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006492:	4098                	lw	a4,0(s1)
    80006494:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006498:	40d8                	lw	a4,4(s1)
    8000649a:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000649e:	6498                	ld	a4,8(s1)
    800064a0:	0007069b          	sext.w	a3,a4
    800064a4:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800064a8:	9701                	srai	a4,a4,0x20
    800064aa:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800064ae:	6898                	ld	a4,16(s1)
    800064b0:	0007069b          	sext.w	a3,a4
    800064b4:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800064b8:	9701                	srai	a4,a4,0x20
    800064ba:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800064be:	4685                	li	a3,1
    800064c0:	c3f4                	sw	a3,68(a5)
    disk.free[i] = 1;
    800064c2:	4705                	li	a4,1
    800064c4:	00d48c23          	sb	a3,24(s1)
    800064c8:	00e48ca3          	sb	a4,25(s1)
    800064cc:	00e48d23          	sb	a4,26(s1)
    800064d0:	00e48da3          	sb	a4,27(s1)
    800064d4:	00e48e23          	sb	a4,28(s1)
    800064d8:	00e48ea3          	sb	a4,29(s1)
    800064dc:	00e48f23          	sb	a4,30(s1)
    800064e0:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800064e4:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800064e8:	0727a823          	sw	s2,112(a5)
}
    800064ec:	60e2                	ld	ra,24(sp)
    800064ee:	6442                	ld	s0,16(sp)
    800064f0:	64a2                	ld	s1,8(sp)
    800064f2:	6902                	ld	s2,0(sp)
    800064f4:	6105                	addi	sp,sp,32
    800064f6:	8082                	ret
    panic("could not find virtio disk");
    800064f8:	00002517          	auipc	a0,0x2
    800064fc:	44850513          	addi	a0,a0,1096 # 80008940 <syscallnum+0x2d8>
    80006500:	ffffa097          	auipc	ra,0xffffa
    80006504:	044080e7          	jalr	68(ra) # 80000544 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006508:	00002517          	auipc	a0,0x2
    8000650c:	45850513          	addi	a0,a0,1112 # 80008960 <syscallnum+0x2f8>
    80006510:	ffffa097          	auipc	ra,0xffffa
    80006514:	034080e7          	jalr	52(ra) # 80000544 <panic>
    panic("virtio disk should not be ready");
    80006518:	00002517          	auipc	a0,0x2
    8000651c:	46850513          	addi	a0,a0,1128 # 80008980 <syscallnum+0x318>
    80006520:	ffffa097          	auipc	ra,0xffffa
    80006524:	024080e7          	jalr	36(ra) # 80000544 <panic>
    panic("virtio disk has no queue 0");
    80006528:	00002517          	auipc	a0,0x2
    8000652c:	47850513          	addi	a0,a0,1144 # 800089a0 <syscallnum+0x338>
    80006530:	ffffa097          	auipc	ra,0xffffa
    80006534:	014080e7          	jalr	20(ra) # 80000544 <panic>
    panic("virtio disk max queue too short");
    80006538:	00002517          	auipc	a0,0x2
    8000653c:	48850513          	addi	a0,a0,1160 # 800089c0 <syscallnum+0x358>
    80006540:	ffffa097          	auipc	ra,0xffffa
    80006544:	004080e7          	jalr	4(ra) # 80000544 <panic>
    panic("virtio disk kalloc");
    80006548:	00002517          	auipc	a0,0x2
    8000654c:	49850513          	addi	a0,a0,1176 # 800089e0 <syscallnum+0x378>
    80006550:	ffffa097          	auipc	ra,0xffffa
    80006554:	ff4080e7          	jalr	-12(ra) # 80000544 <panic>

0000000080006558 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006558:	7159                	addi	sp,sp,-112
    8000655a:	f486                	sd	ra,104(sp)
    8000655c:	f0a2                	sd	s0,96(sp)
    8000655e:	eca6                	sd	s1,88(sp)
    80006560:	e8ca                	sd	s2,80(sp)
    80006562:	e4ce                	sd	s3,72(sp)
    80006564:	e0d2                	sd	s4,64(sp)
    80006566:	fc56                	sd	s5,56(sp)
    80006568:	f85a                	sd	s6,48(sp)
    8000656a:	f45e                	sd	s7,40(sp)
    8000656c:	f062                	sd	s8,32(sp)
    8000656e:	ec66                	sd	s9,24(sp)
    80006570:	e86a                	sd	s10,16(sp)
    80006572:	1880                	addi	s0,sp,112
    80006574:	892a                	mv	s2,a0
    80006576:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006578:	00c52c83          	lw	s9,12(a0)
    8000657c:	001c9c9b          	slliw	s9,s9,0x1
    80006580:	1c82                	slli	s9,s9,0x20
    80006582:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006586:	0001e517          	auipc	a0,0x1e
    8000658a:	88250513          	addi	a0,a0,-1918 # 80023e08 <disk+0x128>
    8000658e:	ffffa097          	auipc	ra,0xffffa
    80006592:	65c080e7          	jalr	1628(ra) # 80000bea <acquire>
  for(int i = 0; i < 3; i++){
    80006596:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006598:	4ba1                	li	s7,8
      disk.free[i] = 0;
    8000659a:	0001db17          	auipc	s6,0x1d
    8000659e:	746b0b13          	addi	s6,s6,1862 # 80023ce0 <disk>
  for(int i = 0; i < 3; i++){
    800065a2:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    800065a4:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800065a6:	0001ec17          	auipc	s8,0x1e
    800065aa:	862c0c13          	addi	s8,s8,-1950 # 80023e08 <disk+0x128>
    800065ae:	a8b5                	j	8000662a <virtio_disk_rw+0xd2>
      disk.free[i] = 0;
    800065b0:	00fb06b3          	add	a3,s6,a5
    800065b4:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    800065b8:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    800065ba:	0207c563          	bltz	a5,800065e4 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800065be:	2485                	addiw	s1,s1,1
    800065c0:	0711                	addi	a4,a4,4
    800065c2:	1f548a63          	beq	s1,s5,800067b6 <virtio_disk_rw+0x25e>
    idx[i] = alloc_desc();
    800065c6:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    800065c8:	0001d697          	auipc	a3,0x1d
    800065cc:	71868693          	addi	a3,a3,1816 # 80023ce0 <disk>
    800065d0:	87d2                	mv	a5,s4
    if(disk.free[i]){
    800065d2:	0186c583          	lbu	a1,24(a3)
    800065d6:	fde9                	bnez	a1,800065b0 <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800065d8:	2785                	addiw	a5,a5,1
    800065da:	0685                	addi	a3,a3,1
    800065dc:	ff779be3          	bne	a5,s7,800065d2 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800065e0:	57fd                	li	a5,-1
    800065e2:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    800065e4:	02905a63          	blez	s1,80006618 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800065e8:	f9042503          	lw	a0,-112(s0)
    800065ec:	00000097          	auipc	ra,0x0
    800065f0:	cfa080e7          	jalr	-774(ra) # 800062e6 <free_desc>
      for(int j = 0; j < i; j++)
    800065f4:	4785                	li	a5,1
    800065f6:	0297d163          	bge	a5,s1,80006618 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800065fa:	f9442503          	lw	a0,-108(s0)
    800065fe:	00000097          	auipc	ra,0x0
    80006602:	ce8080e7          	jalr	-792(ra) # 800062e6 <free_desc>
      for(int j = 0; j < i; j++)
    80006606:	4789                	li	a5,2
    80006608:	0097d863          	bge	a5,s1,80006618 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000660c:	f9842503          	lw	a0,-104(s0)
    80006610:	00000097          	auipc	ra,0x0
    80006614:	cd6080e7          	jalr	-810(ra) # 800062e6 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006618:	85e2                	mv	a1,s8
    8000661a:	0001d517          	auipc	a0,0x1d
    8000661e:	6de50513          	addi	a0,a0,1758 # 80023cf8 <disk+0x18>
    80006622:	ffffc097          	auipc	ra,0xffffc
    80006626:	be6080e7          	jalr	-1050(ra) # 80002208 <sleep>
  for(int i = 0; i < 3; i++){
    8000662a:	f9040713          	addi	a4,s0,-112
    8000662e:	84ce                	mv	s1,s3
    80006630:	bf59                	j	800065c6 <virtio_disk_rw+0x6e>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80006632:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    80006636:	00479693          	slli	a3,a5,0x4
    8000663a:	0001d797          	auipc	a5,0x1d
    8000663e:	6a678793          	addi	a5,a5,1702 # 80023ce0 <disk>
    80006642:	97b6                	add	a5,a5,a3
    80006644:	4685                	li	a3,1
    80006646:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006648:	0001d597          	auipc	a1,0x1d
    8000664c:	69858593          	addi	a1,a1,1688 # 80023ce0 <disk>
    80006650:	00a60793          	addi	a5,a2,10
    80006654:	0792                	slli	a5,a5,0x4
    80006656:	97ae                	add	a5,a5,a1
    80006658:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    8000665c:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006660:	f6070693          	addi	a3,a4,-160
    80006664:	619c                	ld	a5,0(a1)
    80006666:	97b6                	add	a5,a5,a3
    80006668:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000666a:	6188                	ld	a0,0(a1)
    8000666c:	96aa                	add	a3,a3,a0
    8000666e:	47c1                	li	a5,16
    80006670:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006672:	4785                	li	a5,1
    80006674:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006678:	f9442783          	lw	a5,-108(s0)
    8000667c:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006680:	0792                	slli	a5,a5,0x4
    80006682:	953e                	add	a0,a0,a5
    80006684:	05890693          	addi	a3,s2,88
    80006688:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000668a:	6188                	ld	a0,0(a1)
    8000668c:	97aa                	add	a5,a5,a0
    8000668e:	40000693          	li	a3,1024
    80006692:	c794                	sw	a3,8(a5)
  if(write)
    80006694:	100d0d63          	beqz	s10,800067ae <virtio_disk_rw+0x256>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006698:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000669c:	00c7d683          	lhu	a3,12(a5)
    800066a0:	0016e693          	ori	a3,a3,1
    800066a4:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    800066a8:	f9842583          	lw	a1,-104(s0)
    800066ac:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800066b0:	0001d697          	auipc	a3,0x1d
    800066b4:	63068693          	addi	a3,a3,1584 # 80023ce0 <disk>
    800066b8:	00260793          	addi	a5,a2,2
    800066bc:	0792                	slli	a5,a5,0x4
    800066be:	97b6                	add	a5,a5,a3
    800066c0:	587d                	li	a6,-1
    800066c2:	01078823          	sb	a6,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800066c6:	0592                	slli	a1,a1,0x4
    800066c8:	952e                	add	a0,a0,a1
    800066ca:	f9070713          	addi	a4,a4,-112
    800066ce:	9736                	add	a4,a4,a3
    800066d0:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    800066d2:	6298                	ld	a4,0(a3)
    800066d4:	972e                	add	a4,a4,a1
    800066d6:	4585                	li	a1,1
    800066d8:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800066da:	4509                	li	a0,2
    800066dc:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    800066e0:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800066e4:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    800066e8:	0127b423          	sd	s2,8(a5)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800066ec:	6698                	ld	a4,8(a3)
    800066ee:	00275783          	lhu	a5,2(a4)
    800066f2:	8b9d                	andi	a5,a5,7
    800066f4:	0786                	slli	a5,a5,0x1
    800066f6:	97ba                	add	a5,a5,a4
    800066f8:	00c79223          	sh	a2,4(a5)

  __sync_synchronize();
    800066fc:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006700:	6698                	ld	a4,8(a3)
    80006702:	00275783          	lhu	a5,2(a4)
    80006706:	2785                	addiw	a5,a5,1
    80006708:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000670c:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006710:	100017b7          	lui	a5,0x10001
    80006714:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006718:	00492703          	lw	a4,4(s2)
    8000671c:	4785                	li	a5,1
    8000671e:	02f71163          	bne	a4,a5,80006740 <virtio_disk_rw+0x1e8>
    sleep(b, &disk.vdisk_lock);
    80006722:	0001d997          	auipc	s3,0x1d
    80006726:	6e698993          	addi	s3,s3,1766 # 80023e08 <disk+0x128>
  while(b->disk == 1) {
    8000672a:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000672c:	85ce                	mv	a1,s3
    8000672e:	854a                	mv	a0,s2
    80006730:	ffffc097          	auipc	ra,0xffffc
    80006734:	ad8080e7          	jalr	-1320(ra) # 80002208 <sleep>
  while(b->disk == 1) {
    80006738:	00492783          	lw	a5,4(s2)
    8000673c:	fe9788e3          	beq	a5,s1,8000672c <virtio_disk_rw+0x1d4>
  }

  disk.info[idx[0]].b = 0;
    80006740:	f9042903          	lw	s2,-112(s0)
    80006744:	00290793          	addi	a5,s2,2
    80006748:	00479713          	slli	a4,a5,0x4
    8000674c:	0001d797          	auipc	a5,0x1d
    80006750:	59478793          	addi	a5,a5,1428 # 80023ce0 <disk>
    80006754:	97ba                	add	a5,a5,a4
    80006756:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000675a:	0001d997          	auipc	s3,0x1d
    8000675e:	58698993          	addi	s3,s3,1414 # 80023ce0 <disk>
    80006762:	00491713          	slli	a4,s2,0x4
    80006766:	0009b783          	ld	a5,0(s3)
    8000676a:	97ba                	add	a5,a5,a4
    8000676c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006770:	854a                	mv	a0,s2
    80006772:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006776:	00000097          	auipc	ra,0x0
    8000677a:	b70080e7          	jalr	-1168(ra) # 800062e6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000677e:	8885                	andi	s1,s1,1
    80006780:	f0ed                	bnez	s1,80006762 <virtio_disk_rw+0x20a>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006782:	0001d517          	auipc	a0,0x1d
    80006786:	68650513          	addi	a0,a0,1670 # 80023e08 <disk+0x128>
    8000678a:	ffffa097          	auipc	ra,0xffffa
    8000678e:	514080e7          	jalr	1300(ra) # 80000c9e <release>
}
    80006792:	70a6                	ld	ra,104(sp)
    80006794:	7406                	ld	s0,96(sp)
    80006796:	64e6                	ld	s1,88(sp)
    80006798:	6946                	ld	s2,80(sp)
    8000679a:	69a6                	ld	s3,72(sp)
    8000679c:	6a06                	ld	s4,64(sp)
    8000679e:	7ae2                	ld	s5,56(sp)
    800067a0:	7b42                	ld	s6,48(sp)
    800067a2:	7ba2                	ld	s7,40(sp)
    800067a4:	7c02                	ld	s8,32(sp)
    800067a6:	6ce2                	ld	s9,24(sp)
    800067a8:	6d42                	ld	s10,16(sp)
    800067aa:	6165                	addi	sp,sp,112
    800067ac:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800067ae:	4689                	li	a3,2
    800067b0:	00d79623          	sh	a3,12(a5)
    800067b4:	b5e5                	j	8000669c <virtio_disk_rw+0x144>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800067b6:	f9042603          	lw	a2,-112(s0)
    800067ba:	00a60713          	addi	a4,a2,10
    800067be:	0712                	slli	a4,a4,0x4
    800067c0:	0001d517          	auipc	a0,0x1d
    800067c4:	52850513          	addi	a0,a0,1320 # 80023ce8 <disk+0x8>
    800067c8:	953a                	add	a0,a0,a4
  if(write)
    800067ca:	e60d14e3          	bnez	s10,80006632 <virtio_disk_rw+0xda>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    800067ce:	00a60793          	addi	a5,a2,10
    800067d2:	00479693          	slli	a3,a5,0x4
    800067d6:	0001d797          	auipc	a5,0x1d
    800067da:	50a78793          	addi	a5,a5,1290 # 80023ce0 <disk>
    800067de:	97b6                	add	a5,a5,a3
    800067e0:	0007a423          	sw	zero,8(a5)
    800067e4:	b595                	j	80006648 <virtio_disk_rw+0xf0>

00000000800067e6 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800067e6:	1101                	addi	sp,sp,-32
    800067e8:	ec06                	sd	ra,24(sp)
    800067ea:	e822                	sd	s0,16(sp)
    800067ec:	e426                	sd	s1,8(sp)
    800067ee:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800067f0:	0001d497          	auipc	s1,0x1d
    800067f4:	4f048493          	addi	s1,s1,1264 # 80023ce0 <disk>
    800067f8:	0001d517          	auipc	a0,0x1d
    800067fc:	61050513          	addi	a0,a0,1552 # 80023e08 <disk+0x128>
    80006800:	ffffa097          	auipc	ra,0xffffa
    80006804:	3ea080e7          	jalr	1002(ra) # 80000bea <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006808:	10001737          	lui	a4,0x10001
    8000680c:	533c                	lw	a5,96(a4)
    8000680e:	8b8d                	andi	a5,a5,3
    80006810:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006812:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006816:	689c                	ld	a5,16(s1)
    80006818:	0204d703          	lhu	a4,32(s1)
    8000681c:	0027d783          	lhu	a5,2(a5)
    80006820:	04f70863          	beq	a4,a5,80006870 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006824:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006828:	6898                	ld	a4,16(s1)
    8000682a:	0204d783          	lhu	a5,32(s1)
    8000682e:	8b9d                	andi	a5,a5,7
    80006830:	078e                	slli	a5,a5,0x3
    80006832:	97ba                	add	a5,a5,a4
    80006834:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006836:	00278713          	addi	a4,a5,2
    8000683a:	0712                	slli	a4,a4,0x4
    8000683c:	9726                	add	a4,a4,s1
    8000683e:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006842:	e721                	bnez	a4,8000688a <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006844:	0789                	addi	a5,a5,2
    80006846:	0792                	slli	a5,a5,0x4
    80006848:	97a6                	add	a5,a5,s1
    8000684a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000684c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006850:	ffffc097          	auipc	ra,0xffffc
    80006854:	b68080e7          	jalr	-1176(ra) # 800023b8 <wakeup>

    disk.used_idx += 1;
    80006858:	0204d783          	lhu	a5,32(s1)
    8000685c:	2785                	addiw	a5,a5,1
    8000685e:	17c2                	slli	a5,a5,0x30
    80006860:	93c1                	srli	a5,a5,0x30
    80006862:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006866:	6898                	ld	a4,16(s1)
    80006868:	00275703          	lhu	a4,2(a4)
    8000686c:	faf71ce3          	bne	a4,a5,80006824 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006870:	0001d517          	auipc	a0,0x1d
    80006874:	59850513          	addi	a0,a0,1432 # 80023e08 <disk+0x128>
    80006878:	ffffa097          	auipc	ra,0xffffa
    8000687c:	426080e7          	jalr	1062(ra) # 80000c9e <release>
}
    80006880:	60e2                	ld	ra,24(sp)
    80006882:	6442                	ld	s0,16(sp)
    80006884:	64a2                	ld	s1,8(sp)
    80006886:	6105                	addi	sp,sp,32
    80006888:	8082                	ret
      panic("virtio_disk_intr status");
    8000688a:	00002517          	auipc	a0,0x2
    8000688e:	16e50513          	addi	a0,a0,366 # 800089f8 <syscallnum+0x390>
    80006892:	ffffa097          	auipc	ra,0xffffa
    80006896:	cb2080e7          	jalr	-846(ra) # 80000544 <panic>
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

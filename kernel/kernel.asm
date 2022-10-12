
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
    80000068:	18c78793          	addi	a5,a5,396 # 800061f0 <timervec>
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
    80000130:	652080e7          	jalr	1618(ra) # 8000277e <either_copyin>
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
    80000190:	b2450513          	addi	a0,a0,-1244 # 80010cb0 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	a56080e7          	jalr	-1450(ra) # 80000bea <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019c:	00011497          	auipc	s1,0x11
    800001a0:	b1448493          	addi	s1,s1,-1260 # 80010cb0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a4:	89a6                	mv	s3,s1
    800001a6:	00011917          	auipc	s2,0x11
    800001aa:	ba290913          	addi	s2,s2,-1118 # 80010d48 <cons+0x98>
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
    800001d0:	3fc080e7          	jalr	1020(ra) # 800025c8 <killed>
    800001d4:	e535                	bnez	a0,80000240 <consoleread+0xdc>
      sleep(&cons.r, &cons.lock);
    800001d6:	85ce                	mv	a1,s3
    800001d8:	854a                	mv	a0,s2
    800001da:	00002097          	auipc	ra,0x2
    800001de:	fee080e7          	jalr	-18(ra) # 800021c8 <sleep>
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
    8000021a:	512080e7          	jalr	1298(ra) # 80002728 <either_copyout>
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
    8000022e:	a8650513          	addi	a0,a0,-1402 # 80010cb0 <cons>
    80000232:	00001097          	auipc	ra,0x1
    80000236:	a6c080e7          	jalr	-1428(ra) # 80000c9e <release>

  return target - n;
    8000023a:	414b853b          	subw	a0,s7,s4
    8000023e:	a811                	j	80000252 <consoleread+0xee>
        release(&cons.lock);
    80000240:	00011517          	auipc	a0,0x11
    80000244:	a7050513          	addi	a0,a0,-1424 # 80010cb0 <cons>
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
    8000027c:	acf72823          	sw	a5,-1328(a4) # 80010d48 <cons+0x98>
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
    800002d6:	9de50513          	addi	a0,a0,-1570 # 80010cb0 <cons>
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
    800002fc:	4dc080e7          	jalr	1244(ra) # 800027d4 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000300:	00011517          	auipc	a0,0x11
    80000304:	9b050513          	addi	a0,a0,-1616 # 80010cb0 <cons>
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
    80000328:	98c70713          	addi	a4,a4,-1652 # 80010cb0 <cons>
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
    80000352:	96278793          	addi	a5,a5,-1694 # 80010cb0 <cons>
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
    80000380:	9cc7a783          	lw	a5,-1588(a5) # 80010d48 <cons+0x98>
    80000384:	9f1d                	subw	a4,a4,a5
    80000386:	08000793          	li	a5,128
    8000038a:	f6f71be3          	bne	a4,a5,80000300 <consoleintr+0x3c>
    8000038e:	a07d                	j	8000043c <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000390:	00011717          	auipc	a4,0x11
    80000394:	92070713          	addi	a4,a4,-1760 # 80010cb0 <cons>
    80000398:	0a072783          	lw	a5,160(a4)
    8000039c:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a0:	00011497          	auipc	s1,0x11
    800003a4:	91048493          	addi	s1,s1,-1776 # 80010cb0 <cons>
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
    800003e0:	8d470713          	addi	a4,a4,-1836 # 80010cb0 <cons>
    800003e4:	0a072783          	lw	a5,160(a4)
    800003e8:	09c72703          	lw	a4,156(a4)
    800003ec:	f0f70ae3          	beq	a4,a5,80000300 <consoleintr+0x3c>
      cons.e--;
    800003f0:	37fd                	addiw	a5,a5,-1
    800003f2:	00011717          	auipc	a4,0x11
    800003f6:	94f72f23          	sw	a5,-1698(a4) # 80010d50 <cons+0xa0>
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
    8000041c:	89878793          	addi	a5,a5,-1896 # 80010cb0 <cons>
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
    80000440:	90c7a823          	sw	a2,-1776(a5) # 80010d4c <cons+0x9c>
        wakeup(&cons.r);
    80000444:	00011517          	auipc	a0,0x11
    80000448:	90450513          	addi	a0,a0,-1788 # 80010d48 <cons+0x98>
    8000044c:	00002097          	auipc	ra,0x2
    80000450:	f2c080e7          	jalr	-212(ra) # 80002378 <wakeup>
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
    8000046a:	84a50513          	addi	a0,a0,-1974 # 80010cb0 <cons>
    8000046e:	00000097          	auipc	ra,0x0
    80000472:	6ec080e7          	jalr	1772(ra) # 80000b5a <initlock>

  uartinit();
    80000476:	00000097          	auipc	ra,0x0
    8000047a:	330080e7          	jalr	816(ra) # 800007a6 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000047e:	00022797          	auipc	a5,0x22
    80000482:	7ca78793          	addi	a5,a5,1994 # 80022c48 <devsw>
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
    80000554:	8207a023          	sw	zero,-2016(a5) # 80010d70 <pr+0x18>
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
    80000588:	5af72623          	sw	a5,1452(a4) # 80008b30 <panicked>
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
    800005c4:	7b0dad83          	lw	s11,1968(s11) # 80010d70 <pr+0x18>
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
    80000602:	75a50513          	addi	a0,a0,1882 # 80010d58 <pr>
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
    80000766:	5f650513          	addi	a0,a0,1526 # 80010d58 <pr>
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
    80000782:	5da48493          	addi	s1,s1,1498 # 80010d58 <pr>
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
    800007e2:	59a50513          	addi	a0,a0,1434 # 80010d78 <uart_tx_lock>
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
    8000080e:	3267a783          	lw	a5,806(a5) # 80008b30 <panicked>
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
    8000084a:	2f273703          	ld	a4,754(a4) # 80008b38 <uart_tx_r>
    8000084e:	00008797          	auipc	a5,0x8
    80000852:	2f27b783          	ld	a5,754(a5) # 80008b40 <uart_tx_w>
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
    80000874:	508a0a13          	addi	s4,s4,1288 # 80010d78 <uart_tx_lock>
    uart_tx_r += 1;
    80000878:	00008497          	auipc	s1,0x8
    8000087c:	2c048493          	addi	s1,s1,704 # 80008b38 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000880:	00008997          	auipc	s3,0x8
    80000884:	2c098993          	addi	s3,s3,704 # 80008b40 <uart_tx_w>
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
    800008aa:	ad2080e7          	jalr	-1326(ra) # 80002378 <wakeup>
    
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
    800008e6:	49650513          	addi	a0,a0,1174 # 80010d78 <uart_tx_lock>
    800008ea:	00000097          	auipc	ra,0x0
    800008ee:	300080e7          	jalr	768(ra) # 80000bea <acquire>
  if(panicked){
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	23e7a783          	lw	a5,574(a5) # 80008b30 <panicked>
    800008fa:	e7c9                	bnez	a5,80000984 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fc:	00008797          	auipc	a5,0x8
    80000900:	2447b783          	ld	a5,580(a5) # 80008b40 <uart_tx_w>
    80000904:	00008717          	auipc	a4,0x8
    80000908:	23473703          	ld	a4,564(a4) # 80008b38 <uart_tx_r>
    8000090c:	02070713          	addi	a4,a4,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000910:	00010a17          	auipc	s4,0x10
    80000914:	468a0a13          	addi	s4,s4,1128 # 80010d78 <uart_tx_lock>
    80000918:	00008497          	auipc	s1,0x8
    8000091c:	22048493          	addi	s1,s1,544 # 80008b38 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000920:	00008917          	auipc	s2,0x8
    80000924:	22090913          	addi	s2,s2,544 # 80008b40 <uart_tx_w>
    80000928:	00f71f63          	bne	a4,a5,80000946 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000092c:	85d2                	mv	a1,s4
    8000092e:	8526                	mv	a0,s1
    80000930:	00002097          	auipc	ra,0x2
    80000934:	898080e7          	jalr	-1896(ra) # 800021c8 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000938:	00093783          	ld	a5,0(s2)
    8000093c:	6098                	ld	a4,0(s1)
    8000093e:	02070713          	addi	a4,a4,32
    80000942:	fef705e3          	beq	a4,a5,8000092c <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000946:	00010497          	auipc	s1,0x10
    8000094a:	43248493          	addi	s1,s1,1074 # 80010d78 <uart_tx_lock>
    8000094e:	01f7f713          	andi	a4,a5,31
    80000952:	9726                	add	a4,a4,s1
    80000954:	01370c23          	sb	s3,24(a4)
  uart_tx_w += 1;
    80000958:	0785                	addi	a5,a5,1
    8000095a:	00008717          	auipc	a4,0x8
    8000095e:	1ef73323          	sd	a5,486(a4) # 80008b40 <uart_tx_w>
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
    800009d4:	3a848493          	addi	s1,s1,936 # 80010d78 <uart_tx_lock>
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
    80000a16:	3ce78793          	addi	a5,a5,974 # 80023de0 <end>
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
    80000a36:	37e90913          	addi	s2,s2,894 # 80010db0 <kmem>
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
    80000ad2:	2e250513          	addi	a0,a0,738 # 80010db0 <kmem>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	084080e7          	jalr	132(ra) # 80000b5a <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ade:	45c5                	li	a1,17
    80000ae0:	05ee                	slli	a1,a1,0x1b
    80000ae2:	00023517          	auipc	a0,0x23
    80000ae6:	2fe50513          	addi	a0,a0,766 # 80023de0 <end>
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
    80000b08:	2ac48493          	addi	s1,s1,684 # 80010db0 <kmem>
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
    80000b20:	29450513          	addi	a0,a0,660 # 80010db0 <kmem>
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
    80000b4c:	26850513          	addi	a0,a0,616 # 80010db0 <kmem>
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
    80000ea8:	ca470713          	addi	a4,a4,-860 # 80008b48 <started>
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
    80000ede:	abe080e7          	jalr	-1346(ra) # 80002998 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ee2:	00005097          	auipc	ra,0x5
    80000ee6:	34e080e7          	jalr	846(ra) # 80006230 <plicinithart>
  }

  scheduler();        
    80000eea:	00001097          	auipc	ra,0x1
    80000eee:	0e4080e7          	jalr	228(ra) # 80001fce <scheduler>
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
    80000f56:	a1e080e7          	jalr	-1506(ra) # 80002970 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f5a:	00002097          	auipc	ra,0x2
    80000f5e:	a3e080e7          	jalr	-1474(ra) # 80002998 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	2b8080e7          	jalr	696(ra) # 8000621a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f6a:	00005097          	auipc	ra,0x5
    80000f6e:	2c6080e7          	jalr	710(ra) # 80006230 <plicinithart>
    binit();         // buffer cache
    80000f72:	00002097          	auipc	ra,0x2
    80000f76:	472080e7          	jalr	1138(ra) # 800033e4 <binit>
    iinit();         // inode table
    80000f7a:	00003097          	auipc	ra,0x3
    80000f7e:	b16080e7          	jalr	-1258(ra) # 80003a90 <iinit>
    fileinit();      // file table
    80000f82:	00004097          	auipc	ra,0x4
    80000f86:	ab4080e7          	jalr	-1356(ra) # 80004a36 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f8a:	00005097          	auipc	ra,0x5
    80000f8e:	3ae080e7          	jalr	942(ra) # 80006338 <virtio_disk_init>
    userinit();      // first user process
    80000f92:	00001097          	auipc	ra,0x1
    80000f96:	d56080e7          	jalr	-682(ra) # 80001ce8 <userinit>
    __sync_synchronize();
    80000f9a:	0ff0000f          	fence
    started = 1;
    80000f9e:	4785                	li	a5,1
    80000fa0:	00008717          	auipc	a4,0x8
    80000fa4:	baf72423          	sw	a5,-1112(a4) # 80008b48 <started>
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
    80000fb8:	b9c7b783          	ld	a5,-1124(a5) # 80008b50 <kernel_pagetable>
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
    80001274:	8ea7b023          	sd	a0,-1824(a5) # 80008b50 <kernel_pagetable>
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
void
proc_mapstacks(pagetable_t kpgtbl)
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
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001866:	00010497          	auipc	s1,0x10
    8000186a:	99a48493          	addi	s1,s1,-1638 # 80011200 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000186e:	8b26                	mv	s6,s1
    80001870:	00006a97          	auipc	s5,0x6
    80001874:	790a8a93          	addi	s5,s5,1936 # 80008000 <etext>
    80001878:	04000937          	lui	s2,0x4000
    8000187c:	197d                	addi	s2,s2,-1
    8000187e:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001880:	00017a17          	auipc	s4,0x17
    80001884:	180a0a13          	addi	s4,s4,384 # 80018a00 <tickslock>
    char *pa = kalloc();
    80001888:	fffff097          	auipc	ra,0xfffff
    8000188c:	272080e7          	jalr	626(ra) # 80000afa <kalloc>
    80001890:	862a                	mv	a2,a0
    if(pa == 0)
    80001892:	c131                	beqz	a0,800018d6 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
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
  for(p = proc; p < &proc[NPROC]; p++) {
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
void
procinit(void)
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
    80001906:	4ce50513          	addi	a0,a0,1230 # 80010dd0 <pid_lock>
    8000190a:	fffff097          	auipc	ra,0xfffff
    8000190e:	250080e7          	jalr	592(ra) # 80000b5a <initlock>
  initlock(&wait_lock, "wait_lock");
    80001912:	00007597          	auipc	a1,0x7
    80001916:	8d658593          	addi	a1,a1,-1834 # 800081e8 <digits+0x1a8>
    8000191a:	0000f517          	auipc	a0,0xf
    8000191e:	4ce50513          	addi	a0,a0,1230 # 80010de8 <wait_lock>
    80001922:	fffff097          	auipc	ra,0xfffff
    80001926:	238080e7          	jalr	568(ra) # 80000b5a <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000192a:	00010497          	auipc	s1,0x10
    8000192e:	8d648493          	addi	s1,s1,-1834 # 80011200 <proc>
      initlock(&p->lock, "proc");
    80001932:	00007b17          	auipc	s6,0x7
    80001936:	8c6b0b13          	addi	s6,s6,-1850 # 800081f8 <digits+0x1b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000193a:	8aa6                	mv	s5,s1
    8000193c:	00006a17          	auipc	s4,0x6
    80001940:	6c4a0a13          	addi	s4,s4,1732 # 80008000 <etext>
    80001944:	04000937          	lui	s2,0x4000
    80001948:	197d                	addi	s2,s2,-1
    8000194a:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000194c:	00017997          	auipc	s3,0x17
    80001950:	0b498993          	addi	s3,s3,180 # 80018a00 <tickslock>
      initlock(&p->lock, "proc");
    80001954:	85da                	mv	a1,s6
    80001956:	8526                	mv	a0,s1
    80001958:	fffff097          	auipc	ra,0xfffff
    8000195c:	202080e7          	jalr	514(ra) # 80000b5a <initlock>
      p->state = UNUSED;
    80001960:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001964:	415487b3          	sub	a5,s1,s5
    80001968:	8795                	srai	a5,a5,0x5
    8000196a:	000a3703          	ld	a4,0(s4)
    8000196e:	02e787b3          	mul	a5,a5,a4
    80001972:	2785                	addiw	a5,a5,1
    80001974:	00d7979b          	slliw	a5,a5,0xd
    80001978:	40f907b3          	sub	a5,s2,a5
    8000197c:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
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
int
cpuid()
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
struct cpu*
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
    800019ba:	44a50513          	addi	a0,a0,1098 # 80010e00 <cpus>
    800019be:	953e                	add	a0,a0,a5
    800019c0:	6422                	ld	s0,8(sp)
    800019c2:	0141                	addi	sp,sp,16
    800019c4:	8082                	ret

00000000800019c6 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
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
    800019e2:	3f270713          	addi	a4,a4,1010 # 80010dd0 <pid_lock>
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

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
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

  if (first) {
    80001a16:	00007797          	auipc	a5,0x7
    80001a1a:	fea7a783          	lw	a5,-22(a5) # 80008a00 <first.1743>
    80001a1e:	eb89                	bnez	a5,80001a30 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a20:	00001097          	auipc	ra,0x1
    80001a24:	f90080e7          	jalr	-112(ra) # 800029b0 <usertrapret>
}
    80001a28:	60a2                	ld	ra,8(sp)
    80001a2a:	6402                	ld	s0,0(sp)
    80001a2c:	0141                	addi	sp,sp,16
    80001a2e:	8082                	ret
    first = 0;
    80001a30:	00007797          	auipc	a5,0x7
    80001a34:	fc07a823          	sw	zero,-48(a5) # 80008a00 <first.1743>
    fsinit(ROOTDEV);
    80001a38:	4505                	li	a0,1
    80001a3a:	00002097          	auipc	ra,0x2
    80001a3e:	fd6080e7          	jalr	-42(ra) # 80003a10 <fsinit>
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
    80001a54:	38090913          	addi	s2,s2,896 # 80010dd0 <pid_lock>
    80001a58:	854a                	mv	a0,s2
    80001a5a:	fffff097          	auipc	ra,0xfffff
    80001a5e:	190080e7          	jalr	400(ra) # 80000bea <acquire>
  pid = nextpid;
    80001a62:	00007797          	auipc	a5,0x7
    80001a66:	fa278793          	addi	a5,a5,-94 # 80008a04 <nextpid>
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
  if(pagetable == 0)
    80001aa2:	c121                	beqz	a0,80001ae2 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
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
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
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
  if(p->trapframe)
    80001b84:	6d28                	ld	a0,88(a0)
    80001b86:	c509                	beqz	a0,80001b90 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b88:	fffff097          	auipc	ra,0xfffff
    80001b8c:	e76080e7          	jalr	-394(ra) # 800009fe <kfree>
  p->trapframe = 0;
    80001b90:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
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
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bdc:	0000f497          	auipc	s1,0xf
    80001be0:	62448493          	addi	s1,s1,1572 # 80011200 <proc>
    80001be4:	00017917          	auipc	s2,0x17
    80001be8:	e1c90913          	addi	s2,s2,-484 # 80018a00 <tickslock>
    acquire(&p->lock);
    80001bec:	8526                	mv	a0,s1
    80001bee:	fffff097          	auipc	ra,0xfffff
    80001bf2:	ffc080e7          	jalr	-4(ra) # 80000bea <acquire>
    if(p->state == UNUSED) {
    80001bf6:	4c9c                	lw	a5,24(s1)
    80001bf8:	cf81                	beqz	a5,80001c10 <allocproc+0x40>
      release(&p->lock);
    80001bfa:	8526                	mv	a0,s1
    80001bfc:	fffff097          	auipc	ra,0xfffff
    80001c00:	0a2080e7          	jalr	162(ra) # 80000c9e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c04:	1e048493          	addi	s1,s1,480
    80001c08:	ff2492e3          	bne	s1,s2,80001bec <allocproc+0x1c>
  return 0;
    80001c0c:	4481                	li	s1,0
    80001c0e:	a871                	j	80001caa <allocproc+0xda>
  p->pid = allocpid();
    80001c10:	00000097          	auipc	ra,0x0
    80001c14:	e34080e7          	jalr	-460(ra) # 80001a44 <allocpid>
    80001c18:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c1a:	4785                	li	a5,1
    80001c1c:	cc9c                	sw	a5,24(s1)
  p->time_created = ticks;
    80001c1e:	00007797          	auipc	a5,0x7
    80001c22:	f427e783          	lwu	a5,-190(a5) # 80008b60 <ticks>
    80001c26:	16f4bc23          	sd	a5,376(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c2a:	fffff097          	auipc	ra,0xfffff
    80001c2e:	ed0080e7          	jalr	-304(ra) # 80000afa <kalloc>
    80001c32:	892a                	mv	s2,a0
    80001c34:	eca8                	sd	a0,88(s1)
    80001c36:	c149                	beqz	a0,80001cb8 <allocproc+0xe8>
  p->pagetable = proc_pagetable(p);
    80001c38:	8526                	mv	a0,s1
    80001c3a:	00000097          	auipc	ra,0x0
    80001c3e:	e50080e7          	jalr	-432(ra) # 80001a8a <proc_pagetable>
    80001c42:	892a                	mv	s2,a0
    80001c44:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c46:	c549                	beqz	a0,80001cd0 <allocproc+0x100>
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
    80001c78:	eec7a783          	lw	a5,-276(a5) # 80008b60 <ticks>
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
}
    80001caa:	8526                	mv	a0,s1
    80001cac:	60e2                	ld	ra,24(sp)
    80001cae:	6442                	ld	s0,16(sp)
    80001cb0:	64a2                	ld	s1,8(sp)
    80001cb2:	6902                	ld	s2,0(sp)
    80001cb4:	6105                	addi	sp,sp,32
    80001cb6:	8082                	ret
    freeproc(p);
    80001cb8:	8526                	mv	a0,s1
    80001cba:	00000097          	auipc	ra,0x0
    80001cbe:	ebe080e7          	jalr	-322(ra) # 80001b78 <freeproc>
    release(&p->lock);
    80001cc2:	8526                	mv	a0,s1
    80001cc4:	fffff097          	auipc	ra,0xfffff
    80001cc8:	fda080e7          	jalr	-38(ra) # 80000c9e <release>
    return 0;
    80001ccc:	84ca                	mv	s1,s2
    80001cce:	bff1                	j	80001caa <allocproc+0xda>
    freeproc(p);
    80001cd0:	8526                	mv	a0,s1
    80001cd2:	00000097          	auipc	ra,0x0
    80001cd6:	ea6080e7          	jalr	-346(ra) # 80001b78 <freeproc>
    release(&p->lock);
    80001cda:	8526                	mv	a0,s1
    80001cdc:	fffff097          	auipc	ra,0xfffff
    80001ce0:	fc2080e7          	jalr	-62(ra) # 80000c9e <release>
    return 0;
    80001ce4:	84ca                	mv	s1,s2
    80001ce6:	b7d1                	j	80001caa <allocproc+0xda>

0000000080001ce8 <userinit>:
{
    80001ce8:	1101                	addi	sp,sp,-32
    80001cea:	ec06                	sd	ra,24(sp)
    80001cec:	e822                	sd	s0,16(sp)
    80001cee:	e426                	sd	s1,8(sp)
    80001cf0:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cf2:	00000097          	auipc	ra,0x0
    80001cf6:	ede080e7          	jalr	-290(ra) # 80001bd0 <allocproc>
    80001cfa:	84aa                	mv	s1,a0
  initproc = p;
    80001cfc:	00007797          	auipc	a5,0x7
    80001d00:	e4a7be23          	sd	a0,-420(a5) # 80008b58 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001d04:	03400613          	li	a2,52
    80001d08:	00007597          	auipc	a1,0x7
    80001d0c:	d0858593          	addi	a1,a1,-760 # 80008a10 <initcode>
    80001d10:	6928                	ld	a0,80(a0)
    80001d12:	fffff097          	auipc	ra,0xfffff
    80001d16:	660080e7          	jalr	1632(ra) # 80001372 <uvmfirst>
  p->sz = PGSIZE;
    80001d1a:	6785                	lui	a5,0x1
    80001d1c:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d1e:	6cb8                	ld	a4,88(s1)
    80001d20:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d24:	6cb8                	ld	a4,88(s1)
    80001d26:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d28:	4641                	li	a2,16
    80001d2a:	00006597          	auipc	a1,0x6
    80001d2e:	4d658593          	addi	a1,a1,1238 # 80008200 <digits+0x1c0>
    80001d32:	15848513          	addi	a0,s1,344
    80001d36:	fffff097          	auipc	ra,0xfffff
    80001d3a:	102080e7          	jalr	258(ra) # 80000e38 <safestrcpy>
  p->cwd = namei("/");
    80001d3e:	00006517          	auipc	a0,0x6
    80001d42:	4d250513          	addi	a0,a0,1234 # 80008210 <digits+0x1d0>
    80001d46:	00002097          	auipc	ra,0x2
    80001d4a:	6ec080e7          	jalr	1772(ra) # 80004432 <namei>
    80001d4e:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d52:	478d                	li	a5,3
    80001d54:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d56:	8526                	mv	a0,s1
    80001d58:	fffff097          	auipc	ra,0xfffff
    80001d5c:	f46080e7          	jalr	-186(ra) # 80000c9e <release>
}
    80001d60:	60e2                	ld	ra,24(sp)
    80001d62:	6442                	ld	s0,16(sp)
    80001d64:	64a2                	ld	s1,8(sp)
    80001d66:	6105                	addi	sp,sp,32
    80001d68:	8082                	ret

0000000080001d6a <growproc>:
{
    80001d6a:	1101                	addi	sp,sp,-32
    80001d6c:	ec06                	sd	ra,24(sp)
    80001d6e:	e822                	sd	s0,16(sp)
    80001d70:	e426                	sd	s1,8(sp)
    80001d72:	e04a                	sd	s2,0(sp)
    80001d74:	1000                	addi	s0,sp,32
    80001d76:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d78:	00000097          	auipc	ra,0x0
    80001d7c:	c4e080e7          	jalr	-946(ra) # 800019c6 <myproc>
    80001d80:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d82:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d84:	01204c63          	bgtz	s2,80001d9c <growproc+0x32>
  } else if(n < 0){
    80001d88:	02094663          	bltz	s2,80001db4 <growproc+0x4a>
  p->sz = sz;
    80001d8c:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d8e:	4501                	li	a0,0
}
    80001d90:	60e2                	ld	ra,24(sp)
    80001d92:	6442                	ld	s0,16(sp)
    80001d94:	64a2                	ld	s1,8(sp)
    80001d96:	6902                	ld	s2,0(sp)
    80001d98:	6105                	addi	sp,sp,32
    80001d9a:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d9c:	4691                	li	a3,4
    80001d9e:	00b90633          	add	a2,s2,a1
    80001da2:	6928                	ld	a0,80(a0)
    80001da4:	fffff097          	auipc	ra,0xfffff
    80001da8:	688080e7          	jalr	1672(ra) # 8000142c <uvmalloc>
    80001dac:	85aa                	mv	a1,a0
    80001dae:	fd79                	bnez	a0,80001d8c <growproc+0x22>
      return -1;
    80001db0:	557d                	li	a0,-1
    80001db2:	bff9                	j	80001d90 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001db4:	00b90633          	add	a2,s2,a1
    80001db8:	6928                	ld	a0,80(a0)
    80001dba:	fffff097          	auipc	ra,0xfffff
    80001dbe:	62a080e7          	jalr	1578(ra) # 800013e4 <uvmdealloc>
    80001dc2:	85aa                	mv	a1,a0
    80001dc4:	b7e1                	j	80001d8c <growproc+0x22>

0000000080001dc6 <fork>:
{
    80001dc6:	7179                	addi	sp,sp,-48
    80001dc8:	f406                	sd	ra,40(sp)
    80001dca:	f022                	sd	s0,32(sp)
    80001dcc:	ec26                	sd	s1,24(sp)
    80001dce:	e84a                	sd	s2,16(sp)
    80001dd0:	e44e                	sd	s3,8(sp)
    80001dd2:	e052                	sd	s4,0(sp)
    80001dd4:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001dd6:	00000097          	auipc	ra,0x0
    80001dda:	bf0080e7          	jalr	-1040(ra) # 800019c6 <myproc>
    80001dde:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001de0:	00000097          	auipc	ra,0x0
    80001de4:	df0080e7          	jalr	-528(ra) # 80001bd0 <allocproc>
    80001de8:	12050363          	beqz	a0,80001f0e <fork+0x148>
    80001dec:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001dee:	04893603          	ld	a2,72(s2)
    80001df2:	692c                	ld	a1,80(a0)
    80001df4:	05093503          	ld	a0,80(s2)
    80001df8:	fffff097          	auipc	ra,0xfffff
    80001dfc:	788080e7          	jalr	1928(ra) # 80001580 <uvmcopy>
    80001e00:	04054a63          	bltz	a0,80001e54 <fork+0x8e>
  np->sz = p->sz;
    80001e04:	04893783          	ld	a5,72(s2)
    80001e08:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001e0c:	05893683          	ld	a3,88(s2)
    80001e10:	87b6                	mv	a5,a3
    80001e12:	0589b703          	ld	a4,88(s3)
    80001e16:	12068693          	addi	a3,a3,288
    80001e1a:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e1e:	6788                	ld	a0,8(a5)
    80001e20:	6b8c                	ld	a1,16(a5)
    80001e22:	6f90                	ld	a2,24(a5)
    80001e24:	01073023          	sd	a6,0(a4)
    80001e28:	e708                	sd	a0,8(a4)
    80001e2a:	eb0c                	sd	a1,16(a4)
    80001e2c:	ef10                	sd	a2,24(a4)
    80001e2e:	02078793          	addi	a5,a5,32
    80001e32:	02070713          	addi	a4,a4,32
    80001e36:	fed792e3          	bne	a5,a3,80001e1a <fork+0x54>
  np->mask = p->mask;
    80001e3a:	16892783          	lw	a5,360(s2)
    80001e3e:	16f9a423          	sw	a5,360(s3)
  np->trapframe->a0 = 0;
    80001e42:	0589b783          	ld	a5,88(s3)
    80001e46:	0607b823          	sd	zero,112(a5)
    80001e4a:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001e4e:	15000a13          	li	s4,336
    80001e52:	a03d                	j	80001e80 <fork+0xba>
    freeproc(np);
    80001e54:	854e                	mv	a0,s3
    80001e56:	00000097          	auipc	ra,0x0
    80001e5a:	d22080e7          	jalr	-734(ra) # 80001b78 <freeproc>
    release(&np->lock);
    80001e5e:	854e                	mv	a0,s3
    80001e60:	fffff097          	auipc	ra,0xfffff
    80001e64:	e3e080e7          	jalr	-450(ra) # 80000c9e <release>
    return -1;
    80001e68:	5a7d                	li	s4,-1
    80001e6a:	a849                	j	80001efc <fork+0x136>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e6c:	00003097          	auipc	ra,0x3
    80001e70:	c5c080e7          	jalr	-932(ra) # 80004ac8 <filedup>
    80001e74:	009987b3          	add	a5,s3,s1
    80001e78:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001e7a:	04a1                	addi	s1,s1,8
    80001e7c:	01448763          	beq	s1,s4,80001e8a <fork+0xc4>
    if(p->ofile[i])
    80001e80:	009907b3          	add	a5,s2,s1
    80001e84:	6388                	ld	a0,0(a5)
    80001e86:	f17d                	bnez	a0,80001e6c <fork+0xa6>
    80001e88:	bfcd                	j	80001e7a <fork+0xb4>
  np->cwd = idup(p->cwd);
    80001e8a:	15093503          	ld	a0,336(s2)
    80001e8e:	00002097          	auipc	ra,0x2
    80001e92:	dc0080e7          	jalr	-576(ra) # 80003c4e <idup>
    80001e96:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e9a:	4641                	li	a2,16
    80001e9c:	15890593          	addi	a1,s2,344
    80001ea0:	15898513          	addi	a0,s3,344
    80001ea4:	fffff097          	auipc	ra,0xfffff
    80001ea8:	f94080e7          	jalr	-108(ra) # 80000e38 <safestrcpy>
  pid = np->pid;
    80001eac:	0309aa03          	lw	s4,48(s3)
  release(&np->lock);
    80001eb0:	854e                	mv	a0,s3
    80001eb2:	fffff097          	auipc	ra,0xfffff
    80001eb6:	dec080e7          	jalr	-532(ra) # 80000c9e <release>
  acquire(&wait_lock);
    80001eba:	0000f497          	auipc	s1,0xf
    80001ebe:	f2e48493          	addi	s1,s1,-210 # 80010de8 <wait_lock>
    80001ec2:	8526                	mv	a0,s1
    80001ec4:	fffff097          	auipc	ra,0xfffff
    80001ec8:	d26080e7          	jalr	-730(ra) # 80000bea <acquire>
  np->parent = p;
    80001ecc:	0329bc23          	sd	s2,56(s3)
  np->tickets = np->parent->tickets;
    80001ed0:	1b492783          	lw	a5,436(s2)
    80001ed4:	1af9aa23          	sw	a5,436(s3)
  release(&wait_lock);
    80001ed8:	8526                	mv	a0,s1
    80001eda:	fffff097          	auipc	ra,0xfffff
    80001ede:	dc4080e7          	jalr	-572(ra) # 80000c9e <release>
  acquire(&np->lock);
    80001ee2:	854e                	mv	a0,s3
    80001ee4:	fffff097          	auipc	ra,0xfffff
    80001ee8:	d06080e7          	jalr	-762(ra) # 80000bea <acquire>
  np->state = RUNNABLE;
    80001eec:	478d                	li	a5,3
    80001eee:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001ef2:	854e                	mv	a0,s3
    80001ef4:	fffff097          	auipc	ra,0xfffff
    80001ef8:	daa080e7          	jalr	-598(ra) # 80000c9e <release>
}
    80001efc:	8552                	mv	a0,s4
    80001efe:	70a2                	ld	ra,40(sp)
    80001f00:	7402                	ld	s0,32(sp)
    80001f02:	64e2                	ld	s1,24(sp)
    80001f04:	6942                	ld	s2,16(sp)
    80001f06:	69a2                	ld	s3,8(sp)
    80001f08:	6a02                	ld	s4,0(sp)
    80001f0a:	6145                	addi	sp,sp,48
    80001f0c:	8082                	ret
    return -1;
    80001f0e:	5a7d                	li	s4,-1
    80001f10:	b7f5                	j	80001efc <fork+0x136>

0000000080001f12 <max>:
int max(int a, int b){
    80001f12:	1141                	addi	sp,sp,-16
    80001f14:	e422                	sd	s0,8(sp)
    80001f16:	0800                	addi	s0,sp,16
  if(a > b)
    80001f18:	87aa                	mv	a5,a0
    80001f1a:	00b55363          	bge	a0,a1,80001f20 <max+0xe>
    80001f1e:	87ae                	mv	a5,a1
}
    80001f20:	0007851b          	sext.w	a0,a5
    80001f24:	6422                	ld	s0,8(sp)
    80001f26:	0141                	addi	sp,sp,16
    80001f28:	8082                	ret

0000000080001f2a <min>:
int min(int a, int b){
    80001f2a:	1141                	addi	sp,sp,-16
    80001f2c:	e422                	sd	s0,8(sp)
    80001f2e:	0800                	addi	s0,sp,16
  if(a < b)
    80001f30:	87aa                	mv	a5,a0
    80001f32:	00a5d363          	bge	a1,a0,80001f38 <min+0xe>
    80001f36:	87ae                	mv	a5,a1
}
    80001f38:	0007851b          	sext.w	a0,a5
    80001f3c:	6422                	ld	s0,8(sp)
    80001f3e:	0141                	addi	sp,sp,16
    80001f40:	8082                	ret

0000000080001f42 <update_time>:
{
    80001f42:	7179                	addi	sp,sp,-48
    80001f44:	f406                	sd	ra,40(sp)
    80001f46:	f022                	sd	s0,32(sp)
    80001f48:	ec26                	sd	s1,24(sp)
    80001f4a:	e84a                	sd	s2,16(sp)
    80001f4c:	e44e                	sd	s3,8(sp)
    80001f4e:	1800                	addi	s0,sp,48
  for (p = proc; p < &proc[NPROC]; p++) {
    80001f50:	0000f497          	auipc	s1,0xf
    80001f54:	2b048493          	addi	s1,s1,688 # 80011200 <proc>
    if (p->state == RUNNING) {
    80001f58:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++) {
    80001f5a:	00017917          	auipc	s2,0x17
    80001f5e:	aa690913          	addi	s2,s2,-1370 # 80018a00 <tickslock>
    80001f62:	a811                	j	80001f76 <update_time+0x34>
    release(&p->lock); 
    80001f64:	8526                	mv	a0,s1
    80001f66:	fffff097          	auipc	ra,0xfffff
    80001f6a:	d38080e7          	jalr	-712(ra) # 80000c9e <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001f6e:	1e048493          	addi	s1,s1,480
    80001f72:	03248063          	beq	s1,s2,80001f92 <update_time+0x50>
    acquire(&p->lock);
    80001f76:	8526                	mv	a0,s1
    80001f78:	fffff097          	auipc	ra,0xfffff
    80001f7c:	c72080e7          	jalr	-910(ra) # 80000bea <acquire>
    if (p->state == RUNNING) {
    80001f80:	4c9c                	lw	a5,24(s1)
    80001f82:	ff3791e3          	bne	a5,s3,80001f64 <update_time+0x22>
      p->rtime++;
    80001f86:	16c4a783          	lw	a5,364(s1)
    80001f8a:	2785                	addiw	a5,a5,1
    80001f8c:	16f4a623          	sw	a5,364(s1)
    80001f90:	bfd1                	j	80001f64 <update_time+0x22>
}
    80001f92:	70a2                	ld	ra,40(sp)
    80001f94:	7402                	ld	s0,32(sp)
    80001f96:	64e2                	ld	s1,24(sp)
    80001f98:	6942                	ld	s2,16(sp)
    80001f9a:	69a2                	ld	s3,8(sp)
    80001f9c:	6145                	addi	sp,sp,48
    80001f9e:	8082                	ret

0000000080001fa0 <randomnum>:
{
    80001fa0:	1141                	addi	sp,sp,-16
    80001fa2:	e422                	sd	s0,8(sp)
    80001fa4:	0800                	addi	s0,sp,16
  uint64 num = (uint64)ticks;
    80001fa6:	00007797          	auipc	a5,0x7
    80001faa:	bba7e783          	lwu	a5,-1094(a5) # 80008b60 <ticks>
  num = num ^ (num << 13);
    80001fae:	00d79713          	slli	a4,a5,0xd
    80001fb2:	8fb9                	xor	a5,a5,a4
  num = num ^ (num >> 17);
    80001fb4:	0117d713          	srli	a4,a5,0x11
    80001fb8:	8f3d                	xor	a4,a4,a5
  num = num ^ (num << 5);
    80001fba:	00571793          	slli	a5,a4,0x5
    80001fbe:	8fb9                	xor	a5,a5,a4
  num = num % (max - min);
    80001fc0:	9d89                	subw	a1,a1,a0
    80001fc2:	02b7f7b3          	remu	a5,a5,a1
}
    80001fc6:	9d3d                	addw	a0,a0,a5
    80001fc8:	6422                	ld	s0,8(sp)
    80001fca:	0141                	addi	sp,sp,16
    80001fcc:	8082                	ret

0000000080001fce <scheduler>:
{
    80001fce:	715d                	addi	sp,sp,-80
    80001fd0:	e486                	sd	ra,72(sp)
    80001fd2:	e0a2                	sd	s0,64(sp)
    80001fd4:	fc26                	sd	s1,56(sp)
    80001fd6:	f84a                	sd	s2,48(sp)
    80001fd8:	f44e                	sd	s3,40(sp)
    80001fda:	f052                	sd	s4,32(sp)
    80001fdc:	ec56                	sd	s5,24(sp)
    80001fde:	e85a                	sd	s6,16(sp)
    80001fe0:	e45e                	sd	s7,8(sp)
    80001fe2:	0880                	addi	s0,sp,80
    80001fe4:	8792                	mv	a5,tp
  int id = r_tp();
    80001fe6:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001fe8:	00779b13          	slli	s6,a5,0x7
    80001fec:	0000f717          	auipc	a4,0xf
    80001ff0:	de470713          	addi	a4,a4,-540 # 80010dd0 <pid_lock>
    80001ff4:	975a                	add	a4,a4,s6
    80001ff6:	02073823          	sd	zero,48(a4)
          swtch(&c->context, &p->context);
    80001ffa:	0000f717          	auipc	a4,0xf
    80001ffe:	e0e70713          	addi	a4,a4,-498 # 80010e08 <cpus+0x8>
    80002002:	9b3a                	add	s6,s6,a4
      if(p->state == RUNNABLE){
    80002004:	490d                	li	s2,3
    for(p = proc; p < &proc[NPROC]; p++) {
    80002006:	00017997          	auipc	s3,0x17
    8000200a:	9fa98993          	addi	s3,s3,-1542 # 80018a00 <tickslock>
    int totalticketval = 0;
    8000200e:	4a01                	li	s4,0
          c->proc = p;
    80002010:	079e                	slli	a5,a5,0x7
    80002012:	0000fa97          	auipc	s5,0xf
    80002016:	dbea8a93          	addi	s5,s5,-578 # 80010dd0 <pid_lock>
    8000201a:	9abe                	add	s5,s5,a5
    8000201c:	a889                	j	8000206e <scheduler+0xa0>
    for(p = proc; p < &proc[NPROC]; p++) {
    8000201e:	1e078793          	addi	a5,a5,480
    80002022:	01378963          	beq	a5,s3,80002034 <scheduler+0x66>
      if(p->state == RUNNABLE){
    80002026:	4f98                	lw	a4,24(a5)
    80002028:	ff271be3          	bne	a4,s2,8000201e <scheduler+0x50>
        totalticketval += p->tickets;
    8000202c:	1b47a703          	lw	a4,436(a5)
    80002030:	9db9                	addw	a1,a1,a4
    80002032:	b7f5                	j	8000201e <scheduler+0x50>
    int ticketval = randomnum(0,totalticketval);
    80002034:	8552                	mv	a0,s4
    80002036:	00000097          	auipc	ra,0x0
    8000203a:	f6a080e7          	jalr	-150(ra) # 80001fa0 <randomnum>
    8000203e:	8baa                	mv	s7,a0
    for(p = proc; p < &proc[NPROC]; p++) {
    80002040:	0000f497          	auipc	s1,0xf
    80002044:	1c048493          	addi	s1,s1,448 # 80011200 <proc>
    80002048:	a881                	j	80002098 <scheduler+0xca>
          p->state = RUNNING;
    8000204a:	4791                	li	a5,4
    8000204c:	cc9c                	sw	a5,24(s1)
          c->proc = p;
    8000204e:	029ab823          	sd	s1,48(s5)
          swtch(&c->context, &p->context);
    80002052:	06048593          	addi	a1,s1,96
    80002056:	855a                	mv	a0,s6
    80002058:	00001097          	auipc	ra,0x1
    8000205c:	8ae080e7          	jalr	-1874(ra) # 80002906 <swtch>
          c->proc = 0;
    80002060:	020ab823          	sd	zero,48(s5)
          release(&p->lock);
    80002064:	8526                	mv	a0,s1
    80002066:	fffff097          	auipc	ra,0xfffff
    8000206a:	c38080e7          	jalr	-968(ra) # 80000c9e <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000206e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002072:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002076:	10079073          	csrw	sstatus,a5
    int totalticketval = 0;
    8000207a:	85d2                	mv	a1,s4
    for(p = proc; p < &proc[NPROC]; p++) {
    8000207c:	0000f797          	auipc	a5,0xf
    80002080:	18478793          	addi	a5,a5,388 # 80011200 <proc>
    80002084:	b74d                	j	80002026 <scheduler+0x58>
      release(&p->lock);
    80002086:	8526                	mv	a0,s1
    80002088:	fffff097          	auipc	ra,0xfffff
    8000208c:	c16080e7          	jalr	-1002(ra) # 80000c9e <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002090:	1e048493          	addi	s1,s1,480
    80002094:	fd348de3          	beq	s1,s3,8000206e <scheduler+0xa0>
      acquire(&p->lock);
    80002098:	8526                	mv	a0,s1
    8000209a:	fffff097          	auipc	ra,0xfffff
    8000209e:	b50080e7          	jalr	-1200(ra) # 80000bea <acquire>
      if(p->state == RUNNABLE) {
    800020a2:	4c9c                	lw	a5,24(s1)
    800020a4:	ff2791e3          	bne	a5,s2,80002086 <scheduler+0xb8>
        if(p->tickets > ticketval){
    800020a8:	1b44a783          	lw	a5,436(s1)
    800020ac:	f8fbcfe3          	blt	s7,a5,8000204a <scheduler+0x7c>
          ticketval = ticketval - p->tickets; 
    800020b0:	40fb8bbb          	subw	s7,s7,a5
    800020b4:	bfc9                	j	80002086 <scheduler+0xb8>

00000000800020b6 <sched>:
{
    800020b6:	7179                	addi	sp,sp,-48
    800020b8:	f406                	sd	ra,40(sp)
    800020ba:	f022                	sd	s0,32(sp)
    800020bc:	ec26                	sd	s1,24(sp)
    800020be:	e84a                	sd	s2,16(sp)
    800020c0:	e44e                	sd	s3,8(sp)
    800020c2:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800020c4:	00000097          	auipc	ra,0x0
    800020c8:	902080e7          	jalr	-1790(ra) # 800019c6 <myproc>
    800020cc:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800020ce:	fffff097          	auipc	ra,0xfffff
    800020d2:	aa2080e7          	jalr	-1374(ra) # 80000b70 <holding>
    800020d6:	c93d                	beqz	a0,8000214c <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020d8:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800020da:	2781                	sext.w	a5,a5
    800020dc:	079e                	slli	a5,a5,0x7
    800020de:	0000f717          	auipc	a4,0xf
    800020e2:	cf270713          	addi	a4,a4,-782 # 80010dd0 <pid_lock>
    800020e6:	97ba                	add	a5,a5,a4
    800020e8:	0a87a703          	lw	a4,168(a5)
    800020ec:	4785                	li	a5,1
    800020ee:	06f71763          	bne	a4,a5,8000215c <sched+0xa6>
  if(p->state == RUNNING)
    800020f2:	4c98                	lw	a4,24(s1)
    800020f4:	4791                	li	a5,4
    800020f6:	06f70b63          	beq	a4,a5,8000216c <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020fa:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800020fe:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002100:	efb5                	bnez	a5,8000217c <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002102:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002104:	0000f917          	auipc	s2,0xf
    80002108:	ccc90913          	addi	s2,s2,-820 # 80010dd0 <pid_lock>
    8000210c:	2781                	sext.w	a5,a5
    8000210e:	079e                	slli	a5,a5,0x7
    80002110:	97ca                	add	a5,a5,s2
    80002112:	0ac7a983          	lw	s3,172(a5)
    80002116:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002118:	2781                	sext.w	a5,a5
    8000211a:	079e                	slli	a5,a5,0x7
    8000211c:	0000f597          	auipc	a1,0xf
    80002120:	cec58593          	addi	a1,a1,-788 # 80010e08 <cpus+0x8>
    80002124:	95be                	add	a1,a1,a5
    80002126:	06048513          	addi	a0,s1,96
    8000212a:	00000097          	auipc	ra,0x0
    8000212e:	7dc080e7          	jalr	2012(ra) # 80002906 <swtch>
    80002132:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002134:	2781                	sext.w	a5,a5
    80002136:	079e                	slli	a5,a5,0x7
    80002138:	97ca                	add	a5,a5,s2
    8000213a:	0b37a623          	sw	s3,172(a5)
}
    8000213e:	70a2                	ld	ra,40(sp)
    80002140:	7402                	ld	s0,32(sp)
    80002142:	64e2                	ld	s1,24(sp)
    80002144:	6942                	ld	s2,16(sp)
    80002146:	69a2                	ld	s3,8(sp)
    80002148:	6145                	addi	sp,sp,48
    8000214a:	8082                	ret
    panic("sched p->lock");
    8000214c:	00006517          	auipc	a0,0x6
    80002150:	0cc50513          	addi	a0,a0,204 # 80008218 <digits+0x1d8>
    80002154:	ffffe097          	auipc	ra,0xffffe
    80002158:	3f0080e7          	jalr	1008(ra) # 80000544 <panic>
    panic("sched locks");
    8000215c:	00006517          	auipc	a0,0x6
    80002160:	0cc50513          	addi	a0,a0,204 # 80008228 <digits+0x1e8>
    80002164:	ffffe097          	auipc	ra,0xffffe
    80002168:	3e0080e7          	jalr	992(ra) # 80000544 <panic>
    panic("sched running");
    8000216c:	00006517          	auipc	a0,0x6
    80002170:	0cc50513          	addi	a0,a0,204 # 80008238 <digits+0x1f8>
    80002174:	ffffe097          	auipc	ra,0xffffe
    80002178:	3d0080e7          	jalr	976(ra) # 80000544 <panic>
    panic("sched interruptible");
    8000217c:	00006517          	auipc	a0,0x6
    80002180:	0cc50513          	addi	a0,a0,204 # 80008248 <digits+0x208>
    80002184:	ffffe097          	auipc	ra,0xffffe
    80002188:	3c0080e7          	jalr	960(ra) # 80000544 <panic>

000000008000218c <yield>:
{
    8000218c:	1101                	addi	sp,sp,-32
    8000218e:	ec06                	sd	ra,24(sp)
    80002190:	e822                	sd	s0,16(sp)
    80002192:	e426                	sd	s1,8(sp)
    80002194:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002196:	00000097          	auipc	ra,0x0
    8000219a:	830080e7          	jalr	-2000(ra) # 800019c6 <myproc>
    8000219e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021a0:	fffff097          	auipc	ra,0xfffff
    800021a4:	a4a080e7          	jalr	-1462(ra) # 80000bea <acquire>
  p->state = RUNNABLE;
    800021a8:	478d                	li	a5,3
    800021aa:	cc9c                	sw	a5,24(s1)
  sched();
    800021ac:	00000097          	auipc	ra,0x0
    800021b0:	f0a080e7          	jalr	-246(ra) # 800020b6 <sched>
  release(&p->lock);
    800021b4:	8526                	mv	a0,s1
    800021b6:	fffff097          	auipc	ra,0xfffff
    800021ba:	ae8080e7          	jalr	-1304(ra) # 80000c9e <release>
}
    800021be:	60e2                	ld	ra,24(sp)
    800021c0:	6442                	ld	s0,16(sp)
    800021c2:	64a2                	ld	s1,8(sp)
    800021c4:	6105                	addi	sp,sp,32
    800021c6:	8082                	ret

00000000800021c8 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800021c8:	7179                	addi	sp,sp,-48
    800021ca:	f406                	sd	ra,40(sp)
    800021cc:	f022                	sd	s0,32(sp)
    800021ce:	ec26                	sd	s1,24(sp)
    800021d0:	e84a                	sd	s2,16(sp)
    800021d2:	e44e                	sd	s3,8(sp)
    800021d4:	1800                	addi	s0,sp,48
    800021d6:	89aa                	mv	s3,a0
    800021d8:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800021da:	fffff097          	auipc	ra,0xfffff
    800021de:	7ec080e7          	jalr	2028(ra) # 800019c6 <myproc>
    800021e2:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800021e4:	fffff097          	auipc	ra,0xfffff
    800021e8:	a06080e7          	jalr	-1530(ra) # 80000bea <acquire>
  release(lk);
    800021ec:	854a                	mv	a0,s2
    800021ee:	fffff097          	auipc	ra,0xfffff
    800021f2:	ab0080e7          	jalr	-1360(ra) # 80000c9e <release>

  // Go to sleep.
  p->chan = chan;
    800021f6:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800021fa:	4789                	li	a5,2
    800021fc:	cc9c                	sw	a5,24(s1)

  sched();
    800021fe:	00000097          	auipc	ra,0x0
    80002202:	eb8080e7          	jalr	-328(ra) # 800020b6 <sched>

  // Tidy up.
  p->chan = 0;
    80002206:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000220a:	8526                	mv	a0,s1
    8000220c:	fffff097          	auipc	ra,0xfffff
    80002210:	a92080e7          	jalr	-1390(ra) # 80000c9e <release>
  acquire(lk);
    80002214:	854a                	mv	a0,s2
    80002216:	fffff097          	auipc	ra,0xfffff
    8000221a:	9d4080e7          	jalr	-1580(ra) # 80000bea <acquire>
}
    8000221e:	70a2                	ld	ra,40(sp)
    80002220:	7402                	ld	s0,32(sp)
    80002222:	64e2                	ld	s1,24(sp)
    80002224:	6942                	ld	s2,16(sp)
    80002226:	69a2                	ld	s3,8(sp)
    80002228:	6145                	addi	sp,sp,48
    8000222a:	8082                	ret

000000008000222c <waitx>:
{
    8000222c:	711d                	addi	sp,sp,-96
    8000222e:	ec86                	sd	ra,88(sp)
    80002230:	e8a2                	sd	s0,80(sp)
    80002232:	e4a6                	sd	s1,72(sp)
    80002234:	e0ca                	sd	s2,64(sp)
    80002236:	fc4e                	sd	s3,56(sp)
    80002238:	f852                	sd	s4,48(sp)
    8000223a:	f456                	sd	s5,40(sp)
    8000223c:	f05a                	sd	s6,32(sp)
    8000223e:	ec5e                	sd	s7,24(sp)
    80002240:	e862                	sd	s8,16(sp)
    80002242:	e466                	sd	s9,8(sp)
    80002244:	e06a                	sd	s10,0(sp)
    80002246:	1080                	addi	s0,sp,96
    80002248:	8b2a                	mv	s6,a0
    8000224a:	8bae                	mv	s7,a1
    8000224c:	8c32                	mv	s8,a2
  struct proc *p = myproc();
    8000224e:	fffff097          	auipc	ra,0xfffff
    80002252:	778080e7          	jalr	1912(ra) # 800019c6 <myproc>
    80002256:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002258:	0000f517          	auipc	a0,0xf
    8000225c:	b9050513          	addi	a0,a0,-1136 # 80010de8 <wait_lock>
    80002260:	fffff097          	auipc	ra,0xfffff
    80002264:	98a080e7          	jalr	-1654(ra) # 80000bea <acquire>
    havekids = 0;
    80002268:	4c81                	li	s9,0
        if(np->state == ZOMBIE){
    8000226a:	4a15                	li	s4,5
    for(np = proc; np < &proc[NPROC]; np++){
    8000226c:	00016997          	auipc	s3,0x16
    80002270:	79498993          	addi	s3,s3,1940 # 80018a00 <tickslock>
        havekids = 1;
    80002274:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002276:	0000fd17          	auipc	s10,0xf
    8000227a:	b72d0d13          	addi	s10,s10,-1166 # 80010de8 <wait_lock>
    havekids = 0;
    8000227e:	8766                	mv	a4,s9
    for(np = proc; np < &proc[NPROC]; np++){
    80002280:	0000f497          	auipc	s1,0xf
    80002284:	f8048493          	addi	s1,s1,-128 # 80011200 <proc>
    80002288:	a059                	j	8000230e <waitx+0xe2>
          pid = np->pid;
    8000228a:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    8000228e:	16c4a703          	lw	a4,364(s1)
    80002292:	00ec2023          	sw	a4,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    80002296:	1704a783          	lw	a5,368(s1)
    8000229a:	9f3d                	addw	a4,a4,a5
    8000229c:	1744a783          	lw	a5,372(s1)
    800022a0:	9f99                	subw	a5,a5,a4
    800022a2:	00fba023          	sw	a5,0(s7) # fffffffffffff000 <end+0xffffffff7ffdb220>
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800022a6:	000b0e63          	beqz	s6,800022c2 <waitx+0x96>
    800022aa:	4691                	li	a3,4
    800022ac:	02c48613          	addi	a2,s1,44
    800022b0:	85da                	mv	a1,s6
    800022b2:	05093503          	ld	a0,80(s2)
    800022b6:	fffff097          	auipc	ra,0xfffff
    800022ba:	3ce080e7          	jalr	974(ra) # 80001684 <copyout>
    800022be:	02054563          	bltz	a0,800022e8 <waitx+0xbc>
          freeproc(np);
    800022c2:	8526                	mv	a0,s1
    800022c4:	00000097          	auipc	ra,0x0
    800022c8:	8b4080e7          	jalr	-1868(ra) # 80001b78 <freeproc>
          release(&np->lock);
    800022cc:	8526                	mv	a0,s1
    800022ce:	fffff097          	auipc	ra,0xfffff
    800022d2:	9d0080e7          	jalr	-1584(ra) # 80000c9e <release>
          release(&wait_lock);
    800022d6:	0000f517          	auipc	a0,0xf
    800022da:	b1250513          	addi	a0,a0,-1262 # 80010de8 <wait_lock>
    800022de:	fffff097          	auipc	ra,0xfffff
    800022e2:	9c0080e7          	jalr	-1600(ra) # 80000c9e <release>
          return pid;
    800022e6:	a09d                	j	8000234c <waitx+0x120>
            release(&np->lock);
    800022e8:	8526                	mv	a0,s1
    800022ea:	fffff097          	auipc	ra,0xfffff
    800022ee:	9b4080e7          	jalr	-1612(ra) # 80000c9e <release>
            release(&wait_lock);
    800022f2:	0000f517          	auipc	a0,0xf
    800022f6:	af650513          	addi	a0,a0,-1290 # 80010de8 <wait_lock>
    800022fa:	fffff097          	auipc	ra,0xfffff
    800022fe:	9a4080e7          	jalr	-1628(ra) # 80000c9e <release>
            return -1;
    80002302:	59fd                	li	s3,-1
    80002304:	a0a1                	j	8000234c <waitx+0x120>
    for(np = proc; np < &proc[NPROC]; np++){
    80002306:	1e048493          	addi	s1,s1,480
    8000230a:	03348463          	beq	s1,s3,80002332 <waitx+0x106>
      if(np->parent == p){
    8000230e:	7c9c                	ld	a5,56(s1)
    80002310:	ff279be3          	bne	a5,s2,80002306 <waitx+0xda>
        acquire(&np->lock);
    80002314:	8526                	mv	a0,s1
    80002316:	fffff097          	auipc	ra,0xfffff
    8000231a:	8d4080e7          	jalr	-1836(ra) # 80000bea <acquire>
        if(np->state == ZOMBIE){
    8000231e:	4c9c                	lw	a5,24(s1)
    80002320:	f74785e3          	beq	a5,s4,8000228a <waitx+0x5e>
        release(&np->lock);
    80002324:	8526                	mv	a0,s1
    80002326:	fffff097          	auipc	ra,0xfffff
    8000232a:	978080e7          	jalr	-1672(ra) # 80000c9e <release>
        havekids = 1;
    8000232e:	8756                	mv	a4,s5
    80002330:	bfd9                	j	80002306 <waitx+0xda>
    if(!havekids || p->killed){
    80002332:	c701                	beqz	a4,8000233a <waitx+0x10e>
    80002334:	02892783          	lw	a5,40(s2)
    80002338:	cb8d                	beqz	a5,8000236a <waitx+0x13e>
      release(&wait_lock);
    8000233a:	0000f517          	auipc	a0,0xf
    8000233e:	aae50513          	addi	a0,a0,-1362 # 80010de8 <wait_lock>
    80002342:	fffff097          	auipc	ra,0xfffff
    80002346:	95c080e7          	jalr	-1700(ra) # 80000c9e <release>
      return -1;
    8000234a:	59fd                	li	s3,-1
}
    8000234c:	854e                	mv	a0,s3
    8000234e:	60e6                	ld	ra,88(sp)
    80002350:	6446                	ld	s0,80(sp)
    80002352:	64a6                	ld	s1,72(sp)
    80002354:	6906                	ld	s2,64(sp)
    80002356:	79e2                	ld	s3,56(sp)
    80002358:	7a42                	ld	s4,48(sp)
    8000235a:	7aa2                	ld	s5,40(sp)
    8000235c:	7b02                	ld	s6,32(sp)
    8000235e:	6be2                	ld	s7,24(sp)
    80002360:	6c42                	ld	s8,16(sp)
    80002362:	6ca2                	ld	s9,8(sp)
    80002364:	6d02                	ld	s10,0(sp)
    80002366:	6125                	addi	sp,sp,96
    80002368:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000236a:	85ea                	mv	a1,s10
    8000236c:	854a                	mv	a0,s2
    8000236e:	00000097          	auipc	ra,0x0
    80002372:	e5a080e7          	jalr	-422(ra) # 800021c8 <sleep>
    havekids = 0;
    80002376:	b721                	j	8000227e <waitx+0x52>

0000000080002378 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002378:	7139                	addi	sp,sp,-64
    8000237a:	fc06                	sd	ra,56(sp)
    8000237c:	f822                	sd	s0,48(sp)
    8000237e:	f426                	sd	s1,40(sp)
    80002380:	f04a                	sd	s2,32(sp)
    80002382:	ec4e                	sd	s3,24(sp)
    80002384:	e852                	sd	s4,16(sp)
    80002386:	e456                	sd	s5,8(sp)
    80002388:	0080                	addi	s0,sp,64
    8000238a:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000238c:	0000f497          	auipc	s1,0xf
    80002390:	e7448493          	addi	s1,s1,-396 # 80011200 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002394:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002396:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002398:	00016917          	auipc	s2,0x16
    8000239c:	66890913          	addi	s2,s2,1640 # 80018a00 <tickslock>
    800023a0:	a821                	j	800023b8 <wakeup+0x40>
        p->state = RUNNABLE;
    800023a2:	0154ac23          	sw	s5,24(s1)
      }
      release(&p->lock);
    800023a6:	8526                	mv	a0,s1
    800023a8:	fffff097          	auipc	ra,0xfffff
    800023ac:	8f6080e7          	jalr	-1802(ra) # 80000c9e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800023b0:	1e048493          	addi	s1,s1,480
    800023b4:	03248463          	beq	s1,s2,800023dc <wakeup+0x64>
    if(p != myproc()){
    800023b8:	fffff097          	auipc	ra,0xfffff
    800023bc:	60e080e7          	jalr	1550(ra) # 800019c6 <myproc>
    800023c0:	fea488e3          	beq	s1,a0,800023b0 <wakeup+0x38>
      acquire(&p->lock);
    800023c4:	8526                	mv	a0,s1
    800023c6:	fffff097          	auipc	ra,0xfffff
    800023ca:	824080e7          	jalr	-2012(ra) # 80000bea <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800023ce:	4c9c                	lw	a5,24(s1)
    800023d0:	fd379be3          	bne	a5,s3,800023a6 <wakeup+0x2e>
    800023d4:	709c                	ld	a5,32(s1)
    800023d6:	fd4798e3          	bne	a5,s4,800023a6 <wakeup+0x2e>
    800023da:	b7e1                	j	800023a2 <wakeup+0x2a>
    }
  }
}
    800023dc:	70e2                	ld	ra,56(sp)
    800023de:	7442                	ld	s0,48(sp)
    800023e0:	74a2                	ld	s1,40(sp)
    800023e2:	7902                	ld	s2,32(sp)
    800023e4:	69e2                	ld	s3,24(sp)
    800023e6:	6a42                	ld	s4,16(sp)
    800023e8:	6aa2                	ld	s5,8(sp)
    800023ea:	6121                	addi	sp,sp,64
    800023ec:	8082                	ret

00000000800023ee <reparent>:
{
    800023ee:	7179                	addi	sp,sp,-48
    800023f0:	f406                	sd	ra,40(sp)
    800023f2:	f022                	sd	s0,32(sp)
    800023f4:	ec26                	sd	s1,24(sp)
    800023f6:	e84a                	sd	s2,16(sp)
    800023f8:	e44e                	sd	s3,8(sp)
    800023fa:	e052                	sd	s4,0(sp)
    800023fc:	1800                	addi	s0,sp,48
    800023fe:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002400:	0000f497          	auipc	s1,0xf
    80002404:	e0048493          	addi	s1,s1,-512 # 80011200 <proc>
      pp->parent = initproc;
    80002408:	00006a17          	auipc	s4,0x6
    8000240c:	750a0a13          	addi	s4,s4,1872 # 80008b58 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002410:	00016997          	auipc	s3,0x16
    80002414:	5f098993          	addi	s3,s3,1520 # 80018a00 <tickslock>
    80002418:	a029                	j	80002422 <reparent+0x34>
    8000241a:	1e048493          	addi	s1,s1,480
    8000241e:	01348d63          	beq	s1,s3,80002438 <reparent+0x4a>
    if(pp->parent == p){
    80002422:	7c9c                	ld	a5,56(s1)
    80002424:	ff279be3          	bne	a5,s2,8000241a <reparent+0x2c>
      pp->parent = initproc;
    80002428:	000a3503          	ld	a0,0(s4)
    8000242c:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000242e:	00000097          	auipc	ra,0x0
    80002432:	f4a080e7          	jalr	-182(ra) # 80002378 <wakeup>
    80002436:	b7d5                	j	8000241a <reparent+0x2c>
}
    80002438:	70a2                	ld	ra,40(sp)
    8000243a:	7402                	ld	s0,32(sp)
    8000243c:	64e2                	ld	s1,24(sp)
    8000243e:	6942                	ld	s2,16(sp)
    80002440:	69a2                	ld	s3,8(sp)
    80002442:	6a02                	ld	s4,0(sp)
    80002444:	6145                	addi	sp,sp,48
    80002446:	8082                	ret

0000000080002448 <exit>:
{
    80002448:	7179                	addi	sp,sp,-48
    8000244a:	f406                	sd	ra,40(sp)
    8000244c:	f022                	sd	s0,32(sp)
    8000244e:	ec26                	sd	s1,24(sp)
    80002450:	e84a                	sd	s2,16(sp)
    80002452:	e44e                	sd	s3,8(sp)
    80002454:	e052                	sd	s4,0(sp)
    80002456:	1800                	addi	s0,sp,48
    80002458:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000245a:	fffff097          	auipc	ra,0xfffff
    8000245e:	56c080e7          	jalr	1388(ra) # 800019c6 <myproc>
    80002462:	89aa                	mv	s3,a0
  if(p == initproc)
    80002464:	00006797          	auipc	a5,0x6
    80002468:	6f47b783          	ld	a5,1780(a5) # 80008b58 <initproc>
    8000246c:	0d050493          	addi	s1,a0,208
    80002470:	15050913          	addi	s2,a0,336
    80002474:	02a79363          	bne	a5,a0,8000249a <exit+0x52>
    panic("init exiting");
    80002478:	00006517          	auipc	a0,0x6
    8000247c:	de850513          	addi	a0,a0,-536 # 80008260 <digits+0x220>
    80002480:	ffffe097          	auipc	ra,0xffffe
    80002484:	0c4080e7          	jalr	196(ra) # 80000544 <panic>
      fileclose(f);
    80002488:	00002097          	auipc	ra,0x2
    8000248c:	692080e7          	jalr	1682(ra) # 80004b1a <fileclose>
      p->ofile[fd] = 0;
    80002490:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002494:	04a1                	addi	s1,s1,8
    80002496:	01248563          	beq	s1,s2,800024a0 <exit+0x58>
    if(p->ofile[fd]){
    8000249a:	6088                	ld	a0,0(s1)
    8000249c:	f575                	bnez	a0,80002488 <exit+0x40>
    8000249e:	bfdd                	j	80002494 <exit+0x4c>
  begin_op();
    800024a0:	00002097          	auipc	ra,0x2
    800024a4:	1ae080e7          	jalr	430(ra) # 8000464e <begin_op>
  iput(p->cwd);
    800024a8:	1509b503          	ld	a0,336(s3)
    800024ac:	00002097          	auipc	ra,0x2
    800024b0:	99a080e7          	jalr	-1638(ra) # 80003e46 <iput>
  end_op();
    800024b4:	00002097          	auipc	ra,0x2
    800024b8:	21a080e7          	jalr	538(ra) # 800046ce <end_op>
  p->cwd = 0;
    800024bc:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800024c0:	0000f497          	auipc	s1,0xf
    800024c4:	92848493          	addi	s1,s1,-1752 # 80010de8 <wait_lock>
    800024c8:	8526                	mv	a0,s1
    800024ca:	ffffe097          	auipc	ra,0xffffe
    800024ce:	720080e7          	jalr	1824(ra) # 80000bea <acquire>
  reparent(p);
    800024d2:	854e                	mv	a0,s3
    800024d4:	00000097          	auipc	ra,0x0
    800024d8:	f1a080e7          	jalr	-230(ra) # 800023ee <reparent>
  wakeup(p->parent);
    800024dc:	0389b503          	ld	a0,56(s3)
    800024e0:	00000097          	auipc	ra,0x0
    800024e4:	e98080e7          	jalr	-360(ra) # 80002378 <wakeup>
  acquire(&p->lock);
    800024e8:	854e                	mv	a0,s3
    800024ea:	ffffe097          	auipc	ra,0xffffe
    800024ee:	700080e7          	jalr	1792(ra) # 80000bea <acquire>
  p->xstate = status;
    800024f2:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800024f6:	4795                	li	a5,5
    800024f8:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    800024fc:	00006797          	auipc	a5,0x6
    80002500:	6647a783          	lw	a5,1636(a5) # 80008b60 <ticks>
    80002504:	16f9aa23          	sw	a5,372(s3)
  release(&wait_lock);
    80002508:	8526                	mv	a0,s1
    8000250a:	ffffe097          	auipc	ra,0xffffe
    8000250e:	794080e7          	jalr	1940(ra) # 80000c9e <release>
  sched();
    80002512:	00000097          	auipc	ra,0x0
    80002516:	ba4080e7          	jalr	-1116(ra) # 800020b6 <sched>
  panic("zombie exit");
    8000251a:	00006517          	auipc	a0,0x6
    8000251e:	d5650513          	addi	a0,a0,-682 # 80008270 <digits+0x230>
    80002522:	ffffe097          	auipc	ra,0xffffe
    80002526:	022080e7          	jalr	34(ra) # 80000544 <panic>

000000008000252a <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000252a:	7179                	addi	sp,sp,-48
    8000252c:	f406                	sd	ra,40(sp)
    8000252e:	f022                	sd	s0,32(sp)
    80002530:	ec26                	sd	s1,24(sp)
    80002532:	e84a                	sd	s2,16(sp)
    80002534:	e44e                	sd	s3,8(sp)
    80002536:	1800                	addi	s0,sp,48
    80002538:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000253a:	0000f497          	auipc	s1,0xf
    8000253e:	cc648493          	addi	s1,s1,-826 # 80011200 <proc>
    80002542:	00016997          	auipc	s3,0x16
    80002546:	4be98993          	addi	s3,s3,1214 # 80018a00 <tickslock>
    acquire(&p->lock);
    8000254a:	8526                	mv	a0,s1
    8000254c:	ffffe097          	auipc	ra,0xffffe
    80002550:	69e080e7          	jalr	1694(ra) # 80000bea <acquire>
    if(p->pid == pid){
    80002554:	589c                	lw	a5,48(s1)
    80002556:	01278d63          	beq	a5,s2,80002570 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000255a:	8526                	mv	a0,s1
    8000255c:	ffffe097          	auipc	ra,0xffffe
    80002560:	742080e7          	jalr	1858(ra) # 80000c9e <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002564:	1e048493          	addi	s1,s1,480
    80002568:	ff3491e3          	bne	s1,s3,8000254a <kill+0x20>
  }
  return -1;
    8000256c:	557d                	li	a0,-1
    8000256e:	a829                	j	80002588 <kill+0x5e>
      p->killed = 1;
    80002570:	4785                	li	a5,1
    80002572:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002574:	4c98                	lw	a4,24(s1)
    80002576:	4789                	li	a5,2
    80002578:	00f70f63          	beq	a4,a5,80002596 <kill+0x6c>
      release(&p->lock);
    8000257c:	8526                	mv	a0,s1
    8000257e:	ffffe097          	auipc	ra,0xffffe
    80002582:	720080e7          	jalr	1824(ra) # 80000c9e <release>
      return 0;
    80002586:	4501                	li	a0,0
}
    80002588:	70a2                	ld	ra,40(sp)
    8000258a:	7402                	ld	s0,32(sp)
    8000258c:	64e2                	ld	s1,24(sp)
    8000258e:	6942                	ld	s2,16(sp)
    80002590:	69a2                	ld	s3,8(sp)
    80002592:	6145                	addi	sp,sp,48
    80002594:	8082                	ret
        p->state = RUNNABLE;
    80002596:	478d                	li	a5,3
    80002598:	cc9c                	sw	a5,24(s1)
    8000259a:	b7cd                	j	8000257c <kill+0x52>

000000008000259c <setkilled>:

void
setkilled(struct proc *p)
{
    8000259c:	1101                	addi	sp,sp,-32
    8000259e:	ec06                	sd	ra,24(sp)
    800025a0:	e822                	sd	s0,16(sp)
    800025a2:	e426                	sd	s1,8(sp)
    800025a4:	1000                	addi	s0,sp,32
    800025a6:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800025a8:	ffffe097          	auipc	ra,0xffffe
    800025ac:	642080e7          	jalr	1602(ra) # 80000bea <acquire>
  p->killed = 1;
    800025b0:	4785                	li	a5,1
    800025b2:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800025b4:	8526                	mv	a0,s1
    800025b6:	ffffe097          	auipc	ra,0xffffe
    800025ba:	6e8080e7          	jalr	1768(ra) # 80000c9e <release>
}
    800025be:	60e2                	ld	ra,24(sp)
    800025c0:	6442                	ld	s0,16(sp)
    800025c2:	64a2                	ld	s1,8(sp)
    800025c4:	6105                	addi	sp,sp,32
    800025c6:	8082                	ret

00000000800025c8 <killed>:

int
killed(struct proc *p)
{
    800025c8:	1101                	addi	sp,sp,-32
    800025ca:	ec06                	sd	ra,24(sp)
    800025cc:	e822                	sd	s0,16(sp)
    800025ce:	e426                	sd	s1,8(sp)
    800025d0:	e04a                	sd	s2,0(sp)
    800025d2:	1000                	addi	s0,sp,32
    800025d4:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800025d6:	ffffe097          	auipc	ra,0xffffe
    800025da:	614080e7          	jalr	1556(ra) # 80000bea <acquire>
  k = p->killed;
    800025de:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800025e2:	8526                	mv	a0,s1
    800025e4:	ffffe097          	auipc	ra,0xffffe
    800025e8:	6ba080e7          	jalr	1722(ra) # 80000c9e <release>
  return k;
}
    800025ec:	854a                	mv	a0,s2
    800025ee:	60e2                	ld	ra,24(sp)
    800025f0:	6442                	ld	s0,16(sp)
    800025f2:	64a2                	ld	s1,8(sp)
    800025f4:	6902                	ld	s2,0(sp)
    800025f6:	6105                	addi	sp,sp,32
    800025f8:	8082                	ret

00000000800025fa <wait>:
{
    800025fa:	715d                	addi	sp,sp,-80
    800025fc:	e486                	sd	ra,72(sp)
    800025fe:	e0a2                	sd	s0,64(sp)
    80002600:	fc26                	sd	s1,56(sp)
    80002602:	f84a                	sd	s2,48(sp)
    80002604:	f44e                	sd	s3,40(sp)
    80002606:	f052                	sd	s4,32(sp)
    80002608:	ec56                	sd	s5,24(sp)
    8000260a:	e85a                	sd	s6,16(sp)
    8000260c:	e45e                	sd	s7,8(sp)
    8000260e:	e062                	sd	s8,0(sp)
    80002610:	0880                	addi	s0,sp,80
    80002612:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002614:	fffff097          	auipc	ra,0xfffff
    80002618:	3b2080e7          	jalr	946(ra) # 800019c6 <myproc>
    8000261c:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000261e:	0000e517          	auipc	a0,0xe
    80002622:	7ca50513          	addi	a0,a0,1994 # 80010de8 <wait_lock>
    80002626:	ffffe097          	auipc	ra,0xffffe
    8000262a:	5c4080e7          	jalr	1476(ra) # 80000bea <acquire>
    havekids = 0;
    8000262e:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002630:	4a15                	li	s4,5
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002632:	00016997          	auipc	s3,0x16
    80002636:	3ce98993          	addi	s3,s3,974 # 80018a00 <tickslock>
        havekids = 1;
    8000263a:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000263c:	0000ec17          	auipc	s8,0xe
    80002640:	7acc0c13          	addi	s8,s8,1964 # 80010de8 <wait_lock>
    havekids = 0;
    80002644:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002646:	0000f497          	auipc	s1,0xf
    8000264a:	bba48493          	addi	s1,s1,-1094 # 80011200 <proc>
    8000264e:	a0bd                	j	800026bc <wait+0xc2>
          pid = pp->pid;
    80002650:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002654:	000b0e63          	beqz	s6,80002670 <wait+0x76>
    80002658:	4691                	li	a3,4
    8000265a:	02c48613          	addi	a2,s1,44
    8000265e:	85da                	mv	a1,s6
    80002660:	05093503          	ld	a0,80(s2)
    80002664:	fffff097          	auipc	ra,0xfffff
    80002668:	020080e7          	jalr	32(ra) # 80001684 <copyout>
    8000266c:	02054563          	bltz	a0,80002696 <wait+0x9c>
          freeproc(pp);
    80002670:	8526                	mv	a0,s1
    80002672:	fffff097          	auipc	ra,0xfffff
    80002676:	506080e7          	jalr	1286(ra) # 80001b78 <freeproc>
          release(&pp->lock);
    8000267a:	8526                	mv	a0,s1
    8000267c:	ffffe097          	auipc	ra,0xffffe
    80002680:	622080e7          	jalr	1570(ra) # 80000c9e <release>
          release(&wait_lock);
    80002684:	0000e517          	auipc	a0,0xe
    80002688:	76450513          	addi	a0,a0,1892 # 80010de8 <wait_lock>
    8000268c:	ffffe097          	auipc	ra,0xffffe
    80002690:	612080e7          	jalr	1554(ra) # 80000c9e <release>
          return pid;
    80002694:	a0b5                	j	80002700 <wait+0x106>
            release(&pp->lock);
    80002696:	8526                	mv	a0,s1
    80002698:	ffffe097          	auipc	ra,0xffffe
    8000269c:	606080e7          	jalr	1542(ra) # 80000c9e <release>
            release(&wait_lock);
    800026a0:	0000e517          	auipc	a0,0xe
    800026a4:	74850513          	addi	a0,a0,1864 # 80010de8 <wait_lock>
    800026a8:	ffffe097          	auipc	ra,0xffffe
    800026ac:	5f6080e7          	jalr	1526(ra) # 80000c9e <release>
            return -1;
    800026b0:	59fd                	li	s3,-1
    800026b2:	a0b9                	j	80002700 <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800026b4:	1e048493          	addi	s1,s1,480
    800026b8:	03348463          	beq	s1,s3,800026e0 <wait+0xe6>
      if(pp->parent == p){
    800026bc:	7c9c                	ld	a5,56(s1)
    800026be:	ff279be3          	bne	a5,s2,800026b4 <wait+0xba>
        acquire(&pp->lock);
    800026c2:	8526                	mv	a0,s1
    800026c4:	ffffe097          	auipc	ra,0xffffe
    800026c8:	526080e7          	jalr	1318(ra) # 80000bea <acquire>
        if(pp->state == ZOMBIE){
    800026cc:	4c9c                	lw	a5,24(s1)
    800026ce:	f94781e3          	beq	a5,s4,80002650 <wait+0x56>
        release(&pp->lock);
    800026d2:	8526                	mv	a0,s1
    800026d4:	ffffe097          	auipc	ra,0xffffe
    800026d8:	5ca080e7          	jalr	1482(ra) # 80000c9e <release>
        havekids = 1;
    800026dc:	8756                	mv	a4,s5
    800026de:	bfd9                	j	800026b4 <wait+0xba>
    if(!havekids || killed(p)){
    800026e0:	c719                	beqz	a4,800026ee <wait+0xf4>
    800026e2:	854a                	mv	a0,s2
    800026e4:	00000097          	auipc	ra,0x0
    800026e8:	ee4080e7          	jalr	-284(ra) # 800025c8 <killed>
    800026ec:	c51d                	beqz	a0,8000271a <wait+0x120>
      release(&wait_lock);
    800026ee:	0000e517          	auipc	a0,0xe
    800026f2:	6fa50513          	addi	a0,a0,1786 # 80010de8 <wait_lock>
    800026f6:	ffffe097          	auipc	ra,0xffffe
    800026fa:	5a8080e7          	jalr	1448(ra) # 80000c9e <release>
      return -1;
    800026fe:	59fd                	li	s3,-1
}
    80002700:	854e                	mv	a0,s3
    80002702:	60a6                	ld	ra,72(sp)
    80002704:	6406                	ld	s0,64(sp)
    80002706:	74e2                	ld	s1,56(sp)
    80002708:	7942                	ld	s2,48(sp)
    8000270a:	79a2                	ld	s3,40(sp)
    8000270c:	7a02                	ld	s4,32(sp)
    8000270e:	6ae2                	ld	s5,24(sp)
    80002710:	6b42                	ld	s6,16(sp)
    80002712:	6ba2                	ld	s7,8(sp)
    80002714:	6c02                	ld	s8,0(sp)
    80002716:	6161                	addi	sp,sp,80
    80002718:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000271a:	85e2                	mv	a1,s8
    8000271c:	854a                	mv	a0,s2
    8000271e:	00000097          	auipc	ra,0x0
    80002722:	aaa080e7          	jalr	-1366(ra) # 800021c8 <sleep>
    havekids = 0;
    80002726:	bf39                	j	80002644 <wait+0x4a>

0000000080002728 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002728:	7179                	addi	sp,sp,-48
    8000272a:	f406                	sd	ra,40(sp)
    8000272c:	f022                	sd	s0,32(sp)
    8000272e:	ec26                	sd	s1,24(sp)
    80002730:	e84a                	sd	s2,16(sp)
    80002732:	e44e                	sd	s3,8(sp)
    80002734:	e052                	sd	s4,0(sp)
    80002736:	1800                	addi	s0,sp,48
    80002738:	84aa                	mv	s1,a0
    8000273a:	892e                	mv	s2,a1
    8000273c:	89b2                	mv	s3,a2
    8000273e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002740:	fffff097          	auipc	ra,0xfffff
    80002744:	286080e7          	jalr	646(ra) # 800019c6 <myproc>
  if(user_dst){
    80002748:	c08d                	beqz	s1,8000276a <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000274a:	86d2                	mv	a3,s4
    8000274c:	864e                	mv	a2,s3
    8000274e:	85ca                	mv	a1,s2
    80002750:	6928                	ld	a0,80(a0)
    80002752:	fffff097          	auipc	ra,0xfffff
    80002756:	f32080e7          	jalr	-206(ra) # 80001684 <copyout>
  } else {
    memmove((char *)dst, src, len);
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
    memmove((char *)dst, src, len);
    8000276a:	000a061b          	sext.w	a2,s4
    8000276e:	85ce                	mv	a1,s3
    80002770:	854a                	mv	a0,s2
    80002772:	ffffe097          	auipc	ra,0xffffe
    80002776:	5d4080e7          	jalr	1492(ra) # 80000d46 <memmove>
    return 0;
    8000277a:	8526                	mv	a0,s1
    8000277c:	bff9                	j	8000275a <either_copyout+0x32>

000000008000277e <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000277e:	7179                	addi	sp,sp,-48
    80002780:	f406                	sd	ra,40(sp)
    80002782:	f022                	sd	s0,32(sp)
    80002784:	ec26                	sd	s1,24(sp)
    80002786:	e84a                	sd	s2,16(sp)
    80002788:	e44e                	sd	s3,8(sp)
    8000278a:	e052                	sd	s4,0(sp)
    8000278c:	1800                	addi	s0,sp,48
    8000278e:	892a                	mv	s2,a0
    80002790:	84ae                	mv	s1,a1
    80002792:	89b2                	mv	s3,a2
    80002794:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002796:	fffff097          	auipc	ra,0xfffff
    8000279a:	230080e7          	jalr	560(ra) # 800019c6 <myproc>
  if(user_src){
    8000279e:	c08d                	beqz	s1,800027c0 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800027a0:	86d2                	mv	a3,s4
    800027a2:	864e                	mv	a2,s3
    800027a4:	85ca                	mv	a1,s2
    800027a6:	6928                	ld	a0,80(a0)
    800027a8:	fffff097          	auipc	ra,0xfffff
    800027ac:	f68080e7          	jalr	-152(ra) # 80001710 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800027b0:	70a2                	ld	ra,40(sp)
    800027b2:	7402                	ld	s0,32(sp)
    800027b4:	64e2                	ld	s1,24(sp)
    800027b6:	6942                	ld	s2,16(sp)
    800027b8:	69a2                	ld	s3,8(sp)
    800027ba:	6a02                	ld	s4,0(sp)
    800027bc:	6145                	addi	sp,sp,48
    800027be:	8082                	ret
    memmove(dst, (char*)src, len);
    800027c0:	000a061b          	sext.w	a2,s4
    800027c4:	85ce                	mv	a1,s3
    800027c6:	854a                	mv	a0,s2
    800027c8:	ffffe097          	auipc	ra,0xffffe
    800027cc:	57e080e7          	jalr	1406(ra) # 80000d46 <memmove>
    return 0;
    800027d0:	8526                	mv	a0,s1
    800027d2:	bff9                	j	800027b0 <either_copyin+0x32>

00000000800027d4 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800027d4:	715d                	addi	sp,sp,-80
    800027d6:	e486                	sd	ra,72(sp)
    800027d8:	e0a2                	sd	s0,64(sp)
    800027da:	fc26                	sd	s1,56(sp)
    800027dc:	f84a                	sd	s2,48(sp)
    800027de:	f44e                	sd	s3,40(sp)
    800027e0:	f052                	sd	s4,32(sp)
    800027e2:	ec56                	sd	s5,24(sp)
    800027e4:	e85a                	sd	s6,16(sp)
    800027e6:	e45e                	sd	s7,8(sp)
    800027e8:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800027ea:	00006517          	auipc	a0,0x6
    800027ee:	8de50513          	addi	a0,a0,-1826 # 800080c8 <digits+0x88>
    800027f2:	ffffe097          	auipc	ra,0xffffe
    800027f6:	d9c080e7          	jalr	-612(ra) # 8000058e <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800027fa:	0000f497          	auipc	s1,0xf
    800027fe:	b5e48493          	addi	s1,s1,-1186 # 80011358 <proc+0x158>
    80002802:	00016917          	auipc	s2,0x16
    80002806:	35690913          	addi	s2,s2,854 # 80018b58 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000280a:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000280c:	00006997          	auipc	s3,0x6
    80002810:	a7498993          	addi	s3,s3,-1420 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    80002814:	00006a97          	auipc	s5,0x6
    80002818:	a74a8a93          	addi	s5,s5,-1420 # 80008288 <digits+0x248>
    printf("\n");
    8000281c:	00006a17          	auipc	s4,0x6
    80002820:	8aca0a13          	addi	s4,s4,-1876 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002824:	00006b97          	auipc	s7,0x6
    80002828:	aa4b8b93          	addi	s7,s7,-1372 # 800082c8 <states.1787>
    8000282c:	a00d                	j	8000284e <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000282e:	ed86a583          	lw	a1,-296(a3)
    80002832:	8556                	mv	a0,s5
    80002834:	ffffe097          	auipc	ra,0xffffe
    80002838:	d5a080e7          	jalr	-678(ra) # 8000058e <printf>
    printf("\n");
    8000283c:	8552                	mv	a0,s4
    8000283e:	ffffe097          	auipc	ra,0xffffe
    80002842:	d50080e7          	jalr	-688(ra) # 8000058e <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002846:	1e048493          	addi	s1,s1,480
    8000284a:	03248163          	beq	s1,s2,8000286c <procdump+0x98>
    if(p->state == UNUSED)
    8000284e:	86a6                	mv	a3,s1
    80002850:	ec04a783          	lw	a5,-320(s1)
    80002854:	dbed                	beqz	a5,80002846 <procdump+0x72>
      state = "???";
    80002856:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002858:	fcfb6be3          	bltu	s6,a5,8000282e <procdump+0x5a>
    8000285c:	1782                	slli	a5,a5,0x20
    8000285e:	9381                	srli	a5,a5,0x20
    80002860:	078e                	slli	a5,a5,0x3
    80002862:	97de                	add	a5,a5,s7
    80002864:	6390                	ld	a2,0(a5)
    80002866:	f661                	bnez	a2,8000282e <procdump+0x5a>
      state = "???";
    80002868:	864e                	mv	a2,s3
    8000286a:	b7d1                	j	8000282e <procdump+0x5a>
  }
}
    8000286c:	60a6                	ld	ra,72(sp)
    8000286e:	6406                	ld	s0,64(sp)
    80002870:	74e2                	ld	s1,56(sp)
    80002872:	7942                	ld	s2,48(sp)
    80002874:	79a2                	ld	s3,40(sp)
    80002876:	7a02                	ld	s4,32(sp)
    80002878:	6ae2                	ld	s5,24(sp)
    8000287a:	6b42                	ld	s6,16(sp)
    8000287c:	6ba2                	ld	s7,8(sp)
    8000287e:	6161                	addi	sp,sp,80
    80002880:	8082                	ret

0000000080002882 <setpriority>:

int
setpriority(int new_priority, int pid)
{
    80002882:	7179                	addi	sp,sp,-48
    80002884:	f406                	sd	ra,40(sp)
    80002886:	f022                	sd	s0,32(sp)
    80002888:	ec26                	sd	s1,24(sp)
    8000288a:	e84a                	sd	s2,16(sp)
    8000288c:	e44e                	sd	s3,8(sp)
    8000288e:	e052                	sd	s4,0(sp)
    80002890:	1800                	addi	s0,sp,48
    80002892:	8a2a                	mv	s4,a0
    80002894:	892e                	mv	s2,a1
  int prev_priority;
  prev_priority = 0;

  struct proc* p;
  for(p = proc; p < &proc[NPROC]; p++)
    80002896:	0000f497          	auipc	s1,0xf
    8000289a:	96a48493          	addi	s1,s1,-1686 # 80011200 <proc>
    8000289e:	00016997          	auipc	s3,0x16
    800028a2:	16298993          	addi	s3,s3,354 # 80018a00 <tickslock>
  {
    acquire(&p->lock);
    800028a6:	8526                	mv	a0,s1
    800028a8:	ffffe097          	auipc	ra,0xffffe
    800028ac:	342080e7          	jalr	834(ra) # 80000bea <acquire>

    if(p->pid == pid)
    800028b0:	589c                	lw	a5,48(s1)
    800028b2:	01278d63          	beq	a5,s2,800028cc <setpriority+0x4a>
        yield();
      }

      break;
    }
    release(&p->lock);
    800028b6:	8526                	mv	a0,s1
    800028b8:	ffffe097          	auipc	ra,0xffffe
    800028bc:	3e6080e7          	jalr	998(ra) # 80000c9e <release>
  for(p = proc; p < &proc[NPROC]; p++)
    800028c0:	1e048493          	addi	s1,s1,480
    800028c4:	ff3491e3          	bne	s1,s3,800028a6 <setpriority+0x24>
  prev_priority = 0;
    800028c8:	4901                	li	s2,0
    800028ca:	a005                	j	800028ea <setpriority+0x68>
      prev_priority = p->priority;
    800028cc:	1d84a903          	lw	s2,472(s1)
      p->priority = new_priority;
    800028d0:	1d44bc23          	sd	s4,472(s1)
      p->sleeptime = 0;
    800028d4:	1c04b423          	sd	zero,456(s1)
      p->runtime = 0;
    800028d8:	1a04bc23          	sd	zero,440(s1)
      release(&p->lock);
    800028dc:	8526                	mv	a0,s1
    800028de:	ffffe097          	auipc	ra,0xffffe
    800028e2:	3c0080e7          	jalr	960(ra) # 80000c9e <release>
      if(reschedule){
    800028e6:	012a4b63          	blt	s4,s2,800028fc <setpriority+0x7a>
  }
  return prev_priority;
}
    800028ea:	854a                	mv	a0,s2
    800028ec:	70a2                	ld	ra,40(sp)
    800028ee:	7402                	ld	s0,32(sp)
    800028f0:	64e2                	ld	s1,24(sp)
    800028f2:	6942                	ld	s2,16(sp)
    800028f4:	69a2                	ld	s3,8(sp)
    800028f6:	6a02                	ld	s4,0(sp)
    800028f8:	6145                	addi	sp,sp,48
    800028fa:	8082                	ret
        yield();
    800028fc:	00000097          	auipc	ra,0x0
    80002900:	890080e7          	jalr	-1904(ra) # 8000218c <yield>
    80002904:	b7dd                	j	800028ea <setpriority+0x68>

0000000080002906 <swtch>:
    80002906:	00153023          	sd	ra,0(a0)
    8000290a:	00253423          	sd	sp,8(a0)
    8000290e:	e900                	sd	s0,16(a0)
    80002910:	ed04                	sd	s1,24(a0)
    80002912:	03253023          	sd	s2,32(a0)
    80002916:	03353423          	sd	s3,40(a0)
    8000291a:	03453823          	sd	s4,48(a0)
    8000291e:	03553c23          	sd	s5,56(a0)
    80002922:	05653023          	sd	s6,64(a0)
    80002926:	05753423          	sd	s7,72(a0)
    8000292a:	05853823          	sd	s8,80(a0)
    8000292e:	05953c23          	sd	s9,88(a0)
    80002932:	07a53023          	sd	s10,96(a0)
    80002936:	07b53423          	sd	s11,104(a0)
    8000293a:	0005b083          	ld	ra,0(a1)
    8000293e:	0085b103          	ld	sp,8(a1)
    80002942:	6980                	ld	s0,16(a1)
    80002944:	6d84                	ld	s1,24(a1)
    80002946:	0205b903          	ld	s2,32(a1)
    8000294a:	0285b983          	ld	s3,40(a1)
    8000294e:	0305ba03          	ld	s4,48(a1)
    80002952:	0385ba83          	ld	s5,56(a1)
    80002956:	0405bb03          	ld	s6,64(a1)
    8000295a:	0485bb83          	ld	s7,72(a1)
    8000295e:	0505bc03          	ld	s8,80(a1)
    80002962:	0585bc83          	ld	s9,88(a1)
    80002966:	0605bd03          	ld	s10,96(a1)
    8000296a:	0685bd83          	ld	s11,104(a1)
    8000296e:	8082                	ret

0000000080002970 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002970:	1141                	addi	sp,sp,-16
    80002972:	e406                	sd	ra,8(sp)
    80002974:	e022                	sd	s0,0(sp)
    80002976:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002978:	00006597          	auipc	a1,0x6
    8000297c:	98058593          	addi	a1,a1,-1664 # 800082f8 <states.1787+0x30>
    80002980:	00016517          	auipc	a0,0x16
    80002984:	08050513          	addi	a0,a0,128 # 80018a00 <tickslock>
    80002988:	ffffe097          	auipc	ra,0xffffe
    8000298c:	1d2080e7          	jalr	466(ra) # 80000b5a <initlock>
}
    80002990:	60a2                	ld	ra,8(sp)
    80002992:	6402                	ld	s0,0(sp)
    80002994:	0141                	addi	sp,sp,16
    80002996:	8082                	ret

0000000080002998 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002998:	1141                	addi	sp,sp,-16
    8000299a:	e422                	sd	s0,8(sp)
    8000299c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000299e:	00003797          	auipc	a5,0x3
    800029a2:	7c278793          	addi	a5,a5,1986 # 80006160 <kernelvec>
    800029a6:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800029aa:	6422                	ld	s0,8(sp)
    800029ac:	0141                	addi	sp,sp,16
    800029ae:	8082                	ret

00000000800029b0 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800029b0:	1141                	addi	sp,sp,-16
    800029b2:	e406                	sd	ra,8(sp)
    800029b4:	e022                	sd	s0,0(sp)
    800029b6:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800029b8:	fffff097          	auipc	ra,0xfffff
    800029bc:	00e080e7          	jalr	14(ra) # 800019c6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029c0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800029c4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029c6:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800029ca:	00004617          	auipc	a2,0x4
    800029ce:	63660613          	addi	a2,a2,1590 # 80007000 <_trampoline>
    800029d2:	00004697          	auipc	a3,0x4
    800029d6:	62e68693          	addi	a3,a3,1582 # 80007000 <_trampoline>
    800029da:	8e91                	sub	a3,a3,a2
    800029dc:	040007b7          	lui	a5,0x4000
    800029e0:	17fd                	addi	a5,a5,-1
    800029e2:	07b2                	slli	a5,a5,0xc
    800029e4:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029e6:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800029ea:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800029ec:	180026f3          	csrr	a3,satp
    800029f0:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800029f2:	6d38                	ld	a4,88(a0)
    800029f4:	6134                	ld	a3,64(a0)
    800029f6:	6585                	lui	a1,0x1
    800029f8:	96ae                	add	a3,a3,a1
    800029fa:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800029fc:	6d38                	ld	a4,88(a0)
    800029fe:	00000697          	auipc	a3,0x0
    80002a02:	13e68693          	addi	a3,a3,318 # 80002b3c <usertrap>
    80002a06:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002a08:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002a0a:	8692                	mv	a3,tp
    80002a0c:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a0e:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002a12:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002a16:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a1a:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002a1e:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a20:	6f18                	ld	a4,24(a4)
    80002a22:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002a26:	6928                	ld	a0,80(a0)
    80002a28:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002a2a:	00004717          	auipc	a4,0x4
    80002a2e:	67270713          	addi	a4,a4,1650 # 8000709c <userret>
    80002a32:	8f11                	sub	a4,a4,a2
    80002a34:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002a36:	577d                	li	a4,-1
    80002a38:	177e                	slli	a4,a4,0x3f
    80002a3a:	8d59                	or	a0,a0,a4
    80002a3c:	9782                	jalr	a5
}
    80002a3e:	60a2                	ld	ra,8(sp)
    80002a40:	6402                	ld	s0,0(sp)
    80002a42:	0141                	addi	sp,sp,16
    80002a44:	8082                	ret

0000000080002a46 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002a46:	1101                	addi	sp,sp,-32
    80002a48:	ec06                	sd	ra,24(sp)
    80002a4a:	e822                	sd	s0,16(sp)
    80002a4c:	e426                	sd	s1,8(sp)
    80002a4e:	e04a                	sd	s2,0(sp)
    80002a50:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002a52:	00016917          	auipc	s2,0x16
    80002a56:	fae90913          	addi	s2,s2,-82 # 80018a00 <tickslock>
    80002a5a:	854a                	mv	a0,s2
    80002a5c:	ffffe097          	auipc	ra,0xffffe
    80002a60:	18e080e7          	jalr	398(ra) # 80000bea <acquire>
  ticks++;
    80002a64:	00006497          	auipc	s1,0x6
    80002a68:	0fc48493          	addi	s1,s1,252 # 80008b60 <ticks>
    80002a6c:	409c                	lw	a5,0(s1)
    80002a6e:	2785                	addiw	a5,a5,1
    80002a70:	c09c                	sw	a5,0(s1)
  update_time();
    80002a72:	fffff097          	auipc	ra,0xfffff
    80002a76:	4d0080e7          	jalr	1232(ra) # 80001f42 <update_time>
  wakeup(&ticks);
    80002a7a:	8526                	mv	a0,s1
    80002a7c:	00000097          	auipc	ra,0x0
    80002a80:	8fc080e7          	jalr	-1796(ra) # 80002378 <wakeup>
  release(&tickslock);
    80002a84:	854a                	mv	a0,s2
    80002a86:	ffffe097          	auipc	ra,0xffffe
    80002a8a:	218080e7          	jalr	536(ra) # 80000c9e <release>
}
    80002a8e:	60e2                	ld	ra,24(sp)
    80002a90:	6442                	ld	s0,16(sp)
    80002a92:	64a2                	ld	s1,8(sp)
    80002a94:	6902                	ld	s2,0(sp)
    80002a96:	6105                	addi	sp,sp,32
    80002a98:	8082                	ret

0000000080002a9a <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002a9a:	1101                	addi	sp,sp,-32
    80002a9c:	ec06                	sd	ra,24(sp)
    80002a9e:	e822                	sd	s0,16(sp)
    80002aa0:	e426                	sd	s1,8(sp)
    80002aa2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002aa4:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002aa8:	00074d63          	bltz	a4,80002ac2 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002aac:	57fd                	li	a5,-1
    80002aae:	17fe                	slli	a5,a5,0x3f
    80002ab0:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002ab2:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002ab4:	06f70363          	beq	a4,a5,80002b1a <devintr+0x80>
  }
}
    80002ab8:	60e2                	ld	ra,24(sp)
    80002aba:	6442                	ld	s0,16(sp)
    80002abc:	64a2                	ld	s1,8(sp)
    80002abe:	6105                	addi	sp,sp,32
    80002ac0:	8082                	ret
     (scause & 0xff) == 9){
    80002ac2:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002ac6:	46a5                	li	a3,9
    80002ac8:	fed792e3          	bne	a5,a3,80002aac <devintr+0x12>
    int irq = plic_claim();
    80002acc:	00003097          	auipc	ra,0x3
    80002ad0:	79c080e7          	jalr	1948(ra) # 80006268 <plic_claim>
    80002ad4:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002ad6:	47a9                	li	a5,10
    80002ad8:	02f50763          	beq	a0,a5,80002b06 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002adc:	4785                	li	a5,1
    80002ade:	02f50963          	beq	a0,a5,80002b10 <devintr+0x76>
    return 1;
    80002ae2:	4505                	li	a0,1
    } else if(irq){
    80002ae4:	d8f1                	beqz	s1,80002ab8 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002ae6:	85a6                	mv	a1,s1
    80002ae8:	00006517          	auipc	a0,0x6
    80002aec:	81850513          	addi	a0,a0,-2024 # 80008300 <states.1787+0x38>
    80002af0:	ffffe097          	auipc	ra,0xffffe
    80002af4:	a9e080e7          	jalr	-1378(ra) # 8000058e <printf>
      plic_complete(irq);
    80002af8:	8526                	mv	a0,s1
    80002afa:	00003097          	auipc	ra,0x3
    80002afe:	792080e7          	jalr	1938(ra) # 8000628c <plic_complete>
    return 1;
    80002b02:	4505                	li	a0,1
    80002b04:	bf55                	j	80002ab8 <devintr+0x1e>
      uartintr();
    80002b06:	ffffe097          	auipc	ra,0xffffe
    80002b0a:	ea8080e7          	jalr	-344(ra) # 800009ae <uartintr>
    80002b0e:	b7ed                	j	80002af8 <devintr+0x5e>
      virtio_disk_intr();
    80002b10:	00004097          	auipc	ra,0x4
    80002b14:	ca6080e7          	jalr	-858(ra) # 800067b6 <virtio_disk_intr>
    80002b18:	b7c5                	j	80002af8 <devintr+0x5e>
    if(cpuid() == 0){
    80002b1a:	fffff097          	auipc	ra,0xfffff
    80002b1e:	e80080e7          	jalr	-384(ra) # 8000199a <cpuid>
    80002b22:	c901                	beqz	a0,80002b32 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002b24:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002b28:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002b2a:	14479073          	csrw	sip,a5
    return 2;
    80002b2e:	4509                	li	a0,2
    80002b30:	b761                	j	80002ab8 <devintr+0x1e>
      clockintr();
    80002b32:	00000097          	auipc	ra,0x0
    80002b36:	f14080e7          	jalr	-236(ra) # 80002a46 <clockintr>
    80002b3a:	b7ed                	j	80002b24 <devintr+0x8a>

0000000080002b3c <usertrap>:
{
    80002b3c:	1101                	addi	sp,sp,-32
    80002b3e:	ec06                	sd	ra,24(sp)
    80002b40:	e822                	sd	s0,16(sp)
    80002b42:	e426                	sd	s1,8(sp)
    80002b44:	e04a                	sd	s2,0(sp)
    80002b46:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b48:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002b4c:	1007f793          	andi	a5,a5,256
    80002b50:	e3b1                	bnez	a5,80002b94 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b52:	00003797          	auipc	a5,0x3
    80002b56:	60e78793          	addi	a5,a5,1550 # 80006160 <kernelvec>
    80002b5a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002b5e:	fffff097          	auipc	ra,0xfffff
    80002b62:	e68080e7          	jalr	-408(ra) # 800019c6 <myproc>
    80002b66:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002b68:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b6a:	14102773          	csrr	a4,sepc
    80002b6e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b70:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002b74:	47a1                	li	a5,8
    80002b76:	02f70763          	beq	a4,a5,80002ba4 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002b7a:	00000097          	auipc	ra,0x0
    80002b7e:	f20080e7          	jalr	-224(ra) # 80002a9a <devintr>
    80002b82:	892a                	mv	s2,a0
    80002b84:	c92d                	beqz	a0,80002bf6 <usertrap+0xba>
  if(killed(p))
    80002b86:	8526                	mv	a0,s1
    80002b88:	00000097          	auipc	ra,0x0
    80002b8c:	a40080e7          	jalr	-1472(ra) # 800025c8 <killed>
    80002b90:	c555                	beqz	a0,80002c3c <usertrap+0x100>
    80002b92:	a045                	j	80002c32 <usertrap+0xf6>
    panic("usertrap: not from user mode");
    80002b94:	00005517          	auipc	a0,0x5
    80002b98:	78c50513          	addi	a0,a0,1932 # 80008320 <states.1787+0x58>
    80002b9c:	ffffe097          	auipc	ra,0xffffe
    80002ba0:	9a8080e7          	jalr	-1624(ra) # 80000544 <panic>
    if(killed(p))
    80002ba4:	00000097          	auipc	ra,0x0
    80002ba8:	a24080e7          	jalr	-1500(ra) # 800025c8 <killed>
    80002bac:	ed1d                	bnez	a0,80002bea <usertrap+0xae>
    p->trapframe->epc += 4;
    80002bae:	6cb8                	ld	a4,88(s1)
    80002bb0:	6f1c                	ld	a5,24(a4)
    80002bb2:	0791                	addi	a5,a5,4
    80002bb4:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bb6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002bba:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bbe:	10079073          	csrw	sstatus,a5
    syscall();
    80002bc2:	00000097          	auipc	ra,0x0
    80002bc6:	328080e7          	jalr	808(ra) # 80002eea <syscall>
  if(killed(p))
    80002bca:	8526                	mv	a0,s1
    80002bcc:	00000097          	auipc	ra,0x0
    80002bd0:	9fc080e7          	jalr	-1540(ra) # 800025c8 <killed>
    80002bd4:	ed31                	bnez	a0,80002c30 <usertrap+0xf4>
  usertrapret();
    80002bd6:	00000097          	auipc	ra,0x0
    80002bda:	dda080e7          	jalr	-550(ra) # 800029b0 <usertrapret>
}
    80002bde:	60e2                	ld	ra,24(sp)
    80002be0:	6442                	ld	s0,16(sp)
    80002be2:	64a2                	ld	s1,8(sp)
    80002be4:	6902                	ld	s2,0(sp)
    80002be6:	6105                	addi	sp,sp,32
    80002be8:	8082                	ret
      exit(-1);
    80002bea:	557d                	li	a0,-1
    80002bec:	00000097          	auipc	ra,0x0
    80002bf0:	85c080e7          	jalr	-1956(ra) # 80002448 <exit>
    80002bf4:	bf6d                	j	80002bae <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bf6:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002bfa:	5890                	lw	a2,48(s1)
    80002bfc:	00005517          	auipc	a0,0x5
    80002c00:	74450513          	addi	a0,a0,1860 # 80008340 <states.1787+0x78>
    80002c04:	ffffe097          	auipc	ra,0xffffe
    80002c08:	98a080e7          	jalr	-1654(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c0c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c10:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c14:	00005517          	auipc	a0,0x5
    80002c18:	75c50513          	addi	a0,a0,1884 # 80008370 <states.1787+0xa8>
    80002c1c:	ffffe097          	auipc	ra,0xffffe
    80002c20:	972080e7          	jalr	-1678(ra) # 8000058e <printf>
    setkilled(p);
    80002c24:	8526                	mv	a0,s1
    80002c26:	00000097          	auipc	ra,0x0
    80002c2a:	976080e7          	jalr	-1674(ra) # 8000259c <setkilled>
    80002c2e:	bf71                	j	80002bca <usertrap+0x8e>
  if(killed(p))
    80002c30:	4901                	li	s2,0
    exit(-1);
    80002c32:	557d                	li	a0,-1
    80002c34:	00000097          	auipc	ra,0x0
    80002c38:	814080e7          	jalr	-2028(ra) # 80002448 <exit>
  if (which_dev == 2 && p->alarm_on == 1 && p->handlerpermission == 1) {
    80002c3c:	4789                	li	a5,2
    80002c3e:	f8f91ce3          	bne	s2,a5,80002bd6 <usertrap+0x9a>
    80002c42:	1984a703          	lw	a4,408(s1)
    80002c46:	4785                	li	a5,1
    80002c48:	00f70763          	beq	a4,a5,80002c56 <usertrap+0x11a>
    yield();
    80002c4c:	fffff097          	auipc	ra,0xfffff
    80002c50:	540080e7          	jalr	1344(ra) # 8000218c <yield>
    80002c54:	b749                	j	80002bd6 <usertrap+0x9a>
  if (which_dev == 2 && p->alarm_on == 1 && p->handlerpermission == 1) {
    80002c56:	1b04a703          	lw	a4,432(s1)
    80002c5a:	fef719e3          	bne	a4,a5,80002c4c <usertrap+0x110>
      struct trapframe *tf = kalloc();
    80002c5e:	ffffe097          	auipc	ra,0xffffe
    80002c62:	e9c080e7          	jalr	-356(ra) # 80000afa <kalloc>
    80002c66:	892a                	mv	s2,a0
      memmove(tf, p->trapframe, PGSIZE);
    80002c68:	6605                	lui	a2,0x1
    80002c6a:	6cac                	ld	a1,88(s1)
    80002c6c:	ffffe097          	auipc	ra,0xffffe
    80002c70:	0da080e7          	jalr	218(ra) # 80000d46 <memmove>
      p->alarm_tf = tf;
    80002c74:	1924b823          	sd	s2,400(s1)
      p->cur_ticks++;
    80002c78:	18c4a783          	lw	a5,396(s1)
    80002c7c:	2785                	addiw	a5,a5,1
    80002c7e:	0007871b          	sext.w	a4,a5
    80002c82:	18f4a623          	sw	a5,396(s1)
      if (p->cur_ticks >= p->ticks){
    80002c86:	1884a783          	lw	a5,392(s1)
    80002c8a:	fcf741e3          	blt	a4,a5,80002c4c <usertrap+0x110>
        p->trapframe->epc = p->handler;
    80002c8e:	6cbc                	ld	a5,88(s1)
    80002c90:	1804b703          	ld	a4,384(s1)
    80002c94:	ef98                	sd	a4,24(a5)
        p->handlerpermission = 0;
    80002c96:	1a04a823          	sw	zero,432(s1)
    80002c9a:	bf4d                	j	80002c4c <usertrap+0x110>

0000000080002c9c <kerneltrap>:
{
    80002c9c:	7179                	addi	sp,sp,-48
    80002c9e:	f406                	sd	ra,40(sp)
    80002ca0:	f022                	sd	s0,32(sp)
    80002ca2:	ec26                	sd	s1,24(sp)
    80002ca4:	e84a                	sd	s2,16(sp)
    80002ca6:	e44e                	sd	s3,8(sp)
    80002ca8:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002caa:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cae:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cb2:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002cb6:	1004f793          	andi	a5,s1,256
    80002cba:	cb85                	beqz	a5,80002cea <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cbc:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002cc0:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002cc2:	ef85                	bnez	a5,80002cfa <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002cc4:	00000097          	auipc	ra,0x0
    80002cc8:	dd6080e7          	jalr	-554(ra) # 80002a9a <devintr>
    80002ccc:	cd1d                	beqz	a0,80002d0a <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002cce:	4789                	li	a5,2
    80002cd0:	06f50a63          	beq	a0,a5,80002d44 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002cd4:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002cd8:	10049073          	csrw	sstatus,s1
}
    80002cdc:	70a2                	ld	ra,40(sp)
    80002cde:	7402                	ld	s0,32(sp)
    80002ce0:	64e2                	ld	s1,24(sp)
    80002ce2:	6942                	ld	s2,16(sp)
    80002ce4:	69a2                	ld	s3,8(sp)
    80002ce6:	6145                	addi	sp,sp,48
    80002ce8:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002cea:	00005517          	auipc	a0,0x5
    80002cee:	6a650513          	addi	a0,a0,1702 # 80008390 <states.1787+0xc8>
    80002cf2:	ffffe097          	auipc	ra,0xffffe
    80002cf6:	852080e7          	jalr	-1966(ra) # 80000544 <panic>
    panic("kerneltrap: interrupts enabled");
    80002cfa:	00005517          	auipc	a0,0x5
    80002cfe:	6be50513          	addi	a0,a0,1726 # 800083b8 <states.1787+0xf0>
    80002d02:	ffffe097          	auipc	ra,0xffffe
    80002d06:	842080e7          	jalr	-1982(ra) # 80000544 <panic>
    printf("scause %p\n", scause);
    80002d0a:	85ce                	mv	a1,s3
    80002d0c:	00005517          	auipc	a0,0x5
    80002d10:	6cc50513          	addi	a0,a0,1740 # 800083d8 <states.1787+0x110>
    80002d14:	ffffe097          	auipc	ra,0xffffe
    80002d18:	87a080e7          	jalr	-1926(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d1c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d20:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d24:	00005517          	auipc	a0,0x5
    80002d28:	6c450513          	addi	a0,a0,1732 # 800083e8 <states.1787+0x120>
    80002d2c:	ffffe097          	auipc	ra,0xffffe
    80002d30:	862080e7          	jalr	-1950(ra) # 8000058e <printf>
    panic("kerneltrap");
    80002d34:	00005517          	auipc	a0,0x5
    80002d38:	6cc50513          	addi	a0,a0,1740 # 80008400 <states.1787+0x138>
    80002d3c:	ffffe097          	auipc	ra,0xffffe
    80002d40:	808080e7          	jalr	-2040(ra) # 80000544 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d44:	fffff097          	auipc	ra,0xfffff
    80002d48:	c82080e7          	jalr	-894(ra) # 800019c6 <myproc>
    80002d4c:	d541                	beqz	a0,80002cd4 <kerneltrap+0x38>
    80002d4e:	fffff097          	auipc	ra,0xfffff
    80002d52:	c78080e7          	jalr	-904(ra) # 800019c6 <myproc>
    80002d56:	4d18                	lw	a4,24(a0)
    80002d58:	4791                	li	a5,4
    80002d5a:	f6f71de3          	bne	a4,a5,80002cd4 <kerneltrap+0x38>
    yield();
    80002d5e:	fffff097          	auipc	ra,0xfffff
    80002d62:	42e080e7          	jalr	1070(ra) # 8000218c <yield>
    80002d66:	b7bd                	j	80002cd4 <kerneltrap+0x38>

0000000080002d68 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002d68:	1101                	addi	sp,sp,-32
    80002d6a:	ec06                	sd	ra,24(sp)
    80002d6c:	e822                	sd	s0,16(sp)
    80002d6e:	e426                	sd	s1,8(sp)
    80002d70:	1000                	addi	s0,sp,32
    80002d72:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002d74:	fffff097          	auipc	ra,0xfffff
    80002d78:	c52080e7          	jalr	-942(ra) # 800019c6 <myproc>
  switch (n) {
    80002d7c:	4795                	li	a5,5
    80002d7e:	0497e163          	bltu	a5,s1,80002dc0 <argraw+0x58>
    80002d82:	048a                	slli	s1,s1,0x2
    80002d84:	00005717          	auipc	a4,0x5
    80002d88:	7d470713          	addi	a4,a4,2004 # 80008558 <states.1787+0x290>
    80002d8c:	94ba                	add	s1,s1,a4
    80002d8e:	409c                	lw	a5,0(s1)
    80002d90:	97ba                	add	a5,a5,a4
    80002d92:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002d94:	6d3c                	ld	a5,88(a0)
    80002d96:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002d98:	60e2                	ld	ra,24(sp)
    80002d9a:	6442                	ld	s0,16(sp)
    80002d9c:	64a2                	ld	s1,8(sp)
    80002d9e:	6105                	addi	sp,sp,32
    80002da0:	8082                	ret
    return p->trapframe->a1;
    80002da2:	6d3c                	ld	a5,88(a0)
    80002da4:	7fa8                	ld	a0,120(a5)
    80002da6:	bfcd                	j	80002d98 <argraw+0x30>
    return p->trapframe->a2;
    80002da8:	6d3c                	ld	a5,88(a0)
    80002daa:	63c8                	ld	a0,128(a5)
    80002dac:	b7f5                	j	80002d98 <argraw+0x30>
    return p->trapframe->a3;
    80002dae:	6d3c                	ld	a5,88(a0)
    80002db0:	67c8                	ld	a0,136(a5)
    80002db2:	b7dd                	j	80002d98 <argraw+0x30>
    return p->trapframe->a4;
    80002db4:	6d3c                	ld	a5,88(a0)
    80002db6:	6bc8                	ld	a0,144(a5)
    80002db8:	b7c5                	j	80002d98 <argraw+0x30>
    return p->trapframe->a5;
    80002dba:	6d3c                	ld	a5,88(a0)
    80002dbc:	6fc8                	ld	a0,152(a5)
    80002dbe:	bfe9                	j	80002d98 <argraw+0x30>
  panic("argraw");
    80002dc0:	00005517          	auipc	a0,0x5
    80002dc4:	65050513          	addi	a0,a0,1616 # 80008410 <states.1787+0x148>
    80002dc8:	ffffd097          	auipc	ra,0xffffd
    80002dcc:	77c080e7          	jalr	1916(ra) # 80000544 <panic>

0000000080002dd0 <fetchaddr>:
{
    80002dd0:	1101                	addi	sp,sp,-32
    80002dd2:	ec06                	sd	ra,24(sp)
    80002dd4:	e822                	sd	s0,16(sp)
    80002dd6:	e426                	sd	s1,8(sp)
    80002dd8:	e04a                	sd	s2,0(sp)
    80002dda:	1000                	addi	s0,sp,32
    80002ddc:	84aa                	mv	s1,a0
    80002dde:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002de0:	fffff097          	auipc	ra,0xfffff
    80002de4:	be6080e7          	jalr	-1050(ra) # 800019c6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002de8:	653c                	ld	a5,72(a0)
    80002dea:	02f4f863          	bgeu	s1,a5,80002e1a <fetchaddr+0x4a>
    80002dee:	00848713          	addi	a4,s1,8
    80002df2:	02e7e663          	bltu	a5,a4,80002e1e <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002df6:	46a1                	li	a3,8
    80002df8:	8626                	mv	a2,s1
    80002dfa:	85ca                	mv	a1,s2
    80002dfc:	6928                	ld	a0,80(a0)
    80002dfe:	fffff097          	auipc	ra,0xfffff
    80002e02:	912080e7          	jalr	-1774(ra) # 80001710 <copyin>
    80002e06:	00a03533          	snez	a0,a0
    80002e0a:	40a00533          	neg	a0,a0
}
    80002e0e:	60e2                	ld	ra,24(sp)
    80002e10:	6442                	ld	s0,16(sp)
    80002e12:	64a2                	ld	s1,8(sp)
    80002e14:	6902                	ld	s2,0(sp)
    80002e16:	6105                	addi	sp,sp,32
    80002e18:	8082                	ret
    return -1;
    80002e1a:	557d                	li	a0,-1
    80002e1c:	bfcd                	j	80002e0e <fetchaddr+0x3e>
    80002e1e:	557d                	li	a0,-1
    80002e20:	b7fd                	j	80002e0e <fetchaddr+0x3e>

0000000080002e22 <fetchstr>:
{
    80002e22:	7179                	addi	sp,sp,-48
    80002e24:	f406                	sd	ra,40(sp)
    80002e26:	f022                	sd	s0,32(sp)
    80002e28:	ec26                	sd	s1,24(sp)
    80002e2a:	e84a                	sd	s2,16(sp)
    80002e2c:	e44e                	sd	s3,8(sp)
    80002e2e:	1800                	addi	s0,sp,48
    80002e30:	892a                	mv	s2,a0
    80002e32:	84ae                	mv	s1,a1
    80002e34:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002e36:	fffff097          	auipc	ra,0xfffff
    80002e3a:	b90080e7          	jalr	-1136(ra) # 800019c6 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002e3e:	86ce                	mv	a3,s3
    80002e40:	864a                	mv	a2,s2
    80002e42:	85a6                	mv	a1,s1
    80002e44:	6928                	ld	a0,80(a0)
    80002e46:	fffff097          	auipc	ra,0xfffff
    80002e4a:	956080e7          	jalr	-1706(ra) # 8000179c <copyinstr>
    80002e4e:	00054e63          	bltz	a0,80002e6a <fetchstr+0x48>
  return strlen(buf);
    80002e52:	8526                	mv	a0,s1
    80002e54:	ffffe097          	auipc	ra,0xffffe
    80002e58:	016080e7          	jalr	22(ra) # 80000e6a <strlen>
}
    80002e5c:	70a2                	ld	ra,40(sp)
    80002e5e:	7402                	ld	s0,32(sp)
    80002e60:	64e2                	ld	s1,24(sp)
    80002e62:	6942                	ld	s2,16(sp)
    80002e64:	69a2                	ld	s3,8(sp)
    80002e66:	6145                	addi	sp,sp,48
    80002e68:	8082                	ret
    return -1;
    80002e6a:	557d                	li	a0,-1
    80002e6c:	bfc5                	j	80002e5c <fetchstr+0x3a>

0000000080002e6e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002e6e:	1101                	addi	sp,sp,-32
    80002e70:	ec06                	sd	ra,24(sp)
    80002e72:	e822                	sd	s0,16(sp)
    80002e74:	e426                	sd	s1,8(sp)
    80002e76:	1000                	addi	s0,sp,32
    80002e78:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e7a:	00000097          	auipc	ra,0x0
    80002e7e:	eee080e7          	jalr	-274(ra) # 80002d68 <argraw>
    80002e82:	c088                	sw	a0,0(s1)
  return 0;
}
    80002e84:	4501                	li	a0,0
    80002e86:	60e2                	ld	ra,24(sp)
    80002e88:	6442                	ld	s0,16(sp)
    80002e8a:	64a2                	ld	s1,8(sp)
    80002e8c:	6105                	addi	sp,sp,32
    80002e8e:	8082                	ret

0000000080002e90 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002e90:	1101                	addi	sp,sp,-32
    80002e92:	ec06                	sd	ra,24(sp)
    80002e94:	e822                	sd	s0,16(sp)
    80002e96:	e426                	sd	s1,8(sp)
    80002e98:	1000                	addi	s0,sp,32
    80002e9a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e9c:	00000097          	auipc	ra,0x0
    80002ea0:	ecc080e7          	jalr	-308(ra) # 80002d68 <argraw>
    80002ea4:	e088                	sd	a0,0(s1)
  return 0;
}
    80002ea6:	4501                	li	a0,0
    80002ea8:	60e2                	ld	ra,24(sp)
    80002eaa:	6442                	ld	s0,16(sp)
    80002eac:	64a2                	ld	s1,8(sp)
    80002eae:	6105                	addi	sp,sp,32
    80002eb0:	8082                	ret

0000000080002eb2 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002eb2:	7179                	addi	sp,sp,-48
    80002eb4:	f406                	sd	ra,40(sp)
    80002eb6:	f022                	sd	s0,32(sp)
    80002eb8:	ec26                	sd	s1,24(sp)
    80002eba:	e84a                	sd	s2,16(sp)
    80002ebc:	1800                	addi	s0,sp,48
    80002ebe:	84ae                	mv	s1,a1
    80002ec0:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002ec2:	fd840593          	addi	a1,s0,-40
    80002ec6:	00000097          	auipc	ra,0x0
    80002eca:	fca080e7          	jalr	-54(ra) # 80002e90 <argaddr>
  return fetchstr(addr, buf, max);
    80002ece:	864a                	mv	a2,s2
    80002ed0:	85a6                	mv	a1,s1
    80002ed2:	fd843503          	ld	a0,-40(s0)
    80002ed6:	00000097          	auipc	ra,0x0
    80002eda:	f4c080e7          	jalr	-180(ra) # 80002e22 <fetchstr>
}
    80002ede:	70a2                	ld	ra,40(sp)
    80002ee0:	7402                	ld	s0,32(sp)
    80002ee2:	64e2                	ld	s1,24(sp)
    80002ee4:	6942                	ld	s2,16(sp)
    80002ee6:	6145                	addi	sp,sp,48
    80002ee8:	8082                	ret

0000000080002eea <syscall>:
    [SYS_setpriority] 1,
};

void
syscall(void)
{
    80002eea:	7179                	addi	sp,sp,-48
    80002eec:	f406                	sd	ra,40(sp)
    80002eee:	f022                	sd	s0,32(sp)
    80002ef0:	ec26                	sd	s1,24(sp)
    80002ef2:	e84a                	sd	s2,16(sp)
    80002ef4:	e44e                	sd	s3,8(sp)
    80002ef6:	e052                	sd	s4,0(sp)
    80002ef8:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002efa:	fffff097          	auipc	ra,0xfffff
    80002efe:	acc080e7          	jalr	-1332(ra) # 800019c6 <myproc>
    80002f02:	892a                	mv	s2,a0

  num = p->trapframe->a7;
    80002f04:	6d24                	ld	s1,88(a0)
    80002f06:	74dc                	ld	a5,168(s1)
    80002f08:	0007899b          	sext.w	s3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) 
    80002f0c:	37fd                	addiw	a5,a5,-1
    80002f0e:	4769                	li	a4,26
    80002f10:	0af76163          	bltu	a4,a5,80002fb2 <syscall+0xc8>
    80002f14:	00399713          	slli	a4,s3,0x3
    80002f18:	00005797          	auipc	a5,0x5
    80002f1c:	65878793          	addi	a5,a5,1624 # 80008570 <syscalls>
    80002f20:	97ba                	add	a5,a5,a4
    80002f22:	639c                	ld	a5,0(a5)
    80002f24:	c7d9                	beqz	a5,80002fb2 <syscall+0xc8>
  {
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002f26:	9782                	jalr	a5
    80002f28:	f8a8                	sd	a0,112(s1)
    if ((p->mask >> num) & 1)
    80002f2a:	16892483          	lw	s1,360(s2)
    80002f2e:	4134d4bb          	sraw	s1,s1,s3
    80002f32:	8885                	andi	s1,s1,1
    80002f34:	c0c5                	beqz	s1,80002fd4 <syscall+0xea>
    {
      /* Modified for A4: Added entire section for trace, prints output for each syscall traced */
  	  printf("%d: syscall %s ( %d ",p->pid, syscallnames[num], p->trapframe->a0);
    80002f36:	05893703          	ld	a4,88(s2)
    80002f3a:	00399693          	slli	a3,s3,0x3
    80002f3e:	00006797          	auipc	a5,0x6
    80002f42:	b0a78793          	addi	a5,a5,-1270 # 80008a48 <syscallnames>
    80002f46:	97b6                	add	a5,a5,a3
    80002f48:	7b34                	ld	a3,112(a4)
    80002f4a:	6390                	ld	a2,0(a5)
    80002f4c:	03092583          	lw	a1,48(s2)
    80002f50:	00005517          	auipc	a0,0x5
    80002f54:	4c850513          	addi	a0,a0,1224 # 80008418 <states.1787+0x150>
    80002f58:	ffffd097          	auipc	ra,0xffffd
    80002f5c:	636080e7          	jalr	1590(ra) # 8000058e <printf>
      for (int i = 1; i < syscallnum[num]; i++) /* Modified for A4: 'num' tracks number of registers used by syscall and prints its register values  */
    80002f60:	098a                	slli	s3,s3,0x2
    80002f62:	00005797          	auipc	a5,0x5
    80002f66:	60e78793          	addi	a5,a5,1550 # 80008570 <syscalls>
    80002f6a:	99be                	add	s3,s3,a5
    80002f6c:	0e09a983          	lw	s3,224(s3)
    80002f70:	4785                	li	a5,1
    80002f72:	0337d463          	bge	a5,s3,80002f9a <syscall+0xb0>
        printf("%d ", argraw(i));
    80002f76:	00005a17          	auipc	s4,0x5
    80002f7a:	4baa0a13          	addi	s4,s4,1210 # 80008430 <states.1787+0x168>
    80002f7e:	8526                	mv	a0,s1
    80002f80:	00000097          	auipc	ra,0x0
    80002f84:	de8080e7          	jalr	-536(ra) # 80002d68 <argraw>
    80002f88:	85aa                	mv	a1,a0
    80002f8a:	8552                	mv	a0,s4
    80002f8c:	ffffd097          	auipc	ra,0xffffd
    80002f90:	602080e7          	jalr	1538(ra) # 8000058e <printf>
      for (int i = 1; i < syscallnum[num]; i++) /* Modified for A4: 'num' tracks number of registers used by syscall and prints its register values  */
    80002f94:	2485                	addiw	s1,s1,1
    80002f96:	ff3494e3          	bne	s1,s3,80002f7e <syscall+0x94>
      printf(") -> %d\n", p->trapframe->a0);
    80002f9a:	05893783          	ld	a5,88(s2)
    80002f9e:	7bac                	ld	a1,112(a5)
    80002fa0:	00005517          	auipc	a0,0x5
    80002fa4:	49850513          	addi	a0,a0,1176 # 80008438 <states.1787+0x170>
    80002fa8:	ffffd097          	auipc	ra,0xffffd
    80002fac:	5e6080e7          	jalr	1510(ra) # 8000058e <printf>
    80002fb0:	a015                	j	80002fd4 <syscall+0xea>
    }	
  } 
  else 
  {
    printf("%d %s: unknown sys call %d\n",
    80002fb2:	86ce                	mv	a3,s3
    80002fb4:	15890613          	addi	a2,s2,344
    80002fb8:	03092583          	lw	a1,48(s2)
    80002fbc:	00005517          	auipc	a0,0x5
    80002fc0:	48c50513          	addi	a0,a0,1164 # 80008448 <states.1787+0x180>
    80002fc4:	ffffd097          	auipc	ra,0xffffd
    80002fc8:	5ca080e7          	jalr	1482(ra) # 8000058e <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002fcc:	05893783          	ld	a5,88(s2)
    80002fd0:	577d                	li	a4,-1
    80002fd2:	fbb8                	sd	a4,112(a5)
  
  // if (p->mask >> num)
  // {
  // 	printf("%d: syscall %s -> %d\n",p->pid, syscallnames[num], p->trapframe->a0);
  // }	
}
    80002fd4:	70a2                	ld	ra,40(sp)
    80002fd6:	7402                	ld	s0,32(sp)
    80002fd8:	64e2                	ld	s1,24(sp)
    80002fda:	6942                	ld	s2,16(sp)
    80002fdc:	69a2                	ld	s3,8(sp)
    80002fde:	6a02                	ld	s4,0(sp)
    80002fe0:	6145                	addi	sp,sp,48
    80002fe2:	8082                	ret

0000000080002fe4 <sys_trace>:

int mask;

uint64
sys_trace(void)
{
    80002fe4:	1141                	addi	sp,sp,-16
    80002fe6:	e406                	sd	ra,8(sp)
    80002fe8:	e022                	sd	s0,0(sp)
    80002fea:	0800                	addi	s0,sp,16
	if(argint(0, &mask) < 0)
    80002fec:	00006597          	auipc	a1,0x6
    80002ff0:	b7858593          	addi	a1,a1,-1160 # 80008b64 <mask>
    80002ff4:	4501                	li	a0,0
    80002ff6:	00000097          	auipc	ra,0x0
    80002ffa:	e78080e7          	jalr	-392(ra) # 80002e6e <argint>
	{
		return -1;
    80002ffe:	57fd                	li	a5,-1
	if(argint(0, &mask) < 0)
    80003000:	00054d63          	bltz	a0,8000301a <sys_trace+0x36>
	}
	
  myproc()->mask = mask;
    80003004:	fffff097          	auipc	ra,0xfffff
    80003008:	9c2080e7          	jalr	-1598(ra) # 800019c6 <myproc>
    8000300c:	00006797          	auipc	a5,0x6
    80003010:	b587a783          	lw	a5,-1192(a5) # 80008b64 <mask>
    80003014:	16f52423          	sw	a5,360(a0)
	return 0;
    80003018:	4781                	li	a5,0
}	/* Modified for A4: Added trace */
    8000301a:	853e                	mv	a0,a5
    8000301c:	60a2                	ld	ra,8(sp)
    8000301e:	6402                	ld	s0,0(sp)
    80003020:	0141                	addi	sp,sp,16
    80003022:	8082                	ret

0000000080003024 <sys_sigalarm>:

/* Modified for A4: Added trace */
uint64 
sys_sigalarm(void)
{
    80003024:	1101                	addi	sp,sp,-32
    80003026:	ec06                	sd	ra,24(sp)
    80003028:	e822                	sd	s0,16(sp)
    8000302a:	1000                	addi	s0,sp,32
  uint64 addr;
  int ticks;
  if(argint(0, &ticks) < 0)
    8000302c:	fe440593          	addi	a1,s0,-28
    80003030:	4501                	li	a0,0
    80003032:	00000097          	auipc	ra,0x0
    80003036:	e3c080e7          	jalr	-452(ra) # 80002e6e <argint>
    return -1;
    8000303a:	57fd                	li	a5,-1
  if(argint(0, &ticks) < 0)
    8000303c:	04054463          	bltz	a0,80003084 <sys_sigalarm+0x60>
  if(argaddr(1, &addr) < 0)
    80003040:	fe840593          	addi	a1,s0,-24
    80003044:	4505                	li	a0,1
    80003046:	00000097          	auipc	ra,0x0
    8000304a:	e4a080e7          	jalr	-438(ra) # 80002e90 <argaddr>
    return -1;
    8000304e:	57fd                	li	a5,-1
  if(argaddr(1, &addr) < 0)
    80003050:	02054a63          	bltz	a0,80003084 <sys_sigalarm+0x60>

  myproc()->ticks = ticks;
    80003054:	fffff097          	auipc	ra,0xfffff
    80003058:	972080e7          	jalr	-1678(ra) # 800019c6 <myproc>
    8000305c:	fe442783          	lw	a5,-28(s0)
    80003060:	18f52423          	sw	a5,392(a0)
  myproc()->handler = addr;
    80003064:	fffff097          	auipc	ra,0xfffff
    80003068:	962080e7          	jalr	-1694(ra) # 800019c6 <myproc>
    8000306c:	fe843783          	ld	a5,-24(s0)
    80003070:	18f53023          	sd	a5,384(a0)
  myproc()->alarm_on = 1;
    80003074:	fffff097          	auipc	ra,0xfffff
    80003078:	952080e7          	jalr	-1710(ra) # 800019c6 <myproc>
    8000307c:	4785                	li	a5,1
    8000307e:	18f52c23          	sw	a5,408(a0)
  //myproc()->a1 = myproc()->trapframe->a0;
  //myproc()->a2 = myproc()->trapframe->a1;

  return 0;
    80003082:	4781                	li	a5,0
}
    80003084:	853e                	mv	a0,a5
    80003086:	60e2                	ld	ra,24(sp)
    80003088:	6442                	ld	s0,16(sp)
    8000308a:	6105                	addi	sp,sp,32
    8000308c:	8082                	ret

000000008000308e <sys_sigreturn>:

/* Modified for A4: Added trace */
uint64 
sys_sigreturn(void)
{
    8000308e:	1101                	addi	sp,sp,-32
    80003090:	ec06                	sd	ra,24(sp)
    80003092:	e822                	sd	s0,16(sp)
    80003094:	e426                	sd	s1,8(sp)
    80003096:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80003098:	fffff097          	auipc	ra,0xfffff
    8000309c:	92e080e7          	jalr	-1746(ra) # 800019c6 <myproc>
    800030a0:	84aa                	mv	s1,a0
  memmove(p->trapframe, p->alarm_tf, PGSIZE);
    800030a2:	6605                	lui	a2,0x1
    800030a4:	19053583          	ld	a1,400(a0)
    800030a8:	6d28                	ld	a0,88(a0)
    800030aa:	ffffe097          	auipc	ra,0xffffe
    800030ae:	c9c080e7          	jalr	-868(ra) # 80000d46 <memmove>
  //myproc()->trapframe->a0 = myproc()->a1;
  //myproc()->trapframe->a1 = myproc()->a2;
  kfree(p->alarm_tf);
    800030b2:	1904b503          	ld	a0,400(s1)
    800030b6:	ffffe097          	auipc	ra,0xffffe
    800030ba:	948080e7          	jalr	-1720(ra) # 800009fe <kfree>
  p->cur_ticks = 0;
    800030be:	1804a623          	sw	zero,396(s1)
  p->handlerpermission = 1;
    800030c2:	4785                	li	a5,1
    800030c4:	1af4a823          	sw	a5,432(s1)
  return myproc()->trapframe->a0;
    800030c8:	fffff097          	auipc	ra,0xfffff
    800030cc:	8fe080e7          	jalr	-1794(ra) # 800019c6 <myproc>
    800030d0:	6d3c                	ld	a5,88(a0)
}
    800030d2:	7ba8                	ld	a0,112(a5)
    800030d4:	60e2                	ld	ra,24(sp)
    800030d6:	6442                	ld	s0,16(sp)
    800030d8:	64a2                	ld	s1,8(sp)
    800030da:	6105                	addi	sp,sp,32
    800030dc:	8082                	ret

00000000800030de <sys_settickets>:

uint64 
sys_settickets(void)
{
    800030de:	7179                	addi	sp,sp,-48
    800030e0:	f406                	sd	ra,40(sp)
    800030e2:	f022                	sd	s0,32(sp)
    800030e4:	ec26                	sd	s1,24(sp)
    800030e6:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800030e8:	fffff097          	auipc	ra,0xfffff
    800030ec:	8de080e7          	jalr	-1826(ra) # 800019c6 <myproc>
    800030f0:	84aa                	mv	s1,a0
  int tickets;
  if(argint(0, &tickets) < 0)
    800030f2:	fdc40593          	addi	a1,s0,-36
    800030f6:	4501                	li	a0,0
    800030f8:	00000097          	auipc	ra,0x0
    800030fc:	d76080e7          	jalr	-650(ra) # 80002e6e <argint>
    80003100:	00054c63          	bltz	a0,80003118 <sys_settickets+0x3a>
    return -1;
  p->tickets = tickets;
    80003104:	fdc42783          	lw	a5,-36(s0)
    80003108:	1af4aa23          	sw	a5,436(s1)
  return 0; 
    8000310c:	4501                	li	a0,0
}
    8000310e:	70a2                	ld	ra,40(sp)
    80003110:	7402                	ld	s0,32(sp)
    80003112:	64e2                	ld	s1,24(sp)
    80003114:	6145                	addi	sp,sp,48
    80003116:	8082                	ret
    return -1;
    80003118:	557d                	li	a0,-1
    8000311a:	bfd5                	j	8000310e <sys_settickets+0x30>

000000008000311c <sys_setpriority>:

uint64
sys_setpriority()
{
    8000311c:	1101                	addi	sp,sp,-32
    8000311e:	ec06                	sd	ra,24(sp)
    80003120:	e822                	sd	s0,16(sp)
    80003122:	1000                	addi	s0,sp,32
  int pid, priority;
  int arg_num[2] = {0, 1};

  if(argint(arg_num[0], &priority) < 0)
    80003124:	fe840593          	addi	a1,s0,-24
    80003128:	4501                	li	a0,0
    8000312a:	00000097          	auipc	ra,0x0
    8000312e:	d44080e7          	jalr	-700(ra) # 80002e6e <argint>
  {
    return -1;
    80003132:	57fd                	li	a5,-1
  if(argint(arg_num[0], &priority) < 0)
    80003134:	02054563          	bltz	a0,8000315e <sys_setpriority+0x42>
  }
  if(argint(arg_num[1], &pid) < 0)
    80003138:	fec40593          	addi	a1,s0,-20
    8000313c:	4505                	li	a0,1
    8000313e:	00000097          	auipc	ra,0x0
    80003142:	d30080e7          	jalr	-720(ra) # 80002e6e <argint>
  {
    return -1;
    80003146:	57fd                	li	a5,-1
  if(argint(arg_num[1], &pid) < 0)
    80003148:	00054b63          	bltz	a0,8000315e <sys_setpriority+0x42>
  }
   
  return setpriority(priority, pid);
    8000314c:	fec42583          	lw	a1,-20(s0)
    80003150:	fe842503          	lw	a0,-24(s0)
    80003154:	fffff097          	auipc	ra,0xfffff
    80003158:	72e080e7          	jalr	1838(ra) # 80002882 <setpriority>
    8000315c:	87aa                	mv	a5,a0
}
    8000315e:	853e                	mv	a0,a5
    80003160:	60e2                	ld	ra,24(sp)
    80003162:	6442                	ld	s0,16(sp)
    80003164:	6105                	addi	sp,sp,32
    80003166:	8082                	ret

0000000080003168 <sys_exit>:


uint64
sys_exit(void)
{
    80003168:	1101                	addi	sp,sp,-32
    8000316a:	ec06                	sd	ra,24(sp)
    8000316c:	e822                	sd	s0,16(sp)
    8000316e:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80003170:	fec40593          	addi	a1,s0,-20
    80003174:	4501                	li	a0,0
    80003176:	00000097          	auipc	ra,0x0
    8000317a:	cf8080e7          	jalr	-776(ra) # 80002e6e <argint>
  exit(n);
    8000317e:	fec42503          	lw	a0,-20(s0)
    80003182:	fffff097          	auipc	ra,0xfffff
    80003186:	2c6080e7          	jalr	710(ra) # 80002448 <exit>
  return 0;  // not reached
}
    8000318a:	4501                	li	a0,0
    8000318c:	60e2                	ld	ra,24(sp)
    8000318e:	6442                	ld	s0,16(sp)
    80003190:	6105                	addi	sp,sp,32
    80003192:	8082                	ret

0000000080003194 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003194:	1141                	addi	sp,sp,-16
    80003196:	e406                	sd	ra,8(sp)
    80003198:	e022                	sd	s0,0(sp)
    8000319a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000319c:	fffff097          	auipc	ra,0xfffff
    800031a0:	82a080e7          	jalr	-2006(ra) # 800019c6 <myproc>
}
    800031a4:	5908                	lw	a0,48(a0)
    800031a6:	60a2                	ld	ra,8(sp)
    800031a8:	6402                	ld	s0,0(sp)
    800031aa:	0141                	addi	sp,sp,16
    800031ac:	8082                	ret

00000000800031ae <sys_fork>:

uint64
sys_fork(void)
{
    800031ae:	1141                	addi	sp,sp,-16
    800031b0:	e406                	sd	ra,8(sp)
    800031b2:	e022                	sd	s0,0(sp)
    800031b4:	0800                	addi	s0,sp,16
  return fork();
    800031b6:	fffff097          	auipc	ra,0xfffff
    800031ba:	c10080e7          	jalr	-1008(ra) # 80001dc6 <fork>
}
    800031be:	60a2                	ld	ra,8(sp)
    800031c0:	6402                	ld	s0,0(sp)
    800031c2:	0141                	addi	sp,sp,16
    800031c4:	8082                	ret

00000000800031c6 <sys_wait>:

uint64
sys_wait(void)
{
    800031c6:	1101                	addi	sp,sp,-32
    800031c8:	ec06                	sd	ra,24(sp)
    800031ca:	e822                	sd	s0,16(sp)
    800031cc:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800031ce:	fe840593          	addi	a1,s0,-24
    800031d2:	4501                	li	a0,0
    800031d4:	00000097          	auipc	ra,0x0
    800031d8:	cbc080e7          	jalr	-836(ra) # 80002e90 <argaddr>
  return wait(p);
    800031dc:	fe843503          	ld	a0,-24(s0)
    800031e0:	fffff097          	auipc	ra,0xfffff
    800031e4:	41a080e7          	jalr	1050(ra) # 800025fa <wait>
}
    800031e8:	60e2                	ld	ra,24(sp)
    800031ea:	6442                	ld	s0,16(sp)
    800031ec:	6105                	addi	sp,sp,32
    800031ee:	8082                	ret

00000000800031f0 <sys_waitx>:

uint64
sys_waitx(void)
{
    800031f0:	7139                	addi	sp,sp,-64
    800031f2:	fc06                	sd	ra,56(sp)
    800031f4:	f822                	sd	s0,48(sp)
    800031f6:	f426                	sd	s1,40(sp)
    800031f8:	f04a                	sd	s2,32(sp)
    800031fa:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    800031fc:	fd840593          	addi	a1,s0,-40
    80003200:	4501                	li	a0,0
    80003202:	00000097          	auipc	ra,0x0
    80003206:	c8e080e7          	jalr	-882(ra) # 80002e90 <argaddr>
  argaddr(1, &addr1); // user virtual memory
    8000320a:	fd040593          	addi	a1,s0,-48
    8000320e:	4505                	li	a0,1
    80003210:	00000097          	auipc	ra,0x0
    80003214:	c80080e7          	jalr	-896(ra) # 80002e90 <argaddr>
  argaddr(2, &addr2);
    80003218:	fc840593          	addi	a1,s0,-56
    8000321c:	4509                	li	a0,2
    8000321e:	00000097          	auipc	ra,0x0
    80003222:	c72080e7          	jalr	-910(ra) # 80002e90 <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    80003226:	fc040613          	addi	a2,s0,-64
    8000322a:	fc440593          	addi	a1,s0,-60
    8000322e:	fd843503          	ld	a0,-40(s0)
    80003232:	fffff097          	auipc	ra,0xfffff
    80003236:	ffa080e7          	jalr	-6(ra) # 8000222c <waitx>
    8000323a:	892a                	mv	s2,a0
  struct proc* p = myproc();
    8000323c:	ffffe097          	auipc	ra,0xffffe
    80003240:	78a080e7          	jalr	1930(ra) # 800019c6 <myproc>
    80003244:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    80003246:	4691                	li	a3,4
    80003248:	fc440613          	addi	a2,s0,-60
    8000324c:	fd043583          	ld	a1,-48(s0)
    80003250:	6928                	ld	a0,80(a0)
    80003252:	ffffe097          	auipc	ra,0xffffe
    80003256:	432080e7          	jalr	1074(ra) # 80001684 <copyout>
    return -1;
    8000325a:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    8000325c:	00054f63          	bltz	a0,8000327a <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2,(char*)&rtime, sizeof(int)) < 0)
    80003260:	4691                	li	a3,4
    80003262:	fc040613          	addi	a2,s0,-64
    80003266:	fc843583          	ld	a1,-56(s0)
    8000326a:	68a8                	ld	a0,80(s1)
    8000326c:	ffffe097          	auipc	ra,0xffffe
    80003270:	418080e7          	jalr	1048(ra) # 80001684 <copyout>
    80003274:	00054a63          	bltz	a0,80003288 <sys_waitx+0x98>
    return -1;
  return ret;
    80003278:	87ca                	mv	a5,s2
}
    8000327a:	853e                	mv	a0,a5
    8000327c:	70e2                	ld	ra,56(sp)
    8000327e:	7442                	ld	s0,48(sp)
    80003280:	74a2                	ld	s1,40(sp)
    80003282:	7902                	ld	s2,32(sp)
    80003284:	6121                	addi	sp,sp,64
    80003286:	8082                	ret
    return -1;
    80003288:	57fd                	li	a5,-1
    8000328a:	bfc5                	j	8000327a <sys_waitx+0x8a>

000000008000328c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000328c:	7179                	addi	sp,sp,-48
    8000328e:	f406                	sd	ra,40(sp)
    80003290:	f022                	sd	s0,32(sp)
    80003292:	ec26                	sd	s1,24(sp)
    80003294:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80003296:	fdc40593          	addi	a1,s0,-36
    8000329a:	4501                	li	a0,0
    8000329c:	00000097          	auipc	ra,0x0
    800032a0:	bd2080e7          	jalr	-1070(ra) # 80002e6e <argint>
  addr = myproc()->sz;
    800032a4:	ffffe097          	auipc	ra,0xffffe
    800032a8:	722080e7          	jalr	1826(ra) # 800019c6 <myproc>
    800032ac:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    800032ae:	fdc42503          	lw	a0,-36(s0)
    800032b2:	fffff097          	auipc	ra,0xfffff
    800032b6:	ab8080e7          	jalr	-1352(ra) # 80001d6a <growproc>
    800032ba:	00054863          	bltz	a0,800032ca <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    800032be:	8526                	mv	a0,s1
    800032c0:	70a2                	ld	ra,40(sp)
    800032c2:	7402                	ld	s0,32(sp)
    800032c4:	64e2                	ld	s1,24(sp)
    800032c6:	6145                	addi	sp,sp,48
    800032c8:	8082                	ret
    return -1;
    800032ca:	54fd                	li	s1,-1
    800032cc:	bfcd                	j	800032be <sys_sbrk+0x32>

00000000800032ce <sys_sleep>:

uint64
sys_sleep(void)
{
    800032ce:	7139                	addi	sp,sp,-64
    800032d0:	fc06                	sd	ra,56(sp)
    800032d2:	f822                	sd	s0,48(sp)
    800032d4:	f426                	sd	s1,40(sp)
    800032d6:	f04a                	sd	s2,32(sp)
    800032d8:	ec4e                	sd	s3,24(sp)
    800032da:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800032dc:	fcc40593          	addi	a1,s0,-52
    800032e0:	4501                	li	a0,0
    800032e2:	00000097          	auipc	ra,0x0
    800032e6:	b8c080e7          	jalr	-1140(ra) # 80002e6e <argint>
  acquire(&tickslock);
    800032ea:	00015517          	auipc	a0,0x15
    800032ee:	71650513          	addi	a0,a0,1814 # 80018a00 <tickslock>
    800032f2:	ffffe097          	auipc	ra,0xffffe
    800032f6:	8f8080e7          	jalr	-1800(ra) # 80000bea <acquire>
  ticks0 = ticks;
    800032fa:	00006917          	auipc	s2,0x6
    800032fe:	86692903          	lw	s2,-1946(s2) # 80008b60 <ticks>
  while(ticks - ticks0 < n){
    80003302:	fcc42783          	lw	a5,-52(s0)
    80003306:	cf9d                	beqz	a5,80003344 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003308:	00015997          	auipc	s3,0x15
    8000330c:	6f898993          	addi	s3,s3,1784 # 80018a00 <tickslock>
    80003310:	00006497          	auipc	s1,0x6
    80003314:	85048493          	addi	s1,s1,-1968 # 80008b60 <ticks>
    if(killed(myproc())){
    80003318:	ffffe097          	auipc	ra,0xffffe
    8000331c:	6ae080e7          	jalr	1710(ra) # 800019c6 <myproc>
    80003320:	fffff097          	auipc	ra,0xfffff
    80003324:	2a8080e7          	jalr	680(ra) # 800025c8 <killed>
    80003328:	ed15                	bnez	a0,80003364 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    8000332a:	85ce                	mv	a1,s3
    8000332c:	8526                	mv	a0,s1
    8000332e:	fffff097          	auipc	ra,0xfffff
    80003332:	e9a080e7          	jalr	-358(ra) # 800021c8 <sleep>
  while(ticks - ticks0 < n){
    80003336:	409c                	lw	a5,0(s1)
    80003338:	412787bb          	subw	a5,a5,s2
    8000333c:	fcc42703          	lw	a4,-52(s0)
    80003340:	fce7ece3          	bltu	a5,a4,80003318 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80003344:	00015517          	auipc	a0,0x15
    80003348:	6bc50513          	addi	a0,a0,1724 # 80018a00 <tickslock>
    8000334c:	ffffe097          	auipc	ra,0xffffe
    80003350:	952080e7          	jalr	-1710(ra) # 80000c9e <release>
  return 0;
    80003354:	4501                	li	a0,0
}
    80003356:	70e2                	ld	ra,56(sp)
    80003358:	7442                	ld	s0,48(sp)
    8000335a:	74a2                	ld	s1,40(sp)
    8000335c:	7902                	ld	s2,32(sp)
    8000335e:	69e2                	ld	s3,24(sp)
    80003360:	6121                	addi	sp,sp,64
    80003362:	8082                	ret
      release(&tickslock);
    80003364:	00015517          	auipc	a0,0x15
    80003368:	69c50513          	addi	a0,a0,1692 # 80018a00 <tickslock>
    8000336c:	ffffe097          	auipc	ra,0xffffe
    80003370:	932080e7          	jalr	-1742(ra) # 80000c9e <release>
      return -1;
    80003374:	557d                	li	a0,-1
    80003376:	b7c5                	j	80003356 <sys_sleep+0x88>

0000000080003378 <sys_kill>:

uint64
sys_kill(void)
{
    80003378:	1101                	addi	sp,sp,-32
    8000337a:	ec06                	sd	ra,24(sp)
    8000337c:	e822                	sd	s0,16(sp)
    8000337e:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003380:	fec40593          	addi	a1,s0,-20
    80003384:	4501                	li	a0,0
    80003386:	00000097          	auipc	ra,0x0
    8000338a:	ae8080e7          	jalr	-1304(ra) # 80002e6e <argint>
  return kill(pid);
    8000338e:	fec42503          	lw	a0,-20(s0)
    80003392:	fffff097          	auipc	ra,0xfffff
    80003396:	198080e7          	jalr	408(ra) # 8000252a <kill>
}
    8000339a:	60e2                	ld	ra,24(sp)
    8000339c:	6442                	ld	s0,16(sp)
    8000339e:	6105                	addi	sp,sp,32
    800033a0:	8082                	ret

00000000800033a2 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800033a2:	1101                	addi	sp,sp,-32
    800033a4:	ec06                	sd	ra,24(sp)
    800033a6:	e822                	sd	s0,16(sp)
    800033a8:	e426                	sd	s1,8(sp)
    800033aa:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800033ac:	00015517          	auipc	a0,0x15
    800033b0:	65450513          	addi	a0,a0,1620 # 80018a00 <tickslock>
    800033b4:	ffffe097          	auipc	ra,0xffffe
    800033b8:	836080e7          	jalr	-1994(ra) # 80000bea <acquire>
  xticks = ticks;
    800033bc:	00005497          	auipc	s1,0x5
    800033c0:	7a44a483          	lw	s1,1956(s1) # 80008b60 <ticks>
  release(&tickslock);
    800033c4:	00015517          	auipc	a0,0x15
    800033c8:	63c50513          	addi	a0,a0,1596 # 80018a00 <tickslock>
    800033cc:	ffffe097          	auipc	ra,0xffffe
    800033d0:	8d2080e7          	jalr	-1838(ra) # 80000c9e <release>
  return xticks;
}
    800033d4:	02049513          	slli	a0,s1,0x20
    800033d8:	9101                	srli	a0,a0,0x20
    800033da:	60e2                	ld	ra,24(sp)
    800033dc:	6442                	ld	s0,16(sp)
    800033de:	64a2                	ld	s1,8(sp)
    800033e0:	6105                	addi	sp,sp,32
    800033e2:	8082                	ret

00000000800033e4 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800033e4:	7179                	addi	sp,sp,-48
    800033e6:	f406                	sd	ra,40(sp)
    800033e8:	f022                	sd	s0,32(sp)
    800033ea:	ec26                	sd	s1,24(sp)
    800033ec:	e84a                	sd	s2,16(sp)
    800033ee:	e44e                	sd	s3,8(sp)
    800033f0:	e052                	sd	s4,0(sp)
    800033f2:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800033f4:	00005597          	auipc	a1,0x5
    800033f8:	2cc58593          	addi	a1,a1,716 # 800086c0 <syscallnum+0x70>
    800033fc:	00015517          	auipc	a0,0x15
    80003400:	61c50513          	addi	a0,a0,1564 # 80018a18 <bcache>
    80003404:	ffffd097          	auipc	ra,0xffffd
    80003408:	756080e7          	jalr	1878(ra) # 80000b5a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000340c:	0001d797          	auipc	a5,0x1d
    80003410:	60c78793          	addi	a5,a5,1548 # 80020a18 <bcache+0x8000>
    80003414:	0001e717          	auipc	a4,0x1e
    80003418:	86c70713          	addi	a4,a4,-1940 # 80020c80 <bcache+0x8268>
    8000341c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003420:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003424:	00015497          	auipc	s1,0x15
    80003428:	60c48493          	addi	s1,s1,1548 # 80018a30 <bcache+0x18>
    b->next = bcache.head.next;
    8000342c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000342e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003430:	00005a17          	auipc	s4,0x5
    80003434:	298a0a13          	addi	s4,s4,664 # 800086c8 <syscallnum+0x78>
    b->next = bcache.head.next;
    80003438:	2b893783          	ld	a5,696(s2)
    8000343c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000343e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003442:	85d2                	mv	a1,s4
    80003444:	01048513          	addi	a0,s1,16
    80003448:	00001097          	auipc	ra,0x1
    8000344c:	4c4080e7          	jalr	1220(ra) # 8000490c <initsleeplock>
    bcache.head.next->prev = b;
    80003450:	2b893783          	ld	a5,696(s2)
    80003454:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003456:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000345a:	45848493          	addi	s1,s1,1112
    8000345e:	fd349de3          	bne	s1,s3,80003438 <binit+0x54>
  }
}
    80003462:	70a2                	ld	ra,40(sp)
    80003464:	7402                	ld	s0,32(sp)
    80003466:	64e2                	ld	s1,24(sp)
    80003468:	6942                	ld	s2,16(sp)
    8000346a:	69a2                	ld	s3,8(sp)
    8000346c:	6a02                	ld	s4,0(sp)
    8000346e:	6145                	addi	sp,sp,48
    80003470:	8082                	ret

0000000080003472 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003472:	7179                	addi	sp,sp,-48
    80003474:	f406                	sd	ra,40(sp)
    80003476:	f022                	sd	s0,32(sp)
    80003478:	ec26                	sd	s1,24(sp)
    8000347a:	e84a                	sd	s2,16(sp)
    8000347c:	e44e                	sd	s3,8(sp)
    8000347e:	1800                	addi	s0,sp,48
    80003480:	89aa                	mv	s3,a0
    80003482:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80003484:	00015517          	auipc	a0,0x15
    80003488:	59450513          	addi	a0,a0,1428 # 80018a18 <bcache>
    8000348c:	ffffd097          	auipc	ra,0xffffd
    80003490:	75e080e7          	jalr	1886(ra) # 80000bea <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003494:	0001e497          	auipc	s1,0x1e
    80003498:	83c4b483          	ld	s1,-1988(s1) # 80020cd0 <bcache+0x82b8>
    8000349c:	0001d797          	auipc	a5,0x1d
    800034a0:	7e478793          	addi	a5,a5,2020 # 80020c80 <bcache+0x8268>
    800034a4:	02f48f63          	beq	s1,a5,800034e2 <bread+0x70>
    800034a8:	873e                	mv	a4,a5
    800034aa:	a021                	j	800034b2 <bread+0x40>
    800034ac:	68a4                	ld	s1,80(s1)
    800034ae:	02e48a63          	beq	s1,a4,800034e2 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800034b2:	449c                	lw	a5,8(s1)
    800034b4:	ff379ce3          	bne	a5,s3,800034ac <bread+0x3a>
    800034b8:	44dc                	lw	a5,12(s1)
    800034ba:	ff2799e3          	bne	a5,s2,800034ac <bread+0x3a>
      b->refcnt++;
    800034be:	40bc                	lw	a5,64(s1)
    800034c0:	2785                	addiw	a5,a5,1
    800034c2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800034c4:	00015517          	auipc	a0,0x15
    800034c8:	55450513          	addi	a0,a0,1364 # 80018a18 <bcache>
    800034cc:	ffffd097          	auipc	ra,0xffffd
    800034d0:	7d2080e7          	jalr	2002(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    800034d4:	01048513          	addi	a0,s1,16
    800034d8:	00001097          	auipc	ra,0x1
    800034dc:	46e080e7          	jalr	1134(ra) # 80004946 <acquiresleep>
      return b;
    800034e0:	a8b9                	j	8000353e <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800034e2:	0001d497          	auipc	s1,0x1d
    800034e6:	7e64b483          	ld	s1,2022(s1) # 80020cc8 <bcache+0x82b0>
    800034ea:	0001d797          	auipc	a5,0x1d
    800034ee:	79678793          	addi	a5,a5,1942 # 80020c80 <bcache+0x8268>
    800034f2:	00f48863          	beq	s1,a5,80003502 <bread+0x90>
    800034f6:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800034f8:	40bc                	lw	a5,64(s1)
    800034fa:	cf81                	beqz	a5,80003512 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800034fc:	64a4                	ld	s1,72(s1)
    800034fe:	fee49de3          	bne	s1,a4,800034f8 <bread+0x86>
  panic("bget: no buffers");
    80003502:	00005517          	auipc	a0,0x5
    80003506:	1ce50513          	addi	a0,a0,462 # 800086d0 <syscallnum+0x80>
    8000350a:	ffffd097          	auipc	ra,0xffffd
    8000350e:	03a080e7          	jalr	58(ra) # 80000544 <panic>
      b->dev = dev;
    80003512:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80003516:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    8000351a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000351e:	4785                	li	a5,1
    80003520:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003522:	00015517          	auipc	a0,0x15
    80003526:	4f650513          	addi	a0,a0,1270 # 80018a18 <bcache>
    8000352a:	ffffd097          	auipc	ra,0xffffd
    8000352e:	774080e7          	jalr	1908(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    80003532:	01048513          	addi	a0,s1,16
    80003536:	00001097          	auipc	ra,0x1
    8000353a:	410080e7          	jalr	1040(ra) # 80004946 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000353e:	409c                	lw	a5,0(s1)
    80003540:	cb89                	beqz	a5,80003552 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003542:	8526                	mv	a0,s1
    80003544:	70a2                	ld	ra,40(sp)
    80003546:	7402                	ld	s0,32(sp)
    80003548:	64e2                	ld	s1,24(sp)
    8000354a:	6942                	ld	s2,16(sp)
    8000354c:	69a2                	ld	s3,8(sp)
    8000354e:	6145                	addi	sp,sp,48
    80003550:	8082                	ret
    virtio_disk_rw(b, 0);
    80003552:	4581                	li	a1,0
    80003554:	8526                	mv	a0,s1
    80003556:	00003097          	auipc	ra,0x3
    8000355a:	fd2080e7          	jalr	-46(ra) # 80006528 <virtio_disk_rw>
    b->valid = 1;
    8000355e:	4785                	li	a5,1
    80003560:	c09c                	sw	a5,0(s1)
  return b;
    80003562:	b7c5                	j	80003542 <bread+0xd0>

0000000080003564 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003564:	1101                	addi	sp,sp,-32
    80003566:	ec06                	sd	ra,24(sp)
    80003568:	e822                	sd	s0,16(sp)
    8000356a:	e426                	sd	s1,8(sp)
    8000356c:	1000                	addi	s0,sp,32
    8000356e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003570:	0541                	addi	a0,a0,16
    80003572:	00001097          	auipc	ra,0x1
    80003576:	46e080e7          	jalr	1134(ra) # 800049e0 <holdingsleep>
    8000357a:	cd01                	beqz	a0,80003592 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000357c:	4585                	li	a1,1
    8000357e:	8526                	mv	a0,s1
    80003580:	00003097          	auipc	ra,0x3
    80003584:	fa8080e7          	jalr	-88(ra) # 80006528 <virtio_disk_rw>
}
    80003588:	60e2                	ld	ra,24(sp)
    8000358a:	6442                	ld	s0,16(sp)
    8000358c:	64a2                	ld	s1,8(sp)
    8000358e:	6105                	addi	sp,sp,32
    80003590:	8082                	ret
    panic("bwrite");
    80003592:	00005517          	auipc	a0,0x5
    80003596:	15650513          	addi	a0,a0,342 # 800086e8 <syscallnum+0x98>
    8000359a:	ffffd097          	auipc	ra,0xffffd
    8000359e:	faa080e7          	jalr	-86(ra) # 80000544 <panic>

00000000800035a2 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800035a2:	1101                	addi	sp,sp,-32
    800035a4:	ec06                	sd	ra,24(sp)
    800035a6:	e822                	sd	s0,16(sp)
    800035a8:	e426                	sd	s1,8(sp)
    800035aa:	e04a                	sd	s2,0(sp)
    800035ac:	1000                	addi	s0,sp,32
    800035ae:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800035b0:	01050913          	addi	s2,a0,16
    800035b4:	854a                	mv	a0,s2
    800035b6:	00001097          	auipc	ra,0x1
    800035ba:	42a080e7          	jalr	1066(ra) # 800049e0 <holdingsleep>
    800035be:	c92d                	beqz	a0,80003630 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800035c0:	854a                	mv	a0,s2
    800035c2:	00001097          	auipc	ra,0x1
    800035c6:	3da080e7          	jalr	986(ra) # 8000499c <releasesleep>

  acquire(&bcache.lock);
    800035ca:	00015517          	auipc	a0,0x15
    800035ce:	44e50513          	addi	a0,a0,1102 # 80018a18 <bcache>
    800035d2:	ffffd097          	auipc	ra,0xffffd
    800035d6:	618080e7          	jalr	1560(ra) # 80000bea <acquire>
  b->refcnt--;
    800035da:	40bc                	lw	a5,64(s1)
    800035dc:	37fd                	addiw	a5,a5,-1
    800035de:	0007871b          	sext.w	a4,a5
    800035e2:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800035e4:	eb05                	bnez	a4,80003614 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800035e6:	68bc                	ld	a5,80(s1)
    800035e8:	64b8                	ld	a4,72(s1)
    800035ea:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800035ec:	64bc                	ld	a5,72(s1)
    800035ee:	68b8                	ld	a4,80(s1)
    800035f0:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800035f2:	0001d797          	auipc	a5,0x1d
    800035f6:	42678793          	addi	a5,a5,1062 # 80020a18 <bcache+0x8000>
    800035fa:	2b87b703          	ld	a4,696(a5)
    800035fe:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003600:	0001d717          	auipc	a4,0x1d
    80003604:	68070713          	addi	a4,a4,1664 # 80020c80 <bcache+0x8268>
    80003608:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000360a:	2b87b703          	ld	a4,696(a5)
    8000360e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003610:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003614:	00015517          	auipc	a0,0x15
    80003618:	40450513          	addi	a0,a0,1028 # 80018a18 <bcache>
    8000361c:	ffffd097          	auipc	ra,0xffffd
    80003620:	682080e7          	jalr	1666(ra) # 80000c9e <release>
}
    80003624:	60e2                	ld	ra,24(sp)
    80003626:	6442                	ld	s0,16(sp)
    80003628:	64a2                	ld	s1,8(sp)
    8000362a:	6902                	ld	s2,0(sp)
    8000362c:	6105                	addi	sp,sp,32
    8000362e:	8082                	ret
    panic("brelse");
    80003630:	00005517          	auipc	a0,0x5
    80003634:	0c050513          	addi	a0,a0,192 # 800086f0 <syscallnum+0xa0>
    80003638:	ffffd097          	auipc	ra,0xffffd
    8000363c:	f0c080e7          	jalr	-244(ra) # 80000544 <panic>

0000000080003640 <bpin>:

void
bpin(struct buf *b) {
    80003640:	1101                	addi	sp,sp,-32
    80003642:	ec06                	sd	ra,24(sp)
    80003644:	e822                	sd	s0,16(sp)
    80003646:	e426                	sd	s1,8(sp)
    80003648:	1000                	addi	s0,sp,32
    8000364a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000364c:	00015517          	auipc	a0,0x15
    80003650:	3cc50513          	addi	a0,a0,972 # 80018a18 <bcache>
    80003654:	ffffd097          	auipc	ra,0xffffd
    80003658:	596080e7          	jalr	1430(ra) # 80000bea <acquire>
  b->refcnt++;
    8000365c:	40bc                	lw	a5,64(s1)
    8000365e:	2785                	addiw	a5,a5,1
    80003660:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003662:	00015517          	auipc	a0,0x15
    80003666:	3b650513          	addi	a0,a0,950 # 80018a18 <bcache>
    8000366a:	ffffd097          	auipc	ra,0xffffd
    8000366e:	634080e7          	jalr	1588(ra) # 80000c9e <release>
}
    80003672:	60e2                	ld	ra,24(sp)
    80003674:	6442                	ld	s0,16(sp)
    80003676:	64a2                	ld	s1,8(sp)
    80003678:	6105                	addi	sp,sp,32
    8000367a:	8082                	ret

000000008000367c <bunpin>:

void
bunpin(struct buf *b) {
    8000367c:	1101                	addi	sp,sp,-32
    8000367e:	ec06                	sd	ra,24(sp)
    80003680:	e822                	sd	s0,16(sp)
    80003682:	e426                	sd	s1,8(sp)
    80003684:	1000                	addi	s0,sp,32
    80003686:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003688:	00015517          	auipc	a0,0x15
    8000368c:	39050513          	addi	a0,a0,912 # 80018a18 <bcache>
    80003690:	ffffd097          	auipc	ra,0xffffd
    80003694:	55a080e7          	jalr	1370(ra) # 80000bea <acquire>
  b->refcnt--;
    80003698:	40bc                	lw	a5,64(s1)
    8000369a:	37fd                	addiw	a5,a5,-1
    8000369c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000369e:	00015517          	auipc	a0,0x15
    800036a2:	37a50513          	addi	a0,a0,890 # 80018a18 <bcache>
    800036a6:	ffffd097          	auipc	ra,0xffffd
    800036aa:	5f8080e7          	jalr	1528(ra) # 80000c9e <release>
}
    800036ae:	60e2                	ld	ra,24(sp)
    800036b0:	6442                	ld	s0,16(sp)
    800036b2:	64a2                	ld	s1,8(sp)
    800036b4:	6105                	addi	sp,sp,32
    800036b6:	8082                	ret

00000000800036b8 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800036b8:	1101                	addi	sp,sp,-32
    800036ba:	ec06                	sd	ra,24(sp)
    800036bc:	e822                	sd	s0,16(sp)
    800036be:	e426                	sd	s1,8(sp)
    800036c0:	e04a                	sd	s2,0(sp)
    800036c2:	1000                	addi	s0,sp,32
    800036c4:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800036c6:	00d5d59b          	srliw	a1,a1,0xd
    800036ca:	0001e797          	auipc	a5,0x1e
    800036ce:	a2a7a783          	lw	a5,-1494(a5) # 800210f4 <sb+0x1c>
    800036d2:	9dbd                	addw	a1,a1,a5
    800036d4:	00000097          	auipc	ra,0x0
    800036d8:	d9e080e7          	jalr	-610(ra) # 80003472 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800036dc:	0074f713          	andi	a4,s1,7
    800036e0:	4785                	li	a5,1
    800036e2:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800036e6:	14ce                	slli	s1,s1,0x33
    800036e8:	90d9                	srli	s1,s1,0x36
    800036ea:	00950733          	add	a4,a0,s1
    800036ee:	05874703          	lbu	a4,88(a4)
    800036f2:	00e7f6b3          	and	a3,a5,a4
    800036f6:	c69d                	beqz	a3,80003724 <bfree+0x6c>
    800036f8:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800036fa:	94aa                	add	s1,s1,a0
    800036fc:	fff7c793          	not	a5,a5
    80003700:	8ff9                	and	a5,a5,a4
    80003702:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003706:	00001097          	auipc	ra,0x1
    8000370a:	120080e7          	jalr	288(ra) # 80004826 <log_write>
  brelse(bp);
    8000370e:	854a                	mv	a0,s2
    80003710:	00000097          	auipc	ra,0x0
    80003714:	e92080e7          	jalr	-366(ra) # 800035a2 <brelse>
}
    80003718:	60e2                	ld	ra,24(sp)
    8000371a:	6442                	ld	s0,16(sp)
    8000371c:	64a2                	ld	s1,8(sp)
    8000371e:	6902                	ld	s2,0(sp)
    80003720:	6105                	addi	sp,sp,32
    80003722:	8082                	ret
    panic("freeing free block");
    80003724:	00005517          	auipc	a0,0x5
    80003728:	fd450513          	addi	a0,a0,-44 # 800086f8 <syscallnum+0xa8>
    8000372c:	ffffd097          	auipc	ra,0xffffd
    80003730:	e18080e7          	jalr	-488(ra) # 80000544 <panic>

0000000080003734 <balloc>:
{
    80003734:	711d                	addi	sp,sp,-96
    80003736:	ec86                	sd	ra,88(sp)
    80003738:	e8a2                	sd	s0,80(sp)
    8000373a:	e4a6                	sd	s1,72(sp)
    8000373c:	e0ca                	sd	s2,64(sp)
    8000373e:	fc4e                	sd	s3,56(sp)
    80003740:	f852                	sd	s4,48(sp)
    80003742:	f456                	sd	s5,40(sp)
    80003744:	f05a                	sd	s6,32(sp)
    80003746:	ec5e                	sd	s7,24(sp)
    80003748:	e862                	sd	s8,16(sp)
    8000374a:	e466                	sd	s9,8(sp)
    8000374c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000374e:	0001e797          	auipc	a5,0x1e
    80003752:	98e7a783          	lw	a5,-1650(a5) # 800210dc <sb+0x4>
    80003756:	10078163          	beqz	a5,80003858 <balloc+0x124>
    8000375a:	8baa                	mv	s7,a0
    8000375c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000375e:	0001eb17          	auipc	s6,0x1e
    80003762:	97ab0b13          	addi	s6,s6,-1670 # 800210d8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003766:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003768:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000376a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000376c:	6c89                	lui	s9,0x2
    8000376e:	a061                	j	800037f6 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003770:	974a                	add	a4,a4,s2
    80003772:	8fd5                	or	a5,a5,a3
    80003774:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003778:	854a                	mv	a0,s2
    8000377a:	00001097          	auipc	ra,0x1
    8000377e:	0ac080e7          	jalr	172(ra) # 80004826 <log_write>
        brelse(bp);
    80003782:	854a                	mv	a0,s2
    80003784:	00000097          	auipc	ra,0x0
    80003788:	e1e080e7          	jalr	-482(ra) # 800035a2 <brelse>
  bp = bread(dev, bno);
    8000378c:	85a6                	mv	a1,s1
    8000378e:	855e                	mv	a0,s7
    80003790:	00000097          	auipc	ra,0x0
    80003794:	ce2080e7          	jalr	-798(ra) # 80003472 <bread>
    80003798:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000379a:	40000613          	li	a2,1024
    8000379e:	4581                	li	a1,0
    800037a0:	05850513          	addi	a0,a0,88
    800037a4:	ffffd097          	auipc	ra,0xffffd
    800037a8:	542080e7          	jalr	1346(ra) # 80000ce6 <memset>
  log_write(bp);
    800037ac:	854a                	mv	a0,s2
    800037ae:	00001097          	auipc	ra,0x1
    800037b2:	078080e7          	jalr	120(ra) # 80004826 <log_write>
  brelse(bp);
    800037b6:	854a                	mv	a0,s2
    800037b8:	00000097          	auipc	ra,0x0
    800037bc:	dea080e7          	jalr	-534(ra) # 800035a2 <brelse>
}
    800037c0:	8526                	mv	a0,s1
    800037c2:	60e6                	ld	ra,88(sp)
    800037c4:	6446                	ld	s0,80(sp)
    800037c6:	64a6                	ld	s1,72(sp)
    800037c8:	6906                	ld	s2,64(sp)
    800037ca:	79e2                	ld	s3,56(sp)
    800037cc:	7a42                	ld	s4,48(sp)
    800037ce:	7aa2                	ld	s5,40(sp)
    800037d0:	7b02                	ld	s6,32(sp)
    800037d2:	6be2                	ld	s7,24(sp)
    800037d4:	6c42                	ld	s8,16(sp)
    800037d6:	6ca2                	ld	s9,8(sp)
    800037d8:	6125                	addi	sp,sp,96
    800037da:	8082                	ret
    brelse(bp);
    800037dc:	854a                	mv	a0,s2
    800037de:	00000097          	auipc	ra,0x0
    800037e2:	dc4080e7          	jalr	-572(ra) # 800035a2 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800037e6:	015c87bb          	addw	a5,s9,s5
    800037ea:	00078a9b          	sext.w	s5,a5
    800037ee:	004b2703          	lw	a4,4(s6)
    800037f2:	06eaf363          	bgeu	s5,a4,80003858 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    800037f6:	41fad79b          	sraiw	a5,s5,0x1f
    800037fa:	0137d79b          	srliw	a5,a5,0x13
    800037fe:	015787bb          	addw	a5,a5,s5
    80003802:	40d7d79b          	sraiw	a5,a5,0xd
    80003806:	01cb2583          	lw	a1,28(s6)
    8000380a:	9dbd                	addw	a1,a1,a5
    8000380c:	855e                	mv	a0,s7
    8000380e:	00000097          	auipc	ra,0x0
    80003812:	c64080e7          	jalr	-924(ra) # 80003472 <bread>
    80003816:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003818:	004b2503          	lw	a0,4(s6)
    8000381c:	000a849b          	sext.w	s1,s5
    80003820:	8662                	mv	a2,s8
    80003822:	faa4fde3          	bgeu	s1,a0,800037dc <balloc+0xa8>
      m = 1 << (bi % 8);
    80003826:	41f6579b          	sraiw	a5,a2,0x1f
    8000382a:	01d7d69b          	srliw	a3,a5,0x1d
    8000382e:	00c6873b          	addw	a4,a3,a2
    80003832:	00777793          	andi	a5,a4,7
    80003836:	9f95                	subw	a5,a5,a3
    80003838:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000383c:	4037571b          	sraiw	a4,a4,0x3
    80003840:	00e906b3          	add	a3,s2,a4
    80003844:	0586c683          	lbu	a3,88(a3)
    80003848:	00d7f5b3          	and	a1,a5,a3
    8000384c:	d195                	beqz	a1,80003770 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000384e:	2605                	addiw	a2,a2,1
    80003850:	2485                	addiw	s1,s1,1
    80003852:	fd4618e3          	bne	a2,s4,80003822 <balloc+0xee>
    80003856:	b759                	j	800037dc <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003858:	00005517          	auipc	a0,0x5
    8000385c:	eb850513          	addi	a0,a0,-328 # 80008710 <syscallnum+0xc0>
    80003860:	ffffd097          	auipc	ra,0xffffd
    80003864:	d2e080e7          	jalr	-722(ra) # 8000058e <printf>
  return 0;
    80003868:	4481                	li	s1,0
    8000386a:	bf99                	j	800037c0 <balloc+0x8c>

000000008000386c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000386c:	7179                	addi	sp,sp,-48
    8000386e:	f406                	sd	ra,40(sp)
    80003870:	f022                	sd	s0,32(sp)
    80003872:	ec26                	sd	s1,24(sp)
    80003874:	e84a                	sd	s2,16(sp)
    80003876:	e44e                	sd	s3,8(sp)
    80003878:	e052                	sd	s4,0(sp)
    8000387a:	1800                	addi	s0,sp,48
    8000387c:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000387e:	47ad                	li	a5,11
    80003880:	02b7e763          	bltu	a5,a1,800038ae <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003884:	02059493          	slli	s1,a1,0x20
    80003888:	9081                	srli	s1,s1,0x20
    8000388a:	048a                	slli	s1,s1,0x2
    8000388c:	94aa                	add	s1,s1,a0
    8000388e:	0504a903          	lw	s2,80(s1)
    80003892:	06091e63          	bnez	s2,8000390e <bmap+0xa2>
      addr = balloc(ip->dev);
    80003896:	4108                	lw	a0,0(a0)
    80003898:	00000097          	auipc	ra,0x0
    8000389c:	e9c080e7          	jalr	-356(ra) # 80003734 <balloc>
    800038a0:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800038a4:	06090563          	beqz	s2,8000390e <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    800038a8:	0524a823          	sw	s2,80(s1)
    800038ac:	a08d                	j	8000390e <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    800038ae:	ff45849b          	addiw	s1,a1,-12
    800038b2:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800038b6:	0ff00793          	li	a5,255
    800038ba:	08e7e563          	bltu	a5,a4,80003944 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800038be:	08052903          	lw	s2,128(a0)
    800038c2:	00091d63          	bnez	s2,800038dc <bmap+0x70>
      addr = balloc(ip->dev);
    800038c6:	4108                	lw	a0,0(a0)
    800038c8:	00000097          	auipc	ra,0x0
    800038cc:	e6c080e7          	jalr	-404(ra) # 80003734 <balloc>
    800038d0:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800038d4:	02090d63          	beqz	s2,8000390e <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800038d8:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800038dc:	85ca                	mv	a1,s2
    800038de:	0009a503          	lw	a0,0(s3)
    800038e2:	00000097          	auipc	ra,0x0
    800038e6:	b90080e7          	jalr	-1136(ra) # 80003472 <bread>
    800038ea:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800038ec:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800038f0:	02049593          	slli	a1,s1,0x20
    800038f4:	9181                	srli	a1,a1,0x20
    800038f6:	058a                	slli	a1,a1,0x2
    800038f8:	00b784b3          	add	s1,a5,a1
    800038fc:	0004a903          	lw	s2,0(s1)
    80003900:	02090063          	beqz	s2,80003920 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003904:	8552                	mv	a0,s4
    80003906:	00000097          	auipc	ra,0x0
    8000390a:	c9c080e7          	jalr	-868(ra) # 800035a2 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000390e:	854a                	mv	a0,s2
    80003910:	70a2                	ld	ra,40(sp)
    80003912:	7402                	ld	s0,32(sp)
    80003914:	64e2                	ld	s1,24(sp)
    80003916:	6942                	ld	s2,16(sp)
    80003918:	69a2                	ld	s3,8(sp)
    8000391a:	6a02                	ld	s4,0(sp)
    8000391c:	6145                	addi	sp,sp,48
    8000391e:	8082                	ret
      addr = balloc(ip->dev);
    80003920:	0009a503          	lw	a0,0(s3)
    80003924:	00000097          	auipc	ra,0x0
    80003928:	e10080e7          	jalr	-496(ra) # 80003734 <balloc>
    8000392c:	0005091b          	sext.w	s2,a0
      if(addr){
    80003930:	fc090ae3          	beqz	s2,80003904 <bmap+0x98>
        a[bn] = addr;
    80003934:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003938:	8552                	mv	a0,s4
    8000393a:	00001097          	auipc	ra,0x1
    8000393e:	eec080e7          	jalr	-276(ra) # 80004826 <log_write>
    80003942:	b7c9                	j	80003904 <bmap+0x98>
  panic("bmap: out of range");
    80003944:	00005517          	auipc	a0,0x5
    80003948:	de450513          	addi	a0,a0,-540 # 80008728 <syscallnum+0xd8>
    8000394c:	ffffd097          	auipc	ra,0xffffd
    80003950:	bf8080e7          	jalr	-1032(ra) # 80000544 <panic>

0000000080003954 <iget>:
{
    80003954:	7179                	addi	sp,sp,-48
    80003956:	f406                	sd	ra,40(sp)
    80003958:	f022                	sd	s0,32(sp)
    8000395a:	ec26                	sd	s1,24(sp)
    8000395c:	e84a                	sd	s2,16(sp)
    8000395e:	e44e                	sd	s3,8(sp)
    80003960:	e052                	sd	s4,0(sp)
    80003962:	1800                	addi	s0,sp,48
    80003964:	89aa                	mv	s3,a0
    80003966:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003968:	0001d517          	auipc	a0,0x1d
    8000396c:	79050513          	addi	a0,a0,1936 # 800210f8 <itable>
    80003970:	ffffd097          	auipc	ra,0xffffd
    80003974:	27a080e7          	jalr	634(ra) # 80000bea <acquire>
  empty = 0;
    80003978:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000397a:	0001d497          	auipc	s1,0x1d
    8000397e:	79648493          	addi	s1,s1,1942 # 80021110 <itable+0x18>
    80003982:	0001f697          	auipc	a3,0x1f
    80003986:	21e68693          	addi	a3,a3,542 # 80022ba0 <log>
    8000398a:	a039                	j	80003998 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000398c:	02090b63          	beqz	s2,800039c2 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003990:	08848493          	addi	s1,s1,136
    80003994:	02d48a63          	beq	s1,a3,800039c8 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003998:	449c                	lw	a5,8(s1)
    8000399a:	fef059e3          	blez	a5,8000398c <iget+0x38>
    8000399e:	4098                	lw	a4,0(s1)
    800039a0:	ff3716e3          	bne	a4,s3,8000398c <iget+0x38>
    800039a4:	40d8                	lw	a4,4(s1)
    800039a6:	ff4713e3          	bne	a4,s4,8000398c <iget+0x38>
      ip->ref++;
    800039aa:	2785                	addiw	a5,a5,1
    800039ac:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800039ae:	0001d517          	auipc	a0,0x1d
    800039b2:	74a50513          	addi	a0,a0,1866 # 800210f8 <itable>
    800039b6:	ffffd097          	auipc	ra,0xffffd
    800039ba:	2e8080e7          	jalr	744(ra) # 80000c9e <release>
      return ip;
    800039be:	8926                	mv	s2,s1
    800039c0:	a03d                	j	800039ee <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800039c2:	f7f9                	bnez	a5,80003990 <iget+0x3c>
    800039c4:	8926                	mv	s2,s1
    800039c6:	b7e9                	j	80003990 <iget+0x3c>
  if(empty == 0)
    800039c8:	02090c63          	beqz	s2,80003a00 <iget+0xac>
  ip->dev = dev;
    800039cc:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800039d0:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800039d4:	4785                	li	a5,1
    800039d6:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800039da:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800039de:	0001d517          	auipc	a0,0x1d
    800039e2:	71a50513          	addi	a0,a0,1818 # 800210f8 <itable>
    800039e6:	ffffd097          	auipc	ra,0xffffd
    800039ea:	2b8080e7          	jalr	696(ra) # 80000c9e <release>
}
    800039ee:	854a                	mv	a0,s2
    800039f0:	70a2                	ld	ra,40(sp)
    800039f2:	7402                	ld	s0,32(sp)
    800039f4:	64e2                	ld	s1,24(sp)
    800039f6:	6942                	ld	s2,16(sp)
    800039f8:	69a2                	ld	s3,8(sp)
    800039fa:	6a02                	ld	s4,0(sp)
    800039fc:	6145                	addi	sp,sp,48
    800039fe:	8082                	ret
    panic("iget: no inodes");
    80003a00:	00005517          	auipc	a0,0x5
    80003a04:	d4050513          	addi	a0,a0,-704 # 80008740 <syscallnum+0xf0>
    80003a08:	ffffd097          	auipc	ra,0xffffd
    80003a0c:	b3c080e7          	jalr	-1220(ra) # 80000544 <panic>

0000000080003a10 <fsinit>:
fsinit(int dev) {
    80003a10:	7179                	addi	sp,sp,-48
    80003a12:	f406                	sd	ra,40(sp)
    80003a14:	f022                	sd	s0,32(sp)
    80003a16:	ec26                	sd	s1,24(sp)
    80003a18:	e84a                	sd	s2,16(sp)
    80003a1a:	e44e                	sd	s3,8(sp)
    80003a1c:	1800                	addi	s0,sp,48
    80003a1e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003a20:	4585                	li	a1,1
    80003a22:	00000097          	auipc	ra,0x0
    80003a26:	a50080e7          	jalr	-1456(ra) # 80003472 <bread>
    80003a2a:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003a2c:	0001d997          	auipc	s3,0x1d
    80003a30:	6ac98993          	addi	s3,s3,1708 # 800210d8 <sb>
    80003a34:	02000613          	li	a2,32
    80003a38:	05850593          	addi	a1,a0,88
    80003a3c:	854e                	mv	a0,s3
    80003a3e:	ffffd097          	auipc	ra,0xffffd
    80003a42:	308080e7          	jalr	776(ra) # 80000d46 <memmove>
  brelse(bp);
    80003a46:	8526                	mv	a0,s1
    80003a48:	00000097          	auipc	ra,0x0
    80003a4c:	b5a080e7          	jalr	-1190(ra) # 800035a2 <brelse>
  if(sb.magic != FSMAGIC)
    80003a50:	0009a703          	lw	a4,0(s3)
    80003a54:	102037b7          	lui	a5,0x10203
    80003a58:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003a5c:	02f71263          	bne	a4,a5,80003a80 <fsinit+0x70>
  initlog(dev, &sb);
    80003a60:	0001d597          	auipc	a1,0x1d
    80003a64:	67858593          	addi	a1,a1,1656 # 800210d8 <sb>
    80003a68:	854a                	mv	a0,s2
    80003a6a:	00001097          	auipc	ra,0x1
    80003a6e:	b40080e7          	jalr	-1216(ra) # 800045aa <initlog>
}
    80003a72:	70a2                	ld	ra,40(sp)
    80003a74:	7402                	ld	s0,32(sp)
    80003a76:	64e2                	ld	s1,24(sp)
    80003a78:	6942                	ld	s2,16(sp)
    80003a7a:	69a2                	ld	s3,8(sp)
    80003a7c:	6145                	addi	sp,sp,48
    80003a7e:	8082                	ret
    panic("invalid file system");
    80003a80:	00005517          	auipc	a0,0x5
    80003a84:	cd050513          	addi	a0,a0,-816 # 80008750 <syscallnum+0x100>
    80003a88:	ffffd097          	auipc	ra,0xffffd
    80003a8c:	abc080e7          	jalr	-1348(ra) # 80000544 <panic>

0000000080003a90 <iinit>:
{
    80003a90:	7179                	addi	sp,sp,-48
    80003a92:	f406                	sd	ra,40(sp)
    80003a94:	f022                	sd	s0,32(sp)
    80003a96:	ec26                	sd	s1,24(sp)
    80003a98:	e84a                	sd	s2,16(sp)
    80003a9a:	e44e                	sd	s3,8(sp)
    80003a9c:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003a9e:	00005597          	auipc	a1,0x5
    80003aa2:	cca58593          	addi	a1,a1,-822 # 80008768 <syscallnum+0x118>
    80003aa6:	0001d517          	auipc	a0,0x1d
    80003aaa:	65250513          	addi	a0,a0,1618 # 800210f8 <itable>
    80003aae:	ffffd097          	auipc	ra,0xffffd
    80003ab2:	0ac080e7          	jalr	172(ra) # 80000b5a <initlock>
  for(i = 0; i < NINODE; i++) {
    80003ab6:	0001d497          	auipc	s1,0x1d
    80003aba:	66a48493          	addi	s1,s1,1642 # 80021120 <itable+0x28>
    80003abe:	0001f997          	auipc	s3,0x1f
    80003ac2:	0f298993          	addi	s3,s3,242 # 80022bb0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003ac6:	00005917          	auipc	s2,0x5
    80003aca:	caa90913          	addi	s2,s2,-854 # 80008770 <syscallnum+0x120>
    80003ace:	85ca                	mv	a1,s2
    80003ad0:	8526                	mv	a0,s1
    80003ad2:	00001097          	auipc	ra,0x1
    80003ad6:	e3a080e7          	jalr	-454(ra) # 8000490c <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003ada:	08848493          	addi	s1,s1,136
    80003ade:	ff3498e3          	bne	s1,s3,80003ace <iinit+0x3e>
}
    80003ae2:	70a2                	ld	ra,40(sp)
    80003ae4:	7402                	ld	s0,32(sp)
    80003ae6:	64e2                	ld	s1,24(sp)
    80003ae8:	6942                	ld	s2,16(sp)
    80003aea:	69a2                	ld	s3,8(sp)
    80003aec:	6145                	addi	sp,sp,48
    80003aee:	8082                	ret

0000000080003af0 <ialloc>:
{
    80003af0:	715d                	addi	sp,sp,-80
    80003af2:	e486                	sd	ra,72(sp)
    80003af4:	e0a2                	sd	s0,64(sp)
    80003af6:	fc26                	sd	s1,56(sp)
    80003af8:	f84a                	sd	s2,48(sp)
    80003afa:	f44e                	sd	s3,40(sp)
    80003afc:	f052                	sd	s4,32(sp)
    80003afe:	ec56                	sd	s5,24(sp)
    80003b00:	e85a                	sd	s6,16(sp)
    80003b02:	e45e                	sd	s7,8(sp)
    80003b04:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b06:	0001d717          	auipc	a4,0x1d
    80003b0a:	5de72703          	lw	a4,1502(a4) # 800210e4 <sb+0xc>
    80003b0e:	4785                	li	a5,1
    80003b10:	04e7fa63          	bgeu	a5,a4,80003b64 <ialloc+0x74>
    80003b14:	8aaa                	mv	s5,a0
    80003b16:	8bae                	mv	s7,a1
    80003b18:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003b1a:	0001da17          	auipc	s4,0x1d
    80003b1e:	5bea0a13          	addi	s4,s4,1470 # 800210d8 <sb>
    80003b22:	00048b1b          	sext.w	s6,s1
    80003b26:	0044d593          	srli	a1,s1,0x4
    80003b2a:	018a2783          	lw	a5,24(s4)
    80003b2e:	9dbd                	addw	a1,a1,a5
    80003b30:	8556                	mv	a0,s5
    80003b32:	00000097          	auipc	ra,0x0
    80003b36:	940080e7          	jalr	-1728(ra) # 80003472 <bread>
    80003b3a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003b3c:	05850993          	addi	s3,a0,88
    80003b40:	00f4f793          	andi	a5,s1,15
    80003b44:	079a                	slli	a5,a5,0x6
    80003b46:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003b48:	00099783          	lh	a5,0(s3)
    80003b4c:	c3a1                	beqz	a5,80003b8c <ialloc+0x9c>
    brelse(bp);
    80003b4e:	00000097          	auipc	ra,0x0
    80003b52:	a54080e7          	jalr	-1452(ra) # 800035a2 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b56:	0485                	addi	s1,s1,1
    80003b58:	00ca2703          	lw	a4,12(s4)
    80003b5c:	0004879b          	sext.w	a5,s1
    80003b60:	fce7e1e3          	bltu	a5,a4,80003b22 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003b64:	00005517          	auipc	a0,0x5
    80003b68:	c1450513          	addi	a0,a0,-1004 # 80008778 <syscallnum+0x128>
    80003b6c:	ffffd097          	auipc	ra,0xffffd
    80003b70:	a22080e7          	jalr	-1502(ra) # 8000058e <printf>
  return 0;
    80003b74:	4501                	li	a0,0
}
    80003b76:	60a6                	ld	ra,72(sp)
    80003b78:	6406                	ld	s0,64(sp)
    80003b7a:	74e2                	ld	s1,56(sp)
    80003b7c:	7942                	ld	s2,48(sp)
    80003b7e:	79a2                	ld	s3,40(sp)
    80003b80:	7a02                	ld	s4,32(sp)
    80003b82:	6ae2                	ld	s5,24(sp)
    80003b84:	6b42                	ld	s6,16(sp)
    80003b86:	6ba2                	ld	s7,8(sp)
    80003b88:	6161                	addi	sp,sp,80
    80003b8a:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003b8c:	04000613          	li	a2,64
    80003b90:	4581                	li	a1,0
    80003b92:	854e                	mv	a0,s3
    80003b94:	ffffd097          	auipc	ra,0xffffd
    80003b98:	152080e7          	jalr	338(ra) # 80000ce6 <memset>
      dip->type = type;
    80003b9c:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003ba0:	854a                	mv	a0,s2
    80003ba2:	00001097          	auipc	ra,0x1
    80003ba6:	c84080e7          	jalr	-892(ra) # 80004826 <log_write>
      brelse(bp);
    80003baa:	854a                	mv	a0,s2
    80003bac:	00000097          	auipc	ra,0x0
    80003bb0:	9f6080e7          	jalr	-1546(ra) # 800035a2 <brelse>
      return iget(dev, inum);
    80003bb4:	85da                	mv	a1,s6
    80003bb6:	8556                	mv	a0,s5
    80003bb8:	00000097          	auipc	ra,0x0
    80003bbc:	d9c080e7          	jalr	-612(ra) # 80003954 <iget>
    80003bc0:	bf5d                	j	80003b76 <ialloc+0x86>

0000000080003bc2 <iupdate>:
{
    80003bc2:	1101                	addi	sp,sp,-32
    80003bc4:	ec06                	sd	ra,24(sp)
    80003bc6:	e822                	sd	s0,16(sp)
    80003bc8:	e426                	sd	s1,8(sp)
    80003bca:	e04a                	sd	s2,0(sp)
    80003bcc:	1000                	addi	s0,sp,32
    80003bce:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003bd0:	415c                	lw	a5,4(a0)
    80003bd2:	0047d79b          	srliw	a5,a5,0x4
    80003bd6:	0001d597          	auipc	a1,0x1d
    80003bda:	51a5a583          	lw	a1,1306(a1) # 800210f0 <sb+0x18>
    80003bde:	9dbd                	addw	a1,a1,a5
    80003be0:	4108                	lw	a0,0(a0)
    80003be2:	00000097          	auipc	ra,0x0
    80003be6:	890080e7          	jalr	-1904(ra) # 80003472 <bread>
    80003bea:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003bec:	05850793          	addi	a5,a0,88
    80003bf0:	40c8                	lw	a0,4(s1)
    80003bf2:	893d                	andi	a0,a0,15
    80003bf4:	051a                	slli	a0,a0,0x6
    80003bf6:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003bf8:	04449703          	lh	a4,68(s1)
    80003bfc:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003c00:	04649703          	lh	a4,70(s1)
    80003c04:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003c08:	04849703          	lh	a4,72(s1)
    80003c0c:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003c10:	04a49703          	lh	a4,74(s1)
    80003c14:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003c18:	44f8                	lw	a4,76(s1)
    80003c1a:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003c1c:	03400613          	li	a2,52
    80003c20:	05048593          	addi	a1,s1,80
    80003c24:	0531                	addi	a0,a0,12
    80003c26:	ffffd097          	auipc	ra,0xffffd
    80003c2a:	120080e7          	jalr	288(ra) # 80000d46 <memmove>
  log_write(bp);
    80003c2e:	854a                	mv	a0,s2
    80003c30:	00001097          	auipc	ra,0x1
    80003c34:	bf6080e7          	jalr	-1034(ra) # 80004826 <log_write>
  brelse(bp);
    80003c38:	854a                	mv	a0,s2
    80003c3a:	00000097          	auipc	ra,0x0
    80003c3e:	968080e7          	jalr	-1688(ra) # 800035a2 <brelse>
}
    80003c42:	60e2                	ld	ra,24(sp)
    80003c44:	6442                	ld	s0,16(sp)
    80003c46:	64a2                	ld	s1,8(sp)
    80003c48:	6902                	ld	s2,0(sp)
    80003c4a:	6105                	addi	sp,sp,32
    80003c4c:	8082                	ret

0000000080003c4e <idup>:
{
    80003c4e:	1101                	addi	sp,sp,-32
    80003c50:	ec06                	sd	ra,24(sp)
    80003c52:	e822                	sd	s0,16(sp)
    80003c54:	e426                	sd	s1,8(sp)
    80003c56:	1000                	addi	s0,sp,32
    80003c58:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003c5a:	0001d517          	auipc	a0,0x1d
    80003c5e:	49e50513          	addi	a0,a0,1182 # 800210f8 <itable>
    80003c62:	ffffd097          	auipc	ra,0xffffd
    80003c66:	f88080e7          	jalr	-120(ra) # 80000bea <acquire>
  ip->ref++;
    80003c6a:	449c                	lw	a5,8(s1)
    80003c6c:	2785                	addiw	a5,a5,1
    80003c6e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003c70:	0001d517          	auipc	a0,0x1d
    80003c74:	48850513          	addi	a0,a0,1160 # 800210f8 <itable>
    80003c78:	ffffd097          	auipc	ra,0xffffd
    80003c7c:	026080e7          	jalr	38(ra) # 80000c9e <release>
}
    80003c80:	8526                	mv	a0,s1
    80003c82:	60e2                	ld	ra,24(sp)
    80003c84:	6442                	ld	s0,16(sp)
    80003c86:	64a2                	ld	s1,8(sp)
    80003c88:	6105                	addi	sp,sp,32
    80003c8a:	8082                	ret

0000000080003c8c <ilock>:
{
    80003c8c:	1101                	addi	sp,sp,-32
    80003c8e:	ec06                	sd	ra,24(sp)
    80003c90:	e822                	sd	s0,16(sp)
    80003c92:	e426                	sd	s1,8(sp)
    80003c94:	e04a                	sd	s2,0(sp)
    80003c96:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003c98:	c115                	beqz	a0,80003cbc <ilock+0x30>
    80003c9a:	84aa                	mv	s1,a0
    80003c9c:	451c                	lw	a5,8(a0)
    80003c9e:	00f05f63          	blez	a5,80003cbc <ilock+0x30>
  acquiresleep(&ip->lock);
    80003ca2:	0541                	addi	a0,a0,16
    80003ca4:	00001097          	auipc	ra,0x1
    80003ca8:	ca2080e7          	jalr	-862(ra) # 80004946 <acquiresleep>
  if(ip->valid == 0){
    80003cac:	40bc                	lw	a5,64(s1)
    80003cae:	cf99                	beqz	a5,80003ccc <ilock+0x40>
}
    80003cb0:	60e2                	ld	ra,24(sp)
    80003cb2:	6442                	ld	s0,16(sp)
    80003cb4:	64a2                	ld	s1,8(sp)
    80003cb6:	6902                	ld	s2,0(sp)
    80003cb8:	6105                	addi	sp,sp,32
    80003cba:	8082                	ret
    panic("ilock");
    80003cbc:	00005517          	auipc	a0,0x5
    80003cc0:	ad450513          	addi	a0,a0,-1324 # 80008790 <syscallnum+0x140>
    80003cc4:	ffffd097          	auipc	ra,0xffffd
    80003cc8:	880080e7          	jalr	-1920(ra) # 80000544 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003ccc:	40dc                	lw	a5,4(s1)
    80003cce:	0047d79b          	srliw	a5,a5,0x4
    80003cd2:	0001d597          	auipc	a1,0x1d
    80003cd6:	41e5a583          	lw	a1,1054(a1) # 800210f0 <sb+0x18>
    80003cda:	9dbd                	addw	a1,a1,a5
    80003cdc:	4088                	lw	a0,0(s1)
    80003cde:	fffff097          	auipc	ra,0xfffff
    80003ce2:	794080e7          	jalr	1940(ra) # 80003472 <bread>
    80003ce6:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003ce8:	05850593          	addi	a1,a0,88
    80003cec:	40dc                	lw	a5,4(s1)
    80003cee:	8bbd                	andi	a5,a5,15
    80003cf0:	079a                	slli	a5,a5,0x6
    80003cf2:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003cf4:	00059783          	lh	a5,0(a1)
    80003cf8:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003cfc:	00259783          	lh	a5,2(a1)
    80003d00:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003d04:	00459783          	lh	a5,4(a1)
    80003d08:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003d0c:	00659783          	lh	a5,6(a1)
    80003d10:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003d14:	459c                	lw	a5,8(a1)
    80003d16:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003d18:	03400613          	li	a2,52
    80003d1c:	05b1                	addi	a1,a1,12
    80003d1e:	05048513          	addi	a0,s1,80
    80003d22:	ffffd097          	auipc	ra,0xffffd
    80003d26:	024080e7          	jalr	36(ra) # 80000d46 <memmove>
    brelse(bp);
    80003d2a:	854a                	mv	a0,s2
    80003d2c:	00000097          	auipc	ra,0x0
    80003d30:	876080e7          	jalr	-1930(ra) # 800035a2 <brelse>
    ip->valid = 1;
    80003d34:	4785                	li	a5,1
    80003d36:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003d38:	04449783          	lh	a5,68(s1)
    80003d3c:	fbb5                	bnez	a5,80003cb0 <ilock+0x24>
      panic("ilock: no type");
    80003d3e:	00005517          	auipc	a0,0x5
    80003d42:	a5a50513          	addi	a0,a0,-1446 # 80008798 <syscallnum+0x148>
    80003d46:	ffffc097          	auipc	ra,0xffffc
    80003d4a:	7fe080e7          	jalr	2046(ra) # 80000544 <panic>

0000000080003d4e <iunlock>:
{
    80003d4e:	1101                	addi	sp,sp,-32
    80003d50:	ec06                	sd	ra,24(sp)
    80003d52:	e822                	sd	s0,16(sp)
    80003d54:	e426                	sd	s1,8(sp)
    80003d56:	e04a                	sd	s2,0(sp)
    80003d58:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003d5a:	c905                	beqz	a0,80003d8a <iunlock+0x3c>
    80003d5c:	84aa                	mv	s1,a0
    80003d5e:	01050913          	addi	s2,a0,16
    80003d62:	854a                	mv	a0,s2
    80003d64:	00001097          	auipc	ra,0x1
    80003d68:	c7c080e7          	jalr	-900(ra) # 800049e0 <holdingsleep>
    80003d6c:	cd19                	beqz	a0,80003d8a <iunlock+0x3c>
    80003d6e:	449c                	lw	a5,8(s1)
    80003d70:	00f05d63          	blez	a5,80003d8a <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003d74:	854a                	mv	a0,s2
    80003d76:	00001097          	auipc	ra,0x1
    80003d7a:	c26080e7          	jalr	-986(ra) # 8000499c <releasesleep>
}
    80003d7e:	60e2                	ld	ra,24(sp)
    80003d80:	6442                	ld	s0,16(sp)
    80003d82:	64a2                	ld	s1,8(sp)
    80003d84:	6902                	ld	s2,0(sp)
    80003d86:	6105                	addi	sp,sp,32
    80003d88:	8082                	ret
    panic("iunlock");
    80003d8a:	00005517          	auipc	a0,0x5
    80003d8e:	a1e50513          	addi	a0,a0,-1506 # 800087a8 <syscallnum+0x158>
    80003d92:	ffffc097          	auipc	ra,0xffffc
    80003d96:	7b2080e7          	jalr	1970(ra) # 80000544 <panic>

0000000080003d9a <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003d9a:	7179                	addi	sp,sp,-48
    80003d9c:	f406                	sd	ra,40(sp)
    80003d9e:	f022                	sd	s0,32(sp)
    80003da0:	ec26                	sd	s1,24(sp)
    80003da2:	e84a                	sd	s2,16(sp)
    80003da4:	e44e                	sd	s3,8(sp)
    80003da6:	e052                	sd	s4,0(sp)
    80003da8:	1800                	addi	s0,sp,48
    80003daa:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003dac:	05050493          	addi	s1,a0,80
    80003db0:	08050913          	addi	s2,a0,128
    80003db4:	a021                	j	80003dbc <itrunc+0x22>
    80003db6:	0491                	addi	s1,s1,4
    80003db8:	01248d63          	beq	s1,s2,80003dd2 <itrunc+0x38>
    if(ip->addrs[i]){
    80003dbc:	408c                	lw	a1,0(s1)
    80003dbe:	dde5                	beqz	a1,80003db6 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003dc0:	0009a503          	lw	a0,0(s3)
    80003dc4:	00000097          	auipc	ra,0x0
    80003dc8:	8f4080e7          	jalr	-1804(ra) # 800036b8 <bfree>
      ip->addrs[i] = 0;
    80003dcc:	0004a023          	sw	zero,0(s1)
    80003dd0:	b7dd                	j	80003db6 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003dd2:	0809a583          	lw	a1,128(s3)
    80003dd6:	e185                	bnez	a1,80003df6 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003dd8:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003ddc:	854e                	mv	a0,s3
    80003dde:	00000097          	auipc	ra,0x0
    80003de2:	de4080e7          	jalr	-540(ra) # 80003bc2 <iupdate>
}
    80003de6:	70a2                	ld	ra,40(sp)
    80003de8:	7402                	ld	s0,32(sp)
    80003dea:	64e2                	ld	s1,24(sp)
    80003dec:	6942                	ld	s2,16(sp)
    80003dee:	69a2                	ld	s3,8(sp)
    80003df0:	6a02                	ld	s4,0(sp)
    80003df2:	6145                	addi	sp,sp,48
    80003df4:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003df6:	0009a503          	lw	a0,0(s3)
    80003dfa:	fffff097          	auipc	ra,0xfffff
    80003dfe:	678080e7          	jalr	1656(ra) # 80003472 <bread>
    80003e02:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003e04:	05850493          	addi	s1,a0,88
    80003e08:	45850913          	addi	s2,a0,1112
    80003e0c:	a811                	j	80003e20 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003e0e:	0009a503          	lw	a0,0(s3)
    80003e12:	00000097          	auipc	ra,0x0
    80003e16:	8a6080e7          	jalr	-1882(ra) # 800036b8 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003e1a:	0491                	addi	s1,s1,4
    80003e1c:	01248563          	beq	s1,s2,80003e26 <itrunc+0x8c>
      if(a[j])
    80003e20:	408c                	lw	a1,0(s1)
    80003e22:	dde5                	beqz	a1,80003e1a <itrunc+0x80>
    80003e24:	b7ed                	j	80003e0e <itrunc+0x74>
    brelse(bp);
    80003e26:	8552                	mv	a0,s4
    80003e28:	fffff097          	auipc	ra,0xfffff
    80003e2c:	77a080e7          	jalr	1914(ra) # 800035a2 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003e30:	0809a583          	lw	a1,128(s3)
    80003e34:	0009a503          	lw	a0,0(s3)
    80003e38:	00000097          	auipc	ra,0x0
    80003e3c:	880080e7          	jalr	-1920(ra) # 800036b8 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003e40:	0809a023          	sw	zero,128(s3)
    80003e44:	bf51                	j	80003dd8 <itrunc+0x3e>

0000000080003e46 <iput>:
{
    80003e46:	1101                	addi	sp,sp,-32
    80003e48:	ec06                	sd	ra,24(sp)
    80003e4a:	e822                	sd	s0,16(sp)
    80003e4c:	e426                	sd	s1,8(sp)
    80003e4e:	e04a                	sd	s2,0(sp)
    80003e50:	1000                	addi	s0,sp,32
    80003e52:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003e54:	0001d517          	auipc	a0,0x1d
    80003e58:	2a450513          	addi	a0,a0,676 # 800210f8 <itable>
    80003e5c:	ffffd097          	auipc	ra,0xffffd
    80003e60:	d8e080e7          	jalr	-626(ra) # 80000bea <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e64:	4498                	lw	a4,8(s1)
    80003e66:	4785                	li	a5,1
    80003e68:	02f70363          	beq	a4,a5,80003e8e <iput+0x48>
  ip->ref--;
    80003e6c:	449c                	lw	a5,8(s1)
    80003e6e:	37fd                	addiw	a5,a5,-1
    80003e70:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003e72:	0001d517          	auipc	a0,0x1d
    80003e76:	28650513          	addi	a0,a0,646 # 800210f8 <itable>
    80003e7a:	ffffd097          	auipc	ra,0xffffd
    80003e7e:	e24080e7          	jalr	-476(ra) # 80000c9e <release>
}
    80003e82:	60e2                	ld	ra,24(sp)
    80003e84:	6442                	ld	s0,16(sp)
    80003e86:	64a2                	ld	s1,8(sp)
    80003e88:	6902                	ld	s2,0(sp)
    80003e8a:	6105                	addi	sp,sp,32
    80003e8c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e8e:	40bc                	lw	a5,64(s1)
    80003e90:	dff1                	beqz	a5,80003e6c <iput+0x26>
    80003e92:	04a49783          	lh	a5,74(s1)
    80003e96:	fbf9                	bnez	a5,80003e6c <iput+0x26>
    acquiresleep(&ip->lock);
    80003e98:	01048913          	addi	s2,s1,16
    80003e9c:	854a                	mv	a0,s2
    80003e9e:	00001097          	auipc	ra,0x1
    80003ea2:	aa8080e7          	jalr	-1368(ra) # 80004946 <acquiresleep>
    release(&itable.lock);
    80003ea6:	0001d517          	auipc	a0,0x1d
    80003eaa:	25250513          	addi	a0,a0,594 # 800210f8 <itable>
    80003eae:	ffffd097          	auipc	ra,0xffffd
    80003eb2:	df0080e7          	jalr	-528(ra) # 80000c9e <release>
    itrunc(ip);
    80003eb6:	8526                	mv	a0,s1
    80003eb8:	00000097          	auipc	ra,0x0
    80003ebc:	ee2080e7          	jalr	-286(ra) # 80003d9a <itrunc>
    ip->type = 0;
    80003ec0:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003ec4:	8526                	mv	a0,s1
    80003ec6:	00000097          	auipc	ra,0x0
    80003eca:	cfc080e7          	jalr	-772(ra) # 80003bc2 <iupdate>
    ip->valid = 0;
    80003ece:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003ed2:	854a                	mv	a0,s2
    80003ed4:	00001097          	auipc	ra,0x1
    80003ed8:	ac8080e7          	jalr	-1336(ra) # 8000499c <releasesleep>
    acquire(&itable.lock);
    80003edc:	0001d517          	auipc	a0,0x1d
    80003ee0:	21c50513          	addi	a0,a0,540 # 800210f8 <itable>
    80003ee4:	ffffd097          	auipc	ra,0xffffd
    80003ee8:	d06080e7          	jalr	-762(ra) # 80000bea <acquire>
    80003eec:	b741                	j	80003e6c <iput+0x26>

0000000080003eee <iunlockput>:
{
    80003eee:	1101                	addi	sp,sp,-32
    80003ef0:	ec06                	sd	ra,24(sp)
    80003ef2:	e822                	sd	s0,16(sp)
    80003ef4:	e426                	sd	s1,8(sp)
    80003ef6:	1000                	addi	s0,sp,32
    80003ef8:	84aa                	mv	s1,a0
  iunlock(ip);
    80003efa:	00000097          	auipc	ra,0x0
    80003efe:	e54080e7          	jalr	-428(ra) # 80003d4e <iunlock>
  iput(ip);
    80003f02:	8526                	mv	a0,s1
    80003f04:	00000097          	auipc	ra,0x0
    80003f08:	f42080e7          	jalr	-190(ra) # 80003e46 <iput>
}
    80003f0c:	60e2                	ld	ra,24(sp)
    80003f0e:	6442                	ld	s0,16(sp)
    80003f10:	64a2                	ld	s1,8(sp)
    80003f12:	6105                	addi	sp,sp,32
    80003f14:	8082                	ret

0000000080003f16 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003f16:	1141                	addi	sp,sp,-16
    80003f18:	e422                	sd	s0,8(sp)
    80003f1a:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003f1c:	411c                	lw	a5,0(a0)
    80003f1e:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003f20:	415c                	lw	a5,4(a0)
    80003f22:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003f24:	04451783          	lh	a5,68(a0)
    80003f28:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003f2c:	04a51783          	lh	a5,74(a0)
    80003f30:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003f34:	04c56783          	lwu	a5,76(a0)
    80003f38:	e99c                	sd	a5,16(a1)
}
    80003f3a:	6422                	ld	s0,8(sp)
    80003f3c:	0141                	addi	sp,sp,16
    80003f3e:	8082                	ret

0000000080003f40 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f40:	457c                	lw	a5,76(a0)
    80003f42:	0ed7e963          	bltu	a5,a3,80004034 <readi+0xf4>
{
    80003f46:	7159                	addi	sp,sp,-112
    80003f48:	f486                	sd	ra,104(sp)
    80003f4a:	f0a2                	sd	s0,96(sp)
    80003f4c:	eca6                	sd	s1,88(sp)
    80003f4e:	e8ca                	sd	s2,80(sp)
    80003f50:	e4ce                	sd	s3,72(sp)
    80003f52:	e0d2                	sd	s4,64(sp)
    80003f54:	fc56                	sd	s5,56(sp)
    80003f56:	f85a                	sd	s6,48(sp)
    80003f58:	f45e                	sd	s7,40(sp)
    80003f5a:	f062                	sd	s8,32(sp)
    80003f5c:	ec66                	sd	s9,24(sp)
    80003f5e:	e86a                	sd	s10,16(sp)
    80003f60:	e46e                	sd	s11,8(sp)
    80003f62:	1880                	addi	s0,sp,112
    80003f64:	8b2a                	mv	s6,a0
    80003f66:	8bae                	mv	s7,a1
    80003f68:	8a32                	mv	s4,a2
    80003f6a:	84b6                	mv	s1,a3
    80003f6c:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003f6e:	9f35                	addw	a4,a4,a3
    return 0;
    80003f70:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003f72:	0ad76063          	bltu	a4,a3,80004012 <readi+0xd2>
  if(off + n > ip->size)
    80003f76:	00e7f463          	bgeu	a5,a4,80003f7e <readi+0x3e>
    n = ip->size - off;
    80003f7a:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f7e:	0a0a8963          	beqz	s5,80004030 <readi+0xf0>
    80003f82:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f84:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003f88:	5c7d                	li	s8,-1
    80003f8a:	a82d                	j	80003fc4 <readi+0x84>
    80003f8c:	020d1d93          	slli	s11,s10,0x20
    80003f90:	020ddd93          	srli	s11,s11,0x20
    80003f94:	05890613          	addi	a2,s2,88
    80003f98:	86ee                	mv	a3,s11
    80003f9a:	963a                	add	a2,a2,a4
    80003f9c:	85d2                	mv	a1,s4
    80003f9e:	855e                	mv	a0,s7
    80003fa0:	ffffe097          	auipc	ra,0xffffe
    80003fa4:	788080e7          	jalr	1928(ra) # 80002728 <either_copyout>
    80003fa8:	05850d63          	beq	a0,s8,80004002 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003fac:	854a                	mv	a0,s2
    80003fae:	fffff097          	auipc	ra,0xfffff
    80003fb2:	5f4080e7          	jalr	1524(ra) # 800035a2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003fb6:	013d09bb          	addw	s3,s10,s3
    80003fba:	009d04bb          	addw	s1,s10,s1
    80003fbe:	9a6e                	add	s4,s4,s11
    80003fc0:	0559f763          	bgeu	s3,s5,8000400e <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003fc4:	00a4d59b          	srliw	a1,s1,0xa
    80003fc8:	855a                	mv	a0,s6
    80003fca:	00000097          	auipc	ra,0x0
    80003fce:	8a2080e7          	jalr	-1886(ra) # 8000386c <bmap>
    80003fd2:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003fd6:	cd85                	beqz	a1,8000400e <readi+0xce>
    bp = bread(ip->dev, addr);
    80003fd8:	000b2503          	lw	a0,0(s6)
    80003fdc:	fffff097          	auipc	ra,0xfffff
    80003fe0:	496080e7          	jalr	1174(ra) # 80003472 <bread>
    80003fe4:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fe6:	3ff4f713          	andi	a4,s1,1023
    80003fea:	40ec87bb          	subw	a5,s9,a4
    80003fee:	413a86bb          	subw	a3,s5,s3
    80003ff2:	8d3e                	mv	s10,a5
    80003ff4:	2781                	sext.w	a5,a5
    80003ff6:	0006861b          	sext.w	a2,a3
    80003ffa:	f8f679e3          	bgeu	a2,a5,80003f8c <readi+0x4c>
    80003ffe:	8d36                	mv	s10,a3
    80004000:	b771                	j	80003f8c <readi+0x4c>
      brelse(bp);
    80004002:	854a                	mv	a0,s2
    80004004:	fffff097          	auipc	ra,0xfffff
    80004008:	59e080e7          	jalr	1438(ra) # 800035a2 <brelse>
      tot = -1;
    8000400c:	59fd                	li	s3,-1
  }
  return tot;
    8000400e:	0009851b          	sext.w	a0,s3
}
    80004012:	70a6                	ld	ra,104(sp)
    80004014:	7406                	ld	s0,96(sp)
    80004016:	64e6                	ld	s1,88(sp)
    80004018:	6946                	ld	s2,80(sp)
    8000401a:	69a6                	ld	s3,72(sp)
    8000401c:	6a06                	ld	s4,64(sp)
    8000401e:	7ae2                	ld	s5,56(sp)
    80004020:	7b42                	ld	s6,48(sp)
    80004022:	7ba2                	ld	s7,40(sp)
    80004024:	7c02                	ld	s8,32(sp)
    80004026:	6ce2                	ld	s9,24(sp)
    80004028:	6d42                	ld	s10,16(sp)
    8000402a:	6da2                	ld	s11,8(sp)
    8000402c:	6165                	addi	sp,sp,112
    8000402e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004030:	89d6                	mv	s3,s5
    80004032:	bff1                	j	8000400e <readi+0xce>
    return 0;
    80004034:	4501                	li	a0,0
}
    80004036:	8082                	ret

0000000080004038 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004038:	457c                	lw	a5,76(a0)
    8000403a:	10d7e863          	bltu	a5,a3,8000414a <writei+0x112>
{
    8000403e:	7159                	addi	sp,sp,-112
    80004040:	f486                	sd	ra,104(sp)
    80004042:	f0a2                	sd	s0,96(sp)
    80004044:	eca6                	sd	s1,88(sp)
    80004046:	e8ca                	sd	s2,80(sp)
    80004048:	e4ce                	sd	s3,72(sp)
    8000404a:	e0d2                	sd	s4,64(sp)
    8000404c:	fc56                	sd	s5,56(sp)
    8000404e:	f85a                	sd	s6,48(sp)
    80004050:	f45e                	sd	s7,40(sp)
    80004052:	f062                	sd	s8,32(sp)
    80004054:	ec66                	sd	s9,24(sp)
    80004056:	e86a                	sd	s10,16(sp)
    80004058:	e46e                	sd	s11,8(sp)
    8000405a:	1880                	addi	s0,sp,112
    8000405c:	8aaa                	mv	s5,a0
    8000405e:	8bae                	mv	s7,a1
    80004060:	8a32                	mv	s4,a2
    80004062:	8936                	mv	s2,a3
    80004064:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004066:	00e687bb          	addw	a5,a3,a4
    8000406a:	0ed7e263          	bltu	a5,a3,8000414e <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000406e:	00043737          	lui	a4,0x43
    80004072:	0ef76063          	bltu	a4,a5,80004152 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004076:	0c0b0863          	beqz	s6,80004146 <writei+0x10e>
    8000407a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000407c:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004080:	5c7d                	li	s8,-1
    80004082:	a091                	j	800040c6 <writei+0x8e>
    80004084:	020d1d93          	slli	s11,s10,0x20
    80004088:	020ddd93          	srli	s11,s11,0x20
    8000408c:	05848513          	addi	a0,s1,88
    80004090:	86ee                	mv	a3,s11
    80004092:	8652                	mv	a2,s4
    80004094:	85de                	mv	a1,s7
    80004096:	953a                	add	a0,a0,a4
    80004098:	ffffe097          	auipc	ra,0xffffe
    8000409c:	6e6080e7          	jalr	1766(ra) # 8000277e <either_copyin>
    800040a0:	07850263          	beq	a0,s8,80004104 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800040a4:	8526                	mv	a0,s1
    800040a6:	00000097          	auipc	ra,0x0
    800040aa:	780080e7          	jalr	1920(ra) # 80004826 <log_write>
    brelse(bp);
    800040ae:	8526                	mv	a0,s1
    800040b0:	fffff097          	auipc	ra,0xfffff
    800040b4:	4f2080e7          	jalr	1266(ra) # 800035a2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800040b8:	013d09bb          	addw	s3,s10,s3
    800040bc:	012d093b          	addw	s2,s10,s2
    800040c0:	9a6e                	add	s4,s4,s11
    800040c2:	0569f663          	bgeu	s3,s6,8000410e <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    800040c6:	00a9559b          	srliw	a1,s2,0xa
    800040ca:	8556                	mv	a0,s5
    800040cc:	fffff097          	auipc	ra,0xfffff
    800040d0:	7a0080e7          	jalr	1952(ra) # 8000386c <bmap>
    800040d4:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800040d8:	c99d                	beqz	a1,8000410e <writei+0xd6>
    bp = bread(ip->dev, addr);
    800040da:	000aa503          	lw	a0,0(s5)
    800040de:	fffff097          	auipc	ra,0xfffff
    800040e2:	394080e7          	jalr	916(ra) # 80003472 <bread>
    800040e6:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800040e8:	3ff97713          	andi	a4,s2,1023
    800040ec:	40ec87bb          	subw	a5,s9,a4
    800040f0:	413b06bb          	subw	a3,s6,s3
    800040f4:	8d3e                	mv	s10,a5
    800040f6:	2781                	sext.w	a5,a5
    800040f8:	0006861b          	sext.w	a2,a3
    800040fc:	f8f674e3          	bgeu	a2,a5,80004084 <writei+0x4c>
    80004100:	8d36                	mv	s10,a3
    80004102:	b749                	j	80004084 <writei+0x4c>
      brelse(bp);
    80004104:	8526                	mv	a0,s1
    80004106:	fffff097          	auipc	ra,0xfffff
    8000410a:	49c080e7          	jalr	1180(ra) # 800035a2 <brelse>
  }

  if(off > ip->size)
    8000410e:	04caa783          	lw	a5,76(s5)
    80004112:	0127f463          	bgeu	a5,s2,8000411a <writei+0xe2>
    ip->size = off;
    80004116:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000411a:	8556                	mv	a0,s5
    8000411c:	00000097          	auipc	ra,0x0
    80004120:	aa6080e7          	jalr	-1370(ra) # 80003bc2 <iupdate>

  return tot;
    80004124:	0009851b          	sext.w	a0,s3
}
    80004128:	70a6                	ld	ra,104(sp)
    8000412a:	7406                	ld	s0,96(sp)
    8000412c:	64e6                	ld	s1,88(sp)
    8000412e:	6946                	ld	s2,80(sp)
    80004130:	69a6                	ld	s3,72(sp)
    80004132:	6a06                	ld	s4,64(sp)
    80004134:	7ae2                	ld	s5,56(sp)
    80004136:	7b42                	ld	s6,48(sp)
    80004138:	7ba2                	ld	s7,40(sp)
    8000413a:	7c02                	ld	s8,32(sp)
    8000413c:	6ce2                	ld	s9,24(sp)
    8000413e:	6d42                	ld	s10,16(sp)
    80004140:	6da2                	ld	s11,8(sp)
    80004142:	6165                	addi	sp,sp,112
    80004144:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004146:	89da                	mv	s3,s6
    80004148:	bfc9                	j	8000411a <writei+0xe2>
    return -1;
    8000414a:	557d                	li	a0,-1
}
    8000414c:	8082                	ret
    return -1;
    8000414e:	557d                	li	a0,-1
    80004150:	bfe1                	j	80004128 <writei+0xf0>
    return -1;
    80004152:	557d                	li	a0,-1
    80004154:	bfd1                	j	80004128 <writei+0xf0>

0000000080004156 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004156:	1141                	addi	sp,sp,-16
    80004158:	e406                	sd	ra,8(sp)
    8000415a:	e022                	sd	s0,0(sp)
    8000415c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000415e:	4639                	li	a2,14
    80004160:	ffffd097          	auipc	ra,0xffffd
    80004164:	c5e080e7          	jalr	-930(ra) # 80000dbe <strncmp>
}
    80004168:	60a2                	ld	ra,8(sp)
    8000416a:	6402                	ld	s0,0(sp)
    8000416c:	0141                	addi	sp,sp,16
    8000416e:	8082                	ret

0000000080004170 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004170:	7139                	addi	sp,sp,-64
    80004172:	fc06                	sd	ra,56(sp)
    80004174:	f822                	sd	s0,48(sp)
    80004176:	f426                	sd	s1,40(sp)
    80004178:	f04a                	sd	s2,32(sp)
    8000417a:	ec4e                	sd	s3,24(sp)
    8000417c:	e852                	sd	s4,16(sp)
    8000417e:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004180:	04451703          	lh	a4,68(a0)
    80004184:	4785                	li	a5,1
    80004186:	00f71a63          	bne	a4,a5,8000419a <dirlookup+0x2a>
    8000418a:	892a                	mv	s2,a0
    8000418c:	89ae                	mv	s3,a1
    8000418e:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004190:	457c                	lw	a5,76(a0)
    80004192:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004194:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004196:	e79d                	bnez	a5,800041c4 <dirlookup+0x54>
    80004198:	a8a5                	j	80004210 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    8000419a:	00004517          	auipc	a0,0x4
    8000419e:	61650513          	addi	a0,a0,1558 # 800087b0 <syscallnum+0x160>
    800041a2:	ffffc097          	auipc	ra,0xffffc
    800041a6:	3a2080e7          	jalr	930(ra) # 80000544 <panic>
      panic("dirlookup read");
    800041aa:	00004517          	auipc	a0,0x4
    800041ae:	61e50513          	addi	a0,a0,1566 # 800087c8 <syscallnum+0x178>
    800041b2:	ffffc097          	auipc	ra,0xffffc
    800041b6:	392080e7          	jalr	914(ra) # 80000544 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041ba:	24c1                	addiw	s1,s1,16
    800041bc:	04c92783          	lw	a5,76(s2)
    800041c0:	04f4f763          	bgeu	s1,a5,8000420e <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041c4:	4741                	li	a4,16
    800041c6:	86a6                	mv	a3,s1
    800041c8:	fc040613          	addi	a2,s0,-64
    800041cc:	4581                	li	a1,0
    800041ce:	854a                	mv	a0,s2
    800041d0:	00000097          	auipc	ra,0x0
    800041d4:	d70080e7          	jalr	-656(ra) # 80003f40 <readi>
    800041d8:	47c1                	li	a5,16
    800041da:	fcf518e3          	bne	a0,a5,800041aa <dirlookup+0x3a>
    if(de.inum == 0)
    800041de:	fc045783          	lhu	a5,-64(s0)
    800041e2:	dfe1                	beqz	a5,800041ba <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800041e4:	fc240593          	addi	a1,s0,-62
    800041e8:	854e                	mv	a0,s3
    800041ea:	00000097          	auipc	ra,0x0
    800041ee:	f6c080e7          	jalr	-148(ra) # 80004156 <namecmp>
    800041f2:	f561                	bnez	a0,800041ba <dirlookup+0x4a>
      if(poff)
    800041f4:	000a0463          	beqz	s4,800041fc <dirlookup+0x8c>
        *poff = off;
    800041f8:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800041fc:	fc045583          	lhu	a1,-64(s0)
    80004200:	00092503          	lw	a0,0(s2)
    80004204:	fffff097          	auipc	ra,0xfffff
    80004208:	750080e7          	jalr	1872(ra) # 80003954 <iget>
    8000420c:	a011                	j	80004210 <dirlookup+0xa0>
  return 0;
    8000420e:	4501                	li	a0,0
}
    80004210:	70e2                	ld	ra,56(sp)
    80004212:	7442                	ld	s0,48(sp)
    80004214:	74a2                	ld	s1,40(sp)
    80004216:	7902                	ld	s2,32(sp)
    80004218:	69e2                	ld	s3,24(sp)
    8000421a:	6a42                	ld	s4,16(sp)
    8000421c:	6121                	addi	sp,sp,64
    8000421e:	8082                	ret

0000000080004220 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004220:	711d                	addi	sp,sp,-96
    80004222:	ec86                	sd	ra,88(sp)
    80004224:	e8a2                	sd	s0,80(sp)
    80004226:	e4a6                	sd	s1,72(sp)
    80004228:	e0ca                	sd	s2,64(sp)
    8000422a:	fc4e                	sd	s3,56(sp)
    8000422c:	f852                	sd	s4,48(sp)
    8000422e:	f456                	sd	s5,40(sp)
    80004230:	f05a                	sd	s6,32(sp)
    80004232:	ec5e                	sd	s7,24(sp)
    80004234:	e862                	sd	s8,16(sp)
    80004236:	e466                	sd	s9,8(sp)
    80004238:	1080                	addi	s0,sp,96
    8000423a:	84aa                	mv	s1,a0
    8000423c:	8b2e                	mv	s6,a1
    8000423e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004240:	00054703          	lbu	a4,0(a0)
    80004244:	02f00793          	li	a5,47
    80004248:	02f70363          	beq	a4,a5,8000426e <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000424c:	ffffd097          	auipc	ra,0xffffd
    80004250:	77a080e7          	jalr	1914(ra) # 800019c6 <myproc>
    80004254:	15053503          	ld	a0,336(a0)
    80004258:	00000097          	auipc	ra,0x0
    8000425c:	9f6080e7          	jalr	-1546(ra) # 80003c4e <idup>
    80004260:	89aa                	mv	s3,a0
  while(*path == '/')
    80004262:	02f00913          	li	s2,47
  len = path - s;
    80004266:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80004268:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000426a:	4c05                	li	s8,1
    8000426c:	a865                	j	80004324 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    8000426e:	4585                	li	a1,1
    80004270:	4505                	li	a0,1
    80004272:	fffff097          	auipc	ra,0xfffff
    80004276:	6e2080e7          	jalr	1762(ra) # 80003954 <iget>
    8000427a:	89aa                	mv	s3,a0
    8000427c:	b7dd                	j	80004262 <namex+0x42>
      iunlockput(ip);
    8000427e:	854e                	mv	a0,s3
    80004280:	00000097          	auipc	ra,0x0
    80004284:	c6e080e7          	jalr	-914(ra) # 80003eee <iunlockput>
      return 0;
    80004288:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    8000428a:	854e                	mv	a0,s3
    8000428c:	60e6                	ld	ra,88(sp)
    8000428e:	6446                	ld	s0,80(sp)
    80004290:	64a6                	ld	s1,72(sp)
    80004292:	6906                	ld	s2,64(sp)
    80004294:	79e2                	ld	s3,56(sp)
    80004296:	7a42                	ld	s4,48(sp)
    80004298:	7aa2                	ld	s5,40(sp)
    8000429a:	7b02                	ld	s6,32(sp)
    8000429c:	6be2                	ld	s7,24(sp)
    8000429e:	6c42                	ld	s8,16(sp)
    800042a0:	6ca2                	ld	s9,8(sp)
    800042a2:	6125                	addi	sp,sp,96
    800042a4:	8082                	ret
      iunlock(ip);
    800042a6:	854e                	mv	a0,s3
    800042a8:	00000097          	auipc	ra,0x0
    800042ac:	aa6080e7          	jalr	-1370(ra) # 80003d4e <iunlock>
      return ip;
    800042b0:	bfe9                	j	8000428a <namex+0x6a>
      iunlockput(ip);
    800042b2:	854e                	mv	a0,s3
    800042b4:	00000097          	auipc	ra,0x0
    800042b8:	c3a080e7          	jalr	-966(ra) # 80003eee <iunlockput>
      return 0;
    800042bc:	89d2                	mv	s3,s4
    800042be:	b7f1                	j	8000428a <namex+0x6a>
  len = path - s;
    800042c0:	40b48633          	sub	a2,s1,a1
    800042c4:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    800042c8:	094cd463          	bge	s9,s4,80004350 <namex+0x130>
    memmove(name, s, DIRSIZ);
    800042cc:	4639                	li	a2,14
    800042ce:	8556                	mv	a0,s5
    800042d0:	ffffd097          	auipc	ra,0xffffd
    800042d4:	a76080e7          	jalr	-1418(ra) # 80000d46 <memmove>
  while(*path == '/')
    800042d8:	0004c783          	lbu	a5,0(s1)
    800042dc:	01279763          	bne	a5,s2,800042ea <namex+0xca>
    path++;
    800042e0:	0485                	addi	s1,s1,1
  while(*path == '/')
    800042e2:	0004c783          	lbu	a5,0(s1)
    800042e6:	ff278de3          	beq	a5,s2,800042e0 <namex+0xc0>
    ilock(ip);
    800042ea:	854e                	mv	a0,s3
    800042ec:	00000097          	auipc	ra,0x0
    800042f0:	9a0080e7          	jalr	-1632(ra) # 80003c8c <ilock>
    if(ip->type != T_DIR){
    800042f4:	04499783          	lh	a5,68(s3)
    800042f8:	f98793e3          	bne	a5,s8,8000427e <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800042fc:	000b0563          	beqz	s6,80004306 <namex+0xe6>
    80004300:	0004c783          	lbu	a5,0(s1)
    80004304:	d3cd                	beqz	a5,800042a6 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004306:	865e                	mv	a2,s7
    80004308:	85d6                	mv	a1,s5
    8000430a:	854e                	mv	a0,s3
    8000430c:	00000097          	auipc	ra,0x0
    80004310:	e64080e7          	jalr	-412(ra) # 80004170 <dirlookup>
    80004314:	8a2a                	mv	s4,a0
    80004316:	dd51                	beqz	a0,800042b2 <namex+0x92>
    iunlockput(ip);
    80004318:	854e                	mv	a0,s3
    8000431a:	00000097          	auipc	ra,0x0
    8000431e:	bd4080e7          	jalr	-1068(ra) # 80003eee <iunlockput>
    ip = next;
    80004322:	89d2                	mv	s3,s4
  while(*path == '/')
    80004324:	0004c783          	lbu	a5,0(s1)
    80004328:	05279763          	bne	a5,s2,80004376 <namex+0x156>
    path++;
    8000432c:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000432e:	0004c783          	lbu	a5,0(s1)
    80004332:	ff278de3          	beq	a5,s2,8000432c <namex+0x10c>
  if(*path == 0)
    80004336:	c79d                	beqz	a5,80004364 <namex+0x144>
    path++;
    80004338:	85a6                	mv	a1,s1
  len = path - s;
    8000433a:	8a5e                	mv	s4,s7
    8000433c:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    8000433e:	01278963          	beq	a5,s2,80004350 <namex+0x130>
    80004342:	dfbd                	beqz	a5,800042c0 <namex+0xa0>
    path++;
    80004344:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004346:	0004c783          	lbu	a5,0(s1)
    8000434a:	ff279ce3          	bne	a5,s2,80004342 <namex+0x122>
    8000434e:	bf8d                	j	800042c0 <namex+0xa0>
    memmove(name, s, len);
    80004350:	2601                	sext.w	a2,a2
    80004352:	8556                	mv	a0,s5
    80004354:	ffffd097          	auipc	ra,0xffffd
    80004358:	9f2080e7          	jalr	-1550(ra) # 80000d46 <memmove>
    name[len] = 0;
    8000435c:	9a56                	add	s4,s4,s5
    8000435e:	000a0023          	sb	zero,0(s4)
    80004362:	bf9d                	j	800042d8 <namex+0xb8>
  if(nameiparent){
    80004364:	f20b03e3          	beqz	s6,8000428a <namex+0x6a>
    iput(ip);
    80004368:	854e                	mv	a0,s3
    8000436a:	00000097          	auipc	ra,0x0
    8000436e:	adc080e7          	jalr	-1316(ra) # 80003e46 <iput>
    return 0;
    80004372:	4981                	li	s3,0
    80004374:	bf19                	j	8000428a <namex+0x6a>
  if(*path == 0)
    80004376:	d7fd                	beqz	a5,80004364 <namex+0x144>
  while(*path != '/' && *path != 0)
    80004378:	0004c783          	lbu	a5,0(s1)
    8000437c:	85a6                	mv	a1,s1
    8000437e:	b7d1                	j	80004342 <namex+0x122>

0000000080004380 <dirlink>:
{
    80004380:	7139                	addi	sp,sp,-64
    80004382:	fc06                	sd	ra,56(sp)
    80004384:	f822                	sd	s0,48(sp)
    80004386:	f426                	sd	s1,40(sp)
    80004388:	f04a                	sd	s2,32(sp)
    8000438a:	ec4e                	sd	s3,24(sp)
    8000438c:	e852                	sd	s4,16(sp)
    8000438e:	0080                	addi	s0,sp,64
    80004390:	892a                	mv	s2,a0
    80004392:	8a2e                	mv	s4,a1
    80004394:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004396:	4601                	li	a2,0
    80004398:	00000097          	auipc	ra,0x0
    8000439c:	dd8080e7          	jalr	-552(ra) # 80004170 <dirlookup>
    800043a0:	e93d                	bnez	a0,80004416 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043a2:	04c92483          	lw	s1,76(s2)
    800043a6:	c49d                	beqz	s1,800043d4 <dirlink+0x54>
    800043a8:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043aa:	4741                	li	a4,16
    800043ac:	86a6                	mv	a3,s1
    800043ae:	fc040613          	addi	a2,s0,-64
    800043b2:	4581                	li	a1,0
    800043b4:	854a                	mv	a0,s2
    800043b6:	00000097          	auipc	ra,0x0
    800043ba:	b8a080e7          	jalr	-1142(ra) # 80003f40 <readi>
    800043be:	47c1                	li	a5,16
    800043c0:	06f51163          	bne	a0,a5,80004422 <dirlink+0xa2>
    if(de.inum == 0)
    800043c4:	fc045783          	lhu	a5,-64(s0)
    800043c8:	c791                	beqz	a5,800043d4 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043ca:	24c1                	addiw	s1,s1,16
    800043cc:	04c92783          	lw	a5,76(s2)
    800043d0:	fcf4ede3          	bltu	s1,a5,800043aa <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800043d4:	4639                	li	a2,14
    800043d6:	85d2                	mv	a1,s4
    800043d8:	fc240513          	addi	a0,s0,-62
    800043dc:	ffffd097          	auipc	ra,0xffffd
    800043e0:	a1e080e7          	jalr	-1506(ra) # 80000dfa <strncpy>
  de.inum = inum;
    800043e4:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043e8:	4741                	li	a4,16
    800043ea:	86a6                	mv	a3,s1
    800043ec:	fc040613          	addi	a2,s0,-64
    800043f0:	4581                	li	a1,0
    800043f2:	854a                	mv	a0,s2
    800043f4:	00000097          	auipc	ra,0x0
    800043f8:	c44080e7          	jalr	-956(ra) # 80004038 <writei>
    800043fc:	1541                	addi	a0,a0,-16
    800043fe:	00a03533          	snez	a0,a0
    80004402:	40a00533          	neg	a0,a0
}
    80004406:	70e2                	ld	ra,56(sp)
    80004408:	7442                	ld	s0,48(sp)
    8000440a:	74a2                	ld	s1,40(sp)
    8000440c:	7902                	ld	s2,32(sp)
    8000440e:	69e2                	ld	s3,24(sp)
    80004410:	6a42                	ld	s4,16(sp)
    80004412:	6121                	addi	sp,sp,64
    80004414:	8082                	ret
    iput(ip);
    80004416:	00000097          	auipc	ra,0x0
    8000441a:	a30080e7          	jalr	-1488(ra) # 80003e46 <iput>
    return -1;
    8000441e:	557d                	li	a0,-1
    80004420:	b7dd                	j	80004406 <dirlink+0x86>
      panic("dirlink read");
    80004422:	00004517          	auipc	a0,0x4
    80004426:	3b650513          	addi	a0,a0,950 # 800087d8 <syscallnum+0x188>
    8000442a:	ffffc097          	auipc	ra,0xffffc
    8000442e:	11a080e7          	jalr	282(ra) # 80000544 <panic>

0000000080004432 <namei>:

struct inode*
namei(char *path)
{
    80004432:	1101                	addi	sp,sp,-32
    80004434:	ec06                	sd	ra,24(sp)
    80004436:	e822                	sd	s0,16(sp)
    80004438:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000443a:	fe040613          	addi	a2,s0,-32
    8000443e:	4581                	li	a1,0
    80004440:	00000097          	auipc	ra,0x0
    80004444:	de0080e7          	jalr	-544(ra) # 80004220 <namex>
}
    80004448:	60e2                	ld	ra,24(sp)
    8000444a:	6442                	ld	s0,16(sp)
    8000444c:	6105                	addi	sp,sp,32
    8000444e:	8082                	ret

0000000080004450 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004450:	1141                	addi	sp,sp,-16
    80004452:	e406                	sd	ra,8(sp)
    80004454:	e022                	sd	s0,0(sp)
    80004456:	0800                	addi	s0,sp,16
    80004458:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000445a:	4585                	li	a1,1
    8000445c:	00000097          	auipc	ra,0x0
    80004460:	dc4080e7          	jalr	-572(ra) # 80004220 <namex>
}
    80004464:	60a2                	ld	ra,8(sp)
    80004466:	6402                	ld	s0,0(sp)
    80004468:	0141                	addi	sp,sp,16
    8000446a:	8082                	ret

000000008000446c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000446c:	1101                	addi	sp,sp,-32
    8000446e:	ec06                	sd	ra,24(sp)
    80004470:	e822                	sd	s0,16(sp)
    80004472:	e426                	sd	s1,8(sp)
    80004474:	e04a                	sd	s2,0(sp)
    80004476:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004478:	0001e917          	auipc	s2,0x1e
    8000447c:	72890913          	addi	s2,s2,1832 # 80022ba0 <log>
    80004480:	01892583          	lw	a1,24(s2)
    80004484:	02892503          	lw	a0,40(s2)
    80004488:	fffff097          	auipc	ra,0xfffff
    8000448c:	fea080e7          	jalr	-22(ra) # 80003472 <bread>
    80004490:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004492:	02c92683          	lw	a3,44(s2)
    80004496:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004498:	02d05763          	blez	a3,800044c6 <write_head+0x5a>
    8000449c:	0001e797          	auipc	a5,0x1e
    800044a0:	73478793          	addi	a5,a5,1844 # 80022bd0 <log+0x30>
    800044a4:	05c50713          	addi	a4,a0,92
    800044a8:	36fd                	addiw	a3,a3,-1
    800044aa:	1682                	slli	a3,a3,0x20
    800044ac:	9281                	srli	a3,a3,0x20
    800044ae:	068a                	slli	a3,a3,0x2
    800044b0:	0001e617          	auipc	a2,0x1e
    800044b4:	72460613          	addi	a2,a2,1828 # 80022bd4 <log+0x34>
    800044b8:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800044ba:	4390                	lw	a2,0(a5)
    800044bc:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800044be:	0791                	addi	a5,a5,4
    800044c0:	0711                	addi	a4,a4,4
    800044c2:	fed79ce3          	bne	a5,a3,800044ba <write_head+0x4e>
  }
  bwrite(buf);
    800044c6:	8526                	mv	a0,s1
    800044c8:	fffff097          	auipc	ra,0xfffff
    800044cc:	09c080e7          	jalr	156(ra) # 80003564 <bwrite>
  brelse(buf);
    800044d0:	8526                	mv	a0,s1
    800044d2:	fffff097          	auipc	ra,0xfffff
    800044d6:	0d0080e7          	jalr	208(ra) # 800035a2 <brelse>
}
    800044da:	60e2                	ld	ra,24(sp)
    800044dc:	6442                	ld	s0,16(sp)
    800044de:	64a2                	ld	s1,8(sp)
    800044e0:	6902                	ld	s2,0(sp)
    800044e2:	6105                	addi	sp,sp,32
    800044e4:	8082                	ret

00000000800044e6 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800044e6:	0001e797          	auipc	a5,0x1e
    800044ea:	6e67a783          	lw	a5,1766(a5) # 80022bcc <log+0x2c>
    800044ee:	0af05d63          	blez	a5,800045a8 <install_trans+0xc2>
{
    800044f2:	7139                	addi	sp,sp,-64
    800044f4:	fc06                	sd	ra,56(sp)
    800044f6:	f822                	sd	s0,48(sp)
    800044f8:	f426                	sd	s1,40(sp)
    800044fa:	f04a                	sd	s2,32(sp)
    800044fc:	ec4e                	sd	s3,24(sp)
    800044fe:	e852                	sd	s4,16(sp)
    80004500:	e456                	sd	s5,8(sp)
    80004502:	e05a                	sd	s6,0(sp)
    80004504:	0080                	addi	s0,sp,64
    80004506:	8b2a                	mv	s6,a0
    80004508:	0001ea97          	auipc	s5,0x1e
    8000450c:	6c8a8a93          	addi	s5,s5,1736 # 80022bd0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004510:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004512:	0001e997          	auipc	s3,0x1e
    80004516:	68e98993          	addi	s3,s3,1678 # 80022ba0 <log>
    8000451a:	a035                	j	80004546 <install_trans+0x60>
      bunpin(dbuf);
    8000451c:	8526                	mv	a0,s1
    8000451e:	fffff097          	auipc	ra,0xfffff
    80004522:	15e080e7          	jalr	350(ra) # 8000367c <bunpin>
    brelse(lbuf);
    80004526:	854a                	mv	a0,s2
    80004528:	fffff097          	auipc	ra,0xfffff
    8000452c:	07a080e7          	jalr	122(ra) # 800035a2 <brelse>
    brelse(dbuf);
    80004530:	8526                	mv	a0,s1
    80004532:	fffff097          	auipc	ra,0xfffff
    80004536:	070080e7          	jalr	112(ra) # 800035a2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000453a:	2a05                	addiw	s4,s4,1
    8000453c:	0a91                	addi	s5,s5,4
    8000453e:	02c9a783          	lw	a5,44(s3)
    80004542:	04fa5963          	bge	s4,a5,80004594 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004546:	0189a583          	lw	a1,24(s3)
    8000454a:	014585bb          	addw	a1,a1,s4
    8000454e:	2585                	addiw	a1,a1,1
    80004550:	0289a503          	lw	a0,40(s3)
    80004554:	fffff097          	auipc	ra,0xfffff
    80004558:	f1e080e7          	jalr	-226(ra) # 80003472 <bread>
    8000455c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000455e:	000aa583          	lw	a1,0(s5)
    80004562:	0289a503          	lw	a0,40(s3)
    80004566:	fffff097          	auipc	ra,0xfffff
    8000456a:	f0c080e7          	jalr	-244(ra) # 80003472 <bread>
    8000456e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004570:	40000613          	li	a2,1024
    80004574:	05890593          	addi	a1,s2,88
    80004578:	05850513          	addi	a0,a0,88
    8000457c:	ffffc097          	auipc	ra,0xffffc
    80004580:	7ca080e7          	jalr	1994(ra) # 80000d46 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004584:	8526                	mv	a0,s1
    80004586:	fffff097          	auipc	ra,0xfffff
    8000458a:	fde080e7          	jalr	-34(ra) # 80003564 <bwrite>
    if(recovering == 0)
    8000458e:	f80b1ce3          	bnez	s6,80004526 <install_trans+0x40>
    80004592:	b769                	j	8000451c <install_trans+0x36>
}
    80004594:	70e2                	ld	ra,56(sp)
    80004596:	7442                	ld	s0,48(sp)
    80004598:	74a2                	ld	s1,40(sp)
    8000459a:	7902                	ld	s2,32(sp)
    8000459c:	69e2                	ld	s3,24(sp)
    8000459e:	6a42                	ld	s4,16(sp)
    800045a0:	6aa2                	ld	s5,8(sp)
    800045a2:	6b02                	ld	s6,0(sp)
    800045a4:	6121                	addi	sp,sp,64
    800045a6:	8082                	ret
    800045a8:	8082                	ret

00000000800045aa <initlog>:
{
    800045aa:	7179                	addi	sp,sp,-48
    800045ac:	f406                	sd	ra,40(sp)
    800045ae:	f022                	sd	s0,32(sp)
    800045b0:	ec26                	sd	s1,24(sp)
    800045b2:	e84a                	sd	s2,16(sp)
    800045b4:	e44e                	sd	s3,8(sp)
    800045b6:	1800                	addi	s0,sp,48
    800045b8:	892a                	mv	s2,a0
    800045ba:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800045bc:	0001e497          	auipc	s1,0x1e
    800045c0:	5e448493          	addi	s1,s1,1508 # 80022ba0 <log>
    800045c4:	00004597          	auipc	a1,0x4
    800045c8:	22458593          	addi	a1,a1,548 # 800087e8 <syscallnum+0x198>
    800045cc:	8526                	mv	a0,s1
    800045ce:	ffffc097          	auipc	ra,0xffffc
    800045d2:	58c080e7          	jalr	1420(ra) # 80000b5a <initlock>
  log.start = sb->logstart;
    800045d6:	0149a583          	lw	a1,20(s3)
    800045da:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800045dc:	0109a783          	lw	a5,16(s3)
    800045e0:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800045e2:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800045e6:	854a                	mv	a0,s2
    800045e8:	fffff097          	auipc	ra,0xfffff
    800045ec:	e8a080e7          	jalr	-374(ra) # 80003472 <bread>
  log.lh.n = lh->n;
    800045f0:	4d3c                	lw	a5,88(a0)
    800045f2:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800045f4:	02f05563          	blez	a5,8000461e <initlog+0x74>
    800045f8:	05c50713          	addi	a4,a0,92
    800045fc:	0001e697          	auipc	a3,0x1e
    80004600:	5d468693          	addi	a3,a3,1492 # 80022bd0 <log+0x30>
    80004604:	37fd                	addiw	a5,a5,-1
    80004606:	1782                	slli	a5,a5,0x20
    80004608:	9381                	srli	a5,a5,0x20
    8000460a:	078a                	slli	a5,a5,0x2
    8000460c:	06050613          	addi	a2,a0,96
    80004610:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80004612:	4310                	lw	a2,0(a4)
    80004614:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80004616:	0711                	addi	a4,a4,4
    80004618:	0691                	addi	a3,a3,4
    8000461a:	fef71ce3          	bne	a4,a5,80004612 <initlog+0x68>
  brelse(buf);
    8000461e:	fffff097          	auipc	ra,0xfffff
    80004622:	f84080e7          	jalr	-124(ra) # 800035a2 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004626:	4505                	li	a0,1
    80004628:	00000097          	auipc	ra,0x0
    8000462c:	ebe080e7          	jalr	-322(ra) # 800044e6 <install_trans>
  log.lh.n = 0;
    80004630:	0001e797          	auipc	a5,0x1e
    80004634:	5807ae23          	sw	zero,1436(a5) # 80022bcc <log+0x2c>
  write_head(); // clear the log
    80004638:	00000097          	auipc	ra,0x0
    8000463c:	e34080e7          	jalr	-460(ra) # 8000446c <write_head>
}
    80004640:	70a2                	ld	ra,40(sp)
    80004642:	7402                	ld	s0,32(sp)
    80004644:	64e2                	ld	s1,24(sp)
    80004646:	6942                	ld	s2,16(sp)
    80004648:	69a2                	ld	s3,8(sp)
    8000464a:	6145                	addi	sp,sp,48
    8000464c:	8082                	ret

000000008000464e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000464e:	1101                	addi	sp,sp,-32
    80004650:	ec06                	sd	ra,24(sp)
    80004652:	e822                	sd	s0,16(sp)
    80004654:	e426                	sd	s1,8(sp)
    80004656:	e04a                	sd	s2,0(sp)
    80004658:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000465a:	0001e517          	auipc	a0,0x1e
    8000465e:	54650513          	addi	a0,a0,1350 # 80022ba0 <log>
    80004662:	ffffc097          	auipc	ra,0xffffc
    80004666:	588080e7          	jalr	1416(ra) # 80000bea <acquire>
  while(1){
    if(log.committing){
    8000466a:	0001e497          	auipc	s1,0x1e
    8000466e:	53648493          	addi	s1,s1,1334 # 80022ba0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004672:	4979                	li	s2,30
    80004674:	a039                	j	80004682 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004676:	85a6                	mv	a1,s1
    80004678:	8526                	mv	a0,s1
    8000467a:	ffffe097          	auipc	ra,0xffffe
    8000467e:	b4e080e7          	jalr	-1202(ra) # 800021c8 <sleep>
    if(log.committing){
    80004682:	50dc                	lw	a5,36(s1)
    80004684:	fbed                	bnez	a5,80004676 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004686:	509c                	lw	a5,32(s1)
    80004688:	0017871b          	addiw	a4,a5,1
    8000468c:	0007069b          	sext.w	a3,a4
    80004690:	0027179b          	slliw	a5,a4,0x2
    80004694:	9fb9                	addw	a5,a5,a4
    80004696:	0017979b          	slliw	a5,a5,0x1
    8000469a:	54d8                	lw	a4,44(s1)
    8000469c:	9fb9                	addw	a5,a5,a4
    8000469e:	00f95963          	bge	s2,a5,800046b0 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800046a2:	85a6                	mv	a1,s1
    800046a4:	8526                	mv	a0,s1
    800046a6:	ffffe097          	auipc	ra,0xffffe
    800046aa:	b22080e7          	jalr	-1246(ra) # 800021c8 <sleep>
    800046ae:	bfd1                	j	80004682 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800046b0:	0001e517          	auipc	a0,0x1e
    800046b4:	4f050513          	addi	a0,a0,1264 # 80022ba0 <log>
    800046b8:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800046ba:	ffffc097          	auipc	ra,0xffffc
    800046be:	5e4080e7          	jalr	1508(ra) # 80000c9e <release>
      break;
    }
  }
}
    800046c2:	60e2                	ld	ra,24(sp)
    800046c4:	6442                	ld	s0,16(sp)
    800046c6:	64a2                	ld	s1,8(sp)
    800046c8:	6902                	ld	s2,0(sp)
    800046ca:	6105                	addi	sp,sp,32
    800046cc:	8082                	ret

00000000800046ce <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800046ce:	7139                	addi	sp,sp,-64
    800046d0:	fc06                	sd	ra,56(sp)
    800046d2:	f822                	sd	s0,48(sp)
    800046d4:	f426                	sd	s1,40(sp)
    800046d6:	f04a                	sd	s2,32(sp)
    800046d8:	ec4e                	sd	s3,24(sp)
    800046da:	e852                	sd	s4,16(sp)
    800046dc:	e456                	sd	s5,8(sp)
    800046de:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800046e0:	0001e497          	auipc	s1,0x1e
    800046e4:	4c048493          	addi	s1,s1,1216 # 80022ba0 <log>
    800046e8:	8526                	mv	a0,s1
    800046ea:	ffffc097          	auipc	ra,0xffffc
    800046ee:	500080e7          	jalr	1280(ra) # 80000bea <acquire>
  log.outstanding -= 1;
    800046f2:	509c                	lw	a5,32(s1)
    800046f4:	37fd                	addiw	a5,a5,-1
    800046f6:	0007891b          	sext.w	s2,a5
    800046fa:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800046fc:	50dc                	lw	a5,36(s1)
    800046fe:	efb9                	bnez	a5,8000475c <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004700:	06091663          	bnez	s2,8000476c <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    80004704:	0001e497          	auipc	s1,0x1e
    80004708:	49c48493          	addi	s1,s1,1180 # 80022ba0 <log>
    8000470c:	4785                	li	a5,1
    8000470e:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004710:	8526                	mv	a0,s1
    80004712:	ffffc097          	auipc	ra,0xffffc
    80004716:	58c080e7          	jalr	1420(ra) # 80000c9e <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000471a:	54dc                	lw	a5,44(s1)
    8000471c:	06f04763          	bgtz	a5,8000478a <end_op+0xbc>
    acquire(&log.lock);
    80004720:	0001e497          	auipc	s1,0x1e
    80004724:	48048493          	addi	s1,s1,1152 # 80022ba0 <log>
    80004728:	8526                	mv	a0,s1
    8000472a:	ffffc097          	auipc	ra,0xffffc
    8000472e:	4c0080e7          	jalr	1216(ra) # 80000bea <acquire>
    log.committing = 0;
    80004732:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004736:	8526                	mv	a0,s1
    80004738:	ffffe097          	auipc	ra,0xffffe
    8000473c:	c40080e7          	jalr	-960(ra) # 80002378 <wakeup>
    release(&log.lock);
    80004740:	8526                	mv	a0,s1
    80004742:	ffffc097          	auipc	ra,0xffffc
    80004746:	55c080e7          	jalr	1372(ra) # 80000c9e <release>
}
    8000474a:	70e2                	ld	ra,56(sp)
    8000474c:	7442                	ld	s0,48(sp)
    8000474e:	74a2                	ld	s1,40(sp)
    80004750:	7902                	ld	s2,32(sp)
    80004752:	69e2                	ld	s3,24(sp)
    80004754:	6a42                	ld	s4,16(sp)
    80004756:	6aa2                	ld	s5,8(sp)
    80004758:	6121                	addi	sp,sp,64
    8000475a:	8082                	ret
    panic("log.committing");
    8000475c:	00004517          	auipc	a0,0x4
    80004760:	09450513          	addi	a0,a0,148 # 800087f0 <syscallnum+0x1a0>
    80004764:	ffffc097          	auipc	ra,0xffffc
    80004768:	de0080e7          	jalr	-544(ra) # 80000544 <panic>
    wakeup(&log);
    8000476c:	0001e497          	auipc	s1,0x1e
    80004770:	43448493          	addi	s1,s1,1076 # 80022ba0 <log>
    80004774:	8526                	mv	a0,s1
    80004776:	ffffe097          	auipc	ra,0xffffe
    8000477a:	c02080e7          	jalr	-1022(ra) # 80002378 <wakeup>
  release(&log.lock);
    8000477e:	8526                	mv	a0,s1
    80004780:	ffffc097          	auipc	ra,0xffffc
    80004784:	51e080e7          	jalr	1310(ra) # 80000c9e <release>
  if(do_commit){
    80004788:	b7c9                	j	8000474a <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000478a:	0001ea97          	auipc	s5,0x1e
    8000478e:	446a8a93          	addi	s5,s5,1094 # 80022bd0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004792:	0001ea17          	auipc	s4,0x1e
    80004796:	40ea0a13          	addi	s4,s4,1038 # 80022ba0 <log>
    8000479a:	018a2583          	lw	a1,24(s4)
    8000479e:	012585bb          	addw	a1,a1,s2
    800047a2:	2585                	addiw	a1,a1,1
    800047a4:	028a2503          	lw	a0,40(s4)
    800047a8:	fffff097          	auipc	ra,0xfffff
    800047ac:	cca080e7          	jalr	-822(ra) # 80003472 <bread>
    800047b0:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800047b2:	000aa583          	lw	a1,0(s5)
    800047b6:	028a2503          	lw	a0,40(s4)
    800047ba:	fffff097          	auipc	ra,0xfffff
    800047be:	cb8080e7          	jalr	-840(ra) # 80003472 <bread>
    800047c2:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800047c4:	40000613          	li	a2,1024
    800047c8:	05850593          	addi	a1,a0,88
    800047cc:	05848513          	addi	a0,s1,88
    800047d0:	ffffc097          	auipc	ra,0xffffc
    800047d4:	576080e7          	jalr	1398(ra) # 80000d46 <memmove>
    bwrite(to);  // write the log
    800047d8:	8526                	mv	a0,s1
    800047da:	fffff097          	auipc	ra,0xfffff
    800047de:	d8a080e7          	jalr	-630(ra) # 80003564 <bwrite>
    brelse(from);
    800047e2:	854e                	mv	a0,s3
    800047e4:	fffff097          	auipc	ra,0xfffff
    800047e8:	dbe080e7          	jalr	-578(ra) # 800035a2 <brelse>
    brelse(to);
    800047ec:	8526                	mv	a0,s1
    800047ee:	fffff097          	auipc	ra,0xfffff
    800047f2:	db4080e7          	jalr	-588(ra) # 800035a2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800047f6:	2905                	addiw	s2,s2,1
    800047f8:	0a91                	addi	s5,s5,4
    800047fa:	02ca2783          	lw	a5,44(s4)
    800047fe:	f8f94ee3          	blt	s2,a5,8000479a <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004802:	00000097          	auipc	ra,0x0
    80004806:	c6a080e7          	jalr	-918(ra) # 8000446c <write_head>
    install_trans(0); // Now install writes to home locations
    8000480a:	4501                	li	a0,0
    8000480c:	00000097          	auipc	ra,0x0
    80004810:	cda080e7          	jalr	-806(ra) # 800044e6 <install_trans>
    log.lh.n = 0;
    80004814:	0001e797          	auipc	a5,0x1e
    80004818:	3a07ac23          	sw	zero,952(a5) # 80022bcc <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000481c:	00000097          	auipc	ra,0x0
    80004820:	c50080e7          	jalr	-944(ra) # 8000446c <write_head>
    80004824:	bdf5                	j	80004720 <end_op+0x52>

0000000080004826 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004826:	1101                	addi	sp,sp,-32
    80004828:	ec06                	sd	ra,24(sp)
    8000482a:	e822                	sd	s0,16(sp)
    8000482c:	e426                	sd	s1,8(sp)
    8000482e:	e04a                	sd	s2,0(sp)
    80004830:	1000                	addi	s0,sp,32
    80004832:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004834:	0001e917          	auipc	s2,0x1e
    80004838:	36c90913          	addi	s2,s2,876 # 80022ba0 <log>
    8000483c:	854a                	mv	a0,s2
    8000483e:	ffffc097          	auipc	ra,0xffffc
    80004842:	3ac080e7          	jalr	940(ra) # 80000bea <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004846:	02c92603          	lw	a2,44(s2)
    8000484a:	47f5                	li	a5,29
    8000484c:	06c7c563          	blt	a5,a2,800048b6 <log_write+0x90>
    80004850:	0001e797          	auipc	a5,0x1e
    80004854:	36c7a783          	lw	a5,876(a5) # 80022bbc <log+0x1c>
    80004858:	37fd                	addiw	a5,a5,-1
    8000485a:	04f65e63          	bge	a2,a5,800048b6 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000485e:	0001e797          	auipc	a5,0x1e
    80004862:	3627a783          	lw	a5,866(a5) # 80022bc0 <log+0x20>
    80004866:	06f05063          	blez	a5,800048c6 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000486a:	4781                	li	a5,0
    8000486c:	06c05563          	blez	a2,800048d6 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004870:	44cc                	lw	a1,12(s1)
    80004872:	0001e717          	auipc	a4,0x1e
    80004876:	35e70713          	addi	a4,a4,862 # 80022bd0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000487a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000487c:	4314                	lw	a3,0(a4)
    8000487e:	04b68c63          	beq	a3,a1,800048d6 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004882:	2785                	addiw	a5,a5,1
    80004884:	0711                	addi	a4,a4,4
    80004886:	fef61be3          	bne	a2,a5,8000487c <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000488a:	0621                	addi	a2,a2,8
    8000488c:	060a                	slli	a2,a2,0x2
    8000488e:	0001e797          	auipc	a5,0x1e
    80004892:	31278793          	addi	a5,a5,786 # 80022ba0 <log>
    80004896:	963e                	add	a2,a2,a5
    80004898:	44dc                	lw	a5,12(s1)
    8000489a:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000489c:	8526                	mv	a0,s1
    8000489e:	fffff097          	auipc	ra,0xfffff
    800048a2:	da2080e7          	jalr	-606(ra) # 80003640 <bpin>
    log.lh.n++;
    800048a6:	0001e717          	auipc	a4,0x1e
    800048aa:	2fa70713          	addi	a4,a4,762 # 80022ba0 <log>
    800048ae:	575c                	lw	a5,44(a4)
    800048b0:	2785                	addiw	a5,a5,1
    800048b2:	d75c                	sw	a5,44(a4)
    800048b4:	a835                	j	800048f0 <log_write+0xca>
    panic("too big a transaction");
    800048b6:	00004517          	auipc	a0,0x4
    800048ba:	f4a50513          	addi	a0,a0,-182 # 80008800 <syscallnum+0x1b0>
    800048be:	ffffc097          	auipc	ra,0xffffc
    800048c2:	c86080e7          	jalr	-890(ra) # 80000544 <panic>
    panic("log_write outside of trans");
    800048c6:	00004517          	auipc	a0,0x4
    800048ca:	f5250513          	addi	a0,a0,-174 # 80008818 <syscallnum+0x1c8>
    800048ce:	ffffc097          	auipc	ra,0xffffc
    800048d2:	c76080e7          	jalr	-906(ra) # 80000544 <panic>
  log.lh.block[i] = b->blockno;
    800048d6:	00878713          	addi	a4,a5,8
    800048da:	00271693          	slli	a3,a4,0x2
    800048de:	0001e717          	auipc	a4,0x1e
    800048e2:	2c270713          	addi	a4,a4,706 # 80022ba0 <log>
    800048e6:	9736                	add	a4,a4,a3
    800048e8:	44d4                	lw	a3,12(s1)
    800048ea:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800048ec:	faf608e3          	beq	a2,a5,8000489c <log_write+0x76>
  }
  release(&log.lock);
    800048f0:	0001e517          	auipc	a0,0x1e
    800048f4:	2b050513          	addi	a0,a0,688 # 80022ba0 <log>
    800048f8:	ffffc097          	auipc	ra,0xffffc
    800048fc:	3a6080e7          	jalr	934(ra) # 80000c9e <release>
}
    80004900:	60e2                	ld	ra,24(sp)
    80004902:	6442                	ld	s0,16(sp)
    80004904:	64a2                	ld	s1,8(sp)
    80004906:	6902                	ld	s2,0(sp)
    80004908:	6105                	addi	sp,sp,32
    8000490a:	8082                	ret

000000008000490c <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000490c:	1101                	addi	sp,sp,-32
    8000490e:	ec06                	sd	ra,24(sp)
    80004910:	e822                	sd	s0,16(sp)
    80004912:	e426                	sd	s1,8(sp)
    80004914:	e04a                	sd	s2,0(sp)
    80004916:	1000                	addi	s0,sp,32
    80004918:	84aa                	mv	s1,a0
    8000491a:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000491c:	00004597          	auipc	a1,0x4
    80004920:	f1c58593          	addi	a1,a1,-228 # 80008838 <syscallnum+0x1e8>
    80004924:	0521                	addi	a0,a0,8
    80004926:	ffffc097          	auipc	ra,0xffffc
    8000492a:	234080e7          	jalr	564(ra) # 80000b5a <initlock>
  lk->name = name;
    8000492e:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004932:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004936:	0204a423          	sw	zero,40(s1)
}
    8000493a:	60e2                	ld	ra,24(sp)
    8000493c:	6442                	ld	s0,16(sp)
    8000493e:	64a2                	ld	s1,8(sp)
    80004940:	6902                	ld	s2,0(sp)
    80004942:	6105                	addi	sp,sp,32
    80004944:	8082                	ret

0000000080004946 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
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
    8000495e:	290080e7          	jalr	656(ra) # 80000bea <acquire>
  while (lk->locked) {
    80004962:	409c                	lw	a5,0(s1)
    80004964:	cb89                	beqz	a5,80004976 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004966:	85ca                	mv	a1,s2
    80004968:	8526                	mv	a0,s1
    8000496a:	ffffe097          	auipc	ra,0xffffe
    8000496e:	85e080e7          	jalr	-1954(ra) # 800021c8 <sleep>
  while (lk->locked) {
    80004972:	409c                	lw	a5,0(s1)
    80004974:	fbed                	bnez	a5,80004966 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004976:	4785                	li	a5,1
    80004978:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000497a:	ffffd097          	auipc	ra,0xffffd
    8000497e:	04c080e7          	jalr	76(ra) # 800019c6 <myproc>
    80004982:	591c                	lw	a5,48(a0)
    80004984:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004986:	854a                	mv	a0,s2
    80004988:	ffffc097          	auipc	ra,0xffffc
    8000498c:	316080e7          	jalr	790(ra) # 80000c9e <release>
}
    80004990:	60e2                	ld	ra,24(sp)
    80004992:	6442                	ld	s0,16(sp)
    80004994:	64a2                	ld	s1,8(sp)
    80004996:	6902                	ld	s2,0(sp)
    80004998:	6105                	addi	sp,sp,32
    8000499a:	8082                	ret

000000008000499c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000499c:	1101                	addi	sp,sp,-32
    8000499e:	ec06                	sd	ra,24(sp)
    800049a0:	e822                	sd	s0,16(sp)
    800049a2:	e426                	sd	s1,8(sp)
    800049a4:	e04a                	sd	s2,0(sp)
    800049a6:	1000                	addi	s0,sp,32
    800049a8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800049aa:	00850913          	addi	s2,a0,8
    800049ae:	854a                	mv	a0,s2
    800049b0:	ffffc097          	auipc	ra,0xffffc
    800049b4:	23a080e7          	jalr	570(ra) # 80000bea <acquire>
  lk->locked = 0;
    800049b8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800049bc:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800049c0:	8526                	mv	a0,s1
    800049c2:	ffffe097          	auipc	ra,0xffffe
    800049c6:	9b6080e7          	jalr	-1610(ra) # 80002378 <wakeup>
  release(&lk->lk);
    800049ca:	854a                	mv	a0,s2
    800049cc:	ffffc097          	auipc	ra,0xffffc
    800049d0:	2d2080e7          	jalr	722(ra) # 80000c9e <release>
}
    800049d4:	60e2                	ld	ra,24(sp)
    800049d6:	6442                	ld	s0,16(sp)
    800049d8:	64a2                	ld	s1,8(sp)
    800049da:	6902                	ld	s2,0(sp)
    800049dc:	6105                	addi	sp,sp,32
    800049de:	8082                	ret

00000000800049e0 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800049e0:	7179                	addi	sp,sp,-48
    800049e2:	f406                	sd	ra,40(sp)
    800049e4:	f022                	sd	s0,32(sp)
    800049e6:	ec26                	sd	s1,24(sp)
    800049e8:	e84a                	sd	s2,16(sp)
    800049ea:	e44e                	sd	s3,8(sp)
    800049ec:	1800                	addi	s0,sp,48
    800049ee:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800049f0:	00850913          	addi	s2,a0,8
    800049f4:	854a                	mv	a0,s2
    800049f6:	ffffc097          	auipc	ra,0xffffc
    800049fa:	1f4080e7          	jalr	500(ra) # 80000bea <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800049fe:	409c                	lw	a5,0(s1)
    80004a00:	ef99                	bnez	a5,80004a1e <holdingsleep+0x3e>
    80004a02:	4481                	li	s1,0
  release(&lk->lk);
    80004a04:	854a                	mv	a0,s2
    80004a06:	ffffc097          	auipc	ra,0xffffc
    80004a0a:	298080e7          	jalr	664(ra) # 80000c9e <release>
  return r;
}
    80004a0e:	8526                	mv	a0,s1
    80004a10:	70a2                	ld	ra,40(sp)
    80004a12:	7402                	ld	s0,32(sp)
    80004a14:	64e2                	ld	s1,24(sp)
    80004a16:	6942                	ld	s2,16(sp)
    80004a18:	69a2                	ld	s3,8(sp)
    80004a1a:	6145                	addi	sp,sp,48
    80004a1c:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004a1e:	0284a983          	lw	s3,40(s1)
    80004a22:	ffffd097          	auipc	ra,0xffffd
    80004a26:	fa4080e7          	jalr	-92(ra) # 800019c6 <myproc>
    80004a2a:	5904                	lw	s1,48(a0)
    80004a2c:	413484b3          	sub	s1,s1,s3
    80004a30:	0014b493          	seqz	s1,s1
    80004a34:	bfc1                	j	80004a04 <holdingsleep+0x24>

0000000080004a36 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004a36:	1141                	addi	sp,sp,-16
    80004a38:	e406                	sd	ra,8(sp)
    80004a3a:	e022                	sd	s0,0(sp)
    80004a3c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004a3e:	00004597          	auipc	a1,0x4
    80004a42:	e0a58593          	addi	a1,a1,-502 # 80008848 <syscallnum+0x1f8>
    80004a46:	0001e517          	auipc	a0,0x1e
    80004a4a:	2a250513          	addi	a0,a0,674 # 80022ce8 <ftable>
    80004a4e:	ffffc097          	auipc	ra,0xffffc
    80004a52:	10c080e7          	jalr	268(ra) # 80000b5a <initlock>
}
    80004a56:	60a2                	ld	ra,8(sp)
    80004a58:	6402                	ld	s0,0(sp)
    80004a5a:	0141                	addi	sp,sp,16
    80004a5c:	8082                	ret

0000000080004a5e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004a5e:	1101                	addi	sp,sp,-32
    80004a60:	ec06                	sd	ra,24(sp)
    80004a62:	e822                	sd	s0,16(sp)
    80004a64:	e426                	sd	s1,8(sp)
    80004a66:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004a68:	0001e517          	auipc	a0,0x1e
    80004a6c:	28050513          	addi	a0,a0,640 # 80022ce8 <ftable>
    80004a70:	ffffc097          	auipc	ra,0xffffc
    80004a74:	17a080e7          	jalr	378(ra) # 80000bea <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a78:	0001e497          	auipc	s1,0x1e
    80004a7c:	28848493          	addi	s1,s1,648 # 80022d00 <ftable+0x18>
    80004a80:	0001f717          	auipc	a4,0x1f
    80004a84:	22070713          	addi	a4,a4,544 # 80023ca0 <disk>
    if(f->ref == 0){
    80004a88:	40dc                	lw	a5,4(s1)
    80004a8a:	cf99                	beqz	a5,80004aa8 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a8c:	02848493          	addi	s1,s1,40
    80004a90:	fee49ce3          	bne	s1,a4,80004a88 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004a94:	0001e517          	auipc	a0,0x1e
    80004a98:	25450513          	addi	a0,a0,596 # 80022ce8 <ftable>
    80004a9c:	ffffc097          	auipc	ra,0xffffc
    80004aa0:	202080e7          	jalr	514(ra) # 80000c9e <release>
  return 0;
    80004aa4:	4481                	li	s1,0
    80004aa6:	a819                	j	80004abc <filealloc+0x5e>
      f->ref = 1;
    80004aa8:	4785                	li	a5,1
    80004aaa:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004aac:	0001e517          	auipc	a0,0x1e
    80004ab0:	23c50513          	addi	a0,a0,572 # 80022ce8 <ftable>
    80004ab4:	ffffc097          	auipc	ra,0xffffc
    80004ab8:	1ea080e7          	jalr	490(ra) # 80000c9e <release>
}
    80004abc:	8526                	mv	a0,s1
    80004abe:	60e2                	ld	ra,24(sp)
    80004ac0:	6442                	ld	s0,16(sp)
    80004ac2:	64a2                	ld	s1,8(sp)
    80004ac4:	6105                	addi	sp,sp,32
    80004ac6:	8082                	ret

0000000080004ac8 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004ac8:	1101                	addi	sp,sp,-32
    80004aca:	ec06                	sd	ra,24(sp)
    80004acc:	e822                	sd	s0,16(sp)
    80004ace:	e426                	sd	s1,8(sp)
    80004ad0:	1000                	addi	s0,sp,32
    80004ad2:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004ad4:	0001e517          	auipc	a0,0x1e
    80004ad8:	21450513          	addi	a0,a0,532 # 80022ce8 <ftable>
    80004adc:	ffffc097          	auipc	ra,0xffffc
    80004ae0:	10e080e7          	jalr	270(ra) # 80000bea <acquire>
  if(f->ref < 1)
    80004ae4:	40dc                	lw	a5,4(s1)
    80004ae6:	02f05263          	blez	a5,80004b0a <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004aea:	2785                	addiw	a5,a5,1
    80004aec:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004aee:	0001e517          	auipc	a0,0x1e
    80004af2:	1fa50513          	addi	a0,a0,506 # 80022ce8 <ftable>
    80004af6:	ffffc097          	auipc	ra,0xffffc
    80004afa:	1a8080e7          	jalr	424(ra) # 80000c9e <release>
  return f;
}
    80004afe:	8526                	mv	a0,s1
    80004b00:	60e2                	ld	ra,24(sp)
    80004b02:	6442                	ld	s0,16(sp)
    80004b04:	64a2                	ld	s1,8(sp)
    80004b06:	6105                	addi	sp,sp,32
    80004b08:	8082                	ret
    panic("filedup");
    80004b0a:	00004517          	auipc	a0,0x4
    80004b0e:	d4650513          	addi	a0,a0,-698 # 80008850 <syscallnum+0x200>
    80004b12:	ffffc097          	auipc	ra,0xffffc
    80004b16:	a32080e7          	jalr	-1486(ra) # 80000544 <panic>

0000000080004b1a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004b1a:	7139                	addi	sp,sp,-64
    80004b1c:	fc06                	sd	ra,56(sp)
    80004b1e:	f822                	sd	s0,48(sp)
    80004b20:	f426                	sd	s1,40(sp)
    80004b22:	f04a                	sd	s2,32(sp)
    80004b24:	ec4e                	sd	s3,24(sp)
    80004b26:	e852                	sd	s4,16(sp)
    80004b28:	e456                	sd	s5,8(sp)
    80004b2a:	0080                	addi	s0,sp,64
    80004b2c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004b2e:	0001e517          	auipc	a0,0x1e
    80004b32:	1ba50513          	addi	a0,a0,442 # 80022ce8 <ftable>
    80004b36:	ffffc097          	auipc	ra,0xffffc
    80004b3a:	0b4080e7          	jalr	180(ra) # 80000bea <acquire>
  if(f->ref < 1)
    80004b3e:	40dc                	lw	a5,4(s1)
    80004b40:	06f05163          	blez	a5,80004ba2 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004b44:	37fd                	addiw	a5,a5,-1
    80004b46:	0007871b          	sext.w	a4,a5
    80004b4a:	c0dc                	sw	a5,4(s1)
    80004b4c:	06e04363          	bgtz	a4,80004bb2 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004b50:	0004a903          	lw	s2,0(s1)
    80004b54:	0094ca83          	lbu	s5,9(s1)
    80004b58:	0104ba03          	ld	s4,16(s1)
    80004b5c:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004b60:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004b64:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004b68:	0001e517          	auipc	a0,0x1e
    80004b6c:	18050513          	addi	a0,a0,384 # 80022ce8 <ftable>
    80004b70:	ffffc097          	auipc	ra,0xffffc
    80004b74:	12e080e7          	jalr	302(ra) # 80000c9e <release>

  if(ff.type == FD_PIPE){
    80004b78:	4785                	li	a5,1
    80004b7a:	04f90d63          	beq	s2,a5,80004bd4 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004b7e:	3979                	addiw	s2,s2,-2
    80004b80:	4785                	li	a5,1
    80004b82:	0527e063          	bltu	a5,s2,80004bc2 <fileclose+0xa8>
    begin_op();
    80004b86:	00000097          	auipc	ra,0x0
    80004b8a:	ac8080e7          	jalr	-1336(ra) # 8000464e <begin_op>
    iput(ff.ip);
    80004b8e:	854e                	mv	a0,s3
    80004b90:	fffff097          	auipc	ra,0xfffff
    80004b94:	2b6080e7          	jalr	694(ra) # 80003e46 <iput>
    end_op();
    80004b98:	00000097          	auipc	ra,0x0
    80004b9c:	b36080e7          	jalr	-1226(ra) # 800046ce <end_op>
    80004ba0:	a00d                	j	80004bc2 <fileclose+0xa8>
    panic("fileclose");
    80004ba2:	00004517          	auipc	a0,0x4
    80004ba6:	cb650513          	addi	a0,a0,-842 # 80008858 <syscallnum+0x208>
    80004baa:	ffffc097          	auipc	ra,0xffffc
    80004bae:	99a080e7          	jalr	-1638(ra) # 80000544 <panic>
    release(&ftable.lock);
    80004bb2:	0001e517          	auipc	a0,0x1e
    80004bb6:	13650513          	addi	a0,a0,310 # 80022ce8 <ftable>
    80004bba:	ffffc097          	auipc	ra,0xffffc
    80004bbe:	0e4080e7          	jalr	228(ra) # 80000c9e <release>
  }
}
    80004bc2:	70e2                	ld	ra,56(sp)
    80004bc4:	7442                	ld	s0,48(sp)
    80004bc6:	74a2                	ld	s1,40(sp)
    80004bc8:	7902                	ld	s2,32(sp)
    80004bca:	69e2                	ld	s3,24(sp)
    80004bcc:	6a42                	ld	s4,16(sp)
    80004bce:	6aa2                	ld	s5,8(sp)
    80004bd0:	6121                	addi	sp,sp,64
    80004bd2:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004bd4:	85d6                	mv	a1,s5
    80004bd6:	8552                	mv	a0,s4
    80004bd8:	00000097          	auipc	ra,0x0
    80004bdc:	34c080e7          	jalr	844(ra) # 80004f24 <pipeclose>
    80004be0:	b7cd                	j	80004bc2 <fileclose+0xa8>

0000000080004be2 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004be2:	715d                	addi	sp,sp,-80
    80004be4:	e486                	sd	ra,72(sp)
    80004be6:	e0a2                	sd	s0,64(sp)
    80004be8:	fc26                	sd	s1,56(sp)
    80004bea:	f84a                	sd	s2,48(sp)
    80004bec:	f44e                	sd	s3,40(sp)
    80004bee:	0880                	addi	s0,sp,80
    80004bf0:	84aa                	mv	s1,a0
    80004bf2:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004bf4:	ffffd097          	auipc	ra,0xffffd
    80004bf8:	dd2080e7          	jalr	-558(ra) # 800019c6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004bfc:	409c                	lw	a5,0(s1)
    80004bfe:	37f9                	addiw	a5,a5,-2
    80004c00:	4705                	li	a4,1
    80004c02:	04f76763          	bltu	a4,a5,80004c50 <filestat+0x6e>
    80004c06:	892a                	mv	s2,a0
    ilock(f->ip);
    80004c08:	6c88                	ld	a0,24(s1)
    80004c0a:	fffff097          	auipc	ra,0xfffff
    80004c0e:	082080e7          	jalr	130(ra) # 80003c8c <ilock>
    stati(f->ip, &st);
    80004c12:	fb840593          	addi	a1,s0,-72
    80004c16:	6c88                	ld	a0,24(s1)
    80004c18:	fffff097          	auipc	ra,0xfffff
    80004c1c:	2fe080e7          	jalr	766(ra) # 80003f16 <stati>
    iunlock(f->ip);
    80004c20:	6c88                	ld	a0,24(s1)
    80004c22:	fffff097          	auipc	ra,0xfffff
    80004c26:	12c080e7          	jalr	300(ra) # 80003d4e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004c2a:	46e1                	li	a3,24
    80004c2c:	fb840613          	addi	a2,s0,-72
    80004c30:	85ce                	mv	a1,s3
    80004c32:	05093503          	ld	a0,80(s2)
    80004c36:	ffffd097          	auipc	ra,0xffffd
    80004c3a:	a4e080e7          	jalr	-1458(ra) # 80001684 <copyout>
    80004c3e:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004c42:	60a6                	ld	ra,72(sp)
    80004c44:	6406                	ld	s0,64(sp)
    80004c46:	74e2                	ld	s1,56(sp)
    80004c48:	7942                	ld	s2,48(sp)
    80004c4a:	79a2                	ld	s3,40(sp)
    80004c4c:	6161                	addi	sp,sp,80
    80004c4e:	8082                	ret
  return -1;
    80004c50:	557d                	li	a0,-1
    80004c52:	bfc5                	j	80004c42 <filestat+0x60>

0000000080004c54 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004c54:	7179                	addi	sp,sp,-48
    80004c56:	f406                	sd	ra,40(sp)
    80004c58:	f022                	sd	s0,32(sp)
    80004c5a:	ec26                	sd	s1,24(sp)
    80004c5c:	e84a                	sd	s2,16(sp)
    80004c5e:	e44e                	sd	s3,8(sp)
    80004c60:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004c62:	00854783          	lbu	a5,8(a0)
    80004c66:	c3d5                	beqz	a5,80004d0a <fileread+0xb6>
    80004c68:	84aa                	mv	s1,a0
    80004c6a:	89ae                	mv	s3,a1
    80004c6c:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004c6e:	411c                	lw	a5,0(a0)
    80004c70:	4705                	li	a4,1
    80004c72:	04e78963          	beq	a5,a4,80004cc4 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004c76:	470d                	li	a4,3
    80004c78:	04e78d63          	beq	a5,a4,80004cd2 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c7c:	4709                	li	a4,2
    80004c7e:	06e79e63          	bne	a5,a4,80004cfa <fileread+0xa6>
    ilock(f->ip);
    80004c82:	6d08                	ld	a0,24(a0)
    80004c84:	fffff097          	auipc	ra,0xfffff
    80004c88:	008080e7          	jalr	8(ra) # 80003c8c <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004c8c:	874a                	mv	a4,s2
    80004c8e:	5094                	lw	a3,32(s1)
    80004c90:	864e                	mv	a2,s3
    80004c92:	4585                	li	a1,1
    80004c94:	6c88                	ld	a0,24(s1)
    80004c96:	fffff097          	auipc	ra,0xfffff
    80004c9a:	2aa080e7          	jalr	682(ra) # 80003f40 <readi>
    80004c9e:	892a                	mv	s2,a0
    80004ca0:	00a05563          	blez	a0,80004caa <fileread+0x56>
      f->off += r;
    80004ca4:	509c                	lw	a5,32(s1)
    80004ca6:	9fa9                	addw	a5,a5,a0
    80004ca8:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004caa:	6c88                	ld	a0,24(s1)
    80004cac:	fffff097          	auipc	ra,0xfffff
    80004cb0:	0a2080e7          	jalr	162(ra) # 80003d4e <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004cb4:	854a                	mv	a0,s2
    80004cb6:	70a2                	ld	ra,40(sp)
    80004cb8:	7402                	ld	s0,32(sp)
    80004cba:	64e2                	ld	s1,24(sp)
    80004cbc:	6942                	ld	s2,16(sp)
    80004cbe:	69a2                	ld	s3,8(sp)
    80004cc0:	6145                	addi	sp,sp,48
    80004cc2:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004cc4:	6908                	ld	a0,16(a0)
    80004cc6:	00000097          	auipc	ra,0x0
    80004cca:	3ce080e7          	jalr	974(ra) # 80005094 <piperead>
    80004cce:	892a                	mv	s2,a0
    80004cd0:	b7d5                	j	80004cb4 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004cd2:	02451783          	lh	a5,36(a0)
    80004cd6:	03079693          	slli	a3,a5,0x30
    80004cda:	92c1                	srli	a3,a3,0x30
    80004cdc:	4725                	li	a4,9
    80004cde:	02d76863          	bltu	a4,a3,80004d0e <fileread+0xba>
    80004ce2:	0792                	slli	a5,a5,0x4
    80004ce4:	0001e717          	auipc	a4,0x1e
    80004ce8:	f6470713          	addi	a4,a4,-156 # 80022c48 <devsw>
    80004cec:	97ba                	add	a5,a5,a4
    80004cee:	639c                	ld	a5,0(a5)
    80004cf0:	c38d                	beqz	a5,80004d12 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004cf2:	4505                	li	a0,1
    80004cf4:	9782                	jalr	a5
    80004cf6:	892a                	mv	s2,a0
    80004cf8:	bf75                	j	80004cb4 <fileread+0x60>
    panic("fileread");
    80004cfa:	00004517          	auipc	a0,0x4
    80004cfe:	b6e50513          	addi	a0,a0,-1170 # 80008868 <syscallnum+0x218>
    80004d02:	ffffc097          	auipc	ra,0xffffc
    80004d06:	842080e7          	jalr	-1982(ra) # 80000544 <panic>
    return -1;
    80004d0a:	597d                	li	s2,-1
    80004d0c:	b765                	j	80004cb4 <fileread+0x60>
      return -1;
    80004d0e:	597d                	li	s2,-1
    80004d10:	b755                	j	80004cb4 <fileread+0x60>
    80004d12:	597d                	li	s2,-1
    80004d14:	b745                	j	80004cb4 <fileread+0x60>

0000000080004d16 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004d16:	715d                	addi	sp,sp,-80
    80004d18:	e486                	sd	ra,72(sp)
    80004d1a:	e0a2                	sd	s0,64(sp)
    80004d1c:	fc26                	sd	s1,56(sp)
    80004d1e:	f84a                	sd	s2,48(sp)
    80004d20:	f44e                	sd	s3,40(sp)
    80004d22:	f052                	sd	s4,32(sp)
    80004d24:	ec56                	sd	s5,24(sp)
    80004d26:	e85a                	sd	s6,16(sp)
    80004d28:	e45e                	sd	s7,8(sp)
    80004d2a:	e062                	sd	s8,0(sp)
    80004d2c:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004d2e:	00954783          	lbu	a5,9(a0)
    80004d32:	10078663          	beqz	a5,80004e3e <filewrite+0x128>
    80004d36:	892a                	mv	s2,a0
    80004d38:	8aae                	mv	s5,a1
    80004d3a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004d3c:	411c                	lw	a5,0(a0)
    80004d3e:	4705                	li	a4,1
    80004d40:	02e78263          	beq	a5,a4,80004d64 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004d44:	470d                	li	a4,3
    80004d46:	02e78663          	beq	a5,a4,80004d72 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004d4a:	4709                	li	a4,2
    80004d4c:	0ee79163          	bne	a5,a4,80004e2e <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004d50:	0ac05d63          	blez	a2,80004e0a <filewrite+0xf4>
    int i = 0;
    80004d54:	4981                	li	s3,0
    80004d56:	6b05                	lui	s6,0x1
    80004d58:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004d5c:	6b85                	lui	s7,0x1
    80004d5e:	c00b8b9b          	addiw	s7,s7,-1024
    80004d62:	a861                	j	80004dfa <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004d64:	6908                	ld	a0,16(a0)
    80004d66:	00000097          	auipc	ra,0x0
    80004d6a:	22e080e7          	jalr	558(ra) # 80004f94 <pipewrite>
    80004d6e:	8a2a                	mv	s4,a0
    80004d70:	a045                	j	80004e10 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004d72:	02451783          	lh	a5,36(a0)
    80004d76:	03079693          	slli	a3,a5,0x30
    80004d7a:	92c1                	srli	a3,a3,0x30
    80004d7c:	4725                	li	a4,9
    80004d7e:	0cd76263          	bltu	a4,a3,80004e42 <filewrite+0x12c>
    80004d82:	0792                	slli	a5,a5,0x4
    80004d84:	0001e717          	auipc	a4,0x1e
    80004d88:	ec470713          	addi	a4,a4,-316 # 80022c48 <devsw>
    80004d8c:	97ba                	add	a5,a5,a4
    80004d8e:	679c                	ld	a5,8(a5)
    80004d90:	cbdd                	beqz	a5,80004e46 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004d92:	4505                	li	a0,1
    80004d94:	9782                	jalr	a5
    80004d96:	8a2a                	mv	s4,a0
    80004d98:	a8a5                	j	80004e10 <filewrite+0xfa>
    80004d9a:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004d9e:	00000097          	auipc	ra,0x0
    80004da2:	8b0080e7          	jalr	-1872(ra) # 8000464e <begin_op>
      ilock(f->ip);
    80004da6:	01893503          	ld	a0,24(s2)
    80004daa:	fffff097          	auipc	ra,0xfffff
    80004dae:	ee2080e7          	jalr	-286(ra) # 80003c8c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004db2:	8762                	mv	a4,s8
    80004db4:	02092683          	lw	a3,32(s2)
    80004db8:	01598633          	add	a2,s3,s5
    80004dbc:	4585                	li	a1,1
    80004dbe:	01893503          	ld	a0,24(s2)
    80004dc2:	fffff097          	auipc	ra,0xfffff
    80004dc6:	276080e7          	jalr	630(ra) # 80004038 <writei>
    80004dca:	84aa                	mv	s1,a0
    80004dcc:	00a05763          	blez	a0,80004dda <filewrite+0xc4>
        f->off += r;
    80004dd0:	02092783          	lw	a5,32(s2)
    80004dd4:	9fa9                	addw	a5,a5,a0
    80004dd6:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004dda:	01893503          	ld	a0,24(s2)
    80004dde:	fffff097          	auipc	ra,0xfffff
    80004de2:	f70080e7          	jalr	-144(ra) # 80003d4e <iunlock>
      end_op();
    80004de6:	00000097          	auipc	ra,0x0
    80004dea:	8e8080e7          	jalr	-1816(ra) # 800046ce <end_op>

      if(r != n1){
    80004dee:	009c1f63          	bne	s8,s1,80004e0c <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004df2:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004df6:	0149db63          	bge	s3,s4,80004e0c <filewrite+0xf6>
      int n1 = n - i;
    80004dfa:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004dfe:	84be                	mv	s1,a5
    80004e00:	2781                	sext.w	a5,a5
    80004e02:	f8fb5ce3          	bge	s6,a5,80004d9a <filewrite+0x84>
    80004e06:	84de                	mv	s1,s7
    80004e08:	bf49                	j	80004d9a <filewrite+0x84>
    int i = 0;
    80004e0a:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004e0c:	013a1f63          	bne	s4,s3,80004e2a <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004e10:	8552                	mv	a0,s4
    80004e12:	60a6                	ld	ra,72(sp)
    80004e14:	6406                	ld	s0,64(sp)
    80004e16:	74e2                	ld	s1,56(sp)
    80004e18:	7942                	ld	s2,48(sp)
    80004e1a:	79a2                	ld	s3,40(sp)
    80004e1c:	7a02                	ld	s4,32(sp)
    80004e1e:	6ae2                	ld	s5,24(sp)
    80004e20:	6b42                	ld	s6,16(sp)
    80004e22:	6ba2                	ld	s7,8(sp)
    80004e24:	6c02                	ld	s8,0(sp)
    80004e26:	6161                	addi	sp,sp,80
    80004e28:	8082                	ret
    ret = (i == n ? n : -1);
    80004e2a:	5a7d                	li	s4,-1
    80004e2c:	b7d5                	j	80004e10 <filewrite+0xfa>
    panic("filewrite");
    80004e2e:	00004517          	auipc	a0,0x4
    80004e32:	a4a50513          	addi	a0,a0,-1462 # 80008878 <syscallnum+0x228>
    80004e36:	ffffb097          	auipc	ra,0xffffb
    80004e3a:	70e080e7          	jalr	1806(ra) # 80000544 <panic>
    return -1;
    80004e3e:	5a7d                	li	s4,-1
    80004e40:	bfc1                	j	80004e10 <filewrite+0xfa>
      return -1;
    80004e42:	5a7d                	li	s4,-1
    80004e44:	b7f1                	j	80004e10 <filewrite+0xfa>
    80004e46:	5a7d                	li	s4,-1
    80004e48:	b7e1                	j	80004e10 <filewrite+0xfa>

0000000080004e4a <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004e4a:	7179                	addi	sp,sp,-48
    80004e4c:	f406                	sd	ra,40(sp)
    80004e4e:	f022                	sd	s0,32(sp)
    80004e50:	ec26                	sd	s1,24(sp)
    80004e52:	e84a                	sd	s2,16(sp)
    80004e54:	e44e                	sd	s3,8(sp)
    80004e56:	e052                	sd	s4,0(sp)
    80004e58:	1800                	addi	s0,sp,48
    80004e5a:	84aa                	mv	s1,a0
    80004e5c:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004e5e:	0005b023          	sd	zero,0(a1)
    80004e62:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004e66:	00000097          	auipc	ra,0x0
    80004e6a:	bf8080e7          	jalr	-1032(ra) # 80004a5e <filealloc>
    80004e6e:	e088                	sd	a0,0(s1)
    80004e70:	c551                	beqz	a0,80004efc <pipealloc+0xb2>
    80004e72:	00000097          	auipc	ra,0x0
    80004e76:	bec080e7          	jalr	-1044(ra) # 80004a5e <filealloc>
    80004e7a:	00aa3023          	sd	a0,0(s4)
    80004e7e:	c92d                	beqz	a0,80004ef0 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004e80:	ffffc097          	auipc	ra,0xffffc
    80004e84:	c7a080e7          	jalr	-902(ra) # 80000afa <kalloc>
    80004e88:	892a                	mv	s2,a0
    80004e8a:	c125                	beqz	a0,80004eea <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004e8c:	4985                	li	s3,1
    80004e8e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004e92:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004e96:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004e9a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004e9e:	00003597          	auipc	a1,0x3
    80004ea2:	5e258593          	addi	a1,a1,1506 # 80008480 <states.1787+0x1b8>
    80004ea6:	ffffc097          	auipc	ra,0xffffc
    80004eaa:	cb4080e7          	jalr	-844(ra) # 80000b5a <initlock>
  (*f0)->type = FD_PIPE;
    80004eae:	609c                	ld	a5,0(s1)
    80004eb0:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004eb4:	609c                	ld	a5,0(s1)
    80004eb6:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004eba:	609c                	ld	a5,0(s1)
    80004ebc:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004ec0:	609c                	ld	a5,0(s1)
    80004ec2:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004ec6:	000a3783          	ld	a5,0(s4)
    80004eca:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004ece:	000a3783          	ld	a5,0(s4)
    80004ed2:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004ed6:	000a3783          	ld	a5,0(s4)
    80004eda:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004ede:	000a3783          	ld	a5,0(s4)
    80004ee2:	0127b823          	sd	s2,16(a5)
  return 0;
    80004ee6:	4501                	li	a0,0
    80004ee8:	a025                	j	80004f10 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004eea:	6088                	ld	a0,0(s1)
    80004eec:	e501                	bnez	a0,80004ef4 <pipealloc+0xaa>
    80004eee:	a039                	j	80004efc <pipealloc+0xb2>
    80004ef0:	6088                	ld	a0,0(s1)
    80004ef2:	c51d                	beqz	a0,80004f20 <pipealloc+0xd6>
    fileclose(*f0);
    80004ef4:	00000097          	auipc	ra,0x0
    80004ef8:	c26080e7          	jalr	-986(ra) # 80004b1a <fileclose>
  if(*f1)
    80004efc:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004f00:	557d                	li	a0,-1
  if(*f1)
    80004f02:	c799                	beqz	a5,80004f10 <pipealloc+0xc6>
    fileclose(*f1);
    80004f04:	853e                	mv	a0,a5
    80004f06:	00000097          	auipc	ra,0x0
    80004f0a:	c14080e7          	jalr	-1004(ra) # 80004b1a <fileclose>
  return -1;
    80004f0e:	557d                	li	a0,-1
}
    80004f10:	70a2                	ld	ra,40(sp)
    80004f12:	7402                	ld	s0,32(sp)
    80004f14:	64e2                	ld	s1,24(sp)
    80004f16:	6942                	ld	s2,16(sp)
    80004f18:	69a2                	ld	s3,8(sp)
    80004f1a:	6a02                	ld	s4,0(sp)
    80004f1c:	6145                	addi	sp,sp,48
    80004f1e:	8082                	ret
  return -1;
    80004f20:	557d                	li	a0,-1
    80004f22:	b7fd                	j	80004f10 <pipealloc+0xc6>

0000000080004f24 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004f24:	1101                	addi	sp,sp,-32
    80004f26:	ec06                	sd	ra,24(sp)
    80004f28:	e822                	sd	s0,16(sp)
    80004f2a:	e426                	sd	s1,8(sp)
    80004f2c:	e04a                	sd	s2,0(sp)
    80004f2e:	1000                	addi	s0,sp,32
    80004f30:	84aa                	mv	s1,a0
    80004f32:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004f34:	ffffc097          	auipc	ra,0xffffc
    80004f38:	cb6080e7          	jalr	-842(ra) # 80000bea <acquire>
  if(writable){
    80004f3c:	02090d63          	beqz	s2,80004f76 <pipeclose+0x52>
    pi->writeopen = 0;
    80004f40:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004f44:	21848513          	addi	a0,s1,536
    80004f48:	ffffd097          	auipc	ra,0xffffd
    80004f4c:	430080e7          	jalr	1072(ra) # 80002378 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004f50:	2204b783          	ld	a5,544(s1)
    80004f54:	eb95                	bnez	a5,80004f88 <pipeclose+0x64>
    release(&pi->lock);
    80004f56:	8526                	mv	a0,s1
    80004f58:	ffffc097          	auipc	ra,0xffffc
    80004f5c:	d46080e7          	jalr	-698(ra) # 80000c9e <release>
    kfree((char*)pi);
    80004f60:	8526                	mv	a0,s1
    80004f62:	ffffc097          	auipc	ra,0xffffc
    80004f66:	a9c080e7          	jalr	-1380(ra) # 800009fe <kfree>
  } else
    release(&pi->lock);
}
    80004f6a:	60e2                	ld	ra,24(sp)
    80004f6c:	6442                	ld	s0,16(sp)
    80004f6e:	64a2                	ld	s1,8(sp)
    80004f70:	6902                	ld	s2,0(sp)
    80004f72:	6105                	addi	sp,sp,32
    80004f74:	8082                	ret
    pi->readopen = 0;
    80004f76:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004f7a:	21c48513          	addi	a0,s1,540
    80004f7e:	ffffd097          	auipc	ra,0xffffd
    80004f82:	3fa080e7          	jalr	1018(ra) # 80002378 <wakeup>
    80004f86:	b7e9                	j	80004f50 <pipeclose+0x2c>
    release(&pi->lock);
    80004f88:	8526                	mv	a0,s1
    80004f8a:	ffffc097          	auipc	ra,0xffffc
    80004f8e:	d14080e7          	jalr	-748(ra) # 80000c9e <release>
}
    80004f92:	bfe1                	j	80004f6a <pipeclose+0x46>

0000000080004f94 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004f94:	7159                	addi	sp,sp,-112
    80004f96:	f486                	sd	ra,104(sp)
    80004f98:	f0a2                	sd	s0,96(sp)
    80004f9a:	eca6                	sd	s1,88(sp)
    80004f9c:	e8ca                	sd	s2,80(sp)
    80004f9e:	e4ce                	sd	s3,72(sp)
    80004fa0:	e0d2                	sd	s4,64(sp)
    80004fa2:	fc56                	sd	s5,56(sp)
    80004fa4:	f85a                	sd	s6,48(sp)
    80004fa6:	f45e                	sd	s7,40(sp)
    80004fa8:	f062                	sd	s8,32(sp)
    80004faa:	ec66                	sd	s9,24(sp)
    80004fac:	1880                	addi	s0,sp,112
    80004fae:	84aa                	mv	s1,a0
    80004fb0:	8aae                	mv	s5,a1
    80004fb2:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004fb4:	ffffd097          	auipc	ra,0xffffd
    80004fb8:	a12080e7          	jalr	-1518(ra) # 800019c6 <myproc>
    80004fbc:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004fbe:	8526                	mv	a0,s1
    80004fc0:	ffffc097          	auipc	ra,0xffffc
    80004fc4:	c2a080e7          	jalr	-982(ra) # 80000bea <acquire>
  while(i < n){
    80004fc8:	0d405463          	blez	s4,80005090 <pipewrite+0xfc>
    80004fcc:	8ba6                	mv	s7,s1
  int i = 0;
    80004fce:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004fd0:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004fd2:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004fd6:	21c48c13          	addi	s8,s1,540
    80004fda:	a08d                	j	8000503c <pipewrite+0xa8>
      release(&pi->lock);
    80004fdc:	8526                	mv	a0,s1
    80004fde:	ffffc097          	auipc	ra,0xffffc
    80004fe2:	cc0080e7          	jalr	-832(ra) # 80000c9e <release>
      return -1;
    80004fe6:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004fe8:	854a                	mv	a0,s2
    80004fea:	70a6                	ld	ra,104(sp)
    80004fec:	7406                	ld	s0,96(sp)
    80004fee:	64e6                	ld	s1,88(sp)
    80004ff0:	6946                	ld	s2,80(sp)
    80004ff2:	69a6                	ld	s3,72(sp)
    80004ff4:	6a06                	ld	s4,64(sp)
    80004ff6:	7ae2                	ld	s5,56(sp)
    80004ff8:	7b42                	ld	s6,48(sp)
    80004ffa:	7ba2                	ld	s7,40(sp)
    80004ffc:	7c02                	ld	s8,32(sp)
    80004ffe:	6ce2                	ld	s9,24(sp)
    80005000:	6165                	addi	sp,sp,112
    80005002:	8082                	ret
      wakeup(&pi->nread);
    80005004:	8566                	mv	a0,s9
    80005006:	ffffd097          	auipc	ra,0xffffd
    8000500a:	372080e7          	jalr	882(ra) # 80002378 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000500e:	85de                	mv	a1,s7
    80005010:	8562                	mv	a0,s8
    80005012:	ffffd097          	auipc	ra,0xffffd
    80005016:	1b6080e7          	jalr	438(ra) # 800021c8 <sleep>
    8000501a:	a839                	j	80005038 <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000501c:	21c4a783          	lw	a5,540(s1)
    80005020:	0017871b          	addiw	a4,a5,1
    80005024:	20e4ae23          	sw	a4,540(s1)
    80005028:	1ff7f793          	andi	a5,a5,511
    8000502c:	97a6                	add	a5,a5,s1
    8000502e:	f9f44703          	lbu	a4,-97(s0)
    80005032:	00e78c23          	sb	a4,24(a5)
      i++;
    80005036:	2905                	addiw	s2,s2,1
  while(i < n){
    80005038:	05495063          	bge	s2,s4,80005078 <pipewrite+0xe4>
    if(pi->readopen == 0 || killed(pr)){
    8000503c:	2204a783          	lw	a5,544(s1)
    80005040:	dfd1                	beqz	a5,80004fdc <pipewrite+0x48>
    80005042:	854e                	mv	a0,s3
    80005044:	ffffd097          	auipc	ra,0xffffd
    80005048:	584080e7          	jalr	1412(ra) # 800025c8 <killed>
    8000504c:	f941                	bnez	a0,80004fdc <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000504e:	2184a783          	lw	a5,536(s1)
    80005052:	21c4a703          	lw	a4,540(s1)
    80005056:	2007879b          	addiw	a5,a5,512
    8000505a:	faf705e3          	beq	a4,a5,80005004 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000505e:	4685                	li	a3,1
    80005060:	01590633          	add	a2,s2,s5
    80005064:	f9f40593          	addi	a1,s0,-97
    80005068:	0509b503          	ld	a0,80(s3)
    8000506c:	ffffc097          	auipc	ra,0xffffc
    80005070:	6a4080e7          	jalr	1700(ra) # 80001710 <copyin>
    80005074:	fb6514e3          	bne	a0,s6,8000501c <pipewrite+0x88>
  wakeup(&pi->nread);
    80005078:	21848513          	addi	a0,s1,536
    8000507c:	ffffd097          	auipc	ra,0xffffd
    80005080:	2fc080e7          	jalr	764(ra) # 80002378 <wakeup>
  release(&pi->lock);
    80005084:	8526                	mv	a0,s1
    80005086:	ffffc097          	auipc	ra,0xffffc
    8000508a:	c18080e7          	jalr	-1000(ra) # 80000c9e <release>
  return i;
    8000508e:	bfa9                	j	80004fe8 <pipewrite+0x54>
  int i = 0;
    80005090:	4901                	li	s2,0
    80005092:	b7dd                	j	80005078 <pipewrite+0xe4>

0000000080005094 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005094:	715d                	addi	sp,sp,-80
    80005096:	e486                	sd	ra,72(sp)
    80005098:	e0a2                	sd	s0,64(sp)
    8000509a:	fc26                	sd	s1,56(sp)
    8000509c:	f84a                	sd	s2,48(sp)
    8000509e:	f44e                	sd	s3,40(sp)
    800050a0:	f052                	sd	s4,32(sp)
    800050a2:	ec56                	sd	s5,24(sp)
    800050a4:	e85a                	sd	s6,16(sp)
    800050a6:	0880                	addi	s0,sp,80
    800050a8:	84aa                	mv	s1,a0
    800050aa:	892e                	mv	s2,a1
    800050ac:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800050ae:	ffffd097          	auipc	ra,0xffffd
    800050b2:	918080e7          	jalr	-1768(ra) # 800019c6 <myproc>
    800050b6:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800050b8:	8b26                	mv	s6,s1
    800050ba:	8526                	mv	a0,s1
    800050bc:	ffffc097          	auipc	ra,0xffffc
    800050c0:	b2e080e7          	jalr	-1234(ra) # 80000bea <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800050c4:	2184a703          	lw	a4,536(s1)
    800050c8:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800050cc:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800050d0:	02f71763          	bne	a4,a5,800050fe <piperead+0x6a>
    800050d4:	2244a783          	lw	a5,548(s1)
    800050d8:	c39d                	beqz	a5,800050fe <piperead+0x6a>
    if(killed(pr)){
    800050da:	8552                	mv	a0,s4
    800050dc:	ffffd097          	auipc	ra,0xffffd
    800050e0:	4ec080e7          	jalr	1260(ra) # 800025c8 <killed>
    800050e4:	e941                	bnez	a0,80005174 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800050e6:	85da                	mv	a1,s6
    800050e8:	854e                	mv	a0,s3
    800050ea:	ffffd097          	auipc	ra,0xffffd
    800050ee:	0de080e7          	jalr	222(ra) # 800021c8 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800050f2:	2184a703          	lw	a4,536(s1)
    800050f6:	21c4a783          	lw	a5,540(s1)
    800050fa:	fcf70de3          	beq	a4,a5,800050d4 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050fe:	09505263          	blez	s5,80005182 <piperead+0xee>
    80005102:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005104:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80005106:	2184a783          	lw	a5,536(s1)
    8000510a:	21c4a703          	lw	a4,540(s1)
    8000510e:	02f70d63          	beq	a4,a5,80005148 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005112:	0017871b          	addiw	a4,a5,1
    80005116:	20e4ac23          	sw	a4,536(s1)
    8000511a:	1ff7f793          	andi	a5,a5,511
    8000511e:	97a6                	add	a5,a5,s1
    80005120:	0187c783          	lbu	a5,24(a5)
    80005124:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005128:	4685                	li	a3,1
    8000512a:	fbf40613          	addi	a2,s0,-65
    8000512e:	85ca                	mv	a1,s2
    80005130:	050a3503          	ld	a0,80(s4)
    80005134:	ffffc097          	auipc	ra,0xffffc
    80005138:	550080e7          	jalr	1360(ra) # 80001684 <copyout>
    8000513c:	01650663          	beq	a0,s6,80005148 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005140:	2985                	addiw	s3,s3,1
    80005142:	0905                	addi	s2,s2,1
    80005144:	fd3a91e3          	bne	s5,s3,80005106 <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005148:	21c48513          	addi	a0,s1,540
    8000514c:	ffffd097          	auipc	ra,0xffffd
    80005150:	22c080e7          	jalr	556(ra) # 80002378 <wakeup>
  release(&pi->lock);
    80005154:	8526                	mv	a0,s1
    80005156:	ffffc097          	auipc	ra,0xffffc
    8000515a:	b48080e7          	jalr	-1208(ra) # 80000c9e <release>
  return i;
}
    8000515e:	854e                	mv	a0,s3
    80005160:	60a6                	ld	ra,72(sp)
    80005162:	6406                	ld	s0,64(sp)
    80005164:	74e2                	ld	s1,56(sp)
    80005166:	7942                	ld	s2,48(sp)
    80005168:	79a2                	ld	s3,40(sp)
    8000516a:	7a02                	ld	s4,32(sp)
    8000516c:	6ae2                	ld	s5,24(sp)
    8000516e:	6b42                	ld	s6,16(sp)
    80005170:	6161                	addi	sp,sp,80
    80005172:	8082                	ret
      release(&pi->lock);
    80005174:	8526                	mv	a0,s1
    80005176:	ffffc097          	auipc	ra,0xffffc
    8000517a:	b28080e7          	jalr	-1240(ra) # 80000c9e <release>
      return -1;
    8000517e:	59fd                	li	s3,-1
    80005180:	bff9                	j	8000515e <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005182:	4981                	li	s3,0
    80005184:	b7d1                	j	80005148 <piperead+0xb4>

0000000080005186 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80005186:	1141                	addi	sp,sp,-16
    80005188:	e422                	sd	s0,8(sp)
    8000518a:	0800                	addi	s0,sp,16
    8000518c:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000518e:	8905                	andi	a0,a0,1
    80005190:	c111                	beqz	a0,80005194 <flags2perm+0xe>
      perm = PTE_X;
    80005192:	4521                	li	a0,8
    if(flags & 0x2)
    80005194:	8b89                	andi	a5,a5,2
    80005196:	c399                	beqz	a5,8000519c <flags2perm+0x16>
      perm |= PTE_W;
    80005198:	00456513          	ori	a0,a0,4
    return perm;
}
    8000519c:	6422                	ld	s0,8(sp)
    8000519e:	0141                	addi	sp,sp,16
    800051a0:	8082                	ret

00000000800051a2 <exec>:

int
exec(char *path, char **argv)
{
    800051a2:	df010113          	addi	sp,sp,-528
    800051a6:	20113423          	sd	ra,520(sp)
    800051aa:	20813023          	sd	s0,512(sp)
    800051ae:	ffa6                	sd	s1,504(sp)
    800051b0:	fbca                	sd	s2,496(sp)
    800051b2:	f7ce                	sd	s3,488(sp)
    800051b4:	f3d2                	sd	s4,480(sp)
    800051b6:	efd6                	sd	s5,472(sp)
    800051b8:	ebda                	sd	s6,464(sp)
    800051ba:	e7de                	sd	s7,456(sp)
    800051bc:	e3e2                	sd	s8,448(sp)
    800051be:	ff66                	sd	s9,440(sp)
    800051c0:	fb6a                	sd	s10,432(sp)
    800051c2:	f76e                	sd	s11,424(sp)
    800051c4:	0c00                	addi	s0,sp,528
    800051c6:	84aa                	mv	s1,a0
    800051c8:	dea43c23          	sd	a0,-520(s0)
    800051cc:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800051d0:	ffffc097          	auipc	ra,0xffffc
    800051d4:	7f6080e7          	jalr	2038(ra) # 800019c6 <myproc>
    800051d8:	892a                	mv	s2,a0

  begin_op();
    800051da:	fffff097          	auipc	ra,0xfffff
    800051de:	474080e7          	jalr	1140(ra) # 8000464e <begin_op>

  if((ip = namei(path)) == 0){
    800051e2:	8526                	mv	a0,s1
    800051e4:	fffff097          	auipc	ra,0xfffff
    800051e8:	24e080e7          	jalr	590(ra) # 80004432 <namei>
    800051ec:	c92d                	beqz	a0,8000525e <exec+0xbc>
    800051ee:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800051f0:	fffff097          	auipc	ra,0xfffff
    800051f4:	a9c080e7          	jalr	-1380(ra) # 80003c8c <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800051f8:	04000713          	li	a4,64
    800051fc:	4681                	li	a3,0
    800051fe:	e5040613          	addi	a2,s0,-432
    80005202:	4581                	li	a1,0
    80005204:	8526                	mv	a0,s1
    80005206:	fffff097          	auipc	ra,0xfffff
    8000520a:	d3a080e7          	jalr	-710(ra) # 80003f40 <readi>
    8000520e:	04000793          	li	a5,64
    80005212:	00f51a63          	bne	a0,a5,80005226 <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80005216:	e5042703          	lw	a4,-432(s0)
    8000521a:	464c47b7          	lui	a5,0x464c4
    8000521e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005222:	04f70463          	beq	a4,a5,8000526a <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005226:	8526                	mv	a0,s1
    80005228:	fffff097          	auipc	ra,0xfffff
    8000522c:	cc6080e7          	jalr	-826(ra) # 80003eee <iunlockput>
    end_op();
    80005230:	fffff097          	auipc	ra,0xfffff
    80005234:	49e080e7          	jalr	1182(ra) # 800046ce <end_op>
  }
  return -1;
    80005238:	557d                	li	a0,-1
}
    8000523a:	20813083          	ld	ra,520(sp)
    8000523e:	20013403          	ld	s0,512(sp)
    80005242:	74fe                	ld	s1,504(sp)
    80005244:	795e                	ld	s2,496(sp)
    80005246:	79be                	ld	s3,488(sp)
    80005248:	7a1e                	ld	s4,480(sp)
    8000524a:	6afe                	ld	s5,472(sp)
    8000524c:	6b5e                	ld	s6,464(sp)
    8000524e:	6bbe                	ld	s7,456(sp)
    80005250:	6c1e                	ld	s8,448(sp)
    80005252:	7cfa                	ld	s9,440(sp)
    80005254:	7d5a                	ld	s10,432(sp)
    80005256:	7dba                	ld	s11,424(sp)
    80005258:	21010113          	addi	sp,sp,528
    8000525c:	8082                	ret
    end_op();
    8000525e:	fffff097          	auipc	ra,0xfffff
    80005262:	470080e7          	jalr	1136(ra) # 800046ce <end_op>
    return -1;
    80005266:	557d                	li	a0,-1
    80005268:	bfc9                	j	8000523a <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    8000526a:	854a                	mv	a0,s2
    8000526c:	ffffd097          	auipc	ra,0xffffd
    80005270:	81e080e7          	jalr	-2018(ra) # 80001a8a <proc_pagetable>
    80005274:	8baa                	mv	s7,a0
    80005276:	d945                	beqz	a0,80005226 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005278:	e7042983          	lw	s3,-400(s0)
    8000527c:	e8845783          	lhu	a5,-376(s0)
    80005280:	c7ad                	beqz	a5,800052ea <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005282:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005284:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80005286:	6c85                	lui	s9,0x1
    80005288:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000528c:	def43823          	sd	a5,-528(s0)
    80005290:	ac0d                	j	800054c2 <exec+0x320>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005292:	00003517          	auipc	a0,0x3
    80005296:	5f650513          	addi	a0,a0,1526 # 80008888 <syscallnum+0x238>
    8000529a:	ffffb097          	auipc	ra,0xffffb
    8000529e:	2aa080e7          	jalr	682(ra) # 80000544 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800052a2:	8756                	mv	a4,s5
    800052a4:	012d86bb          	addw	a3,s11,s2
    800052a8:	4581                	li	a1,0
    800052aa:	8526                	mv	a0,s1
    800052ac:	fffff097          	auipc	ra,0xfffff
    800052b0:	c94080e7          	jalr	-876(ra) # 80003f40 <readi>
    800052b4:	2501                	sext.w	a0,a0
    800052b6:	1aaa9a63          	bne	s5,a0,8000546a <exec+0x2c8>
  for(i = 0; i < sz; i += PGSIZE){
    800052ba:	6785                	lui	a5,0x1
    800052bc:	0127893b          	addw	s2,a5,s2
    800052c0:	77fd                	lui	a5,0xfffff
    800052c2:	01478a3b          	addw	s4,a5,s4
    800052c6:	1f897563          	bgeu	s2,s8,800054b0 <exec+0x30e>
    pa = walkaddr(pagetable, va + i);
    800052ca:	02091593          	slli	a1,s2,0x20
    800052ce:	9181                	srli	a1,a1,0x20
    800052d0:	95ea                	add	a1,a1,s10
    800052d2:	855e                	mv	a0,s7
    800052d4:	ffffc097          	auipc	ra,0xffffc
    800052d8:	da4080e7          	jalr	-604(ra) # 80001078 <walkaddr>
    800052dc:	862a                	mv	a2,a0
    if(pa == 0)
    800052de:	d955                	beqz	a0,80005292 <exec+0xf0>
      n = PGSIZE;
    800052e0:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    800052e2:	fd9a70e3          	bgeu	s4,s9,800052a2 <exec+0x100>
      n = sz - i;
    800052e6:	8ad2                	mv	s5,s4
    800052e8:	bf6d                	j	800052a2 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800052ea:	4a01                	li	s4,0
  iunlockput(ip);
    800052ec:	8526                	mv	a0,s1
    800052ee:	fffff097          	auipc	ra,0xfffff
    800052f2:	c00080e7          	jalr	-1024(ra) # 80003eee <iunlockput>
  end_op();
    800052f6:	fffff097          	auipc	ra,0xfffff
    800052fa:	3d8080e7          	jalr	984(ra) # 800046ce <end_op>
  p = myproc();
    800052fe:	ffffc097          	auipc	ra,0xffffc
    80005302:	6c8080e7          	jalr	1736(ra) # 800019c6 <myproc>
    80005306:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005308:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    8000530c:	6785                	lui	a5,0x1
    8000530e:	17fd                	addi	a5,a5,-1
    80005310:	9a3e                	add	s4,s4,a5
    80005312:	757d                	lui	a0,0xfffff
    80005314:	00aa77b3          	and	a5,s4,a0
    80005318:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    8000531c:	4691                	li	a3,4
    8000531e:	6609                	lui	a2,0x2
    80005320:	963e                	add	a2,a2,a5
    80005322:	85be                	mv	a1,a5
    80005324:	855e                	mv	a0,s7
    80005326:	ffffc097          	auipc	ra,0xffffc
    8000532a:	106080e7          	jalr	262(ra) # 8000142c <uvmalloc>
    8000532e:	8b2a                	mv	s6,a0
  ip = 0;
    80005330:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005332:	12050c63          	beqz	a0,8000546a <exec+0x2c8>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005336:	75f9                	lui	a1,0xffffe
    80005338:	95aa                	add	a1,a1,a0
    8000533a:	855e                	mv	a0,s7
    8000533c:	ffffc097          	auipc	ra,0xffffc
    80005340:	316080e7          	jalr	790(ra) # 80001652 <uvmclear>
  stackbase = sp - PGSIZE;
    80005344:	7c7d                	lui	s8,0xfffff
    80005346:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80005348:	e0043783          	ld	a5,-512(s0)
    8000534c:	6388                	ld	a0,0(a5)
    8000534e:	c535                	beqz	a0,800053ba <exec+0x218>
    80005350:	e9040993          	addi	s3,s0,-368
    80005354:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80005358:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    8000535a:	ffffc097          	auipc	ra,0xffffc
    8000535e:	b10080e7          	jalr	-1264(ra) # 80000e6a <strlen>
    80005362:	2505                	addiw	a0,a0,1
    80005364:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005368:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    8000536c:	13896663          	bltu	s2,s8,80005498 <exec+0x2f6>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005370:	e0043d83          	ld	s11,-512(s0)
    80005374:	000dba03          	ld	s4,0(s11)
    80005378:	8552                	mv	a0,s4
    8000537a:	ffffc097          	auipc	ra,0xffffc
    8000537e:	af0080e7          	jalr	-1296(ra) # 80000e6a <strlen>
    80005382:	0015069b          	addiw	a3,a0,1
    80005386:	8652                	mv	a2,s4
    80005388:	85ca                	mv	a1,s2
    8000538a:	855e                	mv	a0,s7
    8000538c:	ffffc097          	auipc	ra,0xffffc
    80005390:	2f8080e7          	jalr	760(ra) # 80001684 <copyout>
    80005394:	10054663          	bltz	a0,800054a0 <exec+0x2fe>
    ustack[argc] = sp;
    80005398:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000539c:	0485                	addi	s1,s1,1
    8000539e:	008d8793          	addi	a5,s11,8
    800053a2:	e0f43023          	sd	a5,-512(s0)
    800053a6:	008db503          	ld	a0,8(s11)
    800053aa:	c911                	beqz	a0,800053be <exec+0x21c>
    if(argc >= MAXARG)
    800053ac:	09a1                	addi	s3,s3,8
    800053ae:	fb3c96e3          	bne	s9,s3,8000535a <exec+0x1b8>
  sz = sz1;
    800053b2:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800053b6:	4481                	li	s1,0
    800053b8:	a84d                	j	8000546a <exec+0x2c8>
  sp = sz;
    800053ba:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    800053bc:	4481                	li	s1,0
  ustack[argc] = 0;
    800053be:	00349793          	slli	a5,s1,0x3
    800053c2:	f9040713          	addi	a4,s0,-112
    800053c6:	97ba                	add	a5,a5,a4
    800053c8:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    800053cc:	00148693          	addi	a3,s1,1
    800053d0:	068e                	slli	a3,a3,0x3
    800053d2:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800053d6:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800053da:	01897663          	bgeu	s2,s8,800053e6 <exec+0x244>
  sz = sz1;
    800053de:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800053e2:	4481                	li	s1,0
    800053e4:	a059                	j	8000546a <exec+0x2c8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800053e6:	e9040613          	addi	a2,s0,-368
    800053ea:	85ca                	mv	a1,s2
    800053ec:	855e                	mv	a0,s7
    800053ee:	ffffc097          	auipc	ra,0xffffc
    800053f2:	296080e7          	jalr	662(ra) # 80001684 <copyout>
    800053f6:	0a054963          	bltz	a0,800054a8 <exec+0x306>
  p->trapframe->a1 = sp;
    800053fa:	058ab783          	ld	a5,88(s5)
    800053fe:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005402:	df843783          	ld	a5,-520(s0)
    80005406:	0007c703          	lbu	a4,0(a5)
    8000540a:	cf11                	beqz	a4,80005426 <exec+0x284>
    8000540c:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000540e:	02f00693          	li	a3,47
    80005412:	a039                	j	80005420 <exec+0x27e>
      last = s+1;
    80005414:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80005418:	0785                	addi	a5,a5,1
    8000541a:	fff7c703          	lbu	a4,-1(a5)
    8000541e:	c701                	beqz	a4,80005426 <exec+0x284>
    if(*s == '/')
    80005420:	fed71ce3          	bne	a4,a3,80005418 <exec+0x276>
    80005424:	bfc5                	j	80005414 <exec+0x272>
  safestrcpy(p->name, last, sizeof(p->name));
    80005426:	4641                	li	a2,16
    80005428:	df843583          	ld	a1,-520(s0)
    8000542c:	158a8513          	addi	a0,s5,344
    80005430:	ffffc097          	auipc	ra,0xffffc
    80005434:	a08080e7          	jalr	-1528(ra) # 80000e38 <safestrcpy>
  oldpagetable = p->pagetable;
    80005438:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    8000543c:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    80005440:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005444:	058ab783          	ld	a5,88(s5)
    80005448:	e6843703          	ld	a4,-408(s0)
    8000544c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000544e:	058ab783          	ld	a5,88(s5)
    80005452:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005456:	85ea                	mv	a1,s10
    80005458:	ffffc097          	auipc	ra,0xffffc
    8000545c:	6ce080e7          	jalr	1742(ra) # 80001b26 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005460:	0004851b          	sext.w	a0,s1
    80005464:	bbd9                	j	8000523a <exec+0x98>
    80005466:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    8000546a:	e0843583          	ld	a1,-504(s0)
    8000546e:	855e                	mv	a0,s7
    80005470:	ffffc097          	auipc	ra,0xffffc
    80005474:	6b6080e7          	jalr	1718(ra) # 80001b26 <proc_freepagetable>
  if(ip){
    80005478:	da0497e3          	bnez	s1,80005226 <exec+0x84>
  return -1;
    8000547c:	557d                	li	a0,-1
    8000547e:	bb75                	j	8000523a <exec+0x98>
    80005480:	e1443423          	sd	s4,-504(s0)
    80005484:	b7dd                	j	8000546a <exec+0x2c8>
    80005486:	e1443423          	sd	s4,-504(s0)
    8000548a:	b7c5                	j	8000546a <exec+0x2c8>
    8000548c:	e1443423          	sd	s4,-504(s0)
    80005490:	bfe9                	j	8000546a <exec+0x2c8>
    80005492:	e1443423          	sd	s4,-504(s0)
    80005496:	bfd1                	j	8000546a <exec+0x2c8>
  sz = sz1;
    80005498:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000549c:	4481                	li	s1,0
    8000549e:	b7f1                	j	8000546a <exec+0x2c8>
  sz = sz1;
    800054a0:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800054a4:	4481                	li	s1,0
    800054a6:	b7d1                	j	8000546a <exec+0x2c8>
  sz = sz1;
    800054a8:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800054ac:	4481                	li	s1,0
    800054ae:	bf75                	j	8000546a <exec+0x2c8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800054b0:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800054b4:	2b05                	addiw	s6,s6,1
    800054b6:	0389899b          	addiw	s3,s3,56
    800054ba:	e8845783          	lhu	a5,-376(s0)
    800054be:	e2fb57e3          	bge	s6,a5,800052ec <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800054c2:	2981                	sext.w	s3,s3
    800054c4:	03800713          	li	a4,56
    800054c8:	86ce                	mv	a3,s3
    800054ca:	e1840613          	addi	a2,s0,-488
    800054ce:	4581                	li	a1,0
    800054d0:	8526                	mv	a0,s1
    800054d2:	fffff097          	auipc	ra,0xfffff
    800054d6:	a6e080e7          	jalr	-1426(ra) # 80003f40 <readi>
    800054da:	03800793          	li	a5,56
    800054de:	f8f514e3          	bne	a0,a5,80005466 <exec+0x2c4>
    if(ph.type != ELF_PROG_LOAD)
    800054e2:	e1842783          	lw	a5,-488(s0)
    800054e6:	4705                	li	a4,1
    800054e8:	fce796e3          	bne	a5,a4,800054b4 <exec+0x312>
    if(ph.memsz < ph.filesz)
    800054ec:	e4043903          	ld	s2,-448(s0)
    800054f0:	e3843783          	ld	a5,-456(s0)
    800054f4:	f8f966e3          	bltu	s2,a5,80005480 <exec+0x2de>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800054f8:	e2843783          	ld	a5,-472(s0)
    800054fc:	993e                	add	s2,s2,a5
    800054fe:	f8f964e3          	bltu	s2,a5,80005486 <exec+0x2e4>
    if(ph.vaddr % PGSIZE != 0)
    80005502:	df043703          	ld	a4,-528(s0)
    80005506:	8ff9                	and	a5,a5,a4
    80005508:	f3d1                	bnez	a5,8000548c <exec+0x2ea>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000550a:	e1c42503          	lw	a0,-484(s0)
    8000550e:	00000097          	auipc	ra,0x0
    80005512:	c78080e7          	jalr	-904(ra) # 80005186 <flags2perm>
    80005516:	86aa                	mv	a3,a0
    80005518:	864a                	mv	a2,s2
    8000551a:	85d2                	mv	a1,s4
    8000551c:	855e                	mv	a0,s7
    8000551e:	ffffc097          	auipc	ra,0xffffc
    80005522:	f0e080e7          	jalr	-242(ra) # 8000142c <uvmalloc>
    80005526:	e0a43423          	sd	a0,-504(s0)
    8000552a:	d525                	beqz	a0,80005492 <exec+0x2f0>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000552c:	e2843d03          	ld	s10,-472(s0)
    80005530:	e2042d83          	lw	s11,-480(s0)
    80005534:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005538:	f60c0ce3          	beqz	s8,800054b0 <exec+0x30e>
    8000553c:	8a62                	mv	s4,s8
    8000553e:	4901                	li	s2,0
    80005540:	b369                	j	800052ca <exec+0x128>

0000000080005542 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005542:	7179                	addi	sp,sp,-48
    80005544:	f406                	sd	ra,40(sp)
    80005546:	f022                	sd	s0,32(sp)
    80005548:	ec26                	sd	s1,24(sp)
    8000554a:	e84a                	sd	s2,16(sp)
    8000554c:	1800                	addi	s0,sp,48
    8000554e:	892e                	mv	s2,a1
    80005550:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005552:	fdc40593          	addi	a1,s0,-36
    80005556:	ffffe097          	auipc	ra,0xffffe
    8000555a:	918080e7          	jalr	-1768(ra) # 80002e6e <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000555e:	fdc42703          	lw	a4,-36(s0)
    80005562:	47bd                	li	a5,15
    80005564:	02e7eb63          	bltu	a5,a4,8000559a <argfd+0x58>
    80005568:	ffffc097          	auipc	ra,0xffffc
    8000556c:	45e080e7          	jalr	1118(ra) # 800019c6 <myproc>
    80005570:	fdc42703          	lw	a4,-36(s0)
    80005574:	01a70793          	addi	a5,a4,26
    80005578:	078e                	slli	a5,a5,0x3
    8000557a:	953e                	add	a0,a0,a5
    8000557c:	611c                	ld	a5,0(a0)
    8000557e:	c385                	beqz	a5,8000559e <argfd+0x5c>
    return -1;
  if(pfd)
    80005580:	00090463          	beqz	s2,80005588 <argfd+0x46>
    *pfd = fd;
    80005584:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005588:	4501                	li	a0,0
  if(pf)
    8000558a:	c091                	beqz	s1,8000558e <argfd+0x4c>
    *pf = f;
    8000558c:	e09c                	sd	a5,0(s1)
}
    8000558e:	70a2                	ld	ra,40(sp)
    80005590:	7402                	ld	s0,32(sp)
    80005592:	64e2                	ld	s1,24(sp)
    80005594:	6942                	ld	s2,16(sp)
    80005596:	6145                	addi	sp,sp,48
    80005598:	8082                	ret
    return -1;
    8000559a:	557d                	li	a0,-1
    8000559c:	bfcd                	j	8000558e <argfd+0x4c>
    8000559e:	557d                	li	a0,-1
    800055a0:	b7fd                	j	8000558e <argfd+0x4c>

00000000800055a2 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800055a2:	1101                	addi	sp,sp,-32
    800055a4:	ec06                	sd	ra,24(sp)
    800055a6:	e822                	sd	s0,16(sp)
    800055a8:	e426                	sd	s1,8(sp)
    800055aa:	1000                	addi	s0,sp,32
    800055ac:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800055ae:	ffffc097          	auipc	ra,0xffffc
    800055b2:	418080e7          	jalr	1048(ra) # 800019c6 <myproc>
    800055b6:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800055b8:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffdb2f0>
    800055bc:	4501                	li	a0,0
    800055be:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800055c0:	6398                	ld	a4,0(a5)
    800055c2:	cb19                	beqz	a4,800055d8 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800055c4:	2505                	addiw	a0,a0,1
    800055c6:	07a1                	addi	a5,a5,8
    800055c8:	fed51ce3          	bne	a0,a3,800055c0 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800055cc:	557d                	li	a0,-1
}
    800055ce:	60e2                	ld	ra,24(sp)
    800055d0:	6442                	ld	s0,16(sp)
    800055d2:	64a2                	ld	s1,8(sp)
    800055d4:	6105                	addi	sp,sp,32
    800055d6:	8082                	ret
      p->ofile[fd] = f;
    800055d8:	01a50793          	addi	a5,a0,26
    800055dc:	078e                	slli	a5,a5,0x3
    800055de:	963e                	add	a2,a2,a5
    800055e0:	e204                	sd	s1,0(a2)
      return fd;
    800055e2:	b7f5                	j	800055ce <fdalloc+0x2c>

00000000800055e4 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800055e4:	715d                	addi	sp,sp,-80
    800055e6:	e486                	sd	ra,72(sp)
    800055e8:	e0a2                	sd	s0,64(sp)
    800055ea:	fc26                	sd	s1,56(sp)
    800055ec:	f84a                	sd	s2,48(sp)
    800055ee:	f44e                	sd	s3,40(sp)
    800055f0:	f052                	sd	s4,32(sp)
    800055f2:	ec56                	sd	s5,24(sp)
    800055f4:	e85a                	sd	s6,16(sp)
    800055f6:	0880                	addi	s0,sp,80
    800055f8:	8b2e                	mv	s6,a1
    800055fa:	89b2                	mv	s3,a2
    800055fc:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800055fe:	fb040593          	addi	a1,s0,-80
    80005602:	fffff097          	auipc	ra,0xfffff
    80005606:	e4e080e7          	jalr	-434(ra) # 80004450 <nameiparent>
    8000560a:	84aa                	mv	s1,a0
    8000560c:	16050063          	beqz	a0,8000576c <create+0x188>
    return 0;

  ilock(dp);
    80005610:	ffffe097          	auipc	ra,0xffffe
    80005614:	67c080e7          	jalr	1660(ra) # 80003c8c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005618:	4601                	li	a2,0
    8000561a:	fb040593          	addi	a1,s0,-80
    8000561e:	8526                	mv	a0,s1
    80005620:	fffff097          	auipc	ra,0xfffff
    80005624:	b50080e7          	jalr	-1200(ra) # 80004170 <dirlookup>
    80005628:	8aaa                	mv	s5,a0
    8000562a:	c931                	beqz	a0,8000567e <create+0x9a>
    iunlockput(dp);
    8000562c:	8526                	mv	a0,s1
    8000562e:	fffff097          	auipc	ra,0xfffff
    80005632:	8c0080e7          	jalr	-1856(ra) # 80003eee <iunlockput>
    ilock(ip);
    80005636:	8556                	mv	a0,s5
    80005638:	ffffe097          	auipc	ra,0xffffe
    8000563c:	654080e7          	jalr	1620(ra) # 80003c8c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005640:	000b059b          	sext.w	a1,s6
    80005644:	4789                	li	a5,2
    80005646:	02f59563          	bne	a1,a5,80005670 <create+0x8c>
    8000564a:	044ad783          	lhu	a5,68(s5)
    8000564e:	37f9                	addiw	a5,a5,-2
    80005650:	17c2                	slli	a5,a5,0x30
    80005652:	93c1                	srli	a5,a5,0x30
    80005654:	4705                	li	a4,1
    80005656:	00f76d63          	bltu	a4,a5,80005670 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000565a:	8556                	mv	a0,s5
    8000565c:	60a6                	ld	ra,72(sp)
    8000565e:	6406                	ld	s0,64(sp)
    80005660:	74e2                	ld	s1,56(sp)
    80005662:	7942                	ld	s2,48(sp)
    80005664:	79a2                	ld	s3,40(sp)
    80005666:	7a02                	ld	s4,32(sp)
    80005668:	6ae2                	ld	s5,24(sp)
    8000566a:	6b42                	ld	s6,16(sp)
    8000566c:	6161                	addi	sp,sp,80
    8000566e:	8082                	ret
    iunlockput(ip);
    80005670:	8556                	mv	a0,s5
    80005672:	fffff097          	auipc	ra,0xfffff
    80005676:	87c080e7          	jalr	-1924(ra) # 80003eee <iunlockput>
    return 0;
    8000567a:	4a81                	li	s5,0
    8000567c:	bff9                	j	8000565a <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000567e:	85da                	mv	a1,s6
    80005680:	4088                	lw	a0,0(s1)
    80005682:	ffffe097          	auipc	ra,0xffffe
    80005686:	46e080e7          	jalr	1134(ra) # 80003af0 <ialloc>
    8000568a:	8a2a                	mv	s4,a0
    8000568c:	c921                	beqz	a0,800056dc <create+0xf8>
  ilock(ip);
    8000568e:	ffffe097          	auipc	ra,0xffffe
    80005692:	5fe080e7          	jalr	1534(ra) # 80003c8c <ilock>
  ip->major = major;
    80005696:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000569a:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000569e:	4785                	li	a5,1
    800056a0:	04fa1523          	sh	a5,74(s4)
  iupdate(ip);
    800056a4:	8552                	mv	a0,s4
    800056a6:	ffffe097          	auipc	ra,0xffffe
    800056aa:	51c080e7          	jalr	1308(ra) # 80003bc2 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800056ae:	000b059b          	sext.w	a1,s6
    800056b2:	4785                	li	a5,1
    800056b4:	02f58b63          	beq	a1,a5,800056ea <create+0x106>
  if(dirlink(dp, name, ip->inum) < 0)
    800056b8:	004a2603          	lw	a2,4(s4)
    800056bc:	fb040593          	addi	a1,s0,-80
    800056c0:	8526                	mv	a0,s1
    800056c2:	fffff097          	auipc	ra,0xfffff
    800056c6:	cbe080e7          	jalr	-834(ra) # 80004380 <dirlink>
    800056ca:	06054f63          	bltz	a0,80005748 <create+0x164>
  iunlockput(dp);
    800056ce:	8526                	mv	a0,s1
    800056d0:	fffff097          	auipc	ra,0xfffff
    800056d4:	81e080e7          	jalr	-2018(ra) # 80003eee <iunlockput>
  return ip;
    800056d8:	8ad2                	mv	s5,s4
    800056da:	b741                	j	8000565a <create+0x76>
    iunlockput(dp);
    800056dc:	8526                	mv	a0,s1
    800056de:	fffff097          	auipc	ra,0xfffff
    800056e2:	810080e7          	jalr	-2032(ra) # 80003eee <iunlockput>
    return 0;
    800056e6:	8ad2                	mv	s5,s4
    800056e8:	bf8d                	j	8000565a <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800056ea:	004a2603          	lw	a2,4(s4)
    800056ee:	00003597          	auipc	a1,0x3
    800056f2:	1ba58593          	addi	a1,a1,442 # 800088a8 <syscallnum+0x258>
    800056f6:	8552                	mv	a0,s4
    800056f8:	fffff097          	auipc	ra,0xfffff
    800056fc:	c88080e7          	jalr	-888(ra) # 80004380 <dirlink>
    80005700:	04054463          	bltz	a0,80005748 <create+0x164>
    80005704:	40d0                	lw	a2,4(s1)
    80005706:	00003597          	auipc	a1,0x3
    8000570a:	1aa58593          	addi	a1,a1,426 # 800088b0 <syscallnum+0x260>
    8000570e:	8552                	mv	a0,s4
    80005710:	fffff097          	auipc	ra,0xfffff
    80005714:	c70080e7          	jalr	-912(ra) # 80004380 <dirlink>
    80005718:	02054863          	bltz	a0,80005748 <create+0x164>
  if(dirlink(dp, name, ip->inum) < 0)
    8000571c:	004a2603          	lw	a2,4(s4)
    80005720:	fb040593          	addi	a1,s0,-80
    80005724:	8526                	mv	a0,s1
    80005726:	fffff097          	auipc	ra,0xfffff
    8000572a:	c5a080e7          	jalr	-934(ra) # 80004380 <dirlink>
    8000572e:	00054d63          	bltz	a0,80005748 <create+0x164>
    dp->nlink++;  // for ".."
    80005732:	04a4d783          	lhu	a5,74(s1)
    80005736:	2785                	addiw	a5,a5,1
    80005738:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000573c:	8526                	mv	a0,s1
    8000573e:	ffffe097          	auipc	ra,0xffffe
    80005742:	484080e7          	jalr	1156(ra) # 80003bc2 <iupdate>
    80005746:	b761                	j	800056ce <create+0xea>
  ip->nlink = 0;
    80005748:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000574c:	8552                	mv	a0,s4
    8000574e:	ffffe097          	auipc	ra,0xffffe
    80005752:	474080e7          	jalr	1140(ra) # 80003bc2 <iupdate>
  iunlockput(ip);
    80005756:	8552                	mv	a0,s4
    80005758:	ffffe097          	auipc	ra,0xffffe
    8000575c:	796080e7          	jalr	1942(ra) # 80003eee <iunlockput>
  iunlockput(dp);
    80005760:	8526                	mv	a0,s1
    80005762:	ffffe097          	auipc	ra,0xffffe
    80005766:	78c080e7          	jalr	1932(ra) # 80003eee <iunlockput>
  return 0;
    8000576a:	bdc5                	j	8000565a <create+0x76>
    return 0;
    8000576c:	8aaa                	mv	s5,a0
    8000576e:	b5f5                	j	8000565a <create+0x76>

0000000080005770 <sys_dup>:
{
    80005770:	7179                	addi	sp,sp,-48
    80005772:	f406                	sd	ra,40(sp)
    80005774:	f022                	sd	s0,32(sp)
    80005776:	ec26                	sd	s1,24(sp)
    80005778:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000577a:	fd840613          	addi	a2,s0,-40
    8000577e:	4581                	li	a1,0
    80005780:	4501                	li	a0,0
    80005782:	00000097          	auipc	ra,0x0
    80005786:	dc0080e7          	jalr	-576(ra) # 80005542 <argfd>
    return -1;
    8000578a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000578c:	02054363          	bltz	a0,800057b2 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005790:	fd843503          	ld	a0,-40(s0)
    80005794:	00000097          	auipc	ra,0x0
    80005798:	e0e080e7          	jalr	-498(ra) # 800055a2 <fdalloc>
    8000579c:	84aa                	mv	s1,a0
    return -1;
    8000579e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800057a0:	00054963          	bltz	a0,800057b2 <sys_dup+0x42>
  filedup(f);
    800057a4:	fd843503          	ld	a0,-40(s0)
    800057a8:	fffff097          	auipc	ra,0xfffff
    800057ac:	320080e7          	jalr	800(ra) # 80004ac8 <filedup>
  return fd;
    800057b0:	87a6                	mv	a5,s1
}
    800057b2:	853e                	mv	a0,a5
    800057b4:	70a2                	ld	ra,40(sp)
    800057b6:	7402                	ld	s0,32(sp)
    800057b8:	64e2                	ld	s1,24(sp)
    800057ba:	6145                	addi	sp,sp,48
    800057bc:	8082                	ret

00000000800057be <sys_read>:
{
    800057be:	7179                	addi	sp,sp,-48
    800057c0:	f406                	sd	ra,40(sp)
    800057c2:	f022                	sd	s0,32(sp)
    800057c4:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800057c6:	fd840593          	addi	a1,s0,-40
    800057ca:	4505                	li	a0,1
    800057cc:	ffffd097          	auipc	ra,0xffffd
    800057d0:	6c4080e7          	jalr	1732(ra) # 80002e90 <argaddr>
  argint(2, &n);
    800057d4:	fe440593          	addi	a1,s0,-28
    800057d8:	4509                	li	a0,2
    800057da:	ffffd097          	auipc	ra,0xffffd
    800057de:	694080e7          	jalr	1684(ra) # 80002e6e <argint>
  if(argfd(0, 0, &f) < 0)
    800057e2:	fe840613          	addi	a2,s0,-24
    800057e6:	4581                	li	a1,0
    800057e8:	4501                	li	a0,0
    800057ea:	00000097          	auipc	ra,0x0
    800057ee:	d58080e7          	jalr	-680(ra) # 80005542 <argfd>
    800057f2:	87aa                	mv	a5,a0
    return -1;
    800057f4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800057f6:	0007cc63          	bltz	a5,8000580e <sys_read+0x50>
  return fileread(f, p, n);
    800057fa:	fe442603          	lw	a2,-28(s0)
    800057fe:	fd843583          	ld	a1,-40(s0)
    80005802:	fe843503          	ld	a0,-24(s0)
    80005806:	fffff097          	auipc	ra,0xfffff
    8000580a:	44e080e7          	jalr	1102(ra) # 80004c54 <fileread>
}
    8000580e:	70a2                	ld	ra,40(sp)
    80005810:	7402                	ld	s0,32(sp)
    80005812:	6145                	addi	sp,sp,48
    80005814:	8082                	ret

0000000080005816 <sys_write>:
{
    80005816:	7179                	addi	sp,sp,-48
    80005818:	f406                	sd	ra,40(sp)
    8000581a:	f022                	sd	s0,32(sp)
    8000581c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000581e:	fd840593          	addi	a1,s0,-40
    80005822:	4505                	li	a0,1
    80005824:	ffffd097          	auipc	ra,0xffffd
    80005828:	66c080e7          	jalr	1644(ra) # 80002e90 <argaddr>
  argint(2, &n);
    8000582c:	fe440593          	addi	a1,s0,-28
    80005830:	4509                	li	a0,2
    80005832:	ffffd097          	auipc	ra,0xffffd
    80005836:	63c080e7          	jalr	1596(ra) # 80002e6e <argint>
  if(argfd(0, 0, &f) < 0)
    8000583a:	fe840613          	addi	a2,s0,-24
    8000583e:	4581                	li	a1,0
    80005840:	4501                	li	a0,0
    80005842:	00000097          	auipc	ra,0x0
    80005846:	d00080e7          	jalr	-768(ra) # 80005542 <argfd>
    8000584a:	87aa                	mv	a5,a0
    return -1;
    8000584c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000584e:	0007cc63          	bltz	a5,80005866 <sys_write+0x50>
  return filewrite(f, p, n);
    80005852:	fe442603          	lw	a2,-28(s0)
    80005856:	fd843583          	ld	a1,-40(s0)
    8000585a:	fe843503          	ld	a0,-24(s0)
    8000585e:	fffff097          	auipc	ra,0xfffff
    80005862:	4b8080e7          	jalr	1208(ra) # 80004d16 <filewrite>
}
    80005866:	70a2                	ld	ra,40(sp)
    80005868:	7402                	ld	s0,32(sp)
    8000586a:	6145                	addi	sp,sp,48
    8000586c:	8082                	ret

000000008000586e <sys_close>:
{
    8000586e:	1101                	addi	sp,sp,-32
    80005870:	ec06                	sd	ra,24(sp)
    80005872:	e822                	sd	s0,16(sp)
    80005874:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005876:	fe040613          	addi	a2,s0,-32
    8000587a:	fec40593          	addi	a1,s0,-20
    8000587e:	4501                	li	a0,0
    80005880:	00000097          	auipc	ra,0x0
    80005884:	cc2080e7          	jalr	-830(ra) # 80005542 <argfd>
    return -1;
    80005888:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000588a:	02054463          	bltz	a0,800058b2 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000588e:	ffffc097          	auipc	ra,0xffffc
    80005892:	138080e7          	jalr	312(ra) # 800019c6 <myproc>
    80005896:	fec42783          	lw	a5,-20(s0)
    8000589a:	07e9                	addi	a5,a5,26
    8000589c:	078e                	slli	a5,a5,0x3
    8000589e:	97aa                	add	a5,a5,a0
    800058a0:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800058a4:	fe043503          	ld	a0,-32(s0)
    800058a8:	fffff097          	auipc	ra,0xfffff
    800058ac:	272080e7          	jalr	626(ra) # 80004b1a <fileclose>
  return 0;
    800058b0:	4781                	li	a5,0
}
    800058b2:	853e                	mv	a0,a5
    800058b4:	60e2                	ld	ra,24(sp)
    800058b6:	6442                	ld	s0,16(sp)
    800058b8:	6105                	addi	sp,sp,32
    800058ba:	8082                	ret

00000000800058bc <sys_fstat>:
{
    800058bc:	1101                	addi	sp,sp,-32
    800058be:	ec06                	sd	ra,24(sp)
    800058c0:	e822                	sd	s0,16(sp)
    800058c2:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800058c4:	fe040593          	addi	a1,s0,-32
    800058c8:	4505                	li	a0,1
    800058ca:	ffffd097          	auipc	ra,0xffffd
    800058ce:	5c6080e7          	jalr	1478(ra) # 80002e90 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800058d2:	fe840613          	addi	a2,s0,-24
    800058d6:	4581                	li	a1,0
    800058d8:	4501                	li	a0,0
    800058da:	00000097          	auipc	ra,0x0
    800058de:	c68080e7          	jalr	-920(ra) # 80005542 <argfd>
    800058e2:	87aa                	mv	a5,a0
    return -1;
    800058e4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800058e6:	0007ca63          	bltz	a5,800058fa <sys_fstat+0x3e>
  return filestat(f, st);
    800058ea:	fe043583          	ld	a1,-32(s0)
    800058ee:	fe843503          	ld	a0,-24(s0)
    800058f2:	fffff097          	auipc	ra,0xfffff
    800058f6:	2f0080e7          	jalr	752(ra) # 80004be2 <filestat>
}
    800058fa:	60e2                	ld	ra,24(sp)
    800058fc:	6442                	ld	s0,16(sp)
    800058fe:	6105                	addi	sp,sp,32
    80005900:	8082                	ret

0000000080005902 <sys_link>:
{
    80005902:	7169                	addi	sp,sp,-304
    80005904:	f606                	sd	ra,296(sp)
    80005906:	f222                	sd	s0,288(sp)
    80005908:	ee26                	sd	s1,280(sp)
    8000590a:	ea4a                	sd	s2,272(sp)
    8000590c:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000590e:	08000613          	li	a2,128
    80005912:	ed040593          	addi	a1,s0,-304
    80005916:	4501                	li	a0,0
    80005918:	ffffd097          	auipc	ra,0xffffd
    8000591c:	59a080e7          	jalr	1434(ra) # 80002eb2 <argstr>
    return -1;
    80005920:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005922:	10054e63          	bltz	a0,80005a3e <sys_link+0x13c>
    80005926:	08000613          	li	a2,128
    8000592a:	f5040593          	addi	a1,s0,-176
    8000592e:	4505                	li	a0,1
    80005930:	ffffd097          	auipc	ra,0xffffd
    80005934:	582080e7          	jalr	1410(ra) # 80002eb2 <argstr>
    return -1;
    80005938:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000593a:	10054263          	bltz	a0,80005a3e <sys_link+0x13c>
  begin_op();
    8000593e:	fffff097          	auipc	ra,0xfffff
    80005942:	d10080e7          	jalr	-752(ra) # 8000464e <begin_op>
  if((ip = namei(old)) == 0){
    80005946:	ed040513          	addi	a0,s0,-304
    8000594a:	fffff097          	auipc	ra,0xfffff
    8000594e:	ae8080e7          	jalr	-1304(ra) # 80004432 <namei>
    80005952:	84aa                	mv	s1,a0
    80005954:	c551                	beqz	a0,800059e0 <sys_link+0xde>
  ilock(ip);
    80005956:	ffffe097          	auipc	ra,0xffffe
    8000595a:	336080e7          	jalr	822(ra) # 80003c8c <ilock>
  if(ip->type == T_DIR){
    8000595e:	04449703          	lh	a4,68(s1)
    80005962:	4785                	li	a5,1
    80005964:	08f70463          	beq	a4,a5,800059ec <sys_link+0xea>
  ip->nlink++;
    80005968:	04a4d783          	lhu	a5,74(s1)
    8000596c:	2785                	addiw	a5,a5,1
    8000596e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005972:	8526                	mv	a0,s1
    80005974:	ffffe097          	auipc	ra,0xffffe
    80005978:	24e080e7          	jalr	590(ra) # 80003bc2 <iupdate>
  iunlock(ip);
    8000597c:	8526                	mv	a0,s1
    8000597e:	ffffe097          	auipc	ra,0xffffe
    80005982:	3d0080e7          	jalr	976(ra) # 80003d4e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005986:	fd040593          	addi	a1,s0,-48
    8000598a:	f5040513          	addi	a0,s0,-176
    8000598e:	fffff097          	auipc	ra,0xfffff
    80005992:	ac2080e7          	jalr	-1342(ra) # 80004450 <nameiparent>
    80005996:	892a                	mv	s2,a0
    80005998:	c935                	beqz	a0,80005a0c <sys_link+0x10a>
  ilock(dp);
    8000599a:	ffffe097          	auipc	ra,0xffffe
    8000599e:	2f2080e7          	jalr	754(ra) # 80003c8c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800059a2:	00092703          	lw	a4,0(s2)
    800059a6:	409c                	lw	a5,0(s1)
    800059a8:	04f71d63          	bne	a4,a5,80005a02 <sys_link+0x100>
    800059ac:	40d0                	lw	a2,4(s1)
    800059ae:	fd040593          	addi	a1,s0,-48
    800059b2:	854a                	mv	a0,s2
    800059b4:	fffff097          	auipc	ra,0xfffff
    800059b8:	9cc080e7          	jalr	-1588(ra) # 80004380 <dirlink>
    800059bc:	04054363          	bltz	a0,80005a02 <sys_link+0x100>
  iunlockput(dp);
    800059c0:	854a                	mv	a0,s2
    800059c2:	ffffe097          	auipc	ra,0xffffe
    800059c6:	52c080e7          	jalr	1324(ra) # 80003eee <iunlockput>
  iput(ip);
    800059ca:	8526                	mv	a0,s1
    800059cc:	ffffe097          	auipc	ra,0xffffe
    800059d0:	47a080e7          	jalr	1146(ra) # 80003e46 <iput>
  end_op();
    800059d4:	fffff097          	auipc	ra,0xfffff
    800059d8:	cfa080e7          	jalr	-774(ra) # 800046ce <end_op>
  return 0;
    800059dc:	4781                	li	a5,0
    800059de:	a085                	j	80005a3e <sys_link+0x13c>
    end_op();
    800059e0:	fffff097          	auipc	ra,0xfffff
    800059e4:	cee080e7          	jalr	-786(ra) # 800046ce <end_op>
    return -1;
    800059e8:	57fd                	li	a5,-1
    800059ea:	a891                	j	80005a3e <sys_link+0x13c>
    iunlockput(ip);
    800059ec:	8526                	mv	a0,s1
    800059ee:	ffffe097          	auipc	ra,0xffffe
    800059f2:	500080e7          	jalr	1280(ra) # 80003eee <iunlockput>
    end_op();
    800059f6:	fffff097          	auipc	ra,0xfffff
    800059fa:	cd8080e7          	jalr	-808(ra) # 800046ce <end_op>
    return -1;
    800059fe:	57fd                	li	a5,-1
    80005a00:	a83d                	j	80005a3e <sys_link+0x13c>
    iunlockput(dp);
    80005a02:	854a                	mv	a0,s2
    80005a04:	ffffe097          	auipc	ra,0xffffe
    80005a08:	4ea080e7          	jalr	1258(ra) # 80003eee <iunlockput>
  ilock(ip);
    80005a0c:	8526                	mv	a0,s1
    80005a0e:	ffffe097          	auipc	ra,0xffffe
    80005a12:	27e080e7          	jalr	638(ra) # 80003c8c <ilock>
  ip->nlink--;
    80005a16:	04a4d783          	lhu	a5,74(s1)
    80005a1a:	37fd                	addiw	a5,a5,-1
    80005a1c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005a20:	8526                	mv	a0,s1
    80005a22:	ffffe097          	auipc	ra,0xffffe
    80005a26:	1a0080e7          	jalr	416(ra) # 80003bc2 <iupdate>
  iunlockput(ip);
    80005a2a:	8526                	mv	a0,s1
    80005a2c:	ffffe097          	auipc	ra,0xffffe
    80005a30:	4c2080e7          	jalr	1218(ra) # 80003eee <iunlockput>
  end_op();
    80005a34:	fffff097          	auipc	ra,0xfffff
    80005a38:	c9a080e7          	jalr	-870(ra) # 800046ce <end_op>
  return -1;
    80005a3c:	57fd                	li	a5,-1
}
    80005a3e:	853e                	mv	a0,a5
    80005a40:	70b2                	ld	ra,296(sp)
    80005a42:	7412                	ld	s0,288(sp)
    80005a44:	64f2                	ld	s1,280(sp)
    80005a46:	6952                	ld	s2,272(sp)
    80005a48:	6155                	addi	sp,sp,304
    80005a4a:	8082                	ret

0000000080005a4c <sys_unlink>:
{
    80005a4c:	7151                	addi	sp,sp,-240
    80005a4e:	f586                	sd	ra,232(sp)
    80005a50:	f1a2                	sd	s0,224(sp)
    80005a52:	eda6                	sd	s1,216(sp)
    80005a54:	e9ca                	sd	s2,208(sp)
    80005a56:	e5ce                	sd	s3,200(sp)
    80005a58:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005a5a:	08000613          	li	a2,128
    80005a5e:	f3040593          	addi	a1,s0,-208
    80005a62:	4501                	li	a0,0
    80005a64:	ffffd097          	auipc	ra,0xffffd
    80005a68:	44e080e7          	jalr	1102(ra) # 80002eb2 <argstr>
    80005a6c:	18054163          	bltz	a0,80005bee <sys_unlink+0x1a2>
  begin_op();
    80005a70:	fffff097          	auipc	ra,0xfffff
    80005a74:	bde080e7          	jalr	-1058(ra) # 8000464e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005a78:	fb040593          	addi	a1,s0,-80
    80005a7c:	f3040513          	addi	a0,s0,-208
    80005a80:	fffff097          	auipc	ra,0xfffff
    80005a84:	9d0080e7          	jalr	-1584(ra) # 80004450 <nameiparent>
    80005a88:	84aa                	mv	s1,a0
    80005a8a:	c979                	beqz	a0,80005b60 <sys_unlink+0x114>
  ilock(dp);
    80005a8c:	ffffe097          	auipc	ra,0xffffe
    80005a90:	200080e7          	jalr	512(ra) # 80003c8c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005a94:	00003597          	auipc	a1,0x3
    80005a98:	e1458593          	addi	a1,a1,-492 # 800088a8 <syscallnum+0x258>
    80005a9c:	fb040513          	addi	a0,s0,-80
    80005aa0:	ffffe097          	auipc	ra,0xffffe
    80005aa4:	6b6080e7          	jalr	1718(ra) # 80004156 <namecmp>
    80005aa8:	14050a63          	beqz	a0,80005bfc <sys_unlink+0x1b0>
    80005aac:	00003597          	auipc	a1,0x3
    80005ab0:	e0458593          	addi	a1,a1,-508 # 800088b0 <syscallnum+0x260>
    80005ab4:	fb040513          	addi	a0,s0,-80
    80005ab8:	ffffe097          	auipc	ra,0xffffe
    80005abc:	69e080e7          	jalr	1694(ra) # 80004156 <namecmp>
    80005ac0:	12050e63          	beqz	a0,80005bfc <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005ac4:	f2c40613          	addi	a2,s0,-212
    80005ac8:	fb040593          	addi	a1,s0,-80
    80005acc:	8526                	mv	a0,s1
    80005ace:	ffffe097          	auipc	ra,0xffffe
    80005ad2:	6a2080e7          	jalr	1698(ra) # 80004170 <dirlookup>
    80005ad6:	892a                	mv	s2,a0
    80005ad8:	12050263          	beqz	a0,80005bfc <sys_unlink+0x1b0>
  ilock(ip);
    80005adc:	ffffe097          	auipc	ra,0xffffe
    80005ae0:	1b0080e7          	jalr	432(ra) # 80003c8c <ilock>
  if(ip->nlink < 1)
    80005ae4:	04a91783          	lh	a5,74(s2)
    80005ae8:	08f05263          	blez	a5,80005b6c <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005aec:	04491703          	lh	a4,68(s2)
    80005af0:	4785                	li	a5,1
    80005af2:	08f70563          	beq	a4,a5,80005b7c <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005af6:	4641                	li	a2,16
    80005af8:	4581                	li	a1,0
    80005afa:	fc040513          	addi	a0,s0,-64
    80005afe:	ffffb097          	auipc	ra,0xffffb
    80005b02:	1e8080e7          	jalr	488(ra) # 80000ce6 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b06:	4741                	li	a4,16
    80005b08:	f2c42683          	lw	a3,-212(s0)
    80005b0c:	fc040613          	addi	a2,s0,-64
    80005b10:	4581                	li	a1,0
    80005b12:	8526                	mv	a0,s1
    80005b14:	ffffe097          	auipc	ra,0xffffe
    80005b18:	524080e7          	jalr	1316(ra) # 80004038 <writei>
    80005b1c:	47c1                	li	a5,16
    80005b1e:	0af51563          	bne	a0,a5,80005bc8 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005b22:	04491703          	lh	a4,68(s2)
    80005b26:	4785                	li	a5,1
    80005b28:	0af70863          	beq	a4,a5,80005bd8 <sys_unlink+0x18c>
  iunlockput(dp);
    80005b2c:	8526                	mv	a0,s1
    80005b2e:	ffffe097          	auipc	ra,0xffffe
    80005b32:	3c0080e7          	jalr	960(ra) # 80003eee <iunlockput>
  ip->nlink--;
    80005b36:	04a95783          	lhu	a5,74(s2)
    80005b3a:	37fd                	addiw	a5,a5,-1
    80005b3c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005b40:	854a                	mv	a0,s2
    80005b42:	ffffe097          	auipc	ra,0xffffe
    80005b46:	080080e7          	jalr	128(ra) # 80003bc2 <iupdate>
  iunlockput(ip);
    80005b4a:	854a                	mv	a0,s2
    80005b4c:	ffffe097          	auipc	ra,0xffffe
    80005b50:	3a2080e7          	jalr	930(ra) # 80003eee <iunlockput>
  end_op();
    80005b54:	fffff097          	auipc	ra,0xfffff
    80005b58:	b7a080e7          	jalr	-1158(ra) # 800046ce <end_op>
  return 0;
    80005b5c:	4501                	li	a0,0
    80005b5e:	a84d                	j	80005c10 <sys_unlink+0x1c4>
    end_op();
    80005b60:	fffff097          	auipc	ra,0xfffff
    80005b64:	b6e080e7          	jalr	-1170(ra) # 800046ce <end_op>
    return -1;
    80005b68:	557d                	li	a0,-1
    80005b6a:	a05d                	j	80005c10 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005b6c:	00003517          	auipc	a0,0x3
    80005b70:	d4c50513          	addi	a0,a0,-692 # 800088b8 <syscallnum+0x268>
    80005b74:	ffffb097          	auipc	ra,0xffffb
    80005b78:	9d0080e7          	jalr	-1584(ra) # 80000544 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b7c:	04c92703          	lw	a4,76(s2)
    80005b80:	02000793          	li	a5,32
    80005b84:	f6e7f9e3          	bgeu	a5,a4,80005af6 <sys_unlink+0xaa>
    80005b88:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b8c:	4741                	li	a4,16
    80005b8e:	86ce                	mv	a3,s3
    80005b90:	f1840613          	addi	a2,s0,-232
    80005b94:	4581                	li	a1,0
    80005b96:	854a                	mv	a0,s2
    80005b98:	ffffe097          	auipc	ra,0xffffe
    80005b9c:	3a8080e7          	jalr	936(ra) # 80003f40 <readi>
    80005ba0:	47c1                	li	a5,16
    80005ba2:	00f51b63          	bne	a0,a5,80005bb8 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005ba6:	f1845783          	lhu	a5,-232(s0)
    80005baa:	e7a1                	bnez	a5,80005bf2 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005bac:	29c1                	addiw	s3,s3,16
    80005bae:	04c92783          	lw	a5,76(s2)
    80005bb2:	fcf9ede3          	bltu	s3,a5,80005b8c <sys_unlink+0x140>
    80005bb6:	b781                	j	80005af6 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005bb8:	00003517          	auipc	a0,0x3
    80005bbc:	d1850513          	addi	a0,a0,-744 # 800088d0 <syscallnum+0x280>
    80005bc0:	ffffb097          	auipc	ra,0xffffb
    80005bc4:	984080e7          	jalr	-1660(ra) # 80000544 <panic>
    panic("unlink: writei");
    80005bc8:	00003517          	auipc	a0,0x3
    80005bcc:	d2050513          	addi	a0,a0,-736 # 800088e8 <syscallnum+0x298>
    80005bd0:	ffffb097          	auipc	ra,0xffffb
    80005bd4:	974080e7          	jalr	-1676(ra) # 80000544 <panic>
    dp->nlink--;
    80005bd8:	04a4d783          	lhu	a5,74(s1)
    80005bdc:	37fd                	addiw	a5,a5,-1
    80005bde:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005be2:	8526                	mv	a0,s1
    80005be4:	ffffe097          	auipc	ra,0xffffe
    80005be8:	fde080e7          	jalr	-34(ra) # 80003bc2 <iupdate>
    80005bec:	b781                	j	80005b2c <sys_unlink+0xe0>
    return -1;
    80005bee:	557d                	li	a0,-1
    80005bf0:	a005                	j	80005c10 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005bf2:	854a                	mv	a0,s2
    80005bf4:	ffffe097          	auipc	ra,0xffffe
    80005bf8:	2fa080e7          	jalr	762(ra) # 80003eee <iunlockput>
  iunlockput(dp);
    80005bfc:	8526                	mv	a0,s1
    80005bfe:	ffffe097          	auipc	ra,0xffffe
    80005c02:	2f0080e7          	jalr	752(ra) # 80003eee <iunlockput>
  end_op();
    80005c06:	fffff097          	auipc	ra,0xfffff
    80005c0a:	ac8080e7          	jalr	-1336(ra) # 800046ce <end_op>
  return -1;
    80005c0e:	557d                	li	a0,-1
}
    80005c10:	70ae                	ld	ra,232(sp)
    80005c12:	740e                	ld	s0,224(sp)
    80005c14:	64ee                	ld	s1,216(sp)
    80005c16:	694e                	ld	s2,208(sp)
    80005c18:	69ae                	ld	s3,200(sp)
    80005c1a:	616d                	addi	sp,sp,240
    80005c1c:	8082                	ret

0000000080005c1e <sys_open>:

uint64
sys_open(void)
{
    80005c1e:	7131                	addi	sp,sp,-192
    80005c20:	fd06                	sd	ra,184(sp)
    80005c22:	f922                	sd	s0,176(sp)
    80005c24:	f526                	sd	s1,168(sp)
    80005c26:	f14a                	sd	s2,160(sp)
    80005c28:	ed4e                	sd	s3,152(sp)
    80005c2a:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005c2c:	f4c40593          	addi	a1,s0,-180
    80005c30:	4505                	li	a0,1
    80005c32:	ffffd097          	auipc	ra,0xffffd
    80005c36:	23c080e7          	jalr	572(ra) # 80002e6e <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005c3a:	08000613          	li	a2,128
    80005c3e:	f5040593          	addi	a1,s0,-176
    80005c42:	4501                	li	a0,0
    80005c44:	ffffd097          	auipc	ra,0xffffd
    80005c48:	26e080e7          	jalr	622(ra) # 80002eb2 <argstr>
    80005c4c:	87aa                	mv	a5,a0
    return -1;
    80005c4e:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005c50:	0a07c963          	bltz	a5,80005d02 <sys_open+0xe4>

  begin_op();
    80005c54:	fffff097          	auipc	ra,0xfffff
    80005c58:	9fa080e7          	jalr	-1542(ra) # 8000464e <begin_op>

  if(omode & O_CREATE){
    80005c5c:	f4c42783          	lw	a5,-180(s0)
    80005c60:	2007f793          	andi	a5,a5,512
    80005c64:	cfc5                	beqz	a5,80005d1c <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005c66:	4681                	li	a3,0
    80005c68:	4601                	li	a2,0
    80005c6a:	4589                	li	a1,2
    80005c6c:	f5040513          	addi	a0,s0,-176
    80005c70:	00000097          	auipc	ra,0x0
    80005c74:	974080e7          	jalr	-1676(ra) # 800055e4 <create>
    80005c78:	84aa                	mv	s1,a0
    if(ip == 0){
    80005c7a:	c959                	beqz	a0,80005d10 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005c7c:	04449703          	lh	a4,68(s1)
    80005c80:	478d                	li	a5,3
    80005c82:	00f71763          	bne	a4,a5,80005c90 <sys_open+0x72>
    80005c86:	0464d703          	lhu	a4,70(s1)
    80005c8a:	47a5                	li	a5,9
    80005c8c:	0ce7ed63          	bltu	a5,a4,80005d66 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005c90:	fffff097          	auipc	ra,0xfffff
    80005c94:	dce080e7          	jalr	-562(ra) # 80004a5e <filealloc>
    80005c98:	89aa                	mv	s3,a0
    80005c9a:	10050363          	beqz	a0,80005da0 <sys_open+0x182>
    80005c9e:	00000097          	auipc	ra,0x0
    80005ca2:	904080e7          	jalr	-1788(ra) # 800055a2 <fdalloc>
    80005ca6:	892a                	mv	s2,a0
    80005ca8:	0e054763          	bltz	a0,80005d96 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005cac:	04449703          	lh	a4,68(s1)
    80005cb0:	478d                	li	a5,3
    80005cb2:	0cf70563          	beq	a4,a5,80005d7c <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005cb6:	4789                	li	a5,2
    80005cb8:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005cbc:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005cc0:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005cc4:	f4c42783          	lw	a5,-180(s0)
    80005cc8:	0017c713          	xori	a4,a5,1
    80005ccc:	8b05                	andi	a4,a4,1
    80005cce:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005cd2:	0037f713          	andi	a4,a5,3
    80005cd6:	00e03733          	snez	a4,a4
    80005cda:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005cde:	4007f793          	andi	a5,a5,1024
    80005ce2:	c791                	beqz	a5,80005cee <sys_open+0xd0>
    80005ce4:	04449703          	lh	a4,68(s1)
    80005ce8:	4789                	li	a5,2
    80005cea:	0af70063          	beq	a4,a5,80005d8a <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005cee:	8526                	mv	a0,s1
    80005cf0:	ffffe097          	auipc	ra,0xffffe
    80005cf4:	05e080e7          	jalr	94(ra) # 80003d4e <iunlock>
  end_op();
    80005cf8:	fffff097          	auipc	ra,0xfffff
    80005cfc:	9d6080e7          	jalr	-1578(ra) # 800046ce <end_op>

  return fd;
    80005d00:	854a                	mv	a0,s2
}
    80005d02:	70ea                	ld	ra,184(sp)
    80005d04:	744a                	ld	s0,176(sp)
    80005d06:	74aa                	ld	s1,168(sp)
    80005d08:	790a                	ld	s2,160(sp)
    80005d0a:	69ea                	ld	s3,152(sp)
    80005d0c:	6129                	addi	sp,sp,192
    80005d0e:	8082                	ret
      end_op();
    80005d10:	fffff097          	auipc	ra,0xfffff
    80005d14:	9be080e7          	jalr	-1602(ra) # 800046ce <end_op>
      return -1;
    80005d18:	557d                	li	a0,-1
    80005d1a:	b7e5                	j	80005d02 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005d1c:	f5040513          	addi	a0,s0,-176
    80005d20:	ffffe097          	auipc	ra,0xffffe
    80005d24:	712080e7          	jalr	1810(ra) # 80004432 <namei>
    80005d28:	84aa                	mv	s1,a0
    80005d2a:	c905                	beqz	a0,80005d5a <sys_open+0x13c>
    ilock(ip);
    80005d2c:	ffffe097          	auipc	ra,0xffffe
    80005d30:	f60080e7          	jalr	-160(ra) # 80003c8c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005d34:	04449703          	lh	a4,68(s1)
    80005d38:	4785                	li	a5,1
    80005d3a:	f4f711e3          	bne	a4,a5,80005c7c <sys_open+0x5e>
    80005d3e:	f4c42783          	lw	a5,-180(s0)
    80005d42:	d7b9                	beqz	a5,80005c90 <sys_open+0x72>
      iunlockput(ip);
    80005d44:	8526                	mv	a0,s1
    80005d46:	ffffe097          	auipc	ra,0xffffe
    80005d4a:	1a8080e7          	jalr	424(ra) # 80003eee <iunlockput>
      end_op();
    80005d4e:	fffff097          	auipc	ra,0xfffff
    80005d52:	980080e7          	jalr	-1664(ra) # 800046ce <end_op>
      return -1;
    80005d56:	557d                	li	a0,-1
    80005d58:	b76d                	j	80005d02 <sys_open+0xe4>
      end_op();
    80005d5a:	fffff097          	auipc	ra,0xfffff
    80005d5e:	974080e7          	jalr	-1676(ra) # 800046ce <end_op>
      return -1;
    80005d62:	557d                	li	a0,-1
    80005d64:	bf79                	j	80005d02 <sys_open+0xe4>
    iunlockput(ip);
    80005d66:	8526                	mv	a0,s1
    80005d68:	ffffe097          	auipc	ra,0xffffe
    80005d6c:	186080e7          	jalr	390(ra) # 80003eee <iunlockput>
    end_op();
    80005d70:	fffff097          	auipc	ra,0xfffff
    80005d74:	95e080e7          	jalr	-1698(ra) # 800046ce <end_op>
    return -1;
    80005d78:	557d                	li	a0,-1
    80005d7a:	b761                	j	80005d02 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005d7c:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005d80:	04649783          	lh	a5,70(s1)
    80005d84:	02f99223          	sh	a5,36(s3)
    80005d88:	bf25                	j	80005cc0 <sys_open+0xa2>
    itrunc(ip);
    80005d8a:	8526                	mv	a0,s1
    80005d8c:	ffffe097          	auipc	ra,0xffffe
    80005d90:	00e080e7          	jalr	14(ra) # 80003d9a <itrunc>
    80005d94:	bfa9                	j	80005cee <sys_open+0xd0>
      fileclose(f);
    80005d96:	854e                	mv	a0,s3
    80005d98:	fffff097          	auipc	ra,0xfffff
    80005d9c:	d82080e7          	jalr	-638(ra) # 80004b1a <fileclose>
    iunlockput(ip);
    80005da0:	8526                	mv	a0,s1
    80005da2:	ffffe097          	auipc	ra,0xffffe
    80005da6:	14c080e7          	jalr	332(ra) # 80003eee <iunlockput>
    end_op();
    80005daa:	fffff097          	auipc	ra,0xfffff
    80005dae:	924080e7          	jalr	-1756(ra) # 800046ce <end_op>
    return -1;
    80005db2:	557d                	li	a0,-1
    80005db4:	b7b9                	j	80005d02 <sys_open+0xe4>

0000000080005db6 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005db6:	7175                	addi	sp,sp,-144
    80005db8:	e506                	sd	ra,136(sp)
    80005dba:	e122                	sd	s0,128(sp)
    80005dbc:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005dbe:	fffff097          	auipc	ra,0xfffff
    80005dc2:	890080e7          	jalr	-1904(ra) # 8000464e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005dc6:	08000613          	li	a2,128
    80005dca:	f7040593          	addi	a1,s0,-144
    80005dce:	4501                	li	a0,0
    80005dd0:	ffffd097          	auipc	ra,0xffffd
    80005dd4:	0e2080e7          	jalr	226(ra) # 80002eb2 <argstr>
    80005dd8:	02054963          	bltz	a0,80005e0a <sys_mkdir+0x54>
    80005ddc:	4681                	li	a3,0
    80005dde:	4601                	li	a2,0
    80005de0:	4585                	li	a1,1
    80005de2:	f7040513          	addi	a0,s0,-144
    80005de6:	fffff097          	auipc	ra,0xfffff
    80005dea:	7fe080e7          	jalr	2046(ra) # 800055e4 <create>
    80005dee:	cd11                	beqz	a0,80005e0a <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005df0:	ffffe097          	auipc	ra,0xffffe
    80005df4:	0fe080e7          	jalr	254(ra) # 80003eee <iunlockput>
  end_op();
    80005df8:	fffff097          	auipc	ra,0xfffff
    80005dfc:	8d6080e7          	jalr	-1834(ra) # 800046ce <end_op>
  return 0;
    80005e00:	4501                	li	a0,0
}
    80005e02:	60aa                	ld	ra,136(sp)
    80005e04:	640a                	ld	s0,128(sp)
    80005e06:	6149                	addi	sp,sp,144
    80005e08:	8082                	ret
    end_op();
    80005e0a:	fffff097          	auipc	ra,0xfffff
    80005e0e:	8c4080e7          	jalr	-1852(ra) # 800046ce <end_op>
    return -1;
    80005e12:	557d                	li	a0,-1
    80005e14:	b7fd                	j	80005e02 <sys_mkdir+0x4c>

0000000080005e16 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005e16:	7135                	addi	sp,sp,-160
    80005e18:	ed06                	sd	ra,152(sp)
    80005e1a:	e922                	sd	s0,144(sp)
    80005e1c:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005e1e:	fffff097          	auipc	ra,0xfffff
    80005e22:	830080e7          	jalr	-2000(ra) # 8000464e <begin_op>
  argint(1, &major);
    80005e26:	f6c40593          	addi	a1,s0,-148
    80005e2a:	4505                	li	a0,1
    80005e2c:	ffffd097          	auipc	ra,0xffffd
    80005e30:	042080e7          	jalr	66(ra) # 80002e6e <argint>
  argint(2, &minor);
    80005e34:	f6840593          	addi	a1,s0,-152
    80005e38:	4509                	li	a0,2
    80005e3a:	ffffd097          	auipc	ra,0xffffd
    80005e3e:	034080e7          	jalr	52(ra) # 80002e6e <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e42:	08000613          	li	a2,128
    80005e46:	f7040593          	addi	a1,s0,-144
    80005e4a:	4501                	li	a0,0
    80005e4c:	ffffd097          	auipc	ra,0xffffd
    80005e50:	066080e7          	jalr	102(ra) # 80002eb2 <argstr>
    80005e54:	02054b63          	bltz	a0,80005e8a <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005e58:	f6841683          	lh	a3,-152(s0)
    80005e5c:	f6c41603          	lh	a2,-148(s0)
    80005e60:	458d                	li	a1,3
    80005e62:	f7040513          	addi	a0,s0,-144
    80005e66:	fffff097          	auipc	ra,0xfffff
    80005e6a:	77e080e7          	jalr	1918(ra) # 800055e4 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e6e:	cd11                	beqz	a0,80005e8a <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005e70:	ffffe097          	auipc	ra,0xffffe
    80005e74:	07e080e7          	jalr	126(ra) # 80003eee <iunlockput>
  end_op();
    80005e78:	fffff097          	auipc	ra,0xfffff
    80005e7c:	856080e7          	jalr	-1962(ra) # 800046ce <end_op>
  return 0;
    80005e80:	4501                	li	a0,0
}
    80005e82:	60ea                	ld	ra,152(sp)
    80005e84:	644a                	ld	s0,144(sp)
    80005e86:	610d                	addi	sp,sp,160
    80005e88:	8082                	ret
    end_op();
    80005e8a:	fffff097          	auipc	ra,0xfffff
    80005e8e:	844080e7          	jalr	-1980(ra) # 800046ce <end_op>
    return -1;
    80005e92:	557d                	li	a0,-1
    80005e94:	b7fd                	j	80005e82 <sys_mknod+0x6c>

0000000080005e96 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005e96:	7135                	addi	sp,sp,-160
    80005e98:	ed06                	sd	ra,152(sp)
    80005e9a:	e922                	sd	s0,144(sp)
    80005e9c:	e526                	sd	s1,136(sp)
    80005e9e:	e14a                	sd	s2,128(sp)
    80005ea0:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005ea2:	ffffc097          	auipc	ra,0xffffc
    80005ea6:	b24080e7          	jalr	-1244(ra) # 800019c6 <myproc>
    80005eaa:	892a                	mv	s2,a0
  
  begin_op();
    80005eac:	ffffe097          	auipc	ra,0xffffe
    80005eb0:	7a2080e7          	jalr	1954(ra) # 8000464e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005eb4:	08000613          	li	a2,128
    80005eb8:	f6040593          	addi	a1,s0,-160
    80005ebc:	4501                	li	a0,0
    80005ebe:	ffffd097          	auipc	ra,0xffffd
    80005ec2:	ff4080e7          	jalr	-12(ra) # 80002eb2 <argstr>
    80005ec6:	04054b63          	bltz	a0,80005f1c <sys_chdir+0x86>
    80005eca:	f6040513          	addi	a0,s0,-160
    80005ece:	ffffe097          	auipc	ra,0xffffe
    80005ed2:	564080e7          	jalr	1380(ra) # 80004432 <namei>
    80005ed6:	84aa                	mv	s1,a0
    80005ed8:	c131                	beqz	a0,80005f1c <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005eda:	ffffe097          	auipc	ra,0xffffe
    80005ede:	db2080e7          	jalr	-590(ra) # 80003c8c <ilock>
  if(ip->type != T_DIR){
    80005ee2:	04449703          	lh	a4,68(s1)
    80005ee6:	4785                	li	a5,1
    80005ee8:	04f71063          	bne	a4,a5,80005f28 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005eec:	8526                	mv	a0,s1
    80005eee:	ffffe097          	auipc	ra,0xffffe
    80005ef2:	e60080e7          	jalr	-416(ra) # 80003d4e <iunlock>
  iput(p->cwd);
    80005ef6:	15093503          	ld	a0,336(s2)
    80005efa:	ffffe097          	auipc	ra,0xffffe
    80005efe:	f4c080e7          	jalr	-180(ra) # 80003e46 <iput>
  end_op();
    80005f02:	ffffe097          	auipc	ra,0xffffe
    80005f06:	7cc080e7          	jalr	1996(ra) # 800046ce <end_op>
  p->cwd = ip;
    80005f0a:	14993823          	sd	s1,336(s2)
  return 0;
    80005f0e:	4501                	li	a0,0
}
    80005f10:	60ea                	ld	ra,152(sp)
    80005f12:	644a                	ld	s0,144(sp)
    80005f14:	64aa                	ld	s1,136(sp)
    80005f16:	690a                	ld	s2,128(sp)
    80005f18:	610d                	addi	sp,sp,160
    80005f1a:	8082                	ret
    end_op();
    80005f1c:	ffffe097          	auipc	ra,0xffffe
    80005f20:	7b2080e7          	jalr	1970(ra) # 800046ce <end_op>
    return -1;
    80005f24:	557d                	li	a0,-1
    80005f26:	b7ed                	j	80005f10 <sys_chdir+0x7a>
    iunlockput(ip);
    80005f28:	8526                	mv	a0,s1
    80005f2a:	ffffe097          	auipc	ra,0xffffe
    80005f2e:	fc4080e7          	jalr	-60(ra) # 80003eee <iunlockput>
    end_op();
    80005f32:	ffffe097          	auipc	ra,0xffffe
    80005f36:	79c080e7          	jalr	1948(ra) # 800046ce <end_op>
    return -1;
    80005f3a:	557d                	li	a0,-1
    80005f3c:	bfd1                	j	80005f10 <sys_chdir+0x7a>

0000000080005f3e <sys_exec>:

uint64
sys_exec(void)
{
    80005f3e:	7145                	addi	sp,sp,-464
    80005f40:	e786                	sd	ra,456(sp)
    80005f42:	e3a2                	sd	s0,448(sp)
    80005f44:	ff26                	sd	s1,440(sp)
    80005f46:	fb4a                	sd	s2,432(sp)
    80005f48:	f74e                	sd	s3,424(sp)
    80005f4a:	f352                	sd	s4,416(sp)
    80005f4c:	ef56                	sd	s5,408(sp)
    80005f4e:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005f50:	e3840593          	addi	a1,s0,-456
    80005f54:	4505                	li	a0,1
    80005f56:	ffffd097          	auipc	ra,0xffffd
    80005f5a:	f3a080e7          	jalr	-198(ra) # 80002e90 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005f5e:	08000613          	li	a2,128
    80005f62:	f4040593          	addi	a1,s0,-192
    80005f66:	4501                	li	a0,0
    80005f68:	ffffd097          	auipc	ra,0xffffd
    80005f6c:	f4a080e7          	jalr	-182(ra) # 80002eb2 <argstr>
    80005f70:	87aa                	mv	a5,a0
    return -1;
    80005f72:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005f74:	0c07c263          	bltz	a5,80006038 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005f78:	10000613          	li	a2,256
    80005f7c:	4581                	li	a1,0
    80005f7e:	e4040513          	addi	a0,s0,-448
    80005f82:	ffffb097          	auipc	ra,0xffffb
    80005f86:	d64080e7          	jalr	-668(ra) # 80000ce6 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005f8a:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005f8e:	89a6                	mv	s3,s1
    80005f90:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005f92:	02000a13          	li	s4,32
    80005f96:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005f9a:	00391513          	slli	a0,s2,0x3
    80005f9e:	e3040593          	addi	a1,s0,-464
    80005fa2:	e3843783          	ld	a5,-456(s0)
    80005fa6:	953e                	add	a0,a0,a5
    80005fa8:	ffffd097          	auipc	ra,0xffffd
    80005fac:	e28080e7          	jalr	-472(ra) # 80002dd0 <fetchaddr>
    80005fb0:	02054a63          	bltz	a0,80005fe4 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005fb4:	e3043783          	ld	a5,-464(s0)
    80005fb8:	c3b9                	beqz	a5,80005ffe <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005fba:	ffffb097          	auipc	ra,0xffffb
    80005fbe:	b40080e7          	jalr	-1216(ra) # 80000afa <kalloc>
    80005fc2:	85aa                	mv	a1,a0
    80005fc4:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005fc8:	cd11                	beqz	a0,80005fe4 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005fca:	6605                	lui	a2,0x1
    80005fcc:	e3043503          	ld	a0,-464(s0)
    80005fd0:	ffffd097          	auipc	ra,0xffffd
    80005fd4:	e52080e7          	jalr	-430(ra) # 80002e22 <fetchstr>
    80005fd8:	00054663          	bltz	a0,80005fe4 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005fdc:	0905                	addi	s2,s2,1
    80005fde:	09a1                	addi	s3,s3,8
    80005fe0:	fb491be3          	bne	s2,s4,80005f96 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fe4:	10048913          	addi	s2,s1,256
    80005fe8:	6088                	ld	a0,0(s1)
    80005fea:	c531                	beqz	a0,80006036 <sys_exec+0xf8>
    kfree(argv[i]);
    80005fec:	ffffb097          	auipc	ra,0xffffb
    80005ff0:	a12080e7          	jalr	-1518(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ff4:	04a1                	addi	s1,s1,8
    80005ff6:	ff2499e3          	bne	s1,s2,80005fe8 <sys_exec+0xaa>
  return -1;
    80005ffa:	557d                	li	a0,-1
    80005ffc:	a835                	j	80006038 <sys_exec+0xfa>
      argv[i] = 0;
    80005ffe:	0a8e                	slli	s5,s5,0x3
    80006000:	fc040793          	addi	a5,s0,-64
    80006004:	9abe                	add	s5,s5,a5
    80006006:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    8000600a:	e4040593          	addi	a1,s0,-448
    8000600e:	f4040513          	addi	a0,s0,-192
    80006012:	fffff097          	auipc	ra,0xfffff
    80006016:	190080e7          	jalr	400(ra) # 800051a2 <exec>
    8000601a:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000601c:	10048993          	addi	s3,s1,256
    80006020:	6088                	ld	a0,0(s1)
    80006022:	c901                	beqz	a0,80006032 <sys_exec+0xf4>
    kfree(argv[i]);
    80006024:	ffffb097          	auipc	ra,0xffffb
    80006028:	9da080e7          	jalr	-1574(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000602c:	04a1                	addi	s1,s1,8
    8000602e:	ff3499e3          	bne	s1,s3,80006020 <sys_exec+0xe2>
  return ret;
    80006032:	854a                	mv	a0,s2
    80006034:	a011                	j	80006038 <sys_exec+0xfa>
  return -1;
    80006036:	557d                	li	a0,-1
}
    80006038:	60be                	ld	ra,456(sp)
    8000603a:	641e                	ld	s0,448(sp)
    8000603c:	74fa                	ld	s1,440(sp)
    8000603e:	795a                	ld	s2,432(sp)
    80006040:	79ba                	ld	s3,424(sp)
    80006042:	7a1a                	ld	s4,416(sp)
    80006044:	6afa                	ld	s5,408(sp)
    80006046:	6179                	addi	sp,sp,464
    80006048:	8082                	ret

000000008000604a <sys_pipe>:

uint64
sys_pipe(void)
{
    8000604a:	7139                	addi	sp,sp,-64
    8000604c:	fc06                	sd	ra,56(sp)
    8000604e:	f822                	sd	s0,48(sp)
    80006050:	f426                	sd	s1,40(sp)
    80006052:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006054:	ffffc097          	auipc	ra,0xffffc
    80006058:	972080e7          	jalr	-1678(ra) # 800019c6 <myproc>
    8000605c:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000605e:	fd840593          	addi	a1,s0,-40
    80006062:	4501                	li	a0,0
    80006064:	ffffd097          	auipc	ra,0xffffd
    80006068:	e2c080e7          	jalr	-468(ra) # 80002e90 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000606c:	fc840593          	addi	a1,s0,-56
    80006070:	fd040513          	addi	a0,s0,-48
    80006074:	fffff097          	auipc	ra,0xfffff
    80006078:	dd6080e7          	jalr	-554(ra) # 80004e4a <pipealloc>
    return -1;
    8000607c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000607e:	0c054463          	bltz	a0,80006146 <sys_pipe+0xfc>
  fd0 = -1;
    80006082:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006086:	fd043503          	ld	a0,-48(s0)
    8000608a:	fffff097          	auipc	ra,0xfffff
    8000608e:	518080e7          	jalr	1304(ra) # 800055a2 <fdalloc>
    80006092:	fca42223          	sw	a0,-60(s0)
    80006096:	08054b63          	bltz	a0,8000612c <sys_pipe+0xe2>
    8000609a:	fc843503          	ld	a0,-56(s0)
    8000609e:	fffff097          	auipc	ra,0xfffff
    800060a2:	504080e7          	jalr	1284(ra) # 800055a2 <fdalloc>
    800060a6:	fca42023          	sw	a0,-64(s0)
    800060aa:	06054863          	bltz	a0,8000611a <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800060ae:	4691                	li	a3,4
    800060b0:	fc440613          	addi	a2,s0,-60
    800060b4:	fd843583          	ld	a1,-40(s0)
    800060b8:	68a8                	ld	a0,80(s1)
    800060ba:	ffffb097          	auipc	ra,0xffffb
    800060be:	5ca080e7          	jalr	1482(ra) # 80001684 <copyout>
    800060c2:	02054063          	bltz	a0,800060e2 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800060c6:	4691                	li	a3,4
    800060c8:	fc040613          	addi	a2,s0,-64
    800060cc:	fd843583          	ld	a1,-40(s0)
    800060d0:	0591                	addi	a1,a1,4
    800060d2:	68a8                	ld	a0,80(s1)
    800060d4:	ffffb097          	auipc	ra,0xffffb
    800060d8:	5b0080e7          	jalr	1456(ra) # 80001684 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800060dc:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800060de:	06055463          	bgez	a0,80006146 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    800060e2:	fc442783          	lw	a5,-60(s0)
    800060e6:	07e9                	addi	a5,a5,26
    800060e8:	078e                	slli	a5,a5,0x3
    800060ea:	97a6                	add	a5,a5,s1
    800060ec:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800060f0:	fc042503          	lw	a0,-64(s0)
    800060f4:	0569                	addi	a0,a0,26
    800060f6:	050e                	slli	a0,a0,0x3
    800060f8:	94aa                	add	s1,s1,a0
    800060fa:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800060fe:	fd043503          	ld	a0,-48(s0)
    80006102:	fffff097          	auipc	ra,0xfffff
    80006106:	a18080e7          	jalr	-1512(ra) # 80004b1a <fileclose>
    fileclose(wf);
    8000610a:	fc843503          	ld	a0,-56(s0)
    8000610e:	fffff097          	auipc	ra,0xfffff
    80006112:	a0c080e7          	jalr	-1524(ra) # 80004b1a <fileclose>
    return -1;
    80006116:	57fd                	li	a5,-1
    80006118:	a03d                	j	80006146 <sys_pipe+0xfc>
    if(fd0 >= 0)
    8000611a:	fc442783          	lw	a5,-60(s0)
    8000611e:	0007c763          	bltz	a5,8000612c <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80006122:	07e9                	addi	a5,a5,26
    80006124:	078e                	slli	a5,a5,0x3
    80006126:	94be                	add	s1,s1,a5
    80006128:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000612c:	fd043503          	ld	a0,-48(s0)
    80006130:	fffff097          	auipc	ra,0xfffff
    80006134:	9ea080e7          	jalr	-1558(ra) # 80004b1a <fileclose>
    fileclose(wf);
    80006138:	fc843503          	ld	a0,-56(s0)
    8000613c:	fffff097          	auipc	ra,0xfffff
    80006140:	9de080e7          	jalr	-1570(ra) # 80004b1a <fileclose>
    return -1;
    80006144:	57fd                	li	a5,-1
}
    80006146:	853e                	mv	a0,a5
    80006148:	70e2                	ld	ra,56(sp)
    8000614a:	7442                	ld	s0,48(sp)
    8000614c:	74a2                	ld	s1,40(sp)
    8000614e:	6121                	addi	sp,sp,64
    80006150:	8082                	ret
	...

0000000080006160 <kernelvec>:
    80006160:	7111                	addi	sp,sp,-256
    80006162:	e006                	sd	ra,0(sp)
    80006164:	e40a                	sd	sp,8(sp)
    80006166:	e80e                	sd	gp,16(sp)
    80006168:	ec12                	sd	tp,24(sp)
    8000616a:	f016                	sd	t0,32(sp)
    8000616c:	f41a                	sd	t1,40(sp)
    8000616e:	f81e                	sd	t2,48(sp)
    80006170:	fc22                	sd	s0,56(sp)
    80006172:	e0a6                	sd	s1,64(sp)
    80006174:	e4aa                	sd	a0,72(sp)
    80006176:	e8ae                	sd	a1,80(sp)
    80006178:	ecb2                	sd	a2,88(sp)
    8000617a:	f0b6                	sd	a3,96(sp)
    8000617c:	f4ba                	sd	a4,104(sp)
    8000617e:	f8be                	sd	a5,112(sp)
    80006180:	fcc2                	sd	a6,120(sp)
    80006182:	e146                	sd	a7,128(sp)
    80006184:	e54a                	sd	s2,136(sp)
    80006186:	e94e                	sd	s3,144(sp)
    80006188:	ed52                	sd	s4,152(sp)
    8000618a:	f156                	sd	s5,160(sp)
    8000618c:	f55a                	sd	s6,168(sp)
    8000618e:	f95e                	sd	s7,176(sp)
    80006190:	fd62                	sd	s8,184(sp)
    80006192:	e1e6                	sd	s9,192(sp)
    80006194:	e5ea                	sd	s10,200(sp)
    80006196:	e9ee                	sd	s11,208(sp)
    80006198:	edf2                	sd	t3,216(sp)
    8000619a:	f1f6                	sd	t4,224(sp)
    8000619c:	f5fa                	sd	t5,232(sp)
    8000619e:	f9fe                	sd	t6,240(sp)
    800061a0:	afdfc0ef          	jal	ra,80002c9c <kerneltrap>
    800061a4:	6082                	ld	ra,0(sp)
    800061a6:	6122                	ld	sp,8(sp)
    800061a8:	61c2                	ld	gp,16(sp)
    800061aa:	7282                	ld	t0,32(sp)
    800061ac:	7322                	ld	t1,40(sp)
    800061ae:	73c2                	ld	t2,48(sp)
    800061b0:	7462                	ld	s0,56(sp)
    800061b2:	6486                	ld	s1,64(sp)
    800061b4:	6526                	ld	a0,72(sp)
    800061b6:	65c6                	ld	a1,80(sp)
    800061b8:	6666                	ld	a2,88(sp)
    800061ba:	7686                	ld	a3,96(sp)
    800061bc:	7726                	ld	a4,104(sp)
    800061be:	77c6                	ld	a5,112(sp)
    800061c0:	7866                	ld	a6,120(sp)
    800061c2:	688a                	ld	a7,128(sp)
    800061c4:	692a                	ld	s2,136(sp)
    800061c6:	69ca                	ld	s3,144(sp)
    800061c8:	6a6a                	ld	s4,152(sp)
    800061ca:	7a8a                	ld	s5,160(sp)
    800061cc:	7b2a                	ld	s6,168(sp)
    800061ce:	7bca                	ld	s7,176(sp)
    800061d0:	7c6a                	ld	s8,184(sp)
    800061d2:	6c8e                	ld	s9,192(sp)
    800061d4:	6d2e                	ld	s10,200(sp)
    800061d6:	6dce                	ld	s11,208(sp)
    800061d8:	6e6e                	ld	t3,216(sp)
    800061da:	7e8e                	ld	t4,224(sp)
    800061dc:	7f2e                	ld	t5,232(sp)
    800061de:	7fce                	ld	t6,240(sp)
    800061e0:	6111                	addi	sp,sp,256
    800061e2:	10200073          	sret
    800061e6:	00000013          	nop
    800061ea:	00000013          	nop
    800061ee:	0001                	nop

00000000800061f0 <timervec>:
    800061f0:	34051573          	csrrw	a0,mscratch,a0
    800061f4:	e10c                	sd	a1,0(a0)
    800061f6:	e510                	sd	a2,8(a0)
    800061f8:	e914                	sd	a3,16(a0)
    800061fa:	6d0c                	ld	a1,24(a0)
    800061fc:	7110                	ld	a2,32(a0)
    800061fe:	6194                	ld	a3,0(a1)
    80006200:	96b2                	add	a3,a3,a2
    80006202:	e194                	sd	a3,0(a1)
    80006204:	4589                	li	a1,2
    80006206:	14459073          	csrw	sip,a1
    8000620a:	6914                	ld	a3,16(a0)
    8000620c:	6510                	ld	a2,8(a0)
    8000620e:	610c                	ld	a1,0(a0)
    80006210:	34051573          	csrrw	a0,mscratch,a0
    80006214:	30200073          	mret
	...

000000008000621a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000621a:	1141                	addi	sp,sp,-16
    8000621c:	e422                	sd	s0,8(sp)
    8000621e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006220:	0c0007b7          	lui	a5,0xc000
    80006224:	4705                	li	a4,1
    80006226:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006228:	c3d8                	sw	a4,4(a5)
}
    8000622a:	6422                	ld	s0,8(sp)
    8000622c:	0141                	addi	sp,sp,16
    8000622e:	8082                	ret

0000000080006230 <plicinithart>:

void
plicinithart(void)
{
    80006230:	1141                	addi	sp,sp,-16
    80006232:	e406                	sd	ra,8(sp)
    80006234:	e022                	sd	s0,0(sp)
    80006236:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006238:	ffffb097          	auipc	ra,0xffffb
    8000623c:	762080e7          	jalr	1890(ra) # 8000199a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006240:	0085171b          	slliw	a4,a0,0x8
    80006244:	0c0027b7          	lui	a5,0xc002
    80006248:	97ba                	add	a5,a5,a4
    8000624a:	40200713          	li	a4,1026
    8000624e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006252:	00d5151b          	slliw	a0,a0,0xd
    80006256:	0c2017b7          	lui	a5,0xc201
    8000625a:	953e                	add	a0,a0,a5
    8000625c:	00052023          	sw	zero,0(a0)
}
    80006260:	60a2                	ld	ra,8(sp)
    80006262:	6402                	ld	s0,0(sp)
    80006264:	0141                	addi	sp,sp,16
    80006266:	8082                	ret

0000000080006268 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006268:	1141                	addi	sp,sp,-16
    8000626a:	e406                	sd	ra,8(sp)
    8000626c:	e022                	sd	s0,0(sp)
    8000626e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006270:	ffffb097          	auipc	ra,0xffffb
    80006274:	72a080e7          	jalr	1834(ra) # 8000199a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006278:	00d5179b          	slliw	a5,a0,0xd
    8000627c:	0c201537          	lui	a0,0xc201
    80006280:	953e                	add	a0,a0,a5
  return irq;
}
    80006282:	4148                	lw	a0,4(a0)
    80006284:	60a2                	ld	ra,8(sp)
    80006286:	6402                	ld	s0,0(sp)
    80006288:	0141                	addi	sp,sp,16
    8000628a:	8082                	ret

000000008000628c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000628c:	1101                	addi	sp,sp,-32
    8000628e:	ec06                	sd	ra,24(sp)
    80006290:	e822                	sd	s0,16(sp)
    80006292:	e426                	sd	s1,8(sp)
    80006294:	1000                	addi	s0,sp,32
    80006296:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006298:	ffffb097          	auipc	ra,0xffffb
    8000629c:	702080e7          	jalr	1794(ra) # 8000199a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800062a0:	00d5151b          	slliw	a0,a0,0xd
    800062a4:	0c2017b7          	lui	a5,0xc201
    800062a8:	97aa                	add	a5,a5,a0
    800062aa:	c3c4                	sw	s1,4(a5)
}
    800062ac:	60e2                	ld	ra,24(sp)
    800062ae:	6442                	ld	s0,16(sp)
    800062b0:	64a2                	ld	s1,8(sp)
    800062b2:	6105                	addi	sp,sp,32
    800062b4:	8082                	ret

00000000800062b6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800062b6:	1141                	addi	sp,sp,-16
    800062b8:	e406                	sd	ra,8(sp)
    800062ba:	e022                	sd	s0,0(sp)
    800062bc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800062be:	479d                	li	a5,7
    800062c0:	04a7cc63          	blt	a5,a0,80006318 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800062c4:	0001e797          	auipc	a5,0x1e
    800062c8:	9dc78793          	addi	a5,a5,-1572 # 80023ca0 <disk>
    800062cc:	97aa                	add	a5,a5,a0
    800062ce:	0187c783          	lbu	a5,24(a5)
    800062d2:	ebb9                	bnez	a5,80006328 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800062d4:	00451613          	slli	a2,a0,0x4
    800062d8:	0001e797          	auipc	a5,0x1e
    800062dc:	9c878793          	addi	a5,a5,-1592 # 80023ca0 <disk>
    800062e0:	6394                	ld	a3,0(a5)
    800062e2:	96b2                	add	a3,a3,a2
    800062e4:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800062e8:	6398                	ld	a4,0(a5)
    800062ea:	9732                	add	a4,a4,a2
    800062ec:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800062f0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800062f4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800062f8:	953e                	add	a0,a0,a5
    800062fa:	4785                	li	a5,1
    800062fc:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006300:	0001e517          	auipc	a0,0x1e
    80006304:	9b850513          	addi	a0,a0,-1608 # 80023cb8 <disk+0x18>
    80006308:	ffffc097          	auipc	ra,0xffffc
    8000630c:	070080e7          	jalr	112(ra) # 80002378 <wakeup>
}
    80006310:	60a2                	ld	ra,8(sp)
    80006312:	6402                	ld	s0,0(sp)
    80006314:	0141                	addi	sp,sp,16
    80006316:	8082                	ret
    panic("free_desc 1");
    80006318:	00002517          	auipc	a0,0x2
    8000631c:	5e050513          	addi	a0,a0,1504 # 800088f8 <syscallnum+0x2a8>
    80006320:	ffffa097          	auipc	ra,0xffffa
    80006324:	224080e7          	jalr	548(ra) # 80000544 <panic>
    panic("free_desc 2");
    80006328:	00002517          	auipc	a0,0x2
    8000632c:	5e050513          	addi	a0,a0,1504 # 80008908 <syscallnum+0x2b8>
    80006330:	ffffa097          	auipc	ra,0xffffa
    80006334:	214080e7          	jalr	532(ra) # 80000544 <panic>

0000000080006338 <virtio_disk_init>:
{
    80006338:	1101                	addi	sp,sp,-32
    8000633a:	ec06                	sd	ra,24(sp)
    8000633c:	e822                	sd	s0,16(sp)
    8000633e:	e426                	sd	s1,8(sp)
    80006340:	e04a                	sd	s2,0(sp)
    80006342:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006344:	00002597          	auipc	a1,0x2
    80006348:	5d458593          	addi	a1,a1,1492 # 80008918 <syscallnum+0x2c8>
    8000634c:	0001e517          	auipc	a0,0x1e
    80006350:	a7c50513          	addi	a0,a0,-1412 # 80023dc8 <disk+0x128>
    80006354:	ffffb097          	auipc	ra,0xffffb
    80006358:	806080e7          	jalr	-2042(ra) # 80000b5a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000635c:	100017b7          	lui	a5,0x10001
    80006360:	4398                	lw	a4,0(a5)
    80006362:	2701                	sext.w	a4,a4
    80006364:	747277b7          	lui	a5,0x74727
    80006368:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000636c:	14f71e63          	bne	a4,a5,800064c8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006370:	100017b7          	lui	a5,0x10001
    80006374:	43dc                	lw	a5,4(a5)
    80006376:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006378:	4709                	li	a4,2
    8000637a:	14e79763          	bne	a5,a4,800064c8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000637e:	100017b7          	lui	a5,0x10001
    80006382:	479c                	lw	a5,8(a5)
    80006384:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006386:	14e79163          	bne	a5,a4,800064c8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000638a:	100017b7          	lui	a5,0x10001
    8000638e:	47d8                	lw	a4,12(a5)
    80006390:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006392:	554d47b7          	lui	a5,0x554d4
    80006396:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000639a:	12f71763          	bne	a4,a5,800064c8 <virtio_disk_init+0x190>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000639e:	100017b7          	lui	a5,0x10001
    800063a2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800063a6:	4705                	li	a4,1
    800063a8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800063aa:	470d                	li	a4,3
    800063ac:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800063ae:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800063b0:	c7ffe737          	lui	a4,0xc7ffe
    800063b4:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fda97f>
    800063b8:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800063ba:	2701                	sext.w	a4,a4
    800063bc:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800063be:	472d                	li	a4,11
    800063c0:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800063c2:	0707a903          	lw	s2,112(a5)
    800063c6:	2901                	sext.w	s2,s2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800063c8:	00897793          	andi	a5,s2,8
    800063cc:	10078663          	beqz	a5,800064d8 <virtio_disk_init+0x1a0>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800063d0:	100017b7          	lui	a5,0x10001
    800063d4:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800063d8:	43fc                	lw	a5,68(a5)
    800063da:	2781                	sext.w	a5,a5
    800063dc:	10079663          	bnez	a5,800064e8 <virtio_disk_init+0x1b0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800063e0:	100017b7          	lui	a5,0x10001
    800063e4:	5bdc                	lw	a5,52(a5)
    800063e6:	2781                	sext.w	a5,a5
  if(max == 0)
    800063e8:	10078863          	beqz	a5,800064f8 <virtio_disk_init+0x1c0>
  if(max < NUM)
    800063ec:	471d                	li	a4,7
    800063ee:	10f77d63          	bgeu	a4,a5,80006508 <virtio_disk_init+0x1d0>
  disk.desc = kalloc();
    800063f2:	ffffa097          	auipc	ra,0xffffa
    800063f6:	708080e7          	jalr	1800(ra) # 80000afa <kalloc>
    800063fa:	0001e497          	auipc	s1,0x1e
    800063fe:	8a648493          	addi	s1,s1,-1882 # 80023ca0 <disk>
    80006402:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006404:	ffffa097          	auipc	ra,0xffffa
    80006408:	6f6080e7          	jalr	1782(ra) # 80000afa <kalloc>
    8000640c:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000640e:	ffffa097          	auipc	ra,0xffffa
    80006412:	6ec080e7          	jalr	1772(ra) # 80000afa <kalloc>
    80006416:	87aa                	mv	a5,a0
    80006418:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    8000641a:	6088                	ld	a0,0(s1)
    8000641c:	cd75                	beqz	a0,80006518 <virtio_disk_init+0x1e0>
    8000641e:	0001e717          	auipc	a4,0x1e
    80006422:	88a73703          	ld	a4,-1910(a4) # 80023ca8 <disk+0x8>
    80006426:	cb6d                	beqz	a4,80006518 <virtio_disk_init+0x1e0>
    80006428:	cbe5                	beqz	a5,80006518 <virtio_disk_init+0x1e0>
  memset(disk.desc, 0, PGSIZE);
    8000642a:	6605                	lui	a2,0x1
    8000642c:	4581                	li	a1,0
    8000642e:	ffffb097          	auipc	ra,0xffffb
    80006432:	8b8080e7          	jalr	-1864(ra) # 80000ce6 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006436:	0001e497          	auipc	s1,0x1e
    8000643a:	86a48493          	addi	s1,s1,-1942 # 80023ca0 <disk>
    8000643e:	6605                	lui	a2,0x1
    80006440:	4581                	li	a1,0
    80006442:	6488                	ld	a0,8(s1)
    80006444:	ffffb097          	auipc	ra,0xffffb
    80006448:	8a2080e7          	jalr	-1886(ra) # 80000ce6 <memset>
  memset(disk.used, 0, PGSIZE);
    8000644c:	6605                	lui	a2,0x1
    8000644e:	4581                	li	a1,0
    80006450:	6888                	ld	a0,16(s1)
    80006452:	ffffb097          	auipc	ra,0xffffb
    80006456:	894080e7          	jalr	-1900(ra) # 80000ce6 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000645a:	100017b7          	lui	a5,0x10001
    8000645e:	4721                	li	a4,8
    80006460:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006462:	4098                	lw	a4,0(s1)
    80006464:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006468:	40d8                	lw	a4,4(s1)
    8000646a:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000646e:	6498                	ld	a4,8(s1)
    80006470:	0007069b          	sext.w	a3,a4
    80006474:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006478:	9701                	srai	a4,a4,0x20
    8000647a:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000647e:	6898                	ld	a4,16(s1)
    80006480:	0007069b          	sext.w	a3,a4
    80006484:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006488:	9701                	srai	a4,a4,0x20
    8000648a:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000648e:	4685                	li	a3,1
    80006490:	c3f4                	sw	a3,68(a5)
    disk.free[i] = 1;
    80006492:	4705                	li	a4,1
    80006494:	00d48c23          	sb	a3,24(s1)
    80006498:	00e48ca3          	sb	a4,25(s1)
    8000649c:	00e48d23          	sb	a4,26(s1)
    800064a0:	00e48da3          	sb	a4,27(s1)
    800064a4:	00e48e23          	sb	a4,28(s1)
    800064a8:	00e48ea3          	sb	a4,29(s1)
    800064ac:	00e48f23          	sb	a4,30(s1)
    800064b0:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800064b4:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800064b8:	0727a823          	sw	s2,112(a5)
}
    800064bc:	60e2                	ld	ra,24(sp)
    800064be:	6442                	ld	s0,16(sp)
    800064c0:	64a2                	ld	s1,8(sp)
    800064c2:	6902                	ld	s2,0(sp)
    800064c4:	6105                	addi	sp,sp,32
    800064c6:	8082                	ret
    panic("could not find virtio disk");
    800064c8:	00002517          	auipc	a0,0x2
    800064cc:	46050513          	addi	a0,a0,1120 # 80008928 <syscallnum+0x2d8>
    800064d0:	ffffa097          	auipc	ra,0xffffa
    800064d4:	074080e7          	jalr	116(ra) # 80000544 <panic>
    panic("virtio disk FEATURES_OK unset");
    800064d8:	00002517          	auipc	a0,0x2
    800064dc:	47050513          	addi	a0,a0,1136 # 80008948 <syscallnum+0x2f8>
    800064e0:	ffffa097          	auipc	ra,0xffffa
    800064e4:	064080e7          	jalr	100(ra) # 80000544 <panic>
    panic("virtio disk should not be ready");
    800064e8:	00002517          	auipc	a0,0x2
    800064ec:	48050513          	addi	a0,a0,1152 # 80008968 <syscallnum+0x318>
    800064f0:	ffffa097          	auipc	ra,0xffffa
    800064f4:	054080e7          	jalr	84(ra) # 80000544 <panic>
    panic("virtio disk has no queue 0");
    800064f8:	00002517          	auipc	a0,0x2
    800064fc:	49050513          	addi	a0,a0,1168 # 80008988 <syscallnum+0x338>
    80006500:	ffffa097          	auipc	ra,0xffffa
    80006504:	044080e7          	jalr	68(ra) # 80000544 <panic>
    panic("virtio disk max queue too short");
    80006508:	00002517          	auipc	a0,0x2
    8000650c:	4a050513          	addi	a0,a0,1184 # 800089a8 <syscallnum+0x358>
    80006510:	ffffa097          	auipc	ra,0xffffa
    80006514:	034080e7          	jalr	52(ra) # 80000544 <panic>
    panic("virtio disk kalloc");
    80006518:	00002517          	auipc	a0,0x2
    8000651c:	4b050513          	addi	a0,a0,1200 # 800089c8 <syscallnum+0x378>
    80006520:	ffffa097          	auipc	ra,0xffffa
    80006524:	024080e7          	jalr	36(ra) # 80000544 <panic>

0000000080006528 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006528:	7159                	addi	sp,sp,-112
    8000652a:	f486                	sd	ra,104(sp)
    8000652c:	f0a2                	sd	s0,96(sp)
    8000652e:	eca6                	sd	s1,88(sp)
    80006530:	e8ca                	sd	s2,80(sp)
    80006532:	e4ce                	sd	s3,72(sp)
    80006534:	e0d2                	sd	s4,64(sp)
    80006536:	fc56                	sd	s5,56(sp)
    80006538:	f85a                	sd	s6,48(sp)
    8000653a:	f45e                	sd	s7,40(sp)
    8000653c:	f062                	sd	s8,32(sp)
    8000653e:	ec66                	sd	s9,24(sp)
    80006540:	e86a                	sd	s10,16(sp)
    80006542:	1880                	addi	s0,sp,112
    80006544:	892a                	mv	s2,a0
    80006546:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006548:	00c52c83          	lw	s9,12(a0)
    8000654c:	001c9c9b          	slliw	s9,s9,0x1
    80006550:	1c82                	slli	s9,s9,0x20
    80006552:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006556:	0001e517          	auipc	a0,0x1e
    8000655a:	87250513          	addi	a0,a0,-1934 # 80023dc8 <disk+0x128>
    8000655e:	ffffa097          	auipc	ra,0xffffa
    80006562:	68c080e7          	jalr	1676(ra) # 80000bea <acquire>
  for(int i = 0; i < 3; i++){
    80006566:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006568:	4ba1                	li	s7,8
      disk.free[i] = 0;
    8000656a:	0001db17          	auipc	s6,0x1d
    8000656e:	736b0b13          	addi	s6,s6,1846 # 80023ca0 <disk>
  for(int i = 0; i < 3; i++){
    80006572:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80006574:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006576:	0001ec17          	auipc	s8,0x1e
    8000657a:	852c0c13          	addi	s8,s8,-1966 # 80023dc8 <disk+0x128>
    8000657e:	a8b5                	j	800065fa <virtio_disk_rw+0xd2>
      disk.free[i] = 0;
    80006580:	00fb06b3          	add	a3,s6,a5
    80006584:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006588:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000658a:	0207c563          	bltz	a5,800065b4 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000658e:	2485                	addiw	s1,s1,1
    80006590:	0711                	addi	a4,a4,4
    80006592:	1f548a63          	beq	s1,s5,80006786 <virtio_disk_rw+0x25e>
    idx[i] = alloc_desc();
    80006596:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006598:	0001d697          	auipc	a3,0x1d
    8000659c:	70868693          	addi	a3,a3,1800 # 80023ca0 <disk>
    800065a0:	87d2                	mv	a5,s4
    if(disk.free[i]){
    800065a2:	0186c583          	lbu	a1,24(a3)
    800065a6:	fde9                	bnez	a1,80006580 <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800065a8:	2785                	addiw	a5,a5,1
    800065aa:	0685                	addi	a3,a3,1
    800065ac:	ff779be3          	bne	a5,s7,800065a2 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800065b0:	57fd                	li	a5,-1
    800065b2:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    800065b4:	02905a63          	blez	s1,800065e8 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800065b8:	f9042503          	lw	a0,-112(s0)
    800065bc:	00000097          	auipc	ra,0x0
    800065c0:	cfa080e7          	jalr	-774(ra) # 800062b6 <free_desc>
      for(int j = 0; j < i; j++)
    800065c4:	4785                	li	a5,1
    800065c6:	0297d163          	bge	a5,s1,800065e8 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800065ca:	f9442503          	lw	a0,-108(s0)
    800065ce:	00000097          	auipc	ra,0x0
    800065d2:	ce8080e7          	jalr	-792(ra) # 800062b6 <free_desc>
      for(int j = 0; j < i; j++)
    800065d6:	4789                	li	a5,2
    800065d8:	0097d863          	bge	a5,s1,800065e8 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800065dc:	f9842503          	lw	a0,-104(s0)
    800065e0:	00000097          	auipc	ra,0x0
    800065e4:	cd6080e7          	jalr	-810(ra) # 800062b6 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800065e8:	85e2                	mv	a1,s8
    800065ea:	0001d517          	auipc	a0,0x1d
    800065ee:	6ce50513          	addi	a0,a0,1742 # 80023cb8 <disk+0x18>
    800065f2:	ffffc097          	auipc	ra,0xffffc
    800065f6:	bd6080e7          	jalr	-1066(ra) # 800021c8 <sleep>
  for(int i = 0; i < 3; i++){
    800065fa:	f9040713          	addi	a4,s0,-112
    800065fe:	84ce                	mv	s1,s3
    80006600:	bf59                	j	80006596 <virtio_disk_rw+0x6e>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80006602:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    80006606:	00479693          	slli	a3,a5,0x4
    8000660a:	0001d797          	auipc	a5,0x1d
    8000660e:	69678793          	addi	a5,a5,1686 # 80023ca0 <disk>
    80006612:	97b6                	add	a5,a5,a3
    80006614:	4685                	li	a3,1
    80006616:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006618:	0001d597          	auipc	a1,0x1d
    8000661c:	68858593          	addi	a1,a1,1672 # 80023ca0 <disk>
    80006620:	00a60793          	addi	a5,a2,10
    80006624:	0792                	slli	a5,a5,0x4
    80006626:	97ae                	add	a5,a5,a1
    80006628:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    8000662c:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006630:	f6070693          	addi	a3,a4,-160
    80006634:	619c                	ld	a5,0(a1)
    80006636:	97b6                	add	a5,a5,a3
    80006638:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000663a:	6188                	ld	a0,0(a1)
    8000663c:	96aa                	add	a3,a3,a0
    8000663e:	47c1                	li	a5,16
    80006640:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006642:	4785                	li	a5,1
    80006644:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006648:	f9442783          	lw	a5,-108(s0)
    8000664c:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006650:	0792                	slli	a5,a5,0x4
    80006652:	953e                	add	a0,a0,a5
    80006654:	05890693          	addi	a3,s2,88
    80006658:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000665a:	6188                	ld	a0,0(a1)
    8000665c:	97aa                	add	a5,a5,a0
    8000665e:	40000693          	li	a3,1024
    80006662:	c794                	sw	a3,8(a5)
  if(write)
    80006664:	100d0d63          	beqz	s10,8000677e <virtio_disk_rw+0x256>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006668:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000666c:	00c7d683          	lhu	a3,12(a5)
    80006670:	0016e693          	ori	a3,a3,1
    80006674:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    80006678:	f9842583          	lw	a1,-104(s0)
    8000667c:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006680:	0001d697          	auipc	a3,0x1d
    80006684:	62068693          	addi	a3,a3,1568 # 80023ca0 <disk>
    80006688:	00260793          	addi	a5,a2,2
    8000668c:	0792                	slli	a5,a5,0x4
    8000668e:	97b6                	add	a5,a5,a3
    80006690:	587d                	li	a6,-1
    80006692:	01078823          	sb	a6,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006696:	0592                	slli	a1,a1,0x4
    80006698:	952e                	add	a0,a0,a1
    8000669a:	f9070713          	addi	a4,a4,-112
    8000669e:	9736                	add	a4,a4,a3
    800066a0:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    800066a2:	6298                	ld	a4,0(a3)
    800066a4:	972e                	add	a4,a4,a1
    800066a6:	4585                	li	a1,1
    800066a8:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800066aa:	4509                	li	a0,2
    800066ac:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    800066b0:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800066b4:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    800066b8:	0127b423          	sd	s2,8(a5)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800066bc:	6698                	ld	a4,8(a3)
    800066be:	00275783          	lhu	a5,2(a4)
    800066c2:	8b9d                	andi	a5,a5,7
    800066c4:	0786                	slli	a5,a5,0x1
    800066c6:	97ba                	add	a5,a5,a4
    800066c8:	00c79223          	sh	a2,4(a5)

  __sync_synchronize();
    800066cc:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800066d0:	6698                	ld	a4,8(a3)
    800066d2:	00275783          	lhu	a5,2(a4)
    800066d6:	2785                	addiw	a5,a5,1
    800066d8:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800066dc:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800066e0:	100017b7          	lui	a5,0x10001
    800066e4:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800066e8:	00492703          	lw	a4,4(s2)
    800066ec:	4785                	li	a5,1
    800066ee:	02f71163          	bne	a4,a5,80006710 <virtio_disk_rw+0x1e8>
    sleep(b, &disk.vdisk_lock);
    800066f2:	0001d997          	auipc	s3,0x1d
    800066f6:	6d698993          	addi	s3,s3,1750 # 80023dc8 <disk+0x128>
  while(b->disk == 1) {
    800066fa:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800066fc:	85ce                	mv	a1,s3
    800066fe:	854a                	mv	a0,s2
    80006700:	ffffc097          	auipc	ra,0xffffc
    80006704:	ac8080e7          	jalr	-1336(ra) # 800021c8 <sleep>
  while(b->disk == 1) {
    80006708:	00492783          	lw	a5,4(s2)
    8000670c:	fe9788e3          	beq	a5,s1,800066fc <virtio_disk_rw+0x1d4>
  }

  disk.info[idx[0]].b = 0;
    80006710:	f9042903          	lw	s2,-112(s0)
    80006714:	00290793          	addi	a5,s2,2
    80006718:	00479713          	slli	a4,a5,0x4
    8000671c:	0001d797          	auipc	a5,0x1d
    80006720:	58478793          	addi	a5,a5,1412 # 80023ca0 <disk>
    80006724:	97ba                	add	a5,a5,a4
    80006726:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000672a:	0001d997          	auipc	s3,0x1d
    8000672e:	57698993          	addi	s3,s3,1398 # 80023ca0 <disk>
    80006732:	00491713          	slli	a4,s2,0x4
    80006736:	0009b783          	ld	a5,0(s3)
    8000673a:	97ba                	add	a5,a5,a4
    8000673c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006740:	854a                	mv	a0,s2
    80006742:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006746:	00000097          	auipc	ra,0x0
    8000674a:	b70080e7          	jalr	-1168(ra) # 800062b6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000674e:	8885                	andi	s1,s1,1
    80006750:	f0ed                	bnez	s1,80006732 <virtio_disk_rw+0x20a>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006752:	0001d517          	auipc	a0,0x1d
    80006756:	67650513          	addi	a0,a0,1654 # 80023dc8 <disk+0x128>
    8000675a:	ffffa097          	auipc	ra,0xffffa
    8000675e:	544080e7          	jalr	1348(ra) # 80000c9e <release>
}
    80006762:	70a6                	ld	ra,104(sp)
    80006764:	7406                	ld	s0,96(sp)
    80006766:	64e6                	ld	s1,88(sp)
    80006768:	6946                	ld	s2,80(sp)
    8000676a:	69a6                	ld	s3,72(sp)
    8000676c:	6a06                	ld	s4,64(sp)
    8000676e:	7ae2                	ld	s5,56(sp)
    80006770:	7b42                	ld	s6,48(sp)
    80006772:	7ba2                	ld	s7,40(sp)
    80006774:	7c02                	ld	s8,32(sp)
    80006776:	6ce2                	ld	s9,24(sp)
    80006778:	6d42                	ld	s10,16(sp)
    8000677a:	6165                	addi	sp,sp,112
    8000677c:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000677e:	4689                	li	a3,2
    80006780:	00d79623          	sh	a3,12(a5)
    80006784:	b5e5                	j	8000666c <virtio_disk_rw+0x144>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006786:	f9042603          	lw	a2,-112(s0)
    8000678a:	00a60713          	addi	a4,a2,10
    8000678e:	0712                	slli	a4,a4,0x4
    80006790:	0001d517          	auipc	a0,0x1d
    80006794:	51850513          	addi	a0,a0,1304 # 80023ca8 <disk+0x8>
    80006798:	953a                	add	a0,a0,a4
  if(write)
    8000679a:	e60d14e3          	bnez	s10,80006602 <virtio_disk_rw+0xda>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    8000679e:	00a60793          	addi	a5,a2,10
    800067a2:	00479693          	slli	a3,a5,0x4
    800067a6:	0001d797          	auipc	a5,0x1d
    800067aa:	4fa78793          	addi	a5,a5,1274 # 80023ca0 <disk>
    800067ae:	97b6                	add	a5,a5,a3
    800067b0:	0007a423          	sw	zero,8(a5)
    800067b4:	b595                	j	80006618 <virtio_disk_rw+0xf0>

00000000800067b6 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800067b6:	1101                	addi	sp,sp,-32
    800067b8:	ec06                	sd	ra,24(sp)
    800067ba:	e822                	sd	s0,16(sp)
    800067bc:	e426                	sd	s1,8(sp)
    800067be:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800067c0:	0001d497          	auipc	s1,0x1d
    800067c4:	4e048493          	addi	s1,s1,1248 # 80023ca0 <disk>
    800067c8:	0001d517          	auipc	a0,0x1d
    800067cc:	60050513          	addi	a0,a0,1536 # 80023dc8 <disk+0x128>
    800067d0:	ffffa097          	auipc	ra,0xffffa
    800067d4:	41a080e7          	jalr	1050(ra) # 80000bea <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800067d8:	10001737          	lui	a4,0x10001
    800067dc:	533c                	lw	a5,96(a4)
    800067de:	8b8d                	andi	a5,a5,3
    800067e0:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800067e2:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800067e6:	689c                	ld	a5,16(s1)
    800067e8:	0204d703          	lhu	a4,32(s1)
    800067ec:	0027d783          	lhu	a5,2(a5)
    800067f0:	04f70863          	beq	a4,a5,80006840 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800067f4:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800067f8:	6898                	ld	a4,16(s1)
    800067fa:	0204d783          	lhu	a5,32(s1)
    800067fe:	8b9d                	andi	a5,a5,7
    80006800:	078e                	slli	a5,a5,0x3
    80006802:	97ba                	add	a5,a5,a4
    80006804:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006806:	00278713          	addi	a4,a5,2
    8000680a:	0712                	slli	a4,a4,0x4
    8000680c:	9726                	add	a4,a4,s1
    8000680e:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006812:	e721                	bnez	a4,8000685a <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006814:	0789                	addi	a5,a5,2
    80006816:	0792                	slli	a5,a5,0x4
    80006818:	97a6                	add	a5,a5,s1
    8000681a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000681c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006820:	ffffc097          	auipc	ra,0xffffc
    80006824:	b58080e7          	jalr	-1192(ra) # 80002378 <wakeup>

    disk.used_idx += 1;
    80006828:	0204d783          	lhu	a5,32(s1)
    8000682c:	2785                	addiw	a5,a5,1
    8000682e:	17c2                	slli	a5,a5,0x30
    80006830:	93c1                	srli	a5,a5,0x30
    80006832:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006836:	6898                	ld	a4,16(s1)
    80006838:	00275703          	lhu	a4,2(a4)
    8000683c:	faf71ce3          	bne	a4,a5,800067f4 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006840:	0001d517          	auipc	a0,0x1d
    80006844:	58850513          	addi	a0,a0,1416 # 80023dc8 <disk+0x128>
    80006848:	ffffa097          	auipc	ra,0xffffa
    8000684c:	456080e7          	jalr	1110(ra) # 80000c9e <release>
}
    80006850:	60e2                	ld	ra,24(sp)
    80006852:	6442                	ld	s0,16(sp)
    80006854:	64a2                	ld	s1,8(sp)
    80006856:	6105                	addi	sp,sp,32
    80006858:	8082                	ret
      panic("virtio_disk_intr status");
    8000685a:	00002517          	auipc	a0,0x2
    8000685e:	18650513          	addi	a0,a0,390 # 800089e0 <syscallnum+0x390>
    80006862:	ffffa097          	auipc	ra,0xffffa
    80006866:	ce2080e7          	jalr	-798(ra) # 80000544 <panic>
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

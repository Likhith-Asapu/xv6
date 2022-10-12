
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	c6010113          	addi	sp,sp,-928 # 80008c60 <stack0>
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
    80000056:	ace70713          	addi	a4,a4,-1330 # 80008b20 <timer_scratch>
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
    80000068:	fac78793          	addi	a5,a5,-84 # 80006010 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb46f>
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
    80000130:	588080e7          	jalr	1416(ra) # 800026b4 <either_copyin>
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
    80000190:	ad450513          	addi	a0,a0,-1324 # 80010c60 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	a56080e7          	jalr	-1450(ra) # 80000bea <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019c:	00011497          	auipc	s1,0x11
    800001a0:	ac448493          	addi	s1,s1,-1340 # 80010c60 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a4:	89a6                	mv	s3,s1
    800001a6:	00011917          	auipc	s2,0x11
    800001aa:	b5290913          	addi	s2,s2,-1198 # 80010cf8 <cons+0x98>
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
    800001d0:	332080e7          	jalr	818(ra) # 800024fe <killed>
    800001d4:	e535                	bnez	a0,80000240 <consoleread+0xdc>
      sleep(&cons.r, &cons.lock);
    800001d6:	85ce                	mv	a1,s3
    800001d8:	854a                	mv	a0,s2
    800001da:	00002097          	auipc	ra,0x2
    800001de:	f24080e7          	jalr	-220(ra) # 800020fe <sleep>
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
    8000021a:	448080e7          	jalr	1096(ra) # 8000265e <either_copyout>
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
    8000022e:	a3650513          	addi	a0,a0,-1482 # 80010c60 <cons>
    80000232:	00001097          	auipc	ra,0x1
    80000236:	a6c080e7          	jalr	-1428(ra) # 80000c9e <release>

  return target - n;
    8000023a:	414b853b          	subw	a0,s7,s4
    8000023e:	a811                	j	80000252 <consoleread+0xee>
        release(&cons.lock);
    80000240:	00011517          	auipc	a0,0x11
    80000244:	a2050513          	addi	a0,a0,-1504 # 80010c60 <cons>
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
    8000027c:	a8f72023          	sw	a5,-1408(a4) # 80010cf8 <cons+0x98>
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
    800002d6:	98e50513          	addi	a0,a0,-1650 # 80010c60 <cons>
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
    800002fc:	412080e7          	jalr	1042(ra) # 8000270a <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000300:	00011517          	auipc	a0,0x11
    80000304:	96050513          	addi	a0,a0,-1696 # 80010c60 <cons>
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
    80000328:	93c70713          	addi	a4,a4,-1732 # 80010c60 <cons>
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
    80000352:	91278793          	addi	a5,a5,-1774 # 80010c60 <cons>
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
    80000380:	97c7a783          	lw	a5,-1668(a5) # 80010cf8 <cons+0x98>
    80000384:	9f1d                	subw	a4,a4,a5
    80000386:	08000793          	li	a5,128
    8000038a:	f6f71be3          	bne	a4,a5,80000300 <consoleintr+0x3c>
    8000038e:	a07d                	j	8000043c <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000390:	00011717          	auipc	a4,0x11
    80000394:	8d070713          	addi	a4,a4,-1840 # 80010c60 <cons>
    80000398:	0a072783          	lw	a5,160(a4)
    8000039c:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a0:	00011497          	auipc	s1,0x11
    800003a4:	8c048493          	addi	s1,s1,-1856 # 80010c60 <cons>
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
    800003e0:	88470713          	addi	a4,a4,-1916 # 80010c60 <cons>
    800003e4:	0a072783          	lw	a5,160(a4)
    800003e8:	09c72703          	lw	a4,156(a4)
    800003ec:	f0f70ae3          	beq	a4,a5,80000300 <consoleintr+0x3c>
      cons.e--;
    800003f0:	37fd                	addiw	a5,a5,-1
    800003f2:	00011717          	auipc	a4,0x11
    800003f6:	90f72723          	sw	a5,-1778(a4) # 80010d00 <cons+0xa0>
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
    8000041c:	84878793          	addi	a5,a5,-1976 # 80010c60 <cons>
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
    80000440:	8cc7a023          	sw	a2,-1856(a5) # 80010cfc <cons+0x9c>
        wakeup(&cons.r);
    80000444:	00011517          	auipc	a0,0x11
    80000448:	8b450513          	addi	a0,a0,-1868 # 80010cf8 <cons+0x98>
    8000044c:	00002097          	auipc	ra,0x2
    80000450:	e62080e7          	jalr	-414(ra) # 800022ae <wakeup>
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
    8000046a:	7fa50513          	addi	a0,a0,2042 # 80010c60 <cons>
    8000046e:	00000097          	auipc	ra,0x0
    80000472:	6ec080e7          	jalr	1772(ra) # 80000b5a <initlock>

  uartinit();
    80000476:	00000097          	auipc	ra,0x0
    8000047a:	330080e7          	jalr	816(ra) # 800007a6 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000047e:	00022797          	auipc	a5,0x22
    80000482:	d7a78793          	addi	a5,a5,-646 # 800221f8 <devsw>
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
    80000554:	7c07a823          	sw	zero,2000(a5) # 80010d20 <pr+0x18>
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
    80000588:	54f72e23          	sw	a5,1372(a4) # 80008ae0 <panicked>
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
    800005c4:	760dad83          	lw	s11,1888(s11) # 80010d20 <pr+0x18>
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
    80000602:	70a50513          	addi	a0,a0,1802 # 80010d08 <pr>
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
    80000766:	5a650513          	addi	a0,a0,1446 # 80010d08 <pr>
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
    80000782:	58a48493          	addi	s1,s1,1418 # 80010d08 <pr>
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
    800007e2:	54a50513          	addi	a0,a0,1354 # 80010d28 <uart_tx_lock>
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
    8000080e:	2d67a783          	lw	a5,726(a5) # 80008ae0 <panicked>
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
    8000084a:	2a273703          	ld	a4,674(a4) # 80008ae8 <uart_tx_r>
    8000084e:	00008797          	auipc	a5,0x8
    80000852:	2a27b783          	ld	a5,674(a5) # 80008af0 <uart_tx_w>
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
    80000874:	4b8a0a13          	addi	s4,s4,1208 # 80010d28 <uart_tx_lock>
    uart_tx_r += 1;
    80000878:	00008497          	auipc	s1,0x8
    8000087c:	27048493          	addi	s1,s1,624 # 80008ae8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000880:	00008997          	auipc	s3,0x8
    80000884:	27098993          	addi	s3,s3,624 # 80008af0 <uart_tx_w>
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
    800008aa:	a08080e7          	jalr	-1528(ra) # 800022ae <wakeup>
    
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
    800008e6:	44650513          	addi	a0,a0,1094 # 80010d28 <uart_tx_lock>
    800008ea:	00000097          	auipc	ra,0x0
    800008ee:	300080e7          	jalr	768(ra) # 80000bea <acquire>
  if(panicked){
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	1ee7a783          	lw	a5,494(a5) # 80008ae0 <panicked>
    800008fa:	e7c9                	bnez	a5,80000984 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fc:	00008797          	auipc	a5,0x8
    80000900:	1f47b783          	ld	a5,500(a5) # 80008af0 <uart_tx_w>
    80000904:	00008717          	auipc	a4,0x8
    80000908:	1e473703          	ld	a4,484(a4) # 80008ae8 <uart_tx_r>
    8000090c:	02070713          	addi	a4,a4,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000910:	00010a17          	auipc	s4,0x10
    80000914:	418a0a13          	addi	s4,s4,1048 # 80010d28 <uart_tx_lock>
    80000918:	00008497          	auipc	s1,0x8
    8000091c:	1d048493          	addi	s1,s1,464 # 80008ae8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000920:	00008917          	auipc	s2,0x8
    80000924:	1d090913          	addi	s2,s2,464 # 80008af0 <uart_tx_w>
    80000928:	00f71f63          	bne	a4,a5,80000946 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000092c:	85d2                	mv	a1,s4
    8000092e:	8526                	mv	a0,s1
    80000930:	00001097          	auipc	ra,0x1
    80000934:	7ce080e7          	jalr	1998(ra) # 800020fe <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000938:	00093783          	ld	a5,0(s2)
    8000093c:	6098                	ld	a4,0(s1)
    8000093e:	02070713          	addi	a4,a4,32
    80000942:	fef705e3          	beq	a4,a5,8000092c <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000946:	00010497          	auipc	s1,0x10
    8000094a:	3e248493          	addi	s1,s1,994 # 80010d28 <uart_tx_lock>
    8000094e:	01f7f713          	andi	a4,a5,31
    80000952:	9726                	add	a4,a4,s1
    80000954:	01370c23          	sb	s3,24(a4)
  uart_tx_w += 1;
    80000958:	0785                	addi	a5,a5,1
    8000095a:	00008717          	auipc	a4,0x8
    8000095e:	18f73b23          	sd	a5,406(a4) # 80008af0 <uart_tx_w>
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
    800009d4:	35848493          	addi	s1,s1,856 # 80010d28 <uart_tx_lock>
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
    80000a16:	97e78793          	addi	a5,a5,-1666 # 80023390 <end>
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
    80000a36:	32e90913          	addi	s2,s2,814 # 80010d60 <kmem>
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
    80000ad2:	29250513          	addi	a0,a0,658 # 80010d60 <kmem>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	084080e7          	jalr	132(ra) # 80000b5a <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ade:	45c5                	li	a1,17
    80000ae0:	05ee                	slli	a1,a1,0x1b
    80000ae2:	00023517          	auipc	a0,0x23
    80000ae6:	8ae50513          	addi	a0,a0,-1874 # 80023390 <end>
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
    80000b08:	25c48493          	addi	s1,s1,604 # 80010d60 <kmem>
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
    80000b20:	24450513          	addi	a0,a0,580 # 80010d60 <kmem>
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
    80000b4c:	21850513          	addi	a0,a0,536 # 80010d60 <kmem>
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
    80000ea8:	c5470713          	addi	a4,a4,-940 # 80008af8 <started>
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
    80000ede:	970080e7          	jalr	-1680(ra) # 8000284a <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ee2:	00005097          	auipc	ra,0x5
    80000ee6:	16e080e7          	jalr	366(ra) # 80006050 <plicinithart>
  }

  scheduler();        
    80000eea:	00001097          	auipc	ra,0x1
    80000eee:	062080e7          	jalr	98(ra) # 80001f4c <scheduler>
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
    80000f56:	8d0080e7          	jalr	-1840(ra) # 80002822 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f5a:	00002097          	auipc	ra,0x2
    80000f5e:	8f0080e7          	jalr	-1808(ra) # 8000284a <trapinithart>
    plicinit();      // set up interrupt controller
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	0d8080e7          	jalr	216(ra) # 8000603a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f6a:	00005097          	auipc	ra,0x5
    80000f6e:	0e6080e7          	jalr	230(ra) # 80006050 <plicinithart>
    binit();         // buffer cache
    80000f72:	00002097          	auipc	ra,0x2
    80000f76:	29a080e7          	jalr	666(ra) # 8000320c <binit>
    iinit();         // inode table
    80000f7a:	00003097          	auipc	ra,0x3
    80000f7e:	93e080e7          	jalr	-1730(ra) # 800038b8 <iinit>
    fileinit();      // file table
    80000f82:	00004097          	auipc	ra,0x4
    80000f86:	8dc080e7          	jalr	-1828(ra) # 8000485e <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f8a:	00005097          	auipc	ra,0x5
    80000f8e:	1ce080e7          	jalr	462(ra) # 80006158 <virtio_disk_init>
    userinit();      // first user process
    80000f92:	00001097          	auipc	ra,0x1
    80000f96:	d3a080e7          	jalr	-710(ra) # 80001ccc <userinit>
    __sync_synchronize();
    80000f9a:	0ff0000f          	fence
    started = 1;
    80000f9e:	4785                	li	a5,1
    80000fa0:	00008717          	auipc	a4,0x8
    80000fa4:	b4f72c23          	sw	a5,-1192(a4) # 80008af8 <started>
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
    80000fb8:	b4c7b783          	ld	a5,-1204(a5) # 80008b00 <kernel_pagetable>
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
    80001274:	88a7b823          	sd	a0,-1904(a5) # 80008b00 <kernel_pagetable>
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
    8000186a:	94a48493          	addi	s1,s1,-1718 # 800111b0 <proc>
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
    80001880:	00016a17          	auipc	s4,0x16
    80001884:	730a0a13          	addi	s4,s4,1840 # 80017fb0 <tickslock>
    char *pa = kalloc();
    80001888:	fffff097          	auipc	ra,0xfffff
    8000188c:	272080e7          	jalr	626(ra) # 80000afa <kalloc>
    80001890:	862a                	mv	a2,a0
    if(pa == 0)
    80001892:	c131                	beqz	a0,800018d6 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001894:	416485b3          	sub	a1,s1,s6
    80001898:	858d                	srai	a1,a1,0x3
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
    800018ba:	1b848493          	addi	s1,s1,440
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
    80001906:	47e50513          	addi	a0,a0,1150 # 80010d80 <pid_lock>
    8000190a:	fffff097          	auipc	ra,0xfffff
    8000190e:	250080e7          	jalr	592(ra) # 80000b5a <initlock>
  initlock(&wait_lock, "wait_lock");
    80001912:	00007597          	auipc	a1,0x7
    80001916:	8d658593          	addi	a1,a1,-1834 # 800081e8 <digits+0x1a8>
    8000191a:	0000f517          	auipc	a0,0xf
    8000191e:	47e50513          	addi	a0,a0,1150 # 80010d98 <wait_lock>
    80001922:	fffff097          	auipc	ra,0xfffff
    80001926:	238080e7          	jalr	568(ra) # 80000b5a <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000192a:	00010497          	auipc	s1,0x10
    8000192e:	88648493          	addi	s1,s1,-1914 # 800111b0 <proc>
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
    8000194c:	00016997          	auipc	s3,0x16
    80001950:	66498993          	addi	s3,s3,1636 # 80017fb0 <tickslock>
      initlock(&p->lock, "proc");
    80001954:	85da                	mv	a1,s6
    80001956:	8526                	mv	a0,s1
    80001958:	fffff097          	auipc	ra,0xfffff
    8000195c:	202080e7          	jalr	514(ra) # 80000b5a <initlock>
      p->state = UNUSED;
    80001960:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001964:	415487b3          	sub	a5,s1,s5
    80001968:	878d                	srai	a5,a5,0x3
    8000196a:	000a3703          	ld	a4,0(s4)
    8000196e:	02e787b3          	mul	a5,a5,a4
    80001972:	2785                	addiw	a5,a5,1
    80001974:	00d7979b          	slliw	a5,a5,0xd
    80001978:	40f907b3          	sub	a5,s2,a5
    8000197c:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000197e:	1b848493          	addi	s1,s1,440
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
    800019ba:	3fa50513          	addi	a0,a0,1018 # 80010db0 <cpus>
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
    800019e2:	3a270713          	addi	a4,a4,930 # 80010d80 <pid_lock>
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
    80001a1a:	faa7a783          	lw	a5,-86(a5) # 800089c0 <first.1716>
    80001a1e:	eb89                	bnez	a5,80001a30 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a20:	00001097          	auipc	ra,0x1
    80001a24:	e42080e7          	jalr	-446(ra) # 80002862 <usertrapret>
}
    80001a28:	60a2                	ld	ra,8(sp)
    80001a2a:	6402                	ld	s0,0(sp)
    80001a2c:	0141                	addi	sp,sp,16
    80001a2e:	8082                	ret
    first = 0;
    80001a30:	00007797          	auipc	a5,0x7
    80001a34:	f807a823          	sw	zero,-112(a5) # 800089c0 <first.1716>
    fsinit(ROOTDEV);
    80001a38:	4505                	li	a0,1
    80001a3a:	00002097          	auipc	ra,0x2
    80001a3e:	dfe080e7          	jalr	-514(ra) # 80003838 <fsinit>
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
    80001a54:	33090913          	addi	s2,s2,816 # 80010d80 <pid_lock>
    80001a58:	854a                	mv	a0,s2
    80001a5a:	fffff097          	auipc	ra,0xfffff
    80001a5e:	190080e7          	jalr	400(ra) # 80000bea <acquire>
  pid = nextpid;
    80001a62:	00007797          	auipc	a5,0x7
    80001a66:	f6278793          	addi	a5,a5,-158 # 800089c4 <nextpid>
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
    80001be0:	5d448493          	addi	s1,s1,1492 # 800111b0 <proc>
    80001be4:	00016917          	auipc	s2,0x16
    80001be8:	3cc90913          	addi	s2,s2,972 # 80017fb0 <tickslock>
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
    80001c04:	1b848493          	addi	s1,s1,440
    80001c08:	ff2492e3          	bne	s1,s2,80001bec <allocproc+0x1c>
  return 0;
    80001c0c:	4481                	li	s1,0
    80001c0e:	a041                	j	80001c8e <allocproc+0xbe>
  p->pid = allocpid();
    80001c10:	00000097          	auipc	ra,0x0
    80001c14:	e34080e7          	jalr	-460(ra) # 80001a44 <allocpid>
    80001c18:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c1a:	4785                	li	a5,1
    80001c1c:	cc9c                	sw	a5,24(s1)
  p->time_created = ticks;
    80001c1e:	00007797          	auipc	a5,0x7
    80001c22:	ef27e783          	lwu	a5,-270(a5) # 80008b10 <ticks>
    80001c26:	16f4bc23          	sd	a5,376(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c2a:	fffff097          	auipc	ra,0xfffff
    80001c2e:	ed0080e7          	jalr	-304(ra) # 80000afa <kalloc>
    80001c32:	892a                	mv	s2,a0
    80001c34:	eca8                	sd	a0,88(s1)
    80001c36:	c13d                	beqz	a0,80001c9c <allocproc+0xcc>
  p->pagetable = proc_pagetable(p);
    80001c38:	8526                	mv	a0,s1
    80001c3a:	00000097          	auipc	ra,0x0
    80001c3e:	e50080e7          	jalr	-432(ra) # 80001a8a <proc_pagetable>
    80001c42:	892a                	mv	s2,a0
    80001c44:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c46:	c53d                	beqz	a0,80001cb4 <allocproc+0xe4>
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
    80001c78:	e9c7a783          	lw	a5,-356(a5) # 80008b10 <ticks>
    80001c7c:	16f4a823          	sw	a5,368(s1)
  p->alarm_on = 0;
    80001c80:	1804ac23          	sw	zero,408(s1)
  p->cur_ticks = 0;
    80001c84:	1804a623          	sw	zero,396(s1)
  p->handlerpermission = 1;
    80001c88:	4785                	li	a5,1
    80001c8a:	1af4a823          	sw	a5,432(s1)
}
    80001c8e:	8526                	mv	a0,s1
    80001c90:	60e2                	ld	ra,24(sp)
    80001c92:	6442                	ld	s0,16(sp)
    80001c94:	64a2                	ld	s1,8(sp)
    80001c96:	6902                	ld	s2,0(sp)
    80001c98:	6105                	addi	sp,sp,32
    80001c9a:	8082                	ret
    freeproc(p);
    80001c9c:	8526                	mv	a0,s1
    80001c9e:	00000097          	auipc	ra,0x0
    80001ca2:	eda080e7          	jalr	-294(ra) # 80001b78 <freeproc>
    release(&p->lock);
    80001ca6:	8526                	mv	a0,s1
    80001ca8:	fffff097          	auipc	ra,0xfffff
    80001cac:	ff6080e7          	jalr	-10(ra) # 80000c9e <release>
    return 0;
    80001cb0:	84ca                	mv	s1,s2
    80001cb2:	bff1                	j	80001c8e <allocproc+0xbe>
    freeproc(p);
    80001cb4:	8526                	mv	a0,s1
    80001cb6:	00000097          	auipc	ra,0x0
    80001cba:	ec2080e7          	jalr	-318(ra) # 80001b78 <freeproc>
    release(&p->lock);
    80001cbe:	8526                	mv	a0,s1
    80001cc0:	fffff097          	auipc	ra,0xfffff
    80001cc4:	fde080e7          	jalr	-34(ra) # 80000c9e <release>
    return 0;
    80001cc8:	84ca                	mv	s1,s2
    80001cca:	b7d1                	j	80001c8e <allocproc+0xbe>

0000000080001ccc <userinit>:
{
    80001ccc:	1101                	addi	sp,sp,-32
    80001cce:	ec06                	sd	ra,24(sp)
    80001cd0:	e822                	sd	s0,16(sp)
    80001cd2:	e426                	sd	s1,8(sp)
    80001cd4:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cd6:	00000097          	auipc	ra,0x0
    80001cda:	efa080e7          	jalr	-262(ra) # 80001bd0 <allocproc>
    80001cde:	84aa                	mv	s1,a0
  initproc = p;
    80001ce0:	00007797          	auipc	a5,0x7
    80001ce4:	e2a7b423          	sd	a0,-472(a5) # 80008b08 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001ce8:	03400613          	li	a2,52
    80001cec:	00007597          	auipc	a1,0x7
    80001cf0:	ce458593          	addi	a1,a1,-796 # 800089d0 <initcode>
    80001cf4:	6928                	ld	a0,80(a0)
    80001cf6:	fffff097          	auipc	ra,0xfffff
    80001cfa:	67c080e7          	jalr	1660(ra) # 80001372 <uvmfirst>
  p->sz = PGSIZE;
    80001cfe:	6785                	lui	a5,0x1
    80001d00:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d02:	6cb8                	ld	a4,88(s1)
    80001d04:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d08:	6cb8                	ld	a4,88(s1)
    80001d0a:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d0c:	4641                	li	a2,16
    80001d0e:	00006597          	auipc	a1,0x6
    80001d12:	4f258593          	addi	a1,a1,1266 # 80008200 <digits+0x1c0>
    80001d16:	15848513          	addi	a0,s1,344
    80001d1a:	fffff097          	auipc	ra,0xfffff
    80001d1e:	11e080e7          	jalr	286(ra) # 80000e38 <safestrcpy>
  p->cwd = namei("/");
    80001d22:	00006517          	auipc	a0,0x6
    80001d26:	4ee50513          	addi	a0,a0,1262 # 80008210 <digits+0x1d0>
    80001d2a:	00002097          	auipc	ra,0x2
    80001d2e:	530080e7          	jalr	1328(ra) # 8000425a <namei>
    80001d32:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d36:	478d                	li	a5,3
    80001d38:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d3a:	8526                	mv	a0,s1
    80001d3c:	fffff097          	auipc	ra,0xfffff
    80001d40:	f62080e7          	jalr	-158(ra) # 80000c9e <release>
}
    80001d44:	60e2                	ld	ra,24(sp)
    80001d46:	6442                	ld	s0,16(sp)
    80001d48:	64a2                	ld	s1,8(sp)
    80001d4a:	6105                	addi	sp,sp,32
    80001d4c:	8082                	ret

0000000080001d4e <growproc>:
{
    80001d4e:	1101                	addi	sp,sp,-32
    80001d50:	ec06                	sd	ra,24(sp)
    80001d52:	e822                	sd	s0,16(sp)
    80001d54:	e426                	sd	s1,8(sp)
    80001d56:	e04a                	sd	s2,0(sp)
    80001d58:	1000                	addi	s0,sp,32
    80001d5a:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d5c:	00000097          	auipc	ra,0x0
    80001d60:	c6a080e7          	jalr	-918(ra) # 800019c6 <myproc>
    80001d64:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d66:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d68:	01204c63          	bgtz	s2,80001d80 <growproc+0x32>
  } else if(n < 0){
    80001d6c:	02094663          	bltz	s2,80001d98 <growproc+0x4a>
  p->sz = sz;
    80001d70:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d72:	4501                	li	a0,0
}
    80001d74:	60e2                	ld	ra,24(sp)
    80001d76:	6442                	ld	s0,16(sp)
    80001d78:	64a2                	ld	s1,8(sp)
    80001d7a:	6902                	ld	s2,0(sp)
    80001d7c:	6105                	addi	sp,sp,32
    80001d7e:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d80:	4691                	li	a3,4
    80001d82:	00b90633          	add	a2,s2,a1
    80001d86:	6928                	ld	a0,80(a0)
    80001d88:	fffff097          	auipc	ra,0xfffff
    80001d8c:	6a4080e7          	jalr	1700(ra) # 8000142c <uvmalloc>
    80001d90:	85aa                	mv	a1,a0
    80001d92:	fd79                	bnez	a0,80001d70 <growproc+0x22>
      return -1;
    80001d94:	557d                	li	a0,-1
    80001d96:	bff9                	j	80001d74 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d98:	00b90633          	add	a2,s2,a1
    80001d9c:	6928                	ld	a0,80(a0)
    80001d9e:	fffff097          	auipc	ra,0xfffff
    80001da2:	646080e7          	jalr	1606(ra) # 800013e4 <uvmdealloc>
    80001da6:	85aa                	mv	a1,a0
    80001da8:	b7e1                	j	80001d70 <growproc+0x22>

0000000080001daa <fork>:
{
    80001daa:	7179                	addi	sp,sp,-48
    80001dac:	f406                	sd	ra,40(sp)
    80001dae:	f022                	sd	s0,32(sp)
    80001db0:	ec26                	sd	s1,24(sp)
    80001db2:	e84a                	sd	s2,16(sp)
    80001db4:	e44e                	sd	s3,8(sp)
    80001db6:	e052                	sd	s4,0(sp)
    80001db8:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001dba:	00000097          	auipc	ra,0x0
    80001dbe:	c0c080e7          	jalr	-1012(ra) # 800019c6 <myproc>
    80001dc2:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001dc4:	00000097          	auipc	ra,0x0
    80001dc8:	e0c080e7          	jalr	-500(ra) # 80001bd0 <allocproc>
    80001dcc:	10050f63          	beqz	a0,80001eea <fork+0x140>
    80001dd0:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001dd2:	04893603          	ld	a2,72(s2)
    80001dd6:	692c                	ld	a1,80(a0)
    80001dd8:	05093503          	ld	a0,80(s2)
    80001ddc:	fffff097          	auipc	ra,0xfffff
    80001de0:	7a4080e7          	jalr	1956(ra) # 80001580 <uvmcopy>
    80001de4:	04054a63          	bltz	a0,80001e38 <fork+0x8e>
  np->sz = p->sz;
    80001de8:	04893783          	ld	a5,72(s2)
    80001dec:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001df0:	05893683          	ld	a3,88(s2)
    80001df4:	87b6                	mv	a5,a3
    80001df6:	0589b703          	ld	a4,88(s3)
    80001dfa:	12068693          	addi	a3,a3,288
    80001dfe:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e02:	6788                	ld	a0,8(a5)
    80001e04:	6b8c                	ld	a1,16(a5)
    80001e06:	6f90                	ld	a2,24(a5)
    80001e08:	01073023          	sd	a6,0(a4)
    80001e0c:	e708                	sd	a0,8(a4)
    80001e0e:	eb0c                	sd	a1,16(a4)
    80001e10:	ef10                	sd	a2,24(a4)
    80001e12:	02078793          	addi	a5,a5,32
    80001e16:	02070713          	addi	a4,a4,32
    80001e1a:	fed792e3          	bne	a5,a3,80001dfe <fork+0x54>
  np->mask = p->mask;
    80001e1e:	16892783          	lw	a5,360(s2)
    80001e22:	16f9a423          	sw	a5,360(s3)
  np->trapframe->a0 = 0;
    80001e26:	0589b783          	ld	a5,88(s3)
    80001e2a:	0607b823          	sd	zero,112(a5)
    80001e2e:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001e32:	15000a13          	li	s4,336
    80001e36:	a03d                	j	80001e64 <fork+0xba>
    freeproc(np);
    80001e38:	854e                	mv	a0,s3
    80001e3a:	00000097          	auipc	ra,0x0
    80001e3e:	d3e080e7          	jalr	-706(ra) # 80001b78 <freeproc>
    release(&np->lock);
    80001e42:	854e                	mv	a0,s3
    80001e44:	fffff097          	auipc	ra,0xfffff
    80001e48:	e5a080e7          	jalr	-422(ra) # 80000c9e <release>
    return -1;
    80001e4c:	5a7d                	li	s4,-1
    80001e4e:	a069                	j	80001ed8 <fork+0x12e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e50:	00003097          	auipc	ra,0x3
    80001e54:	aa0080e7          	jalr	-1376(ra) # 800048f0 <filedup>
    80001e58:	009987b3          	add	a5,s3,s1
    80001e5c:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001e5e:	04a1                	addi	s1,s1,8
    80001e60:	01448763          	beq	s1,s4,80001e6e <fork+0xc4>
    if(p->ofile[i])
    80001e64:	009907b3          	add	a5,s2,s1
    80001e68:	6388                	ld	a0,0(a5)
    80001e6a:	f17d                	bnez	a0,80001e50 <fork+0xa6>
    80001e6c:	bfcd                	j	80001e5e <fork+0xb4>
  np->cwd = idup(p->cwd);
    80001e6e:	15093503          	ld	a0,336(s2)
    80001e72:	00002097          	auipc	ra,0x2
    80001e76:	c04080e7          	jalr	-1020(ra) # 80003a76 <idup>
    80001e7a:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e7e:	4641                	li	a2,16
    80001e80:	15890593          	addi	a1,s2,344
    80001e84:	15898513          	addi	a0,s3,344
    80001e88:	fffff097          	auipc	ra,0xfffff
    80001e8c:	fb0080e7          	jalr	-80(ra) # 80000e38 <safestrcpy>
  pid = np->pid;
    80001e90:	0309aa03          	lw	s4,48(s3)
  release(&np->lock);
    80001e94:	854e                	mv	a0,s3
    80001e96:	fffff097          	auipc	ra,0xfffff
    80001e9a:	e08080e7          	jalr	-504(ra) # 80000c9e <release>
  acquire(&wait_lock);
    80001e9e:	0000f497          	auipc	s1,0xf
    80001ea2:	efa48493          	addi	s1,s1,-262 # 80010d98 <wait_lock>
    80001ea6:	8526                	mv	a0,s1
    80001ea8:	fffff097          	auipc	ra,0xfffff
    80001eac:	d42080e7          	jalr	-702(ra) # 80000bea <acquire>
  np->parent = p;
    80001eb0:	0329bc23          	sd	s2,56(s3)
  release(&wait_lock);
    80001eb4:	8526                	mv	a0,s1
    80001eb6:	fffff097          	auipc	ra,0xfffff
    80001eba:	de8080e7          	jalr	-536(ra) # 80000c9e <release>
  acquire(&np->lock);
    80001ebe:	854e                	mv	a0,s3
    80001ec0:	fffff097          	auipc	ra,0xfffff
    80001ec4:	d2a080e7          	jalr	-726(ra) # 80000bea <acquire>
  np->state = RUNNABLE;
    80001ec8:	478d                	li	a5,3
    80001eca:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001ece:	854e                	mv	a0,s3
    80001ed0:	fffff097          	auipc	ra,0xfffff
    80001ed4:	dce080e7          	jalr	-562(ra) # 80000c9e <release>
}
    80001ed8:	8552                	mv	a0,s4
    80001eda:	70a2                	ld	ra,40(sp)
    80001edc:	7402                	ld	s0,32(sp)
    80001ede:	64e2                	ld	s1,24(sp)
    80001ee0:	6942                	ld	s2,16(sp)
    80001ee2:	69a2                	ld	s3,8(sp)
    80001ee4:	6a02                	ld	s4,0(sp)
    80001ee6:	6145                	addi	sp,sp,48
    80001ee8:	8082                	ret
    return -1;
    80001eea:	5a7d                	li	s4,-1
    80001eec:	b7f5                	j	80001ed8 <fork+0x12e>

0000000080001eee <update_time>:
{
    80001eee:	7179                	addi	sp,sp,-48
    80001ef0:	f406                	sd	ra,40(sp)
    80001ef2:	f022                	sd	s0,32(sp)
    80001ef4:	ec26                	sd	s1,24(sp)
    80001ef6:	e84a                	sd	s2,16(sp)
    80001ef8:	e44e                	sd	s3,8(sp)
    80001efa:	1800                	addi	s0,sp,48
  for (p = proc; p < &proc[NPROC]; p++) {
    80001efc:	0000f497          	auipc	s1,0xf
    80001f00:	2b448493          	addi	s1,s1,692 # 800111b0 <proc>
    if (p->state == RUNNING) {
    80001f04:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++) {
    80001f06:	00016917          	auipc	s2,0x16
    80001f0a:	0aa90913          	addi	s2,s2,170 # 80017fb0 <tickslock>
    80001f0e:	a811                	j	80001f22 <update_time+0x34>
    release(&p->lock); 
    80001f10:	8526                	mv	a0,s1
    80001f12:	fffff097          	auipc	ra,0xfffff
    80001f16:	d8c080e7          	jalr	-628(ra) # 80000c9e <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001f1a:	1b848493          	addi	s1,s1,440
    80001f1e:	03248063          	beq	s1,s2,80001f3e <update_time+0x50>
    acquire(&p->lock);
    80001f22:	8526                	mv	a0,s1
    80001f24:	fffff097          	auipc	ra,0xfffff
    80001f28:	cc6080e7          	jalr	-826(ra) # 80000bea <acquire>
    if (p->state == RUNNING) {
    80001f2c:	4c9c                	lw	a5,24(s1)
    80001f2e:	ff3791e3          	bne	a5,s3,80001f10 <update_time+0x22>
      p->rtime++;
    80001f32:	16c4a783          	lw	a5,364(s1)
    80001f36:	2785                	addiw	a5,a5,1
    80001f38:	16f4a623          	sw	a5,364(s1)
    80001f3c:	bfd1                	j	80001f10 <update_time+0x22>
}
    80001f3e:	70a2                	ld	ra,40(sp)
    80001f40:	7402                	ld	s0,32(sp)
    80001f42:	64e2                	ld	s1,24(sp)
    80001f44:	6942                	ld	s2,16(sp)
    80001f46:	69a2                	ld	s3,8(sp)
    80001f48:	6145                	addi	sp,sp,48
    80001f4a:	8082                	ret

0000000080001f4c <scheduler>:
{
    80001f4c:	7139                	addi	sp,sp,-64
    80001f4e:	fc06                	sd	ra,56(sp)
    80001f50:	f822                	sd	s0,48(sp)
    80001f52:	f426                	sd	s1,40(sp)
    80001f54:	f04a                	sd	s2,32(sp)
    80001f56:	ec4e                	sd	s3,24(sp)
    80001f58:	e852                	sd	s4,16(sp)
    80001f5a:	e456                	sd	s5,8(sp)
    80001f5c:	e05a                	sd	s6,0(sp)
    80001f5e:	0080                	addi	s0,sp,64
    80001f60:	8792                	mv	a5,tp
  int id = r_tp();
    80001f62:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f64:	00779a93          	slli	s5,a5,0x7
    80001f68:	0000f717          	auipc	a4,0xf
    80001f6c:	e1870713          	addi	a4,a4,-488 # 80010d80 <pid_lock>
    80001f70:	9756                	add	a4,a4,s5
    80001f72:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f76:	0000f717          	auipc	a4,0xf
    80001f7a:	e4270713          	addi	a4,a4,-446 # 80010db8 <cpus+0x8>
    80001f7e:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001f80:	498d                	li	s3,3
        p->state = RUNNING;
    80001f82:	4b11                	li	s6,4
        c->proc = p;
    80001f84:	079e                	slli	a5,a5,0x7
    80001f86:	0000fa17          	auipc	s4,0xf
    80001f8a:	dfaa0a13          	addi	s4,s4,-518 # 80010d80 <pid_lock>
    80001f8e:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f90:	00016917          	auipc	s2,0x16
    80001f94:	02090913          	addi	s2,s2,32 # 80017fb0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f9c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fa0:	10079073          	csrw	sstatus,a5
    80001fa4:	0000f497          	auipc	s1,0xf
    80001fa8:	20c48493          	addi	s1,s1,524 # 800111b0 <proc>
    80001fac:	a03d                	j	80001fda <scheduler+0x8e>
        p->state = RUNNING;
    80001fae:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001fb2:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001fb6:	06048593          	addi	a1,s1,96
    80001fba:	8556                	mv	a0,s5
    80001fbc:	00000097          	auipc	ra,0x0
    80001fc0:	7fc080e7          	jalr	2044(ra) # 800027b8 <swtch>
        c->proc = 0;
    80001fc4:	020a3823          	sd	zero,48(s4)
      release(&p->lock);
    80001fc8:	8526                	mv	a0,s1
    80001fca:	fffff097          	auipc	ra,0xfffff
    80001fce:	cd4080e7          	jalr	-812(ra) # 80000c9e <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fd2:	1b848493          	addi	s1,s1,440
    80001fd6:	fd2481e3          	beq	s1,s2,80001f98 <scheduler+0x4c>
      acquire(&p->lock);
    80001fda:	8526                	mv	a0,s1
    80001fdc:	fffff097          	auipc	ra,0xfffff
    80001fe0:	c0e080e7          	jalr	-1010(ra) # 80000bea <acquire>
      if(p->state == RUNNABLE) {
    80001fe4:	4c9c                	lw	a5,24(s1)
    80001fe6:	ff3791e3          	bne	a5,s3,80001fc8 <scheduler+0x7c>
    80001fea:	b7d1                	j	80001fae <scheduler+0x62>

0000000080001fec <sched>:
{
    80001fec:	7179                	addi	sp,sp,-48
    80001fee:	f406                	sd	ra,40(sp)
    80001ff0:	f022                	sd	s0,32(sp)
    80001ff2:	ec26                	sd	s1,24(sp)
    80001ff4:	e84a                	sd	s2,16(sp)
    80001ff6:	e44e                	sd	s3,8(sp)
    80001ff8:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001ffa:	00000097          	auipc	ra,0x0
    80001ffe:	9cc080e7          	jalr	-1588(ra) # 800019c6 <myproc>
    80002002:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002004:	fffff097          	auipc	ra,0xfffff
    80002008:	b6c080e7          	jalr	-1172(ra) # 80000b70 <holding>
    8000200c:	c93d                	beqz	a0,80002082 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000200e:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002010:	2781                	sext.w	a5,a5
    80002012:	079e                	slli	a5,a5,0x7
    80002014:	0000f717          	auipc	a4,0xf
    80002018:	d6c70713          	addi	a4,a4,-660 # 80010d80 <pid_lock>
    8000201c:	97ba                	add	a5,a5,a4
    8000201e:	0a87a703          	lw	a4,168(a5)
    80002022:	4785                	li	a5,1
    80002024:	06f71763          	bne	a4,a5,80002092 <sched+0xa6>
  if(p->state == RUNNING)
    80002028:	4c98                	lw	a4,24(s1)
    8000202a:	4791                	li	a5,4
    8000202c:	06f70b63          	beq	a4,a5,800020a2 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002030:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002034:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002036:	efb5                	bnez	a5,800020b2 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002038:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000203a:	0000f917          	auipc	s2,0xf
    8000203e:	d4690913          	addi	s2,s2,-698 # 80010d80 <pid_lock>
    80002042:	2781                	sext.w	a5,a5
    80002044:	079e                	slli	a5,a5,0x7
    80002046:	97ca                	add	a5,a5,s2
    80002048:	0ac7a983          	lw	s3,172(a5)
    8000204c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000204e:	2781                	sext.w	a5,a5
    80002050:	079e                	slli	a5,a5,0x7
    80002052:	0000f597          	auipc	a1,0xf
    80002056:	d6658593          	addi	a1,a1,-666 # 80010db8 <cpus+0x8>
    8000205a:	95be                	add	a1,a1,a5
    8000205c:	06048513          	addi	a0,s1,96
    80002060:	00000097          	auipc	ra,0x0
    80002064:	758080e7          	jalr	1880(ra) # 800027b8 <swtch>
    80002068:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000206a:	2781                	sext.w	a5,a5
    8000206c:	079e                	slli	a5,a5,0x7
    8000206e:	97ca                	add	a5,a5,s2
    80002070:	0b37a623          	sw	s3,172(a5)
}
    80002074:	70a2                	ld	ra,40(sp)
    80002076:	7402                	ld	s0,32(sp)
    80002078:	64e2                	ld	s1,24(sp)
    8000207a:	6942                	ld	s2,16(sp)
    8000207c:	69a2                	ld	s3,8(sp)
    8000207e:	6145                	addi	sp,sp,48
    80002080:	8082                	ret
    panic("sched p->lock");
    80002082:	00006517          	auipc	a0,0x6
    80002086:	19650513          	addi	a0,a0,406 # 80008218 <digits+0x1d8>
    8000208a:	ffffe097          	auipc	ra,0xffffe
    8000208e:	4ba080e7          	jalr	1210(ra) # 80000544 <panic>
    panic("sched locks");
    80002092:	00006517          	auipc	a0,0x6
    80002096:	19650513          	addi	a0,a0,406 # 80008228 <digits+0x1e8>
    8000209a:	ffffe097          	auipc	ra,0xffffe
    8000209e:	4aa080e7          	jalr	1194(ra) # 80000544 <panic>
    panic("sched running");
    800020a2:	00006517          	auipc	a0,0x6
    800020a6:	19650513          	addi	a0,a0,406 # 80008238 <digits+0x1f8>
    800020aa:	ffffe097          	auipc	ra,0xffffe
    800020ae:	49a080e7          	jalr	1178(ra) # 80000544 <panic>
    panic("sched interruptible");
    800020b2:	00006517          	auipc	a0,0x6
    800020b6:	19650513          	addi	a0,a0,406 # 80008248 <digits+0x208>
    800020ba:	ffffe097          	auipc	ra,0xffffe
    800020be:	48a080e7          	jalr	1162(ra) # 80000544 <panic>

00000000800020c2 <yield>:
{
    800020c2:	1101                	addi	sp,sp,-32
    800020c4:	ec06                	sd	ra,24(sp)
    800020c6:	e822                	sd	s0,16(sp)
    800020c8:	e426                	sd	s1,8(sp)
    800020ca:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020cc:	00000097          	auipc	ra,0x0
    800020d0:	8fa080e7          	jalr	-1798(ra) # 800019c6 <myproc>
    800020d4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020d6:	fffff097          	auipc	ra,0xfffff
    800020da:	b14080e7          	jalr	-1260(ra) # 80000bea <acquire>
  p->state = RUNNABLE;
    800020de:	478d                	li	a5,3
    800020e0:	cc9c                	sw	a5,24(s1)
  sched();
    800020e2:	00000097          	auipc	ra,0x0
    800020e6:	f0a080e7          	jalr	-246(ra) # 80001fec <sched>
  release(&p->lock);
    800020ea:	8526                	mv	a0,s1
    800020ec:	fffff097          	auipc	ra,0xfffff
    800020f0:	bb2080e7          	jalr	-1102(ra) # 80000c9e <release>
}
    800020f4:	60e2                	ld	ra,24(sp)
    800020f6:	6442                	ld	s0,16(sp)
    800020f8:	64a2                	ld	s1,8(sp)
    800020fa:	6105                	addi	sp,sp,32
    800020fc:	8082                	ret

00000000800020fe <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800020fe:	7179                	addi	sp,sp,-48
    80002100:	f406                	sd	ra,40(sp)
    80002102:	f022                	sd	s0,32(sp)
    80002104:	ec26                	sd	s1,24(sp)
    80002106:	e84a                	sd	s2,16(sp)
    80002108:	e44e                	sd	s3,8(sp)
    8000210a:	1800                	addi	s0,sp,48
    8000210c:	89aa                	mv	s3,a0
    8000210e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002110:	00000097          	auipc	ra,0x0
    80002114:	8b6080e7          	jalr	-1866(ra) # 800019c6 <myproc>
    80002118:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000211a:	fffff097          	auipc	ra,0xfffff
    8000211e:	ad0080e7          	jalr	-1328(ra) # 80000bea <acquire>
  release(lk);
    80002122:	854a                	mv	a0,s2
    80002124:	fffff097          	auipc	ra,0xfffff
    80002128:	b7a080e7          	jalr	-1158(ra) # 80000c9e <release>

  // Go to sleep.
  p->chan = chan;
    8000212c:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002130:	4789                	li	a5,2
    80002132:	cc9c                	sw	a5,24(s1)

  sched();
    80002134:	00000097          	auipc	ra,0x0
    80002138:	eb8080e7          	jalr	-328(ra) # 80001fec <sched>

  // Tidy up.
  p->chan = 0;
    8000213c:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002140:	8526                	mv	a0,s1
    80002142:	fffff097          	auipc	ra,0xfffff
    80002146:	b5c080e7          	jalr	-1188(ra) # 80000c9e <release>
  acquire(lk);
    8000214a:	854a                	mv	a0,s2
    8000214c:	fffff097          	auipc	ra,0xfffff
    80002150:	a9e080e7          	jalr	-1378(ra) # 80000bea <acquire>
}
    80002154:	70a2                	ld	ra,40(sp)
    80002156:	7402                	ld	s0,32(sp)
    80002158:	64e2                	ld	s1,24(sp)
    8000215a:	6942                	ld	s2,16(sp)
    8000215c:	69a2                	ld	s3,8(sp)
    8000215e:	6145                	addi	sp,sp,48
    80002160:	8082                	ret

0000000080002162 <waitx>:
{
    80002162:	711d                	addi	sp,sp,-96
    80002164:	ec86                	sd	ra,88(sp)
    80002166:	e8a2                	sd	s0,80(sp)
    80002168:	e4a6                	sd	s1,72(sp)
    8000216a:	e0ca                	sd	s2,64(sp)
    8000216c:	fc4e                	sd	s3,56(sp)
    8000216e:	f852                	sd	s4,48(sp)
    80002170:	f456                	sd	s5,40(sp)
    80002172:	f05a                	sd	s6,32(sp)
    80002174:	ec5e                	sd	s7,24(sp)
    80002176:	e862                	sd	s8,16(sp)
    80002178:	e466                	sd	s9,8(sp)
    8000217a:	e06a                	sd	s10,0(sp)
    8000217c:	1080                	addi	s0,sp,96
    8000217e:	8b2a                	mv	s6,a0
    80002180:	8bae                	mv	s7,a1
    80002182:	8c32                	mv	s8,a2
  struct proc *p = myproc();
    80002184:	00000097          	auipc	ra,0x0
    80002188:	842080e7          	jalr	-1982(ra) # 800019c6 <myproc>
    8000218c:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000218e:	0000f517          	auipc	a0,0xf
    80002192:	c0a50513          	addi	a0,a0,-1014 # 80010d98 <wait_lock>
    80002196:	fffff097          	auipc	ra,0xfffff
    8000219a:	a54080e7          	jalr	-1452(ra) # 80000bea <acquire>
    havekids = 0;
    8000219e:	4c81                	li	s9,0
        if(np->state == ZOMBIE){
    800021a0:	4a15                	li	s4,5
    for(np = proc; np < &proc[NPROC]; np++){
    800021a2:	00016997          	auipc	s3,0x16
    800021a6:	e0e98993          	addi	s3,s3,-498 # 80017fb0 <tickslock>
        havekids = 1;
    800021aa:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021ac:	0000fd17          	auipc	s10,0xf
    800021b0:	becd0d13          	addi	s10,s10,-1044 # 80010d98 <wait_lock>
    havekids = 0;
    800021b4:	8766                	mv	a4,s9
    for(np = proc; np < &proc[NPROC]; np++){
    800021b6:	0000f497          	auipc	s1,0xf
    800021ba:	ffa48493          	addi	s1,s1,-6 # 800111b0 <proc>
    800021be:	a059                	j	80002244 <waitx+0xe2>
          pid = np->pid;
    800021c0:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    800021c4:	16c4a703          	lw	a4,364(s1)
    800021c8:	00ec2023          	sw	a4,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    800021cc:	1704a783          	lw	a5,368(s1)
    800021d0:	9f3d                	addw	a4,a4,a5
    800021d2:	1744a783          	lw	a5,372(s1)
    800021d6:	9f99                	subw	a5,a5,a4
    800021d8:	00fba023          	sw	a5,0(s7) # fffffffffffff000 <end+0xffffffff7ffdbc70>
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800021dc:	000b0e63          	beqz	s6,800021f8 <waitx+0x96>
    800021e0:	4691                	li	a3,4
    800021e2:	02c48613          	addi	a2,s1,44
    800021e6:	85da                	mv	a1,s6
    800021e8:	05093503          	ld	a0,80(s2)
    800021ec:	fffff097          	auipc	ra,0xfffff
    800021f0:	498080e7          	jalr	1176(ra) # 80001684 <copyout>
    800021f4:	02054563          	bltz	a0,8000221e <waitx+0xbc>
          freeproc(np);
    800021f8:	8526                	mv	a0,s1
    800021fa:	00000097          	auipc	ra,0x0
    800021fe:	97e080e7          	jalr	-1666(ra) # 80001b78 <freeproc>
          release(&np->lock);
    80002202:	8526                	mv	a0,s1
    80002204:	fffff097          	auipc	ra,0xfffff
    80002208:	a9a080e7          	jalr	-1382(ra) # 80000c9e <release>
          release(&wait_lock);
    8000220c:	0000f517          	auipc	a0,0xf
    80002210:	b8c50513          	addi	a0,a0,-1140 # 80010d98 <wait_lock>
    80002214:	fffff097          	auipc	ra,0xfffff
    80002218:	a8a080e7          	jalr	-1398(ra) # 80000c9e <release>
          return pid;
    8000221c:	a09d                	j	80002282 <waitx+0x120>
            release(&np->lock);
    8000221e:	8526                	mv	a0,s1
    80002220:	fffff097          	auipc	ra,0xfffff
    80002224:	a7e080e7          	jalr	-1410(ra) # 80000c9e <release>
            release(&wait_lock);
    80002228:	0000f517          	auipc	a0,0xf
    8000222c:	b7050513          	addi	a0,a0,-1168 # 80010d98 <wait_lock>
    80002230:	fffff097          	auipc	ra,0xfffff
    80002234:	a6e080e7          	jalr	-1426(ra) # 80000c9e <release>
            return -1;
    80002238:	59fd                	li	s3,-1
    8000223a:	a0a1                	j	80002282 <waitx+0x120>
    for(np = proc; np < &proc[NPROC]; np++){
    8000223c:	1b848493          	addi	s1,s1,440
    80002240:	03348463          	beq	s1,s3,80002268 <waitx+0x106>
      if(np->parent == p){
    80002244:	7c9c                	ld	a5,56(s1)
    80002246:	ff279be3          	bne	a5,s2,8000223c <waitx+0xda>
        acquire(&np->lock);
    8000224a:	8526                	mv	a0,s1
    8000224c:	fffff097          	auipc	ra,0xfffff
    80002250:	99e080e7          	jalr	-1634(ra) # 80000bea <acquire>
        if(np->state == ZOMBIE){
    80002254:	4c9c                	lw	a5,24(s1)
    80002256:	f74785e3          	beq	a5,s4,800021c0 <waitx+0x5e>
        release(&np->lock);
    8000225a:	8526                	mv	a0,s1
    8000225c:	fffff097          	auipc	ra,0xfffff
    80002260:	a42080e7          	jalr	-1470(ra) # 80000c9e <release>
        havekids = 1;
    80002264:	8756                	mv	a4,s5
    80002266:	bfd9                	j	8000223c <waitx+0xda>
    if(!havekids || p->killed){
    80002268:	c701                	beqz	a4,80002270 <waitx+0x10e>
    8000226a:	02892783          	lw	a5,40(s2)
    8000226e:	cb8d                	beqz	a5,800022a0 <waitx+0x13e>
      release(&wait_lock);
    80002270:	0000f517          	auipc	a0,0xf
    80002274:	b2850513          	addi	a0,a0,-1240 # 80010d98 <wait_lock>
    80002278:	fffff097          	auipc	ra,0xfffff
    8000227c:	a26080e7          	jalr	-1498(ra) # 80000c9e <release>
      return -1;
    80002280:	59fd                	li	s3,-1
}
    80002282:	854e                	mv	a0,s3
    80002284:	60e6                	ld	ra,88(sp)
    80002286:	6446                	ld	s0,80(sp)
    80002288:	64a6                	ld	s1,72(sp)
    8000228a:	6906                	ld	s2,64(sp)
    8000228c:	79e2                	ld	s3,56(sp)
    8000228e:	7a42                	ld	s4,48(sp)
    80002290:	7aa2                	ld	s5,40(sp)
    80002292:	7b02                	ld	s6,32(sp)
    80002294:	6be2                	ld	s7,24(sp)
    80002296:	6c42                	ld	s8,16(sp)
    80002298:	6ca2                	ld	s9,8(sp)
    8000229a:	6d02                	ld	s10,0(sp)
    8000229c:	6125                	addi	sp,sp,96
    8000229e:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800022a0:	85ea                	mv	a1,s10
    800022a2:	854a                	mv	a0,s2
    800022a4:	00000097          	auipc	ra,0x0
    800022a8:	e5a080e7          	jalr	-422(ra) # 800020fe <sleep>
    havekids = 0;
    800022ac:	b721                	j	800021b4 <waitx+0x52>

00000000800022ae <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800022ae:	7139                	addi	sp,sp,-64
    800022b0:	fc06                	sd	ra,56(sp)
    800022b2:	f822                	sd	s0,48(sp)
    800022b4:	f426                	sd	s1,40(sp)
    800022b6:	f04a                	sd	s2,32(sp)
    800022b8:	ec4e                	sd	s3,24(sp)
    800022ba:	e852                	sd	s4,16(sp)
    800022bc:	e456                	sd	s5,8(sp)
    800022be:	0080                	addi	s0,sp,64
    800022c0:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800022c2:	0000f497          	auipc	s1,0xf
    800022c6:	eee48493          	addi	s1,s1,-274 # 800111b0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800022ca:	4989                	li	s3,2
        p->state = RUNNABLE;
    800022cc:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800022ce:	00016917          	auipc	s2,0x16
    800022d2:	ce290913          	addi	s2,s2,-798 # 80017fb0 <tickslock>
    800022d6:	a821                	j	800022ee <wakeup+0x40>
        p->state = RUNNABLE;
    800022d8:	0154ac23          	sw	s5,24(s1)
      }
      release(&p->lock);
    800022dc:	8526                	mv	a0,s1
    800022de:	fffff097          	auipc	ra,0xfffff
    800022e2:	9c0080e7          	jalr	-1600(ra) # 80000c9e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800022e6:	1b848493          	addi	s1,s1,440
    800022ea:	03248463          	beq	s1,s2,80002312 <wakeup+0x64>
    if(p != myproc()){
    800022ee:	fffff097          	auipc	ra,0xfffff
    800022f2:	6d8080e7          	jalr	1752(ra) # 800019c6 <myproc>
    800022f6:	fea488e3          	beq	s1,a0,800022e6 <wakeup+0x38>
      acquire(&p->lock);
    800022fa:	8526                	mv	a0,s1
    800022fc:	fffff097          	auipc	ra,0xfffff
    80002300:	8ee080e7          	jalr	-1810(ra) # 80000bea <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002304:	4c9c                	lw	a5,24(s1)
    80002306:	fd379be3          	bne	a5,s3,800022dc <wakeup+0x2e>
    8000230a:	709c                	ld	a5,32(s1)
    8000230c:	fd4798e3          	bne	a5,s4,800022dc <wakeup+0x2e>
    80002310:	b7e1                	j	800022d8 <wakeup+0x2a>
    }
  }
}
    80002312:	70e2                	ld	ra,56(sp)
    80002314:	7442                	ld	s0,48(sp)
    80002316:	74a2                	ld	s1,40(sp)
    80002318:	7902                	ld	s2,32(sp)
    8000231a:	69e2                	ld	s3,24(sp)
    8000231c:	6a42                	ld	s4,16(sp)
    8000231e:	6aa2                	ld	s5,8(sp)
    80002320:	6121                	addi	sp,sp,64
    80002322:	8082                	ret

0000000080002324 <reparent>:
{
    80002324:	7179                	addi	sp,sp,-48
    80002326:	f406                	sd	ra,40(sp)
    80002328:	f022                	sd	s0,32(sp)
    8000232a:	ec26                	sd	s1,24(sp)
    8000232c:	e84a                	sd	s2,16(sp)
    8000232e:	e44e                	sd	s3,8(sp)
    80002330:	e052                	sd	s4,0(sp)
    80002332:	1800                	addi	s0,sp,48
    80002334:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002336:	0000f497          	auipc	s1,0xf
    8000233a:	e7a48493          	addi	s1,s1,-390 # 800111b0 <proc>
      pp->parent = initproc;
    8000233e:	00006a17          	auipc	s4,0x6
    80002342:	7caa0a13          	addi	s4,s4,1994 # 80008b08 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002346:	00016997          	auipc	s3,0x16
    8000234a:	c6a98993          	addi	s3,s3,-918 # 80017fb0 <tickslock>
    8000234e:	a029                	j	80002358 <reparent+0x34>
    80002350:	1b848493          	addi	s1,s1,440
    80002354:	01348d63          	beq	s1,s3,8000236e <reparent+0x4a>
    if(pp->parent == p){
    80002358:	7c9c                	ld	a5,56(s1)
    8000235a:	ff279be3          	bne	a5,s2,80002350 <reparent+0x2c>
      pp->parent = initproc;
    8000235e:	000a3503          	ld	a0,0(s4)
    80002362:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002364:	00000097          	auipc	ra,0x0
    80002368:	f4a080e7          	jalr	-182(ra) # 800022ae <wakeup>
    8000236c:	b7d5                	j	80002350 <reparent+0x2c>
}
    8000236e:	70a2                	ld	ra,40(sp)
    80002370:	7402                	ld	s0,32(sp)
    80002372:	64e2                	ld	s1,24(sp)
    80002374:	6942                	ld	s2,16(sp)
    80002376:	69a2                	ld	s3,8(sp)
    80002378:	6a02                	ld	s4,0(sp)
    8000237a:	6145                	addi	sp,sp,48
    8000237c:	8082                	ret

000000008000237e <exit>:
{
    8000237e:	7179                	addi	sp,sp,-48
    80002380:	f406                	sd	ra,40(sp)
    80002382:	f022                	sd	s0,32(sp)
    80002384:	ec26                	sd	s1,24(sp)
    80002386:	e84a                	sd	s2,16(sp)
    80002388:	e44e                	sd	s3,8(sp)
    8000238a:	e052                	sd	s4,0(sp)
    8000238c:	1800                	addi	s0,sp,48
    8000238e:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002390:	fffff097          	auipc	ra,0xfffff
    80002394:	636080e7          	jalr	1590(ra) # 800019c6 <myproc>
    80002398:	89aa                	mv	s3,a0
  if(p == initproc)
    8000239a:	00006797          	auipc	a5,0x6
    8000239e:	76e7b783          	ld	a5,1902(a5) # 80008b08 <initproc>
    800023a2:	0d050493          	addi	s1,a0,208
    800023a6:	15050913          	addi	s2,a0,336
    800023aa:	02a79363          	bne	a5,a0,800023d0 <exit+0x52>
    panic("init exiting");
    800023ae:	00006517          	auipc	a0,0x6
    800023b2:	eb250513          	addi	a0,a0,-334 # 80008260 <digits+0x220>
    800023b6:	ffffe097          	auipc	ra,0xffffe
    800023ba:	18e080e7          	jalr	398(ra) # 80000544 <panic>
      fileclose(f);
    800023be:	00002097          	auipc	ra,0x2
    800023c2:	584080e7          	jalr	1412(ra) # 80004942 <fileclose>
      p->ofile[fd] = 0;
    800023c6:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800023ca:	04a1                	addi	s1,s1,8
    800023cc:	01248563          	beq	s1,s2,800023d6 <exit+0x58>
    if(p->ofile[fd]){
    800023d0:	6088                	ld	a0,0(s1)
    800023d2:	f575                	bnez	a0,800023be <exit+0x40>
    800023d4:	bfdd                	j	800023ca <exit+0x4c>
  begin_op();
    800023d6:	00002097          	auipc	ra,0x2
    800023da:	0a0080e7          	jalr	160(ra) # 80004476 <begin_op>
  iput(p->cwd);
    800023de:	1509b503          	ld	a0,336(s3)
    800023e2:	00002097          	auipc	ra,0x2
    800023e6:	88c080e7          	jalr	-1908(ra) # 80003c6e <iput>
  end_op();
    800023ea:	00002097          	auipc	ra,0x2
    800023ee:	10c080e7          	jalr	268(ra) # 800044f6 <end_op>
  p->cwd = 0;
    800023f2:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800023f6:	0000f497          	auipc	s1,0xf
    800023fa:	9a248493          	addi	s1,s1,-1630 # 80010d98 <wait_lock>
    800023fe:	8526                	mv	a0,s1
    80002400:	ffffe097          	auipc	ra,0xffffe
    80002404:	7ea080e7          	jalr	2026(ra) # 80000bea <acquire>
  reparent(p);
    80002408:	854e                	mv	a0,s3
    8000240a:	00000097          	auipc	ra,0x0
    8000240e:	f1a080e7          	jalr	-230(ra) # 80002324 <reparent>
  wakeup(p->parent);
    80002412:	0389b503          	ld	a0,56(s3)
    80002416:	00000097          	auipc	ra,0x0
    8000241a:	e98080e7          	jalr	-360(ra) # 800022ae <wakeup>
  acquire(&p->lock);
    8000241e:	854e                	mv	a0,s3
    80002420:	ffffe097          	auipc	ra,0xffffe
    80002424:	7ca080e7          	jalr	1994(ra) # 80000bea <acquire>
  p->xstate = status;
    80002428:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000242c:	4795                	li	a5,5
    8000242e:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    80002432:	00006797          	auipc	a5,0x6
    80002436:	6de7a783          	lw	a5,1758(a5) # 80008b10 <ticks>
    8000243a:	16f9aa23          	sw	a5,372(s3)
  release(&wait_lock);
    8000243e:	8526                	mv	a0,s1
    80002440:	fffff097          	auipc	ra,0xfffff
    80002444:	85e080e7          	jalr	-1954(ra) # 80000c9e <release>
  sched();
    80002448:	00000097          	auipc	ra,0x0
    8000244c:	ba4080e7          	jalr	-1116(ra) # 80001fec <sched>
  panic("zombie exit");
    80002450:	00006517          	auipc	a0,0x6
    80002454:	e2050513          	addi	a0,a0,-480 # 80008270 <digits+0x230>
    80002458:	ffffe097          	auipc	ra,0xffffe
    8000245c:	0ec080e7          	jalr	236(ra) # 80000544 <panic>

0000000080002460 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002460:	7179                	addi	sp,sp,-48
    80002462:	f406                	sd	ra,40(sp)
    80002464:	f022                	sd	s0,32(sp)
    80002466:	ec26                	sd	s1,24(sp)
    80002468:	e84a                	sd	s2,16(sp)
    8000246a:	e44e                	sd	s3,8(sp)
    8000246c:	1800                	addi	s0,sp,48
    8000246e:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002470:	0000f497          	auipc	s1,0xf
    80002474:	d4048493          	addi	s1,s1,-704 # 800111b0 <proc>
    80002478:	00016997          	auipc	s3,0x16
    8000247c:	b3898993          	addi	s3,s3,-1224 # 80017fb0 <tickslock>
    acquire(&p->lock);
    80002480:	8526                	mv	a0,s1
    80002482:	ffffe097          	auipc	ra,0xffffe
    80002486:	768080e7          	jalr	1896(ra) # 80000bea <acquire>
    if(p->pid == pid){
    8000248a:	589c                	lw	a5,48(s1)
    8000248c:	01278d63          	beq	a5,s2,800024a6 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002490:	8526                	mv	a0,s1
    80002492:	fffff097          	auipc	ra,0xfffff
    80002496:	80c080e7          	jalr	-2036(ra) # 80000c9e <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000249a:	1b848493          	addi	s1,s1,440
    8000249e:	ff3491e3          	bne	s1,s3,80002480 <kill+0x20>
  }
  return -1;
    800024a2:	557d                	li	a0,-1
    800024a4:	a829                	j	800024be <kill+0x5e>
      p->killed = 1;
    800024a6:	4785                	li	a5,1
    800024a8:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800024aa:	4c98                	lw	a4,24(s1)
    800024ac:	4789                	li	a5,2
    800024ae:	00f70f63          	beq	a4,a5,800024cc <kill+0x6c>
      release(&p->lock);
    800024b2:	8526                	mv	a0,s1
    800024b4:	ffffe097          	auipc	ra,0xffffe
    800024b8:	7ea080e7          	jalr	2026(ra) # 80000c9e <release>
      return 0;
    800024bc:	4501                	li	a0,0
}
    800024be:	70a2                	ld	ra,40(sp)
    800024c0:	7402                	ld	s0,32(sp)
    800024c2:	64e2                	ld	s1,24(sp)
    800024c4:	6942                	ld	s2,16(sp)
    800024c6:	69a2                	ld	s3,8(sp)
    800024c8:	6145                	addi	sp,sp,48
    800024ca:	8082                	ret
        p->state = RUNNABLE;
    800024cc:	478d                	li	a5,3
    800024ce:	cc9c                	sw	a5,24(s1)
    800024d0:	b7cd                	j	800024b2 <kill+0x52>

00000000800024d2 <setkilled>:

void
setkilled(struct proc *p)
{
    800024d2:	1101                	addi	sp,sp,-32
    800024d4:	ec06                	sd	ra,24(sp)
    800024d6:	e822                	sd	s0,16(sp)
    800024d8:	e426                	sd	s1,8(sp)
    800024da:	1000                	addi	s0,sp,32
    800024dc:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800024de:	ffffe097          	auipc	ra,0xffffe
    800024e2:	70c080e7          	jalr	1804(ra) # 80000bea <acquire>
  p->killed = 1;
    800024e6:	4785                	li	a5,1
    800024e8:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800024ea:	8526                	mv	a0,s1
    800024ec:	ffffe097          	auipc	ra,0xffffe
    800024f0:	7b2080e7          	jalr	1970(ra) # 80000c9e <release>
}
    800024f4:	60e2                	ld	ra,24(sp)
    800024f6:	6442                	ld	s0,16(sp)
    800024f8:	64a2                	ld	s1,8(sp)
    800024fa:	6105                	addi	sp,sp,32
    800024fc:	8082                	ret

00000000800024fe <killed>:

int
killed(struct proc *p)
{
    800024fe:	1101                	addi	sp,sp,-32
    80002500:	ec06                	sd	ra,24(sp)
    80002502:	e822                	sd	s0,16(sp)
    80002504:	e426                	sd	s1,8(sp)
    80002506:	e04a                	sd	s2,0(sp)
    80002508:	1000                	addi	s0,sp,32
    8000250a:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000250c:	ffffe097          	auipc	ra,0xffffe
    80002510:	6de080e7          	jalr	1758(ra) # 80000bea <acquire>
  k = p->killed;
    80002514:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002518:	8526                	mv	a0,s1
    8000251a:	ffffe097          	auipc	ra,0xffffe
    8000251e:	784080e7          	jalr	1924(ra) # 80000c9e <release>
  return k;
}
    80002522:	854a                	mv	a0,s2
    80002524:	60e2                	ld	ra,24(sp)
    80002526:	6442                	ld	s0,16(sp)
    80002528:	64a2                	ld	s1,8(sp)
    8000252a:	6902                	ld	s2,0(sp)
    8000252c:	6105                	addi	sp,sp,32
    8000252e:	8082                	ret

0000000080002530 <wait>:
{
    80002530:	715d                	addi	sp,sp,-80
    80002532:	e486                	sd	ra,72(sp)
    80002534:	e0a2                	sd	s0,64(sp)
    80002536:	fc26                	sd	s1,56(sp)
    80002538:	f84a                	sd	s2,48(sp)
    8000253a:	f44e                	sd	s3,40(sp)
    8000253c:	f052                	sd	s4,32(sp)
    8000253e:	ec56                	sd	s5,24(sp)
    80002540:	e85a                	sd	s6,16(sp)
    80002542:	e45e                	sd	s7,8(sp)
    80002544:	e062                	sd	s8,0(sp)
    80002546:	0880                	addi	s0,sp,80
    80002548:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000254a:	fffff097          	auipc	ra,0xfffff
    8000254e:	47c080e7          	jalr	1148(ra) # 800019c6 <myproc>
    80002552:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002554:	0000f517          	auipc	a0,0xf
    80002558:	84450513          	addi	a0,a0,-1980 # 80010d98 <wait_lock>
    8000255c:	ffffe097          	auipc	ra,0xffffe
    80002560:	68e080e7          	jalr	1678(ra) # 80000bea <acquire>
    havekids = 0;
    80002564:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002566:	4a15                	li	s4,5
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002568:	00016997          	auipc	s3,0x16
    8000256c:	a4898993          	addi	s3,s3,-1464 # 80017fb0 <tickslock>
        havekids = 1;
    80002570:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002572:	0000fc17          	auipc	s8,0xf
    80002576:	826c0c13          	addi	s8,s8,-2010 # 80010d98 <wait_lock>
    havekids = 0;
    8000257a:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000257c:	0000f497          	auipc	s1,0xf
    80002580:	c3448493          	addi	s1,s1,-972 # 800111b0 <proc>
    80002584:	a0bd                	j	800025f2 <wait+0xc2>
          pid = pp->pid;
    80002586:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000258a:	000b0e63          	beqz	s6,800025a6 <wait+0x76>
    8000258e:	4691                	li	a3,4
    80002590:	02c48613          	addi	a2,s1,44
    80002594:	85da                	mv	a1,s6
    80002596:	05093503          	ld	a0,80(s2)
    8000259a:	fffff097          	auipc	ra,0xfffff
    8000259e:	0ea080e7          	jalr	234(ra) # 80001684 <copyout>
    800025a2:	02054563          	bltz	a0,800025cc <wait+0x9c>
          freeproc(pp);
    800025a6:	8526                	mv	a0,s1
    800025a8:	fffff097          	auipc	ra,0xfffff
    800025ac:	5d0080e7          	jalr	1488(ra) # 80001b78 <freeproc>
          release(&pp->lock);
    800025b0:	8526                	mv	a0,s1
    800025b2:	ffffe097          	auipc	ra,0xffffe
    800025b6:	6ec080e7          	jalr	1772(ra) # 80000c9e <release>
          release(&wait_lock);
    800025ba:	0000e517          	auipc	a0,0xe
    800025be:	7de50513          	addi	a0,a0,2014 # 80010d98 <wait_lock>
    800025c2:	ffffe097          	auipc	ra,0xffffe
    800025c6:	6dc080e7          	jalr	1756(ra) # 80000c9e <release>
          return pid;
    800025ca:	a0b5                	j	80002636 <wait+0x106>
            release(&pp->lock);
    800025cc:	8526                	mv	a0,s1
    800025ce:	ffffe097          	auipc	ra,0xffffe
    800025d2:	6d0080e7          	jalr	1744(ra) # 80000c9e <release>
            release(&wait_lock);
    800025d6:	0000e517          	auipc	a0,0xe
    800025da:	7c250513          	addi	a0,a0,1986 # 80010d98 <wait_lock>
    800025de:	ffffe097          	auipc	ra,0xffffe
    800025e2:	6c0080e7          	jalr	1728(ra) # 80000c9e <release>
            return -1;
    800025e6:	59fd                	li	s3,-1
    800025e8:	a0b9                	j	80002636 <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800025ea:	1b848493          	addi	s1,s1,440
    800025ee:	03348463          	beq	s1,s3,80002616 <wait+0xe6>
      if(pp->parent == p){
    800025f2:	7c9c                	ld	a5,56(s1)
    800025f4:	ff279be3          	bne	a5,s2,800025ea <wait+0xba>
        acquire(&pp->lock);
    800025f8:	8526                	mv	a0,s1
    800025fa:	ffffe097          	auipc	ra,0xffffe
    800025fe:	5f0080e7          	jalr	1520(ra) # 80000bea <acquire>
        if(pp->state == ZOMBIE){
    80002602:	4c9c                	lw	a5,24(s1)
    80002604:	f94781e3          	beq	a5,s4,80002586 <wait+0x56>
        release(&pp->lock);
    80002608:	8526                	mv	a0,s1
    8000260a:	ffffe097          	auipc	ra,0xffffe
    8000260e:	694080e7          	jalr	1684(ra) # 80000c9e <release>
        havekids = 1;
    80002612:	8756                	mv	a4,s5
    80002614:	bfd9                	j	800025ea <wait+0xba>
    if(!havekids || killed(p)){
    80002616:	c719                	beqz	a4,80002624 <wait+0xf4>
    80002618:	854a                	mv	a0,s2
    8000261a:	00000097          	auipc	ra,0x0
    8000261e:	ee4080e7          	jalr	-284(ra) # 800024fe <killed>
    80002622:	c51d                	beqz	a0,80002650 <wait+0x120>
      release(&wait_lock);
    80002624:	0000e517          	auipc	a0,0xe
    80002628:	77450513          	addi	a0,a0,1908 # 80010d98 <wait_lock>
    8000262c:	ffffe097          	auipc	ra,0xffffe
    80002630:	672080e7          	jalr	1650(ra) # 80000c9e <release>
      return -1;
    80002634:	59fd                	li	s3,-1
}
    80002636:	854e                	mv	a0,s3
    80002638:	60a6                	ld	ra,72(sp)
    8000263a:	6406                	ld	s0,64(sp)
    8000263c:	74e2                	ld	s1,56(sp)
    8000263e:	7942                	ld	s2,48(sp)
    80002640:	79a2                	ld	s3,40(sp)
    80002642:	7a02                	ld	s4,32(sp)
    80002644:	6ae2                	ld	s5,24(sp)
    80002646:	6b42                	ld	s6,16(sp)
    80002648:	6ba2                	ld	s7,8(sp)
    8000264a:	6c02                	ld	s8,0(sp)
    8000264c:	6161                	addi	sp,sp,80
    8000264e:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002650:	85e2                	mv	a1,s8
    80002652:	854a                	mv	a0,s2
    80002654:	00000097          	auipc	ra,0x0
    80002658:	aaa080e7          	jalr	-1366(ra) # 800020fe <sleep>
    havekids = 0;
    8000265c:	bf39                	j	8000257a <wait+0x4a>

000000008000265e <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000265e:	7179                	addi	sp,sp,-48
    80002660:	f406                	sd	ra,40(sp)
    80002662:	f022                	sd	s0,32(sp)
    80002664:	ec26                	sd	s1,24(sp)
    80002666:	e84a                	sd	s2,16(sp)
    80002668:	e44e                	sd	s3,8(sp)
    8000266a:	e052                	sd	s4,0(sp)
    8000266c:	1800                	addi	s0,sp,48
    8000266e:	84aa                	mv	s1,a0
    80002670:	892e                	mv	s2,a1
    80002672:	89b2                	mv	s3,a2
    80002674:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002676:	fffff097          	auipc	ra,0xfffff
    8000267a:	350080e7          	jalr	848(ra) # 800019c6 <myproc>
  if(user_dst){
    8000267e:	c08d                	beqz	s1,800026a0 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002680:	86d2                	mv	a3,s4
    80002682:	864e                	mv	a2,s3
    80002684:	85ca                	mv	a1,s2
    80002686:	6928                	ld	a0,80(a0)
    80002688:	fffff097          	auipc	ra,0xfffff
    8000268c:	ffc080e7          	jalr	-4(ra) # 80001684 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002690:	70a2                	ld	ra,40(sp)
    80002692:	7402                	ld	s0,32(sp)
    80002694:	64e2                	ld	s1,24(sp)
    80002696:	6942                	ld	s2,16(sp)
    80002698:	69a2                	ld	s3,8(sp)
    8000269a:	6a02                	ld	s4,0(sp)
    8000269c:	6145                	addi	sp,sp,48
    8000269e:	8082                	ret
    memmove((char *)dst, src, len);
    800026a0:	000a061b          	sext.w	a2,s4
    800026a4:	85ce                	mv	a1,s3
    800026a6:	854a                	mv	a0,s2
    800026a8:	ffffe097          	auipc	ra,0xffffe
    800026ac:	69e080e7          	jalr	1694(ra) # 80000d46 <memmove>
    return 0;
    800026b0:	8526                	mv	a0,s1
    800026b2:	bff9                	j	80002690 <either_copyout+0x32>

00000000800026b4 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800026b4:	7179                	addi	sp,sp,-48
    800026b6:	f406                	sd	ra,40(sp)
    800026b8:	f022                	sd	s0,32(sp)
    800026ba:	ec26                	sd	s1,24(sp)
    800026bc:	e84a                	sd	s2,16(sp)
    800026be:	e44e                	sd	s3,8(sp)
    800026c0:	e052                	sd	s4,0(sp)
    800026c2:	1800                	addi	s0,sp,48
    800026c4:	892a                	mv	s2,a0
    800026c6:	84ae                	mv	s1,a1
    800026c8:	89b2                	mv	s3,a2
    800026ca:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800026cc:	fffff097          	auipc	ra,0xfffff
    800026d0:	2fa080e7          	jalr	762(ra) # 800019c6 <myproc>
  if(user_src){
    800026d4:	c08d                	beqz	s1,800026f6 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800026d6:	86d2                	mv	a3,s4
    800026d8:	864e                	mv	a2,s3
    800026da:	85ca                	mv	a1,s2
    800026dc:	6928                	ld	a0,80(a0)
    800026de:	fffff097          	auipc	ra,0xfffff
    800026e2:	032080e7          	jalr	50(ra) # 80001710 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800026e6:	70a2                	ld	ra,40(sp)
    800026e8:	7402                	ld	s0,32(sp)
    800026ea:	64e2                	ld	s1,24(sp)
    800026ec:	6942                	ld	s2,16(sp)
    800026ee:	69a2                	ld	s3,8(sp)
    800026f0:	6a02                	ld	s4,0(sp)
    800026f2:	6145                	addi	sp,sp,48
    800026f4:	8082                	ret
    memmove(dst, (char*)src, len);
    800026f6:	000a061b          	sext.w	a2,s4
    800026fa:	85ce                	mv	a1,s3
    800026fc:	854a                	mv	a0,s2
    800026fe:	ffffe097          	auipc	ra,0xffffe
    80002702:	648080e7          	jalr	1608(ra) # 80000d46 <memmove>
    return 0;
    80002706:	8526                	mv	a0,s1
    80002708:	bff9                	j	800026e6 <either_copyin+0x32>

000000008000270a <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000270a:	715d                	addi	sp,sp,-80
    8000270c:	e486                	sd	ra,72(sp)
    8000270e:	e0a2                	sd	s0,64(sp)
    80002710:	fc26                	sd	s1,56(sp)
    80002712:	f84a                	sd	s2,48(sp)
    80002714:	f44e                	sd	s3,40(sp)
    80002716:	f052                	sd	s4,32(sp)
    80002718:	ec56                	sd	s5,24(sp)
    8000271a:	e85a                	sd	s6,16(sp)
    8000271c:	e45e                	sd	s7,8(sp)
    8000271e:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002720:	00006517          	auipc	a0,0x6
    80002724:	9a850513          	addi	a0,a0,-1624 # 800080c8 <digits+0x88>
    80002728:	ffffe097          	auipc	ra,0xffffe
    8000272c:	e66080e7          	jalr	-410(ra) # 8000058e <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002730:	0000f497          	auipc	s1,0xf
    80002734:	bd848493          	addi	s1,s1,-1064 # 80011308 <proc+0x158>
    80002738:	00016917          	auipc	s2,0x16
    8000273c:	9d090913          	addi	s2,s2,-1584 # 80018108 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002740:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002742:	00006997          	auipc	s3,0x6
    80002746:	b3e98993          	addi	s3,s3,-1218 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    8000274a:	00006a97          	auipc	s5,0x6
    8000274e:	b3ea8a93          	addi	s5,s5,-1218 # 80008288 <digits+0x248>
    printf("\n");
    80002752:	00006a17          	auipc	s4,0x6
    80002756:	976a0a13          	addi	s4,s4,-1674 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000275a:	00006b97          	auipc	s7,0x6
    8000275e:	b6eb8b93          	addi	s7,s7,-1170 # 800082c8 <states.1760>
    80002762:	a00d                	j	80002784 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002764:	ed86a583          	lw	a1,-296(a3)
    80002768:	8556                	mv	a0,s5
    8000276a:	ffffe097          	auipc	ra,0xffffe
    8000276e:	e24080e7          	jalr	-476(ra) # 8000058e <printf>
    printf("\n");
    80002772:	8552                	mv	a0,s4
    80002774:	ffffe097          	auipc	ra,0xffffe
    80002778:	e1a080e7          	jalr	-486(ra) # 8000058e <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000277c:	1b848493          	addi	s1,s1,440
    80002780:	03248163          	beq	s1,s2,800027a2 <procdump+0x98>
    if(p->state == UNUSED)
    80002784:	86a6                	mv	a3,s1
    80002786:	ec04a783          	lw	a5,-320(s1)
    8000278a:	dbed                	beqz	a5,8000277c <procdump+0x72>
      state = "???";
    8000278c:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000278e:	fcfb6be3          	bltu	s6,a5,80002764 <procdump+0x5a>
    80002792:	1782                	slli	a5,a5,0x20
    80002794:	9381                	srli	a5,a5,0x20
    80002796:	078e                	slli	a5,a5,0x3
    80002798:	97de                	add	a5,a5,s7
    8000279a:	6390                	ld	a2,0(a5)
    8000279c:	f661                	bnez	a2,80002764 <procdump+0x5a>
      state = "???";
    8000279e:	864e                	mv	a2,s3
    800027a0:	b7d1                	j	80002764 <procdump+0x5a>
  }
}
    800027a2:	60a6                	ld	ra,72(sp)
    800027a4:	6406                	ld	s0,64(sp)
    800027a6:	74e2                	ld	s1,56(sp)
    800027a8:	7942                	ld	s2,48(sp)
    800027aa:	79a2                	ld	s3,40(sp)
    800027ac:	7a02                	ld	s4,32(sp)
    800027ae:	6ae2                	ld	s5,24(sp)
    800027b0:	6b42                	ld	s6,16(sp)
    800027b2:	6ba2                	ld	s7,8(sp)
    800027b4:	6161                	addi	sp,sp,80
    800027b6:	8082                	ret

00000000800027b8 <swtch>:
    800027b8:	00153023          	sd	ra,0(a0)
    800027bc:	00253423          	sd	sp,8(a0)
    800027c0:	e900                	sd	s0,16(a0)
    800027c2:	ed04                	sd	s1,24(a0)
    800027c4:	03253023          	sd	s2,32(a0)
    800027c8:	03353423          	sd	s3,40(a0)
    800027cc:	03453823          	sd	s4,48(a0)
    800027d0:	03553c23          	sd	s5,56(a0)
    800027d4:	05653023          	sd	s6,64(a0)
    800027d8:	05753423          	sd	s7,72(a0)
    800027dc:	05853823          	sd	s8,80(a0)
    800027e0:	05953c23          	sd	s9,88(a0)
    800027e4:	07a53023          	sd	s10,96(a0)
    800027e8:	07b53423          	sd	s11,104(a0)
    800027ec:	0005b083          	ld	ra,0(a1)
    800027f0:	0085b103          	ld	sp,8(a1)
    800027f4:	6980                	ld	s0,16(a1)
    800027f6:	6d84                	ld	s1,24(a1)
    800027f8:	0205b903          	ld	s2,32(a1)
    800027fc:	0285b983          	ld	s3,40(a1)
    80002800:	0305ba03          	ld	s4,48(a1)
    80002804:	0385ba83          	ld	s5,56(a1)
    80002808:	0405bb03          	ld	s6,64(a1)
    8000280c:	0485bb83          	ld	s7,72(a1)
    80002810:	0505bc03          	ld	s8,80(a1)
    80002814:	0585bc83          	ld	s9,88(a1)
    80002818:	0605bd03          	ld	s10,96(a1)
    8000281c:	0685bd83          	ld	s11,104(a1)
    80002820:	8082                	ret

0000000080002822 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002822:	1141                	addi	sp,sp,-16
    80002824:	e406                	sd	ra,8(sp)
    80002826:	e022                	sd	s0,0(sp)
    80002828:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000282a:	00006597          	auipc	a1,0x6
    8000282e:	ace58593          	addi	a1,a1,-1330 # 800082f8 <states.1760+0x30>
    80002832:	00015517          	auipc	a0,0x15
    80002836:	77e50513          	addi	a0,a0,1918 # 80017fb0 <tickslock>
    8000283a:	ffffe097          	auipc	ra,0xffffe
    8000283e:	320080e7          	jalr	800(ra) # 80000b5a <initlock>
}
    80002842:	60a2                	ld	ra,8(sp)
    80002844:	6402                	ld	s0,0(sp)
    80002846:	0141                	addi	sp,sp,16
    80002848:	8082                	ret

000000008000284a <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000284a:	1141                	addi	sp,sp,-16
    8000284c:	e422                	sd	s0,8(sp)
    8000284e:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002850:	00003797          	auipc	a5,0x3
    80002854:	73078793          	addi	a5,a5,1840 # 80005f80 <kernelvec>
    80002858:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000285c:	6422                	ld	s0,8(sp)
    8000285e:	0141                	addi	sp,sp,16
    80002860:	8082                	ret

0000000080002862 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002862:	1141                	addi	sp,sp,-16
    80002864:	e406                	sd	ra,8(sp)
    80002866:	e022                	sd	s0,0(sp)
    80002868:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000286a:	fffff097          	auipc	ra,0xfffff
    8000286e:	15c080e7          	jalr	348(ra) # 800019c6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002872:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002876:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002878:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000287c:	00004617          	auipc	a2,0x4
    80002880:	78460613          	addi	a2,a2,1924 # 80007000 <_trampoline>
    80002884:	00004697          	auipc	a3,0x4
    80002888:	77c68693          	addi	a3,a3,1916 # 80007000 <_trampoline>
    8000288c:	8e91                	sub	a3,a3,a2
    8000288e:	040007b7          	lui	a5,0x4000
    80002892:	17fd                	addi	a5,a5,-1
    80002894:	07b2                	slli	a5,a5,0xc
    80002896:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002898:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000289c:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000289e:	180026f3          	csrr	a3,satp
    800028a2:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800028a4:	6d38                	ld	a4,88(a0)
    800028a6:	6134                	ld	a3,64(a0)
    800028a8:	6585                	lui	a1,0x1
    800028aa:	96ae                	add	a3,a3,a1
    800028ac:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800028ae:	6d38                	ld	a4,88(a0)
    800028b0:	00000697          	auipc	a3,0x0
    800028b4:	13e68693          	addi	a3,a3,318 # 800029ee <usertrap>
    800028b8:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800028ba:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800028bc:	8692                	mv	a3,tp
    800028be:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028c0:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800028c4:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800028c8:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028cc:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800028d0:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800028d2:	6f18                	ld	a4,24(a4)
    800028d4:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800028d8:	6928                	ld	a0,80(a0)
    800028da:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800028dc:	00004717          	auipc	a4,0x4
    800028e0:	7c070713          	addi	a4,a4,1984 # 8000709c <userret>
    800028e4:	8f11                	sub	a4,a4,a2
    800028e6:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800028e8:	577d                	li	a4,-1
    800028ea:	177e                	slli	a4,a4,0x3f
    800028ec:	8d59                	or	a0,a0,a4
    800028ee:	9782                	jalr	a5
}
    800028f0:	60a2                	ld	ra,8(sp)
    800028f2:	6402                	ld	s0,0(sp)
    800028f4:	0141                	addi	sp,sp,16
    800028f6:	8082                	ret

00000000800028f8 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800028f8:	1101                	addi	sp,sp,-32
    800028fa:	ec06                	sd	ra,24(sp)
    800028fc:	e822                	sd	s0,16(sp)
    800028fe:	e426                	sd	s1,8(sp)
    80002900:	e04a                	sd	s2,0(sp)
    80002902:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002904:	00015917          	auipc	s2,0x15
    80002908:	6ac90913          	addi	s2,s2,1708 # 80017fb0 <tickslock>
    8000290c:	854a                	mv	a0,s2
    8000290e:	ffffe097          	auipc	ra,0xffffe
    80002912:	2dc080e7          	jalr	732(ra) # 80000bea <acquire>
  ticks++;
    80002916:	00006497          	auipc	s1,0x6
    8000291a:	1fa48493          	addi	s1,s1,506 # 80008b10 <ticks>
    8000291e:	409c                	lw	a5,0(s1)
    80002920:	2785                	addiw	a5,a5,1
    80002922:	c09c                	sw	a5,0(s1)
  update_time();
    80002924:	fffff097          	auipc	ra,0xfffff
    80002928:	5ca080e7          	jalr	1482(ra) # 80001eee <update_time>
  wakeup(&ticks);
    8000292c:	8526                	mv	a0,s1
    8000292e:	00000097          	auipc	ra,0x0
    80002932:	980080e7          	jalr	-1664(ra) # 800022ae <wakeup>
  release(&tickslock);
    80002936:	854a                	mv	a0,s2
    80002938:	ffffe097          	auipc	ra,0xffffe
    8000293c:	366080e7          	jalr	870(ra) # 80000c9e <release>
}
    80002940:	60e2                	ld	ra,24(sp)
    80002942:	6442                	ld	s0,16(sp)
    80002944:	64a2                	ld	s1,8(sp)
    80002946:	6902                	ld	s2,0(sp)
    80002948:	6105                	addi	sp,sp,32
    8000294a:	8082                	ret

000000008000294c <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000294c:	1101                	addi	sp,sp,-32
    8000294e:	ec06                	sd	ra,24(sp)
    80002950:	e822                	sd	s0,16(sp)
    80002952:	e426                	sd	s1,8(sp)
    80002954:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002956:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    8000295a:	00074d63          	bltz	a4,80002974 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    8000295e:	57fd                	li	a5,-1
    80002960:	17fe                	slli	a5,a5,0x3f
    80002962:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002964:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002966:	06f70363          	beq	a4,a5,800029cc <devintr+0x80>
  }
}
    8000296a:	60e2                	ld	ra,24(sp)
    8000296c:	6442                	ld	s0,16(sp)
    8000296e:	64a2                	ld	s1,8(sp)
    80002970:	6105                	addi	sp,sp,32
    80002972:	8082                	ret
     (scause & 0xff) == 9){
    80002974:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002978:	46a5                	li	a3,9
    8000297a:	fed792e3          	bne	a5,a3,8000295e <devintr+0x12>
    int irq = plic_claim();
    8000297e:	00003097          	auipc	ra,0x3
    80002982:	70a080e7          	jalr	1802(ra) # 80006088 <plic_claim>
    80002986:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002988:	47a9                	li	a5,10
    8000298a:	02f50763          	beq	a0,a5,800029b8 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    8000298e:	4785                	li	a5,1
    80002990:	02f50963          	beq	a0,a5,800029c2 <devintr+0x76>
    return 1;
    80002994:	4505                	li	a0,1
    } else if(irq){
    80002996:	d8f1                	beqz	s1,8000296a <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002998:	85a6                	mv	a1,s1
    8000299a:	00006517          	auipc	a0,0x6
    8000299e:	96650513          	addi	a0,a0,-1690 # 80008300 <states.1760+0x38>
    800029a2:	ffffe097          	auipc	ra,0xffffe
    800029a6:	bec080e7          	jalr	-1044(ra) # 8000058e <printf>
      plic_complete(irq);
    800029aa:	8526                	mv	a0,s1
    800029ac:	00003097          	auipc	ra,0x3
    800029b0:	700080e7          	jalr	1792(ra) # 800060ac <plic_complete>
    return 1;
    800029b4:	4505                	li	a0,1
    800029b6:	bf55                	j	8000296a <devintr+0x1e>
      uartintr();
    800029b8:	ffffe097          	auipc	ra,0xffffe
    800029bc:	ff6080e7          	jalr	-10(ra) # 800009ae <uartintr>
    800029c0:	b7ed                	j	800029aa <devintr+0x5e>
      virtio_disk_intr();
    800029c2:	00004097          	auipc	ra,0x4
    800029c6:	c14080e7          	jalr	-1004(ra) # 800065d6 <virtio_disk_intr>
    800029ca:	b7c5                	j	800029aa <devintr+0x5e>
    if(cpuid() == 0){
    800029cc:	fffff097          	auipc	ra,0xfffff
    800029d0:	fce080e7          	jalr	-50(ra) # 8000199a <cpuid>
    800029d4:	c901                	beqz	a0,800029e4 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800029d6:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800029da:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800029dc:	14479073          	csrw	sip,a5
    return 2;
    800029e0:	4509                	li	a0,2
    800029e2:	b761                	j	8000296a <devintr+0x1e>
      clockintr();
    800029e4:	00000097          	auipc	ra,0x0
    800029e8:	f14080e7          	jalr	-236(ra) # 800028f8 <clockintr>
    800029ec:	b7ed                	j	800029d6 <devintr+0x8a>

00000000800029ee <usertrap>:
{
    800029ee:	1101                	addi	sp,sp,-32
    800029f0:	ec06                	sd	ra,24(sp)
    800029f2:	e822                	sd	s0,16(sp)
    800029f4:	e426                	sd	s1,8(sp)
    800029f6:	e04a                	sd	s2,0(sp)
    800029f8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029fa:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800029fe:	1007f793          	andi	a5,a5,256
    80002a02:	e3b1                	bnez	a5,80002a46 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a04:	00003797          	auipc	a5,0x3
    80002a08:	57c78793          	addi	a5,a5,1404 # 80005f80 <kernelvec>
    80002a0c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002a10:	fffff097          	auipc	ra,0xfffff
    80002a14:	fb6080e7          	jalr	-74(ra) # 800019c6 <myproc>
    80002a18:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002a1a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a1c:	14102773          	csrr	a4,sepc
    80002a20:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a22:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002a26:	47a1                	li	a5,8
    80002a28:	02f70763          	beq	a4,a5,80002a56 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002a2c:	00000097          	auipc	ra,0x0
    80002a30:	f20080e7          	jalr	-224(ra) # 8000294c <devintr>
    80002a34:	892a                	mv	s2,a0
    80002a36:	c92d                	beqz	a0,80002aa8 <usertrap+0xba>
  if(killed(p))
    80002a38:	8526                	mv	a0,s1
    80002a3a:	00000097          	auipc	ra,0x0
    80002a3e:	ac4080e7          	jalr	-1340(ra) # 800024fe <killed>
    80002a42:	c555                	beqz	a0,80002aee <usertrap+0x100>
    80002a44:	a045                	j	80002ae4 <usertrap+0xf6>
    panic("usertrap: not from user mode");
    80002a46:	00006517          	auipc	a0,0x6
    80002a4a:	8da50513          	addi	a0,a0,-1830 # 80008320 <states.1760+0x58>
    80002a4e:	ffffe097          	auipc	ra,0xffffe
    80002a52:	af6080e7          	jalr	-1290(ra) # 80000544 <panic>
    if(killed(p))
    80002a56:	00000097          	auipc	ra,0x0
    80002a5a:	aa8080e7          	jalr	-1368(ra) # 800024fe <killed>
    80002a5e:	ed1d                	bnez	a0,80002a9c <usertrap+0xae>
    p->trapframe->epc += 4;
    80002a60:	6cb8                	ld	a4,88(s1)
    80002a62:	6f1c                	ld	a5,24(a4)
    80002a64:	0791                	addi	a5,a5,4
    80002a66:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a68:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002a6c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a70:	10079073          	csrw	sstatus,a5
    syscall();
    80002a74:	00000097          	auipc	ra,0x0
    80002a78:	328080e7          	jalr	808(ra) # 80002d9c <syscall>
  if(killed(p))
    80002a7c:	8526                	mv	a0,s1
    80002a7e:	00000097          	auipc	ra,0x0
    80002a82:	a80080e7          	jalr	-1408(ra) # 800024fe <killed>
    80002a86:	ed31                	bnez	a0,80002ae2 <usertrap+0xf4>
  usertrapret();
    80002a88:	00000097          	auipc	ra,0x0
    80002a8c:	dda080e7          	jalr	-550(ra) # 80002862 <usertrapret>
}
    80002a90:	60e2                	ld	ra,24(sp)
    80002a92:	6442                	ld	s0,16(sp)
    80002a94:	64a2                	ld	s1,8(sp)
    80002a96:	6902                	ld	s2,0(sp)
    80002a98:	6105                	addi	sp,sp,32
    80002a9a:	8082                	ret
      exit(-1);
    80002a9c:	557d                	li	a0,-1
    80002a9e:	00000097          	auipc	ra,0x0
    80002aa2:	8e0080e7          	jalr	-1824(ra) # 8000237e <exit>
    80002aa6:	bf6d                	j	80002a60 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002aa8:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002aac:	5890                	lw	a2,48(s1)
    80002aae:	00006517          	auipc	a0,0x6
    80002ab2:	89250513          	addi	a0,a0,-1902 # 80008340 <states.1760+0x78>
    80002ab6:	ffffe097          	auipc	ra,0xffffe
    80002aba:	ad8080e7          	jalr	-1320(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002abe:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ac2:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ac6:	00006517          	auipc	a0,0x6
    80002aca:	8aa50513          	addi	a0,a0,-1878 # 80008370 <states.1760+0xa8>
    80002ace:	ffffe097          	auipc	ra,0xffffe
    80002ad2:	ac0080e7          	jalr	-1344(ra) # 8000058e <printf>
    setkilled(p);
    80002ad6:	8526                	mv	a0,s1
    80002ad8:	00000097          	auipc	ra,0x0
    80002adc:	9fa080e7          	jalr	-1542(ra) # 800024d2 <setkilled>
    80002ae0:	bf71                	j	80002a7c <usertrap+0x8e>
  if(killed(p))
    80002ae2:	4901                	li	s2,0
    exit(-1);
    80002ae4:	557d                	li	a0,-1
    80002ae6:	00000097          	auipc	ra,0x0
    80002aea:	898080e7          	jalr	-1896(ra) # 8000237e <exit>
  if (which_dev == 2 && p->alarm_on == 1 && p->handlerpermission == 1) {
    80002aee:	4789                	li	a5,2
    80002af0:	f8f91ce3          	bne	s2,a5,80002a88 <usertrap+0x9a>
    80002af4:	1984a703          	lw	a4,408(s1)
    80002af8:	4785                	li	a5,1
    80002afa:	00f70763          	beq	a4,a5,80002b08 <usertrap+0x11a>
    yield();
    80002afe:	fffff097          	auipc	ra,0xfffff
    80002b02:	5c4080e7          	jalr	1476(ra) # 800020c2 <yield>
    80002b06:	b749                	j	80002a88 <usertrap+0x9a>
  if (which_dev == 2 && p->alarm_on == 1 && p->handlerpermission == 1) {
    80002b08:	1b04a703          	lw	a4,432(s1)
    80002b0c:	fef719e3          	bne	a4,a5,80002afe <usertrap+0x110>
      struct trapframe *tf = kalloc();
    80002b10:	ffffe097          	auipc	ra,0xffffe
    80002b14:	fea080e7          	jalr	-22(ra) # 80000afa <kalloc>
    80002b18:	892a                	mv	s2,a0
      memmove(tf, p->trapframe, PGSIZE);
    80002b1a:	6605                	lui	a2,0x1
    80002b1c:	6cac                	ld	a1,88(s1)
    80002b1e:	ffffe097          	auipc	ra,0xffffe
    80002b22:	228080e7          	jalr	552(ra) # 80000d46 <memmove>
      p->alarm_tf = tf;
    80002b26:	1924b823          	sd	s2,400(s1)
      p->cur_ticks++;
    80002b2a:	18c4a783          	lw	a5,396(s1)
    80002b2e:	2785                	addiw	a5,a5,1
    80002b30:	0007871b          	sext.w	a4,a5
    80002b34:	18f4a623          	sw	a5,396(s1)
      if (p->cur_ticks >= p->ticks){
    80002b38:	1884a783          	lw	a5,392(s1)
    80002b3c:	fcf741e3          	blt	a4,a5,80002afe <usertrap+0x110>
        p->trapframe->epc = p->handler;
    80002b40:	6cbc                	ld	a5,88(s1)
    80002b42:	1804b703          	ld	a4,384(s1)
    80002b46:	ef98                	sd	a4,24(a5)
        p->handlerpermission = 0;
    80002b48:	1a04a823          	sw	zero,432(s1)
    80002b4c:	bf4d                	j	80002afe <usertrap+0x110>

0000000080002b4e <kerneltrap>:
{
    80002b4e:	7179                	addi	sp,sp,-48
    80002b50:	f406                	sd	ra,40(sp)
    80002b52:	f022                	sd	s0,32(sp)
    80002b54:	ec26                	sd	s1,24(sp)
    80002b56:	e84a                	sd	s2,16(sp)
    80002b58:	e44e                	sd	s3,8(sp)
    80002b5a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b5c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b60:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b64:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002b68:	1004f793          	andi	a5,s1,256
    80002b6c:	cb85                	beqz	a5,80002b9c <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b6e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002b72:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002b74:	ef85                	bnez	a5,80002bac <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002b76:	00000097          	auipc	ra,0x0
    80002b7a:	dd6080e7          	jalr	-554(ra) # 8000294c <devintr>
    80002b7e:	cd1d                	beqz	a0,80002bbc <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002b80:	4789                	li	a5,2
    80002b82:	06f50a63          	beq	a0,a5,80002bf6 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b86:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b8a:	10049073          	csrw	sstatus,s1
}
    80002b8e:	70a2                	ld	ra,40(sp)
    80002b90:	7402                	ld	s0,32(sp)
    80002b92:	64e2                	ld	s1,24(sp)
    80002b94:	6942                	ld	s2,16(sp)
    80002b96:	69a2                	ld	s3,8(sp)
    80002b98:	6145                	addi	sp,sp,48
    80002b9a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002b9c:	00005517          	auipc	a0,0x5
    80002ba0:	7f450513          	addi	a0,a0,2036 # 80008390 <states.1760+0xc8>
    80002ba4:	ffffe097          	auipc	ra,0xffffe
    80002ba8:	9a0080e7          	jalr	-1632(ra) # 80000544 <panic>
    panic("kerneltrap: interrupts enabled");
    80002bac:	00006517          	auipc	a0,0x6
    80002bb0:	80c50513          	addi	a0,a0,-2036 # 800083b8 <states.1760+0xf0>
    80002bb4:	ffffe097          	auipc	ra,0xffffe
    80002bb8:	990080e7          	jalr	-1648(ra) # 80000544 <panic>
    printf("scause %p\n", scause);
    80002bbc:	85ce                	mv	a1,s3
    80002bbe:	00006517          	auipc	a0,0x6
    80002bc2:	81a50513          	addi	a0,a0,-2022 # 800083d8 <states.1760+0x110>
    80002bc6:	ffffe097          	auipc	ra,0xffffe
    80002bca:	9c8080e7          	jalr	-1592(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bce:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002bd2:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002bd6:	00006517          	auipc	a0,0x6
    80002bda:	81250513          	addi	a0,a0,-2030 # 800083e8 <states.1760+0x120>
    80002bde:	ffffe097          	auipc	ra,0xffffe
    80002be2:	9b0080e7          	jalr	-1616(ra) # 8000058e <printf>
    panic("kerneltrap");
    80002be6:	00006517          	auipc	a0,0x6
    80002bea:	81a50513          	addi	a0,a0,-2022 # 80008400 <states.1760+0x138>
    80002bee:	ffffe097          	auipc	ra,0xffffe
    80002bf2:	956080e7          	jalr	-1706(ra) # 80000544 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002bf6:	fffff097          	auipc	ra,0xfffff
    80002bfa:	dd0080e7          	jalr	-560(ra) # 800019c6 <myproc>
    80002bfe:	d541                	beqz	a0,80002b86 <kerneltrap+0x38>
    80002c00:	fffff097          	auipc	ra,0xfffff
    80002c04:	dc6080e7          	jalr	-570(ra) # 800019c6 <myproc>
    80002c08:	4d18                	lw	a4,24(a0)
    80002c0a:	4791                	li	a5,4
    80002c0c:	f6f71de3          	bne	a4,a5,80002b86 <kerneltrap+0x38>
    yield();
    80002c10:	fffff097          	auipc	ra,0xfffff
    80002c14:	4b2080e7          	jalr	1202(ra) # 800020c2 <yield>
    80002c18:	b7bd                	j	80002b86 <kerneltrap+0x38>

0000000080002c1a <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002c1a:	1101                	addi	sp,sp,-32
    80002c1c:	ec06                	sd	ra,24(sp)
    80002c1e:	e822                	sd	s0,16(sp)
    80002c20:	e426                	sd	s1,8(sp)
    80002c22:	1000                	addi	s0,sp,32
    80002c24:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002c26:	fffff097          	auipc	ra,0xfffff
    80002c2a:	da0080e7          	jalr	-608(ra) # 800019c6 <myproc>
  switch (n) {
    80002c2e:	4795                	li	a5,5
    80002c30:	0497e163          	bltu	a5,s1,80002c72 <argraw+0x58>
    80002c34:	048a                	slli	s1,s1,0x2
    80002c36:	00006717          	auipc	a4,0x6
    80002c3a:	90270713          	addi	a4,a4,-1790 # 80008538 <states.1760+0x270>
    80002c3e:	94ba                	add	s1,s1,a4
    80002c40:	409c                	lw	a5,0(s1)
    80002c42:	97ba                	add	a5,a5,a4
    80002c44:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002c46:	6d3c                	ld	a5,88(a0)
    80002c48:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002c4a:	60e2                	ld	ra,24(sp)
    80002c4c:	6442                	ld	s0,16(sp)
    80002c4e:	64a2                	ld	s1,8(sp)
    80002c50:	6105                	addi	sp,sp,32
    80002c52:	8082                	ret
    return p->trapframe->a1;
    80002c54:	6d3c                	ld	a5,88(a0)
    80002c56:	7fa8                	ld	a0,120(a5)
    80002c58:	bfcd                	j	80002c4a <argraw+0x30>
    return p->trapframe->a2;
    80002c5a:	6d3c                	ld	a5,88(a0)
    80002c5c:	63c8                	ld	a0,128(a5)
    80002c5e:	b7f5                	j	80002c4a <argraw+0x30>
    return p->trapframe->a3;
    80002c60:	6d3c                	ld	a5,88(a0)
    80002c62:	67c8                	ld	a0,136(a5)
    80002c64:	b7dd                	j	80002c4a <argraw+0x30>
    return p->trapframe->a4;
    80002c66:	6d3c                	ld	a5,88(a0)
    80002c68:	6bc8                	ld	a0,144(a5)
    80002c6a:	b7c5                	j	80002c4a <argraw+0x30>
    return p->trapframe->a5;
    80002c6c:	6d3c                	ld	a5,88(a0)
    80002c6e:	6fc8                	ld	a0,152(a5)
    80002c70:	bfe9                	j	80002c4a <argraw+0x30>
  panic("argraw");
    80002c72:	00005517          	auipc	a0,0x5
    80002c76:	79e50513          	addi	a0,a0,1950 # 80008410 <states.1760+0x148>
    80002c7a:	ffffe097          	auipc	ra,0xffffe
    80002c7e:	8ca080e7          	jalr	-1846(ra) # 80000544 <panic>

0000000080002c82 <fetchaddr>:
{
    80002c82:	1101                	addi	sp,sp,-32
    80002c84:	ec06                	sd	ra,24(sp)
    80002c86:	e822                	sd	s0,16(sp)
    80002c88:	e426                	sd	s1,8(sp)
    80002c8a:	e04a                	sd	s2,0(sp)
    80002c8c:	1000                	addi	s0,sp,32
    80002c8e:	84aa                	mv	s1,a0
    80002c90:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002c92:	fffff097          	auipc	ra,0xfffff
    80002c96:	d34080e7          	jalr	-716(ra) # 800019c6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002c9a:	653c                	ld	a5,72(a0)
    80002c9c:	02f4f863          	bgeu	s1,a5,80002ccc <fetchaddr+0x4a>
    80002ca0:	00848713          	addi	a4,s1,8
    80002ca4:	02e7e663          	bltu	a5,a4,80002cd0 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002ca8:	46a1                	li	a3,8
    80002caa:	8626                	mv	a2,s1
    80002cac:	85ca                	mv	a1,s2
    80002cae:	6928                	ld	a0,80(a0)
    80002cb0:	fffff097          	auipc	ra,0xfffff
    80002cb4:	a60080e7          	jalr	-1440(ra) # 80001710 <copyin>
    80002cb8:	00a03533          	snez	a0,a0
    80002cbc:	40a00533          	neg	a0,a0
}
    80002cc0:	60e2                	ld	ra,24(sp)
    80002cc2:	6442                	ld	s0,16(sp)
    80002cc4:	64a2                	ld	s1,8(sp)
    80002cc6:	6902                	ld	s2,0(sp)
    80002cc8:	6105                	addi	sp,sp,32
    80002cca:	8082                	ret
    return -1;
    80002ccc:	557d                	li	a0,-1
    80002cce:	bfcd                	j	80002cc0 <fetchaddr+0x3e>
    80002cd0:	557d                	li	a0,-1
    80002cd2:	b7fd                	j	80002cc0 <fetchaddr+0x3e>

0000000080002cd4 <fetchstr>:
{
    80002cd4:	7179                	addi	sp,sp,-48
    80002cd6:	f406                	sd	ra,40(sp)
    80002cd8:	f022                	sd	s0,32(sp)
    80002cda:	ec26                	sd	s1,24(sp)
    80002cdc:	e84a                	sd	s2,16(sp)
    80002cde:	e44e                	sd	s3,8(sp)
    80002ce0:	1800                	addi	s0,sp,48
    80002ce2:	892a                	mv	s2,a0
    80002ce4:	84ae                	mv	s1,a1
    80002ce6:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002ce8:	fffff097          	auipc	ra,0xfffff
    80002cec:	cde080e7          	jalr	-802(ra) # 800019c6 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002cf0:	86ce                	mv	a3,s3
    80002cf2:	864a                	mv	a2,s2
    80002cf4:	85a6                	mv	a1,s1
    80002cf6:	6928                	ld	a0,80(a0)
    80002cf8:	fffff097          	auipc	ra,0xfffff
    80002cfc:	aa4080e7          	jalr	-1372(ra) # 8000179c <copyinstr>
    80002d00:	00054e63          	bltz	a0,80002d1c <fetchstr+0x48>
  return strlen(buf);
    80002d04:	8526                	mv	a0,s1
    80002d06:	ffffe097          	auipc	ra,0xffffe
    80002d0a:	164080e7          	jalr	356(ra) # 80000e6a <strlen>
}
    80002d0e:	70a2                	ld	ra,40(sp)
    80002d10:	7402                	ld	s0,32(sp)
    80002d12:	64e2                	ld	s1,24(sp)
    80002d14:	6942                	ld	s2,16(sp)
    80002d16:	69a2                	ld	s3,8(sp)
    80002d18:	6145                	addi	sp,sp,48
    80002d1a:	8082                	ret
    return -1;
    80002d1c:	557d                	li	a0,-1
    80002d1e:	bfc5                	j	80002d0e <fetchstr+0x3a>

0000000080002d20 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002d20:	1101                	addi	sp,sp,-32
    80002d22:	ec06                	sd	ra,24(sp)
    80002d24:	e822                	sd	s0,16(sp)
    80002d26:	e426                	sd	s1,8(sp)
    80002d28:	1000                	addi	s0,sp,32
    80002d2a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d2c:	00000097          	auipc	ra,0x0
    80002d30:	eee080e7          	jalr	-274(ra) # 80002c1a <argraw>
    80002d34:	c088                	sw	a0,0(s1)
  return 0;
}
    80002d36:	4501                	li	a0,0
    80002d38:	60e2                	ld	ra,24(sp)
    80002d3a:	6442                	ld	s0,16(sp)
    80002d3c:	64a2                	ld	s1,8(sp)
    80002d3e:	6105                	addi	sp,sp,32
    80002d40:	8082                	ret

0000000080002d42 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002d42:	1101                	addi	sp,sp,-32
    80002d44:	ec06                	sd	ra,24(sp)
    80002d46:	e822                	sd	s0,16(sp)
    80002d48:	e426                	sd	s1,8(sp)
    80002d4a:	1000                	addi	s0,sp,32
    80002d4c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d4e:	00000097          	auipc	ra,0x0
    80002d52:	ecc080e7          	jalr	-308(ra) # 80002c1a <argraw>
    80002d56:	e088                	sd	a0,0(s1)
  return 0;
}
    80002d58:	4501                	li	a0,0
    80002d5a:	60e2                	ld	ra,24(sp)
    80002d5c:	6442                	ld	s0,16(sp)
    80002d5e:	64a2                	ld	s1,8(sp)
    80002d60:	6105                	addi	sp,sp,32
    80002d62:	8082                	ret

0000000080002d64 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002d64:	7179                	addi	sp,sp,-48
    80002d66:	f406                	sd	ra,40(sp)
    80002d68:	f022                	sd	s0,32(sp)
    80002d6a:	ec26                	sd	s1,24(sp)
    80002d6c:	e84a                	sd	s2,16(sp)
    80002d6e:	1800                	addi	s0,sp,48
    80002d70:	84ae                	mv	s1,a1
    80002d72:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002d74:	fd840593          	addi	a1,s0,-40
    80002d78:	00000097          	auipc	ra,0x0
    80002d7c:	fca080e7          	jalr	-54(ra) # 80002d42 <argaddr>
  return fetchstr(addr, buf, max);
    80002d80:	864a                	mv	a2,s2
    80002d82:	85a6                	mv	a1,s1
    80002d84:	fd843503          	ld	a0,-40(s0)
    80002d88:	00000097          	auipc	ra,0x0
    80002d8c:	f4c080e7          	jalr	-180(ra) # 80002cd4 <fetchstr>
}
    80002d90:	70a2                	ld	ra,40(sp)
    80002d92:	7402                	ld	s0,32(sp)
    80002d94:	64e2                	ld	s1,24(sp)
    80002d96:	6942                	ld	s2,16(sp)
    80002d98:	6145                	addi	sp,sp,48
    80002d9a:	8082                	ret

0000000080002d9c <syscall>:
    [SYS_sigreturn] 0,
};

void
syscall(void)
{
    80002d9c:	7179                	addi	sp,sp,-48
    80002d9e:	f406                	sd	ra,40(sp)
    80002da0:	f022                	sd	s0,32(sp)
    80002da2:	ec26                	sd	s1,24(sp)
    80002da4:	e84a                	sd	s2,16(sp)
    80002da6:	e44e                	sd	s3,8(sp)
    80002da8:	e052                	sd	s4,0(sp)
    80002daa:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002dac:	fffff097          	auipc	ra,0xfffff
    80002db0:	c1a080e7          	jalr	-998(ra) # 800019c6 <myproc>
    80002db4:	892a                	mv	s2,a0

  num = p->trapframe->a7;
    80002db6:	6d24                	ld	s1,88(a0)
    80002db8:	74dc                	ld	a5,168(s1)
    80002dba:	0007899b          	sext.w	s3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) 
    80002dbe:	37fd                	addiw	a5,a5,-1
    80002dc0:	4761                	li	a4,24
    80002dc2:	0af76163          	bltu	a4,a5,80002e64 <syscall+0xc8>
    80002dc6:	00399713          	slli	a4,s3,0x3
    80002dca:	00005797          	auipc	a5,0x5
    80002dce:	78678793          	addi	a5,a5,1926 # 80008550 <syscalls>
    80002dd2:	97ba                	add	a5,a5,a4
    80002dd4:	639c                	ld	a5,0(a5)
    80002dd6:	c7d9                	beqz	a5,80002e64 <syscall+0xc8>
  {
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002dd8:	9782                	jalr	a5
    80002dda:	f8a8                	sd	a0,112(s1)
    if ((p->mask >> num) & 1)
    80002ddc:	16892483          	lw	s1,360(s2)
    80002de0:	4134d4bb          	sraw	s1,s1,s3
    80002de4:	8885                	andi	s1,s1,1
    80002de6:	c0c5                	beqz	s1,80002e86 <syscall+0xea>
    {
      /* Modified for A4: Added entire section for trace, prints output for each syscall traced */
  	  printf("%d: syscall %s ( %d ",p->pid, syscallnames[num], p->trapframe->a0);
    80002de8:	05893703          	ld	a4,88(s2)
    80002dec:	00399693          	slli	a3,s3,0x3
    80002df0:	00006797          	auipc	a5,0x6
    80002df4:	c1878793          	addi	a5,a5,-1000 # 80008a08 <syscallnames>
    80002df8:	97b6                	add	a5,a5,a3
    80002dfa:	7b34                	ld	a3,112(a4)
    80002dfc:	6390                	ld	a2,0(a5)
    80002dfe:	03092583          	lw	a1,48(s2)
    80002e02:	00005517          	auipc	a0,0x5
    80002e06:	61650513          	addi	a0,a0,1558 # 80008418 <states.1760+0x150>
    80002e0a:	ffffd097          	auipc	ra,0xffffd
    80002e0e:	784080e7          	jalr	1924(ra) # 8000058e <printf>
      for (int i = 1; i < syscallnum[num]; i++) /* Modified for A4: 'num' tracks number of registers used by syscall and prints its register values  */
    80002e12:	098a                	slli	s3,s3,0x2
    80002e14:	00005797          	auipc	a5,0x5
    80002e18:	73c78793          	addi	a5,a5,1852 # 80008550 <syscalls>
    80002e1c:	99be                	add	s3,s3,a5
    80002e1e:	0d09a983          	lw	s3,208(s3)
    80002e22:	4785                	li	a5,1
    80002e24:	0337d463          	bge	a5,s3,80002e4c <syscall+0xb0>
        printf("%d ", argraw(i));
    80002e28:	00005a17          	auipc	s4,0x5
    80002e2c:	608a0a13          	addi	s4,s4,1544 # 80008430 <states.1760+0x168>
    80002e30:	8526                	mv	a0,s1
    80002e32:	00000097          	auipc	ra,0x0
    80002e36:	de8080e7          	jalr	-536(ra) # 80002c1a <argraw>
    80002e3a:	85aa                	mv	a1,a0
    80002e3c:	8552                	mv	a0,s4
    80002e3e:	ffffd097          	auipc	ra,0xffffd
    80002e42:	750080e7          	jalr	1872(ra) # 8000058e <printf>
      for (int i = 1; i < syscallnum[num]; i++) /* Modified for A4: 'num' tracks number of registers used by syscall and prints its register values  */
    80002e46:	2485                	addiw	s1,s1,1
    80002e48:	ff3494e3          	bne	s1,s3,80002e30 <syscall+0x94>
      printf(") -> %d\n", p->trapframe->a0);
    80002e4c:	05893783          	ld	a5,88(s2)
    80002e50:	7bac                	ld	a1,112(a5)
    80002e52:	00005517          	auipc	a0,0x5
    80002e56:	5e650513          	addi	a0,a0,1510 # 80008438 <states.1760+0x170>
    80002e5a:	ffffd097          	auipc	ra,0xffffd
    80002e5e:	734080e7          	jalr	1844(ra) # 8000058e <printf>
    80002e62:	a015                	j	80002e86 <syscall+0xea>
    }	
  } 
  else 
  {
    printf("%d %s: unknown sys call %d\n",
    80002e64:	86ce                	mv	a3,s3
    80002e66:	15890613          	addi	a2,s2,344
    80002e6a:	03092583          	lw	a1,48(s2)
    80002e6e:	00005517          	auipc	a0,0x5
    80002e72:	5da50513          	addi	a0,a0,1498 # 80008448 <states.1760+0x180>
    80002e76:	ffffd097          	auipc	ra,0xffffd
    80002e7a:	718080e7          	jalr	1816(ra) # 8000058e <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002e7e:	05893783          	ld	a5,88(s2)
    80002e82:	577d                	li	a4,-1
    80002e84:	fbb8                	sd	a4,112(a5)
  
  // if (p->mask >> num)
  // {
  // 	printf("%d: syscall %s -> %d\n",p->pid, syscallnames[num], p->trapframe->a0);
  // }	
}
    80002e86:	70a2                	ld	ra,40(sp)
    80002e88:	7402                	ld	s0,32(sp)
    80002e8a:	64e2                	ld	s1,24(sp)
    80002e8c:	6942                	ld	s2,16(sp)
    80002e8e:	69a2                	ld	s3,8(sp)
    80002e90:	6a02                	ld	s4,0(sp)
    80002e92:	6145                	addi	sp,sp,48
    80002e94:	8082                	ret

0000000080002e96 <sys_trace>:

int mask;

uint64
sys_trace(void)
{
    80002e96:	1141                	addi	sp,sp,-16
    80002e98:	e406                	sd	ra,8(sp)
    80002e9a:	e022                	sd	s0,0(sp)
    80002e9c:	0800                	addi	s0,sp,16
	if(argint(0, &mask) < 0)
    80002e9e:	00006597          	auipc	a1,0x6
    80002ea2:	c7658593          	addi	a1,a1,-906 # 80008b14 <mask>
    80002ea6:	4501                	li	a0,0
    80002ea8:	00000097          	auipc	ra,0x0
    80002eac:	e78080e7          	jalr	-392(ra) # 80002d20 <argint>
	{
		return -1;
    80002eb0:	57fd                	li	a5,-1
	if(argint(0, &mask) < 0)
    80002eb2:	00054d63          	bltz	a0,80002ecc <sys_trace+0x36>
	}
	
  myproc()->mask = mask;
    80002eb6:	fffff097          	auipc	ra,0xfffff
    80002eba:	b10080e7          	jalr	-1264(ra) # 800019c6 <myproc>
    80002ebe:	00006797          	auipc	a5,0x6
    80002ec2:	c567a783          	lw	a5,-938(a5) # 80008b14 <mask>
    80002ec6:	16f52423          	sw	a5,360(a0)
	return 0;
    80002eca:	4781                	li	a5,0
}	/* Modified for A4: Added trace */
    80002ecc:	853e                	mv	a0,a5
    80002ece:	60a2                	ld	ra,8(sp)
    80002ed0:	6402                	ld	s0,0(sp)
    80002ed2:	0141                	addi	sp,sp,16
    80002ed4:	8082                	ret

0000000080002ed6 <sys_sigalarm>:

/* Modified for A4: Added trace */
uint64 sys_sigalarm(void)
{
    80002ed6:	1101                	addi	sp,sp,-32
    80002ed8:	ec06                	sd	ra,24(sp)
    80002eda:	e822                	sd	s0,16(sp)
    80002edc:	1000                	addi	s0,sp,32
  uint64 addr;
  int ticks;
  if(argint(0, &ticks) < 0)
    80002ede:	fe440593          	addi	a1,s0,-28
    80002ee2:	4501                	li	a0,0
    80002ee4:	00000097          	auipc	ra,0x0
    80002ee8:	e3c080e7          	jalr	-452(ra) # 80002d20 <argint>
    return -1;
    80002eec:	57fd                	li	a5,-1
  if(argint(0, &ticks) < 0)
    80002eee:	04054463          	bltz	a0,80002f36 <sys_sigalarm+0x60>
  if(argaddr(1, &addr) < 0)
    80002ef2:	fe840593          	addi	a1,s0,-24
    80002ef6:	4505                	li	a0,1
    80002ef8:	00000097          	auipc	ra,0x0
    80002efc:	e4a080e7          	jalr	-438(ra) # 80002d42 <argaddr>
    return -1;
    80002f00:	57fd                	li	a5,-1
  if(argaddr(1, &addr) < 0)
    80002f02:	02054a63          	bltz	a0,80002f36 <sys_sigalarm+0x60>

  myproc()->ticks = ticks;
    80002f06:	fffff097          	auipc	ra,0xfffff
    80002f0a:	ac0080e7          	jalr	-1344(ra) # 800019c6 <myproc>
    80002f0e:	fe442783          	lw	a5,-28(s0)
    80002f12:	18f52423          	sw	a5,392(a0)
  myproc()->handler = addr;
    80002f16:	fffff097          	auipc	ra,0xfffff
    80002f1a:	ab0080e7          	jalr	-1360(ra) # 800019c6 <myproc>
    80002f1e:	fe843783          	ld	a5,-24(s0)
    80002f22:	18f53023          	sd	a5,384(a0)
  myproc()->alarm_on = 1;
    80002f26:	fffff097          	auipc	ra,0xfffff
    80002f2a:	aa0080e7          	jalr	-1376(ra) # 800019c6 <myproc>
    80002f2e:	4785                	li	a5,1
    80002f30:	18f52c23          	sw	a5,408(a0)
  //myproc()->a1 = myproc()->trapframe->a0;
  //myproc()->a2 = myproc()->trapframe->a1;

  return 0;
    80002f34:	4781                	li	a5,0
}
    80002f36:	853e                	mv	a0,a5
    80002f38:	60e2                	ld	ra,24(sp)
    80002f3a:	6442                	ld	s0,16(sp)
    80002f3c:	6105                	addi	sp,sp,32
    80002f3e:	8082                	ret

0000000080002f40 <sys_sigreturn>:

/* Modified for A4: Added trace */
uint64 sys_sigreturn(void)
{
    80002f40:	1101                	addi	sp,sp,-32
    80002f42:	ec06                	sd	ra,24(sp)
    80002f44:	e822                	sd	s0,16(sp)
    80002f46:	e426                	sd	s1,8(sp)
    80002f48:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002f4a:	fffff097          	auipc	ra,0xfffff
    80002f4e:	a7c080e7          	jalr	-1412(ra) # 800019c6 <myproc>
    80002f52:	84aa                	mv	s1,a0
  memmove(p->trapframe, p->alarm_tf, PGSIZE);
    80002f54:	6605                	lui	a2,0x1
    80002f56:	19053583          	ld	a1,400(a0)
    80002f5a:	6d28                	ld	a0,88(a0)
    80002f5c:	ffffe097          	auipc	ra,0xffffe
    80002f60:	dea080e7          	jalr	-534(ra) # 80000d46 <memmove>
  //myproc()->trapframe->a0 = myproc()->a1;
  //myproc()->trapframe->a1 = myproc()->a2;
  kfree(p->alarm_tf);
    80002f64:	1904b503          	ld	a0,400(s1)
    80002f68:	ffffe097          	auipc	ra,0xffffe
    80002f6c:	a96080e7          	jalr	-1386(ra) # 800009fe <kfree>
  p->cur_ticks = 0;
    80002f70:	1804a623          	sw	zero,396(s1)
  p->handlerpermission = 1;
    80002f74:	4785                	li	a5,1
    80002f76:	1af4a823          	sw	a5,432(s1)
  return myproc()->trapframe->a0;
    80002f7a:	fffff097          	auipc	ra,0xfffff
    80002f7e:	a4c080e7          	jalr	-1460(ra) # 800019c6 <myproc>
    80002f82:	6d3c                	ld	a5,88(a0)
}
    80002f84:	7ba8                	ld	a0,112(a5)
    80002f86:	60e2                	ld	ra,24(sp)
    80002f88:	6442                	ld	s0,16(sp)
    80002f8a:	64a2                	ld	s1,8(sp)
    80002f8c:	6105                	addi	sp,sp,32
    80002f8e:	8082                	ret

0000000080002f90 <sys_exit>:

uint64
sys_exit(void)
{
    80002f90:	1101                	addi	sp,sp,-32
    80002f92:	ec06                	sd	ra,24(sp)
    80002f94:	e822                	sd	s0,16(sp)
    80002f96:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002f98:	fec40593          	addi	a1,s0,-20
    80002f9c:	4501                	li	a0,0
    80002f9e:	00000097          	auipc	ra,0x0
    80002fa2:	d82080e7          	jalr	-638(ra) # 80002d20 <argint>
  exit(n);
    80002fa6:	fec42503          	lw	a0,-20(s0)
    80002faa:	fffff097          	auipc	ra,0xfffff
    80002fae:	3d4080e7          	jalr	980(ra) # 8000237e <exit>
  return 0;  // not reached
}
    80002fb2:	4501                	li	a0,0
    80002fb4:	60e2                	ld	ra,24(sp)
    80002fb6:	6442                	ld	s0,16(sp)
    80002fb8:	6105                	addi	sp,sp,32
    80002fba:	8082                	ret

0000000080002fbc <sys_getpid>:

uint64
sys_getpid(void)
{
    80002fbc:	1141                	addi	sp,sp,-16
    80002fbe:	e406                	sd	ra,8(sp)
    80002fc0:	e022                	sd	s0,0(sp)
    80002fc2:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002fc4:	fffff097          	auipc	ra,0xfffff
    80002fc8:	a02080e7          	jalr	-1534(ra) # 800019c6 <myproc>
}
    80002fcc:	5908                	lw	a0,48(a0)
    80002fce:	60a2                	ld	ra,8(sp)
    80002fd0:	6402                	ld	s0,0(sp)
    80002fd2:	0141                	addi	sp,sp,16
    80002fd4:	8082                	ret

0000000080002fd6 <sys_fork>:

uint64
sys_fork(void)
{
    80002fd6:	1141                	addi	sp,sp,-16
    80002fd8:	e406                	sd	ra,8(sp)
    80002fda:	e022                	sd	s0,0(sp)
    80002fdc:	0800                	addi	s0,sp,16
  return fork();
    80002fde:	fffff097          	auipc	ra,0xfffff
    80002fe2:	dcc080e7          	jalr	-564(ra) # 80001daa <fork>
}
    80002fe6:	60a2                	ld	ra,8(sp)
    80002fe8:	6402                	ld	s0,0(sp)
    80002fea:	0141                	addi	sp,sp,16
    80002fec:	8082                	ret

0000000080002fee <sys_wait>:

uint64
sys_wait(void)
{
    80002fee:	1101                	addi	sp,sp,-32
    80002ff0:	ec06                	sd	ra,24(sp)
    80002ff2:	e822                	sd	s0,16(sp)
    80002ff4:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002ff6:	fe840593          	addi	a1,s0,-24
    80002ffa:	4501                	li	a0,0
    80002ffc:	00000097          	auipc	ra,0x0
    80003000:	d46080e7          	jalr	-698(ra) # 80002d42 <argaddr>
  return wait(p);
    80003004:	fe843503          	ld	a0,-24(s0)
    80003008:	fffff097          	auipc	ra,0xfffff
    8000300c:	528080e7          	jalr	1320(ra) # 80002530 <wait>
}
    80003010:	60e2                	ld	ra,24(sp)
    80003012:	6442                	ld	s0,16(sp)
    80003014:	6105                	addi	sp,sp,32
    80003016:	8082                	ret

0000000080003018 <sys_waitx>:

uint64
sys_waitx(void)
{
    80003018:	7139                	addi	sp,sp,-64
    8000301a:	fc06                	sd	ra,56(sp)
    8000301c:	f822                	sd	s0,48(sp)
    8000301e:	f426                	sd	s1,40(sp)
    80003020:	f04a                	sd	s2,32(sp)
    80003022:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    80003024:	fd840593          	addi	a1,s0,-40
    80003028:	4501                	li	a0,0
    8000302a:	00000097          	auipc	ra,0x0
    8000302e:	d18080e7          	jalr	-744(ra) # 80002d42 <argaddr>
  argaddr(1, &addr1); // user virtual memory
    80003032:	fd040593          	addi	a1,s0,-48
    80003036:	4505                	li	a0,1
    80003038:	00000097          	auipc	ra,0x0
    8000303c:	d0a080e7          	jalr	-758(ra) # 80002d42 <argaddr>
  argaddr(2, &addr2);
    80003040:	fc840593          	addi	a1,s0,-56
    80003044:	4509                	li	a0,2
    80003046:	00000097          	auipc	ra,0x0
    8000304a:	cfc080e7          	jalr	-772(ra) # 80002d42 <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    8000304e:	fc040613          	addi	a2,s0,-64
    80003052:	fc440593          	addi	a1,s0,-60
    80003056:	fd843503          	ld	a0,-40(s0)
    8000305a:	fffff097          	auipc	ra,0xfffff
    8000305e:	108080e7          	jalr	264(ra) # 80002162 <waitx>
    80003062:	892a                	mv	s2,a0
  struct proc* p = myproc();
    80003064:	fffff097          	auipc	ra,0xfffff
    80003068:	962080e7          	jalr	-1694(ra) # 800019c6 <myproc>
    8000306c:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    8000306e:	4691                	li	a3,4
    80003070:	fc440613          	addi	a2,s0,-60
    80003074:	fd043583          	ld	a1,-48(s0)
    80003078:	6928                	ld	a0,80(a0)
    8000307a:	ffffe097          	auipc	ra,0xffffe
    8000307e:	60a080e7          	jalr	1546(ra) # 80001684 <copyout>
    return -1;
    80003082:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    80003084:	00054f63          	bltz	a0,800030a2 <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2,(char*)&rtime, sizeof(int)) < 0)
    80003088:	4691                	li	a3,4
    8000308a:	fc040613          	addi	a2,s0,-64
    8000308e:	fc843583          	ld	a1,-56(s0)
    80003092:	68a8                	ld	a0,80(s1)
    80003094:	ffffe097          	auipc	ra,0xffffe
    80003098:	5f0080e7          	jalr	1520(ra) # 80001684 <copyout>
    8000309c:	00054a63          	bltz	a0,800030b0 <sys_waitx+0x98>
    return -1;
  return ret;
    800030a0:	87ca                	mv	a5,s2
}
    800030a2:	853e                	mv	a0,a5
    800030a4:	70e2                	ld	ra,56(sp)
    800030a6:	7442                	ld	s0,48(sp)
    800030a8:	74a2                	ld	s1,40(sp)
    800030aa:	7902                	ld	s2,32(sp)
    800030ac:	6121                	addi	sp,sp,64
    800030ae:	8082                	ret
    return -1;
    800030b0:	57fd                	li	a5,-1
    800030b2:	bfc5                	j	800030a2 <sys_waitx+0x8a>

00000000800030b4 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800030b4:	7179                	addi	sp,sp,-48
    800030b6:	f406                	sd	ra,40(sp)
    800030b8:	f022                	sd	s0,32(sp)
    800030ba:	ec26                	sd	s1,24(sp)
    800030bc:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    800030be:	fdc40593          	addi	a1,s0,-36
    800030c2:	4501                	li	a0,0
    800030c4:	00000097          	auipc	ra,0x0
    800030c8:	c5c080e7          	jalr	-932(ra) # 80002d20 <argint>
  addr = myproc()->sz;
    800030cc:	fffff097          	auipc	ra,0xfffff
    800030d0:	8fa080e7          	jalr	-1798(ra) # 800019c6 <myproc>
    800030d4:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    800030d6:	fdc42503          	lw	a0,-36(s0)
    800030da:	fffff097          	auipc	ra,0xfffff
    800030de:	c74080e7          	jalr	-908(ra) # 80001d4e <growproc>
    800030e2:	00054863          	bltz	a0,800030f2 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    800030e6:	8526                	mv	a0,s1
    800030e8:	70a2                	ld	ra,40(sp)
    800030ea:	7402                	ld	s0,32(sp)
    800030ec:	64e2                	ld	s1,24(sp)
    800030ee:	6145                	addi	sp,sp,48
    800030f0:	8082                	ret
    return -1;
    800030f2:	54fd                	li	s1,-1
    800030f4:	bfcd                	j	800030e6 <sys_sbrk+0x32>

00000000800030f6 <sys_sleep>:

uint64
sys_sleep(void)
{
    800030f6:	7139                	addi	sp,sp,-64
    800030f8:	fc06                	sd	ra,56(sp)
    800030fa:	f822                	sd	s0,48(sp)
    800030fc:	f426                	sd	s1,40(sp)
    800030fe:	f04a                	sd	s2,32(sp)
    80003100:	ec4e                	sd	s3,24(sp)
    80003102:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80003104:	fcc40593          	addi	a1,s0,-52
    80003108:	4501                	li	a0,0
    8000310a:	00000097          	auipc	ra,0x0
    8000310e:	c16080e7          	jalr	-1002(ra) # 80002d20 <argint>
  acquire(&tickslock);
    80003112:	00015517          	auipc	a0,0x15
    80003116:	e9e50513          	addi	a0,a0,-354 # 80017fb0 <tickslock>
    8000311a:	ffffe097          	auipc	ra,0xffffe
    8000311e:	ad0080e7          	jalr	-1328(ra) # 80000bea <acquire>
  ticks0 = ticks;
    80003122:	00006917          	auipc	s2,0x6
    80003126:	9ee92903          	lw	s2,-1554(s2) # 80008b10 <ticks>
  while(ticks - ticks0 < n){
    8000312a:	fcc42783          	lw	a5,-52(s0)
    8000312e:	cf9d                	beqz	a5,8000316c <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003130:	00015997          	auipc	s3,0x15
    80003134:	e8098993          	addi	s3,s3,-384 # 80017fb0 <tickslock>
    80003138:	00006497          	auipc	s1,0x6
    8000313c:	9d848493          	addi	s1,s1,-1576 # 80008b10 <ticks>
    if(killed(myproc())){
    80003140:	fffff097          	auipc	ra,0xfffff
    80003144:	886080e7          	jalr	-1914(ra) # 800019c6 <myproc>
    80003148:	fffff097          	auipc	ra,0xfffff
    8000314c:	3b6080e7          	jalr	950(ra) # 800024fe <killed>
    80003150:	ed15                	bnez	a0,8000318c <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80003152:	85ce                	mv	a1,s3
    80003154:	8526                	mv	a0,s1
    80003156:	fffff097          	auipc	ra,0xfffff
    8000315a:	fa8080e7          	jalr	-88(ra) # 800020fe <sleep>
  while(ticks - ticks0 < n){
    8000315e:	409c                	lw	a5,0(s1)
    80003160:	412787bb          	subw	a5,a5,s2
    80003164:	fcc42703          	lw	a4,-52(s0)
    80003168:	fce7ece3          	bltu	a5,a4,80003140 <sys_sleep+0x4a>
  }
  release(&tickslock);
    8000316c:	00015517          	auipc	a0,0x15
    80003170:	e4450513          	addi	a0,a0,-444 # 80017fb0 <tickslock>
    80003174:	ffffe097          	auipc	ra,0xffffe
    80003178:	b2a080e7          	jalr	-1238(ra) # 80000c9e <release>
  return 0;
    8000317c:	4501                	li	a0,0
}
    8000317e:	70e2                	ld	ra,56(sp)
    80003180:	7442                	ld	s0,48(sp)
    80003182:	74a2                	ld	s1,40(sp)
    80003184:	7902                	ld	s2,32(sp)
    80003186:	69e2                	ld	s3,24(sp)
    80003188:	6121                	addi	sp,sp,64
    8000318a:	8082                	ret
      release(&tickslock);
    8000318c:	00015517          	auipc	a0,0x15
    80003190:	e2450513          	addi	a0,a0,-476 # 80017fb0 <tickslock>
    80003194:	ffffe097          	auipc	ra,0xffffe
    80003198:	b0a080e7          	jalr	-1270(ra) # 80000c9e <release>
      return -1;
    8000319c:	557d                	li	a0,-1
    8000319e:	b7c5                	j	8000317e <sys_sleep+0x88>

00000000800031a0 <sys_kill>:

uint64
sys_kill(void)
{
    800031a0:	1101                	addi	sp,sp,-32
    800031a2:	ec06                	sd	ra,24(sp)
    800031a4:	e822                	sd	s0,16(sp)
    800031a6:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800031a8:	fec40593          	addi	a1,s0,-20
    800031ac:	4501                	li	a0,0
    800031ae:	00000097          	auipc	ra,0x0
    800031b2:	b72080e7          	jalr	-1166(ra) # 80002d20 <argint>
  return kill(pid);
    800031b6:	fec42503          	lw	a0,-20(s0)
    800031ba:	fffff097          	auipc	ra,0xfffff
    800031be:	2a6080e7          	jalr	678(ra) # 80002460 <kill>
}
    800031c2:	60e2                	ld	ra,24(sp)
    800031c4:	6442                	ld	s0,16(sp)
    800031c6:	6105                	addi	sp,sp,32
    800031c8:	8082                	ret

00000000800031ca <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800031ca:	1101                	addi	sp,sp,-32
    800031cc:	ec06                	sd	ra,24(sp)
    800031ce:	e822                	sd	s0,16(sp)
    800031d0:	e426                	sd	s1,8(sp)
    800031d2:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800031d4:	00015517          	auipc	a0,0x15
    800031d8:	ddc50513          	addi	a0,a0,-548 # 80017fb0 <tickslock>
    800031dc:	ffffe097          	auipc	ra,0xffffe
    800031e0:	a0e080e7          	jalr	-1522(ra) # 80000bea <acquire>
  xticks = ticks;
    800031e4:	00006497          	auipc	s1,0x6
    800031e8:	92c4a483          	lw	s1,-1748(s1) # 80008b10 <ticks>
  release(&tickslock);
    800031ec:	00015517          	auipc	a0,0x15
    800031f0:	dc450513          	addi	a0,a0,-572 # 80017fb0 <tickslock>
    800031f4:	ffffe097          	auipc	ra,0xffffe
    800031f8:	aaa080e7          	jalr	-1366(ra) # 80000c9e <release>
  return xticks;
}
    800031fc:	02049513          	slli	a0,s1,0x20
    80003200:	9101                	srli	a0,a0,0x20
    80003202:	60e2                	ld	ra,24(sp)
    80003204:	6442                	ld	s0,16(sp)
    80003206:	64a2                	ld	s1,8(sp)
    80003208:	6105                	addi	sp,sp,32
    8000320a:	8082                	ret

000000008000320c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000320c:	7179                	addi	sp,sp,-48
    8000320e:	f406                	sd	ra,40(sp)
    80003210:	f022                	sd	s0,32(sp)
    80003212:	ec26                	sd	s1,24(sp)
    80003214:	e84a                	sd	s2,16(sp)
    80003216:	e44e                	sd	s3,8(sp)
    80003218:	e052                	sd	s4,0(sp)
    8000321a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000321c:	00005597          	auipc	a1,0x5
    80003220:	46c58593          	addi	a1,a1,1132 # 80008688 <syscallnum+0x68>
    80003224:	00015517          	auipc	a0,0x15
    80003228:	da450513          	addi	a0,a0,-604 # 80017fc8 <bcache>
    8000322c:	ffffe097          	auipc	ra,0xffffe
    80003230:	92e080e7          	jalr	-1746(ra) # 80000b5a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003234:	0001d797          	auipc	a5,0x1d
    80003238:	d9478793          	addi	a5,a5,-620 # 8001ffc8 <bcache+0x8000>
    8000323c:	0001d717          	auipc	a4,0x1d
    80003240:	ff470713          	addi	a4,a4,-12 # 80020230 <bcache+0x8268>
    80003244:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003248:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000324c:	00015497          	auipc	s1,0x15
    80003250:	d9448493          	addi	s1,s1,-620 # 80017fe0 <bcache+0x18>
    b->next = bcache.head.next;
    80003254:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003256:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003258:	00005a17          	auipc	s4,0x5
    8000325c:	438a0a13          	addi	s4,s4,1080 # 80008690 <syscallnum+0x70>
    b->next = bcache.head.next;
    80003260:	2b893783          	ld	a5,696(s2)
    80003264:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003266:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000326a:	85d2                	mv	a1,s4
    8000326c:	01048513          	addi	a0,s1,16
    80003270:	00001097          	auipc	ra,0x1
    80003274:	4c4080e7          	jalr	1220(ra) # 80004734 <initsleeplock>
    bcache.head.next->prev = b;
    80003278:	2b893783          	ld	a5,696(s2)
    8000327c:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000327e:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003282:	45848493          	addi	s1,s1,1112
    80003286:	fd349de3          	bne	s1,s3,80003260 <binit+0x54>
  }
}
    8000328a:	70a2                	ld	ra,40(sp)
    8000328c:	7402                	ld	s0,32(sp)
    8000328e:	64e2                	ld	s1,24(sp)
    80003290:	6942                	ld	s2,16(sp)
    80003292:	69a2                	ld	s3,8(sp)
    80003294:	6a02                	ld	s4,0(sp)
    80003296:	6145                	addi	sp,sp,48
    80003298:	8082                	ret

000000008000329a <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000329a:	7179                	addi	sp,sp,-48
    8000329c:	f406                	sd	ra,40(sp)
    8000329e:	f022                	sd	s0,32(sp)
    800032a0:	ec26                	sd	s1,24(sp)
    800032a2:	e84a                	sd	s2,16(sp)
    800032a4:	e44e                	sd	s3,8(sp)
    800032a6:	1800                	addi	s0,sp,48
    800032a8:	89aa                	mv	s3,a0
    800032aa:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    800032ac:	00015517          	auipc	a0,0x15
    800032b0:	d1c50513          	addi	a0,a0,-740 # 80017fc8 <bcache>
    800032b4:	ffffe097          	auipc	ra,0xffffe
    800032b8:	936080e7          	jalr	-1738(ra) # 80000bea <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800032bc:	0001d497          	auipc	s1,0x1d
    800032c0:	fc44b483          	ld	s1,-60(s1) # 80020280 <bcache+0x82b8>
    800032c4:	0001d797          	auipc	a5,0x1d
    800032c8:	f6c78793          	addi	a5,a5,-148 # 80020230 <bcache+0x8268>
    800032cc:	02f48f63          	beq	s1,a5,8000330a <bread+0x70>
    800032d0:	873e                	mv	a4,a5
    800032d2:	a021                	j	800032da <bread+0x40>
    800032d4:	68a4                	ld	s1,80(s1)
    800032d6:	02e48a63          	beq	s1,a4,8000330a <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800032da:	449c                	lw	a5,8(s1)
    800032dc:	ff379ce3          	bne	a5,s3,800032d4 <bread+0x3a>
    800032e0:	44dc                	lw	a5,12(s1)
    800032e2:	ff2799e3          	bne	a5,s2,800032d4 <bread+0x3a>
      b->refcnt++;
    800032e6:	40bc                	lw	a5,64(s1)
    800032e8:	2785                	addiw	a5,a5,1
    800032ea:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800032ec:	00015517          	auipc	a0,0x15
    800032f0:	cdc50513          	addi	a0,a0,-804 # 80017fc8 <bcache>
    800032f4:	ffffe097          	auipc	ra,0xffffe
    800032f8:	9aa080e7          	jalr	-1622(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    800032fc:	01048513          	addi	a0,s1,16
    80003300:	00001097          	auipc	ra,0x1
    80003304:	46e080e7          	jalr	1134(ra) # 8000476e <acquiresleep>
      return b;
    80003308:	a8b9                	j	80003366 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000330a:	0001d497          	auipc	s1,0x1d
    8000330e:	f6e4b483          	ld	s1,-146(s1) # 80020278 <bcache+0x82b0>
    80003312:	0001d797          	auipc	a5,0x1d
    80003316:	f1e78793          	addi	a5,a5,-226 # 80020230 <bcache+0x8268>
    8000331a:	00f48863          	beq	s1,a5,8000332a <bread+0x90>
    8000331e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003320:	40bc                	lw	a5,64(s1)
    80003322:	cf81                	beqz	a5,8000333a <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003324:	64a4                	ld	s1,72(s1)
    80003326:	fee49de3          	bne	s1,a4,80003320 <bread+0x86>
  panic("bget: no buffers");
    8000332a:	00005517          	auipc	a0,0x5
    8000332e:	36e50513          	addi	a0,a0,878 # 80008698 <syscallnum+0x78>
    80003332:	ffffd097          	auipc	ra,0xffffd
    80003336:	212080e7          	jalr	530(ra) # 80000544 <panic>
      b->dev = dev;
    8000333a:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    8000333e:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80003342:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003346:	4785                	li	a5,1
    80003348:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000334a:	00015517          	auipc	a0,0x15
    8000334e:	c7e50513          	addi	a0,a0,-898 # 80017fc8 <bcache>
    80003352:	ffffe097          	auipc	ra,0xffffe
    80003356:	94c080e7          	jalr	-1716(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    8000335a:	01048513          	addi	a0,s1,16
    8000335e:	00001097          	auipc	ra,0x1
    80003362:	410080e7          	jalr	1040(ra) # 8000476e <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003366:	409c                	lw	a5,0(s1)
    80003368:	cb89                	beqz	a5,8000337a <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000336a:	8526                	mv	a0,s1
    8000336c:	70a2                	ld	ra,40(sp)
    8000336e:	7402                	ld	s0,32(sp)
    80003370:	64e2                	ld	s1,24(sp)
    80003372:	6942                	ld	s2,16(sp)
    80003374:	69a2                	ld	s3,8(sp)
    80003376:	6145                	addi	sp,sp,48
    80003378:	8082                	ret
    virtio_disk_rw(b, 0);
    8000337a:	4581                	li	a1,0
    8000337c:	8526                	mv	a0,s1
    8000337e:	00003097          	auipc	ra,0x3
    80003382:	fca080e7          	jalr	-54(ra) # 80006348 <virtio_disk_rw>
    b->valid = 1;
    80003386:	4785                	li	a5,1
    80003388:	c09c                	sw	a5,0(s1)
  return b;
    8000338a:	b7c5                	j	8000336a <bread+0xd0>

000000008000338c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000338c:	1101                	addi	sp,sp,-32
    8000338e:	ec06                	sd	ra,24(sp)
    80003390:	e822                	sd	s0,16(sp)
    80003392:	e426                	sd	s1,8(sp)
    80003394:	1000                	addi	s0,sp,32
    80003396:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003398:	0541                	addi	a0,a0,16
    8000339a:	00001097          	auipc	ra,0x1
    8000339e:	46e080e7          	jalr	1134(ra) # 80004808 <holdingsleep>
    800033a2:	cd01                	beqz	a0,800033ba <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800033a4:	4585                	li	a1,1
    800033a6:	8526                	mv	a0,s1
    800033a8:	00003097          	auipc	ra,0x3
    800033ac:	fa0080e7          	jalr	-96(ra) # 80006348 <virtio_disk_rw>
}
    800033b0:	60e2                	ld	ra,24(sp)
    800033b2:	6442                	ld	s0,16(sp)
    800033b4:	64a2                	ld	s1,8(sp)
    800033b6:	6105                	addi	sp,sp,32
    800033b8:	8082                	ret
    panic("bwrite");
    800033ba:	00005517          	auipc	a0,0x5
    800033be:	2f650513          	addi	a0,a0,758 # 800086b0 <syscallnum+0x90>
    800033c2:	ffffd097          	auipc	ra,0xffffd
    800033c6:	182080e7          	jalr	386(ra) # 80000544 <panic>

00000000800033ca <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800033ca:	1101                	addi	sp,sp,-32
    800033cc:	ec06                	sd	ra,24(sp)
    800033ce:	e822                	sd	s0,16(sp)
    800033d0:	e426                	sd	s1,8(sp)
    800033d2:	e04a                	sd	s2,0(sp)
    800033d4:	1000                	addi	s0,sp,32
    800033d6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800033d8:	01050913          	addi	s2,a0,16
    800033dc:	854a                	mv	a0,s2
    800033de:	00001097          	auipc	ra,0x1
    800033e2:	42a080e7          	jalr	1066(ra) # 80004808 <holdingsleep>
    800033e6:	c92d                	beqz	a0,80003458 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800033e8:	854a                	mv	a0,s2
    800033ea:	00001097          	auipc	ra,0x1
    800033ee:	3da080e7          	jalr	986(ra) # 800047c4 <releasesleep>

  acquire(&bcache.lock);
    800033f2:	00015517          	auipc	a0,0x15
    800033f6:	bd650513          	addi	a0,a0,-1066 # 80017fc8 <bcache>
    800033fa:	ffffd097          	auipc	ra,0xffffd
    800033fe:	7f0080e7          	jalr	2032(ra) # 80000bea <acquire>
  b->refcnt--;
    80003402:	40bc                	lw	a5,64(s1)
    80003404:	37fd                	addiw	a5,a5,-1
    80003406:	0007871b          	sext.w	a4,a5
    8000340a:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000340c:	eb05                	bnez	a4,8000343c <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000340e:	68bc                	ld	a5,80(s1)
    80003410:	64b8                	ld	a4,72(s1)
    80003412:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003414:	64bc                	ld	a5,72(s1)
    80003416:	68b8                	ld	a4,80(s1)
    80003418:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000341a:	0001d797          	auipc	a5,0x1d
    8000341e:	bae78793          	addi	a5,a5,-1106 # 8001ffc8 <bcache+0x8000>
    80003422:	2b87b703          	ld	a4,696(a5)
    80003426:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003428:	0001d717          	auipc	a4,0x1d
    8000342c:	e0870713          	addi	a4,a4,-504 # 80020230 <bcache+0x8268>
    80003430:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003432:	2b87b703          	ld	a4,696(a5)
    80003436:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003438:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000343c:	00015517          	auipc	a0,0x15
    80003440:	b8c50513          	addi	a0,a0,-1140 # 80017fc8 <bcache>
    80003444:	ffffe097          	auipc	ra,0xffffe
    80003448:	85a080e7          	jalr	-1958(ra) # 80000c9e <release>
}
    8000344c:	60e2                	ld	ra,24(sp)
    8000344e:	6442                	ld	s0,16(sp)
    80003450:	64a2                	ld	s1,8(sp)
    80003452:	6902                	ld	s2,0(sp)
    80003454:	6105                	addi	sp,sp,32
    80003456:	8082                	ret
    panic("brelse");
    80003458:	00005517          	auipc	a0,0x5
    8000345c:	26050513          	addi	a0,a0,608 # 800086b8 <syscallnum+0x98>
    80003460:	ffffd097          	auipc	ra,0xffffd
    80003464:	0e4080e7          	jalr	228(ra) # 80000544 <panic>

0000000080003468 <bpin>:

void
bpin(struct buf *b) {
    80003468:	1101                	addi	sp,sp,-32
    8000346a:	ec06                	sd	ra,24(sp)
    8000346c:	e822                	sd	s0,16(sp)
    8000346e:	e426                	sd	s1,8(sp)
    80003470:	1000                	addi	s0,sp,32
    80003472:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003474:	00015517          	auipc	a0,0x15
    80003478:	b5450513          	addi	a0,a0,-1196 # 80017fc8 <bcache>
    8000347c:	ffffd097          	auipc	ra,0xffffd
    80003480:	76e080e7          	jalr	1902(ra) # 80000bea <acquire>
  b->refcnt++;
    80003484:	40bc                	lw	a5,64(s1)
    80003486:	2785                	addiw	a5,a5,1
    80003488:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000348a:	00015517          	auipc	a0,0x15
    8000348e:	b3e50513          	addi	a0,a0,-1218 # 80017fc8 <bcache>
    80003492:	ffffe097          	auipc	ra,0xffffe
    80003496:	80c080e7          	jalr	-2036(ra) # 80000c9e <release>
}
    8000349a:	60e2                	ld	ra,24(sp)
    8000349c:	6442                	ld	s0,16(sp)
    8000349e:	64a2                	ld	s1,8(sp)
    800034a0:	6105                	addi	sp,sp,32
    800034a2:	8082                	ret

00000000800034a4 <bunpin>:

void
bunpin(struct buf *b) {
    800034a4:	1101                	addi	sp,sp,-32
    800034a6:	ec06                	sd	ra,24(sp)
    800034a8:	e822                	sd	s0,16(sp)
    800034aa:	e426                	sd	s1,8(sp)
    800034ac:	1000                	addi	s0,sp,32
    800034ae:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800034b0:	00015517          	auipc	a0,0x15
    800034b4:	b1850513          	addi	a0,a0,-1256 # 80017fc8 <bcache>
    800034b8:	ffffd097          	auipc	ra,0xffffd
    800034bc:	732080e7          	jalr	1842(ra) # 80000bea <acquire>
  b->refcnt--;
    800034c0:	40bc                	lw	a5,64(s1)
    800034c2:	37fd                	addiw	a5,a5,-1
    800034c4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800034c6:	00015517          	auipc	a0,0x15
    800034ca:	b0250513          	addi	a0,a0,-1278 # 80017fc8 <bcache>
    800034ce:	ffffd097          	auipc	ra,0xffffd
    800034d2:	7d0080e7          	jalr	2000(ra) # 80000c9e <release>
}
    800034d6:	60e2                	ld	ra,24(sp)
    800034d8:	6442                	ld	s0,16(sp)
    800034da:	64a2                	ld	s1,8(sp)
    800034dc:	6105                	addi	sp,sp,32
    800034de:	8082                	ret

00000000800034e0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800034e0:	1101                	addi	sp,sp,-32
    800034e2:	ec06                	sd	ra,24(sp)
    800034e4:	e822                	sd	s0,16(sp)
    800034e6:	e426                	sd	s1,8(sp)
    800034e8:	e04a                	sd	s2,0(sp)
    800034ea:	1000                	addi	s0,sp,32
    800034ec:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800034ee:	00d5d59b          	srliw	a1,a1,0xd
    800034f2:	0001d797          	auipc	a5,0x1d
    800034f6:	1b27a783          	lw	a5,434(a5) # 800206a4 <sb+0x1c>
    800034fa:	9dbd                	addw	a1,a1,a5
    800034fc:	00000097          	auipc	ra,0x0
    80003500:	d9e080e7          	jalr	-610(ra) # 8000329a <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003504:	0074f713          	andi	a4,s1,7
    80003508:	4785                	li	a5,1
    8000350a:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000350e:	14ce                	slli	s1,s1,0x33
    80003510:	90d9                	srli	s1,s1,0x36
    80003512:	00950733          	add	a4,a0,s1
    80003516:	05874703          	lbu	a4,88(a4)
    8000351a:	00e7f6b3          	and	a3,a5,a4
    8000351e:	c69d                	beqz	a3,8000354c <bfree+0x6c>
    80003520:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003522:	94aa                	add	s1,s1,a0
    80003524:	fff7c793          	not	a5,a5
    80003528:	8ff9                	and	a5,a5,a4
    8000352a:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    8000352e:	00001097          	auipc	ra,0x1
    80003532:	120080e7          	jalr	288(ra) # 8000464e <log_write>
  brelse(bp);
    80003536:	854a                	mv	a0,s2
    80003538:	00000097          	auipc	ra,0x0
    8000353c:	e92080e7          	jalr	-366(ra) # 800033ca <brelse>
}
    80003540:	60e2                	ld	ra,24(sp)
    80003542:	6442                	ld	s0,16(sp)
    80003544:	64a2                	ld	s1,8(sp)
    80003546:	6902                	ld	s2,0(sp)
    80003548:	6105                	addi	sp,sp,32
    8000354a:	8082                	ret
    panic("freeing free block");
    8000354c:	00005517          	auipc	a0,0x5
    80003550:	17450513          	addi	a0,a0,372 # 800086c0 <syscallnum+0xa0>
    80003554:	ffffd097          	auipc	ra,0xffffd
    80003558:	ff0080e7          	jalr	-16(ra) # 80000544 <panic>

000000008000355c <balloc>:
{
    8000355c:	711d                	addi	sp,sp,-96
    8000355e:	ec86                	sd	ra,88(sp)
    80003560:	e8a2                	sd	s0,80(sp)
    80003562:	e4a6                	sd	s1,72(sp)
    80003564:	e0ca                	sd	s2,64(sp)
    80003566:	fc4e                	sd	s3,56(sp)
    80003568:	f852                	sd	s4,48(sp)
    8000356a:	f456                	sd	s5,40(sp)
    8000356c:	f05a                	sd	s6,32(sp)
    8000356e:	ec5e                	sd	s7,24(sp)
    80003570:	e862                	sd	s8,16(sp)
    80003572:	e466                	sd	s9,8(sp)
    80003574:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003576:	0001d797          	auipc	a5,0x1d
    8000357a:	1167a783          	lw	a5,278(a5) # 8002068c <sb+0x4>
    8000357e:	10078163          	beqz	a5,80003680 <balloc+0x124>
    80003582:	8baa                	mv	s7,a0
    80003584:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003586:	0001db17          	auipc	s6,0x1d
    8000358a:	102b0b13          	addi	s6,s6,258 # 80020688 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000358e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003590:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003592:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003594:	6c89                	lui	s9,0x2
    80003596:	a061                	j	8000361e <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003598:	974a                	add	a4,a4,s2
    8000359a:	8fd5                	or	a5,a5,a3
    8000359c:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800035a0:	854a                	mv	a0,s2
    800035a2:	00001097          	auipc	ra,0x1
    800035a6:	0ac080e7          	jalr	172(ra) # 8000464e <log_write>
        brelse(bp);
    800035aa:	854a                	mv	a0,s2
    800035ac:	00000097          	auipc	ra,0x0
    800035b0:	e1e080e7          	jalr	-482(ra) # 800033ca <brelse>
  bp = bread(dev, bno);
    800035b4:	85a6                	mv	a1,s1
    800035b6:	855e                	mv	a0,s7
    800035b8:	00000097          	auipc	ra,0x0
    800035bc:	ce2080e7          	jalr	-798(ra) # 8000329a <bread>
    800035c0:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800035c2:	40000613          	li	a2,1024
    800035c6:	4581                	li	a1,0
    800035c8:	05850513          	addi	a0,a0,88
    800035cc:	ffffd097          	auipc	ra,0xffffd
    800035d0:	71a080e7          	jalr	1818(ra) # 80000ce6 <memset>
  log_write(bp);
    800035d4:	854a                	mv	a0,s2
    800035d6:	00001097          	auipc	ra,0x1
    800035da:	078080e7          	jalr	120(ra) # 8000464e <log_write>
  brelse(bp);
    800035de:	854a                	mv	a0,s2
    800035e0:	00000097          	auipc	ra,0x0
    800035e4:	dea080e7          	jalr	-534(ra) # 800033ca <brelse>
}
    800035e8:	8526                	mv	a0,s1
    800035ea:	60e6                	ld	ra,88(sp)
    800035ec:	6446                	ld	s0,80(sp)
    800035ee:	64a6                	ld	s1,72(sp)
    800035f0:	6906                	ld	s2,64(sp)
    800035f2:	79e2                	ld	s3,56(sp)
    800035f4:	7a42                	ld	s4,48(sp)
    800035f6:	7aa2                	ld	s5,40(sp)
    800035f8:	7b02                	ld	s6,32(sp)
    800035fa:	6be2                	ld	s7,24(sp)
    800035fc:	6c42                	ld	s8,16(sp)
    800035fe:	6ca2                	ld	s9,8(sp)
    80003600:	6125                	addi	sp,sp,96
    80003602:	8082                	ret
    brelse(bp);
    80003604:	854a                	mv	a0,s2
    80003606:	00000097          	auipc	ra,0x0
    8000360a:	dc4080e7          	jalr	-572(ra) # 800033ca <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000360e:	015c87bb          	addw	a5,s9,s5
    80003612:	00078a9b          	sext.w	s5,a5
    80003616:	004b2703          	lw	a4,4(s6)
    8000361a:	06eaf363          	bgeu	s5,a4,80003680 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    8000361e:	41fad79b          	sraiw	a5,s5,0x1f
    80003622:	0137d79b          	srliw	a5,a5,0x13
    80003626:	015787bb          	addw	a5,a5,s5
    8000362a:	40d7d79b          	sraiw	a5,a5,0xd
    8000362e:	01cb2583          	lw	a1,28(s6)
    80003632:	9dbd                	addw	a1,a1,a5
    80003634:	855e                	mv	a0,s7
    80003636:	00000097          	auipc	ra,0x0
    8000363a:	c64080e7          	jalr	-924(ra) # 8000329a <bread>
    8000363e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003640:	004b2503          	lw	a0,4(s6)
    80003644:	000a849b          	sext.w	s1,s5
    80003648:	8662                	mv	a2,s8
    8000364a:	faa4fde3          	bgeu	s1,a0,80003604 <balloc+0xa8>
      m = 1 << (bi % 8);
    8000364e:	41f6579b          	sraiw	a5,a2,0x1f
    80003652:	01d7d69b          	srliw	a3,a5,0x1d
    80003656:	00c6873b          	addw	a4,a3,a2
    8000365a:	00777793          	andi	a5,a4,7
    8000365e:	9f95                	subw	a5,a5,a3
    80003660:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003664:	4037571b          	sraiw	a4,a4,0x3
    80003668:	00e906b3          	add	a3,s2,a4
    8000366c:	0586c683          	lbu	a3,88(a3)
    80003670:	00d7f5b3          	and	a1,a5,a3
    80003674:	d195                	beqz	a1,80003598 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003676:	2605                	addiw	a2,a2,1
    80003678:	2485                	addiw	s1,s1,1
    8000367a:	fd4618e3          	bne	a2,s4,8000364a <balloc+0xee>
    8000367e:	b759                	j	80003604 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003680:	00005517          	auipc	a0,0x5
    80003684:	05850513          	addi	a0,a0,88 # 800086d8 <syscallnum+0xb8>
    80003688:	ffffd097          	auipc	ra,0xffffd
    8000368c:	f06080e7          	jalr	-250(ra) # 8000058e <printf>
  return 0;
    80003690:	4481                	li	s1,0
    80003692:	bf99                	j	800035e8 <balloc+0x8c>

0000000080003694 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003694:	7179                	addi	sp,sp,-48
    80003696:	f406                	sd	ra,40(sp)
    80003698:	f022                	sd	s0,32(sp)
    8000369a:	ec26                	sd	s1,24(sp)
    8000369c:	e84a                	sd	s2,16(sp)
    8000369e:	e44e                	sd	s3,8(sp)
    800036a0:	e052                	sd	s4,0(sp)
    800036a2:	1800                	addi	s0,sp,48
    800036a4:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800036a6:	47ad                	li	a5,11
    800036a8:	02b7e763          	bltu	a5,a1,800036d6 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    800036ac:	02059493          	slli	s1,a1,0x20
    800036b0:	9081                	srli	s1,s1,0x20
    800036b2:	048a                	slli	s1,s1,0x2
    800036b4:	94aa                	add	s1,s1,a0
    800036b6:	0504a903          	lw	s2,80(s1)
    800036ba:	06091e63          	bnez	s2,80003736 <bmap+0xa2>
      addr = balloc(ip->dev);
    800036be:	4108                	lw	a0,0(a0)
    800036c0:	00000097          	auipc	ra,0x0
    800036c4:	e9c080e7          	jalr	-356(ra) # 8000355c <balloc>
    800036c8:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800036cc:	06090563          	beqz	s2,80003736 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    800036d0:	0524a823          	sw	s2,80(s1)
    800036d4:	a08d                	j	80003736 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    800036d6:	ff45849b          	addiw	s1,a1,-12
    800036da:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800036de:	0ff00793          	li	a5,255
    800036e2:	08e7e563          	bltu	a5,a4,8000376c <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800036e6:	08052903          	lw	s2,128(a0)
    800036ea:	00091d63          	bnez	s2,80003704 <bmap+0x70>
      addr = balloc(ip->dev);
    800036ee:	4108                	lw	a0,0(a0)
    800036f0:	00000097          	auipc	ra,0x0
    800036f4:	e6c080e7          	jalr	-404(ra) # 8000355c <balloc>
    800036f8:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800036fc:	02090d63          	beqz	s2,80003736 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003700:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003704:	85ca                	mv	a1,s2
    80003706:	0009a503          	lw	a0,0(s3)
    8000370a:	00000097          	auipc	ra,0x0
    8000370e:	b90080e7          	jalr	-1136(ra) # 8000329a <bread>
    80003712:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003714:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003718:	02049593          	slli	a1,s1,0x20
    8000371c:	9181                	srli	a1,a1,0x20
    8000371e:	058a                	slli	a1,a1,0x2
    80003720:	00b784b3          	add	s1,a5,a1
    80003724:	0004a903          	lw	s2,0(s1)
    80003728:	02090063          	beqz	s2,80003748 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000372c:	8552                	mv	a0,s4
    8000372e:	00000097          	auipc	ra,0x0
    80003732:	c9c080e7          	jalr	-868(ra) # 800033ca <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003736:	854a                	mv	a0,s2
    80003738:	70a2                	ld	ra,40(sp)
    8000373a:	7402                	ld	s0,32(sp)
    8000373c:	64e2                	ld	s1,24(sp)
    8000373e:	6942                	ld	s2,16(sp)
    80003740:	69a2                	ld	s3,8(sp)
    80003742:	6a02                	ld	s4,0(sp)
    80003744:	6145                	addi	sp,sp,48
    80003746:	8082                	ret
      addr = balloc(ip->dev);
    80003748:	0009a503          	lw	a0,0(s3)
    8000374c:	00000097          	auipc	ra,0x0
    80003750:	e10080e7          	jalr	-496(ra) # 8000355c <balloc>
    80003754:	0005091b          	sext.w	s2,a0
      if(addr){
    80003758:	fc090ae3          	beqz	s2,8000372c <bmap+0x98>
        a[bn] = addr;
    8000375c:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003760:	8552                	mv	a0,s4
    80003762:	00001097          	auipc	ra,0x1
    80003766:	eec080e7          	jalr	-276(ra) # 8000464e <log_write>
    8000376a:	b7c9                	j	8000372c <bmap+0x98>
  panic("bmap: out of range");
    8000376c:	00005517          	auipc	a0,0x5
    80003770:	f8450513          	addi	a0,a0,-124 # 800086f0 <syscallnum+0xd0>
    80003774:	ffffd097          	auipc	ra,0xffffd
    80003778:	dd0080e7          	jalr	-560(ra) # 80000544 <panic>

000000008000377c <iget>:
{
    8000377c:	7179                	addi	sp,sp,-48
    8000377e:	f406                	sd	ra,40(sp)
    80003780:	f022                	sd	s0,32(sp)
    80003782:	ec26                	sd	s1,24(sp)
    80003784:	e84a                	sd	s2,16(sp)
    80003786:	e44e                	sd	s3,8(sp)
    80003788:	e052                	sd	s4,0(sp)
    8000378a:	1800                	addi	s0,sp,48
    8000378c:	89aa                	mv	s3,a0
    8000378e:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003790:	0001d517          	auipc	a0,0x1d
    80003794:	f1850513          	addi	a0,a0,-232 # 800206a8 <itable>
    80003798:	ffffd097          	auipc	ra,0xffffd
    8000379c:	452080e7          	jalr	1106(ra) # 80000bea <acquire>
  empty = 0;
    800037a0:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800037a2:	0001d497          	auipc	s1,0x1d
    800037a6:	f1e48493          	addi	s1,s1,-226 # 800206c0 <itable+0x18>
    800037aa:	0001f697          	auipc	a3,0x1f
    800037ae:	9a668693          	addi	a3,a3,-1626 # 80022150 <log>
    800037b2:	a039                	j	800037c0 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800037b4:	02090b63          	beqz	s2,800037ea <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800037b8:	08848493          	addi	s1,s1,136
    800037bc:	02d48a63          	beq	s1,a3,800037f0 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800037c0:	449c                	lw	a5,8(s1)
    800037c2:	fef059e3          	blez	a5,800037b4 <iget+0x38>
    800037c6:	4098                	lw	a4,0(s1)
    800037c8:	ff3716e3          	bne	a4,s3,800037b4 <iget+0x38>
    800037cc:	40d8                	lw	a4,4(s1)
    800037ce:	ff4713e3          	bne	a4,s4,800037b4 <iget+0x38>
      ip->ref++;
    800037d2:	2785                	addiw	a5,a5,1
    800037d4:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800037d6:	0001d517          	auipc	a0,0x1d
    800037da:	ed250513          	addi	a0,a0,-302 # 800206a8 <itable>
    800037de:	ffffd097          	auipc	ra,0xffffd
    800037e2:	4c0080e7          	jalr	1216(ra) # 80000c9e <release>
      return ip;
    800037e6:	8926                	mv	s2,s1
    800037e8:	a03d                	j	80003816 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800037ea:	f7f9                	bnez	a5,800037b8 <iget+0x3c>
    800037ec:	8926                	mv	s2,s1
    800037ee:	b7e9                	j	800037b8 <iget+0x3c>
  if(empty == 0)
    800037f0:	02090c63          	beqz	s2,80003828 <iget+0xac>
  ip->dev = dev;
    800037f4:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800037f8:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800037fc:	4785                	li	a5,1
    800037fe:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003802:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003806:	0001d517          	auipc	a0,0x1d
    8000380a:	ea250513          	addi	a0,a0,-350 # 800206a8 <itable>
    8000380e:	ffffd097          	auipc	ra,0xffffd
    80003812:	490080e7          	jalr	1168(ra) # 80000c9e <release>
}
    80003816:	854a                	mv	a0,s2
    80003818:	70a2                	ld	ra,40(sp)
    8000381a:	7402                	ld	s0,32(sp)
    8000381c:	64e2                	ld	s1,24(sp)
    8000381e:	6942                	ld	s2,16(sp)
    80003820:	69a2                	ld	s3,8(sp)
    80003822:	6a02                	ld	s4,0(sp)
    80003824:	6145                	addi	sp,sp,48
    80003826:	8082                	ret
    panic("iget: no inodes");
    80003828:	00005517          	auipc	a0,0x5
    8000382c:	ee050513          	addi	a0,a0,-288 # 80008708 <syscallnum+0xe8>
    80003830:	ffffd097          	auipc	ra,0xffffd
    80003834:	d14080e7          	jalr	-748(ra) # 80000544 <panic>

0000000080003838 <fsinit>:
fsinit(int dev) {
    80003838:	7179                	addi	sp,sp,-48
    8000383a:	f406                	sd	ra,40(sp)
    8000383c:	f022                	sd	s0,32(sp)
    8000383e:	ec26                	sd	s1,24(sp)
    80003840:	e84a                	sd	s2,16(sp)
    80003842:	e44e                	sd	s3,8(sp)
    80003844:	1800                	addi	s0,sp,48
    80003846:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003848:	4585                	li	a1,1
    8000384a:	00000097          	auipc	ra,0x0
    8000384e:	a50080e7          	jalr	-1456(ra) # 8000329a <bread>
    80003852:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003854:	0001d997          	auipc	s3,0x1d
    80003858:	e3498993          	addi	s3,s3,-460 # 80020688 <sb>
    8000385c:	02000613          	li	a2,32
    80003860:	05850593          	addi	a1,a0,88
    80003864:	854e                	mv	a0,s3
    80003866:	ffffd097          	auipc	ra,0xffffd
    8000386a:	4e0080e7          	jalr	1248(ra) # 80000d46 <memmove>
  brelse(bp);
    8000386e:	8526                	mv	a0,s1
    80003870:	00000097          	auipc	ra,0x0
    80003874:	b5a080e7          	jalr	-1190(ra) # 800033ca <brelse>
  if(sb.magic != FSMAGIC)
    80003878:	0009a703          	lw	a4,0(s3)
    8000387c:	102037b7          	lui	a5,0x10203
    80003880:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003884:	02f71263          	bne	a4,a5,800038a8 <fsinit+0x70>
  initlog(dev, &sb);
    80003888:	0001d597          	auipc	a1,0x1d
    8000388c:	e0058593          	addi	a1,a1,-512 # 80020688 <sb>
    80003890:	854a                	mv	a0,s2
    80003892:	00001097          	auipc	ra,0x1
    80003896:	b40080e7          	jalr	-1216(ra) # 800043d2 <initlog>
}
    8000389a:	70a2                	ld	ra,40(sp)
    8000389c:	7402                	ld	s0,32(sp)
    8000389e:	64e2                	ld	s1,24(sp)
    800038a0:	6942                	ld	s2,16(sp)
    800038a2:	69a2                	ld	s3,8(sp)
    800038a4:	6145                	addi	sp,sp,48
    800038a6:	8082                	ret
    panic("invalid file system");
    800038a8:	00005517          	auipc	a0,0x5
    800038ac:	e7050513          	addi	a0,a0,-400 # 80008718 <syscallnum+0xf8>
    800038b0:	ffffd097          	auipc	ra,0xffffd
    800038b4:	c94080e7          	jalr	-876(ra) # 80000544 <panic>

00000000800038b8 <iinit>:
{
    800038b8:	7179                	addi	sp,sp,-48
    800038ba:	f406                	sd	ra,40(sp)
    800038bc:	f022                	sd	s0,32(sp)
    800038be:	ec26                	sd	s1,24(sp)
    800038c0:	e84a                	sd	s2,16(sp)
    800038c2:	e44e                	sd	s3,8(sp)
    800038c4:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800038c6:	00005597          	auipc	a1,0x5
    800038ca:	e6a58593          	addi	a1,a1,-406 # 80008730 <syscallnum+0x110>
    800038ce:	0001d517          	auipc	a0,0x1d
    800038d2:	dda50513          	addi	a0,a0,-550 # 800206a8 <itable>
    800038d6:	ffffd097          	auipc	ra,0xffffd
    800038da:	284080e7          	jalr	644(ra) # 80000b5a <initlock>
  for(i = 0; i < NINODE; i++) {
    800038de:	0001d497          	auipc	s1,0x1d
    800038e2:	df248493          	addi	s1,s1,-526 # 800206d0 <itable+0x28>
    800038e6:	0001f997          	auipc	s3,0x1f
    800038ea:	87a98993          	addi	s3,s3,-1926 # 80022160 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800038ee:	00005917          	auipc	s2,0x5
    800038f2:	e4a90913          	addi	s2,s2,-438 # 80008738 <syscallnum+0x118>
    800038f6:	85ca                	mv	a1,s2
    800038f8:	8526                	mv	a0,s1
    800038fa:	00001097          	auipc	ra,0x1
    800038fe:	e3a080e7          	jalr	-454(ra) # 80004734 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003902:	08848493          	addi	s1,s1,136
    80003906:	ff3498e3          	bne	s1,s3,800038f6 <iinit+0x3e>
}
    8000390a:	70a2                	ld	ra,40(sp)
    8000390c:	7402                	ld	s0,32(sp)
    8000390e:	64e2                	ld	s1,24(sp)
    80003910:	6942                	ld	s2,16(sp)
    80003912:	69a2                	ld	s3,8(sp)
    80003914:	6145                	addi	sp,sp,48
    80003916:	8082                	ret

0000000080003918 <ialloc>:
{
    80003918:	715d                	addi	sp,sp,-80
    8000391a:	e486                	sd	ra,72(sp)
    8000391c:	e0a2                	sd	s0,64(sp)
    8000391e:	fc26                	sd	s1,56(sp)
    80003920:	f84a                	sd	s2,48(sp)
    80003922:	f44e                	sd	s3,40(sp)
    80003924:	f052                	sd	s4,32(sp)
    80003926:	ec56                	sd	s5,24(sp)
    80003928:	e85a                	sd	s6,16(sp)
    8000392a:	e45e                	sd	s7,8(sp)
    8000392c:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000392e:	0001d717          	auipc	a4,0x1d
    80003932:	d6672703          	lw	a4,-666(a4) # 80020694 <sb+0xc>
    80003936:	4785                	li	a5,1
    80003938:	04e7fa63          	bgeu	a5,a4,8000398c <ialloc+0x74>
    8000393c:	8aaa                	mv	s5,a0
    8000393e:	8bae                	mv	s7,a1
    80003940:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003942:	0001da17          	auipc	s4,0x1d
    80003946:	d46a0a13          	addi	s4,s4,-698 # 80020688 <sb>
    8000394a:	00048b1b          	sext.w	s6,s1
    8000394e:	0044d593          	srli	a1,s1,0x4
    80003952:	018a2783          	lw	a5,24(s4)
    80003956:	9dbd                	addw	a1,a1,a5
    80003958:	8556                	mv	a0,s5
    8000395a:	00000097          	auipc	ra,0x0
    8000395e:	940080e7          	jalr	-1728(ra) # 8000329a <bread>
    80003962:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003964:	05850993          	addi	s3,a0,88
    80003968:	00f4f793          	andi	a5,s1,15
    8000396c:	079a                	slli	a5,a5,0x6
    8000396e:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003970:	00099783          	lh	a5,0(s3)
    80003974:	c3a1                	beqz	a5,800039b4 <ialloc+0x9c>
    brelse(bp);
    80003976:	00000097          	auipc	ra,0x0
    8000397a:	a54080e7          	jalr	-1452(ra) # 800033ca <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000397e:	0485                	addi	s1,s1,1
    80003980:	00ca2703          	lw	a4,12(s4)
    80003984:	0004879b          	sext.w	a5,s1
    80003988:	fce7e1e3          	bltu	a5,a4,8000394a <ialloc+0x32>
  printf("ialloc: no inodes\n");
    8000398c:	00005517          	auipc	a0,0x5
    80003990:	db450513          	addi	a0,a0,-588 # 80008740 <syscallnum+0x120>
    80003994:	ffffd097          	auipc	ra,0xffffd
    80003998:	bfa080e7          	jalr	-1030(ra) # 8000058e <printf>
  return 0;
    8000399c:	4501                	li	a0,0
}
    8000399e:	60a6                	ld	ra,72(sp)
    800039a0:	6406                	ld	s0,64(sp)
    800039a2:	74e2                	ld	s1,56(sp)
    800039a4:	7942                	ld	s2,48(sp)
    800039a6:	79a2                	ld	s3,40(sp)
    800039a8:	7a02                	ld	s4,32(sp)
    800039aa:	6ae2                	ld	s5,24(sp)
    800039ac:	6b42                	ld	s6,16(sp)
    800039ae:	6ba2                	ld	s7,8(sp)
    800039b0:	6161                	addi	sp,sp,80
    800039b2:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800039b4:	04000613          	li	a2,64
    800039b8:	4581                	li	a1,0
    800039ba:	854e                	mv	a0,s3
    800039bc:	ffffd097          	auipc	ra,0xffffd
    800039c0:	32a080e7          	jalr	810(ra) # 80000ce6 <memset>
      dip->type = type;
    800039c4:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800039c8:	854a                	mv	a0,s2
    800039ca:	00001097          	auipc	ra,0x1
    800039ce:	c84080e7          	jalr	-892(ra) # 8000464e <log_write>
      brelse(bp);
    800039d2:	854a                	mv	a0,s2
    800039d4:	00000097          	auipc	ra,0x0
    800039d8:	9f6080e7          	jalr	-1546(ra) # 800033ca <brelse>
      return iget(dev, inum);
    800039dc:	85da                	mv	a1,s6
    800039de:	8556                	mv	a0,s5
    800039e0:	00000097          	auipc	ra,0x0
    800039e4:	d9c080e7          	jalr	-612(ra) # 8000377c <iget>
    800039e8:	bf5d                	j	8000399e <ialloc+0x86>

00000000800039ea <iupdate>:
{
    800039ea:	1101                	addi	sp,sp,-32
    800039ec:	ec06                	sd	ra,24(sp)
    800039ee:	e822                	sd	s0,16(sp)
    800039f0:	e426                	sd	s1,8(sp)
    800039f2:	e04a                	sd	s2,0(sp)
    800039f4:	1000                	addi	s0,sp,32
    800039f6:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800039f8:	415c                	lw	a5,4(a0)
    800039fa:	0047d79b          	srliw	a5,a5,0x4
    800039fe:	0001d597          	auipc	a1,0x1d
    80003a02:	ca25a583          	lw	a1,-862(a1) # 800206a0 <sb+0x18>
    80003a06:	9dbd                	addw	a1,a1,a5
    80003a08:	4108                	lw	a0,0(a0)
    80003a0a:	00000097          	auipc	ra,0x0
    80003a0e:	890080e7          	jalr	-1904(ra) # 8000329a <bread>
    80003a12:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a14:	05850793          	addi	a5,a0,88
    80003a18:	40c8                	lw	a0,4(s1)
    80003a1a:	893d                	andi	a0,a0,15
    80003a1c:	051a                	slli	a0,a0,0x6
    80003a1e:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003a20:	04449703          	lh	a4,68(s1)
    80003a24:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003a28:	04649703          	lh	a4,70(s1)
    80003a2c:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003a30:	04849703          	lh	a4,72(s1)
    80003a34:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003a38:	04a49703          	lh	a4,74(s1)
    80003a3c:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003a40:	44f8                	lw	a4,76(s1)
    80003a42:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003a44:	03400613          	li	a2,52
    80003a48:	05048593          	addi	a1,s1,80
    80003a4c:	0531                	addi	a0,a0,12
    80003a4e:	ffffd097          	auipc	ra,0xffffd
    80003a52:	2f8080e7          	jalr	760(ra) # 80000d46 <memmove>
  log_write(bp);
    80003a56:	854a                	mv	a0,s2
    80003a58:	00001097          	auipc	ra,0x1
    80003a5c:	bf6080e7          	jalr	-1034(ra) # 8000464e <log_write>
  brelse(bp);
    80003a60:	854a                	mv	a0,s2
    80003a62:	00000097          	auipc	ra,0x0
    80003a66:	968080e7          	jalr	-1688(ra) # 800033ca <brelse>
}
    80003a6a:	60e2                	ld	ra,24(sp)
    80003a6c:	6442                	ld	s0,16(sp)
    80003a6e:	64a2                	ld	s1,8(sp)
    80003a70:	6902                	ld	s2,0(sp)
    80003a72:	6105                	addi	sp,sp,32
    80003a74:	8082                	ret

0000000080003a76 <idup>:
{
    80003a76:	1101                	addi	sp,sp,-32
    80003a78:	ec06                	sd	ra,24(sp)
    80003a7a:	e822                	sd	s0,16(sp)
    80003a7c:	e426                	sd	s1,8(sp)
    80003a7e:	1000                	addi	s0,sp,32
    80003a80:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003a82:	0001d517          	auipc	a0,0x1d
    80003a86:	c2650513          	addi	a0,a0,-986 # 800206a8 <itable>
    80003a8a:	ffffd097          	auipc	ra,0xffffd
    80003a8e:	160080e7          	jalr	352(ra) # 80000bea <acquire>
  ip->ref++;
    80003a92:	449c                	lw	a5,8(s1)
    80003a94:	2785                	addiw	a5,a5,1
    80003a96:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003a98:	0001d517          	auipc	a0,0x1d
    80003a9c:	c1050513          	addi	a0,a0,-1008 # 800206a8 <itable>
    80003aa0:	ffffd097          	auipc	ra,0xffffd
    80003aa4:	1fe080e7          	jalr	510(ra) # 80000c9e <release>
}
    80003aa8:	8526                	mv	a0,s1
    80003aaa:	60e2                	ld	ra,24(sp)
    80003aac:	6442                	ld	s0,16(sp)
    80003aae:	64a2                	ld	s1,8(sp)
    80003ab0:	6105                	addi	sp,sp,32
    80003ab2:	8082                	ret

0000000080003ab4 <ilock>:
{
    80003ab4:	1101                	addi	sp,sp,-32
    80003ab6:	ec06                	sd	ra,24(sp)
    80003ab8:	e822                	sd	s0,16(sp)
    80003aba:	e426                	sd	s1,8(sp)
    80003abc:	e04a                	sd	s2,0(sp)
    80003abe:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003ac0:	c115                	beqz	a0,80003ae4 <ilock+0x30>
    80003ac2:	84aa                	mv	s1,a0
    80003ac4:	451c                	lw	a5,8(a0)
    80003ac6:	00f05f63          	blez	a5,80003ae4 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003aca:	0541                	addi	a0,a0,16
    80003acc:	00001097          	auipc	ra,0x1
    80003ad0:	ca2080e7          	jalr	-862(ra) # 8000476e <acquiresleep>
  if(ip->valid == 0){
    80003ad4:	40bc                	lw	a5,64(s1)
    80003ad6:	cf99                	beqz	a5,80003af4 <ilock+0x40>
}
    80003ad8:	60e2                	ld	ra,24(sp)
    80003ada:	6442                	ld	s0,16(sp)
    80003adc:	64a2                	ld	s1,8(sp)
    80003ade:	6902                	ld	s2,0(sp)
    80003ae0:	6105                	addi	sp,sp,32
    80003ae2:	8082                	ret
    panic("ilock");
    80003ae4:	00005517          	auipc	a0,0x5
    80003ae8:	c7450513          	addi	a0,a0,-908 # 80008758 <syscallnum+0x138>
    80003aec:	ffffd097          	auipc	ra,0xffffd
    80003af0:	a58080e7          	jalr	-1448(ra) # 80000544 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003af4:	40dc                	lw	a5,4(s1)
    80003af6:	0047d79b          	srliw	a5,a5,0x4
    80003afa:	0001d597          	auipc	a1,0x1d
    80003afe:	ba65a583          	lw	a1,-1114(a1) # 800206a0 <sb+0x18>
    80003b02:	9dbd                	addw	a1,a1,a5
    80003b04:	4088                	lw	a0,0(s1)
    80003b06:	fffff097          	auipc	ra,0xfffff
    80003b0a:	794080e7          	jalr	1940(ra) # 8000329a <bread>
    80003b0e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b10:	05850593          	addi	a1,a0,88
    80003b14:	40dc                	lw	a5,4(s1)
    80003b16:	8bbd                	andi	a5,a5,15
    80003b18:	079a                	slli	a5,a5,0x6
    80003b1a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003b1c:	00059783          	lh	a5,0(a1)
    80003b20:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003b24:	00259783          	lh	a5,2(a1)
    80003b28:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003b2c:	00459783          	lh	a5,4(a1)
    80003b30:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003b34:	00659783          	lh	a5,6(a1)
    80003b38:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003b3c:	459c                	lw	a5,8(a1)
    80003b3e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003b40:	03400613          	li	a2,52
    80003b44:	05b1                	addi	a1,a1,12
    80003b46:	05048513          	addi	a0,s1,80
    80003b4a:	ffffd097          	auipc	ra,0xffffd
    80003b4e:	1fc080e7          	jalr	508(ra) # 80000d46 <memmove>
    brelse(bp);
    80003b52:	854a                	mv	a0,s2
    80003b54:	00000097          	auipc	ra,0x0
    80003b58:	876080e7          	jalr	-1930(ra) # 800033ca <brelse>
    ip->valid = 1;
    80003b5c:	4785                	li	a5,1
    80003b5e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003b60:	04449783          	lh	a5,68(s1)
    80003b64:	fbb5                	bnez	a5,80003ad8 <ilock+0x24>
      panic("ilock: no type");
    80003b66:	00005517          	auipc	a0,0x5
    80003b6a:	bfa50513          	addi	a0,a0,-1030 # 80008760 <syscallnum+0x140>
    80003b6e:	ffffd097          	auipc	ra,0xffffd
    80003b72:	9d6080e7          	jalr	-1578(ra) # 80000544 <panic>

0000000080003b76 <iunlock>:
{
    80003b76:	1101                	addi	sp,sp,-32
    80003b78:	ec06                	sd	ra,24(sp)
    80003b7a:	e822                	sd	s0,16(sp)
    80003b7c:	e426                	sd	s1,8(sp)
    80003b7e:	e04a                	sd	s2,0(sp)
    80003b80:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003b82:	c905                	beqz	a0,80003bb2 <iunlock+0x3c>
    80003b84:	84aa                	mv	s1,a0
    80003b86:	01050913          	addi	s2,a0,16
    80003b8a:	854a                	mv	a0,s2
    80003b8c:	00001097          	auipc	ra,0x1
    80003b90:	c7c080e7          	jalr	-900(ra) # 80004808 <holdingsleep>
    80003b94:	cd19                	beqz	a0,80003bb2 <iunlock+0x3c>
    80003b96:	449c                	lw	a5,8(s1)
    80003b98:	00f05d63          	blez	a5,80003bb2 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003b9c:	854a                	mv	a0,s2
    80003b9e:	00001097          	auipc	ra,0x1
    80003ba2:	c26080e7          	jalr	-986(ra) # 800047c4 <releasesleep>
}
    80003ba6:	60e2                	ld	ra,24(sp)
    80003ba8:	6442                	ld	s0,16(sp)
    80003baa:	64a2                	ld	s1,8(sp)
    80003bac:	6902                	ld	s2,0(sp)
    80003bae:	6105                	addi	sp,sp,32
    80003bb0:	8082                	ret
    panic("iunlock");
    80003bb2:	00005517          	auipc	a0,0x5
    80003bb6:	bbe50513          	addi	a0,a0,-1090 # 80008770 <syscallnum+0x150>
    80003bba:	ffffd097          	auipc	ra,0xffffd
    80003bbe:	98a080e7          	jalr	-1654(ra) # 80000544 <panic>

0000000080003bc2 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003bc2:	7179                	addi	sp,sp,-48
    80003bc4:	f406                	sd	ra,40(sp)
    80003bc6:	f022                	sd	s0,32(sp)
    80003bc8:	ec26                	sd	s1,24(sp)
    80003bca:	e84a                	sd	s2,16(sp)
    80003bcc:	e44e                	sd	s3,8(sp)
    80003bce:	e052                	sd	s4,0(sp)
    80003bd0:	1800                	addi	s0,sp,48
    80003bd2:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003bd4:	05050493          	addi	s1,a0,80
    80003bd8:	08050913          	addi	s2,a0,128
    80003bdc:	a021                	j	80003be4 <itrunc+0x22>
    80003bde:	0491                	addi	s1,s1,4
    80003be0:	01248d63          	beq	s1,s2,80003bfa <itrunc+0x38>
    if(ip->addrs[i]){
    80003be4:	408c                	lw	a1,0(s1)
    80003be6:	dde5                	beqz	a1,80003bde <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003be8:	0009a503          	lw	a0,0(s3)
    80003bec:	00000097          	auipc	ra,0x0
    80003bf0:	8f4080e7          	jalr	-1804(ra) # 800034e0 <bfree>
      ip->addrs[i] = 0;
    80003bf4:	0004a023          	sw	zero,0(s1)
    80003bf8:	b7dd                	j	80003bde <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003bfa:	0809a583          	lw	a1,128(s3)
    80003bfe:	e185                	bnez	a1,80003c1e <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003c00:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003c04:	854e                	mv	a0,s3
    80003c06:	00000097          	auipc	ra,0x0
    80003c0a:	de4080e7          	jalr	-540(ra) # 800039ea <iupdate>
}
    80003c0e:	70a2                	ld	ra,40(sp)
    80003c10:	7402                	ld	s0,32(sp)
    80003c12:	64e2                	ld	s1,24(sp)
    80003c14:	6942                	ld	s2,16(sp)
    80003c16:	69a2                	ld	s3,8(sp)
    80003c18:	6a02                	ld	s4,0(sp)
    80003c1a:	6145                	addi	sp,sp,48
    80003c1c:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003c1e:	0009a503          	lw	a0,0(s3)
    80003c22:	fffff097          	auipc	ra,0xfffff
    80003c26:	678080e7          	jalr	1656(ra) # 8000329a <bread>
    80003c2a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003c2c:	05850493          	addi	s1,a0,88
    80003c30:	45850913          	addi	s2,a0,1112
    80003c34:	a811                	j	80003c48 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003c36:	0009a503          	lw	a0,0(s3)
    80003c3a:	00000097          	auipc	ra,0x0
    80003c3e:	8a6080e7          	jalr	-1882(ra) # 800034e0 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003c42:	0491                	addi	s1,s1,4
    80003c44:	01248563          	beq	s1,s2,80003c4e <itrunc+0x8c>
      if(a[j])
    80003c48:	408c                	lw	a1,0(s1)
    80003c4a:	dde5                	beqz	a1,80003c42 <itrunc+0x80>
    80003c4c:	b7ed                	j	80003c36 <itrunc+0x74>
    brelse(bp);
    80003c4e:	8552                	mv	a0,s4
    80003c50:	fffff097          	auipc	ra,0xfffff
    80003c54:	77a080e7          	jalr	1914(ra) # 800033ca <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003c58:	0809a583          	lw	a1,128(s3)
    80003c5c:	0009a503          	lw	a0,0(s3)
    80003c60:	00000097          	auipc	ra,0x0
    80003c64:	880080e7          	jalr	-1920(ra) # 800034e0 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003c68:	0809a023          	sw	zero,128(s3)
    80003c6c:	bf51                	j	80003c00 <itrunc+0x3e>

0000000080003c6e <iput>:
{
    80003c6e:	1101                	addi	sp,sp,-32
    80003c70:	ec06                	sd	ra,24(sp)
    80003c72:	e822                	sd	s0,16(sp)
    80003c74:	e426                	sd	s1,8(sp)
    80003c76:	e04a                	sd	s2,0(sp)
    80003c78:	1000                	addi	s0,sp,32
    80003c7a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003c7c:	0001d517          	auipc	a0,0x1d
    80003c80:	a2c50513          	addi	a0,a0,-1492 # 800206a8 <itable>
    80003c84:	ffffd097          	auipc	ra,0xffffd
    80003c88:	f66080e7          	jalr	-154(ra) # 80000bea <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003c8c:	4498                	lw	a4,8(s1)
    80003c8e:	4785                	li	a5,1
    80003c90:	02f70363          	beq	a4,a5,80003cb6 <iput+0x48>
  ip->ref--;
    80003c94:	449c                	lw	a5,8(s1)
    80003c96:	37fd                	addiw	a5,a5,-1
    80003c98:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003c9a:	0001d517          	auipc	a0,0x1d
    80003c9e:	a0e50513          	addi	a0,a0,-1522 # 800206a8 <itable>
    80003ca2:	ffffd097          	auipc	ra,0xffffd
    80003ca6:	ffc080e7          	jalr	-4(ra) # 80000c9e <release>
}
    80003caa:	60e2                	ld	ra,24(sp)
    80003cac:	6442                	ld	s0,16(sp)
    80003cae:	64a2                	ld	s1,8(sp)
    80003cb0:	6902                	ld	s2,0(sp)
    80003cb2:	6105                	addi	sp,sp,32
    80003cb4:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003cb6:	40bc                	lw	a5,64(s1)
    80003cb8:	dff1                	beqz	a5,80003c94 <iput+0x26>
    80003cba:	04a49783          	lh	a5,74(s1)
    80003cbe:	fbf9                	bnez	a5,80003c94 <iput+0x26>
    acquiresleep(&ip->lock);
    80003cc0:	01048913          	addi	s2,s1,16
    80003cc4:	854a                	mv	a0,s2
    80003cc6:	00001097          	auipc	ra,0x1
    80003cca:	aa8080e7          	jalr	-1368(ra) # 8000476e <acquiresleep>
    release(&itable.lock);
    80003cce:	0001d517          	auipc	a0,0x1d
    80003cd2:	9da50513          	addi	a0,a0,-1574 # 800206a8 <itable>
    80003cd6:	ffffd097          	auipc	ra,0xffffd
    80003cda:	fc8080e7          	jalr	-56(ra) # 80000c9e <release>
    itrunc(ip);
    80003cde:	8526                	mv	a0,s1
    80003ce0:	00000097          	auipc	ra,0x0
    80003ce4:	ee2080e7          	jalr	-286(ra) # 80003bc2 <itrunc>
    ip->type = 0;
    80003ce8:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003cec:	8526                	mv	a0,s1
    80003cee:	00000097          	auipc	ra,0x0
    80003cf2:	cfc080e7          	jalr	-772(ra) # 800039ea <iupdate>
    ip->valid = 0;
    80003cf6:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003cfa:	854a                	mv	a0,s2
    80003cfc:	00001097          	auipc	ra,0x1
    80003d00:	ac8080e7          	jalr	-1336(ra) # 800047c4 <releasesleep>
    acquire(&itable.lock);
    80003d04:	0001d517          	auipc	a0,0x1d
    80003d08:	9a450513          	addi	a0,a0,-1628 # 800206a8 <itable>
    80003d0c:	ffffd097          	auipc	ra,0xffffd
    80003d10:	ede080e7          	jalr	-290(ra) # 80000bea <acquire>
    80003d14:	b741                	j	80003c94 <iput+0x26>

0000000080003d16 <iunlockput>:
{
    80003d16:	1101                	addi	sp,sp,-32
    80003d18:	ec06                	sd	ra,24(sp)
    80003d1a:	e822                	sd	s0,16(sp)
    80003d1c:	e426                	sd	s1,8(sp)
    80003d1e:	1000                	addi	s0,sp,32
    80003d20:	84aa                	mv	s1,a0
  iunlock(ip);
    80003d22:	00000097          	auipc	ra,0x0
    80003d26:	e54080e7          	jalr	-428(ra) # 80003b76 <iunlock>
  iput(ip);
    80003d2a:	8526                	mv	a0,s1
    80003d2c:	00000097          	auipc	ra,0x0
    80003d30:	f42080e7          	jalr	-190(ra) # 80003c6e <iput>
}
    80003d34:	60e2                	ld	ra,24(sp)
    80003d36:	6442                	ld	s0,16(sp)
    80003d38:	64a2                	ld	s1,8(sp)
    80003d3a:	6105                	addi	sp,sp,32
    80003d3c:	8082                	ret

0000000080003d3e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003d3e:	1141                	addi	sp,sp,-16
    80003d40:	e422                	sd	s0,8(sp)
    80003d42:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003d44:	411c                	lw	a5,0(a0)
    80003d46:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003d48:	415c                	lw	a5,4(a0)
    80003d4a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003d4c:	04451783          	lh	a5,68(a0)
    80003d50:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003d54:	04a51783          	lh	a5,74(a0)
    80003d58:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003d5c:	04c56783          	lwu	a5,76(a0)
    80003d60:	e99c                	sd	a5,16(a1)
}
    80003d62:	6422                	ld	s0,8(sp)
    80003d64:	0141                	addi	sp,sp,16
    80003d66:	8082                	ret

0000000080003d68 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d68:	457c                	lw	a5,76(a0)
    80003d6a:	0ed7e963          	bltu	a5,a3,80003e5c <readi+0xf4>
{
    80003d6e:	7159                	addi	sp,sp,-112
    80003d70:	f486                	sd	ra,104(sp)
    80003d72:	f0a2                	sd	s0,96(sp)
    80003d74:	eca6                	sd	s1,88(sp)
    80003d76:	e8ca                	sd	s2,80(sp)
    80003d78:	e4ce                	sd	s3,72(sp)
    80003d7a:	e0d2                	sd	s4,64(sp)
    80003d7c:	fc56                	sd	s5,56(sp)
    80003d7e:	f85a                	sd	s6,48(sp)
    80003d80:	f45e                	sd	s7,40(sp)
    80003d82:	f062                	sd	s8,32(sp)
    80003d84:	ec66                	sd	s9,24(sp)
    80003d86:	e86a                	sd	s10,16(sp)
    80003d88:	e46e                	sd	s11,8(sp)
    80003d8a:	1880                	addi	s0,sp,112
    80003d8c:	8b2a                	mv	s6,a0
    80003d8e:	8bae                	mv	s7,a1
    80003d90:	8a32                	mv	s4,a2
    80003d92:	84b6                	mv	s1,a3
    80003d94:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003d96:	9f35                	addw	a4,a4,a3
    return 0;
    80003d98:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003d9a:	0ad76063          	bltu	a4,a3,80003e3a <readi+0xd2>
  if(off + n > ip->size)
    80003d9e:	00e7f463          	bgeu	a5,a4,80003da6 <readi+0x3e>
    n = ip->size - off;
    80003da2:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003da6:	0a0a8963          	beqz	s5,80003e58 <readi+0xf0>
    80003daa:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003dac:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003db0:	5c7d                	li	s8,-1
    80003db2:	a82d                	j	80003dec <readi+0x84>
    80003db4:	020d1d93          	slli	s11,s10,0x20
    80003db8:	020ddd93          	srli	s11,s11,0x20
    80003dbc:	05890613          	addi	a2,s2,88
    80003dc0:	86ee                	mv	a3,s11
    80003dc2:	963a                	add	a2,a2,a4
    80003dc4:	85d2                	mv	a1,s4
    80003dc6:	855e                	mv	a0,s7
    80003dc8:	fffff097          	auipc	ra,0xfffff
    80003dcc:	896080e7          	jalr	-1898(ra) # 8000265e <either_copyout>
    80003dd0:	05850d63          	beq	a0,s8,80003e2a <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003dd4:	854a                	mv	a0,s2
    80003dd6:	fffff097          	auipc	ra,0xfffff
    80003dda:	5f4080e7          	jalr	1524(ra) # 800033ca <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003dde:	013d09bb          	addw	s3,s10,s3
    80003de2:	009d04bb          	addw	s1,s10,s1
    80003de6:	9a6e                	add	s4,s4,s11
    80003de8:	0559f763          	bgeu	s3,s5,80003e36 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003dec:	00a4d59b          	srliw	a1,s1,0xa
    80003df0:	855a                	mv	a0,s6
    80003df2:	00000097          	auipc	ra,0x0
    80003df6:	8a2080e7          	jalr	-1886(ra) # 80003694 <bmap>
    80003dfa:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003dfe:	cd85                	beqz	a1,80003e36 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003e00:	000b2503          	lw	a0,0(s6)
    80003e04:	fffff097          	auipc	ra,0xfffff
    80003e08:	496080e7          	jalr	1174(ra) # 8000329a <bread>
    80003e0c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e0e:	3ff4f713          	andi	a4,s1,1023
    80003e12:	40ec87bb          	subw	a5,s9,a4
    80003e16:	413a86bb          	subw	a3,s5,s3
    80003e1a:	8d3e                	mv	s10,a5
    80003e1c:	2781                	sext.w	a5,a5
    80003e1e:	0006861b          	sext.w	a2,a3
    80003e22:	f8f679e3          	bgeu	a2,a5,80003db4 <readi+0x4c>
    80003e26:	8d36                	mv	s10,a3
    80003e28:	b771                	j	80003db4 <readi+0x4c>
      brelse(bp);
    80003e2a:	854a                	mv	a0,s2
    80003e2c:	fffff097          	auipc	ra,0xfffff
    80003e30:	59e080e7          	jalr	1438(ra) # 800033ca <brelse>
      tot = -1;
    80003e34:	59fd                	li	s3,-1
  }
  return tot;
    80003e36:	0009851b          	sext.w	a0,s3
}
    80003e3a:	70a6                	ld	ra,104(sp)
    80003e3c:	7406                	ld	s0,96(sp)
    80003e3e:	64e6                	ld	s1,88(sp)
    80003e40:	6946                	ld	s2,80(sp)
    80003e42:	69a6                	ld	s3,72(sp)
    80003e44:	6a06                	ld	s4,64(sp)
    80003e46:	7ae2                	ld	s5,56(sp)
    80003e48:	7b42                	ld	s6,48(sp)
    80003e4a:	7ba2                	ld	s7,40(sp)
    80003e4c:	7c02                	ld	s8,32(sp)
    80003e4e:	6ce2                	ld	s9,24(sp)
    80003e50:	6d42                	ld	s10,16(sp)
    80003e52:	6da2                	ld	s11,8(sp)
    80003e54:	6165                	addi	sp,sp,112
    80003e56:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e58:	89d6                	mv	s3,s5
    80003e5a:	bff1                	j	80003e36 <readi+0xce>
    return 0;
    80003e5c:	4501                	li	a0,0
}
    80003e5e:	8082                	ret

0000000080003e60 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003e60:	457c                	lw	a5,76(a0)
    80003e62:	10d7e863          	bltu	a5,a3,80003f72 <writei+0x112>
{
    80003e66:	7159                	addi	sp,sp,-112
    80003e68:	f486                	sd	ra,104(sp)
    80003e6a:	f0a2                	sd	s0,96(sp)
    80003e6c:	eca6                	sd	s1,88(sp)
    80003e6e:	e8ca                	sd	s2,80(sp)
    80003e70:	e4ce                	sd	s3,72(sp)
    80003e72:	e0d2                	sd	s4,64(sp)
    80003e74:	fc56                	sd	s5,56(sp)
    80003e76:	f85a                	sd	s6,48(sp)
    80003e78:	f45e                	sd	s7,40(sp)
    80003e7a:	f062                	sd	s8,32(sp)
    80003e7c:	ec66                	sd	s9,24(sp)
    80003e7e:	e86a                	sd	s10,16(sp)
    80003e80:	e46e                	sd	s11,8(sp)
    80003e82:	1880                	addi	s0,sp,112
    80003e84:	8aaa                	mv	s5,a0
    80003e86:	8bae                	mv	s7,a1
    80003e88:	8a32                	mv	s4,a2
    80003e8a:	8936                	mv	s2,a3
    80003e8c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003e8e:	00e687bb          	addw	a5,a3,a4
    80003e92:	0ed7e263          	bltu	a5,a3,80003f76 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003e96:	00043737          	lui	a4,0x43
    80003e9a:	0ef76063          	bltu	a4,a5,80003f7a <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e9e:	0c0b0863          	beqz	s6,80003f6e <writei+0x10e>
    80003ea2:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ea4:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003ea8:	5c7d                	li	s8,-1
    80003eaa:	a091                	j	80003eee <writei+0x8e>
    80003eac:	020d1d93          	slli	s11,s10,0x20
    80003eb0:	020ddd93          	srli	s11,s11,0x20
    80003eb4:	05848513          	addi	a0,s1,88
    80003eb8:	86ee                	mv	a3,s11
    80003eba:	8652                	mv	a2,s4
    80003ebc:	85de                	mv	a1,s7
    80003ebe:	953a                	add	a0,a0,a4
    80003ec0:	ffffe097          	auipc	ra,0xffffe
    80003ec4:	7f4080e7          	jalr	2036(ra) # 800026b4 <either_copyin>
    80003ec8:	07850263          	beq	a0,s8,80003f2c <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003ecc:	8526                	mv	a0,s1
    80003ece:	00000097          	auipc	ra,0x0
    80003ed2:	780080e7          	jalr	1920(ra) # 8000464e <log_write>
    brelse(bp);
    80003ed6:	8526                	mv	a0,s1
    80003ed8:	fffff097          	auipc	ra,0xfffff
    80003edc:	4f2080e7          	jalr	1266(ra) # 800033ca <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ee0:	013d09bb          	addw	s3,s10,s3
    80003ee4:	012d093b          	addw	s2,s10,s2
    80003ee8:	9a6e                	add	s4,s4,s11
    80003eea:	0569f663          	bgeu	s3,s6,80003f36 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003eee:	00a9559b          	srliw	a1,s2,0xa
    80003ef2:	8556                	mv	a0,s5
    80003ef4:	fffff097          	auipc	ra,0xfffff
    80003ef8:	7a0080e7          	jalr	1952(ra) # 80003694 <bmap>
    80003efc:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003f00:	c99d                	beqz	a1,80003f36 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003f02:	000aa503          	lw	a0,0(s5)
    80003f06:	fffff097          	auipc	ra,0xfffff
    80003f0a:	394080e7          	jalr	916(ra) # 8000329a <bread>
    80003f0e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f10:	3ff97713          	andi	a4,s2,1023
    80003f14:	40ec87bb          	subw	a5,s9,a4
    80003f18:	413b06bb          	subw	a3,s6,s3
    80003f1c:	8d3e                	mv	s10,a5
    80003f1e:	2781                	sext.w	a5,a5
    80003f20:	0006861b          	sext.w	a2,a3
    80003f24:	f8f674e3          	bgeu	a2,a5,80003eac <writei+0x4c>
    80003f28:	8d36                	mv	s10,a3
    80003f2a:	b749                	j	80003eac <writei+0x4c>
      brelse(bp);
    80003f2c:	8526                	mv	a0,s1
    80003f2e:	fffff097          	auipc	ra,0xfffff
    80003f32:	49c080e7          	jalr	1180(ra) # 800033ca <brelse>
  }

  if(off > ip->size)
    80003f36:	04caa783          	lw	a5,76(s5)
    80003f3a:	0127f463          	bgeu	a5,s2,80003f42 <writei+0xe2>
    ip->size = off;
    80003f3e:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003f42:	8556                	mv	a0,s5
    80003f44:	00000097          	auipc	ra,0x0
    80003f48:	aa6080e7          	jalr	-1370(ra) # 800039ea <iupdate>

  return tot;
    80003f4c:	0009851b          	sext.w	a0,s3
}
    80003f50:	70a6                	ld	ra,104(sp)
    80003f52:	7406                	ld	s0,96(sp)
    80003f54:	64e6                	ld	s1,88(sp)
    80003f56:	6946                	ld	s2,80(sp)
    80003f58:	69a6                	ld	s3,72(sp)
    80003f5a:	6a06                	ld	s4,64(sp)
    80003f5c:	7ae2                	ld	s5,56(sp)
    80003f5e:	7b42                	ld	s6,48(sp)
    80003f60:	7ba2                	ld	s7,40(sp)
    80003f62:	7c02                	ld	s8,32(sp)
    80003f64:	6ce2                	ld	s9,24(sp)
    80003f66:	6d42                	ld	s10,16(sp)
    80003f68:	6da2                	ld	s11,8(sp)
    80003f6a:	6165                	addi	sp,sp,112
    80003f6c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f6e:	89da                	mv	s3,s6
    80003f70:	bfc9                	j	80003f42 <writei+0xe2>
    return -1;
    80003f72:	557d                	li	a0,-1
}
    80003f74:	8082                	ret
    return -1;
    80003f76:	557d                	li	a0,-1
    80003f78:	bfe1                	j	80003f50 <writei+0xf0>
    return -1;
    80003f7a:	557d                	li	a0,-1
    80003f7c:	bfd1                	j	80003f50 <writei+0xf0>

0000000080003f7e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003f7e:	1141                	addi	sp,sp,-16
    80003f80:	e406                	sd	ra,8(sp)
    80003f82:	e022                	sd	s0,0(sp)
    80003f84:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003f86:	4639                	li	a2,14
    80003f88:	ffffd097          	auipc	ra,0xffffd
    80003f8c:	e36080e7          	jalr	-458(ra) # 80000dbe <strncmp>
}
    80003f90:	60a2                	ld	ra,8(sp)
    80003f92:	6402                	ld	s0,0(sp)
    80003f94:	0141                	addi	sp,sp,16
    80003f96:	8082                	ret

0000000080003f98 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003f98:	7139                	addi	sp,sp,-64
    80003f9a:	fc06                	sd	ra,56(sp)
    80003f9c:	f822                	sd	s0,48(sp)
    80003f9e:	f426                	sd	s1,40(sp)
    80003fa0:	f04a                	sd	s2,32(sp)
    80003fa2:	ec4e                	sd	s3,24(sp)
    80003fa4:	e852                	sd	s4,16(sp)
    80003fa6:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003fa8:	04451703          	lh	a4,68(a0)
    80003fac:	4785                	li	a5,1
    80003fae:	00f71a63          	bne	a4,a5,80003fc2 <dirlookup+0x2a>
    80003fb2:	892a                	mv	s2,a0
    80003fb4:	89ae                	mv	s3,a1
    80003fb6:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fb8:	457c                	lw	a5,76(a0)
    80003fba:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003fbc:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fbe:	e79d                	bnez	a5,80003fec <dirlookup+0x54>
    80003fc0:	a8a5                	j	80004038 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003fc2:	00004517          	auipc	a0,0x4
    80003fc6:	7b650513          	addi	a0,a0,1974 # 80008778 <syscallnum+0x158>
    80003fca:	ffffc097          	auipc	ra,0xffffc
    80003fce:	57a080e7          	jalr	1402(ra) # 80000544 <panic>
      panic("dirlookup read");
    80003fd2:	00004517          	auipc	a0,0x4
    80003fd6:	7be50513          	addi	a0,a0,1982 # 80008790 <syscallnum+0x170>
    80003fda:	ffffc097          	auipc	ra,0xffffc
    80003fde:	56a080e7          	jalr	1386(ra) # 80000544 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fe2:	24c1                	addiw	s1,s1,16
    80003fe4:	04c92783          	lw	a5,76(s2)
    80003fe8:	04f4f763          	bgeu	s1,a5,80004036 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fec:	4741                	li	a4,16
    80003fee:	86a6                	mv	a3,s1
    80003ff0:	fc040613          	addi	a2,s0,-64
    80003ff4:	4581                	li	a1,0
    80003ff6:	854a                	mv	a0,s2
    80003ff8:	00000097          	auipc	ra,0x0
    80003ffc:	d70080e7          	jalr	-656(ra) # 80003d68 <readi>
    80004000:	47c1                	li	a5,16
    80004002:	fcf518e3          	bne	a0,a5,80003fd2 <dirlookup+0x3a>
    if(de.inum == 0)
    80004006:	fc045783          	lhu	a5,-64(s0)
    8000400a:	dfe1                	beqz	a5,80003fe2 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000400c:	fc240593          	addi	a1,s0,-62
    80004010:	854e                	mv	a0,s3
    80004012:	00000097          	auipc	ra,0x0
    80004016:	f6c080e7          	jalr	-148(ra) # 80003f7e <namecmp>
    8000401a:	f561                	bnez	a0,80003fe2 <dirlookup+0x4a>
      if(poff)
    8000401c:	000a0463          	beqz	s4,80004024 <dirlookup+0x8c>
        *poff = off;
    80004020:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004024:	fc045583          	lhu	a1,-64(s0)
    80004028:	00092503          	lw	a0,0(s2)
    8000402c:	fffff097          	auipc	ra,0xfffff
    80004030:	750080e7          	jalr	1872(ra) # 8000377c <iget>
    80004034:	a011                	j	80004038 <dirlookup+0xa0>
  return 0;
    80004036:	4501                	li	a0,0
}
    80004038:	70e2                	ld	ra,56(sp)
    8000403a:	7442                	ld	s0,48(sp)
    8000403c:	74a2                	ld	s1,40(sp)
    8000403e:	7902                	ld	s2,32(sp)
    80004040:	69e2                	ld	s3,24(sp)
    80004042:	6a42                	ld	s4,16(sp)
    80004044:	6121                	addi	sp,sp,64
    80004046:	8082                	ret

0000000080004048 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004048:	711d                	addi	sp,sp,-96
    8000404a:	ec86                	sd	ra,88(sp)
    8000404c:	e8a2                	sd	s0,80(sp)
    8000404e:	e4a6                	sd	s1,72(sp)
    80004050:	e0ca                	sd	s2,64(sp)
    80004052:	fc4e                	sd	s3,56(sp)
    80004054:	f852                	sd	s4,48(sp)
    80004056:	f456                	sd	s5,40(sp)
    80004058:	f05a                	sd	s6,32(sp)
    8000405a:	ec5e                	sd	s7,24(sp)
    8000405c:	e862                	sd	s8,16(sp)
    8000405e:	e466                	sd	s9,8(sp)
    80004060:	1080                	addi	s0,sp,96
    80004062:	84aa                	mv	s1,a0
    80004064:	8b2e                	mv	s6,a1
    80004066:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004068:	00054703          	lbu	a4,0(a0)
    8000406c:	02f00793          	li	a5,47
    80004070:	02f70363          	beq	a4,a5,80004096 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004074:	ffffe097          	auipc	ra,0xffffe
    80004078:	952080e7          	jalr	-1710(ra) # 800019c6 <myproc>
    8000407c:	15053503          	ld	a0,336(a0)
    80004080:	00000097          	auipc	ra,0x0
    80004084:	9f6080e7          	jalr	-1546(ra) # 80003a76 <idup>
    80004088:	89aa                	mv	s3,a0
  while(*path == '/')
    8000408a:	02f00913          	li	s2,47
  len = path - s;
    8000408e:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80004090:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004092:	4c05                	li	s8,1
    80004094:	a865                	j	8000414c <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004096:	4585                	li	a1,1
    80004098:	4505                	li	a0,1
    8000409a:	fffff097          	auipc	ra,0xfffff
    8000409e:	6e2080e7          	jalr	1762(ra) # 8000377c <iget>
    800040a2:	89aa                	mv	s3,a0
    800040a4:	b7dd                	j	8000408a <namex+0x42>
      iunlockput(ip);
    800040a6:	854e                	mv	a0,s3
    800040a8:	00000097          	auipc	ra,0x0
    800040ac:	c6e080e7          	jalr	-914(ra) # 80003d16 <iunlockput>
      return 0;
    800040b0:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800040b2:	854e                	mv	a0,s3
    800040b4:	60e6                	ld	ra,88(sp)
    800040b6:	6446                	ld	s0,80(sp)
    800040b8:	64a6                	ld	s1,72(sp)
    800040ba:	6906                	ld	s2,64(sp)
    800040bc:	79e2                	ld	s3,56(sp)
    800040be:	7a42                	ld	s4,48(sp)
    800040c0:	7aa2                	ld	s5,40(sp)
    800040c2:	7b02                	ld	s6,32(sp)
    800040c4:	6be2                	ld	s7,24(sp)
    800040c6:	6c42                	ld	s8,16(sp)
    800040c8:	6ca2                	ld	s9,8(sp)
    800040ca:	6125                	addi	sp,sp,96
    800040cc:	8082                	ret
      iunlock(ip);
    800040ce:	854e                	mv	a0,s3
    800040d0:	00000097          	auipc	ra,0x0
    800040d4:	aa6080e7          	jalr	-1370(ra) # 80003b76 <iunlock>
      return ip;
    800040d8:	bfe9                	j	800040b2 <namex+0x6a>
      iunlockput(ip);
    800040da:	854e                	mv	a0,s3
    800040dc:	00000097          	auipc	ra,0x0
    800040e0:	c3a080e7          	jalr	-966(ra) # 80003d16 <iunlockput>
      return 0;
    800040e4:	89d2                	mv	s3,s4
    800040e6:	b7f1                	j	800040b2 <namex+0x6a>
  len = path - s;
    800040e8:	40b48633          	sub	a2,s1,a1
    800040ec:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    800040f0:	094cd463          	bge	s9,s4,80004178 <namex+0x130>
    memmove(name, s, DIRSIZ);
    800040f4:	4639                	li	a2,14
    800040f6:	8556                	mv	a0,s5
    800040f8:	ffffd097          	auipc	ra,0xffffd
    800040fc:	c4e080e7          	jalr	-946(ra) # 80000d46 <memmove>
  while(*path == '/')
    80004100:	0004c783          	lbu	a5,0(s1)
    80004104:	01279763          	bne	a5,s2,80004112 <namex+0xca>
    path++;
    80004108:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000410a:	0004c783          	lbu	a5,0(s1)
    8000410e:	ff278de3          	beq	a5,s2,80004108 <namex+0xc0>
    ilock(ip);
    80004112:	854e                	mv	a0,s3
    80004114:	00000097          	auipc	ra,0x0
    80004118:	9a0080e7          	jalr	-1632(ra) # 80003ab4 <ilock>
    if(ip->type != T_DIR){
    8000411c:	04499783          	lh	a5,68(s3)
    80004120:	f98793e3          	bne	a5,s8,800040a6 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004124:	000b0563          	beqz	s6,8000412e <namex+0xe6>
    80004128:	0004c783          	lbu	a5,0(s1)
    8000412c:	d3cd                	beqz	a5,800040ce <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000412e:	865e                	mv	a2,s7
    80004130:	85d6                	mv	a1,s5
    80004132:	854e                	mv	a0,s3
    80004134:	00000097          	auipc	ra,0x0
    80004138:	e64080e7          	jalr	-412(ra) # 80003f98 <dirlookup>
    8000413c:	8a2a                	mv	s4,a0
    8000413e:	dd51                	beqz	a0,800040da <namex+0x92>
    iunlockput(ip);
    80004140:	854e                	mv	a0,s3
    80004142:	00000097          	auipc	ra,0x0
    80004146:	bd4080e7          	jalr	-1068(ra) # 80003d16 <iunlockput>
    ip = next;
    8000414a:	89d2                	mv	s3,s4
  while(*path == '/')
    8000414c:	0004c783          	lbu	a5,0(s1)
    80004150:	05279763          	bne	a5,s2,8000419e <namex+0x156>
    path++;
    80004154:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004156:	0004c783          	lbu	a5,0(s1)
    8000415a:	ff278de3          	beq	a5,s2,80004154 <namex+0x10c>
  if(*path == 0)
    8000415e:	c79d                	beqz	a5,8000418c <namex+0x144>
    path++;
    80004160:	85a6                	mv	a1,s1
  len = path - s;
    80004162:	8a5e                	mv	s4,s7
    80004164:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80004166:	01278963          	beq	a5,s2,80004178 <namex+0x130>
    8000416a:	dfbd                	beqz	a5,800040e8 <namex+0xa0>
    path++;
    8000416c:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000416e:	0004c783          	lbu	a5,0(s1)
    80004172:	ff279ce3          	bne	a5,s2,8000416a <namex+0x122>
    80004176:	bf8d                	j	800040e8 <namex+0xa0>
    memmove(name, s, len);
    80004178:	2601                	sext.w	a2,a2
    8000417a:	8556                	mv	a0,s5
    8000417c:	ffffd097          	auipc	ra,0xffffd
    80004180:	bca080e7          	jalr	-1078(ra) # 80000d46 <memmove>
    name[len] = 0;
    80004184:	9a56                	add	s4,s4,s5
    80004186:	000a0023          	sb	zero,0(s4)
    8000418a:	bf9d                	j	80004100 <namex+0xb8>
  if(nameiparent){
    8000418c:	f20b03e3          	beqz	s6,800040b2 <namex+0x6a>
    iput(ip);
    80004190:	854e                	mv	a0,s3
    80004192:	00000097          	auipc	ra,0x0
    80004196:	adc080e7          	jalr	-1316(ra) # 80003c6e <iput>
    return 0;
    8000419a:	4981                	li	s3,0
    8000419c:	bf19                	j	800040b2 <namex+0x6a>
  if(*path == 0)
    8000419e:	d7fd                	beqz	a5,8000418c <namex+0x144>
  while(*path != '/' && *path != 0)
    800041a0:	0004c783          	lbu	a5,0(s1)
    800041a4:	85a6                	mv	a1,s1
    800041a6:	b7d1                	j	8000416a <namex+0x122>

00000000800041a8 <dirlink>:
{
    800041a8:	7139                	addi	sp,sp,-64
    800041aa:	fc06                	sd	ra,56(sp)
    800041ac:	f822                	sd	s0,48(sp)
    800041ae:	f426                	sd	s1,40(sp)
    800041b0:	f04a                	sd	s2,32(sp)
    800041b2:	ec4e                	sd	s3,24(sp)
    800041b4:	e852                	sd	s4,16(sp)
    800041b6:	0080                	addi	s0,sp,64
    800041b8:	892a                	mv	s2,a0
    800041ba:	8a2e                	mv	s4,a1
    800041bc:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800041be:	4601                	li	a2,0
    800041c0:	00000097          	auipc	ra,0x0
    800041c4:	dd8080e7          	jalr	-552(ra) # 80003f98 <dirlookup>
    800041c8:	e93d                	bnez	a0,8000423e <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041ca:	04c92483          	lw	s1,76(s2)
    800041ce:	c49d                	beqz	s1,800041fc <dirlink+0x54>
    800041d0:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041d2:	4741                	li	a4,16
    800041d4:	86a6                	mv	a3,s1
    800041d6:	fc040613          	addi	a2,s0,-64
    800041da:	4581                	li	a1,0
    800041dc:	854a                	mv	a0,s2
    800041de:	00000097          	auipc	ra,0x0
    800041e2:	b8a080e7          	jalr	-1142(ra) # 80003d68 <readi>
    800041e6:	47c1                	li	a5,16
    800041e8:	06f51163          	bne	a0,a5,8000424a <dirlink+0xa2>
    if(de.inum == 0)
    800041ec:	fc045783          	lhu	a5,-64(s0)
    800041f0:	c791                	beqz	a5,800041fc <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041f2:	24c1                	addiw	s1,s1,16
    800041f4:	04c92783          	lw	a5,76(s2)
    800041f8:	fcf4ede3          	bltu	s1,a5,800041d2 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800041fc:	4639                	li	a2,14
    800041fe:	85d2                	mv	a1,s4
    80004200:	fc240513          	addi	a0,s0,-62
    80004204:	ffffd097          	auipc	ra,0xffffd
    80004208:	bf6080e7          	jalr	-1034(ra) # 80000dfa <strncpy>
  de.inum = inum;
    8000420c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004210:	4741                	li	a4,16
    80004212:	86a6                	mv	a3,s1
    80004214:	fc040613          	addi	a2,s0,-64
    80004218:	4581                	li	a1,0
    8000421a:	854a                	mv	a0,s2
    8000421c:	00000097          	auipc	ra,0x0
    80004220:	c44080e7          	jalr	-956(ra) # 80003e60 <writei>
    80004224:	1541                	addi	a0,a0,-16
    80004226:	00a03533          	snez	a0,a0
    8000422a:	40a00533          	neg	a0,a0
}
    8000422e:	70e2                	ld	ra,56(sp)
    80004230:	7442                	ld	s0,48(sp)
    80004232:	74a2                	ld	s1,40(sp)
    80004234:	7902                	ld	s2,32(sp)
    80004236:	69e2                	ld	s3,24(sp)
    80004238:	6a42                	ld	s4,16(sp)
    8000423a:	6121                	addi	sp,sp,64
    8000423c:	8082                	ret
    iput(ip);
    8000423e:	00000097          	auipc	ra,0x0
    80004242:	a30080e7          	jalr	-1488(ra) # 80003c6e <iput>
    return -1;
    80004246:	557d                	li	a0,-1
    80004248:	b7dd                	j	8000422e <dirlink+0x86>
      panic("dirlink read");
    8000424a:	00004517          	auipc	a0,0x4
    8000424e:	55650513          	addi	a0,a0,1366 # 800087a0 <syscallnum+0x180>
    80004252:	ffffc097          	auipc	ra,0xffffc
    80004256:	2f2080e7          	jalr	754(ra) # 80000544 <panic>

000000008000425a <namei>:

struct inode*
namei(char *path)
{
    8000425a:	1101                	addi	sp,sp,-32
    8000425c:	ec06                	sd	ra,24(sp)
    8000425e:	e822                	sd	s0,16(sp)
    80004260:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004262:	fe040613          	addi	a2,s0,-32
    80004266:	4581                	li	a1,0
    80004268:	00000097          	auipc	ra,0x0
    8000426c:	de0080e7          	jalr	-544(ra) # 80004048 <namex>
}
    80004270:	60e2                	ld	ra,24(sp)
    80004272:	6442                	ld	s0,16(sp)
    80004274:	6105                	addi	sp,sp,32
    80004276:	8082                	ret

0000000080004278 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004278:	1141                	addi	sp,sp,-16
    8000427a:	e406                	sd	ra,8(sp)
    8000427c:	e022                	sd	s0,0(sp)
    8000427e:	0800                	addi	s0,sp,16
    80004280:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004282:	4585                	li	a1,1
    80004284:	00000097          	auipc	ra,0x0
    80004288:	dc4080e7          	jalr	-572(ra) # 80004048 <namex>
}
    8000428c:	60a2                	ld	ra,8(sp)
    8000428e:	6402                	ld	s0,0(sp)
    80004290:	0141                	addi	sp,sp,16
    80004292:	8082                	ret

0000000080004294 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004294:	1101                	addi	sp,sp,-32
    80004296:	ec06                	sd	ra,24(sp)
    80004298:	e822                	sd	s0,16(sp)
    8000429a:	e426                	sd	s1,8(sp)
    8000429c:	e04a                	sd	s2,0(sp)
    8000429e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800042a0:	0001e917          	auipc	s2,0x1e
    800042a4:	eb090913          	addi	s2,s2,-336 # 80022150 <log>
    800042a8:	01892583          	lw	a1,24(s2)
    800042ac:	02892503          	lw	a0,40(s2)
    800042b0:	fffff097          	auipc	ra,0xfffff
    800042b4:	fea080e7          	jalr	-22(ra) # 8000329a <bread>
    800042b8:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800042ba:	02c92683          	lw	a3,44(s2)
    800042be:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800042c0:	02d05763          	blez	a3,800042ee <write_head+0x5a>
    800042c4:	0001e797          	auipc	a5,0x1e
    800042c8:	ebc78793          	addi	a5,a5,-324 # 80022180 <log+0x30>
    800042cc:	05c50713          	addi	a4,a0,92
    800042d0:	36fd                	addiw	a3,a3,-1
    800042d2:	1682                	slli	a3,a3,0x20
    800042d4:	9281                	srli	a3,a3,0x20
    800042d6:	068a                	slli	a3,a3,0x2
    800042d8:	0001e617          	auipc	a2,0x1e
    800042dc:	eac60613          	addi	a2,a2,-340 # 80022184 <log+0x34>
    800042e0:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800042e2:	4390                	lw	a2,0(a5)
    800042e4:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800042e6:	0791                	addi	a5,a5,4
    800042e8:	0711                	addi	a4,a4,4
    800042ea:	fed79ce3          	bne	a5,a3,800042e2 <write_head+0x4e>
  }
  bwrite(buf);
    800042ee:	8526                	mv	a0,s1
    800042f0:	fffff097          	auipc	ra,0xfffff
    800042f4:	09c080e7          	jalr	156(ra) # 8000338c <bwrite>
  brelse(buf);
    800042f8:	8526                	mv	a0,s1
    800042fa:	fffff097          	auipc	ra,0xfffff
    800042fe:	0d0080e7          	jalr	208(ra) # 800033ca <brelse>
}
    80004302:	60e2                	ld	ra,24(sp)
    80004304:	6442                	ld	s0,16(sp)
    80004306:	64a2                	ld	s1,8(sp)
    80004308:	6902                	ld	s2,0(sp)
    8000430a:	6105                	addi	sp,sp,32
    8000430c:	8082                	ret

000000008000430e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000430e:	0001e797          	auipc	a5,0x1e
    80004312:	e6e7a783          	lw	a5,-402(a5) # 8002217c <log+0x2c>
    80004316:	0af05d63          	blez	a5,800043d0 <install_trans+0xc2>
{
    8000431a:	7139                	addi	sp,sp,-64
    8000431c:	fc06                	sd	ra,56(sp)
    8000431e:	f822                	sd	s0,48(sp)
    80004320:	f426                	sd	s1,40(sp)
    80004322:	f04a                	sd	s2,32(sp)
    80004324:	ec4e                	sd	s3,24(sp)
    80004326:	e852                	sd	s4,16(sp)
    80004328:	e456                	sd	s5,8(sp)
    8000432a:	e05a                	sd	s6,0(sp)
    8000432c:	0080                	addi	s0,sp,64
    8000432e:	8b2a                	mv	s6,a0
    80004330:	0001ea97          	auipc	s5,0x1e
    80004334:	e50a8a93          	addi	s5,s5,-432 # 80022180 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004338:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000433a:	0001e997          	auipc	s3,0x1e
    8000433e:	e1698993          	addi	s3,s3,-490 # 80022150 <log>
    80004342:	a035                	j	8000436e <install_trans+0x60>
      bunpin(dbuf);
    80004344:	8526                	mv	a0,s1
    80004346:	fffff097          	auipc	ra,0xfffff
    8000434a:	15e080e7          	jalr	350(ra) # 800034a4 <bunpin>
    brelse(lbuf);
    8000434e:	854a                	mv	a0,s2
    80004350:	fffff097          	auipc	ra,0xfffff
    80004354:	07a080e7          	jalr	122(ra) # 800033ca <brelse>
    brelse(dbuf);
    80004358:	8526                	mv	a0,s1
    8000435a:	fffff097          	auipc	ra,0xfffff
    8000435e:	070080e7          	jalr	112(ra) # 800033ca <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004362:	2a05                	addiw	s4,s4,1
    80004364:	0a91                	addi	s5,s5,4
    80004366:	02c9a783          	lw	a5,44(s3)
    8000436a:	04fa5963          	bge	s4,a5,800043bc <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000436e:	0189a583          	lw	a1,24(s3)
    80004372:	014585bb          	addw	a1,a1,s4
    80004376:	2585                	addiw	a1,a1,1
    80004378:	0289a503          	lw	a0,40(s3)
    8000437c:	fffff097          	auipc	ra,0xfffff
    80004380:	f1e080e7          	jalr	-226(ra) # 8000329a <bread>
    80004384:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004386:	000aa583          	lw	a1,0(s5)
    8000438a:	0289a503          	lw	a0,40(s3)
    8000438e:	fffff097          	auipc	ra,0xfffff
    80004392:	f0c080e7          	jalr	-244(ra) # 8000329a <bread>
    80004396:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004398:	40000613          	li	a2,1024
    8000439c:	05890593          	addi	a1,s2,88
    800043a0:	05850513          	addi	a0,a0,88
    800043a4:	ffffd097          	auipc	ra,0xffffd
    800043a8:	9a2080e7          	jalr	-1630(ra) # 80000d46 <memmove>
    bwrite(dbuf);  // write dst to disk
    800043ac:	8526                	mv	a0,s1
    800043ae:	fffff097          	auipc	ra,0xfffff
    800043b2:	fde080e7          	jalr	-34(ra) # 8000338c <bwrite>
    if(recovering == 0)
    800043b6:	f80b1ce3          	bnez	s6,8000434e <install_trans+0x40>
    800043ba:	b769                	j	80004344 <install_trans+0x36>
}
    800043bc:	70e2                	ld	ra,56(sp)
    800043be:	7442                	ld	s0,48(sp)
    800043c0:	74a2                	ld	s1,40(sp)
    800043c2:	7902                	ld	s2,32(sp)
    800043c4:	69e2                	ld	s3,24(sp)
    800043c6:	6a42                	ld	s4,16(sp)
    800043c8:	6aa2                	ld	s5,8(sp)
    800043ca:	6b02                	ld	s6,0(sp)
    800043cc:	6121                	addi	sp,sp,64
    800043ce:	8082                	ret
    800043d0:	8082                	ret

00000000800043d2 <initlog>:
{
    800043d2:	7179                	addi	sp,sp,-48
    800043d4:	f406                	sd	ra,40(sp)
    800043d6:	f022                	sd	s0,32(sp)
    800043d8:	ec26                	sd	s1,24(sp)
    800043da:	e84a                	sd	s2,16(sp)
    800043dc:	e44e                	sd	s3,8(sp)
    800043de:	1800                	addi	s0,sp,48
    800043e0:	892a                	mv	s2,a0
    800043e2:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800043e4:	0001e497          	auipc	s1,0x1e
    800043e8:	d6c48493          	addi	s1,s1,-660 # 80022150 <log>
    800043ec:	00004597          	auipc	a1,0x4
    800043f0:	3c458593          	addi	a1,a1,964 # 800087b0 <syscallnum+0x190>
    800043f4:	8526                	mv	a0,s1
    800043f6:	ffffc097          	auipc	ra,0xffffc
    800043fa:	764080e7          	jalr	1892(ra) # 80000b5a <initlock>
  log.start = sb->logstart;
    800043fe:	0149a583          	lw	a1,20(s3)
    80004402:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004404:	0109a783          	lw	a5,16(s3)
    80004408:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000440a:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000440e:	854a                	mv	a0,s2
    80004410:	fffff097          	auipc	ra,0xfffff
    80004414:	e8a080e7          	jalr	-374(ra) # 8000329a <bread>
  log.lh.n = lh->n;
    80004418:	4d3c                	lw	a5,88(a0)
    8000441a:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000441c:	02f05563          	blez	a5,80004446 <initlog+0x74>
    80004420:	05c50713          	addi	a4,a0,92
    80004424:	0001e697          	auipc	a3,0x1e
    80004428:	d5c68693          	addi	a3,a3,-676 # 80022180 <log+0x30>
    8000442c:	37fd                	addiw	a5,a5,-1
    8000442e:	1782                	slli	a5,a5,0x20
    80004430:	9381                	srli	a5,a5,0x20
    80004432:	078a                	slli	a5,a5,0x2
    80004434:	06050613          	addi	a2,a0,96
    80004438:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    8000443a:	4310                	lw	a2,0(a4)
    8000443c:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    8000443e:	0711                	addi	a4,a4,4
    80004440:	0691                	addi	a3,a3,4
    80004442:	fef71ce3          	bne	a4,a5,8000443a <initlog+0x68>
  brelse(buf);
    80004446:	fffff097          	auipc	ra,0xfffff
    8000444a:	f84080e7          	jalr	-124(ra) # 800033ca <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000444e:	4505                	li	a0,1
    80004450:	00000097          	auipc	ra,0x0
    80004454:	ebe080e7          	jalr	-322(ra) # 8000430e <install_trans>
  log.lh.n = 0;
    80004458:	0001e797          	auipc	a5,0x1e
    8000445c:	d207a223          	sw	zero,-732(a5) # 8002217c <log+0x2c>
  write_head(); // clear the log
    80004460:	00000097          	auipc	ra,0x0
    80004464:	e34080e7          	jalr	-460(ra) # 80004294 <write_head>
}
    80004468:	70a2                	ld	ra,40(sp)
    8000446a:	7402                	ld	s0,32(sp)
    8000446c:	64e2                	ld	s1,24(sp)
    8000446e:	6942                	ld	s2,16(sp)
    80004470:	69a2                	ld	s3,8(sp)
    80004472:	6145                	addi	sp,sp,48
    80004474:	8082                	ret

0000000080004476 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004476:	1101                	addi	sp,sp,-32
    80004478:	ec06                	sd	ra,24(sp)
    8000447a:	e822                	sd	s0,16(sp)
    8000447c:	e426                	sd	s1,8(sp)
    8000447e:	e04a                	sd	s2,0(sp)
    80004480:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004482:	0001e517          	auipc	a0,0x1e
    80004486:	cce50513          	addi	a0,a0,-818 # 80022150 <log>
    8000448a:	ffffc097          	auipc	ra,0xffffc
    8000448e:	760080e7          	jalr	1888(ra) # 80000bea <acquire>
  while(1){
    if(log.committing){
    80004492:	0001e497          	auipc	s1,0x1e
    80004496:	cbe48493          	addi	s1,s1,-834 # 80022150 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000449a:	4979                	li	s2,30
    8000449c:	a039                	j	800044aa <begin_op+0x34>
      sleep(&log, &log.lock);
    8000449e:	85a6                	mv	a1,s1
    800044a0:	8526                	mv	a0,s1
    800044a2:	ffffe097          	auipc	ra,0xffffe
    800044a6:	c5c080e7          	jalr	-932(ra) # 800020fe <sleep>
    if(log.committing){
    800044aa:	50dc                	lw	a5,36(s1)
    800044ac:	fbed                	bnez	a5,8000449e <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800044ae:	509c                	lw	a5,32(s1)
    800044b0:	0017871b          	addiw	a4,a5,1
    800044b4:	0007069b          	sext.w	a3,a4
    800044b8:	0027179b          	slliw	a5,a4,0x2
    800044bc:	9fb9                	addw	a5,a5,a4
    800044be:	0017979b          	slliw	a5,a5,0x1
    800044c2:	54d8                	lw	a4,44(s1)
    800044c4:	9fb9                	addw	a5,a5,a4
    800044c6:	00f95963          	bge	s2,a5,800044d8 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800044ca:	85a6                	mv	a1,s1
    800044cc:	8526                	mv	a0,s1
    800044ce:	ffffe097          	auipc	ra,0xffffe
    800044d2:	c30080e7          	jalr	-976(ra) # 800020fe <sleep>
    800044d6:	bfd1                	j	800044aa <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800044d8:	0001e517          	auipc	a0,0x1e
    800044dc:	c7850513          	addi	a0,a0,-904 # 80022150 <log>
    800044e0:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800044e2:	ffffc097          	auipc	ra,0xffffc
    800044e6:	7bc080e7          	jalr	1980(ra) # 80000c9e <release>
      break;
    }
  }
}
    800044ea:	60e2                	ld	ra,24(sp)
    800044ec:	6442                	ld	s0,16(sp)
    800044ee:	64a2                	ld	s1,8(sp)
    800044f0:	6902                	ld	s2,0(sp)
    800044f2:	6105                	addi	sp,sp,32
    800044f4:	8082                	ret

00000000800044f6 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800044f6:	7139                	addi	sp,sp,-64
    800044f8:	fc06                	sd	ra,56(sp)
    800044fa:	f822                	sd	s0,48(sp)
    800044fc:	f426                	sd	s1,40(sp)
    800044fe:	f04a                	sd	s2,32(sp)
    80004500:	ec4e                	sd	s3,24(sp)
    80004502:	e852                	sd	s4,16(sp)
    80004504:	e456                	sd	s5,8(sp)
    80004506:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004508:	0001e497          	auipc	s1,0x1e
    8000450c:	c4848493          	addi	s1,s1,-952 # 80022150 <log>
    80004510:	8526                	mv	a0,s1
    80004512:	ffffc097          	auipc	ra,0xffffc
    80004516:	6d8080e7          	jalr	1752(ra) # 80000bea <acquire>
  log.outstanding -= 1;
    8000451a:	509c                	lw	a5,32(s1)
    8000451c:	37fd                	addiw	a5,a5,-1
    8000451e:	0007891b          	sext.w	s2,a5
    80004522:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004524:	50dc                	lw	a5,36(s1)
    80004526:	efb9                	bnez	a5,80004584 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004528:	06091663          	bnez	s2,80004594 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    8000452c:	0001e497          	auipc	s1,0x1e
    80004530:	c2448493          	addi	s1,s1,-988 # 80022150 <log>
    80004534:	4785                	li	a5,1
    80004536:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004538:	8526                	mv	a0,s1
    8000453a:	ffffc097          	auipc	ra,0xffffc
    8000453e:	764080e7          	jalr	1892(ra) # 80000c9e <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004542:	54dc                	lw	a5,44(s1)
    80004544:	06f04763          	bgtz	a5,800045b2 <end_op+0xbc>
    acquire(&log.lock);
    80004548:	0001e497          	auipc	s1,0x1e
    8000454c:	c0848493          	addi	s1,s1,-1016 # 80022150 <log>
    80004550:	8526                	mv	a0,s1
    80004552:	ffffc097          	auipc	ra,0xffffc
    80004556:	698080e7          	jalr	1688(ra) # 80000bea <acquire>
    log.committing = 0;
    8000455a:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000455e:	8526                	mv	a0,s1
    80004560:	ffffe097          	auipc	ra,0xffffe
    80004564:	d4e080e7          	jalr	-690(ra) # 800022ae <wakeup>
    release(&log.lock);
    80004568:	8526                	mv	a0,s1
    8000456a:	ffffc097          	auipc	ra,0xffffc
    8000456e:	734080e7          	jalr	1844(ra) # 80000c9e <release>
}
    80004572:	70e2                	ld	ra,56(sp)
    80004574:	7442                	ld	s0,48(sp)
    80004576:	74a2                	ld	s1,40(sp)
    80004578:	7902                	ld	s2,32(sp)
    8000457a:	69e2                	ld	s3,24(sp)
    8000457c:	6a42                	ld	s4,16(sp)
    8000457e:	6aa2                	ld	s5,8(sp)
    80004580:	6121                	addi	sp,sp,64
    80004582:	8082                	ret
    panic("log.committing");
    80004584:	00004517          	auipc	a0,0x4
    80004588:	23450513          	addi	a0,a0,564 # 800087b8 <syscallnum+0x198>
    8000458c:	ffffc097          	auipc	ra,0xffffc
    80004590:	fb8080e7          	jalr	-72(ra) # 80000544 <panic>
    wakeup(&log);
    80004594:	0001e497          	auipc	s1,0x1e
    80004598:	bbc48493          	addi	s1,s1,-1092 # 80022150 <log>
    8000459c:	8526                	mv	a0,s1
    8000459e:	ffffe097          	auipc	ra,0xffffe
    800045a2:	d10080e7          	jalr	-752(ra) # 800022ae <wakeup>
  release(&log.lock);
    800045a6:	8526                	mv	a0,s1
    800045a8:	ffffc097          	auipc	ra,0xffffc
    800045ac:	6f6080e7          	jalr	1782(ra) # 80000c9e <release>
  if(do_commit){
    800045b0:	b7c9                	j	80004572 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800045b2:	0001ea97          	auipc	s5,0x1e
    800045b6:	bcea8a93          	addi	s5,s5,-1074 # 80022180 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800045ba:	0001ea17          	auipc	s4,0x1e
    800045be:	b96a0a13          	addi	s4,s4,-1130 # 80022150 <log>
    800045c2:	018a2583          	lw	a1,24(s4)
    800045c6:	012585bb          	addw	a1,a1,s2
    800045ca:	2585                	addiw	a1,a1,1
    800045cc:	028a2503          	lw	a0,40(s4)
    800045d0:	fffff097          	auipc	ra,0xfffff
    800045d4:	cca080e7          	jalr	-822(ra) # 8000329a <bread>
    800045d8:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800045da:	000aa583          	lw	a1,0(s5)
    800045de:	028a2503          	lw	a0,40(s4)
    800045e2:	fffff097          	auipc	ra,0xfffff
    800045e6:	cb8080e7          	jalr	-840(ra) # 8000329a <bread>
    800045ea:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800045ec:	40000613          	li	a2,1024
    800045f0:	05850593          	addi	a1,a0,88
    800045f4:	05848513          	addi	a0,s1,88
    800045f8:	ffffc097          	auipc	ra,0xffffc
    800045fc:	74e080e7          	jalr	1870(ra) # 80000d46 <memmove>
    bwrite(to);  // write the log
    80004600:	8526                	mv	a0,s1
    80004602:	fffff097          	auipc	ra,0xfffff
    80004606:	d8a080e7          	jalr	-630(ra) # 8000338c <bwrite>
    brelse(from);
    8000460a:	854e                	mv	a0,s3
    8000460c:	fffff097          	auipc	ra,0xfffff
    80004610:	dbe080e7          	jalr	-578(ra) # 800033ca <brelse>
    brelse(to);
    80004614:	8526                	mv	a0,s1
    80004616:	fffff097          	auipc	ra,0xfffff
    8000461a:	db4080e7          	jalr	-588(ra) # 800033ca <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000461e:	2905                	addiw	s2,s2,1
    80004620:	0a91                	addi	s5,s5,4
    80004622:	02ca2783          	lw	a5,44(s4)
    80004626:	f8f94ee3          	blt	s2,a5,800045c2 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000462a:	00000097          	auipc	ra,0x0
    8000462e:	c6a080e7          	jalr	-918(ra) # 80004294 <write_head>
    install_trans(0); // Now install writes to home locations
    80004632:	4501                	li	a0,0
    80004634:	00000097          	auipc	ra,0x0
    80004638:	cda080e7          	jalr	-806(ra) # 8000430e <install_trans>
    log.lh.n = 0;
    8000463c:	0001e797          	auipc	a5,0x1e
    80004640:	b407a023          	sw	zero,-1216(a5) # 8002217c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004644:	00000097          	auipc	ra,0x0
    80004648:	c50080e7          	jalr	-944(ra) # 80004294 <write_head>
    8000464c:	bdf5                	j	80004548 <end_op+0x52>

000000008000464e <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000464e:	1101                	addi	sp,sp,-32
    80004650:	ec06                	sd	ra,24(sp)
    80004652:	e822                	sd	s0,16(sp)
    80004654:	e426                	sd	s1,8(sp)
    80004656:	e04a                	sd	s2,0(sp)
    80004658:	1000                	addi	s0,sp,32
    8000465a:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000465c:	0001e917          	auipc	s2,0x1e
    80004660:	af490913          	addi	s2,s2,-1292 # 80022150 <log>
    80004664:	854a                	mv	a0,s2
    80004666:	ffffc097          	auipc	ra,0xffffc
    8000466a:	584080e7          	jalr	1412(ra) # 80000bea <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000466e:	02c92603          	lw	a2,44(s2)
    80004672:	47f5                	li	a5,29
    80004674:	06c7c563          	blt	a5,a2,800046de <log_write+0x90>
    80004678:	0001e797          	auipc	a5,0x1e
    8000467c:	af47a783          	lw	a5,-1292(a5) # 8002216c <log+0x1c>
    80004680:	37fd                	addiw	a5,a5,-1
    80004682:	04f65e63          	bge	a2,a5,800046de <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004686:	0001e797          	auipc	a5,0x1e
    8000468a:	aea7a783          	lw	a5,-1302(a5) # 80022170 <log+0x20>
    8000468e:	06f05063          	blez	a5,800046ee <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004692:	4781                	li	a5,0
    80004694:	06c05563          	blez	a2,800046fe <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004698:	44cc                	lw	a1,12(s1)
    8000469a:	0001e717          	auipc	a4,0x1e
    8000469e:	ae670713          	addi	a4,a4,-1306 # 80022180 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800046a2:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800046a4:	4314                	lw	a3,0(a4)
    800046a6:	04b68c63          	beq	a3,a1,800046fe <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800046aa:	2785                	addiw	a5,a5,1
    800046ac:	0711                	addi	a4,a4,4
    800046ae:	fef61be3          	bne	a2,a5,800046a4 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800046b2:	0621                	addi	a2,a2,8
    800046b4:	060a                	slli	a2,a2,0x2
    800046b6:	0001e797          	auipc	a5,0x1e
    800046ba:	a9a78793          	addi	a5,a5,-1382 # 80022150 <log>
    800046be:	963e                	add	a2,a2,a5
    800046c0:	44dc                	lw	a5,12(s1)
    800046c2:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800046c4:	8526                	mv	a0,s1
    800046c6:	fffff097          	auipc	ra,0xfffff
    800046ca:	da2080e7          	jalr	-606(ra) # 80003468 <bpin>
    log.lh.n++;
    800046ce:	0001e717          	auipc	a4,0x1e
    800046d2:	a8270713          	addi	a4,a4,-1406 # 80022150 <log>
    800046d6:	575c                	lw	a5,44(a4)
    800046d8:	2785                	addiw	a5,a5,1
    800046da:	d75c                	sw	a5,44(a4)
    800046dc:	a835                	j	80004718 <log_write+0xca>
    panic("too big a transaction");
    800046de:	00004517          	auipc	a0,0x4
    800046e2:	0ea50513          	addi	a0,a0,234 # 800087c8 <syscallnum+0x1a8>
    800046e6:	ffffc097          	auipc	ra,0xffffc
    800046ea:	e5e080e7          	jalr	-418(ra) # 80000544 <panic>
    panic("log_write outside of trans");
    800046ee:	00004517          	auipc	a0,0x4
    800046f2:	0f250513          	addi	a0,a0,242 # 800087e0 <syscallnum+0x1c0>
    800046f6:	ffffc097          	auipc	ra,0xffffc
    800046fa:	e4e080e7          	jalr	-434(ra) # 80000544 <panic>
  log.lh.block[i] = b->blockno;
    800046fe:	00878713          	addi	a4,a5,8
    80004702:	00271693          	slli	a3,a4,0x2
    80004706:	0001e717          	auipc	a4,0x1e
    8000470a:	a4a70713          	addi	a4,a4,-1462 # 80022150 <log>
    8000470e:	9736                	add	a4,a4,a3
    80004710:	44d4                	lw	a3,12(s1)
    80004712:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004714:	faf608e3          	beq	a2,a5,800046c4 <log_write+0x76>
  }
  release(&log.lock);
    80004718:	0001e517          	auipc	a0,0x1e
    8000471c:	a3850513          	addi	a0,a0,-1480 # 80022150 <log>
    80004720:	ffffc097          	auipc	ra,0xffffc
    80004724:	57e080e7          	jalr	1406(ra) # 80000c9e <release>
}
    80004728:	60e2                	ld	ra,24(sp)
    8000472a:	6442                	ld	s0,16(sp)
    8000472c:	64a2                	ld	s1,8(sp)
    8000472e:	6902                	ld	s2,0(sp)
    80004730:	6105                	addi	sp,sp,32
    80004732:	8082                	ret

0000000080004734 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004734:	1101                	addi	sp,sp,-32
    80004736:	ec06                	sd	ra,24(sp)
    80004738:	e822                	sd	s0,16(sp)
    8000473a:	e426                	sd	s1,8(sp)
    8000473c:	e04a                	sd	s2,0(sp)
    8000473e:	1000                	addi	s0,sp,32
    80004740:	84aa                	mv	s1,a0
    80004742:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004744:	00004597          	auipc	a1,0x4
    80004748:	0bc58593          	addi	a1,a1,188 # 80008800 <syscallnum+0x1e0>
    8000474c:	0521                	addi	a0,a0,8
    8000474e:	ffffc097          	auipc	ra,0xffffc
    80004752:	40c080e7          	jalr	1036(ra) # 80000b5a <initlock>
  lk->name = name;
    80004756:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000475a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000475e:	0204a423          	sw	zero,40(s1)
}
    80004762:	60e2                	ld	ra,24(sp)
    80004764:	6442                	ld	s0,16(sp)
    80004766:	64a2                	ld	s1,8(sp)
    80004768:	6902                	ld	s2,0(sp)
    8000476a:	6105                	addi	sp,sp,32
    8000476c:	8082                	ret

000000008000476e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000476e:	1101                	addi	sp,sp,-32
    80004770:	ec06                	sd	ra,24(sp)
    80004772:	e822                	sd	s0,16(sp)
    80004774:	e426                	sd	s1,8(sp)
    80004776:	e04a                	sd	s2,0(sp)
    80004778:	1000                	addi	s0,sp,32
    8000477a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000477c:	00850913          	addi	s2,a0,8
    80004780:	854a                	mv	a0,s2
    80004782:	ffffc097          	auipc	ra,0xffffc
    80004786:	468080e7          	jalr	1128(ra) # 80000bea <acquire>
  while (lk->locked) {
    8000478a:	409c                	lw	a5,0(s1)
    8000478c:	cb89                	beqz	a5,8000479e <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000478e:	85ca                	mv	a1,s2
    80004790:	8526                	mv	a0,s1
    80004792:	ffffe097          	auipc	ra,0xffffe
    80004796:	96c080e7          	jalr	-1684(ra) # 800020fe <sleep>
  while (lk->locked) {
    8000479a:	409c                	lw	a5,0(s1)
    8000479c:	fbed                	bnez	a5,8000478e <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000479e:	4785                	li	a5,1
    800047a0:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800047a2:	ffffd097          	auipc	ra,0xffffd
    800047a6:	224080e7          	jalr	548(ra) # 800019c6 <myproc>
    800047aa:	591c                	lw	a5,48(a0)
    800047ac:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800047ae:	854a                	mv	a0,s2
    800047b0:	ffffc097          	auipc	ra,0xffffc
    800047b4:	4ee080e7          	jalr	1262(ra) # 80000c9e <release>
}
    800047b8:	60e2                	ld	ra,24(sp)
    800047ba:	6442                	ld	s0,16(sp)
    800047bc:	64a2                	ld	s1,8(sp)
    800047be:	6902                	ld	s2,0(sp)
    800047c0:	6105                	addi	sp,sp,32
    800047c2:	8082                	ret

00000000800047c4 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800047c4:	1101                	addi	sp,sp,-32
    800047c6:	ec06                	sd	ra,24(sp)
    800047c8:	e822                	sd	s0,16(sp)
    800047ca:	e426                	sd	s1,8(sp)
    800047cc:	e04a                	sd	s2,0(sp)
    800047ce:	1000                	addi	s0,sp,32
    800047d0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800047d2:	00850913          	addi	s2,a0,8
    800047d6:	854a                	mv	a0,s2
    800047d8:	ffffc097          	auipc	ra,0xffffc
    800047dc:	412080e7          	jalr	1042(ra) # 80000bea <acquire>
  lk->locked = 0;
    800047e0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800047e4:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800047e8:	8526                	mv	a0,s1
    800047ea:	ffffe097          	auipc	ra,0xffffe
    800047ee:	ac4080e7          	jalr	-1340(ra) # 800022ae <wakeup>
  release(&lk->lk);
    800047f2:	854a                	mv	a0,s2
    800047f4:	ffffc097          	auipc	ra,0xffffc
    800047f8:	4aa080e7          	jalr	1194(ra) # 80000c9e <release>
}
    800047fc:	60e2                	ld	ra,24(sp)
    800047fe:	6442                	ld	s0,16(sp)
    80004800:	64a2                	ld	s1,8(sp)
    80004802:	6902                	ld	s2,0(sp)
    80004804:	6105                	addi	sp,sp,32
    80004806:	8082                	ret

0000000080004808 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004808:	7179                	addi	sp,sp,-48
    8000480a:	f406                	sd	ra,40(sp)
    8000480c:	f022                	sd	s0,32(sp)
    8000480e:	ec26                	sd	s1,24(sp)
    80004810:	e84a                	sd	s2,16(sp)
    80004812:	e44e                	sd	s3,8(sp)
    80004814:	1800                	addi	s0,sp,48
    80004816:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004818:	00850913          	addi	s2,a0,8
    8000481c:	854a                	mv	a0,s2
    8000481e:	ffffc097          	auipc	ra,0xffffc
    80004822:	3cc080e7          	jalr	972(ra) # 80000bea <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004826:	409c                	lw	a5,0(s1)
    80004828:	ef99                	bnez	a5,80004846 <holdingsleep+0x3e>
    8000482a:	4481                	li	s1,0
  release(&lk->lk);
    8000482c:	854a                	mv	a0,s2
    8000482e:	ffffc097          	auipc	ra,0xffffc
    80004832:	470080e7          	jalr	1136(ra) # 80000c9e <release>
  return r;
}
    80004836:	8526                	mv	a0,s1
    80004838:	70a2                	ld	ra,40(sp)
    8000483a:	7402                	ld	s0,32(sp)
    8000483c:	64e2                	ld	s1,24(sp)
    8000483e:	6942                	ld	s2,16(sp)
    80004840:	69a2                	ld	s3,8(sp)
    80004842:	6145                	addi	sp,sp,48
    80004844:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004846:	0284a983          	lw	s3,40(s1)
    8000484a:	ffffd097          	auipc	ra,0xffffd
    8000484e:	17c080e7          	jalr	380(ra) # 800019c6 <myproc>
    80004852:	5904                	lw	s1,48(a0)
    80004854:	413484b3          	sub	s1,s1,s3
    80004858:	0014b493          	seqz	s1,s1
    8000485c:	bfc1                	j	8000482c <holdingsleep+0x24>

000000008000485e <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000485e:	1141                	addi	sp,sp,-16
    80004860:	e406                	sd	ra,8(sp)
    80004862:	e022                	sd	s0,0(sp)
    80004864:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004866:	00004597          	auipc	a1,0x4
    8000486a:	faa58593          	addi	a1,a1,-86 # 80008810 <syscallnum+0x1f0>
    8000486e:	0001e517          	auipc	a0,0x1e
    80004872:	a2a50513          	addi	a0,a0,-1494 # 80022298 <ftable>
    80004876:	ffffc097          	auipc	ra,0xffffc
    8000487a:	2e4080e7          	jalr	740(ra) # 80000b5a <initlock>
}
    8000487e:	60a2                	ld	ra,8(sp)
    80004880:	6402                	ld	s0,0(sp)
    80004882:	0141                	addi	sp,sp,16
    80004884:	8082                	ret

0000000080004886 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004886:	1101                	addi	sp,sp,-32
    80004888:	ec06                	sd	ra,24(sp)
    8000488a:	e822                	sd	s0,16(sp)
    8000488c:	e426                	sd	s1,8(sp)
    8000488e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004890:	0001e517          	auipc	a0,0x1e
    80004894:	a0850513          	addi	a0,a0,-1528 # 80022298 <ftable>
    80004898:	ffffc097          	auipc	ra,0xffffc
    8000489c:	352080e7          	jalr	850(ra) # 80000bea <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800048a0:	0001e497          	auipc	s1,0x1e
    800048a4:	a1048493          	addi	s1,s1,-1520 # 800222b0 <ftable+0x18>
    800048a8:	0001f717          	auipc	a4,0x1f
    800048ac:	9a870713          	addi	a4,a4,-1624 # 80023250 <disk>
    if(f->ref == 0){
    800048b0:	40dc                	lw	a5,4(s1)
    800048b2:	cf99                	beqz	a5,800048d0 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800048b4:	02848493          	addi	s1,s1,40
    800048b8:	fee49ce3          	bne	s1,a4,800048b0 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800048bc:	0001e517          	auipc	a0,0x1e
    800048c0:	9dc50513          	addi	a0,a0,-1572 # 80022298 <ftable>
    800048c4:	ffffc097          	auipc	ra,0xffffc
    800048c8:	3da080e7          	jalr	986(ra) # 80000c9e <release>
  return 0;
    800048cc:	4481                	li	s1,0
    800048ce:	a819                	j	800048e4 <filealloc+0x5e>
      f->ref = 1;
    800048d0:	4785                	li	a5,1
    800048d2:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800048d4:	0001e517          	auipc	a0,0x1e
    800048d8:	9c450513          	addi	a0,a0,-1596 # 80022298 <ftable>
    800048dc:	ffffc097          	auipc	ra,0xffffc
    800048e0:	3c2080e7          	jalr	962(ra) # 80000c9e <release>
}
    800048e4:	8526                	mv	a0,s1
    800048e6:	60e2                	ld	ra,24(sp)
    800048e8:	6442                	ld	s0,16(sp)
    800048ea:	64a2                	ld	s1,8(sp)
    800048ec:	6105                	addi	sp,sp,32
    800048ee:	8082                	ret

00000000800048f0 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800048f0:	1101                	addi	sp,sp,-32
    800048f2:	ec06                	sd	ra,24(sp)
    800048f4:	e822                	sd	s0,16(sp)
    800048f6:	e426                	sd	s1,8(sp)
    800048f8:	1000                	addi	s0,sp,32
    800048fa:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800048fc:	0001e517          	auipc	a0,0x1e
    80004900:	99c50513          	addi	a0,a0,-1636 # 80022298 <ftable>
    80004904:	ffffc097          	auipc	ra,0xffffc
    80004908:	2e6080e7          	jalr	742(ra) # 80000bea <acquire>
  if(f->ref < 1)
    8000490c:	40dc                	lw	a5,4(s1)
    8000490e:	02f05263          	blez	a5,80004932 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004912:	2785                	addiw	a5,a5,1
    80004914:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004916:	0001e517          	auipc	a0,0x1e
    8000491a:	98250513          	addi	a0,a0,-1662 # 80022298 <ftable>
    8000491e:	ffffc097          	auipc	ra,0xffffc
    80004922:	380080e7          	jalr	896(ra) # 80000c9e <release>
  return f;
}
    80004926:	8526                	mv	a0,s1
    80004928:	60e2                	ld	ra,24(sp)
    8000492a:	6442                	ld	s0,16(sp)
    8000492c:	64a2                	ld	s1,8(sp)
    8000492e:	6105                	addi	sp,sp,32
    80004930:	8082                	ret
    panic("filedup");
    80004932:	00004517          	auipc	a0,0x4
    80004936:	ee650513          	addi	a0,a0,-282 # 80008818 <syscallnum+0x1f8>
    8000493a:	ffffc097          	auipc	ra,0xffffc
    8000493e:	c0a080e7          	jalr	-1014(ra) # 80000544 <panic>

0000000080004942 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004942:	7139                	addi	sp,sp,-64
    80004944:	fc06                	sd	ra,56(sp)
    80004946:	f822                	sd	s0,48(sp)
    80004948:	f426                	sd	s1,40(sp)
    8000494a:	f04a                	sd	s2,32(sp)
    8000494c:	ec4e                	sd	s3,24(sp)
    8000494e:	e852                	sd	s4,16(sp)
    80004950:	e456                	sd	s5,8(sp)
    80004952:	0080                	addi	s0,sp,64
    80004954:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004956:	0001e517          	auipc	a0,0x1e
    8000495a:	94250513          	addi	a0,a0,-1726 # 80022298 <ftable>
    8000495e:	ffffc097          	auipc	ra,0xffffc
    80004962:	28c080e7          	jalr	652(ra) # 80000bea <acquire>
  if(f->ref < 1)
    80004966:	40dc                	lw	a5,4(s1)
    80004968:	06f05163          	blez	a5,800049ca <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    8000496c:	37fd                	addiw	a5,a5,-1
    8000496e:	0007871b          	sext.w	a4,a5
    80004972:	c0dc                	sw	a5,4(s1)
    80004974:	06e04363          	bgtz	a4,800049da <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004978:	0004a903          	lw	s2,0(s1)
    8000497c:	0094ca83          	lbu	s5,9(s1)
    80004980:	0104ba03          	ld	s4,16(s1)
    80004984:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004988:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000498c:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004990:	0001e517          	auipc	a0,0x1e
    80004994:	90850513          	addi	a0,a0,-1784 # 80022298 <ftable>
    80004998:	ffffc097          	auipc	ra,0xffffc
    8000499c:	306080e7          	jalr	774(ra) # 80000c9e <release>

  if(ff.type == FD_PIPE){
    800049a0:	4785                	li	a5,1
    800049a2:	04f90d63          	beq	s2,a5,800049fc <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800049a6:	3979                	addiw	s2,s2,-2
    800049a8:	4785                	li	a5,1
    800049aa:	0527e063          	bltu	a5,s2,800049ea <fileclose+0xa8>
    begin_op();
    800049ae:	00000097          	auipc	ra,0x0
    800049b2:	ac8080e7          	jalr	-1336(ra) # 80004476 <begin_op>
    iput(ff.ip);
    800049b6:	854e                	mv	a0,s3
    800049b8:	fffff097          	auipc	ra,0xfffff
    800049bc:	2b6080e7          	jalr	694(ra) # 80003c6e <iput>
    end_op();
    800049c0:	00000097          	auipc	ra,0x0
    800049c4:	b36080e7          	jalr	-1226(ra) # 800044f6 <end_op>
    800049c8:	a00d                	j	800049ea <fileclose+0xa8>
    panic("fileclose");
    800049ca:	00004517          	auipc	a0,0x4
    800049ce:	e5650513          	addi	a0,a0,-426 # 80008820 <syscallnum+0x200>
    800049d2:	ffffc097          	auipc	ra,0xffffc
    800049d6:	b72080e7          	jalr	-1166(ra) # 80000544 <panic>
    release(&ftable.lock);
    800049da:	0001e517          	auipc	a0,0x1e
    800049de:	8be50513          	addi	a0,a0,-1858 # 80022298 <ftable>
    800049e2:	ffffc097          	auipc	ra,0xffffc
    800049e6:	2bc080e7          	jalr	700(ra) # 80000c9e <release>
  }
}
    800049ea:	70e2                	ld	ra,56(sp)
    800049ec:	7442                	ld	s0,48(sp)
    800049ee:	74a2                	ld	s1,40(sp)
    800049f0:	7902                	ld	s2,32(sp)
    800049f2:	69e2                	ld	s3,24(sp)
    800049f4:	6a42                	ld	s4,16(sp)
    800049f6:	6aa2                	ld	s5,8(sp)
    800049f8:	6121                	addi	sp,sp,64
    800049fa:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800049fc:	85d6                	mv	a1,s5
    800049fe:	8552                	mv	a0,s4
    80004a00:	00000097          	auipc	ra,0x0
    80004a04:	34c080e7          	jalr	844(ra) # 80004d4c <pipeclose>
    80004a08:	b7cd                	j	800049ea <fileclose+0xa8>

0000000080004a0a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004a0a:	715d                	addi	sp,sp,-80
    80004a0c:	e486                	sd	ra,72(sp)
    80004a0e:	e0a2                	sd	s0,64(sp)
    80004a10:	fc26                	sd	s1,56(sp)
    80004a12:	f84a                	sd	s2,48(sp)
    80004a14:	f44e                	sd	s3,40(sp)
    80004a16:	0880                	addi	s0,sp,80
    80004a18:	84aa                	mv	s1,a0
    80004a1a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004a1c:	ffffd097          	auipc	ra,0xffffd
    80004a20:	faa080e7          	jalr	-86(ra) # 800019c6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004a24:	409c                	lw	a5,0(s1)
    80004a26:	37f9                	addiw	a5,a5,-2
    80004a28:	4705                	li	a4,1
    80004a2a:	04f76763          	bltu	a4,a5,80004a78 <filestat+0x6e>
    80004a2e:	892a                	mv	s2,a0
    ilock(f->ip);
    80004a30:	6c88                	ld	a0,24(s1)
    80004a32:	fffff097          	auipc	ra,0xfffff
    80004a36:	082080e7          	jalr	130(ra) # 80003ab4 <ilock>
    stati(f->ip, &st);
    80004a3a:	fb840593          	addi	a1,s0,-72
    80004a3e:	6c88                	ld	a0,24(s1)
    80004a40:	fffff097          	auipc	ra,0xfffff
    80004a44:	2fe080e7          	jalr	766(ra) # 80003d3e <stati>
    iunlock(f->ip);
    80004a48:	6c88                	ld	a0,24(s1)
    80004a4a:	fffff097          	auipc	ra,0xfffff
    80004a4e:	12c080e7          	jalr	300(ra) # 80003b76 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004a52:	46e1                	li	a3,24
    80004a54:	fb840613          	addi	a2,s0,-72
    80004a58:	85ce                	mv	a1,s3
    80004a5a:	05093503          	ld	a0,80(s2)
    80004a5e:	ffffd097          	auipc	ra,0xffffd
    80004a62:	c26080e7          	jalr	-986(ra) # 80001684 <copyout>
    80004a66:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004a6a:	60a6                	ld	ra,72(sp)
    80004a6c:	6406                	ld	s0,64(sp)
    80004a6e:	74e2                	ld	s1,56(sp)
    80004a70:	7942                	ld	s2,48(sp)
    80004a72:	79a2                	ld	s3,40(sp)
    80004a74:	6161                	addi	sp,sp,80
    80004a76:	8082                	ret
  return -1;
    80004a78:	557d                	li	a0,-1
    80004a7a:	bfc5                	j	80004a6a <filestat+0x60>

0000000080004a7c <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004a7c:	7179                	addi	sp,sp,-48
    80004a7e:	f406                	sd	ra,40(sp)
    80004a80:	f022                	sd	s0,32(sp)
    80004a82:	ec26                	sd	s1,24(sp)
    80004a84:	e84a                	sd	s2,16(sp)
    80004a86:	e44e                	sd	s3,8(sp)
    80004a88:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004a8a:	00854783          	lbu	a5,8(a0)
    80004a8e:	c3d5                	beqz	a5,80004b32 <fileread+0xb6>
    80004a90:	84aa                	mv	s1,a0
    80004a92:	89ae                	mv	s3,a1
    80004a94:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004a96:	411c                	lw	a5,0(a0)
    80004a98:	4705                	li	a4,1
    80004a9a:	04e78963          	beq	a5,a4,80004aec <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a9e:	470d                	li	a4,3
    80004aa0:	04e78d63          	beq	a5,a4,80004afa <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004aa4:	4709                	li	a4,2
    80004aa6:	06e79e63          	bne	a5,a4,80004b22 <fileread+0xa6>
    ilock(f->ip);
    80004aaa:	6d08                	ld	a0,24(a0)
    80004aac:	fffff097          	auipc	ra,0xfffff
    80004ab0:	008080e7          	jalr	8(ra) # 80003ab4 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004ab4:	874a                	mv	a4,s2
    80004ab6:	5094                	lw	a3,32(s1)
    80004ab8:	864e                	mv	a2,s3
    80004aba:	4585                	li	a1,1
    80004abc:	6c88                	ld	a0,24(s1)
    80004abe:	fffff097          	auipc	ra,0xfffff
    80004ac2:	2aa080e7          	jalr	682(ra) # 80003d68 <readi>
    80004ac6:	892a                	mv	s2,a0
    80004ac8:	00a05563          	blez	a0,80004ad2 <fileread+0x56>
      f->off += r;
    80004acc:	509c                	lw	a5,32(s1)
    80004ace:	9fa9                	addw	a5,a5,a0
    80004ad0:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004ad2:	6c88                	ld	a0,24(s1)
    80004ad4:	fffff097          	auipc	ra,0xfffff
    80004ad8:	0a2080e7          	jalr	162(ra) # 80003b76 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004adc:	854a                	mv	a0,s2
    80004ade:	70a2                	ld	ra,40(sp)
    80004ae0:	7402                	ld	s0,32(sp)
    80004ae2:	64e2                	ld	s1,24(sp)
    80004ae4:	6942                	ld	s2,16(sp)
    80004ae6:	69a2                	ld	s3,8(sp)
    80004ae8:	6145                	addi	sp,sp,48
    80004aea:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004aec:	6908                	ld	a0,16(a0)
    80004aee:	00000097          	auipc	ra,0x0
    80004af2:	3ce080e7          	jalr	974(ra) # 80004ebc <piperead>
    80004af6:	892a                	mv	s2,a0
    80004af8:	b7d5                	j	80004adc <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004afa:	02451783          	lh	a5,36(a0)
    80004afe:	03079693          	slli	a3,a5,0x30
    80004b02:	92c1                	srli	a3,a3,0x30
    80004b04:	4725                	li	a4,9
    80004b06:	02d76863          	bltu	a4,a3,80004b36 <fileread+0xba>
    80004b0a:	0792                	slli	a5,a5,0x4
    80004b0c:	0001d717          	auipc	a4,0x1d
    80004b10:	6ec70713          	addi	a4,a4,1772 # 800221f8 <devsw>
    80004b14:	97ba                	add	a5,a5,a4
    80004b16:	639c                	ld	a5,0(a5)
    80004b18:	c38d                	beqz	a5,80004b3a <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004b1a:	4505                	li	a0,1
    80004b1c:	9782                	jalr	a5
    80004b1e:	892a                	mv	s2,a0
    80004b20:	bf75                	j	80004adc <fileread+0x60>
    panic("fileread");
    80004b22:	00004517          	auipc	a0,0x4
    80004b26:	d0e50513          	addi	a0,a0,-754 # 80008830 <syscallnum+0x210>
    80004b2a:	ffffc097          	auipc	ra,0xffffc
    80004b2e:	a1a080e7          	jalr	-1510(ra) # 80000544 <panic>
    return -1;
    80004b32:	597d                	li	s2,-1
    80004b34:	b765                	j	80004adc <fileread+0x60>
      return -1;
    80004b36:	597d                	li	s2,-1
    80004b38:	b755                	j	80004adc <fileread+0x60>
    80004b3a:	597d                	li	s2,-1
    80004b3c:	b745                	j	80004adc <fileread+0x60>

0000000080004b3e <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004b3e:	715d                	addi	sp,sp,-80
    80004b40:	e486                	sd	ra,72(sp)
    80004b42:	e0a2                	sd	s0,64(sp)
    80004b44:	fc26                	sd	s1,56(sp)
    80004b46:	f84a                	sd	s2,48(sp)
    80004b48:	f44e                	sd	s3,40(sp)
    80004b4a:	f052                	sd	s4,32(sp)
    80004b4c:	ec56                	sd	s5,24(sp)
    80004b4e:	e85a                	sd	s6,16(sp)
    80004b50:	e45e                	sd	s7,8(sp)
    80004b52:	e062                	sd	s8,0(sp)
    80004b54:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004b56:	00954783          	lbu	a5,9(a0)
    80004b5a:	10078663          	beqz	a5,80004c66 <filewrite+0x128>
    80004b5e:	892a                	mv	s2,a0
    80004b60:	8aae                	mv	s5,a1
    80004b62:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004b64:	411c                	lw	a5,0(a0)
    80004b66:	4705                	li	a4,1
    80004b68:	02e78263          	beq	a5,a4,80004b8c <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004b6c:	470d                	li	a4,3
    80004b6e:	02e78663          	beq	a5,a4,80004b9a <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004b72:	4709                	li	a4,2
    80004b74:	0ee79163          	bne	a5,a4,80004c56 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004b78:	0ac05d63          	blez	a2,80004c32 <filewrite+0xf4>
    int i = 0;
    80004b7c:	4981                	li	s3,0
    80004b7e:	6b05                	lui	s6,0x1
    80004b80:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004b84:	6b85                	lui	s7,0x1
    80004b86:	c00b8b9b          	addiw	s7,s7,-1024
    80004b8a:	a861                	j	80004c22 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004b8c:	6908                	ld	a0,16(a0)
    80004b8e:	00000097          	auipc	ra,0x0
    80004b92:	22e080e7          	jalr	558(ra) # 80004dbc <pipewrite>
    80004b96:	8a2a                	mv	s4,a0
    80004b98:	a045                	j	80004c38 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004b9a:	02451783          	lh	a5,36(a0)
    80004b9e:	03079693          	slli	a3,a5,0x30
    80004ba2:	92c1                	srli	a3,a3,0x30
    80004ba4:	4725                	li	a4,9
    80004ba6:	0cd76263          	bltu	a4,a3,80004c6a <filewrite+0x12c>
    80004baa:	0792                	slli	a5,a5,0x4
    80004bac:	0001d717          	auipc	a4,0x1d
    80004bb0:	64c70713          	addi	a4,a4,1612 # 800221f8 <devsw>
    80004bb4:	97ba                	add	a5,a5,a4
    80004bb6:	679c                	ld	a5,8(a5)
    80004bb8:	cbdd                	beqz	a5,80004c6e <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004bba:	4505                	li	a0,1
    80004bbc:	9782                	jalr	a5
    80004bbe:	8a2a                	mv	s4,a0
    80004bc0:	a8a5                	j	80004c38 <filewrite+0xfa>
    80004bc2:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004bc6:	00000097          	auipc	ra,0x0
    80004bca:	8b0080e7          	jalr	-1872(ra) # 80004476 <begin_op>
      ilock(f->ip);
    80004bce:	01893503          	ld	a0,24(s2)
    80004bd2:	fffff097          	auipc	ra,0xfffff
    80004bd6:	ee2080e7          	jalr	-286(ra) # 80003ab4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004bda:	8762                	mv	a4,s8
    80004bdc:	02092683          	lw	a3,32(s2)
    80004be0:	01598633          	add	a2,s3,s5
    80004be4:	4585                	li	a1,1
    80004be6:	01893503          	ld	a0,24(s2)
    80004bea:	fffff097          	auipc	ra,0xfffff
    80004bee:	276080e7          	jalr	630(ra) # 80003e60 <writei>
    80004bf2:	84aa                	mv	s1,a0
    80004bf4:	00a05763          	blez	a0,80004c02 <filewrite+0xc4>
        f->off += r;
    80004bf8:	02092783          	lw	a5,32(s2)
    80004bfc:	9fa9                	addw	a5,a5,a0
    80004bfe:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004c02:	01893503          	ld	a0,24(s2)
    80004c06:	fffff097          	auipc	ra,0xfffff
    80004c0a:	f70080e7          	jalr	-144(ra) # 80003b76 <iunlock>
      end_op();
    80004c0e:	00000097          	auipc	ra,0x0
    80004c12:	8e8080e7          	jalr	-1816(ra) # 800044f6 <end_op>

      if(r != n1){
    80004c16:	009c1f63          	bne	s8,s1,80004c34 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004c1a:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004c1e:	0149db63          	bge	s3,s4,80004c34 <filewrite+0xf6>
      int n1 = n - i;
    80004c22:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004c26:	84be                	mv	s1,a5
    80004c28:	2781                	sext.w	a5,a5
    80004c2a:	f8fb5ce3          	bge	s6,a5,80004bc2 <filewrite+0x84>
    80004c2e:	84de                	mv	s1,s7
    80004c30:	bf49                	j	80004bc2 <filewrite+0x84>
    int i = 0;
    80004c32:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004c34:	013a1f63          	bne	s4,s3,80004c52 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004c38:	8552                	mv	a0,s4
    80004c3a:	60a6                	ld	ra,72(sp)
    80004c3c:	6406                	ld	s0,64(sp)
    80004c3e:	74e2                	ld	s1,56(sp)
    80004c40:	7942                	ld	s2,48(sp)
    80004c42:	79a2                	ld	s3,40(sp)
    80004c44:	7a02                	ld	s4,32(sp)
    80004c46:	6ae2                	ld	s5,24(sp)
    80004c48:	6b42                	ld	s6,16(sp)
    80004c4a:	6ba2                	ld	s7,8(sp)
    80004c4c:	6c02                	ld	s8,0(sp)
    80004c4e:	6161                	addi	sp,sp,80
    80004c50:	8082                	ret
    ret = (i == n ? n : -1);
    80004c52:	5a7d                	li	s4,-1
    80004c54:	b7d5                	j	80004c38 <filewrite+0xfa>
    panic("filewrite");
    80004c56:	00004517          	auipc	a0,0x4
    80004c5a:	bea50513          	addi	a0,a0,-1046 # 80008840 <syscallnum+0x220>
    80004c5e:	ffffc097          	auipc	ra,0xffffc
    80004c62:	8e6080e7          	jalr	-1818(ra) # 80000544 <panic>
    return -1;
    80004c66:	5a7d                	li	s4,-1
    80004c68:	bfc1                	j	80004c38 <filewrite+0xfa>
      return -1;
    80004c6a:	5a7d                	li	s4,-1
    80004c6c:	b7f1                	j	80004c38 <filewrite+0xfa>
    80004c6e:	5a7d                	li	s4,-1
    80004c70:	b7e1                	j	80004c38 <filewrite+0xfa>

0000000080004c72 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004c72:	7179                	addi	sp,sp,-48
    80004c74:	f406                	sd	ra,40(sp)
    80004c76:	f022                	sd	s0,32(sp)
    80004c78:	ec26                	sd	s1,24(sp)
    80004c7a:	e84a                	sd	s2,16(sp)
    80004c7c:	e44e                	sd	s3,8(sp)
    80004c7e:	e052                	sd	s4,0(sp)
    80004c80:	1800                	addi	s0,sp,48
    80004c82:	84aa                	mv	s1,a0
    80004c84:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004c86:	0005b023          	sd	zero,0(a1)
    80004c8a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004c8e:	00000097          	auipc	ra,0x0
    80004c92:	bf8080e7          	jalr	-1032(ra) # 80004886 <filealloc>
    80004c96:	e088                	sd	a0,0(s1)
    80004c98:	c551                	beqz	a0,80004d24 <pipealloc+0xb2>
    80004c9a:	00000097          	auipc	ra,0x0
    80004c9e:	bec080e7          	jalr	-1044(ra) # 80004886 <filealloc>
    80004ca2:	00aa3023          	sd	a0,0(s4)
    80004ca6:	c92d                	beqz	a0,80004d18 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004ca8:	ffffc097          	auipc	ra,0xffffc
    80004cac:	e52080e7          	jalr	-430(ra) # 80000afa <kalloc>
    80004cb0:	892a                	mv	s2,a0
    80004cb2:	c125                	beqz	a0,80004d12 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004cb4:	4985                	li	s3,1
    80004cb6:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004cba:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004cbe:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004cc2:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004cc6:	00003597          	auipc	a1,0x3
    80004cca:	7ba58593          	addi	a1,a1,1978 # 80008480 <states.1760+0x1b8>
    80004cce:	ffffc097          	auipc	ra,0xffffc
    80004cd2:	e8c080e7          	jalr	-372(ra) # 80000b5a <initlock>
  (*f0)->type = FD_PIPE;
    80004cd6:	609c                	ld	a5,0(s1)
    80004cd8:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004cdc:	609c                	ld	a5,0(s1)
    80004cde:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004ce2:	609c                	ld	a5,0(s1)
    80004ce4:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004ce8:	609c                	ld	a5,0(s1)
    80004cea:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004cee:	000a3783          	ld	a5,0(s4)
    80004cf2:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004cf6:	000a3783          	ld	a5,0(s4)
    80004cfa:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004cfe:	000a3783          	ld	a5,0(s4)
    80004d02:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004d06:	000a3783          	ld	a5,0(s4)
    80004d0a:	0127b823          	sd	s2,16(a5)
  return 0;
    80004d0e:	4501                	li	a0,0
    80004d10:	a025                	j	80004d38 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004d12:	6088                	ld	a0,0(s1)
    80004d14:	e501                	bnez	a0,80004d1c <pipealloc+0xaa>
    80004d16:	a039                	j	80004d24 <pipealloc+0xb2>
    80004d18:	6088                	ld	a0,0(s1)
    80004d1a:	c51d                	beqz	a0,80004d48 <pipealloc+0xd6>
    fileclose(*f0);
    80004d1c:	00000097          	auipc	ra,0x0
    80004d20:	c26080e7          	jalr	-986(ra) # 80004942 <fileclose>
  if(*f1)
    80004d24:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004d28:	557d                	li	a0,-1
  if(*f1)
    80004d2a:	c799                	beqz	a5,80004d38 <pipealloc+0xc6>
    fileclose(*f1);
    80004d2c:	853e                	mv	a0,a5
    80004d2e:	00000097          	auipc	ra,0x0
    80004d32:	c14080e7          	jalr	-1004(ra) # 80004942 <fileclose>
  return -1;
    80004d36:	557d                	li	a0,-1
}
    80004d38:	70a2                	ld	ra,40(sp)
    80004d3a:	7402                	ld	s0,32(sp)
    80004d3c:	64e2                	ld	s1,24(sp)
    80004d3e:	6942                	ld	s2,16(sp)
    80004d40:	69a2                	ld	s3,8(sp)
    80004d42:	6a02                	ld	s4,0(sp)
    80004d44:	6145                	addi	sp,sp,48
    80004d46:	8082                	ret
  return -1;
    80004d48:	557d                	li	a0,-1
    80004d4a:	b7fd                	j	80004d38 <pipealloc+0xc6>

0000000080004d4c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004d4c:	1101                	addi	sp,sp,-32
    80004d4e:	ec06                	sd	ra,24(sp)
    80004d50:	e822                	sd	s0,16(sp)
    80004d52:	e426                	sd	s1,8(sp)
    80004d54:	e04a                	sd	s2,0(sp)
    80004d56:	1000                	addi	s0,sp,32
    80004d58:	84aa                	mv	s1,a0
    80004d5a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004d5c:	ffffc097          	auipc	ra,0xffffc
    80004d60:	e8e080e7          	jalr	-370(ra) # 80000bea <acquire>
  if(writable){
    80004d64:	02090d63          	beqz	s2,80004d9e <pipeclose+0x52>
    pi->writeopen = 0;
    80004d68:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004d6c:	21848513          	addi	a0,s1,536
    80004d70:	ffffd097          	auipc	ra,0xffffd
    80004d74:	53e080e7          	jalr	1342(ra) # 800022ae <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004d78:	2204b783          	ld	a5,544(s1)
    80004d7c:	eb95                	bnez	a5,80004db0 <pipeclose+0x64>
    release(&pi->lock);
    80004d7e:	8526                	mv	a0,s1
    80004d80:	ffffc097          	auipc	ra,0xffffc
    80004d84:	f1e080e7          	jalr	-226(ra) # 80000c9e <release>
    kfree((char*)pi);
    80004d88:	8526                	mv	a0,s1
    80004d8a:	ffffc097          	auipc	ra,0xffffc
    80004d8e:	c74080e7          	jalr	-908(ra) # 800009fe <kfree>
  } else
    release(&pi->lock);
}
    80004d92:	60e2                	ld	ra,24(sp)
    80004d94:	6442                	ld	s0,16(sp)
    80004d96:	64a2                	ld	s1,8(sp)
    80004d98:	6902                	ld	s2,0(sp)
    80004d9a:	6105                	addi	sp,sp,32
    80004d9c:	8082                	ret
    pi->readopen = 0;
    80004d9e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004da2:	21c48513          	addi	a0,s1,540
    80004da6:	ffffd097          	auipc	ra,0xffffd
    80004daa:	508080e7          	jalr	1288(ra) # 800022ae <wakeup>
    80004dae:	b7e9                	j	80004d78 <pipeclose+0x2c>
    release(&pi->lock);
    80004db0:	8526                	mv	a0,s1
    80004db2:	ffffc097          	auipc	ra,0xffffc
    80004db6:	eec080e7          	jalr	-276(ra) # 80000c9e <release>
}
    80004dba:	bfe1                	j	80004d92 <pipeclose+0x46>

0000000080004dbc <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004dbc:	7159                	addi	sp,sp,-112
    80004dbe:	f486                	sd	ra,104(sp)
    80004dc0:	f0a2                	sd	s0,96(sp)
    80004dc2:	eca6                	sd	s1,88(sp)
    80004dc4:	e8ca                	sd	s2,80(sp)
    80004dc6:	e4ce                	sd	s3,72(sp)
    80004dc8:	e0d2                	sd	s4,64(sp)
    80004dca:	fc56                	sd	s5,56(sp)
    80004dcc:	f85a                	sd	s6,48(sp)
    80004dce:	f45e                	sd	s7,40(sp)
    80004dd0:	f062                	sd	s8,32(sp)
    80004dd2:	ec66                	sd	s9,24(sp)
    80004dd4:	1880                	addi	s0,sp,112
    80004dd6:	84aa                	mv	s1,a0
    80004dd8:	8aae                	mv	s5,a1
    80004dda:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004ddc:	ffffd097          	auipc	ra,0xffffd
    80004de0:	bea080e7          	jalr	-1046(ra) # 800019c6 <myproc>
    80004de4:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004de6:	8526                	mv	a0,s1
    80004de8:	ffffc097          	auipc	ra,0xffffc
    80004dec:	e02080e7          	jalr	-510(ra) # 80000bea <acquire>
  while(i < n){
    80004df0:	0d405463          	blez	s4,80004eb8 <pipewrite+0xfc>
    80004df4:	8ba6                	mv	s7,s1
  int i = 0;
    80004df6:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004df8:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004dfa:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004dfe:	21c48c13          	addi	s8,s1,540
    80004e02:	a08d                	j	80004e64 <pipewrite+0xa8>
      release(&pi->lock);
    80004e04:	8526                	mv	a0,s1
    80004e06:	ffffc097          	auipc	ra,0xffffc
    80004e0a:	e98080e7          	jalr	-360(ra) # 80000c9e <release>
      return -1;
    80004e0e:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004e10:	854a                	mv	a0,s2
    80004e12:	70a6                	ld	ra,104(sp)
    80004e14:	7406                	ld	s0,96(sp)
    80004e16:	64e6                	ld	s1,88(sp)
    80004e18:	6946                	ld	s2,80(sp)
    80004e1a:	69a6                	ld	s3,72(sp)
    80004e1c:	6a06                	ld	s4,64(sp)
    80004e1e:	7ae2                	ld	s5,56(sp)
    80004e20:	7b42                	ld	s6,48(sp)
    80004e22:	7ba2                	ld	s7,40(sp)
    80004e24:	7c02                	ld	s8,32(sp)
    80004e26:	6ce2                	ld	s9,24(sp)
    80004e28:	6165                	addi	sp,sp,112
    80004e2a:	8082                	ret
      wakeup(&pi->nread);
    80004e2c:	8566                	mv	a0,s9
    80004e2e:	ffffd097          	auipc	ra,0xffffd
    80004e32:	480080e7          	jalr	1152(ra) # 800022ae <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004e36:	85de                	mv	a1,s7
    80004e38:	8562                	mv	a0,s8
    80004e3a:	ffffd097          	auipc	ra,0xffffd
    80004e3e:	2c4080e7          	jalr	708(ra) # 800020fe <sleep>
    80004e42:	a839                	j	80004e60 <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004e44:	21c4a783          	lw	a5,540(s1)
    80004e48:	0017871b          	addiw	a4,a5,1
    80004e4c:	20e4ae23          	sw	a4,540(s1)
    80004e50:	1ff7f793          	andi	a5,a5,511
    80004e54:	97a6                	add	a5,a5,s1
    80004e56:	f9f44703          	lbu	a4,-97(s0)
    80004e5a:	00e78c23          	sb	a4,24(a5)
      i++;
    80004e5e:	2905                	addiw	s2,s2,1
  while(i < n){
    80004e60:	05495063          	bge	s2,s4,80004ea0 <pipewrite+0xe4>
    if(pi->readopen == 0 || killed(pr)){
    80004e64:	2204a783          	lw	a5,544(s1)
    80004e68:	dfd1                	beqz	a5,80004e04 <pipewrite+0x48>
    80004e6a:	854e                	mv	a0,s3
    80004e6c:	ffffd097          	auipc	ra,0xffffd
    80004e70:	692080e7          	jalr	1682(ra) # 800024fe <killed>
    80004e74:	f941                	bnez	a0,80004e04 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004e76:	2184a783          	lw	a5,536(s1)
    80004e7a:	21c4a703          	lw	a4,540(s1)
    80004e7e:	2007879b          	addiw	a5,a5,512
    80004e82:	faf705e3          	beq	a4,a5,80004e2c <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004e86:	4685                	li	a3,1
    80004e88:	01590633          	add	a2,s2,s5
    80004e8c:	f9f40593          	addi	a1,s0,-97
    80004e90:	0509b503          	ld	a0,80(s3)
    80004e94:	ffffd097          	auipc	ra,0xffffd
    80004e98:	87c080e7          	jalr	-1924(ra) # 80001710 <copyin>
    80004e9c:	fb6514e3          	bne	a0,s6,80004e44 <pipewrite+0x88>
  wakeup(&pi->nread);
    80004ea0:	21848513          	addi	a0,s1,536
    80004ea4:	ffffd097          	auipc	ra,0xffffd
    80004ea8:	40a080e7          	jalr	1034(ra) # 800022ae <wakeup>
  release(&pi->lock);
    80004eac:	8526                	mv	a0,s1
    80004eae:	ffffc097          	auipc	ra,0xffffc
    80004eb2:	df0080e7          	jalr	-528(ra) # 80000c9e <release>
  return i;
    80004eb6:	bfa9                	j	80004e10 <pipewrite+0x54>
  int i = 0;
    80004eb8:	4901                	li	s2,0
    80004eba:	b7dd                	j	80004ea0 <pipewrite+0xe4>

0000000080004ebc <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004ebc:	715d                	addi	sp,sp,-80
    80004ebe:	e486                	sd	ra,72(sp)
    80004ec0:	e0a2                	sd	s0,64(sp)
    80004ec2:	fc26                	sd	s1,56(sp)
    80004ec4:	f84a                	sd	s2,48(sp)
    80004ec6:	f44e                	sd	s3,40(sp)
    80004ec8:	f052                	sd	s4,32(sp)
    80004eca:	ec56                	sd	s5,24(sp)
    80004ecc:	e85a                	sd	s6,16(sp)
    80004ece:	0880                	addi	s0,sp,80
    80004ed0:	84aa                	mv	s1,a0
    80004ed2:	892e                	mv	s2,a1
    80004ed4:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004ed6:	ffffd097          	auipc	ra,0xffffd
    80004eda:	af0080e7          	jalr	-1296(ra) # 800019c6 <myproc>
    80004ede:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004ee0:	8b26                	mv	s6,s1
    80004ee2:	8526                	mv	a0,s1
    80004ee4:	ffffc097          	auipc	ra,0xffffc
    80004ee8:	d06080e7          	jalr	-762(ra) # 80000bea <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004eec:	2184a703          	lw	a4,536(s1)
    80004ef0:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004ef4:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ef8:	02f71763          	bne	a4,a5,80004f26 <piperead+0x6a>
    80004efc:	2244a783          	lw	a5,548(s1)
    80004f00:	c39d                	beqz	a5,80004f26 <piperead+0x6a>
    if(killed(pr)){
    80004f02:	8552                	mv	a0,s4
    80004f04:	ffffd097          	auipc	ra,0xffffd
    80004f08:	5fa080e7          	jalr	1530(ra) # 800024fe <killed>
    80004f0c:	e941                	bnez	a0,80004f9c <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004f0e:	85da                	mv	a1,s6
    80004f10:	854e                	mv	a0,s3
    80004f12:	ffffd097          	auipc	ra,0xffffd
    80004f16:	1ec080e7          	jalr	492(ra) # 800020fe <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f1a:	2184a703          	lw	a4,536(s1)
    80004f1e:	21c4a783          	lw	a5,540(s1)
    80004f22:	fcf70de3          	beq	a4,a5,80004efc <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f26:	09505263          	blez	s5,80004faa <piperead+0xee>
    80004f2a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004f2c:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004f2e:	2184a783          	lw	a5,536(s1)
    80004f32:	21c4a703          	lw	a4,540(s1)
    80004f36:	02f70d63          	beq	a4,a5,80004f70 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004f3a:	0017871b          	addiw	a4,a5,1
    80004f3e:	20e4ac23          	sw	a4,536(s1)
    80004f42:	1ff7f793          	andi	a5,a5,511
    80004f46:	97a6                	add	a5,a5,s1
    80004f48:	0187c783          	lbu	a5,24(a5)
    80004f4c:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004f50:	4685                	li	a3,1
    80004f52:	fbf40613          	addi	a2,s0,-65
    80004f56:	85ca                	mv	a1,s2
    80004f58:	050a3503          	ld	a0,80(s4)
    80004f5c:	ffffc097          	auipc	ra,0xffffc
    80004f60:	728080e7          	jalr	1832(ra) # 80001684 <copyout>
    80004f64:	01650663          	beq	a0,s6,80004f70 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f68:	2985                	addiw	s3,s3,1
    80004f6a:	0905                	addi	s2,s2,1
    80004f6c:	fd3a91e3          	bne	s5,s3,80004f2e <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004f70:	21c48513          	addi	a0,s1,540
    80004f74:	ffffd097          	auipc	ra,0xffffd
    80004f78:	33a080e7          	jalr	826(ra) # 800022ae <wakeup>
  release(&pi->lock);
    80004f7c:	8526                	mv	a0,s1
    80004f7e:	ffffc097          	auipc	ra,0xffffc
    80004f82:	d20080e7          	jalr	-736(ra) # 80000c9e <release>
  return i;
}
    80004f86:	854e                	mv	a0,s3
    80004f88:	60a6                	ld	ra,72(sp)
    80004f8a:	6406                	ld	s0,64(sp)
    80004f8c:	74e2                	ld	s1,56(sp)
    80004f8e:	7942                	ld	s2,48(sp)
    80004f90:	79a2                	ld	s3,40(sp)
    80004f92:	7a02                	ld	s4,32(sp)
    80004f94:	6ae2                	ld	s5,24(sp)
    80004f96:	6b42                	ld	s6,16(sp)
    80004f98:	6161                	addi	sp,sp,80
    80004f9a:	8082                	ret
      release(&pi->lock);
    80004f9c:	8526                	mv	a0,s1
    80004f9e:	ffffc097          	auipc	ra,0xffffc
    80004fa2:	d00080e7          	jalr	-768(ra) # 80000c9e <release>
      return -1;
    80004fa6:	59fd                	li	s3,-1
    80004fa8:	bff9                	j	80004f86 <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004faa:	4981                	li	s3,0
    80004fac:	b7d1                	j	80004f70 <piperead+0xb4>

0000000080004fae <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004fae:	1141                	addi	sp,sp,-16
    80004fb0:	e422                	sd	s0,8(sp)
    80004fb2:	0800                	addi	s0,sp,16
    80004fb4:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004fb6:	8905                	andi	a0,a0,1
    80004fb8:	c111                	beqz	a0,80004fbc <flags2perm+0xe>
      perm = PTE_X;
    80004fba:	4521                	li	a0,8
    if(flags & 0x2)
    80004fbc:	8b89                	andi	a5,a5,2
    80004fbe:	c399                	beqz	a5,80004fc4 <flags2perm+0x16>
      perm |= PTE_W;
    80004fc0:	00456513          	ori	a0,a0,4
    return perm;
}
    80004fc4:	6422                	ld	s0,8(sp)
    80004fc6:	0141                	addi	sp,sp,16
    80004fc8:	8082                	ret

0000000080004fca <exec>:

int
exec(char *path, char **argv)
{
    80004fca:	df010113          	addi	sp,sp,-528
    80004fce:	20113423          	sd	ra,520(sp)
    80004fd2:	20813023          	sd	s0,512(sp)
    80004fd6:	ffa6                	sd	s1,504(sp)
    80004fd8:	fbca                	sd	s2,496(sp)
    80004fda:	f7ce                	sd	s3,488(sp)
    80004fdc:	f3d2                	sd	s4,480(sp)
    80004fde:	efd6                	sd	s5,472(sp)
    80004fe0:	ebda                	sd	s6,464(sp)
    80004fe2:	e7de                	sd	s7,456(sp)
    80004fe4:	e3e2                	sd	s8,448(sp)
    80004fe6:	ff66                	sd	s9,440(sp)
    80004fe8:	fb6a                	sd	s10,432(sp)
    80004fea:	f76e                	sd	s11,424(sp)
    80004fec:	0c00                	addi	s0,sp,528
    80004fee:	84aa                	mv	s1,a0
    80004ff0:	dea43c23          	sd	a0,-520(s0)
    80004ff4:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004ff8:	ffffd097          	auipc	ra,0xffffd
    80004ffc:	9ce080e7          	jalr	-1586(ra) # 800019c6 <myproc>
    80005000:	892a                	mv	s2,a0

  begin_op();
    80005002:	fffff097          	auipc	ra,0xfffff
    80005006:	474080e7          	jalr	1140(ra) # 80004476 <begin_op>

  if((ip = namei(path)) == 0){
    8000500a:	8526                	mv	a0,s1
    8000500c:	fffff097          	auipc	ra,0xfffff
    80005010:	24e080e7          	jalr	590(ra) # 8000425a <namei>
    80005014:	c92d                	beqz	a0,80005086 <exec+0xbc>
    80005016:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005018:	fffff097          	auipc	ra,0xfffff
    8000501c:	a9c080e7          	jalr	-1380(ra) # 80003ab4 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005020:	04000713          	li	a4,64
    80005024:	4681                	li	a3,0
    80005026:	e5040613          	addi	a2,s0,-432
    8000502a:	4581                	li	a1,0
    8000502c:	8526                	mv	a0,s1
    8000502e:	fffff097          	auipc	ra,0xfffff
    80005032:	d3a080e7          	jalr	-710(ra) # 80003d68 <readi>
    80005036:	04000793          	li	a5,64
    8000503a:	00f51a63          	bne	a0,a5,8000504e <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    8000503e:	e5042703          	lw	a4,-432(s0)
    80005042:	464c47b7          	lui	a5,0x464c4
    80005046:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000504a:	04f70463          	beq	a4,a5,80005092 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000504e:	8526                	mv	a0,s1
    80005050:	fffff097          	auipc	ra,0xfffff
    80005054:	cc6080e7          	jalr	-826(ra) # 80003d16 <iunlockput>
    end_op();
    80005058:	fffff097          	auipc	ra,0xfffff
    8000505c:	49e080e7          	jalr	1182(ra) # 800044f6 <end_op>
  }
  return -1;
    80005060:	557d                	li	a0,-1
}
    80005062:	20813083          	ld	ra,520(sp)
    80005066:	20013403          	ld	s0,512(sp)
    8000506a:	74fe                	ld	s1,504(sp)
    8000506c:	795e                	ld	s2,496(sp)
    8000506e:	79be                	ld	s3,488(sp)
    80005070:	7a1e                	ld	s4,480(sp)
    80005072:	6afe                	ld	s5,472(sp)
    80005074:	6b5e                	ld	s6,464(sp)
    80005076:	6bbe                	ld	s7,456(sp)
    80005078:	6c1e                	ld	s8,448(sp)
    8000507a:	7cfa                	ld	s9,440(sp)
    8000507c:	7d5a                	ld	s10,432(sp)
    8000507e:	7dba                	ld	s11,424(sp)
    80005080:	21010113          	addi	sp,sp,528
    80005084:	8082                	ret
    end_op();
    80005086:	fffff097          	auipc	ra,0xfffff
    8000508a:	470080e7          	jalr	1136(ra) # 800044f6 <end_op>
    return -1;
    8000508e:	557d                	li	a0,-1
    80005090:	bfc9                	j	80005062 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80005092:	854a                	mv	a0,s2
    80005094:	ffffd097          	auipc	ra,0xffffd
    80005098:	9f6080e7          	jalr	-1546(ra) # 80001a8a <proc_pagetable>
    8000509c:	8baa                	mv	s7,a0
    8000509e:	d945                	beqz	a0,8000504e <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800050a0:	e7042983          	lw	s3,-400(s0)
    800050a4:	e8845783          	lhu	a5,-376(s0)
    800050a8:	c7ad                	beqz	a5,80005112 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800050aa:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800050ac:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    800050ae:	6c85                	lui	s9,0x1
    800050b0:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800050b4:	def43823          	sd	a5,-528(s0)
    800050b8:	ac0d                	j	800052ea <exec+0x320>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800050ba:	00003517          	auipc	a0,0x3
    800050be:	79650513          	addi	a0,a0,1942 # 80008850 <syscallnum+0x230>
    800050c2:	ffffb097          	auipc	ra,0xffffb
    800050c6:	482080e7          	jalr	1154(ra) # 80000544 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800050ca:	8756                	mv	a4,s5
    800050cc:	012d86bb          	addw	a3,s11,s2
    800050d0:	4581                	li	a1,0
    800050d2:	8526                	mv	a0,s1
    800050d4:	fffff097          	auipc	ra,0xfffff
    800050d8:	c94080e7          	jalr	-876(ra) # 80003d68 <readi>
    800050dc:	2501                	sext.w	a0,a0
    800050de:	1aaa9a63          	bne	s5,a0,80005292 <exec+0x2c8>
  for(i = 0; i < sz; i += PGSIZE){
    800050e2:	6785                	lui	a5,0x1
    800050e4:	0127893b          	addw	s2,a5,s2
    800050e8:	77fd                	lui	a5,0xfffff
    800050ea:	01478a3b          	addw	s4,a5,s4
    800050ee:	1f897563          	bgeu	s2,s8,800052d8 <exec+0x30e>
    pa = walkaddr(pagetable, va + i);
    800050f2:	02091593          	slli	a1,s2,0x20
    800050f6:	9181                	srli	a1,a1,0x20
    800050f8:	95ea                	add	a1,a1,s10
    800050fa:	855e                	mv	a0,s7
    800050fc:	ffffc097          	auipc	ra,0xffffc
    80005100:	f7c080e7          	jalr	-132(ra) # 80001078 <walkaddr>
    80005104:	862a                	mv	a2,a0
    if(pa == 0)
    80005106:	d955                	beqz	a0,800050ba <exec+0xf0>
      n = PGSIZE;
    80005108:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    8000510a:	fd9a70e3          	bgeu	s4,s9,800050ca <exec+0x100>
      n = sz - i;
    8000510e:	8ad2                	mv	s5,s4
    80005110:	bf6d                	j	800050ca <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005112:	4a01                	li	s4,0
  iunlockput(ip);
    80005114:	8526                	mv	a0,s1
    80005116:	fffff097          	auipc	ra,0xfffff
    8000511a:	c00080e7          	jalr	-1024(ra) # 80003d16 <iunlockput>
  end_op();
    8000511e:	fffff097          	auipc	ra,0xfffff
    80005122:	3d8080e7          	jalr	984(ra) # 800044f6 <end_op>
  p = myproc();
    80005126:	ffffd097          	auipc	ra,0xffffd
    8000512a:	8a0080e7          	jalr	-1888(ra) # 800019c6 <myproc>
    8000512e:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005130:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005134:	6785                	lui	a5,0x1
    80005136:	17fd                	addi	a5,a5,-1
    80005138:	9a3e                	add	s4,s4,a5
    8000513a:	757d                	lui	a0,0xfffff
    8000513c:	00aa77b3          	and	a5,s4,a0
    80005140:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005144:	4691                	li	a3,4
    80005146:	6609                	lui	a2,0x2
    80005148:	963e                	add	a2,a2,a5
    8000514a:	85be                	mv	a1,a5
    8000514c:	855e                	mv	a0,s7
    8000514e:	ffffc097          	auipc	ra,0xffffc
    80005152:	2de080e7          	jalr	734(ra) # 8000142c <uvmalloc>
    80005156:	8b2a                	mv	s6,a0
  ip = 0;
    80005158:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    8000515a:	12050c63          	beqz	a0,80005292 <exec+0x2c8>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000515e:	75f9                	lui	a1,0xffffe
    80005160:	95aa                	add	a1,a1,a0
    80005162:	855e                	mv	a0,s7
    80005164:	ffffc097          	auipc	ra,0xffffc
    80005168:	4ee080e7          	jalr	1262(ra) # 80001652 <uvmclear>
  stackbase = sp - PGSIZE;
    8000516c:	7c7d                	lui	s8,0xfffff
    8000516e:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80005170:	e0043783          	ld	a5,-512(s0)
    80005174:	6388                	ld	a0,0(a5)
    80005176:	c535                	beqz	a0,800051e2 <exec+0x218>
    80005178:	e9040993          	addi	s3,s0,-368
    8000517c:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80005180:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80005182:	ffffc097          	auipc	ra,0xffffc
    80005186:	ce8080e7          	jalr	-792(ra) # 80000e6a <strlen>
    8000518a:	2505                	addiw	a0,a0,1
    8000518c:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005190:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005194:	13896663          	bltu	s2,s8,800052c0 <exec+0x2f6>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005198:	e0043d83          	ld	s11,-512(s0)
    8000519c:	000dba03          	ld	s4,0(s11)
    800051a0:	8552                	mv	a0,s4
    800051a2:	ffffc097          	auipc	ra,0xffffc
    800051a6:	cc8080e7          	jalr	-824(ra) # 80000e6a <strlen>
    800051aa:	0015069b          	addiw	a3,a0,1
    800051ae:	8652                	mv	a2,s4
    800051b0:	85ca                	mv	a1,s2
    800051b2:	855e                	mv	a0,s7
    800051b4:	ffffc097          	auipc	ra,0xffffc
    800051b8:	4d0080e7          	jalr	1232(ra) # 80001684 <copyout>
    800051bc:	10054663          	bltz	a0,800052c8 <exec+0x2fe>
    ustack[argc] = sp;
    800051c0:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800051c4:	0485                	addi	s1,s1,1
    800051c6:	008d8793          	addi	a5,s11,8
    800051ca:	e0f43023          	sd	a5,-512(s0)
    800051ce:	008db503          	ld	a0,8(s11)
    800051d2:	c911                	beqz	a0,800051e6 <exec+0x21c>
    if(argc >= MAXARG)
    800051d4:	09a1                	addi	s3,s3,8
    800051d6:	fb3c96e3          	bne	s9,s3,80005182 <exec+0x1b8>
  sz = sz1;
    800051da:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800051de:	4481                	li	s1,0
    800051e0:	a84d                	j	80005292 <exec+0x2c8>
  sp = sz;
    800051e2:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    800051e4:	4481                	li	s1,0
  ustack[argc] = 0;
    800051e6:	00349793          	slli	a5,s1,0x3
    800051ea:	f9040713          	addi	a4,s0,-112
    800051ee:	97ba                	add	a5,a5,a4
    800051f0:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    800051f4:	00148693          	addi	a3,s1,1
    800051f8:	068e                	slli	a3,a3,0x3
    800051fa:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800051fe:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005202:	01897663          	bgeu	s2,s8,8000520e <exec+0x244>
  sz = sz1;
    80005206:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000520a:	4481                	li	s1,0
    8000520c:	a059                	j	80005292 <exec+0x2c8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000520e:	e9040613          	addi	a2,s0,-368
    80005212:	85ca                	mv	a1,s2
    80005214:	855e                	mv	a0,s7
    80005216:	ffffc097          	auipc	ra,0xffffc
    8000521a:	46e080e7          	jalr	1134(ra) # 80001684 <copyout>
    8000521e:	0a054963          	bltz	a0,800052d0 <exec+0x306>
  p->trapframe->a1 = sp;
    80005222:	058ab783          	ld	a5,88(s5)
    80005226:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000522a:	df843783          	ld	a5,-520(s0)
    8000522e:	0007c703          	lbu	a4,0(a5)
    80005232:	cf11                	beqz	a4,8000524e <exec+0x284>
    80005234:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005236:	02f00693          	li	a3,47
    8000523a:	a039                	j	80005248 <exec+0x27e>
      last = s+1;
    8000523c:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80005240:	0785                	addi	a5,a5,1
    80005242:	fff7c703          	lbu	a4,-1(a5)
    80005246:	c701                	beqz	a4,8000524e <exec+0x284>
    if(*s == '/')
    80005248:	fed71ce3          	bne	a4,a3,80005240 <exec+0x276>
    8000524c:	bfc5                	j	8000523c <exec+0x272>
  safestrcpy(p->name, last, sizeof(p->name));
    8000524e:	4641                	li	a2,16
    80005250:	df843583          	ld	a1,-520(s0)
    80005254:	158a8513          	addi	a0,s5,344
    80005258:	ffffc097          	auipc	ra,0xffffc
    8000525c:	be0080e7          	jalr	-1056(ra) # 80000e38 <safestrcpy>
  oldpagetable = p->pagetable;
    80005260:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80005264:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    80005268:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000526c:	058ab783          	ld	a5,88(s5)
    80005270:	e6843703          	ld	a4,-408(s0)
    80005274:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005276:	058ab783          	ld	a5,88(s5)
    8000527a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000527e:	85ea                	mv	a1,s10
    80005280:	ffffd097          	auipc	ra,0xffffd
    80005284:	8a6080e7          	jalr	-1882(ra) # 80001b26 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005288:	0004851b          	sext.w	a0,s1
    8000528c:	bbd9                	j	80005062 <exec+0x98>
    8000528e:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    80005292:	e0843583          	ld	a1,-504(s0)
    80005296:	855e                	mv	a0,s7
    80005298:	ffffd097          	auipc	ra,0xffffd
    8000529c:	88e080e7          	jalr	-1906(ra) # 80001b26 <proc_freepagetable>
  if(ip){
    800052a0:	da0497e3          	bnez	s1,8000504e <exec+0x84>
  return -1;
    800052a4:	557d                	li	a0,-1
    800052a6:	bb75                	j	80005062 <exec+0x98>
    800052a8:	e1443423          	sd	s4,-504(s0)
    800052ac:	b7dd                	j	80005292 <exec+0x2c8>
    800052ae:	e1443423          	sd	s4,-504(s0)
    800052b2:	b7c5                	j	80005292 <exec+0x2c8>
    800052b4:	e1443423          	sd	s4,-504(s0)
    800052b8:	bfe9                	j	80005292 <exec+0x2c8>
    800052ba:	e1443423          	sd	s4,-504(s0)
    800052be:	bfd1                	j	80005292 <exec+0x2c8>
  sz = sz1;
    800052c0:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800052c4:	4481                	li	s1,0
    800052c6:	b7f1                	j	80005292 <exec+0x2c8>
  sz = sz1;
    800052c8:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800052cc:	4481                	li	s1,0
    800052ce:	b7d1                	j	80005292 <exec+0x2c8>
  sz = sz1;
    800052d0:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800052d4:	4481                	li	s1,0
    800052d6:	bf75                	j	80005292 <exec+0x2c8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800052d8:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800052dc:	2b05                	addiw	s6,s6,1
    800052de:	0389899b          	addiw	s3,s3,56
    800052e2:	e8845783          	lhu	a5,-376(s0)
    800052e6:	e2fb57e3          	bge	s6,a5,80005114 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800052ea:	2981                	sext.w	s3,s3
    800052ec:	03800713          	li	a4,56
    800052f0:	86ce                	mv	a3,s3
    800052f2:	e1840613          	addi	a2,s0,-488
    800052f6:	4581                	li	a1,0
    800052f8:	8526                	mv	a0,s1
    800052fa:	fffff097          	auipc	ra,0xfffff
    800052fe:	a6e080e7          	jalr	-1426(ra) # 80003d68 <readi>
    80005302:	03800793          	li	a5,56
    80005306:	f8f514e3          	bne	a0,a5,8000528e <exec+0x2c4>
    if(ph.type != ELF_PROG_LOAD)
    8000530a:	e1842783          	lw	a5,-488(s0)
    8000530e:	4705                	li	a4,1
    80005310:	fce796e3          	bne	a5,a4,800052dc <exec+0x312>
    if(ph.memsz < ph.filesz)
    80005314:	e4043903          	ld	s2,-448(s0)
    80005318:	e3843783          	ld	a5,-456(s0)
    8000531c:	f8f966e3          	bltu	s2,a5,800052a8 <exec+0x2de>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005320:	e2843783          	ld	a5,-472(s0)
    80005324:	993e                	add	s2,s2,a5
    80005326:	f8f964e3          	bltu	s2,a5,800052ae <exec+0x2e4>
    if(ph.vaddr % PGSIZE != 0)
    8000532a:	df043703          	ld	a4,-528(s0)
    8000532e:	8ff9                	and	a5,a5,a4
    80005330:	f3d1                	bnez	a5,800052b4 <exec+0x2ea>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005332:	e1c42503          	lw	a0,-484(s0)
    80005336:	00000097          	auipc	ra,0x0
    8000533a:	c78080e7          	jalr	-904(ra) # 80004fae <flags2perm>
    8000533e:	86aa                	mv	a3,a0
    80005340:	864a                	mv	a2,s2
    80005342:	85d2                	mv	a1,s4
    80005344:	855e                	mv	a0,s7
    80005346:	ffffc097          	auipc	ra,0xffffc
    8000534a:	0e6080e7          	jalr	230(ra) # 8000142c <uvmalloc>
    8000534e:	e0a43423          	sd	a0,-504(s0)
    80005352:	d525                	beqz	a0,800052ba <exec+0x2f0>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005354:	e2843d03          	ld	s10,-472(s0)
    80005358:	e2042d83          	lw	s11,-480(s0)
    8000535c:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005360:	f60c0ce3          	beqz	s8,800052d8 <exec+0x30e>
    80005364:	8a62                	mv	s4,s8
    80005366:	4901                	li	s2,0
    80005368:	b369                	j	800050f2 <exec+0x128>

000000008000536a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000536a:	7179                	addi	sp,sp,-48
    8000536c:	f406                	sd	ra,40(sp)
    8000536e:	f022                	sd	s0,32(sp)
    80005370:	ec26                	sd	s1,24(sp)
    80005372:	e84a                	sd	s2,16(sp)
    80005374:	1800                	addi	s0,sp,48
    80005376:	892e                	mv	s2,a1
    80005378:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000537a:	fdc40593          	addi	a1,s0,-36
    8000537e:	ffffe097          	auipc	ra,0xffffe
    80005382:	9a2080e7          	jalr	-1630(ra) # 80002d20 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005386:	fdc42703          	lw	a4,-36(s0)
    8000538a:	47bd                	li	a5,15
    8000538c:	02e7eb63          	bltu	a5,a4,800053c2 <argfd+0x58>
    80005390:	ffffc097          	auipc	ra,0xffffc
    80005394:	636080e7          	jalr	1590(ra) # 800019c6 <myproc>
    80005398:	fdc42703          	lw	a4,-36(s0)
    8000539c:	01a70793          	addi	a5,a4,26
    800053a0:	078e                	slli	a5,a5,0x3
    800053a2:	953e                	add	a0,a0,a5
    800053a4:	611c                	ld	a5,0(a0)
    800053a6:	c385                	beqz	a5,800053c6 <argfd+0x5c>
    return -1;
  if(pfd)
    800053a8:	00090463          	beqz	s2,800053b0 <argfd+0x46>
    *pfd = fd;
    800053ac:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800053b0:	4501                	li	a0,0
  if(pf)
    800053b2:	c091                	beqz	s1,800053b6 <argfd+0x4c>
    *pf = f;
    800053b4:	e09c                	sd	a5,0(s1)
}
    800053b6:	70a2                	ld	ra,40(sp)
    800053b8:	7402                	ld	s0,32(sp)
    800053ba:	64e2                	ld	s1,24(sp)
    800053bc:	6942                	ld	s2,16(sp)
    800053be:	6145                	addi	sp,sp,48
    800053c0:	8082                	ret
    return -1;
    800053c2:	557d                	li	a0,-1
    800053c4:	bfcd                	j	800053b6 <argfd+0x4c>
    800053c6:	557d                	li	a0,-1
    800053c8:	b7fd                	j	800053b6 <argfd+0x4c>

00000000800053ca <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800053ca:	1101                	addi	sp,sp,-32
    800053cc:	ec06                	sd	ra,24(sp)
    800053ce:	e822                	sd	s0,16(sp)
    800053d0:	e426                	sd	s1,8(sp)
    800053d2:	1000                	addi	s0,sp,32
    800053d4:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800053d6:	ffffc097          	auipc	ra,0xffffc
    800053da:	5f0080e7          	jalr	1520(ra) # 800019c6 <myproc>
    800053de:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800053e0:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffdbd40>
    800053e4:	4501                	li	a0,0
    800053e6:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800053e8:	6398                	ld	a4,0(a5)
    800053ea:	cb19                	beqz	a4,80005400 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800053ec:	2505                	addiw	a0,a0,1
    800053ee:	07a1                	addi	a5,a5,8
    800053f0:	fed51ce3          	bne	a0,a3,800053e8 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800053f4:	557d                	li	a0,-1
}
    800053f6:	60e2                	ld	ra,24(sp)
    800053f8:	6442                	ld	s0,16(sp)
    800053fa:	64a2                	ld	s1,8(sp)
    800053fc:	6105                	addi	sp,sp,32
    800053fe:	8082                	ret
      p->ofile[fd] = f;
    80005400:	01a50793          	addi	a5,a0,26
    80005404:	078e                	slli	a5,a5,0x3
    80005406:	963e                	add	a2,a2,a5
    80005408:	e204                	sd	s1,0(a2)
      return fd;
    8000540a:	b7f5                	j	800053f6 <fdalloc+0x2c>

000000008000540c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000540c:	715d                	addi	sp,sp,-80
    8000540e:	e486                	sd	ra,72(sp)
    80005410:	e0a2                	sd	s0,64(sp)
    80005412:	fc26                	sd	s1,56(sp)
    80005414:	f84a                	sd	s2,48(sp)
    80005416:	f44e                	sd	s3,40(sp)
    80005418:	f052                	sd	s4,32(sp)
    8000541a:	ec56                	sd	s5,24(sp)
    8000541c:	e85a                	sd	s6,16(sp)
    8000541e:	0880                	addi	s0,sp,80
    80005420:	8b2e                	mv	s6,a1
    80005422:	89b2                	mv	s3,a2
    80005424:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005426:	fb040593          	addi	a1,s0,-80
    8000542a:	fffff097          	auipc	ra,0xfffff
    8000542e:	e4e080e7          	jalr	-434(ra) # 80004278 <nameiparent>
    80005432:	84aa                	mv	s1,a0
    80005434:	16050063          	beqz	a0,80005594 <create+0x188>
    return 0;

  ilock(dp);
    80005438:	ffffe097          	auipc	ra,0xffffe
    8000543c:	67c080e7          	jalr	1660(ra) # 80003ab4 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005440:	4601                	li	a2,0
    80005442:	fb040593          	addi	a1,s0,-80
    80005446:	8526                	mv	a0,s1
    80005448:	fffff097          	auipc	ra,0xfffff
    8000544c:	b50080e7          	jalr	-1200(ra) # 80003f98 <dirlookup>
    80005450:	8aaa                	mv	s5,a0
    80005452:	c931                	beqz	a0,800054a6 <create+0x9a>
    iunlockput(dp);
    80005454:	8526                	mv	a0,s1
    80005456:	fffff097          	auipc	ra,0xfffff
    8000545a:	8c0080e7          	jalr	-1856(ra) # 80003d16 <iunlockput>
    ilock(ip);
    8000545e:	8556                	mv	a0,s5
    80005460:	ffffe097          	auipc	ra,0xffffe
    80005464:	654080e7          	jalr	1620(ra) # 80003ab4 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005468:	000b059b          	sext.w	a1,s6
    8000546c:	4789                	li	a5,2
    8000546e:	02f59563          	bne	a1,a5,80005498 <create+0x8c>
    80005472:	044ad783          	lhu	a5,68(s5)
    80005476:	37f9                	addiw	a5,a5,-2
    80005478:	17c2                	slli	a5,a5,0x30
    8000547a:	93c1                	srli	a5,a5,0x30
    8000547c:	4705                	li	a4,1
    8000547e:	00f76d63          	bltu	a4,a5,80005498 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005482:	8556                	mv	a0,s5
    80005484:	60a6                	ld	ra,72(sp)
    80005486:	6406                	ld	s0,64(sp)
    80005488:	74e2                	ld	s1,56(sp)
    8000548a:	7942                	ld	s2,48(sp)
    8000548c:	79a2                	ld	s3,40(sp)
    8000548e:	7a02                	ld	s4,32(sp)
    80005490:	6ae2                	ld	s5,24(sp)
    80005492:	6b42                	ld	s6,16(sp)
    80005494:	6161                	addi	sp,sp,80
    80005496:	8082                	ret
    iunlockput(ip);
    80005498:	8556                	mv	a0,s5
    8000549a:	fffff097          	auipc	ra,0xfffff
    8000549e:	87c080e7          	jalr	-1924(ra) # 80003d16 <iunlockput>
    return 0;
    800054a2:	4a81                	li	s5,0
    800054a4:	bff9                	j	80005482 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800054a6:	85da                	mv	a1,s6
    800054a8:	4088                	lw	a0,0(s1)
    800054aa:	ffffe097          	auipc	ra,0xffffe
    800054ae:	46e080e7          	jalr	1134(ra) # 80003918 <ialloc>
    800054b2:	8a2a                	mv	s4,a0
    800054b4:	c921                	beqz	a0,80005504 <create+0xf8>
  ilock(ip);
    800054b6:	ffffe097          	auipc	ra,0xffffe
    800054ba:	5fe080e7          	jalr	1534(ra) # 80003ab4 <ilock>
  ip->major = major;
    800054be:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800054c2:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800054c6:	4785                	li	a5,1
    800054c8:	04fa1523          	sh	a5,74(s4)
  iupdate(ip);
    800054cc:	8552                	mv	a0,s4
    800054ce:	ffffe097          	auipc	ra,0xffffe
    800054d2:	51c080e7          	jalr	1308(ra) # 800039ea <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800054d6:	000b059b          	sext.w	a1,s6
    800054da:	4785                	li	a5,1
    800054dc:	02f58b63          	beq	a1,a5,80005512 <create+0x106>
  if(dirlink(dp, name, ip->inum) < 0)
    800054e0:	004a2603          	lw	a2,4(s4)
    800054e4:	fb040593          	addi	a1,s0,-80
    800054e8:	8526                	mv	a0,s1
    800054ea:	fffff097          	auipc	ra,0xfffff
    800054ee:	cbe080e7          	jalr	-834(ra) # 800041a8 <dirlink>
    800054f2:	06054f63          	bltz	a0,80005570 <create+0x164>
  iunlockput(dp);
    800054f6:	8526                	mv	a0,s1
    800054f8:	fffff097          	auipc	ra,0xfffff
    800054fc:	81e080e7          	jalr	-2018(ra) # 80003d16 <iunlockput>
  return ip;
    80005500:	8ad2                	mv	s5,s4
    80005502:	b741                	j	80005482 <create+0x76>
    iunlockput(dp);
    80005504:	8526                	mv	a0,s1
    80005506:	fffff097          	auipc	ra,0xfffff
    8000550a:	810080e7          	jalr	-2032(ra) # 80003d16 <iunlockput>
    return 0;
    8000550e:	8ad2                	mv	s5,s4
    80005510:	bf8d                	j	80005482 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005512:	004a2603          	lw	a2,4(s4)
    80005516:	00003597          	auipc	a1,0x3
    8000551a:	35a58593          	addi	a1,a1,858 # 80008870 <syscallnum+0x250>
    8000551e:	8552                	mv	a0,s4
    80005520:	fffff097          	auipc	ra,0xfffff
    80005524:	c88080e7          	jalr	-888(ra) # 800041a8 <dirlink>
    80005528:	04054463          	bltz	a0,80005570 <create+0x164>
    8000552c:	40d0                	lw	a2,4(s1)
    8000552e:	00003597          	auipc	a1,0x3
    80005532:	34a58593          	addi	a1,a1,842 # 80008878 <syscallnum+0x258>
    80005536:	8552                	mv	a0,s4
    80005538:	fffff097          	auipc	ra,0xfffff
    8000553c:	c70080e7          	jalr	-912(ra) # 800041a8 <dirlink>
    80005540:	02054863          	bltz	a0,80005570 <create+0x164>
  if(dirlink(dp, name, ip->inum) < 0)
    80005544:	004a2603          	lw	a2,4(s4)
    80005548:	fb040593          	addi	a1,s0,-80
    8000554c:	8526                	mv	a0,s1
    8000554e:	fffff097          	auipc	ra,0xfffff
    80005552:	c5a080e7          	jalr	-934(ra) # 800041a8 <dirlink>
    80005556:	00054d63          	bltz	a0,80005570 <create+0x164>
    dp->nlink++;  // for ".."
    8000555a:	04a4d783          	lhu	a5,74(s1)
    8000555e:	2785                	addiw	a5,a5,1
    80005560:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005564:	8526                	mv	a0,s1
    80005566:	ffffe097          	auipc	ra,0xffffe
    8000556a:	484080e7          	jalr	1156(ra) # 800039ea <iupdate>
    8000556e:	b761                	j	800054f6 <create+0xea>
  ip->nlink = 0;
    80005570:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005574:	8552                	mv	a0,s4
    80005576:	ffffe097          	auipc	ra,0xffffe
    8000557a:	474080e7          	jalr	1140(ra) # 800039ea <iupdate>
  iunlockput(ip);
    8000557e:	8552                	mv	a0,s4
    80005580:	ffffe097          	auipc	ra,0xffffe
    80005584:	796080e7          	jalr	1942(ra) # 80003d16 <iunlockput>
  iunlockput(dp);
    80005588:	8526                	mv	a0,s1
    8000558a:	ffffe097          	auipc	ra,0xffffe
    8000558e:	78c080e7          	jalr	1932(ra) # 80003d16 <iunlockput>
  return 0;
    80005592:	bdc5                	j	80005482 <create+0x76>
    return 0;
    80005594:	8aaa                	mv	s5,a0
    80005596:	b5f5                	j	80005482 <create+0x76>

0000000080005598 <sys_dup>:
{
    80005598:	7179                	addi	sp,sp,-48
    8000559a:	f406                	sd	ra,40(sp)
    8000559c:	f022                	sd	s0,32(sp)
    8000559e:	ec26                	sd	s1,24(sp)
    800055a0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800055a2:	fd840613          	addi	a2,s0,-40
    800055a6:	4581                	li	a1,0
    800055a8:	4501                	li	a0,0
    800055aa:	00000097          	auipc	ra,0x0
    800055ae:	dc0080e7          	jalr	-576(ra) # 8000536a <argfd>
    return -1;
    800055b2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800055b4:	02054363          	bltz	a0,800055da <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800055b8:	fd843503          	ld	a0,-40(s0)
    800055bc:	00000097          	auipc	ra,0x0
    800055c0:	e0e080e7          	jalr	-498(ra) # 800053ca <fdalloc>
    800055c4:	84aa                	mv	s1,a0
    return -1;
    800055c6:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800055c8:	00054963          	bltz	a0,800055da <sys_dup+0x42>
  filedup(f);
    800055cc:	fd843503          	ld	a0,-40(s0)
    800055d0:	fffff097          	auipc	ra,0xfffff
    800055d4:	320080e7          	jalr	800(ra) # 800048f0 <filedup>
  return fd;
    800055d8:	87a6                	mv	a5,s1
}
    800055da:	853e                	mv	a0,a5
    800055dc:	70a2                	ld	ra,40(sp)
    800055de:	7402                	ld	s0,32(sp)
    800055e0:	64e2                	ld	s1,24(sp)
    800055e2:	6145                	addi	sp,sp,48
    800055e4:	8082                	ret

00000000800055e6 <sys_read>:
{
    800055e6:	7179                	addi	sp,sp,-48
    800055e8:	f406                	sd	ra,40(sp)
    800055ea:	f022                	sd	s0,32(sp)
    800055ec:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800055ee:	fd840593          	addi	a1,s0,-40
    800055f2:	4505                	li	a0,1
    800055f4:	ffffd097          	auipc	ra,0xffffd
    800055f8:	74e080e7          	jalr	1870(ra) # 80002d42 <argaddr>
  argint(2, &n);
    800055fc:	fe440593          	addi	a1,s0,-28
    80005600:	4509                	li	a0,2
    80005602:	ffffd097          	auipc	ra,0xffffd
    80005606:	71e080e7          	jalr	1822(ra) # 80002d20 <argint>
  if(argfd(0, 0, &f) < 0)
    8000560a:	fe840613          	addi	a2,s0,-24
    8000560e:	4581                	li	a1,0
    80005610:	4501                	li	a0,0
    80005612:	00000097          	auipc	ra,0x0
    80005616:	d58080e7          	jalr	-680(ra) # 8000536a <argfd>
    8000561a:	87aa                	mv	a5,a0
    return -1;
    8000561c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000561e:	0007cc63          	bltz	a5,80005636 <sys_read+0x50>
  return fileread(f, p, n);
    80005622:	fe442603          	lw	a2,-28(s0)
    80005626:	fd843583          	ld	a1,-40(s0)
    8000562a:	fe843503          	ld	a0,-24(s0)
    8000562e:	fffff097          	auipc	ra,0xfffff
    80005632:	44e080e7          	jalr	1102(ra) # 80004a7c <fileread>
}
    80005636:	70a2                	ld	ra,40(sp)
    80005638:	7402                	ld	s0,32(sp)
    8000563a:	6145                	addi	sp,sp,48
    8000563c:	8082                	ret

000000008000563e <sys_write>:
{
    8000563e:	7179                	addi	sp,sp,-48
    80005640:	f406                	sd	ra,40(sp)
    80005642:	f022                	sd	s0,32(sp)
    80005644:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005646:	fd840593          	addi	a1,s0,-40
    8000564a:	4505                	li	a0,1
    8000564c:	ffffd097          	auipc	ra,0xffffd
    80005650:	6f6080e7          	jalr	1782(ra) # 80002d42 <argaddr>
  argint(2, &n);
    80005654:	fe440593          	addi	a1,s0,-28
    80005658:	4509                	li	a0,2
    8000565a:	ffffd097          	auipc	ra,0xffffd
    8000565e:	6c6080e7          	jalr	1734(ra) # 80002d20 <argint>
  if(argfd(0, 0, &f) < 0)
    80005662:	fe840613          	addi	a2,s0,-24
    80005666:	4581                	li	a1,0
    80005668:	4501                	li	a0,0
    8000566a:	00000097          	auipc	ra,0x0
    8000566e:	d00080e7          	jalr	-768(ra) # 8000536a <argfd>
    80005672:	87aa                	mv	a5,a0
    return -1;
    80005674:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005676:	0007cc63          	bltz	a5,8000568e <sys_write+0x50>
  return filewrite(f, p, n);
    8000567a:	fe442603          	lw	a2,-28(s0)
    8000567e:	fd843583          	ld	a1,-40(s0)
    80005682:	fe843503          	ld	a0,-24(s0)
    80005686:	fffff097          	auipc	ra,0xfffff
    8000568a:	4b8080e7          	jalr	1208(ra) # 80004b3e <filewrite>
}
    8000568e:	70a2                	ld	ra,40(sp)
    80005690:	7402                	ld	s0,32(sp)
    80005692:	6145                	addi	sp,sp,48
    80005694:	8082                	ret

0000000080005696 <sys_close>:
{
    80005696:	1101                	addi	sp,sp,-32
    80005698:	ec06                	sd	ra,24(sp)
    8000569a:	e822                	sd	s0,16(sp)
    8000569c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000569e:	fe040613          	addi	a2,s0,-32
    800056a2:	fec40593          	addi	a1,s0,-20
    800056a6:	4501                	li	a0,0
    800056a8:	00000097          	auipc	ra,0x0
    800056ac:	cc2080e7          	jalr	-830(ra) # 8000536a <argfd>
    return -1;
    800056b0:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800056b2:	02054463          	bltz	a0,800056da <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800056b6:	ffffc097          	auipc	ra,0xffffc
    800056ba:	310080e7          	jalr	784(ra) # 800019c6 <myproc>
    800056be:	fec42783          	lw	a5,-20(s0)
    800056c2:	07e9                	addi	a5,a5,26
    800056c4:	078e                	slli	a5,a5,0x3
    800056c6:	97aa                	add	a5,a5,a0
    800056c8:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800056cc:	fe043503          	ld	a0,-32(s0)
    800056d0:	fffff097          	auipc	ra,0xfffff
    800056d4:	272080e7          	jalr	626(ra) # 80004942 <fileclose>
  return 0;
    800056d8:	4781                	li	a5,0
}
    800056da:	853e                	mv	a0,a5
    800056dc:	60e2                	ld	ra,24(sp)
    800056de:	6442                	ld	s0,16(sp)
    800056e0:	6105                	addi	sp,sp,32
    800056e2:	8082                	ret

00000000800056e4 <sys_fstat>:
{
    800056e4:	1101                	addi	sp,sp,-32
    800056e6:	ec06                	sd	ra,24(sp)
    800056e8:	e822                	sd	s0,16(sp)
    800056ea:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800056ec:	fe040593          	addi	a1,s0,-32
    800056f0:	4505                	li	a0,1
    800056f2:	ffffd097          	auipc	ra,0xffffd
    800056f6:	650080e7          	jalr	1616(ra) # 80002d42 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800056fa:	fe840613          	addi	a2,s0,-24
    800056fe:	4581                	li	a1,0
    80005700:	4501                	li	a0,0
    80005702:	00000097          	auipc	ra,0x0
    80005706:	c68080e7          	jalr	-920(ra) # 8000536a <argfd>
    8000570a:	87aa                	mv	a5,a0
    return -1;
    8000570c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000570e:	0007ca63          	bltz	a5,80005722 <sys_fstat+0x3e>
  return filestat(f, st);
    80005712:	fe043583          	ld	a1,-32(s0)
    80005716:	fe843503          	ld	a0,-24(s0)
    8000571a:	fffff097          	auipc	ra,0xfffff
    8000571e:	2f0080e7          	jalr	752(ra) # 80004a0a <filestat>
}
    80005722:	60e2                	ld	ra,24(sp)
    80005724:	6442                	ld	s0,16(sp)
    80005726:	6105                	addi	sp,sp,32
    80005728:	8082                	ret

000000008000572a <sys_link>:
{
    8000572a:	7169                	addi	sp,sp,-304
    8000572c:	f606                	sd	ra,296(sp)
    8000572e:	f222                	sd	s0,288(sp)
    80005730:	ee26                	sd	s1,280(sp)
    80005732:	ea4a                	sd	s2,272(sp)
    80005734:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005736:	08000613          	li	a2,128
    8000573a:	ed040593          	addi	a1,s0,-304
    8000573e:	4501                	li	a0,0
    80005740:	ffffd097          	auipc	ra,0xffffd
    80005744:	624080e7          	jalr	1572(ra) # 80002d64 <argstr>
    return -1;
    80005748:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000574a:	10054e63          	bltz	a0,80005866 <sys_link+0x13c>
    8000574e:	08000613          	li	a2,128
    80005752:	f5040593          	addi	a1,s0,-176
    80005756:	4505                	li	a0,1
    80005758:	ffffd097          	auipc	ra,0xffffd
    8000575c:	60c080e7          	jalr	1548(ra) # 80002d64 <argstr>
    return -1;
    80005760:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005762:	10054263          	bltz	a0,80005866 <sys_link+0x13c>
  begin_op();
    80005766:	fffff097          	auipc	ra,0xfffff
    8000576a:	d10080e7          	jalr	-752(ra) # 80004476 <begin_op>
  if((ip = namei(old)) == 0){
    8000576e:	ed040513          	addi	a0,s0,-304
    80005772:	fffff097          	auipc	ra,0xfffff
    80005776:	ae8080e7          	jalr	-1304(ra) # 8000425a <namei>
    8000577a:	84aa                	mv	s1,a0
    8000577c:	c551                	beqz	a0,80005808 <sys_link+0xde>
  ilock(ip);
    8000577e:	ffffe097          	auipc	ra,0xffffe
    80005782:	336080e7          	jalr	822(ra) # 80003ab4 <ilock>
  if(ip->type == T_DIR){
    80005786:	04449703          	lh	a4,68(s1)
    8000578a:	4785                	li	a5,1
    8000578c:	08f70463          	beq	a4,a5,80005814 <sys_link+0xea>
  ip->nlink++;
    80005790:	04a4d783          	lhu	a5,74(s1)
    80005794:	2785                	addiw	a5,a5,1
    80005796:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000579a:	8526                	mv	a0,s1
    8000579c:	ffffe097          	auipc	ra,0xffffe
    800057a0:	24e080e7          	jalr	590(ra) # 800039ea <iupdate>
  iunlock(ip);
    800057a4:	8526                	mv	a0,s1
    800057a6:	ffffe097          	auipc	ra,0xffffe
    800057aa:	3d0080e7          	jalr	976(ra) # 80003b76 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800057ae:	fd040593          	addi	a1,s0,-48
    800057b2:	f5040513          	addi	a0,s0,-176
    800057b6:	fffff097          	auipc	ra,0xfffff
    800057ba:	ac2080e7          	jalr	-1342(ra) # 80004278 <nameiparent>
    800057be:	892a                	mv	s2,a0
    800057c0:	c935                	beqz	a0,80005834 <sys_link+0x10a>
  ilock(dp);
    800057c2:	ffffe097          	auipc	ra,0xffffe
    800057c6:	2f2080e7          	jalr	754(ra) # 80003ab4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800057ca:	00092703          	lw	a4,0(s2)
    800057ce:	409c                	lw	a5,0(s1)
    800057d0:	04f71d63          	bne	a4,a5,8000582a <sys_link+0x100>
    800057d4:	40d0                	lw	a2,4(s1)
    800057d6:	fd040593          	addi	a1,s0,-48
    800057da:	854a                	mv	a0,s2
    800057dc:	fffff097          	auipc	ra,0xfffff
    800057e0:	9cc080e7          	jalr	-1588(ra) # 800041a8 <dirlink>
    800057e4:	04054363          	bltz	a0,8000582a <sys_link+0x100>
  iunlockput(dp);
    800057e8:	854a                	mv	a0,s2
    800057ea:	ffffe097          	auipc	ra,0xffffe
    800057ee:	52c080e7          	jalr	1324(ra) # 80003d16 <iunlockput>
  iput(ip);
    800057f2:	8526                	mv	a0,s1
    800057f4:	ffffe097          	auipc	ra,0xffffe
    800057f8:	47a080e7          	jalr	1146(ra) # 80003c6e <iput>
  end_op();
    800057fc:	fffff097          	auipc	ra,0xfffff
    80005800:	cfa080e7          	jalr	-774(ra) # 800044f6 <end_op>
  return 0;
    80005804:	4781                	li	a5,0
    80005806:	a085                	j	80005866 <sys_link+0x13c>
    end_op();
    80005808:	fffff097          	auipc	ra,0xfffff
    8000580c:	cee080e7          	jalr	-786(ra) # 800044f6 <end_op>
    return -1;
    80005810:	57fd                	li	a5,-1
    80005812:	a891                	j	80005866 <sys_link+0x13c>
    iunlockput(ip);
    80005814:	8526                	mv	a0,s1
    80005816:	ffffe097          	auipc	ra,0xffffe
    8000581a:	500080e7          	jalr	1280(ra) # 80003d16 <iunlockput>
    end_op();
    8000581e:	fffff097          	auipc	ra,0xfffff
    80005822:	cd8080e7          	jalr	-808(ra) # 800044f6 <end_op>
    return -1;
    80005826:	57fd                	li	a5,-1
    80005828:	a83d                	j	80005866 <sys_link+0x13c>
    iunlockput(dp);
    8000582a:	854a                	mv	a0,s2
    8000582c:	ffffe097          	auipc	ra,0xffffe
    80005830:	4ea080e7          	jalr	1258(ra) # 80003d16 <iunlockput>
  ilock(ip);
    80005834:	8526                	mv	a0,s1
    80005836:	ffffe097          	auipc	ra,0xffffe
    8000583a:	27e080e7          	jalr	638(ra) # 80003ab4 <ilock>
  ip->nlink--;
    8000583e:	04a4d783          	lhu	a5,74(s1)
    80005842:	37fd                	addiw	a5,a5,-1
    80005844:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005848:	8526                	mv	a0,s1
    8000584a:	ffffe097          	auipc	ra,0xffffe
    8000584e:	1a0080e7          	jalr	416(ra) # 800039ea <iupdate>
  iunlockput(ip);
    80005852:	8526                	mv	a0,s1
    80005854:	ffffe097          	auipc	ra,0xffffe
    80005858:	4c2080e7          	jalr	1218(ra) # 80003d16 <iunlockput>
  end_op();
    8000585c:	fffff097          	auipc	ra,0xfffff
    80005860:	c9a080e7          	jalr	-870(ra) # 800044f6 <end_op>
  return -1;
    80005864:	57fd                	li	a5,-1
}
    80005866:	853e                	mv	a0,a5
    80005868:	70b2                	ld	ra,296(sp)
    8000586a:	7412                	ld	s0,288(sp)
    8000586c:	64f2                	ld	s1,280(sp)
    8000586e:	6952                	ld	s2,272(sp)
    80005870:	6155                	addi	sp,sp,304
    80005872:	8082                	ret

0000000080005874 <sys_unlink>:
{
    80005874:	7151                	addi	sp,sp,-240
    80005876:	f586                	sd	ra,232(sp)
    80005878:	f1a2                	sd	s0,224(sp)
    8000587a:	eda6                	sd	s1,216(sp)
    8000587c:	e9ca                	sd	s2,208(sp)
    8000587e:	e5ce                	sd	s3,200(sp)
    80005880:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005882:	08000613          	li	a2,128
    80005886:	f3040593          	addi	a1,s0,-208
    8000588a:	4501                	li	a0,0
    8000588c:	ffffd097          	auipc	ra,0xffffd
    80005890:	4d8080e7          	jalr	1240(ra) # 80002d64 <argstr>
    80005894:	18054163          	bltz	a0,80005a16 <sys_unlink+0x1a2>
  begin_op();
    80005898:	fffff097          	auipc	ra,0xfffff
    8000589c:	bde080e7          	jalr	-1058(ra) # 80004476 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800058a0:	fb040593          	addi	a1,s0,-80
    800058a4:	f3040513          	addi	a0,s0,-208
    800058a8:	fffff097          	auipc	ra,0xfffff
    800058ac:	9d0080e7          	jalr	-1584(ra) # 80004278 <nameiparent>
    800058b0:	84aa                	mv	s1,a0
    800058b2:	c979                	beqz	a0,80005988 <sys_unlink+0x114>
  ilock(dp);
    800058b4:	ffffe097          	auipc	ra,0xffffe
    800058b8:	200080e7          	jalr	512(ra) # 80003ab4 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800058bc:	00003597          	auipc	a1,0x3
    800058c0:	fb458593          	addi	a1,a1,-76 # 80008870 <syscallnum+0x250>
    800058c4:	fb040513          	addi	a0,s0,-80
    800058c8:	ffffe097          	auipc	ra,0xffffe
    800058cc:	6b6080e7          	jalr	1718(ra) # 80003f7e <namecmp>
    800058d0:	14050a63          	beqz	a0,80005a24 <sys_unlink+0x1b0>
    800058d4:	00003597          	auipc	a1,0x3
    800058d8:	fa458593          	addi	a1,a1,-92 # 80008878 <syscallnum+0x258>
    800058dc:	fb040513          	addi	a0,s0,-80
    800058e0:	ffffe097          	auipc	ra,0xffffe
    800058e4:	69e080e7          	jalr	1694(ra) # 80003f7e <namecmp>
    800058e8:	12050e63          	beqz	a0,80005a24 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800058ec:	f2c40613          	addi	a2,s0,-212
    800058f0:	fb040593          	addi	a1,s0,-80
    800058f4:	8526                	mv	a0,s1
    800058f6:	ffffe097          	auipc	ra,0xffffe
    800058fa:	6a2080e7          	jalr	1698(ra) # 80003f98 <dirlookup>
    800058fe:	892a                	mv	s2,a0
    80005900:	12050263          	beqz	a0,80005a24 <sys_unlink+0x1b0>
  ilock(ip);
    80005904:	ffffe097          	auipc	ra,0xffffe
    80005908:	1b0080e7          	jalr	432(ra) # 80003ab4 <ilock>
  if(ip->nlink < 1)
    8000590c:	04a91783          	lh	a5,74(s2)
    80005910:	08f05263          	blez	a5,80005994 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005914:	04491703          	lh	a4,68(s2)
    80005918:	4785                	li	a5,1
    8000591a:	08f70563          	beq	a4,a5,800059a4 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000591e:	4641                	li	a2,16
    80005920:	4581                	li	a1,0
    80005922:	fc040513          	addi	a0,s0,-64
    80005926:	ffffb097          	auipc	ra,0xffffb
    8000592a:	3c0080e7          	jalr	960(ra) # 80000ce6 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000592e:	4741                	li	a4,16
    80005930:	f2c42683          	lw	a3,-212(s0)
    80005934:	fc040613          	addi	a2,s0,-64
    80005938:	4581                	li	a1,0
    8000593a:	8526                	mv	a0,s1
    8000593c:	ffffe097          	auipc	ra,0xffffe
    80005940:	524080e7          	jalr	1316(ra) # 80003e60 <writei>
    80005944:	47c1                	li	a5,16
    80005946:	0af51563          	bne	a0,a5,800059f0 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    8000594a:	04491703          	lh	a4,68(s2)
    8000594e:	4785                	li	a5,1
    80005950:	0af70863          	beq	a4,a5,80005a00 <sys_unlink+0x18c>
  iunlockput(dp);
    80005954:	8526                	mv	a0,s1
    80005956:	ffffe097          	auipc	ra,0xffffe
    8000595a:	3c0080e7          	jalr	960(ra) # 80003d16 <iunlockput>
  ip->nlink--;
    8000595e:	04a95783          	lhu	a5,74(s2)
    80005962:	37fd                	addiw	a5,a5,-1
    80005964:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005968:	854a                	mv	a0,s2
    8000596a:	ffffe097          	auipc	ra,0xffffe
    8000596e:	080080e7          	jalr	128(ra) # 800039ea <iupdate>
  iunlockput(ip);
    80005972:	854a                	mv	a0,s2
    80005974:	ffffe097          	auipc	ra,0xffffe
    80005978:	3a2080e7          	jalr	930(ra) # 80003d16 <iunlockput>
  end_op();
    8000597c:	fffff097          	auipc	ra,0xfffff
    80005980:	b7a080e7          	jalr	-1158(ra) # 800044f6 <end_op>
  return 0;
    80005984:	4501                	li	a0,0
    80005986:	a84d                	j	80005a38 <sys_unlink+0x1c4>
    end_op();
    80005988:	fffff097          	auipc	ra,0xfffff
    8000598c:	b6e080e7          	jalr	-1170(ra) # 800044f6 <end_op>
    return -1;
    80005990:	557d                	li	a0,-1
    80005992:	a05d                	j	80005a38 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005994:	00003517          	auipc	a0,0x3
    80005998:	eec50513          	addi	a0,a0,-276 # 80008880 <syscallnum+0x260>
    8000599c:	ffffb097          	auipc	ra,0xffffb
    800059a0:	ba8080e7          	jalr	-1112(ra) # 80000544 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800059a4:	04c92703          	lw	a4,76(s2)
    800059a8:	02000793          	li	a5,32
    800059ac:	f6e7f9e3          	bgeu	a5,a4,8000591e <sys_unlink+0xaa>
    800059b0:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800059b4:	4741                	li	a4,16
    800059b6:	86ce                	mv	a3,s3
    800059b8:	f1840613          	addi	a2,s0,-232
    800059bc:	4581                	li	a1,0
    800059be:	854a                	mv	a0,s2
    800059c0:	ffffe097          	auipc	ra,0xffffe
    800059c4:	3a8080e7          	jalr	936(ra) # 80003d68 <readi>
    800059c8:	47c1                	li	a5,16
    800059ca:	00f51b63          	bne	a0,a5,800059e0 <sys_unlink+0x16c>
    if(de.inum != 0)
    800059ce:	f1845783          	lhu	a5,-232(s0)
    800059d2:	e7a1                	bnez	a5,80005a1a <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800059d4:	29c1                	addiw	s3,s3,16
    800059d6:	04c92783          	lw	a5,76(s2)
    800059da:	fcf9ede3          	bltu	s3,a5,800059b4 <sys_unlink+0x140>
    800059de:	b781                	j	8000591e <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800059e0:	00003517          	auipc	a0,0x3
    800059e4:	eb850513          	addi	a0,a0,-328 # 80008898 <syscallnum+0x278>
    800059e8:	ffffb097          	auipc	ra,0xffffb
    800059ec:	b5c080e7          	jalr	-1188(ra) # 80000544 <panic>
    panic("unlink: writei");
    800059f0:	00003517          	auipc	a0,0x3
    800059f4:	ec050513          	addi	a0,a0,-320 # 800088b0 <syscallnum+0x290>
    800059f8:	ffffb097          	auipc	ra,0xffffb
    800059fc:	b4c080e7          	jalr	-1204(ra) # 80000544 <panic>
    dp->nlink--;
    80005a00:	04a4d783          	lhu	a5,74(s1)
    80005a04:	37fd                	addiw	a5,a5,-1
    80005a06:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005a0a:	8526                	mv	a0,s1
    80005a0c:	ffffe097          	auipc	ra,0xffffe
    80005a10:	fde080e7          	jalr	-34(ra) # 800039ea <iupdate>
    80005a14:	b781                	j	80005954 <sys_unlink+0xe0>
    return -1;
    80005a16:	557d                	li	a0,-1
    80005a18:	a005                	j	80005a38 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005a1a:	854a                	mv	a0,s2
    80005a1c:	ffffe097          	auipc	ra,0xffffe
    80005a20:	2fa080e7          	jalr	762(ra) # 80003d16 <iunlockput>
  iunlockput(dp);
    80005a24:	8526                	mv	a0,s1
    80005a26:	ffffe097          	auipc	ra,0xffffe
    80005a2a:	2f0080e7          	jalr	752(ra) # 80003d16 <iunlockput>
  end_op();
    80005a2e:	fffff097          	auipc	ra,0xfffff
    80005a32:	ac8080e7          	jalr	-1336(ra) # 800044f6 <end_op>
  return -1;
    80005a36:	557d                	li	a0,-1
}
    80005a38:	70ae                	ld	ra,232(sp)
    80005a3a:	740e                	ld	s0,224(sp)
    80005a3c:	64ee                	ld	s1,216(sp)
    80005a3e:	694e                	ld	s2,208(sp)
    80005a40:	69ae                	ld	s3,200(sp)
    80005a42:	616d                	addi	sp,sp,240
    80005a44:	8082                	ret

0000000080005a46 <sys_open>:

uint64
sys_open(void)
{
    80005a46:	7131                	addi	sp,sp,-192
    80005a48:	fd06                	sd	ra,184(sp)
    80005a4a:	f922                	sd	s0,176(sp)
    80005a4c:	f526                	sd	s1,168(sp)
    80005a4e:	f14a                	sd	s2,160(sp)
    80005a50:	ed4e                	sd	s3,152(sp)
    80005a52:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005a54:	f4c40593          	addi	a1,s0,-180
    80005a58:	4505                	li	a0,1
    80005a5a:	ffffd097          	auipc	ra,0xffffd
    80005a5e:	2c6080e7          	jalr	710(ra) # 80002d20 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005a62:	08000613          	li	a2,128
    80005a66:	f5040593          	addi	a1,s0,-176
    80005a6a:	4501                	li	a0,0
    80005a6c:	ffffd097          	auipc	ra,0xffffd
    80005a70:	2f8080e7          	jalr	760(ra) # 80002d64 <argstr>
    80005a74:	87aa                	mv	a5,a0
    return -1;
    80005a76:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005a78:	0a07c963          	bltz	a5,80005b2a <sys_open+0xe4>

  begin_op();
    80005a7c:	fffff097          	auipc	ra,0xfffff
    80005a80:	9fa080e7          	jalr	-1542(ra) # 80004476 <begin_op>

  if(omode & O_CREATE){
    80005a84:	f4c42783          	lw	a5,-180(s0)
    80005a88:	2007f793          	andi	a5,a5,512
    80005a8c:	cfc5                	beqz	a5,80005b44 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005a8e:	4681                	li	a3,0
    80005a90:	4601                	li	a2,0
    80005a92:	4589                	li	a1,2
    80005a94:	f5040513          	addi	a0,s0,-176
    80005a98:	00000097          	auipc	ra,0x0
    80005a9c:	974080e7          	jalr	-1676(ra) # 8000540c <create>
    80005aa0:	84aa                	mv	s1,a0
    if(ip == 0){
    80005aa2:	c959                	beqz	a0,80005b38 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005aa4:	04449703          	lh	a4,68(s1)
    80005aa8:	478d                	li	a5,3
    80005aaa:	00f71763          	bne	a4,a5,80005ab8 <sys_open+0x72>
    80005aae:	0464d703          	lhu	a4,70(s1)
    80005ab2:	47a5                	li	a5,9
    80005ab4:	0ce7ed63          	bltu	a5,a4,80005b8e <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005ab8:	fffff097          	auipc	ra,0xfffff
    80005abc:	dce080e7          	jalr	-562(ra) # 80004886 <filealloc>
    80005ac0:	89aa                	mv	s3,a0
    80005ac2:	10050363          	beqz	a0,80005bc8 <sys_open+0x182>
    80005ac6:	00000097          	auipc	ra,0x0
    80005aca:	904080e7          	jalr	-1788(ra) # 800053ca <fdalloc>
    80005ace:	892a                	mv	s2,a0
    80005ad0:	0e054763          	bltz	a0,80005bbe <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005ad4:	04449703          	lh	a4,68(s1)
    80005ad8:	478d                	li	a5,3
    80005ada:	0cf70563          	beq	a4,a5,80005ba4 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005ade:	4789                	li	a5,2
    80005ae0:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005ae4:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005ae8:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005aec:	f4c42783          	lw	a5,-180(s0)
    80005af0:	0017c713          	xori	a4,a5,1
    80005af4:	8b05                	andi	a4,a4,1
    80005af6:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005afa:	0037f713          	andi	a4,a5,3
    80005afe:	00e03733          	snez	a4,a4
    80005b02:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005b06:	4007f793          	andi	a5,a5,1024
    80005b0a:	c791                	beqz	a5,80005b16 <sys_open+0xd0>
    80005b0c:	04449703          	lh	a4,68(s1)
    80005b10:	4789                	li	a5,2
    80005b12:	0af70063          	beq	a4,a5,80005bb2 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005b16:	8526                	mv	a0,s1
    80005b18:	ffffe097          	auipc	ra,0xffffe
    80005b1c:	05e080e7          	jalr	94(ra) # 80003b76 <iunlock>
  end_op();
    80005b20:	fffff097          	auipc	ra,0xfffff
    80005b24:	9d6080e7          	jalr	-1578(ra) # 800044f6 <end_op>

  return fd;
    80005b28:	854a                	mv	a0,s2
}
    80005b2a:	70ea                	ld	ra,184(sp)
    80005b2c:	744a                	ld	s0,176(sp)
    80005b2e:	74aa                	ld	s1,168(sp)
    80005b30:	790a                	ld	s2,160(sp)
    80005b32:	69ea                	ld	s3,152(sp)
    80005b34:	6129                	addi	sp,sp,192
    80005b36:	8082                	ret
      end_op();
    80005b38:	fffff097          	auipc	ra,0xfffff
    80005b3c:	9be080e7          	jalr	-1602(ra) # 800044f6 <end_op>
      return -1;
    80005b40:	557d                	li	a0,-1
    80005b42:	b7e5                	j	80005b2a <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005b44:	f5040513          	addi	a0,s0,-176
    80005b48:	ffffe097          	auipc	ra,0xffffe
    80005b4c:	712080e7          	jalr	1810(ra) # 8000425a <namei>
    80005b50:	84aa                	mv	s1,a0
    80005b52:	c905                	beqz	a0,80005b82 <sys_open+0x13c>
    ilock(ip);
    80005b54:	ffffe097          	auipc	ra,0xffffe
    80005b58:	f60080e7          	jalr	-160(ra) # 80003ab4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005b5c:	04449703          	lh	a4,68(s1)
    80005b60:	4785                	li	a5,1
    80005b62:	f4f711e3          	bne	a4,a5,80005aa4 <sys_open+0x5e>
    80005b66:	f4c42783          	lw	a5,-180(s0)
    80005b6a:	d7b9                	beqz	a5,80005ab8 <sys_open+0x72>
      iunlockput(ip);
    80005b6c:	8526                	mv	a0,s1
    80005b6e:	ffffe097          	auipc	ra,0xffffe
    80005b72:	1a8080e7          	jalr	424(ra) # 80003d16 <iunlockput>
      end_op();
    80005b76:	fffff097          	auipc	ra,0xfffff
    80005b7a:	980080e7          	jalr	-1664(ra) # 800044f6 <end_op>
      return -1;
    80005b7e:	557d                	li	a0,-1
    80005b80:	b76d                	j	80005b2a <sys_open+0xe4>
      end_op();
    80005b82:	fffff097          	auipc	ra,0xfffff
    80005b86:	974080e7          	jalr	-1676(ra) # 800044f6 <end_op>
      return -1;
    80005b8a:	557d                	li	a0,-1
    80005b8c:	bf79                	j	80005b2a <sys_open+0xe4>
    iunlockput(ip);
    80005b8e:	8526                	mv	a0,s1
    80005b90:	ffffe097          	auipc	ra,0xffffe
    80005b94:	186080e7          	jalr	390(ra) # 80003d16 <iunlockput>
    end_op();
    80005b98:	fffff097          	auipc	ra,0xfffff
    80005b9c:	95e080e7          	jalr	-1698(ra) # 800044f6 <end_op>
    return -1;
    80005ba0:	557d                	li	a0,-1
    80005ba2:	b761                	j	80005b2a <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005ba4:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005ba8:	04649783          	lh	a5,70(s1)
    80005bac:	02f99223          	sh	a5,36(s3)
    80005bb0:	bf25                	j	80005ae8 <sys_open+0xa2>
    itrunc(ip);
    80005bb2:	8526                	mv	a0,s1
    80005bb4:	ffffe097          	auipc	ra,0xffffe
    80005bb8:	00e080e7          	jalr	14(ra) # 80003bc2 <itrunc>
    80005bbc:	bfa9                	j	80005b16 <sys_open+0xd0>
      fileclose(f);
    80005bbe:	854e                	mv	a0,s3
    80005bc0:	fffff097          	auipc	ra,0xfffff
    80005bc4:	d82080e7          	jalr	-638(ra) # 80004942 <fileclose>
    iunlockput(ip);
    80005bc8:	8526                	mv	a0,s1
    80005bca:	ffffe097          	auipc	ra,0xffffe
    80005bce:	14c080e7          	jalr	332(ra) # 80003d16 <iunlockput>
    end_op();
    80005bd2:	fffff097          	auipc	ra,0xfffff
    80005bd6:	924080e7          	jalr	-1756(ra) # 800044f6 <end_op>
    return -1;
    80005bda:	557d                	li	a0,-1
    80005bdc:	b7b9                	j	80005b2a <sys_open+0xe4>

0000000080005bde <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005bde:	7175                	addi	sp,sp,-144
    80005be0:	e506                	sd	ra,136(sp)
    80005be2:	e122                	sd	s0,128(sp)
    80005be4:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005be6:	fffff097          	auipc	ra,0xfffff
    80005bea:	890080e7          	jalr	-1904(ra) # 80004476 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005bee:	08000613          	li	a2,128
    80005bf2:	f7040593          	addi	a1,s0,-144
    80005bf6:	4501                	li	a0,0
    80005bf8:	ffffd097          	auipc	ra,0xffffd
    80005bfc:	16c080e7          	jalr	364(ra) # 80002d64 <argstr>
    80005c00:	02054963          	bltz	a0,80005c32 <sys_mkdir+0x54>
    80005c04:	4681                	li	a3,0
    80005c06:	4601                	li	a2,0
    80005c08:	4585                	li	a1,1
    80005c0a:	f7040513          	addi	a0,s0,-144
    80005c0e:	fffff097          	auipc	ra,0xfffff
    80005c12:	7fe080e7          	jalr	2046(ra) # 8000540c <create>
    80005c16:	cd11                	beqz	a0,80005c32 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c18:	ffffe097          	auipc	ra,0xffffe
    80005c1c:	0fe080e7          	jalr	254(ra) # 80003d16 <iunlockput>
  end_op();
    80005c20:	fffff097          	auipc	ra,0xfffff
    80005c24:	8d6080e7          	jalr	-1834(ra) # 800044f6 <end_op>
  return 0;
    80005c28:	4501                	li	a0,0
}
    80005c2a:	60aa                	ld	ra,136(sp)
    80005c2c:	640a                	ld	s0,128(sp)
    80005c2e:	6149                	addi	sp,sp,144
    80005c30:	8082                	ret
    end_op();
    80005c32:	fffff097          	auipc	ra,0xfffff
    80005c36:	8c4080e7          	jalr	-1852(ra) # 800044f6 <end_op>
    return -1;
    80005c3a:	557d                	li	a0,-1
    80005c3c:	b7fd                	j	80005c2a <sys_mkdir+0x4c>

0000000080005c3e <sys_mknod>:

uint64
sys_mknod(void)
{
    80005c3e:	7135                	addi	sp,sp,-160
    80005c40:	ed06                	sd	ra,152(sp)
    80005c42:	e922                	sd	s0,144(sp)
    80005c44:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005c46:	fffff097          	auipc	ra,0xfffff
    80005c4a:	830080e7          	jalr	-2000(ra) # 80004476 <begin_op>
  argint(1, &major);
    80005c4e:	f6c40593          	addi	a1,s0,-148
    80005c52:	4505                	li	a0,1
    80005c54:	ffffd097          	auipc	ra,0xffffd
    80005c58:	0cc080e7          	jalr	204(ra) # 80002d20 <argint>
  argint(2, &minor);
    80005c5c:	f6840593          	addi	a1,s0,-152
    80005c60:	4509                	li	a0,2
    80005c62:	ffffd097          	auipc	ra,0xffffd
    80005c66:	0be080e7          	jalr	190(ra) # 80002d20 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c6a:	08000613          	li	a2,128
    80005c6e:	f7040593          	addi	a1,s0,-144
    80005c72:	4501                	li	a0,0
    80005c74:	ffffd097          	auipc	ra,0xffffd
    80005c78:	0f0080e7          	jalr	240(ra) # 80002d64 <argstr>
    80005c7c:	02054b63          	bltz	a0,80005cb2 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005c80:	f6841683          	lh	a3,-152(s0)
    80005c84:	f6c41603          	lh	a2,-148(s0)
    80005c88:	458d                	li	a1,3
    80005c8a:	f7040513          	addi	a0,s0,-144
    80005c8e:	fffff097          	auipc	ra,0xfffff
    80005c92:	77e080e7          	jalr	1918(ra) # 8000540c <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c96:	cd11                	beqz	a0,80005cb2 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c98:	ffffe097          	auipc	ra,0xffffe
    80005c9c:	07e080e7          	jalr	126(ra) # 80003d16 <iunlockput>
  end_op();
    80005ca0:	fffff097          	auipc	ra,0xfffff
    80005ca4:	856080e7          	jalr	-1962(ra) # 800044f6 <end_op>
  return 0;
    80005ca8:	4501                	li	a0,0
}
    80005caa:	60ea                	ld	ra,152(sp)
    80005cac:	644a                	ld	s0,144(sp)
    80005cae:	610d                	addi	sp,sp,160
    80005cb0:	8082                	ret
    end_op();
    80005cb2:	fffff097          	auipc	ra,0xfffff
    80005cb6:	844080e7          	jalr	-1980(ra) # 800044f6 <end_op>
    return -1;
    80005cba:	557d                	li	a0,-1
    80005cbc:	b7fd                	j	80005caa <sys_mknod+0x6c>

0000000080005cbe <sys_chdir>:

uint64
sys_chdir(void)
{
    80005cbe:	7135                	addi	sp,sp,-160
    80005cc0:	ed06                	sd	ra,152(sp)
    80005cc2:	e922                	sd	s0,144(sp)
    80005cc4:	e526                	sd	s1,136(sp)
    80005cc6:	e14a                	sd	s2,128(sp)
    80005cc8:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005cca:	ffffc097          	auipc	ra,0xffffc
    80005cce:	cfc080e7          	jalr	-772(ra) # 800019c6 <myproc>
    80005cd2:	892a                	mv	s2,a0
  
  begin_op();
    80005cd4:	ffffe097          	auipc	ra,0xffffe
    80005cd8:	7a2080e7          	jalr	1954(ra) # 80004476 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005cdc:	08000613          	li	a2,128
    80005ce0:	f6040593          	addi	a1,s0,-160
    80005ce4:	4501                	li	a0,0
    80005ce6:	ffffd097          	auipc	ra,0xffffd
    80005cea:	07e080e7          	jalr	126(ra) # 80002d64 <argstr>
    80005cee:	04054b63          	bltz	a0,80005d44 <sys_chdir+0x86>
    80005cf2:	f6040513          	addi	a0,s0,-160
    80005cf6:	ffffe097          	auipc	ra,0xffffe
    80005cfa:	564080e7          	jalr	1380(ra) # 8000425a <namei>
    80005cfe:	84aa                	mv	s1,a0
    80005d00:	c131                	beqz	a0,80005d44 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005d02:	ffffe097          	auipc	ra,0xffffe
    80005d06:	db2080e7          	jalr	-590(ra) # 80003ab4 <ilock>
  if(ip->type != T_DIR){
    80005d0a:	04449703          	lh	a4,68(s1)
    80005d0e:	4785                	li	a5,1
    80005d10:	04f71063          	bne	a4,a5,80005d50 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005d14:	8526                	mv	a0,s1
    80005d16:	ffffe097          	auipc	ra,0xffffe
    80005d1a:	e60080e7          	jalr	-416(ra) # 80003b76 <iunlock>
  iput(p->cwd);
    80005d1e:	15093503          	ld	a0,336(s2)
    80005d22:	ffffe097          	auipc	ra,0xffffe
    80005d26:	f4c080e7          	jalr	-180(ra) # 80003c6e <iput>
  end_op();
    80005d2a:	ffffe097          	auipc	ra,0xffffe
    80005d2e:	7cc080e7          	jalr	1996(ra) # 800044f6 <end_op>
  p->cwd = ip;
    80005d32:	14993823          	sd	s1,336(s2)
  return 0;
    80005d36:	4501                	li	a0,0
}
    80005d38:	60ea                	ld	ra,152(sp)
    80005d3a:	644a                	ld	s0,144(sp)
    80005d3c:	64aa                	ld	s1,136(sp)
    80005d3e:	690a                	ld	s2,128(sp)
    80005d40:	610d                	addi	sp,sp,160
    80005d42:	8082                	ret
    end_op();
    80005d44:	ffffe097          	auipc	ra,0xffffe
    80005d48:	7b2080e7          	jalr	1970(ra) # 800044f6 <end_op>
    return -1;
    80005d4c:	557d                	li	a0,-1
    80005d4e:	b7ed                	j	80005d38 <sys_chdir+0x7a>
    iunlockput(ip);
    80005d50:	8526                	mv	a0,s1
    80005d52:	ffffe097          	auipc	ra,0xffffe
    80005d56:	fc4080e7          	jalr	-60(ra) # 80003d16 <iunlockput>
    end_op();
    80005d5a:	ffffe097          	auipc	ra,0xffffe
    80005d5e:	79c080e7          	jalr	1948(ra) # 800044f6 <end_op>
    return -1;
    80005d62:	557d                	li	a0,-1
    80005d64:	bfd1                	j	80005d38 <sys_chdir+0x7a>

0000000080005d66 <sys_exec>:

uint64
sys_exec(void)
{
    80005d66:	7145                	addi	sp,sp,-464
    80005d68:	e786                	sd	ra,456(sp)
    80005d6a:	e3a2                	sd	s0,448(sp)
    80005d6c:	ff26                	sd	s1,440(sp)
    80005d6e:	fb4a                	sd	s2,432(sp)
    80005d70:	f74e                	sd	s3,424(sp)
    80005d72:	f352                	sd	s4,416(sp)
    80005d74:	ef56                	sd	s5,408(sp)
    80005d76:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005d78:	e3840593          	addi	a1,s0,-456
    80005d7c:	4505                	li	a0,1
    80005d7e:	ffffd097          	auipc	ra,0xffffd
    80005d82:	fc4080e7          	jalr	-60(ra) # 80002d42 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005d86:	08000613          	li	a2,128
    80005d8a:	f4040593          	addi	a1,s0,-192
    80005d8e:	4501                	li	a0,0
    80005d90:	ffffd097          	auipc	ra,0xffffd
    80005d94:	fd4080e7          	jalr	-44(ra) # 80002d64 <argstr>
    80005d98:	87aa                	mv	a5,a0
    return -1;
    80005d9a:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005d9c:	0c07c263          	bltz	a5,80005e60 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005da0:	10000613          	li	a2,256
    80005da4:	4581                	li	a1,0
    80005da6:	e4040513          	addi	a0,s0,-448
    80005daa:	ffffb097          	auipc	ra,0xffffb
    80005dae:	f3c080e7          	jalr	-196(ra) # 80000ce6 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005db2:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005db6:	89a6                	mv	s3,s1
    80005db8:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005dba:	02000a13          	li	s4,32
    80005dbe:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005dc2:	00391513          	slli	a0,s2,0x3
    80005dc6:	e3040593          	addi	a1,s0,-464
    80005dca:	e3843783          	ld	a5,-456(s0)
    80005dce:	953e                	add	a0,a0,a5
    80005dd0:	ffffd097          	auipc	ra,0xffffd
    80005dd4:	eb2080e7          	jalr	-334(ra) # 80002c82 <fetchaddr>
    80005dd8:	02054a63          	bltz	a0,80005e0c <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005ddc:	e3043783          	ld	a5,-464(s0)
    80005de0:	c3b9                	beqz	a5,80005e26 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005de2:	ffffb097          	auipc	ra,0xffffb
    80005de6:	d18080e7          	jalr	-744(ra) # 80000afa <kalloc>
    80005dea:	85aa                	mv	a1,a0
    80005dec:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005df0:	cd11                	beqz	a0,80005e0c <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005df2:	6605                	lui	a2,0x1
    80005df4:	e3043503          	ld	a0,-464(s0)
    80005df8:	ffffd097          	auipc	ra,0xffffd
    80005dfc:	edc080e7          	jalr	-292(ra) # 80002cd4 <fetchstr>
    80005e00:	00054663          	bltz	a0,80005e0c <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005e04:	0905                	addi	s2,s2,1
    80005e06:	09a1                	addi	s3,s3,8
    80005e08:	fb491be3          	bne	s2,s4,80005dbe <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e0c:	10048913          	addi	s2,s1,256
    80005e10:	6088                	ld	a0,0(s1)
    80005e12:	c531                	beqz	a0,80005e5e <sys_exec+0xf8>
    kfree(argv[i]);
    80005e14:	ffffb097          	auipc	ra,0xffffb
    80005e18:	bea080e7          	jalr	-1046(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e1c:	04a1                	addi	s1,s1,8
    80005e1e:	ff2499e3          	bne	s1,s2,80005e10 <sys_exec+0xaa>
  return -1;
    80005e22:	557d                	li	a0,-1
    80005e24:	a835                	j	80005e60 <sys_exec+0xfa>
      argv[i] = 0;
    80005e26:	0a8e                	slli	s5,s5,0x3
    80005e28:	fc040793          	addi	a5,s0,-64
    80005e2c:	9abe                	add	s5,s5,a5
    80005e2e:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005e32:	e4040593          	addi	a1,s0,-448
    80005e36:	f4040513          	addi	a0,s0,-192
    80005e3a:	fffff097          	auipc	ra,0xfffff
    80005e3e:	190080e7          	jalr	400(ra) # 80004fca <exec>
    80005e42:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e44:	10048993          	addi	s3,s1,256
    80005e48:	6088                	ld	a0,0(s1)
    80005e4a:	c901                	beqz	a0,80005e5a <sys_exec+0xf4>
    kfree(argv[i]);
    80005e4c:	ffffb097          	auipc	ra,0xffffb
    80005e50:	bb2080e7          	jalr	-1102(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e54:	04a1                	addi	s1,s1,8
    80005e56:	ff3499e3          	bne	s1,s3,80005e48 <sys_exec+0xe2>
  return ret;
    80005e5a:	854a                	mv	a0,s2
    80005e5c:	a011                	j	80005e60 <sys_exec+0xfa>
  return -1;
    80005e5e:	557d                	li	a0,-1
}
    80005e60:	60be                	ld	ra,456(sp)
    80005e62:	641e                	ld	s0,448(sp)
    80005e64:	74fa                	ld	s1,440(sp)
    80005e66:	795a                	ld	s2,432(sp)
    80005e68:	79ba                	ld	s3,424(sp)
    80005e6a:	7a1a                	ld	s4,416(sp)
    80005e6c:	6afa                	ld	s5,408(sp)
    80005e6e:	6179                	addi	sp,sp,464
    80005e70:	8082                	ret

0000000080005e72 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005e72:	7139                	addi	sp,sp,-64
    80005e74:	fc06                	sd	ra,56(sp)
    80005e76:	f822                	sd	s0,48(sp)
    80005e78:	f426                	sd	s1,40(sp)
    80005e7a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005e7c:	ffffc097          	auipc	ra,0xffffc
    80005e80:	b4a080e7          	jalr	-1206(ra) # 800019c6 <myproc>
    80005e84:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005e86:	fd840593          	addi	a1,s0,-40
    80005e8a:	4501                	li	a0,0
    80005e8c:	ffffd097          	auipc	ra,0xffffd
    80005e90:	eb6080e7          	jalr	-330(ra) # 80002d42 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005e94:	fc840593          	addi	a1,s0,-56
    80005e98:	fd040513          	addi	a0,s0,-48
    80005e9c:	fffff097          	auipc	ra,0xfffff
    80005ea0:	dd6080e7          	jalr	-554(ra) # 80004c72 <pipealloc>
    return -1;
    80005ea4:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005ea6:	0c054463          	bltz	a0,80005f6e <sys_pipe+0xfc>
  fd0 = -1;
    80005eaa:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005eae:	fd043503          	ld	a0,-48(s0)
    80005eb2:	fffff097          	auipc	ra,0xfffff
    80005eb6:	518080e7          	jalr	1304(ra) # 800053ca <fdalloc>
    80005eba:	fca42223          	sw	a0,-60(s0)
    80005ebe:	08054b63          	bltz	a0,80005f54 <sys_pipe+0xe2>
    80005ec2:	fc843503          	ld	a0,-56(s0)
    80005ec6:	fffff097          	auipc	ra,0xfffff
    80005eca:	504080e7          	jalr	1284(ra) # 800053ca <fdalloc>
    80005ece:	fca42023          	sw	a0,-64(s0)
    80005ed2:	06054863          	bltz	a0,80005f42 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005ed6:	4691                	li	a3,4
    80005ed8:	fc440613          	addi	a2,s0,-60
    80005edc:	fd843583          	ld	a1,-40(s0)
    80005ee0:	68a8                	ld	a0,80(s1)
    80005ee2:	ffffb097          	auipc	ra,0xffffb
    80005ee6:	7a2080e7          	jalr	1954(ra) # 80001684 <copyout>
    80005eea:	02054063          	bltz	a0,80005f0a <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005eee:	4691                	li	a3,4
    80005ef0:	fc040613          	addi	a2,s0,-64
    80005ef4:	fd843583          	ld	a1,-40(s0)
    80005ef8:	0591                	addi	a1,a1,4
    80005efa:	68a8                	ld	a0,80(s1)
    80005efc:	ffffb097          	auipc	ra,0xffffb
    80005f00:	788080e7          	jalr	1928(ra) # 80001684 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005f04:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f06:	06055463          	bgez	a0,80005f6e <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005f0a:	fc442783          	lw	a5,-60(s0)
    80005f0e:	07e9                	addi	a5,a5,26
    80005f10:	078e                	slli	a5,a5,0x3
    80005f12:	97a6                	add	a5,a5,s1
    80005f14:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005f18:	fc042503          	lw	a0,-64(s0)
    80005f1c:	0569                	addi	a0,a0,26
    80005f1e:	050e                	slli	a0,a0,0x3
    80005f20:	94aa                	add	s1,s1,a0
    80005f22:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005f26:	fd043503          	ld	a0,-48(s0)
    80005f2a:	fffff097          	auipc	ra,0xfffff
    80005f2e:	a18080e7          	jalr	-1512(ra) # 80004942 <fileclose>
    fileclose(wf);
    80005f32:	fc843503          	ld	a0,-56(s0)
    80005f36:	fffff097          	auipc	ra,0xfffff
    80005f3a:	a0c080e7          	jalr	-1524(ra) # 80004942 <fileclose>
    return -1;
    80005f3e:	57fd                	li	a5,-1
    80005f40:	a03d                	j	80005f6e <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005f42:	fc442783          	lw	a5,-60(s0)
    80005f46:	0007c763          	bltz	a5,80005f54 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005f4a:	07e9                	addi	a5,a5,26
    80005f4c:	078e                	slli	a5,a5,0x3
    80005f4e:	94be                	add	s1,s1,a5
    80005f50:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005f54:	fd043503          	ld	a0,-48(s0)
    80005f58:	fffff097          	auipc	ra,0xfffff
    80005f5c:	9ea080e7          	jalr	-1558(ra) # 80004942 <fileclose>
    fileclose(wf);
    80005f60:	fc843503          	ld	a0,-56(s0)
    80005f64:	fffff097          	auipc	ra,0xfffff
    80005f68:	9de080e7          	jalr	-1570(ra) # 80004942 <fileclose>
    return -1;
    80005f6c:	57fd                	li	a5,-1
}
    80005f6e:	853e                	mv	a0,a5
    80005f70:	70e2                	ld	ra,56(sp)
    80005f72:	7442                	ld	s0,48(sp)
    80005f74:	74a2                	ld	s1,40(sp)
    80005f76:	6121                	addi	sp,sp,64
    80005f78:	8082                	ret
    80005f7a:	0000                	unimp
    80005f7c:	0000                	unimp
	...

0000000080005f80 <kernelvec>:
    80005f80:	7111                	addi	sp,sp,-256
    80005f82:	e006                	sd	ra,0(sp)
    80005f84:	e40a                	sd	sp,8(sp)
    80005f86:	e80e                	sd	gp,16(sp)
    80005f88:	ec12                	sd	tp,24(sp)
    80005f8a:	f016                	sd	t0,32(sp)
    80005f8c:	f41a                	sd	t1,40(sp)
    80005f8e:	f81e                	sd	t2,48(sp)
    80005f90:	fc22                	sd	s0,56(sp)
    80005f92:	e0a6                	sd	s1,64(sp)
    80005f94:	e4aa                	sd	a0,72(sp)
    80005f96:	e8ae                	sd	a1,80(sp)
    80005f98:	ecb2                	sd	a2,88(sp)
    80005f9a:	f0b6                	sd	a3,96(sp)
    80005f9c:	f4ba                	sd	a4,104(sp)
    80005f9e:	f8be                	sd	a5,112(sp)
    80005fa0:	fcc2                	sd	a6,120(sp)
    80005fa2:	e146                	sd	a7,128(sp)
    80005fa4:	e54a                	sd	s2,136(sp)
    80005fa6:	e94e                	sd	s3,144(sp)
    80005fa8:	ed52                	sd	s4,152(sp)
    80005faa:	f156                	sd	s5,160(sp)
    80005fac:	f55a                	sd	s6,168(sp)
    80005fae:	f95e                	sd	s7,176(sp)
    80005fb0:	fd62                	sd	s8,184(sp)
    80005fb2:	e1e6                	sd	s9,192(sp)
    80005fb4:	e5ea                	sd	s10,200(sp)
    80005fb6:	e9ee                	sd	s11,208(sp)
    80005fb8:	edf2                	sd	t3,216(sp)
    80005fba:	f1f6                	sd	t4,224(sp)
    80005fbc:	f5fa                	sd	t5,232(sp)
    80005fbe:	f9fe                	sd	t6,240(sp)
    80005fc0:	b8ffc0ef          	jal	ra,80002b4e <kerneltrap>
    80005fc4:	6082                	ld	ra,0(sp)
    80005fc6:	6122                	ld	sp,8(sp)
    80005fc8:	61c2                	ld	gp,16(sp)
    80005fca:	7282                	ld	t0,32(sp)
    80005fcc:	7322                	ld	t1,40(sp)
    80005fce:	73c2                	ld	t2,48(sp)
    80005fd0:	7462                	ld	s0,56(sp)
    80005fd2:	6486                	ld	s1,64(sp)
    80005fd4:	6526                	ld	a0,72(sp)
    80005fd6:	65c6                	ld	a1,80(sp)
    80005fd8:	6666                	ld	a2,88(sp)
    80005fda:	7686                	ld	a3,96(sp)
    80005fdc:	7726                	ld	a4,104(sp)
    80005fde:	77c6                	ld	a5,112(sp)
    80005fe0:	7866                	ld	a6,120(sp)
    80005fe2:	688a                	ld	a7,128(sp)
    80005fe4:	692a                	ld	s2,136(sp)
    80005fe6:	69ca                	ld	s3,144(sp)
    80005fe8:	6a6a                	ld	s4,152(sp)
    80005fea:	7a8a                	ld	s5,160(sp)
    80005fec:	7b2a                	ld	s6,168(sp)
    80005fee:	7bca                	ld	s7,176(sp)
    80005ff0:	7c6a                	ld	s8,184(sp)
    80005ff2:	6c8e                	ld	s9,192(sp)
    80005ff4:	6d2e                	ld	s10,200(sp)
    80005ff6:	6dce                	ld	s11,208(sp)
    80005ff8:	6e6e                	ld	t3,216(sp)
    80005ffa:	7e8e                	ld	t4,224(sp)
    80005ffc:	7f2e                	ld	t5,232(sp)
    80005ffe:	7fce                	ld	t6,240(sp)
    80006000:	6111                	addi	sp,sp,256
    80006002:	10200073          	sret
    80006006:	00000013          	nop
    8000600a:	00000013          	nop
    8000600e:	0001                	nop

0000000080006010 <timervec>:
    80006010:	34051573          	csrrw	a0,mscratch,a0
    80006014:	e10c                	sd	a1,0(a0)
    80006016:	e510                	sd	a2,8(a0)
    80006018:	e914                	sd	a3,16(a0)
    8000601a:	6d0c                	ld	a1,24(a0)
    8000601c:	7110                	ld	a2,32(a0)
    8000601e:	6194                	ld	a3,0(a1)
    80006020:	96b2                	add	a3,a3,a2
    80006022:	e194                	sd	a3,0(a1)
    80006024:	4589                	li	a1,2
    80006026:	14459073          	csrw	sip,a1
    8000602a:	6914                	ld	a3,16(a0)
    8000602c:	6510                	ld	a2,8(a0)
    8000602e:	610c                	ld	a1,0(a0)
    80006030:	34051573          	csrrw	a0,mscratch,a0
    80006034:	30200073          	mret
	...

000000008000603a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000603a:	1141                	addi	sp,sp,-16
    8000603c:	e422                	sd	s0,8(sp)
    8000603e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006040:	0c0007b7          	lui	a5,0xc000
    80006044:	4705                	li	a4,1
    80006046:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006048:	c3d8                	sw	a4,4(a5)
}
    8000604a:	6422                	ld	s0,8(sp)
    8000604c:	0141                	addi	sp,sp,16
    8000604e:	8082                	ret

0000000080006050 <plicinithart>:

void
plicinithart(void)
{
    80006050:	1141                	addi	sp,sp,-16
    80006052:	e406                	sd	ra,8(sp)
    80006054:	e022                	sd	s0,0(sp)
    80006056:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006058:	ffffc097          	auipc	ra,0xffffc
    8000605c:	942080e7          	jalr	-1726(ra) # 8000199a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006060:	0085171b          	slliw	a4,a0,0x8
    80006064:	0c0027b7          	lui	a5,0xc002
    80006068:	97ba                	add	a5,a5,a4
    8000606a:	40200713          	li	a4,1026
    8000606e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006072:	00d5151b          	slliw	a0,a0,0xd
    80006076:	0c2017b7          	lui	a5,0xc201
    8000607a:	953e                	add	a0,a0,a5
    8000607c:	00052023          	sw	zero,0(a0)
}
    80006080:	60a2                	ld	ra,8(sp)
    80006082:	6402                	ld	s0,0(sp)
    80006084:	0141                	addi	sp,sp,16
    80006086:	8082                	ret

0000000080006088 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006088:	1141                	addi	sp,sp,-16
    8000608a:	e406                	sd	ra,8(sp)
    8000608c:	e022                	sd	s0,0(sp)
    8000608e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006090:	ffffc097          	auipc	ra,0xffffc
    80006094:	90a080e7          	jalr	-1782(ra) # 8000199a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006098:	00d5179b          	slliw	a5,a0,0xd
    8000609c:	0c201537          	lui	a0,0xc201
    800060a0:	953e                	add	a0,a0,a5
  return irq;
}
    800060a2:	4148                	lw	a0,4(a0)
    800060a4:	60a2                	ld	ra,8(sp)
    800060a6:	6402                	ld	s0,0(sp)
    800060a8:	0141                	addi	sp,sp,16
    800060aa:	8082                	ret

00000000800060ac <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800060ac:	1101                	addi	sp,sp,-32
    800060ae:	ec06                	sd	ra,24(sp)
    800060b0:	e822                	sd	s0,16(sp)
    800060b2:	e426                	sd	s1,8(sp)
    800060b4:	1000                	addi	s0,sp,32
    800060b6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800060b8:	ffffc097          	auipc	ra,0xffffc
    800060bc:	8e2080e7          	jalr	-1822(ra) # 8000199a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800060c0:	00d5151b          	slliw	a0,a0,0xd
    800060c4:	0c2017b7          	lui	a5,0xc201
    800060c8:	97aa                	add	a5,a5,a0
    800060ca:	c3c4                	sw	s1,4(a5)
}
    800060cc:	60e2                	ld	ra,24(sp)
    800060ce:	6442                	ld	s0,16(sp)
    800060d0:	64a2                	ld	s1,8(sp)
    800060d2:	6105                	addi	sp,sp,32
    800060d4:	8082                	ret

00000000800060d6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800060d6:	1141                	addi	sp,sp,-16
    800060d8:	e406                	sd	ra,8(sp)
    800060da:	e022                	sd	s0,0(sp)
    800060dc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800060de:	479d                	li	a5,7
    800060e0:	04a7cc63          	blt	a5,a0,80006138 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800060e4:	0001d797          	auipc	a5,0x1d
    800060e8:	16c78793          	addi	a5,a5,364 # 80023250 <disk>
    800060ec:	97aa                	add	a5,a5,a0
    800060ee:	0187c783          	lbu	a5,24(a5)
    800060f2:	ebb9                	bnez	a5,80006148 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800060f4:	00451613          	slli	a2,a0,0x4
    800060f8:	0001d797          	auipc	a5,0x1d
    800060fc:	15878793          	addi	a5,a5,344 # 80023250 <disk>
    80006100:	6394                	ld	a3,0(a5)
    80006102:	96b2                	add	a3,a3,a2
    80006104:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006108:	6398                	ld	a4,0(a5)
    8000610a:	9732                	add	a4,a4,a2
    8000610c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006110:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006114:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006118:	953e                	add	a0,a0,a5
    8000611a:	4785                	li	a5,1
    8000611c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006120:	0001d517          	auipc	a0,0x1d
    80006124:	14850513          	addi	a0,a0,328 # 80023268 <disk+0x18>
    80006128:	ffffc097          	auipc	ra,0xffffc
    8000612c:	186080e7          	jalr	390(ra) # 800022ae <wakeup>
}
    80006130:	60a2                	ld	ra,8(sp)
    80006132:	6402                	ld	s0,0(sp)
    80006134:	0141                	addi	sp,sp,16
    80006136:	8082                	ret
    panic("free_desc 1");
    80006138:	00002517          	auipc	a0,0x2
    8000613c:	78850513          	addi	a0,a0,1928 # 800088c0 <syscallnum+0x2a0>
    80006140:	ffffa097          	auipc	ra,0xffffa
    80006144:	404080e7          	jalr	1028(ra) # 80000544 <panic>
    panic("free_desc 2");
    80006148:	00002517          	auipc	a0,0x2
    8000614c:	78850513          	addi	a0,a0,1928 # 800088d0 <syscallnum+0x2b0>
    80006150:	ffffa097          	auipc	ra,0xffffa
    80006154:	3f4080e7          	jalr	1012(ra) # 80000544 <panic>

0000000080006158 <virtio_disk_init>:
{
    80006158:	1101                	addi	sp,sp,-32
    8000615a:	ec06                	sd	ra,24(sp)
    8000615c:	e822                	sd	s0,16(sp)
    8000615e:	e426                	sd	s1,8(sp)
    80006160:	e04a                	sd	s2,0(sp)
    80006162:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006164:	00002597          	auipc	a1,0x2
    80006168:	77c58593          	addi	a1,a1,1916 # 800088e0 <syscallnum+0x2c0>
    8000616c:	0001d517          	auipc	a0,0x1d
    80006170:	20c50513          	addi	a0,a0,524 # 80023378 <disk+0x128>
    80006174:	ffffb097          	auipc	ra,0xffffb
    80006178:	9e6080e7          	jalr	-1562(ra) # 80000b5a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000617c:	100017b7          	lui	a5,0x10001
    80006180:	4398                	lw	a4,0(a5)
    80006182:	2701                	sext.w	a4,a4
    80006184:	747277b7          	lui	a5,0x74727
    80006188:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000618c:	14f71e63          	bne	a4,a5,800062e8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006190:	100017b7          	lui	a5,0x10001
    80006194:	43dc                	lw	a5,4(a5)
    80006196:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006198:	4709                	li	a4,2
    8000619a:	14e79763          	bne	a5,a4,800062e8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000619e:	100017b7          	lui	a5,0x10001
    800061a2:	479c                	lw	a5,8(a5)
    800061a4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800061a6:	14e79163          	bne	a5,a4,800062e8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800061aa:	100017b7          	lui	a5,0x10001
    800061ae:	47d8                	lw	a4,12(a5)
    800061b0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800061b2:	554d47b7          	lui	a5,0x554d4
    800061b6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800061ba:	12f71763          	bne	a4,a5,800062e8 <virtio_disk_init+0x190>
  *R(VIRTIO_MMIO_STATUS) = status;
    800061be:	100017b7          	lui	a5,0x10001
    800061c2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800061c6:	4705                	li	a4,1
    800061c8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061ca:	470d                	li	a4,3
    800061cc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800061ce:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800061d0:	c7ffe737          	lui	a4,0xc7ffe
    800061d4:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb3cf>
    800061d8:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800061da:	2701                	sext.w	a4,a4
    800061dc:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061de:	472d                	li	a4,11
    800061e0:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800061e2:	0707a903          	lw	s2,112(a5)
    800061e6:	2901                	sext.w	s2,s2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800061e8:	00897793          	andi	a5,s2,8
    800061ec:	10078663          	beqz	a5,800062f8 <virtio_disk_init+0x1a0>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800061f0:	100017b7          	lui	a5,0x10001
    800061f4:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800061f8:	43fc                	lw	a5,68(a5)
    800061fa:	2781                	sext.w	a5,a5
    800061fc:	10079663          	bnez	a5,80006308 <virtio_disk_init+0x1b0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006200:	100017b7          	lui	a5,0x10001
    80006204:	5bdc                	lw	a5,52(a5)
    80006206:	2781                	sext.w	a5,a5
  if(max == 0)
    80006208:	10078863          	beqz	a5,80006318 <virtio_disk_init+0x1c0>
  if(max < NUM)
    8000620c:	471d                	li	a4,7
    8000620e:	10f77d63          	bgeu	a4,a5,80006328 <virtio_disk_init+0x1d0>
  disk.desc = kalloc();
    80006212:	ffffb097          	auipc	ra,0xffffb
    80006216:	8e8080e7          	jalr	-1816(ra) # 80000afa <kalloc>
    8000621a:	0001d497          	auipc	s1,0x1d
    8000621e:	03648493          	addi	s1,s1,54 # 80023250 <disk>
    80006222:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006224:	ffffb097          	auipc	ra,0xffffb
    80006228:	8d6080e7          	jalr	-1834(ra) # 80000afa <kalloc>
    8000622c:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000622e:	ffffb097          	auipc	ra,0xffffb
    80006232:	8cc080e7          	jalr	-1844(ra) # 80000afa <kalloc>
    80006236:	87aa                	mv	a5,a0
    80006238:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    8000623a:	6088                	ld	a0,0(s1)
    8000623c:	cd75                	beqz	a0,80006338 <virtio_disk_init+0x1e0>
    8000623e:	0001d717          	auipc	a4,0x1d
    80006242:	01a73703          	ld	a4,26(a4) # 80023258 <disk+0x8>
    80006246:	cb6d                	beqz	a4,80006338 <virtio_disk_init+0x1e0>
    80006248:	cbe5                	beqz	a5,80006338 <virtio_disk_init+0x1e0>
  memset(disk.desc, 0, PGSIZE);
    8000624a:	6605                	lui	a2,0x1
    8000624c:	4581                	li	a1,0
    8000624e:	ffffb097          	auipc	ra,0xffffb
    80006252:	a98080e7          	jalr	-1384(ra) # 80000ce6 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006256:	0001d497          	auipc	s1,0x1d
    8000625a:	ffa48493          	addi	s1,s1,-6 # 80023250 <disk>
    8000625e:	6605                	lui	a2,0x1
    80006260:	4581                	li	a1,0
    80006262:	6488                	ld	a0,8(s1)
    80006264:	ffffb097          	auipc	ra,0xffffb
    80006268:	a82080e7          	jalr	-1406(ra) # 80000ce6 <memset>
  memset(disk.used, 0, PGSIZE);
    8000626c:	6605                	lui	a2,0x1
    8000626e:	4581                	li	a1,0
    80006270:	6888                	ld	a0,16(s1)
    80006272:	ffffb097          	auipc	ra,0xffffb
    80006276:	a74080e7          	jalr	-1420(ra) # 80000ce6 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000627a:	100017b7          	lui	a5,0x10001
    8000627e:	4721                	li	a4,8
    80006280:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006282:	4098                	lw	a4,0(s1)
    80006284:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006288:	40d8                	lw	a4,4(s1)
    8000628a:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000628e:	6498                	ld	a4,8(s1)
    80006290:	0007069b          	sext.w	a3,a4
    80006294:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006298:	9701                	srai	a4,a4,0x20
    8000629a:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000629e:	6898                	ld	a4,16(s1)
    800062a0:	0007069b          	sext.w	a3,a4
    800062a4:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800062a8:	9701                	srai	a4,a4,0x20
    800062aa:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800062ae:	4685                	li	a3,1
    800062b0:	c3f4                	sw	a3,68(a5)
    disk.free[i] = 1;
    800062b2:	4705                	li	a4,1
    800062b4:	00d48c23          	sb	a3,24(s1)
    800062b8:	00e48ca3          	sb	a4,25(s1)
    800062bc:	00e48d23          	sb	a4,26(s1)
    800062c0:	00e48da3          	sb	a4,27(s1)
    800062c4:	00e48e23          	sb	a4,28(s1)
    800062c8:	00e48ea3          	sb	a4,29(s1)
    800062cc:	00e48f23          	sb	a4,30(s1)
    800062d0:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800062d4:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800062d8:	0727a823          	sw	s2,112(a5)
}
    800062dc:	60e2                	ld	ra,24(sp)
    800062de:	6442                	ld	s0,16(sp)
    800062e0:	64a2                	ld	s1,8(sp)
    800062e2:	6902                	ld	s2,0(sp)
    800062e4:	6105                	addi	sp,sp,32
    800062e6:	8082                	ret
    panic("could not find virtio disk");
    800062e8:	00002517          	auipc	a0,0x2
    800062ec:	60850513          	addi	a0,a0,1544 # 800088f0 <syscallnum+0x2d0>
    800062f0:	ffffa097          	auipc	ra,0xffffa
    800062f4:	254080e7          	jalr	596(ra) # 80000544 <panic>
    panic("virtio disk FEATURES_OK unset");
    800062f8:	00002517          	auipc	a0,0x2
    800062fc:	61850513          	addi	a0,a0,1560 # 80008910 <syscallnum+0x2f0>
    80006300:	ffffa097          	auipc	ra,0xffffa
    80006304:	244080e7          	jalr	580(ra) # 80000544 <panic>
    panic("virtio disk should not be ready");
    80006308:	00002517          	auipc	a0,0x2
    8000630c:	62850513          	addi	a0,a0,1576 # 80008930 <syscallnum+0x310>
    80006310:	ffffa097          	auipc	ra,0xffffa
    80006314:	234080e7          	jalr	564(ra) # 80000544 <panic>
    panic("virtio disk has no queue 0");
    80006318:	00002517          	auipc	a0,0x2
    8000631c:	63850513          	addi	a0,a0,1592 # 80008950 <syscallnum+0x330>
    80006320:	ffffa097          	auipc	ra,0xffffa
    80006324:	224080e7          	jalr	548(ra) # 80000544 <panic>
    panic("virtio disk max queue too short");
    80006328:	00002517          	auipc	a0,0x2
    8000632c:	64850513          	addi	a0,a0,1608 # 80008970 <syscallnum+0x350>
    80006330:	ffffa097          	auipc	ra,0xffffa
    80006334:	214080e7          	jalr	532(ra) # 80000544 <panic>
    panic("virtio disk kalloc");
    80006338:	00002517          	auipc	a0,0x2
    8000633c:	65850513          	addi	a0,a0,1624 # 80008990 <syscallnum+0x370>
    80006340:	ffffa097          	auipc	ra,0xffffa
    80006344:	204080e7          	jalr	516(ra) # 80000544 <panic>

0000000080006348 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006348:	7159                	addi	sp,sp,-112
    8000634a:	f486                	sd	ra,104(sp)
    8000634c:	f0a2                	sd	s0,96(sp)
    8000634e:	eca6                	sd	s1,88(sp)
    80006350:	e8ca                	sd	s2,80(sp)
    80006352:	e4ce                	sd	s3,72(sp)
    80006354:	e0d2                	sd	s4,64(sp)
    80006356:	fc56                	sd	s5,56(sp)
    80006358:	f85a                	sd	s6,48(sp)
    8000635a:	f45e                	sd	s7,40(sp)
    8000635c:	f062                	sd	s8,32(sp)
    8000635e:	ec66                	sd	s9,24(sp)
    80006360:	e86a                	sd	s10,16(sp)
    80006362:	1880                	addi	s0,sp,112
    80006364:	892a                	mv	s2,a0
    80006366:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006368:	00c52c83          	lw	s9,12(a0)
    8000636c:	001c9c9b          	slliw	s9,s9,0x1
    80006370:	1c82                	slli	s9,s9,0x20
    80006372:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006376:	0001d517          	auipc	a0,0x1d
    8000637a:	00250513          	addi	a0,a0,2 # 80023378 <disk+0x128>
    8000637e:	ffffb097          	auipc	ra,0xffffb
    80006382:	86c080e7          	jalr	-1940(ra) # 80000bea <acquire>
  for(int i = 0; i < 3; i++){
    80006386:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006388:	4ba1                	li	s7,8
      disk.free[i] = 0;
    8000638a:	0001db17          	auipc	s6,0x1d
    8000638e:	ec6b0b13          	addi	s6,s6,-314 # 80023250 <disk>
  for(int i = 0; i < 3; i++){
    80006392:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80006394:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006396:	0001dc17          	auipc	s8,0x1d
    8000639a:	fe2c0c13          	addi	s8,s8,-30 # 80023378 <disk+0x128>
    8000639e:	a8b5                	j	8000641a <virtio_disk_rw+0xd2>
      disk.free[i] = 0;
    800063a0:	00fb06b3          	add	a3,s6,a5
    800063a4:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    800063a8:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    800063aa:	0207c563          	bltz	a5,800063d4 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800063ae:	2485                	addiw	s1,s1,1
    800063b0:	0711                	addi	a4,a4,4
    800063b2:	1f548a63          	beq	s1,s5,800065a6 <virtio_disk_rw+0x25e>
    idx[i] = alloc_desc();
    800063b6:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    800063b8:	0001d697          	auipc	a3,0x1d
    800063bc:	e9868693          	addi	a3,a3,-360 # 80023250 <disk>
    800063c0:	87d2                	mv	a5,s4
    if(disk.free[i]){
    800063c2:	0186c583          	lbu	a1,24(a3)
    800063c6:	fde9                	bnez	a1,800063a0 <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800063c8:	2785                	addiw	a5,a5,1
    800063ca:	0685                	addi	a3,a3,1
    800063cc:	ff779be3          	bne	a5,s7,800063c2 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800063d0:	57fd                	li	a5,-1
    800063d2:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    800063d4:	02905a63          	blez	s1,80006408 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800063d8:	f9042503          	lw	a0,-112(s0)
    800063dc:	00000097          	auipc	ra,0x0
    800063e0:	cfa080e7          	jalr	-774(ra) # 800060d6 <free_desc>
      for(int j = 0; j < i; j++)
    800063e4:	4785                	li	a5,1
    800063e6:	0297d163          	bge	a5,s1,80006408 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800063ea:	f9442503          	lw	a0,-108(s0)
    800063ee:	00000097          	auipc	ra,0x0
    800063f2:	ce8080e7          	jalr	-792(ra) # 800060d6 <free_desc>
      for(int j = 0; j < i; j++)
    800063f6:	4789                	li	a5,2
    800063f8:	0097d863          	bge	a5,s1,80006408 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800063fc:	f9842503          	lw	a0,-104(s0)
    80006400:	00000097          	auipc	ra,0x0
    80006404:	cd6080e7          	jalr	-810(ra) # 800060d6 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006408:	85e2                	mv	a1,s8
    8000640a:	0001d517          	auipc	a0,0x1d
    8000640e:	e5e50513          	addi	a0,a0,-418 # 80023268 <disk+0x18>
    80006412:	ffffc097          	auipc	ra,0xffffc
    80006416:	cec080e7          	jalr	-788(ra) # 800020fe <sleep>
  for(int i = 0; i < 3; i++){
    8000641a:	f9040713          	addi	a4,s0,-112
    8000641e:	84ce                	mv	s1,s3
    80006420:	bf59                	j	800063b6 <virtio_disk_rw+0x6e>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80006422:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    80006426:	00479693          	slli	a3,a5,0x4
    8000642a:	0001d797          	auipc	a5,0x1d
    8000642e:	e2678793          	addi	a5,a5,-474 # 80023250 <disk>
    80006432:	97b6                	add	a5,a5,a3
    80006434:	4685                	li	a3,1
    80006436:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006438:	0001d597          	auipc	a1,0x1d
    8000643c:	e1858593          	addi	a1,a1,-488 # 80023250 <disk>
    80006440:	00a60793          	addi	a5,a2,10
    80006444:	0792                	slli	a5,a5,0x4
    80006446:	97ae                	add	a5,a5,a1
    80006448:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    8000644c:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006450:	f6070693          	addi	a3,a4,-160
    80006454:	619c                	ld	a5,0(a1)
    80006456:	97b6                	add	a5,a5,a3
    80006458:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000645a:	6188                	ld	a0,0(a1)
    8000645c:	96aa                	add	a3,a3,a0
    8000645e:	47c1                	li	a5,16
    80006460:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006462:	4785                	li	a5,1
    80006464:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006468:	f9442783          	lw	a5,-108(s0)
    8000646c:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006470:	0792                	slli	a5,a5,0x4
    80006472:	953e                	add	a0,a0,a5
    80006474:	05890693          	addi	a3,s2,88
    80006478:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000647a:	6188                	ld	a0,0(a1)
    8000647c:	97aa                	add	a5,a5,a0
    8000647e:	40000693          	li	a3,1024
    80006482:	c794                	sw	a3,8(a5)
  if(write)
    80006484:	100d0d63          	beqz	s10,8000659e <virtio_disk_rw+0x256>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006488:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000648c:	00c7d683          	lhu	a3,12(a5)
    80006490:	0016e693          	ori	a3,a3,1
    80006494:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    80006498:	f9842583          	lw	a1,-104(s0)
    8000649c:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800064a0:	0001d697          	auipc	a3,0x1d
    800064a4:	db068693          	addi	a3,a3,-592 # 80023250 <disk>
    800064a8:	00260793          	addi	a5,a2,2
    800064ac:	0792                	slli	a5,a5,0x4
    800064ae:	97b6                	add	a5,a5,a3
    800064b0:	587d                	li	a6,-1
    800064b2:	01078823          	sb	a6,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800064b6:	0592                	slli	a1,a1,0x4
    800064b8:	952e                	add	a0,a0,a1
    800064ba:	f9070713          	addi	a4,a4,-112
    800064be:	9736                	add	a4,a4,a3
    800064c0:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    800064c2:	6298                	ld	a4,0(a3)
    800064c4:	972e                	add	a4,a4,a1
    800064c6:	4585                	li	a1,1
    800064c8:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800064ca:	4509                	li	a0,2
    800064cc:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    800064d0:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800064d4:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    800064d8:	0127b423          	sd	s2,8(a5)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800064dc:	6698                	ld	a4,8(a3)
    800064de:	00275783          	lhu	a5,2(a4)
    800064e2:	8b9d                	andi	a5,a5,7
    800064e4:	0786                	slli	a5,a5,0x1
    800064e6:	97ba                	add	a5,a5,a4
    800064e8:	00c79223          	sh	a2,4(a5)

  __sync_synchronize();
    800064ec:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800064f0:	6698                	ld	a4,8(a3)
    800064f2:	00275783          	lhu	a5,2(a4)
    800064f6:	2785                	addiw	a5,a5,1
    800064f8:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800064fc:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006500:	100017b7          	lui	a5,0x10001
    80006504:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006508:	00492703          	lw	a4,4(s2)
    8000650c:	4785                	li	a5,1
    8000650e:	02f71163          	bne	a4,a5,80006530 <virtio_disk_rw+0x1e8>
    sleep(b, &disk.vdisk_lock);
    80006512:	0001d997          	auipc	s3,0x1d
    80006516:	e6698993          	addi	s3,s3,-410 # 80023378 <disk+0x128>
  while(b->disk == 1) {
    8000651a:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000651c:	85ce                	mv	a1,s3
    8000651e:	854a                	mv	a0,s2
    80006520:	ffffc097          	auipc	ra,0xffffc
    80006524:	bde080e7          	jalr	-1058(ra) # 800020fe <sleep>
  while(b->disk == 1) {
    80006528:	00492783          	lw	a5,4(s2)
    8000652c:	fe9788e3          	beq	a5,s1,8000651c <virtio_disk_rw+0x1d4>
  }

  disk.info[idx[0]].b = 0;
    80006530:	f9042903          	lw	s2,-112(s0)
    80006534:	00290793          	addi	a5,s2,2
    80006538:	00479713          	slli	a4,a5,0x4
    8000653c:	0001d797          	auipc	a5,0x1d
    80006540:	d1478793          	addi	a5,a5,-748 # 80023250 <disk>
    80006544:	97ba                	add	a5,a5,a4
    80006546:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000654a:	0001d997          	auipc	s3,0x1d
    8000654e:	d0698993          	addi	s3,s3,-762 # 80023250 <disk>
    80006552:	00491713          	slli	a4,s2,0x4
    80006556:	0009b783          	ld	a5,0(s3)
    8000655a:	97ba                	add	a5,a5,a4
    8000655c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006560:	854a                	mv	a0,s2
    80006562:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006566:	00000097          	auipc	ra,0x0
    8000656a:	b70080e7          	jalr	-1168(ra) # 800060d6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000656e:	8885                	andi	s1,s1,1
    80006570:	f0ed                	bnez	s1,80006552 <virtio_disk_rw+0x20a>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006572:	0001d517          	auipc	a0,0x1d
    80006576:	e0650513          	addi	a0,a0,-506 # 80023378 <disk+0x128>
    8000657a:	ffffa097          	auipc	ra,0xffffa
    8000657e:	724080e7          	jalr	1828(ra) # 80000c9e <release>
}
    80006582:	70a6                	ld	ra,104(sp)
    80006584:	7406                	ld	s0,96(sp)
    80006586:	64e6                	ld	s1,88(sp)
    80006588:	6946                	ld	s2,80(sp)
    8000658a:	69a6                	ld	s3,72(sp)
    8000658c:	6a06                	ld	s4,64(sp)
    8000658e:	7ae2                	ld	s5,56(sp)
    80006590:	7b42                	ld	s6,48(sp)
    80006592:	7ba2                	ld	s7,40(sp)
    80006594:	7c02                	ld	s8,32(sp)
    80006596:	6ce2                	ld	s9,24(sp)
    80006598:	6d42                	ld	s10,16(sp)
    8000659a:	6165                	addi	sp,sp,112
    8000659c:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000659e:	4689                	li	a3,2
    800065a0:	00d79623          	sh	a3,12(a5)
    800065a4:	b5e5                	j	8000648c <virtio_disk_rw+0x144>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800065a6:	f9042603          	lw	a2,-112(s0)
    800065aa:	00a60713          	addi	a4,a2,10
    800065ae:	0712                	slli	a4,a4,0x4
    800065b0:	0001d517          	auipc	a0,0x1d
    800065b4:	ca850513          	addi	a0,a0,-856 # 80023258 <disk+0x8>
    800065b8:	953a                	add	a0,a0,a4
  if(write)
    800065ba:	e60d14e3          	bnez	s10,80006422 <virtio_disk_rw+0xda>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    800065be:	00a60793          	addi	a5,a2,10
    800065c2:	00479693          	slli	a3,a5,0x4
    800065c6:	0001d797          	auipc	a5,0x1d
    800065ca:	c8a78793          	addi	a5,a5,-886 # 80023250 <disk>
    800065ce:	97b6                	add	a5,a5,a3
    800065d0:	0007a423          	sw	zero,8(a5)
    800065d4:	b595                	j	80006438 <virtio_disk_rw+0xf0>

00000000800065d6 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800065d6:	1101                	addi	sp,sp,-32
    800065d8:	ec06                	sd	ra,24(sp)
    800065da:	e822                	sd	s0,16(sp)
    800065dc:	e426                	sd	s1,8(sp)
    800065de:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800065e0:	0001d497          	auipc	s1,0x1d
    800065e4:	c7048493          	addi	s1,s1,-912 # 80023250 <disk>
    800065e8:	0001d517          	auipc	a0,0x1d
    800065ec:	d9050513          	addi	a0,a0,-624 # 80023378 <disk+0x128>
    800065f0:	ffffa097          	auipc	ra,0xffffa
    800065f4:	5fa080e7          	jalr	1530(ra) # 80000bea <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800065f8:	10001737          	lui	a4,0x10001
    800065fc:	533c                	lw	a5,96(a4)
    800065fe:	8b8d                	andi	a5,a5,3
    80006600:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006602:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006606:	689c                	ld	a5,16(s1)
    80006608:	0204d703          	lhu	a4,32(s1)
    8000660c:	0027d783          	lhu	a5,2(a5)
    80006610:	04f70863          	beq	a4,a5,80006660 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006614:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006618:	6898                	ld	a4,16(s1)
    8000661a:	0204d783          	lhu	a5,32(s1)
    8000661e:	8b9d                	andi	a5,a5,7
    80006620:	078e                	slli	a5,a5,0x3
    80006622:	97ba                	add	a5,a5,a4
    80006624:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006626:	00278713          	addi	a4,a5,2
    8000662a:	0712                	slli	a4,a4,0x4
    8000662c:	9726                	add	a4,a4,s1
    8000662e:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006632:	e721                	bnez	a4,8000667a <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006634:	0789                	addi	a5,a5,2
    80006636:	0792                	slli	a5,a5,0x4
    80006638:	97a6                	add	a5,a5,s1
    8000663a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000663c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006640:	ffffc097          	auipc	ra,0xffffc
    80006644:	c6e080e7          	jalr	-914(ra) # 800022ae <wakeup>

    disk.used_idx += 1;
    80006648:	0204d783          	lhu	a5,32(s1)
    8000664c:	2785                	addiw	a5,a5,1
    8000664e:	17c2                	slli	a5,a5,0x30
    80006650:	93c1                	srli	a5,a5,0x30
    80006652:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006656:	6898                	ld	a4,16(s1)
    80006658:	00275703          	lhu	a4,2(a4)
    8000665c:	faf71ce3          	bne	a4,a5,80006614 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006660:	0001d517          	auipc	a0,0x1d
    80006664:	d1850513          	addi	a0,a0,-744 # 80023378 <disk+0x128>
    80006668:	ffffa097          	auipc	ra,0xffffa
    8000666c:	636080e7          	jalr	1590(ra) # 80000c9e <release>
}
    80006670:	60e2                	ld	ra,24(sp)
    80006672:	6442                	ld	s0,16(sp)
    80006674:	64a2                	ld	s1,8(sp)
    80006676:	6105                	addi	sp,sp,32
    80006678:	8082                	ret
      panic("virtio_disk_intr status");
    8000667a:	00002517          	auipc	a0,0x2
    8000667e:	32e50513          	addi	a0,a0,814 # 800089a8 <syscallnum+0x388>
    80006682:	ffffa097          	auipc	ra,0xffffa
    80006686:	ec2080e7          	jalr	-318(ra) # 80000544 <panic>
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

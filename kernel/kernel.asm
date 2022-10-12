
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	c8010113          	addi	sp,sp,-896 # 80008c80 <stack0>
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
    80000056:	aee70713          	addi	a4,a4,-1298 # 80008b40 <timer_scratch>
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
    80000068:	07c78793          	addi	a5,a5,124 # 800060e0 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb44f>
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
    80000130:	612080e7          	jalr	1554(ra) # 8000273e <either_copyin>
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
    80000190:	af450513          	addi	a0,a0,-1292 # 80010c80 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	a56080e7          	jalr	-1450(ra) # 80000bea <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019c:	00011497          	auipc	s1,0x11
    800001a0:	ae448493          	addi	s1,s1,-1308 # 80010c80 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a4:	89a6                	mv	s3,s1
    800001a6:	00011917          	auipc	s2,0x11
    800001aa:	b7290913          	addi	s2,s2,-1166 # 80010d18 <cons+0x98>
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
    800001d0:	3bc080e7          	jalr	956(ra) # 80002588 <killed>
    800001d4:	e535                	bnez	a0,80000240 <consoleread+0xdc>
      sleep(&cons.r, &cons.lock);
    800001d6:	85ce                	mv	a1,s3
    800001d8:	854a                	mv	a0,s2
    800001da:	00002097          	auipc	ra,0x2
    800001de:	fae080e7          	jalr	-82(ra) # 80002188 <sleep>
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
    8000021a:	4d2080e7          	jalr	1234(ra) # 800026e8 <either_copyout>
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
    8000022e:	a5650513          	addi	a0,a0,-1450 # 80010c80 <cons>
    80000232:	00001097          	auipc	ra,0x1
    80000236:	a6c080e7          	jalr	-1428(ra) # 80000c9e <release>

  return target - n;
    8000023a:	414b853b          	subw	a0,s7,s4
    8000023e:	a811                	j	80000252 <consoleread+0xee>
        release(&cons.lock);
    80000240:	00011517          	auipc	a0,0x11
    80000244:	a4050513          	addi	a0,a0,-1472 # 80010c80 <cons>
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
    8000027c:	aaf72023          	sw	a5,-1376(a4) # 80010d18 <cons+0x98>
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
    800002d6:	9ae50513          	addi	a0,a0,-1618 # 80010c80 <cons>
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
    800002fc:	49c080e7          	jalr	1180(ra) # 80002794 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000300:	00011517          	auipc	a0,0x11
    80000304:	98050513          	addi	a0,a0,-1664 # 80010c80 <cons>
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
    80000328:	95c70713          	addi	a4,a4,-1700 # 80010c80 <cons>
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
    80000352:	93278793          	addi	a5,a5,-1742 # 80010c80 <cons>
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
    80000380:	99c7a783          	lw	a5,-1636(a5) # 80010d18 <cons+0x98>
    80000384:	9f1d                	subw	a4,a4,a5
    80000386:	08000793          	li	a5,128
    8000038a:	f6f71be3          	bne	a4,a5,80000300 <consoleintr+0x3c>
    8000038e:	a07d                	j	8000043c <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000390:	00011717          	auipc	a4,0x11
    80000394:	8f070713          	addi	a4,a4,-1808 # 80010c80 <cons>
    80000398:	0a072783          	lw	a5,160(a4)
    8000039c:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a0:	00011497          	auipc	s1,0x11
    800003a4:	8e048493          	addi	s1,s1,-1824 # 80010c80 <cons>
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
    800003e0:	8a470713          	addi	a4,a4,-1884 # 80010c80 <cons>
    800003e4:	0a072783          	lw	a5,160(a4)
    800003e8:	09c72703          	lw	a4,156(a4)
    800003ec:	f0f70ae3          	beq	a4,a5,80000300 <consoleintr+0x3c>
      cons.e--;
    800003f0:	37fd                	addiw	a5,a5,-1
    800003f2:	00011717          	auipc	a4,0x11
    800003f6:	92f72723          	sw	a5,-1746(a4) # 80010d20 <cons+0xa0>
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
    8000041c:	86878793          	addi	a5,a5,-1944 # 80010c80 <cons>
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
    80000440:	8ec7a023          	sw	a2,-1824(a5) # 80010d1c <cons+0x9c>
        wakeup(&cons.r);
    80000444:	00011517          	auipc	a0,0x11
    80000448:	8d450513          	addi	a0,a0,-1836 # 80010d18 <cons+0x98>
    8000044c:	00002097          	auipc	ra,0x2
    80000450:	eec080e7          	jalr	-276(ra) # 80002338 <wakeup>
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
    8000046a:	81a50513          	addi	a0,a0,-2022 # 80010c80 <cons>
    8000046e:	00000097          	auipc	ra,0x0
    80000472:	6ec080e7          	jalr	1772(ra) # 80000b5a <initlock>

  uartinit();
    80000476:	00000097          	auipc	ra,0x0
    8000047a:	330080e7          	jalr	816(ra) # 800007a6 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000047e:	00022797          	auipc	a5,0x22
    80000482:	d9a78793          	addi	a5,a5,-614 # 80022218 <devsw>
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
    80000554:	7e07a823          	sw	zero,2032(a5) # 80010d40 <pr+0x18>
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
    80000588:	56f72e23          	sw	a5,1404(a4) # 80008b00 <panicked>
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
    800005c4:	780dad83          	lw	s11,1920(s11) # 80010d40 <pr+0x18>
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
    80000602:	72a50513          	addi	a0,a0,1834 # 80010d28 <pr>
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
    80000766:	5c650513          	addi	a0,a0,1478 # 80010d28 <pr>
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
    80000782:	5aa48493          	addi	s1,s1,1450 # 80010d28 <pr>
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
    800007e2:	56a50513          	addi	a0,a0,1386 # 80010d48 <uart_tx_lock>
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
    8000080e:	2f67a783          	lw	a5,758(a5) # 80008b00 <panicked>
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
    8000084a:	2c273703          	ld	a4,706(a4) # 80008b08 <uart_tx_r>
    8000084e:	00008797          	auipc	a5,0x8
    80000852:	2c27b783          	ld	a5,706(a5) # 80008b10 <uart_tx_w>
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
    80000874:	4d8a0a13          	addi	s4,s4,1240 # 80010d48 <uart_tx_lock>
    uart_tx_r += 1;
    80000878:	00008497          	auipc	s1,0x8
    8000087c:	29048493          	addi	s1,s1,656 # 80008b08 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000880:	00008997          	auipc	s3,0x8
    80000884:	29098993          	addi	s3,s3,656 # 80008b10 <uart_tx_w>
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
    800008aa:	a92080e7          	jalr	-1390(ra) # 80002338 <wakeup>
    
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
    800008e6:	46650513          	addi	a0,a0,1126 # 80010d48 <uart_tx_lock>
    800008ea:	00000097          	auipc	ra,0x0
    800008ee:	300080e7          	jalr	768(ra) # 80000bea <acquire>
  if(panicked){
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	20e7a783          	lw	a5,526(a5) # 80008b00 <panicked>
    800008fa:	e7c9                	bnez	a5,80000984 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fc:	00008797          	auipc	a5,0x8
    80000900:	2147b783          	ld	a5,532(a5) # 80008b10 <uart_tx_w>
    80000904:	00008717          	auipc	a4,0x8
    80000908:	20473703          	ld	a4,516(a4) # 80008b08 <uart_tx_r>
    8000090c:	02070713          	addi	a4,a4,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000910:	00010a17          	auipc	s4,0x10
    80000914:	438a0a13          	addi	s4,s4,1080 # 80010d48 <uart_tx_lock>
    80000918:	00008497          	auipc	s1,0x8
    8000091c:	1f048493          	addi	s1,s1,496 # 80008b08 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000920:	00008917          	auipc	s2,0x8
    80000924:	1f090913          	addi	s2,s2,496 # 80008b10 <uart_tx_w>
    80000928:	00f71f63          	bne	a4,a5,80000946 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000092c:	85d2                	mv	a1,s4
    8000092e:	8526                	mv	a0,s1
    80000930:	00002097          	auipc	ra,0x2
    80000934:	858080e7          	jalr	-1960(ra) # 80002188 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000938:	00093783          	ld	a5,0(s2)
    8000093c:	6098                	ld	a4,0(s1)
    8000093e:	02070713          	addi	a4,a4,32
    80000942:	fef705e3          	beq	a4,a5,8000092c <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000946:	00010497          	auipc	s1,0x10
    8000094a:	40248493          	addi	s1,s1,1026 # 80010d48 <uart_tx_lock>
    8000094e:	01f7f713          	andi	a4,a5,31
    80000952:	9726                	add	a4,a4,s1
    80000954:	01370c23          	sb	s3,24(a4)
  uart_tx_w += 1;
    80000958:	0785                	addi	a5,a5,1
    8000095a:	00008717          	auipc	a4,0x8
    8000095e:	1af73b23          	sd	a5,438(a4) # 80008b10 <uart_tx_w>
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
    800009d4:	37848493          	addi	s1,s1,888 # 80010d48 <uart_tx_lock>
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
    80000a16:	99e78793          	addi	a5,a5,-1634 # 800233b0 <end>
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
    80000a36:	34e90913          	addi	s2,s2,846 # 80010d80 <kmem>
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
    80000ad2:	2b250513          	addi	a0,a0,690 # 80010d80 <kmem>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	084080e7          	jalr	132(ra) # 80000b5a <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ade:	45c5                	li	a1,17
    80000ae0:	05ee                	slli	a1,a1,0x1b
    80000ae2:	00023517          	auipc	a0,0x23
    80000ae6:	8ce50513          	addi	a0,a0,-1842 # 800233b0 <end>
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
    80000b08:	27c48493          	addi	s1,s1,636 # 80010d80 <kmem>
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
    80000b20:	26450513          	addi	a0,a0,612 # 80010d80 <kmem>
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
    80000b4c:	23850513          	addi	a0,a0,568 # 80010d80 <kmem>
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
    80000ea8:	c7470713          	addi	a4,a4,-908 # 80008b18 <started>
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
    80000ede:	9fa080e7          	jalr	-1542(ra) # 800028d4 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ee2:	00005097          	auipc	ra,0x5
    80000ee6:	23e080e7          	jalr	574(ra) # 80006120 <plicinithart>
  }

  scheduler();        
    80000eea:	00001097          	auipc	ra,0x1
    80000eee:	0a4080e7          	jalr	164(ra) # 80001f8e <scheduler>
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
    80000f56:	95a080e7          	jalr	-1702(ra) # 800028ac <trapinit>
    trapinithart();  // install kernel trap vector
    80000f5a:	00002097          	auipc	ra,0x2
    80000f5e:	97a080e7          	jalr	-1670(ra) # 800028d4 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	1a8080e7          	jalr	424(ra) # 8000610a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f6a:	00005097          	auipc	ra,0x5
    80000f6e:	1b6080e7          	jalr	438(ra) # 80006120 <plicinithart>
    binit();         // buffer cache
    80000f72:	00002097          	auipc	ra,0x2
    80000f76:	362080e7          	jalr	866(ra) # 800032d4 <binit>
    iinit();         // inode table
    80000f7a:	00003097          	auipc	ra,0x3
    80000f7e:	a06080e7          	jalr	-1530(ra) # 80003980 <iinit>
    fileinit();      // file table
    80000f82:	00004097          	auipc	ra,0x4
    80000f86:	9a4080e7          	jalr	-1628(ra) # 80004926 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f8a:	00005097          	auipc	ra,0x5
    80000f8e:	29e080e7          	jalr	670(ra) # 80006228 <virtio_disk_init>
    userinit();      // first user process
    80000f92:	00001097          	auipc	ra,0x1
    80000f96:	d4e080e7          	jalr	-690(ra) # 80001ce0 <userinit>
    __sync_synchronize();
    80000f9a:	0ff0000f          	fence
    started = 1;
    80000f9e:	4785                	li	a5,1
    80000fa0:	00008717          	auipc	a4,0x8
    80000fa4:	b6f72c23          	sw	a5,-1160(a4) # 80008b18 <started>
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
    80000fb8:	b6c7b783          	ld	a5,-1172(a5) # 80008b20 <kernel_pagetable>
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
    80001274:	8aa7b823          	sd	a0,-1872(a5) # 80008b20 <kernel_pagetable>
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
    8000186a:	96a48493          	addi	s1,s1,-1686 # 800111d0 <proc>
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
    80001884:	750a0a13          	addi	s4,s4,1872 # 80017fd0 <tickslock>
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
    80001906:	49e50513          	addi	a0,a0,1182 # 80010da0 <pid_lock>
    8000190a:	fffff097          	auipc	ra,0xfffff
    8000190e:	250080e7          	jalr	592(ra) # 80000b5a <initlock>
  initlock(&wait_lock, "wait_lock");
    80001912:	00007597          	auipc	a1,0x7
    80001916:	8d658593          	addi	a1,a1,-1834 # 800081e8 <digits+0x1a8>
    8000191a:	0000f517          	auipc	a0,0xf
    8000191e:	49e50513          	addi	a0,a0,1182 # 80010db8 <wait_lock>
    80001922:	fffff097          	auipc	ra,0xfffff
    80001926:	238080e7          	jalr	568(ra) # 80000b5a <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000192a:	00010497          	auipc	s1,0x10
    8000192e:	8a648493          	addi	s1,s1,-1882 # 800111d0 <proc>
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
    80001950:	68498993          	addi	s3,s3,1668 # 80017fd0 <tickslock>
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
    800019ba:	41a50513          	addi	a0,a0,1050 # 80010dd0 <cpus>
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
    800019e2:	3c270713          	addi	a4,a4,962 # 80010da0 <pid_lock>
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
    80001a1a:	fca7a783          	lw	a5,-54(a5) # 800089e0 <first.1727>
    80001a1e:	eb89                	bnez	a5,80001a30 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a20:	00001097          	auipc	ra,0x1
    80001a24:	ecc080e7          	jalr	-308(ra) # 800028ec <usertrapret>
}
    80001a28:	60a2                	ld	ra,8(sp)
    80001a2a:	6402                	ld	s0,0(sp)
    80001a2c:	0141                	addi	sp,sp,16
    80001a2e:	8082                	ret
    first = 0;
    80001a30:	00007797          	auipc	a5,0x7
    80001a34:	fa07a823          	sw	zero,-80(a5) # 800089e0 <first.1727>
    fsinit(ROOTDEV);
    80001a38:	4505                	li	a0,1
    80001a3a:	00002097          	auipc	ra,0x2
    80001a3e:	ec6080e7          	jalr	-314(ra) # 80003900 <fsinit>
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
    80001a54:	35090913          	addi	s2,s2,848 # 80010da0 <pid_lock>
    80001a58:	854a                	mv	a0,s2
    80001a5a:	fffff097          	auipc	ra,0xfffff
    80001a5e:	190080e7          	jalr	400(ra) # 80000bea <acquire>
  pid = nextpid;
    80001a62:	00007797          	auipc	a5,0x7
    80001a66:	f8278793          	addi	a5,a5,-126 # 800089e4 <nextpid>
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
    80001be0:	5f448493          	addi	s1,s1,1524 # 800111d0 <proc>
    80001be4:	00016917          	auipc	s2,0x16
    80001be8:	3ec90913          	addi	s2,s2,1004 # 80017fd0 <tickslock>
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
    80001c0e:	a071                	j	80001c9a <allocproc+0xca>
  p->pid = allocpid();
    80001c10:	00000097          	auipc	ra,0x0
    80001c14:	e34080e7          	jalr	-460(ra) # 80001a44 <allocpid>
    80001c18:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c1a:	4785                	li	a5,1
    80001c1c:	cc9c                	sw	a5,24(s1)
  p->time_created = ticks;
    80001c1e:	00007797          	auipc	a5,0x7
    80001c22:	f127e783          	lwu	a5,-238(a5) # 80008b30 <ticks>
    80001c26:	16f4bc23          	sd	a5,376(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c2a:	fffff097          	auipc	ra,0xfffff
    80001c2e:	ed0080e7          	jalr	-304(ra) # 80000afa <kalloc>
    80001c32:	892a                	mv	s2,a0
    80001c34:	eca8                	sd	a0,88(s1)
    80001c36:	c92d                	beqz	a0,80001ca8 <allocproc+0xd8>
  p->pagetable = proc_pagetable(p);
    80001c38:	8526                	mv	a0,s1
    80001c3a:	00000097          	auipc	ra,0x0
    80001c3e:	e50080e7          	jalr	-432(ra) # 80001a8a <proc_pagetable>
    80001c42:	892a                	mv	s2,a0
    80001c44:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c46:	cd2d                	beqz	a0,80001cc0 <allocproc+0xf0>
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
    80001c78:	ebc7a783          	lw	a5,-324(a5) # 80008b30 <ticks>
    80001c7c:	16f4a823          	sw	a5,368(s1)
  p->alarm_on = 0;
    80001c80:	1804ac23          	sw	zero,408(s1)
  p->cur_ticks = 0;
    80001c84:	1804a623          	sw	zero,396(s1)
  p->handlerpermission = 1;
    80001c88:	4785                	li	a5,1
    80001c8a:	1af4a823          	sw	a5,432(s1)
  if(p->parent != 0){
    80001c8e:	7c9c                	ld	a5,56(s1)
    80001c90:	c7a1                	beqz	a5,80001cd8 <allocproc+0x108>
    p->tickets = p->parent->tickets;
    80001c92:	1b47a783          	lw	a5,436(a5)
    80001c96:	1af4aa23          	sw	a5,436(s1)
}
    80001c9a:	8526                	mv	a0,s1
    80001c9c:	60e2                	ld	ra,24(sp)
    80001c9e:	6442                	ld	s0,16(sp)
    80001ca0:	64a2                	ld	s1,8(sp)
    80001ca2:	6902                	ld	s2,0(sp)
    80001ca4:	6105                	addi	sp,sp,32
    80001ca6:	8082                	ret
    freeproc(p);
    80001ca8:	8526                	mv	a0,s1
    80001caa:	00000097          	auipc	ra,0x0
    80001cae:	ece080e7          	jalr	-306(ra) # 80001b78 <freeproc>
    release(&p->lock);
    80001cb2:	8526                	mv	a0,s1
    80001cb4:	fffff097          	auipc	ra,0xfffff
    80001cb8:	fea080e7          	jalr	-22(ra) # 80000c9e <release>
    return 0;
    80001cbc:	84ca                	mv	s1,s2
    80001cbe:	bff1                	j	80001c9a <allocproc+0xca>
    freeproc(p);
    80001cc0:	8526                	mv	a0,s1
    80001cc2:	00000097          	auipc	ra,0x0
    80001cc6:	eb6080e7          	jalr	-330(ra) # 80001b78 <freeproc>
    release(&p->lock);
    80001cca:	8526                	mv	a0,s1
    80001ccc:	fffff097          	auipc	ra,0xfffff
    80001cd0:	fd2080e7          	jalr	-46(ra) # 80000c9e <release>
    return 0;
    80001cd4:	84ca                	mv	s1,s2
    80001cd6:	b7d1                	j	80001c9a <allocproc+0xca>
    p->tickets = 1;
    80001cd8:	4785                	li	a5,1
    80001cda:	1af4aa23          	sw	a5,436(s1)
    80001cde:	bf75                	j	80001c9a <allocproc+0xca>

0000000080001ce0 <userinit>:
{
    80001ce0:	1101                	addi	sp,sp,-32
    80001ce2:	ec06                	sd	ra,24(sp)
    80001ce4:	e822                	sd	s0,16(sp)
    80001ce6:	e426                	sd	s1,8(sp)
    80001ce8:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cea:	00000097          	auipc	ra,0x0
    80001cee:	ee6080e7          	jalr	-282(ra) # 80001bd0 <allocproc>
    80001cf2:	84aa                	mv	s1,a0
  initproc = p;
    80001cf4:	00007797          	auipc	a5,0x7
    80001cf8:	e2a7ba23          	sd	a0,-460(a5) # 80008b28 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cfc:	03400613          	li	a2,52
    80001d00:	00007597          	auipc	a1,0x7
    80001d04:	cf058593          	addi	a1,a1,-784 # 800089f0 <initcode>
    80001d08:	6928                	ld	a0,80(a0)
    80001d0a:	fffff097          	auipc	ra,0xfffff
    80001d0e:	668080e7          	jalr	1640(ra) # 80001372 <uvmfirst>
  p->sz = PGSIZE;
    80001d12:	6785                	lui	a5,0x1
    80001d14:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d16:	6cb8                	ld	a4,88(s1)
    80001d18:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d1c:	6cb8                	ld	a4,88(s1)
    80001d1e:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d20:	4641                	li	a2,16
    80001d22:	00006597          	auipc	a1,0x6
    80001d26:	4de58593          	addi	a1,a1,1246 # 80008200 <digits+0x1c0>
    80001d2a:	15848513          	addi	a0,s1,344
    80001d2e:	fffff097          	auipc	ra,0xfffff
    80001d32:	10a080e7          	jalr	266(ra) # 80000e38 <safestrcpy>
  p->cwd = namei("/");
    80001d36:	00006517          	auipc	a0,0x6
    80001d3a:	4da50513          	addi	a0,a0,1242 # 80008210 <digits+0x1d0>
    80001d3e:	00002097          	auipc	ra,0x2
    80001d42:	5e4080e7          	jalr	1508(ra) # 80004322 <namei>
    80001d46:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d4a:	478d                	li	a5,3
    80001d4c:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d4e:	8526                	mv	a0,s1
    80001d50:	fffff097          	auipc	ra,0xfffff
    80001d54:	f4e080e7          	jalr	-178(ra) # 80000c9e <release>
}
    80001d58:	60e2                	ld	ra,24(sp)
    80001d5a:	6442                	ld	s0,16(sp)
    80001d5c:	64a2                	ld	s1,8(sp)
    80001d5e:	6105                	addi	sp,sp,32
    80001d60:	8082                	ret

0000000080001d62 <growproc>:
{
    80001d62:	1101                	addi	sp,sp,-32
    80001d64:	ec06                	sd	ra,24(sp)
    80001d66:	e822                	sd	s0,16(sp)
    80001d68:	e426                	sd	s1,8(sp)
    80001d6a:	e04a                	sd	s2,0(sp)
    80001d6c:	1000                	addi	s0,sp,32
    80001d6e:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d70:	00000097          	auipc	ra,0x0
    80001d74:	c56080e7          	jalr	-938(ra) # 800019c6 <myproc>
    80001d78:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d7a:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d7c:	01204c63          	bgtz	s2,80001d94 <growproc+0x32>
  } else if(n < 0){
    80001d80:	02094663          	bltz	s2,80001dac <growproc+0x4a>
  p->sz = sz;
    80001d84:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d86:	4501                	li	a0,0
}
    80001d88:	60e2                	ld	ra,24(sp)
    80001d8a:	6442                	ld	s0,16(sp)
    80001d8c:	64a2                	ld	s1,8(sp)
    80001d8e:	6902                	ld	s2,0(sp)
    80001d90:	6105                	addi	sp,sp,32
    80001d92:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d94:	4691                	li	a3,4
    80001d96:	00b90633          	add	a2,s2,a1
    80001d9a:	6928                	ld	a0,80(a0)
    80001d9c:	fffff097          	auipc	ra,0xfffff
    80001da0:	690080e7          	jalr	1680(ra) # 8000142c <uvmalloc>
    80001da4:	85aa                	mv	a1,a0
    80001da6:	fd79                	bnez	a0,80001d84 <growproc+0x22>
      return -1;
    80001da8:	557d                	li	a0,-1
    80001daa:	bff9                	j	80001d88 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001dac:	00b90633          	add	a2,s2,a1
    80001db0:	6928                	ld	a0,80(a0)
    80001db2:	fffff097          	auipc	ra,0xfffff
    80001db6:	632080e7          	jalr	1586(ra) # 800013e4 <uvmdealloc>
    80001dba:	85aa                	mv	a1,a0
    80001dbc:	b7e1                	j	80001d84 <growproc+0x22>

0000000080001dbe <fork>:
{
    80001dbe:	7179                	addi	sp,sp,-48
    80001dc0:	f406                	sd	ra,40(sp)
    80001dc2:	f022                	sd	s0,32(sp)
    80001dc4:	ec26                	sd	s1,24(sp)
    80001dc6:	e84a                	sd	s2,16(sp)
    80001dc8:	e44e                	sd	s3,8(sp)
    80001dca:	e052                	sd	s4,0(sp)
    80001dcc:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001dce:	00000097          	auipc	ra,0x0
    80001dd2:	bf8080e7          	jalr	-1032(ra) # 800019c6 <myproc>
    80001dd6:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001dd8:	00000097          	auipc	ra,0x0
    80001ddc:	df8080e7          	jalr	-520(ra) # 80001bd0 <allocproc>
    80001de0:	10050f63          	beqz	a0,80001efe <fork+0x140>
    80001de4:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001de6:	04893603          	ld	a2,72(s2)
    80001dea:	692c                	ld	a1,80(a0)
    80001dec:	05093503          	ld	a0,80(s2)
    80001df0:	fffff097          	auipc	ra,0xfffff
    80001df4:	790080e7          	jalr	1936(ra) # 80001580 <uvmcopy>
    80001df8:	04054a63          	bltz	a0,80001e4c <fork+0x8e>
  np->sz = p->sz;
    80001dfc:	04893783          	ld	a5,72(s2)
    80001e00:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001e04:	05893683          	ld	a3,88(s2)
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
    80001e2e:	fed792e3          	bne	a5,a3,80001e12 <fork+0x54>
  np->mask = p->mask;
    80001e32:	16892783          	lw	a5,360(s2)
    80001e36:	16f9a423          	sw	a5,360(s3)
  np->trapframe->a0 = 0;
    80001e3a:	0589b783          	ld	a5,88(s3)
    80001e3e:	0607b823          	sd	zero,112(a5)
    80001e42:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001e46:	15000a13          	li	s4,336
    80001e4a:	a03d                	j	80001e78 <fork+0xba>
    freeproc(np);
    80001e4c:	854e                	mv	a0,s3
    80001e4e:	00000097          	auipc	ra,0x0
    80001e52:	d2a080e7          	jalr	-726(ra) # 80001b78 <freeproc>
    release(&np->lock);
    80001e56:	854e                	mv	a0,s3
    80001e58:	fffff097          	auipc	ra,0xfffff
    80001e5c:	e46080e7          	jalr	-442(ra) # 80000c9e <release>
    return -1;
    80001e60:	5a7d                	li	s4,-1
    80001e62:	a069                	j	80001eec <fork+0x12e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e64:	00003097          	auipc	ra,0x3
    80001e68:	b54080e7          	jalr	-1196(ra) # 800049b8 <filedup>
    80001e6c:	009987b3          	add	a5,s3,s1
    80001e70:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001e72:	04a1                	addi	s1,s1,8
    80001e74:	01448763          	beq	s1,s4,80001e82 <fork+0xc4>
    if(p->ofile[i])
    80001e78:	009907b3          	add	a5,s2,s1
    80001e7c:	6388                	ld	a0,0(a5)
    80001e7e:	f17d                	bnez	a0,80001e64 <fork+0xa6>
    80001e80:	bfcd                	j	80001e72 <fork+0xb4>
  np->cwd = idup(p->cwd);
    80001e82:	15093503          	ld	a0,336(s2)
    80001e86:	00002097          	auipc	ra,0x2
    80001e8a:	cb8080e7          	jalr	-840(ra) # 80003b3e <idup>
    80001e8e:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e92:	4641                	li	a2,16
    80001e94:	15890593          	addi	a1,s2,344
    80001e98:	15898513          	addi	a0,s3,344
    80001e9c:	fffff097          	auipc	ra,0xfffff
    80001ea0:	f9c080e7          	jalr	-100(ra) # 80000e38 <safestrcpy>
  pid = np->pid;
    80001ea4:	0309aa03          	lw	s4,48(s3)
  release(&np->lock);
    80001ea8:	854e                	mv	a0,s3
    80001eaa:	fffff097          	auipc	ra,0xfffff
    80001eae:	df4080e7          	jalr	-524(ra) # 80000c9e <release>
  acquire(&wait_lock);
    80001eb2:	0000f497          	auipc	s1,0xf
    80001eb6:	f0648493          	addi	s1,s1,-250 # 80010db8 <wait_lock>
    80001eba:	8526                	mv	a0,s1
    80001ebc:	fffff097          	auipc	ra,0xfffff
    80001ec0:	d2e080e7          	jalr	-722(ra) # 80000bea <acquire>
  np->parent = p;
    80001ec4:	0329bc23          	sd	s2,56(s3)
  release(&wait_lock);
    80001ec8:	8526                	mv	a0,s1
    80001eca:	fffff097          	auipc	ra,0xfffff
    80001ece:	dd4080e7          	jalr	-556(ra) # 80000c9e <release>
  acquire(&np->lock);
    80001ed2:	854e                	mv	a0,s3
    80001ed4:	fffff097          	auipc	ra,0xfffff
    80001ed8:	d16080e7          	jalr	-746(ra) # 80000bea <acquire>
  np->state = RUNNABLE;
    80001edc:	478d                	li	a5,3
    80001ede:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001ee2:	854e                	mv	a0,s3
    80001ee4:	fffff097          	auipc	ra,0xfffff
    80001ee8:	dba080e7          	jalr	-582(ra) # 80000c9e <release>
}
    80001eec:	8552                	mv	a0,s4
    80001eee:	70a2                	ld	ra,40(sp)
    80001ef0:	7402                	ld	s0,32(sp)
    80001ef2:	64e2                	ld	s1,24(sp)
    80001ef4:	6942                	ld	s2,16(sp)
    80001ef6:	69a2                	ld	s3,8(sp)
    80001ef8:	6a02                	ld	s4,0(sp)
    80001efa:	6145                	addi	sp,sp,48
    80001efc:	8082                	ret
    return -1;
    80001efe:	5a7d                	li	s4,-1
    80001f00:	b7f5                	j	80001eec <fork+0x12e>

0000000080001f02 <update_time>:
{
    80001f02:	7179                	addi	sp,sp,-48
    80001f04:	f406                	sd	ra,40(sp)
    80001f06:	f022                	sd	s0,32(sp)
    80001f08:	ec26                	sd	s1,24(sp)
    80001f0a:	e84a                	sd	s2,16(sp)
    80001f0c:	e44e                	sd	s3,8(sp)
    80001f0e:	1800                	addi	s0,sp,48
  for (p = proc; p < &proc[NPROC]; p++) {
    80001f10:	0000f497          	auipc	s1,0xf
    80001f14:	2c048493          	addi	s1,s1,704 # 800111d0 <proc>
    if (p->state == RUNNING) {
    80001f18:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++) {
    80001f1a:	00016917          	auipc	s2,0x16
    80001f1e:	0b690913          	addi	s2,s2,182 # 80017fd0 <tickslock>
    80001f22:	a811                	j	80001f36 <update_time+0x34>
    release(&p->lock); 
    80001f24:	8526                	mv	a0,s1
    80001f26:	fffff097          	auipc	ra,0xfffff
    80001f2a:	d78080e7          	jalr	-648(ra) # 80000c9e <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001f2e:	1b848493          	addi	s1,s1,440
    80001f32:	03248063          	beq	s1,s2,80001f52 <update_time+0x50>
    acquire(&p->lock);
    80001f36:	8526                	mv	a0,s1
    80001f38:	fffff097          	auipc	ra,0xfffff
    80001f3c:	cb2080e7          	jalr	-846(ra) # 80000bea <acquire>
    if (p->state == RUNNING) {
    80001f40:	4c9c                	lw	a5,24(s1)
    80001f42:	ff3791e3          	bne	a5,s3,80001f24 <update_time+0x22>
      p->rtime++;
    80001f46:	16c4a783          	lw	a5,364(s1)
    80001f4a:	2785                	addiw	a5,a5,1
    80001f4c:	16f4a623          	sw	a5,364(s1)
    80001f50:	bfd1                	j	80001f24 <update_time+0x22>
}
    80001f52:	70a2                	ld	ra,40(sp)
    80001f54:	7402                	ld	s0,32(sp)
    80001f56:	64e2                	ld	s1,24(sp)
    80001f58:	6942                	ld	s2,16(sp)
    80001f5a:	69a2                	ld	s3,8(sp)
    80001f5c:	6145                	addi	sp,sp,48
    80001f5e:	8082                	ret

0000000080001f60 <randomnum>:
{
    80001f60:	1141                	addi	sp,sp,-16
    80001f62:	e422                	sd	s0,8(sp)
    80001f64:	0800                	addi	s0,sp,16
  uint64 num = (uint64)ticks;
    80001f66:	00007797          	auipc	a5,0x7
    80001f6a:	bca7e783          	lwu	a5,-1078(a5) # 80008b30 <ticks>
  num = num ^ (num << 13);
    80001f6e:	00d79713          	slli	a4,a5,0xd
    80001f72:	8fb9                	xor	a5,a5,a4
  num = num ^ (num >> 17);
    80001f74:	0117d713          	srli	a4,a5,0x11
    80001f78:	8f3d                	xor	a4,a4,a5
  num = num ^ (num << 5);
    80001f7a:	00571793          	slli	a5,a4,0x5
    80001f7e:	8fb9                	xor	a5,a5,a4
  num = num % (max - min);
    80001f80:	9d89                	subw	a1,a1,a0
    80001f82:	02b7f7b3          	remu	a5,a5,a1
}
    80001f86:	9d3d                	addw	a0,a0,a5
    80001f88:	6422                	ld	s0,8(sp)
    80001f8a:	0141                	addi	sp,sp,16
    80001f8c:	8082                	ret

0000000080001f8e <scheduler>:
{
    80001f8e:	715d                	addi	sp,sp,-80
    80001f90:	e486                	sd	ra,72(sp)
    80001f92:	e0a2                	sd	s0,64(sp)
    80001f94:	fc26                	sd	s1,56(sp)
    80001f96:	f84a                	sd	s2,48(sp)
    80001f98:	f44e                	sd	s3,40(sp)
    80001f9a:	f052                	sd	s4,32(sp)
    80001f9c:	ec56                	sd	s5,24(sp)
    80001f9e:	e85a                	sd	s6,16(sp)
    80001fa0:	e45e                	sd	s7,8(sp)
    80001fa2:	0880                	addi	s0,sp,80
    80001fa4:	8792                	mv	a5,tp
  int id = r_tp();
    80001fa6:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001fa8:	00779b13          	slli	s6,a5,0x7
    80001fac:	0000f717          	auipc	a4,0xf
    80001fb0:	df470713          	addi	a4,a4,-524 # 80010da0 <pid_lock>
    80001fb4:	975a                	add	a4,a4,s6
    80001fb6:	02073823          	sd	zero,48(a4)
          swtch(&c->context, &p->context);
    80001fba:	0000f717          	auipc	a4,0xf
    80001fbe:	e1e70713          	addi	a4,a4,-482 # 80010dd8 <cpus+0x8>
    80001fc2:	9b3a                	add	s6,s6,a4
      if(p->state == RUNNABLE){
    80001fc4:	490d                	li	s2,3
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fc6:	00016997          	auipc	s3,0x16
    80001fca:	00a98993          	addi	s3,s3,10 # 80017fd0 <tickslock>
    int totalticketval = 0;
    80001fce:	4a01                	li	s4,0
          c->proc = p;
    80001fd0:	079e                	slli	a5,a5,0x7
    80001fd2:	0000fa97          	auipc	s5,0xf
    80001fd6:	dcea8a93          	addi	s5,s5,-562 # 80010da0 <pid_lock>
    80001fda:	9abe                	add	s5,s5,a5
    80001fdc:	a889                	j	8000202e <scheduler+0xa0>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fde:	1b878793          	addi	a5,a5,440
    80001fe2:	01378963          	beq	a5,s3,80001ff4 <scheduler+0x66>
      if(p->state == RUNNABLE){
    80001fe6:	4f98                	lw	a4,24(a5)
    80001fe8:	ff271be3          	bne	a4,s2,80001fde <scheduler+0x50>
        totalticketval += p->tickets;
    80001fec:	1b47a703          	lw	a4,436(a5)
    80001ff0:	9db9                	addw	a1,a1,a4
    80001ff2:	b7f5                	j	80001fde <scheduler+0x50>
    int ticketval = randomnum(0,totalticketval);
    80001ff4:	8552                	mv	a0,s4
    80001ff6:	00000097          	auipc	ra,0x0
    80001ffa:	f6a080e7          	jalr	-150(ra) # 80001f60 <randomnum>
    80001ffe:	8baa                	mv	s7,a0
    for(p = proc; p < &proc[NPROC]; p++) {
    80002000:	0000f497          	auipc	s1,0xf
    80002004:	1d048493          	addi	s1,s1,464 # 800111d0 <proc>
    80002008:	a881                	j	80002058 <scheduler+0xca>
          p->state = RUNNING;
    8000200a:	4791                	li	a5,4
    8000200c:	cc9c                	sw	a5,24(s1)
          c->proc = p;
    8000200e:	029ab823          	sd	s1,48(s5)
          swtch(&c->context, &p->context);
    80002012:	06048593          	addi	a1,s1,96
    80002016:	855a                	mv	a0,s6
    80002018:	00001097          	auipc	ra,0x1
    8000201c:	82a080e7          	jalr	-2006(ra) # 80002842 <swtch>
          c->proc = 0;
    80002020:	020ab823          	sd	zero,48(s5)
          release(&p->lock);
    80002024:	8526                	mv	a0,s1
    80002026:	fffff097          	auipc	ra,0xfffff
    8000202a:	c78080e7          	jalr	-904(ra) # 80000c9e <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000202e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002032:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002036:	10079073          	csrw	sstatus,a5
    int totalticketval = 0;
    8000203a:	85d2                	mv	a1,s4
    for(p = proc; p < &proc[NPROC]; p++) {
    8000203c:	0000f797          	auipc	a5,0xf
    80002040:	19478793          	addi	a5,a5,404 # 800111d0 <proc>
    80002044:	b74d                	j	80001fe6 <scheduler+0x58>
      release(&p->lock);
    80002046:	8526                	mv	a0,s1
    80002048:	fffff097          	auipc	ra,0xfffff
    8000204c:	c56080e7          	jalr	-938(ra) # 80000c9e <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002050:	1b848493          	addi	s1,s1,440
    80002054:	fd348de3          	beq	s1,s3,8000202e <scheduler+0xa0>
      acquire(&p->lock);
    80002058:	8526                	mv	a0,s1
    8000205a:	fffff097          	auipc	ra,0xfffff
    8000205e:	b90080e7          	jalr	-1136(ra) # 80000bea <acquire>
      if(p->state == RUNNABLE) {
    80002062:	4c9c                	lw	a5,24(s1)
    80002064:	ff2791e3          	bne	a5,s2,80002046 <scheduler+0xb8>
        if(p->tickets > ticketval){
    80002068:	1b44a783          	lw	a5,436(s1)
    8000206c:	f8fbcfe3          	blt	s7,a5,8000200a <scheduler+0x7c>
          ticketval = ticketval - p->tickets; 
    80002070:	40fb8bbb          	subw	s7,s7,a5
    80002074:	bfc9                	j	80002046 <scheduler+0xb8>

0000000080002076 <sched>:
{
    80002076:	7179                	addi	sp,sp,-48
    80002078:	f406                	sd	ra,40(sp)
    8000207a:	f022                	sd	s0,32(sp)
    8000207c:	ec26                	sd	s1,24(sp)
    8000207e:	e84a                	sd	s2,16(sp)
    80002080:	e44e                	sd	s3,8(sp)
    80002082:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002084:	00000097          	auipc	ra,0x0
    80002088:	942080e7          	jalr	-1726(ra) # 800019c6 <myproc>
    8000208c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000208e:	fffff097          	auipc	ra,0xfffff
    80002092:	ae2080e7          	jalr	-1310(ra) # 80000b70 <holding>
    80002096:	c93d                	beqz	a0,8000210c <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002098:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000209a:	2781                	sext.w	a5,a5
    8000209c:	079e                	slli	a5,a5,0x7
    8000209e:	0000f717          	auipc	a4,0xf
    800020a2:	d0270713          	addi	a4,a4,-766 # 80010da0 <pid_lock>
    800020a6:	97ba                	add	a5,a5,a4
    800020a8:	0a87a703          	lw	a4,168(a5)
    800020ac:	4785                	li	a5,1
    800020ae:	06f71763          	bne	a4,a5,8000211c <sched+0xa6>
  if(p->state == RUNNING)
    800020b2:	4c98                	lw	a4,24(s1)
    800020b4:	4791                	li	a5,4
    800020b6:	06f70b63          	beq	a4,a5,8000212c <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020ba:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800020be:	8b89                	andi	a5,a5,2
  if(intr_get())
    800020c0:	efb5                	bnez	a5,8000213c <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020c2:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800020c4:	0000f917          	auipc	s2,0xf
    800020c8:	cdc90913          	addi	s2,s2,-804 # 80010da0 <pid_lock>
    800020cc:	2781                	sext.w	a5,a5
    800020ce:	079e                	slli	a5,a5,0x7
    800020d0:	97ca                	add	a5,a5,s2
    800020d2:	0ac7a983          	lw	s3,172(a5)
    800020d6:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800020d8:	2781                	sext.w	a5,a5
    800020da:	079e                	slli	a5,a5,0x7
    800020dc:	0000f597          	auipc	a1,0xf
    800020e0:	cfc58593          	addi	a1,a1,-772 # 80010dd8 <cpus+0x8>
    800020e4:	95be                	add	a1,a1,a5
    800020e6:	06048513          	addi	a0,s1,96
    800020ea:	00000097          	auipc	ra,0x0
    800020ee:	758080e7          	jalr	1880(ra) # 80002842 <swtch>
    800020f2:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020f4:	2781                	sext.w	a5,a5
    800020f6:	079e                	slli	a5,a5,0x7
    800020f8:	97ca                	add	a5,a5,s2
    800020fa:	0b37a623          	sw	s3,172(a5)
}
    800020fe:	70a2                	ld	ra,40(sp)
    80002100:	7402                	ld	s0,32(sp)
    80002102:	64e2                	ld	s1,24(sp)
    80002104:	6942                	ld	s2,16(sp)
    80002106:	69a2                	ld	s3,8(sp)
    80002108:	6145                	addi	sp,sp,48
    8000210a:	8082                	ret
    panic("sched p->lock");
    8000210c:	00006517          	auipc	a0,0x6
    80002110:	10c50513          	addi	a0,a0,268 # 80008218 <digits+0x1d8>
    80002114:	ffffe097          	auipc	ra,0xffffe
    80002118:	430080e7          	jalr	1072(ra) # 80000544 <panic>
    panic("sched locks");
    8000211c:	00006517          	auipc	a0,0x6
    80002120:	10c50513          	addi	a0,a0,268 # 80008228 <digits+0x1e8>
    80002124:	ffffe097          	auipc	ra,0xffffe
    80002128:	420080e7          	jalr	1056(ra) # 80000544 <panic>
    panic("sched running");
    8000212c:	00006517          	auipc	a0,0x6
    80002130:	10c50513          	addi	a0,a0,268 # 80008238 <digits+0x1f8>
    80002134:	ffffe097          	auipc	ra,0xffffe
    80002138:	410080e7          	jalr	1040(ra) # 80000544 <panic>
    panic("sched interruptible");
    8000213c:	00006517          	auipc	a0,0x6
    80002140:	10c50513          	addi	a0,a0,268 # 80008248 <digits+0x208>
    80002144:	ffffe097          	auipc	ra,0xffffe
    80002148:	400080e7          	jalr	1024(ra) # 80000544 <panic>

000000008000214c <yield>:
{
    8000214c:	1101                	addi	sp,sp,-32
    8000214e:	ec06                	sd	ra,24(sp)
    80002150:	e822                	sd	s0,16(sp)
    80002152:	e426                	sd	s1,8(sp)
    80002154:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002156:	00000097          	auipc	ra,0x0
    8000215a:	870080e7          	jalr	-1936(ra) # 800019c6 <myproc>
    8000215e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002160:	fffff097          	auipc	ra,0xfffff
    80002164:	a8a080e7          	jalr	-1398(ra) # 80000bea <acquire>
  p->state = RUNNABLE;
    80002168:	478d                	li	a5,3
    8000216a:	cc9c                	sw	a5,24(s1)
  sched();
    8000216c:	00000097          	auipc	ra,0x0
    80002170:	f0a080e7          	jalr	-246(ra) # 80002076 <sched>
  release(&p->lock);
    80002174:	8526                	mv	a0,s1
    80002176:	fffff097          	auipc	ra,0xfffff
    8000217a:	b28080e7          	jalr	-1240(ra) # 80000c9e <release>
}
    8000217e:	60e2                	ld	ra,24(sp)
    80002180:	6442                	ld	s0,16(sp)
    80002182:	64a2                	ld	s1,8(sp)
    80002184:	6105                	addi	sp,sp,32
    80002186:	8082                	ret

0000000080002188 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002188:	7179                	addi	sp,sp,-48
    8000218a:	f406                	sd	ra,40(sp)
    8000218c:	f022                	sd	s0,32(sp)
    8000218e:	ec26                	sd	s1,24(sp)
    80002190:	e84a                	sd	s2,16(sp)
    80002192:	e44e                	sd	s3,8(sp)
    80002194:	1800                	addi	s0,sp,48
    80002196:	89aa                	mv	s3,a0
    80002198:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000219a:	00000097          	auipc	ra,0x0
    8000219e:	82c080e7          	jalr	-2004(ra) # 800019c6 <myproc>
    800021a2:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800021a4:	fffff097          	auipc	ra,0xfffff
    800021a8:	a46080e7          	jalr	-1466(ra) # 80000bea <acquire>
  release(lk);
    800021ac:	854a                	mv	a0,s2
    800021ae:	fffff097          	auipc	ra,0xfffff
    800021b2:	af0080e7          	jalr	-1296(ra) # 80000c9e <release>

  // Go to sleep.
  p->chan = chan;
    800021b6:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800021ba:	4789                	li	a5,2
    800021bc:	cc9c                	sw	a5,24(s1)

  sched();
    800021be:	00000097          	auipc	ra,0x0
    800021c2:	eb8080e7          	jalr	-328(ra) # 80002076 <sched>

  // Tidy up.
  p->chan = 0;
    800021c6:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800021ca:	8526                	mv	a0,s1
    800021cc:	fffff097          	auipc	ra,0xfffff
    800021d0:	ad2080e7          	jalr	-1326(ra) # 80000c9e <release>
  acquire(lk);
    800021d4:	854a                	mv	a0,s2
    800021d6:	fffff097          	auipc	ra,0xfffff
    800021da:	a14080e7          	jalr	-1516(ra) # 80000bea <acquire>
}
    800021de:	70a2                	ld	ra,40(sp)
    800021e0:	7402                	ld	s0,32(sp)
    800021e2:	64e2                	ld	s1,24(sp)
    800021e4:	6942                	ld	s2,16(sp)
    800021e6:	69a2                	ld	s3,8(sp)
    800021e8:	6145                	addi	sp,sp,48
    800021ea:	8082                	ret

00000000800021ec <waitx>:
{
    800021ec:	711d                	addi	sp,sp,-96
    800021ee:	ec86                	sd	ra,88(sp)
    800021f0:	e8a2                	sd	s0,80(sp)
    800021f2:	e4a6                	sd	s1,72(sp)
    800021f4:	e0ca                	sd	s2,64(sp)
    800021f6:	fc4e                	sd	s3,56(sp)
    800021f8:	f852                	sd	s4,48(sp)
    800021fa:	f456                	sd	s5,40(sp)
    800021fc:	f05a                	sd	s6,32(sp)
    800021fe:	ec5e                	sd	s7,24(sp)
    80002200:	e862                	sd	s8,16(sp)
    80002202:	e466                	sd	s9,8(sp)
    80002204:	e06a                	sd	s10,0(sp)
    80002206:	1080                	addi	s0,sp,96
    80002208:	8b2a                	mv	s6,a0
    8000220a:	8bae                	mv	s7,a1
    8000220c:	8c32                	mv	s8,a2
  struct proc *p = myproc();
    8000220e:	fffff097          	auipc	ra,0xfffff
    80002212:	7b8080e7          	jalr	1976(ra) # 800019c6 <myproc>
    80002216:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002218:	0000f517          	auipc	a0,0xf
    8000221c:	ba050513          	addi	a0,a0,-1120 # 80010db8 <wait_lock>
    80002220:	fffff097          	auipc	ra,0xfffff
    80002224:	9ca080e7          	jalr	-1590(ra) # 80000bea <acquire>
    havekids = 0;
    80002228:	4c81                	li	s9,0
        if(np->state == ZOMBIE){
    8000222a:	4a15                	li	s4,5
    for(np = proc; np < &proc[NPROC]; np++){
    8000222c:	00016997          	auipc	s3,0x16
    80002230:	da498993          	addi	s3,s3,-604 # 80017fd0 <tickslock>
        havekids = 1;
    80002234:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002236:	0000fd17          	auipc	s10,0xf
    8000223a:	b82d0d13          	addi	s10,s10,-1150 # 80010db8 <wait_lock>
    havekids = 0;
    8000223e:	8766                	mv	a4,s9
    for(np = proc; np < &proc[NPROC]; np++){
    80002240:	0000f497          	auipc	s1,0xf
    80002244:	f9048493          	addi	s1,s1,-112 # 800111d0 <proc>
    80002248:	a059                	j	800022ce <waitx+0xe2>
          pid = np->pid;
    8000224a:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    8000224e:	16c4a703          	lw	a4,364(s1)
    80002252:	00ec2023          	sw	a4,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    80002256:	1704a783          	lw	a5,368(s1)
    8000225a:	9f3d                	addw	a4,a4,a5
    8000225c:	1744a783          	lw	a5,372(s1)
    80002260:	9f99                	subw	a5,a5,a4
    80002262:	00fba023          	sw	a5,0(s7) # fffffffffffff000 <end+0xffffffff7ffdbc50>
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002266:	000b0e63          	beqz	s6,80002282 <waitx+0x96>
    8000226a:	4691                	li	a3,4
    8000226c:	02c48613          	addi	a2,s1,44
    80002270:	85da                	mv	a1,s6
    80002272:	05093503          	ld	a0,80(s2)
    80002276:	fffff097          	auipc	ra,0xfffff
    8000227a:	40e080e7          	jalr	1038(ra) # 80001684 <copyout>
    8000227e:	02054563          	bltz	a0,800022a8 <waitx+0xbc>
          freeproc(np);
    80002282:	8526                	mv	a0,s1
    80002284:	00000097          	auipc	ra,0x0
    80002288:	8f4080e7          	jalr	-1804(ra) # 80001b78 <freeproc>
          release(&np->lock);
    8000228c:	8526                	mv	a0,s1
    8000228e:	fffff097          	auipc	ra,0xfffff
    80002292:	a10080e7          	jalr	-1520(ra) # 80000c9e <release>
          release(&wait_lock);
    80002296:	0000f517          	auipc	a0,0xf
    8000229a:	b2250513          	addi	a0,a0,-1246 # 80010db8 <wait_lock>
    8000229e:	fffff097          	auipc	ra,0xfffff
    800022a2:	a00080e7          	jalr	-1536(ra) # 80000c9e <release>
          return pid;
    800022a6:	a09d                	j	8000230c <waitx+0x120>
            release(&np->lock);
    800022a8:	8526                	mv	a0,s1
    800022aa:	fffff097          	auipc	ra,0xfffff
    800022ae:	9f4080e7          	jalr	-1548(ra) # 80000c9e <release>
            release(&wait_lock);
    800022b2:	0000f517          	auipc	a0,0xf
    800022b6:	b0650513          	addi	a0,a0,-1274 # 80010db8 <wait_lock>
    800022ba:	fffff097          	auipc	ra,0xfffff
    800022be:	9e4080e7          	jalr	-1564(ra) # 80000c9e <release>
            return -1;
    800022c2:	59fd                	li	s3,-1
    800022c4:	a0a1                	j	8000230c <waitx+0x120>
    for(np = proc; np < &proc[NPROC]; np++){
    800022c6:	1b848493          	addi	s1,s1,440
    800022ca:	03348463          	beq	s1,s3,800022f2 <waitx+0x106>
      if(np->parent == p){
    800022ce:	7c9c                	ld	a5,56(s1)
    800022d0:	ff279be3          	bne	a5,s2,800022c6 <waitx+0xda>
        acquire(&np->lock);
    800022d4:	8526                	mv	a0,s1
    800022d6:	fffff097          	auipc	ra,0xfffff
    800022da:	914080e7          	jalr	-1772(ra) # 80000bea <acquire>
        if(np->state == ZOMBIE){
    800022de:	4c9c                	lw	a5,24(s1)
    800022e0:	f74785e3          	beq	a5,s4,8000224a <waitx+0x5e>
        release(&np->lock);
    800022e4:	8526                	mv	a0,s1
    800022e6:	fffff097          	auipc	ra,0xfffff
    800022ea:	9b8080e7          	jalr	-1608(ra) # 80000c9e <release>
        havekids = 1;
    800022ee:	8756                	mv	a4,s5
    800022f0:	bfd9                	j	800022c6 <waitx+0xda>
    if(!havekids || p->killed){
    800022f2:	c701                	beqz	a4,800022fa <waitx+0x10e>
    800022f4:	02892783          	lw	a5,40(s2)
    800022f8:	cb8d                	beqz	a5,8000232a <waitx+0x13e>
      release(&wait_lock);
    800022fa:	0000f517          	auipc	a0,0xf
    800022fe:	abe50513          	addi	a0,a0,-1346 # 80010db8 <wait_lock>
    80002302:	fffff097          	auipc	ra,0xfffff
    80002306:	99c080e7          	jalr	-1636(ra) # 80000c9e <release>
      return -1;
    8000230a:	59fd                	li	s3,-1
}
    8000230c:	854e                	mv	a0,s3
    8000230e:	60e6                	ld	ra,88(sp)
    80002310:	6446                	ld	s0,80(sp)
    80002312:	64a6                	ld	s1,72(sp)
    80002314:	6906                	ld	s2,64(sp)
    80002316:	79e2                	ld	s3,56(sp)
    80002318:	7a42                	ld	s4,48(sp)
    8000231a:	7aa2                	ld	s5,40(sp)
    8000231c:	7b02                	ld	s6,32(sp)
    8000231e:	6be2                	ld	s7,24(sp)
    80002320:	6c42                	ld	s8,16(sp)
    80002322:	6ca2                	ld	s9,8(sp)
    80002324:	6d02                	ld	s10,0(sp)
    80002326:	6125                	addi	sp,sp,96
    80002328:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000232a:	85ea                	mv	a1,s10
    8000232c:	854a                	mv	a0,s2
    8000232e:	00000097          	auipc	ra,0x0
    80002332:	e5a080e7          	jalr	-422(ra) # 80002188 <sleep>
    havekids = 0;
    80002336:	b721                	j	8000223e <waitx+0x52>

0000000080002338 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002338:	7139                	addi	sp,sp,-64
    8000233a:	fc06                	sd	ra,56(sp)
    8000233c:	f822                	sd	s0,48(sp)
    8000233e:	f426                	sd	s1,40(sp)
    80002340:	f04a                	sd	s2,32(sp)
    80002342:	ec4e                	sd	s3,24(sp)
    80002344:	e852                	sd	s4,16(sp)
    80002346:	e456                	sd	s5,8(sp)
    80002348:	0080                	addi	s0,sp,64
    8000234a:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000234c:	0000f497          	auipc	s1,0xf
    80002350:	e8448493          	addi	s1,s1,-380 # 800111d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002354:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002356:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002358:	00016917          	auipc	s2,0x16
    8000235c:	c7890913          	addi	s2,s2,-904 # 80017fd0 <tickslock>
    80002360:	a821                	j	80002378 <wakeup+0x40>
        p->state = RUNNABLE;
    80002362:	0154ac23          	sw	s5,24(s1)
      }
      release(&p->lock);
    80002366:	8526                	mv	a0,s1
    80002368:	fffff097          	auipc	ra,0xfffff
    8000236c:	936080e7          	jalr	-1738(ra) # 80000c9e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002370:	1b848493          	addi	s1,s1,440
    80002374:	03248463          	beq	s1,s2,8000239c <wakeup+0x64>
    if(p != myproc()){
    80002378:	fffff097          	auipc	ra,0xfffff
    8000237c:	64e080e7          	jalr	1614(ra) # 800019c6 <myproc>
    80002380:	fea488e3          	beq	s1,a0,80002370 <wakeup+0x38>
      acquire(&p->lock);
    80002384:	8526                	mv	a0,s1
    80002386:	fffff097          	auipc	ra,0xfffff
    8000238a:	864080e7          	jalr	-1948(ra) # 80000bea <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000238e:	4c9c                	lw	a5,24(s1)
    80002390:	fd379be3          	bne	a5,s3,80002366 <wakeup+0x2e>
    80002394:	709c                	ld	a5,32(s1)
    80002396:	fd4798e3          	bne	a5,s4,80002366 <wakeup+0x2e>
    8000239a:	b7e1                	j	80002362 <wakeup+0x2a>
    }
  }
}
    8000239c:	70e2                	ld	ra,56(sp)
    8000239e:	7442                	ld	s0,48(sp)
    800023a0:	74a2                	ld	s1,40(sp)
    800023a2:	7902                	ld	s2,32(sp)
    800023a4:	69e2                	ld	s3,24(sp)
    800023a6:	6a42                	ld	s4,16(sp)
    800023a8:	6aa2                	ld	s5,8(sp)
    800023aa:	6121                	addi	sp,sp,64
    800023ac:	8082                	ret

00000000800023ae <reparent>:
{
    800023ae:	7179                	addi	sp,sp,-48
    800023b0:	f406                	sd	ra,40(sp)
    800023b2:	f022                	sd	s0,32(sp)
    800023b4:	ec26                	sd	s1,24(sp)
    800023b6:	e84a                	sd	s2,16(sp)
    800023b8:	e44e                	sd	s3,8(sp)
    800023ba:	e052                	sd	s4,0(sp)
    800023bc:	1800                	addi	s0,sp,48
    800023be:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800023c0:	0000f497          	auipc	s1,0xf
    800023c4:	e1048493          	addi	s1,s1,-496 # 800111d0 <proc>
      pp->parent = initproc;
    800023c8:	00006a17          	auipc	s4,0x6
    800023cc:	760a0a13          	addi	s4,s4,1888 # 80008b28 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800023d0:	00016997          	auipc	s3,0x16
    800023d4:	c0098993          	addi	s3,s3,-1024 # 80017fd0 <tickslock>
    800023d8:	a029                	j	800023e2 <reparent+0x34>
    800023da:	1b848493          	addi	s1,s1,440
    800023de:	01348d63          	beq	s1,s3,800023f8 <reparent+0x4a>
    if(pp->parent == p){
    800023e2:	7c9c                	ld	a5,56(s1)
    800023e4:	ff279be3          	bne	a5,s2,800023da <reparent+0x2c>
      pp->parent = initproc;
    800023e8:	000a3503          	ld	a0,0(s4)
    800023ec:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800023ee:	00000097          	auipc	ra,0x0
    800023f2:	f4a080e7          	jalr	-182(ra) # 80002338 <wakeup>
    800023f6:	b7d5                	j	800023da <reparent+0x2c>
}
    800023f8:	70a2                	ld	ra,40(sp)
    800023fa:	7402                	ld	s0,32(sp)
    800023fc:	64e2                	ld	s1,24(sp)
    800023fe:	6942                	ld	s2,16(sp)
    80002400:	69a2                	ld	s3,8(sp)
    80002402:	6a02                	ld	s4,0(sp)
    80002404:	6145                	addi	sp,sp,48
    80002406:	8082                	ret

0000000080002408 <exit>:
{
    80002408:	7179                	addi	sp,sp,-48
    8000240a:	f406                	sd	ra,40(sp)
    8000240c:	f022                	sd	s0,32(sp)
    8000240e:	ec26                	sd	s1,24(sp)
    80002410:	e84a                	sd	s2,16(sp)
    80002412:	e44e                	sd	s3,8(sp)
    80002414:	e052                	sd	s4,0(sp)
    80002416:	1800                	addi	s0,sp,48
    80002418:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000241a:	fffff097          	auipc	ra,0xfffff
    8000241e:	5ac080e7          	jalr	1452(ra) # 800019c6 <myproc>
    80002422:	89aa                	mv	s3,a0
  if(p == initproc)
    80002424:	00006797          	auipc	a5,0x6
    80002428:	7047b783          	ld	a5,1796(a5) # 80008b28 <initproc>
    8000242c:	0d050493          	addi	s1,a0,208
    80002430:	15050913          	addi	s2,a0,336
    80002434:	02a79363          	bne	a5,a0,8000245a <exit+0x52>
    panic("init exiting");
    80002438:	00006517          	auipc	a0,0x6
    8000243c:	e2850513          	addi	a0,a0,-472 # 80008260 <digits+0x220>
    80002440:	ffffe097          	auipc	ra,0xffffe
    80002444:	104080e7          	jalr	260(ra) # 80000544 <panic>
      fileclose(f);
    80002448:	00002097          	auipc	ra,0x2
    8000244c:	5c2080e7          	jalr	1474(ra) # 80004a0a <fileclose>
      p->ofile[fd] = 0;
    80002450:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002454:	04a1                	addi	s1,s1,8
    80002456:	01248563          	beq	s1,s2,80002460 <exit+0x58>
    if(p->ofile[fd]){
    8000245a:	6088                	ld	a0,0(s1)
    8000245c:	f575                	bnez	a0,80002448 <exit+0x40>
    8000245e:	bfdd                	j	80002454 <exit+0x4c>
  begin_op();
    80002460:	00002097          	auipc	ra,0x2
    80002464:	0de080e7          	jalr	222(ra) # 8000453e <begin_op>
  iput(p->cwd);
    80002468:	1509b503          	ld	a0,336(s3)
    8000246c:	00002097          	auipc	ra,0x2
    80002470:	8ca080e7          	jalr	-1846(ra) # 80003d36 <iput>
  end_op();
    80002474:	00002097          	auipc	ra,0x2
    80002478:	14a080e7          	jalr	330(ra) # 800045be <end_op>
  p->cwd = 0;
    8000247c:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002480:	0000f497          	auipc	s1,0xf
    80002484:	93848493          	addi	s1,s1,-1736 # 80010db8 <wait_lock>
    80002488:	8526                	mv	a0,s1
    8000248a:	ffffe097          	auipc	ra,0xffffe
    8000248e:	760080e7          	jalr	1888(ra) # 80000bea <acquire>
  reparent(p);
    80002492:	854e                	mv	a0,s3
    80002494:	00000097          	auipc	ra,0x0
    80002498:	f1a080e7          	jalr	-230(ra) # 800023ae <reparent>
  wakeup(p->parent);
    8000249c:	0389b503          	ld	a0,56(s3)
    800024a0:	00000097          	auipc	ra,0x0
    800024a4:	e98080e7          	jalr	-360(ra) # 80002338 <wakeup>
  acquire(&p->lock);
    800024a8:	854e                	mv	a0,s3
    800024aa:	ffffe097          	auipc	ra,0xffffe
    800024ae:	740080e7          	jalr	1856(ra) # 80000bea <acquire>
  p->xstate = status;
    800024b2:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800024b6:	4795                	li	a5,5
    800024b8:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    800024bc:	00006797          	auipc	a5,0x6
    800024c0:	6747a783          	lw	a5,1652(a5) # 80008b30 <ticks>
    800024c4:	16f9aa23          	sw	a5,372(s3)
  release(&wait_lock);
    800024c8:	8526                	mv	a0,s1
    800024ca:	ffffe097          	auipc	ra,0xffffe
    800024ce:	7d4080e7          	jalr	2004(ra) # 80000c9e <release>
  sched();
    800024d2:	00000097          	auipc	ra,0x0
    800024d6:	ba4080e7          	jalr	-1116(ra) # 80002076 <sched>
  panic("zombie exit");
    800024da:	00006517          	auipc	a0,0x6
    800024de:	d9650513          	addi	a0,a0,-618 # 80008270 <digits+0x230>
    800024e2:	ffffe097          	auipc	ra,0xffffe
    800024e6:	062080e7          	jalr	98(ra) # 80000544 <panic>

00000000800024ea <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800024ea:	7179                	addi	sp,sp,-48
    800024ec:	f406                	sd	ra,40(sp)
    800024ee:	f022                	sd	s0,32(sp)
    800024f0:	ec26                	sd	s1,24(sp)
    800024f2:	e84a                	sd	s2,16(sp)
    800024f4:	e44e                	sd	s3,8(sp)
    800024f6:	1800                	addi	s0,sp,48
    800024f8:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800024fa:	0000f497          	auipc	s1,0xf
    800024fe:	cd648493          	addi	s1,s1,-810 # 800111d0 <proc>
    80002502:	00016997          	auipc	s3,0x16
    80002506:	ace98993          	addi	s3,s3,-1330 # 80017fd0 <tickslock>
    acquire(&p->lock);
    8000250a:	8526                	mv	a0,s1
    8000250c:	ffffe097          	auipc	ra,0xffffe
    80002510:	6de080e7          	jalr	1758(ra) # 80000bea <acquire>
    if(p->pid == pid){
    80002514:	589c                	lw	a5,48(s1)
    80002516:	01278d63          	beq	a5,s2,80002530 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000251a:	8526                	mv	a0,s1
    8000251c:	ffffe097          	auipc	ra,0xffffe
    80002520:	782080e7          	jalr	1922(ra) # 80000c9e <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002524:	1b848493          	addi	s1,s1,440
    80002528:	ff3491e3          	bne	s1,s3,8000250a <kill+0x20>
  }
  return -1;
    8000252c:	557d                	li	a0,-1
    8000252e:	a829                	j	80002548 <kill+0x5e>
      p->killed = 1;
    80002530:	4785                	li	a5,1
    80002532:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002534:	4c98                	lw	a4,24(s1)
    80002536:	4789                	li	a5,2
    80002538:	00f70f63          	beq	a4,a5,80002556 <kill+0x6c>
      release(&p->lock);
    8000253c:	8526                	mv	a0,s1
    8000253e:	ffffe097          	auipc	ra,0xffffe
    80002542:	760080e7          	jalr	1888(ra) # 80000c9e <release>
      return 0;
    80002546:	4501                	li	a0,0
}
    80002548:	70a2                	ld	ra,40(sp)
    8000254a:	7402                	ld	s0,32(sp)
    8000254c:	64e2                	ld	s1,24(sp)
    8000254e:	6942                	ld	s2,16(sp)
    80002550:	69a2                	ld	s3,8(sp)
    80002552:	6145                	addi	sp,sp,48
    80002554:	8082                	ret
        p->state = RUNNABLE;
    80002556:	478d                	li	a5,3
    80002558:	cc9c                	sw	a5,24(s1)
    8000255a:	b7cd                	j	8000253c <kill+0x52>

000000008000255c <setkilled>:

void
setkilled(struct proc *p)
{
    8000255c:	1101                	addi	sp,sp,-32
    8000255e:	ec06                	sd	ra,24(sp)
    80002560:	e822                	sd	s0,16(sp)
    80002562:	e426                	sd	s1,8(sp)
    80002564:	1000                	addi	s0,sp,32
    80002566:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002568:	ffffe097          	auipc	ra,0xffffe
    8000256c:	682080e7          	jalr	1666(ra) # 80000bea <acquire>
  p->killed = 1;
    80002570:	4785                	li	a5,1
    80002572:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002574:	8526                	mv	a0,s1
    80002576:	ffffe097          	auipc	ra,0xffffe
    8000257a:	728080e7          	jalr	1832(ra) # 80000c9e <release>
}
    8000257e:	60e2                	ld	ra,24(sp)
    80002580:	6442                	ld	s0,16(sp)
    80002582:	64a2                	ld	s1,8(sp)
    80002584:	6105                	addi	sp,sp,32
    80002586:	8082                	ret

0000000080002588 <killed>:

int
killed(struct proc *p)
{
    80002588:	1101                	addi	sp,sp,-32
    8000258a:	ec06                	sd	ra,24(sp)
    8000258c:	e822                	sd	s0,16(sp)
    8000258e:	e426                	sd	s1,8(sp)
    80002590:	e04a                	sd	s2,0(sp)
    80002592:	1000                	addi	s0,sp,32
    80002594:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002596:	ffffe097          	auipc	ra,0xffffe
    8000259a:	654080e7          	jalr	1620(ra) # 80000bea <acquire>
  k = p->killed;
    8000259e:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800025a2:	8526                	mv	a0,s1
    800025a4:	ffffe097          	auipc	ra,0xffffe
    800025a8:	6fa080e7          	jalr	1786(ra) # 80000c9e <release>
  return k;
}
    800025ac:	854a                	mv	a0,s2
    800025ae:	60e2                	ld	ra,24(sp)
    800025b0:	6442                	ld	s0,16(sp)
    800025b2:	64a2                	ld	s1,8(sp)
    800025b4:	6902                	ld	s2,0(sp)
    800025b6:	6105                	addi	sp,sp,32
    800025b8:	8082                	ret

00000000800025ba <wait>:
{
    800025ba:	715d                	addi	sp,sp,-80
    800025bc:	e486                	sd	ra,72(sp)
    800025be:	e0a2                	sd	s0,64(sp)
    800025c0:	fc26                	sd	s1,56(sp)
    800025c2:	f84a                	sd	s2,48(sp)
    800025c4:	f44e                	sd	s3,40(sp)
    800025c6:	f052                	sd	s4,32(sp)
    800025c8:	ec56                	sd	s5,24(sp)
    800025ca:	e85a                	sd	s6,16(sp)
    800025cc:	e45e                	sd	s7,8(sp)
    800025ce:	e062                	sd	s8,0(sp)
    800025d0:	0880                	addi	s0,sp,80
    800025d2:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800025d4:	fffff097          	auipc	ra,0xfffff
    800025d8:	3f2080e7          	jalr	1010(ra) # 800019c6 <myproc>
    800025dc:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800025de:	0000e517          	auipc	a0,0xe
    800025e2:	7da50513          	addi	a0,a0,2010 # 80010db8 <wait_lock>
    800025e6:	ffffe097          	auipc	ra,0xffffe
    800025ea:	604080e7          	jalr	1540(ra) # 80000bea <acquire>
    havekids = 0;
    800025ee:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800025f0:	4a15                	li	s4,5
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800025f2:	00016997          	auipc	s3,0x16
    800025f6:	9de98993          	addi	s3,s3,-1570 # 80017fd0 <tickslock>
        havekids = 1;
    800025fa:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800025fc:	0000ec17          	auipc	s8,0xe
    80002600:	7bcc0c13          	addi	s8,s8,1980 # 80010db8 <wait_lock>
    havekids = 0;
    80002604:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002606:	0000f497          	auipc	s1,0xf
    8000260a:	bca48493          	addi	s1,s1,-1078 # 800111d0 <proc>
    8000260e:	a0bd                	j	8000267c <wait+0xc2>
          pid = pp->pid;
    80002610:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002614:	000b0e63          	beqz	s6,80002630 <wait+0x76>
    80002618:	4691                	li	a3,4
    8000261a:	02c48613          	addi	a2,s1,44
    8000261e:	85da                	mv	a1,s6
    80002620:	05093503          	ld	a0,80(s2)
    80002624:	fffff097          	auipc	ra,0xfffff
    80002628:	060080e7          	jalr	96(ra) # 80001684 <copyout>
    8000262c:	02054563          	bltz	a0,80002656 <wait+0x9c>
          freeproc(pp);
    80002630:	8526                	mv	a0,s1
    80002632:	fffff097          	auipc	ra,0xfffff
    80002636:	546080e7          	jalr	1350(ra) # 80001b78 <freeproc>
          release(&pp->lock);
    8000263a:	8526                	mv	a0,s1
    8000263c:	ffffe097          	auipc	ra,0xffffe
    80002640:	662080e7          	jalr	1634(ra) # 80000c9e <release>
          release(&wait_lock);
    80002644:	0000e517          	auipc	a0,0xe
    80002648:	77450513          	addi	a0,a0,1908 # 80010db8 <wait_lock>
    8000264c:	ffffe097          	auipc	ra,0xffffe
    80002650:	652080e7          	jalr	1618(ra) # 80000c9e <release>
          return pid;
    80002654:	a0b5                	j	800026c0 <wait+0x106>
            release(&pp->lock);
    80002656:	8526                	mv	a0,s1
    80002658:	ffffe097          	auipc	ra,0xffffe
    8000265c:	646080e7          	jalr	1606(ra) # 80000c9e <release>
            release(&wait_lock);
    80002660:	0000e517          	auipc	a0,0xe
    80002664:	75850513          	addi	a0,a0,1880 # 80010db8 <wait_lock>
    80002668:	ffffe097          	auipc	ra,0xffffe
    8000266c:	636080e7          	jalr	1590(ra) # 80000c9e <release>
            return -1;
    80002670:	59fd                	li	s3,-1
    80002672:	a0b9                	j	800026c0 <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002674:	1b848493          	addi	s1,s1,440
    80002678:	03348463          	beq	s1,s3,800026a0 <wait+0xe6>
      if(pp->parent == p){
    8000267c:	7c9c                	ld	a5,56(s1)
    8000267e:	ff279be3          	bne	a5,s2,80002674 <wait+0xba>
        acquire(&pp->lock);
    80002682:	8526                	mv	a0,s1
    80002684:	ffffe097          	auipc	ra,0xffffe
    80002688:	566080e7          	jalr	1382(ra) # 80000bea <acquire>
        if(pp->state == ZOMBIE){
    8000268c:	4c9c                	lw	a5,24(s1)
    8000268e:	f94781e3          	beq	a5,s4,80002610 <wait+0x56>
        release(&pp->lock);
    80002692:	8526                	mv	a0,s1
    80002694:	ffffe097          	auipc	ra,0xffffe
    80002698:	60a080e7          	jalr	1546(ra) # 80000c9e <release>
        havekids = 1;
    8000269c:	8756                	mv	a4,s5
    8000269e:	bfd9                	j	80002674 <wait+0xba>
    if(!havekids || killed(p)){
    800026a0:	c719                	beqz	a4,800026ae <wait+0xf4>
    800026a2:	854a                	mv	a0,s2
    800026a4:	00000097          	auipc	ra,0x0
    800026a8:	ee4080e7          	jalr	-284(ra) # 80002588 <killed>
    800026ac:	c51d                	beqz	a0,800026da <wait+0x120>
      release(&wait_lock);
    800026ae:	0000e517          	auipc	a0,0xe
    800026b2:	70a50513          	addi	a0,a0,1802 # 80010db8 <wait_lock>
    800026b6:	ffffe097          	auipc	ra,0xffffe
    800026ba:	5e8080e7          	jalr	1512(ra) # 80000c9e <release>
      return -1;
    800026be:	59fd                	li	s3,-1
}
    800026c0:	854e                	mv	a0,s3
    800026c2:	60a6                	ld	ra,72(sp)
    800026c4:	6406                	ld	s0,64(sp)
    800026c6:	74e2                	ld	s1,56(sp)
    800026c8:	7942                	ld	s2,48(sp)
    800026ca:	79a2                	ld	s3,40(sp)
    800026cc:	7a02                	ld	s4,32(sp)
    800026ce:	6ae2                	ld	s5,24(sp)
    800026d0:	6b42                	ld	s6,16(sp)
    800026d2:	6ba2                	ld	s7,8(sp)
    800026d4:	6c02                	ld	s8,0(sp)
    800026d6:	6161                	addi	sp,sp,80
    800026d8:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800026da:	85e2                	mv	a1,s8
    800026dc:	854a                	mv	a0,s2
    800026de:	00000097          	auipc	ra,0x0
    800026e2:	aaa080e7          	jalr	-1366(ra) # 80002188 <sleep>
    havekids = 0;
    800026e6:	bf39                	j	80002604 <wait+0x4a>

00000000800026e8 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800026e8:	7179                	addi	sp,sp,-48
    800026ea:	f406                	sd	ra,40(sp)
    800026ec:	f022                	sd	s0,32(sp)
    800026ee:	ec26                	sd	s1,24(sp)
    800026f0:	e84a                	sd	s2,16(sp)
    800026f2:	e44e                	sd	s3,8(sp)
    800026f4:	e052                	sd	s4,0(sp)
    800026f6:	1800                	addi	s0,sp,48
    800026f8:	84aa                	mv	s1,a0
    800026fa:	892e                	mv	s2,a1
    800026fc:	89b2                	mv	s3,a2
    800026fe:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002700:	fffff097          	auipc	ra,0xfffff
    80002704:	2c6080e7          	jalr	710(ra) # 800019c6 <myproc>
  if(user_dst){
    80002708:	c08d                	beqz	s1,8000272a <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000270a:	86d2                	mv	a3,s4
    8000270c:	864e                	mv	a2,s3
    8000270e:	85ca                	mv	a1,s2
    80002710:	6928                	ld	a0,80(a0)
    80002712:	fffff097          	auipc	ra,0xfffff
    80002716:	f72080e7          	jalr	-142(ra) # 80001684 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000271a:	70a2                	ld	ra,40(sp)
    8000271c:	7402                	ld	s0,32(sp)
    8000271e:	64e2                	ld	s1,24(sp)
    80002720:	6942                	ld	s2,16(sp)
    80002722:	69a2                	ld	s3,8(sp)
    80002724:	6a02                	ld	s4,0(sp)
    80002726:	6145                	addi	sp,sp,48
    80002728:	8082                	ret
    memmove((char *)dst, src, len);
    8000272a:	000a061b          	sext.w	a2,s4
    8000272e:	85ce                	mv	a1,s3
    80002730:	854a                	mv	a0,s2
    80002732:	ffffe097          	auipc	ra,0xffffe
    80002736:	614080e7          	jalr	1556(ra) # 80000d46 <memmove>
    return 0;
    8000273a:	8526                	mv	a0,s1
    8000273c:	bff9                	j	8000271a <either_copyout+0x32>

000000008000273e <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000273e:	7179                	addi	sp,sp,-48
    80002740:	f406                	sd	ra,40(sp)
    80002742:	f022                	sd	s0,32(sp)
    80002744:	ec26                	sd	s1,24(sp)
    80002746:	e84a                	sd	s2,16(sp)
    80002748:	e44e                	sd	s3,8(sp)
    8000274a:	e052                	sd	s4,0(sp)
    8000274c:	1800                	addi	s0,sp,48
    8000274e:	892a                	mv	s2,a0
    80002750:	84ae                	mv	s1,a1
    80002752:	89b2                	mv	s3,a2
    80002754:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002756:	fffff097          	auipc	ra,0xfffff
    8000275a:	270080e7          	jalr	624(ra) # 800019c6 <myproc>
  if(user_src){
    8000275e:	c08d                	beqz	s1,80002780 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002760:	86d2                	mv	a3,s4
    80002762:	864e                	mv	a2,s3
    80002764:	85ca                	mv	a1,s2
    80002766:	6928                	ld	a0,80(a0)
    80002768:	fffff097          	auipc	ra,0xfffff
    8000276c:	fa8080e7          	jalr	-88(ra) # 80001710 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002770:	70a2                	ld	ra,40(sp)
    80002772:	7402                	ld	s0,32(sp)
    80002774:	64e2                	ld	s1,24(sp)
    80002776:	6942                	ld	s2,16(sp)
    80002778:	69a2                	ld	s3,8(sp)
    8000277a:	6a02                	ld	s4,0(sp)
    8000277c:	6145                	addi	sp,sp,48
    8000277e:	8082                	ret
    memmove(dst, (char*)src, len);
    80002780:	000a061b          	sext.w	a2,s4
    80002784:	85ce                	mv	a1,s3
    80002786:	854a                	mv	a0,s2
    80002788:	ffffe097          	auipc	ra,0xffffe
    8000278c:	5be080e7          	jalr	1470(ra) # 80000d46 <memmove>
    return 0;
    80002790:	8526                	mv	a0,s1
    80002792:	bff9                	j	80002770 <either_copyin+0x32>

0000000080002794 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002794:	715d                	addi	sp,sp,-80
    80002796:	e486                	sd	ra,72(sp)
    80002798:	e0a2                	sd	s0,64(sp)
    8000279a:	fc26                	sd	s1,56(sp)
    8000279c:	f84a                	sd	s2,48(sp)
    8000279e:	f44e                	sd	s3,40(sp)
    800027a0:	f052                	sd	s4,32(sp)
    800027a2:	ec56                	sd	s5,24(sp)
    800027a4:	e85a                	sd	s6,16(sp)
    800027a6:	e45e                	sd	s7,8(sp)
    800027a8:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800027aa:	00006517          	auipc	a0,0x6
    800027ae:	91e50513          	addi	a0,a0,-1762 # 800080c8 <digits+0x88>
    800027b2:	ffffe097          	auipc	ra,0xffffe
    800027b6:	ddc080e7          	jalr	-548(ra) # 8000058e <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800027ba:	0000f497          	auipc	s1,0xf
    800027be:	b6e48493          	addi	s1,s1,-1170 # 80011328 <proc+0x158>
    800027c2:	00016917          	auipc	s2,0x16
    800027c6:	96690913          	addi	s2,s2,-1690 # 80018128 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027ca:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800027cc:	00006997          	auipc	s3,0x6
    800027d0:	ab498993          	addi	s3,s3,-1356 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    800027d4:	00006a97          	auipc	s5,0x6
    800027d8:	ab4a8a93          	addi	s5,s5,-1356 # 80008288 <digits+0x248>
    printf("\n");
    800027dc:	00006a17          	auipc	s4,0x6
    800027e0:	8eca0a13          	addi	s4,s4,-1812 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027e4:	00006b97          	auipc	s7,0x6
    800027e8:	ae4b8b93          	addi	s7,s7,-1308 # 800082c8 <states.1771>
    800027ec:	a00d                	j	8000280e <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800027ee:	ed86a583          	lw	a1,-296(a3)
    800027f2:	8556                	mv	a0,s5
    800027f4:	ffffe097          	auipc	ra,0xffffe
    800027f8:	d9a080e7          	jalr	-614(ra) # 8000058e <printf>
    printf("\n");
    800027fc:	8552                	mv	a0,s4
    800027fe:	ffffe097          	auipc	ra,0xffffe
    80002802:	d90080e7          	jalr	-624(ra) # 8000058e <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002806:	1b848493          	addi	s1,s1,440
    8000280a:	03248163          	beq	s1,s2,8000282c <procdump+0x98>
    if(p->state == UNUSED)
    8000280e:	86a6                	mv	a3,s1
    80002810:	ec04a783          	lw	a5,-320(s1)
    80002814:	dbed                	beqz	a5,80002806 <procdump+0x72>
      state = "???";
    80002816:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002818:	fcfb6be3          	bltu	s6,a5,800027ee <procdump+0x5a>
    8000281c:	1782                	slli	a5,a5,0x20
    8000281e:	9381                	srli	a5,a5,0x20
    80002820:	078e                	slli	a5,a5,0x3
    80002822:	97de                	add	a5,a5,s7
    80002824:	6390                	ld	a2,0(a5)
    80002826:	f661                	bnez	a2,800027ee <procdump+0x5a>
      state = "???";
    80002828:	864e                	mv	a2,s3
    8000282a:	b7d1                	j	800027ee <procdump+0x5a>
  }
}
    8000282c:	60a6                	ld	ra,72(sp)
    8000282e:	6406                	ld	s0,64(sp)
    80002830:	74e2                	ld	s1,56(sp)
    80002832:	7942                	ld	s2,48(sp)
    80002834:	79a2                	ld	s3,40(sp)
    80002836:	7a02                	ld	s4,32(sp)
    80002838:	6ae2                	ld	s5,24(sp)
    8000283a:	6b42                	ld	s6,16(sp)
    8000283c:	6ba2                	ld	s7,8(sp)
    8000283e:	6161                	addi	sp,sp,80
    80002840:	8082                	ret

0000000080002842 <swtch>:
    80002842:	00153023          	sd	ra,0(a0)
    80002846:	00253423          	sd	sp,8(a0)
    8000284a:	e900                	sd	s0,16(a0)
    8000284c:	ed04                	sd	s1,24(a0)
    8000284e:	03253023          	sd	s2,32(a0)
    80002852:	03353423          	sd	s3,40(a0)
    80002856:	03453823          	sd	s4,48(a0)
    8000285a:	03553c23          	sd	s5,56(a0)
    8000285e:	05653023          	sd	s6,64(a0)
    80002862:	05753423          	sd	s7,72(a0)
    80002866:	05853823          	sd	s8,80(a0)
    8000286a:	05953c23          	sd	s9,88(a0)
    8000286e:	07a53023          	sd	s10,96(a0)
    80002872:	07b53423          	sd	s11,104(a0)
    80002876:	0005b083          	ld	ra,0(a1)
    8000287a:	0085b103          	ld	sp,8(a1)
    8000287e:	6980                	ld	s0,16(a1)
    80002880:	6d84                	ld	s1,24(a1)
    80002882:	0205b903          	ld	s2,32(a1)
    80002886:	0285b983          	ld	s3,40(a1)
    8000288a:	0305ba03          	ld	s4,48(a1)
    8000288e:	0385ba83          	ld	s5,56(a1)
    80002892:	0405bb03          	ld	s6,64(a1)
    80002896:	0485bb83          	ld	s7,72(a1)
    8000289a:	0505bc03          	ld	s8,80(a1)
    8000289e:	0585bc83          	ld	s9,88(a1)
    800028a2:	0605bd03          	ld	s10,96(a1)
    800028a6:	0685bd83          	ld	s11,104(a1)
    800028aa:	8082                	ret

00000000800028ac <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800028ac:	1141                	addi	sp,sp,-16
    800028ae:	e406                	sd	ra,8(sp)
    800028b0:	e022                	sd	s0,0(sp)
    800028b2:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800028b4:	00006597          	auipc	a1,0x6
    800028b8:	a4458593          	addi	a1,a1,-1468 # 800082f8 <states.1771+0x30>
    800028bc:	00015517          	auipc	a0,0x15
    800028c0:	71450513          	addi	a0,a0,1812 # 80017fd0 <tickslock>
    800028c4:	ffffe097          	auipc	ra,0xffffe
    800028c8:	296080e7          	jalr	662(ra) # 80000b5a <initlock>
}
    800028cc:	60a2                	ld	ra,8(sp)
    800028ce:	6402                	ld	s0,0(sp)
    800028d0:	0141                	addi	sp,sp,16
    800028d2:	8082                	ret

00000000800028d4 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800028d4:	1141                	addi	sp,sp,-16
    800028d6:	e422                	sd	s0,8(sp)
    800028d8:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028da:	00003797          	auipc	a5,0x3
    800028de:	77678793          	addi	a5,a5,1910 # 80006050 <kernelvec>
    800028e2:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800028e6:	6422                	ld	s0,8(sp)
    800028e8:	0141                	addi	sp,sp,16
    800028ea:	8082                	ret

00000000800028ec <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800028ec:	1141                	addi	sp,sp,-16
    800028ee:	e406                	sd	ra,8(sp)
    800028f0:	e022                	sd	s0,0(sp)
    800028f2:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800028f4:	fffff097          	auipc	ra,0xfffff
    800028f8:	0d2080e7          	jalr	210(ra) # 800019c6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028fc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002900:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002902:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002906:	00004617          	auipc	a2,0x4
    8000290a:	6fa60613          	addi	a2,a2,1786 # 80007000 <_trampoline>
    8000290e:	00004697          	auipc	a3,0x4
    80002912:	6f268693          	addi	a3,a3,1778 # 80007000 <_trampoline>
    80002916:	8e91                	sub	a3,a3,a2
    80002918:	040007b7          	lui	a5,0x4000
    8000291c:	17fd                	addi	a5,a5,-1
    8000291e:	07b2                	slli	a5,a5,0xc
    80002920:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002922:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002926:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002928:	180026f3          	csrr	a3,satp
    8000292c:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000292e:	6d38                	ld	a4,88(a0)
    80002930:	6134                	ld	a3,64(a0)
    80002932:	6585                	lui	a1,0x1
    80002934:	96ae                	add	a3,a3,a1
    80002936:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002938:	6d38                	ld	a4,88(a0)
    8000293a:	00000697          	auipc	a3,0x0
    8000293e:	13e68693          	addi	a3,a3,318 # 80002a78 <usertrap>
    80002942:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002944:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002946:	8692                	mv	a3,tp
    80002948:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000294a:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000294e:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002952:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002956:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000295a:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000295c:	6f18                	ld	a4,24(a4)
    8000295e:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002962:	6928                	ld	a0,80(a0)
    80002964:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002966:	00004717          	auipc	a4,0x4
    8000296a:	73670713          	addi	a4,a4,1846 # 8000709c <userret>
    8000296e:	8f11                	sub	a4,a4,a2
    80002970:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002972:	577d                	li	a4,-1
    80002974:	177e                	slli	a4,a4,0x3f
    80002976:	8d59                	or	a0,a0,a4
    80002978:	9782                	jalr	a5
}
    8000297a:	60a2                	ld	ra,8(sp)
    8000297c:	6402                	ld	s0,0(sp)
    8000297e:	0141                	addi	sp,sp,16
    80002980:	8082                	ret

0000000080002982 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002982:	1101                	addi	sp,sp,-32
    80002984:	ec06                	sd	ra,24(sp)
    80002986:	e822                	sd	s0,16(sp)
    80002988:	e426                	sd	s1,8(sp)
    8000298a:	e04a                	sd	s2,0(sp)
    8000298c:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000298e:	00015917          	auipc	s2,0x15
    80002992:	64290913          	addi	s2,s2,1602 # 80017fd0 <tickslock>
    80002996:	854a                	mv	a0,s2
    80002998:	ffffe097          	auipc	ra,0xffffe
    8000299c:	252080e7          	jalr	594(ra) # 80000bea <acquire>
  ticks++;
    800029a0:	00006497          	auipc	s1,0x6
    800029a4:	19048493          	addi	s1,s1,400 # 80008b30 <ticks>
    800029a8:	409c                	lw	a5,0(s1)
    800029aa:	2785                	addiw	a5,a5,1
    800029ac:	c09c                	sw	a5,0(s1)
  update_time();
    800029ae:	fffff097          	auipc	ra,0xfffff
    800029b2:	554080e7          	jalr	1364(ra) # 80001f02 <update_time>
  wakeup(&ticks);
    800029b6:	8526                	mv	a0,s1
    800029b8:	00000097          	auipc	ra,0x0
    800029bc:	980080e7          	jalr	-1664(ra) # 80002338 <wakeup>
  release(&tickslock);
    800029c0:	854a                	mv	a0,s2
    800029c2:	ffffe097          	auipc	ra,0xffffe
    800029c6:	2dc080e7          	jalr	732(ra) # 80000c9e <release>
}
    800029ca:	60e2                	ld	ra,24(sp)
    800029cc:	6442                	ld	s0,16(sp)
    800029ce:	64a2                	ld	s1,8(sp)
    800029d0:	6902                	ld	s2,0(sp)
    800029d2:	6105                	addi	sp,sp,32
    800029d4:	8082                	ret

00000000800029d6 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800029d6:	1101                	addi	sp,sp,-32
    800029d8:	ec06                	sd	ra,24(sp)
    800029da:	e822                	sd	s0,16(sp)
    800029dc:	e426                	sd	s1,8(sp)
    800029de:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029e0:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800029e4:	00074d63          	bltz	a4,800029fe <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800029e8:	57fd                	li	a5,-1
    800029ea:	17fe                	slli	a5,a5,0x3f
    800029ec:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800029ee:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800029f0:	06f70363          	beq	a4,a5,80002a56 <devintr+0x80>
  }
}
    800029f4:	60e2                	ld	ra,24(sp)
    800029f6:	6442                	ld	s0,16(sp)
    800029f8:	64a2                	ld	s1,8(sp)
    800029fa:	6105                	addi	sp,sp,32
    800029fc:	8082                	ret
     (scause & 0xff) == 9){
    800029fe:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002a02:	46a5                	li	a3,9
    80002a04:	fed792e3          	bne	a5,a3,800029e8 <devintr+0x12>
    int irq = plic_claim();
    80002a08:	00003097          	auipc	ra,0x3
    80002a0c:	750080e7          	jalr	1872(ra) # 80006158 <plic_claim>
    80002a10:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002a12:	47a9                	li	a5,10
    80002a14:	02f50763          	beq	a0,a5,80002a42 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002a18:	4785                	li	a5,1
    80002a1a:	02f50963          	beq	a0,a5,80002a4c <devintr+0x76>
    return 1;
    80002a1e:	4505                	li	a0,1
    } else if(irq){
    80002a20:	d8f1                	beqz	s1,800029f4 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002a22:	85a6                	mv	a1,s1
    80002a24:	00006517          	auipc	a0,0x6
    80002a28:	8dc50513          	addi	a0,a0,-1828 # 80008300 <states.1771+0x38>
    80002a2c:	ffffe097          	auipc	ra,0xffffe
    80002a30:	b62080e7          	jalr	-1182(ra) # 8000058e <printf>
      plic_complete(irq);
    80002a34:	8526                	mv	a0,s1
    80002a36:	00003097          	auipc	ra,0x3
    80002a3a:	746080e7          	jalr	1862(ra) # 8000617c <plic_complete>
    return 1;
    80002a3e:	4505                	li	a0,1
    80002a40:	bf55                	j	800029f4 <devintr+0x1e>
      uartintr();
    80002a42:	ffffe097          	auipc	ra,0xffffe
    80002a46:	f6c080e7          	jalr	-148(ra) # 800009ae <uartintr>
    80002a4a:	b7ed                	j	80002a34 <devintr+0x5e>
      virtio_disk_intr();
    80002a4c:	00004097          	auipc	ra,0x4
    80002a50:	c5a080e7          	jalr	-934(ra) # 800066a6 <virtio_disk_intr>
    80002a54:	b7c5                	j	80002a34 <devintr+0x5e>
    if(cpuid() == 0){
    80002a56:	fffff097          	auipc	ra,0xfffff
    80002a5a:	f44080e7          	jalr	-188(ra) # 8000199a <cpuid>
    80002a5e:	c901                	beqz	a0,80002a6e <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002a60:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002a64:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002a66:	14479073          	csrw	sip,a5
    return 2;
    80002a6a:	4509                	li	a0,2
    80002a6c:	b761                	j	800029f4 <devintr+0x1e>
      clockintr();
    80002a6e:	00000097          	auipc	ra,0x0
    80002a72:	f14080e7          	jalr	-236(ra) # 80002982 <clockintr>
    80002a76:	b7ed                	j	80002a60 <devintr+0x8a>

0000000080002a78 <usertrap>:
{
    80002a78:	1101                	addi	sp,sp,-32
    80002a7a:	ec06                	sd	ra,24(sp)
    80002a7c:	e822                	sd	s0,16(sp)
    80002a7e:	e426                	sd	s1,8(sp)
    80002a80:	e04a                	sd	s2,0(sp)
    80002a82:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a84:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002a88:	1007f793          	andi	a5,a5,256
    80002a8c:	e3b1                	bnez	a5,80002ad0 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a8e:	00003797          	auipc	a5,0x3
    80002a92:	5c278793          	addi	a5,a5,1474 # 80006050 <kernelvec>
    80002a96:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002a9a:	fffff097          	auipc	ra,0xfffff
    80002a9e:	f2c080e7          	jalr	-212(ra) # 800019c6 <myproc>
    80002aa2:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002aa4:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002aa6:	14102773          	csrr	a4,sepc
    80002aaa:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002aac:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002ab0:	47a1                	li	a5,8
    80002ab2:	02f70763          	beq	a4,a5,80002ae0 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002ab6:	00000097          	auipc	ra,0x0
    80002aba:	f20080e7          	jalr	-224(ra) # 800029d6 <devintr>
    80002abe:	892a                	mv	s2,a0
    80002ac0:	c92d                	beqz	a0,80002b32 <usertrap+0xba>
  if(killed(p))
    80002ac2:	8526                	mv	a0,s1
    80002ac4:	00000097          	auipc	ra,0x0
    80002ac8:	ac4080e7          	jalr	-1340(ra) # 80002588 <killed>
    80002acc:	c555                	beqz	a0,80002b78 <usertrap+0x100>
    80002ace:	a045                	j	80002b6e <usertrap+0xf6>
    panic("usertrap: not from user mode");
    80002ad0:	00006517          	auipc	a0,0x6
    80002ad4:	85050513          	addi	a0,a0,-1968 # 80008320 <states.1771+0x58>
    80002ad8:	ffffe097          	auipc	ra,0xffffe
    80002adc:	a6c080e7          	jalr	-1428(ra) # 80000544 <panic>
    if(killed(p))
    80002ae0:	00000097          	auipc	ra,0x0
    80002ae4:	aa8080e7          	jalr	-1368(ra) # 80002588 <killed>
    80002ae8:	ed1d                	bnez	a0,80002b26 <usertrap+0xae>
    p->trapframe->epc += 4;
    80002aea:	6cb8                	ld	a4,88(s1)
    80002aec:	6f1c                	ld	a5,24(a4)
    80002aee:	0791                	addi	a5,a5,4
    80002af0:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002af2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002af6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002afa:	10079073          	csrw	sstatus,a5
    syscall();
    80002afe:	00000097          	auipc	ra,0x0
    80002b02:	328080e7          	jalr	808(ra) # 80002e26 <syscall>
  if(killed(p))
    80002b06:	8526                	mv	a0,s1
    80002b08:	00000097          	auipc	ra,0x0
    80002b0c:	a80080e7          	jalr	-1408(ra) # 80002588 <killed>
    80002b10:	ed31                	bnez	a0,80002b6c <usertrap+0xf4>
  usertrapret();
    80002b12:	00000097          	auipc	ra,0x0
    80002b16:	dda080e7          	jalr	-550(ra) # 800028ec <usertrapret>
}
    80002b1a:	60e2                	ld	ra,24(sp)
    80002b1c:	6442                	ld	s0,16(sp)
    80002b1e:	64a2                	ld	s1,8(sp)
    80002b20:	6902                	ld	s2,0(sp)
    80002b22:	6105                	addi	sp,sp,32
    80002b24:	8082                	ret
      exit(-1);
    80002b26:	557d                	li	a0,-1
    80002b28:	00000097          	auipc	ra,0x0
    80002b2c:	8e0080e7          	jalr	-1824(ra) # 80002408 <exit>
    80002b30:	bf6d                	j	80002aea <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b32:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002b36:	5890                	lw	a2,48(s1)
    80002b38:	00006517          	auipc	a0,0x6
    80002b3c:	80850513          	addi	a0,a0,-2040 # 80008340 <states.1771+0x78>
    80002b40:	ffffe097          	auipc	ra,0xffffe
    80002b44:	a4e080e7          	jalr	-1458(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b48:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b4c:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b50:	00006517          	auipc	a0,0x6
    80002b54:	82050513          	addi	a0,a0,-2016 # 80008370 <states.1771+0xa8>
    80002b58:	ffffe097          	auipc	ra,0xffffe
    80002b5c:	a36080e7          	jalr	-1482(ra) # 8000058e <printf>
    setkilled(p);
    80002b60:	8526                	mv	a0,s1
    80002b62:	00000097          	auipc	ra,0x0
    80002b66:	9fa080e7          	jalr	-1542(ra) # 8000255c <setkilled>
    80002b6a:	bf71                	j	80002b06 <usertrap+0x8e>
  if(killed(p))
    80002b6c:	4901                	li	s2,0
    exit(-1);
    80002b6e:	557d                	li	a0,-1
    80002b70:	00000097          	auipc	ra,0x0
    80002b74:	898080e7          	jalr	-1896(ra) # 80002408 <exit>
  if (which_dev == 2 && p->alarm_on == 1 && p->handlerpermission == 1) {
    80002b78:	4789                	li	a5,2
    80002b7a:	f8f91ce3          	bne	s2,a5,80002b12 <usertrap+0x9a>
    80002b7e:	1984a703          	lw	a4,408(s1)
    80002b82:	4785                	li	a5,1
    80002b84:	00f70763          	beq	a4,a5,80002b92 <usertrap+0x11a>
    yield();
    80002b88:	fffff097          	auipc	ra,0xfffff
    80002b8c:	5c4080e7          	jalr	1476(ra) # 8000214c <yield>
    80002b90:	b749                	j	80002b12 <usertrap+0x9a>
  if (which_dev == 2 && p->alarm_on == 1 && p->handlerpermission == 1) {
    80002b92:	1b04a703          	lw	a4,432(s1)
    80002b96:	fef719e3          	bne	a4,a5,80002b88 <usertrap+0x110>
      struct trapframe *tf = kalloc();
    80002b9a:	ffffe097          	auipc	ra,0xffffe
    80002b9e:	f60080e7          	jalr	-160(ra) # 80000afa <kalloc>
    80002ba2:	892a                	mv	s2,a0
      memmove(tf, p->trapframe, PGSIZE);
    80002ba4:	6605                	lui	a2,0x1
    80002ba6:	6cac                	ld	a1,88(s1)
    80002ba8:	ffffe097          	auipc	ra,0xffffe
    80002bac:	19e080e7          	jalr	414(ra) # 80000d46 <memmove>
      p->alarm_tf = tf;
    80002bb0:	1924b823          	sd	s2,400(s1)
      p->cur_ticks++;
    80002bb4:	18c4a783          	lw	a5,396(s1)
    80002bb8:	2785                	addiw	a5,a5,1
    80002bba:	0007871b          	sext.w	a4,a5
    80002bbe:	18f4a623          	sw	a5,396(s1)
      if (p->cur_ticks >= p->ticks){
    80002bc2:	1884a783          	lw	a5,392(s1)
    80002bc6:	fcf741e3          	blt	a4,a5,80002b88 <usertrap+0x110>
        p->trapframe->epc = p->handler;
    80002bca:	6cbc                	ld	a5,88(s1)
    80002bcc:	1804b703          	ld	a4,384(s1)
    80002bd0:	ef98                	sd	a4,24(a5)
        p->handlerpermission = 0;
    80002bd2:	1a04a823          	sw	zero,432(s1)
    80002bd6:	bf4d                	j	80002b88 <usertrap+0x110>

0000000080002bd8 <kerneltrap>:
{
    80002bd8:	7179                	addi	sp,sp,-48
    80002bda:	f406                	sd	ra,40(sp)
    80002bdc:	f022                	sd	s0,32(sp)
    80002bde:	ec26                	sd	s1,24(sp)
    80002be0:	e84a                	sd	s2,16(sp)
    80002be2:	e44e                	sd	s3,8(sp)
    80002be4:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002be6:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bea:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bee:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002bf2:	1004f793          	andi	a5,s1,256
    80002bf6:	cb85                	beqz	a5,80002c26 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bf8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002bfc:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002bfe:	ef85                	bnez	a5,80002c36 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002c00:	00000097          	auipc	ra,0x0
    80002c04:	dd6080e7          	jalr	-554(ra) # 800029d6 <devintr>
    80002c08:	cd1d                	beqz	a0,80002c46 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c0a:	4789                	li	a5,2
    80002c0c:	06f50a63          	beq	a0,a5,80002c80 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c10:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c14:	10049073          	csrw	sstatus,s1
}
    80002c18:	70a2                	ld	ra,40(sp)
    80002c1a:	7402                	ld	s0,32(sp)
    80002c1c:	64e2                	ld	s1,24(sp)
    80002c1e:	6942                	ld	s2,16(sp)
    80002c20:	69a2                	ld	s3,8(sp)
    80002c22:	6145                	addi	sp,sp,48
    80002c24:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c26:	00005517          	auipc	a0,0x5
    80002c2a:	76a50513          	addi	a0,a0,1898 # 80008390 <states.1771+0xc8>
    80002c2e:	ffffe097          	auipc	ra,0xffffe
    80002c32:	916080e7          	jalr	-1770(ra) # 80000544 <panic>
    panic("kerneltrap: interrupts enabled");
    80002c36:	00005517          	auipc	a0,0x5
    80002c3a:	78250513          	addi	a0,a0,1922 # 800083b8 <states.1771+0xf0>
    80002c3e:	ffffe097          	auipc	ra,0xffffe
    80002c42:	906080e7          	jalr	-1786(ra) # 80000544 <panic>
    printf("scause %p\n", scause);
    80002c46:	85ce                	mv	a1,s3
    80002c48:	00005517          	auipc	a0,0x5
    80002c4c:	79050513          	addi	a0,a0,1936 # 800083d8 <states.1771+0x110>
    80002c50:	ffffe097          	auipc	ra,0xffffe
    80002c54:	93e080e7          	jalr	-1730(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c58:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c5c:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c60:	00005517          	auipc	a0,0x5
    80002c64:	78850513          	addi	a0,a0,1928 # 800083e8 <states.1771+0x120>
    80002c68:	ffffe097          	auipc	ra,0xffffe
    80002c6c:	926080e7          	jalr	-1754(ra) # 8000058e <printf>
    panic("kerneltrap");
    80002c70:	00005517          	auipc	a0,0x5
    80002c74:	79050513          	addi	a0,a0,1936 # 80008400 <states.1771+0x138>
    80002c78:	ffffe097          	auipc	ra,0xffffe
    80002c7c:	8cc080e7          	jalr	-1844(ra) # 80000544 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c80:	fffff097          	auipc	ra,0xfffff
    80002c84:	d46080e7          	jalr	-698(ra) # 800019c6 <myproc>
    80002c88:	d541                	beqz	a0,80002c10 <kerneltrap+0x38>
    80002c8a:	fffff097          	auipc	ra,0xfffff
    80002c8e:	d3c080e7          	jalr	-708(ra) # 800019c6 <myproc>
    80002c92:	4d18                	lw	a4,24(a0)
    80002c94:	4791                	li	a5,4
    80002c96:	f6f71de3          	bne	a4,a5,80002c10 <kerneltrap+0x38>
    yield();
    80002c9a:	fffff097          	auipc	ra,0xfffff
    80002c9e:	4b2080e7          	jalr	1202(ra) # 8000214c <yield>
    80002ca2:	b7bd                	j	80002c10 <kerneltrap+0x38>

0000000080002ca4 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002ca4:	1101                	addi	sp,sp,-32
    80002ca6:	ec06                	sd	ra,24(sp)
    80002ca8:	e822                	sd	s0,16(sp)
    80002caa:	e426                	sd	s1,8(sp)
    80002cac:	1000                	addi	s0,sp,32
    80002cae:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002cb0:	fffff097          	auipc	ra,0xfffff
    80002cb4:	d16080e7          	jalr	-746(ra) # 800019c6 <myproc>
  switch (n) {
    80002cb8:	4795                	li	a5,5
    80002cba:	0497e163          	bltu	a5,s1,80002cfc <argraw+0x58>
    80002cbe:	048a                	slli	s1,s1,0x2
    80002cc0:	00006717          	auipc	a4,0x6
    80002cc4:	88870713          	addi	a4,a4,-1912 # 80008548 <states.1771+0x280>
    80002cc8:	94ba                	add	s1,s1,a4
    80002cca:	409c                	lw	a5,0(s1)
    80002ccc:	97ba                	add	a5,a5,a4
    80002cce:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002cd0:	6d3c                	ld	a5,88(a0)
    80002cd2:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002cd4:	60e2                	ld	ra,24(sp)
    80002cd6:	6442                	ld	s0,16(sp)
    80002cd8:	64a2                	ld	s1,8(sp)
    80002cda:	6105                	addi	sp,sp,32
    80002cdc:	8082                	ret
    return p->trapframe->a1;
    80002cde:	6d3c                	ld	a5,88(a0)
    80002ce0:	7fa8                	ld	a0,120(a5)
    80002ce2:	bfcd                	j	80002cd4 <argraw+0x30>
    return p->trapframe->a2;
    80002ce4:	6d3c                	ld	a5,88(a0)
    80002ce6:	63c8                	ld	a0,128(a5)
    80002ce8:	b7f5                	j	80002cd4 <argraw+0x30>
    return p->trapframe->a3;
    80002cea:	6d3c                	ld	a5,88(a0)
    80002cec:	67c8                	ld	a0,136(a5)
    80002cee:	b7dd                	j	80002cd4 <argraw+0x30>
    return p->trapframe->a4;
    80002cf0:	6d3c                	ld	a5,88(a0)
    80002cf2:	6bc8                	ld	a0,144(a5)
    80002cf4:	b7c5                	j	80002cd4 <argraw+0x30>
    return p->trapframe->a5;
    80002cf6:	6d3c                	ld	a5,88(a0)
    80002cf8:	6fc8                	ld	a0,152(a5)
    80002cfa:	bfe9                	j	80002cd4 <argraw+0x30>
  panic("argraw");
    80002cfc:	00005517          	auipc	a0,0x5
    80002d00:	71450513          	addi	a0,a0,1812 # 80008410 <states.1771+0x148>
    80002d04:	ffffe097          	auipc	ra,0xffffe
    80002d08:	840080e7          	jalr	-1984(ra) # 80000544 <panic>

0000000080002d0c <fetchaddr>:
{
    80002d0c:	1101                	addi	sp,sp,-32
    80002d0e:	ec06                	sd	ra,24(sp)
    80002d10:	e822                	sd	s0,16(sp)
    80002d12:	e426                	sd	s1,8(sp)
    80002d14:	e04a                	sd	s2,0(sp)
    80002d16:	1000                	addi	s0,sp,32
    80002d18:	84aa                	mv	s1,a0
    80002d1a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d1c:	fffff097          	auipc	ra,0xfffff
    80002d20:	caa080e7          	jalr	-854(ra) # 800019c6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002d24:	653c                	ld	a5,72(a0)
    80002d26:	02f4f863          	bgeu	s1,a5,80002d56 <fetchaddr+0x4a>
    80002d2a:	00848713          	addi	a4,s1,8
    80002d2e:	02e7e663          	bltu	a5,a4,80002d5a <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d32:	46a1                	li	a3,8
    80002d34:	8626                	mv	a2,s1
    80002d36:	85ca                	mv	a1,s2
    80002d38:	6928                	ld	a0,80(a0)
    80002d3a:	fffff097          	auipc	ra,0xfffff
    80002d3e:	9d6080e7          	jalr	-1578(ra) # 80001710 <copyin>
    80002d42:	00a03533          	snez	a0,a0
    80002d46:	40a00533          	neg	a0,a0
}
    80002d4a:	60e2                	ld	ra,24(sp)
    80002d4c:	6442                	ld	s0,16(sp)
    80002d4e:	64a2                	ld	s1,8(sp)
    80002d50:	6902                	ld	s2,0(sp)
    80002d52:	6105                	addi	sp,sp,32
    80002d54:	8082                	ret
    return -1;
    80002d56:	557d                	li	a0,-1
    80002d58:	bfcd                	j	80002d4a <fetchaddr+0x3e>
    80002d5a:	557d                	li	a0,-1
    80002d5c:	b7fd                	j	80002d4a <fetchaddr+0x3e>

0000000080002d5e <fetchstr>:
{
    80002d5e:	7179                	addi	sp,sp,-48
    80002d60:	f406                	sd	ra,40(sp)
    80002d62:	f022                	sd	s0,32(sp)
    80002d64:	ec26                	sd	s1,24(sp)
    80002d66:	e84a                	sd	s2,16(sp)
    80002d68:	e44e                	sd	s3,8(sp)
    80002d6a:	1800                	addi	s0,sp,48
    80002d6c:	892a                	mv	s2,a0
    80002d6e:	84ae                	mv	s1,a1
    80002d70:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002d72:	fffff097          	auipc	ra,0xfffff
    80002d76:	c54080e7          	jalr	-940(ra) # 800019c6 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002d7a:	86ce                	mv	a3,s3
    80002d7c:	864a                	mv	a2,s2
    80002d7e:	85a6                	mv	a1,s1
    80002d80:	6928                	ld	a0,80(a0)
    80002d82:	fffff097          	auipc	ra,0xfffff
    80002d86:	a1a080e7          	jalr	-1510(ra) # 8000179c <copyinstr>
    80002d8a:	00054e63          	bltz	a0,80002da6 <fetchstr+0x48>
  return strlen(buf);
    80002d8e:	8526                	mv	a0,s1
    80002d90:	ffffe097          	auipc	ra,0xffffe
    80002d94:	0da080e7          	jalr	218(ra) # 80000e6a <strlen>
}
    80002d98:	70a2                	ld	ra,40(sp)
    80002d9a:	7402                	ld	s0,32(sp)
    80002d9c:	64e2                	ld	s1,24(sp)
    80002d9e:	6942                	ld	s2,16(sp)
    80002da0:	69a2                	ld	s3,8(sp)
    80002da2:	6145                	addi	sp,sp,48
    80002da4:	8082                	ret
    return -1;
    80002da6:	557d                	li	a0,-1
    80002da8:	bfc5                	j	80002d98 <fetchstr+0x3a>

0000000080002daa <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002daa:	1101                	addi	sp,sp,-32
    80002dac:	ec06                	sd	ra,24(sp)
    80002dae:	e822                	sd	s0,16(sp)
    80002db0:	e426                	sd	s1,8(sp)
    80002db2:	1000                	addi	s0,sp,32
    80002db4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002db6:	00000097          	auipc	ra,0x0
    80002dba:	eee080e7          	jalr	-274(ra) # 80002ca4 <argraw>
    80002dbe:	c088                	sw	a0,0(s1)
  return 0;
}
    80002dc0:	4501                	li	a0,0
    80002dc2:	60e2                	ld	ra,24(sp)
    80002dc4:	6442                	ld	s0,16(sp)
    80002dc6:	64a2                	ld	s1,8(sp)
    80002dc8:	6105                	addi	sp,sp,32
    80002dca:	8082                	ret

0000000080002dcc <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002dcc:	1101                	addi	sp,sp,-32
    80002dce:	ec06                	sd	ra,24(sp)
    80002dd0:	e822                	sd	s0,16(sp)
    80002dd2:	e426                	sd	s1,8(sp)
    80002dd4:	1000                	addi	s0,sp,32
    80002dd6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002dd8:	00000097          	auipc	ra,0x0
    80002ddc:	ecc080e7          	jalr	-308(ra) # 80002ca4 <argraw>
    80002de0:	e088                	sd	a0,0(s1)
  return 0;
}
    80002de2:	4501                	li	a0,0
    80002de4:	60e2                	ld	ra,24(sp)
    80002de6:	6442                	ld	s0,16(sp)
    80002de8:	64a2                	ld	s1,8(sp)
    80002dea:	6105                	addi	sp,sp,32
    80002dec:	8082                	ret

0000000080002dee <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002dee:	7179                	addi	sp,sp,-48
    80002df0:	f406                	sd	ra,40(sp)
    80002df2:	f022                	sd	s0,32(sp)
    80002df4:	ec26                	sd	s1,24(sp)
    80002df6:	e84a                	sd	s2,16(sp)
    80002df8:	1800                	addi	s0,sp,48
    80002dfa:	84ae                	mv	s1,a1
    80002dfc:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002dfe:	fd840593          	addi	a1,s0,-40
    80002e02:	00000097          	auipc	ra,0x0
    80002e06:	fca080e7          	jalr	-54(ra) # 80002dcc <argaddr>
  return fetchstr(addr, buf, max);
    80002e0a:	864a                	mv	a2,s2
    80002e0c:	85a6                	mv	a1,s1
    80002e0e:	fd843503          	ld	a0,-40(s0)
    80002e12:	00000097          	auipc	ra,0x0
    80002e16:	f4c080e7          	jalr	-180(ra) # 80002d5e <fetchstr>
}
    80002e1a:	70a2                	ld	ra,40(sp)
    80002e1c:	7402                	ld	s0,32(sp)
    80002e1e:	64e2                	ld	s1,24(sp)
    80002e20:	6942                	ld	s2,16(sp)
    80002e22:	6145                	addi	sp,sp,48
    80002e24:	8082                	ret

0000000080002e26 <syscall>:
    [SYS_settickets] 1,
};

void
syscall(void)
{
    80002e26:	7179                	addi	sp,sp,-48
    80002e28:	f406                	sd	ra,40(sp)
    80002e2a:	f022                	sd	s0,32(sp)
    80002e2c:	ec26                	sd	s1,24(sp)
    80002e2e:	e84a                	sd	s2,16(sp)
    80002e30:	e44e                	sd	s3,8(sp)
    80002e32:	e052                	sd	s4,0(sp)
    80002e34:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002e36:	fffff097          	auipc	ra,0xfffff
    80002e3a:	b90080e7          	jalr	-1136(ra) # 800019c6 <myproc>
    80002e3e:	892a                	mv	s2,a0

  num = p->trapframe->a7;
    80002e40:	6d24                	ld	s1,88(a0)
    80002e42:	74dc                	ld	a5,168(s1)
    80002e44:	0007899b          	sext.w	s3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) 
    80002e48:	37fd                	addiw	a5,a5,-1
    80002e4a:	4765                	li	a4,25
    80002e4c:	0af76163          	bltu	a4,a5,80002eee <syscall+0xc8>
    80002e50:	00399713          	slli	a4,s3,0x3
    80002e54:	00005797          	auipc	a5,0x5
    80002e58:	70c78793          	addi	a5,a5,1804 # 80008560 <syscalls>
    80002e5c:	97ba                	add	a5,a5,a4
    80002e5e:	639c                	ld	a5,0(a5)
    80002e60:	c7d9                	beqz	a5,80002eee <syscall+0xc8>
  {
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002e62:	9782                	jalr	a5
    80002e64:	f8a8                	sd	a0,112(s1)
    if ((p->mask >> num) & 1)
    80002e66:	16892483          	lw	s1,360(s2)
    80002e6a:	4134d4bb          	sraw	s1,s1,s3
    80002e6e:	8885                	andi	s1,s1,1
    80002e70:	c0c5                	beqz	s1,80002f10 <syscall+0xea>
    {
      /* Modified for A4: Added entire section for trace, prints output for each syscall traced */
  	  printf("%d: syscall %s ( %d ",p->pid, syscallnames[num], p->trapframe->a0);
    80002e72:	05893703          	ld	a4,88(s2)
    80002e76:	00399693          	slli	a3,s3,0x3
    80002e7a:	00006797          	auipc	a5,0x6
    80002e7e:	bae78793          	addi	a5,a5,-1106 # 80008a28 <syscallnames>
    80002e82:	97b6                	add	a5,a5,a3
    80002e84:	7b34                	ld	a3,112(a4)
    80002e86:	6390                	ld	a2,0(a5)
    80002e88:	03092583          	lw	a1,48(s2)
    80002e8c:	00005517          	auipc	a0,0x5
    80002e90:	58c50513          	addi	a0,a0,1420 # 80008418 <states.1771+0x150>
    80002e94:	ffffd097          	auipc	ra,0xffffd
    80002e98:	6fa080e7          	jalr	1786(ra) # 8000058e <printf>
      for (int i = 1; i < syscallnum[num]; i++) /* Modified for A4: 'num' tracks number of registers used by syscall and prints its register values  */
    80002e9c:	098a                	slli	s3,s3,0x2
    80002e9e:	00005797          	auipc	a5,0x5
    80002ea2:	6c278793          	addi	a5,a5,1730 # 80008560 <syscalls>
    80002ea6:	99be                	add	s3,s3,a5
    80002ea8:	0d89a983          	lw	s3,216(s3)
    80002eac:	4785                	li	a5,1
    80002eae:	0337d463          	bge	a5,s3,80002ed6 <syscall+0xb0>
        printf("%d ", argraw(i));
    80002eb2:	00005a17          	auipc	s4,0x5
    80002eb6:	57ea0a13          	addi	s4,s4,1406 # 80008430 <states.1771+0x168>
    80002eba:	8526                	mv	a0,s1
    80002ebc:	00000097          	auipc	ra,0x0
    80002ec0:	de8080e7          	jalr	-536(ra) # 80002ca4 <argraw>
    80002ec4:	85aa                	mv	a1,a0
    80002ec6:	8552                	mv	a0,s4
    80002ec8:	ffffd097          	auipc	ra,0xffffd
    80002ecc:	6c6080e7          	jalr	1734(ra) # 8000058e <printf>
      for (int i = 1; i < syscallnum[num]; i++) /* Modified for A4: 'num' tracks number of registers used by syscall and prints its register values  */
    80002ed0:	2485                	addiw	s1,s1,1
    80002ed2:	ff3494e3          	bne	s1,s3,80002eba <syscall+0x94>
      printf(") -> %d\n", p->trapframe->a0);
    80002ed6:	05893783          	ld	a5,88(s2)
    80002eda:	7bac                	ld	a1,112(a5)
    80002edc:	00005517          	auipc	a0,0x5
    80002ee0:	55c50513          	addi	a0,a0,1372 # 80008438 <states.1771+0x170>
    80002ee4:	ffffd097          	auipc	ra,0xffffd
    80002ee8:	6aa080e7          	jalr	1706(ra) # 8000058e <printf>
    80002eec:	a015                	j	80002f10 <syscall+0xea>
    }	
  } 
  else 
  {
    printf("%d %s: unknown sys call %d\n",
    80002eee:	86ce                	mv	a3,s3
    80002ef0:	15890613          	addi	a2,s2,344
    80002ef4:	03092583          	lw	a1,48(s2)
    80002ef8:	00005517          	auipc	a0,0x5
    80002efc:	55050513          	addi	a0,a0,1360 # 80008448 <states.1771+0x180>
    80002f00:	ffffd097          	auipc	ra,0xffffd
    80002f04:	68e080e7          	jalr	1678(ra) # 8000058e <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002f08:	05893783          	ld	a5,88(s2)
    80002f0c:	577d                	li	a4,-1
    80002f0e:	fbb8                	sd	a4,112(a5)
  
  // if (p->mask >> num)
  // {
  // 	printf("%d: syscall %s -> %d\n",p->pid, syscallnames[num], p->trapframe->a0);
  // }	
}
    80002f10:	70a2                	ld	ra,40(sp)
    80002f12:	7402                	ld	s0,32(sp)
    80002f14:	64e2                	ld	s1,24(sp)
    80002f16:	6942                	ld	s2,16(sp)
    80002f18:	69a2                	ld	s3,8(sp)
    80002f1a:	6a02                	ld	s4,0(sp)
    80002f1c:	6145                	addi	sp,sp,48
    80002f1e:	8082                	ret

0000000080002f20 <sys_trace>:

int mask;

uint64
sys_trace(void)
{
    80002f20:	1141                	addi	sp,sp,-16
    80002f22:	e406                	sd	ra,8(sp)
    80002f24:	e022                	sd	s0,0(sp)
    80002f26:	0800                	addi	s0,sp,16
	if(argint(0, &mask) < 0)
    80002f28:	00006597          	auipc	a1,0x6
    80002f2c:	c0c58593          	addi	a1,a1,-1012 # 80008b34 <mask>
    80002f30:	4501                	li	a0,0
    80002f32:	00000097          	auipc	ra,0x0
    80002f36:	e78080e7          	jalr	-392(ra) # 80002daa <argint>
	{
		return -1;
    80002f3a:	57fd                	li	a5,-1
	if(argint(0, &mask) < 0)
    80002f3c:	00054d63          	bltz	a0,80002f56 <sys_trace+0x36>
	}
	
  myproc()->mask = mask;
    80002f40:	fffff097          	auipc	ra,0xfffff
    80002f44:	a86080e7          	jalr	-1402(ra) # 800019c6 <myproc>
    80002f48:	00006797          	auipc	a5,0x6
    80002f4c:	bec7a783          	lw	a5,-1044(a5) # 80008b34 <mask>
    80002f50:	16f52423          	sw	a5,360(a0)
	return 0;
    80002f54:	4781                	li	a5,0
}	/* Modified for A4: Added trace */
    80002f56:	853e                	mv	a0,a5
    80002f58:	60a2                	ld	ra,8(sp)
    80002f5a:	6402                	ld	s0,0(sp)
    80002f5c:	0141                	addi	sp,sp,16
    80002f5e:	8082                	ret

0000000080002f60 <sys_sigalarm>:

/* Modified for A4: Added trace */
uint64 
sys_sigalarm(void)
{
    80002f60:	1101                	addi	sp,sp,-32
    80002f62:	ec06                	sd	ra,24(sp)
    80002f64:	e822                	sd	s0,16(sp)
    80002f66:	1000                	addi	s0,sp,32
  uint64 addr;
  int ticks;
  if(argint(0, &ticks) < 0)
    80002f68:	fe440593          	addi	a1,s0,-28
    80002f6c:	4501                	li	a0,0
    80002f6e:	00000097          	auipc	ra,0x0
    80002f72:	e3c080e7          	jalr	-452(ra) # 80002daa <argint>
    return -1;
    80002f76:	57fd                	li	a5,-1
  if(argint(0, &ticks) < 0)
    80002f78:	04054463          	bltz	a0,80002fc0 <sys_sigalarm+0x60>
  if(argaddr(1, &addr) < 0)
    80002f7c:	fe840593          	addi	a1,s0,-24
    80002f80:	4505                	li	a0,1
    80002f82:	00000097          	auipc	ra,0x0
    80002f86:	e4a080e7          	jalr	-438(ra) # 80002dcc <argaddr>
    return -1;
    80002f8a:	57fd                	li	a5,-1
  if(argaddr(1, &addr) < 0)
    80002f8c:	02054a63          	bltz	a0,80002fc0 <sys_sigalarm+0x60>

  myproc()->ticks = ticks;
    80002f90:	fffff097          	auipc	ra,0xfffff
    80002f94:	a36080e7          	jalr	-1482(ra) # 800019c6 <myproc>
    80002f98:	fe442783          	lw	a5,-28(s0)
    80002f9c:	18f52423          	sw	a5,392(a0)
  myproc()->handler = addr;
    80002fa0:	fffff097          	auipc	ra,0xfffff
    80002fa4:	a26080e7          	jalr	-1498(ra) # 800019c6 <myproc>
    80002fa8:	fe843783          	ld	a5,-24(s0)
    80002fac:	18f53023          	sd	a5,384(a0)
  myproc()->alarm_on = 1;
    80002fb0:	fffff097          	auipc	ra,0xfffff
    80002fb4:	a16080e7          	jalr	-1514(ra) # 800019c6 <myproc>
    80002fb8:	4785                	li	a5,1
    80002fba:	18f52c23          	sw	a5,408(a0)
  //myproc()->a1 = myproc()->trapframe->a0;
  //myproc()->a2 = myproc()->trapframe->a1;

  return 0;
    80002fbe:	4781                	li	a5,0
}
    80002fc0:	853e                	mv	a0,a5
    80002fc2:	60e2                	ld	ra,24(sp)
    80002fc4:	6442                	ld	s0,16(sp)
    80002fc6:	6105                	addi	sp,sp,32
    80002fc8:	8082                	ret

0000000080002fca <sys_sigreturn>:

/* Modified for A4: Added trace */
uint64 
sys_sigreturn(void)
{
    80002fca:	1101                	addi	sp,sp,-32
    80002fcc:	ec06                	sd	ra,24(sp)
    80002fce:	e822                	sd	s0,16(sp)
    80002fd0:	e426                	sd	s1,8(sp)
    80002fd2:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002fd4:	fffff097          	auipc	ra,0xfffff
    80002fd8:	9f2080e7          	jalr	-1550(ra) # 800019c6 <myproc>
    80002fdc:	84aa                	mv	s1,a0
  memmove(p->trapframe, p->alarm_tf, PGSIZE);
    80002fde:	6605                	lui	a2,0x1
    80002fe0:	19053583          	ld	a1,400(a0)
    80002fe4:	6d28                	ld	a0,88(a0)
    80002fe6:	ffffe097          	auipc	ra,0xffffe
    80002fea:	d60080e7          	jalr	-672(ra) # 80000d46 <memmove>
  //myproc()->trapframe->a0 = myproc()->a1;
  //myproc()->trapframe->a1 = myproc()->a2;
  kfree(p->alarm_tf);
    80002fee:	1904b503          	ld	a0,400(s1)
    80002ff2:	ffffe097          	auipc	ra,0xffffe
    80002ff6:	a0c080e7          	jalr	-1524(ra) # 800009fe <kfree>
  p->cur_ticks = 0;
    80002ffa:	1804a623          	sw	zero,396(s1)
  p->handlerpermission = 1;
    80002ffe:	4785                	li	a5,1
    80003000:	1af4a823          	sw	a5,432(s1)
  return myproc()->trapframe->a0;
    80003004:	fffff097          	auipc	ra,0xfffff
    80003008:	9c2080e7          	jalr	-1598(ra) # 800019c6 <myproc>
    8000300c:	6d3c                	ld	a5,88(a0)
}
    8000300e:	7ba8                	ld	a0,112(a5)
    80003010:	60e2                	ld	ra,24(sp)
    80003012:	6442                	ld	s0,16(sp)
    80003014:	64a2                	ld	s1,8(sp)
    80003016:	6105                	addi	sp,sp,32
    80003018:	8082                	ret

000000008000301a <sys_settickets>:

uint64 
sys_settickets(void)
{
    8000301a:	7179                	addi	sp,sp,-48
    8000301c:	f406                	sd	ra,40(sp)
    8000301e:	f022                	sd	s0,32(sp)
    80003020:	ec26                	sd	s1,24(sp)
    80003022:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80003024:	fffff097          	auipc	ra,0xfffff
    80003028:	9a2080e7          	jalr	-1630(ra) # 800019c6 <myproc>
    8000302c:	84aa                	mv	s1,a0
  int tickets;
  if(argint(0, &tickets) < 0)
    8000302e:	fdc40593          	addi	a1,s0,-36
    80003032:	4501                	li	a0,0
    80003034:	00000097          	auipc	ra,0x0
    80003038:	d76080e7          	jalr	-650(ra) # 80002daa <argint>
    8000303c:	00054c63          	bltz	a0,80003054 <sys_settickets+0x3a>
    return -1;
  p->tickets = tickets;
    80003040:	fdc42783          	lw	a5,-36(s0)
    80003044:	1af4aa23          	sw	a5,436(s1)
  return 0; 
    80003048:	4501                	li	a0,0
}
    8000304a:	70a2                	ld	ra,40(sp)
    8000304c:	7402                	ld	s0,32(sp)
    8000304e:	64e2                	ld	s1,24(sp)
    80003050:	6145                	addi	sp,sp,48
    80003052:	8082                	ret
    return -1;
    80003054:	557d                	li	a0,-1
    80003056:	bfd5                	j	8000304a <sys_settickets+0x30>

0000000080003058 <sys_exit>:


uint64
sys_exit(void)
{
    80003058:	1101                	addi	sp,sp,-32
    8000305a:	ec06                	sd	ra,24(sp)
    8000305c:	e822                	sd	s0,16(sp)
    8000305e:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80003060:	fec40593          	addi	a1,s0,-20
    80003064:	4501                	li	a0,0
    80003066:	00000097          	auipc	ra,0x0
    8000306a:	d44080e7          	jalr	-700(ra) # 80002daa <argint>
  exit(n);
    8000306e:	fec42503          	lw	a0,-20(s0)
    80003072:	fffff097          	auipc	ra,0xfffff
    80003076:	396080e7          	jalr	918(ra) # 80002408 <exit>
  return 0;  // not reached
}
    8000307a:	4501                	li	a0,0
    8000307c:	60e2                	ld	ra,24(sp)
    8000307e:	6442                	ld	s0,16(sp)
    80003080:	6105                	addi	sp,sp,32
    80003082:	8082                	ret

0000000080003084 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003084:	1141                	addi	sp,sp,-16
    80003086:	e406                	sd	ra,8(sp)
    80003088:	e022                	sd	s0,0(sp)
    8000308a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000308c:	fffff097          	auipc	ra,0xfffff
    80003090:	93a080e7          	jalr	-1734(ra) # 800019c6 <myproc>
}
    80003094:	5908                	lw	a0,48(a0)
    80003096:	60a2                	ld	ra,8(sp)
    80003098:	6402                	ld	s0,0(sp)
    8000309a:	0141                	addi	sp,sp,16
    8000309c:	8082                	ret

000000008000309e <sys_fork>:

uint64
sys_fork(void)
{
    8000309e:	1141                	addi	sp,sp,-16
    800030a0:	e406                	sd	ra,8(sp)
    800030a2:	e022                	sd	s0,0(sp)
    800030a4:	0800                	addi	s0,sp,16
  return fork();
    800030a6:	fffff097          	auipc	ra,0xfffff
    800030aa:	d18080e7          	jalr	-744(ra) # 80001dbe <fork>
}
    800030ae:	60a2                	ld	ra,8(sp)
    800030b0:	6402                	ld	s0,0(sp)
    800030b2:	0141                	addi	sp,sp,16
    800030b4:	8082                	ret

00000000800030b6 <sys_wait>:

uint64
sys_wait(void)
{
    800030b6:	1101                	addi	sp,sp,-32
    800030b8:	ec06                	sd	ra,24(sp)
    800030ba:	e822                	sd	s0,16(sp)
    800030bc:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800030be:	fe840593          	addi	a1,s0,-24
    800030c2:	4501                	li	a0,0
    800030c4:	00000097          	auipc	ra,0x0
    800030c8:	d08080e7          	jalr	-760(ra) # 80002dcc <argaddr>
  return wait(p);
    800030cc:	fe843503          	ld	a0,-24(s0)
    800030d0:	fffff097          	auipc	ra,0xfffff
    800030d4:	4ea080e7          	jalr	1258(ra) # 800025ba <wait>
}
    800030d8:	60e2                	ld	ra,24(sp)
    800030da:	6442                	ld	s0,16(sp)
    800030dc:	6105                	addi	sp,sp,32
    800030de:	8082                	ret

00000000800030e0 <sys_waitx>:

uint64
sys_waitx(void)
{
    800030e0:	7139                	addi	sp,sp,-64
    800030e2:	fc06                	sd	ra,56(sp)
    800030e4:	f822                	sd	s0,48(sp)
    800030e6:	f426                	sd	s1,40(sp)
    800030e8:	f04a                	sd	s2,32(sp)
    800030ea:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    800030ec:	fd840593          	addi	a1,s0,-40
    800030f0:	4501                	li	a0,0
    800030f2:	00000097          	auipc	ra,0x0
    800030f6:	cda080e7          	jalr	-806(ra) # 80002dcc <argaddr>
  argaddr(1, &addr1); // user virtual memory
    800030fa:	fd040593          	addi	a1,s0,-48
    800030fe:	4505                	li	a0,1
    80003100:	00000097          	auipc	ra,0x0
    80003104:	ccc080e7          	jalr	-820(ra) # 80002dcc <argaddr>
  argaddr(2, &addr2);
    80003108:	fc840593          	addi	a1,s0,-56
    8000310c:	4509                	li	a0,2
    8000310e:	00000097          	auipc	ra,0x0
    80003112:	cbe080e7          	jalr	-834(ra) # 80002dcc <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    80003116:	fc040613          	addi	a2,s0,-64
    8000311a:	fc440593          	addi	a1,s0,-60
    8000311e:	fd843503          	ld	a0,-40(s0)
    80003122:	fffff097          	auipc	ra,0xfffff
    80003126:	0ca080e7          	jalr	202(ra) # 800021ec <waitx>
    8000312a:	892a                	mv	s2,a0
  struct proc* p = myproc();
    8000312c:	fffff097          	auipc	ra,0xfffff
    80003130:	89a080e7          	jalr	-1894(ra) # 800019c6 <myproc>
    80003134:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    80003136:	4691                	li	a3,4
    80003138:	fc440613          	addi	a2,s0,-60
    8000313c:	fd043583          	ld	a1,-48(s0)
    80003140:	6928                	ld	a0,80(a0)
    80003142:	ffffe097          	auipc	ra,0xffffe
    80003146:	542080e7          	jalr	1346(ra) # 80001684 <copyout>
    return -1;
    8000314a:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    8000314c:	00054f63          	bltz	a0,8000316a <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2,(char*)&rtime, sizeof(int)) < 0)
    80003150:	4691                	li	a3,4
    80003152:	fc040613          	addi	a2,s0,-64
    80003156:	fc843583          	ld	a1,-56(s0)
    8000315a:	68a8                	ld	a0,80(s1)
    8000315c:	ffffe097          	auipc	ra,0xffffe
    80003160:	528080e7          	jalr	1320(ra) # 80001684 <copyout>
    80003164:	00054a63          	bltz	a0,80003178 <sys_waitx+0x98>
    return -1;
  return ret;
    80003168:	87ca                	mv	a5,s2
}
    8000316a:	853e                	mv	a0,a5
    8000316c:	70e2                	ld	ra,56(sp)
    8000316e:	7442                	ld	s0,48(sp)
    80003170:	74a2                	ld	s1,40(sp)
    80003172:	7902                	ld	s2,32(sp)
    80003174:	6121                	addi	sp,sp,64
    80003176:	8082                	ret
    return -1;
    80003178:	57fd                	li	a5,-1
    8000317a:	bfc5                	j	8000316a <sys_waitx+0x8a>

000000008000317c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000317c:	7179                	addi	sp,sp,-48
    8000317e:	f406                	sd	ra,40(sp)
    80003180:	f022                	sd	s0,32(sp)
    80003182:	ec26                	sd	s1,24(sp)
    80003184:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80003186:	fdc40593          	addi	a1,s0,-36
    8000318a:	4501                	li	a0,0
    8000318c:	00000097          	auipc	ra,0x0
    80003190:	c1e080e7          	jalr	-994(ra) # 80002daa <argint>
  addr = myproc()->sz;
    80003194:	fffff097          	auipc	ra,0xfffff
    80003198:	832080e7          	jalr	-1998(ra) # 800019c6 <myproc>
    8000319c:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    8000319e:	fdc42503          	lw	a0,-36(s0)
    800031a2:	fffff097          	auipc	ra,0xfffff
    800031a6:	bc0080e7          	jalr	-1088(ra) # 80001d62 <growproc>
    800031aa:	00054863          	bltz	a0,800031ba <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    800031ae:	8526                	mv	a0,s1
    800031b0:	70a2                	ld	ra,40(sp)
    800031b2:	7402                	ld	s0,32(sp)
    800031b4:	64e2                	ld	s1,24(sp)
    800031b6:	6145                	addi	sp,sp,48
    800031b8:	8082                	ret
    return -1;
    800031ba:	54fd                	li	s1,-1
    800031bc:	bfcd                	j	800031ae <sys_sbrk+0x32>

00000000800031be <sys_sleep>:

uint64
sys_sleep(void)
{
    800031be:	7139                	addi	sp,sp,-64
    800031c0:	fc06                	sd	ra,56(sp)
    800031c2:	f822                	sd	s0,48(sp)
    800031c4:	f426                	sd	s1,40(sp)
    800031c6:	f04a                	sd	s2,32(sp)
    800031c8:	ec4e                	sd	s3,24(sp)
    800031ca:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800031cc:	fcc40593          	addi	a1,s0,-52
    800031d0:	4501                	li	a0,0
    800031d2:	00000097          	auipc	ra,0x0
    800031d6:	bd8080e7          	jalr	-1064(ra) # 80002daa <argint>
  acquire(&tickslock);
    800031da:	00015517          	auipc	a0,0x15
    800031de:	df650513          	addi	a0,a0,-522 # 80017fd0 <tickslock>
    800031e2:	ffffe097          	auipc	ra,0xffffe
    800031e6:	a08080e7          	jalr	-1528(ra) # 80000bea <acquire>
  ticks0 = ticks;
    800031ea:	00006917          	auipc	s2,0x6
    800031ee:	94692903          	lw	s2,-1722(s2) # 80008b30 <ticks>
  while(ticks - ticks0 < n){
    800031f2:	fcc42783          	lw	a5,-52(s0)
    800031f6:	cf9d                	beqz	a5,80003234 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800031f8:	00015997          	auipc	s3,0x15
    800031fc:	dd898993          	addi	s3,s3,-552 # 80017fd0 <tickslock>
    80003200:	00006497          	auipc	s1,0x6
    80003204:	93048493          	addi	s1,s1,-1744 # 80008b30 <ticks>
    if(killed(myproc())){
    80003208:	ffffe097          	auipc	ra,0xffffe
    8000320c:	7be080e7          	jalr	1982(ra) # 800019c6 <myproc>
    80003210:	fffff097          	auipc	ra,0xfffff
    80003214:	378080e7          	jalr	888(ra) # 80002588 <killed>
    80003218:	ed15                	bnez	a0,80003254 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    8000321a:	85ce                	mv	a1,s3
    8000321c:	8526                	mv	a0,s1
    8000321e:	fffff097          	auipc	ra,0xfffff
    80003222:	f6a080e7          	jalr	-150(ra) # 80002188 <sleep>
  while(ticks - ticks0 < n){
    80003226:	409c                	lw	a5,0(s1)
    80003228:	412787bb          	subw	a5,a5,s2
    8000322c:	fcc42703          	lw	a4,-52(s0)
    80003230:	fce7ece3          	bltu	a5,a4,80003208 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80003234:	00015517          	auipc	a0,0x15
    80003238:	d9c50513          	addi	a0,a0,-612 # 80017fd0 <tickslock>
    8000323c:	ffffe097          	auipc	ra,0xffffe
    80003240:	a62080e7          	jalr	-1438(ra) # 80000c9e <release>
  return 0;
    80003244:	4501                	li	a0,0
}
    80003246:	70e2                	ld	ra,56(sp)
    80003248:	7442                	ld	s0,48(sp)
    8000324a:	74a2                	ld	s1,40(sp)
    8000324c:	7902                	ld	s2,32(sp)
    8000324e:	69e2                	ld	s3,24(sp)
    80003250:	6121                	addi	sp,sp,64
    80003252:	8082                	ret
      release(&tickslock);
    80003254:	00015517          	auipc	a0,0x15
    80003258:	d7c50513          	addi	a0,a0,-644 # 80017fd0 <tickslock>
    8000325c:	ffffe097          	auipc	ra,0xffffe
    80003260:	a42080e7          	jalr	-1470(ra) # 80000c9e <release>
      return -1;
    80003264:	557d                	li	a0,-1
    80003266:	b7c5                	j	80003246 <sys_sleep+0x88>

0000000080003268 <sys_kill>:

uint64
sys_kill(void)
{
    80003268:	1101                	addi	sp,sp,-32
    8000326a:	ec06                	sd	ra,24(sp)
    8000326c:	e822                	sd	s0,16(sp)
    8000326e:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003270:	fec40593          	addi	a1,s0,-20
    80003274:	4501                	li	a0,0
    80003276:	00000097          	auipc	ra,0x0
    8000327a:	b34080e7          	jalr	-1228(ra) # 80002daa <argint>
  return kill(pid);
    8000327e:	fec42503          	lw	a0,-20(s0)
    80003282:	fffff097          	auipc	ra,0xfffff
    80003286:	268080e7          	jalr	616(ra) # 800024ea <kill>
}
    8000328a:	60e2                	ld	ra,24(sp)
    8000328c:	6442                	ld	s0,16(sp)
    8000328e:	6105                	addi	sp,sp,32
    80003290:	8082                	ret

0000000080003292 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003292:	1101                	addi	sp,sp,-32
    80003294:	ec06                	sd	ra,24(sp)
    80003296:	e822                	sd	s0,16(sp)
    80003298:	e426                	sd	s1,8(sp)
    8000329a:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000329c:	00015517          	auipc	a0,0x15
    800032a0:	d3450513          	addi	a0,a0,-716 # 80017fd0 <tickslock>
    800032a4:	ffffe097          	auipc	ra,0xffffe
    800032a8:	946080e7          	jalr	-1722(ra) # 80000bea <acquire>
  xticks = ticks;
    800032ac:	00006497          	auipc	s1,0x6
    800032b0:	8844a483          	lw	s1,-1916(s1) # 80008b30 <ticks>
  release(&tickslock);
    800032b4:	00015517          	auipc	a0,0x15
    800032b8:	d1c50513          	addi	a0,a0,-740 # 80017fd0 <tickslock>
    800032bc:	ffffe097          	auipc	ra,0xffffe
    800032c0:	9e2080e7          	jalr	-1566(ra) # 80000c9e <release>
  return xticks;
}
    800032c4:	02049513          	slli	a0,s1,0x20
    800032c8:	9101                	srli	a0,a0,0x20
    800032ca:	60e2                	ld	ra,24(sp)
    800032cc:	6442                	ld	s0,16(sp)
    800032ce:	64a2                	ld	s1,8(sp)
    800032d0:	6105                	addi	sp,sp,32
    800032d2:	8082                	ret

00000000800032d4 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800032d4:	7179                	addi	sp,sp,-48
    800032d6:	f406                	sd	ra,40(sp)
    800032d8:	f022                	sd	s0,32(sp)
    800032da:	ec26                	sd	s1,24(sp)
    800032dc:	e84a                	sd	s2,16(sp)
    800032de:	e44e                	sd	s3,8(sp)
    800032e0:	e052                	sd	s4,0(sp)
    800032e2:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800032e4:	00005597          	auipc	a1,0x5
    800032e8:	3c458593          	addi	a1,a1,964 # 800086a8 <syscallnum+0x70>
    800032ec:	00015517          	auipc	a0,0x15
    800032f0:	cfc50513          	addi	a0,a0,-772 # 80017fe8 <bcache>
    800032f4:	ffffe097          	auipc	ra,0xffffe
    800032f8:	866080e7          	jalr	-1946(ra) # 80000b5a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800032fc:	0001d797          	auipc	a5,0x1d
    80003300:	cec78793          	addi	a5,a5,-788 # 8001ffe8 <bcache+0x8000>
    80003304:	0001d717          	auipc	a4,0x1d
    80003308:	f4c70713          	addi	a4,a4,-180 # 80020250 <bcache+0x8268>
    8000330c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003310:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003314:	00015497          	auipc	s1,0x15
    80003318:	cec48493          	addi	s1,s1,-788 # 80018000 <bcache+0x18>
    b->next = bcache.head.next;
    8000331c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000331e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003320:	00005a17          	auipc	s4,0x5
    80003324:	390a0a13          	addi	s4,s4,912 # 800086b0 <syscallnum+0x78>
    b->next = bcache.head.next;
    80003328:	2b893783          	ld	a5,696(s2)
    8000332c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000332e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003332:	85d2                	mv	a1,s4
    80003334:	01048513          	addi	a0,s1,16
    80003338:	00001097          	auipc	ra,0x1
    8000333c:	4c4080e7          	jalr	1220(ra) # 800047fc <initsleeplock>
    bcache.head.next->prev = b;
    80003340:	2b893783          	ld	a5,696(s2)
    80003344:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003346:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000334a:	45848493          	addi	s1,s1,1112
    8000334e:	fd349de3          	bne	s1,s3,80003328 <binit+0x54>
  }
}
    80003352:	70a2                	ld	ra,40(sp)
    80003354:	7402                	ld	s0,32(sp)
    80003356:	64e2                	ld	s1,24(sp)
    80003358:	6942                	ld	s2,16(sp)
    8000335a:	69a2                	ld	s3,8(sp)
    8000335c:	6a02                	ld	s4,0(sp)
    8000335e:	6145                	addi	sp,sp,48
    80003360:	8082                	ret

0000000080003362 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003362:	7179                	addi	sp,sp,-48
    80003364:	f406                	sd	ra,40(sp)
    80003366:	f022                	sd	s0,32(sp)
    80003368:	ec26                	sd	s1,24(sp)
    8000336a:	e84a                	sd	s2,16(sp)
    8000336c:	e44e                	sd	s3,8(sp)
    8000336e:	1800                	addi	s0,sp,48
    80003370:	89aa                	mv	s3,a0
    80003372:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80003374:	00015517          	auipc	a0,0x15
    80003378:	c7450513          	addi	a0,a0,-908 # 80017fe8 <bcache>
    8000337c:	ffffe097          	auipc	ra,0xffffe
    80003380:	86e080e7          	jalr	-1938(ra) # 80000bea <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003384:	0001d497          	auipc	s1,0x1d
    80003388:	f1c4b483          	ld	s1,-228(s1) # 800202a0 <bcache+0x82b8>
    8000338c:	0001d797          	auipc	a5,0x1d
    80003390:	ec478793          	addi	a5,a5,-316 # 80020250 <bcache+0x8268>
    80003394:	02f48f63          	beq	s1,a5,800033d2 <bread+0x70>
    80003398:	873e                	mv	a4,a5
    8000339a:	a021                	j	800033a2 <bread+0x40>
    8000339c:	68a4                	ld	s1,80(s1)
    8000339e:	02e48a63          	beq	s1,a4,800033d2 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800033a2:	449c                	lw	a5,8(s1)
    800033a4:	ff379ce3          	bne	a5,s3,8000339c <bread+0x3a>
    800033a8:	44dc                	lw	a5,12(s1)
    800033aa:	ff2799e3          	bne	a5,s2,8000339c <bread+0x3a>
      b->refcnt++;
    800033ae:	40bc                	lw	a5,64(s1)
    800033b0:	2785                	addiw	a5,a5,1
    800033b2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800033b4:	00015517          	auipc	a0,0x15
    800033b8:	c3450513          	addi	a0,a0,-972 # 80017fe8 <bcache>
    800033bc:	ffffe097          	auipc	ra,0xffffe
    800033c0:	8e2080e7          	jalr	-1822(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    800033c4:	01048513          	addi	a0,s1,16
    800033c8:	00001097          	auipc	ra,0x1
    800033cc:	46e080e7          	jalr	1134(ra) # 80004836 <acquiresleep>
      return b;
    800033d0:	a8b9                	j	8000342e <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800033d2:	0001d497          	auipc	s1,0x1d
    800033d6:	ec64b483          	ld	s1,-314(s1) # 80020298 <bcache+0x82b0>
    800033da:	0001d797          	auipc	a5,0x1d
    800033de:	e7678793          	addi	a5,a5,-394 # 80020250 <bcache+0x8268>
    800033e2:	00f48863          	beq	s1,a5,800033f2 <bread+0x90>
    800033e6:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800033e8:	40bc                	lw	a5,64(s1)
    800033ea:	cf81                	beqz	a5,80003402 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800033ec:	64a4                	ld	s1,72(s1)
    800033ee:	fee49de3          	bne	s1,a4,800033e8 <bread+0x86>
  panic("bget: no buffers");
    800033f2:	00005517          	auipc	a0,0x5
    800033f6:	2c650513          	addi	a0,a0,710 # 800086b8 <syscallnum+0x80>
    800033fa:	ffffd097          	auipc	ra,0xffffd
    800033fe:	14a080e7          	jalr	330(ra) # 80000544 <panic>
      b->dev = dev;
    80003402:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80003406:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    8000340a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000340e:	4785                	li	a5,1
    80003410:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003412:	00015517          	auipc	a0,0x15
    80003416:	bd650513          	addi	a0,a0,-1066 # 80017fe8 <bcache>
    8000341a:	ffffe097          	auipc	ra,0xffffe
    8000341e:	884080e7          	jalr	-1916(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    80003422:	01048513          	addi	a0,s1,16
    80003426:	00001097          	auipc	ra,0x1
    8000342a:	410080e7          	jalr	1040(ra) # 80004836 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000342e:	409c                	lw	a5,0(s1)
    80003430:	cb89                	beqz	a5,80003442 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003432:	8526                	mv	a0,s1
    80003434:	70a2                	ld	ra,40(sp)
    80003436:	7402                	ld	s0,32(sp)
    80003438:	64e2                	ld	s1,24(sp)
    8000343a:	6942                	ld	s2,16(sp)
    8000343c:	69a2                	ld	s3,8(sp)
    8000343e:	6145                	addi	sp,sp,48
    80003440:	8082                	ret
    virtio_disk_rw(b, 0);
    80003442:	4581                	li	a1,0
    80003444:	8526                	mv	a0,s1
    80003446:	00003097          	auipc	ra,0x3
    8000344a:	fd2080e7          	jalr	-46(ra) # 80006418 <virtio_disk_rw>
    b->valid = 1;
    8000344e:	4785                	li	a5,1
    80003450:	c09c                	sw	a5,0(s1)
  return b;
    80003452:	b7c5                	j	80003432 <bread+0xd0>

0000000080003454 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003454:	1101                	addi	sp,sp,-32
    80003456:	ec06                	sd	ra,24(sp)
    80003458:	e822                	sd	s0,16(sp)
    8000345a:	e426                	sd	s1,8(sp)
    8000345c:	1000                	addi	s0,sp,32
    8000345e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003460:	0541                	addi	a0,a0,16
    80003462:	00001097          	auipc	ra,0x1
    80003466:	46e080e7          	jalr	1134(ra) # 800048d0 <holdingsleep>
    8000346a:	cd01                	beqz	a0,80003482 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000346c:	4585                	li	a1,1
    8000346e:	8526                	mv	a0,s1
    80003470:	00003097          	auipc	ra,0x3
    80003474:	fa8080e7          	jalr	-88(ra) # 80006418 <virtio_disk_rw>
}
    80003478:	60e2                	ld	ra,24(sp)
    8000347a:	6442                	ld	s0,16(sp)
    8000347c:	64a2                	ld	s1,8(sp)
    8000347e:	6105                	addi	sp,sp,32
    80003480:	8082                	ret
    panic("bwrite");
    80003482:	00005517          	auipc	a0,0x5
    80003486:	24e50513          	addi	a0,a0,590 # 800086d0 <syscallnum+0x98>
    8000348a:	ffffd097          	auipc	ra,0xffffd
    8000348e:	0ba080e7          	jalr	186(ra) # 80000544 <panic>

0000000080003492 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003492:	1101                	addi	sp,sp,-32
    80003494:	ec06                	sd	ra,24(sp)
    80003496:	e822                	sd	s0,16(sp)
    80003498:	e426                	sd	s1,8(sp)
    8000349a:	e04a                	sd	s2,0(sp)
    8000349c:	1000                	addi	s0,sp,32
    8000349e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800034a0:	01050913          	addi	s2,a0,16
    800034a4:	854a                	mv	a0,s2
    800034a6:	00001097          	auipc	ra,0x1
    800034aa:	42a080e7          	jalr	1066(ra) # 800048d0 <holdingsleep>
    800034ae:	c92d                	beqz	a0,80003520 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800034b0:	854a                	mv	a0,s2
    800034b2:	00001097          	auipc	ra,0x1
    800034b6:	3da080e7          	jalr	986(ra) # 8000488c <releasesleep>

  acquire(&bcache.lock);
    800034ba:	00015517          	auipc	a0,0x15
    800034be:	b2e50513          	addi	a0,a0,-1234 # 80017fe8 <bcache>
    800034c2:	ffffd097          	auipc	ra,0xffffd
    800034c6:	728080e7          	jalr	1832(ra) # 80000bea <acquire>
  b->refcnt--;
    800034ca:	40bc                	lw	a5,64(s1)
    800034cc:	37fd                	addiw	a5,a5,-1
    800034ce:	0007871b          	sext.w	a4,a5
    800034d2:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800034d4:	eb05                	bnez	a4,80003504 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800034d6:	68bc                	ld	a5,80(s1)
    800034d8:	64b8                	ld	a4,72(s1)
    800034da:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800034dc:	64bc                	ld	a5,72(s1)
    800034de:	68b8                	ld	a4,80(s1)
    800034e0:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800034e2:	0001d797          	auipc	a5,0x1d
    800034e6:	b0678793          	addi	a5,a5,-1274 # 8001ffe8 <bcache+0x8000>
    800034ea:	2b87b703          	ld	a4,696(a5)
    800034ee:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800034f0:	0001d717          	auipc	a4,0x1d
    800034f4:	d6070713          	addi	a4,a4,-672 # 80020250 <bcache+0x8268>
    800034f8:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800034fa:	2b87b703          	ld	a4,696(a5)
    800034fe:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003500:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003504:	00015517          	auipc	a0,0x15
    80003508:	ae450513          	addi	a0,a0,-1308 # 80017fe8 <bcache>
    8000350c:	ffffd097          	auipc	ra,0xffffd
    80003510:	792080e7          	jalr	1938(ra) # 80000c9e <release>
}
    80003514:	60e2                	ld	ra,24(sp)
    80003516:	6442                	ld	s0,16(sp)
    80003518:	64a2                	ld	s1,8(sp)
    8000351a:	6902                	ld	s2,0(sp)
    8000351c:	6105                	addi	sp,sp,32
    8000351e:	8082                	ret
    panic("brelse");
    80003520:	00005517          	auipc	a0,0x5
    80003524:	1b850513          	addi	a0,a0,440 # 800086d8 <syscallnum+0xa0>
    80003528:	ffffd097          	auipc	ra,0xffffd
    8000352c:	01c080e7          	jalr	28(ra) # 80000544 <panic>

0000000080003530 <bpin>:

void
bpin(struct buf *b) {
    80003530:	1101                	addi	sp,sp,-32
    80003532:	ec06                	sd	ra,24(sp)
    80003534:	e822                	sd	s0,16(sp)
    80003536:	e426                	sd	s1,8(sp)
    80003538:	1000                	addi	s0,sp,32
    8000353a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000353c:	00015517          	auipc	a0,0x15
    80003540:	aac50513          	addi	a0,a0,-1364 # 80017fe8 <bcache>
    80003544:	ffffd097          	auipc	ra,0xffffd
    80003548:	6a6080e7          	jalr	1702(ra) # 80000bea <acquire>
  b->refcnt++;
    8000354c:	40bc                	lw	a5,64(s1)
    8000354e:	2785                	addiw	a5,a5,1
    80003550:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003552:	00015517          	auipc	a0,0x15
    80003556:	a9650513          	addi	a0,a0,-1386 # 80017fe8 <bcache>
    8000355a:	ffffd097          	auipc	ra,0xffffd
    8000355e:	744080e7          	jalr	1860(ra) # 80000c9e <release>
}
    80003562:	60e2                	ld	ra,24(sp)
    80003564:	6442                	ld	s0,16(sp)
    80003566:	64a2                	ld	s1,8(sp)
    80003568:	6105                	addi	sp,sp,32
    8000356a:	8082                	ret

000000008000356c <bunpin>:

void
bunpin(struct buf *b) {
    8000356c:	1101                	addi	sp,sp,-32
    8000356e:	ec06                	sd	ra,24(sp)
    80003570:	e822                	sd	s0,16(sp)
    80003572:	e426                	sd	s1,8(sp)
    80003574:	1000                	addi	s0,sp,32
    80003576:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003578:	00015517          	auipc	a0,0x15
    8000357c:	a7050513          	addi	a0,a0,-1424 # 80017fe8 <bcache>
    80003580:	ffffd097          	auipc	ra,0xffffd
    80003584:	66a080e7          	jalr	1642(ra) # 80000bea <acquire>
  b->refcnt--;
    80003588:	40bc                	lw	a5,64(s1)
    8000358a:	37fd                	addiw	a5,a5,-1
    8000358c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000358e:	00015517          	auipc	a0,0x15
    80003592:	a5a50513          	addi	a0,a0,-1446 # 80017fe8 <bcache>
    80003596:	ffffd097          	auipc	ra,0xffffd
    8000359a:	708080e7          	jalr	1800(ra) # 80000c9e <release>
}
    8000359e:	60e2                	ld	ra,24(sp)
    800035a0:	6442                	ld	s0,16(sp)
    800035a2:	64a2                	ld	s1,8(sp)
    800035a4:	6105                	addi	sp,sp,32
    800035a6:	8082                	ret

00000000800035a8 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800035a8:	1101                	addi	sp,sp,-32
    800035aa:	ec06                	sd	ra,24(sp)
    800035ac:	e822                	sd	s0,16(sp)
    800035ae:	e426                	sd	s1,8(sp)
    800035b0:	e04a                	sd	s2,0(sp)
    800035b2:	1000                	addi	s0,sp,32
    800035b4:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800035b6:	00d5d59b          	srliw	a1,a1,0xd
    800035ba:	0001d797          	auipc	a5,0x1d
    800035be:	10a7a783          	lw	a5,266(a5) # 800206c4 <sb+0x1c>
    800035c2:	9dbd                	addw	a1,a1,a5
    800035c4:	00000097          	auipc	ra,0x0
    800035c8:	d9e080e7          	jalr	-610(ra) # 80003362 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800035cc:	0074f713          	andi	a4,s1,7
    800035d0:	4785                	li	a5,1
    800035d2:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800035d6:	14ce                	slli	s1,s1,0x33
    800035d8:	90d9                	srli	s1,s1,0x36
    800035da:	00950733          	add	a4,a0,s1
    800035de:	05874703          	lbu	a4,88(a4)
    800035e2:	00e7f6b3          	and	a3,a5,a4
    800035e6:	c69d                	beqz	a3,80003614 <bfree+0x6c>
    800035e8:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800035ea:	94aa                	add	s1,s1,a0
    800035ec:	fff7c793          	not	a5,a5
    800035f0:	8ff9                	and	a5,a5,a4
    800035f2:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800035f6:	00001097          	auipc	ra,0x1
    800035fa:	120080e7          	jalr	288(ra) # 80004716 <log_write>
  brelse(bp);
    800035fe:	854a                	mv	a0,s2
    80003600:	00000097          	auipc	ra,0x0
    80003604:	e92080e7          	jalr	-366(ra) # 80003492 <brelse>
}
    80003608:	60e2                	ld	ra,24(sp)
    8000360a:	6442                	ld	s0,16(sp)
    8000360c:	64a2                	ld	s1,8(sp)
    8000360e:	6902                	ld	s2,0(sp)
    80003610:	6105                	addi	sp,sp,32
    80003612:	8082                	ret
    panic("freeing free block");
    80003614:	00005517          	auipc	a0,0x5
    80003618:	0cc50513          	addi	a0,a0,204 # 800086e0 <syscallnum+0xa8>
    8000361c:	ffffd097          	auipc	ra,0xffffd
    80003620:	f28080e7          	jalr	-216(ra) # 80000544 <panic>

0000000080003624 <balloc>:
{
    80003624:	711d                	addi	sp,sp,-96
    80003626:	ec86                	sd	ra,88(sp)
    80003628:	e8a2                	sd	s0,80(sp)
    8000362a:	e4a6                	sd	s1,72(sp)
    8000362c:	e0ca                	sd	s2,64(sp)
    8000362e:	fc4e                	sd	s3,56(sp)
    80003630:	f852                	sd	s4,48(sp)
    80003632:	f456                	sd	s5,40(sp)
    80003634:	f05a                	sd	s6,32(sp)
    80003636:	ec5e                	sd	s7,24(sp)
    80003638:	e862                	sd	s8,16(sp)
    8000363a:	e466                	sd	s9,8(sp)
    8000363c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000363e:	0001d797          	auipc	a5,0x1d
    80003642:	06e7a783          	lw	a5,110(a5) # 800206ac <sb+0x4>
    80003646:	10078163          	beqz	a5,80003748 <balloc+0x124>
    8000364a:	8baa                	mv	s7,a0
    8000364c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000364e:	0001db17          	auipc	s6,0x1d
    80003652:	05ab0b13          	addi	s6,s6,90 # 800206a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003656:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003658:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000365a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000365c:	6c89                	lui	s9,0x2
    8000365e:	a061                	j	800036e6 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003660:	974a                	add	a4,a4,s2
    80003662:	8fd5                	or	a5,a5,a3
    80003664:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003668:	854a                	mv	a0,s2
    8000366a:	00001097          	auipc	ra,0x1
    8000366e:	0ac080e7          	jalr	172(ra) # 80004716 <log_write>
        brelse(bp);
    80003672:	854a                	mv	a0,s2
    80003674:	00000097          	auipc	ra,0x0
    80003678:	e1e080e7          	jalr	-482(ra) # 80003492 <brelse>
  bp = bread(dev, bno);
    8000367c:	85a6                	mv	a1,s1
    8000367e:	855e                	mv	a0,s7
    80003680:	00000097          	auipc	ra,0x0
    80003684:	ce2080e7          	jalr	-798(ra) # 80003362 <bread>
    80003688:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000368a:	40000613          	li	a2,1024
    8000368e:	4581                	li	a1,0
    80003690:	05850513          	addi	a0,a0,88
    80003694:	ffffd097          	auipc	ra,0xffffd
    80003698:	652080e7          	jalr	1618(ra) # 80000ce6 <memset>
  log_write(bp);
    8000369c:	854a                	mv	a0,s2
    8000369e:	00001097          	auipc	ra,0x1
    800036a2:	078080e7          	jalr	120(ra) # 80004716 <log_write>
  brelse(bp);
    800036a6:	854a                	mv	a0,s2
    800036a8:	00000097          	auipc	ra,0x0
    800036ac:	dea080e7          	jalr	-534(ra) # 80003492 <brelse>
}
    800036b0:	8526                	mv	a0,s1
    800036b2:	60e6                	ld	ra,88(sp)
    800036b4:	6446                	ld	s0,80(sp)
    800036b6:	64a6                	ld	s1,72(sp)
    800036b8:	6906                	ld	s2,64(sp)
    800036ba:	79e2                	ld	s3,56(sp)
    800036bc:	7a42                	ld	s4,48(sp)
    800036be:	7aa2                	ld	s5,40(sp)
    800036c0:	7b02                	ld	s6,32(sp)
    800036c2:	6be2                	ld	s7,24(sp)
    800036c4:	6c42                	ld	s8,16(sp)
    800036c6:	6ca2                	ld	s9,8(sp)
    800036c8:	6125                	addi	sp,sp,96
    800036ca:	8082                	ret
    brelse(bp);
    800036cc:	854a                	mv	a0,s2
    800036ce:	00000097          	auipc	ra,0x0
    800036d2:	dc4080e7          	jalr	-572(ra) # 80003492 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800036d6:	015c87bb          	addw	a5,s9,s5
    800036da:	00078a9b          	sext.w	s5,a5
    800036de:	004b2703          	lw	a4,4(s6)
    800036e2:	06eaf363          	bgeu	s5,a4,80003748 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    800036e6:	41fad79b          	sraiw	a5,s5,0x1f
    800036ea:	0137d79b          	srliw	a5,a5,0x13
    800036ee:	015787bb          	addw	a5,a5,s5
    800036f2:	40d7d79b          	sraiw	a5,a5,0xd
    800036f6:	01cb2583          	lw	a1,28(s6)
    800036fa:	9dbd                	addw	a1,a1,a5
    800036fc:	855e                	mv	a0,s7
    800036fe:	00000097          	auipc	ra,0x0
    80003702:	c64080e7          	jalr	-924(ra) # 80003362 <bread>
    80003706:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003708:	004b2503          	lw	a0,4(s6)
    8000370c:	000a849b          	sext.w	s1,s5
    80003710:	8662                	mv	a2,s8
    80003712:	faa4fde3          	bgeu	s1,a0,800036cc <balloc+0xa8>
      m = 1 << (bi % 8);
    80003716:	41f6579b          	sraiw	a5,a2,0x1f
    8000371a:	01d7d69b          	srliw	a3,a5,0x1d
    8000371e:	00c6873b          	addw	a4,a3,a2
    80003722:	00777793          	andi	a5,a4,7
    80003726:	9f95                	subw	a5,a5,a3
    80003728:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000372c:	4037571b          	sraiw	a4,a4,0x3
    80003730:	00e906b3          	add	a3,s2,a4
    80003734:	0586c683          	lbu	a3,88(a3)
    80003738:	00d7f5b3          	and	a1,a5,a3
    8000373c:	d195                	beqz	a1,80003660 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000373e:	2605                	addiw	a2,a2,1
    80003740:	2485                	addiw	s1,s1,1
    80003742:	fd4618e3          	bne	a2,s4,80003712 <balloc+0xee>
    80003746:	b759                	j	800036cc <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003748:	00005517          	auipc	a0,0x5
    8000374c:	fb050513          	addi	a0,a0,-80 # 800086f8 <syscallnum+0xc0>
    80003750:	ffffd097          	auipc	ra,0xffffd
    80003754:	e3e080e7          	jalr	-450(ra) # 8000058e <printf>
  return 0;
    80003758:	4481                	li	s1,0
    8000375a:	bf99                	j	800036b0 <balloc+0x8c>

000000008000375c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000375c:	7179                	addi	sp,sp,-48
    8000375e:	f406                	sd	ra,40(sp)
    80003760:	f022                	sd	s0,32(sp)
    80003762:	ec26                	sd	s1,24(sp)
    80003764:	e84a                	sd	s2,16(sp)
    80003766:	e44e                	sd	s3,8(sp)
    80003768:	e052                	sd	s4,0(sp)
    8000376a:	1800                	addi	s0,sp,48
    8000376c:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000376e:	47ad                	li	a5,11
    80003770:	02b7e763          	bltu	a5,a1,8000379e <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003774:	02059493          	slli	s1,a1,0x20
    80003778:	9081                	srli	s1,s1,0x20
    8000377a:	048a                	slli	s1,s1,0x2
    8000377c:	94aa                	add	s1,s1,a0
    8000377e:	0504a903          	lw	s2,80(s1)
    80003782:	06091e63          	bnez	s2,800037fe <bmap+0xa2>
      addr = balloc(ip->dev);
    80003786:	4108                	lw	a0,0(a0)
    80003788:	00000097          	auipc	ra,0x0
    8000378c:	e9c080e7          	jalr	-356(ra) # 80003624 <balloc>
    80003790:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003794:	06090563          	beqz	s2,800037fe <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003798:	0524a823          	sw	s2,80(s1)
    8000379c:	a08d                	j	800037fe <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000379e:	ff45849b          	addiw	s1,a1,-12
    800037a2:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800037a6:	0ff00793          	li	a5,255
    800037aa:	08e7e563          	bltu	a5,a4,80003834 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800037ae:	08052903          	lw	s2,128(a0)
    800037b2:	00091d63          	bnez	s2,800037cc <bmap+0x70>
      addr = balloc(ip->dev);
    800037b6:	4108                	lw	a0,0(a0)
    800037b8:	00000097          	auipc	ra,0x0
    800037bc:	e6c080e7          	jalr	-404(ra) # 80003624 <balloc>
    800037c0:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800037c4:	02090d63          	beqz	s2,800037fe <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800037c8:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800037cc:	85ca                	mv	a1,s2
    800037ce:	0009a503          	lw	a0,0(s3)
    800037d2:	00000097          	auipc	ra,0x0
    800037d6:	b90080e7          	jalr	-1136(ra) # 80003362 <bread>
    800037da:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800037dc:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800037e0:	02049593          	slli	a1,s1,0x20
    800037e4:	9181                	srli	a1,a1,0x20
    800037e6:	058a                	slli	a1,a1,0x2
    800037e8:	00b784b3          	add	s1,a5,a1
    800037ec:	0004a903          	lw	s2,0(s1)
    800037f0:	02090063          	beqz	s2,80003810 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800037f4:	8552                	mv	a0,s4
    800037f6:	00000097          	auipc	ra,0x0
    800037fa:	c9c080e7          	jalr	-868(ra) # 80003492 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800037fe:	854a                	mv	a0,s2
    80003800:	70a2                	ld	ra,40(sp)
    80003802:	7402                	ld	s0,32(sp)
    80003804:	64e2                	ld	s1,24(sp)
    80003806:	6942                	ld	s2,16(sp)
    80003808:	69a2                	ld	s3,8(sp)
    8000380a:	6a02                	ld	s4,0(sp)
    8000380c:	6145                	addi	sp,sp,48
    8000380e:	8082                	ret
      addr = balloc(ip->dev);
    80003810:	0009a503          	lw	a0,0(s3)
    80003814:	00000097          	auipc	ra,0x0
    80003818:	e10080e7          	jalr	-496(ra) # 80003624 <balloc>
    8000381c:	0005091b          	sext.w	s2,a0
      if(addr){
    80003820:	fc090ae3          	beqz	s2,800037f4 <bmap+0x98>
        a[bn] = addr;
    80003824:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003828:	8552                	mv	a0,s4
    8000382a:	00001097          	auipc	ra,0x1
    8000382e:	eec080e7          	jalr	-276(ra) # 80004716 <log_write>
    80003832:	b7c9                	j	800037f4 <bmap+0x98>
  panic("bmap: out of range");
    80003834:	00005517          	auipc	a0,0x5
    80003838:	edc50513          	addi	a0,a0,-292 # 80008710 <syscallnum+0xd8>
    8000383c:	ffffd097          	auipc	ra,0xffffd
    80003840:	d08080e7          	jalr	-760(ra) # 80000544 <panic>

0000000080003844 <iget>:
{
    80003844:	7179                	addi	sp,sp,-48
    80003846:	f406                	sd	ra,40(sp)
    80003848:	f022                	sd	s0,32(sp)
    8000384a:	ec26                	sd	s1,24(sp)
    8000384c:	e84a                	sd	s2,16(sp)
    8000384e:	e44e                	sd	s3,8(sp)
    80003850:	e052                	sd	s4,0(sp)
    80003852:	1800                	addi	s0,sp,48
    80003854:	89aa                	mv	s3,a0
    80003856:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003858:	0001d517          	auipc	a0,0x1d
    8000385c:	e7050513          	addi	a0,a0,-400 # 800206c8 <itable>
    80003860:	ffffd097          	auipc	ra,0xffffd
    80003864:	38a080e7          	jalr	906(ra) # 80000bea <acquire>
  empty = 0;
    80003868:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000386a:	0001d497          	auipc	s1,0x1d
    8000386e:	e7648493          	addi	s1,s1,-394 # 800206e0 <itable+0x18>
    80003872:	0001f697          	auipc	a3,0x1f
    80003876:	8fe68693          	addi	a3,a3,-1794 # 80022170 <log>
    8000387a:	a039                	j	80003888 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000387c:	02090b63          	beqz	s2,800038b2 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003880:	08848493          	addi	s1,s1,136
    80003884:	02d48a63          	beq	s1,a3,800038b8 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003888:	449c                	lw	a5,8(s1)
    8000388a:	fef059e3          	blez	a5,8000387c <iget+0x38>
    8000388e:	4098                	lw	a4,0(s1)
    80003890:	ff3716e3          	bne	a4,s3,8000387c <iget+0x38>
    80003894:	40d8                	lw	a4,4(s1)
    80003896:	ff4713e3          	bne	a4,s4,8000387c <iget+0x38>
      ip->ref++;
    8000389a:	2785                	addiw	a5,a5,1
    8000389c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000389e:	0001d517          	auipc	a0,0x1d
    800038a2:	e2a50513          	addi	a0,a0,-470 # 800206c8 <itable>
    800038a6:	ffffd097          	auipc	ra,0xffffd
    800038aa:	3f8080e7          	jalr	1016(ra) # 80000c9e <release>
      return ip;
    800038ae:	8926                	mv	s2,s1
    800038b0:	a03d                	j	800038de <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800038b2:	f7f9                	bnez	a5,80003880 <iget+0x3c>
    800038b4:	8926                	mv	s2,s1
    800038b6:	b7e9                	j	80003880 <iget+0x3c>
  if(empty == 0)
    800038b8:	02090c63          	beqz	s2,800038f0 <iget+0xac>
  ip->dev = dev;
    800038bc:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800038c0:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800038c4:	4785                	li	a5,1
    800038c6:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800038ca:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800038ce:	0001d517          	auipc	a0,0x1d
    800038d2:	dfa50513          	addi	a0,a0,-518 # 800206c8 <itable>
    800038d6:	ffffd097          	auipc	ra,0xffffd
    800038da:	3c8080e7          	jalr	968(ra) # 80000c9e <release>
}
    800038de:	854a                	mv	a0,s2
    800038e0:	70a2                	ld	ra,40(sp)
    800038e2:	7402                	ld	s0,32(sp)
    800038e4:	64e2                	ld	s1,24(sp)
    800038e6:	6942                	ld	s2,16(sp)
    800038e8:	69a2                	ld	s3,8(sp)
    800038ea:	6a02                	ld	s4,0(sp)
    800038ec:	6145                	addi	sp,sp,48
    800038ee:	8082                	ret
    panic("iget: no inodes");
    800038f0:	00005517          	auipc	a0,0x5
    800038f4:	e3850513          	addi	a0,a0,-456 # 80008728 <syscallnum+0xf0>
    800038f8:	ffffd097          	auipc	ra,0xffffd
    800038fc:	c4c080e7          	jalr	-948(ra) # 80000544 <panic>

0000000080003900 <fsinit>:
fsinit(int dev) {
    80003900:	7179                	addi	sp,sp,-48
    80003902:	f406                	sd	ra,40(sp)
    80003904:	f022                	sd	s0,32(sp)
    80003906:	ec26                	sd	s1,24(sp)
    80003908:	e84a                	sd	s2,16(sp)
    8000390a:	e44e                	sd	s3,8(sp)
    8000390c:	1800                	addi	s0,sp,48
    8000390e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003910:	4585                	li	a1,1
    80003912:	00000097          	auipc	ra,0x0
    80003916:	a50080e7          	jalr	-1456(ra) # 80003362 <bread>
    8000391a:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000391c:	0001d997          	auipc	s3,0x1d
    80003920:	d8c98993          	addi	s3,s3,-628 # 800206a8 <sb>
    80003924:	02000613          	li	a2,32
    80003928:	05850593          	addi	a1,a0,88
    8000392c:	854e                	mv	a0,s3
    8000392e:	ffffd097          	auipc	ra,0xffffd
    80003932:	418080e7          	jalr	1048(ra) # 80000d46 <memmove>
  brelse(bp);
    80003936:	8526                	mv	a0,s1
    80003938:	00000097          	auipc	ra,0x0
    8000393c:	b5a080e7          	jalr	-1190(ra) # 80003492 <brelse>
  if(sb.magic != FSMAGIC)
    80003940:	0009a703          	lw	a4,0(s3)
    80003944:	102037b7          	lui	a5,0x10203
    80003948:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000394c:	02f71263          	bne	a4,a5,80003970 <fsinit+0x70>
  initlog(dev, &sb);
    80003950:	0001d597          	auipc	a1,0x1d
    80003954:	d5858593          	addi	a1,a1,-680 # 800206a8 <sb>
    80003958:	854a                	mv	a0,s2
    8000395a:	00001097          	auipc	ra,0x1
    8000395e:	b40080e7          	jalr	-1216(ra) # 8000449a <initlog>
}
    80003962:	70a2                	ld	ra,40(sp)
    80003964:	7402                	ld	s0,32(sp)
    80003966:	64e2                	ld	s1,24(sp)
    80003968:	6942                	ld	s2,16(sp)
    8000396a:	69a2                	ld	s3,8(sp)
    8000396c:	6145                	addi	sp,sp,48
    8000396e:	8082                	ret
    panic("invalid file system");
    80003970:	00005517          	auipc	a0,0x5
    80003974:	dc850513          	addi	a0,a0,-568 # 80008738 <syscallnum+0x100>
    80003978:	ffffd097          	auipc	ra,0xffffd
    8000397c:	bcc080e7          	jalr	-1076(ra) # 80000544 <panic>

0000000080003980 <iinit>:
{
    80003980:	7179                	addi	sp,sp,-48
    80003982:	f406                	sd	ra,40(sp)
    80003984:	f022                	sd	s0,32(sp)
    80003986:	ec26                	sd	s1,24(sp)
    80003988:	e84a                	sd	s2,16(sp)
    8000398a:	e44e                	sd	s3,8(sp)
    8000398c:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000398e:	00005597          	auipc	a1,0x5
    80003992:	dc258593          	addi	a1,a1,-574 # 80008750 <syscallnum+0x118>
    80003996:	0001d517          	auipc	a0,0x1d
    8000399a:	d3250513          	addi	a0,a0,-718 # 800206c8 <itable>
    8000399e:	ffffd097          	auipc	ra,0xffffd
    800039a2:	1bc080e7          	jalr	444(ra) # 80000b5a <initlock>
  for(i = 0; i < NINODE; i++) {
    800039a6:	0001d497          	auipc	s1,0x1d
    800039aa:	d4a48493          	addi	s1,s1,-694 # 800206f0 <itable+0x28>
    800039ae:	0001e997          	auipc	s3,0x1e
    800039b2:	7d298993          	addi	s3,s3,2002 # 80022180 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800039b6:	00005917          	auipc	s2,0x5
    800039ba:	da290913          	addi	s2,s2,-606 # 80008758 <syscallnum+0x120>
    800039be:	85ca                	mv	a1,s2
    800039c0:	8526                	mv	a0,s1
    800039c2:	00001097          	auipc	ra,0x1
    800039c6:	e3a080e7          	jalr	-454(ra) # 800047fc <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800039ca:	08848493          	addi	s1,s1,136
    800039ce:	ff3498e3          	bne	s1,s3,800039be <iinit+0x3e>
}
    800039d2:	70a2                	ld	ra,40(sp)
    800039d4:	7402                	ld	s0,32(sp)
    800039d6:	64e2                	ld	s1,24(sp)
    800039d8:	6942                	ld	s2,16(sp)
    800039da:	69a2                	ld	s3,8(sp)
    800039dc:	6145                	addi	sp,sp,48
    800039de:	8082                	ret

00000000800039e0 <ialloc>:
{
    800039e0:	715d                	addi	sp,sp,-80
    800039e2:	e486                	sd	ra,72(sp)
    800039e4:	e0a2                	sd	s0,64(sp)
    800039e6:	fc26                	sd	s1,56(sp)
    800039e8:	f84a                	sd	s2,48(sp)
    800039ea:	f44e                	sd	s3,40(sp)
    800039ec:	f052                	sd	s4,32(sp)
    800039ee:	ec56                	sd	s5,24(sp)
    800039f0:	e85a                	sd	s6,16(sp)
    800039f2:	e45e                	sd	s7,8(sp)
    800039f4:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800039f6:	0001d717          	auipc	a4,0x1d
    800039fa:	cbe72703          	lw	a4,-834(a4) # 800206b4 <sb+0xc>
    800039fe:	4785                	li	a5,1
    80003a00:	04e7fa63          	bgeu	a5,a4,80003a54 <ialloc+0x74>
    80003a04:	8aaa                	mv	s5,a0
    80003a06:	8bae                	mv	s7,a1
    80003a08:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003a0a:	0001da17          	auipc	s4,0x1d
    80003a0e:	c9ea0a13          	addi	s4,s4,-866 # 800206a8 <sb>
    80003a12:	00048b1b          	sext.w	s6,s1
    80003a16:	0044d593          	srli	a1,s1,0x4
    80003a1a:	018a2783          	lw	a5,24(s4)
    80003a1e:	9dbd                	addw	a1,a1,a5
    80003a20:	8556                	mv	a0,s5
    80003a22:	00000097          	auipc	ra,0x0
    80003a26:	940080e7          	jalr	-1728(ra) # 80003362 <bread>
    80003a2a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003a2c:	05850993          	addi	s3,a0,88
    80003a30:	00f4f793          	andi	a5,s1,15
    80003a34:	079a                	slli	a5,a5,0x6
    80003a36:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003a38:	00099783          	lh	a5,0(s3)
    80003a3c:	c3a1                	beqz	a5,80003a7c <ialloc+0x9c>
    brelse(bp);
    80003a3e:	00000097          	auipc	ra,0x0
    80003a42:	a54080e7          	jalr	-1452(ra) # 80003492 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a46:	0485                	addi	s1,s1,1
    80003a48:	00ca2703          	lw	a4,12(s4)
    80003a4c:	0004879b          	sext.w	a5,s1
    80003a50:	fce7e1e3          	bltu	a5,a4,80003a12 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003a54:	00005517          	auipc	a0,0x5
    80003a58:	d0c50513          	addi	a0,a0,-756 # 80008760 <syscallnum+0x128>
    80003a5c:	ffffd097          	auipc	ra,0xffffd
    80003a60:	b32080e7          	jalr	-1230(ra) # 8000058e <printf>
  return 0;
    80003a64:	4501                	li	a0,0
}
    80003a66:	60a6                	ld	ra,72(sp)
    80003a68:	6406                	ld	s0,64(sp)
    80003a6a:	74e2                	ld	s1,56(sp)
    80003a6c:	7942                	ld	s2,48(sp)
    80003a6e:	79a2                	ld	s3,40(sp)
    80003a70:	7a02                	ld	s4,32(sp)
    80003a72:	6ae2                	ld	s5,24(sp)
    80003a74:	6b42                	ld	s6,16(sp)
    80003a76:	6ba2                	ld	s7,8(sp)
    80003a78:	6161                	addi	sp,sp,80
    80003a7a:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003a7c:	04000613          	li	a2,64
    80003a80:	4581                	li	a1,0
    80003a82:	854e                	mv	a0,s3
    80003a84:	ffffd097          	auipc	ra,0xffffd
    80003a88:	262080e7          	jalr	610(ra) # 80000ce6 <memset>
      dip->type = type;
    80003a8c:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003a90:	854a                	mv	a0,s2
    80003a92:	00001097          	auipc	ra,0x1
    80003a96:	c84080e7          	jalr	-892(ra) # 80004716 <log_write>
      brelse(bp);
    80003a9a:	854a                	mv	a0,s2
    80003a9c:	00000097          	auipc	ra,0x0
    80003aa0:	9f6080e7          	jalr	-1546(ra) # 80003492 <brelse>
      return iget(dev, inum);
    80003aa4:	85da                	mv	a1,s6
    80003aa6:	8556                	mv	a0,s5
    80003aa8:	00000097          	auipc	ra,0x0
    80003aac:	d9c080e7          	jalr	-612(ra) # 80003844 <iget>
    80003ab0:	bf5d                	j	80003a66 <ialloc+0x86>

0000000080003ab2 <iupdate>:
{
    80003ab2:	1101                	addi	sp,sp,-32
    80003ab4:	ec06                	sd	ra,24(sp)
    80003ab6:	e822                	sd	s0,16(sp)
    80003ab8:	e426                	sd	s1,8(sp)
    80003aba:	e04a                	sd	s2,0(sp)
    80003abc:	1000                	addi	s0,sp,32
    80003abe:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003ac0:	415c                	lw	a5,4(a0)
    80003ac2:	0047d79b          	srliw	a5,a5,0x4
    80003ac6:	0001d597          	auipc	a1,0x1d
    80003aca:	bfa5a583          	lw	a1,-1030(a1) # 800206c0 <sb+0x18>
    80003ace:	9dbd                	addw	a1,a1,a5
    80003ad0:	4108                	lw	a0,0(a0)
    80003ad2:	00000097          	auipc	ra,0x0
    80003ad6:	890080e7          	jalr	-1904(ra) # 80003362 <bread>
    80003ada:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003adc:	05850793          	addi	a5,a0,88
    80003ae0:	40c8                	lw	a0,4(s1)
    80003ae2:	893d                	andi	a0,a0,15
    80003ae4:	051a                	slli	a0,a0,0x6
    80003ae6:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003ae8:	04449703          	lh	a4,68(s1)
    80003aec:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003af0:	04649703          	lh	a4,70(s1)
    80003af4:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003af8:	04849703          	lh	a4,72(s1)
    80003afc:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003b00:	04a49703          	lh	a4,74(s1)
    80003b04:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003b08:	44f8                	lw	a4,76(s1)
    80003b0a:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003b0c:	03400613          	li	a2,52
    80003b10:	05048593          	addi	a1,s1,80
    80003b14:	0531                	addi	a0,a0,12
    80003b16:	ffffd097          	auipc	ra,0xffffd
    80003b1a:	230080e7          	jalr	560(ra) # 80000d46 <memmove>
  log_write(bp);
    80003b1e:	854a                	mv	a0,s2
    80003b20:	00001097          	auipc	ra,0x1
    80003b24:	bf6080e7          	jalr	-1034(ra) # 80004716 <log_write>
  brelse(bp);
    80003b28:	854a                	mv	a0,s2
    80003b2a:	00000097          	auipc	ra,0x0
    80003b2e:	968080e7          	jalr	-1688(ra) # 80003492 <brelse>
}
    80003b32:	60e2                	ld	ra,24(sp)
    80003b34:	6442                	ld	s0,16(sp)
    80003b36:	64a2                	ld	s1,8(sp)
    80003b38:	6902                	ld	s2,0(sp)
    80003b3a:	6105                	addi	sp,sp,32
    80003b3c:	8082                	ret

0000000080003b3e <idup>:
{
    80003b3e:	1101                	addi	sp,sp,-32
    80003b40:	ec06                	sd	ra,24(sp)
    80003b42:	e822                	sd	s0,16(sp)
    80003b44:	e426                	sd	s1,8(sp)
    80003b46:	1000                	addi	s0,sp,32
    80003b48:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b4a:	0001d517          	auipc	a0,0x1d
    80003b4e:	b7e50513          	addi	a0,a0,-1154 # 800206c8 <itable>
    80003b52:	ffffd097          	auipc	ra,0xffffd
    80003b56:	098080e7          	jalr	152(ra) # 80000bea <acquire>
  ip->ref++;
    80003b5a:	449c                	lw	a5,8(s1)
    80003b5c:	2785                	addiw	a5,a5,1
    80003b5e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003b60:	0001d517          	auipc	a0,0x1d
    80003b64:	b6850513          	addi	a0,a0,-1176 # 800206c8 <itable>
    80003b68:	ffffd097          	auipc	ra,0xffffd
    80003b6c:	136080e7          	jalr	310(ra) # 80000c9e <release>
}
    80003b70:	8526                	mv	a0,s1
    80003b72:	60e2                	ld	ra,24(sp)
    80003b74:	6442                	ld	s0,16(sp)
    80003b76:	64a2                	ld	s1,8(sp)
    80003b78:	6105                	addi	sp,sp,32
    80003b7a:	8082                	ret

0000000080003b7c <ilock>:
{
    80003b7c:	1101                	addi	sp,sp,-32
    80003b7e:	ec06                	sd	ra,24(sp)
    80003b80:	e822                	sd	s0,16(sp)
    80003b82:	e426                	sd	s1,8(sp)
    80003b84:	e04a                	sd	s2,0(sp)
    80003b86:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003b88:	c115                	beqz	a0,80003bac <ilock+0x30>
    80003b8a:	84aa                	mv	s1,a0
    80003b8c:	451c                	lw	a5,8(a0)
    80003b8e:	00f05f63          	blez	a5,80003bac <ilock+0x30>
  acquiresleep(&ip->lock);
    80003b92:	0541                	addi	a0,a0,16
    80003b94:	00001097          	auipc	ra,0x1
    80003b98:	ca2080e7          	jalr	-862(ra) # 80004836 <acquiresleep>
  if(ip->valid == 0){
    80003b9c:	40bc                	lw	a5,64(s1)
    80003b9e:	cf99                	beqz	a5,80003bbc <ilock+0x40>
}
    80003ba0:	60e2                	ld	ra,24(sp)
    80003ba2:	6442                	ld	s0,16(sp)
    80003ba4:	64a2                	ld	s1,8(sp)
    80003ba6:	6902                	ld	s2,0(sp)
    80003ba8:	6105                	addi	sp,sp,32
    80003baa:	8082                	ret
    panic("ilock");
    80003bac:	00005517          	auipc	a0,0x5
    80003bb0:	bcc50513          	addi	a0,a0,-1076 # 80008778 <syscallnum+0x140>
    80003bb4:	ffffd097          	auipc	ra,0xffffd
    80003bb8:	990080e7          	jalr	-1648(ra) # 80000544 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003bbc:	40dc                	lw	a5,4(s1)
    80003bbe:	0047d79b          	srliw	a5,a5,0x4
    80003bc2:	0001d597          	auipc	a1,0x1d
    80003bc6:	afe5a583          	lw	a1,-1282(a1) # 800206c0 <sb+0x18>
    80003bca:	9dbd                	addw	a1,a1,a5
    80003bcc:	4088                	lw	a0,0(s1)
    80003bce:	fffff097          	auipc	ra,0xfffff
    80003bd2:	794080e7          	jalr	1940(ra) # 80003362 <bread>
    80003bd6:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003bd8:	05850593          	addi	a1,a0,88
    80003bdc:	40dc                	lw	a5,4(s1)
    80003bde:	8bbd                	andi	a5,a5,15
    80003be0:	079a                	slli	a5,a5,0x6
    80003be2:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003be4:	00059783          	lh	a5,0(a1)
    80003be8:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003bec:	00259783          	lh	a5,2(a1)
    80003bf0:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003bf4:	00459783          	lh	a5,4(a1)
    80003bf8:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003bfc:	00659783          	lh	a5,6(a1)
    80003c00:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003c04:	459c                	lw	a5,8(a1)
    80003c06:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003c08:	03400613          	li	a2,52
    80003c0c:	05b1                	addi	a1,a1,12
    80003c0e:	05048513          	addi	a0,s1,80
    80003c12:	ffffd097          	auipc	ra,0xffffd
    80003c16:	134080e7          	jalr	308(ra) # 80000d46 <memmove>
    brelse(bp);
    80003c1a:	854a                	mv	a0,s2
    80003c1c:	00000097          	auipc	ra,0x0
    80003c20:	876080e7          	jalr	-1930(ra) # 80003492 <brelse>
    ip->valid = 1;
    80003c24:	4785                	li	a5,1
    80003c26:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003c28:	04449783          	lh	a5,68(s1)
    80003c2c:	fbb5                	bnez	a5,80003ba0 <ilock+0x24>
      panic("ilock: no type");
    80003c2e:	00005517          	auipc	a0,0x5
    80003c32:	b5250513          	addi	a0,a0,-1198 # 80008780 <syscallnum+0x148>
    80003c36:	ffffd097          	auipc	ra,0xffffd
    80003c3a:	90e080e7          	jalr	-1778(ra) # 80000544 <panic>

0000000080003c3e <iunlock>:
{
    80003c3e:	1101                	addi	sp,sp,-32
    80003c40:	ec06                	sd	ra,24(sp)
    80003c42:	e822                	sd	s0,16(sp)
    80003c44:	e426                	sd	s1,8(sp)
    80003c46:	e04a                	sd	s2,0(sp)
    80003c48:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003c4a:	c905                	beqz	a0,80003c7a <iunlock+0x3c>
    80003c4c:	84aa                	mv	s1,a0
    80003c4e:	01050913          	addi	s2,a0,16
    80003c52:	854a                	mv	a0,s2
    80003c54:	00001097          	auipc	ra,0x1
    80003c58:	c7c080e7          	jalr	-900(ra) # 800048d0 <holdingsleep>
    80003c5c:	cd19                	beqz	a0,80003c7a <iunlock+0x3c>
    80003c5e:	449c                	lw	a5,8(s1)
    80003c60:	00f05d63          	blez	a5,80003c7a <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003c64:	854a                	mv	a0,s2
    80003c66:	00001097          	auipc	ra,0x1
    80003c6a:	c26080e7          	jalr	-986(ra) # 8000488c <releasesleep>
}
    80003c6e:	60e2                	ld	ra,24(sp)
    80003c70:	6442                	ld	s0,16(sp)
    80003c72:	64a2                	ld	s1,8(sp)
    80003c74:	6902                	ld	s2,0(sp)
    80003c76:	6105                	addi	sp,sp,32
    80003c78:	8082                	ret
    panic("iunlock");
    80003c7a:	00005517          	auipc	a0,0x5
    80003c7e:	b1650513          	addi	a0,a0,-1258 # 80008790 <syscallnum+0x158>
    80003c82:	ffffd097          	auipc	ra,0xffffd
    80003c86:	8c2080e7          	jalr	-1854(ra) # 80000544 <panic>

0000000080003c8a <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003c8a:	7179                	addi	sp,sp,-48
    80003c8c:	f406                	sd	ra,40(sp)
    80003c8e:	f022                	sd	s0,32(sp)
    80003c90:	ec26                	sd	s1,24(sp)
    80003c92:	e84a                	sd	s2,16(sp)
    80003c94:	e44e                	sd	s3,8(sp)
    80003c96:	e052                	sd	s4,0(sp)
    80003c98:	1800                	addi	s0,sp,48
    80003c9a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003c9c:	05050493          	addi	s1,a0,80
    80003ca0:	08050913          	addi	s2,a0,128
    80003ca4:	a021                	j	80003cac <itrunc+0x22>
    80003ca6:	0491                	addi	s1,s1,4
    80003ca8:	01248d63          	beq	s1,s2,80003cc2 <itrunc+0x38>
    if(ip->addrs[i]){
    80003cac:	408c                	lw	a1,0(s1)
    80003cae:	dde5                	beqz	a1,80003ca6 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003cb0:	0009a503          	lw	a0,0(s3)
    80003cb4:	00000097          	auipc	ra,0x0
    80003cb8:	8f4080e7          	jalr	-1804(ra) # 800035a8 <bfree>
      ip->addrs[i] = 0;
    80003cbc:	0004a023          	sw	zero,0(s1)
    80003cc0:	b7dd                	j	80003ca6 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003cc2:	0809a583          	lw	a1,128(s3)
    80003cc6:	e185                	bnez	a1,80003ce6 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003cc8:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003ccc:	854e                	mv	a0,s3
    80003cce:	00000097          	auipc	ra,0x0
    80003cd2:	de4080e7          	jalr	-540(ra) # 80003ab2 <iupdate>
}
    80003cd6:	70a2                	ld	ra,40(sp)
    80003cd8:	7402                	ld	s0,32(sp)
    80003cda:	64e2                	ld	s1,24(sp)
    80003cdc:	6942                	ld	s2,16(sp)
    80003cde:	69a2                	ld	s3,8(sp)
    80003ce0:	6a02                	ld	s4,0(sp)
    80003ce2:	6145                	addi	sp,sp,48
    80003ce4:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003ce6:	0009a503          	lw	a0,0(s3)
    80003cea:	fffff097          	auipc	ra,0xfffff
    80003cee:	678080e7          	jalr	1656(ra) # 80003362 <bread>
    80003cf2:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003cf4:	05850493          	addi	s1,a0,88
    80003cf8:	45850913          	addi	s2,a0,1112
    80003cfc:	a811                	j	80003d10 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003cfe:	0009a503          	lw	a0,0(s3)
    80003d02:	00000097          	auipc	ra,0x0
    80003d06:	8a6080e7          	jalr	-1882(ra) # 800035a8 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003d0a:	0491                	addi	s1,s1,4
    80003d0c:	01248563          	beq	s1,s2,80003d16 <itrunc+0x8c>
      if(a[j])
    80003d10:	408c                	lw	a1,0(s1)
    80003d12:	dde5                	beqz	a1,80003d0a <itrunc+0x80>
    80003d14:	b7ed                	j	80003cfe <itrunc+0x74>
    brelse(bp);
    80003d16:	8552                	mv	a0,s4
    80003d18:	fffff097          	auipc	ra,0xfffff
    80003d1c:	77a080e7          	jalr	1914(ra) # 80003492 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003d20:	0809a583          	lw	a1,128(s3)
    80003d24:	0009a503          	lw	a0,0(s3)
    80003d28:	00000097          	auipc	ra,0x0
    80003d2c:	880080e7          	jalr	-1920(ra) # 800035a8 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003d30:	0809a023          	sw	zero,128(s3)
    80003d34:	bf51                	j	80003cc8 <itrunc+0x3e>

0000000080003d36 <iput>:
{
    80003d36:	1101                	addi	sp,sp,-32
    80003d38:	ec06                	sd	ra,24(sp)
    80003d3a:	e822                	sd	s0,16(sp)
    80003d3c:	e426                	sd	s1,8(sp)
    80003d3e:	e04a                	sd	s2,0(sp)
    80003d40:	1000                	addi	s0,sp,32
    80003d42:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003d44:	0001d517          	auipc	a0,0x1d
    80003d48:	98450513          	addi	a0,a0,-1660 # 800206c8 <itable>
    80003d4c:	ffffd097          	auipc	ra,0xffffd
    80003d50:	e9e080e7          	jalr	-354(ra) # 80000bea <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003d54:	4498                	lw	a4,8(s1)
    80003d56:	4785                	li	a5,1
    80003d58:	02f70363          	beq	a4,a5,80003d7e <iput+0x48>
  ip->ref--;
    80003d5c:	449c                	lw	a5,8(s1)
    80003d5e:	37fd                	addiw	a5,a5,-1
    80003d60:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003d62:	0001d517          	auipc	a0,0x1d
    80003d66:	96650513          	addi	a0,a0,-1690 # 800206c8 <itable>
    80003d6a:	ffffd097          	auipc	ra,0xffffd
    80003d6e:	f34080e7          	jalr	-204(ra) # 80000c9e <release>
}
    80003d72:	60e2                	ld	ra,24(sp)
    80003d74:	6442                	ld	s0,16(sp)
    80003d76:	64a2                	ld	s1,8(sp)
    80003d78:	6902                	ld	s2,0(sp)
    80003d7a:	6105                	addi	sp,sp,32
    80003d7c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003d7e:	40bc                	lw	a5,64(s1)
    80003d80:	dff1                	beqz	a5,80003d5c <iput+0x26>
    80003d82:	04a49783          	lh	a5,74(s1)
    80003d86:	fbf9                	bnez	a5,80003d5c <iput+0x26>
    acquiresleep(&ip->lock);
    80003d88:	01048913          	addi	s2,s1,16
    80003d8c:	854a                	mv	a0,s2
    80003d8e:	00001097          	auipc	ra,0x1
    80003d92:	aa8080e7          	jalr	-1368(ra) # 80004836 <acquiresleep>
    release(&itable.lock);
    80003d96:	0001d517          	auipc	a0,0x1d
    80003d9a:	93250513          	addi	a0,a0,-1742 # 800206c8 <itable>
    80003d9e:	ffffd097          	auipc	ra,0xffffd
    80003da2:	f00080e7          	jalr	-256(ra) # 80000c9e <release>
    itrunc(ip);
    80003da6:	8526                	mv	a0,s1
    80003da8:	00000097          	auipc	ra,0x0
    80003dac:	ee2080e7          	jalr	-286(ra) # 80003c8a <itrunc>
    ip->type = 0;
    80003db0:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003db4:	8526                	mv	a0,s1
    80003db6:	00000097          	auipc	ra,0x0
    80003dba:	cfc080e7          	jalr	-772(ra) # 80003ab2 <iupdate>
    ip->valid = 0;
    80003dbe:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003dc2:	854a                	mv	a0,s2
    80003dc4:	00001097          	auipc	ra,0x1
    80003dc8:	ac8080e7          	jalr	-1336(ra) # 8000488c <releasesleep>
    acquire(&itable.lock);
    80003dcc:	0001d517          	auipc	a0,0x1d
    80003dd0:	8fc50513          	addi	a0,a0,-1796 # 800206c8 <itable>
    80003dd4:	ffffd097          	auipc	ra,0xffffd
    80003dd8:	e16080e7          	jalr	-490(ra) # 80000bea <acquire>
    80003ddc:	b741                	j	80003d5c <iput+0x26>

0000000080003dde <iunlockput>:
{
    80003dde:	1101                	addi	sp,sp,-32
    80003de0:	ec06                	sd	ra,24(sp)
    80003de2:	e822                	sd	s0,16(sp)
    80003de4:	e426                	sd	s1,8(sp)
    80003de6:	1000                	addi	s0,sp,32
    80003de8:	84aa                	mv	s1,a0
  iunlock(ip);
    80003dea:	00000097          	auipc	ra,0x0
    80003dee:	e54080e7          	jalr	-428(ra) # 80003c3e <iunlock>
  iput(ip);
    80003df2:	8526                	mv	a0,s1
    80003df4:	00000097          	auipc	ra,0x0
    80003df8:	f42080e7          	jalr	-190(ra) # 80003d36 <iput>
}
    80003dfc:	60e2                	ld	ra,24(sp)
    80003dfe:	6442                	ld	s0,16(sp)
    80003e00:	64a2                	ld	s1,8(sp)
    80003e02:	6105                	addi	sp,sp,32
    80003e04:	8082                	ret

0000000080003e06 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003e06:	1141                	addi	sp,sp,-16
    80003e08:	e422                	sd	s0,8(sp)
    80003e0a:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003e0c:	411c                	lw	a5,0(a0)
    80003e0e:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003e10:	415c                	lw	a5,4(a0)
    80003e12:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003e14:	04451783          	lh	a5,68(a0)
    80003e18:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003e1c:	04a51783          	lh	a5,74(a0)
    80003e20:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003e24:	04c56783          	lwu	a5,76(a0)
    80003e28:	e99c                	sd	a5,16(a1)
}
    80003e2a:	6422                	ld	s0,8(sp)
    80003e2c:	0141                	addi	sp,sp,16
    80003e2e:	8082                	ret

0000000080003e30 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003e30:	457c                	lw	a5,76(a0)
    80003e32:	0ed7e963          	bltu	a5,a3,80003f24 <readi+0xf4>
{
    80003e36:	7159                	addi	sp,sp,-112
    80003e38:	f486                	sd	ra,104(sp)
    80003e3a:	f0a2                	sd	s0,96(sp)
    80003e3c:	eca6                	sd	s1,88(sp)
    80003e3e:	e8ca                	sd	s2,80(sp)
    80003e40:	e4ce                	sd	s3,72(sp)
    80003e42:	e0d2                	sd	s4,64(sp)
    80003e44:	fc56                	sd	s5,56(sp)
    80003e46:	f85a                	sd	s6,48(sp)
    80003e48:	f45e                	sd	s7,40(sp)
    80003e4a:	f062                	sd	s8,32(sp)
    80003e4c:	ec66                	sd	s9,24(sp)
    80003e4e:	e86a                	sd	s10,16(sp)
    80003e50:	e46e                	sd	s11,8(sp)
    80003e52:	1880                	addi	s0,sp,112
    80003e54:	8b2a                	mv	s6,a0
    80003e56:	8bae                	mv	s7,a1
    80003e58:	8a32                	mv	s4,a2
    80003e5a:	84b6                	mv	s1,a3
    80003e5c:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003e5e:	9f35                	addw	a4,a4,a3
    return 0;
    80003e60:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003e62:	0ad76063          	bltu	a4,a3,80003f02 <readi+0xd2>
  if(off + n > ip->size)
    80003e66:	00e7f463          	bgeu	a5,a4,80003e6e <readi+0x3e>
    n = ip->size - off;
    80003e6a:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e6e:	0a0a8963          	beqz	s5,80003f20 <readi+0xf0>
    80003e72:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e74:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003e78:	5c7d                	li	s8,-1
    80003e7a:	a82d                	j	80003eb4 <readi+0x84>
    80003e7c:	020d1d93          	slli	s11,s10,0x20
    80003e80:	020ddd93          	srli	s11,s11,0x20
    80003e84:	05890613          	addi	a2,s2,88
    80003e88:	86ee                	mv	a3,s11
    80003e8a:	963a                	add	a2,a2,a4
    80003e8c:	85d2                	mv	a1,s4
    80003e8e:	855e                	mv	a0,s7
    80003e90:	fffff097          	auipc	ra,0xfffff
    80003e94:	858080e7          	jalr	-1960(ra) # 800026e8 <either_copyout>
    80003e98:	05850d63          	beq	a0,s8,80003ef2 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003e9c:	854a                	mv	a0,s2
    80003e9e:	fffff097          	auipc	ra,0xfffff
    80003ea2:	5f4080e7          	jalr	1524(ra) # 80003492 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ea6:	013d09bb          	addw	s3,s10,s3
    80003eaa:	009d04bb          	addw	s1,s10,s1
    80003eae:	9a6e                	add	s4,s4,s11
    80003eb0:	0559f763          	bgeu	s3,s5,80003efe <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003eb4:	00a4d59b          	srliw	a1,s1,0xa
    80003eb8:	855a                	mv	a0,s6
    80003eba:	00000097          	auipc	ra,0x0
    80003ebe:	8a2080e7          	jalr	-1886(ra) # 8000375c <bmap>
    80003ec2:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003ec6:	cd85                	beqz	a1,80003efe <readi+0xce>
    bp = bread(ip->dev, addr);
    80003ec8:	000b2503          	lw	a0,0(s6)
    80003ecc:	fffff097          	auipc	ra,0xfffff
    80003ed0:	496080e7          	jalr	1174(ra) # 80003362 <bread>
    80003ed4:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ed6:	3ff4f713          	andi	a4,s1,1023
    80003eda:	40ec87bb          	subw	a5,s9,a4
    80003ede:	413a86bb          	subw	a3,s5,s3
    80003ee2:	8d3e                	mv	s10,a5
    80003ee4:	2781                	sext.w	a5,a5
    80003ee6:	0006861b          	sext.w	a2,a3
    80003eea:	f8f679e3          	bgeu	a2,a5,80003e7c <readi+0x4c>
    80003eee:	8d36                	mv	s10,a3
    80003ef0:	b771                	j	80003e7c <readi+0x4c>
      brelse(bp);
    80003ef2:	854a                	mv	a0,s2
    80003ef4:	fffff097          	auipc	ra,0xfffff
    80003ef8:	59e080e7          	jalr	1438(ra) # 80003492 <brelse>
      tot = -1;
    80003efc:	59fd                	li	s3,-1
  }
  return tot;
    80003efe:	0009851b          	sext.w	a0,s3
}
    80003f02:	70a6                	ld	ra,104(sp)
    80003f04:	7406                	ld	s0,96(sp)
    80003f06:	64e6                	ld	s1,88(sp)
    80003f08:	6946                	ld	s2,80(sp)
    80003f0a:	69a6                	ld	s3,72(sp)
    80003f0c:	6a06                	ld	s4,64(sp)
    80003f0e:	7ae2                	ld	s5,56(sp)
    80003f10:	7b42                	ld	s6,48(sp)
    80003f12:	7ba2                	ld	s7,40(sp)
    80003f14:	7c02                	ld	s8,32(sp)
    80003f16:	6ce2                	ld	s9,24(sp)
    80003f18:	6d42                	ld	s10,16(sp)
    80003f1a:	6da2                	ld	s11,8(sp)
    80003f1c:	6165                	addi	sp,sp,112
    80003f1e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f20:	89d6                	mv	s3,s5
    80003f22:	bff1                	j	80003efe <readi+0xce>
    return 0;
    80003f24:	4501                	li	a0,0
}
    80003f26:	8082                	ret

0000000080003f28 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f28:	457c                	lw	a5,76(a0)
    80003f2a:	10d7e863          	bltu	a5,a3,8000403a <writei+0x112>
{
    80003f2e:	7159                	addi	sp,sp,-112
    80003f30:	f486                	sd	ra,104(sp)
    80003f32:	f0a2                	sd	s0,96(sp)
    80003f34:	eca6                	sd	s1,88(sp)
    80003f36:	e8ca                	sd	s2,80(sp)
    80003f38:	e4ce                	sd	s3,72(sp)
    80003f3a:	e0d2                	sd	s4,64(sp)
    80003f3c:	fc56                	sd	s5,56(sp)
    80003f3e:	f85a                	sd	s6,48(sp)
    80003f40:	f45e                	sd	s7,40(sp)
    80003f42:	f062                	sd	s8,32(sp)
    80003f44:	ec66                	sd	s9,24(sp)
    80003f46:	e86a                	sd	s10,16(sp)
    80003f48:	e46e                	sd	s11,8(sp)
    80003f4a:	1880                	addi	s0,sp,112
    80003f4c:	8aaa                	mv	s5,a0
    80003f4e:	8bae                	mv	s7,a1
    80003f50:	8a32                	mv	s4,a2
    80003f52:	8936                	mv	s2,a3
    80003f54:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003f56:	00e687bb          	addw	a5,a3,a4
    80003f5a:	0ed7e263          	bltu	a5,a3,8000403e <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003f5e:	00043737          	lui	a4,0x43
    80003f62:	0ef76063          	bltu	a4,a5,80004042 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f66:	0c0b0863          	beqz	s6,80004036 <writei+0x10e>
    80003f6a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f6c:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003f70:	5c7d                	li	s8,-1
    80003f72:	a091                	j	80003fb6 <writei+0x8e>
    80003f74:	020d1d93          	slli	s11,s10,0x20
    80003f78:	020ddd93          	srli	s11,s11,0x20
    80003f7c:	05848513          	addi	a0,s1,88
    80003f80:	86ee                	mv	a3,s11
    80003f82:	8652                	mv	a2,s4
    80003f84:	85de                	mv	a1,s7
    80003f86:	953a                	add	a0,a0,a4
    80003f88:	ffffe097          	auipc	ra,0xffffe
    80003f8c:	7b6080e7          	jalr	1974(ra) # 8000273e <either_copyin>
    80003f90:	07850263          	beq	a0,s8,80003ff4 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003f94:	8526                	mv	a0,s1
    80003f96:	00000097          	auipc	ra,0x0
    80003f9a:	780080e7          	jalr	1920(ra) # 80004716 <log_write>
    brelse(bp);
    80003f9e:	8526                	mv	a0,s1
    80003fa0:	fffff097          	auipc	ra,0xfffff
    80003fa4:	4f2080e7          	jalr	1266(ra) # 80003492 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003fa8:	013d09bb          	addw	s3,s10,s3
    80003fac:	012d093b          	addw	s2,s10,s2
    80003fb0:	9a6e                	add	s4,s4,s11
    80003fb2:	0569f663          	bgeu	s3,s6,80003ffe <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003fb6:	00a9559b          	srliw	a1,s2,0xa
    80003fba:	8556                	mv	a0,s5
    80003fbc:	fffff097          	auipc	ra,0xfffff
    80003fc0:	7a0080e7          	jalr	1952(ra) # 8000375c <bmap>
    80003fc4:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003fc8:	c99d                	beqz	a1,80003ffe <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003fca:	000aa503          	lw	a0,0(s5)
    80003fce:	fffff097          	auipc	ra,0xfffff
    80003fd2:	394080e7          	jalr	916(ra) # 80003362 <bread>
    80003fd6:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fd8:	3ff97713          	andi	a4,s2,1023
    80003fdc:	40ec87bb          	subw	a5,s9,a4
    80003fe0:	413b06bb          	subw	a3,s6,s3
    80003fe4:	8d3e                	mv	s10,a5
    80003fe6:	2781                	sext.w	a5,a5
    80003fe8:	0006861b          	sext.w	a2,a3
    80003fec:	f8f674e3          	bgeu	a2,a5,80003f74 <writei+0x4c>
    80003ff0:	8d36                	mv	s10,a3
    80003ff2:	b749                	j	80003f74 <writei+0x4c>
      brelse(bp);
    80003ff4:	8526                	mv	a0,s1
    80003ff6:	fffff097          	auipc	ra,0xfffff
    80003ffa:	49c080e7          	jalr	1180(ra) # 80003492 <brelse>
  }

  if(off > ip->size)
    80003ffe:	04caa783          	lw	a5,76(s5)
    80004002:	0127f463          	bgeu	a5,s2,8000400a <writei+0xe2>
    ip->size = off;
    80004006:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000400a:	8556                	mv	a0,s5
    8000400c:	00000097          	auipc	ra,0x0
    80004010:	aa6080e7          	jalr	-1370(ra) # 80003ab2 <iupdate>

  return tot;
    80004014:	0009851b          	sext.w	a0,s3
}
    80004018:	70a6                	ld	ra,104(sp)
    8000401a:	7406                	ld	s0,96(sp)
    8000401c:	64e6                	ld	s1,88(sp)
    8000401e:	6946                	ld	s2,80(sp)
    80004020:	69a6                	ld	s3,72(sp)
    80004022:	6a06                	ld	s4,64(sp)
    80004024:	7ae2                	ld	s5,56(sp)
    80004026:	7b42                	ld	s6,48(sp)
    80004028:	7ba2                	ld	s7,40(sp)
    8000402a:	7c02                	ld	s8,32(sp)
    8000402c:	6ce2                	ld	s9,24(sp)
    8000402e:	6d42                	ld	s10,16(sp)
    80004030:	6da2                	ld	s11,8(sp)
    80004032:	6165                	addi	sp,sp,112
    80004034:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004036:	89da                	mv	s3,s6
    80004038:	bfc9                	j	8000400a <writei+0xe2>
    return -1;
    8000403a:	557d                	li	a0,-1
}
    8000403c:	8082                	ret
    return -1;
    8000403e:	557d                	li	a0,-1
    80004040:	bfe1                	j	80004018 <writei+0xf0>
    return -1;
    80004042:	557d                	li	a0,-1
    80004044:	bfd1                	j	80004018 <writei+0xf0>

0000000080004046 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004046:	1141                	addi	sp,sp,-16
    80004048:	e406                	sd	ra,8(sp)
    8000404a:	e022                	sd	s0,0(sp)
    8000404c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000404e:	4639                	li	a2,14
    80004050:	ffffd097          	auipc	ra,0xffffd
    80004054:	d6e080e7          	jalr	-658(ra) # 80000dbe <strncmp>
}
    80004058:	60a2                	ld	ra,8(sp)
    8000405a:	6402                	ld	s0,0(sp)
    8000405c:	0141                	addi	sp,sp,16
    8000405e:	8082                	ret

0000000080004060 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004060:	7139                	addi	sp,sp,-64
    80004062:	fc06                	sd	ra,56(sp)
    80004064:	f822                	sd	s0,48(sp)
    80004066:	f426                	sd	s1,40(sp)
    80004068:	f04a                	sd	s2,32(sp)
    8000406a:	ec4e                	sd	s3,24(sp)
    8000406c:	e852                	sd	s4,16(sp)
    8000406e:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004070:	04451703          	lh	a4,68(a0)
    80004074:	4785                	li	a5,1
    80004076:	00f71a63          	bne	a4,a5,8000408a <dirlookup+0x2a>
    8000407a:	892a                	mv	s2,a0
    8000407c:	89ae                	mv	s3,a1
    8000407e:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004080:	457c                	lw	a5,76(a0)
    80004082:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004084:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004086:	e79d                	bnez	a5,800040b4 <dirlookup+0x54>
    80004088:	a8a5                	j	80004100 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    8000408a:	00004517          	auipc	a0,0x4
    8000408e:	70e50513          	addi	a0,a0,1806 # 80008798 <syscallnum+0x160>
    80004092:	ffffc097          	auipc	ra,0xffffc
    80004096:	4b2080e7          	jalr	1202(ra) # 80000544 <panic>
      panic("dirlookup read");
    8000409a:	00004517          	auipc	a0,0x4
    8000409e:	71650513          	addi	a0,a0,1814 # 800087b0 <syscallnum+0x178>
    800040a2:	ffffc097          	auipc	ra,0xffffc
    800040a6:	4a2080e7          	jalr	1186(ra) # 80000544 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040aa:	24c1                	addiw	s1,s1,16
    800040ac:	04c92783          	lw	a5,76(s2)
    800040b0:	04f4f763          	bgeu	s1,a5,800040fe <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040b4:	4741                	li	a4,16
    800040b6:	86a6                	mv	a3,s1
    800040b8:	fc040613          	addi	a2,s0,-64
    800040bc:	4581                	li	a1,0
    800040be:	854a                	mv	a0,s2
    800040c0:	00000097          	auipc	ra,0x0
    800040c4:	d70080e7          	jalr	-656(ra) # 80003e30 <readi>
    800040c8:	47c1                	li	a5,16
    800040ca:	fcf518e3          	bne	a0,a5,8000409a <dirlookup+0x3a>
    if(de.inum == 0)
    800040ce:	fc045783          	lhu	a5,-64(s0)
    800040d2:	dfe1                	beqz	a5,800040aa <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800040d4:	fc240593          	addi	a1,s0,-62
    800040d8:	854e                	mv	a0,s3
    800040da:	00000097          	auipc	ra,0x0
    800040de:	f6c080e7          	jalr	-148(ra) # 80004046 <namecmp>
    800040e2:	f561                	bnez	a0,800040aa <dirlookup+0x4a>
      if(poff)
    800040e4:	000a0463          	beqz	s4,800040ec <dirlookup+0x8c>
        *poff = off;
    800040e8:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800040ec:	fc045583          	lhu	a1,-64(s0)
    800040f0:	00092503          	lw	a0,0(s2)
    800040f4:	fffff097          	auipc	ra,0xfffff
    800040f8:	750080e7          	jalr	1872(ra) # 80003844 <iget>
    800040fc:	a011                	j	80004100 <dirlookup+0xa0>
  return 0;
    800040fe:	4501                	li	a0,0
}
    80004100:	70e2                	ld	ra,56(sp)
    80004102:	7442                	ld	s0,48(sp)
    80004104:	74a2                	ld	s1,40(sp)
    80004106:	7902                	ld	s2,32(sp)
    80004108:	69e2                	ld	s3,24(sp)
    8000410a:	6a42                	ld	s4,16(sp)
    8000410c:	6121                	addi	sp,sp,64
    8000410e:	8082                	ret

0000000080004110 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004110:	711d                	addi	sp,sp,-96
    80004112:	ec86                	sd	ra,88(sp)
    80004114:	e8a2                	sd	s0,80(sp)
    80004116:	e4a6                	sd	s1,72(sp)
    80004118:	e0ca                	sd	s2,64(sp)
    8000411a:	fc4e                	sd	s3,56(sp)
    8000411c:	f852                	sd	s4,48(sp)
    8000411e:	f456                	sd	s5,40(sp)
    80004120:	f05a                	sd	s6,32(sp)
    80004122:	ec5e                	sd	s7,24(sp)
    80004124:	e862                	sd	s8,16(sp)
    80004126:	e466                	sd	s9,8(sp)
    80004128:	1080                	addi	s0,sp,96
    8000412a:	84aa                	mv	s1,a0
    8000412c:	8b2e                	mv	s6,a1
    8000412e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004130:	00054703          	lbu	a4,0(a0)
    80004134:	02f00793          	li	a5,47
    80004138:	02f70363          	beq	a4,a5,8000415e <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000413c:	ffffe097          	auipc	ra,0xffffe
    80004140:	88a080e7          	jalr	-1910(ra) # 800019c6 <myproc>
    80004144:	15053503          	ld	a0,336(a0)
    80004148:	00000097          	auipc	ra,0x0
    8000414c:	9f6080e7          	jalr	-1546(ra) # 80003b3e <idup>
    80004150:	89aa                	mv	s3,a0
  while(*path == '/')
    80004152:	02f00913          	li	s2,47
  len = path - s;
    80004156:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80004158:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000415a:	4c05                	li	s8,1
    8000415c:	a865                	j	80004214 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    8000415e:	4585                	li	a1,1
    80004160:	4505                	li	a0,1
    80004162:	fffff097          	auipc	ra,0xfffff
    80004166:	6e2080e7          	jalr	1762(ra) # 80003844 <iget>
    8000416a:	89aa                	mv	s3,a0
    8000416c:	b7dd                	j	80004152 <namex+0x42>
      iunlockput(ip);
    8000416e:	854e                	mv	a0,s3
    80004170:	00000097          	auipc	ra,0x0
    80004174:	c6e080e7          	jalr	-914(ra) # 80003dde <iunlockput>
      return 0;
    80004178:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    8000417a:	854e                	mv	a0,s3
    8000417c:	60e6                	ld	ra,88(sp)
    8000417e:	6446                	ld	s0,80(sp)
    80004180:	64a6                	ld	s1,72(sp)
    80004182:	6906                	ld	s2,64(sp)
    80004184:	79e2                	ld	s3,56(sp)
    80004186:	7a42                	ld	s4,48(sp)
    80004188:	7aa2                	ld	s5,40(sp)
    8000418a:	7b02                	ld	s6,32(sp)
    8000418c:	6be2                	ld	s7,24(sp)
    8000418e:	6c42                	ld	s8,16(sp)
    80004190:	6ca2                	ld	s9,8(sp)
    80004192:	6125                	addi	sp,sp,96
    80004194:	8082                	ret
      iunlock(ip);
    80004196:	854e                	mv	a0,s3
    80004198:	00000097          	auipc	ra,0x0
    8000419c:	aa6080e7          	jalr	-1370(ra) # 80003c3e <iunlock>
      return ip;
    800041a0:	bfe9                	j	8000417a <namex+0x6a>
      iunlockput(ip);
    800041a2:	854e                	mv	a0,s3
    800041a4:	00000097          	auipc	ra,0x0
    800041a8:	c3a080e7          	jalr	-966(ra) # 80003dde <iunlockput>
      return 0;
    800041ac:	89d2                	mv	s3,s4
    800041ae:	b7f1                	j	8000417a <namex+0x6a>
  len = path - s;
    800041b0:	40b48633          	sub	a2,s1,a1
    800041b4:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    800041b8:	094cd463          	bge	s9,s4,80004240 <namex+0x130>
    memmove(name, s, DIRSIZ);
    800041bc:	4639                	li	a2,14
    800041be:	8556                	mv	a0,s5
    800041c0:	ffffd097          	auipc	ra,0xffffd
    800041c4:	b86080e7          	jalr	-1146(ra) # 80000d46 <memmove>
  while(*path == '/')
    800041c8:	0004c783          	lbu	a5,0(s1)
    800041cc:	01279763          	bne	a5,s2,800041da <namex+0xca>
    path++;
    800041d0:	0485                	addi	s1,s1,1
  while(*path == '/')
    800041d2:	0004c783          	lbu	a5,0(s1)
    800041d6:	ff278de3          	beq	a5,s2,800041d0 <namex+0xc0>
    ilock(ip);
    800041da:	854e                	mv	a0,s3
    800041dc:	00000097          	auipc	ra,0x0
    800041e0:	9a0080e7          	jalr	-1632(ra) # 80003b7c <ilock>
    if(ip->type != T_DIR){
    800041e4:	04499783          	lh	a5,68(s3)
    800041e8:	f98793e3          	bne	a5,s8,8000416e <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800041ec:	000b0563          	beqz	s6,800041f6 <namex+0xe6>
    800041f0:	0004c783          	lbu	a5,0(s1)
    800041f4:	d3cd                	beqz	a5,80004196 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800041f6:	865e                	mv	a2,s7
    800041f8:	85d6                	mv	a1,s5
    800041fa:	854e                	mv	a0,s3
    800041fc:	00000097          	auipc	ra,0x0
    80004200:	e64080e7          	jalr	-412(ra) # 80004060 <dirlookup>
    80004204:	8a2a                	mv	s4,a0
    80004206:	dd51                	beqz	a0,800041a2 <namex+0x92>
    iunlockput(ip);
    80004208:	854e                	mv	a0,s3
    8000420a:	00000097          	auipc	ra,0x0
    8000420e:	bd4080e7          	jalr	-1068(ra) # 80003dde <iunlockput>
    ip = next;
    80004212:	89d2                	mv	s3,s4
  while(*path == '/')
    80004214:	0004c783          	lbu	a5,0(s1)
    80004218:	05279763          	bne	a5,s2,80004266 <namex+0x156>
    path++;
    8000421c:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000421e:	0004c783          	lbu	a5,0(s1)
    80004222:	ff278de3          	beq	a5,s2,8000421c <namex+0x10c>
  if(*path == 0)
    80004226:	c79d                	beqz	a5,80004254 <namex+0x144>
    path++;
    80004228:	85a6                	mv	a1,s1
  len = path - s;
    8000422a:	8a5e                	mv	s4,s7
    8000422c:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    8000422e:	01278963          	beq	a5,s2,80004240 <namex+0x130>
    80004232:	dfbd                	beqz	a5,800041b0 <namex+0xa0>
    path++;
    80004234:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004236:	0004c783          	lbu	a5,0(s1)
    8000423a:	ff279ce3          	bne	a5,s2,80004232 <namex+0x122>
    8000423e:	bf8d                	j	800041b0 <namex+0xa0>
    memmove(name, s, len);
    80004240:	2601                	sext.w	a2,a2
    80004242:	8556                	mv	a0,s5
    80004244:	ffffd097          	auipc	ra,0xffffd
    80004248:	b02080e7          	jalr	-1278(ra) # 80000d46 <memmove>
    name[len] = 0;
    8000424c:	9a56                	add	s4,s4,s5
    8000424e:	000a0023          	sb	zero,0(s4)
    80004252:	bf9d                	j	800041c8 <namex+0xb8>
  if(nameiparent){
    80004254:	f20b03e3          	beqz	s6,8000417a <namex+0x6a>
    iput(ip);
    80004258:	854e                	mv	a0,s3
    8000425a:	00000097          	auipc	ra,0x0
    8000425e:	adc080e7          	jalr	-1316(ra) # 80003d36 <iput>
    return 0;
    80004262:	4981                	li	s3,0
    80004264:	bf19                	j	8000417a <namex+0x6a>
  if(*path == 0)
    80004266:	d7fd                	beqz	a5,80004254 <namex+0x144>
  while(*path != '/' && *path != 0)
    80004268:	0004c783          	lbu	a5,0(s1)
    8000426c:	85a6                	mv	a1,s1
    8000426e:	b7d1                	j	80004232 <namex+0x122>

0000000080004270 <dirlink>:
{
    80004270:	7139                	addi	sp,sp,-64
    80004272:	fc06                	sd	ra,56(sp)
    80004274:	f822                	sd	s0,48(sp)
    80004276:	f426                	sd	s1,40(sp)
    80004278:	f04a                	sd	s2,32(sp)
    8000427a:	ec4e                	sd	s3,24(sp)
    8000427c:	e852                	sd	s4,16(sp)
    8000427e:	0080                	addi	s0,sp,64
    80004280:	892a                	mv	s2,a0
    80004282:	8a2e                	mv	s4,a1
    80004284:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004286:	4601                	li	a2,0
    80004288:	00000097          	auipc	ra,0x0
    8000428c:	dd8080e7          	jalr	-552(ra) # 80004060 <dirlookup>
    80004290:	e93d                	bnez	a0,80004306 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004292:	04c92483          	lw	s1,76(s2)
    80004296:	c49d                	beqz	s1,800042c4 <dirlink+0x54>
    80004298:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000429a:	4741                	li	a4,16
    8000429c:	86a6                	mv	a3,s1
    8000429e:	fc040613          	addi	a2,s0,-64
    800042a2:	4581                	li	a1,0
    800042a4:	854a                	mv	a0,s2
    800042a6:	00000097          	auipc	ra,0x0
    800042aa:	b8a080e7          	jalr	-1142(ra) # 80003e30 <readi>
    800042ae:	47c1                	li	a5,16
    800042b0:	06f51163          	bne	a0,a5,80004312 <dirlink+0xa2>
    if(de.inum == 0)
    800042b4:	fc045783          	lhu	a5,-64(s0)
    800042b8:	c791                	beqz	a5,800042c4 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042ba:	24c1                	addiw	s1,s1,16
    800042bc:	04c92783          	lw	a5,76(s2)
    800042c0:	fcf4ede3          	bltu	s1,a5,8000429a <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800042c4:	4639                	li	a2,14
    800042c6:	85d2                	mv	a1,s4
    800042c8:	fc240513          	addi	a0,s0,-62
    800042cc:	ffffd097          	auipc	ra,0xffffd
    800042d0:	b2e080e7          	jalr	-1234(ra) # 80000dfa <strncpy>
  de.inum = inum;
    800042d4:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042d8:	4741                	li	a4,16
    800042da:	86a6                	mv	a3,s1
    800042dc:	fc040613          	addi	a2,s0,-64
    800042e0:	4581                	li	a1,0
    800042e2:	854a                	mv	a0,s2
    800042e4:	00000097          	auipc	ra,0x0
    800042e8:	c44080e7          	jalr	-956(ra) # 80003f28 <writei>
    800042ec:	1541                	addi	a0,a0,-16
    800042ee:	00a03533          	snez	a0,a0
    800042f2:	40a00533          	neg	a0,a0
}
    800042f6:	70e2                	ld	ra,56(sp)
    800042f8:	7442                	ld	s0,48(sp)
    800042fa:	74a2                	ld	s1,40(sp)
    800042fc:	7902                	ld	s2,32(sp)
    800042fe:	69e2                	ld	s3,24(sp)
    80004300:	6a42                	ld	s4,16(sp)
    80004302:	6121                	addi	sp,sp,64
    80004304:	8082                	ret
    iput(ip);
    80004306:	00000097          	auipc	ra,0x0
    8000430a:	a30080e7          	jalr	-1488(ra) # 80003d36 <iput>
    return -1;
    8000430e:	557d                	li	a0,-1
    80004310:	b7dd                	j	800042f6 <dirlink+0x86>
      panic("dirlink read");
    80004312:	00004517          	auipc	a0,0x4
    80004316:	4ae50513          	addi	a0,a0,1198 # 800087c0 <syscallnum+0x188>
    8000431a:	ffffc097          	auipc	ra,0xffffc
    8000431e:	22a080e7          	jalr	554(ra) # 80000544 <panic>

0000000080004322 <namei>:

struct inode*
namei(char *path)
{
    80004322:	1101                	addi	sp,sp,-32
    80004324:	ec06                	sd	ra,24(sp)
    80004326:	e822                	sd	s0,16(sp)
    80004328:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000432a:	fe040613          	addi	a2,s0,-32
    8000432e:	4581                	li	a1,0
    80004330:	00000097          	auipc	ra,0x0
    80004334:	de0080e7          	jalr	-544(ra) # 80004110 <namex>
}
    80004338:	60e2                	ld	ra,24(sp)
    8000433a:	6442                	ld	s0,16(sp)
    8000433c:	6105                	addi	sp,sp,32
    8000433e:	8082                	ret

0000000080004340 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004340:	1141                	addi	sp,sp,-16
    80004342:	e406                	sd	ra,8(sp)
    80004344:	e022                	sd	s0,0(sp)
    80004346:	0800                	addi	s0,sp,16
    80004348:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000434a:	4585                	li	a1,1
    8000434c:	00000097          	auipc	ra,0x0
    80004350:	dc4080e7          	jalr	-572(ra) # 80004110 <namex>
}
    80004354:	60a2                	ld	ra,8(sp)
    80004356:	6402                	ld	s0,0(sp)
    80004358:	0141                	addi	sp,sp,16
    8000435a:	8082                	ret

000000008000435c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000435c:	1101                	addi	sp,sp,-32
    8000435e:	ec06                	sd	ra,24(sp)
    80004360:	e822                	sd	s0,16(sp)
    80004362:	e426                	sd	s1,8(sp)
    80004364:	e04a                	sd	s2,0(sp)
    80004366:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004368:	0001e917          	auipc	s2,0x1e
    8000436c:	e0890913          	addi	s2,s2,-504 # 80022170 <log>
    80004370:	01892583          	lw	a1,24(s2)
    80004374:	02892503          	lw	a0,40(s2)
    80004378:	fffff097          	auipc	ra,0xfffff
    8000437c:	fea080e7          	jalr	-22(ra) # 80003362 <bread>
    80004380:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004382:	02c92683          	lw	a3,44(s2)
    80004386:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004388:	02d05763          	blez	a3,800043b6 <write_head+0x5a>
    8000438c:	0001e797          	auipc	a5,0x1e
    80004390:	e1478793          	addi	a5,a5,-492 # 800221a0 <log+0x30>
    80004394:	05c50713          	addi	a4,a0,92
    80004398:	36fd                	addiw	a3,a3,-1
    8000439a:	1682                	slli	a3,a3,0x20
    8000439c:	9281                	srli	a3,a3,0x20
    8000439e:	068a                	slli	a3,a3,0x2
    800043a0:	0001e617          	auipc	a2,0x1e
    800043a4:	e0460613          	addi	a2,a2,-508 # 800221a4 <log+0x34>
    800043a8:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800043aa:	4390                	lw	a2,0(a5)
    800043ac:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800043ae:	0791                	addi	a5,a5,4
    800043b0:	0711                	addi	a4,a4,4
    800043b2:	fed79ce3          	bne	a5,a3,800043aa <write_head+0x4e>
  }
  bwrite(buf);
    800043b6:	8526                	mv	a0,s1
    800043b8:	fffff097          	auipc	ra,0xfffff
    800043bc:	09c080e7          	jalr	156(ra) # 80003454 <bwrite>
  brelse(buf);
    800043c0:	8526                	mv	a0,s1
    800043c2:	fffff097          	auipc	ra,0xfffff
    800043c6:	0d0080e7          	jalr	208(ra) # 80003492 <brelse>
}
    800043ca:	60e2                	ld	ra,24(sp)
    800043cc:	6442                	ld	s0,16(sp)
    800043ce:	64a2                	ld	s1,8(sp)
    800043d0:	6902                	ld	s2,0(sp)
    800043d2:	6105                	addi	sp,sp,32
    800043d4:	8082                	ret

00000000800043d6 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800043d6:	0001e797          	auipc	a5,0x1e
    800043da:	dc67a783          	lw	a5,-570(a5) # 8002219c <log+0x2c>
    800043de:	0af05d63          	blez	a5,80004498 <install_trans+0xc2>
{
    800043e2:	7139                	addi	sp,sp,-64
    800043e4:	fc06                	sd	ra,56(sp)
    800043e6:	f822                	sd	s0,48(sp)
    800043e8:	f426                	sd	s1,40(sp)
    800043ea:	f04a                	sd	s2,32(sp)
    800043ec:	ec4e                	sd	s3,24(sp)
    800043ee:	e852                	sd	s4,16(sp)
    800043f0:	e456                	sd	s5,8(sp)
    800043f2:	e05a                	sd	s6,0(sp)
    800043f4:	0080                	addi	s0,sp,64
    800043f6:	8b2a                	mv	s6,a0
    800043f8:	0001ea97          	auipc	s5,0x1e
    800043fc:	da8a8a93          	addi	s5,s5,-600 # 800221a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004400:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004402:	0001e997          	auipc	s3,0x1e
    80004406:	d6e98993          	addi	s3,s3,-658 # 80022170 <log>
    8000440a:	a035                	j	80004436 <install_trans+0x60>
      bunpin(dbuf);
    8000440c:	8526                	mv	a0,s1
    8000440e:	fffff097          	auipc	ra,0xfffff
    80004412:	15e080e7          	jalr	350(ra) # 8000356c <bunpin>
    brelse(lbuf);
    80004416:	854a                	mv	a0,s2
    80004418:	fffff097          	auipc	ra,0xfffff
    8000441c:	07a080e7          	jalr	122(ra) # 80003492 <brelse>
    brelse(dbuf);
    80004420:	8526                	mv	a0,s1
    80004422:	fffff097          	auipc	ra,0xfffff
    80004426:	070080e7          	jalr	112(ra) # 80003492 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000442a:	2a05                	addiw	s4,s4,1
    8000442c:	0a91                	addi	s5,s5,4
    8000442e:	02c9a783          	lw	a5,44(s3)
    80004432:	04fa5963          	bge	s4,a5,80004484 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004436:	0189a583          	lw	a1,24(s3)
    8000443a:	014585bb          	addw	a1,a1,s4
    8000443e:	2585                	addiw	a1,a1,1
    80004440:	0289a503          	lw	a0,40(s3)
    80004444:	fffff097          	auipc	ra,0xfffff
    80004448:	f1e080e7          	jalr	-226(ra) # 80003362 <bread>
    8000444c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000444e:	000aa583          	lw	a1,0(s5)
    80004452:	0289a503          	lw	a0,40(s3)
    80004456:	fffff097          	auipc	ra,0xfffff
    8000445a:	f0c080e7          	jalr	-244(ra) # 80003362 <bread>
    8000445e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004460:	40000613          	li	a2,1024
    80004464:	05890593          	addi	a1,s2,88
    80004468:	05850513          	addi	a0,a0,88
    8000446c:	ffffd097          	auipc	ra,0xffffd
    80004470:	8da080e7          	jalr	-1830(ra) # 80000d46 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004474:	8526                	mv	a0,s1
    80004476:	fffff097          	auipc	ra,0xfffff
    8000447a:	fde080e7          	jalr	-34(ra) # 80003454 <bwrite>
    if(recovering == 0)
    8000447e:	f80b1ce3          	bnez	s6,80004416 <install_trans+0x40>
    80004482:	b769                	j	8000440c <install_trans+0x36>
}
    80004484:	70e2                	ld	ra,56(sp)
    80004486:	7442                	ld	s0,48(sp)
    80004488:	74a2                	ld	s1,40(sp)
    8000448a:	7902                	ld	s2,32(sp)
    8000448c:	69e2                	ld	s3,24(sp)
    8000448e:	6a42                	ld	s4,16(sp)
    80004490:	6aa2                	ld	s5,8(sp)
    80004492:	6b02                	ld	s6,0(sp)
    80004494:	6121                	addi	sp,sp,64
    80004496:	8082                	ret
    80004498:	8082                	ret

000000008000449a <initlog>:
{
    8000449a:	7179                	addi	sp,sp,-48
    8000449c:	f406                	sd	ra,40(sp)
    8000449e:	f022                	sd	s0,32(sp)
    800044a0:	ec26                	sd	s1,24(sp)
    800044a2:	e84a                	sd	s2,16(sp)
    800044a4:	e44e                	sd	s3,8(sp)
    800044a6:	1800                	addi	s0,sp,48
    800044a8:	892a                	mv	s2,a0
    800044aa:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800044ac:	0001e497          	auipc	s1,0x1e
    800044b0:	cc448493          	addi	s1,s1,-828 # 80022170 <log>
    800044b4:	00004597          	auipc	a1,0x4
    800044b8:	31c58593          	addi	a1,a1,796 # 800087d0 <syscallnum+0x198>
    800044bc:	8526                	mv	a0,s1
    800044be:	ffffc097          	auipc	ra,0xffffc
    800044c2:	69c080e7          	jalr	1692(ra) # 80000b5a <initlock>
  log.start = sb->logstart;
    800044c6:	0149a583          	lw	a1,20(s3)
    800044ca:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800044cc:	0109a783          	lw	a5,16(s3)
    800044d0:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800044d2:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800044d6:	854a                	mv	a0,s2
    800044d8:	fffff097          	auipc	ra,0xfffff
    800044dc:	e8a080e7          	jalr	-374(ra) # 80003362 <bread>
  log.lh.n = lh->n;
    800044e0:	4d3c                	lw	a5,88(a0)
    800044e2:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800044e4:	02f05563          	blez	a5,8000450e <initlog+0x74>
    800044e8:	05c50713          	addi	a4,a0,92
    800044ec:	0001e697          	auipc	a3,0x1e
    800044f0:	cb468693          	addi	a3,a3,-844 # 800221a0 <log+0x30>
    800044f4:	37fd                	addiw	a5,a5,-1
    800044f6:	1782                	slli	a5,a5,0x20
    800044f8:	9381                	srli	a5,a5,0x20
    800044fa:	078a                	slli	a5,a5,0x2
    800044fc:	06050613          	addi	a2,a0,96
    80004500:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80004502:	4310                	lw	a2,0(a4)
    80004504:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80004506:	0711                	addi	a4,a4,4
    80004508:	0691                	addi	a3,a3,4
    8000450a:	fef71ce3          	bne	a4,a5,80004502 <initlog+0x68>
  brelse(buf);
    8000450e:	fffff097          	auipc	ra,0xfffff
    80004512:	f84080e7          	jalr	-124(ra) # 80003492 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004516:	4505                	li	a0,1
    80004518:	00000097          	auipc	ra,0x0
    8000451c:	ebe080e7          	jalr	-322(ra) # 800043d6 <install_trans>
  log.lh.n = 0;
    80004520:	0001e797          	auipc	a5,0x1e
    80004524:	c607ae23          	sw	zero,-900(a5) # 8002219c <log+0x2c>
  write_head(); // clear the log
    80004528:	00000097          	auipc	ra,0x0
    8000452c:	e34080e7          	jalr	-460(ra) # 8000435c <write_head>
}
    80004530:	70a2                	ld	ra,40(sp)
    80004532:	7402                	ld	s0,32(sp)
    80004534:	64e2                	ld	s1,24(sp)
    80004536:	6942                	ld	s2,16(sp)
    80004538:	69a2                	ld	s3,8(sp)
    8000453a:	6145                	addi	sp,sp,48
    8000453c:	8082                	ret

000000008000453e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000453e:	1101                	addi	sp,sp,-32
    80004540:	ec06                	sd	ra,24(sp)
    80004542:	e822                	sd	s0,16(sp)
    80004544:	e426                	sd	s1,8(sp)
    80004546:	e04a                	sd	s2,0(sp)
    80004548:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000454a:	0001e517          	auipc	a0,0x1e
    8000454e:	c2650513          	addi	a0,a0,-986 # 80022170 <log>
    80004552:	ffffc097          	auipc	ra,0xffffc
    80004556:	698080e7          	jalr	1688(ra) # 80000bea <acquire>
  while(1){
    if(log.committing){
    8000455a:	0001e497          	auipc	s1,0x1e
    8000455e:	c1648493          	addi	s1,s1,-1002 # 80022170 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004562:	4979                	li	s2,30
    80004564:	a039                	j	80004572 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004566:	85a6                	mv	a1,s1
    80004568:	8526                	mv	a0,s1
    8000456a:	ffffe097          	auipc	ra,0xffffe
    8000456e:	c1e080e7          	jalr	-994(ra) # 80002188 <sleep>
    if(log.committing){
    80004572:	50dc                	lw	a5,36(s1)
    80004574:	fbed                	bnez	a5,80004566 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004576:	509c                	lw	a5,32(s1)
    80004578:	0017871b          	addiw	a4,a5,1
    8000457c:	0007069b          	sext.w	a3,a4
    80004580:	0027179b          	slliw	a5,a4,0x2
    80004584:	9fb9                	addw	a5,a5,a4
    80004586:	0017979b          	slliw	a5,a5,0x1
    8000458a:	54d8                	lw	a4,44(s1)
    8000458c:	9fb9                	addw	a5,a5,a4
    8000458e:	00f95963          	bge	s2,a5,800045a0 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004592:	85a6                	mv	a1,s1
    80004594:	8526                	mv	a0,s1
    80004596:	ffffe097          	auipc	ra,0xffffe
    8000459a:	bf2080e7          	jalr	-1038(ra) # 80002188 <sleep>
    8000459e:	bfd1                	j	80004572 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800045a0:	0001e517          	auipc	a0,0x1e
    800045a4:	bd050513          	addi	a0,a0,-1072 # 80022170 <log>
    800045a8:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800045aa:	ffffc097          	auipc	ra,0xffffc
    800045ae:	6f4080e7          	jalr	1780(ra) # 80000c9e <release>
      break;
    }
  }
}
    800045b2:	60e2                	ld	ra,24(sp)
    800045b4:	6442                	ld	s0,16(sp)
    800045b6:	64a2                	ld	s1,8(sp)
    800045b8:	6902                	ld	s2,0(sp)
    800045ba:	6105                	addi	sp,sp,32
    800045bc:	8082                	ret

00000000800045be <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800045be:	7139                	addi	sp,sp,-64
    800045c0:	fc06                	sd	ra,56(sp)
    800045c2:	f822                	sd	s0,48(sp)
    800045c4:	f426                	sd	s1,40(sp)
    800045c6:	f04a                	sd	s2,32(sp)
    800045c8:	ec4e                	sd	s3,24(sp)
    800045ca:	e852                	sd	s4,16(sp)
    800045cc:	e456                	sd	s5,8(sp)
    800045ce:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800045d0:	0001e497          	auipc	s1,0x1e
    800045d4:	ba048493          	addi	s1,s1,-1120 # 80022170 <log>
    800045d8:	8526                	mv	a0,s1
    800045da:	ffffc097          	auipc	ra,0xffffc
    800045de:	610080e7          	jalr	1552(ra) # 80000bea <acquire>
  log.outstanding -= 1;
    800045e2:	509c                	lw	a5,32(s1)
    800045e4:	37fd                	addiw	a5,a5,-1
    800045e6:	0007891b          	sext.w	s2,a5
    800045ea:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800045ec:	50dc                	lw	a5,36(s1)
    800045ee:	efb9                	bnez	a5,8000464c <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    800045f0:	06091663          	bnez	s2,8000465c <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    800045f4:	0001e497          	auipc	s1,0x1e
    800045f8:	b7c48493          	addi	s1,s1,-1156 # 80022170 <log>
    800045fc:	4785                	li	a5,1
    800045fe:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004600:	8526                	mv	a0,s1
    80004602:	ffffc097          	auipc	ra,0xffffc
    80004606:	69c080e7          	jalr	1692(ra) # 80000c9e <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000460a:	54dc                	lw	a5,44(s1)
    8000460c:	06f04763          	bgtz	a5,8000467a <end_op+0xbc>
    acquire(&log.lock);
    80004610:	0001e497          	auipc	s1,0x1e
    80004614:	b6048493          	addi	s1,s1,-1184 # 80022170 <log>
    80004618:	8526                	mv	a0,s1
    8000461a:	ffffc097          	auipc	ra,0xffffc
    8000461e:	5d0080e7          	jalr	1488(ra) # 80000bea <acquire>
    log.committing = 0;
    80004622:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004626:	8526                	mv	a0,s1
    80004628:	ffffe097          	auipc	ra,0xffffe
    8000462c:	d10080e7          	jalr	-752(ra) # 80002338 <wakeup>
    release(&log.lock);
    80004630:	8526                	mv	a0,s1
    80004632:	ffffc097          	auipc	ra,0xffffc
    80004636:	66c080e7          	jalr	1644(ra) # 80000c9e <release>
}
    8000463a:	70e2                	ld	ra,56(sp)
    8000463c:	7442                	ld	s0,48(sp)
    8000463e:	74a2                	ld	s1,40(sp)
    80004640:	7902                	ld	s2,32(sp)
    80004642:	69e2                	ld	s3,24(sp)
    80004644:	6a42                	ld	s4,16(sp)
    80004646:	6aa2                	ld	s5,8(sp)
    80004648:	6121                	addi	sp,sp,64
    8000464a:	8082                	ret
    panic("log.committing");
    8000464c:	00004517          	auipc	a0,0x4
    80004650:	18c50513          	addi	a0,a0,396 # 800087d8 <syscallnum+0x1a0>
    80004654:	ffffc097          	auipc	ra,0xffffc
    80004658:	ef0080e7          	jalr	-272(ra) # 80000544 <panic>
    wakeup(&log);
    8000465c:	0001e497          	auipc	s1,0x1e
    80004660:	b1448493          	addi	s1,s1,-1260 # 80022170 <log>
    80004664:	8526                	mv	a0,s1
    80004666:	ffffe097          	auipc	ra,0xffffe
    8000466a:	cd2080e7          	jalr	-814(ra) # 80002338 <wakeup>
  release(&log.lock);
    8000466e:	8526                	mv	a0,s1
    80004670:	ffffc097          	auipc	ra,0xffffc
    80004674:	62e080e7          	jalr	1582(ra) # 80000c9e <release>
  if(do_commit){
    80004678:	b7c9                	j	8000463a <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000467a:	0001ea97          	auipc	s5,0x1e
    8000467e:	b26a8a93          	addi	s5,s5,-1242 # 800221a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004682:	0001ea17          	auipc	s4,0x1e
    80004686:	aeea0a13          	addi	s4,s4,-1298 # 80022170 <log>
    8000468a:	018a2583          	lw	a1,24(s4)
    8000468e:	012585bb          	addw	a1,a1,s2
    80004692:	2585                	addiw	a1,a1,1
    80004694:	028a2503          	lw	a0,40(s4)
    80004698:	fffff097          	auipc	ra,0xfffff
    8000469c:	cca080e7          	jalr	-822(ra) # 80003362 <bread>
    800046a0:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800046a2:	000aa583          	lw	a1,0(s5)
    800046a6:	028a2503          	lw	a0,40(s4)
    800046aa:	fffff097          	auipc	ra,0xfffff
    800046ae:	cb8080e7          	jalr	-840(ra) # 80003362 <bread>
    800046b2:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800046b4:	40000613          	li	a2,1024
    800046b8:	05850593          	addi	a1,a0,88
    800046bc:	05848513          	addi	a0,s1,88
    800046c0:	ffffc097          	auipc	ra,0xffffc
    800046c4:	686080e7          	jalr	1670(ra) # 80000d46 <memmove>
    bwrite(to);  // write the log
    800046c8:	8526                	mv	a0,s1
    800046ca:	fffff097          	auipc	ra,0xfffff
    800046ce:	d8a080e7          	jalr	-630(ra) # 80003454 <bwrite>
    brelse(from);
    800046d2:	854e                	mv	a0,s3
    800046d4:	fffff097          	auipc	ra,0xfffff
    800046d8:	dbe080e7          	jalr	-578(ra) # 80003492 <brelse>
    brelse(to);
    800046dc:	8526                	mv	a0,s1
    800046de:	fffff097          	auipc	ra,0xfffff
    800046e2:	db4080e7          	jalr	-588(ra) # 80003492 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800046e6:	2905                	addiw	s2,s2,1
    800046e8:	0a91                	addi	s5,s5,4
    800046ea:	02ca2783          	lw	a5,44(s4)
    800046ee:	f8f94ee3          	blt	s2,a5,8000468a <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800046f2:	00000097          	auipc	ra,0x0
    800046f6:	c6a080e7          	jalr	-918(ra) # 8000435c <write_head>
    install_trans(0); // Now install writes to home locations
    800046fa:	4501                	li	a0,0
    800046fc:	00000097          	auipc	ra,0x0
    80004700:	cda080e7          	jalr	-806(ra) # 800043d6 <install_trans>
    log.lh.n = 0;
    80004704:	0001e797          	auipc	a5,0x1e
    80004708:	a807ac23          	sw	zero,-1384(a5) # 8002219c <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000470c:	00000097          	auipc	ra,0x0
    80004710:	c50080e7          	jalr	-944(ra) # 8000435c <write_head>
    80004714:	bdf5                	j	80004610 <end_op+0x52>

0000000080004716 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004716:	1101                	addi	sp,sp,-32
    80004718:	ec06                	sd	ra,24(sp)
    8000471a:	e822                	sd	s0,16(sp)
    8000471c:	e426                	sd	s1,8(sp)
    8000471e:	e04a                	sd	s2,0(sp)
    80004720:	1000                	addi	s0,sp,32
    80004722:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004724:	0001e917          	auipc	s2,0x1e
    80004728:	a4c90913          	addi	s2,s2,-1460 # 80022170 <log>
    8000472c:	854a                	mv	a0,s2
    8000472e:	ffffc097          	auipc	ra,0xffffc
    80004732:	4bc080e7          	jalr	1212(ra) # 80000bea <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004736:	02c92603          	lw	a2,44(s2)
    8000473a:	47f5                	li	a5,29
    8000473c:	06c7c563          	blt	a5,a2,800047a6 <log_write+0x90>
    80004740:	0001e797          	auipc	a5,0x1e
    80004744:	a4c7a783          	lw	a5,-1460(a5) # 8002218c <log+0x1c>
    80004748:	37fd                	addiw	a5,a5,-1
    8000474a:	04f65e63          	bge	a2,a5,800047a6 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000474e:	0001e797          	auipc	a5,0x1e
    80004752:	a427a783          	lw	a5,-1470(a5) # 80022190 <log+0x20>
    80004756:	06f05063          	blez	a5,800047b6 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000475a:	4781                	li	a5,0
    8000475c:	06c05563          	blez	a2,800047c6 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004760:	44cc                	lw	a1,12(s1)
    80004762:	0001e717          	auipc	a4,0x1e
    80004766:	a3e70713          	addi	a4,a4,-1474 # 800221a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000476a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000476c:	4314                	lw	a3,0(a4)
    8000476e:	04b68c63          	beq	a3,a1,800047c6 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004772:	2785                	addiw	a5,a5,1
    80004774:	0711                	addi	a4,a4,4
    80004776:	fef61be3          	bne	a2,a5,8000476c <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000477a:	0621                	addi	a2,a2,8
    8000477c:	060a                	slli	a2,a2,0x2
    8000477e:	0001e797          	auipc	a5,0x1e
    80004782:	9f278793          	addi	a5,a5,-1550 # 80022170 <log>
    80004786:	963e                	add	a2,a2,a5
    80004788:	44dc                	lw	a5,12(s1)
    8000478a:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000478c:	8526                	mv	a0,s1
    8000478e:	fffff097          	auipc	ra,0xfffff
    80004792:	da2080e7          	jalr	-606(ra) # 80003530 <bpin>
    log.lh.n++;
    80004796:	0001e717          	auipc	a4,0x1e
    8000479a:	9da70713          	addi	a4,a4,-1574 # 80022170 <log>
    8000479e:	575c                	lw	a5,44(a4)
    800047a0:	2785                	addiw	a5,a5,1
    800047a2:	d75c                	sw	a5,44(a4)
    800047a4:	a835                	j	800047e0 <log_write+0xca>
    panic("too big a transaction");
    800047a6:	00004517          	auipc	a0,0x4
    800047aa:	04250513          	addi	a0,a0,66 # 800087e8 <syscallnum+0x1b0>
    800047ae:	ffffc097          	auipc	ra,0xffffc
    800047b2:	d96080e7          	jalr	-618(ra) # 80000544 <panic>
    panic("log_write outside of trans");
    800047b6:	00004517          	auipc	a0,0x4
    800047ba:	04a50513          	addi	a0,a0,74 # 80008800 <syscallnum+0x1c8>
    800047be:	ffffc097          	auipc	ra,0xffffc
    800047c2:	d86080e7          	jalr	-634(ra) # 80000544 <panic>
  log.lh.block[i] = b->blockno;
    800047c6:	00878713          	addi	a4,a5,8
    800047ca:	00271693          	slli	a3,a4,0x2
    800047ce:	0001e717          	auipc	a4,0x1e
    800047d2:	9a270713          	addi	a4,a4,-1630 # 80022170 <log>
    800047d6:	9736                	add	a4,a4,a3
    800047d8:	44d4                	lw	a3,12(s1)
    800047da:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800047dc:	faf608e3          	beq	a2,a5,8000478c <log_write+0x76>
  }
  release(&log.lock);
    800047e0:	0001e517          	auipc	a0,0x1e
    800047e4:	99050513          	addi	a0,a0,-1648 # 80022170 <log>
    800047e8:	ffffc097          	auipc	ra,0xffffc
    800047ec:	4b6080e7          	jalr	1206(ra) # 80000c9e <release>
}
    800047f0:	60e2                	ld	ra,24(sp)
    800047f2:	6442                	ld	s0,16(sp)
    800047f4:	64a2                	ld	s1,8(sp)
    800047f6:	6902                	ld	s2,0(sp)
    800047f8:	6105                	addi	sp,sp,32
    800047fa:	8082                	ret

00000000800047fc <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800047fc:	1101                	addi	sp,sp,-32
    800047fe:	ec06                	sd	ra,24(sp)
    80004800:	e822                	sd	s0,16(sp)
    80004802:	e426                	sd	s1,8(sp)
    80004804:	e04a                	sd	s2,0(sp)
    80004806:	1000                	addi	s0,sp,32
    80004808:	84aa                	mv	s1,a0
    8000480a:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000480c:	00004597          	auipc	a1,0x4
    80004810:	01458593          	addi	a1,a1,20 # 80008820 <syscallnum+0x1e8>
    80004814:	0521                	addi	a0,a0,8
    80004816:	ffffc097          	auipc	ra,0xffffc
    8000481a:	344080e7          	jalr	836(ra) # 80000b5a <initlock>
  lk->name = name;
    8000481e:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004822:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004826:	0204a423          	sw	zero,40(s1)
}
    8000482a:	60e2                	ld	ra,24(sp)
    8000482c:	6442                	ld	s0,16(sp)
    8000482e:	64a2                	ld	s1,8(sp)
    80004830:	6902                	ld	s2,0(sp)
    80004832:	6105                	addi	sp,sp,32
    80004834:	8082                	ret

0000000080004836 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004836:	1101                	addi	sp,sp,-32
    80004838:	ec06                	sd	ra,24(sp)
    8000483a:	e822                	sd	s0,16(sp)
    8000483c:	e426                	sd	s1,8(sp)
    8000483e:	e04a                	sd	s2,0(sp)
    80004840:	1000                	addi	s0,sp,32
    80004842:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004844:	00850913          	addi	s2,a0,8
    80004848:	854a                	mv	a0,s2
    8000484a:	ffffc097          	auipc	ra,0xffffc
    8000484e:	3a0080e7          	jalr	928(ra) # 80000bea <acquire>
  while (lk->locked) {
    80004852:	409c                	lw	a5,0(s1)
    80004854:	cb89                	beqz	a5,80004866 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004856:	85ca                	mv	a1,s2
    80004858:	8526                	mv	a0,s1
    8000485a:	ffffe097          	auipc	ra,0xffffe
    8000485e:	92e080e7          	jalr	-1746(ra) # 80002188 <sleep>
  while (lk->locked) {
    80004862:	409c                	lw	a5,0(s1)
    80004864:	fbed                	bnez	a5,80004856 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004866:	4785                	li	a5,1
    80004868:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000486a:	ffffd097          	auipc	ra,0xffffd
    8000486e:	15c080e7          	jalr	348(ra) # 800019c6 <myproc>
    80004872:	591c                	lw	a5,48(a0)
    80004874:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004876:	854a                	mv	a0,s2
    80004878:	ffffc097          	auipc	ra,0xffffc
    8000487c:	426080e7          	jalr	1062(ra) # 80000c9e <release>
}
    80004880:	60e2                	ld	ra,24(sp)
    80004882:	6442                	ld	s0,16(sp)
    80004884:	64a2                	ld	s1,8(sp)
    80004886:	6902                	ld	s2,0(sp)
    80004888:	6105                	addi	sp,sp,32
    8000488a:	8082                	ret

000000008000488c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000488c:	1101                	addi	sp,sp,-32
    8000488e:	ec06                	sd	ra,24(sp)
    80004890:	e822                	sd	s0,16(sp)
    80004892:	e426                	sd	s1,8(sp)
    80004894:	e04a                	sd	s2,0(sp)
    80004896:	1000                	addi	s0,sp,32
    80004898:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000489a:	00850913          	addi	s2,a0,8
    8000489e:	854a                	mv	a0,s2
    800048a0:	ffffc097          	auipc	ra,0xffffc
    800048a4:	34a080e7          	jalr	842(ra) # 80000bea <acquire>
  lk->locked = 0;
    800048a8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800048ac:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800048b0:	8526                	mv	a0,s1
    800048b2:	ffffe097          	auipc	ra,0xffffe
    800048b6:	a86080e7          	jalr	-1402(ra) # 80002338 <wakeup>
  release(&lk->lk);
    800048ba:	854a                	mv	a0,s2
    800048bc:	ffffc097          	auipc	ra,0xffffc
    800048c0:	3e2080e7          	jalr	994(ra) # 80000c9e <release>
}
    800048c4:	60e2                	ld	ra,24(sp)
    800048c6:	6442                	ld	s0,16(sp)
    800048c8:	64a2                	ld	s1,8(sp)
    800048ca:	6902                	ld	s2,0(sp)
    800048cc:	6105                	addi	sp,sp,32
    800048ce:	8082                	ret

00000000800048d0 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800048d0:	7179                	addi	sp,sp,-48
    800048d2:	f406                	sd	ra,40(sp)
    800048d4:	f022                	sd	s0,32(sp)
    800048d6:	ec26                	sd	s1,24(sp)
    800048d8:	e84a                	sd	s2,16(sp)
    800048da:	e44e                	sd	s3,8(sp)
    800048dc:	1800                	addi	s0,sp,48
    800048de:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800048e0:	00850913          	addi	s2,a0,8
    800048e4:	854a                	mv	a0,s2
    800048e6:	ffffc097          	auipc	ra,0xffffc
    800048ea:	304080e7          	jalr	772(ra) # 80000bea <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800048ee:	409c                	lw	a5,0(s1)
    800048f0:	ef99                	bnez	a5,8000490e <holdingsleep+0x3e>
    800048f2:	4481                	li	s1,0
  release(&lk->lk);
    800048f4:	854a                	mv	a0,s2
    800048f6:	ffffc097          	auipc	ra,0xffffc
    800048fa:	3a8080e7          	jalr	936(ra) # 80000c9e <release>
  return r;
}
    800048fe:	8526                	mv	a0,s1
    80004900:	70a2                	ld	ra,40(sp)
    80004902:	7402                	ld	s0,32(sp)
    80004904:	64e2                	ld	s1,24(sp)
    80004906:	6942                	ld	s2,16(sp)
    80004908:	69a2                	ld	s3,8(sp)
    8000490a:	6145                	addi	sp,sp,48
    8000490c:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000490e:	0284a983          	lw	s3,40(s1)
    80004912:	ffffd097          	auipc	ra,0xffffd
    80004916:	0b4080e7          	jalr	180(ra) # 800019c6 <myproc>
    8000491a:	5904                	lw	s1,48(a0)
    8000491c:	413484b3          	sub	s1,s1,s3
    80004920:	0014b493          	seqz	s1,s1
    80004924:	bfc1                	j	800048f4 <holdingsleep+0x24>

0000000080004926 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004926:	1141                	addi	sp,sp,-16
    80004928:	e406                	sd	ra,8(sp)
    8000492a:	e022                	sd	s0,0(sp)
    8000492c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000492e:	00004597          	auipc	a1,0x4
    80004932:	f0258593          	addi	a1,a1,-254 # 80008830 <syscallnum+0x1f8>
    80004936:	0001e517          	auipc	a0,0x1e
    8000493a:	98250513          	addi	a0,a0,-1662 # 800222b8 <ftable>
    8000493e:	ffffc097          	auipc	ra,0xffffc
    80004942:	21c080e7          	jalr	540(ra) # 80000b5a <initlock>
}
    80004946:	60a2                	ld	ra,8(sp)
    80004948:	6402                	ld	s0,0(sp)
    8000494a:	0141                	addi	sp,sp,16
    8000494c:	8082                	ret

000000008000494e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000494e:	1101                	addi	sp,sp,-32
    80004950:	ec06                	sd	ra,24(sp)
    80004952:	e822                	sd	s0,16(sp)
    80004954:	e426                	sd	s1,8(sp)
    80004956:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004958:	0001e517          	auipc	a0,0x1e
    8000495c:	96050513          	addi	a0,a0,-1696 # 800222b8 <ftable>
    80004960:	ffffc097          	auipc	ra,0xffffc
    80004964:	28a080e7          	jalr	650(ra) # 80000bea <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004968:	0001e497          	auipc	s1,0x1e
    8000496c:	96848493          	addi	s1,s1,-1688 # 800222d0 <ftable+0x18>
    80004970:	0001f717          	auipc	a4,0x1f
    80004974:	90070713          	addi	a4,a4,-1792 # 80023270 <disk>
    if(f->ref == 0){
    80004978:	40dc                	lw	a5,4(s1)
    8000497a:	cf99                	beqz	a5,80004998 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000497c:	02848493          	addi	s1,s1,40
    80004980:	fee49ce3          	bne	s1,a4,80004978 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004984:	0001e517          	auipc	a0,0x1e
    80004988:	93450513          	addi	a0,a0,-1740 # 800222b8 <ftable>
    8000498c:	ffffc097          	auipc	ra,0xffffc
    80004990:	312080e7          	jalr	786(ra) # 80000c9e <release>
  return 0;
    80004994:	4481                	li	s1,0
    80004996:	a819                	j	800049ac <filealloc+0x5e>
      f->ref = 1;
    80004998:	4785                	li	a5,1
    8000499a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000499c:	0001e517          	auipc	a0,0x1e
    800049a0:	91c50513          	addi	a0,a0,-1764 # 800222b8 <ftable>
    800049a4:	ffffc097          	auipc	ra,0xffffc
    800049a8:	2fa080e7          	jalr	762(ra) # 80000c9e <release>
}
    800049ac:	8526                	mv	a0,s1
    800049ae:	60e2                	ld	ra,24(sp)
    800049b0:	6442                	ld	s0,16(sp)
    800049b2:	64a2                	ld	s1,8(sp)
    800049b4:	6105                	addi	sp,sp,32
    800049b6:	8082                	ret

00000000800049b8 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800049b8:	1101                	addi	sp,sp,-32
    800049ba:	ec06                	sd	ra,24(sp)
    800049bc:	e822                	sd	s0,16(sp)
    800049be:	e426                	sd	s1,8(sp)
    800049c0:	1000                	addi	s0,sp,32
    800049c2:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800049c4:	0001e517          	auipc	a0,0x1e
    800049c8:	8f450513          	addi	a0,a0,-1804 # 800222b8 <ftable>
    800049cc:	ffffc097          	auipc	ra,0xffffc
    800049d0:	21e080e7          	jalr	542(ra) # 80000bea <acquire>
  if(f->ref < 1)
    800049d4:	40dc                	lw	a5,4(s1)
    800049d6:	02f05263          	blez	a5,800049fa <filedup+0x42>
    panic("filedup");
  f->ref++;
    800049da:	2785                	addiw	a5,a5,1
    800049dc:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800049de:	0001e517          	auipc	a0,0x1e
    800049e2:	8da50513          	addi	a0,a0,-1830 # 800222b8 <ftable>
    800049e6:	ffffc097          	auipc	ra,0xffffc
    800049ea:	2b8080e7          	jalr	696(ra) # 80000c9e <release>
  return f;
}
    800049ee:	8526                	mv	a0,s1
    800049f0:	60e2                	ld	ra,24(sp)
    800049f2:	6442                	ld	s0,16(sp)
    800049f4:	64a2                	ld	s1,8(sp)
    800049f6:	6105                	addi	sp,sp,32
    800049f8:	8082                	ret
    panic("filedup");
    800049fa:	00004517          	auipc	a0,0x4
    800049fe:	e3e50513          	addi	a0,a0,-450 # 80008838 <syscallnum+0x200>
    80004a02:	ffffc097          	auipc	ra,0xffffc
    80004a06:	b42080e7          	jalr	-1214(ra) # 80000544 <panic>

0000000080004a0a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004a0a:	7139                	addi	sp,sp,-64
    80004a0c:	fc06                	sd	ra,56(sp)
    80004a0e:	f822                	sd	s0,48(sp)
    80004a10:	f426                	sd	s1,40(sp)
    80004a12:	f04a                	sd	s2,32(sp)
    80004a14:	ec4e                	sd	s3,24(sp)
    80004a16:	e852                	sd	s4,16(sp)
    80004a18:	e456                	sd	s5,8(sp)
    80004a1a:	0080                	addi	s0,sp,64
    80004a1c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004a1e:	0001e517          	auipc	a0,0x1e
    80004a22:	89a50513          	addi	a0,a0,-1894 # 800222b8 <ftable>
    80004a26:	ffffc097          	auipc	ra,0xffffc
    80004a2a:	1c4080e7          	jalr	452(ra) # 80000bea <acquire>
  if(f->ref < 1)
    80004a2e:	40dc                	lw	a5,4(s1)
    80004a30:	06f05163          	blez	a5,80004a92 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004a34:	37fd                	addiw	a5,a5,-1
    80004a36:	0007871b          	sext.w	a4,a5
    80004a3a:	c0dc                	sw	a5,4(s1)
    80004a3c:	06e04363          	bgtz	a4,80004aa2 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004a40:	0004a903          	lw	s2,0(s1)
    80004a44:	0094ca83          	lbu	s5,9(s1)
    80004a48:	0104ba03          	ld	s4,16(s1)
    80004a4c:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004a50:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004a54:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004a58:	0001e517          	auipc	a0,0x1e
    80004a5c:	86050513          	addi	a0,a0,-1952 # 800222b8 <ftable>
    80004a60:	ffffc097          	auipc	ra,0xffffc
    80004a64:	23e080e7          	jalr	574(ra) # 80000c9e <release>

  if(ff.type == FD_PIPE){
    80004a68:	4785                	li	a5,1
    80004a6a:	04f90d63          	beq	s2,a5,80004ac4 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004a6e:	3979                	addiw	s2,s2,-2
    80004a70:	4785                	li	a5,1
    80004a72:	0527e063          	bltu	a5,s2,80004ab2 <fileclose+0xa8>
    begin_op();
    80004a76:	00000097          	auipc	ra,0x0
    80004a7a:	ac8080e7          	jalr	-1336(ra) # 8000453e <begin_op>
    iput(ff.ip);
    80004a7e:	854e                	mv	a0,s3
    80004a80:	fffff097          	auipc	ra,0xfffff
    80004a84:	2b6080e7          	jalr	694(ra) # 80003d36 <iput>
    end_op();
    80004a88:	00000097          	auipc	ra,0x0
    80004a8c:	b36080e7          	jalr	-1226(ra) # 800045be <end_op>
    80004a90:	a00d                	j	80004ab2 <fileclose+0xa8>
    panic("fileclose");
    80004a92:	00004517          	auipc	a0,0x4
    80004a96:	dae50513          	addi	a0,a0,-594 # 80008840 <syscallnum+0x208>
    80004a9a:	ffffc097          	auipc	ra,0xffffc
    80004a9e:	aaa080e7          	jalr	-1366(ra) # 80000544 <panic>
    release(&ftable.lock);
    80004aa2:	0001e517          	auipc	a0,0x1e
    80004aa6:	81650513          	addi	a0,a0,-2026 # 800222b8 <ftable>
    80004aaa:	ffffc097          	auipc	ra,0xffffc
    80004aae:	1f4080e7          	jalr	500(ra) # 80000c9e <release>
  }
}
    80004ab2:	70e2                	ld	ra,56(sp)
    80004ab4:	7442                	ld	s0,48(sp)
    80004ab6:	74a2                	ld	s1,40(sp)
    80004ab8:	7902                	ld	s2,32(sp)
    80004aba:	69e2                	ld	s3,24(sp)
    80004abc:	6a42                	ld	s4,16(sp)
    80004abe:	6aa2                	ld	s5,8(sp)
    80004ac0:	6121                	addi	sp,sp,64
    80004ac2:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004ac4:	85d6                	mv	a1,s5
    80004ac6:	8552                	mv	a0,s4
    80004ac8:	00000097          	auipc	ra,0x0
    80004acc:	34c080e7          	jalr	844(ra) # 80004e14 <pipeclose>
    80004ad0:	b7cd                	j	80004ab2 <fileclose+0xa8>

0000000080004ad2 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004ad2:	715d                	addi	sp,sp,-80
    80004ad4:	e486                	sd	ra,72(sp)
    80004ad6:	e0a2                	sd	s0,64(sp)
    80004ad8:	fc26                	sd	s1,56(sp)
    80004ada:	f84a                	sd	s2,48(sp)
    80004adc:	f44e                	sd	s3,40(sp)
    80004ade:	0880                	addi	s0,sp,80
    80004ae0:	84aa                	mv	s1,a0
    80004ae2:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004ae4:	ffffd097          	auipc	ra,0xffffd
    80004ae8:	ee2080e7          	jalr	-286(ra) # 800019c6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004aec:	409c                	lw	a5,0(s1)
    80004aee:	37f9                	addiw	a5,a5,-2
    80004af0:	4705                	li	a4,1
    80004af2:	04f76763          	bltu	a4,a5,80004b40 <filestat+0x6e>
    80004af6:	892a                	mv	s2,a0
    ilock(f->ip);
    80004af8:	6c88                	ld	a0,24(s1)
    80004afa:	fffff097          	auipc	ra,0xfffff
    80004afe:	082080e7          	jalr	130(ra) # 80003b7c <ilock>
    stati(f->ip, &st);
    80004b02:	fb840593          	addi	a1,s0,-72
    80004b06:	6c88                	ld	a0,24(s1)
    80004b08:	fffff097          	auipc	ra,0xfffff
    80004b0c:	2fe080e7          	jalr	766(ra) # 80003e06 <stati>
    iunlock(f->ip);
    80004b10:	6c88                	ld	a0,24(s1)
    80004b12:	fffff097          	auipc	ra,0xfffff
    80004b16:	12c080e7          	jalr	300(ra) # 80003c3e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004b1a:	46e1                	li	a3,24
    80004b1c:	fb840613          	addi	a2,s0,-72
    80004b20:	85ce                	mv	a1,s3
    80004b22:	05093503          	ld	a0,80(s2)
    80004b26:	ffffd097          	auipc	ra,0xffffd
    80004b2a:	b5e080e7          	jalr	-1186(ra) # 80001684 <copyout>
    80004b2e:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004b32:	60a6                	ld	ra,72(sp)
    80004b34:	6406                	ld	s0,64(sp)
    80004b36:	74e2                	ld	s1,56(sp)
    80004b38:	7942                	ld	s2,48(sp)
    80004b3a:	79a2                	ld	s3,40(sp)
    80004b3c:	6161                	addi	sp,sp,80
    80004b3e:	8082                	ret
  return -1;
    80004b40:	557d                	li	a0,-1
    80004b42:	bfc5                	j	80004b32 <filestat+0x60>

0000000080004b44 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004b44:	7179                	addi	sp,sp,-48
    80004b46:	f406                	sd	ra,40(sp)
    80004b48:	f022                	sd	s0,32(sp)
    80004b4a:	ec26                	sd	s1,24(sp)
    80004b4c:	e84a                	sd	s2,16(sp)
    80004b4e:	e44e                	sd	s3,8(sp)
    80004b50:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004b52:	00854783          	lbu	a5,8(a0)
    80004b56:	c3d5                	beqz	a5,80004bfa <fileread+0xb6>
    80004b58:	84aa                	mv	s1,a0
    80004b5a:	89ae                	mv	s3,a1
    80004b5c:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004b5e:	411c                	lw	a5,0(a0)
    80004b60:	4705                	li	a4,1
    80004b62:	04e78963          	beq	a5,a4,80004bb4 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004b66:	470d                	li	a4,3
    80004b68:	04e78d63          	beq	a5,a4,80004bc2 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004b6c:	4709                	li	a4,2
    80004b6e:	06e79e63          	bne	a5,a4,80004bea <fileread+0xa6>
    ilock(f->ip);
    80004b72:	6d08                	ld	a0,24(a0)
    80004b74:	fffff097          	auipc	ra,0xfffff
    80004b78:	008080e7          	jalr	8(ra) # 80003b7c <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004b7c:	874a                	mv	a4,s2
    80004b7e:	5094                	lw	a3,32(s1)
    80004b80:	864e                	mv	a2,s3
    80004b82:	4585                	li	a1,1
    80004b84:	6c88                	ld	a0,24(s1)
    80004b86:	fffff097          	auipc	ra,0xfffff
    80004b8a:	2aa080e7          	jalr	682(ra) # 80003e30 <readi>
    80004b8e:	892a                	mv	s2,a0
    80004b90:	00a05563          	blez	a0,80004b9a <fileread+0x56>
      f->off += r;
    80004b94:	509c                	lw	a5,32(s1)
    80004b96:	9fa9                	addw	a5,a5,a0
    80004b98:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004b9a:	6c88                	ld	a0,24(s1)
    80004b9c:	fffff097          	auipc	ra,0xfffff
    80004ba0:	0a2080e7          	jalr	162(ra) # 80003c3e <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004ba4:	854a                	mv	a0,s2
    80004ba6:	70a2                	ld	ra,40(sp)
    80004ba8:	7402                	ld	s0,32(sp)
    80004baa:	64e2                	ld	s1,24(sp)
    80004bac:	6942                	ld	s2,16(sp)
    80004bae:	69a2                	ld	s3,8(sp)
    80004bb0:	6145                	addi	sp,sp,48
    80004bb2:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004bb4:	6908                	ld	a0,16(a0)
    80004bb6:	00000097          	auipc	ra,0x0
    80004bba:	3ce080e7          	jalr	974(ra) # 80004f84 <piperead>
    80004bbe:	892a                	mv	s2,a0
    80004bc0:	b7d5                	j	80004ba4 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004bc2:	02451783          	lh	a5,36(a0)
    80004bc6:	03079693          	slli	a3,a5,0x30
    80004bca:	92c1                	srli	a3,a3,0x30
    80004bcc:	4725                	li	a4,9
    80004bce:	02d76863          	bltu	a4,a3,80004bfe <fileread+0xba>
    80004bd2:	0792                	slli	a5,a5,0x4
    80004bd4:	0001d717          	auipc	a4,0x1d
    80004bd8:	64470713          	addi	a4,a4,1604 # 80022218 <devsw>
    80004bdc:	97ba                	add	a5,a5,a4
    80004bde:	639c                	ld	a5,0(a5)
    80004be0:	c38d                	beqz	a5,80004c02 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004be2:	4505                	li	a0,1
    80004be4:	9782                	jalr	a5
    80004be6:	892a                	mv	s2,a0
    80004be8:	bf75                	j	80004ba4 <fileread+0x60>
    panic("fileread");
    80004bea:	00004517          	auipc	a0,0x4
    80004bee:	c6650513          	addi	a0,a0,-922 # 80008850 <syscallnum+0x218>
    80004bf2:	ffffc097          	auipc	ra,0xffffc
    80004bf6:	952080e7          	jalr	-1710(ra) # 80000544 <panic>
    return -1;
    80004bfa:	597d                	li	s2,-1
    80004bfc:	b765                	j	80004ba4 <fileread+0x60>
      return -1;
    80004bfe:	597d                	li	s2,-1
    80004c00:	b755                	j	80004ba4 <fileread+0x60>
    80004c02:	597d                	li	s2,-1
    80004c04:	b745                	j	80004ba4 <fileread+0x60>

0000000080004c06 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004c06:	715d                	addi	sp,sp,-80
    80004c08:	e486                	sd	ra,72(sp)
    80004c0a:	e0a2                	sd	s0,64(sp)
    80004c0c:	fc26                	sd	s1,56(sp)
    80004c0e:	f84a                	sd	s2,48(sp)
    80004c10:	f44e                	sd	s3,40(sp)
    80004c12:	f052                	sd	s4,32(sp)
    80004c14:	ec56                	sd	s5,24(sp)
    80004c16:	e85a                	sd	s6,16(sp)
    80004c18:	e45e                	sd	s7,8(sp)
    80004c1a:	e062                	sd	s8,0(sp)
    80004c1c:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004c1e:	00954783          	lbu	a5,9(a0)
    80004c22:	10078663          	beqz	a5,80004d2e <filewrite+0x128>
    80004c26:	892a                	mv	s2,a0
    80004c28:	8aae                	mv	s5,a1
    80004c2a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004c2c:	411c                	lw	a5,0(a0)
    80004c2e:	4705                	li	a4,1
    80004c30:	02e78263          	beq	a5,a4,80004c54 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004c34:	470d                	li	a4,3
    80004c36:	02e78663          	beq	a5,a4,80004c62 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c3a:	4709                	li	a4,2
    80004c3c:	0ee79163          	bne	a5,a4,80004d1e <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004c40:	0ac05d63          	blez	a2,80004cfa <filewrite+0xf4>
    int i = 0;
    80004c44:	4981                	li	s3,0
    80004c46:	6b05                	lui	s6,0x1
    80004c48:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004c4c:	6b85                	lui	s7,0x1
    80004c4e:	c00b8b9b          	addiw	s7,s7,-1024
    80004c52:	a861                	j	80004cea <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004c54:	6908                	ld	a0,16(a0)
    80004c56:	00000097          	auipc	ra,0x0
    80004c5a:	22e080e7          	jalr	558(ra) # 80004e84 <pipewrite>
    80004c5e:	8a2a                	mv	s4,a0
    80004c60:	a045                	j	80004d00 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004c62:	02451783          	lh	a5,36(a0)
    80004c66:	03079693          	slli	a3,a5,0x30
    80004c6a:	92c1                	srli	a3,a3,0x30
    80004c6c:	4725                	li	a4,9
    80004c6e:	0cd76263          	bltu	a4,a3,80004d32 <filewrite+0x12c>
    80004c72:	0792                	slli	a5,a5,0x4
    80004c74:	0001d717          	auipc	a4,0x1d
    80004c78:	5a470713          	addi	a4,a4,1444 # 80022218 <devsw>
    80004c7c:	97ba                	add	a5,a5,a4
    80004c7e:	679c                	ld	a5,8(a5)
    80004c80:	cbdd                	beqz	a5,80004d36 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004c82:	4505                	li	a0,1
    80004c84:	9782                	jalr	a5
    80004c86:	8a2a                	mv	s4,a0
    80004c88:	a8a5                	j	80004d00 <filewrite+0xfa>
    80004c8a:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004c8e:	00000097          	auipc	ra,0x0
    80004c92:	8b0080e7          	jalr	-1872(ra) # 8000453e <begin_op>
      ilock(f->ip);
    80004c96:	01893503          	ld	a0,24(s2)
    80004c9a:	fffff097          	auipc	ra,0xfffff
    80004c9e:	ee2080e7          	jalr	-286(ra) # 80003b7c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004ca2:	8762                	mv	a4,s8
    80004ca4:	02092683          	lw	a3,32(s2)
    80004ca8:	01598633          	add	a2,s3,s5
    80004cac:	4585                	li	a1,1
    80004cae:	01893503          	ld	a0,24(s2)
    80004cb2:	fffff097          	auipc	ra,0xfffff
    80004cb6:	276080e7          	jalr	630(ra) # 80003f28 <writei>
    80004cba:	84aa                	mv	s1,a0
    80004cbc:	00a05763          	blez	a0,80004cca <filewrite+0xc4>
        f->off += r;
    80004cc0:	02092783          	lw	a5,32(s2)
    80004cc4:	9fa9                	addw	a5,a5,a0
    80004cc6:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004cca:	01893503          	ld	a0,24(s2)
    80004cce:	fffff097          	auipc	ra,0xfffff
    80004cd2:	f70080e7          	jalr	-144(ra) # 80003c3e <iunlock>
      end_op();
    80004cd6:	00000097          	auipc	ra,0x0
    80004cda:	8e8080e7          	jalr	-1816(ra) # 800045be <end_op>

      if(r != n1){
    80004cde:	009c1f63          	bne	s8,s1,80004cfc <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004ce2:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004ce6:	0149db63          	bge	s3,s4,80004cfc <filewrite+0xf6>
      int n1 = n - i;
    80004cea:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004cee:	84be                	mv	s1,a5
    80004cf0:	2781                	sext.w	a5,a5
    80004cf2:	f8fb5ce3          	bge	s6,a5,80004c8a <filewrite+0x84>
    80004cf6:	84de                	mv	s1,s7
    80004cf8:	bf49                	j	80004c8a <filewrite+0x84>
    int i = 0;
    80004cfa:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004cfc:	013a1f63          	bne	s4,s3,80004d1a <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004d00:	8552                	mv	a0,s4
    80004d02:	60a6                	ld	ra,72(sp)
    80004d04:	6406                	ld	s0,64(sp)
    80004d06:	74e2                	ld	s1,56(sp)
    80004d08:	7942                	ld	s2,48(sp)
    80004d0a:	79a2                	ld	s3,40(sp)
    80004d0c:	7a02                	ld	s4,32(sp)
    80004d0e:	6ae2                	ld	s5,24(sp)
    80004d10:	6b42                	ld	s6,16(sp)
    80004d12:	6ba2                	ld	s7,8(sp)
    80004d14:	6c02                	ld	s8,0(sp)
    80004d16:	6161                	addi	sp,sp,80
    80004d18:	8082                	ret
    ret = (i == n ? n : -1);
    80004d1a:	5a7d                	li	s4,-1
    80004d1c:	b7d5                	j	80004d00 <filewrite+0xfa>
    panic("filewrite");
    80004d1e:	00004517          	auipc	a0,0x4
    80004d22:	b4250513          	addi	a0,a0,-1214 # 80008860 <syscallnum+0x228>
    80004d26:	ffffc097          	auipc	ra,0xffffc
    80004d2a:	81e080e7          	jalr	-2018(ra) # 80000544 <panic>
    return -1;
    80004d2e:	5a7d                	li	s4,-1
    80004d30:	bfc1                	j	80004d00 <filewrite+0xfa>
      return -1;
    80004d32:	5a7d                	li	s4,-1
    80004d34:	b7f1                	j	80004d00 <filewrite+0xfa>
    80004d36:	5a7d                	li	s4,-1
    80004d38:	b7e1                	j	80004d00 <filewrite+0xfa>

0000000080004d3a <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004d3a:	7179                	addi	sp,sp,-48
    80004d3c:	f406                	sd	ra,40(sp)
    80004d3e:	f022                	sd	s0,32(sp)
    80004d40:	ec26                	sd	s1,24(sp)
    80004d42:	e84a                	sd	s2,16(sp)
    80004d44:	e44e                	sd	s3,8(sp)
    80004d46:	e052                	sd	s4,0(sp)
    80004d48:	1800                	addi	s0,sp,48
    80004d4a:	84aa                	mv	s1,a0
    80004d4c:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004d4e:	0005b023          	sd	zero,0(a1)
    80004d52:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004d56:	00000097          	auipc	ra,0x0
    80004d5a:	bf8080e7          	jalr	-1032(ra) # 8000494e <filealloc>
    80004d5e:	e088                	sd	a0,0(s1)
    80004d60:	c551                	beqz	a0,80004dec <pipealloc+0xb2>
    80004d62:	00000097          	auipc	ra,0x0
    80004d66:	bec080e7          	jalr	-1044(ra) # 8000494e <filealloc>
    80004d6a:	00aa3023          	sd	a0,0(s4)
    80004d6e:	c92d                	beqz	a0,80004de0 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004d70:	ffffc097          	auipc	ra,0xffffc
    80004d74:	d8a080e7          	jalr	-630(ra) # 80000afa <kalloc>
    80004d78:	892a                	mv	s2,a0
    80004d7a:	c125                	beqz	a0,80004dda <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004d7c:	4985                	li	s3,1
    80004d7e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004d82:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004d86:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004d8a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004d8e:	00003597          	auipc	a1,0x3
    80004d92:	6f258593          	addi	a1,a1,1778 # 80008480 <states.1771+0x1b8>
    80004d96:	ffffc097          	auipc	ra,0xffffc
    80004d9a:	dc4080e7          	jalr	-572(ra) # 80000b5a <initlock>
  (*f0)->type = FD_PIPE;
    80004d9e:	609c                	ld	a5,0(s1)
    80004da0:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004da4:	609c                	ld	a5,0(s1)
    80004da6:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004daa:	609c                	ld	a5,0(s1)
    80004dac:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004db0:	609c                	ld	a5,0(s1)
    80004db2:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004db6:	000a3783          	ld	a5,0(s4)
    80004dba:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004dbe:	000a3783          	ld	a5,0(s4)
    80004dc2:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004dc6:	000a3783          	ld	a5,0(s4)
    80004dca:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004dce:	000a3783          	ld	a5,0(s4)
    80004dd2:	0127b823          	sd	s2,16(a5)
  return 0;
    80004dd6:	4501                	li	a0,0
    80004dd8:	a025                	j	80004e00 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004dda:	6088                	ld	a0,0(s1)
    80004ddc:	e501                	bnez	a0,80004de4 <pipealloc+0xaa>
    80004dde:	a039                	j	80004dec <pipealloc+0xb2>
    80004de0:	6088                	ld	a0,0(s1)
    80004de2:	c51d                	beqz	a0,80004e10 <pipealloc+0xd6>
    fileclose(*f0);
    80004de4:	00000097          	auipc	ra,0x0
    80004de8:	c26080e7          	jalr	-986(ra) # 80004a0a <fileclose>
  if(*f1)
    80004dec:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004df0:	557d                	li	a0,-1
  if(*f1)
    80004df2:	c799                	beqz	a5,80004e00 <pipealloc+0xc6>
    fileclose(*f1);
    80004df4:	853e                	mv	a0,a5
    80004df6:	00000097          	auipc	ra,0x0
    80004dfa:	c14080e7          	jalr	-1004(ra) # 80004a0a <fileclose>
  return -1;
    80004dfe:	557d                	li	a0,-1
}
    80004e00:	70a2                	ld	ra,40(sp)
    80004e02:	7402                	ld	s0,32(sp)
    80004e04:	64e2                	ld	s1,24(sp)
    80004e06:	6942                	ld	s2,16(sp)
    80004e08:	69a2                	ld	s3,8(sp)
    80004e0a:	6a02                	ld	s4,0(sp)
    80004e0c:	6145                	addi	sp,sp,48
    80004e0e:	8082                	ret
  return -1;
    80004e10:	557d                	li	a0,-1
    80004e12:	b7fd                	j	80004e00 <pipealloc+0xc6>

0000000080004e14 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004e14:	1101                	addi	sp,sp,-32
    80004e16:	ec06                	sd	ra,24(sp)
    80004e18:	e822                	sd	s0,16(sp)
    80004e1a:	e426                	sd	s1,8(sp)
    80004e1c:	e04a                	sd	s2,0(sp)
    80004e1e:	1000                	addi	s0,sp,32
    80004e20:	84aa                	mv	s1,a0
    80004e22:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004e24:	ffffc097          	auipc	ra,0xffffc
    80004e28:	dc6080e7          	jalr	-570(ra) # 80000bea <acquire>
  if(writable){
    80004e2c:	02090d63          	beqz	s2,80004e66 <pipeclose+0x52>
    pi->writeopen = 0;
    80004e30:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004e34:	21848513          	addi	a0,s1,536
    80004e38:	ffffd097          	auipc	ra,0xffffd
    80004e3c:	500080e7          	jalr	1280(ra) # 80002338 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004e40:	2204b783          	ld	a5,544(s1)
    80004e44:	eb95                	bnez	a5,80004e78 <pipeclose+0x64>
    release(&pi->lock);
    80004e46:	8526                	mv	a0,s1
    80004e48:	ffffc097          	auipc	ra,0xffffc
    80004e4c:	e56080e7          	jalr	-426(ra) # 80000c9e <release>
    kfree((char*)pi);
    80004e50:	8526                	mv	a0,s1
    80004e52:	ffffc097          	auipc	ra,0xffffc
    80004e56:	bac080e7          	jalr	-1108(ra) # 800009fe <kfree>
  } else
    release(&pi->lock);
}
    80004e5a:	60e2                	ld	ra,24(sp)
    80004e5c:	6442                	ld	s0,16(sp)
    80004e5e:	64a2                	ld	s1,8(sp)
    80004e60:	6902                	ld	s2,0(sp)
    80004e62:	6105                	addi	sp,sp,32
    80004e64:	8082                	ret
    pi->readopen = 0;
    80004e66:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004e6a:	21c48513          	addi	a0,s1,540
    80004e6e:	ffffd097          	auipc	ra,0xffffd
    80004e72:	4ca080e7          	jalr	1226(ra) # 80002338 <wakeup>
    80004e76:	b7e9                	j	80004e40 <pipeclose+0x2c>
    release(&pi->lock);
    80004e78:	8526                	mv	a0,s1
    80004e7a:	ffffc097          	auipc	ra,0xffffc
    80004e7e:	e24080e7          	jalr	-476(ra) # 80000c9e <release>
}
    80004e82:	bfe1                	j	80004e5a <pipeclose+0x46>

0000000080004e84 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004e84:	7159                	addi	sp,sp,-112
    80004e86:	f486                	sd	ra,104(sp)
    80004e88:	f0a2                	sd	s0,96(sp)
    80004e8a:	eca6                	sd	s1,88(sp)
    80004e8c:	e8ca                	sd	s2,80(sp)
    80004e8e:	e4ce                	sd	s3,72(sp)
    80004e90:	e0d2                	sd	s4,64(sp)
    80004e92:	fc56                	sd	s5,56(sp)
    80004e94:	f85a                	sd	s6,48(sp)
    80004e96:	f45e                	sd	s7,40(sp)
    80004e98:	f062                	sd	s8,32(sp)
    80004e9a:	ec66                	sd	s9,24(sp)
    80004e9c:	1880                	addi	s0,sp,112
    80004e9e:	84aa                	mv	s1,a0
    80004ea0:	8aae                	mv	s5,a1
    80004ea2:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004ea4:	ffffd097          	auipc	ra,0xffffd
    80004ea8:	b22080e7          	jalr	-1246(ra) # 800019c6 <myproc>
    80004eac:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004eae:	8526                	mv	a0,s1
    80004eb0:	ffffc097          	auipc	ra,0xffffc
    80004eb4:	d3a080e7          	jalr	-710(ra) # 80000bea <acquire>
  while(i < n){
    80004eb8:	0d405463          	blez	s4,80004f80 <pipewrite+0xfc>
    80004ebc:	8ba6                	mv	s7,s1
  int i = 0;
    80004ebe:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ec0:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004ec2:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004ec6:	21c48c13          	addi	s8,s1,540
    80004eca:	a08d                	j	80004f2c <pipewrite+0xa8>
      release(&pi->lock);
    80004ecc:	8526                	mv	a0,s1
    80004ece:	ffffc097          	auipc	ra,0xffffc
    80004ed2:	dd0080e7          	jalr	-560(ra) # 80000c9e <release>
      return -1;
    80004ed6:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004ed8:	854a                	mv	a0,s2
    80004eda:	70a6                	ld	ra,104(sp)
    80004edc:	7406                	ld	s0,96(sp)
    80004ede:	64e6                	ld	s1,88(sp)
    80004ee0:	6946                	ld	s2,80(sp)
    80004ee2:	69a6                	ld	s3,72(sp)
    80004ee4:	6a06                	ld	s4,64(sp)
    80004ee6:	7ae2                	ld	s5,56(sp)
    80004ee8:	7b42                	ld	s6,48(sp)
    80004eea:	7ba2                	ld	s7,40(sp)
    80004eec:	7c02                	ld	s8,32(sp)
    80004eee:	6ce2                	ld	s9,24(sp)
    80004ef0:	6165                	addi	sp,sp,112
    80004ef2:	8082                	ret
      wakeup(&pi->nread);
    80004ef4:	8566                	mv	a0,s9
    80004ef6:	ffffd097          	auipc	ra,0xffffd
    80004efa:	442080e7          	jalr	1090(ra) # 80002338 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004efe:	85de                	mv	a1,s7
    80004f00:	8562                	mv	a0,s8
    80004f02:	ffffd097          	auipc	ra,0xffffd
    80004f06:	286080e7          	jalr	646(ra) # 80002188 <sleep>
    80004f0a:	a839                	j	80004f28 <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004f0c:	21c4a783          	lw	a5,540(s1)
    80004f10:	0017871b          	addiw	a4,a5,1
    80004f14:	20e4ae23          	sw	a4,540(s1)
    80004f18:	1ff7f793          	andi	a5,a5,511
    80004f1c:	97a6                	add	a5,a5,s1
    80004f1e:	f9f44703          	lbu	a4,-97(s0)
    80004f22:	00e78c23          	sb	a4,24(a5)
      i++;
    80004f26:	2905                	addiw	s2,s2,1
  while(i < n){
    80004f28:	05495063          	bge	s2,s4,80004f68 <pipewrite+0xe4>
    if(pi->readopen == 0 || killed(pr)){
    80004f2c:	2204a783          	lw	a5,544(s1)
    80004f30:	dfd1                	beqz	a5,80004ecc <pipewrite+0x48>
    80004f32:	854e                	mv	a0,s3
    80004f34:	ffffd097          	auipc	ra,0xffffd
    80004f38:	654080e7          	jalr	1620(ra) # 80002588 <killed>
    80004f3c:	f941                	bnez	a0,80004ecc <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004f3e:	2184a783          	lw	a5,536(s1)
    80004f42:	21c4a703          	lw	a4,540(s1)
    80004f46:	2007879b          	addiw	a5,a5,512
    80004f4a:	faf705e3          	beq	a4,a5,80004ef4 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f4e:	4685                	li	a3,1
    80004f50:	01590633          	add	a2,s2,s5
    80004f54:	f9f40593          	addi	a1,s0,-97
    80004f58:	0509b503          	ld	a0,80(s3)
    80004f5c:	ffffc097          	auipc	ra,0xffffc
    80004f60:	7b4080e7          	jalr	1972(ra) # 80001710 <copyin>
    80004f64:	fb6514e3          	bne	a0,s6,80004f0c <pipewrite+0x88>
  wakeup(&pi->nread);
    80004f68:	21848513          	addi	a0,s1,536
    80004f6c:	ffffd097          	auipc	ra,0xffffd
    80004f70:	3cc080e7          	jalr	972(ra) # 80002338 <wakeup>
  release(&pi->lock);
    80004f74:	8526                	mv	a0,s1
    80004f76:	ffffc097          	auipc	ra,0xffffc
    80004f7a:	d28080e7          	jalr	-728(ra) # 80000c9e <release>
  return i;
    80004f7e:	bfa9                	j	80004ed8 <pipewrite+0x54>
  int i = 0;
    80004f80:	4901                	li	s2,0
    80004f82:	b7dd                	j	80004f68 <pipewrite+0xe4>

0000000080004f84 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004f84:	715d                	addi	sp,sp,-80
    80004f86:	e486                	sd	ra,72(sp)
    80004f88:	e0a2                	sd	s0,64(sp)
    80004f8a:	fc26                	sd	s1,56(sp)
    80004f8c:	f84a                	sd	s2,48(sp)
    80004f8e:	f44e                	sd	s3,40(sp)
    80004f90:	f052                	sd	s4,32(sp)
    80004f92:	ec56                	sd	s5,24(sp)
    80004f94:	e85a                	sd	s6,16(sp)
    80004f96:	0880                	addi	s0,sp,80
    80004f98:	84aa                	mv	s1,a0
    80004f9a:	892e                	mv	s2,a1
    80004f9c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004f9e:	ffffd097          	auipc	ra,0xffffd
    80004fa2:	a28080e7          	jalr	-1496(ra) # 800019c6 <myproc>
    80004fa6:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004fa8:	8b26                	mv	s6,s1
    80004faa:	8526                	mv	a0,s1
    80004fac:	ffffc097          	auipc	ra,0xffffc
    80004fb0:	c3e080e7          	jalr	-962(ra) # 80000bea <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004fb4:	2184a703          	lw	a4,536(s1)
    80004fb8:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004fbc:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004fc0:	02f71763          	bne	a4,a5,80004fee <piperead+0x6a>
    80004fc4:	2244a783          	lw	a5,548(s1)
    80004fc8:	c39d                	beqz	a5,80004fee <piperead+0x6a>
    if(killed(pr)){
    80004fca:	8552                	mv	a0,s4
    80004fcc:	ffffd097          	auipc	ra,0xffffd
    80004fd0:	5bc080e7          	jalr	1468(ra) # 80002588 <killed>
    80004fd4:	e941                	bnez	a0,80005064 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004fd6:	85da                	mv	a1,s6
    80004fd8:	854e                	mv	a0,s3
    80004fda:	ffffd097          	auipc	ra,0xffffd
    80004fde:	1ae080e7          	jalr	430(ra) # 80002188 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004fe2:	2184a703          	lw	a4,536(s1)
    80004fe6:	21c4a783          	lw	a5,540(s1)
    80004fea:	fcf70de3          	beq	a4,a5,80004fc4 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004fee:	09505263          	blez	s5,80005072 <piperead+0xee>
    80004ff2:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004ff4:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004ff6:	2184a783          	lw	a5,536(s1)
    80004ffa:	21c4a703          	lw	a4,540(s1)
    80004ffe:	02f70d63          	beq	a4,a5,80005038 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005002:	0017871b          	addiw	a4,a5,1
    80005006:	20e4ac23          	sw	a4,536(s1)
    8000500a:	1ff7f793          	andi	a5,a5,511
    8000500e:	97a6                	add	a5,a5,s1
    80005010:	0187c783          	lbu	a5,24(a5)
    80005014:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005018:	4685                	li	a3,1
    8000501a:	fbf40613          	addi	a2,s0,-65
    8000501e:	85ca                	mv	a1,s2
    80005020:	050a3503          	ld	a0,80(s4)
    80005024:	ffffc097          	auipc	ra,0xffffc
    80005028:	660080e7          	jalr	1632(ra) # 80001684 <copyout>
    8000502c:	01650663          	beq	a0,s6,80005038 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005030:	2985                	addiw	s3,s3,1
    80005032:	0905                	addi	s2,s2,1
    80005034:	fd3a91e3          	bne	s5,s3,80004ff6 <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005038:	21c48513          	addi	a0,s1,540
    8000503c:	ffffd097          	auipc	ra,0xffffd
    80005040:	2fc080e7          	jalr	764(ra) # 80002338 <wakeup>
  release(&pi->lock);
    80005044:	8526                	mv	a0,s1
    80005046:	ffffc097          	auipc	ra,0xffffc
    8000504a:	c58080e7          	jalr	-936(ra) # 80000c9e <release>
  return i;
}
    8000504e:	854e                	mv	a0,s3
    80005050:	60a6                	ld	ra,72(sp)
    80005052:	6406                	ld	s0,64(sp)
    80005054:	74e2                	ld	s1,56(sp)
    80005056:	7942                	ld	s2,48(sp)
    80005058:	79a2                	ld	s3,40(sp)
    8000505a:	7a02                	ld	s4,32(sp)
    8000505c:	6ae2                	ld	s5,24(sp)
    8000505e:	6b42                	ld	s6,16(sp)
    80005060:	6161                	addi	sp,sp,80
    80005062:	8082                	ret
      release(&pi->lock);
    80005064:	8526                	mv	a0,s1
    80005066:	ffffc097          	auipc	ra,0xffffc
    8000506a:	c38080e7          	jalr	-968(ra) # 80000c9e <release>
      return -1;
    8000506e:	59fd                	li	s3,-1
    80005070:	bff9                	j	8000504e <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005072:	4981                	li	s3,0
    80005074:	b7d1                	j	80005038 <piperead+0xb4>

0000000080005076 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80005076:	1141                	addi	sp,sp,-16
    80005078:	e422                	sd	s0,8(sp)
    8000507a:	0800                	addi	s0,sp,16
    8000507c:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000507e:	8905                	andi	a0,a0,1
    80005080:	c111                	beqz	a0,80005084 <flags2perm+0xe>
      perm = PTE_X;
    80005082:	4521                	li	a0,8
    if(flags & 0x2)
    80005084:	8b89                	andi	a5,a5,2
    80005086:	c399                	beqz	a5,8000508c <flags2perm+0x16>
      perm |= PTE_W;
    80005088:	00456513          	ori	a0,a0,4
    return perm;
}
    8000508c:	6422                	ld	s0,8(sp)
    8000508e:	0141                	addi	sp,sp,16
    80005090:	8082                	ret

0000000080005092 <exec>:

int
exec(char *path, char **argv)
{
    80005092:	df010113          	addi	sp,sp,-528
    80005096:	20113423          	sd	ra,520(sp)
    8000509a:	20813023          	sd	s0,512(sp)
    8000509e:	ffa6                	sd	s1,504(sp)
    800050a0:	fbca                	sd	s2,496(sp)
    800050a2:	f7ce                	sd	s3,488(sp)
    800050a4:	f3d2                	sd	s4,480(sp)
    800050a6:	efd6                	sd	s5,472(sp)
    800050a8:	ebda                	sd	s6,464(sp)
    800050aa:	e7de                	sd	s7,456(sp)
    800050ac:	e3e2                	sd	s8,448(sp)
    800050ae:	ff66                	sd	s9,440(sp)
    800050b0:	fb6a                	sd	s10,432(sp)
    800050b2:	f76e                	sd	s11,424(sp)
    800050b4:	0c00                	addi	s0,sp,528
    800050b6:	84aa                	mv	s1,a0
    800050b8:	dea43c23          	sd	a0,-520(s0)
    800050bc:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800050c0:	ffffd097          	auipc	ra,0xffffd
    800050c4:	906080e7          	jalr	-1786(ra) # 800019c6 <myproc>
    800050c8:	892a                	mv	s2,a0

  begin_op();
    800050ca:	fffff097          	auipc	ra,0xfffff
    800050ce:	474080e7          	jalr	1140(ra) # 8000453e <begin_op>

  if((ip = namei(path)) == 0){
    800050d2:	8526                	mv	a0,s1
    800050d4:	fffff097          	auipc	ra,0xfffff
    800050d8:	24e080e7          	jalr	590(ra) # 80004322 <namei>
    800050dc:	c92d                	beqz	a0,8000514e <exec+0xbc>
    800050de:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800050e0:	fffff097          	auipc	ra,0xfffff
    800050e4:	a9c080e7          	jalr	-1380(ra) # 80003b7c <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800050e8:	04000713          	li	a4,64
    800050ec:	4681                	li	a3,0
    800050ee:	e5040613          	addi	a2,s0,-432
    800050f2:	4581                	li	a1,0
    800050f4:	8526                	mv	a0,s1
    800050f6:	fffff097          	auipc	ra,0xfffff
    800050fa:	d3a080e7          	jalr	-710(ra) # 80003e30 <readi>
    800050fe:	04000793          	li	a5,64
    80005102:	00f51a63          	bne	a0,a5,80005116 <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80005106:	e5042703          	lw	a4,-432(s0)
    8000510a:	464c47b7          	lui	a5,0x464c4
    8000510e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005112:	04f70463          	beq	a4,a5,8000515a <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005116:	8526                	mv	a0,s1
    80005118:	fffff097          	auipc	ra,0xfffff
    8000511c:	cc6080e7          	jalr	-826(ra) # 80003dde <iunlockput>
    end_op();
    80005120:	fffff097          	auipc	ra,0xfffff
    80005124:	49e080e7          	jalr	1182(ra) # 800045be <end_op>
  }
  return -1;
    80005128:	557d                	li	a0,-1
}
    8000512a:	20813083          	ld	ra,520(sp)
    8000512e:	20013403          	ld	s0,512(sp)
    80005132:	74fe                	ld	s1,504(sp)
    80005134:	795e                	ld	s2,496(sp)
    80005136:	79be                	ld	s3,488(sp)
    80005138:	7a1e                	ld	s4,480(sp)
    8000513a:	6afe                	ld	s5,472(sp)
    8000513c:	6b5e                	ld	s6,464(sp)
    8000513e:	6bbe                	ld	s7,456(sp)
    80005140:	6c1e                	ld	s8,448(sp)
    80005142:	7cfa                	ld	s9,440(sp)
    80005144:	7d5a                	ld	s10,432(sp)
    80005146:	7dba                	ld	s11,424(sp)
    80005148:	21010113          	addi	sp,sp,528
    8000514c:	8082                	ret
    end_op();
    8000514e:	fffff097          	auipc	ra,0xfffff
    80005152:	470080e7          	jalr	1136(ra) # 800045be <end_op>
    return -1;
    80005156:	557d                	li	a0,-1
    80005158:	bfc9                	j	8000512a <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    8000515a:	854a                	mv	a0,s2
    8000515c:	ffffd097          	auipc	ra,0xffffd
    80005160:	92e080e7          	jalr	-1746(ra) # 80001a8a <proc_pagetable>
    80005164:	8baa                	mv	s7,a0
    80005166:	d945                	beqz	a0,80005116 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005168:	e7042983          	lw	s3,-400(s0)
    8000516c:	e8845783          	lhu	a5,-376(s0)
    80005170:	c7ad                	beqz	a5,800051da <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005172:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005174:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80005176:	6c85                	lui	s9,0x1
    80005178:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000517c:	def43823          	sd	a5,-528(s0)
    80005180:	ac0d                	j	800053b2 <exec+0x320>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005182:	00003517          	auipc	a0,0x3
    80005186:	6ee50513          	addi	a0,a0,1774 # 80008870 <syscallnum+0x238>
    8000518a:	ffffb097          	auipc	ra,0xffffb
    8000518e:	3ba080e7          	jalr	954(ra) # 80000544 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005192:	8756                	mv	a4,s5
    80005194:	012d86bb          	addw	a3,s11,s2
    80005198:	4581                	li	a1,0
    8000519a:	8526                	mv	a0,s1
    8000519c:	fffff097          	auipc	ra,0xfffff
    800051a0:	c94080e7          	jalr	-876(ra) # 80003e30 <readi>
    800051a4:	2501                	sext.w	a0,a0
    800051a6:	1aaa9a63          	bne	s5,a0,8000535a <exec+0x2c8>
  for(i = 0; i < sz; i += PGSIZE){
    800051aa:	6785                	lui	a5,0x1
    800051ac:	0127893b          	addw	s2,a5,s2
    800051b0:	77fd                	lui	a5,0xfffff
    800051b2:	01478a3b          	addw	s4,a5,s4
    800051b6:	1f897563          	bgeu	s2,s8,800053a0 <exec+0x30e>
    pa = walkaddr(pagetable, va + i);
    800051ba:	02091593          	slli	a1,s2,0x20
    800051be:	9181                	srli	a1,a1,0x20
    800051c0:	95ea                	add	a1,a1,s10
    800051c2:	855e                	mv	a0,s7
    800051c4:	ffffc097          	auipc	ra,0xffffc
    800051c8:	eb4080e7          	jalr	-332(ra) # 80001078 <walkaddr>
    800051cc:	862a                	mv	a2,a0
    if(pa == 0)
    800051ce:	d955                	beqz	a0,80005182 <exec+0xf0>
      n = PGSIZE;
    800051d0:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    800051d2:	fd9a70e3          	bgeu	s4,s9,80005192 <exec+0x100>
      n = sz - i;
    800051d6:	8ad2                	mv	s5,s4
    800051d8:	bf6d                	j	80005192 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800051da:	4a01                	li	s4,0
  iunlockput(ip);
    800051dc:	8526                	mv	a0,s1
    800051de:	fffff097          	auipc	ra,0xfffff
    800051e2:	c00080e7          	jalr	-1024(ra) # 80003dde <iunlockput>
  end_op();
    800051e6:	fffff097          	auipc	ra,0xfffff
    800051ea:	3d8080e7          	jalr	984(ra) # 800045be <end_op>
  p = myproc();
    800051ee:	ffffc097          	auipc	ra,0xffffc
    800051f2:	7d8080e7          	jalr	2008(ra) # 800019c6 <myproc>
    800051f6:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800051f8:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800051fc:	6785                	lui	a5,0x1
    800051fe:	17fd                	addi	a5,a5,-1
    80005200:	9a3e                	add	s4,s4,a5
    80005202:	757d                	lui	a0,0xfffff
    80005204:	00aa77b3          	and	a5,s4,a0
    80005208:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    8000520c:	4691                	li	a3,4
    8000520e:	6609                	lui	a2,0x2
    80005210:	963e                	add	a2,a2,a5
    80005212:	85be                	mv	a1,a5
    80005214:	855e                	mv	a0,s7
    80005216:	ffffc097          	auipc	ra,0xffffc
    8000521a:	216080e7          	jalr	534(ra) # 8000142c <uvmalloc>
    8000521e:	8b2a                	mv	s6,a0
  ip = 0;
    80005220:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005222:	12050c63          	beqz	a0,8000535a <exec+0x2c8>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005226:	75f9                	lui	a1,0xffffe
    80005228:	95aa                	add	a1,a1,a0
    8000522a:	855e                	mv	a0,s7
    8000522c:	ffffc097          	auipc	ra,0xffffc
    80005230:	426080e7          	jalr	1062(ra) # 80001652 <uvmclear>
  stackbase = sp - PGSIZE;
    80005234:	7c7d                	lui	s8,0xfffff
    80005236:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80005238:	e0043783          	ld	a5,-512(s0)
    8000523c:	6388                	ld	a0,0(a5)
    8000523e:	c535                	beqz	a0,800052aa <exec+0x218>
    80005240:	e9040993          	addi	s3,s0,-368
    80005244:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80005248:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    8000524a:	ffffc097          	auipc	ra,0xffffc
    8000524e:	c20080e7          	jalr	-992(ra) # 80000e6a <strlen>
    80005252:	2505                	addiw	a0,a0,1
    80005254:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005258:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    8000525c:	13896663          	bltu	s2,s8,80005388 <exec+0x2f6>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005260:	e0043d83          	ld	s11,-512(s0)
    80005264:	000dba03          	ld	s4,0(s11)
    80005268:	8552                	mv	a0,s4
    8000526a:	ffffc097          	auipc	ra,0xffffc
    8000526e:	c00080e7          	jalr	-1024(ra) # 80000e6a <strlen>
    80005272:	0015069b          	addiw	a3,a0,1
    80005276:	8652                	mv	a2,s4
    80005278:	85ca                	mv	a1,s2
    8000527a:	855e                	mv	a0,s7
    8000527c:	ffffc097          	auipc	ra,0xffffc
    80005280:	408080e7          	jalr	1032(ra) # 80001684 <copyout>
    80005284:	10054663          	bltz	a0,80005390 <exec+0x2fe>
    ustack[argc] = sp;
    80005288:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000528c:	0485                	addi	s1,s1,1
    8000528e:	008d8793          	addi	a5,s11,8
    80005292:	e0f43023          	sd	a5,-512(s0)
    80005296:	008db503          	ld	a0,8(s11)
    8000529a:	c911                	beqz	a0,800052ae <exec+0x21c>
    if(argc >= MAXARG)
    8000529c:	09a1                	addi	s3,s3,8
    8000529e:	fb3c96e3          	bne	s9,s3,8000524a <exec+0x1b8>
  sz = sz1;
    800052a2:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800052a6:	4481                	li	s1,0
    800052a8:	a84d                	j	8000535a <exec+0x2c8>
  sp = sz;
    800052aa:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    800052ac:	4481                	li	s1,0
  ustack[argc] = 0;
    800052ae:	00349793          	slli	a5,s1,0x3
    800052b2:	f9040713          	addi	a4,s0,-112
    800052b6:	97ba                	add	a5,a5,a4
    800052b8:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    800052bc:	00148693          	addi	a3,s1,1
    800052c0:	068e                	slli	a3,a3,0x3
    800052c2:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800052c6:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800052ca:	01897663          	bgeu	s2,s8,800052d6 <exec+0x244>
  sz = sz1;
    800052ce:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800052d2:	4481                	li	s1,0
    800052d4:	a059                	j	8000535a <exec+0x2c8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800052d6:	e9040613          	addi	a2,s0,-368
    800052da:	85ca                	mv	a1,s2
    800052dc:	855e                	mv	a0,s7
    800052de:	ffffc097          	auipc	ra,0xffffc
    800052e2:	3a6080e7          	jalr	934(ra) # 80001684 <copyout>
    800052e6:	0a054963          	bltz	a0,80005398 <exec+0x306>
  p->trapframe->a1 = sp;
    800052ea:	058ab783          	ld	a5,88(s5)
    800052ee:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800052f2:	df843783          	ld	a5,-520(s0)
    800052f6:	0007c703          	lbu	a4,0(a5)
    800052fa:	cf11                	beqz	a4,80005316 <exec+0x284>
    800052fc:	0785                	addi	a5,a5,1
    if(*s == '/')
    800052fe:	02f00693          	li	a3,47
    80005302:	a039                	j	80005310 <exec+0x27e>
      last = s+1;
    80005304:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80005308:	0785                	addi	a5,a5,1
    8000530a:	fff7c703          	lbu	a4,-1(a5)
    8000530e:	c701                	beqz	a4,80005316 <exec+0x284>
    if(*s == '/')
    80005310:	fed71ce3          	bne	a4,a3,80005308 <exec+0x276>
    80005314:	bfc5                	j	80005304 <exec+0x272>
  safestrcpy(p->name, last, sizeof(p->name));
    80005316:	4641                	li	a2,16
    80005318:	df843583          	ld	a1,-520(s0)
    8000531c:	158a8513          	addi	a0,s5,344
    80005320:	ffffc097          	auipc	ra,0xffffc
    80005324:	b18080e7          	jalr	-1256(ra) # 80000e38 <safestrcpy>
  oldpagetable = p->pagetable;
    80005328:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    8000532c:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    80005330:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005334:	058ab783          	ld	a5,88(s5)
    80005338:	e6843703          	ld	a4,-408(s0)
    8000533c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000533e:	058ab783          	ld	a5,88(s5)
    80005342:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005346:	85ea                	mv	a1,s10
    80005348:	ffffc097          	auipc	ra,0xffffc
    8000534c:	7de080e7          	jalr	2014(ra) # 80001b26 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005350:	0004851b          	sext.w	a0,s1
    80005354:	bbd9                	j	8000512a <exec+0x98>
    80005356:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    8000535a:	e0843583          	ld	a1,-504(s0)
    8000535e:	855e                	mv	a0,s7
    80005360:	ffffc097          	auipc	ra,0xffffc
    80005364:	7c6080e7          	jalr	1990(ra) # 80001b26 <proc_freepagetable>
  if(ip){
    80005368:	da0497e3          	bnez	s1,80005116 <exec+0x84>
  return -1;
    8000536c:	557d                	li	a0,-1
    8000536e:	bb75                	j	8000512a <exec+0x98>
    80005370:	e1443423          	sd	s4,-504(s0)
    80005374:	b7dd                	j	8000535a <exec+0x2c8>
    80005376:	e1443423          	sd	s4,-504(s0)
    8000537a:	b7c5                	j	8000535a <exec+0x2c8>
    8000537c:	e1443423          	sd	s4,-504(s0)
    80005380:	bfe9                	j	8000535a <exec+0x2c8>
    80005382:	e1443423          	sd	s4,-504(s0)
    80005386:	bfd1                	j	8000535a <exec+0x2c8>
  sz = sz1;
    80005388:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000538c:	4481                	li	s1,0
    8000538e:	b7f1                	j	8000535a <exec+0x2c8>
  sz = sz1;
    80005390:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005394:	4481                	li	s1,0
    80005396:	b7d1                	j	8000535a <exec+0x2c8>
  sz = sz1;
    80005398:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000539c:	4481                	li	s1,0
    8000539e:	bf75                	j	8000535a <exec+0x2c8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800053a0:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800053a4:	2b05                	addiw	s6,s6,1
    800053a6:	0389899b          	addiw	s3,s3,56
    800053aa:	e8845783          	lhu	a5,-376(s0)
    800053ae:	e2fb57e3          	bge	s6,a5,800051dc <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800053b2:	2981                	sext.w	s3,s3
    800053b4:	03800713          	li	a4,56
    800053b8:	86ce                	mv	a3,s3
    800053ba:	e1840613          	addi	a2,s0,-488
    800053be:	4581                	li	a1,0
    800053c0:	8526                	mv	a0,s1
    800053c2:	fffff097          	auipc	ra,0xfffff
    800053c6:	a6e080e7          	jalr	-1426(ra) # 80003e30 <readi>
    800053ca:	03800793          	li	a5,56
    800053ce:	f8f514e3          	bne	a0,a5,80005356 <exec+0x2c4>
    if(ph.type != ELF_PROG_LOAD)
    800053d2:	e1842783          	lw	a5,-488(s0)
    800053d6:	4705                	li	a4,1
    800053d8:	fce796e3          	bne	a5,a4,800053a4 <exec+0x312>
    if(ph.memsz < ph.filesz)
    800053dc:	e4043903          	ld	s2,-448(s0)
    800053e0:	e3843783          	ld	a5,-456(s0)
    800053e4:	f8f966e3          	bltu	s2,a5,80005370 <exec+0x2de>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800053e8:	e2843783          	ld	a5,-472(s0)
    800053ec:	993e                	add	s2,s2,a5
    800053ee:	f8f964e3          	bltu	s2,a5,80005376 <exec+0x2e4>
    if(ph.vaddr % PGSIZE != 0)
    800053f2:	df043703          	ld	a4,-528(s0)
    800053f6:	8ff9                	and	a5,a5,a4
    800053f8:	f3d1                	bnez	a5,8000537c <exec+0x2ea>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800053fa:	e1c42503          	lw	a0,-484(s0)
    800053fe:	00000097          	auipc	ra,0x0
    80005402:	c78080e7          	jalr	-904(ra) # 80005076 <flags2perm>
    80005406:	86aa                	mv	a3,a0
    80005408:	864a                	mv	a2,s2
    8000540a:	85d2                	mv	a1,s4
    8000540c:	855e                	mv	a0,s7
    8000540e:	ffffc097          	auipc	ra,0xffffc
    80005412:	01e080e7          	jalr	30(ra) # 8000142c <uvmalloc>
    80005416:	e0a43423          	sd	a0,-504(s0)
    8000541a:	d525                	beqz	a0,80005382 <exec+0x2f0>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000541c:	e2843d03          	ld	s10,-472(s0)
    80005420:	e2042d83          	lw	s11,-480(s0)
    80005424:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005428:	f60c0ce3          	beqz	s8,800053a0 <exec+0x30e>
    8000542c:	8a62                	mv	s4,s8
    8000542e:	4901                	li	s2,0
    80005430:	b369                	j	800051ba <exec+0x128>

0000000080005432 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005432:	7179                	addi	sp,sp,-48
    80005434:	f406                	sd	ra,40(sp)
    80005436:	f022                	sd	s0,32(sp)
    80005438:	ec26                	sd	s1,24(sp)
    8000543a:	e84a                	sd	s2,16(sp)
    8000543c:	1800                	addi	s0,sp,48
    8000543e:	892e                	mv	s2,a1
    80005440:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005442:	fdc40593          	addi	a1,s0,-36
    80005446:	ffffe097          	auipc	ra,0xffffe
    8000544a:	964080e7          	jalr	-1692(ra) # 80002daa <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000544e:	fdc42703          	lw	a4,-36(s0)
    80005452:	47bd                	li	a5,15
    80005454:	02e7eb63          	bltu	a5,a4,8000548a <argfd+0x58>
    80005458:	ffffc097          	auipc	ra,0xffffc
    8000545c:	56e080e7          	jalr	1390(ra) # 800019c6 <myproc>
    80005460:	fdc42703          	lw	a4,-36(s0)
    80005464:	01a70793          	addi	a5,a4,26
    80005468:	078e                	slli	a5,a5,0x3
    8000546a:	953e                	add	a0,a0,a5
    8000546c:	611c                	ld	a5,0(a0)
    8000546e:	c385                	beqz	a5,8000548e <argfd+0x5c>
    return -1;
  if(pfd)
    80005470:	00090463          	beqz	s2,80005478 <argfd+0x46>
    *pfd = fd;
    80005474:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005478:	4501                	li	a0,0
  if(pf)
    8000547a:	c091                	beqz	s1,8000547e <argfd+0x4c>
    *pf = f;
    8000547c:	e09c                	sd	a5,0(s1)
}
    8000547e:	70a2                	ld	ra,40(sp)
    80005480:	7402                	ld	s0,32(sp)
    80005482:	64e2                	ld	s1,24(sp)
    80005484:	6942                	ld	s2,16(sp)
    80005486:	6145                	addi	sp,sp,48
    80005488:	8082                	ret
    return -1;
    8000548a:	557d                	li	a0,-1
    8000548c:	bfcd                	j	8000547e <argfd+0x4c>
    8000548e:	557d                	li	a0,-1
    80005490:	b7fd                	j	8000547e <argfd+0x4c>

0000000080005492 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005492:	1101                	addi	sp,sp,-32
    80005494:	ec06                	sd	ra,24(sp)
    80005496:	e822                	sd	s0,16(sp)
    80005498:	e426                	sd	s1,8(sp)
    8000549a:	1000                	addi	s0,sp,32
    8000549c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000549e:	ffffc097          	auipc	ra,0xffffc
    800054a2:	528080e7          	jalr	1320(ra) # 800019c6 <myproc>
    800054a6:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800054a8:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffdbd20>
    800054ac:	4501                	li	a0,0
    800054ae:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800054b0:	6398                	ld	a4,0(a5)
    800054b2:	cb19                	beqz	a4,800054c8 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800054b4:	2505                	addiw	a0,a0,1
    800054b6:	07a1                	addi	a5,a5,8
    800054b8:	fed51ce3          	bne	a0,a3,800054b0 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800054bc:	557d                	li	a0,-1
}
    800054be:	60e2                	ld	ra,24(sp)
    800054c0:	6442                	ld	s0,16(sp)
    800054c2:	64a2                	ld	s1,8(sp)
    800054c4:	6105                	addi	sp,sp,32
    800054c6:	8082                	ret
      p->ofile[fd] = f;
    800054c8:	01a50793          	addi	a5,a0,26
    800054cc:	078e                	slli	a5,a5,0x3
    800054ce:	963e                	add	a2,a2,a5
    800054d0:	e204                	sd	s1,0(a2)
      return fd;
    800054d2:	b7f5                	j	800054be <fdalloc+0x2c>

00000000800054d4 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800054d4:	715d                	addi	sp,sp,-80
    800054d6:	e486                	sd	ra,72(sp)
    800054d8:	e0a2                	sd	s0,64(sp)
    800054da:	fc26                	sd	s1,56(sp)
    800054dc:	f84a                	sd	s2,48(sp)
    800054de:	f44e                	sd	s3,40(sp)
    800054e0:	f052                	sd	s4,32(sp)
    800054e2:	ec56                	sd	s5,24(sp)
    800054e4:	e85a                	sd	s6,16(sp)
    800054e6:	0880                	addi	s0,sp,80
    800054e8:	8b2e                	mv	s6,a1
    800054ea:	89b2                	mv	s3,a2
    800054ec:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800054ee:	fb040593          	addi	a1,s0,-80
    800054f2:	fffff097          	auipc	ra,0xfffff
    800054f6:	e4e080e7          	jalr	-434(ra) # 80004340 <nameiparent>
    800054fa:	84aa                	mv	s1,a0
    800054fc:	16050063          	beqz	a0,8000565c <create+0x188>
    return 0;

  ilock(dp);
    80005500:	ffffe097          	auipc	ra,0xffffe
    80005504:	67c080e7          	jalr	1660(ra) # 80003b7c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005508:	4601                	li	a2,0
    8000550a:	fb040593          	addi	a1,s0,-80
    8000550e:	8526                	mv	a0,s1
    80005510:	fffff097          	auipc	ra,0xfffff
    80005514:	b50080e7          	jalr	-1200(ra) # 80004060 <dirlookup>
    80005518:	8aaa                	mv	s5,a0
    8000551a:	c931                	beqz	a0,8000556e <create+0x9a>
    iunlockput(dp);
    8000551c:	8526                	mv	a0,s1
    8000551e:	fffff097          	auipc	ra,0xfffff
    80005522:	8c0080e7          	jalr	-1856(ra) # 80003dde <iunlockput>
    ilock(ip);
    80005526:	8556                	mv	a0,s5
    80005528:	ffffe097          	auipc	ra,0xffffe
    8000552c:	654080e7          	jalr	1620(ra) # 80003b7c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005530:	000b059b          	sext.w	a1,s6
    80005534:	4789                	li	a5,2
    80005536:	02f59563          	bne	a1,a5,80005560 <create+0x8c>
    8000553a:	044ad783          	lhu	a5,68(s5)
    8000553e:	37f9                	addiw	a5,a5,-2
    80005540:	17c2                	slli	a5,a5,0x30
    80005542:	93c1                	srli	a5,a5,0x30
    80005544:	4705                	li	a4,1
    80005546:	00f76d63          	bltu	a4,a5,80005560 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000554a:	8556                	mv	a0,s5
    8000554c:	60a6                	ld	ra,72(sp)
    8000554e:	6406                	ld	s0,64(sp)
    80005550:	74e2                	ld	s1,56(sp)
    80005552:	7942                	ld	s2,48(sp)
    80005554:	79a2                	ld	s3,40(sp)
    80005556:	7a02                	ld	s4,32(sp)
    80005558:	6ae2                	ld	s5,24(sp)
    8000555a:	6b42                	ld	s6,16(sp)
    8000555c:	6161                	addi	sp,sp,80
    8000555e:	8082                	ret
    iunlockput(ip);
    80005560:	8556                	mv	a0,s5
    80005562:	fffff097          	auipc	ra,0xfffff
    80005566:	87c080e7          	jalr	-1924(ra) # 80003dde <iunlockput>
    return 0;
    8000556a:	4a81                	li	s5,0
    8000556c:	bff9                	j	8000554a <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000556e:	85da                	mv	a1,s6
    80005570:	4088                	lw	a0,0(s1)
    80005572:	ffffe097          	auipc	ra,0xffffe
    80005576:	46e080e7          	jalr	1134(ra) # 800039e0 <ialloc>
    8000557a:	8a2a                	mv	s4,a0
    8000557c:	c921                	beqz	a0,800055cc <create+0xf8>
  ilock(ip);
    8000557e:	ffffe097          	auipc	ra,0xffffe
    80005582:	5fe080e7          	jalr	1534(ra) # 80003b7c <ilock>
  ip->major = major;
    80005586:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000558a:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000558e:	4785                	li	a5,1
    80005590:	04fa1523          	sh	a5,74(s4)
  iupdate(ip);
    80005594:	8552                	mv	a0,s4
    80005596:	ffffe097          	auipc	ra,0xffffe
    8000559a:	51c080e7          	jalr	1308(ra) # 80003ab2 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000559e:	000b059b          	sext.w	a1,s6
    800055a2:	4785                	li	a5,1
    800055a4:	02f58b63          	beq	a1,a5,800055da <create+0x106>
  if(dirlink(dp, name, ip->inum) < 0)
    800055a8:	004a2603          	lw	a2,4(s4)
    800055ac:	fb040593          	addi	a1,s0,-80
    800055b0:	8526                	mv	a0,s1
    800055b2:	fffff097          	auipc	ra,0xfffff
    800055b6:	cbe080e7          	jalr	-834(ra) # 80004270 <dirlink>
    800055ba:	06054f63          	bltz	a0,80005638 <create+0x164>
  iunlockput(dp);
    800055be:	8526                	mv	a0,s1
    800055c0:	fffff097          	auipc	ra,0xfffff
    800055c4:	81e080e7          	jalr	-2018(ra) # 80003dde <iunlockput>
  return ip;
    800055c8:	8ad2                	mv	s5,s4
    800055ca:	b741                	j	8000554a <create+0x76>
    iunlockput(dp);
    800055cc:	8526                	mv	a0,s1
    800055ce:	fffff097          	auipc	ra,0xfffff
    800055d2:	810080e7          	jalr	-2032(ra) # 80003dde <iunlockput>
    return 0;
    800055d6:	8ad2                	mv	s5,s4
    800055d8:	bf8d                	j	8000554a <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800055da:	004a2603          	lw	a2,4(s4)
    800055de:	00003597          	auipc	a1,0x3
    800055e2:	2b258593          	addi	a1,a1,690 # 80008890 <syscallnum+0x258>
    800055e6:	8552                	mv	a0,s4
    800055e8:	fffff097          	auipc	ra,0xfffff
    800055ec:	c88080e7          	jalr	-888(ra) # 80004270 <dirlink>
    800055f0:	04054463          	bltz	a0,80005638 <create+0x164>
    800055f4:	40d0                	lw	a2,4(s1)
    800055f6:	00003597          	auipc	a1,0x3
    800055fa:	2a258593          	addi	a1,a1,674 # 80008898 <syscallnum+0x260>
    800055fe:	8552                	mv	a0,s4
    80005600:	fffff097          	auipc	ra,0xfffff
    80005604:	c70080e7          	jalr	-912(ra) # 80004270 <dirlink>
    80005608:	02054863          	bltz	a0,80005638 <create+0x164>
  if(dirlink(dp, name, ip->inum) < 0)
    8000560c:	004a2603          	lw	a2,4(s4)
    80005610:	fb040593          	addi	a1,s0,-80
    80005614:	8526                	mv	a0,s1
    80005616:	fffff097          	auipc	ra,0xfffff
    8000561a:	c5a080e7          	jalr	-934(ra) # 80004270 <dirlink>
    8000561e:	00054d63          	bltz	a0,80005638 <create+0x164>
    dp->nlink++;  // for ".."
    80005622:	04a4d783          	lhu	a5,74(s1)
    80005626:	2785                	addiw	a5,a5,1
    80005628:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000562c:	8526                	mv	a0,s1
    8000562e:	ffffe097          	auipc	ra,0xffffe
    80005632:	484080e7          	jalr	1156(ra) # 80003ab2 <iupdate>
    80005636:	b761                	j	800055be <create+0xea>
  ip->nlink = 0;
    80005638:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000563c:	8552                	mv	a0,s4
    8000563e:	ffffe097          	auipc	ra,0xffffe
    80005642:	474080e7          	jalr	1140(ra) # 80003ab2 <iupdate>
  iunlockput(ip);
    80005646:	8552                	mv	a0,s4
    80005648:	ffffe097          	auipc	ra,0xffffe
    8000564c:	796080e7          	jalr	1942(ra) # 80003dde <iunlockput>
  iunlockput(dp);
    80005650:	8526                	mv	a0,s1
    80005652:	ffffe097          	auipc	ra,0xffffe
    80005656:	78c080e7          	jalr	1932(ra) # 80003dde <iunlockput>
  return 0;
    8000565a:	bdc5                	j	8000554a <create+0x76>
    return 0;
    8000565c:	8aaa                	mv	s5,a0
    8000565e:	b5f5                	j	8000554a <create+0x76>

0000000080005660 <sys_dup>:
{
    80005660:	7179                	addi	sp,sp,-48
    80005662:	f406                	sd	ra,40(sp)
    80005664:	f022                	sd	s0,32(sp)
    80005666:	ec26                	sd	s1,24(sp)
    80005668:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000566a:	fd840613          	addi	a2,s0,-40
    8000566e:	4581                	li	a1,0
    80005670:	4501                	li	a0,0
    80005672:	00000097          	auipc	ra,0x0
    80005676:	dc0080e7          	jalr	-576(ra) # 80005432 <argfd>
    return -1;
    8000567a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000567c:	02054363          	bltz	a0,800056a2 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005680:	fd843503          	ld	a0,-40(s0)
    80005684:	00000097          	auipc	ra,0x0
    80005688:	e0e080e7          	jalr	-498(ra) # 80005492 <fdalloc>
    8000568c:	84aa                	mv	s1,a0
    return -1;
    8000568e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005690:	00054963          	bltz	a0,800056a2 <sys_dup+0x42>
  filedup(f);
    80005694:	fd843503          	ld	a0,-40(s0)
    80005698:	fffff097          	auipc	ra,0xfffff
    8000569c:	320080e7          	jalr	800(ra) # 800049b8 <filedup>
  return fd;
    800056a0:	87a6                	mv	a5,s1
}
    800056a2:	853e                	mv	a0,a5
    800056a4:	70a2                	ld	ra,40(sp)
    800056a6:	7402                	ld	s0,32(sp)
    800056a8:	64e2                	ld	s1,24(sp)
    800056aa:	6145                	addi	sp,sp,48
    800056ac:	8082                	ret

00000000800056ae <sys_read>:
{
    800056ae:	7179                	addi	sp,sp,-48
    800056b0:	f406                	sd	ra,40(sp)
    800056b2:	f022                	sd	s0,32(sp)
    800056b4:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800056b6:	fd840593          	addi	a1,s0,-40
    800056ba:	4505                	li	a0,1
    800056bc:	ffffd097          	auipc	ra,0xffffd
    800056c0:	710080e7          	jalr	1808(ra) # 80002dcc <argaddr>
  argint(2, &n);
    800056c4:	fe440593          	addi	a1,s0,-28
    800056c8:	4509                	li	a0,2
    800056ca:	ffffd097          	auipc	ra,0xffffd
    800056ce:	6e0080e7          	jalr	1760(ra) # 80002daa <argint>
  if(argfd(0, 0, &f) < 0)
    800056d2:	fe840613          	addi	a2,s0,-24
    800056d6:	4581                	li	a1,0
    800056d8:	4501                	li	a0,0
    800056da:	00000097          	auipc	ra,0x0
    800056de:	d58080e7          	jalr	-680(ra) # 80005432 <argfd>
    800056e2:	87aa                	mv	a5,a0
    return -1;
    800056e4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800056e6:	0007cc63          	bltz	a5,800056fe <sys_read+0x50>
  return fileread(f, p, n);
    800056ea:	fe442603          	lw	a2,-28(s0)
    800056ee:	fd843583          	ld	a1,-40(s0)
    800056f2:	fe843503          	ld	a0,-24(s0)
    800056f6:	fffff097          	auipc	ra,0xfffff
    800056fa:	44e080e7          	jalr	1102(ra) # 80004b44 <fileread>
}
    800056fe:	70a2                	ld	ra,40(sp)
    80005700:	7402                	ld	s0,32(sp)
    80005702:	6145                	addi	sp,sp,48
    80005704:	8082                	ret

0000000080005706 <sys_write>:
{
    80005706:	7179                	addi	sp,sp,-48
    80005708:	f406                	sd	ra,40(sp)
    8000570a:	f022                	sd	s0,32(sp)
    8000570c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000570e:	fd840593          	addi	a1,s0,-40
    80005712:	4505                	li	a0,1
    80005714:	ffffd097          	auipc	ra,0xffffd
    80005718:	6b8080e7          	jalr	1720(ra) # 80002dcc <argaddr>
  argint(2, &n);
    8000571c:	fe440593          	addi	a1,s0,-28
    80005720:	4509                	li	a0,2
    80005722:	ffffd097          	auipc	ra,0xffffd
    80005726:	688080e7          	jalr	1672(ra) # 80002daa <argint>
  if(argfd(0, 0, &f) < 0)
    8000572a:	fe840613          	addi	a2,s0,-24
    8000572e:	4581                	li	a1,0
    80005730:	4501                	li	a0,0
    80005732:	00000097          	auipc	ra,0x0
    80005736:	d00080e7          	jalr	-768(ra) # 80005432 <argfd>
    8000573a:	87aa                	mv	a5,a0
    return -1;
    8000573c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000573e:	0007cc63          	bltz	a5,80005756 <sys_write+0x50>
  return filewrite(f, p, n);
    80005742:	fe442603          	lw	a2,-28(s0)
    80005746:	fd843583          	ld	a1,-40(s0)
    8000574a:	fe843503          	ld	a0,-24(s0)
    8000574e:	fffff097          	auipc	ra,0xfffff
    80005752:	4b8080e7          	jalr	1208(ra) # 80004c06 <filewrite>
}
    80005756:	70a2                	ld	ra,40(sp)
    80005758:	7402                	ld	s0,32(sp)
    8000575a:	6145                	addi	sp,sp,48
    8000575c:	8082                	ret

000000008000575e <sys_close>:
{
    8000575e:	1101                	addi	sp,sp,-32
    80005760:	ec06                	sd	ra,24(sp)
    80005762:	e822                	sd	s0,16(sp)
    80005764:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005766:	fe040613          	addi	a2,s0,-32
    8000576a:	fec40593          	addi	a1,s0,-20
    8000576e:	4501                	li	a0,0
    80005770:	00000097          	auipc	ra,0x0
    80005774:	cc2080e7          	jalr	-830(ra) # 80005432 <argfd>
    return -1;
    80005778:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000577a:	02054463          	bltz	a0,800057a2 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000577e:	ffffc097          	auipc	ra,0xffffc
    80005782:	248080e7          	jalr	584(ra) # 800019c6 <myproc>
    80005786:	fec42783          	lw	a5,-20(s0)
    8000578a:	07e9                	addi	a5,a5,26
    8000578c:	078e                	slli	a5,a5,0x3
    8000578e:	97aa                	add	a5,a5,a0
    80005790:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005794:	fe043503          	ld	a0,-32(s0)
    80005798:	fffff097          	auipc	ra,0xfffff
    8000579c:	272080e7          	jalr	626(ra) # 80004a0a <fileclose>
  return 0;
    800057a0:	4781                	li	a5,0
}
    800057a2:	853e                	mv	a0,a5
    800057a4:	60e2                	ld	ra,24(sp)
    800057a6:	6442                	ld	s0,16(sp)
    800057a8:	6105                	addi	sp,sp,32
    800057aa:	8082                	ret

00000000800057ac <sys_fstat>:
{
    800057ac:	1101                	addi	sp,sp,-32
    800057ae:	ec06                	sd	ra,24(sp)
    800057b0:	e822                	sd	s0,16(sp)
    800057b2:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800057b4:	fe040593          	addi	a1,s0,-32
    800057b8:	4505                	li	a0,1
    800057ba:	ffffd097          	auipc	ra,0xffffd
    800057be:	612080e7          	jalr	1554(ra) # 80002dcc <argaddr>
  if(argfd(0, 0, &f) < 0)
    800057c2:	fe840613          	addi	a2,s0,-24
    800057c6:	4581                	li	a1,0
    800057c8:	4501                	li	a0,0
    800057ca:	00000097          	auipc	ra,0x0
    800057ce:	c68080e7          	jalr	-920(ra) # 80005432 <argfd>
    800057d2:	87aa                	mv	a5,a0
    return -1;
    800057d4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800057d6:	0007ca63          	bltz	a5,800057ea <sys_fstat+0x3e>
  return filestat(f, st);
    800057da:	fe043583          	ld	a1,-32(s0)
    800057de:	fe843503          	ld	a0,-24(s0)
    800057e2:	fffff097          	auipc	ra,0xfffff
    800057e6:	2f0080e7          	jalr	752(ra) # 80004ad2 <filestat>
}
    800057ea:	60e2                	ld	ra,24(sp)
    800057ec:	6442                	ld	s0,16(sp)
    800057ee:	6105                	addi	sp,sp,32
    800057f0:	8082                	ret

00000000800057f2 <sys_link>:
{
    800057f2:	7169                	addi	sp,sp,-304
    800057f4:	f606                	sd	ra,296(sp)
    800057f6:	f222                	sd	s0,288(sp)
    800057f8:	ee26                	sd	s1,280(sp)
    800057fa:	ea4a                	sd	s2,272(sp)
    800057fc:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800057fe:	08000613          	li	a2,128
    80005802:	ed040593          	addi	a1,s0,-304
    80005806:	4501                	li	a0,0
    80005808:	ffffd097          	auipc	ra,0xffffd
    8000580c:	5e6080e7          	jalr	1510(ra) # 80002dee <argstr>
    return -1;
    80005810:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005812:	10054e63          	bltz	a0,8000592e <sys_link+0x13c>
    80005816:	08000613          	li	a2,128
    8000581a:	f5040593          	addi	a1,s0,-176
    8000581e:	4505                	li	a0,1
    80005820:	ffffd097          	auipc	ra,0xffffd
    80005824:	5ce080e7          	jalr	1486(ra) # 80002dee <argstr>
    return -1;
    80005828:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000582a:	10054263          	bltz	a0,8000592e <sys_link+0x13c>
  begin_op();
    8000582e:	fffff097          	auipc	ra,0xfffff
    80005832:	d10080e7          	jalr	-752(ra) # 8000453e <begin_op>
  if((ip = namei(old)) == 0){
    80005836:	ed040513          	addi	a0,s0,-304
    8000583a:	fffff097          	auipc	ra,0xfffff
    8000583e:	ae8080e7          	jalr	-1304(ra) # 80004322 <namei>
    80005842:	84aa                	mv	s1,a0
    80005844:	c551                	beqz	a0,800058d0 <sys_link+0xde>
  ilock(ip);
    80005846:	ffffe097          	auipc	ra,0xffffe
    8000584a:	336080e7          	jalr	822(ra) # 80003b7c <ilock>
  if(ip->type == T_DIR){
    8000584e:	04449703          	lh	a4,68(s1)
    80005852:	4785                	li	a5,1
    80005854:	08f70463          	beq	a4,a5,800058dc <sys_link+0xea>
  ip->nlink++;
    80005858:	04a4d783          	lhu	a5,74(s1)
    8000585c:	2785                	addiw	a5,a5,1
    8000585e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005862:	8526                	mv	a0,s1
    80005864:	ffffe097          	auipc	ra,0xffffe
    80005868:	24e080e7          	jalr	590(ra) # 80003ab2 <iupdate>
  iunlock(ip);
    8000586c:	8526                	mv	a0,s1
    8000586e:	ffffe097          	auipc	ra,0xffffe
    80005872:	3d0080e7          	jalr	976(ra) # 80003c3e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005876:	fd040593          	addi	a1,s0,-48
    8000587a:	f5040513          	addi	a0,s0,-176
    8000587e:	fffff097          	auipc	ra,0xfffff
    80005882:	ac2080e7          	jalr	-1342(ra) # 80004340 <nameiparent>
    80005886:	892a                	mv	s2,a0
    80005888:	c935                	beqz	a0,800058fc <sys_link+0x10a>
  ilock(dp);
    8000588a:	ffffe097          	auipc	ra,0xffffe
    8000588e:	2f2080e7          	jalr	754(ra) # 80003b7c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005892:	00092703          	lw	a4,0(s2)
    80005896:	409c                	lw	a5,0(s1)
    80005898:	04f71d63          	bne	a4,a5,800058f2 <sys_link+0x100>
    8000589c:	40d0                	lw	a2,4(s1)
    8000589e:	fd040593          	addi	a1,s0,-48
    800058a2:	854a                	mv	a0,s2
    800058a4:	fffff097          	auipc	ra,0xfffff
    800058a8:	9cc080e7          	jalr	-1588(ra) # 80004270 <dirlink>
    800058ac:	04054363          	bltz	a0,800058f2 <sys_link+0x100>
  iunlockput(dp);
    800058b0:	854a                	mv	a0,s2
    800058b2:	ffffe097          	auipc	ra,0xffffe
    800058b6:	52c080e7          	jalr	1324(ra) # 80003dde <iunlockput>
  iput(ip);
    800058ba:	8526                	mv	a0,s1
    800058bc:	ffffe097          	auipc	ra,0xffffe
    800058c0:	47a080e7          	jalr	1146(ra) # 80003d36 <iput>
  end_op();
    800058c4:	fffff097          	auipc	ra,0xfffff
    800058c8:	cfa080e7          	jalr	-774(ra) # 800045be <end_op>
  return 0;
    800058cc:	4781                	li	a5,0
    800058ce:	a085                	j	8000592e <sys_link+0x13c>
    end_op();
    800058d0:	fffff097          	auipc	ra,0xfffff
    800058d4:	cee080e7          	jalr	-786(ra) # 800045be <end_op>
    return -1;
    800058d8:	57fd                	li	a5,-1
    800058da:	a891                	j	8000592e <sys_link+0x13c>
    iunlockput(ip);
    800058dc:	8526                	mv	a0,s1
    800058de:	ffffe097          	auipc	ra,0xffffe
    800058e2:	500080e7          	jalr	1280(ra) # 80003dde <iunlockput>
    end_op();
    800058e6:	fffff097          	auipc	ra,0xfffff
    800058ea:	cd8080e7          	jalr	-808(ra) # 800045be <end_op>
    return -1;
    800058ee:	57fd                	li	a5,-1
    800058f0:	a83d                	j	8000592e <sys_link+0x13c>
    iunlockput(dp);
    800058f2:	854a                	mv	a0,s2
    800058f4:	ffffe097          	auipc	ra,0xffffe
    800058f8:	4ea080e7          	jalr	1258(ra) # 80003dde <iunlockput>
  ilock(ip);
    800058fc:	8526                	mv	a0,s1
    800058fe:	ffffe097          	auipc	ra,0xffffe
    80005902:	27e080e7          	jalr	638(ra) # 80003b7c <ilock>
  ip->nlink--;
    80005906:	04a4d783          	lhu	a5,74(s1)
    8000590a:	37fd                	addiw	a5,a5,-1
    8000590c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005910:	8526                	mv	a0,s1
    80005912:	ffffe097          	auipc	ra,0xffffe
    80005916:	1a0080e7          	jalr	416(ra) # 80003ab2 <iupdate>
  iunlockput(ip);
    8000591a:	8526                	mv	a0,s1
    8000591c:	ffffe097          	auipc	ra,0xffffe
    80005920:	4c2080e7          	jalr	1218(ra) # 80003dde <iunlockput>
  end_op();
    80005924:	fffff097          	auipc	ra,0xfffff
    80005928:	c9a080e7          	jalr	-870(ra) # 800045be <end_op>
  return -1;
    8000592c:	57fd                	li	a5,-1
}
    8000592e:	853e                	mv	a0,a5
    80005930:	70b2                	ld	ra,296(sp)
    80005932:	7412                	ld	s0,288(sp)
    80005934:	64f2                	ld	s1,280(sp)
    80005936:	6952                	ld	s2,272(sp)
    80005938:	6155                	addi	sp,sp,304
    8000593a:	8082                	ret

000000008000593c <sys_unlink>:
{
    8000593c:	7151                	addi	sp,sp,-240
    8000593e:	f586                	sd	ra,232(sp)
    80005940:	f1a2                	sd	s0,224(sp)
    80005942:	eda6                	sd	s1,216(sp)
    80005944:	e9ca                	sd	s2,208(sp)
    80005946:	e5ce                	sd	s3,200(sp)
    80005948:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000594a:	08000613          	li	a2,128
    8000594e:	f3040593          	addi	a1,s0,-208
    80005952:	4501                	li	a0,0
    80005954:	ffffd097          	auipc	ra,0xffffd
    80005958:	49a080e7          	jalr	1178(ra) # 80002dee <argstr>
    8000595c:	18054163          	bltz	a0,80005ade <sys_unlink+0x1a2>
  begin_op();
    80005960:	fffff097          	auipc	ra,0xfffff
    80005964:	bde080e7          	jalr	-1058(ra) # 8000453e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005968:	fb040593          	addi	a1,s0,-80
    8000596c:	f3040513          	addi	a0,s0,-208
    80005970:	fffff097          	auipc	ra,0xfffff
    80005974:	9d0080e7          	jalr	-1584(ra) # 80004340 <nameiparent>
    80005978:	84aa                	mv	s1,a0
    8000597a:	c979                	beqz	a0,80005a50 <sys_unlink+0x114>
  ilock(dp);
    8000597c:	ffffe097          	auipc	ra,0xffffe
    80005980:	200080e7          	jalr	512(ra) # 80003b7c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005984:	00003597          	auipc	a1,0x3
    80005988:	f0c58593          	addi	a1,a1,-244 # 80008890 <syscallnum+0x258>
    8000598c:	fb040513          	addi	a0,s0,-80
    80005990:	ffffe097          	auipc	ra,0xffffe
    80005994:	6b6080e7          	jalr	1718(ra) # 80004046 <namecmp>
    80005998:	14050a63          	beqz	a0,80005aec <sys_unlink+0x1b0>
    8000599c:	00003597          	auipc	a1,0x3
    800059a0:	efc58593          	addi	a1,a1,-260 # 80008898 <syscallnum+0x260>
    800059a4:	fb040513          	addi	a0,s0,-80
    800059a8:	ffffe097          	auipc	ra,0xffffe
    800059ac:	69e080e7          	jalr	1694(ra) # 80004046 <namecmp>
    800059b0:	12050e63          	beqz	a0,80005aec <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800059b4:	f2c40613          	addi	a2,s0,-212
    800059b8:	fb040593          	addi	a1,s0,-80
    800059bc:	8526                	mv	a0,s1
    800059be:	ffffe097          	auipc	ra,0xffffe
    800059c2:	6a2080e7          	jalr	1698(ra) # 80004060 <dirlookup>
    800059c6:	892a                	mv	s2,a0
    800059c8:	12050263          	beqz	a0,80005aec <sys_unlink+0x1b0>
  ilock(ip);
    800059cc:	ffffe097          	auipc	ra,0xffffe
    800059d0:	1b0080e7          	jalr	432(ra) # 80003b7c <ilock>
  if(ip->nlink < 1)
    800059d4:	04a91783          	lh	a5,74(s2)
    800059d8:	08f05263          	blez	a5,80005a5c <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800059dc:	04491703          	lh	a4,68(s2)
    800059e0:	4785                	li	a5,1
    800059e2:	08f70563          	beq	a4,a5,80005a6c <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800059e6:	4641                	li	a2,16
    800059e8:	4581                	li	a1,0
    800059ea:	fc040513          	addi	a0,s0,-64
    800059ee:	ffffb097          	auipc	ra,0xffffb
    800059f2:	2f8080e7          	jalr	760(ra) # 80000ce6 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800059f6:	4741                	li	a4,16
    800059f8:	f2c42683          	lw	a3,-212(s0)
    800059fc:	fc040613          	addi	a2,s0,-64
    80005a00:	4581                	li	a1,0
    80005a02:	8526                	mv	a0,s1
    80005a04:	ffffe097          	auipc	ra,0xffffe
    80005a08:	524080e7          	jalr	1316(ra) # 80003f28 <writei>
    80005a0c:	47c1                	li	a5,16
    80005a0e:	0af51563          	bne	a0,a5,80005ab8 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005a12:	04491703          	lh	a4,68(s2)
    80005a16:	4785                	li	a5,1
    80005a18:	0af70863          	beq	a4,a5,80005ac8 <sys_unlink+0x18c>
  iunlockput(dp);
    80005a1c:	8526                	mv	a0,s1
    80005a1e:	ffffe097          	auipc	ra,0xffffe
    80005a22:	3c0080e7          	jalr	960(ra) # 80003dde <iunlockput>
  ip->nlink--;
    80005a26:	04a95783          	lhu	a5,74(s2)
    80005a2a:	37fd                	addiw	a5,a5,-1
    80005a2c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005a30:	854a                	mv	a0,s2
    80005a32:	ffffe097          	auipc	ra,0xffffe
    80005a36:	080080e7          	jalr	128(ra) # 80003ab2 <iupdate>
  iunlockput(ip);
    80005a3a:	854a                	mv	a0,s2
    80005a3c:	ffffe097          	auipc	ra,0xffffe
    80005a40:	3a2080e7          	jalr	930(ra) # 80003dde <iunlockput>
  end_op();
    80005a44:	fffff097          	auipc	ra,0xfffff
    80005a48:	b7a080e7          	jalr	-1158(ra) # 800045be <end_op>
  return 0;
    80005a4c:	4501                	li	a0,0
    80005a4e:	a84d                	j	80005b00 <sys_unlink+0x1c4>
    end_op();
    80005a50:	fffff097          	auipc	ra,0xfffff
    80005a54:	b6e080e7          	jalr	-1170(ra) # 800045be <end_op>
    return -1;
    80005a58:	557d                	li	a0,-1
    80005a5a:	a05d                	j	80005b00 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005a5c:	00003517          	auipc	a0,0x3
    80005a60:	e4450513          	addi	a0,a0,-444 # 800088a0 <syscallnum+0x268>
    80005a64:	ffffb097          	auipc	ra,0xffffb
    80005a68:	ae0080e7          	jalr	-1312(ra) # 80000544 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005a6c:	04c92703          	lw	a4,76(s2)
    80005a70:	02000793          	li	a5,32
    80005a74:	f6e7f9e3          	bgeu	a5,a4,800059e6 <sys_unlink+0xaa>
    80005a78:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005a7c:	4741                	li	a4,16
    80005a7e:	86ce                	mv	a3,s3
    80005a80:	f1840613          	addi	a2,s0,-232
    80005a84:	4581                	li	a1,0
    80005a86:	854a                	mv	a0,s2
    80005a88:	ffffe097          	auipc	ra,0xffffe
    80005a8c:	3a8080e7          	jalr	936(ra) # 80003e30 <readi>
    80005a90:	47c1                	li	a5,16
    80005a92:	00f51b63          	bne	a0,a5,80005aa8 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005a96:	f1845783          	lhu	a5,-232(s0)
    80005a9a:	e7a1                	bnez	a5,80005ae2 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005a9c:	29c1                	addiw	s3,s3,16
    80005a9e:	04c92783          	lw	a5,76(s2)
    80005aa2:	fcf9ede3          	bltu	s3,a5,80005a7c <sys_unlink+0x140>
    80005aa6:	b781                	j	800059e6 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005aa8:	00003517          	auipc	a0,0x3
    80005aac:	e1050513          	addi	a0,a0,-496 # 800088b8 <syscallnum+0x280>
    80005ab0:	ffffb097          	auipc	ra,0xffffb
    80005ab4:	a94080e7          	jalr	-1388(ra) # 80000544 <panic>
    panic("unlink: writei");
    80005ab8:	00003517          	auipc	a0,0x3
    80005abc:	e1850513          	addi	a0,a0,-488 # 800088d0 <syscallnum+0x298>
    80005ac0:	ffffb097          	auipc	ra,0xffffb
    80005ac4:	a84080e7          	jalr	-1404(ra) # 80000544 <panic>
    dp->nlink--;
    80005ac8:	04a4d783          	lhu	a5,74(s1)
    80005acc:	37fd                	addiw	a5,a5,-1
    80005ace:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005ad2:	8526                	mv	a0,s1
    80005ad4:	ffffe097          	auipc	ra,0xffffe
    80005ad8:	fde080e7          	jalr	-34(ra) # 80003ab2 <iupdate>
    80005adc:	b781                	j	80005a1c <sys_unlink+0xe0>
    return -1;
    80005ade:	557d                	li	a0,-1
    80005ae0:	a005                	j	80005b00 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005ae2:	854a                	mv	a0,s2
    80005ae4:	ffffe097          	auipc	ra,0xffffe
    80005ae8:	2fa080e7          	jalr	762(ra) # 80003dde <iunlockput>
  iunlockput(dp);
    80005aec:	8526                	mv	a0,s1
    80005aee:	ffffe097          	auipc	ra,0xffffe
    80005af2:	2f0080e7          	jalr	752(ra) # 80003dde <iunlockput>
  end_op();
    80005af6:	fffff097          	auipc	ra,0xfffff
    80005afa:	ac8080e7          	jalr	-1336(ra) # 800045be <end_op>
  return -1;
    80005afe:	557d                	li	a0,-1
}
    80005b00:	70ae                	ld	ra,232(sp)
    80005b02:	740e                	ld	s0,224(sp)
    80005b04:	64ee                	ld	s1,216(sp)
    80005b06:	694e                	ld	s2,208(sp)
    80005b08:	69ae                	ld	s3,200(sp)
    80005b0a:	616d                	addi	sp,sp,240
    80005b0c:	8082                	ret

0000000080005b0e <sys_open>:

uint64
sys_open(void)
{
    80005b0e:	7131                	addi	sp,sp,-192
    80005b10:	fd06                	sd	ra,184(sp)
    80005b12:	f922                	sd	s0,176(sp)
    80005b14:	f526                	sd	s1,168(sp)
    80005b16:	f14a                	sd	s2,160(sp)
    80005b18:	ed4e                	sd	s3,152(sp)
    80005b1a:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005b1c:	f4c40593          	addi	a1,s0,-180
    80005b20:	4505                	li	a0,1
    80005b22:	ffffd097          	auipc	ra,0xffffd
    80005b26:	288080e7          	jalr	648(ra) # 80002daa <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005b2a:	08000613          	li	a2,128
    80005b2e:	f5040593          	addi	a1,s0,-176
    80005b32:	4501                	li	a0,0
    80005b34:	ffffd097          	auipc	ra,0xffffd
    80005b38:	2ba080e7          	jalr	698(ra) # 80002dee <argstr>
    80005b3c:	87aa                	mv	a5,a0
    return -1;
    80005b3e:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005b40:	0a07c963          	bltz	a5,80005bf2 <sys_open+0xe4>

  begin_op();
    80005b44:	fffff097          	auipc	ra,0xfffff
    80005b48:	9fa080e7          	jalr	-1542(ra) # 8000453e <begin_op>

  if(omode & O_CREATE){
    80005b4c:	f4c42783          	lw	a5,-180(s0)
    80005b50:	2007f793          	andi	a5,a5,512
    80005b54:	cfc5                	beqz	a5,80005c0c <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005b56:	4681                	li	a3,0
    80005b58:	4601                	li	a2,0
    80005b5a:	4589                	li	a1,2
    80005b5c:	f5040513          	addi	a0,s0,-176
    80005b60:	00000097          	auipc	ra,0x0
    80005b64:	974080e7          	jalr	-1676(ra) # 800054d4 <create>
    80005b68:	84aa                	mv	s1,a0
    if(ip == 0){
    80005b6a:	c959                	beqz	a0,80005c00 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005b6c:	04449703          	lh	a4,68(s1)
    80005b70:	478d                	li	a5,3
    80005b72:	00f71763          	bne	a4,a5,80005b80 <sys_open+0x72>
    80005b76:	0464d703          	lhu	a4,70(s1)
    80005b7a:	47a5                	li	a5,9
    80005b7c:	0ce7ed63          	bltu	a5,a4,80005c56 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005b80:	fffff097          	auipc	ra,0xfffff
    80005b84:	dce080e7          	jalr	-562(ra) # 8000494e <filealloc>
    80005b88:	89aa                	mv	s3,a0
    80005b8a:	10050363          	beqz	a0,80005c90 <sys_open+0x182>
    80005b8e:	00000097          	auipc	ra,0x0
    80005b92:	904080e7          	jalr	-1788(ra) # 80005492 <fdalloc>
    80005b96:	892a                	mv	s2,a0
    80005b98:	0e054763          	bltz	a0,80005c86 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005b9c:	04449703          	lh	a4,68(s1)
    80005ba0:	478d                	li	a5,3
    80005ba2:	0cf70563          	beq	a4,a5,80005c6c <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005ba6:	4789                	li	a5,2
    80005ba8:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005bac:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005bb0:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005bb4:	f4c42783          	lw	a5,-180(s0)
    80005bb8:	0017c713          	xori	a4,a5,1
    80005bbc:	8b05                	andi	a4,a4,1
    80005bbe:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005bc2:	0037f713          	andi	a4,a5,3
    80005bc6:	00e03733          	snez	a4,a4
    80005bca:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005bce:	4007f793          	andi	a5,a5,1024
    80005bd2:	c791                	beqz	a5,80005bde <sys_open+0xd0>
    80005bd4:	04449703          	lh	a4,68(s1)
    80005bd8:	4789                	li	a5,2
    80005bda:	0af70063          	beq	a4,a5,80005c7a <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005bde:	8526                	mv	a0,s1
    80005be0:	ffffe097          	auipc	ra,0xffffe
    80005be4:	05e080e7          	jalr	94(ra) # 80003c3e <iunlock>
  end_op();
    80005be8:	fffff097          	auipc	ra,0xfffff
    80005bec:	9d6080e7          	jalr	-1578(ra) # 800045be <end_op>

  return fd;
    80005bf0:	854a                	mv	a0,s2
}
    80005bf2:	70ea                	ld	ra,184(sp)
    80005bf4:	744a                	ld	s0,176(sp)
    80005bf6:	74aa                	ld	s1,168(sp)
    80005bf8:	790a                	ld	s2,160(sp)
    80005bfa:	69ea                	ld	s3,152(sp)
    80005bfc:	6129                	addi	sp,sp,192
    80005bfe:	8082                	ret
      end_op();
    80005c00:	fffff097          	auipc	ra,0xfffff
    80005c04:	9be080e7          	jalr	-1602(ra) # 800045be <end_op>
      return -1;
    80005c08:	557d                	li	a0,-1
    80005c0a:	b7e5                	j	80005bf2 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005c0c:	f5040513          	addi	a0,s0,-176
    80005c10:	ffffe097          	auipc	ra,0xffffe
    80005c14:	712080e7          	jalr	1810(ra) # 80004322 <namei>
    80005c18:	84aa                	mv	s1,a0
    80005c1a:	c905                	beqz	a0,80005c4a <sys_open+0x13c>
    ilock(ip);
    80005c1c:	ffffe097          	auipc	ra,0xffffe
    80005c20:	f60080e7          	jalr	-160(ra) # 80003b7c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005c24:	04449703          	lh	a4,68(s1)
    80005c28:	4785                	li	a5,1
    80005c2a:	f4f711e3          	bne	a4,a5,80005b6c <sys_open+0x5e>
    80005c2e:	f4c42783          	lw	a5,-180(s0)
    80005c32:	d7b9                	beqz	a5,80005b80 <sys_open+0x72>
      iunlockput(ip);
    80005c34:	8526                	mv	a0,s1
    80005c36:	ffffe097          	auipc	ra,0xffffe
    80005c3a:	1a8080e7          	jalr	424(ra) # 80003dde <iunlockput>
      end_op();
    80005c3e:	fffff097          	auipc	ra,0xfffff
    80005c42:	980080e7          	jalr	-1664(ra) # 800045be <end_op>
      return -1;
    80005c46:	557d                	li	a0,-1
    80005c48:	b76d                	j	80005bf2 <sys_open+0xe4>
      end_op();
    80005c4a:	fffff097          	auipc	ra,0xfffff
    80005c4e:	974080e7          	jalr	-1676(ra) # 800045be <end_op>
      return -1;
    80005c52:	557d                	li	a0,-1
    80005c54:	bf79                	j	80005bf2 <sys_open+0xe4>
    iunlockput(ip);
    80005c56:	8526                	mv	a0,s1
    80005c58:	ffffe097          	auipc	ra,0xffffe
    80005c5c:	186080e7          	jalr	390(ra) # 80003dde <iunlockput>
    end_op();
    80005c60:	fffff097          	auipc	ra,0xfffff
    80005c64:	95e080e7          	jalr	-1698(ra) # 800045be <end_op>
    return -1;
    80005c68:	557d                	li	a0,-1
    80005c6a:	b761                	j	80005bf2 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005c6c:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005c70:	04649783          	lh	a5,70(s1)
    80005c74:	02f99223          	sh	a5,36(s3)
    80005c78:	bf25                	j	80005bb0 <sys_open+0xa2>
    itrunc(ip);
    80005c7a:	8526                	mv	a0,s1
    80005c7c:	ffffe097          	auipc	ra,0xffffe
    80005c80:	00e080e7          	jalr	14(ra) # 80003c8a <itrunc>
    80005c84:	bfa9                	j	80005bde <sys_open+0xd0>
      fileclose(f);
    80005c86:	854e                	mv	a0,s3
    80005c88:	fffff097          	auipc	ra,0xfffff
    80005c8c:	d82080e7          	jalr	-638(ra) # 80004a0a <fileclose>
    iunlockput(ip);
    80005c90:	8526                	mv	a0,s1
    80005c92:	ffffe097          	auipc	ra,0xffffe
    80005c96:	14c080e7          	jalr	332(ra) # 80003dde <iunlockput>
    end_op();
    80005c9a:	fffff097          	auipc	ra,0xfffff
    80005c9e:	924080e7          	jalr	-1756(ra) # 800045be <end_op>
    return -1;
    80005ca2:	557d                	li	a0,-1
    80005ca4:	b7b9                	j	80005bf2 <sys_open+0xe4>

0000000080005ca6 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005ca6:	7175                	addi	sp,sp,-144
    80005ca8:	e506                	sd	ra,136(sp)
    80005caa:	e122                	sd	s0,128(sp)
    80005cac:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005cae:	fffff097          	auipc	ra,0xfffff
    80005cb2:	890080e7          	jalr	-1904(ra) # 8000453e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005cb6:	08000613          	li	a2,128
    80005cba:	f7040593          	addi	a1,s0,-144
    80005cbe:	4501                	li	a0,0
    80005cc0:	ffffd097          	auipc	ra,0xffffd
    80005cc4:	12e080e7          	jalr	302(ra) # 80002dee <argstr>
    80005cc8:	02054963          	bltz	a0,80005cfa <sys_mkdir+0x54>
    80005ccc:	4681                	li	a3,0
    80005cce:	4601                	li	a2,0
    80005cd0:	4585                	li	a1,1
    80005cd2:	f7040513          	addi	a0,s0,-144
    80005cd6:	fffff097          	auipc	ra,0xfffff
    80005cda:	7fe080e7          	jalr	2046(ra) # 800054d4 <create>
    80005cde:	cd11                	beqz	a0,80005cfa <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005ce0:	ffffe097          	auipc	ra,0xffffe
    80005ce4:	0fe080e7          	jalr	254(ra) # 80003dde <iunlockput>
  end_op();
    80005ce8:	fffff097          	auipc	ra,0xfffff
    80005cec:	8d6080e7          	jalr	-1834(ra) # 800045be <end_op>
  return 0;
    80005cf0:	4501                	li	a0,0
}
    80005cf2:	60aa                	ld	ra,136(sp)
    80005cf4:	640a                	ld	s0,128(sp)
    80005cf6:	6149                	addi	sp,sp,144
    80005cf8:	8082                	ret
    end_op();
    80005cfa:	fffff097          	auipc	ra,0xfffff
    80005cfe:	8c4080e7          	jalr	-1852(ra) # 800045be <end_op>
    return -1;
    80005d02:	557d                	li	a0,-1
    80005d04:	b7fd                	j	80005cf2 <sys_mkdir+0x4c>

0000000080005d06 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005d06:	7135                	addi	sp,sp,-160
    80005d08:	ed06                	sd	ra,152(sp)
    80005d0a:	e922                	sd	s0,144(sp)
    80005d0c:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005d0e:	fffff097          	auipc	ra,0xfffff
    80005d12:	830080e7          	jalr	-2000(ra) # 8000453e <begin_op>
  argint(1, &major);
    80005d16:	f6c40593          	addi	a1,s0,-148
    80005d1a:	4505                	li	a0,1
    80005d1c:	ffffd097          	auipc	ra,0xffffd
    80005d20:	08e080e7          	jalr	142(ra) # 80002daa <argint>
  argint(2, &minor);
    80005d24:	f6840593          	addi	a1,s0,-152
    80005d28:	4509                	li	a0,2
    80005d2a:	ffffd097          	auipc	ra,0xffffd
    80005d2e:	080080e7          	jalr	128(ra) # 80002daa <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005d32:	08000613          	li	a2,128
    80005d36:	f7040593          	addi	a1,s0,-144
    80005d3a:	4501                	li	a0,0
    80005d3c:	ffffd097          	auipc	ra,0xffffd
    80005d40:	0b2080e7          	jalr	178(ra) # 80002dee <argstr>
    80005d44:	02054b63          	bltz	a0,80005d7a <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005d48:	f6841683          	lh	a3,-152(s0)
    80005d4c:	f6c41603          	lh	a2,-148(s0)
    80005d50:	458d                	li	a1,3
    80005d52:	f7040513          	addi	a0,s0,-144
    80005d56:	fffff097          	auipc	ra,0xfffff
    80005d5a:	77e080e7          	jalr	1918(ra) # 800054d4 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005d5e:	cd11                	beqz	a0,80005d7a <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d60:	ffffe097          	auipc	ra,0xffffe
    80005d64:	07e080e7          	jalr	126(ra) # 80003dde <iunlockput>
  end_op();
    80005d68:	fffff097          	auipc	ra,0xfffff
    80005d6c:	856080e7          	jalr	-1962(ra) # 800045be <end_op>
  return 0;
    80005d70:	4501                	li	a0,0
}
    80005d72:	60ea                	ld	ra,152(sp)
    80005d74:	644a                	ld	s0,144(sp)
    80005d76:	610d                	addi	sp,sp,160
    80005d78:	8082                	ret
    end_op();
    80005d7a:	fffff097          	auipc	ra,0xfffff
    80005d7e:	844080e7          	jalr	-1980(ra) # 800045be <end_op>
    return -1;
    80005d82:	557d                	li	a0,-1
    80005d84:	b7fd                	j	80005d72 <sys_mknod+0x6c>

0000000080005d86 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005d86:	7135                	addi	sp,sp,-160
    80005d88:	ed06                	sd	ra,152(sp)
    80005d8a:	e922                	sd	s0,144(sp)
    80005d8c:	e526                	sd	s1,136(sp)
    80005d8e:	e14a                	sd	s2,128(sp)
    80005d90:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005d92:	ffffc097          	auipc	ra,0xffffc
    80005d96:	c34080e7          	jalr	-972(ra) # 800019c6 <myproc>
    80005d9a:	892a                	mv	s2,a0
  
  begin_op();
    80005d9c:	ffffe097          	auipc	ra,0xffffe
    80005da0:	7a2080e7          	jalr	1954(ra) # 8000453e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005da4:	08000613          	li	a2,128
    80005da8:	f6040593          	addi	a1,s0,-160
    80005dac:	4501                	li	a0,0
    80005dae:	ffffd097          	auipc	ra,0xffffd
    80005db2:	040080e7          	jalr	64(ra) # 80002dee <argstr>
    80005db6:	04054b63          	bltz	a0,80005e0c <sys_chdir+0x86>
    80005dba:	f6040513          	addi	a0,s0,-160
    80005dbe:	ffffe097          	auipc	ra,0xffffe
    80005dc2:	564080e7          	jalr	1380(ra) # 80004322 <namei>
    80005dc6:	84aa                	mv	s1,a0
    80005dc8:	c131                	beqz	a0,80005e0c <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005dca:	ffffe097          	auipc	ra,0xffffe
    80005dce:	db2080e7          	jalr	-590(ra) # 80003b7c <ilock>
  if(ip->type != T_DIR){
    80005dd2:	04449703          	lh	a4,68(s1)
    80005dd6:	4785                	li	a5,1
    80005dd8:	04f71063          	bne	a4,a5,80005e18 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005ddc:	8526                	mv	a0,s1
    80005dde:	ffffe097          	auipc	ra,0xffffe
    80005de2:	e60080e7          	jalr	-416(ra) # 80003c3e <iunlock>
  iput(p->cwd);
    80005de6:	15093503          	ld	a0,336(s2)
    80005dea:	ffffe097          	auipc	ra,0xffffe
    80005dee:	f4c080e7          	jalr	-180(ra) # 80003d36 <iput>
  end_op();
    80005df2:	ffffe097          	auipc	ra,0xffffe
    80005df6:	7cc080e7          	jalr	1996(ra) # 800045be <end_op>
  p->cwd = ip;
    80005dfa:	14993823          	sd	s1,336(s2)
  return 0;
    80005dfe:	4501                	li	a0,0
}
    80005e00:	60ea                	ld	ra,152(sp)
    80005e02:	644a                	ld	s0,144(sp)
    80005e04:	64aa                	ld	s1,136(sp)
    80005e06:	690a                	ld	s2,128(sp)
    80005e08:	610d                	addi	sp,sp,160
    80005e0a:	8082                	ret
    end_op();
    80005e0c:	ffffe097          	auipc	ra,0xffffe
    80005e10:	7b2080e7          	jalr	1970(ra) # 800045be <end_op>
    return -1;
    80005e14:	557d                	li	a0,-1
    80005e16:	b7ed                	j	80005e00 <sys_chdir+0x7a>
    iunlockput(ip);
    80005e18:	8526                	mv	a0,s1
    80005e1a:	ffffe097          	auipc	ra,0xffffe
    80005e1e:	fc4080e7          	jalr	-60(ra) # 80003dde <iunlockput>
    end_op();
    80005e22:	ffffe097          	auipc	ra,0xffffe
    80005e26:	79c080e7          	jalr	1948(ra) # 800045be <end_op>
    return -1;
    80005e2a:	557d                	li	a0,-1
    80005e2c:	bfd1                	j	80005e00 <sys_chdir+0x7a>

0000000080005e2e <sys_exec>:

uint64
sys_exec(void)
{
    80005e2e:	7145                	addi	sp,sp,-464
    80005e30:	e786                	sd	ra,456(sp)
    80005e32:	e3a2                	sd	s0,448(sp)
    80005e34:	ff26                	sd	s1,440(sp)
    80005e36:	fb4a                	sd	s2,432(sp)
    80005e38:	f74e                	sd	s3,424(sp)
    80005e3a:	f352                	sd	s4,416(sp)
    80005e3c:	ef56                	sd	s5,408(sp)
    80005e3e:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005e40:	e3840593          	addi	a1,s0,-456
    80005e44:	4505                	li	a0,1
    80005e46:	ffffd097          	auipc	ra,0xffffd
    80005e4a:	f86080e7          	jalr	-122(ra) # 80002dcc <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005e4e:	08000613          	li	a2,128
    80005e52:	f4040593          	addi	a1,s0,-192
    80005e56:	4501                	li	a0,0
    80005e58:	ffffd097          	auipc	ra,0xffffd
    80005e5c:	f96080e7          	jalr	-106(ra) # 80002dee <argstr>
    80005e60:	87aa                	mv	a5,a0
    return -1;
    80005e62:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005e64:	0c07c263          	bltz	a5,80005f28 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005e68:	10000613          	li	a2,256
    80005e6c:	4581                	li	a1,0
    80005e6e:	e4040513          	addi	a0,s0,-448
    80005e72:	ffffb097          	auipc	ra,0xffffb
    80005e76:	e74080e7          	jalr	-396(ra) # 80000ce6 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005e7a:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005e7e:	89a6                	mv	s3,s1
    80005e80:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005e82:	02000a13          	li	s4,32
    80005e86:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005e8a:	00391513          	slli	a0,s2,0x3
    80005e8e:	e3040593          	addi	a1,s0,-464
    80005e92:	e3843783          	ld	a5,-456(s0)
    80005e96:	953e                	add	a0,a0,a5
    80005e98:	ffffd097          	auipc	ra,0xffffd
    80005e9c:	e74080e7          	jalr	-396(ra) # 80002d0c <fetchaddr>
    80005ea0:	02054a63          	bltz	a0,80005ed4 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005ea4:	e3043783          	ld	a5,-464(s0)
    80005ea8:	c3b9                	beqz	a5,80005eee <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005eaa:	ffffb097          	auipc	ra,0xffffb
    80005eae:	c50080e7          	jalr	-944(ra) # 80000afa <kalloc>
    80005eb2:	85aa                	mv	a1,a0
    80005eb4:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005eb8:	cd11                	beqz	a0,80005ed4 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005eba:	6605                	lui	a2,0x1
    80005ebc:	e3043503          	ld	a0,-464(s0)
    80005ec0:	ffffd097          	auipc	ra,0xffffd
    80005ec4:	e9e080e7          	jalr	-354(ra) # 80002d5e <fetchstr>
    80005ec8:	00054663          	bltz	a0,80005ed4 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005ecc:	0905                	addi	s2,s2,1
    80005ece:	09a1                	addi	s3,s3,8
    80005ed0:	fb491be3          	bne	s2,s4,80005e86 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ed4:	10048913          	addi	s2,s1,256
    80005ed8:	6088                	ld	a0,0(s1)
    80005eda:	c531                	beqz	a0,80005f26 <sys_exec+0xf8>
    kfree(argv[i]);
    80005edc:	ffffb097          	auipc	ra,0xffffb
    80005ee0:	b22080e7          	jalr	-1246(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ee4:	04a1                	addi	s1,s1,8
    80005ee6:	ff2499e3          	bne	s1,s2,80005ed8 <sys_exec+0xaa>
  return -1;
    80005eea:	557d                	li	a0,-1
    80005eec:	a835                	j	80005f28 <sys_exec+0xfa>
      argv[i] = 0;
    80005eee:	0a8e                	slli	s5,s5,0x3
    80005ef0:	fc040793          	addi	a5,s0,-64
    80005ef4:	9abe                	add	s5,s5,a5
    80005ef6:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005efa:	e4040593          	addi	a1,s0,-448
    80005efe:	f4040513          	addi	a0,s0,-192
    80005f02:	fffff097          	auipc	ra,0xfffff
    80005f06:	190080e7          	jalr	400(ra) # 80005092 <exec>
    80005f0a:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f0c:	10048993          	addi	s3,s1,256
    80005f10:	6088                	ld	a0,0(s1)
    80005f12:	c901                	beqz	a0,80005f22 <sys_exec+0xf4>
    kfree(argv[i]);
    80005f14:	ffffb097          	auipc	ra,0xffffb
    80005f18:	aea080e7          	jalr	-1302(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f1c:	04a1                	addi	s1,s1,8
    80005f1e:	ff3499e3          	bne	s1,s3,80005f10 <sys_exec+0xe2>
  return ret;
    80005f22:	854a                	mv	a0,s2
    80005f24:	a011                	j	80005f28 <sys_exec+0xfa>
  return -1;
    80005f26:	557d                	li	a0,-1
}
    80005f28:	60be                	ld	ra,456(sp)
    80005f2a:	641e                	ld	s0,448(sp)
    80005f2c:	74fa                	ld	s1,440(sp)
    80005f2e:	795a                	ld	s2,432(sp)
    80005f30:	79ba                	ld	s3,424(sp)
    80005f32:	7a1a                	ld	s4,416(sp)
    80005f34:	6afa                	ld	s5,408(sp)
    80005f36:	6179                	addi	sp,sp,464
    80005f38:	8082                	ret

0000000080005f3a <sys_pipe>:

uint64
sys_pipe(void)
{
    80005f3a:	7139                	addi	sp,sp,-64
    80005f3c:	fc06                	sd	ra,56(sp)
    80005f3e:	f822                	sd	s0,48(sp)
    80005f40:	f426                	sd	s1,40(sp)
    80005f42:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005f44:	ffffc097          	auipc	ra,0xffffc
    80005f48:	a82080e7          	jalr	-1406(ra) # 800019c6 <myproc>
    80005f4c:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005f4e:	fd840593          	addi	a1,s0,-40
    80005f52:	4501                	li	a0,0
    80005f54:	ffffd097          	auipc	ra,0xffffd
    80005f58:	e78080e7          	jalr	-392(ra) # 80002dcc <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005f5c:	fc840593          	addi	a1,s0,-56
    80005f60:	fd040513          	addi	a0,s0,-48
    80005f64:	fffff097          	auipc	ra,0xfffff
    80005f68:	dd6080e7          	jalr	-554(ra) # 80004d3a <pipealloc>
    return -1;
    80005f6c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005f6e:	0c054463          	bltz	a0,80006036 <sys_pipe+0xfc>
  fd0 = -1;
    80005f72:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005f76:	fd043503          	ld	a0,-48(s0)
    80005f7a:	fffff097          	auipc	ra,0xfffff
    80005f7e:	518080e7          	jalr	1304(ra) # 80005492 <fdalloc>
    80005f82:	fca42223          	sw	a0,-60(s0)
    80005f86:	08054b63          	bltz	a0,8000601c <sys_pipe+0xe2>
    80005f8a:	fc843503          	ld	a0,-56(s0)
    80005f8e:	fffff097          	auipc	ra,0xfffff
    80005f92:	504080e7          	jalr	1284(ra) # 80005492 <fdalloc>
    80005f96:	fca42023          	sw	a0,-64(s0)
    80005f9a:	06054863          	bltz	a0,8000600a <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f9e:	4691                	li	a3,4
    80005fa0:	fc440613          	addi	a2,s0,-60
    80005fa4:	fd843583          	ld	a1,-40(s0)
    80005fa8:	68a8                	ld	a0,80(s1)
    80005faa:	ffffb097          	auipc	ra,0xffffb
    80005fae:	6da080e7          	jalr	1754(ra) # 80001684 <copyout>
    80005fb2:	02054063          	bltz	a0,80005fd2 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005fb6:	4691                	li	a3,4
    80005fb8:	fc040613          	addi	a2,s0,-64
    80005fbc:	fd843583          	ld	a1,-40(s0)
    80005fc0:	0591                	addi	a1,a1,4
    80005fc2:	68a8                	ld	a0,80(s1)
    80005fc4:	ffffb097          	auipc	ra,0xffffb
    80005fc8:	6c0080e7          	jalr	1728(ra) # 80001684 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005fcc:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005fce:	06055463          	bgez	a0,80006036 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005fd2:	fc442783          	lw	a5,-60(s0)
    80005fd6:	07e9                	addi	a5,a5,26
    80005fd8:	078e                	slli	a5,a5,0x3
    80005fda:	97a6                	add	a5,a5,s1
    80005fdc:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005fe0:	fc042503          	lw	a0,-64(s0)
    80005fe4:	0569                	addi	a0,a0,26
    80005fe6:	050e                	slli	a0,a0,0x3
    80005fe8:	94aa                	add	s1,s1,a0
    80005fea:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005fee:	fd043503          	ld	a0,-48(s0)
    80005ff2:	fffff097          	auipc	ra,0xfffff
    80005ff6:	a18080e7          	jalr	-1512(ra) # 80004a0a <fileclose>
    fileclose(wf);
    80005ffa:	fc843503          	ld	a0,-56(s0)
    80005ffe:	fffff097          	auipc	ra,0xfffff
    80006002:	a0c080e7          	jalr	-1524(ra) # 80004a0a <fileclose>
    return -1;
    80006006:	57fd                	li	a5,-1
    80006008:	a03d                	j	80006036 <sys_pipe+0xfc>
    if(fd0 >= 0)
    8000600a:	fc442783          	lw	a5,-60(s0)
    8000600e:	0007c763          	bltz	a5,8000601c <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80006012:	07e9                	addi	a5,a5,26
    80006014:	078e                	slli	a5,a5,0x3
    80006016:	94be                	add	s1,s1,a5
    80006018:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000601c:	fd043503          	ld	a0,-48(s0)
    80006020:	fffff097          	auipc	ra,0xfffff
    80006024:	9ea080e7          	jalr	-1558(ra) # 80004a0a <fileclose>
    fileclose(wf);
    80006028:	fc843503          	ld	a0,-56(s0)
    8000602c:	fffff097          	auipc	ra,0xfffff
    80006030:	9de080e7          	jalr	-1570(ra) # 80004a0a <fileclose>
    return -1;
    80006034:	57fd                	li	a5,-1
}
    80006036:	853e                	mv	a0,a5
    80006038:	70e2                	ld	ra,56(sp)
    8000603a:	7442                	ld	s0,48(sp)
    8000603c:	74a2                	ld	s1,40(sp)
    8000603e:	6121                	addi	sp,sp,64
    80006040:	8082                	ret
	...

0000000080006050 <kernelvec>:
    80006050:	7111                	addi	sp,sp,-256
    80006052:	e006                	sd	ra,0(sp)
    80006054:	e40a                	sd	sp,8(sp)
    80006056:	e80e                	sd	gp,16(sp)
    80006058:	ec12                	sd	tp,24(sp)
    8000605a:	f016                	sd	t0,32(sp)
    8000605c:	f41a                	sd	t1,40(sp)
    8000605e:	f81e                	sd	t2,48(sp)
    80006060:	fc22                	sd	s0,56(sp)
    80006062:	e0a6                	sd	s1,64(sp)
    80006064:	e4aa                	sd	a0,72(sp)
    80006066:	e8ae                	sd	a1,80(sp)
    80006068:	ecb2                	sd	a2,88(sp)
    8000606a:	f0b6                	sd	a3,96(sp)
    8000606c:	f4ba                	sd	a4,104(sp)
    8000606e:	f8be                	sd	a5,112(sp)
    80006070:	fcc2                	sd	a6,120(sp)
    80006072:	e146                	sd	a7,128(sp)
    80006074:	e54a                	sd	s2,136(sp)
    80006076:	e94e                	sd	s3,144(sp)
    80006078:	ed52                	sd	s4,152(sp)
    8000607a:	f156                	sd	s5,160(sp)
    8000607c:	f55a                	sd	s6,168(sp)
    8000607e:	f95e                	sd	s7,176(sp)
    80006080:	fd62                	sd	s8,184(sp)
    80006082:	e1e6                	sd	s9,192(sp)
    80006084:	e5ea                	sd	s10,200(sp)
    80006086:	e9ee                	sd	s11,208(sp)
    80006088:	edf2                	sd	t3,216(sp)
    8000608a:	f1f6                	sd	t4,224(sp)
    8000608c:	f5fa                	sd	t5,232(sp)
    8000608e:	f9fe                	sd	t6,240(sp)
    80006090:	b49fc0ef          	jal	ra,80002bd8 <kerneltrap>
    80006094:	6082                	ld	ra,0(sp)
    80006096:	6122                	ld	sp,8(sp)
    80006098:	61c2                	ld	gp,16(sp)
    8000609a:	7282                	ld	t0,32(sp)
    8000609c:	7322                	ld	t1,40(sp)
    8000609e:	73c2                	ld	t2,48(sp)
    800060a0:	7462                	ld	s0,56(sp)
    800060a2:	6486                	ld	s1,64(sp)
    800060a4:	6526                	ld	a0,72(sp)
    800060a6:	65c6                	ld	a1,80(sp)
    800060a8:	6666                	ld	a2,88(sp)
    800060aa:	7686                	ld	a3,96(sp)
    800060ac:	7726                	ld	a4,104(sp)
    800060ae:	77c6                	ld	a5,112(sp)
    800060b0:	7866                	ld	a6,120(sp)
    800060b2:	688a                	ld	a7,128(sp)
    800060b4:	692a                	ld	s2,136(sp)
    800060b6:	69ca                	ld	s3,144(sp)
    800060b8:	6a6a                	ld	s4,152(sp)
    800060ba:	7a8a                	ld	s5,160(sp)
    800060bc:	7b2a                	ld	s6,168(sp)
    800060be:	7bca                	ld	s7,176(sp)
    800060c0:	7c6a                	ld	s8,184(sp)
    800060c2:	6c8e                	ld	s9,192(sp)
    800060c4:	6d2e                	ld	s10,200(sp)
    800060c6:	6dce                	ld	s11,208(sp)
    800060c8:	6e6e                	ld	t3,216(sp)
    800060ca:	7e8e                	ld	t4,224(sp)
    800060cc:	7f2e                	ld	t5,232(sp)
    800060ce:	7fce                	ld	t6,240(sp)
    800060d0:	6111                	addi	sp,sp,256
    800060d2:	10200073          	sret
    800060d6:	00000013          	nop
    800060da:	00000013          	nop
    800060de:	0001                	nop

00000000800060e0 <timervec>:
    800060e0:	34051573          	csrrw	a0,mscratch,a0
    800060e4:	e10c                	sd	a1,0(a0)
    800060e6:	e510                	sd	a2,8(a0)
    800060e8:	e914                	sd	a3,16(a0)
    800060ea:	6d0c                	ld	a1,24(a0)
    800060ec:	7110                	ld	a2,32(a0)
    800060ee:	6194                	ld	a3,0(a1)
    800060f0:	96b2                	add	a3,a3,a2
    800060f2:	e194                	sd	a3,0(a1)
    800060f4:	4589                	li	a1,2
    800060f6:	14459073          	csrw	sip,a1
    800060fa:	6914                	ld	a3,16(a0)
    800060fc:	6510                	ld	a2,8(a0)
    800060fe:	610c                	ld	a1,0(a0)
    80006100:	34051573          	csrrw	a0,mscratch,a0
    80006104:	30200073          	mret
	...

000000008000610a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000610a:	1141                	addi	sp,sp,-16
    8000610c:	e422                	sd	s0,8(sp)
    8000610e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006110:	0c0007b7          	lui	a5,0xc000
    80006114:	4705                	li	a4,1
    80006116:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006118:	c3d8                	sw	a4,4(a5)
}
    8000611a:	6422                	ld	s0,8(sp)
    8000611c:	0141                	addi	sp,sp,16
    8000611e:	8082                	ret

0000000080006120 <plicinithart>:

void
plicinithart(void)
{
    80006120:	1141                	addi	sp,sp,-16
    80006122:	e406                	sd	ra,8(sp)
    80006124:	e022                	sd	s0,0(sp)
    80006126:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006128:	ffffc097          	auipc	ra,0xffffc
    8000612c:	872080e7          	jalr	-1934(ra) # 8000199a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006130:	0085171b          	slliw	a4,a0,0x8
    80006134:	0c0027b7          	lui	a5,0xc002
    80006138:	97ba                	add	a5,a5,a4
    8000613a:	40200713          	li	a4,1026
    8000613e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006142:	00d5151b          	slliw	a0,a0,0xd
    80006146:	0c2017b7          	lui	a5,0xc201
    8000614a:	953e                	add	a0,a0,a5
    8000614c:	00052023          	sw	zero,0(a0)
}
    80006150:	60a2                	ld	ra,8(sp)
    80006152:	6402                	ld	s0,0(sp)
    80006154:	0141                	addi	sp,sp,16
    80006156:	8082                	ret

0000000080006158 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006158:	1141                	addi	sp,sp,-16
    8000615a:	e406                	sd	ra,8(sp)
    8000615c:	e022                	sd	s0,0(sp)
    8000615e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006160:	ffffc097          	auipc	ra,0xffffc
    80006164:	83a080e7          	jalr	-1990(ra) # 8000199a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006168:	00d5179b          	slliw	a5,a0,0xd
    8000616c:	0c201537          	lui	a0,0xc201
    80006170:	953e                	add	a0,a0,a5
  return irq;
}
    80006172:	4148                	lw	a0,4(a0)
    80006174:	60a2                	ld	ra,8(sp)
    80006176:	6402                	ld	s0,0(sp)
    80006178:	0141                	addi	sp,sp,16
    8000617a:	8082                	ret

000000008000617c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000617c:	1101                	addi	sp,sp,-32
    8000617e:	ec06                	sd	ra,24(sp)
    80006180:	e822                	sd	s0,16(sp)
    80006182:	e426                	sd	s1,8(sp)
    80006184:	1000                	addi	s0,sp,32
    80006186:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006188:	ffffc097          	auipc	ra,0xffffc
    8000618c:	812080e7          	jalr	-2030(ra) # 8000199a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006190:	00d5151b          	slliw	a0,a0,0xd
    80006194:	0c2017b7          	lui	a5,0xc201
    80006198:	97aa                	add	a5,a5,a0
    8000619a:	c3c4                	sw	s1,4(a5)
}
    8000619c:	60e2                	ld	ra,24(sp)
    8000619e:	6442                	ld	s0,16(sp)
    800061a0:	64a2                	ld	s1,8(sp)
    800061a2:	6105                	addi	sp,sp,32
    800061a4:	8082                	ret

00000000800061a6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800061a6:	1141                	addi	sp,sp,-16
    800061a8:	e406                	sd	ra,8(sp)
    800061aa:	e022                	sd	s0,0(sp)
    800061ac:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800061ae:	479d                	li	a5,7
    800061b0:	04a7cc63          	blt	a5,a0,80006208 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800061b4:	0001d797          	auipc	a5,0x1d
    800061b8:	0bc78793          	addi	a5,a5,188 # 80023270 <disk>
    800061bc:	97aa                	add	a5,a5,a0
    800061be:	0187c783          	lbu	a5,24(a5)
    800061c2:	ebb9                	bnez	a5,80006218 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800061c4:	00451613          	slli	a2,a0,0x4
    800061c8:	0001d797          	auipc	a5,0x1d
    800061cc:	0a878793          	addi	a5,a5,168 # 80023270 <disk>
    800061d0:	6394                	ld	a3,0(a5)
    800061d2:	96b2                	add	a3,a3,a2
    800061d4:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800061d8:	6398                	ld	a4,0(a5)
    800061da:	9732                	add	a4,a4,a2
    800061dc:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800061e0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800061e4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800061e8:	953e                	add	a0,a0,a5
    800061ea:	4785                	li	a5,1
    800061ec:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    800061f0:	0001d517          	auipc	a0,0x1d
    800061f4:	09850513          	addi	a0,a0,152 # 80023288 <disk+0x18>
    800061f8:	ffffc097          	auipc	ra,0xffffc
    800061fc:	140080e7          	jalr	320(ra) # 80002338 <wakeup>
}
    80006200:	60a2                	ld	ra,8(sp)
    80006202:	6402                	ld	s0,0(sp)
    80006204:	0141                	addi	sp,sp,16
    80006206:	8082                	ret
    panic("free_desc 1");
    80006208:	00002517          	auipc	a0,0x2
    8000620c:	6d850513          	addi	a0,a0,1752 # 800088e0 <syscallnum+0x2a8>
    80006210:	ffffa097          	auipc	ra,0xffffa
    80006214:	334080e7          	jalr	820(ra) # 80000544 <panic>
    panic("free_desc 2");
    80006218:	00002517          	auipc	a0,0x2
    8000621c:	6d850513          	addi	a0,a0,1752 # 800088f0 <syscallnum+0x2b8>
    80006220:	ffffa097          	auipc	ra,0xffffa
    80006224:	324080e7          	jalr	804(ra) # 80000544 <panic>

0000000080006228 <virtio_disk_init>:
{
    80006228:	1101                	addi	sp,sp,-32
    8000622a:	ec06                	sd	ra,24(sp)
    8000622c:	e822                	sd	s0,16(sp)
    8000622e:	e426                	sd	s1,8(sp)
    80006230:	e04a                	sd	s2,0(sp)
    80006232:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006234:	00002597          	auipc	a1,0x2
    80006238:	6cc58593          	addi	a1,a1,1740 # 80008900 <syscallnum+0x2c8>
    8000623c:	0001d517          	auipc	a0,0x1d
    80006240:	15c50513          	addi	a0,a0,348 # 80023398 <disk+0x128>
    80006244:	ffffb097          	auipc	ra,0xffffb
    80006248:	916080e7          	jalr	-1770(ra) # 80000b5a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000624c:	100017b7          	lui	a5,0x10001
    80006250:	4398                	lw	a4,0(a5)
    80006252:	2701                	sext.w	a4,a4
    80006254:	747277b7          	lui	a5,0x74727
    80006258:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000625c:	14f71e63          	bne	a4,a5,800063b8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006260:	100017b7          	lui	a5,0x10001
    80006264:	43dc                	lw	a5,4(a5)
    80006266:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006268:	4709                	li	a4,2
    8000626a:	14e79763          	bne	a5,a4,800063b8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000626e:	100017b7          	lui	a5,0x10001
    80006272:	479c                	lw	a5,8(a5)
    80006274:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006276:	14e79163          	bne	a5,a4,800063b8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000627a:	100017b7          	lui	a5,0x10001
    8000627e:	47d8                	lw	a4,12(a5)
    80006280:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006282:	554d47b7          	lui	a5,0x554d4
    80006286:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000628a:	12f71763          	bne	a4,a5,800063b8 <virtio_disk_init+0x190>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000628e:	100017b7          	lui	a5,0x10001
    80006292:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006296:	4705                	li	a4,1
    80006298:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000629a:	470d                	li	a4,3
    8000629c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000629e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800062a0:	c7ffe737          	lui	a4,0xc7ffe
    800062a4:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb3af>
    800062a8:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800062aa:	2701                	sext.w	a4,a4
    800062ac:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800062ae:	472d                	li	a4,11
    800062b0:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800062b2:	0707a903          	lw	s2,112(a5)
    800062b6:	2901                	sext.w	s2,s2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800062b8:	00897793          	andi	a5,s2,8
    800062bc:	10078663          	beqz	a5,800063c8 <virtio_disk_init+0x1a0>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800062c0:	100017b7          	lui	a5,0x10001
    800062c4:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800062c8:	43fc                	lw	a5,68(a5)
    800062ca:	2781                	sext.w	a5,a5
    800062cc:	10079663          	bnez	a5,800063d8 <virtio_disk_init+0x1b0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800062d0:	100017b7          	lui	a5,0x10001
    800062d4:	5bdc                	lw	a5,52(a5)
    800062d6:	2781                	sext.w	a5,a5
  if(max == 0)
    800062d8:	10078863          	beqz	a5,800063e8 <virtio_disk_init+0x1c0>
  if(max < NUM)
    800062dc:	471d                	li	a4,7
    800062de:	10f77d63          	bgeu	a4,a5,800063f8 <virtio_disk_init+0x1d0>
  disk.desc = kalloc();
    800062e2:	ffffb097          	auipc	ra,0xffffb
    800062e6:	818080e7          	jalr	-2024(ra) # 80000afa <kalloc>
    800062ea:	0001d497          	auipc	s1,0x1d
    800062ee:	f8648493          	addi	s1,s1,-122 # 80023270 <disk>
    800062f2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800062f4:	ffffb097          	auipc	ra,0xffffb
    800062f8:	806080e7          	jalr	-2042(ra) # 80000afa <kalloc>
    800062fc:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800062fe:	ffffa097          	auipc	ra,0xffffa
    80006302:	7fc080e7          	jalr	2044(ra) # 80000afa <kalloc>
    80006306:	87aa                	mv	a5,a0
    80006308:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    8000630a:	6088                	ld	a0,0(s1)
    8000630c:	cd75                	beqz	a0,80006408 <virtio_disk_init+0x1e0>
    8000630e:	0001d717          	auipc	a4,0x1d
    80006312:	f6a73703          	ld	a4,-150(a4) # 80023278 <disk+0x8>
    80006316:	cb6d                	beqz	a4,80006408 <virtio_disk_init+0x1e0>
    80006318:	cbe5                	beqz	a5,80006408 <virtio_disk_init+0x1e0>
  memset(disk.desc, 0, PGSIZE);
    8000631a:	6605                	lui	a2,0x1
    8000631c:	4581                	li	a1,0
    8000631e:	ffffb097          	auipc	ra,0xffffb
    80006322:	9c8080e7          	jalr	-1592(ra) # 80000ce6 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006326:	0001d497          	auipc	s1,0x1d
    8000632a:	f4a48493          	addi	s1,s1,-182 # 80023270 <disk>
    8000632e:	6605                	lui	a2,0x1
    80006330:	4581                	li	a1,0
    80006332:	6488                	ld	a0,8(s1)
    80006334:	ffffb097          	auipc	ra,0xffffb
    80006338:	9b2080e7          	jalr	-1614(ra) # 80000ce6 <memset>
  memset(disk.used, 0, PGSIZE);
    8000633c:	6605                	lui	a2,0x1
    8000633e:	4581                	li	a1,0
    80006340:	6888                	ld	a0,16(s1)
    80006342:	ffffb097          	auipc	ra,0xffffb
    80006346:	9a4080e7          	jalr	-1628(ra) # 80000ce6 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000634a:	100017b7          	lui	a5,0x10001
    8000634e:	4721                	li	a4,8
    80006350:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006352:	4098                	lw	a4,0(s1)
    80006354:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006358:	40d8                	lw	a4,4(s1)
    8000635a:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000635e:	6498                	ld	a4,8(s1)
    80006360:	0007069b          	sext.w	a3,a4
    80006364:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006368:	9701                	srai	a4,a4,0x20
    8000636a:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000636e:	6898                	ld	a4,16(s1)
    80006370:	0007069b          	sext.w	a3,a4
    80006374:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006378:	9701                	srai	a4,a4,0x20
    8000637a:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000637e:	4685                	li	a3,1
    80006380:	c3f4                	sw	a3,68(a5)
    disk.free[i] = 1;
    80006382:	4705                	li	a4,1
    80006384:	00d48c23          	sb	a3,24(s1)
    80006388:	00e48ca3          	sb	a4,25(s1)
    8000638c:	00e48d23          	sb	a4,26(s1)
    80006390:	00e48da3          	sb	a4,27(s1)
    80006394:	00e48e23          	sb	a4,28(s1)
    80006398:	00e48ea3          	sb	a4,29(s1)
    8000639c:	00e48f23          	sb	a4,30(s1)
    800063a0:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800063a4:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800063a8:	0727a823          	sw	s2,112(a5)
}
    800063ac:	60e2                	ld	ra,24(sp)
    800063ae:	6442                	ld	s0,16(sp)
    800063b0:	64a2                	ld	s1,8(sp)
    800063b2:	6902                	ld	s2,0(sp)
    800063b4:	6105                	addi	sp,sp,32
    800063b6:	8082                	ret
    panic("could not find virtio disk");
    800063b8:	00002517          	auipc	a0,0x2
    800063bc:	55850513          	addi	a0,a0,1368 # 80008910 <syscallnum+0x2d8>
    800063c0:	ffffa097          	auipc	ra,0xffffa
    800063c4:	184080e7          	jalr	388(ra) # 80000544 <panic>
    panic("virtio disk FEATURES_OK unset");
    800063c8:	00002517          	auipc	a0,0x2
    800063cc:	56850513          	addi	a0,a0,1384 # 80008930 <syscallnum+0x2f8>
    800063d0:	ffffa097          	auipc	ra,0xffffa
    800063d4:	174080e7          	jalr	372(ra) # 80000544 <panic>
    panic("virtio disk should not be ready");
    800063d8:	00002517          	auipc	a0,0x2
    800063dc:	57850513          	addi	a0,a0,1400 # 80008950 <syscallnum+0x318>
    800063e0:	ffffa097          	auipc	ra,0xffffa
    800063e4:	164080e7          	jalr	356(ra) # 80000544 <panic>
    panic("virtio disk has no queue 0");
    800063e8:	00002517          	auipc	a0,0x2
    800063ec:	58850513          	addi	a0,a0,1416 # 80008970 <syscallnum+0x338>
    800063f0:	ffffa097          	auipc	ra,0xffffa
    800063f4:	154080e7          	jalr	340(ra) # 80000544 <panic>
    panic("virtio disk max queue too short");
    800063f8:	00002517          	auipc	a0,0x2
    800063fc:	59850513          	addi	a0,a0,1432 # 80008990 <syscallnum+0x358>
    80006400:	ffffa097          	auipc	ra,0xffffa
    80006404:	144080e7          	jalr	324(ra) # 80000544 <panic>
    panic("virtio disk kalloc");
    80006408:	00002517          	auipc	a0,0x2
    8000640c:	5a850513          	addi	a0,a0,1448 # 800089b0 <syscallnum+0x378>
    80006410:	ffffa097          	auipc	ra,0xffffa
    80006414:	134080e7          	jalr	308(ra) # 80000544 <panic>

0000000080006418 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006418:	7159                	addi	sp,sp,-112
    8000641a:	f486                	sd	ra,104(sp)
    8000641c:	f0a2                	sd	s0,96(sp)
    8000641e:	eca6                	sd	s1,88(sp)
    80006420:	e8ca                	sd	s2,80(sp)
    80006422:	e4ce                	sd	s3,72(sp)
    80006424:	e0d2                	sd	s4,64(sp)
    80006426:	fc56                	sd	s5,56(sp)
    80006428:	f85a                	sd	s6,48(sp)
    8000642a:	f45e                	sd	s7,40(sp)
    8000642c:	f062                	sd	s8,32(sp)
    8000642e:	ec66                	sd	s9,24(sp)
    80006430:	e86a                	sd	s10,16(sp)
    80006432:	1880                	addi	s0,sp,112
    80006434:	892a                	mv	s2,a0
    80006436:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006438:	00c52c83          	lw	s9,12(a0)
    8000643c:	001c9c9b          	slliw	s9,s9,0x1
    80006440:	1c82                	slli	s9,s9,0x20
    80006442:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006446:	0001d517          	auipc	a0,0x1d
    8000644a:	f5250513          	addi	a0,a0,-174 # 80023398 <disk+0x128>
    8000644e:	ffffa097          	auipc	ra,0xffffa
    80006452:	79c080e7          	jalr	1948(ra) # 80000bea <acquire>
  for(int i = 0; i < 3; i++){
    80006456:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006458:	4ba1                	li	s7,8
      disk.free[i] = 0;
    8000645a:	0001db17          	auipc	s6,0x1d
    8000645e:	e16b0b13          	addi	s6,s6,-490 # 80023270 <disk>
  for(int i = 0; i < 3; i++){
    80006462:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80006464:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006466:	0001dc17          	auipc	s8,0x1d
    8000646a:	f32c0c13          	addi	s8,s8,-206 # 80023398 <disk+0x128>
    8000646e:	a8b5                	j	800064ea <virtio_disk_rw+0xd2>
      disk.free[i] = 0;
    80006470:	00fb06b3          	add	a3,s6,a5
    80006474:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006478:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000647a:	0207c563          	bltz	a5,800064a4 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000647e:	2485                	addiw	s1,s1,1
    80006480:	0711                	addi	a4,a4,4
    80006482:	1f548a63          	beq	s1,s5,80006676 <virtio_disk_rw+0x25e>
    idx[i] = alloc_desc();
    80006486:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006488:	0001d697          	auipc	a3,0x1d
    8000648c:	de868693          	addi	a3,a3,-536 # 80023270 <disk>
    80006490:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80006492:	0186c583          	lbu	a1,24(a3)
    80006496:	fde9                	bnez	a1,80006470 <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006498:	2785                	addiw	a5,a5,1
    8000649a:	0685                	addi	a3,a3,1
    8000649c:	ff779be3          	bne	a5,s7,80006492 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800064a0:	57fd                	li	a5,-1
    800064a2:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    800064a4:	02905a63          	blez	s1,800064d8 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800064a8:	f9042503          	lw	a0,-112(s0)
    800064ac:	00000097          	auipc	ra,0x0
    800064b0:	cfa080e7          	jalr	-774(ra) # 800061a6 <free_desc>
      for(int j = 0; j < i; j++)
    800064b4:	4785                	li	a5,1
    800064b6:	0297d163          	bge	a5,s1,800064d8 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800064ba:	f9442503          	lw	a0,-108(s0)
    800064be:	00000097          	auipc	ra,0x0
    800064c2:	ce8080e7          	jalr	-792(ra) # 800061a6 <free_desc>
      for(int j = 0; j < i; j++)
    800064c6:	4789                	li	a5,2
    800064c8:	0097d863          	bge	a5,s1,800064d8 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800064cc:	f9842503          	lw	a0,-104(s0)
    800064d0:	00000097          	auipc	ra,0x0
    800064d4:	cd6080e7          	jalr	-810(ra) # 800061a6 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800064d8:	85e2                	mv	a1,s8
    800064da:	0001d517          	auipc	a0,0x1d
    800064de:	dae50513          	addi	a0,a0,-594 # 80023288 <disk+0x18>
    800064e2:	ffffc097          	auipc	ra,0xffffc
    800064e6:	ca6080e7          	jalr	-858(ra) # 80002188 <sleep>
  for(int i = 0; i < 3; i++){
    800064ea:	f9040713          	addi	a4,s0,-112
    800064ee:	84ce                	mv	s1,s3
    800064f0:	bf59                	j	80006486 <virtio_disk_rw+0x6e>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    800064f2:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    800064f6:	00479693          	slli	a3,a5,0x4
    800064fa:	0001d797          	auipc	a5,0x1d
    800064fe:	d7678793          	addi	a5,a5,-650 # 80023270 <disk>
    80006502:	97b6                	add	a5,a5,a3
    80006504:	4685                	li	a3,1
    80006506:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006508:	0001d597          	auipc	a1,0x1d
    8000650c:	d6858593          	addi	a1,a1,-664 # 80023270 <disk>
    80006510:	00a60793          	addi	a5,a2,10
    80006514:	0792                	slli	a5,a5,0x4
    80006516:	97ae                	add	a5,a5,a1
    80006518:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    8000651c:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006520:	f6070693          	addi	a3,a4,-160
    80006524:	619c                	ld	a5,0(a1)
    80006526:	97b6                	add	a5,a5,a3
    80006528:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000652a:	6188                	ld	a0,0(a1)
    8000652c:	96aa                	add	a3,a3,a0
    8000652e:	47c1                	li	a5,16
    80006530:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006532:	4785                	li	a5,1
    80006534:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006538:	f9442783          	lw	a5,-108(s0)
    8000653c:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006540:	0792                	slli	a5,a5,0x4
    80006542:	953e                	add	a0,a0,a5
    80006544:	05890693          	addi	a3,s2,88
    80006548:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000654a:	6188                	ld	a0,0(a1)
    8000654c:	97aa                	add	a5,a5,a0
    8000654e:	40000693          	li	a3,1024
    80006552:	c794                	sw	a3,8(a5)
  if(write)
    80006554:	100d0d63          	beqz	s10,8000666e <virtio_disk_rw+0x256>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006558:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000655c:	00c7d683          	lhu	a3,12(a5)
    80006560:	0016e693          	ori	a3,a3,1
    80006564:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    80006568:	f9842583          	lw	a1,-104(s0)
    8000656c:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006570:	0001d697          	auipc	a3,0x1d
    80006574:	d0068693          	addi	a3,a3,-768 # 80023270 <disk>
    80006578:	00260793          	addi	a5,a2,2
    8000657c:	0792                	slli	a5,a5,0x4
    8000657e:	97b6                	add	a5,a5,a3
    80006580:	587d                	li	a6,-1
    80006582:	01078823          	sb	a6,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006586:	0592                	slli	a1,a1,0x4
    80006588:	952e                	add	a0,a0,a1
    8000658a:	f9070713          	addi	a4,a4,-112
    8000658e:	9736                	add	a4,a4,a3
    80006590:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    80006592:	6298                	ld	a4,0(a3)
    80006594:	972e                	add	a4,a4,a1
    80006596:	4585                	li	a1,1
    80006598:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000659a:	4509                	li	a0,2
    8000659c:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    800065a0:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800065a4:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    800065a8:	0127b423          	sd	s2,8(a5)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800065ac:	6698                	ld	a4,8(a3)
    800065ae:	00275783          	lhu	a5,2(a4)
    800065b2:	8b9d                	andi	a5,a5,7
    800065b4:	0786                	slli	a5,a5,0x1
    800065b6:	97ba                	add	a5,a5,a4
    800065b8:	00c79223          	sh	a2,4(a5)

  __sync_synchronize();
    800065bc:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800065c0:	6698                	ld	a4,8(a3)
    800065c2:	00275783          	lhu	a5,2(a4)
    800065c6:	2785                	addiw	a5,a5,1
    800065c8:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800065cc:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800065d0:	100017b7          	lui	a5,0x10001
    800065d4:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800065d8:	00492703          	lw	a4,4(s2)
    800065dc:	4785                	li	a5,1
    800065de:	02f71163          	bne	a4,a5,80006600 <virtio_disk_rw+0x1e8>
    sleep(b, &disk.vdisk_lock);
    800065e2:	0001d997          	auipc	s3,0x1d
    800065e6:	db698993          	addi	s3,s3,-586 # 80023398 <disk+0x128>
  while(b->disk == 1) {
    800065ea:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800065ec:	85ce                	mv	a1,s3
    800065ee:	854a                	mv	a0,s2
    800065f0:	ffffc097          	auipc	ra,0xffffc
    800065f4:	b98080e7          	jalr	-1128(ra) # 80002188 <sleep>
  while(b->disk == 1) {
    800065f8:	00492783          	lw	a5,4(s2)
    800065fc:	fe9788e3          	beq	a5,s1,800065ec <virtio_disk_rw+0x1d4>
  }

  disk.info[idx[0]].b = 0;
    80006600:	f9042903          	lw	s2,-112(s0)
    80006604:	00290793          	addi	a5,s2,2
    80006608:	00479713          	slli	a4,a5,0x4
    8000660c:	0001d797          	auipc	a5,0x1d
    80006610:	c6478793          	addi	a5,a5,-924 # 80023270 <disk>
    80006614:	97ba                	add	a5,a5,a4
    80006616:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000661a:	0001d997          	auipc	s3,0x1d
    8000661e:	c5698993          	addi	s3,s3,-938 # 80023270 <disk>
    80006622:	00491713          	slli	a4,s2,0x4
    80006626:	0009b783          	ld	a5,0(s3)
    8000662a:	97ba                	add	a5,a5,a4
    8000662c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006630:	854a                	mv	a0,s2
    80006632:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006636:	00000097          	auipc	ra,0x0
    8000663a:	b70080e7          	jalr	-1168(ra) # 800061a6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000663e:	8885                	andi	s1,s1,1
    80006640:	f0ed                	bnez	s1,80006622 <virtio_disk_rw+0x20a>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006642:	0001d517          	auipc	a0,0x1d
    80006646:	d5650513          	addi	a0,a0,-682 # 80023398 <disk+0x128>
    8000664a:	ffffa097          	auipc	ra,0xffffa
    8000664e:	654080e7          	jalr	1620(ra) # 80000c9e <release>
}
    80006652:	70a6                	ld	ra,104(sp)
    80006654:	7406                	ld	s0,96(sp)
    80006656:	64e6                	ld	s1,88(sp)
    80006658:	6946                	ld	s2,80(sp)
    8000665a:	69a6                	ld	s3,72(sp)
    8000665c:	6a06                	ld	s4,64(sp)
    8000665e:	7ae2                	ld	s5,56(sp)
    80006660:	7b42                	ld	s6,48(sp)
    80006662:	7ba2                	ld	s7,40(sp)
    80006664:	7c02                	ld	s8,32(sp)
    80006666:	6ce2                	ld	s9,24(sp)
    80006668:	6d42                	ld	s10,16(sp)
    8000666a:	6165                	addi	sp,sp,112
    8000666c:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000666e:	4689                	li	a3,2
    80006670:	00d79623          	sh	a3,12(a5)
    80006674:	b5e5                	j	8000655c <virtio_disk_rw+0x144>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006676:	f9042603          	lw	a2,-112(s0)
    8000667a:	00a60713          	addi	a4,a2,10
    8000667e:	0712                	slli	a4,a4,0x4
    80006680:	0001d517          	auipc	a0,0x1d
    80006684:	bf850513          	addi	a0,a0,-1032 # 80023278 <disk+0x8>
    80006688:	953a                	add	a0,a0,a4
  if(write)
    8000668a:	e60d14e3          	bnez	s10,800064f2 <virtio_disk_rw+0xda>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    8000668e:	00a60793          	addi	a5,a2,10
    80006692:	00479693          	slli	a3,a5,0x4
    80006696:	0001d797          	auipc	a5,0x1d
    8000669a:	bda78793          	addi	a5,a5,-1062 # 80023270 <disk>
    8000669e:	97b6                	add	a5,a5,a3
    800066a0:	0007a423          	sw	zero,8(a5)
    800066a4:	b595                	j	80006508 <virtio_disk_rw+0xf0>

00000000800066a6 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800066a6:	1101                	addi	sp,sp,-32
    800066a8:	ec06                	sd	ra,24(sp)
    800066aa:	e822                	sd	s0,16(sp)
    800066ac:	e426                	sd	s1,8(sp)
    800066ae:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800066b0:	0001d497          	auipc	s1,0x1d
    800066b4:	bc048493          	addi	s1,s1,-1088 # 80023270 <disk>
    800066b8:	0001d517          	auipc	a0,0x1d
    800066bc:	ce050513          	addi	a0,a0,-800 # 80023398 <disk+0x128>
    800066c0:	ffffa097          	auipc	ra,0xffffa
    800066c4:	52a080e7          	jalr	1322(ra) # 80000bea <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800066c8:	10001737          	lui	a4,0x10001
    800066cc:	533c                	lw	a5,96(a4)
    800066ce:	8b8d                	andi	a5,a5,3
    800066d0:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800066d2:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800066d6:	689c                	ld	a5,16(s1)
    800066d8:	0204d703          	lhu	a4,32(s1)
    800066dc:	0027d783          	lhu	a5,2(a5)
    800066e0:	04f70863          	beq	a4,a5,80006730 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800066e4:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800066e8:	6898                	ld	a4,16(s1)
    800066ea:	0204d783          	lhu	a5,32(s1)
    800066ee:	8b9d                	andi	a5,a5,7
    800066f0:	078e                	slli	a5,a5,0x3
    800066f2:	97ba                	add	a5,a5,a4
    800066f4:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800066f6:	00278713          	addi	a4,a5,2
    800066fa:	0712                	slli	a4,a4,0x4
    800066fc:	9726                	add	a4,a4,s1
    800066fe:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006702:	e721                	bnez	a4,8000674a <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006704:	0789                	addi	a5,a5,2
    80006706:	0792                	slli	a5,a5,0x4
    80006708:	97a6                	add	a5,a5,s1
    8000670a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000670c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006710:	ffffc097          	auipc	ra,0xffffc
    80006714:	c28080e7          	jalr	-984(ra) # 80002338 <wakeup>

    disk.used_idx += 1;
    80006718:	0204d783          	lhu	a5,32(s1)
    8000671c:	2785                	addiw	a5,a5,1
    8000671e:	17c2                	slli	a5,a5,0x30
    80006720:	93c1                	srli	a5,a5,0x30
    80006722:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006726:	6898                	ld	a4,16(s1)
    80006728:	00275703          	lhu	a4,2(a4)
    8000672c:	faf71ce3          	bne	a4,a5,800066e4 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006730:	0001d517          	auipc	a0,0x1d
    80006734:	c6850513          	addi	a0,a0,-920 # 80023398 <disk+0x128>
    80006738:	ffffa097          	auipc	ra,0xffffa
    8000673c:	566080e7          	jalr	1382(ra) # 80000c9e <release>
}
    80006740:	60e2                	ld	ra,24(sp)
    80006742:	6442                	ld	s0,16(sp)
    80006744:	64a2                	ld	s1,8(sp)
    80006746:	6105                	addi	sp,sp,32
    80006748:	8082                	ret
      panic("virtio_disk_intr status");
    8000674a:	00002517          	auipc	a0,0x2
    8000674e:	27e50513          	addi	a0,a0,638 # 800089c8 <syscallnum+0x390>
    80006752:	ffffa097          	auipc	ra,0xffffa
    80006756:	df2080e7          	jalr	-526(ra) # 80000544 <panic>
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

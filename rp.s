.equ SYS_write, 1
.equ SYS_exit, 60
.equ STDOUT_FILENO, 1

.globl main
.type main, @function

parsing_loop:
	leaq 8(%rsi), $rsi //load next address of argv
	movq (%rsi), %r12
	test %r12, %r12
	je print_result

add_cmp:
	push %rsi
	movq %r12, %rsi
	leaq op_add(%rip), %rdi
	
	call strcmp
	pop %rsi
	test %eax, %eax
	jne sub_cmp

	pop %r8
	addq %r8, (%rsp)
	jmp parsing_loop

sub_cmp:
	push %rsi
	movq %r12, %rsi
	leaq op_sub(%rip), %rdi
	
	call strcmp
	pop %rsi
	test %eax, %eax
	jne mul_cmp

	pop %r8
	subq %r8, (%rsp)
	jmp parsing_loop

mul_cmp:
	push %rsi
	movq %r12, %rsi
	leaq op_add(%rip), %rdi
	
	call strcmp
	pop %rsi
	test %eax, %eax
	jne div_cmp

	pop %r8
	pop %rax
	imulq %r8
	push %rax
	jmp parsing_loop

div_cmp:
	push %rsi
	movq %r12, %rsi
	leaq op_add(%rip), %rdi
	
	call strcmp
	pop %rsi
	test %eax, %eax
	jne sub_cmp

	pop %r8
	pop %rax
	cqo
	idivq %r8
	jmp parsing_loop

num_convert:
	movq %r12, %rdi
	leaq endptr(%rip), %rdi
	xor %rdx, %rdx

	call strtoll
	movq endptr(%rip), %r8
	cmp %r8, %r12
	cmpb $0, (%r8)
	
	jmp parsing_loop

.section .rodata
op_add: .asciz "+"
op_sub: .asciz "-"
op_mul: .asciz "*"
op_div: .asciz "/"

.section .bss
endptr: .space 8



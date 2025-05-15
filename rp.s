/* UNFINISHED, SEG FAULTS
 * Reverse polish calculator
 * Author: Connor Allen 934467445
 */


.equ SYS_write, 1
.equ SYS_exit, 60
.equ STDOUT_FILENO, 1

.globl main
.type main, @function

main:
	push %rbp
	mov %rsp, %rbp

	mov %rdi, %r13
	mov %rsi, %r14

	mov $0, %r15
	addq $8, %r14
	jmp parsing_loop

parsing_loop:
	leaq 8(%rsi), %rsi
	movq (%rsi), %r12
	test %r12, %r12
	je print_result
	addq $8, %rsi

add_cmp:
	push %rsi
	movq %r12, %rsi
	leaq op_add(%rip), %rdi
	
	movq %rsp, %r13
	andq $-16, %rsp
	movq %r13, %rsp

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

	movq %rsp, %r13
	andq $-16, %rsp
	movq %r13, %rsp

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
	leaq op_mul(%rip), %rdi
	
	movq %rsp, %r13
	andq $-16, %rsp
	movq %r13, %rsp

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
	leaq op_div(%rip), %rdi
	
	movq %rsp, %r13
	andq $-16, %rsp
	movq %r13, %rsp

	call strcmp
	pop %rsi
	test %eax, %eax
	jne num_convert

	pop %r8
	pop %rax
	cqo
	idivq %r8
	push %rax
	jmp parsing_loop

num_convert:
	movq %r12, %rdi
	leaq endptr(%rip), %rsi
	xor %rdx, %rdx

	call strtoll
	push %rax
	
	jmp parsing_loop

print_result:
	mov (%rsp), %rdi
	mov $SYS_write, %rax
	syscall
	mov $0, %rdi
	pop %rbp
	call exit

exit:
	mov $SYS_exit, %rax
	syscall

.section .rodata
op_add: .asciz "+"
op_sub: .asciz "-"
op_mul: .asciz "*"
op_div: .asciz "/"

.section .bss
endptr: .space 8


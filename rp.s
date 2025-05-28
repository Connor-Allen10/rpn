/* WORKING, WITH NO ERROR HANDLING
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

	cmp $1, %rdi
	jle _end	
	sub $1024, %rsp
	mov %rsp, %rbx

	mov %rdi, %r13
	mov %rsi, %r14

	mov $0, %r15
	add $8, %r14

	jmp parsing_loop

parsing_loop:
	mov (%r14), %r12
	test %r12, %r12
	je print_result
	add $8, %r14

add_cmp:
	movq %r12, %rsi
	leaq op_add(%rip), %rdi

	xor %rax, %rax
	call strcmp

	test %eax, %eax
	jne sub_cmp

	sub $8, %rbx
	mov (%rbx), %r8
	sub $8, %rbx
	add %r8, (%rbx)
	add $8, %rbx
	jmp parsing_loop

sub_cmp:
	movq %r12, %rsi
	leaq op_sub(%rip), %rdi

	xor %rax, %rax
	call strcmp

	test %eax, %eax
	jne mul_cmp

	sub $8, %rbx
	mov (%rbx), %r8
	sub $8, %rbx
	mov (%rbx), %rax
	sub %r8, %rax
	mov %rax, (%rbx)
	add $8, %rbx
	jmp parsing_loop

mul_cmp:
	movq %r12, %rsi
	leaq op_mul(%rip), %rdi

	xor %rax, %rax
	call strcmp

	test %eax, %eax
	jne div_cmp

	sub $8, %rbx
	mov (%rbx), %rax
	sub $8, %rbx
	imulq (%rbx), %rax
	mov %rax, (%rbx)
	add $8, %rbx
	jmp parsing_loop

div_cmp:
	movq %r12, %rsi
	leaq op_div(%rip), %rdi

	xor %rax, %rax
	call strcmp

	test %eax, %eax
	jne num_convert

	sub $8, %rbx
	mov (%rbx), %r8
	sub $8, %rbx
	mov (%rbx), %rax
	cqo
	idivq %r8
	mov %rax, (%rbx)
	add $8, %rbx
	jmp parsing_loop


num_convert:
	movq %r12, %rdi
	leaq endptr(%rip), %rsi
	xor %rdx, %rdx

	call strtoll

	mov %rax, (%rbx)
	add $8, %rbx
	jmp parsing_loop

print_result:
	sub $8, %rbx
	mov (%rbx), %rsi
	leaq print_result_str(%rip), %rdi

	xor %rax, %rax
	call printf
	
	leave
	ret
_end:
	mov $0, %rdi
	mov $SYS_exit, %rax
	syscall

.section .rodata
op_add: .asciz "+"
op_sub: .asciz "-"
op_mul: .asciz "*"
op_div: .asciz "/"
print_result_str: .asciz "%ld\n"

.section .bss
endptr: .space 8


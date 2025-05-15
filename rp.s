.equ SYS_write, 1
.equ SYS_exit, 60
.equ STDOUT_FILENO, 1

.extern printf
.extern strtoll
.extern strcmp
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
	leaq op_mul(%rip), %rdi
	
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
	
	call strcmp
	pop %rsi
	test %eax, %eax
	jne num_convert

	pop %r8
	pop %rax
	cqo
	idivq %r8
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
	call print_int
	mov $0, %rdi
	call exit

exit:
	mov $SYS_exit, %rax
	syscall

print_int:
	mov %rsp, %rsi
	sub $32, %rsp
	mov %rsp, %rcx

	mov %rdi, %rax
	mov $0, %r8

	cmp $0, %rax
	jge .convert_loop
	neg %rax
	mov $1, %r8

.convert_loop:
	xor %rdx, %rdx
	mov $10, %rbx
	div %rbx
	add $'0', %dl
	dec %rcx
	mov %dl, (%rcx)

	test %rax, %rax
	jne .convert_loop

	cmp $0, %r8
	je .print_it
	dec %rcx
	movb $'-', (%rcx)

.print_it:
	mov $1, %rax
	mov $1, %rdi
	mov %rcx, %rsi
	mov %rsp, %rdx
	sub %rcx, %rdx
	syscall

	mov %rsi, %rsp
	ret


.section .rodata
op_add: .asciz "+"
op_sub: .asciz "-"
op_mul: .asciz "*"
op_div: .asciz "/"

.section .bss
endptr: .space 8


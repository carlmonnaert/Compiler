	.data
format:
	.string "%d\n"
	.text
	.globl f
f:
	push %rbp
	mov %rsp, %rbp
	sub $16, %rsp
	mov %rdi, -8(%rbp)
	push -8(%rbp)
	pop %rax
	add $16, %rsp
	pop %rbp
	ret
	.text
	.globl main
main:
	push %rbp
	mov %rsp, %rbp
	sub $24, %rsp
	mov $10, %rdi
	call f
	push %rax
	pop %r8
	mov %r8, -16(%rbp)
	push -16(%rbp)
	pop %rsi
	leaq format(%rip), %rdi
	mov $0, %eax
	mov %rsp, %r8
	and $0xf, %r8 
	sub %r8, %rsp
	push %r8
	sub $8, %rsp
	call printf
	add $8, %rsp
	pop %r8
	add %r8, %rsp
	push $0
	pop %rax
	add $24, %rsp
	pop %rbp
	ret

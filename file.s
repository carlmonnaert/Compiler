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
	pop %rdi
	call g
	push %rax
	push $3
	pop %rax
	pop %rbx
	add %rbx, %rax
	push %rax
	pop %rax
	add $16, %rsp
	pop %rbp
	ret
	.text
	.globl g
g:
	push %rbp
	mov %rsp, %rbp
	sub $16, %rsp
	mov %rdi, -8(%rbp)
	push -8(%rbp)
	push $1
	pop %rax
	pop %rbx
	add %rbx, %rax
	push %rax
	pop %rax
	add $16, %rsp
	pop %rbp
	ret
	.text
	.globl main
main:
	push %rbp
	mov %rsp, %rbp
	sub $16, %rsp
	mov $5, %rdi
	call f
	push %rax
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
	add $16, %rsp
	pop %rbp
	ret

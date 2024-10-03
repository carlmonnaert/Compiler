	.data
format:
	.string "%d\n"
	.text
	.globl main
main:
	push $20
	push $5
	pop %rbx
	pop %rax
	cqo
	idiv %rbx
	push %rax
	push $4
	pop %rbx
	pop %rax
	cqo
	idiv %rbx
	push %rax
	push $2
	pop %rbx
	pop %rax
	cqo
	idiv %rbx
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
	push $5
	push $2
	pop %rax
	pop %rbx
	imul %rbx, %rax
	push %rax
	push $1
	pop %rax
	pop %rbx
	add %rbx, %rax
	push %rax
	pop %rax
	ret

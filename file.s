	.data
format:
	.string "%d\n"
x:
	.int 0
	.text
	.globl main
main:
	push x(%rip)
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
	push $10
	push $10
	pop %rbx
	pop %rax
	sub %rbx, %rax
	push %rax
	push $10
	pop %rbx
	pop %rax
	sub %rbx, %rax
	push %rax
	push $10
	pop %rbx
	pop %rax
	sub %rbx, %rax
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
	ret

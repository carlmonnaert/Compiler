	.data
format:
	.string "%d\n"
.globl  x
x:
	.int 0
	.text
	.globl f
f:
	push $20
	pop %rax
	ret
	.text
	.globl main
main:
	push $5
	call f
	push %rax
	pop %rax
	pop %rbx
	add %rbx, %rax
	push %rax
	pop %r8
	mov %r8, x(%rip)
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
	push $0
	pop %rax
	ret

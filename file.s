	.data
format:
	.string "%d\n"
format2:
	.string "%d"
	.text
	.globl main
main:
	push %rbp
	mov %rsp, %rbp
	sub $32, %rsp
	push $0
	leaq (%rsp), %rsi
	leaq format2(%rip), %rdi
	mov $0, %eax
	mov %rsp, %r8
	and $0xf, %r8 
	sub %r8, %rsp
	push %r8
	sub $8, %rsp
	call scanf
	add $8, %rsp
	pop %r8
	add %r8, %rsp
	mov %rsi, -16(%rbp)
	pop %rsi
	push $0
	leaq (%rsp), %rsi
	leaq format2(%rip), %rdi
	mov $0, %eax
	mov %rsp, %r8
	and $0xf, %r8 
	sub %r8, %rsp
	push %r8
	sub $8, %rsp
	call scanf
	add $8, %rsp
	pop %r8
	add %r8, %rsp
	mov %rsi, -24(%rbp)
	pop %rsi
	push -16(%rbp)
	push -24(%rbp)
	pop %rax
	pop %rbx
	add %rbx, %rax
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
	add $32, %rsp
	pop %rbp
	ret

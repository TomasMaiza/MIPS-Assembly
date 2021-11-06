# hacer fibonacci fib(n) = fib(n-1) + fib(n-2) para n >= 2 para fib(1) = 1 y fib(0) = 0

.data
num: .space 4
res: .space 4
.align 2
cad1: .asciiz "Ingresar un numero: "
cad2: .asciiz "\nEl fibonacci del numero es: "
.align 2
.text
.globl main
main:
    la $a0, cad1
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    sw $v0, num($0)
    move $a0, $v0
    li $s0, 0
    jal fib
    sw $v0, res($0)
    la $a0, cad2
    li $v0, 4
    syscall
    lw $a0, res($0)
    li $v0, 1
    syscall
    li $v0, 10
    syscall
.end

fib:
    move $t1, $a0
    loop1:
        bgt $t1, 1, recursion
        move $v0, $t1
        jr $ra
    recursion:
        sub $sp, $sp, 12
        sw $ra, 0($sp)
        sw $a0, 4($sp)
        addi $a0, $a0, -1
        jal fib
        sw $v0, 8($sp)
        lw $a0, 4($sp)
        addi $a0, $a0, -2
        jal fib
        lw $t0, 8($sp)
        add $v0, $v0, $t0
        lw $ra, 0($sp)
        addi $sp, $sp, 12
        jr $ra
.end
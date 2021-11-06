.data
frase: .space 100
abecedario: .space 26
letras: .asciiz "abcdefghijklmnopqrstuvwxyz"
letra: .space 2
espacio: .asciiz " "
salto: .asciiz "\n"
ing: .asciiz "Ingrese una frase: "
.text
.globl main
main:
    la $a0, ing
    li $v0, 4
    syscall
    la $a0, frase
    la $a1, 100
    li $v0, 8
    syscall
    la $a0, frase
    la $a1, abecedario
    jal tfa
    li $s0, 0 # cero
    la $s1, letras
    la $s2, abecedario
    mostrar:
        lb $t1, ($s1)
        beq $t1, $s0, terminar
        sb $t1, letra
        la $a0, letra
        li $v0, 4
        syscall
        la $a0, espacio
        li $v0, 4
        syscall
        la $t2, ($s2)
        lb $a0, ($t2)
        li $v0, 1
        syscall
        la $a0, salto
        li $v0, 4
        syscall
        addi $s1, $s1, 1
        addi $s2, $s2, 1
        j mostrar
    terminar:
        li $v0, 10
        syscall
.end

tfa:
    move $t0, $a0 # frase
    move $t1, $a1 # abecedario
    li $s0, 0 # cero
    li $s1, 32
    loop:
        lb $t2, ($t0)
        beq $t2, $s0, fin
        beq $t2, $s1, seguir
        addi $t2, $t2, -97
        add $t1, $t1, $t2
        lb $t3, ($t1)
        addi $t3, $t3, 1
        sb $t3, ($t1)
        j seguir
    seguir:
        addi $t0, $t0, 1
        move $t1, $a1
        j loop
    fin:
        jr $ra
.end
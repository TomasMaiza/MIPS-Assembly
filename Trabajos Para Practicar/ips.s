.data
h1: .space 16 # ip host
.align 2
r1: .space 16 # ip red
.align 2
m1: .space 16 # mascara
.align 2
ht: .space 4
rt: .space 4
mt: .space 4
ingh: .asciiz "Introduzca una dirección IP: "
ingr: .asciiz "\nIntroduzca una dirección de red: "
ingm: .asciiz "\nIntroduzca una máscara: "
verd: .asciiz "\nLa dirección pertenece a la red"
falso: .asciiz "\nLa dirección no pertenece a la red"
.text
.globl main
main:
    la $a0, ingh # ingresar ip host
    li $v0, 4
    syscall
    la $a0, h1
    la $a1, 20
    li $v0, 8
    syscall
    la $a0, ingr # ingresar ip red
    li $v0, 4
    syscall
    la $a0, r1
    la $a1, 20
    li $v0, 8
    syscall
    la $a0, ingm # ingresar mascara
    li $v0, 4
    syscall
    la $a0, m1
    la $a1, 20
    li $v0, 8
    syscall
    la $a0, h1
    la $a1, ht
    jal aton # traduce ip host
    la $a0, r1
    la $a1, rt
    jal aton # traduce ip red
    la $a0, m1
    la $a1, mt
    jal aton # traduce ip mascara
    lw $s0, ht
    lw $s1, mt
    lw $s2, rt
    and $s3, $s0, $s1
    beq $s2, $s3, true
    la $a0, falso
    li $v0, 4
    syscall 
    li $v0, 10
    syscall
.end

aton:
    move $t0, $a0 # ip
    move $t1, $a1 # traduccion
    addi $t1, $t1, 3 # suma 3 a la direccion de la traduccion 
    li $t4, 0 # contador de cifras de cada numero
    li $s2, 0 # sumador
    li $t5, 46 # ascii del punto (.)
    loop1:
        lb $t2, ($t0)
        addi $t2, $t2, -48
        addi $sp, $sp, -4
        sw $t2, ($sp)
        addi $t0, $t0, 1
        addi $t4, $t4, 1
        lb $t6, ($t0)
        beq $t5, $t6, punto
        li $t8, 0xa
        beq $t6, $t8, fin
        j loop1
    punto:
        li $s4, 1
        li $s0, 0xa
        li $s2, 0
        loop2:
            lw $s1, ($sp)
            addi $sp, $sp, 4
            mult $s1, $s4
            mflo $s1  
            add $s2, $s2, $s1 
            addi $t4, $t4, -1
            mult $s4, $s0
            mflo $s4
            blez $t4, volver
            j loop2
    volver:
        sb $s2, ($t1)
        addi $t1, $t1, -1
        addi $t0, $t0, 1
        j loop1
    fin:
        li $s4, 1
        li $s0, 0xa
        li $s2, 0
        loop3:
            lw $s1, ($sp)
            addi $sp, $sp, 4
            mult $s1, $s4
            mflo $s1  
            add $s2, $s2, $s1 
            addi $t4, $t4, -1
            mult $s4, $s0
            mflo $s4
            blez $t4, terminar
            j loop3
        terminar:
            sb $s2, ($t1)   
            jr $ra
.end

true:
    la $a0, verd
    li $v0, 4
    syscall
    li $v0, 10
    syscall
.end
.data

abc: .asciiz "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
auxi: .space 2
frase: .space 104
frase2: .space 104
clave1: .space 27
clave2: .space 27
des: .space 104
introclave: .asciiz "Ingrese la clave: "
introfrase: .asciiz "\nIngrese la frase: "
cifrada: .asciiz "\nLa frase cifrada es: "
descifrada: .asciiz "\nLa frase descifrada es: "

.text
.globl main
main:
    la $a0, introclave
    li $v0, 4
    syscall
    la $a0, clave1($0)
    la $a1, 27
    li $v0, 8
    syscall
    la $a0, introfrase
    li $v0, 4
    syscall
    la $a0, frase($0)
    la $a1, 104
    li $v0, 8
    syscall
    la $a0, clave1
    la $a1, frase
    la $a2, frase2
    jal cifrar # salta a la subrutina
    la $a0, abc
    la $a1, clave1
    la $a2, clave2
    jal decode
    la $a0, clave2
    la $a1, frase2
    la $a2, des
    jal cifrar
    la $a0, cifrada
    li $v0, 4
    syscall
    la $a0, frase2 # muestra la frase cifrada
    li $v0, 4
    syscall
    la $a0, descifrada
    li $v0, 4
    syscall
    la $a0, des # muestra la frase descifrada
    li $v0, 4
    syscall
    li $v0, 10
    syscall
.end

cifrar:
    move $t0, $a0 # clave
    move $t1, $a1 # frase
    move $t5, $a2 # frase 2
    loop:
        lb $t2, ($t1) # carga el byte de la letra
        li $t7, 32
        beq $t2, $t7, espacio
        addi $t2, $t2, -65
        move $t3, $t0 # mueve la direccion de la clave a $t3
        add $t3, $t3, $t2 # le suma $t2
        lb $t4, ($t3) # carga el byte de la letra de reemplazo
        sb $t4, ($t5) # guarda el byte de la letra en la frase cifrada
        addi $t5, $t5, 1 # avanza una posición de memoria en la frase cifrada
        addi $t1, $t1, 1 # avanza una posición de memoria en la frase
        lb $t6, ($t1) # carga el byte de la memoria de la frase
        blez $t6, fin # si es 0 (la frase terminó), salta a fin
        j loop
    espacio:
        sb $t2, ($t5)
        addi $t5, $t5, 1 # avanza una posición de memoria en la frase cifrada
        addi $t1, $t1, 1 # avanza una posición de memoria en la frase
        lb $t6, ($t1) # carga el byte de la memoria de la frase
        blez $t6, fin # si es 0 (la frase terminó), salta a fin
        j loop
    fin:
        jr $ra
.end

decode:
    move $t0, $a0 # abecedario
    move $t1, $a1 # clave 1
    move $t2, $a2 # clave 2
    loop1:
        lb $t4, ($t0) # carga el byte de la letra del abecedario
        lb $t3, ($t1) # carga el byte de la letra de la clave 1
        addi $t3, $t3, -65 # calcula el ascii de la letra de la clave 1
        move $t5, $t2 # mueve la clave 2 a $t5
        add $t5, $t5, $t3 # suma $t3 posiciones a la clave 2
        sb $t4, ($t5) # guarda la letra en la clave 2
        addi $t0, $t0, 1
        addi $t1, $t1, 1
        lb $t6, ($t0)
        blez $t6, fin1       
        j loop1
    fin1:
        jr $ra
.end
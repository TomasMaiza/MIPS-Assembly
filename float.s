.data
num: .space 4
ing: .asciiz "\n\nIntroduzca un numero flotante: "
.align 4
ihex: .asciiz "\nRepresentacion hexadecimal: "
.align 8
hexa: .space 4
.align 2
hexaux: .space 4
.align 2
ibin: .asciiz "\nRepresentacion binaria: "
.align 2
repbinaria: .space 32
binario: .space 32
isigno: .asciiz "\nSigno: "
.align 2
iexp: .asciiz "\nExponente: "
.align 2
exp: .space 32
exponente: .space 4
imant: .asciiz "\nMantisa: "
.align 2
mantisa: .space 32
negativo: .asciiz "Negativo"
positivo: .asciiz "Positivo"
hdiez: .asciiz "a"
honce: .asciiz "b"
hdoce: .asciiz "c"
htrece: .asciiz "d"
hcatorce: .asciiz "e"
hquince: .asciiz "f"
finalizar: .asciiz "\n\nSe ingreso un 0.0, el programa finaliza."
.text
.globl main
main:
    la $a0, ing
    li $v0, 4
    syscall
    li $v0, 6 # se ingresa el numero
    syscall
    la $a0, finalizar
    li.s $f1, 0.0
    c.eq.s $f0, $f1 # si el número ingresado es 0.0, se termina el programa
    bc1t fin
    s.s $f0, num($0) # almacena el flotante en memoria
    la $a1, binario
    la $a2, repbinaria
    jal sign
    la $a0, exp # carga la dirección del binario del exponente
    la $a1, exponente # carga la dirección del exponente
    la $a2, repbinaria
    jal bin
    la $a0, exp
    la $a1, repbinaria
    jal binmantisa
    la $a0, ibin
    la $a1, repbinaria
    jal mostrarbin
    la $a0, ihex
    li $v0, 4
    syscall
    la $a0, hexa
    la $a1, repbinaria
    la $a2, hexaux
    jal mostrarhexa
    la $a0, iexp
    li $v0, 4
    syscall
    lb $a0, exponente # muestra el exponente
    li $v0, 1
    syscall
    la $a0, imant
    li $v0, 4
    syscall
    la $a0, repbinaria
    la $a1, mantisa
    jal mostrarman
    j main
.end

sign:
    move $t2, $a2
    addi $t2, $t2, 31
    li.s $f1, 0.0 # se almacena 0.0 en $f1
    c.lt.s $f0, $f1 # comprueba si $f1 < 0.0
    bc1t nega
    bc1f pos
    nega:
        la $a0, isigno # muestra que el signo es negativo
        li $v0, 4
        syscall
        la $a0, negativo
        li $v0, 4
        syscall
        li $t0, 1
        sb $t0, ($a1) # carga un 1 en memoria
        sb $t0, ($t2) # carga un 1 en memoria
        jr $ra
    pos:
        la $a0, isigno # muestra que el signo es positivo
        li $v0, 4
        syscall
        la $a0, positivo
        li $v0, 4
        syscall
        li $t0, 0
        sb $t0, ($a1) # carga un 0 en memoria
        sb $t0, ($t2)
    jr $ra
.end

bin:
    li $s4, 127
    move $t3, $a0
    addi $a2, $a2, 30
    li $t4, 0 # contador
    li $t6, 0 # contador pila
    cvt.w.s $f1, $f0 # convierte el float a entero
    mfc1 $a0, $f1 # almacena el entero en un registro de enteros
    cvt.s.w $f1, $f1
    sub.s $f1, $f0, $f1 # almacena en $f1 solo la parte decimal del número ingresado
    abs.s $f1, $f1
    li.s $f2, 2.0 # guarda 2.0 en $f2
    li.s $f7, 1.0
    move $t0, $a0
    abs $t0, $t0
    li $t1, 2 
    divide:
        div $t0, $t1 # division de $t0 por 2
        mfhi $t2 # guarda el resto en $t2
        addi $sp, $sp, -4
        sw $t2, ($sp) # almacena el resto en la pilas
        addi $t6, $t6, 1
        beq $t0, 1, calcExp # si $t0 = 1 entonces salta a calcExp
        mflo $t0 # almacena en $t0 el resultado de la division
        addi $t4, $t4, 1 # suma 1 al contador
        j divide # loop
    calcExp:
        lw $s1, ($sp) # carga en $s1 el último valor apilado
        addi $sp, $sp, 4
        beq $s1, 1, binEnt
        j calcExp
        binEnt:
            beq $t6, 1, expo # si $t6 = 0 salta a volver
            lw $s1, ($sp) # carga en $s1 el último valor apilado
            sb $s1, ($t3) # almacena el valor de $s1 como byte
            addi $t3, $t3, 1
            addi $sp, $sp, 4
            addi $t6, $t6, -1
            j binEnt
        expo:
            li $t6, 0
            sb $t4, ($a1)
            add $t0, $t4, $s4
            li $t4, 0 # contador
    binarioExp:
        div $t0, $t1 # division de $t0 por 2
        mfhi $t2 # almacena en $t2 el resto de la división
        addi $sp, $sp, -4
        sw $t2, ($sp)
        addi $t6, $t6, 1
        beq $t0, 1, desapilar # si $t0 = 1 entonces salta a desapilar
        mflo $t0 # almacena en $t0 el resultado de la division
        addi $t4, $t4, 1 # suma 1 al contador
        j binarioExp # loop
    desapilar:
        beq $t6, 0, ceros # si $t6 = 0 salta a ceros
        lw $s1, ($sp) # carga en $s1 el último valor apilado
        sb $s1, ($a2) # almacena el valor de $s1 como byte
        addi $a2, $a2, -1
        addi $sp, $sp, 4
        addi $t6, $t6, -1
        j desapilar
    ceros:
        li $s6, 0
        beq $t4, 8, man
        addi $a2, $a2, -1
        addi $t4, $t4, 1
        j ceros
    man:
        mul.s $f1, $f1, $f2 # multiplica la parte decimal por 2
        cvt.w.s $f3, $f1 # guarda la parte entera del resultado en $f3
        mfc1 $t0, $f3
        sb $t0, ($t3)
        cvt.w.s $f4, $f1 # convierte el float a entero
        cvt.s.w $f4, $f4 # convierte el entero a float
        sub.s $f1, $f1, $f4 # almacena en $f1 solo la parte decimal del número ingresado
        addi $t3, $t3, 1
        addi $s6, $s6, 1
        c.eq.s $f1, $f7 # si $f1 = 1.0 termina el loop
        bc1t volver
        beq $s6, 23, volver
        j man
    volver:
        jr $ra
.end

binmantisa:
    li $t1, 0 # contador
    addi $a1, $a1, 22
    loop1:
        lb $t0, ($a0)
        sb $t0, ($a1) # carga el bit
        addi $a0, $a0, 1
        addi $a1, $a1, -1
        beq $t1, 23, vol
        addi $t1, $t1, 1
        j loop1
    vol:
        jr $ra
.end

mostrarbin:
    li $v0, 4
    syscall
    li $t1, 0
    move $t0, $a1
    addi $t0, $t0, 31 # añade 15 a la dirección que guarda el binario
    mostrarbyte2:
        lb $a0, ($t0) # carga cada byte en $a0 para mostrarlo
        li $v0, 1
        syscall
        addi $t0, $t0, -1
        addi $t1, $t1, 1
        beq $t1, 0x20, reg2 # si ya se recorrió todo el número vuelve al main
        j mostrarbyte2
    reg2:
        jr $ra
.end

mostrarman:
    li $t0, 0 # contador
    li.s $f2, 2.0 # potencia
    li.s $f4, 2.0 # constante 2.0 para las potencias
    li.s $f0, 0.0 # sumador
    li.s $f3, 1.0 # carga 1.0 en el registro
    addi $a0, $a0, 22 # suma 22 a la rep binaria (avanza hasta la mantisa)
    loop2:
        lb $t1, ($a0) # carga un bit en $t1
        mtc1 $t1, $f1 # convierte el resultado a float
        cvt.s.w $f1, $f1
        div.s $f1, $f1, $f2 # divide el bit por una potencia de dos
        add.s $f0, $f0, $f1 # lo suma
        addi $a0, $a0, -1
        addi $t0, $t0, 1
        mul.s $f2, $f2, $f4
        beq $t0, 23, most # si el contador llega a 23, se muestra la mantisa y se vuelve al main
        j loop2
    most:
        add.s $f12, $f0, $f3 # suma 1.0 para obtener la mantisa y la muestra
        li $v0, 2
        syscall
        jr $ra
.end

mostrarhexa:
    addi $a1, $a1, 31
    addi $a0, $a0, 3
    li $t0, 0 # contador de 4 bits
    li $t3, 0 # contador hexa
    tomaCuatro:
        lb $t1, ($a1) # carga el byte de $a1 en $t1
        sb $t1, ($a2) # guadra el byte en $a2
        addi $t0, $t0, 1 # suma 1 al contador
        beq $t0, 4, comparar # comprueba si el contador es igual a 4 para saltar a comparar
        addi $a1, $a1, -1
        addi $a2, $a2, 1
        j tomaCuatro # bucle
    comparar:
        li $t0, 0
        addi $t3, $t3, 1
        addi $a2, $a2, -3
        addi $a1, $a1, -1
        lb $t1, ($a2)
        cargarbytes:
            lb $t4, ($a2) # carga cada byte en un registro temporal
            addi $a2, $a2, 1
            lb $t5, ($a2)
            addi $a2, $a2, 1
            lb $t6, ($a2)
            addi $a2, $a2, 1
            lb $t7, ($a2)
            addi $a2, $a2, -3
        beq $t4, 0, ceross # compara $t4 con 0 y luego con cada combinación posible
        beq $t4, 1, unos # compara $t4 con 1 y luego con cada combinación posible
        ceross:
            beq $t5, 0, ceros2
            beq $t5, 1, ceross2
            ceros2:
                beq $t6, 0, ceros3
                beq $t6, 1, ceross1
                ceros3:
                    beq $t7, 0, cero
                    j uno
                ceross1:
                    beq $t7, 0, dos
                    j tres
            ceross2:
                beq $t6, 0, ceross3
                beq $t6, 1, ceross4
                ceross3:
                    beq $t7, 0, cuatro
                    j cinco
                ceross4:
                    beq $t7, 0, seis
                    j siete
        unos:
            beq $t5, 1, unos2
            beq $t5, 0, unos5
            unos2:
                beq $t6, 1, unos3
                beq $t6, 0, unos4
                unos3:
                    beq $t7, 1, quince
                    j catorce
                unos4:
                    beq $t7, 1, trece
                    j doce
            unos5:
                beq $t6, 1, unos6
                beq $t6, 0, unos7
                unos6:
                    beq $t7, 1, once
                    j diez
                unos7:
                    beq $t7, 1, nueve
                    j ocho
        cero:
            li $t1, 0x0 # carga 0x0 en $t1
            sb $t1, ($a0) # lo guarda en $a0
            move $a3, $a0
            move $a0, $t1 # muestra el 0
            li $v0, 1
            syscall
            move $a0, $a3
            j seguir # continua el bucle
        uno:
            li $t1, 0x1
            sb $t1, ($a0)
            move $a3, $a0
            move $a0, $t1
            li $v0, 1
            syscall
            move $a0, $a3
            j seguir
        dos:
            li $t1, 0x2
            sb $t1, ($a0)
            move $a3, $a0
            move $a0, $t1
            li $v0, 1
            syscall
            move $a0, $a3
            j seguir
        tres:
            li $t1, 0x3
            sb $t1, ($a0)
            move $a3, $a0
            move $a0, $t1
            li $v0, 1
            syscall
            move $a0, $a3
            j seguir
        cuatro:
            li $t1, 0x4
            sb $t1, ($a0)
            move $a3, $a0
            move $a0, $t1
            li $v0, 1
            syscall
            move $a0, $a3
            j seguir
        cinco:
            li $t1, 0x5
            sb $t1, ($a0)
            move $a3, $a0
            move $a0, $t1
            li $v0, 1
            syscall
            move $a0, $a3
            j seguir
        seis:
            li $t1, 0x6
            sb $t1, ($a0)
            move $a3, $a0
            move $a0, $t1
            li $v0, 1
            syscall
            move $a0, $a3
            j seguir
        siete:
            li $t1, 0x7
            sb $t1, ($a0)
            move $a3, $a0
            move $a0, $t1
            li $v0, 1
            syscall
            move $a0, $a3
            j seguir
        ocho:
            li $t1, 0x8
            sb $t1, ($a0)
            move $a3, $a0
            move $a0, $t1
            li $v0, 1
            syscall
            move $a0, $a3
            j seguir
        nueve:
            li $t1, 0x9
            sb $t1, ($a0)
            move $a3, $a0
            move $a0, $t1
            li $v0, 1
            syscall
            move $a0, $a3
            j seguir
        diez:
            move $a3, $a0
            la $a0, hdiez # muestra 0xa
            li $v0, 4
            syscall
            move $a0, $a3
            j seguir # continua el bucle
        once:
            move $a3, $a0
            la $a0, honce
            li $v0, 4
            syscall
            move $a0, $a3
            j seguir
        doce:
            move $a3, $a0
            la $a0, hdoce
            li $v0, 4
            syscall
            move $a0, $a3
            j seguir
        trece:
            move $a3, $a0
            la $a0, htrece
            li $v0, 4
            syscall
            move $a0, $a3
            j seguir
        catorce:
            move $a3, $a0
            la $a0, hcatorce
            li $v0, 4
            syscall
            move $a0, $a3
            j seguir
        quince:
            move $a3, $a0
            la $a0, hquince
            li $v0, 4
            syscall
            move $a0, $a3
            j seguir
        seguir:
            beq $t3, 8, volvermain
            addi $a0, $a0, -1
            j tomaCuatro
        volvermain:
            jr $ra
.end

fin:
    li $v0, 4
    syscall
    li $v0, 10
    syscall
.end
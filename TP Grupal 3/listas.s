.data 0x10001000
    slist: .word 0 # --------------------------------------------------------------> puntero al primer nodo
    cclist: .word 0 # -------------------------------------------------------------> puntero a la lista de categorías
    wclist: .word 0 # -------------------------------------------------------------> puntero a la categoría seleccionada en curso
    final: .space 4 # -------------------------------------------------------------> puntero al último nodo
    finalc: .space 4 # ------------------------------------------------------------> puntero a la última categoría
    flist: .word 0 # --------------------------------------------------------------> puntero a los nodos liberados

    contador: .word 0x0 
    
    op1: .asciiz "\n1: Crear una categoria\n" # -------------------------------------> newcategory (LISTO)
    op2: .asciiz "2: Pasar a la categoria siguiente\n" # --------------------------> nextcategory (LISTO)
    op3: .asciiz "3: Pasar a la categoria anterior\n" # ---------------------------> prevcategory (LISTO)
    op4: .asciiz "4: Mostrar todas las categorias\n" # ----------------------------> allcategorys (LISTO)
    op5: .asciiz "5: Borrar una categoria\n" # ------------------------------------> delcategory
    op6: .asciiz "6: Agregar un objeto a la categoria seleccionada\n" # -----------> newnode (LISTO)
    op7: .asciiz "7: Borrar un objeto de la categoria seleccionada\n" # -----------> delnode (LISTO)
    op8: .asciiz "8: Listar todos los objetos de la categoria seleccionada\n" # ---> allobj (LISTO)
    op9: .asciiz "9: Finalizar programa\n\n" # ------------------------------------> fin (LISTO)

    salto: .asciiz "\n" # ---------------------------------------------------------> salto de linea
    asterisco: .asciiz "*" # ------------------------------------------------------> asterisco para señalar la lista actual

    seleccion: .asciiz "Seleccion: " # --------------------------------------------> seleccion de opcion. Se ingresa un numero.
    
    ingvalor: .asciiz "\nIngresar un valor: " # -----------------------------------> ingreso de valores
    input: .space 4 # -------------------------------------------------------------> auxiliar de input


.text

.globl main

    main:
        j menu
    .end

    menu:
        la $a0, op1 # -------------------------------------------------------------> muestra la opcion 1
        li $v0, 4
        syscall
        
        la $a0, op2 # -------------------------------------------------------------> muestra la opcion 2
        li $v0, 4
        syscall
        
        la $a0, op3 # -------------------------------------------------------------> muestra la opcion 3
        li $v0, 4
        syscall
        
        la $a0, op4 # -------------------------------------------------------------> muestra la opcion 4
        li $v0, 4
        syscall
        
        la $a0, op5 # -------------------------------------------------------------> muestra la opcion 5
        li $v0, 4
        syscall
        
        la $a0, op6 # -------------------------------------------------------------> muestra la opcion 6
        li $v0, 4
        syscall
        
        la $a0, op7 # -------------------------------------------------------------> muestra la opcion 7
        li $v0, 4
        syscall
        
        la $a0, op8 # -------------------------------------------------------------> muestra la opcion 8
        li $v0, 4
        syscall
        
        la $a0, op9 # -------------------------------------------------------------> muestra la opcion 9
        li $v0, 4
        syscall
        
        la $a0, seleccion # -------------------------------------------------------> cartel de seleccion
        li $v0, 4
        syscall
        
        li $v0, 5 # ---------------------------------------------------------------> se ingresa la seleccion y se almacena en $v0
        syscall

        beq $v0, 1, ing1 # --------------------------------------------------------> accede a la función correspondiente según la selección
        beq $v0, 2, nextcategory
        beq $v0, 3, prevcategory
        beq $v0, 4, allcategorys
        beq $v0, 5, delcategory
        beq $v0, 6, ing6
        beq $v0, 7, ing7
        beq $v0, 8, mostrarobjetos
        beq $v0, 9, fin
        ing1:
            la $a0, ingvalor # ----------------------------------------------------> cartel de ingreso de valores
            li $v0, 4 # -----------------------------------------------------------> syscall para mostrar cadenas
            syscall
            la $a0, input # -------------------------------------------------------> almacena la cadena en input
            la $a1, 16 # ----------------------------------------------------------> tamaño del valor a ingresar
            li $v0, 8 # -----------------------------------------------------------> syscall de ingreso de cadenas
            syscall
            lb $a0, input # -------------------------------------------------------> carga los bytes de la cadena ingresada
            lb $a1, input+1
            lb $a2, input+2
            lb $a3, input+3
            j newcategory

        ing6:
            la $a0, ingvalor # ----------------------------------------------------> cartel de ingreso de valores
            li $v0, 4 # -----------------------------------------------------------> syscall para mostrar cadenas
            syscall
            la $a0, input # -------------------------------------------------------> almacena la cadena en input
            la $a1, 16 # ----------------------------------------------------------> tamaño del valor a ingresar
            li $v0, 8 # -----------------------------------------------------------> syscall de ingreso de cadenas
            syscall
            lb $a0, input # -------------------------------------------------------> carga los bytes de la cadena ingresada
            lb $a1, input+1
            lb $a2, input+2
            lb $a3, input+3
            j newnode
        ing7:
            la $a0, ingvalor # ----------------------------------------------------> cartel de ingreso de valores
            li $v0, 4 # -----------------------------------------------------------> syscall para mostrar cadenas
            syscall
            li $v0, 5 # ingreso la id a eliminar
            syscall
            lw $t0, slist # cargo la direccion del primer nodo en $t0
            recorrer:
                lw $t1, 4($t0) # carga la id del objeto en $t1
                beq $t1, $v0, saltar # si coincide con la ingresada entonces pasa a saltar
                lw $t0, 12($t0) # carga en $t0 la dirección del siguiente nodo
                j recorrer # loop
            saltar:
                move $a0, $t0 # mueve la dirección del nodo a eliminar a $a0
                li $a1, 0 # carga 0 en $a1
                j delnode
    .end

    newcategory:
        move $t0, $a0 # -----------------------------------------------------------> preserva el argumento
        
        addi $sp, $sp, -4 # -------------------------------------------------------> reclamación de la pila
        sw $ra, ($sp) # -----------------------------------------------------------> apilo el registro $ra
        
        jal smalloc # -------------------------------------------------------------> pido espacio 
        
        lw $ra, ($sp) # -----------------------------------------------------------> desapilo el registro $ra
        addi $sp, $sp, 4 # --------------------------------------------------------> liberación de la pila
        
        sb $t0, 8($v0) # ----------------------------------------------------------> guarda el argumento en el espacio reservado
        
        move $t0, $a1 
        sb $t0, 9($v0)
        move $t0, $a2
        sb $t0, 10($v0)
        move $t0, $a3
        sb $t0, 11($v0)
        
        lw $t1, cclist # ----------------------------------------------------------> carga el puntero cclist en $t1
        beq $t1, $0, first1 # -----------------------------------------------------> si la lista está vacía salta a first1
        
        sw $v0, ($t1) # -----------------------------------------------------------> apunta el noda anterior hacia el nuevo nodo
        sw $t1, 12($v0) # ---------------------------------------------------------> inserta la dirección del nodo siguiente
        sw $v0, cclist # ----------------------------------------------------------> actualiza el puntero cclist
        lw $t1, finalc # ----------------------------------------------------------> carga la dirección del puntero final en $t1
        sw $t1, ($v0) # -----------------------------------------------------------> guarda la dirección del último nodo en la primera palabra del nuevo nodo (hace que la lista sea circular)
        sw $v0, 12($t1) # ---------------------------------------------------------> guarda la dirección del nuevo nodo en la última palabra del último nodo (hace que la lista sea circular)
        
        j menu


        first1:
            sw $0, 12($v0) # ------------------------------------------------------> primera categoría inicializada a 0
            sw $v0, cclist # ------------------------------------------------------> apunta cclist a la nueva categoría
            sw $v0, wclist # ------------------------------------------------------> apunta wclist a la nueva categoría
            sw $v0, finalc # ------------------------------------------------------> apunta finalc al nuevo nodo
            
            j menu
    .end


    nextcategory:
        lw $t0, wclist # ----------------------------------------------------------> carga la dirección del puntero wclist en $a0
        lw $t1, 12($t0) # ---------------------------------------------------------> avanza a la última palabra de la categoría
        sw $t1, wclist # ----------------------------------------------------------> actualiza el puntero wclist
        lw $t2, 4($t1) # ----------------------------------------------------------> avanzo a la dirección de la lista de la categoría a la que me moví
        sw $t2, slist # -----------------------------------------------------------> apunto el puntero slist al primer elemento
        beq $t1, $0, volver # -----------------------------------------------------> si la primera palabra esta vacia, vuelvo al menu
        lw $t2, ($t1) # -----------------------------------------------------------> cargo la direccion del último nodo de la lista de objetos en $t2
        sw $t2, final # -----------------------------------------------------------> actualizo el puntero al último elemento
        volver:
            j menu
    .end


    prevcategory:
        lw $t0, wclist # ----------------------------------------------------------> carga la dirección del puntero wclist en $a0
        lw $t1, ($t0) # -----------------------------------------------------------> carga en $t1 la primera palabra de la categoría
        sw $t1, wclist # ----------------------------------------------------------> actualiza el puntero wclist
        lw $t2, 4($t1) # ----------------------------------------------------------> avanzo a la dirección de la lista de la categoría a la que me moví
        sw $t2, slist # -----------------------------------------------------------> apunto el puntero slist al primer elemento
        beq $t1, $0, volver1 # ----------------------------------------------------> si la primera palabra esta vacia, vuelvo al menu
        lw $t2, ($t1) # -----------------------------------------------------------> cargo la direccion del último nodo de la lista de objetos en $t2
        sw $t2, final # -----------------------------------------------------------> actualizo el puntero al último elemento
        volver1:
            j menu
    .end

    allcategorys:
        lw $t0, cclist # -----------------------------------------------------------> carga en $t0 la dirección del primer nodo de la lista
        lw $t1, finalc # -----------------------------------------------------------> carga en $t1 la dirección del último nodo de la lista
        lw $t2, wclist # -----------------------------------------------------------> carga en $t1 la dirección de la categoría actual
        loop2:
            la $a0, salto # -------------------------------------------------------> muestra un salto de línea
            li $v0, 4
            syscall
            la $a0, 8($t0) # ------------------------------------------------------> cargo en $a0 el nombre del objeto y lo muestro
            li $v0, 4
            syscall
            beq $t0, $t2, ast
            beq $t0, $t1, menu # --------------------------------------------------> si se mostró el último objeto de la lista, vuelvo al menú
            lw $t0, 12($t0) # -----------------------------------------------------> cargo en $t0 la dirección del siguiente objeto
            j loop2 # -------------------------------------------------------------> loop
            ast:
                la $a0, asterisco
                li $v0, 4
                syscall
                beq $t0, $t1, menu # --------------------------------------------------> si se mostró el último objeto de la lista, vuelvo al menú
                lw $t0, 12($t0) # -----------------------------------------------------> cargo en $t0 la dirección del siguiente objeto
                j loop2
    .end

    mostrarobjetos:
        lw $t0, slist # -----------------------------------------------------------> carga en $t0 la dirección del primer nodo de la lista
        lw $t1, final # -----------------------------------------------------------> carga en $t1 la dirección del último nodo de la lista
        loop1:
            la $a0, salto # -------------------------------------------------------> muestra un salto de línea
            li $v0, 4
            syscall
            la $a0, 8($t0) # ------------------------------------------------------> cargo en $a0 el nombre del objeto y lo muestro
            li $v0, 4
            syscall
            beq $t0, $t1, menu # --------------------------------------------------> si se mostró el último objeto de la lista, vuelvo al menú
            lw $t0, 12($t0) # -----------------------------------------------------> cargo en $t0 la dirección del siguiente objeto
            j loop1 # -------------------------------------------------------------> loop
    .end

    
    newnode:
        move $t0, $a0 # -----------------------------------------------------------> preserva el argumento
        addi $sp, $sp, -4 # -------------------------------------------------------> reclamación de la pila
        sw $ra, ($sp) # -----------------------------------------------------------> apilo el registro $ra
        
        jal smalloc

        lw $ra, ($sp) # -----------------------------------------------------------> desapilo el registro $ra
        addi $sp, $sp, 4 # --------------------------------------------------------> liberación de la pila
        sb $t0, 8($v0) # ----------------------------------------------------------> guarda el argumento en el espacio reservado
        
        move $t0, $a1 
        sb $t0, 9($v0)
        move $t0, $a2
        sb $t0, 10($v0)
        move $t0, $a3
        sb $t0, 11($v0)
        
        lw $t1, slist # -----------------------------------------------------------> carga el puntero slist en $t1
        beq $t1, $0, first # ------------------------------------------------------> si la lista está vacía salta a first
        sw $v0, ($t1) # -----------------------------------------------------------> apunta el noda anterior hacia el nuevo nodo
        lw $t2, contador # --------------------------------------------------------> carga el valor del contador en $t2
        addi $t2, $t2, 0x1 # ------------------------------------------------------> suma 0x1 al contador
        sw $t2, contador # --------------------------------------------------------> actualiza el valor del contador
        lw $t3, final # -----------------------------------------------------------> carga en $t3 la dirección del último nodo

        numeracion:
            sw $t2, 4($t3) # ------------------------------------------------------> actualiza la numeración del nodo
            addi $t3, $t3, 16 # ---------------------------------------------------> avanza al siguiente nodo
            addi $t2, $t2, -0x1 # -------------------------------------------------> resta 0x1 a la numeración
            bne $v0, $t3, numeracion # --------------------------------------------> si $t3 es la dirección de memoria del nuevo nodo entonces termina el loop, sino sigue 
            sw $t2, 4($v0) # ------------------------------------------------------> carga la numeración en el nuevo nodo
            sw $t1, 12($v0) # -----------------------------------------------------> inserta la dirección del nodo siguiente
            sw $v0, slist # -------------------------------------------------------> actualiza el puntero
            lw $t1, final # -------------------------------------------------------> carga la dirección del puntero final en $t1
            sw $t1, ($v0) # -------------------------------------------------------> guarda la dirección del último nodo en la primera palabra del nuevo nodo (hace que la lista sea circular)
            sw $v0, 12($t1) # -----------------------------------------------------> guarda la dirección del nuevo nodo en la última palabra del último nodo (hace que la lista sea circular)
            lw $s0, wclist
            sw $v0, 4($s0) # ------------------------------------------------------> guarda en la categoría seleccionada la dirección del nuevo nodo
            
            j menu
        first:
            li $t2, 0x1
            sw $t2, 4($v0) # ------------------------------------------------------> carga un 0x1 como número del elemento
            sw $t2, contador # ----------------------------------------------------> actualiza el contador
            sw $0, 12($v0) # ------------------------------------------------------> primero nodo inicializado a 0
            sw $v0, slist # -------------------------------------------------------> apunta slist al nuevo nodo
            sw $v0, final # -------------------------------------------------------> apunta final al nuevo nodo
            lw $s0, wclist
            sw $v0, 4($s0) # ------------------------------------------------------> guarda en la categoría seleccionada la dirección del nuevo nodo
            j menu
    .end

    delnode:
        move $t0, $a0 # mueve la dirección del nodo a eliminar a $t0
        lw $t1, slist # carga la dirección del primer nodo de la lista en $t1
        lw $s1, final # carga la dirección del último nodo de la lista en $s1
        beq $s1, $t1, uno # si la lista tiene un solo elemento entonces pasa a uno
        beq $t1, $t0, prim # si es el primer nodo, salta a prim
        lw $t1, final # carga la dirección del último nodo de la lista en $t1
        beq $t1, $t0, ultimo # si es el último nodo, salta a prim
        otro:
            lw $t2, ($t0) # cargo en $t2 el nodo anterior al que voy a eliminar
            lw $t3, 12($t0) # cargo en $t3 el nodo posterior al que voy a eliminar
            sw $t3, 12($t2) # actualizo el puntero siguiente al anterior
            sw $t2, ($t3) # actualizo el puntero anterior al siguiente
            actualizarid2:
                lw $t4, 4($t3) # carga en $t4 la id del nodo
                addi $t4, $t4, -0x1 # resta uno a la id
                sw $t4, 4($t3) # actualiza la id del nodo
                beq $t3, $t1, term # si $t3 es el último nodo, salta a term
                lw $t3, 12($t3) # avanza al siguiente nodo
                j actualizarid2
        uno:
            lw $t3, wclist # carga la dirección de la categoría en $t3
            sw $0, 4($t3) # actualiza la dirección de la lista en la segunda palabra de la categoría
            sw $0, slist # actualiza slist
            sw $0, final # actualiza final
            j term
        prim:
            lw $t1, final # carga la dirección del último nodo de la lista en $t1
            lw $t2, 12($t0) # carga la dirección del segundo nodo en $t2
            sw $t2, 12($t1) # actualiza la circularidad de la lista
            sw $t1, ($t2) # actualiza la circularidad de la lista
            lw $t3, wclist # carga la dirección de la categoría en $t3
            sw $t2, 4($t3) # actualiza la dirección de la lista en la segunda palabra de la categoría
            sw $t2, slist # actualiza el puntero slist
            actualizarid1:
                lw $t4, 4($t2) # carga en $t4 la id del nodo
                addi $t4, $t4, -0x1 # resta uno a la id
                sw $t4, 4($t2) # actualiza la id del nodo
                beq $t2, $t1, term # si $t2 es el último nodo, salta a term
                lw $t2, 12($t2) # avanza al siguiente nodo
                j actualizarid1
        ultimo:
            lw $t1, slist # carga la dirección del primer nodo de la lista en $t1
            lw $t2, ($t0) # carga la dirección del penúltimo nodo en $t2
            sw $t2, ($t1) # actualiza la circularidad de la lista
            sw $t1, 12($t2) # actualiza la circularidad de la lista
            sw $t2, final # actualiza el puntero final
        term:
            addi $sp, $sp, -4 # -------------------------------------------------------> reclamación de la pila
            sw $ra, ($sp) # -----------------------------------------------------------> apilo el registro $ra
            jal sfree # salta a la subrutina para liberar el nodo
            lw $ra, ($sp) # -----------------------------------------------------------> desapilo el registro $ra
            addi $sp, $sp, 4 # --------------------------------------------------------> liberación de la pila
            bgtz $a1, borrarcategoria
            j menu
        borrarcategoria:
            jr $ra
    .end

    delcategory:
        li $a1, 1 # carga 1 en $a1
        lw $s3, slist # carga el inicio de la lista de la categoría en $s3
        lw $s4, final # carga el final de la lista de la categoría en $s4
        elimnodos:
            move $a0, $s3 # mueve la dirección del nodo a $a0
            lw $s5, 12($s3) # avanza al siguiente nodo
            jal delnode
            beq $s3, $s4, sig # si el nodo es el último, salta a sig
            move $s3, $s5 # avanza al siguiente nodo
            j elimnodos
        sig:
            lw $a0, wclist # carga la dirección de la categoría actual en $a0
            lw $t0, cclist # carga la dirección de la primera categoría en $t0 
            lw $t1, finalc # carga la dirección de la última categoría en $t1
            beq $a0, $t0, pri # si la categoría a eliminar es la primera, salta a pri
            beq $a0, $t1, ult # si la categoría a eliminar es la última, salta a ult
        otros:
            lw $t2, ($a0) # cargo en $t2 el nodo anterior al que voy a eliminar
            lw $t3, 12($a0) # cargo en $t3 el nodo posterior al que voy a eliminar
            sw $t3, 12($t2) # actualizo el puntero siguiente al anterior
            sw $t2, ($t3) # actualizo el puntero anterior al siguiente
            sw $t2, wclist # actualiza el puntero slist
            j termi
        pri:
            lw $t2, 12($a0) # carga la dirección del segundo nodo en $t2
            sw $t2, 12($t1) # actualiza la circularidad de la lista
            sw $t1, ($t2) # actualiza la circularidad de la lista
            sw $t2, wclist # actualiza el puntero wclist
            sw $t2, cclist # actualiza el puntero cclist
            sw $t2, final # actualiza el puntero final
            addi $t2, $t2, 4 # suma 4 a $t2
            sw $t2, slist # actualiza el puntero slist
            j termi
        ult:
            lw $t2, ($a0) # carga la dirección del penúltimo nodo en $t2
            sw $t2, ($t1) # actualiza la circularidad de la lista
            sw $t1, 12($t2) # actualiza la circularidad de la lista
            sw $t2, finalc # actualiza el puntero finalc
            sw $t2, wclist # actualiza el puntero wclist
        termi:
            jal sfree # salta a la subrutina para liberar el nodo
            j menu
    .end

    smalloc:
        li $a0, 16 # --------------------------------------------------------------> tamaño solicitado de 4 palabras
        li $v0, 9 # ---------------------------------------------------------------> syscall sbrk
        syscall
        jr $ra # ------------------------------------------------------------------> retorna la direccion de memoria en $v0
    .end


    sfree:
        la $t0, flist # carga la dirección del primer nodo de la lista de objetos en $t0
        sw $t0, 12($a0)
        sw $a0, flist  # $a0 node address in unused list
        jr $ra
    .end


    fin:
        li $v0, 10
        syscall
    .end
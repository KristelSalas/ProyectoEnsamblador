.model small
.stack 100h
.data
 
n1 dw ?    ;
n2 dw ?    ;
n3 dw ?    ;      
n4 dw ?    ;         Respaldos
n5 dw ?    ;            de
n6 dw ?    ;            las
po dw ?    ;        operaciones
n7 dw ?    ;
fact dw ?  ;
va dw ?    ;
re dw ?    ;
 
PUTC    MACRO   char
        PUSH    AX
        MOV     AL, char
        MOV     AH, 0Eh
        INT     10h     
        POP     AX
ENDM

;------------------------------------------- Clear screen ----------------------------------------------

DEFINE_CLEAR_SCREEN     MACRO
LOCAL skip_proc_clear_screen
JMP     skip_proc_clear_screen
CLEAR_SCREEN PROC NEAR
        PUSH    AX    
        PUSH    DS      
        PUSH    BX      
        PUSH    CX      
        PUSH    DI      
        MOV     AX, 40h
        MOV     DS, AX  
        MOV     AH, 06h 
        MOV     AL, 0   
        MOV     BH, 07  
        MOV     CH, 0   
        MOV     CL, 0   
        MOV     DI, 84h 
        MOV     DH, [DI] 
        MOV     DI, 4Ah 
        MOV     DL, [DI]
        DEC     DL      
        INT     10h
        MOV     BH, 0   
        MOV     DL, 0   
        MOV     DH, 0   
        MOV     AH, 02
        INT     10h
        POP     DI      
        POP     CX      
        POP     BX      
        POP     DS      
        POP     AX      
        RET
CLEAR_SCREEN ENDP
skip_proc_clear_screen:
ENDM

;------------------------------------------- Print ----------------------------------------------
  
PRINT   MACRO   sdat
LOCAL   next_char, s_dcl, printed, skip_dcl
PUSH    AX     
PUSH    SI      
JMP     skip_dcl      
        s_dcl DB sdat, 0
skip_dcl:
        LEA     SI, s_dcl        
next_char:      
        MOV     AL, CS:[SI]
        CMP     AL, 0
        JZ      printed
        INC     SI
        MOV     AH, 0Eh 
        INT     10h
        JMP     next_char
printed:
POP     SI      
POP     AX      
ENDM    

;------------------------------------------- Printn ----------------------------------------------
 
PRINTN   MACRO   sdat
LOCAL   next_char, s_dcl, printed, skip_dcl
PUSH    AX      
PUSH    SI      
JMP     skip_dcl 
        s_dcl DB sdat, 13, 10, 0
skip_dcl:
        LEA     SI, s_dcl        
next_char:      
        MOV     AL, CS:[SI]
        CMP     AL, 0
        JZ      printed
        INC     SI
        MOV     AH, 0Eh 
        INT     10h
        JMP     next_char
printed:
POP     SI      
POP     AX      
ENDM            

;------------------------------------------- Scan num ----------------------------------------------
     
DEFINE_SCAN_NUM         MACRO
LOCAL make_minus, ten, next_digit, set_minus
LOCAL too_big, backspace_checked, too_big2
LOCAL stop_input, not_minus, skip_proc_scan_num
LOCAL remove_not_digit, ok_AE_0, ok_digit, not_cr
JMP     skip_proc_scan_num
SCAN_NUM        PROC    NEAR
        PUSH    DX
        PUSH    AX
        PUSH    SI        
        MOV     CX, 0
        MOV     CS:make_minus, 0
next_digit:
        MOV     AH, 00h
        INT     16h
        MOV     AH, 0Eh
        INT     10h
        CMP     AL, '-'
        JE      set_minus
        CMP     AL, 13 
        JNE     not_cr
        JMP     stop_input
not_cr:
        CMP     AL, 8                   
        JNE     backspace_checked
        MOV     DX, 0                 
        MOV     AX, CX                  
        DIV     CS:ten                 
        MOV     CX, AX
        PUTC    ' '                     
        PUTC    8                     
        JMP     next_digit
backspace_checked:
        CMP     AL, '0'
        JAE     ok_AE_0
        JMP     remove_not_digit
ok_AE_0:        
        CMP     AL, '9'
        JBE     ok_digit
remove_not_digit:       
        PUTC    8       
        PUTC    ' '    
        PUTC    8             
        JMP     next_digit       
ok_digit:
        PUSH    AX
        MOV     AX, CX
        MUL     CS:ten                
        MOV     CX, AX
        POP     AX
        CMP     DX, 0
        JNE     too_big
        SUB     AL, 30h
        MOV     AH, 0
        MOV     DX, CX    
        ADD     CX, AX
        JC      too_big2  
        JMP     next_digit
set_minus:
        MOV     CS:make_minus, 1
        JMP     next_digit
too_big2:
        MOV     CX, DX     
        MOV     DX, 0     
too_big:
        MOV     AX, CX
        DIV     CS:ten 
        MOV     CX, AX
        PUTC    8      
        PUTC    ' '     
        PUTC    8        
        JMP     next_digit 
stop_input:
        CMP     CS:make_minus, 0
        JE      not_minus
        NEG     CX
not_minus:
        POP     SI
        POP     AX
        POP     DX
        RET
make_minus      DB      ?    
ten             DW      10     
SCAN_NUM        ENDP
skip_proc_scan_num:
ENDM        

;------------------------------------------- Print num uns ----------------------------------------------

DEFINE_PRINT_NUM_UNS    MACRO
LOCAL begin_print, calc, skip, print_zero, end_print, ten
LOCAL skip_proc_print_num_uns
JMP     skip_proc_print_num_uns
PRINT_NUM_UNS   PROC    NEAR
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        MOV     CX, 1
        MOV     BX, 10000 
        CMP     AX, 0
        JZ      print_zero
begin_print:
        CMP     BX,0
        JZ      end_print
        CMP     CX, 0
        JE      calc
        CMP     AX, BX
        JB      skip
calc:
        MOV     CX, 0   
        MOV     DX, 0
        DIV     BX      
        ADD     AL, 30h    
        PUTC    AL
        MOV     AX, DX 
skip:
        PUSH    AX
        MOV     DX, 0
        MOV     AX, BX
        DIV     CS:ten  
        MOV     BX, AX
        POP     AX
        JMP     begin_print
print_zero:
        PUTC    '0'       
end_print:
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        RET
ten             DW      10       
PRINT_NUM_UNS   ENDP
skip_proc_print_num_uns:
ENDM 

;------------------------------------------- Print num ----------------------------------------------  

DEFINE_PRINT_NUM        MACRO
LOCAL not_zero, positive, printed, skip_proc_print_num
JMP     skip_proc_print_num
PRINT_NUM       PROC    NEAR
        PUSH    DX
        PUSH    AX
        CMP     AX, 0
        JNZ     not_zero
        PUTC    '0'
        JMP     printed
not_zero:
        CMP     AX, 0
        JNS     positive
        NEG     AX
        PUTC    '-'
positive:
        CALL    PRINT_NUM_UNS
printed:
        POP     AX
        POP     DX
        RET
PRINT_NUM       ENDP
skip_proc_print_num:
ENDM
   
.code   

jmp menu                ;salta al menú para iniciar el código

menu:  
    call clear_screen    
    printn "Bienvenido, digite el numero asignado a lo que desea realizar: "
    printn "1-Ver hora"
    printn "2-Operaciones aritmeticas" 
    printn "3-Numero factorial"
    printn "4-Conversion de Sistemas Numericos"
    printn "5-Conversion de Longitudes"
    printn "6-Conversiones de Masa"
    printn "7-Conversion de Monedas"
    printn "8-Conversiones de Temperatura"
    printn "9-Salir"                    
    print "Opcion: "
    call scan_num            ;lee el numero y lo almacena en cx
    cmp cx,1                 ;hace la comparacion entre cx y 1
    je hora                  ;si conccuerda brinca a hora  
    cmp cx,2                 ;hace la comparacion entre cx y 2
    je menuaritmeticas       ;si conccuerda brinca a menuaritmeticas
    cmp cx,3                 ;hace la comparacion entre cx y 3
    je factorial             ;si conccuerda brinca a factorial
    cmp cx,4                 ;hace la comparacion entre cx y 4
    je numerico              ;si conccuerda brinca a conversiones
    cmp cx,5                 ;hace la comparacion entre cx y 5
    je longitud             ;si concuerda brinca a 
    cmp cx,6                 ;hace la comparacion entre cx y 6 
    je masa                 ;si concuerda brinca a 
    cmp cx,7                 ;hace la comparacion entre cx y 7
    je moneda               ;si concuerda brinca a 
    cmp cx,8                 ;hace la comparacion entre cx y 8
    je temperatura          ;si concuerda brinca a 
    cmp cx,9                 ;hace la comparacion entre cx y 9
    jmp salir                ;si concuerda brinca a salir
     
    hora:
        jmp hora2 
    menuaritmeticas:
        jmp menuaritmeticas2
    factorial:
        jmp factorial2 
    numerico:
        jmp numerico2
    longitud:
        jmp longitud2 
    masa:
        jmp masa2
    moneda:
        jmp moneda2
    temperatura:
        jmp temperatura2

hora2:
    call clear_screen       
    printn
    print "Hora: "
    mov ah,2ch
    int 21h
    xor ax,ax  
    mov al,ch 
    call print_num_uns
    print ":"
    xor ax,ax  
    mov al,cl 
    call print_num_uns
    print ":"
    xor ax,ax  
    mov al,dh 
    call print_num_uns   
    mov ah,00h
    int 16h
    jmp menu
    
menuaritmeticas2:
    xor cx,cx           ;limpia el registro cx para evitar interferencias
    call clear_screen   ;limpia la consola
    printn "Digite el numero de la operacion que desea realizar"
    printn "1-Suma"
    printn "2-Resta"
    printn "3-Multiplicacion"
    printn "4-Division"
    printn "5-Potencia"
    print "Opcion: "        
    call scan_num       
    cmp cx,1            ;hace la comparacion entre cx y 1
    je suma             ;si es verdadera salta a la etiqueta suma
    cmp cx,2            ;hace la comparacion entre cx y 2
    je resta            ;si es verdadera salta a la etiqueta resta
    cmp cx,3            ;hace la comparacion entre cx y 3
    je multiplicacion   ;si es verdadera salta a la etiqueta multiplicacion
    cmp cx,4            ;hace la comparacion entre cx y 4
    je division         ;si es verdadera salta a la etiqueta division
    cmp cx,5            ;hace la comparacion entre cx y 5
    je potencia         ;si es verdadera salta a la etiqueta potencia
    
    suma:
        jmp suma2 
    resta:
        jmp resta2
    multiplicacion:
        jmp multiplicacion2
    division:
        jmp division2
    potencia:
        jmp potencia2
    
    suma2:
        call clear_screen
        printn ""   
        print "-Suma-"
        printn ""
        print "Primer numero: "   
        call scan_num  ;guarda en CX
        mov n1,cx      ;mover de cx a variable n1 
        printn "" 
        print "Segundo numero: "
        call scan_num  ;guarda en CX
        mov n2,cx      ;mover de cx a variable n2
        printn ""
        mov ax,n1      ;cargar lo de n1 a al
        add ax,n2      ;suma lo de n2 con lo de ax 
        
        printn "" 
        print "El resultado es: "
        call print_num ; imprime lo que guarda ax
        mov ah,00h
        int 16h
        jmp menu

    resta2: 
        call clear_screen 
        printn ""
        print "-Resta-" 
        printn ""
        print "Primer numero: "   
        call scan_num  ;guarda en CX
        mov n1,cx      ;mover de cl a variable n1 
        printn "" 
        print "Segundo numero: "
        call scan_num  ;guarda en CX
        mov n2,cx      ;mover de cl a variable n2
        printn ""
        mov ax,n1      ;cargar lo de n1 a al
        sub ax,n2      ;resta lo de n2 con lo de al
        
        printn ""
        print "El resultado es: "
        call print_num ; imprime lo que guarda ax
        mov ah,00h
        int 16h
        jmp menu

    multiplicacion2:
        call clear_screen 
        printn ""
        print "-Multiplicacion-"
        printn ""
        print "Primer numero: "   
        call scan_num   ;guarda en CX
        mov n1,cx       ;mover de cx a variable n1 
        printn "" 
        print "Segundo numero: "
        call scan_num   ;guarda en CX
        mov n2,cx       ;mover de cx a variable n2
        printn ""

        mov ax,n1       ;cargar lo de n1 a ax
        mul n2          ;multiplica lo de n2 con lo de ax
 
        printn ""
        print "El resultado es: "
        call print_num ; imprime lo que guarda ax         
        mov ah,00h
        int 16h
        jmp menu

    division2: 
        call clear_screen 
        printn ""
        print "-Division-"
        printn ""
        print "Primer numero: "   
        call scan_num   ;guarda en CX
        mov n3,cx       ;mover de cl a variable n3 
        printn "" 
        print "Segundo numero: "
        call scan_num   ;guarda en CX
        mov n4,cx       ;mover de cl a variable n4

        mov ax,n3       ;cargar lo de n3 a al  
        mov bx,n4       ;cargar a bl lo de n4
        div n4          ;divide bl entre al o algo así xd 
         
        printn ""
        print "El resultado es: "
        call print_num ; imprime lo que guarda ax 
        mov ah,00h
        int 16h
        jmp menu

    potencia2:
        call clear_screen 
        printn ""
        print "-Potencia-"
        printn ""
        print "Ingrese el numero base: "   
        call scan_num   ;guarda en CX
        mov n5,cx       ;mover de cl a variable n5   
        mov po,cx       ;guarda en po lo de cl
        printn "" 
        print "Ingrese el exponente: "
        call scan_num   ;guarda en CX
        mov n6,cx       ;mover de cl a variable n6   
        printn ""
        
        dec n6          ;disminuye en uno para el ciclo
        mov cx,n6       ;se asigna lo de n6 decrementado cl que controla el ciclo
        
        ciclopo:                                      
        mov ax,po       ;cargar lo de po a al                
        mul n5          ;multiplica lo de n5 con lo de po     
        mov po,ax       ;guarda el resultado de al en po
        loop ciclopo    ;salta al ciclo
        
        xor ax,ax
        mov ax,po       ;mueve de po a al el resultado para imprimirlo
        print "El resultado es: "
        call print_num  ;imprime lo que guarda ax
        mov ah,00h
        int 16h
        jmp menu
    
factorial2:
    call clear_screen
    printn ""
    print "-Factorial-"
    printn ""
    print "Ingrese el numero del que desea obtener el factorial: "   
    call scan_num       ;guarda en CX
    mov n7,cx           ;mover de cl a variable n7   
    mov fact,cx         ;mueve lo de cl a fact
                        
    dec n7              ;le resta uno para empezar a multiplicar
    mov cx,n7           ;se asigna lo de n7 decrementado cl que controla el ciclo
    
    factor:
    mov ax,n7           ;cargar lo de n7 a al        
    mul fact            ;multiplica lo de fact con lo de al
    mov fact,ax         ;guarda lo de al en fact
    dec n7              ;decrementa lo de n7 para la proxima multiplicacion
    loop factor
    
    xor ax,ax
    mov ax,fact         ;mueve lo de fact a al para imprimir
    printn ""
    print "El resultado es: "
    call print_num      ;imprime lo que guarda ax 
    mov ah,00h
    int 16h
    jmp menu
    
numerico2:
    print "noup"
    mov ah,00h
    int 16h
    jmp menu
    
longitud2:  
    xor cx,cx 
    call clear_screen
    printn "Seleccione la operacion a realizar"
    printn "1-Metros a kilometros"
    printn "2-Kilometros a metros"
    printn "3-Metros a millas"
    printn "4-Millas a metros"
    printn "5-Kilometros a millas"
    printn "6-Millas a kilometros"
    print "Opcion: "            
    call scan_num           
    cmp cx,1
    je metroakilo
    cmp cx,2
    je kiloametro
    cmp cx,3
    je metroami
    cmp cx,4
    je miametro
    cmp cx,5
    je kiloami
    cmp cx,6
    je miakilo
        
    metroakilo: 
        jmp metroakilo2 
    kiloametro:
        jmp kiloametro2
    metroami:
        jmp metroami2
    miametro:
        jmp miametro2
    kiloami:
        jmp kiloami2
    miakilo:
        jmp miakilo2
         
    metroakilo2: ;Metros a kilometros FUNCIONA PERO NO DA DECIMALES
        call clear_screen    
        printn ""
        print "Digite el valor: "
        call scan_num
        mov va,cx                
        ;valor multplicado por 1 y divido en 1000 
        ;multiplicación
        mov ax,1        ;carga a ax el valor de re
        mul va          ;multiplica lo de va con lo de ax 
        ;division 
        mov bx,1000     ;cargar 1 a bx
        div bx          ;divide bx entre ax y guarda en ax
        printn ""
        print "El resultado es: "
        call print_num ; imprime lo que guarda ax  
        mov ah,00h
        int 16h
        jmp menu 
         
    kiloametro2: ;Kilometros a metros
        
        call clear_screen   
        printn ""
        print "Digite el valor: "
        call scan_num   ;Lee el numero guarda en cx
        mov va,cx       ;guarda en variable va lo de cx
        mov ax,1000     ;valor por el que se va a multiplicar
        mul va          ;multiplica lo de va con lo de ax   
        printn ""
        print "El resultado es: "
        call print_num  ; imprime lo que guarda ax 
        mov ah,00h      ;Espera enter   
        int 16h         ; "       "
        jmp menu 
                
    metroami2:   ;Metros a millas
       call clear_screen  
       print "No :p" 
       mov ah,00h
       int 16h
       jmp menu  
                
    miametro2:   ;Millas a metros    FUNCIONA PERO REDONDEA LOS DECIMALES
       call clear_screen  
       ;el valor por 1609.34 ya que cada metro vale eso en millas   
       printn ""
       print "Digite el valor: "
       call scan_num   ;Lee el numero guarda en cx
       mov va,cx       ;guarda en variable va lo de cx 
                
       mov ax,1609  ;valor por el que se va a multiplicar
       mul va          ;multiplica lo de va con lo de ax
       printn ""
       print "El resultado es: "
       call print_num  ;imprime lo que guarda ax 
       mov ah,00h      ;espera un enter
       int 16h
       jmp menu
                
    kiloami2:    ;Kilometros a millas
       call clear_screen  
       print "falta"
                
       mov ah,00h
       int 16h
       jmp menu
              
    miakilo2:    ;Millas a kilometros     FUNCIONA SIN DECIMALES
       call clear_screen 
       ;se multiplica el valor por 1,609 
       printn ""
       print "Digite el valor: "
       call scan_num   ;Lee el numero guarda en cx
       mov va,cx       ;guarda en variable va lo de cx
                
       mov ax,1609     ;valor por el que se va a multiplicar
       mov bx,va       ;cargar a bx el valor
       mul bx          ;multiplica lo de bx con lo de ax
       mov re,ax 
                
       xor ax,ax
       mov ax,re    
       printn ""
       print "El resultado es: "
       call print_num ; imprime lo que guarda ax
       mov ah,00h      ;espera un enter
       int 16h         
       jmp menu
                 
masa2:      
    xor cx,cx 
    call clear_screen
    printn "Seleccione la operacion a realizar"
    printn "1-Gramos a kilogramos"
    printn "2-Kilogramos a gramos"
    printn "3-Gramos a libras"
    printn "4-Libras a gramos"
    printn "5-Kilogramos a libras"
    printn "6-Libras a kilogramos"
    print "Opcion: "           
    call scan_num           
    cmp cx,1
    je graki
    cmp cx,2
    je kigra
    cmp cx,3
    je grali
    cmp cx,4
    je ligra
    cmp cx,5
    je kili
    cmp cx,6
    je liki 
        
    graki:         
        jmp graki2 
    kigra:
        jmp kigra2
    grali:
        jmp grali2
    ligra:
        jmp ligra2
    kili:
        jmp kili2
    liki:
        jmp liki2
        
    graki2:      ;gramos a kilos
        call clear_screen  
        ;dividir el valor entre mil     
        printn "" 
        print "Ingrese la cantidad de gramos:"
        call scan_num   ;Toma el numero y lo guarda en cx
        mov n1,cx       ;Muevo de cx a n1  
        mov ax,n1       ;Mueve de la variable a ax
        mov bx,1000     ;Mueve 1000 a bx
        div bx          ;Divide ax entre bx 
        printn ""
        print "El resultado es: "
        call print_num ; imprime lo que guarda ax
        mov ah,00h      ;Espera un enter
        int 16h
        jmp menu
                
    kigra2:      ;kilos a gramos
        call clear_screen  
        ;multiplicar el valor por mil   
        printn ""
        print "Ingrese la cantidad de kilos:"
        call scan_num   ;Toma el numero y lo guarda en cx
        mov n1,cx       ;Muevo de cx a n1  
        mov ax,n1       ;Mueve de la variable a ax
        mov bx,1000     ;Mueve 1000 a bx
        mul bx          ;Multiplica ax entre bx 
        printn ""
        print "El resultado es: "
        call print_num ; imprime lo que guarda ax
        mov ah,00h      ;Espera un enter
        int 16h
        jmp menu
                
    grali2:      ;gramos a libras
                call clear_screen  
        ;dividir el valor entre 454
        printn ""
        print "Ingrese la cantidad de gramos:"
        call scan_num   ;Toma el numero y lo guarda en cx
        mov n1,cx       ;Muevo de cx a n1  
        mov ax,n1       ;Mueve de la variable a ax
        mov bx,454      ;Mueve 454 a bx
        div bx          ;Divide ax entre bx  
        printn ""
        print "El resultado es: "
        call print_num ; imprime lo que guarda ax
        mov ah,00h      ;Espera un enter
        int 16h
        jmp menu
                
    ligra2:      ;libras a gramos
        call clear_screen  
        ;multiplicar el valor por 454 
        printn ""
        print "Ingrese la cantidad de libras: "
        call scan_num   ;Toma el numero y lo guarda en cx
        mov n1,cx       ;Muevo de cx a n1  
        mov ax,n1       ;Mueve de la variable a ax
        mov bx,454      ;Mueve 454 a bx
        mul bx          ;Multiplica ax entre bx  
        printn ""
        print "El resultado es: "
        call print_num ; imprime lo que guarda ax 
        mov ah,00h      ;Espera un enter
        int 16h
        jmp menu
                
    kili2:       ;kilos a libras
        call clear_screen  
        ;multiplicar el valor por 2   
        printn ""
        print "Ingrese la cantidad de kilos: "
        call scan_num   ;Toma el numero y lo guarda en cx
        mov n1,cx       ;Mueve de cx a n1  
        mov ax,n1       ;Mueve de la variable a ax
        mov bx,2        ;Mueve 2 a bx
        mul bx          ;Multiplica ax entre bx
        printn "" 
        print "El resultado es: "
        call print_num ; imprime lo que guarda ax
        mov ah,00h      ;Espera un enter
        int 16h
        jmp menu
                
    liki2:       ;libras a kilos
        call clear_screen  
        ;dividir el valor entre 2 
        printn ""
        print "Ingrese la cantidad de libras: "
        call scan_num   ;Toma el numero y lo guarda en cx
        mov n1,cx       ;Muevo de cx a n1  
        mov ax,n1       ;Mueve de la variable a ax
        mov bx,2        ;Mueve 2 a bx
        div bx          ;Divide ax entre bx
        printn ""
        print "El resultado es: "
        call print_num ; imprime lo que guarda ax
        mov ah,00h      ;Espera un enter
        int 16h
        jmp menu  
        
moneda2:  
    xor cx,cx 
    call clear_screen
    printn "Seleccione la operacion a realizar"
    printn "1-Colon a dolar"
    printn "2-Dolar a colon"
    print "Opcion: "           
    call scan_num          
    cmp cx,1
    je codo
    cmp cx,2
    je doco 
        
    codo:   
        jmp codo2 
        doco:
        jmp doco2
        
    codo2:     ;Colon a dolar
        call clear_screen  
        ;Multiplicar el valor entre 585 
        printn ""
        print "Ingrese la cantidad de colones: "
        call scan_num   ;Toma el numero y lo guarda en cx
        mov n1,cx       ;Mueve de cx a n1
        mov ax,n1       ;Mueve de la variable a ax
        mov bx,585      ;Mueve 585 a bx
        mul bx          ;Multiplica ax entre bx
        printn "" 
        print "El resultado es: "
        call print_num  ;imprime lo que guarda ax  
        mov ah,00h      ;Espera el enter
        int 16h
        jmp menu
                
    doco2:     ;Dolar a colon
        call clear_screen      
        printn ""
        print "Ingrese la cantidad de dolares: "
        call scan_num   ;Toma el numero y lo guarda en cx
        mov n1,cx       ;Mueve de cx a n1
        mov ax,n1       ;Mueve de la variable a ax
        mov bx,585      ;Mueve 585 a bx
        div bx          ;Divide ax entre bx
        printn ""
        print "El resultado es: "
        call print_num ; imprime lo que guarda ax
        mov ah,00h      ;Espera el enter
        int 16h
        jmp menu
        
temperatura2:  
    xor cx,cx 
    call clear_screen
    printn "Seleccione la operacion a realizar"
    printn "1-Celsius a Fahrenheit"
    printn "2-Fahrenheit a Celsius"
    print "Opcion: "            
    call scan_num           
    cmp cx,1
    je cefa
    cmp cx,2
    je face 
        
    cefa:
        jmp cefa2 
    face:
        jmp face2
        
    cefa2:               ;Celsius a Farhenheit
        call clear_screen  
        ;9/5 multiplicado por el valor + 32
        printn "" 
        print "Ingrese los grados celsius: "
        call scan_num   ;Toma el numero y lo guarda en cx
        mov n1,cx       ;Mueve de cx a n1
        mov ax,n1       ;Mueve de la variable a ax
        mov bx,2        ;Mueve 2 a bx
        mul bx          ;Multiplica ax entre bx 
        add ax,32
        printn ""
        print "Los grados Farhenheit son aproximadamente:"
        mov ah,00h
        int 16h
        jmp menu
                
    face2:               ;Farhenheit a Celsius
        call clear_screen  
        ;5/9(valor - 32)    
        printn ""
        print "Ingrese los grados Farhenheit:"
        call scan_num   ;Toma el numero y lo guarda en cx
        mov n1,cx       ;Mueve de cx a n1
        mov ax,n1
        sub ax,32
        mov n1,ax
                
        mov ax,n1       ;Mueve de la variable a ax
        mov bx,1        ;Mueve 1 a bx
        mul bx          ;Multiplica ax entre bx 
        printn ""
        print "Los grados Celsius son aproximadamente:"
        call print_num ; imprime lo que guarda ax
        mov ah,00h
        int 16h
        jmp menu
          
salir:
    print "adios :c"
    ret
        
DEFINE_PRINT_NUM_UNS
DEFINE_PRINT_NUM
DEFINE_SCAN_NUM 
DEFINE_CLEAR_SCREEN 
end
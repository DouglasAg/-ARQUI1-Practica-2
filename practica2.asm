ORG 100h

inicio:
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    jmp menu

menu:
    call limpiar
    mov dx, menuinicio
    call escribir

    mov ah, 01
    int 21h

    cmp al, 49
    je entrar

    cmp al, 50
    je registrar

    cmp al, 51
    je salir
    jne opcionno

%macro leerarchivo 3
    ; 1 ruta archivo, 2 contenedor de los datos archivo
    ; 3 se pondra el numero de caracteres leidos
    ;limpiar ax,cx,dx
    xor ax, ax
    xor cx, cx
    xor dx, dx
    ;abrir archivo
    mov ah, 3dh
    mov cx, 00
    mov dx, %1
    int 21h
    ;archivo no existe
    jc noarchivo
    ;archivo si existe se lee
    mov bx, ax
    mov ah, 3fh
    mov cx, 499
    mov dx, [%2]
    int 21h

    ;numero de caracteres
    mov [%3], ax

    mov ah, 3eh
    int 21h
%endmacro

%macro escribir_archivo 3
    ; 1 nombre archivo, 2 numero de caracters,
    ; 3 texto a escribir
    ; crear archivo
    mov ah, 3ch
    mov cx, 0
    mov dx, %1
    int 21h
    jc menu
    mov bx, ax
    mov ah, 3eh
    int 21h

    ;abrir el archivo
    mov ah,3dh
    mov al,1h ;Abrimos el archivo en solo escritura.
    mov dx, %1
    int 21h
    jc menu ;Si hubo error

    ;Escritura de archivo
    mov bx,ax ; mover hadfile
    mov cx,[%2] ;num de caracteres a grabar
    mov dx,%3
    mov ah,40h
    int 21h
    
    cmp cx,ax
    jne menu ;error salir
    mov ah,3eh  ;Cierre de archivo 
    int 21h
%endmacro

entrar:
    call limpiar
    mov dx, msjiniioentrar
    call escribir
    xor si, si
    mov si, usuario
    
    mov cx,100
    regresa: 
        mov ah,07h 
        int 21h 
        cmp al,13 
        je termina 
        mov [si], al 
        inc si
        mov dl,al 
        mov ah,02h ;- Para imprimir por pantalla un caracter 
        int 21h 
    loop regresa 
    termina: 
        
        mov dx, msjcontrasena
        call escribir
        
        xor si, si
        mov si, contrasena 
        mov cx, 100
        regresa2: 
            mov ah,07h 
            int 21h 
            cmp al,13 
            je termina2 
            mov [si],al 
            inc si 
            mov dl,al 
            mov ah,02h ;- Para imprimir por pantalla un caracter 
            int 21h 
        loop regresa2

   
    termina2: 
        xor bx, bx 
        mov bx, 0
        mov [tamuser], bx
        mov [tampalabraconcat], bx

        leerarchivo rutaarchivo, textoleido, numcarleido
        mov si, [textoleido]
        jmp iniciolog

iniciolog:
    jmp inicioleerusario

inicioleerusario:
    xor bx, bx 
    mov bx, 0
    mov [tamuser], bx
    mov [tampalabraconcat], bx
    jmp comporbarcaracter

iniciousario:
    xor bx, bx 
    mov bx, 0
    mov [tamuser], bx
    mov [tampalabraconcat], bx
    jmp repetircomp

iniciocontra:
    xor bx, bx 
    mov bx, 0
    mov [tamcontra], bx
    mov [tampalabraconcat], bx
    jmp repetircomp

comporbarcaracter:
    lodsb
    cmp al, 44                  ; coma
    je comausuario
    cmp al, 59                  ; punto y coma
    je puntocomausuario
    jne concatenarpalabra       ; otro simbolo solo concatenar

repetircomp:
    mov dl, [numcar]
    inc dl
    mov [numcar], dl
    
    
    mov al, [numcar]
    mov bl, [numcarleido]
    cmp al, bl
    je fincompronacion
    jne comporbarcaracter

concatenarpalabra:
    mov [siactuall], si   
    xor si, si
    mov si, palabraconcat   
    mov bx, [tampalabraconcat]
    mov [si + bx], al
    inc bx
    mov [tampalabraconcat], bx    
    xor si, si
    mov si, [siactuall]
    jmp repetircomp

comausuario:
    mov [siactuall], si
    xor si, si
    mov si, usuariocompa
    mov di, palabraconcat
    mov bx, 0
    mov [connum], bx
    jmp concat

concat:
    mov cl, [connum]
    cmp cl, [tampalabraconcat]
    jne continuaconcat
    je continuarcomausuario

continuaconcat:
    mov dl, [di]
    mov [si + bx], dl
    inc bx
    inc di
    mov cl, [connum]
    add cl, 1
    mov [connum], cl
    jmp concat

continuarcomausuario:
    mov bx, [tampalabraconcat]
    mov [tamuser], bx

    xor si, si
    mov si, [siactuall]
    jmp iniciocontra

puntocomausuario:
    mov [siactuall], si
    xor si, si
    mov si, contrasenacompa
    mov di, palabraconcat
    mov bx, 0
    mov [connum], bx
    jmp concatcontra

concatcontra:
    mov cl, [connum]
    cmp cl, [tampalabraconcat]
    jne continuaconcatcontra
    je continuarpuntocoma

continuaconcatcontra:
    mov dl, [di]
    mov [si + bx], dl
    inc bx
    inc di
    mov cl, [connum]
    add cl, 1
    mov [connum], cl
    jmp concatcontra

continuarpuntocoma:
    mov bx, [tampalabraconcat]
    mov [tamcontra], bx

    xor si, si
    mov si, [siactuall]
    jmp comprobarusuario

comprobarusuario:
    mov [siactuall], si
    xor si, si
    xor di, di
    xor cx, cx   

    mov cx, [tamuser]
    mov si, usuariocompa
    mov di, usuario
    
    repe cmpsb 
    jne continuaringreso
    je compararcontra
    

compararcontra:
    xor si, si
    xor di, di
    xor cx, cx
    
    mov cx, [tamcontra]
    mov si, contrasenacompa
    mov di, contrasena
    
    repe cmpsb 
    jne continuaringreso
    je siingreso
    

continuaringreso:
    mov si, [siactuall]
    jmp iniciousario

siingreso:
    mov si, [usuariocompa]
    jmp compadmin

concatadmin:
    mov cl, [connum]
    cmp cl, 5
    jne continuaconcatadmin
    je compadmin

continuaconcatadmin:
    mov dl, [di]
    mov [si + bx], dl
    inc bx
    inc di
    mov cl, [connum]
    add cl, 1
    mov [connum], cl
    jmp concatadmin

compadmin:
    mov si, usuariocompa
    lodsb
    cmp al, 97

    
    jne noesadmin
    je esadmind


esadmind:
    lodsb
    cmp al, 100
    jne noesadmin
    je esadmini

esadmini:
    lodsb
    cmp al, 109
    jne noesadmin
    je esadminn

esadminn:
    lodsb
    cmp al, 105
    jne noesadmin
    je esadmin

esadmin:
    call limpiar
    mov dx, menuadmin
    call escribir

    mov ah, 01
    int 21h

    cmp al, 49 ; top 10 puntos
    je menu

    cmp al, 50 ; top 10 tiempo
    je menu

    cmp al, 50 ; regresar menu
    je menu
    jne noesadmin

fincompronacion:
    mov ah, 08
    int 21h
    jmp menu

registrar:
    call limpiar
    mov dx, msjiniioentrar
    call escribir
    xor si, si
    mov si, usuario
    
    mov cx,100
    regresa3: 
        mov ah,07h 
        int 21h 
        cmp al,13 
        je termina3 
        mov [si], al 
        inc si
        mov dl,al 
        mov ah,02h ;- Para imprimir por pantalla un caracter 
        int 21h 
    loop regresa3 
    termina3:
        mov bx, 100
        sub bx, cx
        mov [numus], bx 
        xor bx, bx 
        mov bx, 0
        mov [tamuser], bx
        mov [tampalabraconcat], bx
        leerarchivo rutaarchivo, textoleido, numcarleido
        mov si, [textoleido]
        jmp iniciobuscarusuario

iniciobuscarusuario:
    xor bx, bx 
    mov bx, 0
    mov [tamuser], bx
    mov [tampalabraconcat], bx
    jmp comporbarcaracterparanuscar

iniciousariobusqueda:
    xor bx, bx 
    mov bx, 0
    mov [tamuser], bx
    mov [tampalabraconcat], bx
    jmp repetircompbusqueda

iniciocontrabusqueda:
    xor bx, bx 
    mov bx, 0
    mov [tamcontra], bx
    mov [tampalabraconcat], bx
    jmp repetircompbusqueda

comporbarcaracterparanuscar:
    lodsb
    cmp al, 44                          ; coma
    je comausuariobusqueda
    cmp al, 59                          ; punto y coma
    je puntocomausuariobusqueda
    jne concatenarpalabrabusqueda       ; otro simbolo solo concatenar

repetircompbusqueda:
    mov dl, [numcar]
    inc dl
    mov [numcar], dl
    
    
    mov al, [numcar]
    mov bl, [numcarleido]
    cmp al, bl
    je continuarregistrar
    jne comporbarcaracterparanuscar

concatenarpalabrabusqueda:
    mov [siactuall], si   
    xor si, si
    mov si, palabraconcat   
    mov bx, [tampalabraconcat]
    mov [si + bx], al
    inc bx
    mov [tampalabraconcat], bx    
    xor si, si
    mov si, [siactuall]
    jmp repetircompbusqueda

comausuariobusqueda:
    mov [siactuall], si
    xor si, si
    mov si, usuariocompa
    mov di, palabraconcat
    mov bx, 0
    mov [connum], bx
    jmp concatbusqueda

concatbusqueda:
    mov cl, [connum]
    cmp cl, [tampalabraconcat]
    jne continuaconcatbusqueda
    je continuarcomausuariobusqueda

continuaconcatbusqueda:
    mov dl, [di]
    mov [si + bx], dl
    inc bx
    inc di
    mov cl, [connum]
    add cl, 1
    mov [connum], cl
    jmp concatbusqueda

continuarcomausuariobusqueda:
    mov bx, [tampalabraconcat]
    mov [tamuser], bx

    xor si, si
    mov si, [siactuall]
    jmp iniciocontrabusqueda

puntocomausuariobusqueda:
    mov [siactuall], si
    xor si, si
    mov si, contrasenacompa
    mov di, palabraconcat
    mov bx, 0
    mov [connum], bx

    mov bx, [tampalabraconcat]
    mov [tamcontra], bx

    xor si, si
    mov si, [siactuall]
    jmp comprobarusuariobusqueda

comprobarusuariobusqueda:
    mov [siactuall], si
    xor si, si
    xor di, di
    xor cx, cx   

    mov cx, [tamuser]
    mov si, usuariocompa
    mov di, usuario
    
    repe cmpsb 
    jne continuaringresobusqueda
    je nombrerepetido
    
    
continuaringresobusqueda:
    mov si, [siactuall]
    jmp iniciousariobusqueda

nombrerepetido:
    call limpiar
    mov dx, msjusuarioexiste
    call escribir
    mov ah, 08
    int 21h
    jmp menu


continuarregistrar:
        mov dx, msjcontrasena
        call escribir
        
        xor si, si
        mov si, contrasena 
        mov cx, 100
        regresa4: 
            mov ah,07h 
            int 21h 
            cmp al,13 
            je termina4 
            mov [si],al 
            inc si 
            mov dl,al 
            mov ah,02h ;- Para imprimir por pantalla un caracter 
            int 21h 
        loop regresa4

   
    termina4: 
        mov bx, 100
        sub bx, cx
        mov [numcon], bx 
        
        jmp verificarclave
        
verificarclave:
    mov dl, 0
    mov [numcar], dl
    xor si, si
    mov si, contrasena
    jmp compcalve
    

compcalve:
    lodsb
   
    cmp al, 48
    je repetircompclave
    cmp al, 49
    je repetircompclave
    cmp al, 50
    je repetircompclave
    cmp al, 51
    je repetircompclave
    cmp al, 52
    je repetircompclave
    cmp al, 53
    je repetircompclave
    cmp al, 54
    je repetircompclave
    cmp al, 55
    je repetircompclave
    cmp al, 56
    je repetircompclave
    cmp al, 57
    je repetircompclave
    jne caracternovalido

caracternovalido:
    mov [carac], al
    mov dx, msjcaracterinvalid
    call escribir
    mov ah, 02h
    mov dl, [carac]
    int 21h
    mov ah, 08
    int 21h
    jmp continuarregistrar


repetircompclave:
    mov dl, [numcar]
    inc dl
    mov [numcar], dl
    
    mov al, [numcar]
    mov bl, [numcon]
    cmp al, bl
    je clavebien
    jne compcalve

clavebien:
    mov bx, 0
    mov [connum], bx
    mov [numtodo], bx

    mov si, concatenartodo 
    mov di, [textoleido]  
    jmp cocattextoleido

cocattextoleido:
    mov cx, [connum]
    cmp cx, [numcarleido]
    jne continuacocattextoleido
    je concatusauario

continuacocattextoleido:
    mov dl, [di]
    mov [si + bx], dl
    inc bx
    inc di
    mov cx, [connum]
    add cx, 1
    mov [connum], cx
    jmp cocattextoleido

concatusauario:
    mov [numtodo], bx
    mov bx, 0
    mov [connum], bx
    
    mov si, concatenartodo 
    mov di, usuario  
    mov bx, [numtodo]
    jmp concatusuarionuevo

concatusuarionuevo:
    mov cx, [connum]
    cmp cx, [numus]
    jne continuaconcatusuarionuevo
    je concatenarcaluladorarep

continuaconcatusuarionuevo:
    mov dl, [di]
    mov [si + bx], dl
    inc bx
    inc di
    mov cx, [connum]
    add cx, 1
    mov [connum], cx
    jmp concatusuarionuevo

concatenarcaluladorarep:
    mov dl, 44
    mov [si + bx], dl
    inc bx
    mov [numtodo], bx
    mov bx, 0
    mov [connum], bx

    mov si, concatenartodo 
    mov di, contrasena  
    mov bx, [numtodo]
    jmp concatclavenueva

concatclavenueva:
    mov cx, [connum]
    cmp cx, [numcon]
    jne continuaconcatclavenueva
    je finconcatclave

continuaconcatclavenueva:
    mov dl, [di]
    mov [si + bx], dl
    inc bx
    inc di
    mov cx, [connum]
    add cx, 1
    mov [connum], cx
    jmp concatclavenueva

finconcatclave:
    mov dl, 59
    mov [si + bx], dl
    inc bx
    mov [numtodo], bx

    escribir_archivo rutaarchivo, numtodo,  concatenartodo
    mov ah, 08
    int 21h
    jmp menu

noarchivo:
    mov dx, msjnoarchivo
    call escribir
    mov ah, 08
    int 21h
    jmp menu

escribir:
    mov ah, 09h
    int 21h
    ret 

opcionno:
    call limpiar
    jmp menu

limpiar:
    mov ax,0600h ;limpiar pantalla
    mov bh,0fh ;0 color de fondo negro, f color de letra blanco
    mov cx,0000h
    mov dx,184Fh
    int 10h

    mov ah,02h
    mov bh,00
    mov dh,00
    mov dl,00
    int 10h
    ret 

noesadmin:
    call limpiar
    mov dx, menujuego
    call escribir
    mov ah, 01
    int 21h
    cmp al, 49 ; jugar
    je iniciojuego
    cmp al, 50 ; regresar menu
    je menu
    jne noesadmin

%macro ponercursor 2
    ;1 filas 2 columna
    xor ax, ax
    xor bx, bx
    xor cx, cx
    mov ah, 02h
    mov bh, 0
    mov dh, %1
    mov dl, %2
    int 10h
%endmacro

%macro ponercaracter 2
    ; 1 caracter 2 color
    xor ax, ax
    xor bx, bx
    xor cx, cx
    
    mov ah, 0Ah
    mov al, %1
    mov bh, 0
    mov bl, %2
    mov cx, 1
    int 10h
%endmacro

%macro poner_puntuacion 1 
    ponercursor 0,18
    mov al, %1
    AAM
    mov bx, ax
    add bh, 30h
    mov [digt], bh
    ponercaracter [digt], 15
    ponercursor 0,19
    mov al, %1
    AAM
    mov bx, ax
    add bl, 30h
    mov [digt], bl
    ponercaracter [digt], 15
%endmacro

%macro poner_tiempo 2
    xor ax, ax
    
    mov al, %1
    aam 
    add al, 30h
    mov [uni2], al 
    add ah, 30h
    mov [dece2], ah
    
    mov al, %2
    aam 
    add al, 30h
    mov [uni], al 
    add ah, 30h
    mov [dece], ah

    ponercursor 0, 30
    ponercaracter [dece2], 15
    ponercursor 0, 31
    ponercaracter [uni2], 15
    ponercursor 0, 32
    ponercaracter 58, 15

    ponercursor 0, 33
    ponercaracter [dece], 15
    ponercursor 0, 34
    ponercaracter [uni], 15

%endmacro

iniciojuego:
    call limpiar
    call pantallagrande
    call ponerusuariopantalla
    call ponernivelunos
    xor cx, cx
    mov cx, 0
    mov [puntuacion], cx
    poner_puntuacion [puntuacion]
    call ponermarco
    xor cx, cx
    mov cx, 4
    mov [tamanoserpiente], cx
    
    call poneriniciopos

    xor cl, cl
    mov cl, 0
    mov [numerocomida], cl
    call ponercomida
    xor bl, bl
    mov bl, 0
    mov [segundos], bl
    mov [tiempo], bl
    mov [tiempominutos], bl
    jmp juegoniveluno
    ;;;;;;;;; cambiar nivel ------------------------------------------------------------sdf
   


ponerusuariopantalla:
    xor si, si
    xor cx, cx
    mov si, usuariocompa
    mov cx, 0
    mov [numcar], cx
    mov [posicionx], cx
    call imprimeusu
    ret

imprimeusu:
    push si
    push dx
    push ax
    push bx
    push cx
    imprimeusu2:
    mov cx, [numcar]
    inc cx
    mov [numcar], cx
    mov al, [si]
    mov [digt], al
    inc si
    ponercursor 0, [posicionx]
    ponercaracter [digt], 15
    xor cx, cx
    mov cx, [posicionx]
    inc cx
    mov [posicionx], cx
    xor al, al
    xor bl, bl
    mov al, [numcar]
    mov bl, [tamuser]
    cmp al, bl
    jne imprimeusu2
    pop cx
    pop bx
    pop ax
    pop dx
    pop si
    ret

%macro poner_pixel 3
    ; 1. color, 2. columna, 3.fila
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx
    mov ah, 0Ch
    mov al, %1
    mov bh, 0
    mov cx, %2
    mov dx, %3
    int 10h
%endmacro


ponermarco:
    push si
    push dx
    push ax
    push bx
    push cx
    xor bx, bx
    mov bx, 2
    mov [numcar],bx
    ciclomarco: 
        poner_pixel 15, [numcar], 10
        poner_pixel 15, [numcar], 198
        mov bx, [numcar]
        inc bx
        mov [numcar], bx
        cmp bx, 318
        jne ciclomarco
    xor bx, bx
    mov bx, 10
    mov [numcar],bx
    cicloborde:
        poner_pixel 15, 2, [numcar]
        poner_pixel 15, 318, [numcar]
        mov bx, [numcar]
        inc bx
        mov [numcar], bx
        cmp bx, 199
        jne cicloborde
    pop cx
    pop bx
    pop ax
    pop dx
    pop si
    ret

ponernivelunos:
    push si
    push dx
    push ax
    push bx
    push cx
    ponercursor 0, 12
    ponercaracter 78, 15
    ponercursor 0, 13
    ponercaracter 49, 15
    pop cx
    pop bx
    pop ax
    pop dx
    pop si
    ret 

juegoniveluno:
    call leerteclado
    call chococonborede
    call serpietecomio
    call pasaraniveldos
    call actualizarcuerpo
    call serpietesecomio
    call pintarserpiente
    call hora
    call esperar
    jmp juegoniveluno


pintarserpiente:
    push si
    push dx
    push ax
    push bx
    push cx
    xor bx, bx
    mov bx, 0
    mov [inicioserpiente], bx
    pintarparte:
        xor si, si
        mov cl, [inicioserpiente]
        mov si, [inicioserpiente]
        mov bl, byte[posiciones+si]
        mov [posicionenx], bl
        inc cl
        mov [inicioserpiente], cl
        mov si, [inicioserpiente]
        mov bh, byte[posiciones+si]
       
        mov [posicioneny], bh
        ponercursor [posicioneny], [posicionenx]
        ponercaracter 79, 3

        mov cl, [inicioserpiente]
        inc cl
        mov [inicioserpiente], cl
        
        mov bx, [tamanoserpiente]
        mov cx, [inicioserpiente]
        cmp bx, cx
        jne pintarparte

        
        mov si, [inicioserpiente]
        mov bl, byte[posiciones+si]
        mov [posicionenx], bl
        inc cl
        mov [inicioserpiente], cl
        mov si, [inicioserpiente]
        mov bh, byte[posiciones+si]
       
        mov [posicioneny], bh
        ponercursor [posicioneny], [posicionenx]
        ponercaracter 79, 0
        pop cx
        pop bx
        pop ax
        pop dx
        pop si
        ret

leerteclado:
    push si
    push dx
    push ax
    push bx
    push cx
    mov ah, 01h
    int 16h

    jz movercabeza ;ninguna tecla se presiono

    mov ah, 0
    int 16h

    cmp al, 0
    jne movercabeza ; por si se presiono un ascii

    cmp ah, 48h
    je arriba

    cmp ah, 50h
    je abajo

    cmp ah, 4dh
    je derecha

    cmp ah, 4bh
    je izquierda
    jne movercabeza

arriba:
    mov bl, 1
    mov [direccion], bl
    jmp movercabeza

abajo:
    mov bl, 3
    mov [direccion], bl
    jmp movercabeza

derecha:
    mov bl, 0
    mov [direccion], bl
    jmp movercabeza

izquierda:
    mov bl, 2
    mov [direccion], bl
    jmp movercabeza

movercabeza:
    mov bl, [direccion]
    cmp bl, 0
    je moverderecha
    cmp bl, 1
    je moverarriba
    cmp bl, 2
    je moverizquierda
    cmp bl, 3
    je moverabajo
    jmp finteclado

moverderecha:
    mov cl, [cabezaenx]
    inc cl
    mov [cabezaenx], cl
    jmp finteclado

moverarriba:
    mov cl, [cabezaeny]
    sub cl, 1
    mov [cabezaeny], cl
    jmp finteclado

moverizquierda:
    mov cl, [cabezaenx]
    sub cl, 1
    mov [cabezaenx], cl
    jmp finteclado

moverabajo:
    mov cl, [cabezaeny]
    inc cl
    mov [cabezaeny], cl
    jmp finteclado

finteclado:
    pop cx
    pop bx
    pop ax
    pop dx
    pop si
    ret

pantallagrande:
    mov ah, 00h
    mov al, 13h
    int 10h
    ret

pantallpequena:
    mov ah, 00h
    mov al, 3h
    int 10h
    ret

pintarpixel:
    mov es, word[startaddr]
    mov ax, 14

    mov di, 32000
    add di, 160
    mov [es:di], ax
    ret

actualizarcuerpo:
    push si
    push dx
    push ax
    push bx
    push cx
    xor bx, bx
    mov bx, 25
    mov [numeroactualizar], bx
    actualizar:
        xor si, si
        
        mov cx, [numeroactualizar]
        sub cx, 2
        mov [numeactualizaranterior], cx

        mov si, [numeactualizaranterior]
        mov bl, byte[posiciones+si]
        mov si, [numeroactualizar]
        mov [posiciones+si], bl
        
        mov cx, [numeroactualizar]
        sub cx, 1
        mov [numeroactualizar], cx

        cmp cx, 1
        jne actualizar
    xor bx, bx
    mov bl, [cabezaenx]
    mov [posiciones], bl
    mov bh, [cabezaeny]
    mov [posiciones+1], bh
    pop cx
    pop bx
    pop ax
    pop dx
    pop si
    ret

chococonborede:
    push si
    push dx
    push ax
    push bx
    push cx
    xor cl, cl
    mov cl, [cabezaenx]
    cmp cl, 0
    je finjuego
    cmp cl, 39
    je finjuego
    xor cl, cl
    mov cl, [cabezaeny]
    cmp cl, 1
    je finjuego
    cmp cl, 24
    je finjuego
    pop cx
    pop bx
    pop ax
    pop dx
    pop si
    ret

finjuego:
    pop cx
    pop bx
    pop ax
    pop dx
    pop si
    call limpiar
    call pantallpequena
    push si
    push dx
    push ax
    push bx
    push cx

    xor dx, dx
    mov dx, perdio
    call escribir
    mov ah, 08
    int 21h
    pop cx
    pop bx
    pop ax
    pop dx
    pop si

    jmp noesadmin



ponercomida:
    push si
    push dx
    push ax
    push bx
    push cx
    xor cx, cx
    xor si, si
    xor bl, bl
    mov si, [numerocomida]
    mov bl, [comidaposiscion+si]
    mov [comidax], bl
    mov cl, [numerocomida]
    inc cl
    mov [numerocomida], cl
    xor si, si
    xor bl, bl
    mov si, [numerocomida]
    mov bl, [comidaposiscion+si]
    mov [comiday], bl
    mov cl, [numerocomida]
    inc cl
    mov [numerocomida], cl
    ponercursor [comiday], [comidax]
    ponercaracter 254, 6
    pop cx
    pop bx
    pop ax
    pop dx
    pop si
    ret

serpietecomio:
    push si
    push dx
    push ax
    push bx
    push cx
    xor bx, bx
    mov bl, [cabezaenx]
    mov bh, [comidax]
    cmp bh, bl
    jne fincomio 
    xor bx, bx
    mov bl, [cabezaeny]
    mov bh, [comiday]
    cmp bh, bl
    jne fincomio 
    xor cl, cl
    mov cl, [puntuacion]
    inc cl
    mov [puntuacion], cl
    poner_puntuacion [puntuacion]
    call ponercomida
    xor cx, cx
    mov cx, [tamanoserpiente]
    add cx, 2
    mov [tamanoserpiente], cx
fincomio:
    pop cx
    pop bx
    pop ax
    pop dx
    pop si
    ret

poneriniciopos:
    push si
    push dx
    push ax
    push bx
    push cx
    mov bx, [cabezaenxinicio]
    mov [cabezaenx], bx
    mov bx, [cabezaenyinicio]
    mov [cabezaenxinicio], bx
    xor bx, bx
    mov bh, [posiciones1x]
    mov [posiciones], bh
    xor bx, bx
    mov bh, [posiciones1y]
    mov [posiciones+1], bh
    xor bx, bx
    mov bh, [posiciones2x]
    mov [posiciones+2], bh
    xor bx, bx
    mov bh, [posiciones2y]
    mov [posiciones+3], bh
    xor bx, bx
    mov bh, [posiciones3x]
    mov [posiciones+4], bh
    xor bx, bx
    mov bh, [posiciones3y]
    mov [posiciones+5], bh
    xor bl, bl
    mov bl, 0
    mov [direccion], bl
    pop cx
    pop bx
    pop ax
    pop dx
    pop si
    ret

serpietesecomio:
    push si
    push dx
    push ax
    push bx
    push cx
    xor bx, bx
    mov bx, 2
    mov [numerocomparar], bx
    iniciocomio:
        xor si, si
        xor bx, bx
        xor cl, cl
        mov si, [numerocomparar]
        mov bl, byte[posiciones+si]
        mov cl, [numerocomparar]
        inc cl
        mov [numerocomparar], cl
        xor cl, cl
        mov cl, [cabezaenx]
        cmp bl, cl
        jne repetiriniciocomio
        
        xor si, si
        xor bx, bx
        mov si, [numerocomparar]
        mov bl, byte[posiciones+si]
        mov cl, [numerocomparar]
        inc cl
        mov [numerocomparar], cl
        xor cl, cl
        mov cl, [cabezaeny]
        cmp bl, cl
        jne repetircomio
        je finjuego
    repetiriniciocomio:
        mov cl, [numerocomparar]
        inc cl
        mov [numerocomparar], cl
    repetircomio:
        mov cl, [numerocomparar]
        mov bl, [tamanoserpiente]
        cmp cl, bl
        jne iniciocomio
        pop cx
        pop bx
        pop ax
        pop dx
        pop si
        ret

pasaraniveldos: 
    push si
    push dx
    push ax
    push bx
    push cx

    mov bx, [puntuacion]
    cmp bx, 4
    je camiaraniveldos


    pop cx
    pop bx
    pop ax
    pop dx
    pop si
    ret

camiaraniveldos:
    pop cx
    pop bx
    pop ax
    pop dx
    pop si

    push si
    push dx
    push ax
    push bx
    push cx
    call limpiar
    call pantallpequena
    call limpiar
    call pantallagrande
    call ponerusuariopantalla
    call ponermarco
    call ponerniveldos
    call poneriniciopos
    call ponerobstaculosniveldos
    xor bx, bx
    mov bx, 4
    mov [tamanoserpiente], bx
    xor cl, cl
    mov cl, 0
    mov [numerocomida], cl
    call ponercomida
    xor cl, cl
    mov cl, [puntuacion]
    inc cl
    mov [puntuacion], cl
    poner_puntuacion [puntuacion]
    pop cx
    pop bx
    pop ax
    pop dx
    pop si
    jmp niveldos


ponerniveldos:
    push si
    push dx
    push ax
    push bx
    push cx
    ponercursor 0, 12
    ponercaracter 78, 15
    ponercursor 0, 13
    ponercaracter 50, 15
    pop cx
    pop bx
    pop ax
    pop dx
    pop si
    ret 

ponerobstaculosniveldos:
    push si
    push dx
    push ax
    push bx
    push cx
    xor bx, bx
    mov bx, 10
    mov [numcar],bx
    cicloobstaculoniveldos: 
        ponercursor 6, [numcar]
        ponercaracter 196, 15
        ponercursor 19, [numcar]
        ponercaracter 196, 15
        mov bx, [numcar]
        inc bx
        mov [numcar], bx
        cmp bx, 28
        jne cicloobstaculoniveldos
    pop cx
    pop bx
    pop ax
    pop dx
    pop si
    ret

niveldos:
    call leerteclado
    call chococonborede
    call choqueniveldos
    call serpietecomio
    call pasaraniveltres
    call actualizarcuerpo
    call serpietesecomio
    call pintarserpiente
    call hora
    call esperar2
    jmp niveldos



choqueniveldos:
    push si
    push dx
    push ax
    push bx
    push cx

    xor bl, bl
    mov bl, [cabezaeny]
    cmp bl, 6
    je choqueniveldosenex
    cmp bl, 19
    je choqueniveldosenex
    jne fincoqueniveldos

choqueniveldosenex:
    xor cl, cl
    mov cl, 10
    xor bl, bl
    mov bl, [cabezaenx]
    comparacionniveldoschoque:
        cmp cl, bl
        je finjuego
        inc cl
        cmp cl, 28
        jne comparacionniveldoschoque
        je fincoqueniveldos

fincoqueniveldos:
    pop cx
    pop bx
    pop ax
    pop dx
    pop si
    ret

pasaraniveltres: 
    push si
    push dx
    push ax
    push bx
    push cx

    mov bx, [puntuacion]
    cmp bx, 9
    je camiaraniveltres


    pop cx
    pop bx
    pop ax
    pop dx
    pop si
    ret


camiaraniveltres:
    pop cx
    pop bx
    pop ax
    pop dx
    pop si

    push si
    push dx
    push ax
    push bx
    push cx
    call limpiar
    call pantallpequena
    call limpiar
    call pantallagrande
    call ponerusuariopantalla
    call ponermarco
    call ponerniveltres
    call poneriniciopos
    call ponerobstaculosniveldos
    call ponerobstaculosniveltres

    xor bx, bx
    mov bx, 4
    mov [tamanoserpiente], bx
    xor cl, cl
    mov cl, 0
    mov [numerocomida], cl
    call ponercomida
    xor cl, cl
    mov cl, [puntuacion]
    inc cl
    mov [puntuacion], cl
    poner_puntuacion [puntuacion]
    pop cx
    pop bx
    pop ax
    pop dx
    pop si
    jmp niveltres

niveltres:
    call leerteclado
    call chococonborede
    call choqueniveldos
    call choqueniveltres
    call serpietecomio
    call actualizarcuerpo
    call serpietesecomio
    call pintarserpiente
    call ganoniveltres
    call hora
    call esperar3
    jmp niveltres


ponerniveltres: 
    push si
    push dx
    push ax
    push bx
    push cx
    ponercursor 0, 12
    ponercaracter 78, 15
    ponercursor 0, 13
    ponercaracter 51, 15
    pop cx
    pop bx
    pop ax
    pop dx
    pop si
    ret 

ponerobstaculosniveltres:
    push si
    push dx
    push ax
    push bx
    push cx

    xor bx, bx
    mov bx, 10
    mov [numcar],bx
    cicloobstaculoniveltres: 
        ponercursor [numcar], 5 
        ponercaracter 179, 15
        ponercursor [numcar], 32 
        ponercaracter 179, 15
        mov bx, [numcar]
        inc bx
        mov [numcar], bx
        cmp bx, 17
        jne cicloobstaculoniveltres
    pop cx
    pop bx
    pop ax
    pop dx
    pop si
    ret

esperar:
    push si
    push dx
    push ax
    push bx
    push cx
    xor ax, ax
    mov ah, 86h
    mov cx, 10
    mov dx, 001fh
    int 15h
    pop cx
    pop bx
    pop ax
    pop dx
    pop si
    ret

esperar2:
    push si
    push dx
    push ax
    push bx
    push cx
    xor ax, ax
    mov ah, 86h
    mov cx, 05
    mov dx, 001FH
    int 15h
    pop cx
    pop bx
    pop ax
    pop dx
    pop si
    ret

esperar3:
    push si
    push dx
    push ax
    push bx
    push cx
    xor ax, ax
    mov ah, 86h
    mov cx, 02
    mov dx, 001FH
    int 15h
    pop cx
    pop bx
    pop ax
    pop dx
    pop si
    ret

choqueniveltres:
    push si
    push dx
    push ax
    push bx
    push cx

    xor bl, bl
    mov bl, [cabezaenx]
    cmp bl, 5
    je choqueniveltresenex
    cmp bl, 32
    je choqueniveltresenex
    jne fincoqueniveltres

choqueniveltresenex:
    xor cl, cl
    mov cl, 10
    xor bl, bl
    mov bl, [cabezaeny]
    comparacionniveltreschoque:
        cmp cl, bl
        je finjuego
        inc cl
        cmp cl, 17
        jne comparacionniveltreschoque
        je fincoqueniveltres

fincoqueniveltres:
    pop cx
    pop bx
    pop ax
    pop dx
    pop si
    ret


ganoniveltres: 
    push si
    push dx
    push ax
    push bx
    push cx

    mov bx, [puntuacion]
    cmp bx, 14
    je gano


    pop cx
    pop bx
    pop ax
    pop dx
    pop si
    ret

gano:
    pop cx
    pop bx
    pop ax
    pop dx
    pop si

    push si
    push dx
    push ax
    push bx
    push cx
    call limpiar
    call pantallpequena
    call limpiar
    xor cl, cl
    mov cl, [puntuacion]
    inc cl
    mov [puntuacion], cl
    pop cx
    pop bx
    pop ax
    pop dx
    pop si
    jmp terminoganando

terminoganando:
    pop cx
    pop bx
    pop ax
    pop dx
    pop si
    push si
    push dx
    push ax
    push bx
    push cx
    call limpiar
    call pantallpequena
    

    xor dx, dx
    mov dx, ganonivel
    call escribir

    mov ah, 08
    int 21h
    pop cx
    pop bx
    pop ax
    pop dx
    pop si

    jmp noesadmin


hora:
    push si
    push dx
    push ax
    push bx
    push cx
    xor ax, ax
    mov ah, 2ch
    int 21h
    xor bl, bl
    mov bl, [segundos]
    cmp dh, bl
    je finhora

    mov [segundos], dh
    xor cl, cl
    mov cl, [tiempo]
    inc cl
    mov [tiempo], cl
    xor bl, bl
    mov bl, 60
    cmp cl, bl
    je cambiarminutos
    jne finhora
cambiarminutos:
    mov cl, [tiempominutos]
    inc cl
    mov [tiempominutos], cl
    xor cl, cl
    mov cl, 0
    mov [tiempo], cl
finhora:
    poner_tiempo [tiempominutos], [tiempo]
    pop cx
    pop bx
    pop ax
    pop dx
    pop si
    ret

salir:
    mov ah, 4Ch
    int 21h

section .data

menuinicio:             db '|-------------Menu-------------|',13,10
                        db '|1. Ingresar                   |',13,10
                        db '|2. Registrar                  |',13,10
                        db '|3. Salir                      |',13,10
                        db '|------------------------------|',13,10
                        db 'Ingrese una opcion: $',13,10

msjiniioentrar:         db 13,10,'Usuario: $',13,10
msjcontrasena:          db 13,10,'Clave: $',13,10

usuario:                times 100 db '',13,10,'$'
contrasena:             times 100 db '',13,10,'$'

usuariocompa:           times 100 db '',13,10,'$'
contrasenacompa:        times 100 db '',13,10,'$'

textoleido:             times 500 db "$"
rutaarchivo:            dw "usuarios.txt",0

palabraconcat:          times 100 db '',13,10,'$'

siactuall:              dw ''

msjnoarchivo:           db 'Error en la lectura del archivo',13,10,'$'

msjentrousu:            db 13,10,'entro usu $',13,10
msjentrocontra:         db 13,10,'entro contra $',13,10

nombreprueba:           dw "reporte.rep",0

connum:                 db 0

dmin:                   db 'admin$',13,10
palabradmin:            times 100 db '',13,10,'$'

menujuego:              db '|------------Juego ------------|',13,10
                        db '|1. Jugar                      |',13,10
                        db '|2. Regresar                   |',13,10
                        db '|------------------------------|',13,10
                        db 'Ingrese una opcion: $',13,10

menuadmin:              db '|------------Admin ------------|',13,10
                        db '|1. Top 10 puntos              |',13,10
                        db '|2. Top 10 tiempo              |',13,10
                        db '|2. Regresar                   |',13,10
                        db '|------------------------------|',13,10
                        db 'Ingrese una opcion: $',13,10

msjusuarioexiste:       db 'El usuario ya existe',13,10,'$'
msjcaracterinvalid:     db 13,10,'Caracter invalido: $',13,10

concatenartodo:         times 1000 db '',13,10,'$'

perdio:                 db 'Perdio',13,10,'$'

ganonivel:              db 'Gano',13,10,'$'

startaddr:              dw 0A000h

direccion:              db 0

posiciones:             db 4
                        db 3
                        ;0
                        db 3
                        db 3
                        ;1
                        db 2
                        db 3
                        ;2
                        db 4
                        db 3
                        ;3
                        db 3
                        db 2
                        ;4
                        db 4
                        db 3
                        ;5
                        db 4
                        db 3
                        ;6
                        db 4
                        db 3
                        ;7
                        db 4
                        db 3
                        ;8
                        db 4
                        db 3
                        ;9
                        db 4
                        db 3
                        ;10
                        db 4
                        db 3
                        ;11
                        db 4
                        db 3
                        ;12
                        db 4
                        db 3
                        ;13

cabezaenx:              db 5
cabezaeny:              db 3

cabezaenxinicio:        db 5
cabezaenyinicio:        db 3

posiciones1x:           db 4
posiciones1y:           db 3
                        
posiciones2x:           db 3
posiciones2y:           db 3

posiciones3x:           db 2
posiciones3y:           db 3

comidax:                db 12
comiday:                db 15

comidaposiscion:        db 12
                        db 15
                        ;0
                        db 35
                        db 5
                        ;1
                        db 4
                        db 9
                        ;2
                        db 33
                        db 23
                        ;3
                        db 22
                        db 11
                        ;4
                        db 5
                        db 22
                        ;5
                        db 37
                        db 17
                        ;6
                        db 20
                        db 3
                        ;7
                        db 26
                        db 17
                        ;8
                        db 2
                        db 13
                        ;9
                        db 15
                        db 10


numerocomparar:         db 0



dece:                   db 0
uni:                    db 0

dece2:                  db 0
uni2:                   db 0

section .bss
numcarleido:            resb 10
tamuser:                resb 5
tamcontra:              resb 5
tampalabraconcat:       resb 5
numcar:                 resb 10

numus:                  resb 10
numcon:                 resb 10
numtodo:                resb 10
carac:                  resd 1
posicionx:              resb 10
digt:                   resd 1

posicionenx:            resb 8
posicioneny:            resb 8


tamanoserpiente:        resb 10
inicioserpiente:        resb 10
numeroactualizar:       resb 10
numeactualizaranterior: resb 10

puntuacion:             resb 5
numerocomida:           resb 3

segundos:               resb 5
tiempo:                 resb 5
tiempominutos:          resb 5
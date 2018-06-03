org 100h
jmp start
s: db'SCORE:'
msg:db'welcome to snake game press any key to start the game',0
boundry:db'-'
score : dw 0
snake :db '*'
snakelen: dw 3
boundpos: times 210 dw 0
fruit_pos: dw 360,212,440,2556,3120,2888,442,388,1052,2552,932,224,560,946,562,888,168,3566,366,880,220,560,1260,1400,1480,220,180,1008,3120,1952,2160,2224 ;fruit position varies from start to end and end to start
fruit_count: dw 0 
snake_pos: dw 860,862,864,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;maximum length of snake is 50
tempsnake_pos: dw 860,862,864,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
last_snake_state:  times 50 dw 0
oldisr: dw 0
up: dw 1  ;states in which snake can go 
down: dw 1 ;at initial stage snake can go up ,down and forward 
forw: dw 1
rev: dw 0
uflag: dw 0 ;upflag
dflag: dw 0 ;down flag
fflag: dw 0 ; forward flag
rflag: dw 0 ;reverse flag
exflag: dw 0
fruit: db '#'
delay: dw 40000
over: db ' GAME OVER TATA BYE BYE'

kbisr:
cli
in al,0x60
cmp al,01
jnz firstcmp
mov word[fflag],0
mov word[uflag],0
mov word[rflag],0
mov word[dflag],0
mov word[exflag],1
jmp kbexit
firstcmp:
cmp al,0x4b
jnz nextcmp
cmp word[forw],1
jnz end1
mov word[fflag],1
mov word[uflag],0
mov word[rflag],0
mov word[dflag],0
mov word[up],1
mov word[down],1
mov word [forw],1
mov word [rev],0
end1: ;intermediate jump so that jump don't get out of range
jmp kbexit
nextcmp:
cmp al,0x48
jnz nextcmp1
cmp word[up],1
jnz end2
mov word[fflag],0
mov word[uflag],1
mov word[rflag],0
mov word[dflag],0

mov word[up],1
mov word[down],0
mov word [forw],1
mov word [rev],1
end2:			;intermediate jump so that jump don't get out of range
jmp kbexit

nextcmp1:
cmp al,0x50
jnz nextcmp2
cmp word[down],1
jnz end2
mov word[fflag],0
mov word[uflag],0
mov word[rflag],0
mov word[dflag],1

mov word[up],0
mov word[down],1
mov word [forw],1
mov word [rev],1

nextcmp2:
cmp al,4dh
jnz kbexit
cmp word[rev],1
jnz kbexit
mov word[fflag],0
mov word[uflag],0
mov word[rflag],1
mov word[dflag],0

mov word[up],1
mov word[down],1
mov word [forw],0
mov word [rev],1

kbexit:
sti
mov al, 0x20
out 0x20, al ; send EOI to PIC
iret

printnum:
push bp
mov bp,sp
push es
push ax
push bx
push cx
push dx
push di

mov ax,0xb800

mov es,ax

mov bx,10

mov cx,0

mov ax,[bp+4]

nextdigit:
mov dx,0

div bx

add dl,0x30

push dx

inc cx

cmp ax ,0
jnz nextdigit
mov di,3660

nextpos:

pop dx

mov dh,0x07
mov [es:di],dx
add di,2
loop nextpos
pop di
pop dx
pop cx
pop bx
pop ax
pop es 
pop bp
ret 2

clrscr:
push es
push ax
push di

mov ax,0xb800
mov es,ax
mov di,0
next:
mov word[es:di],0x1020
add di,2
cmp di,4000
jne next

pop di
pop ax 
pop es 
ret
printstr:
push bp
mov bp,sp
push es
push ax
push cx
push si
push di

mov ax,0xb800
mov es,ax
mov di,[bp+4]
mov si,[bp+8]
mov cx,[bp+6]
mov ah,0x07

nextchar:
mov al,[si]
mov [es:di],ax
add si,1
add di,2
loop nextchar
pop di
pop si
pop cx 
pop ax
pop es
pop bp
ret 6

printblink:
push bp
mov bp,sp
push es
push ax
push cx
push si
push di

mov ax,0xb800
mov es,ax
mov di,[bp+4] ;position
mov si,[bp+8] ;offset
mov cx,[bp+6] ;length
mov ah,0x87

nextch:
mov al,[si]
mov [es:di],ax
add si,1
add di,2
loop nextch
pop di
pop si
pop cx 
pop ax
pop es
pop bp
ret 6


start: 
call clrscr
push msg
push 53
push 340
call printblink
mov ah,0
int 16h
call clrscr
xor si,si
xor ax,ax
mov es,ax
mov ax,[es:0x9*4]
mov [oldisr],ax
mov ax,[es:0x9*4+2]
mov [oldisr+2],ax
cli        
mov word[es:0x9*4],kbisr
mov word[es:0x9*4+2],cs
sti
gamestart:
call clrscr
mov si,0
mov cx,80
mov bx,0
printupbound:
mov [boundpos+si],bx
push boundry
push 1
push bx
call printstr
add bx,2
add si,2
loop printupbound
mov cx,80
mov bx,3840
add si,2
printlowbound:
mov [boundpos+si],bx
push boundry
push 1
push bx
call printstr
add bx,2
add si,2
loop printlowbound
mov bx,0
mov cx,25
add si,2
printleftbound:
mov [boundpos+si],bx
push boundry
push 1
push bx
call printstr
add bx,160
add si,2
loop printleftbound
mov bx,158
mov cx,25
printrightbound:
mov [boundpos+si],bx
push boundry
push 1
push bx
call printstr
add bx,160
add si,2
loop printrightbound
xor bx,bx
xor ax,ax
mov bx,2
mov cx,[snakelen]
sub cx,1
dead:
mov ax,[snake_pos]
cmp ax,[snake_pos+bx]
jnz l1
jmp exit
l1:
add bx,2
loop dead
mov ax,[snake_pos]
mov bx,[fruit_count]
mov dx,[fruit_pos+bx]
cmp ax,dx ;checks whether snake has eaten fruit or not
jnz further
add word[fruit_count],2
add word[score],20
sub word[delay],2000
add word[snakelen],1
cmp word[fruit_count],64
jnz further
mov word[fruit_count],0
further:
push s
push 6
push 3640
call printstr
mov ax,[score]
push ax 
call printnum
cmp word[exflag],1
jnz l2
jmp exit
l2:
push fruit
push 1
mov bx,[fruit_count]
mov ax,[fruit_pos+bx]
push ax
call printstr





mov cx,[snakelen]
mov bx,0
printsnake:
push snake
push 1
mov ax,[snake_pos+bx]
mov [last_snake_state+bx],ax
push ax

call printstr
add bx,2
loop printsnake

cmp word[fflag],1
jnz upcmp

;forward code
mov bx,0
mov si,2
mov cx,[snakelen]
forloop:
mov ax,[cs:snake_pos+bx]
mov [cs:tempsnake_pos+si],ax

add bx,2
add si,2
loop forloop
sub word[cs:tempsnake_pos],2
jmp array


upcmp:
cmp word[uflag],1
jnz downcmp

;up code
mov bx,0
mov si,2
mov cx,[snakelen]
uploop:
mov ax,[cs:snake_pos+bx]
mov [cs:tempsnake_pos+si],ax

add bx,2
add si,2
loop uploop
sub word[cs:tempsnake_pos],160
jmp array

downcmp:
cmp word[dflag],1
jnz revcmp

;down code
mov bx,0
mov si,2
mov cx,[snakelen]
downloop:
mov ax,[cs:snake_pos+bx]
mov [cs:tempsnake_pos+si],ax

add bx,2
add si,2
loop downloop
add word[cs:tempsnake_pos],160
jmp array

revcmp:

cmp word[rflag],1
jnz array
;reverse code
mov bx,0
mov si,2
mov cx,[snakelen]
revloop:
mov ax,[cs:snake_pos+bx]
mov [cs:tempsnake_pos+si],ax

add bx,2
add si,2
loop revloop
add word[cs:tempsnake_pos],2


;mov ax,[snake_pos]
;mov cx,210
;mov bx,0
;boundcmp:
;cmp ax,[boundcmp+bx]
;jz pausestate
;add bx,2
;loop boundcmp

array:
mov bx,0
mov si,0
mov cx,[snakelen]
arraycopy:
mov ax,[cs:tempsnake_pos+bx]
mov [cs:snake_pos+si],ax
add bx,2
add si,2
loop arraycopy
mov cx,[delay]
delayloop1:
push ax
pop ax

loop delayloop1
mov cx,[delay]
delayloop2:
push ax
pop ax
loop delayloop2


jmp gamestart

pausestate:
push cx
push bx
mov cx,[snakelen]
mov bx,0
printpause:
push snake
push 1
mov ax,[last_snake_state+bx]
push ax
call printstr
add bx,2
loop printpause
pop bx
pop cx
mov ah,0
int 16h
ret



exit:

push over
push 23
push 1362
call printblink
mov ax,0
mov es,ax
cli
mov ax,[oldisr]
mov [es:0x9*4],ax
mov ax,[oldisr+2]
mov [es:0x9*4+2],ax
sti

mov ah,4ch
int 21h
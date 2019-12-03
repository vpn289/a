
; graphics of pi-hex assuming on hex digits
; order of he digits
; 0 1 2 4 8 3 5 9 A C 7 B D E F

screen_w =10;1528
Bytes_per_pixel = 1
row = screen_w*Bytes_per_pixel
hdeight =10
max_col_h=45

format PE64 GUI

entry start
  section '.idata' import data readable writeable

  include  'dllinclude.inc'

  section '.text' code readable executable  writeable
  start:
        call opennmappihex
;rax - address of pi_hex
        include 'preparegrapfh.inc'
;------------------------------
;convert bitmap to gif blocks
;8-bit pixsels to 9-bit gif chanks

            call     enumfile
            call     draw_graph
           ; call     eighttonine
            call       lzwp

;----------------------------
;here save the  gif

         mov     rcx,[handle_bmp]
       sub     rsp,40h
         mov     rdx,gif_file_header
         mov     r8,54+768   +hdeight*row+4
         mov     r9,byteswritten
         mov     qword [rsp+20h],0
         call    [WriteFile]
       add     rsp,40h

          xor     rcx,rcx
          call    [ExitProcess]

          include       'opnepihex.inc'
          include       'enumfilenm.inc'
;          include       '9-8pack.inc'
          include       'drawgraph.inc'

;---------------
;LZW pack
;универсальный заполнитель
; строим таблицу ссылок ена первые 256 кодов

lzwp:

        xor      rcx,rcx
        mov     rax,lzw_vocab

filler:
        mov     [rcx*8+lzw_table],rax
        inc     rax
        inc     rcx
        cmp     rcx,255
        jne     filler


lzwpack:
      ;  int3
        nop
        nop
        nop
        mov     rsi,pixels
        mov     r8,pixels ;end of source string
        mov     rbx,lzw_vocab
        mov     rdi,compressed_picture
        mov     rdx,lzw_table
        mov     r11,lzw_code
        xor     r10,r10
        xor     rax,rax
        mov     r12,1 ; длина искомой строки-1 (тоесть 2)

        mov     r13,r12

        mov     r14,lzw_table+256*8+2*8 ;
        ;переносим первый символ на выход
        movzx       ax,byte [rsi]
        mov        [r11],ax

        ;сравнение строк делаем через cmpsb
        ;rsi строка источник
        ;rdi строка в словаре
        ;rcx длина строки
        mov  rcx,2
        mov  rsi,pixels
        ;rdi надо брать из lzw_table
        ;по хорошему пробегать словарь надо от конца к началу, тогда проверка на динамический конец становится проверкой на 0.
        ;поиск двух и более значных строк заканчивается на коде 101
        mov    rdi,[r14]
        test   rdi,rdi
        jne     lzwp4
        ;пустое значение кончилась таблица
lzwp4:
        ;нужно внести строку в таблицу и записать ссылку на строку в таблицу


        rep    cmpsb
        jrcxz   lzwp3


lzwp3:
        mov     al,[rsi+r13]      ;читаем сивмол, если это конец - плюем, иаче ищем строку из предыущего и текущего символа в словаре.
        ;cтрока простирается от rsi до pixels максимум, ... нене. максимальная длина искомой строки фиксируется счетчиком. сначала она 2

lzwp2:
        mov     r9,[lzw_table+r10*8] ; get start of 1-st string
        cmp     al,[r9+r13]
        je      lzwp1
        ;get next entry in lzw table
        inc     r10
        jmp     lzwp2

lzwp1:
        ;нашли символ поищем следующий
        dec    r13
        mov    al,[rsi+r13]
        cmp    al,[r9+r13]
        jne    lzwp3 ;не совпал символ, надо искать дальше
        test   r13,r13 ;а тут прошли всю строку, значит нашли ее
        jne    lzwp1  ;не до конца прошли строку

       ;туточки нашли строку, выплюнем код
       ;save to lzw_code
       mov   rax,r9
       sub   rax,lzw_vocab
       mov   [r11],ax
       inc   r11
       inc   r11
       ret



;-----------------
;normalize the heighs

;----------EXIT----------
         xor      rcx,rcx
         call  [ExitProcess]
;-------------------------------



convert_i       dq      0
handle          dq      0


byteswritten    dq      0
bytesreaded     dq      0





heighst:
        dq      0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0
accumul:
        dq      0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0;40*row,27*row,32*row,-8*row,16*row,38*row,-17*row,22*row,10*row,39*row,3*row,-11*row,9*row,-32*row,4*row,15*row,1*row



pixels:
        db 7,7,7,7,7,7,7,7,7,7
        db 7,7,7,7,7,7,7,7,7,7
        db 7,7,7,7,7,7,7,7,7,7
        db 7,7,7,7,7,7,7,7,7,7
        db 7,7,7,7,7,7,7,7,7,7
        db 7,7,7,7,7,7,7,7,7,7
        db 7,7,7,7,7,7,7,7,7,7
        db 7,7,7,7,7,7,7,7,7,7
        db 7,7,7,7,7,7,7,7,7,7
        db 7,7,7,7,7,7,7,7,7,7
    ; db hdeight*screen_w*Bytes_per_pixel+4    dup(7h)
   ;  dw  100h, 7,102h, 103h , 104h;,  105h,106h,  107h, 108h,109h, 10ah, 10bh, 10ch,10dh,10eh;,10fh;,110h;,111h;,112h;10ch,10dh,10eh,10fh, 8,  8,8,8,8, 110h, 0, 101h,0   ; 7,  7, 7 ,7,7,7,7
     ;dw  ,7,7,7,7,7, 7,7,7,7,7,7,7,7,7,7,102h, 103h , 104h,  105h,106h
    ;  dw  7,102h, 103h , 8,106h,7
     ; dw  7,102h, 103h , 8,107h
     ; dw   8
     ; dw  7,102h, 103h , 8
     ; dw  7,102h, 103h , 8
     ; dw  7,102h, 103h , 8
     ; dw  7,102h, 103h , 8
     ; dw  7,102h, 103h , 104h
   ;  dw  100h, 7,102h, 103h , 104h,  105h,106h
     ;dw  101h                                         ;28+8=36
     dw  0ffffh
     db 256 dup(0)

lzw_table:
        dq      2048 dup(0)


lzw_vocab:
        db      00h,01h,02h,03h,04h,05h,06h,07h,08h,09h,0ah,0bh,0ch,0dh,0eh,0fh
        db      10h,11h,12h,13h,14h,15h,16h,17h,18h,19h,1ah,1bh,1ch,1dh,1eh,1fh
        db      20h,21h,22h,23h,24h,25h,26h,27h,28h,29h,2ah,2bh,2ch,2dh,2eh,2fh
        db      30h,31h,32h,33h,34h,35h,36h,37h,38h,39h,3ah,3bh,3ch,3dh,3eh,3fh
        db      40h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4ah,4bh,4ch,4dh,4eh,4fh
        db      50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5ah,5bh,5ch,5dh,5eh,5fh
        db      60h,61h,62h,63h,64h,65h,66h,67h,68h,69h,6ah,6bh,6ch,6dh,6eh,6fh
        db      70h,71h,72h,73h,74h,75h,76h,77h,78h,79h,7ah,7bh,7ch,7dh,7eh,7fh
        db      80h,81h,82h,83h,84h,85h,86h,87h,88h,89h,8ah,8bh,8ch,8dh,8eh,8fh
        db      90h,91h,92h,93h,94h,95h,96h,97h,98h,99h,9ah,9bh,9ch,9dh,9eh,9fh

        db      0a0h,0a1h,0a2h,0a3h,0a4h,0a5h,0a6h,0a7h,0a8h,0a9h,0aah,0abh,0ach,0adh,0aeh,0afh
        db      0b0h,0b1h,0b2h,0b3h,0b4h,0b5h,0b6h,0b7h,0b8h,0b9h,0bah,0bbh,0bch,0bdh,0beh,0bfh
        db      0c0h,0c1h,0c2h,0c3h,0c4h,0c5h,0c6h,0c7h,0c8h,0c9h,0cah,0cbh,0cch,0cdh,0ceh,0cfh
        db      0d0h,0d1h,0d2h,0d3h,0d4h,0d5h,0d6h,0d7h,0d8h,0d9h,0dah,0dbh,0dch,0ddh,0deh,0dfh
        db      0e0h,0e1h,0e2h,0e3h,0e4h,0e5h,0e6h,0e7h,0e8h,0e9h,0eah,0ebh,0ech,0edh,0eeh,0efh
        db      0f0h,0f1h,0f2h,0f3h,0f4h,0f5h,0f6h,0f7h,0f8h,0f9h,0fah,0fbh,0fch,0fdh,0feh,0ffh
        dq   8192 dup   (0)
lzw_code:
        db      4096 dup(0)
gif_file_header:
         db      'GIF89a'
width   dw     screen_w
height  dw     hdeight
        db      0f7h; 24bpp 4 colors 12 bytes pallete ; 0f7h ;global color table absent 24 bpp
        db      2 ;color number of background
        db      0 ;соотношение сторон
        ;pallete
        include 'gifpallet.inc'

         db      ','
         dw      0 ;полоджение картинки на лог экране
         dw      0
widthl   dw     screen_w
heightl  dw     hdeight
         db      0 ;локальная платира отсутствует
         db      08 ;размерность кода

copmrbytes         db      7 ;screen_w*hdeight+0 ;0feh ;количество байт кода

        ; db      00
compressed_picture:
;pixels:
        db      256 dup(0)

         db       0,3Bh
endofgif:

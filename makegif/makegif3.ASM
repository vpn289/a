;������ �� �������� �� ���������

screen_w =10;1528
Bytes_per_pixel = 1
row = screen_w*Bytes_per_pixel
hdeight =1
max_col_h=45

format PE64 GUI

entry start
  section '.idata' import data readable writeable

  include  'dllinclude.inc'

  section '.text' code readable executable  writeable
  start:

  ;����������� �������� � �����
                lea     rsi,[ pixels]
                mov     cl,3




          call     enumfile
          call     lzwp
;------------------------------
;input non_compressed 9-bit wotd
;output compressed_picture
;pack 9-bit into 8 bit putput stream


           call eighttonine


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

  stringtocount:
                push    rcx
                mov     ch,cl
                shl     cl,3
                xor     rax,rax
                inc     rax
                shl     rax,cl
                dec     rax

 ;� ������ ������ ������ � ������� � ��������� �������
                and      rax,[rsi]
                shl      rax,8
                mov      al,ch
                pop      rcx
                ret

         include  '9-8pack.inc'
         include  'enumfilenm.inc'

;---------------
;LZW pack
;input      pixels
;output     non_packed
;-------------
;  rsi ������� �����
;  rbx ��������
;  r10 ����� �������� ������
;  r11 ����� ������ ��� ������. ������� 2, ����� ������� �����������, ����� ������������ � 2
;  ������ ������ ��������� �� ����� ��� ���������
;  ������ ���� ������� ������ 2 ������ ������-������ ������
;  ��� �� ������ �������, ������� ��
;  ��������� ������������� ����� - ������ � ����� ��� �����
;  �� ������� �� ������ � ���� ����� �������� � �������
; ������� ���������� ����� 101����
; ����������  lzw_table_last ������ ������ �� ��������� ������ �� ������  � ������� ������
; � rcx ������ �� r11 ����� ������
; � dx ����� ��� ��� ������������. �������� � �������������� ������ 101
; ���� ����� ������, �������� ����� ������ ������� �� ���
lzwp:



lzwpack:
     ;  int3
        nop
        nop
        nop
        xor     rax,rax
        xor     rdx,rdx
        xor     rdx,rdx
        mov     r10,screen_w*hdeight  ;������� ���� ������������
        mov     r11,2 ;��������� ����� ������

        mov     rsi,pixels                   ;������� �����
        mov     rbx,non_packed               ;�������� �����
        ;��������� ������ cc 100h
        mov        word [rbx],100h
        add        rbx,2

        ;������ ������ ��������� �� �����
        movzx    rax,byte [rsi]
        inc     rsi
        mov     [rbx],ax
        add     rbx,2


        ;����� ���� ����������� ������ rsi,rsi+1
lzw_again:
        mov     rcx,r11   ;����� ������ ������� ���

find_lzw_string_again:
        mov     r8,rsi    ;�������� ��������� �������� ������
        mov     r9,rbx    ;�������� ��������� ��������� ������
        mov     r11,rcx   ;�������� ����� ������
        call    stringtocount
        call   find_lzw_string
        cmp    rdi,101h
        jne    lzw_string_found
;��� ������ �� �������, �������� ����������� ���, ������� ������ � �������, ������� ����� ������ �� 2-�
     ;������� ������ � �������
        call   add_lzw_string
     ;   int3
        mov    [rbx],dx ;������
        add     rbx,2
        inc    r8       ;���������� ������� �����
        mov    rsi,r8  ;����������� ��������� �������� ������
        jmp    lzw_again


        inc    r11     ;�������� ������ ������
        mov    rcx,r11 ;����������� ���� ������

        call   add_lzw_string ;������� � �������
        mov    rdx,1
        dec    r10        ;����� ��������� ������
        jne    lzw_again
        ret


lzw_string_found:
;������ �������, ������������ ���, ����������� ����� ������ � ���� �����
        mov      r12,rbx ;����������
        inc      r11     ;����� ������
        jmp      lzw_again
        ret



find_lzw_string:
        ;rsi ������� ������
        ;rcx ����� ������

        mov  r13,[lzw_table_last]      ;������ �� ��������� ������ � ������� ������
test_prev_string:
        mov  rdi,[r13]                 ;�� ������� � ������ � �������
        cmp  rdi,101h

        ;��������� ������ (�� �����  ������� ����������)
        je  end_of_serch
        ;������ ������� � �������� ��� ������.
        call       stringtocount
        cmp        rax,[rdi]
        ;������, ��� ����� ���������� � ���?
        je       found_in_table
        ;��������� ������ � ������� ����
        sub        r13,8
        jmp        test_prev_string

found_in_table:
        ;������������ ���
        sub       rdi,lzw_table
        shr       rdi,3
        add       rdi,100h
        mov       rdx,rdi
        ;����������� ����� ������ � ������� �������
        inc          r11
        mov          rcx,r11

end_of_serch:

        ret

add_lzw_string:
        ;�������� ��� ������� ������ � rsi
        ;rcx - ����� ������
        ;���� ���������� lzw_vocab_last, ������� ������ ������ ��������� ����� � lzw_vocab.
        mov  r12,rbx
        mov       rdi,[lzw_vocab_last]
        ;��� �� �������� ���������� � lzw_table �� �������� lzw_table_last.
        mov       rbx,[lzw_table_last]
        ;��������� 8 � lzw_table_last,
        add       rbx,8
        mov       [rbx],rdi
        int3
        mov     [rdi],rax
        add     rdi,8
        ;����� �� �������� � �� ���� ������������ ���� ������.
       ; rep       movsb
        ;��������� ����� �������� � lzw_vocab_last (��� rdi ����� movsb)
        mov       [lzw_vocab_last],rdi
        add       qword [lzw_table_last],8
      ;  mov       rdi,[lzw_table_last]

rdi_to_code:
        sub       rbx,lzw_table
        shr       rbx,3
        add       rbx,100h
        mov       rdx,rbx
        mov       rbx,r12
        ;int3                         567321

        ret


convert_i       dq      0
handle          dq      0


byteswritten    dq      0
bytesreaded     dq      0


lzw_table_last       dq      lzw_table + 8 ;��������� ������ ��������� ���
lzw_vocab_last       dq      lzw_vocab


heighst:
        dq      0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0
accumul:
        dq      0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0;40*row,27*row,32*row,-8*row,16*row,38*row,-17*row,22*row,10*row,39*row,3*row,-11*row,9*row,-32*row,4*row,15*row,1*row


non_packed:
        dw      100h,0h,00h,00h,00h,0ffh,0ffh
        db      1024 dup(0ffh)
pixels:
        db 7,7,7,7,7,7,7,7,7,7 ,0ffh,0ffh
        db 7,7,7,7,7,7,7,7,7,7 ,0ffh,0ffh
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
        dq      100h    ; ��� �������
        dq      101h ;   ��� �����
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


;-------------------------------------
;gif file
;--------------------------------------
gif_file_header:
         db      'GIF89a'
width   dw     screen_w
height  dw     hdeight
        db      0f7h; 24bpp 4 colors 12 bytes pallete ; 0f7h ;global color table absent 24 bpp
        db      2 ;color number of background
        db      0 ;����������� ������
        ;pallete
        include 'gifpallet.inc'

         db      ','
         dw      0 ;���������� �������� �� ��� ������
         dw      0
widthl   dw     screen_w
heightl  dw     hdeight
         db      0 ;��������� ������� �����������
         db      08 ;����������� ����

copmrbytes         db      screen_w*hdeight+0 ;0feh ;���������� ���� ����
;-----------------
;lzw packed pixels
;----------------

        ; db      00
compressed_picture:
;pixels:
;        db      screen_w*hdeight dup(0)
         db 0b,01b,02h,0,0,0,0,0,0,0,0,0,00,0,0,0,0,0,0

         db       0,3Bh
endofgif:

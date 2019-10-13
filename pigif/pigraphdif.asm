
; graphics of pi-hex assuming on hex digits
; order of he digits
; 0 1 2 4 8 3 5 9 A C 7 B D E F

screen_w =4
Bytes_per_pixel = 1
row = screen_w*Bytes_per_pixel
hdeight =4
max_col_h=14

format PE64 GUI

entry start
  section '.idata' import data readable writeable

  include  'dllinclude.inc'

  section '.text' code readable executable  writeable
  start:
        call opennmappihex
;rax - address of pi_hex
;-------------------------
;take digit from file and inc in the table heighst
         mov     rsi,1

         inc   rax
         inc   rax

coumt2:
         xor   rbx,rbx
         mov   rcx,100
         mov   r9,27h

coumt1:
         xor    rdx,rdx
         mov    bl,[rax]
         ;and   bl,3fh
         sub    bl,30h
         bt     rbx,5
         cmovb  rdx,r9
         sub    rbx,rdx

         ;and    bl,0fh
         ;setb   dl
         ;sub    bl,dl
         inc    rax
         shl    bl,3
;         add    qword [rbx+heighst],row
         inc     qword [rbx+accumul]
         loop   coumt1

         push   rax
         push   rsi

;---------------------------
;calc relaties
;âû÷èñëÿåì ñðåäíåå - ñóììà âñåõ, äåëåíàÿ íà 16
;èç êàæäîãî çíà÷åíèå âû÷èòàåì ñðåäíåå
            mov rcx,16
            xor rax,rax
            mov rdi,accumul
sumof16:
            add rax,[rdi]
            add rdi,8
            loop       sumof16
            sar rax,4

            mov rcx,16
            xor rsi,rsi

eachrelative:
            mov rbx,[rsi*8+accumul]
            sub rbx,rax
            mov [rsi*8+heighst],rbx
            inc rsi
            loop        eachrelative

;scale heighst
          mov    rcx,16
          mov    rdi,heighst

scaleh2:
          mov    rax,[rdi]
          mov    rbx,rax
          neg    rax
          cmovl  rax,rbx
          cmp    rax, max_col_h
          jb     scaleh1
          mov    qword [rdi],max_col_h
scaleh1:
          add   rdi,8
          loop  scaleh2


           mov    rcx,16
           mov    rdi,heighst
           mov    rbx,row



         call   draw_graph



          pop    rsi
          pop    rax
          dec    rsi
          jne    coumt2
;------------------------------
;convert bitmap to gif blocks
;8-bit pixsels to 9-bit gif chanks


          xor     rcx,rcx
          call    [ExitProcess]

          include       'opnepihex.inc'
          include       'enumfilenm.inc'

eighttonine:
;rsi - pixels
;rdi -compressed
         xor    rax,rax
         mov    rsi,pixels
         mov    rdi, compressed_picture
         mov    rcx,15
ein1:
         mov    al,[rsi]
         ;insert 0-bit
         shl     rax,9
         inc     rsi
         loop    ein1
         mov     [rdi],rax
         ret

;-----------------
;normalize the heighs

draw_graph:



       call     enumfile


;--------------------
;fill white
       mov      rdi,pixels
       xor      al,al
       dec      al
       mov      rcx,hdeight*row
;       rep      stosb
;----------------------------
;draw horizontal axis with black
      mov       rdi,pixels+hdeight*row/2
      ;xor       al,al
      mov        al,16
      mov       rcx,row
;      rep       stosb
;----------------------------
;draw graphic green 16 columns width 8 height from table
      mov       rcx,pixels+51*row+10*Bytes_per_pixel
      mov       rsi,heighst
      mov       rbx,16

      mov       r8,8*Bytes_per_pixel
      mov       r9,row

   sub       rsp,40h
;      mov       qword [rsp+20h],8300h

grapich:

      mov       rdx,[rsi]
      imul      rdx,r9

  ;    call      [DrawColumn]
      add       rsi,8
      add       rcx,30 ;place for next column
      dec       rbx
      jne       grapich
    add       rsp,40h

    ;    call    eighttonine

;----------------------------
;here save the  gif

         mov     rcx,[handle_bmp]
       sub     rsp,40h
         mov     rdx,gif_file_header
         mov     r8, endofgif-gif_file_header;hdeight*row+54+1024    ;bytes to write
         mov     r9,byteswritten
         mov     qword [rsp+20h],0
         call    [WriteFile]
       add     rsp,40h
         ret

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
     db hdeight*screen_w*Bytes_per_pixel    dup(7)
     db 256 dup(0)


gif_file_header:
         db      'GIF89a'
width   dw     screen_w
height  dw     hdeight
        db      0f7h; 24bpp 4 colors 12 bytes pallete ; 0f7h ;global color table absent 24 bpp
        db      2 ;color number of background
        db      0 ;ñîîòíîøåíèå ñòîðîí
        ;pallete
        include 'gifpallet.inc'

    ;   include 'gifhex2.inc'
       ; include 'gifhex.inc'
         db      ','
         dw      0 ;ïîëîäæåíèå êàðòèíêè íà ëîã ýêðàíå
         dw      0
widthl   dw     screen_w
heightl  dw     hdeight
         db      0 ;ëîêàëüíàÿ ïëàòèðà îòñóòñòâóåò
         db      08 ;ðàçìåðíîñòü êîäà
         db      screen_w*hdeight+4 ;0feh ;êîëè÷åñòâî áàéò êîäà

         db      00
compressed_picture:
;pixels:
         db      1,1,1,1,0,0,0,0, 0h,0h,0h,0h,1,2,4,8;,10h, 20h,40h,80h
    ;     db      0,1,2,3,4,5,6,7,8,9,0ah,0bh,0ch,0dh,0eh,0fh
    ;     db      0,1,2,3,4,5,6,7,8,9,0ah,0bh,0ch,0dh,0eh,0fh
    ;     db      0,1,2,3,4,5,6,7,8,9,0ah,0bh,0ch,0dh,0eh,0fh
    ;     db      0,1,2,3,4,5,6,7,8,9,0ah,0bh,0ch,0dh,0eh,0fh
    ;     db      0,1,2,3,4,5,6,7,8,9,0ah,0bh,0ch,0dh,0eh,0fh
    ;     db      0,1,2,3,4,5,6,7,8,9,0ah,0bh,0ch,0dh,0eh,0fh
    ;     db      0,1,2,3,4,5,6,7,8,9,0ah,0bh,0ch,0dh,0eh,0fh
    ;     db      0,1,2,3,4,5,6,7,8,9,0ah,0bh,0ch,0dh,0eh,0fh
    ;     db      0,1,2,3,4,5,6,7,8,9,0ah,0bh,0ch,0dh,0eh,0fh
    ;     db      0,1,2,3,4,5,6,7,8,9,0ah,0bh,0ch,0dh,0eh,0fh
    ;     db      0,1,2,3,4,5,6,7,8,9,0ah,0bh,0ch,0dh,0eh,0fh
    ;     db      0,1,2,3,4,5,6,7,8,9,0ah,0bh,0ch,0dh,0eh,0fh
    ;     db      0,1,2,3,4,5,6,7,8,9,0ah,0bh,0ch,0dh,0eh,0fh
    ;     db      0,1,2,3,4,5,6,7,8,9,0ah,0bh,0ch,0dh,0eh,0fh
         ;db      254 dup(7h)
;         db      255,0
;         db      254 dup(7)


         db      1,8,8
         db      0,3Bh
endofgif:
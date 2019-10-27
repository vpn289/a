
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


          xor     rcx,rcx
          call    [ExitProcess]

          include       'opnepihex.inc'
          include       'enumfilenm.inc'
          include       '9-8pack.inc'


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
    ; db hdeight*screen_w*Bytes_per_pixel+4    dup(7h)
     dw  100h, 7,102h, 103h , 104h;,  105h,106h,  107h, 108h,109h, 10ah, 10bh, 10ch,10dh,10eh;,10fh;,110h;,111h;,112h;10ch,10dh,10eh,10fh, 8,  8,8,8,8, 110h, 0, 101h,0   ; 7,  7, 7 ,7,7,7,7
     ;dw  ,7,7,7,7,7, 7,7,7,7,7,7,7,7,7,7,102h, 103h , 104h,  105h,106h
      dw  7,102h, 103h , 8,106h,7
      dw  7,102h, 103h , 8,107h
      dw   8
      dw  7,102h, 103h , 8
      dw  7,102h, 103h , 8
      dw  7,102h, 103h , 8
      dw  7,102h, 103h , 8
      dw  7,102h, 103h , 104h
   ;  dw  100h, 7,102h, 103h , 104h,  105h,106h
     dw  101h                                         ;28+8=36
     dw  0ffffh
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

         db      ','
         dw      0 ;ïîëîäæåíèå êàðòèíêè íà ëîã ýêðàíå
         dw      0
widthl   dw     screen_w
heightl  dw     hdeight
         db      0 ;ëîêàëüíàÿ ïëàòèðà îòñóòñòâóåò
         db      08 ;ðàçìåðíîñòü êîäà

copmrbytes         db      7 ;screen_w*hdeight+0 ;0feh ;êîëè÷åñòâî áàéò êîäà

        ; db      00
compressed_picture:
;pixels:
        db      256 dup(0)
      ;    db      7,04h,02h,0eh,04h ;,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
         ; db      0x00, 0x07, 0x08, 0x1C, 0x28, 0x30, 0x20
       ;     db     0x00, 0x07, 0x08, 0x1c, 0x30, 0x10, 0x0
          ; 0000 0000 1110 0000 0001 0000 0011 1000 0000 1100 0000 0100
          ; 000000001 110000000 010000001 110000000 110000000 100
          ; 000000001 110000000 010000001 110000000 110000001
          ; 00000000  1110000   00010000  0011 1000 00001100 0000 1000
          ;  00        07       08        1c      030      10
          ; 0x08, 0x0B,
          ; 0x00, 0x35, 0x0C, 0x11, 0x48, 0x24, 0x43,0x41, 0x22, 0x01, 0x01, 0x00, 0x3B,
          ; 0000 0000  1010 1100  0011 0000  1000 1000  0010 0001  0100 0010  1100 0010  1000 0010  0100 0100 1000 0000 1000 0000
          ;  000000001 010110000 110000100 010000010 000101000 010110000 101000001 001000100 100000001 0000000
         ; db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
      ;    db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
      ;    db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
      ;    db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h

       ;   db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
       ;   db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
       ;   db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
       ;   db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
       ;   db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
       ;   db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
       ;   db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
       ;   db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
       ;   db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
       ;   db      7,0eh,1Ch;,38h  7,0eh,1Ch,
        ;  db      255
        ;  db      7,0eh,1ch, 38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
        ;  db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
        ;  db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
        ;  db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
        ;  db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h

        ;  db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
        ;  db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
        ;  db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
        ;  db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
        ;  db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
        ;  db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
        ;  db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
        ;  db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
        ;  db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
        ;  db      7,0eh,1Ch;38h ,  7,0eh,1Ch
        ;  db      255
        ;   db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
        ;  db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
        ;  db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
        ;  db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
        ;  db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h

        ;  db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
        ;  db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
        ;  db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
        ;  db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
        ;  db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
        ;  db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
        ;  db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
        ;  db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
        ;  db      7,0eh,1Ch,38h,70h,0E0h,0C0h,81h, 03h, 7,0eh,1Ch,38h,70h,0E0h,0C0h ,81h , 03h
        ;  db      7,0eh,1Ch;,38h
         db       0,3Bh
endofgif:

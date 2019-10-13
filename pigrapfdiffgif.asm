
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

  dd 0,0,0,RVA kernel_name,RVA kernel_table
  dd 0,0,0,RVA user_name,RVA user_table
  dd 0,0,0,RVA mydll,RVA mydll_table
  dd 0,0,0,0,0

  kernel_table:
    ExitProcess     dq RVA _ExitProcess
    ReadFile        dq RVA _ReadFile
    WriteFile       dq RVA _WriteFile
    CreateFile      dq RVA _CreateFile
    OpenFile        dq RVA _OpenFile
    GetLastError    dq RVA _GetLastError
    SetFilePointer  dq  RVA _SetFilePointer
    CreateFileMappingA  dq  RVA _CreateFileMappingA
    MapViewOfFile       dq  RVA _MapViewOfFile
    dq 0

  user_table:
    MessageBoxA dq RVA _MessageBoxA
    dq 0

  mydll_table:
     IntToString  dq RVA _IntToString
     CutLeadingZeroes dq RVA _CutLeadingZeroes
     DrawColumn       dq RVA _DrawColumn
    dq 0

  kernel_name db 'KERNEL32.DLL',0
  user_name db 'USER32.DLL',0
  mydll     db 'my.dll',0

  _ExitProcess dw 0
    db 'ExitProcess',0
  _MessageBoxA dw 0
    db 'MessageBoxA',0
  _ReadFile dw 0
    db 'ReadFile',0
  _WriteFile dw 0
    db 'WriteFile',0
  _CreateFile dw 0
    db 'CreateFileA',0
  _OpenFile   dw 0
    db 'OpenFile',0
  _GetLastError dw      0
    db 'GetLastError',0
  _SetFilePointer dw 0
    db 'SetFilePointer',0
  _IntToString dw 0
    db 'IntToString',0
  _CutLeadingZeroes dw 0
    db 'CutLeadingZeroes',0
  _DrawColumn   dw      0
    db 'DrawColumn',0
  _CreateFileMappingA dw        0
    db 'CreateFileMappingA',0
  _MapViewOfFile dw     0
    db 'MapViewOfFile',0

; section '.text' code readable executable
  section '.text' code readable executable  writeable
  start:
       sub     rsp,40h
         mov     rcx,pihextb
         mov   rdx, 0x80000000  ;generic read
         mov   r8,0 ;sharemode
         mov   r9,0 ;dsecuriti attr
         mov   qword [rsp+20h],3 ;open exist
         mov   qword [rsp+24h],80h ;file attribute
         mov   qword [rsp+28h],0 ;htemplatefile
         call  [CreateFile]
       add   rsp,40h
         mov   [handle_pihex],rax
         mov   rcx,rax
         mov   rdx,0;file mapping attributes
         mov   r8,2 ; pages read only
         mov   r9,0 ; maximum size
       sub   rsp,40h
         mov   qword [rsp+20h],0 ;maximum size
         mov   qword [rsp+24h],0
         call  [CreateFileMappingA]
       add   rsp,40h
         mov   rcx,rax
         mov   rdx,4 ;desiread access RO
         mov   r8,0
         mov   r9,0 ;offset
       sub   rsp,40h
         mov   qword [rsp+20h],0
         call  [MapViewOfFile]
       add   rsp,40h
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

eighttonine:;al-input byte

         ret

;-----------------
;normalize the heighs

draw_graph:




;--------------
;try to create file enum.en
       sub   rsp,40h
         mov   rcx,filename
         mov   rdx, 0xc0000000 ;0x10000000 ;desiredaccess ;ofStruc
         mov   r8,0 ;sharemode
         mov   r9,0 ;dsecuriti attr
         mov   qword [rsp+20h],4 ;open file always
         mov   qword [rsp+24h],80h ;file attribute
         mov   qword [rsp+28h],0 ;htemplatefile
         call  [CreateFile]
       add   rsp,40h
         mov   [handle],rax
         call  [GetLastError]
         cmp   al,0b7h ;already exist
;read the
       sub    rsp,40h
         mov    rcx,[handle]
         mov    rdx,convert_i
         mov    r8,8    ;bytes to read
         mov    r9,bytesreaded
         mov    qword [rsp+20h],0
         call   [ReadFile]
       add    rsp,40h

         inc    qword [convert_i]

;writeback
         mov     rcx,[handle]
         xor     rdx,rdx
         xor     r8,r8
         xor     r9,r9  ;set to begin
       sub       rsp,40h
         call    [SetFilePointer]
       add       rsp,40h
         mov     rcx,[handle]
       sub     rsp,40h
         mov     rdx,convert_i
         mov     r8,8    ;bytes to write
         mov     r9,byteswritten
         mov     qword [rsp+20h],0
         call    [WriteFile]
       add     rsp,40h


       ;  call   to_decimal
         mov    rcx,convert_i
         mov    rdx,firstnum
       sub    rsp,40h
         call   [IntToString]
         mov    rcx,firstnum
         call   [CutLeadingZeroes]
       add    rsp,40h
;here rcx is the name of file
;         mov    rcx,firstnum
         mov   rdx, 0xc0000000 ;0x10000000 ;desiredaccess ;ofStruc
         mov   r8,0 ;sharemode
         mov   r9,0 ;dsecuriti attr
       sub   rsp,40h
         mov   qword [rsp+20h],4 ;open file always
         mov   qword [rsp+24h],80h ;file attribute
         mov   qword [rsp+28h],0 ;htemplatefile
         call  [CreateFile]
       add   rsp,40h
         mov   [handle_bmp],rax

;--------------------
;fill white
       mov      rdi,pixels
       xor      al,al
       dec      al
       mov      rcx,hdeight*row
       rep      stosb
;----------------------------
;draw horizontal axis with black
      mov       rdi,pixels+hdeight*row/2
      ;xor       al,al
      mov        al,16
      mov       rcx,row
      rep       stosb
;----------------------------
;draw graphic green 16 columns width 8 height from table
      mov       rcx,pixels+51*row+10*Bytes_per_pixel
      mov       rsi,heighst
      mov       rbx,16

      mov       r8,8*Bytes_per_pixel
      mov       r9,row

   sub       rsp,40h
      mov       qword [rsp+20h],8300h

grapich:

      mov       rdx,[rsi]
      imul      rdx,r9

  ;    call      [DrawColumn]
      add       rsi,8
      add       rcx,30 ;place for next column
      dec       rbx
      jne       grapich
    add       rsp,40h


;----------------------------
;here save the  gif

         mov     rcx,[handle_bmp]
       sub     rsp,40h
         mov     rdx,gif_file_header
         mov     r8, pixels-gif_file_header;hdeight*row+54+1024    ;bytes to write
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
handle_bmp      dq      0
handle_pihex    dq      0
byteswritten    dq      0
bytesreaded     dq      0



filename db 'enum.en',0  ,0,0,0
pihextb    db 'pi_hex_1b.txt',0

firstnum  db '12345678901234567890'
          db '.gif',0

heighst:
        dq      0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0
accumul:
        dq      0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0;40*row,27*row,32*row,-8*row,16*row,38*row,-17*row,22*row,10*row,39*row,3*row,-11*row,9*row,-32*row,4*row,15*row,1*row

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
         db      3,0,4,8,10h,20h,40h,80h,1,2,4,8,10h, 20h,40h,80h
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


pixels:
 ;  dd 0ff8080h , 0ff0000h,  0ff0000h, 0ff0000h, 0ff0000h, 0ff0000h, 0ff0000h, 0ff0000h, 0ff0000h, 0ff0000h, 0ff0000h, 0ff0000h, 0ff0000h, 0ff0000h, 0ff0000h
     db 100*screen_w*Bytes_per_pixel    dup(0)

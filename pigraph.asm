
; graphics of pi-hex assuming on hex digits
; order of he digits
; 0 1 2 4 8 3 5 9 A C 7 B D E F

screen_w = 180
Bytes_per_pixel = 3
row = screen_w*Bytes_per_pixel

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

; section '.text' code readable executable
  section '.text' code readable executable  writeable
  start:
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
         call    [SetFilePointer]
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
       mov      rcx,100*row
       rep      stosb
;----------------------------
;draw horizontal axis with black
      mov       rdi,pixels+50*row
      xor       al,al
      mov       rcx,row
      rep       stosb
;----------------------------
;draw graphic green 16 columns width 8 height from table
      mov       rcx,pixels+51*row+10*Bytes_per_pixel
      mov       rsi,heighst
      mov       rbx,16

      mov       r8,8*Bytes_per_pixel
      mov       r9,row
      mov       qword [rsp+20h],8300h


      sub       rsp,40h

grapich:

      mov       rdx,[rsi]

      call      [DrawColumn]
      add       rsi,8
      add       rcx,30 ;place for next column
      dec       rbx
      jne       grapich
      add       rsp,40h


;----------------------------
;here save the  bmp

         mov     rcx,[handle_bmp]
         sub     rsp,40h
         mov     rdx,bmp_file_header
         mov     r8,100*row+54+1024    ;bytes to write
         mov     r9,byteswritten
         mov     qword [rsp+20h],0
         call    [WriteFile]
         add     rsp,40h

;----------EXIT----------
         xor      rcx,rcx
         call  [ExitProcess]
;-------------------------------



convert_i       dq      0
handle          dq      0
handle_bmp      dq      0
byteswritten    dq      0
bytesreaded     dq      0



filename db 'enum.en',0  ,0,0,0

firstnum  db '12345678901234567890'
          db '.bmp',0

heighst:
        dq      40*row,27*row,32*row,-8*row,16*row,38*row,-17*row,22*row,10*row,39*row,3*row,-11*row,9*row,-32*row,4*row,15*row,1*row

bmp_file_header:

BITMAPFILEHEADER:
  bfType      dw 4d42h
  bfSize      dd 100*screen_w*Bytes_per_pixel +54
  bfReserved1 dw 0
  bfReserved2 dw 0
  bfOffBits   dd  pixels -  bmp_file_header


BITMAPINFOHEADER:
  biSize          dd 40
  biWidth         dd screen_w
  biHeight        dd 100
  biPlanes        dw 1
  biBitCount      dw Bytes_per_pixel*8
  biCompression   dd 0
  biSizeImage     dd 100*screen_w*Bytes_per_pixel
  biXPelsPerMeter dd 600
  biYPelsPerMeter dd 600
  biClrUsed       dd 0
  biClrImportant  dd 0

pixels:
 ;  dd 0ff8080h , 0ff0000h,  0ff0000h, 0ff0000h, 0ff0000h, 0ff0000h, 0ff0000h, 0ff0000h, 0ff0000h, 0ff0000h, 0ff0000h, 0ff0000h, 0ff0000h, 0ff0000h, 0ff0000h
     db 100*screen_w*Bytes_per_pixel    dup(0)

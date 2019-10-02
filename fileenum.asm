
; file enumerator
;create in folder 'foldername' file 1.ext if folder empty
;if folder not empty create file with next name i/e 1.exe exisit creates 2.ext and so on


format PE64 GUI
include     'gdi32.inc'
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

;----------EXIT----------
         xor      rcx,rcx
         call  [ExitProcess]


;write to file
;
to_file:
         push    rsi
         push    rax
         mov   rcx,[handle]
         mov   rdx,[str_start]
         mov   r8,[str_len]
         mov   r9,byteswritten
         sub   rsp,128
         call  [WriteFile]
         add   rsp,128
         pop   rax
         pop   rsi
         ret
;-------------------------
;convert to  decimal subs

cut_leading_zeroes:
;rdi - start of string
;rcx - length of string
        mov     rdi,firstnum
        mov     rcx,21
        mov     al,30h
        cld
        repe     scasb
        dec      rdi
        ret

put_number:
;rax - number
        mov     [convert_i],rax
;        call    to_decimal
        call    cut_leading_zeroes
        mov     [str_start],rdi
        mov     [str_len],rcx
        call    to_file
        ret

crlf:
        mov       qword [str_start],crlf_s
        mov       qword [str_len],2
        call      to_file
        ret

roof_symbol:
        mov     qword [str_start],roofs
        mov     qword [str_len],1
        call    to_file
        ret

star_symbol:
        mov     qword [str_start],star
        mov     qword [str_len],1
        call    to_file
        ret


convert_i       dq      0
convertbcd:     dq      0
                dw 0
digits          db      12
handle          dq      0
byteswritten    dq      0
bytesreaded     dq      0
str_start       dq      0
str_len         dq      0
star            db      '*'
roofs           db      '^'
crlf_s          db      13,10


filename db 'enum.en',0  ,0,0,0
ofStruc:  db 136
          db 0
          dw 0
          dw 0
          dw 0
          db 128 dup(0)
firstnumlen  dq  2
summlen   dq  0
          db  '00'
firstnum  db '11'
          db 256 dup(0h)
dividers         dq 0
dividers_total   dq      0
lowpart          dq 2
highpart         dq 0
lowpart_save     dq 0
simples:         dq 2
          dq 1024 dup(?)

          db       0x200000 dup  (?)

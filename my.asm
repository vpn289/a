
;

format PE64 console dll
include 'win64a.inc'

section '.text' code readable executable

proc DllEntryPoint hinstDLL,fdwReason,lpvReserved
        mov     eax,TRUE
        ret
endp

proc IntToString uses rsi rax rdi
; rcx pointer to  integer
; rdx pointer to result string

to_decimal:
        push    rsi
;        mov     [convert_i],rcx
        xor     rdi,rdi
        fild    qword [rcx] ;[convert_i]
        fbstp    tbyte [convertbcd]
        mov      rsi,convertbcd+9

todec2:
        mov      al,[rsi]
        dec      rsi
        mov      ah,al
        shr      al,4
        and      ah,0fh
        or       ax,3030h
        mov      word [rdi+rdx],ax
        inc      rdi
        inc      rdi
        cmp      rsi,convertbcd
        jnb      todec2
        pop      rsi
        ret

        ret
endp


proc SpaceLeadingZeroes uses  rax
space_leading_zeroes:
;rcx - start of string
;rcx - length of string
        mov     ah,21
        mov     al,30h

slz2:
        cmp     al,[rcx]
        jne     slz1
        mov     byte [rcx],20h
slz1:
        inc     rcx
        dec     ah
        jne     slz2
        ret
endp

proc CutLeadingZeroes uses  rax rdi
cut_leading_zeroes:
;rdi - start of string
;rcx - length of string
        mov     rdi,rcx
        mov     rcx,21
        mov     al,30h
        cld
        repe     scasb
        dec      rdi
        mov      rcx,rdi
        ret
endp

proc DrawColumn uses  rax r10 r11 r12 r13
;draw column r8 width
; rcx-left low corner
; rdx - heigh of col
; r8 - width column in bytes
; r9 -width of screen in bytes
; rsp+20h - color
draw_col:
      mov       rax,[rbp+70h]
      mov       r13,rcx
      mov       r11,r9
      neg       r11
      test      rdx,rdx
      je        col3
      cmovg     r11,r9
;      add       r13,rdx

col1:
      mov       r10,r8
      ;mov       r11,rcx
      lea       r12,[rcx+rdx]
col2:

      mov       [r12],al
      inc       r12
      ror       rax,8
      mov       [r12],al
      inc       r12
      ror       rax,8
      mov       [r12],al
      inc       r12
      rol       rax,16
      sub       r10,3
      jne       col2
;      mov       rcx,r11
      sub       rdx,r11
;      sub       r11,r9
      jne       col1

col3:
      ret
endp

section '.bss' data readable writeable

  convertbcd:     dq      0
                dw 0


section '.edata' export data readable

  export 'my.DLL',\
         IntToString,'IntToString'  ,\
         CutLeadingZeroes,'CutLeadingZeroes',\
         SpaceLeadingZeroes,'SpaceLeadingZeroes',\
         DrawColumn,'DrawColumn'

section '.reloc' fixups data readable discardable

  if $=$$
    dd 0,8              ; if there are no fixups, generate dummy entry
  end if

section '.idata' import data readable writeable

  library kernel32,'KERNEL32.DLL'

  include 'api/kernel32.inc'




         ;pixels - 9-bit code
         ;compreesed pictue - packed bytes

eighttonine:
;rsi - pixels
;rdi -compressed
;áåðåì èíôîðìàöèþ èç ïèêñåëñ 9-áèòíûå ñëîâà â 16 áèòàõ, ïàêóåì èõ è ðàñêëàäûâàåì ïî 8 áèò.
         mov    rsi,pixels
         mov    rdi, compressed_picture
         mov    r8,rdi
         mov    rbx, screen_w*hdeight
         xor    rax,rax
         xor    rbx,rbx
         mov    rcx,1

         mov    ax,[rsi]
         mov    [rdi],al
         shr    rax,8
         ror    rax,cl
         inc    rsi
         inc    rsi
         inc    rdi
ein1:
         mov    ax,[rsi]
         cmp    ax,0ffffh
         je     ein2
         rol    rax,cl
         mov    [rdi],al
         inc    cl
         shr    rax,8
         ror    rax,cl
         inc    rsi
         inc    rsi
         inc    rdi
         cmp    cl,8
         jne    ein1
;íàêîïèëñÿ öåëûé áàéò, âûïíåì
         rol     rax,cl
         mov     [rdi],al
         xor     rax,rax
         mov     rcx,0
         inc     rdi
         inc     rbx
         cmp     rbx,20
         jne     ein1

        ;here end of gif-lzw code
ein2:
         mov     qword [rdi],03b0000h
         sub     rdi,r8
         mov     rax,rdi
   ;      dec     al
         mov     [copmrbytes],al
         ret

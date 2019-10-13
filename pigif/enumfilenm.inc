;--------------
enumfile:
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
         ret

handle_bmp      dq      0

filename db 'enum.en',0  ,0,0,0


firstnum  db '12345678901234567890'
          db '.gif',0

opennmappihex:
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
         ret

pihextb    db 'pi_hex_1b.txt',0
handle_pihex    dq      0

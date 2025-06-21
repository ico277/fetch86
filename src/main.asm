section .rodata
    distro_art_table:
        dd unknown_art
        dd 0xD99B1896   ; 'arch'
        dd arch_art 
       ; dd "arti"
       ; dd artix_art 
        dd 0x7948D555   ; 'debian'
        dd debian_art 
        dd 0xEF987004   ; 'gentoo'
        dd gentoo_art 
        dd 0xC5AE0EE2   ; 'linuxlite'
        dd linuxlite_art    
        dd 0xF42EDE36   ; 'linuxmint'
        dd linuxmint_art 
        dd 0x3795E431   ; 'pop'
        dd popos_art 
        dd 0x9D00FDE7   ; 'ubuntu'
        dd ubuntu_art 
        dd 0            ; terminator
        dd 0            ; terminator

    unknown_art:    incbin "./resources/unknown.bin"
    arch_art:       incbin "./resources/arch.bin"
    ;artix_art:      incbin "./resources/artix.bin"
    debian_art:     incbin "./resources/debian.bin"
    gentoo_art:     incbin "./resources/gentoo.bin"
    linuxlite_art:  incbin "./resources/linuxlite.bin"
    linuxmint_art:  incbin "./resources/linuxmint.bin"
    popos_art:      incbin "./resources/pop.bin"
    ubuntu_art:     incbin "./resources/ubuntu.bin"

    os_release_file: db "/etc/os-release", 0
    os_release_id:   db "ID=", 0

section .data
    msg db "UwU Nya~!", 0xA, 0
    msg_len equ $ - msg

section .bss
    distro_data: resd 3
    buffer: resb 4096

section .text
    global _start
    extern sdbm_hash
    extern strlen
    extern print
    extern println
    extern readline
    extern find_in_file_by_line

get_distro:
    push ebp
    mov ebp, esp
    sub esp, 8

    ; get hash of first argument (distro ID)
    push dword [ebp + 8]
    call sdbm_hash
    add esp, 4

    ; init vars
    mov edx, distro_art_table
    mov ecx, 0
.loop:
    inc ecx
    cmp dword [edx + ((8 * ecx) - 4)], 0
    je .notfound
    cmp eax, [edx + ((8 * ecx) - 4)]
    je .found
    jmp .loop
.notfound:
    mov dword eax, [distro_art_table]
    mov [esp], eax        ; moves the first element (unknown distro) of distro_art_table
    jmp .parse
.found:
    mov eax, [edx + (8 * ecx)]
    mov [esp], eax
.parse:
    ; do struct
    push dword [esp]
    call strlen
    add esp, 4

    mov [esp + 4], eax

    mov eax, [esp]
    mov [distro_data], eax

    mov eax, [esp]
    add eax, [esp + 4]
    inc eax
    mov eax, [eax]
    mov [distro_data + 4], eax

    mov eax, [esp]
    add eax, [esp + 4]
    add eax, 4
    inc eax
    mov [distro_data + 8], eax
.exit:
    mov eax, distro_data
    add esp, 8
    pop ebp
    ret


_start:
    ;mov dword [buffer], "gent"
    ;mov word [buffer + 4], "oo"
    ;mov byte [buffer + 6], 0
    ;push buffer
    ;call get_distro
    ;add esp, 4

    ;push dword [distro_data]
    ;call println
    ;add esp, 4

    ;push dword [distro_data + 8]
    ;call print
    ;add esp, 4

    ;push dword 0
    ;push dword buffer
    ;push dword 4096
    ;call readline
    ;add esp, 12

    ;mov byte [buffer + 4095], 0
    ;push buffer
    ;call println
    ;add esp, 4

    push os_release_id
    push os_release_file
    push buffer
    push dword 4096
    call find_in_file_by_line
    add esp, 16

    push buffer
    call println
    add esp, 4
.exit:
    mov eax, 1
    mov ebx, 0
    int 0x80

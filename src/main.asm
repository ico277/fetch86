section .rodata
    distro_art_table:
        dd unknown_art
        dd "arch"
        dd arch_art 
        dd "arti"
        dd artix_art 
        dd "debi"
        dd debian_art 
        dd "gent"
        dd gentoo_art 
        dd "linu"
        dd linuxlite_art 
        dd "linu"
        dd linuxmint_art 
        dd "popa"
        dd popos_art 
        dd "ubun"
        dd ubuntu_art 
        dd 0            ; terminator

    unknown_art:    incbin "./resources/unknown.bin"
    arch_art:       incbin "./resources/arch.bin"
    ;artix_art:      incbin "./resources/artix.bin"
    artix_art:      incbin "./resources/arch.bin"
    debian_art:     incbin "./resources/debian.bin"
    gentoo_art:     incbin "./resources/gentoo.bin"
    linuxlite_art:  incbin "./resources/linuxlite.bin"
    linuxmint_art:  incbin "./resources/linuxmint.bin"
    popos_art:      incbin "./resources/pop.bin"
    ubuntu_art:     incbin "./resources/ubuntu.bin"

section .data
    msg db "UwU Nya~!", 0xA, 0
    msg_len equ $ - msg

section .text
    global _start



_start:
    mov eax, 4  
    mov ebx, 1
    mov ecx, [distro_art_table + (8 * 3)] ; char*
    mov edx, 25  ; len
    int 0x80
.exit:
    mov eax, 1
    mov ebx, 0
    int 0x80

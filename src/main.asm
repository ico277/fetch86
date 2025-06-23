section .rodata
    distro_art_table:
        dd unknown_art
        dd 0xD99B1896   ; 'arch'
        dd arch_art 
        dd 0xAE211532
        dd artix_art 
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
    artix_art:      incbin "./resources/artix.bin"
    debian_art:     incbin "./resources/debian.bin"
    gentoo_art:     incbin "./resources/gentoo.bin"
    linuxlite_art:  incbin "./resources/linuxlite.bin"
    linuxmint_art:  incbin "./resources/linuxmint.bin"
    popos_art:      incbin "./resources/pop.bin"
    ubuntu_art:     incbin "./resources/ubuntu.bin"

    os_release_file db "/etc/os-release", 0
    os_release_id   db "ID=", 0
    
    move_cur_down_esc     db 0x1B, "[1B", 0
    move_cur_up_esc       db 0x1B, "[1A", 0
    disable_line_wrap_esc db 0x1B, "[?7l", 0
    enable_line_wrap_esc  db 0x1B, "[?7h", 0
    move_cur_right_esc1   db 0x1B, "[", 0
    move_cur_right_esc2   db "C", 0

    %define SEP " -> "

    os_line        db "OS    ", SEP, 0
    kernel_line    db "Kernel", SEP, 0
    uptime_line    db "Uptime", SEP, 0
    cpu_line       db "CPU"   , SEP, 0
    memory_line    db "Memory", SEP, 0

section .data
    newlines dd 0

section .bss
    distro_data: resd 4
    buffer: resb 4096

section .text
    global _start
    extern sdbm_hash
    extern strlen
    extern print
    extern println
    extern readline
    extern find_in_file_by_line
    extern int_to_str

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
    inc eax
    mov [distro_data + 4], eax

    mov eax, [esp]
    add eax, [esp + 4]
    add eax, 5
    mov eax, [eax]
    mov [distro_data + 8], eax

    mov eax, [esp]
    add eax, [esp + 4]
    add eax, 8
    inc eax
    mov [distro_data + 12], eax
.exit:
    mov eax, distro_data
    add esp, 8
    pop ebp
    ret
 
move_cur_up:
    push ebp
    mov ebp, esp
    mov eax, 0
.loop:
    cmp eax, [ebp + 8]
    jae .exit
    push eax
    push move_cur_up_esc
    call print
    add esp, 4
    pop eax
    inc eax
    jmp .loop
.exit:
    pop ebp
    ret

move_cur_down:
    push ebp
    mov ebp, esp
    mov eax, 0
.loop:
    cmp eax, [ebp + 8]
    jae .exit
    push eax
    push move_cur_down_esc
    call print
    add esp, 4
    pop eax
    inc eax
    jmp .loop
.exit:
    pop ebp
    ret

move_cur_right:
    push ebp
    mov ebp, esp
    sub esp, 12
    mov dword [esp], 0
    mov dword [esp + 4], 0
    mov dword [esp + 8], 0
    push esp
    push dword [ebp + 8]
    call int_to_str
    add esp, 8
    push move_cur_right_esc1
    call print
    add esp, 4
    push esp
    call print
    add esp, 4
    push move_cur_right_esc2
    call print
    add esp, 4
.exit:
    add esp, 12
    pop ebp
    ret

; count, buffer
get_kernel_version:
    push ebp
    mov ebp, esp
    push ebx
    sub esp, 1024
    
    mov eax, 122
    mov ebx, esp
    int 0x80

    mov eax, 0
.os:
    cmp eax, [ebp + 8]
    jae .exit
    mov cl, byte [esp + eax]
    cmp cl, 0
    je .space
    mov edx, [ebp + 12]
    mov byte [edx + eax], cl
    inc eax
    jmp .os
.space:
    cmp eax, [ebp + 8]
    jae .exit
    mov cl, " "
    mov edx, [ebp + 12]
    mov byte [edx + eax], cl
    inc eax
    sub dword [ebp + 8], eax
    add [ebp + 12], eax
    mov eax, 0
.version:
    cmp eax, [ebp + 8]
    jae .exit
    mov cl, byte [esp + 130 + eax]
    cmp cl, 0
    je .exit
    mov edx, [ebp + 12]
    mov byte [edx + eax], cl
    inc eax
    jmp .version

.exit:
    add esp, 1024
    pop ebx
    pop ebp
    ret

; buffer
get_uptime:
    push ebp
    mov ebp, esp
    push ebx
    sub esp, 128

    mov eax, 99           
    mov ebx, esp
    int 0x80

    mov ecx, esp

    push dword [ebp + 8]
    push dword [ecx] 
    call int_to_str
    add esp, 8
.exit:
    add esp, 128
    pop ebx
    pop ebp
    ret

_start:
    ; get distro ID from /etc/os-release
    push os_release_id
    push os_release_file
    push buffer
    push dword 4096
    call find_in_file_by_line
    add esp, 16
    
    ; remove newline
    push buffer
    call strlen
    add esp, 4
    mov byte [buffer + eax - 1], 0

    ; find distro info using the distro data table
    push buffer + 3
    call get_distro
    add esp, 4

    ; print distro art
    push dword [distro_data + 12]
    call println
    add esp, 4

    ; move the cursor to the top
    push dword [distro_data + 8]
    inc dword [esp]
    call move_cur_up
    add esp, 4
    
    ; move the cursor to the right
    push dword [distro_data + 4]
    call move_cur_right
    add esp, 4
    ; print first part of os_line
    push os_line
    call print
    add esp, 4
    ; print second half of os_line
    push dword [distro_data]
    call println
    add esp, 4
    ; increment newlines counter
    add dword [newlines], 1

    ; move the cursor to the right
    push dword [distro_data + 4]
    call move_cur_right
    add esp, 4
    ; print first part of kernel_line
    push kernel_line
    call print
    add esp, 4
    ; get kernel version
    push buffer
    push dword 4095
    call get_kernel_version
    add esp, 8
    ; print second part of kernel_line
    push buffer
    call println
    add esp, 4
    ; increment newlines counter
    add dword [newlines], 1

    ; move the cursor to the right
    push dword [distro_data + 4]
    call move_cur_right
    add esp, 4
    ; print first part of uptime_line
    push uptime_line
    call print
    add esp, 4
    ; get uptime
    push buffer
    call get_uptime
    add esp, 4
    ; print second part of uptime_line
    push buffer
    call println
    add esp, 4
    ; increment newlines counter
    add dword [newlines], 1


.fix_lines:
    mov dword eax, [distro_data + 8]
    cmp [newlines], eax
    ja .exit
    sub eax, dword [newlines]
    inc eax
    push eax
    call move_cur_down
    add esp, 4
.exit:
    mov eax, 1
    mov ebx, 0
    int 0x80

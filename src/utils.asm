section .bss


section .text
global sdbm_hash
global strlen

;unsigned long hash = 0;
;int c;
;while ((c = *str++)) {
;    unsigned long shifted_6  = hash << 6;     // hash * 64
;    unsigned long shifted_16 = hash << 16;    // hash * 65536
;    unsigned long subtract   = hash;          // original hash
;    unsigned long combined = c + shifted_6 + shifted_16 - subtract;
;    hash = combined;
;}
sdbm_hash:
    push ebp                    ; init stack
    mov ebp, esp
    sub esp, 20

    mov dword [esp], 0          ; index var
    mov dword [esp + 16], 0     ; hash var
.loop:
    mov eax, [esp]              ; move index var to eax
    mov edx, [ebp + 8]          ; move argument char* into edx
    movzx ecx, byte [edx + eax] ; store a char from argument[index] into ecx
    cmp ecx, 0                  ; compare ecx with 0 (terminator)
    je .exit                    ; jump to exit if 0

    mov eax, [esp + 16]         ; store hash into eax
    mov [esp + 12], eax         ; copy the current hash

    shl eax, 6                  ; left bitshift the hash by 6
    mov [esp + 4], eax          ; store a copy 

    mov eax, [esp + 16]         ; get current hash value
    shl eax, 16                 ; left bitshift the hash by 16
    mov [esp + 8], eax          ; store a copy

    add ecx, [esp + 4]          ; ecx += result from left bitshit 6
    add ecx, [esp + 8]          ; ecx += result from left bitshit 16
    sub ecx, [esp + 12]         ; ecx -= original hash

    mov [esp + 16], ecx         ; store the new hash
    inc dword [esp]             ; increment index var
    jmp .loop
.exit:
    mov eax, [esp + 16]         ; store the finished hash in eax (return value)
    add esp, 20                 ; cleanup stack
    pop ebp                     ; more cleanup
    ret


strlen:

    ret

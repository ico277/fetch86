section .data
    newline db 0xA, 0x0

section .bss


section .text
global sdbm_hash
global strlen
global print
global println
global readline

;unsigned long hash = 0;
;int c;
;while ((c = *str++)) {
;    unsigned long shifted_6  = hash << 6;     // hash * 64
;    unsigned long shifted_16 = hash << 16;    // hash * 65536
;    unsigned long subtract   = hash;          // original hash
;    unsigned long combined = c + shifted_6 + shifted_16 - subtract;
;    hash = combined;
;}
; arguments: char* (or any other null terminated string of data)
; return value: eax = uint
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


; arguments: char*
; return value: eax = uint
strlen:
    push ebp                    ; init stack
    mov ebp, esp

    mov edx, [ebp + 8]          ; store char* in edx
    xor eax, eax                ; init eax to 0

.loop:
    cmp byte [edx], 0           ; check if terminator is found
    je .exit                    ; exit if yes
    inc edx
    inc eax
    jmp .loop

.exit:   
    pop ebp                     ; cleanup
    ret

; arguments: char*
; return value: none
print:
    push ebp                    ; stack init stuffs
    mov ebp, esp

    mov ecx, [ebp + 8]          ; move first argument (char*) into edx
.loop:
    cmp byte [ecx], 0           ; check if *edx is equal to zero (0 = end of string)
    je .exit                    ; exit if end of string has been found

    mov eax, 4                  ; eax = syscall number 4 = sys_write
    push ebx                    ; save ebx in stack (callee reserved)
    mov ebx, 0                  ; ebx = file 0 = stdout
    mov edx, 1                  ; edx = amount of bytes to write (1 since its 1 character)
    int 0x80                    ; syscall

    pop ebx                     ; restore ebx
    inc ecx                     ; increment edx (next char in char*)
    jmp .loop                   ; continue loop
.exit:
    pop ebp                     ; stack cleanup
    ret

; arguments: char*
; return value: none
println:
    push ebp                    ; stack init stuffs 
    mov ebp, esp

    push dword [ebp + 8]        ; push first argument (char*) onto the stack
    call print                  ; call print
    add esp, 4                  ; stack cleanup

    push newline                ; push newline (pointer to "\n") onto the stack
    call print                  ; call print again
    add esp, 4                  ; stack cleanup
.exit:
    pop ebp                     ; more stack cleanup
    ret

; arguments:  count, char* (buffer), file number
; return value: amount of bytes read
readline:
    push ebp
    mov ebp, esp
    push ebx

    sub esp, 4                  ; allocate a dword on the stack for the index
    mov dword [esp], 0          ; init index to 0
.loop:
    mov eax, 3                  ; syscall number 3 = read
    mov ebx, [ebp + 16]         ; 3rd argument (file number) 
    mov ecx, [ebp + 12]         ; 2nd argument (buffer) 
    add ecx, [esp]              ; advance buffer by the amount of bytes read 
    mov edx, 1                  ; how many bytes to read (1)
    int 0x80                    ; execute the syscall
    
    cmp eax, 0                  ; check if eax is zero
    je .exit
    mov eax, [ebp + 8]
    cmp dword [esp], eax        ; check if buffer is full
    je .exit
    mov eax, [ebx + 12]         ; buffer
    add eax, [esp]              ; advance by the index
    cmp byte [eax], 0xA         ; check if newline was found
    je .exit
    add dword [esp], 1
    jmp .loop
.exit:
    mov dword eax, [esp]
    inc eax

    add esp, 4
    pop ebx
    pop ebp
    ret
    

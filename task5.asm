section .bss
    buf     resb 4096
    keybuf  resb 64         ; the keyword line

section .text
    global _start

_start:
    mov rax, 0
    mov rdi, 0
    mov rsi, buf
    mov rdx, 4096
    syscall
    mov r12, rax        ; r12 = total bytes read

    ; --- parse the first line: the keyword ---
    xor rcx, rcx        ; index into buf
    xor r14, r14         ; r14 = keyword length

.read_key:
    mov al, [buf + rcx]
    cmp al, 10             ; newline ends the keyword line
    je .key_done
    mov [keybuf + r14], al
    inc r14
    inc rcx
    jmp .read_key

.key_done:
    inc rcx               ; skip the newline
    mov r13, rcx           ; r13 = start index of the text (for the write later)
    xor r15, r15           ; r15 = current position within the keyword

.loop:
    cmp rcx, r12
    jge .done

    mov al, [buf + rcx]

    cmp al, 'a'
    jb .check_upper
    cmp al, 'z'
    ja .check_upper
    mov bl, [keybuf + r15]
    sub bl, 'a'              ; bl = shift for this position (a=0, b=1, ...)
    add al, bl
    cmp al, 'z'
    jbe .advance_key
    sub al, 26
    jmp .advance_key

.check_upper:
    cmp al, 'A'
    jb .store               ; not a letter at all — leave unchanged, keyword does not advance
    cmp al, 'Z'
    ja .store
    mov bl, [keybuf + r15]
    sub bl, 'a'
    add al, bl
    cmp al, 'Z'
    jbe .advance_key
    sub al, 26

.advance_key:
    inc r15                 ; move to the next keyword letter
    cmp r15, r14
    jl .store
    xor r15, r15             ; wrap back to the start of the keyword

.store:
    mov [buf + rcx], al

.next:
    inc rcx
    jmp .loop

.done:
    mov rax, 1
    mov rdi, 1
    mov rsi, buf
    add rsi, r13           ; skip the keyword line in the output
    mov rdx, r12
    sub rdx, r13
    syscall

    mov rax, 60
    mov rdi, 0
    syscall
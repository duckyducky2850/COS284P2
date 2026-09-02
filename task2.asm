section .bss
    buf     resb 4096       ; storage for the input, up to 4000 bytes

section .text
    global _start

_start:
    ; --- read all of stdin into buf ---
    ; Call number 0 reads bytes from a file descriptor. Descriptor 0 is stdin.
    mov rax, 0
    mov rdi, 0
    mov rsi, buf
    mov rdx, 4096
    syscall
    mov r12, rax        ; r12 = number of bytes read

    xor rcx, rcx        ; index = 0

; Looping over a string: step an index from 0 up to the length.
.loop:
    cmp rcx, r12
    jge .done

    mov al, [buf + rcx]

    ; Is it lowercase? If not, go check uppercase.
    cmp al, 'a'
    jb .check_upper
    cmp al, 'z'
    ja .check_upper
    add al, 3            ; shift forward by 3
    cmp al, 'z'
    jbe .store            ; still inside a-z, no wrap needed
    sub al, 26            ; wrapped past 'z' — bring it back into range
    jmp .store

.check_upper:
    ; Is it uppercase? If not, it's not a letter at all — leave it unchanged.
    cmp al, 'A'
    jb .store
    cmp al, 'Z'
    ja .store
    add al, 3
    cmp al, 'Z'
    jbe .store
    sub al, 26

.store:
    mov [buf + rcx], al

.next:
    inc rcx              ; advance the counter every time
    jmp .loop

.done:
    ; --- write buf back out, n bytes ---
    ; Call number 1 writes bytes to a file descriptor. Descriptor 1 is stdout.
    mov rax, 1
    mov rdi, 1
    mov rsi, buf
    mov rdx, r12
    syscall

    ; Every program must end by calling exit with status 0.
    mov rax, 60
    mov rdi, 0
    syscall
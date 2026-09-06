;shift 3 caesar cipher
section .bss
    buf     resb 4096       ; storage for the input, up to 4000 bytes

section .text
    global _start

_start:
    ; read from stdin into buf
    ; Call number 0 reads bytes from a file descriptor. Descriptor 0 is stdin.
    mov rax, 0 ;read
    mov rdi, 0 ; from stdin
    mov rsi, buf ; where to store the input
    mov rdx, 4096 ; maximum bytes to read
    syscall
    mov r12, rax        ; r12 = number of bytes read

    xor rcx, rcx        ; index = 0

; Looping over a string: 0 to n-1 (length) (n is number of bytes read)
.loop:
    cmp rcx, r12 
    jge .done

    mov al, [buf + rcx]

    ; Is it lowercase? not -> go check uppercase.
    cmp al, 'a'
    jb .check_upper
    cmp al, 'z'
    ja .check_upper
    add al, 3            ; shift forward by 3
    cmp al, 'z'
    jbe .store            ; still inside a-z, no wrap needed
    sub al, 26            ; wrapped past 'z', bring it back into range
    jmp .store

.check_upper:
    ; Is it uppercase? not -> leave it unchanged.
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
    inc rcx              ; incr the counter every time
    jmp .loop

.done:
    ; write back out
    ; Call number 1 writes bytes to a file descriptor. Descriptor 1 is stdout.
    mov rax, 1
    mov rdi, 1
    mov rsi, buf
    mov rdx, r12
    syscall

    ; exit
    mov rax, 60
    mov rdi, 0
    syscall
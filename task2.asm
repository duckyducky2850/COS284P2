;shift 3 caesar cipher
section .bss
    buf     resb 4096       ; storage for the input, up to 4000 bytes

section .text
    global _start

_start: ; entry point, execution begins here
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
.loop: ; top of the loop, one character processed per pass
    cmp rcx, r12          ; have we reached the end of the input?
    jge .done             ; if index >= length, leave the loop

    mov al, [buf + rcx]  ; al = the current character

    ; Is it lowercase? not -> go check uppercase.
    cmp al, 'a'
    jb .check_upper
    cmp al, 'z'
    ja .check_upper
    add al, 3            ; shift forward by 3, fixed key for this task (unlike task 3)
    cmp al, 'z'
    jbe .store            ; still inside a-z, no wrap needed
    sub al, 26            ; wrapped past 'z', bring it back into range
    jmp .store

.check_upper: ; only reached if al failed the lowercase test above
    ; Is it uppercase? not -> leave it unchanged.
    cmp al, 'A'
    jb .store
    cmp al, 'Z'
    ja .store
    add al, 3            ; same shift-by-3, uppercase alphabet this time
    cmp al, 'Z'
    jbe .store            ; still inside A-Z, no wrap needed
    sub al, 26            ; wrapped past 'Z', bring it back into range

.store: ; every path (shifted or unchanged) ends up here to save the result
    mov [buf + rcx], al  ; write the (possibly shifted) byte back into buf

.next:
    inc rcx              ; incr the counter every time
    jmp .loop            ; jump back to top of loop

.done: ; reached once every byte has been processed
    ; write back out
    ; Call number 1 writes bytes to a file descriptor. Descriptor 1 is stdout.
    mov rax, 1           ; write
    mov rdi, 1           ; to stdout
    mov rsi, buf         ; address of the bytes
    mov rdx, r12         ; how many bytes, the original count read
    syscall               ; perform the write

    ; exit
    mov rax, 60          ; exit
    mov rdi, 0           ; status 0
    syscall               ; program terminates here
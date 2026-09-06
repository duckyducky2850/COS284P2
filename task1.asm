; swap case in string
section .bss
    buf     resb 4096 ; storage for the input, up to 4000 bytes as stated in the practical

section .text
    global _start

_start:
    ; read stdin into buf
    ; Call number 0 reads bytes from a file descriptor. 0 = stdin aka keyboard
    mov rax, 0          ; read
    mov rdi, 0          ; from stdin
    mov rsi, buf        ; where to store the input
    mov rdx, 4096       ; maximum bytes to read
    syscall             ; rax now holds the byte count
    mov r12, rax        ; r12 = number of bytes read (rax gets reused by the next syscall)

    xor rcx, rcx        ; index = 0

; Looping over a string
.loop:
    cmp rcx, r12        ; r12 holds the length
    jge .done           ; if index >= length, leave the loop

    mov al, [buf + rcx] ; the byte at this index

    ; An if is a cmp and a jump that skips the body. An if/else adds a jmp over the else. (slides lols)
    ; is al a lowercase letter (a-z)?
    cmp al, 'a'
    jb .check_upper     ; below 'a', not lowercase, go check uppercase instead
    cmp al, 'z'
    ja .check_upper     ; above 'z', not lowercase, go check uppercase instead
    sub al, 0x20         ; it is lowercase: lowercase to uppercase (same trick as the Lecture 3 demo)
    jmp .store           ; done with this byte, skip the uppercase check

.check_upper:
    ; is al uppercase?
    cmp al, 'A'
    jb .store            ; below 'A', not a letter at all, leave it unchanged
    cmp al, 'Z'
    ja .store            ; above 'Z', not a letter at all, leave it unchanged
    add al, 0x20          ; it is uppercase: uppercase to lowercase

.store:
    mov [buf + rcx], al  ; write the (possibly modified) byte back into buf

.next:
    inc rcx              ; advance the counter
    jmp .loop            ; jump back to top of loop

.done:
    ; write
    ; call 1 writes to a file descriptor, 1 is stdout aka screen
    mov rax, 1          ; write original number of bytes
    mov rdi, 1          ; to stdout
    mov rsi, buf        ; address of the bytes
    mov rdx, r12        ; how many bytes the original count read
    syscall


    ; exit
    mov rax, 60 ;exit
    mov rdi, 0 ;status
    syscall
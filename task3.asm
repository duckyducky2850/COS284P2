; chosen shift caesar cipher
section .bss
    buf     resb 4096

section .text
    global _start

_start:
    mov rax, 0
    mov rdi, 0
    mov rsi, buf
    mov rdx, 4096
    syscall
    mov r12, rax        ; r12 = total bytes read

    ; Parse first line (shift amount)
    ; Input is text, not numbers. '5' is the value 53, not 5.
    ; Subtract '0' to turn a digit character into its numeric value.
    xor rcx, rcx        ; index into buf
    xor rbx, rbx        ; rbx = shift value being built, starts at 0

.parse_shift:
    xor rax, rax          ; clear rax so only al's value counts
    mov al, [buf + rcx]
    cmp al, 10             ; newline ends the shift line
    je .parsed
    sub al, '0'             ; ascii digit -> numeric value
    imul rbx, rbx, 10       ; shift-so-far = shift-so-far * 10  (handles 2-digit shifts)
    add rbx, rax            ; + this digit
    inc rcx
    jmp .parse_shift

.parsed:
    inc rcx               ; skip the newline itself
    mov r13, rcx           ; r13 = index where the text begins (save it for the write later)

; Parse the text itself
; loop from r13 to r12-1, swapping/shift each character as needed
; same swap/shift loop but shift amount is in bl (0-25)
.loop:
    cmp rcx, r12
    jge .done

    mov al, [buf + rcx]

    cmp al, 'a'
    jb .check_upper
    cmp al, 'z'
    ja .check_upper
    add al, bl
    cmp al, 'z'
    jbe .store
    sub al, 26
    jmp .store

.check_upper:
    cmp al, 'A'
    jb .store
    cmp al, 'Z'
    ja .store
    add al, bl
    cmp al, 'Z'
    jbe .store
    sub al, 26

.store:
    mov [buf + rcx], al

.next:
    inc rcx
    jmp .loop

.done:
    ; write only the text portion from r13 onward, not the shift line
    mov rax, 1
    mov rdi, 1
    mov rsi, buf
    add rsi, r13          ; rsi = address of the text, buf + r13
    mov rdx, r12
    sub rdx, r13           ; rdx = how many bytes of text there are
    syscall

    mov rax, 60 ;exit yk
    mov rdi, 0
    syscall
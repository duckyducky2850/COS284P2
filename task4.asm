; XOR to hex
section .bss
    buf     resb 4096       ; the input
    hexbuf  resb 8200       ; two hex chars per input byte, plus a newline

section .text
    global _start

_start:
    mov rax, 0 ;read
    mov rdi, 0
    mov rsi, buf
    mov rdx, 4096
    syscall
    mov r12, rax        ; r12 = number of bytes read

    xor rcx, rcx        ; index into buf (input)
    xor r13, r13         ; index into hexbuf (output)

.loop:
    cmp rcx, r12
    jge .done

    mov al, [buf + rcx]
    xor al, 0x2a          ; combine every byte with the key

    ; split the byte into its two nibbles (a "nibble" is half a byte, 4 bits)
    mov bl, al
    shr bl, 4               ; bl = high nibble (0-15)
    and al, 0x0F            ; al = low nibble (0-15)

    ; convert the high nibble to a hex character
    cmp bl, 10
    jb .high_digit
    add bl, 'a' - 10        ; 10-15 -> 'a'-'f'
    jmp .high_store
.high_digit:
    add bl, '0'              ; 0-9 -> '0'-'9'
.high_store:
    mov [hexbuf + r13], bl
    inc r13

    ; convert the low nibble to a hex character
    cmp al, 10
    jb .low_digit
    add al, 'a' - 10
    jmp .low_store
.low_digit:
    add al, '0'
.low_store:
    mov [hexbuf + r13], al
    inc r13

.next:
    inc rcx
    jmp .loop

.done:
    mov byte [hexbuf + r13], 10   ; the single trailing newline the task asks for
    inc r13

    mov rax, 1 ;write
    mov rdi, 1
    mov rsi, hexbuf
    mov rdx, r13
    syscall

    mov rax, 60
    mov rdi, 0
    syscall
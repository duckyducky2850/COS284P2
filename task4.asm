; XOR to hex
section .bss
    buf     resb 4096       ; the input
    hexbuf  resb 8200       ; two hex chars per input byte, plus a newline

section .text
    global _start

_start: ; entry point, execution begins here
    mov rax, 0 ;read
    mov rdi, 0          ; from stdin
    mov rsi, buf        ; where to store the input
    mov rdx, 4096       ; maximum bytes to read
    syscall              ; rax now holds the byte count
    mov r12, rax        ; r12 = number of bytes read

    xor rcx, rcx        ; index into buf (input)
    xor r13, r13         ; index into hexbuf (output)

.loop: ; top of the loop, one input byte becomes two output hex characters per pass
    cmp rcx, r12          ; have we reached the end of the input?
    jge .done             ; if index >= length, leave the loop

    mov al, [buf + rcx]  ; al = the current input byte
    xor al, 0x2a          ; combine every byte with the key

    ; split the byte into its two nibbles (a "nibble" is half a byte, 4 bits)
    mov bl, al
    shr bl, 4               ; bl = high nibble (0-15)
    and al, 0x0F            ; al = low nibble (0-15)

    ; convert the high nibble to a hex character
    cmp bl, 10               ; is the nibble value 10-15 (needs a letter) or 0-9 (needs a digit)?
    jb .high_digit
    add bl, 'a' - 10        ; 10-15 -> 'a'-'f'
    jmp .high_store
.high_digit: ; only reached if bl was 0-9
    add bl, '0'              ; 0-9 -> '0'-'9'
.high_store: ; both paths land here to save the converted character
    mov [hexbuf + r13], bl  ; write the high-nibble hex char into the output buffer
    inc r13                ; advance the output index

    ; convert the low nibble to a hex character
    cmp al, 10               ; same test, applied to the low nibble this time
    jb .low_digit
    add al, 'a' - 10
    jmp .low_store
.low_digit: ; only reached if al was 0-9
    add al, '0'
.low_store: ; both paths land here to save the converted character
    mov [hexbuf + r13], al  ; write the low-nibble hex char into the output buffer
    inc r13                ; advance the output index

.next:
    inc rcx               ; advance the input index
    jmp .loop             ; jump back to top of loop, process the next input byte

.done: ; reached once every input byte has produced its two hex characters
    mov byte [hexbuf + r13], 10   ; the single trailing newline the task asks for
    inc r13                        ; include that newline in the byte count for the write

    mov rax, 1 ;write
    mov rdi, 1           ; to stdout
    mov rsi, hexbuf      ; address of the hex output (not buf, the original input)
    mov rdx, r13         ; how many hex characters (+ newline) were produced
    syscall               ; perform the write

    mov rax, 60          ; exit
    mov rdi, 0           ; status 0
    syscall               ; program terminates here
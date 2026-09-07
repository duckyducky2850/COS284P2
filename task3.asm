; chosen shift caesar cipher
section .bss
    buf     resb 4096

section .text
    global _start

_start: ; entry point, execution begins here
    mov rax, 0          ; read
    mov rdi, 0          ; from stdin
    mov rsi, buf        ; where to store the input
    mov rdx, 4096       ; maximum bytes to read
    syscall              ; one single read gets the whole input (shift line + text) at once
    mov r12, rax        ; r12 = total bytes read

    ; Parse first line (shift amount)
    ; Input is text, not numbers. '5' is the value 53, not 5.
    ; Subtract '0' to turn a digit character into its numeric value.
    xor rcx, rcx        ; index into buf
    xor rbx, rbx        ; rbx = shift value being built, starts at 0

.parse_shift: ; loop 1: reads the header line only, stops at the newline (not at r12)
    xor rax, rax          ; clear rax so only al's value counts
    mov al, [buf + rcx]  ; al = current character of the shift line
    cmp al, 10             ; newline ends the shift line
    je .parsed
    sub al, '0'             ; ascii digit -> numeric value
    imul rbx, rbx, 10       ; shift-so-far = shift-so-far * 10  (handles 2-digit shifts)
    add rbx, rax            ; + this digit
    inc rcx               ; move to the next character of the shift line
    jmp .parse_shift      ; go test again

.parsed:
    inc rcx               ; skip the newline itself
    mov r13, rcx           ; r13 = index where the text begins (save it for the write later)

; Parse the text itself
; loop from r13 to r12-1, swapping/shift each character as needed
; same swap/shift loop but shift amount is in bl (0-25)
.loop: ; loop 2: top of the cipher loop, starts at r13 (rcx was left there by .parsed)
    cmp rcx, r12          ; have we reached the end of the whole buffer?
    jge .done             ; if index >= length, leave the loop

    mov al, [buf + rcx]  ; al = current character of the text

    cmp al, 'a'          ; is al a lowercase letter (a-z)?
    jb .check_upper
    cmp al, 'z'
    ja .check_upper
    add al, bl            ; shift forward by bl (the parsed shift, 0-25)
    cmp al, 'z'
    jbe .store            ; still inside a-z, no wrap needed
    sub al, 26            ; wrapped past 'z', bring it back into range
    jmp .store

.check_upper: ; only reached if al failed the lowercase test above
    cmp al, 'A'          ; is al an uppercase letter (A-Z)?
    jb .store             ; below 'A', not a letter at all, leave unchanged
    cmp al, 'Z'
    ja .store             ; above 'Z', not a letter at all, leave unchanged
    add al, bl             ; shift forward by bl, uppercase alphabet this time
    cmp al, 'Z'
    jbe .store             ; still inside A-Z, no wrap needed
    sub al, 26             ; wrapped past 'Z', bring it back into range

.store: ; every path (shifted or unchanged) ends up here to save the result
    mov [buf + rcx], al  ; write the (possibly shifted) byte back into buf

.next:
    inc rcx               ; advance the counter every time
    jmp .loop             ; jump back to top of loop

.done: ; reached once every byte of the text has been processed
    ; write only the text portion from r13 onward, not the shift line
    mov rax, 1            ; write
    mov rdi, 1            ; to stdout
    mov rsi, buf
    add rsi, r13          ; rsi = address of the text, buf + r13
    mov rdx, r12
    sub rdx, r13           ; rdx = how many bytes of text there are
    syscall               ; perform the write

    mov rax, 60 ;exit yk
    mov rdi, 0
    syscall               ; program terminates here
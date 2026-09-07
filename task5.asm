; viginere cipher

;The first line of the input is a keyword made of lowercase letters. The rest is the text to
;encrypt.*Shift each letter of the text forward by the amount given by the current keyword
;letter, where a shifts by 0, b by 1, and so on. Move to the next keyword letter for each
;letter you encrypt, wrapping back to the start of the keyword. Non-letters are copied
;unchanged and do not advance the keyword.

section .bss
    buf     resb 4096
    keybuf  resb 64         ; the keyword line

section .text
    global _start

_start: ; entry point, execution begins here
    mov rax, 0          ; read
    mov rdi, 0          ; from stdin
    mov rsi, buf        ; where to store the input
    mov rdx, 4096       ; maximum bytes to read
    syscall              ; one single read gets the whole input (keyword line + text) at once
    mov r12, rax        ; r12 = total bytes read

    ; parse keyword
    xor rcx, rcx        ; index into buf
    xor r14, r14         ; r14 = keyword length

.read_key: ; loop 1: copies the keyword line, character by character, into keybuf
    mov al, [buf + rcx]  ; al = current character of the keyword line
    cmp al, 10             ; newline ends the keyword line
    je .key_done
    mov [keybuf + r14], al  ; copy this keyword character into keybuf
    inc r14                ; advance the keyword-length counter
    inc rcx                ; move to the next character of the keyword line
    jmp .read_key          ; go test again

.key_done: ; reached once the newline ending the keyword line is found
    inc rcx               ; skip the newline
    mov r13, rcx           ; r13 = start index of the text (for the write later)
    xor r15, r15           ; r15 = current position within the keyword

.loop: ;loop through the text, shifting each letter by the current keyword letter (loop 2, starts at r13)
    cmp rcx, r12          ; have we reached the end of the whole buffer?
    jge .done             ; if index >= length, leave the loop

    mov al, [buf + rcx]  ; al = current character of the text

    cmp al, 'a'          ; is al a lowercase letter (a-z)?
    jb .check_upper
    cmp al, 'z'
    ja .check_upper
    mov bl, [keybuf + r15]  ; bl = the keyword letter at the current keyword position
    sub bl, 'a'              ; bl = shift for this position (a=0, b=1, ...)
    add al, bl               ; apply the shift
    cmp al, 'z'
    jbe .advance_key         ; still inside a-z, no wrap needed
    sub al, 26               ; wrapped past 'z', bring it back into range
    jmp .advance_key

.check_upper: ; only reached if al failed the lowercase test above
    cmp al, 'A'
    jb .store               ; not a letter at all, leave unchanged & keyword does not advance
    cmp al, 'Z'
    ja .store                ; not a letter at all, leave unchanged & keyword does not advance
    mov bl, [keybuf + r15]  ; bl = the keyword letter at the current keyword position
    sub bl, 'a'              ; bl = shift for this position
    add al, bl               ; apply the shift, uppercase alphabet this time
    cmp al, 'Z'
    jbe .advance_key         ; still inside A-Z, no wrap needed
    sub al, 26               ; wrapped past 'Z', bring it back into range

.advance_key: ; only reached for actual letters, matching the spec's "non-letters do not advance the keyword"
    inc r15                 ; move to the next keyword letter
    cmp r15, r14             ; has the keyword position run past the keyword's length?
    jl .store                ; still within the keyword, no wrap needed
    xor r15, r15             ; wrap back to the start of the keyword

.store: ; every path (shifted or unchanged) ends up here to save the result
    mov [buf + rcx], al  ; write the (possibly shifted) byte back into buf

.next:
    inc rcx               ; advance the counter every time
    jmp .loop             ; jump back to top of loop

.done: ; reached once every byte of the text has been processed
    mov rax, 1            ; write
    mov rdi, 1            ; to stdout
    mov rsi, buf
    add rsi, r13           ; skip the keyword line in the output
    mov rdx, r12
    sub rdx, r13           ; how many bytes of text there are
    syscall                ; perform the write

    mov rax, 60           ; exit
    mov rdi, 0            ; status 0
    syscall                ; program terminates here
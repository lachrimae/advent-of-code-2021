global _start

SYS_READ    equ 0
SYS_WRITE   equ 1
SYS_OPEN    equ 2
SYS_CLOSE   equ 3
SYS_BRK     equ 12
SYS_EXIT    equ 60
STDOUT      equ 1
READONLY    equ 0
BUFLEN      equ 16384

section .bss
; we desire five integers to track the five bits of our output
linelen: resb 1
inputlen: resb 4
; buffer is where we store the input read from file
buffer: resb BUFLEN
; workspace is our "heap".
; 48 bytes can be used for arithmetic
; then there is tons left over for the result string etc
workspace: resb 128

section .text
panic:
  mov rax, SYS_EXIT
  mov rdi, 1
  syscall

_start:
  pop rdi ; argc
  cmp rdi, 2
  jne panic
  pop rdi ; argv[0]: executable invocation name
  pop rdi ; argv[1]: file name

  ; fd = open(argv[1], flags, mode)
  mov rax, SYS_OPEN
  mov rsi, READONLY
  xor rdx, rdx
  syscall

  ; read from fd to buf
  mov rdi, rax
  mov rax, SYS_READ
  mov rsi, buffer
  mov rdx, BUFLEN
  syscall
  mov dword [inputlen], eax

  ; close(fd)
  mov rax, SYS_CLOSE
  syscall

  ; rax = '\n' // newlines are LF on Linux
  mov rax, 10
  mov rdi, buffer
  mov rsi, buffer
  ; while(1)
_start_find_newline:
  cmp byte [rsi], al
  ; if the byte is zero
  je _start_found_newline
  ; else add one and continue
  inc rsi
  jmp _start_find_newline
_start_found_newline:
  ; then add one and break
  inc rsi

  ; rsi = buffer start - occurrence of first '\n'
  sub rsi, rdi
  ; bring this down to one byte and move it to linelen
  mov rax, rsi
  mov byte [linelen], al

;  ; brk(4 * len(first line))
;  mov rax, rsi
;  mov rdi, 4
;  mul rdi
;  mov rdi, rax
;  mov rax, SYS_BRK
;  syscall
;  cmp rax, 0
;  jne panic

  call average_each_bit
  call asciify_bits

  ; write(stdout, bitstring, 5)
  mov rax, SYS_WRITE
  mov rdi, STDOUT
  mov rsi, workspace
  mov rdx, 5
  syscall

  ; exit(0)
  mov rax, SYS_EXIT
  xor rdi, rdi
  syscall

asciify_bits:
  enter 0, 0
  xor r11, r11
  ; rax = 4 * length of first line, not including newline
  mov rax, [linelen]
  dec rax
  mov rdx, qword 4
  mul rdx
asciify_bits_current_bit:
  cmp r11, [linelen]
  jge asciify_bits_end
  mov al, [rax + r11]
  inc r11
  jmp asciify_bits_current_bit
asciify_bits_end:
  leave
  ret

; INPUTS
; rax must be a value such that 0 <= rax < linelen
; OUTPUT
; the outputs will go into the .data section
average_each_bit:
  enter 0, 0
  xor r11, r11
average_each_bit_outer_loop:
  ; for (int i = 0; i < inputlen; i++)
  cmp rax, [inputlen]
  jge average_each_bit_outer_loop_exit
;average_each_bit_inner_loop:
;  ; for (int j = 0; j < rdi; j += linelen)
;  cmp r11, rdi
;  jge average_each_bit_inner_loop_exit
;  mov rsi, rdi
;  mov r12, bit1
;  push rdi
;  mov rdi, QWORD [r12 + rax*4]
;  push rax
;  push r11
;  ; average(rdi, rsi)
;  call average
;  ; here we save the bit
;  mov dword [bit1 + rcx*4], eax
;  pop r11
;  pop rdi
;  pop rax
;  mov rdi, rsi
;  inc r11
;  jmp average_each_bit_inner_loop
average_each_bit_inner_loop_exit:
  inc rax
  jmp average_each_bit_outer_loop
average_each_bit_outer_loop_exit:
  leave
  ret


; INPUTS
; rdi must be the initial address of the loop
; rsi must be the length of the loop
; OUTPUT
; eax will be 1 if at least half of the elements
;   were 1, and it will otherwise be zero
average:
  enter 0, 0
  xor rax, rax
  ; we want r11 to contain the terminal
  ; address of the summation loop
  mov r11, rdi
  add r11, rsi
average_body:
  add eax, dword [rdi]
  inc rdi
  ; if the next address is less than
  ; the terminal address...
  cmp rdi, r11
  ; return to the start of the loop
  jb average_body
  ; but otherwise return the mode of the
  ; inputs, assuming they were all 1 or 0
  xor rdx, rdx 
  div rsi
  ; we wish to test whether the quotient is
  ; greater than or equal than 2.
  ; we do so by subtracting two from the quotient
  ; and checking whether it is nonnegative
  sub eax, 2
  test eax, eax
  jns average_one
average_zero:
  xor rax, rax
  jmp average_done
average_one:
  mov rax, 1
average_done:
  leave
  ret

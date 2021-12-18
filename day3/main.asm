global _start

SYS_READ    equ 0
SYS_WRITE   equ 1
SYS_OPEN    equ 2
SYS_CLOSE   equ 3
SYS_EXIT    equ 60
STDOUT      equ 1
READONLY    equ 0
BUFLEN      equ 1024

section .bss
; we desire five integers to track the five bits of our output
bit1: resb 4
bit2: resb 4
bit3: resb 4
bit4: resb 4
bit5: resb 4
bitstring: resb 5
; 1 kilobyte of buffer
buffer: resb BUFLEN

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

  ; close(fd)
  mov rax, SYS_CLOSE
  syscall

  call average_each_bit
  call asciify_bits

  ; write from 
  ; syscall(SYS_WRITE, STDOUT, hello, hello_len);
  mov rax, SYS_WRITE
  mov rdi, STDOUT
  mov rsi, bitstring
  mov rdx, 5
  syscall

  ; exit(0)
  mov rax, SYS_EXIT
  xor rdi, rdi
  syscall

assemble_bits:
  enter 0, 0
  xor rax, rax

  add eax, dword [bit5]

  shl dword [bit4], 1
  add eax, dword [bit4]

  shl dword [bit3], 2
  add eax, dword [bit3]

  shl dword [bit2], 3
  add eax, dword [bit2]

  shl dword [bit1], 4
  add eax, dword [bit1]

  leave
  ret

asciify_bits:
  enter 0, 0

  mov al, [bit1]
  add al, 48
  mov [bitstring], al
  
  mov al, [bit2]
  add al, 48
  mov [bitstring + 1], al

  mov al, [bit3]
  add al, 48
  mov [bitstring + 2], al

  mov al, [bit4]
  add al, 48
  mov [bitstring + 3], al

  mov al, [bit5]
  add al, 48
  mov [bitstring + 4], al

  leave
  ret

; INPUTS
; rdi must be the length of each segment of the input
; OUTPUT
; the outputs will go into bit1, bit2, bit3, bit4 and bit5
average_each_bit:
  enter 0, 0
  mov rax, r12
  xor rax, rax
  xor r11, r11
average_each_bit_outer_loop:
  sub rax, 5
  test rax, rax
  jns average_each_bit_outer_loop_exit
  add rax, 5
average_each_bit_inner_loop:
  sub r11, rdi
  test rax, rax
  jns average_each_bit_inner_loop_exit
  add r11, rdi
  mov rsi, rdi
  ; i think this is too many layers of indirection
  ; on this next line:
  mov rdi, QWORD [r12 + rax*4]
  push rax
  push rdi
  push r11
  call average
  ; here we save the bit
  mov dword [bit1 + rcx*4], eax
  pop r11
  pop rdi
  pop rax
  mov rdi, rsi
  inc r11
average_each_bit_inner_loop_exit:
  inc rax
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

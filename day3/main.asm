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
  ; require one CLI argument
  jne panic
  pop rdi ; argv[0]: executable invocation name
  pop rdi ; argv[1]: file name

  ; fd = open(argv[1], flags, mode)
  mov rax, SYS_OPEN
  mov rsi, READONLY
  xor rdx, rdx
  syscall

  ; read the input file into the buffer
  mov rdi, rax
  mov rax, SYS_READ
  mov rsi, buffer
  mov rdx, BUFLEN
  syscall
  mov dword [inputlen], eax

  ; close(fd)
  mov rax, SYS_CLOSE
  syscall

  ; this has been tested and shown to be working
  ; we want to find the length of each line
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

  call average_each_bit

  ; prepare to call asciify_bits
  ; set rdi to linelen
  mov rsi, workspace
  xor rax, rax
  mov al, [linelen]
  dec al
  mov rbx, 4
  mul rbx
  mov rdi, rax
  mov rdx, rax
  add rdx, workspace
  push rdx
  call asciify_bits
  pop rdx

  ; write(stdout, output string, linelen)
  mov rdi, STDOUT
  mov rsi, rdx
  xor rax, rax
  mov al, [linelen]
  mov rdx, rax
  dec rax
  mov byte [rax+rsi], 10
  mov rax, SYS_WRITE
  syscall

  ; exit(0)
  mov rax, SYS_EXIT
  xor rdi, rdi
  syscall

; this has been tested and shown to be working
; rsi: position in memory to start asciifying quadwords
; rdi: length of the memory segment
; rdx: position in memory to output bytes
asciify_bits:
  enter 0, 0
  ; r11 = 0
  xor r11, r11
  ; r12 = length of first line minus one
asciify_bits_current_bit:
  cmp r11, rdi
  jge asciify_bits_end
  ; this one has to grow by 4*r11 actually
  mov al, [rsi + r11]
  ; to ascii
  add al, 48
  mov [rdx], al
  inc rdx
  add r11, 4
  jmp asciify_bits_current_bit
asciify_bits_end:
  leave
  ret

; no inputs. relies on linelen, buffer, inputlen and workspace reserved vars
average_each_bit:
  enter 0, 0
  xor r11, r11
  ; rbx = end of input
  mov rbx, buffer
  add rbx, inputlen
  ; rcx = start of workspace
  mov rcx, workspace
average_each_bit_outer_loop:
  ; for (int r11 = 0; r11 < inputlen; r11 ++)
  inc r11
  cmp r11, [inputlen]
  dec r11
  jge average_each_bit_exit
  mov rdx, buffer
  add rdx, r11
average_each_bit_inner_loop:
  ; for (int rdx = buffer + r11; rdx < buffer+inputlen; rdx += linelen)
  cmp rdx, rbx
  jge average_each_bit_outer_loop_reenter
  ; place the new value into rax and de-asciify it
  xor rax, rax
  mov al, byte [rdx]
  sub al, 48
  ; add either 0 or 1 to the start of workspace offset by r11 quadwords
  add [rcx+4*r11], rax
  xor rax, rax
  mov al, byte [linelen]
  add rdx, rax
  jmp average_each_bit_inner_loop
average_each_bit_outer_loop_reenter:
  inc r11
  jmp average_each_bit_outer_loop
average_each_bit_exit:
  xor r11, r11
  ;
  ; TODO:
  ; so far we've only summed bits, time to truly average them
  ;
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

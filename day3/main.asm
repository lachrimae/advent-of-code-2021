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
; here we track some basic metadata about the data in the inputbuf
varmode: resb 1
linelen: resb 1
inputlen: resb 4
numlines: resb 4
; workspace is our "heap".
; 48 bytes can be used for arithmetic
; then there is tons left over for the output string
workspace: resb 128
; we store the input in this inputbuf
inputbuf: resb BUFLEN

section .text
panic:
  mov rax, SYS_EXIT
  mov rdi, 1
  syscall

usegamma:
  mov byte [varmode], 1
  jmp _start_finished_processing_input
useepsilon:
  mov byte [varmode], 0
  jmp _start_finished_processing_input

_start:
  pop rdi ; argc
  cmp rdi, 3
  ; require two CLI arguments
  jne panic
  pop rdi ; argv[0]: executable invocation name
  pop rdi ; argv[1]: file name

  ; fd = open(argv[1], flags, mode)
  mov rax, SYS_OPEN
  mov rsi, READONLY
  xor rdx, rdx
  syscall

  ; read the input file into the inputbuf
  mov rdi, rax
  mov rax, SYS_READ
  mov rsi, inputbuf
  mov rdx, BUFLEN
  syscall
  mov dword [inputlen], eax

  ; close(fd)
  mov rax, SYS_CLOSE
  syscall

  ; get the varmode
  pop rdi
  mov rax, [rdi]
  cmp al, 101 ; "e" in ASCII, use epsilon
  je useepsilon
  cmp al, 103 ; "g" in ASCII, use gamma
  je usegamma
  ; if neither worked then panic
  jmp panic
_start_finished_processing_input:

  ; we want to find the length of each line
  ; rax = '\n' are newlines are LF on Linux
  mov rax, 10
  mov rdi, inputbuf
  mov rsi, inputbuf
  ; while(1): check if *rsi is a newline. if so, break
_start_find_newline:
  cmp byte [rsi], al
  je _start_found_newline
  inc rsi
  jmp _start_find_newline
_start_found_newline:
  ; then add one and break
  inc rsi

  ; rsi = inputbuf start - occurrence of first '\n'
  sub rsi, rdi
  ; bring this down to one byte and move it to linelen
  mov rax, rsi
  mov byte [linelen], al

  call average_each_bit

  ; prepare to call asciify_bits
  ; set rdi to linelen
  mov rsi, r12
  xor rax, rax
  mov al, [linelen]
  dec al
  mov rbx, 4
  mul rbx
  mov rdi, rax
  mov rdx, rax
  add rdx, workspace
  call asciify_bits

  ; write(stdout, output string, linelen)
  mov rdi, STDOUT
  mov rsi, r12
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

; rsi: position in memory to start asciifying bytes
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
  inc r11
  jmp asciify_bits_current_bit
asciify_bits_end:
  leave
  ret

; no inputs. relies on linelen, inputbuf, inputlen and workspace reserved vars
; output: r12 indicates the beginning of the program output
average_each_bit:
  enter 0, 0
  ; r11 is the cursor into the inputbuf
  xor r11, r11
  ; r12 is the index within the current line
  xor r12, r12
  ; r13 is the number of EOLs encountered so far
  xor r13, r13
  ; rdx = beginning of input
  ; rbx = end of input
  mov rbx, inputbuf
  add ebx, dword [inputlen]
  ; rcx = start of workspace
  mov rcx, workspace
average_each_bit_summation_loop:
  mov rax, r12
  inc rax
  cmp al, byte [linelen]
  jae average_each_bit_summation_loop_newline
  mov rax, r11
  cmp eax, dword [inputlen]
  jae average_each_bit_division_loop_enter
  
  xor rax, rax
  mov al, byte [inputbuf+r11]
  sub rax, 48
  add dword [workspace+4*r12], eax

  inc r11
  inc r12
  jmp average_each_bit_summation_loop
average_each_bit_summation_loop_newline:
  inc r11
  mov r12, 0
  inc r13
  jmp average_each_bit_summation_loop
average_each_bit_division_loop_enter:
  ; saving this result from the summation loop
  mov rax, r13
  mov dword [numlines], eax

  ; r12 is the beginning of our output memory segment
  xor rax, rax
  mov al, byte [linelen]
  dec rax
  mov rbx, 4
  mul ebx
  mov r12, workspace
  add r12, rax

  ; r11 is the index into our list of vars in workspace
  xor r11, r11
average_each_bit_division_loop:
  mov rax, r11
  inc rax
  cmp al, byte [linelen]
  jge average_each_bit_exit

  ; upper bytes of our dividend are in edx
  ; lower bytes will be in eax
  xor edx, edx
  xor rax, rax
  ; divisor is the number of 1s so far in this column
  mov eax, dword [workspace+4*r11]
  mov rbx, rax
  ; dividend is the number of lines in the column
  mov eax, dword [numlines]
  div rbx ; TODO: SIGFPE due to rbx == 0 somehow
  ; if the quotient is less than or equal to two,
  ; then there are >50% 1s in the column.
  push rax
  mov al, byte [varmode]
  cmp al, 1
  je average_each_bit_gamma_comparison
  jmp average_each_bit_epsilon_comparison
average_each_bit_gamma_comparison:
  pop rax
  cmp rax, 2
  jge average_each_bit_division_loop_insert_zero
  jmp average_each_bit_division_loop_insert_one
average_each_bit_epsilon_comparison:
  pop rax
  cmp rax, 2
  jge average_each_bit_division_loop_insert_one
  jmp average_each_bit_division_loop_insert_zero
average_each_bit_division_loop_insert_one:
  mov rax, 1
  jmp average_each_bit_division_loop_reenter
average_each_bit_division_loop_insert_zero:
  xor rax, rax
average_each_bit_division_loop_reenter:
  mov byte [r12+r11], al
  inc r11
  jmp average_each_bit_division_loop
average_each_bit_exit:
  leave
  ret

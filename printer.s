        global printer, putchar
        extern resume
        extern len, cells, WorldWidth, WorldLength, state, len, curr
        extern printf

        ;; /usr/include/asm/unistd_32.h
sys_write:      equ   4
stdout:         equ   1


section .bss
                   

section .data

row_counter: dd 1
col_counter: dd 1
print_format: db '%d',10, 0



section .text

printer:
		
		push ebp
		mov ebp, esp

        mov ecx, state
        mov edi, dword [WorldLength]
        mov ebx, dword [WorldWidth]
        mov dword[col_counter], 1
        mov dword[row_counter], 1

    for_i:
    	cmp dword [row_counter], edi
    	jg done

    		for_j:    
				cmp dword[col_counter], ebx
    			jg print_newline
                mov edx, 0
                mov dl, byte [ecx]
                cmp dl, 0
                je print_zero                
                push '1'
                call putchar
                add esp, 4

            continue:

        		inc dword[col_counter]
                inc ecx
        		jmp for_j

        print_newline:

         	push 0xA
            call putchar
            add esp, 4

		mov dword [col_counter], 1
		inc dword [row_counter]
    	jmp for_i

         print_zero:
             push '0'
             call putchar
             add esp, 4
             jmp continue

         done:

            xor ebx, ebx
            mov dword [curr], 1
            mov esp, ebp
            pop ebp
            call resume             ; resume scheduler

        jmp printer

 putchar:
    push ebp
    mov ebp, esp

    pushad                 ; save registers
    mov eax, 4             ; sys_write
    mov ebx, 1             ; fd 1 == out
    lea ecx, [ebp + 4 + 1*4]       ; char
    mov edx, 1             ; # of chars
    int 0x80               ; call kernel
    popad                  ; restore registers

    pop ebp
    ret



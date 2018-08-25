;;; This is a simplified co-routines implementation:

;;; CORS contains just stack tops, and we always work
;;; with co-routine indexes.
        global init_co, start_co, end_co, resume, get_world_length, get_world_width, get_len
        global len, co_index, init_cells, cells, curr, get_cell_i_coordinate, get_cell_j_coordinate, get_cell_state, state, next_generation, get_cells
        extern WorldLength, WorldWidth, buffer, gameboard_size, debugFlag, putchar, num_of_gen, gen_before_print
        extern cell_next_state, printf
        extern backup_edi


maxcors:        equ 100*100+2         ; maximum number of co-routines
stacksz:        equ 16*1024     ; per-co-routine stack size


extern cell

section .data

print_format: db "%d", 10, 0

size_of_cell: 
        
struc co_i

        function_pointer: resd 1
        flag: resb 1
        i_coordinate: resd 1
        j_coordinate: resd 1
        age: resb 1
        num_of_alive_neighbor: resb 1
        co_index: resd 1


endstruc


len: equ 19

temp_i dd 0
temp_j dd 0

row_counter: dd 1
col_counter: dd 1



section .bss

stacks: resb maxcors * stacksz  ; co-routine stacks
cors:   resd maxcors            ; simply an array with co-routine stack tops
state: resb maxcors            ; cells states
curr:   resd 1                  ; current co-routine
origsp: resd 1                  ; original stack top
tmp:    resd 1                  ; temporary value
cells: resb maxcors*len
backup_eax: resd 1
backup_curr: resd 1




section .text


        ;; ebx = co-routine index to initialize
        ;; edx = co-routine start
        ;; other registers will be visible to co-routine after "start_co"
init_co:
        push eax                ; save eax (on caller's stack)
		push edx
		mov edx,0
		mov eax,stacksz
        imul ebx			    ; eax = co-routine's stack offset in stacks
        pop edx
		add eax, stacks + stacksz ; eax = top of (empty) co-routine's stack
        mov [cors + ebx*4], eax ; store co-routine's stack top
        pop eax                 ; restore eax (from caller's stack)

        mov [tmp], esp          ; save caller's stack top
        mov esp, [cors + ebx*4] ; esp = co-routine's stack top

        cmp ebx, 0
        je insert_k_t
        jmp not_insert

    insert_k_t:
        push gen_before_print
        push num_of_gen


    not_insert:
        push edx                ; save return address to co-routine stack
        pushf                   ; save flags
        pusha                   ; save all registers
        mov [cors + ebx*4], esp ; update co-routine's stack top

        mov esp, [tmp]          ; restore caller's stack top
        ret                     ; return to caller

        ;; ebx = co-routine index to start

init_cells:

		push ebp
		mov ebp, esp
		
        mov edi, cells
        mov ecx, dword [WorldLength]
        mov ebx, dword [WorldWidth]

        mov dword [curr], 2

        init_coordinates:

                init_i:
                        mov edx, dword [temp_i]

                        init_j:
                                mov esi, dword [temp_j]
                                mov dword [edi+i_coordinate], edx
                                mov dword [edi+j_coordinate], esi
                                mov byte [edi+flag], 1
                                mov byte [edi+num_of_alive_neighbor], 0
                                mov edx, dword[curr]
                                mov dword [edi+co_index],edx
                                inc dword [curr]
                                mov edx, dword [temp_i]
                                mov dword [edi+function_pointer], next_generation
                                add edi, len
                                inc dword [temp_j]
                                dec ebx
                                cmp ebx,0
                                jne init_j
                                mov ebx, dword [WorldWidth]
                                inc dword [temp_i]
                                mov dword [temp_j], 0
                                dec ecx
                                cmp ecx, 0
                                jnz init_i

        init_cors:

            mov ebx, 2
            mov edi, dword [gameboard_size]
            add edi, 2

            init_loop:

            	mov edx, next_generation
            	pushad
                call init_co
                popad
                inc ebx
                cmp ebx, edi
                jne init_loop


        init_state:
                mov edi, cells
                mov esi, buffer
                mov ecx, state

        
        check_state:

            cmp byte [esi], 0
            je done
            cmp byte [esi], 20h
            je put_zero
            cmp byte [esi], 0xA
            je next_char
            mov byte[ecx], 1
            inc ecx
            mov byte [edi+flag], 1
            mov byte [edi + age], 1
            add edi, len
            inc esi
            jmp check_state

		next_char:
			inc esi
			jmp check_state

                put_zero:
                        mov byte[ecx], 0
                        inc ecx,
                        mov byte [edi + age], 0
                        add edi, len
                        inc esi
                        jmp check_state

                done:
                        cmp byte [debugFlag], 1
                        jne end_init
                        mov ecx, state
                        mov edi, dword [WorldLength]
                        mov ebx, dword [WorldWidth]
                        mov dword[col_counter], 1
                        mov dword[row_counter], 1

                    for_i:
                        cmp dword [row_counter], edi
                        jg end_init

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

                            continue_loop:

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
                             jmp continue_loop

                    end_init:
                        mov esp, ebp
                        pop ebp
               
                        ret

                



get_cell_i_coordinate:

	push ebp
	mov ebp, esp

	mov edi, dword [ebp+8]
	mov eax, dword [edi + i_coordinate]

	mov esp, ebp
	pop ebp
	ret

get_cell_j_coordinate:

	push ebp
	mov ebp, esp

    mov edi, dword [ebp+8]
	mov eax, dword [edi + j_coordinate]

	mov esp, ebp
	pop ebp
	ret

get_cell_state:

	push ebp
	mov ebp, esp

        mov edi, dword [ebp+8]
        mov edx, dword [edi + co_index]
        sub edx, 2
        mov ecx, state
        add ecx, edx
        mov ebx,0 
        mov bl, byte [ecx]

        mov esp, ebp
        pop ebp

        mov eax, 0
        mov al, bl
	ret

get_cells:

        mov eax, cells
        ret

get_world_length:

        mov eax, dword [WorldLength]
        ret

get_world_width:

        mov eax, dword [WorldWidth]
        ret

get_len:

        mov eax, 0
        mov eax, len
        ret


next_generation:              
        
        push ebp
        mov ebp, esp
        


        calc_neighbors:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            mov edi, cells

        	.find_cell:
                mov esi, dword [curr]
                cmp dword [edi+co_index], esi   
                je start_calc
                add edi, len
                jmp .find_cell
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            start_calc:
                push edi

                push dword[edi+j_coordinate]
                push dword[edi+i_coordinate]              
                call cell_next_state
                add esp, 8
                pop edi

                pusha
                pushf

                mov ebx, dword[edi+co_index]
                mov dword[curr], ebx
                mov ebx, 0

                call resume

        update_cell_state:
            .here:
                popf
                popa

                mov edi, cells                   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                .find_cell:

                    mov esi, dword [curr]
                    cmp dword [edi+co_index], esi
                    je start_update
                    add edi, len
                    jmp .find_cell
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                start_update:

                mov ecx, state
                add ecx, dword [edi+co_index]
                sub ecx, 2  
                mov [ecx], al
                cmp al, 1
                je check_age
                mov byte [edi + age], 0
                jmp continue

                check_age:

                        cmp byte [edi + age], 9
                        jl inc_age
                        jmp continue

                inc_age:
                        inc byte [edi + age]

        continue:
            mov ebx, dword[edi+co_index]
            mov dword[curr], ebx
            mov ebx, 0
           	mov esp, ebp
           	pop ebp

            call resume
            jmp next_generation
                

start_co:

        pusha                   ; save all registers (restored in "end_co")
        mov [origsp], esp       ; save caller's stack top
        mov [curr], ebx         ; store current co-routine index
        jmp resume.cont         ; perform state-restoring part of "resume"

        ;; can be called or jumped to
end_co:
        mov esp, [origsp]       ; restore stack top of whoever called "start_co"
        popa                    ; restore all registers
        ret                     ; return to caller of "start_co"

        ;; ebx = co-routine index to switch to
resume:                         ; "call resume" pushed return address
        pushf                   ; save flags to source co-routine stack
        pusha                   ; save all registers
        xchg ebx, [curr]        ; ebx = current co-routine index  
        mov [cors + ebx*4], esp ; update current co-routine's stack top
        mov ebx, [curr]         ; ebx = destination co-routine index         

       

.cont:
        mov esp, [cors + ebx*4] ; get destination co-routine's stack top
        popa                    ; restore all registers
        popf                    ; restore flags
        ret                     ; jump to saved return address
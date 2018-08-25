        global scheduler, backup_edi
        extern resume, end_co
        extern cells, co_index, len, printer, next_generation, gameboard_size, curr, printf, num_of_gen, gen_before_print
        global backup_esp

section .data

current_co: dd 2
print_counter: dd 0
print_format: db "%d", 10, 0

section .bss

	print_freq: resd 1
	backup_edi: resd 1

section .text

scheduler:



    
game_loop:
     
    push ebp
    mov ebp, esp

    mov ecx, dword [ebp + 4]
    mov ecx, dword [ecx]
    mov eax, dword [ebp + 8]
    mov eax, dword [eax]
   	

  	calculate_cell_state:


	    mov edi, cells
	    
	    find_cell:
	    	mov esi, dword [current_co]
	    	cmp dword [edi+co_index], esi
	    	je activate_co_routine
	    	add edi, len
	    	jmp find_cell    


	    activate_co_routine:

	    	mov dword [curr], 0
	    	mov ebx, [current_co]
	    	call resume	    	
	    	inc dword [current_co]

	    update_current_cell:

	    	mov ebx, dword [gameboard_size]
	    	add ebx, 2
		    mov eax, dword[current_co]
		    mov edx, 0
		    div ebx
		    mov dword [current_co], edx  
		    cmp dword [current_co], 1
		    jle fix
		    jmp calculate_cell_state

		    fix:
		    	mov dword [current_co], 2   
		    	jmp update_cell_state
	

		update_cell_state:    
    		mov edi, cells
	    	mov esi, dword [current_co]
	    	.find_cell:
		    	cmp dword [edi+co_index], esi	
		    	je resume_co_routine
		    	add edi, len
		    	jmp .find_cell


	    resume_co_routine:
	    	mov ebx, dword [current_co]
    		mov dword [curr], 0
    		call resume
    		inc dword [current_co]

	    		.update_current_cell:
			    	mov ebx, dword [gameboard_size]
			    	add ebx, 2
				    mov eax, dword[current_co]
				    mov edx, 0
				    div ebx
				    mov dword [current_co], edx  
				    cmp dword [current_co], 1
				    jle .fix
				    jmp resume_co_routine


				    .fix:
				    	mov dword [current_co], 2
				    	inc dword [print_counter]

				    	check_if_need_to_print:
					    	mov eax, dword [gen_before_print]


					    	cmp dword [print_counter], eax
					    	je print
					    	jmp find_cell

	   					print:

                            mov ebx, 1
				    		mov dword [curr], 0
				    		call resume
				    		mov dword [print_counter], 0 


				    	dec ecx
				    	jnz calculate_cell_state
    					        			
    mov esp, ebp
    pop ebp

    call end_co             ; stop co-routines

        global main
        extern init_co, start_co, init_cells, resume
        extern scheduler, printer, printf
        global WorldLength, WorldWidth, buffer, gameboard_size, num_of_gen, gen_before_print, debugFlag


        ;; /usr/include/asm/unistd_32.h
sys_exit:       equ   1


section .data

print_format: 
        db "%d", 10, 0

print_newline: 
        db "", 10, 0
        
debugMsgLng:
        db 'length=' ,0 
len1 equ $-debugMsgLng

debugMsgWdt:
        db 'width=' ,0 
len2 equ $-debugMsgWdt
  
debugMsgNumOfGen:
        db 'number of generations=',0 
len3 equ $-debugMsgNumOfGen 
 
debugMsgPrtFreq:
        db 'print frequency=',0 
len4 equ $-debugMsgPrtFreq  
        
ten: 
        dd 10

WorldLength: 
        dd 0
WorldWidth: 
        dd 0
num_of_gen: 
        dd 0
gen_before_print: 
        dd 0
gameboard_size: 
        dd 0

debugFlag: db 0

section .bss

buffer: resb 10000  ; hold the initial state of the game from the file

widthToPrint: resd 1
lengthToPrint: resd 1
numOfGenToPrint: resd 1
freqToPrint: resd 1


section .text

 %macro debugPrint 4
          mov eax, 4
          mov ebx, 1
          mov ecx, %1 ; the message type!
          mov edx, %2 ; the message's length!
          int 80h
          mov eax, 4
          mov ebx, 1
          mov ecx, %3 ; the number to print!
          mov edx, %4  ; the length which is 3 at most.
          int 80h
          mov eax, 4
          mov ebx, 1
          mov ecx, print_newline ; the number to print!
          mov edx, 1  ; the length which is 3 at most.
          int 80h
        %endmacro
        
        

main:
        enter 0, 0

        xor ebx, ebx            ; scheduler is co-routine 0
        mov edx, scheduler
        mov ecx, [ebp + 4]      

        call init_co            ; initialize scheduler state

        inc ebx                 ; printer i co-routine 1
        mov edx, printer
        call init_co            ; initialize printer state

        mov esi, [ebp+12]
        add esi, 4
        mov esi, dword [esi]
        
        cmp word [esi], 0x642d
        je debugMode
        jmp noDebug
        
    debugMode:
            
            mov byte [debugFlag], 1
            mov esi, [ebp+12]
            add esi, 8
            mov esi, dword [esi]
            
            mov eax, 5 ; open the file  
            mov ebx, esi
            mov ecx, 0    ;
            mov edx, 0777    ;
            int 0x80         ;
        
            mov ebx, eax ; read the file 
            mov eax, 3 
            mov ecx, buffer    ;
            mov edx, 10000    ;
            int 0x80 
            mov dword [gameboard_size], eax  ;

            mov edi, 0
            mov esi, [ebp+12]
            add esi, 12	; esi = argv[1]
            mov esi, dword [esi]
            mov edi, esi  ; length of matrix
            mov dword [lengthToPrint], edi
            push edi
            call atoi
            add esp, 4
            mov dword [WorldLength], eax
            mov eax, 0
            mov edi, 0

            mov esi, [ebp+12]
            add esi, 16	; esi = argv[1]
            mov esi, dword [esi]
            mov edi, esi  ; width of matrix
            mov dword [widthToPrint], edi
            push edi
            call atoi

            add esp, 4
            mov dword [WorldWidth], eax
            mov eax, 0
            mov edi, 0

            mov esi, [ebp+12]
            add esi, 20	
            mov esi, dword [esi]
            mov edi, esi  ; number of generation in the game 
            mov dword [numOfGenToPrint], edi       
            push edi
            call atoi
            add esp, 4
            mov dword [num_of_gen], eax
            mov eax, 0
            mov edi, 0

            mov esi, [ebp+12]
            add esi, 24
            mov esi, dword [esi]
            mov edi, esi ; number of generation before calling the printer
            mov dword [freqToPrint], edi
            push edi
            call atoi
            add esp, 4
            mov dword [gen_before_print], eax

            mov eax, dword [WorldLength]
            inc eax
            sub dword [gameboard_size], eax
            
            push dword [lengthToPrint]
            call count_chars
            add esp, 4
            mov edi , eax
            debugPrint debugMsgLng,len1,dword [lengthToPrint], edi

            push dword [widthToPrint]
            call count_chars
            add esp, 4
            mov edi , eax            
            debugPrint debugMsgWdt,len2,dword[widthToPrint], edi

            push dword [numOfGenToPrint]
            call count_chars
            add esp, 4
            mov edi , eax
            debugPrint debugMsgNumOfGen,len3,dword[numOfGenToPrint], edi

            push dword [freqToPrint]
            call count_chars
            add esp, 4
            mov edi , eax
            debugPrint debugMsgPrtFreq,len4,dword[freqToPrint], edi
            
            mov eax, 4
            mov ebx, 1
            mov ecx, 0xA ;printing a new line!
            mov edx, 1
            int 80h
          
            jmp startGame 
            

    noDebug:
        
        mov eax, 5 ; open the file  
        mov ebx, esi
        mov ecx, 0    ;
        mov edx, 0777    ;
        int 0x80         ;

        mov ebx, eax ; read the file 
        mov eax, 3 
        mov ecx, buffer    ;
        mov edx, 10000    ;
        int 0x80 
        mov dword [gameboard_size], eax              ;

        mov edi, 0
        mov esi, [ebp+12]
        add esi, 8	; esi = argv[1]
        mov esi, dword [esi]
        mov edi, esi  ; length of matrix

        mov eax, 0
        push edi
        call atoi
        add esp, 4
        mov dword [WorldLength], eax
        mov eax, 0
        mov edi, 0

        mov esi, [ebp+12]
        add esi, 12	; esi = argv[1]
        mov esi, dword [esi]
        mov edi, esi  ; width of matrix
        push edi
        call atoi

        add esp, 4
        mov dword [WorldWidth], eax
        mov eax, 0
        mov edi, 0

        mov esi, [ebp+12]
        add esi, 16	
        mov esi, dword [esi]
        mov edi, esi  ; number of generation in the game        
        push edi
        call atoi
        add esp, 4
        mov dword [num_of_gen], eax
        mov eax, 0
        mov edi, 0

        mov esi, [ebp+12]
        add esi, 20
        mov esi, dword [esi]
        mov edi, esi ; number of generation before calling the printer
        push edi
        call atoi
        add esp, 4
        mov dword [gen_before_print], eax

        mov eax, dword [WorldLength]
        inc eax
        sub dword [gameboard_size], eax

       
       startGame:
       
        call init_cells
        

        xor ebx, ebx            ; starting co-routine = scheduler

        call start_co           ; start co-routines


        ;; exit

        mov eax, sys_exit
        xor ebx, ebx
        int 80h


atoi:
        push ebp
        mov ebp, esp        ; Entry code - set up ebp and esp
        push ecx
        push edx
        push ebx
        mov ecx, dword [ebp+8]  ; Get argument (pointer to string)
        xor eax,eax
        xor ebx,ebx
atoi_loop:
        xor edx,edx
        cmp byte[ecx],0
        jz  atoi_end
        imul dword[ten]
        mov bl,byte[ecx]
        sub bl,'0'
        add eax,ebx
        inc ecx
        jmp atoi_loop
atoi_end:
        pop ebx                 ; Restore registers
        pop edx
        pop ecx
        mov     esp, ebp        ; Function exit code
        pop     ebp
        ret
        

count_chars:

    push ebp
    mov ebp, esp

    mov ecx, dword [ebp + 8]
    mov edi, 0

    count_loop:
        cmp byte [ecx], 0
        je end_count
        inc ecx
        inc edi
        jmp count_loop 

    end_count:
        mov eax, edi
        mov esp, ebp
        pop ebp
        ret
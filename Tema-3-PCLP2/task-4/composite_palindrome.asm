section .note.GNU-stack 

section .text
global check_palindrome
global composite_palindrome
extern malloc
extern free
extern strcpy
extern strlen
extern strcmp

; int check_palindrome(const char *str, int len)
check_palindrome:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi

    ; get first parameter (str pointer)
    mov esi, [ebp+8]
    ; get second parameter (length)
    mov ecx, [ebp+12]

    ; test if length is zero
    test ecx, ecx
    ; if zero its a palindrome
    jz .is_palindrome
    ; compare length with 1
    cmp ecx, 1
    ; if <= 1 its a palindrome
    jle .is_palindrome

    ; start of string
    mov edi, esi
    ; end of string, uses lea to store the address in register
    lea eax, [esi+ecx-1]

.compare_loop:
    ; get char from start
    mov bl, [edi]
    ; get char from end
    mov dl, [eax]
    ; compare them
    cmp bl, dl
    ; if not equal => not a palindrome
    jne .not_palindrome

    ; increment start pointer / next letter
    inc edi
    ; decrement end pointer / next letter backward from end of the string
    dec eax
    ; compare them
    cmp edi, eax
    ; if start <= end , keep comparing
    jle .compare_loop

.is_palindrome:
    ; return value 1 (true case)
    mov eax, 1
    jmp .done

.not_palindrome:
    ; return value 0 (false case)
    xor eax, eax

.done:
    ; restore registers
    pop edi
    pop esi
    pop ebx
    mov esp, ebp
    pop ebp
    ret

; char* composite_palindrome(const char **strs, int len)
composite_palindrome:
    push ebp
    mov ebp, esp
    ; make space for variables
    sub esp, 36         
    push ebx
    push esi
    push edi

    ; sets optimal_length as zero 
    mov dword [ebp-4], 0
    ; sets optimal_stirng as zero    
    mov dword [ebp-8], 0

    ; checks if len is zero
    cmp dword [ebp+12], 0
    ; if not continues
    jne .start_processing
    ; allocate 1 byte
    push 1
    call malloc
    ; clean stack
    add esp, 4
    ; store null terminator
    mov byte [eax], 0
    ; return the empty string
    jmp .return_result

.start_processing:
    ; get len parameter
    mov ecx, [ebp+12]
    ; start with 1
    mov eax, 1
    ; shift left by len ( 2^len)
    shl eax, cl
    ; (2^len-1)
    dec eax
    ; store max_mask
    mov [ebp-12], eax

    ; start mask with 1 
    mov ecx, 1

.outer_loop:
    ; compare mask with max_mask
    cmp ecx, [ebp-12]
    ; if greater exit loop
    jg .outer_loop_done

    ; current_length = 0
    mov dword [ebp-16], 0
    ; string_index = 0
    mov ebx, 0 
    ; copies mask to edx
    mov edx, ecx

.length_calc_loop:
    ; compare index to length
    cmp ebx, [ebp+12]
    ;if index >= lenght then its done 
    jge .length_calc_done
    ; test if lower bit is set
    test edx, 1
    ; if not , skip
    jz .skip_string_length

    push ebx
    push ecx
    push edx
    ; gets strings array
    mov esi, [ebp+8]
    ; push current string
    push dword [esi+ebx*4]
    ; gets its length
    call strlen
    ; clean stack
    add esp, 4
    ; restores values
    pop edx
    pop ecx
    pop ebx
    ; adds the value from strlen to current_length
    add [ebp-16], eax

.skip_string_length:
    ; shift mask right
    shr edx, 1
    ; increment index
    inc ebx
    ; continue loop
    jmp .length_calc_loop

.length_calc_done:
    ; gets current length
    mov eax, [ebp-16]
    ; compare with optimal_length
    cmp eax, [ebp-4]
    ; if less skip
    jl .next_iteration

    ; adds 1 for null terminator
    inc eax
    push ecx
    push eax
    ; allocate memory
    call malloc
    ; clean stack
    add esp, 4
    pop ecx
    ; store current_string
    mov [ebp-20], eax
    ; adds null terminator 
    mov byte [eax], 0

    ; edi points to empty buffer
    mov edi, [ebp-20] 
    ; sets index to zero
    mov ebx, 0
    ; copies mask to edx
    mov edx, ecx 

.build_string_loop:
    ; compare index to lenght
    cmp ebx, [ebp+12]
    ; if >= then done
    jge .build_string_done
    ; test if lowest bit is set
    test edx, 1
    ; if not then skip
    jz .skip_string_copy

    ; saves registers
    push ebx
    push ecx
    push edx
    ; gets strs array
    mov esi, [ebp+8]
    ; gets current string
    mov eax, [esi+ebx*4]
    ; push source
    push eax
    ; push destination
    push edi
    call strcpy
    ; clean stack
    add esp, 8
    ; push string
    push eax
    ; get length
    call strlen
    ; clean stack
    add esp, 4
    ; advance pointer
    add edi, eax
    ;restore registers
    pop edx
    pop ecx
    pop ebx

.skip_string_copy:
    ; shift mask right
    shr edx, 1
    ; increment index
    inc ebx
    ; continue loop
    jmp .build_string_loop

.build_string_done:
    push ecx
    ; push current string
    push dword [ebp-20]
    ; get length
    call strlen
    ; clean stack
    add esp, 4
    ; push length
    push eax
    ;push string
    push dword [ebp-20]
    ; checks if palindrome
    call check_palindrome
    ; clear stack
    add esp, 8
    pop ecx
    ; test result
    test eax, eax
    ; if zero its not a palindrome
    jz .not_palindrome

    ; gets current length
    mov eax, [ebp-16]
    ; compare with optimal length
    cmp eax, [ebp-4]
    ; if less skip
    jl .not_palindrome
    ; if greater , new optimal length
    jg .new_optimal

    ; get current length
    mov eax, [ebp-8]
    ; test if null
    test eax, eax
    ; if null new optimal
    jz .new_optimal  

    push ecx
    ; push optimal string
    push dword [ebp-8] 
    ; push current string
    push dword [ebp-20] 
    ; compare
    call strcmp
    ; clean stack
    add esp, 8
    ; restore ecx
    pop ecx
    ; compare result
    cmp eax, 0
    ; if current >= optimal then skip
    jge .not_palindrome

.new_optimal:
    ; gets optimal string
    mov eax, [ebp-8]
    ; test if null
    test eax, eax
    ; if null skip free
    jz .no_free_needed
    ; save ecx
    push ecx
    ; push pointer to free
    push eax
    ; free memory
    call free
    ; clean stack
    add esp, 4
    ; restore ecx
    pop ecx

.no_free_needed:
    ; gets current length
    mov eax, [ebp-16]
    ; stores it in optimal length
    mov [ebp-4], eax
    ;get current string
    mov eax, [ebp-20]
    ; stores it in optimal string
    mov [ebp-8], eax
    ; continue loop
    jmp .next_iteration

.not_palindrome:
    ; check if current string exists
    cmp dword [ebp-20], 0
    ; if null skip
    je .next_iteration
    ; save ecx
    push ecx
    ; push pointer to free
    push dword [ebp-20]
    call free
    ; cleans stack
    add esp, 4
    ; restore ecx
    pop ecx

.next_iteration:
    ; increments mask
    inc ecx
    ; continues loop
    jmp .outer_loop

.outer_loop_done:
    ; checks if optimal string exists
    cmp dword [ebp-8], 0
    ; if yes, returns it
    jne .return_result
    ; allocate 1 byte
    push 1
    call malloc
    ; clean stack
    add esp, 4
    ; adds null terminator
    mov byte [eax], 0
    ; stores it in optimal string
    mov [ebp-8], eax

.return_result:
    ; returns optimal string
    mov eax, [ebp-8]
    ; restores registers
    pop edi
    pop esi
    pop ebx
    mov esp, ebp
    pop ebp
    ret
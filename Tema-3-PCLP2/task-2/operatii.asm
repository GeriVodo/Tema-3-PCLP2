section .note.GNU-stack 

section .text
global sort
global get_words

extern qsort

; int compare(const void *a, const void *b)
compare:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi

    ; gets first argument(address)
    mov eax, [ebp+8]
    ; gets second argument(address)
    mov ebx, [ebp+12]
    ; dereference to get the string 
    mov eax, [eax]
    ; dereference to get the string
    mov ebx, [ebx]      
    ; makes ecx zero
    xor ecx, ecx    
    ; stores the address of string a    
    mov edi, eax
.length_a:
    ; check for null terminator
    cmp byte [edi], 0   
    je .length_a_done
    ; increment length counter
    inc ecx
    ; moves to next charachter
    inc edi
    jmp .length_a
.length_a_done:
    ; sets edx to zero ( will hold length of b)
    xor edx, edx        
    ; goes through string b
    mov edi, ebx
.length_b:
    ; same thing as in length_a
    cmp byte [edi], 0   
    je .length_b_done
    inc edx
    inc edi
    jmp .length_b
.length_b_done:
    ; compare lengths
    cmp ecx, edx
    ; if a shorter it comes first
    jl .less
    ; if a is longer it comes second
    jg .greater
    ; if equal compare lexicographically
    mov esi, eax
    mov edi, ebx
.lex_compare:
    ; gets current char from a
    mov al, [esi]
    ; gets current char from b
    mov bl, [edi]
    ; compares first chars from each string
    cmp al, bl
    jl .less
    jg .greater
    ;checks if null-terminator is reached
    test al, al
    ; if yes strings are equal      
    jz .equal
    ; increment both
    inc esi
    inc edi
    ; comtinue comparing
    jmp .lex_compare

.less:
    ; returns -1, a comes before b
    mov eax, -1         
    jmp .done
.greater:
    ; returns 1, a comes after b
    mov eax, 1          
    jmp .done
.equal:
    ; returns 0, strings are equal
    xor eax, eax        
.done:
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

; void sort(char **words, int number_of_words, int size)
sort:
    push ebp
    mov ebp, esp

    ; compare function
    push compare 
    ; int size  
    push dword [ebp+16]
    ; int number_of_words 
    push dword [ebp+12] 
    ; char  **words
    push dword [ebp+8]  

    call qsort
    ; clean up stack
    add esp, 16         

    pop ebp
    ret

; void get_words(char *s, char **words, int number_of_words)
get_words:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi

    ; source string pointer
    mov esi, [ebp+8]
    ; words array pointer
    mov edi, [ebp+12]
    ; number of words to extract
    mov ecx, [ebp+16]
    ; current word count
    xor ebx, ebx        

.next_word:
    ; check if we have extracted enough words
    cmp ebx, ecx
    ; if yes jump to done
    jge .done

.skip_delims:
    ; get current char
    mov al, [esi]
    ; check for null terminator
    test al, al
    jz .done

    ; checks for delimiters(space, comma, period, newline)
    cmp al, ' '
    je .is_delim
    cmp al, ','
    je .is_delim
    cmp al, '.'
    je .is_delim
    ; 10 is ASCII code for newline character
    cmp al, 10          
    je .is_delim
    ; found word of start
    jmp .word_start

.is_delim:
    ;skip the delimiter
    inc esi
    ; comtinue looking for delimiters
    jmp .skip_delims

.word_start:
    ; Store word start address in words array
    mov [edi + ebx*4], esi
    ; increment word count 
    inc ebx

.find_end:
    ; get current char
    mov al, [esi]
    test al, al
    jz .done
    ;check for word ending delimiters
    cmp al, ' '
    je .terminate
    cmp al, ','
    je .terminate
    cmp al, '.'
    je .terminate
    ; 10 is ASCII code for newline character
    cmp al, 10          
    je .terminate

    ; moves to next character
    inc esi
    jmp .find_end

.terminate:
    ; adds null terminator to end of word
    mov byte [esi], 0
    ; Move past delimiter 
    inc esi 
    ; processes next word          
    jmp .next_word

.done:
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret
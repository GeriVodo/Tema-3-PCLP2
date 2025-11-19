section .note.GNU-stack 

section .text
global sort

; struct node* sort(int n, struct node* node)
sort:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi

    ; Get parameters
    ; length of linked list 
    mov ecx, [ebp+8]
    ; node array pointer    
    mov esi, [ebp+12]   

    ; Check for empty list
    test ecx, ecx
    jz .error

    ; Check if n is equal to 1
    cmp ecx, 1
    ; if not 1 start sorting
    jne .start_sort
    ; if 1 , returns the single node
    mov eax, esi
    jmp .end

.start_sort:
    ; Calculate needed stack space 
    mov eax, ecx
    ; binary left shift (multiplies by 4)
    shl eax, 2
    ; copy current stack pointer in ebx 
    mov ebx, esp
    ; moves down the stack pointer
    sub ebx, eax
    ; align to 16 bytes
    and ebx, 0xFFFFFFF0
    ; allocate aligned space
    mov esp, ebx
    ; edi points to the pointer array
    mov edi, esp
    ; saves n(number of nodes)
    push ecx 
    ; get n again
    mov ecx, [ebp+8]
    ; makes eax zero
    xor eax, eax
    ; repeat store string doubleword(fills stack with nulls)
    rep stosd
    ; restore n
    pop ecx             

    ; Scan through all nodes and store their addresses
    ; n
    mov ecx, [ebp+8]
    ; node array pointer  
    mov esi, [ebp+12] 
    ; pointer array  
    mov edi, esp        

.scan_nodes:
    ; get node's value
    mov eax, [esi]
    ; convert to 0-based index
    dec eax
    ; Verify value is within bounds , 1 and n
    cmp eax, [ebp+8]
    jae .error
    ; Store node pointer in array
    mov [edi + eax*4], esi
    ; Move to next node (4 for int value and 4 for next pointer)
    add esi, 8
    loop .scan_nodes

    ; get 1st element (value = 1)
    mov eax, [esp]      
    ; check if NULL
    test eax, eax
    jz .error
    ; gets n
    mov ecx, [ebp+8]
    ; n-1 links needed    
    dec ecx  
    ; pointer to start of sorted node array        
    mov esi, esp 
    ; current node (head of new list)       
    mov edi, eax        

.link_loop:
    ; Get next node in sequence
    ; next node pointer
    mov edx, [esi + 4]  
    ; check if NULL
    test edx, edx
    jz .link_done
    ; Set current node's next pointer
    mov [edi + 4], edx
    ; Move to next node
    mov edi, edx
    ; next array position
    add esi, 4
    loop .link_loop

.link_done:
    ; Set last node's next to NULL
    mov dword [edi + 4], 0

    ; Clean up stack (eax already has the head pointer)
    jmp .end

.end:
    ; Restore stack pointer
    mov esp, ebp
    ; account for saved registers
    sub esp, 12
    pop edi
    pop esi
    pop ebx
    mov esp, ebp
    pop ebp
    ret

.error:
    ; returns null
    xor eax, eax        
    jmp .end
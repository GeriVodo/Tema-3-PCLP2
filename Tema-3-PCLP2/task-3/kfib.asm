section .note.GNU-stack 

section .text
global kfib

; int kfib(int n, int K)
kfib:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi

    ; edi = n (first parameter)
    mov edi, [ebp+8]
    ; esi = K (second parameter)
    mov esi, [ebp+12]

    ; compares n and K
    cmp edi, esi
    ; if n = K return 1
    je .return_one
    ; if n is smaller return 0
    jl .return_zero

    ; check if k = 2
    cmp esi, 2
    jne .general_case

    ; calculates kfib(n-1, 2)
    lea eax, [edi-1]
    push esi
    push eax
    ; recursive call
    call kfib
    ; cleans stack ( 2 args * 4 bytes each)
    add esp, 8
    ; stores result in ebx
    mov ebx, eax

    ; calculates kfib(n-2, 2)
    lea eax, [edi-2]
    push esi
    push eax
    call kfib
    ; clean stack
    add esp, 8
    ; sum results kfib(n-1)+kfib(n-2)
    add eax, ebx
    jmp .done

.general_case:
    ; sum = 0
    xor ebx, ebx
    ; loop counter/ i = 1
    mov ecx, 1

.sum_loop:
    ; eax = n
    mov eax, edi
    ; n-i
    sub eax, ecx

    ; sace loop counter and sum accumulator
    push ecx
    push ebx

    ;push k and n-1
    push esi
    push eax
    call kfib
    ; Clean stack
    add esp, 8

    ; restore sum and counter
    pop ebx
    pop ecx

    ;add result to sum
    add ebx, eax
    ; increment loop counter
    inc ecx
    ; compare i and K
    cmp ecx, esi
    ;jump if i<=k
    jle .sum_loop

    ; move final sum to return register
    mov eax, ebx
    jmp .done

.return_one:
    ; Return value 1 for base case
    mov eax, 1
    jmp .done

.return_zero:
    xor eax, eax

.done:
    pop edi
    pop esi
    pop ebx
    mov esp, ebp
    pop ebp
    ret
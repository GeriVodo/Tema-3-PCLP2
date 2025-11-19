**sortari.asm**

this program sorts a linked list where each node contains an integer value. it allocates an array on the stack to store node pointers, places each node's address in the array at the index corresponding to its value ( node with value 3 stored at array[2]).
links sorted nodes with n-1 links.
it return a pointer to the new head of the sorted list.

**operatii.asm**

this program takes a string of words seperated by delimiters , extracts the words and sorts them first by length then alphabetically for words of equal length and outputs an array of pointers to sorted word.

get_words- scans input string character by character , identifies delimiters and replaces them by null terminators and stores pointers to each word in an output array

compare - compares two words first by length, for equal lengths compares lexicographically and returs -1/0/1 based on the case

sort - prepares the word array for sorting, sorts via qsort.

**kfib.asm**

this function computes the k-step fibonacci sequence where each term is the sum of the previous K terms . it takes two inputs( n- the term to compute and k- the step size). the function checks basic cases , n == k, n < k and k==2 . for k > 2 enters a loop that accumulates the sum of previous k terms.

**composite_palindrome.asm**

1. check_palindrome - checks if a string is a palindrome( reads the same backwards)

compare_loop - takes one char from the start and one from the end, if they match moves both pointer inwards and repeats , if not then its not a palindrome

is_palindrome - returns 1 and jumps to cleanup

not_palindrome - returns 0

done - cleans up and returns eax (result)

2. composite_palindrome - combines multiple strings to find the longest possible palindrome . if multiple combinations have the same length then it returns the one that comes first lexicographically.

//start_processing : 

 - checks if there are no strings (len == 0)

 - calculates the maximum number of possible combinations and stores it

 - initializes variables to track the optimal palindrome found so far(length and string)

// outer_loop : tries every possible combination of strings

 - uses a bitmask (ecx) to represent which strings are included in the current combination

// length_calc_loop : calculates the length of the current string combination

 - for each string, checks if it’s included in the mask (test edx, 1).

 - calls strlen and adds its length to current_length

 - shifts the mask right to check the next string

// skip_string_length : skips strings not included in the current combination

// length_calc_done : decides if it should proceed with building the combined string

 - compares current_length with the best palindrome length 

 - if shorter it skips this combination (because we want the longest/optimal palindrome)

// build_string_loop : combines the selected strings into one

- for each included string:
    copies it into a buffer using strcpy

    updates the buffer pointer (edi) to the end of the string

    skips excluded strings (skip_string_copy)

// skip_string_copy : ignores strings not in the current combination

- advances the mask and index without copying anything

// build_string_done : checks if the combined string is a palindrome

 - calls check_palindrome on the built string: 

    if not a palindrome, jumps to mot_palindrome

    if it is a palindrome, checks if its longer than the current optimal.

// new_optimal : updates the most optimal known palindrome

- if the new palindrome is longer:

    updates optimal_length and optimal_string

 - if the same length but lexicographically smaller:

    updates optimal string

Frees the old best string if it exists (.no_free_needed skips this if null).

// no_free_needed : just a placeholder to jump over free when unnecessary

// not_palindrome : cleans up if the combination isnt a palindrome

- frees allocated memory

// next_iteration : moves to next combination

- increments the bitmask (ecx) and jumps back to outer_loop

// outer_loop_done : checks all combinations and prepares the result

 - if no valid palindrome was found returns an empty string otherwise makes sure that the result is stored

// return_result : returns the final result , restores registers and cleans up stack 


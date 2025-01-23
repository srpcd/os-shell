;[org 0x7c00]
[org 0x7c00]
mov ah, 0x0e

jmp _start

section .bss
	string_buffer resb 12
section .data
	written_txt db 0
	target_cmd db 0
section .text
	global _start
	
	invalid_cmd db 13, 10, "Invalid command", 0
	help_page db "- hlt", 13, 10, "- cls", 13, 10, "- exit", 13, 10, "- help", 0

_print_crlf:
    mov al, 13
    int 0x10
    mov al, 10
    int 0x10
    ret

_cmd_exec:
	cmp byte [target_cmd], 1
	je _help
	cmp byte [target_cmd], 2
	je _cls
	cmp byte [target_cmd], 3
	je _exit
	cmp byte [target_cmd], 4
	je _hlt

_help:
    mov ah, 0x0e
    call _print_crlf
    mov bx, help_page
    call _display_help
    ret

_exit:
    mov ax, 5307h
    mov cx, 3
    mov bx, 1
    int 15h
	call _cmd_follower_hlt
	
_hlt:
    cli
    hlt
	jmp _hlt

_display_help:
    mov al, [bx]
    cmp al, 0
    je _help_ret
    int 0x10
    inc bx
    jmp _display_help

_help_ret:
    ret

_cmd_follower_help:
	mov byte [target_cmd], 1
	ret
	
_cmd_follower_cls:
	mov byte [target_cmd], 2
	ret
	
_cmd_follower_exit:
	mov byte [target_cmd], 3
	ret
	
_cmd_follower_hlt:
	pusha
	mov ah, 0x0E
	mov al, 13
	int 0x10
	mov ah, 0x0E
	mov al, 10
	int 0x10
	popa
	mov byte [target_cmd], 4
	ret
	
_check_hlt:
	cmp word [string_buffer], "hl"
	jne _done
	cmp byte [string_buffer + 2], 't'
	jne _done
	cmp byte [string_buffer + 3], 0
	jne _done
	
	call _cmd_follower_hlt
	jmp _cmd_exec
	
_check_exit:
	cmp word [string_buffer], "ex"
	jne _check_hlt
	cmp word [string_buffer + 2], "it"
	jne _check_hlt
	cmp byte [string_buffer + 4], 0
	jne _check_hlt
	
	call _cmd_follower_exit
	jmp _cmd_exec

_check_cls:
	cmp word [string_buffer], "cl"
	jne _check_exit
	cmp byte [string_buffer + 2], 's'
	jne _check_exit
	cmp byte [string_buffer + 3], 0
	jne _check_exit
	
	call _cmd_follower_cls
	jmp _cmd_exec

_execute_cmd:
	cmp word [string_buffer], "he"
	jne _check_cls
	cmp word [string_buffer + 2], "lp"
	jne _check_cls
	cmp byte [string_buffer + 4], 0
	jne _check_cls
	
	call _cmd_follower_help
	jmp _cmd_exec
	
_done:
    mov bx, invalid_cmd
    call _display_invalid_cmd
    ret

_display_invalid_cmd:
    mov al, [bx]
    cmp al, 0
    je _invalid_cmd_ret
    int 0x10
    inc bx
    jmp _display_invalid_cmd

_invalid_cmd_ret:
    ret

_clear_buffer:
	mov word [written_txt], 0
	mov byte [string_buffer], 0
	mov byte [string_buffer + 1], 0
	mov byte [string_buffer + 2], 0
	mov byte [string_buffer + 3], 0
	mov byte [string_buffer + 4], 0
	mov byte [string_buffer + 5], 0
	mov byte [string_buffer + 6], 0
	mov byte [string_buffer + 7], 0
	mov byte [string_buffer + 8], 0
	mov byte [string_buffer + 9], 0
	mov byte [string_buffer + 10], 0
	mov byte [string_buffer + 11], 0

_add_null_char:
	push bx
	mov bx, [written_txt]
	mov byte [string_buffer + bx + 1], 0
	pop bx
	ret

_input_print_crlf:
	call _add_null_char
	call _execute_cmd
	call _clear_buffer
    call _print_crlf
	call _print_msg
    jmp _input
	
_input_backspace:
	cmp word [written_txt], 0
	je _input

    int 0x10
    mov al, ' '
    int 0x10
    mov al, 8
    int 0x10
	push bx
	mov bx, [written_txt]
	mov byte [string_buffer + bx], al
	pop bx
    dec word [written_txt]
    jmp _input

_print_msg:
    mov al, '>'
    int 0x10
    ret

_input:
    mov ah, 0x00
    int 0x16
    mov ah, 0x0e
    cmp al, 13
    je _input_print_crlf
    cmp al, 8
    je _input_backspace
    int 0x10
	push bx
	mov bx, [written_txt]
	mov byte [string_buffer + bx], al
	pop bx
	inc word [written_txt]
    jmp _input

prompt:
    call _print_crlf
    call _print_msg
    jmp _input

_start:
    cli
    sti
    call _cls
    jmp prompt

_end:
    jmp $

_cls:
    pusha
    mov ah, 0x06
    mov al, 0
    xor bh, bh
    xor cx, cx
    mov dx, 0x184f
    int 0x10
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    popa
    ret
	
_ret:
    ret

times 510-($-$$) db 0
dw 0xaa55

org 0x7c00                      ; define starting point in mem

; constants
video = 0x10
set_cursor_pos = 0x02
write_char = 0x0a

sys_sercives = 0x15
wait_sercive = 0x86

keyboard_int = 0x16
keyboard_read = 0x00
keystroke_status = 0x01

timer_int = 0x1a
read_timer_ctr = 0x00

left_arrow = 0x4b
right_arrow = 0x4d
down_arrow = 0x50
up_arrow = 0x48
space_btn = 0x39


; **********  variables **********
pos_row: db 15
pos_col: db 1
scan_code: db 0
write_mode: db 1


; begin game loop
start:
    ; get pressed key
    call handle_keyboard

    ; check for write mode
    cmp byte [scan_code], space_btn
    jne check_left_arrow
    cmp byte [write_mode], 1
    jne write_mode_on
write_mode_off:
    mov byte [write_mode], 0
    call handle_keyboard
    jmp check_left_arrow
write_mode_on:
    mov byte [write_mode], 1
    call handle_keyboard
    jmp check_left_arrow

    ; possibly update cursor pos
check_left_arrow:
    cmp byte [scan_code], left_arrow
    jne check_right_arrow
    dec byte [pos_col]      ; move cursor left
    jmp move
check_right_arrow:
    cmp byte [scan_code], right_arrow
    jne check_up_arrow
    inc byte [pos_col]      ; move cursor up
    jmp move
check_up_arrow:
    cmp byte [scan_code], up_arrow
    jne check_down_arrow
    dec byte [pos_row]      ; move cursor up
    jmp move
check_down_arrow:
    cmp byte [scan_code], down_arrow
    jne start
    inc byte [pos_row]      ; move cursor down


move:
    ; set (updated) cursor pos
    mov ah, set_cursor_pos
    mov dh, [pos_row]       ; row
    mov dl, [pos_col]       ; col
    mov bh, 0               ; page
    int video

    ; write character (only in write mode) at curr cursor pos
    cmp byte [write_mode], 1
    jne end_start
    mov ah, write_char
    mov bh, 0               ; page
    mov cx, 1               ; num of chars to write
    mov al, '#'             ; char to write (snake)
    int video

end_start:

    mov byte [scan_code], 0

    jmp start

; some other key beside the arrows is pressed
failure:
    jmp $

; ********** functions **********
; writes keycode in scan_code
handle_keyboard:
    mov ah, keystroke_status
    int keyboard_int
    jz end_handle_keyboard; no code (key) available
    mov ah, keyboard_read
    int keyboard_int
    mov [scan_code], ah
    end_handle_keyboard:
    ret


times 510 - ($ - $$) db 0       ; fill the remaining bytes (512 bytes bootloader) with 0
dw 0xaa55                       ; magic number (end of bootloader)
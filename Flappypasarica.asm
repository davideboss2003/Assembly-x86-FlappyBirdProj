.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Flappy bird",0
area_width EQU 1000
area_height EQU 600
area DD 0

counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20
arg5 EQU 20
arg6 EQU 20

symbol_width EQU 10
symbol_height EQU 20
state_height EQU 13
state_width EQU 17
pasarica_length EQU 40
include digits.inc
include letters.inc
include pasarica.inc
include starimatrix.inc
.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_bird proc
	push ebp
	mov ebp, esp
	pusha
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, '0'
	jl patrat_gol
	cmp eax, '1'
	jg patrat_gol
	lea esi, pasarica
	jmp draw_bird
patrat_gol: 
	mov eax, 2
	lea esi pasarica
draw_bird:
	mov ebx, pasarica_length
	mul ebx
	mov ebx, pasarica_length
	mul ebx
	add esi, eax
	mov ecx, pasarica_length
bucla_pasarica_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, pasarica_length
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, pasarica_length
bucla_pasarica_coloane:
	cmp byte ptr [esi], 0 ;verifica daca e pixel gri
	je block_pixel_gri
	cmp byte ptr [esi], 2 ;verifica daca e pixel maro
	je block_pixel_maro
	cmp byte ptr [esi], 3 ;verifica daca e pixel albastru
	je block_pixel_albastru
	cmp byte ptr [esi], 4 ;verifica daca e pixel rosu
	je block_pixel_rosu
	cmp byte ptr [esi], 5 ;verifica daca e pixel crem
	je block_pixel_crem
	mov dword ptr [edi], 0
	jmp simbol_pasarica_pixel_next
block_pixel_gri:
	mov dword ptr [edi], 0c0c0c0h
	jmp simbol_pasarica_pixel_next
block_pixel_maro:
	mov dword ptr [edi], 0B22222h
	jmp simbol_pasarica_pixel_next
block_pixel_albastru:
	mov dword ptr [edi], 0000080h
	jmp simbol_pasarica_pixel_next
block_pixel_rosu:
	mov dword ptr [edi], 08B0000h
	jmp simbol_pasarica_pixel_next
block_pixel_crem:
	mov dword ptr [edi], 0FFDAB9h
	jmp simbol_pasarica_pixel_next
	mov dword ptr [edi], 0
	jmp simbol_pasarica_pixel_next	
simbol_pasarica_pixel_next:
	inc esi
	add edi, 4
	loop bucla_pasarica_coloane
	pop ecx
	loop bucla_pasarica_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_bird endp
make_bird_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_bird
	add esp, 16
endm



state_matrix proc
; functie pt parcurgere a matricii de stare
push ebp
mov ebp, esp
pusha
lea esi, state
add esi, eax
mov ecx, state_height
mov ebx, 0
mov edi, 0
bucla_state_linii:
push ecx
mov ecx, state_width
bucla_state_coloane:
cmp byte ptr [esi],0
je contur
cmp byte ptr [esi], 1
je scara
make_bird_macro '0', area, ebx, edi
jmp continue
scara:
make_bird_macro '1', area, ebx, edi
jmp continue
contur:
make_bird_macro '0', area, ebx, edi
jmp continue
continue:
    add ebx, 40 
    inc esi
    loop bucla_state_coloane
    pop ecx
    mov ebx, 0
    add edi, 40
    loop bucla_state_linii
    popa
    mov esp, ebp
    pop ebp
    ret
state_matrix endp

state_matrix_macro macro 
    call state_matrix
endm




















make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp


; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm






; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255 
	push area
	call memset
	add esp, 12
	
	;desenez lina verde
	;draw_green_line_macro  area 120, 450  sau aici??
	; afisam solul	color_ground area, area_width, area_height
	
	jmp afisare_litere
	
evt_click:

	jmp afisare_litere
	
evt_timer:
	inc counter
	;rep stosd 
afisare_litere:

	make_bird_macro 0, area, 200,200
	state_matrix_macro  
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start

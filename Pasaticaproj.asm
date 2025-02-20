.586
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


var_pasare_i db 1
score DD 0
game_over db 0
counter DD 0 ; numara evenimentele de tip timer
counterOK DD 0

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16		
arg4 EQU 20
arg5 EQU 20
arg6 EQU 20


pasare_i DD 40
pasare_j DD 256
pasare_kaput dd 0
miscare DD 0

lungime_misc EQU 16

symbol_width EQU 10
symbol_height EQU 20
state_height EQU 13
state_width EQU 17
pasarica_length EQU 40
block_length EQU 40



include digits.inc
include starimatrix.inc
include letters.inc
include pasarica.inc


button_x EQU 740 
button_y EQU 200 
button_size EQU 80



.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y





make_bird proc
	;functie pt desenat patrate
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	
	lea esi, pasarica
	jmp draw_block
make_empty:	
	mov eax, 0 ; pe pozitia 0 e gol
	lea esi, pasarica
	
draw_block:
	mov ebx, block_length
	mul ebx
	mov ebx, block_length
	mul ebx
	add esi, eax
	mov ecx, block_length
bucla_block_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, block_length
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, block_length
bucla_block_coloane:
	cmp byte ptr [esi], 0 ;verifica daca e pixel fundal
	je block_pixel_fundal
	cmp byte ptr [esi], 2 ;verifica daca e pixel maro
	je block_pixel_verde
	cmp byte ptr [esi], 3 ;verifica daca e pixel albastru
	je block_pixel_maro
	cmp byte ptr [esi], 4 ;verifica daca e pixel rosu
	je block_pixel_stalp
	cmp byte ptr [esi], 5 ;verifica daca e pixel gold
	je block_pixel_pietricele
	mov dword ptr [edi], 0FFBF00h
	jmp block_pixel_next
block_pixel_fundal:
	mov dword ptr [edi], 077BCE9h
	jmp block_pixel_next
block_pixel_verde:
	mov dword ptr [edi], 0529C4Ah
	jmp block_pixel_next
block_pixel_maro:
	mov dword ptr [edi], 0800020h
	jmp block_pixel_next
block_pixel_stalp:
	mov dword ptr [edi], 036454Fh
	jmp block_pixel_next
block_pixel_pietricele:
	mov dword ptr [edi], 0E97451h
	jmp block_pixel_next
block_pixel_next:
	inc esi
	add edi, 4
	loop bucla_block_coloane
	pop ecx
	loop bucla_block_linii
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
    ;functie pt parcurgere a matricii de stare
    push ebp
    mov ebp, esp
    pusha

    lea esi, state
	add esi,  miscare
    mov ecx, state_height
    mov ebx, 0
    mov edi, 39
bucla_state_linii:
    push ecx
    mov ecx, lungime_misc
bucla_state_coloane:
    cmp byte ptr [esi], 0
    je caramida
    cmp byte ptr [esi], 1
    je stalp
    make_bird_macro 2, area, ebx, edi
    jmp continue
stalp:
    make_bird_macro 1, area, ebx, edi
    jmp continue
caramida:
    make_bird_macro 0, area, ebx, edi
    jmp continue
continue:
    add ebx, 40 
    inc esi
    loop bucla_state_coloane
    pop ecx
    mov ebx, 0
    add edi, 40
	add esi, state_width
	sub esi , lungime_misc
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

linie_horizontal macro x, y, len, color
	local bucla_linie
	 mov eax, y ;EAX =y
	 mov ebx, area_width
	 mul ebx; EAX=y*area_width 
	 add eax, x;EAX=y*area_width +X
	 shl eax, 2 ;EAX=(y*area_width +x)*4
	 add eax, area
	 mov ecx, len
bucla_linie:
	 mov dword ptr[eax], color
	 add eax, 4
	 loop bucla_linie
endm


linie_vertical macro x, y, len, color
	local bucla_linie
	 mov eax, y ;EAX =y
	 mov ebx, area_width
	 mul ebx; EAX=y*area_width 
	 add eax, x;EAX=y*area_width +X
	 shl eax, 2 ;EAX=(y*area_width +x)*4
	 add eax, area
	 mov ecx, len
bucla_linie:
	 mov dword ptr[eax], color
	 add eax, area_width * 4
	 loop bucla_linie
endm


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
	push 0
	push area
	call memset
	add esp, 12
	

	
	jmp afisare_litere





	
evt_click:
cmp game_over,1
	je final_draw
	
	; linie_horizontal [ebp+arg2], [ebp+arg3], 100, 0FFh
	; linie_vertical [ebp+arg2], [ebp+arg3], 100, 0FFh
	mov eax, [ebp+arg2]
	cmp eax, button_x
	jl button_fail
	cmp eax, button_x + button_size
	jg button_fail
	mov eax, [ebp+arg3]
	cmp eax, button_y
	jl button_fail
	cmp eax, button_y + button_size
	jg button_fail
	;s-a dat click in buton
	mov eax, score
	inc score
	cmp pasare_i, 640
	je final_draw
	sub pasare_j, 40
	
	make_text_macro '0', area, button_x +button_size/2 - 5 , button_y + button_size + 10
	make_text_macro 'K', area, button_x +button_size/2 + 5 , button_y + button_size + 10
	jmp afisare_litere
	
button_fail:
	make_text_macro ' ', area, button_x +button_size/2 - 5 , button_y + button_size + 10
	make_text_macro ' ', area, button_x +button_size/2 + 5 , button_y + button_size + 10
	jmp afisare_litere
	
evt_timer:
cmp game_over,1
	je final_draw
	
	inc var_pasare_i;
	cmp var_pasare_i,18
	jnz nu
	mov var_pasare_i,0
	nu:
	inc counter
	add pasare_j, 5
	mov ebx, miscare
	add ebx, lungime_misc
	mov ebp, state_width
	sub ebp, 1
	cmp ebx, ebp
	
	
    mov esi, offset state 
	mov edx,0
	mov eax,pasare_j
	mov ecx,40
	div ecx
	mov ecx,state_width
	mul ecx
	add esi,eax 
	mov ecx,0
	mov cl,var_pasare_i
	add esi,ecx
	
	cmp dword ptr[esi], 2
	je sf_sf
	
	 cmp pasare_j, 382
	 jge sf_sf               
	jne incrementare
	
	
	sf_sf:
	make_text_macro 'G', area, 300, 200
	make_text_macro 'A', area, 310, 200
	make_text_macro 'M', area, 320, 200
	make_text_macro 'E', area, 330, 200
	make_text_macro ' ', area, 340, 200
	make_text_macro 'O', area, 350, 200
	make_text_macro 'V', area, 360, 200
	make_text_macro 'E', area, 370, 200
	make_text_macro 'R', area, 380, 200
	;jmp afisare_litere
	mov game_over,1
	jmp final_draw
	 
	 jmp afisare_litere
	 
	 
incrementare:
	inc miscare
	jmp afisare_litere


afisare_litere:
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 30, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 20, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	
afisare_scor:
	mov ebx, 10
	mov eax, score
;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area , 263, 16
;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area , 253, 16
;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area , 243, 16
	
	make_text_macro edx, area, 10, 10
	
	;scriem un mesaj
	make_text_macro 'F', area, 720, 55
	make_text_macro 'L', area, 730, 55
	make_text_macro 'A', area, 740, 55
	make_text_macro 'P', area, 750, 55
	make_text_macro 'P', area, 760, 55
	make_text_macro 'Y', area, 770, 55
	
	
	make_text_macro 'P', area, 800, 55
	make_text_macro 'A', area, 810, 55
	make_text_macro 'S', area, 820, 55
	make_text_macro 'A', area, 830, 55
	make_text_macro 'R', area, 840, 55
	make_text_macro 'I', area, 850, 55
	make_text_macro 'C', area, 860, 55
	make_text_macro 'A', area, 870, 55
	
	make_text_macro 'Y', area, 103, 16
	make_text_macro 'O', area, 113, 16
	make_text_macro 'U', area, 123, 16
	make_text_macro 'R', area, 133, 16
	make_text_macro ' ', area, 143, 16
	make_text_macro 'S', area, 153, 16
	make_text_macro 'C', area, 163, 16
	make_text_macro 'O', area, 173, 16
	make_text_macro 'R', area, 183, 16
	make_text_macro 'E', area, 193, 16
	make_text_macro ' ', area, 203, 16
	make_text_macro 'I', area, 213, 16
	make_text_macro 'S', area, 223, 16
	
	linie_horizontal button_x, button_y, button_size, 0FFh
	linie_horizontal button_x, button_y + button_size, button_size, 0FFh
	linie_vertical button_x, button_y, button_size, 0FFh
	linie_vertical button_x + button_size, button_y, button_size, 0FFh
	
	state_matrix_macro  
	;pasare_x = x0 (0) + pasarewidth*j
	make_bird_macro 3, area, pasare_i, pasare_j 
	
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

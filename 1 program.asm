; File changes  capital letter to lower letters or lower letters to capital



.model small
.stack 100h
.data
	buferis db 255,256 dup ('$') ; vieta kurioje talpinsime ivestas raides
	hello db 'Iveskite 8 didziasias ar mazasias raides: $' ;žinutė iššokanti iš pat pradžių
	rezultatas db 'Apkeistos raides: $' ; rezultato žinutė
	klaida db 'tai ne raides $'
	enteris db 13,10,'$' ; nauja eilute     
	ilgis db '(ilgis $'
	skliaustelis db ')$'  
.code 
; privalomos eilutės
	Mov ax, @data ; pasakom kur randasi kintamieji
	Mov ds, ax ; š AX į DS perkeliam data segment'o adresą 

; isvedame hello žinutę į ekraną
	mov ah, 9
	mov dx, offset hello
	int 21h
; vykdome nuskaitymą 
	mov ah, 0Ah
	mov dx, offset buferis
	int 21h
; pereinam i kitą eilutę spausdindami 
	mov ah, 9
	mov dx, offset enteris 
	int 21h
    
    
    
      
    mov si, 2
Ciklas:
	Mov bl, [buferis+si]
	cmp bl, 13d
	je  Spausdinimas
    cmp bl, 41h
	jb klaida1
	cmp bl,5Bh
	je klaida1
	cmp bl, 5Ch
	je klaida1
	cmp bl, 5Dh
	je klaida1
	cmp bl, 5Eh
	je klaida1 
	cmp bl, 5Fh
	je klaida1
	cmp bl, 60h
	je klaida1
	cmp bl, 7Ah
	ja klaida1
	cmp bl, 61h
	jae mazoji 
	cmp bl, 5Ah
	jb didzioji
	
Klaida1:
	mov ah, 09h
	mov dx, offset klaida
	int 21h
	jmp pabaiga
Didzioji:
	Add bl, 20h
	mov bh,0
	mov [buferis+si], bl
	;push bx
    inc si
	jmp ciklas
Mazoji:
	Sub bl, 20h
	mov bh,0   
	mov [buferis+si], bl  
	inc si
	jmp ciklas
Spausdinimas:    
	mov ah, 9h
	mov dx, offset rezultatas
	int 21h    
	mov si,2
Spausdinimas1:                                                                                                                                                                                                                  
	mov dl, [buferis+si]                   
	cmp dl, 13d                            	                                                                  
	je skaicius                            	                                       
	mov ah, 02h                            
	mov dl, [buferis+si]                   
	int 21h                                
	inc si                                 
    jmp spausdinimas1                      
   skaicius:
    mov ah, 9h
    mov dx,offset ilgis 
    int 21h       
 mov dx,0 
 mov ax,0         
 mov dl,[buferis+1]
 cmp dl,10         
 jae dvizenklis    
 add dl,30h         
 jmp spausdinti2      
  dvizenklis:      
mov al,dl
mov bl,10         
div bl               
add al,30h         
mov dl,al 
mov ah, 02h 
int 21h
add ah,30h   
mov dl,0
mov dl,ah
mov ah, 02h 
int 21h 
mov dx,0
mov ah,0
mov ah,9
mov dx,offset skliaustelis  
int 21h 
jmp pabaiga   
Spausdinti2:
         
mov ah, 02h 
int 21h       
mov dl,ah          
mov ah, 02h
mov dx,0
mov ah,0        
mov ah,9
mov dx,offset skliaustelis  
int 21h                                                                                                                                  
Pabaiga:
mov ax, 4c00h
int 21h
End

; Program changes 1 -> vienas (one) 2 -> du (two) and so on
; It also scans given file and puts all the changed material into another file
; 2 program.asm filename1.txt filename2.txt
; filename1 - the file that contains an information
; filename2 - the file that will contain changed information


.MODEL small
.STACK 100h
skBufDydis	EQU 255		
raBufDydis	EQU 255			
.DATA
;-------------Duomenu failai---------
	inputFile db 255 dup (0)			;failo pavadinimam 
	outputFile db 255 dup (0)  			; rezultato failui
	pagalba db "Pagalbos pranesimas", 10, 13, "$" 
	klaidaas db "ivesta per daug skaiciu", 10, 13, "$" 
;-------------Bufferiai, skirti darbui------
	bufferis db skBufDydis dup ("$")
	raBufferis db raBufDydis dup (0) 
;-------------Kiti reikalingi kintamieji----
	duomFailDeskriptorius dw ?          
	rezFailDeskriptorius dw ?            
	symbCount dw 0
	rezCount db 0 
    
	vienas123 db 'vienas'  
	du123 db 'du'
	trys123 db 'trys'

.CODE
	Pradzia:
		MOV ax, @data
		MOV ds, ax  
		
;Skaitomas ir apdorojamas parametras
	;ES:80h - adresas, kuriame prasideda parametras
	MOV cl, byte ptr es:[80h]	;Parametro simboliu skaicius randasi siame adrese
	MOV ch, 00h
	ADD cl, 81h                 ; pridedam 81h ir zinom adresa paskutinio symbolio(kurioj vietoj stovi paskutinis simbolis)
	MOV bx, 81h                 ; pirmo simbolio adresas
	LEA si, inputFile			; inputFile adresas
	MOV dh, 20h				
  Parametrai:
	CMP bx, cx				;Tikriname, ar BX LYGUS cx ir tada reiks, kad nuskaitem abu failus
	Je Nuskaityta
	INC bx                      ; praleidzia tarpa 82h
	MOV ah, byte ptr es:[bx]	;Parametro ASCII simbolis perkeliamas i AH
	MOV [si], ah                ; idedam i inputFile buferi
	INC si                      ; imam kita nari ir ziurim ar jis ne tarpas(jei tarpas tai kitas parametras)
	MOV ah, es:[bx + 1]
	CMP ah, dh
    JNE Parametrai
	INC bx				
	MOV dh, 0Dh					
	LEA si, outputFile
	JMP Parametrai
	
  Nuskaityta:		
; duomenu failo atidarymo procedura
	MOV ah, 3Dh                 ;DOS pertraukimas atidarantis faila
	MOV al, 00					; skaitymui
	MOV dx, offset inputFile   ;I dx isidedame adresa pirmojo duomenu failo
	INT 21h                     ;Kvieciame interrupta
	JNC	NeraKlaida                ;Jeigu carry flagas = 0 sokame i NeKlaida
	JMP KlaidosKodas            ;Jeigu ivyksta klaida, sokame isvesti pagalbos pranesima
		
  NeraKlaida:
	MOV duomFailDeskriptorius, ax           ;I deskriptoriaus numeri irasome ax
	
;Rezultato failo sukurimas ir atidarymas rasymui
	MOV ah, 3Ch               ;DOS pertraukimas sukuriantis rezultatu faila
	MOV cx, 0				  ; tuscias failas
	MOV dx, offset outputFile
	INT 21h
	JNC	NeraKlaida2
	JMP KlaidosKodas

  NeraKlaida2:
	MOV rezFailDeskriptorius, ax
	
;Duomenu nuskaitymo pradzia is fail
  Skaitymas:
	MOV bx, duomFailDeskriptorius
	LEA	dx, bufferis	;vieta, i kuria irasoma nuskaityta informacija
	CALL Nuskaitymas            ;kvieciame procedura, kuri ivykdo nuskaityma
	MOV symbCount, ax           ;i symbCount isidedame kiek nuskaiteme simboliu
	MOV si, 0                   ;nunuliname registrus, kuriuos naudosime
	MOV bx, 0 
	MOV di, 0
	
Ciklas:

    CMP symbCount,si
    je rasymas
	
    MOV ax, 0
    MOV dx, 0
    MOV al, [bufferis+si]
    CMP al,31h             ;i al isimetame nuskaityta simboli                                                  
    JE vienas1
    CMP al,32h
    JE du1
    CMP al, 33h
    JE trys1
    CMP al,34h
    JE keturi1
    CMP al,35h
    JE penki1
    CMP al,36h
    JE sesi1
    CMP al,37h
    JE septyni1
    CMP al,38h
    JE astuoni1
    CMP al,39h
    JE devyni1
    call tapati                     
    JMP Ciklas
    
    
    
    Rasymas:
    mov symbCount,di
	MOV	bx, rezFailDeskriptorius			;i bx irasom rezultato failo deskriptoriaus numeri
	CALL rasykBuf           ;kvieciame rasymo i bufferi procedura
	JMP uzdarytiRasymui 
	
	vienas1:
	JMP Vienas
	du1:
	JMP du
	trys1:
	JMP trys
	keturi1:
	JMP keturi
	Penki1:
	JMP penki
	Sesi1:
	JMP sesi
	septyni1:
	JMP septyni
	astuoni1:
	JMP astuoni
	devyni1:
	JMP devyni
	
	Vienas:
	
	 mov dl,[vienas123+bx]	 
	 mov [rabufferis+di],dl
	 inc bx
	 inc di
	 cmp dl, 's'
	 JNE vienas
	 inc si
	 mov bx,0     	 
	 JMP Ciklas
	Du:
	 mov dl,[du123+bx] 
	 mov [rabufferis+di],dl 
	 inc di 
	 inc bx
	 cmp dl,'u'
	 Jne Du
	 inc si
	 mov bx,0
	 JMP Ciklas
	Trys:
	  mov dl,[trys123+bx]  
	  mov [rabufferis+di],dl 
	 inc di 
	 inc bx
	 cmp dl,'s'
	 Jne trys
	 mov bx,0
	 inc si
	 JMP Ciklas
	Keturi:
	  mov [rabufferis+di],'k' 
	 inc di
	  mov [rabufferis+di],'e' 
	 inc di
	  mov [rabufferis+di],'t' 
	 inc di
	  mov [rabufferis+di],'u' 
	 inc di
	  mov [rabufferis+di],'r' 
	 inc di
	  mov [rabufferis+di],'i' 
	 inc di
	 inc si
	 JMP Ciklas
	Penki:
	  mov [rabufferis+di],'p' 
	 inc di
	  mov [rabufferis+di],'e' 
	 inc di
	  mov [rabufferis+di],'n' 
	 inc di
	  mov [rabufferis+di],'k' 
	 inc di
	  mov [rabufferis+di],'i' 
	 inc di
	 inc si
	 JMP Ciklas
	sesi:
	 mov [rabufferis+di],'s' 
	 inc di
	  mov [rabufferis+di],'e' 
	 inc di
	  mov [rabufferis+di],'s' 
	 inc di
	  mov [rabufferis+di],'i' 
	 inc di
	 inc si
	 JMP ciklas
	 septyni:
	 mov [rabufferis+di],'s' 
	 inc di
	  mov [rabufferis+di],'e' 
	 inc di
	  mov [rabufferis+di],'p' 
	 inc di
	  mov [rabufferis+di],'t' 
	 inc di
	  mov [rabufferis+di],'y' 
	 inc di
	  mov [rabufferis+di],'n' 
	 inc di
	  mov [rabufferis+di],'i' 
	 inc di
	 inc si
	 JMP Ciklas
	astuoni:
	 mov [rabufferis+di],'a' 
	 inc di
	  mov [rabufferis+di],'s' 
	 inc di
	  mov [rabufferis+di],'t' 
	 inc di
	  mov [rabufferis+di],'u'
	 inc di
	  mov [rabufferis+di],'o' 
	 inc di
	  mov [rabufferis+di],'n' 
	 inc di
	  mov [rabufferis+di],'i' 
	 inc di
	 inc si
	 JMP Ciklas
	devyni:
	 mov [rabufferis+di],'d' 
	 inc di
	  mov [rabufferis+di],'e' 
	 inc di
	  mov [rabufferis+di],'v' 
	 inc di
	  mov [rabufferis+di],'y' 
	 inc di
	  mov [rabufferis+di],'n' 
	 inc di
	  mov [rabufferis+di],'i' 
	 inc di
	 inc si
	 JMP Ciklas 
 Proc tapati
	MOv [rabufferis+di],al
	inc si
	inc di
	JMP ciklas
ENdp tapati                                                       
	          	
			
;*****************************************************
;Rezultato failo uzdarymas
;*****************************************************
  uzdarytiRasymui: 
  
	MOV	ah, 3Eh				    ;21h pertraukimo failo uzdarymo funkcijos numeris
	MOV	bx, rezFailDeskriptorius			    ;i bx irasom rezultato failo deskriptoriaus numeri
	INT	21h				        ;failo uzdarymas
	JC	KlaidosKodas	        ;jei uzdarant faila ivyksta klaida, nustatomas carry flag
	JMP pabaiga	
;*****************************************************
;Duomenu failo uzdarymas
;*****************************************************
  uzdarytiSkaitymui:
	MOV	ah, 3Eh				    ;21h pertraukimo failo uzdarymo funkcijos numeris
	MOV	bx, duomFailDeskriptorius ;i bx irasom duomenu failo deskriptoriaus numeri
	INT	21h				        ;failo uzdarymas
	JC	KlaidosKodas		    ;jei uzdarant faila ivyksta klaida, nustatomas carry flag
	
  Pabaiga:
	MOV	ah, 4Ch				;reikalinga kiekvienos programos pabaigoj
	MOV	al, 0				;reikalinga kiekvienos programos pabaigoj
	INT	21h				    ;reikalinga kiekvienos programos pabaigoj
	
 KlaidosKodas:
    MOV ah, 9
	MOV dx, offset pagalba		;i dx idemdame pagalbos eilutes adresa
	INT	21h			            ;kvieciame pertraukima
	JMP Pabaiga	

;*****************************************************
;Procedura nuskaitanti informacija is pirmojo failo
;*****************************************************
PROC Nuskaitymas
	
	MOV	cx, skBufDydis		    ;cx - kiek baitu reikia nuskaityti is failo
	
	MOV	ah, 3Fh			        ;21h pertraukimo duomenu nuskaitymo funkcijos numeris
	INT	21h			            ;skaitymas is failo
	JC	klaidaSkaitant		    ;jei skaitant is failo ivyksta klaida, nustatomas carry flag  
	
  SkaitykBufPabaiga:
	RET

  klaidaSkaitant:
	MOV ax, 0			        ;Pazymime registre ax, kad nebuvo nuskaityta nei vieno simbolio
	JMP	SkaitykBufPabaiga
Nuskaitymas ENDP
;******************************************************

;*****************************************************
;Procedura, irasanti buferi i faila
;*****************************************************
PROC RasykBuf 
    
	MOV	ah, 40h			        ;21h pertraukimo duomenu irasymo funkcijos numeris
	MOV	dx, offset raBufferis	;vieta, is kurios rasom i faila
	mov cx,symbCount
	INT	21h			            ;rasymas i faila
	JC	klaidaRasant		    ;jei rasant i faila ivyksta klaida, nustatomas carry flag 
	RET
klaidaRasant:
	MOV ah, 9
	MOV dx, offset klaidaas		;i dx idemdame pagalbos eilutes adresa
	INT	21h			            ;kvieciame pertraukima
	JMP Pabaiga	
RasykBuf ENDP
;*******************************************************
	

END pradzia

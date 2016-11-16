;Sistemas Digitais 2 2/2016
;Lucas Nascimento Santos Souza 14/0151010

;;;Experimento Bonus
;Calculadora aritmetica de ateh 4 digitos BCD, operando com
;a Notacao Polonesa Reversa (RPN - Reverse Polish Notation)

$MOD51

ORG 0

;;;Representacao Numerica
;A representacao utilizada eh 4 digitos BCD, por isso sao validos os numeros de 0 ateh 9.999.
;Considerando o sinal, os possiveis valores vao desde -9.999 ateh +9.999.
;As operacoes sao inteiras, com precisao de 4 digitos BCD.

SINAL_X   BIT   20H.0     ;bit = 0 -> positivo, bit = 1 -> negativo
SINAL_Y   BIT   20H.1     ;bit = 0 -> positivo, bit = 1 -> negativo
SINAL_Z   BIT   20H.2     ;bit = 0 -> positivo, bit = 1 -> negativo
SINAL_T   BIT   20H.3     ;bit = 0 -> positivo, bit = 1 -> negativo

;;;Condicoes Anormais
;Como condicao anormal, consideremos a operacao invalida (divisao por zero) e a ultrapassagem (overflow).
;A ultrapassagem ocorre quando o valor absoluto do resultado de uma operacao for maior que 9.999.
;Ela ocorre tambem quando o usuario tenta digitar um numero de mais de 4 digitos.
;Quando ocorrer uma dessas condicoes, a calculadora sinaliza o problema e para em um loop infinito.

ERRO      BIT   20H.4     ;bit = 0 -> OK, bit = 1 -> erro
OVFL      BIT   20H.5     ;bit = 0 -> OK, bit = 1 -> overflow

;;;Reserva de Espaco na RAM interna
AUX3H     EQU   21H       ;MSB AUXILIAR 3
AUX3L     EQU   22H       ;LSB AUXILIAR 3
AUX4H     EQU   23H
AUX4L     EQU   24H
AUX5H     EQU   25H
AUX5L     EQU   26H

XH        EQU   30H 			;HIGH X
XL        EQU   31H 			;LOW X
YH        EQU   32H 			;Y
YL        EQU   33H 			;Y
ZH        EQU   34H 			;Z
ZL        EQU   35H 			;Z
TH        EQU   36H			  ;T
TL        EQU   37H 			;T
MEMH      EQU   38H 		  ;MEMORIA PARA STO E RCL
MEML      EQU   39H 		  ;MEMORIA PARA STO E RCL

AUX1H     EQU   3AH 	    ;MSB AUXILIAR 1
AUX1L     EQU   3BH 	    ;LSB AUXILIAR 1
AUX2H     EQU   3CH
AUX2L     EQU   3DH

F_INI     EQU   40H     	;Inicio da fila

;;;Codigos das Teclas
CHS       EQU   0AH   		;Mudar sinal de X
CLX       EQU   0BH 	   	;Zerar X
CLS       EQU   0CH 	   	;Zerar a pilha (Clear Stack)
ENTER     EQU   0DH 	    ;"Enter" (PUSH)
DROP      EQU   0EH 		  ;POP
SWAPI     EQU   0FH 		  ;Trocar X e Y
MAIS      EQU   10H 		  ;Y+X
MENOS     EQU   11H 	    ;Y-X
MULT      EQU   12H 		  ;Y*X
DIVI      EQU   13H 		  ;Y/X
MODUL     EQU   14H 	    ;Módulo de Y/X (Resto da divisao)
RRX       EQU   15H 		  ;Rodar Direita
RLX       EQU   16H 		  ;Rodar Esquerda
SRX       EQU   17H 		  ;Shift Direita
SLX       EQU   18H 		  ;Shift Esquerda
QUAD      EQU   19H 		  ;X*X
POW       EQU   1AH 		  ;Y^X
RSUP      EQU   1BH 		  ;Rodar pilha para cima
RSDW      EQU   1CH 	    ;Rodar pilha para baixo
STO       EQU   1DH 		  ;Armazenar X na memoria
RCL       EQU   1EH 		  ;Copiar a memoria para X
T_INV     EQU   0FFH 	    ;Tecla invalida

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;Inicializacao
INIT:
    ;Zerando as quatro posicoes da pilha, do topo ao final
    MOV XH, #0H
    MOV XL, #0H

    MOV YH, #0H
    MOV YL, #0H

    MOV ZH, #0H
    MOV ZL, #0H

    MOV TH, #0H
    MOV TL, #0H

    MOV R0, #F_INI        ;R0 = endereco inicial da fila

    MOV R6, #0H           ;Contador = 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;Carregar Fila
;Operacao a ser executada na calculadora
CARREGAR_FILA:
    ;Calculo do slide
    ; MOV 40H, #04          ;4
    ; MOV 41H, #02          ;2
    ; MOV 42H, #0DH         ;ENTER
    ; MOV 43H, #03          ;3
    ; MOV 44H, #05          ;5
    ; MOV 45H, #04          ;4
    ; MOV 46H, #10H         ;+
    ; MOV 47H, #0FFH        ;T_INV

    ;Teste do recebimento dos numeros
    ; MOV 40H, #03          ;3456
    ; MOV 41H, #04
    ; MOV 42H, #05
    ; MOV 43H, #06
    ; MOV 44H, #0FFH

    ;Teste subtracao
    ; MOV 40H, #05          ;57 - 37
    ; MOV 41H, #07
    ; MOV 42H, #0DH
    ; MOV 43H, #03
    ; MOV 44H, #07
    ; MOV 45H, #11H
    ; MOV 46H, #0FFH

    ;Teste multiplicacao
    ; MOV 40H, #05          ;50 * 9
    ; MOV 41H, #00
    ; MOV 42H, #0DH
    ; MOV 43H, #09
    ; MOV 44H, #12H
    ; MOV 45H, #0FFH

    ;Teste quadrado
    ; MOV 40H, #05          ;5²
    ; MOV 41H, #19H
    ; MOV 42H, #0FFH

    ;Teste divisao
    ; MOV 40H, #02          ;24 / 12
    ; MOV 41H, #04
    ; MOV 42H, #0DH
    ; MOV 43H, #01
    ; MOV 44H, #02
    ; MOV 45H, #13H
    ; MOV 46H, #0FFH

    ;Teste modulo
    ; MOV 40H, #01          ;10 / 4
    ; MOV 41H, #00
    ; MOV 42H, #0DH
    ; MOV 43H, #04
    ; MOV 44H, #14H
    ; MOV 45H, #0FFH

    ;Teste potencia
    MOV 40H, #02          ;2 ^ 4
    MOV 41H, #0DH
    MOV 42H, #04
    MOV 43H, #1AH
    MOV 44H, #0FFH

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;Ler Fila
;Le o primeiro elemento da fila e executa a subrotina correspondente a este elemento,
;le o proximo elemento da fila, repetindo o processo ate encontrar uma T_INV.
LER_FILA:
    MOV A, @R0            ;A = conteudo do endereco atual da fila

    INC R0                ;Passa para o proximo endereco da fila

;;;Verifica se eh uma tecla invalida
CHECAR_T_INV:
    CJNE A, #T_INV, CHECAR_CHS   ;Se A != T_INV, checar se a proxima tecla foi pressionada
    LCALL TECLA_INVALIDA         ;Se A == T_INV, executa a operacao
    MOV R6, #0H                  ;Contador = 0
    JMP LER_FILA

;;;Switch case das operacoes
CHECAR_CHS:
    CJNE A, #CHS, CHECAR_CLX     ;Se A != CHS, checar se a proxima tecla foi pressionada
    LCALL CHANGE_SIGNAL_X        ;Se A == CHS, executa a operacao
    MOV R6, #0H                  ;Contador = 0
    JMP LER_FILA

CHECAR_CLX:
    CJNE A, #CLX, CHECAR_CLS     ;Se A != CLX, checar se a proxima tecla foi pressionada
    LCALL CLEAR_X                ;Se A == CLX, executa a operacao
    MOV R6, #0H                  ;Contador = 0
    JMP LER_FILA

CHECAR_CLS:
    CJNE A, #CLS, CHECAR_ENTER   ;Se A != CLS, checar se a proxima tecla foi pressionada
    LCALL CLEAR_STACK            ;Se A == CLS, executa a operacao
    MOV R6, #0H                  ;Contador = 0
    JMP LER_FILA

CHECAR_ENTER:
    CJNE A, #ENTER, CHECAR_DROP  ;Se A != ENTER, checar se a proxima tecla foi pressionada
    LCALL ENTER_PUSH             ;Se A == ENTER, executa a operacao
    MOV R6, #0H                  ;Contador = 0
    JMP LER_FILA

CHECAR_DROP:
    CJNE A, #DROP, CHECAR_SWAPI  ;Se A != DROP, checar se a proxima tecla foi pressionada
    LCALL DROP_POP               ;Se A == DROP, executa a operacao
    MOV R6, #0H                  ;Contador = 0
    JMP LER_FILA

CHECAR_SWAPI:
    CJNE A, #SWAPI, CHECAR_MAIS  ;Se A != SWAPI, checar se a proxima tecla foi pressionada
    LCALL SWAP_X_Y               ;Se A == SWAPI, executa a operacao
    MOV R6, #0H                  ;Contador = 0
    JMP LER_FILA

CHECAR_MAIS:
    CJNE A, #MAIS, CHECAR_MENOS  ;Se A != MAIS, checar se a proxima tecla foi pressionada
    LCALL ADICAO_Y_X             ;Se A == MAIS, executa a operacao
    MOV R6, #0H                  ;Contador = 0
    JMP LER_FILA

CHECAR_MENOS:
    CJNE A, #MENOS, CHECAR_MULT  ;Se A != MENOS, checar se a proxima tecla foi pressionada
    LCALL SUBTRACAO_Y_X          ;Se A == MENOS, executa a operacao
    MOV R6, #0H                  ;Contador = 0
    JMP LER_FILA

CHECAR_MULT:
    CJNE A, #MULT, CHECAR_DIVI  ;Se A != MULT, checar se a proxima tecla foi pressionada
    LCALL MULTIPLICACAO_Y_X     ;Se A == MULT, executa a operacao
    MOV R6, #0H                 ;Contador = 0
    JMP LER_FILA

CHECAR_DIVI:
    CJNE A, #DIVI, CHECAR_MODUL ;Se A != DIVI, checar se a proxima tecla foi pressionada
    LCALL DIVISAO_Y_X           ;Se A == DIVI, executa a operacao
    MOV R6, #0H                 ;Contador = 0
    JMP LER_FILA

CHECAR_MODUL:
    CJNE A, #MODUL, CHECAR_RRX  ;Se A != MODUL, checar se a proxima tecla foi pressionada
    LCALL MODULO_Y_X            ;Se A == MODUL, executa a operacao
    MOV R6, #0H                 ;Contador = 0
    JMP LER_FILA

CHECAR_RRX:
    CJNE A, #RRX, CHECAR_RLX    ;Se A != RRX, checar se a proxima tecla foi pressionada
    LCALL RODAR_DIREITA_X       ;Se A == RRX, executa a operacao
    MOV R6, #0H                 ;Contador = 0
    JMP LER_FILA

CHECAR_RLX:
    CJNE A, #RLX, CHECAR_SRX    ;Se A != RLX, checar se a proxima tecla foi pressionada
    LCALL RODAR_ESQUERDA_X      ;Se A == RLX, executa a operacao
    MOV R6, #0H                 ;Contador = 0
    JMP LER_FILA

CHECAR_SRX:
    CJNE A, #SRX, CHECAR_SLX    ;Se A != SRX, checar se a proxima tecla foi pressionada
    LCALL SHIFT_DIREITA_X       ;Se A == SRX, executa a operacao
    MOV R6, #0H                 ;Contador = 0
    JMP LER_FILA

CHECAR_SLX:
    CJNE A, #SLX, CHECAR_QUAD   ;Se A != SLX, checar se a proxima tecla foi pressionada
    LCALL SHIFT_ESQUERDA_X      ;Se A == SLX, executa a operacao
    MOV R6, #0H                 ;Contador = 0
    JMP LER_FILA

CHECAR_QUAD:
    CJNE A, #QUAD, CHECAR_POW   ;Se A != QUAD, checar se a proxima tecla foi pressionada
    LCALL QUADRADO_X            ;Se A == QUAD, executa a operacao
    MOV R6, #0H                 ;Contador = 0
    JMP LER_FILA

CHECAR_POW:
    CJNE A, #POW, CHECAR_RSUP   ;Se A != POW, checar se a proxima tecla foi pressionada
    LCALL POTENCIA_Y_X          ;Se A == POW, executa a operacao
    MOV R6, #0H                 ;Contador = 0
    JMP LER_FILA

CHECAR_RSUP:
    CJNE A, #RSUP, CHECAR_RSDW  ;Se A != RSUP, checar se a proxima tecla foi pressionada
    LCALL RODAR_PILHA_CIMA      ;Se A == RSUP, executa a operacao
    MOV R6, #0H                 ;Contador = 0
    JMP LER_FILA

CHECAR_RSDW:
    CJNE A, #RSDW, CHECAR_STO   ;Se A != RSDW, checar se a proxima tecla foi pressionada
    LCALL RODAR_PILHA_CIMA      ;Se A == RSDW, executa a operacao
    MOV R6, #0H                 ;Contador = 0
    JMP LER_FILA

CHECAR_STO:
    CJNE A, #STO, CHECAR_RCL    ;Se A != STO, checar se a proxima tecla foi pressionada
    LCALL ARMAZENAR_X_MEMORIA   ;Se A == STO, executa a operacao
    MOV R6, #0H                 ;Contador = 0
    JMP LER_FILA

CHECAR_RCL:
    CJNE A, #RCL, CHECAR_NUM    ;Se A != RCL, checar se a proxima tecla foi pressionada
    LCALL COPIAR_MEMORIA_X      ;Se A == RCL, executa a operacao
    MOV R6, #0H                  ;Contador = 0
    JMP LER_FILA

;Se a tecla nao for nenhuma das operacoes, ela eh um numero
CHECAR_NUM:
    LCALL RECEBER_NUM
    JMP LER_FILA

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;Rotina - Tecla Invalida
TECLA_INVALIDA:

    JMP FIM

;;;Rotina - Fim
FIM:
    JMP INIT

;;;Rotinas das Teclas
;;;Rotina - Change Signal (X)
CHANGE_SIGNAL_X:
    CPL SINAL_X

    RET

;;;Rotina - Clear (X)
CLEAR_X:
    MOV XH, #0H
    MOV XL, #0H
    CLR SINAL_X

    RET

;;;Rotina - Clear Stack
CLEAR_STACK:
    MOV XH, #0H
    MOV XL, #0H
    CLR SINAL_X

    MOV YH, #0H
    MOV YL, #0H
    CLR SINAL_Y

    MOV ZH, #0H
    MOV ZL, #0H
    CLR SINAL_Z

    MOV TH, #0H
    MOV TL, #0H
    CLR SINAL_T

    RET

;;;Rotina - Enter "PUSH"
;T <=> Z
;Z <=> Y
;Y <=> X
;X <=> 0
ENTER_PUSH:
    ;LSB
    MOV A, XL           ;A = XL
    XCH A, YL           ;YL = XL, A = YL
    XCH A, ZL           ;ZL = YL, A = ZL
    MOV TL, A           ;TL = ZL

    ;MSB
    MOV A, XH           ;A = XH
    XCH A, YH           ;YH = XH, A = YH
    XCH A, ZH           ;ZH = YH, A = ZH
    MOV TH, A           ;TH = ZH

    ;SINAIS
    MOV A.0, C          ;Armazenndo o valor do Carry

    MOV C, SINAL_Z      ;C = SINAL_Z
    MOV SINAL_T, C      ;SINAL_T = SINAL_Z

    MOV C, SINAL_Y      ;C = SINAL_Y
    MOV SINAL_Z, C      ;SINAL_Z = SINAL_Y

    MOV C, SINAL_X      ;C = SINAL_X
    MOV SINAL_Y, C      ;SINAL_Y =  SINAL_X

    LCALL CLEAR_X       ;X = 0, SINAL_X = 0

    MOV C, A.0          ;Restaurando o valor do Carry

    RET

;;;Rotina - Drop "POP"
;T <=> T
;Z <=> T
;Y <=> Z
;X <=> Y
DROP_POP:
    ;LSB
    MOV A, TL           ;A = TL
    XCH A, ZL           ;ZL = TL, A = ZL
    XCH A, YL           ;YL, = ZL, A = YL
    MOV XL, A           ;XL = YL

    ;MSB
    MOV A, TH           ;A = TH
    XCH A, ZH           ;ZH = TH, A = ZH
    XCH A, YH           ;YH = ZH, A = YH
    MOV XH, A           ;XH = YH

    ;SINAIS
    MOV A.0, C          ;Armazenndo o valor do Carry

    MOV C, SINAL_Y      ;C = SINAL_Y
    MOV SINAL_X, C      ;SINAL_X = SINAL_Y

    MOV C, SINAL_Z      ;C = SINAL_Z
    MOV SINAL_Y, C      ;SINAL_Y = SINAL_Z

    MOV C, SINAL_T      ;C = SINAL_T
    MOV SINAL_Z, C      ;SINAL_Z = SINAL_T

    MOV C, A.0          ;Restaurando o valor do Carry

    RET

;;;Rotina - Swap (X,Y)
SWAP_X_Y:
    ;LSB
    MOV A, XL           ;A = XL
    XCH A, YL           ;YL = XL, A = YL
    MOV XL, A           ;XL = YL

    ;MSB
    MOV A, XH           ;A = XH
    XCH A, YH           ;YH = XH, A = YH
    MOV XH, A           ;XH = YH

    ;SINAIS
    MOV C, SINAL_X      ;C = SINAL_X
    MOV A, #0H          ;A = 0
    ADDC A, #0H         ;LSB(A) = SINAL_X
    MOV AUX1L, A        ;LSB(AUX1L) = SINAL_X

    MOV C, SINAL_Y      ;C = SINAL_Y
    MOV SINAL_X, C      ;SINAL_X = SINAL_Y

    MOV A, AUX1L        ;A = AUX1L
    MOV C, A.0          ;C = SINAL_X
    MOV SINAL_Y, C      ;SINAL_Y = SINAL_X

    RET

;;;Rotina - Adicao (Y,X)
ADICAO_Y_X:
    MOV A, YL           ;A = YL
    ADD A, XL           ;A = YL + XL
    DA A                ;Ajuste para BCD
    MOV YL, A           ;YL = YL + XL

    MOV A, YH           ;A = YH
    ADDC A, XH          ;A = YH + XH + C
    DA A                ;Ajuste para BCD
    MOV YH, A           ;YH = YH + XH

    LCALL DROP_POP

    RET

;;;Rotina - Subtracao (Y,X)
SUBTRACAO_Y_X:
    MOV R5, YL
    MOV R6, YH          ;Armazena o valor de Y

    LCALL NEGATIVO_BCD  ;XL = - XL

    MOV YL, R5
    MOV YH, R6          ;Restaura o valor de Y

    MOV A, YL           ;A = YL
    ADD A, XL           ;A = YL + (- XL)
    DA A                ;Ajuste para BCD
    MOV YL, A           ;YL = YL + (- XL)

    MOV A, YH           ;A = YH
    ADDC A, XH          ;A = YH + (- XH) + C
    DA A                ;Ajuste para BCD
    MOV YH, A           ;YH = YH + (- XH)

    LCALL DROP_POP

    RET

    ;Subtrai 9 de cada digito BCD, e soma 1 para negativar o numero
    NEGATIVO_BCD:
        ;XL
        ;LSByte
        MOV A, XL           ;A = XL
        ANL A, #0FH         ;A = LSByte(XL)
        MOV AUX1L, A        ;AUX1L = LSByte(XL)

        MOV A, #09H         ;A = 9
        CLR C
        SUBB A, AUX1L       ;A = 9 - LSByte(XL)

        ANL A, #0FH         ;A = LSByte(9 - LSByte(XL))
        MOV AUX1L, A        ;AUX1L = [0, 9 - LSByte(XL)]

        ;MSByte
        MOV A, XL           ;A = XL
        ANL A, #0F0H        ;A = MSByte(XL)
        MOV AUX2L, A        ;AUX1L = MSByte(XL)

        MOV A, #90H         ;A = 9
        CLR C
        SUBB A, AUX2L       ;A = 9 - MSByte(XL)

        ANL A, #0F0H        ;A = MSByte(A = 9 - MSByte(XL))
        ORL AUX1L, A        ;AUX1L = [9 - MSByte(XL), 9 - LSByte(XL)]

        MOV XL, AUX1L       ;XL = [9 - MSByte(XL), 9 - LSByte(XL)]

        ;XH
        ;LSByte
        MOV A, XH           ;A = XH
        ANL A, #0FH         ;A = LSByte(XH)
        MOV AUX1H, A        ;AUX1H = LSByte(XH)

        MOV A, #09H         ;A = 9
        CLR C
        SUBB A, AUX1H       ;A = 9 - LSByte(XH)

        ANL A, #0FH         ;A = LSByte(9 - LSByte(XH))
        MOV AUX1H, A        ;AUX1H = [0, 9 - LSByte(XH)]

        ;MSByte
        MOV A, XH           ;A = XH
        ANL A, #0F0H        ;A = MSByte(XH)
        MOV AUX2H, A        ;AUX1H = MSByte(XH)

        MOV A, #90H         ;A = 9
        CLR C
        SUBB A, AUX2H       ;A = 9 - MSByte(XH)

        ANL A, #0F0H        ;A = MSByte(9 - MSByte(XH))
        ORL AUX1H, A        ;AUX1H = [9 - MSByte(XH), 9 - LSByte(XH)]

        MOV XH, AUX1H       ;XH = [9 - MSByte(XH), 9 - LSByte(XH)]

        ;Soma o numero com para obter o resultado final
        MOV YL, #01H
        MOV YH, #0H

        LCALL ADICAO_Y_X

        RET

;;;Rotina - Multiplicacao (Y,X)
;Multiplicar um numero por n, eh a msm coisa que somar o numero com ele msm n vezes
MULTIPLICACAO_Y_X:
    ;Enquanto n > 0
    ;Somar o numero com ele msm

    MOV R1, YL
    MOV R2, YH          ;R2,R1 = Y inicial, numero a ser somado

    MOV R3, YL
    MOV R4, YH          ;R4,R3 = Y inicial, numero a ser somado

    MOV R5, XL
    MOV R6, XH          ;R6,R5 = X inicial, numero de vezes a ser somado

    LOOP_MULTIPLICACAO:
        ;Soma inicial para o resultado da multiplicacao
        MOV XL, R1
        MOV XH, R2          ;X = resultado da soma

        MOV YL, R3
        MOV YH, R4          ;Y = Y inicial, numero a ser somado

        LCALL ADICAO_Y_X    ;Soma o numero com ele msm, resultado em X

        MOV R1, XL
        MOV R2, XH          ;Resultado da soma em R2,R1

        ;Subtracao para o loop
        MOV YL, R5
        MOV YH, R6          ;Numero de vezes a ser somado

        MOV XL, #01H        ;-1
        MOV XH, #0H

        LCALL SUBTRACAO_Y_X ;Contagem do numero de somas efetudas

        MOV R5, XL
        MOV R6, XH          ;R6,R5 = novo numero de vezes a ser somado

        ;Verifica se o numero de vezes a ser somado chegou em 1
        CJNE R6, #0H, LOOP_MULTIPLICACAO
        CJNE R5, #01H, LOOP_MULTIPLICACAO

        MOV YL, R1
        MOV YH, R2          ;R2,R1 = Resultado final

        LCALL DROP_POP

        RET

;;;Rotina - Divisao (Y,X)
DIVISAO_Y_X:
    ;Enquanto n > 0
    ;Subtrair o numero com ele msm, ate o maior valor maior q 0

    MOV R1, XL
    MOV R2, XH          ;X = valor a ser subtraido n vezes

    MOV R3, #0H
    MOV R4, #0H         ;Quociente = num de subtracoes

    MOV R5, YL
    MOV R6, YH          ;Valor a ser subtraido inicialmente

    LOOP_DIVISAO:
        ;Subtracoes sucessivas
        MOV YL, R5
        MOV YH, R6              ;Resultado da subtracao

        MOV XL, R1
        MOV XH, R2              ;X = valor a ser subtraido n vezes

        LCALL SUBTRACAO_Y_X

        MOV R5, XL
        MOV R6, XH              ;R5,R4 = armazena o resultado da subtracao

        ;Verifica se o resultado da subtracao eh negativo
        MOV YL, R5
        MOV YH, R6              ;Y = resultado da subtracao

        MOV XL, #0H
        MOV XH, #0H             ;X = 0

        LCALL SUBTRACAO_Y_X

        ;Verifica se o resultado eh maior ou menor q 0
        MOV A, XH
        ANL A, #0F0H            ;Pega somente MSByte(X)
        CJNE A, #90H, MAIOR_0   ;Se MSByte(X) != 9, X > 0
        JMP MENOR_0

        MAIOR_0:
            ;Contando o numero de subtracoes feitas
            MOV YL, R3
            MOV YH, R4          ;Quociente

            MOV XL, #01H
            MOV XH, #0H         ;Quociente++

            LCALL ADICAO_Y_X

            MOV R3, XL
            MOV R4, XH          ;Quociente = Quociente++

            ;Loop
            JMP LOOP_DIVISAO    ;Efetua mais uma subtracao

        MENOR_0:
            MOV YL, R3
            MOV YH, R4          ;Quociente final

            LCALL DROP_POP

            RET

;;;Rotina - Modulo (Y,X)
MODULO_Y_X:
    LCALL DIVISAO_Y_X

    MOV YL, R1
    MOV YH, R2          ;Resto - X

    MOV XL, R5
    MOV XH, R6          ;X

    LCALL ADICAO_Y_X    ;Resto - X + X = Resto

    RET

;;;Rotina - Rodar Direita (X)
RODAR_DIREITA_X:
    ;Guardando o valor de LSB(XL)
    MOV A, XL           ;A = XL
    MOV C, A.0          ;C = LSB(XL)
    MOV A, #0H          ;A = 0
    ADDC A, #0H         ;LSB(A) = LSB(XL)
    MOV AUX1L, A        ;LSB(AUX1L) = LSB(XL)

    ;Rodando XL com LSB(XH)
    MOV A, XH           ;A = XH
    MOV C, A.0          ;C = LSB(XH)
    MOV A, XL           ;A = XL
    RRC A               ;MSB(A) = LSB(XH)
    MOV XL, A           ;MSB(XL) = LSB(XH)

    ;Rodando XH com LSB(XL)
    MOV A, AUX1L        ;A = AUX1L
    MOV C, A.0          ;C = LSB(XL)
    MOV A, XH           ;A = XH
    RRC A               ;MSB(A) = LSB(XL)
    MOV XH, A           ;MSB(XH) = LSB(XL)

    RET

;;;Rotina - Rodar Esquerda (X)
RODAR_ESQUERDA_X:
    ;Guardando o valor de MSB(XH)
    MOV A, XH           ;A = XH
    MOV C, A.7          ;C = MSB(XH)
    MOV A, #0H          ;A = 0
    ADDC A, #0H         ;LSB(A) = MSB(XH)
    MOV AUX1L, A        ;LSB(AUX1L) = MSB(XH)

    ;Rodando XH com MSB(XL)
    MOV A, XL           ;A = XL
    MOV C, A.7          ;C = MSB(XL)
    MOV A, XH           ;A = XH
    RLC A               ;LSB(A) = MSB(XL)
    MOV XH, A           ;LSB(XH) = MSB(XL)

    ;Rodando XL com MSB(XH)
    MOV A, AUX1L        ;A = AUX1L
    MOV C, A.0          ;C = MSB(XH)
    MOV A, XL           ;A = XL
    RLC A               ;LSB(A) = MSB(XH)
    MOV XL, A           ;LSB(XL) = MSB(XH)

    RET

;;;Rotina - Shift Direita (X)
SHIFT_DIREITA_X:
    ;Rodando XL com LSB(XH)
    MOV A, XH           ;A = XH
    MOV C, A.0          ;C = LSB(XH)
    MOV A, XL           ;A = XL
    RRC A               ;MSB(A) = LSB(XH)
    MOV XL, A           ;MSB(XL) = LSB(XH)

    ;Rodando XH com SINAL_X
    MOV C, SINAL_X      ;C = SINAL_X
    MOV A, XH           ;A = XH
    RRC A               ;MSB(A) = SINAL_X
    MOV XH, A           ;MSB(XH) = SINAL_X

    RET

;;;Rotina - Shift Esquerda (X)
SHIFT_ESQUERDA_X:
    ;Rodando XL com 0
    CLR C               ;C = 0
    MOV A, XL           ;A = XL
    RLC A               ;LSB(A) = 0, C = MSB(XL)
    MOV XL, A           ;LSB(XL) = 0

    ;Rodando XH com MSB(XL)
    MOV A, XH           ;A = XH
    RLC A               ;LSB(A) = MSB(XL)
    MOV XH, A           ;LSB(XH) = MSB(XL)

    RET

;;;Rotina - Quadrado (X)
QUADRADO_X:
    MOV YL, XL          ;Y = X
    MOV YH, XH

    LCALL MULTIPLICACAO_Y_X

    RET

;;;Rotina - Potencia (Y,X)
POTENCIA_Y_X:
    ;Enquanto n > 0
    ;Multiplicar o numero por ele msm

    MOV AUX3L, YL
    MOV AUX3H, YH          ;AUX3 = Y inicial, numero a ser multiplicado

    MOV AUX4L, YL
    MOV AUX4H, YH          ;AUX4 = Y inicial, numero a ser multiplicado

    MOV AUX5L, XL
    MOV AUX5H, XH          ;AUX5 = X inicial, numero de vezes a ser multiplicado

    LOOP_POTENCIA:
        ;Multiplicacao inicial para o resultado da potencia
        MOV XL, AUX3L
        MOV XH, AUX3H            ;X = resultado da multiplicacao

        MOV YL, AUX4L
        MOV YH, AUX4H            ;Y = Y inicial, numero a ser multiplicado

        LCALL MULTIPLICACAO_Y_X  ;Multiplica o numero com ele msm, resultado em X

        MOV AUX3L, XL
        MOV AUX3H, XH            ;Resultado da multiplicacao em R2,R1

        ;Subtracao para o loop
        MOV YL, AUX5L
        MOV YH, AUX5H            ;Numero de vezes a ser multiplicado

        MOV XL, #01H             ;-1
        MOV XH, #0H

        LCALL SUBTRACAO_Y_X      ;Contagem do numero de multiplicacoes efetudas

        MOV AUX5L, XL
        MOV AUX5H, XH            ;AUX5 = novo numero de vezes a ser somado

        ;Verifica se o numero de vezes a ser somado chegou em 1
        MOV A, AUX5H
        CJNE A, #0H, LOOP_POTENCIA
        MOV A, AUX5L
        CJNE A, #01H, LOOP_POTENCIA

        MOV YL, AUX3L
        MOV YH, AUX3H            ;AUX3 = Resultado final

        LCALL DROP_POP

        RET

;;;Rotina - Rodar Pilha para Cima
;T <=> X
;Z <=> T
;Y <=> Z
;X <=> Y
RODAR_PILHA_CIMA:
    ;LSB
    MOV A, XL           ;A = XL
    XCH A, TL           ;TL = XL, A = TL
    XCH A, ZL           ;ZL = TL, A = ZL
    XCH A, YL           ;YL = ZL, A = YL
    XCH A, XL           ;XL = YL

    ;MSB
    MOV A, XH           ;A = XH
    XCH A, TH           ;TH = XH, A = TH
    XCH A, ZH           ;ZH = TH, A = ZH
    XCH A, YH           ;YH = ZH, A = YH
    XCH A, XH           ;XH = YH

    ;SINAIS
    MOV C, SINAL_X      ;C = SINAL_X
    MOV A, #0H          ;A = 0
    ADDC A, #0H         ;LSB(A) = SINAL_X
    MOV AUX1L, A        ;LSB(AUX1L) = SINAL_X

    MOV C, SINAL_Y      ;C = SINAL_Y
    MOV SINAL_X, C      ;SINAL_X = SINAL_Y

    MOV C, SINAL_Z      ;C = SINAL_Z
    MOV SINAL_Y, C      ;SINAL_Y = SINAL_Z

    MOV C, SINAL_T      ;C = SINAL_T
    MOV SINAL_Z, C      ;SINAL_Z = SINAL_T

    MOV A, AUX1L        ;A = AUX1L
    MOV C, A.0          ;C = SINAL_X
    MOV SINAL_T, C      ;SINAL_T = SINAL_X

    RET

;;;Rotina - Rodar Pilha para Baixo
;T <=> Z
;Z <=> Y
;Y <=> X
;X <=> T
RODAR_PILHA_BAIXO:
    ;LSB
    MOV A, ZL           ;A = ZL
    XCH A, TL           ;TL = ZL, A = TL
    XCH A, XL           ;XL = TL, A = XL
    XCH A, YL           ;YL = XL, A = YL
    XCH A, ZL           ;ZL = YL

    ;MSB
    MOV A, ZH           ;A = ZH
    XCH A, TH           ;TH = ZH, A = TH
    XCH A, XH           ;XH = TH, A = XH
    XCH A, YH           ;YH = XH, A = YH
    XCH A, ZH           ;ZH = YH

    ;SINAIS
    MOV C, SINAL_T      ;C = SINAL_T
    MOV A, #0H          ;A = 0
    ADDC A, #0H         ;LSB(A) = SINAL_T
    MOV AUX1L, A        ;LSB(AUX1L) = SINAL_T

    MOV C, SINAL_Z      ;C = SINAL_Z
    MOV SINAL_T, C      ;SINAL_T = SINAL_Z

    MOV C, SINAL_Y      ;C = SINAL_Y
    MOV SINAL_Z, C      ;SINAL_Z = SINAL_Y

    MOV C, SINAL_X      ;C = SINAL_X
    MOV SINAL_Y, C      ;SINAL_Y = SINAL_X

    MOV A, AUX1L        ;A = AUX1L
    MOV C, A.0          ;C = SINAL_T
    MOV SINAL_X, C      ;SINAL_X = SINAL_T

    RET

;;;Rotina - Armazenar (X) na memoria
ARMAZENAR_X_MEMORIA:
    ;LSB
    MOV A, XL
    MOV MEML, A

    ;MSB
    MOV A, XH
    MOV MEMH, A

    RET

;;;Rotina - Copiar a memoria para (X)
COPIAR_MEMORIA_X:
    ;LSB
    MOV A, MEML
    MOV XL, A

    ;MSB
    MOV A, MEMH
    MOV XH, A

    RET

;;;Receber Numero
RECEBER_NUM:
    INC R6                             ;Contador

    CJNE R6, #1, CHECAR_DEZENA         ;Contador != 1
    LJMP RECEBER_UNIDADE               ;Contador == 1, recebe Unidade

CHECAR_DEZENA:
    CJNE R6, #2, CHECAR_CENTENA        ;Contador != 2
    LJMP RECEBER_DEZENA                ;Contador == 2, recebe Dezena

CHECAR_CENTENA:
    CJNE R6, #3, CHECAR_MILHAR         ;Contador != 3
    LJMP RECEBER_CENTENA               ;Contador == 3, recebe Centena

CHECAR_MILHAR:
    CJNE R6, #4, OVERFLOW              ;Contador != 4
    LJMP RECEBER_MILHAR                ;Contador == 4, recebe Milhar

;A tecla mais recente deve ficar sempre a mais direita
;Ex:
;   3 -> 0003
RECEBER_UNIDADE:
    MOV XL, A           ;XL = 03

    RET

;Ex:
;   4 -> 0043 -> 0034
RECEBER_DEZENA:
    SWAP A              ;A = SWAP Tecla
    ORL XL, A           ;XL = 43

    MOV A, XL
    SWAP A
    MOV XL, A           ;XL = 34

    RET

;Ex:
;   5 -> 0534 -> 0543 -> 0345
RECEBER_CENTENA:
    MOV XH, A           ;XH = 05, XL = 34

    MOV A, XL
    SWAP A
    MOV XL, A           ;XH = 05, XL = 43

    MOV R1, #XL         ;R1 = endereco de XL
    MOV A, XH           ;A = XH
    XCHD A, @R1         ;A = 03, XL = 45
    MOV XH, A           ;XH = 03, XL = 45

    RET

;Ex:
;   6 -> 6345 -> 3645 -> 3654 -> 3456
RECEBER_MILHAR:
    SWAP A              ;A = SWAP Tecla
    ORL XH, A           ;XH = 63

    MOV A, XH
    SWAP A
    MOV XH, A           ;XH = 36

    MOV A, XL
    SWAP A
    MOV XL, A           ;XL = 54

    MOV R1, #XL         ;R1 = endereco de XL
    MOV A, XH           ;A = XH
    XCHD A, @R1         ;A = 34, XL = 56
    MOV XH, A           ;XH = 34, VL = 56

    RET

OVERFLOW:
    SETB OVFL           ;Mais de 4 digitos, overflow

    RET

END

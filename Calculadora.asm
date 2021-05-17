;********************************************************************************
; Rotina que faz a varredura do teclado e retorna o valor da tecla pressionada	*
;********************************************************************************
Calculadora_keyRead:
;verificar se há alguma tecla pressionada
	CALL       _Keypad_Key_Press+0
	MOVF       R0+0, 0
	MOVWF      Calculadora_keyRead_key_L0+0
;se houver tecla pressionada
	MOVF       R0+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_Calculadora_keyRead0
	MOVLW      1
	SUBWF      Calculadora_keyRead_key_L0+0, 0
	MOVWF      R0+0
	CLRF       R0+1
	BTFSS      STATUS+0, 0
	DECF       R0+1, 1
	MOVF       R0+0, 0
	ADDWF      FARG_Calculadora_keyRead_keys+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      R0+0
	GOTO       L_end_keyRead
L_Calculadora_keyRead0:
;zera registrador R0 para retomar ao topo da pilha
	CLRF       R0+0
;retorna para o topo da pilha
L_end_keyRead:
	RETURN
;********************************************************************************


;********************************************************************************
; Rotina de inicialização do sistema						*
;********************************************************************************
_main:
;inicializa o teclado
	CALL       _Keypad_Init+0
;inicializa o LCD
	CALL       _Lcd_Init+0
;limpa o LCD
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;remove cursor do LCD
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;********************************************************************************
	
	
;********************************************************************************
; Rotina de verificações de estados do sistema					*
;********************************************************************************
L_main1:
;guarda o valor digitado pelo teclado
	MOVLW      _teclas+0
	MOVWF      FARG_Calculadora_keyRead_keys+0
	CALL       Calculadora_keyRead+0
	MOVF       R0+0, 0
	MOVWF      main_k_L0+0
;se foi realizado uma operação matemática com um valor numérico
	BTFSS      _flags+0, 0
	GOTO       L_main5
	MOVF       main_k_L0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main5
;********************************************************************************


;********************************************************************************
; Rotina de reset de display							*
;********************************************************************************
L__main37:
;reseta a posição de leitura
	CLRF       main_pos_L0+0
;reseta a operação matemática
	BCF        _flags+0, 0
;limpa o display
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;retorna o cursor para q posição inicial
	MOVLW      2
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;limpa variáveis
	CLRF       main_i_L0+0
;********************************************************************************

	
;********************************************************************************
; Rotina de reset de variáveis							*
;********************************************************************************
L_main6:
	MOVLW      8
	SUBWF      main_i_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main7
;limpa os bit do número
	MOVF       main_i_L0+0, 0
	ADDLW      _numero+0
	MOVWF      FSR
	CLRF       INDF+0
;reseta os bits do primeiro byte do resultado
	MOVF       main_i_L0+0, 0
	ADDLW      _resultado+0
	MOVWF      FSR
	CLRF       INDF+0
;reseta os bits do segundo byte do resultado
	MOVF       main_i_L0+0, 0
	ADDLW      _resultado+0
	MOVWF      R0+0
	MOVLW      8
	ADDWF      R0+0, 0
	MOVWF      FSR
	CLRF       INDF+0
;incrementa o contador do laço
	INCF       main_i_L0+0, 1
;retorna para o começo do laço
	GOTO       L_main6
L_main7:
;final do laço
;********************************************************************************
    
    
;********************************************************************************
; Rotina de entrada das parcelas						*
;********************************************************************************
L_main5:
;se a tecla pressionada for um número
	MOVLW      48
	SUBWF      main_k_L0+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L__main36
	MOVF       main_k_L0+0, 0
	SUBLW      57
	BTFSS      STATUS+0, 0
	GOTO       L__main36
	GOTO       L__main35
L__main36:
	MOVF       main_k_L0+0, 0
	XORLW      46
	BTFSC      STATUS+0, 2
	GOTO       L__main35
	GOTO       L_main13
L__main35:
;atribui posição dos bits no LCD
	MOVF       main_pos_L0+0, 0
	ADDLW      _numero+0
	MOVWF      FSR
	MOVF       main_k_L0+0, 0
	MOVWF      INDF+0
	INCF       main_pos_L0+0, 1
;reseta posição para o começo do byte
	MOVLW      8
	SUBWF      main_pos_L0+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_main14
	CLRF       main_pos_L0+0
L_main14:
;printa no LCD o número no bit correspondente
	MOVLW      1
	SUBWF      main_pos_L0+0, 0
	MOVWF      R0+0
	CLRF       R0+1
	BTFSS      STATUS+0, 0
	DECF       R0+1, 1
	MOVF       R0+0, 0
	ADDLW      _numero+0
	MOVWF      FARG_Lcd_Out_CP_text+0
	CALL       _Lcd_Out_CP+0
;salto para finalização da rotina principal
	GOTO       L_main15
;********************************************************************************
	
	
;********************************************************************************
; Rotina de entrada da operação matemática					*
;********************************************************************************
L_main13:
;Calculadora.c,61 :: 		else if(k == '+' || k=='-' || k=='/' || k=='*')
;verificação de símbolo aritmético
	MOVF       main_k_L0+0, 0
	XORLW      43
	BTFSC      STATUS+0, 2
	GOTO       L__main34
	MOVF       main_k_L0+0, 0
	XORLW      45
	BTFSC      STATUS+0, 2
	GOTO       L__main34
	MOVF       main_k_L0+0, 0
	XORLW      47
	BTFSC      STATUS+0, 2
	GOTO       L__main34
	MOVF       main_k_L0+0, 0
	XORLW      42
	BTFSC      STATUS+0, 2
	GOTO       L__main34
	GOTO       L_main18
L__main34:
;armazenamento da variável no registrador main_op_L
	MOVF       main_k_L0+0, 0
	MOVWF      main_op_L_L0+0
;reset do registrador main_pos (posição)
	CLRF       main_pos_L0+0
;chamada de função para impressão do símbolo no LCD
	MOVF       main_k_L0+0, 0
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;conversão texto p/ número real e atribuição do mesmo para registrador _lvalue
	MOVLW      _numero+0
	MOVWF      FARG_atof_s+0
	CALL       _atof+0
	MOVF       R0+0, 0
	MOVWF      _lvalue+0
	MOVF       R0+1, 0
	MOVWF      _lvalue+1
	MOVF       R0+2, 0
	MOVWF      _lvalue+2
	MOVF       R0+3, 0
	MOVWF      _lvalue+3
;limpa variáveis
	CLRF       main_i_L0+0
L_main19:
	MOVLW      8
	SUBWF      main_i_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main20
	MOVF       main_i_L0+0, 0
	ADDLW      _numero+0
	MOVWF      FSR
	CLRF       INDF+0
	INCF       main_i_L0+0, 1
	GOTO       L_main19
L_main20:
;fim da rotina de identificação de operação matemática
	GOTO       L_main22
;********************************************************************************
	
	
;********************************************************************************
; Rotina de comando do resultado						*
;********************************************************************************
L_main18:
;quando recebido o comando de "="
	MOVF       main_k_L0+0, 0
	XORLW      61
	BTFSS      STATUS+0, 2
	GOTO       L_main23
;conversão texto p/ número real e atribuição do mesmo para registrador _rvalue
	MOVLW      _numero+0
	MOVWF      FARG_atof_s+0
	CALL       _atof+0
	MOVF       R0+0, 0
	MOVWF      _rvalue+0
	MOVF       R0+1, 0
	MOVWF      _rvalue+1
	MOVF       R0+2, 0
	MOVWF      _rvalue+2
	MOVF       R0+3, 0
	MOVWF      _rvalue+3
;reset da flag de negativo>positivo
	BCF        _flags+0, 1
;chamada de função para impressão do símbolo no LCD
	MOVLW      61
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;jump para estrutura condicional do registrador main_op_L "op"
	GOTO       L_main24
;********************************************************************************

	
;********************************************************************************
; Rotina de desambiguação (identificação de operação e jump)			*
;********************************************************************************
L_main24:
	MOVF       main_op_L_L0+0, 0
	XORLW      43
	BTFSC      STATUS+0, 2
	GOTO       L_main26
	MOVF       main_op_L_L0+0, 0
	XORLW      45
	BTFSC      STATUS+0, 2
	GOTO       L_main27
	MOVF       main_op_L_L0+0, 0
	XORLW      47
	BTFSC      STATUS+0, 2
	GOTO       L_main30
	MOVF       main_op_L_L0+0, 0
	XORLW      42
	BTFSC      STATUS+0, 2
	GOTO       L_main31
;********************************************************************************
	
	
;********************************************************************************
; Rotina para soma das parcelas	(main_op_L == '+')				*
;********************************************************************************
L_main26:
;soma os bits do _lvalue com _rvalue
	MOVF       _lvalue+0, 0
	MOVWF      R0+0
	MOVF       _lvalue+1, 0
	MOVWF      R0+1
	MOVF       _lvalue+2, 0
	MOVWF      R0+2
	MOVF       _lvalue+3, 0
	MOVWF      R0+3
	MOVF       _rvalue+0, 0
	MOVWF      R4+0
	MOVF       _rvalue+1, 0
	MOVWF      R4+1
	MOVF       _rvalue+2, 0
	MOVWF      R4+2
	MOVF       _rvalue+3, 0
	MOVWF      R4+3
	CALL       _Add_32x32_FP+0
	MOVF       R0+0, 0
	MOVWF      _lvalue+0
	MOVF       R0+1, 0
	MOVWF      _lvalue+1
	MOVF       R0+2, 0
	MOVWF      _lvalue+2
	MOVF       R0+3, 0
	MOVWF      _lvalue+3
;final da rotina de soma e jump para final da estrutura condicional "op"
	GOTO       L_main25
;********************************************************************************
	
	
;********************************************************************************
; Rotina para subtração das parcelas (main_op_L == '-')				*
;********************************************************************************
L_main27:
;verifica se _lvalue é maior ou igual que _rvalue
	MOVF       _rvalue+0, 0
	MOVWF      R4+0
	MOVF       _rvalue+1, 0
	MOVWF      R4+1
	MOVF       _rvalue+2, 0
	MOVWF      R4+2
	MOVF       _rvalue+3, 0
	MOVWF      R4+3
	MOVF       _lvalue+0, 0
	MOVWF      R0+0
	MOVF       _lvalue+1, 0
	MOVWF      R0+1
	MOVF       _lvalue+2, 0
	MOVWF      R0+2
	MOVF       _lvalue+3, 0
	MOVWF      R0+3
	CALL       _Compare_Double+0
	MOVLW      1
	BTFSS      STATUS+0, 0
	MOVLW      0
	MOVWF      R0+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main28
;subtrai os bits do _lvalue com _rvalue
	MOVF       _rvalue+0, 0
	MOVWF      R4+0
	MOVF       _rvalue+1, 0
	MOVWF      R4+1
	MOVF       _rvalue+2, 0
	MOVWF      R4+2
	MOVF       _rvalue+3, 0
	MOVWF      R4+3
	MOVF       _lvalue+0, 0
	MOVWF      R0+0
	MOVF       _lvalue+1, 0
	MOVWF      R0+1
	MOVF       _lvalue+2, 0
	MOVWF      R0+2
	MOVF       _lvalue+3, 0
	MOVWF      R0+3
	CALL       _Sub_32x32_FP+0
	MOVF       R0+0, 0
	MOVWF      _lvalue+0
	MOVF       R0+1, 0
	MOVWF      _lvalue+1
	MOVF       R0+2, 0
	MOVWF      _lvalue+2
	MOVF       R0+3, 0
	MOVWF      _lvalue+3
;reset da flag de negativo>positivo
	BCF        _flags+0, 1
;jump para final de rotina de subtração
	GOTO       L_main29
L_main28:
;subtrai os bits do _rvalue com _lvalue
	MOVF       _lvalue+0, 0
	MOVWF      R4+0
	MOVF       _lvalue+1, 0
	MOVWF      R4+1
	MOVF       _lvalue+2, 0
	MOVWF      R4+2
	MOVF       _lvalue+3, 0
	MOVWF      R4+3
	MOVF       _rvalue+0, 0
	MOVWF      R0+0
	MOVF       _rvalue+1, 0
	MOVWF      R0+1
	MOVF       _rvalue+2, 0
	MOVWF      R0+2
	MOVF       _rvalue+3, 0
	MOVWF      R0+3
	CALL       _Sub_32x32_FP+0
	MOVF       R0+0, 0
	MOVWF      _lvalue+0
	MOVF       R0+1, 0
	MOVWF      _lvalue+1
	MOVF       R0+2, 0
	MOVWF      _lvalue+2
	MOVF       R0+3, 0
	MOVWF      _lvalue+3
;reset da flag de positivo>negativo
	BSF        _flags+0, 1
;final da rotina de subtração 
L_main29:
;jump para final da estrutura condicional "op"
	GOTO       L_main25
;********************************************************************************
	
	
;********************************************************************************
; Rotina para divisão das parcelas (main_op_L == '/')				*
;********************************************************************************
L_main30:
;divide os bits do _lvalue com _rvalue
	MOVF       _rvalue+0, 0
	MOVWF      R4+0
	MOVF       _rvalue+1, 0
	MOVWF      R4+1
	MOVF       _rvalue+2, 0
	MOVWF      R4+2
	MOVF       _rvalue+3, 0
	MOVWF      R4+3
	MOVF       _lvalue+0, 0
	MOVWF      R0+0
	MOVF       _lvalue+1, 0
	MOVWF      R0+1
	MOVF       _lvalue+2, 0
	MOVWF      R0+2
	MOVF       _lvalue+3, 0
	MOVWF      R0+3
	CALL       _Div_32x32_FP+0
	MOVF       R0+0, 0
	MOVWF      _lvalue+0
	MOVF       R0+1, 0
	MOVWF      _lvalue+1
	MOVF       R0+2, 0
	MOVWF      _lvalue+2
	MOVF       R0+3, 0
	MOVWF      _lvalue+3
;fim da rotina de divisão e jump para final da estrutura condicional "op"
	GOTO       L_main25
;********************************************************************************
	
	
;********************************************************************************
; Rotina para multiplicação das parcelas (main_op_L == '*')			*
;********************************************************************************
L_main31:
;multiplica os bits do _lvalue com _rvalue
	MOVF       _lvalue+0, 0
	MOVWF      R0+0
	MOVF       _lvalue+1, 0
	MOVWF      R0+1
	MOVF       _lvalue+2, 0
	MOVWF      R0+2
	MOVF       _lvalue+3, 0
	MOVWF      R0+3
	MOVF       _rvalue+0, 0
	MOVWF      R4+0
	MOVF       _rvalue+1, 0
	MOVWF      R4+1
	MOVF       _rvalue+2, 0
	MOVWF      R4+2
	MOVF       _rvalue+3, 0
	MOVWF      R4+3
	CALL       _Mul_32x32_FP+0
	MOVF       R0+0, 0
	MOVWF      _lvalue+0
	MOVF       R0+1, 0
	MOVWF      _lvalue+1
	MOVF       R0+2, 0
	MOVWF      _lvalue+2
	MOVF       R0+3, 0
	MOVWF      _lvalue+3
;fim da rotina de multiplicação e jump para final da estrutura condicional "op"
	GOTO       L_main25
;********************************************************************************
	
	
;********************************************************************************
; Rotina para converter de número real para texto				*
;********************************************************************************
L_main25:
;conversão de bits do número real para texto
	MOVF       _lvalue+0, 0
	MOVWF      FARG_FloatToStr_fnum+0
	MOVF       _lvalue+1, 0
	MOVWF      FARG_FloatToStr_fnum+1
	MOVF       _lvalue+2, 0
	MOVWF      FARG_FloatToStr_fnum+2
	MOVF       _lvalue+3, 0
	MOVWF      FARG_FloatToStr_fnum+3
	CLRF       R0+0
	BTFSC      _flags+0, 1
	INCF       R0+0, 1
	MOVF       R0+0, 0
	ADDLW      _resultado+0
	MOVWF      FARG_FloatToStr_str+0
	CALL       _FloatToStr+0
;verificação da flag para caso negativo e concatenação do '-'
	BTFSS      _flags+0, 1
	GOTO       L_main32
	MOVLW      45
	MOVWF      _resultado+0
;********************************************************************************
	
	
;********************************************************************************
; Rotina para imprimir resultado no LCD						*
;********************************************************************************
L_main32:
;impressão do resultado na linha 2, coluna 1
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      _resultado+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;atualização da flag de finalização de cálculo
	BSF        _flags+0, 0
;********************************************************************************
	
	
;********************************************************************************
; Rotina de finalização de laços de controle					*
;********************************************************************************	
;fim da rotina de cálculo da operação
L_main23:
L_main22:
L_main15:
;delay de 200 ms
	MOVLW      3
	MOVWF      R11+0
	MOVLW      8
	MOVWF      R12+0
	MOVLW      119
	MOVWF      R13+0
;decremento iterativo para zerar registradores do delay
L_main33:
	DECFSZ     R13+0, 1
	GOTO       L_main33
	DECFSZ     R12+0, 1
	GOTO       L_main33
	DECFSZ     R11+0, 1
	GOTO       L_main33
;fim do laço de loop do algoritmo
	GOTO       L_main1
;fim da função principal
L_end_main:
	GOTO       $+0

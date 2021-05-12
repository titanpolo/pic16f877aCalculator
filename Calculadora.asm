;********************************************************************************
; Rotina que faz a varredura do teclado e retorna o valor da tecla pressionada	*
;********************************************************************************
Calculadora_keyRead:
;Calculadora.c,19 :: 		static char keyRead(char keys[])
;Calculadora.c,23 :: 		key = keypad_key_press();
	CALL       _Keypad_Key_Press+0
	MOVF       R0+0, 0
	MOVWF      Calculadora_keyRead_key_L0+0
;Calculadora.c,24 :: 		if(key!=0) return keys[key-1];
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
;Calculadora.c,25 :: 		return 0;
	CLRF       R0+0
;Calculadora.c,26 :: 		}
L_end_keyRead:
	RETURN
; end of Calculadora_keyRead
;********************************************************************************
; Rotina de inicialização do sistema						*
;********************************************************************************
_main:
;Calculadora.c,28 :: 		void main()
;Calculadora.c,32 :: 		keypad_init();
	CALL       _Keypad_Init+0
;Calculadora.c,33 :: 		Lcd_Init();
	CALL       _Lcd_Init+0
;Calculadora.c,34 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;Calculadora.c,35 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;Calculadora.c,37 :: 		while(1)
;********************************************************************************
; Rotina de verificações de estados do sistema					*
;********************************************************************************
L_main1:
;Calculadora.c,39 :: 		k = keyRead(teclas);//leitura do teclado
	MOVLW      _teclas+0
	MOVWF      FARG_Calculadora_keyRead_keys+0
	CALL       Calculadora_keyRead+0
	MOVF       R0+0, 0
	MOVWF      main_k_L0+0
;Calculadora.c,41 :: 		if(CALCULO_OK && k)
	BTFSS      _flags+0, 0
	GOTO       L_main5
	MOVF       main_k_L0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main5
;********************************************************************************
; Rotina de reset de display							*
;********************************************************************************
L__main37:
;Calculadora.c,43 :: 		pos = 0;//reseta posicao
	CLRF       main_pos_L0+0
;Calculadora.c,44 :: 		CALCULO_OK = 0;//reseta calculo
	BCF        _flags+0, 0
;Calculadora.c,45 :: 		lcd_clear();//limpa display
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;Calculadora.c,46 :: 		lcd_cmd(_LCD_RETURN_HOME);
	MOVLW      2
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;Calculadora.c,47 :: 		for(i=0;i<8;i++){//limpa as variaveis
	CLRF       main_i_L0+0
;********************************************************************************
; Rotina de reset de variáveis							*
;********************************************************************************
L_main6:
	MOVLW      8
	SUBWF      main_i_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main7
;Calculadora.c,48 :: 		*(numero + i) = 0;
	MOVF       main_i_L0+0, 0
	ADDLW      _numero+0
	MOVWF      FSR
	CLRF       INDF+0
;Calculadora.c,49 :: 		*(resultado + i) = 0;
	MOVF       main_i_L0+0, 0
	ADDLW      _resultado+0
	MOVWF      FSR
	CLRF       INDF+0
;Calculadora.c,50 :: 		*(resultado +i + 8) = 0;
	MOVF       main_i_L0+0, 0
	ADDLW      _resultado+0
	MOVWF      R0+0
	MOVLW      8
	ADDWF      R0+0, 0
	MOVWF      FSR
	CLRF       INDF+0
;Calculadora.c,47 :: 		for(i=0;i<8;i++){//limpa as variaveis
	INCF       main_i_L0+0, 1
;Calculadora.c,51 :: 		}
	GOTO       L_main6
L_main7:
;Calculadora.c,52 :: 		}
;********************************************************************************
; Rotina de entrada das parcelas						*
;********************************************************************************
L_main5:
;Calculadora.c,55 :: 		if((k>='0' && k<='9') || k=='.')
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
;Calculadora.c,57 :: 		*(numero + pos++) = k;
	MOVF       main_pos_L0+0, 0
	ADDLW      _numero+0
	MOVWF      FSR
	MOVF       main_k_L0+0, 0
	MOVWF      INDF+0
	INCF       main_pos_L0+0, 1
;Calculadora.c,58 :: 		if(pos >= 8) pos = 0;
	MOVLW      8
	SUBWF      main_pos_L0+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_main14
	CLRF       main_pos_L0+0
L_main14:
;Calculadora.c,59 :: 		lcd_Out_CP((numero+(pos-1)));
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
;Calculadora.c,60 :: 		}
	GOTO       L_main15
;********************************************************************************
; Rotina de entrada da operação matemática					*
;********************************************************************************
L_main13:
;Calculadora.c,61 :: 		else if(k == '+' || k=='-' || k=='/' || k=='*')
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
;Calculadora.c,63 :: 		op = k;
	MOVF       main_k_L0+0, 0
	MOVWF      main_op_L0+0
;Calculadora.c,64 :: 		pos = 0;
	CLRF       main_pos_L0+0
;Calculadora.c,65 :: 		lcd_chr_CP(op);
	MOVF       main_k_L0+0, 0
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Calculadora.c,66 :: 		lvalue = atof(numero);
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
;Calculadora.c,67 :: 		LimparNumero;
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
;Calculadora.c,68 :: 		}
	GOTO       L_main22
;********************************************************************************
; Rotina de comando do resultado						*
;********************************************************************************
L_main18:
;Calculadora.c,69 :: 		else if(k == '=')
	MOVF       main_k_L0+0, 0
	XORLW      61
	BTFSS      STATUS+0, 2
	GOTO       L_main23
;Calculadora.c,71 :: 		rvalue = atof(numero);
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
;Calculadora.c,72 :: 		NEGATIVO = 0;
	BCF        _flags+0, 1
;Calculadora.c,73 :: 		lcd_chr_CP('=');
	MOVLW      61
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;Calculadora.c,75 :: 		switch(op)
	GOTO       L_main24
;Calculadora.c,77 :: 		case '+':
;********************************************************************************
; Rotina para soma das parcelas							*
;********************************************************************************
L_main26:
;Calculadora.c,78 :: 		lvalue += rvalue;
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
;Calculadora.c,79 :: 		break;
	GOTO       L_main25
;Calculadora.c,80 :: 		case '-':
;********************************************************************************
; Rotina para subtração das parcelas						*
;********************************************************************************
L_main27:
;Calculadora.c,81 :: 		if(lvalue >= rvalue)
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
;Calculadora.c,83 :: 		lvalue -= rvalue;
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
;Calculadora.c,84 :: 		NEGATIVO = 0;
	BCF        _flags+0, 1
;Calculadora.c,85 :: 		}
	GOTO       L_main29
L_main28:
;Calculadora.c,88 :: 		lvalue = rvalue - lvalue;
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
;Calculadora.c,89 :: 		NEGATIVO = 1;
	BSF        _flags+0, 1
;Calculadora.c,90 :: 		}
L_main29:
;Calculadora.c,91 :: 		break;
	GOTO       L_main25
;Calculadora.c,92 :: 		case '/':
;********************************************************************************
; Rotina para divisão das parcelas						*
;********************************************************************************
L_main30:
;Calculadora.c,93 :: 		lvalue /= rvalue;
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
;Calculadora.c,94 :: 		break;
	GOTO       L_main25
;Calculadora.c,95 :: 		case '*':
;********************************************************************************
; Rotina para multiplicação das parcelas					*
;********************************************************************************
L_main31:
;Calculadora.c,96 :: 		lvalue *= rvalue;
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
;Calculadora.c,97 :: 		break;
	GOTO       L_main25
;Calculadora.c,98 :: 		}
L_main24:
	MOVF       main_op_L0+0, 0
	XORLW      43
	BTFSC      STATUS+0, 2
	GOTO       L_main26
	MOVF       main_op_L0+0, 0
	XORLW      45
	BTFSC      STATUS+0, 2
	GOTO       L_main27
	MOVF       main_op_L0+0, 0
	XORLW      47
	BTFSC      STATUS+0, 2
	GOTO       L_main30
	MOVF       main_op_L0+0, 0
	XORLW      42
	BTFSC      STATUS+0, 2
	GOTO       L_main31
;********************************************************************************
; Rotina para converter número real para texto					*
;********************************************************************************
L_main25:
;Calculadora.c,100 :: 		floattostr(lvalue, resultado  + NEGATIVO);
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
;Calculadora.c,101 :: 		if(NEGATIVO) *(resultado) = '-';
	BTFSS      _flags+0, 1
	GOTO       L_main32
	MOVLW      45
	MOVWF      _resultado+0
;********************************************************************************
; Rotina para imprimir resultado no LCD						*
;********************************************************************************
L_main32:
;Calculadora.c,102 :: 		lcd_out(2,1,resultado);
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      _resultado+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;Calculadora.c,103 :: 		CALCULO_OK = 1;
	BSF        _flags+0, 0
;Calculadora.c,104 :: 		}
L_main23:
L_main22:
L_main15:
;Calculadora.c,105 :: 		delay_ms(200);
	MOVLW      3
	MOVWF      R11+0
	MOVLW      8
	MOVWF      R12+0
	MOVLW      119
	MOVWF      R13+0
L_main33:
	DECFSZ     R13+0, 1
	GOTO       L_main33
	DECFSZ     R12+0, 1
	GOTO       L_main33
	DECFSZ     R11+0, 1
	GOTO       L_main33
;Calculadora.c,106 :: 		}
	GOTO       L_main1
;Calculadora.c,107 :: 		}
L_end_main:
	GOTO       $+0
; end of _main

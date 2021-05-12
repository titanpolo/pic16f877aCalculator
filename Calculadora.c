 /* *Projeto: Calculadora *MCU: PIC16F877A *Clock: HS 8MHz *Descrição: Simples calculadora *Compilador: MikroC PRO PIC *Autor: Tiago H. Melo*/
    char keypadPort at PORTD;
    sbit LCD_RS at RB0_bit; sbit LCD_RS_Direction at TRISB0_bit;
    sbit LCD_EN at RB1_bit; sbit LCD_EN_Direction at TRISB1_bit;
    sbit LCD_D4 at RB2_bit; sbit LCD_D4_Direction at TRISB2_bit;
    sbit LCD_D5 at RB3_bit; sbit LCD_D5_Direction at TRISB3_bit;
    sbit LCD_D6 at RB4_bit; sbit LCD_D6_Direction at TRISB4_bit;
    sbit LCD_D7 at RB5_bit; sbit LCD_D7_Direction at TRISB5_bit;
    char teclas[] = {'7','8','9','/','4','5','6','*','1','2','3','-','.','0','=','+'};
    char numero[9];
    float lvalue, rvalue;
    char op, flags, resultado[16];
    #define CALCULO_OK flags.F0
    #define NEGATIVO flags.F1
    #define lcd_clear() lcd_cmd(_LCD_CLEAR);
    #define LimparNumero for(i=0;i<8;i++) *(numero + i) = 0;
    
    //esta funcao faz a varredura do teclado e retorna o valor da tecla pressionada
    char keyRead(char keys[])
    {
    	
	    char key;
	    key = keypad_key_press();
	    if(key != 0) return keys[key-1];
	    return 0;
    }
    
    void main()
    {
	    char k, pos, op, i;
	    keypad_init();
	    Lcd_Init();
	    Lcd_Cmd(_LCD_CLEAR);
	    Lcd_Cmd(_LCD_CURSOR_OFF);
	    while(1)
	    {
		    k = keyRead(teclas); //leitura do teclado
		    if(CALCULO_OK)
	    	{
			    pos = 0; //reseta posicao
			    CALCULO_OK = 0; //reseta calculo
			    lcd_clear(); //limpa display
			    lcd_cmd(_LCD_RETURN_HOME);
			    for(i=0;i<8;i++){ //limpa as variaveis
				    *(numero + i) = 0;
				    *(resultado + i) = 0;
				    *(resultado +i + 8) = 0;
		    	}
	    	} //se a teclas pressiona for um numero
		    if((k>='0' && k<='9') || k=='.')
		    {
			    *(numero + pos++) = k;
			    if(pos >= 8) pos = 0;
			    lcd_Out_CP((numero+(pos-1)));
		    }
		    else if(k == '+' || k=='-' || k=='/' || k=='*')
		    {
			    op = k;
			    pos = 0;
			    lcd_chr_CP(op);
			    lvalue = atof(numero);
			    LimparNumero;
	    	}
		    else if(k == '=')
		    {
			    rvalue = atof(numero);
			    NEGATIVO = 0;
			    lcd_chr_CP('=');
			    switch(op)
			    {
				    case '+':
				    lvalue += rvalue;
				    break;
				    case '-':
				    if(lvalue >= rvalue)
				    {
				    	lvalue -= rvalue;
				    }
				    else
				    {
					    lvalue = rvalue - lvalue;
					    NEGATIVO = 1;
				    }
				    break;
				    case '/':
				    if(rvalue!=0)lvalue /= rvalue;
				    else lvalue = 0;
				    break;
				    case '*':
				    lvalue *= rvalue;
				    break;
			    }
			     //converte numero para string
			    floattostr(lvalue, (resultado + NEGATIVO));
			    if(NEGATIVO) *(resultado) = '-';
			    lcd_out(2, 1, resultado);
			    CALCULO_OK = 1;
			}
		    delay_ms(200);
	    }
    }

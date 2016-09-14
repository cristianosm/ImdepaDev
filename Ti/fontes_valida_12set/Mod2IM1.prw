#INCLUDE 'INKEY.CH' 
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'FIVEWIN.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#DEFINE  ENTER CHR(13)+CHR(10)

/*                                                                                                                                    
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Mod2IM1        ºAutor ³Fabiano Pereiraº Data ³ 17/09/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para Importar, Ajustar Planilha de Curva.           º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±³Observacao³                                                            º±±
±±³          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ IMDEPA - Protheus 11                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
*********************************************************************
User Function Mod2IM1()
*********************************************************************
Local 	aArea 		:=	GetArea()
Local 	cTabela 	:= 	'IM1' 
Local 	cTitulo 	:= 	SX2->(DbGoTop(), DbSeek(cTabela, .F.), SX2->X2_NOME)

Private cOpcao 		:= 	ParamIxb[01]
Private aHeader		:=	{} 
Private aBkpCols 	:= 	{}
Private aCols		:=	{}
Private aArqTemp	:=	{}
Private aCGD		:=  {}
Private aCordW		:=	{}
Private lDelGetD	:=	.T.
Private lMaximazed	:=	.T.

Private aHReplic 	:= 	{}
Private aCReplic 	:= 	{}

Private nPFilRepl  	:= 	0
Private nPosSeg    	:= 	0
Private nPosMarca  	:= 	0		
Private lNewCpo		:= 	.F.
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  VERIFICA SE Eh IMPORTACAO DO EXCEL             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cOpcao == 'IMPORT'

	If TelaImpCurva()
    	cOpcao := 'VISUAL'
		DbSelectArea('IM1');DbGoTop()
    Else
		Return()
	EndIf

EndIf



IIF(!ExisteSX6('IMD_AMBIEN'),	CriarSX6('IMD_AMBIEN', 'C','Ambiente\Filiais que utilizam novo cocnceito do campo IMC.Min', '{{"SOLUTIO", "*"},{"VALIDA","*"}}' ),)
aAmbiente := &(GetMv('IMD_AMBIEN'))



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Montando aHeader para a Getdados               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*
DbSelectArea('SX3');DbSetOrder(1);DbGoTop()
DbSeek(cTabela)
Do While !Eof() .And. (X3_ARQUIVO == cTabela)
	Aadd(aHeader,{ Trim(X3_TITULO), X3_CAMPO, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, '', X3_USADO, X3_TIPO, X3_F3})   //X3_ARQUIVO, X3_CONTEXT })
	DbSkip()
EndDo
*/

DbSelectArea('SX3');DbSetOrder(2);DbGoTop()	
DbSeek('IM1_COD'	); 	Aadd(aHeader,{ Trim(X3_TITULO),  X3_CAMPO	, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, '', X3_USADO, X3_TIPO, X3_F3  })	
DbSeek('IM1_DESC'	); 	Aadd(aHeader,{ Trim(X3_TITULO),  X3_CAMPO	, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, '', X3_USADO, X3_TIPO, X3_F3  })	
DbSeek('IM1_CODGM3'	); 	Aadd(aHeader,{ Trim(X3_TITULO),  X3_CAMPO	, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, '', X3_USADO, X3_TIPO, X3_F3  })
DbSeek('IM1_DESGM3'	); 	Aadd(aHeader,{ Trim(X3_TITULO),  X3_CAMPO	, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, '', X3_USADO, X3_TIPO, X3_F3  })
DbSeek('IM1_TRAVAM' ); 	Aadd(aHeader,{ Trim(X3_TITULO),  X3_CAMPO	, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, '', X3_USADO, X3_TIPO, X3_F3  })
DbSeek('IM1_MARKUP'	); 	Aadd(aHeader,{ Trim(X3_TITULO),  X3_CAMPO	, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, '', X3_USADO, X3_TIPO, X3_F3  })	
DbSeek('IM1_ALCMAX'	); 	Aadd(aHeader,{ Trim(X3_TITULO),  X3_CAMPO	, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, '', X3_USADO, X3_TIPO, X3_F3  })	
DbSeek('IM1_ALCMED'	); 	Aadd(aHeader,{ Trim(X3_TITULO),  X3_CAMPO	, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, '', X3_USADO, X3_TIPO, X3_F3  })	
DbSeek('IM1_IMCMIN'	); 	Aadd(aHeader,{ Trim(X3_TITULO),  X3_CAMPO	, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, '', X3_USADO, X3_TIPO, X3_F3  })	
DbSeek('IM1_MKPM35'	); 	Aadd(aHeader,{ Trim(X3_TITULO),  X3_CAMPO	, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, '', X3_USADO, X3_TIPO, X3_F3  })	
DbSeek('IM1_MKPPR1'	); 	Aadd(aHeader,{ Trim(X3_TITULO),  X3_CAMPO	, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, '', X3_USADO, X3_TIPO, X3_F3  })	
DbSeek('IM1_MKPPR2'	); 	Aadd(aHeader,{ Trim(X3_TITULO),  X3_CAMPO	, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, '', X3_USADO, X3_TIPO, X3_F3  })	
DbSeek('IM1_MKPPR3'	); 	Aadd(aHeader,{ Trim(X3_TITULO),  X3_CAMPO	, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, '', X3_USADO, X3_TIPO, X3_F3  })	
DbSeek('IM1_MKPPR4'	); 	Aadd(aHeader,{ Trim(X3_TITULO),  X3_CAMPO	, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, '', X3_USADO, X3_TIPO, X3_F3  })	
DbSeek('IM1_NEWIMC' ); 	Aadd(aHeader,{ Trim(X3_TITULO),  X3_CAMPO	, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, '', X3_USADO, X3_TIPO, X3_F3  })	
DbSeek('IM1_REPLIC'	); 	Aadd(aHeader,{ Trim(X3_TITULO),  X3_CAMPO	, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, '', X3_USADO, X3_TIPO, X3_F3  })	






//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Montando aCols para a GetDados					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cOpcao != 'INCLUI'

	IIF(Select("SQL") != 0, SQL->( DbCLoseArea() ), )
	cQuery := ""
	cQuery += "	SELECT	* "+ENTER	
	cQuery += "	FROM	" +RetSqlName('IM1')+"  "+ENTER
	cQuery += "	WHERE	IM1_FILIAL	= 	'"+xFilial('IM1')+"'	"+ENTER  				
	cQuery += "	AND		IM1_SEGMEN	=	'"+IM1->IM1_SEGMEN+"'  	"+ENTER
	cQuery += "	AND		D_E_L_E_T_ 	!= 	'*'	  		 			"+ENTER
	cQuery += "	ORDER BY IM1_SEGMEN								"+ENTER

	//MemoWrit(GetTempPath()+"Mod2IM1.TXT", cQuery)            
	MsAguarde({|| DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),'SQL',.F.,.F.)},'Aguarde...','' )
	DbSelectArea('SQL');DbGoTop()
	Do While !Eof()


			Aadd(aCols, {	SQL->IM1_COD, SQL->IM1_DESC,;
							SQL->IM1_CODGM3, Posicione('SX5', 1, xFilial('SX5') +'Z8'+ SQL->IM1_CODGM3, 'X5_DESCRI'),;
							SQL->IM1_TRAVAM,;
							SQL->IM1_MARKUP, SQL->IM1_ALCMAX, SQL->IM1_ALCMED, SQL->IM1_IMCMIN,;
							SQL->IM1_MKPM35, SQL->IM1_MKPPR1, SQL->IM1_MKPPR2, SQL->IM1_MKPPR3,;
							SQL->IM1_MKPPR4, SQL->IM1_NEWIMC, SQL->IM1_REPLIC, .F. })
		DbSkip()
	EndDo
	IIF(Select("SQL") != 0, SQL->( DbCLoseArea() ), )
	aBkpCols := aCols
EndIf



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Variaveis do Cabecalho do Modelo 2				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSegmento := IIF(cOpcao!= 'INCLUI', IM1->IM1_SEGMEN , Space(TamSx3('IM1_SEGMEN')[01]))


	cDesSeg		:= 	''
	aTabelas  	:=  &(GetMv('MV_SEGXTAB'))  // {{"1","OEM", "INDUSTRIA"},{"2","MNT","MANUTENCAO"},{"3","REV","REVENDA"}
	nPSeg 	  	:=  Ascan(aTabelas, {|X| AllTrim(X[2]) == AllTrim(IM1->IM1_SEGMEN) })
	If nPSeg == 0
		cDesSeg	:= 	AllTrim(aTabelas[nPSeg][03])
	EndIf	
	cDesSeg   	:= IIF(cOpcao!= 'INCLUI', cDesSeg, Space(TamSx3('IM1_DESSEG')[01]))


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array com descricao dos campos do Cabecalho     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aC := {}
Aadd(aC,{"cSegmento",{20,010},"Segmento: ","@!","ExistCpo('ZZV'),cDesSeg := Posicione('ZZV',1,xFilial('ZZV')+cSegmento, 'ZZV_DESC')","ZZV", IIF(cOpcao == "INCLUI", .T., .F.) }) 
Aadd(aC,{"cDesSeg"  ,{20,100},"Descricao: ","@!","",,.F.}) 

//+----------------------------------------------+
// 	Variaveis do Rodape do Modelo 2
//+----------------------------------------------+
// nLinGetD := 0 

//+-------------------------------------------------+
//¦ Array com descricao dos campos do Rodape        
//+-------------------------------------------------+
aR:={}
// Aadd(aR,{"nLinGetD" ,{120,10},"Linha na GetDados", "@E 999",,,.F.})


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array com coordenadas da GetDados no modelo2    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF WINDOWS
   aCGD:={D(44),D(05),D(228),D(315)}  
#ELSE
   aCGD:={D(10),D(04),D(15),D(73)}
#ENDIF 

aCordW := { D(125),D(100),D(600),D(735)} //aCGD


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validacoes na GetDados da Modelo 2     			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cLinhaOk := 'AllwaysTrue()' // "ExecBlock('Md2LinOk',.f.,.f.)"
cTudoOk  := "ExecBlock('Md2IM1TudOk',.F.,.F.)"


cDescOp := ''
If cOpcao == "INCLUI"
	nOpcx 	:= 	3	//	INCLUI NOVOS 
	cDescOp	:=	' - INCLUSÃO'

ElseIf cOpcao == "ALTERA"
	nOpcx := 4	//	 4 - ALTERA E PERMITE INCLUIR NOVOS ITENS / 6 - ALTERA - NAO INCLUI NOVOS ITENS
	cDescOp	:=	' - ALTERAÇÃO'

Else

	nOpcx := 0	//	QQ OUTRO NUM. APENAS VISUALIZA
	
	If 	cOpcao == "VISUAL"
		cDescOp	:=	' - VISUALIZAÇÃO'
    ElseIf cOpcao == "EXCLUI"
    	cDescOp	:=	' - EXCLUSÃO'
    EndIf

EndIf 
                                                                 


nMax := 999


// Modelo2(        cTitulo          [ aC ] [ aR ] [ aGd ] [ nOp ] [ cLinhaOk ] [ cTudoOk ] aGetsD [ bF4 ] [ cIniCpos ] [ nMax ] [ aCordW ] [ lDelGetD ] [ lMaximazed ] [ aButtons ] ) 
If Modelo2(AllTrim(cTitulo)+cDescOp, aC,     aR,   aCGD,  nOpcx,  cLinhaOk,    cTudoOk,;
           /*aGetsD*/, /*{|| Alert('Md2IM1F4()')}*/ ,/*[cIniCpos]*/, nMax,  aCordW,   lDelGetD,   lMaximazed,  /*[ aButtons ]*/ )


	nPCod := Ascan(aHeader,{|x| AllTrim(x[2]) == 'IM1_COD' })

	//	VALIDACAO PARA INCLUSAO\ALTERACAO
	If cOpcao == "INCLUI"
		
		lExclui	:= .F.
		For nX:=1 To Len(aCols)

			If !aCols[nX][Len(aHeader)+1]
				GravaIM1('INCLUI',nX)
				lExclui := .T.
		    EndIf
		
		Next

		IIF(lExclui, MsgInfo('ITEM EXCLUIDO COM SUCESSO!!!'), )
		
	ElseIf cOpcao == "ALTERA"
	
		lAltera := .F.
		For nX:=1 To Len(aCols)

			DbSelectArea('IM1');DbSetOrder(2);DbGoTop()		//	IM1_FILIAL+IM1_SEGMEN+IM1_COD
			If DbSeek(xFilial('IM1')+cSegmento+aCols[nX][nPCod], .F.)
           		
           		If !aCols[nX][Len(aHeader)+1]
					GravaIM1('ALTERA',nX) 
				Else          					
					GravaIM1('EXCLUI',nX)
           	  	EndIf
           	  	lAltera := .T.
            
            Else
            	GravaIM1('INCLUI',nX)
				lAltera := .T.
			EndIf
    
		Next
        
		IIF(lAltera, MsgInfo('ITEM(s) ALTERADO(s) COM SUCESSO!!!'), )
		

	ElseIf cOpcao == 'EXCLUI'

		GravaIM1('EXCLUI_TODOS')
	    MsgInfo('ITEM(s) EXCLUIDO(s) COM SUCESSO!!!')

	EndIf


EndIf

IIF(Select("SQL") != 0, SQL->( DbCLoseArea() ), )
//    APAGA ARQUIVOS TEMPORARIOS
If Len(aArqTemp) > 0
   For nX := 1 To Len(aArqTemp)
       FErase( aArqTemp[nX] )
   Next
EndIf

Return()
*********************************************************************
Static Function GravaIM1(cOpcao, nLinha)
*********************************************************************
cFilBck	  :=	cFilAnt
aRet	  := 	{}
nPGrpMar  :=	Ascan(aHeader,{|x| AllTrim(x[2]) == 'IM1_CODGM3' 	})
nPCod	  :=	Ascan(aHeader,{|x| AllTrim(x[2]) == 'IM1_COD'		})
nPDesc	  :=	Ascan(aHeader,{|x| AllTrim(x[2]) == 'IM1_DESC'		})
nPMarkUp  :=	Ascan(aHeader,{|x| AllTrim(x[2]) == 'IM1_MARKUP'	})
nPAlcMax  :=	Ascan(aHeader,{|x| AllTrim(x[2]) == 'IM1_ALCMAX'	})
nPAlcMed  :=	Ascan(aHeader,{|x| AllTrim(x[2]) == 'IM1_ALCMED'	})
nPImcMin  :=	Ascan(aHeader,{|x| AllTrim(x[2]) == 'IM1_IMCMIN'	})
nPMkpM35  :=	Ascan(aHeader,{|x| AllTrim(x[2]) == 'IM1_MKPM35'	})
nPMkpPr1  :=	Ascan(aHeader,{|x| AllTrim(x[2]) == 'IM1_MKPPR1'	})
nPMkpPr2  :=	Ascan(aHeader,{|x| AllTrim(x[2]) == 'IM1_MKPPR2'	})
nPMkpPr3  :=	Ascan(aHeader,{|x| AllTrim(x[2]) == 'IM1_MKPPR3'	})
nPMkpPr4  :=	Ascan(aHeader,{|x| AllTrim(x[2]) == 'IM1_MKPPR4'	})
nPReplic  :=	Ascan(aHeader,{|x| AllTrim(x[2]) == 'IM1_REPLIC'	})
nPTravaM  :=	Ascan(aHeader,{|x| AllTrim(x[2]) == 'IM1_TRAVAM' 	})
nPNewIMC  :=	Ascan(aHeader,{|x| AllTrim(x[2]) == 'IM1_NEWIMC' 	})

If cOpcao == 'EXCLUI'

	//GRAVA LOG TABELA DE CURVA
	U_GravaLogCurva(nLinha, cOpcao)   
	
	RecLock('IM1', .F.)
    	DbDelete()
	MsUnLock()


	cFilBck	 :=	cFilAnt
	RecnoIM1 := IM1->(Recno())

	If AllTrim(aCols[nLinha][nPReplic])=='S' .And. Len(aCReplic) > 0
		If Ascan(aCReplic, {|X| X[1] != '' } ) > 0
			For nR := 1 To Len(aCReplic)
				If !Empty(aCReplic[nR][nPosMarca])

					//Aadd(aCReplic, {'', AllTrim(SQL->FILIAL), AllTrim(SQL->SEGMENTO), AllTrim(Posicione('ZZV',1,xFilial('ZZV')+SQL->SEGMENTO, 'ZZV_DESC')), .F.})
					cFilRepl	:=	aCReplic[nR][nPFilRepl]
					cReplicSeg 	:= 	aCReplic[nR][nPosSeg]
					cFilAnt		:=	cFilRepl
					DbSelectArea('IM1');DbSetOrder(2);DbGoTop()		//	IM1_FILIAL+IM1_SEGMEN+IM1_COD
					If DbSeek(cFilRepl+cReplicSeg+aCols[nLinha][nPCod], .F.)    						
						RecLock('IM1', .F.)
							DbDelete()
					    MsUnLock()
                    EndIf

			    EndIf
		    Next
        EndIf
    EndIf

	cFilAnt	:= cFilBck
	DbSelectArea('IM1')
	DbGoTo(RecnoIM1)
	           	    
ElseIf cOpcao == 'EXCLUI_TODOS'

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  DELETA ITENS    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea('IM1');DbSetOrder(2);DbGoTop()		//	IM1_FILIAL+IM1_SEGMEN+IM1_COD
		If DbSeek(xFilial('IM1')+cSegmento, .F.)
			Do While !Eof() .And. AllTrim(IM1->IM1_SEGMEN) == AllTrim(cSegmento)
           		
           		RecLock('IM1', .F.)
               		DbDelete()
           	  	MsUnLock()
           	    
           	 	DbSkip()
           	 EndDo
		EndIf
		
		
		cFilBck	 :=	cFilAnt
		RecnoIM1 := IM1->(Recno())
	
		If AllTrim(aCols[nLinha][nPReplic])=='S' .And. Len(aCReplic) > 0
			If Ascan(aCReplic, {|X| X[1] != '' } ) > 0
				For nR := 1 To Len(aCReplic)
					If !Empty(aCReplic[nR][nPosMarca])
	
						//Aadd(aCReplic, {'', AllTrim(SQL->FILIAL), AllTrim(SQL->SEGMENTO), AllTrim(Posicione('ZZV',1,xFilial('ZZV')+SQL->SEGMENTO, 'ZZV_DESC')), .F.})
						cFilRepl	:=	aCReplic[nR][nPFilRepl]
						cReplicSeg 	:= 	aCReplic[nR][nPosSeg]
						cFilAnt		:=	cFilRepl

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³  DELETA ITENS    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DbSelectArea('IM1');DbSetOrder(2);DbGoTop()		//	IM1_FILIAL+IM1_SEGMEN+IM1_COD
						If DbSeek(cFilRepl+cSegmento, .F.)
							Do While !Eof() .And. AllTrim(IM1->IM1_SEGMEN) == AllTrim(cSegmento)
				           		
				           		RecLock('IM1', .F.)
				               		DbDelete()
				           	  	MsUnLock()
				           	    
				           	 	DbSkip()
				           	 EndDo
						EndIf
	
				    EndIf
			    Next
	        EndIf
	    EndIf
	
		cFilAnt	:= cFilBck
		DbSelectArea('IM1')
		DbGoTo(RecnoIM1)
	

Else

	lGrava := IIF(cOpcao == 'INCLUI', .T., .F.)
	//	Aadd(aCReplic, '', AllTrim(ZZV->ZZV_COD), AllTrim(ZZV->ZZV_DESC), .F.)
	
	DbSelectArea('IM1')
	RecnoIM1 := IM1->(Recno())
    
	//GRAVA LOG TABELA DE CURVA
   	U_GravaLogCurva(nLinha, cOpcao)

	RecLock('IM1', lGrava)     
		IM1->IM1_FILIAL :=  xFilial("IM1")
		IM1->IM1_CODGM3	:=	aCols[nLinha][nPGrpMar]
		IM1->IM1_COD	:=	aCols[nLinha][nPCod]
		IM1->IM1_DESC	:=	aCols[nLinha][nPDesc]   
		IM1->IM1_SEGMEN :=  cSegmento
		IM1->IM1_TRAVAM	:=	aCols[nLinha][nPtravaM]
		IM1->IM1_MARKUP	:=	aCols[nLinha][nPMarkUp]
		IM1->IM1_ALCMAX	:=	aCols[nLinha][nPAlcMax]
		IM1->IM1_ALCMED	:=	aCols[nLinha][nPAlcMed]
		IM1->IM1_IMCMIN	:=	aCols[nLinha][nPImcMin]
		IM1->IM1_NEWIMC	:=	aCols[nLinha][nPNewIMC]
		IM1->IM1_MKPM35	:=	aCols[nLinha][nPMkpM35]
		IM1->IM1_MKPPR1	:=	aCols[nLinha][nPMkpPr1]
		IM1->IM1_MKPPR2	:=	aCols[nLinha][nPMkpPr2]	
		IM1->IM1_MKPPR3	:=	aCols[nLinha][nPMkpPr3]
		IM1->IM1_MKPPR4	:=	aCols[nLinha][nPMkpPr4]
    MsUnLock()
    

	If AllTrim(aCols[nLinha][nPReplic])=='S' .And. Len(aCReplic) > 0
	
		cFilBck := cFilAnt
		If Ascan(aCReplic, {|X| X[1] != '' } ) > 0
		
			For nR := 1 To Len(aCReplic)

				If !Empty(aCReplic[nR][nPosMarca])
	
					//Aadd(aCReplic, {'', AllTrim(SQL->FILIAL), AllTrim(SQL->SEGMENTO), AllTrim(Posicione('ZZV',1,xFilial('ZZV')+SQL->SEGMENTO, 'ZZV_DESC')), .F.})
					cFilRepl   := aCReplic[nR][nPFilRepl]
					cReplicSeg := aCReplic[nR][nPosSeg]
					
					DbSelectArea('IM1');DbSetOrder(2);DbGoTop()		//	IM1_FILIAL+IM1_SEGMEN+IM1_COD
					If DbSeek(cFilRepl+cReplicSeg+aCols[nLinha][nPCod], .F.)
						lGrava 	:=	.F.
					Else
						lGrava	:=	.T.
	                EndIf
	                
					DbSelectArea('IM1')
					RecLock('IM1', lGrava)
						IM1->IM1_FILIAL	:= 	cFilRepl
						IM1->IM1_SEGMEN	:=	cReplicSeg
						IM1->IM1_CODGM3	:=	aCols[nLinha][nPGrpMar]
						IM1->IM1_COD	:=	aCols[nLinha][nPCod]
						IM1->IM1_DESC	:=	aCols[nLinha][nPDesc]
						IM1->IM1_TRAVAM	:=	aCols[nLinha][nPtravaM]
						IM1->IM1_MARKUP	:=	aCols[nLinha][nPMarkUp]
						IM1->IM1_ALCMAX	:=	aCols[nLinha][nPAlcMax]
						IM1->IM1_ALCMED	:=	aCols[nLinha][nPAlcMed]
						IM1->IM1_IMCMIN	:=	aCols[nLinha][nPImcMin]
						IM1->IM1_NEWIMC	:=	aCols[nLinha][nPNewIMC]
						IM1->IM1_MKPM35	:=	aCols[nLinha][nPMkpM35]
						IM1->IM1_MKPPR1	:=	aCols[nLinha][nPMkpPr1]
						IM1->IM1_MKPPR2	:=	aCols[nLinha][nPMkpPr2]	
						IM1->IM1_MKPPR3	:=	aCols[nLinha][nPMkpPr3]
						IM1->IM1_MKPPR4	:=	aCols[nLinha][nPMkpPr4]
				    MsUnLock()

			    EndIf

		    Next
        
        EndIf

    EndIf

    cFilAnt := cFilBck
	DbSelectArea('IM1')
	DbGoTo(RecnoIM1)
	           	
EndIf

cFilAnt	:=	cFilBck
Return(aRet)
*********************************************************************
Static Function TelaImpCurva()
*********************************************************************
Local 	lRetImport	:=	.T.     
Local	aTabelas 	:= 	&(GetMv('MV_SEGXTAB'))  // {{"1","OEM", "INDUSTRIA"},{"2","MNT","MANUTENCAO"},{"3","REV","REVENDA"}
Private cDiretorio	:=	Space(200)
Private cArqCsv	:=	Space(200)
Private cMarca     :=	GetMark()
Private aGrpSeg	:=	{''}
Private cCBox	 	:= 	''

//DbSelectArea('ZZV');DbSetOrder(1);DbGoTop()
//Do While !Eof()
/*
For nZ := 1 To Len(aTabelas) 
	Aadd(aGrpSeg, AllTrim(aTabelas[nZ][2]))		
Next
*/

Aadd(aGrpSeg, 'FILIAL e SEGMENTO INFORMADO NO .CSV' )


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³    TELA CARREGA ARQUIVO .CSV    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDlg1      := MSDialog():New( D(095),D(232),D(427),D(740),"IMPORTA .CSV - PLANILHA CURVA",,,.F.,,,,,,.T.,,,.T. )
oGrp       := TGroup():New( D(004),D(004),D(146),D(250),"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )

oSay1      := TSay():New( D(012),D(008),{||"Caminho do Arquivo"},oGrp,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,D(064),D(008) )
oGet1      := TGet():New( D(020),D(008),{|u| If(PCount()>0,cDiretorio :=u,cDiretorio)},oGrp,D(230),D(008),'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,{|| /**/ },.F.,.F.,"","",,)

oBtn1      := TButton():New( D(018),D(238),"...",oGrp,{|| cDiretorio  := 	cGetFile("Anexos (*csv)|*csv|","Arquivo (*csv)",0,'',.T.,GETF_LOCALHARD+GETF_NETWORKDRIVE/*+GETF_RETDIRECTORY+GETF_MULTISELECT*/),; 
															cArqCsv		:=	SubStr(cDiretorio, RAT('\', cDiretorio)+1),;
															cDiretorio  := 	Left(cDiretorio,   RAT('\', cDiretorio)  ),;
															IIF(!Empty(cDiretorio), Processa ({|| AdicionaCSV(),'Processando....','Carregando Arquivo',.F.}),), ,oBrw1:oBrowse:Refresh() },D(011),D(011),,,,.T.,,"",,,,.F. )

oSay1      := TSay():New( D(032),D(008),{||"Canal\Segmento"},oGrp,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,D(064),D(008) )
oCBox	   := TComboBox():New( D(039),D(008),{|u| If(PCount()>0,cCBox:=u,cCBox)},aGrpSeg,D(100),D(010),oDlg1,,{|| },,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,,cCBox )


*******************************
	TableTmp()    // CRIAR ARQ. TEMP
*******************************
DbSelectArea("TMP")
oBrw1      := MsSelect():New( "TMP","OK","",{{"OK","","",""},{"ARQUIVO","","Arquivo",""}},.F.,cMarca,{D(052),D(008),D(140),D(245) },,, oGrp )

//oBtn2      := TButton():New( D(150),D(086),"Ok"  ,oDlg1,{|| IIF(Empty(cDiretorio).Or.Empty(cCBox), MsgInfo('INFORME UM ARQUIVO E\OU CANAL\SEGMENTO'), (Processa ({|| ImportCurva(cCBox)},'Importando Arquivo...','Processando...', .F.),oDlg1:End()) ) },D(037),D(012),,,,.T.,,"",,,,.F. )
oBtn2      := TButton():New( D(150),D(086),"Ok"  ,oDlg1,{|| Processa({|| ImportCurva(cCBox)},'Importando Arquivo...','Processando...', .F.), oDlg1:End()},D(037),D(012),,,,.T.,,"",,,,.F. )
oBtn3      := TButton():New( D(150),D(146),"Sair",oDlg1,{|| oDlg1:End(), lClose:=.T.},D(037),D(012),,,,.T.,,"",,,,.F. )

oBrw1:oBrowse:bAllMark      :=    {|| MarcaTMP(), oBrw1:oBrowse:Refresh() }
oBrw1:oBrowse:bLDblClick    :=    {|| Des_MarcaTMP()}


oDlg1:Activate(,,,.T.,{||.T.})

IIF(Select("TMP") != 0, TMP->(DbCLoseArea()), )
Return()
*********************************************************************
Static Function TableTmp()
*********************************************************************
Local aFds := {}
Local cTmp

If Select("TMP") == 0
   Aadd( aFds , {"OK"      ,"C",002,000} )
   Aadd( aFds , {"ARQUIVO" ,"C",200,000} )

   cTmp := CriaTrab( aFds, .T. )
   Use (cTmp) Alias TMP New Exclusive
   Aadd(aArqTemp, cTmp)

Else
	If Select('TMP') > 0
	   DbSelectArea("TMP")
	   RecLock('TMP', .F.)
	       Zap
	   MsUnLock()
	Endif
	
	TMP->(DbGoTop())
EndIf

Return()
*********************************************************************
Static Function MarcaTMP()
*********************************************************************
DbSelectArea('TMP');DbGoTop()
_cFlag    :=    IIF(!Empty(TMP->OK), cMarca,'')
Do While TMP->(!Eof())
   RecLock("TMP",.F.)
       TMP->OK  := IIF(!Empty(_cFlag),'', cMarca)
   MsUnLock()
   DbSkip()
EndDo

TMP->(DbGoTop())

Return()
*********************************************************************
Static Function Des_MarcaTMP()
*********************************************************************
_cMarca :=  IIF(Empty(TMP->OK), cMarca,'')

RecLock("TMP",.F.)
   TMP->OK  := _cMarca
MsUnLock()

Return()
*********************************************************************
Static Function AdicionaCSV()
*********************************************************************
DbSelectArea("TMP")
RecLock('TMP', .F.)
	Zap
MsUnLock()

RecLock("TMP",.T.)
	TMP->OK			:= 	cMarca
	TMP->ARQUIVO  	:= 	cArqCsv
MsUnLock()


TMP->(DbGoTop())
Return()
*********************************************************************
Static Function ImportCurva()
*********************************************************************
//IIF( !ExisteSX6('MV_IMPCSV'), CriarSX6('MV_IMPCSV', 'N','Pula primeira(s) linha(s) do .csv', '4'), '')
//nSkipLn := GetMv('MV_IMPCSV')
Local cBckFil	:=	cFilAnt

If File(cDiretorio+cArqCsv)

	If MsgYesNo('CONFIRMA A IMPORTADAÇÃO DO ARQUIVO '+cArqCsv+' ?') 

		FT_FUSE(cDiretorio+cArqCsv)
		FT_FGOTOP()
		nTotReg := FT_FLASTREC()
		ProcRegua(nTotReg)
		FT_FGOTOP()
			
		nCount := 0        
		cLinha := ''


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ LAYOUT ARQUIVO .CSV	 					³
		//|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|
		//|	FILIAL 									|
		//|	SEGMENTO 								|
		//|	COD.GRUPO MARCA 3						|
		//|	COD.CURVA							 	|	
		//|	DESCRICAO 								|
		//|	MARKUP 									|
		//|	ALCADA MAX 								|
		//|	ALC.MAX MED 							|
		//|	IMC MINIMO 								|
		//|	MKP.MIN35 								|
		//|	MKP PROMO 1 							|
		//|	MKP PROMO 2 							|
		//|	MKP PROMO 3 							|
		//|	MKP PROMO 4								|
		//| TRAVA MASTER							|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		Do While !FT_FEOF()
			
			nCount++
			IncProc('Processando '+cValToChar(nCount)+' de '+cValToChar(nTotReg))
			
			cLinha 	:= 	FT_FREADLN()
            
			If Left(cLinha, 01) != ';' .And. IsDigit(Left(cLinha, 01))

				cFilCsv		:=	PadL(Left(cLinha, AT(';',cLinha)-1),TamSx3('B1_FILIAL')[1],'0'); cLinha := SubStr(cLinha, AT(';',cLinha)+1)	//	FILIAL
				cCodSeg		:=	Left(cLinha, AT(';',cLinha)-1); cLinha := SubStr(cLinha, AT(';',cLinha)+1)	//	SEGMENTO

				cGrpM3		:=	Left(cLinha, AT(';',cLinha)-1); cLinha := SubStr(cLinha, AT(';',cLinha)+1)	//	CODIGO GRUPO DE MARCAS 3
				cCurva		:=	PadL(Left(cLinha, AT(';',cLinha)-1),TamSx3('B1_CURVA')[1],'0'); cLinha := SubStr(cLinha, AT(';',cLinha)+1) 	//	CURVA IMDEPA
				cDesCurva	:=	Left(cLinha, AT(';',cLinha)-1); cLinha := SubStr(cLinha, AT(';',cLinha)+1)	//	DESCRICAO MARK UP

				cMarkUp		:=	Left(cLinha, AT(';',cLinha)-1); cLinha := SubStr(cLinha, AT(';',cLinha)+1)	//	MK 35D c/ UA
				cAlcMax		:=	Left(cLinha, AT(';',cLinha)-1); cLinha := SubStr(cLinha, AT(';',cLinha)+1)	//	ALÇADA MÁXIMA
				cAlcMMed	:=	Left(cLinha, AT(';',cLinha)-1); cLinha := SubStr(cLinha, AT(';',cLinha)+1)	//	ALÇADA MÁXIMA MÉDIA
				
				cOldIMCMin	:=	Left(cLinha, AT(';',cLinha)-1); cLinha := SubStr(cLinha, AT(';',cLinha)+1)	//	IMC Mínimo
				cNewIMCMin	:=	Left(cLinha, AT(';',cLinha)-1); cLinha := SubStr(cLinha, AT(';',cLinha)+1)	//	IMC Mínimo
                
				cMkpM35		:=	Left(cLinha, AT(';',cLinha)-1); cLinha := SubStr(cLinha, AT(';',cLinha)+1)	//	MUP MÍNIMO 35d c/UA
				cMkpPro1	:=	Left(cLinha, AT(';',cLinha)-1); cLinha := SubStr(cLinha, AT(';',cLinha)+1)	//	MUP MÍN PROMO 1 35d c/UA
				cMkpPro2	:=	Left(cLinha, AT(';',cLinha)-1); cLinha := SubStr(cLinha, AT(';',cLinha)+1)	//	MUP MÍN PROMO 2 35d c/UA
				cMkpPro3	:=	Left(cLinha, AT(';',cLinha)-1); cLinha := SubStr(cLinha, AT(';',cLinha)+1)	//	MUP MÍN PROMO 3 35d c/UA
				cMkpPro4	:=	Left(cLinha, AT(';',cLinha)-1); cLinha := SubStr(cLinha, AT(';',cLinha)+1)	//	MUP MÍN PROMO 4 35d c/UA
				cTravaM		:=	IIF(AT(';',cLinha)==0, cLinha, Left(cLinha, AT(';',cLinha)-1) )			//	TRAVA MASTER
				
				cFilAnt		:=	cFilCsv
				
				DbSelectArea('IM1');DbSetOrder(2);DbGoTop()
				If DbSeek(cFilAnt + cCodSeg + cCurva, .F.)
					lGrava := .F.
				Else
					lGrava := .T.
				EndIf


				RecLock('IM1', lGrava)

					IM1->IM1_FILIAL		:= 	cFilAnt
					IM1->IM1_SEGMEN		:=	cCodSeg

					IM1->IM1_CODGM3		:= 	cGrpM3
					IM1->IM1_COD		:= 	cCurva
					IM1->IM1_DESC		:= 	cDesCurva

					IM1->IM1_MARKUP		:= 	 Val(StrTran(cMarkUp, 	',', '.'))

					IM1->IM1_ALCMAX		:= 	Val(StrTran(cAlcMax,	',', '.'))
					IM1->IM1_ALCMED		:= 	Val(StrTran(cAlcMMed,	',', '.'))

					IM1->IM1_IMCMIN		:= 	(Val(StrTran(cOldIMCMin, ',', '.')) + 100) / 100 
					IM1->IM1_NEWIMC		:= 	 Val(StrTran(cNewIMCMin,	',', '.'))

					IM1->IM1_TRAVAM		:= 	Val(StrTran(cTravaM, 	',', '.'))

					IM1->IM1_MKPM35		:= 	Val(StrTran(cMkpM35,  ',', '.')) 
					IM1->IM1_MKPPR1		:= 	Val(StrTran(cMkpPro1, ',', '.'))
					IM1->IM1_MKPPR2		:= 	Val(StrTran(cMkpPro2, ',', '.'))
					IM1->IM1_MKPPR3		:= 	Val(StrTran(cMkpPro3, ',', '.'))
					IM1->IM1_MKPPR4		:= 	Val(StrTran(cMkpPro4, ',', '.'))

                    /*
					 IM1->IM1_ALCMAX	:= 	(Val(StrTran(cAlcMax,  	',', '.')) + 100) / 100	//	CONVERTE -2,0% EM 0.98
					 IM1->IM1_ALCMED	:= 	(Val(StrTran(cAlcMMed, 	',', '.')) + 100) / 100	//	CONVERTE  10%  EM 1.10
					 IM1->IM1_IMCMIN	:= 	(Val(StrTran(cIMCMin,  	',', '.')) + 100) / 100
					*/

				MsUnLock()
							
            EndIf

			
			FT_FSKIP()

		EndDo        
		
		FCLOSE(cDiretorio+cArqCsv)
		FT_FUSE()
	
	EndIf
Else
	MsgInfo('Arquivo não encontrado.')
EndIf


cFilAnt := cBckFil
Return()
***********************************************************************
User Function Md2IM1TudOk()	//Md2IM1F4()
***********************************************************************
Local nOpc 		:= 	0 	//	GD_UPDATE
Local nPReplic	:= 	Ascan(aHeader,{|x| AllTrim(x[2]) == 'IM1_REPLIC' })
Local lTela		:=	IIF(nPReplic>0, Ascan(aCols,{|X| X[nPReplic] == 'S' }) > 0, .F.)
Local aTabelas := &(GetMv('MV_SEGXTAB'))  // {{"1","OEM"},{"2","MNT"},{"3","REV"}

SetPrvt("oDlgR","oGrp1","oBrwR","oBtn")

aCReplic := {}

oDlgR      := MSDialog():New( 091,232,375,637,"Replicar MarkUp",,,.F.,,,,,,.T.,,,.T. )
oGrp1      := TGroup():New( 004,004,116,192,"",oDlgR,CLR_BLACK,CLR_WHITE,.T.,.F. )

DbSelectArea('SX3');DbSetOrder(2);DbGoTop()
						Aadd(aHReplic,{ Space(5)	       ,  'MARCA'  	,'@!',001,000,'','','C','',''} )
DbSeek('ZZV_FILIAL'); 	Aadd(aHReplic,{ Trim(X3_TITULO),  'FILREPL'	, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, '', X3_USADO, X3_TIPO, X3_F3  })
DbSeek('ZZV_COD'); 		Aadd(aHReplic,{ Trim(X3_TITULO),  X3_CAMPO	, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, '', X3_USADO, X3_TIPO, X3_F3  })
DbSeek('ZZV_DESC');		Aadd(aHReplic,{ Trim(X3_TITULO),  X3_CAMPO	, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, '', X3_USADO, X3_TIPO, X3_F3  })

/*
If cOpcao == 'EXCLUI'	//	PARA EXCLUI_TODOS O USUARIO DEVE IR SEGMENTO A SEGMENTO.
	
	IIF(Select("SQL") != 0, SQL->( DbCLoseArea() ), )
	cQuery := "	SELECT	* "+ENTER	
	cQuery += "	FROM	" +RetSqlName('IM1')+"  "+ENTER
	cQuery += "	WHERE	IM1_FILIAL	 = 	'"+xFilial('IM1')+"'	"+ENTER  				
	cQuery += "	AND		IM1_CODGM3	 =	'"+IM1->IM1_CODGM3+"'  	"+ENTER
	cQuery += "	AND		IM1_COD		 =	'"+IM1->IM1_COD+"'  	"+ENTER
	cQuery += "	AND		IM1_SEGMEN	!=	'"+IM1->IM1_SEGMEN+"'  	"+ENTER
	cQuery += "	AND		D_E_L_E_T_ 	!= 	'*'	  		 			"+ENTER
	cQuery += "	ORDER BY IM1_SEGMEN								"+ENTER

	MemoWrit(GetTempPath()+"Mod2IM1_ZZZ.TXT", cQuery)            
	MsAguarde({|| DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),'SQL',.F.,.F.)},'Aguarde...','' )
	DbSelectArea('SQL');DbGoTop()
	Do While !Eof()
		Aadd(aCReplic, {'', AllTrim(SQL->IM1_SEGMEN), AllTrim(Posicione('ZZV',1,xFilial('ZZV')+SQL->IM1_SEGMEN, 'ZZV_DESC')), .F.})
		DbSelectArea('SQL')
		DbSkip()
	EndDo	
	IIF(Select("SQL") != 0, SQL->( DbCLoseArea() ), )

Else
*/
/*
DbSelectArea('ZZV');DbSetOrder(1);DbGoTop()
Do While !Eof()
	If AllTrim(IM1->IM1_SEGMEN) != AllTrim(ZZV->ZZV_COD)
		Aadd(aCReplic, {'', AllTrim(ZZV->ZZV_COD), AllTrim(ZZV->ZZV_DESC), .F.})
	EndIf
	DbSelectArea('ZZV')
	DbSkip()
EndDo  */
/*
For nZ := 1 To Len(aTabelas) 
	If AllTrim(IM1->IM1_SEGMEN) != AllTrim(aTabelas[nZ][2])
		Aadd(aCReplic, {'', AllTrim(aTabelas[nZ][2]), AllTrim(Posicione("ZZV", 1, xFilial("ZZV")+AllTrim(aTabelas[nZ][2]), "ZZV_DESC")), .F.} )		        
	EndIf
Next nZ
*/


IIF(Select("SQL") != 0, SQL->( DbCLoseArea() ), )
cQuery := "	SELECT IM1_FILIAL FILIAL, IM1_SEGMEN SEGMENTO "+ENTER	
cQuery += "	FROM  " +RetSqlName('IM1')+"  "+ENTER
cQuery += "	WHERE D_E_L_E_T_ 	!= 	'*'	"+ENTER  				
cQuery += "	GROUP BY IM1_FILIAL, IM1_SEGMEN	"+ENTER
cQuery += "	ORDER BY IM1_FILIAL, IM1_SEGMEN	"+ENTER
       
DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),'SQL',.F.,.F.)
DbSelectArea('SQL');DbGoTop()
Do While !Eof()
	If AllTrim(IM1->IM1_FILIAL+IM1->IM1_SEGMEN) != AllTrim(SQL->FILIAL+SQL->SEGMENTO)
		Aadd(aCReplic, {'', AllTrim(SQL->FILIAL), AllTrim(SQL->SEGMENTO), AllTrim(Posicione('ZZV',1,xFilial('ZZV')+SQL->SEGMENTO, 'ZZV_DESC')), .F.})
	EndIf
	DbSelectArea('SQL')
	DbSkip()
EndDo	
IIF(Select("SQL") != 0, SQL->( DbCLoseArea() ), )



oBrwR := MsNewGetDados():New(012,008,112,188,nOpc,'AllwaysTrue()','AllwaysTrue()','',,0,99,'AllwaysTrue()','','AllwaysTrue()',oGrp1,aHReplic,aCReplic )
oBrwR:oBrowse:bLDblClick 	:= {|| IIF(oBrwR:oBrowse:nColPos == 1 ,(DbClickGrid(''),oBrwR:oBrowse:Refresh()),oBrwR:EditCell()) }
oBrwR:oBrowse:bHeaderClick 	:= {|| IIF(oBrwR:oBrowse:nColPos == 1 , DbaHeaderClick(''),) }

oBtn := TButton():New( 120,076,"OK",oDlgR,{|| oDlgR:End() },037,012,,,,.T.,,"",,,,.F. )
                                            
lNaoMostrar:= !lTela .Or. Len(aCReplic)==0 .Or. cOpcao $ 'EXCLUI\VISUAL'

oDlgR:Activate(,,,.T.,,,{|| IIF(lNaoMostrar,oDlgR:End(),)})

Return(.T.)
***********************************************************************
Static Function DbClickGrid()
***********************************************************************
nPosMarca 	:= 	Ascan(oBrwR:aHeader,{|x| AllTrim(x[2]) == "MARCA"  	})
nPFilRepl	:=	Ascan(oBrwR:aHeader,{|x| AllTrim(x[2]) == "FILREPL" })
nPosSeg   	:= 	Ascan(oBrwR:aHeader,{|x| AllTrim(x[2]) == "ZZV_COD"	})
		
If nPosSeg > 0
	oBrwR:aCols[oBrwR:nAT][nPosMarca] 	:= 	IIF(Empty(oBrwR:aCols[oBrwR:nAT][nPosMarca]), 'X', '')
	aCReplic[oBrwR:nAT][nPosMarca] 		:=	oBrwR:aCols[oBrwR:nAT][nPosMarca]
	oBrwR:oBrowse:Refresh()
EndIf
	
Return()
***********************************************************************
Static Function DbaHeaderClick()
***********************************************************************
nPosMarca 	:= 	Ascan(oBrwR:aHeader,{|x| AllTrim(x[2]) == "MARCA"	})
nPFilRepl	:=	Ascan(oBrwR:aHeader,{|x| AllTrim(x[2]) == "FILREPL" })
nPosSeg   	:= 	Ascan(oBrwR:aHeader,{|x| AllTrim(x[2]) == "ZZV_COD"	})
                                  
cFlag 	 := IIF(Ascan(oBrwR:aCols,   {|X| X[nPosMarca] != '' }) > 0, '', 'X')

For nX:=1 To Len(oBrwR:aCols)
	//If AllTrim(IM1->IM1_SEGMEN) != AllTrim(oBrwR:aCols[nX][nPosSeg])
		oBrwR:aCols[nX][nPosMarca] 	:= cFlag
		aCReplic[nX][nPosMarca] 	:=	oBrwR:aCols[nX][nPosMarca]
	//EndIf
Next
oBrwR:oBrowse:Refresh()

Return()
***********************************************************************
Static Function C(nTam)
***********************************************************************
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta Tamanho dos Objetos            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nHRes    :=    oMainWnd:nClientWidth 		// Resolucao horizontal do monitor

   If nHRes == 640                              // Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
       nTam *= 0.8
   ElseIf (nHRes == 798).Or.(nHRes == 800)    	// Resolucao 800x600
       nTam *= 1
   Else                                        	// Resolucao 1024x768 e acima
       nTam *= 1.28
   EndIf

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³Tratamento para tema "Flat"³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If "MP8" $ oApp:cVersion
       If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
           nTam *= 0.90
       EndIf
   EndIf
Return Int(nTam)
***********************************************************************
Static Function D(nTam)	//	QDO TELA Eh DESENVOLVIDA COM RESOLUCAO 1080
***********************************************************************
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta Tamanho dos Objetos            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nHRes    :=    oMainWnd:nClientWidth		// Resolucao horizontal do monitor

   If nHRes == 640                            	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
       nTam := (nTam / 1.38 )
   ElseIf (nHRes == 798).Or.(nHRes == 800)    	// Resolucao 800x600
       nTam := (nTam / 1.28 )
   Else                                        	// Resolucao 1024x768 e acima
      nTam := (nTam * 1.28)
   EndIf

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³Tratamento para tema "Flat"³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If "MP8" $ oApp:cVersion .Or. '10' $ cVersao 
       If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
          nTam /= 1.04
       EndIf
//   ElseIf Alltrim(GetTheme()) == 'OCEAN'
//		nTam *= 50
   EndIf        
   

Return Int(nTam)        


User Function GravaLogCurva(nLinha, cOpcao)

Local aAreaZLP := GetArea()      
Local aDadTOP  := {{ "IM1_CODGM3", "IM1_TRAVAM", "IM1_COD", "IM1_DESC", "IM1_MARKUP", "IM1_ALCMAX", "IM1_ALCMED", "IM1_IMCMIN", "IM1_MKPM35", "IM1_MKPPR1", ;
						"IM1_MKPPR2", "IM1_MKPPR3", "IM1_MKPPR4", "IM1_REPLIC" }, {} }

/*BeginSql Alias 'TMPIM1'
	SELECT MAX(IM1.R_E_C_N_O_) RECLAST
	from %Table:IM1% IM1
	where 
	IM1_FILIAL = %xFilial:IM1%
	and IM1.%notdel%
EndSql	  */          
	
If cOpcao == "ALTERA" 	                   
    aAdd(aDadTOP[2], Iif(IM1->IM1_CODGM3	<>	aCols[nLinha][nPGrpMar], IM1->IM1_CODGM3, .F.	) )
	aAdd(aDadTOP[2], Iif(IM1->IM1_COD 		<>	aCols[nLinha][nPCod]   , IM1->IM1_COD,    .F.	) )  
	aAdd(aDadTOP[2], Iif(IM1->IM1_DESC		<>	aCols[nLinha][nPDesc]  , IM1->IM1_DESC,   .F.	) )
	aAdd(aDadTOP[2], Iif(IM1->IM1_TRAVAM	<>	aCols[nLinha][nPTravaM], IM1->IM1_TRAVAM, .F.	) )
	aAdd(aDadTOP[2], Iif(IM1->IM1_MARKUP	<>	aCols[nLinha][nPMarkUp], IM1->IM1_MARKUP, .F.	) )
	aAdd(aDadTOP[2], Iif(IM1->IM1_ALCMAX	<>	aCols[nLinha][nPAlcMax], IM1->IM1_ALCMAX, .F.	) )
	aAdd(aDadTOP[2], Iif(IM1->IM1_ALCMED	<>	aCols[nLinha][nPAlcMed], IM1->IM1_ALCMED, .F.	) )
	aAdd(aDadTOP[2], Iif(IM1->IM1_IMCMIN	<>	aCols[nLinha][nPImcMin], IM1->IM1_IMCMIN, .F.	) )
	aAdd(aDadTOP[2], Iif(IM1->IM1_MKPM35	<>	aCols[nLinha][nPMkpM35], IM1->IM1_MKPM35, .F.	) )
	aAdd(aDadTOP[2], Iif(IM1->IM1_MKPPR1	<>	aCols[nLinha][nPMkpPr1], IM1->IM1_MKPPR1, .F.	) )
	aAdd(aDadTOP[2], Iif(IM1->IM1_MKPPR2	<>	aCols[nLinha][nPMkpPr2], IM1->IM1_MKPPR2, .F.	) )      
	aAdd(aDadTOP[2], Iif(IM1->IM1_MKPPR3	<>	aCols[nLinha][nPMkpPr3], IM1->IM1_MKPPR3, .F.	) )
	aAdd(aDadTOP[2], Iif(IM1->IM1_MKPPR4	<>	aCols[nLinha][nPMkpPr4], IM1->IM1_MKPPR4, .F.	) )	
	aAdd(aDadTOP[2], Iif(Alltrim(IM1->IM1_REPLIC)	<>	Alltrim(aCols[nLinha][nPReplic]), IM1->IM1_REPLIC, .F.	) )	    
Else 
	aAdd(aDadTOP[2], IM1->IM1_CODGM3 )
	aAdd(aDadTOP[2], IM1->IM1_COD    )
	aAdd(aDadTOP[2], IM1->IM1_DESC   )
	aAdd(aDadTOP[2], IM1->IM1_TRAVAM )
	aAdd(aDadTOP[2], IM1->IM1_MARKUP )
	aAdd(aDadTOP[2], IM1->IM1_ALCMAX )
	aAdd(aDadTOP[2], IM1->IM1_ALCMED )
	aAdd(aDadTOP[2], IM1->IM1_IMCMIN )
	aAdd(aDadTOP[2], IM1->IM1_MKPM35 )
	aAdd(aDadTOP[2], IM1->IM1_MKPPR1 )
	aAdd(aDadTOP[2], IM1->IM1_MKPPR2 )
	aAdd(aDadTOP[2], IM1->IM1_MKPPR3 )
	aAdd(aDadTOP[2], IM1->IM1_MKPPR4 )  
	aAdd(aDadTOP[2], IM1->IM1_REPLIC )  	
EndIf	                	
	
DbSelectArea("ZLP")
      
For nI := 1 To Len(aDadTOP[2])   
	If ValType(aDadTOP[2, nI]) <> "L"                      
		RECLOCK("ZLP", .T.)
		           
		ZLP->ZLP_FILIAL		:= xFilial("IM1")
		ZLP->ZLP_TABELA		:= "IM1"  
		ZLP->ZLP_REGIST     := Iif(cOpcao == "EXCLUI", IM1->(Recno()) , Iif(cOpcao == "ALTERA", IM1->(Recno()), 0) )                                                         
		ZLP->ZLP_PROD       := ""
		ZLP->ZLP_CAMPO		:= Alltrim( aDadTOP[1, nI] )
		ZLP->ZLP_CONTEU 	:= Iif( ValType( aDadTOP[2, nI] ) == "N",  Alltrim( Str(aDadTOP[2, nI]) ), Alltrim(aDadTOP[2, nI]) )
		ZLP->ZLP_CONTAT		:= Iif( ValType( aCols[ nX, Ascan(aHeader,{|x| Alltrim(x[2])==aDadTOP[1, nI]}) ] ) == "N",  Alltrim( Str(aCols[ nX, Ascan(aHeader,{|x| Alltrim(x[2])==aDadTOP[1, nI]}) ]) ), Iif(ValType( aCols[ nX, Ascan(aHeader,{|x| Alltrim(x[2])==aDadTOP[1, nI]}) ] ) == "D", DToS(aCols[ nX, Ascan(aHeader,{|x| Alltrim(x[2])==aDadTOP[1, nI]}) ]),Alltrim(aCols[ nX, Ascan(aHeader,{|x| Alltrim(x[2])==aDadTOP[1, nI]}) ])) )
		ZLP->ZLP_DATA  		:= dDatabase
		ZLP->ZLP_HORA 		:= SUBSTR(TIME(), 1, 5) 
		ZLP->ZLP_USER 		:= Alltrim( UsrRetName(RetCodUsr()) )
		ZLP->ZLP_STYLE		:= Iif(cOpcao == "EXCLUI", "E" , Iif(cOpcao == "ALTERA","A", "I") )
			 
		ZLP->(MSUNLOCK()) 
	EndIf
Next nI         

//TMPIM1->(dbCloseArea())

RestArea(aAreaZLP)
      

Return
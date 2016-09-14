#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE 'FONT.CH'
#DEFINE  ENTER CHR(13)+CHR(10)
/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    |IMPFAT01  ³Autor  ³                       ³Data  ³  /  /     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina para importar .csv FATORES                            ³±±
±±³          ³                                                             ³±±
±±³          ³                                                             ³±±
±±³          ³                                                             ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ 	IMDEPA                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*********************************************************************
User Function IMPFAT01()
*********************************************************************
Private cNomArq 	:= 	Space(150)    
Private lInverte 	:= 	.F.
Private cMark    	:= 	'X'
Private lSchedule  	:= 	Type("dDatabase") == "U" // Se rodado via workflow a variável dDatabase estara disponivel somente apos o Prepare Environment
Private oData     	:= 	Nil
Private cArqTabelas	:=	'\tabpreco_fatores.dtc'
Private cDirSrv  	:= 	'\csv_import'
Private dDtSchedule := 	CtoD("")
Private oTelaIni
Private oMark
Private cArqTrab
	

If !lSchedule

    ******************** 
		CheckSX6()
	********************   

	cMark := GetMark()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem da tela de processamento.                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	dDtSchedule := 	IIF(Empty(AllTrim(GetMV("ES_DTIMP3"))),dDtSchedule, StoD(AllTrim(GetMV("ES_DTIMP3"))))
	dDtSchedule := 	IIF(dDtSchedule < dDataBase, CtoD(""), 	dDtSchedule)
	cNomArq		:=	Lower(PadR(IIF(Empty(dDtSchedule), '', GetMv('ES_DRCSV3')), 150,''))
	cColor	 	:= 	IIF(Empty(dDtSchedule), CLR_BLACK, CLR_HRED)
	
	@ 200,001 To 380,450 Dialog oTelaIni Title OemToAnsi("Importação de FATORES de Produtos >>> DA1")

   	@ 001,001 To 006,027
   	@ 003,012 Say "Este programa ira ler os FATORES de produtos e importar dentro da tabela DA1." Size 230
	
   	@ 032,015 Say "Arquivo:"				Size 120, 7 Pixel COLOR CLR_BLACK Of oTelaIni
   	@ 030,040 MsGet oNomArq  Var cNomArq	Size 153, 7 When .T. Pixel Of oTelaIni

   	@ 030,198 Button "..." 					Size 014, 010 Pixel Of oTelaIni Action (cNomArq := cGetFile("*.csv","Selecione o Arquivo a ser importado...",1,"C:\",.T.,16,.F.))

	cSayData := IIF(Empty(dDtSchedule), 'Agendar execução:', 'Agendado para:') 
   	@ 047,015 Say cSayData	Size 100, 7 Pixel COLOR cColor Of oTelaIni
   	@ 045,065 MsGet oData 	Var dDtSchedule	Size 55 , 7 When .T. Valid Empty(dDtSchedule) .Or. dDtSchedule >= dDataBase Pixel Of oTelaIni

   	@ 065,012 Button "Limpar Agendamento" Size 060, 011 Pixel Of oTelaIni Action ClearSchedule()
   	@ 065,128 BmpButton Type 05 Action SelTabelas()
   	@ 065,158 BmpButton Type 01 Action IIF(ValidInfos(), Close(oTelaIni),)
   	@ 065,188 BmpButton Type 02 Action Close(oTelaIni)

   	Activate Dialog oTelaIni Centered


Else

	ConOut("----------------------- IMPFAT01 -----------------------")
	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '05' FUNNAME 'IMPFAT01' TABLES 'SM0','DA0','SX6'
	ConOut("IMPFAT01 - INICIO -  DATA:"+DtoS(dDataBase)+' HORA: '+ Time())
	
	********************
		CheckSX6()
	********************
	

	ConOut( "IMPFAT01 - Inicio - " + Time() )
	
	*************************	
		ImpCsvFator()
	*************************

	ClearSchedule()
	ConOut("IMPFAT01 - FIM -  DATA:"+DtoS(dDataBase)+' HORA: '+ Time())


	
	RESET ENVIRONMENT
	
EndIf


Return()
********************************************************************
Static Function F_Agenda(cNomArq, dDtSchedule)
********************************************************************
Local cArquivo 	:= 	''
Local cCodXX1	:=	''
Local aErros	:=	{}
Local lDisable	:=	.F.
Local lCadWf   	:=	.F.
Local cHoraWF	:=	''   

If !Empty(dDtSchedule)
	/*
	DbSelectArea("XX1");DbGoTop()
	Do While !Eof()
		
		If "IMPFAT01" $ XX1->XX1_ROTINA
		
			If XX1->XX1_STATUS == "2"
				lDisable := .T.
				cCodXX1	 :=	XX1->XX1_CODIGO

			ElseIf XX1->XX1_DATA > DtoS(dDtSchedule)
				Aadd(aErros, 'Schedule já programado para: '+DtoC(StoD(XX1->XX1_DATA))+ENTER+;
				'Agende sua execução para DATA MAIOR ou IGUAL a data de hoje ('+DtoC(Date())+')' )
				Exit
				
			ElseIf XX1->XX1_STATUS != "2"
				cHoraWF	 :=	 XX1->XX1_HORA
				lDisable := .F.	
				lCadWf 	 := .T.
				Exit
			EndIf
			
		EndIf
		
		DbSkip()
	EndDo
	*/
	
	IIF(Select('TMPTSK')!=0, TMPTSK->(DbCloseArea()), )
	cQuery := "	SELECT  * FROM SCHDTSK					"+ENTER	
	cQuery += " WHERE   TSK_ROTINA LIKE '%IMPFAT01%'	"+ENTER
	cQuery += " AND     TSK_STATUS = '0'				"+ENTER
	cQuery += " AND     D_E_L_E_T_ != '*'				"+ENTER
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TMPTSK', .F., .T.)

	DbSelectArea('TMPTSK');DbGoTop()
	Do While !Eof()

		lCadWf	 :=	.T.
		lDisable := .F.
		cCodXX1	 :=	TMPTSK->TSK_CODIGO
		cHoraWF	 :=	TMPTSK->TSK_HORA
		Exit
	
		DbSkip()
	EndDo

	
	
	If !lCadWf
		Aadd(aErros, 'Schedule da rotina IMPFAT01 NÃO cadastrada. Entre em contato com Depto T.I') 	
	EndIf	
	If lDisable
		Aadd(aErros, 'Schedule da rotina IMPFAT01 (Código: '+cCodXX1+') esta desabilitado. Entre em contato com Depto T.I') 
	EndIf

	
					
	If Len(aErros) == 0
		
		If MsgYesNo( "Confirma o AGENDAMENTO da rotina para execução no  DIA: "+DtoC(dDtSchedule)+"  ÀS  "+cHoraWF+ENTER+"Confirma?" )
			
			If !ExistDir(cDirSrv)
				nErro := MakeDir(cDirSrv)
				If nErro > 0
					Aadd(aErros, "Erro na criação do diretorio  "+cDirSrv+"  no Servidor. Código de erro *MakeDir: " + Alltrim(Str(nErro)) + "." )
				EndIf
			EndIf
			

			If !(cDirSrv $ cNomArq)

				// GRAVA ARQUIVO COM AS FILIAIS\TABELAS SELECIONADAS
				cArqTemp 	:= 	'/system/'+cArqTrab+'.dtc'	// GRAVA POR PADRAO NO \SYSTEM\
				If File(cArqTemp)
					
					IIF(Select('TRB')!=0, TRB->(DbCloseArea()), )
					
					__CopyFile(cArqTemp, cDirSrv+cArqTabelas)	// COPIA DO \SYSTEM\ PARA O \PROTHEUS_DATA\
					
					If !File(cDirSrv+cArqTabelas)
						Aadd(aErros, "Não foi possivel copiar o arquivo (arq. com filiais\tabelas) de trabalho para o servidor. ("+cDirSrv+cArqTabelas+") " )
					EndIf
				
				Else
					Aadd(aErros, 'Arquivo de trabalho (arq. com filiais\tabelas) não encontrado!'+ENTER+'Clique no botão "ParÂmetros" para selecionar Filiais \ Tabelas!!!')
				EndIf
				
			
				// COPIA ARQUIVO .CSV PARA O SERVIDOR
				cArquivo :=  Right(cNomArq, Len(cNomArq) - Rat("\", cNomArq))
				If File(cDirSrv + "\" + cArquivo)
					
					If MsgYesNo("Já existe um arquivo com o nome " + cArquivo + " no Servidor. Sobrescreve?")
						nErro := FErase(cDirSrv + "\" + cArquivo)
						If nErro > 0
							Aadd(aErros, "Erro ao excluir arquivo " + cArquivo +  " do Servidor. Código de erro *FErase: " + Alltrim(Str(nErro)) + "." )
						EndIf
					EndIf
					
				EndIf
			
			
			
				If !CpyT2S(cNomArq, cDirSrv)
					Aadd(aErros, "Não foi possivel copiar o arquivo .csv para o servidor." )
				Else
					
					If !PutMV("ES_DRCSV3", cDirSrv + "\" + cArquivo)
						Aadd(aErros, "Não foi possivel atualizar parametro ES_DRCSV3." )
					EndIf
					
					
					If Len(aErros) == 0
						PutMV("ES_DTIMP3", DtoS(dDtSchedule))
						MsgInfo("Dados para execução de agendamento efetuado com sucesso." )
					EndIf
					
				EndIf
			
			Else
				MsgInfo("Dados para execução de agendamento efetuado com sucesso." )			
			EndIf

		EndIf
	
	Else
		Aadd(aErros, 'Rotina IMPFAT01 nao encontrada no Schedule.')
	EndIf
	
EndIf

If Len(aErros) > 0
	cMsgErro := ''
	For nX:=1 To Len(aErros)
		cMsgErro+= aErros[nX]+ENTER
	Next

	MsgAlert(cMsgErro, '--> ERRO <--')
EndIf

Return(IIF(Len(aErros)==0, .T., .F.))
*********************************************************************
Static Function SelTabelas()
*********************************************************************
Local aStru		:=	{}
Local aCpoBro 	:= 	{}
Local lRet 		:= 	.T.
Local oBrwTab
Local aTabelas 	:= &(GetMv('MV_SEGXTAB'))		//	{{"1","OEM"},{"2","MNT"},{"3","REV"}}
Local cTabelas	:=	''


If Select("TRB") > 0
	DbSelectArea("TRB")
	RecLock('TRB', .F.)
		Zap
	MsUnLock()
Else
	Aadd(aStru,{"OK"     ,"C"	,2	,0	})
	Aadd(aStru,{"FILIAL" ,"C"	,2	,0	})
	Aadd(aStru,{"DESCRI" ,"C"	,30	,0	})
	Aadd(aStru,{"TABELA" ,"C"	,3	,0	})

	cArqTrab := CriaTrab(aStru,.T.)
	DbUseArea(.T.,,cArqTrab, "TRB", .F., .F.)
EndIf

For nX:=1 To Len(aTabelas)
	cTabelas += aTabelas[nX][02]+','
Next
cFilTab	:=	FormatIn(cTabelas,",")  

lQuery  := .T.
IIF(Select('TMPDA0')!=0, TMPDA0->(DbCloseArea()), )
If File(cDirSrv+cArqTabelas)
	DbUseArea(.T.,,cDirSrv+cArqTabelas, 'TMPDA0', .F., .F.)
	DbSelectArea("TMPDA0")
	lQuery  := IIF(Select('TMPDA0')>0, .F., .T.)
EndIf

If lQuery

	cSql := " SELECT ' ' OK, DA0_FILIAL FILIAL, DA0_CODTAB TABELA, DA0_DESCRI DESCRI "+ENTER
	cSql += " FROM 	"+RetSqlName("DA0")+" DA0 		"+ENTER
	cSql += " WHERE DA0_CODTAB  IN	" +cFilTab		 +ENTER
	cSql += " AND 	DA0.D_E_L_E_T_ != '*' 			"+ENTER
	cSql += " ORDER BY DA0_FILIAL, DA0_CODTAB		"+ENTER
	
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),'TMPDA0', .F., .F.)


	DbSelectArea("TMPDA0");DbGoTop()
	Do While !Eof()
		RecLock('TRB', .T.)
			TRB->OK 	:= IIF(!Empty(TMPDA0->OK), cMark, TMPDA0->OK)
			TRB->FILIAL := TMPDA0->FILIAL
			TRB->DESCRI := TMPDA0->DESCRI
			TRB->TABELA := TMPDA0->TABELA
		MsUnLock()
	
		DbSelectArea("TMPDA0")
		DbSkip()
	EndDo
	IIF(Select('TMPDA0')!=0, TMPDA0->(DbCloseArea()), )

EndIf

DbSelectArea("TRB");DbGoTop()
aCpoBro	:= 	{{ "OK"	 	,, "" 			,"@!"	},;
           	 { "FILIAL"	,, "Filial" 	,"@!"	},;
			 { "DESCRI"	,, "Descricao" 	,"@1!"	},;
			 { "TABELA"	,, "Cod Tabela"	,"@X"	}}



DEFINE MSDIALOG oBrwTab TITLE "SELEÇÃO DE LISTAS DE PREÇOS" From 9,0 To 315,800 PIXEL
oMark 						:=	MsSelect():New("TRB", "OK", "", aCpoBro, @lInverte, @cMark, {17,1,140,400},,,,,)
oMark:bMark 				:= 	{|| MarkDisp() }
oMark:oBrowse:lCanAllmark 	:= 	.T. 
oMark:oBrowse:bAllMark 		:=	{|| RdMarkAll("TRB", oMark, cMark, "OK", "TABELA")}
oMark:oBrowse:Refresh()


EnchoiceBar(oBrwTab, {|| oBrwTab:End() },  {|| oBrwTab:End() })
oBrwTab:Activate(,,,.T.,{|| /*bValid*/ },, {|| IIF(!lQuery, MarkArqTRB(),)/*bIni*/})
   

//IIF(Select('TRB')!=0, TRB->(DbCloseArea()),)  NAO FECHAR TABELAS TEMPORARIA
Return(lRet)
*********************************************************************
Static Function MarkArqTRB()
*********************************************************************
DbSelectArea("TMPDA0");DbGoTop()
Do While !Eof()
	RecLock('TRB', .T.)
		TRB->OK 	:= IIF(!Empty(TMPDA0->OK), cMark, TMPDA0->OK)
		TRB->FILIAL := TMPDA0->FILIAL
		TRB->DESCRI := TMPDA0->DESCRI
		TRB->TABELA := TMPDA0->TABELA
	MsUnLock()

	DbSelectArea("TMPDA0")
	DbSkip()
EndDo
IIF(Select('TMPDA0')!=0, TMPDA0->(DbCloseArea()), )
DbSelectArea("TRB");DbGoTop()
oMark:oBrowse:Refresh()
Return()
*********************************************************************
Static Function MarkDisp()
*********************************************************************
RecLock("TRB",.F.)
	TRB->OK := IIF(Marked("OK")	, cMark, '')
MsUnLock()
oMark:oBrowse:Refresh()
Return()
*********************************************************************
Static Function RDMarkAll(cAlias, oMark, cMarca, cCpoMark, cTabBrw)
*********************************************************************
Local nRecno  
Local lTabSeg 	:=	.F.
Local nOpcao	:=	4
													//	  [01] [02]   [02] [02]   [03] [02]
Local aTabela := &(GetMv('MV_SEGXTAB'))				//	{{"1","OEM"},{"2","MNT"},{"3","REV"}}
			
	
DbSelectArea(cAlias)
nRecno:=Recno()
DbGoTop()
           
If !lSchedule
	cTabPrc := ''
	For nX:=1 To Len(aTabela)
		cTabPrc += aTabela[nX][02]+IIF(nX!=Len(aTabela), ', ', '')
	Next
	
	nOpcao  := Aviso('Marcação','Qual opção você deseja realizar\marcar ???'+ENTER+ENTER+ENTER+'Tab.Seg = '+cTabPrc, {'Todos','Limpar','Tab.Seg','Sair'}, 3)

EndIf


Do While !Eof()
	RecLock(cAlias,.F.)
		
		If !lSchedule

			If nOpcao == 1		//	MARCAR TODOS
				Replace &(cCpoMark) With cMarca

			ElseIf nOpcao == 2 	// 	LIMPAR TODOS
				Replace &(cCpoMark) With "  "

			ElseIf nOpcao == 3 	// 	REV,OEM,MNT
				Replace &(cCpoMark) With "  "
				
				If &(cTabBrw) $ cTabPrc
					Replace &(cCpoMark) With cMarca
				EndIf	
			ElseIf nOpcao == 4 	// 	SAIR
				Exit
			EndIf

		EndIf
		
	MsUnlock()
	DbSkip()
End

DbGoTo(nRecno)

If !lSchedule
	oMark:oBrowse:Refresh()
EndIf

Return(.T.)
************************************************************
Static Function CheckSX6()
************************************************************
DbSelectArea('SX6')
IIF(!ExisteSX6('ES_DTIMP3'), 	CriarSX6('ES_DTIMP3', 'C','Data para rodar rotina IMPFAT01 via schedule.', 	'' 	), )
IIF(!ExisteSX6('ES_DRCSV3'), 	CriarSX6('ES_DRCSV3', 'C','Diretorio+Arquivo .csv para importar - IMPFAT01.',	'' 	), )
IIF(!ExisteSX6('IM_TAMPROD'),	CriarSX6('IM_TAMPROD', 'N','Tamanho codigo produto.', '8' ),)

Return()
*********************************************************************
Static Function ValidInfos()
*********************************************************************
Local lRetorno 	:= 	.T.
Local lSelect	:=	.F.    


If Empty(cNomArq)
	MsgAlert('Arquivo .csv não informado!')
	lRetorno := .F.
Else

	
	If File(cNomArq)

		If FT_FUSE(cNomArq) == -1
			MsgAlert('Arquivo .csv com problema. Verifique !!!')
		Else
	
			FCLOSE(cNomArq)

	        If !Empty(dDtSchedule) .And. cDirSrv $ cNomArq .And. Select('TRB') == 0
				IIF(Select('TRB')!=0, TRB->(DbCloseArea()), )
				If File(cDirSrv+cArqTabelas)
					
					DbUseArea(.T.,,cDirSrv+cArqTabelas, "TRB", .F., .F.)
				Else
					MsgAlert('Não foi selecionado Filiais \ Tabelas.'+ENTER+'Clique no botão "Parâmetros" e selecione alguma Filial\Tabela !!!')						
				EndIf
			EndIf

			If Select('TRB') > 0
				DbSelectArea('TRB');DbGoTop()
				Do While !Eof()
					
					If !Empty(TRB->OK)
						lSelect	:=	.T.
						Exit
					EndIf
					
					DbSelectArea('TRB')	
					DbSkip()
			    EndDo
			
			    If !lSelect
				    MsgAlert('Não foi selecionado Filiais \ Tabelas.'+ENTER+'Clique no botão "Parâmetros" e selecione alguma Filial\Tabela !!!')
					lRetorno := .F.
			    EndIf

			Else
				MsgAlert('Não foi selecionado Filiais \ Tabelas.'+ENTER+'Clique no botão "Parâmetros" para selecionar !!!')
				lRetorno := .F.
			EndIf
        
        EndIf
    Else
	    MsgAlert('Arquivo .csv não encontrado !')
    	lRetorno := .F.
    EndIf

EndIf

If lRetorno

	If Empty(dDtSchedule)
		lRetorno := MsgYesNo('Confirma a Importação de FATORES ???')

		If lRetorno
			Processa({|| ImpCsvFator()},"Importa .csv Fatores...","Importando arquivo de FATORES...")
		EndIf

	Else
		lRetorno :=	F_Agenda(cNomArq, dDtSchedule)
    EndIf

EndIf


Return(lRetorno)
*********************************************************************
Static Function ImpCsvFator()
*********************************************************************
Local cArqCsv 	:= 	IIF(!lSchedule, cNomArq, GetMV('ES_DRCSV3'))
Local nTamProd 	:=	GetMv('IM_TAMPROD')


If File(cArqCsv)


	FT_FUSE(cArqCsv)
	FT_FGOTOP()        
	nTotRegCsv := FT_FLASTREC()
	ProcRegua(nTotRegCsv)
	FT_FGOTOP()
		
	nCount 	:= 0        
	cLinha 	:= ''
	aTmpTab := 	{}

	If File(cDirSrv+cArqTabelas) .Or. !lSchedule		// '\csv_import\tab_promo.dtc'
		
        If lSchedule
	        // TABELA COM A SELECAO DAS TABELAS E FILIAS 
			IIF(Select('TRB')!=0, TRB->(DbCloseArea()), )
			DbUseArea(.T.,,cDirSrv+cArqTabelas, "TRB", .F., .F.)
		EndIf
								
		DbSelectArea('TRB');DbGoTop()
		Do While !Eof()    
			If !Empty(TRB->OK)
				Aadd(aTmpTab, {TRB->FILIAL, TRB->TABELA})
			EndIf
			DbSelectArea('TRB')
			DbSkip()
		EndDo
		IIF(Select('TRB')!=0, TRB->(DbCloseArea()), )
            

		Do While !FT_FEOF()
			IncProc()
			nCount++
	

			IncProc('Processando... '+AllTrim(cValToChar(nCount))+' de '+AllTrim(cValToChar(nTotRegCsv))+' registros.') 
										
			cLinha 	:= 	FT_FREADLN()
	
			If Left(cLinha, 01) != ';' .And. IsDigit(Left(cLinha, 01))
	
				cFilCsv		:=	PadL(Left(cLinha, AT(';',cLinha)-1),2,'0'); 		cLinha := SubStr(cLinha, AT(';',cLinha)+1)		//	FILIAL
				cProduto	:=	PadL(Left(cLinha, AT(';',cLinha)-1),nTamProd,'0');	cLinha := SubStr(cLinha, AT(';',cLinha)+1) 	//	CODIGO PRODUTO
				cProduto	:=	PadR(cProduto, TamSx3('B1_COD')[01])
				nFator		:=	Val(StrTran(cLinha, ',', '.'))
				nFator		:=	NoRound(nFator, TamSx3('DA1_PRCVEN')[02])



				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³  VERIFICA SE FILIAL DO ARQUIVO .CSV ESTA NO ARQ. DA FILIAL\TABELA SELECIONADAS  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aCodTab	:=	{}
				aEval(aTmpTab, {|X| IIF(X[01]==cFilCsv, Aadd(aCodTab, {X[01], X[02]}), ) })
							
				cFilBck		:=	cFilAnt
				cFilAnt 	:= 	cFilCsv
	

				For nX:=1 To Len(aCodTab)

					cFilTab := aCodTab[nX][01]
					cCodTab := aCodTab[nX][02]
				
					DbSelectArea('DA1');DbSetOrder(1)	// DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM
					If DbSeek(cFilTab + cCodTab + cProduto, .F.)
		
				
						RecLock('DA1', .F.)
		
							nFator := IIF(nFator==0, 1, nFator)

				        	If DA1->DA1_PERDES == 0
								DA1->DA1_PERDES :=  nFator
								DA1->DA1_PRCVEN := (DA1->DA1_PRCVEN * nFator)
				        	Else
								nPrcOrig		:= 	DA1->DA1_PRCVEN / DA1->DA1_PERDES	// VOLTA PRECO DE VENDA AO VALOR ORIGINAL (PRECO SEM FATOR)
								DA1->DA1_PERDES :=  nFator								
								DA1->DA1_PRCVEN := (nPrcOrig * nFator)
							EndIf
		
						MsUnLock()

					EndIf	
	
	            Next
	        
	        	cFilAnt	:=	cFilBck
	        
	        EndIf
	        
			
			FT_FSKIP()
		EndDo        
		
		FCLOSE(cArqCsv)
		FT_FUSE()
	    
	    If !lSchedule
	    	MsgInfo(' ROTINA PROCESSADO COM SUCESSO ')
	    Else
	    	FatorEmail()
	    EndIf
	    
	Else
		ConOut( "IMPFAT01 - Erro ao abrir o arquivo "+cArqTabelas)		
    EndIf
    
Else
 	MsgAlert("O arquivo "+cArqCsv+" nao pode ser aberto!!!  Verifique os parametros.","Atencao!")
	ConOut( "IMPFAT01 - O arquivo "+cArqCsv+" nao pode ser aberto! Verifique os parametros.")
EndIf


IIF(Select('TRBDA0')!=0, TRBDA0->(DbCloseArea()), )
Return()
*********************************************************************
Static Function ClearSchedule()
*********************************************************************
Local cPathArq := AllTrim(GetMv('ES_DRCSV3'))
FErase(cDirSrv+cArqTabelas)
FErase(cPathArq)
PutMV('ES_DTIMP3', '')
PutMV('ES_DRCSV3', '')

cNomArq		:=	Space(150)
dDtSchedule	:=	CtoD("")

Return()
********************************************************************
Static Function FatorEmail()
********************************************************************

cHtml := '<html>'
cHtml += '<head>'
cHtml += '<h3 align = Left><font size="3" face="Verdana" color="#0000FF">Importação .csv FATOR - Via WorkFlow</h3></font>' 
cHtml += '<br></br>'
cHtml += '<b><font size="2" face="Verdana" color="#0000FF">Processado em: </font></b>'
cHtml += '<b><font size="2" face="Verdana" color="#0000FF">'+Dtoc(Date())+' às '+Time()+'</font></b>'	    	
cHtml += '<br></br>'
cHtml += '</head>'
cHtml += '<body bgcolor = white text=black>'
cHtml += '<hr width=100% noshade>'
cHtml += '<br></br>'

cRotina		:=	'IMPFAT01'
cAssunto	:=	'Importação .csv FATOR - Via WorkFlow'
cPara		:=	AllTrim(GetMv('IM_WFPRECO'))
cCopia		:=	'fabiano.pereira@solutio.inf.br'
cCopOcult	:=	''
cCorpoEmail	:=	cHtml
cAtachado	:=	''

U_ENVIA_EMAIL(cRotina, cAssunto, cPara, cCopia, cCopOcult, cCorpoEmail, cAtachado)

Return()
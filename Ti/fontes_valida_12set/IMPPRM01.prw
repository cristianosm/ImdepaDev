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
±±³Fun‡ao    |IMPPRM01  ³Autor  ³                       ³Data  ³  /  /     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Rotina para importar .csv PROMO                             ³±±
±±³          ³ OBS.: CONCIDERA CAMPO PROMO 1, PROMO 2, PROMO 3, PROMO 4,   ³±±
±±³          ³ PROMO1234, PROMO F COM E SEM ESPACAO						   ³±±
±±³          ³                                                             ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ 	IMDEPA                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*********************************************************************
User Function IMPPRM01()
********************************************************************
Private cNomArq 	:= 	Space(150)    
Private lInverte 	:= 	.F.
Private cMark    	:= 	'X'
Private lSchedule  	:= 	Type("dDatabase") == "U" 
Private oData     	:= 	Nil
Private cArqTabelas	:=	'\tabpreco_promo.dtc'
Private cDirSrv  	:= 	'\csv_import'
Private dDtSchedule := 	CtoD('')
Private cCVPeso1 	:= 	'1'
Private cCVPeso2 	:= 	'1'
Private cCVPeso3 	:= 	'1'
Private cCVPeso4 	:= 	'1'

Private oTelaIni
Private oMark
Private cArqTrab



If !lSchedule
	
	******************
	   CheckSX6()
	******************
	
	cMark := GetMark()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem da tela de processamento.                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	dDtSchedule := 	IIF(Empty(AllTrim(GetMV("ES_DTIMP1"))),dDtSchedule, StoD(AllTrim(GetMV("ES_DTIMP1"))))
	dDtSchedule := 	IIF(dDtSchedule < dDataBase, CtoD(""), 	dDtSchedule)
	cNomArq		:=	Lower(PadR(IIF(Empty(dDtSchedule), '', GetMv('ES_DIRCSV')), 150,''))
	cColor	 	:= 	IIF(Empty(dDtSchedule), CLR_BLACK, CLR_HRED)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem da tela de processamento.                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 200,001 To 380,450 Dialog oTelaIni Title OemToAnsi("Importação de PROMOs >>> Ajusta Preço")

   	@ 1.5,001 To 006,027
   	@ 003,012 Say "Este programa ira ler os produtos que entram ou saem de PROMOÇÃO e aplicar" Size 230
   	@ 009,012 Say "o Markup correspondente" Size 230
   	
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

	ConOut("----------------------- IMPPRM01 -----------------------")
	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '05' FUNNAME 'IMPPRM01' TABLES 'SM0','DA0','SX6'
	ConOut("IMPPRM01 - INICIO -  DATA:"+DtoS(dDataBase)+' HORA: '+ Time())
	
	********************
		CheckSX6()
	********************


	ConOut( "IMPPRM01 - Inicio - " + Time() )
	
	*************************	
		ImpCsvPromo()
	*************************

	ClearSchedule()
	ConOut("IMPPRM01 - FIM -  DATA:"+DtoS(dDataBase)+' HORA: '+ Time())


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
		
		If "IMPPRM01" $ XX1->XX1_ROTINA 
		
			If XX1->XX1_STATUS == "2"
				lDisable := .T.
				cCodXX1	 :=	XX1->XX1_CODIGO
			ElseIf XX1->XX1_DATA > DtoS(dDtSchedule)
				Aadd(aErros, 'Schedule já programado para: '+DtoC(StoD(XX1->XX1_DATA))+ENTER+;
				'Agende sua execução para DATA MAIOR ou IGUAL a data de hoje ('+DtoC(Date())+')' )
				Exit
				
			ElseIf XX1->XX1_STATUS != "2"
				cHoraWF	:=	XX1->XX1_HORA
				lDisable:= .F.	
				lCadWf 	:= .T.
				Exit
				
			EndIf
			
		EndIf
		
		DbSkip()
	EndDo
	*/
	
	IIF(Select('TMPTSK')!=0, TMPTSK->(DbCloseArea()), )
	cQuery := "	SELECT  * FROM SCHDTSK					"+ENTER	
	cQuery += " WHERE   TSK_ROTINA LIKE '%IMPPRM01%'	"+ENTER
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
		Aadd(aErros, 'Schedule da rotina IMPPRM01 NÃO cadastrada. Entre em contato com Depto T.I') 	
	EndIf	
	If lDisable
		Aadd(aErros, 'Schedule da rotina IMPPRM01 (Código: '+cCodXX1+') esta desabilitado. Entre em contato com Depto T.I') 
	EndIf

	
					
	If Len(aErros) == 0
		
		If MsgYesNo( "Confirma o AGENDAMENTO da rotina para execução no  DIA: "+DtoC(dDtSchedule)+"  ÀS  "+cHoraWF+ENTER+"Confirma?" )
					
			If !ExistDir(cDirSrv)		// '\csv_import' 
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

										// '\csv_import\tab_promo.dtc'					
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
					
					If !PutMV("ES_DIRCSV", cDirSrv + "\" + cArquivo)
						Aadd(aErros, "Não foi possivel atualizar parametro ES_DIRCSV." )
					EndIf
					
					
					If Len(aErros) == 0
						PutMV("ES_DTIMP1", DtoS(dDtSchedule))
						MsgInfo("Dados para execução de agendamento efetuado com sucesso." )
					EndIf
					
				EndIf
			
			Else
				MsgInfo("Dados para execução de agendamento efetuado com sucesso." )			
			EndIf

		EndIf
	
	Else
		Aadd(aErros, 'Rotina IMPPRM01 nao encontrada no Schedule.')
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
IIF(!ExisteSX6('ES_DTIMP1'), 	CriarSX6('ES_DTIMP1', 'C','Data para rodar rotina via schedule - IMPPRM01.', 	'' 	), )
IIF(!ExisteSX6('ES_DIRCSV'), 	CriarSX6('ES_DIRCSV', 'C','Diretorio+Arquivo .csv para importar - IMPPRM01.',	'' 	), )
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
		lRetorno := MsgYesNo('Confirma a Importação de PROMO ???') 
	
		If lRetorno
			Processa({|| ImpCsvPromo()},"Importa .csv Promo...","Importando arquivo de PROMOs...")
		EndIf
	Else
		lRetorno :=	F_Agenda(cNomArq, dDtSchedule)
    EndIf
EndIf

Return(lRetorno)
*********************************************************************
Static Function ImpCsvPromo()
*********************************************************************
Local cArqCsv 		:= 	IIF(!lSchedule, cNomArq, GetMV('ES_DIRCSV'))
Local nTamProd 		:=	GetMv('IM_TAMPROD')

Private aDA1Erros 	:= 	{}
Private aFATErros 	:= 	{}
Private aSB1Erros 	:= 	{}
Private aZA7Erros 	:=	{}


If File(cArqCsv)


	FT_FUSE(cArqCsv)
	FT_FGOTOP()
	nTotRegCsv	:=	FT_FLASTREC()
	ProcRegua(nTotRegCsv)
	FT_FGOTOP()
	nCount 	:= 0        
	cLinha 	:= ''
	aTmpTab := 	{}


	If File(cDirSrv+cArqTabelas) .Or. !lSchedule	// '\csv_import\tab_promo.dtc'

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
				cPromo		:=	AllTrim(Left(cLinha, AT(';',cLinha)-1));			cLinha := SubStr(cLinha, AT(';',cLinha)+1) 	//	PROMO1,2,3,4,F


				//	AJUSTE PARA CORRECAO DO UPDATE - ERRO QUANDO DA1_PRCVEN 	= 1.862,0049   // CORRETO  = 1862.0049
							
                cPreco	:=	cLinha									//	1.862,0049	|	339,5918
				cPreco 	:= 	StrTran(cPreco, ",", "#" 	)	   		//	1.862#0049	|	339#5918
				cPreco 	:= 	StrTran(cPreco, ".", "" 	)			//	1862#0049	|	339#5918	
				cPreco 	:= 	StrTran(cPreco, "#", "." 	)			//	1862.0049	|	339.5918


				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³  VERIFICA SE FILIAL DO ARQUIVO .CSV ESTA NO ARQ. DA FILIAL\TABELA SELECIONADAS  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aCodTab	:=	{}
				aEval(aTmpTab, {|X| IIF(X[01]==cFilCsv, Aadd(aCodTab, {X[01], X[02]}), ) })
							
				For nX:=1 To Len(aCodTab)
					
					cFilTab := aCodTab[nX][01]
					cCodTab := aCodTab[nX][02]

					cTpPromo := Right(cPromo,1)
					
					If cTpPromo != 'F' // NAO EXECUTA SE FOR PROMO F.


						cSql :=" UPDATE "+RetSqlName('DA1')+ " DA1X 	"
						cSql +=" SET DA1_PRCVEN = NVL( "
						cSql +=" (	SELECT NVL(NVL(SB1.B1_CUSTRP,0) *  	"
						cSql +=" 		CASE SB1.B1_MCUSTRP"
						cSql += 	SqlChkMoeda()
						cSql +=" 		END * NVL(IM1.IM1_MKPPR"+cTpPromo+",0),0)	"
						
						cSql +=" 	FROM DA1010 DA1	"
						cSql +=" 	INNER JOIN SB1010 SB1 ON SB1.B1_FILIAL = DA1.DA1_FILIAL AND SB1.B1_COD = DA1.DA1_CODPRO AND SB1.D_E_L_E_T_ = ' '	"
						cSql +=" 	INNER JOIN SM2010 SM2 ON SM2.M2_DATA = '"+DToS(dDataBase)+"' AND SM2.D_E_L_E_T_ = ' '	"
						cSql +=" 	INNER JOIN IM1010 IM1 ON IM1.IM1_FILIAL = DA1.DA1_FILIAL AND IM1.IM1_COD = SB1.B1_CURVA AND IM1.IM1_SEGMEN = '"+cFilTab+"' AND IM1.D_E_L_E_T_ = ' ' "
						cSql +=" 	WHERE DA1.DA1_FILIAL = DA1X.DA1_FILIAL AND DA1.DA1_CODTAB = DA1X.DA1_CODTAB AND DA1.D_E_L_E_T_ = ' ' AND DA1.DA1_CODPRO = DA1X.DA1_CODPRO),0) "
						
						cSql +=" WHERE DA1X.DA1_FILIAL = '"+cFilTab+"' AND DA1X.DA1_CODTAB = '"+cCodTab+"' AND DA1X.D_E_L_E_T_ = ' ' "
						cSql +=" AND DA1X.DA1_CODPRO   = '"+cProduto+"' "

						nErro := TcSqlExec(cSql)	// MsAguarde( {|| TcSqlExec(cSql) },'Processando','Executando Atualização...' )

					EndIf


					If Empty(TcSqlError()) .Or. cTpPromo == 'F'
					
						IIF(cTpPromo != 'F', TcSqlExec('COMMIT'), )

						// UPDATE FATOR
						cSql :=" UPDATE "+RetSqlName('DA1')+ " 	"
						If cTpPromo == 'F' 	// PEGA O PRECO DA TABELA IMPORTADA.
							cSql +=" 	SET DA1_PERDES = 0, DA1_PRCVEN 	= "+ cPreco +" "
						Else
							cSql +=" 	SET DA1_PRCVEN 	= ( DA1_PRCVEN * DA1_PERDES ) "
						EndIf
						cSql +=" WHERE DA1_FILIAL 	= '"+cFilTab+"' "
						cSql +=" AND   DA1_CODTAB   = '"+cCodTab+"' "
						cSql +=" AND   DA1_CODPRO   = '"+cProduto+"' "
						If cTpPromo != 'F' 
							cSql +=" AND   DA1_PERDES   >  0  "
						EndIf
						cSql +=" AND   D_E_L_E_T_   = ' ' "
						
						TcSqlExec(cSql)
						If Empty(TcSqlError())
							TcSqlExec('COMMIT')
						Else
							//		 	        1		   2		3		  4
							Aadd(aFATErros, {cFilTab, cCodTab, cProduto, TcSqlError()})
							TcSqlExec('ROLLBACK')
						EndIf

						
						// UPDATE PRODUTO
						If cTpPromo != 'F' // SE FOR PROMO F, GRAVA O STATUS DA VENDA IGUAL A 1.
							cClass := Val(cTpPromo) //&("cClassP"+cTpPromo)
						Else
							cClass := 1
						EndIf
						cClass := AllTrim(Str(cClass))

						cSql :=" UPDATE "+RetSqlName('SB1')+ " 			"
						cSql +=" 	SET B1_OBSTPES  = '"+cPromo+"',		"
						cSql +=" 	    B1_CLASSVE  = '"+cClass+"'		"
						cSql +=" WHERE B1_FILIAL 	= '"+cFilTab+"' 	"
						cSql +=" AND   B1_COD	    = '"+cProduto+"' 	"
						cSql +=" AND   D_E_L_E_T_   = ' ' 				"
						
						TcSqlExec(cSql)
						If Empty(TcSqlError())
							TcSqlExec('COMMIT')
						Else
							//		 	  1		   2		3		  4
							Aadd(aSB1Erros, {cFilTab, cCodTab, cProduto, TcSqlError()})
							TcSqlExec('ROLLBACK')
						EndIf



						// UPDATE ZA7
						cSql :=" UPDATE "+RetSqlName('ZA7')+ " 			"
						cSql +=" 	SET ZA7_TPPROM  = '"+cTpPromo+"'	"
						cSql +=" WHERE ZA7_FILIAL 	= '"+cFilTab+"' 	"
						cSql +=" AND   ZA7_CODPRO   = '"+cProduto+"' 	"
						cSql +=" AND   D_E_L_E_T_   = ' ' "

						TcSqlExec(cSql)
						If Empty(TcSqlError())
							TcSqlExec('COMMIT')
						Else
							//		 	  1		   2		3		  4
							Aadd(aZA7Erros, {cFilTab, cCodTab, cProduto, TcSqlError()})
							TcSqlExec('ROLLBACK')
						EndIf

					Else
						//					1		2		3			4		5            6
						Aadd(aDA1Erros, {cFilTab, cCodTab, cProduto, cPromo, cTpPromo, TcSqlError()})
						TcSqlExec('ROLLBACK')
					EndIf

	            Next

	        EndIf


			FT_FSKIP()
		EndDo        
		
		FCLOSE(cArqCsv)
		FT_FUSE()
	    
		*********************	
			ShowLogErro()			
		*********************
	    
	Else
		If !Schedule
			MsgAlert('IMPPRM01 - Erro ao abrir o arquivo !!!')
		Else
			ConOut( "IMPPRM01 - Erro ao abrir o arquivo "+cArqTabelas)		
		EndIf
    EndIf
    
Else
 	If !Schedule
 		MsgAlert("O arquivo "+cArqCsv+" nao pode ser aberto! Verifique os parametros.","Atencao!")
	Else
		ConOut( "IMPPRM01 - O arquivo "+cArqCsv+" nao pode ser aberto! Verifique os parametros.")
	EndIf
EndIf


IIF(Select('TRBDA0')!=0, TRBDA0->(DbCloseArea()), )
Return()
*********************************************************************
Static Function ClearSchedule()
*********************************************************************
Local cPathArq := AllTrim(GetMv('ES_DIRCSV'))
FErase(cDirSrv+cArqTabelas)
FErase(cPathArq)
PutMV('ES_DTIMP1', '')
PutMV('ES_DIRCSV', '')

cNomArq		:=	Space(150)
dDtSchedule	:=	CtoD("")
Return()
*************************************************************************
Static Function SqlChkMoeda()
*************************************************************************
Local aArea		:= 	GetArea()
Local cCpoSM2 	:= 	''
Local cRetSql 	:=	''
/*		
cSql +=" (	SELECT NVL(NVL(SB1.B1_CUSTRP,0) *  	"
cSql +=" 		CASE SB1.B1_MCUSTRP"
cSql += 	SqlChkMoeda()
cSql +=" 		END * NVL(IM1.IM1_MKPPR"+cTpPromo+",0),0)	"
						
cSql +="   		WHEN '1' THEN 1	"
cSql +="   		WHEN '2' THEN NVL(SM2.M2_MOEDA2,0)	"
cSql +="  		WHEN '3' THEN NVL(SM2.M2_MOEDA3,0)	"
cSql +="   		WHEN '4' THEN NVL(SM2.M2_MOEDA4,0)	"
cSql +="   		WHEN '5' THEN NVL(SM2.M2_MOEDA5,0)	"
cSql +="   		WHEN '6' THEN NVL(SM2.M2_MOEDA6,0)	"
cSql +="   		WHEN '7' THEN NVL(SM2.M2_MOEDA7,0)	"
cSql +="   		WHEN '8' THEN NVL(SM2.M2_MOEDA8,0)	"
cSql +="   		WHEN '9' THEN NVL(SM2.M2_MOEDA9,0)	"
cSql +="   		WHEN '10' THEN NVL(SM2.M2_MOEDA10,0)	"
cSql +="   		WHEN '11' THEN NVL(SM2.M2_MOEDA11,0)	"
cSql +="   		WHEN '12' THEN NVL(SM2.M2_MOEDA12,0)	"
*/

DbSelectArea('SM2')
For nM := 1 To FCount()
	cCpoSM2 := AllTrim(FieldName(nM))
	If Left(cCpoSM2, 08) == 'M2_MOEDA'
		cMoeda := SubStr(cCpoSM2, 09)
		If cMoeda == '1'
			cRetSql += "   		WHEN '1'  THEN 1					"+ENTER
		Else
			cRetSql += "   		WHEN '"+cMoeda+"'  THEN NVL(SM2.M2_MOEDA"+cMoeda+",0)	"+ENTER
		EndIf
	EndIf
Next

RestArea(aArea)
Return(cRetSql)
*************************************************************************
Static Function ShowLogErro()
*************************************************************************
	    
If 	Len(aDA1Erros)  == 0 .And.;
	Len(aFATErros)  == 0 .And.;
	Len(aSB1Erros)  == 0 .And.;
	Len(aZA7Erros)  == 0
	
	If !lSchedule
		MsgInfo("PROCESSO REALIZADO COM SUCESSO !!!")
	Else
		Conout("IMPPRM01 - PROCESSO REALIZADO COM SUCESSO !!!")
		***********************
			PromoEmail('')
		***********************
	Endif

Else

	cErroDA1 := ''
	cErroFAT := ''
	cErroSB1 := ''
	cErroZA7 := ''
	
	//					1		2		3			4		5            6
	// Aadd(aDA1Erros, _cFilial, _cTabela, _cProd, _cPromo, nNumPromo, TcSqlError())
	If Len(aDA1Erros) > 0
		For nX:=1 To Len(aDA1Erros)
			cMsgDA1 += 'FILIAL:   '+aDA1Erros[nX][01]+Space(05)+;
						'TABELA:   '+aDA1Erros[nX][02]+Space(05)+;
						'PRODUTO:  '+aDA1Erros[nX][03]+Space(05)+;
						'PROMO:    '+aDA1Erros[nX][04]+Space(05)+;
						'NUMPROMO: '+aDA1Erros[nX][05]+Space(05)+;
						'ERRO:     '+aDA1Erros[nX][06]
		Next
		
		If !lSchedule
			Aviso('Erro na atualização.','Problema [DA1] na atualização da tabela... O(s) seguinte(s) Produto(s) não foram atualizado(s).'+ENTER+ENTER+cErroDA1, {'Sair'}, 3)
		Else
			Conout('IMPPRM01 - Erro na atualização.','Problema [DA1] na atualização da tabela... O(s) seguinte(s) Produto(s) não foram atualizado(s). # '+cErroDA1 )
		Endif
	EndIf
	
	//		 	             1		   2		3		  4
	// Aadd(aFATErros, _cFilial, _cTabela, _cProd, TcSqlError())
	If Len(aFATErros) > 0
		cErroFAT := ''
		For nX:=1 To Len(aFATErros)
			cErroFAT += 'FILIAL:   '+aFATErros[nX][01]+Space(05)+;
						'TABELA:   '+aFATErros[nX][02]+Space(05)+;
						'PRODUTO:  '+aFATErros[nX][03]+Space(05)+;
						'ERRO:     '+aFATErros[nX][04]
		Next
		
		If !lSchedule
			Aviso('Erro na atualização.','Problema [FATOR]  na atualização da tabela... O(s) seguinte(s) Produto(s) não foram atualizado(s).'+ENTER+ENTER+cErroFAT, {'Sair'}, 3)
		Else
			Conout('IMPPRM01 - Problema [FATOR]  na atualização da tabela... O(s) seguinte(s) Produto(s) não foram atualizado(s). # '+cErroFAT )
		Endif
		
	EndIf
	
	
	//		            	  1		   2		3		  4
	//	Aadd(aSB1Erros, _cFilial, _cTabela, _cProd, TcSqlError())
	If Len(aSB1Erros) > 0
		For nX:=1 To Len(aSB1Erros)
			cErroSB1 += 'FILIAL:   '+aSB1Erros[nX][01]+Space(05)+;
						'TABELA:   '+aSB1Erros[nX][02]+Space(05)+;
						'PRODUTO:  '+aSB1Erros[nX][03]+Space(05)+;
						'ERRO:     '+aSB1Erros[nX][04]
		Next
		
		If !lSchedule
			Aviso('Erro na atualização.','Problema [SB1]  na atualização da tabela... O(s) seguinte(s) Produto(s) não foram atualizado(s).'+ENTER+ENTER+cErroSB1, {'Sair'}, 3)
		Else
			Conout('IMPPRM01 - Problema [SB1]  na atualização da tabela... O(s) seguinte(s) Produto(s) não foram atualizado(s). # ' + cErroSB1 )
		Endif
	EndIf
	
	//		 	           1		   2		3		  4
	//	Aadd(aZA7Erros, _cFilial, _cTabela, _cProd, TcSqlError())
	If Len(aZA7Erros) > 0
		For nX:=1 To Len(aZA7Erros)
			cErroZA7 += 'FILIAL:   '+aZA7Erros[nX][01]+Space(05)+;
						'TABELA:   '+aZA7Erros[nX][02]+Space(05)+;
						'PRODUTO:  '+aZA7Erros[nX][03]+Space(05)+;
						'ERRO:     '+aZA7Erros[nX][04]
		Next
		
		If !lSchedule
			Aviso('Erro na atualização.','Problema [ZA7]  na atualização da tabela... O(s) seguinte(s) Produto(s) não foram atualizado(s).'+ENTER+ENTER+cErroZA7, {'Sair'}, 3)
		Else
			Conout('IMPPRM01 - Problema [ZA7]  na atualização da tabela... O(s) seguinte(s) Produto(s) não foram atualizado(s). # ' + cErroZA7 )
		Endif
	EndIf

	If lSchedule
		cMsgErro := IIF(!Empty(cErroDA1), cErroDA1+ENTER, '')
		cMsgErro := IIF(!Empty(cErroFAT), cErroFAT+ENTER, '')
		cMsgErro := IIF(!Empty(cErroSB1), cErroSB1+ENTER, '')
		cMsgErro := IIF(!Empty(cErroZA7), cErroZA7+ENTER, '')	
	
		PromoEmail(cMsgErro)
	EndIf
	
EndIf
	
Return()
********************************************************************
Static Function PromoEmail(cMsgErro)
********************************************************************

cHtml := '<html>'
cHtml += '<head>'
cHtml += '<h3 align = Left><font size="3" face="Verdana" color="#0000FF">Importação .csv PROMO - Via WorkFlow</h3></font>' 
cHtml += '<br></br>'
cHtml += '<b><font size="2" face="Verdana" color="#0000FF">Processado em: </font></b>'
cHtml += '<b><font size="2" face="Verdana" color="#0000FF">'+Dtoc(Date())+' às '+Time()+'</font></b>'	    	
cHtml += '<br></br>'
cHtml += '</head>'
cHtml += '<body bgcolor = white text=black>'
cHtml += '<hr width=100% noshade>'
cHtml += '<br></br>'

cArqErro := cDirSrv+'\erro_wf_promo.txt'
IIF(!Empty(cMsgErro), MemoWrit(cArqErro, cMsgErro), )

cRotina		:=	'IMPPRM01'
cAssunto	:=	'Importação .csv PROMO - Via WorkFlow'
cPara		:=	AllTrim(GetMv('IM_WFPRECO'))
cCopia		:=	'fabiano.pereira@solutio.inf.br'
cCopOcult	:=	''
cCorpoEmail	:=	cHtml
cAtachado	:=	IIF(!Empty(cMsgErro), cArqErro, '')

U_ENVIA_EMAIL(cRotina, cAssunto, cPara, cCopia, cCopOcult, cCorpoEmail, cAtachado)

Return()
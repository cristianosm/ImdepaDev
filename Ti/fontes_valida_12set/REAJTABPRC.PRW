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
±±³Fun‡ao    |REAJTABPRC³Autor  ³                       ³Data  ³25/05/2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina REAJUSTE DE PRECO - TABELA DA0                        ³±±
±±³          ³VIA MENU E SCHEDULE                                          ³±±
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
User Function REAJTABPRC()
*********************************************************************
Private cPergMenu	:= 	'MNREAJUS'
Private cPergWF		:= 	'WFREAJUS'
Private cArqParam	:=	'\tabpreco_parametros.dtc'
Private cArqTabelas	:=	'\tabpreco_reajuste.dtc'
Private cDirSrv  	:= 	'\csv_import'
Private cMark    	:= 	'X'
Private cNomArq 	:= 	Space(150)    
Private lInverte 	:= 	.F.
Private lExecPerg	:=	.F.
Private lSchedule  	:= 	Type("dDatabase") == "U" // Se rodado via workflow a variável dDatabase estara disponivel somente apos o Prepare Environment
Private oData     	:= 	Nil
Private dDtSchedule := 	CtoD("")
Private oTelaIni
Private oMark
Private cArqDA0
Private cArqSX1



If !lSchedule

    ***************************** 
		CheckSX6(); AjustaSX1()
	*****************************

	cMark := GetMark()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem da tela de processamento.                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	dDtSchedule := 	IIF(Empty(AllTrim(GetMV("ES_DTIMP2"))),dDtSchedule, StoD(AllTrim(GetMV("ES_DTIMP2"))))
	dDtSchedule := 	IIF(dDtSchedule < dDataBase, CtoD(""), 	dDtSchedule)
	cColor	 	:= 	IIF(Empty(dDtSchedule), CLR_BLACK, CLR_HRED)
	
	@ 200,001 To 380,450 Dialog oTelaIni Title OemToAnsi("Reajuste de Preços")

   	@ 0.5,001 To 006,028
   	@ 018,012 Say "Este programa ira realizar o reajuste dos preços conforme parâmetros." 	Size 230 //Of oTelaIni
   		
	cSayData := IIF(Empty(dDtSchedule), 'Agendar execução:', 'Agendado para:') 
   	@ 037,015 Say cSayData	Size 100, 7 Pixel COLOR cColor Of oTelaIni
   	@ 035,065 MsGet oData 	Var dDtSchedule	Size 55 , 7 When .T. Valid Empty(dDtSchedule) .Or. dDtSchedule >= dDataBase Pixel Of oTelaIni

   	@ 052,012 Button "Param. Agendamento" 	Size 060, 011 Pixel Of oTelaIni Action ChkTpPerg('WF')
   	@ 065,012 Button "Limpar Agendamento" 	Size 060, 011 Pixel Of oTelaIni Action ClearSchedule()
   	@ 065,095 Button "Tab.Preço" 			Size 030, 011 Pixel Of oTelaIni Action SelTabelas()
   	@ 065,128 BmpButton Type 05 Action ChkTpPerg('MENU')
   	@ 065,158 BmpButton Type 01 Action IIF(ValidInfos(), Close(oTelaIni), )
   	@ 065,188 BmpButton Type 02 Action Close(oTelaIni)

   	Activate Dialog oTelaIni Centered


Else


	//PREPARE ENVIRONMENT EMPRESA aParam[01] FILIAL aParam[02] FUNNAME 'REAJTABPRC' TABLES 'SM0','DA0','SX6'
	ConOut("----------------------- REAJTABPRC -----------------------") 
	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '05' FUNNAME 'REAJTABPRC' TABLES 'SM0','DA0','SX6'	
	ConOut("REAJTABPRC - INICIO -  DATA:"+DtoS(dDataBase)+' HORA: '+ Time())
	
    ******************************** 
		CheckSX6(); OpenPerg()
	********************************

	ConOut( "REAJTABPRC - Inicio - " + Time() )
	
	*************************	
		UpReajuste()
	*************************

	ClearSchedule()
	ConOut("REAJTABPRC - FIM -  DATA:"+DtoS(dDataBase)+' HORA: '+ Time())
		
	RESET ENVIRONMENT
	
EndIf


Return()
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

	cArqDA0 := CriaTrab(aStru,.T.)
	DbUseArea(.T.,,cArqDA0, "TRB", .F., .F.)
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
IIF(!ExisteSX6('ES_DTIMP2'), 	CriarSX6('ES_DTIMP2',  'C','Data para rodar rotina REAJTABPRC via schedule.', 	'' 	), )
IIF(!ExisteSX6('IM_TAMPROD'),	CriarSX6('IM_TAMPROD', 'N','Tamanho codigo produto.', '8' ),)
IIF(!ExisteSX6('IM_WFPRECO'), 	CriarSX6('IM_WFPRECO', 'C','Email utilizado nos programas REAJTABPRC, IMPFAT01, IMPPRM01',	'luana' ), )

Return()
*********************************************************************
Static Function ValidInfos()
*********************************************************************
Local lRetorno 	:= 	.T.
Local lSelect	:=	.F. 

If !lExecPerg     
	MsgAlert('Não foi definido os parâmentros para processar a rotina.'+ENTER+'Clique no botão "Parametros" ou "Param. Agendamento".')
	lRetorno := .F.

ElseIf Select('TRB') > 0
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
        

If lRetorno

    If !lSchedule .And. Empty(dDtSchedule)
		lRetorno := MsgYesNo('Confirma a EXECUÇÃO do Reajuste conforme parâmetros???')

		If lRetorno
			Processa( {|| UpReajuste()},"Aguarde...","Processando Reajustes...")
		EndIf
    Else
   		lRetorno :=	F_Agenda()
    EndIf
EndIf

Return(lRetorno)
********************************************************************
Static Function UpReajuste()
********************************************************************
Local lRetUp	:=	.T.
Local aCodTab 	:=	{}
Local aErros	:= 	{}
Local nTotReg	:=	0
Local nTotUpdOK	:=	0

If lSchedule
    If !File(cDirSrv+cArqTabelas)
	    ConOut('REAJTABPRC - ARQUIVO  '+cDirSrv+cArqTabelas+' NAO EXISTE !!!')   
		Aadd(aErros, {'XX', 'XX', 'XXX', 'REAJTABPRC - ARQUIVO  '+cDirSrv+cArqTabelas+' NAO EXISTE !!!'})
    Else
	    // TABELA COM A SELECAO DAS TABELAS E FILIAS 
		IIF(Select('TRB')!=0, TRB->(DbCloseArea()), )
		DbUseArea(.T.,,cDirSrv+cArqTabelas, "TRB", .F., .F.)
	EndIf
EndIf

						
DbSelectArea('TRB');DbGoTop()
Do While !Eof()    
	If !Empty(TRB->OK)
		Aadd(aCodTab, {TRB->FILIAL, TRB->TABELA})
	EndIf
	DbSelectArea('TRB')
	DbSkip()
EndDo
IIF(Select('TRB')!=0, TRB->(DbCloseArea()), )


If lSchedule
	If Select('T_PARAM') > 0
	    cMV_PAR01	:=	T_PARAM->MV_PAR01
	    cMV_PAR02	:=	T_PARAM->MV_PAR02
	    cMV_PAR03	:=	T_PARAM->MV_PAR03
	    cMV_PAR04	:=	T_PARAM->MV_PAR04
	    cMV_PAR05	:=	T_PARAM->MV_PAR05
	    cMV_PAR06	:=	T_PARAM->MV_PAR06
	    cMV_PAR07	:=	T_PARAM->MV_PAR07
	    cMV_PAR08	:=	T_PARAM->MV_PAR08
	    nMV_PAR09	:=	T_PARAM->MV_PAR09
	    nMV_PAR10	:=	T_PARAM->MV_PAR10	    

	Else
	    ConOut('REAJTABPRC - NAO FOI POSSIVEL ABRIR O ARQUIVO DE PARAMETRO ----- Select(T_PARAM) == 0 !!!')	
		Aadd(aErros, {'XX', 'XX', 'XXX', 'REAJTABPRC - NAO FOI POSSIVEL ABRIR O ARQUIVO DE PARAMETRO ----- Select(T_PARAM) == 0 !!!'})
	EndIf
Else
    cMV_PAR01	:=	MV_PAR01
    cMV_PAR02	:=	MV_PAR02
    cMV_PAR03	:=	MV_PAR03
    cMV_PAR04	:=	MV_PAR04
    cMV_PAR05	:=	MV_PAR05
    cMV_PAR06	:=	MV_PAR06
    cMV_PAR07	:=	MV_PAR07
    cMV_PAR08	:=	MV_PAR08
    nMV_PAR09	:=	MV_PAR09
    nMV_PAR10	:=	MV_PAR10
EndIf


If Len(aErros) == 0			

	For nX:=1 To Len(aCodTab)
		
		cFilTab := 	aCodTab[nX][01]
		cCodTab :=	aCodTab[nX][02]
		
		cFilBck	:=	cFilAnt
		cFilAnt := 	cFilTab
	
		IIF(Select('SQL')!=0, SQL->(DbCloseArea()), )
		cSql := " SELECT SB1.B1_COD AS CODPRO, "					//	SELECT DOS ITENS QUE SERAO ATUALIZADOS
		cSql +=      " NVL( SB1.B1_CUSTRP, 0 ) AS CUSTRP, "       	//	CUSTO DE REPOSICAO
		cSql +=      " CASE SB1.B1_MCUSTRP "                       	//	BUSCA A MOEDA CORRETA
		cSql += 		SqlChkMoeda()
		cSql +=      " END AS MOEDA, "
		cSql +=      "   CASE TRIM( B1_OBSTPES ) "                 	//	BUSCA O MARKUP CORRETO CONFORME A PROMO
		cSql +=             " WHEN 'PROMO 1' THEN IM1.IM1_MKPPR1 "
		cSql +=             " WHEN 'PROMO 2' THEN IM1.IM1_MKPPR2 "
		cSql +=             " WHEN 'PROMO 3' THEN IM1.IM1_MKPPR3 "
		cSql +=             " WHEN 'PROMO 4' THEN IM1.IM1_MKPPR4 "
		cSql +=             " ELSE IM1.IM1_MARKUP "
		cSql +=      "   END AS MARKUP "
		
		cSql +=  " FROM " + RetSqlName( "SB1" ) + " SB1 "
		cSql +=     " , " + RetSqlName( "IM1" ) + " IM1 "
		cSql +=     " , " + RetSqlName( "SM2" ) + " SM2 "
		cSql +=     " , " + RetSqlName( "DA1" ) + " DA1 "
		cSql += " WHERE SB1.D_E_L_E_T_ 	= 	' ' "
		cSql +=   " AND IM1.D_E_L_E_T_ 	= 	' ' "
		cSql +=   " AND SM2.D_E_L_E_T_ 	= 	' ' "
		cSql +=   " AND DA1.D_E_L_E_T_ 	= 	' ' "
		cSql +=   " AND IM1.IM1_COD 	= 	SB1.B1_CURVA "
		cSql +=   " AND IM1.IM1_FILIAL 	= 	SB1.B1_FILIAL "
		cSql +=   " AND DA1.DA1_CODTAB 	= 	IM1.IM1_SEGMEN "
		cSql +=   " AND DA1.DA1_CODPRO 	= 	SB1.B1_COD "
		cSql +=   " AND DA1.DA1_FILIAL 	= 	SB1.B1_FILIAL "
		cSql +=   " AND IM1.IM1_SEGMEN 	= 	'" + cCodTab + "' "                               	//	TABELA QUE SERA ATUALIZADA
		cSql +=   " AND SB1.B1_FILIAL 	= 	'" + cFilTab + "' "                               	//	FILIAL ( 05 )
		cSql +=   " AND SM2.M2_DATA 	= 	'" + DtoS(dDataBase) + "' "     	                //	DATA DA COTACAO DA MOEDA (DATA DO DIA)
		cSql +=   " AND SB1.B1_COD 		BETWEEN '" + cMV_PAR01 + "' AND '" + cMV_PAR02 + "' "   //	CODIGO DO PRODUTO / DE-ATE
		cSql +=   " AND SB1.B1_CODITE 	BETWEEN '" + cMV_PAR03 + "' AND '" + cMV_PAR04 + "' "	//	CODITE / DE-ATE
		cSql +=   " AND SB1.B1_GRMAR3 	BETWEEN '" + cMV_PAR05 + "' AND '" + cMV_PAR06 + "' "  	//	GRUPO DE MARCAS 3 / DE-ATE
		cSql +=   " AND SB1.B1_CURVA 	BETWEEN '" + cMV_PAR07 + "' AND '" + cMV_PAR08 + "' "  	//	CURVA IMDEPA / DE-ATE
		
		If nMV_PAR10 == 1  // PROMO = 1 (NAO)
			cSql += " AND NVL( TRIM( SB1.B1_OBSTPES ), 'X' ) NOT IN ( 'PROMO 1', 'PROMO 2', 'PROMO 3', 'PROMO 4' ) "
		Endif
		
		cSql += " AND NVL( TRIM( SB1.B1_OBSTPES ), 'X' ) NOT IN ( 'PROMO F', 'PROMOF' ) "
		
		//MsgRun('Verificando dados...', 'Aguarde... ',{|| DbUseArea( .T., "TOPCONN", TcGenQry( Nil, Nil, cSql), "SQL" ) }) 
		DbUseArea( .T., "TOPCONN", TcGenQry( Nil, Nil, cSql), "SQL" )
		
		DbSelectArea('SQL');DbGoTop()
		nTotSql	:=	0
		nCount 	:=	0
		SQL->(dbEval({|| nTotSql++},,,))
		nTotReg	+=	nTotSql
		SQL->(DbGoTop())	
		ProcRegua(nTotSql)


		DbSelectArea('SQL');DbGoTop()
		Do While !Eof()
			nCount++
			IncProc('Processando... '+AllTrim(cValToChar(nCount))+' de '+AllTrim(cValToChar(nTotSql))+' registros.') 		
	

			//UPDATE ESTá UTILIZANDO O íNDICE 1 NO PLANO DE ACESSO
			cSql := "UPDATE  "+RetSqlName('DA1')                      //CUSTO DE REPOSICAO * MOEDA * MARKUP
			cSql +=    " SET DA1_PRCVEN = " + AllTrim(Str(SQL->CUSTRP * SQL->MOEDA * SQL->MARKUP, Nil, 04))
			
			If nMV_PAR09 == 2 //fator == 2 (sim)
				cSql +=  " * DECODE( DA1_PERDES, 0, 1, DA1_PERDES ) " 	//	ACRESCENTA * FATOR SE FOR SELECIONADO O PARAMETRO.
			Endif                                                     	//	OBS: SE FOR ZERO, RECEBERá 1, POIS MULTIPLICAR POR ZERO IRá ZERAR O PREçO
			
			cSql +=	" WHERE DA1_FILIAL = '" + cFilTab + "' "         	//	FILIAL
			cSql +=	" AND DA1_CODPRO = '" + SQL->CODPRO + "' "   		//	COD. PRODUTO
			cSql +=	" AND DA1_CODTAB = '" + cCodTab + "' "          	//	TABELA
			cSql +=	" AND D_E_L_E_T_ = ' ' "
			
	
			TcSqlExec(cSql)
			If Empty(TcSqlError()) 
				TcSqlExec('COMMIT')
				nTotUpdOK++
			Else
				Aadd(aErros, {cFilTab, cCodTab, SQL->CODPRO, TcSqlError()})
				TcSqlExec('ROLLBACK')
			EndIf
				
	
			DbSelectArea('SQL')
			DbSkip()
		EndDo
	
		cFilAnt := 	cFilBck
		
	Next
	
EndIf
	
cMsgErro  := ''
If Len(aErros) > 0
	For nX:=1 To Len(aErros)
		cMsgErro += 'FILIAL:   '+aErros[nX][01]+Space(05)+;
					'TABELA:   '+aErros[nX][02]+Space(05)+;
					'PRODUTO:  '+aErros[nX][03]+Space(05)+;
					'ERRO:     '+aErros[nX][04]
	Next
EndIf

If !lSchedule                                
	MsgInfo("Foram Reajustados  "+cValToChar(nTotUpdOk)+"  de  "+cValToChar(nTotReg)+" registros.") 
    If !Empty(cMsgErro)
    	lRetUp	 :=	.F.
		Aviso('Erro na atualização.','O(s) seguinte(s) Produto(s) não foram atualizado(s).'+ENTER+ENTER+cMsgErro, {'Sair'}, 3)
	EndIf
Else
	ConOut("Foram Reajustados  "+cValToChar(nTotUpdOk)+"  de  "+cValToChar(nTotReg)+" registros.") 
    If !Empty(cMsgErro)
		Conout('REAJUSTE - Erro na atualização.','O(s) seguinte(s) Produto(s) não foram atualizado(s). # '+cMsgErro )
	EndIf

	**************************	
		ReajEmail(cMsgErro)
	**************************
EndIf					
			

IIF(Select('SQL')!=0, SQL->(DbCloseArea()), )
Return(lRetUp)
********************************************************************
Static Function AjustaSX1()
********************************************************************
Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}


cPergMenu	:=	PadR(cPergMenu, Len(SX1->X1_GRUPO))

PutSx1(cPergMenu, "01",'Do produto?',"","","mv_ch1","C",15,0,0,"G","","SB1","","","mv_par01",,,,,,,,"","","","","","","","","",,,,"")
PutSx1(cPergMenu, "02",'Até produto?',"","","mv_ch2","C",15,0,0,"G","","SB1","","","mv_par02",,,,,,,,"","","","","","","","","",,,,"")
PutSx1(cPergMenu, "03",'Cod. Item de?',"","","mv_ch3","C",27,0,0,"G","","","","","mv_par03",,,,,,,,"","","","","","","","","",,,,"")
PutSx1(cPergMenu, "04",'Cod. Item Ate?',"","","mv_ch4","C",27,0,0,"G","","","","","mv_par04",,,,,,,,"","","","","","","","","",,,,"")
PutSx1(cPergMenu, "05",'Do grupo marcas 3?',"","","mv_ch5","C",10,0,0,"G","","Z8","","","mv_par05",,,,,,,,"","","","","","","","","",,,,"")
PutSx1(cPergMenu, "06",'Até grupo marcas 3?',"","","mv_ch6","C",10,0,0,"G","","Z8","","","mv_par06",,,,,,,,"","","","","","","","","",,,,"")
PutSx1(cPergMenu, "07",'Da Curva?',"","","mv_ch7","C",4,0,0,"G","","IM1","","","mv_par07",,,,,,,,"","","","","","","","","",,,,"")
PutSx1(cPergMenu, "08",'Até a Curva?',"","","mv_ch8","C",4,0,0,"G","","IM1","","","mv_par08",,,,,,,,"","","","","","","","","",,,,"")
PutSx1(cPergMenu, "09","Considera Fator?","","?","mv_ch9","N",1,0,0,"C","","","","","mv_par09","Nao","No","No","","Sim","Si","Yes","","","","","","","","","","","","")
PutSx1(cPergMenu, "10","Considera Promos?","","?","mv_ch10","N",1,0,0,"C","","","","","mv_par10","Nao","No","No","","Sim","Si","Yes","","","","","","","","","","","","")


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  PERGUNTAS IGUAIS PARA EXECUCAO VIA MENU E WORKFLOW           ³
//³  ISSO PARA EVITAR POSSIVEIS ERROS                             ³
//³  EX.: AGENDA WF INFO "X" PARAMETROS E DEPOIS ENTRAR NA ROTINA ³
//³  NOVAMENTE E COLOCAR OUTROS PARAMETROS..                      ³
//³  WF IRA PEGAR O ULTIMO PARAMETRO.                             ³
//³                                                               ³
//³  COM PERGUNTAS SEPARADAS CADA UM FICA INDEPENDENTE            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cPergWF	:=	PadR(cPergWF, Len(SX1->X1_GRUPO))

PutSx1(cPergWF, "01",'Do produto?',"","","mv_ch1","C",15,0,0,"G","","SB1","","","mv_par01",,,,,,,,"","","","","","","","","",,,,"")
PutSx1(cPergWF, "02",'Até produto?',"","","mv_ch2","C",15,0,0,"G","","SB1","","","mv_par02",,,,,,,,"","","","","","","","","",,,,"")
PutSx1(cPergWF, "03",'Cod. Item de?',"","","mv_ch3","C",27,0,0,"G","","","","","mv_par03",,,,,,,,"","","","","","","","","",,,,"")
PutSx1(cPergWF, "04",'Cod. Item Ate?',"","","mv_ch4","C",27,0,0,"G","","","","","mv_par04",,,,,,,,"","","","","","","","","",,,,"")
PutSx1(cPergWF, "05",'Do grupo marcas 3?',"","","mv_ch5","C",10,0,0,"G","","Z8","","","mv_par05",,,,,,,,"","","","","","","","","",,,,"")
PutSx1(cPergWF, "06",'Até grupo marcas 3?',"","","mv_ch6","C",10,0,0,"G","","Z8","","","mv_par06",,,,,,,,"","","","","","","","","",,,,"")
PutSx1(cPergWF, "07",'Da Curva?',"","","mv_ch7","C",4,0,0,"G","","IM1","","","mv_par07",,,,,,,,"","","","","","","","","",,,,"")
PutSx1(cPergWF, "08",'Até a Curva?',"","","mv_ch8","C",4,0,0,"G","","IM1","","","mv_par08",,,,,,,,"","","","","","","","","",,,,"")
PutSx1(cPergWF, "09","Considera Fator?","","?","mv_ch9","N",1,0,0,"C","","","","","mv_par09","Nao","No","No","","Sim","Si","Yes","","","","","","","","","","","","")
PutSx1(cPergWF, "10","Considera Promos?","","?","mv_ch10","N",1,0,0,"C","","","","","mv_par10","Nao","No","No","","Sim","Si","Yes","","","","","","","","","","","","")


Return()
********************************************************************
Static Function ChkTpPerg(cOpcao)
********************************************************************
Local lRetorno := .T.

If cOpcao == 'WF'
	SX1->(Dbseek(PadR(cPergWF, Len(SX1->X1_GRUPO))))
	If Pergunte(cPergWF, IIF(!lSchedule, .T., .F.))
		lExecPerg := .T.
		If !SalveParam()
			MsgAlert('Não foi possível salvar o arquivo de PARAMETROS.'+ENTER+'Clique no botão "ParÂmetros Agendamendo" para tentar salvar os parâmetros novamente!!!'+ENTER+'Caso não seja possível salvar os parâmetros entre em contato com a T.I !!!')
			lRetorno := .F.
		EndIf
	EndIf
ElseIf cOpcao == 'MENU'
	SX1->(Dbseek(PadR(cPergMenu, Len(SX1->X1_GRUPO))))
	Pergunte(cPergMenu, .T., "Opções de Reajuste - Menu")
	lExecPerg := .T.

EndIf

Return(lRetorno)
*********************************************************************
Static Function ClearSchedule()
*********************************************************************
dDtSchedule	:=	CtoD("")
FErase(cDirSrv+cArqTabelas)
FErase(cDirSrv+cArqParam)
PutMV('ES_DTIMP2', '')

Return()
********************************************************************
Static Function F_Agenda()
********************************************************************
Local cArquivo 	:= 	''
Local cCodXX1	:=	''
Local aErros	:=	{}
Local lDisable	:=	.F.
Local lCadWf   	:=	.F.
Local cHoraWF	:=	''


If !Empty(dDtSchedule)
	
	
	IIF(Select('TMPTSK')!=0, TMPTSK->(DbCloseArea()), )
	cQuery := "	SELECT  * FROM SCHDTSK					"+ENTER	
	cQuery += " WHERE   TSK_ROTINA LIKE '%REAJTABPRC%'	"+ENTER
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

		/*
		If TMPTSK->TSK_STATUS == "0"
			lDisable := .T.
			cCodXX1	 :=	TMPTSK->TSK_CODIGO
			Exit

		ElseIf !Empty(TMPTSK->TSK_DIA)
			If TMPTSK->TSK_DIA > DtoS(dDtSchedule)
				Aadd(aErros, 'Schedule já programado para: '+DtoC(StoD(TMPTSK->TSK_DIA))+ENTER+;
						  'Agende sua execução para DATA MAIOR ou IGUAL a data de hoje ('+DtoC(Date())+')' )
				Exit
			EndIf

		ElseIf !(TMPTSK->TSK_STATUS $ "0/2")
			cHoraWF	:=	TMPTSK->TSK_HORA
			lDisable:= .F.	
			lCadWf 	:= .T.
			Exit
		EndIf
		*/
			
		
			
		DbSkip()
	EndDo
	
	
	IIF(Select('TMPTSK')!=0, TMPTSK->(DbCloseArea()), )
	
	If !lCadWf
		Aadd(aErros, 'Schedule da rotina REAJTABPRC NÃO cadastrada. Entre em contato com Depto T.I') 	
	EndIf
	If lDisable
		Aadd(aErros, 'Schedule da rotina REAJTABPRC (Código: '+cCodXX1+') esta desabilitado. Entre em contato com Depto T.I') 
	EndIf

	
					
	If Len(aErros) == 0
		
		If MsgYesNo( "Confirma o AGENDAMENTO da rotina para execução no  DIA: "+DtoC(dDtSchedule)+"  ÀS  "+cHoraWF+ENTER+"Confirma?" )
			
			If !ExistDir(cDirSrv)
				nErro := MakeDir(cDirSrv)
				If nErro > 0
					Aadd(aErros, "Erro na criação do diretorio  "+cDirSrv+"  no Servidor. Código de erro *MakeDir: " + Alltrim(Str(nErro)) + "." )
				EndIf
			EndIf
			

			// GRAVA ARQUIVO COM AS FILIAIS\TABELAS SELECIONADAS
			cArqTrbDA0 	:= 	'/system/'+cArqDA0+'.dtc'	// GRAVA POR PADRAO NO \SYSTEM\
			If File(cArqTrbDA0)
				
				IIF(Select('TRB')!=0, TRB->(DbCloseArea()), )
				
				__CopyFile(cArqTrbDA0, cDirSrv+cArqTabelas)	// COPIA DO \SYSTEM\ PARA O \PROTHEUS_DATA\
				
				If !File(cDirSrv+cArqTabelas)
					Aadd(aErros, "Não foi possivel copiar o arquivo (arq. com filiais\tabelas) de trabalho para o servidor. ("+cDirSrv+cArqTabelas+") " )
				EndIf
			
			Else
				Aadd(aErros, 'Arquivo de trabalho (arq. com filiais\tabelas) não encontrado!'+ENTER+'Clique no botão "ParÂmetros" para selecionar Filiais \ Tabelas!!!')
			EndIf
			
		
			// COPIA ARQUIVO .CSV PARA O SERVIDOR
			cArquivo :=  Right(cNomArq, Len(cNomArq) - Rat("\", cNomArq))
			If File(cDirSrv + "\" + cArquivo)
				
				nErro := FErase(cDirSrv + "\" + cArquivo)
				If nErro > 0
					Aadd(aErros, "Erro ao excluir arquivo " + cArquivo +  " do Servidor. Código de erro *FErase: " + Alltrim(Str(nErro)) + "." )
				EndIf

			EndIf
		

			// GRAVA COM PERGUNTAS 
			cArqTrbParam :=	'/system/'+cArqSX1+'.dtc'	// GRAVA POR PADRAO NO \SYSTEM\
			If File(cArqTrbParam)

				__CopyFile(cArqTrbParam, cDirSrv+cArqParam)	// COPIA DO \SYSTEM\ PARA O \PROTHEUS_DATA\
				
				If !File(cDirSrv+cArqTabelas)
					Aadd(aErros, "Não foi possivel copiar o arquivo de parametros para o servidor. ("+cDirSrv+cArqParam+") " )
				EndIf
			
			Else
				Aadd(aErros, 'Arquivo de trabalho (arq. com filiais\tabelas) não encontrado!'+ENTER+'Clique no botão "ParÂmetros" para selecionar Filiais \ Tabelas!!!')
			EndIf


			If Len(aErros) == 0
				PutMV("ES_DTIMP2", DtoS(dDtSchedule))
				MsgInfo("Dados para execução de agendamento efetuado com sucesso." )
			EndIf

		EndIf

	Else
		Aadd(aErros, 'Rotina REAJTABPRC nao encontrada no Schedule.')
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
********************************************************************
Static Function SqlChkMoeda()
********************************************************************
Local aArea		:= 	GetArea()
Local cCpoSM2 	:= 	''
Local cRetSql 	:=	''
/*
cSql +="   		WHEN '1'  THEN 1					"+ENTER
cSql +="   		WHEN '2'  THEN NVL(SM2.M2_MOEDA2,0)	"+ENTER
cSql +="   		WHEN '3'  THEN NVL(SM2.M2_MOEDA3,0)	"+ENTER
cSql +="   		WHEN '4'  THEN NVL(SM2.M2_MOEDA4,0)	"+ENTER
cSql +="   		WHEN '5'  THEN NVL(SM2.M2_MOEDA5,0)	"+ENTER
cSql +="   		WHEN '6'  THEN NVL(SM2.M2_MOEDA6,0)	"+ENTER
cSql +="   		WHEN '7'  THEN NVL(SM2.M2_MOEDA7,0)	"+ENTER
cSql +="   		WHEN '8'  THEN NVL(SM2.M2_MOEDA8,0)	"+ENTER
cSql +="   		WHEN '9'  THEN NVL(SM2.M2_MOEDA9,0)	"+ENTER
cSql +="   		WHEN '10' THEN NVL(SM2.M2_MOEDA10,0)"+ENTER
cSql +="   		WHEN '11' THEN NVL(SM2.M2_MOEDA11,0)"+ENTER
cSql +="   		WHEN '12' THEN NVL(SM2.M2_MOEDA12,0)"+ENTER
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
********************************************************************
Static Function ReajEmail(cMsgErro)
********************************************************************

cHtml := '<html>'
cHtml += '<head>'
cHtml += '<h3 align = Left><font size="3" face="Verdana"color="#0000FF">Reajuste de Preço - Via WorkFlow</h3></font>' 
cHtml += '<br></br>'
cHtml += '<b><font size="2" face="Verdana" color="#0000FF">Processado em: </font></b>'
cHtml += '<b><font size="2" face="Verdana" color="#0000FF"> '+Dtoc(Date())+' às '+Time()+'</font></b>'	    	
cHtml += '<br></br>'
cHtml += '</head>'
cHtml += '<body bgcolor = white text=black>'
cHtml += '<hr width=100% noshade>'
cHtml += '<br></br>'

cArqErro := cDirSrv+'\erro_wf_reajuste.txt'
IIF(!Empty(cMsgErro), MemoWrit(cArqErro, cMsgErro), )

cRotina		:=	'REAJTABPRC'
cAssunto	:=	'Reajuste de Preço - Via WorkFlow'
cPara		:=	AllTrim(GetMv('IM_WFPRECO'))
cCopia		:=	''
cCopOcult	:=	''
cCorpoEmail	:=	cHtml
cAtachado	:=	IIF(!Empty(cMsgErro), cArqErro, '')

U_ENVIA_EMAIL(cRotina, cAssunto, cPara, cCopia, cCopOcult, cCorpoEmail, cAtachado)

Return()
********************************************************************
Static Function SalveParam()
********************************************************************
Local lRetorno	:=	.T.
Local aStru		:=	{}
Local aParam	:=	{}
// cArqParam	:=	'\tabpreco_parametros.dtc'

If Select('T_PARAM') > 0 
	DbSelectArea('T_PARAM')
	RecLock('T_PARAM', .F.)
		Zap
	MsUnLock()

Else

    DbSelectArea('SX1') 
	Dbseek(PadR(cPergWF, Len(SX1->X1_GRUPO)))
	Do While !Eof() .And. AllTrim(cPergWF) == AllTrim(SX1->X1_GRUPO)

		Aadd(aStru,	 { Upper(SX1->X1_VAR01),  SX1->X1_TIPO, SX1->X1_TAMANHO, SX1->X1_DECIMAL })
		Aadd(aParam, { Upper(SX1->X1_VAR01), &(SX1->X1_VAR01) })
		
		DbSelectArea('SX1')
		DbSkip()
	EndDo

	cArqSX1 := CriaTrab(aStru,.T.)
	DbUseArea(.T.,,cArqSX1, 'T_PARAM', .F., .F.)	   	
	
EndIf

DbSelectArea('T_PARAM')
RecLock('T_PARAM', .T.)  
	For nX:=1 To Len(aParam)
		xParam		:= 	AllTrim(aParam[nX][01])
		cConteudo	:=	aParam[nX][02]
		T_PARAM->&(xParam) := cConteudo
	Next	
MsUnLock()


lRetorno := IIF(File('/system/'+cArqSX1+'.dtc'), .T., .F.)
Return(lRetorno)
********************************************************************
Static Function OpenPerg()
********************************************************************
If File(cDirSrv+cArqParam)
	IIF(Select('T_PARAM')!=0, T_PARAM->(DbCloseArea()), )
	DbUseArea(.T.,,cDirSrv+cArqParam, 'T_PARAM', .F., .F.)

    DbSelectArea('SX1') 
	Dbseek(PadR(cPergWF, Len(SX1->X1_GRUPO))) 
	
	/*
	DbSelectArea('T_PARAM') 
	For nX := 1 To T_PARAM->(FCount()) 
		IF NX == 2
		    CONOUT('ANTES MV_PAR02 == '+MV_PAR02)
		ELSEIF NX == 10
		    CONOUT('ANTES MV_PAR10 == '+MV_PAR10)
		ENDIF
		
		&(T_PARAM->(FieldName(nX))) := &(T_PARAM->(FieldName(nX)))

		IF NX == 2
		    CONOUT('DEPOIS MV_PAR02 == '+MV_PAR02)
		ELSEIF NX == 10
		    CONOUT('DEPOIS MV_PAR10 == '+MV_PAR10)
		ENDIF
	Next
	*/				
EndIf

Return()
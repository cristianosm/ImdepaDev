#include "Protheus.ch"

#Define _LC		1
#Define _SALDUP 2
#Define _RISCO  3
#Define _ULTCOM 4
#Define _VENCLC 5

//ajustado 04/09/2014
//testes com mauricio

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Funcao    |CAMPRODAPE   |Autor  ³CRISTIANO MACHADO   |Data  |31/07/13  ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡ao |Adiciona Campos no Rodape da Tela da Verdade...             ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Uso       |CAMPRODAPE                                                  ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
********************************************************************
User Function CAMPRODAPE()
********************************************************************

Local cCampo :=	SubStr(ReadVar(),04)
Local cPonto := PROCNAME(1)

If cPonto == "U_TMKACTIVE" //| Criacao das Variavaies

	Public _nPosPeF		:= Len(aValores) + 1  //| Percentual Frete
	Public _nPosObC		:= Len(aValores) + 2  //| Obs Cliente
	Public _nPosFrtMin	:= Len(aValores) + 3  //| Frete Minimo
	//Public _nPosFrt := Len(aValores) + 3  //frete calculado CIFI


	aADD( aValores, 0  ) // Percentual Frete
	aADD( aValores, "" ) // Obs Cliente
	aADD( aValores, 0  ) // Frete Minimo
	//aADD( aValores, 0  )  //frete calculado CIFI


	@ 020,190  SAY "Perc. Frete" OF oFoldRodape:aDialogs[1] PIXEL SIZE 55,90
	@ 019,220  MSGET oPerFrete VAR aValores[_nPosPeF] Picture "@R 999.99 %" OF oFoldRodape:aDialogs[1] PIXEL When .F. SIZE 70,9

	//@ 020,190+150  SAY "Frt Inc" OF oFoldRodape:aDialogs[1] PIXEL SIZE 55,90
	//@ 019,220+150  MSGET oVlrFrt VAR aValores[_nPosFrt] Picture "@R 9,999,999.99 " OF oFoldRodape:aDialogs[1] PIXEL SIZE 70,9



	@ 035,190  SAY "Obs Cliente" OF oFoldRodape:aDialogs[1] PIXEL SIZE 55,90
	@ 034,220  MSGET oObsCli VAR aValores[_nPosObC] Picture "@!" OF oFoldRodape:aDialogs[1] PIXEL When .F. SIZE 250,9

	//Robson - 14/11/2014 - Mostrar frete minimo na tela
	@ 020,300  SAY "Frete Mínimo" OF oFoldRodape:aDialogs[1] PIXEL SIZE 55,90
	@ 019,335  MSGET oPerFrete VAR aValores[_nPosFrtMin] Picture "@R 999,999.99" OF oFoldRodape:aDialogs[1] PIXEL When .F. SIZE 70,9


ElseIf cPonto == "U_TMKVCP" // Atualiza Variavel Percentual Frete



	nMerc := MaFisRet(  , "NF_TOTAL" )

	//VAI FUNCIONAR SO COM FILIAL 05
	//QUANTO FOR PARA TODAS TROCAR
	//XFILIAL('SUA')<>'07' .OR. XFILIAL('SUA')<>'11'	//.AND. (SA1->A1_CLFAMIN<>'S')


	//ALERT(NMERC)


	//MV_FILFRT='05/11'
	LVINCULO:=ALLTRIM(SA1->A1_VINCULO)$  ("#CM*CM*#PP*PP")
	//IF (XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (SA1->A1_VINCULO<>'PP' .AND. SA1->A1_VINCULO<>'CM') .AND. SA1->A1_CLIFRTE<>'1' .AND. SA1->A1_TPFRET <> 'F'

	IF (XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (!LVINCULO) .AND. SA1->A1_CLIFRTE<>'1' .AND. SA1->A1_TPFRET <> 'F'

		//ALERT('FILIAL: '+XFILIAL('SUA'))

		//IF (XFILIAL('SUA')=='05') .AND. (SA1->A1_VINCULO<>'PP' .OR. SA1->A1_VINCULO<>'CM')

		//ALERT('...VIA RODAPE...'+STR(_NFRETE)+'  '+M->UA_TPCIF)
		//ALERT('...VIA RODAPE II...'+STR(NMERC)+'  '+M->UA_TPCIF)


		////JULIO JACOVENKO, em 31/07/2014
		////tratar excecoes
		/////tratar aqui (NAO HE NECESSARIO, POR HORA)

		//IF  M->UA_FRETCAL<>0
		//aValores[_nPosPeF] := Round( M->UA_FRETCAL / _NFRETE * 100 , 2 )

		//_NVLMETA  //FRETE META
		//_NVALFRT  //FRETE TRANSPORTADORA





		//IF AVALORES[4] >= _NVALSUG    //se alterar valor quando o sugerido for zero
		nVALFRT:=_NVALFRT - AVALORES[4]
		//ENDIF

		//ALERT('AVALORES4 '+STR( AVALORES[4] ))
		//ALERT('_NVALSUG  '+STR(_NVALSUG))
		//ALERT('_NVLMETA  '+STR(_NVLMETA))
		//ALERT('_NVALFRT  '+STR(_NVALFRT))

		IF AVALORES[4]>= _NVALSUG

			IF _NVLMETA>0 .AND. AVALORES[4]>0     //se meta maior apresenta a difenca entre Frete Trans - Meta
				nValFrt:=_NVALFRT  - AVALORES[4]   //_NVLMETA
			ELSEIF _NVLMETA<=0 .AND. AVALORES[4]=0 //se meta menor apresenta somente Frete Trans
				nValFrt:=_NVALFRT
			ELSEIF _NVLMETA<=0 .AND. AVALORES[4]=0
				nValFrt:=_NVALFRT  - AVALORES[4]
			ENDIF

		ELSE //AQUI VAI DESCONTANDO

			nValFrt:=_NVALFRT  - AVALORES[4]

		ENDIF



		//ALERT('VIA RODAPE NVALFRT '+STR(NVALFRT)+' SUGERIDO ORIGINAL '+STR(_NVLMETA))

		aValores[_nPosPeF] := Round( NVALFRT / _NFRETE * 100 , 2 )
		//aValores[_nPosPeF] := Round( AVALORES[4] / _NFRETE * 100 , 2 )

		LVINCULO:=ALLTRIM(SA1->A1_VINCULO)$  ("#CM*CM*#PP*PP")
		//If (XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (SA1->A1_VINCULO<>'PP' .AND. SA1->A1_VINCULO<>'CM') .AND. SA1->A1_CLIFRTE<>'1' .AND. SA1->A1_TPFRET <> 'F'
		If (XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (!LVINCULO) .AND. SA1->A1_CLIFRTE<>'1' .AND. SA1->A1_TPFRET <> 'F'
			aValores[_nPosFrtMin] := NVALFRT //Robson - 14/11/2014 - Mostrar frete minimo na tela
		EndIf

	ELSE

		///ORIGINAL
		aValores[_nPosPeF] := Round( M->UA_FRETCAL / nMerc * 100 , 2 )

		LVINCULO:=ALLTRIM(SA1->A1_VINCULO)$  ("#CM*CM*#PP*PP")
		//If (XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (SA1->A1_VINCULO<>'PP' .AND. SA1->A1_VINCULO<>'CM') .AND. SA1->A1_CLIFRTE<>'1' .AND. SA1->A1_TPFRET <> 'F'
		If (XFILIAL('SUA') $ GETMV('MV_FILFRT') ) .AND. (!LVINCULO) .AND. SA1->A1_CLIFRTE<>'1' .AND. SA1->A1_TPFRET <> 'F'
			aValores[_nPosFrtMin] := _NVALFRT //Robson - 14/11/2014 - Mostrar frete minimo na tela
		EndIf

		//ALERT('%NF_TOTAL: '+STR(NMERC))
		//ALERT('%PER FRECCAL : '+STR(M->UA_FRETCAL / nMerc * 100 ))
		//ALERT('%FRECAL      : '+STR(M->UA_FRETCAL))
	ENDIF

ElseIf cPonto == "U_ALT_CLIENTE_SUA" 

	If !M->UA_PROSPEC
		aValores[_nPosObC] := Posicione("SA1",1,XFILIAL("SA1")+__ClienteAtual,"A1_OBSVEND")
	EndIf

	IIF(cCampo=='UA_CLIENTE', (FDadosCli('DESTROI'), FDadosCli('SHOW')), )

ElseIf cPonto == "U_TLVENT" // HISTORICO

	FDadosCli('DESTROI')
	FDadosCli('SHOW')
	
ElseIf cPonto $ "U_TMKLIMPA"
	FDadosCli('DESTROI')

EndIf

Return(.T.)
********************************************************************
Static Function FDadosCli(cOpcao)
********************************************************************
Local aArea	 :=	GetArea()
Local aMyObj := {'oGrpCli','oObjSeg','oObjVinc','oObjDtUCom','oObjLC', 'oObjSalDup','oObjRisco','oObjSP'}
Local aDadosCli := {}

If cOpcao == 'DESTROI'

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ "DESTROI"  MY_OBJETOS	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nObj := 1 To Len(aObj)
		If ValType(aObj[nObj]) == 'O'
			If Ascan(aMyObj, aObj[nObj]:cVariable) > 0
				FreeObj(aObj[nObj])
			EndIf
  		EndIf
  	Next


Else



	If AllTrim(SA1->A1_COD+SA1->A1_LOJA) != AllTrim(M->UA_CLIENTE+M->UA_LOJA)
		DbselectArea("SA1");DbSetOrder(1);DbGoTop()
		DbSeek(xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA, .F.)
	EndIf


    // ChkFile('ZZV')
    cSegmento := ''
    DbSelectarea('ZZV');DbSetOrder(1)
	If DbSeek(xFilial("ZZV")+ SA1->A1_GRPSEG, .F.)
		cSegmento := AllTrim(ZZV->ZZV_COD)
	EndIf

	cVinculo	:=	SA1->A1_VINCULO
	cDtUltComp	:=	DtoC(SA1->A1_ULTCOM)
	cLimCred	:=	AllTrim(Transform( SA1->A1_LC, '@E 999,999,999.99'))
	cSaldoHist	:=	AllTrim(Transform( SA1->A1_SALDUP, '@E 999,999,999.99'))
	cRisco		:=	SA1->A1_RISCO


	oGrpCli      	:= TGroup():New( 001,480,050,620,"Dados Financeiros",oFoldRodape:aDialogs[1],CLR_BLACK,CLR_WHITE,.T.,.F. )

	aDadosCli 		:= VerDadosCli() //| Analista: Cristiano Machado Chamado: 10895 
	
	oDCFont := TFont():New('Arial',,-10,.T.,.F.)// Fonte Dados Cliente
	oBPFont := TFont():New('Arial',,-12,.T.,.T.)// Fonte Bloqueio Pedido
	
	oObjLC  		:= TSay():New( 010, 485,{|| "Limite Crédito:        R$ "	+	Transform(  aDadosCli[_LC]   , '@E 999,999,999.99') },oGrpCli,,oDCFont,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE, 160,008 )
	oObjSalDup  	:= TSay():New( 020, 485,{|| "Sld Duplicatas:        R$ "	+	Transform( aDadosCli[_SALDUP], '@E 999,999,999.99') },oGrpCli,,oDCFont,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE, 160,008 )
	oObjRisco  		:= TSay():New( 030, 485,{|| "Risco: "				+	aDadosCli[_RISCO]   },oGrpCli,,oDCFont,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE, 160,008 )
	oObjDtUCom		:= TSay():New( 030, 516,{|| "Ult.Compra: "			+	aDadosCli[_ULTCOM]  },oGrpCli,,oDCFont,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE, 160,008 )
	// Status Pedido
	lPedido :=  if( M->UA_OPER == "1" , .T., .F. )
	If lPedido
		oObjSP  		 := TSay():New( 040, 485,{|| VerBloqPed(M->UA_NUMSC5,aDadosCli) },oGrpCli,,oBPFont,.F.,.F.,.F.,.T.,CLR_RED,CLR_WHITE, 160,008 )      
		oObjSP:cVariable :=	'oObjSP'
	EndIf

	oGrpCli:cVariable		:=	'oGrpCli'
	oObjLC:cVariable		:=	'oObjLC'
	oObjSalDup:cVariable	:=	'oObjSalDup'
	oObjRisco:cVariable		:=	'oObjRisco'
	oObjDtUCom:cVariable	:=	'oObjDtUCom'

	/*
	oObjSeg  		:= TSay():New( 012, 485,{|| "Segmento: "+AllTrim(ZZV->ZZV_COD) },oGrpCli,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE, 080,008 )
	oObjVinc	  	:= TSay():New( 023, 485,{|| "Vinculo:  "+SA1->A1_VINCULO  },oGrpCli,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE, 080,008 )
	oObjDtUCom		:= TSay():New( 034, 485,{|| "Ult.Compra: "+DtoC(SA1->A1_ULTCOM)  },oGrpCli,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE, 080,008 )

	oObjLC  		:= TSay():New( 012, 545,{|| "Limite Crédito R$  "+AllTrim(Transform( SA1->A1_LC, '@E 999,999,999.99'))   },oGrpCli,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE, 080,008 )
	oObjSalDup  	:= TSay():New( 023, 545,{|| "Saldo Histórico R$ "+	AllTrim(Transform( SA1->A1_SALDUP, '@E 999,999,999.99')) },oGrpCli,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE, 080,008 )
	oObjRisco  		:= TSay():New( 034, 545,{|| "Risco: "+SA1->A1_RISCO },oGrpCli,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE, 080,008 )
    */

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ "CRIA"  MY_OBJETOS		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nObj := 1 To Len(aMyObj)
		If Type(aMyObj[nObj]) == 'O'
			Aadd(aObj, &(aMyObj[nObj]))
		EndIf
	Next

EndIf


oFoldRodape:Refresh()
RestArea(aArea)
Return()

*******************************************************************************
Static Function VerDadosCli() // Obtem os Dados Financeiros do Cliente
*******************************************************************************

Local lLjOCd := "C" // Se os dados sao agregados por Codigo ou Loja... ? [L->Loja, C->Codigo ]

Local aDadosCli := { 0, 0, "", "", "" }

Local cSql := " SELECT A1_COD, Sum(A1_LC) A1_LC, Sum(A1_SALDUP) A1_SALDUP, Max(A1_RISCO) A1_RISCO, Max(A1_ULTCOM) A1_ULTCOM , Min(A1_VENCLC) A1_VENCLC"
      cSql += " FROM SA1010 WHERE D_E_L_E_T_ = ' ' AND  A1_COD = '"+SA1->A1_COD+" ' GROUP BY A1_COD "

      If lLjOCd == "C" //|  Informacoes por Codigo 
      	U_ExecMySql(cSql, "CLI", "Q", .F., .F. )
      	
      	DbSelectArea("CLI");DbGotop()
      	
      	aDadosCli[_LC] 	 := CLI->A1_LC
      	aDadosCli[_SALDUP] := CLI->A1_SALDUP
      	aDadosCli[_RISCO]  := CLI->A1_RISCO
      	aDadosCli[_ULTCOM] := DToC( SToD(CLI->A1_ULTCOM) )
      	aDadosCli[_VENCLC] := DToC( SToD(CLI->A1_VENCLC) )
      	
      	DbCloseArea()
      	
      ElseIf lLjOCd == "L" //|  Informacoes por loja 
      
      	aDadosCli[_LC] 	   := SA1->A1_LC
      	aDadosCli[_SALDUP] := SA1->A1_SALDUP
      	aDadosCli[_RISCO]  := SA1->A1_RISCO
      	aDadosCli[_ULTCOM] := DToC( SA1->A1_ULTCOM )
        aDadosCli[_VENCLC] := DToC( SA1->A1_VENCLC )
        
      EndIf
      
Return( aDadosCli )
*******************************************************************************
Static Function VerBloqPed(cPedido,aDadosCli)// Em caso de Pedido Verifica o Motivo do Bloqueio no Crédito
*******************************************************************************
Local cReturn 	:= " "
local cSql 		:= " " 

Static BLQ01 	:= "01" //| Totvs -> Bloqueio Valor do Limite de Crédito
Static BLQ04 	:= "04" //| Totvs -> Bloqueio Limite de Crédito Vencido
Static BLQ09 	:= "09" //| Totvs -> Rejeição Manual de Crédito

Static BLQ97 	:= "97" //| Custom-> Bloqueio Valor Mínimo
Static BLQ98 	:= "98" //| Custom-> Bloqueio Parametro
Static BLQ99 	:= "99" //| Custom-> Bloqueio Vendor




// Consulta Pedido para Identificar Bloqueio
cSql += "SELECT MAX(C9_BLCRED) BLOQ FROM SC9010 "
cSql += "WHERE C9_FILIAL = '"+xFilial("SC9")+"' "
cSql += "AND   C9_PEDIDO = '"+cPedido+"' "
cSql += "AND   C9_BLCRED NOT IN ('  ','10') "
cSql += "AND   D_E_L_E_T_ = ' ' "

U_ExecMySql( cSql , 'BLQ' , "Q", .F., .F. )

DbSelectArea("BLQ")
If !EOF("BLQ")

	If BLQ01 == BLQ->BLOQ
		cReturn := "Pedido bloqueado por Limite ou Atraso "
	ElseIf BLQ04 == BLQ->BLOQ
		cReturn := "Pedido bloqueado por Dt Lim. Vencido "+aDadosCli[_VENCLC]+""
	ElseIf BLQ09 == BLQ->BLOQ
		cReturn := "Pedido bloqueado manualmente pelo Crédito"
	ElseIf BLQ97 == BLQ->BLOQ
		cReturn := "Pedido bloqueado por parâmetro Imdepa"
	ElseIf BLQ98 == BLQ->BLOQ
		cReturn := "Pedido bloqueado por Valor Mínimo"
	ElseIf BLQ99 == BLQ->BLOQ
		cReturn := "Pedido bloqueado por Cond.Pag. Vendor"
	Else 
		cReturn := "Pedido Bloqueio no Crédito!"
	EndIF
EndIf

Return(cReturn)
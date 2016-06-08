#Include 'Totvs.ch'
#Include 'FiveWin.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIMDF190   บAutor  ณJeferson            บ Data ณ  16/01/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para pesquisa de um item de produto atraves da teclaบฑฑ
ฑฑบ          ณ F11                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ C๓digo do Produto                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Pode ser usada em qualque SXB                              บฑฑ
ฑฑบmarcio		Criado variavel UB_EQSIORI para armazenar produto           บฑฑ
ฑฑบ			Equivalente original                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

*******************************************************************************
User Function IMDF190B(nItAnt,aArrayAnt,cOpcao,crepasProd)
*******************************************************************************

	IF  !lRodaF11
		Return
	ENDIF

	Private lMostra	:= .F.
	Private cBCodProd

	If crepasProd <> Nil .and. !Empty(crepasProd)
		lvisual := .F.
		cBCodProd := ALLTRIM(crepasProd)
	Else
		lvisual := .T.
	//cBCodProd := ALLTRIM(SubStr(aArrayAnt[nItAnt],70,15))
		cBCodProd := ALLTRIM(SubStr(aArrayAnt[nItAnt],70,14))
	Endif

	Private nOpcao
	Private cCod:=Space(15)
	Private cDesProd := Posicione("SB1",1,xFilial("SB1")+cBCodProd,"B1_DESC")
	Private nAcreCond := {}
	Private lachouEST := .f.

	If cOpcao == "Equivalente"
		nOpcao := 1
		cCod := Equivalentes(cBCodProd)

	ElseIf cOpcao == "Similar"
		nOpcao := 2
		cCod := Similares(cBCodProd)
	Endif

	IF lvisual
		Set key VK_F11 to
	Endif

	Private aFiliais:={}
	Private cTextoAux:=''

	Private oDlg01
	Private cTitle:= OemToAnsi(IIF(nOpcao==1,"Consulta Avan็ada de Produtos - Equivalente","Consulta Avan็ada de Produtos - Similar"))
	Private oListPro2
	Private aListPro2:={}
	Private nItemPro:=1
	Private oMens
	Private cMens := ""
	Private cRef:=Space(20)
	Private cMar:=Space(20)

	Private cDes:=Space(40)
	Private cGrp:=Space(06)
	Private cGr1:=Space(06)
	Private cGr2:=Space(06)
	Private cGr3:=Space(06)

	Private cSeg:=Space(30)
	Private cFab:=Space(20)
	Private cVei:=Space(40)
	Private cMod:=Space(30)
	Private cGpa:=Space(40)
	Private cNov:=Space(20)

	Private nI15:=0
	Private nI16:=0
	Private nI17:=0
	Private nI18:=0
	Private nI19:=0
	Private nI20:=0
	Private nI21:=0
	Private nI22:=0
	Private nI23:=0
	Private nI24:=0
	Private nI25:=0
	Private nI26:=0
	Private nI27:=0
	Private nI28:=0
	Private nI29:=0
	Private nI30:=0
	Private nI31:=0
	Private cI32:=Space(10)
	Private cI33:=Space(10)
	Private cI34:=Space(10)
	Private cI35:=Space(10)
	Private nI36:=0
	Private nI37:=0
	Private nI38:=0
	Private nI39:=0
	Private nI40:=0
	Private nI41:=0
	Private nI42:=0
	Private nI43:=0
	Private nI44:=0
	Private nI45:=0
	Private nI46:=0
	Private nI47:=0
	Private nI48:=0
	Private nI49:=0
	Private nI50:=0
	Private cI51:=Space(10)
	Private cI52:=Space(10)
	Private cI53:=Space(10)
	Private nI54:=0
	Private nI55:=0
	Private nI56:=0

	nAcreCond := 1 + (Posicione("SE4",1,xFilial("SE4")+M->UA_CONDPG,"E4_ACRSFIN") / 100)

// Buscar todas as filiais da empresa em questao
	DbSelectArea("SM0")
	nRecSM0:=Recno()
	cCodEmp:=SM0->M0_CODIGO
	DbGoTop()
	While !Eof()
		If M0_CODFIL $ GETMV("MV_FILSEST") // Matriz somente para impressao de documentos oficiais....
			DbSkip()
			Loop
		Endif
		If cCodEmp = M0_CODIGO
			Aadd(aFiliais,M0_CODFIL)
			cTextoAux+=Alltrim(Tabela("Z3",M0_CODFIL,.F.))
		Endif
		DbSkip()
	End

	cTextoAux+='PLA' // Fixo o nome da planilha

	DbSelectArea("SM0")
	DbGoto(nRecSM0)


	IF lvisual
		DEFINE MSDIALOG oDlg01 TITLE cTitle FROM 001,001 TO 390,985 PIXEL OF oMainWnd
		oFolder := TFolder():New(1,1,{"Dados Cadastrais B"},{"oFl1"},oDlg01,,,,.T.,.F.,490,045)

	/*
	Dados para a pasta "Dados Cadastrais"
	*/

		@ 010,010 Say OemToAnsi("Codigo") 		    Size 030,008 of oFolder:aDialogs[1] PIXEL
		@ 010,220 Say OemToAnsi("Descricao") 		Size 030,008 of oFolder:aDialogs[1] PIXEL


		@ 010,043 MsGet cBCodProd Picture '@!'      	Size 040,010 of oFolder:aDialogs[1] PIXEL WHEN .F.
		@ 010,273 MsGet cDesProd Picture '@!'		Size 170,010 of oFolder:aDialogs[1] PIXEL WHEN .F.

	/*
	Dados para a pasta "Aplica็ใo"
	*/

		DEFINE FONT oFont NAME "Courier New" SIZE 0,-11

		@ 055,004  SAY Space(85)+;
			Substr(cTextoAux,01,1)+' '+;
			Substr(cTextoAux,04,1)+' '+;
			Substr(cTextoAux,07,1)+' '+;
			Substr(cTextoAux,10,1)+' '+;
			Substr(cTextoAux,13,1)+' '+;
			Substr(cTextoAux,16,1)+' '+;
			Substr(cTextoAux,19,1)+' '+;
			Substr(cTextoAux,22,1)+' '+;
			Substr(cTextoAux,25,1)+' '+;
			Substr(cTextoAux,28,1) PIXEL FONT oFONT
		@ 060,004  SAY Space(85)+;
			Substr(cTextoAux,02,1)+' '+;
			Substr(cTextoAux,05,1)+' '+;
			Substr(cTextoAux,08,1)+' '+;
			Substr(cTextoAux,11,1)+' '+;
			Substr(cTextoAux,14,1)+' '+;
			Substr(cTextoAux,17,1)+' '+;
			Substr(cTextoAux,20,1)+' '+;
			Substr(cTextoAux,23,1)+' '+;
			Substr(cTextoAux,26,1)+' '+;
			Substr(cTextoAux,29,1) PIXEL FONT oFONT

		@ 065,004  SAY PadR("QTD",09)+"  "+PadR("REFERENCIA",20)+"  "+PadR("MARCA",20)+"  "+PadR("R$ PRECO",12)+"  "+PadR("CODIGO",15)+' '+;
			Substr(cTextoAux,03,1)+' '+;
			Substr(cTextoAux,06,1)+' '+;
			Substr(cTextoAux,09,1)+' '+;
			Substr(cTextoAux,12,1)+' '+;
			Substr(cTextoAux,15,1)+' '+;
			Substr(cTextoAux,18,1)+' '+;
			Substr(cTextoAux,21,1)+' '+;
			Substr(cTextoAux,24,1)+' '+;
			Substr(cTextoAux,27,1)+' '+;
			Substr(cTextoAux,30,1) PIXEL FONT oFONT

		@ 075,004  LISTBOX oListPro2 VAR nItemPro SIZE 450,075 PIXEL ITEMS aListPro2 FONT oFONT ON DBLCLICK(u_F190Qtd1(@oListPro2,oListPro2:nAt,@aListPro2,cBCodProd))

		@ 075,455 Button OemToAnsi("Avancado ")		Size 036,015 of oDlg01 PIXEL Action (IniTela(), oDlg01:End())
		@ 090,455 Button OemToAnsi("Voltar")		Size 036,015 of oDlg01 PIXEL Action (oDlg01:End()) //(fSeleciona1(), oDlg01:End())

		If !Empty(cBCodProd)
			fLocaliza1()
			oListPro2:SetFocus()
			oListPro2:nAt := 1
		Endif

		ACTIVATE MSDIALOG oDlg01 CENTERED

		SetKey( VK_F12, { || Nil } )
		SetKey( VK_F11, {|| U_Pergunta() } )

		Return(.T.)
	Else
		Return(fLocaliza1())
	Endif

Return()
*******************************************************************************
Static Function fLocaliza1()// Localiza  atraves de Query o produto pelos dados selecionados
*******************************************************************************
	Local cQueryB
	Local lEstoque := .f.
	Local cVarTeste:=''
	Local FilComEst02 	:= GetMv("IM_OPERE02") // Estoque operando com Estoque 02

	cVarTeste:=cRef+cMar+cCod+cDes+cGrp+cGr1+cGr2+cGr3+cSeg+cFab+cVei+cMod+cGpa+cNov
	ncountb 	:= 0

	If 	Empty(Alltrim(cVarTeste)) .and. lvisual

		cMens := ''
		oListPro2:SetArray(aListPro2)
		oListPro2:Refresh()
		oListPro2:SetFocus()
		oListPro2:nAt := 1
		Return

	Endif

	cRef:=Alltrim(cRef)+Space(01)
	cMar:=Alltrim(cMar)
	cCod:=Alltrim(cCod)
	cDes:=Alltrim(cDes)
	cGrp:=Alltrim(cGrp)
	cGr1:=Alltrim(cGr1)
	cGr2:=Alltrim(cGr2)
	cGr3:=Alltrim(cGr3)

	cSeg:=Alltrim(cSeg)
	cFab:=Alltrim(cFab)
	cVei:=Alltrim(cVei)
	cMod:=Alltrim(cMod)
	cGpa:=Alltrim(cGpa)
	cNov:=Alltrim(CNov)

	If !Empty(Alltrim(cRef)) .Or. Len(Alltrim(cRef)) > 2
		cRef:=StrTran(cRef,'%','')  // Retira o caracter '%' caso o usuario tenha digitado
		cRef:=StrTran(cRef,' ','%') // Retira o caracter '%' caso o usuario tenha digitado
		cRef:=StrTran(cRef,'.','%') // Retira o caracter '%' caso o usuario tenha digitado
		nAux:=At('%',cRef)
		cRef:=Left(cRef,nAux)
	Else
		cRef:=''
	Endif
/* Query Antiga
	cQueryB := "SELECT DISTINCT SB1.B1_COD,SB1.B1_DESC,SB1.B1_REFER,SB1.B1_MARCA,SB1.B1_TIPO,SB1.B1_UM,SB1.B1_GRUPO,SB1.B1_PRV1,SB1.B1_EQUIVAL,SB1.B1_SIMILAR,MAX(NVL(SB2.B2_QATU,0)) QTDEST "
	cQueryB += "FROM "+RetSQLName("SB1")+" SB1, "
	cQueryB +=         RetSQLName("SZF")+" SZF, "+RetSQLName("SZG")+" SZG, "
	cQueryB +=         RetSQLName("SB2")+" SB2 "
	cQueryB += "WHERE "
// Uniao Produtos com estoque
	cQueryB += "SB1.B1_FILIAL = '"+xFilial('SB1')+ "' AND "
	cQueryB += "SB2.B2_FILIAL(+) = '" +xFilial('SB2')+ "' AND "
	cQueryB += "SB1.B1_COD=SB2.B2_COD(+) AND "
	cQueryB += "SB2.B2_LOCAL(+)='01' AND "
// Uniao Produtos com Produtos x Aplicacao
	cQueryB += "SB1.B1_FILIAL=SZG.ZG_FILIAL(+) AND "
	cQueryB += "SB1.B1_COD=SZG.ZG_CODPRO(+) AND "
// Uniao Produtos x Aplicacao com Aplicacao
	cQueryB += "SZG.ZG_FILIAL=SZF.ZF_FILIAL(+) AND "
	cQueryB += "SZG.ZG_CODAPL=SZF.ZF_COD(+) AND "
//Elimina produtos bloqueados //marcio
	cQueryB += "SB1.B1_MSBLQL <> '1'  AND "
// Dados da Pasta Dados Cadastrias
	If !Empty(cCod)
		cQueryB += "SB1.B1_COD IN (" + cCod+ ") AND "
	Endif
	cQueryB += "SB1.D_E_L_E_T_ = ' ' AND "
	cQueryB += "SB2.D_E_L_E_T_(+) = ' ' AND "
	cQueryB += "SZF.D_E_L_E_T_(+) = ' ' AND "
	cQueryB += "SZG.D_E_L_E_T_(+) = ' ' "
	cQueryB += "GROUP BY SB1.B1_COD,SB1.B1_DESC,SB1.B1_REFER,SB1.B1_MARCA,SB1.B1_TIPO,SB1.B1_UM,SB1.B1_GRUPO,SB1.B1_PRV1,SB1.B1_EQUIVAL,SB1.B1_SIMILAR "
	cQueryB += "ORDER BY QTDEST DESC ,SB1.B1_REFER,SB1.B1_MARCA "
*/
	///MEMOWRIT("C:\SQLSIGA\IMDF190B.TXT", cQueryB)
	//cQueryB := ChangeQuery(cQueryB)
	//dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQueryB),"cQueryB",.F.,.T.)

	cQueryB := ""
	cQueryB += "SELECT "
	cQueryB += "   SB1.B1_COD, SB1.B1_DESC, SB1.B1_REFER, SB1.B1_MARCA, SB1.B1_TIPO, SB1.B1_UM, SB1.B1_GRUPO, SB1.B1_PRV1, SB1.B1_EQUIVAL, SB1.B1_SIMILAR, MAX( NVL( SB2.B2_QATU, 0 ) ) QTDEST "
	cQueryB += "FROM "
	cQueryB += "   SB1010 SB1 "
	cQueryB += "FULL JOIN "
	cQueryB += "   ( SELECT B2_FILIAL, B2_COD, SUM( B2_QATU ) B2_QATU "
	cQueryB += "		FROM SB2010  "
	cQueryB += "		WHERE B2_FILIAL = '"+xFilial('SB1')+ "' "

	If !Empty(cCod)
		cQueryB += "   AND B2_COD IN (" + cCod+ ")   "
	Endif

	If cFilAnt $ FilComEst02
		cQueryB += "		AND B2_LOCAL IN( '01', '02' ) "
	Else
		cQueryB += "		AND B2_LOCAL = '01' "
	EndIf

	cQueryB += "		AND D_E_L_E_T_ = ' ' GROUP BY B2_FILIAL, B2_COD "
	cQueryB += "   ) SB2             ON SB2.B2_FILIAL = SB1.B1_FILIAL AND SB2.B2_COD = SB1.B1_COD "
	cQueryB += "FULL JOIN SZG010 SZG ON SZG.ZG_FILIAL = SB1.B1_FILIAL AND SZG.ZG_CODPRO = SB1.B1_COD "
	cQueryB += "FULL JOIN SZF010 SZF ON SZG.ZG_FILIAL = SZF.ZF_FILIAL AND SZG.ZG_CODAPL = SZF.ZF_COD "
	cQueryB += "WHERE "
	cQueryB += "   SB1.B1_FILIAL = '"+xFilial('SB1')+"' "
	cQueryB += "   AND SB1.B1_MSBLQL IN( '2', ' ' ) "

	If !Empty(cCod)
		cQueryB += "   AND SB1.B1_COD 	IN (" + cCod+ ")  "
	Endif

	cQueryB += "   AND SB1.D_E_L_E_T_ = ' ' "
	cQueryB += "   AND "
	cQueryB += "   ( "
	cQueryB += "      SZG.D_E_L_E_T_ = ' ' "
	cQueryB += "      OR SZG.D_E_L_E_T_ IS NULL "
	cQueryB += "   ) "
	cQueryB += "   AND "
	cQueryB += "   ( "
	cQueryB += "      SZF.D_E_L_E_T_ = ' ' "
	cQueryB += "      OR SZF.D_E_L_E_T_ IS NULL "
	cQueryB += "   ) "
	cQueryB += "GROUP BY "
	cQueryB += "   SB1.B1_COD, SB1.B1_DESC, SB1.B1_REFER, SB1.B1_MARCA, SB1.B1_TIPO, SB1.B1_UM, SB1.B1_GRUPO, SB1.B1_PRV1, SB1.B1_EQUIVAL, SB1.B1_SIMILAR "
	cQueryB += "ORDER BY "
	cQueryB += "   QTDEST DESC, SB1.B1_REFER, SB1.B1_MARCA "


	U_ExecMySql(cQueryB,"cQueryB","Q", lMostra)
// ReInicializa as variaveis em razao do Alltrim aplicado anteriormente

	cRef:=Space(20)
	cMar:=Space(20)
	cDes:=Space(40)
	cGrp:=Space(06)
	cGr1:=Space(06)
	cGr2:=Space(06)
	cGr3:=Space(06)

	cSeg:=Space(30)
	cFab:=Space(20)
	cVei:=Space(40)
	cMod:=Space(30)
	cGpa:=Space(40)
	cNov:=Space(20)

	nI15:=0
	nI16:=0
	nI17:=0
	nI18:=0
	nI19:=0
	nI20:=0
	nI21:=0
	nI22:=0
	nI23:=0
	nI24:=0
	nI25:=0
	nI26:=0
	nI27:=0
	nI28:=0
	nI29:=0
	nI30:=0
	nI31:=0
	cI32:=Space(10)
	cI33:=Space(10)
	cI34:=Space(10)
	cI35:=Space(10)
	nI36:=0
	nI37:=0
	nI38:=0
	nI39:=0
	nI40:=0
	nI41:=0
	nI42:=0
	nI43:=0
	nI44:=0
	nI45:=0
	nI46:=0
	nI47:=0
	nI48:=0
	nI49:=0
	nI50:=0
	cI51:=Space(10)
	cI52:=Space(10)
	cI53:=Space(10)
	nI54:=0
	nI55:=0
	nI56:=0


	DbSelectArea('cQueryB')
	DbGoTop()
	aListPro2 :={}
	nPrecoPro:=0
	nValoriza := 0
	While !Eof()
		lEstoque := .F.
		nValoriza:=  0
	// Tratamento para identificar as filiais que possuem estoque
		cEstoqueAux:='|'
		DbSelectArea('SB2')
		DbSetOrder(1)
		For w:=1 To Len(aFiliais)
			DbSeek(aFiliais[w]+cQueryB->B1_COD+'01') // Estou fixando o local 01 na consulta por definicao IMDEPA
			If Found() .And. (SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QACLASS-SB2->B2_QPEDVEN) > 0
				cEstoqueAux+='X'+'|'
				lEstoque := .T.
				nValoriza:= nValoriza +2
			Else
				cEstoqueAux+=' '+'|'
			Endif
		Next

		cQueryB := " SELECT SUM(NVL(ZE_QTDTRAN - ZE_QTDRES,0)) QTDPLA "
		cQueryB += " FROM "+RetSQLName("SZE")+" SZE "
		cQueryB += " WHERE     ZE_FILIAL = '"+xFilial('SZE')+"'"
		cQueryB += "       AND ZE_PRODUTO = '" +cQueryB->B1_COD+ "'"
		cQueryB += "       AND ZE_DESTINO = '"+cFilAnt+"' "
		cQueryB += "       AND ( ZE_CODCLI = '      ' or ( ZE_CODCLI = '"+M->UA_CLIENTE+"' and ZE_LOJA = '"+M->UA_LOJA+"' ) )"
		cQueryB += "       AND ZE_FLAGNF <> 'S' "
		cQueryB += "       AND D_E_L_E_T_ = ' ' "

		//dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQueryB),"cQueryBPla",.F.,.T.)

		U_ExecMySql(cQueryB,"cQueryBPla","Q", lMostra)

		If cQueryBPla->qtdpla > 0
			cTemPlan	:= 'X|'
			lEstoque 	:= .T.
			nValoriza 	:= nValoriza + 2
		Else
			cTemPlan:=' |'
		Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤPฟ
	//ณUsado para Desovar Produtos.                                        ณ
	//ณOrdena determinados produtos para aparecerem primeiro na tela do F11ณ
	//ณconforme solicita็ใo da Diretoria								   ณ
	//ณ--------------------------------------------------------------------ณ
		IF ALLTRIM(cQueryB->B1_COD) $ GETMV("MV_DESOVA",," ")
			nValoriza := nValoriza + 1000
		ENDIF
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤPู

		DbSelectArea('cQueryBPla')
		DbCloseArea()

		DbSelectArea('cQueryB')

		dbSelectarea("DA1")
		dbSetOrder(1)
		DbSeek(xFilial("DA1")+M->UA_TABELA+cQueryB->B1_COD)
		If !Found() .Or. DA1_PRCVEN = 0
			nPrecoPro:=0
		Else
		//TamSx3("UB_PRCVEN")[2]
			nPrecoPro:=xMoeda(DA1_PRCVEN,DA1_MOEDA,M->UA_MOEDA,,)
		Endif

	// atualiza campo no ListBox
		nPrecoPro:=A410Arred(nPrecoPro*nAcreCond,"UB_VRUNIT")

		DbSelectArea('cQueryB')

		lachouEST := .T.
		AADD(aListPro2,{Space(09) + " |" + PADR(cQueryB->B1_REFER,20)+" |" + PADR( cQueryB->B1_MARCA, 20 ) + " |" + Str(nPrecoPro,12,4) + " |" + cQueryB->B1_COD  + cEstoqueAux + cTemPlan,nValoriza} )

		ncountb++

		cQueryB->(DbSkip())
	Enddo

//ordena o arrai AlistPRO por ordem de nValoriza
	aSort(aListPRO2,,,{|a,b| a[2] > b[2] })
	aListClone	:= {}
	aListClone 	:= aClone(aListPRO2)
	aListPRO2 	:= {}
	for i:=1 to LEN(aListClone)
		AADD(aListPRO2,aListClone[i][1])
	Next i
	If ncountb > 0
		cMens := alltrim(str(ncountb)) +" Registros nใo mostrados por nใo possuirem estoque, nem produto Equivalente nem Similar"
	Else
		cMens := ""
	Endif

	If lvisual
		oListPro2:SetArray(aListPro2)
		oListPro2:Refresh()
		oListPro2:SetFocus()
		oListPro2:nAt := 1

		IF LEN(aListPro2) <> 0
			SetKey( VK_F12, {|| u_F190Qtd1(@oListPro2,oListPro2:nAt,@aListPro2,cBCodProd) } )
		ENDIF

	Endif

	DbSelectArea("cQueryB")
	DbCloseArea()


Return(lachouEST)
*******************************************************************************
Static Function fSeleciona1()// Seleciona e retorna o codigo do produto
*******************************************************************************

	Local nLENaHeader := Len(aHeader), nAnt := n, nPos

	fArmazena1()

	If Len(aArmazena) = 0
		IW_MsgBox('Nenhum item selecionado')
		Return
	Endif

	For w:=1 To Len(aArmazena)

		M->UB_PRODUTO:=aArmazena[w,1]
		M->UB_QUANT  :=aArmazena[w,2]
		M->UB_VRCACRE:=aArmazena[w,3]

		M->UB_EQSIORI:=aArmazena[w,4]
		If w=1
			aCols[n,GDFieldPos('UB_PRODUTO')] := aArmazena[w,1]
			aCols[n,GDFieldPos('UB_QUANT')]   := aArmazena[w,2]
			aCols[n,GDFieldPos('UB_VRCACRE')] := aArmazena[w,3]

			aCols[n,GDFieldPos('UB_EQSIORI')] := aArmazena[w,4]
		Else
			AAdd(aCols, Array(nLENaHeader+1))
			n := Len(aCols)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤeira,Xฟ
		//ณCarrega os campos conforme inicializador padrใo e conform dados obtidos      ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤeira,Xู

			For nW := 1 To nLENaHeader
				aCols[n,nW] := CriaVar(aHeader[nW,2],.T.)
			Next nW
			aCols[n,nLENaHeader+1] := .F.
			aCols[n,GDFieldPos('UB_PRODUTO')] := aArmazena[w,1]
			aCols[n,GDFieldPos('UB_QUANT')]   := aArmazena[w,2]
			aCols[n,GDFieldPos('UB_VRCACRE')] := aArmazena[w,3]

			aCols[n,GDFieldPos('UB_EQSIORI')] := aArmazena[w,4]
		Endif
	// A linha abaixo eh o conteudo do X3_VALID do campo UB_PRODUTO, com uma mudanca na chamada da funcao TK271P01


	// MARLLON - 01/08/2005
	// FOI ALTERADA NA VERSAO 8.11 PARA O QUE ESTAH ABAIXO
		TK273Calcula("UB_PRODUTO") .AND. MAFISREF("IT_PRODUTO","TK273",M->UB_PRODUTO) .AND. U_VALIDTP(M->UA_TABELA,"UB_PRODUTO",M->UB_PRODUTO)
	// MARLLON - 01/08/2005 - FIM


		nPos := Ascan( aPrecosCamp, { |x| x[1] == M->UB_PRODUTO } )
		If nPos > 0
			aCols[n,GDFieldPos('UB_VRCCAMP')] := aPrecosCamp[nPos,2]
		Endif
		RunTrigger(2,Len(aCols))
	Next
	n := nAnt
	M->UB_PRODUTO:=aArmazena[1,1]
	M->UB_QUANT  :=aArmazena[1,2]
	M->UB_VRCACRE:=aArmazena[1,3]

	M->UB_EQSIORI:=aArmazena[1,4]


// MARLLON - 01/08/2005
// FOI ALTERADA NA VERSAO 8.11 PARA O QUE ESTAH ABAIXO
// A linha abaixo eh o conteudo do X3_VALID do campo UB_PRODUTO, com uma mudanca na chamada da funcao TK271P01
	TK273Calcula("UB_PRODUTO") .AND. MAFISREF("IT_PRODUTO","TK273",M->UB_PRODUTO) .AND. U_VALIDTP(M->UA_TABELA,"UB_PRODUTO",M->UB_PRODUTO)
// MARLLON - 01/08/2005 - FIM


	nPos := Ascan( aPrecosCamp, { |x| x[1] == M->UB_PRODUTO } )
	If nPos > 0
		aCols[n,GDFieldPos('UB_VRCCAMP')] := aPrecosCamp[nPos,2]
	Endif
	RunTrigger(2,n)
	oGetTlv:Refresh()

Return
*******************************************************************************
Static Function IniTela()// Funcao Auxiliar para preencher para poder habilitar os restantes das folders.....
*******************************************************************************

	Local oDlgAv

	DEFINE MSDIALOG oDlgAv TITLE cTitle FROM 001,001 TO 390,985 PIXEL OF oMainWnd

	oFolder := TFolder():New(1,1,{"Dados Cadastrais","Aplica็ใo","Dimensionamento1","Dimensionamento2","Dimensionamento3","Dimensionamento4","Dimensionamento5","Dimensionamento6","Figuras Ex."},{"oFl1","oFl2","oFl3","oFl4","oFl5","oFl6","oFl7","oFl8","oFl9"},oDlgAv,,,,.T.,.F.,490,095)

/*
Dados para a pasta "Dados Cadastrais"
*/

	@ 010,010 Say OemToAnsi("Referencia") 		Size 030,008 of oFolder:aDialogs[1] PIXEL
	@ 025,010 Say OemToAnsi("Marca")		    Size 030,008 of oFolder:aDialogs[1] PIXEL
	@ 040,010 Say OemToAnsi("Codigo") 		    Size 030,008 of oFolder:aDialogs[1] PIXEL
	@ 055,010 Say OemToAnsi("Descricao") 		Size 030,008 of oFolder:aDialogs[1] PIXEL

	@ 010,220 Say OemToAnsi("Grupo Produtos")  	Size 030,008 of oFolder:aDialogs[1] PIXEL
	@ 025,220 Say OemToAnsi("SubGrupo 1")     	Size 030,008 of oFolder:aDialogs[1] PIXEL
	@ 040,220 Say OemToAnsi("SubGrupo 2")     	Size 030,008 of oFolder:aDialogs[1] PIXEL
	@ 055,220 Say OemToAnsi("SubGrupo 3")     	Size 030,008 of oFolder:aDialogs[1] PIXEL

	@ 010,043 MsGet cRef Picture '@!'			Size 090,010 of oFolder:aDialogs[1] PIXEL
	@ 025,043 MsGet cMar Picture '@!'			Size 090,010 of oFolder:aDialogs[1] PIXEL
	@ 040,043 MsGet cBCodProd Picture '@!'       Size 040,010 of oFolder:aDialogs[1] PIXEL WHEN .T.
	@ 055,043 MsGet cDes Picture '@!'			Size 170,010 of oFolder:aDialogs[1] PIXEL

	@ 010,273 MsGet cGrp Picture '@!' 			Size 050,010 of oFolder:aDialogs[1] PIXEL //F3 "SBM"
	@ 025,273 MsGet cGr1 Picture '@!' 			Size 050,010 of oFolder:aDialogs[1] PIXEL //F3 "SZA"
	@ 040,273 MsGet cGr2 Picture '@!' 			Size 050,010 of oFolder:aDialogs[1] PIXEL //F3 "SZB"
	@ 055,273 MsGet cGr3 Picture '@!' 			Size 050,010 of oFolder:aDialogs[1] PIXEL //F3 "SZC"

// Dados para a pasta "Aplica็ใo"

	@ 010,010 Say OemToAnsi("Segmento") 		Size 030,008 of oFolder:aDialogs[2] PIXEL
	@ 025,010 Say OemToAnsi("Fabricante")   	Size 030,008 of oFolder:aDialogs[2] PIXEL
	@ 040,010 Say OemToAnsi("Veic./Equip.")	    Size 030,008 of oFolder:aDialogs[2] PIXEL
	@ 055,010 Say OemToAnsi("Tipo/Modelo")  	Size 030,008 of oFolder:aDialogs[2] PIXEL

	@ 010,170 Say OemToAnsi("Grp Princ. Aplicacao")    	Size 040,008 of oFolder:aDialogs[2] PIXEL
	@ 025,170 Say OemToAnsi("No.Original Veic/Equip") 		Size 030,008 of oFolder:aDialogs[2] PIXEL

	@ 010,043 MsGet cSeg Picture '@!'			Size 120,010 of oFolder:aDialogs[2] PIXEL
	@ 025,043 MsGet cFab Picture '@!'       	Size 090,010 of oFolder:aDialogs[2] PIXEL
	@ 040,043 MsGet cVei Picture '@!'			Size 170,010 of oFolder:aDialogs[2] PIXEL
	@ 055,043 MsGet cMod Picture '@!'			Size 120,010 of oFolder:aDialogs[2] PIXEL

	@ 010,223 MsGet cGpa Picture '@!'			Size 120,010 of oFolder:aDialogs[2] PIXEL
	@ 025,223 MsGet cNov Picture '@!'       	Size 090,010 of oFolder:aDialogs[2] PIXEL

	@ 010,010 Say OemToAnsi("Unid. Medida (mm/Pol")	Size 030,008 of oFolder:aDialogs[3] PIXEL
	@ 025,010 Say OemToAnsi("d (mm)")			  		Size 030,008 of oFolder:aDialogs[3] PIXEL
	@ 040,010 Say OemToAnsi("D (mm)")			  		Size 030,008 of oFolder:aDialogs[3] PIXEL
	@ 055,010 Say OemToAnsi("B (mm)")			  		Size 030,008 of oFolder:aDialogs[3] PIXEL

	@ 010,170 Say OemToAnsi("T (ฐC") 	     		  	Size 030,008 of oFolder:aDialogs[3] PIXEL
	@ 025,170 Say OemToAnsi("Pressใo (Kg/Cmฒ)") 		    Size 040,008 of oFolder:aDialogs[3] PIXEL
	@ 040,170 Say OemToAnsi("Cr (Kgf/Cmฒ)") 			Size 040,008 of oFolder:aDialogs[3] PIXEL
	@ 055,170 Say OemToAnsi("C (Kgf/Cmฒ)") 				Size 040,008 of oFolder:aDialogs[3] PIXEL

	@ 010,043 MsGet nI15 Picture "9999999999" 			Size 120,010 of oFolder:aDialogs[3] PIXEL
	@ 025,043 MsGet nI16 Picture "9999999999" 			Size 120,010 of oFolder:aDialogs[3] PIXEL
	@ 040,043 MsGet nI17 Picture "9999999999" 			Size 120,010 of oFolder:aDialogs[3] PIXEL
	@ 055,043 MsGet nI18 Picture "9999999999" 			Size 120,010 of oFolder:aDialogs[3] PIXEL

	@ 010,223 MsGet nI19 Picture "9999999999" 			Size 120,010 of oFolder:aDialogs[3] PIXEL
	@ 025,223 MsGet nI20 Picture "9999999999" 			Size 120,010 of oFolder:aDialogs[3] PIXEL
	@ 040,223 MsGet nI21 Picture "9999999999" 			Size 120,010 of oFolder:aDialogs[3] PIXEL
	@ 055,223 MsGet nI22 Picture "9999999999" 			Size 120,010 of oFolder:aDialogs[3] PIXEL


//Dados para a pasta "Dimensionamento2"

	@ 010,010 Say OemToAnsi("Co(Kgf/Cmฒ)")	  			Size 030,008 of oFolder:aDialogs[4] PIXEL
	@ 025,010 Say OemToAnsi("Graxa mim-1")				Size 030,008 of oFolder:aDialogs[4] PIXEL
	@ 040,010 Say OemToAnsi("Oleo mim-1")		 		Size 030,008 of oFolder:aDialogs[4] PIXEL
	@ 055,010 Say OemToAnsi("RPM")   	     		  	Size 030,008 of oFolder:aDialogs[4] PIXEL

	@ 010,170 Say OemToAnsi("Passo (mm)")       		Size 040,008 of oFolder:aDialogs[4] PIXEL
	@ 025,170 Say OemToAnsi("Diametro do Eixo(mm)")   	Size 040,008 of oFolder:aDialogs[4] PIXEL
	@ 040,170 Say OemToAnsi("Diametro (mm)")			Size 040,008 of oFolder:aDialogs[4] PIXEL
	@ 055,170 Say OemToAnsi("Diametro do Pino (mm)")	Size 040,008 of oFolder:aDialogs[4] PIXEL

	@ 010,043 MsGet nI23 Picture "9999999999" 			Size 120,010 of oFolder:aDialogs[4] PIXEL
	@ 025,043 MsGet nI24 Picture "9999999999" 			Size 120,010 of oFolder:aDialogs[4] PIXEL
	@ 040,043 MsGet nI25 Picture "9999999999" 			Size 120,010 of oFolder:aDialogs[4] PIXEL
	@ 055,043 MsGet nI26 Picture "9999999999" 			Size 120,010 of oFolder:aDialogs[4] PIXEL

	@ 010,223 MsGet nI27 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[4] PIXEL
	@ 025,223 MsGet nI28 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[4] PIXEL
	@ 040,223 MsGet nI29 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[4] PIXEL
	@ 055,223 MsGet nI30 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[4] PIXEL

//Dados para a pasta "Dimensionamento3"

	@ 010,010 Say OemToAnsi("Diametro do Rolo (mm)")	Size 030,008 of oFolder:aDialogs[5] PIXEL
	@ 025,010 Say OemToAnsi("Rosca")					Size 030,008 of oFolder:aDialogs[5] PIXEL
	@ 040,010 Say OemToAnsi("Dispositivo Trava") 		Size 030,008 of oFolder:aDialogs[5] PIXEL
	@ 055,010 Say OemToAnsi("Porca")   	     		  	Size 030,008 of oFolder:aDialogs[5] PIXEL

	@ 010,170 Say OemToAnsi("Arruela")       			Size 040,008 of oFolder:aDialogs[5] PIXEL
	@ 025,170 Say OemToAnsi("de (mm)")   				Size 040,008 of oFolder:aDialogs[5] PIXEL
	@ 040,170 Say OemToAnsi("da (mm)")					Size 040,008 of oFolder:aDialogs[5] PIXEL
	@ 055,170 Say OemToAnsi("Perfil")					Size 040,008 of oFolder:aDialogs[5] PIXEL

	@ 010,043 MsGet nI31 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[5] PIXEL
	@ 025,043 MsGet cI32 								Size 120,010 of oFolder:aDialogs[5] PIXEL
	@ 040,043 MsGet cI33 								Size 120,010 of oFolder:aDialogs[5] PIXEL
	@ 055,043 MsGet cI34 								Size 120,010 of oFolder:aDialogs[5] PIXEL

	@ 010,223 MsGet cI35 								Size 120,010 of oFolder:aDialogs[5] PIXEL
	@ 025,223 MsGet nI36 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[5] PIXEL
	@ 040,223 MsGet nI37 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[5] PIXEL
	@ 055,223 MsGet nI38 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[5] PIXEL

//Dados para a pasta "Dimensionamento4"

	@ 010,010 Say OemToAnsi("No. Frisos")				Size 030,008 of oFolder:aDialogs[6] PIXEL
	@ 025,010 Say OemToAnsi("A1 (mm)")					Size 030,008 of oFolder:aDialogs[6] PIXEL
	@ 040,010 Say OemToAnsi("A (mm)")					Size 030,008 of oFolder:aDialogs[6] PIXEL
	@ 055,010 Say OemToAnsi("L (mm)")  	     		  	Size 030,008 of oFolder:aDialogs[6] PIXEL

	@ 010,170 Say OemToAnsi("G (mm)")        			Size 040,008 of oFolder:aDialogs[6] PIXEL
	@ 025,170 Say OemToAnsi("H1 (mm)")   				Size 040,008 of oFolder:aDialogs[6] PIXEL
	@ 040,170 Say OemToAnsi("H2 (mm)")					Size 040,008 of oFolder:aDialogs[6] PIXEL
	@ 055,170 Say OemToAnsi("H (mm)")					Size 040,008 of oFolder:aDialogs[6] PIXEL

	@ 010,043 MsGet nI39 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[6] PIXEL
	@ 025,043 MsGet nI40 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[6] PIXEL
	@ 040,043 MsGet nI41 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[6] PIXEL
	@ 055,043 MsGet nI42 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[6] PIXEL

	@ 010,223 MsGet nI43 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[6] PIXEL
	@ 025,223 MsGet nI44 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[6] PIXEL
	@ 040,223 MsGet nI45 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[6] PIXEL
	@ 055,223 MsGet nI46 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[6] PIXEL

//Dados para a pasta "Dimensionamento5"

	@ 010,010 Say OemToAnsi("J (mm)")       			Size 030,008 of oFolder:aDialogs[7] PIXEL
	@ 025,010 Say OemToAnsi("C (mm)") 					Size 030,008 of oFolder:aDialogs[7] PIXEL
	@ 040,010 Say OemToAnsi("N1 (mm)")					Size 030,008 of oFolder:aDialogs[7] PIXEL
	@ 055,010 Say OemToAnsi("Comprimento B1")		  	Size 030,008 of oFolder:aDialogs[7] PIXEL

	@ 010,170 Say OemToAnsi("Caixa")         			Size 040,008 of oFolder:aDialogs[7] PIXEL
	@ 025,170 Say OemToAnsi("Bucha Fixacao")			Size 040,008 of oFolder:aDialogs[7] PIXEL
	@ 040,170 Say OemToAnsi("Tipo Rolamento")			Size 040,008 of oFolder:aDialogs[7] PIXEL
	@ 055,170 Say OemToAnsi("N")						Size 040,008 of oFolder:aDialogs[7] PIXEL

	@ 010,043 MsGet nI47 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[7] PIXEL
	@ 025,043 MsGet nI48 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[7] PIXEL
	@ 040,043 MsGet nI49 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[7] PIXEL
	@ 055,043 MsGet nI50 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[7] PIXEL

	@ 010,223 MsGet cI51 								Size 120,010 of oFolder:aDialogs[7] PIXEL
	@ 025,223 MsGet cI52 								Size 120,010 of oFolder:aDialogs[7] PIXEL
	@ 040,223 MsGet cI53 								Size 120,010 of oFolder:aDialogs[7] PIXEL
	@ 055,223 MsGet nI54 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[7] PIXEL

//Dados para a pasta "Dimensionamento6"

	@ 010,010 Say OemToAnsi("No. Pastilha") 			Size 030,008 of oFolder:aDialogs[8] PIXEL
	@ 025,010 Say OemToAnsi("No. Lonas")				Size 030,008 of oFolder:aDialogs[8] PIXEL

	@ 010,043 MsGet nI55 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[8] PIXEL
	@ 025,043 MsGet nI56 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[8] PIXEL

	@ 003,010 BITMAP FILE "sigaadv/rolam1.jpg" Size 080,075 of oFolder:aDialogs[9] PIXEL ADJUST


	DEFINE FONT oFont NAME "Courier New" SIZE 0,-11
	@ 100,004  SAY Space(85)+;
		Substr(cTextoAux,01,1)+' '+;
		Substr(cTextoAux,04,1)+' '+;
		Substr(cTextoAux,07,1)+' '+;
		Substr(cTextoAux,10,1)+' '+;
		Substr(cTextoAux,13,1)+' '+;
		Substr(cTextoAux,16,1)+' '+;
		Substr(cTextoAux,19,1)+' '+;
		Substr(cTextoAux,22,1)+' '+;
		Substr(cTextoAux,25,1)+' '+;
		Substr(cTextoAux,28,1) PIXEL FONT oFONT
	@ 105,004  SAY Space(85)+;
		Substr(cTextoAux,02,1)+' '+;
		Substr(cTextoAux,05,1)+' '+;
		Substr(cTextoAux,08,1)+' '+;
		Substr(cTextoAux,11,1)+' '+;
		Substr(cTextoAux,14,1)+' '+;
		Substr(cTextoAux,17,1)+' '+;
		Substr(cTextoAux,20,1)+' '+;
		Substr(cTextoAux,23,1)+' '+;
		Substr(cTextoAux,26,1)+' '+;
		Substr(cTextoAux,29,1) PIXEL FONT oFONT

	@ 110,004  SAY PadR("QTD",09)+"  "+PadR("REFERENCIA",20)+"  "+PadR("MARCA",20)+"  "+PadR("R$ PRECO",12)+"  "+PadR("CODIGO",15)+' '+;
		Substr(cTextoAux,03,1)+' '+;
		Substr(cTextoAux,06,1)+' '+;
		Substr(cTextoAux,09,1)+' '+;
		Substr(cTextoAux,12,1)+' '+;
		Substr(cTextoAux,15,1)+' '+;
		Substr(cTextoAux,18,1)+' '+;
		Substr(cTextoAux,21,1)+' '+;
		Substr(cTextoAux,24,1)+' '+;
		Substr(cTextoAux,27,1)+' '+;
		Substr(cTextoAux,30,1) PIXEL FONT oFONT


	@ 120,004  LISTBOX oListPro2 VAR nItemPro SIZE 450,075 PIXEL ITEMS aListPro2 FONT oFONT ON DBLCLICK(u_F190Qtd1(@oListPro2,oListPro2:nAt,@aListPro2,cBCodProd))

	@ 120,455 Button OemToAnsi("Avancado ")		Size 036,015 of oDlgAv PIXEL Action (IniTela(), oDlgAv:End()) when .f.
	@ 135,455 Button OemToAnsi("Voltar")		Size 036,015 of oDlgAv PIXEL Action oDlgAv:End()//(fSeleciona1(),oDlgAv:End())

	ACTIVATE MSDIALOG oDlgAv CENTERED

Return(.T.)
*******************************************************************************
Static Function fArmazena1(cBCodProd)// Armazena as quantidades e itens selecionados
*******************************************************************************

	lLogica:=.F.
	For wx:=1 To Len(aListPro2)
		If !Empty(SubStr(aListPro2[wx],1,9)) .And. Val(SubStr(aListPro2[wx],1,9)) > 0 // Item com quantidade selecionada maior que zero
			lLogica:=.T.
			Aadd(aArmazena,{SubStr(aListPro2[wx],70,15),Val(SubStr(aListPro2[wx],1,9)),Val(SubStr(aListPro2[wx],56,12)),cBCodProd}) // Codigo do Produto ,Quantidade e Vlr Unitario,CodProd que originou o Equivalente/Similar
		Endif
	Next
	If !lLogica .And. Len(aArmazena) = 0
		IW_MsgBox('Nenhum item selecionado!')
		Return
	Endif
	aListPro2:={}
	oListPro2:SetArray(aListPro2)
	oListPro2:Refresh()
	oListPro2:SetFocus()
	Set Key VK_F12 To
Return


//**************************************************
Static Function Equivalentes(cproduto)

	Local cEquivalente	:= " "

	dbSelectArea("SZH")
	dbSetOrder(1)
	DBGOTOP()
	IF DBSEEK(xFilial("SZH") + cProduto)
		DO WHILE !EOF() .AND. ALLTRIM(SZH->ZH_PROD) == cProduto
			cEquivalente += "'" + ALLTRIM(SZH->ZH_EQUI)  + "',"
			DBSKIP()
		END DO
	ENDIF
	cEquivalente := Left(cEquivalente,Len(cEquivalente)-1)

Return(cEquivalente)
*******************************************************************************
Static Function Similares(cproduto)
*******************************************************************************
	Local cSimilar	:= " "

	dbSelectArea("SZI")
	dbSetOrder(1)
	DBGOTOP()
	IF DBSEEK(xFilial("SZI") + cProduto)
		DO WHILE !EOF() .AND. ALLTRIM(SZI->ZI_PROD) == cProduto
			cSimilar += "'"+ ALLTRIM(SZI->ZI_SIMILAR) + "',"
			DBSKIP()
		END DO
	ENDIF

	cSimilar := Left(cSimilar,Len(cSimilar)-1)

Return(cSimilar)
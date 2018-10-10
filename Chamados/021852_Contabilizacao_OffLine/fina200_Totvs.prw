#Include "FINA200.CH"
#Include "FILEIO.CH"
#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"

#Define mcEMP 1
#Define mcUNG 2
#Define mcFIL 3

Static lFWCodFil  	:= .T.
Static nTamNat		:= 0
Static lVerifNat 	:= .F.
Static dRefPCC	 	:= CTOD("22/06/2015")
Static __oFINA2001
Static lFA200RE2	:= ExistBlock("FA200RE2")
Static lFA200REJ	:= ExistBlock("FA200REJ")
Static lF200DB1		:= ExistBlock("F200DB1")
Static lF200DB2		:= ExistBlock("F200DB2")
Static lF200OCR		:= ExistBlock("F200OCR")
Static l060SEA		:= ExistBlock("F060SEA")
Static __lPar17 	:= .F.

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUN«√O : fina200_Totvs.prw | AUTOR : Cristiano Machado | DATA : 09/10/2018**
**---------------------------------------------------------------------------**
** DESCRI«√O:  Retorno da comunicac„o bancÜria - Receber                     **
**---------------------------------------------------------------------------**
** USO : Especifico para   **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
** ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL. **
**---------------------------------------------------------------------------**
** PROGRAMADOR | DATA | MOTIVO DA ALTERACAO **
**---------------------------------------------------------------------------**
**   |  | **
**   |  | **
\*---------------------------------------------------------------------------*/
Function FinA200(nPosArotina)
	Local lPanelFin := IsPanelFin()
	Local lPergunte := .F.
	Local aAreaCnab
	Private lF200Cus  := ExistBlock("F200CUS") //Novo ponto de Entrada
	Private cStProc := ""
	Private aTit
	Private	cTipoBx  := ""
	Private cArqCfg  := ""
	Private nVlrcnab := 0
	Private lMVCNABImp := GetNewPar("MV_CNABIMP",.F.)
	Private lMVGlosa   := GetNewPar("MV_GLOSA",.F.)

	// Retorno Automatico via Job
	// parametro que controla execucao via Job utilizado para pontos de entrada que nao tem como passar o parametro
	Private lExecJob := ExecSchedule()

	if lExecJob
		nPosArotina := 3 // recebe arquivo
	Endif

	Private cPerg	:= "AFI200"

	/*
	___________________________________
	| Perguntas:						|
	| __________________________________|
	|									|
	| 01	Mostra Lanc Contab ?		|
	| 02	Aglut Lancamentos ?			|
	| 03	Atualiza Moedas por ?		|
	| 04	Arquivo de Entrada ?		|
	| 05	Arquivo de Config ?			|
	| 06	Codigo do Banco ?			|
	| 07	Codigo da Agencia ?			|
	| 08	Codigo da Conta ?			|
	| 09	Codigo da Sub-Conta ?		|
	| 10	Abate Desc Comissao ?		|
	| 11	Contabiliza On Line ?		|
	| 12	Configuracao CNAB ?			|
	| 13	Processa Filial?			|
	| 14	Contabiliza Transferencia ?	|
	| 15	Retencao Banc.Transferencia?|
	| 16	Cons.Juros Comiss„o ?       |
	| 17	RetenÁ„o Banc∑ria Despesa?  |
	|___________________________________|
	*/

	///fffffffffffffffffffffffffffffffffffffffo
	//> Verifica se tem pergunta 17          >
	//?fffffffffffffffffffffffffffffffffffffffY

	SX1->(DbSetOrder(1))

	If SX1->(DBSEEK(PADR(cPerg, LEN(SX1->X1_GRUPO), ' ') + '17')) // RetenÁ„o Banc∑ria Despesa?
		__lPar17:= .T.
	EndIf

	///fffffffffffffffffffffffffffffffffffffffo
	//> Verifica as perguntas selecionadas    >
	//?fffffffffffffffffffffffffffffffffffffffY
	If lPanelFin .and. ! lExecJob         // Retorno Automatico via Job - parametro que controla execucao via Job
		lPergunte := PergInPanel(cPerg,.T.)
	Else
		if lExecJob    // Retorno Automatico via Job - parametro que controla execucao via Job
			Pergunte(cPerg,.F.,Nil,Nil,Nil,.F.)  // carrega as perguntas que foram atualizadas pelo FINA205
			lPergunte := .T.
		Else
			lPergunte := pergunte(cPerg,.T.)
		Endif
	Endif

	If !lPergunte
		Return
	Endif
	MV_PAR04 := UPPER(MV_PAR04)

	PRIVATE cLotefin 	:= Space(TamSX3("EE_LOTE")[1]),nTotAbat := 0,cConta := " "
	PRIVATE nHdlBco		:= 0,nHdlConf := 0,nSeq := 0 ,cMotBx := "NOR"
	PRIVATE nValEstrang := 0
	PRIVATE cMarca 		:= GetMark()
	PRIVATE aRotina 	:= MenuDef()
	PRIVATE VALOR  		:= 0
	PRIVATE nHdlPrv 	:= 0
	PRIVATE nOtrGa		:= 0
	PRIVATE nTotAGer	:= 0
	PRIVATE ABATIMENTO 	:= 0
	Private lOracle		:= "ORACLE" $ Upper(TCGetDB())

	///ffffffffffffffffffffffffffffffffffffffo
	//> Define o cabecalho da tela de baixas >
	//?ffffffffffffffffffffffffffffffffffffffY
	PRIVATE cCadastro := STR0006  //"Comunicac„o BancÜria-Retorno"

	DEFAULT nPosArotina := 0

	If nTamNat == 0
		F200VerNat()
	Endif

	If nPosArotina > 0
		dbSelectArea('SE1')
		bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nPosArotina,2 ] + "(a,b,c,d,e) }" )
		Eval( bBlock, Alias(), (Alias())->(Recno()),nPosArotina,lExecJob) // Retorno Automatico via Job - parametro que controla execucao via Job
	Else
		mBrowse( 6,1,22,75,"SE1",,,,,,Fa040Legenda("SE1"))
	Endif

	///fffffffffffffffffffffffffo
	//> Fecha os Arquivos ASCII >
	//?fffffffffffffffffffffffffY
	FCLOSE(nHdlBco)
	FCLOSE(nHdlConf)

Return

/*/
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++/ffffffffff-ffffffffff-fffffff-fffffffffffffffffffffff-ffffff-ffffffffffo++
++>FunÁ÷o    > fA200Ger > Autor > Wagner Xavier         > Data > 26/05/92 >++
++Vffffffffff=ffffffffff°fffffff°fffffffffffffffffffffff°ffffff°ffffffffffY++
++>DescriÁ÷o > Comunicacao Bancaria - Retorno                             >++
++Vffffffffff=ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
++>Sintaxe   > fA200Ger()                                                 >++
++Vffffffffff=ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
++> Uso      > FinA200                                                    >++
++?ffffffffff°ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
*/
Function fa200gera(cAlias)

	Processa({|lEnd| fa200Ger(cAlias)})  // Chamada com regua

	FDelQuery()

Return .T.

/*/
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++/ffffffffff-ffffffffff-fffffff-fffffffffffffffffffffff-ffffff-ffffffffffo++
++>FunÁ÷o    > fA200Gera> Autor > Wagner Xavier         > Data > 26/05/92 >++
++Vffffffffff=ffffffffff°fffffff°fffffffffffffffffffffff°ffffff°ffffffffffY++
++>DescriÁ÷o > Comunicacao Bancaria - Retorno                             >++
++Vffffffffff=ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
++>Sintaxe   > fA200Ger()                                                 >++
++Vffffffffff=ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
++> Uso      > FinA200                                                    >++
++?ffffffffff°ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
*/
Function fA200Ger(cAlias)
	Local lPosNum  :=.f.,lPosData:=.f.,lPosMot  :=.f.
	Local lPosDesp :=.f.,lPosDesc:=.f.,lPosAbat :=.f.
	Local lPosPrin :=.f.,lPosJuro:=.f.,lPosMult :=.f.
	Local lPosOcor :=.f.,lPosTipo:=.f.,lPosOutrD:= .F.
	Local lPosCC   :=.f.,lPosDtCC:=.f.,lPosNsNum:=.f.
	Local cArqConf,cArqEnt,xBuffer
	Local lDesconto,lContabiliza
	Local cData
	Local cPosNsNum , nLenNsNum
	Local lUmHelp 	:= .F.
	Local cTabela 	:= "17"
	Local lPadrao 	:= .f.
	Local lBaixou 	:= .F.
	Local nSavRecno	:= Recno()
	Local nPos
	Local aTabela 	:= {}
	Local lRecicl		:= SuperGetMv("MV_RECICL",.F.,.F.)
	Local lNaoExiste:= .F.
	Local cIndex	:= " "
	LOCAL lFina200 	:= ExistBlock("FINA200" )
	LOCAL l200Pos  	:= ExistBlock("FA200POS" )
	LOCAL lT200Pos 	:= ExistTemplate("FA200POS" )
	LOCAL lFa200Fil	:= ExistBlock("FA200FIL")
	LOCAL lFa200F1 	:= ExistBlock("FA200F1" )
	LOCAL lF200Tit 	:= ExistBlock("F200TIT" )
	LOCAL lF200Fim 	:= ExistBlock("F200FIM" )
	LOCAL lTF200Fim 	:= ExistTemplate("F200FIM" )
	LOCAL lF200Var 	:= ExistBlock("F200VAR" )
	LOCAL lF200Avl 	:= ExistBlock("F200AVL" )
	LOCAL l200Fil  	:= .F.
	LOCAL lFirst	:= .F.
	Local cMotBan	:= Space(10)				// motivo da ocorrencia no banco
	Local nCont, cMotivo, lSai := .f.
	Local aLeitura 	:= {}
	Local lFa200_02 := ExistBlock("FA200_02")
	Local aValores 	:= {}
	LOCAL lBxCnab  	:= GetMv("MV_BXCNAB") == "S"
	LOCAL aCampos  	:= {}
	Local lAchouTit	:= .F.
	Local nX 		:= 0
	Local nRegSE5 	:= 0
	Local lBxDtFin	:= GetNewPar("MV_BXDTFIN","1") == "1" // Permite data de baixa menor que MV_DATAFIN 1=SIM / 2=NAO
	Local lHelpDT	:= !lExecJob
	Local lPosDtVc 	:= .F.
	Local nLenDtVc
	Local cPosDtVc
	Local lF200ABAT := ExistBlock("F200ABAT")
	Local lFI0InDic := .T.
	Local nLastLn	:= 0
	Local nUltLinProc := 1
	Local lReproc 	:= .T.
	Local cIdArq
	Local nLinRead	:= 0
	Local nRegEmp	:= SM0->(Recno())
	Local lF200PORT := ExistBlock("F200PORT")
	Local lAltPort 	:= .T.
	Local nTotAbImp := 0
	Local cFilOrig  := cFilAnt	// Salva a filial para garantir que nao seja alterada em customizacao
	Local nTamPre	:= TamSX3("E1_PREFIXO")[1]
	Local nTamNum	:= TamSX3("E1_NUM")[1]
	Local nTamPar	:= TamSX3("E1_PARCELA")[1]
	Local nTamTit	:= nTamPre+nTamNum+nTamPar
	Local aArqConf	:= {}		// Atributos do arquivo de configuracao
	Local lProcessa := .T.
	Local nValTot	:= 0

	Local lAltera   := Iif(IsBlind(), .F. , ALTERA)

	//--- Tratamento Gestao Corporativa
	Local lGestao   := Iif( lFWCodFil, FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa
	//
	Local cFilFwSE1 := IIF( lGestao , FwFilial("SE1") , xFilial("SE1") )
	//
	Local cFilFwCT2 := IIF( lGestao , FwFilial("CT2") , xFilial("CT2") )
	//
	Local lCtbExcl	:= !Empty( cFilFwCT2 )

	Local lMulNatBx := SuperGetMV("MV_MULNATB",.F.,.F.)
	Local lJurComis := (mv_par16 == 1)
	Local nExit		:= 0
	Local nValImp	:= 0
	Local nValLiq	:= 0
	Local lRet		:= .T.
	Local cLog			:= ""
	Local cCamposE5	:= ""
	Local aAlt     	 := {}
	Local cNatLote	:= FINNATMOV("R")
	Local cLocRec 	:= SuperGetMV( "MV_LOCREC" , .F. , " " )
	Local lTtMes	:= .F.
	Local lCustodia := .F.
	Local nTotImp	:= 0
	Local nValRec2	:= 0
	Local aPcc		:= {}
	Local lJurMulDes	:= (SuperGetMv("MV_IMPBAIX",.t.,"2") == "1")
	Local nOldValRec	:= 0
	Local nSalImp		:= 0
	Local lCalcIssBx	:= .F.
	Local lRecIss		:= .F.
	Local lSC5RecIss	:= SC5->(FieldPos("C5_RECISS")) > 0

	Local lPccBxCr	:= FPccBxCr() //Controla o Pis Cofins e Csll na baixa
	Local lIrPjBxCr	:= FIrPjBxCr() //Controla IRPJ na Baixa
	Local lBxTotal	:= .F.
	Local lPELog 		:= .F.
	Local uRet    	:= Nil
	Local lIntegTIN	:= FindFunction( "GETROTINTEG" ) .and. FindFunction("FwHasEAI")
	Local lMU070 		:= FWHasEAI("FINA070",.T.,,.T.)
	Local lIntRm 		:= .F.
	Local cTitPai		:= ""
	Local cPrefRM 	:= SuperGetMv("MV_PREFRM",,"TIN")
	Local nValorAux := 0

	Local l200GEMBX	:= ExistBlock("200GEMBX")
	Local lGEMBaixa	:= ExistTemplate("GEMBaixa")
	Local lFA200SEB	:= ExistBlock("FA200SEB")
	Local lF200GLOG	:= ExistBlock("F200GLOG")
	Local lF200BXAG	:= ExistBlock("F200BXAG")
	Local lF200IMP	:= ExistBlock("F200IMP")
	Local cBuffer	:= ""
	Local nHdlRecic	:= 0
	Local oModelMov := Nil
	Local oModelBxC := Nil
	Local cCamArq	:= ""
	Local lBarra    := isSrvUnix()

	oModelMov := FWLoadModel("FINM030")
	oModelBxC := FWLoadModel("FINM010")

	If ExistBlock("F200CNAB")
		lBxCnab := ExecBlock("F200CNAB",.F.,.F.,{lBxCnab,cAlias})
	EndIf

	nHdlBco   	:= 0
	nHdlConf   	:= 0
	nSeq       	:= 0
	cMotBx     	:= "NOR"
	nTotAGer   	:= 0
	nTotDesp   	:= 0 // Total de Despesas para uso com MV_BXCNAB
	nTotOutD   	:= 0 // Total de outras despesas para uso com MV_BXCNAB
	nTotValCC   := 0 // Total de outros creditos para uso com MV_BXCNAB
	nValEstrang := 0
	VALOR    	:= 0
	nHdlPrv  	:= 0
	ABATIMENTO  := 0

	Private cBanco
	Private cAgencia
	Private cConta
	Private cHist070
	Private lAut:=.f.,nTotAbat := 0
	Private cArquivo
	Private dDataCred,dBaixa
	Private lBAIXCNAB := .F.
	Private lVlrMaior := .F.
	Private nVlrMaior := 0
	Private lCabec := .f.
	Private nHdlCNAB := 0
	Private cPadrao
	Private nTotal := 0
	Private cModSpb := "1"  // Informado apenas para nao dar problemas nas rotinas de baixa
	Private nAcresc
	Private nDecresc
	Private aFlagCTB		:= {}
	Private lUsaFlag		:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
	Private nLidos,nLenNum,nLenData,nLenDesp,nLenDesc,nLenAbat,nLenMot, nTamDet
	Private nLenPrin,nLenJuro,nLenMult,nLenOcor,nLenTipo,nLenCC,nLenDtCC, nLenOutrD
	Private cPosNum,cPosData,cPosDesp,cPosDesc,cPosAbat,cPosPrin,cPosJuro,cPosMult
	Private cPosOcor,cPosTipo,cPosCC,cPosDtCC,cPosMot, cPosOutrD

	If lMVCNABImp
		// vari∑veis usadas pela TotMes
		PRIVATE aDadosRef	:= Array(7)
		PRIVATE aDadosRet	:= Array(7)
		AFill( aDadosRef, 0 )
		AFill( aDadosRet, 0 )
	EndIf
	PRIVATE nPis := nCofins := nCsll := nIrrf := nParciais := 0

	// Se existir o arquivo de LOG, forca sua abertura antes do inicio da transacao
	If lFI0InDic
		DbSelectArea("FI0")
		DbSelectArea("FI1")
	Endif

	///ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffo
	//> Posiciona no Banco indicado                                  >
	//?ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY
	cBanco  := mv_par06
	cAgencia:= mv_par07
	cConta  := mv_par08
	cSubCta := mv_par09
	lDigita := IIF(mv_par01==1,.T.,.F.)
	lAglut  := IIF(mv_par02==1,.T.,.F.)

	If lMU070 .And. ( lIntegTIN .and. AllTrim(SE1->E1_ORIGEM)=="FINI055" ) .Or.;
	( FWHasEAI("FINI070A",.T.,,.T.) .And. ( AllTrim(SE1->E1_ORIGEM) $ 'L|S|T' .Or. SE1->E1_IDLAN > 0 ) )
		lIntRm := .T.
	Endif

	///fffffffffffffffffffffffffffffffffffffffffffffffffffffffffo
	//> Verifica se existe inidce IDCNAB para multiplas filiais >
	//?fffffffffffffffffffffffffffffffffffffffffffffffffffffffffY
	If mv_par13 == 2
		If lCtbExcl
			// A Contabilidade est∑ em modo exclusivo e foi solicitado o processamento de todas as filiais.
			// Neste caso, o sistema nao realiza a contabilizaÁ„o on-line. Confirma mesmo assim?
			if ! lExecJob // Retorno Automatico via Job - parametro que controla execucao via Job
				If ! MsgYesNo( STR0015, STR0012 )
					Return .F.
				Endif
			EndIf
		EndIf
	EndIf

	dbSelectArea("SA6")
	DbSetOrder(1)
	SA6->( dbSeek(xFilial("SA6") + cBanco + cAgencia + cConta) )

	dbSelectArea("SEE")
	DbSetOrder(1)
	SEE->( dbSeek(xFilial("SEE")+cBanco+cAgencia+cConta+cSubCta) )
	If !SEE->( found() )
		Help(" ",1,"PAR150")

		// Retorno Automatico via Job
		if lExecJob
			Aadd(aMsgSch, STR0017+cBanco+"  "+STR0018+cAgencia+"  "+STR0019+cConta+"  "+STR0020+cSubCta) // "Parametros de Bancos nao encontrados para o Banco:" # "Agencia:" # "Conta:" # "Sub-Conta:"
		Endif

		Return .F.
	Endif

	If lBxCnab // Baixar arquivo recebidos pelo CNAB aglutinando os valores
		If Empty(SEE->EE_LOTE)
			cLoteFin := StrZero( 1, TamSX3("EE_LOTE")[1] )
		Else
			cLoteFin := FinSomaLote(SEE->EE_LOTE)
		EndIf
		cLoteFin := Iif(CheckLote("R",.F.),cLoteFin,GetNewLote())
	EndIf
	nTamDet := Iif( Empty (SEE->EE_NRBYTES), 400 , SEE->EE_NRBYTES )
	nTamDet	+= 2  // ajusta tamanho do detalhe para ler o CR+LF
	cTabela := Iif( Empty(SEE->EE_TABELA), "17" , SEE->EE_TABELA )

	///fffffffffffffffffffffffffffffffffffffffo
	//> Verifica se a tabela existe           >
	//?fffffffffffffffffffffffffffffffffffffffY
	dbSelectArea( "SX5" )
	If !SX5->( dbSeek( cFilial + cTabela ) )
		Help(" ",1,"PAR150")

		// Retorno Automatico via Job
		if lExecJob
			Aadd(aMsgSch, STR0021) // "Tabela 17 nao localizada no arquivo de tabelas SX5"
		Endif

		Return .F.
	Endif

	//Altero banco da baixa pelo portador ?
	If lF200PORT
		lAltPort := ExecBlock("F200PORT",.F.,.F.)
	Endif

	While !SX5->(Eof()) .and. SX5->X5_TABELA == cTabela
		AADD(aTabela,{Alltrim(X5Descri()),AllTrim(SX5->X5_CHAVE)})
		SX5->(dbSkip( ))
	Enddo

	///ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffo
	//> Verifica o numero do Lote                                    >
	//?ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY
	PRIVATE cLote
	dbSelectArea("SX5")
	dbSeek(cFilial+"09FIN")
	cLote := Substr(X5Descri(),1,4)

	///ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffo
	//> Verifica se « um EXECBLOCK e caso sendo, executa-o							>
	//?ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY
	If At(UPPER("EXEC"),X5Descri()) > 0
		cLote := &(X5Descri())
	Endif

	If ( MV_PAR12 == 1 )
		///ffffffffffffffffffffffffffffffo
		//> Abre arquivo de configuracao >
		//?ffffffffffffffffffffffffffffffY
		cArqConf:=mv_par05
		IF !FILE(cArqConf)
			Help(" ",1,"NOARQPAR")

			// Retorno Automatico via Job
			if lExecJob
				Conout(STR0022+cArqConf+STR0023) // "Arquivo de configuracao " # " nao localizado."
				Aadd(aMsgSch, STR0022+cArqConf+STR0023) // "Arquivo de configuracao " # " nao localizado."
			Endif

			Return .F.
		Else
			nHdlConf:=FOPEN(cArqConf,0+64)
		EndIF

		///ffffffffffffffffffffffffffffo
		//> L‡ arquivo de configuracao >
		//?ffffffffffffffffffffffffffffY
		nLidos:=0
		FSEEK(nHdlConf,0,0)
		nTamArq:=FSEEK(nHdlConf,0,2)
		FSEEK(nHdlConf,0,0)

		While nLidos <= nTamArq

			///fffffffffffffffffffffffffffffffffffffffffffo
			//> Verifica o tipo de qual registro foi lido >
			//?fffffffffffffffffffffffffffffffffffffffffffY
			xBuffer:=Space(85)
			FREAD(nHdlConf,@xBuffer,85)
			IF SubStr(xBuffer,1,1) == CHR(1)
				nLidos+=85
				Loop
			EndIF
			IF SubStr(xBuffer,1,1) == CHR(3)
				nLidos+=85
				Exit
			EndIF

			IF !lPosNum
				cPosNum:=Substr(xBuffer,17,10)
				nLenNum:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosNum:=.t.
				nLidos+=85
				Loop
			EndIF
			IF !lPosData
				cPosData:=Substr(xBuffer,17,10)
				nLenData:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosData:=.t.
				nLidos+=85
				Loop
			End
			IF !lPosDesp
				cPosDesp:=Substr(xBuffer,17,10)
				nLenDesp:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosDesp:=.t.
				nLidos+=85
				Loop
			End
			IF !lPosDesc
				cPosDesc:=Substr(xBuffer,17,10)
				nLenDesc:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosDesc:=.t.
				nLidos+=85
				Loop
			End
			IF !lPosAbat
				cPosAbat:=Substr(xBuffer,17,10)
				nLenAbat:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosAbat:=.t.
				nLidos+=85
				Loop
			EndIF
			IF !lPosPrin
				cPosPrin:=Substr(xBuffer,17,10)
				nLenPrin:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosPrin:=.t.
				nLidos+=85
				Loop
			EndIF
			IF !lPosJuro
				cPosJuro:=Substr(xBuffer,17,10)
				nLenJuro:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosJuro:=.t.
				nLidos+=85
				Loop
			EndIF
			IF !lPosMult
				cPosMult:=Substr(xBuffer,17,10)
				nLenMult:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosMult:=.t.
				nLidos+=85
				Loop
			EndIF
			IF !lPosOcor
				cPosOcor:=Substr(xBuffer,17,10)
				nLenOcor:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosOcor:=.t.
				nLidos+=85
				Loop
			EndIF
			IF !lPosTipo
				cPosTipo:=Substr(xBuffer,17,10)
				nLenTipo:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosTipo:=.t.
				nLidos+=85
				Loop
			EndIF
			IF !lPosOutrD
				cPosOutrD:=Substr(xBuffer,17,10)
				nLenOutrD:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosOutrD:=.t.
				nLidos+=85
				Loop
			EndIF
			IF !lPosCC
				cPosCC:=Substr(xBuffer,17,10)
				nLenCC:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosCC:=.t.
				nLidos+=85
				Loop
			EndIF
			IF !lPosDtCc
				cPosDtCc:=Substr(xBuffer,17,10)
				nLenDtCc:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosDtCc:=.t.
				nLidos+=85
				Loop
			EndIF
			IF !lPosNsNum
				cPosNsNum := Substr(xBuffer,17,10)
				nLenNsNum := 1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosNsNum := .t.
				nLidos += 85
				Loop
			EndIF
			IF !lPosMot									// codigo do motivo da ocorrencia
				cPosMot:=Substr(xBuffer,17,10)
				nLenMot:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosMot:=.t.
				nLidos+=85
				Loop
			EndIF
			If !lPosDtVc
				cPosDtVc:=Substr(xBuffer,17,10)
				nLenDtVc:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosDtVc:=.t.
				nLidos+=85
				Loop
			Endif
		EndDo

		///fffffffffffffffffffffffffffffffo
		//> fecha arquivo de configuracao >
		//?fffffffffffffffffffffffffffffffY
		Fclose(nHdlConf)
	EndIf
	///fffffffffffffffffffffffffffffffffo
	//> Abre arquivo enviado pelo banco >
	//?fffffffffffffffffffffffffffffffffY

	//MV_LOCREC  -ParÇmetro onde ser∑ gravado o diret€rio

	MV_PAR04 := Alltrim(MV_PAR04)
	cLocRec	 := Alltrim(cLocRec)

	If lBarra
		MV_PAR04 := StrTran(MV_PAR04,"\","/")
		cLocRec	 := StrTran(cLocRec ,"\","/")
	Else
		MV_PAR04 := StrTran(MV_PAR04,"/","\")
		cLocRec	 := StrTran(cLocRec ,"/","\")
	Endif

	If Empty(cLocRec)
		If File(MV_PAR04)
			cArqEnt := MV_PAR04
		Else
			If !lExecJob
				Help( Nil, Nil, STR0051, Nil , STR0052 + MV_PAR04 + STR0050 , 1, 0 )  //"Arquivo nao Encontrado" # "O arquivo " #  " nao foi localizado. Favor verificar."
				Return .F.
			Else
				Return .F.
			Endif
		Endif
	Else
		If AT("/", MV_PAR04) > 0 .Or. AT("\", MV_PAR04) > 0 .Or. AT(":", MV_PAR04) > 0
			If File(MV_PAR04)
				cArqEnt := MV_PAR04
			Else
				If !lExecJob
					Help( Nil, Nil, STR0051, Nil , STR0052 + ArquivoEnt() + "," + STR0049 + MV_PAR04 + STR0050 , 1, 0 )  //"Arquivo nao Encontrado" # "O arquivo " #  " "Informado no caminho " # "nao foi localizado. Favor verificar"
					Return .F.
				Else
					Return .F.
				Endif
			Endif
		Else
			If ! SubStr(cLocRec, Len(cLocRec), 1 ) $ "/|\|"
				If lBarra
					cLocRec := cLocRec + "/"
				Else
					cLocRec := cLocRec + "\"
				Endif
			Endif

			cCamArq  := cLocRec + MV_PAR04
			If File(cCamArq)
				cArqEnt := cCamArq
			Else
				If !lExecJob
					Help( Nil, Nil, STR0051, Nil , STR0052 + MV_PAR04 + "," + STR0049 + cCamArq + STR0050 , 1, 0 )  //"Arquivo nao Encontrado" # "O arquivo " #  " "Informado no caminho " # "nao foi localizado. Favor verificar"
					Return .F.
				Else
					Return .F.
				Endif
			Endif
		Endif
	Endif

	If !FILE(cArqEnt)
		Help(" ",1,"NOARQENT")

		// Retorno Automatico via Job
		if lExecJob
			Aadd(aMsgSch, STR0024+cArqEnt+STR0023) // "Arquivo de entrada " # " nao localizado."
		Endif

		Return .F.
	Else
		nHdlBco:=FOPEN(cArqEnt,0+64)
	EndIF

	If lRecicl
		///ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffo
		//> Filtra o arquivo por E1_NUMBCO - caso exista reciclagem      >
		//?ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY
		dbSelectArea("SE1")
		cIndex	:= CriaTrab(nil,.f.)
		cChave	:= IndexKey()
		IndRegua("SE1",cIndex,"E1_FILIAL+E1_NUMBCO",,Fa200ChecF(),STR0009)  //"Selecionando Registros..."
		nIndex 	:= RetIndex("SE1")
		dbSelectArea("SE1")
		dbSetOrder(nIndex+1)

		dbGoTop()
		IF BOF() .and. EOF()
			Help(" ",1,"RECNO")

			// Retorno Automatico via Job
			if lExecJob
				Aadd(aMsgSch, STR0025)  // "Nao foram localizados registros na tabela SE1."
			Endif

			Return
		EndIf
	EndIf

	///ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffo
	//> Chama a SumAbatRec antes do Controle de transas„o para abrir o alias >
	//> auxiliar __SE1																		 >
	//?ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY
	SumAbatRec( "", "", "", 1, "")

	///ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffo
	//> Gera arquivo de Trabalho                                     >
	//?ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY
	AADD(aCampos,{"FILMOV","C",IIf( lFWCodFil, FWGETTAMFILIAL, 2 ),0})
	AADD(aCampos,{"DATAC","D",08,0})
	AADD(aCampos,{"MOEDA","C",TamSX3("E1_MOEDA")[1],0})
	AADD(aCampos,{"NATURE","C",TamSX3("E1_NATUREZ")[1],0})
	AADD(aCampos,{"TOTAL","N",17,2})

	If __oFINA2001 <> Nil
		__oFINA2001:Delete()
		__oFINA2001	:= Nil
	Endif

	__oFINA2001 := FWTemporaryTable():New("TRB")
	__oFINA2001:SetFields( aCampos )

	aChave   := {"FILMOV","DATAC"}

	__oFINA2001:AddIndex("1", aChave)
	__oFINA2001:Create()

	///fffffffffffffffffffffffffffffffo
	//> L‡ arquivo enviado pelo banco >
	//?fffffffffffffffffffffffffffffffY
	nLidos:=0
	FSEEK(nHdlBco,0,0)
	nTamArq:=FSEEK(nHdlBco,0,2)
	FSEEK(nHdlBco,0,0)
	///ffffffffffffffffffffffffffffffffffffffffffffffffffffo
	//> Desenha o cursor e o salva para poder movimentÜ-lo >
	//?ffffffffffffffffffffffffffffffffffffffffffffffffffffY
	ProcRegua( nTamArq/nTamDet , 24 )

	///ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffo
	//> Carrega atributos do arquivo de configuracao                 >
	//?ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY
	aArqConf := Directory(MV_PAR05)

	lFirst 		:= .F.
	nTotAger 	:= 0
	nCtDesp 	:= 0
	nCtOutCrd 	:= 0

	// Se existir o arquivo de LOG, grava as informacoes pertinentes, referente ao cabecalho do arquivo
	// Para futuro reprocessamento se preciso for.
	If lFI0InDic
		FREAD(nHdlBco,cBuffer,10000)
		cIdArq	 := "A"+SubStr(Str(MsCrc32(cBuffer+Str(nTamArq)),10),2)
		lReproc	 := Fa200GrvLog(1, cArqEnt, cBanco, cAgencia, cConta, @nUltLinProc,,,,cIdArq)
	Endif

	FSEEK(nHdlBco,0,0)
	///fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffo
	//> Inicializa a gravacao dos lancamentos do SIGAPCO          >
	//?fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY
	PcoIniLan("000004")
	PcoIniLan("000007")

	While lReproc .And. nLidos <= nTamArq
		IncProc()

		If MV_PAR12 == 1
			nLastLn ++
			// Se tiver o arquivo de LOG, avanca ate a proxima linha, apos a ultima processada
			If lFI0InDic
				If nLastLn < nUltLinProc
					If lBxCnab
						xBuffer:=Space(nTamDet)
						FREAD(nHdlBco,@xBuffer,nTamDet)

						LoadVlBx( nHdlBco, xBuffer, nTamDet, @nValTot, @nTotDesp, @nTotOutD, @nTotValCc, @nTotAGer,,lBxCnab)
						nLidos+=nTamDet
					Else
						// Avanca uma linha do arquivo retorno
						nLidos+=nTamDet
						fReadLn(nHdlBco,,(nTamDet)) // Posiciona proxima linha
					Endif
					Loop
				Endif
				// Grava a ultima linha lida do arquivo
				FI0->(RecLock("FI0"))
				FI0->FI0_LASTLN	:= nLastLn
				MsUnlock()
			Endif
		Endif

		nDespes := 0
		nDescont:= 0
		nAbatim := 0
		nValRec := 0
		nJuros  := 0
		nMulta  := 0
		nValCc  := 0
		nCM		:= 0
		nOutrDesp := 0
		nVlrMaior := 0
		lVlrMaior := .F.
		lBaixou	:= .F.
		lBAIXCNAB := .F.
		lBxTotal := .F.

		// Template GEM

		cFilAnt := cFilOrig					// sempre restaura a filial original

		If ( MV_PAR12 == 1 )
			///fffffffffffffffffffffffffffffo
			//> Tipo qual registro foi lido >
			//?fffffffffffffffffffffffffffffY
			xBuffer:=Space(nTamDet)
			FREAD(nHdlBco,@xBuffer,nTamDet)
			If lF200Cus
				lCustodia := ExecBlock("F200CUS",.f.,.f.,xBuffer) //podendo ser retornado .T. (Verdadeiro )ou .F. (Falso)
			EndIF
			IF SubStr(xBuffer,1,1) $ "0|A"
				If !lCustodia
					nLidos+=nTamDet
					Loop
				EndIf
			EndIF
			IF SubStr(xBuffer,1,1) $ "1|F|J|7|2"  .or. lCustodia
				///ffffffffffffffffffffffffffffffffffo
				//> L‡ os valores do arquivo Retorno >
				//?ffffffffffffffffffffffffffffffffffY
				cNumTit :=Substr(xBuffer,Int(Val(Substr(cPosNum, 1,3))),nLenNum )
				cData   :=Substr(xBuffer,Int(Val(Substr(cPosData,1,3))),nLenData)
				cData   :=ChangDate(cData,SEE->EE_TIPODAT)
				dBaixa  :=Ctod(Substr(cData,1,2)+"/"+Substr(cData,3,2)+"/"+Substr(cData,5,2),"ddmmyy")
				cTipo   :=Substr(xBuffer,Int(Val(Substr(cPosTipo, 1,3))),nLenTipo )
				cTipo   := Iif(Empty(cTipo),"NF ",cTipo)		// Bradesco
				cNsNum  := " "
				cEspecie:= "   "
				dDataCred := Ctod("//")
				dDtVc := Ctod("//")
				IF !Empty(cPosDesp)
					nDespes:=Round(Val(Substr(xBuffer,Int(Val(Substr(cPosDesp,1,3))),nLenDesp))/100,2)
				EndIF
				IF !Empty(cPosDesc)
					nDescont:=Round(Val(Substr(xBuffer,Int(Val(Substr(cPosDesc,1,3))),nLenDesc))/100,2)
				EndIF
				IF !Empty(cPosAbat)
					nAbatim:=Round(Val(Substr(xBuffer,Int(Val(Substr(cPosAbat,1,3))),nLenAbat))/100,2)
				EndIF
				IF !Empty(cPosPrin)
					nValRec :=Round(Val(Substr(xBuffer,Int(Val(Substr(cPosPrin,1,3))),nLenPrin))/100,2)
				EndIF
				IF !Empty(cPosJuro)
					nJuros  :=Round(Val(Substr(xBuffer,Int(Val(Substr(cPosJuro,1,3))),nLenJuro))/100,2)
				EndIF
				IF !Empty(cPosMult)
					nMulta  :=Round(Val(Substr(xBuffer,Int(Val(Substr(cPosMult,1,3))),nLenMult))/100,2)
				EndIF
				IF !Empty(cPosOutrd)
					nOutrDesp  :=Round(Val(Substr(xBuffer,Int(Val(Substr(cPosOutrd,1,3))),nLenOutrd))/100,2)
				EndIF
				IF !Empty(cPosCc)
					nValCc :=Round(Val(Substr(xBuffer,Int(Val(Substr(cPosCc,1,3))),nLenCc))/100,2)
				EndIF
				IF !Empty(cPosDtCc)
					cData  :=Substr(xBuffer,Int(Val(Substr(cPosDtCc,1,3))),nLenDtCc)
					cData    := ChangDate(cData,SEE->EE_TIPODAT)
					dDataCred:=Ctod(Substr(cData,1,2)+"/"+Substr(cData,3,2)+"/"+Substr(cData,5,2),"ddmmyy")
					dDataUser:=dDataCred
				End
				IF !Empty(cPosNsNum)
					cNsNum  :=Substr(xBuffer,Int(Val(Substr(cPosNsNum,1,3))),nLenNsNum)
				End
				If nLenOcor == 2
					cOcorr  :=Substr(xBuffer,Int(Val(Substr(cPosOcor,1,3))),nLenOcor) + " "
				Else
					cOcorr  :=Substr(xBuffer,Int(Val(Substr(cPosOcor,1,3))),nLenOcor)
				EndIf
				If !Empty(cPosMot)
					cMotBan:=Substr(xBuffer,Int(Val(Substr(cPosMot,1,3))),nLenMot)
				EndIf
				IF !Empty(cPosDtVc)
					cDtVc :=Substr(xBuffer,Int(Val(Substr(cPosDtVc,1,3))),nLenDtVc)
					cDtVc := ChangDate(cDtVc,SEE->EE_TIPODAT)
					dDtVc :=Ctod(Substr(cDtVc,1,2)+"/"+Substr(cDtVc,3,2)+"/"+Substr(cDtVc,5,2),"ddmmyy")
				EndIf

				///fffffffffffffffffffffffffffffffo
				//> o array aValores irÜ permitir >
				//> que qualquer excec„o ou neces->
				//> sidade seja tratado no ponto  >
				//> de entrada em PARAMIXB        >
				//?fffffffffffffffffffffffffffffffY
				// Estrutura de aValores
				//	Numero do T∞tulo	- 01
				//	data da Baixa		- 02
				// Tipo do T∞tulo		- 03
				// Nosso Numero			- 04
				// Valor da Despesa		- 05
				// Valor do Desconto	- 06
				// Valor do Abatiment	- 07
				// Valor Recebido    	- 08
				// Juros				- 09
				// Multa				- 10
				// Outras Despesas		- 11
				// Valor do Credito		- 12
				// Data Credito			- 13
				// Ocorrencia			- 14
				// Motivo da Baixa 		- 15
				// Linha Inteira		- 16
				// Data de Vencto	   	- 17

				aValores := ( { cNumTit, dBaixa, cTipo, cNsNum, nDespes, nDescont, nAbatim, nValRec, nJuros, nMulta, nOutrDesp, nValCc, dDataCred, cOcorr, cMotBan, xBuffer,dDtVc,{} })

				If l200GEMBX
					uRet := ExecBlock("200GEMBX", .F., .F., {aValores})
					If ValType( uRet ) == 'A'
						aValores := aClone(uRet)
					Endif
				EndIf

				// Template GEM
				If lF200Var
					uRet := ExecBlock("F200VAR",.F.,.F.,{aValores})
					If ValType( uRet ) == 'A'
						aValores := aClone(uRet)
					Endif
				ElseIf lGEMBaixa
					ExecTemplate("GEMBaixa",.F.,.F.,)
				Endif

				If Empty(cNumTit)
					nLidos += nTamDet
					Loop
				EndIf

				///fffffffffffffffffffffffffffffffo
				//> Verifica especie do titulo    >
				//?fffffffffffffffffffffffffffffffY
				nPos := Ascan(aTabela, {|aVal|aVal[1] == Substr(cTipo,1,2)})
				If nPos != 0
					cEspecie := aTabela[nPos][2]
				Else
					cEspecie	:= "  "
				EndIf
				If cEspecie $ MVABATIM			// Nao l‡ titulo de abatimento
					nLidos += nTamDet
					Loop
				Endif
			Else
				nLidos += nTamDet
				Loop
			Endif
		Else
			//Estrutura do arquivo localizado na pasta system.
			If lExecJob.and. !Empty(SEE->EE_CFGREC)
				cArqCfg := SEE->EE_CFGREC
			ElseIf Valtype(MV_PAR05)=="C"
				cArqCfg := MV_PAR05
			Endif

			aLeitura := ReadCnab2(nHdlBco,cArqCfg,nTamDet,aArqConf,@nLinRead)
			cNumTit  := SubStr(aLeitura[1],1,nTamTit)
			cData    := aLeitura[04]
			cData    := ChangDate(cData,SEE->EE_TIPODAT)
			dBaixa   := Ctod(Substr(cData,1,2)+"/"+Substr(cData,3,2)+"/"+Substr(cData,5,2),"ddmmyy")
			cTipo    := aLeitura[02]
			cTipo    := Iif(Empty(cTipo),"NF ",cTipo)		// Bradesco
			cNsNum   := aLeitura[11]
			nDespes  := aLeitura[06]
			nDescont := aLeitura[07]
			nAbatim  := aLeitura[08]
			nValRec  := aLeitura[05]
			nJuros   := aLeitura[09]
			nMulta   := aLeitura[10]
			cOcorr   := PadR(aLeitura[03],3)
			nValOutrD:= aLeitura[12]
			nValCC   := aLeitura[13]
			cData    := aLeitura[14]
			cData    := ChangDate(cData,SEE->EE_TIPODAT)
			dDataCred:= Ctod(Substr(cData,1,2)+"/"+Substr(cData,3,2)+"/"+Substr(cData,5,2),"ddmmyy")
			dDataUser:= dDataCred
			cMotBan  := aLeitura[15]
			xBuffer  := aLeitura[17] // Segmentos concatenados
			aBuffer  := aLeitura[19] // Segmentos separados
			dDtVc		:= CTOD("//")

			nLastLn := nLinRead
			nLidos := nLastLn * nTamDet

			// Se tiver o arquivo de LOG, avanca ate a proxima linha, apos a ultima processada
			If lFI0InDic
				If nLastLn < nUltLinProc
					If lBxCnab
						xBuffer:=Space(nTamDet)
						FREAD(nHdlBco,@xBuffer,nTamDet)

						LoadVlBx( nHdlBco, xBuffer, nTamDet, @nValtot, @nTotDesp, @nTotOutD, @nTotValCc, @nTotAGer,,lBxCnab)
					Else
						// Avanca uma linha do arquivo retorno
						fReadLn(nHdlBco,,(nTamDet)) // Posiciona proxima linha
					Endif
					Loop
				Endif
				// Grava a ultima linha lida do arquivo
				FI0->(RecLock("FI0"))
				FI0->FI0_LASTLN	:= nLastLn
				MsUnlock()
			Endif

			aValores := ( { cNumTit, dBaixa, cTipo, cNsNum, nDespes, nDescont, nAbatim, nValRec, nJuros, nMulta, nVaLOutrD, nValCc, dDataCred, cOcorr, cMotBan, xBuffer, dDtVc, aBuffer })

			If l200GEMBX
				uRet := ExecBlock("200GEMBX", .F., .F., {aValores})
				If ValType( uRet ) == 'A'
					aValores := aClone(uRet)
				Endif
			EndIf

			// Template GEM
			If lF200Var
				uRet := ExecBlock("F200VAR",.F.,.F.,{aValores})
				If ValType( uRet ) == 'A'
					aValores := aClone(uRet)
				Endif
			ElseIf lGEMBaixa
				ExecTemplate("GEMBaixa",.F.,.F.,)
			Endif

			If Empty(cNumTit)
				nLidos += nTamDet
				Loop
			Endif

			///fffffffffffffffffffffffffffffffo
			//> Verifica especie do titulo    >
			//?fffffffffffffffffffffffffffffffY
			nPos := Ascan(aTabela, {|aVal|aVal[1] == Alltrim(Substr(cTipo,1,3))})
			If nPos != 0
				cEspecie := aTabela[nPos][2]
			Else
				cEspecie	:= "  "
			EndIf
			If cEspecie $ MVABATIM			// Nao l‡ titulo de abatimento
				Loop
			EndIf
		EndIf
		If lF200Avl .And. !ExecBlock("F200AVL",.F.,.F.,{aValores} )
			Loop
		Endif
		///fffffffffffffffffffffffffffffffo
		//> Verifica codigo da ocorrencia >
		//> ∞ndice: Filial+banco+cod banco>
		//> +tipo                         >
		//?fffffffffffffffffffffffffffffffY
		dbSelectArea("SEB")
		dbSetOrder(1)
		If !(dbSeek(xFilial("SEB")+mv_par06+cOcorr+"R"))
			Help(" ",1,"FA200OCORR",,mv_par06+"-"+cOcorr+"R",4,1)

			// Retorno Automatico via Job
			if lExecJob
				Aadd(aMsgSch, STR0026+mv_par06+" "+cOcorr+STR0027) // "Ocorrencia " # " nao localizada na tabela SEB."
			Endif
		Endif
		lHelp 		:= .F.
		lNaoExiste  := .F.				// Verifica se registro de reciclagem existe no SE1
		If lT200pos
			ExecTemplate("FA200POS",.F.,.F.,{aValores})
		Endif
		If l200pos
			uRet := Execblock("FA200POS",.F.,.F.,{aValores})
			If ValType( uRet ) == 'A'
				aValores := aClone(uRet)
			Endif

		Endif
		///fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffo
		//> Verifica se existe o titulo no SE1. Caso este titulo nao seja >
		//> localizado, passa-se para a proxima linha do arquivo retorno. >
		//> O texto do help sera' mostrado apenas uma vez, tendo em vista >
		//> a possibilidade de existirem muitos titulos de outras filiais.>
		//> OBS: Sera verificado inicialmente se nao existe outra chave   >
		//> igual para tipos de titulo diferentes.                        >
		//?fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY
		dbSelectArea("SE1")
		IF lFA200SEB
			lProcessa := ExecBlock("FA200SEB",.F.,.F.)
			lProcessa := IIF(ValType(lProcessa) != "L",.T., lProcessa)
		ENDIF

		IF lProcessa
			If SEB->EB_OCORR != "39"		// cod 39 -> indica reciclagem
				SE1->(dbSetOrder(1))
				lAchouTit := .F.

				If lFa200Fil
					l200Fil := .T.
					Execblock("FA200FIL",.F.,.F.,aValores)
				Else

					If mv_par13 == 2 .And. !Empty( cFilFwSE1 )
						//Busca por IdCnab (sem filial)
						SE1->(dbSetOrder(19)) // IdCnab
						If SE1->(MsSeek(Substr(cNumTit,1,10)))
							cFilAnt	:= SE1->E1_FILIAL
							If lCtbExcl
								mv_par11 := 2  //Desligo contabilizacao on-line
							Endif
						Endif
					Else
						//Busca por IdCnab
						SE1->(dbSetOrder(16)) // Filial+IdCnab
						SE1->(MsSeek(xFilial("SE1")+	Substr(cNumTit,1,10)))
					Endif

					//Se nao achou, utiliza metodo antigo (titulo)
					If SE1->(!Found())
						SE1->(dbSetOrder(1))
						// Busca por chave antiga como retornado pelo banco
						If dbSeek(xFilial("SE1")+PadR(cNumTit,nTamTit)+cEspecie)
							lAchouTit := .T.
							nPos   := 1
						Endif

						While !lAchouTit
							// Busca por chave antiga
							dbSetOrder(1)
							If !dbSeek(xFilial("SE1")+Pad(cNumTit,nTamTit)+cEspecie)
								nPos := Ascan(aTabela, {|aVal|aVal[1] == Substr(cTipo,1,2)},nPos+1)
								If nPos != 0
									cEspecie := aTabela[nPos][2]
								Else
									Exit
								Endif
							Else
								lAchouTit := .T.
							Endif
						Enddo

						If !lAchouTit
							// Busca por chave antiga adaptada para o tamanho de 9 posicoes para numero de NF
							// Isto ocorre quando titulo foi enviado com 6 posicoes para numero de NF e retornou com o
							// campo ja atualizado para 9 posicoes
							cNumTit := SubStr(cNumTit,1,nTamPre)+Padr(Substr(cNumtit,4,6),nTamNum)+SubStr(cNumTit,10,nTamPar)
							If !Empty(cNumTit) .And. dbSeek(xFilial("SE1")+Substr(cNumTit,1,nTamTit))
								cEspecie := SE1->E1_TIPO
								lAchouTit := .T.
								nPos   := 1
							Endif

							While !lAchouTit
								// Busca por chave antiga
								dbSetOrder(1)
								If !dbSeek(xFilial("SE1")+Pad(cNumTit,nTamTit)+cEspecie)
									nPos := Ascan(aTabela, {|aVal|aVal[1] == Substr(cTipo,1,2)},nPos+1)
									If nPos != 0
										cEspecie := aTabela[nPos][2]
									Else
										Exit
									Endif
								Else
									lAchouTit := .T.
								Endif
							Enddo
						Endif
					Else
						nPos := 1
					Endif

					If nPos == 0
						lHelp := .T.
					EndIF
					If !lUmHelp .And. lHelp
						Help(" ",1,"NOESPECIE",,cNumTit+" "+cEspecie,5,1)
						lUmHelp := .T.

						// Retorno Automatico via Job
						if lExecJob
							Aadd(aMsgSch, STR0028+cEspecie+STR0029+cNumTit) // "Especie " # " nao localizada para o titulo "
						Endif
					Endif
				EndIf
			Else
				If lRecicl
					///fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffo
					//> Mesmo que nao exista o registro no SE1, ele serÜ criado no 	>
					//> arquivo de reclicagem                                         >
					//?fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY
					dbSetOrder(nIndex+1)
					If !dbSeek(xFilial("SE1")+cNsNum)
						If !lFirst
							lFirst := .T.
						EndIf
						Fa200GrRec(cNsNum, @nHdlRecic)
						lNaoExiste := .T.				// Registro nao existente no SE1 -> portanto nao deve gravar nada no SE1!!
					Endif
				Else			//  uma rejeicao porem o registro nao foi cadastrado no SE1
					Help(" ",1,"NOESPECIE",,cNumTit+" "+cEspecie,5,1)
					lNaoExiste := .T.

					// Retorno Automatico via Job
					if lExecJob
						Aadd(aMsgSch, STR0028+cEspecie+STR0029+cNumTit) // "Especie " # " nao localizada para o titulo "
					Endif
				EndIf
			EndIF
		ENDIF

		//atualiza a leitura do parametro, caso o arquivo retorno tenha registros de mais de uma filial
		lCalcIssBx	:= .F.

		BEGIN TRANSACTION

			// Retorno Automatico via Job
			// controla o status para emissao do relatorio de processamento
			if lExecJob
				cStProc := ""
				if lNaoExiste
					cStProc := STR0030 // "Titulo Inexistente"
					Aadd(aFa205R,{cNumTit,"", "", dBaixa,	0, nValRec, cStProc })
				Elseif lHelp
					if SE1->E1_SALDO = 0
						cStProc := STR0031 // "Baixado anteriormente"
					Else
						cStProc := STR0032 // "Titulo com Erro"
					Endif
				Endif
			Endif

			If !lHelp .And. !lNaoExiste
				// Retorno Automatico via Job
				// controla o status para emissao do relatorio de processamento do FINA205
				if lExecJob .and. SE1->E1_SALDO = 0
					cStProc := STR0031 // "Baixado anteriormente"
				Endif

				lSai := .f.
				IF SEB->EB_OCORR $ "03|15|16|17|40|41|42|52|53"		//Registro rejeitado
					// Retorno Automatico via Job
					// controla o status para emissao do relatorio de processamento do FINA205
					if lExecJob
						cStProc := STR0033 // "Entrada confirmada"
					Endif

					For nCont := 1 To Len(cMotBan) Step 2
						cMotivo := Substr(cMotBan,nCont,2)
						If fa200Rejei(cMotivo,cOcorr)
							lSai := .T.
							///ffffffffffffffffffffffffffffffffffffffffffffffffo
							//> Trata tarifas da retirada do titulo do banco	>
							//?ffffffffffffffffffffffffffffffffffffffffffffffffY
							If lBxCnab
								nTotDesp += nDespes
								nTotOutD += nOutrDesp
							Else
								IF nDespes > 0 .or. nOutrDesp > 0		//Tarifas diversas
									Fa200Tarifa()
								Endif
							Endif
							Exit
						EndIf
					Next nCont
					If lSai .And. ( MV_PAR12 == 1 )
						nLidos += nTamDet
					Endif
				Endif

				If !lSai
					IF SEB->EB_OCORR $ "06|07|08|36|37|38|39" .And. ( lBxDtFin .Or. DtMovFin(dBaixa,lHelpDT) )	//Baixa do Titulo
						cPadrao:=fA070Pad()
						lPadrao:=VerPadrao(cPadrao)
						lContabiliza:= Iif(mv_par11==1,.T.,.F.)

						///fffffffffffffffffffffffffffffffo
						//> Monta Contabilizacao.         >
						//?fffffffffffffffffffffffffffffffY
						If !lCabec .and. lPadrao .and. lContabiliza
							nHdlPrv := HeadProva( cLote,;
							"FINA200",;
							substr( cUsuario, 7, 6 ),;
							@cArquivo )
							nHdlCNAB := nHdlPrv
							lCabec := .T.
						End
						nValEstrang := SE1->E1_SALDO
						lDesconto   := Iif(mv_par10==1,.T.,.F.)

						nTotAbImp	:= 0
						nTotAbat	:= SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA, SE1->E1_MOEDA,"S",dBaixa,@nTotAbImp)
						ABATIMENTO 	:= nTotAbat

						If lAltPort
							cBanco      := Iif(Empty(SE1->E1_PORTADO),cBanco,SE1->E1_PORTADO)
							cAgencia    := Iif(Empty(SE1->E1_AGEDEP),cAgencia,SE1->E1_AGEDEP)
							cConta      := Iif(Empty(SE1->E1_CONTA),cConta,SE1->E1_CONTA)

							// Buscar a Conta Oficial. Abaixo eu seto os novos valores
							If !Empty(SEE->EE_CTAOFI)

								cBanco		:= SEE->EE_CODOFI
								cAgencia	:= SEE->EE_AGEOFI
								cConta		:= SEE->EE_CTAOFI

							Endif
						Endif

						cHist070    := STR0010  //"Valor recebido s/ Titulo"

						//Ponto de entrada para tratamento de abatimento e desconto que voltam na mesma posicao
						//Bradesco
						If lF200ABAT
							ExecBlock("F200ABAT",.F.,.F.)
						Endif

						SA6->(DbSetOrder(1))
						SA6->(MSSeek(xFilial("SA6")+cBanco+cAgencia+cConta))

						///fffffffffffffffffffffffffffffffo
						//> Verifica se a despesa estÜ    >
						//> descontada do valor principal >
						//?fffffffffffffffffffffffffffffffY
						If SEE->EE_DESPCRD == "S"
							nValRec := nValRec+nDespes + nOutrDesp - nValCC
						EndIf
						// Calcula a data de credito, se esta estiver vazia
						If dDataCred == Nil .Or. Empty(dDataCred)
							dDataCred := DataValida(dBaixa,.T.) // Assume a data da baixa
							If !__lPar17 .Or. (__lPar17 .And. MV_PAR17 == 1)
								For nX := 1 To SA6->A6_Retenca // Para todos os dias de retencao valida a data
									// O calculo eh feito desta forma, pois os dias de retencao
									// sao dias uteis, e se fosse apenas somado dDataCred+A6_Retenca
									// nao sera verdadeiro quando a data for em uma quinta-feira, por
									// exemplo e, tiver 2 dias de retencao.
									dDataCred := DataValida(dDataCred+1,.T.)
								Next
							EndIf
						EndIf
						dDataUser := dDataCred
						If dDataCred > dBaixa
							cModSpb := "3"   // COMPE
						Endif
						///ffffffffffffffffffffffffffffffffffo
						//> Possibilita alterar algumas das  >
						//> variÜveis utilizadas pelo CNAB.  >
						//?ffffffffffffffffffffffffffffffffffY

						If lFina200
							aValores[8] := nValRec
							ExecBlock("FINA200",.F.,.F., { aValores, nTotAbat, nTotAbImp } )
						Endif

						// Serao usadas na Fa070Grv para gravar a baixa do titulo, considerando os acrescimos e decrescimos
						nAcresc     := Round(NoRound(xMoeda(SE1->E1_SDACRES,SE1->E1_MOEDA,1,dBaixa,3),3),2)
						nDecresc    := Round(NoRound(xMoeda(SE1->E1_SDDECRE,SE1->E1_MOEDA,1,dBaixa,3),3),2)

						If nDescont > 0 // Valida se o banco retornou desconto no arquivo.
							nDescont 	:= nDescont - nDecresc
						Endif

						If nJuros > 0 // Valida se o banco retornou o juros no arquivo.
							nJuros		:= nJuros - nAcresc
						Endif

						If cPaisLoc == "BRA"
							If lMVCNABImp
								aTit := {}
								lMsErroAuto := .F.

								aAreaCnab := GetArea()
								dbSelectArea("SA1")
								SA1->( dbSetOrder(1) )
								dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)
								lIrPjBxCr	:= FIrPjBxCr()
								// Posiciona no cliente para verificar modo de retencao de ISS
								IF !("FINA040" $ SE1->E1_ORIGEM) .And. lSC5RecIss
									DbSelectArea("SC5")
									SC5->(dbSetOrder(1))
									If SC5->(MsSeek(xfilial("SC5")+SE1->E1_PEDIDO))
										lRecIss := (SC5->C5_RECISS == "1" .And. GetNewPar("MV_DESCISS",.F.))
									Else
										lRecIss := (SA1->A1_RECISS == "1" .And. GetNewPar("MV_DESCISS",.F.))
									Endif
								Else
									lRecIss := (SA1->A1_RECISS == "1" .And. GetNewPar("MV_DESCISS",.F.))
								Endif
								RestArea(aAreaCnab)

								nOldValRec	:= nValRec
								nValLiq := (SE1->E1_VALOR) - (SE1->( E1_PIS + E1_COFINS + E1_CSLL + E1_IRRF + IF(lRecIss,E1_ISS,0) ) )  // Valor liquido do tÃtulo
								nValRec := nValRec - nJuros + nDescont - nMulta - nAcresc + nDecresc

								// RecomposiÁ„o dos valores dos IMPOSTOS para baixa.
								nValRec		:= F200VALREC(dBaixa,nValRec,,nTotAbImp)
								nValImp		:= SE1->( E1_PIS + E1_COFINS + E1_CSLL + E1_IRRF + IF(lRecIss,E1_ISS,0) + E1_INSS )
								nVlrCnab	:= SE1->E1_VALOR - nTotAbat

								//Valores acess€rios
								nVlrCnab	:= nVlrCnab + nJuros - nDescont + nMulta + nAcresc - nDecresc

								// INSS
								nVlrCnab	-= SE1->E1_INSS

								// ISS -  j∑ calculado na funÁ„o SumAbatRec

								// IRRF
								If lIrPjBxCr
									nIrrf := FCaIrBxCR(nValRec)
									nVlrCnab -= nIrrf
								EndIf

								// PCC
								If lPccBxCr
									If dBaixa > dRefPCC
										nSalImp := If ( nValRec > SE1->E1_BASEPIS, SE1->E1_BASEPIS, nValRec )
										aPcc	:= newMinPcc(dBaixa, nSalImp,SE1->E1_NATUREZ,"R",SA1->A1_COD+SA1->A1_LOJA)
										nPis	:= PIS		:= aPcc[2]
										nCofins	:= COFINS	:= aPcc[3]
										nCsll	:= CSLL		:= aPcc[4]

										nVlrCNAB -= (nPis + nCofins + nCsll)
									Else
										F070TotMes(dBaixa,.T.)

										If aDadosRet[2] + aDadosRet[3] + aDadosRet[4] + nValImp + nValRec2 == SE1->E1_SALDO
											nTotImp 	:= aDadosRet[2] + aDadosRet[3] + aDadosRet[4] + nValImp
											nValRec := nOldValRec
										Else
											nValRec := nOldValRec
										EndIf

										If nValImp + nValRec != SE1->E1_VALOR // se baixa parcial
											If SE1->E1_SALDO - nValRec <> 0
												If nValRec + nTotImp != SE1->E1_SALDO
													// Regra de trÕs para achar o valor da soma dos impostos na baixa parcial
													nValImp = ( nValRec * (SE1->( E1_PIS + E1_COFINS + E1_CSLL + E1_IRRF ) ) ) / nValLiq
												Else
													lTtMes := .T.
												EndIf
											Endif
										Endif

										If !lTtMes
											nVlrcnab := SE1->( E1_VALOR -  ( E1_PIS + E1_COFINS + E1_CSLL + E1_IRRF + E1_ISS + E1_INSS ) )
										Else
											nVlrcnab := SE1->E1_VALOR - nTotImp
										EndIf
									EndIf
								EndIf

								Do Case
									Case nOldValRec == 0
									lRet := .F.
									Case nOldValRec == nVlrcnab
									cTipoBx := "Baixa Total por CNAB"
									Case nOldValRec - nValImp == nVlrcnab 		// Caso o cliente pague o valor bruto do tÃtulo ao inv»s do lÃquido
									cTipoBx := "Baixa Total por CNAB"
									nValRec -= Iif(dBaixa < dRefPCC, nValImp, 0)
									Case nOldValRec + nValImp < nVlrcnab
									If lMVGlosa
										cTipoBx := "Baixa com Glosa por CNAB"
									Else
										cTipoBx := "Baixa parcial por CNAB"
									Endif
									Case nOldValRec > nVlrcnab
									cTipoBx := "Baixa Total a mais por CNAB"
									lVlrMaior := .T.
									nVlrMaior := nOldValRec - nVlrCnab
								EndCase

								If dBaixa < dRefPCC
									If !lTtMes
										If SE1->E1_SALDO - nValRec <> 0
											nValRec := Round(NoRound(nValRec+nValImp,2),2)
										EndIf
									ElseIf SE1->E1_SALDO - nValRec <> 0
										nValRec := Round(NoRound(nValRec+nTotImp,2),2)
									EndIf
								EndIf

								If lRet
									AADD( aTit, { "E1_PREFIXO" 	, SE1->E1_PREFIXO	, Nil } )	// 01
									AADD( aTit, { "E1_NUM"     	, SE1->E1_NUM		, Nil } )	// 02
									AADD( aTit, { "E1_PARCELA" 	, SE1->E1_PARCELA	, Nil } )	// 03
									AADD( aTit, { "E1_TIPO"    	, SE1->E1_TIPO		, Nil } )	// 04
									AADD( aTit, { "AUTMOTBX"  	, "NOR"				, Nil } )	// 05
									AADD( aTit, { "AUTDTBAIXA"	, dBaixa			, Nil } )	// 06
									AADD( aTit, { "AUTDTCREDITO", dDataCred			, Nil } )	// 07
									AADD( aTit, { "AUTHIST"   	, cTipoBx		   	, Nil } )	// 08
									AADD( aTit, { "AUTVALREC"  	, nValRec			, Nil } )	// 09
									AADD( aTit, { "AUTJUROS"  	, nJuros			, Nil } )	// 10
									AADD( aTit, { "AUTDESCONT" 	, nDescont			, Nil } )	// 11
									AADD( aTit, { "AUTMULTA" 	, nMulta			, Nil } )	// 12
									AADD( aTit, { "AUTACRESC" 	, nAcresc			, Nil } )	// 13
									AADD( aTit, { "AUTDECRESC" 	, nDecresc			, Nil } )	// 14

									MSExecAuto({|x, y| FINA070(x, y)}, aTit, 3)

									If  lMsErroAuto
										MOSTRAERRO()
										DisarmTransaction()
										lBaixou := .F.
									Else
										lBaixou := lBAIXCNAB
									EndIf

									// recarrega os mv_parx da rotina fina200, pois foi alterado no fina070
									pergunte(cPerg,.F.)

									//Reposicionar SA6 em caso de desposicionamento pelo FINA070 - MSEXECAUTO
									SA6->(DbSetOrder(1))
									SA6->(MSSeek(xFilial("SA6")+cBanco+cAgencia+cConta))

								Endif
							Else
								lBaixou := fA070Grv(lPadrao,lDesconto,lContabiliza,cNsNum,.T.,dDataCred,lJurComis,cArqEnt,SEB->EB_OCORR,;
								/*nTxMoeda*/,/*lGerChqAdt*/,/*aSeqSe5*/,/*aHdlPrv*/,/*lBloqSa1*/,/*lMultNat*/,oModelBxC)
							Endif
						Else
							lBaixou := fA070Grv(lPadrao,lDesconto,lContabiliza,cNsNum,.T.,dDataCred,lJurComis,cArqEnt,SEB->EB_OCORR,;
							/*nTxMoeda*/,/*lGerChqAdt*/,/*aSeqSe5*/,/*aHdlPrv*/,/*lBloqSa1*/,/*lMultNat*/,oModelBxC)
						Endif

						// evitando problemas de processamento
						if lExecJob
							Sleep(500)
						Endif

						If lBaixou

							If !lMVCNABImp
								/* Atualiza o status do titulo no SERASA */
								If cPaisLoc == "BRA"
									If SE1->E1_SALDO <= 0
										cChaveTit := xFilial("SE1") + "|" +;
										SE1->E1_PREFIXO + "|" +;
										SE1->E1_NUM		+ "|" +;
										SE1->E1_PARCELA + "|" +;
										SE1->E1_TIPO	+ "|" +;
										SE1->E1_CLIENTE + "|" +;
										SE1->E1_LOJA
										cChaveFK7 := FINGRVFK7("SE1",cChaveTit)
										F770BxRen("1",TrazCodMot(cMotBx),cChaveFK7)
										dbSelectArea("SE1")
									Endif
								Endif
							EndIf

							///ffffffffffffffffffffffffffffffffffffffffffffffffffffffffo
							//> Verifica se trata Rateio Multi-Natureza na Baixa CNAB  >
							//?ffffffffffffffffffffffffffffffffffffffffffffffffffffffffY
							If lMulNatBx .And. MV_MULNATR .And. SE1->E1_MULTNAT == "1"

								//Variaveis para uso na funcao MultNatC
								nTotLtEZ  := 0
								lOK		  := .F.
								aColsSEV  := {}
								aGrvLctPco := {	{"000004","09","FINA200"}, ;
								{"000004","10","FINA200"}  }

								MultNatB("SE1",.F.,"1",@lOk,@aColsSEV,.T.,.T.)
								If lOk
									MultNatC( "SE1" /*cAlias*/,;
									@nHdlPrv /*@nHdlPrv*/,;
									@nTotal /*@nTotal*/,;
									@cArquivo /*@cArquivo*/,;
									lContabiliza /*lContabiliza*/,;
									.T. /*lBxLote*/,;
									"1" /*cReplica*/,;
									nTotLtEZ /*nTotLtEZ*/,;
									lOk /*lOk*/,;
									aColsSEV /*aCols*/,;
									.T. /*lBaixou*/,;
									aGrvLctPco /*aGrvLctPco*/,;
									lUsaFlag /*lUsaFlag*/,;
									@aFlagCTB /*@aFlagCTB*/	)
								Endif
							Endif

							// Retorno Automatico via Job
							// controla o status para emissao do relatorio de processamento do FINA205
							if lExecJob
								cStProc := "Baixado Ok"
							Endif

							///ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffo
							//> Grava os lancamentos nas contas orcamentarias SIGAPCO    >
							//?ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY
							//to do MARCOS BERTO
							If FWModeAccess("SE1") == "E"
								cFilAnt := SE1->E1_FILIAL
							EndIf
							If SE1->E1_SITUACA == "0"	// Carteira
								PcoDetLan("000004","01","FINA070")
							ElseIf SE1->E1_SITUACA == "1"	// Simples
								PcoDetLan("000004","02","FINA070")
							ElseIf SE1->E1_SITUACA == "2"	// Descontada
								PcoDetLan("000004","03","FINA070")
							ElseIf SE1->E1_SITUACA == "3"	// Vinculada
								PcoDetLan("000004","04","FINA070")
							ElseIf SE1->E1_SITUACA == "4"	// c/Advogado
								PcoDetLan("000004","05","FINA070")
							ElseIf SE1->E1_SITUACA == "5"	// Judicial
								PcoDetLan("000004","06","FINA070")
							ElseIf SE1->E1_SITUACA == "6"	// Caucionada Descontada
								PcoDetLan("000004","07","FINA070")
							ElseIf SE1->E1_SITUACA == "7"	// Carteira Protesto
								PcoDetLan("000004","08","FINA070")

								//Para as novas situacoes de cobranca
								//repito os processos padroes existentes de acordo com a categoria de cada uma
							ElseIF FN022SITCB(SE1->E1_SITUACA)[1]		//Carteira cSituacao $ "0|F|G"
								PcoDetLan("000004","01","FINA070")
							ElseIf FN022SITCB(SE1->E1_SITUACA)[5]	//Simples e Cartorio   cSituacao $ "1|H"
								PcoDetLan("000004","02","FINA070")
							ElseIf FN022SITCB(SE1->E1_SITUACA)[3]	//Descontada 	cSituacao $ "2|7"
								PcoDetLan("000004","03","FINA070")
							ElseIf FN022SITCB(SE1->E1_SITUACA)[4]	//Cobranca em banco com protesto
								PcoDetLan("000004","06","FINA070")
							ElseIf FN022SITCB(SE1->E1_SITUACA)[2]	//Cobranca em banco sem protesto exceto Simples e Cartorio
								PcoDetLan("000004","05","FINA070")
							EndIf
							cFilAnt := cFilOrig

							nTotAGer+=nValRec
							If lBxCnab
								nTotValCc += nValCC
							EndIf

							//Para baixa totalizadora somente gravo o movimento de titulos que
							//nao estejam em carteira descontada (2 ou 7) pois este movimento bancario
							//j∑ foi gerado no momento da transferencia ou montagem do bordero
							IF !(FN022SITCB( SE1->E1_SITUACA )[3]) 	//SE1->E1_SITUACA $ "2/7"
								dbSelectArea("TRB")
								If !(dbSeek(xFilial("SE5")+Dtos(dDataCred)))
									Reclock("TRB",.T.)
									Replace FILMOV With xFilial("SE5")
									Replace DATAC With dDataCred
									Replace NATURE With cNatLote
									Replace MOEDA With StrZero(SE1->E1_MOEDA,2)
								Else
									Reclock("TRB",.F.)
								Endif
								Replace TOTAL WITH TOTAL + If(lMVCNABImp, nVlrCnab, nValRec)
								MsUnlock()
							Endif
						Else
							LoadVlBx( nHdlBco, xBuffer, nTamDet, @nValtot, @nTotDesp, @nTotOutD, @nTotValCc, @nTotAGer,aLeitura, lBxCnab)
							cStProc := "Problemas na Baixa"
						Endif

						If !lBxCnab
							///ffffffffffffffffffffffffffffffffffffffffffffffffffffffffo
							//> Grava Outros Cr«ditos, se houver valor                 >
							//?ffffffffffffffffffffffffffffffffffffffffffffffffffffffffY
							If nValcc > 0
								fa200Outros()
							Endif
						Endif

						If lCabec .and. lPadrao .and. lContabiliza .and. lBaixou

							If lUsaFlag // Armazena em aFlagCTB para atualizar no modulo Contabil
								aAdd( aFlagCTB, { "E5_LA", "S", "SE5", SE5->( RecNo() ), 0, 0, 0} )
							EndIf

							nTotal += DetProva( nHdlPrv,;
							cPadrao,;
							"FINA200" /*cPrograma*/,;
							cLote,;
							/*nLinha*/,;
							/*lExecuta*/,;
							/*cCriterio*/,;
							/*lRateio*/,;
							/*cChaveBusca*/,;
							/*aCT5*/,;
							/*lPosiciona*/,;
							@aFlagCTB,;
							/*aTabRecOri*/,;
							/*aDadosProva*/ )

							If LanceiCtb .And. !lUsaFlag

								oModelBxC:SetOperation( MODEL_OPERATION_UPDATE ) //AlteraÁ„o
								oModelBxC:Activate()
								oModelBxC:SetValue( "MASTER", "E5_GRV", .T. ) //habilita gravaÁ„o de SE5

								//Posiciona a FKA com base no IDORIG da SE5 posicionada
								oSubFKA := oModelBxC:GetModel( "FKADETAIL" )
								If oSubFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )

									//Dados do movimento
									oSubFK5 := oModelBxC:GetModel( "FK5DETAIL" )
									oSubFK5:SetValue( "FK5_LA", "S")

									If oModelBxC:VldData()
										oModelBxC:CommitData()
									Else
										lRet := .F.
										cLog := cValToChar(oModelBxC:GetErrorMessage()[4]) + ' - '
										cLog += cValToChar(oModelBxC:GetErrorMessage()[5]) + ' - '
										cLog += cValToChar(oModelBxC:GetErrorMessage()[6])

										Help( ,,"M030_FA200Rejei",,cLog, 1, 0 )
									Endif
								Endif
								oModelBxC:DeActivate()

							EndIf

						Endif

						///fffffffffffffffffffffffffffffffo
						//> Credito em C.Corrente -> gera >
						//> arquivo de reciclagem         >
						//?fffffffffffffffffffffffffffffffY
						If SEB->EB_OCORR $ "39"
							If lRecicl
								If !lFirst
									lFirst := .T.
								EndIf
								Fa200GrRec(cNsNum, @nHdlRecic)
								dbSelectArea("SE1")
								RecLock("SE1")
								Replace E1_OCORREN With "02"
								MsUnlock()
							EndIf
						EndIf
					Endif

					If lBxCnab
						nTotDesp += nDespes
						nTotOutD += nOutrDesp
					Else
						IF nDespes > 0 .or. nOutrDesp > 0		//Tarifas diversas
							Fa200Tarifa()
						Endif
					Endif

					If SEB->EB_OCORR == "02"			// Confirmac„o
						RecLock("SE1")
						SE1->E1_OCORREN := "01"
						If Empty(SE1->E1_NUMBCO)
							SE1->E1_NUMBCO  := cNsNUM
						EndIf
						MsUnLock()
						If lFa200_02
							ExecBlock("FA200_02",.f.,.f.)
						Endif
					Endif

					//Grava alteracao da data de vencto quando for o caso
					If SEB->EB_OCORR $ "14" .and. !Empty(dDtVc)  //Alteracao de Vencto
						RecLock("SE1")
						Replace SE1->E1_VENCTO With dDtVc
						Replace SE1->E1_VENCREA With DataValida(dDtVc,.T.)
						MsUnlock()
					Endif

					//Trecho incluido para integraÁ„o e-commerce
					If  lBaixou
						If  LJ861EC01(SE1->E1_NUM, SE1->E1_PREFIXO, .T./*PrecisaTerPedido*/, SE1->E1_FILORIG)
							LJ861EC02(SE1->E1_NUM, SE1->E1_PREFIXO, SE1->E1_FILORIG)
						EndIf
					EndIf

					// Retorno Automatico via Job
					// armazena os dados do titulo para emissao de relatorio de processamento
					if lExecJob
						If lBaixou
							Aadd(aFa205R,{SE1->E1_NUM,		SE1->E1_CLIENTE, 	SE1->E1_LOJA, dDataCred,	SE1->E1_VALOR, nValRec, "Baixado ok" })
						Else
							Aadd(aFa205R,{SE1->E1_NUM,		SE1->E1_CLIENTE, 	SE1->E1_LOJA, dDataCred,	SE1->E1_VALOR, nValRec, cStProc })
						Endif
					Endif

					//Instrucao de alteracao de carteira de cobranÁa
					IF SEB->EB_OCORR $ "90#91#93#94#95#96#9F#9G#9H" .And. SE1->E1_SITUACA != "2"
						F200TRFCOB(SEB->EB_OCORR,cBanco,cAgencia,cConta)
					Endif

				EndIf

			Endif
			// evitando problemas de processamento
			If lExecJob
				Sleep(500)
			Endif

			//IntegraÁ„o Protheus X TIN
			If !lSai .And. lBaixou
				ALTERA := .T. //Variavel passada como .T. para chamada do FINI070 entender que » baixa.

				If lIntRm
					aRetInteg := FwIntegDef( 'FINA070', , , , 'FINA070' )
					//Se der erro no envio da integraÁ„o, ent„o faz rollback e apresenta mensagem em tela para o usu∑rio
					If ValType(aRetInteg) == "A" .AND. Len(aRetInteg) >= 2 .AND. !aRetInteg[1]
						If ! IsBlind()
							Help( ,, "FINA070INTEGDEL",, STR0046 + AllTrim( aRetInteg[2] ), 1, 0,,,,,, {STR0047} ) //"O registro nao ser∑ baixado, pois ocorreu um erro na integraÁ„o: ", "Verifique se a integraÁ„o est∑ configurada corretamente."
						Endif
						DisarmTransaction()

						If lFI0InDic
							FI0->(DbSetOrder(2))// Verifica se o numero do arquivo j∑ foi gravado, para voltar.
							If FI0->(FI0_FILIAL+FI0_BCO+FI0_AGE+FI0_CTA+AllTrim(cArquivo)) == xFilial("FI0")+cBanco+cAgencia+cConta+AllTrim(cArquivo)
								RecLock("FI0",.F.,.T.)
								FI0->( dbDelete() )
							Endif
						Endif

						Return .F.
					Endif
				ElseIf lMU070
					FwIntegDef( 'FINA070', , , , 'FINA070' )
				EndIf

				ALTERA := lAltera
			Endif

			If lBaixou
				//numbor
				aAlt := {}
				aadd( aAlt,{ STR0044,'','','',STR0045 + Alltrim(Transform(nValRec,PesqPict("SE1","E1_VALOR"))) })
				//chamada da FunÁ„o que cria o Hist€rico de CobranÁa
				FinaCONC(aAlt)
			endif

		END TRANSACTION

		If !lSai
			// Avanca uma linha do arquivo retorno
			If MV_PAR12 == 1
				nLidos		+= nTamDet
				nLinRead	:= 0
			EndIf

			If lF200GLOG
				lPELog := Execblock("F200GLOG",.f.,.f.)
				If valtype(lPELog) != "L"
					lPElog := .F.
				endIF
			Endif
			// Se baixou o titulo e existir o arquivo de LOG, grava as informacoes pertinentes
			// Para futuro reprocessamento se preciso for.
			If (lBaixou .or. lPELog) .And. lFI0InDic
				Fa200GrvLog(2, cArqEnt, cBanco, cAgencia, cConta, nLastLn,If(Empty(SE1->E1_IDCNAB), SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO), SE1->E1_IDCNAB), SEB->EB_REFBAN, SEB->EB_OCORR, cIdArq )
			Endif

			///ffffffffffffffffffffffffffffffffffo
			//> Possibilita alterar algumas das  >
			//> variÜveis utilizadas pelo CNAB.  >
			//?ffffffffffffffffffffffffffffffffffY
			If lF200Tit
				ExecBlock("F200TIT",.F.,.F.)
			Endif

		EndIf

		BEGIN TRANSACTION

			If lIntRm .And. !lSai .And. lBaixou

				//Retorna o valor recebido a maior, em relaÁ„o ao saldo do tÃtulo (baixa via CNAB - integraÁ„o Protheus x RM Educacional)
				nValorAux := GetCredRM()

				If nValorAux > 0
					lMsErroAuto := .F.
					SE1->( dbSetOrder( 1 ) ) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
					cTitPai := SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)

					aTit := {}
					AADD( aTit, {"E1_FILIAL" , xFilial("SE1") , NIL} )
					AADD( aTit, {"E1_PREFIXO", cPrefRM        , NIL} )
					AADD( aTit, {"E1_NUM"	 , SE1->E1_NUM    , NIL} )
					AADD( aTit, {"E1_PARCELA", SE1->E1_PARCELA, NIL} )
					AADD( aTit, {"E1_TIPO"   , SE1->E1_TIPO   , NIL} )
					AADD( aTit, {"E1_CLIENTE", SE1->E1_CLIENTE, NIL} )
					AADD( aTit, {"E1_LOJA"   , SE1->E1_LOJA   , NIL} )
					AADD( aTit, {"E1_NATUREZ", SE1->E1_NATUREZ, NIL} )
					AADD( aTit, {"E1_PORTADO", cBanco         , NIL} )
					AADD( aTit, {"E1_AGEDEP" , cAgencia       , NIL} )
					AADD( aTit, {"E1_CONTA"  , cConta         , NIL} )
					AADD( aTit, {"E1_EMISSAO", SE1->E1_EMISSAO, NIL} )
					AADD( aTit, {"E1_EMIS1"	 , SE1->E1_EMIS1  , NIL} )
					AADD( aTit, {"E1_VENCTO" , SE1->E1_VENCTO , NIL} )
					AADD( aTit, {"E1_VENCREA", SE1->E1_VENCREA, NIL} )
					AADD( aTit, {"E1_VALOR"  , nValorAux      , NIL} )
					AADD( aTit, {"E1_VLCRUZ" , nValorAux      , NIL} )
					AADD( aTit, {"E1_SALDO"  , nValorAux      , NIL} )
					AADD( aTit, {"E1_MOEDA"  , 1              , NIL} )
					AADD( aTit, {"E1_SITUACA", "0"            , NIL} )
					AADD( aTit, {"E1_STATUS" , "A"            , NIL} )
					AADD( aTit, {"E1_ORIGEM" , "FINA200"      , NIL} )
					AADD( aTit, {"E1_FLUXO"  , "S"            , NIL} )
					AADD( aTit, {"E1_MULTNAT", "2"            , NIL} )
					AADD( aTit, {"E1_PROJPMS", "2"            , NIL} )
					AADD( aTit, {"E1_TITPAI" , cTitPai        , NIL} )

					// Inclus„o
					MSExecAuto({|x, y| FINA040(x, y)}, aTit, 3)

					If  lMsErroAuto
						MostraErro()
						DisarmTransaction()
					EndIf

					aTit := {}
					If !lMsErroAuto
						AADD( aTit, {"E1_PREFIXO"  , SE1->E1_PREFIXO, Nil} )
						AADD( aTit, {"E1_NUM"      , SE1->E1_NUM    , Nil} )
						AADD( aTit, {"E1_PARCELA"  , SE1->E1_PARCELA, Nil} )
						AADD( aTit, {"E1_TIPO"     , SE1->E1_TIPO   , Nil} )
						AADD( aTit, {"E1_CLIENTE"  , SE1->E1_CLIENTE, NIL} )
						AADD( aTit, {"E1_LOJA"     , SE1->E1_LOJA   , NIL} )
						AADD( aTit, {"E1_NATUREZ"  , SE1->E1_NATUREZ, NIL} )
						AADD( aTit, {"AUTBANCO"    , SE1->E1_PORTADO, NIL} )
						AADD( aTit, {"AUTAGENCIA"  , SE1->E1_AGEDEP , NIL} )
						AADD( aTit, {"AUTCONTA"    , SE1->E1_CONTA  , NIL} )
						AADD( aTit, {"E1_MOEDA"    , 1              , NIL} )
						AADD( aTit, {"AUTMOTBX"    , "NOR"          , Nil} )
						AADD( aTit, {"AUTDTBAIXA"  , dBaixa         , Nil} )
						AADD( aTit, {"AUTDTCREDITO", dDataCred      , Nil} )
						AADD( aTit, {"AUTVALREC"   , SE1->E1_VALOR  , Nil} )

						MSExecAuto({|x, y| FINA070(x, y)}, aTit, 3)

						// recarrega os mv_parx da rotina fina200, pois foi alterado no fina070
						Pergunte( cPerg, .F. )

						If  lMsErroAuto
							MostraErro()
							DisarmTransaction()
						EndIf
					Endif
				Endif
			Endif

		END TRANSACTION

	Enddo

	///ffffffffffffffffffffffffffffffffffffffffffffffffo
	//> Finaliza a gravacao dos lancamentos do SIGAPCO >
	//?ffffffffffffffffffffffffffffffffffffffffffffffffY
	PcoFinLan("000004")

	If lCabec .and. lPadrao .and. lContabiliza
		dbSelectArea("SE1")
		SE1->(dbGoBottom())
		SE1->(dbSkip())

		dbSelectArea("SE5")
		nRegSE5 := SE5->(Recno())
		SE5->(dbGoBottom())
		SE5->(dbSkip())

		VALOR := nTotAger
		ABATIMENTO := 0
		PIS			:= 0
		COFINS		:= 0
		CSLL		:= 0
		//nTotal+=DetProva(nHdlPrv,cPadrao,"FINA200",cLote)
		nTotal += DetProva( nHdlPrv,;
		cPadrao,;
		"FINA200" /*cPrograma*/,;
		cLote,;
		/*nLinha*/,;
		/*lExecuta*/,;
		/*cCriterio*/,;
		/*lRateio*/,;
		/*cChaveBusca*/,;
		/*aCT5*/,;
		/*lPosiciona*/,;
		@aFlagCTB,;
		/*aTabRecOri*/,;
		/*aDadosProva*/ )

		dbSelectArea("SE5")
		dbGoto(nRegSE5)
	Endif

	If l200Fil .and. lfa200F1
		Execblock("FA200F1",.f.,.f.)
	Endif

	If lTF200Fim
		ExecTemplate("F200FIM",.f.,.f.)
	Endif
	If lF200Fim
		Execblock("F200FIM",.f.,.f.)
	Endif

	///ffffffffffffffffffffffffffffffffffffffffffffffffffffffo
	//> Grava no SEE o n˙mero do ˙ltimo lote recebido e gera >
	//> movimentacao bancaria											>
	//?ffffffffffffffffffffffffffffffffffffffffffffffffffffffY
	If !Empty(cLoteFin) .and. lBxCnab
		RecLock("SEE",.F.)
		SEE->EE_LOTE := cLoteFin
		MsUnLock()
		//MOVIMENTOS TOTALIZADORES
		If TRB->(Reccount()) > 0
			dbSelectArea("TRB")
			dbGoTop()

			While !Eof()
				cFilAnt := TRB->FILMOV

				//Define os campos que nao existem na FK5 e que ser„o gravados apenas na E5, para que a gravaÁ„o da E5 continue igual
				//Estrutura para o E5_CAMPOS: "{{'SE5->CAMPO', Valor}, {'SE5->CAMPO', Valor}}"
				cCamposE5 := "{"
				cCamposE5 += "{'E5_DTDIGIT'	,STOD('" + DToS(TRB->DATAC)	+ "')}"
				cCamposE5 += ",{'E5_LOTE'	,'" + cLoteFin				+ "' }"
				cCamposE5 += ",{'E5_TIPODOC',' ' } "
				cCamposE5 += "}"

				//Model de Movimento Banc∑rio
				oModelMov:SetOperation( MODEL_OPERATION_INSERT )			//Inclusao
				oModelMov:Activate()										//Ativa o modelo de dados
				oModelMov:SetValue( "MASTER","E5_GRV"	, .T.		)	//Informa se vai gravar SE5 ou nao
				oModelMov:SetValue( "MASTER", "NOVOPROC", .T.		)	//Informa que a inclus„o ser∑ feita com um novo n˙mero de processo
				oModelMov:SetValue( "MASTER","E5_CAMPOS", cCamposE5	)	//Informa os campos da SE5 que ser„o gravados indepentes de FK5

				oSubFK5 := oModelMov:GetModel( "FK5DETAIL" )
				oSubFKA := oModelMov:GetModel("FKADETAIL")

				oSubFKA:SetValue( "FKA_IDORIG", FWUUIDV4() )
				oSubFKA:SetValue( "FKA_TABORI", "FK5" )

				//Informacoes do movimento
				oSubFK5:SetValue( "FK5_ORIGEM"	,FunName() )
				oSubFK5:SetValue( "FK5_DATA"	,TRB->DATAC )
				oSubFK5:SetValue( "FK5_VALOR"	,(TRB->TOTAL + nValtot) )
				oSubFK5:SetValue( "FK5_RECPAG"	,"R" )
				oSubFK5:SetValue( "FK5_MOEDA"	,TRB->MOEDA )
				oSubFK5:SetValue( "FK5_NATURE"	,TRB->NATURE )
				oSubFK5:SetValue( "FK5_BANCO"	,cBanco )
				oSubFK5:SetValue( "FK5_AGENCI"	,cAgencia )
				oSubFK5:SetValue( "FK5_CONTA"	,cConta )
				oSubFK5:SetValue( "FK5_DTDISP"	,TRB->DATAC )
				oSubFK5:SetValue( "FK5_HISTOR"	,STR0011 + " " + cLoteFin ) // "Baixa por Retorno CNAB / Lote :"
				oSubFK5:SetValue( "FK5_TPDOC"	,"VL" ) //Colocado pois este movimento nao gera TIPODOC necess∑rio para adequacao
				oSubFK5:SetValue( "FK5_FILORI"	,cFilAnt )
				oSubFK5:SetValue( "FK5_LA"		,"S" ) //Esse movimento nao deve ser contabilizado
				oSubFK5:SetValue( "FK5_LOTE"	,cLoteFin )
				If SpbInUse()
					oSubFK5:SetValue( "FK5_MODSPB", "1" )
				Endif

				If oModelMov:VldData()
					oModelMov:CommitData()
					dbselectarea("SE5")
					Dbsetorder(7)
					DBSEEK(xFilial("SE5")+ SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + SE1->E1_CLIENTE + SE1->E1_LOJA)
				Else
					lRet := .F.
					cLog := cValToChar(oModelMov:GetErrorMessage()[4]) + ' - '
					cLog += cValToChar(oModelMov:GetErrorMessage()[5]) + ' - '
					cLog += cValToChar(oModelMov:GetErrorMessage()[6])

					Help( ,,"M030_FA200Ger",,cLog, 1, 0 )
				Endif

				///ffffffffffffffffffffffffffffffffffffffffffffffffffffffo
				//> Gravacao complementar dos dados da baixa aglutinada  >
				//?ffffffffffffffffffffffffffffffffffffffffffffffffffffffY
				If lF200BXAG
					Execblock("F200BXAG",.f.,.f.)
				Endif

				///fffffffffffffffffffffffffffffffo
				//> Atualiza saldo bancario.      >
				//?fffffffffffffffffffffffffffffffY
				AtuSalBco(cBanco,cAgencia,cConta,SE5->E5_DATA,SE5->E5_VALOR,"+")
				dbSelectArea("TRB")
				dbSkip()
			Enddo

		Endif
		If nTotDesp > 0 .Or. nTotOutD > 0
			Fa200Tarifa(nTotDesp, nTotOutD)
		Endif
		If nTotValCC > 0
			fa200Outros(nTotValCC)
		Endif
	EndIf

	cFilAnt := cFilOrig					// sempre restaura a filial original

	//Contabilizo totalizador das despesas banc∑rias e outros creditos
	If !lBxCnab

		VALOR2 := nCtDesp
		VALOR3 := nCtOutCrd

		dbSelectArea("SE5")
		nRegSE5 := SE5->(Recno())
		dbGoBottom()
		dbSkip()

		lPadrao := VerPadrao("562")		// Movimentacao BancÜria a Pagar
		lContabiliza:= Iif(mv_par11==1,.T.,.F.)

		If !lCabec .and. lPadrao .and. lContabiliza
			nHdlPrv := HeadProva( cLote,;
			"FINA200",;
			substr( cUsuario, 7, 6 ),;
			@cArquivo )
			lCabec := .T.
		Endif

		If lCabec .and. lPadrao .and. lContabiliza
			//Total de Despesas e Outras despesas
			nTotal += DetProva( nHdlPrv,;
			"562",;
			"FINA200" /*cPrograma*/,;
			cLote,;
			/*nLinha*/,;
			/*lExecuta*/,;
			/*cCriterio*/,;
			/*lRateio*/,;
			/*cChaveBusca*/,;
			/*aCT5*/,;
			/*lPosiciona*/,;
			@aFlagCTB,;
			/*aTabRecOri*/,;
			/*aDadosProva*/ )

			//Total de Outros Cr»ditos
			nTotal += DetProva( nHdlPrv,;
			"563",;
			"FINA200" /*cPrograma*/,;
			cLote,;
			/*nLinha*/,;
			/*lExecuta*/,;
			/*cCriterio*/,;
			/*lRateio*/,;
			/*cChaveBusca*/,;
			/*aCT5*/,;
			/*lPosiciona*/,;
			@aFlagCTB,;
			/*aTabRecOri*/,;
			/*aDadosProva*/ )
		Endif

		dbSelectArea("SE5")
		dbGoto(nRegSE5)

		PCODetLan("000007","11","FINA200")

		VALOR2 := VALOR3 := 0

	Endif

	IF lCabec .and. nTotal > 0
		RodaProva(  nHdlPrv,;
		nTotal )

		///fffffffffffffffffffffffffffffffffffffffffffffffffffffo
		//> Envia para Lancamento Contabil                      >
		//?fffffffffffffffffffffffffffffffffffffffffffffffffffffY
		cA100Incl( cArquivo,;
		nHdlPrv,;
		3 /*nOpcx*/,;
		cLote,;
		lDigita,;
		lAglut,;
		/*cOnLine*/,;
		/*dData*/,;
		/*dReproc*/,;
		@aFlagCTB,;
		/*aDadosProva*/,;
		/*aDiario*/ )

		aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento
	Endif

	PcoFinLan("000007")

	If lRecicl
		If lFirst
			FClose(nHdlRecic)
		Endif
		If cIndex != " "
			RetIndex("SE1")
			Set Filter To
			FErase (cIndex+OrdBagExt())
		EndIf
	Endif

	dbSelectArea("TRB")
	dbCloseArea()
	if lExecJob
		Sleep(2000)
	Endif

	VALOR := 0
	ABATIMENTO := 0

	SM0->(dbGoTo(nRegEmp))
	cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )

	dbSelectArea( "SE1" )
	dbSetOrder(1)
	dbGoTo( nSavRecno )
	If lF200IMP
		ExecBlock("F200IMP",.F.,.F.)
	Endif

	If oModelMov != NIL
		oModelMov:Destroy()
		oModelMov := Nil
		oSubFK5 := Nil
		oSubFKA := Nil
	EndIf

	If oModelBxC != NIL
		oModelBxC:Destroy()
		oModelBxC := Nil
	EndIf

Return .F.

/*/
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++/ffffffffff-ffffffffff-fffffff-fffffffffffffffffffffff-ffffff-ffffffffffo++
++>FunÁ÷o    >fA200Par  > Autor > Wagner Xavier         > Data > 26/05/92 >++
++Vffffffffff=ffffffffff°fffffff°fffffffffffffffffffffff°ffffff°ffffffffffY++
++>DescriÁ÷o >Aciona parametros do Programa                               >++
++Vffffffffff=ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
++> Uso      > Generico                                                   >++
++?ffffffffff°ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
*/
Function fA200Par()
	Pergunte( cPerg )
	MV_PAR04 := UPPER(MV_PAR04)
Return .T.

/*/
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++/ffffffffff-ffffffffff-fffffff-fffffffffffffffffffffff-ffffff-ffffffffffo++
++>FunÁ÷o    >fA200Rejei> Autor > Wagner Xavier         > Data > 26/05/92 >++
++Vffffffffff=ffffffffff°fffffff°fffffffffffffffffffffff°ffffff°ffffffffffY++
++>DescriÁ÷o >Trata titulo rejeitado.                                     >++
++Vffffffffff=ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
++>Sintaxe   >fa200Rejei                                                  >++
++Vffffffffff=ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
++> Uso      > Generico                                                   >++
++?ffffffffff°ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
*/
Function fa200Rejei(cMotivo,cOcorr)
	Local cAlias		:= Alias()
	Local lRet			:= .F.
	Local lPadrao		:= .f.
	Local cNumBor		:= " "
	Local cLog			:= ""
	Local cCamposE5	:= ""
	Local oModelRej  := Nil
	Local oSubFKARej := Nil
	local oSubFK5Rej := Nil

	Private cSituant:= "0"									// Private para permitir condicionamento para contabilizaÁ„o

	Default cOcorr := ""

	dbSelectArea("SEB")
	dbSetOrder(1)
	// Procura pela chave completa->filial+banco+ocorrencia+tipo+motivo banco
	If dbSeek(xFilial("SEB")+mv_par06+cOcorr+"R"+cMotivo)
		IF SEB->EB_MOTSIS == "01" .OR. EMPTY(SEB->EB_MOTSIS)	// Titulo protestado ou nao pago
			dbSelectArea("SEA")											// Retorna p/ carteira
			dbSetOrder(1)
			If dbSeek(xFilial("SEA")+SE1->E1_NUMBOR+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)
				Reclock( "SEA" , .F. , .T.)
				SEA->(dbDelete( ))
				MsUnlock()
			EndIf
			///fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffo
			//> PONTO DE ENTRADA FA280RE2                                     >
			//> Tratamento de dados de titulo rejeitado antes de "zerar" os 	>
			//> dados do mesmo.                                               >
			//?fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY
			If lFA200RE2
				Execblock("FA200RE2",.F.,.F.)
			Endif
			cSituant := SE1->E1_SITUACA
			cNumBor := SE1->E1_NUMBOR
			Reclock( "SE1" )
			SE1->E1_SITUACA := "0"
			SE1->E1_PORTADO := Space(Len(SE1->E1_PORTADO) )
			SE1->E1_AGEDEP  := Space(Len(SE1->E1_AGEDEP ) )
			SE1->E1_CONTA   := Space(Len(SE1->E1_CONTA  ) )
			SE1->E1_DATABOR := CtoD ( "" )
			SE1->E1_NUMBOR  := Space(Len(SE1->E1_NUMBOR ) )
			SE1->E1_NUMBCO  := Space(Len(SE1->E1_NUMBCO ) )
			SE1->E1_OCORREN := "01"
			lRet := .T.
			MsUnlock()

			///fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffo
			//>Efetua a contabilizacao da transferencia para carteira, caso   >
			//>exista este lancamento padrao, pois se nao for feito neste mo- >
			//>mento nao havera registro da rejeicao.                         >
			//?fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY
			lPadrao:=VerPadrao("540")
			If !lCabec .and. lPadrao
				nHdlPrv := HeadProva( cLote,;
				"FINA200",;
				substr( cUsuario, 7, 6 ),;
				@cArquivo )

				lCabec := .T.
			Endif

			If lCabec .and. lPadrao
				nTotal += DetProva( nHdlPrv,;
				"540",;
				"FINA200" /*cPrograma*/,;
				cLote,;
				/*nLinha*/,;
				/*lExecuta*/,;
				/*cCriterio*/,;
				/*lRateio*/,;
				/*cChaveBusca*/,;
				/*aCT5*/,;
				/*lPosiciona*/,;
				@aFlagCTB,;
				/*aTabRecOri*/,;
				/*aDadosProva*/ )

				// Forca a contabilizacao da rejeicao on-line pois nao e registrada
				// a transferencia para a carteira
				lDigita := .T.
			Endif

			If FN022SITCB( cSituAnt )[3]	//  'Se cobranca descontada e rejeita gera um movimento a pagar"

				//Define os campos que nao existem na FK5 e que ser„o gravados apenas na E5, para que a gravaÁ„o da E5 continue igual
				//Estrutura para o E5_CAMPOS: "{{'SE5->CAMPO', Valor}, {'SE5->CAMPO', Valor}}"
				cCamposE5 := "{"
				cCamposE5 += "{'E5_DTDIGIT'	,STOD('" + DTOS(dDataBase) + "')}"
				cCamposE5 += "}"

				//Model de Movimento Banc∑rio
				oModelRej := FWLoadModel("FINM030")
				oModelRej:SetOperation( MODEL_OPERATION_INSERT )			//Inclusao
				oModelRej:Activate()										//Ativa o modelo de dados
				oModelRej:SetValue( "MASTER","E5_GRV"		, .T.		)	//Informa se vai gravar SE5 ou nao
				oModelRej:SetValue( "MASTER", "NOVOPROC"	, .T.		)	//Informa que a inclus„o ser∑ feita com um novo n˙mero de processo
				oModelRej:SetValue( "MASTER","E5_CAMPOS"	,cCamposE5	)	//Informa os campos da SE5 que ser„o gravados indepentes de FK5

				oSubFKARej := oModelRej:GetModel("FKADETAIL")
				oSubFKARej:SetValue( "FKA_IDORIG", FWUUIDV4() )
				oSubFKARej:SetValue( "FKA_TABORI", "FK5" )

				//Informacoes do movimento
				oSubFK5Rej := oModelRej:GetModel( "FK5DETAIL" )
				oSubFK5Rej:SetValue( "FK5_ORIGEM"	,FunName() )
				oSubFK5Rej:SetValue( "FK5_DATA"		,dBaixa )
				oSubFK5Rej:SetValue( "FK5_VALOR"	,nValrec )
				oSubFK5Rej:SetValue( "FK5_VLMOE2"	,nValrec )
				oSubFK5Rej:SetValue( "FK5_RECPAG"	,"P" )
				oSubFK5Rej:SetValue( "FK5_BANCO"	,cBanco )
				oSubFK5Rej:SetValue( "FK5_AGENCI"	,cAgencia )
				oSubFK5Rej:SetValue( "FK5_CONTA"	,cConta )
				oSubFK5Rej:SetValue( "FK5_DTDISP"	,dBaixa )
				oSubFK5Rej:SetValue( "FK5_HISTOR"	,"EST. " + cNumBor+" "+SE1->E1_PREFIXO+" "+SE1->E1_NUM+" "+SE1->E1_PARCELA+" "+SE1->E1_TIPO )
				oSubFK5Rej:SetValue( "FK5_MOEDA"	,STRZero(SE1->E1_MOEDA,2))
				oSubFK5Rej:SetValue( "FK5_NATURE"	,SE1->E1_NATUREZ)
				oSubFK5Rej:SetValue( "FK5_TPDOC"	,"ES"			)
				If SpbInUse()
					oSubFK5Rej:SetValue( "FK5_MODSPB", "1" )
				Endif

				If oModelRej:VldData()
					oModelRej:CommitData()
				Else
					lRet := .F.
					cLog := cValToChar(oModelRej:GetErrorMessage()[4]) + ' - '
					cLog += cValToChar(oModelRej:GetErrorMessage()[5]) + ' - '
					cLog += cValToChar(oModelRej:GetErrorMessage()[6])

					Help( ,,"M030_FA200Rejei",,cLog, 1, 0 )
				Endif
				oModelRej:DeActivate()

				AtuSalBco(cBanco,cAgencia,cConta,SE5->E5_DATA,SE5->E5_VALOR,"-")

				lPadrao:=VerPadrao("562")
				If !lCabec .and. lPadrao
					nHdlPrv := HeadProva( cLote,;
					"FINA200",;
					substr( cUsuario, 7, 6 ),;
					@cArquivo )
					lCabec := .T.
				Endif

				If lCabec .and. lPadrao

					If lUsaFlag // Armazena em aFlagCTB para atualizar no modulo Contabil
						aAdd( aFlagCTB, { "E5_LA", "S", "SE5", SE5->( RecNo() ), 0, 0, 0} )
					EndIf

					nTotal += DetProva( nHdlPrv,;
					"562",;
					"FINA200" /*cPrograma*/,;
					cLote,;
					/*nLinha*/,;
					/*lExecuta*/,;
					/*cCriterio*/,;
					/*lRateio*/,;
					/*cChaveBusca*/,;
					/*aCT5*/,;
					/*lPosiciona*/,;
					@aFlagCTB,;
					/*aTabRecOri*/,;
					/*aDadosProva*/ )

					If LanceiCtb .And. !lUsaFlag
						RecLock("SE5")
						SE5->E5_LA := "S"
						MsUnLock()

						dbSelectArea( "FK5" )
						FK5->( DbSetOrder( 1 ) )//FK5_FILIAL+FK5_IDMOV
						If SE5->E5_TABORI== "FK5" .AND. MsSeek( xFilial("FK5") + SE5->E5_IDORIG )
							RecLock("FK5")
							FK5->FK5_LA := "S"
							MsUnlock()
						Endif
					EndIf
					// Forca a contabilizacao da rejeicao on-line pois nao e registrada
					// a transferencia para a carteira
					lDigita := .T.
				Endif

				oModelRej:Destroy()
				oModelRej  := Nil
				oSubFKARej := Nil
				oSubFK5Rej := Nil
			EndIf
		Endif

		//DDA - Debito Direto Autorizado
		If Alltrim(cOcorr) $ "53/52"
			Reclock("SE1")
			SE1->E1_OCORREN := cOcorr
			MsUnlock()
		Endif

	EndIf

	///fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffo
	//> PONTO DE ENTRADA FA280REJ                                     >
	//> Tratamento de dados de titulo rejeitado                     	>
	//?fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY
	If lFA200REJ
		Execblock("FA200REJ",.F.,.F.)
	Endif
	MsUnlock()
	dbSelectArea( cAlias )
Return lRet

/*/
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++/ffffffffff-ffffffffff-fffffff-fffffffffffffffffffffff-ffffff-ffffffffffo++
++>FunÁ÷o    >fA200Tarif> Autor > Wagner Xavier         > Data > 26/05/92 >++
++Vffffffffff=ffffffffff°fffffff°fffffffffffffffffffffff°ffffff°ffffffffffY++
++>Descric„o >Trata uma determinada tarifa.                               >++
++Vffffffffff=ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
++>Sintaxe   >fa200Tarifa( )                                              >++
++Vffffffffff=ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
++> Uso      >Generico                                                    >++
++?ffffffffff°ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
*/
Function fa200Tarifa(nTotDesp, nTotOutD)

	Local cAlias		:= Alias()
	Local lPadrao		:= VerPadrao("562")		// Movimentacao BancÜria a Pagar
	Local lContabiliza	:= Iif(mv_par11==1,.T.,.F.)
	Local cNat			:= ""
	Local nX			:= 0
	Local cLog			:= ""
	Local lRet			:= .T.
	Local cCamposE5		:= ""
	Local cChaveTit		:= ""
	Local cHistorDB		:= ""
	Local cChaveFK7 	:= ""
	Local cLoteDB		:= ""
	Local cAliasQry 	:= GetNextAlias()
	Local cQuery    	:= ""
	Local nCount		:= 0
	Local cAliasQry1 	:= GetNextAlias()
	Local nCount1		:= 0
	Local lSEmcFIL 	:= (FWMODEACCESS("SE1",mcFIL) == 'C') .and. (FWMODEACCESS("SE5",mcFIL) == 'C')// nÃvel de compartilhamento familia SE
	Local oModelTar	:= NIL
	Local oSubFKATar := Nil
	Local oSubFK5Tar := Nil

	nDespes   := If(nTotDesp == Nil, nDespes  , nTotDesp)
	nOutrDesp := If(nTotOutD == Nil, nOutrDesp, nTotOutD)

	If nDespes > 0 .or. nOutrDesp > 0

		oModelTar := FWLoadModel("FINM030")

		///fffffffffffffffffffffffffffffffffffffffffffffffffffffffffo
		//> Calcula a data de credito, se esta estiver vazia			>
		//> Se aplica apenas nos casos de confirmas„o de entrada do	>
		//> titulo e tenha lancamento de Despesas BancÜrias, pois 	>
		//> nas ocorrencias de baixa, essa data ja estara calculada >
		//?fffffffffffffffffffffffffffffffffffffffffffffffffffffffffY

		If dDataCred == Nil .Or. Empty(dDataCred)
			dDataCred := If(!Empty(dBaixa),dBaixa,SE5->E5_DATA)  // Assume a data da baixa ou a data do movimento totalizador
			dBaixa := If(!Empty(dBaixa),DataValida(dBaixa,.T.),DataValida(SE5->E5_DATA,.T.))
			If !__lPar17 .Or. (__lPar17 .And. MV_PAR17 == 1)
				For nX := 1 To Sa6->A6_Retenca // Para todos os dias de retencao valida a data
					// O calculo eh feito desta forma, pois os dias de retencao
					// sao dias uteis, e se fosse apenas somado dDataCred+A6_Retenca
					// nao sera verdadeiro quando a data for em uma quinta-feira, por
					// exemplo e, tiver 2 dias de retencao.
					dDataCred := DataValida(dDataCred+1,.T.)
				Next
			EndIf
		EndIf

		// Gera registro na movimentacao bancaria
		cNat := F200VerNat()

		If nDespes > 0  .AND. !EMPTY(dBaixa) .AND. !EMPTY(dDataCred)
			cQuery := " SELECT COUNT(*) TOTDP "
			cQuery += " FROM " + RetSQLName("SE5") + " SE5 "
			//nao considera deletados, estornados ou cancelados
			cQuery += " WHERE D_E_L_E_T_ <> '*' "
			cQuery += " 	AND SE5.E5_SITUACA NOT IN ( 'C' , 'E' , 'X' )   "
			cQuery += " 	AND SE5.E5_TIPODOC <> 'ES'                      "
			// Tipo Desepesas
			cQuery += " 	AND SE5.E5_TIPODOC = 'DB'                       "
			cQuery += " 	AND SE5.E5_MOTBX  = 'NOR'                       "
			// Data de despesas
			cQuery += " 	AND SE5.E5_DTDISPO	= '" + DTOS(dDataCred) + "' "
			cQuery += " 	AND SE5.E5_DATA   	= '" + DTOS(dBaixa)    + "' "
			// Filtro do titulo
			cQuery += " 	AND SE5.E5_FILIAL   = '" + SE1->E1_FILIAL  + "' "
			cQuery += " 	AND SE5.E5_PREFIXO  = '" + SE1->E1_PREFIXO + "' "
			cQuery += " 	AND SE5.E5_NUMERO   = '" + SE1->E1_NUM     + "' "
			cQuery += " 	AND SE5.E5_PARCELA  = '" + SE1->E1_PARCELA + "' "
			cQuery += " 	AND SE5.E5_TIPO     = '" + SE1->E1_TIPO    + "' "
			cQuery += " 	AND SE5.E5_CLIFOR   = '" + SE1->E1_CLIENTE + "' "
			cQuery += " 	AND SE5.E5_LOJA     = '" + SE1->E1_LOJA    + "' "
			cQuery += "     AND SE5.D_E_L_E_T_ <> '*'                       "

			If nTotDesp == Nil
				cQuery += " 	AND SE5.E5_CNABOC = '"+SEB->EB_OCORR+"' "
			EndIf

			cQuery := ChangeQuery( cQuery )

			If Select(cAliasQry) > 0
				( cAliasQRY )->( dbCloseArea() )
			Endif

			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )
			nCount	:= 0

			If ( cAliasQRY )->(!Eof())
				nCount	:= ( cAliasQRY )->TOTDP
			Endif

			If Select(cAliasQry) > 0
				( cAliasQRY )->( dbCloseArea() )
			Endif
		EndIf

		// Despesas Banc∑rias
		If nDespes > 0 .And. nCount == 0

			//Define os campos que nao existem na FK5 e que ser„o gravados apenas na E5, para que a gravaÁ„o da E5 continue igual
			//Estrutura para o E5_CAMPOS: "{{'SE5->CAMPO', Valor}, {'SE5->CAMPO', Valor}}"
			cCamposE5 := "{"
			cCamposE5 += "{'E5_DTDIGIT'	,STOD('" + DTOS(dDataBase) + "')}"
			cCamposE5 += ",{'E5_MOTBX'	,'NOR'		}"
			If nTotDesp # Nil
				cLoteDB := cLoteFin
				cHistorDB := STR0011 + " " + cLoteFin //"Baixa por Retorno CNAB / Lote :"
				cChaveFK7 := ""
			Else
				cCamposE5 += ",{'E5_PREFIXO' ,'" + SE1->E1_PREFIXO	+ "'}"
				cCamposE5 += ",{'E5_NUMERO'	 ,'" + SE1->E1_NUM		+ "'}"
				cCamposE5 += ",{'E5_PARCELA' ,'" + SE1->E1_PARCELA	+ "'}"
				cCamposE5 += ",{'E5_TIPO'	 ,'" + SE1->E1_TIPO		+ "'}"
				cCamposE5 += ",{'E5_CLIFOR'	 ,'" + SE1->E1_CLIENTE	+ "'}"
				cCamposE5 += ",{'E5_LOJA'	 ,'" + SE1->E1_LOJA		+ "'}"
				cCamposE5 += ",{'E5_CNABOC'	 ,'" + SEB->EB_OCORR	+ "'}"
				cLoteDB		:= ""
				cHistorDB	:= SEB->EB_DESCRI
				//Dados da tabela auxiliar com o c€digo do tÃtulo a receber
				cChaveTit	:= xFilial("SE1") + "|" + SE1->E1_PREFIXO 	+ "|" + SE1->E1_NUM 	+ "|" + SE1->E1_PARCELA + "|" + ;
				SE1->E1_TIPO		+ "|" + SE1->E1_CLIENTE + "|" + SE1->E1_LOJA
				cChaveFK7	:= FINGRVFK7( "SE1", cChaveTit )

			EndIf
			cCamposE5 += "}"

			//Model de Movimento Bancario
			oModelTar:SetOperation( MODEL_OPERATION_INSERT )			//Inclusao
			oModelTar:Activate()											//Ativa o modelo de dados
			oModelTar:SetValue( "MASTER","E5_GRV"		,.T.		)	//Informa se vai gravar SE5 ou nao
			oModelTar:SetValue( "MASTER","NOVOPROC"	,.T.		)	//Informa que a inclus„o ser∑ feita com um novo n˙mero de processo
			oModelTar:SetValue( "MASTER","E5_CAMPOS"	,cCamposE5	)	//Informa os campos da SE5 que ser„o gravados indepentes de FK5

			oSubFKATar := oModelTar:GetModel( "FKADETAIL" )
			oSubFKATar:SetValue( 'FKA_IDORIG', FWUUIDV4() )
			oSubFKATar:SetValue( 'FKA_TABORI', "FK5" )

			//Informacoes do movimento
			oSubFK5Tar := oModelTar:GetModel( "FK5DETAIL" )
			oSubFK5Tar:SetValue( "FK5_IDDOC"	,cChaveFK7 )
			oSubFK5Tar:SetValue( "FK5_ORIGEM"	,FunName() )
			oSubFK5Tar:SetValue( "FK5_DATA"		,dBaixa )
			oSubFK5Tar:SetValue( "FK5_VALOR"	,nDespes )
			oSubFK5Tar:SetValue( "FK5_VLMOE2"	,nDespes )
			oSubFK5Tar:SetValue( "FK5_RECPAG"	,"P" )
			oSubFK5Tar:SetValue( "FK5_BANCO"	,SA6->A6_COD )
			oSubFK5Tar:SetValue( "FK5_AGENCI"	,SA6->A6_AGENCIA )
			oSubFK5Tar:SetValue( "FK5_CONTA"	,SA6->A6_NUMCON )
			oSubFK5Tar:SetValue( "FK5_DTDISP"	,dDataCred )
			oSubFK5Tar:SetValue( "FK5_NATURE"	,If(!Empty(cNat),cNat,SE1 -> E1_NATUREZ)	)
			oSubFK5Tar:SetValue( "FK5_TPDOC"	,"DB"	)
			oSubFK5Tar:SetValue( "FK5_LOTE"		,cLoteDB )
			oSubFK5Tar:SetValue( "FK5_FILORI"	,Iif(lSEmcFIL,SE1->E1_FILORIG,cFilAnt) )
			oSubFK5Tar:SetValue( "FK5_HISTOR"	,cHistorDB )
			oSubFK5Tar:SetValue( "FK5_MOEDA"	,StrZero(SE1->E1_MOEDA,2) )
			If SpbInUse()
				oSubFK5Tar:SetValue( "FK5_MODSPB", "1" )
			Endif

			If oModelTar:VldData()
				oModelTar:CommitData()
				SE5->(dbGoto(oModelTar:GetValue( "MASTER", "E5_RECNO" )))
			Else
				lRet := .F.
				cLog := cValToChar(oModelTar:GetErrorMessage()[4]) + ' - '
				cLog += cValToChar(oModelTar:GetErrorMessage()[5]) + ' - '
				cLog += cValToChar(oModelTar:GetErrorMessage()[6])

				Help( ,,"M_200TRFDB",,cLog, 1, 0 )
			Endif
			oModelTar:DeActivate()

			///fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffo
			//> PONTO DE ENTRADA F200DB1                                    >
			//> Serve para tratamento complementar das despesas bancarias.  >
			//?fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY
			IF lF200DB1
				ExecBlock("F200DB1",.F.,.F.)
			Endif

			// Atualiza Saldos Bancarios
			AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DATA,SE5->E5_VALOR,"-")

			// Atualiza Saldos por Natureza FIV / FIW
			AtuSldNat(SE5->E5_NATUREZ, SE5->E5_DATA, "01", "3", "P", nDespes, nDespes,"+",,FunName(),"SE5",SE5->(Recno()))

			If !lCabec .and. lPadrao .and. lContabiliza
				nHdlPrv := HeadProva( cLote,;
				"FINA200",;
				substr( cUsuario, 7, 6 ),;
				@cArquivo )

				lCabec := .T.
			Endif

			dbSelectArea("SE5")

			If lCabec .and. lPadrao .and. lContabiliza

				If lUsaFlag // Armazena em aFlagCTB para atualizar no modulo Contabil
					aAdd( aFlagCTB, { "E5_LA", "S", "SE5", SE5->( RecNo() ), 0, 0, 0} )
				EndIf

				nTotal += DetProva( nHdlPrv,;
				"562",;
				"FINA200" /*cPrograma*/,;
				cLote,;
				/*nLinha*/,;
				/*lExecuta*/,;
				/*cCriterio*/,;
				/*lRateio*/,;
				/*cChaveBusca*/,;
				/*aCT5*/,;
				/*lPosiciona*/,;
				@aFlagCTB,;
				/*aTabRecOri*/,;
				/*aDadosProva*/ )

				If LanceiCtb .And. !lUsaFlag
					RecLock("SE5")
					SE5->E5_LA := "S"
					MsUnLock()

					dbSelectArea( "FK5" )
					FK5->( DbSetOrder( 1 ) )//FK5_FILIAL+FK5_IDMOV
					If SE5->E5_TABORI== "FK5" .AND. MsSeek( xFilial("FK5") + SE5->E5_IDORIG )
						RecLock("FK5")
						FK5->FK5_LA := "S"
						MsUnlock()
					Endif
				EndIf
			Endif
			nCtDesp += nDespes
		Endif

		If nOutrDesp > 0
			cQuery := " SELECT COUNT(*) TOTDP                              "
			cQuery += " FROM "+RetSQLName("SE5") + " SE5                   "
			//nao considera deletados, estornados ou cancelados
			cQuery += " WHERE D_E_L_E_T_ <> '*'                            "
			cQuery += " 	AND SE5.E5_SITUACA NOT IN ( 'C' , 'E' , 'X' )  "
			cQuery += " 	AND SE5.E5_TIPODOC <> 'ES'                     "
			// Tipo Desepesas
			cQuery += " 	AND SE5.E5_TIPODOC = 'OD'                      "
			cQuery += " 	AND SE5.E5_MOTBX  = 'NOR'                      "
			// Data de despesas
			cQuery += " 	AND SE5.E5_DTDISPO = '" + DTOS(dDataCred) + "' "
			cQuery += " 	AND SE5.E5_DATA    = '" + DTOS(dBaixa)    + "' "
			// Filtro do titulo
			cQuery += " 	AND SE5.E5_FILIAL  = '" + SE1->E1_FILIAL  + "' "
			cQuery += " 	AND SE5.E5_PREFIXO = '" + SE1->E1_PREFIXO + "' "
			cQuery += " 	AND SE5.E5_NUMERO  = '" + SE1->E1_NUM     + "' "
			cQuery += " 	AND SE5.E5_PARCELA = '" + SE1->E1_PARCELA + "' "
			cQuery += " 	AND SE5.E5_TIPO    = '" + SE1->E1_TIPO    + "' "
			cQuery += " 	AND SE5.E5_CLIFOR  = '" + SE1->E1_CLIENTE + "' "
			cQuery += " 	AND SE5.E5_LOJA    = '" + SE1->E1_LOJA    + "' "
			cQuery += "     AND SE5.D_E_L_E_T_<> '*' "

			If nTotOutD == Nil
				cQuery += " 	AND SE5.E5_CNABOC = '"+SEB->EB_OCORR+"' "
			EndIf

			cQuery := ChangeQuery( cQuery )

			If Select(cAliasQry1) > 0
				( cAliasQRY1 )->( dbCloseArea() )
			Endif

			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry1, .F., .T. )
			nCount1	:= 0
			IF ( cAliasQRY1 )->(!Eof())
				nCount1	:= ( cAliasQRY1 )->TOTDP
			Endif
			If Select(cAliasQry1) > 0
				( cAliasQRY1 )->( dbCloseArea() )
			Endif
		Endif

		// Outras Despesas
		If nOutrDesp > 0 .AND. nCount1 == 0

			// Gera registro na movimentacao bancaria
			cNat := F200VerNat()

			//Define os campos que nao existem na FK5 e que ser„o gravados apenas na E5, para que a gravaÁ„o da E5 continue igual
			//Estrutura para o E5_CAMPOS: "{{'SE5->CAMPO', Valor}, {'SE5->CAMPO', Valor}}"
			cCamposE5 := "{"
			cCamposE5 += "{'E5_DTDIGIT'	,STOD('" + DTOS(dDataBase) + "')}"
			cCamposE5 += ",{'E5_MOTBX'	,'NOR'		}"
			If nTotOutD # Nil
				cLoteDB		:= cLoteFin
				cHistorDB	:= STR0011 + " " + cLoteFin //"Baixa por Retorno CNAB / Lote :"
				cChaveFK7	:= ""
			Else
				cCamposE5 += ",{'E5_PREFIXO' ,'" + SE1->E1_PREFIXO	+ "'}"
				cCamposE5 += ",{'E5_NUMERO'	 ,'" + SE1->E1_NUM		+ "'}"
				cCamposE5 += ",{'E5_PARCELA' ,'" + SE1->E1_PARCELA	+ "'}"
				cCamposE5 += ",{'E5_TIPO'	 ,'" + SE1->E1_TIPO		+ "'}"
				cCamposE5 += ",{'E5_CLIFOR'	 ,'" + SE1->E1_CLIENTE	+ "'}"
				cCamposE5 += ",{'E5_LOJA'	 ,'" + SE1->E1_LOJA		+ "'}"
				cCamposE5 += ",{'E5_CNABOC'	 ,'" + SEB->EB_OCORR	+ "'}"

				cLoteDB		:= ""
				cHistorDB	:= SEB->EB_DESCRI
				//Dados da tabela auxiliar com o c€digo do tÃtulo a receber
				cChaveTit	:= xFilial("SE1") + "|" + SE1->E1_PREFIXO 	+ "|" + SE1->E1_NUM 	+ "|" + SE1->E1_PARCELA + "|" + ;
				SE1->E1_TIPO		+ "|" + SE1->E1_CLIENTE + "|" + SE1->E1_LOJA
				cChaveFK7	:= FINGRVFK7( "SE1", cChaveTit )

			EndIf
			cCamposE5 += "}"

			//Model de Movimento Bancario
			oModelTar:SetOperation( MODEL_OPERATION_INSERT )			//Inclusao
			oModelTar:Activate()
			oModelTar:SetValue( "MASTER","E5_GRV"		,.T.		)	//Informa se vai gravar SE5 ou nao
			oModelTar:SetValue( "MASTER","NOVOPROC"	,.T.		)	//Informa que a inclus„o ser∑ feita com um novo n˙mero de processo
			oModelTar:SetValue( "MASTER","E5_CAMPOS"	,cCamposE5	)	//Informa os campos da SE5 que ser„o gravados indepentes de FK5

			oSubFKATar := oModelTar:GetModel( "FKADETAIL" )
			oSubFKATar:SetValue( 'FKA_IDORIG', FWUUIDV4() )
			oSubFKATar:SetValue( 'FKA_TABORI', "FK5" )

			//Informacoes do movimento
			oSubFK5 := oModelTar:GetModel( "FK5DETAIL" )

			oSubFK5Tar:SetValue( "FK5_IDDOC"	,cChaveFK7 )
			oSubFK5Tar:SetValue( "FK5_ORIGEM"	,FunName() )
			oSubFK5Tar:SetValue( "FK5_DATA"		,dBaixa )
			oSubFK5Tar:SetValue( "FK5_VALOR"	,nOutrDesp )
			oSubFK5Tar:SetValue( "FK5_VLMOE2"	,nOutrDesp )
			oSubFK5Tar:SetValue( "FK5_RECPAG"	,"P" )
			oSubFK5Tar:SetValue( "FK5_DTDISP"	,dDataCred )
			oSubFK5Tar:SetValue( "FK5_BANCO"	,SA6->A6_COD )
			oSubFK5Tar:SetValue( "FK5_AGENCI"	,SA6->A6_AGENCIA )
			oSubFK5Tar:SetValue( "FK5_CONTA"	,SA6->A6_NUMCON )
			oSubFK5Tar:SetValue( "FK5_NATURE"	,If(!Empty(cNat),cNat,SE1 -> E1_NATUREZ)	)
			oSubFK5Tar:SetValue( "FK5_TPDOC"	,"OD"	)
			oSubFK5Tar:SetValue( "FK5_LOTE"		,cLoteDB )
			oSubFK5Tar:SetValue( "FK5_MOEDA"	,StrZero(SE1->E1_MOEDA,2) )
			oSubFK5Tar:SetValue( "FK5_FILORI"	,Iif(lSEmcFIL,SE1->E1_FILORIG,cFilAnt) )
			oSubFK5Tar:SetValue( "FK5_HISTOR"	,cHistorDB )

			If SpbInUse()
				oSubFK5Tar:SetValue( "FK5_MODSPB", "1" )
			Endif
			If nTotOutD # Nil
				oSubFK5Tar:SetValue( "FK5_BANCO"	,SA6->A6_COD )
				oSubFK5Tar:SetValue( "FK5_AGENCI"	,SA6->A6_AGENCIA )
				oSubFK5Tar:SetValue( "FK5_CONTA"	,SA6->A6_NUMCON )
			Else
				//Dados do Movimento
				oSubFK5Tar:SetValue( "FK5_BANCO"	, If(!Empty(SE1->E1_PORTADO), SE1->E1_PORTADO, SA6->A6_COD     ))
				oSubFK5Tar:SetValue( "FK5_AGENCI"	, If(!Empty(SE1->E1_AGEDEP) , SE1->E1_AGEDEP , SA6->A6_AGENCIA ))
				oSubFK5Tar:SetValue( "FK5_CONTA"	, If(!Empty(SE1->E1_CONTA)  , SE1->E1_CONTA  , SA6->A6_NUMCON  ))
				oSubFK5Tar:SetValue( "FK5_DTDISP"	,dDataCred )
			EndIf

			If oModelTar:VldData()
				oModelTar:CommitData()
				dbselectarea("SE5")
				Dbsetorder(7)
				DBSEEK(xFilial("SE5")+ SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + SE1->E1_CLIENTE + SE1->E1_LOJA)
			Else
				lRet := .F.
				cLog := cValToChar(oModelTar:GetErrorMessage()[4]) + ' - '
				cLog += cValToChar(oModelTar:GetErrorMessage()[5]) + ' - '
				cLog += cValToChar(oModelTar:GetErrorMessage()[6])

				Help( ,,"M_200TRFOD",,cLog, 1, 0 )
			Endif
			oModelTar:DeActivate()

			///fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffo
			//> PONTO DE ENTRADA F200DB2                                    >
			//> Serve para tratamento complementar de outras despesas.      >
			//?fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY
			IF lF200DB2
				ExecBlock("F200DB2",.F.,.F.)
			Endif

			// Atualiza Saldos Bancarios
			AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DATA,SE5->E5_VALOR,"-")

			// Atualiza Saldos por Natureza FIV / FIW
			AtuSldNat(SE5->E5_NATUREZ, SE5->E5_DATA, "01", "3", "P", nOutrDesp, nOutrDesp,"+",,FunName(),"SE5",SE5->(Recno()))

			If !lCabec .and. lPadrao .and. lContabiliza
				nHdlPrv := HeadProva( cLote,;
				"FINA200",;
				substr( cUsuario, 7, 6 ),;
				@cArquivo )

				lCabec := .T.
			Endif

			dbSelectArea("SE5")
			If lCabec .and. lPadrao .and. lContabiliza

				If lUsaFlag // Armazena em aFlagCTB para atualizar no modulo Contabil
					aAdd( aFlagCTB, { "E5_LA", "S", "SE5", SE5->( RecNo() ), 0, 0, 0} )
				EndIf

				nTotal += DetProva( nHdlPrv,;
				"562",;
				"FINA200" /*cPrograma*/,;
				cLote,;
				/*nLinha*/,;
				/*lExecuta*/,;
				/*cCriterio*/,;
				/*lRateio*/,;
				/*cChaveBusca*/,;
				/*aCT5*/,;
				/*lPosiciona*/,;
				@aFlagCTB,;
				/*aTabRecOri*/,;
				/*aDadosProva*/ )

				If LanceiCtb .And. !lUsaFlag
					RecLock("SE5")
					SE5->E5_LA := "S"
					MsUnLock()

					dbSelectArea( "FK5" )
					FK5->( DbSetOrder( 1 ) )//FK5_FILIAL+FK5_IDMOV
					If SE5->E5_TABORI == "FK5" .AND. MsSeek( xFilial("FK5") + SE5->E5_IDORIG )
						RecLock("FK5")
						FK5->FK5_LA := "S"
						MsUnlock()
					Endif
				EndIf
			Endif
			nCtDesp += nOutrDesp
		Endif
		dbSelectArea(cAlias)

		oModelTar:Destroy()
		oModelTar := Nil
		oSubFK5Tar:= Nil
		oSubFKATar:= Nil
	Endif

Return .T.

/*/
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++/ffffffffff-ffffffffff-fffffff-fffffffffffffffffffffff-ffffff-ffffffffffo++
++>FunÁ÷o    >fA200Outro> Autor > Wagner Xavier         > Data > 26/05/92 >++
++Vffffffffff=ffffffffff°fffffff°fffffffffffffffffffffff°ffffff°ffffffffffY++
++>Descric„o >Trata uma determinada tarifa.                               >++
++Vffffffffff=ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
++>Sintaxe   >fa200Tarifa( )                                              >++
++Vffffffffff=ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
++> Uso      >Generico                                                    >++
++?ffffffffff°ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
*/
Function fa200Outros( nTotValcc )

	Local cAlias		:= Alias()
	Local lPadrao		:= VerPadrao("563")		// Movimentacao BancÜria a Receber
	Local lContabiliza	:= Iif(mv_par11==1,.T.,.F.)
	Local cNat			:= ""
	Local nX			:= 0
	Local cLog			:= ""
	Local lRet			:= .T.
	Local cCamposE5		:= ""
	Local cChaveTit		:= ""
	Local cHistorDB		:= ""
	Local cChaveFK7 	:= ""
	Local oModelOut := Nil
	Local oSubFKAOut := Nil
	Local oSubFK5Out := Nil
	Local aAreaSE5 := SE5->(GetArea())

	nValCC := If(nTotValCC = Nil, nValCC, nTotValCC)

	If nValCC > 0

		///fffffffffffffffffffffffffffffffffffffffffffffffffffffffffo
		//> Calcula a data de credito, se esta estiver vazia			>
		//> Se aplica apenas nos casos de confirmas„o de entrada do	>
		//> titulo e tenha lancamento de Despesas BancÜrias, pois 	>
		//> nas ocorrencias de baixa, essa data ja estara calculada >
		//?fffffffffffffffffffffffffffffffffffffffffffffffffffffffffY
		If dDataCred == Nil .Or. Empty(dDataCred)
			dDataCred := If(!Empty(dBaixa),dBaixa,SE5->E5_DATA)  // Assume a data da baixa ou a data do movimento totalizador
			dBaixa := If(!Empty(dBaixa),DataValida(dBaixa,.T.),DataValida(SE5->E5_DATA,.T.))
			If !__lPar17 .Or. (__lPar17 .And. MV_PAR17 == 1)
				For nX := 1 To Sa6->A6_Retenca // Para todos os dias de retencao valida a data
					// O calculo eh feito desta forma, pois os dias de retencao
					// sao dias uteis, e se fosse apenas somado dDataCred+A6_Retenca
					// nao sera verdadeiro quando a data for em uma quinta-feira, por
					// exemplo e, tiver 2 dias de retencao.
					dDataCred := DataValida(dDataCred+1,.T.)
				Next
			EndIf
		EndIf

		// Gera registro na movimentacao bancaria
		// Outros Creditos
		cNat := F200VerNat()

		//Define os campos que nao existem na FK5 e que ser„o gravados apenas na E5, para que a gravaÁ„o da E5 continue igual
		//Estrutura para o E5_CAMPOS: "{{'SE5->CAMPO', Valor}, {'SE5->CAMPO', Valor}}"
		cCamposE5 := "{"
		cCamposE5 += "{'E5_DTDIGIT'	,STOD('" + DTOS(dDataBase) + "')}"
		cCamposE5 += ",{'E5_MOTBX'	,'NOR'		}"
		If nTotValCC # Nil
			cCamposE5 += ",{'E5_LOTE'	,'" + cLoteFin	 + "'}"
			cHistorDB := STR0011 + " " + cLoteFin	//"Baixa por Retorno CNAB / Lote :"
			cChaveFK7 := ""
		Else
			cCamposE5 += ",{'E5_PREFIXO','" + SE1->E1_PREFIXO	+ "'}"
			cCamposE5 += ",{'E5_NUMERO'	,'" + SE1->E1_NUM		+ "'}"
			cCamposE5 += ",{'E5_PARCELA','" + SE1->E1_PARCELA	+ "'}"
			cCamposE5 += ",{'E5_TIPO'	,'" + SE1->E1_TIPO		+ "'}"
			cCamposE5 += ",{'E5_CLIFOR'	,'" + SE1->E1_CLIENTE	+ "'}"
			cCamposE5 += ",{'E5_LOJA'	,'" + SE1->E1_LOJA		+ "'}"
			cHistorDB := SEB->EB_DESCRI
			//Dados da tabela auxiliar com o c€digo do tÃtulo a receber
			cChaveTit := xFilial("SE1") + "|" + SE1->E1_PREFIXO + "|" + SE1->E1_NUM 	+ "|" + SE1->E1_PARCELA + "|" + ;
			SE1->E1_TIPO    + "|" + SE1->E1_CLIENTE + "|" + SE1->E1_LOJA
			cChaveFK7 := FINGRVFK7( "SE1", cChaveTit )
		EndIf
		cCamposE5 += "}"

		oModelOut := FWLoadModel("FINM030")						//Model de Movimento Banc∑rio
		oModelOut:SetOperation( MODEL_OPERATION_INSERT )			//Inclusao
		oModelOut:Activate()											//Ativa o modelo de dados
		oModelOut:SetValue( "MASTER","E5_GRV"		,.T.		)	//Informa se vai gravar SE5 ou nao
		oModelOut:SetValue( "MASTER","NOVOPROC"		,.T.		)	//Informa que a inclus„o ser∑ feita com um novo n˙mero de processo
		oModelOut:SetValue( "MASTER","E5_CAMPOS"	,cCamposE5	)	//Informa os campos da SE5 que ser„o gravados indepentes de FK5

		oSubFKAOut := oModelOut:GetModel("FKADETAIL")
		oSubFKAOut:SetValue( "FKA_IDORIG", FWUUIDV4() )
		oSubFKAOut:SetValue( "FKA_TABORI", "FK5" )

		//Informacoes do movimento
		oSubFK5Out := oModelOut:GetModel( "FK5DETAIL" )
		oSubFK5Out:SetValue( "FK5_IDDOC"	,cChaveFK7 )
		oSubFK5Out:SetValue( "FK5_ORIGEM"	,FunName() )
		oSubFK5Out:SetValue( "FK5_DATA"		,dBaixa )
		oSubFK5Out:SetValue( "FK5_VALOR"	,nValcc )
		oSubFK5Out:SetValue( "FK5_VLMOE2"	,nValcc )
		oSubFK5Out:SetValue( "FK5_RECPAG"	,"R" )
		oSubFK5Out:SetValue( "FK5_BANCO"	,SA6->A6_COD )
		oSubFK5Out:SetValue( "FK5_AGENCI"	,SA6->A6_AGENCIA )
		oSubFK5Out:SetValue( "FK5_CONTA"	,SA6->A6_NUMCON )
		oSubFK5Out:SetValue( "FK5_DTDISP"	,dDataCred )
		oSubFK5Out:SetValue( "FK5_NATURE"	,If(!Empty(cNat),cNat,SE1 -> E1_NATUREZ)	)
		oSubFK5Out:SetValue( "FK5_MOEDA"	,StrZero(SE1->E1_MOEDA,2))
		oSubFK5Out:SetValue( "FK5_TPDOC"	,"DB"	)
		oSubFK5Out:SetValue( "FK5_FILORI"	,cFilAnt )
		oSubFK5Out:SetValue( "FK5_HISTOR"	,cHistorDB )
		If SpbInUse()
			oSubFK5Out:SetValue( "FK5_MODSPB", "1" )
		Endif

		If oModelOut:VldData()
			oModelOut:CommitData()
			dbselectarea("SE5")
			dbsetorder(7)
			DBSEEK(xFilial("SE5")+ SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + SE1->E1_CLIENTE + SE1->E1_LOJA)
		Else
			lRet := .F.
			cLog := cValToChar(oModelOut:GetErrorMessage()[4]) + ' - '
			cLog += cValToChar(oModelOut:GetErrorMessage()[5]) + ' - '
			cLog += cValToChar(oModelOut:GetErrorMessage()[6])

			Help( ,,"F200OUTCRD",,cLog, 1, 0 )
		Endif

		oModelOut:DeActivate()
		oModelOut:Destroy()
		oModelOut := Nil
		oSubFK5Out := Nil
		oSubFKAOut := Nil

		///fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffo
		//> PONTO DE ENTRADA F200OCR                                    >
		//> Serve para tratamento complementar de outros creditos.      >
		//?fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY
		IF lF200OCR
			ExecBlock("F200OCR",.F.,.F.)
		Endif

		///fffffffffffffffffffffffffffffffo
		//> Atualiza saldo bancario.      >
		//?fffffffffffffffffffffffffffffffY
		AtuSalBco(cBanco,cAgencia,cConta,dBaixa,nValcc,"+")

		// Atualiza Saldos por Natureza FIV / FIW
		AtuSldNat(SE5->E5_NATUREZ, SE5->E5_DATA, "01", "3", "C", nValcc, nValcc,"+",,FunName(),"SE5",SE5->(Recno()))

		If !lCabec .and. lPadrao .and. lContabiliza
			nHdlPrv := HeadProva( cLote,;
			"FINA200",;
			substr( cUsuario, 7, 6 ),;
			@cArquivo )

			lCabec := .T.
		Endif

		dbSelectArea("SE5")

		If lCabec .and. lPadrao .and. lContabiliza
			If lUsaFlag // Armazena em aFlagCTB para atualizar no modulo Contabil
				aAdd( aFlagCTB, { "E5_LA", "S", "SE5", SE5->( RecNo() ), 0, 0, 0} )
			EndIf
			nTotal += DetProva( nHdlPrv,;
			"563",;
			"FINA200" /*cPrograma*/,;
			cLote,;
			/*nLinha*/,;
			/*lExecuta*/,;
			/*cCriterio*/,;
			/*lRateio*/,;
			/*cChaveBusca*/,;
			/*aCT5*/,;
			/*lPosiciona*/,;
			@aFlagCTB,;
			/*aTabRecOri*/,;
			/*aDadosProva*/ )

			If LanceiCtb .And. !lUsaFlag
				RecLock("SE5")
				SE5->E5_LA := "S"
				MsUnLock()

				dbSelectArea( "FK5" )
				FK5->( DbSetOrder( 1 ) )//FK5_FILIAL+FK5_IDMOV
				If SE5->E5_TABORI== "FK5" .AND. MsSeek( xFilial("FK5") + SE5->E5_IDORIG )
					RecLock("FK5")
					FK5->FK5_LA := "S"
					MsUnlock()
				Endif
			EndIf
		Endif
		nCtOutCrd := nValcc

		dbSelectArea( cAlias )
	Endif

	Restarea(aAreaSE5)

Return .T.

/*/
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++/ffffffffff-ffffffffff-fffffff-fffffffffffffffffffffff-ffffff-ffffffffffo++
++>FunÁ÷o    >Fa200GrRec> Autor > Pilar S. Albaladejo   > Data > 22/05/97 >++
++Vffffffffff=ffffffffff°fffffff°fffffffffffffffffffffff°ffffff°ffffffffffY++
++>Descric„o >Grava registros no arquivo de reciclagem                    >++
++Vffffffffff=ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
++>Sintaxe   >fa200GrRec( )	                                              >++
++Vffffffffff=ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
++> Uso      >Generico                                                    >++
++?ffffffffff°ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
*/
Function Fa200GrRec(cNsNum, nHdlRecic)

	Local cAlias 	:= Alias()
	Local nTamNBco	:= TamSX3("E1_NUMBCO")[1]
	Local nTamNnum 	:= TamSX3("E1_FILIAL")[1] + nTamNBco
	Local cFile		:= "RECICL" + SubStr(cNumEmp,1,2) + ".TXT"
	Local lAchou	:= .F.
	Local cBuffer	:= ""
	Local nI		:= 0
	Local nTmAqRec	:= 0

	If nHdlRecic == 0
		If File(cFile)
			nHdlRecic := fOpen(cFile , FO_READWRITE + FO_SHARED )
		Else
			nHdlRecic := fCreate(cFile)
		EndIf
	EndIf
	If nHdlRecic == -1
		Help(" ",1,"F200RECICL",,STR0048 + str(ferror(),4),1,0) // 'Erro de abertura: FERROR n„o '
	Else
		nTmAqRec := FSeek(nHdlRecic,0,2)
		FSeek(nHdlRecic,0,0)
		For nI := 1 to nTmAqRec
			FRead(nHdlRecic, @cBuffer, nTamNnum)
			If  AllTrim(cBuffer) == xFilial("SE1") + cNsNum
				lAchou := .T.
				Exit
			EndIf
			FSeek(nHdlRecic,2,1)
			nI	+= ( nTamNnum + 1 )
		Next

		If !lAchou
			FSeek(nHdlRecic,0,FS_END)
			If nTmAqRec > 0
				FWrite(nHdlRecic, Chr(13) + Chr(10) + xFilial("SE1") + PadR(cNsNum, nTamNBco))
			Else
				FWrite(nHdlRecic, xFilial("SE1") + PadR(cNsNum, nTamNBco))
			EndIf
		EndIf
	Endif

	DbSelectArea(cAlias)

Return

/*/
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++/ffffffffff-ffffffffff-fffffff-fffffffffffffffffffffff-ffffff-ffffffffffo++
++>Func„o	 >Fa200ChecF> Autor > Pilar S Albaladejo    > Data > 22/05/97 >++
++Vffffffffff=ffffffffff°fffffff°fffffffffffffffffffffff°ffffff°ffffffffffY++
++>Descric„o >Retorna Expresao para Indice Condicional					  >++
++Vffffffffff=ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
++>Sintaxe	 >Fa200ChecF() 												  >++
++Vffffffffff=ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
++> Uso		 >Generico													  >++
++?ffffffffff°ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
*/
Function FA200ChecF()
	Local cFiltro := ""
	cFiltro := 'E1_FILIAL == "'+xFilial("SE1")+'" .And. E1_SALDO > 0'
Return cFiltro

/*/
||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++/ffffffffff-fffffffffff-fffffff-fffffffffffffffffffffff-ffffff-ffffffffffo++
++>Func„o	 >Fa200GrvLog> Autor > Claudio Donizete      > Data > 25/07/05 >++
++Vffffffffff=fffffffffff°fffffff°fffffffffffffffffffffff°ffffff°ffffffffffY++
++>Descric„o >Grava LOG de processamento do arquivo retorno				   >++
++Vffffffffff=fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
++>Sintaxe	 >Fa200GrvLog   											   >++
++Vffffffffff=fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
++> Uso		 >Fina200													   >++
++?ffffffffff°fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
*/
Static Function Fa200GrvLog(nTipo, cArquivo, cBanco, cAgencia, cConta, nLastLn, cIdTit,;
	cOcoBco, cOcoSis, cIdArq)
	Local cSeq := "00"
	Local lRet := .T.
	Local nLastRec
	Local nBarLin	:= Rat("\",cArquivo)
	Local aUsuario

	// Obtem o nome do arquivo apenas, desprezando o path
	If nBarLin > 0
		cArquivo := SubStr(cArquivo,nBarLin+1)
	ElseIf nBarLin == 0
		nBarLin	:= Rat("/",cArquivo)
		cArquivo := If(nBarLin > 0, SubStr(cArquivo,nBarLin+1), cArquivo)
	Endif

	If nTipo == 1 // Cabecalho
		// Se o arquivo ja foi processado, a ultima linha sera a ultima
		// gravada no arquivo
		If FI0->(MsSeek(xFilial("FI0")+Pad(cIdArq,Len(FI0_IDARQ))+cBanco+cAgencia+cConta))
			While FI0->(FI0_FILIAL+Pad(FI0_IDARQ,Len(FI0_IDARQ))+FI0_BCO+FI0_AGE+FI0_CTA) == xFilial("FI0")+Pad(cIdArq,Len(FI0->FI0_IDARQ))+cBanco+cAgencia+cConta
				nLastLn	:= FI0->FI0_LASTLN
				cSeq	  	:= FI0->FI0_SEQ
				nLastRec := FI0->(Recno())
				FI0->(DbSkip())
			End
			FI0->(MsGoto(nLastRec))
			PswOrder(1)

			// caso de usuario excluido estava dando errorlog
			if PswSeek(FI0->FI0_USU)
				aUsuario := PswRet()
				cNomeUsuario := Alltrim(aUsuario[1][2])
			Else
				cNomeUsuario := FI0->FI0_USU
			Endif

			// se estiver em modo Job nao apresenta a mensagem e sempre reprocessa
			lRet := (lExecJob .or. ApMsgYesNo("Arquivo retorno j∑ processado anteriormente em " +;
			DTOC(FI0->FI0_DTPRC) + " ás " + FI0->FI0_HRPRC + Chr(13)+Chr(10)+;
			"Processado com o nome : " + AllTrim(FI0->FI0_ARQ)+ Chr(13)+Chr(10)+ ;
			"Usu∑rio que processou : " + cNomeUsuario+ Chr(13)+Chr(10)+;
			"A ultima linha lida do arquivo foi: " +	Transform(FI0->FI0_LASTLN, "")+ Chr(13)+Chr(10) +;
			"O arquivo j∑ foi processado " + Str(Val(FI0->FI0_SEQ),3) +;
			If(Val(FI0->FI0_SEQ)<=1," vez", " vezes")+". Deseja  reprocess∑-lo?"))

			// Retorno Automatico via Job
			if lExecJob
				Aadd(aMsgSch, "Arquivo retorno j∑ processado anteriormente em " +;
				DTOC(FI0->FI0_DTPRC) + " ás " + FI0->FI0_HRPRC +;
				". Processado com o nome : " + AllTrim(FI0->FI0_ARQ)+ ;
				". A ultima linha lida do arquivo foi: " + Transform(FI0->FI0_LASTLN, "")+;
				". Verifique.")
				lRet := .F.
			Endif
		Endif
		If lRet
			RecLock("FI0", .T.)
			FI0->FI0_FILIAL	:= xFilial("FI0")
			FI0->FI0_ARQ		:= cArquivo
			FI0->FI0_IDARQ		:= cIdArq
			FI0->FI0_DTPRC		:= dDataBase
			FI0->FI0_HRPRC		:= Left(Time(), 6) // Grava a HH:MM do processamento
			FI0->FI0_BCO		:= cBanco
			FI0->FI0_AGE		:= cAgencia
			FI0->FI0_CTA		:= cConta
			FI0->FI0_USU		:= RetCodUsr()
			FI0->FI0_LASTLN		:= nLastLn
			FI0->FI0_SEQ		:= Soma1(cSeq)
			FI0->( Dbunlock())
			FKCOMMIT()
		Endif
	Elseif nTipo == 2 // Detalhe dos titulos processados
		RecLock("FI1", .T.)
		FI1->FI1_FILIAL		:= xFilial("FI1")
		FI1->FI1_IDARQ		:= cIdArq
		FI1->FI1_IDTIT		:= cIdTit
		FI1->FI1_OCORB		:= cOcoBco
		FI1->FI1_OCORS		:= cOcoSis
		FI1->FI1_SEQ	:= FI0->FI0_SEQ
		FI1->( Dbunlock())
		FKCOMMIT()
	Endif

Return lRet

/*/
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++/ffffffffff-ffffffffff-fffffff-fffffffffffffffffffffff-ffffff-ffffffffffo++
++>Programa  >MenuDef   > Autor > Ana Paula N. Silva     > Data >23/11/06 >++
++Vffffffffff=ffffffffff°fffffff°fffffffffffffffffffffff°ffffff°ffffffffffY++
++>DescriÁ÷o > Utilizacao de menu Funcional                               >++
++Vffffffffff=ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
++>Retorno   >Array com opcoes da rotina.                                 >++
++Vffffffffff=ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
++>Parametros>Parametros do array a Rotina:                               >++
++>          >1. Nome a aparecer no cabecalho                             >++
++>          >2. Nome da Rotina associada                                 >++
++>          >3. Reservado                                                >++
++>          >4. Tipo de Transac„o a ser efetuada:                        >++
++>          >	  1 - Pesquisa e Posiciona em um Banco de Dados     	  >++
++>          >    2 - Simplesmente Mostra os Campos                       >++
++>          >    3 - Inclui registros no Bancos de Dados                 >++
++>          >    4 - Altera o registro corrente                          >++
++>          >    5 - Remove o registro corrente do Banco de Dados        >++
++>          >5. Nivel de acesso                                          >++
++>          >6. Habilita Menu Funcional                                  >++
++Vffffffffff=fffffffffffffff-ffffffffffffffffffffffffffffffffffffffffffffY++
++>   DATA   > Programador   >Manutencao efetuada                         >++
++Vffffffffff=fffffffffffffff=ffffffffffffffffffffffffffffffffffffffffffffY++
++>          >               >                                            >++
++?ffffffffff°fffffffffffffff°ffffffffffffffffffffffffffffffffffffffffffffY++
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
/*/
Static Function MenuDef()
	Local aRotina:= { {STR0001 ,"fA200Par" , 0 , 1},;  // "Parametros"
	{STR0002 ,"AxVisual" , 0 , 2},;  // "Visualizar"
	{STR0003 ,"fA200Gera", 0 , 3} }  // "Receber Arquivo"
Return(aRotina)

/*/
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++/ffffffffff-fffffffffff-fffffff-ffffffffffffffffffffff-ffffff-ffffffffffo++
++>FunÁ÷o    >FinA200T   > Autor > Marcelo Celi Marques > Data > 31.03.08 >++
++Vffffffffff=fffffffffff°fffffff°ffffffffffffffffffffff°ffffff°ffffffffffY++
++>DescriÁ÷o > Chamada semi-automatica utilizado pelo gestor financeiro   >++
++Vffffffffff=ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
++> Uso      > FINA200                                                    >++
++?ffffffffff°ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
/*/
Function FinA200T(aParam)
	cRotinaExec := "FINA200"
	ReCreateBrow("SE1",FinWindow)
	FinA200(aParam[1])
	ReCreateBrow("SE1",FinWindow)

	dbSelectArea("SE1")

	INCLUI := .F.
	ALTERA := .F.

Return .T.

/*/
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++/ffffffffff-fffffffffff-fffffff-ffffffffffffffffffffff-ffffff-ffffffffffo++
++>FunÁ÷o    >F200TrfCob > Autor > Mauricio Pequim Jr.  > Data > 31.03.08 >++
++Vffffffffff=fffffffffff°fffffff°ffffffffffffffffffffff°ffffff°ffffffffffY++
++>DescriÁ÷o > GravaÁ„o das transferencias dos titulos                    >++
++Vffffffffff=ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
++> Uso      > FINA200                                                    >++
++?ffffffffff°ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
/*/
Static Function F200TrfCob(cOcorr,cBanco,cAgencia,cConta)

	Local aArea		:= GetArea()
	Local nJ		:= 0
	Local cPadrao2	:="540"
	Local cChavEA	:= xFilial("SEA")+E1_NUMBOR+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	Local cSituAnt  := SE1->E1_SITUACA
	Local lPadrao2	:= .F.
	Local lContabiliza := Iif(mv_par11==1,.T.,.F.)
	Local cSituacao := "0"
	Local cLstCart	:= FN022LSTCB(1)	//Lista de Situacoes de cobranca - Carteira
	Local cLstBanco	:= FN022LSTCB(3)	//Lista de Situacoes de cobranca - com portador (banco)
	Local cLstProt	:= FN022LSTCB(4)	//Lista de Situacoes de cobranca - Protesto
	Local nRetencao	:= SA6->A6_RETENCA

	DEFAULT cOcorr  := ""
	DEFAULT cBanco	:= ""
	DEFAULT cAgencia:= ""
	DEFAULT cConta	:= ""

	If !Empty (cOcorr)

		//Obtenho a nova situacao do titulo
		cSituacao := SUBSTR(cOcorr,2,1)

		//Alteracao para CobranÁa Protesto (6) ou Carteira Protesto (F)
		//Atualiza numero de titulos protestados
		IF ( cSituacao $ cLstProt )  .and. !( cSituAnt $ cLstProt )
			dbSelectArea("SA1")
			If (dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
				Reclock("SA1")
				SA1->A1_TITPROT := A1_TITPROT+1
				SA1->A1_DTULTIT := dDataBase
				MsUnlock()
			Endif
			dbSelectArea("SE1")
		Endif

		//Retirada de protesto
		//Alteracao da CobranÁa Protesto(6) ou Carteira Protesto(F) para Carteira(0) ou Carteira Acordo(G)
		IF ( (cSituacao $ cLstCart ) .and. !(cSituacao $ cLstProt) ) .and. (SE1->E1_SITUACA $ cLstProt)
			dbSelectArea("SA1")
			If (dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
				Reclock("SA1")
				SA1->A1_TITPROT := A1_TITPROT-1
				MsUnlock( )
			Endif
			dbSelectArea("SE1")
		Endif

		//Transferencia para cobranca bancaria
		IF cSituacao $ cLstBanco .and. cSituacao != cSituAnt
			///ffffffffffffffffffffffffffffffffffffffffffffffo
			//> Atualiza data vencto real c/retenc„o BancÜria>
			//?ffffffffffffffffffffffffffffffffffffffffffffffY
			// Se possuir retencao bancaria, grava a data de vencimento
			IF mv_par15 == 1 .And. nRetencao>0
				dBase	:=	SE1->E1_VENCREA
				For nJ:=1 To nRetencao
					dBase := DataValida(dBase+1,.T.)
				Next nJ
				Reclock("SE1")
				SE1->E1_VENCREA := dBase
				MsUnlock()
				// Atualiza tambem os registros agregados
				F060AtuAgre()
			EndIF
		EndIF

		//Transferindo o titulo que estava em banco para a carteira
		IF cSituacao $ cLstCart .and. cSituAnt $ cLstBanco
			///ffffffffffffffffffffffffffffffffffffffffffffffo
			//> Atualiza data vencto real s/retenc„o BancÜria>
			//?ffffffffffffffffffffffffffffffffffffffffffffffY
			// Se considera retencao bancaria
			If mv_par15 == 1
				Reclock("SE1")
				SE1->E1_VENCREA := DataValida(SE1->E1_VENCORI,.T.)
				If SE1->E1_VENCREA < SE1->E1_VENCTO
					SE1->E1_VENCREA := DataValida(SE1->E1_VENCTO,.T.)
				Endif
				MsUnlock()
				// Atualiza tambem os registros agregados
				F060AtuAgre()
			EndIF
		Endif

		// Banco vazio, contabiliza anterior
		If Empty(cBanco)
			dbSelectArea("SA6")
			dbSeek(xFilial()+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA)
		Else
			dbSelectArea("SA6")
			dbSeek(xFilial()+cBanco+cAgencia+cConta)
		Endif

		FKCOMMIT()

		// Guardo portador anterior, para possivel utilizacao no LP
		VAR_IXB			 := SE1->E1_PORTADO

		If cSituacao $ cLstCart
			//Atualizo dados do titulo
			RecLock("SE1")
			SE1->E1_PORTADO := ""
			SE1->E1_AGEDEP  := ""
			SE1->E1_SITUACA := cSituacao
			SE1->E1_NUMBCO  := ""
			SE1->E1_MOVIMEN := dDataBase
			SE1->E1_CONTA	 := ""
			If cSituacao != cSituAnt .And. !Empty(SE1->E1_NUMBOR)
				SE1->E1_NUMBOR := " "
				SE1->E1_DATABOR:= Ctod("  /  /  ")
			EndIf
			FKCOMMIT()

			//Excluo do bordero (SEA) se o titulo voltou para carteira
			dbSelectArea("SEA")
			If dbSeek(cChavEA)
				RecLock("SEA",.F.,.T.)
				dbDelete()
				MsUnlock()
				SX2->(MsUnlock())
			Endif

		Else

			//Atualizo dados do titulo
			RecLock("SE1")
			SE1->E1_PORTADO := cBanco
			SE1->E1_AGEDEP  := cAgencia
			SE1->E1_SITUACA := cSituacao
			SE1->E1_NUMBCO  := cNsNum
			SE1->E1_MOVIMEN := dDataBase
			SE1->E1_CONTA	:= cConta
			FKCOMMIT()

			//Incluo no SEA se o titulo foi para cobranca
			dbSelectArea("SEA")
			If !dbSeek(cChavEA)
				RecLock("SEA",.T.)
			Else
				RecLock("SEA")
			EndIf
			SEA->EA_FILIAL  := xFilial("SEA")
			SEA->EA_DATABOR := dDataBase
			SEA->EA_PORTADO := cBanco
			SEA->EA_AGEDEP  := cAgencia
			SEA->EA_NUMCON  := cConta
			SEA->EA_SITUACA := cSituacao
			SEA->EA_NUM 	:= SE1->E1_NUM
			SEA->EA_PARCELA := SE1->E1_PARCELA
			SEA->EA_PREFIXO := SE1->E1_PREFIXO
			SEA->EA_TIPO	:= SE1->E1_TIPO
			SEA->EA_CART	:= "R"
			SEA->EA_SITUANT := cSituant
			SEA->EA_FILORIG := SE1->E1_FILIAL
			If l060SEA
				ExecBlock("F060SEA",.f.,.f.)
			Endif
			SEA->(MsUnlock())
		Endif
		FKCOMMIT()

		//Contabiliza Transferencias
		If lContabiliza .and. cSituant != SE1->E1_SITUACA
			IF FN022SITCB(cSituacao)[1]		//Carteira cSituacao $ "0|F|G"
				cPadrao:="540"
			ElseIf FN022SITCB(cSituacao)[5]	//Simples e Cartorio   cSituacao $ "1|H"
				cPadrao:="541"
			ElseIf FN022SITCB(cSituacao)[3]	//Descontada 	cSituacao $ "2|7"
				cPadrao:="542"
			ElseIf FN022SITCB(cSituacao)[4]	//Cobranca em banco com protesto
				cPadrao:="543"
			ElseIf FN022SITCB(cSituacao)[2]	//Cobranca em banco sem protesto exceto Simples e Cartorio
				cPadrao:="544"
			EndIf

			//A situacao do titulo mudou de uma cobranÁa para outra sem passar pela carteira
			If !(cSituacao $ cLstCart) .and. !(cSituant  $ cLstCart)
				lPadrao2:=VerPadrao(cPadrao2)
			Endif

			lPadrao:=VerPadrao(cPadrao)
			STRLCTPAD := cSituant   // Disponibiliza a situacao anterior para ser utilizada no LP
			VALOR  := 0					// para contabilizar o total descontado (PRIVATE)
			VALOR2 := 0			 		// Saldo dos titulo para contabilizacao da diferenca

			If lPadrao .and. mv_par14 == 1
				If !lCabec
					///ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffo
					//> Inicializa Lancamento Contabil                                   >
					//?ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY
					nHdlPrv := HeadProva( cLote,;
					"FINA200" /*cPrograma*/,;
					Substr( cUsuario, 7, 6 ),;
					@cArquivo )
					lCabec := .T.
				Endif

				If lCabec
					//Quando existe mudanÁa de situacao de cobranca sem que o titulo passe pela Carteira (Situacao 0)
					//Contabilizo movimento CobranÁa -> Carteira
					If lPadrao2
						nTotal += DetProva( nHdlPrv,;
						cPadrao2,;
						"FINA200" /*cPrograma*/,;
						cLote,;
						/*nLinha*/,;
						/*lExecuta*/,;
						/*cCriterio*/,;
						/*lRateio*/,;
						/*cChaveBusca*/,;
						/*aCT5*/,;
						/*lPosiciona*/,;
						/*@aFlagCTB*/,;
						/*aTabRecOri*/,;
						/*aDadosProva*/ )
					Endif

					//Contabilizo movimento Carteira -> CobranÁa
					nTotal += DetProva( nHdlPrv,;
					cPadrao,;
					"FINA200" /*cPrograma*/,;
					cLote,;
					/*nLinha*/,;
					/*lExecuta*/,;
					/*cCriterio*/,;
					/*lRateio*/,;
					/*cChaveBusca*/,;
					/*aCT5*/,;
					/*lPosiciona*/,;
					/*@aFlagCTB*/,;
					/*aTabRecOri*/,;
					/*aDadosProva*/ )
				Endif
			Endif
		EndIf

	Endif

	RestArea(aArea)

Return

/*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++/ffffffffff-ffffffffffff-fffffff-ffffffffffffffffffffffffffffff-ffffffffo++
++>Func„o    >ExecSchedule> Autor > Aldo Barbosa dos Santos      >01/07/11>++
++Vffffffffff=ffffffffffff°fffffff°ffffffffffffffffffffffffffffff°ffffffffY++
++>Descricao >Retorna se o programa esta sendo executado via schedule     >++
++?ffffffffff°ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH*/
Static Function ExecSchedule()
	Local lRetorno := .T.

	lRetorno := IsBlind()

Return( lRetorno )

/*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++/ffffffffff-ffffffffffff-fffffff-ffffffffffffffffffffffffffffff-ffffffffo++
++>Func„o    >LoadVlBx    > Autor > Controladoria                >01/07/11>++
++Vffffffffff=ffffffffffff°fffffff°ffffffffffffffffffffffffffffff°ffffffffY++
++>Descricao >                                                            >++
++?ffffffffff°ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffY++
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH*/

Static Function LoadVlBx( nHdlBco, xBuffer, nTamDet, nValtot, nTotDesp, nTotOutD, nTotValCc, nTotAGer,aLeitura, lBxCnab)
	Local aArea		:= GetArea()
	Local cOcorr	:= ''
	Local cMotBan	:= ''

	Local nCont		:= 0
	Local nDespes	:= 0
	Local nValrec	:= 0
	Local nOutrDesp	:= 0
	Local nValCc	:= 0
	LOCAL aArqConf 	:= ""

	Local lSai		:= .F.

	Default aLeitura := {}
	Default lBxCnab	:= SuperGetMv( "MV_BXCNAB",,"S" ) == "S"

	If !Empty(cArqCfg) .and. ValType(MV_PAR05) == "N"
		MV_PAR05 := AllTrim(cArqCfg)
	Endif
	aArqConf 	:= Directory(MV_PAR05)

	If MV_PAR12 == 1 // modelo do CNAB (Modelo1 # Modelo2)
		IF SubStr(xBuffer,1,1) $ "1|F|J|7|2"
			///ffffffffffffffffffffffffffffffffffo
			//> L‡ os valores do arquivo Retorno >
			//?ffffffffffffffffffffffffffffffffffY
			IF !Empty(cPosDesp)
				nDespes:=Round(Val(Substr(xBuffer,Int(Val(Substr(cPosDesp,1,3))),nLenDesp))/100,2)
			EndIF
			IF !Empty(cPosPrin)
				nValrec :=Round(Val(Substr(xBuffer,Int(Val(Substr(cPosPrin,1,3))),nLenPrin))/100,2)
			EndIF
			IF !Empty(cPosOutrd)
				nOutrDesp  :=Round(Val(Substr(xBuffer,Int(Val(Substr(cPosOutrd,1,3))),nLenOutrd))/100,2)
			EndIF
			IF !Empty(cPosCc)
				nValCc :=Round(Val(Substr(xBuffer,Int(Val(Substr(cPosCc,1,3))),nLenCc))/100,2)
			EndIF
			If nLenOcor == 2
				cOcorr  :=Substr(xBuffer,Int(Val(Substr(cPosOcor,1,3))),nLenOcor) + " "
			Else
				cOcorr  :=Substr(xBuffer,Int(Val(Substr(cPosOcor,1,3))),nLenOcor)
			EndIf
			If !Empty(cPosMot)
				cMotBan:=Substr(xBuffer,Int(Val(Substr(cPosMot,1,3))),nLenMot)
			EndIf

		Endif
	Else
		If Len(aLeitura) == 0
			aLeitura := ReadCnab2(nHdlBco,MV_PAR05,nTamDet,aArqConf)
		EndIf
		nDespes  := aLeitura[06]
		nValRec  := aLeitura[05]
		nValCC   := aLeitura[13]
		cOcorr   := PadR(aLeitura[03],3)
		cMotBan  := aLeitura[15]
	Endif

	If !Empty(cOcorr)
		dbSelectArea("SEB")
		dbSetOrder(1)
		If !(dbSeek(xFilial("SEB")+mv_par06+cOcorr+"R"))
			Help(" ",1,"FA200OCORR",,mv_par06+"-"+cOcorr+"R",4,1)

			// Retorno Automatico via Job
			if lExecJob
				Aadd(aMsgSch, STR0026+mv_par06+" "+cOcorr+STR0027) // "Ocorrencia " # " nao localizada na tabela SEB."
			Endif
		Endif

		IF SEB->EB_OCORR $ "03|15|16|17|40|41|42|52|53"		//Registro rejeitado
			For nCont := 1 To Len(cMotBan) Step 2
				cMotivo := Substr(cMotBan,nCont,2)
				If fa200Rejei(cMotivo,cOcorr)
					lSai := .T.
					///ffffffffffffffffffffffffffffffffffffffffffffffffo
					//> Trata tarifas da retirada do titulo do banco	>
					//?ffffffffffffffffffffffffffffffffffffffffffffffffY
					If lBxCnab
						nTotDesp += nDespes
						nTotOutD += nOutrDesp
					Endif
					Exit
				EndIf
			Next nCont

		EndIf

		If !lSai
			If SEB->EB_OCORR $ "06|07|08|36|37|38|39"		//Baixa do Titulo
				DbSelectArea( "FI1" )
				DbSetOrder(1)
				FI1->(dbSeek(xFilial("FI1")+ SE1->E1_NUM ))
				If SE1->E1_NUM == FI1->FI1_IDTIT
					nValtot 	+= nValrec+If(SEE->EE_DESPCRD == "S",nDespes + nOutrDesp - nValCC,0)
					nTotDesp 	+= nDespes
				EndIf
				nTotOutD 	+= nOutrDesp
				nTotValCc 	+= nValCC
				nTotAGer	+= nValrec+If(SEE->EE_DESPCRD == "S",nDespes + nOutrDesp - nValCC,0)
			EndIf
		Endif
	Endif

	RestArea( aArea )

Return

//-----------------------------------------------------------------------------------------
/*/
{Protheus.doc} F200VerNat
Verifica a natureza de despesas banc∑rias

@author pequim

@since 26/09/2014
@version 1.0
/*/
//-----------------------------------------------------------------------------------------

Function F200VerNat()

	Local cNatureza := ""
	Local aArea := GetArea()

	lVerifNat := .T.

	If nTamNat == 0
		nTamNat := TamSX3("FK5_NATURE")[1]
	Endif

	cNatureza := &(SuperGetMV("MV_NATDPBC"))
	cNatureza := Padr(cNatureza,nTamNat)

	SED->(dbSetOrder(1))
	If SED->(!(MsSeek(xFilial("SED")+cNatureza)))
		RecLock("SED",.T.)
		SED->ED_FILIAL  := xFilial("SED")
		SED->ED_CODIGO  := cNatureza
		SED->ED_CALCIRF := "N"
		SED->ED_CALCISS := "N"
		SED->ED_CALCINS := "N"
		SED->ED_CALCCSL := "N"
		SED->ED_CALCCOF := "N"
		SED->ED_CALCPIS := "N"
		SED->ED_DESCRIC := STR0041 //"Despesas Banc∑rias - CNAB"
		SED->ED_TIPO	:= "2"
		MsUnlock()
		FKCOMMIT()
	Endif

	RestArea(aArea)

Return cNatureza

//-------------------------------------------------------------------
/*/{Protheus.doc}F200VALREC
C∑lculo do valor recebido de forma BRUTA, no caso de retenÁ„o
de impostos (MV_CNABIMP), para processamento da BAIXA pelo FINA070.

@param dRef - Data de Referencia
@param nValRec - Valor Recebido
@param lBxTotal - Baixa total
@param nTotAbImp - Total de IMPOSTOS na emiss„o.

@return nValRet - Retorna o Valor Recebido BRUTO c/ impostos.

@author Leonardo Castro
@since  03/08/2015
/*/
//-------------------------------------------------------------------

Function F200VALREC(dRef,nValRec,lBxTotal,nTotAbImp)

	Local aArea			:= GetArea()
	Local aAreaSA1		:= SA1->(GetArea("SA1"))
	Local aAreaSED		:= SED->(GetArea("SED"))
	Local nValRet		:= 0
	Local nPercCalc		:= 0

	Local lPccBxCr		:= FPccBxCr() //Controla o Pis Cofins e Csll na Baixa
	Local lIrPjBxCr		:= FIrPjBxCr() //Controla IRPJ na Baixa
	Local nVlrMin		:= SuperGetMv("MV_VL13137", .T., 10 ) // Valor minimo de retencao

	Default dRef		:= dDataBase
	Default nValRec		:= 0
	Default lBxTotal	:= .T.
	Default nTotAbImp	:= 0

	nValRet := nValRec

	If dRef >= cToD("22/06/2015")

		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE))

		DbSelectArea("SED")
		SED->(DbSetOrder(1))
		SED->(DbSeek(xFilial("SED")+SE1->E1_NATUREZ))

		//Monto PERCENTUAL de calculo de impostos na baixa.
		nPercCalc	:= IIF(lPccBxCr, SED->(ED_PERCPIS + ED_PERCCOF + ED_PERCCSL), 0 )
		nPercCalc	+= IIF(lIrPjBxCr, IIF(SED->ED_PERCIRF > 0, SED->ED_PERCIRF, SuperGetMV("MV_ALIQIRF")) , 0 )

		/* Neste momento sera feita a recomposiÁ„o do valor recebido */

		// BAIXA TOTAL
		If lBxTotal

			nValRet += nTotAbImp

			If lPccBxCr .And. SE1->(E1_PIS + E1_COFINS + E1_CSLL) > nVlrMin
				nValRet += SE1->( E1_PIS + E1_COFINS + E1_CSLL )
			EndIf

			If lIrPjBxCr .And. SE1->E1_IRRF > 0
				nValRet += SE1->E1_IRRF
			EndIf

			// BAIXA RESIDUAL (ZERA SALDO)
		ElseIf SE1->E1_SALDO == Round( (nValRet + nTotAbImp) / ( 1 - (nPercCalc/100) ) , 2 )

			nValRet := SE1->E1_SALDO

			// BAIXA PARCIAL
		Else

			nValRet := Round( (nValRet) / ( 1 - (nPercCalc/100) ) , 2 )

		EndIf

	EndIf

	RestArea(aAreaSED)
	RestArea(aAreaSA1)
	RestArea(aArea)

Return nValRet

/*
Uso na baixa retorno cnab via schedule(FINA205)
Corrigi o nome do arquivo de entrada e atualiza
o valor do param. mv_par04
*/

Static Function ArquivoEnt()
	Local nI
	Local cNmArq := ""

	mv_par04 := AllTrim(mv_par04)

	For nI := 1 to Len(mv_par04)
		cCaract := SubStr(mv_par04,nI,1)

		If cCaract $ "\|/" .And. !Empty(cCaract)
			cNmArq := ""
		Else
			cNmArq := If(Empty(cCaract), cNmArq, (cNmArq + cCaract))
		EndIf
	Next nI

Return cNmArq

#Include "totvs.ch"
#Include "protheus.ch"
#Include "RwMake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³MA110BAR  ºAUTOR  ³CRISTIANO MACHADO   º DATA ³  27/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESC.     ³Inclui Botao para importacao de arquivo .CSV na solicitacao º±±
±±º          ³de compras. o arquivo deve ter dois campos [codigo de produ-º±±
±±º          ³to] e [quantidade]                                          º±±
±±º          ³PE PARA MATA110.PRX                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ MP8 IMDEPA ROLAMENTOS                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

*******************************************************************************
User Function MA110BAR()
*******************************************************************************

	aBotao := {}
	AAdd( aBotao, { "S4WB001N", { || ARQUIVO() }, "IMP. CSV" } )

Return(aBotao)

*******************************************************************************
Static Function ARQUIVO()
*******************************************************************************

	Private aAreaAtu  	:= GetArea()

	Private aAreaSB1	:= SB1->( GetArea() )
	SB1->( DbSetOrder( 1 ) )

	Private aAreaSB2	:= SB2->( GetArea() )
	SB2->( DbSetOrder( 1 ) )

	//CONVARQ()

	cTipo := ""
	cTipo := cTipo + "Arquivos de Dados (*.csv)  | *.csv | "
	cFile := cGetFile( cTipo , "Seleção de Arquivos /.csv",,"c:\excel") //,,GETF_MULTISELECT+GETF_LOCALHARD+GETF_NETWORKDRIVE ) //,.T.,GETF_NOCHANGEDIR+GETF_NETWORKDRIVE)//GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE)
	cArq  := AllTrim(cFile)

	IF !Empty(cArq)
		Processa( {|| CONVARQ() } , "Processando Dados" 		, "Processando Dados ... /Aguarde... ", .T. )
		Processa( {|| MIGRA() }   , "Importação Ped. Compra" 	, "Importando Dados ... /Aguarde...  ", .T. )
	EndIf

	RestArea(aAreaSB2)
	RestArea(aAreaSB1)
	RestArea(aAreaAtu)
	

Return()

*******************************************************************************
Static Function CONVARQ()
*******************************************************************************
	Local _cProduto := ""

	//Private	cPath 	:= "C:\EXCEL\PEDIDO.csv"
	Private	cPath 	:= cArq
	Private aStru 	:= {}
	Private NDEL 	:= 0
	Private lPrim   := .F.
	Private aDados  := {}
	Private nCols   := 0
	Private cCab    := ''
	Private PUsaCab := .F.
	Private aCSV    := {}
	Private I       := 0

	/*
	IF !INCLUI
	Alert("Somente Disponivel na Inclusao/Alteração da Solicitação!!")
	Return()
	EndIf
	*/

	IF !File(cPath)
		Alert("O Arquivo " + cPath + " não existe !!!")
		Return()
	EndIf

	//CRIA DBF PARA SER ALIMENTADO PELO ARQUIVO CSV
	AAdd(aStru,{"PRODUTO" ,"C",15,0})
	AAdd(aStru,{"QUANT"   ,"N",14,2})

	///02/12/2011 - JULIO JACOVENKO, modificacao solicitada pelo chamado AAZU2A (usuario Everton)
	///solicitado importador data
	AAdd(aStru,{"DATAE" ,"D",08,0})   //NO CVS, TEM DE SER DD/MM/AA
	AAdd(aStru,{"OBS"   ,"C",60,0})   //MAXIMO DE CARACTERES QUE PEGA DO CVS
	///////////////////////////////////////////////////

	cArq := CriaTrab(aStru,.T.)

	USE &cArq EXCLUSIVE ALIAS TRAB NEW
	INDEX ON  Produto TAG 1 To &cArq

	//ABRI ARQUIVO TEXTO
	FT_FUSE(cPath)
	//PULA P/ LINHA 1
	FT_FGOTOP()

	aDados := Array(0,5)

	//agora vamos alimentar o array
	FT_FGOTOP()
	While !FT_FEOF()//EnQuantO NAO For O FIM DO ARQUIVO TEXTO

		cLinha 	:= FT_FREADLN()//LE A LINHA DO ARQUIVO

		IIF(AT(",",cLinha) > 0, NDEL := AT(",",cLinha), NDEL := AT(";",cLinha) )

		IF 	VAL(SubStr(cLinha,NDEL+1,Len(cLinha))) > 0 .OR. !Empty(StrZero(VAL(SubStr(cLinha,001,NDEL-1)),8))
			If lPrim
				aCampos := Separa(cLinha,";",.T.) //CABECALHO SE HOUVER
				lPrim := .F.
			Else
				AAdd(aDados,Separa(cLinha,";",.T.))
			EndIf
		EndIf

		FT_FSKIP()//PULA UMA LINHA NO ARQUIVO

	EndDo

	For X := 1 To Len(aDados)

		_cProduto := Iif( Len( AllTrim( aDados[X][1] ) ) < 10, StrZero( VAL( aDados[X][1] ), 8 ), AllTrim( aDados[X][1] ) )

		///JULIO, em 08/04/2012
		// Jean Rehermann - Solutio IT - 22/09/2015 - Trato o tamanho do codigo do Produto
		//IF DbSeek(StrZero(VAL(aDados[X][1]),8))
		IF DbSeek(_cProduto)
			RECLOCK("TRAB",.F.)
			TRAB->QUANT += VAL(aDados[X][2])
		Else
			RECLOCK("TRAB",.T.)
			TRAB->QUANT := VAL(aDados[X][2])
		EndIf

		// Jean Rehermann - Solutio IT - 22/09/2015 - Trato o tamanho do codigo do Produto
		//TRAB->PRODUTO := StrZero(VAL(aDados[X][1]),8)
		TRAB->PRODUTO := _cProduto
		//TRAB->QUANT 	:= VAL(aDados[X][2])

		cColuna := Len(aDados[x])

		If cColuna>=3 .and. AllTrim(aDados[X][3])<>''
			TRAB->DATAE     := CToD(aDados[X][3])
		ElseIf cColuna>=3 .and. AllTrim(aDados[X][3])==''
			TRAB->DATAE     := dDataBase
		ElseIf cColuna<3
			//Alert('<3 '+str(cColuna) )
			TRAB->DATAE     := dDataBase
		EndIf

		If cColuna>=4  .and. AllTrim(aDados[X][4])<>''
			TRAB->OBS       := aDados[X][4]
		ElseIf cColuna<4
			TRAB->OBS       :=' '
		EndIf

		MsUnlock()
	Next

	DbSelectArea("TRAB")
	DbCloseArea()

Return()

*******************************************************************************
Static Function MIGRA()
*******************************************************************************
	Local nReg  	:= 0
	Local nPreco	:= 0
	Local nCount  	:= 0
	Local LPOS  	:= .T.

	IF Empty(cArq)
		Alert("Selecione um Arquivo !!")
		Return()
	Else

		USE &cArq ALIAS TRB NEW
		Cid       := RETCODUSR()
		cSolicit  := SubStr(CUSUARIO,7,14)

		TRB->(PROCREGUA(LASTREC()))
		TRB->(DBGOTOP())

		N	:= 1
		While !EOF()
			cProduto  	:= AllTrim(TRB->PRODUTO)+Space(15-Len(AllTrim(TRB->PRODUTO)))

			SB1->( DbSetOrder( 1 ) )
			IF SB1->(DbSeek(xFilial("SB1")+cProduto,.F.)) //SB1->(DbSeek(xFilial("SB1")+TRB->PRODUTO,.F.))

				cDescr  	:= SB1->B1_DESC
				nQuant    	:= TRB->QUANT
				cUnid    	:= SB1->B1_UM
				cSegUnid 	:= SB1->B1_SEGUM
				cArmazem 	:= SB1->B1_LOCPAD
				nPreco	  	:= 0

				IIF(Len(aCols)>1,nReg:=Len(aCols)+1,nReg:=nReg+1)
				nCount++

				//    		nReg	:= nReg + 1

			Else

				Alert("Produto " +TRB->PRODUTO+" não encontrado nesta Filial!!!")
				DbSelectArea("TRB")
				TRB->(DbSkip())
				IncProc()
				LOOP

			EndIf

			IF nReg > 0

				IF nReg > 1
					AAdd(aCols,ARRAY(Len(aHeader)+1))
				EndIf

				// INICIALIZA CAMPOS DEFAULT COM INICIALIZADOR PADRAO
				For I := 1 To Len(aHeader)
					IF !(AllTrim(aHeader[I][2]) $ "C1_ITEM/C1_PRODUTO/C1_DESCRI/C1_UM/C1_QUJE/C1_EMISSAO/C1_DATPRF/C1_LOCAL/C1_SEGUM/C1_OBS/C1_ALI_WT/C1_REC_WT")
						If I < 32 // Nao faz o criavar para os campos ALIAS E Recno WT
							aCols[Len(aCols)][I] := CRIAVAR(aHeader[I][2])
						EndIf
					EndIf
				Next I

				IF nReg > 1
					N := nReg
					GdFieldPut("C1_ITEM"	, StrZero(N,4)		,N)
				EndIf

				DbSelectArea("SB2");DbSetOrder(1)
				DbSeek(xFilial("SB2")+cProduto+cArmazem,.F.)
				GdFieldPut("C1_PRODUTO"	, cProduto	,N)//;IIF(EXISTTRIGGER( "C1_PRODUTO" )	, RunTrigger(2, N),"")

				IF LPOS
					__READVAR:="M->C1_PRODUTO"
					POSICIONE("SX3",2,"C1_PRODUTO","X3_CAMPO")
					LPOS := .F.
				EndIf

				// Teste CRIS
				CheckSx3("C1_PRODUTO",cProduto)
				RunTrigger(2, N,"C1_PRODUTO")

				GdFieldPut("C1_DESCRI"	, cDescr	,N)//;IIF(EXISTTRIGGER( "C1_DESCRI" 	)	, RunTrigger(2, N),"")
				GdFieldPut("C1_UM"		, cUnid		,N)//;IIF(EXISTTRIGGER( "C1_UM" 		)	, RunTrigger(2, N),"")
				GdFieldPut("C1_QUANT"	, nQuant	,N)//;IIF(EXISTTRIGGER( "C1_QUANT" 	)	, RunTrigger(2, N),"")//LIMPA Produto

				//			MAFISREF( 'IT_QUANT', 'MT120', GDFIELDGET( 'C1_QUANT', N ) )//LIMPA Produto
				//			nPreco := BUSCAPR(nPreco)
				SB1->(DbSeek(xFilial("SB1")+aCols[N,2],.F.))
				nPreco := SB1->B1_PRV1

				GdFieldPut( 'C1_VUNIT', nPreco, N )
				//			GdFieldPut( 'C1_QUJE', NOROUND( GDFIELDGET( 'C1_VUNIT', N ) * GDFIELDGET( 'C1_QUANT', N ), TAMSX3( 'C1_QUJE' )[ 2 ] ), N )

				GdFieldPut("C1_EMISSAO"	, dDataBase	,N)//;IIF(EXISTTRIGGER( "C1_EMISSAO" 	)	, RunTrigger(2, N),"")

				///02/12/2011 - Julo Jacovenko - chamado AAZU2A
				///pegar data
				GdFieldPut("C1_DATPRF"	, TRB->DATAE	,N)//;IIF(EXISTTRIGGER( "C1_EMISSAO" 	)	, RunTrigger(2, N),"")

				GdFieldPut("C1_LOCAL"	, cArmazem	,N)//;IIF(EXISTTRIGGER( "C1_LOCAL" 	)	, RunTrigger(2, N),"")
				GdFieldPut("C1_SEGUM"	, cSegUnid	,N)

				//02/12/2011 - Julio Jacovenko - chamado AAZU2A
				///COLOCA A C1_OBS
				GdFieldPut("C1_OBS"	, TRB->OBS  	,N)//;IIF(EXISTTRIGGER( "C1_DESCRI" 	)	, RunTrigger(2, N),"")

				//Inserido por Edivaldo Goncalves Cordeiro - Tratamento para novos campos
				GdFieldPut("C1_TPSC"	 , '1'   	,N)
				GdFieldPut("C1_MODAL"	 , Space(1)	,N)
				GdFieldPut("C1_TPMOD"	 , ' '   	,N)
				GdFieldPut("C1_CODED"    , Space(1)	,N)
				GdFieldPut("C1_NUMPR"    , Space(1)	,N)
				GdFieldPut("C1_ORCAM"    , Space(1)	,N)
				GdFieldPut("C1_ORIGEM"   , Space(1)	,N)
				GdFieldPut("C1_FLAGGCT"  , Space(1)	,N)
				GdFieldPut("C1_PROGRAM"  , Space(1)	,N)

				aCols[Len(aCols)][Len(aHeader)+1] := .F.

			EndIf
			DbSelectArea("TRB")
			TRB->(DbSkip())
			IncProc()

		EndDo

		IF nReg == 0
			Alert("Nenhum Registro Importado!!!")
		Else
			Alert("Importados " + cValToChar( nCount ) + "  Registros!!!")
		EndIf

	EndIf

	TRB->(DbCloseArea())
	SB1->(DbSeek(xFilial("SB1")+aCols[1,2],.F.))

	

Return()
#Include "Totvs.ch"

//#Include "FIVEWIN.CH"
//#Include "RWMAKE.CH"

#Define ENTER 			( chr(13) + chr(10) )
#Define _TAB_ 			( chr(9) )
#Define CLR_BLUE   8388608               // RGB(   0,   0, 128 )


*******************************************************************************
User Function TMKCBPRO(aBtnSup) //| Definicao de Novos Botoes na Barra Superior na Tela da Verdade |
*******************************************************************************

	Aadd( aBtnSup, { "CLIENTE" 		, &("{|| U_AltCliVen() }"		), OemToAnsi("Alterar Cliente"	)})
	Aadd( aBtnSup, { "PROJETPMS" 	, &("{|| U_MaisBotoes() }"	), OemToAnsi("Outras Opções"		)})

Return(aBtnSup)
*******************************************************************************
User Function UltPrec() //| Visualizacao dos Ultimos Precos praticados para o cliente em questão |
*******************************************************************************
	Local aArea	      := GetArea()
	Local cCodCli     := ""
	Local cLojCli     := ""
	Local cProduto    := ""
	Local cTipoAte
	Private cCadastro := OemtoAnsi("Últimos preços do cliente")


	If (nFolder == 1 .AND. (cTipoAte == "2"	.Or. cTipoAte == "4")) .Or. (nFolder == 2) // Televendas
		cCodCli  := M->UA_CLIENTE
		cLojCli  := M->UA_LOJA
		cProduto := GDFieldGet('UB_PRODUTO',n)
	Endif

	//| Valida se o cliente, loja e produto foram informados.
	If Empty(cCodCli) .or. Empty(cLojCli) .or. Empty(cProduto)
		Aviso( OemToAnsi('Item de Pesquisa Não Informado'), OemToAnsi('Código/Loja do cliente ou código do produto não informados.') ,{ 'OK' } )
		Return(.F.)
	Endif

	DbSelectarea("SA7")
	DbSetorder(1)
	If DbSeek( xFilial("SA7")+ cCodCli + cLojCli + cProduto)

		//| Envia para processamento dos Gets
		nOpcA:=AxVisual("SA7",RECNO(),2)

		RestArea(aArea) //DbSelectarea(cAliasOld)
	Endif

Return(.T.)
*******************************************************************************
USER Function MaisBotoes() //| Janela com Botoes adicionais na Tela da Verdade|
*******************************************************************************
	Local oDlgEsp
	Local oBar
	Local aBtn := array(4)

	DEFINE MSDIALOG oDlgEsp TITLE Oemtoansi("Outras Opções")  FROM 138,000 TO 170,500 PIXEL

	DEFINE BUTTONBAR oBar 3D TOP OF oDlgEsp

	DEFINE BUTTON aBtn[1]  RESOURCE "VENDEDOR" OF oBar When .T. TOOLTIP  OemToAnsi("Representantes") ACTION( U_TVEXEC( {||FATA320() } ), oDlgEsp:End() )

	DEFINE BUTTON aBtn[3]  RESOURCE "AREA" OF oBar When .T. TOOLTIP  OemToAnsi("Suspects") ACTION( TMKA341(), oDlgEsp:End() )

	DEFINE BUTTON aBtn[4]  RESOURCE "SOLICITA_MDI" OF oBar When .T. TOOLTIP  OemToAnsi("Solicitacoes de Compra") ACTION( U_TVEXEC({||MATA110()}), oDlgEsp:End() )

	DEFINE BUTTON aBtn[2]  RESOURCE "BMPPOST" OF oBar When .T. TOOLTIP  OemToAnsi("Envio dos dados dos produtos por e-mail") ACTION( U_MEmail(), oDlgEsp:End() )

	DEFINE BUTTON aBtn[2]  RESOURCE "WEB" OF oBar When .T. TOOLTIP  OemToAnsi("Banco de Conhecimento de Produto") ACTION( U_BCOCONPR(), oDlgEsp:End() )

	// Jorge Oliveira - 27/01/2011 - Coloca o botao na tela se for MDI
	If SetMDIChild()
		DEFINE BUTTON aBtn[2]  RESOURCE "COPYUSER" OF oBar When .T. TOOLTIP  OemToAnsi("Copia de Atendimento") ACTION( U_COPIATT(), oDlgEsp:End() )
	EndIf

	DEFINE BUTTON aBtn[2]  RESOURCE "AGENDA" OF oBar When .T. TOOLTIP  OemToAnsi("Agendar PMC") ACTION( U_IMDAGPMC(), oDlgEsp:End() )

	ACTIVATE MSDIALOG oDlgEsp NOCENTER

Return NIL
*******************************************************************************
User Function TVEXEC( bFuncao ) // Executa Rotinas na Tela da Verdade Recuperando o Header, Acol e Variavel N
*******************************************************************************
	Local aColsAnt   := aClone(aCols)
	Local aHeaderAnt := aClone(aHeader)
	Local nAnt       := n
	Local aRotBack   := aClone(aRotina)

	// Executa a funcao passada por parametro
	Eval(bFuncao)

	aCols := aClone(aColsAnt)
	aHeader := aClone(aHeaderAnt)

	n := nAnt
	aRotina := aClone(aRotBack)

Return NIL

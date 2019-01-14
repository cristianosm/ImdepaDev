#Include "Totvs.ch"
#Include "Tbiconn.ch"

// Valores Padroes para os Campos
#Define P_X3USADO  "€€€€€€€€€€€€€€ "
#Define P_X3RESER  "þÀ"

// Posicoes Array aSxx
#Define LTAM 3 // Numero de Posicoes do Array aSxx
#Define _PES 1 // Dados para Pesquisa na Tabela pelo Registro
#Define _CPO 2 // Nome do Campo a ser alterado na Tabela
#Define _VAL 3 // Novo Valor que sera Gravado

#Define _TOKEN_ "|" /// Token delimitador usado no arquivo TXT

#Define UM	1
#Define _CHECAGEM_ "CHE" /// Arquivo com tabelas a serem checadas..

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNÇÃO   : CSM_Compat   | AUTOR : Cristiano Machado | DATA : 20/12/2018 **
**---------------------------------------------------------------------------**
** DESCRIÇÃO:  **
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
*******************************************************************************
User Function CSM_Compat()
*******************************************************************************

	Local cEmpresa := "01"
	Local cFilLog  := "01"
	Local cFuncao  := "CSM_COMPAT"

	PREPARE ENVIRONMENT EMPRESA cEmpresa FILIAL cFilLog FUNNAME cFuncao TABLES "SX2","SX3","SX6","SIX"

	Principal() // Rotina Principal...

	CheckTab() // Executa checagem de estrutura de tabela...

	CallProc() // Chama Eventuais procedures....


	RESET ENVIRONMENT

	Return
*******************************************************************************
Static Function Principal() // Parametros e Variaveis Envolvidas
*******************************************************************************

	GLog("Iniciando Compatibilização")

	//GLog( "P_X3USADO => " + (P_X3USADO) + " P_X3RESER => " + (P_X3RESER) + " " )

	ParVar() 	// Parametros e Variaveis Envolvidas

	SxxAjus(cTab := "SX2") // Tabelas

	SxxAjus(cTab := "SX3") // Campos

	SxxAjus(cTab := "SIX") // Indices

	SxxAjus(cTab := "SX6") // Parametros

	SxxAjus(cTab := "CHE") // Checagem de tabelas em Geral

	GLog("Finalizando Compatibilizações")

	Return
*******************************************************************************
Static Function ParVar() // Parametros e Variaveis Envolvidas
*******************************************************************************

	// Define Estrutura do Array aSX?

	//| Estrutura Array aSxx:
	//| _PES => Chave utilizado para Pesquisa na Tabela especifica utilizando indice 1
	//| _CPO => Campo que vai receber o valor na Tabela
	//| _VAL => Valor a ser gravado
	_SetOwnerPrvt( 'aSxx' , {} )

	_SetOwnerPrvt( 'cTab' , "" )

	DbSelectArea("SX2");DbSetOrder(1)
	DbSelectArea("SX3");DbSetOrder(2)

	Return
*******************************************************************************
Static Function SxxAjus(cTab) 	// Ajustes na SX2 - Tabelas
*******************************************************************************

	Local nTpC		:= ""
	Local nOp		:= "" // Tipode de Operacao A-Alteracao , I-inclusao

	Local cChavPesq	:= "" // Armazena a Chave de Pesquisa
	Local cCampo	:= "" // Armazena o Nome do Campo a ser atualizado
	Local cConteudo	:= "" // Armazena o Comteudo do Campo a Ser Alimentado
	Local cTabCpo 	:= "" // Alias mais Campo da Tabela

	cTab := Upper(cTab)

	GLog("Iniciando Ajustes na Tabela " + cTab )

	GetAsx() // Alimenta Array SX2

	If Len(aSxx) <= 0
		GLog("Nada foi Ajustado na Tabela " + cTab )
		Return
	EndIf

	DbSelectArea(cTab)
	DbGoTop()

	For nP := 1 To Len(aSxx)

		cChavPesq	:= (aSxx[nP][_PES])

		If cTab == _CHECAGEM_

			Check( cChavPesq )

		Else

			// Atualiza as Variaveis Bases...
			cCampo		:= Alltrim( aSxx[nP][_CPO] )
			cTabCpo 	:= cTab + "->" + cCampo
			cConteudo	:= Alltrim( DecodeUtf8( aSxx[nP][_VAL] ))

			// Obtem o Tipo do Campo que irá receber o Valor existente na Tabela SX em questao ...
			GetTpCpo( cCampo, @nTpC )

			If (&cTab.)->(DbSeek( cChavPesq ,.F.))
				RecLock(cTab,.F.)
				nOp := "A"
			Else
				RecLock(cTab,.T.)
				nOp := "I"
			EndIf

			// Tratamento de Campos Especiais... Excessoes Tabela SX3 ...
			If cTab == "SX2" .And. nOp == "I" // Inclusão de Registro Novo no SX2
				SX2->X2_CHAVE := cChavPesq
				&cTabCpo. := cConteudo
			
			ElseIf cTab == "SX3" .And. cCampo == "X3_USADO" // Campos USADO ja possui conteudo Padrao Definido
				&cTabCpo. := ( P_X3USADO )

			ElseIf cTab == "SX3" .And. cCampo == "X3_RESERV" // Campos RESERV ja possui conteudo Padrao Definido
				&cTabCpo. := ( P_X3RESER )

			ElseIf cTab == "SX6" .And. cCampo == "X6_VAR" .And. nOp == "I" // Caso seja inclusao de Parametro por Filial deve tratar para Funcionar a pesquisa nas proximas buscas ja cadastrando a filial utilizada na pesquisa

				If !Empty( Substr(cChavPesq,1,2) ) // Identifica que se trava de Parametro por Filial
					SX6->X6_FIL := Substr(cChavPesq,1,2)
				EndIf

				&cTabCpo. := cConteudo

			ElseIf cTab == "SIX" .And. cCampo == "INDICE" .And. nOp == "I" // Caso seja inclusao de Parametro por Filial deve tratar para Funcionar a pesquisa nas proximas buscas ja cadastrando a filial utilizada na pesquisa

				SIX->ORDEM := Substr(cChavPesq,4,1)
				&cTabCpo. := cConteudo

			Else

				If nTpC == "N" // Campos Tipo =  NUMERICO
					&cTabCpo. := Val(cConteudo)
				Else
					&cTabCpo. := cConteudo
				EndIf

			EndIf

			GLog(nOp+":"+Upper(cTab)+": Pesq[" + cChavPesq + Replicate(" ",12-Len(cChavPesq)) + "] Campo[" + cTabCpo + Replicate(" ",15-Len(cTabCpo)) + "] Conteudo["+ Alltrim(cValToChar(&cTabCpo.)) + Replicate(" ",50-Len(Alltrim(cValToChar(&cTabCpo.)))) + "] ")

			MsUnlock()

		EndIf

	Next

	GLog("Finalizado os Ajustes na Tabela " + cTab )

	Return
*******************************************************************************
Static Function GetaSX(cNome)//| Converte o Texto em Array para Montar Desenho
*******************************************************************************

	Local cArq := "\systemload\"

	Default cNome := cTab

	cArq += cNome + "_dic.csv"

	aSxx := {}

	If !File(cArq)

		Return

	EndIf

	FT_FUse(cArq)
	FT_FGoTop()
	While !FT_FEOF()

		cLine  	:= FT_FReadLn()
		aLine	:= StrToKarr(cLine,_TOKEN_)

		If Len(aLine) == LTAM .Or. ( Len(aLine) == UM .and. cTab == _CHECAGEM_ )
			Aadd( aSxx, aLine )
		EndIf

		FT_FSkip()

	EndDo

	FT_FUse()

	Return
*******************************************************************************
Static Function GLog(cTxt)//| Converte o Texto em Array para Montar Desenho
*******************************************************************************

	cTxt := Alltrim(cTxt)

	Conout(" COMPAT - " + cTxt + Replicate(".",115-Len(cTxt)) + "| "+DToc(dDataBase)+" | "+Time()+" |" )

	Return
*******************************************************************************
Static Function CheckTab() // Executa checagem de estrutura de tabela...
*******************************************************************************

	Return
*******************************************************************************
Static Function CallProc() // Chama Eventuais procedures....
*******************************************************************************

	Return
*******************************************************************************
Static Function GetTpCpo(cTabCpo, nTpC) // Obtem o Tipo do Campo que irá receber o Valor existente na Tabela SX em questao ...
*******************************************************************************

	Local aStruct   := {}

	aStruct := ( &cTab. )->( DBStruct() )

	For nPC := 1 To Len(aStruct)

		If Alltrim(aStruct[nPC][1]) == Alltrim(cTabCpo)
			nTpC := Alltrim(aStruct[nPC][2])
			exit
		EndIf

	Next

	Return
*******************************************************************************
Static Function Check(cTab) // Obtem o Tipo do Campo que irá receber o Valor existente na Tabela SX em questao ...
*******************************************************************************

	Begin Sequence

		GLog("DbSelectArea Tabela [" + cTab + "]" )
		DbSelectArea(cTab)

		GLog("TcRefresh Tabela [" + cTab + "]" )
		TcRefresh( cTab )

		GLog("ChkFile Tabela [" + cTab + "]" )
		ChkFile( cTab, .F. )

		GLog("X31UpdTable Tabela [" + cTab + "]" )
		X31UpdTable( cTab )

		If __GetX31Error()
			GLog("X31UpdTable Erro [ No foi possvel abrir "+cTab+"010 exclusivo. ] ") // + __GetX31Trace() + " ]" )
		Endif
		
		GLog("TcRefresh Tabela [" + cTab + "]" )
		TcRefresh( cTab )


	End Sequence

Return 


/**************************************************************************************************

Exemplo de Cada Arquivo .... 

------------------ >>> SX2 .... /systemload/sx2_dic.csv *** Se precisar incluir campos....

ZCV|X2_PATH   |\DADOSADV\
ZCV|X2_ARQUIVO|ZCV010
ZCV|X2_NOME   |Itens do Volume
ZCV|X2_MODO   |E
ZCV|X2_MODOUN |E
ZCV|X2_MODOEMP|E
ZCV|X2_UNICO  |ZCV_FILIAL+ZCV_CODVOL+ZCV_CODPRO+ZCV_LOTE+ZCV_SUBLOT+ZCV_IDDCF+ZCV_SEQUEN
ZCV|X2_PYME   |N
ZCV|X2_MODULO |42
ZCV|X2_DISPLAY|ZCV_FILIAL+ZCV_CODVOL+ZCV_CODPRO+ZCV_LOTE+ZCV_SUBLOT+ZCV_IDDCF+ZCV_SEQUEN
ZCV|X2_POSLGT |2
ZCV|X2_CLOB   |2
ZCV|X2_AUTREC |2

------------------ >>> SX3 .... /systemload/sx3_dic.csv *** Se precisar incluir campos....
 
DB_PVOBS|X3_CAMPO  |DB_PVOBS
DB_PVOBS|X3_ARQUIVO|SDB
DB_PVOBS|X3_ORDEM  |73
DB_PVOBS|X3_TIPO   |C
DB_PVOBS|X3_TAMANHO|90
DB_PVOBS|X3_TITULO |Observ. PV
DB_PVOBS|X3_DESCRIC|Observ. PV
DB_PVOBS|X3_PICTURE|@!
DB_PVOBS|X3_USADO  |P_X3USADO 
DB_PVOBS|X3_RELACAO|  
DB_PVOBS|X3_RESERV |P_X3RESER
DB_PVOBS|X3_PROPRI |U
DB_PVOBS|X3_BROWSE |N
DB_PVOBS|X3_VISUAL |V
DB_PVOBS|X3_CONTEXT|V
DB_PVOBS|X3_INIBRW |  
DB_PVOBS|X3_IDXSRV |N
DB_PVOBS|X3_ORTOGRA|N
DB_PVOBS|X3_IDXFLD |N

------------------ >>> SX6 .... /systemload/sx6_dic.csv *** Se precisar incluir campos....

05IMD_ATCONF|X6_VAR|IMD_ATCONF
05IMD_ATCONF|X6_TIPO|C
05IMD_ATCONF|X6_DESCRIC|Código da atividade de conferência de separação
05IMD_ATCONF|X6_DESC1| 
05IMD_ATCONF|X6_CONTEUD|022
05IMD_ATCONF|X6_PROPRI|U

  IMD_VPALET|X6_VAR|IMD_VPALET
  IMD_VPALET|X6_TIPO|C
  IMD_VPALET|X6_DESCRIC|Sequencial proximo pallet de expedicao (Volumes)
  IMD_VPALET|X6_CONTEUD|00000000
  IMD_VPALET|X6_PROPRI|U

------------------ >>> SIX .... /systemload/six_dic.csv *** Se precisar incluir campos....

ZCV2|INDICE|ZCV
ZCV2|CHAVE|ZCV_FILIAL+ZCV_CODPRO+ZCV_LOTE+ZCV_SUBLOT+ZCV_IDDCF+ZCV_SEQUEN
ZCV2|DESCRICAO|Cod.Produto + Lote + SubLote + Seq.Servico + Seq.Docto
ZCV2|PROPRI|U
ZCV2|NICKNAME| 
ZCV2|SHOWPESQ|S

***************************************************************************************************/

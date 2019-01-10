#Include "Totvs.ch"
#Include "Tbiconn.ch"

// Valores Padroes para os Campos
#Define P_X3USADO  "���������������"
#Define P_X3RESER  "��"

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
** FUN��O   : CSM_Compat   | AUTOR : Cristiano Machado | DATA : 20/12/2018 **
**---------------------------------------------------------------------------**
** DESCRI��O:  **
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

	GLog("Iniciando Migracao")

	//GLog( "P_X3USADO => " + (P_X3USADO) + " P_X3RESER => " + (P_X3RESER) + " " )

	ParVar() 	// Parametros e Variaveis Envolvidas

	SxxAjus(cTab := "SX2") // Tabelas

	SxxAjus(cTab := "SX3") // Campos

	SxxAjus(cTab := "SIX") // Indices

	SxxAjus(cTab := "SX6") // Parametros

	SxxAjus(cTab := "CHE") // Checagem de tabelas em Geral

	GLog("Finalizando Migracao")

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

			// Obtem o Tipo do Campo que ir� receber o Valor existente na Tabela SX em questao ...
			GetTpCpo( cCampo, @nTpC )

			If (&cTab.)->(DbSeek( cChavPesq ,.F.))
				RecLock(cTab,.F.)
				nOp := "A"
			Else
				RecLock(cTab,.T.)
				nOp := "I"
			EndIf

			// Tratamento de Campos Especiais... Excessoes Tabela SX3 ...
			If cTab == "SX2" .And. nOp == "I" // Inclus�o de Registro Novo no SX2
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
Static Function GetTpCpo(cTabCpo, nTpC) // Obtem o Tipo do Campo que ir� receber o Valor existente na Tabela SX em questao ...
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
Static Function Check(cTab) // Obtem o Tipo do Campo que ir� receber o Valor existente na Tabela SX em questao ...
*******************************************************************************

	Begin Sequence

		GLog("DbSelectArea Tabela [" + cTab + "]" )
		DbSelectArea(cTab)

		GLog("TcRefresh Tabela [" + cTab + "]" )
		TcRefresh( cTab )

		GLog("ChkFile Tabela [" + cTab + "]" )
		ChkFile( cTab, .F. )

		GLog("TcRefresh Tabela [" + cTab + "]" )
		TcRefresh( cTab )

	End Sequence

Return 
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

#Define UM	1 
#Define _CHECAGEM_ "CHE" /// Arquivo com tabelas a serem checadas.. 

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNÇÃO   : MigColetores   | AUTOR : Cristiano Machado | DATA : 20/12/2018 **
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
User Function MigColetores()
*******************************************************************************

	Local cEmpresa := "01"
	Local cFilLog  := "01"
	Local cFuncao  := "MIGCOLETORES"
	

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
	
	Local cCpoTab 	:= "" // Campo da Tabela
	Local nTpC		:= ""
	Local nOp		:= "" // Tipode de Operacao A-Alteracao , I-inclusao
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
	
	
		If cTab == _CHECAGEM_
			
			Check( Alltrim( aSxx[nP][_PES]) )
			
		Else
	
		cCpoTab := cTab + "->" + Alltrim( aSxx[nP][_CPO] )
		
		GetTpCpo( aSxx[nP][_CPO], @nTpC ) // Obtem o Tipo do Campo que irá receber o Valor existente na Tabela SX em questao ... 
		
		If (&cTab.)->(DbSeek( aSxx[nP][_PES] ,.F.))
			RecLock(cTab,.F.)
			nOp := "A"
		Else
			RecLock(cTab,.T.)
			nOp := "I"
		EndIf
			
			// Tratamento de Campos Especiais... Excessoes Tabela SX3 ...
			If cTab == "SX3" .And. aSxx[nP][_CPO] == "X3_USADO" // Campos USADO ja possui conteudo Padrao Definido
				&cCpoTab. := ( P_X3USADO )
				
	
			ElseIf cTab == "SX3" .And. aSxx[nP][_CPO] == "X3_RESERV" // Campos RESERV ja possui conteudo Padrao Definido
				&cCpoTab. := ( P_X3RESER )
				

			ElseIf cTab == "SX6" .And. aSxx[nP][_CPO] == "X6_VAR" .And. nOp == "I" // Caso seja inclusao de Parametro por Filial deve tratar para Funcionar a pesquisa nas proximas buscas ja cadastrando a filial utilizada na pesquisa
				
				If !Empty( Substr(aSxx[nP][_PES],1,2) ) // Identifica que se trava de Parametro por Filial
					SX6->X6_FIL := Substr(aSxx[nP][_PES],1,2)
				EndIf
				
				&cCpoTab. := Alltrim( DecodeUtf8( aSxx[nP][_VAL] ))
			
			ElseIf cTab == "SIX" .And. aSxx[nP][_CPO] == "INDICE" .And. nOp == "I" // Caso seja inclusao de Parametro por Filial deve tratar para Funcionar a pesquisa nas proximas buscas ja cadastrando a filial utilizada na pesquisa
				
				SIX->ORDEM := Substr(aSxx[nP][_PES],4,1)
				&cCpoTab. := Alltrim( DecodeUtf8( aSxx[nP][_VAL] ))
			
			Else
				
				If nTpC == "N" // Campos Tipo =  NUMERICO
					&cCpoTab. := Val(aSxx[nP][_VAL])
				Else
					&cCpoTab. := Alltrim( DecodeUtf8( aSxx[nP][_VAL] ))
				EndIf

			EndIf
			
			GLog(nOp+":"+Upper(cTab)+": Pesq[" + aSxx[nP][_PES] + Replicate(" ",12-Len(aSxx[nP][_PES])) + "] Campo[" + cCpoTab + Replicate(" ",15-Len(cCpoTab)) + "] Conteudo["+ Alltrim(cValToChar(&cCpoTab.)) + Replicate(" ",50-Len(Alltrim(cValToChar(&cCpoTab.)))) + "] ")

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
		aLine	:= StrToKarr(cLine,';')
		
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
Static Function GetTpCpo(cCpoTab, nTpC) // Obtem o Tipo do Campo que irá receber o Valor existente na Tabela SX em questao ...  
*******************************************************************************
		
	Local aStruct   := {}
	
	aStruct := ( &cTab. )->( DBStruct() )
		
		For nPC := 1 To Len(aStruct)
				
			If Alltrim(aStruct[nPC][1]) == Alltrim(cCpoTab)
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

	GLog("TcRefresh Tabela [" + cTab + "]" )
	TcRefresh( cTab )

	End Sequence

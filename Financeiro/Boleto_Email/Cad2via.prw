#include "Totvs.ch"
#INCLUDE "Imdepa.ch"

#Define LILIFIL 	123  	//| Tamanho Limite da Linha no MultGet para efetuar as quebras no texto

#Define CONTEM 	7			//| Posicao Operador Contem no Array Operadores...
#Define NCONTEM 	8			//| Posicao Operador Nao Contem no Array Operadores...

#Define SIMPLES 	"S" 		//| Parametro da Funcao AddExpre() -> SIMPLES
#Define MULTIPLO "M" 		//| Parametro da Funcao AddExpre() -> MULTIPLO

#Define INICIO		"I"			//| Parametro usado no Controle de Botoes no Incio...

#Define FAKE 		1			//| Combo, lado do array que contem Valores Amigavais para apresentar ao usuario
#Define REAL 		2 			//| Combo, lado do array que contem Valores Reais para Filtro

#Define _SA1 		1			//| Array contendo Campos SA1 para combo
#Define _OPE 		2			//| Array contendo Operadores para combo
#Define _BOT 		3 			//| Array contendo Operador dos Botoes...

#Define _E_  		1 			//| Posicao E no Array Operador
#Define _OU_ 		2			//| Posicao OU no Array Operador
#Define _PA_ 		3			//| Posicao Parentese Aberto no Array Operador
#Define _PF_ 		4			//| Posicao Parentese Fechado E no Array Operador

#DEFINE BOTAO		1 			//| Indice Retorno da Funcao U_MEN()

#Define MARK     1 			//| Coluna indice Marcacao
#Define RECBOL		2			//| Posicao do Campo Codigo do Clienrte no Array Campos
#Define CODCLI		3			//| Posicao do Campo Codigo do Clienrte no Array Campos
#Define LOJCLI   4			//| Posicao do Campo Loja do Clienrte no Array Campos


#Define SEMPRE   1			//| Posicao Retorno do Botao SEMPRE na tela de Pergunta de Marcacao dos Clientes
#Define HOJE     2			//| Posicao Retorno do Botao HOJE na tela de Pergunta de Marcacao dos Clientes
#Define SIM      1			//| Posicao Retorno do Botao SIM na tela de Pergunta de Marcacao dos Clientes

#Define ARESET		{{'','','','','','','','','',''}}  /// Conteudo Padrao do Array utilizado no Browse...

#Define _ENTER Chr(10) + chr(13)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LIBRARY   ºAutor  ³Microsiga           º Data ³  07/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

*******************************************************************************
User Function Cad2Via()
*******************************************************************************

	local cFilFake	:= ""
	local aCores  	:= {	{ 'SA1->A1_RECBOLE=="H"' , 'BR_AZUL'  },;    // Ativo
										{ 'SA1->A1_RECBOLE=="S"' , 'BR_VERDE' },;
										{ 'SA1->A1_RECBOLE=="N"' , 'BR_CINZA' }	}    // Inativo
 
	Local nClickDef := 4

	// Variaveis Tela Greve
	Local 	aStruFile 		:= { { "BANCO" , "C" , 3, 0},{ "DESC" , "C" , 50, 0},{ "GREVE" , "C" , 3, 0},{ "DATAA" , "D" , 8, 0} }
	Local aStruIndex		:= { "BANCO" }
	Local cPath				:= Nil
	Local cNameFile		:= "CAD2VIAG"
	Local cDriver			:= Nil
	Local lReplace			:= .F.
	Local cPath				:= "\banco\"
 
	Private cAlias   	:= 'SA1'
	Private cCadastro 	:= "Cadastro de Clientes"
	Private aRotina    	:= {}       //"Legenda"
	
	Private cAliasGrev		:= "TGRE" //GetNextAlias()
	
	Public lFiltro			:= .F.
	Public lGreve 			:= .F.
 
	U_MyFile( aStruFile, aStruIndex, cPath, cNameFile, cAliasGrev, cDriver, lReplace )
 
	AADD(aRotina, { "Pesquisar"			, "AxPesqui" 									, 0, 1 })
	AADD(aRotina, { "Filtrar"     	, "U_Cad2ViaFil()" 							, 0, 2 })
	AADD(aRotina, { "Greve"     		, "U_Cad2Greve" 								, 0, 3 })
	AADD(aRotina, { "Marcar"		  		, "U_Cad2Marcar()"							, 0, 4 })
	AADD(aRotina, { "Alterar"		  		, "AxAltera"										, 0, 5 })
	AADD(aRotina, { "Legenda"     	, "U_Cad2ViaLeg()"  					  	, 0, 6 })
	
	DbSelectArea("SA1")
	DbSetOrder(1)
 
	mBrowse( ,,,,"SA1",,,,,nClickDef,aCores,,,,,,,,cFilFake)

Return()
*******************************************************************************
User Function Cad2ViaLeg() // Legenda da 2 Via
*******************************************************************************

	Private cCadastro := "Cadastro de Clientes"

	BrwLegenda(cCadastro , "Legenda" , {		{"BR_AZUL"		, "Recebe e-mail Hoje." 	} 	,;
		{"BR_VERDE"	, "Recebe e-mail Sempre."	}	,;
		{"BR_CINZA"	, "Nunca Recebe e-mail."	} } )
	
Return()
*******************************************************************************
User Function Cad2Marcar() /// Marca Clientes para Receber ou Nao Boletos...
*******************************************************************************

	If (SA1->A1_RECBOLE == "N") //| N‹o Recebe... Deseja incluir ?

		AdiClientes("T")

	ElseIf (SA1->A1_RECBOLE == "S" .OR. SA1->A1_RECBOLE == "H")

		RetClientes("T")  //| Recebe Deseja Excluir ?//

	EndIf

Return()
*******************************************************************************
User Function Cad2ViaFil() // Tela De Filtro....
*******************************************************************************
// Variaveis Logicas
	Private lTransparent := .F.
	Private lCnt_Parents := .F. ///	Controle de Parenteses na formacao da expressao

// Variaveis Caracter
	Private cCmb_Campo 		:= ""
	Private cCmb_Opera 		:= ""
	Private cCmb_Expre 		:= Space(250)
	Private cFilFake			:= ""
	Private cFilReal			:= ""
	
// Variaveis Numericas
	Private nCmb_Campo		:= 0
	Private nCmb_Opera		:= 0
	
	Private nTL					:= 10 // Tamanho em pixel da linha
	Private nTC					:= 8 // Tamanho em pixel da coluna
	Private n

// Variaveis Array
	Private aItens				:= MntArray() // Array Contendo Campos do SA1...
	Private aCmb_Campo		:= aItens[_SA1][FAKE] // Array Contendo Operadores...
	Private aCmb_Opera		:= aItens[_OPE][FAKE]// Array Contendo Operadores Botao...
	Private aCmb_Botoe		:= aItens[_BOT][FAKE]// Array Contendo Operadores Botao...
	Private aFiltro			:= {""}
	Private aBrowse			:= ARESET
	
// Variaveis Objetos
	Private oDlg
	Private oSay
	Private oGroupA
	Private oBrowse
	Private oCmb_Campo,oCmb_Opera,oCmb_Expre,oTMultiget
	Private oTBot_e,oTBot_ou, oTBot_ca,oTBot_cf,oTBot_Adic,oTBot_Limp,oTBot_Apli,oTBot_Mtod,oTBot_Incl,oTBot_Remo,oTBot_Expo,oTBot_Sair

	lFiltro := .T.

	MontaTela()
	
	lFiltro := .F.
	
Return()
*******************************************************************************
Static Function MontaTela()// Aqui Ž Contruida a Tela Principal....
*******************************************************************************

	oDlg 		:= TDialog():New(0, 0, (600), (650), "Filtro de Clientes",,,,,0, 16777215,,,.T.,,,,,,lTransparent)

	oGroupA	:= TGroup():New(nTL,nTC,100,320,'Objeto TGroup',oDlg,,,.T.)

	nLin := nTL * 2 // linha 2

	oSay					:= TSay():Create(oDlg,{||'Campo Cliente:'}		,nLin,nTC * 03,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	oSay					:= TSay():Create(oDlg,{||'Operador:'}	,nLin,nTC * 12,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	oSay					:= TSay():Create(oDlg,{||'Conteudo:'}	,nLin,nTC * 21,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)

	nLin := nTL * 3 // linha 3

	oCmb_Campo 	:= TComboBox():New(nLin,nTC*3	,{|u|if(PCount()>0,cCmb_Campo:=u,)}, aCmb_Campo,60,20,oDlg,,{||},,,,.T.,,,,,,,,,)
	oCmb_Campo:Select(1)
		
	oCmb_Opera 	:= TComboBox():New(nLin,nTC*12,{|u|if(PCount()>0,cCmb_Opera:=u,)}, aCmb_Opera,60,20,oDlg,,{|| nCmb_Campo:=Ascan(aCmb_Opera,cCmb_Campo)},,,,.T.,,,,,,,,,)
	oCmb_Opera:Select(1)
		
	oCmb_Expre 	:= TGet():Create( oDlg,{|u|if(Pcount()>0,cCmb_Expre:=u,cCmb_Expre)},nLin,nTC*21,103,001,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cCmb_Expre,,,, )
	oTBot_e 			:= TButton():Create( oDlg	,nLin,nTC*35	,"e"				,{||AddExpre(SIMPLES,_E_)}	,11			,11			,		,			,		,.T.			,		,			,		,			,  			,		)
		
	oTBot_ou			:= TButton():Create( oDlg	,nLin,nTC*37	,"ou"			,{||AddExpre(SIMPLES,_OU_)}	,11			,11			,		,			,		,.T.			,		,			,		,			,  			,		)
		
		
	nLin := nTL * 4.5 // linha 4.5

	oTBot_Adic		:= TButton():Create( oDlg,nLin,nTC*21,"Adicionar"		,{||AddExpre(MULTIPLO,oCmb_Campo:nAt,oCmb_Opera:nAt,cCmb_Expre)  }	,46,10,,,,.T.,,,,,,)
	oTBot_Limp		:= TButton():Create( oDlg,nLin,nTC*28,"Limpar"				,{||ResetaVar("MULT")}			,46,10,,,,.T.,,,,,,)
	oTBot_Ca			:= TButton():Create( oDlg,nLin,nTC*35,"("						,{||AddExpre(SIMPLES,_PA_)}	,11,11,,,,.T.,,,,,,)
	oTBot_Cf			:= TButton():Create( oDlg,nLin,nTC*37,")"						,{||AddExpre(SIMPLES,_PF_)}	,11,11,,,,.T.,,,,,,)
		
		
	nLin := nTL * 5 // linha 5

	oSay					:= TSay():Create(oDlg,{||'Filtro:'}	,nLin,nTC * 03,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)

	nLin := nTL * 6 // linha 6

	oTMultiget 	:= tMultiget():New( nLin, nTc*3, {| u | if( pCount() > 0, cFilFake := u, cFilFake ) },oDlg, 246, 27, , , , , , .T. )
	oTBot_Apli 	:= TButton():Create( oDlg,nLin,nTC*35,"Aplicar"		,{||AplicFil()}	,27,27,,,,.T.,,,,,,)
		
	nLin := nTL * 11 // linha 11

	oBrowse 	:= TCBrowse():New( nLin	,nTC*01	,312,160,,aCmb_Campo,{5,30,30,30,30,30},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
		
	AtuBrowse()
		
	oBrowse:bLDblClick   := { || aBrowse[oBrowse:nAt][MARK] := Iif( Empty(aBrowse[oBrowse:nAt][MARK]) ,'X',Space(2) ) }
		
	nLin := nTL * 27 // linha 24

	oGroupB		:= TGroup():New(nLin,002,100,100,'Objeto ',oDlg,,,.T.)

	nLin := nTL * 28 // linha 28

	oTBot_Mtod		:= TButton():Create( oDlg,nLin,nTC*01,"Selecionar"		,{||MarcaTodos()}		,47,16,,,,.T.,,,,,,)
	oTBot_Expo		:= TButton():Create( oDlg,nLin,nTC*08,"Exportar"			,{||ExpClientes()}		,47,16,,,,.T.,,,,,,)
	oTBot_Incl		:= TButton():Create( oDlg,nLin,nTC*20,"Incluir"			,{||AdiClientes("A")}	,47,16,,,,.T.,,,,,,)
	oTBot_Remo		:= TButton():Create( oDlg,nLin,nTC*27,"Excluir"			,{||RetClientes("A")}	,47,16,,,,.T.,,,,,,)
	oTBot_Sair		:= TButton():Create( oDlg,nLin,nTC*34,"Sair"					,{||oDlg:End()}			,47,16,,,,.T.,,,,,,)

	ControleBot(INICIO)

	oDlg:Activate(,,,.T.,{||('Finalizando...'),.T.},,{||('Iniciando...')} )

Return()
*******************************************************************************
Static Function MntArray()// Monta os Array's que ser‹o utilizados no 
*******************************************************************************
	Local aArray1  := {}
	Local aArray2  := {}
	Local aArray3  := {}
	Local aArrayG  := {}

	aadd(	aArray1 , { " " 					,	"Rec.Bol?"			,"Codigo"  	,"Loja" 			,"Nome" 			, "CNPJ"		,	"Estado" 		,"Municipio"		,"Cod.Gerente" , "Filial"				}	)
	aadd(	aArray1 , { " A1_FILIAL "	,	" A1_RECBOLE "	," A1_COD "	," A1_LOJA "	," A1_NOME "	, "A1_CGC"	,  " A1_ESTC " ," A1_MUNC " 	," A1_GERVEN "	, " A1_FILCLI "	}	)

	aadd(	aArray2 , { "Igual a" 		,"Diferente de"	,"Menor que"	,"Menor ou Igual a"	,"Maior que"		,"Maior ou Igual a"	,"Contem "	,"Nao Contem "	}	)
	aadd(	aArray2 , { " = " 				," <> " 					," < "				," <= "						," > "					," >= "						," LIKE "	," NOT LIKE " 	}	)
	
	aadd(	aArray3 , { "e" 			,"ou"		,"("			,")"			}	)
	aadd(	aArray3 , { " AND " 	," OR " 	," ( "		," ) "		}	)
			
	aArrayG :=  { aArray1 , aArray2 ,  aArray3  }

Return(aArrayG)
*******************************************************************************
Static Function AplicFil()// Aplica o Filtro conforme Express‹o criada...
*******************************************************************************

// Executa a Query para Filtras os Clientes conforme Filtro Criado...
	ExecQuery()

// Alimenta Array do Browse com Resultado da Query
	CarBrowse()

	// Ativa os Botoes 
	If Len(aBrowse) > 0
		oTBot_Mtod:Enable()
		oTBot_Expo:Enable()
		oTBot_Incl:Enable()
		oTBot_Remo:Enable()
	EndIf

Return()
*******************************************************************************
Static Function CarBrowse()// Alimenta Array do Browse com Resultado da Query e/ou atualiza
*******************************************************************************

	aBrowse := U_TabToArray("FIL", .F.)

	AtuBrowse()

Return()
*******************************************************************************
Static Function AtuBrowse()// Atualiza Objetos e Variaveis relacionada ao TCBrowse
*******************************************************************************

	oBrowse:SetFocus()

	oBrowse:SetArray(aBrowse)

	oBrowse:ResetLen()

	oBrowse:GoTop()

	If lGreve

		oBrowse:bLine := {|| {	aBrowse[oBrowse:nAt,01],;
			aBrowse[oBrowse:nAt,02],;
			aBrowse[oBrowse:nAT,03],;
			aBrowse[oBrowse:nAt,04] } }
	
	ElseIf lFiltro
	
		oBrowse:bLine := {|| {	aBrowse[oBrowse:nAt,01],;
			if(aBrowse[oBrowse:nAt,02]=="S","Sempre",If(aBrowse[oBrowse:nAt,02]=="H","Hoje",If(aBrowse[oBrowse:nAt,02]=="N","Nunca"," " ))),;
			aBrowse[oBrowse:nAt,03],;
			aBrowse[oBrowse:nAT,04],;
			aBrowse[oBrowse:nAt,05],;
			aBrowse[oBrowse:nAt,06],;
			aBrowse[oBrowse:nAt,07],;
			aBrowse[oBrowse:nAt,08],;
			aBrowse[oBrowse:nAt,09],;
			aBrowse[oBrowse:nAt,10] } }
	
	EndIf

	oBrowse:Refresh()

Return()
*******************************************************************************
Static Function ExecQuery()// Executa a Query para Filtras os Clientes conforme Filtro Criado...
*******************************************************************************
	Local cSql := ""

	If Select("FIL") <> 0
		DbCloseArea("FIL")
	EndIf

	cSql := " Select "//  '.T.' A1_BROWSE,  "

	For n := 1 To Len(aCmb_Campo)
		cSql +=  aItens[_SA1][REAL][n] + ","
	Next
	cSql := Substr(cSql,1,Len(cSql)-1) // retirar ultima , para evitar erro
	cSql += " From  SA1010  Where "
	cSql += cFilReal
	cSql += " AND A1_FILIAL  = '"+xFilial("SA1")+ "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY A1_COD, A1_LOJA "
 
	U_ExecMySql(cSql,"FIL","Q",.F.)

Return
*******************************************************************************
Static Function AddExpre(xTp, nP1, nP2, cExpre)// Adiciona expressao a memo e a varivavel filtro da query
*******************************************************************************
	Local nPcC			:= 0 // Posicao Combo Campos
	Local nPcO			:= 0 // Posicao Combo Operadores
	Local nPcB			:= 0 // Posicao Array Botoes

	Default xTp		:= SIMPLES  /// Tipo de Chamada... S-Simples... ou ...M->Multipla
	Default cExpre	:= ""

	If ( xTp == SIMPLES )
		
		AddPalavra(aITens[_BOT][REAL][nP1] , aITens[_BOT][FAKE][nP1] )
	
	ElseIf ( xTp == MULTIPLO )

		AddPalavra(aITens[_SA1][REAL][nP1] 	, aITens[_SA1][FAKE][nP1] )
		AddPalavra(aITens[_OPE][REAL][nP2] 	, aITens[_OPE][FAKE][nP2] )
		
		If ( nP2 == CONTEM .Or. nP2 == NCONTEM )
			AddPalavra( "'%"+Alltrim(cExpre)+"%'" 	, "'"+Alltrim(cExpre)+"'" )
		Else
			AddPalavra( "'"+Alltrim(cExpre)+"'" 		, "'"+Alltrim(cExpre)+"'" )
		EndIf
		
		ResetaVar()
	
	EndiF

	// Controle de Botoes.... Habilita e Desabilita...
	ControleBot(xTp,nP1)


Return()
*******************************************************************************
Static Function ControleBot(xTp,nP1)// Controle Logico de Bloqueio/Desbloqueio dos botoes que formam as expressoes
*******************************************************************************

	Default xTp 	:= 0
	Default nP1	:= 0


	If  ( xTp == INICIO )
	
		lCnt_Parents := .F.
		
		oTBot_Adic:Enable()
		oTBot_e:Disable()
		oTBot_ou:Disable()
		oTBot_Ca:Enable()
		oTBot_Cf:Disable()
		oTBot_Apli:Disable()
		
		oTBot_Mtod:Disable()
		oTBot_Expo:Disable()
		oTBot_Incl:Disable()
		oTBot_Remo:Disable()

	ElseIf  ( xTp == MULTIPLO ) // Adicionar ...

		oTBot_Adic:Disable()
		oTBot_e:Enable()
		oTBot_ou:Enable()
		
		If lCnt_Parents
			oTBot_Ca:Disable()
			oTBot_Cf:Enable()
			oTBot_Apli:Disable()
		Else
			oTBot_Ca:Disable()
			oTBot_Cf:Disable()
			oTBot_Apli:Enable()
		EndIf

	ElseIf ( xTp == SIMPLES )

		If  nP1 == _E_
				
			oTBot_Adic:Enable()
			oTBot_e:Disable()
			oTBot_ou:Disable()
			If lCnt_Parents
				oTBot_Ca:Disable()
				oTBot_Cf:Disable()
			Else
				oTBot_Ca:Enable()
				oTBot_Cf:Disable()
			EndIf
			oTBot_Apli:Disable()
				
		ElseIf 		nP1 == _OU_

			oTBot_Adic:Enable()
			oTBot_e:Disable()
			oTBot_ou:Disable()
			If lCnt_Parents
				oTBot_Ca:Disable()
				oTBot_Cf:Disable()
			Else
				oTBot_Ca:Enable()
				oTBot_Cf:Disable()
			EndIf
			oTBot_Apli:Disable()
				
		ElseIf 		nP1 == _PA_

			lCnt_Parents := .T.
			
			oTBot_Adic:Enable()
			oTBot_e:Disable()
			oTBot_ou:Disable()
			oTBot_Ca:Disable()
			oTBot_Cf:Disable()
			oTBot_Apli:Disable()
				
		ElseIf 		nP1 == _PF_

			lCnt_Parents := .F.
	
			oTBot_Adic:Disable()
			oTBot_e:Enable()
			oTBot_ou:Enable()
			oTBot_Ca:Disable()
			oTBot_Cf:Disable()
			oTBot_Apli:Enable()

		EndIf
		
	EndIF
								
Return()
*******************************************************************************
Static Function AddPalavra(cReal, cFake)// adiciona cada palavra na expressao
*******************************************************************************
	Local cAux 	:= " "	+Alltrim(cFake)								//|  Variavel que recebe express‹o...
	local nTAr		:= Len(aFiltro)											//|  Numero de Linhas que existe no aFiltro
	Local nTUL		:= Iif(nTAr>0,Len(aFiltro[nTAr]),1)		//|  Tamanho da ultima linha do aFiltro

	cFilReal += cReal

	If ( nTUL + Len(cAux) < LILIFIL )
		aFiltro[nTAr] +=  cAux
	Else
		aFiltro[nTAr] += _ENTER
	
		Aadd( aFiltro , cAux  )
	
	EndIf

	cFilFake := ""
	For i := 1 To Len(aFiltro)
		cFilFake += aFiltro[i]
	Next

Return()
*******************************************************************************
Static Function ResetaVar(cQuem) //Reseta os filtros.... e Resultados...
*******************************************************************************

	Default cQuem := ""

	If ( cQuem=="MULT" )
		
		cFilFake		:= ""
		cFilReal		:= ""
		aFiltro		:= {""}
		
		aBrowse 		:= ARESET
		
		AtuBrowse()
		
		ControleBot(INICIO)
		
	Else

		oCmb_Expre:cText := cCmb_Expre := Space(250)
		oCmb_Expre:CtrlRefresh()
		oCmb_Expre:Refresh()

	EndIf

Return()
*********************************************************************
Static Function ExpClientes()// Exporta os clientes filtrados para arquivo csv que eh enviado por email...
*********************************************************************
	Local aBroeHeader	:= {}
	Local cArquivo 		:= ""
	
	aAdd( aBroeHeader	, aCmb_Campo 	)
	For i:=1 To Len(aBrowse)
		aAdd( aBroeHeader 	, aBrowse[i] 	)
	Next
	
	cArquivo := 	U_ArrayToCsv(aBroeHeader)


	U_EnvMyMail("","","","Clientes Boleto Mail",_ENTER + _ENTER + "Anexo segue arquivo .csv com filtro aplicado... ","\"+cArquivo,.T.)


Return()
*********************************************************************
Static Function AdiClientes(cQuem) //| Inclui clientes no recebimento de Boletos por email...
*********************************************************************
	Local cCaption 	:= "Incluir"
	Local cSubTit 		:= "Aten‹o"
	Local cMensagem 	:= "Marcar este(s) Cliente(s) para receber(em) e-mail com instrucao de pagamento dos seus titulos ? "
	Local aBotoes		:= {"Sempre","Hoje","Cancelar"}
	Local aRet				:= {}
	
	Default	cQuem	:= "A" /// .T. = Array   .... .F. = Tabela
	
	aRet := U_Men(cCaption, cSubTit, cMensagem, aBotoes )

	If aRet[BOTAO] == SEMPRE
		MarkCli("S",cQuem) //
	ElseIf aRet[BOTAO] == HOJE
		MarkCli("H",cQuem) //
	EndIf
	
Return()
*********************************************************************
Static Function RetClientes(cQuem) //| Excluir Clientes do Recebimento de Boletos por email...
*********************************************************************

	Local cCaption 	:= "Excluir"
	Local cSubTit 		:= "Aten‹o"
	Local cMensagem 	:= "Remover este(s) Cliente(s) do recebimento de e-mail com instrucao de pagamento dos seus titulos ?"
	Local aBotoes		:= {"Sim","Nao"}
	Local aRet				:= {}

	Default	cQuem	:= "A" /// .T. = Array   .... .F. = Tabela
	
	aRet := U_Men(cCaption, cSubTit, cMensagem, aBotoes )

	If aRet[BOTAO] == SIM
		MarkCli("N",cQuem) //
	EndIF
	
Return()
*********************************************************************
Static Function MarkCli(cOpc,cQuem) // Marca os Clientes ... Tabela SA1...cOpc:S-Sempre | H-Hoje | N-Nunca |  ..... cQuem: T-Tabela|A=Array
*********************************************************************
	Local cSqlP1 := " Update SA1010 Set A1_RECBOLE = '"
	Local cSqlP2 := "' Where A1_COD = '"
	Local cSqlP3 := "' AND A1_LOJA = '"
	Local cSqlP4 := "' "
	Local cSqlHJ := " AND A1_SALDUP > 1 "
	Local cSqlOK := ""

	Local nMark	:= 0

	If cQuem == "A"

		For i:= 1 To Len(aBrowse)
			
			If !Empty(aBrowse[i][MARK])
			
				cSqlOK := cSqlP1 + cOpc + cSqlP2 +aBrowse[i][CODCLI]+ cSqlP3 +aBrowse[i][LOJCLI]+ cSqlP4

				If cOpc == "H" // Tratar para Marcar Cliente como H apenas se ele possuir algum Titulo em Aberto...
					cSqlOK += cSqlHJ
				EndIf
				
				U_ExecMySql( cSqlOK ,"", "E",.F. )
				
				aBrowse[i][MARK] 	:= Space(2)
				aBrowse[i][RECBOL] := cOpc
					
				nMark += 1
				
			EndIf
			 
		Next

	ElseIf cQuem == "T"

		cSqlOK := cSqlP1 + cOpc + cSqlP2 +SA1->A1_COD+ cSqlP3 +SA1->A1_LOJA+ cSqlP4
	
		If cOpc == "H" // Tratar para Marcar Cliente como H apenas se ele possuir algum Titulo em Aberto...
			cSqlOK += cSqlHJ
		EndIf
	
		U_ExecMySql( cSqlOK ,"", "E",.F. )


		nMark += 1
			
	EndIf

	If nMark > 0
		Iw_MsgBox(cValToChar(nMark) + " Cliente(s) Marcado(s)... ","Atencao","INFO")
	EndIf
	
Return()
*********************************************************************
Static Function MarcaTodos()// Marca X clientes que vao receber as marcas....
*********************************************************************

	For i := 1 To Len(aBrowse)
			
		aBrowse[i][MARK] := If(Empty(aBrowse[i][MARK]),"X","  ")
		
	Next
			

Return()
*********************************************************************
User Function Cad2Greve()/// Menu de Greve
*********************************************************************

	SetPrvt("nTL,nTC,nLin,lTrans,oDlg,oSay,oTBot_GreG,oTBot_Sair")
	SetPrvt("oBrowse,aCampos,aBrowse,aBancExl")
	SetPrvt("cCmb_Greve,aCmb_Greve,oCmb_Greve")
	SetPrvt("cGet_Banco,cGet_Desc")
	
	lGreve := .T.
	
// Inicializa Variaveis....	
	PrepVars()

// Monta tela...
	MntTelaGreve()
	
// Atualiza Tabela apartir do Array
	AtuArrToTab()

	lGreve := .F.
	
Return()
*********************************************************************
Static Function PrepVars() // Preparar variaveis referente Cadastro de Bancos em Greve
*********************************************************************
	
	
	cCmb_Greve	:= "NAO"
	aCmb_Greve	:={"NAO","SIM"}
	
	cGet_Banco := Space(3)
	cGet_Desc 	:= Space(50)

	nTL					:= 10 	// Tamanho em pixel da linha
	nTC					:= 8 	// Tamanho em pixel da coluna
	nLin					:= 0
	
	lTrans 			:= .F.
	
	aCampos			:= {"Banco","Nome","Em Greve?","Atualizado"}

	aBrowse			:= U_TabToArray(cAliasGrev, .F. )
	
	aBancExl			:= {} // Array Contendo Codigo de Bancos que foram Excluidos... para posterior atualizacao da Tabela local ...
	 
Return()
*********************************************************************
Static Function MntTelaGreve()// Tela de Cadastro dos Bancos em Greve...
*********************************************************************

	
	oDlg 		:= TDialog():New(0, 0, (350), (500), "Bancos em Greve",,,,,0, 16777215,,,.T.,,,,,,lTrans)

	nLin := nTL * 1 // linha 2

	oSay			:= TSay():Create(oDlg,{||'Situacao do Banco:'}		,nLin,nTC * 02,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)

	nLin := nTL * 2 // linha 3

	oBrowse 	:= TCBrowse():New( nLin	,nTC*02	,225,130,,aCampos,{20,120,30,40},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	
	nLin := nTL * 16 // linha 5

	oBrowse:bLDblClick   := { || AlterArr("A") }
	
	oTBot_GreG	:= TButton():Create( oDlg,nLin,nTC*02		,"Greve Geral"	,{||GreveGeral("Greve Geral") 	}	,46,10,,,,.T.,,,,,,)
	oTBot_GreG	:= TButton():Create( oDlg,nLin,nTC*9.3		,"Incluir"			,{||AlterArr("I")				}	,46,10,,,,.T.,,,,,,)
	oTBot_GreG	:= TButton():Create( oDlg,nLin,nTC*16.6	,"Excluir"			,{||AlterArr("E")				}	,46,10,,,,.T.,,,,,,)
	oTBot_Sair	:= TButton():Create( oDlg,nLin,nTC*24		,"Sair"				,{||Odlg:End() }						,46,10,,,,.T.,,,,,,)

	AtuBrowse()

	oDlg:Activate(,,,.T.,{||('Finalizando...'),.T.},,{||('Iniciando...')} )

Return()
*********************************************************************
Static Function AlterArr(cOperacao)// Botoes de Incluir/ Excluir / Alterar Bancos do Cadastro...
*********************************************************************

	IF cOperacao == "I" //Incluir
		
		cCmb_Greve		:= "NAO"
		cGet_Banco 	:= Space(3)
		cGet_Desc 		:= Space(50)
	
	ElseIf cOperacao == "E" .OR. cOperacao == "A" //Excluir e Alterar
		
		cGet_Banco	:=		aBrowse[oBrowse:nAt][1]
		cGet_Desc 	:= 	aBrowse[oBrowse:nAt][2]
		cCmb_Greve	:= 	aBrowse[oBrowse:nAt][3]
		
	EndIf
	
	TelaAlter(cOperacao)

Return()
*********************************************************************
Static Function TelaAlter(cOperacao)// Tela de Altera‹o de Cadastro do Banco
*********************************************************************

	Local oDlgBan 		:= TDialog():New(0, 0, (180), (230), "Banco",,,,,0, 16777215,,,.T.,,,,,,.F.)
	Local oSay
	Local oGet_Banco
	Local oGet_Desc
	Local oCmb_Greve
	Local lActive := .F.
	
	Private lVal := .F.

	// So deixa ativo campo Codigo Banco na Inclusao...
	If cOperacao == "I"
		lActive := .T.
	EndIf

	oGroupG	:= TGroup():New(05,05,65,115,'',oDlgBan,,,.T.)
	
	oSay		:= TSay():Create(oDlgBan,{||'Banco : '}		,15	,10,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	oSay		:= TSay():Create(oDlgBan,{||'Nome  : '}		,30	,10,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	oSay		:= TSay():Create(oDlgBan,{||'Greve ? '}		,45	,10,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)

	oGet_Banco							:= TGet():Create(oDlgBan)
	oGet_Banco:bSetGet			:= {|a,b,c| if(Pcount()>0,cGet_Banco:=a,cGet_Banco)}
	oGet_Banco:nTop				:= 27		// TOPO
	oGet_Banco:nLeft				:= 70		// ESQUERDA
	oGet_Banco:nWidth			:= 40		// LARGURA
	oGet_Banco:nHeight			:= 20		// ALTURA
	oGet_Banco:Picture			:= "@!"
	oGet_Banco:bValid			:= {||}
	oGet_Banco:cf3					:= "SA6BCO"
	oGet_Banco:bWhen 			:= {|| If(Alltrim(SA6->A6_NOME)<>"CARTEIRA",cGet_Desc:=SA6->A6_NOME,)}
	oGet_Banco:bChange			:= {||}
	oGet_Banco:lReadOnly 		:= .F.
	oGet_Banco:lPassword 		:= .F.
	oGet_Banco:cReadVar 		:= cGet_Banco
	oGet_Banco:lActive 			:= lActive
	oGet_Banco:cTitle			:= ""

										
	oGet_Desc							:= TGet():Create(oDlgBan)
	oGet_Desc:bSetGet			:= {|u|if(Pcount()>0,cGet_Desc:=u,cGet_Desc)}
	oGet_Desc:nTop					:= 57
	oGet_Desc:nLeft				:= 70
	oGet_Desc:nWidth				:= 140
	oGet_Desc:nHeight			:= 20
	oGet_Desc:Picture			:= "@!"
	oGet_Desc:bValid				:= {||}
	oGet_Desc:cf3					:= ""
	oGet_Desc:bWhen 				:= {||}
	oGet_Desc:bChange			:= {||}
	oGet_Desc:lReadOnly 		:= .F.
	oGet_Desc:lPassword 		:= .F.
	oGet_Desc:cReadVar 			:= cGet_Desc
	oGet_Desc:lActive 			:= .T.
	oGet_Desc:cTitle				:= ""
	
	oCmb_Greve 	:= TComboBox():New(43,35,{|u|if(PCount()>0,cCmb_Greve:=u,cCmb_Greve)}, aCmb_Greve,40,20,oDlgBan,,{||},,,,.T.,,,,,,,,,)
	
	If cCmb_Greve == "SIM"
		oCmb_Greve:Select(2)
	Elseif cCmb_Greve == "NAO"
		oCmb_Greve:Select(1)
	EndIf
	
	oTBot_GreG	:= TButton():Create( oDlgBan,70,10	,"Confirma"		,{||If( ValidaBan(cOperacao) ,oDlgBan:End() ,"" )	}	,40,10,,,,.T.,,,,,,)
	oTBot_GreG	:= TButton():Create( oDlgBan,70,70	,"Cancela"			,{||oDlgBan:End() 								}	,40,10,,,,.T.,,,,,,)
	
	oDlgBan:Activate(,,,.T.,{||('Finalizando...'),.T.},,{||('Iniciando...')} )

Return()
*********************************************************************
Static Function ValidaBan(cOperacao)// Valida se o Banco Pode ser Incluido 
*********************************************************************
	Local lValida := .T.
	
	//| S— eh poreciso Validar INCLUSAO | ALTERACAO
	If cOperacao == "I"
		
		//| Verifica se o Banco j‡ n‹o esta Incluido na Tabela Local TGRE... Apenas um C—digo de Cada Banco Ž Aceito....
		For nB := 1 To Len(aBrowse)
			If aBrowse[nB][1] == cGet_Banco
				lValida := .F.
				cMen 		:= "Codigo de Banco informado: "+cGet_Banco+", ja esta cadastrado nesta Tabela de Greve !!!"
				Exit
			EndIf
		Next
		
		//| Verifica se o Banco existe no Cadastro de Bancos...SA6 	
		If !ExistCpo("SA6", cGet_Banco ) .And. lValida
			lValida 	:= .F.
			cMen 		:= "Codigo de Banco informado: "+cGet_Banco+", nao existe no Cadastro de Bancos do Sistema !!!"
		EndIf
	EndIf
	
	If !lValida
		IW_MsgBox(cMen, "Atencao","ALERT")
	Else
		Confirma(cOperacao)
	EndIf
	
Return (lValida)
*********************************************************************
Static Function Confirma(cOperacao)// Confirma a Operacao de Alteracao / Inclusao / Exclusao
*********************************************************************
	Local nTam := Len(aBrowse)

	If ( cOperacao == "I" )

		aAdd( aBrowse , { cGet_Banco , cGet_Desc , cCmb_Greve, dDataBase } )

	ElseIf ( cOperacao == "E" )
	
		aAdd( aBancExl , aBrowse[oBrowse:nAt][1] )
		aDel(	aBrowse , oBrowse:nAt)
		aSize(aBrowse,nTam-1 )
	
	ElseIf ( cOperacao == "A" )

		aBrowse[oBrowse:nAt][1]	:= cGet_Banco
		aBrowse[oBrowse:nAt][2]	:= cGet_Desc
		aBrowse[oBrowse:nAt][3]	:= cCmb_Greve
		aBrowse[oBrowse:nAt][4]	:= dDataBase
	
	EndIf


	// Reinicializa e Autliza as Variaves, objetos e tabelas envolvidas...
	
	cCmb_Greve		:= "NAO"
	cGet_Banco 	:= Space(3)
	cGet_Desc 		:= Space(50)

	DbSelectArea("SA6");DbGotop()
	
	
Return()
*********************************************************************
Static Function GreveGeral()// Marca Todos os bancos Cadastrados como Greve ...
*********************************************************************
	
	Local cCaption 	:= "Atencao"
	Local cSubTit 		:= "Escolha Uma Opcao:"
	Local cMensagem 	:= "GREVE: Estabelece que todos os Bancos sao atingidos por algum tipo de Greve. " + _ENTER + _ENTER + "NORMAL: Estabelece que nenhum Banco e atingido por algum tipo de Greve."
	Local aBotoes		:= {"Greve","Normal","Sair"}
	Local aRet				:= {}
	
	Local GREVE			:= 1
	Local NORMAL			:= 2
	Local SAIR				:= 3
	//Default	cQuem		:= "A" /// .T. = Array   .... .F. = Tabela
	
	//Marcar este(s) Cliente(s) para receber(em) e-mail com instrucao de pagamento dos seus titulos ? "
	aRet := U_Men(cCaption, cSubTit, cMensagem, aBotoes )

	If aRet[BOTAO] == GREVE
		
		For n:=1 To Len(aBrowse)
			aBrowse[n][3]	:= "SIM"
			aBrowse[n][4]	:= dDataBase
		Next
	ElseIf aRet[BOTAO] == NORMAL
		
		For n:=1 To Len(aBrowse)
			aBrowse[n][3]	:= "NAO"
			aBrowse[n][4]	:= dDataBase
		Next

	EndIf
	
Return()
*********************************************************************
Static Function AtuArrToTab()// Atualiza a Tabela Local dos Bancos em Greve apartir do Array...
*********************************************************************

	DbSelectArea("TGRE");DbGotop()

	For n:= 1 To Len(aBrowse)
	
		If !Empty(aBrowse[n][1])

			If TGRE->(DbSeek( aBrowse[n][1],.F.))
	
				If TGRE->GREVE <> aBrowse[n][3]
			
					RecLock("TGRE",.F.)
					TGRE->BANCO	:= aBrowse[n][1]
					TGRE->DESC		:= aBrowse[n][2]
					TGRE->GREVE	:= aBrowse[n][3]
					TGRE->DATAA	:= aBrowse[n][4]
					MsUnlock()

				EndIf
			Else
		
				RecLock("TGRE",.T.)
				TGRE->BANCO	:= aBrowse[n][1]
				TGRE->DESC		:= aBrowse[n][2]
				TGRE->GREVE	:= aBrowse[n][3]
				TGRE->DATAA	:= aBrowse[n][4]
				MsUnlock()
		
			EndIf

		EndIf
	
	Next
	
	DbSelectArea("TGRE");	DbGotop()
	// Verifica se foi excluido algum c—digo de banco do array.. para atualizar a Tabela Local
	If Len(aBancExl) > 0
	
		For nE := 1 To Len(aBancExl)
		 	
			If TGRE->(DbSeek( aBancExl[nE],.F.))
				RecLock("TGRE",.F.)
				DBDelete()
				MsUnlock()
			EndIf
	
		Next
		
	EndIf

Return()

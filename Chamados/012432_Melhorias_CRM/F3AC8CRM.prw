#Include 'protheus.ch'
#Include 'parmtype.ch'

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNÇÃO   : F3AC8CRM    | AUTOR : Cristiano Machado  | DATA : 15/12/2016   **
**---------------------------------------------------------------------------**
** DESCRIÇÃO: Monta a Pesquisa F3 para o Campo AD8->AD8_CONTATO devido a     **
**          : necessidade de regras especificas e multi tabelas .            **
**---------------------------------------------------------------------------**
** USO      : Especifico para o cliente Imdepa Rolamentos                    **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
**            ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.              **
**---------------------------------------------------------------------------**
**   PROGRAMADOR   |   DATA   |            MOTIVO DA ALTERACAO               **
**---------------------------------------------------------------------------**
**                 |          |                                              **
**                 |          |                                              **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User Function F3AC8CRM(nL)
*******************************************************************************
	
	Local nRecno		:= 0
	Local cFiltroAC8	:= AC8->(DbFilter())
	
	Private cEntidade	:= ""
	Private cCodCli		:= ""
	Private cCodEnt		:= ""
	Private aOrdem 		:= {}
	Private aCpo 		:= {}
	Private aHead  		:= {}
	Private aCol	   	:= {}	
	Private lRet		:= .F.
	Private nLin		:= 0

	DefaulT nL 			:= N
	
	nLin				:= nL
	
	SaveInter()	//| Salva estado das variaveis publicas/privadas         

	Prepare()	//| Prepara Variaveis
	
	Consulta()	//| Executa a Consulta para obter os dados

	Tela()		//| Monta a Tela com os dados

	RestInter()	//| Restaura estado das variaveis publicas/privadas

	AC8->(DbClearFilter())

	If !Empty(cFiltroAC8)
		nRecno	:= AC8->(Recno())
		DbSelectArea("AC8")
		Set Filter To &cFiltroAC8
		DbGoto(nRecno)
	EndIf

Return( lRet )
*******************************************************************************
Static Function Prepare()//| Prepara Variaveis
*******************************************************************************
	
	cCodCli	:= 	aCols[nLin][aScan(aHeader,{|x|AllTrim(x[2])=="AD8_CODCLI"})]+aCols[nLin][aScan(aHeader,{|x|AllTrim(x[2])=="AD8_LOJCLI"})]

	cCodEnt	:=	aCols[nLin][aScan(aHeader,{|x|AllTrim(x[2])=="AD8_PROSPE"})]+aCols[nLin][aScan(aHeader,{|x|AllTrim(x[2])=="AD8_LOJPRO"})]

	AAdd( aCpo, "AC8_CODCON" )
	AAdd( aCpo, "U5_CONTAT" )
	AAdd( aCpo, "AC8_ENTIDA" )
	AAdd( aCpo, "AC8_CODENT" )

	SX3->(dbSetOrder(2))

	For nI := 1 To Len( aCpo )

		SX3->(dbSeek(aCpo[nI]))

		SX3->(AAdd(aHead,{	RTrim(X3Titulo()),X3_CAMPO, ;
		"",X3_TAMANHO,;
		X3_DECIMAL, X3_VALID, ;
		X3_USADO, X3_TIPO, ;
		X3_F3, X3_CONTEXT}))
	Next nI

	AAdd( aOrdem, "Contato")
	AAdd( aOrdem, "Cod.Entidade")

	If !Empty(cCodEnt)
		cEntidade	:= "SUS"
	Else
		cEntidade	:= "SA1"
	EndIf

Return()
*******************************************************************************
Static Function Consulta()//| Executa a Consulta para obter os dados
*******************************************************************************
	Local cAliasQry 	:= ""
	Local cQuery 		:= ""
	
	//Selecao de campos do AC8
	cQuery := " SELECT AC8_CODCON, AC8_ENTIDA, AC8_CODENT,U5_CODCONT, U5_CONTAT "
	cQuery += " FROM " + RetSqlName("AC8") +" AC8 "
	cQuery += " INNER JOIN " + RetSqlName("SU5") + " SU5 "
	cQuery += " ON AC8.AC8_CODCON =  SU5.U5_CODCONT "
	cQuery += " AND SU5.U5_FILIAL = '" + xFilial("SU5") + "'"
	cQuery += " AND SU5.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE AC8.AC8_FILIAL = '" + xFilial("AC8") + "'"
	cQuery += " AND AC8.AC8_ENTIDA = '"+cEntidade+"'"

	If  !EMPTY(cCodEnt)
		cQuery += " AND AC8.AC8_CODENT = '" +cCodEnt+"'"
	Else
		cQuery += " AND AC8.AC8_CODENT = '" +cCodCli+"'"
	Endif

	cQuery += " AND AC8.D_E_L_E_T_ = ' ' "

	cAliasQry := GetNextAlias()

	If Select(cAliasQry) > 0
		(cAliasQry)->(DbCloseArea())
	EndIf

	U_ExecMySql(cQuery, cAliasQry, "Q", lShowSql:=.F., .F. )


	(cAliasQry)->(DbGoTop())
	While (cAliasQry)->(!EOF())
		AAdd( aCol, Array( Len( aCpo ) + 1 ) )
		nL := Len( aCol )

		For nI := 1 To Len( aCpo )
			aCol[ nL, nI ] := (cAliasQry)->(FieldGet( FieldPos( aCpo[nI] ) ) )
		Next nI

		aCol[nL,Len(aCpo)+1] := .F.
		(cAliasQry)->(dbSkip())
	End

	(cAliasQry)->(dbCloseArea())

Return()
*******************************************************************************
Static Function Tela()//| Monta a Tela com os dados
*******************************************************************************

	Local nOrd			:= 1
	Local nPosEntidade 	:= 0
	Local nPosCodEnt   	:= 0
	Local cOrd 			:= ""
	Local cSeek 		:= Space(30)	
	
	Local oDlg,oTopPanel,oMainPanel,oBtnPanel1,oBtnPanel2
	Local oOrdem,oSeek,oPesq,oBtn1,oBtn2,oBtn3,oGet

	Local bClique := { |oGet| lRet := (Len(oGet:aCols) > 0) }


	DEFINE MSDIALOG oDlg TITLE "Contatos da Entidade" FROM 0,0 TO 390,515 PIXEL

	// Definicao de paineis
	@ 0,0 MSPANEL oTopPanel SIZE 250,43
	oTopPanel:Align := CONTROL_ALIGN_TOP

	@ 0,0 MSPANEL oMainPanel SIZE 250,39
	oMainPanel:Align := CONTROL_ALIGN_ALLCLIENT

	@ 0,0 MSPANEL oBtnPanel1 SIZE 250,15
	oBtnPanel1:Align := CONTROL_ALIGN_BOTTOM

	@ 0,0 MSPANEL oBtnPanel2 SIZE 250,15 OF oBtnPanel1
	oBtnPanel2:Align := CONTROL_ALIGN_ALLCLIENT

	// Definicao dos objetos
	@  3,  3 COMBOBOX oOrdem VAR cOrd ITEMS aOrdem SIZE 210,36 ON CHANGE (nOrd:=oOrdem:nAt) PIXEL OF oTopPanel
	@ 17,  3 MSGET oSeek VAR cSeek SIZE 210,10 PIXEL OF oTopPanel
	@  3,215 BUTTON oPesq PROMPT "Pesquisar" SIZE 40,11 PIXEL OF oTopPanel ACTION (F3AC8Psq(nOrd,cSeek,oGet))

	DEFINE SBUTTON oBtn1 FROM 2,2 TYPE 1 ENABLE OF oBtnPanel2 ONSTOP "Ok" ACTION ( Eval(bClique,oGet) ,oDlg:End())
	oBtn1:lAutDisable := .f.

	DEFINE SBUTTON oBtn3 FROM 2,32 TYPE 2 ENABLE OF oBtnPanel2 ONSTOP "Cancelar" ACTION (oDlg:End())

	oGet := MsNewGetDados():New(5,5,100,232,0,,,,,,,,,,oMainPanel,aHead,aCol)
	oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGet:oBrowse:blDblClick := {|| Eval(bClique,oGet), oDlg:End()}

	ACTIVATE MSDIALOG oDlg CENTERED

	If lRet
		nPosCodEnt   := AScan( aHead, {|x| ALLTrim( x[ 2 ] ) == "AC8_CODENT" } )
		nPosEntidade := AScan( aHead, {|x| ALLTrim( x[ 2 ] ) == "AC8_ENTIDA" } )
		nPosCto 	 := AScan( aHead, {|x| ALLTrim( x[ 2 ] ) == "AC8_CODCON" } )
		nPosNome 	 := AScan( aHead, {|x| ALLTrim( x[ 2 ] ) == "U5_CONTAT" } )

		DbSelectArea("AC8")
		AC8->(DBSETORDER(1)) // AC8_FILIAL+AC8_CODCON+AC8_ENTIDA+AC8_FILENT+AC8_CODENT
		lRet := AC8->( DBSEEK(XFILIAL("AC8")+ (oGet:aCols[oGet:nAT ,nPosCto])  +  ALLTRIM(oGet:aCols[oGet:nAT ,nPosEntidade])))

		If !lRet
			MsgStop("Nenhum contato foi selecionado")
		EndIf

	EndIf

Return()
*******************************************************************************
Static Function F3AC8Psq(nOrd,cSeek,oGet)//| Pesquisa no F3
*******************************************************************************

	Local nP 		:= 0
	Local nColRef	:= 0

	If nOrd == 1
		nColRef	:= aScan(oGet:aHeader,{|x|AllTrim(x[2])=="AC8_CODCON"})
	Else
		nColRef	:= aScan(oGet:aHeader,{|x|AllTrim(x[2])=="AC8_CODENT"})
	EndIf

	nP := AScan( oGet:aCols, {|x| AllTrim(cSeek) == AllTrim(x[nColRef])} )

	If nP > 0
		oGet:GoTo(nP)
		oGet:Refresh()
	Endif

Return

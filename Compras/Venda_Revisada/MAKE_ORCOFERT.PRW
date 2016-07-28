#Include "Totvs.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Write_OrcOfert  ³ Autor ³ Edivaldo/ Márcio³ Data ³ 06/08/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Registro de quantidade ofertada e venda perdida              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Data Atu. ³ Descricao                                                    ³±±
±±³          ³                                                              ³±±
±±³11/12/06  ³ Adicionado parametro nLinha pois durante a Atualização da    ³±±
±±³          ³ data e hora considerava a linha n e não a linha que estava   ³±±
±±³          ³ sendo alterada                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ESPECIFICO PARA O CLIENTE IMDEPA                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

**********************************************************************
User Function Write_OrcOfert(cParX, nLinha)
**********************************************************************

	
	SetPrvt("ljaExiste,cUB_FILIAL,cUB_NUM,cUB_PRODUTO,cUB_ITEM,nUB_QUANT,cUB_DTNECLI,cUB_HRNECLI,nUB_VRCACRE,cFiltroQry,cUA_CLIENTE,cUA_LOJA,nZA0_QUANTD,nZA0_PRECO,nRECNO_ZA0,lDelet,cChavePub,dDataOld, nHoraOld,lNec_AtuDeH")

	Default cParX 		:= ""
	Default cChavePub 	:= "Acols[n][GdFieldPos('UB_PRODUTO')]+Acols[n][GdFieldPos('UB_ITEM')]+NC(Acols[n][GdFieldPos('UB_QUANT')])"
			cChavePub 	+= "+Acols[n][GdFieldPos('UB_TES')]+ NC(Acols[n][GdFieldPos('UB_VRCACRE')])"

	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³   AJUSTE DESCONTO\ACRESCIMO GERAL 	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  	nBckLine := n
    If Type('nLinha') <> 'U' 
    	If nLinha != Nil
    		If nLinha <> n
    			n := nLinha
    		EndIf
        EndIf
	EndIf
     

	//| Aplica as Alteracoes de Cliente/Loja/Data Nec Cli/Hora... no ZA0... Nestes Casos nao precisa executar o Consultado/Ofertado
	If ( (cParX) $ "C/L/D/H" )

		AplicarAlteracao(cParX)
		Return(.T.)

	ElseIf VerRecursividade() //.And. (Left(GetEnvServer(),07) == 'SOLUTIO' .Or. GetEnvServer() == 'HOMOLOGACAO')

		//| Inicia a Gravacao/Atualizacao do Consultado/Ofertado
		Grava_Atualiza_Consultado()

	EndIF


	If n <> nBckLine
		n := nBckLine
	EndIf


Return(.T.)
**********************************************************************
Static Function  VerRecursividade()
**********************************************************************
Local lRetorno := .T.

If GdFieldGet('UB_VRCACRE', n) == 0
	lRetorno := .F.
Else

	//| Testa ah Recursividade.. para evitar execucoes repetidas e desnecessarias...
	If GdDeleted(n) .Or. Type('_cChaveRec') <> 'U'
		If _cChaveRec ==  &cChavePub.
			lRetorno := .F.
		Else
			_cChaveRec := &cChavePub.
			lRetorno   := .T.
		EndIf
	Else
		If Type('_cChaveRec') == 'U' 
			Public _cChaveRec := &cChavePub.
			/*
			If GdFieldGet('UB_VRCACRE', n) > 0
				Public _cChaveRec := &cChavePub.
				lRetorno := .T.	
			Else
				lRetorno := .F.
			EndIf
			*/
		Endif
	Endif

EndIf

Return(lRetorno)

/*
	//| Testa ah Recursividade.. para evitar execucoes repetidas e desnecessarias...
	If GdDeleted(n) .Or. Type('_cChaveRec') <> 'U'
		If _cChaveRec ==  &cChavePub.
			Return(.F.)
		Else
			_cChaveRec := &cChavePub.
			Return(.T.)
		EndIf
	Else
		If Type('_cChaveRec') == 'U'
			Public _cChaveRec := &cChavePub.
			Return(.T.)
		Endif
	Endif

Return(.T.)
*/
**********************************************************************
Static Function Grava_Atualiza_Consultado()// Inicia a Gravacao/Atualizacao do Consultado/Ofertado
**********************************************************************


	//| inicializa as variaveis...
	Carrega_Privates()

	If  VerReg() 		//| Verifica se já existe o Registro no ZA0...
		ZA0_Atualiza() 	//| Atualiza quando o registro já existe e a quantidade digitada for superior....

	ElseIf lDelet
		ZA0_Novo()  	//| Inclue novo registro....

	EndIf


Return()
**********************************************************************
Static Function AplicarAlteracao(cParX)
**********************************************************************

	//| Em Caso de Troca de Cliente no Orcamento deve Atualizar no Consultado/Ofertado....
	If ( cParX == "C" .OR. cParX == "L" )

		CLI_Atualiza() // No Momento da Alteracao do Cliente deve Atualizar ZA0

	ElseIf ( cParX == "D" .OR. cParX == "H" ) 	//| Em Caso de Troca de Data de Necessidade do Cliente ou Hora deve atualizar no Consultado/Ofertado....

		DNC_Atualiza() // No Momento da Alteracao do Cliente deve Atualizar ZA0

	EndIf

Return()
**********************************************************************
Static Function Carrega_Privates()
**********************************************************************
	Local nPosProd 	:= GdFieldPos('UB_PRODUTO')
	Local nPosQatd 	:= GdFieldPos('UB_QUANT')

	nUB_QUANT  		:= 0 // Quantidade  // | 	//Acols[N][GdFieldPos('UB_QUANT')]

	cUB_FILIAL		:= 	xFilial("SUA")
	cUB_NUM			:= 	M->UA_NUM
	cUB_PRODUTO		:= 	aCols[n][GdFieldPos('UB_PRODUTO')]
	cUB_ITEM		:= 	aCols[n][GdFieldPos('UB_ITEM')]
	cUB_DTNECLI		:= 	aCols[n][GdFieldPos('UB_DTNECLI')]
	cUB_HRNECLI		:= 	aCols[n][GdFieldPos('UB_HRNECLI')]
    nUB_VRCACRE		:= 	aCols[n][GdFieldPos('UB_VRCACRE')]		
		
	lDelet			:= 	!GDDeleted(N)

	cUA_CLIENTE		:= 	M->UA_CLIENTE
	cUA_LOJA		:= 	M->UA_LOJA

	cFiltroQry		:= 	MontaFiltro()

	// Busca no acols as quantidades jah digitadas...para o mesmo item
	For nI := 1 To Len(aCols)
		If ( acols[nI][nPosProd] == cUB_PRODUTO )
			If ( GDDeleted(N) .And. EmpTy(cUB_DTNECLI) )
				nUB_QUANT += acols[nI][nPosQatd]
			ElseIf !GDDeleted(N)
				nUB_QUANT += acols[nI][nPosQatd]
			EndIf
		EndIf
	Next

Return()
**********************************************************************
Static Function VerReg() //Verifica se já existe o Registro...
**********************************************************************
	Local nReg 		:= 	0
	Local ljaExiste :=	.F.

	lNec_AtuDeH		:= 	.F.
	nZA0_QUANTD		:= 	0 // Quantidade ja digitada...
	nZA0_PRECO		:=	0
	nRECNO_ZA0		:=	0

	cSql := "Select Count(1) REG, Sum(za0_quantd) QTD, Max(R_E_C_N_O_) RECNO From ZA0010 "
	cSql += cFiltroQry

	U_ExecMySql(cSql , "TEMP", "Q" , .F.)

	If TEMP->REG > 0
		nZA0_QUANTD	:= 	TEMP->QTD
		nRECNO_ZA0	:= 	TEMP->RECNO
		ljaExiste 	:= 	.T.
	EndIF

	//| Verifica se eh Necessário Altualizar a Data e Hora de Todos os itens do Orcamento... Isso normalmente ocorre quando Orcamento eh Importado...
	If nRECNO_ZA0 > 0

		If ZA0->ZA0_FILIAL <> cUB_FILIAL .OR. ZA0->ZA0_NUMORC <> cUB_NUM
			ZA0->(DbGoto(nRECNO_ZA0))
		EndIf

		If ( ZA0->ZA0_DTNECL <> cUB_DTNECLI .OR. ZA0->ZA0_HRNECL <> cUB_HRNECLI ) .And. ZA0->ZA0_FILIAL == cUB_FILIAL .AND. ZA0->ZA0_NUMORC == cUB_NUM
			lNec_AtuDeH := .T.
		EndIf
			
		nZA0_PRECO	:=	ZA0->ZA0_PRECO
			
	EndIf

Return(ljaExiste)
**********************************************************************
Static Function ZA0_Atualiza()
**********************************************************************
	Local cSql 		:= 	""
    Local lQtdMaior :=	nUB_QUANT 	> nZA0_QUANTD 
    Local lPrcDif	:=	nUB_VRCACRE !=	nZA0_PRECO

	//If ( nUB_QUANT > nZA0_QUANTD )  // Se Quantidade Digitada for Superior ao Consultado deve Atualizar
	If lQtdMaior .Or. lPrcDif
	
		cSql  	+=	"Update ZA0010 "							;
				+	"Set "										;
				+	"ZA0_FILIAL = '"+cUB_FILIAL			+"', "	;
				+	"ZA0_NUMORC = '"+cUB_NUM			+"', "	;
				+	"ZA0_PRODUT = '"+cUB_PRODUTO		+"', "	;
				+	"ZA0_SEQID  = '"+cUB_ITEM			+"', " 	;
				+	IIF(lQtdMaior, "ZA0_QUANTD = "+nc(nUB_QUANT)+" , ", "") 	;
				+	"ZA0_DTNECL = '"+DTOS(cUB_DTNECLI)	+"', "	;
				+	"ZA0_HRNECL = '"+cUB_HRNECLI		+"', "	;
				+	"ZA0_PRECO  =  "+nc(nUB_VRCACRE)	+" , "	;
				+	"ZA0_FLAGOF = ' ' "
	
		cSql 	+= 	cFiltroQry

		U_ExecMySql(cSql, "", "E", .F.)

	EndIf

	If lNec_AtuDeH
		DNC_Atualiza(.F.,"UB_DTNECLI",cUB_DTNECLI	,GdFieldPos('UB_DTNECLI'))
		DNC_Atualiza(.F.,"UB_HRNECLI",cUB_HRNECLI	,GdFieldPos('UB_HRNECLI'))
		lNec_AtuDeH := .F.
	EndIf

Return()
**********************************************************************
Static Function ZA0_Novo()
**********************************************************************
	Local cSql := ""

	cSql	:= 	"UPDATE ZA0010 SET "							;
			+	"ZA0_FILIAL	=	'"+cUB_FILIAL			+"'	,"	;
			+	"ZA0_NUMORC	= 	'"+cUB_NUM				+"'	,"	;
			+	"ZA0_PRODUT	= 	'"+cUB_PRODUTO			+"'	,"	;
			+	"ZA0_QUANTD	= 	 "+nc(nUB_QUANT)		+"	,"	;
			+	"ZA0_DTNECL	= 	'"+Dtos(cUB_DTNECLI)	+"'	,"	;
			+	"ZA0_HRNECL	= 	'"+cUB_HRNECLI			+"'	,"	;
			+ 	"ZA0_SEQID	= 	'"+cUB_ITEM				+"'	,"	;
			+	"ZA0_PRECO	=	 "+nc(nUB_VRCACRE)		+"	,"	;
			+ 	"ZA0_CLIENT	= 	'"+cUA_CLIENTE			+"'	,"	;
			+ 	"ZA0_LOJACL	= 	'"+cUA_LOJA				+"'	 "	;
			+	"WHERE R_E_C_N_O_ = "+nc(VerRec())		+" "


	U_ExecMySql(cSql, "", "E", .F.)

Return()
*********************************************************************
Static Function MontaFiltro()
**********************************************************************
Local 	cFiltro := 	" "
		cFiltro += 	"Where ZA0_FILIAL = '"+cUB_FILIAL+"' "	;
				+	"AND   ZA0_NUMORC = '"+cUB_NUM+"' "		;
				+	"AND   ZA0_PRODUT = '"+cUB_PRODUTO+"' "	;
				+	"AND   D_E_L_E_T_ = ' '"

Return (cFiltro)
**********************************************************************
Static Function nc(nVal)
**********************************************************************

Return (cValtoChar(nVal))
**********************************************************************
Static Function VerRec()
**********************************************************************

	Local nRecno := 0

	DbSelectArea("ZA0")
	Reclock("ZA0",.T.)
	Msunlock()

	nRecno := RECNO()

Return(nRecno)
**********************************************************************
Static Function CLI_Atualiza()
**********************************************************************
/*	Local cSql 			:= ""
	Local cUA_CLIENTE	:= M->UA_CLIENTE
	Local cUA_LOJA		:= M->UA_LOJA
	Local cUA_NUM			:= M->UA_NUM
	Local cUA_FILIAL		:= xFilial("SUA")


	cSql  	+=	"Update ZA0010 "							;
		+	"Set "											;
		+	"ZA0_CLIENT = '"+cUA_CLIENTE		+"', "	;
		+	"ZA0_LOJACL = '"+cUA_LOJA			+"', "	;
		+	"ZA0_FLAGOF = ' ' "							;
		+ 	"Where ZA0_FILIAL = '"+cUA_FILIAL	+"' "	;
		+	"AND   ZA0_NUMORC = '"+cUA_NUM		+"' "

	U_ExecMySql(cSql, "", "E", .F.)
*/
Return()
**********************************************************************
Static Function DNC_Atualiza(xCall,cCampo,xVal,nPosCamp)
**********************************************************************

	Default xCall		:= .T. // TRUE -> Funcao Chamada apartir de uma Validacao de Campo... OFF ->Funcao Chamada apartir de um Programa....

	//| Controle de Recursividade ... Evita Execucoes Repetidas ou Loop
	If Type('lIn_Loop_DNC') == 'U'
		Private lIn_Loop_DNC 	:= .F.
		Private nIni 		:=  n
	Else
		Private lIn_Loop_DNC 	:= .T.
	EndIf
	If lIn_Loop_DNC
		Return()
		lIn_Loop_DNC := .F.
	EndIf
	//| Fim Controle Recursividade

	If xCall
		Private 	cUB_NomeCamp 	:= Substr(Readvar(),4)
		Private 	cUB_VlrCamp	:= 	&cUB_NomeCamp.
		Private 	cUB_nPosCamp	:= GdFieldPos(cUB_NomeCamp)
	Else
		Private 	cUB_NomeCamp 	:= cCampo
		Private 	cUB_VlrCamp		:= 	xVal
		Private 	cUB_nPosCamp	:= nPosCamp
	EndIf


	DNC_Update()// Atualiza ZA0 via Update

	If xCall
		AtualizaAcols() // Replica no Acols de Todos os Itens ... o Valor informado Apenas via Get
	EndIf

Return()
**********************************************************************
Static Function DNC_Update()
**********************************************************************
	Local  cSql 			:= ""
	Local cUA_NUM			:= M->UA_NUM
	Local cUA_FILIAL		:= cFilAnt


	cSql	:= ""
	cSql  	+=	"Update ZA0010 "
	cSql  	+=	"Set "

	If cUB_NomeCamp == "UB_DTNECLI"
		cSql  	+=	"ZA0_DTNECL = '"+Dtos(cUB_VlrCamp)	+"', "
	ElseIf cUB_NomeCamp == "UB_HRNECLI"
		cSql  	+=	"ZA0_HRNECL = '"+cUB_VlrCamp		+"', "
	EndIf

	cSql  	+=	"ZA0_FLAGOF = ' ' "
	cSql  	+=	"Where ZA0_FILIAL = '"+cUA_FILIAL	+"' "
	cSql  	+=	"AND   ZA0_NUMORC = '"+cUA_NUM		+"' "

	U_ExecMySql(cSql, "", "E", .F.)

Return()
**********************************************************************
Static Function AtualizaAcols()
**********************************************************************

	For n := 1 to Len(aCols)

		If n <> nIni

			M->&cUB_NomeCamp   		:= 	cUB_VlrCamp
			aCols[n][cUB_nPosCamp]	:=	cUB_VlrCamp

			GdFieldPut(cUB_VlrCamp,M->&cUB_NomeCamp,n)

			// IIF(Empty(Alias()), 'PREFIXO'->(ChkFile(Left(cUB_NomeCamp,02))),)					// 	FABIANO PEREIRA - SOLUTIO
			lOk := CheckSX3(cUB_NomeCamp,M->&cUB_NomeCamp)
			If lOk
				RunTrigger(2,n,PADR(cUB_NomeCamp,10))
			EndIf

		EndIf

	Next n

	n	:= nIni

Return()
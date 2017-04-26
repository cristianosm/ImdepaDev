#Include "PROTHEUS.CH"
#Include 'FWMVCDEF.CH'

Static aIndSCT
Static lCopia

/*/
±±³Descri‡„o ³ Manutencao do Cadastro de Metas de Venda.                  ³±±
/*/
*******************************************************************************
User Function IFATA050()
*******************************************************************************

	Local oBrowse	:= Nil
//	Private cCadastro := "Meta de Venda"

	//AjustaHlp() //"Ajusta Help"

	//³ Cria o Browse ³
	/*
	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription("Meta de Venda")  //"Meta de Venda"
	oBrowse:SetAlias('SCT')
	oBrowse:Activate()
	*/

	Private cCadastro := "Meta de Venda"

	Private aRotina     := { }

 	AADD(aRotina, { "Pesquisar"  , "AxPesqui" , 0, 1 })
	AADD(aRotina, { "Visualizar" , "AxVisual" , 0, 2 })
	AADD(aRotina, { "Incluir"    , "AxInclui" , 0, 3 })
	AADD(aRotina, { "Alterar"    , "AxAltera" , 0, 4 })
	AADD(aRotina, { "Excluir"    , "AxDeleta" , 0, 5 })

 
	DbSelectArea("SCT");DbSetOrder(1)

	mBrowse(6, 1, 22, 75, "SCT")
	
Return(.T.)

/*
±±ºDesc.     ³Define o modelo de dados para Manutencao do Cadastro de   º±±
±±º          ³Metas de Venda (MVC).                                     º±±
*/
*******************************************************************************
Static Function ModelDef()
*******************************************************************************
	Local oModel
	Local oStruCab 		:= FWFormStruct(1,'SCT')//,{|cCampo| AllTrim(cCampo)+"|" $ "CT_DOC|CT_DESCRI|"})
	Local oStruGrid 	:= FWFormStruct(1,'SCT')

	Local bActivate     := {|| }//{|oMdl|FatA050Act(oMdl)}
	Local bPosValidacao := {|| }//{||FatA050Pos()}
	Local bCommit		:= {|| }//{|oMdl|FatA050Cmt(oMdl)}
	Local bCancel   	:= {|| }//{|oMdl|FatA050Can(oMdl)}
	Local bLinePost 	:= {|| }//{||Ft050LinOk()}

	oStruGrid:RemoveField('CT_DOC')
	oStruGrid:RemoveField('CT_DESCRI')

	oModel := MPFormModel():New('IFATA050',/*bPreValidacao*/,bPosValidacao,bCommit,bCancel)
	oModel:AddFields('SCTCAB',/*cOwner*/,oStruCab,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
	oModel:AddGrid( 'SCTGRID','SCTCAB',oStruGrid,/*bLinePre*/,bLinePost,/*bPreVal*/,/*bPosVal*/)
	oModel:SetRelation("SCTGRID",{{"CT_FILIAL",'xFilial("SCT")'},{"CT_DOC","CT_DOC"}},SCT->(IndexKey(1)))
	oModel:SetPrimaryKey({'CT_FILIAL','CT_DOC','CT_SEQUEN'})
	oModel:SetActivate(bActivate)
	oModel:SetDescription("Meta de Venda")

Return(oModel)

/*
±±ºDesc.     ³Define a interface para Manutencao do Cadastro de     º±±
±±º          ³Metas de Venda (MVC).                                 º±±
*/
*******************************************************************************
Static Function ViewDef()
*******************************************************************************
	Local oView

	Local oModel     := FWLoadModel('IFATA050')
	Local oStruCab   := FWFormStruct(2,'SCT',{|cCampo| AllTrim(cCampo)+"|" $ "CT_FILIAL|CT_DOC|CT_DESCRI|"})
	Local oStruGrid   := FWFormStruct(2,'SCT')
	Local aCabExcel  := Ft050Cab()  			// Cria o cabecalho para utilizacao no Microsoft Excel
	Local aUsrBut    := {}     					// recebe o ponto de entrada
	Local aButtons	 := {}                      // botoes da enchoicebar
	Local nAuxFor    := 0                       // auxiliar do For , contador da Array aUsrBut
	Local lFat050But := ExistBlock("FAT050BUT") // P.E. para incluir botoes do usuario na enchoicebar
	Local oMdlCab    := oModel:GetModel('SCTCAB')
	Local oMdlGrid    := oModel:GetModel('SCTGRID')

	oStruGrid:RemoveField('CT_DOC')
	oStruGrid:RemoveField('CT_DESCRI')

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField('VIEW_CAB',oStruCab,'SCTCAB')
	oView:AddGrid('VIEW_GRID',oStruGrid,'SCTGRID' )
	oView:AddIncrementField('VIEW_GRID','CT_SEQUEN')

	oView:CreateHorizontalBox('SUPERIOR',8)
	oView:CreateHorizontalBox('INFERIOR',92)

	oView:SetOwnerView( 'VIEW_CAB','SUPERIOR' )
	oView:SetOwnerView( 'VIEW_GRID','INFERIOR' )

	If GetRemoteType() == 1
		oView:AddUserButton(PmsBExcel()[3],PmsBExcel()[1],{|| DlgToExcel({ {"CABECALHO",oMdlCab:GetDescription(),{aCabExcel[1][1],aCabExcel[2][1]},{oMdlCab:GetValue('CT_DOC'),oMdlCab:GetValue('CT_DESCRI')}},{"GETDADOS","",oMdlGrid:aHeader,oMdlGrid:aCols}})},PmsBExcel()[2])
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para incluir botoes do usuario na barra, ³
	//³ de ferramentas do formulario na copia das metas de venda. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If lFat050But .AND. lCopia == .T.
		aUsrBut := ExecBlock("FAT050BUT",.F.,.F.)
		If (ValType(aUsrBut) == "A")
			For nAuxFor := 1 To Len(aUsrBut)
				oView:AddUserButton(aUsrBut[nAuxFor][3],aUsrBut[nAuxFor][1],aUsrBut[nAuxFor][2],aUsrBut[nAuxFor][4])
			Next nAuxFor
		EndIf
		lCopia := .F.
	EndIf

Return(oView)
/*
±±³Retorno   ³aRotina retorna a array com lista de aRotina                ³±±
/*/
*******************************************************************************
Static Function MenuDef()
*******************************************************************************

	Local aRotina :={}
	Local aUsrBut :={}
	Local nX := 0

	//If IsInCallStack("FATA320") .AND. FindFunction("FT060Permi")
		//aPermissoes := FT060Permi(__cUserId, "ACA_ACMETA")
	//Else
		aPermissoes := {.T.,.T.,.T.,.T.}
	//EndIf

	ADD OPTION aRotina TITLE "Pesquisar" ACTION 'PesqBrw' 			OPERATION 1	ACCESS 0

	If aPermissoes[4]
		ADD OPTION aRotina TITLE "STR0003" ACTION 'VIEWDEF.IFATA050'	OPERATION 2	ACCESS 0
	EndIf

	If aPermissoes[1]
		ADD OPTION aRotina TITLE "STR0004" ACTION 'VIEWDEF.IFATA050'	OPERATION 3	ACCESS 0
	EndIf

	If aPermissoes[2]
		ADD OPTION aRotina TITLE "STR0005" ACTION 'VIEWDEF.IFATA050'	OPERATION 4	ACCESS 0
	EndIf

	If aPermissoes[3]
		ADD OPTION aRotina TITLE "STR0006" ACTION 'VIEWDEF.IFATA050'	OPERATION 5	ACCESS 0
	EndIf

	ADD OPTION aRotina TITLE "Consulta" ACTION 'U_Ft050Cons'			OPERATION 6	ACCESS 0 //"Consulta"
	ADD OPTION aRotina TITLE "Cópia" ACTION 'U_Ft050Copia'				OPERATION 7	ACCESS 0 //"Copia"

	/*If ExistBlock("FT050MNU")
		aUsrBut := ExecBlock("FT050MNU",.F.,.F.)
		For nX := 1 To Len(aUsrBut)
			ADD OPTION aRotina TITLE aUsrBut[nX][1] ACTION aUsrBut[nX][2] OPERATION aUsrBut[nX][4] ACCESS 0
		Next nX
	EndIf*/

Return(aRotina)

/*
±±ºDesc.     ³Bloco executado ao iniciar o formulario MVC para inclusao,  º±±
±±º          ³alteracao, exclusao e visualizacao.                         º±±
*/
*******************************************************************************
Static Function FatA050Act(oMdl)
*******************************************************************************

	Local nOperation := oMdl:GetOperation()
	Local oMdlGrid := oMdl:GetModel('SCTGRID')
	Local nX := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a operacao for copia ajusta a sequencia, ³
	//³da linha.         						   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	if nOperation == 3 .AND. lCopia
		For nX:= 1 to oMdlGrid:GetQtdLine()
			oMdlGrid:GoLine(nX)
			oMdlGrid:SetValue("CT_SEQUEN",cValToChar(StrZero(nX,TamSx3("CT_SEQUEN")[1])),.T.)
		Next nX
		lCopia := .F.
	EndIf

Return(.T.)

/*
±±ºDesc.     ³Pos validacao do browse MVC, executada antes da gravacao,   º±±
±±º          ³permitindo validar o formulario.                            º±±
*/
*******************************************************************************
Static Function FatA050Pos()
*******************************************************************************
	Local lRet := .T.

	/*If ExistBlock("FT050TOK")
		lRet := ExecBlock("FT050TOK",.F.,.F.)
	EndIf*/

Return(lRet)

/*
±±ºDesc.     ³Bloco executado na gravacao dos dados do formulario MVC.  º±±
*/
*******************************************************************************
Static Function FatA050Cmt(oMdl)
*******************************************************************************
	Local nOperation := oMdl:GetOperation()
	//integracao com modulo de planejamento e controle orcamentario
	Local lInt_Pco := (SuperGetMV("MV_PCOINTE",.F.,"2")=="1")

	//³ Inicializa a gravacao dos lancamentos do SIGAPCO          ³
	PcoIniLan("000155")

	If nOperation == 3  .Or. nOperation == 5

		FWModelActive(oMdl)
		FWFormCommit(oMdl)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava os lancamentos para integracao com modulo SIGAPCO³
 
		If lInt_Pco
			PcoDetLan("000155","01","FATA050")
		EndIf

	Endif

	If nOperation == 4

		FWModelActive(oMdl)
		FWFormCommit(oMdl)
		Ft050GrvDesc(oMdl)

		//³Grava os lancamentos para integracao com modulo SIGAPCO³
		If lInt_Pco
			PcoDetLan("000155","01","FATA050")
		EndIf

	EndIf

	// Finaliza a gravacao dos lancamentos do SIGAPCO            
	PcoFinLan("000155")

Return(.T.)
/*
±±ºDesc.     ³Bloco acionado no cancelamento de inclusao/alteracao do     º±±
±±º          ³formulario MVC.                                             º±±
*/
*******************************************************************************
Static Function FatA050Can(oMdl)
*******************************************************************************

	Local nOperation:= oMdl:GetOperation()

	If nOperation == 3
		RollBackSX8()
	EndIf

Return(.T.)

/*
±±ºDesc.     ³Copia do Cadastro de Metas de Venda.                         º±±
*/
*******************************************************************************
User Function Ft050Copia()
*******************************************************************************
	Local cTitulo		:= "Cópia"
	Local nOperation 	:= 9 // Define o modo de operacao como copia
	lCopia := .T.

	FWExecView(cTitulo,'VIEWDEF.FATA050',nOperation,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/)

Return Nil

/*
±±ºDesc.     ³Grava a descricao do cabecalho no grid.                     º±±
*/
*******************************************************************************
Static Function Ft050GrvDesc(oMdl)
*******************************************************************************
	Local oMdlCab := oMdl:GetModel('SCTCAB')
	Local oMdlGrid := oMdl:GetModel('SCTGRID')
	Local nX := 0

	DbSelectArea("SCT");DbSetOrder(1)
	
	For nX:= 1 to oMdlGrid:GetQtdLine()
		oMdlGrid:GoLine(nX)
		If DbSeek(xFilial("SCT")+oMdlCab:GetValue("CT_DOC")+oMdlGrid:GetValue("CT_SEQUEN"))
			RecLock("SCT",.F.)
			SCT->CT_DESCRI := oMdlCab:GetValue("CT_DESCRI")
			MsUnlock()
		Endif
	Next nX

Return Nil

/*
±±ºDesc.     ³Criacao do cabecalho para integracao com Microsoft Excel.   º±±
*/
*******************************************************************************
Static Function Ft050Cab()
*******************************************************************************
	Local aCabec := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montagem do Array do Cabecalho                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(2)
	dbSeek("CT_DOC")
	aadd(aCabec,{OemToAnsi(X3Titulo()),SX3->X3_PICTURE,Nil})
	dbSelectArea("SX3")
	dbSetOrder(2)
	dbSeek("CT_DESCRI")
	aadd(aCabec,{OemToAnsi(X3Titulo()),SX3->X3_PICTURE,Nil})

Return(aCabec)

/*
±±ºDesc.     ³Validacao da Linha.                                         º±±
*/
*******************************************************************************
Static Function Ft050LinOk()
*******************************************************************************
	Local oMdl		:= FWModelActive()
	Local oMdlGrid	:= oMdl:GetModel('SCTGRID')
	Local nPMoeda	:= oMdlGrid:GetValue('CT_MOEDA') // moeda
	Local nPValor	:= oMdlGrid:GetValue('CT_VALOR') // valor
	Local nPQuant	:= oMdlGrid:GetValue('CT_QUANT') // quantidade
	Local lRet	:= .T.

/*	If !oMdlGrid:IsDeleted()
		Do Case
			Case nPMoeda == 0
			UserException('CT_MOEDA Must be Used !!!')
			Case nPValor == 0
			UserException('CT_VALOR Must be Used !!!')
			Case nPQuant == 0
			UserException('CT_QUANT Must be Used !!!')
		EndCase

		If Empty(nPMoeda) .Or. Empty(nPValor) .Or. Empty(nPQuant)
			Help(" ",1,"FT050LOK01")
			lRet := .F.
		EndIf
	EndIf */

	/*If ExistBlock("FT050LOK")
		lRet := ExecBlock("FT050LOK",.F.,.F.)
	EndIf*/

Return(lRet)

/*/
±±³Descri‡…o ³ Consulta as Metas de Venda por data.                       ³±±
/*/
*******************************************************************************
User Function Ft050Cons(cAlias,nReg,nOpc)
*******************************************************************************
	Local cCadastro := "Meta de Venda"              // Meta de Venda
	Local aArea     := GetArea()        	// Salva ambiente anterior
	Local aSizeAut  := MsAdvSize( .F. )    // Array para redimensionamento da tela
	Local aObjects  := {}					// Array para redimensionamento da tela
	Local aPosObj   := {}					// Array para redimensionamento da tela
	Local aCampos   := {}                   // campos da a tela
	Local aStru     := {}                   // Estrutura da Query
	Local aStruExcel:= {}
	Local aSoma     := {}                   // soma dos valores
	Local aDesc     := {}   				// descrição dos elementos no Tree

	Local cDesc     := ""                  // descricao
	Local cChave    := ""                  // chave da tabela
	Local cCampo    := ""                  // campo da tabela
	Local cConteudo := ""                  // conteudo do campo
	Local cSeek     := ""                  // chave da pesquisa
	Local cLast     := ""
	Local cTitulo   := ""                  // titulo
	Local cChar     := ""
	Local cQuery    := ""                  // Query
	Local cAliasSCT := "SCT"               // Alias
	Local cQuebra1  := ""
	Local cQuebra2  := ""

	Local dData     := SCT->CT_DATA        // data

	Local lData     := .F.

	Local nOrdem    := 0                   // ordem
	Local nX        := 0                   // auxiliar
	Local nY        := 0                   // auxiliar
	Local nPSoma    := 0

	Local oDlg                            // tela
	Local oTree                           // estrutura da  tela
	Local oSay1                           // objeto say1
	Local oSay2                           // objeto say2

	nOrdem    := SCT->(U_FtOrdMeta())
	cChave    := SCT->(IndexKey(1))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define as descricoes para cada tipo de elemento no Tree                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aDesc, { "CT_REGIAO" , { |x| Posicione( "SX5", 1, xFilial( "SX5" ) + "A2" + x, "X5_DESCRI" ) } } )
	AAdd( aDesc, { "CT_TIPO"   , { |x| Posicione( "SX5", 1, xFilial( "SX5" ) + "02" + x, "X5_DESCRI" ) } } )
	AAdd( aDesc, { "CT_GRUPO"  , { |x| Posicione( "SBM", 1, xFilial( "SBM" ) + x, "BM_DESC" ) } } )
	AAdd( aDesc, { "CT_PRODUTO", { |x| Posicione( "SB1", 1, xFilial( "SB1" ) + x, "B1_DESC" ) } } )
	AAdd( aDesc, { "CT_VEND"   , { |x| Posicione( "SA3", 1, xFilial( "SA3" ) + x, "A3_NOME" ) } } )

	dbSelectArea("SCT")
	For nX := 1 To Len(cChave)+1
		cChar  := SubStr(cChave,1,1)
		cChave := SubStr(cChave,2)
		If cChar <> "+" .And. !Empty(cChar)
			cCampo += cChar
		Else
			If ( !Empty(cCampo) )
				aadd(aCampos,cCampo)
			EndIf
			cCampo := ""
		EndIf
	Next nX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calculo automatico de dimensoes dos objetos                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aObjects, { 100, 100, .t., .t. } )
	AAdd( aObjects, { 080, 100, .f., .t. } )

	aInfo := { aSizeAut[1], aSizeAut[2], aSizeAut[3], aSizeAut[4], 3, 3 }
	aObj  := MsObjSize( aInfo, aObjects, , .T. )

	DEFINE MSDIALOG oDlg FROM aSizeAut[7],00 TO aSizeAut[6],aSizeAut[5] TITLE cCadastro OF oMainWnd PIXEL

	oTree := DbTree():New( aObj[1,1], aObj[1,2], aObj[1,3], aObj[1,4],oDlg,,,.T.)

	dbSelectArea(cAliasSCT)

	aStru  := SCT->(dbStruct())
	// cAliasSCT := "Ft050Cons"
	cAliasSCT := CriaTrab( ,.F. )
	cQuery := "SELECT * "
	cQuery += "FROM "+RetSqlName("SCT")+" SCT "
	cQuery += "WHERE "
	cQuery += "SCT.CT_FILIAL='"+xFilial("SCT")+"' AND "
	cQuery += "SCT.CT_DATA='"+Dtos(dData)+"' AND "
	cQuery += "SCT.D_E_L_E_T_=' ' "
	cQuery += "ORDER BY "+SqlOrder(SCT->(IndexKey(1)))

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSCT,.T.,.T.)
	For nX := 1 To Len(aStru)
		If ( aStru[nX][2] <> "C" )
			TcSetField(cAliasSCT,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
		EndIf
	Next nX

	cQuebra1 := ""
	For nX := 1 To Len(aCampos)
		cQuebra1 += "+"+aCampos[nX]
	Next nX
	cQuebra1 := SubStr(cQuebra1,2)
	While ( !Eof() .And. (cAliasSCT)->CT_FILIAL == xFilial("SCT") .And.;
	(cAliasSCT)->CT_DATA == dData )
		cQuebra2 := &cQuebra1
		nY    := 0
		cLast := ""
		For nX := 1 To Len(aCampos)
			cCampo    := aCampos[nX]
			cConteudo := &(cCampo)
			cDesc     := ""
			nY        += Len(cConteudo)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Obtem as descricoes para cada tipo de elemento no Tree                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty( nScan := AScan( aDesc, { |x| x[1] == AllTrim( cCampo ) } ) )
				cDesc := " - " + AllTrim( Capital( Eval( aDesc[ nScan, 2 ], cConteudo ) ) )
			EndIf

			If ( nX > 1 )
				cLast     += &(aCampos[nX-1])
			EndIf
			lData := .F.
			Do Case
				Case "DTOS"$Upper(cCampo)
				cCampo := SubStr(cCampo,6,Len(cCampo)-6)
				lData  := .T.
			EndCase
			cTitulo := PadR(AllTrim(RetTitle(cCampo))+": "+If(lData, DToC( SToD( cConteudo ) ) , AllTrim( cConteudo ) ) + cDesc, 120 )
			cSeek   := PadR(SubStr(cQuebra2,1,nY),Len(cQuebra2))
			If !oTree:TreeSeek(cSeek)
				oTree:TreeSeek(cLast)
				oTree:addItem(cTitulo,cSeek,"FOLDER5","FOLDER6",,,If(nX==1,1,2))
				cLast := cSeek
				If ( !Empty(cConteudo) )
					aadd(aSoma,{cSeek,(cAliasSCT)->CT_QUANT,(cAliasSCT)->CT_VALOR})
				EndIf
			Else
				If ( !Empty(cConteudo) )
					nPSoma := aScan(aSoma,{|x| x[1]==cSeek })
					aSoma[nPSoma][2] += (cAliasSCT)->CT_QUANT
					aSoma[nPSoma][3] += (cAliasSCT)->CT_VALOR
				EndIf
			EndIf
		Next nX
		dbSelectArea(cAliasSCT)
		dbSkip()
	EndDo
	#IFDEF TOP
	dbSelectArea(cAliasSCT)
	dbCloseArea()
	dbSelectArea("SCT")
	#ENDIF

	@ aObj[2,1], aObj[2,2] TO aObj[2,3], aObj[2,4] PROMPT OemToAnsi("Hierarquia") PIXEL //"Hierarquia"

	nLin := aObj[2,1] +  8
	nCol := aObj[2,2] +  7

	@ nLin,nCol          SAY RetTitle("CT_QUANT") SIZE 040,008 OF oDlg PIXEL
	@ nLin + 10,nCol + 6 SAY oSay1 PROMPT 0 SIZE 050,008 OF oDlg PIXEL
	@ nLin + 30,nCol SAY RetTitle("CT_VALOR") SIZE 040,008 OF oDlg PIXEL
	@ nLin + 40,nCol + 6 SAY oSay2 PROMPT 0 SIZE 050,008 OF oDlg PIXEL

	oTree:bChange := {|| Ft050Msg(oTree,oSay1,oSay2,aSoma) }

	@ aObj[2,3] - 17,aObj[2,4] - 33 BUTTON "Sair" ACTION ( oDlg:End() ) OF oDlg PIXEL SIZE 30,10 //"Sair"
	@ aObj[2,3] - 17,aObj[2,4] - 75 BUTTON "Excel" ACTION ( FtToExcel(aCampos,aSoma) ) OF oDlg PIXEL SIZE 30,10 //"Excel"

	ACTIVATE MSDIALOG oDlg ON INIT Eval(oTree:bChange)

	RestArea(aArea)

Return(.T.)
/*
±±³Descri‡…o ³Demonstra as mensagens do rodape da funcao de consulta      ³±±
*/
*******************************************************************************
Static Function Ft050Msg(oTree,oSay1,oSay2,aSoma)
*******************************************************************************

	Local nPSoma := 0
	Local cSeek  := oTree:GetCargo()

	nPSoma := aScan(aSoma,{|x| x[1]==cSeek })

	oSay1:SetText(AllTRim( TransForm(aSoma[nPSoma,2],PesqPict("SCT","CT_QUANT",18))))
	oSay2:SetText(AllTRim( TransForm(aSoma[nPSoma,3],PesqPict("SCT","CT_VALOR",18))))

Return(.T.)
/*
±±³Descri‡…o ³Estabelece o indice de hierarquia das metas de venda        ³±±
*/
*******************************************************************************
User Function FtOrdMeta(cChave)
*******************************************************************************

	Local aArea    := GetArea()                			// retorna o ambiente anterios
	Local nOrdem   := 0                                 // ordem
	Local nPos     := 0                                 // posição
	Local cArqInd  := ""                                // index

	DEFAULT cChave  := AllTrim(&(GetMv("MV_FTMETA")))  // chave da tabela
	DEFAULT aIndSCT := {}

	nPos := At("CT_FILIAL",cChave)
	If ( nPos == 0 )
		cChave := "C7_DATA+"+cChave
	Else
		cChave := AllTrim(SubStr(cChave,nPos,9))+"+Dtos(CT_DATA)"+SubStr(cChave,nPos+9)
	EndIf
	dbSelectArea("SCT")
	nOrdem := RetIndex("SCT") + 1
	nPos := aScan(aIndSCT,{|x| AllTrim(x[2])==cChave})
	If ( nPos <> 0 )
		#IFNDEF TOP
		dbSetIndex(aIndSCT[nPos][1])
		dbSetOrder(nOrdem)
		#ELSE
		nPos := 0
		#ENDIF
	EndIf
	If ( nPos == 0 )
		cArqInd := CriaTrab(,.F.)
		IndRegua("SCT",cArqInd,cChave)
		nOrdem := RetIndex("SCT") + 1
		#IFNDEF TOP
		dbSetIndex(cArqInd+OrdBagExt())
		aadd(aIndSCT,{ cArqInd , cChave })
		#ENDIF
		dbSetOrder(nOrdem)
	EndIf
	If ( aArea[1]<>"SCT" )
		RestArea(aArea)
	EndIf
Return(nOrdem)

/*/
±±³Descri‡…o ³Exporta para o Excell                                       ³±±
/*/
*******************************************************************************
Static Function FtToExcel(aCampos,aDados)
*******************************************************************************

	Local aArea		:= GetArea()                 	// retorna ambiente anterior
	Local aStruct   := {}                           // estrutura
	Local cDirDocs  := MsDocPath()
	Local cPath		:= AllTrim(GetTempPath())
	Local nY		:= 0                            // auxiliar do for
	Local nX        := 0                            // auxiliar do for
	Local cBuffer   := ""                           // recebe as variaveis de valores
	Local oExcelApp := Nil                          // recebe planilha do excell
	Local nHandle   := 0
	Local cArquivo  := CriaTrab(,.F.)+".CSV"        // arquivo
	Local xValor    := Nil                          //  valor

	If ApOleClient("MsExcel")
		For nX := 1 To Len(aCampos)
			aCampos[nX] := Upper(aCampos[nX])
			aCampos[nX] := StrTran(aCampos[nX],"DTOS(","")
			aCampos[nX] := StrTran(aCampos[nX],")","")
			dbSelectArea("SX3")
			dbSetOrder(2)
			If MsSeek(aCampos[nX])
				aadd(aStruct,{aCampos[nX],SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			EndIf
		Next nX
		SX3->(dbSetOrder(1))
		If (nHandle := FCreate(cDirDocs + "\"+cArquivo)) > 0
			For nY := 1 To Len(aStruct)
				xValor := RetTitle(aStruct[nY][1])
				xValor := PadR(xValor,Max(aStruct[nY][3]+aStruct[nY][4],Len(xValor)))
				cBuffer += ToXlsFormat(xValor)
				cBuffer += ";"
			Next nY
			cBuffer += ToXlsFormat(RetTitle("CT_QUANT"))+";"
			cBuffer += ToXlsFormat(RetTitle("CT_VALOR"))+CRLF
			FWrite(nHandle, cBuffer)
			For nX := 1 To Len(aDados)
				cBuffer	:= ""
				cLinha := aDados[nX][1]
				For nY := 1 To Len(aStruct)
					xValor := SubStr(cLinha,1,aStruct[nY][3]+aStruct[nY][4])
					Do Case
						Case aStruct[nY][2]=="N"
						xValor := Val(xValor)
						Case aStruct[nY][2]=="D"
						xValor := Stod(xValor)
					EndCase
					cBuffer += ToXlsFormat(xValor)
					cBuffer += ";"
					cLinha := SubStr(cLinha,aStruct[nY][3]+aStruct[nY][4]+1)
				Next nY
				cBuffer += ToXlsFormat(aDados[nX][2])+";"
				cBuffer += ToXlsFormat(aDados[nX][3])+CRLF
				FWrite(nHandle, cBuffer)
			Next nX
			FClose(nHandle)
			CpyS2T(cDirDocs + "\" + cArquivo, cPath, .T.)

			oExcelApp := MsExcel():New()
			oExcelApp:WorkBooks:Open(cPath + cArquivo)
			oExcelApp:SetVisible(.T.)
		Else
			MsgStop("Erro na criação do arquivo na estação local") //"Erro na criacao do arquivo na estacao local. Contate o administrador do sistema"
		EndIf
	Else
		MsgStop("Microsoft Excel não instlalado.")	 //"Microsoft Excel nao instalado."
	EndIf

	RestArea(aArea)
Return

/*/
±±³Descri‡…o ³Inclui help de rotina (confirma gravacao com todos os itens ³±±
±±³          ³deletados                                                   ³±±
/*/
*******************************************************************************
Static Function AjustaHlp()
*******************************************************************************

	Local aArea		:= Getarea()
	Local aAreaSX3	:= SX3->(Getarea())
	Local aHelpPor	:= {}
	Local aHelpSpa	:= {}
	Local aHelpEng	:= {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³HELP na Inclusao  		  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Problema												  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aHelpPor,"Nao ha registros a serem gravados na " )
	Aadd(aHelpPor,"tabela SCT - Metas de Venda."  )
	// Espanhol
	Aadd(aHelpSpa,"No existen registros para grabar " )
	Aadd(aHelpSpa,"en la tabla SCT - Metas de venta."  )
	// Ingles
	Aadd(aHelpEng,"No records are to be recorded " )
	Aadd(aHelpEng,"in the table SCT - Sales Goals"  )
	PutHelp("PA050NAOREG",aHelpPor,aHelpEng,aHelpSpa,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Solucao 												  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHelpPor := {}
	aHelpSpa := {}
	aHelpEng := {}

	Aadd(aHelpPor,"Verifique a sequencia das Metas de Venda." )
	// Espanhol
	Aadd(aHelpSpa,"Verifique la sequencia de las Metas de" )
	Aadd(aHelpSpa,"venta." )
	// Ingles
	Aadd(aHelpEng,"Check the sequence of Sales Goals." )
	PutHelp("SA050NAOREG",aHelpPor,aHelpEng,aHelpSpa,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³HELP na Alteracao                               		  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Problema												  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHelpPor := {}
	aHelpSpa := {}
	aHelpEng := {}

	Aadd(aHelpPor,"Para excluir todos os itens utilize" )
	Aadd(aHelpPor,"a opcao Excluir Metas de Venda."  )
	// Espanhol
	Aadd(aHelpSpa,"Para borrar todos los items use  " )
	Aadd(aHelpSpa,"la rotina Borrar Meta de Venta."  )
	// Ingles
	Aadd(aHelpEng,"To delete all items use the" )
	Aadd(aHelpEng,"Delete option Sales Goals."  )
	PutHelp("PA050EXCL",aHelpPor,aHelpEng,aHelpSpa,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Solucao 												  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHelpPor := {}
	aHelpSpa := {}
	aHelpEng := {}

	Aadd(aHelpPor,"Posicione Meta de Venda e clique" )
	Aadd(aHelpPor,"no botao excluir." )
	// Espanhol
	Aadd(aHelpSpa,"Posicione Meta de Venta y clique" )
	Aadd(aHelpSpa,"en el botao borrar." )
	// Ingles
	Aadd(aHelpEng,"Position Sales Goals and click" )
	Aadd(aHelpEng,"on the delete button." )
	PutHelp("SA050EXCL",aHelpPor,aHelpEng,aHelpSpa,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ajusta o dicionario de dados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SX3")
	DbSetOrder(2)

	If Dbseek("CT_PRODUTO") .AND. AllTrim(SX3->X3_VALID) <> '( Vazio() .Or. ExistCpo("SB1") ) .and. U_FA050CLEAR( 1 )'
		RecLock("SX3",.F.)
		SX3->X3_VALID	:= '( Vazio() .Or. ExistCpo("SB1") ) .and. U_FA050CLEAR( 1 )'
		MsUnLock()
	EndIf

	If Dbseek("CT_GRUPO") .AND. AllTrim(SX3->X3_VALID) <> '( Vazio() .Or. ExistCpo("SBM") ) .and. U_FA050CLEAR( 2 )'
		RecLock("SX3",.F.)
		SX3->X3_VALID	:= '( Vazio() .Or. ExistCpo("SBM") ) .and. U_FA050CLEAR( 2 )'
		MsUnLock()
	EndIf

	If Dbseek("CT_TIPO") .AND. AllTrim(SX3->X3_VALID) <> '( Vazio() .Or. ExistCpo("SX5","02"+M->CT_TIPO) ) .and. U_FA050CLEAR( 3 )'
		RecLock("SX3",.F.)
		SX3->X3_VALID	:= '( Vazio() .Or. ExistCpo("SX5","02"+M->CT_TIPO) ) .and. U_FA050CLEAR( 3 )'
		MsUnLock()
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ajusta os gatilhos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SX7")
	DbSetOrder(1)

	If DbSeek("CT_GRUPO  001") .AND. AllTrim(SX7->X7_CDOMIN) == "CT_TIPO" .AND. AllTrim(SX7->X7_REGRA) == '""'
		RecLock("SX7",.F.)
		DbDelete()
		MsUnLock()
	EndIf

	If DbSeek("CT_GRUPO  002") .AND. AllTrim(SX7->X7_CDOMIN) == "CT_PRODUTO" .AND. AllTrim(SX7->X7_REGRA) == '""'
		RecLock("SX7",.F.)
		DbDelete()
		MsUnLock()
	EndIf

	If DbSeek("CT_PRODUTO001") .AND. AllTrim(SX7->X7_CDOMIN) == "CT_TIPO" .AND. AllTrim(SX7->X7_REGRA) == 'SB1->B1_TIPO'
		RecLock("SX7",.F.)
		DbDelete()
		MsUnLock()
	EndIf

	If DbSeek("CT_PRODUTO002") .AND. AllTrim(SX7->X7_CDOMIN) == "CT_GRUPO" .AND. AllTrim(SX7->X7_REGRA) == 'SB1->B1_GRUPO'
		RecLock("SX7",.F.)
		DbDelete()
		MsUnLock()
	EndIf

	If DbSeek("CT_TIPO   001") .AND. AllTrim(SX7->X7_CDOMIN) == "CT_GRUPO" .AND. AllTrim(SX7->X7_REGRA) == '""'
		RecLock("SX7",.F.)
		DbDelete()
		MsUnLock()
	EndIf

	If DbSeek("CT_TIPO   002") .AND. AllTrim(SX7->X7_CDOMIN) == "CT_PRODUTO" .AND. AllTrim(SX7->X7_REGRA) == '""'
		RecLock("SX7",.F.)
		DbDelete()
		MsUnLock()
	EndIf

	RestArea(aAreaSX3)
	RestArea(aArea)

Return

/*

FUNCOES PARA TESTE PONTO DE ENTRADA

User Function FT050MNU()
Local Putz := {}
AAdd(Putz,{'Botao 1','Alert("botao 1")', 0 , 9,0,NIL})
AAdd(Putz,{'Botao 2','Alert("botao 2")', 0 , 9,0,NIL})
AAdd(Putz,{'Botao 3','Alert("botao 3")', 0 , 9,0,NIL})

Return(Putz)

User Function FAT050BUT()
Local Putz := {}
AAdd(Putz,{"",{||Alert("TESTE1")},'Botao Int 1','Botao 1 Mouse'})
AAdd(Putz,{"",{||Alert("TESTE2")},'Botao Int 2','Botao 2 Mouse'})
AAdd(Putz,{"",{||Alert("TESTE3")},'Botao Int 3','Botao 3 Mouse'})
Return(Putz)

User Function FT050TOK()
Local lRet := .F.

MsgAlert("TEste")
Return(lRet)
*/

/*
±±ºDesc.     ³Preenche ou limpa os campos do grid da tabela SCT de acordo º±±
±±º          ³com a origem                                                º±±
*/

*******************************************************************************
User Function FA050CLEAR( nType )
*******************************************************************************

	Local oModel := FWModelActive()
	Local aArea  := GetArea()
	Local aAreaSB1 := SB1->( GetArea() )

	If nType == 1
		SB1->( dbSetOrder( 1 ) )
		If SB1->( dbSeek( xFilial("SB1") + M->CT_PRODUTO ) )
			oModel:LoadValue( 'SCTGRID', 'CT_GRUPO', SB1->B1_GRUPO )
			oModel:LoadValue( 'SCTGRID', 'CT_TIPO' , SB1->B1_TIPO  )
		EndIf

	ElseIf  nType == 2
		oModel:ClearField( 'SCTGRID', 'CT_PRODUTO' )
		oModel:ClearField( 'SCTGRID', 'CT_TIPO'    )

	ElseIf nType == 3
		oModel:ClearField( 'SCTGRID', 'CT_PRODUTO' )
		oModel:ClearField( 'SCTGRID', 'CT_GRUPO'   )

	EndIf

	RestArea(aAreaSB1)
	RestArea(aArea)

Return .T.
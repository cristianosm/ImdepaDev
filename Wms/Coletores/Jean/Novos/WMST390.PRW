#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//Item da Montagem na Mesa
#DEFINE IMCODPRO 1
#DEFINE IMDESPRO 2
#DEFINE IMLOTE   3
#DEFINE IMSUBLOT 4
#DEFINE IMQUANT  5

/*/------------------------------------------------------------------------------------------------
{Protheus.doc} WMSA390
Monitor do Processo de Montagem de Volume
@author  Jackson Patrick Werka
@since   07/02/2014
------------------------------------------------------------------------------------------------/*/
User Function WMST390()

	Local oBrowse

	Private lRasLot := (AllTrim(SuperGetMV('MV_RASTRO',.F.,'N')) == 'S') .And. SuperGetMV('MV_WMSLOTE',.F.,.F.)

	AjustaSX1()

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZCS")         // Alias da tabela utilizada
	oBrowse:SetMenuDef("WMST390")   // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription("Montagem de Volumes") // Descrição do browse "Montagem de Volumes"
	oBrowse:DisableDetails()        //Desabilita detalhes do Browse
	oBrowse:SetAmbiente(.F.)        //Desabilita opção Ambiente do menu Ações Relacionadas
	oBrowse:SetWalkThru(.F.)        //Desabilita opção WalkThru do menu Ações Relacionadas

	oBrowse:AddLegend("ZCS->ZCS_STATUS=='1'", "RED"   , "Nao Iniciado") //"Nao Iniciado"
	oBrowse:AddLegend("ZCS->ZCS_STATUS=='2'", "YELLOW", "Em Andamento") //"Em Andamento"
	oBrowse:AddLegend("ZCS->ZCS_STATUS=='3'", "GREEN" , "Finalizado") //"Finalizado"
	oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------//
//-------------------------Funcao MenuDEF----------------------------//
//-------------------------------------------------------------------//
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE "Monitor" ACTION "VIEWDEF.WMST390"   OPERATION 2  ACCESS 0 //Monitor
	ADD OPTION aRotina TITLE "Relatório CheckOut" ACTION "WMSR420"           OPERATION 9  ACCESS 0 //Relatório CheckOut

Return aRotina

//-------------------------------------------------------------------//
//-------------------------Funcao ViewDef----------------------------//
//-------------------------------------------------------------------//
Static Function ViewDef()
Local oView  := FWFormView():New()
Local oModel := ModelDef()
Local oStr1  := FWFormStruct(2,'ZCS')
Local oStr2  := FWFormStruct(2,'ZCT')
Local oStr3  := FWFormStruct(2,'ZCU')
Local oStr4  := FWFormStruct(2,'ZCV')

	oStr2:AddField('ZCT_VSTATUS', '01',"Volumes", "Situação da montagem de volumes" + '.', {"Situação da montagem de volumes"}, 'GET', '@BMP', Nil, /*cLookUp*/,.F., /*cFolder*/, /*cGroup*/, /*aComboValues*/, /*nMaxLenCombo*/, /*cIniBrow*/, .T.) //Situação da montagem de volumes
	oStr2:RemoveField('ZCT_STATUS')

	oView:SetModel(oModel)
	oView:AddField('VIEW_ZCS', oStr1, 'A390ZCS')
	oView:AddGrid( 'VIEW_ZCT', oStr2, 'A390ZCT')
	oView:AddGrid( 'VIEW_ZCU', oStr3, 'A390ZCU')
	oView:AddGrid( 'VIEW_ZCV', oStr4, 'A390ZCV')

	oView:CreateFolder( 'FOLDER1')
	oView:AddSheet('FOLDER1','SHEET1',"Embalagem") //Embalagem
	oView:AddSheet('FOLDER1','SHEET2',"Volume") //Volume

	oView:CreateHorizontalBox( 'BOXZCS', 20, /*owner*/, /*lUsePixel*/, 'FOLDER1', 'SHEET1')
	oView:CreateHorizontalBox( 'BOXZCT', 80, /*owner*/, /*lUsePixel*/, 'FOLDER1', 'SHEET1')
	oView:CreateHorizontalBox( 'BOXZCU', 30, /*owner*/, /*lUsePixel*/, 'FOLDER1', 'SHEET2')
	oView:CreateHorizontalBox( 'BOXZCV', 70, /*owner*/, /*lUsePixel*/, 'FOLDER1', 'SHEET2')

	oView:SetOwnerView('VIEW_ZCS','BOXZCS')
	oView:SetOwnerView('VIEW_ZCT','BOXZCT')
	oView:SetOwnerView('VIEW_ZCU','BOXZCU')
	oView:SetOwnerView('VIEW_ZCV','BOXZCV')

	oView:AddUserButton("Montar Volume"            ,'',{|oView| U_WMA390Volu(oView,oModel)     },"Montar Volume") //Montar Volume
	oView:AddUserButton("Liberar Documento Parcial",'',{|oView| Wma390LibP(oView,oModel)     },"Liberar Documento Parcial") //Liberar Documento Parcial
	oView:AddUserButton("Estornar Documento"       ,'',{|oView| U_WmA390Esto(2,oView,oModel)   },"Estornar Documento") //Estornar Documento
	oView:AddUserButton("Estornar Volume"          ,'',{|oView| U_WmA390Esto(1,oView,oModel)   },"Estornar Volume" ) //Estornar Volume
	oView:AddUserButton("Estornar Produto Volume"  ,'',{|oView| U_WmA390Esto(3,oView,oModel)   },"Estornar Produto Volume") //Estornar Produto Volume
	oView:AddUserButton("Imprimir Etiqueta"        ,'',{|oView| U_WMSR410A(,.F.,oView)       },"Imprimir Etiqueta") //Imprimir Etiqueta
	oView:setUseCursor(.F.)
	
Return oView

//-------------------------------------------------------------------//
//-------------------------Funcao ModelDef---------------------------//
//-------------------------------------------------------------------//
Static Function ModelDef()
Local oModel := MPFormModel():New('A390DOC')
Local oStr1  := FWFormStruct(1,'ZCS')
Local oStr2  := FWFormStruct(1,'ZCT')
Local oStr3  := FWFormStruct(1,'ZCU')
Local oStr4  := FWFormStruct(1,'ZCV')
Local aTrigger := {}

	Local bStatus := {||,Iif(ZCT->ZCT_STATUS=="1",'BR_VERMELHO',Iif(ZCT->ZCT_STATUS=="2",'BR_AMARELO','BR_VERDE'))}
	//oStr2:AddField(< cTitulo >, < cTooltip >, < cIdField >, < cTipo >, < nTamanho >, [ nDecimal ], [ bValid ], [ bWhen ], [ aValues ], [ lObrigat ], [ bInit ], < lKey >, [ lNoUpd ], [ lVirtual ], [ cValid ])
	oStr2:AddField("Status", "Situação da montagem de volumes", 'ZCT_VSTATUS', 'C', 11, 0,,,,,bStatus,,,.T.) //Status //Situação da montagem de volumes

	oModel:addFields('A390ZCS',,oStr1)
	oModel:addGrid('A390ZCT','A390ZCS',oStr2)
	If ZCT->(FieldPos("ZCT_DATA")) > 0		
		oModel:SetRelation('A390ZCT', { { 'ZCT_FILIAL', 'xFilial("ZCT")' }, { 'ZCT_CARGA', 'ZCS_CARGA' }, { 'ZCT_PEDIDO', 'ZCS_PEDIDO' }, { 'ZCT_DATA', 'DTOS(ZCS_DATA)' }, { 'ZCT_HORA', 'ZCS_HORA' } }, ZCT->(IndexKey(1)) )
	Else
		oModel:SetRelation('A390ZCT', { { 'ZCT_FILIAL', 'xFilial("ZCT")' }, { 'ZCT_CARGA', 'ZCS_CARGA' }, { 'ZCT_PEDIDO', 'ZCS_PEDIDO' } }, ZCT->(IndexKey(1)) )
	EndIf	

	oStr3:SetProperty('ZCU_NOMOPE',MODEL_FIELD_INIT,{||Posicione('DCD',1,xFilial('DCD')+ZCU->ZCU_OPERAD,'DCD_NOMFUN')})
	oModel:addGrid('A390ZCU','A390ZCS',oStr3)
	If ZCU->(FieldPos("ZCU_DATA")) > 0
		oModel:SetRelation('A390ZCU', { { 'ZCU_FILIAL', 'xFilial("ZCU")' }, { 'ZCU_CARGA', 'ZCS_CARGA' }, { 'ZCU_PEDIDO', 'ZCS_PEDIDO' }, { 'ZCU_DATA', 'DTOS(ZCS_DATA)' }, { 'ZCU_HORA', 'ZCS_HORA' } }, ZCU->(IndexKey(3)) )
	Else
		oModel:SetRelation('A390ZCU', { { 'ZCU_FILIAL', 'xFilial("ZCU")' }, { 'ZCU_CARGA', 'ZCS_CARGA' }, { 'ZCU_PEDIDO', 'ZCS_PEDIDO' } }, ZCU->(IndexKey(2)) )
	EndIf	

	oModel:addGrid('A390ZCV','A390ZCU',oStr4)
	If ZCV->(FieldPos("ZCV_CARGA")) > 0
		oModel:SetRelation('A390ZCV', { { 'ZCV_FILIAL', 'xFilial("ZCV")' }, { 'ZCV_CARGA', 'ZCU_CARGA' }, { 'ZCV_PEDIDO', 'ZCU_PEDIDO' }, { 'ZCV_CODVOL', 'ZCU_CODVOL' } }, ZCV->(IndexKey(3)) )
	Else
		oModel:SetRelation('A390ZCV', { { 'ZCV_FILIAL', 'xFilial("ZCV")' }, { 'ZCV_CODVOL', 'ZCU_CODVOL' } }, ZCV->(IndexKey(2)) )
	EndIf	
	
	oModel:SetPrimaryKey({'ZCS_FILIAL', 'ZCS_CARGA','ZCS_PEDIDO','ZCS_DATA','ZCS_HORA'})
	
	oModel:SetOnDemand(.T.)
	oModel:getModel('A390ZCT'):SetOnlyView(.T.)
	oModel:getModel('A390ZCU'):SetOnlyView(.T.)
	oModel:getModel('A390ZCV'):SetOnlyView(.T.)

Return oModel

//--------------------------------------------------------------------------//
//---------------------Montagem de Volume Sem Coletor RF--------------------//
//--------------------------------------------------------------------------//
User Function WMA390Volu(oView,oModel)
	Local lRet      := .T.
	Local oDlg      := Nil
	Local oQtde     := Nil
	Local oCodPro   := Nil
	Local oLote     := Nil
	Local oSubLot   := Nil
	Local cTitulo   := ''
	Local nQtde     := 1
	Local cCarga    := oView:GetModel('A390ZCT'):GetValue('ZCT_CARGA')
	Local cPedido   := oView:GetModel('A390ZCT'):GetValue('ZCT_PEDIDO')
	Local cDtHr     := DTOS(oView:GetModel('A390ZCS'):GetValue('ZCS_DATA')) + oView:GetModel('A390ZCS'):GetValue('ZCS_HORA')
	Local cCodVol   := Padl(CBProxCod('MV_WMSNVOL'),10,'0')
	Local cCodPro   := Space(Len(SB1->B1_CODBAR))
	Local cLote     := Space(Len(ZCT->ZCT_LOTE))
	Local cSubLot   := Space(Len(ZCT->ZCT_SUBLOT))
	Local cRastro   := Space(Len(SB1->B1_RASTRO))
	Local cNext     := ''
	Local nList     := 1
	Local cPictCBar := PesqPictQt("ZCT_QTEMBA",Len(ZCT->ZCT_CODPRO))

	Private oListBox  := Nil
	Private aListBox  := {}

	If ZCS->ZCS_STATUS == '3'
		Aviso("Atenção","Pedido com todos os itens embalados",{"OK"}) //Atenção //Pedido com todos os itens embalados
		lRet := .F.
	EndIf

	If Empty(cCodVol)
		MsgAlert("Parâmetro MV_CODVOL inexistente! Avise o Administrador do sistema!") 
		lRet := .F.
	EndIf

	If lRet
		oView:AFOLDERS[1][5]:NOPTION := 2
		cTitulo := "Volume: " + cCodVol
		AAdd(aListBox,{Space(Len(SB1->B1_COD)),Space(Len(SB1->B1_DESC)),Space(Len(ZCT->ZCT_LOTE)),Space(Len(ZCT->ZCT_SUBLOT)),0})

		SetKey(VK_F6,{|| EstItem()})

		If lRasLot

			DEFINE MSDIALOG oDlg TITLE cTitulo FROM  170,080 TO 665,735 PIXEL

			@ 07,10 SAY "Quantidade" SIZE 50,8 OF oDlg PIXEL //Quantidade
			@ 05,60 MSGET oQtde VAR nQtde SIZE 40,10 OF oDlg PICTURE '@E 99999,999.99' PIXEL

			@ 23,10 SAY "Código do Produto" SIZE 50,8 OF oDlg PIXEL //Código do Produto
			@ 22,60 MSGET oCodPro VAR cCodPro PICTURE '@!' VALID Iif(!Empty(cCodPro),WMA390VPLS(oListBox,cCarga,cPedido,cCodVol,cCodPro,@cLote,@cSubLot,nQtde,@cRastro,1,,oQtde,,cDtHr),.F.) F3 'SB1' SIZE 127,10 OF oDlg PIXEL
			@ 22,60 MSGET cNext PICTURE '@!' WHEN !(cRastro $ 'LS') SIZE 01,01 OF oDlg PIXEL

			@ 39,10 SAY "Lote" SIZE 50,8 OF oDlg PIXEL //Lote
			@ 38,60 MSGET oLote VAR cLote PICTURE '@!' VALID WMA390VPLS(oListBox,cCarga,cPedido,cCodVol,cCodPro,@cLote,@cSubLot,nQtde,@cRastro,2,,oQtde,,cDtHr) WHEN (cRastro $ 'LS') SIZE 127,10 OF oDlg PIXEL
			@ 38,60 MSGET cNext PICTURE '@!' WHEN !(cRastro $ 'S') SIZE 01,01 OF oDlg PIXEL

			@ 55,10 SAY "Sublote" SIZE 50,8 OF oDlg PIXEL //SubLote
			@ 54,60 MSGET oSubLot VAR cSubLot PICTURE '@!' VALID WMA390VPLS(oListBox,cCarga,cPedido,cCodVol,cCodPro,@cLote,@cSubLot,nQtde,@cRastro,3,,oQtde,,cDtHr) WHEN (cRastro == 'S') SIZE 127,10 OF oDlg PIXEL

			@ 70,09 TO 205, 319 LABEL '' OF oDlg PIXEL
			@ 75,12 LISTBOX oListBox VAR nList FIELDS HEADER "Código", "Descrição", "Lote", "SubLote", "Quantidade" SIZE 304,126 PIXEL //Código, Descrição, Lote, SubLote, Quantidade

			oListBox:SetArray(aListBox)
			oListBox:bLine:={||{ aListBox[oListBox:nAt,IMCODPRO],;
										aListBox[oListBox:nAt,IMDESPRO],;
										aListBox[oListBox:nAt,IMLOTE  ],;
										aListBox[oListBox:nAt,IMSUBLOT],;
										Transform(aListBox[oListBox:nAt,IMQUANT],cPictCBar)}}

			DEFINE SBUTTON FROM 220, 260 TYPE 1 OF oDlg ENABLE ACTION (WMA390Grv(1,cCarga,cPedido,cCodVol,aListBox,,cDtHr),oDlg:End())
			DEFINE SBUTTON FROM 220, 290 TYPE 2 OF oDlg ENABLE ACTION oDlg:End()

			@ 220,10 SAY "[F6] Estornar Item" SIZE 100,8 OF oDlg PIXEL //[F6] Estornar Item

		Else
			DEFINE MSDIALOG oDlg TITLE cTitulo FROM  170,080 TO 550,735 PIXEL

			@ 07,10 SAY "Quantidade" SIZE 50,8 OF oDlg PIXEL //Quantidade
			@ 05,60 MSGET oQtde VAR nQtde SIZE 40,10 OF oDlg PICTURE '@E 99999,999.99' PIXEL

			@ 23,10 SAY "Código do Produto" SIZE 50,8 OF oDlg PIXEL //Código do Produto
			@ 22,60 MSGET oCodPro VAR cCodPro PICTURE '@!' VALID Iif(!Empty(cCodPro),WMA390VPLS(oListBox,cCarga,cPedido,cCodVol,cCodPro,@cLote,@cSubLot,nQtde,@cRastro,1,,oQtde,,cDtHr),.T.) F3 'SB1' SIZE 127,10 OF oDlg PIXEL

			@ 38,09 TO 173, 319 LABEL '' OF oDlg PIXEL
			@ 43,12 LISTBOX oListBox VAR cVar FIELDS HEADER "Código", "Descrição", "Quantidade" SIZE 304,126 PIXEL //Código, Descrição, Quantidade

			oListBox:SetArray(aListBox)
			oListBox:bLine:={||{ aListBox[oListBox:nAt,IMCODPRO],;
										aListBox[oListBox:nAt,IMDESPRO],;
										Transform(aListBox[oListBox:nAt,IMQUANT],cPictCBar)}}

			DEFINE SBUTTON FROM 175, 260 TYPE 1 OF oDlg ENABLE ACTION (WMA390Grv(1,cCarga,cPedido,cCodVol,aListBox,,cDtHr),oDlg:End())
			DEFINE SBUTTON FROM 175, 290 TYPE 2 OF oDlg ENABLE ACTION oDlg:End()

			@ 175,10 SAY "[F6] Estornar Item" SIZE 100,8 OF oDlg PIXEL //[F6] Estornar Item
		EndIf

		ACTIVATE MSDIALOG oDlg

	EndIf

	SetKey(VK_F6,Nil)

	oModel:DeActivate()
	oModel:Activate()
	oView:Refresh()
Return

//--------------------------------------------------------------------------//
//---------------------Validação de produto/lote/sublote--------------------//
//--------------------------------------------------------------------------//
Static Function WMA390VPLS(oListBox,cCarga,cPedido,cCodVol,cProduto,cLote,cSubLote,nQtde,cRastro,nCampo,lColetor,oQtde,lSepara,cDtHr)
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local aEtiqueta  := {}
Local nTotEmba   := 0
Local nTotSepa   := 0
Local nPos       := 0
Local aProdutos  := {}

Default cProduto := Space(Len(SB1->B1_CODBAR))
Default cLote    := Space(Len(ZCT->ZCT_LOTE))
Default cSubLote := Space(Len(ZCT->ZCT_SUBLOT))
Default lColetor := .F.
Default lSepara  := .F. //quando montagem de volume é automatica após a separação não deve desbloquear para o faturamento, que será somente na conferencia de expedição.
Default cDtHr    := ''   

If !Empty(cProduto)

	aEtiqueta := CBRetEtiEan(cProduto)

	If Empty(aEtiqueta)
		SB1->(DbSetOrder(1))
		If !(SB1->(MsSeek(xFilial('SB1')+cProduto)))
			If !lColetor
				Aviso("Montagem de Volume", "Código do produto inválido", {"OK"}) //Montagem de Volume //Código do produto //inválido //OK
			Else
				DLVTAviso("Aviso", "Código do produto inválido") //Aviso //Código do produto inválido
				VtKeyboard(Chr(20))
			EndIf
			lRet := .F.
		EndIf
	ElseIf ValType(aEtiqueta[2]) == 'N'
		cProduto := aEtiqueta[1]
		nQtde    := If(aEtiqueta[2] == 0,1,aEtiqueta[2]) * nQtde
	EndIf

	If lRet
		cRastro := Posicione('SB1', 1, xFilial('SB1')+cProduto, 'B1_RASTRO')

		//Se o campo é Produto e rastro é por Lote ou SubLote retorna .T. para que o usuário forneça as outras informações
		//Se o campo é Lote e rastro é por SubLote retorna .T. para que o usuário forneça o SubLote
		If !Empty(cRastro) .And. lRasLot
			If nCampo == 1 .And. cRastro $ 'L|S'
				Return .T.
			ElseIf nCampo == 2 .And. cRastro $ 'S'
				Return .T.
			EndIf
		EndIf

		ZCT->(DbSetOrder(1)) //ZCT_FILIAL+ZCT_CARGA+ZCT_PEDIDO+ZCT_CODPRO+ZCT_LOTE+ZCT_SUBLOT
		If ZCT->(DbSeek(xFilial('ZCT')+cCarga+cPedido+cProduto+cLote+cSubLote))
			While ZCT->(!Eof()) .AND. (xFilial('ZCT')+cCarga+cPedido+cProduto+cLote+cSubLote == ZCT->ZCT_FILIAL+ZCT->ZCT_CARGA+ZCT->ZCT_PEDIDO+ZCT->ZCT_CODPRO+ZCT->ZCT_LOTE+ZCT->ZCT_SUBLOT)
				nTotSepa += ZCT->ZCT_QTSEPA
				nTotEmba += ZCT->ZCT_QTEMBA
				ZCT->(DbSkip())
			EndDo
		ElseIf ZCT->(DbSeek(xFilial('ZCT')+cCarga+cPedido+cProduto)) .And. !lRasLot
			While ZCT->(!Eof()) .AND. (xFilial('ZCT')+cCarga+cPedido+cProduto == ZCT->ZCT_FILIAL+ZCT->ZCT_CARGA+ZCT->ZCT_PEDIDO+ZCT->ZCT_CODPRO)
				nTotSepa += ZCT->ZCT_QTSEPA
				nTotEmba += ZCT->ZCT_QTEMBA
				ZCT->(DbSkip())
			EndDo
		Else
			If !lColetor
				Aviso("Montagem de Volume", "Produto não pertence ao documento", {"OK"}) //Montagem de Volume //Produto não pertence ao documento //OK
			Else
				DLVTAviso("Aviso","Produto não pertence ao documento") //"Aviso" //"Produto não pertence ao documento"
				VtKeyboard(Chr(20))
			EndIf
			lRet     := .F.
			cProduto := Space(Len(SB1->B1_COD))
			cLote    := Space(Len(ZCT->ZCT_LOTE))
			cSubLote := Space(Len(ZCT->ZCT_SUBLOT))
		EndIf

		If lRet .And. nTotEmba+nQtde > nTotSepa
			If !lColetor
				Aviso("Montagem de Volume", "Quantidade para este produto superior a quantidade separada", {"OK"}) //Montagem de Volume //Quantidade para este produto superior a quantidade separada //OK
			Else
				DLVTAviso("Aviso","Quantidade para este produto superior a quantidade separada") //Aviso //Quantidade para este produto superior a quantidade separada
				VtKeyboard(Chr(20))
			EndIf
			lRet := .F.
		EndIf


		If lRet .And. !lColetor
			If lRasLot
				nPos := AScan(aListBox,{|x|x[1]+x[3]+x[4] == cProduto+cLote+cSubLote})
			Else
				nPos := AScan(aListBox,{|x|x[1] == cProduto})
			EndIf

			If nPos == 0
				If Len(aListBox) == 1 .And. Empty(aListBox[1,1])
					nPos := 1
				Else
					AAdd(aListBox, Array(5))
					nPos := Len(aListBox)
				EndIf

				aListBox[nPos,IMCODPRO] := cProduto
				aListBox[nPos,IMDESPRO] := Posicione('SB1',1,xFilial('SB1')+cProduto,'B1_DESC')
				aListBox[nPos,IMLOTE]   := cLote
				aListBox[nPos,IMSUBLOT] := cSubLote
				aListBox[nPos,IMQUANT]  := 0
			EndIf

			If (aListBox[nPos,IMQUANT]+nTotEmba+nQtde > nTotSepa)
				Aviso("Montagem de Volume", "Quantidade para este produto superior a quantidade separada", {"OK"}) //Quantidade para este produto superior a quantidade separada //OK
				lRet := .F.
			EndIf

			If lRet
				aListBox[nPos,IMQUANT] += nQtde
				oListBox:SetArray( aListBox )

				If lRasLot
					oListBox:bLine:={||{ aListBox[oListBox:nAt,IMCODPRO],;
												aListBox[oListBox:nAt,IMDESPRO],;
												aListBox[oListBox:nAt,IMLOTE],;
												aListBox[oListBox:nAt,IMSUBLOT],;
												Transform(aListBox[oListBox:nAt,IMQUANT],PesqPictQt("ZCT_CODPRO",Len(ZCT->ZCT_CODPRO)))}}
				Else
					oListBox:bLine:={||{ aListBox[oListBox:nAt,IMCODPRO],;
												aListBox[oListBox:nAt,IMDESPRO],;
												Transform(aListBox[oListBox:nAt,IMQUANT],PesqPictQt("ZCT_CODPRO",Len(ZCT->ZCT_CODPRO)))}}
				EndIf

				nQtde    := 0
				cProduto := Space(Len(SB1->B1_COD))
				cLote    := Space(Len(ZCT->ZCT_LOTE))
				cSubLote := Space(Len(ZCT->ZCT_SUBLOT))
				cRastro  := ''
				oListBox:Refresh()
				oQtde:SetFocus()
			EndIf
		ElseIf lRet .And. lColetor
			AAdd(aProdutos,{cProduto,Posicione('SB1',1,xFilial('SB1')+cProduto,'B1_DESC'),cLote,cSubLote,nQtde})
			If WMA390Grv(2,cCarga,cPedido,cCodVol,aProdutos,lSepara,cDtHr)
				If lFim
					WMV080Fina(Iif(!Empty(cCarga),1,2),cCodVol,cCarga,cPedido)
				EndIf
			Else
				DLVTAviso("Aviso","Houve problema na gravação!") //Aviso //Código do produto inválido
				VtKeyboard(Chr(20))
				lRet := .F.
			EndIf
		EndIf
	EndIf
Else
	lRet := .F.
EndIf

RestArea(aAreaAnt)
Return lRet

//------------------------------------------------------------------------------//
//---------------------Estorno de Item na Montagem de Volume--------------------//
//------------------------------------------------------------------------------//
Static Function EstItem()

If QtdComp(Len(aListBox)) > QtdComp(0)
	If Aviso("Estornar Item", "Confirma estorno do item" + ' ' +AllTrim(aListBox[oListBox:nAt,1])+'?',{"Sim","Não"}) == 1
		ADel(aListBox,oListBox:nAt)
		ASize(aListBox,Len(aListBox)-1)
		oListBox:nAt := 1
		oListBox:Refresh()
	EndIf
EndIf

Return

//-------------------------------------------------------------------------------------------------//
//---------------------Grava o Volume, os Itens do Volume, atualiza Quantidades--------------------//
//---------------------e Status do Processo de Embalagem da Carga/Pedido na ZCS--------------------//
//-------------------------------------------------------------------------------------------------//
Static Function WMA390Grv(nAcao,cCarga,cPedido,cVolume,aProdutos,lSepara,cDtHr)
Local nX          := 0
Local nY          := 0
Local lRet        := .F.
Local nQtdEmb     := 0 // Quantidade que será embalada no ZCV corrente
Local nQtdRes     := 0 // Quantidade que resta a ser embalada
Local nQtdSol     := 0
Local nSaldo      := 0
Local nQtdVol     := 0
Local cLocImp     := Space(Len(CB5->CB5_CODIGO))
Local lLocImp     := .T.
Local nTotLote    := 0
Local nTotItem    := 0
Local nQtdTotEmb  := 0
Local lRasLot     := (AllTrim(SuperGetMV('MV_RASTRO',.F.,'N')) == 'S') .And. SuperGetMV('MV_WMSLOTE',.F.,.F.)
Local cQuery      := ''
Local cAliasZCT   := ''
Local cAliasSC9   := ''
Local cAliasZCU   := ''
Local cAliasZCV   := ''
Local aAreaAnt   := GetArea()

Default cCarga    := ''
Default cPedido   := ''
Default cVolume   := ''
Default aProdutos := {}
Default nAcao     := 1
Default lSepara   := .F.
Default cDtHr     := ''

ZCS->(DbSetOrder(1)) //ZCS_FILIAL+ZCS_CARGA+ZCS_PEDIDO+DTOS(ZCS_DATA)+ZCS_HORA
ZCT->(DbSetOrder(1)) //ZCT_FILIAL+ZCT_CARGA+ZCT_PEDIDO+ZCT_CODPRO+ZCT_LOTE+ZCT_SUBLOT+ZCT_IDDCF
ZCV->(DbSetOrder(2)) //ZCV_FILIAL+ZCV_CODPRO+ZCV_LOTE+ZCV_SUBLOT+ZCV_IDDCF+ZCV_SEQUEN

While !LockByName(Iif(nAcao==1,'WMST390','WMSV080'),.F.,.F. )
	Sleep(50)
	nX++
	If nX > 200
		Return ( .F. )
	EndIf
EndDo

Begin Transaction

	ZCU->(DbSetOrder(2)) //ZCU_FILIAL+ZCU_CARGA+ZCU_PEDIDO+ZCU_CODVOL
	If ZCU->(!DbSeek(xFilial('ZCU')+cCarga+cPedido+cVolume))
		RecLock('ZCU',.T.)
		ZCU->ZCU_FILIAL := xFilial('ZCU')
		ZCU->ZCU_CARGA  := cCarga
		ZCU->ZCU_PEDIDO := cPedido
		ZCU->ZCU_CODVOL := cVolume
		ZCU->ZCU_OPERAD := __CUSERID
		ZCU->ZCU_IMPETI := '0'
		If ZCU->(FieldPos("ZCU_DATA")) > 0
			ZCU->ZCU_DATA := StoD(SubStr(cDtHr,1,8))
			ZCU->ZCU_HORA := SubStr(cDtHr,9,5)
		EndIf
		ZCU->(MsUnLock())
	EndIf

	For nY := 1  To Len(aProdutos)

		nQtdRes  := aProdutos[nY,5]

		cQuery := "SELECT ZCT_CARGA, ZCT_PEDIDO, ZCT_LOTE, ZCT_SUBLOT, ZCT_QTSEPA, ZCT_QTEMBA, ZCT_IDDCF, ZCT.R_E_C_N_O_ RECNOZCT"
		cQuery += " FROM "+RetSqlName('ZCT')+" ZCT"
		cQuery += " WHERE ZCT_FILIAL  = '"+xFilial('ZCT')+"'"
		cQuery +=      " AND ZCT_CARGA  = '"+cCarga+"'"
		cQuery +=      " AND ZCT_PEDIDO = '"+cPedido+"'"
		cQuery +=      " AND ZCT_CODPRO = '"+aProdutos[nY,1]+"'"
		If lRasLot
			cQuery +=   " AND ZCT_LOTE   = '"+aProdutos[nY,3]+"'"
			cQuery +=   " AND ZCT_SUBLOT = '"+aProdutos[nY,4]+"'"
		EndIf
		If ZCT->(FieldPos("ZCT_DATA")) > 0
			cQuery +=   " AND ZCT_DATA = '"+SubStr(cDtHr,1,8)+"'"
			cQuery +=   " AND ZCT_HORA = '"+SubStr(cDtHr,9,5)+"'"
		EndIf			
		cQuery +=      " AND ZCT_STATUS <> '3'"
		cQuery +=      " AND D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasZCT := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasZCT,.F.,.T.)

		nTotItem := 0
		nQtdSol  := nQtdRes
		While (cAliasZCT)->(!Eof()) .AND. QtdComp(nQtdRes) > 0

			nTotLote := 0
			nSaldo   := (cAliasZCT)->ZCT_QTSEPA - (cAliasZCT)->ZCT_QTEMBA
			If QtdComp(nQtdRes) > QtdComp(nSaldo)
				nQtdEmb := nSaldo
			Else
				nQtdEmb := nQtdRes
			EndIf
			nQtdRes -= nQtdEmb

			//verifica se o produto é um filho
			If SuperGetMV("MV_WMSNEW",.F.,.F.)
				dbSelectArea("D11")
				D11->(dbSetOrder(2))
				If dbSeek(xFilial("D11")+aProdutos[nY,1])
					cProdSC9 := D11->D11_PRODUT
					nQTMULT  := D11->D11_QTMULT
				Else
					cProdSC9 := aProdutos[nY,1]
					nQTMULT  := 1
				EndIf
			Else
				cProdSC9 := aProdutos[nY,1]
				nQTMULT  := 1
			EndIf
			cQuery := "SELECT C9_SEQUEN, SUM(C9_QTDLIB) AS SOMASC9" //O SUM para quando se está trabalhando com carga
			cQuery += " FROM "+RetSqlName('SC9')+" SC9"
			cQuery += " WHERE C9_FILIAL   = '"+xFilial('SC9')+"'"
			If !(Empty(cCarga))
				cQuery +=   " AND C9_CARGA  = '"+(cAliasZCT)->ZCT_CARGA+"'"
			EndIf
			cQuery +=      " AND C9_PEDIDO   = '"+(cAliasZCT)->ZCT_PEDIDO+"'"
			cQuery +=      " AND C9_PRODUTO = '"+cProdSC9+"'"
			cQuery +=      " AND C9_LOTECTL = '"+(cAliasZCT)->ZCT_LOTE+"'"
			cQuery +=      " AND C9_NUMLOTE = '"+(cAliasZCT)->ZCT_SUBLOT+"'"
			cQuery +=      " AND C9_BLWMS   = '01'"
			cQuery +=      " AND C9_IDDCF   = '"+(cAliasZCT)->ZCT_IDDCF+"'"
			cQuery +=      " AND D_E_L_E_T_ = ' '"
			cQuery +=      " GROUP BY C9_SEQUEN"
			cQuery +=      " ORDER BY C9_SEQUEN"
			cQuery := ChangeQuery(cQuery)
			cAliasSC9 := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSC9,.F.,.T.)

			While (cAliasSC9)->(!Eof()) .AND. QtdComp(nQtdEmb) > 0
				//É preciso descontar a quantidade embalada em volumes anteriores
				cQuery := "SELECT SUM(ZCV_QUANT) AS SOMAZCV"
				cQuery += " FROM "+RetSqlName('ZCV')+" ZCV"
				cQuery += " WHERE ZCV_FILIAL = '"+xFilial('ZCV')+"'"
				cQuery +=   " AND ZCV_CODPRO = '"+aProdutos[nY,1]+"'"
				cQuery +=   " AND ZCV_LOTE   = '"+(cAliasZCT)->ZCT_LOTE+"'"
				cQuery +=   " AND ZCV_SUBLOT = '"+(cAliasZCT)->ZCT_SUBLOT+"'"
				cQuery +=   " AND ZCV_IDDCF  = '"+(cAliasZCT)->ZCT_IDDCF+"'"
				cQuery +=   " AND ZCV_SEQUEN = '"+(cAliasSC9)->C9_SEQUEN+"'"
				cQuery +=   " AND ZCV_STATUS <> '1'"
				cQuery +=   " AND D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				cAliasZCV := GetNextAlias()
				DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasZCV,.F.,.T.)

				//Se a Quantidade a embalar for maior que o item liberado varre as outras sequencias do pedido
				If QtdComp(nQtdEmb) >  QtdComp(((cAliasSC9)->SOMASC9 * nQTMULT) - (cAliasZCV)->SOMAZCV)
					nQtdVol := ((cAliasSC9)->SOMASC9 * nQTMULT) - (cAliasZCV)->SOMAZCV
				Else
					nQtdVol := nQtdEmb
				EndIf

				If QtdComp(nQtdVol) == 0
					(cAliasSC9)->(DbSkip())
					Loop
				EndIf

				ZCV->(DbSetOrder(1))
				If ZCV->(!DbSeek(xFilial('ZCV')+cVolume+aProdutos[nY,1]+(cAliasZCT)->ZCT_LOTE+(cAliasZCT)->ZCT_SUBLOT+(cAliasZCT)->ZCT_IDDCF+(cAliasSC9)->C9_SEQUEN))
					RecLock('ZCV',.T.)
					ZCV->ZCV_FILIAL := xFilial('ZCV')
					ZCV->ZCV_CODVOL := cVolume
					ZCV->ZCV_CODPRO := aProdutos[nY,1]
					ZCV->ZCV_LOTE   := (cAliasZCT)->ZCT_LOTE
					ZCV->ZCV_SUBLOT := (cAliasZCT)->ZCT_SUBLOT
					ZCV->ZCV_SEQUEN := (cAliasSC9)->C9_SEQUEN
					ZCV->ZCV_QUANT  := nQtdVol
					ZCV->ZCV_IDDCF  := (cAliasZCT)->ZCT_IDDCF
					ZCV->ZCV_STATUS := '0' //Não Liberado
					If ZCV->(FieldPos("ZCV_CARGA")) > 0
						ZCV->ZCV_CARGA  := (cAliasZCT)->ZCT_CARGA
						ZCV->ZCV_PEDIDO := (cAliasZCT)->ZCT_PEDIDO
						ZCV->ZCV_DATA   := StoD(SubStr(cDtHr,1,8))
						ZCV->ZCV_HORA   := SubStr(cDtHr,9,5)
					EndIf						
					ZCV->(MsUnlock())
				Else
					RecLock('ZCV',.F.)
					ZCV->ZCV_QUANT  += nQtdVol
					ZCV->(MsUnlock())
				EndIf
				nQtdEmb    -= nQtdVol
				nTotLote   += nQtdVol
				nTotItem   += nQtdVol
				nQtdTotEmb += nQtdVol
				(cAliasSC9)->(DbSkip())
				(cAliasZCV)->(DbCloseArea())
			EndDo

			ZCT->(DbGoTo((cAliasZCT)->RECNOZCT))
			RecLock('ZCT',.F.)
			ZCT->ZCT_QTEMBA += nTotLote
			If ZCT->ZCT_QTEMBA == ZCT->ZCT_QTSEPA
				ZCT->ZCT_STATUS := '3' //Finalizado
			Else
				ZCT->ZCT_STATUS := '2' //Em Andamento
			EndIf
			lRet := .T.
			ZCT->(MsUnlock())
			(cAliasZCT)->(DbSkip())
			(cAliasSC9)->(DbCloseArea())
		EndDo

		If QtdComp(nQtdSol) != QtdComp(nTotItem)
			If nAcao == 1
				Aviso("Montagem de Volume", "Quantidade solicitada para embalagem do produto"+AllTrim(aProdutos[nY,1])+"não possui saldo de pedido a ser liberado", {'OK'})
			Else
				DLVTAviso("Aviso","Quantidade solicitada para embalagem do produto não possui saldo de pedido a ser liberado")
				VtKeyboard(Chr(20))
			EndIf
			lRet := .F.
			Exit
		EndIf

		(cAliasZCT)->(DbCloseArea())
	Next

	If lRet
		If ZCS->(DbSeek(xFilial('ZCS')+cCarga+cPedido+cDtHr))
			RecLock('ZCS',.F.)
			ZCS->ZCS_QTEMBA += nQtdTotEmb
			If ZCS->ZCS_QTEMBA == ZCS->ZCS_QTSEPA
				ZCS->ZCS_STATUS := '3' //Finalizado
			Else
				ZCS->ZCS_STATUS := '2' //Em Andamento
			EndIf
			ZCS->(MsUnlock())
		EndIf

		If ZCU->(FieldPos("ZCU_DATA")) > 0
			cSeek := cCarga+cPedido+cDtHr
			nIndZCU := 3
		Else
			cSeek := cCarga+cPedido
			nIndZCU := 2
		EndIf
		//Atualização do Status da ZCV para Liberado
		If ZCS->ZCS_STATUS == '3'
			ZCU->(DbSetOrder(nIndZCU))
			If ZCU->(DbSeek(xFilial('ZCU')+cSeek))
				While ZCU->(!Eof()) .And. (ZCU->(ZCU_FILIAL+ZCU_CARGA+ZCU_PEDIDO+If(nIndZCU == 3,DTOS(ZCU_DATA)+ZCU_HORA,'')) == xFilial("ZCU")+cSeek)
					ZCV->(DbSetOrder(1))
					If ZCV->(DbSeek(xFilial('ZCV')+ZCU->ZCU_CODVOL))
						While ZCV->(!Eof()) .And. (ZCV->(ZCV_FILIAL+ZCV->ZCV_CODVOL)  == xFilial("ZCV")+ZCU->ZCU_CODVOL)
							RecLock('ZCV',.F.)
							ZCV->ZCV_STATUS := '1' //Liberado
							ZCV->(MsUnlock())
							ZCV->(DbSkip())
						EndDo
					EndIf
					ZCU->(DbSkip())
				EndDo
				If ZCT->(FieldPos("ZCT_DATA")) > 0
					nInd  := 3
					cSeek := cCarga+cPedido+cDtHr
				Else
					nInd  := 1
					cSeek := cCarga+cPedido
				EndIf
				SC9->(DbSetOrder(9))
				ZCT->(DbSetOrder(nInd))
				If ZCT->(DbSeek(xFilial('ZCT')+cSeek))
					While ZCT->(!Eof()) .And. (ZCT->(ZCT_FILIAL+ZCT_CARGA+ZCT_PEDIDO+If(nInd == 3,DTOS(ZCT_DATA)+ZCT_HORA,'')) == xFilial('ZCT')+cSeek)
						RecLock('ZCT',.F.)
						ZCT->ZCT_QTLIBE := ZCT->ZCT_QTEMBA
						ZCT->(MsUnlock())
						If SC9->(MsSeek(xFilial('SC9')+ZCT->ZCT_IDDCF)) .And. !(lSepara .And. (AllTrim(SuperGetMV('MV_WMSCEXP',.F.,'0'))  $ '14') )
							While SC9->(!Eof()) .And. (SC9->(C9_FILIAL+C9_IDDCF) == xFilial('SC9')+ZCT->ZCT_IDDCF)
								RecLock('SC9',.F.)
								SC9->C9_BLWMS := '05'
								SC9->(MsUnlock())
								SC9->(DbSkip())
							EndDo
						EndIf
						ZCT->(DbSkip())
					EndDo
				EndIf
			EndIf
		EndIf
	EndIf
	If !lRet
		DisarmTransaction()
	EndIf
End Transaction

If nAcao == 1
	UnLockByName('WMST390',.F.,.F.)
ElseIf nAcao == 2
	UnLockByName('WMSV080',.F.,.F.)
EndIf

If ZCS->ZCS_STATUS == '3' .And. nAcao == 1
	//Pergunta se será feita a impressão da Etiqueta
	If MsgYesNo("Deseja imprimir as etiquetas de Volume?","Aviso") //Deseja imprimir as etiquetas de Volume?
		If Empty(SuperGetMV('MV_WMSLOCI',.F.,''))

			DEFINE MSDIALOG oDlgLI TITLE "Informe local da impressão" From 50,50 to 120,280 PIXEL //Informe local da impressão

				@ 06,05 SAY "Local de Impressão:" SIZE 50,8 OF oDlgLI PIXEL //Local de Impressão:
				@ 05,60 MSGET oGetLI VAR cLocImp F3 'CB5' SIZE 50,06 WHEN .T. PICTURE '@!' OF oDlgLI PIXEL
				DEFINE SBUTTON FROM 21,083 TYPE 1 ACTION (nOpcLI := 1,oDlgLI:End()) ENABLE Of oDlgLI

			ACTIVATE DIALOG oDlgLI CENTERED

			If !CB5SetImp(cLocImp,IsTelNet())
				Alert("Local de impressao invalido!","Aviso",.t.,3000,2) //
				lLocImp := .F.
			EndIf

		ElseIf !CB5SetImp(CBRLocImp('MV_WMSLOCI'),IsTelNet())
			Alert("Local de impressao invalido!","Aviso",.t.,3000,2) //Local de impressao invalido!
			lLocImp := .F.
		EndIf
		If lLocImp
			
			cQuery := "SELECT ZCU_CODVOL" 
			cQuery +=  " FROM "+RetSqlName('ZCU')+" ZCU"
			cQuery += " WHERE ZCU_FILIAL = '"+xFilial('ZCU')+"'"
			cQuery +=   " AND ZCU_CARGA  = '"+ZCS->ZCS_CARGA+"'"
			cQuery +=   " AND ZCU_PEDIDO = '"+ZCS->ZCS_PEDIDO+"'"
			If ZCU->(FieldPos("ZCU_DATA")) > 0
				cQuery += " AND ZCU_DATA = '"+DTOS(ZCS->ZCS_DATA)+"'"
				cQuery += " AND ZCU_HORA = '"+ZCS->ZCS_HORA+"'"
			EndIf
			cQuery +=   " AND ZCU.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasZCU := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasZCU,.F.,.T.)
			
			While (cAliasZCU)->(!Eof())
				U_WMSR410A((cAliasZCU)->ZCU_CODVOL,.T.)
				(cAliasZCU)->(DbSkip())
			EndDo
			
			(cAliasZCU)->(DbCloseArea())
		EndIf
		MSCBCLOSEPRINTER()
	EndIf
ElseIf ZCS->ZCS_STATUS == '3' .And. nAcao == 2
	lFim := .T.
EndIf

RestArea(aAreaAnt)
Return lRet

//--------------------------------------------------------------------------------//
//---------------------Liberação dos Itens Embalados do Pedido--------------------//
//--------------------------------------------------------------------------------//
Static Function Wma390LibP(oView,oModel)
Local lRet      := .T.
Local cCarga    := oView:GetModel('A390ZCT'):GetValue('ZCT_CARGA')
Local cPedido   := oView:GetModel('A390ZCT'):GetValue('ZCT_PEDIDO')
Local cProduto  := oView:GetModel('A390ZCT'):GetValue('ZCT_CODPRO')
Local cLote     := oView:GetModel('A390ZCT'):GetValue('ZCT_LOTE')
Local cSubLote  := oView:GetModel('A390ZCT'):GetValue('ZCT_SUBLOT')
Local nQtdEmb   := oView:GetModel('A390ZCT'):GetValue('ZCT_QTEMBA')
Local nQtdLib   := oView:GetModel('A390ZCT'):GetValue('ZCT_QTLIBE')
Local cIDDCF    := oView:GetModel('A390ZCT'):GetValue('ZCT_IDDCF')
Local cMsg      := ''
Local cQuery    := ''
Local cAliasQry := ''

If oView:AFOLDERS[1][5]:NOPTION <> 1
	oView:AFOLDERS[1][5]:NOPTION := 1
	Aviso("Aviso","Selecione o Item do Pedido que deseja ser liberado",{'OK'}) //
	lRet := .F.
EndIf

If lRet
	If nQtdEmb == 0
		Aviso("Aviso","O Item selecionado não foi embalado!",{'OK'}) //
		lRet := .F.
	ElseIf nQtdEmb == nQtdLib
		Aviso("Aviso","O Produto: "+AllTrim(cProduto)+" já foi liberado de acordo com a quantidade embalada!",{'OK'}) //'#####'
		lRet := .F.
	Else
		nQtdEmb := nQtdEmb - nQtdLib
		cMsg := Chr( 13 ) + Chr( 13 )
		cMsg += "Produto: "    + cProduto + Chr( 13 )             //Produto: '#####'
		cMsg += "Quantidade: " + CValToChar(nQtdEmb) + Chr( 13 )  //Quantidade: '#####'
		cMsg += "Sequência: "  + cIDDCF                           //Sequência: '#####'

		If !MsgYesNo("Confirma a liberação parcial? "+cMsg,"Aviso") //
			lRet := .F.
		EndIf
	EndIf
EndIf

If lRet
	Begin Transaction
		cQuery := "SELECT ZCU_CODVOL, ZCV_CODPRO, ZCV_LOTE, ZCV_SUBLOT, ZCV_QUANT, ZCU_CARGA, ZCU_PEDIDO, DCF_SERIE, DCF_SERVIC, DCF_LOCAL, DCF_ENDER, DCF_ID"
		cQuery += " FROM "+RetSqlName('ZCU')+" ZCU, "+RetSqlName('ZCV')+" ZCV, "+RetSqlName('DCF')+" DCF"
		cQuery += "  WHERE ZCU_FILIAL     = '"+xFilial('ZCU')+"'"
		cQuery +=      " AND ZCV_FILIAL     = '"+xFilial('ZCV')+"'"
		cQuery +=      " AND DCF_FILIAL     = '"+xFilial('DCF')+"'"
		cQuery +=      " AND ZCU_CARGA      = '"+cCarga+"'"
		cQuery +=      " AND ZCU_PEDIDO     = '"+cPedido+"'"
		cQuery +=      " AND ZCV_CODPRO     = '"+cProduto+"'"
		cQuery +=      " AND ZCV_LOTE       = '"+cLote+"'"
		cQuery +=      " AND ZCV_SUBLOT     = '"+cSubLote+"'"
		cQuery +=      " AND ZCV_IDDCF      = '"+cIDDCF+"'"
		cQuery +=      " AND ZCU_CODVOL     = ZCV_CODVOL"
		cQuery +=      " AND ZCV_IDDCF      = DCF_ID"
		cQuery +=      " AND ZCV_STATUS    <> '1'"
		cQuery +=      " AND ZCU.D_E_L_E_T_ = ' '"
		cQuery +=      " AND ZCV.D_E_L_E_T_ = ' '"
		cQuery +=      " AND DCF.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

		lRet := WmsDivSC9((cAliasQry)->ZCU_CARGA,(cAliasQry)->ZCU_PEDIDO,(cAliasQry)->DCF_SERIE,(cAliasQry)->ZCV_CODPRO,(cAliasQry)->DCF_SERVIC,(cAliasQry)->ZCV_LOTE,(cAliasQry)->ZCV_SUBLOT,Nil,(cAliasQry)->ZCV_QUANT,,(cAliasQry)->DCF_LOCAL,(cAliasQry)->DCF_ENDER,(cAliasQry)->DCF_ID,.T.)

		While (cAliasQry)->(!Eof())
			If ZCV->(DbSeek(xFilial('ZCV')+(cAliasQry)->ZCU_CODVOL))
				While ZCV->(!Eof()) .And. ZCV->(ZCV_FILIAL+ZCV_CODVOL) == xFilial('ZCV')+(cAliasQry)->ZCU_CODVOL
					RecLock('ZCV',.F.)
					ZCV->ZCV_STATUS := '1' //Liberado
					ZCV->(MsUnlock())
					ZCV->(DbSkip())
				EndDo
			EndIf
			(cAliasQry)->(DbSkip())
		EndDo

		ZCT->(DbSetOrder(1)) //ZCT_FILIAL+ZCT_CARGA+ZCT_PEDIDO+ZCT_CODPRO+ZCT_LOTE+ZCT_SUBLOT+ZCT_IDDCF
		If ZCT->(DbSeek(xFilial('ZCT')+cCarga+cPedido+cProduto+cLote+cSubLote+cIDDCF))
			RecLock('ZCT',.F.)
			ZCT->ZCT_QTLIBE += nQtdEmb
			ZCT->(MsUnlock())
		EndIf

		If !lRet
			DisarmTransaction()
		EndIf
		(cAliasQry)->(DbCloseArea())
	End Transaction
	If lRet
		Aviso("Liberação Parcial","Volumes liberados com sucesso",{"OK"}) // // //OK
		oModel:DeActivate()
		oModel:Activate()
		oView:Refresh()
	EndIf
EndIf
Return

//---------------------------------------------------------------------------------------//
//---------------------Função que chama o Estorno dos Itens do Volume--------------------//
//-----------------quando o usuário está utilizando o sistema via Desktop----------------//
//---------------------------------------------------------------------------------------//
User Function WmA390Esto(nAcao,oView,oModel)
Local lRet      := .T.
Local aVols     := {}
Local cCarga    := oView:GetModel('A390ZCS'):GetValue('ZCS_CARGA')
Local cPedido   := oView:GetModel('A390ZCS'):GetValue('ZCS_PEDIDO')
Local cCodVol   := ''
Local cProduto  := ''
Local cLote     := ''
Local cSubLote  := ''
Local cDtHr     := ''

If ZCU->(FieldPos("ZCU_DATA")) > 0
	cDtHr := DtoS(oView:GetModel('A390ZCS'):GetValue('ZCS_DATA')) + oView:GetModel('A390ZCS'):GetValue('ZCS_HORA') 
EndIf

If nAcao == 1 //Estornar Volume
	If oView:AFOLDERS[1][5]:NOPTION <> 2
		oView:AFOLDERS[1][5]:NOPTION := 2
		Aviso("Aviso","Selecione o volume a ser estornado",{'OK'}) //
		lRet := .F.
	Else
		cCarga  := oView:GetModel('A390ZCU'):GetValue('ZCU_CARGA')
		cPedido := oView:GetModel('A390ZCU'):GetValue('ZCU_PEDIDO')
		cCodVol := oView:GetModel('A390ZCU'):GetValue('ZCU_CODVOL')
		lRet    := Iif(Aviso("Aviso","Deseja estornar os itens embalados no volume: " +AllTrim(cCodVol)+'?',{"Sim","Não"}) == 1,.T.,.F.) //'#####'?
	EndIf

ElseIf nAcao == 2 //Estornar Documento
	If oView:AFOLDERS[1][5]:NOPTION <> 2
		oView:AFOLDERS[1][5]:NOPTION := 2
	EndIf
	lRet := Iif(Aviso("Aviso","Deseja estornar todos os itens embalados de todos volumes do Pedido?",{"Sim","Não"}) == 1,.T.,.F.) //

ElseIf nAcao == 3 //Estornar Produto Volume
	If oView:AFOLDERS[1][5]:NOPTION <> 2
		oView:AFOLDERS[1][5]:NOPTION := 2
		Aviso("Aviso","Selecione o produto a ser estornado",{'OK'}) //Selecione o produto a ser estornado
		lRet := .F.
	Else
		cCarga   := oView:GetModel('A390ZCU'):GetValue('ZCU_CARGA')
		cPedido  := oView:GetModel('A390ZCU'):GetValue('ZCU_PEDIDO')
		cCodVol  := oView:GetModel('A390ZCU'):GetValue('ZCU_CODVOL')
		cProduto := oView:GetModel('A390ZCV'):GetValue('ZCV_CODPRO')
		cLote    := oView:GetModel('A390ZCV'):GetValue('ZCV_LOTE')
		cSubLote := oView:GetModel('A390ZCV'):GetValue('ZCV_SUBLOT')
		lRet     := Iif(Aviso("Aviso","Deseja Excluir Produto "+AllTrim(cProduto)+' '+" do Processo de Embalagem?",{"Sim","Não"}) == 1,.T.,.F.) 
	EndIf
EndIf
If lRet
	WmA390GrvE(nAcao,cCarga,cPedido,cCodVol,cProduto,cLote,cSubLote,aVols,cDtHr)

	If !Empty(aVols)
		If nAcao == 1
			Aviso("Estornar Embalagem","O Volume não foi estornado, pois possui item faturado!",{"OK"})
		ElseIf nAcao == 2
			TmsMsgErr(aVols,"Os Volumes abaixo não foram estornados, pois possuem item faturado!")
		ElseIf nAcao == 3
			Aviso("Estornar Embalagem","O Item do volume não foi estornado, pois já está faturado!",{"OK"})
		EndIf
	EndIf

	oModel:DeActivate()
	oModel:Activate()
	oView:Refresh()
EndIf

Return

//-------------------------------------------------------------------//
//---------------------Estorno de Itens do Volume--------------------//
//-------------------------------------------------------------------//
Static Function WmA390GrvE(nAcao,cCarga,cPedido,cCodVol,cProduto,cLote,cSubLote,aVols,cDtHr)
Local cQuery    := ''
Local cAliasQry := ''
Local nTotPrd   := 0
Local cStatus   := ''
Local cSeekZCU  := ''
Local cSeekZCV  := ''

Default aVols    := {}
Default cDtHr   := ''

//-- ----------nAcao-----------
//-- [1] - Estornar Volume
//-- [2] - Estornar Documento
//-- [3] - Estornar Produto Volume

cQuery := "SELECT ZCV.R_E_C_N_O_ RECNOZCV, SC9.R_E_C_N_O_ RECNOSC9"
cQuery += " FROM "+RetSqlName('ZCU')+" ZCU, "+RetSqlName('ZCV')+" ZCV, "+RetSqlName('SC9')+" SC9"
cQuery += "  WHERE ZCU_FILIAL      = '"+xFilial('ZCU')+"'"
cQuery +=      " AND ZCV_FILIAL = '"+xFilial('ZCV')+"'"
cQuery +=      " AND C9_FILIAL  = '"+xFilial('SC9')+"'"
cQuery +=      " AND ZCU_CARGA  = '"+cCarga+"'"
cQuery +=      " AND ZCU_PEDIDO = '"+cPedido+"'"
If ZCU->(FieldPos("ZCU_DATA")) > 0
	cQuery += " AND ZCU_DATA = '"+SubStr(cDtHr,1,8)+"'"
	cQuery += " AND ZCU_HORA = '"+SubStr(cDtHr,9,5)+"'"
EndIf
If nAcao == 1 .Or. nAcao = 3
	cQuery +=   " AND ZCU_CODVOL = '"+cCodVol+"'"
EndIf
If nAcao == 3
	cQuery +=   " AND ZCV_CODPRO = '"+cProduto+"'"
	cQuery +=   " AND ZCV_LOTE     = '"+cLote+"'"
	cQuery +=   " AND ZCV_SUBLOT = '"+cSubLote+"'"
EndIf
cQuery +=      " AND C9_CARGA   = '"+cCarga+"'"
cQuery +=      " AND C9_PEDIDO  = '"+cPedido+"'"
cQuery +=      " AND ZCU_CODVOL = ZCV_CODVOL"
cQuery +=      " AND ZCV_SEQUEN = C9_SEQUEN "
cQuery +=      " AND ZCV_IDDCF  = C9_IDDCF"
cQuery +=      " AND ZCU.D_E_L_E_T_ = ' '"
cQuery +=      " AND ZCV.D_E_L_E_T_ = ' '"
cQuery +=      " AND SC9.D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
cAliasQry := GetNextAlias()
DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

Begin Transaction

	ZCT->(DbSetOrder(1)) //ZCT_FILIAL+ZCT_CARGA+ZCT_PEDIDO+ZCT_CODPRO+ZCT_LOTE+ZCT_SUBLOT
	If ZCU->(FieldPos("ZCU_DATA")) > 0
		ZCU->(DbSetOrder(3)) //ZCU_FILIAL+ZCU_CARGA+ZCU_PEDIDO+DTOS(ZCU_DATA)+ZCU_HORA
		cSeekZCU := cCarga+cPedido+cDtHr
		ZCV->(DbSetOrder(3)) //ZCV_FILIAL+ZCV_CARGA+ZCV_PEDIDO+ZCV_CODVOL+DTOS(ZCV_DATA)+ZCV_HORA
		cSeekZCV := cCarga+cPedido+cCodVol+cDtHr
	Else
		ZCU->(DbSetOrder(1)) //ZCU_FILIAL+ZCU_CODVOL
		cSeekZCU := cCodVol
		ZCV->(DbSetOrder(1)) //ZCV_FILIAL+ZCV_CODVOL+...
		cSeekZCV := cCodVol
	EndIf	

	While (cAliasQry)->(!Eof())
		//Posiciona nos registros ZCV e SC9 correspondentes
		ZCV->(DbGoTo((cAliasQry)->(RECNOZCV)))
		SC9->(DbGoTo((cAliasQry)->(RECNOSC9)))

		//Verifica se possui nota fiscal para esse item
		If !Empty(SC9->C9_NFISCAL) .And. AScan(aVols,{|x|x[1]==ZCV->ZCV_CODVOL}) == 0
			AAdd(aVols,{ZCV->ZCV_CODVOL})
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(DbGoTop())
	While (cAliasQry)->(!Eof())
		 //Posiciona nos registros ZCV e SC9 correspondentes
		ZCV->(DbGoTo((cAliasQry)->(RECNOZCV)))
		SC9->(DbGoTo((cAliasQry)->(RECNOSC9)))

		//Não permite estornar os volumes que possuem item faturado
		If AScan(aVols,{|x|x[1]==ZCV->ZCV_CODVOL}) > 0
			(cAliasQry)->(DbSkip())
			Loop
		EndIf
		
		//Se o item já foi liberado precisa atualizar também a tabela de Pedidos Liberados (SC9) e Composição do Empenho (SDC)
		If ZCV->ZCV_STATUS == '1' //Liberado
			WmsDivSC9(SC9->C9_CARGA,SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_PRODUTO,SC9->C9_SERVIC,SC9->C9_LOTECTL,SC9->C9_NUMLOTE,SC9->C9_NUMSERI,ZCV->ZCV_QUANT,,SC9->C9_LOCAL,SC9->C9_ENDPAD,SC9->C9_IDDCF,.F.,,,SC9->(Recno()),.T.)
		EndIf

		nTotPrd += ZCV->ZCV_QUANT
		//Atualiza as quantidades e status dos Itens do Documento (ZCT)
		ZCT->(DbSeek(xFilial('ZCT')+cCarga+cPedido+ZCV->ZCV_CODPRO+ZCV->ZCV_LOTE+ZCV->ZCV_SUBLOT+ZCV->ZCV_IDDCF))
		RecLock('ZCT',.F.)
		ZCT->ZCT_QTEMBA -= ZCV->ZCV_QUANT
		ZCT->ZCT_QTLIBE := Iif(QtdComp(ZCT->ZCT_QTLIBE - ZCV->ZCV_QUANT) > QtdComp(0), (ZCT->ZCT_QTLIBE - ZCV->ZCV_QUANT), 0)
		ZCT->ZCT_STATUS := Iif(QtdComp(ZCT->ZCT_QTEMBA) <= QtdComp(0),'1','2')
		ZCT->(MsUnlock())

		//Deleta o item do volume
		cCodVol := ZCV->ZCV_CODVOL
		RecLock('ZCV',.F.)
		ZCV->(DbDelete())
		ZCV->(MsUnlock())

		//Se não existirem mais itens no volume, deleta o volume
		If ZCV->(!DbSeek(xFilial('ZCV')+cSeekZCV))
			If ZCU->(DbSeek(xFilial('ZCU')+cSeekZCU))
				RecLock('ZCU',.F.)
				ZCU->(DbDelete())
				ZCU->(MsUnlock())
			EndIf
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo

	If QtdComp(nTotPrd) > QtdComp(0)
	
		If ZCU->(FieldPos("ZCU_DATA")) > 0
			ZCU->(DbSetOrder(3)) //ZCU_FILIAL+ZCU_CARGA+ZCU_PEDIDO+ZCU_DATA+ZCU_HORA
			cSeekZCU := cCarga+cPedido+cDtHr
		Else
			ZCU->(DbSetOrder(2)) //ZCU_FILIAL+ZCU_CARGA+ZCU_PEDIDO+...
			cSeekZCU := cCarga+cPedido
		EndIf
		//Se não existirem mais volumes para o documento, seta status "Não Iniciado"
		If ZCU->(!DbSeek(xFilial('ZCU')+cSeekZCU))
			cStatus := '1' //-- Não Iniciado
		Else
			cStatus := '2' //-- Em andamento
		EndIf
	
		//Atualiza quantidade embalada e status para o documento
		ZCS->(DbSetOrder(1))
		If ZCS->(DbSeek(xFilial('ZCS')+cCarga+cPedido+If(ZCU->(FieldPos("ZCU_DATA")) > 0,cDtHr,'')))
			RecLock('ZCS',.F.)
			ZCS->ZCS_QTEMBA -= nTotPrd
			ZCS->ZCS_STATUS := cStatus
			ZCS->(MsUnlock())
		EndIf
	EndIf 
End Transaction

(cAliasQry)->(DbCloseArea())

Return

//-------------------------------------------------------------------//
//--------- Ajuste do Dicionário de Perguntas do Relatório ----------//
//-------------------------------------------------------------------//
Static Function AjustaSX1()
Local aHelpPor := {}
Local aHelpEng := {}
Local aHelpSpa := {}
Local aTamSX3  := {}
Local lAtuSX1  := .F.
Local cPerg    := PadR('WMR420',Len(SX1->X1_GRUPO))

SX1->(DbSetOrder(1))
If SX1->(MsSeek(cPerg+'01', .F.))
	If Upper(AllTrim(SX1->X1_PERGUNT)) <>'CARGA DE ?'
		lAtuSX1 := .T.
		Do While !SX1->(Eof()) .And. cPerg == SX1->X1_GRUPO
			RecLock('SX1', .F.)
			SX1->(DbDelete())
			MsUnlock()
			SX1->(DbSkip())
		EndDo
	EndIf
Else
	lAtuSX1 := .T.
EndIf

If lAtuSX1
	aTamSX3 := TamSX3("ZCS_CARGA")
	aHelpPor := {'Carga inicial'}
	aHelpEng := {'Initial cargo'}
	aHelpSpa := {'Carga inicial'}
	PutSX1('WMR420','01','Carga De ?','¿De Carga ?','From Cargo ?','mv_ch1','C',aTamSX3[1],aTamSX3[2],0,'G','','','','N','mv_par01','','','',Space(aTamSX3[1]),'','','','','','','','','','','','',aHelpPor,aHelpEng,aHelpSpa)

	aHelpPor := {'Carga final'}
	aHelpEng := {'Final cargo'}
	aHelpSpa := {'Carga final'}
	PutSX1('WMR420','02','Carga Ate ?','¿A Carga ?','To Cargo ?','mv_ch2','C',aTamSX3[1],aTamSX3[2],0,'G','','','','N','mv_par02','','','',Replicate('Z',aTamSX3[1]),'','','','','','','','','','','','',aHelpPor,aHelpEng,aHelpSpa)

	aTamSX3 := TamSX3("ZCS_PEDIDO")
	aHelpPor := {'Pedido inicial'}
	aHelpEng := {'Initial order'}
	aHelpSpa := {'Pedido inicial'}
	PutSX1('WMR420','03','Pedido De ?','¿De Pedido ?','From Order ?','mv_ch3','C',aTamSX3[1],aTamSX3[2],0,'G','','','','N','mv_par03','','','',Space(aTamSX3[1]),'','','','','','','','','','','','',aHelpPor,aHelpEng,aHelpSpa)

	aHelpPor := {'Pedido final'}
	aHelpEng := {'Final order'}
	aHelpSpa := {'Pedido final'}
	PutSX1('WMR420','04','Pedido Ate ?','¿A Pedido ?','To Order ?','mv_ch4','C',aTamSX3[1],aTamSX3[2],0,'G','','','','N','mv_par04','','','',Replicate('Z',aTamSX3[1]),'','','','','','','','','','','','',aHelpPor,aHelpEng,aHelpSpa)

	aHelpPor := {'Status do pedido na montagem de volumes'}
	aHelpEng := {'Order status in assembly volumes'}
	aHelpSpa := {'Estado del pedido en la montaje de volúmenes'}
	PutSX1('WMR420','05','Status ?','¿Estatus ?','Status ?','mv_ch5','N',1,0,1,'C','','','','N','mv_par05','Não Iniciado','No Iniciado','Not Started','','Em andamento','En proceso','In Progress','Finalizado','Finalizado','Concluded','Todos','Todos','All','','','',aHelpPor,aHelpEng,aHelpSpa)

	aHelpPor := {'Tipo de relatorio desejado'}
	aHelpEng := {'Type of report required'}
	aHelpSpa := {'Tipo de informe requerido'}
	PutSX1('WMR420','06','Relatorio ?','¿Informe ?','Report ?','mv_ch6','N',1,0,2,'C','','','','N','mv_par06','Analitico','Analitico','Detailed','','Sintetico','Sintetico','Summarized','','','','','','','','','',aHelpPor,aHelpEng,aHelpSpa)
EndIf

Return Nil

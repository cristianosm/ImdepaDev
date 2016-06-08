#Include 'totvs.ch'
#Include 'fivewin.ch'
#Include 'rwmake.ch'



#DEFINE ENTER ( chr(13) + chr(10) )
#DEFINE _TAB_ ( chr(9) )
#DEFINE CLR_AZUL  RGB(0,0,255)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMDF190   ºAutor  ³Jeferson            º Data ³  16/01/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para pesquisa de um item de produto atraves da teclaº±±
±±º          ³ F11                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Codigo do Produto                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Pode ser usada em qualque SXB                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*******************************************************************************
User Function IMDF190()
*******************************************************************************

//| Locais
	Local nPosN			:= 0
	Local nHeight11  	:= -11

	Local ReadVarIni 	:= __ReadVar

	Local lBold	   		:= .T.
	Local lUnderLine 	:= .T.

	Local cOld_F12		:= ""
	Local cOld_F11      := ""

//| Objetos
	SetPrvt("oDlg01,oBut2,oMens,oRef,oMar,oCod,oDes,oGrp,oGr1,oGr2,oGr3,oSeg,oFab,oVei,oMod,oGpa,oNov")
	Private oFont		:= TFont():New( "Courier New",,nheight11,,!lBold,,,,,!lUnderLine )
	Private oFontNegri	:= TFont():New( "Courier New",,nheight11,, lBold,,,,,!lUnderLine )
	Private cMsGs       :=' '

//| Caracteres
	SetPrvt("cTextoAux,cCodProd,cTitle,cMens,cRef,cMar,cCod,cDes,cGrp,cGr1,cGr2,cGr3,cSeg,cFab,cVei,cMod,cGpa,cNov,cI32,cI33,cI34,cI35,cI51,cI52,cI53,cFilEst")
	Store "" 			To cMens
	Store Space(06) 	To cGrp,cGr1,cGr2,cGr3
	Store Space(10)		To cI32,cI33,cI34,cI35,cI51,cI52,cI53
	Store Space(15)		To cCod
	Store Space(20)		To cRef,cMar,cFab,cNov
	Store Space(30)		To cMod,cSeg
	Store Space(40)		To cDes,cVei,cGpa

//| Numericas
	SetPrvt("nAcreCond,nAnt,nItemPro,nCount,nI15,nI16,nI17,nI18,nI19,nI20,nI21,nI22,nI23,nI24,nI25,nI26,nI27,nI28,nI29,nI30,nI31,nI32,nI33,nI34,nI35,nI36,nI37")
	SetPrvt("nI38,nI39,nI40,nI41,nI42,nI43,nI44,nI45,nI46,nI47,nI48,nI49,nI50,nI51,nI52,nI53,nI54,nI55,nI56,nItemPro,nCount,nValOrdem")

//| Arreys
	SetPrvt("aArmazena,aListPRO,aFiliais")
	Store {} 			To aArmazena,aListPRO

//|Logicas
	SetPrvt("lFirst,lRodaF11,lRodaF12,lCaptura,lSair")
	Store .T.			To lFirst,lRodaF12,lSair


//| Variaveis Publicas
	Public oListPRO
	Public lF190OrdEst 	:= .T.

//| Inicializacoes
	cFilEst 	:= U_cRetFils("Q")//| Retorna as filiais que operam com estoque em Char
	cTitle		:= OemToAnsi("Consulta Avançada de Produtos")
	cCodProd 	:= &(Readvar())
	cTextoAux 	:= 'PLA'	// Fixo o nome da planilha
	cOld_F12 	:= SetKey( VK_F12 )//| Salva as Variaveis
	cOld_F11 	:= SetKey( VK_F11 )//| Salva as Variaveis

	nValOrdem	:= 0
	nAnt 		:= N
	nItemPro	:= 1
	nAcreCond 	:= 1 + (Posicione("SE4",1,xFilial("SE4")+M->UA_CONDPG,"E4_ACRSFIN") / 100)//| % Acrescimo CondCao

	aFiliais 	:= U_cRetFils("A")//| Retorna as filiais que operam com estoque em Arrey
	lCaptura	:= .F.
	lRodaF11	:= lFocusTlv .AND. N == LEN(aCols) .AND. EMPTY(gdFieldGet("UB_PRODUTO",n)) .AND. EMPTY(ReadVar())

	IF !lRodaF11
	// Retorna o conteudo original - Inserido por  valdo Goncalves Cordeiro em 21/09/11
		SetKey( VK_F12, cOld_F12 )
		SetKey( VK_F11, cOld_F11 )

		Return(.T.)
	EndIf

//| Tela Principal
	While lSair
		MontaTela()
	EndDo

	U_LinhaAdd()

	__ReadVar := ReadVarIni

// Retorna o conteudo original
	SetKey( VK_F12, cOld_F12 )
	SetKey( VK_F11, cOld_F11 )

Return(.T.)
*******************************************************************************
Static Function MontaTela()
*******************************************************************************

	Local  _cDescFil     :=" "

	DEFINE MSDIALOG oDlg01 TITLE cTitle FROM 001,001 TO 507,985 STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) PIXEL OF oMainWnd


	SM0->(DbSeek("01" + cFilAnt))
	_cDescFil   := Alltrim(SM0->M0_FILIAL)

//oTBitmap := TBitmap():Create(oDlg01,30,146,260,184,,'xclose.png',.T.,            {||Alert("Clique em TBitmap1")},,.F.,.F.,,,.F.,,.T.,,.F.)

	oFolder := TFolder():New(1,1,{"Dados Cadastrais ","Aplicação "},{"oFl1","oFl2",},oDlg01,,,,.T.,.F.,490,095)

//| Dados para a pasta "Dados Cadastrais"
	@ 010,010 Say OemToAnsi("Referencia") 		Size 030,008 of oFolder:aDialogs[1] PIXEL
	@ 025,010 Say OemToAnsi("Marca")		    	Size 030,008 of oFolder:aDialogs[1] PIXEL
	@ 040,010 Say OemToAnsi("Codigo") 		    	Size 030,008 of oFolder:aDialogs[1] PIXEL
	@ 055,010 Say OemToAnsi("Descricao") 			Size 030,008 of oFolder:aDialogs[1] PIXEL

	@ 010,220 Say OemToAnsi("Grupo Produtos")  	Size 030,008 of oFolder:aDialogs[1] PIXEL
	@ 025,220 Say OemToAnsi("SubGrupo 1")     	Size 030,008 of oFolder:aDialogs[1] PIXEL
	@ 040,220 Say OemToAnsi("SubGrupo 2")     	Size 030,008 of oFolder:aDialogs[1] PIXEL
	@ 055,220 Say OemToAnsi("SubGrupo 3")     	Size 030,008 of oFolder:aDialogs[1] PIXEL

	@ 010,043 MSGet oRef VAR cRef Picture '@!'	Size 090,010 of oFolder:aDialogs[1] PIXEL valid _RefreshBarra()
	@ 025,043 MsGet oMar VAR cMar Picture '@!'	Size 090,010 of oFolder:aDialogs[1] PIXEL valid _RefreshBarra()
	@ 040,043 MsGet oCod VAR cCod Picture '@!' 	Size 040,010 of oFolder:aDialogs[1] PIXEL valid _RefreshBarra()
	@ 055,043 MsGet oDes VAR cDes Picture '@!'	Size 170,010 of oFolder:aDialogs[1] PIXEL valid _RefreshBarra()

	@ 010,273 MsGet oGrp VAR cGrp Picture PesqPict("SBM","BM_GRUPO") Size 050,010 of oFolder:aDialogs[1] PIXEL //F3 "SBM"
	@ 025,273 MsGet oGr1 VAR cGr1 Picture PesqPict("SZA","ZA_COD")	 Size 050,010 of oFolder:aDialogs[1] PIXEL //F3 "SZA"
	@ 040,273 MsGet oGr2 VAR cGr2 Picture PesqPict("SZB","ZB_COD")	 Size 050,010 of oFolder:aDialogs[1] PIXEL //F3 "SZB"
	@ 055,273 MsGet oGr3 VAR cGr3 Picture PesqPict("SZC","ZC_COD")	 Size 050,010 of oFolder:aDialogs[1] PIXEL //F3 "SZC"


//| Dados para a pasta "Aplicacao"
	@ 010,010 Say OemToAnsi("Segmento") 			Size 030,008 of oFolder:aDialogs[2] PIXEL
	@ 025,010 Say OemToAnsi("Fabricante")   		Size 030,008 of oFolder:aDialogs[2] PIXEL
	@ 040,010 Say OemToAnsi("Veic./Equip.")	  	Size 030,008 of oFolder:aDialogs[2] PIXEL
	@ 055,010 Say OemToAnsi("Tipo/Modelo")  		Size 030,008 of oFolder:aDialogs[2] PIXEL

	@ 010,170 Say OemToAnsi("Grp Princ. Aplicacao")    	Size 040,008 of oFolder:aDialogs[2] PIXEL
	@ 025,170 Say OemToAnsi("No.Original Veic/Equip") 	Size 030,008 of oFolder:aDialogs[2] PIXEL

	@ 010,043 MsGet cSeg Picture '@!'			Size 120,010 of oFolder:aDialogs[2] PIXEL  valid _RefreshBarra()
	@ 025,043 MsGet cFab Picture '@!'       	Size 090,010 of oFolder:aDialogs[2] PIXEL  valid _RefreshBarra()
	@ 040,043 MsGet cVei Picture '@!'			Size 170,010 of oFolder:aDialogs[2] PIXEL  valid _RefreshBarra()
	@ 055,043 MsGet cMod Picture '@!'			Size 120,010 of oFolder:aDialogs[2] PIXEL  valid _RefreshBarra()

	@ 010,223 MsGet cGpa Picture '@!'			Size 120,010 of oFolder:aDialogs[2] PIXEL  valid _RefreshBarra()
	@ 025,223 MsGet cNov Picture '@!'       	Size 090,010 of oFolder:aDialogs[2] PIXEL  valid _RefreshBarra()

//| Desenha o Cabecalho das Filiais
	nXLinha  := 95
	nXColuna := 356

	nPosN := aScan(aFiliais,{|x| x[1] == cFilAnt}) //| Coloca a Marca na Filial Local
	IF nPosN > 0
		@ nXLinha,004  SAY Space(84)+' '+' '+' '+ ' '+Space((nPosN-1)*2)+"¤" PIXEL FONT oFontNegri COLOR CLR_AZUL
	ENDIF


	c1Cabecalho := c2Cabecalho := c3Cabecalho := ""
	For X := 1 To Len(aFiliais)
		c1Cabecalho += Substr(aFiliais[x][2],01,1)+' '
		c2Cabecalho += Substr(aFiliais[x][2],02,1)+' '
		c3Cabecalho += Substr(aFiliais[x][2],03,1)+' '
	Next


	nXLinha += 5
	@ nXLinha,004  SAY Space(84)+' '+' '+' '+ ' ' + c1Cabecalho +'P' PIXEL FONT oFONT

	nXLinha += 5
	@ nXLinha,004  SAY Space(84)+' '+' '+' '+ ' ' + c2Cabecalho +'L' PIXEL FONT oFONT

	@ nXLinha,004  SAY " "+PadR("ESTOQUE",09)+"  " PIXEL FONT oFONT
	nXLinha += 5

	@ nXLinha,004  SAY " "+PadR("DISP.",09)+"  "+PadR("REFERENCIA",20)+"  "+PadR("MARCA",20)+"  "+PadR("R$ PRECO",12)+"  "+PadR("CODIGO",14)+'E'+' '+'S'+ ' ' + c3Cabecalho +'A' PIXEL FONT oFONT
	nXLinha += 102

	TBtnBmp2():New(nXLinha,542,030,030,'watch_mdi.png',,,,{|| ToolTipEst(@oListPRO,oListPRO:nAt,@aListPRO) },oDlg01,"Estoque das outras Filiais",{||},,.T. )

//| Fim  Desenho

	@ 120,004  LISTBOX oListPRO VAR nItemPro SIZE 450,075 PIXEL ITEMS aListPro FONT oFONT ON DBLCLICK(U_F190Qtd1(@oListPRO,oListPRO:nAt,@aListPRO))


	oBtn_localiza := TButton():New(118,453,"",oDlg01,{|| fLocaliza1(),oListPRO:cToolTip:='' },39,18,,,.F.,.T.,.F.,'Localizar',.F.,,,.F. )

	oBtn_localiza:SetCss("QPushButton{ background-image: url(rpo:localiza_mdi.png);"+" background-repeat: none; margin: 2px }")

	oBtn_avancado := TButton():New(134,453,"",oDlg01,{|| (IniTela(), oDlg01:End()) },39,18,,,.F.,.T.,.F.,'Avançado',.F.,,,.F. )

	oBtn_avancado:SetCss("QPushButton{ background-image: url(rpo:sduseek.png);"+" background-repeat: none; margin: 2px }")

	oBtn_sair     := TButton():New(150,453,"",oDlg01,{|| (lSair := .F.,oDlg01:End()) },39,18,,,.F.,.T.,.F.,'Sair',.F.,,,.F. )

	oBtn_sair:SetCss("QPushButton{ background-image: url(rpo:xclose.png);"+" background-repeat: none; margin: 2px }")

	oTMsgBar 		:= TMsgBar():New(oDlg01, ' ', .F.,.F.,.F.,.F., RGB(116,116,116),,,.F.)
	oTMsgItem1 	:= TMsgItem():New( oTMsgBar,'F11 Consulta Avançada', 204,,,, .T., {||})
	oTMsgItem2 	:= TMsgItem():New( oTMsgBar,_cDescFil , 040,,,, .T., {|| } )

	If !Empty(cCodProd)
		cCod			:= cCodProd
		fLocaliza1()
		oListPRO:SetFocus()
		oListPRO:nAt 	:= 1
	Endif

	ACTIVATE MSDIALOG oDlg01 CENTERED ON INIT oRef:SetFocus()

Return(.T.)
*******************************************************************************
Static function _RefreshBarra()
*******************************************************************************

	oTMsgBar:SetMsg(" ")
	oTMsgBar:Refresh()


Return
*******************************************************************************
Static function ToolTipEst(oArray,nIt,aArray)
*******************************************************************************
	Local cMsg        :=' '
	Local cSql        :=' '
	Local _cReferProd :=' '
	Local cProduto    :=' '
	Local nTotSldAtu  :=0
	Local nTotSldTran :=0
	Local cMsg        := ' '

	oTMsgBar:SetMsg("Aguarde...")
	oTMsgBar:Refresh()

	If Empty(aListPro)
		oListPRO:cToolTip:=''
		oTMsgBar:SetMsg("Pronto !")
		oTMsgBar:Refresh()

		Return
	Endif

	cProduto:=Alltrim(SubStr(aArray[nIt],70,13))

	SB1->( dbSeek( xFilial( 'SB1' ) + cProduto, .f. ) )

	cMsg:=PADL(Alltrim(SB1->B1_COD)+'- '+Alltrim(SB1->B1_DESC),30)
	cMsg+=ENTER

	cSql:=" SELECT SB2.B2_FILIAL, SUM (SB2.B2_QATU - SB2.B2_RESERVA - SB2.B2_QACLASS- SB2.B2_QPEDVEN) SALDO,B2_QTRANS SALDO_TRANS"
	cSql+=" FROM "+RetSqlName("SB2")+" SB2"
	cSql+=" WHERE SB2.B2_FILIAL IN ('02','04','05','06','07','09','10','12','13')"
	cSql+=" AND SB2.B2_COD ='"+cProduto+"'"
	cSql+=" AND SB2.B2_LOCAL = '01' "
	cSql+=" AND SB2.D_E_L_E_T_ = ' '"
	cSql+=" GROUP BY B2_FILIAL,B2_QTRANS "
	cSql+=" ORDER BY SALDO DESC"

	U_ExecMySql(cSql,"cSQL","Q",.F.)

	DbSelectArea('cSQL')

	cMsg += " " + PADR( "Filial" , 15 ) + _TAB_ + _TAB_ + PADL( "Saldo Disp." , 15 ) + PADL( "  Saldo Transferência" , 15 ) + ENTER

	While cSQL->( !Eof() )

		SM0->(DbSeek("01" + cSQL->B2_FILIAL))

		If cFilAnt==cSQL->B2_FILIAL
			cSQL->( dbSkip() )
			Loop
		Endif

		cDescFil 	:= Alltrim(SM0->M0_FILIAL)
		cSaldo		:= Alltrim(Str(cSQL->SALDO))

		If Len(cDescFil) > 11
			cMsg += " " + PADR( cDescFil , 15 ) + _TAB_ + PADL( cValToChar(cSQL->SALDO) , 15 ) + PADL( cValToChar(cSQL->SALDO_TRANS) , 15 ) + ENTER
		Else
			cMsg += " " + PADR( cDescFil , 15 ) + _TAB_ + _TAB_ + PADL( cValToChar(cSQL->SALDO) , 15 ) + PADL( cValToChar(cSQL->SALDO_TRANS) , 15 ) + ENTER
		Endif

		nTotSldAtu  += cSQL->SALDO
		nTotSldTran += cSQL->SALDO_TRANS
		cSQL->( dbSkip() )
	End

	cSQL->( dbCloseArea() )


	cMsg+='---------------------------------------------------------------------------------- '+ENTER
	cMsg+= SPACE(54)+Str(nTotSldAtu)                      +Str(nTotSldTran)
	cMsg+=ENTER
	cMsg+='---------------------------------------------------------------------------------- '+ENTER

	oListPRO:cToolTip   := cMsg

	oTMsgBar:SetMsg("Pronto !")
	oTMsgBar:Refresh()


Return
*******************************************************************************
User Function F190Qtd1(oArray,nIt,aArray,cEQSIORI)//Seleciona a quantidade do produto no acols
*******************************************************************************
	Local oDlg02
	Local nPos
	Local cEQSIORI
	Local cTitle        := 'Quantidade'
	Local nQtdAux	    := 0
	Local aArea         := GetArea()
	Local aAreaSB1      := SB1->( GetArea() )

	Default cEQSIORI := Space(TamSX3("UB_PRODUTO")[1])

//Item já foi selecionado e retirado da Lista
	If Len(SubStr(aArray[nIt],70,13))= 0 .OR. !lRodaF12
		Return
	Endif


	lRodaF11 := .F.  // Desabilita abertura do F11
	lRodaF12 := .F.  // Desabilita abertura do F12


	U_LinhaAdd()


	M->UB_PRODUTO := Alltrim(SubStr(aArray[nIt],70,13))
	M->UB_QUANT  	:= Val(SubStr(aArray[nIt],1,9))
	M->UB_VRCACRE	:= Val(SubStr(aArray[nIt],56,12))
	M->UB_EQSIORI	:= cEQSIORI

//|Precos de Campanha
	U_MsgCamp(M->UB_PRODUTO,.F.,.T.,.T.,.F.,nAcreCond)


	nPos := Ascan( aPrecosCamp, { |x| x[1] == M->UB_PRODUTO } )
	If nPos > 0
		aCols[n,GDFieldPos('UB_VRCCAMP')] := aPrecosCamp[nPos,2]
	Endif

	DEFINE MSDIALOG oDlg02 TITLE cTitle FROM 001,001 TO 100,280 PIXEL

	nQtdAux	:=	0	//Val(Substr(aArray[nIt],1,9)) - Sugere 1 peça como valor Defaut para o Orçamento/Pedido


	@ 010,010 Say OemToAnsi("Quantidade:") 		  	Size 030,008 of oDlg02 PIXEL
	@ 010,043 MsGet nQtdAux  Picture '999999.99'  	Size 050,010 of oDlg02 PIXEL VALID Len(SubStr(aArray[nIt],70,13))<> 0 .AND. IF(U_F190VALQTD(nIt,aArray,@nQtdAux,@oDlg02),oDlg02:End(),.F.)
	@ 100,050 Button ''	Size 001,001 of oDlg02 PIXEL Action oDlg01:End()

	ACTIVATE MSDIALOG oDlg02 CENTERED

	If  nQtdAux>0
		aArray[nIt] :=Substr(aArray[nIt],1,7)+' ¤'+Substr(aArray[nIt],10,200) // faz isso na validação
	Endif

	oArray:SetArray(aArray) //SetArray(aListPRO)
	oArray:Refresh()
	oArray:SetFocus()
	oArray:nAt:=nIt
	oGetTlv:Refresh()

	lRodaF11 := .T.
	lRodaF12 := .T.


	RestArea( aAreaSB1 )
	RestArea( aArea    )

Return(aArray)
*******************************************************************************
Static Function fLocaliza1()//Localiza  atraves de Query o produto pelos dados selecionados
*******************************************************************************
	Local cQuery
	Local lEstoque 	   		:= .F.
	Local lEquivalente 		:= .F.
	Local lSimilar	   		:= .F.
	Local cVarTeste			:= ''
	Local cReferDigitado 	:= cRef
	Local cHoraInicio   	:= Time()
	Local cHoraFim			:= ''
	Local cMsgObs         	:= SubStr(Alltrim(SuperGetMV( "MV_MSGOBS",, "" )),1,7)
	Local cMsgPrint       	:= ' '
	Local cPrevTes        	:= ' ' //TES automática prevista para o produto em questão(ver FPARTES())
	Local nAcreMva        	:= 0  //Acréscimo do MVA
	Local lTemAcreMva     	:= .F. //Variável para definir se a filial possuiu ou não o Acréscimo MVA
	Local nDesAcreFil     	:= 0  //Desconto/Acréscimo por filial conforme tabela ZA7 (ZA7_PROMES)

	oTMsgBar:SetMsg("Aguarde...")
	oTMsgBar:Refresh()

	cVarTeste 	:= cRef+cMar+cCod+cDes+cGrp+cGr1+cGr2+cGr3+cSeg+cFab+cVei+cMod+cGpa+cNov

	If 	Empty(Alltrim(cVarTeste))

		cMens := ''
		oDlg01:Refresh()
		oListPRO:SetArray(aListPRO)
		oListPRO:Refresh()
		oListPRO:SetFocus()
		oListPRO:nAt := 1
		oTMsgBar:SetMsg("Pronto !")
		oTMsgBar:Refresh()
		Return()
	Endif

	TrataVar()//| Tratamento das variaveis antes de utilizalaz na Query

//| Query Busca Produtos
	cQuery :=  BQueryimdf190()
	oTMsgBar:SetMsg("Executando Consulta dos Estoques...")
	oTMsgBar:Refresh()

	U_ExecMySql(cQuery,"cQuery","Q",.F.)

// ReInicializa as variaveis em razao do Alltrim aplicado anteriormente
	Store Space(06) 	To cGrp,cGr1,cGr2,cGr3
	Store Space(15)	To cCod
	Store Space(20)	To cRef,cMar,cFab,cNov
	Store Space(30)	To cMod,cSeg
	Store Space(40)	To cDes,cVei,cGpa
	Store 0 			To nI15,nI16,nI17,nI18,nI19,nI20,nI21,nI22,nI23,nI24,nI25,nI26,nI27,nI28,nI29,nI30,nI31,nI36,nI37,nI38,nI39,nI40,nI41,nI42,nI43,nI44,nI45,nI46,nI47,nI48,nI49,nI50,nI54,nI55,nI56
	Store 0 			To nPrecoPro,nCount
	Store Space(10)	To cI32,cI33,cI34,cI35,cI51,cI52,cI53

//Verifica se a filial atual possui o Acréscimo MVA
	If SX5->(DbSeek(xFilial("SX5") + "77" +cFilant,.F.))
		lTemAcreMva:=.T.
	Endif

	aListPRO 		:= {}

//| Abri e Ordena Tabelas
	DbSelectArea('SB2');DbSetOrder(1)
	DbSelectarea("DA1");dbSetOrder(1)

	DbSelectArea('cQuery');DbGoTop()

	While !Eof()
		lEstoque 		:= .F.
		lEquivalente 	:= .F.
		lSimilar	 	:= .F.
		nValOrdem	 	:= 0

	// Tratamento para identificar as filiais que possuem estoque
		cEstoqueAux := '|'

		cQuery := "SELECT B2_FILIAL, CASE WHEN (B2_QATU - B2_RESERVA - B2_QACLASS- B2_QPEDVEN) > 0 THEN 'X|' ELSE ' |' END TXT FROM SB2010 "
		cQuery += "WHERE B2_FILIAL IN ("+cFilEst+") AND B2_COD = '"+cQuery->B1_COD+"' AND   B2_LOCAL = '01' AND   D_E_L_E_T_ = ' ' ORDER BY B2_FILIAL "

		U_ExecMySql(cQuery, "VEST", "Q" ,lCaptura)

		nPos := 2 //| Inicializa
		DbSelectArea("VEST");DbGotop()
		While Len(cFilEst) > nPos //| Roda ate passar por todas as filial contina na variavel "cFilEst" - Filiais que possuem Estoque.

			If Substr(cFilEst,nPos,2) ==  VEST->B2_FILIAL .And. !EoF()
				cEstoqueAux += VEST->TXT
				lEstoque    := Iif( AT("X",VEST->TXT) > 0 , .T. , .F.)
				nValOrdem   := IIF(VEST->B2_FILIAL == cFilAnt, nValOrdem+10^2,nValOrdem + 10^1)

				DbSkip()

			Else //| Se a Query nao retornar alguma filial que controla estoque aqui ela sera inserida.
				cEstoqueAux += " |"
				lEstoque    := .F.
				nValOrdem   := IIF(VEST->B2_FILIAL == cFilAnt, nValOrdem+10^2,nValOrdem + 10^1)

			EndIf

			nPos += 5
		EndDo
		DbSelectArea("VEST");DbCloseArea()

	//| Produtos com Equivalente / Similar
		cEqSim := '|'

		IF cQuery->B1_EQUIVAL == 'S'
			cEqSim 			+=  'X|'
			lEquivalente 	:= .T.
			nValOrdem 		+= 10^0
		ELSE
			cEqSim 			+=  ' |'
		ENDIF

		IF cQuery->B1_SIMILAR  == 'S'
			cEqSim 			+=  'X'
			lSimilar 		:= .T.
			nValOrdem 		+= 10^0
		ELSE
			cEqSim 			+=  ' '
		ENDIF

		dDataCorte := SuperGetMV( "MV_FILPLAN",, "20100801" )
		If ValType( dDataCorte ) == "C"
			dDataCorte := StoD( dDataCorte )
		EndIf

		cQuery := " SELECT ZE_QTDTRAN, ZE_QTDRES, ZE_EXCED "
		cQuery += " FROM "+RetSQLName("SZE")+" SZE "
		cQuery += " WHERE     ZE_FILIAL = '"+xFilial('SZE')+"'"
		cQuery += "       AND ZE_PRODUTO = '" +cQuery->B1_COD+ "'"  	// Jorge Oliveira - 03/11/10 - Incluida data de corte
		cQuery += "       AND ZE_DATA >= '"+DtoS( dDataCorte )+"' "
		cQuery += "       AND ( ZE_CODCLI = '      ' OR ( ZE_CODCLI = '"+M->UA_CLIENTE+"' AND ZE_LOJA = '"+M->UA_LOJA+"' ) )"
		cQuery += "       AND ZE_FLAGPT = ' ' "
		cQuery += "       AND D_E_L_E_T_ = ' ' "

		U_ExecMySql(cQuery,"cQueryPla","Q",lCaptura)

		If ( ( CQUERYPLA->ZE_QTDTRAN - CQUERYPLA->ZE_QTDRES ) > 0 .Or. CQUERYPLA->ZE_EXCED > 0 )
			cTemPlan	:= 'X|'
			nValOrdem 	+= 10^1
		Else
			cTemPlan  	:=' |'
		Endif


	//³Usado para Desovar Produtos.
	//³Ordena determinados produtos para aparecerem primeiro na tela do F11
	//³conforme solicitação da Diretoria
		IF Alltrim(cQuery->B1_COD) $ GETMV("MV_DESOVA",," ")
			nValOrdem += 10^3
		ENDIF

		DbSelectArea('cQueryPla');DbCloseArea()

   // Se tiver o Acréscimo MVA , checa se a TES automatica prevista é a 720
		If lTemAcreMva
	//Posiciona no produto resultado da query do Estoque
			SB1->( dbSeek( xFilial( 'SB1' ) + cQuery->B1_COD, .f. ) )
   //Verifica a Tes automatica prevista para o produto em questão
			cPrevTes   :=SB1->(U_FPARTES("S","N"))

   //O acréscimo MVA é somente para a TES 720 conforme Definido pelo Fiscal
			If cPrevTes=="720"
				nAcreMva   :=SB1->(U_IMDG240D(.F.,cPrevTes))
			Endif
		Endif

		nDesAcreFil :=SB1->(U_IMDG240E(.F.,cQuery->B1_COD))

		DbSelectarea("DA1")
		If !DbSeek(xFilial("DA1")+M->UA_TABELA+cQuery->B1_COD) .Or. DA1_PRCVEN = 0
			nPrecoPro:=0
		Else
			nPrecoPro := xMoeda(DA1_PRCVEN,DA1_MOEDA,M->UA_MOEDA,,)

	    //Acréscimo MVA
			If nAcreMva > 0
				nPrecoPro :=nPrecoPro*nAcreMva
			Endif

	 	//Desconto/Acréscimo da filial
			If nDesAcreFil<>0
				nPrecoPro := A410Arred(nPrecoPro +((nPrecoPro*nDesAcreFil)/100))
			Endif

		Endif

	// atualiza campo no ListBox
		nPrecoPro := A410Arred(nPrecoPro*nAcreCond,"UB_VRUNIT")

	//Projeto Batalha
		If  cQuery->B1_BATALHA='1'
			nSaldoBatalha:=Alltrim(Str(cQuery->CASA+cQuery->QTDEST))
			cMsgPrint='('+nSaldoBatalha+')' +Alltrim(cQuery->B1_OBSTPES)
		Else
			cMsgPrint=' '
		Endif

	//| Mostra somente itens que possuam estoque em alguma das filiais ou tenha equivalentes , mas somente os que tendo equivalente ou similar, tenham estoque
	//| Solicitatdo pelo otoni para não mostras somente os bloqueados no cad prod

		IF lF190OrdEst //| Ordena p/ Estoques
		//edi AADD(aListPRO,Space(09) + " |" + PADR(cQuery->B1_REFER,20)+" |" + PADR( cQuery->B1_MARCA, 20 ) + " |" + Str(nPrecoPro,12,4) + " | " + Substr(cQuery->B1_COD,1,13)  + cEqSim + cEstoqueAux + cTemPlan +cMsgPrint)
			AADD(aListPRO,PADR(cQuery->QTDEST,9,' ') +" |" + PADR(cQuery->B1_REFER,20)+" |" + PADR( cQuery->B1_MARCA, 20 ) + " |" + Str(nPrecoPro,12,4) + " | " + Substr(cQuery->B1_COD,1,13)  + cEqSim + cEstoqueAux + cTemPlan +cMsgPrint)

		Else//| Ordena p/ Pesos
			AADD(aListPRO,{Space(09) + " |" + PADR(cQuery->B1_REFER,20)+" |" + PADR( cQuery->B1_MARCA, 20 ) + " |" + Str(nPrecoPro,12,4) + " | " + Substr(cQuery->B1_COD,1,13)  + cEqSim + cEstoqueAux + cTemPlan, nValOrdem } )

		Endif

		cProduto := cQuery->B1_COD
		nCount++

		DbSelectArea('cQuery')
		DbSkip()

	EndDo

	IF !lF190OrdEst

	//|Ordena o array AlistPRO por ordem de nValOrdem
		aSort(aListPRO,,,{|a,b| a[2]+a[1] > b[2]+b[1] })  // nValOrdem + string  --> usar esta linha somente se tiver usando a função Queryimdf190()
		aListClone  := {}
		aListClone 	:= aClone(aListPRO)
		aListPRO 	:= {}

		For I:=1 To Len(aListClone)
			AADD(aListPRO,aListClone[i][1])
		Next i

	Endif

	If nCount > 0
		cMens := alltrim(Str(nCount)) +" Registros não mostrados por não possuirem estoque, nem produto Equivalente nem Similar"
	Else
		cMens := ""
	Endif

	oDlg01:Refresh()
	oListPRO:SetArray(aListPRO)
	oListPRO:Refresh()
	oListPRO:SetFocus()
	oListPRO:nAt := 1

	oTMsgBar:SetMsg("Pronto !")
	oTMsgBar:Refresh()


	DbSelectArea("cQuery");DbCloseArea()

	IF Len(aListPRO) <> 0
		SetKey( VK_F11, {|| U_Pergunta() } )
		Set key VK_F12 to
		SetKey( VK_F12, {|| U_F190Qtd1(@oListPRO,oListPRO:nAt,@aListPRO) } )
	EndIf


Return()
*******************************************************************************
Static Function TrataVar()//| Tratamento das variaveis antes de utilizalaz na Query
*******************************************************************************
	cRef := Alltrim(cRef)+Space(01)
	cMar := Alltrim(cMar)
	cCod := Alltrim(cCod)
	cDes := Alltrim(cDes)
	cGrp := Alltrim(cGrp)
	cGr1 := Alltrim(cGr1)
	cGr2 := Alltrim(cGr2)
	cGr3 := Alltrim(cGr3)

	cSeg := Alltrim( cSeg )
	cFab := Alltrim( cFab )
	cVei := Alltrim( cVei )
	cMod := Alltrim( cMod )
	cGpa := Alltrim( cGpa )
	cNov := Alltrim( CNov )

	If !Empty( Alltrim( cRef ) ) .Or. Len( Alltrim( cRef ) ) > 2

		cRef := Alltrim( cRef )
		If Substr( cRef , 1, 1 ) == "%"
			cRef := Substr( cRef , 2 , len( cRef ) - 1 )
		Endif

		If Substr( cRef, Len( cRef ), 1 ) == "%"
			cRef := Substr( cRef, 1, len( cRef ) - 1 )
		Endif
		cRef := StrTran(cRef,' ','_') //| Substitui o espaco ' ' pelo caracter Coringa
	Else
		cRef := ''
	Endif

	If !Empty(Alltrim(cDes)) .Or. Len(Alltrim(cDes)) > 2

		cDes := Alltrim(cDes)
		If Substr(cDes,1,1) == "%"
			cDes := Substr(cDes,2,len(cDes)-1)
		Endif

		If Substr(cDes,Len(cDes),1) == "%"
			cDes := Substr(cDes,1,len(cDes)-1)
		Endif
		cDes := StrTran(cDes,' ','_') //| Substitui o espaco ' ' pelo caracter Coringa

	Else
		cDes := ''
	Endif

Return()
*******************************************************************************
Static Function IniTela()//Funcao Auxiliar para preencher para poder habilitar os restantes das folders.....
*******************************************************************************

	Local oDlgAv

	DEFINE MSDIALOG oDlgAv TITLE cTitle FROM 001,001 TO 390,985 PIXEL OF oMainWnd

	oFolder := TFolder():New(1,1,{"Dados Cadastrais","Aplicação","Dimensionamento1","Dimensionamento2","Dimensionamento3","Dimensionamento4","Dimensionamento5","Dimensionamento6","Figuras Ex."},{"oFl1","oFl2","oFl3","oFl4","oFl5","oFl6","oFl7","oFl8","oFl9"},oDlgAv,,,,.T.,.F.,490,095)

//Dados para a pasta "Dados Cadastrais"
	@ 010,010 Say OemToAnsi("Referencia") 		Size 030,008 of oFolder:aDialogs[1] PIXEL
	@ 025,010 Say OemToAnsi("Marca")		    Size 030,008 of oFolder:aDialogs[1] PIXEL
	@ 040,010 Say OemToAnsi("Codigo") 		    Size 030,008 of oFolder:aDialogs[1] PIXEL
	@ 055,010 Say OemToAnsi("Descricao") 		Size 030,008 of oFolder:aDialogs[1] PIXEL

	@ 010,220 Say OemToAnsi("Grupo Produtos")  	Size 030,008 of oFolder:aDialogs[1] PIXEL
	@ 025,220 Say OemToAnsi("SubGrupo 1")     	Size 030,008 of oFolder:aDialogs[1] PIXEL
	@ 040,220 Say OemToAnsi("SubGrupo 2")     	Size 030,008 of oFolder:aDialogs[1] PIXEL
	@ 055,220 Say OemToAnsi("SubGrupo 3")     	Size 030,008 of oFolder:aDialogs[1] PIXEL

	@ 010,043 MsGet oRef VAR cRef Picture '@!'	Size 090,010 of oFolder:aDialogs[1] PIXEL
	@ 025,043 MsGet oMar VAR cMar Picture '@!'	Size 090,010 of oFolder:aDialogs[1] PIXEL
	@ 040,043 MsGet oCod VAR cCod Picture '@!'  Size 040,010 of oFolder:aDialogs[1] PIXEL
	@ 055,043 MsGet oDes VAR cDes Picture '@!'	Size 170,010 of oFolder:aDialogs[1] PIXEL

	@ 010,273 MsGet oGrp VAR cGrp Picture '@!' 	Size 050,010 of oFolder:aDialogs[1] PIXEL //F3 "SBM"
	@ 025,273 MsGet oGr1 VAR cGr1 Picture '@!' 	Size 050,010 of oFolder:aDialogs[1] PIXEL //F3 "SZA"
	@ 040,273 MsGet oGr2 VAR cGr2 Picture '@!' 	Size 050,010 of oFolder:aDialogs[1] PIXEL //F3 "SZB"
	@ 055,273 MsGet oGr3 VAR cGr3 Picture '@!' 	Size 050,010 of oFolder:aDialogs[1] PIXEL //F3 "SZC"

//Dados para a pasta "Aplicação"
	@ 010,010 Say OemToAnsi("Segmento") 		Size 030,008 of oFolder:aDialogs[2] PIXEL
	@ 025,010 Say OemToAnsi("Fabricante")   	Size 030,008 of oFolder:aDialogs[2] PIXEL
	@ 040,010 Say OemToAnsi("Veic./Equip.")	    Size 030,008 of oFolder:aDialogs[2] PIXEL
	@ 055,010 Say OemToAnsi("Tipo/Modelo")  	Size 030,008 of oFolder:aDialogs[2] PIXEL

	@ 010,170 Say OemToAnsi("Grp Princ. Aplicacao")    	Size 040,008 of oFolder:aDialogs[2] PIXEL
	@ 025,170 Say OemToAnsi("No.Original Veic/Equip") 		Size 030,008 of oFolder:aDialogs[2] PIXEL

	@ 010,043 MsGet oSeg  VAR cSeg Picture '@!'	Size 120,010 of oFolder:aDialogs[2] PIXEL
	@ 025,043 MsGet oFab  VAR cFab Picture '@!' Size 090,010 of oFolder:aDialogs[2] PIXEL
	@ 040,043 MsGet oVei  VAR cVei Picture '@!' Size 170,010 of oFolder:aDialogs[2] PIXEL
	@ 055,043 MsGet ocMod VAR cMod Picture '@!'	Size 120,010 of oFolder:aDialogs[2] PIXEL

	@ 010,223 MsGet oGpa VAR cGpa Picture '@!'	Size 120,010 of oFolder:aDialogs[2] PIXEL
	@ 025,223 MsGet oNov VAR cNov Picture '@!' 	Size 090,010 of oFolder:aDialogs[2] PIXEL

	@ 010,010 Say OemToAnsi("Unid. Medida (mm/Pol")	Size 030,008 of oFolder:aDialogs[3] PIXEL
	@ 025,010 Say OemToAnsi("d (mm)")			  		Size 030,008 of oFolder:aDialogs[3] PIXEL
	@ 040,010 Say OemToAnsi("D (mm)")			  		Size 030,008 of oFolder:aDialogs[3] PIXEL
	@ 055,010 Say OemToAnsi("B (mm)")			  		Size 030,008 of oFolder:aDialogs[3] PIXEL

	@ 010,170 Say OemToAnsi("T (°C") 	     		  	Size 030,008 of oFolder:aDialogs[3] PIXEL
	@ 025,170 Say OemToAnsi("Pressão (Kg/Cm²)")		    Size 040,008 of oFolder:aDialogs[3] PIXEL
	@ 040,170 Say OemToAnsi("Cr (Kgf/Cm²)") 			Size 040,008 of oFolder:aDialogs[3] PIXEL
	@ 055,170 Say OemToAnsi("C (Kgf/Cm²)") 				Size 040,008 of oFolder:aDialogs[3] PIXEL

	@ 010,043 MsGet nI15 Picture "9999999999" 			Size 120,010 of oFolder:aDialogs[3] PIXEL
	@ 025,043 MsGet nI16 Picture "9999999999" 			Size 120,010 of oFolder:aDialogs[3] PIXEL
	@ 040,043 MsGet nI17 Picture "9999999999" 			Size 120,010 of oFolder:aDialogs[3] PIXEL
	@ 055,043 MsGet nI18 Picture "9999999999" 			Size 120,010 of oFolder:aDialogs[3] PIXEL

	@ 010,223 MsGet nI19 Picture "9999999999" 			Size 120,010 of oFolder:aDialogs[3] PIXEL
	@ 025,223 MsGet nI20 Picture "9999999999" 			Size 120,010 of oFolder:aDialogs[3] PIXEL
	@ 040,223 MsGet nI21 Picture "9999999999" 			Size 120,010 of oFolder:aDialogs[3] PIXEL
	@ 055,223 MsGet nI22 Picture "9999999999" 			Size 120,010 of oFolder:aDialogs[3] PIXEL

//Dados para a pasta "Dimensionamento2"

	@ 010,010 Say OemToAnsi("Co(Kgf/Cm²)")	  			Size 030,008 of oFolder:aDialogs[4] PIXEL
	@ 025,010 Say OemToAnsi("Graxa mim-1")				Size 030,008 of oFolder:aDialogs[4] PIXEL
	@ 040,010 Say OemToAnsi("Oleo mim-1")		 		Size 030,008 of oFolder:aDialogs[4] PIXEL
	@ 055,010 Say OemToAnsi("RPM")   	     		  	Size 030,008 of oFolder:aDialogs[4] PIXEL

	@ 010,170 Say OemToAnsi("Passo (mm)")       		Size 040,008 of oFolder:aDialogs[4] PIXEL
	@ 025,170 Say OemToAnsi("Diametro do Eixo(mm)")   	Size 040,008 of oFolder:aDialogs[4] PIXEL
	@ 040,170 Say OemToAnsi("Diametro (mm)")			Size 040,008 of oFolder:aDialogs[4] PIXEL
	@ 055,170 Say OemToAnsi("Diametro do Pino (mm)")	Size 040,008 of oFolder:aDialogs[4] PIXEL

	@ 010,043 MsGet nI23 Picture "9999999999" 			Size 120,010 of oFolder:aDialogs[4] PIXEL
	@ 025,043 MsGet nI24 Picture "9999999999" 			Size 120,010 of oFolder:aDialogs[4] PIXEL
	@ 040,043 MsGet nI25 Picture "9999999999" 			Size 120,010 of oFolder:aDialogs[4] PIXEL
	@ 055,043 MsGet nI26 Picture "9999999999" 			Size 120,010 of oFolder:aDialogs[4] PIXEL

	@ 010,223 MsGet nI27 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[4] PIXEL
	@ 025,223 MsGet nI28 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[4] PIXEL
	@ 040,223 MsGet nI29 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[4] PIXEL
	@ 055,223 MsGet nI30 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[4] PIXEL

//Dados para a pasta "Dimensionamento3"
	@ 010,010 Say OemToAnsi("Diametro do Rolo (mm)")	Size 030,008 of oFolder:aDialogs[5] PIXEL
	@ 025,010 Say OemToAnsi("Rosca")					Size 030,008 of oFolder:aDialogs[5] PIXEL
	@ 040,010 Say OemToAnsi("Dispositivo Trava") 		Size 030,008 of oFolder:aDialogs[5] PIXEL
	@ 055,010 Say OemToAnsi("Porca")   	     		  	Size 030,008 of oFolder:aDialogs[5] PIXEL

	@ 010,170 Say OemToAnsi("Arruela")       			Size 040,008 of oFolder:aDialogs[5] PIXEL
	@ 025,170 Say OemToAnsi("de (mm)")   				Size 040,008 of oFolder:aDialogs[5] PIXEL
	@ 040,170 Say OemToAnsi("da (mm)")					Size 040,008 of oFolder:aDialogs[5] PIXEL
	@ 055,170 Say OemToAnsi("Perfil")					Size 040,008 of oFolder:aDialogs[5] PIXEL

	@ 010,043 MsGet nI31 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[5] PIXEL
	@ 025,043 MsGet cI32 								Size 120,010 of oFolder:aDialogs[5] PIXEL
	@ 040,043 MsGet cI33 								Size 120,010 of oFolder:aDialogs[5] PIXEL
	@ 055,043 MsGet cI34 								Size 120,010 of oFolder:aDialogs[5] PIXEL

	@ 010,223 MsGet cI35 								Size 120,010 of oFolder:aDialogs[5] PIXEL
	@ 025,223 MsGet nI36 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[5] PIXEL
	@ 040,223 MsGet nI37 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[5] PIXEL
	@ 055,223 MsGet nI38 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[5] PIXEL

//Dados para a pasta "Dimensionamento4"
	@ 010,010 Say OemToAnsi("No. Frisos")				Size 030,008 of oFolder:aDialogs[6] PIXEL
	@ 025,010 Say OemToAnsi("A1 (mm)")					Size 030,008 of oFolder:aDialogs[6] PIXEL
	@ 040,010 Say OemToAnsi("A (mm)")					Size 030,008 of oFolder:aDialogs[6] PIXEL
	@ 055,010 Say OemToAnsi("L (mm)")  	     		  	Size 030,008 of oFolder:aDialogs[6] PIXEL

	@ 010,170 Say OemToAnsi("G (mm)")        			Size 040,008 of oFolder:aDialogs[6] PIXEL
	@ 025,170 Say OemToAnsi("H1 (mm)")   				Size 040,008 of oFolder:aDialogs[6] PIXEL
	@ 040,170 Say OemToAnsi("H2 (mm)")					Size 040,008 of oFolder:aDialogs[6] PIXEL
	@ 055,170 Say OemToAnsi("H (mm)")					Size 040,008 of oFolder:aDialogs[6] PIXEL

	@ 010,043 MsGet nI39 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[6] PIXEL
	@ 025,043 MsGet nI40 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[6] PIXEL
	@ 040,043 MsGet nI41 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[6] PIXEL
	@ 055,043 MsGet nI42 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[6] PIXEL

	@ 010,223 MsGet nI43 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[6] PIXEL
	@ 025,223 MsGet nI44 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[6] PIXEL
	@ 040,223 MsGet nI45 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[6] PIXEL
	@ 055,223 MsGet nI46 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[6] PIXEL

//Dados para a pasta "Dimensionamento5"
	@ 010,010 Say OemToAnsi("J (mm)")       			Size 030,008 of oFolder:aDialogs[7] PIXEL
	@ 025,010 Say OemToAnsi("C (mm)") 					Size 030,008 of oFolder:aDialogs[7] PIXEL
	@ 040,010 Say OemToAnsi("N1 (mm)")					Size 030,008 of oFolder:aDialogs[7] PIXEL
	@ 055,010 Say OemToAnsi("Comprimento B1")		  	Size 030,008 of oFolder:aDialogs[7] PIXEL

	@ 010,170 Say OemToAnsi("Caixa")         			Size 040,008 of oFolder:aDialogs[7] PIXEL
	@ 025,170 Say OemToAnsi("Bucha Fixacao")			Size 040,008 of oFolder:aDialogs[7] PIXEL
	@ 040,170 Say OemToAnsi("Tipo Rolamento")			Size 040,008 of oFolder:aDialogs[7] PIXEL
	@ 055,170 Say OemToAnsi("N")						Size 040,008 of oFolder:aDialogs[7] PIXEL

	@ 010,043 MsGet nI47 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[7] PIXEL
	@ 025,043 MsGet nI48 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[7] PIXEL
	@ 040,043 MsGet nI49 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[7] PIXEL
	@ 055,043 MsGet nI50 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[7] PIXEL

	@ 010,223 MsGet cI51 								Size 120,010 of oFolder:aDialogs[7] PIXEL
	@ 025,223 MsGet cI52 								Size 120,010 of oFolder:aDialogs[7] PIXEL
	@ 040,223 MsGet cI53 								Size 120,010 of oFolder:aDialogs[7] PIXEL
	@ 055,223 MsGet nI54 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[7] PIXEL

//Dados para a pasta "Dimensionamento6"
	@ 010,010 Say OemToAnsi("No. Pastilha") 			Size 030,008 of oFolder:aDialogs[8] PIXEL
	@ 025,010 Say OemToAnsi("No. Lonas")				Size 030,008 of oFolder:aDialogs[8] PIXEL

	@ 010,043 MsGet nI55 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[8] PIXEL
	@ 025,043 MsGet nI56 Picture "9999999999"			Size 120,010 of oFolder:aDialogs[8] PIXEL

	@ 003,010 BITMAP FILE "sigaadv/rolam1.jpg" Size 080,075 of oFolder:aDialogs[9] PIXEL ADJUST

	DEFINE FONT oFont NAME "Courier New" SIZE 0,-11

	@ 100,004  SAY Space(85)+	Substr(cTextoAux,01,1)+' '+Substr(cTextoAux,04,1)+' '+Substr(cTextoAux,07,1)+' '+Substr(cTextoAux,10,1)+' '+;
		Substr(cTextoAux,13,1)+' '+Substr(cTextoAux,16,1)+' '+Substr(cTextoAux,19,1)+' '+Substr(cTextoAux,22,1)+' '+;
		Substr(cTextoAux,25,1)+' '+Substr(cTextoAux,28,1) PIXEL FONT oFONT

	@ 105,004  SAY Space(85)+	Substr(cTextoAux,02,1)+' '+Substr(cTextoAux,05,1)+' '+Substr(cTextoAux,08,1)+' '+Substr(cTextoAux,11,1)+' '+;
		Substr(cTextoAux,14,1)+' '+Substr(cTextoAux,17,1)+' '+Substr(cTextoAux,20,1)+' '+Substr(cTextoAux,23,1)+' '+;
		Substr(cTextoAux,26,1)+' '+Substr(cTextoAux,29,1) PIXEL FONT oFONT

	@ 110,004  SAY PadR("QTD",09)+"  "+PadR("REFERENCIA",20)+"  "+PadR("MARCA",20)+"  "+PadR("R$ PRECO",12)+"  "+PadR("CODIGO",15)+' '+;
		Substr(cTextoAux,03,1)+' '+Substr(cTextoAux,06,1)+' '+Substr(cTextoAux,09,1)+' '+Substr(cTextoAux,12,1)+' '+;
		Substr(cTextoAux,15,1)+' '+Substr(cTextoAux,18,1)+' '+Substr(cTextoAux,21,1)+' '+Substr(cTextoAux,24,1)+' '+;
		Substr(cTextoAux,27,1)+' '+Substr(cTextoAux,30,1) PIXEL FONT oFONT

	@ 120,004  LISTBOX oListPRO VAR nItemPro SIZE 450,075 PIXEL ITEMS aListPro FONT oFONT ON DBLCLICK(u_F190Qtd1(@oListPRO,oListPRO:nAt,@aListPRO))

	@ 120,455 Button OemToAnsi("&Localizar")	Size 036,015 of oDlgAv PIXEL Action fLocaliza1()
	@ 135,455 Button OemToAnsi("A&vancado ")	Size 036,015 of oDlgAv PIXEL Action (IniTela(), oDlgAv:End()) When .f.
	@ 150,455 Button OemToAnsi("&Sair" ) 		Size 036,015 of oDlgAv PIXEL Action oDlgAv:End()

	ACTIVATE MSDIALOG oDlgAv CENTERED

Return(.T.)
*******************************************************************************
User Function F190VALQTD(nIt,aArray,nQtdAux,oDlg02)
*******************************************************************************
	Local lOk 		  := .F.
	Local lValidouQTD := .F.
	Local cMsgPostit  :=" "

//³Verifica se o produto faz parte de uma campanha de vendas ³
//³vigente e avisa o usuario, carrega aPrecosCamp            ³
//³Sintaxe:                                                  ³
//³MsgCamp(cProduto,lAtuPrcCamp,lF4,lMsg,lCopia,nAcreCond)   ³

//If Len(SubStr(aArray[nIt],70,13))=0
// oDlg02:End()
// Return(lValidouQTD)

//Endif

	IF EMPTY(M->UB_VRCACRE)
		IW_MsgBox(Oemtoansi("Produto "+M->UB_PRODUTO+" não cadastrado ou sem preço para esta tabela de preços."),'Atenção','ALERT')
	ELSE
		aCols[n,GDFieldPos('UB_PRODUTO')] := M->UB_PRODUTO
		aCols[n,GDFieldPos('UB_VRCACRE')] := M->UB_VRCACRE
		aCols[n,GDFieldPos('UB_EQSIORI')] := M->UB_EQSIORI

		__ReadVar := "M->UB_PRODUTO"
		lOk := CheckSX3('UB_PRODUTO',M->UB_PRODUTO)
		RunTrigger(2,n,"",,PADR('UB_PRODUTO',10))
	//	Alert("Entrou Trigger UB_PRODUTO")

		IF  lOk
			__ReadVar := 'M->UB_VRCACRE'
			lOk := CheckSX3('UB_VRCACRE',M->UB_VRCACRE)
		ENDIF
	ENDIF

	If lOk
		__ReadVar 	:= 'M->UB_QUANT'
		lValidouQTD := CheckSX3('UB_QUANT',nQtdAux)

	//	RunTrigger(2,n,"",,PADR('UB_QUANT',10))
	//	Alert("Entrou Trigger UB_QUANT")

	//|	RunTrigger(2,nLinha,"",,PADR('UB_QUANT',10))
	//	U_RunLTriguer( n , "UB_QUANT", "UB_TES"		)
	//|	U_RunLTriguer( n , "UB_QUANT", "UB_DESCICM"	)

	ELSE
		nQtdAux := 0
		lValidouQTD := .T.
	ENDIF

	If !lOk .OR. nQtdAux == 0
		aCols[n,Len(aHeader)+1]:=.T.
	ENDIF

Return lValidouQTD
*******************************************************************************
User Function LinhaAdd()
*******************************************************************************

	Local lCriou := .F.

	IF !EMPTY(aCols[Len(acols),GdFieldPos("UB_PRODUTO")])
		lCriou := .T.
		eVal( oGetTlv:obrowse:badd ) // ADICIONA UMA LINHA NA GETDADOS AUTOMATICAMENTE
		oGetTlv:oBrowse:Refresh()
	Endif

Return lCriou
*******************************************************************************
User Function fMostraArm()//Mostra em ListBox os itens ja armazenados
*******************************************************************************

	Private aList:={}
	Private oList
	lpassou:= .f.
	If Len(aArmazena) = 0
		IW_MsgBox('Nenhum item selecionado')
		Return()
	Endif

	For nx:=1 To Len(aArmazena)
		Aadd(aList,{Posicione("SB1",1,xFilial("SB1")+aArmazena[nx,1],"B1_DESC"),aArmazena[nx,2],aArmazena[nx,3],Posicione("SB1",1,xFilial("SB1")+aArmazena[nx,4],"B1_DESC")})
	Next


	DEFINE MSDIALOG oDlg TITLE 'Itens Armazendos' FROM 0,0 TO 18,80 OF oMainWnd
	DEFINE SBUTTON oBut FROM 122,270 TYPE 01 ENABLE OF oDlg PIXEL ACTION oDlg:End()
	DEFINE SBUTTON oBut FROM 121,230 TYPE 03 ENABLE OF oDlg PIXEL ACTION (u_DelItem(oList:nAt))
	@ 02,02  LISTBOX oList FIELDS HEADER  'Produto','Quantidade','Prc.c/Acrescimo','Eq/Sim Origem' SIZE 300,120 PIXEL FONT oFONT OF oDlg

	oList:Align := 3
	oList:SetArray(aList)
	oList:nAt:=1
	oList:bLine:={|| {	aList[oList:nAt,01],aList[oList:nAt,02],aList[oList:nAt,03],aList[oList:nAt,04]}}
	oList:Refresh()

	ACTIVATE MSDIALOG oDlg CENTERED

Return()
*******************************************************************************
User Function Pergunta(prog)
*******************************************************************************

	Local cCOMBO
	Private oDlgX
//aArea := GetArea()
	ccombo := " "
	aopcoes := Array(0)
	lExecuta := .f.

	IF !lRodaF11
		Return()
	ENDIF
//InKeyIdle() <> VK_F11
	IF SubStr(aListPRO[oListPRO:nAt],85,1) == 'X' //busca se produto tem equivalente
		AADD(aopcoes, "Equivalente")
	ENDIF
	IF SubStr(aListPRO[oListPRO:nAt],87,1) == 'X' //busca se produto tem similar
		AADD(aopcoes, "Similar")
	ENDIF

	IF LEN(aopcoes) == 0
		Alert("Produto " + ALLTRIM(SubStr(aListPRO[oListPRO:nAt],70,14)) + " não possui produtos Equivalentes ou Similares")
	Else

		@ 010,001 TO 100,200 DIALOG oDlgX TITLE  OemToAnsi("Selecione a Opção ")
		@ 012,024 COMBOBOX oCOMBO  VAR cCOMBO	ITEMS aopcoes  SIZE 60, 55 OF oDlgX PIXEL

		@ 32, 020 BmpButton Type 1 Action (U_IMDF190B(oListPRO:nAt,aListPRO,cCOMBO),oDlgX:End())
		@ 32, 050 BmpButton Type 2 Action oDlgX:End() //Close(oDlgX )

		Activate Dialog oDlgX CENTER

		oListPRO:SetArray(aListPRO)
		oListPRO:Refresh()
		oListPRO:SetFocus()

	Endif

Return()
*******************************************************************************
Static Function BQueryimdf190()
*******************************************************************************
	Local cquery
	Local cDesova 		:= GetMv("MV_DESOVA")
	Local FilComEst02 	:= GetMv("IM_OPERE02")

	If Select("cQuery") <> 0
		cQuery->( DbCLoseArea() )
	EndIf

	cQuery := ""

	CQUERY += " SELECT SB1.B1_COD, "
	CQUERY += "        SB1.B1_REFER, "
	CQUERY += "        SB1.B1_MARCA, "
	CQUERY += "        SB1.B1_TIPO, "
	CQUERY += "        SB1.B1_UM, "
	CQUERY += "        SB1.B1_GRUPO, "
	CQUERY += "        SB1.B1_PRV1, "
	CQUERY += "        SB1.B1_EQUIVAL, "
	CQUERY += "        SB1.B1_SIMILAR, "
	CQUERY += "        SB1.B1_BATALHA, "
	CQUERY += "        SB1.B1_OBSTPES, "
	CQUERY += "        SB1.B1_UM     , "

	// Inicio Estoque 02
	If cFilAnt $ FilComEst02
		CQUERY += "		NVL(SB2.B2_QATU - SB2.B2_RESERVA - SB2.B2_QACLASS - SB2.B2_QPEDVEN + NVL(EST2.EST2,0) ,0) QTDEST, "
	Else
		CQUERY += "		NVL(SB2.B2_QATU - SB2.B2_RESERVA - SB2.B2_QACLASS - SB2.B2_QPEDVEN             ,0) QTDEST, "
	EndIf

	CQUERY += "        CASE "
	CQUERY += "          WHEN SB1.B1_COD IN(" + cDesova + ") "
	CQUERY += "          THEN 'S' "
	CQUERY += "          ELSE 'N' "
	CQUERY += "        END DESOVA, "
	CQUERY += "        NVL(EST.CASA,0) CASA "
	CQUERY += "FROM  SB1010 SB1 LEFT JOIN SB2010 SB2  "
	CQUERY += "      ON  SB1.B1_FILIAL  = SB2.B2_FILIAL "
	CQUERY += "      AND SB1.B1_COD     = SB2.B2_COD "

	// Estoque Casas..
	CQUERY += "                LEFT JOIN (  SELECT SB2.B2_COD,    SUM (SB2.B2_QATU - SB2.B2_RESERVA - SB2.B2_QACLASS- SB2.B2_QPEDVEN) CASA "
	CQUERY += "                              FROM   SB2010 SB2 "
	CQUERY += "                              WHERE SB2.B2_FILIAL IN ("+U_cRetFils("Q","MV_FILSEST",.F.)+") "
	CQUERY += "                              AND SB2.B2_COD IN ( SELECT B1_COD "
	CQUERY += "                                                  FROM SB1010 SB1 "
	CQUERY += "                                                  WHERE SB1.B1_FILIAL = '05' "
	CQUERY += "                                                  AND ( SB1.B1_MSBLQL = '2' OR SB1.B1_MSBLQL    = ' ') "

	IIf(!Empty(cRef),cQuery +=			"AND SB1.B1_REFER 	LIKE	'%"	+cRef+ "%' ",)
	IIf(!Empty(cMar),cQuery +=			"AND SB1.B1_MARCA 	LIKE  	'" 	+cMar+ "%' ",)
	IIf(!Empty(cCod),cQuery +=			"AND SB1.B1_COD 		=	 	'" 	+cCod+ "' ",)
	If Empty(cRef)
		IIf(!Empty(cDes),cQuery +=		"AND SB1.B1_REFER 	LIKE   '" 	+cDes+ "%' ",)
	Endif
	IIf(!Empty(cGrp),cQuery +=			"AND SB1.B1_GRUPO 	=     	'" 	+cGrp+ "' ",)
	IIf(!Empty(cGr1),cQuery +=			"AND SB1.B1_SGRB1  	=     	'" 	+cGr1+ "' ",)
	IIf(!Empty(cGr2),cQuery +=			"AND SB1.B1_SGRB2 	=     	'" 	+cGr2+ "' ",)
	IIf(!Empty(cGr3),cQuery +=			"AND SB1.B1_SGRB3 	=     	'" 	+cGr3+ "' ",)


	CQUERY += "                                                  AND SB1.D_E_L_E_T_ = ' '  ) "
	CQUERY += "                              AND SB2.B2_LOCAL   = '01' "
	CQUERY += "                              AND SB2.D_E_L_E_T_ = ' ' "
	CQUERY += "                              GROUP BY SB2.B2_COD "
	CQUERY += "                             ) EST "

	CQUERY += "      ON SB1.B1_COD     = EST.B2_COD                           "
	// Fim Estoque Casas..

	// Inicio Estoque 02
	If cFilAnt $ FilComEst02

	CQUERY += "                LEFT JOIN (  SELECT SB2.B2_COD,    SUM (SB2.B2_QATU - SB2.B2_RESERVA - SB2.B2_QACLASS- SB2.B2_QPEDVEN) EST2 "
	CQUERY += "                              FROM   SB2010 SB2 "
	CQUERY += "                              WHERE SB2.B2_FILIAL  = '"+cFilAnt+"' "
	CQUERY += "                              AND SB2.B2_COD IN ( SELECT B1_COD "
	CQUERY += "                                                  FROM SB1010 SB1 "
	CQUERY += "                                                  WHERE SB1.B1_FILIAL = '05' "
	CQUERY += "                                                  AND ( SB1.B1_MSBLQL = '2' OR SB1.B1_MSBLQL    = ' ') "

	IIf(!Empty(cRef),cQuery +=			"AND SB1.B1_REFER 	LIKE	'%"	+cRef+ "%' ",)
	IIf(!Empty(cMar),cQuery +=			"AND SB1.B1_MARCA 	LIKE  	'" 	+cMar+ "%' ",)
	IIf(!Empty(cCod),cQuery +=			"AND SB1.B1_COD 		=	 	'" 	+cCod+ "' ",)
	If Empty(cRef)
		IIf(!Empty(cDes),cQuery +=		"AND SB1.B1_REFER 	LIKE   '" 	+cDes+ "%' ",)
	Endif
	IIf(!Empty(cGrp),cQuery +=			"AND SB1.B1_GRUPO 	=     	'" 	+cGrp+ "' ",)
	IIf(!Empty(cGr1),cQuery +=			"AND SB1.B1_SGRB1  	=     	'" 	+cGr1+ "' ",)
	IIf(!Empty(cGr2),cQuery +=			"AND SB1.B1_SGRB2 	=     	'" 	+cGr2+ "' ",)
	IIf(!Empty(cGr3),cQuery +=			"AND SB1.B1_SGRB3 	=     	'" 	+cGr3+ "' ",)


	CQUERY += "                                                  AND SB1.D_E_L_E_T_ = ' '  ) "
	CQUERY += "                              AND SB2.B2_LOCAL   = '02' "
	CQUERY += "                              AND SB2.D_E_L_E_T_ = ' ' "
	CQUERY += "                              GROUP BY SB2.B2_COD "
	CQUERY += "                             ) EST2 "

	CQUERY += "      ON SB1.B1_COD     = EST2.B2_COD                           "

	EndIf
	// Fim Estoque 02..

	CQUERY += "WHERE SB1.D_E_L_E_T_ = ' ' "

	IIf(!Empty(cRef),cQuery +=		"AND SB1.B1_REFER 	LIKE	'%"	+cRef+ "%' ",)
	IIf(!Empty(cMar),cQuery +=		"AND SB1.B1_MARCA 	LIKE  	'" 	+cMar+ "%' ",)
	IIf(!Empty(cCod),cQuery +=		"AND SB1.B1_COD 		=	 	'" 	+cCod+ "' ",)
	If Empty(cRef)
		IIf(!Empty(cDes),cQuery +=	"AND SB1.B1_REFER 	LIKE  	'" 	+cDes+ "%' ",)
	Endif
	IIf(!Empty(cGrp),cQuery +=		"AND SB1.B1_GRUPO 	=     	'" 	+cGrp+ "' ",)
	IIf(!Empty(cGr1),cQuery +=		"AND SB1.B1_SGRB1  	=     	'" 	+cGr1+ "' ",)
	IIf(!Empty(cGr2),cQuery +=		"AND SB1.B1_SGRB2 	=     	'" 	+cGr2+ "' ",)
	IIf(!Empty(cGr3),cQuery +=		"AND SB1.B1_SGRB3 	=     	'" 	+cGr3+ "' ",)

	CQUERY += "  AND SB1.B1_FILIAL  = '"+cFilAnt+"' "
	CQUERY += "  AND SB1.B1_MSBLQL != '1' "

	CQUERY += "  AND(SB2.B2_LOCAL   = '01' OR  SB2.B2_LOCAL IS NULL) "
	CQUERY += "  AND(SB2.D_E_L_E_T_ = ' '  OR  SB2.B2_LOCAL IS NULL) "

	CQUERY += " ORDER BY  B1_BATALHA   ,DESOVA,  QTDEST DESC, CASA DESC,  B1_EQUIVAL DESC,  B1_SIMILAR DESC,  B1_REFER "

Return(cquery)
*******************************************************************************
User Function DelItem(noitem)
*******************************************************************************

	IF MsgYesNo("Confirma exclusão deste item ?")
		aListClone	:= {}
		aListClone 	:= aClone(aList)
		aList 	:= {}
		for i:=1 to LEN(aListClone)
			If i != noitem
				AADD(aList,{aListClone[i][1],aListClone[i][2],aListClone[i][3],aListClone[i][4]})
			Endif
		Next i

		aListClone	:= {}
		aListClone 	:= aClone(aArmazena)
		aArmazena 	:= {}
		for i:=1 to LEN(aListClone)
			If i != noitem
				AADD(aArmazena,{aListClone[i][1],aListClone[i][2],aListClone[i][3],aListClone[i][4]})
			Endif
		Next i

	Endif

	oDlg:End()

	U_fMostraArm()

Return()
*******************************************************************************
User Function F190EQUI( cProd, cSGRB1 ) //|Consultar os produtos equivalentes da Marca INA que tem estoque em qualquer Filial.
*******************************************************************************
	Local cQuery   := ""
	Local aArea	   := GetArea()
	Local cMarca   := ""
	Local npos
	Local nQtdeIt  := Len( aCols )
	Local nP_Recno := Ascan( aHeader, {|x| AllTrim( x[2] ) == "UB_REC_WT"} )

	nPos := Ascan( aAbaulSimi, { |x| x[1] == cProd } )

// Inserido por Edivaldo Goncalves Cordeiro - Projeto Abaulados
	If cSGRB1 = "061100"
		If nPos == 0 //So adiciona o produto no Array aAbaulSimi se ainda nao tiver sido incluso
			aAdd( aAbaulSimi, { cProd } )
		Endif
	Endif

// Jorge Oliveira - 15/03/2011 - Na alteracao do Item de um Pedido ou Orcamento nao precisa verificar os Produtos Equivalentes
	If !Empty( aCols[ N, nP_Recno ] )
		Return()
	EndIf

	cMarca  := SuperGetMV( "MV_PR_EQUI",, "'FAG'" )
//cFilEst := SUB->(U_cRetFils()) //Retorna as filiais que operam com estoque

	cQuery := " SELECT DISTINCT ZH_PROD, ZH.ZH_EQUI, B1.B1_COD, B1.B1_DESC, B1_REFER, B1.B1_MARCA, B1_SGRB1 "
	cQuery += "   FROM " + RetSqlName( "SZH" ) + " ZH "
	cQuery += "      , " + RetSqlName( "SB1" ) + " B1 "
	cQuery += "      , " + RetSqlName( "SB2" ) + " B2 "
	cQuery += "  WHERE ZH.D_E_L_E_T_ = ' ' "
	cQuery += "    AND B1.D_E_L_E_T_ = ' ' "
	cQuery += "    AND B2.D_E_L_E_T_ = ' ' "
	cQuery += "    AND ZH.ZH_FILIAL  = '" + xFilial( "SZH" ) + "' "
	cQuery += "    AND B1.B1_FILIAL  = '" + xFilial( "SB1" ) + "' "

	cQuery += "	   AND  B2.B2_FILIAL IN ("+cFilEst+")"

	cQuery += "    AND B1.B1_LOCPAD  = '01' " // VALOR FIXO
	cQuery += "    AND B2.B2_LOCAL   = '01' " // VALOR FIXO
	cQuery += "    AND B1.B1_MARCA IN ( " + cMarca + " ) "
	cQuery += "    AND ZH.ZH_PROD    = '" +  cProd + "' "
	cQuery += "    AND B1.B1_SGRB1   = '" + cSGRB1 + "' "
	cQuery += "    AND B1.B1_EQUIVAL = 'S' " //Produto Equivalente da SZH estah cadastrado como Equivalente no SB1
	cQuery += "    AND ZH.ZH_EQUI    = B1.B1_COD "
	cQuery += "    AND B2.B2_COD     = ZH.ZH_EQUI "
	cQuery += "    AND ( B2.B2_QATU - B2.B2_RESERVA - B2.B2_QACLASS - B2.B2_QPEDVEN ) > 0 " // Tem saldo
	cQuery += " ORDER BY ZH.ZH_PROD "

	U_ExecMySql(cQuery, "QRY_EQUI", "Q", lCaptura )

	DbSelectArea( "QRY_EQUI" )

	QRY_EQUI->( DbGoTop() )

// Para cada registro que localizar, irah colocar na tela !
	While QRY_EQUI->( !EOF() )

	// Coloca a linha no acols
		U_LinhaAdd()

		N := Len( aCols )
		oGetTlv:oBrowse:nAt := N

	// Alimenta a linha com o Produtok
		__ReadVar     := "M->UB_PRODUTO"
		M->UB_PRODUTO := QRY_EQUI->ZH_EQUI
		aCols[ N, GDFieldPos("UB_PRODUTO") ] := M->UB_PRODUTO
		GDFieldPut( 'UB_PRODUTO', M->UB_PRODUTO, N )

	// Executa a trigger para preencher os outros campos da tela
		CheckSX3( "UB_PRODUTO", M->UB_PRODUTO )
		RunTrigger(2,N,"",,PadR("UB_PRODUTO",10))

	// Alimenta a linha com a Quantidade
		__ReadVar 	:= "M->UB_QUANT"
		M->UB_QUANT	:= 1
		aCols[ N, GDFieldPos("UB_QUANT") ] := M->UB_QUANT
		GDFieldPut( 'UB_QUANT', M->UB_QUANT, N )

	// Executa a trigger para que nao apareca a mensagem: "Confirme a quantidade do item XX"
		CheckSX3( "UB_QUANT", M->UB_QUANT )
		RunTrigger(2,N,"",,PadR("UB_QUANT",10))

		QRY_EQUI->( DbSkip() )
	EndDo

// Jorge Oliveira - 10/03/2011 - Chamado AAZTNL - Se teve itens incluidos, entao atualiza
	If nQtdeIt <> Len( aCols )
		oGetTlv:SetArray( aCols )
		oGetTlv:Refresh()
		oGetTlv:oBrowse:Refresh()
	EndIf

	QRY_EQUI->( DbCloseArea() )
	RestArea(aArea)

Return()

*******************************************************************************
User Function F190EBOOK(cProd) //|Consultar os produtos equivalentes Book
*******************************************************************************
	Local cQuery   := ""
	Local aArea	   := GetArea()
	Local cMarca   := ""
	Local npos
	Local nQtdeIt  := Len( aCols )
	Local nP_Recno := Ascan( aHeader, {|x| AllTrim( x[2] ) == "UB_REC_WT"} )



	If !Empty( aCols[ N, nP_Recno ] )
		Return()
	EndIf

//cMarca  := SuperGetMV( "MV_PR_EQUI",, "'FAG'" )
//cFilEst := SUB->(U_cRetFils()) //Retorna as filiais que operam com estoque

	cQuery := " SELECT  ZH_EQUI "
	cQuery += " FROM " + RetSqlName( 'SB2' ) + " SB2, " + RetSQLName("SZH") + " SZH "
	cQuery += " WHERE "
	cQuery += "  ZH_FILIAL     	= '" + xFilial( "SZH" ) + "' "
	cQuery += "  AND	B2_FILIAL 	= '" + xFilial( "SB2" ) + "' "
	cQuery += "  AND ZH_PROD 	= '" +  cProd + "' "
	cQuery += "  AND   ZH_PROMBOK = 'S' "
	cQuery += "  AND  B2_COD=ZH_EQUI"
	cQuery += "  AND  B2_LOCAL	='01' "
	cQuery += "  AND ( B2_QATU - B2_RESERVA - B2_QACLASS - B2_QPEDVEN ) > 0"
	cQuery += "  AND   SZH.D_E_L_E_T_ = '  ' "
	cQuery += "  AND   SB2.D_E_L_E_T_ = ' '  "

	U_ExecMySql(cQuery, "QRY_EQUI", "Q", lCaptura )

	DbSelectArea( "QRY_EQUI" )

	QRY_EQUI->( DbGoTop() )

// Para cada registro que localizar, irah colocar na tela !
	While QRY_EQUI->( !EOF() )

	// Coloca a linha no acols
		U_LinhaAdd()

		N := Len( aCols )
		oGetTlv:oBrowse:nAt := N

	// Alimenta a linha com o Produtok
		__ReadVar     := "M->UB_PRODUTO"
		M->UB_PRODUTO := QRY_EQUI->ZH_EQUI
		aCols[ N, GDFieldPos("UB_PRODUTO") ] := M->UB_PRODUTO
		GDFieldPut( 'UB_PRODUTO', M->UB_PRODUTO, N )

	// Executa a trigger para preencher os outros campos da tela
		CheckSX3( "UB_PRODUTO", M->UB_PRODUTO )
		RunTrigger(2,N,"",,PadR("UB_PRODUTO",10))

	// Alimenta a linha com a Quantidade
		__ReadVar 	:= "M->UB_QUANT"
		M->UB_QUANT	:= 1
		aCols[ N, GDFieldPos("UB_QUANT") ] := M->UB_QUANT
		GDFieldPut( 'UB_QUANT', M->UB_QUANT, N )

	// Executa a trigger para que nao apareca a mensagem: "Confirme a quantidade do item XX"
		CheckSX3( "UB_QUANT", M->UB_QUANT )
		RunTrigger(2,N,"",,PadR("UB_QUANT",10))

		QRY_EQUI->( DbSkip() )
	EndDo

	If nQtdeIt <> Len( aCols )
		oGetTlv:SetArray( aCols )
		oGetTlv:Refresh()
		oGetTlv:oBrowse:Refresh()
	EndIf

	QRY_EQUI->( DbCloseArea() )
	RestArea(aArea)

Return()
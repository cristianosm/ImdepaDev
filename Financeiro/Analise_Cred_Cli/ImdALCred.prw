#INCLUDE "PROTHEUS.CH"
#INCLUDE "HBUTTON.CH"
#INCLUDE "MSGRAPHI.CH"

#Define ENTER 		CHR(13) + CHR(10)
#Define LIMITGP 	3
#Define LIMITGL 	18
#Define AJUSTE 	300

#Define POSI	 		10		//| Posicao Inicial
#Define TAMT  		100		//| Tamanho Total
#Define TIME 		350		//| Tempo limite para Nova execucao quando em uso ....

//| Browse
#Define MARKB 		1
#Define LEGEND 	2
#Define RISCO 		3
#Define SEGCLI 	4
#Define CNPJ 		5
#Define CODIGO 	6
#Define NOME 		7

#DEFINE COR_VERDE 	13500392
#DEFINE COR_AMARE 	14024703
#DEFINE COR_AZUL  	16774891
#DEFINE COR_CINZA 	15724527

#Define MOSTRAQRY 	.T.  	//| Mostra Querys para Captura em tempo de execucao
#Define SLEEPTIME 	0  		//| Mostra Querys para Captura em tempo de execucao

#Define ARREDONDA	100     //| Arredondamento Limite de Credito Sugerido Ex.: 25 -> 477 = 475...  498 = 500

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥IMDALCRED ∫Autor  ≥CRISTIANO MACHADO   ∫ Data ≥  04/16/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
*********************************************************************
User Function ImdALCred()
*********************************************************************
	Private lContinua := .T.

	Private RiscoC 	:= 	"" 				//| Risco ('B','C','D','E')
	Private ValLCI	 	:=	 0           	//| Valor limite de Credito = 0
	Private ValLCF	 	:=	 0				//| Valor limite de Credito = 0
	Private NumQCI	 	:=	 0				//| Quantidade de Compras = 0
	Private NumQCF	 	:=	 0				//| Quantidade de Compras = 0
	Private DatVLI	 	:=	 dDataBase		//| Data Vencimento Limite Credito = 10/10/2010
	Private DatVLF	 	:=	 dDataBase		//| Data Vencimento Limite Credito = 10/10/2010
	Private DatUCI	 	:=	 dDataBase		//| Data Ultima Compra = 10/10/2010
	Private DatUCF	 	:=	 dDataBase		//| Data Ultima Compra = 10/10/2010
	Private DatUAS 	:=	 dDataBase		//| Data Ultima Avaliacao Serasa = 10/10/2010
	Private DPInic	 	:=	 STod(substr(dTos(dDataBase - 541),1,6) + "01")	//| Data Periodo Inicial 18 Meses = 10/10/2009
	Private DPFina 	:=	 dDataBase - 1	//| Data Periodo Final Otem = 10/10/2012
	Private cFGerI 	:=  ""				//| Filtra Gerente Inicial
	Private cFGerF 	:=  ""           	//| Filtra Gerente Final

	Private cCgcCli  :=  Space(14)
	Private FimLWin	 //:=  0
	Private lAlter 	 :=	.F.
	Private nCliFilt :=	0

//|Configuracoes Percentuais ( Status e pagamentos )
	Private sValG 	:= 99 //| Status - Green
	Private sValY 	:= 99	//| Status - Yelow
	Private sValR 	:= 99	//| Status - Red

	Private pValG 	:= 99	//| Pagamentos - Green
	Private pValY 	:= 99	//| Pagamentos - Yelow
	Private pValR 	:= 99	//| Pagamentos - Red

	Private lCSug   := .F.	//| Calculado Sugestao

//inicializa
	sValG := Val( Posicione("SX5",1,xFilial("SX5")+"ZPSG","X5_DESCRI") ) //| Status - Green
	sValY := Val( Posicione("SX5",1,xFilial("SX5")+"ZPSY","X5_DESCRI") ) //| Status - Yelow
	sValR := Val( Posicione("SX5",1,xFilial("SX5")+"ZPSR","X5_DESCRI") ) //| Status - Red
	pValG := Val( Posicione("SX5",1,xFilial("SX5")+"ZPPG","X5_DESCRI") ) //| Pagamentos - Green
	pValY := Val( Posicione("SX5",1,xFilial("SX5")+"ZPPY","X5_DESCRI") ) //| Pagamentos - Yelow
	pValR := Val( Posicione("SX5",1,xFilial("SX5")+"ZPPR","X5_DESCRI") ) //| Pagamentos - Red

//| Temporario
	SetKey(VK_F12,{|| Config() })// Apaga um SetKeySetKEY(VK_F12,{||})
//| Variaveis Tela Parametros

	While lContinua

		If lAlter
			WinRefresh()
		Endif

	//| Monta Tela com Parametros
		lcontinua := TelaParametros()

		If Empty(RiscoC) .And. Empty(cCgcCli) .And. lcontinua .And. !lAlter
			Iw_MsgBox("Escolha pelo menos um RISCO.","Atencao","INFO")
			Loop
		Endif

		If lcontinua .And. !lAlter //| Obtem Dados...

			FimLWin := 463

			oProcess := MsNewProcess():New( {|lEnd| ObtemDados(@oProcess, @lEnd)} , "Consultas... ", "", .T. )
			oProcess:Activate()

			If lContinua //| Monta Browse
				MontaBrowse()
			Else
				lContinua := .T.
			EndIf

		EndIf

	EndDo

	SetKey(VK_F12 , { || })

Return()
*********************************************************************
Static Function MontaBrowse() //| CONSTROI JANELA PRINCIPAL
*********************************************************************
//| Informacoes
	Private nNumCom := 0 				//| Numero de Compras
	Private nTotCom := 0 				//| Valor Total das Compras
	Private nNumTit := 0 				//| Numero de Titulos
	Private nTotTit := 0 				//| Valor Total dos Titulos
	Private dCliDes := cTod("  /  /  ")	//| Cliente Desde
	Private dUltCom := cTod("  /  /  ")	//| Data Ultima Compra
	Private nMaiSdl := 0 				//| Valor do Maior Saldo
	Private nMedAtr := 0 				//| Media de Atraso
	Private dUltAse := cTod("  /  /  ")	//| Data Ultima Analise Serasa
	Private cSAvaSe := ""				//| Status da Ultima Avaliacao Serasa

	Private aSAvaSe   := {"0=Nao Avaliado" ,"1=Rest. Pesada","2=Rest. Leve","3=Sem Rest."}	//| Status da Ultima Avaliacao Serasa
	Private aItRisco  := {" ", "B=RISCO B" ,"C=RISCO C","D=RISCO D","E=RISCO E"}
	Private aItClasse := {" ", "A=CLASSE A", "B=CLASSE B", "C=CLASSE C"}

//| Atual
	SetPrvt("cCRiscA,nLimCrA,dVenLCA,cClassA")

//| Sugestao
	Private cCRiscS	:= ""
	Private nLimCrS := 0
	Private dVenLCS := CTOD("")
	Private cClassS := ""

//| NOVOS
	Private cCRiscN	:= " "
	Private nLimCrN := -0.001
	Private dVenLCN := CTOD(" ")
	Private cClassN := " "

//| Observacao
	Private mGetObs

//| Graficos
	Private oGrap_P   	//| Grafico Pizza
	Private oGrap_L		//| Grafico Linhas
	Private nSerieS   	//| Serie Grafico Linhas Saldo
	Private nSerieL		//| Serie Grafico Linhas Limite
	Private nSerieA		//| Serie Grafico Linhas Ano Anterior

	Private nSerieP     //| Serie Grafico Pizza
	Private aGraDesc	:= {"Pontual","Atraso","S. Atrazo"} //| Array Descricao Grafixo Pizza
	Private aGraCors	:= {CLR_HGREEN,CLR_YELLOW,CLR_HRED} //| Array Cores Grafico Pizza
	Private oFontGra	:= TFont():New( "Arial",,14,,.F.)

	Private cTextoSu
	Private cTextoGL
	Private cTextoGP

//| Browse
	Private oWTBrowse
	Private aDadosBw 	:= {}

//| Objetos
	Static oDlg
	Static oSay_All
	Static oGro_All
	Static oGet_All
	Static oMGObs
	Static oButton
	Static oGLButton
	Static oGPButton
	Static oSUButton
	Static oComboxA
	Static oComboxS
	Static oComboxN
	Static oCombocA
	Static oCombocS
	Static oCombocN
	Static oComboSe
	Static oAplButton

//| Teste Botao Imagem
	Private cBmpLupa	:= "SDUSEEK.PNG"//"GRAF3D_MDI.PNG"
	Private cBmpSuge	:= "BMPTRG_MDI.PNG"
	Private cBmpRigth	:= "RIGHT_MDI.PNG"


	oDlg :=	TDialog():New(007,000,730,800,'Analise de CrÈdito  --  '+cValToChar(nCliFilt)+' Cliente(s) -- Periodo 18 Meses [ '+cValToChar(DPInic)+' <-> '+cValToChar(DPFina)+' ] ' 	,,,,nOr( DS_MODALFRAME, WS_DLGFRAME ),CLR_BLACK,CLR_WHITE,,,.T.)

//| INFORMACOES
	@ 022, 245 SAY oSay_All	PROMPT "N.  Compras:"		SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 022, 322 SAY oSay_All	PROMPT "VT. Compras:" 		SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL

	@ 042, 245 SAY oSay_All PROMPT "N.  Titulos:" 		SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 042, 322 SAY oSay_All PROMPT "VT. Titulos:" 		SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL

	@ 062, 245 SAY oSay_All PROMPT "Cli.  Desde:"		SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 062, 322 SAY oSay_All PROMPT "Ult. Compra:" 		SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL

	@ 082, 245 SAY oSay_All PROMPT "Maior Saldo:" 		SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 082, 322 SAY oSay_All PROMPT "Med. Atraso:" 		SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL

	@ 102, 245 SAY oSay_All PROMPT "U.A. Serasa:" 		SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 102, 322 SAY oSay_All PROMPT "Stat.Serasa:" 		SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL

//| GROUPS
	@ 005, 240 GROUP oGro_All 	TO 122, 395 PROMPT "Informacoes" 	OF oDlg COLOR 0, 16777215 PIXEL
	@ 236, 005 GROUP oGro_All 	TO 322, 235 PROMPT "" 				OF oDlg COLOR 0, 16777215 PIXEL
	@ 325, 005 GROUP oGro_All 	TO 348, 395 PROMPT "" 				OF oDlg COLOR 0, 16777215 PIXEL

//| INFORMACOES CAMPOS
	@ 020, 280 MSGET oGet_All 	VAR nNumCom 	SIZE 035, 010 OF oDlg 	PICTURE '@E 999,999,999'	COLORS 0, 16777215 READONLY PIXEL
	@ 020, 355 MSGET oGet_All 	VAR nTotCom 	SIZE 035, 010 OF oDlg 	PICTURE '@E 999,999,999.00'	COLORS 0, 16777215 READONLY PIXEL

	@ 040, 280 MSGET oGet_All 	VAR nNumTit 	SIZE 035, 010 OF oDlg 	PICTURE '@E 999,999,999'	COLORS 0, 16777215 READONLY PIXEL
	@ 040, 355 MSGET oGet_All 	VAR nTotTit 	SIZE 035, 010 OF oDlg 	PICTURE '@E 999,999,999.00'	COLORS 0, 16777215 READONLY PIXEL

	@ 060, 280 MSGET oGet_All 	VAR dCliDes 	SIZE 035, 010 OF oDlg 	 							COLORS 0, 16777215 READONLY PIXEL
	@ 060, 355 MSGET oGet_All 	VAR dUltCom		SIZE 035, 010 OF oDlg 								COLORS 0, 16777215 READONLY PIXEL

	@ 080, 280 MSGET oGet_All 	VAR nMaiSdl 	SIZE 035, 010 OF oDlg 	PICTURE '@E 999,999,999.00'	COLORS 0, 16777215 READONLY PIXEL
	@ 080, 355 MSGET oGet_All 	VAR nMedAtr 	SIZE 035, 010 OF oDlg 	PICTURE '@E 999,999,999'	COLORS 0, 16777215 READONLY PIXEL

	@ 100, 280 MSGET oGet_All 	VAR dUltAse 	SIZE 035, 010 OF oDlg 	PICTURE '' 					COLORS 0, 16777215 PIXEL

	oComboSe := TComboBox():New(100,355,{|u| if(Pcount()>0,cSAvaSe:=u,cSAvaSe)},aSAvaSe,035,010,oDlg,,,,,,.T.,,,,,,,,,'cSAvaSe' )

	@ 251, 040 GROUP oGro_All 	TO 321, 105 PROMPT "" 				OF oDlg COLOR 0, 16777215 PIXEL
	@ 251, 105 GROUP oGro_All 	TO 321, 170 PROMPT "" 				OF oDlg COLOR 0, 16777215 PIXEL
	@ 251, 170 GROUP oGro_All 	TO 321, 234 PROMPT "" 				OF oDlg COLOR 0, 16777215 PIXEL


	@ 240, 060 SAY oSay_All PROMPT "ATUAL" 		SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 240, 123 SAY oSay_All PROMPT "SUGESTAO" 	SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 240, 191 SAY oSay_All PROMPT "NOVO"		SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL

	@ 258, 015 SAY oSay_All PROMPT "RISCO:" 	SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 275, 015 SAY oSay_All PROMPT "LIMITE:" 	SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 292, 015 SAY oSay_All PROMPT "VENCTO:"	SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 309, 015 SAY oSay_All PROMPT "CLASSE:" 	SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL

//| ATUAL CAMPOS
	oComboxA := TComboBox():New(256,050,{|u| if(Pcount()>0,cCRiscA:=u,cCRiscA)},aItRisco,045,010,oDlg,,,,,,.T.,,,,,,,,,'cCRiscA' )
	@ 273, 050 MSGET oGet_All 	VAR nLimCrA 	SIZE 045, 010 OF oDlg 	PICTURE '@E 999,999,999.00' COLORS 0, 16777215 READONLY HASBUTTON PIXEL
	@ 290, 050 MSGET oGet_All 	VAR dVenLCA 	SIZE 045, 010 OF oDlg 	PICTURE '@!' COLORS 0, 16777215 READONLY HASBUTTON PIXEL
	oCombocA := TComboBox():New(307,050,{|u| if(Pcount()>0,cClassA:=u,cClassA)},aItClasse,045,010,oDlg,,,,,,.T.,,,,,,,,,'cClassA' )

//| SUGESTAO CAMPOS
	oComboxS := TComboBox():New(256,115,{|u| if(Pcount()>0,cCRiscS:=u,cCRiscS)},aItRisco,045,010,oDlg,,,,,,.T.,,,,,,,,,'cCRiscS' )
	@ 273, 115 MSGET oGet_All 	VAR nLimCrS 	SIZE 045, 010 OF oDlg 	PICTURE '@E 999,999,999.00' COLORS 0, 16777215 READONLY PIXEL
	@ 290, 115 MSGET oGet_All 	VAR dVenLCS 	SIZE 045, 010 OF oDlg 	PICTURE '@!' COLORS 0, 16777215 READONLY PIXEL
	oCombocS := TComboBox():New(307,115,{|u| if(Pcount()>0,cClassS:=u,cClassS)},aItClasse,045,010,oDlg,,,,,,.T.,,,,,,,,,'cClassS' )
	oComboxS:SetItems( { " " } )
	oCombocS:SetItems( { " " } )

//| NOVOS CAMPOS
	oComboxN := TComboBox():New(256,180,{|u| if(Pcount()>0,cCRiscN:=u,cCRiscN)},aItRisco,045,010,oDlg,,,,,,.T.,,,,,,,,,'cCRiscN' )
	@ 273, 180 MSGET oGet_All 	VAR nLimCrN 	SIZE 045, 010 OF oDlg	PICTURE '@E 999,999,999.00' COLORS 0, 16777215 PIXEL
	@ 290, 180 MSGET oGet_All 	VAR dVenLCN 	SIZE 045, 010 OF oDlg 	PICTURE '@!' COLORS 0, 16777215 PIXEL
	oCombocN := TComboBox():New(307,180,{|u| if(Pcount()>0,cClassN:=u,cClassN)},aItClasse,045,010,oDlg,,,,,,.T.,,,,,,,,,'cClassN' )

	@ 236, 239 GET oMGObs VAR mGetObs OF oDlg MULTILINE SIZE 155, 086 COLORS 0, 16777215 HSCROLL PIXEL

	SET MESSAGE OF oDlg COLORS 0, 14215660

	Mnt_TBrowse()//| Monta o Browse
	Mnt_Grafico()//| Monta os graficos

	oGLButton := TBtnBmp2():New(260,430,030,030,cBmpLupa,,,,{|| MostraValGL(cTextoGL)},oDlg,"",{||},,.T. )
	oGPButton := TBtnBmp2():New(260,750,030,030,cBmpLupa,,,,{|| MostraValGL(cTextoGP)},oDlg,"",{||},,.T. )

	@ 007, 005 BUTTON oButton PROMPT "X"  			ACTION {|| MarkAll() 								}	SIZE 009, 011 OF oDlg PIXEL
	@ 007, 013 BUTTON oButton PROMPT "C" 	   		ACTION {|| OpenCadCli()								}	SIZE 009, 011 OF oDlg PIXEL
	@ 007, 204 BUTTON oButton PROMPT "FILTRO" 		ACTION {Iif(!FiltraLeg()	, oDlg:End(), ''	) 	}	SIZE 022, 011 OF oDlg PIXEL

//| lupa Sugestao e Seta Novo
	oSUButton 	:= TBtnBmp2():New(472,215,030,030,cBmpSuge ,,,,{|| MostraValGL(cTextoSu)}	,oDlg,"",{||},,.T. )
	oAplButton 	:= TBtnBmp2():New(472,305,030,030,cBmpRigth,,,,{|| AplicaSug()}				,oDlg,"",{||},,.T. )


	@ 329, 050 BUTTON oButton PROMPT "Email" 		ACTION {|| DadosEmail() 							}	SIZE 045, 015 OF oDlg PIXEL
	@ 329, 115 BUTTON oButton PROMPT "Sugestao"		ACTION {|| TrataSugest() 							}	SIZE 045, 015 OF oDlg PIXEL
	@ 329, 180 BUTTON oButton PROMPT "Atualizar"  	ACTION { Iif(!FAtuCli()  	, oDlg:End(), '' 	)	}	SIZE 045, 015 OF oDlg PIXEL

	@ 329, 290 BUTTON oButton PROMPT "Salvar" 		ACTION { FSalvaObs()								}	SIZE 045, 015 OF oDlg PIXEL
	@ 329, 345 BUTTON oButton PROMPT "Sair" 	 	ACTION { lcontinua:=.F.	 	, oDlg:End()         	}	SIZE 045, 015 OF oDlg PIXEL

	oDlg:Activate(,,,.T.,{|| !lcontinua },, )

Return()
*********************************************************************
Static Function DadosEmail() 	//| Envia Dados por Email ....
*********************************************************************
	Local lRet  := .T.
	Local cHtml := ""
	Local cNoArqGL := 'gl_'+aDadosBw[oWTBrowse:nAt,CNPJ]+'_'+dToS(ddatabase) +'_'+StrTran (time(),':','.')+'.jpeg'
	Local cNoArqGP := 'gp_'+aDadosBw[oWTBrowse:nAt,CNPJ]+'_'+dToS(ddatabase) +'_'+StrTran (time(),':','.')+'.jpeg'

	Private cTo	   := ""
	private cObs   := ""
	Private lEnvia := .T.

//| Salva os Graficos em jpeg
	oGrap_L:SetFocus()
	lRet := oGrap_L:SaveToImage(cNoArqGL,'/imgweb/','JPEG')

	oGrap_P:SetFocus()
	lRet := oGrap_P:SaveToImage(cNoArqGP,'/imgweb/','JPEG')

//| Busca Destinatarios...
	cTo  := Posicione("SA3",1,xFilial('SA3')+SA1->A1_VENDEXT,"A3_EMAIL")
	cBcc := Posicione("SA3",1,xFilial('SA3')+SA1->A1_GERVEN ,"A3_EMAIL")

	If !Empty(cTo)
		cTo := Alltrim(cTo)
		if !Empty(cBcc)
			cTo += "," + Alltrim(cBcc)
		EndIf
	EndIf
	cTo := cTo + Space(256)

//| Apresenta Tela de Observacao
	cObs := Obs_mail()

//| Monta o Html do email
	cHtml := MontaHtml(@cHtml , cNoArqGL , cNoArqGP )//| Monta Html

//| Testa se deve enviar ...
	If lEnvia
		U_EnvMyMail("",cTo,"","Reanalise de CrÈdito",cHtml,'')//| U_EnvMyMail(De, Para, Copia, Assunto, Corpo, Anexo )
		Iw_MsgBox("Email Enviado com Sucesso!!!","","INFO")
	Else
		Iw_MsgBox("Email Cancelado!!!","","INFO")
	EndIf

Return()
*********************************************************************
Static Function Obs_mail( cquery )
*********************************************************************
//__cFileLog := MemoWrite(Criatrab(,.F.)+".log",cquery)
	Local cObs := ""
	Static oSay_mail
	Static oGet_mail

	Define FONT oFont NAME "Tahoma" Size 6,12
	Define MsDialog oDlgMemo Title "Observacao Email." From 3,0 to 340,550 Pixel

	@ 03, 05 SAY 	oSay_mail 	Prompt "Destinat·rios:" Size 100, 007 	Of oDlgMemo COLORS 0, 16777215 Pixel
	@ 10, 05 MSGET 	oGet_mail 	Var cTo	 				Size 265, 010 	Of oDlgMemo COLORS 0, 16777215 Pixel
	@ 23, 05 SAY 	oSay_mail 	Prompt "ObservaÁ„o:" 	Size 040, 007 	Of oDlgMemo COLORS 0, 16777215 Pixel
	@ 30, 05 Get 	oMemo  		Var cObs MEMO 			Size 265, 115 	Of oDlgMemo Pixel

	oMemo:bRClicked := {||AllwaysTrue()}
	oMemo:oFont:=oFont

	Define SButton  From 153,215 Type 1 Action oDlgMemo:End() Enable Of oDlgMemo Pixel
	Define SButton  From 153,245 Type 2 Action {|| lEnvia:=.F. , oDlgMemo:End()} Enable Of oDlgMemo Pixel

	Activate MsDialog oDlgMemo Center

Return(cObs)
*********************************************************************
Static Function AplicaSug() 	//| Aplica Sugestao de CrÈdito
*********************************************************************

	cCRiscN	:= cCRiscS
	nLimCrN := nLimCrS
	dVenLCN := dVenLCS
	cClassN := cClassS

Return()
*********************************************************************
Static Function TrataSugest()  //| Tratamento Sugestoes
*********************************************************************

	If U_ISugCred()
		Processa( { || CalcSugest(.T.) },'Aguarde','Recalculando Sugestıes...' )
	EndIf

Return()
*********************************************************************
Static Function CalcSugest(lMen)  //| Calcula Sugestoes
*********************************************************************
	Local cAli_S := "TSUG"
	Local cDriver	:= "CTREECDX"
	Local cArq		:= ""

	Private _cgc	:= ""
	Private _Risco	:= ""
	Private _Limite	:= ""
	Private _Vencto := ""

	Private nPERC_CLD := 0
	Private nPERC_NCO := 0
	Private nPERC_UCO := 0
	Private nPERC_PON := 0
	Private nPERC_SER := 0
	Private nPERC_TOT := 0
	Default lMen := .F.

	If lMen
		ProcRegua(0)
	EndIf

	lCSug := .T.

//| Tabela Sugestoes - TSUG
	aStruct	:= {}
	aAdd ( aStruct, { "CGCRZCLI"	, "C", 14	, 0  } )
	aAdd ( aStruct, { "NVLRISCO"	, "C", 1	, 0  } )
	aAdd ( aStruct, { "LIMICRED"	, "N", 12	, 2  } )
	aAdd ( aStruct, { "VENCTOLM"	, "D", 8	, 2  } )

	aAdd ( aStruct, { "PERC_CLD"	, "C", 5	, 0  } )
	aAdd ( aStruct, { "PERC_NCO"	, "C", 5	, 0  } )
	aAdd ( aStruct, { "PERC_UCO"	, "C", 5	, 0  } )
	aAdd ( aStruct, { "PERC_PON"	, "C", 5	, 0  } )
	aAdd ( aStruct, { "PERC_SER"	, "C", 5	, 0  } )
	aAdd ( aStruct, { "PERC_TOT"	, "C", 5	, 0  } )

	If Select ( cAli_S ) != 0
		DbSelectArea( cAli_S )
		DbCloseArea()
	EndIf

	cArq 	:= CriaTrab(aStruct, .T.)
	DBUseArea( .T., cDriver, cArq, cAli_S, .T., .F. )
	DBCreateIndex(cArq, "CGCRZCLI", { || CGCRZCLI }, .F.)


//| Percorre Todo o Arquivo de Trabalho
	DbSelectArea("TFINAL");DbGotop()
	While !Eof()

		_cgc	:= TFINAL->CGCRZCLI
		_Risco	:= TFINAL->NVLRISCO
		_Limite	:= TFINAL->LIMICRED //MedTopNine() //| Pega a Media de Acumulos em 9 amostras //| TFINAL->LIMICRED
		_Vencto := TFINAL->CVENCLCR


		If lMen
			IncProc()
		EndIf

		VerSugestao()

		DbSelectArea("TSUG")
		RecLock("TSUG", .T.)
		TSUG->CGCRZCLI	:= _cgc
		TSUG->NVLRISCO	:= _Risco
		TSUG->LIMICRED	:= _Limite
		TSUG->VENCTOLM	:= _Vencto

		TSUG->PERC_CLD := cValtoChar(nPERC_CLD)
		TSUG->PERC_NCO := cValtoChar(nPERC_NCO)
		TSUG->PERC_UCO := cValtoChar(nPERC_UCO)
		TSUG->PERC_PON := cValtoChar(nPERC_PON)
		TSUG->PERC_SER := cValtoChar(nPERC_SER)
		TSUG->PERC_TOT := cValtoChar(nPERC_TOT)

		MsUnlock()

		DbSelectArea("TFINAL")
		DbSkip()

	EndDo

	DbSelectArea("TFINAL");DbGotop()

Return()
*********************************************************************
Static Function VerSugestao()  //| Verifica Sugestoes
*********************************************************************

//| Risco x Score
	Local RiscoB := Val( Posicione( "SX5" , 1, xFilial("SX5")+"9Z"+"RXSCOB" ,"X5_DESCRI" ) )
	Local RiscoC := Val( Posicione( "SX5" , 1, xFilial("SX5")+"9Z"+"RXSCOC" ,"X5_DESCRI" ) )
	Local RiscoD := Val( Posicione( "SX5" , 1, xFilial("SX5")+"9Z"+"RXSCOD" ,"X5_DESCRI" ) )
	Local RiscoE := Val( Posicione( "SX5" , 1, xFilial("SX5")+"9Z"+"RXSCOE" ,"X5_DESCRI" ) )
//| Risco x Limite
	Local LimitB := Val( Posicione( "SX5" , 1, xFilial("SX5")+"9Z"+"RXLIMB" ,"X5_DESCRI" ) )
	Local LimitC := Val( Posicione( "SX5" , 1, xFilial("SX5")+"9Z"+"RXLIMC" ,"X5_DESCRI" ) )
	Local LimitD := Val( Posicione( "SX5" , 1, xFilial("SX5")+"9Z"+"RXLIMD" ,"X5_DESCRI" ) )
	Local LimitE := Val( Posicione( "SX5" , 1, xFilial("SX5")+"9Z"+"RXLIME" ,"X5_DESCRI" ) )
//| Risco x Vencimento
	Local VenctB := Val( Posicione( "SX5" , 1, xFilial("SX5")+"9Z"+"RXVENB" ,"X5_DESCRI" ) )
	Local VenctC := Val( Posicione( "SX5" , 1, xFilial("SX5")+"9Z"+"RXVENC" ,"X5_DESCRI" ) )
	Local VenctD := Val( Posicione( "SX5" , 1, xFilial("SX5")+"9Z"+"RXVEND" ,"X5_DESCRI" ) )
	Local VenctE := Val( Posicione( "SX5" , 1, xFilial("SX5")+"9Z"+"RXVENE" ,"X5_DESCRI" ) )


	nPercentual := MntPercTot() //| Retorna o Percentual Que o Cliente Atingiu

//| Qual o Risco x Score ira ser Sugerido Baseado no Percentual que o Cliente Atingiu
	If nPercentual >= RiscoB

		_Limite	:= MedTopNine(6) //| Pega a Media de Acumulos em 9 amostras

		_Risco	:=  "B" //| TFINAL->NVLRISCO
		_Limite	:= ( Round(( _Limite * (( 100 + LimitB ) / 100 )) / ARREDONDA , 0 ) * ARREDONDA ) //|
		_Vencto := _Vencto + VenctB

	ElseIf nPercentual >= RiscoC

		_Limite	:= MedTopNine(9) //| Pega a Media de Acumulos em 9 amostras

		_Risco	:=  "C" //| TFINAL->NVLRISCO
		_Limite	:= ( Round(( _Limite * (( 100 + LimitC ) / 100 )) / ARREDONDA , 0 ) * ARREDONDA ) //|
		_Vencto := _Vencto + VenctC

	ElseIf nPercentual >= RiscoD

		_Limite	:= MedTopNine(9) //| Pega a Media de Acumulos em 9 amostras

		_Risco	:=  "D" //| TFINAL->NVLRISCO
		_Limite	:= ( Round(( _Limite * (( 100 + LimitD ) / 100 )) / ARREDONDA , 0 ) * ARREDONDA ) //|
		_Vencto := _Vencto + VenctD

	ElseIf nPercentual < RiscoE

		_Limite	:= MedTopNine() //| Pega a Media de Acumulos em 9 amostras

		_Risco	:=  "E" //| TFINAL->NVLRISCO

		If (LimitE == -50)
			_Limite	:= 0
		Else
			_Limite	:= ( Round(( _Limite * (( 100 + LimitE ) / 100 )) / ARREDONDA , 0 ) * ARREDONDA ) //|
		EndIf

		If (VenctE == -1 )
			_Vencto := cTod("01/01/2000")
		Else
			_Vencto := _Vencto +VenctE
		EndIf

	Endif

Return()
*********************************************************************
Static Function MntPercTot()  //| Retorna o Percentual Que o Cliente Atingiu
*********************************************************************
	Local Segmento 		:= ""

	nPERC_TOT 			:= 0

	Segmento := TFINAL->SEGMENTO //Posicione( "SA1" , 3, xFilial("SA1")+_cgc ,"A1_GRPSEG" ); //|

//| Cliente Desde
	nPERC_TOT += nPERC_CLD := RetPercPar(Segmento, "CD", DtoAno(TFINAL->CDPRICOM) )	//DtoDias(TFINAL->CDPRICOM) 	//:= STOD(TBASE->CDPRICOM)

//| Numero de Compras
	nPERC_TOT += nPERC_NCO := RetPercPar(Segmento, "NC", TFINAL->NCOMPRAS ) 			// TFINAL->NCOMPRAS 	//:= TBASE->NCOMPRAS

//| Ultima Compra
	nPERC_TOT += nPERC_UCO := RetPercPar(Segmento, "UC", DToDias(TFINAL->ULTRCOMP) ) // DToDias(TFINAL->ULTRCOMP) 	//:= STOD(TBASE->ULTRCOMP)

//| Pontualidade
	nPERC_TOT += nPERC_PON := RetPercPar(Segmento, "PO",  TFINAL->STATUSPG ) 			// TFINAL->PPONTUAL 	// := TBASE->PPONTUAL

//| Serasa
	nPERC_TOT += nPERC_SER := RetPercPar(Segmento, "SE", 0 ) 							//TFINAL->CVENCLCR 	//| := STOD(TBASE->CVENCLCR)


Return(nPERC_TOT)
*********************************************************************
Static Function MedTopNine(nAmostras) //| Pega a Media de Acumulos em 9 amostras
*********************************************************************
	Local aTopNine 	:= {}
	Local nMedia	:= 0

	DbSelectArea("TSALDO");DbGotop()
	DbSeek(TFINAL->CLCLIENT,.F.)
	While TFINAL->CLCLIENT == TSALDO->CLIENTE

		Aadd(aTopNine , TSALDO->ACUMULO)

		DbSelectArea("TSALDO")
		DbSkip()
	EndDo

//aSort()
	Default nAmostras = Len(aTopNine)

	ASort(aTopNine,,, {|x,y|x > y})

	If Len(aTopNine) < nAmostras //| AJUSTE POS BUILD
		nAmostras := Len(aTopNine)
	EndIf

	For n:= 1 To nAmostras

		nMedia += aTopNine[n]

	Next

	nMedia := Round( nMedia / nAmostras , 0)

Return(nMedia)
*********************************************************************
Static Function DtoAno(dData) //| Data para Ano
*********************************************************************
	Local nDias

	nDias := dDatabase - dData

Return(NoRound((nDias/365),0))
*********************************************************************
Static Function DtoDias(dData)//| Data para Dia
*********************************************************************
	Local nDias

	nDias := dDatabase - dData

Return(nDias)
*********************************************************************
Static Function RetPercPar(Segmento, Tipo, Valor)  //| Retorna Percentual em Relacao aos Parametros no Segmento e Seus Pesos
*********************************************************************
	Local nMinimo := 0
	Local nMaximo := 0
	Local nFator  := 0
	Local nPerc


	DbSelectArea("ZZV")
	DbSeek(xFilial("ZZV")+Segmento,.F.)

	If Tipo == "CD" //| Cliente Desde
		nMinimo := ZZV_CLDMIN
		nMaximo := ZZV_CLDMAX

	ElseIf Tipo == "NC" //| Numero Compras
		nMinimo := ZZV_NCOMIN
		nMaximo := ZZV_NCOMAX

	ElseIf Tipo == "UC" //| Ultima Compra
		nMinimo := ZZV_UCOMIN
		nMaximo := ZZV_UCOMAX

	ElseIf Tipo == "PO" //| Pontualidade
		nMinimo := ZZV_PONMIN
		nMaximo := ZZV_PONMAX

	ElseIf Tipo == "SE" //| Serasa
		nMinimo := ZZV_SERMIN
		nMaximo := ZZV_SERMAX

	EndIf

	If Tipo == "UC"
		If Valor <= nMaximo
			nPerc := 100
		Elseif Valor >= nMinimo
			nPerc := 0
		Else
			nPerc := Round(100 - (100/(nMinimo - nMaximo)) * (Valor - nMaximo),2)  //
		EndIf
	Else
		If Valor <= nMinimo
			nPerc := 0
		Elseif Valor >= nMaximo
			nPerc := 100
		Else
			nPerc := Round(Valor * 100 / nMaximo , 2)
		EndIf
	EndIf

// Aplica o Peso referente - PESOCD , PESONC , PESOUC , PESOPO , PESOSE
	nFator 	:= Val ( Posicione( "SX5" , 1, xFilial("SX5")+"9Z"+"PESO"+Tipo ,"X5_DESCRI" ) )

	nPerc 	:= Round( nFator / 100 * nPerc, 2)

Return nPerc
*********************************************************************
Static Function FSalvaObs()  // Atualiza Cadastro de Clientes
*********************************************************************
	If Empty(dToc(dUltAse)) .Or. cSAvaSe == "0" // Nao Avaliado
		IW_MsgBox("Avaliar Serasa do Cliente Antes de Salvar !!!!","Atencao","ALERT")
		Return()
	EndIf

	DbSelectArea("SA1")
	If DbSeek(xFilial("SA1")+aDadosBw[oWTBrowse:nAt][CODIGO],.F.)
		RecLock("SA1",.F.)
		SA1->A1_OBSCREM := mGetObs
		SA1->A1_DREACRE := dUltAse
		SA1->A1_STATSER := cSAvaSe
		Msunlock()

		IW_MsgBox("Salvo com Sucesso...","Atencao","INFO")
	EndIf

Return()
*********************************************************************
Static Function FAtuCli()  // Atualiza Cadastro de Clientes
*********************************************************************
	Local nCont 	:= 0
	Local nTamA 	:= Len(aDadosBw)
	Local lSegue 	:= .T.
	Local nCliAt	:= 0
	Local lValSer   := .T.

	DbSelectArea("SA1")

	If (!IW_MsgBox("Confirma a AtualizaÁ„o do(s) Cliente(s) ?","AtenÁ„o","YESNO") )//Deseja Efetuar a Atualiz"))
		IW_MsgBox("Nenhum Cliente foi Atualizado...","Atencao","INFO")
		Return(lContinua)
	EndIf

	while lSegue //| Percorre Todo Array
		nCont ++

		If aDadosBw[nCont][MARKB] == .T. //| Registro Marca para Atualizar

			If Empty(dToc(TFINAL->UAVALSER)) .Or. TFINAL->STATASER == "0" // Nao Avaliado
				lValSer  := .F.
				Loop
			EndIf

			If DbSeek(xFilial("SA1")+aDadosBw[nCont][CODIGO],.F.) //| Posiciona No Cadastro do Cliente

				RecLock("SA1",.F.)
				If !Empty(trim(cCRiscN))
					SA1->A1_RISCO 	:= cCRiscN  //| B,C,D,E
				EndIF
				If !( nLimCrN < 0 ) 	//| Valor limite de Credito
					SA1->A1_LC 		:= 	nLimCrN
				EndIf
				If !Empty(trim(cValtoChar(dtos(dVenLCN)))) 	//| Data Vencto Limite de Credito
					SA1->A1_VENCLC 	:= 	dVenLCN
				EndIf
				If !Empty(trim(cClassN))
					SA1->A1_CLASSE	:= cClassN 	//| A,B,C
				EndIf
				Msunlock()

				If !Empty(trim(cCRiscN)) .Or. !( nLimCrN < 0 ) .Or. !Empty(trim(cValtoChar(dtos(dVenLCN)))) .Or. !Empty(trim(cClassN))
					ADel( aDadosBw, nCont ) //| Deleta Registro no Array
					nCliAt ++
					nCont  --
				EndIf

			EndIf
		EndIf
		If nCont == (nTamA - nCliAt)
			lSegue := .F.
		EndIf

	EndDo

	cCRiscN	:= " "
	nLimCrN := -0.001
	dVenLCN := CTOD("")
	cClassN := " "

	oCombocN:SetFocus()
	oCombocN:Select(1)
	oCombocN:refresh()

	If !lValSer // Nao Avaliado
		IW_MsgBox("Avaliar Serasa do(s) Cliente(s) Antes de Salvar !!!!","Atencao","ALERT")
	EndIf

	if (nCliAt == 0)
		IW_MsgBox("Nenhum Cliente foi Atualizado...","Atencao","INFO")
	Else
		IW_MsgBox(cValToChar(nCliAt)+" Cliente(s) Atualizado(s)...","Atencao","INFO")
	EndIF

	nTamA -= nCliAt
	ASize(aDadosBw, nTamA )
	if ( nTamA == 0 )
		lContinua := .F.
		IW_MSGBOX("Nao Existem mais Clientes no Filtro!!!","Atencao","INFO")
	EndIf

Return(lContinua)
*********************************************************************
Static Function Mnt_TBrowse()  // MONTA O BROWSE
*********************************************************************
	Local oOk := LoadBitmap( GetResources(), "LBOK")
	Local oNo := LoadBitmap( GetResources(), "LBNO")

	Local aCabec 		:= { " " , " " , "RISCO" , "SEG" , "CNPJ" , "CODIGO" , "NOME" }
	Local aColSizes 	:= {  20 ,  20 ,   20    ,  20   ,    30  ,  30      ,  100   }
	Local bLine 		:= Nil
	LocaL cField		:= Nil
	Local uValue		:= Nil
	Local bChange 		:= {|| {   AtuDados() } }
	Local bLDblClick 	:= {|| aDadosBw[oWTBrowse:nAt,MARKB] := !aDadosBw[oWTBrowse:nAt,MARKB],oWTBrowse:DrawSelect()}
	Local bRClick		:= {||}//{|| { OpenCadCli() } }
	Local bWhen   		:= Nil
	Local bValid        := Nil
	Local lHScroll      := Nil
	Local lVScroll      := Nil
	Local lPixel		:= .T.
	Local cAlias		:= Nil
	Local uParam		:= .F.
	Local oAuxStat

	Local oVD := LoadBitmap(GetResources(),'br_verde'		)
	Local oAM := LoadBitmap(GetResources(),'br_amarelo'		)
	Local oVM := LoadBitmap(GetResources(),'br_vermelho'	)

	DbSelectArea("TFINAL");DbGotop()
	While !EOF()

		If TFINAL->STATUSPG >= sValG
			oAuxStat := oVD
		ElseIf TFINAL->STATUSPG >= sValY
			oAuxStat := oAM
		Else
			oAuxStat := oVM
		EndIf

		Aadd(aDadosBw, {.F., oAuxStat, TFINAL->NVLRISCO, TFINAL->SEGMENTO, TFINAL->CGCRZCLI,  TFINAL->CLCLIENT, TFINAL->CNOMECLI } )

		DbSelectArea("TFINAL")
		DbSkip()

	EndDo

	oWTBrowse 	:= 	TCBrowse():New	( 007 , 005 , 230 , 115 , bLine , aCabec , aColSizes , oDlg , cField , uValue , uValue , bChange , bLDblClick , bRClick , oFontGra , uValue , uValue , uValue , uValue ,uParam  , cAlias , lPixel , bWhen ,uParam  , bValid , lHScroll , lVScroll )

	oWTBrowse:SetArray(aDadosBw)

	oWTBrowse:bLine := {|| { If(aDadosBw[oWTBrowse:nAt,MARKB],oOK,oNO) , aDadosBw[oWTBrowse:nAt,LEGEND] , aDadosBw[oWTBrowse:nAt,RISCO] ,  aDadosBw[oWTBrowse:nAt,SEGCLI] , Transform( aDadosBw[oWTBrowse:nAT,CNPJ] , '@R 99.999.999/9999.99' ) , aDadosBw[oWTBrowse:nAt,CODIGO] , aDadosBw[oWTBrowse:nAt,NOME] } }

Return()
*********************************************************************
Static Function MarkAll()   //| Abri o Cadastro do Cliente para Visualizacao
*********************************************************************

	For n:= 1 To oWTBrowse:nLen

		aDadosBw[n][1] := !aDadosBw[n][1]

	Next

Return()
*********************************************************************
Static Function OpenCadCli()   //| Abri o Cadastro do Cliente para Visualizacao
*********************************************************************
	Private aRotAuto := Nil
	Private	aRotina  := { 	{"Pesquisar","PesqBrw"    	, 0 , 1,0 	,.F.},;	// "Pesquisar"
	{"Visualizar","A030Visual" 	, 0 , 2,0 	,NIL},;	// "Visualizar"
	{"Incluir","A030Inclui" 	, 0 , 3,81	,NIL},;	// "Incluir"
	{"Alterar","A030Altera" 	, 0 , 4,143	,NIL},;	// "Alterar"
	{"Excluir","A030Deleta" 	, 0 , 5,144	,NIL},;	// "Excluir"
	{"Contatos","FtContato"  	, 0 , 4,0 	,NIL}}	// "Contatos"

	DbSelectArea("SA1")
	If DbSeek(xFilial("SA1")+aDadosBw[oWTBrowse:nAt][CODIGO],.F.)

		cFunc := ""
		CCADASTRO := ""
		INCLUI := .F.
		ALTERA := .T.
		A030Altera("SA1",SA1->(Recno()),4)//,,,,,,,,,,,,.T.,,,,,)
	EndIf

Return()
*********************************************************************
Static Function FiltraLeg()//| Executa o Filtro nas Legendas...Conforme as Cores
*********************************************************************
	Local oButton
	Local oButton
	Local oSay
	Local nRadio := 0
	Local aItems := { "","","" }

	Static oGroup
	Static oFlg
	Static oRadio
	Static obrVerde
	Static obrVerme
	Static obrAmare

	DEFINE MSDIALOG oFlg TITLE "Legenda" FROM 000, 000  TO 150, 135 COLORS 0, 16777215 PIXEL

	@ 002, 002 GROUP oGroup 	TO 055, 066 PROMPT "Filtro" OF oFlg COLOR 0, 16777215 PIXEL
	@ 010, 010 SAY oSay1 PROMPT "Escolha a Legenda:" 	SIZE 053, 008 OF oFlg COLORS 0, 16777215 PIXEL

	oRadio := TRadMenu():New( 020 , 040 , aItems ,, oFlg ,,,,,,,, 007 , 050 ,,,, .T. )
	oRadio:bSetGet := {|u| Iif ( PCount()==0 , nRadio , nRadio := u)}

	obrVerde := TBitmap():Create(oFlg,022,021,010,010,,'BR_VERDE.PNG'		,.T.,,,.F.,.F.,,,.F.,,.T.,,.F.)
	obrAmare := TBitmap():Create(oFlg,031,021,010,010,,'BR_AMARELO.PNG'	,.T.,,,.F.,.F.,,,.F.,,.T.,,.F.)
	obrVerme := TBitmap():Create(oFlg,040,021,010,010,,'BR_VERMELHO.PNG'	,.T.,,,.F.,.F.,,,.F.,,.T.,,.F.)

	@ 060, 007 BUTTON oButton1 PROMPT "Filtrar" 	ACTION { AplicaFL(nRadio) , oFlg:End() }	SIZE 025, 012 OF oFlg PIXEL
	@ 060, 037 BUTTON oButton2 PROMPT "Sair"   		ACTION { oFlg:End() } 						SIZE 025, 012 OF oFlg PIXEL

	ACTIVATE MSDIALOG oFlg CENTERED

Return(lcontinua)
*********************************************************************
Static Function AplicaFL(nRadio)   //| Aplica o Filtro Legenda
*********************************************************************
	Local 	nDelet 	:= 0
	Local   nCont	:= 0
	Local 	lDelet	:= .T.
	Local   nTArray := Len(aDadosBw)
	Static 	cLeg	:= ""

	If nRadio == 1
		cLeg := 'br_verde'
	ElseIf nRadio == 2
		cLeg := 'br_amarelo'
	Elseif nRadio == 3
		cLeg := 'br_vermelho'
	EndIf

	If nRadio <> 0

		while lDelet
			nCont ++

			If cLeg <> aDadosBw[nCont][2]:CNAME
				ADel( aDadosBw, nCont )
				lDelet 	:= .T.
				nCont 	:= nCont - 1
				nTArray := nTArray - 1
			EndIf

			If nCont == nTArray
				lDelet := .F.
			EndIf

		EndDo

	Endif

	ASize(aDadosBw, nTArray)

	nCliFilt := nTArray

	if nTArray == 0
		lcontinua := .F.
		IW_MSGBOX("O Filtro nao retornou nehum Registro!!!","Atencao","INFO")
	EndIf

Return(lcontinua)
*********************************************************************
Static Function AtuDados()   //| Atualiza Campos ao Rolar linhas no Browse
*********************************************************************
	Local lStop 	:=.F.
	Local cControl 	:= Substr(dToS(DPInic),1,6)
	Local nValCtro 	:= 0
	Local nCont	 	:= 1 //LIMITGL
	Local lCorte 	:=.F.
	Local dAux

	cTextoSu := ""
	cTextoGL := ""
	cTextoGP := ""


//| Posiciona no Cliente -  Tabela Base Clientes
	DbSelectArea("TFINAL");DbGotop()
	While !lStop .and. !EOF()
		If TFINAL->CGCRZCLI == aDadosBw[oWTBrowse:nAt,CNPJ]
			lStop := .T.
		Else
			DbSkip()
		EndIf
	EndDo

	SA1->(DbSeek(xFilial("SA1")+TFINAL->CLCLIENT,.F.)) //mGetObs := Msmm("SA1->A1_OBSCREM",,,3,,,,)//MemoPosicione("SA1",1, TFINAL->CLCLIENT,"A1_OBSCREM" )

//| INFORMACOES
	nNumCom := TFINAL->NCOMPRAS		//| Numero de Compras
	nTotCom := TFINAL->VALORFAT   	//| Valor Total das Compras
	nNumTit := TFINAL->NTITULOS		//| Numero de Titulos
	nTotTit := Round( TFINAL->VPONTUAL + TFINAL->VATRASOA + TFINAL->VATRASOB , 2 ) //| Valor Total dos Titulos
	dCliDes := TFINAL->CDPRICOM 	//| Cliente Desde
	dUltCom := TFINAL->ULTRCOMP		//| Data Ultima Compra
	nMaiSdl := TFINAL->MAISALDO		//| Valor do Maior Saldo
	nMedAtr := Round( TFINAL->DIASATRA / TFINAL->NTITULOS , 0 ) //| Media de Atraso
	dUltAse := TFINAL->UAVALSER 	//| Data Ultima Analise Serasa
	cSAvaSe := TFINAL->STATASER

//| ATUAL
	cCRiscA	:= TFINAL->NVLRISCO
	nLimCrA := TFINAL->LIMICRED
	dVenLCA := TFINAL->CVENCLCR
	cClassA := TFINAL->CCLASSRI
	oComboxA:SetItems( { cCRiscA + "=RISCO "+ cCRiscA } )
	oCombocA:SetItems( { cClassA + "=CLASSE "+ cClassA } )

//| SUGESTAO
	If lCSug

		TSUG->(DbSeek(TFINAL->CGCRZCLI,.F.))
		cCRiscS	:= TSUG->NVLRISCO
		nLimCrS := TSUG->LIMICRED
		dVenLCS := TSUG->VENCTOLM
		cClassS := TFINAL->CCLASSRI
		oComboxS:SetItems( { cCRiscS + "=RISCO "+ cCRiscS } )
		oCombocS:SetItems( { cClassA + "=CLASSE "+ cClassA } )

		cTextoSu := ""
		cTextoSu += "Cliente Desde : " +TSUG->PERC_CLD 	+" %" + ENTER
		cTextoSu += "Num.  Compras : " +TSUG->PERC_NCO 	+" %" + ENTER
		cTextoSu += "Ultima Compra : " +TSUG->PERC_UCO	+" %" + ENTER
		cTextoSu += "Pontualidade  : " +TSUG->PERC_PON 	+" %" + ENTER
		cTextoSu += "Serasa        : " +TSUG->PERC_SER 	+" %" + ENTER
		cTextoSu += "-------------------------"   		  	  + ENTER
		cTextoSu += "Total         : " +TSUG->PERC_TOT 	+" %" + ENTER

	EndIf
//| NOVOS
	cCRiscN	:= " "
	nLimCrN := -0.001
	dVenLCN := CTOD("")
	cClassN := " "

	oCombocN:SetFocus()
	oCombocN:Select(1)
	oCombocN:refresh()




//| OBS SERASA
	mGetObs := SA1->A1_OBSCREM //MSMM( TFINAL->CLCLIENT , , , , 3 , , ,"SA1","A1_OBSCREM")

//| ATUALIZA GRAFICO LINHAS
	FreeObj(oGrap_L)
	oGrap_L	:= 	TMSGraphic():New( 124, 001, oDlg, oFontGra, RGB(0,0,0), RGB(255,255,255), 238, 110 )
	oGrap_L:l3D := .T.
	oGrap_L:SetTitle('Historico de Saldo',, RGB(0,0,0), A_CENTER , .F. )
	oGrap_L:SetMargins(2,15,2,10)
	oGrap_L:SetLegenProp(GRP_SCRRIGHT, CLR_LIGHTGRAY, GRP_AUTO,.F.)

	If ( TFINAL->MAISALDO > TFINAL->LIMICRED ) //| Defini o Maximo Valor do Grafico
		oGrap_L:SetRangeY( 0 , Round(TFINAL->MAISALDO + (TFINAL->MAISALDO / 9),0) , Round( ( TFINAL->MAISALDO / 10 ) , 0) )
	Else
		oGrap_L:SetRangeY( 0 , Round(TFINAL->LIMICRED + (TFINAL->LIMICRED / 9),0) , Round( ( TFINAL->LIMICRED / 10 ) , 0) )
	Endif

	nSerieL := oGrap_L:CreateSerie	( GRP_LINE ,'Limite'	, , .F. )
	nSerieS := oGrap_L:CreateSerie	( GRP_LINE ,'Saldo' 	, , .F. )
	nSerieA := oGrap_L:CreateSerie	( GRP_LINE ,'Corte'		, , .F. )


//| INSERE DADOS GRAFICO LINHAS
	DbSelectArea("TSALDO");DbGotop()
	DbSeek(TFINAL->CLCLIENT,.F.)
	While nCont <= LIMITGL
		Alert("cControl: " + cValToChar(cControl) + " == TSALDO->MES: "+cValToChar(TSALDO->MES)   )
		If cControl == TSALDO->MES .And. TFINAL->CLCLIENT == TSALDO->CLIENTE

			nValCtro := Round(TSALDO->ACUMULO,0)

			dAux := StoD(TSALDO->MES+"01")

			DbSelectArea("TSALDO")
			DbSkip()
		Else
			nValCtro := Round(0,0)
			dAux := StoD(cControl+"01")
		Endif

		cTextoGL += Substr(CMonth(dAux),1,3) +"/"+ StrZero(Year(dAux),4) + " - R$" + Transform( nValCtro, "@E 999,999.99" ) + ENTER

		oGrap_L:Add( nSerieL, TFINAL->LIMICRED 	, , CLR_HBLUE	)
		oGrap_L:Add( nSerieS, nValCtro 			, , CLR_HRED	)

	//| Desenha Serie Corte
		If cControl == Substr(dToS(dDataBase-365),1,6)
			oGrap_L:Add( nSerieA, ( -1000)	, , RGB(0,255,255)	)
			lCorte := .T.

		Elseif !lCorte // cControl == Substr(dToS(dDataBase-395),1,6)
			oGrap_L:Add( nSerieA, (100000)	, , RGB(0,255,255)	)

		Endif

		cControl := Substr(DToS(STod(cControl+'01')+32),1,6)

		nCont += 1

	EndDo

//| ATUALIZA GRAFICO PIZZA
	FreeObj(oGrap_P)
	oGrap_P 	:= 	TMSGraphic():New( 124 , 234 , oDlg , oFontGra , RGB(0,0,0) , RGB(255,255,255) , 165 , 110 )
	oGrap_P:l3D := .F.
	nSerieP 	:= oGrap_P:CreateSerie( GRP_PIE ,  , 0 , .F. ) //| GRP_PIE = 10

	oGrap_P:SetTitle		( 'Pagamentos' 	, , RGB(0,0,0) , A_CENTER , .F. )
	oGrap_P:SetMargins		( 2	, 10 , 2 , 10 )
	oGrap_P:SetLegenProp	( GRP_SCRRIGHT 	, CLR_LIGHTGRAY , GRP_AUTO , .T. )

//| INSERE DADOS NO GRAFICO PIZZA
	nValTotal := ( TFINAL->VPONTUAL + TFINAL->VATRASOA + TFINAL->VATRASOB )
	nVPontual := Round( ( TFINAL->VPONTUAL / nValTotal ) * 100 , 1 )
	nVAtrasoA := Round( ( TFINAL->VATRASOA / nValTotal ) * 100 , 1 )
	nVAtrasoB := Round( ( TFINAL->VATRASOB / nValTotal ) * 100 , 1 )

	cTextoGP += "Pontual :" + " R$" + Transform( TFINAL->VPONTUAL	, "@E 999,999.99" ) + ENTER
	cTextoGP += "AtrasoA :" + " R$" + Transform( TFINAL->VATRASOA	, "@E 999,999.99" ) + ENTER
	cTextoGP += "AtrasoB :" + " R$" + Transform( TFINAL->VATRASOB	, "@E 999,999.99" ) + ENTER
	cTextoGP += "----------------------" + ENTER
	cTextoGP += "Total   :" + " R$" + Transform( nValTotal			, "@E 999,999.99" ) + ENTER


	oGrap_P:Add( nSerieP, nVPontual , cValtoChar(nVPontual) + " %", aGraCors[1]	) //aGraDesc[1]  , aGraCors[1]	)
	oGrap_P:Add( nSerieP, nVAtrasoA , cValtoChar(nVAtrasoA) + " %", aGraCors[2]	) //aGraDesc[2] , aGraCors[2]	)
	oGrap_P:Add( nSerieP, nVAtrasoB , cValtoChar(nVAtrasoB) + " %", aGraCors[3]	)//aGraDesc[3] , aGraCors[3]	)

//| REFRESH
	oSay_All:SetFocus()
	oSay_All:refresh()

	oGro_All:SetFocus()
	oGro_All:refresh()

	oGet_All:SetFocus()
	oGet_All:refresh()

	oDlg:SetFocus()
	oDlg:refresh()

	oGLButton:End() //| Metodo Destrutor
	oGPButton:End() //| Metodo Destrutor

//| Esta Aqui para Ficar acima do Objeto Grafico
	oGLButton := TBtnBmp2():New(260,430,030,030,cBmpLupa,,,,{|| MostraValGL(cTextoGL)},oDlg,"",{||},,.T. )
	oGPButton := TBtnBmp2():New(260,750,030,030,cBmpLupa,,,,{|| MostraValGL(cTextoGP)},oDlg,"",{||},,.T. )

	oWTBrowse:SetFocus()

Return(.T.)
*********************************************************************
Static Function MostraValGL( _cTexto )//| Apresenta Dados que formam o Grafico Linha
*********************************************************************
	__cFileLog := MemoWrite(Criatrab(,.F.)+".txt",_cTexto)

	Define FONT oFont NAME "Lucida Console" Size 8,14
	Define MsDialog oDlgMemo Title "Dados Grafico" From 3,0 to 245,235 Pixel

	@ 5,5 Get oMemo  Var _cTexto MEMO Size 110,112 Of oDlgMemo Pixel

	oMemo:bRClicked := {||AllwaysTrue()}
	oMemo:oFont:=oFont

	Activate MsDialog oDlgMemo Center

Return()
*********************************************************************
Static Function Mnt_Grafico()//| MONTA GRAFICO BASE
*********************************************************************

//| GRAFICO Linha
	oGrap_L := 	TMSGraphic():New( 124, 001, oDlg, oFontGra, RGB(0,0,0), RGB(255,255,255), 238, 110 )
	oGrap_L:SetTitle('Historico de Saldo',, RGB(0,0,0), A_CENTER , .F. )

//| GRAFICO Pizza
	oGrap_P := 	TMSGraphic():New( 124, 234, oDlg, oFontGra, RGB(0,0,0), RGB(255,255,255), 160, 110 )
	oGrap_P:SetTitle('Pagamentos',, RGB(0,0,0), A_CENTER , .F. )

Return()
*********************************************************************
Static Function ObtemDados() //| Monta Tela com Parametros
*********************************************************************
	Local cSql 		:= ""
	Local cExt 		:= "943" //StrZero(Randomize( 0, 1000 ),3) // Resultado: Varia a cada chamada e deve estar entre 10 e 999

	Private cBaseCli 	:= "BASECLI" 	+ cExt
	Private cNcomp 		:= "NCOMP" 		+ cExt
	Private cMSaldo 	:= "MSALDO"		+ cExt
	Private cMAtraso 	:= "MATRASO" 	+ cExt
	Private lAllCli		:=  Empty(cCgcCli)
	oProcess:SetRegua1(9)
	oProcess:SetRegua2(0)

//|--- Dados principais ------------------------------------------------------
	oProcess:IncRegua1("Criando Tabelas Locais...")

	CriArqTrab() //| Cria Arquivos de Trabalho Local

//|--- Base Clientes ---------------------------------------------------------
	oProcess:IncRegua1("Aguardando Liberacao da Ferramenta...")
	ValSolExec("I") //| Verifica se nao existe um usuario executando a StorProcedure...

//|--- Base Clientes ---------------------------------------------------------
	oProcess:IncRegua1("Verificando Base Clientes...")

	cSql := "create table "+cBaseCli+" as "
	cSql += "select a1_cod cliente, "
	cSql += "a1_loja loja "

	cSql += "from sa1010 a1 "
	cSql += "where a1.a1_filial 	=  '  '  "

	If lAllCli  //| Filtra Paramentro entre todos clientes
		cSql += "  and   a1.a1_risco   	in "+RiscoC+" "
		cSql += "  and   a1.a1_lc      	between "+ cValToChar(ValLCI) +" and "+ cValToChar(ValLCF) +" "
		cSql += "  and   a1.a1_venclc  	between '"+ dtos(DatVLI) +"' and '"+ dtos(DatVLF) +"' "
		cSql += "  and   a1.a1_ultcom  	between '"+ dtos(DatUCI) +"' and '"+ dtos(DatUCF) +"' "

		if !Empty(cFGerI) .Or. cFGerI <> "ZZZZZZ"
			cSql += "  and   a1.a1_gerven   between '" +(cFGerI)+ "' and '" +(cFGerF)+ "' "
		EndIf

		if ( DatUAS <> dDataBase )//| Totdos
			If Empty(dtos(DatUAS)) //| Nunca Avaliados
				cSql += "  and   a1.a1_dreacre 	= '"+ dtos(DatUAS) + "' "
			else  //| 6 - 12 e 24 meses
				cSql += "  and   a1.a1_dreacre 	>= '"+ dtos(DatUAS) + "' "
			endif
		EndIf

		cSql += "  and   a1.a1_cgc    	> ' ' "
	Else
		cSql += "  and   a1.a1_cgc  = '"+cCgcCli+" ' "

	EndIf
	cSql += "  and(  a1.a1_cod     	< 'N00000' or  a1.a1_cod  > 'N00000' ) "
	cSql += "  and   a1.a1_msblql  	in(' ','2') "
	cSql += "  and 	a1.d_e_l_e_t_		= ' ' "

	ExecSql(cSql,""+cBaseCli+"","E")//| Comando, Tabela

//|--- Numero de Compras ------------------------------------------------------
	oProcess:IncRegua1("Verificando Numero de Compras...")

	cNcomp := "NCOMP"+cExt
	cSql := "create table "+cNcomp+" as  "
	cSql += "select 	f2.f2_cliente 	cliente 	, "
	cSql += "			f2.f2_loja 	loja			, "

	cSql += "				count(1) 				compras, "
	cSql += "				sum(f2.f2_valbrut)     valorfat, "
	cSql += "				0                       macumulo "
	cSql += "	from 		sf2010 f2, "+cBaseCli+" "
	cSql += "	where f2.f2_filial 		in("+ U_cRetFils("Q") +") "
	cSql += "		and f2.f2_tipo 		= 'N' "
	cSql += "		and f2.f2_emissao 	between '"+ dtos(DPInic) +"' and '"+ dtos(DPFina) +"' "
	cSql += "		and f2.f2_dupl 		> ' ' "
	cSql += "		and f2.d_e_l_e_t_  	= ' ' "

	cSql += "		and f2.f2_cliente = "+cBaseCli+".cliente "
	cSql += "		and f2.f2_loja    = "+cBaseCli+".loja "

	cSql += " group by	f2.f2_cliente, f2.f2_loja "

	if lAllCli
		cSql += "having count(1) between "+ cValToChar(NumQCI) +" and "+ cValToChar(NumQCF) +" ""
	Endif

	ExecSql(cSql,""+cNcomp+"","E")//| Comando, Tabela

//|--- Maior Saldo -----------------------------------------------------------
	oProcess:IncRegua1("Verificando Maior Saldo...")

	cSql := "create table "+cMSaldo+" as  "
	cSql += "	select cliente, loja, mes, sum(credito) credito, sum(debito) debito, sum(credito - debito) saldo, 0 Acumulo "
	cSql += "	from( "

	cSql += "			select e1_cliente cliente, e1_loja loja, e1_emissao mes, sum(e1_valor) credito, 0 debito "
	cSql += "			from se1010 e1, "+cBaseCli+", sf2010 f2 "
	cSql += "			where e1_filial 			=  '  ' "
	cSql += "			and   e1_emissao			>= '"+ dtos(DPInic) +"' "
	cSql += "			and   e1_baixa				>= ' ' "
	cSql += "			and   e1.d_e_l_e_t_ = ' ' "
	cSql += "			and   e1_cliente = "+cBaseCli+".cliente "
	cSql += "			and   e1_loja = "+cBaseCli+".loja "

	cSql += "			and f2.f2_filial 	= e1.e1_msfil "
	cSql += "			and f2.f2_serie  	= e1.e1_prefixo "
	cSql += "			and f2.f2_doc    	= e1.e1_num "
	cSql += "			and f2.f2_client 	= e1.e1_cliente "
	cSql += "			and f2.f2_loja   	= e1.e1_loja "
	cSql += "			and f2.f2_cond  	not in('244','245') " //| Filtra Pagamentos a Vista
	cSql += "			and f2.d_e_l_e_t_ = ' ' "
	cSql += "		group by e1_cliente, e1_loja, e1_emissao "

	cSql += "		union all "

	cSql += "		select e1_cliente cliente, e1_loja loja,   e1_baixa mes, 0 credito, sum(e1_valor) debito "
	cSql += "			from se1010 e1, "+cBaseCli+", sf2010 f2 "
	cSql += "			where e1_filial 			=  '  ' "
	cSql += "			and   e1_baixa				>= '"+ dtos(DPInic) +"' "
	cSql += "			and   e1.d_e_l_e_t_ = ' ' "
	cSql += "			and   e1_cliente = "+cBaseCli+".cliente "
	cSql += "			and   e1_loja 	 = "+cBaseCli+".loja "

	cSql += "			and f2.f2_filial 	= e1.e1_msfil "
	cSql += "			and f2.f2_serie  	= e1.e1_prefixo "
	cSql += "			and f2.f2_doc    	= e1.e1_num "
	cSql += "			and f2.f2_client 	= e1.e1_cliente "
	cSql += "			and f2.f2_loja   	= e1.e1_loja "
	cSql += "			and f2.f2_cond  	not in('244','245') " //| Filtra Pagamentos a Vista
	cSql += "			and f2.d_e_l_e_t_ = ' ' "

	cSql += "		group by e1_cliente, e1_loja, e1_baixa "
	cSql += "	) "
	cSql += "group by cliente, loja, mes "
	cSql += "order by cliente, loja, mes "

	ExecSql(cSql,""+cMSaldo+"","E")//| Comando, Tabela

//|--- Pagamentos Media Atraso ----------------------------------------------------------
	oProcess:IncRegua1("Verificando Pagamentos...")

	cSql := "create table "+cMAtraso+" as  "
	cSql += "select cliente, loja, sum(dias_atraso) dias_atraso, count(1) num_titulos, "

//| QTD DIAS
	cSql += "sum(pontual) pontual, "
	cSql += "sum(atraso_a) atraso_a, "
	cSql += "sum(atraso_b) atraso_b,  "

//| NOVO - VALORIZADO
	cSql += "	sum(vpontual)  vpontual , "
	cSql += "	sum(vatraso_a) vatrasoa , "
	cSql += "	sum(vatraso_b) vatrasob  "
//| FIM - VALORIZADO

	cSql += "from ( "
	cSql += "	select 	e1_cliente cliente, e1_loja loja,  "

	cSql += "		case  "
	cSql += "			when 	e1_baixa <= e1_vencrea then 0 "
	cSql += "			else	to_date(e1_baixa, 'yyyymmdd') - to_date(e1_vencrea, 'yyyymmdd') "
	cSql += "		end dias_atraso, "

	cSql += "		case  "
	cSql += "			when 	to_date(e1_baixa, 'yyyymmdd') - to_date(e1_vencrea, 'yyyymmdd') <= "+cValToChar(pValG)+" then 1 "
	cSql += "			else 0 "
	cSql += "		end pontual, "

	cSql += "		case  "
	cSql += "			when 	to_date(e1_baixa, 'yyyymmdd') - to_date(e1_vencrea, 'yyyymmdd') between  "+cValToChar(pValG+1)+" and  "+cValToChar(pValY)+" then 1 "
	cSql += "			else 0 "
	cSql += "		end atraso_a, "

	cSql += "		case  "
	cSql += "			when 	to_date(e1_baixa, 'yyyymmdd') - to_date(e1_vencrea, 'yyyymmdd') >= "+cValToChar(pValR)+" then 1 "
	cSql += "			else 0 "
	cSql += "		end atraso_b, "

//| NOVO - VALORIZADO
	cSql += "		case "
	cSql += "			when 	to_date(e1_baixa, 'yyyymmdd') - to_date(e1_vencrea, 'yyyymmdd') <= "+cValToChar(pValG)+" then e1_valor "
	cSql += "			else 0 "
	cSql += "		end vpontual, "

	cSql += "		case "
	cSql += "			when 	to_date(e1_baixa, 'yyyymmdd') - to_date(e1_vencrea, 'yyyymmdd') between  "+cValToChar(pValG+1)+" and  "+cValToChar(pValY)+" then e1_valor "
	cSql += "			else 0 "
	cSql += "		end vatraso_a, "

	cSql += "		case "
	cSql += "			when 	to_date(e1_baixa, 'yyyymmdd') - to_date(e1_vencrea, 'yyyymmdd') >= "+cValToChar(pValR)+" then e1_valor "
	cSql += "			else 0 "
	cSql += "		end vatraso_b "
//| FIM - VALORIZADO

	cSql += "	from se1010 e1, "+cBaseCli+", sf2010 f2 "
	cSql += "	where e1.e1_filial 				=  '  ' "
	cSql += "		and   e1.e1_emissao 		>= '"+ dtos(DPInic) +"' "
	cSql += "		and   e1.e1_tipo 			= 'NF' "
	cSql += "		and   e1.e1_baixa 			> ' ' "
	cSql += "		and   e1.d_e_l_e_t_ 		= ' ' "
	cSql += "		and   e1_cliente	= "+cBaseCli+".cliente "
	cSql += "		and   e1_loja 		= "+cBaseCli+".loja "

	cSql += "		and f2.f2_filial 	= e1.e1_msfil "
	cSql += "		and f2.f2_serie  	= e1.e1_prefixo "
	cSql += "		and f2.f2_doc    	= e1.e1_num "
	cSql += "		and f2.f2_client 	= e1.e1_cliente "
	cSql += "		and f2.f2_loja   	= e1.e1_loja "
	cSql += "		and f2.f2_cond  	not in('244','245') " //| Filtra Pagamentos a Vista
	cSql += "		and f2.d_e_l_e_t_ = ' ' "

	cSql += "	)  "
	cSql += "group by cliente, loja "

	ExecSql(cSql,""+cMAtraso+"","E") //| Comando, Tabela

//|--- Procedure Maior Saldo -------------------------------------------------
	oProcess:IncRegua1("Estruturando Maior Saldo por Mes..")

	cSql := "MAIOR_ACUMULO_N"

	ExecSql(cSql,"","P") //| Procedure

//|--- Dados principais ------------------------------------------------------
	oProcess:IncRegua1("Montando todos os dados obtidos...")

	cSql := "select	a1_cgc 	 cgcrzcli , a1_cod||a1_loja clclient , a1_nome     cnomecli , a1_risco  nvlrisco , a1_pricom cdpricom ,"
	cSql += "		a1_lc    limicred , a1_ultcom       ultrcomp , a1_dreacre  uavalser , a1_venclc cvenclcr , macumulo  maisaldo ,"
	cSql += "      	compras  ncompras , dias_atraso     diasatra , num_titulos ntitulos , pontual   ppontual , a1_classe cclassri ,"
	cSql += "      	atraso_a patrasoa , atraso_b        patrasob , vpontual             , vatrasoa           , valorfat           ,"
	cSql += "      	vatrasob          , trunc( vpontual / (vpontual + vatrasoa + vatrasob) * 100,0) statuspg , a1_grpseg segmento, a1_statser stataser "

	cSql += "from sa1010 a1, "+cNcomp+" NC, "+cMAtraso+" MA, "+cBaseCli+" BA "
	cSql += "where a1.a1_filial = '  ' "

	cSql += "	and   a1.a1_cod  = BA.cliente "
	cSql += "	and   a1.a1_loja = BA.loja "
	cSql += "	and   a1.a1_cod = NC.cliente "
	cSql += "	and   a1.a1_loja = NC.loja "
	cSql += "	and   a1.a1_cod = MA.cliente "
	cSql += "	and   a1.a1_loja = MA.loja "

	ExecSql(cSql,"TBASE","Q")

	DbSelectArea("TBASE");DbGoTop()

	cSql := "SELECT CLIENTE,LOJA, MES,CREDITO,DEBITO,SALDO,ACUMULO FROM "+cMSaldo+" ORDER BY CLIENTE,LOJA, MES "
	ExecSql(cSql,"TACUM","Q")

//|--- Salvando Consultas ------------------------------------------------------
	oProcess:IncRegua1("Salvando Consultas...")
	TransToTrab() // Salva  Resultado das Contultas em Aquivos de Trabalho Local

	oProcess:IncRegua1("Calculando Sugestoes...")
	CalcSugest() // Salva  Resultado das Contultas em Aquivos de Trabalho Local

	oProcess:IncRegua1("Limpando Arquivos Temporarios...")
	DbSelectArea("TFINAL")
	If Eof()
		lContinua := .F.
		IW_MSGBOX("O Filtro nao retornou nehum Registro!!!","Atencao","INFO")
	Endif

Return()
*********************************************************************
Static Function CriArqTrab() //| Cria Arquivos de Trabalho Local
*********************************************************************
	Local aStruct	:= {}
	Local cAli_A		:= "TSALDO"
	Local cAli_B		:= "TFINAL"
	Local cDriver	:= "CTREECDX"
	Local cArq			:= ""

//| Tabela Saldo - TSALDO
	aStruct	:= {}

	aAdd ( aStruct, { "CLIENTE"	, "C", 8		, 0  } )
	aAdd ( aStruct, { "MES"			, "C", 6		, 0  } )
	aAdd ( aStruct, { "ACUMULO"	, "N", 12	, 2  } )

	If Select ( cAli_A ) != 0
		DbSelectArea( cAli_A )
		DbCloseArea()
	EndIf

	cArq 	:= CriaTrab(aStruct, .T.)
	DBUseArea( .T., cDriver, cArq, cAli_A, .T., .F. )
	DBCreateIndex(cArq, "CLIENTE+MES", { || CLIENTE+MES }, .F.)

	Alert(cAli_A +": "+ cValToChar(cArq)) // Cristiano

//| Tabela FINAL - TFINAL
	aStruct	:= {}

	aAdd ( aStruct, { "CGCRZCLI"	, "C", 14	, 0  } )
	aAdd ( aStruct, { "CLCLIENT"	, "C", 8		, 0  } )
	aAdd ( aStruct, { "SEGMENTO"	, "C", 3		, 0  } )
	aAdd ( aStruct, { "CNOMECLI"	, "C", 30	, 0  } )
	aAdd ( aStruct, { "NVLRISCO"	, "C", 1		, 0  } )
	aAdd ( aStruct, { "LIMICRED"	, "N", 12	, 2  } )
	aAdd ( aStruct, { "ULTRCOMP"	, "D", 8		, 0  } )//ULTCOMPR
	aAdd ( aStruct, { "UAVALSER"	, "D", 8		, 0  } )
	aAdd ( aStruct, { "MAISALDO"	, "N", 12	, 2  } )
	aAdd ( aStruct, { "DIASATRA"	, "N", 12	, 2  } )
	aAdd ( aStruct, { "NCOMPRAS"	, "N", 12	, 2  } )
	aAdd ( aStruct, { "NTITULOS"	, "N", 12	, 2  } )
	aAdd ( aStruct, { "PPONTUAL"	, "N", 12	, 2  } )
	aAdd ( aStruct, { "PATRASOA"	, "N", 12	, 2  } )
	aAdd ( aStruct, { "PATRASOB"	, "N", 12	, 2  } )
	aAdd ( aStruct, { "VPONTUAL"	, "N", 12	, 2  } )
	aAdd ( aStruct, { "VATRASOA"	, "N", 12	, 2  } )
	aAdd ( aStruct, { "VATRASOB"	, "N", 12	, 2  } )
	aAdd ( aStruct, { "CVENCLCR"	, "D", 8		, 0  } )
	aAdd ( aStruct, { "CDPRICOM"	, "D", 8		, 0  } )
	aAdd ( aStruct, { "CCLASSRI"	, "C", 1		, 0  } )
	aAdd ( aStruct, { "VALORFAT"	, "N", 12	, 2  } )
	aAdd ( aStruct, { "STATUSPG"	, "N", 3		, 0  } )
	aAdd ( aStruct, { "STATASER"	, "C", 1		, 0  } )


	If Select ( cAli_B ) != 0
		DbSelectArea( cAli_B )
		DbCloseArea( )
	EndIf

	cArq 	:= CriaTrab(aStruct, .T.)
	DBUseArea( .T., cDriver, cArq, cAli_B, .T., .F. )
	DBCreateIndex(cArq,"STR(STATUSPG,3)+NVLRISCO+CGCRZCLI",{ || STR(STATUSPG,3)+NVLRISCO+CGCRZCLI },.F.)

	Alert(cAli_B +": "+ cValToChar(cArq)) // Cristiano

Return()
*********************************************************************
Static Function TransToTrab() // Transfere Resultado das Contultas para Aquivo de Trabalho Local
*********************************************************************
	Local cVar := ""
	Local nAcumulo := 0
	Local cPeriodo :=  ""
	Local cCliente :=  ""

	DbSelectArea("TACUM");DbGotop()
	While !EOF()

		If cPeriodo <> 	Substr(TACUM->MES,1,6) .Or. cCliente <>  TACUM->CLIENTE

			cCliente := TACUM->CLIENTE + TACUM->LOJA
			cPeriodo := Substr(TACUM->MES,1,6)
			nAcumulo := TACUM->ACUMULO

			DbSelectArea("TSALDO")
			RecLock("TSALDO",.T.)
			TSALDO->CLIENTE	:= TACUM->CLIENTE + TACUM->LOJA
			TSALDO->MES			:= cPeriodo
			TSALDO->ACUMULO	:= nAcumulo
			MsUnlock()

		Else

			nAcumulo :=  TACUM->ACUMULO

			If nAcumulo > TSALDO->ACUMULO
				DbSelectArea("TSALDO")
				RecLock("TSALDO",.F.)
				TSALDO->ACUMULO	:= nAcumulo
				MsUnlock()
			Endif

		EndIf

		DbSelectArea("TACUM")
		DbSkip()

	EndDo

	DbSelectArea("TBASE");DbGotop()
	While !EOF()

		DbSelectArea("TFINAL")
		RecLock("TFINAL",.T.)

		TFINAL->CGCRZCLI := TBASE->CGCRZCLI
		TFINAL->CLCLIENT := TBASE->CLCLIENT
		TFINAL->SEGMENTO := TBASE->SEGMENTO
		TFINAL->CNOMECLI := TBASE->CNOMECLI
		TFINAL->NVLRISCO := TBASE->NVLRISCO
		TFINAL->LIMICRED := TBASE->LIMICRED
		TFINAL->ULTRCOMP := STOD(TBASE->ULTRCOMP)
		TFINAL->UAVALSER := STOD(TBASE->UAVALSER)
		TFINAL->MAISALDO := TBASE->MAISALDO
		TFINAL->DIASATRA := TBASE->DIASATRA
		TFINAL->NCOMPRAS := TBASE->NCOMPRAS
		TFINAL->NTITULOS := TBASE->NTITULOS
		TFINAL->PPONTUAL := TBASE->PPONTUAL
		TFINAL->PATRASOA := TBASE->PATRASOA
		TFINAL->PATRASOB := TBASE->PATRASOB
		TFINAL->VPONTUAL := TBASE->VPONTUAL
		TFINAL->VATRASOA := TBASE->VATRASOA
		TFINAL->VATRASOB := TBASE->VATRASOB
		TFINAL->CVENCLCR := STOD(TBASE->CVENCLCR)
		TFINAL->CDPRICOM := STOD(TBASE->CDPRICOM)
		TFINAL->CCLASSRI := TBASE->CCLASSRI
		TFINAL->VALORFAT := TBASE->VALORFAT
		TFINAL->STATUSPG := TBASE->STATUSPG

		MsUnlock()

		nCliFilt ++

		DbSelectArea("TBASE")
		DbSkip()
	EndDo

	DbSelectArea("TACUM");DbCloseArea()
	DbSelectArea("TBASE");DbCloseArea()

	DbSelectArea("TSALDO");DbSetOrder(1);Dbgotop()
	DbSelectArea("TFINAL");DbSetorder(1);DbGotop()

	ValSolExec("F") //| Libera execucao das StorProcedure...

Return()
*********************************************************************
Static Function ExecSql(cSql,cTable,cTp)//| Comando, Tabela, tipo
*********************************************************************
	Local lMostraSql := MOSTRAQRY
	LocAL cRet := ""

	SLEEP(SLEEPTIME)

	If cTp == "E"

		If !Empty(cTable)
			U_ExecMySql("Drop Table "+ctable, "", cTp,lMostraSql)
		EndIf

		U_ExecMySql(cSql,"", cTp, lMostraSql)

	ElseIf cTp == "P" //| Execucao de Comando

		U_ExecMySql(cSql,"", cTp, lMostraSql)

	Else //| Execucao de Query

		U_ExecMySql(cSql , cTable, cTp,lMostraSql)

	EndIf

Return()
*********************************************************************
Static Function TelaParametros() //| Monta Tela Inicial de Parametros
*********************************************************************
	Local lcontinua 	:= .F.
	Local lCheckRB 		:= .F.
	Local lCheckRC 		:= .F.
	Local lCheckRD	 	:= .F.
	Local lCheckRE 		:= .F.
	Local nComboBoUAS 	:= 5
	Local nSB_LCI		:= 0
	Local nSB_LCI		:= 0
	Local nSB_LCF		:= 5000
	Local nSB_NCI		:= 0
	Local nSB_NCF		:= 100
	Local dGUCI			:= CToD('01/01/' + cValtoChar( Year( dDataBase ) ) )
	Local dGUCF         := CToD('31/12/' + cValtoChar( Year( dDataBase ) ) )

	Local dVlcI			:= CToD('01/'+cValtoChar( Month( dDataBase ) )+'/'+ cValtoChar( Year( dDataBase ) ) )       	//| Primeiro Dia Mes Atual
	Local dVlcF         := CToD('01/'+cValtoChar( Month( dVlcI+ 35 ) )+'/'+ cValtoChar( Year( dVlcI+ 35 ) ) ) - 1 	//| Ultimo Dia Mes Atual

	Local cGerI			:= Space(06)
	Local cGerF			:= Replicate('Z',6)
	Default FimLWin		:= 463
	Default lAlter		:= .F.

	Static oCheck
	Static oSB_LCI
	Static oSB_LCF
	Static oSB_NCI
	Static oSB_NCF
	Static oGroup
	Static oComboBox
	Static oButton
	Static oDlg
	Static oGUCI
	Static oGUCF
	Static oVLCI
	Static oVLCF
	Static cGerI
	Static cGerF

	Static oCgcCli

//cCgcCli := '03021270000177' // 05380321000182'//'01770107000181'

	DEFINE MSDIALOG oDlg TITLE "ANALISE CREDITO"  FROM 000, 000  TO FimLWin, 260 COLORS 0, 16777215 PIXEL

	@ 007, 006 GROUP oGroup TO 275, 123 PROMPT "FILTROS"			OF oDlg COLOR 0, 16777215 PIXEL

//| GROUP RISCO ----------------------------------------------------------------------------------------------------------------------
	@ 017, 014 GROUP oGroup TO 052, 114 PROMPT "Risco" 				OF oDlg COLOR 0, 16777215 PIXEL

	@ 027, 027 CHECKBOX oCheck VAR lCheckRB PROMPT "Risco B" SIZE 035, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 027, 072 CHECKBOX oCheck VAR lCheckRC PROMPT "Risco C" SIZE 035, 010 OF oDlg COLORS 0, 16777215 PIXEL

	@ 037, 027 CHECKBOX oCheck VAR lCheckRD PROMPT "Risco D" SIZE 035, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 037, 072 CHECKBOX oCheck VAR lCheckRE PROMPT "Risco E" SIZE 035, 010 OF oDlg COLORS 0, 16777215 PIXEL

//| GROUP LC ----------------------------------------------------------------------------------------------------------------------
	@ 054, 014 GROUP oGroup TO 082, 114 PROMPT "Limite Credito" 	OF oDlg COLOR 0, 16777215 PIXEL

	@ 067, 022 SPINBOX oSB_LCI	CHANGE  {|x| nSB_LCI := x }  SIZE 040, 010 OF oDlg
	oSB_LCI:setRange(0, 100000);oSB_LCI:setStep(500);oSB_LCI:setValue(nSB_LCI)

	@ 067, 067 SPINBOX oSB_LCF	CHANGE  {|x| nSB_LCF := x }  SIZE 040, 010 OF oDlg
	oSB_LCF:setRange(0, 100000);oSB_LCF:setStep(500);oSB_LCF:setValue(nSB_LCF)

//| GROUP VENCTO LC ----------------------------------------------------------------------------------------------------------------------
	@ 085, 014 GROUP oGroup TO 113, 114 PROMPT "Vencto. L.Cred." 	OF oDlg COLOR 0, 16777215 PIXEL

	@ 095, 022 MSGET oVLCI VAR dVlcI SIZE 040, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 095, 067 MSGET oVLCF VAR dVlcF SIZE 040, 010 OF oDlg COLORS 0, 16777215 PIXEL


//| GROUP NUM DE COMPRAS ----------------------------------------------------------------------------------------------------------------------
	@ 115, 014 GROUP oGroup TO 143, 114 PROMPT "Numero Compras" 	OF oDlg COLOR 0, 16777215 PIXEL ////@ 085, 014 GROUP oGroup TO 112, 114 PROMPT "Numero Compras" 	OF oDlg COLOR 0, 16777215 PIXEL

	@ 125, 022 SPINBOX oSB_NCI	CHANGE  {|x| nSB_NCI := x }  SIZE 040, 010 OF oDlg
	oSB_NCI:setRange(0, 10000) ;oSB_NCI:setStep(10) ;oSB_NCI:setValue(nSB_NCI)

	@ 125, 067 SPINBOX oSB_NCF	CHANGE  {|x| nSB_NCF := x } SIZE 040, 010 OF oDlg
	oSB_NCF:setRange(0, 10000) ;oSB_NCF:setStep(10) ;oSB_NCF:setValue(nSB_NCF)


//| GROUP ULTIMA COMPRA ----------------------------------------------------------------------------------------------------------------------
	@ 145, 014 GROUP oGroup TO 173, 114 PROMPT "Ultima Compra" 		OF oDlg COLOR 0, 16777215 PIXEL //@ 115, 014 GROUP oGroup TO 142, 114 PROMPT "Ultima Compra" 		OF oDlg COLOR 0, 16777215 PIXEL

	@ 155, 022 MSGET oGUCI VAR dGUCI SIZE 040, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 155, 067 MSGET oGUCF VAR dGUCF SIZE 040, 010 OF oDlg COLORS 0, 16777215 PIXEL


//| GROUP GERENCIA ----------------------------------------------------------------------------------------------------------------------
	@ 175, 014 GROUP oGroup TO 203, 114 PROMPT "Gerencia" 	OF oDlg COLOR 0, 16777215 PIXEL //@ 115, 014 GROUP oGroup TO 142, 114 PROMPT "Ultima Compra" 		OF oDlg COLOR 0, 16777215 PIXEL

	@ 185, 022 MSGET oGERI VAR cGerI F3 "SA3GER" SIZE 040, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 185, 067 MSGET oGERf VAR cGerF F3 "SA3GER" SIZE 040, 010 OF oDlg COLORS 0, 16777215 PIXEL


//| ULTIMA ANALISE SERASA ----------------------------------------------------------------------------------------------------------------------
	@ 205, 014 GROUP oGroup TO 233, 067 PROMPT "Ultima Analise" 	OF oDlg COLOR 0, 16777215 PIXEL //@ 145, 014 GROUP oGroup TO 172, 067 PROMPT "Ultima Analise" 	OF oDlg COLOR 0, 16777215 PIXEL

	@ 215, 022 MSCOMBOBOX oComboBox VAR nComboBoUAS ITEMS {"6 Meses","12 Meses","24 Meses","Nunca","Todos"} SIZE 040, 010 OF oDlg COLORS 0, 16777215 PIXEL


//| BOTOES ----------------------------------------------------------------------------------------------------------------------
	@ 207, 075 BUTTON oButton PROMPT "OK" 		SIZE 040, 012 OF oDlg ACTION {lcontinua := .T., oDlg:End()} PIXEL
	@ 220, 075 BUTTON oButton PROMPT "SAIR" 	SIZE 040, 012 OF oDlg ACTION {lcontinua := .F., oDlg:End()} PIXEL

	If  FimLWin	==	463 //| 550 -> MAIS | 463 -> MENOS
		@ 227, 115 BUTTON oButton PROMPT "+" 	SIZE 005, 005 OF oDlg ACTION {lAlter := .T.	, lcontinua := .T.,oDlg:End()} PIXEL
	Else
		@ 227, 115 BUTTON oButton PROMPT "-" 	SIZE 005, 005 OF oDlg ACTION {lAlter := .T., lcontinua := .T.,oDlg:End()} PIXEL
	EndIf

//| GROUP CNPJ CLIENTE ----------------------------------------------------------------------------------------------------------------------
	@ 238, 064 SAY oSay PROMPT "OU" 			SIZE 263, 010 OF oDlg COLORS 0, 16777215 PIXEL

	@ 245, 014 GROUP oGroup TO 243, 114 PROMPT "Cnpj Cliente" 		OF oDlg COLOR 0, 16777215 PIXEL //@ 180, 014 GROUP oGroup TO 207, 114 PROMPT "Cnpj Cliente" 		OF oDlg COLOR 0, 16777215 PIXEL

	@ 255, 022 MSGET oCgcCli VAR cCgcCli  PICTURE "@R 99.999.999/9999-99" F3 "VS1" SIZE 82, 010 OF oDlg COLORS 0, 16777215 PIXEL //| Filtro CGC

	ACTIVATE MSDIALOG oDlg CENTERED

//| Estrutura Variaveis para Querys
	If lCheckRB
		RiscoC += ",'B'"
	Endif
	If lCheckRC
		RiscoC += ",'C'"
	Endif
	If lCheckRD
		RiscoC += ",'D'"
	Endif
	If lCheckRE
		RiscoC += ",'E'"
	EndIf
	If !Empty(RiscoC)
		RiscoC := "("+Substr(RiscoC,2)+")"
	Endif
	ValLCI	:= nSB_LCI
	ValLCF	:= nSB_LCF
	NumQCI	:= nSB_NCI
	NumQCF	:= nSB_NCF
	DatUCI	:= dGUCI
	DatUCF	:= dGUCF
	DatVLI	:= dVlcI
	DatVLF  := dVlcF

	cFGerI	:= cGerI
	cFGerF	:= cGerF

	If cValToChar(nComboBoUAS) == "6 Meses"
		DatUAS 	:=	dDataBase - 182
	ElseIf cValToChar(nComboBoUAS) == "12 Meses"
		DatUAS 	:=	dDataBase -  365
	ElseIf cValToChar(nComboBoUAS) == "24 Meses"
		DatUAS 	:=	dDataBase - 730
	ElseIf cValToChar(nComboBoUAS) == "Nunca"
		DatUAS 	:=	cTod("  /  /  ")
	ElseIf cValToChar(nComboBoUAS) == "Todos"
		DatUAS 	:=	dDataBase
	Endif

Return(lcontinua)
*********************************************************************
Static Function Config() //| Tela de Configuracoes de Parametros
*********************************************************************
	Local oGroup
	Local oSay
	Local oGet
	Local oGroup
	Local oButSalvar
	Local oButCancel
	Static oWindow

	DEFINE MSDIALOG oWindow TITLE "Configuracao" FROM 000, 000  TO 210, 260 COLORS 0, 16777215 PIXEL

	@ 002, 002 GROUP oGroup		TO 082, 062 PROMPT "Legenda" OF oWindow COLOR 0, 16777215 PIXEL

	@ 022, 007 SAY oSay PROMPT "Otimo  >=" 	SIZE 025, 007 OF oWindow COLORS 0, 16777215 PIXEL
	@ 042, 007 SAY oSay PROMPT "Bom    >=" 	SIZE 025, 007 OF oWindow COLORS 0, 16777215 PIXEL
	@ 062, 007 SAY oSay PROMPT "Ruim   <=" 	SIZE 025, 007 OF oWindow COLORS 0, 16777215 PIXEL

	@ 020, 035 MSGET oGet VAR sValG SIZE 015, 010 OF oWindow PICTURE "@R 99" VALID ValCfg('sG') COLORS 0, 4259584 PIXEL
	@ 040, 035 MSGET oGet VAR sValY SIZE 015, 010 OF oWindow PICTURE "@R 99" VALID ValCfg('sY') COLORS 0, 65535 PIXEL
	@ 060, 035 MSGET oGet VAR sValR SIZE 015, 010 OF oWindow PICTURE "@R 99" VALID ValCfg('sR') COLORS 0, 255 PIXEL

	@ 022, 52 SAY oSay PROMPT "%" SIZE 025, 007 OF oWindow COLORS 0, 16777215 PIXEL
	@ 042, 52 SAY oSay PROMPT "%" SIZE 025, 007 OF oWindow COLORS 0, 16777215 PIXEL
	@ 062, 52 SAY oSay PROMPT "%" SIZE 025, 007 OF oWindow COLORS 0, 16777215 PIXEL

	@ 002, 067 GROUP oGroup 	TO 082, 127 PROMPT "Grafico" OF oWindow COLOR 0, 16777215 PIXEL

	@ 022, 070 SAY oSay PROMPT "Pontual <=" 	SIZE 025, 007 OF oWindow COLORS 0, 16777215 PIXEL
	@ 042, 070 SAY oSay PROMPT "Atr. A  <=" 	SIZE 025, 007 OF oWindow COLORS 0, 16777215 PIXEL
	@ 062, 070 SAY oSay PROMPT "Atr. B  >=" 	SIZE 025, 007 OF oWindow COLORS 0, 16777215 PIXEL

	@ 020, 095 MSGET oGet VAR pValG SIZE 015, 010 OF oWindow PICTURE "@R 99" VALID ValCfg('pG') COLORS 0, 65280 PIXEL
	@ 040, 095 MSGET oGet VAR pValY SIZE 015, 010 OF oWindow PICTURE "@R 99" VALID ValCfg('pY') COLORS 0, 65535 PIXEL
	@ 060, 095 MSGET oGet VAR pValR SIZE 015, 010 OF oWindow PICTURE "@R 99" VALID ValCfg('pR') COLORS 0, 255 PIXEL

	@ 022, 112 SAY oSay PROMPT "Dias" SIZE 025, 007 OF oWindow COLORS 0, 16777215 PIXEL
	@ 042, 112 SAY oSay PROMPT "Dias" SIZE 025, 007 OF oWindow COLORS 0, 16777215 PIXEL
	@ 062, 112 SAY oSay PROMPT "Dias" SIZE 025, 007 OF oWindow COLORS 0, 16777215 PIXEL


	@ 090, 015 BUTTON oButSalvar PROMPT "Salvar" 	SIZE 035, 010 OF oWindow ACTION ( SalvaCfg(), oWindow:End() ) PIXEL
	@ 090, 080 BUTTON oButCancel PROMPT "Cancelar" 	SIZE 035, 010 OF oWindow ACTION ( oWindow:End() ) PIXEL

	oButCancel:SetFocus()

	ACTIVATE MSDIALOG oWindow CENTERED

	sValG := Val( Posicione("SX5",1,xFilial("SX5")+"ZPSG","X5_DESCRI") ) //| Status - Green
	sValY := Val( Posicione("SX5",1,xFilial("SX5")+"ZPSY","X5_DESCRI") ) //| Status - Yelow
	sValR := Val( Posicione("SX5",1,xFilial("SX5")+"ZPSR","X5_DESCRI") ) //| Status - Red
	pValG := Val( Posicione("SX5",1,xFilial("SX5")+"ZPPG","X5_DESCRI") ) //| Pagamentos - Green
	pValY := Val( Posicione("SX5",1,xFilial("SX5")+"ZPPY","X5_DESCRI") ) //| Pagamentos - Yelow
	pValR := Val( Posicione("SX5",1,xFilial("SX5")+"ZPPR","X5_DESCRI") ) //| Pagamentos - Red


Return()
*********************************************************************
Static Function SalvaCfg( ) //|Salva as Config na Tabela SX5-ZP
*********************************************************************
	lnAchou := .F.

	DbSelectArea("SX5")
	If DbSeek(xFilial("SX5")+"ZP"+"SG",.F.)//
		RecLock("SX5",.F.)
		SX5->X5_DESCRI := cValToChar(sValG)
		Msunlock()

	Else
		lnAchou := .T.
	EndIf

	If DbSeek(xFilial("SX5")+"ZP"+"SY",.F.)
		RecLock("SX5",.F.)
		SX5->X5_DESCRI := cValToChar(sValY)
		Msunlock()
	Else
		lnAchou := .T.
	EndIf

	If DbSeek(xFilial("SX5")+"ZP"+"SR",.F.)
		RecLock("SX5",.F.)
		SX5->X5_DESCRI := cValToChar(sValY-1)
		Msunlock()
	Else
		lnAchou := .T.
	EndIf

	If DbSeek(xFilial("SX5")+"ZP"+"PG",.F.)
		RecLock("SX5",.F.)
		SX5->X5_DESCRI := cValToChar(pValG)
		Msunlock()
	Else
		lnAchou := .T.
	EndIf

	If DbSeek(xFilial("SX5")+"ZP"+"PY",.F.)
		RecLock("SX5",.F.)
		SX5->X5_DESCRI := cValToChar(pValY)
		Msunlock()
	Else
		lnAchou := .T.
	EndIf

	If DbSeek(xFilial("SX5")+"ZP"+"PR",.F.)
		RecLock("SX5",.F.)
		SX5->X5_DESCRI := cValToChar(pValR)
		Msunlock()
	Else
		lnAchou := .T.
	EndIf

	If !lnAchou
		IW_MsgBox("ConfiguraÁıes Salvas com Sucesso !", "AtenÁ„o", "INFO")
	Else
		IW_MsgBox("Erro ao Salvar ConfiguraÁıes !", "AtenÁ„o", "ALERT")
	Endif

Return()
*********************************************************************
Static Function ValCfg( cQuem )
*********************************************************************
	Local lValida := .T.

//| Status
	If 		(cQuem == 'sG') .And. (sValG <= sValY 	.Or. 	sValG >  100   )
		lValida := .F.
		IW_MsgBox( " Valor V·lido: [ "+cValToChar(sValY + 1)+" - 99 ]" , "AtenÁ„o", "ALERT")

	ElseIf 	(cQuem == 'sY')
		IF (sValY <= sValR 	.Or. sValY >= sValG )
			lValida := .F.
			IW_MsgBox( " Valor Valido: [ "+cValToChar(sValR + 1)+" - "+cValToChar(sValG - 1)+" ]" , "AtenÁ„o", "ALERT")
		Else
			sValR := sValY - 1
		EndIf
	ElseIf  (cQuem == 'sR')
		If (sValR <  0	 .Or.  	sValR >= sValG )
			lValida := .F.
			IW_MsgBox( " Valor Valido: [ 0 -"+cValToChar(sValG - 1)+" ]" , "AtenÁ„o", "ALERT")
		Else
			sValY := sValR + 1
		EndIf
	EndIf

//| Pagamentos
	If 		( cQuem == 'pG' ) .And. ( pValG >= pValY .Or. pValG < 0 )
		lValida := .F.
		IW_MsgBox( " Valor Valido: [ 0 - "+cValToChar(pValY - 1)+" ]" , "AtenÁ„o", "ALERT")

	ElseIf 	( cQuem == 'pY' )

		IF (pValY >= pValR 	.Or. pValY <= pValG )
			lValida := .F.
			IW_MsgBox( " Valor Valido: [ "+cValToChar(pValG + 1)+" - "+cValToChar(pValR - 1)+" ]" , "AtenÁ„o", "ALERT")
		Else
			pValR := pValY + 1
		EndIf

	ElseIf  ( cQuem == 'pR' ) //.And. ( pValR > 31 .Or. pValR <= pValY 	)

		If ( pValR > 31 .Or. pValR <= pValY 	)
			lValida := .F.
			IW_MsgBox( " Valor V·lido: [ "+cValToChar(pValY + 1)+" - 31 ]" , "AtenÁ„o", "ALERT")
		Else
			pValY := pValR - 1
		EndIf

	EndIf

Return(lValida)
*********************************************************************
Static Function WinRefresh() //| Monta Tela com Parametros
*********************************************************************
	lAlter := .F.

	If FimLWin == 550
		FimLWin := 463
	Else
		FimLWin := 550
	EndIf

Return()
*********************************************************************
static function ValSolExec(Acao)// Verifica Se Pode Executar a Procedure
*********************************************************************
	Local cExec 	:= "CREATE TABLE VEACRED943  AS SELECT '"+Substr(cUsuario,7,15)+"' CQUEM, '"+Time()+"' INICIO  FROM DUAL "
	Local cSql		:= "SELECT * FROM VEACRED943"
	Local lContinua := .T.
	Local nPasso	:= 0
	Local cRetorno	:= ""
	Local nVezes 	:= 1
	Local cTimeI	:= time()
	Local nTimeDif	:= 600
	Local _cUsuUso	:= ""
	Local lEntrou	:= .T.

	nTimeDif 	  := TIME - U_FTimeTo(cTimeI, Time(), "SN")

	If ACao == "I" //¨| Iniciar

		While (lContinua)

			nTimeDif := TIME - U_FTimeTo(cTimeI, Time(), "SN")

			oProcess:IncRegua1("Em uso ("+_cUsuUso+") aguarde "+cValToChar(nTimeDif)+" seg. ou LiberaÁ„o. ")

			If nVezes > nPasso
				cRetorno := U_ExecMySql(cSql, "", "E" ) //| Obtem Situacao
				nPasso := 3000
				nVezes := 0
			Else
				nVezes := nVezes + 1
			Endif

			If( AT("942",cRetorno) > 0 ) // Se estiver Liberado Executa Bloqueia
				U_ExecMySql(cExec, "", "E" )
				lContinua := .F.

			ElseIf(lEntrou)

				U_ExecMySql("Select * From VEACRED943", "VAUX", "Q" )
				cTimeI 	 := Alltrim(VAUX->INICIO)
				_cUsuUso := Alltrim(VAUX->CQUEM )
				DbSelectArea("VAUX");DbCloseArea()
				lEntrou := .F.
			Endif

			If nTimeDif <= 0      // Mais de 10 Minutos Bloqueado Efetua Liberacao Forcada
				U_ExecMySql("DROP TABLE VEACRED943"	, "", "E" )
				U_ExecMySql(cExec, "", "E" )
				lContinua := .F.
			EndIf

		End Do

	Else //| Finalizar
	//| dropa todas as tabelas Temporarias

		U_ExecMySql("DROP TABLE BASECLI943"	, "", "E" ) //| Base Clientes
		U_ExecMySql("DROP TABLE NCOMP943"	, "", "E" ) //| Compras
		U_ExecMySql("DROP TABLE MSALDO943"	, "", "E" ) //| Saldos
		U_ExecMySql("DROP TABLE MATRASO943"	, "", "E" ) //| Pagamentos

		U_ExecMySql("DROP TABLE VEACRED943"	, "", "E" ) //| Valida se a Rotina Esta em Execucao

	EndIf

Return()
*********************************************************************
Static Function MontaHtml(cHtml, cNoArqGL , cNoArqGP )
*********************************************************************
	cHtml := ""

	cHtml += '<html>'
	cHtml += '<head><meta content="multipart/related; charset=ISO-8859-1" http-equiv="content-type"><title>analise_credito</title></head>'

	cHtml += '<body style="width: 400px;">'

//| Titulo
	cHtml += '<div style="text-align: center;">'
	cHtml += '<big style="font-family: Arial Unicode MS;"><big><span style="font-weight: bold;">Reanalise de Cr&eacute;dito - Financeiro</span></big></big>
	cHtml += '<br><br><br>'

//| Recado
	cHtml += '<textarea readonly="readonly" cols="40" rows="5" name="Recado">Obs: '+StrTran(cObs,ENTER,'  ')+'</textarea>'
	cHtml += '<br><br>'

//| Tabela com Dados Cliente
	cHtml += '<table style="text-align: left; width: 600px; height: 63px;" border="0" cellpadding="2" cellspacing="2">'
	cHtml += '<tbody>'
	cHtml += '<tr>'
	cHtml += 	'<td style="vertical-align: top; height: 30px; font-family: Arial Unicode MS;"><span style="font-weight: bold;">Cliente:</span><br></td>'
	cHtml += 	'<td style="vertical-align: top; height: 30px; font-family: Arial Unicode MS;">'+aDadosBw[oWTBrowse:nAt,CODIGO]+'<br></td>'
	cHtml += 	'<td style="vertical-align: top; height: 30px; font-family: Arial Unicode MS;"><span style="font-weight: bold;">Nome:</span><br></td>'
	cHtml += 	'<td colspan="3" rowspan="1" style="vertical-align: top; height: 30px; font-family: Arial Unicode MS;">'+allTrim(aDadosBw[oWTBrowse:nAt,NOME])+'<br></td>'
	cHtml += '</tr>'
	cHtml += '<tr>'
	cHtml += 	'<td style="vertical-align: top; text-align: justify; width: 50px; height: 30px; font-family: Arial Unicode MS;"><span style="font-weight: bold;">Risco:</span><br></td>'
	cHtml += 	'<td style="vertical-align: top; text-align: justify; width: 50px; height: 30px; font-family: Arial Unicode MS;">'+cCRiscA+'<br></td>'
	cHtml += 	'<td style="vertical-align: top; text-align: justify; width: 50px; height: 30px; font-family: Arial Unicode MS;"><span style="font-weight: bold;">Limite:</span><br></td>'
	cHtml += 	'<td style="vertical-align: top; text-align: justify; width: 50px; height: 30px; font-family: Arial Unicode MS;">'+cvaltochar(nLimCrA)+'<br></td>'
	cHtml += 	'<td style="vertical-align: top; text-align: justify; width: 50px; height: 30px; font-family: Arial Unicode MS;"><span style="font-weight: bold;">Venc.Lim:</span><br></td>'
	cHtml += 	'<td style="vertical-align: top; text-align: justify; width: 50px; height: 30px; font-family: Arial Unicode MS;">'+dtoc(dVenLCA)+'<br></td></tr>'
	cHtml += '</tbody>'
	cHtml += '</table>'
	cHtml += '<br>'

	caminho_base := "http:/" + "/192.168.1.26/imgweb/"

//| Grafico Linhas...
	cHtml += '<img style="width: 456px; height: 200px;" alt="" src="'+caminho_base + cNoArqGL + '">'
	cHtml += '<br><br>'

//| Grafico Pizza...
	cHtml += '<img style="width: 310px; height: 200px;" alt="" src="'+caminho_base + cNoArqGP + '">'
	cHtml += '<br><br>'

//| Observacao SERASA
	cHtml += '<textarea readonly="readonly" cols="40" rows="10" name="Observa&ccedil;&atilde;o">Serasa: '+StrTran(mGetObs,ENTER,'  ')+'</textarea>'
	cHtml += '<br><br><br>'

	cHtml += '</div>'

//| Assinatua
	cHtml += '<table style="width: 602px; height: 261px;" cellpadding="0" cellspacing="0">'
	cHtml += '<tbody>'
	cHtml += '<tr style="font-family: Arial Unicode MS;">'
	cHtml += '<td style="border: medium none ; padding: 0cm;" align="left" width="173">'
	cHtml += '<img style="width: 194px; height: 85px;" src="http://www.gbrparts.com.br/ass/assinatura/assinatura.jpg" dfsrc="http://www.gbrparts.com.br/ass/assinatura/assinatura.jpg" align="bottom" border="0">'
	cHtml += '</td>'
	cHtml += '<td style="border: medium none ; padding: 0cm;" width="179">Analise de CrÈdito e CobranÁa</td>'
	cHtml += '</tr>'
	cHtml += '<tr>'
	cHtml += '<td style="border: medium none ; padding: 0cm;" colspan="2" width="352">'
	cHtml += '<p  style="border: medium none ; padding: 0cm; margin-bottom: 0cm; font-family: Arial Unicode MS;">'
	cHtml += '<strong>'
	cHtml += '<font size="2">EMPRESA CERTIFICADA ISO 9001</font>'
	cHtml += '</strong>'
	cHtml += '</p>'
	cHtml += '<p style="border: medium none ; padding: 0cm; margin-bottom: 0cm;">'
	cHtml += '<strong style="font-family: Arial Unicode MS;">'
	cHtml += '<font size="2">Imdepa Rolamentos Imp. e Com. Ltda.</font>'
	cHtml += '</strong>'
	cHtml += '<font size="1">'
	cHtml += '<span style="font-family: Arial Unicode MS;" class="style1">Porto Alegre - RS <br> Fone: (51) 2121-9925 <br> E-mail:'
	cHtml += '<a href="mailto:financeiro@imdepa.com.br" target="_blank">financeiro@imdepa.com.br</a>'
	cHtml += '</span>'
	cHtml += '<span class="style1">'
	cHtml += '<span style="font-family: Arial Unicode MS;">Visite nosso site:</span>'
	cHtml += '<a href="http://www.imdepa.com.br/" target="_blank">'
	cHtml += '<span style="font-family: Arial Unicode MS;"> www.imdepa.com.br</span>'
	cHtml += '</a>'
	cHtml += '</span>'
	cHtml += '</font>'
	cHtml += '</p>'
	cHtml += '</td>'
	cHtml += '</tr>'
	cHtml += '</tbody>'
	cHtml += '</table>'

	cHtml += '<br>'
	cHtml += '<br>'
	cHtml += '</body>'
	cHtml += '</html>'

Return(cHtml)
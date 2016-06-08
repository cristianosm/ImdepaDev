#Include "Protheus.ch"
#Include "Fivewin.ch"
#Include "Totvs.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |IMDR122   ºAutor  ³CRISTIANO MACHADO   º Data ³  03/21/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Selecao de Titulos para emissao de Segunda Via de boleto   º±±
±±º          ³ de cobranca, apartir do CNPJ do Cliente                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

********************************************************************
User Function IMDR121()
********************************************************************
	Public _cArq
	Public _cCnpj 		:= Space(14)
	Public _lFirst 	:= .T.
	Private cXEnter 	:= CHR(13)+CHR(10)

	U_IMD122B()//| Define o Parametro para ser Utilizado no Query

	fErase( _cArq + '.DBF' )
	fErase( _cArq + '.CDX' )

Return()
********************************************************************
User Function IMD122X()//| Define o Parametro para ser Utilizado no Query
********************************************************************

	Processa({|| GetSqlDados()},'Processando','Obtendo Dados Atraves da Query...')

	Processa({|| CreatTabAux()},'Processando','Criando Arquivo de Trabalho...')

	Processa({|| InsertDados()},'Processando','Exportando Query para Tabela Fisica...')

	If _lFirst
		_lFirst := .F.
		MountBrowse()	//| Carrega o Browse na Tela ...
	Else
		MarkBRefresh()
	EndIf

Return()
********************************************************************
Static Function GetSqlDados()
********************************************************************
	ProcRegua(0);IncProc()

	cString  	:= GetMv('MV_BANCHOM')
	cSearch  	:= '/'
	cReplace 	:= "','"
	cSql 		:= ""

	cSql += "SELECT  "
	cSql += "        SE1.E1_PREFIXO, "
	cSql += "        SE1.E1_NUM, "
	cSql += "        SE1.E1_PARCELA, "
	cSql += "        SE1.E1_PORTADO, "
	cSql += "        SA1.A1_CGC, "
	cSql += "        SA1.A1_COD, "
	cSql += "        SA1.A1_LOJA, "
	cSql += "        SA1.A1_NOME, "
	cSql += "        SE1.E1_VALOR, "
	cSql += "        SE1.E1_VENCTO, "
	cSql += "        SE1.R_E_C_N_O_ "

	cSql += "FROM SE1010 SE1, SA1010 SA1 "
	cSql += "WHERE SE1.E1_FILIAL  = '  ' "
	cSql += "AND   SE1.E1_TIPO    = 'NF' "
	cSql += "AND   SE1.E1_BAIXA   = ' ' "
	cSql += "AND   SE1.E1_VENCREA  >= TO_CHAR(SYSDATE, 'YYYYMMDD') "
	cSql += "AND   SE1.E1_PORTADO IN ('"+StrTran(cString, cSearch, cReplace)+"','246') "    //| 246 eh Banco ABC Execessao...
	cSql += "AND   SE1.E1_NUMBCO  <> '               ' "
	cSql += "AND   SE1.E1_HIST NOT LIKE('VENDOR%') "
	cSql += "AND   SE1.D_E_L_E_T_ = ' ' "
	cSql += "AND   SA1.A1_FILIAL  = SE1.E1_FILIAL "
	cSql += "AND   SA1.A1_COD     = SE1.E1_CLIENTE "
	cSql += "AND   SA1.A1_LOJA    = SE1.E1_LOJA "
	cSql += "AND   SA1.A1_CGC Like('"+Alltrim(_cCnpj)+"%') "
	cSql += "AND   SA1.D_E_L_E_T_ = ' ' "
	cSql += "AND   SA1.D_E_L_E_T_ = ' ' "

	U_ExecMySql(cSql,"QUE","Q")

Return()
********************************************************************
Static Function CreatTabAux()
********************************************************************
	ProcRegua(0);IncProc()

	If _lFirst
		If Select("BOL") <> 0
			BOL->( DbCloseArea() )
		EndIf
		_cArq := CriaTrab(	{ 	{"OK"			,'C'	,02,0	},;
			{"PREFIXO"		,'C'	,03,0	},;
			{"NUMERO"		,'C'	,09,0	},;
			{"PARCELA"		,'C'	,01,0	},;
			{"BANCO"			,'C'	,03,0	},;
			{"CNPJ"	    	,'C'	,14,0	},;
			{"CLIENTE" 	,'C'	,06,0	},;
			{"LOJA" 			,'C'	,02,0	},;
			{"NOME" 			,'C'	,40,0	},;
			{"VALOR"			,'N'	,17,2	},;
			{"VENCTO"		,'D'	,08,0	},;
			{"NRECNO"		,'N'	,12,0	} }, .T.)
	
		DbUseArea(.T., , _cArq, 'BOL', .F. )
	
		cIndex1 := "VENCTO"
//	cIndex1 := "CNPJ + PREFIXO + NUMERO + PARCELA"
		cIndex2 := "CLIENTE + LOJA + PREFIXO + NUMERO + PARCELA"
		cIndex3 := "PREFIXO + NUMERO + PARCELA"
	
		Index On &cIndex1. 	TAG 1 TO &_cArq.
		Index On &cIndex2.	TAG 2 TO &_cArq.
		Index On &cIndex3. 	TAG 3 TO &_cArq.
	
	Else
		DbSelectArea("BOL")
		ZAP
	
	EndIf

Return()
********************************************************************
Static Function InsertDados()
********************************************************************
	ProcRegua(0)

	DbSelectArea('QUE')
	If QUE->( EOF() )
	
		DbSelectArea("BOL")
		RecLock("BOL",.T.)
		BOL->OK		:= Space(2)
		MsUnlock()
	
	Else
	
		DbSelectArea('QUE');DbGotop()
		While !EOF()
		
			DbSelectArea("BOL")
			RecLock("BOL",.T.)
			BOL->OK				:= Space(2)
			BOL->PREFIXO		:= QUE->E1_PREFIXO
			BOL->NUMERO		:= QUE->E1_NUM
			BOL->PARCELA		:= QUE->E1_PARCELA
			BOL->BANCO			:= QUE->E1_PORTADO
			BOL->CNPJ			:= QUE->A1_CGC
			BOL->CLIENTE		:= QUE->A1_COD
			BOL->LOJA			:= QUE->A1_LOJA
			BOL->NOME			:= QUE->A1_NOME
			BOL->VALOR			:= QUE->E1_VALOR
			BOL->VENCTO		:= SToD(QUE->E1_VENCTO)
			BOL->NRECNO		:= QUE->R_E_C_N_O_
			MsUnlock()
		
			DbSelectArea('QUE');DbSkip()
			IncProc()
		
		EndDo
	
	EndIf

	DbSelectArea('QUE');DbCloseArea()
	DbSelectArea("BOL");DbGoTop();DbSetOrder(1)

Return()
********************************************************************
Static Function MountBrowse()
********************************************************************
	Private _cAlias		:= "BOL"
	Private _cCampo		:= "OK"
	Private _aFields   	:=  {	{'OK'       		,, ''	   				, '' 										},;
		{'PREFIXO'     ,, 'Prefixo'			, ''											},;
		{'NUMERO'     	,, 'Numero'			, ''											},;
		{'PARCELA'     ,, 'Parcela'			, ''											},;
		{'BANCO'     	,, 'Banco'				, ''											},;
		{'CNPJ'     		,, 'Cnpj'				, '@R 99.999.999/9999-99'	},;
		{'CLIENTE'     ,, 'Cliente'			, ''											},;
		{'LOJA'     		,, 'Loja'				, ''											},;
		{'NOME'     		,, 'Nome'				, ''											},;
		{'VALOR'    		,, 'Valor'				, '@E 99,999,999,999.99'	},;
		{'VENCTO'			,, 'Vencimento'	, ''											} }

	Private lMarca    	:= .F.
	Private cMarca    	:= GetMark(.T.,'BOL','OK')
	Private cCadastro 	:= "Emissão de Segunda Via - Boleto Bancario"
	Private aRotina   	:=  {	{ 'Pesquisar  ', 'U_IMD122A(cAlias)' 	, 0, 0	},;
		{ 'Parametro  ', 'U_IMD122B()' 			, 0, 0	},;
		{ 'Gerar   '   , 'U_IMD122C()' 			, 0, 0	},;
		{ 'Homologados', 'U_IMD122D()' 			, 0, 0	} }

	MarkBrow( _cAlias, _cCampo,, _aFields, lMarca, cMarca )

	DbSelectArea('BOL');DbCloseArea()

Return()
********************************************************************
User Function IMD122A(cAlias) //| Pesquisar
********************************************************************
	Static oGet
	Static oButtonCan
	Static oButtonOk
	Static oComboBox

	Private oDlg
	Private cComboBox 	:= ""
	Private cConteudo 	:= Space(100)
	Private aIndex		:= {"Vencimento","Cliente + Loja + Prefixo + Numero + Parcela","Prefixo + Numero + Parcela"}

	Define MsDialog oDlg Title "Pesquisar" From 000, 000  To 120, 450 COLORS 0, 16777215 Pixel

	@ 010, 012 MsComboBox oComboBox Var cComboBox Items aIndex  Size 200, 010 Of oDlg COLORS 0, 16777215 Pixel
	@ 025, 012 MsGet oGet Var cConteudo Size 200, 010 OF oDlg Picture "@!"  COLORS 0, 16777215 Pixel
	@ 040, 012 Button oButtonOk  Prompt "Pesquisar"	Size 040, 015 Of oDlg Action(Pesquisar(cAlias)) Pixel
	@ 040, 062 Button oButtonCan Prompt "Cancelar"		Size 040, 015 Of oDlg Action(oDlg:End()) Pixel

	Activate MsDialog oDlg Centered

Return()
********************************************************************
Static Function Pesquisar(cAlias)
********************************************************************
	Local nIndex := 1

	For I := 1 To Len(aIndex)
	
		If cComboBox == aIndex[I]
			nIndex := I
		EndIF
	
	Next

	DbSelectArea(cAlias);DbSetOrder(nIndex)

	If nIndex == 1
		lRetPesq := DbSeek(CToD(Alltrim(cConteudo)),.T.)
	Else
		lRetPesq := DbSeek(Alltrim(cConteudo),.F.)
	EndIf

	If !lRetPesq
		DbSelectArea(cAlias);DbGotop()
		IW_MsgBox("Nenhum Registro Localizado com esta chave de Pesquisa! Tente Novamsnte.","Atenção","INFO")
	Else
		oDlg:End()
	EndIF


Return()
********************************************************************
User Function IMD122B()//| Tela Parametro CNPJ
********************************************************************
	Local oButWin
	Local oGet
	Local oGroup
	Local oWin

	_cCnpj := Space(14)

	Define MsDialog oWin Title "Parametro" From 000, 000  To 120, 300 Colors 0, 16777215 Pixel

	@ 005, 007 Group oGroup To 038, 138 Prompt "Informe o CNPJ do Cliente" Of oWin COLOR 0, 16777215 Pixel
	@ 018, 019 Msget oGet Var _cCnpj Size 101, 010 Of oWin Picture "@R 99.999.999/9999-99" Valid (ValCnpj()) COLORS 0, 16777215 F3 "BOLSA1" Pixel
	@ 042, 035 Button oButWin PROMPT "Confirma" Size 070, 013 Of oWin Action {oWin:End(),U_IMD122X()}  Pixel

	Activate MsDialog oWin Centered

Return()
********************************************************************
Static Function ValCnpj() //| Valida Cnpj No parametro Inicial
********************************************************************
	lReturn := .T.

	If Len(Alltrim(_cCnpj)) < 8
		IW_MsgBox("Informe no Mínimo o CNPJ Raiz do Cliente (8 Digitos)!!! ","Atenção","INFO")
		lReturn := .F.
	EndIf

Return(lReturn)
********************************************************************
User Function IMD122C() //| Verifica Titulos Selecionados
********************************************************************
	Local aRegs			:= {}
	Local lCabec			:= .T.
	Local lRodape		:= .T.

	Private cMenAbc 	:= ""
	Private aAnexo 	:= {}
	Private lSAbc 		:= .F.

	PswOrder(2)
//PswSeek(Substr(cusuario,7,15),.T.)

	PswSeek(CUSERNAME,.T.)

	DbSelectArea("BOL");DbGotop()
	While !EOF()
	
		IF BOL->OK <> Space(2)
		
			If BOL->BANCO <> "246" //| Banco ABC tem uma execao e nao sera gerado 2 Via pelo protheus mas o Financeiro deve ser informado por email. ja tratado mais abaixo.
				aAdd( aRegs, BOL->NRECNO )
				_cCnpj := BOL->CNPJ
		
			Else //| Banco ABC
			
	
				If lCabec
					_cCnpj := BOL->CNPJ
					IW_MsgBox(	"Foram selecionados Titulos do Banco ABC, estes serão enviados ao Cliente através do Financeiro-Poa."+;
						" O Financeiro esta recebendo por e-mail estes titulos.","Atenção","INFO")
							
					cMenAbc += "Financeiro," + cXEnter + cXEnter
					cMenAbc += 'O Cliente CNPJ '+Transform(_cCnpj,'@R 99.999.999/9999-99')+ " - " +Alltrim(BOL->NOME)+" "
					cMenAbc += "solicitou 2 Via do(s) seguinte(s) Titulo(s):" + cXEnter+ cXEnter
					cMenAbc += "Portador Banco ABC - www.abcbrasil.com.br "+ cXEnter + cXEnter

					lCabec := .F.
				EndIf

				cMenAbc += Space(10) + " - " + BOL->PREFIXO + BOL->NUMERO + "-" + BOL->PARCELA + Replicate('.',10)+DToC(BOL->VENCTO)+Replicate('.',10)+ "R$ "+Alltrim(Str(BOL->VALOR)) + cXEnter

			EndIf
		
		EndIf
	
		BOL->( DbSkip() )
	
	EndDo

	If !lCabec .And. lRodape  //Monta Rodape e Envia Email para o Financeiro com titulos do ABC / So pelo site do banco eh posivel tirar a segunda via do ABC
		cMenAbc += cXEnter + cXEnter + cXEnter
		cMenAbc += "E-mail/ Fone do Cliente para contato: "+ Lower(Posicione("SA1",3,xFilial('SA3')+_cCnpj,"A1_MAILFIN"))+ "  - (" + Alltrim(SA1->A1_DDD) + ") "+ SA1->A1_TEL  + cXEnter + cXEnter
		cMenAbc += "Att " + cXEnter
		cMenAbc += Substr(cUsuario,7,15)

		U_EnvMyMail(SA3->(PswRet()[1][14]),"boletos@imdepa.com.br","","Solicitação Boleto ABC - Cliente: "+Transform(_cCnpj,'@R 99.999.999/9999-99') ,cMenAbc,'')
	EndIf

	DbSelectarea("BOL")
	ZAP

	DbSelectArea("BOL")
	RecLock("BOL",.T.)
	BOL->OK	:= Space(2)
	MsUnlock()

	If Len(aRegs) > 0
		aAnexo := U_IMDR120(aRegs)
		If Len(aAnexo) > 0
			TelaMail()
		Else
			IW_MsgBox("Arquivo não Pode ser Anexado,  Execução Cancelada pelo Usuário !","Atenção","INFO")
		EndIf
	Else
		IW_MsgBox("Nenhum Titulo Selecionado para Geração de Boleto Local !!!","Atenção","INFO")

	EndIf

Return()
*********************************************************************
Static Function TelaMail() //| Prepara Para Geração por PDF
*********************************************************************

	Static oButtonV
	Static oButtonE
	Static oButtonS
	Static oGet
	Static oGroup
	Static oMultiGe1
	Static oSay
	Static oWinMail

	Private cDe				:= Space(100)
	Private cPara 			:= Space(100)
	Private cCopia 		:= Space(100)
	Private cAssunto 	:= "Segunda Via Boleto - Imdepa Rolamentos - "
	Private cMensagem 	:= Space(1000)

	PswOrder(2)
//PswSeek(Substr(cusuario,7,15),.T.)
	PswSeek(CUSERNAME,.T.)

	cAssunto += Upper(Posicione("SA1",3,xFilial('SA1')+_cCnpj,"A1_COD")) + " - "
	cAssunto += Upper(Posicione("SA1",3,xFilial('SA1')+_cCnpj,"A1_NOME"))


	cMensagem := 	"Prezado Cliente,"+cXEnter+cXEnter;
		+"Segue anexo Boleto(s) conforme solicitado..."+cXEnter+cXEnter+cXEnter+cXEnter+cXEnter;
		+"Atenciosamente,"+cXEnter+cXEnter;
		+"Dep. Financeiro "+cXEnter;
		+"Imdepa Rolamentos "+cXEnter;
		+"Fone:(51) 2121-9915"+cXEnter
			
//| Busca Email do Usuario Logado
	cDe 		:= "Boletos@Imdepa.com.br"
	cPara	:= Lower(Posicione("SA1",3,xFilial('SA3')+_cCnpj,"A1_MAILFIN"))
	cCopia	:= SA3->(PswRet()[1][14])  //| Retorna e-mail do usuario


	DEFINE MSDIALOG oWinMail TITLE "Envio de Segunda Via por e-mail" FROM 000, 000  TO 450, 505 COLORS 0, 16777215 PIXEL

//	@ 004, 024 SAY oSay PROMPT "Encio de Segunda Via de Boletos para Clientes" SIZE 208, 010 OF oWinMail COLORS 0, 16777215 PIXEL

	@ 010, 010 GROUP oGroup TO 063, 245 PROMPT "Emails" 		OF oWinMail COLOR 0, 16777215 PIXEL
	@ 065, 010 GROUP oGroup TO 092, 192 PROMPT "Assunto" 		OF oWinMail COLOR 0, 16777215 PIXEL
	@ 065, 195 GROUP oGroup TO 092, 245 PROMPT "Anexo" 		OF oWinMail COLOR 0, 16777215 PIXEL
	@ 095, 010 GROUP oGroup TO 195, 245 PROMPT "Mensagem" 	OF oWinMail COLOR 0, 16777215 PIXEL
	@ 197, 045 GROUP oGroup TO 220, 223 PROMPT "" 					OF oWinMail COLOR 0, 16777215 PIXEL

	@ 020, 020 SAY oSay PROMPT "De:" 		SIZE 015, 008 	OF oWinMail COLORS 0, 16777215 PIXEL
	@ 035, 020 SAY oSay PROMPT "Para:" 	SIZE 015, 008 	OF oWinMail COLORS 0, 16777215 PIXEL
	@ 048, 020 SAY oSay PROMPT "Cópia:" SIZE 015, 008 	OF oWinMail COLORS 0, 16777215 PIXEL

	@ 020, 040 MSGET oGet VAR cDe 		SIZE 195, 010 		OF oWinMail COLORS 0, 16777215 PIXEL
	@ 033, 040 MSGET oGet VAR cPara 	SIZE 195, 010 		OF oWinMail COLORS 0, 16777215 PIXEL
	@ 046, 040 MSGET oGet VAR cCopia 	SIZE 195, 010 		OF oWinMail COLORS 0, 16777215 PIXEL
	@ 075, 015 MSGET oGet VAR cAssunto 	SIZE 167, 010 	OF oWinMail COLORS 0, 16777215 PIXEL

	@ 105, 020 GET oMultiGe1 VAR cMensagem OF oWinMail MULTILINE SIZE 215, 080 COLORS 0, 16777215 HSCROLL PIXEL

	@ 074, 200 BUTTON oButtonV PROMPT "Abrir" 	 		Action(FAction(1))		SIZE 040, 015 OF oWinMail PIXEL
	@ 201, 050 BUTTON oButtonE PROMPT "Enviar" 		 	Action(FAction(2,1))	SIZE 050, 015 OF oWinMail PIXEL
	@ 201, 110 BUTTON oButtonV PROMPT "Salvar e Enviar"	Action(FAction(2,2))	SIZE 050, 015 OF oWinMail PIXEL
	@ 201, 170 BUTTON oButtonS PROMPT "Sair"    	 	Action(FAction(4))		SIZE 050, 015 OF oWinMail PIXEL

	oButtonE:SetFocus()

	ACTIVATE MSDIALOG oWinMail CENTERED

Return()
********************************************************************
Static Function FAction(nOpc,nSop)
********************************************************************

	Do Case
	Case nOpc == 1 //| Abrir Anexo
		ShellExecute( "Open", aAnexo[1], "", "", 1 )

	Case nOpc == 2 //| Enviar
        
		_CopyFile(aAnexo[1], aAnexo[2] )
        
		If nSop == 2 //| Atualiza Cadastro do Cliente
			If IW_MsgBox("Deseja Salvar "+Alltrim(cPara)+" como e-mail do Cliente ?","Atualização","YESNO")
				cSql := "Update SA1010 Set A1_MAILFIN = '"+Alltrim(cPara)+"' Where A1_CGC like '"+Substr(_cCnpj,1,8)+"%' "
				U_ExecMySql(cSql,'','E')
			EndIf
		EndIF

		If Empty(cDe) .Or. Empty(cPara)
			IW_MsgBox("Para enviar o email Preencha o Destinatário.","Atenção","INFO")
			Return()
		EndIf

		U_EnvMyMail(cDe,cPara,cCopia,cAssunto,cMensagem,aAnexo[2])
		oWinMail:End()
		IW_MsgBox("Email Enviado com Sucesso. Destinatarios: "+Alltrim(cPara+cCopia),"Atenção","INFO")
		
	Case nOpc == 3 //| Enviar e Salvar
        
		If Empty(cDe) .Or. Empty(cPara)
			IW_MsgBox("Para enviar o email Preencha o Destinatário.","Atenção","INFO")
			Return()
		EndIf
        
		U_EnvMyMail(cDe,cPara,cCopia,cAssunto,cMensagem,aAnexo[2])
		oWinMail:End()
		IW_MsgBox("Email Enviado com Sucesso. Destinatarios: "+Alltrim(cPara+cCopia),"Atenção","INFO")
		
	Case nOpc == 4  //| Sair
		oWinMail:End()

	End Case

	If nOpc <> 1
		If fErase(aAnexo[1]) == -1
			IW_MsgBox('Falha na deleção do Arquivo '+aAnexo[1] )
		EndIf
		If nOpc <> 4  //| Sair
			If fErase(aAnexo[2]) == -1
				IW_MsgBox('Falha na deleção do Arquivo '+aAnexo[2] )
			Endif
		EndIf
	EndIf

Return()
********************************************************************
User Function IMD122D() //| Bancos Homologados aGerar o Boleto
********************************************************************
	Local obbrasil
	Local obitau
	Local obbradesco
	Local obsantander
	Local obcitibank

	Local oButton
	Local oGroup

	Local fbbrasil			:= "\system\bbrasil.bmp"
	Local fbitau				:= "\system\bitau.bmp"
	Local fbbradesco		:= "\system\bbradesco.bmp"
	Local fbsantander	:= "\system\bsantander.bmp"
	Local fbcitibank		:= "\system\bcitibank.bmp"

	Static oWinHom

	Define MsDialog oWinHom Title "Homologados" From 000, 000  To 660, 560 COLORS 0, 16777215 Pixel

	@ 010, 010 Group oGroup To 325, 270 PROMPT " Bancos Homologados a emitir Segunda Via de Boleto Bancario no Protheus " Of oWinHom Color 0, 16777215 Pixel
	@ 020, 015 BitMap obbrasil 		Size 250, 055 Of oWinHom FileName fbbrasil 		NOBORDER Pixel
	@ 080, 015 BitMap obitau 		Size 250, 055 Of oWinHom FileName fbitau 		NOBORDER Pixel
	@ 140, 015 BitMap obbradesco 	Size 250, 055 Of oWinHom FileName fbbradesco 	NOBORDER Pixel
	@ 200, 015 BitMap obsantander 	Size 250, 055 Of oWinHom FileName fbsantander 	NOBORDER Pixel
	@ 260, 015 BitMap obcitibank 	Size 250, 055 Of oWinHom FileName fbcitibank 	NOBORDER Pixel
//	@ 340, 110 Button oButton Prompt "Fechar" Size 060, 014 Of oWinHom Action(oWinHom:End())Pixel

	Activate MsDialog oWinHom Centered

Return()
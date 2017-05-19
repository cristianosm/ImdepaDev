#include 'protheus.ch'
#include 'parmtype.ch'


#Define _ENTER_ CHR(13) + CHR(10)

//|****************************************************************************
//| Projeto:
//| Modulo :
//| Fonte : SinCliCon
//| 
//|************|******************|*********************************************
//|    Data    |     Autor        |                   Descricao
//|************|******************|*********************************************
//| 15/01/2017 | Cristiano Machado| Funcao responsavel por sincronizar Telefone do Cliente com Tabela de Contatos.
//|            |                  | Utilizado na criacao das listas do Telecobranca.   
//|            |                  |  
//|            |                  |  
//|            |                  |  
//|************|***************|***********************************************
*******************************************************************************
User Function SinCliCon()
*******************************************************************************
	
	Local aCamps	:= {"U5_CELULAR","U5_FONE","U5_FCOM1","U5_FCOM2"}
	Local nPos		:= 0
	Local oProcess	:= Nil
	Local lEnd		:= Nil
	
	Private cReguaP := "Verificando Contatos..."
	Private cCampo 	:= ""
	Private nCC		:= 0
	Private nCA		:= 0
	
	If Tela(@nPos)
	
		cCampo := 'SU5->'+aCamps[nPos]
		oProcess := MsNewProcess():New( {|lEnd| VerCliSCon()(@oProcess, @lEnd)} , "Verificando Contatos...", "", .T. )
		oProcess:Activate()
	
		Iw_MsgBox("Total de Contatos Atualizados: "+cValToChar( nCC + nCA )+"  ","Atualizacao Concluida", "INFO")
	
	EndIf
	
	
Return()
*******************************************************************************
Static Function Tela(nPos)
*******************************************************************************

	Local cTxtMM 	:= ""
	Local oDlg		:= Nil
	Local oGroup	:= Nil
	Local oSay		:= Nil
	Local oMGet		:= Nil
	Local oCBox		:= Nil
	Local oBtnA		:= Nil
	Local oBtnB		:= Nil
	Local aItems	:= {FX3Titulo("U5_CELULAR"),FX3Titulo("U5_FONE"),FX3Titulo("U5_FCOM1"),FX3Titulo("U5_FCOM2")}
	Local cCombo	:= aItems[3]
	Local lAtualiza := .F.
	//Janela
	oDlg:= TDialog():New(000,000,370,340,'Atualizacao Contatos',,,,,CLR_BLACK,CLR_WHITE,,,.T.)
	oDlg:lCentered := .T.

	//Grupo
	oGroup:= TGroup():New(02,02,184,168,Nil,oDlg,,,.T.)

	// Mensagem
	cTxtMM +=  _ENTER_ + SPACE(5) + 'Este programa tem o objetivo de efetuar a atualizacao ' 	+ _ENTER_
	cTxtMM +=  _ENTER_ + SPACE(5) + 'do  telefone do  Contato no  cliente de  acordo com o ' 	+ _ENTER_
	cTxtMM +=  _ENTER_ + SPACE(5) + 'telefone principal do cadatro do Cliente.  Utilizado  ' 	+ _ENTER_
    cTxtMM +=  _ENTER_ + SPACE(5) + 'no TeleCobranca para não deixar de apresentar os titulos ' + _ENTER_
    cTxtMM +=  _ENTER_ + SPACE(5) + 'a Cobrar, por nao possuir telefone informado no contato.  '+ _ENTER_
    
    // Cria o MultGet (Memo)
	oMGet := tMultiget():New( 10, 05, {| u | if( pCount() > 0, cTxtMM := u, cTxtMM ) }, oDlg, 160, 090, , , , , , .T. )
	oMGet:lReadOnly := .T.

	// Titulo e Combo
	oSay    := TSay():New( 115,10,{||"Escolha abaixo qual campo deve ser atualizado nos Contatos"},oDlg,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,010)
	
	oCBox   := TComboBox():New( 130,50,{|u|if(PCount()>0,cCombo:=u,cCombo)},aItems,75,10,oDlg,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, )

	// Botoes
	oBtnB   := TButton():New( 160,020,"Sair",oDlg,{|| oDlg:end() },037,012,,,,.T.,,"",,,,.F. )

	oBtnA   := TButton():New( 160,110,"Atualizar",oDlg,{|| nPos := oCBox:Nat, lAtualiza:= .T.,oDlg:end()},037,012,,,,.T.,,"",,,,.F. )
	
	
	// Ativa Janela 
	oDlg:Activate()

	If lAtualiza
		lAtualiza := Iw_MsgBox("Confirma a Atualizacao dos Contatos ? ","Atencao", "YESNO" )
	EndIf

Return(lAtualiza)
*******************************************************************************
Static Function FX3Titulo(cCampo)
*******************************************************************************

	Local cTitulo := "Nao Encontrou"
	//Local cDescri := ""
	Local aAreaSx3 := SX3->(GetArea())
	
	DbSelectArea("SX3");DbSetOrder(2)
	If DbSeek( cCampo )
		cTitulo := X3Titulo()
		//cDescri := X3DescriC()
	EndIf
	
	RestArea(aAreaSx3)
	
Return (cTitulo)
*******************************************************************************
Static Function VerCliSCon(oProcess, lEnd)
*******************************************************************************

	oProcess:SetRegua1( 4 ) 
	oProcess:SetRegua2( 0 )
	
	
	oProcess:IncRegua1("Verificando Contatos sem Telefone")
	SqlConsT(@oProcess, @lEnd)
	
	
	oProcess:IncRegua1("Atualizando Contatos sem Telefone")
	AtuConsT(@oProcess, @lEnd)


	oProcess:IncRegua1( "Verificando Clientes sem Contato")
	SqlClisC(@oProcess, @lEnd)
	
	
	oProcess:IncRegua1("Atualizando Clientes sem Contato")
	AtuClisC(@oProcess, @lEnd)
	
	
	
	  
Return()
*******************************************************************************
Static Function	SqlClisC(oProcess, lEnd)//Verificando Clientes sem Contato" )
*******************************************************************************

Local cSql := ""
Local cTab := "CSC" // Contato sem Telefone 
Local dData2Ya := dDatabase - 365 * 2

cSql += "SELECT " 
cSql += "  A1.A1_COD, A1.A1_LOJA, " 
cSql += "  Case " 
cSql += "    When A1.A1_EMAIL = ' ' Then 'email@mail.com.br' "
cSql += "    else  A1.A1_EMAIL "
cSql += "    end A1_EMAIL, "
cSql += "   Case " 
cSql += "    When A1.A1_TEL = ' ' Then '00 00000000' "
cSql += "    Else  Trim(Replace(A1.A1_DDD,'0',''))||' '||Trim(A1.A1_TEL) "
cSql += "    End A1_TEL, "
cSql += "    NVL(AC.AC8_CODENT,' ') AC8_CODENT, " 
cSql += "    NVL(AC.AC8_CODCON,' ') AC8_CODCON, "
cSql += "    NVL(AC.R_E_C_N_O_,0) RECNO, "
cSql += "    NVL(U5.U5_CODCONT,' ') U5_CODCONT, "
cSql += "    NVL(U5.U5_FCOM1, ' ') U5_FCOM1 "
    
cSql += "FROM SA1010 A1 FULL JOIN AC8010 AC "
cSql += "ON   AC.AC8_CODENT = A1.A1_COD||A1.A1_LOJA "
cSql += "               FULL JOIN SU5010 U5 "
cSql += "ON   AC.AC8_CODCON =  U5.U5_CODCONT "
cSql += "WHERE U5.U5_CODCONT IS NULL "
cSql += "AND   EXISTS (SELECT E1_CLIENTE, E1_LOJA FROM SE1010 WHERE E1_FILIAL = ' ' AND E1_EMISSAO >= '"+DtOs(dData2Ya)+"' AND D_E_L_E_T_ = ' ' AND E1_CLIENTE = A1_COD AND E1_LOJA = A1_LOJA ) "

oProcess:IncRegua2( "Obtendo Clientes.." )

U_ExecMySql( cSql , cTab , "Q", .F., .F. )

Return()
*******************************************************************************
Static Function	AtuClisC(oProcess, lEnd)//Atualizando Clientes sem Contato" )
*******************************************************************************

Local lCriaCR := .F.
Local lCriaCA := .F.

DbSelectArea("CSC");DbGotop()
While !EOF()

	lCriaCR := lCriaCA := .F. 
	
	If Empty(CSC->U5_CODCONT) .And. Empty(CSC->AC8_CODCON)
	
	 	lCriaCR := .T. // Criar Contato e Relacao
	
	ElseIf Empty(CSC->U5_CODCONT) .And. !Empty(CSC->AC8_CODCON) 

		lCriaCA := .T. // Criar Contato e Atualizar Relacao

	EndIf
 	
	oProcess:IncRegua2( "Atualizando Contato do Cliente: " + CSC->A1_COD +"-"+ CSC->A1_LOJA )
	
	AtualCR(lCriaCR, lCriaCA)
	
	nCC += 1
	
	DbSelectArea("CSC")
	DbSkip()

EndDO

DbSelectArea("CSC")
DbCloseArea()

Return()
*******************************************************************************
Static Function AtualCR(lCriaCR, lCriaCA)
*******************************************************************************
	
	Local cCodCon := GetSxeNum("SU5","U5_CODCONT")  
	
	  
	DbSelectArea("SU5")
	RecLock("SU5",.T.)
		SU5->U5_CODCONT := cCodCon
		SU5->U5_CONTAT  := "Tele-Cobranca"
		SU5->U5_AUTORIZ := '2'
		SU5->U5_ATIVO   := '1'
		SU5->U5_MSBLQL  := '2'
		SU5->U5_EMAIL   := CSC->A1_EMAIL 
		SU5->U5_DEPTO	:= '003'
		&cCampo.		:= CSC->A1_TEL
	MsUnlock()
	
	ConfirmSx8()
	
	DbSelectArea("AC8")
	If lCriaCR // Cria Relacionamento
	
		RecLock("AC8",.T.)

	ElseIf lCriaCA // Atualiza Relacionamento
		DBGoto(CSC->RECNO)
		RecLock("AC8",.F.)
		
	EndIF

	AC8->AC8_FILIAL  := xFilial("AC8")
	AC8->AC8_FILENT  := xFilial("AC8")
	AC8->AC8_ENTIDA  := "SA1"
	AC8->AC8_CODENT  := CSC->A1_COD+CSC->A1_LOJA
	AC8->AC8_CODCON  := cCodCon
	Msunlock()


Return()
*******************************************************************************
Static Function	SqlConsT(oProcess, lEnd)//Atualizando Contatos sem Telefone" )
*******************************************************************************

Local cSql := ""
Local cTab := "CST" // Contato sem Telefone 
Local dData2Ya := dDatabase - 365 * 2

cSql += "SELECT "
cSql += "  A1.A1_COD, A1.A1_LOJA, " 
cSql += "  Case " 
cSql += "    When A1.A1_TEL = ' ' Then '00 00000000' "
cSql += "Else  Trim(Replace(A1.A1_DDD,'0',''))||' '||Trim(A1.A1_TEL) "
cSql += "    End A1_TEL, "
cSql += "  AC.AC8_CODENT, AC.AC8_CODCON, "
cSql += "  U5.U5_CODCONT, U5.U5_FCOM1, "
cSql += "  NVL(U5.R_E_C_N_O_,0) RECNO "
cSql += "FROM SA1010 A1 FULL JOIN AC8010 AC "
cSql += "ON   AC.AC8_CODENT = A1.A1_COD||A1.A1_LOJA "
cSql += "               FULL JOIN SU5010 U5 "
cSql += "ON   AC.AC8_CODCON =  U5.U5_CODCONT "
cSql += "WHERE AC.AC8_ENTIDA = 'SA1' " 
cSql += "AND TRIM(TRIM(REPLACE(A1.A1_DDD,'0',''))  ||' '  ||TRIM(A1.A1_TEL)) <> NVL(TRIM("+Substr(cCampo,6)+"),' ')  " 
cSql += "AND   EXISTS (SELECT E1_CLIENTE, E1_LOJA FROM SE1010 WHERE E1_FILIAL = ' ' AND E1_EMISSAO >= '20150201' AND D_E_L_E_T_ = ' ' AND E1_CLIENTE = A1_COD AND E1_LOJA = A1_LOJA ) "


oProcess:IncRegua2( "Obtendo Telelfones.." )

U_ExecMySql( cSql , cTab , "Q", .F., .F. )

Return()
*******************************************************************************
Static Function	AtuConsT(oProcess, lEnd)//Atualizando Contatos sem Telefone" )
*******************************************************************************

Local lCriaCR := .F.
Local lCriaCA := .F.

DbSelectArea("CSC");DbGotop()
While !EOF()

	oProcess:IncRegua2( "Atualizando Contato do Cliente " + CST->A1_COD +"-"+ CST->A1_LOJA )
	
	If CST->RECNO > 0 
		DbSelectArea("SU5"	)
		DBGoto(CST->RECNO)
		RecLock("SU5",.F.)
		&cCampo.		:= CST->A1_TEL
		MsUnlock()
	
		nCA += 1
	EndIf
	
	DbSelectArea("CST")
	DbSkip()

EndDO

DbSelectArea("CST")
DbCloseArea()


Return()
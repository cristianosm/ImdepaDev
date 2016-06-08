#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNÇÃO   : AnalizaSX3  | AUTOR : Cristiano Machado  | DATA : 05/06/2010   **
**---------------------------------------------------------------------------**
** DESCRIÇÃO: Analisa campos que existem no sx3 e nao existem no Banco de    **
**            Dados Criandos conforme parametros utilizado                   **
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
User Function AnalizaSX()
*******************************************************************************

	Local oGrp       	:= Nil
	Local bOk        	:= {||nOpcao:=1, oDlgTf:End() }
	Local bCancel    	:= {||nOpcao:=0, oDlgTf:End() }
	Local nOpcao     	:= 0

	Private cDe     	:= Space(3)
	Private cAte    	:= Space(3)

	Private cModo	 	:= ""
	Private cVeri	 	:= "Ambos"

	Private aModo 		:=  {"Simulação","Execução"}
	Private aVeri		:= {"Tabelas","Campos","Ambos"}

	Private oDlgTf   	:= Nil
	Private oProcess	:= Nil
	Private oModo	 	:= Nil
	Private oVeri	 	:= Nil

	DEFINE MSDIALOG oDlgTf TITLE "Tabelas" From 1,1 to 300,300 of oMainWnd PIXEL

	oGrp  := TGroup():New( 15,5,80,100,"Filtro",oDlgTf,CLR_BLACK,CLR_WHITE,.T.,.F. )

	@ 25,10 SAY "De" SIZE 30,7 PIXEL OF oDlgTf
	@ 25,35 MSGET cDe PICTURE "@!" SIZE 30,7 F3 "SX2" PIXEL OF oDlgTf

	@ 40,10 SAY "Até" SIZE 30,7 PIXEL OF oDlgTf
	@ 40,35 MSGET cAte PICTURE "@!" SIZE 30,7 F3 "SX2" PIXEL OF oDlgTf

	@ 55,10 SAY "Verifica:" SIZE 30,7 PIXEL OF oDlgTf
	@ 55,35 MSCOMBOBOX oVeri VAR cVeri ITEMS aVeri SIZE 45,08 OF oDlgTf PIXEL Valid (!Empty(cVeri))

	@ 70,10 SAY "Modo:" SIZE 30,7 PIXEL OF oDlgTf
	@ 70,35 MSCOMBOBOX oModo VAR cModo ITEMS aModo SIZE 45,08 OF oDlgTf PIXEL Valid (!Empty(cModo))

	ACTIVATE MSDIALOG oDlgTf ON INIT EnchoiceBar(oDlgTf,bOk,bCancel) Centered

	If nOpcao == 1
		oProcess := MsNewProcess():New({|lEnd| RunProc(lEnd,oProcess,cDe,cAte)},"Processando em Modo: "+cModo+"...","Lendo...",.T.)
		oProcess:Activate()
	EndIf

Return()
*******************************************************************************
Static Function RunProc(lEnd,oObj,cxDe,cxAte)
*******************************************************************************
	Local cLogTxt 	:= ""
	Local cFile   	:= ""
	Local cMask   	:= "Arquivos Texto (*.TXT) |*.txt|"
	Local cChave  	:= ""
	Local cTable  	:= ""
	Local lTable  	:= .F.
	Local cxEnter 	:= CHR(13)+CHR(10)
	Local cTraco  	:= Replicate("-",130)+cxEnter
	Local cExecSql	:= ""
	Local lSemErro	:= .T.
	Private cLogInsert := ""

	If cModo == "Execução"
		If !(Msgbox("Tem certeza que deseja Executar a operação em Modo: Execução !!!","Atenção","YESNO"))

			GeraLog( ".: Execução Abortada pelo OPERADOR !!!" )

			Return()
		Endif
	Endif

	cDe  := Iif(Empty(cDe),"AAA",cDe)
	cAte := Iif(Empty(cAte),"ZZZ",cAte)

	cLogTxt := ".:: Analiza do Banco de Dados conforme SX3  ::. Start = "+DtoS(Ddatabase)+" "+Time()+cxEnter+cxEnter

	nRegSx2 := 0

	DbSelectArea("SX3");dbSetOrder(1);DbGotop()
	DbSelectArea("SX2");dbSetOrder(1)

	If !DbSeek(cDe,.F.)
		DbSelectArea("SX2");DbGotop()
	Endif

	nPosSx2 := Recno()

	While !EOF() .AND. SX2->X2_CHAVE >= cDe .AND. SX2->X2_CHAVE <= cAte
		nRegSx2	+= 1
		DbSkip()
	EndDo

	nRegSx3 := 30

	oObj:SetRegua1(nRegSx2)
	oObj:SetRegua2(0)

	nCont  := 0

	DbSelectArea("SX2");DbGoto(nPosSx2)
	While !EOF() .AND. SX2->X2_CHAVE >= cDe .AND. SX2->X2_CHAVE <= cAte .And. lSemErro

		IF lEnd
			Return()
		Endif

		nCont++

		lTable := .F.

		cExecSql := ""
		cLogInsert := ""

		oObj:IncRegua1("Lendo Registro do SX2 : "+AllTrim(Str(nCont))+" / "+AllTrim(Str(nRegSx2))+" - Tabela "+Alltrim(SX2->X2_CHAVE))

		cTable := SX2->X2_CHAVE + SM0->M0_CODIGO + "0"

		SX3->(dbSeek(SX2->X2_CHAVE))

		oObj:SetRegua2(30)
		lFirst	:= .T.
		While SX3->(!EOF())	 .AND. SX3->X3_ARQUIVO == SX2->X2_CHAVE


			oObj:IncRegua2("Verificando Campo : "+SX3->X3_CAMPO+" - "+ SX3->X3_TITULO)

			If SX3->X3_ARQUIVO < cDe .OR. SX3->X3_ARQUIVO > cAte
				SX3->(dbSkip())
				Loop
			Endif

			If !lTable //| Ver se existe ah Tabela no Banco:

				cQuery := "Select * from " + cTable

				If ExecMySql( cQuery ) == 0 //| Existe ah Tabela
					lTable := .T.
				Else //| Tabela Nao Existe Conforme Verificacao:{"Tabelas","Campos","Ambos"}

					If cVeri == "Tabelas" .or. cVeri == "Ambos"
						cLogTxt += cxEnter
						cLogTxt += ".:Tabela : " + cTable + " - " +Alltrim(SX2->X2_NOME)+". Nao existe no Banco !!!" + cxEnter
					Endif

					exit

				Endif
			Endif

			If SX3->X3_CONTEXT <> "V"	//| Verifica se eh campo REAL ou VIRTUAL

				cQuery := "Select "+ Alltrim(SX3->X3_CAMPO) +" From " + cTable	//| Verifica se Existe o Campo no Banco
				If  ExecMySql( cQuery ) <> 0

					If cVeri == "Campos" .or. cVeri == "Ambos" //| Tabela Não Existe //| Conforme Verificacao:{"Tabelas","Campos","Ambos"}

						If lFirst //| Primeiro Campo Nao Emcontrado escreve nome tabela

							cLogTxt += cxEnter
							cLogTxt += "**********************************************************************************" + cxEnter
							cLogTxt += ".:Tabela : " + cTable + " - " +SX2->X2_NOME + cxEnter
							lFirst := .F.

							cExecSql := " ALTER TABLE  "+ cTable + cxEnter + " ADD ( " //| Inicia ALTER TABLE

						Endif

						cExecSql +=	Alltrim(SX3->X3_CAMPO)	//| Configura Campos no ALTER TABLE Campo

						If SX3->X3_TIPO == "N" 	//| Tipo do Campo
							cTpCamp := " NUMBER DEFAULT 0.0"
						Else
							nTam := SX3->X3_TAMANHO
							cTpCamp := " CHAR("+Alltrim(str(nTam))+") DEFAULT '" +Space(nTam)+ "'"
						Endif
						cExecSql +=	cTpCamp

						cExecSql +=	" NOT NULL," //| Nao pode Ser NULO

						cLogTxt += " Campo: "+Alltrim(SX3->X3_CAMPO)+" Tipo: "+(SX3->X3_TIPO)+" Tam: "+Alltrim(Str(SX3->X3_TAMANHO))+" Dec: "+Alltrim(Str(SX3->X3_DECIMAL))+". Nao Existe !" + cxEnter

						cRetFunc := FValTopField()//| Top Field

						If !Empty(cRetFunc)
							cLogInsert += cRetFunc + cxEnter

							If cModo == "Execução"

								If ExecMySql( cRetFunc ) <> 0
									cLogTxt += cxEnter + TCSQLERROR() + cxEnter
									lSemErro := .F.
									Exit
								Endif

							Endif

						Endif

					Endif

				EndIf

			Endif

			SX3->(dbSkip())

		EndDo

		If !lSemErro //| Foi Encontradoo Erro
			DbSelectArea("SX2")
			Loop
		EndIf

		If cExecSql <> ""

			cExecSql := Substr(cExecSql, 1, (Len(cExecSql)-1) )

			cExecSql += " )" + cxEnter

			If cModo == "Execução"
				If ExecMySql( cExecSql ) <> 0
					cLogTxt += cxEnter + TCSQLERROR() + cxEnter
					Exit
				Endif
			Else
				cLogTxt +=  cxEnter + cExecSql
			Endif

			If !Empty(cLogInsert)
				cLogTxt += cxEnter + cLogInsert
			Endif

		Endif

		if lTable .And. cModo == "Execução" //| Cria Os Indices ....

			oObj:IncRegua2("Criando Indice da Tabela: "+cTable)

			FDropIndex()

			DbSelectArea(SX2->X2_CHAVE)
			DbCloseArea()

		Endif

		oObj:SetRegua2(0)
		DbSelectArea("SX2")
		dbSkip()

	EndDo

	cLogTxt += +cxEnter+cxEnter+"End = "+DtoS(Ddatabase)+" "+Time()

	GeraLog( cLogTxt )

Return()
*******************************************************************************
Static Function MyQuery( cQuery , cursor )
*******************************************************************************

	IF SELECT( cursor ) <> 0
		dbSelectArea(cursor)
		DbCloseArea(cursor)
	Endif

	TCQUERY cQuery NEW ALIAS (cursor)

Return()
*******************************************************************************
Static Function FValTopField()
*******************************************************************************
	Local cTipo 	:= "C"
	Local cTable  	:= "SIGA."+ SX2->X2_CHAVE + SM0->M0_CODIGO + "0"
	Local aValues  	:= {}
	Local cRetorno 	:= ""

	If SX3->X3_TIPO <> "C" //| Somnente Campos Nao Caracteres Fazem Parte devem ser inseridos na Top_Field
		Do Case
		Case SX3->X3_TIPO == "N" //| Numerico
			cTipo := "P"
		Case SX3->X3_TIPO == "D" //| Data
			cTipo := "D"
		Case SX3->X3_TIPO == "M" //| Memo
			cTipo := "M"
		Case SX3->X3_TIPO == "L" //| Logico
			cTipo := "L"
		EndCase

		AADD(aValues,{ cTable , SX3->X3_CAMPO , cTipo , SX3->X3_TAMANHO , SX3->X3_DECIMAL })

		cRetorno := 	ExecInsert(aValues)

	EndIf

Return(cRetorno)
*******************************************************************************
Static Function ExecMySql( cSql )//| Executa comandos SQL no servidor. ( Query , Tabela , Se Dropa Tabela Antes .T. Or .F. )
*******************************************************************************
	Local nRet := 0 //| 0 == OK / 1 == Erro

	nRet := TCSQLEXEC(cSql)

Return(nRet)
*******************************************************************************
Static Function ExecInsert( aValues )//| Executa comandos SQL no servidor. ( Query , Tabela , Se Dropa Tabela Antes .T. Or .F. )
*******************************************************************************
	Local nRet := 0 //| 0 == OK / 1 == Erro

//|aValues {"SIGA.DCD010","DCD_DTULAL","D","8","0"}

	cSql := "Insert into TOP_FIELD (FIELD_TABLE,FIELD_NAME,FIELD_TYPE,FIELD_PREC,FIELD_DEC) "
	cSql += "Values ('"+ aValues[1][1] + "','"+ Alltrim(aValues[1][2]) +"','"+ aValues[1][3] +"','"+ Alltrim(Str(aValues[1][4])) +"','"+ Alltrim(Str(aValues[1][5])) +"')"

Return(cSql)
*******************************************************************************
Static Function GeraLog( cLogTxt )
*******************************************************************************
	__cFileLog := MemoWrite(Criatrab(,.F.)+".LOG",cLogTxt)

	Define FONT oFont NAME "Tahoma" Size 6,12
	Define MsDialog oDlgMemo Title "Leitura Concluida." From 3,0 to 340,550 Pixel

	@ 5,5 Get oMemo  Var cLogTxt MEMO Size 265,145 Of oDlgMemo Pixel
	oMemo:bRClicked := {||AllwaysTrue()}
	oMemo:oFont:=oFont

	Define SButton  From 153,205 Type 13 Action ({oDlgMemo:End(),Mysend(cLogTxt)}) Enable Of oDlgMemo Pixel
	Define SButton  From 153,235 Type 1 Action oDlgMemo:End() Enable Of oDlgMemo Pixel

	Activate MsDialog oDlgMemo Center

Return()
*******************************************************************************
Static Function Mysend(cTxt)
*******************************************************************************
	Static oDlg
	Static oButton1
	Static oButton2
	Static oGet1
	Static cGet1 := Space(200)
	Static oSay

	DEFINE MSDIALOG oDlg TITLE "Form" FROM 000, 000  TO 150, 300 COLORS 0, 12632256 PIXEL

	@ 031, 015 MSGET oGet1 VAR cGet1 SIZE 114, 010 OF oDlg PICTURE "@!" VALID !Empty(Alltrim(cGet1)) COLORS 0, 16777215 PIXEL
	@ 016, 015 SAY oSay PROMPT "Por favor, entre com seu email ABAIXO:" SIZE 100, 007 OF oDlg PICTURE "@!" COLORS 0, 12632256 PIXEL

	@ 050, 025 BUTTON oButton1 PROMPT "Enviar" SIZE 040, 012 OF oDlg ACTION {||oDlg:End(),DISMAILX(cGet1,cTxt)} PIXEL
	@ 050, 075 BUTTON oButton2 PROMPT "Sair" SIZE 040, 012 OF oDlg ACTION oDlg:End()  PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

Return
*******************************************************************************
Static Function DISMAILX(cMail,cTxt)
*******************************************************************************

	CONNECT SMTP SERVER GETMV("MV_RELSERV") ACCOUNT GETMV("MV_RELACNT") PASSWORD GETMV("MV_RELPSW") RESULT lResult

	If !lResult
		MsgBox('Erro no Envio')
		Return()
	EndIf

	cAccount := GETMV("MV_RELACNT")

	SEND MAIL FROM cAccount 	;
		TO      cMail	        	;
		SUBJECT "Log Sx3 vs Banco" 	;
		BODY cTxt

	DISCONNECT SMTP SERVER

	MsgBox("Email Enviado com Sucesso!")

Return()
*******************************************************************************
Static Function FDropIndex()
*******************************************************************************




Return()
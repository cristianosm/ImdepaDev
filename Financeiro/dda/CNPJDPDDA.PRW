#Include "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CnpjDPDDA ºAutor  ³Cristiano Machado   º Data ³  05/29/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Utilizado para Trocar o CNPJ do Cliente na Recepcao do     º±±
±±º          ³arquivo DDA. Utiliza Tabela SX5->QY faz um DE PARA          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10 Financeiro                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

*********************************************************************
User Function CnpjDPDDA()
*********************************************************************

Local oButton
Local oGroup
Private oDlg
Private oGetDados

Public lHouveAlt := .F.

DEFINE MSDIALOG oDlg TITLE "Cadastro De CNPJ -> Para CNPJ Utilizado no DDA" FROM 000, 000  TO 400, 600 COLORS 0, 16777215 PIXEL

@ 010, 010 GROUP oGroup TO 160, 285 PROMPT "" OF oDlg COLOR 0, 16777215 PIXEL
@ 175, 010 GROUP oGroup TO 195, 155 PROMPT "" OF oDlg COLOR 0, 16777215 PIXEL

oGetDados := FMSNewGet()// Inicializa MsNewGetDados

@ 180, 015 BUTTON oButton PROMPT "Pesquisar"	SIZE 037, 012 	PIXEL OF oDlg 	ACTION ( FPesqui()	) 	PIXEL
@ 180, 065 BUTTON oButton PROMPT "Salvar" 		SIZE 037, 012 	PIXEL OF oDlg 	ACTION ( FSalvar() 	)	PIXEL
@ 180, 115 BUTTON oButton PROMPT "Sair"			SIZE 037, 012 	PIXEL OF oDlg 	ACTION ( FSair()	) 	PIXEL

ACTIVATE MSDIALOG oDlg CENTERED

Return()
*********************************************************************
Static Function FSair()
*********************************************************************

If lHouveAlt

	If Iw_MsgBox("Deseja Sair sem Salvar as Alterações ?","Atenção","YESNO")
		oDlg:End()
	EndIF

Else
	oDlg:End()
EndIf

Return()
*********************************************************************
Static Function FSalvar()// Salva as Alteracoes no SX5 Tabela QY
*********************************************************************

IF lHouveAlt

	If ( IW_MsgBox("Deseja Salvar as Alterações ? ","Atenção","YESNO") )

		cSql := " Delete SX5010 Where X5_Tabela = 'QY' "
		U_ExecMySql(cSql,"","E")

		For I:=1 To ( Len(oGetDados:aCols) )

			If !( oGetDados:aCols[I][5] ) // Nao estiver deletado..

				RecLock("SX5",.T.)
				SX5->X5_FILIAL 	:= xFilial("SX5")
				SX5->X5_TABELA	:= "QY"
				SX5->X5_CHAVE	:= oGetDados:aCols[I][1]
				SX5->X5_DESCRI	:= oGetDados:aCols[I][2]
				SX5->X5_DESCSPA	:= oGetDados:aCols[I][3]
				SX5->X5_DESCENG	:= oGetDados:aCols[I][4]
				MsUnlock()

			EndIf

		Next
		Iw_MsgBox("Alterações Salvas.","Anteção","INFO")

		lHouveAlt := .F.

		oGetDados:SetArray( FGetDados() , .T. )
		oGetDados:ForceRefresh()
	EndIf
Else
	Iw_MsgBox("Não houveram alterações.","Anteção","INFO")
EndIf

Return()
*********************************************************************
Static Function FPesqui()// Pesquisa um CNPJ...
*********************************************************************
Local oComboBox
Local oGet
Local oSButton
Local _cCnpj 	:= Space(14)
Local nComboBox := 1

Static _oDlg

DEFINE MSDIALOG _oDlg TITLE "Pesquisar" FROM 000, 000  TO 080, 480 COLORS 0, 16777215 PIXEL

@ 010, 015 MSCOMBOBOX oComboBox VAR nComboBox ITEMS {"Cnpj De"} SIZE 180, 010 OF _oDlg COLORS 0, 16777215 PIXEL

@ 025, 015 MSGET oGet VAR _cCnpj SIZE 180, 010 OF _oDlg PICTURE "@R 99.999.999/9999-99" COLORS 0, 16777215 F3 "DDASA2" PIXEL

DEFINE SBUTTON oSButton FROM 010, 205 TYPE 01 OF _oDlg ACTION( Pesqui(_cCnpj), _oDlg:End() )	ENABLE
DEFINE SBUTTON oSButton FROM 025, 205 TYPE 02 OF _oDlg ACTION( _oDlg:End() )					ENABLE

ACTIVATE MSDIALOG _oDlg CENTERED

Return()
*********************************************************************
Static Function Pesqui(_cCnpj)// Pesquisa...
*********************************************************************
nPosAchou := 0

For I:= 1 To Len(oGetDados:aCols)

	If ( _cCnpj == oGetDados:aCols[I][2] )
		nPosAchou := I
		exit
	EndIf
Next

If ( nPosAchou > 0 )
	oGetDados:GoTo(nPosAchou)
Else
	oGetDados:GoTo(oGetDados:nAt)
EndIf

Return()
*********************************************************************
Static Function FMSNewGet()// Cria e inicializa MsGetDados
*********************************************************************
Local aHeaderEx 	:= {}
Local aColsEx 		:= {}
Local aFields 		:= {"ID","CNPJD","CNPJP","OBS"} // Peguei estes campos so pelos tamanhos e tipos que sao iguais os que necessito..
Local aAlterFields 	:= {"CNPJD","CNPJP","OBS"}
Local nStyle 		:= GD_INSERT+GD_DELETE+GD_UPDATE
Local cIniCpos 		:= "+ID"   //| "ID+CNPJD+CNPJP+OBS"

Static oMSNewGet

// 	Define Propriedades dos Campos (Header)
//	Aadd(aHeaderEx,{ X3_TITULO		,SX3->X3_CAMPO,SX3->X3_PICTURE			,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
Aadd(aHeaderEx,{ "Id"			,"ID"		,"@!"						,6	,0	,"U_VerAltDDA()"   						,"","C",""					,"",""	,""})
Aadd(aHeaderEx,{ "Cnpj De"	,"CNPJD"	,"@R 99.999.999/9999-99"	,14	,0	,"CGC(M->CNPJD) .And. U_VerAltDDA() .And. U_FPOBSDDA(M->CNPJD,'D')"	,"","C","DDASA2" ,"",""	,""})
Aadd(aHeaderEx,{ "Cnpj Para"	,"CNPJP"	,"@R 99.999.999/9999-99"	,14	,0	,"CGC(M->CNPJP) .And. U_VerAltDDA() .And. U_FPOBSDDA(M->CNPJP,'P')"	,"","C"	,"DDASA2","","",""})
Aadd(aHeaderEx,{ "Obs"		,"OBS"		,"@!"						,50	,0	,"U_VerAltDDA()"						,"","C",""					,"",""	,""} )

//Inicializa Campos...(aCols)
aColsEx := FGetDados()

// Iniciailiza GetDados...
oMSNewGet := MsNewGetDados():New( 015, 015, 155, 280, nStyle,"AllwaysTrue", "AllwaysTrue", cIniCpos, aAlterFields, ,999, "AllwaysTrue", "", "U_VerAltDDA()", oDlg, aHeaderEx, aColsEx , "")

Return(oMSNewGet)
*********************************************************************
User Function FPOBSDDA(_Cnpj,_X)
*********************************************************************
#Define CNPJD 2
#Define CNPJP 3
#Define OBS   4

Local N 	 := oGetDados:nAt
Local cObs 	 := ""
Local cAux	 := ""
Local _CNPJD := oGetDados:acols[N][CNPJD]
Local _CNPJP := oGetDados:acols[N][CNPJP]

If ( _X == "D" )// De
	_CNPJD := _Cnpj
EndIF
If ( _X == "P" )// Para
	_CNPJP := _Cnpj
EndIF

If ( !Empty( _CNPJD ) .And. !Empty( _CNPJP ) )

	cAux := Alltrim(Posicione( "SA2", 3,xFilial("SA2")+_CNPJD, "A2_NREDUZ" ))

	If Empty(cAux)
		cAux := "Não Encontrado"
	EndIf
	cObs += cAux

	cObs += " -->> "

	cAux := Alltrim(Posicione( "SA2", 3,xFilial("SA2")+_CNPJP, "A2_NREDUZ" ))
	If Empty(cAux)
		cAux := "Não Encontrado"
	EndIf
	cObs += cAux

	oGetDados:acols[N][OBS] := cObs

EndIf


Return(.T.)
*********************************************************************
Static Function FGetDados()// Obtem os Dados para o MsGetDados
*********************************************************************
Local aColsEx := {}
Local nId	  := 0

DbSelectArea("SX5")

If DbSeek(xFilial("SX5")+"QY",.F.)
	While ( !EOF() .And. SX5->X5_TABELA == "QY" )

		Aadd( aColsEx, { SX5->X5_CHAVE, Substr(SX5->X5_DESCRI,1,14), Substr(SX5->X5_DESCSPA,1,14), Substr(SX5->X5_DESCENG,1,50), .F.} )

		DbSelectArea("SX5")
		DbSkip()

	EndDo

EndIf

Return( aColsEx )
*********************************************************************
User Function VerAltDDA() // Marca como Alterado, para evitar salvar quando nao e necessario ...
*********************************************************************

lHouveAlt := .T.

Return(.T.)
*********************************************************************
User Function VerDPDDA(_cnpj)/// Verifica se existe DE -> PARA referente ao CNPJ do Parametro e o Retorna
*********************************************************************
Local cSql := ""

cSql := "Select X5_DESCSPA CNPJ From SX5010 Where X5_FILIAL = '  ' And X5_TABELA = 'QY' And X5_DESCRI = '"+_cnpj+"'"

U_ExecMySql(cSql, "TAUX" , "Q" )


If ( TAUX->( !EOF() ) )

	If !Empty(TAUX->CNPJ)
		_cnpj := TAUX->CNPJ
	EndIf

EndIf

Return(_cnpj)

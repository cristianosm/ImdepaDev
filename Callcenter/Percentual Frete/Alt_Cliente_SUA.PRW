
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³U_Alt_Cliente_SUA  ³ Autor ³Márcio Quevedo Borges³ 07/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monitora a alteração do cliente no atendimento, se alterado ³±±
±±³          ³ limpa os dados da rotaa Rotina PE_TMKGRPED                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ESPECIFICO PARA O CLIENTE IMDEPA						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
vALIDAÇÃO PARA O CAMPO UA_CLIENTE
U_SelFrete() .AND. u_Alt_Cliente_SUA(@M->UA_CODROTA,@M->UA_FRETCAL,@M->UA_CODCONT ,	@M->UA_DESCNT)
/*/
User Function Alt_Cliente_SUA()
Local lRet := .T.

IF !EMPTY(__ClienteAtual) .AND. __ClienteAtual <> M->UA_CLIENTE+M->UA_LOJA
//IF   __ClienteAtual <> M->UA_CLIENTE+M->UA_LOJA

    /*
	If Type("lTk271Auto") == "U" .Or. !lTk271Auto
		lRet := .F.
		IW_MSGBOX(Oemtoansi(" Mudou o Cliente  Limpando Rota Selecionada... !"),Oemtoansi('Atenção'),'ALERT')
	Else
		lRet := .T.  //Libera para quando vir do PALM (Proj Rotas)
		ConOut(" Mudou o Cliente  Limpando Rota Selecionada.... Limpando Rota Selecionada... !")
	EndIf
	*/

	M->UA_CODROTA 		:= SPACE(tamSX3("UA_CODROTA")[1])
	M->UA_FRETCAL 		:= 0
	aValores[4] 		:= 0
	Tk273RodImposto("NF_FRETE",aValores[4])
	__RodouRotas			:= .F.


	//----- se Alterou o cliente limpa o contato
	M->UA_CODCONT 	:= SPACE(tamSX3("UA_CODCONT")[1]) // Contato
	M->UA_DESCNT 	:= SPACE(tamSX3("UA_DESCNT")[1])  // Nome Contato

ENDIF
__ClienteAtual := M->UA_CLIENTE+M->UA_LOJA


	//|ANALISTA: CRISTIANO MACHADO DESC.: PERCENTUAL DO FRETE   DATA: 31/07/13
	U_CAMPRODAPE()
	//FIM


Return lRet //M->UA_CLIENTE



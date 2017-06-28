#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#DEFINE  ENTER CHR(13)+CHR(10)
//
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
U_SelFrete() .AND. u_Alt_Cliente_SUA(@M->UA_CODROTA,@M->UA_FRETCAL,@M->UA_CODCONT ,@M->UA_DESCNT) .AND. U_Write_OrcOfert("C")
/*/
*********************************************************************
User Function Alt_Cliente_SUA()
*********************************************************************
Local lRet := .T.

// FABIANO PEREIRA - SOLUTIO
IIF( !ExisteSX6('MV_SEGXTAB'),	CriarSX6('MV_SEGXTAB', 'C','Segmento Cliente x Tabela de Preco', '{{"1","OEM"},{"2","MNT"},{"3","REV"}}' ),)



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
//	U_CAMPRODAPE()
	//FIM

If Len(aProdxImp) > 0

	nAltCli	:=	Ascan(aProdxImp, {|X| Left(AllTrim(X[12]),06) != AllTrim(M->UA_CLIENTE) })
	
	If nAltCli > 0

			cCliente :=	Left(aProdxImp[nAltCli][12],  TamSx3('UA_CLIENTE')[1])
   			cLojaCli :=	Right(aProdxImp[nAltCli][12], TamSx3('UA_LOJA')[1])

           	Alert('NÃO É PERMITIDO TROCAR O CLIENTE QUANDO JÁ INFORMADO PRODUTO \ ITEM.'+ENTER+ENTER+;
           	  	  'VOCÊ DEVE CONCLUIR O ATENDIMENTO COM O CLIENTE: '+cCliente+' \ '+cLojaCli)

            lRet := .F.

	EndIf

Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  CASO USUARIO ALTERE O CLIENTE ZERA OS ARRAYS  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aProdxImp  	:= {}	//	PRODUTO X IMPOSTOS
	aContDesc 	:= {}	//	ARRAY UTILIZADO NA REGRA DE DESCONTO
	aHistTV		:= {}	//	HISTORICO DE ATENDIMENTO
	aRegDesc	:= {}	//	REGRA DE DESCONTO
	aImdCodR 	:= {}	//	CODIGO DA REGRA DE NEGOCIO   
	aATxRN	 	:= {}	//	ATENDIMENTO X REGRA DE NEGOCIO

EndIf


If lRet


	If lProspect
		cTabela	:=	''
		M->UA_DESCSEG	:=	Posicione("ZZV",1,xFilial("ZZV")+SUS->US_GRPSEG,"ZZV_COD") 
	Else

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ FABIANO PEREIRA - SOLUTIO                               ³
		//³ BUSCA TABELA DE PRECO CONFORME SEGMENTO DO CLIENTE.     ³
		//³ OBS.: UTILIZADO NO X3_VLDUSER POIS VIA SX7 NA ATUALIZA  ³
		//| UA_DESC4												|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If AllTrim(SA1->A1_COD+SA1->A1_LOJA) == AllTrim(M->UA_CLIENTE+M->UA_LOJA)
			cCliente	:= 	M->UA_CLIENTE
			cLoja		:= 	M->UA_LOJA
		Else
			DbselectArea("SA1");DbSetOrder(1);DbGoTop()
			DbSeek(xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA)
			IF FOUND()
				cCliente	:= 	SA1->A1_COD
				cLoja		:= 	SA1->A1_LOJA
			Else
				DbSeek(xFilial("SA1")+M->UA_CLIENTE)
				IF FOUND()
					cCliente	  		:= SA1->A1_COD
					cLoja	  		:= SA1->A1_LOJA
					M->UA_LOJA 		:= cLoja
					__ClienteAtual 	:= M->UA_CLIENTE+M->UA_LOJA
				Else
					lRet := .f.
				ENDIF
			EndIf
		EndIf
	
		M->UA_TEL 		:= IIF(!Empty(SA1->A1_DDD), '('+AllTrim(SA1->A1_DDD)+') ', '')+AllTrim(SA1->A1_TEL)
		M->UA_VINCULO	:=	SA1->A1_VINCIMD
		M->UA_DESCSEG	:=	Posicione("ZZV",1,xFilial("ZZV")+SA1->A1_GRPSEG,"ZZV_COD") 
			
		cTabela	:=	SA1->A1_TABELA
	
	EndIf
		
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  RETIRADA CHAMADA QUE VALIDA VIGENCIA DA TABELA DE PRECO             ³
	//³  FUNCAO ADICIONADA NA FUNCAO VERSEDEV() [ FONTE LIBRAY.PRW]          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aValidDA0 := ExecBlock('ChkValidDA0',.F.,.F.,{cTabela})
	If aValidDA0[01]
		M->UA_TABELA := aValidDA0[02]
	EndIf
	*/	

EndIf


//|ANALISTA: CRISTIANO MACHADO DESC.: PERCENTUAL DO FRETE   DATA: 31/07/13
U_CAMPRODAPE()
//FIM



Return lRet
***********************************************************************
User Function ChkValidDA0()
***********************************************************************
Local aArea		:=	GetArea()
Local cCodTab	:=	ParamIxb[01]
Local lValido	:=	IIF(!Empty(cCodTab), .T., .F.)
Local lGatilho	:=	IIF(Type('ParamIxb')== 'A', IIF(Len(ParamIxb)>=2, ParamIxb[02], .F.), .F.)
Local dDataVld 	:=	dDataBase   
Local aRetorno	:=	{.T.,cCodTab}
Local cGrpSeg	:=	''



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a vigencia da tabela de precos                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cCodTab)

	DbSelectArea("DA0");DbSetOrder(1)
	If !MsSeek(xFilial("DA0")+cCodTab)
		lValido	:= .F.
	Else
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifico se a tabela de preço está ativa e depois faço a validação da  ³
		//³ vigencia da tabela de preço, conforme o tipo de hora.                  ³
		//³ DA0_TPHORA = (1-Unico ou 2-Recorrente)                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (DA0->DA0_ATIVO == "2") .Or.;
			(DA0->DA0_TPHORA == "1" .And. !(SubtHoras(dDataVld,Time(),If(Empty(DA0->DA0_DATATE),dDataVld,DA0->DA0_DATATE),DA0->DA0_HORATE) >= 0 .And.;
			SubtHoras(DA0->DA0_DATDE,DA0->DA0_HORADE,dDataVld,Time()) >= 0)) .Or.;
			(DA0->DA0_TPHORA == "2" .And. !(dDataVld >= DA0->DA0_DATDE .And. dDataVld <= If(Empty(DA0->DA0_DATATE),dDataVld,DA0->DA0_DATATE) .And.;
			(SubStr(Time(),1,5) >= DA0->DA0_HORADE .And. SubStr(Time(),1,5) <= DA0->DA0_HORATE)))
		
			If ExistBlock("OM010VIG")
				lValido := ExecBlock("OM010VIG",.F.,.F.,cCodTab)		
			Else 
				lValido := .F.
			EndIf
		EndIf
	
	EndIf

EndIf


If (!lValido .OR. !Empty(cCodTab))
    
	If lProspect
	
		If AllTrim(SUS->US_COD+SUS->US_LOJA) == AllTrim(M->UA_CLIENTE+M->UA_LOJA)
			cCliente	:= 	M->UA_CLIENTE
			cLoja		:= 	M->UA_LOJA
		Else
			DbselectArea("SUS");DbSetOrder(1);DbGoTop()
			If DbSeek(xFilial("SUS")+M->UA_CLIENTE+M->UA_LOJA, .F.)
				cCliente	:= 	SUS->US_COD
				cLoja		:= 	SUS->US_LOJA
			EndIf
		EndIf
		
		cGrpSeg	:= 	SUS->US_GRPSEG
		// M->UA_DESCSEG	:=	Posicione("ZZV",1,xFilial("ZZV")+cGrpSeg,"ZZV_COD") 
		
	Else		

		If AllTrim(SA1->A1_COD+SA1->A1_LOJA) == AllTrim(M->UA_CLIENTE+M->UA_LOJA)
			cGrpSeg	:= 	SA1->A1_GRPSEG
		Else
			DbselectArea("SA1");DbSetOrder(1);DbGoTop()
			If DbSeek(xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA, .F.)
				cGrpSeg	:= 	SA1->A1_GRPSEG
			EndIf
		EndIf
	
	EndIf
												//	  [01] [02]   [02] [02]   [03] [02]
	aTabelas := &(GetMv('MV_SEGXTAB'))			//	{{"1","OEM"},{"2","MNT"},{"3","REV"}}

	nPosTab := Ascan(aTabelas, {|X| X[1] == Right(cGrpSeg,1) })
	If nPosTab > 0 
		aRetorno[01] := .T.
		aRetorno[02] := aTabelas[nPosTab][02] 
	Else
		aRetorno[01] := .F.
		aRetorno[02] := ''
	EndIf

  //Verifica se o cliente possui uma Tabela de Preço Especifica , para Prospect esta regra nao se aplica      
  aRetorno[02]:=IIf(Empty(SA1->A1_TABELA),aRetorno[02] := aRetorno[02],aRetorno[02]:=SA1->A1_TABELA) 
  
EndIf


RestArea(aArea)
Return(IIF(!lGatilho,aRetorno,aRetorno[02]))
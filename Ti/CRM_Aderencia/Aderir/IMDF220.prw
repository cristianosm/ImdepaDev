#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#DEFINE MERCADORIA		1	// Valor total do mercadoria
#DEFINE DESCONTO		2	// Valor total do desconto
#DEFINE ACRESCIMO		3	// Valor do acrescimo financeiro da condicao de pagamento
#DEFINE FRETE   		4	// Valor total do Frete
#DEFINE DESPESA 		5	// Valor total da despesa
#DEFINE TOTAL 			6	// Total do Pedido


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ U_IMDF220       ³ Autor ³Expedito Mendonca Jr³ Data ³ 09/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consultar a posicao de faturamento do vendedor em relacao a    ³±±
±±³          ³ sua meta e como ficaria a meta caso o orcamento atual          ³±±
±±³          ³ se torne um faturamento.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 06/05/06 ³ marcio  |  Alteração para permitir executar de qualquer folder ³±±
±±³          ³                                                                ³±±
±±³          ³                                                                ³±±
±±³          ³                                                                ³±±
±±³          ³                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 - Indica se foi chamado pela tela de Liberacao de Pedidos³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso   	 ³ ESPECIFICO PARA O CLIENTE IMDEPA							   	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function IMDF220(lLibPed)
Local oDlg, oFont,;
aArea := GetArea(),;
aAreaSA3 := SA3->(GetArea()),;
aAreaSUA := SUA->(GetArea())
Local lTelevenda := .F.
Private cCodVen, oMeta, aMeta, aResumo
Private lMetaMensal := .F., lMetaDiaria := .F.
Private cPerg, aDados := {}
Private cTipo := ' '

// Atualiza arquivo de parametros SX1
// aDados := { 1.PERGUNT,2.PERSPA,3.PERENG,4.VARIAVL,5.TIPO,6.TAMANHO,7.DECIMAL,8.PRESEL,9.GSC,10.VALID,11.VAR01,12.DEF01,13.DEFSPA1,14.DEFENG1,15.CNT01,16.VAR02,17.DEF02,18.DEFSPA2,19.DEFENG2,20.CNT2,
//             21.VAR03,22.DEF03,23.DEFSPA3,24.DEFENG3,25.CNT3,26.VAR04,27.DEF04,28.DEFSPA4,29.DEFENG4,30.CNT4,31.VAR05,32.DEF05,33.DEFSPA5,34.DEFENG5,35.CNT5,36.F3,37.PYME,38.GRPSXG}
aAdd(aDados,{ "Qual meta?          ","Qual meta?          ","Qual meta?          ","mv_ch1","N", 1,0,0,"C","","mv_par01","Mensal","Mensal","Mensal","","","Campanha","Campanha","Campanha","","","","","","","","","","","","","","","","","","","" })
aAdd(aDados,{ "Campanha?           ","Campanha?           ","Campanha?           ","mv_ch2","C", 6,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SUO","","" })
cPerg      := "IMDF22"

AjustaSx1( cPerg, aDados )
If !Pergunte(cPerg,.T.)
	Return NIL
Endif

If !lLibPed
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica em qual pasta o usuario esta posicionado 		     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If nFolder == 1 // Telemarketing ou Televendas
		//If cTipoAte == "2" // Televendas
		lTelevenda := .F.
	    //	Endif
	ElseIf nFolder == 2 // Televendas
		lTelevenda := .T.
	Endif

//	lTelevenda := .T. //Liberado para poder ser consultado em qualquer folder
	If !lTelevenda
		IW_MsgBox(Oemtoansi("Esta rotina está disponível apenas para os atendimentos de Televendas !"),'Atenção','ALERT')
		Return NIL
	ElseIf !__lJaBotCPag
		IF  aValores[TOTAL] > 0
				IW_MSGBOX(Oemtoansi("Antes de Rodar esta rotina, clique no botão 'Condições de Pagamento' ou tecle <F6>"),Oemtoansi('Atenção'),'ALERT')
				Return NIL
		Endif
	Endif


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posicionando o atendimento  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectarea("SUA")
	DbSetorder(1)
	MsSeek(xFilial("SUA")+M->UA_NUM)

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o codigo do vendedor                     		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cCodUSR		:= RetCodUsr()
cCodVen		:= Posicione("SA3",7,xFilial("SA3")+cCodUSR,"A3_COD")
cDiretor	:= SA3->A3_DIRETOR
//Verifica se pertence ao parametro de liberacao de diretor mv_diretor
cDiretores  := GETMV("MV_DIRETOR")

If cCodVen $ cDiretores
	cCodVen	:= Posicione("SA3",1,xFilial("SA3")+cDiretor,"A3_COD")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa array com dados da meta              		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par01 == 1	// metas de vendas comuns
	aMeta := { {PadR("Total faturado hoje",50)				,0,0,0 },;
				{PadR("Total faturado hoje (simulado)",50)	,0,0,0 },;
				{PadR("Média diária no mês (exceto hoje)",50)	,0,0,0 },;
				{PadR("Total faturado no mês (exceto hoje)",50) ,0,0,0 },;
				{PadR("Meta do mês",50)		    		   ,0,0,0 },;
				{PadR("Diferença",50)	        		   ,0,0,0 },;
				{PadR("Média diária para meta",50) 		   ,0,0,0 } }
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Localiza a campanha de vendas                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SUO")
	dbSetOrder(1)
	If !dbSeek(xFilial("SUO")+MV_PAR02,.F.)
		IW_MsgBox("Campanha não encontrada","Atenção","STOP")
		Return NIL
	Endif
	aMeta := { {PadR("Total faturado hoje",60)				,0,0 },;
				{PadR("Total faturado hoje (simulado)",60)	,0,0 },;
				{PadR("Média diária",60)		    		,0,0 },;
				{PadR("Total faturado na campanha (exceto hoje)",60) ,0,0 },;
				{PadR("Meta da campanha",60)	    		,0,0 },;
				{PadR("Diferença",60)	        			,0,0 },;
				{PadR("Média diária para meta",60) 	    	,0,0 } }
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa array com resumo das metas           		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aResumo := array( IIF(mv_par01==1,4,2) , 2 )

// realiza o processamento para o preenchimento dos dados das metas de vendas
Processa( {||ProcMetVend(lLibPed)}, "Aguarde...","Processando Metas de Venda" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre a tela para consulta da meta               		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg FROM 00,000 TO 460,610 TITLE OemToAnsi("Metas de Vendas") PIXEL

	// Cabecalho
	@ 3,1 TO 21,305 LABEL OemtoAnsi(cTipo) OF oDlg PIXEL
	@ 10,6 SAY OemToAnsi("Nome: "+SA3->A3_NOME) OF oDlg PIXEL

	DEFINE FONT oFont NAME "Courier New" SIZE 0,-11
	If mv_par01 == 1	// Metas de vendas comuns
		@ 24 ,1 TO 115,305 LABEL OemtoAnsi("Ref. a "+MesExtenso(month(dDataBase))+"/"+strzero(year(dDataBase),4)) OF oDlg PIXEL
		// Metas
		@  31,3 LISTBOX oMeta ;
		FIELDS HEADER OemToAnsi("Descrição"),OemToAnsi("Valores sem IPI    "),OemToAnsi("Margem ") ;
		SIZE 300,81 OF oDlg PIXEL FONT oFont
		oMeta:SetArray(aMeta)
		oMeta:bLine:={||{aMeta[oMeta:nAt,1],;
					Transform(aMeta[oMeta:nAt,2],"@E 999,999,999.99"),;
					Transform(aMeta[oMeta:nAt,3],"@E 9,999.99") } }
		nSomaLin := 0
	Else				// Campanhas de Vendas
		@ 24 ,1 TO 115,305 LABEL OemtoAnsi("Campanha: "+SUO->UO_CODCAMP+" - "+Alltrim(SUO->UO_DESC)) OF oDlg PIXEL
		// Metas
		@  31,3 LISTBOX oMeta ;
		FIELDS HEADER OemToAnsi("Descrição"),OemToAnsi(IIF(SUO->UO_TPMETA=="2","Quantidade","Valores sem IPI    ")) SIZE 300,81 OF oDlg PIXEL FONT oFont
		oMeta:SetArray(aMeta)
		oMeta:bLine:={||{aMeta[oMeta:nAt,1] , Transform(aMeta[oMeta:nAt,2],"@E 999,999,999.99") } }
		nSomaLin := 6
	Endif

	// Resumo
	@ 120,1 TO 161,305 LABEL OemtoAnsi("Meta Mensal") OF oDlg PIXEL
	@ 131+nSomaLin,005 SAY OemToAnsi("Faturamento Real") OF oDlg PIXEL
	@ 131+nSomaLin,052 MSGET aResumo[1,1] OF oDlg PIXEL SIZE 080,7 WHEN .F.
	@ 131+nSomaLin,155 SAY OemToAnsi("Faturamento Simulado") OF oDlg PIXEL
	@ 131+nSomaLin,210 MSGET aResumo[1,2] OF oDlg PIXEL SIZE 080,7	WHEN .F.
	If mv_par01 == 1	// Metas de vendas comuns
		@ 143,005 SAY OemToAnsi("Margem Real") OF oDlg PIXEL
		@ 143,052 MSGET aResumo[2,1] OF oDlg PIXEL SIZE 080,7	WHEN .F.
		@ 143,155 SAY OemToAnsi("Margem Simulada") OF oDlg PIXEL
		@ 143,210 MSGET aResumo[2,2] OF oDlg PIXEL SIZE 080,7 WHEN .F.
	Endif

	@ 169,1 TO 210,305 LABEL OemtoAnsi("Meta Diária") OF oDlg PIXEL
	@ 180+nSomaLin,005 SAY OemToAnsi("Faturamento Real") OF oDlg PIXEL
	@ 180+nSomaLin,052 MSGET aResumo[IIF(mv_par01==1,3,2),1] OF oDlg PIXEL SIZE 080,7 WHEN .F.
	@ 180+nSomaLin,155 SAY OemToAnsi("Faturamento Simulado") OF oDlg PIXEL
	@ 180+nSomaLin,210 MSGET aResumo[IIF(mv_par01==1,3,2),2] OF oDlg PIXEL SIZE 080,7 WHEN .F.
	If mv_par01 == 1	// Metas de vendas comuns
		@ 192,005 SAY OemToAnsi("Margem Real") OF oDlg PIXEL
		@ 192,052 MSGET aResumo[4,1] OF oDlg PIXEL SIZE 080,7 WHEN .F.
		@ 192,155 SAY OemToAnsi("Margem Simulada") OF oDlg PIXEL
		@ 192,210 MSGET aResumo[4,2] OF oDlg PIXEL SIZE 080,7 WHEN .F.
	Endif

	DEFINE SBUTTON FROM 213,260 TYPE 1  ENABLE OF oDlg ACTION oDlg:End()
	If lMetaMensal
		@ 216,6 SAY OemToAnsi("PARABÉNS, VOCÊ ATINGIU A SUA META "+IIF(mv_par01==1,"MENSAL !!!"," NA CAMPANHA !!!")) OF oDlg PIXEL
	Else
		If lMetaDiaria
			@ 216,6 SAY OemToAnsi("PARABÉNS, VOCÊ ATINGIU A SUA META DIÁRIA "+IIF(mv_par01==1,"NA CAMPANHA","")+" !!!") OF oDlg PIXEL
		Endif
	Endif

ACTIVATE MSDIALOG oDlg CENTER

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura o ambiente                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Restarea(aAreaSA3)
Restarea(aAreaSUA)
Restarea(aArea)
Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ PROCMETVEND     ³ Autor ³Expedito Mendonca Jr³ Data ³ 10/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza o processamento para o preenchimento dos dados         ³±±
±±³          ³ referentes as metas de vendas por vendedor.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso   	 ³ U_IMDF220                        						   	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcMetVend(lLibPed)
Local cQuery, nVend := 0, aMetaValMar, nMetaCamp, nI
Local nDecVLRITEM,nSValFat,nSValMargem,nSCusto,nAcreFin,nAcreReal,nCusto,nVlrItem,nDescLucro,nLucro
Local nRVPercMes,nSVPercMes,nRMPercMes,nSMPercMes,nRVPercDia,nSVPercDia,nDifLucro,nRMPercDia,nSMPercDia
Local aAreaSA1 := SA1->(GetArea()), lVendCli
Local nDiasPass, nDiasRest
Local aVendedores
Local nDescIcmPad, nValDifICM
Local nPercFrete, nFreteItem
Local cChaveCli, nValMerc
//Local nTmpLucro, nTmpCusto
Local cFiliais, nRecSM0


ProcRegua(6)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define quais sao todas as filiais                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFiliais := ""
dbSelectArea("SM0")
nRecSM0 := Recno()
dbSeek(cEmpAnt,.F.)
Do While SM0->M0_CODIGO == cEmpAnt .and. !Eof()
	cFiliais += "'" + SM0->M0_CODFIL + "',"
	dbSkip()
Enddo
cFiliais := Left(cFiliais,Len(cFiliais)-1)
dbGoto(nRecSM0)
IncProc()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Determina qual o nivel do vendedor              		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cDiretores  	:= GETMV("MV_DIRETOR")
cGerente 		:= SA3->A3_GEREN
cDiretor			:= SA3->A3_DIRETOR

//| GLPI : [2418]  || Titulo: [Adaptar CRM] || Analista: [cristianosm] || Data: [07/01/2016]
/*If cCodVen $ cDiretores
	nVend := 6
	cTipo := "Diretor de Vendas"
ElseIf SA3->A3_GRPREP $ GETMV("MV_EISVI")+GETMV("MV_EISVE")
	If SA3->A3_TIPO = "I"
		nVend := 1
	Elseif SA3->A3_TIPO = "E"
		nVend := 2
	Endif
	cTipo := "Vendedor"
Elseif SA3->A3_GRPREP $ GETMV("MV_EISCOOR")
	nVend := 3
	cTipo := "Coordenador de Vendas"
Elseif SA3->A3_GRPREP $ GETMV("MV_EISCHVE")
	nVend := 4
	cTipo := "Chefe de Vendas"
Elseif SA3->A3_GRPREP $ GETMV("MV_EISGEVE")
	nVend := 5
	cTipo := "Gerente de Vendas"
Elseif SA3->A3_GRPREP $ GETMV("MV_EISDIVE")
	nVend := 6
	cTipo := "Diretor de Vendas"
Endif
*/
	If !Empty(SA3->A3_NVLVEN)
		nVend := Val(SA3->A3_NVLVEN)
	Else
		 nVend := 0
	EndIf
If nVend = 0
	Alert('Nao serã gerado dados ! Vendedor : '+SA3->A3_COD+' '+SA3->A3_NOME+' Campo A3_NVLVEN nao preenchido !!!')
	Return NIL
Endif

aDados		:= {{0,0,0},{0,0,0}}
X_HOJE		:= 1
X_MES		:= 2
X_VALOR 	:= 1
X_VALMARGEM := 2
X_CUSTO		:= 3

L_FT_HJ			:= 1
L_FT_HJ_SIM		:= 2
L_MEDIA_DIA		:= 3
L_FT_MES		:= 4
L_META_MES		:= 5
L_DIF			:= 6
L_MED_PARAMETA 	:= 7

C_VALOR 	:= 2
C_IMC		:= 3
C_MC 		:= 4



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula os valores faturados                    		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par01 == 1	// Metas de vendas comuns

	// Calcula o total da meta realizado hoje
	QryMetaComum(nVend,.T.,"_META1",cFiliais)
	IncProc()

	// Calcula o total da meta realizado no mes ate ontem
	QryMetaComum(nVend,.F.,"_META2",cFiliais)
	IncProc()


	// Define a quantidade de dias uteis passados e restantes no mes
		nDiasPass := u_diasUteis( ddatabase-1,cFilAnt,FirstDay(ddatabase))
//		nDiasPass := diasUteis(FirstDay(ddatabase),ddatabase-1,cFilAnt)

		nDiasRest := u_diasUteis(lastday(ddatabase),cFilAnt,ddatabase)
//		nDiasRest := diasUteis(ddatabase,lastday(ddatabase),cFilAnt)

	// metas
	//aMetaValMar[1] = meta por valor
	//aMetaValMar[2] = meta por margem
	//aMetaValMar[3] = "meta por valor a ser lucrado"
	//aMetaValMar[4] = "custo da meta"
	aMetaValMar := MetaMes(cCodVen,nVend)

	// atualiza array das metas
	// metas por valor



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³VALOR S/ IPI³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ

	aMeta[L_FT_HJ	 	,C_VALOR] := aDados[X_HOJE][X_VALOR]//_META1->VALOR				// total faturado no dia
	aMeta[L_MEDIA_DIA	,C_VALOR] := aDados[X_MES][X_VALOR]/nDiasPass //_META2->VALOR/nDiasPass	// media diaria
	aMeta[L_FT_MES	 	,C_VALOR] := aDados[X_MES][X_VALOR]//_META2->VALOR				// total faturado no mes
	aMeta[L_META_MES 	,C_VALOR] := aMetaValMar[1]			// meta do mes
	aMeta[L_DIF		 	,C_VALOR] := aMeta[L_META_MES,C_VALOR]-aMeta[L_FT_MES,C_VALOR]		// diferenca  = META MES - FATURADO DO MES (EXCETO HOJE)
	aMeta[L_MED_PARAMETA,C_VALOR] := aMeta[L_DIF,C_VALOR] / nDiasRest	// media diaria para atingir a meta

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³MARGEM % (IMC)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aMeta[L_FT_HJ		,C_IMC] := (aDados[X_HOJE][X_VALMARGEM]/aDados[X_HOJE][X_VALOR])*100//_META1->VALMARGEM //(_META1->VALMARGEM/_META1->CUSTO)*100	// margem realizada no dia
	aMeta[L_MEDIA_DIA	,C_IMC] := (aDados[X_MES][X_VALMARGEM]/aDados[X_MES][X_VALOR])*100//_META2->VALMARGEM //(_META2->VALMARGEM/_META2->CUSTO)*100	// margem realizada no mes
	aMeta[L_FT_MES		,C_IMC] := (aDados[X_MES][X_VALMARGEM]/aDados[X_MES][X_VALOR])*100
	aMeta[L_META_MES	,C_IMC] := aMetaValMar[2]							// meta do mes em margem

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³VALOR MARGEM³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aMeta[L_FT_HJ    	,C_MC] 	:= aMeta[L_FT_HJ    	,C_VALOR] * aMeta[L_FT_HJ    	,C_IMC]/100//aDados[X_HOJE][X_VALMARGEM]	// margem realizada no dia
	aMeta[L_MEDIA_DIA	,C_MC] 	:= aMeta[L_MEDIA_DIA   	,C_VALOR] * aMeta[L_MEDIA_DIA  	,C_IMC]/100//aDados[X_MES][X_VALMARGEM]
	aMeta[L_FT_MES		,C_MC] 	:= aMeta[L_FT_MES    	,C_VALOR] * aMeta[L_FT_MES    	,C_IMC]/100//aDados[X_MES][X_VALMARGEM]	// margem realizada no mes
	aMeta[L_META_MES 	,C_MC] 	:= aMeta[L_META_MES    	,C_VALOR] * aMeta[L_META_MES   	,C_IMC]/100//aMetaValMar[1]*aMetaValMar[2]/100							// meta do mes em margem
	aMeta[L_DIF      	,C_MC] 	:= aMeta[L_META_MES 	,C_MC] - aMeta[L_FT_MES		,C_MC] //( ((aMeta[L_META_MES,C_VALOR] * aMeta[L_META_MES,C_IMC])/100) - ((aMeta[L_FT_MES,C_VALOR]*aMeta[L_FT_MES,C_IMC]) ) /100) //aMeta[L_META_MES,C_IMC]-aMeta[L_FT_MES,C_IMC]					// diferenca
//	aMeta[L_MED_PARAMETA,C_MC]	:= aMeta[L_DIF,C_MC] //( ( aMetaValMar[3] - _META2->VALMARGEM ) / (aMetaValMar[4]-_META2->CUSTO) ) * 100	// media de lucro para atingir a meta


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³MARGEM % (IMC), Dif e meta³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aMeta[L_DIF			,C_IMC] := ( aMeta[L_DIF ,C_MC]/ aMeta[L_DIF,C_VALOR] ) * 100 //aMeta[L_META_MES,C_IMC]-aMeta[L_FT_MES,C_IMC]					// diferenca
	aMeta[L_MED_PARAMETA,C_IMC] := aMeta[L_DIF,C_IMC] //( ( aMetaValMar[3] - _META2->VALMARGEM ) / (aMetaValMar[4]-_META2->CUSTO) ) * 100	// media de lucro para atingir a meta

/*	aMeta[L_FT_HJ	 	,C_IMC] := (aDados[X_HOJE][X_VALMARGEM]/aDados[X_HOJE][X_VALOR])*100//_META1->VALMARGEM //(_META1->VALMARGEM/_META1->CUSTO)*100	// margem realizada no dia
	aMeta[L_MEDIA_DIA,C_IMC] := aMeta[L_FT_MES,C_IMC] := (aDados[X_MES][X_VALMARGEM]/aDados[X_MES][X_VALOR])*100//_META2->VALMARGEM //(_META2->VALMARGEM/_META2->CUSTO)*100	// margem realizada no mes
	aMeta[L_META_MES,C_IMC] := aMetaValMar[2]							// meta do mes em margem
	aMeta[L_DIF,C_IMC] := ( ((aMeta[L_META_MES,C_VALOR] * aMeta[L_META_MES,C_IMC])/100) - ((aMeta[L_FT_MES	 	,C_VALOR]*aMeta[L_FT_MES,C_IMC])/100) / aMeta[L_DIF,C_VALOR] ) * 100 //aMeta[L_META_MES,C_IMC]-aMeta[L_FT_MES,C_IMC]					// diferenca
	aMeta[L_MED_PARAMETA,C_IMC] := aMeta[L_DIF,C_IMC] //( ( aMetaValMar[3] - _META2->VALMARGEM ) / (aMetaValMar[4]-_META2->CUSTO) ) * 100	// media de lucro para atingir a meta

*/

	IncProc()

Else			// Metas de Campanhas de Vendas

	// Calcula o total da meta da campanha realizado hoje
	QryMetaCamp(nVend,.T.,"_META1",cFiliais)
	IncProc()

	// Calcula o total da meta da campanha realizado desde o inicio da campanha ate ontem
	QryMetaCamp(nVend,.F.,"_META2",cFiliais)
	IncProc()

	// Define a quantidade de dias uteis passados e restantes no periodo da campanha
	// verifica se hoje eh dia util
	If DataValida(dDatabase) == dDatabase
		nDiasPass := u_diasUteis( ddatabase,cFilAnt,SUO->UO_DTINI) - 1
	Else
		nDiasPass := u_diasUteis( ddatabase,cFilAnt,SUO->UO_DTINI)
	Endif
	nDiasRest := u_diasUteis(SUO->UO_DTFIM,cFilAnt,SUO->UO_DTINI) - nDiasPass

	// metas
	nMetaCamp := MetaCamp(cCodVen,SUO->UO_CODCAMP,cFiliais)

	// atualiza array das metas das campanhas de vendas
	// metas por valor ou quantidade
	If SUO->UO_TPMETA=="2" // quantidade
		aMeta[L_FT_HJ		,C_VALOR] := _META1->QUANT				// total faturado no dia para a campanha de vendas
		aMeta[L_MEDIA_DIA	,C_VALOR] := _META2->QUANT/nDiasPass	// media diaria de faturamento desde o inicio da campanha
		aMeta[L_FT_MES 		,C_VALOR] := _META2->QUANT				// total faturado na campanha ate ontem
		aMeta[L_META_MES	,C_VALOR] := nMetaCamp					// meta da campanha de vendas
		aMeta[L_DIF			,C_VALOR] := aMeta[L_META_MES,C_VALOR]-aMeta[L_FT_MES	 	,C_VALOR]		// diferenca
		aMeta[L_MED_PARAMETA,C_VALOR] := aMeta[L_DIF,C_VALOR] / nDiasRest	// media diaria para atingir a meta
	Else
		aMeta[L_FT_HJ,C_VALOR] := _META1->VALOR				// total faturado no dia para a campanha de vendas
		aMeta[L_MEDIA_DIA,C_VALOR] := _META2->VALOR/nDiasPass	// media diaria de faturamento desde o inicio da campanha
		aMeta[L_FT_MES	 	,C_VALOR] := _META2->VALOR				// total faturado na campanha ate ontem
		aMeta[L_META_MES,C_VALOR] := nMetaCamp					// meta da campanha de vendas
		aMeta[L_DIF,C_VALOR] := aMeta[L_META_MES,C_VALOR]-aMeta[L_FT_MES	 	,C_VALOR]		// diferenca
		aMeta[L_MED_PARAMETA,C_VALOR] := aMeta[L_DIF,C_VALOR] / nDiasRest	// media diaria para atingir a meta
	Endif
	IncProc()

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Simulando a efetivacao da venda                 		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// Variáveis da simulação do Callcenter
//nDecSUB := TamSx3("UB_VRUNIT")[2]
nDecDesc := TamSx3("UB_DESC")[2]
nDecVLRITEM := TamSx3("UB_VLRITEM")[2]
//nDecBASEICM := TamSx3("UB_BASEICM")[2]
cDescComis := GetMV("MV_COMIDES")
cAcreComis := GetMV("MV_COMIACR")



cChaveCli := IIF(lLibPed,M->C5_CLIENTE+M->C5_LOJACLI,M->UA_CLIENTE+M->UA_LOJA)
dbSelectArea("SA1")
dbSetOrder(1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posicionando Clientes					     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SA1->(DbSeek(xFilial("SA1")+cChaveCli))
aVendedores := { {SA1->A1_VENDEXT},{SA1->A1_VEND},{SA1->A1_VENDCOO},{SA1->A1_CHEFVEN},{SA1->A1_GERVEN} }

If nVend == 6	// diretoria
	lVendCli := .T. //	lVendCli := .F.
Else
	lVendCli := (cCodVen == aVendedores[nVend,1])
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca informacoes do cadastro de vendedores          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nRecSA3 := SA3->(Recno())
dbSelectArea("SA3");DBSETORDER(1)
For nX := 1 to Len(aVendedores)
	SA3->(DbSeek(xFilial("SA3")+aVendedores[nX,1]))
	aAdd(aVendedores[nX],SA3->A3_COMIS)
Next
SA3->(DBGoto(nRecSA3))

//percentual de comissão do cliente
nPerComisCLI := SA1->A1_COMIS
nPerComisREP := SA1->A1_COMISRE

cPAGCOM1  	:= 	SA1->A1_PAGCOM1
cPAGCOM2	:= 	SA1->A1_PAGCOM2
cPAGCOM3	:=	SA1->A1_PAGCOM3
cPAGCOM4	:=	SA1->A1_PAGCOM4
cPAGCOM5	:=	SA1->A1_PAGCOM5



If !lLibPed	  		// Tela da Verdade (Atendimento do Call Center)
	If (!Inclui .and. SUA->UA_OPER == "1" .and. !Empty(SUA->UA_DOC)) .or. !lVendCli   //Venda ja realizada ou o operador nao eh um dos vendedores deste cliente
		// nao existe simulacao
		If mv_par01 == 1	// Metas de vendas comuns
			aMeta[L_FT_HJ_SIM,C_VALOR] := aMeta[L_FT_HJ	,C_VALOR]	// total faturado no dia
			aMeta[L_FT_HJ_SIM,C_IMC]   := aMeta[L_FT_HJ	,C_IMC]	// margem realizada no dia
			aMeta[L_FT_HJ_SIM,C_MC]		:= aMeta[L_FT_HJ_SIM,C_VALOR] * aMeta[L_FT_HJ_SIM,C_IMC] / 100
			nSValMargem:=0
		Else				// Campanha de Vendas
			aMeta[L_FT_HJ_SIM,C_VALOR] := aMeta[L_FT_HJ,C_VALOR]	// total faturado no dia
		Endif
	Else
		// simula que o orcamento posicionado sera aprovado

		If mv_par01 == 1	// Metas de vendas comuns
			//Define o desconto de ICMS padrao
			//nDescIcmPad := U_DesICMPad(SA1->A1_EST )
			//U_DesICMPad(SA1->A1_EST,@nDescIcmPad )

			//Inserido por Edivaldo Goncalves Cordeiro em 30/11/11
			nDescIcmPad:=SUB->(U_DesICMPad(SA1->A1_EST ))

			nSValFat   :=0
			nSValMargem:=0
			nSCusto := 0
			for nI := 1 to Len(aCols)
				If !gdDeleted(nI) .and. !Empty(gdFieldGet('UB_PRODUTO',nI))

					/*
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Valor a ser faturado                            		     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nSValFat += Round(gdFieldGet('UB_VRCACRE',nI)*gdFieldGet('UB_QUANT',nI),nDecVLRITEM) //Valor sem IPI

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Lucro a ser obtido                              		     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					// Define variaveis para calculo de custo total e lucro
					nAcreFin  := 1 + (Posicione("SE4",1,xFilial("SE4")+M->UA_CONDPG,"E4_ACRSFIN") / 100)
					nAcreReal := 1 + (SE4->E4_ACRREAL / 100)

				    // Define o custo do item (na moeda 1)
    				nCusto := ( U_PrcBase( gdFieldGet('UB_PRODUTO',nI),M->UA_TABELA,,.F. ) * gdFieldGet('UB_QUANT',nI) ) + gdFieldGet('UB_CUSTEMB',nI)
			    	// converte o valor total do item para moeda 1
				    nVlrItem := IIF(M->UA_MOEDA==1,gdFieldGet('UB_VLRITEM',nI),xMoeda(gdFieldGet('UB_VLRITEM',nI),M->UA_MOEDA,1,dDataBase,nDecVLRITEM))
				  	// Define o desconto a ser aplicado no lucro devido ao acrescimo financeiro
			    	nDescLucro := (nVlrItem * nAcreReal) - (nVlrItem * nAcreFin)
				   	// Calcula o valor da diferenca de ICMS
					nValDifICM := nVlrItem * ( (nDescIcmPad - gdFieldget('UB_DESCICM',nI)) / 100 )
					// Faz o rateio do frete quando for CIF
					If M->UA_TPFRETE == "C"
						nPercFrete := aValores[4] / aValores[1]
						nFreteItem := nPercFrete * nVlrItem
					Else
						nFreteItem := 0
					Endif


					// Calcula o lucro obtido descontando o valor referente ao acrescimo financeiro
					nLucro := nVlrItem - nCusto - nDescLucro + nValDifICM - nFreteItem
					// Acumula o lucro a ser obtido total na venda e o custo que a venda acarretaria
					nSValMargem += nLucro
					nSCusto += nCusto
					*/


					cTabPreco	:= M->UA_TABELA
					cMoeda		:= M->UA_MOEDA
					cCondPag 	:= M->UA_CONDPG


					cProduto 	:= gdFieldGet('UB_PRODUTO',nI)
					cLocal	 	:= gdFieldGet('UB_LOCAL',nI)
					nVlrItem 	:= gdFieldGet('UB_VRCACRE',nI)
					nBASEICM 	:= gdFieldGet('UB_BASEICM',nI)
					nQtdItem 	:= gdFieldGet('UB_QUANT',nI)
					nDescIcm 	:= gdFieldGet('UB_DESCICM',nI)
					nFreteCal	:= M->UA_FRETCAL
					nValmerc 	:= M->UA_VALMERC + M->UA_ACRECND // VALOR COM ACRESCIMO (PS. NO UA_VALMERC NÃO ESTÁ CONTIDO O ACRESCIMO)
					nDespesa	:= M->UA_DESPESA

					nIdade 		:= 0

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Posicionando Estoque, se for transrfeência, busca do estoque da filial de transferência   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					// Utilizar a pesquisa de estoque na filial de transferencia somente
					// no atendimento (tmk271), no faturamento verificar o estoque atual
					IF FUNNAME() == 'TMKA271' .AND. !Empty(GdFieldGet('UB_FILTRAN',nI))
						cFilialB2	:= GdFieldGet('UB_FILTRAN',nI)
						cLocalB2 	:= Posicione("SB1",1,cFilialB2+cProduto,"B1_LOCPAD")
					ELSE
						cFilialB2	:= xFilial('SB2')
						cLocalB2 	:= cLocal
					ENDIF

					SB2->(DbSeek(cFilialB2+cProduto+cLocalB2))


					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Posicionando Produtos         			     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					SB1->(DbSeek(xFilial("SB1")+cProduto))


					//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
					//º                        CUSTOS        (OBS: qualquer alteração aqui, faça também no M460FIM        º
					//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼


					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³     CAMPANHAS DE VENDAS								³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					nPrcMin := 0
					aComisCamp := {0,0,0,0,0}
					for nJ := 1 to Len(__aProdCamp)
						If __aProdCamp[nJ] != NIL .and. __aProdCamp[nJ,1] == GdFieldGet('UB_PRODUTO',nI)
							If nPrcMin == 0 .or. (__aProdCamp[nJ,4] < nPrcMin .and. __aProdCamp[nJ,4] != 0)
								nPrcMin := __aProdCamp[nJ,4]
							Endif
							// Verifica o menor percentual de comissao das campanhas de vendas ativas para cada vendedor
							for nK := 1 to Len(aComisCamp)
								If __aProdCamp[nJ,6] != "2" .or. ZZA->(dbSeek(xFilial("ZZA")+__aProdCamp[nJ,2]+aVendedores[nK,1]+str(nK,1),.F.))
									If aComisCamp[nK] == 0 .or. (__aProdCamp[nJ,5] < aComisCamp[nK] .and. __aProdCamp[nJ,5] != 0)
										aComisCamp[nK] := __aProdCamp[nJ,5]
									Endif
								Endif
							next
						Endif
					next


					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Faz a avaliacao comercial conforme alcada do operador     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nPrcTabBase := MaTabPrVen(GetMV("MV_TABPAD"),GdFieldGet('UB_PRODUTO',nI),GdFieldGet('UB_QUANT',nI),M->UA_CLIENTE,M->UA_LOJA,M->UA_MOEDA)
					If nPrcTabBase > 0
						nPrBaseDesc := GdFieldGet('UB_VRUNIT',nI) / (1 - (GdFieldGet('UB_DESCICM',nI)/100))
						nDifIcmUnit := nPrBaseDesc * ( (nDescIcmPad - GdFieldGet('UB_DESCICM',nI)) / 100 )
						nDescReal := NoRound( (1-((nPrBaseDesc+nDifIcmUnit) / nPrcTabBase)) * 100 , nDecDesc )
					Endif


						n_COMIS1  := u_DefComis(aVendedores[1,1],aVendedores[1,2],cDescComis,cAcreComis,nPerComisCLI,cPAGCOM1,,SB1->B1_COMIS ,  IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0)   ) + aComisCamp[1]
						n_COMIS2  := u_DefComis(aVendedores[2,1],aVendedores[2,2],cDescComis,cAcreComis,nPerComisCLI,cPAGCOM2,nPerComisREP,SB1->B1_COMIS ,  IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0)   ) + aComisCamp[2]
						n_COMIS3  := u_DefComis(aVendedores[3,1],aVendedores[3,2],cDescComis,cAcreComis,nPerComisCLI,cPAGCOM3,,SB1->B1_COMIS ,  IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0)   ) + aComisCamp[3]
						n_COMIS4  := u_DefComis(aVendedores[4,1],aVendedores[4,2],cDescComis,cAcreComis,nPerComisCLI,cPAGCOM4,,SB1->B1_COMIS ,  IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0)   ) + aComisCamp[4]
						n_COMIS5  := u_DefComis(aVendedores[5,1],aVendedores[5,2],cDescComis,cAcreComis,nPerComisCLI,cPAGCOM5,,SB1->B1_COMIS ,  IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0)   ) + aComisCamp[5]
                  //alert('COMIS1 =  ' + STR(n_COMIS1) + 'COMIS2 =  ' + STR(n_COMIS2) + 'COMIS3 =  ' + STR(n_COMIS3) + 'COMIS4 =  ' + STR(n_COMIS4) + 'COMIS5 =  ' + STR(n_COMIS5) )
					// Define o custo do item (na moeda 1)
					//Custo Margem de Contribuição
					nCustoMC   :=  SB2->B2_CM1


					nVlrItem := IIF(cMoeda==1,nVlrItem,xMoeda(nVlrItem,cMoeda,1,dDataBase,nDecVLRITEM))

					// Faz o Rateio do frete quando for CIF

					If M->UA_TPFRETE == "C"
						nFreteItem	:= nFreteCal / nValmerc	* nVlrItem
					Else
						nFreteItem := 0
					Endif

					IF (cUFOri $ 'MT') // Se for estado de GO ou MT  o icm é zerado
						nValICM := 0
					ELSE
						nValICM :=	mafisret(nI,"IT_VALICM")
					ENDIF

					nImpostosnoVlrItem := nValICM + mafisret(nI,"IT_VALPS2") + mafisret(nI,"IT_VALCF2")  // ver funções padrões do siga

					nVDescComis := nQtdItem * nVlrItem * ( (n_COMIS1 * 1.63)  + n_COMIS2 + (n_COMIS3 * 1.63)  + (n_COMIS4 * 1.63) + n_COMIS5)/100

					nIdade := u_IdadeAtu(nQtdItem,SB2->B2_IDADE,SB2->B2_DTIDADE)

					nTJLPdia  := (1+ (GetMV("MV_TJLP",,0) /100)/12)^(1/30) -1 //(1+ (GetMV("MV_TJLP",,0) /100))^(1/365) -1

					nCOEFC:= SB2->B2_COEFC
					nCOEFF:= SB2->B2_COEFF
					nCOEFI:= ((1+ nTJLPdia)^nIdade)- 1

					nFat1 := SB2->B2_COEFC * nCustoMC
					nFat2 := SB2->B2_COEFF * nCustoMC
					nFat3 := nCOEFI 	   * (nCustoMC+ nfat1 + nfat2)
					nFatores := nFat1 + nFat2 + nFat3
					nTotItemSemIPI := MaFisRet(nI,"IT_TOTAL") - MaFisRet(nI,"IT_VALIPI")
//				  	nTotItemSemIPI := Round(gdFieldGet('UB_VRCACRE',nI)*gdFieldGet('UB_QUANT',nI),nDecVLRITEM) //Valor sem IPI						//MaFisRet(nI,"IT_TOTAL") - MaFisRet(nI,"IT_VALIPI")

					//************************
					//Custo médio kardex Gerencial
					nCustoMCg 			:=  nFatores + nCustoMC
					nTxFin  			:=  GETMV("MV_TXFIN",,0)/100  // Similar a Taxa CDI , mas ao mês
					nValCPMF	    	:=  GETMV("MV_CPMF" ,,0)/100  * MaFisRet(nI,"IT_TOTAL")
					nPrazoMedioCobr 	:= 	SE4->E4_PRZMED //criar campo
					nTaxaDiaria 		:= (1 + nTxFin )^(1/30) -1
					nValorDeflacionado 	:= (nTotItemSemIPI / ((1 + nTaxaDiaria) ^ nPrazoMedioCobr ))

					// Margem de Contribuicao não Gerencial (sem os fatores -> F1, F2, F3 ...)

					nSValFat 	 += nTotItemSemIPI
					nSValMargem	 += nValorDeflacionado - (nValCPMF + nCustoMC   * nQtdItem + nImpostosnoVlrItem + nVDescComis + nFreteItem)

				Endif
			next


			// atualiza valores simulados
			aMeta[L_FT_HJ_SIM,C_VALOR] 	:= aMeta[L_FT_HJ,C_VALOR]+ nSValFat		// total faturado no dia simulado
			aMeta[L_FT_HJ_SIM,C_IMC] 	:= ((aMeta[L_FT_HJ,C_MC] + nSValMargem)/ aMeta[L_FT_HJ_SIM	,C_VALOR])*100 //((_META1->VALMARGEM+nSValMargem)/(_META1->CUSTO+nSCusto))*100	// margem realizada no dia simulado
			aMeta[L_FT_HJ_SIM,C_MC]		:= aMeta[L_FT_HJ_SIM,C_VALOR] * aMeta[L_FT_HJ_SIM,C_IMC] / 100

			aMeta[L_FT_HJ_SIM,C_VALOR] 	-= 	aValores[DESPESA] // // RETIRANDO A DESPESA DO FATURAMENTO POIS ESTA RODANDO VIA FUNCOES FISCAIS QUE RATEIA A DESPESA

		Else				// Campanha de Vendas

			nSValFat:=0
			for nI := 1 to Len(aCols)
				If !gdDeleted(nI) .and. !Empty(gdFieldGet('UB_PRODUTO',nI)) .and. IMDF220Camp(gdFieldGet('UB_PRODUTO',nI),mv_par02)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Valor a ser faturado                            		     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nTmp := IIF(M->UA_MOEDA == SUO->UO_MOEDA , gdFieldGet('UB_VRCACRE',nI) , xMoeda(gdFieldGet('UB_VRCACRE',nI),M->UA_MOEDA,SUO->UO_MOEDA,dDataBase,nDecVLRITEM) )
					nSValFat += IIF(SUO->UO_TPMETA=="2" , gdFieldGet('UB_QUANT',nI) , Round(nTmp*gdFieldGet('UB_QUANT',nI),nDecVLRITEM) )
				Endif
			next
			// atualiza valores simulados
			aMeta[L_FT_HJ_SIM,C_VALOR] := aMeta[L_FT_HJ	,C_VALOR]+nSValFat											// total faturado no dia simulado

		Endif

	Endif

Else		// Tela de Liberacao do Pedido de Venda

	If  !lVendCli .or. !Empty(SC5->C5_NOTA)   //Operador nao eh um dos vendedores deste cliente ou a nota fiscal ja foi gerada
		// nao existe simulacao
		If mv_par01 == 1	// Metas de vendas comuns
			aMeta[L_FT_HJ_SIM,C_VALOR] 	:= aMeta[L_FT_HJ,C_VALOR]	// total faturado no dia
			aMeta[L_FT_HJ_SIM,C_IMC] 	:= aMeta[L_FT_HJ,C_IMC]	// margem realizada no dia
			aMeta[L_FT_HJ_SIM,C_MC]		:= aMeta[L_FT_HJ_SIM,C_VALOR] * aMeta[L_FT_HJ_SIM,C_IMC] / 100
			nSValMargem:=0
		Else				// Campanha de vendas
			aMeta[L_FT_HJ_SIM,C_VALOR] := aMeta[L_FT_HJ	,C_VALOR]	// total faturado no dia
		Endif
	Else
		If mv_par01 == 1	// Metas de vendas comuns
			// Calcula o total das mercadorias
			nValMerc := 0

			//Define o desconto de ICMS padrao
			//nDescIcmPad := U_DesICMPad(SA1->A1_EST)
			U_DesICMPad(SA1->A1_EST,@nDescIcmPad )

			// simula que o pedido de venda ira gerar NF
		    nDecVLRITEM := TamSx3("D2_TOTAL")[2]
			nSValFat:=0
			nSValMargem:=0
			nSCusto := 0
/*
			for nI := 1 to Len(aCols)
				If !gdDeleted(nI)
					nValMerc += gdFieldGet("C6_VALOR",nI)
				Endif
			next
*/

			for nI := 1 to Len(aCols)
				If !gdDeleted(nI)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Valor a ser faturado                            		     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nSValFat += Round(gdFieldGet('C6_PRCACRE',nI)*gdFieldGet('C6_QTDVEN',nI),nDecVLRITEM)

/*
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Lucro a ser obtido                              		     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					// Define variaveis para calculo de custo total e lucro
					nAcreFin  := 1 + (Posicione("SE4",1,xFilial("SE4")+M->C5_CONDPAG,"E4_ACRSFIN") / 100)
					nAcreReal := 1 + (SE4->E4_ACRREAL / 100)


				    // Define o custo do item (na moeda 1)
	    			nCusto := ( U_PrcBase( gdFieldGet('C6_PRODUTO',nI),M->C5_TABELA,,.F. ) * gdFieldGet('C6_QTDVEN',nI) ) + gdFieldGet('C6_CUSTEMB',nI)
			    	// converte o valor total do item para moeda 1
				    nVlrItem := IIF(M->C5_MOEDA==1,gdFieldGet('C6_VALOR',nI),xMoeda(gdFieldGet('C6_VALOR',nI),M->C5_MOEDA,1,dDataBase,nDecVLRITEM))
				  	// Define o desconto a ser aplicado no lucro devido ao acrescimo financeiro
			    	nDescLucro := (nVlrItem * nAcreReal) - (nVlrItem * nAcreFin)
				   	// Calcula o valor da diferenca de ICMS
					nValDifICM := nVlrItem * ( (nDescIcmPad - gdFieldget('C6_DESCICM',nI)) / 100 )
					// Faz o rateio do frete quando for CIF
					If M->C5_TPFRETE == "C"
						nPercFrete := M->C5_FRETE / nValMerc
						nFreteItem := nPercFrete * nVlrItem
					Else
						nFreteItem := 0
					Endif
					// Calcula o lucro obtido descontando o valor referente ao acrescimo financeiro
					nLucro := nVlrItem - nCusto - nDescLucro + nValDifICM - nFreteItem
					// Acumula o lucro a ser obtido total na venda e o custo que a venda acarretaria
					nSValMargem += nLucro
					nSCusto += nCusto

*/

/*

					cTabPreco	:= M->C5_TABELA
					cMoeda		:= M->C5_MOEDA
					cCondPag 	:= M->C5_CONDPG


					cProduto 	:= gdFieldGet('C6_PRODUTO',nI)
					cLocal	 	:= gdFieldGet('C6_LOCAL',nI)
					nVlrItem 	:= gdFieldGet('UB_VRCACRE',nI)
					nBASEICM 	:= gdFieldGet('UB_BASEICM',nI)
					nQtdItem 	:= gdFieldGet('C6_QTDVEN',nI)
					nDescIcm 	:= gdFieldGet('C6_DESCICM',nI)
					nFreteCal	:= M->UA_FRETCAL
					nValmerc 	:= M->UA_VALMERC + M->UA_ACRECND // VALOR COM ACRESCIMO (PS. NO UA_VALMERC NÃO ESTÁ CONTIDO O ACRESCIMO)
					nDespesa	:= M->UA_DESPESA

					nIdade 		:= 0

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Posicionando Estoque, se for transrfeência, busca do estoque da filial de transferência   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					// Utilizar a pesquisa de estoque na filial de transferencia somente
					// no atendimento (tmk271), no faturamento verificar o estoque atual
					IF !Empty(GdFieldGet('C6_FILTRAN',nI))
						cFilialB2	:= GdFieldGet('C6_FILTRAN',nI)
						cLocalB2 	:= Posicione("SB1",1,cFilialB2+cProduto,"B1_LOCPAD")
					ELSE
						cFilialB2	:= xFilial('SB2')
						cLocalB2 	:= cLocal
					ENDIF

					SB2->(DbSeek(cFilialB2+cProduto+cLocalB2))


					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Posicionando Produtos         			     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					SB1->(DbSeek(xFilial("SB1")+cProduto))


					//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
					//º                        CUSTOS        (OBS: qualquer alteração aqui, faça também no M460FIM        º
					//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼


					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³     CAMPANHAS DE VENDAS								³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					nPrcMin := 0
					aComisCamp := {0,0,0,0,0}
					for nJ := 1 to Len(__aProdCamp)
						If __aProdCamp[nJ] != NIL .and. __aProdCamp[nJ,1] == GdFieldGet('C6_PRODUTO',nI)
							If nPrcMin == 0 .or. (__aProdCamp[nJ,4] < nPrcMin .and. __aProdCamp[nJ,4] != 0)
								nPrcMin := __aProdCamp[nJ,4]
							Endif
							// Verifica o menor percentual de comissao das campanhas de vendas ativas para cada vendedor
							for nK := 1 to Len(aComisCamp)
								If __aProdCamp[nJ,6] != "2" .or. ZZA->(dbSeek(xFilial("ZZA")+__aProdCamp[nJ,2]+aVendedores[nK,1]+str(nK,1),.F.))
									If aComisCamp[nK] == 0 .or. (__aProdCamp[nJ,5] < aComisCamp[nK] .and. __aProdCamp[nJ,5] != 0)
										aComisCamp[nK] := __aProdCamp[nJ,5]
									Endif
								Endif
							next
						Endif
					next


					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Faz a avaliacao comercial conforme alcada do operador     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nPrcTabBase := MaTabPrVen(GetMV("MV_TABPAD"),GdFieldGet('C6_PRODUTO',nI),GdFieldGet('C6_QTDVEN',nI),M->C5_CLIENTE,M->C5_LOJA,M->C5_MOEDA)
					If nPrcTabBase > 0
						nPrBaseDesc := GdFieldGet('C6_PRUNIT',nI) / (1 - (GdFieldGet('C6_DESCICM',nI)/100))
						nDifIcmUnit := nPrBaseDesc * ( (nDescIcmPad - GdFieldGet('C6_DESCICM',nI)) / 100 )
						nDescReal := NoRound( (1-((nPrBaseDesc+nDifIcmUnit) / nPrcTabBase)) * 100 , nDecDesc )
					Endif


						n_COMIS1  := u_DefComis(aVendedores[1,1],aVendedores[1,2],cDescComis,cAcreComis,nPerComisCLI,cPAGCOM1,,SB1->B1_COMIS ,  IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0)   ) + aComisCamp[1]
						n_COMIS2  := u_DefComis(aVendedores[2,1],aVendedores[2,2],cDescComis,cAcreComis,nPerComisCLI,cPAGCOM2,nPerComisREP,SB1->B1_COMIS ,  IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0)   ) + aComisCamp[2]
						n_COMIS3  := u_DefComis(aVendedores[3,1],aVendedores[3,2],cDescComis,cAcreComis,nPerComisCLI,cPAGCOM3,,SB1->B1_COMIS ,  IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0)   ) + aComisCamp[3]
						n_COMIS4  := u_DefComis(aVendedores[4,1],aVendedores[4,2],cDescComis,cAcreComis,nPerComisCLI,cPAGCOM4,,SB1->B1_COMIS ,  IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0)   ) + aComisCamp[4]
						n_COMIS5  := u_DefComis(aVendedores[5,1],aVendedores[5,2],cDescComis,cAcreComis,nPerComisCLI,cPAGCOM5,,SB1->B1_COMIS ,  IIF(nDescReal<0,0,nDescReal) ,IIF(nDescReal<0,nDescReal*-1,0)   ) + aComisCamp[5]

					// Define o custo do item (na moeda 1)
					//Custo Margem de Contribuição
					nCustoMC   :=  SB2->B2_CM1


					nVlrItem := IIF(cMoeda==1,nVlrItem,xMoeda(nVlrItem,cMoeda,1,dDataBase,nDecVLRITEM))

					// Faz o Rateio do frete quando for CIF

					If M->C5_TPFRETE == "C"
						nFreteItem	:= nFreteCal / nValmerc	* nVlrItem
					Else
						nFreteItem := 0
					Endif

					IF (cUFOri $ 'GO/MT') // Se for estado de GO ou MT  o icm é zerado
						nValICM := 0
					ELSE
						nValICM :=	mafisret(nI,"IT_VALICM")
					ENDIF

					nImpostosnoVlrItem := nValICM + mafisret(nI,"IT_VALPS2") + mafisret(nI,"IT_VALCF2")  // ver funções padrões do siga


					nVDescComis := nVlrItem * ( (n_COMIS1 * 1.63)  + n_COMIS2 + (n_COMIS3 * 1.63)  + (n_COMIS4 * 1.63) + n_COMIS5)/100

					nIdade := u_IdadeAtu(nQtdItem,SB2->B2_IDADE,SB2->B2_DTIDADE)

					nTJLPdia  := (1+ (GetMV("MV_TJLP",,0) /100)/12)^(1/30) -1 //(1+ (GetMV("MV_TJLP",,0) /100))^(1/365) -1

					nCOEFC:= SB2->B2_COEFC
					nCOEFF:= SB2->B2_COEFF
					nCOEFI:= ((1+ nTJLPdia)^nIdade)- 1

					nFat1 := SB2->B2_COEFC * nCustoMC
					nFat2 := SB2->B2_COEFF * nCustoMC
					nFat3 := nCOEFI 	   * (nCustoMC+ nfat1 + nfat2)
					nFatores := nFat1 + nFat2 + nFat3

				  	nTotItemSemIPI := Round(gdFieldGet('C6_PRCACRE',nI)*gdFieldGet('C6_QTDVEN',nI),nDecVLRITEM) //Valor sem IPI						//MaFisRet(nI,"IT_TOTAL") - MaFisRet(nI,"IT_VALIPI")

					//************************
					//Custo médio kardex Gerencial
					nCustoMCg 			:=  nFatores + nCustoMC
					nTxFin  			:=  GETMV("MV_TXFIN",,0)/100  // Similar a Taxa CDI , mas ao mês
					nValCPMF	    	:=  GETMV("MV_CPMF" ,,0)/100  * MaFisRet(nI,"IT_TOTAL")
					nPrazoMedioCobr 	:= 	SE4->E4_PRZMED //criar campo
					nTaxaDiaria 		:= (1 + nTxFin )^(1/30) -1
					nValorDeflacionado 	:= (nTotItemSemIPI / ((1 + nTaxaDiaria) ^ nPrazoMedioCobr ))

					// Margem de Contribuicao não Gerencial (sem os fatores -> F1, F2, F3 ...)

					nSValFat 	 += nTotItemSemIPI
					nSValMargem	 += nValorDeflacionado - (nValCPMF + nCustoMC   * nQtdItem + nImpostosnoVlrItem + nVDescComis + nFreteItem)
*/
					nSValMargem	 += Round(gdFieldGet('C6_MC',nI),nDecVLRITEM)

				Endif
			next
			nSValFat += M->C5_DESPESA
			// atualiza valores simulados
			aMeta[L_FT_HJ_SIM,C_VALOR] 	:= aMeta[L_FT_HJ	,C_VALOR]+ nSValFat											// total faturado no dia simulado
			aMeta[L_FT_HJ_SIM,C_IMC] 	:= ((aMeta[L_FT_HJ,C_MC] + nSValMargem )/ (aMeta[L_FT_HJ_SIM	,C_VALOR]))*100 //((_META1->VALMARGEM+nSValMargem)/(_META1->CUSTO+nSCusto))*100	// margem realizada no dia simulado
			aMeta[L_FT_HJ_SIM,C_MC]		:= aMeta[L_FT_HJ_SIM,C_VALOR] * aMeta[L_FT_HJ_SIM,C_IMC] / 100
			aMeta[L_FT_HJ_SIM,C_VALOR] 	-= 	 M->C5_DESPESA



		Else				// Campanha de Vendas

			nSValFat:=0
			for nI := 1 to Len(aCols)
				If !gdDeleted(nI) .and. !Empty(gdFieldGet('UB_PRODUTO',nI)) .and. IMDF220Camp(gdFieldGet('UB_PRODUTO',nI),mv_par02)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Valor a ser faturado                            		     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nTmp := IIF(M->C5_MOEDA == SUO->UO_MOEDA , gdFieldGet('C6_PRCACRE',nI) , xMoeda(gdFieldGet('C6_VRCACRE',nI),M->C5_MOEDA,SUO->UO_MOEDA,dDataBase,nDecVLRITEM) )
					nSValFat += IIF(SUO->UO_TPMETA=="2" , gdFieldGet('C6_QTDVEN',nI) , Round(nTmp*gdFieldGet('C6_QTDVEN',nI),nDecVLRITEM) )
				Endif
			next
			// atualiza valores simulados
			aMeta[L_FT_HJ_SIM,C_VALOR] := aMeta[L_FT_HJ	,C_VALOR]+nSValFat											// total faturado no dia simulado

		Endif

	Endif

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³META FATURAMENTO MES   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// percentual da meta mensal de faturamento atingido
nRVPercMes := ((aMeta[L_FT_MES 	,C_VALOR]+aMeta[L_FT_HJ	,C_VALOR])/aMeta[L_META_MES,C_VALOR])*100
// percentual da meta mensal de faturamento simulado
nSVPercMes := ((aMeta[L_FT_MES 	,C_VALOR]+aMeta[L_FT_HJ_SIM	,C_VALOR])/aMeta[L_META_MES,C_VALOR])*100

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³META FATURAMENTO MES   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If mv_par01 == 1	// Metas de vendas comuns
	// percentual da meta mensal de margem atingido
	nRMPercMes := ((aMeta[L_FT_MES,C_MC] + aMeta[L_FT_HJ    ,C_MC]) / (aMeta[L_FT_MES,C_VALOR]+ aMeta[L_FT_HJ 	,C_VALOR])*100)*100 / aMeta[L_META_MES,C_IMC] //((_META2->VALMARGEM+_META1->VALMARGEM) / aMetaValMar[3]) * 100
	// percentual da meta mensal de margem simulado
	nSMPercMes := ((aMeta[L_FT_MES,C_MC] + aMeta[L_FT_HJ_SIM,C_MC]) / (aMeta[L_FT_MES,C_VALOR]+ aMeta[L_FT_HJ_SIM	,C_VALOR])*100)*100 / aMeta[L_META_MES,C_IMC]//(( (aDados[X_HOJE][X_VALMARGEM]/aDados[X_HOJE][X_VALOR])*100 )/aMeta[L_META_MES,C_IMC])*100 //( (_META2->VALMARGEM+_META1->VALMARGEM+nSValMargem) / aMetaValMar[3] ) * 100
	If ROUND(nRVPercMes,2) >= 100 .and. ROUND(nRMPercMes,2) >= 100
		lMetaMensal := .T.
	Endif
Else				// Campanhas de Vendas
	If ROUND(nRVPercMes,2) >= 100
		lMetaMensal := .T.
	Endif
Endif



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³META FATURAMENTO DIARIA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// percentual da meta diaria de faturamento atingido
nRVPercDia := (aMeta[L_FT_HJ,C_VALOR]/aMeta[L_MED_PARAMETA,C_VALOR])*100
// percentual da meta diaria de faturamento simulado
nSVPercDia := (aMeta[L_FT_HJ_SIM,C_VALOR]/aMeta[L_MED_PARAMETA,C_VALOR])*100

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³META MARGEM      DIARIA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If mv_par01 == 1	// Metas de vendas comuns
	// percentual da meta diaria de margem atingido
	nRMPercDia := ( aMeta[L_FT_HJ    ,C_MC] / aMeta[L_FT_HJ	,C_VALOR]*100)*100 / aMeta[L_META_MES,C_IMC] //(_META1->VALMARGEM / nDifLucro) * 100
	// percentual da meta diaria de margem simulado
	nSMPercDia := ( aMeta[L_FT_HJ_SIM,C_MC] / aMeta[L_FT_HJ_SIM,C_VALOR]*100)*100 / aMeta[L_META_MES,C_IMC]

	If ROUND(nRVPercDia,2) >= 100 .and. ROUND(nRMPercDia,2) >= 100
		lMetaDiaria := .T.
	Endif
Else				// Campanhas de Vendas
	If ROUND(nRVPercDia,2) >= 100
		lMetaDiaria := .T.
	Endif
Endif

// atualiza array com resumo das metas
If mv_par01 == 1	// Metas de vendas comuns
	// metas mensais
	aResumo[1,1] := str(nRVPercMes,6,2)+"% atingida."
	aResumo[1,2] := str(nSVPercMes,6,2)+"% atingida."
	aResumo[2,1] := str(nRMPercMes,6,2)+"% atingida."
	aResumo[2,2] := str(nSMPercMes,6,2)+"% atingida."

	// metas diarias
	aResumo[3,1] := str(nRVPercDia,6,2)+"% atingida."
	aResumo[3,2] := str(nSVPercDia,6,2)+"% atingida."
	aResumo[4,1] := str(nRMPercDia,6,2)+"% atingida."
	aResumo[4,2] := str(nSMPercDia,6,2)+"% atingida."
Else				// Campanhas de Vendas
	// metas mensais
	aResumo[1,1] := str(nRVPercMes,6,2)+"% atingida."
	aResumo[1,2] := str(nSVPercMes,6,2)+"% atingida."

	// metas diarias
	aResumo[2,1] := str(nRVPercDia,6,2)+"% atingida."
	aResumo[2,2] := str(nSVPercDia,6,2)+"% atingida."
Endif

dbSelectArea('_META1')
dbCloseArea()
dbSelectArea('_META2')
dbCloseArea()
RestArea(aAreaSA1)
IncProc()

Return NIL


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Original  ³ MyQuery         ³ Autor ³Raul                ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Fun‡„o	 ³ MyQuery         ³ Autor ³Expedito Mendonca Jr³ Data ³ 10/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Transforma cQuery em cursor com os dados - comunica com o Top  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso   	 ³ ESPECIFICO PARA O CLIENTE IMDEPA							   	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MyQuery( cQuery , cursor )
cQuery := ChangeQuery(cQuery)

/** Mostrar a consulta  **/
//@ 116,090 To 416,707 Dialog oDlgMemo Title cursor
//@ 055,005 Get cQuery   Size 250,080  MEMO Object oMemo
//Activate Dialog oDlgMemo
IF SELECT( cursor ) <> 0
   dbSelectArea(cursor)
   Use
Endif

TCQUERY cQuery NEW ALIAS (cursor)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ MetaMes         ³ Autor ³Expedito Mendonca Jr³ Data ³ 12/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna a meta do mes de determinado vendedor.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso   	 ³ ESPECIFICO PARA O CLIENTE IMDEPA							   	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MetaMes(cCodVen,nVend)
Local aMetValMar
Local cData1 := DTOS(FirstDay(ddatabase))
Local cData2 := DTOS(LastDay(ddatabase))
Local cQuery

If nVend == 1 .or. nVend == 2		// Vendedor interno ou externo

	cQuery := "SELECT SUM(CT_VALOR) MFAT, AVG(CT_MARGEM) MMARGEM "
//	cQuery := "select SUM(CT_VALOR) MFAT, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) MVALMARGEM, SUM(CT_VALOR/(1+(CT_MARGEM/100))) MCUSTO "
	cQuery += " from "+RetSqlName('sct')+" sct"
	cQuery += " where sct.D_E_L_E_T_  = ' ' "
	cQuery += " AND CT_FILIAL  = '"+xFilial("SCT")+"'"
	cQuery += " AND CT_VEND    = '"+cCodVen+"'"
	cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
	cQuery += " AND CT_MARCA   = '"+space(len(SCT->CT_MARCA))+"'" //	cQuery += " AND CT_MARCA  <> '"+space(len(SCT->CT_MARCA))+"'"
	cQuery += " AND CT_CLIENTE = '"+space(len(SCT->CT_CLIENTE))+"'"  // NOVO
	cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
	cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
	cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
	cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
	cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
	cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
	cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
	cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
	cQuery += " AND CT_MARCA3  = '"+space(len(SCT->CT_MARCA3))+"'"

Elseif nVend == 3		// Vendedor coordenador

	// Definicao: meta dos coordenador + meta dos seus vendedores externos subordinados
	cQuery := "SELECT SUM(CT_VALOR) MFAT, AVG(CT_MARGEM) MMARGEM "	//NOVO
//	cQuery := "select SUM(SUPER.VALOR) MFAT, SUM(SUPER.MARGEM) MMARGEM, SUM(SUPER.CUSTO) MCUSTO from "
	// vendedores coordenadores
//	cQuery += "( select SUM(CT_VALOR) VALOR, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) MARGEM, SUM(CT_VALOR/(1+(CT_MARGEM/100))) CUSTO "
	cQuery += " from "+RetSqlName('sct')+" sct "
	cQuery += " WHERE sct.D_E_L_E_T_  = ' ' "
	cQuery += " AND sct.CT_FILIAL  = '"+xFilial("SCT")+"' "
	cQuery += " AND CT_VEND   = '"+cCodVen+"'"
	cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
	cQuery += " AND CT_MARCA   = '"+space(len(SCT->CT_MARCA))+"'"
//	cQuery += " AND CT_MARCA  <> '"+space(len(SCT->CT_MARCA))+"'"
	cQuery += " AND CT_CLIENTE = '"+space(len(SCT->CT_CLIENTE))+"'"  // NOVO
	cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
	cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
	cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
	cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
	cQuery += " AND CT_GRPSEGT = '"+space(len(SCT->CT_GRPSEGT))+"'"       // NOVO
	cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
	cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
	cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
	cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
	cQuery += " AND CT_MARCA3  = '"+space(len(SCT->CT_MARCA3))+"'"
/*	// uniao com vendedores externos
	cQuery += " UNION ALL select SUM(CT_VALOR) VALOR, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) MARGEM, SUM(CT_VALOR/(1+(CT_MARGEM/100))) CUSTO "
	cQuery += " from "+RetSqlName('sct')+" sct,"+ RetSqlName('sa3')+" sa3 "
	cQuery += " where CT_FILIAL = '"+xFilial("SCT")+"' "
	cQuery += " AND A3_FILIAL  = '  '"
	cQuery += " AND sct.D_E_L_E_T_  = ' ' "
	cQuery += " AND sa3.D_E_L_E_T_  = ' ' "
	cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
	cQuery += " AND CT_VEND = A3_COD "
	cQuery += " AND SA3.A3_TIPO = 'E'"
	cQuery += " AND SA3.A3_SUPER = '"+cCodVen+"'"
	cQuery += " AND A3_GRPREP IN (" + GETMV("MV_EISVE") + ") "
	cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
	cQuery += " AND CT_MARCA   = '"+space(len(SCT->CT_MARCA))+"'" //	cQuery += " AND CT_MARCA  <> '"+space(len(SCT->CT_MARCA))+"'"
	cQuery += " AND CT_CLIENTE = '"+space(len(SCT->CT_CLIENTE))+"'"  // NOVO
	cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
	cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
	cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
	cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
	cQuery += " AND CT_GRPSEGT = '"+space(len(SCT->CT_GRPSEGT))+"'"       // NOVO
	cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
	cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
	cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
	cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
	cQuery += " ) SUPER "
*/
Elseif nVend == 4		// Chefe de vendas

	// Definicao: meta do chefe + meta dos seus vendedores internos subordinados
	cQuery := "SELECT SUM(CT_VALOR) MFAT, AVG(CT_MARGEM) MMARGEM "	//NOVO
//	cQuery := "select SUM(SUPER.VALOR) MFAT, SUM(SUPER.MARGEM) MMARGEM, SUM(SUPER.CUSTO) MCUSTO from "
	// chefe de vendas
//	cQuery += "( select SUM(CT_VALOR) VALOR, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) MARGEM, SUM(CT_VALOR/(1+(CT_MARGEM/100))) CUSTO "
	cQuery += " from "+RetSqlName('sct')+" sct "
	cQuery += " WHERE sct.D_E_L_E_T_  = ' ' "
	cQuery += " AND sct.CT_FILIAL  = '"+xFilial("SCT")+"' "
	cQuery += " AND CT_VEND   = '"+cCodVen+"'"
	cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
  //	cQuery += " AND CT_MARCA   = '"+space(len(SCT->CT_MARCA))+"'"
	cQuery += " AND CT_MARCA  <> '"+space(len(SCT->CT_MARCA))+"'"
	cQuery += " AND CT_CLIENTE = '"+space(len(SCT->CT_CLIENTE))+"'"  // NOVO
	cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
	cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
	cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
	cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
	cQuery += " AND CT_GRPSEGT = '"+space(len(SCT->CT_GRPSEGT))+"'"       // NOVO
	cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
	cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
	cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
	cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
	cQuery += " AND CT_MARCA3  = '"+space(len(SCT->CT_MARCA3))+"'"
/*	// uniao com vendedores internos
	cQuery += " UNION ALL select SUM(CT_VALOR) VALOR, SUM(CT_VALOR-(CT_VALOR/(1+(CT_MARGEM/100)))) MARGEM, SUM(CT_VALOR/(1+(CT_MARGEM/100))) CUSTO "
	cQuery += " from "+RetSqlName('sct')+" sct,"+ RetSqlName('sa3')+" sa3 "
	cQuery += " where CT_FILIAL = '"+xFilial("SCT")+"' "
	cQuery += " AND A3_FILIAL = '  '"
	cQuery += " AND sct.D_E_L_E_T_  = ' ' "
	cQuery += " AND sa3.D_E_L_E_T_   =	 ' ' "
	cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
	cQuery += " AND CT_VEND = A3_COD "
	cQuery += " AND SA3.A3_TIPO = 'I'"
	cQuery += " AND SA3.A3_SUPER = '"+cCodVen+"'"
	cQuery += " AND A3_GRPREP IN (" + GETMV("MV_EISVI") + ") "
	cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
	cQuery += " AND CT_MARCA   = '"+space(len(SCT->CT_MARCA))+"'" //	cQuery += " AND CT_MARCA  <> '"+space(len(SCT->CT_MARCA))+"'"
	cQuery += " AND CT_CLIENTE = '"+space(len(SCT->CT_CLIENTE))+"'"  // NOVO
	cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
	cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
	cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
	cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
	cQuery += " AND CT_GRPSEGT = '"+space(len(SCT->CT_GRPSEGT))+"'"       // NOVO
	cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
	cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
	cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
	cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
	cQuery += " ) SUPER  "
	*/
Elseif nVend == 5		// Gerente de Vendas

	// meta de venda efetiva do chefe de vendas
	cQuery := "SELECT SUM(CT_VALOR) MFAT, AVG(CT_MARGEM) MMARGEM "	//NOVO
	cQuery += " from "+RetSqlName('sct')+" sct,"+ RetSqlName('sa3')+" sa3 "
	cQuery += " where CT_FILIAL = '"+xFilial("SCT")+"' "
	cQuery += " AND A3_FILIAL = '  '"
	cQuery += " AND sct.D_E_L_E_T_  = ' ' "
	cQuery += " AND sa3.D_E_L_E_T_  = ' ' "
	cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
	cQuery += " AND CT_VEND = A3_COD "

	//| GLPI : [2418]  || Titulo: [Adaptar CRM] || Analista: [cristianosm] || Data: [07/01/2016]
	//| cQuery += "	 AND SA3.A3_GRPREP IN (" + GETMV("MV_EISGEVE") + ") "
	cQuery += "	 AND SA3.A3_NVLVEN = '5' AND A3_MSBLQL IN('2',' ') " // GERENTES SO DESBLOQUEADOS

	cQuery += " AND SA3.A3_COD  =  '"+cCodVen+"'" 	//	cQuery += " AND SA3.A3_GEREN  =  '"+cCodVen+"'"
	cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
	cQuery += " AND CT_MARCA   = '"+space(len(SCT->CT_MARCA))+"'" //	cQuery += " AND CT_MARCA  <> '"+space(len(SCT->CT_MARCA))+"'"
	cQuery += " AND CT_CLIENTE = '"+space(len(SCT->CT_CLIENTE))+"'"  // NOVO
	cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
	cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
	cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
	cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
	cQuery += " AND CT_GRPSEGT = '"+space(len(SCT->CT_GRPSEGT))+"'"       // NOVO
	cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
	cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
	cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
	cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
	cQuery += " AND CT_MARCA3  = '"+space(len(SCT->CT_MARCA3))+"'"

Elseif nVend == 6		// Diretoria de Vendas

	// meta de venda efetiva dos gerentes
//	cQuery := "SELECT SUM(CT_VALOR) MFAT, AVG(CT_MARGEM) MMARGEM "	//NOVO
	cQuery := " select SUM(CT_VALOR) MFAT, AVG(CT_MARGEM)MMARGEM "
	cQuery += " from "+RetSqlName('sct')+" sct,"+ RetSqlName('sa3')+" sa3 "
	cQuery += " where " //	cQuery += " where CT_FILIAL = '"+xFilial("SCT")+"' AND "
	cQuery += "     A3_FILIAL = '  '"
	cQuery += " AND sct.D_E_L_E_T_  = ' ' "
	cQuery += " AND sa3.D_E_L_E_T_  = ' ' "
	cQuery += " AND sct.CT_DATA between '"+cData1+ "' AND '"+cData2+"'"
	cQuery += " AND CT_VEND = A3_COD "


	//| GLPI : [2418]  || Titulo: [Adaptar CRM] || Analista: [cristianosm] || Data: [07/01/2016]
	//| cQuery += "	 AND SA3.A3_GRPREP IN (" + GETMV("MV_EISGEVE") + ") "
	cQuery += "	 AND SA3.A3_NVLVEN = '5' AND A3_MSBLQL IN('2',' ') " // GERENTES SO DESBLOQUEADOS

	cQuery += " AND SA3.A3_DIRETOR  =  '"+cDiretor+"'"
	cQuery += " AND CT_VEND   <> '"+space(len(SCT->CT_VEND))+"'"
	cQuery += " AND CT_MARCA   = '"+space(len(SCT->CT_MARCA))+"'" //	cQuery += " AND CT_MARCA  <> '"+space(len(SCT->CT_MARCA))+"'"
	cQuery += " AND CT_CLIENTE = '"+space(len(SCT->CT_CLIENTE))+"'"  // NOVO
	cQuery += " AND CT_REGIAO  = '"+space(len(SCT->CT_REGIAO))+"'"
	cQuery += " AND CT_CCUSTO  = '"+space(len(SCT->CT_CCUSTO))+"'"
	cQuery += " AND CT_CIDADE  = '"+space(len(SCT->CT_CIDADE))+"'"
	cQuery += " AND CT_SEGMEN  = '"+space(len(SCT->CT_SEGMEN))+"'"
	cQuery += " AND CT_GRPSEGT = '"+space(len(SCT->CT_GRPSEGT))+"'"       // NOVO
	cQuery += " AND CT_TIPO    = '"+space(len(SCT->CT_TIPO))+"'"
	cQuery += " AND CT_GRUPO   = '"+space(len(SCT->CT_GRUPO))+"'"
	cQuery += " AND CT_PRODUTO = '"+space(len(SCT->CT_PRODUTO))+"'"
	cQuery += " AND CT_CLVL    = '"+space(len(SCT->CT_CLVL))+"'"
	cQuery += " AND CT_MARCA3  = '"+space(len(SCT->CT_MARCA3))+"'"

Endif

// Executa a query e atualiza o retorno da funcao
MEMOWRIT( 'C:\SQLSIGA\IMDF220-_META3.TXT', cQuery )

MyQuery( cQuery , '_META3' )
TCSetField( '_META3', 'MFAT'      , 'N',14 , 2 )
TCSetField( '_META3', 'MMARGEM', 'N',14 , 2 )
TCSetField( '_META3', 'MCUSTO'    , 'N',14 , 2 )

aMetValMar := {_META3->MFAT,_META3->MMARGEM,_META3->MMARGEM,_META3->MMARGEM}
_META3->(dbCloseArea())
Return aMetValMar


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ MetaCamp        ³ Autor ³Expedito Mendonca Jr³ Data ³ 05/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna a meta do vendedor na campanha de vendas.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso   	 ³ ESPECIFICO PARA O CLIENTE IMDEPA							   	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MetaCamp(cCodVen,cCodCamp,cFiliais)
Local nMeta
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Somatorio das metas dos vendedores por produto                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT SUM(ZZG.ZZG_META) META "
cQuery += " FROM "+RetSqlName("ZZG")+" ZZG "
cQuery += " WHERE ZZG.ZZG_FILIAL IN ( " + cFiliais + " )"
cQuery += " AND ZZG.ZZG_CODCAM = '"+cCodCamp+"'"
cQuery += " AND ZZG.ZZG_VEND = '"+cCodVen+"'"
cQuery += " AND ZZG.D_E_L_E_T_ = ' '"
MEMOWRIT( FunName(1)+".SQL", cQuery )
TCQUERY cQuery NEW ALIAS "TRB"
// Verifica se a query foi executada com sucesso
If Alias() != "TRB"
	IW_MsgBox("Erro ao definir metas do vendedor.","Atenção","ALERT")
	Return NIL
Endif
aStru := DbStruct()
For nI := 1 To Len( aStru )
   If aStru[nI,2] != "C"
	   TCSetField( "TRB", aStru[nI,1], aStru[nI,2], aStru[nI,3], aStru[nI,4] )
   EndIf
Next
nMeta := TRB->META
dbCloseArea()
Return nMeta


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ QryMetaComun    ³ Autor ³Expedito Mendonca Jr³ Data ³ 05/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Query para calcular os valores faturados em relacao as metas   ³±±
±±³          ³ de vendas comuns.                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso   	 ³ ESPECIFICO PARA O CLIENTE IMDEPA							   	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function QryMetaComum(nVend,lFatHoje,cAlias,cFiliais)
Local dDataIni, dDataFim

// Define o periodo para o calculo do total faturado no mes ate ontem
If !lFatHoje
	dDataIni :=  Dtos( FirstDay(ddatabase))
	dDataFim := Dtos( ddatabase -1 )
Endif

// Query para selecao de registros


	cQuery :=  " "
	cQuery += "   SELECT SUM (d2_total) valor, SUM ((d2_total * d2_imc) / 100) valmargem, "
	cQuery += "   SUM (d2_cusmc) custo  "
	cQuery += "   FROM sf2010 sf2 INNER JOIN sd2010 sd2 ON f2_filial = d2_filial "
	cQuery += "                                       AND f2_doc = d2_doc "
	cQuery += "                                       AND f2_serie = d2_serie "
	cQuery += "                                       AND f2_cliente = d2_cliente "
	cQuery += "                                       AND f2_loja = d2_loja INNER JOIN sf4010 sf4 ON d2_filial =    f4_filial "
	cQuery += "                                                                                  AND d2_tes    =    f4_codigo "
	cQuery += "  WHERE sf2.f2_filial IN "
	cQuery += "                        (" + cFiliais + ") "
	If lFatHoje
		cQuery += " AND sf2.f2_emissao = '" + DTOS(ddatabase) + "' "
	Else
		cQuery += " AND sf2.f2_emissao BETWEEN '"+dDataIni+"' AND '"+dDataFim+ "' "
	Endif
	If nVend < 6
		cQuery += " AND sf2.F2_VEND"+str(nVend,1)+" = '"+cCodVen+"' "
	ENDIF

    cQuery += "    AND sf2.F2_CLIENTE NOT IN ('N00000','014824') "
    cQuery += "    AND sf2.f2_tipo 	  NOT IN ('B', 'D') "
	cQuery += "    AND sf2.d_e_l_e_t_ = ' ' "
	cQuery += "    AND sd2.d2_origlan <> 'LF' "
	cQuery += "    AND sd2.d_e_l_e_t_ = ' ' "
	cQuery += "    AND sf4.f4_duplic  = 'S' "
	cQuery += "    AND sf4.d_e_l_e_t_ = ' ' "

	MEMOWRIT("C:\SQLSIGA\IMDF220-METACOMUM2-"+cAlias+".txt", cQuery)


	// UNIAO COM AS DEVOLUCOES
//	cQuery += " UNION ALL "
	MyQuery( cQuery , cAlias  )
	TCSetField( cAlias , 'VALOR'    , 'N',14 , 2 )
	TCSetField( cAlias , 'VALMARGEM', 'N',14 , 2 )
	TCSetField( cAlias , 'CUSTO'    , 'N',14 , 2 )

	If lFatHoje
		aDados[X_HOJE][X_VALOR]		+= &(cAlias + '->VALOR')
		aDados[X_HOJE][X_VALMARGEM]	+= &(cAlias + '->VALMARGEM')
		aDados[X_HOJE][X_CUSTO]		+= &(cAlias + '->CUSTO')
	Else
		aDados[X_MES][X_VALOR]		+= &(cAlias + '->VALOR')
		aDados[X_MES][X_VALMARGEM]	+= &(cAlias + '->VALMARGEM')
		aDados[X_MES][X_CUSTO]		+= &(cAlias + '->CUSTO')
	Endif

	IncProc()

	//ÚÄÄÄÄÄÄÄÄÄÄ¿
	//³DEVOLUCOES³
	//ÀÄÄÄÄÄÄÄÄÄÄÙ

	cQuery := " "
	cQuery += " select sum(D1_TOTAL) VALOR, SUM( (((D1_QUANT * D2_PRCVEN) * D2_IMC) / 100) ) VALMARGEM, sum((D2_CUSMC/D2_QUANT)*D1_QUANT) CUSTO " //	cQuery += " select sum(D1_TOTAL)*-1 VALOR, sum((D2_LUCRO1/D2_QUANT)*D1_QUANT*-1) VALMARGEM, sum((D2_CUSIMD1/D2_QUANT)*D1_QUANT*-1) CUSTO "
	cQuery += " from "+RetSqlName("SD1")+" sd1, "+RetSqlName('SD2')+" sd2, "+RetSqlName('SF2')+" sf2, "+RetSqlName("SF4")+" sf4"
	cQuery += " where sd1.D1_FILIAL IN ( " + cFiliais + " )"
	If lFatHoje
		cQuery += " AND sd1.D1_DTDIGIT = '" + DTOS(ddatabase) + "'"
	Else
		cQuery += " AND sd1.D1_DTDIGIT between '"+dDataIni+"' AND '"+dDataFim+ "' "
	Endif
	// relacionamento com SD2
	cQuery += " AND   D2_FILIAL = D1_FILIAL "
	cQuery += " AND   D2_DOC = D1_NFORI "
	cQuery += " AND   D2_SERIE = D1_SERIORI "
	cQuery += " AND   D2_CLIENTE = D1_FORNECE "
	cQuery += " AND   D2_LOJA = D1_LOJA "
	cQuery += " AND   D2_COD = D1_COD "
	// alterado por Luciano Correa em 29/08/05...
	//cQuery += " AND   D2_ITEM = D1_ITEM "
	cQuery += " AND   D2_ITEM = D1_ITEMORI "
	// relacionamento com SF2
	cQuery += " AND   F2_FILIAL = D1_FILIAL "
	cQuery += " AND   F2_DOC = D1_NFORI "
	cQuery += " AND   F2_SERIE = D1_SERIORI "
	cQuery += " AND   F2_CLIENTE = D1_FORNECE "
	cQuery += " AND   F2_LOJA = D1_LOJA "
	cQuery += " AND   F2_CLIENTE NOT IN ('N00000','014824') "
	// relacionamento com SF4
	cQuery += " AND F4_FILIAL = D1_FILIAL"
	cQuery += " AND F4_CODIGO = D1_TES "
	// filtros especificos
	cQuery += " AND sd1.D1_TIPO = 'D'"
	cQuery += " AND sd1.D1_ORIGLAN <> 'LF'"
If nVend < 6
	cQuery += " AND sf2.F2_VEND"+str(nVend,1)+" = '"+cCodVen+"' "
ENDIF
	cQuery += " AND sf4.F4_DUPLIC = 'S'"
	// deletados
	cQuery += " AND   sd1.D_E_L_E_T_ = ' '"
	cQuery += " AND   sd2.D_E_L_E_T_ = ' '"
	cQuery += " AND   sf2.D_E_L_E_T_ = ' '"
	cQuery += " AND   sf4.D_E_L_E_T_ = ' '"
//	cQuery += " ) VENDAS"

	MyQuery( cQuery , cAlias  )
	TCSetField( cAlias , 'VALOR'    , 'N',14 , 2 )
	TCSetField( cAlias , 'VALMARGEM', 'N',14 , 2 )
	TCSetField( cAlias , 'CUSTO'    , 'N',14 , 2 )

	If lFatHoje
		aDados[X_HOJE][X_VALOR]		-= &(cAlias + '->VALOR')
		aDados[X_HOJE][X_VALMARGEM]	-= &(cAlias + '->VALMARGEM')
		aDados[X_HOJE][X_CUSTO]		-= &(cAlias + '->CUSTO')
	Else
		aDados[X_MES][X_VALOR]		-= &(cAlias + '->VALOR')
		aDados[X_MES][X_VALMARGEM]	-= &(cAlias + '->VALMARGEM')
		aDados[X_MES][X_CUSTO]		-= &(cAlias + '->CUSTO')
	Endif

MEMOWRIT("C:\SQLSIGA\IMDF220-METACOMUM-"+cAlias+".txt", cQuery)

// Executa a query
MyQuery( cQuery , cAlias  )
TCSetField( cAlias , 'VALOR'    , 'N',14 , 2 )
TCSetField( cAlias , 'VALMARGEM', 'N',14 , 2 )
TCSetField( cAlias , 'CUSTO'    , 'N',14 , 2 )

Return NIL



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ QryMetaCamp     ³ Autor ³Expedito Mendonca Jr³ Data ³ 05/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Query para calcular os valores faturados em relacao as metas   ³±±
±±³          ³ de vendas campanhas de vendas.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso   	 ³ ESPECIFICO PARA O CLIENTE IMDEPA							   	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function QryMetaCamp(nVend,lFatHoje,cAlias,cFiliais)
Local dDataIni, dDataFim, cConvMoeda

// String para converter para outra moeda
cConvMoeda := IIF(SUO->UO_MOEDA==1,"","/SM2.M2_MOEDA"+Str(SUO->UO_MOEDA,1))

// Define o periodo para o calculo do total faturado desde o inicio da campanha ate ontem
If !lFatHoje
	dDataIni := Dtos(SUO->UO_DTINI)
	dDataFim := Dtos( ddatabase -1 )
Endif

// NFs emitidas subtraindo as devolucoes
cQuery := "select " + IIF( SUO->UO_TPMETA == "2" , "SUM(VENDAS.QUANT) QUANT " , "SUM(VENDAS.VALOR) VALOR " ) + " from "

cQuery += " ( select " + IIF( SUO->UO_TPMETA == "2" , "SUM(D2_QUANT) QUANT ", "SUM(SD2.D2_TOTAL" + cConvMoeda + ") VALOR " )
cQuery += " from "+RetSqlName("SD2")+" sd2, "+RetSqlName("SF2")+" sf2, "+RetSqlName("SF4")+" sf4, "+RetSqlName("ZZI")+" zzi, "+ RetSqlName("SM2")+" SM2 "
cQuery += " where sd2.D2_FILIAL IN ( " + cFiliais + " )"
If lFatHoje
	cQuery += " AND D2_EMISSAO = '" + DTOS(ddatabase) + "'"
Else
	cQuery += " AND D2_EMISSAO between '"+dDataIni+"' AND '"+dDataFim+ "' "
Endif
// relacionamento com SF2
cQuery += " AND F2_FILIAL = D2_FILIAL"
cQuery += " AND F2_DOC  = D2_DOC "
cQuery += " AND F2_SERIE = D2_SERIE "
cQuery += " AND F2_CLIENTE = D2_CLIENTE"
cQuery += " AND F2_LOJA = D2_LOJA "
cQuery += " AND F2_CLIENTE NOT IN ('N00000','014824') "
// relacionamento com SF4
cQuery += " AND F4_FILIAL = D2_FILIAL "
cQuery += " AND F4_CODIGO = D2_TES "
// relacionamento com ZZI
cQuery += " AND ZZI_FILIAL = D2_FILIAL"
cQuery += " AND ZZI_NUM = D2_PEDIDO"
cQuery += " AND ZZI_PRODUT = D2_COD"
cQuery += " AND ZZI_CODCAM = '"+mv_par02+"'"
// relacionamento com SM2
cQuery += " AND SM2.M2_DATA = SD2.D2_EMISSAO"
// filtros
cQuery += " AND D2_TIPO NOT IN ( 'B', 'D' )"
cQuery += " AND D2_ORIGLAN <> 'LF'"
cQuery += " AND F2_VEND"+str(nVend,1)+" = '"+cCodVen+"' "
cQuery += " AND F4_DUPLIC = 'S'"
// deletados
cQuery += " AND   sd2.D_E_L_E_T_ = ' '"
cQuery += " AND   sf2.D_E_L_E_T_ = ' '"
cQuery += " AND   sf4.D_E_L_E_T_ = ' '"
cQuery += " AND   zzi.D_E_L_E_T_ = ' '"
cQuery += " AND   SM2.D_E_L_E_T_  = ' '"

// UNIAO COM AS DEVOLUCOES NO DIA
cQuery += " UNION ALL select " + IIF( SUO->UO_TPMETA == "2" , "SUM(D1_QUANT*-1) QUANT " , "SUM((SD1.D1_TOTAL"+cConvMoeda+") * -1) VALOR " )
cQuery += " from "+RetSqlName("SD1")+" sd1, "+RetSqlName('SD2')+" sd2, "+RetSqlName('SF2')+" sf2, "+RetSqlName("SF4")+" sf4, "+RetSqlName("ZZI")+" zzi, "  + RetSqlName("SM2")+" SM2 "
cQuery += " where sd1.D1_FILIAL IN ( " + cFiliais + " )"
If lFatHoje
	cQuery += " AND sd1.D1_DTDIGIT = '" + DTOS(ddatabase) + "'"
Else
	cQuery += " AND sd1.D1_DTDIGIT between '"+dDataIni+"' AND '"+dDataFim+ "' "
Endif
// relacionamento com SD2
cQuery += " AND   D2_FILIAL = D1_FILIAL"
cQuery += " AND   D2_DOC = D1_NFORI "
cQuery += " AND   D2_SERIE = D1_SERIORI "
cQuery += " AND   D2_CLIENTE = D1_FORNECE "
cQuery += " AND   D2_LOJA = D1_LOJA "
cQuery += " AND   D2_COD = D1_COD "
// alterado por Luciano Correa em 29/08/05...
//cQuery += " AND   D2_ITEM = D1_ITEM "
cQuery += " AND   D2_ITEM = D1_ITEMORI "
// relacionamento com SF2
cQuery += " AND   F2_FILIAL = D1_FILIAL "
cQuery += " AND   F2_DOC = D1_NFORI "
cQuery += " AND   F2_SERIE = D1_SERIORI "
cQuery += " AND   F2_CLIENTE = D1_FORNECE "
cQuery += " AND   F2_LOJA = D1_LOJA "
cQuery += " AND   F2_CLIENTE NOT IN ('N00000','014824') "
// relacionamento com SF4
cQuery += " AND F4_FILIAL = D1_FILIAL "
cQuery += " AND F4_CODIGO = D1_TES "
// relacionamento com ZZI
cQuery += " AND ZZI_FILIAL = D2_FILIAL"
cQuery += " AND ZZI_NUM = D2_PEDIDO"
cQuery += " AND ZZI_PRODUT = D2_COD"
cQuery += " AND ZZI_CODCAM = '"+mv_par02+"'"
// relacionamento com SM2
cQuery += " AND SM2.M2_DATA = SD1.D1_EMISSAO"
// filtros especificos
cQuery += " AND sd1.D1_TIPO = 'D'"
cQuery += " AND sd1.D1_ORIGLAN <> 'LF'"
cQuery += " AND sf2.F2_VEND"+str(nVend,1)+" = '"+cCodVen+"' "
cQuery += " AND sf4.F4_DUPLIC = 'S'"
// deletados
cQuery += " AND   sd1.D_E_L_E_T_ = ' '"
cQuery += " AND   sd2.D_E_L_E_T_ = ' '"
cQuery += " AND   sf2.D_E_L_E_T_ = ' '"
cQuery += " AND   sf4.D_E_L_E_T_ = ' '"
cQuery += " AND   zzi.D_E_L_E_T_ = ' '"
cQuery += " AND   SM2.D_E_L_E_T_  = ' '"
cQuery += " ) VENDAS"

MEMOWRIT("C:\SQLSIGA\IMDF220-METACAMP-"+cAlias+".txt", cQuery)
MyQuery( cQuery , cAlias  )
TCSetField( cAlias , IIF(SUO->UO_TPMETA=='2','QUANT','VALOR') , 'N',14 , 2 )

Return NIL


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ IMDF220Camp     ³ Autor ³Expedito Mendonca Jr³ Data ³ 06/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Indica se o item faz parte da campanha de venda selecionada    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso   	 ³ ESPECIFICO PARA O CLIENTE IMDEPA							   	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function IMDF220Camp(cProduto,cCodCamp)
Local nJ, lRet := .F.
for nJ := 1 to Len(__aProdCamp)
	If __aProdCamp[nJ] != NIL .and. __aProdCamp[nJ,1] == cProduto .and. __aProdCamp[nJ,2] == cCodCamp
		lRet := .T.
		exit
	Endif
next
Return lRet


Static Function diasUteis(  dDataInicial,dataLimite, yfilial )
Local area   := GetArea()
Private ndUtil := 0   // total de dias uteis
//Private nMes   := Month( dataLimite )
//Private nAno   := Year( dataLimite  )
Private dDtIni
Private regional // Feriado regional

If dDataInicial == NIL
	dDtIni := FirstDay(dataLimite)
Else
	dDtIni := dDataInicial
Endif


While   dDtIni <= datalimite
	If DataValida(dDtIni) == dDtIni
		// Consulta tabela de feriados regionais
		dbSelectArea('SX5')
		dbSetOrder(1)
		dbSeek(XFilial('SX5')+'I8'+ yfilial )
		regional := .F.
		Do While !Eof() .AND. SX5->X5_TABELA == 'I8' .AND.  Left( SX5->X5_CHAVE,2 )== yfilial
			If Left(SX5->X5_DESCRI,5) == Left( DTOC( dDtIni ),5 )  // verificar dia e mes
				regional := .T.
				Exit
			Endif
			dbSkip()
		Enddo
		If !regional
			ndUtil++  //somatorio de dias úteis considerando os feriados regionais
		Endif
	Endif
	dDtIni++
EndDo
RestArea( area )
Return nDUtil

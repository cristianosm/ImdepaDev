//#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 25/01/02
#include "protheus.ch"        // incluido pelo assistente de conversao do AP5 IDE em 25/01/02
#include "topconn.ch"
#Command @ <nRow>,<nCol> TO <nToRow>,<nToCol> MULTILINE [<lModi: MODIFY>] [<lDel: DELETE>] [VALID <bLineOk>] [FREEZE <nFreeze>] [OBJECT <oMtl>] ;
	=> [ <oMtl> := ] IW_MultiLine(<nRow>,<nCol>,<nToRow>,<nToCol>,<.lModi.>,<.lDel.>,[\{||<bLineOk>\}],<nFreeze>)
//Static cXBTransp := NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³U_MSTROT2 ³ Autor ³ Jaime de Souza        ³ Data ³ 05/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibir as transportadoras e rotas que podem atender ao     ³±±
±±³          ³ pedido de venda que esta sendo incluido na Tela da Verdade ³±±
±±³          ³ (Esta funcao eh acionada num botao na Tecla F3, quando o   ³±±
±±³          ³ usuario esta selecionando a transportadora).               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico para o cliente Imdepa                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Expedito    ³26/08/04³ Nova regra para calculo do valor do frete       ³±±
±±³ Márcio	   ³02/01/06³ Adicionado acrescimo conf MV_PERACFT no frete    ³±±
±±³                       destacado                                       ³±±
±±³ Global     ³05/07/06  Inabilitado Função XBTRANSP() que era usado no  ³±±
±±³                       botão do rotas na Consulta Padrão da            ³±±
±±³                       Transportadora                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User function Mstrot2()

	Local aColsTmp := aClone(aCols), aHeaderTmp := aClone(aHeader)
	Local nAnt := n, lOk
	Local nPesoTotal,dDisp
	Local oDlg, oBut1, oBut2
	Local oNorExp,nNorExp := IIF(M->UA_FRETEXP=="1",2,1)
	Private aColsFil := aClone(Acols) // Apresenta Menor Valor e Menor Tempo apenas...

	Private nDestaca := IIF(aValores[4]>0,1,2),oDestaca,oReemb,nReemb := IIF(M->UA_REEMB=="S",1,2)
	Private __aRotasDisponiveis	:= {}, aColsFil := {}, oItens

// Verifica se a rotina esta sendo chamada da tela da verdade
	If funname() != "TMKA271"
		IW_MsgBox(Oemtoansi("Opção ativa apenas na Tela da Verdade"),'Atenção','ALERT')
	Return .T.
	Endif

//IF aValores[6] = 0
//	IW_MsgBox(Oemtoansi("Entre na condição de pagamento antes para totalizar os valores!"),'Atenção','ALERT')
//	Return
//Endif

	DO WHILE .T.

	// Preenchimento do aHeader
		aHeader := {}
		aAdd(aHeader,{ "Transportadora"		, "ZO_CODTRAN"  ,""                   ,  6, 0,  " "  , " "  , "C", "SA4" } )
		aAdd(aHeader,{ "Nome"           		, "ZO_NOMTRANS" ,""                   , 40, 0,  " "   , " " , "C", ""    } )
		aAdd(aHeader,{ "Rota"            		, "ZO_CODROTA"  ,""                   ,  6, 0,  " "  , " "  , "C", ""    } )
		aAdd(aHeader,{ "Descricao"      		, "ZO_DESCRI"   ,""                   , 40, 0,  " "   , " " , "C", ""    } )
		aAdd(aHeader,{ "Prazo"           	, "ZO_FREQUEN"  ,""                   , 18, 0,  " "   , " " , "C", ""    } )
		aAdd(aHeader,{ "Frequencia"      	, "ZO_FREQUEN"  ,""                   , 23, 0,  " "   , " " , "C", ""    } )
		aAdd(aHeader,{ "Horario Coleta"  	, "ZZL_DESTPC"  ,""                   , 12, 0,  " "   , " " , "C", ""    } )
		aAdd(aHeader,{ "Frete Normal"    	, "ZZL_VALFIX"  ,"@E 999,999,999.99"  , 12, 2,  " "   , " " , "N", ""    } )
		aAdd(aHeader,{ "Frete c/ Reemb." 	, "ZZL_VALFIX"  ,"@E 999,999,999.99"  , 12, 2,  " "   , " " , "N", ""    } )
		aAdd(aHeader,{ "Frete Expresso"  	, "ZZL_VALFIX"  ,"@E 999,999,999.99"  , 12, 2,  " "   , " " , "N", ""    } )
		aAdd(aHeader,{ "Fret.Exp.c/ Reemb."	, "ZZL_VALFIX"  ,"@E 999,999,999.99"  , 12, 2,  " "   , " " , "N", ""    } )
		aAdd(aHeader,{ "Nota"            		, "ZO_NOTA"     ,"@E 99.99"           , 5,  2,  " "   , " " , "N", ""    } )
		aAdd(aHeader,{ "Meio"            		, "ZZL_DESTPC"  ,""                   , 12, 0,  " "   , " " , "C", ""    } )
		aAdd(aHeader,{ "Distancia Km"    	, "ZZM_KM"      ,"@E 999,999.99"      , 9 , 2,  " "   , " " , "N", ""    } )

	// Inicializa aCols


		aCols := {}
		__aRotasDisponiveis	:= {}
		aColsFil := {}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria e executa a Query para selecao dos registros            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MsAguarde({|| lOk := U_MSTROT2QUERY(@nPesoTotal,@dDisp,@aHeaderTmp,@aColsTmp)},OemToAnsi("Aguarde..."),OemToAnsi("Selecionando rotas..."))

		If !lOk
			MsgAlert("Problema na criacao da QUERY !")
		Return .T.
		EndIf


		aCols  := aClone(__aRotasDisponiveis)

		//Analista: Cristiano ... Data: 24/07/2013 ... Desc.: Retorna Frete Menor Valor e Prazo...
		If nDestaca == 2
			aCols := Ver_M_TeV() //
		else
			aColsFil := Ver_M_TeV() //
		EndIf
		//aColsFil :=  aClone(__aRotasDisponiveis)
		//Fim Cristiano

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibe as rotas disponiveis                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lOk := .F.
		If Len(aCols) > 0
		// ordena do menor frete para o maior frete

			aSort(aCols,,,{|x,y| x[8] < y[8] })

		// exibe a tela
			n := 1
			DEFINE MSDIALOG oDlg FROM 040,020 TO 383,810 TITLE OemToAnsi("Rotas Selecionadas") PIXEL
			@ 005,010 SAY OemToAnsi("Peso Total(Kg): ") OF oDlg PIXEL
			@ 005,052 MSGET nPesoTotal Picture "@E 99,999,999.999" OF oDlg PIXEL WHEN .F.

			@ 005,152 SAY OemToAnsi("Disponibilidade: ") OF oDlg PIXEL
			@ 005,197 MSGET dDisp OF oDlg PIXEL WHEN .F.

			@ 020,010 TO 150,390 MultiLine VALID .T. OBJECT oItens

			@ 153,100 RADIO oNorExp VAR nNorExp 3D SIZE 70,10 PROMPT OemToAnsi("Frete Normal"),OemToAnsi("Frete Expresso") OF oDlg PIXEL

			@ 153,180 RADIO oReemb VAR nReemb 3D SIZE 70,10 PROMPT OemToAnsi("Com Reembolso"),OemToAnsi("Sem Reembolso") OF oDlg PIXEL

			@ 153,260 RADIO oDestaca VAR nDestaca 3D SIZE 70,10  ON CHANGE {|| Change_Acols(nDestaca)} PROMPT OemToAnsi("Destaca"),OemToAnsi("Não Destaca") OF oDlg PIXEL

			Define sButton oBut1 From 155,330 Type 01 Enable Of oDlg Pixel Action ( lOk := .T. , oDlg:End() )
			Define sButton oBut2 From 155,360 Type 02 Enable Of oDlg Pixel Action ( oDlg:End() )

			oDestaca:refresh()
			oItens:refresh()

			ACTIVATE DIALOG oDlg CENTERED

		Else
			IF  M->UA_REEMB = "S"
				Aviso("SEM ITENS","Nenhum item encontrado para frete com REENBOLSO! Altere o campo Reembolso no cabeçario do orçamento para Não !",{"Ok"})
			ELSE
				Alert("Nenhum item encontrado !!!")
			ENDIF
		Endif


	// Atualiza variaveis de acordo com a rota selecionada
		If lOk

		//	cXBTransp 		:= aCols[n,1] //Código da Transportadora

			IF (nDestaca = 1 .AND. M->UA_TPFRETE = "F" ) .AND. ! (nReemb = 1 .AND. M->UA_REEMB <> "S")
				M->UA_TPFRETE := "C"
				Aviso("ATUALIZA ROTAS","AS ROTAS SERAO ATUALIZAS PARA O TIPO DE FRETE CIF, ESCOLHA A ROTA NOVAMENTE!!!",{"Ok"})
				aHeader := aClone(aHeaderTmp)
				aCols   := aClone(aColsTmp)
				LOOP
			ENDIF

			IF (nReemb = 1 .AND. M->UA_REEMB <> "S") .AND. ! (nDestaca = 1 .AND. M->UA_TPFRETE = "F" )
				M->UA_REEMB := "S"
				Aviso("ATUALIZA ROTAS","AS ROTAS SERAO ATUALIZAS PARA O TIPO DE FRETE COM REEMBOLSO , ESCOLHA A ROTA NOVAMENTE!!!",{"Ok"})
				aHeader := aClone(aHeaderTmp)
				aCols   := aClone(aColsTmp)

				LOOP
			ENDIF

			IF (nReemb = 1 .AND. M->UA_REEMB <> "S") .AND. (nDestaca = 1 .AND. M->UA_TPFRETE = "F" )
				M->UA_TPFRETE := "C"
				M->UA_REEMB := "S"
				Aviso("ATUALIZA ROTAS","AS ROTAS SERAO ATUALIZAS PARA O TIPO DE FRETE CIF E COM REEMBOLSO , ESCOLHA A ROTA NOVAMENTE!!!",{"Ok"})
				aHeader := aClone(aHeaderTmp)
				aCols   := aClone(aColsTmp)
				LOOP
			ENDIF

			M->UA_TRANSP  	:= aCols[n,1] //Código da Transportadora       aRetTrans[1]
			M->UA_CODROTA := aCols[n,3]
			M->UA_FRETEXP := IIF(nNorExp==2,"1","2")  // 1=Sim, 2=Nao
			M->UA_MENNOTA := MENSFRETEEXP()
			M->UA_REEMB   := IIF(nReemb==1,"S","N")	  // 1=Sim, 2=Nao

			IF M->UA_TPFRETE == "F"
				M->UA_FRETCAL := 0
				IF POSICIONE("SZO",1,XFILIAL("SZO")+M->UA_CODROTA,"ZO_REDESPA") = "S"
					IF nNorExp == 1	//Normal
						If nReemb == 2  // sem reembolso
							M->UA_FRETFOB := aCols[n,8]
						Else			// com reembolso
							M->UA_FRETFOB := aCols[n,9]
						Endif
					Else			//Expresso
						If nReemb == 2	// sem reembolso
							M->UA_FRETFOB := aCols[n,10]
						Else			// com reembolso
							M->UA_FRETFOB := aCols[n,11]
						Endif
					Endif
				ENDIF
			ELSE
				IF nNorExp == 1	//Normal
					If nReemb == 2  // sem reembolso
						M->UA_FRETCAL := aCols[n,8]
					Else			// com reembolso
						M->UA_FRETCAL := aCols[n,9]
					Endif
				Else			//Expresso
					If nReemb == 2	// sem reembolso
						M->UA_FRETCAL := aCols[n,10]
					Else			// com reembolso
						M->UA_FRETCAL := aCols[n,11]
					Endif
				Endif
			ENDIF
			__lTranspPossuiRota 	:= LEN(__aRotasDisponiveis) > 0   // Transportadora possui rota
			__RodouRotas			:= .T.

			If nDestaca == 1
			// Jorge Oliveira - 18/11/10 - Incluido o arredendamento ( Round() )
				aValores[4] := Round( M->UA_FRETCAL * (1 + GETMV("MV_PERACFT")/100), 2 ) //MARCIO
				aHeader := aClone(aHeaderTmp)
				aCols   := aClone(aColsTmp)
				n := nAnt
				Tk273RodImposto("NF_FRETE",aValores[4])
				oGetTlv:oBrowse:Refresh()
			//	IW_MsgBox(Oemtoansi("Teclar <Enter> no campo condição de pagamento da tela 'Condição de Pagamento',  para recalcular as parcelas."),'Atenção','INFO')
			Else
				aValores[4] := 0
				aHeader := aClone(aHeaderTmp)
				aCols   := aClone(aColsTmp)
				n := nAnt
				Tk273RodImposto("NF_FRETE",aValores[4])
				oGetTlv:oBrowse:Refresh()
			Endif

			EXIT

		ELSE
			aHeader := aClone(aHeaderTmp)
			aCols   := aClone(aColsTmp)
			n := nAnt
			EXIT
		ENDIF

	ENDDO

Return .T.

	/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ ZERAFRE     ³ Autor ³Agostinho Lima      ³ Data ³ 30/06/10 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡ao ³ Zera frete destacado quado for FOB                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Sintaxe   ³ ZERAFRE()                                                  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ Nenhum                                                     ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ NIL                                                        ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ MSTROT2                                                    ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	/*/
User Function ZERAFRE()

	IF M->UA_TPFRETE = "F"

		aValores[4] := 0
		Tk273RodImposto("NF_FRETE",aValores[4])
		oGetTlv:oBrowse:Refresh()

	ENDIF

Return(.T.)

	/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ MSTROT2QUERY³ Autor ³Expedito Mendonca Jr³ Data ³ 02/09/04 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡ao ³ Query para selecao dos registros						      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Sintaxe   ³ MSTROT2QUERY()                                             ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ Nenhum                                                     ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ NIL                                                        ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ MSTROT2                                                    ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	/*/
User Function MSTROT2Query(nPesoTotal,dDisp,aHeaderTmp,aColsTmp)
	Local nI, nContOrig, nContDest, cQuery
	Local lOk     := .F.
	Local aStru   := {}
	Local aOrigem, aDestino, aTpOrigem, aTpDestino
	Local nPProd	:= aScan(aHeaderTmp, {|x| AllTrim(x[2])=="UB_PRODUTO"})
	Local nPQuant	:= aScan(aHeaderTmp, {|x| AllTrim(x[2])=="UB_QUANT"})
	Local nPDtEntre := aScan(aHeaderTmp, {|x| AllTrim(x[2])=="UB_DTENTRE"})
	Local aMeiosTransp := u_RetX3Box("ZO_MEIOTRA")
	Local aHoraColeta := u_RetX3Box("A4_HORCOLE")
	Local cRota,cDescRota,cTransp,cNomTrans,cPrazoTransp,cFrequencia,cHoraColeta,cMeio,nKM,cTpCalc,nFracao,nValPFra,nQtdFracoes
	Local nIcms,nPerFExp
	Local nFreteNormal, nFreteExpres, nFretNorReemb, nFretExpReemb, nValReemb
	Local nValorBase,nAcresValNF,nAcresPeso
	Local cAreaAnt := alias(), aAreaSA1:=SA1->(getarea()), aAreaSUS:=SUS->(getarea())
	Local nVR4 := aValores[4]
//Local cDespCond    := Posicione("SE4",1,xFilial("SE4")+M->UA_CONDPG,"E4_DESPCOB")
//Local cDespCli     := Posicione("SA1",1,xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA,"A1_DESPCOB")

	aValores[4] := 0

//If (!lProspect .and. cDespCli == "N") .or. cDespCond == "N" .or. M->UA_ENDOSSO == "S" .or. M->UA_REEMB == "S"
//   aValores[5] := 0
//Else
//   aValores[5] := LEN(CONDICAO(1000,M->UA_CONDPG)) * GETMV("MV_DESPCOB")
//Endif

//Tk273RodImposto("NF_FRETE",aValores[4])
	RodImposto("NF_DESCONTO",aValores[2])
	RodImposto("NF_FRETE",aValores[4])
	RodImposto("NF_DESPESA",aValores[5])

// Define tipos de origens e destinos
//aTpOrigem := {"01","02","03","04","05","06","07","08"}
	aTpOrigem  := {"02"}
	aTpDestino := {"01","02","03","04","05","06","07","08"}
// Define as origens
	dbSelectArea("SA1")
	MsSeek(xFilial("SA1")+Getmv("MV_IMDEPA")+cFilAnt,.F.)
	aOrigem := {SA1->A1_COD,SA1->A1_CODCID,SA1->A1_CODCID,SA1->A1_MICRORE,SA1->A1_MESORG,SA1->A1_EST,SA1->A1_REGIAO,SA1->A1_PAIS}
// Define os destinos
	If lProspect
		dbSelectArea("SUS")
		MsSeek(xFilial("SUS")+M->UA_CLIENTE+M->UA_LOJA,.F.)
		aDestino := {M->UA_CLIENTE,SUS->US_CODCID,SUS->US_CODCID,SUS->US_MICRORE,SUS->US_MESORG,SUS->US_EST,SUS->US_REGIAO,SUS->US_PAIS}
	Else
		dbSelectArea("SA1")
		MsSeek(xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA,.F.)
		aDestino := {M->UA_CLIENTE,SA1->A1_CODCID,SA1->A1_CODCID,SA1->A1_MICRORE,SA1->A1_MESORG,SA1->A1_EST,SA1->A1_REGIAO,SA1->A1_PAIS}
	Endif

// Posiciona ordem do arquivo de PRAZOS (TRANSP. X CIDADES)
	dbSelectArea("ZZM")
	dbSetOrder(1)

// Posiciona ordem do cadastro de produtos
	dbSelectArea("SB1")
	dbSetOrder(1)

// Calcula o peso total
//obs: na função rotas o acols foi backupeado  como a seguir --> aColsTmp := aClone(aCols), aHeaderTmp := aClone(aHeader)
	nPesoTotal := 0
	dDisp := ctod("")
	For nI :=1 To Len(aColsTmp)
		IF !aColsTmp[nI,Len(aHeaderTmp)+1]	// a linha nao esta deletada // GdDeleted(nI) // O GDDELETED É MAIS LENTO
			SB1->(dbSeek(xFilial("SB1")+aColsTmp[nI][nPProd]),.F.)
			nPesoTotal += aColsTmp[nI][nPQuant] * SB1->B1_PESO
			If aColsTmp[nI][nPDtEntre] > dDisp
				dDisp := aColsTmp[nI][nPDtEntre]
			Endif
		Endif
	Next


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analisa todos os tipos de origens e destinos                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nContOrig := 1 to Len(aTpOrigem)

		For nContDest := 1 to Len(aTpDestino)

		// Ignora os tipos de destino "Clientes" quando se tratar de venda a prospects
			If aTpDestino[nContDest] == "01" .and. lProspect
				Loop
			Endif

		// Inicia a montagem da query
			cQuery := "SELECT SZO.ZO_CODROTA CODROTA, SZO.ZO_DESCRI DESCROTA, SZO.ZO_TRANSP TRANSP, SA4.A4_NOME NOMTRANS, SA4.A4_HORCOLE HORCOLE, "
			cQuery += "A4_VROTAMX VROTAMX,"
			cQuery += "SZO.ZO_NOTA NOTA, SZO.ZO_MEIOTRA MEIOTRA, SZO.ZO_PERFEXP PERFEXP, SZO.ZO_ICMS ICMS, SZO.ZO_FRACAO FRACAO, SZO.ZO_VALPFRA VALPFRA, "
			cQuery += "ZZL.ZZL_TPCALC TPCALC,ZZL.ZZL_VALFIX VALFIX, ZZL.ZZL_ITEM ITEM, ZZL.ZZL_VALLI VALLI,ZZL.ZZL_VALLS VALLS, ZZL.ZZL_PESOLI PESOLI,ZZL.ZZL_PESOLS PESOLS, ZZL.ZZL_PERNF PERNF, ZZL.ZZL_EXCNF EXCNF, ZZL.ZZL_VALPKG VALPKG, ZZL.ZZL_EXCKG EXCKG "

			cQuery += " FROM "+RetSqlName("SZO")+" SZO, "+RetSqlName("ZZL")+" ZZL, "+RetSqlName("SA4")+" SA4 "
			cQuery += IIF( aTpOrigem[nContOrig] == "03" , ", "+RetSqlName("ZZK")+" ZZK1 " , "" )
			cQuery += IIF( aTpDestino[nContDest] == "03" , ", "+RetSqlName("ZZK")+" ZZK2 " , "" )
			cQuery += " WHERE SZO.ZO_FILIAL = '" + xFilial("SZO") + "'"

		// Filtra o tipo de rota
			cQuery += " AND SZO.ZO_TPROTA <> '1'"

		// Filtra a origem
			cQuery += " AND SZO.ZO_TPORIG = '"+aTpOrigem[nContOrig]+"'"
			If aTpOrigem[nContOrig] == "03"	// Grupo de Cidades
				cQuery += " AND ZZK1.ZZK_FILIAL = '"+xFilial("ZZK")+"'"
				cQuery += " AND ZZK1.ZZK_CODGRP = SZO.ZO_ORIGEM"
				cQuery += " AND ZZK1.ZZK_CODCID = '"+aOrigem[Val(aTpOrigem[nContOrig])]+"'"
			Else
				cQuery += " AND SZO.ZO_ORIGEM = '"+aOrigem[Val(aTpOrigem[nContOrig])]+"'"
			Endif
			If aTpOrigem[nContOrig] == "01"	// Tipo de origem Clientes
				cQuery += " AND SZO.ZO_LOJAORI= '"+cFilAnt+"'"
			Endif

		// Filtra o destino
			cQuery += " AND SZO.ZO_TPDEST = '"+aTpDestino[nContDest]+"'"
			If aTpDestino[nContDest] == "03"	// Grupo de Cidades
				cQuery += " AND ZZK2.ZZK_FILIAL = '"+xFilial("ZZK")+"'"
				cQuery += " AND ZZK2.ZZK_CODGRP = SZO.ZO_DESTINO"
				cQuery += " AND ZZK2.ZZK_CODCID = '"+aDestino[Val(aTpDestino[nContDest])]+"'"
			Else
				cQuery += " AND SZO.ZO_DESTINO = '"+aDestino[Val(aTpDestino[nContDest])]+"'"
			Endif
			If aTpDestino[nContDest] == "01"	// Tipo de destino Clientes
				cQuery += " AND SZO.ZO_LOJADES = '"+M->UA_LOJA+"'"
			Endif

		// Verifica os intervalos de peso e valores
		//		cQuery += " AND ( ( ZZL.ZZL_VALLI <= "+Alltrim(Str(aValores[6]))+" AND ZZL.ZZL_VALLS >= "+Alltrim(Str(aValores[6])) + " ) OR "
		//		cQuery += " ( ZZL.ZZL_PESOLI <= "+Alltrim(Str(nPesoTotal))+" AND ZZL.ZZL_PESOLS >= "+Alltrim(Str(nPesoTotal)) + " ) ) "
		//		cQuery += " AND (ZZL.ZZL_TPFRET = '1' OR ZZL.ZZL_TPFRET = '"+IIF(M->UA_TPFRETE=="C","2","3")+"')"

		// Verifica os intervalos de peso e valores   // Agostinho - 10/03/2009 - correção da query
			cQuery += " AND ( (  "+Alltrim(Str(aValores[6]))+" BETWEEN ZZL.ZZL_VALLI AND ZZL.ZZL_VALLS OR ZZL.ZZL_EXCNF = '1' ) AND "
			cQuery += " ( "+Alltrim(Str(nPesoTotal))+" BETWEEN ZZL.ZZL_PESOLI AND ZZL.ZZL_PESOLS OR ZZL.ZZL_EXCKG = '1'  ) ) "
			cQuery += " AND (ZZL.ZZL_TPFRET = '1' OR ZZL.ZZL_TPFRET = '"+IIF(M->UA_TPFRETE=="C","2","3")+"')"



		// relacionamento com ZZL
			cQuery += " AND ZZL.ZZL_FILIAL = SZO.ZO_FILIAL "
			cQuery += " AND ZZL.ZZL_CODROT = SZO.ZO_CODROTA "

		// relacionamento com SA4
			cQuery += " AND SA4.A4_FILIAL = '"+xFilial("SA4")+"'"
			cQuery += " AND SA4.A4_COD = SZO.ZO_TRANSP "

		// deletados
			cQuery += " AND SZO.D_E_L_E_T_ <> '*'"
			cQuery += " AND ZZL.D_E_L_E_T_ <> '*'"
			cQuery += " AND SA4.D_E_L_E_T_ <> '*'"
			cQuery += IIF( aTpOrigem[nContOrig] == "03" , " AND ZZK1.D_E_L_E_T_ = ' '" , "" )
			cQuery += IIF( aTpDestino[nContDest] == "03" , " AND ZZK2.D_E_L_E_T_ = ' '" , "" )

			cQuery += " order by SZO.ZO_CODROTA,ZZL.ZZL_TPCALC,ZZL.ZZL_VALFIX ASC, ZZL.ZZL_ITEM ASC "

		// Executa a query
			cQuery := ChangeQuery(cQuery)
			MEMOWRIT( "C:\SQLSIGA\MSTROT2-"+FunName(1)+ ;
				"-ORIGEM(" +STR(nContOrig,2) + ")- DESTINO("+ STR(nContDest,2) + ".SQL", cQuery )
			TCQUERY cQuery NEW ALIAS "TRB"

			If Alias() == "TRB"
				lOk := .T.
				aStru := DbStruct()
				For nI := 1 To Len( aStru )
					If aStru[nI,2] != "C"
						TCSetField( "TRB", aStru[nI,1], aStru[nI,2], aStru[nI,3], aStru[nI,4] )
					EndIf
				Next
			Else
				lOk := .F.
				exit
			Endif

		// Calcula o frete e preenche o aColsTmp
			Do While !Eof()

			// Posiciona tabela de PRAZOS (TRANSP. X CIDADES)
				ZZM->(MsSeek(xFilial("ZZM")+TRB->TRANSP+aOrigem[2]+aDestino[2],.F.))

			// Campos informativos
				cRota 		:= TRB->CODROTA
				cDescRota 	:= TRB->DESCROTA
				cTransp 	:= TRB->TRANSP
				cNomTrans 	:= TRB->NOMTRANS
				cFrequencia := RetFrequencia({ZZM->ZZM_DOM,ZZM->ZZM_SEG,ZZM->ZZM_TER,ZZM->ZZM_QUA,ZZM->ZZM_QUI,ZZM->ZZM_SEX,ZZM->ZZM_SAB})
				cPrazoTransp:= RetPrazoTransp(ZZM->ZZM_PRAZOD,ZZM->ZZM_PRAZOH)
				cHoraColeta := u_X3CBOXDES(TRB->HORCOLE,aHoraColeta)
				nNota       := TRB->NOTA
				cMeio 		:= u_X3CBOXDES(TRB->MEIOTRA,aMeiosTransp)
				nKM			:= ZZM->ZZM_KM

			// Variaveis para calculo
				nPerFExp := TRB->PERFEXP
				nIcms	 := TRB->ICMS
				nFracao  := TRB->FRACAO
				nValPFra := TRB->VALPFRA

			// Composicao do frete
				nFreteNormal := 0
			// Valor do reembolso
				nValReemb  := 0


			// Inicializa variaveis para armazenar registro de maior valor de frete
			// Acumuladores do valor a ser usado
				x_nValorBase 	:= 0
				x_nAcresValNF	:= 0
				x_nAcresPeso 	:= 0
				x_nFreteNormal	:= 0
				x_nValReemb		:= 0
				x_cTpcalc		:= " "
			//temina inicilizacao

				Do While TRB->CODROTA == cRota .and. !Eof()

				//				If TRB->TPCALC != "03" .or. M->UA_REEMB == "S"		// Reembolso

				// calcula o valor de acrescimo baseado no valor da NF
					If TRB->EXCNF == "1"	// Percentual de acrescimo apenas no excedente
						nValorBase := aValores[6] - TRB->VALLS
						If nValorBase < 0
							nValorBase := 0
						Endif
					Else
						nValorBase := aValores[6]
					Endif
					nAcresValNF := nValorBase * TRB->PERNF / 100

				// calcula o valor de acrescimo baseado no peso
					If TRB->EXCKG == "1"	// Valor acrescido apenas ao excedente
						nValorBase := nPesoTotal - TRB->PESOLS
						If nValorBase < 0
							nValorBase := 0
						Endif
					Else
						nValorBase := nPesoTotal
					Endif
					nAcresPeso := nValorBase * TRB->VALPKG

				// Forma o valor do frete nesta rota
					If TRB->TPCALC != "03"	// calcula o valor do frete normal
						nFreteNormal += TRB->VALFIX + nAcresValNF + nAcresPeso
					Else					// calculo so do reembolso
						nValReemb  += TRB->VALFIX + nAcresValNF + nAcresPeso
					Endif

				//				Endif

					cTpCalc := TRB->TPCALC

					IF TRB->VROTAMX  == "S"
						IF nFreteNormal >  x_nFreteNormal
							x_nValorBase 	:= nValorBase
							x_nAcresValNF	:= nAcresValNF
							x_nAcresPeso 	:= nAcresPeso
							x_nFreteNormal	:= nFreteNormal
							x_nValReemb		:= nValReemb
							x_cTpcalc		:= cTpcalc
						ENDIF
						dbSkip()
						IncProc()
						IF !(TRB->CODROTA+TRB->TPCALC == cRota+cTpCalc)
							nValorBase 	:= x_nValorBase
							nAcresValNF	:= x_nAcresValNF
							nAcresPeso 	:= x_nAcresPeso
							nFreteNormal:= x_nFreteNormal
							nValReemb	:= x_nValReemb
							cTpcalc		:= x_cTpcalc
						ELSE
						//Reinicializa acumuladores
							nValorBase 	:= 0
							nAcresValNF	:= 0
							nAcresPeso 	:= 0
							nFreteNormal:= 0
							nValReemb	:= 0
							cTpcalc		:= " "

						ENDIF

					ELSE
						Do While TRB->CODROTA+TRB->TPCALC == cRota+cTpCalc .and. !Eof()
							dbSkip()
							IncProc()
						Enddo
					ENDIF
					IncProc()
				Enddo

			// Adiciona ao valor do frete o valor por fracao (utilizado normalmente para calcular pedagio)
				nQtdFracoes := IIF( nFracao > 0 , Int(nPesoTotal / nFracao) + IIF(nPesoTotal % nFracao = 0,0,1) , 0 )
				nFreteNormal += (nQtdFracoes * nValPFra)

			// Calculo do frete com reembolso (soma o reembolso e aplica o percentual de ICMS)
				If nValReemb == 0
					nFretNorReemb := 0
				Else
					nFretNorReemb := nFreteNormal + nValReemb
				//				nFretNorReemb += A410Arred(nFretNorReemb * nICMS / 100,"D2_VALICM")
					nFretNorReemb += A410Arred( ( nFretNorReemb / ((100-nICMS)/100) ) - nFretNorReemb ,"D2_VALICM")
					nFretNorReemb := Round(nFretNorReemb,2)
				Endif

			// Calculo do Frete Expresso com reembolso e aplica o percentual de ICMS
				If nValReemb == 0 .or. nPerFExp == 0
					nFretExpReemb := 0
				Else
					nFretExpReemb := (nFreteNormal + nValReemb) * (1+(nPerFExp / 100))
				//		     	nFretExpReemb += A410Arred(nFretExpReemb * nICMS / 100,"D2_VALICM")
					nFretExpReemb += A410Arred( ( nFretExpReemb / ((100-nICMS)/100) ) - nFretExpReemb ,"D2_VALICM")
					nFretExpReemb := Round(nFretExpReemb,2)
				Endif

			// Calculo do Frete Expresso sem reembolso e aplica o percentual de ICMS
				If nPerFExp == 0
					nFreteExpres := 0
				Else
					nFreteExpres := nFreteNormal * (1+(nPerFExp / 100))
				//		     	nFreteExpres += A410Arred(nFreteExpres * nICMS / 100,"D2_VALICM")
					nFreteExpres += A410Arred( ( nFreteExpres / ((100-nICMS)/100) ) - nFreteExpres ,"D2_VALICM")
					nFreteExpres := Round(nFreteExpres,2)
				Endif

			// Aplica o percentual de ICMS no Frete Normal (sem reembolso)
			//	     	nFreteNormal += A410Arred(nFreteNormal * nICMS / 100,"D2_VALICM")
				nFreteNormal += A410Arred( ( nFreteNormal / ((100-nICMS)/100) ) - nFreteNormal ,"D2_VALICM")
				nFreteNormal := Round(nFreteNormal,2)

			// Adiciona a rota
				If M->UA_REEMB != "S" .or. nValReemb != 0	// se for reembolso, filtra apenas as transportadoras que tem reembolso
					If aScan(__aRotasDisponiveis , {|x| x[1] == cTransp} ) == 0		// Mostra apenas uma rota por transportadora
						aAdd(__aRotasDisponiveis,{cTransp,cNomTrans,cRota,cDescRota,cPrazoTransp,cFrequencia,cHoraColeta,nFreteNormal,nFretNorReemb,nFreteExpres,nFretExpReemb,nNota,cMeio,nKM})
					Endif
				Endif
			Enddo

		// Fecha alias temporario
			dbSelectArea("TRB")
			dbCloseArea()
			IncProc()
		Next
	Next

	aValores[4] := nVR4
	Tk273RodImposto("NF_FRETE",aValores[4])

// Restaura ambiente
	Restarea(aAreaSA1)
	Restarea(aAreaSUS)
	dbSelectArea(cAreaAnt)

Return lOk



	/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³RETFREQUENCIA³ Autor ³Expedito Mendonca Jr³ Data ³ 22/09/04 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡ao ³ Retorna string com os nomes dos dias             	      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ MSTROT2QUERY                                               ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	/*/
Static Function RetFrequencia(aDias)
	Local nI, cRet := ""
	Local aNomeDias := {"Dom","Seg","Ter","Qua","Qui","Sex","Sab"}
	For nI := 1 to Len(aDias)
		If aDias[nI] == "1"
			cRet += aNomeDias[nI]+"/"
		Endif
	Next
	cRet := Left(cRet,Len(cRet)-1)
Return cRet


	/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³RETPRAZOTRANS³ Autor ³Expedito Mendonca Jr³ Data ³ 22/09/04 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡ao ³ Retorna o prazo de entrega da transportadora por extenso   ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ MSTROT2QUERY                                               ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	/*/
Static Function RetPrazoTransp(nPrazoD,cPrazoH)
	Local cRet := ""
	If nPrazoD > 0
		cRet += Alltrim(Str(nPrazoD))+IIF(nPrazoD=1," dia"," dias")
	Endif
	If !Empty(cPrazoH)
		If nPrazoD > 0
			cRet += " e "
		Endif
		cRet += Transform(cPrazoH,"@R 99:99")+"h"
	Endif
Return cRet

	/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³U_XBTRANSP   ³ Autor ³Expedito Mendonca Jr³ Data ³ 22/09/04 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡ao ³ Retorna o codigo da transportadora, utilizado na consulta  ³±±
	±±³          ³ padrao SA4                                                 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ MSTROT2                                                    ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	/*/
/*
User Function XBTRANSP()
Local cRet := IIF(cXBTransp == NIL,SA4->A4_COD,cXBTransp)
cXBTransp := NIL
Return cRet
*/

	/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³MENSFRETEEXP ³ Autor ³GLOBAL INFORMATICA  ³ Data ³ 10/07/04 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡ao ³ MODIFICA MENSAGEM DA NOTA CONFORME FRETE EXPRESSO OU NAO   ³±±
	±±³          ³                                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ MSTROT2                                                    ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	/*/



Static Function MENSFRETEEXP()
	Local lExisteMens 	:= .F.
	Local nPosMen 		:= 0
	Local nMensFreteExp := '(Frete Expresso)'
	Local __UA_MENNOTA  := ALLTRIM(M->UA_MENNOTA)

	IF AT(nMensFreteExp,__UA_MENNOTA) > 0
		lExisteMens := .T.
	ENDIF

//M->UA_FRETEXP := IIF(nNorExp==2,"1","2")  // 1=Sim, 2=Nao

	IF M->UA_FRETEXP == '1' // se for frete expresso
		IF !lExisteMens
			__UA_MENNOTA := nMensFreteExp +" "+ __UA_MENNOTA
		ENDIF
	ELSEIF  lExisteMens		// se NAO for frete expresso
		nPosMen := AT(nMensFreteExp,__UA_MENNOTA)
		IF nPosMen > 0
		//	lExisteMens := .T.
			__UA_MENNOTA := STRTRAN(__UA_MENNOTA,nMensFreteExp,' ')
		//ELSE
		//	lExisteMens := .F.
		ENDIF

	ENDIF

	IF !EMPTY(__UA_MENNOTA)
		__UA_MENNOTA := ALLTRIM(__UA_MENNOTA )
	ENDIF
	__UA_MENNOTA := __UA_MENNOTA + SPACE( tamSX3("UA_MENNOTA ")[1] - LEN(__UA_MENNOTA) )

Return __UA_MENNOTA

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³RodImposto      ³Autor  ³ Agostinho Lima  ³ Data ³ 04/08/10 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³Alteracao da funcao Tk271RodImposto para fazer o calculo do ³±±
	±±³          ³aValores[6]                                                 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ ExpC1 = Referencia ( vide MATXFIS)                         ³±±
	±±³          ³ ExpC2 = Valor da Referencia                                ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ TeleVendas                                                 ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Static Function RodImposto(cReferencia, xValor)

	Local aArea		:= GetArea()					// Salva a area atual
	Local lMV_TMKFIS:= .T.// GetNewPar("MV_TMKFIS",.T.)	// (Não divulgar) Parametro que indica que a atualização da MATXFIS é feita de maneira on-line, no off-line a MATXFIS só é atualizada quando se entra na condição de pagamento.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o parâmetro MV_TMKFIS estiver como .F., não faz a    ³
//³atualização da matxfis, pois esse processo demora demais³
//³quando há muitos itens na televendas. Essa atualização  ³
//³só ocorre quando a condição de pagamento é executada.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If MaFisFound("NF") .AND. !(MaFisRet(,cReferencia) == xValor) .AND. lMV_TMKFIS
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Workaround para forçar o cálculo correto de suframa, sem  ³
	//³esse workaround a matxfis distribui incorretamente o valor³
	//³suframa entre os itens da televendas.                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//	If cReferencia == "NF_DESPESA" .And. aValores[SUFRAMA] > 0
		If cReferencia == "NF_DESPESA" .And. aValores[7] > 0

			MaFisAlt(cReferencia, 0)
		EndIf

		MaFisAlt(cReferencia,xValor)
		Tk273AtuNFs()
	Endif
//aValores[1]	:= MaFisRet(, "NF_VALMERC")
//aValores[7]	:= MaFisRet(, "NF_DESCZF")
//aValores[5]	:= MaFisRet(, "NF_DESPESA")
//	aValores[6]	:= MaFisRet(, "NF_TOTAL")
//aValores[1]mercardoria
//aValores[2]desconto
//aValores[3]acrescimo
//aValores[4]frete
//aValores[5]despesa
//aValores[6]total
//aValores[7]suframa
//aValores[8]base dup
	RestArea(aArea)
Return (.T.)

******************************************************************
Static Function Ver_M_TeV(__nDestaca) //Analista: Cristiano ... Data: 24/07/2013 ... Desc.: Retorna Frete Menor Valor e Prazo...
******************************************************************
	Local nAuxVal := 9999
	Local nPosVal := 0
	Local nPosCaF := 0
	Local aColsRet	:= {}

	Local _CarroFixo := Alltrim(POSICIONE( "SX5", 1, xFilial("SX5")+"XX"+cFilAnt, "X5_DESCRI" ))
	Local _lFilOpera := !Empty(_CarroFixo)

	If !_lFilOpera // Filial nao OPERA...
		Return (__aRotasDisponiveis)
	EndIf


	If 	( M->UA_TPFRETE == "C" ) // CIF

		//If __nDestaca == 2 .And. Len( __aRotasDisponiveis ) > 0
		If Len( __aRotasDisponiveis ) > 0
			For n := 1 To Len (__aRotasDisponiveis)

				If ( __aRotasDisponiveis[n][1]  ) == _CarroFixo

					If ( nPosCaF == 0 )
						nPosCaF := n
					EndIf

				ElseIf (  __aRotasDisponiveis[n][8] < nAuxVal .And.  __aRotasDisponiveis[n][8] <> 0 ) // Valor
					nAuxVal := __aRotasDisponiveis[n][8]
					nPosVal := n

				EndIf

			Next

			If ( nPosVal > 0 ) /// Menor Valor
				AaDd ( aColsFil , __aRotasDisponiveis[nPosVal] )
			EndIf

			If ( nPosCaF > 0 ) //Carro Fixo
				AaDd ( aColsFil , __aRotasDisponiveis[nPosCaF] )
			EndIf

		EndIf

	ElseIf ( M->UA_TPFRETE == "F" ) // FOB

		If Len( __aRotasDisponiveis ) > 0

			For n := 1 To Len (__aRotasDisponiveis)

				If ( __aRotasDisponiveis[n][1]  ) == _CarroFixo .And. nPosCaF == 0
					nPosCaF := n
				EndIf

			Next

			If nPosCaF > 0
				aDel(__aRotasDisponiveis, nPosCaF)
				aSize(__aRotasDisponiveis, Len(__aRotasDisponiveis) -1 )
			EndIf

		EndIf

	EndIf


	If Len(aColsFil) > 0
		aColsRet := aClone( aColsFil )
	Else
		aColsRet := aClone( __aRotasDisponiveis )
	EndIf


Return ( aColsRet )
/*
******************************************************************
Static Function ConvPrazo(_Prazo)// Converte o Prazo para Valor em Dias...
******************************************************************
	local nRet  := 0
	local nDias := At( _Prazo, 'dias')

	If nDias > 0
		nRet := Val( Substr(_Prazo,1,nDias-1) )
	Else
		nRet := Val ( Substr(_Prazo,1,2) )
		nRet := Round( nRet / 24 , 2 )
	EndIf

Return(nRet)
*/
******************************************************************
Static Function Change_Acols( _nDestaca )
******************************************************************
Local _CarroFixo := Alltrim(POSICIONE( "SX5", 1, xFilial("SX5")+"XX"+cFilAnt, "X5_DESCRI" ))
Local _lFilOpera := !Empty(_CarroFixo)

	If 	_lFilOpera
		If 	( M->UA_TPFRETE == "C" ) // CIF

			If ( _nDestaca == 2 ) // Nao Destaca
				aCols :=  Aclone( aColsFil )

			Else // Destaca
				aCols := Aclone( __aRotasDisponiveis )

			EndIf
		EndIf
	EndIf

	oDestaca:refresh()
	oItens:refresh()

Return()
//aSort(__aRotasDisponiveis,,,{|x,y| x[5] < y[5] }) // Prazo


/*
	aAdd(aHeader,{ "Transportadora"		, "ZO_CODTRAN"  ,""                   ,  6, 0,  " "  , " "  , "C", "SA4" } )
	aAdd(aHeader,{ "Nome"           	, "ZO_NOMTRANS" ,""                   , 40, 0,  " "   , " " , "C", ""    } )
	aAdd(aHeader,{ "Rota"            	, "ZO_CODROTA"  ,""                   ,  6, 0,  " "  , " "  , "C", ""    } )
	aAdd(aHeader,{ "Descricao"      	, "ZO_DESCRI"   ,""                   , 40, 0,  " "   , " " , "C", ""    } )
	aAdd(aHeader,{ "Prazo"           	, "ZO_FREQUEN"  ,""                   , 18, 0,  " "   , " " , "C", ""    } )
	aAdd(aHeader,{ "Frequencia"      	, "ZO_FREQUEN"  ,""                   , 23, 0,  " "   , " " , "C", ""    } )
	aAdd(aHeader,{ "Horario Coleta"  	, "ZZL_DESTPC"  ,""                   , 12, 0,  " "   , " " , "C", ""    } )
	aAdd(aHeader,{ "Frete Normal"    	, "ZZL_VALFIX"  ,"@E 999,999,999.99"  , 12, 2,  " "   , " " , "N", ""    } )
	aAdd(aHeader,{ "Frete c/ Reemb." 	, "ZZL_VALFIX"  ,"@E 999,999,999.99"  , 12, 2,  " "   , " " , "N", ""    } )
	aAdd(aHeader,{ "Frete Expresso"  	, "ZZL_VALFIX"  ,"@E 999,999,999.99"  , 12, 2,  " "   , " " , "N", ""    } )
	aAdd(aHeader,{ "Fret.Exp.c/ Reemb.", "ZZL_VALFIX"  ,"@E 999,999,999.99"  , 12, 2,  " "   , " " , "N", ""    } )
	aAdd(aHeader,{ "Nota"            	, "ZO_NOTA"     ,"@E 99.99"           , 5,  2,  " "   , " " , "N", ""    } )
	aAdd(aHeader,{ "Meio"            	, "ZZL_DESTPC"  ,""                   , 12, 0,  " "   , " " , "C", ""    } )
	aAdd(aHeader,{ "Distancia Km"    	, "ZZM_KM"      ,"@E 999,999.99"      , 9 , 2,  " "   , " " , "N", ""    } )
*/





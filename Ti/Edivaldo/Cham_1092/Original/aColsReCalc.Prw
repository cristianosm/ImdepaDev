#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#DEFINE  ENTER CHR(13)+CHR(10)

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³aColsReCalc³ Autor ³ Fabiano Pereira      ³ Data ³23.09.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Programa chama funcao para ReCalcular os valores dos itens  ³±±
±±³          ³ do aCols.                                                   ³±±
±±³          ³                                                             ³±±
±±³          ³ Chamado via Gatilho no campo UA_CLIENTE\UA_TABELA\UA_DESC4  ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Imdepa P11                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
OBS.: NAO COLOCAR NO X3_VLDUSER PE FT080RDES ALTERA VALORES...
*/
**********************************************************************
User Function aColsReCalc()
**********************************************************************
Local aArea			:= 	GetArea()
Local cContCpo		:=	&(ReadVar())
Local cDescCpo		:=	''
Local cOldCpo		:=	''
Local lAlterou 		:= 	.F.
Local lRetorno		:=	.T.

Private cCampo		:=	Substr(ReadVar(),04)
Private _cOpcao		:=	IIF(Type('ParamIxb')== 'A', ParamIxb[01], 'TODOS')
Private lOnlyArray	:=	IIF(Type('ParamIxb')== 'A', IIF(Len(ParamIxb)>=2, ParamIxb[02], .F.), .F.)
Private cCondPgto	:=	IIF(Type('ParamIxb')== 'A', IIF(Len(ParamIxb)>=3, ParamIxb[03], M->UA_CONDPG), M->UA_CONDPG)
Private	lX3VldUser 	:= 	Left(_cOpcao,7) == 'VLDUSER'
		cCampo		:=	IIF(Upper(SubStr(ProcName(2),03)) == 'TMKVLDE4', 'UA_CONDPG', cCampo)
		cCampo		:=	IIF(Upper(SubStr(ProcName(6),03)) == 'TMKVCP',   'UA_CONDPG', cCampo)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| 'TMKVLDE4'																						 |
//³  VERIFICA SE CHAMADO Eh DO TMKVLDE4 (BTN. COND.PAGTO) VALIDACAO SE USUARIO TROCOU A COND.PAGTO   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| CABEC DO ARRAY - DADOS GERAIS                                                                   |
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//|Aadd(aProdxImp, {	aCols[n][nPItem],;			//	[01] ITEM          							|
//|						aCols[n][nPProduto],;		//	[02] COD.PRODUTO              				|
//|						cDescProd,;					//	[03] DESCRICAO DO PRODUTO            		|
//| 					0 ,;						//	[04] PRECO DE TABELA                      	|
//| 					0 ,;						//	[05] VLR.PRODUTO + IMPOSTOS               	|
//| 					0 ,;						//	[06] VLR. TOTAL IMPOSTOS 2 DECIMAIS      	|
//| 					aCols[n][nPQuant],;			//	[07] QUANTIDADE               				|
//| 					0,;							//  [08] %  DO IMPOSTO SOBRE O VALOR UNITARIO	|
//| 					0,; 						//	[09] R$ DO IMPOSTO SOBRE O VALOR UNITARIO 	|
//|                    	nVlrSuframa ,;				//	[10] DESCONTO SUFRAMA(ICMS/PIS/COFINS)		|
//|                    	aCols[n][nPTES],;	        //  [11] TES							        |
//|                    	Cliente\Loja,;              //  [12] Cliente\Loja							|
//|                    	Condicao Pagamento,;        //  [13] Cond.Pagamento							|
//|                    	Tabela de Preco,; 	 	    //  [14] Tabela de Preco						|
//|						aCols[nLinha][nPPrUnit],;	//	[15] R$ Preco Unit. 						|
//|						M->UA_DESC4,;				//	[16] % Desconto Cabec						|
//|						0,;  						//	[17] VLR. TOTAL IMPOSTOS 4 DECIMAIS			|
//|						0,;							//	[18] 1o PRECO CALCULADO	(PRECO UNITARIO)	|
//|						0,;							//	[19] 1o PRECO CALCULADO	(PRECO C\ACRESC)	|
//|						UA_DESCG,;					//	[20] % DESCONTO GERAL						|
//|						0,; 						//	[21] SOMA ALIQUOTAS IMPOSTOS				|
//|						0 		})					//	[22] PRECO DA FORMACAO DE PRECO				|
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//| ITENS DO ARRAY - DADOS DOS IMPOSTOS   ( ARRAY DENTRO DO aProdXImp )                             |
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//|	Aadd(aProdxImp[nPosProd], {	cImposto,;			//	[01] COD.IMPOSTO							|
//|								cDescImp,;			//	[02] DESCRICAO IMPOSTO               		|
//|								nBaseImp,;			//	[03] BASE                            		|
//|								nAliqImp,;			//	[04] ALIQUOTA                        		|
//|								nValorImp,;			//	[05] VALOR                          		|
//|								nVlImp4Dec})		//	[06] VALOR                         		 	|
//|                                                									        	    |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


If Upper(SubStr(ProcName(2),03)) == 'TLVENT'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  HISTORICO DE ATENDIMENTO	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lAlterou  := .T.



ElseIf cCampo == 'UA_CLIENTE'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  		 CLIENTE	 		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Len(aProdxImp) > 0 .And. SubStr(Upper(ProcName(2)), 03) != 'TMKVDEL'

		// AO INFORMAR OUTRO OU O MESMO CLIENTE X3_VALID EXECUTA A ROTINA TK273Recalc(,,.T.) QUE RECALCULA, NO PADRAO, O PRC.UNITARIO

		//MsgAlert('CAMPO '+Upper(AllTrim(RetTitle(cCampo)))+'   JÁ INFORMADO.'+ENTER+ENTER+;
		//					 '--> TODOS OS ITENS SERÃO RECALCULADOS. <--'+ENTER+ENTER,'aColsReCalc')

		lRetorno :=	.T.

		//If !lAlterou
		//	cOldCpo		:=	Left(aProdxImp[nAltCli][12], TamSx3('UA_CLIENTE')[1])
		//	M->UA_DESC4	:= 	aProdxImp[nAltCli][16]
		//EndIf


		/*
		nAltCli	:=	Ascan(aProdxImp, {|X| Left(X[12],06) != AllTrim(M->UA_CLIENTE) })

		If nAltCli > 0
            MsgInfo('NÃO É PERMITIDO A TROCA DO CLIENTE QUANDO JÁ INFORMADO PRODUTO\ITEM.'+ENTER+ENTER+;
            	  'VOCÊ DEVE CONCLUIR O ATENDIMENTO COM O CLIENTE: '+cCliente+' \ '+cLojaCli)
            //cOldCpo	:=	Left(aProdxImp[nAltCli][12], TamSx3('UA_CLIENTE')[1])

            lAlterou := .F.
		EndIf
	    */

	EndIf


ElseIf cCampo == 'UA_TABELA'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³      TABELA DE PRECO	 	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Len(aProdxImp) > 0 .And. SubStr(Upper(ProcName(2)), 03) != 'TMKVDEL'

		nAltTab	:=	Ascan(aProdxImp, {|X| X[14] != AllTrim(M->UA_TABELA) })

		If nAltTab > 0


			lAlterou := MsgYesNo('AO MUDAR  [ '+Upper(AllTrim(RetTitle(cCampo)))+' ]  OS VALORES DOS ITENS EXISTENTES SERÃO ALTERADOS.'+ENTER+ENTER+;
								'OS PRODUTOS QUE NÃO ESTÃO RELACIONADOS NA TAB.PREÇO  [ '+M->UA_TABELA+' ]  SERÃO DELETADOS\RESTAURADOS.'+ENTER+ENTER+;
								'DESEJA CONTINUAR ?','aColsReCalc')

			If !lAlterou
				cOldCpo		:=	aProdxImp[nAltTab][14]
				M->UA_DESC4	:= 	aProdxImp[nAltTab][16]
			EndIf

		EndIf

	EndIf


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
		If DbSeek(xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA, .F.)
			cCliente	:= 	SA1->A1_COD
			cLoja		:= 	SA1->A1_LOJA
		EndIf
	EndIf


	cGrpSeg	:= 	SA1->A1_GRPSEG
	cTabela	:=	SA1->A1_TABELA

	aValidDA0 := ExecBlock('ChkValidDA0',.F.,.F.,{cTabela})
	If aValidDA0[01]
		M->UA_TABELA := aValidDA0[02]
	EndIf



ElseIf cCampo == 'UA_CONDPG' .And. !Empty(GdFieldGet('UB_PRODUTO', n))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³    CONDICAO DE PAGAMENTO	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| ** FORCAR PARA RECALCULAR **   (NAO EXECUTAR NO X3_VALID)   ( CHAMADA VIA GATILHO OU PROGRAMA)				     |
	//³	NECESSARIO RODAR RECALCULO LINHA A LINHA...                                                                      |
	//|	POIS AO TROCAR (OU INFO MESMA) COND.PGTO O SISTEMA ATUALIZA PRECO UNITATIO (PRC.TAB - DESCONTOS)                 ³
	//³	NAO ADICIONAR FUNCAO NO X3_VLDUSER PQ DEPOIS DE ATUALIZAR OS VALORES DO PRECO UNITARIO + IMPOSTOS                |
	//|	O SISTEMA ATUALIZA PRECO UNITATIO (PRC.TAB - DESCONTOS)	 														 ³
	//³	FUNCAO aColsReCalc CHAMADA VIA BTN COND.PAGTO (F6) E AO ALTERAR CAMPO COND.PAGTO(UA_CONDPG)                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³   MV_PVRECAL - Indica se desabilita o recalculo da tabela de preco no pedido de venda = .T.	 ³
	//    PARAMETRO DESABILITA RECALCULO AO TROCAR A CONDICAO DE PAGAMENTO
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Len(aProdxImp) > 0 .And. SubStr(Upper(ProcName(2)), 03) != 'TMKVDEL'

		nAltPgto :=	Ascan(aProdxImp, {|X| X[13] != AllTrim(cCondPgto) })
		If nAltPgto > 0

			cOldCpo		:=	aProdxImp[nAltPgto][13]
			nOldAcresc 	:= 	Posicione('SE4',1,xFilial('SE4')+cOldCpo,	'E4_ACRSFIN')
			nAtuAcresc 	:= 	Posicione('SE4',1,xFilial('SE4')+cCondPgto,	'E4_ACRSFIN')

			lAlterou := IIF(nAtuAcresc == nOldAcresc, .F., .T.)

			//lAlterou 	:= .T.		// OBRIGATORIO RECALCULAR X3_VALID TMK273Recalc
			cOldCpo		:=	''
			M->UA_CONDPG:= cCondPgto
			cContCpo	:= M->UA_CONDPG

		Else
			// SE COND.PAGTO EH A MESMA
			// FORCA RECALCULO - PQ X3_VALID RODA TMK273Recal QUE ALTERA VALOR DO PRC.UNIT
			lAlterou 	:= 	.F. //IIF(Len(aCols) > 0, .T., .F.)
		EndIf

	Else
		If SubStr(Upper(ProcName(2)), 03) != 'TMKVDEL'
			lAlterou 	:= 	IIF(Len(aCols) > 0, .T., .F.)

				cOldCpo		:=	''
			M->UA_CONDPG:= cCondPgto
			cContCpo	:= M->UA_CONDPG

		EndIf
	EndIf


ElseIf cCampo == 'UA_DESC4' //.And. !Empty(GdFieldGet('UB_PRODUTO', n))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| 	% DESCONTO GERAL		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Len(aContDesc) > 0
		/*
			Aadd(aContDesc, M->UA_NUM)  	//	[01] NUMERO DO ATENDIMENTO
			Aadd(aContDesc,cCliente)       	//	[02] CODIGO DO CLIENTE
			Aadd(aContDesc,cTabPreco)		//	[03] TABELA DE PRECO
			Aadd(aContDesc,cCondPg)			//	[04] CONDICAO DE PAGAMENTO
			Aadd(aContDesc,cFormPg)       	//	[05] FORMA DE PAGAMENTO
			Aadd(aContDesc,M->UA_DESCORI)	//	[06] DESCONTO ORIGINAL
			Aadd(aContDesc,.F.)				//	[07] CONTROLA SE JA DEU DESCONTO
			Aadd(aContDesc,M->UA_DESC4) 	//	[08] DESCONTO ATUAL
			aContDesc[09] := aContDesc[08]	//	[09] ULTIMO DESCONTO INFORMADO  // aContDesc[9] := aContDesc[8]
		*/


		If lX3VldUser .And. M->UA_DESC4 > aContDesc[06]
			If aContDesc[06] == 0
				MsgAlert('Não consta nenhuma Regra de Desconto para esse Cliente.'+ENTER+;
						 'O campo '+AllTrim(RetTitle('UA_DESC4'))+' deve ser igual a zero.'+ENTER+ENTER+;
						 'Utilize o campo '+AllTrim(RetTitle('UA_DESCG'))+' para conceder desconto.')

			Else
				MsgAlert('Máximo permitido para '+AllTrim(RetTitle(cCampo))+' é de '+AllTrim(Str(aContDesc[08])))
			EndIf
			lRetorno := .F.
	  	Else

			If aContDesc[09] != aContDesc[08] //.Or. aContDesc[08] == aContDesc[09]

				//lAlterou := MsgYesNo('AO MUDAR  [ '+Upper(AllTrim(RetTitle(cCampo)))+' ]  OS VALORES DOS ITENS EXISTENTES SERÃO ALTERADOS.'+ENTER+;
				//					 'ITEN(S) COM [ '+Upper(AllTrim(RetTitle('UB_DESCICM')))+' ] SERÃO ZERADOS.'+ENTER+ENTER+;
				//					 'DESEJA CONTINUAR ?','aColsReCalc')

				//If !lAlterou
				//	cContCpo 		:=	aContDesc[08]
				//Else
					lAlterou 		:=	.T.
					cContCpo 		:=	M->UA_DESC4
					aContDesc[09] 	:= 	aContDesc[08]
					aContDesc[08] 	:= 	M->UA_DESC4
				//EndIf

			Else
				cContCpo :=	M->UA_DESC4
			EndIf

		EndIf

	EndIf

EndIf




If !lX3VldUser

	If lAlterou

		If _cOpcao == 'TODOS'
			Processa({|| ExecFor() },'Atualizando Item(s)...','Processando...')
		Else
			ExecFor()
		EndIf


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  PREENCHE aProxImp COM O NOVO VALOR 			  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Upper(SubStr(ProcName(2),03)) != 'TLVENT'

			If cCampo == 'UA_CONDPG'
				nPos := 13
			ElseIf cCampo == 'UA_DESC4'
				nPos := 16
			ElseIf cCampo == 'UA_CLIENTE'
				cCampo := AllTrim(cCampo)+AllTrim(M->UA_LOJA)
				nPos := 12
			ElseIf cCampo == 'UA_TABELA'
				nPos := 14
			EndIf

			For _nX := 1 To Len(aProdxImp)
				aProdxImp[_nX][nPos] := IIF(ValType(M->&(cCampo)) != 'N', AllTrim(M->&(cCampo)), M->&(cCampo))
			Next

		EndIf


	ElseIf !lAlterou .And. !Empty(GdFieldGet('UB_PRODUTO', n))
		// 	REFAZER O CALCULO NOVAMENTE... POIS EXISTE NO X3_VALID DOS CAMPOS
		//	UA_TABLEA\UA_CLIENTE\UA_DESC4\UA_CONDPG A ROTINA Tk273Recalc(,,.T.)
		//  QUE ALTERA OS VALORES DOS CAMPOS PARA O VALOR PADRAO ((PRC.TAB-DESCONTO)SEM IMPOSTOS EMBUTIDOS)

		lProcessa := .T.

		If cCampo == 'UA_CLIENTE' .And. !Empty(cOldCpo)
			M->UA_CLIENTE := cOldCpo
			IIF(Empty(Alias()), (SUA->(ChkFile('SUA')), DbSelectArea('SUA')), )
			CheckSX3( "UA_CLIENTE", M->UA_CLIENTE )

		ElseIf cCampo == 'UA_TABELA' .And. !Empty(cOldCpo)
			M->UA_TABELA := cOldCpo
			IIF(Empty(Alias()), (SUA->(ChkFile('SUA')), DbSelectArea('SUA')), )
			CheckSX3( "UA_TABELA", M->UA_TABELA )

		ElseIf cCampo == 'UA_DESC4'
			lProcessa 	:=	IIF(aContDesc[06] == 0, .F., .T.) // NAO EXECUTAR O FOR QUANDO DESC.RD = ZERO
			M->UA_DESC4 := 	cContCpo
			IIF(Empty(Alias()), (SUA->(ChkFile('SUA')), DbSelectArea('SUA')), )
			CheckSX3( "UA_DESC4", M->UA_DESC4 )

		ElseIf cCampo == 'UA_CONDPG' //.And. !Empty(cOldCpo)
			cContCpo	:=	M->UA_CONDPG
			cOldCpo    	:=	''
			lProcessa  	:= .F.
			//IIF(Empty(Alias()), (SUA->(ChkFile('SUA')), DbSelectArea('SUA')), )
			//CheckSX3( "UA_CONDPG", M->UA_CONDPG )
		EndIf

	    // NAO ALTEROU E CAMPO COND.PAGTO NAO PRECISA EXECUTAR
		If lProcessa
			Processa({|| ExecFor() },'Atualizando Item(s)...','Processando...')
	    EndIf

	EndIf

	cContCpo := IIF(!Empty(cOldCpo), cOldCpo, cContCpo)

Else
	cContCpo := lRetorno
EndIf


IIF(ValType(oGetTLV) == 'O', oGetTLV:oBrowse:Refresh(),)
RestArea(aArea)
Return(cContCpo)
**********************************************************************
Static Function ExecFor()
**********************************************************************
Local _ACRESCIMO :=	3	// [3] VALOR DO ACRESCIMO FINANCEIRO DA CONDICAO DE PAGAMENTO
Local _DESPESA	 :=	5	// [5] VALOR TOTAL DA DESPESA


If _cOpcao == 'TODOS'

	ProcRegua(Len(aCols))

	For _nX := 1 To Len(aCols)
		If !Empty(GdFieldGet('UB_PRODUTO',_nX))

			IncProc('Processando... '+AllTrim(Str(_nX))+' de '+AllTrim(Str(Len(aCols)))+' Item(s)')

			nLinha		:=	_nX
			lForcExec 	:= 	.F.
			lCheckDel	:=	.T.
			ExecBlock('PrcReCalc',.F.,.F.,{nLinha, lForcExec, lCheckDel, lOnlyArray})
		EndIf
	Next

Else

	If !Empty(GdFieldGet('UB_PRODUTO', n))
		nLinha 	 	:=	n
		lForcExec 	:= .F.
		lCheckDel	:= .T.
		ExecBlock('PrcReCalc',.F.,.F.,{nLinha, lForcExec, lCheckDel})
	EndIf

EndIf


Return()
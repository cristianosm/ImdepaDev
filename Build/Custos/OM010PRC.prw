#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#DEFINE  ENTER CHR(13)+CHR(10)
#DEFINE MAXSAVERESULT 99999

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³OM010PRC    ³ Autor ³ Fabiano Pereira       ³ Data ³11.03.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Ponto de entrada que retorna o preço de venda de acordo 		 ³±±
±±³          |com a quantidade.												 ³±±
±±³          ³                                                               ³±±
±±³          ³                                                               ³±±
±±³          ³Utilizado nos casos em que o produto NAO esta na Tabela Preco  ³±±
±±³          ³entao busca da Tabela relacionado ao segmento do cliente       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ IMDEPA                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
***********************************************************************
User Function OM010PRC()
***********************************************************************
Local aArea     := GetArea()
Local aAreaSB1  := SB1->(GetArea())
Local aStruDA1  := {}

Local cTabPreco 	:=	ParamIxb[1]		//	Tabela de Preço
Local cProduto  	:=	ParamIxb[2]		//	Produto
Local nQtde 		:=	ParamIxb[3]		//	Qtde
Local cCliente 		:=	ParamIxb[4]		//	Cliente
Local cLoja 		:=	ParamIxb[5]		//	Loja
Local nMoeda 		:=	ParamIxb[6]		//	Moeda
Local dDataVld 		:=	ParamIxb[7]		//	Data de Validade
Local nTipo 		:=	ParamIxb[8]		//	Tipo (1=Preço/2 = Fator de acréscimo ou desconto)
Local lB1_PRV1		:=	.F.


Local cTpOper   := ""
Local cQuery    := ""
Local cAliasDA1 := "DA1"

Local nPrcVen   := 0
Local nResult   := 0
Local nMoedaTab := 1
Local nScan     := 0
Local nY        := 0
Local cMascara  := SuperGetMv("MV_MASCGRD")
Local nTamProd  := Len(SB1->B1_COD)
Local nFator    := 0

Local lUltResult:= .T.
Local lQuery    := .F.
Local nProcessa := 0
Local lGrade    := MaGrade()
Local lGradeReal:= .F.
Local lPrcDA1   := .F.
Local cProdRef  := cProduto
Local lSeekDa1  := .F.
Local lR5      	:= GetRpoRelease("R5")    				// Indica se o release e 11.5
Local lLjcnvB0	:= SuperGetMv("MV_LJCNVB0",,.F.)		// Retorna preço da SB0 na ausência do preço do Produto na DA0 e DA1
Local lPrcHist	:=	.F.


//Em Caso de Transferencias n‹o deve buscar qualquer valor pega preo...
conout("Entrou no OM010PRC")
Return(Nil)
///


//	FABIANO PEREIRA - SOLUTIO
Local nFatorTV		:=	0
Local aProdxQtd		:=	{}
Local lCheckQtdLote	:=	.F.
Private cCampo		:=	SubStr(ReadVar(),04)
If Type('oGetTLV') == 'O'
	If oGetTLV:oBrowse:ColPos == GdFieldPos('UB_PRODUTO')
		lCheckQtdLote	:=	.T.
	EndIf
EndIf



cMvEstado := GetMv("MV_ESTADO")
cMvNorte  := GetMv("MV_NORTE")
nMoeda    := 1
aUltResult:= {}
dDataVld  := dDataBase
nTipo     := 1
lExec     := .T.
lAtuEstado:= .F.
lProspect := .F.


IIF(!ExisteSX6('MV_SEGXTAB'),	CriarSX6('MV_SEGXTAB', 'C','Segmento Cliente x Tabela de Preco', '{{"1","OEM"},{"2","MNT"},{"3","REV"}}' ),)


If Type('aHistTV') == 'A'
	If Len(aHistTV) > 0

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  CALL CENTER                                                  ³
		//³  BUSCA PRECO DO aHistTV QDO ATENDIMENTO VIA HISTORICO         ³
		//³  PARA QUE O PRECO SEJA O MESMO PRATICADO QDO DATA AT < 2 DIAS ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		/*
			Aadd(aHistTV, {	GdFieldGet('UB_ITEM', nI), 		GdFieldGet('UB_PRODUTO', nI),;									//	[01], [02],
							M->UA_DESC1, M->UA_DESC4, M->UA_DESCG,;															//	[03], [04], [05]
							GdFieldGet('UB_TOTDESC', nI), 	GdFieldGet('UB_DESCVEN', nI), 	GdFieldGet('UB_DESCRD', nI),;	//	[06], [07], [08]
							GdFieldGet('UB_ACRE',    nI),	GdFieldGet('UB_VRUNIT',  nI), 	GdFieldGet('UB_PRCTAB', nI) })	//	[09], [10], [11]
		*/

		nDiasHist   :=	GetMv('IM_DIAHIST')
		lRecalAtend	:=	DateDiffDay(Date(), M->UA_EMISSAO) > nDiasHist

		If !lRecalAtend
			nLine	:=	IIF(Type('nLinha')== 'N', nLinha, n)
			nPos 	:=	Ascan(aHistTV, {|X| AllTrim(X[01]) == AllTrim(GdFieldGet('UB_ITEM', nLine)) .And. AllTrim(X[02]) == AllTrim(GdFieldGet('UB_PRODUTO', nLine)) })
			If nPos > 0
				If aHistTV[nPos][11] > 0
					lPrcHist :=	.T.
					nResult	 :=	aHistTV[nPos][11]
				EndIf
			EndIf
	    EndIf


	EndIf
EndIf




If !lPrcHist



	If lAtuEstado
		cMvEstado	:= GetMv("MV_ESTADO")
		cMvNorte	:= GetMv("MV_NORTE")
	Endif

	If lGrade .And.	MatGrdPrrf(@cProdRef,.T.)
		nTamProd	:= Len(cProdRef)
		lGradeReal	:= .T.
		cProdRef	:= Padr(cProdRef,Len(DA1->DA1_REFGRD))
	Endif




		nScan := aScan(aUltResult,{|x| 	x[1] == cTabPreco 	.And.;
										x[2] == cProduto 	.And.;
										x[3] == nQtde 		.And.;
										x[4] == cCliente .And.;
										x[5] == cLoja .And.;
										x[6] == nMoeda .And.;
										x[7] == cFilAnt .And.;
										x[10] == lProspect})

		If nScan == 0

			If !(Empty(cCliente) .And. nQtde == 0 )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se for prospect, pega a informação do mesmo.            ³
				//³Funcionalidade implantada para utilização do televendas,³
				//³já que ele suporta orçamento para prospect.             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lProspect
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Acho o tipo de operacao para busca do preco de venda³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SUS")
					dbSetOrder(1)
					If MsSeek(xFilial("SUS")+cCliente+cLoja)
						Do Case
							Case SUS->US_EST == cMvEstado
								cTpOper := "1"
							Case SUS->US_EST != cMvEstado
								If (SUS->US_EST $ cMvNorte) .And. !(cMvEstado $ cMvNorte)
									cTpOper := "3"
								Else
									cTpOper := "2"
								EndIf
						EndCase
					EndIf
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Acho o tipo de operacao para busca do preco de venda³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SA1")
					dbSetOrder(1)
					If MsSeek(xFilial("SA1")+cCliente+cLoja)
						Do Case
							Case SA1->A1_EST == cMvEstado
								cTpOper := "1"
							Case SA1->A1_EST != cMvEstado
								If (SA1->A1_EST $ cMvNorte) .And. !(cMvEstado $ cMvNorte)
									cTpOper := "3"
								Else
									cTpOper := "2"
								EndIf
						EndCase
					EndIf
				EndIf
			Endif

			dbSelectarea("DA1")
			dbSetOrder(1)

			#IFDEF TOP
				If TcSrvType() <> "AS/400"
					lQuery    := .T.
					cAliasDA1 := GetNextAlias()
					aStruDA1  := DA1->(dbStruct())
					cQuery    := ""

					If lGradeReal
						cQuery += "SELECT * FROM ( "
					EndIf

					cQuery += "SELECT * "
					cQuery += "FROM "+RetSqlName("DA1")+ " DA1 "
					cQuery += "WHERE "
					cQuery += "DA1.DA1_FILIAL = '"+xFilial("DA1")+"' AND "
					cQuery += "DA1.DA1_CODTAB = '"+cTabPreco+"' AND "
					cQuery += "DA1.DA1_CODPRO = '"+cProduto+"' AND "
					cQuery += "DA1.DA1_QTDLOT >= "+Str(nQtde,18,8)+" AND "
					cQuery += "DA1.DA1_ATIVO = '1' AND  "

		    		cQuery += "( DA1.DA1_DATVIG <= '"+DtoS(dDataVld)+ "' OR DA1.DA1_DATVIG = '"+Dtos(Ctod("//"))+ "' ) AND "

					If !(nQtde == 0 .And. Empty(cCliente))
						cQuery += "( DA1.DA1_TPOPER = '"+cTpOper+"' OR DA1.DA1_TPOPER = '4' ) AND "
					Endif

					cQuery += "DA1.D_E_L_E_T_ = ' ' "
					If lGradeReal
						cQuery += " UNION "
						cQuery += "SELECT * "
						cQuery += "FROM "+RetSqlName("DA1")+ " DA1 "
						cQuery += "WHERE "
						cQuery += "DA1.DA1_FILIAL = '"+xFilial("DA1")+"' AND "
						cQuery += "DA1.DA1_CODTAB = '"+cTabPreco+"' AND "
						cQuery += "DA1.DA1_REFGRD = '"+cProdRef+"' AND "
						cQuery += "DA1.DA1_QTDLOT >= "+Str(nQtde,18,8)+" AND "
						cQuery += "DA1.DA1_ATIVO = '1' AND  "
						cQuery += "( DA1.DA1_DATVIG <= '"+DtoS(dDataVld)+ "' OR DA1.DA1_DATVIG = '"+Dtos(Ctod("//"))+ "' ) AND "

						If !(nQtde == 0 .And. Empty(cCliente))
							cQuery += "( DA1.DA1_TPOPER = '"+cTpOper+"' OR DA1.DA1_TPOPER = '4' ) AND "
						Endif

						cQuery += "DA1.D_E_L_E_T_ = ' ' "
						cQuery += "AND NOT EXISTS ( "
						cQuery += "SELECT DA1B.DA1_CODPRO  "
						cQuery += "FROM "+RetSqlName("DA1")+ " DA1B "
						cQuery += "WHERE "
						cQuery += "DA1B.DA1_FILIAL = '"+xFilial("DA1")+"' AND "
						cQuery += "DA1B.DA1_CODTAB = '"+cTabPreco+"' AND "
						cQuery += "DA1B.DA1_CODPRO = '"+cProduto+"' AND "
						cQuery += "DA1B.DA1_QTDLOT >= "+Str(nQtde,18,8)+" AND "
						cQuery += "DA1B.DA1_ATIVO = '1' AND  "
						cQuery += "( DA1B.DA1_DATVIG <= '"+DtoS(dDataVld)+ "' OR DA1B.DA1_DATVIG = '"+Dtos(Ctod("//"))+ "' ) AND "

						If !(nQtde == 0 .And. Empty(cCliente))
							cQuery += "( DA1B.DA1_TPOPER = '"+cTpOper+"' OR DA1B.DA1_TPOPER = '4' ) AND "
						Endif
						cQuery += "DA1B.D_E_L_E_T_ = ' ' ) "


						cQuery += " UNION "
						cQuery += "SELECT * "
						cQuery += "FROM "+RetSqlName("DA1")+ " DA1 "
						cQuery += "WHERE "
						cQuery += "DA1.DA1_FILIAL = '"+xFilial("DA1")+"' AND "
						cQuery += "DA1.DA1_CODTAB = '"+cTabPreco+"' AND "
						cQuery += "DA1.DA1_CODPRO LIKE '"+cProduto+"%' AND "
						cQuery += "DA1.DA1_QTDLOT >= "+Str(nQtde,18,8)+" AND "
						cQuery += "DA1.DA1_ATIVO = '1' AND  "
						cQuery += "( DA1.DA1_DATVIG <= '"+DtoS(dDataVld)+ "' OR DA1.DA1_DATVIG = '"+Dtos(Ctod("//"))+ "' ) AND "

						If !(nQtde == 0 .And. Empty(cCliente))
							cQuery += "( DA1.DA1_TPOPER = '"+cTpOper+"' OR DA1.DA1_TPOPER = '4' ) AND "
						Endif

						cQuery += "DA1.D_E_L_E_T_ = ' ' "
						cQuery += "AND NOT EXISTS ( "
						cQuery += "SELECT DA1C.DA1_CODPRO  "
						cQuery += "FROM "+RetSqlName("DA1")+ " DA1C "
						cQuery += "WHERE "
						cQuery += "DA1C.DA1_FILIAL = '"+xFilial("DA1")+"' AND "
						cQuery += "DA1C.DA1_CODTAB = '"+cTabPreco+"' AND "
						cQuery += "DA1C.DA1_REFGRD = '"+cProdRef+"' AND "
						cQuery += "DA1C.DA1_QTDLOT >= "+Str(nQtde,18,8)+" AND "
						cQuery += "DA1C.DA1_ATIVO = '1' AND  "
						cQuery += "( DA1C.DA1_DATVIG <= '"+DtoS(dDataVld)+ "' OR DA1C.DA1_DATVIG = '"+Dtos(Ctod("//"))+ "' ) AND "

						If !(nQtde == 0 .And. Empty(cCliente))
							cQuery += "( DA1C.DA1_TPOPER = '"+cTpOper+"' OR DA1C.DA1_TPOPER = '4' ) AND "
						Endif
						cQuery += "DA1C.D_E_L_E_T_ = ' ' ) ) QRYDAI "

					Endif

					cQuery += "ORDER BY "+SqlOrder(DA1->(IndexKey()))

					//MemoWrit(GetTempPath()+'QUERY_OM010PRC_1.TXT', cQuery )
					cQuery := ChangeQuery(cQuery)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDA1,.T.,.T.)

					If (cAliasDA1)->(!Eof())
						nProcessa := 1
					Else
						SB1->(dbSetOrder(1))
						If SB1->(MsSeek(xFilial("SB1")+cProduto))
							cGrupo := SB1->B1_GRUPO
							If !Empty(cGrupo)
								(cAliasDA1)->(dbCloseArea())
								cAliasDA1 := GetNextAlias()

								cQuery := "SELECT * "
								cQuery += "FROM "+RetSqlName("DA1")+ " DA1 "
								cQuery += "WHERE "
								cQuery += "DA1_FILIAL = '"+xFilial("DA1")+"' AND "
								cQuery += "DA1_CODTAB = '"+cTabPreco+"' AND "
								If cPaisLoc == "BRA"
									cQuery += "DA1_GRUPO = '"+cGrupo+"' AND "
								EndIf
								cQuery += "DA1_QTDLOT >= "+Str(nQtde,18,8)+" AND "
								cQuery += "DA1_ATIVO = '1' AND  "
					    		cQuery += "( DA1_DATVIG <= '"+DtoS(dDataVld)+ "' OR DA1_DATVIG = '"+Dtos(Ctod("//"))+ "' ) AND "
								If !(nQtde == 0 .And. Empty(cCliente))
									cQuery += "( DA1_TPOPER = '"+cTpOper+"' OR DA1_TPOPER = '4' ) AND "
								Endif
								cQuery += "DA1.D_E_L_E_T_ = ' ' "
								cQuery += "ORDER BY "+SqlOrder(DA1->(IndexKey()))

								MemoWrit(GetTempPath()+'QUERY_OM010PRC_2.TXT', cQuery )
								cQuery := ChangeQuery(cQuery)

								dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDA1,.T.,.T.)

								If (cAliasDA1)->(!Eof())
									nProcessa := 2
								EndIf
							EndIf
						EndIf
					Endif
					For nY := 1 To Len(aStruDA1)
						If aStruDA1[nY][2]<>"C"
							TcSetField(cAliasDA1,aStruDA1[nY][1],aStruDA1[nY][2],aStruDA1[nY][3],aStruDA1[nY][4])
						EndIf
					Next nY
				Else
			#ENDIF
					lSeekDA1:= aPesqDA1(cTabPreco,cProduto)
					If lSeekDA1
						nProcessa := 1
					Else
						SB1->(dbSetOrder(1))
						If SB1->(MsSeek(xFilial("SB1")+cProduto))
							cGrupo := SB1->B1_GRUPO
							If !Empty(cGrupo)
								dbSelectarea("DA1")
								dbSetOrder(4)
								If MsSeek(xFilial("DA1")+ cTabPreco + cGrupo)
									nProcessa := 2
								EndIf
							EndIF
						Endif
					EndIf
			#IFDEF TOP
				Endif
			#ENDIF




			If nProcessa > 0

				If nQtde == 0 .And. Empty(cCliente)
					nPrcVen   := (cAliasDA1)->DA1_PRCVEN
					nMoedaTab := (cAliasDA1)->DA1_MOEDA
					nFator    := (cAliasDA1)->DA1_PERDES

					lPrcDA1   := .T.
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco o preco e analiso a qtde de acordo com a faixa³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea(cAliasDA1)
					While (cAliasDA1)->(!Eof()) .And. (cAliasDA1)->DA1_FILIAL == xFilial("DA1") .And.;
										(cAliasDA1)->DA1_CODTAB == cTabPreco .And.;
										If(nProcessa==1,Left((cAliasDA1)->DA1_CODPRO,nTamProd)== cProduto .Or. (cAliasDA1)->DA1_CODPRO==cProduto .Or. (cAliasDA1)->DA1_REFGRD == cProdRef,(cAliasDA1)->DA1_GRUPO==cGrupo)

						If nQtde <= (cAliasDA1)->DA1_QTDLOT .And. (cAliasDA1)->DA1_ATIVO == "1"

							If Empty((cAliasDA1)->DA1_ESTADO) .And. ((cAliasDA1)->DA1_TPOPER == cTpOper .Or. (cAliasDA1)->DA1_TPOPER == "4")

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Verifica a vigencia do item                                   ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

								nQtdLote := (cAliasDA1)->DA1_QTDLOT
								nPrcVen  := (cAliasDA1)->DA1_PRCVEN 	//	FABIANO PEREIRA - SOLUTIO

								While (cAliasDA1)->(!Eof()) .And. (cAliasDA1)->DA1_FILIAL == xFilial("DA1") .And.;
																	(cAliasDA1)->DA1_CODTAB == cTabPreco .And.;
																	If(nProcessa==1,Left((cAliasDA1)->DA1_CODPRO,nTamProd)== cProduto .Or. (cAliasDA1)->DA1_CODPRO==cProduto .Or. (cAliasDA1)->DA1_REFGRD == cProdRef ,(cAliasDA1)->DA1_GRUPO==cGrupo) .And.;
																	(cAliasDA1)->DA1_QTDLOT == nQtdLote .And.;
																	(cAliasDA1)->DA1_DATVIG <= dDataVld

									If nQtde <= (cAliasDA1)->DA1_QTDLOT .And. (cAliasDA1)->DA1_ATIVO == "1" .And.;
										((!Empty((cAliasDA1)->DA1_ESTADO) .And. ( If(lProspect, SUS->US_EST, SA1->A1_EST) == (cAliasDA1)->DA1_ESTADO )).Or.(Empty((cAliasDA1)->DA1_ESTADO) .And. ((cAliasDA1)->DA1_TPOPER == cTpOper .Or. (cAliasDA1)->DA1_TPOPER == "4")))

										nPrcVen   := (cAliasDA1)->DA1_PRCVEN
										nMoedaTab := (cAliasDA1)->DA1_MOEDA
										nFator    := (cAliasDA1)->DA1_PERDES

										lPrcDA1   := .T.

									EndIf

									dbSelectArea(cAliasDA1)
									dbSkip()


									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//|  FABIANO PEREIRA - SOLUTIO								  |
									//³  GUARDA INFORMACOES PARA APRESENTAR PARA USUARIO SOBRE    ³
									//³  PRODUTO COM QUANTIDADES DIFERENTES COM PRECOS DIFERENTES ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If lCheckQtdLote .And. lPrcDA1
										Aadd(aProdxQtd, { nPrcVen, nQtdLote })
										nQtdLote := (cAliasDA1)->DA1_QTDLOT
									EndIf

								Enddo


								If lPrcDA1
									Exit
								Endif



							ElseIf !Empty((cAliasDA1)->DA1_ESTADO) .And. ( If(lProspect, SUS->US_EST, SA1->A1_EST) == (cAliasDA1)->DA1_ESTADO )

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Verifica a vigencia do item                                   ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

								nQtdLote := (cAliasDA1)->DA1_QTDLOT
								nPrcVen  := (cAliasDA1)->DA1_PRCVEN 	//	FABIANO PEREIRA - SOLUTIO

								While (cAliasDA1)->(!Eof()) .And. (cAliasDA1)->DA1_FILIAL == xFilial("DA1") .And.;
																		(cAliasDA1)->DA1_CODTAB == cTabPreco .And.;
																		If(nProcessa==1,Left((cAliasDA1)->DA1_CODPRO,nTamProd)== cProduto .Or. (cAliasDA1)->DA1_CODPRO==cProduto .Or. (cAliasDA1)->DA1_REFGRD == cProdRef,(cAliasDA1)->DA1_GRUPO==cGrupo) .And.;
																		(cAliasDA1)->DA1_QTDLOT == nQtdLote .And.;
																		(cAliasDA1)->DA1_DATVIG <= dDataVld
									If nQtde <= (cAliasDA1)->DA1_QTDLOT .And. (cAliasDA1)->DA1_ATIVO == "1" .And.;
										((!Empty((cAliasDA1)->DA1_ESTADO) .And. ( If(lProspect, SUS->US_EST, SA1->A1_EST) == (cAliasDA1)->DA1_ESTADO )).Or.(Empty((cAliasDA1)->DA1_ESTADO) .And. ((cAliasDA1)->DA1_TPOPER == cTpOper .Or. (cAliasDA1)->DA1_TPOPER == "4")))


										nPrcVen   := (cAliasDA1)->DA1_PRCVEN
										nMoedaTab := (cAliasDA1)->DA1_MOEDA
										nFator    := (cAliasDA1)->DA1_PERDES

										lPrcDA1   := .T.

									Endif

									dbSelectArea(cAliasDA1)
									dbSkip()

									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//|  FABIANO PEREIRA - SOLUTIO								  |
									//³  GUARDA INFORMACOES PARA APRESENTAR PARA USUARIO SOBRE    ³
									//³  PRODUTO COM QUANTIDADES DIFERENTES COM PRECOS DIFERENTES ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If lCheckQtdLote .And. lPrcDA1
										Aadd(aProdxQtd, { nPrcVen, nQtdLote })
										nQtdLote := (cAliasDA1)->DA1_QTDLOT
									EndIf


								Enddo

								If lPrcDA1
									Exit
								Endif

							EndIf
						EndIf

						dbSelectArea(cAliasDA1)
						dbSkip()

					Enddo


					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Somente atualiza com o SB1 caso nao tenha achado nenhuma tabela    ³
					//³caso contrario retornara o preco zerado                            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					If nTipo == 1
						If nPrcVen == 0 .And. !lPrcDA1
							If lLjcnvB0 .AND. nModulo == 12
								DbSelectArea("SB0")
								DbSetOrder(1)
								If DbSeek(xFilial("SB0")+cProduto)
									nPrcVen := SB0->B0_PRV1
								EndIf
							// No FrontLoja, é obrigatório ler o SBI
							ElseIf lR5 .AND. nModulo == 23
								DbSelectArea("SBI")
								DbSetOrder(1)
								If DbSeek(xFilial("SBI")+cProduto)
									nPrcVen := SBI->BI_PRV
								EndIf
							Else
								DbSelectArea("SB1")
								DbSetOrder(1)
								If MsSeek(xFilial("SB1")+cProduto)
									// nPrcVen := SB1->B1_PRV1
									lB1_PRV1:= .T.
								EndIf
							EndIf
							lUltResult := .F.
						Endif
					Endif

				EndIf

			Else

				If nTipo == 1
					If nPrcVen == 0 .And. !lPrcDA1
						If lLjcnvB0 .AND. lR5 .AND. nModulo == 12
							DbSelectArea("SB0")
							DbSetOrder(1)
							If DbSeek(xFilial("SB0")+cProduto)
								nPrcVen := SB0->B0_PRV1
							EndIf
						// No FrontLoja, é obrigatório ler o SBI
						ElseIf lR5 .AND. nModulo == 23
							DbSelectArea("SBI")
							DbSetOrder(1)
							If DbSeek(xFilial("SBI")+cProduto)
								nPrcVen := SBI->BI_PRV
							EndIf
						Else
							DbSelectArea("SB1")
							DbSetOrder(1)
							If MsSeek(xFilial("SB1")+cProduto)
								// nPrcVen := SB1->B1_PRV1
								lB1_PRV1:= .T.
							EndIf
						EndIf
				EndIf
				Endif
				lUltResult := .F.
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o tipo for para trazer preco converte para a moeda    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nFatorTV  	:= nFator
			nFator 		:= Iif( nFator == 0, 1, nFator )

			If nTipo == 1
				nResult := xMoeda(nPrcVen,nMoedaTab,nMoeda,,TamSx3("D2_PRCVEN")[2])
			Else
				nResult	:= nFator
			Endif


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Guarda os ultimos resultados                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lUltResult
				//					  1		   2 	   3	 4		 5   	6	    7       8       9      10
				aadd(aUltResult,{cTabPreco,cProduto,nQtde,cCliente,cLoja,nMoeda,cFilAnt,nResult,nFator,lProspect})
				If Len(aUltResult) > MAXSAVERESULT
					aUltResult := aDel(aUltResult,1)
					aUltResult := aSize(aUltResult,MAXSAVERESULT)
				EndIf
			EndIf
		Else

			If nTipo == 1
				nResult := aUltResult[nScan][8]
			Else
				nResult := aUltResult[nScan][9]
			Endif

		EndIf


	If lQuery
		dbSelectArea(cAliasDA1)
		dbCloseArea()
		dbSelectArea("DA1")
	Endif




	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|  FABIANO PEREIRA - SOLUTIO						  |
	//³  PESQUISA NA TABELA DE PRECO DO SEGMENTO.         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nResult == 0 .Or. lB1_PRV1

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  CASO PRODUTO NAO EXISTA NA TABELA DE PRECO AUTAL ³
		//³  PESQUISA NA TABELA DE PRECO DO SEGMENTO.         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If AllTrim(SA1->A1_COD+SA1->A1_LOJA) == AllTrim(cCliente+cLoja)
			cGrpSeg		:= 	SA1->A1_GRPSEG
		Else
			DbselectArea("SA1");DbSetOrder(1);DbGoTop()
			If DbSeek(xFilial("SA1")+cCliente+cLoja, .F.)
				cGrpSeg		:= 	SA1->A1_GRPSEG
			EndIf
		EndIf


															//	  [01] [02]   [02] [02]   [03] [02]
		aTabela := &(GetMv('MV_SEGXTAB'))					//	{{"1","OEM"},{"2","MNT"},{"3","REV"}}

		nPosTab := Ascan(aTabela, {|X| X[1] == Right(cGrpSeg,1) })
		If nPosTab > 0

			If cTabPreco	!= aTabela[nPosTab][02]
				cTabPreco	:= 	aTabela[nPosTab][02]
				nResult := ExecBlock("OM010PRC",.F.,.F.,{cTabPreco,cProduto,nQtde,cCliente,cLoja,nMoeda,dDataVld,nTipo})
										//					  1		   2 	   3	    4	   5     6	     7      8
			EndIf

		EndIf

	EndIf



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|	 FABIANO PEREIRA - SOLUTIO								  |
	//³  APRESENTA PARA USUARIO INFORMACOES SOBRE    			  ³
	//³  PRODUTO COM PRECOS DIFERENTES PARA  QUANT DIFERENTES 	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aProdxQtd) > 1
		cMensagem := ''
		// Aadd(aProdxQtd, { nPrcVen, nQtdLote })
		For nX:=1 To Len(aProdxQtd)

			If aProdxQtd[nX][2] != 999999.99
				cMensagem += 'ATÉ'+Space(3)+AllTrim(Transform(aProdxQtd[nX][02], '@E 999,999.99'))+'  '+AllTrim(GdFieldGet('UB_UM',n))+'   PREÇO R$ '+AllTrim(Transform(aProdxQtd[nX][01], '@E 999,999,999.99'))+ENTER
			Else
				cMensagem += 'ACIMA  PREÇO R$ '+AllTrim(Transform(aProdxQtd[nX][01], '@E 999,999,999.99'))+ENTER
			EndIf
		Next

		MsgInfo(ENTER+'PRODUTO '+AllTrim(GdFieldGet('UB_PRODUTO', n))+' - '+AllTrim(GdFieldGet('UB_DESCRI ', n))+ENTER+;
				'PREÇOS DIFERENTES PARA QUANTIDADES DIFERENTES.'+ENTER+ENTER+;
				cMensagem)

	EndIf



EndIf



If Type('oGetTLV') == 'O'

	If nScan == 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  aRegDesc  FATOR	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nFatorTV > 0
			nPos := Ascan(aRegDesc,{|X| X[1] == 'Fator' .And. X[2] == StrZero(n, TamSx3('UB_ITEM')[1])  })
			If nPos == 0
				Aadd(aRegDesc, {'Fator', StrZero(n, TamSx3('UB_ITEM')[1]), '', nFatorTV, '' })
			Else
				aRegDesc[nPos][04] := nFatorTV
			EndIf
        Else
			ExcluiRD('Fator')
		EndIf
	EndIf


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ GRAVA TABELA DE PRECO | CLIENTE \ SEGMENTO	|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    GdFieldPut('UB_TABPRC', cTabPreco, n)



EndIf

RestArea(aAreaSB1)
RestArea(aArea)
Return(nResult)
**********************************************************************
Static Function ExcluiRD(cPesq)
**********************************************************************
// Aadd(aRegDesc, {'Desc.RD - Cabec', '', cCodRegra, M->UA_DESC4 })
// Aadd(aRegDesc, {'Item RD', StrZero(n, TamSx3('UB_ITEM')[1]), cCodRegra, nDesconto })

nPos := Ascan(aRegDesc,{|X| X[1] == cPesq  })
If nPos > 0

	aCopiaRD := {}
	For nX := 1 To Len(aRegDesc)
		If aRegDesc[nX][01] != cPesq
			Aadd(aCopiaRD, aRegDesc[nX])
		EndIf
	Next

	aRegDesc := aCopiaRD

EndIf

Return()
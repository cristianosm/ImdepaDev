/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FA440Comis³ Autor ³ Eduardo Riera         ³ Data ³ 16/12/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua o calculo das bases da comissao de um determinado   ³±±
±±³          ³ t¡tulo financeiro.                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 : Numero do Registro do SE1 ( Contas a Receber )     ³±±
±±³			 ³ ExpL2 : .T. : Atualiza baseS da comissao do SE1.			  ³±±
±±³			 ³ ExpL3 : .F. : Retorna bases do SE1 ou (.T.) recalcula(Defa)³±±
±±³			 ³ ExpN4 : Numero do Registro do SD2 para Devol.de Vendas     ³±±
±±³			 ³ ExpL5 : .F. : Nao calcula array de bases por parcela da NF ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Retorna um Array com as bases da comissao. na seguinte     ³±±
±±³          ³ estrutura [C¢digo do Vendedor]                             ³±±
±±³          ³           [Base da Comissao]                               ³±±
±±³          ³           [Base na Emissao ]                               ³±±
±±³          ³           [Base na Baixa   ]                               ³±±
±±³          ³           [Vlr  na Emissao ]                               ³±±
±±³          ³           [Vlr  na Baixa   ]                               ³±±
±±³			 ³ 			 [% da Comissao/Se "Zero" diversos %'s]           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Fina440                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa440Comis(nRegistro,lGrava,lRefaz,nRegDevol,lCalcParc,nRecnoOrig)

	Local aArea 	 := GetArea()
	Local aAreaSE4  := {}
	Local aAreaSF2  := {}
	Local aAreaSF4  := {}
	Local aAreaSD2  := {}
	Local aAreaSA3  := {}
	Local aAreaSD1  := {}
	Local aAreaSF1  := {}
	Local aAreaSE1  := {}
	Local aAux      := {}
	Local aSD2Vend  := {} // Array c/ as Bases dos Vend. por item de nota
	Local aBaseNCC  := {} // Array c/ as Bases dos Vend.
	Local aBaseSE1  := {} // Array c/ as Bases dos Vend. do Titulo em questao
	Local aBaseSD1  := {} // Array c/ as Bases dos Vend. do Item da NFE
	Local aRelImp	:= MaFisRelImp("MT100",{ "SD2" })
	Local nVend     := fa440CntVen() // Numero M ximo de Vendedores
	Local nCntFor   := 0
	Local nMaxFor   := 0
	Local nBaseSe1  := 0 // Base da Comissao
	Local nBaseDif  := 0
	Local nPerComis := 0 // Percentual da Comissao
	Local nBaseEmis := 0 // Base da Comissao na Emissao
	Local nBaseBaix := 0 // Base da Comissao na Baixa
	Local nVlrEmis  := 0 // Valor da Comissao na Emissao
	Local nVlrBaix  := 0 // Valor da Comissao na Baixa
	Local nFrete    := 0 // Valor do Frete
	Local nIcmFrete := 0 // Valor do Icms sobre frete
	Local nTotal    := 0 // Total das mercadorias pelo item
	Local nRatFrete := 0 // Valor rateado do Frete por item
	Local nRatIcmFre:= 0 // Valor rateado do icms s/ frete por item
	Local nSF2IcmRet:= 0 // Valor do Icms Retido
	Local nVlrFat   := 0 // Valor faturado
	Local nVlrTit   := 0 // valor do titulo em questao
	Local nProp     := 0
	Local nPos      := 0
	Local cVend     := "1"
	Local cVendedor := ""
	Local cSerie    := ""
	Local cPrefixo  := "" // Prefixo da Duplicata
	Local lContinua := .T.
	Local nDecimal  := TamSX3("E1_BASCOM1")[2] // N@ de decimais considerados no calculo
	Local cFilialSD1:= ""
	Local cFilialSD2:= ""
	Local cFilialSE1:= ""
	Local cFilialSE2:= ""
	Local cFilialSE4:= ""
	Local cFilialSF1:= ""
	Local cFilialSF2:= ""
	Local cFilialSF4:= ""
	Local cFieldPis := ""
	Local cFieldCof := ""
	Local cCposSD2  := "D2_FILIAL#D2_DOC#D2_SERIE#D2_CLIENTE#D2_LOJA#D2_TES#D2_ICMFRET#D2_TOTAL#D2_VALICM#D2_VALIPI#D2_IPI#D2_ICMSRET#D2_VALACRS#D2_ITEM#D2_COD#D2_DESCICM"
	Local lQuery    := .F.
	Local cAliasSD1 := "SD1"
	Local cAliasSD2 := "SD2"
	Local cAliasDev := "SD1"
	Local cAliasSF4 := "SF4"
	Local cImp		:= "N"	 // Se A3_COMIMP nao existe, cImp = N, senao pega valor em A3_COMIMP
	Local aImp		:= {}  // Recebe o array de TesImpInf
	Local lPEPerCom := ExistBlock("FIN440PE")
	Local cMvComisCC:= Upper( SuperGetMv("MV_COMISCC",,"S") )		// Verifica se deduz ou nao a taxa da adm. financeira p/ LOJA
	Local aSemNota	:=	{}
	Local cEspSes	:= " "
	Local nTamParc  := TamSx3("E1_PARCELA")[1]
	Local cPrimParc := " "
	Local nAlEmissao:= 0
	Local nAlBaixa  := 0
	Local nRatINSS  := 0
	Local nRatIRRF  := 0
	Local nX
	Local nRatCOF	:= 0
	Local nRatCSL	:= 0
	Local nRatPIS   := 0
	Local nScanPis  := 0
	Local nScanCof  := 0
	Local nPosFldPis:= 0
	Local nPosFldCof:= 0
	Local nBaseCC	:= 0											// Base de Comissao, caso seja CC ou CD - LOJA
	Local nImp      := 0
	Local nDescImp  := 0
	Local nFreteAux := 0
	Local aVendPed  := {}
	Local lRecIRRF  := .F.
	Local lMata460  := Alltrim(SE1->E1_ORIGEM) == "MATA460"
//Controla o Pis Cofins e Csll na baixa  (1-Retem PCC na Baixa ou 2-Retem PCC na Emissão(default) )
	Local lPccBxCr	:= If (FindFunction("FPccBxCr"),FPccBxCr(),.F.)
	Local nPis 		:= 0
	Local nCofins 	:= 0
	Local nCsll 	:= 0
	#IFDEF TOP
		Local cQuery    := ""
	#ENDIF
	Static aStruSD1
	Static aStruSD2
	Static aStruSF4

	Default lCalcParc := .T.
	Default nRecnoOrig := nRegistro

// Abertura dos arquivos pois no Loja alguns nao sao utilizados

	dbSelectArea("SE4")
	aAreaSE4  := SE4->(GetArea())
	cFilialSE4:= xFilial("SE4")

	dbSelectArea("SF2")
	aAreaSF2  := SF2->(GetArea())
	cFilialSF2:= xFilial("SF2")

	dbSelectArea("SF4")
	aAreaSF4  := SF4->(GetArea())
	cFilialSF4:= xFilial("SF4")

	dbSelectArea("SD2")
	aAreaSD2  := SD2->(GetArea())
	cFilialSD2:= xFilial("SD2")

	dbSelectArea("SA3")
	aAreaSA3  := SA3->(GetArea())

	dbSelectArea("SD1")
	aAreaSD1  := SD1->(GetArea())
	cFilialSD1:= xFilial("SD1")

	dbSelectArea("SF1")
	aAreaSF1  := SF1->(GetArea())
	cFilialSF1:= xFilial("SF1")

	dbSelectArea("SE1")
	aAreaSE1  := SE1->(GetArea())
	cFilialSE1:= xFilial("SE1")

	dbSelectArea("SE2")
	cFilialSE2:= xFilial("SE2")

	RestArea(aArea)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se é a primeira parcela de uma fatura               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTamParc == 1
		cPrimParc := "1A "
	ElseIf nTamparc == 2
		cPrimParc := SuperGetMv("MV_1DUP")+Space(2-Len(GetMv("MV_1DUP")))
		cPrimParc += "#1 #A #  #01"
	Else
		cPrimParc := SuperGetMv("MV_1DUP")+Space(3-Len(GetMv("MV_1DUP")))
		cPrimParc += "#1  #A  #   #001"
	Endif

	if cPaisLoc<>"BRA"
		cEspSes	:= GetSesNew("NDC","1")
	Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento de Parametros Default da funcao                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRefaz := If( lRefaz == Nil , .T. , lRefaz )
	lGrava := If( lGrava == Nil , .T. , lGrava )
	If ( aStruSD1 == Nil )
		aStruSD1 := {}
		dbSelectArea("SD1")
		aAux := dbStruct()
		For nCntFor := 1 To Len(aAux)
			If ( FieldName(nCntFor)$"D1_FILIAL#D1_DOC#D1_SERIE#D1_FORNECE#D1_LOJA" .Or.;
					FieldName(nCntFor)$"D1_NFORI#D1_SERIORI#D1_COD#D1_ITEMORI#D1_TOTAL#D1_VALDESC#D1_ITEM" )
				aadd(aStruSD1,{aAux[nCntFor,1],aAux[nCntFor,2],aAux[nCntFor,3],aAux[nCntFor,4]})
			EndIf
		Next nCntFor
	EndIf
	If ( aStruSD2 == Nil )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se os campos que gravam o valor do PIS/COFINS para  ³
	//³ abater da base conforme configurado                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If !Empty( nScanPis := aScan(aRelImp,{|x| x[1]=="SD2" .And. x[3]=="IT_VALPS2"} ) )
			cFieldPis  := aRelImp[nScanPis,2]
		EndIf

		If !Empty( nScanCof := aScan(aRelImp,{|x| x[1]=="SD2" .And. x[3]=="IT_VALCF2"} ) )
			cFieldCof := aRelImp[nScanCof,2]
		EndIf

		aStruSD2 := {}
		dbSelectArea("SD2")
		aAux := dbStruct()
		For nCntFor := 1 To Len(aAux)
			If ( FieldName(nCntFor)$cCposSD2 .Or.;
					FieldName(nCntFor)$cFieldPis .Or.;
					FieldName(nCntFor)$cFieldCof .Or.;
					"D2_COMIS"$FieldName(nCntFor) )
				aadd(aStruSD2,{aAux[nCntFor,1],aAux[nCntFor,2],aAux[nCntFor,3],aAux[nCntFor,4]})
			EndIf
		Next nCntFor
	EndIf
	If ( aStruSF4 == Nil )
		aStruSF4 := {}
		dbSelectArea("SF4")
		aAux := dbStruct()
		For nCntFor := 1 To Len(aAux)
			If ( FieldName(nCntFor)$"F4_DUPLIC#F4_INCIDE#F4_IPIFRET#F4_INCSOL#F4_ISS" )
				aadd(aStruSF4,{aAux[nCntFor,1],aAux[nCntFor,2],aAux[nCntFor,3],aAux[nCntFor,4]})
			EndIf
		Next nCntFor
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no Registro do SE1 a ser calculado                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SE1")
	MsGoto(nRegistro)
//Verifica se o cliente e responsavel pelo recolhimento do IR ou nao.
	If cPaisLoc == "BRA"
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA))) .And. SA1->A1_RECIRRF == "1"
			lRecIRRF := .T.
		Endif
	Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o titulo foi gerado pelo faturamento e for neces-³
//³ sario recalcular suas bases.                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( SE1->E1_TIPO $ MVNOTAFIS+cEspSes )
		For nCntFor := 1 To nVend
			cVendedor := SE1->(FieldGet(SE1->(FieldPos("E1_VEND"+cVend))))
			nPerComis := SE1->(FieldGet(SE1->(FieldPos("E1_COMIS"+cVend))))
			If ( nPerComis == 0 .And. !Empty(cVendedor) )
				lRefaz := .T.
				Exit
			EndIf
			cVend := Soma1(cVend,1)
		Next nCntFor
	ElseIf	cPaisLoc <>"BRA" .and.( SE1->E1_TIPO $ MV_CRNEG+MVRECANT)
		lRefaz := .T.
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona Registros                                          ³
//³ Aqui se faz necessaria a cria‡Æo de tratamento de filial de  ³
//³ origem para quando se tem SE1 compartilhado e SF2, SE4 ou SD2³
//³ exclusivos                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SE1->(FieldPos("E1_MSFIL")) > 0
		If !Empty(SE1->E1_MSFIL) .and. !(Empty(cFilialSf1))
			cFilialSf1 := SE1->E1_MSFIL
		Endif
		If !Empty(SE1->E1_MSFIL) .and. !(Empty(cFilialSf2))
			cFilialSf2 := SE1->E1_MSFIL
		Endif
		If !Empty(SE1->E1_MSFIL) .and. !(Empty(cFilialSf4))
			cFilialSf4 := SE1->E1_MSFIL
		Endif
		If !Empty(SE1->E1_MSFIL) .and. !(Empty(cFilialSe1))
			cFilialSe1 := SE1->E1_MSFIL
		Endif
		If !Empty(SE1->E1_MSFIL) .and. !(Empty(cFilialSe2))
			cFilialSe2 := SE1->E1_MSFIL
		Endif
		If !Empty(SE1->E1_MSFIL) .and. !(Empty(cFilialSe4))
			cFilialSe4 := SE1->E1_MSFIL
		Endif
		If !Empty(SE1->E1_MSFIL) .and. !(Empty(cFilialSd1))
			cFilialSd1 := SE1->E1_MSFIL
		Endif
		If !Empty(SE1->E1_MSFIL) .and. !(Empty(cFilialSd2))
			cFilialSd2 := SE1->E1_MSFIL
		Endif
	Else
		If SE1->(FieldPos("E1_FILORIG")) > 0
			If !Empty(SE1->E1_FILORIG) .and. !(Empty(cFilialSf1))
				cFilialSf1 := SE1->E1_FILORIG
			Endif
			If !Empty(SE1->E1_FILORIG) .and. !(Empty(cFilialSf2))
				cFilialSf2 := SE1->E1_FILORIG
			Endif
			If !Empty(SE1->E1_FILORIG) .and. !(Empty(cFilialSe1))
				cFilialSe1 := SE1->E1_FILORIG
			Endif
			If !Empty(SE1->E1_FILORIG) .and. !(Empty(cFilialSe2))
				cFilialSe2 := SE1->E1_FILORIG
			Endif
			If !Empty(SE1->E1_FILORIG) .and. !(Empty(cFilialSe4))
				cFilialSe4 := SE1->E1_FILORIG
			Endif
			If !Empty(SE1->E1_FILORIG) .and. !(Empty(cFilialSd1))
				cFilialSd1 := SE1->E1_FILORIG
			Endif
			If !Empty(SE1->E1_FILORIG) .and. !(Empty(cFilialSd2))
				cFilialSd2 := SE1->E1_FILORIG
			Endif
			If !Empty(SE1->E1_FILORIG) .and. !(Empty(cFilialSf4))
				cFilialSf4 := SE1->E1_FILORIG
			Endif
		Endif
	EndIf
	If ( SE1->E1_TIPO $ MVNOTAFIS+cEspSes .And. lRefaz)
		If Year(SE1->E1_EMISSAO)<2001
			cSerie := If(Empty(SE1->E1_SERIE),SE1->E1_PREFIXO,SE1->E1_SERIE)
		Else
			cSerie := SE1->E1_SERIE
		EndIf
		dbSelectArea("SF2")
		dbSetOrder(1)
		If (!MsSeek(cFilialSF2+SE1->E1_NUM+cSerie+SE1->E1_CLIENTE+SE1->E1_LOJA,.F.))
			lContinua := .F.
		EndIf
		dbSelectArea("SE4")
		dbSetOrder(1)
		If (!MsSeek(cFilialSE4+SF2->F2_COND))
			lContinua := .F.
		EndIf
		dbSelectArea("SD2")
		dbSetOrder(3)
		#IFDEF TOP
			If ( TcSrvType()!="AS/400" )
				SD2->(dbCommit())
				lQuery := .T.
				cAliasSD2 := "FA440COMIS"
				cAliasSF4 := "FA440COMIS"
				cQuery := ""
				For nCntFor := 1 To Len(aStruSD2)
					cQuery += ","+aStruSD2[nCntFor][1]
				Next nCntFor
				For nCntFor := 1 To Len(aStruSF4)
					cQuery += ","+aStruSF4[nCntFor][1]
				Next nCntFor
				cQuery := "SELECT SD2.R_E_C_N_O_ SD2RECNO,"+SubStr(cQuery,2)
				cQuery += "FROM "+RetSqlName("SD2")+" SD2,"+RetSqlName("SF4")+" SF4 "
				cQuery += "WHERE SD2.D2_FILIAL='"+cFilialSD2+"' AND "
				cQuery += "SD2.D2_DOC='"+SE1->E1_NUM+"' AND "
				cQuery += "SD2.D2_SERIE='"+cSerie+"' AND "
				cQuery += "SD2.D2_CLIENTE='"+SE1->E1_CLIENTE+"' AND "
				cQuery += "SD2.D2_LOJA='"+SE1->E1_LOJA+"' AND "
				cQuery += "SD2.D_E_L_E_T_<>'*' AND "
				cQuery += "SF4.F4_FILIAL='"+cFilialSF4+"' AND "
				cQuery += "SF4.F4_CODIGO=SD2.D2_TES AND "
				cQuery += "SF4.D_E_L_E_T_<>'*' "
				cQuery += "ORDER BY "+SqlOrder(SD2->(IndexKey()))
				cQuery := ChangeQuery(cQuery)

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2)
				lContinua := !(cAliasSD2)->(Eof())
				For nCntFor := 1 To Len(aStruSD2)
					If ( aStruSD2[nCntFor][2]!= "C" )
						TcSetField(cAliasSD2,aStruSD2[nCntFor][1],aStruSD2[nCntFor][2],aStruSD2[nCntFor][3],aStruSD2[nCntFor][4])
					EndIf
				Next nCntFor
				For nCntFor := 1 To Len(aStruSF4)
					If ( aStruSF4[nCntFor][2]!="C" )
						TcSetField(cAliasSF4,aStruSF4[nCntFor][1],aStruSF4[nCntFor][2],aStruSD2[nCntFor][3],aStruSF4[nCntFor][4])
					EndIf
				Next nCntFor
			Else
			#ENDIF
			If (!MsSeek(cFilialSD2+SE1->E1_NUM+cSerie+SE1->E1_CLIENTE+SE1->E1_LOJA,.F.))
				lContinua := .F.
			EndIf
			#IFDEF TOP
			EndIf
		#ENDIF




		If ( lContinua )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calculo da comissao por item de nota fiscal                  ³
		//³                                                              ³
		//³1)O Valor do icms s/ frete e adiciona ao campo F2_VALICM, por ³
		//³esta razao deve-se somar o vlr do icms dos itens e subtrair   ³
		//³do total de icms (F2_VALICM) para apurar-se o vlr icms s/frete³
		//³                                                              ³
		//³2)O mesmo ocorre para o valor do IPI sobre frete, Por esta ra-³
		//³zao e' calculado o valor do IPI sobre frete do item multipli- ³
		//³cando-se o valor do frete do item pelo % de ipi do item.      ³
		//³                                                              ³
		//³3)O Valor do Icms Retido pode nÆo estar no total da nota (F2_-³
		//³VALBRUT) por isto deve-se considerar o campo (D2_ICMSRET).    ³
		//³                                                              ³
		//³4)O percentual da comissao dever ser considerado para cada i- ³
		//³tem de nota fiscal pois ela pode ser diferente entre eles. O  ³
		//³percentual gravado no E1_COMIS ‚ sempre um valor aproximado e ³
		//³nao deve ser considerado ser houver nota fiscal para o titulo.³
		//³                                                              ³
		//³5)A Base da Comissao ‚ o valor da mercadoria + o valor do ipi ³
		//³+ o valor das despesas acessorias +  o icms solidario. Como e'³
		//³por item deve-se conhece-lo pelo item a item.                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nTotal     := 0
			nFrete     := (SF2->F2_FRETE + SF2->F2_SEGURO + SF2->F2_DESPESA)
			nIcmFrete  := 0
			nSF2IcmRet :=0

			If !Empty( nScanPis := aScan(aRelImp,{|x| x[1]=="SD2" .And. x[3]=="IT_VALPS2"} ) )
				cFieldPis  := aRelImp[nScanPis,2]
			EndIf

			If !Empty( nScanCof := aScan(aRelImp,{|x| x[1]=="SD2" .And. x[3]=="IT_VALCF2"} ) )
				cFieldCof := aRelImp[nScanCof,2]
			EndIf

			nPosFldPis := (cAliasSD2)->(FieldPos(cFieldPis))
			nPosFldCof := (cAliasSD2)->(FieldPos(cFieldCof))

			While ( !Eof() .And. (cAliasSD2)->D2_FILIAL == cFilialSD2 .And.;
					(cAliasSD2)->D2_DOC 	 == SE1->E1_NUM .And.;
					(cAliasSD2)->D2_SERIE	 == cSerie .And.;
					(cAliasSD2)->D2_CLIENTE  == SE1->E1_CLIENTE .And.;
					(cAliasSD2)->D2_LOJA	 == SE1->E1_LOJA	)

				If ( !lQuery )
					dbSelectArea("SF4")
					dbSetOrder(1)
					MsSeek(cFilialSF4+(cAliasSD2)->D2_TES)
				Else
					If cPaisLoc<>"BRA"
						SD2->(DbGoto((cAliasSD2)->SD2RECNO))
					Endif
				EndIf

				cVend := "1"
				For nCntFor := 1 To nVend
					cVendedor := SF2->(FieldGet(SF2->(FieldPos("F2_VEND"+cVend))))
					nPerComis := (cAliasSD2)->(FieldGet((cAliasSD2)->(FieldPos("D2_COMIS"+cVend))))
					nImp     := 0
					nDescImp := 0
					If cPaisLoc <> "BRA"
						SA3->(DbSetOrder(1))
						SA3->(DbSeek(xFilial()+cVendedor))
						aImp := TesImpInf(	(cAliasSD2)->D2_TES)
						cImp := IIf(SA3->(FieldPos("A3_COMIMP")) >0,SA3->A3_COMIMP,"N")
						For nX :=1 to Len(aImp)
							If (cImp+aImp[nX][3] == "S1")
								nImp += SD2->(FieldGet(FieldPos(aImp[nX][2])))
							ElseIf (cImp+aImp[nX][3] == "N2")
								nImp -=	SD2->(FieldGet(FieldPos(aImp[nX][2])))
							EndIf
						Next nX
					Else
						If (cAliasSD2)->(FieldPos("D2_DESCICM"))<>0
							nDescImp -= (cAliasSD2)->D2_DESCICM
						EndIf
					EndIf
					If ( !Empty(cVendedor) .And. (cAliasSF4)->F4_DUPLIC == "S" )
						aadd(aSD2Vend,{ cVendedor,;
							(cAliasSD2)->D2_TOTAL+nImp+nDescImp,;
							(cAliasSD2)->D2_VALICM+nDescImp,;
							(cAliasSD2)->D2_VALIPI,;
							(cAliasSD2)->D2_IPI,;
							(cAliasSF4)->F4_INCIDE,;
							(cAliasSF4)->F4_IPIFRET,;
							Iif(cPaisLoc<>"BRA".Or.(cAliasSF4)->F4_INCSOL=="N",0,(cAliasSD2)->D2_ICMSRET),;
							nPerComis,;
							(cAliasSD2)->D2_VALACRS,;
							If(lQuery,(cAliasSD2)->SD2RECNO,(cAliasSD2)->(RecNo())),;
							(cAliasSF4)->F4_ISS=="S",;
							cVend,;
							If(nPosFldPis > 0,(cAliasSD2)->(FieldGet(nPosFldPis)),0),;
							If(nPosFldCof > 0,(cAliasSD2)->(FieldGet(nPosFldCof)),0)})
						If aScan(aVendPed, cVendedor) == 0	  // Monta um array com os vendedores para rateio do frete
							aadd(aVendPed, cVendedor)
						Endif
					EndIf
					cVend := Soma1(cVend,1)
				Next nCntFor
				If ( (cAliasSF4)->F4_ISS != "S" )
					If (cAliasSF4)->(FieldPos("F4_INCSOL"))>0
						nSF2IcmRet += Iif((cAliasSF4)->F4_INCSOL=="N",0,(cAliasSD2)->D2_ICMSRET)
					EndIf
					If (cAliasSD2)->(FieldPos("D2_ICMFRET"))>0
						nIcmFrete  += (cAliasSD2)->D2_ICMFRET
					EndIf
				EndIf
				nTotal	  += (cAliasSD2)->D2_TOTAL
				dbSelectArea(cAliasSD2)
				dbSkip()
			EndDo
			If ( lQuery )
				dbSelectArea(cAliasSD2)
				dbCloseArea()
				dbSelectArea("SD2")
			EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calculo da comissao pela nota.                               ³
		//³                                                              ³
		//³1)Apos calculado as bases de cada vendedor por item de nota   ³
		//³deve-se aglutina-las formando uma unica base para toda a nota ³
		//³fiscal.                                                       ³
		//³                                                              ³
		//³2)Como os valores serao aglutinados pode-se haver perda de de-³
		//³cimais por isto deve-se haver um controle para que a perda se-³
		//³ja adicionada a primeira parcela da nota.                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nMaxFor := Len(aSD2Vend)
			nPerComis:=0
			nFreteAux := 0
			For nCntFor := 1 To nMaxFor
				If (lPePercom)
					nPerComis := ExecBlock("FIN440PE",.F.,.F.,{aSD2Vend[nCntFor][1]})
					If ( ValType(nPerComis)<>"N" )
						nPerComis := aSD2Vend[nCntFor][9]
					Else
						aSD2Vend[nCntFor][9] := nPerComis
					EndIf
				Else
					nPerComis := aSD2Vend[nCntFor][9]
				EndIf
				If ( SE1->E1_PARCELA $ cPrimParc )
					nBaseDif  := NoRound(nFrete*(1-(aSD2Vend[nCntFor,2]/nTotal)),nDecimal)
					nBaseDif  := nFrete - nBaseDif
				// No ultimo item o valor do rateio do frete é o valor do frete menos o rateio do frete acumulado
				// ate o penultimo item (evitar diferenca de centavos na base da comissao (E1_BASCOM)
					If nCntFor == nMaxFor
						nRatFrete := (nFrete * If(Len(aVendPed) > 0, Len(aVendPed), 1)) - nFreteAux
					Else
						nFreteAux += nBaseDif
						nRatFrete := nBaseDif
					EndIf
				Else
					nRatFrete := NoRound(nFrete*aSD2Vend[nCntFor,2]/nTotal,nDecimal)
				EndIf
				If cPaisLoc == "BRA"
					If ( SE1->E1_PARCELA $ cPrimParc )
						nBaseDif  := NoRound(SF2->F2_VALINSS*(1-(aSD2Vend[nCntFor,2]/nTotal)),nDecimal)
						nBaseDif  := SF2->F2_VALINSS - nBaseDif
						nRatINSS  := nBaseDif
					Else
						nRatINSS := NoRound(SF2->F2_VALINSS*aSD2Vend[nCntFor,2]/nTotal,nDecimal)
					EndIf

					If SF2->(FieldPos("F2_VALPIS")) > 0
						If ( SE1->E1_PARCELA $ cPrimParc )
							nBaseDif  := NoRound(SF2->F2_VALPIS*(1-(aSD2Vend[nCntFor,2]/nTotal)),nDecimal)
							nBaseDif  := SF2->F2_VALPIS - nBaseDif
							nRatPIS  := nBaseDif
						Else
							nRatPIS := NoRound(SF2->F2_VALPIS*aSD2Vend[nCntFor,2]/nTotal,nDecimal)
						EndIf
					Endif

					If SF2->(FieldPos("F2_VALCSLL")) > 0
						If ( SE1->E1_PARCELA $ cPrimParc )
							nBaseDif  := NoRound(SF2->F2_VALCSLL*(1-(aSD2Vend[nCntFor,2]/nTotal)),nDecimal)
							nBaseDif  := SF2->F2_VALCSLL - nBaseDif
							nRatCSL  := nBaseDif
						Else
							nRatCSL := NoRound(SF2->F2_VALCSLL*aSD2Vend[nCntFor,2]/nTotal,nDecimal)
						EndIf
					Endif

					If SF2->(FieldPos("F2_VALCOFI")) > 0
						If ( SE1->E1_PARCELA $ cPrimParc )
							nBaseDif  := NoRound(SF2->F2_VALCOFI*(1-(aSD2Vend[nCntFor,2]/nTotal)),nDecimal)
							nBaseDif  := SF2->F2_VALCOFI - nBaseDif
							nRatCOF  := nBaseDif
						Else
							nRatCOF := NoRound(SF2->F2_VALCOFI*aSD2Vend[nCntFor,2]/nTotal,nDecimal)
						EndIf
					Endif

					If ( SE1->E1_PARCELA $ cPrimParc )
						nBaseDif  := NoRound(SF2->F2_VALIRRF*(1-(aSD2Vend[nCntFor,2]/nTotal)),nDecimal)
						nBaseDif  := SF2->F2_VALIRRF - nBaseDif
						nRatIRRF  := nBaseDif
					Else
						nRatIRRF := NoRound(SF2->F2_VALIRRF*aSD2Vend[nCntFor,2]/nTotal,nDecimal)
					EndIf
				EndIf
				nRatIcmFre:= 0
				nBaseSE1  := 0
				nPos      := 0
				nRatIcmFre:= NoRound(nIcmFrete*aSD2Vend[nCntFor,2]/nTotal,nDecimal)
				nBaseSE1  := aSD2Vend[nCntFor,2]+IIF(SF2->F2_TIPO=='P',0,aSD2Vend[nCntFor,4])+aSD2Vend[nCntFor,8]+nRatFrete
				dbSelectArea("SA3")
				dbSetOrder(1)
				MsSeek(xFilial()+aSD2Vend[nCntFor,1])

				If SE1->(FieldPos("E1_ALEMIS"+aSD2Vend[nCntFor,13]))<>0 //Nao criar no dicionario padrao
					nAlEmissao := SE1->(FieldGet(FieldPos("E1_ALEMIS"+aSD2Vend[nCntFor,13])))
				Else
					nAlEmissao := SA3->A3_ALEMISS
				EndIf
				If SE1->(FieldPos("E1_ALBAIX"+aSD2Vend[nCntFor,13]))<>0 //Nao criar no dicionario padrao
					nAlBaixa := SE1->(FieldGet(FieldPos("E1_ALBAIX"+aSD2Vend[nCntFor,13])))
				Else
					nAlBaixa := SA3->A3_ALBAIXA
				EndIf

				If ( SA3->A3_FRETE == "N" )
					nBaseSE1 -=  nRatFrete
					nBaseSE1 +=  nRatIcmFre
				Endif
				If ( SA3->A3_IPI   == "N" )
					nBaseSE1 -= ( aSD2Vend[nCntFor,4] )
				EndIf
				If !aSD2Vend[nCntFor,12]
					If ( SA3->A3_ICM   == "N" )
						nBaseSE1 -= aSD2Vend[nCntFor,3]
					EndIf
				Else
					If ( SA3->A3_ISS == "N" )
					//Se o valor do ISS calculado for inferior ao minimo de retencao (MV_VRETISS), nao descontar da base de comissao
						If SuperGetMV("MV_VRETISS",.F.,0) < aSD2Vend[nCntFor,3]
							nBaseSE1 -= ( aSD2Vend[nCntFor,3] )
						Endif
					EndIf
				EndIf
				If ( SA3->A3_ICMSRET == "N" )
					nBaseSE1 -= ( aSD2Vend[nCntFor,8] )
				EndIf
				If SA3->(FieldPos("A3_ACREFIN")) != 0  // Acrescimo Financeiro
					If ( SA3->A3_ACREFIN == "N" ) .and. aSD2Vend[nCntFor,10] > 0
						nBaseSE1 -= ( aSD2Vend[nCntFor,10] )
					EndIf
				Endif

				If SA3->(FieldPos("A3_PISCOF")) != 0  // Abate Pis/Cofins
					Do Case
					Case SA3->A3_PISCOF == "2" //Abate Pis
						nBaseSE1 -=aSD2Vend[nCntFor,14]
					Case SA3->A3_PISCOF == "3" //Abate Cofins
						nBaseSE1 -=aSD2Vend[nCntFor,15]
					Case SA3->A3_PISCOF == "4" //Abate ambos
						nBaseSE1 -=aSD2Vend[nCntFor,14]
						nBaseSE1 -=aSD2Vend[nCntFor,15]
					EndCase
				Endif

				If SuperGetMv("MV_COMISIR") == "N" .And. lRecIRRF
					nBaseSE1 -= nRatIRRF
				Endif
				If GetNewPar("MV_COMIINS","N") == "N"
					nBaseSE1 -= nRatINSS
				EndIf
				If GetNewPar("MV_COMIPIS","N") == "N"
					nBaseSE1 -= nRatPIS
				EndIf
				If GetNewPar("MV_COMICOF","N") == "N"
					nBaseSE1 -= nRatCOF
				EndIf
				If GetNewPar("MV_COMICSL","N") == "N"
					nBaseSE1 -= nRatCSL
				EndIf
				nPos := aScan(aBaseSE1,{|x| x[1] == aSD2Vend[nCntFor,1]})
				If Alltrim(SE1->E1_Hist) <> "VENDA EM DINHEIRO"
					nBaseBaix := Round(nBaseSE1*nAlBaixa/100,nDecimal)	 	// Base da Comissao na Baixa
				ELSE
					nBaseBaix:= 0
				Endif
				nBaseEmis := nBaseSE1-nBaseBaix                           		// Base da Comissao na Emissao
				If ( nAlEmissao==0 .AND.  Alltrim(SE1->E1_Hist) <> "VENDA EM DINHEIRO" )
					nBaseEmis := 0
				EndIf
				nVlrEmis  := nBaseEmis*aSD2Vend[nCntFor,9]/100	// Valor da Comissao na Emissao
				nVlrBaix  := nBaseBaix*aSD2Vend[nCntFor,9]/100	// Valor da Comissao na Baixa
				If ( Empty(nRegDevol) .Or. nRegDevol == aSD2Vend[nCntFor,11] )
					If ( nPos == 0 )
						aadd(aBaseSE1,{ aSD2Vend[nCntFor,1] ,;
							nBaseSE1  				,;
							nBaseEmis 				,;
							nBaseBaix 				,;
							nVlrEmis  				,;
							nVlrBaix				,;
							nPerComis})
					Else
						aBaseSE1[nPos,2] += nBaseSE1
						aBaseSE1[nPos,3] += nBaseEmis
						aBaseSE1[nPos,4] += nBaseBaix
						aBaseSE1[nPos,5] += nVlrEmis
						aBaseSE1[nPos,6] += nVlrBaix
						If aBaseSE1[nPos,7] == nPerComis
							aBaseSE1[nPos,7] := nPerComis
						Else
							aBaseSE1[nPos,7] := 0
						EndIf
					EndIf
				EndIf
			Next nCntFor
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calculo da comissao pelas parcelas.                          ³
		//³                                                              ³
		//³1)O SE3 ‚ gravado por parcela e nao pela nota. assim e'neces- ³
		//³ssario calcular a base da comissao para a parcela em questao. ³
		//³                                                              ³
		//³2)Aqui deve-se tomar o maximo cuidado com a Condi‡Æo de pagto ³
		//³pois se o Icms Solidario ou o Ipi for separado de alguma par- ³
		//³cela deve-se considera esta separacao para calcular-se a me-  ³
		//³lhor propor‡ao possivel para a base da parcela.               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lCalcParc
				nMaxFor := Len(aBaseSE1)
				For nCntFor := 1 To nMaxFor
					nProp   := 0
					nVlrFat := xMoeda(SF2->F2_VALFAT,SE1->E1_MOEDA,1,SE1->E1_EMISSAO)
					nVlrTit := SE1->E1_VLCRUZ
					dbSelectArea("SA3")
					dbSetOrder(1)
					MsSeek(xFilial()+aBaseSE1[nCntFor,1])
					If ( SA3->A3_IPI == "N" .Or. SA3->A3_ICMSRET == "N" )
						If ( (SE4->E4_IPI == "S" .And. SF2->F2_VALIPI <> 0) .Or. ( SE4->E4_SOLID=="S" .And. SF2->F2_ICMSRET <> 0) ) .And. (SE1->E1_PARCELA $ cPrimParc)
							nVlrTit := 0
							nVlrFat := 0
						EndIf
						If ( SE4->E4_IPI == "S" .And. !SE1->E1_PARCELA $ cPrimParc)
							nVlrFat -= ( SF2->F2_VALIPI )
						EndIf
						If ( SE4->E4_SOLID == "S" .And. !SE1->E1_PARCELA $ cPrimParc)
							nVlrFat -= (nSf2IcmRet)
						EndIf
						If ( SE4->E4_IPI == "J" .And. SE1->E1_PARCELA $ cPrimParc)
							nVlrFat -= ( SF2->F2_VALIPI )
							nVlrTit -= ( SF2->F2_VALIPI )
						EndIf
						If ( SE4->E4_IPI == "J" .And. !(SE1->E1_PARCELA $ cPrimParc ))
							nVlrFat -= ( SF2->F2_VALIPI )
						EndIf
						If ( SE4->E4_SOLID == "J" .And. SE1->E1_PARCELA $ cPrimParc )
							nVlrFat -= (nSf2IcmRet)
							nVlrTit -= (nSf2IcmRet)
						EndIf
						If ( SE4->E4_SOLID == "J" .And. !(SE1->E1_PARCELA $ cPrimParc) )
							nVlrFat -= (nSf2IcmRet)
						EndIf
					EndIf
					If ( nVlrTit > 0 )
						nProp := nVlrFat / nVlrTit
					Else
						nProp := 0
					EndIf
					If (nProp != 0 )
						nBaseSE1 := NoRound(aBaseSE1[nCntFor,2]/nProp,nDecimal)
						nBaseEmis:= NoRound(aBaseSE1[nCntFor,3]/nProp,nDecimal)
						nBaseBaix:= NoRound(aBaseSE1[nCntFor,4]/nProp,nDecimal)
						nVlrEmis := Round(aBaseSE1[nCntFor,5]/nProp,nDecimal)
						nVlrBaix := Round(aBaseSE1[nCntFor,6]/nProp,nDecimal)
					Else
						nBaseSE1 := 0
						nBaseEmis:= 0
						nBaseBaix:= 0
						nVlrEmis := 0
						nVlrBaix := 0
					EndIf
					If ( SE1->E1_PARCELA $ cPrimParc .And. nBaseSE1 != 0 )
					//--> Calculo da Proporcao para a Base da Comissao
						nBaseDif := Round(nBaseSE1 * nProp,nDecimal)
						nBaseDif := aBaseSE1[nCntFor,2]-nBaseDif
						aBaseSE1[nCntFor,2] := nBaseSE1+nBaseDif
					//--> Calculo da Proporcao para a Base da Comissao pela Emissao

						nBaseDif := Round(nBaseEmis * nProp,nDecimal)
						nBaseDif := aBaseSE1[nCntFor,3]-nBaseDif
						aBaseSE1[nCntFor,3] := nBaseEmis+nBaseDif
					//--> Calculo da Proporcao para a Base da Comissao pela Baixa

						nBaseDif := Round(nBaseBaix * nProp,nDecimal)
						nBaseDif := aBaseSE1[nCntFor,4]-nBaseDif
						aBaseSE1[nCntFor,4] := nBaseBaix+nBaseDif
					//--> Calculo da Proporcao para o Valor da Comissao pela Emissao

						nBaseDif := Round(nVlrEmis * nProp,nDecimal)
						nBaseDif := aBaseSE1[nCntFor,5]-nBaseDif
						aBaseSE1[nCntFor,5] := nVlrEmis+nBaseDif
					//--> Calculo da Proporcao para o Valor da Comissao pela Baixa

						nBaseDif := Round(nVlrBaix * nProp,nDecimal)
						nBaseDif := aBaseSE1[nCntFor,6]-nBaseDif
						aBaseSE1[nCntFor,6] := nVlrBaix+nBaseDif
					Else
						aBaseSE1[nCntFor,2] := nBaseSE1
						aBaseSE1[nCntFor,3] := nBaseEmis
						aBaseSE1[nCntFor,4] := nBaseBaix
						aBaseSE1[nCntFor,5] := nVlrEmis
						aBaseSE1[nCntFor,6] := nVlrBaix
					EndIf
				Next nCntFor
			EndIf
		Else
			If ( lQuery .And. Select(cAliasSD2)<>0 )
				dbSelectArea(cAliasSD2)
				dbCloseArea()
				dbSelectArea("SE1")
			EndIf
		EndIf
	EndIf
	If ( SE1->E1_TIPO $ MV_CRNEG ) .And. !("FINA040" $ SE1->E1_ORIGEM)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a filial de origem das notas de devolucao de Venda  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If SE1->(FieldPos("E1_FILORIG")) > 0
			If !Empty(SE1->E1_FILORIG) .and. !(Empty(cFilialSF1))
				cFilialSF1 := SE1->E1_FILORIG
			Endif
		EndIf
		If SE1->(FieldPos("E1_FILORIG")) > 0
			If !Empty(SE1->E1_FILORIG) .and. !(Empty(cFilialSD1))
				cFilialSD1 := SE1->E1_FILORIG
			Endif
		EndIf

		If Year(SE1->E1_EMISSAO)<2001
			cSerie := If(Empty(SE1->E1_SERIE),SE1->E1_PREFIXO,SE1->E1_SERIE)
		Else
			cSerie := SE1->E1_SERIE
		EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona Registros                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SF1")
		dbSetOrder(1)
		If (!MsSeek(cFilialSF1+SE1->E1_NUM+cSerie+SE1->E1_CLIENTE+SE1->E1_LOJA,.F.))
			lContinua := .F.
		EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calculo do Estorno da Comissao.                              ³
	//³                                                              ³
	//³1) Localiza-se a Nota Original                                ³
	//³                                                              ³
	//³2) Calcula a Comissao para a Nota Original                    ³
	//³                                                              ³
	//³3) Faz a Proporcao entre os valor da Mercadoria e os valores  ³
	//³   da comissao.                                               ³
	//³                                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SD1")
		dbSetOrder(1)
		#IFDEF TOP
			If ( TcSrvType()!="AS/400" )
				SD1->(dbCommit())
				cAliasSD1 := "BFA440COMIS"
				lQuery := .T.
				cQuery := ""
				For nCntFor := 1 To Len(aStruSD1)
					cQuery += ","+aStruSD1[nCntFor][1]
				Next nCntFor
				cQuery := "SELECT "+SubStr(cQuery,2)
				cQuery += "FROM "+RetSqlName("SD1")+" SD1 "
				cQuery += "WHERE SD1.D1_FILIAL='"+cFilialSD1+"' AND "
				cQuery += "SD1.D1_DOC='"+SE1->E1_NUM+"' AND "
				cQuery += "SD1.D1_SERIE='"+cSerie+"' AND "
				cQuery += "SD1.D1_FORNECE='"+SE1->E1_CLIENTE+"' AND "
				cQuery += "SD1.D1_LOJA='"+SE1->E1_LOJA+"' AND "
				If cPaisLoc<>"BRA"
					cQuery += "SD1.D_E_L_E_T_<>'*' "
				Else
					cQuery += "SD1.D_E_L_E_T_<>'*' AND "
					cQuery += "SD1.D1_ITEMORI<>'"+Space(Len(SD1->D1_ITEMORI))+"' "
				EndIF
				cQuery += "ORDER BY "+SqlOrder(SD1->(IndexKey()))
				cQuery := ChangeQuery(cQuery)

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1,.T.,.T.)
				lContinua := !(cAliasSD1)->(Eof())
				For nCntFor := 1 To Len(aStruSD1)
					If ( aStruSD1[nCntFor][2]!="C" )
						TcSetField(cAliasSD1,aStruSD1[nCntFor][1],aStruSD1[nCntFor][2],aStruSD1[nCntFor][3],aStruSD1[nCntFor][4])
					EndIf
				Next nCntFor
			Else
			#ENDIF
			If (!MsSeek(cFilialSD1+SE1->E1_NUM+cSerie+SE1->E1_CLIENTE+SE1->E1_LOJA,.F.))
				lContinua := .F.
			EndIf
			#IFDEF TOP
			EndIf
		#ENDIF
		aSemNota	:=	{}
		While ( !Eof() .And. cFilialSD1  == (cAliasSD1)->D1_FILIAL  .And.;
				SF1->F1_DOC 	 == (cAliasSD1)->D1_DOC	  .And.;
				SF1->F1_SERIE	 == (cAliasSD1)->D1_SERIE   .And.;
				SF1->F1_FORNECE == (cAliasSD1)->D1_FORNECE .And.;
				SF1->F1_LOJA	 == (cAliasSD1)->D1_LOJA )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Localiza a Nota de Saida - Item                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SD2")
			dbSetOrder(3)
			MsSeek(cFilialSD2+(cAliasSD1)->D1_NFORI+(cAliasSD1)->D1_SERIORI+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_COD+AllTrim((cAliasSD1)->D1_ITEMORI))
			If !SD2->(FOUND())
			//Carrega os items que nao tem nota original
				AAdd(aSemNota,(cAliasSD1)->D1_ITEM)
			Endif
			aBaseSD1 := {} // Inicializa Bases do Item
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona no Nota Fiscal de Saida - Cabecalho                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SF2")
			dbSetOrder(1)
			MsSeek(cFilialSF2+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA)
			If Empty(SF2->F2_PREFIXO)
				cPrefixo := Alltrim(Posicione("SX6",1,cFilialSF2+"MV_1DUPREF","X6_CONTEUD"))
				If Empty(cPrefixo) //Caso não exista o parametro na filial posicionada, pega o coteudo (GetMv)
					cPrefixo := &(GetMV("MV_1DUPREF"))
				EndIf
			Else
				cPrefixo := SF2->F2_PREFIXO
			EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona no Titulo Financeiro                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SE1")
			dbSetOrder(2)
			MsSeek(cFilialSE1+SF2->F2_CLIENTE+SF2->F2_LOJA+cPrefixo+SD2->D2_DOC)
			While ( !Eof() .And. cFilialSE1  == SE1->E1_FILIAL .And.;
					SE1->E1_CLIENTE == SF2->F2_CLIENTE .And.;
					SE1->E1_LOJA    == SF2->F2_LOJA .And.;
					SE1->E1_PREFIXO == cPrefixo .And.;
					SE1->E1_NUM		 == SF2->F2_DOC )
				If ( SE1->E1_TIPO $ MVNOTAFIS+cEspSes )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula o Valor da Comissao para a Parcela                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aBaseNCC := Fa440Comis(SE1->(Recno()),.F.,.T.,SD2->(RecNo()))
					For nCntFor := 1 To Len(aBaseNCC)
						cVendedor := aBaseNCC[nCntFor,1]
						nPos := aScan(aBaseSD1,{|x| x[1]==cVendedor})
						If ( nPos == 0 )
							aadd(aBaseSD1,{ 	aBaseNCC[nCntFor,1],;
								aBaseNCC[nCntFor,2],;
								aBaseNCC[nCntFor,3],;
								aBaseNCC[nCntFor,4],;
								aBaseNCC[nCntFor,5],;
								aBaseNCC[nCntFor,6],;
								aBaseNCC[nCntFor,7]})
						Else
							aBaseSD1[nPos,2] += aBaseNCC[nCntFor,2]
							aBaseSD1[nPos,3] += aBaseNCC[nCntFor,3]
							aBaseSD1[nPos,4] += aBaseNCC[nCntFor,4]
							aBaseSD1[nPos,5] += aBaseNCC[nCntFor,5]
							aBaseSD1[nPos,6] += aBaseNCC[nCntFor,6]
						EndIf
					Next nCntFor
				EndIf
				dbSelectArea("SE1")
				dbSkip()
			EndDo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Aqui eh proporcionalizado as Bases da nota de saida com o item devol.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nCntFor := 1 To Len(aBaseSD1)
				aBaseSD1[nCntFor,2] := NoRound(aBaseSD1[nCntFor,2]*((cAliasSD1)->D1_TOTAL-(cAliasSD1)->D1_VALDESC)/SD2->D2_TOTAL,nDecimal)
				aBaseSD1[nCntFor,3] := NoRound(aBaseSD1[nCntFor,3]*((cAliasSD1)->D1_TOTAL-(cAliasSD1)->D1_VALDESC)/SD2->D2_TOTAL,nDecimal)
				aBaseSD1[nCntFor,4] := NoRound(aBaseSD1[nCntFor,4]*((cAliasSD1)->D1_TOTAL-(cAliasSD1)->D1_VALDESC)/SD2->D2_TOTAL,nDecimal)
				aBaseSD1[nCntFor,5] := NoRound(aBaseSD1[nCntFor,5]*((cAliasSD1)->D1_TOTAL-(cAliasSD1)->D1_VALDESC)/SD2->D2_TOTAL,nDecimal)
				aBaseSD1[nCntFor,6] := NoRound(aBaseSD1[nCntFor,6]*((cAliasSD1)->D1_TOTAL-(cAliasSD1)->D1_VALDESC)/SD2->D2_TOTAL,nDecimal)
			Next nCntFor
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aqui eh somado as bases ja calculadas e como a NCC estorna os valores   ³
		//³na emissao, adiciona-se a base da baixa na base da emissao.             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nCntFor := 1 To Len(aBaseSD1)
				cVendedor := aBaseSD1[nCntFor,1]
				nPos := aScan(aBAseSE1,{|x| x[1] == cVendedor })
				If ( nPos == 0 )
					aadd(aBaseSE1,{ 	aBaseSD1[nCntFor,1],;
						aBaseSD1[nCntFor,2],;
						aBaseSD1[nCntFor,3]+aBaseSD1[nCntFor,4],0,;
						aBaseSD1[nCntFor,5]+aBaseSD1[nCntFor,6],0,0})
				Else
					aBaseSE1[nPos,2] += aBaseSD1[nCntFor,2]
					aBaseSE1[nPos,3] += aBaseSD1[nCntFor,3]+aBaseSD1[nCntFor,4]
					aBaseSE1[nPos,5] += aBaseSD1[nCntFor,5]+aBaseSD1[nCntFor,6]
				EndIf
			Next nCntFor
			dbSelectArea(cAliasSD1)
			dbSkip()
		EndDo
		If ( (Empty(aBaseSE1).Or. Len(aSemNota) > 0) .And. lRefaz .And. cPaisLoc<>"BRA")
			dbSelectArea("SE1")
			MsGoto(nRegistro)
			cSerie := If(Empty(SE1->E1_SERIE),SE1->E1_PREFIXO,SE1->E1_SERIE)
			dbSelectArea("SF1")
			dbSetOrder(1)
			If (!MsSeek(cFilialSF1+SE1->E1_NUM+cSerie+SE1->E1_CLIENTE+SE1->E1_LOJA,.F.))
				lContinua := .F.
			EndIf
			dbSelectArea("SE4")
			dbSetOrder(1)
			If (!MsSeek(cFilialSE4+SF1->F1_COND))
				lContinua := .F.
			EndIf
			dbSelectArea("SD1")
			dbSetOrder(1)
			#IFDEF TOP
				If ( TcSrvType()!="AS/400" )
					lQuery := .T.
					cAliasDev := "FA440COMIS"
					cAliasSF4 := "FA440COMIS"
					cQuery := ""
					For nCntFor := 1 To Len(aStruSD1)
						cQuery += ","+aStruSD1[nCntFor][1]
					Next nCntFor
					For nCntFor := 1 To Len(aStruSF4)
						cQuery += ","+aStruSF4[nCntFor][1]
					Next nCntFor
					cQuery := "SELECT SD1.R_E_C_N_O_ SD1RECNO,"+SubStr(cQuery,2)
					cQuery += "FROM "+RetSqlName("SD1")+" SD1,"+RetSqlName("SF4")+" SF4 "
					cQuery += "WHERE SD1.D1_FILIAL='"+cFilialSD1+"' AND "
					cQuery += "SD1.D1_DOC='"+SE1->E1_NUM+"' AND "
					cQuery += "SD1.D1_SERIE='"+cSerie+"' AND "
					cQuery += "SD1.D1_FORNECE='"+SE1->E1_CLIENTE+"' AND "
					cQuery += "SD1.D1_LOJA='"+SE1->E1_LOJA+"' AND "
					cQuery += "SD1.D_E_L_E_T_<>'*' AND "
					cQuery += "SF4.F4_FILIAL='"+cFilialSF4+"' AND "
					cQuery += "SF4.F4_CODIGO=SD1.D1_TES AND "
					cQuery += "SF4.D_E_L_E_T_<>'*' "
					cQuery += "ORDER BY "+SqlOrder(SD1->(IndexKey()))
					cQuery := ChangeQuery(cQuery)

					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDev)
					lContinua := !(cAliasDev)->(Eof())
					For nCntFor := 1 To Len(aStruSD1)
						If ( aStruSD1[nCntFor][2]!= "C" )
							TcSetField(cAliasDev,aStruSD1[nCntFor][1],aStruSD1[nCntFor][2],aStruSD1[nCntFor][3],aStruSD1[nCntFor][4])
						EndIf
					Next nCntFor
					For nCntFor := 1 To Len(aStruSF4)
						If ( aStruSF4[nCntFor][2]!="C" )
							TcSetField(cAliasSF4,aStruSF4[nCntFor][1],aStruSF4[nCntFor][2],aStruSD1[nCntFor][3],aStruSF4[nCntFor][4])
						EndIf
					Next nCntFor
				Else
				#ENDIF
				If (!MsSeek(cFilialSD1+SE1->E1_NUM+cSerie+SE1->E1_CLIENTE+SE1->E1_LOJA,.F.))
					lContinua := .F.
				EndIf

				#IFDEF TOP
				EndIf
			#ENDIF
			If ( lContinua )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calculo da comissao por item de nota fiscal 			     ³
			//³																 ³
			//³1)O Valor do icms s/ frete e adiciona ao campo F2_VALICM, por ³
			//³esta razao deve-se somar o vlr do icms dos itens e subtrair   ³
			//³do total de icms (F2_VALICM) para apurar-se o vlr icms s/frete³
			//³																 ³
			//³2)O mesmo ocorre para o valor do IPI sobre frete, Por esta ra-³
			//³zao e' calculado o valor do IPI sobre frete do item multipli- ³
			//³cando-se o valor do frete do item pelo % de ipi do item. 	 ³
			//³																 ³
			//³3)O Valor do Icms Retido pode nÆo estar no total da nota (F2_-³
			//³VALBRUT) por isto deve-se considerar o campo (D2_ICMSRET).	 ³
			//³																 ³
			//³4)O percentual da comissao dever ser considerado para cada i- ³
			//³tem de nota fiscal pois ela pode ser diferente entre eles. O  ³
			//³percentual gravado no E1_COMIS ‚ sempre um valor aproximado e ³
			//³nao deve ser considerado ser houver nota fiscal para o titulo.³
			//³																 ³
			//³5)A Base da Comissao ‚ o valor da mercadoria + o valor do ipi ³
			//³+ o valor das despesas acessorias +  o icms solidario. Como e'³
			//³por item deve-se conhece-lo pelo item a item.				 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nTotal	  := 0
				nFrete	  := (SF1->F1_FRETE + SF1->F1_SEGURO + SF1->F1_DESPESA)
				nIcmFrete  := 0
				nSF2IcmRet :=0
				While ( !Eof() .And. (cAliasDev)->D1_FILIAL == cFilialSD1 .And.;
						(cAliasDev)->D1_DOC 	 == SE1->E1_NUM .And.;
						(cAliasDev)->D1_SERIE	 == cSerie .And.;
						(cAliasDev)->D1_FORNECE  == SE1->E1_CLIENTE .And.;
						(cAliasDev)->D1_LOJA	 == SE1->E1_LOJA	)

					If Ascan(aSemNota,(cAliasDev)->D1_ITEM) ==0
						(cAliasDev)->(DbSkip())
						Loop
					EndIf

					If ( !lQuery )
						dbSelectArea("SF4")
						dbSetOrder(1)
						MsSeek(cFilialSF4+(cAliasDev)->D1_TES)
					Else
						If cPaisLoc<>"BRA"
							SD1->(DbGoto((cAliasDev)->SD1RECNO))
						Endif
					EndIf
					cVend := "1"

					cVendedor := SF1->F1_VEND1

					nImp := 0
					If cPaisLoc <> "BRA"
						SA3->(DbSetOrder(1))
						SA3->(DbSeek(xFilial()+cVendedor))
						aImp := TesImpInf(SD1->D1_TES)
						cImp := IIf(SA3->(FieldPos("A3_COMIMP")) >0,SA3->A3_COMIMP,"N")
						nPerComis := SA3->A3_COMIS
						For nX :=1 to Len(aImp)
							If (cImp+aImp[nX][3] == "S1")
								nImp += SD1->(FieldGet(FieldPos(aImp[nX][2])))
							ElseIf (cImp+aImp[nX][3] == "N2")
								nImp -= SD1->(FieldGet(FieldPos(aImp[nX][2]))	)
							Endif
						Next
					EndIf

					If ( !Empty(cVendedor) .And. (cAliasSF4)->F4_DUPLIC == "S" )
						If (cAliasDev)->(FieldPos("D1_COMIS"+cVend)) > 0 .And.;
								(cAliasDev)->(FieldGet((cAliasDev)->(FieldPos("D1_COMIS"+cVend)))) > 0
							nPerComis := (cAliasDev)->(FieldGet((cAliasDev)->(FieldPos("D1_COMIS"+cVend))))
						Endif
						aadd(aSD2Vend,{ cVendedor,;
							(cAliasDev)->D1_TOTAL+nImp,;
							0,;
							0,;
							0,;
							(cAliasSF4)->F4_INCIDE,;
							(cAliasSF4)->F4_IPIFRET,;
							0,;
							nPerComis,;
							0,;
							If(lQuery,(cAliasDev)->SD1RECNO,(cAliasDev)->(RecNo()))})
					EndIf

					nTotal	  += (cAliasDev)->D1_TOTAL
					dbSelectArea(cAliasDev)
					dbSkip()
				EndDo
				If ( lQuery )
					dbSelectArea(cAliasDev)
					dbCloseArea()
					dbSelectArea("SD1")
				EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calculo da comissao pela nota.							     ³
			//³																 ³
			//³1)Apos calculado as bases de cada vendedor por item de nota   ³
			//³deve-se aglutina-las formando uma unica base para toda a nota ³
			//³fiscal.														 ³
			//³																 ³
			//³2)Como os valores serao aglutinados pode-se haver perda de de-³
			//³cimais por isto deve-se haver um controle para que a perda se-³
			//³ja adicionada a primeira parcela da nota. 					 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nMaxFor := Len(aSD2Vend)
				nPerComis:=0
				For nCntFor := 1 To nMaxFor
					If ( lPeperCom )
						nPerComis := ExecBlock("FIN440PE",.F.,.F.,{aSD2Vend[nCntFor][1]})
						If ( ValType(nPerComis)<>"N" )
							nPerComis := aSD2Vend[nCntFor][9]
						EndIf
					EndIf
					If ( SE1->E1_PARCELA $ cPrimParc )
						nBaseDif  := NoRound(nFrete*(1-(aSD2Vend[nCntFor,2]/nTotal)),nDecimal)
						nBaseDif  := nFrete - nBaseDif
						nRatFrete := nBaseDif
					Else
						nRatFrete := NoRound(nFrete*aSD2Vend[nCntFor,2]/nTotal,nDecimal)
					EndIf
					nRatIcmFre:= 0
					nBaseSE1  := 0
					nPos		 := 0
					nRatIcmFre:= NoRound(nIcmFrete*aSD2Vend[nCntFor,2]/nTotal,nDecimal)
					nBaseSE1  := aSD2Vend[nCntFor,2]+aSD2Vend[nCntFor,4]+aSD2Vend[nCntFor,8]+nRatFrete
					dbSelectArea("SA3")
					dbSetOrder(1)
					MsSeek(xFilial()+aSD2Vend[nCntFor,1])

					nAlEmissao := SA3->A3_ALEMISS
					nAlBaixa := SA3->A3_ALBAIXA

					If ( SA3->A3_FRETE == "N" )
						nBaseSE1 -= ( nRatFrete )
					Endif
					If SA3->(FieldPos("A3_ACREFIN")) != 0  // Acrescimo Financeiro
						If ( SA3->A3_ACREFIN == "N" ) .and. aSD2Vend[nCntFor,10] > 0
							nBaseSE1 -= ( aSD2Vend[nCntFor,10] )
						EndIf
					Endif
					nPos := aScan(aBaseSE1,{|x| x[1] == aSD2Vend[nCntFor,1]})
					If Alltrim(SE1->E1_Hist) <> "VENDA EM DINHEIRO"
						nBaseBaix := Round(nBaseSE1*nAlBaixa/100,nDecimal) 	// Base da Comissao na Baixa
					Else
						nBaseBaix:= 0
					EndIf
					nBaseEmis := nBaseSE1-nBaseBaix											// Base da Comissao na Emissao
					nVlrEmis  := Round(nBaseEmis*aSD2Vend[nCntFor,9]/100,nDecimal) // Valor da Comissao na Emissao
					nVlrBaix  := Round(nBaseBaix*aSD2Vend[nCntFor,9]/100,nDecimal) // Valor da Comissao na Baixa
					If ( Empty(nRegDevol) .Or. nRegDevol == aSD2Vend[nCntFor,11] )
						If ( nPos == 0 )
							aadd(aBaseSE1,{ aSD2Vend[nCntFor,1] ,;
								nBaseSE1				,;
								nBaseEmis				,;
								nBaseBaix				,;
								nVlrEmis				,;
								nVlrBaix				,;
								nPerComis				})
						Else
							aBaseSE1[nPos,2] += nBaseSE1
							aBaseSE1[nPos,3] += nBaseEmis
							aBaseSE1[nPos,4] += nBaseBaix
							aBaseSE1[nPos,5] += nVlrEmis
							aBaseSE1[nPos,6] += nVlrBaix
							If aBaseSE1[nPos,7] == nPerComis
								aBaseSE1[nPos,7] := nPerComis
							Else
								aBaseSE1[nPos,7] := 0
							EndIf
						EndIf
					EndIf
				Next nCntFor
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calculo da comissao pelas parcelas.							 ³
			//³																 ³
			//³1)O SE3 ‚ gravado por parcela e nao pela nota. assim e'neces- ³
			//³ssario calcular a base da comissao para a parcela em questao. ³
			//³																 ³
			//³2)Aqui deve-se tomar o maximo cuidado com a Condi‡Æo de pagto ³
			//³pois se o Icms Solidario ou o Ipi for separado de alguma par- ³
			//³cela deve-se considera esta separacao para calcular-se a me-  ³
			//³lhor propor‡ao possivel para a base da parcela. 				 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nMaxFor := Len(aBaseSE1)
				For nCntFor := 1 To nMaxFor
					nProp   := 0
					nVlrFat := xMoeda(SF1->F1_VALBRUT,SE1->E1_MOEDA,1,SE1->E1_EMISSAO)
					nVlrTit := SE1->E1_VLCRUZ
					dbSelectArea("SA3")
					dbSetOrder(1)
					MsSeek(xFilial()+aBaseSE1[nCntFor,1])
					If ( nVlrTit > 0 )
						nProp := nVlrFat / nVlrTit
					Else
						nProp := 0
					EndIf
					If (nProp != 0 )
						nBaseSE1 := NoRound(aBaseSE1[nCntFor,2]/nProp,nDecimal)
						nBaseEmis:= NoRound(aBaseSE1[nCntFor,3]/nProp,nDecimal)
						nBaseBaix:= NoRound(aBaseSE1[nCntFor,4]/nProp,nDecimal)
						nVlrEmis := Round(aBaseSE1[nCntFor,5]/nProp,nDecimal)
						nVlrBaix := Round(aBaseSE1[nCntFor,6]/nProp,nDecimal)
					Else
						nBaseSE1 := 0
						nBaseEmis:= 0
						nBaseBaix:= 0
						nVlrEmis := 0
						nVlrBaix := 0
					EndIf
					If ( SE1->E1_PARCELA $ cPrimParc .And. nBaseSE1 != 0 )
					//--> Calculo da Proporcao para a Base da Comissao
						nBaseDif := Round(nBaseSE1 * nProp,nDecimal)
						nBaseDif := aBaseSE1[nCntFor,2]-nBaseDif
						aBaseSE1[nCntFor,2] := nBaseSE1+nBaseDif
					//--> Calculo da Proporcao para a Base da Comissao pela Emissao

						nBaseDif := Round(nBaseEmis * nProp,nDecimal)
						nBaseDif := aBaseSE1[nCntFor,3]-nBaseDif
						aBaseSE1[nCntFor,3] := nBaseEmis+nBaseDif
					//--> Calculo da Proporcao para a Base da Comissao pela Baixa

						nBaseDif := Round(nBaseBaix * nProp,nDecimal)
						nBaseDif := aBaseSE1[nCntFor,4]-nBaseDif
						aBaseSE1[nCntFor,4] := nBaseBaix+nBaseDif
					//--> Calculo da Proporcao para o Valor da Comissao pela Emissao

						nBaseDif := Round(nVlrEmis * nProp,nDecimal)
						nBaseDif := aBaseSE1[nCntFor,5]-nBaseDif
						aBaseSE1[nCntFor,5] := nVlrEmis+nBaseDif
					//--> Calculo da Proporcao para o Valor da Comissao pela Baixa

						nBaseDif := Round(nVlrBaix * nProp,nDecimal)
						nBaseDif := aBaseSE1[nCntFor,6]-nBaseDif
						aBaseSE1[nCntFor,6] := nVlrBaix+nBaseDif
					Else
						aBaseSE1[nCntFor,2] := nBaseSE1
						aBaseSE1[nCntFor,3] := nBaseEmis
						aBaseSE1[nCntFor,4] := nBaseBaix
						aBaseSE1[nCntFor,5] := nVlrEmis
						aBaseSE1[nCntFor,6] := nVlrBaix
					EndIf
				Next nCntFor
			Else
				If ( lQuery .And. Select(cAliasDev)<>0 )
					dbSelectArea(cAliasDev)
					dbCloseArea()
					dbSelectArea("SE1")
				EndIf
			EndIf
		Endif
		If ( lQuery .And. Select(cAliasDev)<>0 )
			dbSelectArea(cAliasDev)
			dbCloseArea()
			dbSelectArea("SE1")
		EndIf
		If ( lQuery )
			dbSelectArea(cAliasSD1)
			dbCloseArea()
			dbSelectArea("SD1")
		EndIf
	Else
		If Empty(nRegDevol)
			If ( Empty(aBaseSE1) .And. lRefaz )
				cVend := "1"
				For nCntFor := 1 To nVend

					dbGoto(nRecnoOrig) // pra caso o titulo parta de uma liquidação
					cVendedor := SE1->(FieldGet(SE1->(FieldPos("E1_VEND"+cVend))))
					nPerComis := SE1->(FieldGet(SE1->(FieldPos("E1_COMIS"+cVend))))
					dbGoto(nRegistro) // volta ao recno original

					dbSelectArea("SA3")
					dbSetOrder(1)
					MsSeek(xFilial()+cVendedor)
					If SE1->(FieldPos("E1_ALEMIS"+cVend))<>0//Nao criar no dicionario padrao
						nAlEmissao := SE1->(FieldGet(FieldPos("E1_ALEMIS"+cVend)))
					Else
						nAlEmissao := SA3->A3_ALEMISS
					EndIf
					If SE1->(FieldPos("E1_ALBAIX"+cVend))<>0//Nao criar no dicionario padrao
						nAlBaixa := SE1->(FieldGet(FieldPos("E1_ALBAIX"+cVend)))
					Else
						nAlBaixa := SA3->A3_ALBAIXA
					EndIf

					If ( !Empty(cVendedor) )
						If Alltrim(SE1->E1_Hist) <> "VENDA EM DINHEIRO"	 .AND. !"LOJA"$SE1->E1_ORIGEM		 //Adriano - Comissoes
							nBaseEmis := Round(SE1->E1_VLCRUZ*(nAlEmissao/100),nDecimal)
							nBaseBaix := Round(SE1->E1_VLCRUZ*(nAlBaixa/100),nDecimal)
						Else
							nBaseEmis := SE1->(FieldGet(SE1->(FieldPos("E1_BASCOM"+cVend))))
							nBaseBaix := nBaseEmis
							If "LOJA"$SE1->E1_ORIGEM .AND. Alltrim(SE1->E1_Hist) <> "VENDA EM DINHEIRO"

							//Abate o percentual da administradora proporcionalmente
								If cMvComisCC <> "N"
									nBaseCC := 1-((SE1->E1_VLRREAL - SE1->E1_VLCRUZ) / SE1->E1_VLRREAL)
								Else
									nBaseCC	:= 1
								Endif

								If nAlEmissao > 0
									nBaseEmis := Round( (nBaseEmis * nBaseCC) * ( nAlEmissao / 100 ), nDecimal )
									nBaseBaix := 0
								ElseIf nAlBaixa > 0
									nBaseEmis := 0
									nBaseBaix := Round( (nBaseBaix * nBaseCC) * ( nAlBaixa / 100 ), nDecimal )
								Endif
							Endif
						Endif
						If SuperGetMv("MV_COMISIR") == "N" .And. lRecIRRF
							nBaseEmis -= Round(SE1->E1_IRRF*(nAlEmissao/100),nDecimal)
							nBaseBaix -= Round(SE1->E1_IRRF*(nAlBaixa/100),nDecimal)
						Endif
						If GetNewPar("MV_COMIINS","N") == "N"
							nBaseEmis -= Round(SE1->E1_INSS*(nAlEmissao/100),nDecimal)
							nBaseBaix -= Round(SE1->E1_INSS*(nAlBaixa/100),nDecimal)
						EndIf
						If  lPccBxCr
							If 	SE5->E5_PRETPIS	==	" "
								nPis		:= SE5->E5_VRETPIS
							Else
								nPis		:=	0
							EndIf
							If 	SE5->E5_PRETCOF	==	" "
								nCofins	:= SE5->E5_VRETCOF
							Else
								nCofins	:= 0
							EndIf
							If 	SE5->E5_PRETCSL	==	" "
								nCsll		:= SE5->E5_VRETCSL
							Else
								nCsll		:=	0
							EndIf
						Else
							nPis		:= SE1->E1_PIS
							nCofins	:= SE1->E1_COFINS
							nCsll  	:= SE1->E1_CSLL
						Endif
						If GetNewPar("MV_COMIPIS","N") == "N"
							nBaseEmis -= Round(SE1->E1_PIS*(nAlEmissao/100),nDecimal)
							nBaseBaix -= Round(nPis*(nAlBaixa/100),nDecimal)
						EndIf
						If GetNewPar("MV_COMICOF","N") == "N"
							nBaseEmis -= Round(SE1->E1_COFINS*(nAlEmissao/100),nDecimal)
							nBaseBaix -= Round(nCofins*(nAlBaixa/100),nDecimal)
						EndIf
						If GetNewPar("MV_COMICSL","N") == "N"
							nBaseEmis -= Round(SE1->E1_CSLL*(nAlEmissao/100),nDecimal)
							nBaseBaix -= Round(nCsll*(nAlBaixa/100),nDecimal)
						EndIf
						If ( SA3->A3_ISS <> "S" )
							nBaseEmis -= Round(SE1->E1_ISS*(nAlEmissao/100),nDecimal)
							nBaseBaix -= Round(SE1->E1_ISS*(nAlBaixa/100),nDecimal)
						EndIf

						nVlrEmis  := Round(nBaseEmis * (nPerComis/100),nDecimal)
						nVlrBaix  := Round(nBaseBaix * (nPerComis/100),nDecimal)
						aadd(aBaseSE1,{ cVendedor,;
							SE1->E1_VLCRUZ,;
							nBaseEmis,;
							nBaseBaix,;
							nVlrEmis,;
							nVlrBaix,;
							nPerComis})
					EndIf
					cVend := Soma1(cVend,1)
				Next nCntFor
			EndIf
			If ( lGrava .And. lRefaz )
				dbSelectArea("SE1")
				RecLock("SE1")
				cVend := "1"
				For nCntFor := 1 To Len(aBaseSE1)
					dbSelectArea("SA3")
					dbSetOrder(1)
					MsSeek(xFilial()+aBaseSE1[nCntFor,1])
					dbSelectArea("SE1")
					If ( FieldGet(FieldPos("E1_VEND"+cVend)) == aBaseSE1[nCntFor,1] )
						FieldPut(FieldPos("E1_BASCOM"+cVend),aBaseSE1[nCntFor,2])
						If ( aBaseSE1[nCntFor,4] != 0 )
							FieldPut(FieldPos("E1_COMIS"+cVend),aBaseSE1[nCntFor,7])
						Endif
						FieldPut(FieldPos("E1_VALCOM"+cVend),aBaseSE1[nCntFor,5])
					Else
						If ( SE1->(FieldPos("E1_VEND"+cVend)) != 0 )
							nCntFor--
						EndIf
					EndIf
					cVend := Soma1(cVend,1)
				Next nCntFor
				MsUnlock()
			EndIf
			If ( Empty(aBaseSE1) )
				cVend := "1"
				For nCntFor := 1 To nVend
					cVendedor := SE1->(FieldGet(SE1->(FieldPos("E1_VEND"+cVend))))
					nPerComis := SE1->(FieldGet(SE1->(FieldPos("E1_COMIS"+cVend))))
					dbSelectArea("SA3")
					dbSetOrder(1)
					MsSeek(xFilial()+cVendedor)
					If ( !Empty(cVendedor) )
					//Trazer a base gravada na emissao, substituindo o zero, para evitar valores negativos
						If SA3->A3_ALBAIXA > 0
							nBaseSE1  := SE1->(FieldGet(FieldPos("E1_BASCOM" + "1"))) * (SA3->A3_ALBAIXA / 100)
							nBaseEmis := SE1->(FieldGet(FieldPos("E1_BASCOM" + "1"))) - (SE1->(FieldGet(FieldPos("E1_BASCOM" + "1"))) * (SA3->A3_ALBAIXA / 100))
							nBaseBaix := SE1->(FieldGet(SE1->(FieldPos("E1_BASCOM"+cVend)))) * (SA3->A3_ALBAIXA / 100)
							nVlrEmis  := SE1->(FieldGet(FieldPos("E1_BASCOM" + "1"))) - (SE1->(FieldGet(FieldPos("E1_BASCOM" + "1"))) * (SA3->A3_ALBAIXA / 100))
						Else
							nBaseSE1  := SE1->(FieldGet(FieldPos("E1_BASCOM" + "1")))
							nBaseEmis := 0
							nBaseBaix := SE1->(FieldGet(SE1->(FieldPos("E1_BASCOM"+cVend))))
							nVlrEmis  := 0
						EndIf
					// --> Quando o percentual da comissao estiver no produto o sistema
					// --> arredonda o percentual se for pago na baixa, caso haja muita
					// --> distorcao de valores deve-se alterar o numero de casas
					// --> decimais do campo E1_COMIS1..E1_COMIS(n)
						If  lPccBxCr
							If SE5->E5_PRETPIS	==	" "
								nPis		:= SE5->E5_VRETPIS
							Else
								nPis		:=	0
							EndIf
							If SE5->E5_PRETCOF	==	" "
								nCofins	:= SE5->E5_VRETCOF
							Else
								nCofins	:= 0
							EndIf
							If SE5->E5_PRETCSL	==	" "
								nCsll		:= SE5->E5_VRETCSL
							Else
								nCsll		:=	0
							EndIf
						Else
							nPis			:= SE1->E1_PIS
							nCofins		:= SE1->E1_COFINS
							nCsll		:= SE1->E1_CSLL
						Endif
						If SuperGetMv("MV_COMISIR") == "N" .and. !lMata460
							nBaseSE1 -= SE1->E1_IRRF
							nBaseBaix -= SE1->E1_IRRF
						Endif
						If GetNewPar("MV_COMIINS","N") == "N" .and. !lMata460
							nBaseSE1 -= SE1->E1_INSS
							nBaseBaix -= SE1->E1_INSS
						EndIf
						If GetNewPar("MV_COMIPIS","N") == "N" .and. !lMata460
							nBaseSE1 -= SE1->E1_PIS
							nBaseBaix -= nPis
						EndIf
						If GetNewPar("MV_COMICOF","N") == "N" .and. !lMata460
							nBaseSE1 -= SE1->E1_COFINS
							nBaseBaix -= nCofins
						EndIf
						If GetNewPar("MV_COMICSL","N") == "N" .and. !lMata460
							nBaseSE1 -= SE1->E1_CSLL
							nBaseBaix -= nCsll
						EndIf

						nVlrBaix  := nBaseBaix * (nPerComis/100)
					//No segundo elemento, a variavel nBaseSE1 foi substituida pelo campo SE1->E1_VLCRUZ (base bruta), pois apenas passava valores
					//negativos
						aadd(aBaseSE1,{ cVendedor,;
							SE1->E1_VLCRUZ,;
							nBaseEmis,;
							nBaseBaix,;
							nVlrEmis,;
							nVlrBaix,;
							nPerComis })
					EndIf
					cVend := Soma1(cVend,1)
				Next nCntFor
			EndIf
		EndIf
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a Integridade dos dados de Entrada                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RestArea(aAreaSE1)
	RestArea(aAreaSE4)
	RestArea(aAreaSF1)
	RestArea(aAreaSF2)
	RestArea(aAreaSF4)
	RestArea(aAreaSD1)
	RestArea(aAreaSD2)
	RestArea(aAreaSA3)
	RestArea(aArea)

Return(aBaseSE1)
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Sispag   º Autor ³			           ºData  ³  06/04/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para criar string com dados para pagamento de       º±±
±±º          ³ tributos sem código de barras                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ KDL                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
*********************************************************************************
User Function INCSISPAG( cTipo , cAcao, nTam ) //|Incrementa Sequencial Tipo: L=Lote, R=Registro , Acao: '+' -> Soma, '=' -> Apresenta, '-' -> Subtrai, '0' -> Retorna o proximo e Zera o Valor, # -> Zera e Retorna um Espaço, * -> Rrtorna Total de Registros
*********************************************************************************

	Local cValor := '0000'

	If  ( Type( "_nNumLot" ) == 'U')

		Public _nNumLot := 0
		Public _nNumReg := 0
		Public _nNumGer := 0

	EndIf

//| Define Variavel a Ser Utilizada
	cVar := ''

	If ( cTipo = 'L' )// Lote
		cVar := '_nNumLot'

	ElseIf ( cTipo = 'R' )//Registro
		cVar := '_nNumReg'

		//| Geral...
		_nNumGer := _nNumGer + 1

	Else
		Return(cValor) //| Parametro inválido sai da rotina
	EndIf

//| Executa Acao Conforme Parametro

	If ( cAcao == '+')
		&cVar. := &cVar. + 1
		cValor := StrZero( &cVar. , nTam )

	ElseIf  ( cAcao == '-')
		&cVar. := &cVar. - 1
		cValor := StrZero( &cVar. , nTam )

	ElseIf  ( cAcao == '=')
		&cVar. := &cVar.
		cValor := StrZero( &cVar. , nTam )

	ElseIf  ( cAcao == '0')
		&cVar. 	  := 0
		_nNumGer := 0
		cValor := StrZero( &cVar. , nTam )

	ElseIf  ( cAcao == '#')
		&cVar. := 0
		cValor := " "

	ElseIf  ( cAcao == '*')
		cValor := StrZero( &cVar. + 2, nTam )

	ElseIf  ( cAcao == 'G') // Geral Final
		cValor 		:= StrZero( _nNumGer + 1, nTam )

	EndIf

Return(cValor)
*********************************************************************************
User Function SUMSISPAG( cTipo , nValor , nTam )
*********************************************************************************

	If  ( Type( "_nTotLot" ) == 'U')
		Public _nTotLot := 0

	EndIf

	_nTotLot := _nTotLot + nValor

	If ( cTipo == 'R' ) //Lote
		nValor := nValor

	ElseIf ( cTipo == 'L' ) //Lote
		nValor := _nTotLot

	ElseIf ( cTipo == 'H' ) //H -> Header ZERA A SOMA
		_nTotLot := 0
		Return("")
	EndIf

Return( StrZero(nValor , nTam ) )
*********************************************************************************
User Function MOD11( _cCodBar , cTpRet)// Calculo Modulo 11 Modelo Itau...Tipo Retorno => C=Codigo ou D=Digito
*********************************************************************************
	Local cCodBar := Alltrim(_cCodBar)
	Local nTamCod 	:= Len(cCodBar)
	Local nFator 	:= 1
	Local nTotal 	:= 0
	Local nResto 	:= 0
	Local nPula   	:= 5 //Iif( substr(cCodBar,3,1) $ '6/7', 4 , 5 ) // Concessionárias pula a pos 4 demais a 5

	//|Consistencia
	If nTamCod == 0
	Return("0")
	EndIf

	//| Soma das Multiplicacoes
	For  nI := nTamCod To 1 Step -1

	//|Pula DV
		If (nI == nPula )

		//Alert("Entrou")
		Else

			//|Fator de Multiplicacao 2.3.4.5...8.9..2.3...
			If ( nFator == 9 )
				nFator := 2
			Else
				nFator += 1
			EndIf

	 		//|Multiplica
			nTotal += Val(Substr(cCodBar,nI,1)) * nFator

			//Alert(cValtoChar(nI)+":"+Substr(cCodBar,nI,1)+" * "+CvALTOcHAR(nFator))

		EndIf

	Next

	nResto := ( nTotal % 11 )

	nDigito := 11 - nResto

	If cValToChar(nDigito) $ "0/10/11" // Ajuste
		nDigito := 1
	EndIf


	If ( cTpRet == 'C' )//
		cCodBar := Substr(cCodBar,1,nPula-1)+cValtoChar(nDigito)+Substr(cCodBar,nPula+1,nTamCod-nPula)
	Else
		cCodBar := cValtoChar(nDigito)
	EndIf

Return(cCodBar)
*********************************************************************************
User Function MOD10( _cCodBar , cTpRet )// Calculo Modulo 11 Modelo Itau ... Tipo Retorno => C=Codigo ou D=Digito
*********************************************************************************
	Local cCodBar := Alltrim(_cCodBar)
	Local nTamCod 	:= Len(cCodBar)
	Local nFator 	:= 1
	Local nTotal 	:= 0
	Local nResto 	:= 0
	Local nPula   	:= Iif( substr(cCodBar,3,1) $ '6/7',4,5) // Concessionárias pula a pos 4 demais a 5
	Local nMulti  	:= 0 // Resultado da Multiplicacao

	//Consistencia
	If nTamCod == 0
	Return("0")
	EndIf

	//| Soma das Multiplicacoes
	For  nI := nTamCod To 1 Step -1

		//| Pula DV
		If (nI == nPula )
			Loop
		EndIf

		//| Fator de Multiplicacao 2.1.2.1.2.1.2.1
		If ( nFator == 2 )
			nFator := 1
		Else
			nFator += 1
		EndIf

	 	//|Multiplica
		nMulti := Val(Substr(cCodBar,nI,1)) * nFator

		If ( nMulti > 9 )
			nTotal += Val( Substr( cValTochar( nMulti ),1,1 ))
			nTotal += Val( Substr( cValTochar( nMulti ),2,1 ))

		Else
			nTotal += nMulti

		EndIf

	Next

	nResto := ( nTotal % 10 )

	nDigito := 10 - nResto

	If cValToChar(nDigito) == "10" // Ajuste
		nDigito := 0
	EndIf

	If cTpRet == "C" // cODIGO
		cCodBar := Substr(cCodBar,1,nPula-1)+cValtoChar(nDigito)+Substr(cCodBar,nPula+1,nTamCod-nPula)
	Else
		cCodBar := cValtoChar(nDigito)
	EndIf

Return(cCodBar)
/*
*****************************************************************************
User Function TRIBUTOS()
*****************************************************************************

	Local  cString1	:= ""
	Local  cString2	:= ""
	Local  cString3	:= ""
	Local  cString4	:= ""
	Local  cString5	:= ""
	Local  cTributo1 	:= '  ' //AllTrim( SE2->E2_XGPS01  )
	Local  cTributo2 	:= '02' //AllTrim( SE2->E2_XDARF01 )
	Local  cTributo3 	:= '  ' //AllTrim( SE2->E2_XGARE01 )
	Local  cTributo4 	:= '  ' //AllTrim( SE2->E2_XIPVA01 )
	Local  cTributo5 	:= '  ' //AllTrim( SE2->E2_XFGTS01 )


	IF !Empty(cTributo1) .AND. cTributo1 == '01'

		cString1 :=  U_DADOSGPS()
	Return(cString1)

	ElseIf !Empty(cTributo2) .AND. cTributo2 == '02'

		cString2 := U_DADOSDARF()
	Return(cString2)

	ElseIf !Empty(cTributo3) .AND. cTributo3 == '05'

		cString3 := U_DADOSGARE()
	Return(cString3)

	ElseIf !Empty(cTributo4) .AND. cTributo4 == '07' .OR. cTributo4 == '08'

		cString4 := U_DADOSIPVA()
	Return(cString4)

	ElseIf !Empty(cTributo5) .AND. cTributo5 == '11'

		cString5 := U_DADOSFGTS()
	Return(cString5)

	EndIf


Return()
*****************************************************************************
User Function DADOSGPS() //Rotina para criar a string com dados para pagamento de GPS sem código de barras
*****************************************************************************

	Local  cRetGPS  := ""

	cRetGPS := SUBSTR(Alltrim(SE2->E2_XGPS01),1,2 )		//IDENTIFICACAO DO TRIBUTO (2)
	cRetGPS += SUBSTR(Alltrim(SE2->E2_XGPS02),1,4 )		//CODIGO DE PAGTO (4)
	cRetGPS += SUBSTR(Alltrim(SE2->E2_XGPS03),1,6 )		//COMPETENCIA (6)
	cRetGPS += SUBSTR(Alltrim(SE2->E2_XGPS04),1,14)		//INSCRICAO NUMERO - CNPJ OU CPF (14)
	cRetGPS += STRZERO((SE2->E2_VALOR)*100,14)				//VALOR PRINCIPAL (14)
	cRetGPS += STRZERO((SE2->E2_SDACRES)*100,14)			//VALOR ENTIDADES (14)
	cRetGPS += STRZERO((SE2->E2_MULTA + SE2->E2_JUROS )*100,14)		//VALOR DA MULTA + JUROS + ATM(14)
	cRetGPS += STRZERO(((SE2->E2_VALOR + SE2->E2_MULTA + SE2->E2_JUROS + SE2->E2_SDACRES )-(SE2->E2_DESCONT + SE2->E2_SDDECRE))*100,14)  //VALOR TOTAL (14)
	cRetGPS += GRAVADATA(SE2->E2_VENCREA,.F.,5)			//DATA PAGAMENTO (8)
	cRetGPS += SPACE(50)										//BRANCOS (50)
	cRetGPS += SUBSTR(SM0->M0_NOME,1,30)					//NOME DO CONTRIBUINTE (30)


Return(cRetGPS)

*********************************************************************************
User Function DADOSDARF() //| Rotina para criar a string com dados para pagamento de DARF sem código de barras
*********************************************************************************

	Local  cRetDARF  := ""


	cRetDARF := SUBSTR(Alltrim(SE2->E2_XDARF01),1,2)		// IDENTIFICACAO DO TRIBUTO (02)
	cRetDARF += SUBSTR(Alltrim(SE2->E2_CODRET),1,4) //SUBSTR(Alltrim(SE2->E2_XDARF02),1,4)		// CODIGO DA RECEITA (04)
	cRetDARF += "2"											// TIPO DE INSCRICAO DO CONTRIBUINTE 1=CPF, 2=CNPJ  (1)
	cRetDARF += SUBSTR(SM0->M0_CGC,1,14)					// INSCRICAO NUMERO - CNPJ OU CPF (14)
	cRetDARF += GRAVADATA(SE2->E2_VENCREA,.F.,5)			// PERIODO DE APURACAO (8)
	cRetDARF += IIF(Empty(' '),SPACE(17),(SUBST(Alltrim(SE2->E2_XDARF04),1,17)))//NUMERO DE REFERENCIA (17)
	cRetDARF += STRZERO((SE2->E2_VALOR)*100,14)			// VALOR PRINCIPAL (14)
	cRetDARF += STRZERO((SE2->E2_MULTA)*100,14)			// VALOR DA MULTA (14)
	cRetDARF += STRZERO((SE2->E2_JUROS + SE2->E2_SDACRES)*100,14)//VALOR DOS JUROS/ENCARGOS (14)
	cRetDARF += STRZERO(((SE2->E2_VALOR + SE2->E2_MULTA + SE2->E2_JUROS + SE2->E2_SDACRES )-(SE2->E2_DESCONT + SE2->E2_SDDECRE))*100,14)//VALOR TOTAL (14)
	cRetDARF += GRAVADATA(SE2->E2_VENCTO,.F.,5)			// DATA VENCIMENTO (8)
	cRetDARF += GRAVADATA(SE2->E2_VENCREA,.F.,5)		    // DATA PAGAMENTO (8)
	cRetDARF += SPACE(30)										// BRANCOS (30)
	cRetDARF += SUBSTR(SM0->M0_NOME,1,30)					// NOME DO CONTRIBUINTE (30)

Return(cRetDARF)

*********************************************************************************
User Function DADOSGARE() //| Rotina para criar a string com dados para pagamento de GARE sem código de barras
*********************************************************************************

	Local  cRetGARE  := ""

	cRetGARE := SUBSTR(Alltrim(SE2->E2_XGARE01),1,2)	//IDENTIFICACAO DO TRIBUTO (02)
	cRetGARE += SUBSTR(Alltrim(SE2->E2_XGARE02),1,4)	//CODIGO DA RECEITA (04)
	cRetGARE += "2"					   					//TIPO DE INSCRICAO DO CONTRIBUINTE 1=CPF, 2=CNPJ  (01)
	cRetGARE += SUBSTR(SM0->M0_CGC,1,14)				//INSCRICAO NUMERO - CNPJ OU CPF (14)
	cRetGARE += SUBSTR(SM0->M0_INSC,1,12)				//INSCRICAO ESTADUAL - CNPJ OU CPF (12)
	cRetGARE += SPACE(13)									//BRANCOS (13)
	cRetGARE += SUBSTR(Alltrim(SE2->E2_XGARE03),1,6)	//REFERENCIA (06)
	cRetGARE += SPACE(13)									//BRANCOS (13)
	cRetGARE += STRZERO((SE2->E2_VALOR)*100,14)		//VALOR RECEITA (14)
	cRetGARE += STRZERO((SE2->E2_JUROS + SE2->E2_SDACRES)*100,14)//VALOR DOS JUROS/ENCARGOS (14)
	cRetGARE += STRZERO((SE2->E2_MULTA)*100,14)		//VALOR DA MULTA (14)
	cRetGARE += STRZERO(((SE2->E2_VALOR + SE2->E2_MULTA + SE2->E2_JUROS + SE2->E2_SDACRES )-(SE2->E2_DESCONT + SE2->E2_SDDECRE))*100,14)//VALOR DO PAGAMENTO (14)
	cRetGARE += GRAVADATA(SE2->E2_VENCTO,.F.,5)		//DATA VENCIMENTO (8)
	cRetGARE += GRAVADATA(SE2->E2_VENCREA,.F.,5)		//DATA PAGAMENTO (8)
	cRetGARE += SPACE(11)									//BRANCOS (11)
	cRetGARE += SUBSTR(SM0->M0_NOME,1,30)				//NOME DO CONTRIBUINTE (30)

Return(cRetGARE)

*********************************************************************************
User Function DADOSIPVA() //| Rotina para criar a string com dados para pagamento de IPVA sem código de barras
*********************************************************************************

	Local  cRetIPVA  := ""

	//POSICIONA NO FORNECEDOR
	//=======================
	SA2->(DBSETORDER(01))
	SA2->(DBSEEK(xFILIAL("SA2")+SE2->(E2_FORNECE+E2_LOJA)))

	cRetIPVA := SUBSTR(Alltrim(SE2->E2_XIPVA01),1,2)		//IDENTIFICACAO DO TRIBUTO (02)
	cRetIPVA += SPACE(04)										//BRANCOS
	cRetIPVA += IIF(SA2->A2_TIPO == "J", "2", "1")       	//TIPO DE INSCRIÇÃO DO CONTRIBUINTE (1-CPF / 2-CNPJ)
	cRetIPVA += STRZERO(VAL(SA2->A2_CGC),14)             	//CPF OU CNPJ DO CONTRIBUINTE
	cRetIPVA += SUBSTR(DTOS(dDATABASE),1,4)	            //ANO BASE
	cRetIPVA += PADR(SE2->E2_XIPVA02,09)					//E2_XRENAVA                    						// CODIGO RENEVAN
	cRetIPVA += SE2->E2_XIPVA03 								//E2_XUFRENA													// UF RENEVAN
	cRetIPVA += IIF(EMPTY(SE2->E2_XIPVA04),PADR(SA2->A2_COD_MUN,05),PADR(SE2->E2_XIPVA04,05))	// COD.MUNICIPIO RENEVAN  -SE2->E2_XMUNREN
	cRetIPVA += PADR(SE2->E2_XIPVA05,07)					//SE2->E2_XPLACA				     					// PLACA DO VEICULO
	cRetIPVA += SE2->E2_XIPVA06								//E2_XOPCPAG													// OPCAO DE PAGAMENTO
	cRetIPVA += STRZERO(INT((SE2->E2_SALDO+SE2->E2_ACRESC)*100),14)     						// VALOR DO IPVA + MULTA + JUROS
	cRetIPVA += STRZERO(INT(SE2->E2_DECRESC*100),14)		//VALOR DO DESCONTO
	cRetIPVA += STRZERO(INT(((SE2->E2_SALDO+SE2->E2_ACRESC)-SE2->E2_DECRESC)*100),14)			// VALOR DO PAGAMENTO
	cRetIPVA += GRAVADATA(SE2->E2_VENCREA,.F.,5) 			//DATA DE VENCIMENTO
	cRetIPVA += GRAVADATA(SE2->E2_VENCREA,.F.,5) 			//DATA DE PAGAMENTO
	cRetIPVA += SPACE(41) 								    //COMPLEMENTO DE REGISTRO
	cRetIPVA += SUBSTR(SA2->A2_NOME,1,30)					//NOME DO CONTRIBUINTE

Return(cRetIPVA)

*********************************************************************************
User Function DADOSFGTS() //| Rotina para criar a string com dados para pagamento de FGTS sem código de barras
*********************************************************************************

	Local   cRetFGST :=""

	cRetFGST := SUBSTR(Alltrim(SE2->E2_XFGTS01),1,2)	// IDENTIFICACAO DO TRIBUTO (02)"11"
	cRetFGST += SubStr(SE2->E2_XFGTS02,1,4)			// Código da Receita
	cRetFGST += "2"										// TIPO DE INSCRIÇÃO DO CONTRIBUINTE (1-CPF / 2-CNPJ)
	cRetFGST += StrZero(Val(SM0->M0_CGC),14)          	// CPF OU CNPJ DO CONTRIBUINTE
	cRetFGST += AllTrim(SE2->E2_XFGTS03)               	// CODIGO DE BARRAS (LINHA DIGITAVEL)	(*criar campo*)
	cRetFGST += StrZero(Val(SE2->E2_XFGTS04),16) 		// Identificador FGTS
	cRetFGST += StrZero(Val(SE2->E2_XFGTS05),9)   		// Lacre de Conectividade Social
	cRetFGST += StrZero(Val(SE2->E2_XFGTS06),2)  		// Digito do Lacre
	cRetFGST += SubStr(SM0->M0_NOMECOM,1,30)          	// NOME DO CONTRIBUINTE
	cRetFGST += GravaData(SE2->E2_VENCREA,.F.,5)     	// DATA DO PAGAMENTO
	cRetFGST += StrZero(SE2->E2_SALDO*100,14)        	// VALOR DO PAGAMENTO
	cRetFGST += Space(30)                               	// COMPLEMENTO DE REGISTRO


Return(cRetFGST)
*********************************************************************************
User Function SOMAJM() // Rotina para criar a string com dados de juros e multa
*********************************************************************************

	Local  cReturn2  := ""
	Local  nValcamp  := 0

	nValcamp := (SE2->E2_MULTA + SE2->E2_JUROS + SE2->E2_SDACRES)

	cReturn2 += STRZERO(nValCamp*100,14)

Return(cReturn2)

*********************************************************************************
User Function SOMATOTAL() //|Rotina para criar a string com dados de valor total
*********************************************************************************

	Local  cReturn1  := ""

	cReturn1 := STRZERO(((SE2->E2_VALOR + SE2->E2_MULTA + SE2->E2_JUROS + SE2->E2_SDACRES )-(SE2->E2_DESCONT + SE2->E2_SDDECRE))*100,14)

Return(cReturn1)
*/

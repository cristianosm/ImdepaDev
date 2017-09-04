#Include 'Totvs.ch'
#Include 'common.ch'
#Include "RPTDEF.CH"
#Include "FWPrintSetup.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMDR120   ºAutor  ³Luciano Correa      º Data ³  15/10/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Emissão do boleto de cobrança com codigo de barras, nosso  º±±
±±º          ³ numero e linha digitavel conforme manual do Banco do Brasilº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10 FATURAMENTO/FINANCEIRO IMDEPA                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

*********************************************************************
User Function ImdR120(_xPar)//
*********************************************************************
	Private aRecNo 			:= {} 		//| Recnos dos titulos que devem ser Impressos
	Private lPriVia			:= .F. 	//| Verdadeiro se for Primeira Via
	Private cCodBanc		:= ""		//| Codigo do Banco
	Private cChave			:= ""		//| Chave de Pesquisa (Cod Banco + Agencia + Conta Corrente + SubConta)
	Private aRetPFile		:= {}		//| Retorna o Caminho do Arquivo Local[1] e no system [2] para ser anexado posteriormente

/// Parametros Funcao FWMsPrinter..
	Default _xPar			:= ""

	Private lehNfs			:= Iif( ValType(_xPar)=="O" , .T. , .F. ) // OBJETO
	Private xPar			:= _xPar

	Private cFilePrintert	:= CriaTrab( ,.F.) + ".pdf"
	Private nDevice			:= IMP_PDF
	Private lAdjustToLegacy	:= .T.
	Private cPathInServer	:= "\system\pdf\"
	Private cLocalPath		:= "C:\MP11\"
	Private lDisabeSetup	:= .T.
	Private lTReport		:= .F.
	Private cPrinter		:=  ""
	Private lServer			:= .F.
	Private lPDFAsPNG		:= .T.
	Private lRaw			:= .F.
	Private lViewPDF		:= .F.
	Private nQtdCopy		:= NIL
	Private lSetView		:= .F.

	//alert("lehNfs ? "+cValToChar(lehNfs)+"  ValType('xPar') : "+ValType("xPar"))


	If !ExistDir(cLocalPath) 	//| Verifica Existencia do Diretorio MP10
		MakeDir(cLocalPath) 		//| Cria o Diretorio
	EndIf

	If FUNNAME() == "GNFEIMD" .OR. FUNNAME() == "SPEDNFE" //| Ponto de Geracao da NF-Saida para Primeira Via de Boletos
		If ValImpBol() //| Valida Geração de 1 via de Boleto no Faturamento
			lSetView		:= .T.
			OkProc()	//| Processamento do Boleto
		EndIf

	Else//| Emissao Segunda Via
		If !Empty( xPar )
			aRecNo := xPar
			OkProc()	//| Processamento do Boleto

		EndIf

	Endif

Return(aRetPFile)
*********************************************************************
Static Function ValImpBol()//| Valida Geração de 1 via de Boleto
*********************************************************************

	If GetMv("MV_HBOLFAT")  //| Verifica se esta Habilitado o Boleto no Faturamento

		If SX5->(DbSeek(xFilial("SX5") + "U0" +SF2->F2_SERIE,.F.)) //| Contem as Series que estao aptas a Emitir Boleto

			If SE4->(DbSeek(xFilial("SE4") + SF2->F2_COND,.F.))

				If ( SE4->E4_PRINTBO == "S" )            //| Verifica se a Cond Pag. esta definida como "Imprime Boleto"

					DbSelectArea("SE1");DbSetOrder(1)
					If DbSeek(xFilial("SE1")+SF2->F2_SERIE+SF2->F2_DOC,.F.) .And. Empty(SE1->E1_BAIXA)
						//cCodBanc := "001"
						//cChave	 := "001" + "34150" + PadR("10387X",10," ") + "017"

                        ///JULIO JACOVENKO, em 02/10/2015
                        ///hbolfat passa a ser Santander
//						cCodBanc := "033"
//						cChave	 := "033" + "4841 " + PadR("13000049",10," ") + "001"

						cCodBanc := GetMv("IM_APREBAN")
						cChave	 := GetMv("IM_APRECHA")

						While !Eof() .And. SE1->E1_PREFIXO+SE1->E1_NUM == SF2->F2_SERIE+SF2->F2_DOC
							//Alert("Entrou !!!")
							AADD(aRecNo,Recno())
							//Alert("Entrou no aRecno:"+cValtoChar(Recno()))
							DbSelectArea("SE1")
							DbSkip()
						EndDo

						If Len(aRecNo) > 0
							lPriVia := .T.
						EndIf
					Endif
				Endif
			EndIf
		EndIf
	EndIf

Return(lPriVia)
*********************************************************************
Static Function OkProc()//| Processamento do Boleto
*********************************************************************
	Private oPrn
	Private aStru			:= {}
	Private cQuery			:= ""
	Private nValorTit 	:= {}
	Private lPrint			:= .F.
	Private cNomBanc 	:= ""
	Private cCodMoeB		:= ""
	Private cCedente		:= ""
	Private cAgencia		:= ""
	Private cContaCor	:= ""
	Private cEspecie		:= ""
	Private cNossoNum	:= ""
	Private cNumConv		:= ""
	Private cNNumImp		:= ""
	Private cNumDoc		:= ""
	Private cVencto		:= ""
	Private cEmissao		:= ""
	Private cValDoc 		:= ""
	Private cCnpj			:= ""
	Private cCnpjImd		:= "88.613.922/0012-78"
	Private cLinDig		:= ""
	Private cSacado		:= ""
	Private cEndSac		:= ""
	Private cMuESac		:= ""
	Private cAceite		:= ""
	Private cEspDoc		:= ""
	Private cCarteira	:= ""
	Private cCodBarra	:= ""
	Private	cLocalPag	:= ""
	Private cLogo			:= ""
	Private cAgeContI  := ""
	Private cInstrL1		:= ""
	Private cInstrL2		:= ""
	Private cInstrL3		:= ""
	Private cInstrL4		:= ""
	Private cInstrL5		:= ""
	Private cInstrL6		:= ""

	Private _cImpresPadrao := ""
	Private _clocalPadrao  := ""
	Private _cOrientPadrao := ""

	Private lPriPag		:= .T.

	ArqTrab() //| Monta Arquivo de Trabalho "SE1TMP"

	DbSelectArea("SE1TMP")
	While !EOF()

		If lPriVia
			//SA6->( dbSeek( xFilial( 'SA6' ) + "001" + "34150" + "10387X", .F. ) )

			//JULIO JACOVENKO, em 02/10/2015
			//passa a ser Santander
//			SA6->( dbSeek( xFilial( 'SA6' ) + "033" + "4841 " + "13000049", .F. ) )

			SA6->( dbSeek( xFilial( 'SA6' ) + cChave, .F. ) )

		Else
			cCodBanc	:= SE1TMP->E1_PORTADO
			cChave 		:= SE1TMP->E1_PORTADO + SE1TMP->E1_AGEDEP + SE1TMP->E1_CONTA

			SA6->( dbSeek( xFilial( 'SA6' ) + cChave, .F. ) )

			If cCodBanc == "001" //| Banco do Brasil Possui Diversar Carteiras
				If AT("BOLFAT",SE1TMP->E1_HIST) > 0
					cSubCon	:= "017"

				Else
					cSubCon	:= "031" //| Demais carteiras ...

				EndIf
				cChave 	+= cSubCon
			EndIf

			///SANTANDER
			If cCodBanc == "033" //| Banco do Brasil Possui Diversar Carteiras
				If AT("BOLFAT",SE1TMP->E1_HIST) > 0
					cSubCon	:= "001"
				Else
					cSubCon	:= "000" //| Demais carteiras ...
				EndIf
				cChave 	+= cSubCon
			EndIf


		EndIf

		CarVarBan() 	//| Carrega as Variaveis do Banco

		PrintBol() 		//| Gera Impressao do Boleto

		If lPriVia
			MarcaTitulo() 	//| Coloca Marca no Titulo para Identificar que foi gerado o Boleto

		EndIf

		DbSelectArea("SE1TMP")
		DbSkip()

	EndDo

	If !lPriVia
		
		PrintPdf()
		
		oPrn:Preview()

	EndIf

	DbSelectArea("SE1TMP");DbCloseArea()

Return()
*********************************************************************
Static Function ArqTrab()//| Monta Arquivo de Trabalho
*********************************************************************

	aStru := {}
	SM0->( dbSetOrder( 1 ) )
	SM0->( dbSeek( cEmpAnt + cFilAnt, .F. ) )
	SA1->( dbSetOrder( 1 ) )
	SA6->( dbSetOrder( 1 ) )

	aAdd( aStru, { "E1_FILIAL" 	, "C", "2", "0" 	} )
	aAdd( aStru, { "E1_PREFIXO"	, "C", "3", "0" 	} )
	aAdd( aStru, { "E1_NUM" 		, "C", "6", "0" 	} )
	aAdd( aStru, { "E1_PARCELA"	, "C", "1", "0" 	} )
	aAdd( aStru, { "E1_TIPO" 		, "C", "3", "0" 	} )
	aAdd( aStru, { "E1_CLIENTE"	, "C", "6", "0" 	} )
	aAdd( aStru, { "E1_LOJA" 		, "C", "2", "0" 	} )

	aAdd( aStru, { "E1_PORTADO"	, "C", "3", "0" 	} )
	aAdd( aStru, { "E1_AGEDEP" 	, "C", "5", "0" 	} )
	aAdd( aStru, { "E1_CONTA" 	, "C", "10", "0" } )
	aAdd( aStru, { "E1_HIST" 		, "C", "50", "0" } )

	cQuery := ""
	aEval( aStru, { | x | cQuery += "," + AllTrim( x[ 1 ] ) } )

	cRecNo := ""
	aEval( aRecNo, { | x | cRecNo += "," + AllTrim( Str( x ) ) } )


	cQuery := " SELECT " + SubStr( cQuery, 2 ) + ", R_E_C_N_O_ "
	cQuery += " FROM " + RetSqlName( 'SE1' ) + " SE1"
	cQuery += " WHERE SE1.R_E_C_N_O_ IN ( " + SubStr( cRecNo, 2 ) + ")"
	cQuery += " AND SE1.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO"

	U_ExecMySql(cQuery, 'SE1TMP', "Q" )

	For ni := 1 to Len( aStru )
		If aStru[ ni, 2 ] <> 'C'
			TCSetField( 'SE1TMP', aStru[ ni, 1 ], aStru[ ni, 2 ], aStru[ ni, 3 ], aStru[ ni, 4 ] )
		EndIf
	Next

	TCSetField( 'SE1TMP', 'R_E_C_N_O_', 'N', 9, 0 )

	DbSelectArea( 'SE1TMP' );DbGoTop()

Return()
*********************************************************************
Static Function CarVarBan()//| Carrega as Variaveis do Banco
*********************************************************************
	DbSelectArea("SE1");DbGoTo( SE1TMP->R_E_C_N_O_ )
	DbSelectArea("SA1");DbSeek( xFilial( 'SA1' ) + SE1->E1_CLIENTE + SE1->E1_LOJA, .F. )
	DbSelectArea("SEE");DbSetOrder(1)

//| Vareaveis Comum entre Todos Bancos
	DbSeek( xFilial( 'SEE' ) + cChave , .F. ) //| Exigi Cadastro do Parametro bancario

	cNumDoc		:= SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA
	cVencto		:= DtoC(SE1->E1_VENCTO)
	cEmissao	:= DtoC(SE1->E1_EMISSAO)

	cAceite     := "N"

	cSacado		:= SA1->A1_NOME
	cEndSac		:= Alltrim(SA1->A1_TLOGCOB) +" "+ Alltrim(SA1->A1_ENDCOB) +","+ Alltrim(Str(SA1->A1_NUMCOB)) +", "+ Alltrim(SA1->A1_COMPLCO)
	cMuESac		:= Alltrim(SA1->A1_BAIRROC) +" - "+ Alltrim(SA1->A1_MUNC) +" - "+ Alltrim(SA1->A1_ESTC) +" - "+ Alltrim(SA1->A1_CEPC)


	Do Case

	Case cCodBanc == "001" //| Banco do Brasil
		*******
//		DbSeek( xFilial( 'SEE' ) + cChave,.F. ) //| Exigi Cadastro do Parametro bancario

		cNumConv	:= Alltrim(SEE->EE_CODEMP)

		If lPriVia //| Primeira Via BolFat
			cNossoNum	:= BuscaNum()
			cNNumImp	:= cNumConv + cNossoNum

		ElseIf cSubCon == '017' //|Segunda Via BolFat
			cNossoNum	:= PadL(Alltrim(SE1->E1_NUMBCO),10,"0")
			cNNumImp	:= cNumConv + cNossoNum

		ElseIf 	cSubCon == '031'  //| Normal
			cNossoNum	:= Alltrim(SE1->E1_NUMBCO)
			cNumConv	:= ""
			cNNumImp	:= Substr(cNossoNum,2)+"-"+Mod10(cNossoNum,2)

		EndIf

		cAgencia	:= Alltrim(SEE->EE_AGENCIA)
		cContaCor	:= Alltrim(SEE->EE_CONTA)
		cCarteira	:= Substr(SEE->EE_SUBCTA,2,2)

		cAgeContI   := Substr(cAgencia,1,4)+"-"+Substr(cAgencia,5,1)+" / "+Substr(cContaCor,1,5)+"-"+Substr(cContaCor,6,1)

		cNomBanc 	:= "BANCO DO BRASIL"
		cLogo		:= "bbrasil.bmp" //"bsantander.bmp" //"bbrasil.bmp"
		cCodMoeB	:= "|001-9|"
		cCedente	:= SM0->M0_NOMECOM
		cEspecie	:= "R$"

		If SA1->A1_DESPCOB == 'S' .And. !Empty( SE1->E1_ORIGEM )
			nValDoc := Round(SE1->E1_VALOR,2)
		Else
			nValDoc := Round(SE1->E1_VALOR,2)
		EndIf

		If SA1->A1_PESSOA == "J"
			cCnpj		:= Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")
		ElseIf SA1->A1_PESSOA == "F"
			cCnpj		:= Transform(SA1->A1_CGC,"@R 999.999.999-99")
		EndIf

		cEspDoc		:= "DM"
		cLocalPag	:= "PAGAVEL EM QUALQUER BANCO ATé O VENCIMENTO"
		cValDoc 	:= Transform(nValDoc,"@E    999,999,999.99")


		cInstrL1	:= "Juros por Dia de Atraso - R$ "+ Alltrim(Transform(SE1->E1_VALJUR,"@E    999,999.99"))+ " Após "+cVencto
		cInstrL2	:= "Proceda os ajustes de valores pertinentes no pagamento."
		If cCarteira <> '17'
			cInstrL3	:= "Protesto: "+DToC(IIf(CDOW(CtoD(cVencto)+7)=="Saturday", CtoD(cVencto)+9,(IIf(CDOW(CtoD(cVencto)+7)=="Sunday", CtoD(cVencto)+8,CtoD(cVencto)+7))))+" Apartir Dessa Consulte BB p/ Pgto.
		Else
			cInstrL3	:= ""
		Endif
		If !lPriVia
			cInstrL4	:= "///// Atencao - Segunda Via /////"
		EndIf

		cInstrL5	:= ""
		cInstrL6	:= "Após 5 dias do Vencimento, o envio para cartório é automático"

		cCodBarra	:= ""
		cLinDig		:= MontaLinha()


	Case cCodBanc == "341" //| Banco Itau S/A
		*******
		cNomBanc 	:= "BANCO ITAU SA"
		cLogo			:= "bitau.bmp"
		cNossoNum	:= Alltrim(SE1->E1_NUMBCO)
		cNumConv	:= ""
		cCarteira	:= "112"
		cNNumImp	:= cCarteira +"/"+cNossoNum+"-"+Mod10(cCarteira+cNossoNum,2)
		cAgencia	:= Alltrim(SEE->EE_AGENCIA)
		cContaCor	:= Substr(SEE->EE_CONTA,1,5)

		cAgeContI   := cAgencia + "/"+SEE->EE_CONTA
		cCodMoeB	:= "|341-7|"
		cCedente	:= SM0->M0_NOMECOM
		cEspecie	:= "R$"


		If SA1->A1_DESPCOB == 'S' .And. !Empty( SE1->E1_ORIGEM )
			nValDoc := Round(SE1->E1_VALOR,2)
		Else
			nValDoc := Round(SE1->E1_VALOR,2)
		EndIf

		If SA1->A1_PESSOA == "J"
			cCnpj		:= Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")
		ElseIf SA1->A1_PESSOA == "F"
			cCnpj		:= Transform(SA1->A1_CGC,"@R 999.999.999-99")
		EndIf

		cEspDoc		:= "DMI"
		cLocalPag	:= "PAGAVEL EM QUALQUER BANCO ATé O VENCIMENTO"
		cValDoc 	:= Transform(nValDoc,"@E    999,999,999.99")

		cInstrL1	:= "Apos Vencimento Cobrar Mora de............................. "+ Alltrim(Transform(SE1->E1_VALJUR,"@E    999,999.99"))+ " ao Dia."
		//| Tratamento Sabado/Domingo
		cInstrL2	:= "Devolver em "+DToC(IIf(CDOW(CtoD(cVencto)+60)=="Saturday", CtoD(cVencto)+62,(IIf(CDOW(CtoD(cVencto)+60)=="Sunday", CtoD(cVencto)+61,CtoD(cVencto)+60))))
		cInstrL3	:= "Cobrança Escritural"
		cInstrL4	:= "Crédito dado em garantia ao Banco Itau S.A., Pagar Somente em Banco "
		cInstrL5	:= "Após Vencimento acesse www.itau.com.br/boletos para atualizar seu boleto"
		cInstrL6	:= "Após 5 dias do Vencimento, o envio para cartório é automático"


		cCodBarra	:= ""
		cLinDig		:= MontaLinha()

	Case cCodBanc == "033" //| Banco Santander / Real
		*******

        cAgencia	:= Alltrim(SEE->EE_AGENCIA)
		cNumConv	:= Alltrim(SEE->EE_CODEMP)

		//ALERT(LPRIVIA)
		If lPriVia //.AND. cSubCon  == '001'//| Primeira Via BolFat
			cNossoNum	:= SBuscaNum()
			cNNumImp	:= cNossoNum //cNumConv + cNossoNum
            cAgeContI   := cAgencia + "/" + cNumConv
		ElseIf cSubCon  == '001' //2 VIA BOLFAT
			cNossoNum	:= ALLTRIM(SE1->E1_NUMBCO) //PadL(Alltrim(SE1->E1_NUMBCO),10,"0")
			cNNumImp	:= cNossoNum //cNumConv + cNossoNum
            cAgeContI   := cAgencia + "/" + cNumConv
		ElseIf 	cSubCon == '000' //NORMAL
			cNossoNum	:= Alltrim(SE1->E1_NUMBCO)
			cNumConv	:= ""
			cNNumImp	:= Substr(cNossoNum,2)+"-"+Mod10(cNossoNum,2)
			cAgeContI   := cAgencia + "/" + cContaCor + " - 0"
		EndIf


		cNomBanc 	:= "BANCO SANTANDER"
		cLogo		:= "bsantander.bmp"
		//cNossoNum	:= SBuscaNum() //Alltrim(SE1->E1_NUMBCO)
		//cNumConv	:= "7453132"
		cCarteira	:= "COBRANCA SIMPLES RCR" //"101" //"COBRANCA SIMPLES RCR" //"101"  //"42"
		//cNNumImp	:= cNossoNum
		cAgencia	:= Alltrim(SEE->EE_AGENCIA)
		cContaCor	:= Alltrim(SEE->EE_CONTA)

		//cAgeContI   := cAgencia + "/" + cContaCor + " - 0"


		cCodMoeB	:= "|033-7|"
		cCedente	:= SM0->M0_NOMECOM
		cEspecie	:= "R$"

		If SA1->A1_DESPCOB == 'S' .And. !Empty( SE1->E1_ORIGEM )
			nValDoc := Round(SE1->E1_VALOR,2)
		Else
			nValDoc := Round(SE1->E1_VALOR,2)
		EndIf

		If SA1->A1_PESSOA == "J"
			cCnpj		:= Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")
		ElseIf SA1->A1_PESSOA == "F"
			cCnpj		:= Transform(SA1->A1_CGC,"@R 999.999.999-99")
		EndIf

		cEspDoc		:= "DM"
		cLocalPag	:= "PAGAVEL EM QUALQUER BANCO ATé O VENCIMENTO"
		cValDoc 	:= Transform(nValDoc,"@E    999,999,999.99")

		cInstrL1	:= "Juros/Mora ao dia : "+ Alltrim(Transform(SE1->E1_VALJUR,"@E    999,999.99")) + " Após "+DtoC(SE1->E1_VENCTO)
		cInstrL2	:= ""
		cInstrL3	:= "Titulo Empenhado. Pagar ao Banco - Nao vale Quitacao do Pagador."
		cInstrL4	:= ""
		cInstrL5	:= "BANCO SANTANDER - SAC 0800 707 2399 / Ouvidoria 0800 286 8787"
		cInstrL6	:= "Após 5 dias do Vencimento, o envio para cartório é automático"

		cCodBarra	:= ""
		cLinDig		:= MontaLinha()

	Case cCodBanc == "356" //| Banco Santander / Real
		*******

		cNomBanc 	:= "BANCO REAL"
		cLogo		:= "bsantander.bmp"
		cNossoNum	:= Alltrim(SE1->E1_NUMBCO)
		cNumConv	:= ""
		cCarteira	:= "42"
		cNNumImp	:= cNossoNum
		cAgencia	:= Alltrim(SEE->EE_AGENCIA)
		cContaCor	:= Alltrim(SEE->EE_CONTA)

		cAgeContI   := cAgencia + "/" + cContaCor + " - 3"
		cCodMoeB	:= "|356-5|"
		cCedente	:= SM0->M0_NOMECOM
		cEspecie	:= "R$"

		If SA1->A1_DESPCOB == 'S' .And. !Empty( SE1->E1_ORIGEM )
			nValDoc := Round(SE1->E1_VALOR,2)
		Else
			nValDoc := Round(SE1->E1_VALOR,2)
		EndIf

		If SA1->A1_PESSOA == "J"
			cCnpj		:= Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")
		ElseIf SA1->A1_PESSOA == "F"
			cCnpj		:= Transform(SA1->A1_CGC,"@R 999.999.999-99")
		EndIf

		cEspDoc		:= "DM"
		cLocalPag	:= "PAGAVEL EM QUALQUER BANCO ATé O VENCIMENTO"
		cValDoc 	:= Transform(nValDoc,"@E    999,999,999.99")

		cInstrL1	:= "Juros/Mora ao dia : "+ Alltrim(Transform(SE1->E1_VALJUR,"@E    999,999.99")) + " Após "+DtoC(SE1->E1_VENCTO)
		cInstrL2	:= ""
		cInstrL3	:= "Titulo Empenhado. Pagar ao Banco - Nao vale Quitacao do Sacador."
		cInstrL4	:= ""
		cInstrL5	:= "BANCO REAL - SAC 0800 707 2399 / Ouvidoria 0800 286 8787"
		cInstrL6	:= "Após 5 dias do Vencimento, o envio para cartório é automático"

		cCodBarra	:= ""
		cLinDig		:= MontaLinha()


	Case cCodBanc == "745" //| Banco Citi
		*******

		cNomBanc 	:= "BANCO CITI "
		cLogo		:= "bcitibank.bmp"
		cNossoNum	:= Substr(SE1->E1_NUMBCO,1,12) //770058241138
		cNumConv	:= ""
		cCarteira	:= "312"

		cNNumImp	:= cNossoNum

		cAgencia	:= Alltrim(SEE->EE_AGENCIA)
		cContaCor	:= Alltrim(SEE->EE_CONTA)

		cAgeContI   := cAgencia + "/" +  Alltrim(SEE->EE_CODEMP)
		cCodMoeB	:= "|745-5|"
		cCedente	:= SM0->M0_NOMECOM
		cEspecie	:= "R$"

		If SA1->A1_DESPCOB == 'S' .And. !Empty( SE1->E1_ORIGEM )
			nValDoc := Round(SE1->E1_VALOR,2)
		Else
			nValDoc := Round(SE1->E1_VALOR,2)
		EndIf

		If SA1->A1_PESSOA == "J"
			cCnpj		:= Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")
		ElseIf SA1->A1_PESSOA == "F"
			cCnpj		:= Transform(SA1->A1_CGC,"@R 999.999.999-99")
		EndIf

		cEspDoc		:= "DMI"
		cLocalPag	:= "PAGAVEL EM QUALQUER BANCO ATé O VENCIMENTO"
		cValDoc 	:= Transform(nValDoc,"@E    999,999,999.99")

		cInstrL1	:= " * * * VALORES EXPRESSOS EM REAIS  * * *"
		cInstrL2	:= "MORA P/ DIA DE ATRASO: R$ "+ Alltrim(Transform(SE1->E1_VALJUR,"@E    999,999.99"))
		cInstrL3	:= "ATE 5 DIAS APOS VENCTO, PAGAVEL NO CITIBANK, HSBC, BM B, RURAL E BIC"
		cInstrL4	:= "SE PREFERIR, ACESSE WWW.CITIBANK.COM .BR/BOLETOS OU LIGUE 0800 7018701"
		cInstrL5	:= "(11) 21359510 E OBTENHA NOVO BOLETO COM ENCARGOS"
		cInstrL6	:= "Após 5 dias do Vencimento, o envio para cartório é automático"

		cCodBarra	:= ""
		cLinDig		:= MontaLinha()


	Case cCodBanc == "237" //| Banco Bradesco
		*******

		cNomBanc 	:= "BANCO BRADESCO "
		cLogo		:= "bbradesco.bmp"
		cNossoNum	:= Substr(SE1->E1_NUMBCO,1,11)
		cNumConv	:= ""
		cCarteira	:= "02"
		cNNumImp	:= cCarteira +"/"+Substr(cNossoNum,1,2)+"/"+Substr(cNossoNum,3,9)+"-"+Mod10(cCarteira+cNossoNum,1)
		cAgencia	:= "0"+Alltrim(SEE->EE_AGENCIA)
		cContaCor	:= Substr(SEE->EE_CONTA,1,6)

		cAgeContI   := cAgencia + "/" + cContaCor + "-6"
		cCodMoeB	:= "|237-2|"
		cCedente	:= SM0->M0_NOMECOM
		cEspecie	:= "R$"

		If SA1->A1_DESPCOB == 'S' .And. !Empty( SE1->E1_ORIGEM )
			nValDoc := Round(SE1->E1_VALOR,2)
		Else
			nValDoc := Round(SE1->E1_VALOR,2)
		EndIf

		If SA1->A1_PESSOA == "J"
			cCnpj		:= Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")
		ElseIf SA1->A1_PESSOA == "F"
			cCnpj		:= Transform(SA1->A1_CGC,"@R 999.999.999-99")
		EndIf

		cEspDoc		:= "DM"
		cLocalPag	:= "PAGAVEL EM QUALQUER BANCO ATé O VENCIMENTO"
		cValDoc 	:= Transform(nValDoc,"@E    999,999,999.99")

		cInstrL1	:= " * * * VALORES EXPRESSOS EM REAIS  * * *"
		cInstrL2	:= "MORA DIA/COM.PERMANENC............"+ Alltrim(Transform(SE1->E1_VALJUR,"@E    999,999.99"))
		cInstrL3	:= "TITULO NEGOCIADO PAGAVEL SOMENTE EM BANCO OU REDE DE CORRESPONDENTES"
		cInstrL4	:= ""
		cInstrL5	:= ""
		cInstrL6	:= "Após 5 dias do Vencimento, o envio para cartório é automático"

		cCodBarra	:= ""
		cLinDig		:= MontaLinha()

	OtherWise
		*******

	EndCase

Return()
*********************************************************************
Static Function MontaLinha()	//Montagem da Linha Digitavel                                  |
*********************************************************************
	Local cLineDig 	:= ""   //| Linha Digitavel Final
//Local cCodBar	:= ""   //| Codigo de Barras sem os DV
	Local FatorVcto := "" 	//| Fator de Vencimento
	Local cMoeda	:= "" 	//| Codigo da Moeda
	Local cDigVer	:= ""	//| Digito Verificador
	Local cValTit	:= ""	//| Valor do Titulo
	Local cCampo1	:= ""	//| Campo 1 do Codigo de Barras
	Local cCampo2	:= ""	//| Campo 2 do Codigo de Barras
	Local cCampo3	:= ""	//| Campo 3 do Codigo de Barras
	Local cCampo4	:= ""	//| Campo 4 do Codigo de Barras
	Local cCampo5	:= ""	//| Campo 5 do Codigo de Barras
	Local cDvCam1	:= ""	//| Digito Verificador Campo 1
	Local cDvCam2	:= ""	//| Digito Verificador Campo 2
	Local cDvCam3	:= ""	//| Digito Verificador Campo 3

	Do Case

	Case cCodBanc == "001" //| Banco do Brasil
		*******
		If SEE->EE_SUBCTA $ ('017') //| Carteira 017

			//| Codigo de Barras
			cCodBarra += cCodBanc                           									//|01 - 03 = Codigo Banco
			cCodBarra += cMoeda	   		:= "9"                                                	//|04 - 04 = Codigo Moeda
			cCodBarra += cDigVer		:= ""                                                 	//|05 - 05 = Dv Codigo Barras
			cCodBarra += cFatorVcto 	:= Str( ( SE1->E1_VENCTO - Ctod("07/10/1997") ),4 ) 	//|06 - 09 = Fator Vencimento
			cCodBarra += cValTit		:= StrZero( ( nValDoc * 100 ), 10 )              	 	//|10 - 19 = Valor
			cCodBarra += "000000"                                                        		//|20 - 25 = Zeros
			cCodBarra += cNumConv + cNossoNum                                             		//|26 - 42 = Nosso Numero Sem o Dv
			cCodBarra += cCarteira                                                            	//|43 - 44 = Tipo Carteira

			cDigVer	:= Mod11(cCodBarra)

			cCodBarra := Substr(cCodBarra,1,4) + cDigVer + Substr(cCodBarra,5,39)

			//| Alimentar Campos da Linha Digitavel
			cCampo1	:= Substr(cCodBarra,1,4)+Substr(cCodBarra,20,5)
			cCampo2	:= Substr(cCodBarra,25,10)
			cCampo3	:= Substr(cCodBarra,35,10)
			cCampo4	:= cDigVer
			cCampo5	:= cFatorVcto + cValTit

		ElseIf SEE->EE_SUBCTA $ ('031') //| Carteira 031
			//| Codigo de Barras
			cCodBarra += cCodBanc                           									//|01 - 03 = Codigo Banco
			cCodBarra += cMoeda	   		:= "9"                                                	//|04 - 04 = Codigo Moeda
			cCodBarra += cDigVer		:= ""                                                 	//|05 - 05 = Dv Codigo Barras
			cCodBarra += cFatorVcto 	:= Str( ( SE1->E1_VENCTO - Ctod("07/10/1997") ),4 ) 	//|06 - 09 = Fator Vencimento
			cCodBarra += cValTit		:= StrZero( ( nValDoc * 100 ), 10 )              	 	//|10 - 19 = Valor
			cCodBarra += cNossoNum                                                            	//|20 - 30 = Nosso Numero Sem o Dv
			cCodBarra += Substr(cAgencia,1,4)                                  					//|31 - 34 = N da Agencia Cedente
			cCodBarra += "000"+Substr(cContaCor,1,5)                           					//|35 - 42 = N da Conta Corrente
			cCodBarra += cCarteira                                                        		//|43 - 44 = Zeros

			cDigVer	:= Mod11(cCodBarra)

			cCodBarra := Substr(cCodBarra,1,4) + cDigVer + Substr(cCodBarra,5,39)

			//| Alimentar Campos da Linha Digitavel
			cCampo1	:= Substr(cCodBarra,1,4)+Substr(cCodBarra,20,5)
			cCampo2	:= Substr(cCodBarra,25,10)
			cCampo3	:= Substr(cCodBarra,35,10)
			cCampo4	:= cDigVer
			cCampo5	:= cFatorVcto + cValTit

		EndIf


	Case cCodBanc == "341" //| Banco Itau S/A
		*******
		//| Codigo de Barras
		cCodBarra += cCodBanc                           															//|01 - 03 = Codigo Banco
		cCodBarra += cMoeda	   		:= "9"                                               	//|04 - 04 = Codigo Moeda
		cCodBarra += cDigVer		:= ""                                                 	//|05 - 05 = Dv Codigo Barras
		cCodBarra += cFatorVcto 	:= Str( ( SE1->E1_VENCTO - Ctod("07/10/1997") ),4 ) 	//|06 - 09 = Fator Vencimento
		cCodBarra += cValTit		:= StrZero( ( nValDoc * 100 ), 10 )               			//|10 - 19 = Valor
		cCodBarra += cCarteira                                                        	//|20 - 22 = Cod Carteira
		cCodBarra += cNossoNum                                             						//|23 - 30 = Nosso Numero Sem o Dv
		cCodBarra += Mod10(cCarteira+cNossoNum,2)                       							//|31 - 31 = DAC [Carteira/Nosso Num]
		cCodBarra += cAgencia                                             						//|32 - 35 = N da Agencia Cedente
		cCodBarra += cContaCor     		                                 								//|36 - 40 = N da Conta Corrente
		cCodBarra += Mod10(cAgencia+cContaCor,2)                                      	//|41 - 41 = DAC [Agencia/Conta]
		cCodBarra += "000"                                                        		  	//|42 - 44 = Zeros

		cDigVer	:= Mod11(cCodBarra)

		cCodBarra := Substr(cCodBarra,1,4) + cDigVer + Substr(cCodBarra,5,39)

		//| Alimentar Campos da Linha Digitavel
		cCampo1	:= Substr(cCodBarra,01,4) + cCarteira + Substr(cNossoNum,1,2)
		cCampo2	:= Substr(cNossoNum,03)   + Substr(cCodBarra,31,1) + Substr(cAgencia,1,3)
		cCampo3	:= Substr(cAgencia ,04,1) + Substr(cContaCor,1,5) + Substr(cCodBarra,41,1) + Substr(cCodBarra,42,3)
		cCampo4	:= cDigVer
		cCampo5	:= cFatorVcto + cValTit

	Case cCodBanc == "033" //| Banco Real / Santander
	/*
		*******
		//| Codigo de Barras
		cCodBarra += cCodBanc                           														//|01 - 03 = Codigo Banco
		cCodBarra += cMoeda	   	:= "9"                                               	//|04 - 04 = Codigo Moeda
		cCodBarra += cDigVer		:= ""                                               	//|05 - 05 = Dv Codigo Barras
		cCodBarra += cFatorVcto 	:= Str( ( SE1->E1_VENCTO - Ctod("07/10/1997") ),4 )//|06 - 09 = Fator Vencimento
		cCodBarra += cValTit		:= StrZero( ( nValDoc * 100 ), 10 )               		//|10 - 19 = Valor
		cCodBarra += "9"                                                            	//|20 - 20 = Fixo "9" 9
		cCodBarra += "4888243"                                                      	//|21 - 27 = numero do PSK(Codigo do Cliente) 0282033
		cCodBarra += StrZero(Val(cNossoNum),13)                                     	//|28 - 40 = Nosso Numero 5666124578002
		cCodBarra += "0"                                                            	//|41 - 41 = IOF Seguradoras - Demais clientes = zero 0
		cCodBarra += "104"                                                          	//|42 - 44 = 102 -Cobrança simples – SEM Registro
		cDigVer	:= Mod11(cCodBarra)

		cCodBarra := Substr(cCodBarra,1,4) + cDigVer + Substr(cCodBarra,5,39)

		//| Alimentar Campos da Linha Digitavel
		cCampo1	:= Substr(cCodBarra,01,04) + Substr(cCodBarra,20,05) //+ Substr(cCodBarra,24,1)
		cCampo2	:= Substr(cCodBarra,25,03) + Substr(cCodBarra,28,07) //+ Substr(cCodBarra,32,3)
		cCampo3	:= Substr(cCodBarra,35,06) + Substr(cCodBarra,41,01) + Substr(cCodBarra,42,03)
		cCampo4	:= cDigVer
		cCampo5	:= cFatorVcto + cValTit

	*/

		If SEE->EE_SUBCTA $ ('001') //| Carteira 017

		*******
		//| Codigo de Barras
		cCodBarra += cCodBanc  //033                         														//|01 - 03 = Codigo Banco
		cCodBarra += cMoeda	   	:= "9"                                               	//|04 - 04 = Codigo Moeda
		cCodBarra += cDigVer		:= ""                                               	//|05 - 05 = Dv Codigo Barras
		cCodBarra += cFatorVcto 	:= Str( ( SE1->E1_VENCTO - Ctod("07/10/1997") ),4 )//|06 - 09 = Fator Vencimento
		cCodBarra += cValTit		:= StrZero( ( nValDoc * 100 ), 10 )               		//|10 - 19 = Valor
		cCodBarra += "9"                                                            	//|20 - 20 = Fixo "9" 9
		cCodBarra += "7453132"                                                      	//|21 - 27 = numero do PSK(Codigo do Cliente) 0282033
		//cCodBarra += cNumConv + cNossoNum
		cCodBarra += StrZero(Val(cNossoNum),13)                                     	//|28 - 40 = Nosso Numero 5666124578002
		cCodBarra += "0"                                                            	//|41 - 41 = IOF Seguradoras - Demais clientes = zero 0
		cCodBarra += "101"                                                          	//|42 - 44 = 102 -Cobrança simples – SEM Registro

		cDigVer	:= Mod11(cCodBarra)

		cCodBarra := Substr(cCodBarra,1,4) + cDigVer + Substr(cCodBarra,5,39)

		//| Alimentar Campos da Linha Digitavel
		cCampo1	:= Substr(cCodBarra,01,04) + Substr(cCodBarra,20,05) //+ Substr(cCodBarra,24,1)
		cCampo2	:= Substr(cCodBarra,25,03) + Substr(cCodBarra,28,07) //+ Substr(cCodBarra,32,3)
		cCampo3	:= Substr(cCodBarra,35,06) + Substr(cCodBarra,41,01) + Substr(cCodBarra,42,03)
		cCampo4	:= cDigVer
		cCampo5	:= cFatorVcto + cValTit

       ElseIf SEE->EE_SUBCTA $ ('000') //| Carteira 031

		*******
		//| Codigo de Barras
		cCodBarra += cCodBanc                           														//|01 - 03 = Codigo Banco
		cCodBarra += cMoeda	   	:= "9"                                               	//|04 - 04 = Codigo Moeda
		cCodBarra += cDigVer		:= ""                                               	//|05 - 05 = Dv Codigo Barras
		cCodBarra += cFatorVcto 	:= Str( ( SE1->E1_VENCTO - Ctod("07/10/1997") ),4 )//|06 - 09 = Fator Vencimento
		cCodBarra += cValTit		:= StrZero( ( nValDoc * 100 ), 10 )               		//|10 - 19 = Valor
		cCodBarra += "9"                                                            	//|20 - 20 = Fixo "9" 9
		cCodBarra += "4888243"                                                      	//|21 - 27 = numero do PSK(Codigo do Cliente) 0282033
		cCodBarra += StrZero(Val(cNossoNum),13)                                     	//|28 - 40 = Nosso Numero 5666124578002


		cCodBarra += "0"                                                            	//|41 - 41 = IOF Seguradoras - Demais clientes = zero 0
		cCodBarra += "104"                                                          	//|42 - 44 = 102 -Cobrança simples – SEM Registro
		cDigVer	:= Mod11(cCodBarra)

		cCodBarra := Substr(cCodBarra,1,4) + cDigVer + Substr(cCodBarra,5,39)

		//| Alimentar Campos da Linha Digitavel
		cCampo1	:= Substr(cCodBarra,01,04) + Substr(cCodBarra,20,05) //+ Substr(cCodBarra,24,1)
		cCampo2	:= Substr(cCodBarra,25,03) + Substr(cCodBarra,28,07) //+ Substr(cCodBarra,32,3)
		cCampo3	:= Substr(cCodBarra,35,06) + Substr(cCodBarra,41,01) + Substr(cCodBarra,42,03)
		cCampo4	:= cDigVer
		cCampo5	:= cFatorVcto + cValTit


       ENDIF

	Case cCodBanc == "356" //| Banco Real / Santander
		*******
		//| Codigo de Barras
		cCodBarra += cCodBanc                           										//|01 - 03 = Codigo Banco
		cCodBarra += cMoeda	   		:= "9"                                              	//|04 - 04 = Codigo Moeda
		cCodBarra += cDigVer		:= ""                                                 	//|05 - 05 = Dv Codigo Barras
		cCodBarra += cFatorVcto 	:= Str( ( SE1->E1_VENCTO - Ctod("07/10/1997") ),4 ) 		//|06 - 09 = Fator Vencimento
		cCodBarra += cValTit		:= StrZero( ( nValDoc * 100 ), 10 )               		//|10 - 19 = Valor
		cCodBarra += cAgencia                                             					//|20 - 23 = N da Agencia Cedente
		cCodBarra += cContaCor     		                                 					//|24 - 30 = N da Conta Corrente
		cCodBarra += Mod10(cNossoNum+cAgencia+cContaCor,1)                                          	//|31 - 31 = Digitao
		cCodBarra += "000000" + cNossoNum                                                  	//|32 - 44 = Nosso Numero

		cDigVer	:= Mod11(cCodBarra)

		cCodBarra := Substr(cCodBarra,1,4) + cDigVer + Substr(cCodBarra,5,39)

		//| Alimentar Campos da Linha Digitavel
		cCampo1	:= Substr(cCodBarra,01,04) + Substr(cCodBarra,20,4) + Substr(cCodBarra,24,1)
		cCampo2	:= Substr(cCodBarra,25,06) + Substr(cCodBarra,31,1) + Substr(cCodBarra,32,3)
		cCampo3	:= Substr(cCodBarra,35,10)
		cCampo4	:= cDigVer
		cCampo5	:= cFatorVcto + cValTit


	Case cCodBanc == "745" //| Banco Citi
		*******
		//| Codigo de Barras
		cCodBarra += cCodBanc                           									//|01 - 03 = Codigo Banco
		cCodBarra += cMoeda	   		:= "9"                                                	//|04 - 04 = Codigo Moeda
		cCodBarra += cDigVer		:= ""                                                 	//|05 - 05 = Dv Codigo Barras
		cCodBarra += cFatorVcto 	:= Str( ( SE1->E1_VENCTO - Ctod("07/10/1997") ),4 ) 	//|06 - 09 = Fator Vencimento
		cCodBarra += cValTit		:= StrZero( ( nValDoc * 100 ), 10 )               		//|10 - 19 = Valor
		cCodBarra += "3"                                             	   					//|20      = Codigo do Produto
		cCodBarra += "312"                                							  		//|21 - 23 = 3 Ultimos Digitos da Identificacao da Empresa
		cCodBarra +=  Substr(SEE->EE_CODEMP,2,9)                         					//|24 - 32 = Conta Cosmos
		cCodBarra += cNossoNum                                          		   			//|33 - 44 = Nosso Numero

		cDigVer	:= Mod11(cCodBarra)

		cCodBarra := Substr(cCodBarra,1,4) + cDigVer + Substr(cCodBarra,5,39)

		//| Alimentar Campos da Linha Digitavel
		cCampo1	:= Substr(cCodBarra,01,04) + Substr(cCodBarra,20,5)
		cCampo2	:= Substr(cCodBarra,25,10)
		cCampo3	:= Substr(cCodBarra,35,10)
		cCampo4	:= cDigVer
		cCampo5	:= cFatorVcto + cValTit


	Case cCodBanc == "237" //| Banco Bradesco
		*******
		//| Codigo de Barras
		cCodBarra += cCodBanc                           									//|01 - 03 = Codigo Banco
		cCodBarra += cMoeda	   		:= "9"                                                	//|04 - 04 = Codigo Moeda
		cCodBarra += cDigVer		:= ""                                                 	//|05 - 05 = Dv Codigo Barras
		cCodBarra += cFatorVcto 	:= Str( ( SE1->E1_VENCTO - Ctod("07/10/1997") ),4 ) 	//|06 - 09 = Fator Vencimento
		cCodBarra += cValTit		:= StrZero( ( nValDoc * 100 ), 10 )               	//|10 - 19 = Valor
		cCodBarra += Substr(cAgencia,2,4)                                             		//|20 - 23 = N da Agencia Cedente
		cCodBarra += cCarteira                                								//|24 - 25 = N da Carteira
		cCodBarra += cNossoNum     		                                 					//|26 - 36 = Nosso Numero
		cCodBarra += "0"+cContaCor                                          					//|37 - 43 = N Conta Corrente s/ Dv
		cCodBarra += "0" 																	//|44 - 44 = Zero

		cDigVer	:= Mod11(cCodBarra)

		cCodBarra := Substr(cCodBarra,1,4) + cDigVer + Substr(cCodBarra,5,39)

		//| Alimentar Campos da Linha Digitavel
		cCampo1	:= Substr(cCodBarra,01,04) + Substr(cCodBarra,20,5)
		cCampo2	:= Substr(cCodBarra,25,10)
		cCampo3	:= Substr(cCodBarra,35,10)
		cCampo4	:= cDigVer
		cCampo5	:= cFatorVcto + cValTit

	EndCase

	If !Empty(cCampo1) .And. !Empty(cCampo2) .And. !Empty(cCampo3)
	//|Montagem dos Digitos Verificadores dos Campos que formam a Linha Digital (DAC)
		cDvCam1	:= Mod10(cCampo1,2)
		cDvCam2	:= Mod10(cCampo2,1)
		cDvCam3	:= Mod10(cCampo3,1)

	//|Linha Digitavel
		cLineDig := Substr(cCampo1,1,5)+"."+Substr(cCampo1,6,5)+cDvCam1+" "+Substr(cCampo2,1,5)+"."+Substr(cCampo2,6,5)+cDvCam2+" "+Substr(cCampo3,1,5)+"."+Substr(cCampo3,6,5)+cDvCam3+" "+cCampo4+" "+cCampo5

	EndIf

Return(cLineDig)
*********************************************************************
Static Function PrintBol()//| Gera Impressao do Boleto
*********************************************************************
	cNomBanc	:= ""
	cLinha		:= Replicate('- ',170)
	nULinha		:= 80 				//| Uma Linha
	nMLinha 	:= nULinha / 2 		//| Meia Linha
	nQLinha 	:= nULinha / 4		//| Quarto de Linha
	nOLinha 	:= nULinha / 8  	//| Oitavo de Linha
	nDLinha 	:= nULinha / 8  	//| Decimo de Linha

	oFTitulo		:=	TFont():New("Arial" 		,09,08,,.F.,,,,,.F.)	// Titulos dos Campos
	oFConteudo	:=	TFont():New("Arial"			,09,10,,.T.,,,,,.F.)	// Conteudo dos Campos
	oFNBanco		:=	TFont():New("Arial"			,09,20,,.T.,,,,,.F.)	// Nome Banco
	oFCodIni		:=	TFont():New("Arial"			,09,22,,.T.,,,,,.F.)	// Codigo Inicial do Boleto
	oFlinha		:=	TFont():New("Arial"			,09,08,,.F.,,,,,.F.)	// Linha Pontilhada
	oFNumBar		:=	TFont():New("Arial"			,09,18,,.T.,,,,,.F.)	// Numero Barra


 	If lPriVia .Or. lPriPag //

		lPriPag := .F.


		//	oPrn := 	xPar //| Obtem todas as Config do oDanfe...



			oPrn := 	FWMSPrinter():New(cFilePrintert, nDevice, lAdjustToLegacy ,cPathInServer, lDisabeSetup, lTReport, @oPrn, cPrinter, lServer, lPDFAsPNG, lRaw, lViewPDF )
			oPrn:SetResolution(78)
			oPrn:SetPortrait()
			oPrn:SetPaperSize(9)
			oPrn:SetMargin(0,0,0,0)
			oPrn:cPathPDF	:= cLocalPath
			oPrn:SetViewPDF(lSetView)

			If lehNfs //| Caso Seja impressao apartir da emissao da DANFE... dese manter as configuracoes de impressao que foram utilizadas...
				oPrn:cPathPDf 	:= xPar:cPathPDf
				oPrn:cPrinter 	:= xPar:cPrinter
				oPrn:cSession 	:= xPar:cSession
				oPrn:nDevice 	:= xPar:nDevice
				oPrn:cPathPDf 	:= xPar:cPathPDf
			EndIf

		EndIf



	oPrn:StartPage() //| Inicia a Pagina

	nCol	:= 100
	nLinI 	:= 60;     nLinE	:= nLinI + nULinha
	oPrn:Say(nLinI,nCol * 1  ,cLinha,oFlinha,0) //| Linha

	nLinI += nQLinha;	nLinE := nLinI + nULinha


	IF cCODBANC="033" .AND. SEE->EE_SUBCTA $ ('001')
	   oPrn:Say(nLinI,nCol * 11 ,"Recibo do Pagador",oFTitulo,0)
	ELSE
	   oPrn:Say(nLinI,nCol * 11 ,"Recibo do Sacado",oFTitulo,0)
    ENDIF
	nLinI += nULinha;	nLinE := nLinI + nULinha
	nLinI += nULinha;	nLinE := nLinI + nULinha

	oPrn:SayBitmap( nLinI - 15	,nCol	, cLogo		, 500		, 110 			)
//	oPrn:SayBitmap( nRow>				,nCol	, cBitmap	, nWidth	, nHeight	)

	oPrn:Say(nLinI + 60,nCol * 6 ,cCodMoeB,oFCodIni,0)

	nLinI += nMLinha;	nLinE := nLinI + nULinha
	oPrn:Say(nLinI + 40,nCol * 09 ,cLinDig,oFNumBar,0)

	nLinI += nMLinha;	nLinE := nLinI + nULinha
	nLinI += nQLinha;	nLinE := nLinI + nULinha
	oPrn:Box(nLinI				,nCol * 01     	,nLinE,nCol * 11 )

	IF cCodBanc="033" .AND. SEE->EE_SUBCTA $ ('001')
	    oPrn:say(nLinI	+ 20		,nCol * 01 + 10	,"Beneficiario",oFTitulo,0)
	ELSE
	    oPrn:say(nLinI	+ 20		,nCol * 01 + 10	,"Cedente",oFTitulo,0)
	ENDIF

	oPrn:say(nLinI + 60		,nCol * 01 + 10	,cCedente,oFConteudo,0)

	oPrn:Box(nLinI				,nCol * 11 		,nLinE,nCol * 16 )

	IF cCodBanc="033" .AND. SEE->EE_SUBCTA $ ('001')
	    oPrn:say(nLinI	+ 20		,nCol * 11 + 10	,"Agencia/Código do Beneficiario",oFTitulo,0)
	ELSE
	    oPrn:say(nLinI	+ 20		,nCol * 11 + 10	,"Agencia/Código do Cedente",oFTitulo,0)
	ENDIF
	oPrn:say(nLinI + 60		,nCol * 11 + 10	,cAgeContI,oFConteudo,0)

	oPrn:box(nLinI				,nCol * 16 		,nLinE,nCol * 17 )
	oPrn:say(nLinI	+ 20		,nCol * 16 + 10	,"Espécie",oFTitulo,0)
	oPrn:say(nLinI + 60		,nCol * 16 + 10	,cEspecie,oFConteudo,0)

	oPrn:box(nLinI				,nCol * 17 		,nLinE,nCol * 19 )
	oPrn:say(nLinI	+ 20		,nCol * 17 + 10	,"Quantidade",oFTitulo,0)
	oPrn:say(nLinI + 60		,nCol * 17 + 10	,"",oFConteudo,0)

	oPrn:box(nLinI				,nCol * 19 		,nLinE,nCol * 23 )
	oPrn:say(nLinI	+ 20		,nCol * 19 + 10	,"Nosso Número",oFTitulo,0)
	oPrn:say(nLinI + 60		,nCol * 19 + 10	,cNNumImp ,oFConteudo,0)

	nLinI += nULinha;	nLinE := nLinI + nULinha
	oPrn:Box(nLinI				,nCol * 01     	,nLinE,nCol * 07 )
	oPrn:say(nLinI	+ 20		,nCol * 01 + 10	,"Número do Documento",oFTitulo,0)
	oPrn:say(nLinI + 60		,nCol * 01 + 10	,cNumDoc,oFConteudo,0)

	oPrn:Box(nLinI				,nCol * 07 		,nLinE,nCol * 13 )
	oPrn:say(nLinI	+ 20		,nCol * 07 + 10	,"CPF/CNPJ",oFTitulo,0)
	oPrn:say(nLinI + 60		,nCol * 07 + 10	,cCnpjImd,oFConteudo,0)

	oPrn:box(nLinI				,nCol * 13 		,nLinE,nCol * 19 )
	oPrn:say(nLinI	+ 20		,nCol * 13 + 10	,"Vencimento",oFTitulo,0)
	oPrn:say(nLinI + 60		,nCol * 13 + 10	,cVencto,oFConteudo,0)

	oPrn:box(nLinI				,nCol * 19 		,nLinE,nCol * 23 )
	oPrn:say(nLinI	+ 20		,nCol * 19 + 10	,"Valor Documento",oFTitulo,0)
	oPrn:say(nLinI + 60		,nCol * 19 + 10	,cValDoc,oFConteudo,0)


	nLinI += nULinha;	nLinE := nLinI + nULinha
	oPrn:Box(nLinI				,nCol * 01     	,nLinE,nCol * 04 )
	oPrn:say(nLinI	+ 20		,nCol * 01 + 10	,"(-) Desconto / Abatimentos",oFTitulo,0)
	oPrn:say(nLinI + 60		,nCol * 01 + 10	,"",oFConteudo,0)

	oPrn:Box(nLinI				,nCol * 04 		,nLinE,nCol * 08 )
	oPrn:say(nLinI	+ 20		,nCol * 04 + 10	,"(-) Outras Deduções",oFTitulo,0)
	oPrn:say(nLinI + 60		,nCol * 04 + 10	,"",oFConteudo,0)

	oPrn:box(nLinI				,nCol * 08 		,nLinE,nCol * 12 )
	oPrn:say(nLinI	+ 20		,nCol * 08 + 10	,"(+) Mora / Multa",oFTitulo,0)
	oPrn:say(nLinI + 60		,nCol * 08 + 10	,"",oFConteudo,0)

	oPrn:box(nLinI				,nCol * 12 		,nLinE,nCol * 19 )
	oPrn:say(nLinI	+ 20		,nCol * 12 + 10	,"(+) Outros Acréscimos",oFTitulo,0)
	oPrn:say(nLinI + 60		,nCol * 12 + 10	,"",oFConteudo,0)

	oPrn:box(nLinI				,nCol * 19 		,nLinE,nCol * 23 )
	oPrn:say(nLinI	+ 20		,nCol * 19 + 10	,"(=)Valor Cobrado",oFTitulo,0)
//oPrn:say(nLinI + 60		,nCol * 19 + 10	,cValDoc,oFConteudo,0)


	nLinI += nULinha;	nLinE := nLinI + nULinha
	oPrn:Box(nLinI				,nCol * 01     	,nLinE,nCol * 23 )
	IF cCodBanc="033" .AND. SEE->EE_SUBCTA $ ('001')
   	   oPrn:say(nLinI	+ 20		,nCol * 01 + 10	,"Pagador",oFTitulo,0)
	ELSE
	   oPrn:say(nLinI	+ 20		,nCol * 01 + 10	,"Sacado",oFTitulo,0)
	ENDIF
	oPrn:say(nLinI + 60		,nCol * 01 + 10	,cSacado,oFConteudo,0)

	nLinI += nULinha;	nLinE := nLinI + nULinha
	oPrn:say(nLinI + 20		,nCol * 01 + 10	,"Instruções",oFTitulo,0)
	oPrn:say(nLinI + 20		,nCol * 18 + 10	,"Autenticação Mecânica-Ficha de Compensação",oFTitulo,0)

	nLinI += nULinha;	nLinE := nLinI + nULinha
	oPrn:say(nLinI				,nCol * 01 + 10	,cInstrL1,oFConteudo,0)

	nLinI += nULinha;	nLinE := nLinI + nULinha
	oPrn:say(nLinI				,nCol * 01 + 10	,cInstrL2,oFConteudo,0)

	nLinI += nULinha;	nLinE := nLinI + nULinha
	oPrn:say(nLinI				,nCol * 01 + 10	,cInstrL3,oFConteudo,0)

	nLinI += nULinha;	nLinE := nLinI + nULinha
	oPrn:say(nLinI				,nCol * 01 + 10	,cInstrL4,oFConteudo,0)

	nLinI += nULinha;	nLinE := nLinI + nULinha
	oPrn:say(nLinI				,nCol * 01 + 10	,cInstrL5,oFConteudo,0)

	nLinI += nULinha;	nLinE := nLinI + nULinha
	oPrn:say(nLinI				,nCol * 01 + 10	,cInstrL6,oFConteudo,0)

//	nLinI += nULinha;	nLinE := nLinI + nULinha
	nLinI += nULinha;	nLinE := nLinI + nULinha
	oPrn:Say(nLinI				,nCol * 20 ,"Corte na Linha Pontilhada",oFTitulo,0)


	nLinI += nDLinha;	nLinE := nLinI + nULinha
	oPrn:Say(nLinI				,nCol * 1  ,cLinha,oFlinha,0) //| Linha


	nLinI += nULinha;	nLinE := nLinI + nULinha
	nLinI += nULinha;	nLinE := nLinI + nULinha

	oPrn:SayBitmap( nLinI - 15,nCol,cLogo, 500, 110 )  //| objeto,constante,linha,coluna,caminho,

	oPrn:Say(nLinI + 60		,nCol * 6 ,cCodMoeB,oFCodIni,0)

	nLinI += nMLinha;	nLinE := nLinI + nULinha
	oPrn:Say(nLinI + 40		,nCol * 09 ,cLinDig,oFNumBar,0)


	nLinI += nMLinha;	nLinE := nLinI + nULinha
	nLinI += nQLinha;	nLinE := nLinI + nULinha
	oPrn:Box(nLinI				,nCol * 01     	,nLinE,nCol * 19 )
	oPrn:say(nLinI	+ 20		,nCol * 01 + 10	,"Local de Pagamento",oFTitulo,0)
	oPrn:say(nLinI + 60		,nCol * 01 + 10	,cLocalPag,oFConteudo,0)

	oPrn:Box(nLinI				,nCol * 19     	,nLinE,nCol * 23 )
	oPrn:say(nLinI	+ 20		,nCol * 19 + 10	,"Vencimento",oFTitulo,0)
	oPrn:say(nLinI + 60		,nCol * 19 + 10	,cVencto,oFConteudo,0)


	nLinI += nULinha;	nLinE := nLinI + nULinha
	oPrn:Box(nLinI				,nCol * 01     	,nLinE,nCol * 19 )

	IF cCodBanc="033" .AND. SEE->EE_SUBCTA $ ('001')
       oPrn:say(nLinI	+ 20		,nCol * 01 + 10	,"Beneficiario",oFTitulo,0)
	ELSE
	   oPrn:say(nLinI	+ 20		,nCol * 01 + 10	,"Cedente",oFTitulo,0)
	ENDIF
	oPrn:say(nLinI + 60		,nCol * 01 + 10	,cCedente,oFConteudo,0)

	oPrn:Box(nLinI				,nCol * 19     	,nLinE,nCol * 23 )

	IF cCodBanc="033" .AND. SEE->EE_SUBCTA $ ('001')
      oPrn:say(nLinI	+ 20		,nCol * 19 + 10	,"Agência/Codigo Beneficiario",oFTitulo,0)
	ELSE
	  oPrn:say(nLinI	+ 20		,nCol * 19 + 10	,"Agência/Codigo Cedente",oFTitulo,0)
	ENDIF
	oPrn:say(nLinI + 60		,nCol * 19 + 10	,cAgeContI,oFConteudo,0)

	nLinI += nULinha;	nLinE := nLinI + nULinha
	oPrn:Box(nLinI				,nCol * 01     	,nLinE,nCol * 05 )
	oPrn:say(nLinI	+ 20		,nCol * 01 + 10	,"Data do Documento",oFTitulo,0)
	oPrn:say(nLinI + 60		,nCol * 01 + 10	,cEmissao,oFConteudo,0)

	oPrn:Box(nLinI				,nCol * 05     	,nLinE,nCol * 10 )
	oPrn:say(nLinI	+ 20		,nCol * 05 + 10	,"Número Documento",oFTitulo,0)
	oPrn:say(nLinI + 60		,nCol * 05 + 10	,cNumDoc,oFConteudo,0)

	oPrn:Box(nLinI				,nCol * 10     	,nLinE,nCol * 12 )
	oPrn:say(nLinI	+ 20		,nCol * 10 + 10	,"Espécie DOC",oFTitulo,0)
	oPrn:say(nLinI + 60		,nCol * 10 + 10	,cEspDoc,oFConteudo,0)

	oPrn:Box(nLinI				,nCol * 12     	,nLinE,nCol * 14 )
	oPrn:say(nLinI	+ 20		,nCol * 12 + 10	,"Aceite",oFTitulo,0)
	oPrn:say(nLinI + 60		,nCol * 12 + 10	,cAceite,oFConteudo,0)

	oPrn:Box(nLinI				,nCol * 14     	,nLinE,nCol * 19 )
	oPrn:say(nLinI	+ 20		,nCol * 14 + 10	,"Data Processamento",oFTitulo,0)
	oPrn:say(nLinI + 60		,nCol * 14 + 10	,DtoC(dDataBase),oFConteudo,0)

	oPrn:Box(nLinI				,nCol * 19     	,nLinE,nCol * 23 )
	oPrn:say(nLinI	+ 20		,nCol * 19 + 10	,"Nosso Número",oFTitulo,0)
	oPrn:say(nLinI + 60		,nCol * 19 + 10	,cNNumImp,oFConteudo,0)


	nLinI += nULinha;	nLinE := nLinI + nULinha
	IF cCodBanc="033" .AND. SEE->EE_SUBCTA $ ('001')

		oPrn:Box(nLinI				,nCol * 01     	,nLinE,nCol * 05 )
		oPrn:say(nLinI	+ 20		,nCol * 01 + 10	,"Carteira",oFTitulo,0)
		oPrn:say(nLinI + 60		,nCol * 01 + 10	,cCarteira,oFConteudo,0)

		//oPrn:Box(nLinI				,nCol * 05     	,nLinE,nCol * 08 )
		//oPrn:say(nLinI	+ 20		,nCol * 05 + 10	,"Carteira",oFTitulo,0)
		//oPrn:say(nLinI + 60		,nCol * 05 + 10	,cCarteira,oFConteudo,0)


	ELSE

		oPrn:Box(nLinI				,nCol * 01     	,nLinE,nCol * 05 )
		oPrn:say(nLinI	+ 20		,nCol * 01 + 10	,"Uso do Banco",oFTitulo,0)
		oPrn:say(nLinI + 60		,nCol * 01 + 10	,"",oFConteudo,0)

		oPrn:Box(nLinI				,nCol * 05     	,nLinE,nCol * 08 )
		oPrn:say(nLinI	+ 20		,nCol * 05 + 10	,"Carteira",oFTitulo,0)
		oPrn:say(nLinI + 60		,nCol * 05 + 10	,cCarteira,oFConteudo,0)

    ENDIF
	oPrn:Box(nLinI				,nCol * 08     	,nLinE,nCol * 10 )
	oPrn:say(nLinI	+ 20		,nCol * 08 + 10	,"Espécie",oFTitulo,0)
	oPrn:say(nLinI + 60		,nCol * 08 + 10	,cEspecie,oFConteudo,0)

	oPrn:Box(nLinI				,nCol * 10     	,nLinE,nCol * 15 )
	oPrn:say(nLinI	+ 20		,nCol * 10 + 10	,"Quantidade",oFTitulo,0)
	oPrn:say(nLinI + 60		,nCol * 10 + 10	,"",oFConteudo,0)

	oPrn:Box(nLinI				,nCol * 15     	,nLinE,nCol * 19 )
	oPrn:say(nLinI	+ 20		,nCol * 15 + 10	,"Valor",oFTitulo,0)
	oPrn:say(nLinI + 60		,nCol * 15 + 10	,"",oFConteudo,0)

	oPrn:Box(nLinI				,nCol * 19     	,nLinE,nCol * 23 )
	oPrn:say(nLinI	+ 20		,nCol * 19 + 10	,"(=) Valor Documento",oFTitulo,0)
	oPrn:say(nLinI + 60		,nCol * 19 + 10	,cValDoc,oFConteudo,0)


	nLinI += nULinha;	nLinE := nLinI + nULinha
	oPrn:Box(nLinI				,nCol * 01     	,nLinE + (nULinha * 4),nCol * 19 )
	oPrn:say(nLinI	+ 20		,nCol * 01 + 10	,"Instruções",oFTitulo,0)
	oPrn:say(nLinI + 60		,nCol * 01 + 10	,"",oFConteudo,0)


	oPrn:say(nLinI + 60		,nCol * 01 + 10	,cInstrL1,oFConteudo,0)
	oPrn:Box(nLinI				,nCol * 19     	,nLinE,nCol * 23 )
	oPrn:say(nLinI	+ 20		,nCol * 19 + 10	,"(-) Descontos / Abatimentos",oFTitulo,0)
	oPrn:say(nLinI + 60		,nCol * 19 + 10	,"",oFConteudo,0)

	nLinI += nULinha;	nLinE := nLinI + nULinha
	oPrn:say(nLinI + 30		,nCol * 01  + 10,cInstrL2,oFConteudo,0)
	oPrn:Box(nLinI				,nCol * 19     	,nLinE,nCol * 23 )
	oPrn:say(nLinI	+ 20		,nCol * 19 + 10	,"(-) Outras Deduções",oFTitulo,0)
	oPrn:say(nLinI + 30		,nCol * 19 + 10	,"",oFConteudo,0)


	nLinI += nULinha;	nLinE := nLinI + nULinha
	oPrn:say(nLinI + 30		,nCol * 01 + 10	,cInstrL3,oFConteudo,0)
	oPrn:Box(nLinI				,nCol * 19     	,nLinE,nCol * 23 )
	oPrn:say(nLinI	+ 20		,nCol * 19 + 10	,"(+) Mora / Multa",oFTitulo,0)
	oPrn:say(nLinI + 30		,nCol * 19 + 10	,"",oFConteudo,0)


	nLinI += nULinha;	nLinE := nLinI + nULinha
	oPrn:say(nLinI + 30		,nCol * 01  + 10	,cInstrL4,oFConteudo,0)
	oPrn:Box(nLinI				,nCol * 19     	,nLinE,nCol * 23 )
	oPrn:say(nLinI	+ 20		,nCol * 19 + 10	,"(+) Outros Acréscimos",oFTitulo,0)
	oPrn:say(nLinI + 30		,nCol * 19 + 10	,"",oFConteudo,0)


	nLinI += nULinha;	nLinE := nLinI + nULinha
	oPrn:say(nLinI + 30		,nCol * 01  + 10	,cInstrL5,oFConteudo,0)

	oPrn:say(nLinI + 60		,nCol * 01  + 10	,cInstrL6,oFConteudo,0)

	oPrn:Box(nLinI				,nCol * 19     	,nLinE,nCol * 23 )
	oPrn:say(nLinI	+ 20		,nCol * 19 + 10	,"(=) Valor Cobrado",oFTitulo,0)
 //   oPrn:say(nLinI + 60	,nCol * 19 + 10	,cValDoc,oFConteudo,0)


	nLinI += nULinha;	nLinE := nLinI + nULinha
	oPrn:Box(nLinI				,nCol * 01     	,nLinE + (nULinha * 2),nCol * 23 )

	IF cCodBanc="033" .AND. SEE->EE_SUBCTA $ ('001')
	   oPrn:say(nLinI	+ 20		,nCol * 01 + 10	,"Pagador",oFTitulo,0)
	ELSE
	   oPrn:say(nLinI	+ 20		,nCol * 01 + 10	,"Sacado",oFTitulo,0)
	ENDIF
	oPrn:say(nLinI + 60		,nCol * 01 + 10	,Alltrim(cSacado)+" - "+cCnpj,oFConteudo,0)
	nLinI += nULinha;	nLinE := nLinI + nULinha
	oPrn:say(nLinI + 20		,nCol * 01 + 10	,cEndSac,oFConteudo,0)
	oPrn:say(nLinI + 60		,nCol * 01 + 10	,cMuESac,oFConteudo,0)

	nLinI += nULinha;	nLinE := nLinI + nULinha
	nLinI += nULinha;	nLinE := nLinI + nULinha
	nLinI += nQLinha;	nLinE := nLinI + nULinha

	IF cCodBanc="033" .AND. SEE->EE_SUBCTA $ ('001')
	    oPrn:say(nLinI - 5,nCol * 01 + 10	,"Pagador/ Avalista",oFTitulo,0)
	ELSE
	    oPrn:say(nLinI - 5,nCol * 01 + 10	,"Sacador/ Avalista",oFTitulo,0)
	ENDIF
	oPrn:say(nLinI - 5,nCol * 18 + 10	,"Autenticação Mecânica-Ficha de Compensação",oFTitulo,0)


	nLinI += nULinha;	nLinE := nLinI + nULinha
	nLinI += nULinha;	nLinE := nLinI + nULinha
	nLinI += nULinha;	nLinE := nLinI + nULinha
	oPrn:Say(nLinI,nCol * 20 ,"Corte na Linha Pontilhada",oFTitulo,0)

	nLinI += nDLinha;	nLinE := nLinI + nULinha
	oPrn:Say(nLinI,nCol * 1  ,cLinha,oFlinha,0) //| Linha

	oPrn:FWMsBar("INT25", 58.3, 2.3, cCodBarra, @oPrn, .F., Nil, .T., 0.025, 1.4, .F., Nil, Nil, .F., Nil, Nil)

	oPrn:EndPage() //| Finaliza a Pagina

	If lPriVia
		oPrn:Preview()
		//	| oPrn:end()  //| Encerra a Impressao...
	EndIf

Return()
*********************************************************************
Static Function Mod10(cParte,nPeso)//| Calculo do Digito Verificador
*********************************************************************
	Local nSoma 	:= 0
	Local nACDec	:= 0
	Local nDigVer	:= 0
	Local cVal	 	:= ""
	Local cDigver	:= ""

	For I := 1 To Len(cParte)

		cVal 	:= StrZero(Val(SubStr(cParte,I,1)) * nPeso,2)
		nSoma 	+= Val(Substr(cVal,1,1)) + Val(Substr(cVal,2,1))

		If nPeso==1
			nPeso := 2
		Else
			nPeso := 1
		EndIf

	Next

	If cCodBanc == '001' .And. cCarteira == '17'
	*******
		nACDec	:= Val(StrZero(Val(Substr(Strzero(nSoma,2),1,1)) + 1,2)+"0") //| Soma a Casa Decimal da Soma Ex.: nSoma == 25 -> nSoma := 30
		cCalc	:= StrZero(nACDec - nSoma,2)
		cDigver := Substr(cCalc,2,1)

	ElseIf (cCodBanc $('341/033/356/237/745')) .Or. (cCodBanc == '001' .And. cCarteira <> '17')
	*******
		nACDec	:= (nSoma%10)
		cCalc	:= 10 - nACDec
		cDigver := StrZero(If(cCalc==10,0,cCalc),1)

	EndIf

Return(cDigver)
*********************************************************************
Static Function Mod11(cCodigo)//Calculo Modulo 11
*********************************************************************
	nPeso	:= 2
	nSoma	:= 0

	For l := Len(cCodigo) To 1 Step -1

		nSoma += Val(Substr(cCodigo,l,1)) * nPeso

		If nPeso == 9
			nPeso := 2
		Else
			nPeso += 1
		Endif

	Next

	nResto 	:= (nSoma%11)

	nDigito	:= 11 - nResto

	Do Case
	Case nDigito == 0
		nDigito := 1
	Case nDigito == 10
		nDigito := 1
	Case nDigito == 11
		nDigito := 1
	OtherWise
		nDigito := nDigito
	EndCase

Return(StrZero(nDigito,1))


*********************************************************************
Static Function Mod11S(cCodigo)//Calculo Modulo 11
*********************************************************************
	nPeso	:= 2
	nSoma	:= 0

	For l := Len(cCodigo) To 1 Step -1

		nSoma += Val(Substr(cCodigo,l,1)) * nPeso

		If nPeso == 9
			nPeso := 2
		Else
			nPeso += 1
		Endif

	Next

	nResto 	:= (nSoma%11)

    if nResto==10
       nDigito:=1
    ElseIf nResto==0 .or. nResto==1
       nDigito:=0
    Else
       nDigito	:= 11 - nResto
    EndIf

Return(StrZero(nDigito,1))




*********************************************************************
Static Function BuscaNum()	//| Calculo do Digito Verificador do Nosso Numero
*********************************************************************
	If Empty(SE1->E1_NUMBCO)

		cNum := Alltrim(SEE->EE_FAXATU)

		DbSelectArea("SEE")
		Reclock("SEE",.F.)
		SEE->EE_FAXATU := PadL(Alltrim(Str(Val(cNum)+1)),10,"0")
		MsUnlock()

	Else
		cNum := Alltrim(SE1->E1_NUMBCO)
	EndIf

Return(cNum)

*********************************************************************
Static Function SBuscaNum()	//| Calculo do Digito Verificador do Nosso Numero
*********************************************************************
	If Empty(SE1->E1_NUMBCO)
	    //0000000011
		cNum := Alltrim(SEE->EE_FAXATU)

		DbSelectArea("SEE")
		Reclock("SEE",.F.)
		SEE->EE_FAXATU := PadL(Alltrim(Str(Val(cNum)+1)),10,"0")
		MsUnlock()
        cNUM:=SUBSTR(cNum,4,7)+MOD11S(SUBSTR(cNum,4,7)) //numero novo + digito
	Else
		cNum := Alltrim(SE1->E1_NUMBCO)   //ja tem gravado o numero+digito
	EndIf

Return(cNum)
*********************************************************************




*********************************************************************
Static Function MarcaTitulo() //| Marca Titulo como Emitido Boleto no Faturamento
*********************************************************************

	If Empty(SE1->E1_NUMBCO)
		DbSelectArea("SE1")
		Reclock("SE1",.F.)
		SE1->E1_HIST 		:= "BOLFAT "+Alltrim(SE1->E1_HIST)
		SE1->E1_NUMBCO		:= cNossoNum
		SE1->E1_PORTADO	    := cCodBanc
		SE1->E1_AGEDEP		:= cAgencia
		SE1->E1_CONTA		:= cContaCor
		SE1->E1_CODBAR		:= cCodBarra
		MsUnlock()
	EndIf

Return(.T.)
*********************************************************************
Static Function PrintPdf() //| Prepara Para Geracao por PDF
*********************************************************************
	Local cFileLocal	:= cFilePrintert //"boletos.pdf"
	Local cFileSys		:= cFilePrintert //"bol"+__cuserid+".pdf"


	If !ExistDir(cLocalPath) 		//| Verifica Existencia do Diretorio MP10
		MakeDir(cLocalPath) 		//| Cria o Diretorio
	EndIf

	aRetPFile := {cLocalPath + cFileLocal, cPathInServer + cFileSys }

	oPrn:IsPrinterActive()

	oPrn:linjob := ( !lSetView ) // Indica que sera esta em MODO JOB... isso foi usado para n‹o ser apresentada qualquer mensagem...

	sleep(1000)

	///oPrn:Print()

Return
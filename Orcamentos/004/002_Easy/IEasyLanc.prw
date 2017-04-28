#Include 'Totvs.ch'

#Define INCDESP "I"
#Define ESTDESP "E"
#Define ZERO     0

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNÇÃO   : IEasyLanc.prw | AUTOR : Cristiano Machado | DATA : 23/04/2017  **
**---------------------------------------------------------------------------**
** DESCRIÇÃO: Efetua os Lancamentos CE Mercante - Despesa (442)              **
**---------------------------------------------------------------------------**
** USO : Especifico para Imdepa Easy                                         **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
** ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL. **
**---------------------------------------------------------------------------**
** PROGRAMADOR | DATA | MOTIVO DA ALTERACAO **
**---------------------------------------------------------------------------**
**   |  | **
**   |  | **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User function IEasyLanc(cHawb, xIncExt) //| cHawb => Numero do Processo.... xIncExt => I-Incluir | E-Excluir
*******************************************************************************
	Local cCodDCE := SuperGetMv( cParametro := "IM_DESPCE", lHelp := .F., xDefault := "442", cFilU := ""  )
	Local cLanPad := "IE" 		//Codigo do Lancamento Padrao. "IEA"- Imdepa Easy [ A -> Inclui | B -> Exclui ]

	cLanPad := "IE" + If( xIncExt==INCDESP , "A", "B") //

	Public nTotDesp := 0 			// Total a Contabilizar Despesa 442

	//| Verifica se processo possui DespesCE Mercante
	If VerHawb(cHawb, cCodDCE) > ZERO

		ExecLP(cLanPad)

	EndIf

Return()
*******************************************************************************
Static Function ExecLP(cLanPad)
*******************************************************************************

	Local cLote		:= "008850"		// Lote a Ser Utilizado...
	Local cProcess	:= "DESPCEMER"	// Nome do Processo
	Local cFile		:= ""			// Arquivo de Lancamento
	Local nHdlPrv	:= 0			// Arquivo Binario
	Local lDigita 	:= .T.			// Abri o Lancamento para Digitacao 
	Local lAglut 	:= .F.			// Aglutina Lançamento
	Local cUserLog  := SubStr(cUsuario,7,6)
	Local nTotal    := 0
	
	DbSelectArea("CT5")
	If Abs(nTotDesp) > 0
		
		lPadrao := VerPadrao(cLanPad) //| Verifica se o codigo da LANPADRAO Padronizado existe. MATXFUN.PRX
		If lPadrao
		
			nHdlPrv := HeadProva(cLote,cProcess,cUserLog,@cFile)
			nTotal  += DetProva(nHdlPrv,cLanPad,cProcess,cLote)
			RodaProva( @nHdlPrv ,@nTotal)
			cA100Incl( @cFile ,@nHdlPrv,3,@cLote,@lDigita,@lAglut, /*cOnLine := "C"*/ )
		
		EndIf
		
	EndIf

Return()
*******************************************************************************
Static Function VerHawb(cHawb, cCodDCE) // Verifica se Existe Despesa 442 no Processo
*******************************************************************************
	Local cSql 	:= ""

	cSql := "SELECT WD_HAWB, WD_DESPESA, WD_VALOR_R VALOR FROM SWD010 WHERE D_E_L_E_T_ = ' ' AND WD_DESPESA = '"+cCodDCE+"' AND WD_HAWB = '"+cHawb+"'"

	U_ExecMySql( cSql , "TVDH" , "Q", .F., .F. )

	DbSelectArea("TVDH");DbGotop()
	If !Eof()
		nTotDesp := TVDH->VALOR
	Else
		nTotDesp := 0
	EndIf
	DbCloseArea()

Return(nTotDesp)
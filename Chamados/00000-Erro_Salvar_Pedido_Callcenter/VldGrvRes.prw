#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#DEFINE  ENTER CHR(13)+CHR(10)

/*
******************************************************************************
******************************************************************************
******************************************************************************
***Funcao    |VldGrvRes |Autor  :Fabiano Pereira        |Data   24/02/2016 ***
******************************************************************************
***Parametros:                                                             ***
***          *Valida \ Grava Reservas - Projeto Correias Fechadas\Abertas  ***
***          *                                                             ***
***          *                                                             ***
***          *                                                             ***
***          *                                                             ***
******************************************************************************
***Uso       *Generico                                                     ***
******************************************************************************
******************************************************************************
******************************************************************************
*/
**********************************************************************
User Function VldGrvRes()		// CHAMADO VIA CHKCORREIAS.PRW->ValItemConf() / TMKVFIM.PRW 
**********************************************************************
Local aArea	:= 	GetArea()
Local aPVxRes	:=	{}
Local aNotSaldo	:=	{}
Local cBckFil	:=	cFilAnt
Local cFilEst	:=	AllTrim(GetMv('MV_FILESTC'))
Local cNumAT	:=	SUA->UA_NUMSC5
Local lGravaRes	:=	IIF(Type('ParamIxb')== 'A', ParamIxb[01], .F.)
Local aPTransf	:=	IIF(Type('ParamIxb')== 'A', (IIF(Len(ParamIxb)>=2, ParamIxb[02], {})), {})


If Ascan(aProdXImp, {|X| !Empty(X[09])}) > 0

	For nX := 1 To Len(aProdXImp)

		cItemAProd 	:= 	aProdXImp[nX][01]
		nLnaCols 	:=	Ascan(aCols, {|X| X[1] == cItemAProd })
		If nLnaCols == 0
			Loop
		Else
			If aCols[nLnaCols][Len(aHeader)+1]
				Loop   
			EndIf
		EndIf


		If !Empty(aProdXImp[nX][09]) 

			cItemAT 	:=	aProdXImp[nX][01]
			cDescProd	:=	aProdXImp[nX][03]

			aReserva := StrTokArr(aProdXImp[nX][09],"{}")
			For nR := 1 To Len(aReserva)								

				aItemRes	:=	StrTokArr(aReserva[nR],",")


				// cReserva += '{'+cProd+','+cLarg+','+cQuant+','+cAlmox02+','+cFilRes+','+cComp+'}'
				// 	{01106006100,1,2,01,09}
				// [01] PRODUTO 
				// [02] LARGURA 
				// [03] QUANT
				// [04] LOCAL 
				// [05] FILIAL EST
				// [06]	COMPRIMENTO

				
				cProduto 	:=	PadR(aItemRes[01], TamSx3('B2_COD')[01],'')
				nQuantAT	:=	Val(aItemRes[03])
				cLocal		:=	aItemRes[04]
				cFilRes		:=	aItemRes[05]



				//**********************************************
				//  TROCA A FILIAL CONFORME RESERVA \ ESTOQUE 	*
				//***********************************************
				cFilAtu		:=	cFilAnt
				cFilAnt		:=	cFilRes
	              
				nPosT	 	:= 	Ascan(aPTransf, {|X| AllTrim(X[02]) ==  AllTrim(cItemAT) })
				cPTransf 	:= 	IIF(nPosT > 0, aPTransf[nPosT][03], '')
				lReserva 	:=	IIF(!Empty(cPTransf), .F., .T.)
				
				DbSelectArea('SB2');DbSetOrder(1)
				DbSeek(xFilial('SB2')+cProduto+cLocal, .F.)
				nSaldoSB2	:=	SaldoSB2()//,,,,,,,,lReserva)


				//******************************************************************************************
				//*  VERIFICAR CAMPO UB_FILTRAN POIS ACOLS JA ESTA ALIMENTADO COM O NUMERO DA FILIAL		|
				//|  O CAMPO UB_PLANILH Eh PREENCHIDO NO SUB->UB_PLANILH E O ACOLS ESTA VAZIO NESSE MOMENTO	|
				//*******************************************************************************************
				// Aadd(aPTransf, {SC6->C6_NUM, SC6->C6_ITEM, SC6->C6_PRODUTO, SC6->C6_PLANILH, SC6->C6_PLITEM}) <- TMKVFIM.PRW
				nPosT	 := Ascan(aPTransf, {|X| AllTrim(X[02]) ==  AllTrim(cItemAT) })
				cPTransf := IIF(nPosT > 0, aPTransf[nPosT][04], '')
				If !Empty(cPTransf)
                                                             
					
					//******************************************************************
					//*  QDO ITEM DE TRANSFERENCIA VERIFCA SE GEROU A TRANSF...         |
					//|  SE GEROU TRANSF. B2_RESERVA JA ESTARA COM O VALOR DA QUANT.	|
					//|  NAO Eh NECESSARIO GERAR SC0									|
					//*******************************************************************
        
					IIF(Select('TRANSF')!=0, TRANSF->(DbCloseArea()), )

					cQuery := "SELECT 	C6_FILIAL, C6_NUM, C6_PRODUTO, C6_ITEM, C6_PLITEM, C6_PLANILH, C6_FILTRAN "+ENTER
					cQuery += "FROM 	"+RetSqlName("SC6")+ " SC6 "+ENTER
					cQuery += "WHERE 	C6_FILIAL	= '"+GdFieldGet('UB_FILTRAN', nLnaCols)+"' "+ENTER
					cQuery += "AND		C6_PLANILH 	= '"+cPTransf+"' "+ENTER
					cQuery += "AND		C6_PRODUTO 	= '"+GdFieldGet('UB_PRODUTO', nLnaCols)+"' "+ENTER
					cQuery += "AND   	D_E_L_E_T_ != '*'"+ENTER
				
					DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TRANSF', .F., .T.)
					
					lTransf := !Empty(TRANSF->C6_PLANILH, .T., .F.)

					IIF(Select('TRANSF')!=0, TRANSF->(DbCloseArea()), )
                    
                    If lTransf
						//**************************************************************
						//* OUTRA OPCAO Eh GERAR UMA RESERVA (SC0) COM QUANT = ZERO		|
						//| APENAS PARA MANTER UM HISTORICO.							|
						//| NAO GERANDO RESERVA - SC0 APENAS TERA UM REGISTRO NO SB2	|
						//| CAMPO B2_RESERVA (TB NAO TEM PROBLEMA ALGUM NAO GERAR SC0	|
						//| PARA ESSE REGISTRO DA FILIAL SP)							|
						//***************************************************************
						Loop
					EndIf

				EndIf

				
				cTpReserva	:=	'PD'			//	VD - Vendedor | CL - Cliente | PD - Pedido | LB - Liberacao | NF - Nota fiscal
				cDocRes		:=	cNumAT+cItemAT
				cSolicit	:=	cUserName
				cObs		:=	'AT: '+cNumAT+cItemAT

								// VERIFICA SE EXISTE RESERVA
				aRetRes		:=	ChkOpNumRes(cTpReserva, cDocRes, cFilRes, cProduto, cLocal, cBckFil, nQuantAT)		//  1-Inclui | 2-Altera | 3-Exclui	
				nOperRes 	:= 	aRetRes[01]			//  1-Inclui | 2-Altera | 3-Exclui
				cNumero 	:= 	aRetRes[02]
                lProssegue	:=	aRetRes[03]
                                              
				If !lProssegue
					//**************************************************************
					//*  EX.: F10 + CONFIRMA AT - NAO PRECISA ANALISAR NOVAMENTE	|
					//***************************************************************
					Loop
				EndIf



				If lProssegue .And. nSaldoSB2 >= nQuantAT

					aOperacao	:=	{nOperRes, cTpReserva, cDocRes, cSolicit, cFilAtu, cObs}
					
					IIF(Select('SBF')==0.Or.Empty(Alias()), (ChkFile('SBF'),DbSelectArea("SBF")),)
					nSaldoSBF 	:= 	IIF(Localiza(cProduto),  SaldoSBF(cLocal,'',cProduto,'','',''), 0)
					aEndereco  	:= 	IIF(!Localiza(cProduto), {{'',0}}, IIF(nSaldoSBF < nQuantAT, {{'',0}}, ChkEndereco(cProduto, cLocal, cFilRes, nQuantAT, nOperRes)) )


					If lGravaRes
						For nE := 1 To Len(aEndereco)
	
							cNumLote	:= 	''
							cLoteCt		:= 	''				
							cNumSeri  	:= 	''
							cLocaliz	:=	aEndereco[nE][01]
							nQuantEnd	:=	aEndereco[nE][02]
							nQuantRes	:=	IIF(nQuantEnd==0, nQuantAT,  nQuantEnd)
	
							aLote		:=	{cNumLote, cLoteCt, cLocaliz, cNumSeri}
	
							cNumero		:=	IIF(Empty(cNumero), (GetSx8Num("SC0","C0_NUM"), ConfirmSx8()), cNumero)
	
	
							If a430Reserv( aOperacao, cNumero, cProduto, cLocal, nQuantRes, aLote, {}, {}  )
								Aadd(aPVxRes, {SUA->UA_NUMSC5, cItemAT, cProduto, SC0->C0_NUM, cFilRes, nQuantRes} )
							Else
								Aadd(aNotSaldo, {cItemAT, cProduto, cDescProd, cLocal, nQuantAT, nQuantRes, 'RESERVA', cFilRes})
							EndIf
	
							SC0->(MsUnLock())   // Begin Transaction End Transaction

						Next
					EndIf

					
					If Len(aEndereco) == 0
						Aadd(aNotSaldo, {cItemAT, cProduto, cDescProd, cLocal, nQuantAT, nSaldoSBF, 'SALDOSBF', cFilRes})
					EndIf

				Else
					Aadd(aNotSaldo, {cItemAT, cProduto, cDescProd, cLocal, nQuantAT, nSaldoSB2, 'SALDOSB2', cFilRes})
				EndIf


				cFilAnt := cFilAtu
				//**********************
				//*   RETORNA FILIAL	*
				//***********************

			Next
	    
		Else
		
			// lCorreia :=	!Empty(A093VldBase(GdFieldGet("UB_PRODUTO",xY))) chamado: 
	        lCorreia :=	!Empty(A093VldBase(GdFieldGet("UB_PRODUTO",nX)))
	        If lCorreia
				//******************************************************
				//*  SE ARRAY aProdXImp[n][09] EM BRANCO E Eh CORREIA	*
				//*******************************************************
				
				// GRAVAR NO LOGDIVERG ????
				
			EndIf

		EndIf
	
	Next



	If Len(aNotSaldo) > 0
		aSort(aNotSaldo,,,{|X,Y| X[1] < Y[1]})
		*******************************
			TelaDiverg(aNotSaldo)
		*******************************		
	EndIf


Else

	/*
	// VALIDACAO JA ESTA NA TELA F6 - TKGRPED.PRW
	For xY := 1 To Len(aCols)
		lCorreia :=	!Empty(A093VldBase(GdFieldGet("UB_PRODUTO",xY)))
		If lCorreia
	                
			If !ChkSC9Lib(SUA->UA_NUMSC5, GdFieldGet("UB_ITEM",xY), GdFieldGet("UB_PRODUTO",xY))
				//**********************************************
				//|          PROJETO CORREIAS            		|
				//| VERIFICA SALDOs DOS ITENS DO ATENDIEMTNTO	|
				//***********************************************
				cRotina  	:= 	'TKGRPED'
				aOpcao	 	:=	{'VALID_SALDO'}
				cProduto 	:= 	GdFieldGet("UB_PRODUTO",xY)
				aParam	 	:= 	{}
				nLinha	 	:= 	xY
				xRetorno 	:=	'ARRAY_DIVERG'
				aRetorno 	:= 	ExecBlock('ChkCorreias', .F., .F., {cRotina, aOpcao, cProduto, aParam, nLinha, xRetorno})
				aProblem 	:=	aRetorno
				If Len(aProblem) > 0
					aDivCor := aProblem
				EndIf
			EndIf
			
		EndIf
    Next
	*/    
EndIf

cFilAnt := cBckFil
RestArea(aArea)
Return()

/*/
*****************************************************************************
*****************************************************************************
****************************************************************************
***Funcao    *A430Reserv* Autor *Eduardo Riera          * Data *11.08.98  ***
****************************************************************************
***Descricao * Reserva um determinado Produto                             ***
****************************************************************************
***Retorno   * ExpL1 := Indica se o Produto foi reservado                 ***
****************************************************************************
***Parametros* aReserva: [Operacao : 1 Inclui,2 Altera,3 Exclui]      	  ***
***          *           [Tipo da Reserva]                                ***
***          *           [Documento que originou a Reserva]               ***
***          *           [Solicitante]                                    ***
***          *           [Filial da Reserva]                              ***
***          *           [Observacao]                                     ***
***          * cNumero : Numero da Reserva                                ***
***          * cProduto: Produto da Reserva                               ***
***          * cLocal  : Local                                            ***
***          * nQuant  : Quantidade a ser reservada                       ***
***          * aLote   : [Numero do Lote]                                 ***
***          *           [Lote de Controle]                               ***
***          *           [Localizacao]                                    ***
***          *           [Numero de Serie]                                ***
***          * cTipoRes: Tipo da Reserva                                  ***
***          * cDocRes : Documento que originou a reserva                 ***
***          * cSolicit: Solicitante                                      ***
***          * cFilRes : Filial de Reserva                                ***
***          * aheader : Qdo for MATA430                                  ***
***          * aCols   : Qdo for MATA430 -> Item do acols Ex. aCols[1]	  *** 
***          * nQuantElim :				                                  ***
***          * lLoja   : Se Foi chamado a apartir do loja				  ***
*****************************************************************************
*****************************************************************************
*****************************************************************************
/*/
**********************************************************************
Static Function ChkEndereco(cProduto, cLocal, cFilRes, nQuantRes, nOperRes)
**********************************************************************
Local cEndereco	:=	''
Local aEndereco := 	{}
Local lQtdAtend	:=	.F.
Local nTotalSBF	:=	0
Local nSbfQtd	:=	0



/*
SALDO 		 25
GRAVEI SC0   10
             --
NOVO SALDO   15

ALTERAR AT	 20 // saldo no BrowserPAsPP nao considerar apenas 15 (considerar os 10 do AT atual + 15 )
SC0 = 15 ->  20	      
      
		QUANT	EMPENHO
SBF = 	  20	  15     SALDO = 05 (20-15=05)
NA ALTERACAO QUERO 20 (SE FAZER QTD - EMP = APENAS 5)
			Q    E     S
			50	 40	   10	(JA TINHA RES DE 10 AGORA QUERO = 15)
							(OUTRO AT = 30)

*/

If nOperRes == 2	// nOperRes :=  1-Inclui | 2-Altera | 3-Exclui	       

	//**************************************************
	//* Checa se o saldo da Localizacao e suficiente	*
	//***************************************************
    DbSelectArea('SBF');DbSetOrder(2);DbGoTop()	// BF_FILIAL+BF_PRODUTO+BF_LOCAL+BF_LOTECTL+BF_NUMLOTE+BF_PRIOR+BF_LOCALIZ+BF_NUMSERI
    If DbSeek(xFilial('SBF') + cProduto + cLocal, .F.)

    	cEndereco	:=	SBF->BF_LOCALIZ
		nSaldoSBF	:= 	SBF->BF_QUANT - SBF->BF_EMPENHO

		If nSaldoSBF >= nQuantRes
			nQtdEnder 	:=	nSaldoSBF
		Else
			nQtdEnder 	:= 	nQuantRes
		EndIf
		
		Aadd(aEndereco, {cEndereco, nQtdEnder })
	
    EndIf

EndIf



IIF(Select('TMPE')!=0, TMPE->(DbCloseArea()), )
cQuery	:= " SELECT *									"+ENTER
cQuery 	+= " FROM 	"+RetSqlName("SBF")+" SBF 			"+ENTER
cQuery 	+= " WHERE 	SBF.BF_FILIAL 	 = '"+cFilRes+"' 	"+ENTER
cQuery 	+= " AND 	SBF.BF_PRODUTO 	 = '"+cProduto+"' 	"+ENTER
cQuery 	+= " AND 	SBF.BF_LOCAL 	 = '"+cLocal+"'  	"+ENTER
If nOperRes == 2	// ALTERACAO
	cQuery 	+= " AND 	SBF.BF_LOCALIZ 	!= '"+cEndereco+"'	"+ENTER
	cQuery 	+= " AND 	SBF.BF_QUANT -  (SBF.BF_EMPENHO - "+AllTrim(Str(nQuantRes))+")	>  0"+ENTER
Else
	cQuery 	+= " AND 	(SBF.BF_QUANT - SBF.BF_EMPENHO )	>  0"+ENTER
EndIf
cQuery 	+= " AND 	SBF.D_E_L_E_T_	!= '*' 				"+ENTER

DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), 'TMPE', .F., .T.)
DbSelectArea('TMPE');DbGoTop()
Do While !Eof()

	nSaldoSBF	:= 	(TMPE->BF_QUANT - TMPE->BF_EMPENHO)
	nTotalSBF 	+=	nSaldoSBF
        //  10  (10) <=	25	
        //  05  (15) <=	25	
        //  20  (35) >=	25	
        
        //  01  (01)  > 0.16
	If nTotalSBF <= nQuantRes
		nQtdEnder 	:=	nSaldoSBF
	Else
		nTotEnder := 0
		aEval(aEndereco, {|X| nTotEnder += X[02]})
		nVlrMin 	:=	Min(nTotEnder, nQuantRes)
		nVrlMax		:=	Max(nTotEnder, nQuantRes)
		nQtdEnder 	:= 	(nVrlMax - nVlrMin)			//nQuantRes //nTotalSBF - nQuantRes
	EndIf
	
	Aadd(aEndereco, {TMPE->BF_LOCALIZ, nQtdEnder })


	If nTotalSBF >= nQuantRes
		lQtdAtend := .T.
		Exit
	EndIf
	DbSelectArea('TMPE')
	DbSkip()
EndDo

If !lQtdAtend
	aEndereco := {{'',0}}
EndIf

IIF(Select('TMPE')!=0, TMPE->(DbCloseArea()), )
Return(aEndereco)
**************************************************************************************
Static Function ChkOpNumRes(cTpReserva, cDocRes, cFilRes, cProduto, cLocal, cBckFil, nQuantAT)
**************************************************************************************
Local aRetorno 	:= 	{}

IIF(Select('TMPR')!=0, TMPR->(DbCloseArea()), )
cQuery	:= " SELECT *										"+ENTER
cQuery 	+= " FROM 	"+RetSqlName("SC0")+" SC0 				"+ENTER
cQuery 	+= " WHERE 	SC0.C0_FILIAL 	 = '"+xFilial('SC0')+"'	"+ENTER
cQuery 	+= " AND	SC0.C0_FILRES 	 = '"+cBckFil+"' 		"+ENTER
cQuery 	+= " AND 	SC0.C0_TIPO 	 = '"+cTpReserva+"'		"+ENTER
cQuery 	+= " AND 	SC0.C0_PRODUTO 	 = '"+cProduto+"' 		"+ENTER
cQuery 	+= " AND 	SC0.C0_LOCAL 	 = '"+cLocal+"'  		"+ENTER
cQuery 	+= " AND 	SC0.C0_DOCRES 	 = '"+cDocRes+"'  		"+ENTER
cQuery 	+= " AND 	SC0.D_E_L_E_T_	!= '*' 					"+ENTER

DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), 'TMPR', .F., .T.)
DbSelectArea('TMPR');DbGoTop()
Aadd(aRetorno, IIF(Empty(TMPR->C0_NUM), 1, 2))		//  1-Inclui | 2-Altera | 3-Exclui
Aadd(aRetorno, TMPR->C0_NUM)
Aadd(aRetorno, IIF(!Empty(TMPR->C0_NUM).And.TMPR->C0_QUANT==nQuantAT, .F., .T.))

IIF(Select('TMPR')!=0, TMPR->(DbCloseArea()), )
Return(aRetorno)
**********************************************************************
Static Function TelaDiverg(aNotSaldo)
**********************************************************************

	//******************************************
	//|   		TELA CORREIAS SEM SALDO  		|
	//*******************************************
	//					   [01]		[02]	   [03]		[04]	[05]      [06]       [07]	  [08]
	//	Aadd(aNotSaldo, {cItemAT, cProduto, cDescProd, cLocal, nQuantAT, nQtdDisp, 'SALDO', cFilRes})

	Define Dialog oDlgDiv Title "Produto(s) Correia Sem Saldo" From 120,120 To 360,780 Pixel 
	
		oFont1	:= TFont():New( "Arial",0,16,,.T.,0,,700,.F.,.F.,,,,,, )
	    oBrowse := TcBrowse():New(020, 001, 330, 085,,{'Item', 'Produto', 'Descricao', 'Local', 'Quant.','Disponivel','Tipo','Fil.Orig'},{/*50,50,50*/},oDlgDiv,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	    oBrowse:SetArray(aNotSaldo)
	
		oSay1  := TSay():New( 007,040,{||" PRODUTO \ CORREIA SEM SALDO  X RESERVAS -  OS SEGUINTES ITENS NAO SERAO GRAVADOS"+Space(25) },,,oFont1,.F.,.F.,.F.,.T.,CLR_HRED,CLR_WHITE,350,020 )
		
	    oBrowse:AddColumn( TcColumn():New('Item'		,{|| aNotSaldo[oBrowse:nAt][01] },,,,"LEFT",,.F.,.T.,,,,.F.,))
	    oBrowse:AddColumn( TcColumn():New('Produto'		,{|| aNotSaldo[oBrowse:nAt][02] },,,,"LEFT",,.F.,.T.,,,,.F.,))
	    oBrowse:AddColumn( TcColumn():New('Descricao'	,{|| aNotSaldo[oBrowse:nAt][03] },,,,"LEFT",,.F.,.T.,,,,.F.,))
	    oBrowse:AddColumn( TcColumn():New('Local'		,{|| aNotSaldo[oBrowse:nAt][04] },,,,"LEFT",,.F.,.T.,,,,.F.,))
	    oBrowse:AddColumn( TcColumn():New('Quant.'		,{|| aNotSaldo[oBrowse:nAt][05] },,,,"LEFT",,.F.,.T.,,,,.F.,))
	    oBrowse:AddColumn( TcColumn():New('Disponivel'	,{|| aNotSaldo[oBrowse:nAt][06] },,,,"LEFT",,.F.,.T.,,,,.F.,))	    
	    oBrowse:AddColumn( TcColumn():New('Tipo'		,{|| aNotSaldo[oBrowse:nAt][07] },,,,"LEFT",,.F.,.T.,,,,.F.,))
	    oBrowse:AddColumn( TcColumn():New('Fil.Orig'	,{|| aNotSaldo[oBrowse:nAt][08] },,,,"LEFT",,.F.,.T.,,,,.F.,))
	
	    				        
	    TButton():New( 107, 290, '&OK',  oDlgDiv,{|| lRetorno:= .F., oDlgDiv:End() },30,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	Activate Dialog oDlgDiv Centered

Return()
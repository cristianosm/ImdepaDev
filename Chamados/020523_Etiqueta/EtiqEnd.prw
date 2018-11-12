#Include "Totvs.ch"

#Define _ENDER_ 	1
#Define _CODBA_ 	2
#Define _DIGVE_ 	3

#Define _PICKING_  '1'
#Define _PALLET_   '2'

#Define _E_ 		1
#Define _D_			2

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNÇÃO   : EtiqEnd    | AUTOR : Jeferson Luis    | DATA : 05/04/1999      **
**---------------------------------------------------------------------------**
** DESCRIÇÃO: Rotina de impressao de etiquetas codigo de Barras do cadastro  **
**            de enderecos                                                   **
**---------------------------------------------------------------------------**
** USO : Especifico para WMS Imdepa Rolamentos                               **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
** ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                         **
**---------------------------------------------------------------------------**
** PROGRAMADOR  |  DATA  | MOTIVO DA ALTERACAO                               **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
** Cristiano SM |09/11/18| Reescrito o Codigo e ajustado layout de impressao **
**---------------------------------------------------------------------------**
**              |        |                                                   **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User Function EtiqEnd()
*******************************************************************************
	Private cEnd1		:= Space(20)
	Private cEnd2		:= Space(20)
	Private cTpEstrut 	:= Space(01)

	Pergunte("ETIQEND",.T.)

	cTpEstrut := cValToChar(MV_PAR03)

	Processa({|| Eti() }, "Etiqueta de Enderecos")

Return Nil
*******************************************************************************
Static Function Eti() // Imprime codigo de barras
*******************************************************************************

	Local oFontDiV	:= TFont():New("Times New Roman",18,18,.T.,.T.,,,,,.F.)  //Arial-Negrito-tam 24
	Local oFontPic  := TFont():New("Arial"          ,32,32,.T.,.T.,5,.T.,5,.T.,.F.)
	Local oFontPal  := TFont():New("Arial"          ,52,52,.T.,.T.,5,.T.,5,.T.,.F.)

	Local lDireito 	:= .F.
	Local lEsquerdo := .T.
	Local nPL		:= _E_
	Local bAltLado := {|| If( lEsquerdo ,( lEsquerdo := .F. , lDireito := .T. , nPL := _D_ ) , ( lEsquerdo := .T. , lDireito := .F. , nPL := _E_ ) ) }
	
	ProcRegua(0)

	IncProc("Buscando Enderecos...")
	SF01_Seleciona_Enderecos()

	If cTpEstrut == _PICKING_ // Impressao de Etiquetas Picking [PIMACO 3x2]
		
		oFont 	:= oFontPic
		
		nLimteL	:= 10										//| Limite de Linhas Impressas por Pagina 
		nLImp	:= 0										//| Numero de Linhas ja impressas
		nPILin 	:= 250 										//| Posicao da Linha Inicial
		nPLinA 	:= nPILin									//| Posicao da Linha Atual durante o Movimento
		
		nTSLGe	:= 302										//| Tamanho Salto Linha Geral
		bSPLin 	:= {|| nPLinA += 302, nLImp += 1 } 			//| Salta Linha
		bReLin 	:= {|| nPLinA := nPILin, nLImp := 0 }		//| Reseta a Linha

		aPLEnd 	:= { 0   , 0    } 							//| Array Posicao Linha Endereco
		aPCEnd 	:= { 130 , 1300 } 							//| Posicao Coluna Endereco

		aPLDiv 	:= { 80  , 80   } 							//| Posicao Linha Digito Verificados
		aPCDiv 	:= { 890 , 2090 }  							//| Posicao Coluna Digito Verificados

		nPLBar	:= 2.00										//| Posicao Linha Barra
		aPLBar 	:= { nPLBar , nPLBar }  					//| Array Posicao Linha Barra
		aPCBar 	:= { 6.20 , 16.30 }  						//| Array Posicao Coluna Barra

		nTSLBar	:= 2.55										//| Tamanho Salto Linha Codigo Barra
		bSPLBar := {|| aPLBar[_E_] += nTSLBar ,aPLBar[_D_] += nTSLBar } //| Salta Linha Codigo de Barras
		bReLBar := {|| aPLBar[_E_] := nPLBar  ,aPLBar[_D_] := nPLBar } //| Reseta a Linha Codigo de Barras
		
	ElseIf cTpEstrut == _PALLET_ // Impressao da Etiqueta Pallet [PIMACO 3x2]
		
		oFont 	:= oFontPal
		
		nLimteL := 3										//| Limite de Linhas Impressas por Pagina 
		nLImp	:= 0										//| Numero de Linhas ja impressas
		nPILin 	:= 350 										//| Posicao da Linha Inicial
		nPLinA 	:= nPILin									//| Posicao da Linha Atual durante o Movimento
		
		nTSLGe	:= 1000										//| Tamanho Salto Linha Geral
		bSPLin 	:= {|| nPLinA += nTSLGe, nLImp += 1 } 		//| Salta Linha
		bReLin 	:= {|| nPLinA := nPILin, nLImp := 0 }		//| Reseta a Linha

		aPLEnd 	:= { 0   , 0    } 							//| Array Posicao Linha Endereco
		aPCEnd 	:= { 130 , 1380 } 							//| Posicao Coluna Endereco

		aPLDiv 	:= { 370  , 370 } 							//| Posicao Linha Digito Verificados
		aPCDiv 	:= { 580  , 1830 }  						//| Posicao Coluna Digito Verificados

		nPLBar	:= 5.50										//| Posicao Linha Barra
		aPLBar 	:= { nPLBar , nPLBar  }  					//| Array Posicao Linha Barra
		aPCBar 	:= { 3.65 , 14.15 }  						//| Array Posicao Coluna Barra

		nTSLBar	:= 8.50										//| Tamanho Salto Linha Codigo Barra
		bSPLBar := {|| aPLBar[_E_] += nTSLBar ,aPLBar[_D_] += nTSLBar } //| Salta Linha Codigo de Barras
		bReLBar := {|| aPLBar[_E_] := nPLBar ,aPLBar[_D_] := nPLBar  } //| Reseta a Linha Codigo de Barras

	EndIf
	
	

	oPr := TMSPrinter():New( "Protheus" )
	oPr:SetPortrait() // ou SetLandscape()
	oPr:StartPage()

	While !Eof()

		IncProc("Imprimindo Enderecos...")

		cCodEnd  := If( NEND->( Eof() ), Space(15) , NEND->BE_LOCALIZ )

		cEndPict := Substr(Alltrim(cCodEnd),1,2) + '-' + Substr(Alltrim(cCodEnd),3,3) + '-' + Substr(Alltrim(cCodEnd),6,2)

		aEtiqueta := { Alltrim(cEndPict) , Alltrim(cCodEnd) , DigVerif(Alltrim(cCodEnd)) }

		oPr:Say(nPLinA + aPLEnd[nPL] ,aPCEnd[nPL]  	,aEtiqueta[_ENDER_] 	,oFont ,100 )
		oPr:Say(nPLinA + aPLDiv[nPL] ,aPCDiv[nPL]  	,aEtiqueta[_DIGVE_]		,oFontDiV ,100 )

		MSBAR("CODE128" ,aPLBar[nPL] ,aPCBar[nPL]	, aEtiqueta[_CODBA_]	, oPr ,.T. ,,,0.030 ,1 ,,,,.F. )

		eVal(bAltLado)

		If lEsquerdo

			eVal(  bSPLin  ) //| Salta Linha Geral
			eVal(  bSPLBar ) //| Salta Linha Cod Barras

			If nLImp >= nLimteL //| Quebra de Pagina - 10 Etiquetas Piking por Pagina
				oPr:EndPage()
				oPr:StartPage()

				eVal(bReLin) 	//| Reseta a  Linha Geral
				eVal(bReLBar)	//| Reseta a  Linha Cod Barras

			Endif
		EndIf

		DbSelectArea("NEND");DbSkip()

	Enddo

	oPr:EndPage()
	oPr:Preview()
	oPr:End()

	DbSelectArea("NEND")
	DbCloseArea()

Return Nil
*******************************************************************************
Static Function SF01_Seleciona_Enderecos()
*******************************************************************************

	Local cQuery := ""

	cQuery += "SELECT BE_LOCALIZ FROM SBE010  "
	cQuery += "WHERE BE_LOCALIZ BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
	cQuery += "AND BE_FILIAL = '" +xFilial("SBE")+"' "
	cQuery += "AND D_E_L_E_T_ = ' '  "
	cQuery += "GROUP BY BE_LOCALIZ "
	cQuery += "ORDER BY BE_LOCALIZ  "

	U_ExecMySql( cSql := cQuery , cCursor := "NEND" , cTipo := "Q", lMostra := .F., lChange := .F. )

	DbSelectArea("NEND");DbGoTop()

	Return Nil
*******************************************************************************
Static Function DigVerif(cEnd) //Retorna o Digito verificador do endereco
*******************************************************************************

	M->nCont := 0
	M->cPeso := 2

	For i := Len(cEnd) To 1 Step -1
		M->nCont := M->nCont + (Asc(SubStr(cEnd,i,1)) * Asc(Right(cEnd,1,i)) )
	Next

	M->Resto  := ( M->nCont % 97 )
	M->Result := M->Resto //( 97 - M->Resto )

Return (StrZero(M->Result,2))

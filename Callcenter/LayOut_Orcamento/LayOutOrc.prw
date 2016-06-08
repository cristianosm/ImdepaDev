#Include 'Totvs.ch'
#Include "FWPrintSetup.ch"
#Include "FileIo.ch"
#Include "Protheus.ch"
#Include "Colors.ch"

#Define IMP_PDF 		6  // Impressao em PDF
#Define PAPER_A4 	9	 // Tamanho do Papel A4

#Define TIPO		1 // TIPO DE OBJETO
#Define LIN1		2 // POSICAO 1 LINHA
#Define COL1		3 // POSICAO 1 COLUNA
#Define LIN2		4 // POSICAO 2 LINHA
#Define COL2		5 // POSICAO 2 COLUNA
#Define COR		6 // COR EM RGB
#Define TAM		7 // TAMANHO LINHA OU TEXTO
#Define TEXTO	8 // TEXTO...
#Define FORM 	9 // FORMATO DO TEXTO ... N->NORMAL, B->NEGRITO, I->ITALICO, A->NEGRITO E ITALICO

//                        Low Intensity colors
#define CLR_BLACK             0               // RGB(   0,   0,   0 )
#define CLR_BLUE        8388608               // RGB(   0,   0, 128 )
#define CLR_GREEN         32768               // RGB(   0, 128,   0 )
#define CLR_CYAN        8421376               // RGB(   0, 128, 128 )
#define CLR_RED             128               // RGB( 128,   0,   0 )
#define CLR_MAGENTA     8388736               // RGB( 128,   0, 128 )
#define CLR_BROWN         32896               // RGB( 128, 128,   0 )
#define CLR_HGRAY      12632256               // RGB( 192, 192, 192 )
#define CLR_LIGHTGRAY  CLR_HGRAY

//|                       High Intensity Colors
#define CLR_ORANGE      RGB( 255, 229, 204 )
#define CLR_GRAYH       RGB( 224, 224, 224 )
#define CLR_GRAY        8421504               // RGB( 128, 128, 128 )
#define CLR_HBLUE      16711680               // RGB(   0,   0, 255 )
#define CLR_HGREEN        65280               // RGB(   0, 255,   0 )
#define CLR_HCYAN      16776960               // RGB(   0, 255, 255 )
#define CLR_HRED            255               // RGB( 255,   0,   0 )
#define CLR_HMAGENTA   16711935               // RGB( 255,   0, 255 )
#define CLR_YELLOW        65535               // RGB( 255, 255,   0 )
#define CLR_WHITE      16777215               // RGB( 255, 255, 255 )

*******************************************************************************
User Function LayOutOrc()	//| Gera Impressao de Layout
*******************************************************************************
	Private lContinua := .T.

	Pergunte("PRTPDF",.T.)

	While lContinua

		ExecRotina()

		lContinua := Iw_MsgBox("Deseja imprimir o Relatório ?", "Escolha uma Opção" , "YESNO" )

	EndDo

*******************************************************************************
Static Function ExecRotina()
*******************************************************************************

	Private cFilePrintert		:= CriaTrab( ,.F.) + ".pdf"
	Private nDevice				:= IMP_PDF
	Private lAdjustToLegacy	:= .T.
	Private cPathInServer		:= "\system\pdf\"
	Private cLocalPath			:= "C:\MP11\"
	Private lDisabeSetup		:= .T.
	Private lTReport				:= .F.
	Private cPrinter				:=  ""
	Private lServer				:= .F.
	Private lPDFAsPNG			:= .F.
	Private lRaw						:= .F.
	Private lViewPDF				:= .T.
	Private nQtdCopy				:= NIL
	Private lSetView				:= .T.

	Private oPrn
	Private oFConteudo

	Private nRelHoz				:= 0 //| Resolucao Horizontal em Pixel|
	Private nRelVer				:= 0 //| Resolucao Vertical em Pixel|
	Private nAltTxt				:= 0 //| Altura do Texto em Pixel|
	Private nLagTxt				:= 0 //| largura do Texto em Pixel|
	Private aFile					:= {}

	Private bAtuLC					:= { || nALin :=  nTLin*nL , nACol := nTCol *nC}

	oFConteudo	:=	TFont():New("Arial"			,09,10,,.T.,,,,,.F.)	// Conteudo dos Campos

	oPrn := 	FWMSPrinter():New(cFilePrintert, nDevice, lAdjustToLegacy ,cPathInServer, lDisabeSetup, lTReport, @oPrn, cPrinter, lServer, lPDFAsPNG, lRaw, lViewPDF )
	oPrn:SetPortrait() // Retrato
	oPrn:SetPaperSize(PAPER_A4)
	oPrn:SetMargin(10,10,10,10)
	oPrn:cPathPDF	:= cLocalPath
	oPrn:SetViewPDF(lSetView)

	nTLin		:= 17
	nTCol		:= 15

	nILin			:= 4
	nICol			:= 2

	nFCol		:= 150
	nFLin		:= 178

	nFPCol		:= nFCol * nTCol
	nFPLin		:= nFLin * nTLin

	nCorLin		:= 0

	nAltTxt		:= nTLin
	nLagTxt	:= nTCoL

	oPrn:StartPage() //| Inicia a Pagina

	OpenArq(@aFile)

	PrintArq( @oPrn )

	oPrn:EndPage() //| Finaliza a Pagina
	oPrn:Preview()


Return()
/*******************************************************************************
Static Function PrintArq( oPrn )
*******************************************************************************

  cNomBanc	:= ""
	cLinha		:= Replicate('- ',170)
	nULinha		:= 80 				//| Uma Linha
	nMLinha 	:= nULinha / 2 		//| Meia Linha
	nQLinha 	:= nULinha / 4		//| Quarto de Linha
	nOLinha 	:= nULinha / 8  	//| Oitavo de Linha
	nDLinha 	:= nULinha / 8  	//| Decimo de Linha

	nCol			:= 100
	nLinI 		:= 60;     nLinE	:= nLinI + nULinha


	nLinI += nQLinha;	nLinE := nLinI + nULinha
	nLinI += nULinha;	nLinE := nLinI + nULinha
	nLinI += nULinha;	nLinE := nLinI + nULinha
	nLinI += nMLinha;	nLinE := nLinI + nULinha
	nLinI += nMLinha;	nLinE := nLinI + nULinha
	nLinI += nQLinha;	nLinE := nLinI + nULinha

	oPrn:Box(nLinI				,nCol * 01     	,nLinE,nCol * 11 )
	oPrn:Box(nLinI				,nCol * 11 		,nLinE,nCol * 16 )
	oPrn:box(nLinI				,nCol * 16 		,nLinE,nCol * 17 )
	oPrn:box(nLinI				,nCol * 17 		,nLinE,nCol * 19 )
	oPrn:box(nLinI				,nCol * 19 		,nLinE,nCol * 23 )

	nLinI += nULinha;	nLinE := nLinI + nULinha

	oPrn:Box(nLinI				,nCol * 01     	,nLinE,nCol * 07 )
	oPrn:Box(nLinI				,nCol * 07 		,nLinE,nCol * 13 )
	oPrn:box(nLinI				,nCol * 13 		,nLinE,nCol * 19 )
	oPrn:box(nLinI				,nCol * 19 		,nLinE,nCol * 23 )

	nLinI += nULinha;	nLinE := nLinI + nULinha

	oPrn:Box(nLinI				,nCol * 01     	,nLinE,nCol * 04 )
	oPrn:Box(nLinI				,nCol * 04 		,nLinE,nCol * 08 )
	oPrn:box(nLinI				,nCol * 08 		,nLinE,nCol * 12 )
	oPrn:box(nLinI				,nCol * 12 		,nLinE,nCol * 19 )
	oPrn:box(nLinI				,nCol * 19 		,nLinE,nCol * 23 )

	nLinI += nULinha;	nLinE := nLinI + nULinha

	oPrn:Box(nLinI				,nCol * 01     	,nLinE,nCol * 23 )

	nLinI += nULinha;	nLinE := nLinI + nULinha
	nLinI += nULinha;	nLinE := nLinI + nULinha
	nLinI += nULinha;	nLinE := nLinI + nULinha
	nLinI += nULinha;	nLinE := nLinI + nULinha
	nLinI += nULinha;	nLinE := nLinI + nULinha
	nLinI += nULinha;	nLinE := nLinI + nULinha
	nLinI += nULinha;	nLinE := nLinI + nULinha
	nLinI += nULinha;	nLinE := nLinI + nULinha
	nLinI += nDLinha;	nLinE := nLinI + nULinha
	nLinI += nULinha;	nLinE := nLinI + nULinha
	nLinI += nULinha;	nLinE := nLinI + nULinha
	nLinI += nMLinha;	nLinE := nLinI + nULinha
	nLinI += nMLinha;	nLinE := nLinI + nULinha
	nLinI += nQLinha;	nLinE := nLinI + nULinha

	oPrn:Box(nLinI				,nCol * 01     	,nLinE,nCol * 19 )
	oPrn:Box(nLinI				,nCol * 19     	,nLinE,nCol * 23 )

	nLinI += nULinha;	nLinE := nLinI + nULinha

	oPrn:Box(nLinI				,nCol * 01     	,nLinE,nCol * 19 )
	oPrn:Box(nLinI				,nCol * 19     	,nLinE,nCol * 23 )

	nLinI += nULinha;	nLinE := nLinI + nULinha

	oPrn:Box(nLinI				,nCol * 01     	,nLinE,nCol * 05 )
	oPrn:Box(nLinI				,nCol * 05     	,nLinE,nCol * 10 )
	oPrn:Box(nLinI				,nCol * 10     	,nLinE,nCol * 12 )
	oPrn:Box(nLinI				,nCol * 12     	,nLinE,nCol * 14 )
	oPrn:Box(nLinI				,nCol * 14     	,nLinE,nCol * 19 )
	oPrn:Box(nLinI				,nCol * 19     	,nLinE,nCol * 23 )

	nLinI += nULinha;	nLinE := nLinI + nULinha

	oPrn:Box(nLinI				,nCol * 01     	,nLinE,nCol * 05 )
	oPrn:Box(nLinI				,nCol * 05     	,nLinE,nCol * 08 )
	oPrn:Box(nLinI				,nCol * 08     	,nLinE,nCol * 10 )
	oPrn:Box(nLinI				,nCol * 10     	,nLinE,nCol * 15 )
	oPrn:Box(nLinI				,nCol * 15     	,nLinE,nCol * 19 )
	oPrn:Box(nLinI				,nCol * 19     	,nLinE,nCol * 23 )

	nLinI += nULinha;	nLinE := nLinI + nULinha

	oPrn:Box(nLinI				,nCol * 01     	,nLinE + (nULinha * 4),nCol * 19 )
	oPrn:Box(nLinI				,nCol * 19     	,nLinE,nCol * 23 )

	nLinI += nULinha;	nLinE := nLinI + nULinha

	oPrn:Box(nLinI				,nCol * 19     	,nLinE,nCol * 23 )

	nLinI += nULinha;	nLinE := nLinI + nULinha

	oPrn:Box(nLinI				,nCol * 19     	,nLinE,nCol * 23 )

	nLinI += nULinha;	nLinE := nLinI + nULinha

	oPrn:Box(nLinI				,nCol * 19     	,nLinE,nCol * 23 )

	nLinI += nULinha;	nLinE := nLinI + nULinha

	oPrn:Box(nLinI				,nCol * 19     	,nLinE,nCol * 23 )

	nLinI += nULinha;	nLinE := nLinI + nULinha

	oPrn:Box(nLinI				,nCol * 01     	,nLinE + (nULinha * 2),nCol * 23 )

	nLinI += nULinha;	nLinE := nLinI + nULinha

/*/
*******************************************************************************
Static Function PrintArq( oPrn )
*******************************************************************************

	Local oBruVE 	:= TBrush():New2( , CLR_HRED 		) //| Vermelho	|
	Local oBruCI 	:= TBrush():New2( , CLR_GRAYH		) //| Cinza		|
	Local oBruAM 	:= TBrush():New2( , CLR_YELLOW 	) //| Amarelo	|
	Local oBruAZ 	:= TBrush():New2( , CLR_BLUE 		) //| Azul 		|
	Local oBruVD 	:= TBrush():New2( , CLR_ORANGE	) //| Verde 		|
	Local oBruBR 	:= TBrush():New2( , CLR_WHITE		) //| Branco		|
	Local oTFont

	Local 	lBold 		:= .T.
	Local 	lItalic 	:= .T.


	Local cDLinPix	:= "0" // Densidade Linha em Pixel Default (-2)
	Local nColor		:= 0
	Local aCoords 	:= {}
	For nL := 1 To Len(aFile)

		If Len(aFile[nL]) > 0

			If aFile[nL][TIPO] == "L" // Linha
			//Alert("Entrou Linha")
				oPrn:Line( Val(aFile[nL][LIN1]), Val(aFile[nL][COL1]), Val(aFile[nL][LIN2]), Val(aFile[nL][COL2]), nColor, aFile[nL][TAM] )

			ElseIf aFile[nL][TIPO] == "B" // Box
			//Alert("Entrou Coluna")
				oPrn:Box( Val(aFile[nL][LIN1]), Val(aFile[nL][COL1]), Val(aFile[nL][LIN2]), Val(aFile[nL][COL2]) )

			ElseIf  aFile[nL][TIPO] == "R" // Retangulo Colorido

				aCoords := { Val(aFile[nL][LIN1]) , Val(aFile[nL][COL1]) , Val(aFile[nL][LIN2]) , Val(aFile[nL][COL2]) }

				Do Case
					Case aFile[nL][COR] == "VE"
						oPrn:FillRect( aCoords 	, oBruVE	, aFile[nL][TAM])

					Case aFile[nL][COR] == "CI"
						oPrn:FillRect( aCoords	, oBruCI	, aFile[nL][TAM])

					Case aFile[nL][COR] == "AM"
						oPrn:FillRect( aCoords , oBruAM	, aFile[nL][TAM])

					Case aFile[nL][COR] == "AZ"
						oPrn:FillRect( aCoords , oBruAZ	, aFile[nL][TAM])

					Case aFile[nL][COR] == "LA"
						oPrn:FillRect( aCoords , oBruVD	, aFile[nL][TAM])

					OtherWise
						oPrn:FillRect( aCoords , oBruBR	)
				EndCase

			ElseIf aFile[nL][TIPO] == "T" // Texto

			oTFont :=  TFont():New( 'Courier new' , , Val(aFile[nL][TAM]) )

				Do Case
					Case aFile[nL][FORM] == "A" // Tudo
						oTFont:Bold 		:= .T.
						oTFont:Italic  := .T.

					Case aFile[nL][FORM] == "I" // Italico
						oTFont:Italic  := .T.

					Case aFile[nL][FORM] == "B" // Negrito
						oTFont:Bold 		:= .T.

				EndCase

				//| Cria a Fonte..
				//oTFont :=  TFont():New( 'Courier new' , , Val(aFile[nL][TAM]) , lBold , , , , , , , lItalic )

				//| Imprime o Texto...
				oPrn:Say( Val(aFile[nL][LIN1]) , Val(aFile[nL][COL1]) , aFile[nL][TEXTO], oTFont ,   ,   ,  )

			EndIf

		EndIf

	Next

Return()

*******************************************************************************
Static Function OpenArq( aFile )
*******************************************************************************

	Local cArq					:= "\desenho.txt"
	Local nModo				:= 2 //| 0-> READE | 1-> WRITE | 2-> READ_WRITE |
	Local xParam3			:= ""
	Local lChangeCase	:= .T. //| Case sensitive .T. , .F. |
	Local nHandle			:= 0
	Local aLine				:= {}

//| Tipo;Lin1;Col1;Lin2;Col2 |
//| L   ;10  ;10  ;10  ;10   |
//| B   ;10  ;10  ;11  ;12   |

	FT_FUse(cArq)
	FT_FGoTop()
	While !FT_FEOF()

		cLine  := FT_FReadLn()

		aLine	:= STRTOKARR(cLine,';')

		Aadd( aFile, aLine )

		FT_FSkip()

	EndDo

	FT_FUse()

Return()
*******************************************************************************
Static Function Mostra( cquery )
*******************************************************************************
	__cFileLog := MemoWrite(Criatrab(,.F.)+".log",cquery)

	Define FONT oFont NAME "Tahoma" Size 6,12
	Define MsDialog oDlgMemo Title "Leitura Concluida." From 3,0 to 340,550 Pixel

	@ 5,5 Get oMemo  Var cquery MEMO Size 265,145 Of oDlgMemo Pixel
	oMemo:bRClicked := {||AllwaysTrue()}
	oMemo:oFont:=oFont

	Define SButton  From 153,235 Type 1 Action oDlgMemo:End() Enable Of oDlgMemo Pixel

	Activate MsDialog oDlgMemo Center

Return(cquery)
*******************************************************************************
Static Function cv(c)
*******************************************************************************

Return( cValtochar(c) )


/*
	For nL := nILin To nFLin
		For nC := nICol To nFCol
			Eval( bAtuLC ) //| Atualiza nAlin e nACol |
			//| Linha Inicial ----------------------------------------------------
			If nL == nILin
				If nC == nICol //| Coluna Inicial |||||||||||||||||||||||||||||||||||||||||||||||||
				//	oPrn:Box( nALin, nACol, nFPLin, nFPCol, cDLinPix )
					Alert( "Entrou Lin1" )
				EndIf
			EndIf
			//| Linha Dois ----------------------------------------------------
			If nL == (nILin + 1 )
				If nC == ( nICol + 1)	//| Coluna Inicial |||||||||||||||||||||||||||||||||||||||||||||||||
					oPrn:Box( nALin, nACol, nALin + (nTLin * 5), nFPCol - nTCol , cDLinPix )
					Alert( "Entrou Lin2" )
				EndIf
			EndIf
		Next
	Next
*/


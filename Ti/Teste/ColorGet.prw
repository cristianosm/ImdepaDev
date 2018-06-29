#Include 'Totvs.ch'

/*---------------------------------------------------------------------------*\
** FUNÇÃO   : TColorGet.prw | AUTOR : Cristiano Machado | DATA : 14/06/2018 **
\*---------------------------------------------------------------------------*/

*******************************************************************************
User Function TColorGet() //|Teste TGet
*******************************************************************************
	Local oWin 	:= Nil	
	Local nCVS 	:= 100  					//| Coordenada Vertical Superior 	|
	Local nCHE 	:= 100						//| Coordenada Horizontal Esquerda 	|
	Local nCVI 	:= 200						//| Coordenada Vertical Inferior 	|
	Local nCHD 	:= 400						//| Coordenada Horizontal Direita 	|
	Local cTit	:= "Janela Teste"			//| Indica o título da janela.		|
	Local lPix	:= .T.						//| Indica se considera as coordenadas passadas em pixels (.T.) ou caracteres (.F.).|
	Local lTra	:= .F.						//| Se .T. permitira que a Dialog recebe um fundo transparente. |

	Local bEnt	:= Nil 						//|Executa Rotina na Apresentacao da Janela 	|
	Local bSai	:= Nil 						//|Executa Rotina no Encerramento da Janela 	|
	Local lCen	:= .T.	 					//| Apresenta a Janela centralizada quando .T. 	|

	oWin := MSDialog():New(nCVS,nCHE,nCVI,nCHD,cTit,,,,,CLR_BLACK,CLR_WHITE,,,lPix,,,,lTra)

	CriaCpo(@oWin)	

	oWin:Activate(,,,lCen,bSai,,bEnt )

Return()
*******************************************************************************
Static Function CriaCpo(oWin) //| Monta os Campos na Janela |
*******************************************************************************
	// Variaveis TFont
	Local cName			:= 'Courier'	//| Nome da Fonte |
	Local nFHeight		:= -14			//| Tamanho da Fonte |
	Local lBold			:= .F.			//| Negrito |
	Local lUnderline	:= .F.			//| Sublinhado |
	Local lItalic		:= .F.			//| Italico |
	Local uPar			:= Nil
	Local oFont			:= TFont():New (cName,uPar,nFHeight,uPar,lBold,uPar,uPar,uPar,uPar,lUnderline,lItalic )
	
	// Variaveis TGet
	Local nRow			:= 020 // Indica a coordenada vertical em pixels ou caracteres.
	Local nCol			:= 030 // Indica a coordenada horizontal em pixels ou caracteres.
	Local bSetGet		:= Nil
	Local oWnd			:= oWin
	Local nWidth		:= 100
	Local nHeight		:= 010
	Local cPict			:= "@E 99,999,999.99"
	Local bValid		:= Nil
	Local nClrFore		:= RGB( 255 , 0  , 0  ) // Vermelho
	Local nClrBack		:= 0 //RGB( 0 	, 0  , 0  ) // Branco
	Local uP			:= Nil
	Local lPixel		:= .T.
	Local bWhen			:= Nil
	Local bChange		:= Nil
	Local lReadOnly		:= .F.
	Local lPassword		:= Nil
	Local cReadVar		:= Nil
	Local lHasButton	:= .F.
	Local lNoButton		:= .T.
	Local cLabelText	:= Nil
	Local nLabelPos		:= Nil
	Local oLabelFont	:= Nil
	Local nLabelColor	:= Nil
	Local cPlaceHold	:= Nil

	Local oGet			:= Nil
	Local xVarAux		:= Nil

	Local nValA			:= 1000


	TGet():New(nRow,nCol,{|| nValA },oWin,nWidth,nHeight,cPict,bValid,nClrFore,nClrBack,oFont,uP,uP,lPixel,uP,uP,bWhen,uP,uP,bChange,lReadOnly,lPassword,uP,cReadVar,uP,uP,uP,lHasButton,lNoButton,cLabelText,nLabelPos,oLabelFont,nLabelColor,cPlaceHold)
	
	Return
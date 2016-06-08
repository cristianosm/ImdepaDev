#Include "Totvs.ch"

#Define 	_VTX 	01		//| Taxa |
#Define 	_FOB 	02		//| Valor FOB |
#Define 	_FRT 	03		//| Valor Frete |
#Define 	_SEG 	04  //| Valor Seguro |
#Define 	_DAD 	05		//| Despesa Aduaneira |
#Define 	_CIF 	06		//| CIF |
#Define 	_IDI 	07		//| Imposto de Importacao |
#Define 	_IPI 	08		//| Imposto IPI |
#Define 	_PIS 	09		//| Imposto PIS |
#Define 	_COF 	10		//| Imposto CODFINS |
#Define 	_DIC 	11		//| Despesa de ICMS |
#Define 	_ICM 	12		//| Imposto ICMS |
#Define 	_IMP 	13		//| Impostos |
#Define 	_TOT 	14		//| Total Geral |

/*****************************************************************************\
**---------------------------------------------------------------------------**
** FUNÇÃO   : NomeProg    | AUTOR : Cristiano Machado  | DATA : 12/06/2015   **
**---------------------------------------------------------------------------**
** DESCRIÇÃO:                                                                **
**---------------------------------------------------------------------------**
** USO      : Especifico para o cliente  XXXXXX                              **
**---------------------------------------------------------------------------**
**---------------------------------------------------------------------------**
**            ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.              **
**---------------------------------------------------------------------------**
**   PROGRAMADOR   |   DATA   |            MOTIVO DA ALTERACAO               **
**---------------------------------------------------------------------------**
**                 |          |                                              **
**                 |          |                                              **
\*---------------------------------------------------------------------------*/
*******************************************************************************
User Function JanEasy(aValI, aValC)
*******************************************************************************

	Local oWin 			:= Nil						//| Objeto que vai receber a Janela |

	Private nVarAux 	:= 0

	Default aValI 		:= {1000,2000,3000,4000,5000,6000,7000,8000,9000,10000,11000,12000,13000,14000}
	Default aValC 		:= {1000,2000,3000,4000,4000,5999,7000,8000,9000,10000,11000,12000,13000,14000}


	CriaWin(@oWin) 	//| Cria Janela Base ... |

	TPanelCSS(@oWin)	//| Monta os Paineis na Janela ... |

	CriaTxt(@oWin)		//| Monta Textos na Janela ... |

	CriaCpo(@oWin, aValI, aValC)	//| Monta os Campos na Janela... |

	CriaBtu(@oWin)		//| Monta na Janela os Botoes...|

	ShowWin(@oWin)		//| Apresenta a Janela ... |

Return()
*******************************************************************************
Static Function CriaTxt(oWin)		//| Monta Textos na Janela
*******************************************************************************

	Local cTxt			:= ""

	Local nRow			:= 0						//| Indica a coordenada vertical em pixels ou caracteres.|
	Local nCol			:= 0						//| Indica a coordenada horizontal em pixels ou caractere |
	Local bText		:= {||cTxt}		//| Indica o bloco de código que será executado para retornar e apresentar uma string. |

	Local cPicture	:= ""					//| Indica a máscara de formatação, do conteúdo, que será apresentada. |
	Local oFont		:= Nil					//| Indica o objeto do tipo TFont utilizado para definir as características da fonte aplicada na exibição do conteúdo do controle visual. |
	Local lPixels	:= .T.					//| Indica se considera as coordenadas passadas em pixels (.T.) ou caracteres (.F.). |
	Local nClrText	:= CLR_BLACK		//| Indica a cor do texto do objeto.|
	Local nClrBack	:= CLR_WHITE		//| Indica a cor de fundo do objeto.|
	Local nWidth		:= 200					//| Indica a largura em pixels do objeto. |
	Local nHeight	:= 10					//| Indica a altura em pixels do objeto.|
	Local uP				:= Nil					//| Compatibilidade. |

	local	oFTip := DefFonts("TP") //| Fonte Titulo Principal							|
	local	oFTit := DefFonts("TI") //| Fonte Titulo  			 								|
	local	oFStb := DefFonts("ST") //| Fonte Sub Titulo 									|
	local	oFDen := DefFonts("DN") //| Fonte Detalhe Normal  							|
	local	oFDeb := DefFonts("DB") //| Fonte Detalhes Negrito 						|
	local	oFDbu := DefFonts("DS") //| Fonte Detalhes Negrito e Sublinhado	|

	bText := {||'INFORMADO'  	      		};oSay:=TSay():New(004,111,bText,oWin,cPicture,oFTip,uP,uP,uP,lPixels,nClrText,nClrBack,nWidth,nHeight)
	bText := {||'CALCULADO'       		};oSay:=TSay():New(004,211,bText,oWin,cPicture,oFTip,uP,uP,uP,lPixels,nClrText,nClrBack,nWidth,nHeight)
	bText := {||'Taxa '								};oSay:=TSay():New(028,010,bText,oWin,cPicture,oFDeb,uP,uP,uP,lPixels,nClrText,nClrBack,nWidth,nHeight)
	bText := {||'FOB              '		};oSay:=TSay():New(052,010,bText,oWin,cPicture,oFDen,uP,uP,uP,lPixels,nClrText,nClrBack,nWidth,nHeight)
	bText := {||'Frete            '		};oSay:=TSay():New(064,010,bText,oWin,cPicture,oFDen,uP,uP,uP,lPixels,nClrText,nClrBack,nWidth,nHeight)
	bText := {||'Seguro           '		};oSay:=TSay():New(076,010,bText,oWin,cPicture,oFDen,uP,uP,uP,lPixels,nClrText,nClrBack,nWidth,nHeight)
	bText := {||'Desp.Aduaneira   '		};oSay:=TSay():New(088,010,bText,oWin,cPicture,oFDen,uP,uP,uP,lPixels,nClrText,nClrBack,nWidth,nHeight)
	bText := {||'CIF               '	};oSay:=TSay():New(115,010,bText,oWin,cPicture,oFDbu,uP,uP,uP,lPixels,nClrText,nClrBack,nWidth,nHeight)
	bText := {||'II               '		};oSay:=TSay():New(136,010,bText,oWin,cPicture,oFDen,uP,uP,uP,lPixels,nClrText,nClrBack,nWidth,nHeight)
	bText := {||'IPI              '		};oSay:=TSay():New(148,010,bText,oWin,cPicture,oFDen,uP,uP,uP,lPixels,nClrText,nClrBack,nWidth,nHeight)
	bText := {||'PIS              '		};oSay:=TSay():New(160,010,bText,oWin,cPicture,oFDen,uP,uP,uP,lPixels,nClrText,nClrBack,nWidth,nHeight)
	bText := {||'COFINS           '		};oSay:=TSay():New(172,010,bText,oWin,cPicture,oFDen,uP,uP,uP,lPixels,nClrText,nClrBack,nWidth,nHeight)
	bText := {||'Despesa ICMS     '		};oSay:=TSay():New(184,010,bText,oWin,cPicture,oFDen,uP,uP,uP,lPixels,nClrText,nClrBack,nWidth,nHeight)
	bText := {||'ICMS             '		};oSay:=TSay():New(196,010,bText,oWin,cPicture,oFDen,uP,uP,uP,lPixels,nClrText,nClrBack,nWidth,nHeight)
	bText := {||'IMPOSTOS          '	};oSay:=TSay():New(223,010,bText,oWin,cPicture,oFDbu,uP,uP,uP,lPixels,nClrText,nClrBack,nWidth,nHeight)
	bText := {||'TOTAL GERAL       '	};oSay:=TSay():New(247,010,bText,oWin,cPicture,oFTit,uP,uP,uP,lPixels,nClrText,nClrBack,nWidth,nHeight)

Return()
*******************************************************************************
Static Function CriaCpo(oWin, aValI, aValC) //| Monta os Campos na Janela |
*******************************************************************************

	Local nRow					:= 040
	Local nCol					:= 080
	Local bSetGet			:= Nil
	Local oWnd					:= oWin
	Local nWidth				:= 070
	Local nHeight			:= 008
	Local cPict				:= "@E R$ 99,999,999.99"
	Local bValid				:= Nil
	Local nClrFore			:= Nil
	Local nClrBack			:= Nil
	Local oFont				:= DefFonts("DN") //| Fonte Detalhe Normal  	|
	Local uP						:= Nil
	Local lPixel				:= .T.
	Local bWhen				:= Nil
	Local bChange			:= Nil
	Local lReadOnly		:= .T.
	Local lPassword		:= Nil
	Local cReadVar			:= Nil
	Local lHasButton		:= Nil
	Local lNoButton		:= Nil
	Local cLabelText		:= Nil
	Local nLabelPos		:= Nil
	Local oLabelFont		:= Nil
	Local nLabelColor	:= Nil
	Local cPlaceHold		:= Nil

	Local oGet					:= Nil
	Local xVarAux			:= Nil

	cPict				:= "@E 999,999.9999"; nClrFore := rc(aValI[_VTX], aValC[_VTX])
	TGet():New(026,108,{||aValI[_VTX] },oWin,nWidth,nHeight,cPict,bValid,nClrFore,nClrBack,oFont,uP,uP,lPixel,uP,uP,bWhen,uP,uP,bChange,lReadOnly,lPassword,uP,cReadVar,uP,uP,uP,lHasButton,lNoButton,cLabelText,nLabelPos,oLabelFont,nLabelColor,cPlaceHold)
	TGet():New(026,208,{||aValC[_VTX] },oWin,nWidth,nHeight,cPict,bValid,nClrFore,nClrBack,oFont,uP,uP,lPixel,uP,uP,bWhen,uP,uP,bChange,lReadOnly,lPassword,uP,cReadVar,uP,uP,uP,lHasButton,lNoButton,cLabelText,nLabelPos,oLabelFont,nLabelColor,cPlaceHold)

	cPict				:= "@E 99,999,999.99"; nClrFore := rc(aValI[_FOB], aValC[_FOB])
	TGet():New(050,108,{||aValI[_FOB] },oWin,nWidth,nHeight,cPict,bValid,nClrFore,nClrBack,oFont,uP,uP,lPixel,uP,uP,bWhen,uP,uP,bChange,lReadOnly,lPassword,uP,cReadVar,uP,uP,uP,lHasButton,lNoButton,cLabelText,nLabelPos,oLabelFont,nLabelColor,cPlaceHold)
	TGet():New(050,208,{||aValC[_FOB] },oWin,nWidth,nHeight,cPict,bValid,nClrFore,nClrBack,oFont,uP,uP,lPixel,uP,uP,bWhen,uP,uP,bChange,lReadOnly,lPassword,uP,cReadVar,uP,uP,uP,lHasButton,lNoButton,cLabelText,nLabelPos,oLabelFont,nLabelColor,cPlaceHold)

	nClrFore := rc(aValI[_FRT], aValC[_FRT])
	TGet():New(062,108,{||aValI[_FRT] },oWin,nWidth,nHeight,cPict,bValid,nClrFore,nClrBack,oFont,uP,uP,lPixel,uP,uP,bWhen,uP,uP,bChange,lReadOnly,lPassword,uP,cReadVar,uP,uP,uP,lHasButton,lNoButton,cLabelText,nLabelPos,oLabelFont,nLabelColor,cPlaceHold)
	TGet():New(062,208,{||aValC[_FRT] },oWin,nWidth,nHeight,cPict,bValid,nClrFore,nClrBack,oFont,uP,uP,lPixel,uP,uP,bWhen,uP,uP,bChange,lReadOnly,lPassword,uP,cReadVar,uP,uP,uP,lHasButton,lNoButton,cLabelText,nLabelPos,oLabelFont,nLabelColor,cPlaceHold)

	nClrFore := rc(aValI[_SEG], aValC[_SEG])
	TGet():New(074,108,{||aValI[_SEG] },oWin,nWidth,nHeight,cPict,bValid,nClrFore,nClrBack,oFont,uP,uP,lPixel,uP,uP,bWhen,uP,uP,bChange,lReadOnly,lPassword,uP,cReadVar,uP,uP,uP,lHasButton,lNoButton,cLabelText,nLabelPos,oLabelFont,nLabelColor,cPlaceHold)
	TGet():New(074,208,{||aValC[_SEG] },oWin,nWidth,nHeight,cPict,bValid,nClrFore,nClrBack,oFont,uP,uP,lPixel,uP,uP,bWhen,uP,uP,bChange,lReadOnly,lPassword,uP,cReadVar,uP,uP,uP,lHasButton,lNoButton,cLabelText,nLabelPos,oLabelFont,nLabelColor,cPlaceHold)

	nClrFore := rc(aValI[_DAD], aValC[_DAD])
	TGet():New(086,108,{||aValI[_DAD] },oWin,nWidth,nHeight,cPict,bValid,nClrFore,nClrBack,oFont,uP,uP,lPixel,uP,uP,bWhen,uP,uP,bChange,lReadOnly,lPassword,uP,cReadVar,uP,uP,uP,lHasButton,lNoButton,cLabelText,nLabelPos,oLabelFont,nLabelColor,cPlaceHold)
	TGet():New(086,208,{||aValC[_DAD] },oWin,nWidth,nHeight,cPict,bValid,nClrFore,nClrBack,oFont,uP,uP,lPixel,uP,uP,bWhen,uP,uP,bChange,lReadOnly,lPassword,uP,cReadVar,uP,uP,uP,lHasButton,lNoButton,cLabelText,nLabelPos,oLabelFont,nLabelColor,cPlaceHold)

	nClrFore := rc(aValI[_CIF], aValC[_CIF])
	TGet():New(110,108,{||aValI[_CIF] },oWin,nWidth,nHeight,cPict,bValid,nClrFore,nClrBack,oFont,uP,uP,lPixel,uP,uP,bWhen,uP,uP,bChange,lReadOnly,lPassword,uP,cReadVar,uP,uP,uP,lHasButton,lNoButton,cLabelText,nLabelPos,oLabelFont,nLabelColor,cPlaceHold)
	TGet():New(110,208,{||aValC[_CIF] },oWin,nWidth,nHeight,cPict,bValid,nClrFore,nClrBack,oFont,uP,uP,lPixel,uP,uP,bWhen,uP,uP,bChange,lReadOnly,lPassword,uP,cReadVar,uP,uP,uP,lHasButton,lNoButton,cLabelText,nLabelPos,oLabelFont,nLabelColor,cPlaceHold)

	nClrFore := rc(aValI[_IDI], aValC[_IDI])
	TGet():New(134,108,{||aValI[_IDI] },oWin,nWidth,nHeight,cPict,bValid,nClrFore,nClrBack,oFont,uP,uP,lPixel,uP,uP,bWhen,uP,uP,bChange,lReadOnly,lPassword,uP,cReadVar,uP,uP,uP,lHasButton,lNoButton,cLabelText,nLabelPos,oLabelFont,nLabelColor,cPlaceHold)
	TGet():New(134,208,{||aValC[_IDI] },oWin,nWidth,nHeight,cPict,bValid,nClrFore,nClrBack,oFont,uP,uP,lPixel,uP,uP,bWhen,uP,uP,bChange,lReadOnly,lPassword,uP,cReadVar,uP,uP,uP,lHasButton,lNoButton,cLabelText,nLabelPos,oLabelFont,nLabelColor,cPlaceHold)

	nClrFore := rc(aValI[_IPI], aValC[_IPI])
	TGet():New(146,108,{||aValI[_IPI] },oWin,nWidth,nHeight,cPict,bValid,nClrFore,nClrBack,oFont,uP,uP,lPixel,uP,uP,bWhen,uP,uP,bChange,lReadOnly,lPassword,uP,cReadVar,uP,uP,uP,lHasButton,lNoButton,cLabelText,nLabelPos,oLabelFont,nLabelColor,cPlaceHold)
	TGet():New(146,208,{||aValC[_IPI] },oWin,nWidth,nHeight,cPict,bValid,nClrFore,nClrBack,oFont,uP,uP,lPixel,uP,uP,bWhen,uP,uP,bChange,lReadOnly,lPassword,uP,cReadVar,uP,uP,uP,lHasButton,lNoButton,cLabelText,nLabelPos,oLabelFont,nLabelColor,cPlaceHold)

	nClrFore := rc(aValI[_PIS], aValC[_PIS])
	TGet():New(158,108,{||aValI[_PIS] },oWin,nWidth,nHeight,cPict,bValid,nClrFore,nClrBack,oFont,uP,uP,lPixel,uP,uP,bWhen,uP,uP,bChange,lReadOnly,lPassword,uP,cReadVar,uP,uP,uP,lHasButton,lNoButton,cLabelText,nLabelPos,oLabelFont,nLabelColor,cPlaceHold)
	TGet():New(158,208,{||aValC[_PIS] },oWin,nWidth,nHeight,cPict,bValid,nClrFore,nClrBack,oFont,uP,uP,lPixel,uP,uP,bWhen,uP,uP,bChange,lReadOnly,lPassword,uP,cReadVar,uP,uP,uP,lHasButton,lNoButton,cLabelText,nLabelPos,oLabelFont,nLabelColor,cPlaceHold)

	nClrFore := rc(aValI[_COF], aValC[_COF])
	TGet():New(170,108,{||aValI[_COF] },oWin,nWidth,nHeight,cPict,bValid,nClrFore,nClrBack,oFont,uP,uP,lPixel,uP,uP,bWhen,uP,uP,bChange,lReadOnly,lPassword,uP,cReadVar,uP,uP,uP,lHasButton,lNoButton,cLabelText,nLabelPos,oLabelFont,nLabelColor,cPlaceHold)
	TGet():New(170,208,{||aValC[_COF] },oWin,nWidth,nHeight,cPict,bValid,nClrFore,nClrBack,oFont,uP,uP,lPixel,uP,uP,bWhen,uP,uP,bChange,lReadOnly,lPassword,uP,cReadVar,uP,uP,uP,lHasButton,lNoButton,cLabelText,nLabelPos,oLabelFont,nLabelColor,cPlaceHold)

	nClrFore := rc(aValI[_DIC], aValC[_DIC])
	TGet():New(182,108,{||aValI[_DIC] },oWin,nWidth,nHeight,cPict,bValid,nClrFore,nClrBack,oFont,uP,uP,lPixel,uP,uP,bWhen,uP,uP,bChange,lReadOnly,lPassword,uP,cReadVar,uP,uP,uP,lHasButton,lNoButton,cLabelText,nLabelPos,oLabelFont,nLabelColor,cPlaceHold)
	TGet():New(182,208,{||aValC[_DIC] },oWin,nWidth,nHeight,cPict,bValid,nClrFore,nClrBack,oFont,uP,uP,lPixel,uP,uP,bWhen,uP,uP,bChange,lReadOnly,lPassword,uP,cReadVar,uP,uP,uP,lHasButton,lNoButton,cLabelText,nLabelPos,oLabelFont,nLabelColor,cPlaceHold)

	nClrFore := rc(aValI[_ICM], aValC[_ICM])
	TGet():New(194,108,{||aValI[_ICM] },oWin,nWidth,nHeight,cPict,bValid,nClrFore,nClrBack,oFont,uP,uP,lPixel,uP,uP,bWhen,uP,uP,bChange,lReadOnly,lPassword,uP,cReadVar,uP,uP,uP,lHasButton,lNoButton,cLabelText,nLabelPos,oLabelFont,nLabelColor,cPlaceHold)
	TGet():New(194,208,{||aValC[_ICM] },oWin,nWidth,nHeight,cPict,bValid,nClrFore,nClrBack,oFont,uP,uP,lPixel,uP,uP,bWhen,uP,uP,bChange,lReadOnly,lPassword,uP,cReadVar,uP,uP,uP,lHasButton,lNoButton,cLabelText,nLabelPos,oLabelFont,nLabelColor,cPlaceHold)

	nClrFore := rc(aValI[_IMP], aValC[_IMP])
	TGet():New(218,108,{||aValI[_IMP] },oWin,nWidth,nHeight,cPict,bValid,nClrFore,nClrBack,oFont,uP,uP,lPixel,uP,uP,bWhen,uP,uP,bChange,lReadOnly,lPassword,uP,cReadVar,uP,uP,uP,lHasButton,lNoButton,cLabelText,nLabelPos,oLabelFont,nLabelColor,cPlaceHold)
	TGet():New(218,208,{||aValC[_IMP] },oWin,nWidth,nHeight,cPict,bValid,nClrFore,nClrBack,oFont,uP,uP,lPixel,uP,uP,bWhen,uP,uP,bChange,lReadOnly,lPassword,uP,cReadVar,uP,uP,uP,lHasButton,lNoButton,cLabelText,nLabelPos,oLabelFont,nLabelColor,cPlaceHold)

	nClrFore := rc(aValI[_TOT], aValC[_TOT])
	TGet():New(242,108,{||aValI[_TOT] },oWin,nWidth,nHeight,cPict,bValid,nClrFore,nClrBack,oFont,uP,uP,lPixel,uP,uP,bWhen,uP,uP,bChange,lReadOnly,lPassword,uP,cReadVar,uP,uP,uP,lHasButton,lNoButton,cLabelText,nLabelPos,oLabelFont,nLabelColor,cPlaceHold)
	TGet():New(242,208,{||aValC[_TOT] },oWin,nWidth,nHeight,cPict,bValid,nClrFore,nClrBack,oFont,uP,uP,lPixel,uP,uP,bWhen,uP,uP,bChange,lReadOnly,lPassword,uP,cReadVar,uP,uP,uP,lHasButton,lNoButton,cLabelText,nLabelPos,oLabelFont,nLabelColor,cPlaceHold)


Return()
*******************************************************************************
Static Function DefFonts(cQual)//| Definicao das Fontes ...|
*******************************************************************************

	Local oFont 			:=		Nil 						//| Define Modelo Fonte...|

	Local cName			:= 'Courier'		//| Nome da Fonte |
	Local nHeight		:= -14							//| Tamanho da Fonte |
	Local lBold			:= .F.							//| Negrito |
	Local lUnderline	:= .F.							//| Sublinhado |
	Local lItalic		:= .F.							//| Italico |
	Local uPar				:= Nil

	Do Case
	Case cQual == "TP" //| Fonte Titulo  			 		|
		nHeight			:= -24
		lBold			 	:= .T.
		lUnderline  	:= .T.

	Case cQual == "TI" //| Fonte Titulo  			 		|
		nHeight			:= -17
		lBold			 	:= .T.
		lUnderline  	:= .T.

	Case cQual == "ST" //| Fonte Sub Titulo 			|
		nHeight	:= -16
		lBold		:= .F.

	Case cQual == "DN" //| Fonte Detalhe Normal  	|

	Case cQual == "DB" //| Fonte Detalhes Negrito |
		nHeight	:= -16
		lBold		:= .T.

	Case cQual == "DS" //| Fonte Detalhes Negrito e Sublinhado |
		nHeight			:= -16
		lBold				:= .T.
		lUnderline  	:= .T.

	EndCase

	oFont := TFont():New (cName,uPar,nHeight,uPar,lBold,uPar,uPar,uPar,uPar,lUnderline,lItalic )

Return(oFont)
*******************************************************************************
Static Function TPanelCSS(oWin) //| Monta os Paineis ... |
*******************************************************************************
	Local nPCV			:= 002  		//| Ponto Coordenada Vertical   		|
	Local nPCH			:= 002			//| Ponto Coordenada Horizontal  		|
	Local cText		:= ""			//| Indica o texto que será apresentado ao fundo do objeto. |
	Local oWnd			:= @oWin		//| Indica a janela ou controle visual onde o objeto será criado. |
	Local lCen			:= Nil			//| Indica se, verdadeiro (.T.), apresenta o texto do título no centro do objeto; caso contrário, falso (.F.). |
	Local lPar6		:= .F.			//| Compatibilidade |
	Local lPar7		:= .F.			//| Compatibilidade |
	Local nClrT		:= Nil  		//| Indica a cor do texto do objeto. |
	Local nClrB		:= Nil 		//| Indica a cor de fundo do objeto. |
	Local nWid 		:= 080			//| Indica a largura em pixels do objeto |
	Local nHei 		:= 080			//| Indica a altura em pixels do objeto.	|
	Local lLow			:= .T.			//| Indica se, verdadeiro (.T.), apresenta o painel rebaixado em relação ao objeto de fundo; caso contrário, falso (.F.). |
	Local lRais		:= .F.			//| Indica se, verdadeiro (.T.), apresenta a borda do objeto rebaixada em relação ao objeto de fundo; caso contrário, falso (.F.). |

	Local oPanel		:= Nil			//| Objeto que vai receber o Objeto CSS |

	Local cStyle	:=  "Q3Frame{ }"	//| Define o Estilo do CSS |

	//Local cStyle	:=  "Q3Frame{ border-style:solid; border-width:3px; border-color:#F5FFFA; background-color:#F5FFFA }"	//| Define o Estilo do CSS |

//| TAXA
	nPCV := 022 ; nPCH := 105 ; nWid := 076 ; nHei := 018; TPanelCss():New(nPCV,nPCH,cText,oWnd,lCen,lPar6,lPar7,nClrT,nClrB,nWid,nHei,lLow,lRais)
	nPCV := 022 ; nPCH := 205 ; nWid := 076 ; nHei := 018; TPanelCss():New(nPCV,nPCH,cText,oWnd,lCen,lPar6,lPar7,nClrT,nClrB,nWid,nHei,lLow,lRais)

//| CIF
	nPCV := 046 ; nPCH := 105 ; nWid := 076 ; nHei := 078; TPanelCss():New(nPCV,nPCH,cText,oWnd,lCen,lPar6,lPar7,nClrT,nClrB,nWid,nHei,lLow,lRais)
	nPCV := 046 ; nPCH := 205 ; nWid := 076 ; nHei := 078; TPanelCss():New(nPCV,nPCH,cText,oWnd,lCen,lPar6,lPar7,nClrT,nClrB,nWid,nHei,lLow,lRais)

//| IMPOSTOS
	nPCV := 130 ; nPCH := 105 ; nWid := 076 ; nHei := 102; TPanelCss():New(nPCV,nPCH,cText,oWnd,lCen,lPar6,lPar7,nClrT,nClrB,nWid,nHei,lLow,lRais)
	nPCV := 130 ; nPCH := 205 ; nWid := 076 ; nHei := 102; TPanelCss():New(nPCV,nPCH,cText,oWnd,lCen,lPar6,lPar7,nClrT,nClrB,nWid,nHei,lLow,lRais)

//| TOTAL GERAL
	nPCV := 238 ; nPCH := 105 ; nWid := 076 ; nHei := 018; TPanelCss():New(nPCV,nPCH,cText,oWnd,lCen,lPar6,lPar7,nClrT,nClrB,nWid,nHei,lLow,lRais)
	nPCV := 238 ; nPCH := 205 ; nWid := 076 ; nHei := 018; TPanelCss():New(nPCV,nPCH,cText,oWnd,lCen,lPar6,lPar7,nClrT,nClrB,nWid,nHei,lLow,lRais)

//| Aplica o Estilo do CSS |
//oPanel:setCSS( cStyle )

Return()
*******************************************************************************
Static Function CriaBtu(oWin) //| Monta na janela Botoes... |
*******************************************************************************

	Local nTop				:= 008											//| Indica a coordenada vertical em pixels ou caracteres.|
	Local nLeft			:= 566                     	//| Indica a coordenada horizontal em pixels ou caracteres.|
	Local nWidth			:= 24											//| Indica a largura em pixels do objeto. |
	Local nHeight		:= 24											//| Indica a altura em pixels do objeto. |
	Local cResName 	:= "BMPPERG.PNG" 					//| Indica o nome do recurso que contém a imagem. Este recurso deve estar compilado,no repositório de imagens, para ser utilizado.|
	Local bAction		:= {||CriaWhlp()}					//| Indica o bloco de código que será executado quando clicar, com o botão esquerdo do mouse, sobre o botão.|
	Local cMsg				:= "Apresenta Formula de Calculo"//| Indica a mensagem, do tipo dica de contexto (tooltip/hint), ao posicionar o ponteiro do mouse sobre o botão.|
	Local bWhen			:= {|| }										//| Indica o bloco de código que será executado quando a mudança de foco da entrada de dados, na janela em que o controle foi criado, estiver sendo efetuada. Observação: O bloco de código retornará verdadeiro (.T.) se o controle permanecer habilitado; caso contrário, retornará falso (.F.).|
	Local uP					:= Nil											//| Compatibilidade |
	local lTrue			:= .T.											//| Compatibilidade |

	TBtnBmp2():New( nTop,nLeft,26,26,cResName,uP,uP,uP,bAction,oWin,cMsg,bWhen,lTrue)

	TBtnBmp2():New( nTop,nLeft,26,26,cResName,uP,uP,uP,bAction,oWin,cMsg,bWhen,lTrue)

Return()
*******************************************************************************
Static Function CriaWin(oWin) //| Cria Janela Base |
*******************************************************************************

	Local nCVS 	:= 180  										//| Coordenada Vertical Superior 		|
	Local nCHE 	:= 180											//| Coordenada Horizontal Esquerda 	|
	Local nCVI 	:= 700											//| Coordenada Vertical Inferior 		|
	Local nCHD 	:= 775											//| Coordenada Horizontal Direita 	|
	Local cTit		:= "Valores NF Importação"	//| Indica o título da janela.			|
	Local lPix		:= .T.											//| Indica se considera as coordenadas passadas em pixels (.T.) ou caracteres (.F.).|
	Local lTra		:=	 .F.											//| Se .T. permitira que a Dialog recebe um fundo transparente. |

	oWin := MSDialog():New(nCVS,nCHE,nCVI,nCHD,cTit,,,,,CLR_BLACK,CLR_WHITE,,,lPix,,,,lTra)

Return()
*******************************************************************************
Static Function ShowWin(oWin) //| Apresenta Janela Base |
*******************************************************************************
	Private bEnt	:=	 Nil //{||MsgStop("Apresenta Janela..."	),.T.} 	//|Executa Rotina na Apresentacao da Janela |
	Private bSai	:=	 Nil // {||MsgStop("Fecha Janela..."			),.T.}		//|Executa Rotina no Encerramento da Janela |
	Private lCen	:= .T.	 //| Apresenta a Janela centralizada quando .T. |

	oWin:Activate(,,,lCen,bSai,,bEnt )

Return()
*******************************************************************************
Static Function rc(nVal1, nVal2)//|  Retorna Codigo RGB de Cor
*******************************************************************************
	Local nRGB_Black		:=	 0				 	//
	Local nRGB_White		:=	 RGB( 255 	, 255 	, 255	)// 16777215 	//
	Local nRGB_Red			:= RGB( 255 	, 0 		, 0		)// 16711680 	//1118719
	Local nRGB_Laranja 	:=	 RGB( 255	, 140 	, 0		)// 16747520 	//4886271
	Local nRGB_Amarelo	:= RGB( 255 	, 215	, 0 		)// 16766720 	//4784127
	Local nRGB_Verde		:= RGB( 0	 	, 255 	, 127	)// 65407 		//

	If Round(nVal1,2) <> Round(nVal2,2)

		If Abs(nVal1 - nVal2) <= 0.03
			Return (nRGB_Verde)

		ElseIf Abs(nVal1 - nVal2) <= 0.10

			Return (nRGB_Amarelo)

		ElseIf Abs(nVal1 - nVal2) <= 2

			Return (nRGB_Laranja)
		Else

			Return (nRGB_Red)
		EndIf

	EndIf

Return(nRGB_Black)
*******************************************************************************
Static Function CriaWhlp(oWHlp) //| Cria Janela Base |
*******************************************************************************

	Local nCVS 	:= 001  										//| Coordenada Vertical Superior 		|
	Local nCHE 	:= 001											//| Coordenada Horizontal Esquerda 	|
	Local nCVI 	:= 215											//| Coordenada Vertical Inferior 		|
	Local nCHD 	:= 980											//| Coordenada Horizontal Direita 	|
	Local cTit		:= "Ajuda"	//| Indica o título da janela.			|
	Local lPix		:= .T.											//| Indica se considera as coordenadas passadas em pixels (.T.) ou caracteres (.F.).|
	Local lTra		:=	 .F.											//| Se .T. permitira que a Dialog recebe um fundo transparente. |

	Private bEnt	:=	 Nil 	//	|	{||MsgStop("Apresenta Janela..."	),.T.} 	//|Executa Rotina na Apresentacao da Janela |
	Private bSai	:=	 Nil 	//| 	{||MsgStop("Fecha Janela..."			),.T.}		//|Executa Rotina no Encerramento da Janela |
	Private lCen	:= .T.	 	//|	Apresenta a Janela centralizada quando .T. |

	oWHlp := MSDialog():New(nCVS,nCHE,nCVI,nCHD,cTit,,,,,CLR_BLACK,CLR_WHITE,,,lPix,,,,lTra)

	TBitmap():New(0001,0001,978,215,,"\system\form_cal_nfi.png",.T.,oWHlp,{||},,.F.,.F.,,,.F.,,.T.,,.F.)

	oWHlp:Activate(,,,lCen,bSai,,bEnt )

Return()